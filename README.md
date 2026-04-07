# 🎬 AI 视频解说与切片工具方案

> 自动生成电影/电视剧解说词、批量生产切片视频，适配视频号、博客等平台

---

## 🏆 最推荐方案：NarratoAI（首选）

**GitHub：** [linyqh/NarratoAI](https://github.com/linyqh/NarratoAI) ⭐ 8500+（截至 2026 年 4 月）

NarratoAI 是目前 GitHub 上**最专注于影视解说自动化**的开源项目，专为内容创作者和自媒体团队设计。

### 核心功能

| 功能 | 描述 |
|------|------|
| 🤖 一键生成解说词 | 上传视频后，AI 自动分析剧情、生成解说脚本 |
| ✂️ 智能视频剪辑 | 自动场景检测、智能跳剪，无需手动剪辑 |
| 🎙️ 多引擎 TTS 配音 | Edge TTS、Azure、腾讯云、SoulVoice、IndexTTS2（声音克隆）|
| 📝 动态字幕生成 | 支持词级时间戳，卡拉OK字幕效果 |
| 📦 批量生产 | 支持多任务并发处理，批量生成多个视频 |
| 🔌 REST API | 提供完整后端 API，支持自动化流水线 |
| 📱 多平台适配 | 支持竖屏（9:16）短视频格式，适配视频号/抖音/B站 |

### 支持的 AI 大模型（LLM）

- **国际**：OpenAI GPT-4o、Google Gemini、Anthropic Claude
- **国内（无需 VPN）**：DeepSeek、阿里通义千问（Qwen）、SiliconFlow

### 支持的 TTS（文字转语音）

- **免费**：Edge TTS（微软）
- **付费/云端**：Azure Speech、腾讯云 TTS、SoulVoice
- **声音克隆**：IndexTTS2（仅需 30 秒参考音频即可零样本克隆声音）

### 快速部署

```bash
# Docker 一键部署（推荐）
docker pull ghcr.io/linyqh/narratoai:latest
docker run -p 8080:8080 ghcr.io/linyqh/narratoai:latest

# 或使用 Python 本地运行
git clone https://github.com/linyqh/NarratoAI.git
cd NarratoAI
pip install -r requirements.txt
python main.py
```

---

## 🥈 备选方案

### 方案二：MoneyPrinterTurbo

**GitHub：** [harry0703/MoneyPrinterTurbo](https://github.com/harry0703/MoneyPrinterTurbo) ⭐ 22000+（截至 2026 年 4 月）

适合**从主题关键词批量生成**短视频，输入主题自动完成素材搜集+脚本+配音+字幕+成片。

**优势：**
- ⭐ 最高 Star 数，社区活跃
- 📦 真正的一键批量生产（单次可生成 100+ 视频）
- 🇨🇳 原生支持中文，DeepSeek/通义千问等国内模型开箱即用
- 🌐 提供在线版 [reccloud.cn](https://reccloud.cn)（无需部署）
- 🔌 FastAPI RESTful API，支持 Swagger UI 文档

**局限：** 主要从文字/主题生成视频，对已有视频的解说切片功能较弱。

---

### 方案三：GhostCut（鬼手剪辑）

**GitHub：** [JollyToday/Turn_Movie_Clips_to_Narration_Videos](https://github.com/JollyToday/Turn_Movie_Clips_to_Narration_Videos)

专为**影视切片解说**设计，效率极高（号称从1小时剪到2-3分钟）。

**优势：**
- 🎭 自动提取对白、识别角色
- 🧹 背景噪声分离，音画自动对齐
- 🌐 多语言支持，AI 字幕翻译
- 🎙️ 超真实 AI 声音克隆配音
- 🔌 支持 API 接入和批量处理

**注意：** 有 SaaS 版本（[jollytoday.com](https://jollytoday.com)），部分功能需付费。

---

## ⚙️ 推荐 API 技术栈

### 最佳组合方案（适合国内用户）

```
视频输入
   ↓
[OpenAI Whisper] ← 语音识别 + 字幕提取（支持普通话，准确率 95%+）
   ↓
[DeepSeek / 通义千问] ← AI 解说词生成（中文优化，无需 VPN）
   ↓
[Edge TTS / 腾讯云 TTS] ← 文字转语音配音
   ↓
[FFmpeg] ← 视频合成、字幕烧录、切片
   ↓
成品视频（MP4 竖屏 9:16）→ 视频号 / 博客
```

### API 选型对比

| API | 用途 | 费用 | 国内可用 | 推荐指数 |
|-----|------|------|---------|---------|
| **OpenAI Whisper** | 语音识别(STT) | 免费/开源 | 需 VPN（可本地部署） | ⭐⭐⭐⭐⭐ |
| **DeepSeek API** | 解说词生成(LLM) | 极低（约 ¥2/百万 tokens）| ✅ 国内直连 | ⭐⭐⭐⭐⭐ |
| **阿里通义千问** | 解说词生成(LLM) | 有免费额度 | ✅ 国内直连 | ⭐⭐⭐⭐ |
| **微软 Edge TTS** | 语音合成(TTS) | 免费 | ✅ 国内可用 | ⭐⭐⭐⭐ |
| **腾讯云 TTS** | 语音合成(TTS) | 按量计费 | ✅ 国内优化 | ⭐⭐⭐⭐⭐ |
| **Azure Speech** | 语音合成(TTS) | 按量计费 | ⚠️ 需配置 | ⭐⭐⭐⭐ |
| **OpenAI TTS** | 语音合成(TTS) | $0.015/min | 需 VPN | ⭐⭐⭐ |

---

## 🚀 完整批量生产架构建议

```
📁 批量输入目录
├── movie_01.mp4
├── movie_02.mp4
└── ...

↓ NarratoAI 批量处理流水线

1. 视频分析：AI 逐帧理解剧情（多线程并发）
2. 解说生成：DeepSeek/Qwen 生成解说词脚本
3. 语音合成：TTS 引擎批量配音
4. 视频剪辑：自动跳剪 + 字幕烧录
5. 格式转换：FFmpeg 输出 9:16 竖屏 MP4

📁 批量输出目录
├── movie_01_narrated.mp4  → 上传视频号
├── movie_02_narrated.mp4  → 上传博客
└── ...
```

---

## 📋 快速决策指南

| 需求场景 | 推荐工具 | 理由 |
|---------|---------|------|
| 电影/剧集 → 解说切片，注重质量 | **NarratoAI** | 专为影视解说优化，支持声音克隆 |
| 从主题快速批量生产短视频 | **MoneyPrinterTurbo** | 最高 Star，批量能力最强 |
| 专业影视切片，需要角色对白分析 | **GhostCut** | 专注影视切片，功能最专业 |
| 完全自定义，二次开发 | **NarratoAI + DeepSeek API** | 开源可改，国内 API 无需 VPN |

---

## 🔗 资源链接

- [NarratoAI GitHub](https://github.com/linyqh/NarratoAI)
- [MoneyPrinterTurbo GitHub](https://github.com/harry0703/MoneyPrinterTurbo)
- [GhostCut GitHub](https://github.com/JollyToday/Turn_Movie_Clips_to_Narration_Videos)
- [DeepSeek API 文档](https://platform.deepseek.com/api-docs/)
- [通义千问 API 文档](https://help.aliyun.com/zh/dashscope/)
- [腾讯云 TTS 文档](https://cloud.tencent.com/product/tts)
- [OpenAI Whisper GitHub](https://github.com/openai/whisper)
