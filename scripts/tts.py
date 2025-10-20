#!/usr/bin/env python3
import argparse, os, sys
from ChatTTS import ChatTTS
import soundfile as sf

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--text", required=True)
    ap.add_argument("--out", default="/workspace/audio/tts.wav")
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--speed", type=float, default=1.0)
    ap.add_argument("--style", default="[laugh_0][break_6]")
    args = ap.parse_args()

    tts = ChatTTS.Chat()
    tts.load(compile=False)
    spk = tts.sample_random_speaker(seed=args.seed)
    wavs = tts.infer(
        [args.text],
        spks=[spk],
        params_infer_code={"prompt": args.style},
        params_refine_text={"prompt": ""}
    )
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    sf.write(args.out, wavs[0], 24000)
    print(f"Wrote {args.out}")

if __name__ == "__main__":
    sys.exit(main())
