"""OpenAI (GPT) API 客户端"""

from __future__ import annotations

import openai

from ai_video_generator.core.config import OpenAIConfig

from .base import BaseLLMClient


class OpenAIClient(BaseLLMClient):
    """OpenAI GPT API 客户端"""

    def __init__(self, config: OpenAIConfig) -> None:
        self._config = config
        self._client = openai.AsyncOpenAI(api_key=config.api_key)

    async def generate(self, prompt: str, system_prompt: str = "") -> str:
        """调用 GPT 生成文本"""
        messages: list[dict[str, str]] = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        messages.append({"role": "user", "content": prompt})

        response = await self._client.chat.completions.create(
            model=self._config.model,
            messages=messages,
            max_tokens=4096,
        )
        content = response.choices[0].message.content
        return content or ""

    async def is_available(self) -> bool:
        """检查 OpenAI API 是否可用"""
        if not self._config.api_key:
            return False
        try:
            await self._client.chat.completions.create(
                model=self._config.model,
                max_tokens=10,
                messages=[{"role": "user", "content": "ping"}],
            )
            return True
        except Exception:
            return False
