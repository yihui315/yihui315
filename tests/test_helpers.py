"""工具函数测试"""

from __future__ import annotations

import pytest

from ai_video_generator.utils.helpers import parse_json_from_llm, sanitize_filename


class TestParseJsonFromLLM:
    """测试从 LLM 输出中提取 JSON"""

    def test_plain_json_object(self):
        text = '{"title": "test", "value": 42}'
        result = parse_json_from_llm(text)
        assert result == {"title": "test", "value": 42}

    def test_plain_json_array(self):
        text = '[{"a": 1}, {"a": 2}]'
        result = parse_json_from_llm(text)
        assert len(result) == 2

    def test_markdown_code_block(self):
        text = """Here is the result:
```json
{"title": "爆款标题", "scenes": []}
```
Hope this helps!"""
        result = parse_json_from_llm(text)
        assert result["title"] == "爆款标题"

    def test_json_with_surrounding_text(self):
        text = 'Here is the output: {"key": "value"} end of output.'
        result = parse_json_from_llm(text)
        assert result["key"] == "value"

    def test_invalid_json_raises(self):
        with pytest.raises(ValueError, match="无法从文本中提取 JSON"):
            parse_json_from_llm("no json here at all")


class TestSanitizeFilename:
    """测试文件名安全化"""

    def test_removes_unsafe_chars(self):
        assert sanitize_filename('file:name<>test') == "file_name__test"

    def test_truncates_long_names(self):
        long_name = "a" * 200
        result = sanitize_filename(long_name)
        assert len(result) <= 100

    def test_preserves_safe_chars(self):
        assert sanitize_filename("hello_world-123") == "hello_world-123"

    def test_chinese_chars(self):
        assert sanitize_filename("测试视频标题") == "测试视频标题"
