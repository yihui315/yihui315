"""配置管理测试"""

from __future__ import annotations

import os
import tempfile
from pathlib import Path

import yaml

from ai_video_generator.core.config import load_config


class TestLoadConfig:
    """测试配置加载"""

    def test_default_config(self):
        """无配置文件时使用默认值"""
        config = load_config(Path("/nonexistent/config.yaml"))
        assert config.llm.primary == "claude"
        assert config.llm.claude.model == "claude-sonnet-4-20250514"
        assert config.llm.openai.model == "gpt-4o"
        assert config.llm.ollama.base_url == "http://localhost:11434"
        assert config.output.resolution == "1080x1920"

    def test_load_from_yaml(self, tmp_path):
        """从 YAML 文件加载配置"""
        config_data = {
            "llm": {
                "primary": "openai",
                "claude": {"api_key": "test-key", "model": "claude-3-opus"},
            },
            "output": {"platform": "bilibili"},
        }
        config_file = tmp_path / "config.yaml"
        config_file.write_text(yaml.dump(config_data), encoding="utf-8")

        config = load_config(config_file)
        assert config.llm.primary == "openai"
        assert config.llm.claude.api_key == "test-key"
        assert config.llm.claude.model == "claude-3-opus"
        assert config.output.platform == "bilibili"
        # 未指定的项保持默认值
        assert config.llm.openai.model == "gpt-4o"

    def test_env_override(self, tmp_path, monkeypatch):
        """环境变量覆盖配置文件"""
        config_data = {
            "llm": {"claude": {"api_key": "file-key"}},
        }
        config_file = tmp_path / "config.yaml"
        config_file.write_text(yaml.dump(config_data), encoding="utf-8")

        monkeypatch.setenv("CLAUDE_API_KEY", "env-key")
        monkeypatch.setenv("OPENAI_API_KEY", "env-openai-key")

        config = load_config(config_file)
        # 环境变量优先
        assert config.llm.claude.api_key == "env-key"
        assert config.llm.openai.api_key == "env-openai-key"

    def test_empty_yaml(self, tmp_path):
        """空 YAML 文件使用默认值"""
        config_file = tmp_path / "config.yaml"
        config_file.write_text("", encoding="utf-8")

        config = load_config(config_file)
        assert config.llm.primary == "claude"
