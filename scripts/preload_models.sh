#!/usr/bin/env bash
set -euo pipefail
VOLUME_ROOT=${VOLUME_ROOT:-/workspace}
MODEL_DIR="$VOLUME_ROOT/models"
mkdir -p "$MODEL_DIR/tts" "$MODEL_DIR/liveportrait" "$MODEL_DIR/hunyuanvideo-avatar"


export HF_TOKEN="${HF_TOKEN:-}"
if [[ -n "$HF_TOKEN" ]]; then
  echo "Logging in to Hugging Face Hub..."
  if ! huggingface-cli login --token "$HF_TOKEN" --add-to-git-credential; then
    echo "WARNING: HF login failed, proceeding with public models only"
  fi
fi

# Parler‑TTS mini v1.1 (promptable, good quality)
echo "Downloading Parler-TTS mini v1.1..."
mkdir -p "$MODEL_DIR/tts/parler-tts-mini-v1.1"
if ! huggingface-cli download parler-tts/parler-tts-mini-v1.1 --local-dir "$MODEL_DIR/tts/parler-tts-mini-v1.1" --resume-download --quiet; then
  echo "WARNING: Failed to download Parler-TTS, will download on first use"
fi

# (Optional) XTTS‑v2 (voice cloning from 6s sample)
if [[ "${PRELOAD_XTTS:-0}" == "1" ]]; then
  echo "Downloading XTTS-v2..."
  mkdir -p "$MODEL_DIR/tts/xtts-v2"
  if ! huggingface-cli download coqui/XTTS-v2 --local-dir "$MODEL_DIR/tts/xtts-v2" --resume-download --quiet; then
    echo "WARNING: Failed to download XTTS-v2, will download on first use"
  fi
fi

# LivePortrait weights auto-download at first run to /workspace/models/liveportrait
echo "LivePortrait models will be downloaded on first use"

# HunyuanVideo‑Avatar (large ~50GB). Skipped unless PRELOAD_HY_AVATAR=1
if [[ "${PRELOAD_HY_AVATAR:-0}" == "1" ]]; then
  echo "Downloading HunyuanVideo-Avatar (this may take a while, ~50GB)..."
  mkdir -p "$MODEL_DIR/hunyuanvideo-avatar"
  if ! huggingface-cli download tencent/HunyuanVideo-Avatar --local-dir "$MODEL_DIR/hunyuanvideo-avatar" --resume-download --quiet; then
    echo "WARNING: Failed to download HunyuanVideo-Avatar, will download on first use"
  fi
fi

echo "Model preload complete"
