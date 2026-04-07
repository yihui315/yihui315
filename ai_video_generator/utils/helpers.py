"""工具函数"""

from __future__ import annotations

import json
import logging
import re


logger = logging.getLogger(__name__)


def parse_json_from_llm(text: str) -> dict | list:
    """从 LLM 输出中提取 JSON

    LLM 输出可能包含 markdown 代码块或额外文本，
    此函数尝试提取其中的 JSON 内容。

    Args:
        text: LLM 的文本输出

    Returns:
        解析后的 JSON 对象
    """
    # 尝试从 markdown 代码块中提取
    code_block = re.search(r"```(?:json)?\s*\n(.*?)\n```", text, re.DOTALL)
    if code_block:
        return json.loads(code_block.group(1))

    # 尝试直接解析
    text = text.strip()
    if text.startswith(("{", "[")):
        return json.loads(text)

    # 尝试找到第一个 JSON 对象或数组
    for start_char, end_char in [("{", "}"), ("[", "]")]:
        start = text.find(start_char)
        if start == -1:
            continue
        # 从后向前找匹配的结束字符
        end = text.rfind(end_char)
        if end > start:
            return json.loads(text[start : end + 1])

    raise ValueError(f"无法从文本中提取 JSON: {text[:200]}...")


def sanitize_filename(name: str) -> str:
    """将字符串转换为安全的文件名

    Args:
        name: 原始文件名

    Returns:
        安全的文件名
    """
    # 移除或替换不安全的字符
    safe = re.sub(r'[<>:"/\\|?*]', "_", name)
    # 限制长度
    return safe[:100].strip()
