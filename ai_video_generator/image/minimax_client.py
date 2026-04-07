"""MiniMax 图片生成客户端"""

from __future__ import annotations

import base64
from pathlib import Path

import httpx

from ai_video_generator.core.config import MiniMaxConfig


class MiniMaxImageClient:
    """MiniMax 2.7 图片生成客户端"""

    def __init__(self, config: MiniMaxConfig) -> None:
        self._config = config

    async def generate_image(
        self, prompt: str, output_path: Path, width: int = 1080, height: int = 1920
    ) -> Path:
        """根据文本描述生成图片

        Args:
            prompt: 图片描述
            output_path: 图片保存路径
            width: 图片宽度
            height: 图片高度

        Returns:
            生成的图片路径
        """
        headers = {
            "Authorization": f"Bearer {self._config.api_key}",
            "Content-Type": "application/json",
        }
        payload = {
            "model": "abab6.5-chat",
            "prompt": prompt,
            "width": width,
            "height": height,
            "n": 1,
        }

        async with httpx.AsyncClient(timeout=120) as client:
            resp = await client.post(
                f"{self._config.base_url}/text_to_image",
                headers=headers,
                json=payload,
                params={"GroupId": self._config.group_id},
            )
            resp.raise_for_status()
            data = resp.json()

        # 解码 base64 图片并保存
        try:
            img_b64 = data["data"]["image"]
        except (KeyError, TypeError) as exc:
            raise ValueError(
                f"MiniMax API 返回了意外的响应格式: {data}"
            ) from exc
        img_bytes = base64.b64decode(img_b64)

        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_bytes(img_bytes)
        return output_path

    async def is_available(self) -> bool:
        """检查 MiniMax API 是否可用"""
        return bool(self._config.api_key and self._config.group_id)
