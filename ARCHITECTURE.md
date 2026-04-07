# AI 自动生成爆款视频 - 架构设计文档

## 项目概述

本项目是一款 AI 驱动的自动化爆款视频生成软件，整合多种 AI 能力，实现从选题策划到视频成片的全流程自动化。

## 可用资源

| 资源 | 用途 | 接入方式 |
|------|------|----------|
| Claude API | 脚本撰写、内容策划 | API |
| GPT API | 脚本撰写、SEO优化 | API |
| MiniMax 2.7 | 图片生成 | API |
| Ollama (Qwen 3.6) | 本地文案生成、辅助处理 | 本地 API |
| 海螺视频生成 | 视频生成（图生视频） | Web 自动化 |
| GitHub | 代码管理、CI/CD | Git |

## 系统架构

```
┌─────────────────────────────────────────────────────┐
│                   Pipeline Orchestrator              │
│              (流水线编排引擎)                          │
├─────────┬──────────┬───────────┬───────────┬────────┤
│  选题    │  脚本     │  图片      │  视频      │ 后处理  │
│  模块    │  生成     │  生成      │  生成      │ 模块   │
│         │          │           │           │        │
│ Claude  │ Claude   │ MiniMax   │ 海螺       │ FFmpeg │
│ GPT     │ GPT      │ 2.7       │ (Web Auto)│        │
│ Ollama  │ Ollama   │           │           │        │
└─────────┴──────────┴───────────┴───────────┴────────┘
         │                                    │
         └──────── Config Manager ────────────┘
```

## 核心流程

### 1. 选题策划 (Topic Planning)
- 输入：热门话题关键词、目标平台（抖音/快手/B站/小红书）
- 处理：使用 Claude/GPT 分析热点，生成爆款选题
- 输出：选题列表（标题 + 简介 + 目标受众）

### 2. 脚本生成 (Script Generation)
- 输入：选题信息
- 处理：使用 Claude/GPT/Ollama 生成视频脚本
- 输出：分镜脚本（旁白文案 + 画面描述 + 时长标注）

### 3. 图片生成 (Image Generation)
- 输入：分镜脚本中的画面描述
- 处理：使用 MiniMax 2.7 API 根据画面描述生成图片
- 输出：每个分镜对应的高质量图片

### 4. 视频生成 (Video Generation)
- 输入：生成的图片
- 处理：通过 Playwright 自动化操作海螺网页版，上传图片生成视频片段
- 输出：每个分镜对应的视频片段

### 5. 后处理合成 (Post-Processing)
- 输入：视频片段 + 旁白文案
- 处理：使用 FFmpeg 拼接视频、添加字幕、配音、背景音乐
- 输出：最终成品视频

## 目录结构

```
ai_video_generator/
├── core/
│   ├── __init__.py
│   ├── pipeline.py          # 流水线编排引擎
│   ├── config.py            # 配置管理
│   └── models.py            # 数据模型
├── llm/
│   ├── __init__.py
│   ├── base.py              # LLM 基类
│   ├── claude_client.py     # Claude API 客户端
│   ├── openai_client.py     # GPT API 客户端
│   └── ollama_client.py     # Ollama 本地客户端
├── image/
│   ├── __init__.py
│   └── minimax_client.py    # MiniMax 图片生成
├── video/
│   ├── __init__.py
│   ├── hailuo_automation.py # 海螺网页自动化
│   └── post_processor.py    # FFmpeg 后处理
├── utils/
│   ├── __init__.py
│   └── helpers.py           # 工具函数
├── __init__.py
└── __main__.py              # CLI 入口
```

## LLM 降级策略

系统支持多 LLM 降级：
1. **首选**：Claude（创意能力强）
2. **备选**：GPT（稳定性好）
3. **本地兜底**：Ollama Qwen 3.6（无需网络，保障可用性）

## 配置说明

所有 API 密钥和配置通过 `config.yaml` 管理，支持环境变量覆盖。
