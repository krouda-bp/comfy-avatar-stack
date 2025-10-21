#!/usr/bin/env python3
"""
Lightweight Parler-TTS CLI for generating speech when ChatTTS is unavailable.
"""
import argparse
import os

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
    model = ParlerTTSForConditionalGeneration.from_pretrained(args.model).to(device)
    tokenizer = AutoTokenizer.from_pretrained(args.model)

    desc_ids = tokenizer(args.desc, return_tensors="pt").input_ids.to(device)
    prompt_ids = tokenizer(args.text, return_tensors="pt").input_ids.to(device)
    wav = model.generate(input_ids=desc_ids, prompt_input_ids=prompt_ids)

    audio = wav.cpu().numpy().squeeze()
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    sf.write(args.out, audio, model.config.sampling_rate)
    print(f"Wrote {args.out}")


if __name__ == "__main__":
    main()
