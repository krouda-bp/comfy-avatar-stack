#!/usr/bin/env python3
import argparse
import os
import random
import sys

import ChatTTS
import numpy as np
import soundfile as sf
import torch


def main():
    parser = argparse.ArgumentParser(description="Simple ChatTTS CLI")
    parser.add_argument("--text", required=True, help="Text to synthesize.")
    parser.add_argument("--out", default="/workspace/audio/tts.wav", help="Output WAV path.")
    parser.add_argument("--style", default="[laugh_0][break_6]", help="Style prompt for the refiner.")
    parser.add_argument("--seed", type=int, default=42, help="Random seed for reproducible voices.")
    parser.add_argument(
        "--use-refiner",
        action="store_true",
        help="Enable the text refiner stage (can fail on unusual punctuation).",
    )
    args = parser.parse_args()

    # Check GPU availability
    if not torch.cuda.is_available():
        print("WARNING: CUDA not available, running on CPU (will be slow)")

    # Basic clean-up to avoid known tokenizer issues with hyphen characters.
    clean_text = args.text.replace("-", " ")

    random.seed(args.seed)
    np.random.seed(args.seed)
    torch.manual_seed(args.seed)

    try:
        print("Loading ChatTTS model...")
        chat = ChatTTS.Chat()
        chat.load(compile=False)
        print("Model loaded successfully")
    except Exception as e:
        print(f"ERROR: Failed to load ChatTTS model: {e}", file=sys.stderr)
        sys.exit(1)

    try:
        spk = chat.sample_random_speaker()
        params_infer_code = ChatTTS.Chat.InferCodeParams(spk_emb=spk)
        params_refine_text = ChatTTS.Chat.RefineTextParams(prompt=args.style)

        print("Generating speech...")
        wavs = chat.infer(
            clean_text,
            use_decoder=True,
            skip_refine_text=not args.use_refiner,
            params_refine_text=params_refine_text,
            params_infer_code=params_infer_code,
        )
    except Exception as e:
        print(f"ERROR: Speech generation failed: {e}", file=sys.stderr)
        sys.exit(1)

    try:
        audio = wavs[0]
        if isinstance(audio, torch.Tensor):
            audio = audio.detach().cpu().numpy()
        audio = np.asarray(audio, dtype=np.float32).squeeze()

        os.makedirs(os.path.dirname(args.out), exist_ok=True)
        sf.write(args.out, audio, 24000)
        print(f"Successfully wrote {args.out}")
    except Exception as e:
        print(f"ERROR: Failed to write audio file: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
