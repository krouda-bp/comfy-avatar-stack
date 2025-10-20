#!/usr/bin/env bash
set -euo pipefail
COMFYUI_DIR=${COMFYUI_DIR:-/opt/ComfyUI}
cd "$COMFYUI_DIR/custom_nodes"


# 1) ComfyUI-Manager (official org)
if [[ ! -d ComfyUI-Manager ]]; then
git clone https://github.com/Comfy-Org/ComfyUI-Manager.git
fi


# 2) VideoHelperSuite
if [[ ! -d ComfyUI-VideoHelperSuite ]]; then
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
fi


# 3) LivePortraitKJ (long-form reliable talking head)
if [[ ! -d ComfyUI-LivePortraitKJ ]]; then
git clone https://github.com/kijai/ComfyUI-LivePortraitKJ.git
pip install -r ComfyUI-LivePortraitKJ/requirements.txt || true
fi


# 4) HunyuanVideo-Avatar (advanced dialog/emotion/multi-char) — optional heavy
if [[ ! -d ComfyUI-HunyuanVideo-Avatar ]]; then
git clone https://github.com/Yuan-ManX/ComfyUI-HunyuanVideo-Avatar.git
pip install -r ComfyUI-HunyuanVideo-Avatar/requirements.txt || true
fi


# (Optional) HunyuanVideo wrapper for T2V/I2V variants
if [[ ! -d ComfyUI-HunyuanVideoWrapper ]]; then
git clone https://github.com/kijai/ComfyUI-HunyuanVideoWrapper.git
fi


# 5) Parler-TTS node (promptable TTS)
if [[ ! -d ComfyUI-ParlerTTS ]]; then
git clone https://github.com/smthemex/ComfyUI-ParlerTTS.git
pip install -r ComfyUI-ParlerTTS/requirements.txt || true
fi


# (Optional) ChatTTS used via python directly (already installed via pip)


# Sanity: ensure ffmpeg available
ffmpeg -version >/dev/null 2>&1 || { echo "ffmpeg missing"; exit 1; }
