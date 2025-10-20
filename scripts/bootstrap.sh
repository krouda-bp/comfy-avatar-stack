#!/usr/bin/env bash
set -euo pipefail


COMFYUI_DIR=${COMFYUI_DIR:-/opt/ComfyUI}
SCRIPTS_DIR=${SCRIPTS_DIR:-/opt/scripts}
WORKFLOWS_DIR=${WORKFLOWS_DIR:-/opt/workflows}
VOLUME_ROOT=${VOLUME_ROOT:-/workspace}
PORT=${COMFYUI_PORT:-8188}


mkdir -p "$VOLUME_ROOT/models" "$VOLUME_ROOT/outputs" "$VOLUME_ROOT/audio" "$VOLUME_ROOT/avatars" "$VOLUME_ROOT/workflows"


# Configure ComfyUI to use the network volume for models
cat > "$COMFYUI_DIR/extra_model_paths.yaml" <<'YAML'
# Auto-generated: map model types to /workspace
# See updated docs: extra_model_paths.yaml.example


comfyui:
base_path: /workspace/models


# Explicit path overrides for common types
clip:
- /workspace/models/text_encoders
controlnet:
- /workspace/models/controlnet
diffusers:
- /workspace/models/diffusers
loras:
- /workspace/models/loras
upscale_models:
- /workspace/models/upscale
vae:
- /workspace/models/vae
animatediff_motion_lora:
- /workspace/models/animatediff_motion_lora
liveportrait:
- /workspace/models/liveportrait
hunyuanvideo_avatar:
- /workspace/models/hunyuanvideo-avatar
YAML


# Install custom nodes
bash "$SCRIPTS_DIR/install_nodes.sh"


# Optional: preload models (controlled by env)
: "${PRELOAD_HY_AVATAR:=0}"
HF_TOKEN="${HF_TOKEN:-}"
if [[ "$PRELOAD_HY_AVATAR" == "1" ]]; then
HF_TOKEN="$HF_TOKEN" bash "$SCRIPTS_DIR/preload_models.sh" || echo "[WARN] Model preload encountered issues; you can still run and download via UI."
fi


# Copy example workflows (LivePortrait provides examples)
LP_EXAMPLES="$COMFYUI_DIR/custom_nodes/ComfyUI-LivePortraitKJ/examples"
if [[ -d "$LP_EXAMPLES" ]]; then
mkdir -p "$VOLUME_ROOT/workflows/liveportrait"
cp -rn "$LP_EXAMPLES"/* "$VOLUME_ROOT/workflows/liveportrait/" || true
fi


# Start ComfyUI
exec bash "$SCRIPTS_DIR/start_comfy.sh" "$PORT"
