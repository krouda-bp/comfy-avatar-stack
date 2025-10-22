# ComfyUI Avatar Stack

A production-ready Docker container for generating talking head avatars using ComfyUI with video generation, face animation, and text-to-speech capabilities.

## Features

- **ComfyUI** - Node-based AI workflow framework (v0.3.8)
- **Video Generation** - HunyuanVideo for text-to-video synthesis
- **Face Animation** - LivePortrait for realistic talking head animation
- **Text-to-Speech** - ChatTTS and Parler-TTS for natural speech synthesis
- **GPU Accelerated** - CUDA 12.6 support with PyTorch 2.6.0
- **Persistent Storage** - Network volume support for models and outputs

## Quick Start

### Build the Docker Image

```bash
docker build -t comfy-avatar-stack .
```

### Run the Container

```bash
docker run -d \
  --name comfy-avatar \
  --gpus all \
  -p 8188:8188 \
  -v /path/to/storage:/workspace \
  comfy-avatar-stack
```

### Access ComfyUI

Open your browser and navigate to:
```
http://localhost:8188
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `COMFYUI_PORT` | `8188` | Port for ComfyUI web interface |
| `VOLUME_ROOT` | `/workspace` | Root directory for persistent storage |
| `HF_TOKEN` | - | Hugging Face token for private models |
| `HF_HUB_ENABLE_HF_TRANSFER` | `1` | Enable fast downloads from HF Hub |
| `PRELOAD_HY_AVATAR` | `0` | Preload HunyuanVideo-Avatar models (~50GB) |
| `PRELOAD_XTTS` | `0` | Preload XTTS-v2 voice cloning model |

### Example with Environment Variables

```bash
docker run -d \
  --name comfy-avatar \
  --gpus all \
  -p 8188:8188 \
  -e PRELOAD_HY_AVATAR=1 \
  -e HF_TOKEN=your_hf_token_here \
  -v /path/to/storage:/workspace \
  comfy-avatar-stack
```

## Directory Structure

The container uses `/workspace` (configurable via `VOLUME_ROOT`) for persistent storage:

```
/workspace/
├── models/              # AI model weights
│   ├── liveportrait/   # LivePortrait models
│   ├── tts/            # TTS models
│   └── hunyuanvideo-avatar/
├── outputs/            # Generated videos and images
├── audio/              # Generated audio files
├── avatars/            # Avatar files
└── workflows/          # ComfyUI workflow JSON files
```

## Custom Nodes Included

Custom nodes are installed at their latest stable versions (HEAD):

1. **ComfyUI-Manager** - Package manager for nodes (uses latest tagged release)
2. **ComfyUI-VideoHelperSuite** - Video manipulation utilities
3. **ComfyUI-LivePortraitKJ** - Long-form talking head animation
4. **ComfyUI-HunyuanVideo-Avatar** - Advanced multi-character dialog
5. **ComfyUI-HunyuanVideoWrapper** - Text-to-video variants
6. **ComfyUI-ParlerTTS** - Promptable TTS node

**Note:** For production environments requiring version pinning, modify `scripts/install_nodes.sh` to checkout specific commits or tags after cloning.

## Command-Line TTS Tools

Two CLI tools are included for standalone TTS generation:

### ChatTTS

```bash
docker exec comfy-avatar python /opt/scripts/tts.py \
  --text "Hello, this is a test." \
  --out /workspace/audio/output.wav \
  --seed 42
```

**Options:**
- `--text` - Text to synthesize (required)
- `--out` - Output WAV file path (default: `/workspace/audio/tts.wav`)
- `--style` - Style prompt (default: `[laugh_0][break_6]`)
- `--seed` - Random seed for voice consistency (default: 42)
- `--use-refiner` - Enable text refinement stage

### Parler-TTS

```bash
docker exec comfy-avatar python /opt/scripts/tts_parler.py \
  --text "Hello, this is a test." \
  --desc "A female speaker with a calm and clear voice" \
  --out /workspace/audio/output.wav
```

**Options:**
- `--text` - Text to speak (required)
- `--desc` - Voice description for conditioning (required)
- `--out` - Output WAV file path (default: `/workspace/audio/parler.wav`)
- `--model` - Model ID or path (default: `parler-tts/parler-tts-mini-v1.1`)

## System Requirements

### Minimum

- NVIDIA GPU with 8GB+ VRAM
- 16GB+ system RAM
- 50GB+ storage for models
- CUDA 12.6 compatible GPU

### Recommended

- NVIDIA GPU with 24GB+ VRAM (RTX 3090/4090, A5000, etc.)
- 32GB+ system RAM
- 100GB+ SSD storage
- High-bandwidth internet for model downloads

## Model Downloads

Models are downloaded automatically on first use. To preload models:

1. **Small models** (automatically downloaded):
   - Parler-TTS mini (~1GB)
   - ComfyUI base models

2. **Large models** (optional preload):
   ```bash
   docker run -e PRELOAD_HY_AVATAR=1 -e PRELOAD_XTTS=1 ...
   ```
   - HunyuanVideo-Avatar (~50GB)
   - XTTS-v2 (~2GB)

## Troubleshooting

### Out of Memory Errors

If you encounter CUDA OOM errors:
1. Reduce batch sizes in workflows
2. Use `--use-split-cross-attention` (already enabled)
3. Close other GPU applications

### Model Download Failures

If models fail to download:
1. Check internet connection
2. Set `HF_TOKEN` for private models
3. Manually download to `/workspace/models/`

### Container Won't Start

Check logs:
```bash
docker logs comfy-avatar
```

Common issues:
- No GPU available: Add `--gpus all` flag
- Port already in use: Change `-p 8189:8188`
- Volume permission issues: Check `/workspace` permissions

## Development

### Building from Source

```bash
git clone https://github.com/your-repo/comfy-avatar-stack.git
cd comfy-avatar-stack
docker build -t comfy-avatar-stack:dev .
```

### Running Scripts Locally

Scripts are located in `scripts/`:
- `bootstrap.sh` - Container entrypoint
- `start_comfy.sh` - ComfyUI launcher
- `install_nodes.sh` - Custom node installer
- `preload_models.sh` - Model downloader
- `tts.py` - ChatTTS CLI
- `tts_parler.py` - Parler-TTS CLI

## CI/CD

The project includes GitHub Actions workflow for automated builds:
- Triggers on push to `main` branch
- Builds and pushes to GitHub Container Registry
- Tags: `latest` and `YYYYMMDD-SHA`

## Health Checks

The container includes a health check that monitors ComfyUI availability:
- Interval: 30 seconds
- Timeout: 10 seconds
- Start period: 60 seconds
- Retries: 3

Check health status:
```bash
docker inspect --format='{{.State.Health.Status}}' comfy-avatar
```

## License

This project bundles multiple open-source components, each with their own licenses:
- ComfyUI: GPL-3.0
- PyTorch: BSD-style
- ChatTTS: Apache-2.0
- Parler-TTS: Apache-2.0

See individual component repositories for specific license details.

## Credits

Built with:
- [ComfyUI](https://github.com/comfyanonymous/ComfyUI)
- [LivePortrait](https://github.com/kijai/ComfyUI-LivePortraitKJ)
- [HunyuanVideo](https://github.com/Tencent/HunyuanVideo)
- [ChatTTS](https://github.com/2noise/ChatTTS)
- [Parler-TTS](https://github.com/huggingface/parler-tts)

## Support

For issues and questions:
- Check the troubleshooting section above
- Review Docker logs: `docker logs comfy-avatar`
- Open an issue on GitHub
