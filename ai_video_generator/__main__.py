"""CLI 入口"""

from __future__ import annotations

import argparse
import asyncio
import logging
import sys

from ai_video_generator.core.config import load_config
from ai_video_generator.core.pipeline import Pipeline


def main() -> None:
    parser = argparse.ArgumentParser(
        description="AI 自动生成爆款视频"
    )
    parser.add_argument(
        "keywords",
        help="热门话题关键词",
    )
    parser.add_argument(
        "-c", "--config",
        default="config.yaml",
        help="配置文件路径 (默认: config.yaml)",
    )
    parser.add_argument(
        "-p", "--platform",
        default="douyin",
        choices=["douyin", "kuaishou", "bilibili", "xiaohongshu"],
        help="目标平台 (默认: douyin)",
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="输出详细日志",
    )

    args = parser.parse_args()

    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    )

    config = load_config(args.config)
    pipeline = Pipeline(config)

    try:
        project = asyncio.run(
            pipeline.run(args.keywords, args.platform)
        )
        print(f"\n✅ 视频生成完成!")
        print(f"   项目ID: {project.project_id}")
        print(f"   输出目录: {project.output_dir}")
        print(f"   最终视频: {project.final_video_path}")
    except KeyboardInterrupt:
        print("\n⏹ 已取消")
        sys.exit(1)
    except Exception as e:
        logging.getLogger(__name__).error("视频生成失败: %s", e)
        sys.exit(1)


if __name__ == "__main__":
    main()
