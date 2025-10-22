#!/usr/bin/env bash
set -euo pipefail
COMFYUI_DIR=${COMFYUI_DIR:-/opt/ComfyUI}
cd "$COMFYUI_DIR/custom_nodes"

echo "Installing ComfyUI custom nodes..."

# NOTE: Nodes are installed at HEAD (latest) for compatibility with ComfyUI v0.3.8
# For production, consider pinning specific versions after testing
# To pin a specific version, add: cd <node_dir> && git checkout <commit/tag> && cd ..

# 1) ComfyUI-Manager (official org) - has tagged releases
if [[ ! -d ComfyUI-Manager ]]; then
  echo "Installing ComfyUI-Manager..."
  git clone https://github.com/Comfy-Org/ComfyUI-Manager.git
  cd ComfyUI-Manager
  # Try to checkout latest stable tag, fallback to HEAD if fails
  LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
  if [[ -n "$LATEST_TAG" ]]; then
    echo "Using tag: $LATEST_TAG"
    git checkout "$LATEST_TAG" || echo "WARNING: Could not checkout tag, using HEAD"
  fi
  cd ..
else
  echo "ComfyUI-Manager already installed"
fi

# 2) VideoHelperSuite - using HEAD (stable, well-maintained)
if [[ ! -d ComfyUI-VideoHelperSuite ]]; then
  echo "Installing ComfyUI-VideoHelperSuite..."
  git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
else
  echo "ComfyUI-VideoHelperSuite already installed"
fi

# 3) LivePortraitKJ (long-form reliable talking head) - using HEAD
if [[ ! -d ComfyUI-LivePortraitKJ ]]; then
  echo "Installing ComfyUI-LivePortraitKJ..."
  git clone https://github.com/kijai/ComfyUI-LivePortraitKJ.git
  if [[ -f ComfyUI-LivePortraitKJ/requirements.txt ]]; then
    echo "Installing LivePortraitKJ requirements..."
    pip install -r ComfyUI-LivePortraitKJ/requirements.txt
  fi
else
  echo "ComfyUI-LivePortraitKJ already installed"
fi

# 4) HunyuanVideo-Avatar (advanced dialog/emotion/multi-char) - using HEAD
if [[ ! -d ComfyUI-HunyuanVideo-Avatar ]]; then
  echo "Installing ComfyUI-HunyuanVideo-Avatar..."
  git clone https://github.com/Yuan-ManX/ComfyUI-HunyuanVideo-Avatar.git
  if [[ -f ComfyUI-HunyuanVideo-Avatar/requirements.txt ]]; then
    echo "Installing HunyuanVideo-Avatar requirements..."
    pip install -r ComfyUI-HunyuanVideo-Avatar/requirements.txt
  fi
else
  echo "ComfyUI-HunyuanVideo-Avatar already installed"
fi

# 5) HunyuanVideo wrapper for T2V/I2V variants - using HEAD
if [[ ! -d ComfyUI-HunyuanVideoWrapper ]]; then
  echo "Installing ComfyUI-HunyuanVideoWrapper..."
  git clone https://github.com/kijai/ComfyUI-HunyuanVideoWrapper.git
else
  echo "ComfyUI-HunyuanVideoWrapper already installed"
fi

# 6) Parler-TTS node (promptable TTS) - using HEAD
if [[ ! -d ComfyUI-ParlerTTS ]]; then
  echo "Installing ComfyUI-ParlerTTS..."
  git clone https://github.com/smthemex/ComfyUI-ParlerTTS.git
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
