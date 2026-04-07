"""Claude API 客户端"""

from __future__ import annotations

import anthropic

from ai_video_generator.core.config import ClaudeConfig

from .base import BaseLLMClient


class ClaudeClient(BaseLLMClient):
    """Claude API 客户端"""

    def __init__(self, config: ClaudeConfig) -> None:
        self._config = config
        self._client = anthropic.AsyncAnthropic(api_key=config.api_key)

    async def generate(self, prompt: str, system_prompt: str = "") -> str:
        """调用 Claude 生成文本"""
        kwargs: dict = {
            "model": self._config.model,
            "max_tokens": 4096,
            "messages": [{"role": "user", "content": prompt}],
        }
        if system_prompt:
            kwargs["system"] = system_prompt

        response = await self._client.messages.create(**kwargs)
        return response.content[0].text

    async def is_available(self) -> bool:
        """检查 Claude API 是否可用"""
        if not self._config.api_key:
            return False
        try:
            await self._client.messages.create(
                model=self._config.model,
                max_tokens=10,
                messages=[{"role": "user", "content": "ping"}],
            )
            return True
        except Exception:
            return False
