## Hi there 👋

## AI 自动生成爆款视频 🎬

一款 AI 驱动的自动化爆款短视频生成软件，整合 Claude、GPT、MiniMax、Ollama (Qwen) 和海螺视频生成，实现从选题策划到视频成片的全流程自动化。

### 功能特点

- 🧠 **多 LLM 支持**：Claude / GPT / Ollama (Qwen 3.6) 自动降级
- 🎨 **AI 图片生成**：MiniMax 2.7 文生图
- 🎥 **视频生成**：海螺视频网页自动化（图生视频）
- ✂️ **自动合成**：FFmpeg 拼接 + 字幕 + 配音
- 📱 **多平台适配**：抖音 / 快手 / B站 / 小红书

### 快速开始

```bash
# 安装依赖
pip install -r requirements.txt

# 复制配置文件并填入 API 密钥
cp config.example.yaml config.yaml

# 运行
python -m ai_video_generator "AI科技" --platform douyin
```

### 架构

详见 [ARCHITECTURE.md](ARCHITECTURE.md)

<!--
**yihui315/yihui315** is a ✨ _special_ ✨ repository because its `README.md` (this file) appears on your GitHub profile.
-->
