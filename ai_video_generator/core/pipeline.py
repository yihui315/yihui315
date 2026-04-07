"""流水线编排引擎 - 核心业务逻辑"""

from __future__ import annotations

import json
import logging
import uuid
from pathlib import Path

from ai_video_generator.core.config import AppConfig
from ai_video_generator.core.models import (
    LLMProvider,
    Platform,
    SceneScript,
    Topic,
    VideoProject,
    VideoScript,
)
from ai_video_generator.image.minimax_client import MiniMaxImageClient
from ai_video_generator.llm.base import BaseLLMClient
from ai_video_generator.llm.claude_client import ClaudeClient
from ai_video_generator.llm.ollama_client import OllamaClient
from ai_video_generator.llm.openai_client import OpenAIClient
from ai_video_generator.utils.helpers import parse_json_from_llm, sanitize_filename
from ai_video_generator.video.hailuo_automation import HailuoAutomation
from ai_video_generator.video.post_processor import PostProcessor

logger = logging.getLogger(__name__)

TOPIC_SYSTEM_PROMPT = """你是一位短视频爆款选题策划专家。
根据用户提供的关键词和目标平台，生成3个爆款选题方案。
返回 JSON 数组，每项包含:
- title: 视频标题
- description: 简要描述
- target_audience: 目标受众
- keywords: 关键词数组"""

SCRIPT_SYSTEM_PROMPT = """你是一位专业的短视频分镜脚本编剧。
根据给定的选题，编写一个完整的分镜脚本。
返回 JSON 对象，包含:
- title: 视频标题
- scenes: 分镜数组，每项包含:
  - scene_number: 分镜序号
  - narration: 旁白文案
  - visual_description: 画面描述（用于AI生图，英文，详细具体）
  - duration_seconds: 建议时长（秒）
总时长控制在60秒以内，分5-8个分镜。"""


