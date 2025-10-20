#!/usr/bin/env bash
set -euo pipefail
VOLUME_ROOT=${VOLUME_ROOT:-/workspace}
MODEL_DIR="$VOLUME_ROOT/models"
mkdir -p "$MODEL_DIR/tts" "$MODEL_DIR/liveportrait" "$MODEL_DIR/hunyuanvideo-avatar"


export HF_TOKEN="${HF_TOKEN:-}"
if [[ -n "$HF_TOKEN" ]]; then
huggingface-cli login --token "$HF_TOKEN" --add-to-git-credential || true
fi


# Parler‑TTS mini v1.1 (promptable, good quality)
mkdir -p "$MODEL_DIR/tts/parler-tts-mini-v1.1"
huggingface-cli download parler-tts/parler-tts-mini-v1.1 --local-dir "$MODEL_DIR/tts/parler-tts-mini-v1.1" --resume-download --quiet || true


# (Optional) XTTS‑v2 (voice cloning from 6s sample)
if [[ "${PRELOAD_XTTS:-0}" == "1" ]]; then
mkdir -p "$MODEL_DIR/tts/xtts-v2"
huggingface-cli download coqui/XTTS-v2 --local-dir "$MODEL_DIR/tts/xtts-v2" --resume-download --quiet || true
fi


# LivePortrait weights auto-download at first run to /workspace/models/liveportrait


# HunyuanVideo‑Avatar (large). Skipped unless PRELOAD_HY_AVATAR=1
if [[ "${PRELOAD_HY_AVATAR:-0}" == "1" ]]; then
mkdir -p "$MODEL_DIR/hunyuanvideo-avatar"
huggingface-cli download tencent/HunyuanVideo-Avatar --local-dir "$MODEL_DIR/hunyuanvideo-avatar" --resume-download --quiet || true
fi
