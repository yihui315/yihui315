"""数据模型定义"""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path


class Platform(str, Enum):
    """目标发布平台"""

    DOUYIN = "douyin"
    KUAISHOU = "kuaishou"
    BILIBILI = "bilibili"
    XIAOHONGSHU = "xiaohongshu"


class LLMProvider(str, Enum):
    """LLM 提供商"""

    CLAUDE = "claude"
    OPENAI = "openai"
    OLLAMA = "ollama"


@dataclass
class Topic:
    """选题"""

    title: str
    description: str
    target_audience: str
    keywords: list[str] = field(default_factory=list)
    platform: Platform = Platform.DOUYIN


@dataclass
class SceneScript:
    """单个分镜脚本"""

    scene_number: int
    narration: str
    visual_description: str
    duration_seconds: float
    image_path: Path | None = None
    video_path: Path | None = None


@dataclass
class VideoScript:
    """完整视频脚本"""

    topic: Topic
    title: str
    scenes: list[SceneScript] = field(default_factory=list)
    total_duration: float = 0.0

    def update_duration(self) -> None:
        """根据分镜更新总时长"""
        self.total_duration = sum(s.duration_seconds for s in self.scenes)


@dataclass
class VideoProject:
    """视频项目（完整的生成任务）"""

    project_id: str
    script: VideoScript
    output_dir: Path
    final_video_path: Path | None = None
    status: str = "pending"
