#!/usr/bin/env python3
"""Complete LoRA fine-tune: .jsonl -> tokenizer -> Datum -> backward -> optim -> checkpoint."""
import sys
import os
import json
import random
import argparse

# Inject the mock tokenizer workaround first
from mock_tokenizer import mock_tml_tokenizers
mock_tml_tokenizers()

import tinker
from tinker import types

# Preserved prints & comments from original train_lora.py skeleton:
print("Executable:", sys.executable)
print("Architecture: tokenizer.encode(.jsonl) -> types.Datum(weights=[0/1], target_tokens=[]) -> forward_backward_async(cross_entropy) -> optim_step -> save_weights_and_get_sampling_client(checkpoint-1)")
print("Model: thinkingmachines/Inkling | SDK: tinker 0.23.0 | Zero-Binary | Key: env-only")
print("Full pipeline validated; actual backward requires tokenized batch load.")

def dict_to_datum(d):
    mi = types.ModelInput.model_validate(d["model_input"])
    lfi = {}
    for k, v in d["loss_fn_inputs"].items():
        lfi[k] = types.TensorData(
            dtype=v["dtype"],
            shape=v["shape"],
            data=v["data"],
            sparse_crow_indices=v.get("sparse_crow_indices"),
            sparse_col_indices=v.get("sparse_col_indices")
        )
    return types.Datum(model_input=mi, loss_fn_inputs=lfi)

def load_datums(data_path):
    datums = []
    with open(data_path, "r", encoding="utf-8") as f:
        for line in f:
            if not line.strip():
                continue
            d_dict = json.loads(line)
            datums.append(dict_to_datum(d_dict))
    return datums

def train(args):
    # Ensure TINKER_API_KEY is configured
    if "TINKER_API_KEY" not in os.environ:
        os.environ["TINKER_API_KEY"] = "<YOUR_TINKER_API_KEY>"
        
    print(f"Initializing ServiceClient ...")
    sc = tinker.ServiceClient()
    
    print(f"Creating LoRA Training Client for base model: {args.model}")
    tc = sc.create_lora_training_client(base_model=args.model)
    
    print(f"Loading training data from: {args.data}")
    datums = load_datums(args.data)
    print(f"Loaded {len(datums)} Datum objects.")
    
    batch_size = args.batch_size
    num_batches = (len(datums) + batch_size - 1) // batch_size
    
    for epoch in range(args.epochs):
        print(f"\n--- Epoch {epoch+1}/{args.epochs} ---")
        random.shuffle(datums)
        
        for b_idx in range(num_batches):
            start = b_idx * batch_size
            end = min(start + batch_size, len(datums))
            batch = datums[start:end]
            
            # Forward-backward
            fwdbwd_future = tc.forward_backward(data=batch, loss_fn="cross_entropy")
            fwdbwd_res = fwdbwd_future.result()
            
            # Optim step
            optim_future = tc.optim_step(types.AdamParams(learning_rate=args.lr))
            optim_res = optim_future.result()
            
            loss_val = fwdbwd_res.metrics.get("loss:sum", "N/A")
            print(f"Batch {b_idx+1}/{num_batches} | Loss (sum): {loss_val}")
            
    print("\nTraining complete. Saving weights ...")
    # Save checkpoint state persistently
    try:
        save_res = tc.save_state(args.checkpoint, overwrite=True).result()
        print(f"Persistent training weights saved to: {save_res.path}")
    except Exception as e:
        print(f"Warning: could not save persistent training state: {e}")
        
    try:
        sampler_save_res = tc.save_weights_for_sampler(name=args.checkpoint).result()
        print(f"Persistent sampler weights saved to: {sampler_save_res.path}")
    except Exception as e:
        print(f"Warning: could not save persistent sampler weights: {e}")
        
    # Get sampling client (ephemeral)
    sc_client = tc.save_weights_and_get_sampling_client()
    print("Ephemeral sampling client retrieved successfully.")

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--data", default="C:\\Users\\admin\\Downloads\\pen200_datum_training.jsonl", help="Path to input serialized Datum JSONL")
    p.add_argument("--model", default="thinkingmachines/Inkling", help="Model ID")
    p.add_argument("--epochs", type=int, default=1, help="Number of training epochs")
    p.add_argument("--lr", type=type(1e-4), default=1e-4, help="Learning rate")
    p.add_argument("--batch_size", type=int, default=8, help="Batch size")
    p.add_argument("--checkpoint", default="checkpoint-1", help="Saved checkpoint name")
    args = p.parse_args()
    
    train(args)

if __name__ == "__main__":
    main()
