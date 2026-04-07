"""海螺视频生成 - 网页自动化"""

from __future__ import annotations

import asyncio
import logging
from pathlib import Path

from ai_video_generator.core.config import HailuoConfig

logger = logging.getLogger(__name__)


class HailuoAutomation:
    """海螺视频生成网页自动化客户端

    通过 Playwright 自动化操作海螺网页版，
    将图片上传并生成视频片段。
    """

    def __init__(self, config: HailuoConfig) -> None:
        self._config = config
        self._browser = None
        self._context = None

    async def start(self) -> None:
        """启动浏览器"""
        # 延迟导入，仅在实际使用时才需要 playwright
        from playwright.async_api import async_playwright

        self._pw = await async_playwright().start()
        self._browser = await self._pw.chromium.launch(headless=False)
        self._context = await self._browser.new_context()
        logger.info("浏览器已启动")

    async def stop(self) -> None:
        """关闭浏览器"""
        if self._context:
            await self._context.close()
        if self._browser:
            await self._browser.close()
        if self._pw:
            await self._pw.stop()
        logger.info("浏览器已关闭")

    async def generate_video(
        self, image_path: Path, output_path: Path
    ) -> Path:
        """通过海螺网页版将图片转换为视频

        Args:
            image_path: 输入图片路径
            output_path: 视频输出路径

        Returns:
            生成的视频路径

        Note:
            此方法通过 Playwright 自动化操作海螺网页版。
            需要用户预先登录海螺账号（首次使用时会弹出浏览器窗口）。
            由于网页版界面可能更新，选择器可能需要维护。
        """
        if not self._context:
            raise RuntimeError("浏览器未启动，请先调用 start()")

        page = await self._context.new_page()
        try:
            await page.goto(self._config.url, wait_until="networkidle")

            # 上传图片
            file_input = page.locator('input[type="file"]')
            await file_input.set_input_files(str(image_path))
            logger.info("图片已上传: %s", image_path)

            # 点击生成按钮
            generate_btn = page.get_by_text("生成")
            await generate_btn.click()
            logger.info("已点击生成按钮")

            # 等待视频生成完成
            elapsed = 0
            while elapsed < self._config.timeout:
                # 检查是否有下载按钮出现（表示生成完成）
                download_btn = page.get_by_text("下载")
                if await download_btn.is_visible():
                    break
                await asyncio.sleep(self._config.poll_interval)
                elapsed += self._config.poll_interval
                logger.info("等待视频生成... %ds/%ds", elapsed, self._config.timeout)

            if elapsed >= self._config.timeout:
                raise TimeoutError(
                    f"视频生成超时 ({self._config.timeout}s)"
                )

            # 下载视频
            async with page.expect_download() as download_info:
                await page.get_by_text("下载").click()
            download = await download_info.value

            output_path.parent.mkdir(parents=True, exist_ok=True)
            await download.save_as(str(output_path))
            logger.info("视频已保存: %s", output_path)

            return output_path
        finally:
            await page.close()
