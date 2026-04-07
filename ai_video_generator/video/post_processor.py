"""视频后处理模块 - 使用 FFmpeg 合成最终视频"""

from __future__ import annotations

import asyncio
import logging
import shutil
from pathlib import Path

logger = logging.getLogger(__name__)


class PostProcessor:
    """视频后处理器

    使用 FFmpeg 将视频片段拼接为最终成品，
    支持添加字幕、背景音乐等。
    """

    def __init__(self, resolution: str = "1080x1920") -> None:
        self._resolution = resolution

    @staticmethod
    def is_ffmpeg_available() -> bool:
        """检查 FFmpeg 是否可用"""
        return shutil.which("ffmpeg") is not None

    async def concat_videos(
        self, video_paths: list[Path], output_path: Path
    ) -> Path:
        """拼接多个视频片段为一个完整视频

        Args:
            video_paths: 视频片段路径列表
            output_path: 输出路径

        Returns:
            拼接后的视频路径
        """
        if not video_paths:
            raise ValueError("视频列表不能为空，需要至少一个视频片段")

        # 创建 FFmpeg concat 文件列表
        list_file = output_path.parent / "concat_list.txt"
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(list_file, "w", encoding="utf-8") as f:
            for vp in video_paths:
                f.write(f"file '{vp.resolve()}'\n")

        cmd = [
            "ffmpeg", "-y",
            "-f", "concat",
            "-safe", "0",
            "-i", str(list_file),
            "-c", "copy",
            str(output_path),
        ]

        proc = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        _, stderr = await proc.communicate()

        list_file.unlink(missing_ok=True)

        if proc.returncode != 0:
            raise RuntimeError(
                f"FFmpeg 拼接失败: {stderr.decode()}"
            )

        logger.info("视频拼接完成: %s", output_path)
        return output_path

    async def add_subtitles(
        self, video_path: Path, subtitle_path: Path, output_path: Path
    ) -> Path:
        """为视频添加字幕

        Args:
            video_path: 输入视频路径
            subtitle_path: SRT 字幕文件路径
            output_path: 输出路径

        Returns:
            带字幕的视频路径
        """
        cmd = [
            "ffmpeg", "-y",
            "-i", str(video_path),
            "-vf", f"subtitles={subtitle_path}",
            "-c:a", "copy",
            str(output_path),
        ]

        proc = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        _, stderr = await proc.communicate()

        if proc.returncode != 0:
            raise RuntimeError(
                f"FFmpeg 添加字幕失败: {stderr.decode()}"
            )

        logger.info("字幕已添加: %s", output_path)
        return output_path

    @staticmethod
    def generate_srt(
        scenes: list[dict], output_path: Path
    ) -> Path:
        """根据分镜脚本生成 SRT 字幕文件

        Args:
            scenes: 分镜列表，每项包含 narration 和 duration_seconds
            output_path: SRT 文件输出路径

        Returns:
            SRT 文件路径
        """
        output_path.parent.mkdir(parents=True, exist_ok=True)

        lines: list[str] = []
        current_time = 0.0

        for i, scene in enumerate(scenes, 1):
            start = current_time
            end = start + scene["duration_seconds"]
            lines.append(str(i))
            lines.append(
                f"{_format_srt_time(start)} --> {_format_srt_time(end)}"
            )
            lines.append(scene["narration"])
            lines.append("")
            current_time = end

        output_path.write_text("\n".join(lines), encoding="utf-8")
        return output_path


def _format_srt_time(seconds: float) -> str:
    """将秒数格式化为 SRT 时间格式 HH:MM:SS,mmm"""
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    millis = int((seconds % 1) * 1000)
    return f"{hours:02d}:{minutes:02d}:{secs:02d},{millis:03d}"
