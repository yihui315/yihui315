"""Ollama 本地 LLM 客户端"""

from __future__ import annotations

import httpx

from ai_video_generator.core.config import OllamaConfig

from .base import BaseLLMClient


class OllamaClient(BaseLLMClient):
    """Ollama 本地 LLM 客户端（支持 Qwen 等模型）"""

    def __init__(self, config: OllamaConfig) -> None:
        self._config = config

    async def generate(self, prompt: str, system_prompt: str = "") -> str:
        """调用 Ollama 本地模型生成文本"""
        payload: dict = {
            "model": self._config.model,
            "prompt": prompt,
            "stream": False,
        }
        if system_prompt:
            payload["system"] = system_prompt

        async with httpx.AsyncClient(timeout=120) as client:
            resp = await client.post(
                f"{self._config.base_url}/api/generate",
                json=payload,
            )
            resp.raise_for_status()
            return resp.json()["response"]

    async def is_available(self) -> bool:
        """检查 Ollama 服务是否可用"""
        try:
            async with httpx.AsyncClient(timeout=5) as client:
                resp = await client.get(f"{self._config.base_url}/api/tags")
                return resp.status_code == 200
        except Exception:
            return False
