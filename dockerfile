# syntax=docker/dockerfile:1.7
FROM pytorch/pytorch:2.6.0-cuda12.6-cudnn9-runtime


ENV DEBIAN_FRONTEND=noninteractive \
PIP_NO_CACHE_DIR=1 \
UV_FAST_INSTALL=1 \
COMFYUI_DIR=/opt/ComfyUI \
SCRIPTS_DIR=/opt/scripts \
WORKFLOWS_DIR=/opt/workflows \
VOLUME_ROOT=/workspace \
COMFYUI_PORT=8188


# Core OS deps
RUN apt-get update && apt-get install -y --no-install-recommends \
git wget curl aria2 ffmpeg tini ca-certificates \
libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 \
jq && \
rm -rf /var/lib/apt/lists/*


# Python deps (pin stable versions known-good on torch 2.6/cu12.6)
RUN pip install --upgrade pip setuptools wheel && \
pip install --no-deps --upgrade \
huggingface_hub==0.25.2 \
hf-transfer==0.1.6 \
xformers==0.0.29.post2 \
soundfile==0.12.1 \
librosa==0.10.2.post1 \
einops==0.8.0 \
opencv-python-headless==4.10.0.84 \
ChatTTS==0.2.4 \
TTS==0.22.0


# ComfyUI v0.3.65 (tag 51696e3)
RUN git clone https://github.com/comfyanonymous/ComfyUI.git ${COMFYUI_DIR} && \
cd ${COMFYUI_DIR} && \
git checkout 51696e3 && \
pip install -r requirements.txt


# Scripts & config
COPY scripts ${SCRIPTS_DIR}
RUN chmod +x ${SCRIPTS_DIR}/*.sh


# Pre-create directories
RUN mkdir -p ${WORKFLOWS_DIR} ${VOLUME_ROOT}/models ${VOLUME_ROOT}/outputs ${VOLUME_ROOT}/audio ${VOLUME_ROOT}/avatars ${VOLUME_ROOT}/workflows


# Custom nodes installed at runtime by bootstrap.sh (keeps image small)


EXPOSE 8188
ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["/opt/scripts/bootstrap.sh"]
