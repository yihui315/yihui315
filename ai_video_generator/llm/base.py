"""LLM 客户端基类"""

from __future__ import annotations

import abc


class BaseLLMClient(abc.ABC):
    """LLM 客户端抽象基类"""

    @abc.abstractmethod
    async def generate(self, prompt: str, system_prompt: str = "") -> str:
        """生成文本

        Args:
            prompt: 用户提示
            system_prompt: 系统提示

        Returns:
            生成的文本内容
        """

    @abc.abstractmethod
    async def is_available(self) -> bool:
        """检查服务是否可用"""
