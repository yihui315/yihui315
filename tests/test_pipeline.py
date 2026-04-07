"""Pipeline 测试 (使用 mock)"""

from __future__ import annotations

from unittest.mock import AsyncMock, patch

import pytest

from ai_video_generator.core.config import AppConfig
from ai_video_generator.core.models import Platform, Topic
from ai_video_generator.core.pipeline import Pipeline


class TestPipelineTopics:
    """测试选题生成"""

    @pytest.mark.asyncio
    async def test_generate_topics(self):
        """测试选题生成解析"""
        config = AppConfig()
        pipeline = Pipeline(config)

        mock_response = """```json
[
  {
    "title": "AI改变生活的5种方式",
    "description": "探索AI如何改变日常生活",
    "target_audience": "科技爱好者",
    "keywords": ["AI", "科技", "生活"]
  }
]
```"""
        mock_llm = AsyncMock()
        mock_llm.generate.return_value = mock_response
        mock_llm.is_available.return_value = True

        with patch.object(pipeline, "_get_llm", return_value=mock_llm):
            topics = await pipeline.generate_topics("AI科技")

        assert len(topics) == 1
        assert topics[0].title == "AI改变生活的5种方式"
        assert topics[0].platform == Platform.DOUYIN

    @pytest.mark.asyncio
    async def test_generate_script(self):
        """测试脚本生成解析"""
        config = AppConfig()
        pipeline = Pipeline(config)

        mock_response = """```json
{
  "title": "测试视频",
  "scenes": [
    {
      "scene_number": 1,
      "narration": "大家好",
      "visual_description": "A person waving at camera",
      "duration_seconds": 3.0
    },
    {
      "scene_number": 2,
      "narration": "今天聊AI",
      "visual_description": "Futuristic AI interface",
      "duration_seconds": 5.0
    }
  ]
}
```"""
        mock_llm = AsyncMock()
        mock_llm.generate.return_value = mock_response
        mock_llm.is_available.return_value = True

        topic = Topic(
            title="AI科技",
            description="关于AI的话题",
            target_audience="科技爱好者",
        )

        with patch.object(pipeline, "_get_llm", return_value=mock_llm):
            script = await pipeline.generate_script(topic)

        assert script.title == "测试视频"
        assert len(script.scenes) == 2
        assert script.total_duration == 8.0
        assert script.scenes[0].narration == "大家好"
