# syntax=docker/dockerfile:1.7
FROM pytorch/pytorch:2.6.0-cuda12.6-cudnn9-runtime

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    COMFYUI_DIR=/opt/ComfyUI \
    SCRIPTS_DIR=/opt/scripts \
    VOLUME_ROOT=/workspace \
    COMFYUI_PORT=8188 \
    TINI_SUBREAPER=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget curl aria2 ffmpeg tini ca-certificates \
    libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 jq \
  && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip setuptools wheel && \
    pip install --no-deps --upgrade \
      huggingface_hub==0.25.2 \
      hf-transfer==0.1.6 \
      xformers==0.0.29.post2 \
      soundfile==0.12.1 \
      librosa==0.10.2.post1 \
      einops==0.8.0 \
      opencv-python-headless==4.10.0.84 \
      ChatTTS==0.2.4 \
      TTS==0.22.0 \
      fastapi uvicorn

# ComfyUI pinned tag
RUN git clone https://github.com/comfyanonymous/ComfyUI.git ${COMFYUI_DIR} && \
    cd ${COMFYUI_DIR} && git checkout 51696e3 && \
    pip install -r requirements.txt

# Custom nodes (BAKED IN; no runtime cloning)
RUN set -eux; cd ${COMFYUI_DIR}/custom_nodes; \
    git clone https://github.com/Comfy-Org/ComfyUI-Manager.git && \
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
    git clone https://github.com/kijai/ComfyUI-LivePortraitKJ.git && \
    pip install -r ComfyUI-LivePortraitKJ/requirements.txt || true

# Scripts & config
COPY scripts ${SCRIPTS_DIR}
# Normalize Windows line-endings + make executable
RUN sed -i 's/\r$//' ${SCRIPTS_DIR}/*.sh && chmod +x ${SCRIPTS_DIR}/*.sh

# Small CLI for TTS via ChatTTS (no Parler node needed for first run)
COPY scripts/tts.py /opt/scripts/tts.py

EXPOSE 8188
ENTRYPOINT ["/usr/bin/tini","-s","--"]
CMD ["bash","/opt/scripts/bootstrap.sh"]
