"""数据模型测试"""

from __future__ import annotations

from pathlib import Path

from ai_video_generator.core.models import (
    Platform,
    SceneScript,
    Topic,
    VideoProject,
    VideoScript,
)


class TestModels:
    """测试数据模型"""

    def test_topic_defaults(self):
        topic = Topic(
            title="测试标题",
            description="测试描述",
            target_audience="年轻人",
        )
        assert topic.platform == Platform.DOUYIN
        assert topic.keywords == []

    def test_video_script_duration(self):
        topic = Topic(title="t", description="d", target_audience="a")
        script = VideoScript(topic=topic, title="视频")
        script.scenes = [
            SceneScript(
                scene_number=1,
                narration="旁白1",
                visual_description="desc1",
                duration_seconds=5.0,
            ),
            SceneScript(
                scene_number=2,
                narration="旁白2",
                visual_description="desc2",
                duration_seconds=8.0,
            ),
        ]
        script.update_duration()
        assert script.total_duration == 13.0

    def test_video_project_defaults(self):
        topic = Topic(title="t", description="d", target_audience="a")
        script = VideoScript(topic=topic, title="v")
        project = VideoProject(
            project_id="abc123",
            script=script,
            output_dir=Path("/tmp/test"),
        )
        assert project.status == "pending"
        assert project.final_video_path is None
