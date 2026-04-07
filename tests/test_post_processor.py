"""后处理模块测试"""

from __future__ import annotations

from ai_video_generator.video.post_processor import PostProcessor, _format_srt_time


class TestFormatSrtTime:
    """测试 SRT 时间格式化"""

    def test_zero(self):
        assert _format_srt_time(0) == "00:00:00,000"

    def test_seconds_only(self):
        assert _format_srt_time(5.5) == "00:00:05,500"

    def test_minutes_and_seconds(self):
        assert _format_srt_time(125.25) == "00:02:05,250"

    def test_hours(self):
        assert _format_srt_time(3661.0) == "01:01:01,000"


class TestGenerateSrt:
    """测试 SRT 字幕生成"""

    def test_basic_srt(self, tmp_path):
        scenes = [
            {"narration": "第一段旁白", "duration_seconds": 5.0},
            {"narration": "第二段旁白", "duration_seconds": 3.0},
        ]
        output = tmp_path / "test.srt"
        result = PostProcessor.generate_srt(scenes, output)

        assert result == output
        content = output.read_text(encoding="utf-8")

        assert "1\n" in content
        assert "00:00:00,000 --> 00:00:05,000" in content
        assert "第一段旁白" in content
        assert "2\n" in content
        assert "00:00:05,000 --> 00:00:08,000" in content
        assert "第二段旁白" in content

    def test_creates_parent_dirs(self, tmp_path):
        scenes = [{"narration": "test", "duration_seconds": 1.0}]
        output = tmp_path / "sub" / "dir" / "test.srt"
        PostProcessor.generate_srt(scenes, output)
        assert output.exists()
