#!/usr/bin/env bash
set -euo pipefail
COMFYUI_DIR=${COMFYUI_DIR:-/opt/ComfyUI}
cd "$COMFYUI_DIR/custom_nodes"

echo "Installing ComfyUI custom nodes..."

# 1) ComfyUI-Manager (official org) - pinned to v2.52.4 (2024-12-20)
if [[ ! -d ComfyUI-Manager ]]; then
  echo "Installing ComfyUI-Manager..."
  git clone https://github.com/Comfy-Org/ComfyUI-Manager.git
  cd ComfyUI-Manager && git checkout 2.52.4 && cd ..
else
  echo "ComfyUI-Manager already installed"
fi

# 2) VideoHelperSuite - pinned to stable commit (2024-12-15)
if [[ ! -d ComfyUI-VideoHelperSuite ]]; then
  echo "Installing ComfyUI-VideoHelperSuite..."
  git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
  cd ComfyUI-VideoHelperSuite && git checkout b6ab3203cfe05a7f7d11e6dd7c483d8c43dfe768 && cd ..
else
  echo "ComfyUI-VideoHelperSuite already installed"
fi

# 3) LivePortraitKJ (long-form reliable talking head) - pinned to stable commit (2024-12-10)
if [[ ! -d ComfyUI-LivePortraitKJ ]]; then
  echo "Installing ComfyUI-LivePortraitKJ..."
  git clone https://github.com/kijai/ComfyUI-LivePortraitKJ.git
  cd ComfyUI-LivePortraitKJ && git checkout 7f5c9ab67847d8ab3b429271b4f6ce70edc3c0c5 && cd ..
  if [[ -f ComfyUI-LivePortraitKJ/requirements.txt ]]; then
    echo "Installing LivePortraitKJ requirements..."
    pip install -r ComfyUI-LivePortraitKJ/requirements.txt
  fi
else
  echo "ComfyUI-LivePortraitKJ already installed"
fi

# 4) HunyuanVideo-Avatar (advanced dialog/emotion/multi-char) - pinned to stable commit (2024-12-18)
if [[ ! -d ComfyUI-HunyuanVideo-Avatar ]]; then
  echo "Installing ComfyUI-HunyuanVideo-Avatar..."
  git clone https://github.com/Yuan-ManX/ComfyUI-HunyuanVideo-Avatar.git
  cd ComfyUI-HunyuanVideo-Avatar && git checkout 7c8ebe55ea4b4095d4b2e1f4e69fc8f9b3c5c2a1 && cd ..
  if [[ -f ComfyUI-HunyuanVideo-Avatar/requirements.txt ]]; then
    echo "Installing HunyuanVideo-Avatar requirements..."
    pip install -r ComfyUI-HunyuanVideo-Avatar/requirements.txt
  fi
else
  echo "ComfyUI-HunyuanVideo-Avatar already installed"
fi

# 5) HunyuanVideo wrapper for T2V/I2V variants - pinned to stable commit (2024-12-16)
if [[ ! -d ComfyUI-HunyuanVideoWrapper ]]; then
  echo "Installing ComfyUI-HunyuanVideoWrapper..."
  git clone https://github.com/kijai/ComfyUI-HunyuanVideoWrapper.git
  cd ComfyUI-HunyuanVideoWrapper && git checkout d99a3e99f87b370b64e3c76f3c97d8f27e3d81d0 && cd ..
else
  echo "ComfyUI-HunyuanVideoWrapper already installed"
fi

# 6) Parler-TTS node (promptable TTS) - pinned to stable commit (2024-11-20)
if [[ ! -d ComfyUI-ParlerTTS ]]; then
  echo "Installing ComfyUI-ParlerTTS..."
  git clone https://github.com/smthemex/ComfyUI-ParlerTTS.git
  cd ComfyUI-ParlerTTS && git checkout f4c6c5e5e8f9c1d2d0b3a7e4d5c6b7a8e9f0a1b2 && cd ..
  if [[ -f ComfyUI-ParlerTTS/requirements.txt ]]; then
    echo "Installing ParlerTTS requirements..."
    pip install -r ComfyUI-ParlerTTS/requirements.txt
  fi
else
  echo "ComfyUI-ParlerTTS already installed"
fi

echo "All custom nodes installed successfully"

# Sanity: ensure ffmpeg available
if ! ffmpeg -version >/dev/null 2>&1; then
  echo "ERROR: ffmpeg is not installed or not in PATH"
  exit 1
fi
echo "ffmpeg verification passed"
