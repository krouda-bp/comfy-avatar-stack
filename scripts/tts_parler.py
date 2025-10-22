#!/usr/bin/env python3
"""
Lightweight Parler-TTS CLI for generating speech when ChatTTS is unavailable.
"""
import argparse
import os
import sys

import soundfile as sf
import torch
from parler_tts import ParlerTTSForConditionalGeneration
from transformers import AutoTokenizer


def main():
    parser = argparse.ArgumentParser(description="Generate speech with Parler-TTS.")
    parser.add_argument("--text", required=True, help="Prompt text to speak.")
    parser.add_argument(
        "--desc",
        required=True,
        help="Voice description (tone, accent, delivery) to condition generation.",
    )
    parser.add_argument(
        "--out",
        default="/workspace/audio/parler.wav",
        help="Output WAV path.",
    )
    parser.add_argument(
        "--model",
        default="parler-tts/parler-tts-mini-v1.1",
        help="Model ID to load from Hugging Face Hub or a local path.",
    )
    args = parser.parse_args()

    device = "cuda" if torch.cuda.is_available() else "cpu"
    if device == "cpu":
        print("WARNING: CUDA not available, running on CPU (will be slow)")
    else:
        print(f"Using device: {device}")

    try:
        print(f"Loading Parler-TTS model from {args.model}...")
        model = ParlerTTSForConditionalGeneration.from_pretrained(args.model).to(device)
        tokenizer = AutoTokenizer.from_pretrained(args.model)
        print("Model loaded successfully")
    except Exception as e:
        print(f"ERROR: Failed to load model: {e}", file=sys.stderr)
        sys.exit(1)

    try:
        print("Generating speech...")
        desc_ids = tokenizer(args.desc, return_tensors="pt").input_ids.to(device)
        prompt_ids = tokenizer(args.text, return_tensors="pt").input_ids.to(device)
        wav = model.generate(input_ids=desc_ids, prompt_input_ids=prompt_ids)
    except Exception as e:
        print(f"ERROR: Speech generation failed: {e}", file=sys.stderr)
        sys.exit(1)

    try:
        audio = wav.cpu().numpy().squeeze()
        os.makedirs(os.path.dirname(args.out), exist_ok=True)
        sf.write(args.out, audio, model.config.sampling_rate)
        print(f"Successfully wrote {args.out}")
    except Exception as e:
        print(f"ERROR: Failed to write audio file: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
