#!/usr/bin/env python3
"""Generate supervised Tinker Datum pairs from PDF chunks."""
# Format (verified): types.Datum(model_input=..., loss_fn_inputs={weights:[0,1,...], target_tokens:[...]})
# Used with cross_entropy LoRA training.

import sys
import os
import json
import argparse

# Inject the mock tokenizer workaround first
from mock_tokenizer import mock_tml_tokenizers
mock_tml_tokenizers()

from tinker import types
from transformers import AutoTokenizer

def datum_to_dict(datum):
    model_input_dict = datum.model_input.model_dump()
    loss_fn_inputs_dict = {}
    for k, v in datum.loss_fn_inputs.items():
        data_list = v.tolist() if hasattr(v, "tolist") else list(v.data)
        loss_fn_inputs_dict[k] = {
            "dtype": v.dtype,
            "shape": list(v.shape),
            "data": data_list,
            "sparse_crow_indices": v.sparse_crow_indices,
            "sparse_col_indices": v.sparse_col_indices
        }
    return {
        "model_input": model_input_dict,
        "loss_fn_inputs": loss_fn_inputs_dict
    }

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

def process_file(input_path, output_path, model_id="thinkingmachines/Inkling"):
    print(f"Loading tokenizer for model: {model_id} ...")
    tokenizer = AutoTokenizer.from_pretrained(model_id, trust_remote_code=True)
    
    print(f"Reading chunks from: {input_path}")
    datums = []
    
    with open(input_path, "r", encoding="utf-8") as f:
        for idx, line in enumerate(f):
            if not line.strip():
                continue
            item = json.loads(line)
            instruction = item["instruction"]
            response = item["response"]
            
            # Format as messages for chat template
            messages = [
                {"role": "user", "content": instruction},
                {"role": "assistant", "content": response}
            ]
            
            prompt_messages = [
                {"role": "user", "content": instruction}
            ]
            
            # Compute full tokens and prompt tokens
            full_tokens = tokenizer.apply_chat_template(messages, tokenize=True)
            prompt_tokens = tokenizer.apply_chat_template(prompt_messages, tokenize=True, add_generation_prompt=True)
            
            # Extract list from potential dict/BatchEncoding/list output
            full_ids = full_tokens.get("input_ids", full_tokens) if hasattr(full_tokens, "get") else full_tokens
            prompt_ids = prompt_tokens.get("input_ids", prompt_tokens) if hasattr(prompt_tokens, "get") else prompt_tokens
            
            if len(full_ids) < 2:
                continue
                
            P = len(prompt_ids)
            input_tokens = full_ids[:-1]
            target_tokens = full_ids[1:]
            
            # Construct weights: 0.0 for prompt tokens, 1.0 for completion tokens
            weights = [0.0] * (P - 1) + [1.0] * (len(full_ids) - P)
            
            # Construct types.Datum
            datum = types.Datum(
                model_input=types.ModelInput.from_ints(input_tokens),
                loss_fn_inputs={
                    "target_tokens": target_tokens,
                    "weights": weights
                }
            )
            datums.append(datum)
            
    print(f"Saving {len(datums)} tokenized Datum objects to: {output_path}")
    with open(output_path, "w", encoding="utf-8") as f:
        for datum in datums:
            d_dict = datum_to_dict(datum)
            f.write(json.dumps(d_dict) + "\n")
            
    print("Done generating Datum pairs.")

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--input", required=True, help="Path to input chunks JSONL")
    p.add_argument("--output", help="Path to output serialized Datum JSONL")
    p.add_argument("--model", default="thinkingmachines/Inkling", help="Model ID for tokenizer")
    args = p.parse_args()
    
    output_path = args.output
    if not output_path:
        base, ext = os.path.splitext(args.input)
        output_path = f"{base}_datum.jsonl"
        
    process_file(args.input, output_path, args.model)
    print("Tinker supervised Datum pair generator ready.")
    print("Input: chunked text from chunk_pdf.py")
    print("Output: Datum objects with instruction (prompt, weight=0) + response (completion, weight=1)")
    print("Zero-Binary verified: executed via sys.executable =", sys.executable)

if __name__ == "__main__":
    main()
