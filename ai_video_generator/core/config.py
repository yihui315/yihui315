"""配置管理"""

from __future__ import annotations

import os
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import yaml


@dataclass
class ClaudeConfig:
    api_key: str = ""
    model: str = "claude-sonnet-4-20250514"


@dataclass
class OpenAIConfig:
    api_key: str = ""
    model: str = "gpt-4o"


@dataclass
class OllamaConfig:
    base_url: str = "http://localhost:11434"
    model: str = "qwen:3.6b"


@dataclass
class LLMConfig:
    primary: str = "claude"
    fallback_order: list[str] = field(
        default_factory=lambda: ["claude", "openai", "ollama"]
    )
    claude: ClaudeConfig = field(default_factory=ClaudeConfig)
    openai: OpenAIConfig = field(default_factory=OpenAIConfig)
    ollama: OllamaConfig = field(default_factory=OllamaConfig)


@dataclass
class MiniMaxConfig:
    api_key: str = ""
    group_id: str = ""
    base_url: str = "https://api.minimax.chat/v1"


@dataclass
class ImageConfig:
    minimax: MiniMaxConfig = field(default_factory=MiniMaxConfig)


@dataclass
class HailuoConfig:
    url: str = "https://hailuoai.video"
    timeout: int = 300
    poll_interval: int = 10


@dataclass
class VideoConfig:
    hailuo: HailuoConfig = field(default_factory=HailuoConfig)


@dataclass
class OutputConfig:
    dir: str = "./output"
    resolution: str = "1080x1920"
    platform: str = "douyin"


@dataclass
class AppConfig:
    """应用全局配置"""

    llm: LLMConfig = field(default_factory=LLMConfig)
    image: ImageConfig = field(default_factory=ImageConfig)
    video: VideoConfig = field(default_factory=VideoConfig)
    output: OutputConfig = field(default_factory=OutputConfig)


def _apply_env_overrides(config: AppConfig) -> AppConfig:
    """从环境变量覆盖配置中的 API 密钥"""
    env_key = os.environ.get("CLAUDE_API_KEY", "")
    if env_key:
        config.llm.claude.api_key = env_key

    env_key = os.environ.get("OPENAI_API_KEY", "")
    if env_key:
        config.llm.openai.api_key = env_key

    env_key = os.environ.get("MINIMAX_API_KEY", "")
    if env_key:
        config.image.minimax.api_key = env_key

    env_key = os.environ.get("MINIMAX_GROUP_ID", "")
    if env_key:
        config.image.minimax.group_id = env_key

    return config


def _dict_to_config(data: dict[str, Any]) -> AppConfig:
    """将字典转换为配置对象"""
    config = AppConfig()

    llm_data = data.get("llm", {})
    if llm_data:
        config.llm.primary = llm_data.get("primary", config.llm.primary)
        config.llm.fallback_order = llm_data.get(
            "fallback_order", config.llm.fallback_order
        )
        claude_data = llm_data.get("claude", {})
        if claude_data:
            config.llm.claude.api_key = claude_data.get(
                "api_key", config.llm.claude.api_key
            )
            config.llm.claude.model = claude_data.get(
                "model", config.llm.claude.model
            )
        openai_data = llm_data.get("openai", {})
        if openai_data:
            config.llm.openai.api_key = openai_data.get(
                "api_key", config.llm.openai.api_key
            )
            config.llm.openai.model = openai_data.get(
                "model", config.llm.openai.model
            )
        ollama_data = llm_data.get("ollama", {})
        if ollama_data:
            config.llm.ollama.base_url = ollama_data.get(
                "base_url", config.llm.ollama.base_url
            )
            config.llm.ollama.model = ollama_data.get(
                "model", config.llm.ollama.model
            )

    image_data = data.get("image", {})
    if image_data:
        mm_data = image_data.get("minimax", {})
        if mm_data:
            config.image.minimax.api_key = mm_data.get(
                "api_key", config.image.minimax.api_key
            )
            config.image.minimax.group_id = mm_data.get(
                "group_id", config.image.minimax.group_id
            )
            config.image.minimax.base_url = mm_data.get(
                "base_url", config.image.minimax.base_url
            )

    video_data = data.get("video", {})
    if video_data:
        hl_data = video_data.get("hailuo", {})
        if hl_data:
            config.video.hailuo.url = hl_data.get(
                "url", config.video.hailuo.url
            )
            config.video.hailuo.timeout = hl_data.get(
                "timeout", config.video.hailuo.timeout
            )
            config.video.hailuo.poll_interval = hl_data.get(
                "poll_interval", config.video.hailuo.poll_interval
            )

    output_data = data.get("output", {})
    if output_data:
        config.output.dir = output_data.get("dir", config.output.dir)
        config.output.resolution = output_data.get(
            "resolution", config.output.resolution
        )
        config.output.platform = output_data.get(
            "platform", config.output.platform
        )

    return config


def load_config(config_path: str | Path | None = None) -> AppConfig:
    """加载配置文件

    优先级: 环境变量 > 配置文件 > 默认值

    Args:
        config_path: 配置文件路径，默认为 config.yaml

    Returns:
        AppConfig 实例
    """
    if config_path is None:
        config_path = Path("config.yaml")
    else:
        config_path = Path(config_path)

    if config_path.exists():
        with open(config_path, encoding="utf-8") as f:
            data = yaml.safe_load(f) or {}
        config = _dict_to_config(data)
    else:
        config = AppConfig()

    return _apply_env_overrides(config)
