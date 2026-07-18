---
name: pdf-to-tinker-training
description: Split PDF books (variable formats) into supervised Tinker Datum pairs for Inkling LoRA fine-tuning via pure Python (sys.executable, Zero-Binary).
version: 1.0
---

## Trigger
User asks to create fine-tuning data from PDF for thinkingmachines/Inkling using Tinker.

## Requirements
- Zero-Binary / Zero-Batch enforcement: execute via `sys.executable`, no compiled wrappers (see Hermes `AGENTS.md`: plugins/skills extend at edges, core stays pure Python).
- Tokenizer: `training_client.get_tokenizer()` (provided by Tinker SDK; requires full `tinker` env; `tml_tokenizers` is SDK-internal, not on PyPI).
- Tinker SDK: `pip install tinker` (v0.23.0 verified). `types.Datum`, `types.ModelInput.from_ints`, `cross_entropy` loss.
- Tinker `base_model` IDs verified from docs (`tinker/models/`): `thinkingmachines/Inkling` (64K), `thinkingmachines/Inkling:peft:262144` (256K). SDK `400` with `thinkingmachines/inkling` indicates case-sensitive ID; use exact docs string.

## Tinker Datum format (verified from tinker-docs quickstart)
```
datum = types.Datum(
    model_input=types.ModelInput.from_ints(tokens=input_tokens),
    loss_fn_inputs=dict(
        weights=weights,           # 0 = prompt, 1 = completion
        target_tokens=target_tokens  # shift by 1 from input
    )
)
```
Used with `training_client.forward_backward_async(data=[datum], loss_fn="cross_entropy")` via `create_lora_training_client`.

## Chunking strategy
- By headings when detectable; fall back to page-based with configurable overlap.
- Each chunk → instruction (heading/summary) + response (body text).
- **Command/tool extraction:** many books include terminal commands in images (screenshots), not text. For text commands, scan chunks for backticks / `$ ` patterns. For image-embedded commands: extract images via `fitz` page.get_images(), apply OCR (e.g., `tesseract` or vision model) to recover terminal text. Extracted commands become supervised pairs (instruction = "How to use <command>?", response = usage + context).

## Final Workflow (verified — generic, no hard-coded paths)
1. Extract any PDF (`--pdf <path>`) → filter → chunk
2. Generate SL pairs → `<output_path>` (.jsonl, default: `<pdf_basename>_training_full.jsonl`)
3. Train: `scripts/train_lora.py` (LoRA + `cross_entropy`) with `create_lora_training_client`
4. Format: `tinker_datum_supervised_lora` (`loss: cross_entropy`, `weights: ...`, LoRA)
5. Image commands: `fitz.get_images()` + OCR

## Verification
Run: `python chunk_pdf.py --pdf <path>`
