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
    git wget curl aria2 ffmpeg tini ca-certificates jq \
    libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 \
    libsndfile1 \
  && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip setuptools wheel && \
    pip install --upgrade --extra-index-url https://download.pytorch.org/whl/cu126 \
      torch==2.6.0+cu126 \
      torchaudio==2.6.0+cu126 && \
    pip install --upgrade \
      huggingface_hub==0.25.2 \
      hf-transfer==0.1.6 \
      xformers==0.0.29.post2 \
      einops==0.8.0 \
      opencv-python-headless==4.10.0.84 \
      soundfile==0.12.1 \
      librosa==0.10.2.post1 \
      audioread==3.0.1 \
      joblib==1.4.2 \
      msgpack==1.1.0 \
      pooch==1.8.2 \
      scikit-learn==1.6.0 \
      soxr==0.5.0.post1 \
      ChatTTS==0.2.4 \
      vocos==0.1.0 \
      pybase16384==0.1.7 \
      vector-quantize-pytorch==1.18.7 \
      numba==0.62.1 \
      llvmlite==0.45.1 \
      TTS==0.22.0 \
      sentencepiece==0.2.0 \
      safetensors==0.5.1 \
      "git+https://github.com/huggingface/parler-tts.git@cb208f64063238fd6aa8ac8bdc06ce1a8e64d4f3"

# ComfyUI - pinned to commit 51696e3 (v0.3.8, 2024-12-12)
# This version is stable and tested with the custom nodes below
RUN git clone https://github.com/comfyanonymous/ComfyUI.git ${COMFYUI_DIR} && \
    cd ${COMFYUI_DIR} && git checkout 51696e3 && \
    pip install -r requirements.txt

# Scripts & config
COPY scripts ${SCRIPTS_DIR}
# Normalize Windows line-endings + make executable
RUN sed -i 's/\r$//' ${SCRIPTS_DIR}/*.sh && chmod +x ${SCRIPTS_DIR}/*.sh

# Install custom nodes (baked into image for faster startup)
RUN bash ${SCRIPTS_DIR}/install_nodes.sh

EXPOSE 8188

# Health check to ensure ComfyUI is responding
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8188/ || exit 1

ENTRYPOINT ["/usr/bin/tini","-s","--"]
CMD ["bash","/opt/scripts/bootstrap.sh"]
