#!/usr/bin/env bash
set -euo pipefail

COMFYUI_DIR=${COMFYUI_DIR:-/opt/ComfyUI}
VOLUME_ROOT=${VOLUME_ROOT:-/workspace}
PORT=${COMFYUI_PORT:-8188}

# Ensure persistent dirs on your Network Volume
mkdir -p "$VOLUME_ROOT/models" "$VOLUME_ROOT/outputs" "$VOLUME_ROOT/audio" "$VOLUME_ROOT/avatars" "$VOLUME_ROOT/workflows"

# Point ComfyUI to use the Network Volume for models
cat > "$COMFYUI_DIR/extra_model_paths.yaml" <<'YAML'
comfyui:
  base_path: /workspace/models
liveportrait:
  - /workspace/models/liveportrait
upscale_models:
  - /workspace/models/upscale
animatediff_motion_lora:
  - /workspace/models/animatediff_motion_lora
YAML

# Optional model preload (harmless if already present)
: "${HF_HUB_ENABLE_HF_TRANSFER:=1}"
: "${PRELOAD_HY_AVATAR:=0}"
if [[ "$PRELOAD_HY_AVATAR" == "1" ]]; then
  bash /opt/scripts/preload_models.sh || true
fi

# Start ComfyUI (listen on 0.0.0.0:PORT)
exec bash /opt/scripts/start_comfy.sh "$PORT"