class Pipeline:
    """视频生成流水线"""

    def __init__(self, config: AppConfig) -> None:
        self._config = config
        self._llm_clients: dict[str, BaseLLMClient] = {}
        self._image_client = MiniMaxImageClient(config.image.minimax)
        self._video_client = HailuoAutomation(config.video.hailuo)
        self._post_processor = PostProcessor(config.output.resolution)
        self._init_llm_clients()

    def _init_llm_clients(self) -> None:
        """初始化 LLM 客户端"""
        cfg = self._config.llm
        self._llm_clients[LLMProvider.CLAUDE] = ClaudeClient(cfg.claude)
        self._llm_clients[LLMProvider.OPENAI] = OpenAIClient(cfg.openai)
        self._llm_clients[LLMProvider.OLLAMA] = OllamaClient(cfg.ollama)

    async def _get_llm(self) -> BaseLLMClient:
        """根据降级策略获取可用的 LLM 客户端"""
        for provider_name in self._config.llm.fallback_order:
            provider = LLMProvider(provider_name)
            client = self._llm_clients.get(provider)
            if client and await client.is_available():
                logger.info("使用 LLM: %s", provider_name)
                return client
        raise RuntimeError(
            "没有可用的 LLM 服务，请检查配置和网络连接"
        )

    async def generate_topics(
        self, keywords: str, platform: Platform = Platform.DOUYIN
    ) -> list[Topic]:
        """生成爆款选题

        Args:
            keywords: 热门话题关键词
            platform: 目标平台

        Returns:
            选题列表
        """
        llm = await self._get_llm()
        prompt = f"关键词: {keywords}\n目标平台: {platform.value}"
        response = await llm.generate(prompt, TOPIC_SYSTEM_PROMPT)

        topics_data = parse_json_from_llm(response)
        if not isinstance(topics_data, list):
            topics_data = [topics_data]

        topics = []
        for item in topics_data:
            topics.append(
                Topic(
                    title=item["title"],
                    description=item["description"],
                    target_audience=item["target_audience"],
                    keywords=item.get("keywords", []),
                    platform=platform,
                )
            )
        return topics

    async def generate_script(self, topic: Topic) -> VideoScript:
        """根据选题生成分镜脚本

        Args:
            topic: 选题

        Returns:
            视频脚本
        """
        llm = await self._get_llm()
        prompt = (
            f"选题标题: {topic.title}\n"
            f"选题描述: {topic.description}\n"
            f"目标受众: {topic.target_audience}\n"
            f"平台: {topic.platform.value}"
        )
        response = await llm.generate(prompt, SCRIPT_SYSTEM_PROMPT)
        script_data = parse_json_from_llm(response)

        scenes = []
        for s in script_data["scenes"]:
            scenes.append(
                SceneScript(
                    scene_number=s["scene_number"],
                    narration=s["narration"],
                    visual_description=s["visual_description"],
                    duration_seconds=s["duration_seconds"],
                )
            )

        script = VideoScript(topic=topic, title=script_data["title"], scenes=scenes)
        script.update_duration()
        return script

    async def generate_images(self, script: VideoScript, output_dir: Path) -> None:
        """为每个分镜生成图片

        Args:
            script: 视频脚本
            output_dir: 图片输出目录
        """
        for scene in script.scenes:
            img_path = output_dir / f"scene_{scene.scene_number:03d}.png"
            await self._image_client.generate_image(
                prompt=scene.visual_description,
                output_path=img_path,
            )
            scene.image_path = img_path
            logger.info(
                "分镜 %d 图片已生成: %s", scene.scene_number, img_path
            )

    async def generate_videos(self, script: VideoScript, output_dir: Path) -> None:
        """将每个分镜的图片转换为视频片段

        Args:
            script: 视频脚本（需已生成图片）
            output_dir: 视频输出目录
        """
        await self._video_client.start()
        try:
            for scene in script.scenes:
                if not scene.image_path:
                    raise ValueError(
                        f"分镜 {scene.scene_number} 缺少图片"
                    )
                video_path = output_dir / f"scene_{scene.scene_number:03d}.mp4"
                await self._video_client.generate_video(
                    image_path=scene.image_path,
                    output_path=video_path,
                )
                scene.video_path = video_path
        finally:
            await self._video_client.stop()

    async def compose_final_video(
        self, script: VideoScript, output_dir: Path
    ) -> Path:
        """合成最终视频

        Args:
            script: 视频脚本（需已生成视频片段）
            output_dir: 输出目录

        Returns:
            最终视频路径
        """
        video_paths = []
        for scene in script.scenes:
            if not scene.video_path:
                raise ValueError(
                    f"分镜 {scene.scene_number} 缺少视频片段"
                )
            video_paths.append(scene.video_path)

        # 拼接视频
        concat_path = output_dir / "concat.mp4"
        await self._post_processor.concat_videos(video_paths, concat_path)

        # 生成字幕
        srt_path = output_dir / "subtitles.srt"
        scenes_data = [
            {
                "narration": s.narration,
                "duration_seconds": s.duration_seconds,
            }
            for s in script.scenes
        ]
        PostProcessor.generate_srt(scenes_data, srt_path)

        # 添加字幕
        final_path = output_dir / f"{sanitize_filename(script.title)}.mp4"
        await self._post_processor.add_subtitles(concat_path, srt_path, final_path)

        # 清理中间文件
        concat_path.unlink(missing_ok=True)

        return final_path

    async def run(self, keywords: str, platform: str = "douyin") -> VideoProject:
        """运行完整的视频生成流水线

        Args:
            keywords: 热门话题关键词
            platform: 目标平台

        Returns:
            视频项目
        """
        target_platform = Platform(platform)
        project_id = uuid.uuid4().hex[:8]
        output_dir = Path(self._config.output.dir) / project_id
        output_dir.mkdir(parents=True, exist_ok=True)

        logger.info("=== 开始视频生成 [%s] ===", project_id)

        # Step 1: 生成选题
        logger.info("Step 1: 生成选题...")
        topics = await self.generate_topics(keywords, target_platform)
        topic = topics[0]  # 选择第一个选题
        logger.info("选题: %s", topic.title)

        # Step 2: 生成脚本
        logger.info("Step 2: 生成脚本...")
        script = await self.generate_script(topic)
        # 保存脚本
        script_file = output_dir / "script.json"
        script_file.write_text(
            json.dumps(
                {
                    "title": script.title,
                    "scenes": [
                        {
                            "scene_number": s.scene_number,
                            "narration": s.narration,
                            "visual_description": s.visual_description,
                            "duration_seconds": s.duration_seconds,
                        }
                        for s in script.scenes
                    ],
                },
                ensure_ascii=False,
                indent=2,
            ),
            encoding="utf-8",
        )
        logger.info("脚本已保存: %s", script_file)

        # Step 3: 生成图片
        logger.info("Step 3: 生成分镜图片...")
        images_dir = output_dir / "images"
        images_dir.mkdir(exist_ok=True)
        await self.generate_images(script, images_dir)

        # Step 4: 生成视频片段
        logger.info("Step 4: 生成视频片段...")
        videos_dir = output_dir / "videos"
        videos_dir.mkdir(exist_ok=True)
        await self.generate_videos(script, videos_dir)

        # Step 5: 合成最终视频
        logger.info("Step 5: 合成最终视频...")
        final_path = await self.compose_final_video(script, output_dir)

        project = VideoProject(
            project_id=project_id,
            script=script,
            output_dir=output_dir,
            final_video_path=final_path,
            status="completed",
        )

        logger.info("=== 视频生成完成 [%s] ===", project_id)
        logger.info("最终视频: %s", final_path)
        return project
