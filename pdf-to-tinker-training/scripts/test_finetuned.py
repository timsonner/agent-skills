#!/usr/bin/env python3
"""Sample from fine-tuned Inkling checkpoint. Zero-Binary."""
import sys
import os
import argparse

# Inject the mock tokenizer workaround first
from mock_tokenizer import mock_tml_tokenizers
mock_tml_tokenizers()

import tinker
from tinker import types
from transformers import AutoTokenizer

# Preserved prints from original skeleton:
print("Executable:", sys.executable)
print("Usage: after save_weights_and_get_sampling_client('checkpoint-1'),")
print("call sample_async(prompt=tokenized_input, sampling_params=SamplingParams(...))")
print("Checkpoint: checkpoint-1 (from save_weights_and_get_sampling_client)")
print("Ready to sample fine-tuned Inkling model.")

def test(args):
    # Ensure TINKER_API_KEY is configured
    if "TINKER_API_KEY" not in os.environ:
        os.environ["TINKER_API_KEY"] = "<YOUR_TINKER_API_KEY>"
        
    print(f"Initializing ServiceClient ...")
    sc = tinker.ServiceClient()
    
    if args.checkpoint:
        print(f"Creating SamplingClient for checkpoint: {args.checkpoint}")
        sampling_client = sc.create_sampling_client(model_path=args.checkpoint)
    else:
        print(f"Creating SamplingClient for base model: {args.model}")
        sampling_client = sc.create_sampling_client(base_model=args.model)
        
    print("Loading tokenizer ...")
    tokenizer = sampling_client.get_tokenizer()
    
    # Format prompt
    print(f"Formatting prompt: '{args.prompt}'")
    messages = [{"role": "user", "content": args.prompt}]
    p = tokenizer.apply_chat_template(messages, tokenize=True, add_generation_prompt=True)
    p_ids = p["input_ids"] if isinstance(p, dict) or hasattr(p, "keys") else p
    
    print("Sampling from model ...")
    sampling_params = types.SamplingParams(
        max_tokens=args.max_tokens,
        temperature=args.temperature
    )
    
    res = sampling_client.sample(
        prompt=types.ModelInput.from_ints(p_ids),
        num_samples=args.num_samples,
        sampling_params=sampling_params
    ).result()
    
    print("\nGenerated outputs:")
    for idx, seq in enumerate(res.sequences):
        decoded = tokenizer.decode(seq.tokens)
        print(f"\n--- Output {idx+1} (Stop reason: {seq.stop_reason}) ---")
        print(decoded)

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--checkpoint", help="Tinker path to saved weights (e.g. checkpoint-1)")
    p.add_argument("--model", default="thinkingmachines/Inkling", help="Base model ID")
    p.add_argument("--prompt", default="What is a penetration test?", help="Input prompt")
    p.add_argument("--num_samples", type=int, default=1, help="Number of samples to generate")
    p.add_argument("--max_tokens", type=int, default=50, help="Max tokens to generate")
    p.add_argument("--temperature", type=float, default=0.7, help="Sampling temperature")
    args = p.parse_args()
    
    test(args)

if __name__ == "__main__":
    main()
