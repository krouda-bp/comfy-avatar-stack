#!/usr/bin/env bash
set -euo pipefail
PORT="${1:-8188}"
cd "${COMFYUI_DIR:-/opt/ComfyUI}"
python main.py --listen 0.0.0.0 --port "$PORT" --use-split-cross-attention
