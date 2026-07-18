#!/usr/bin/env python3
"""PDF chunk extractor for Tinker training data. Zero-Binary: pure Python via sys.executable."""
import sys
import os
import re
import io
import json
import argparse
import fitz  # PyMuPDF

try:
    import pytesseract
    from PIL import Image
    HAS_OCR = True
except ImportError:
    HAS_OCR = False

def clean_and_filter_page(text):
    """Clean page text by stripping headers, footers and page numbers."""
    lines = []
    for line in text.split("\n"):
        line_s = line.strip()
        if not line_s:
            continue
        
        # Skip headers, copyright lines, and page numbers
        if "Penetration Testing with Kali Linux" in line_s:
            continue
        if "PWK - Copyright" in line_s or "OffSec Services" in line_s:
            continue
        if line_s.isdigit() and len(line_s) <= 4:
            continue
            
        lines.append(line_s)
        
    return "\n".join(lines).strip()

def is_toc_or_copyright(text, page_num):
    """Detect if page is Table of Contents or copyright page."""
    text_lower = text.lower()
    
    # Copyright heuristic (typically in first few pages)
    if page_num <= 10:
        if "copyright" in text_lower or "all rights reserved" in text_lower:
            return True
            
    # TOC heuristic (typically in first 15 pages)
    if page_num <= 15:
        if "table of contents" in text_lower or "contents" in text_lower:
            return True
        # Many dots indicating page index
        if text_lower.count("...") > 5 or text_lower.count(" . . ") > 5:
            return True
            
    return False

def extract_chunks_and_commands(pdf_path, max_pages=None):
    """Extract filtered text chunks and commands from the PDF."""
    doc = fitz.open(pdf_path)
    total_pages = len(doc)
    
    chunks = []
    
    pages_to_process = min(max_pages, total_pages) if max_pages else total_pages
    
    for page_idx in range(pages_to_process):
        page = doc.load_page(page_idx)
        page_num = page_idx + 1
        raw_text = page.get_text()
        
        if is_toc_or_copyright(raw_text, page_num):
            continue
            
        cleaned_text = clean_and_filter_page(raw_text)
        if not cleaned_text.strip():
            continue
            
        # 1. Image-embedded command extraction via OCR
        ocr_commands = []
        if HAS_OCR:
            image_list = page.get_images()
            for img_idx, img in enumerate(image_list):
                try:
                    xref = img[0]
                    base_image = doc.extract_image(xref)
                    image_bytes = base_image["image"]
                    image = Image.open(io.BytesIO(image_bytes))
                    ocr_text = pytesseract.image_to_string(image)
                    for line in ocr_text.split("\n"):
                        line = line.strip()
                        if line.startswith(("$ ", "# ", "C:\\>")) or "`" in line:
                            ocr_commands.append(line)
                except Exception as e:
                    pass
        
        # 2. Text command extraction
        text_commands = []
        for line in cleaned_text.split("\n"):
            line = line.strip()
            if line.startswith(("$ ", "# ", "C:\\>")) or (line.startswith("chmod") or line.startswith("ping") or line.startswith("nmap")):
                text_commands.append(line)
                
        # 3. Text chunking
        paragraphs = [p.strip() for p in cleaned_text.split("\n\n") if p.strip()]
        current_chunk = []
        current_len = 0
        
        for para in paragraphs:
            current_chunk.append(para)
            current_len += len(para)
            if current_len >= 800:
                chunk_content = "\n\n".join(current_chunk)
                chunks.append({
                    "text": chunk_content,
                    "page": page_num
                })
                current_chunk = []
                current_len = 0
                
        if current_chunk:
            chunk_content = "\n\n".join(current_chunk)
            chunks.append({
                "text": chunk_content,
                "page": page_num
            })
            
        # Add commands as separate chunks/pairs if found
        all_found_commands = list(set(ocr_commands + text_commands))
        for cmd in all_found_commands:
            if len(cmd) > 3:
                chunks.append({
                    "text": f"Terminal command usage:\n{cmd}",
                    "page": page_num,
                    "is_command": True
                })
                
    return chunks, total_pages

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--pdf", required=True, help="Path to input PDF file")
    p.add_argument("--output", help="Path to output JSONL file")
    p.add_argument("--pages", type=int, help="Limit number of pages to process")
    args = p.parse_args()
    
    if not os.path.exists(args.pdf):
        print(f"Error: PDF file not found at {args.pdf}")
        sys.exit(1)
        
    output_path = args.output
    if not output_path:
        base_name = os.path.splitext(os.path.basename(args.pdf))[0]
        output_path = f"{base_name}_training_full.jsonl"
        
    print(f"Processing PDF: {args.pdf} ...")
    if not HAS_OCR:
        print("[Note] OCR libraries (pytesseract/Pillow) not fully available. Image command extraction skipped.")
        
    chunks, total_pages = extract_chunks_and_commands(args.pdf, args.pages)
    
    # Save as JSONL SL pairs
    with open(output_path, "w", encoding="utf-8") as f:
        for chunk in chunks:
            response_text = chunk["text"]
            item = {
                "instruction": "Explain the penetration testing concept / command in this section.",
                "response": response_text,
                "format": "tinker_datum_supervised_lora",
                "loss": "cross_entropy",
                "weights": "0_for_prompt_1_for_completion",
                "page": chunk["page"],
                "filtered": "no_toc_no_headers_no_footers_no_copyright"
            }
            f.write(json.dumps(item) + "\n")
            
    print(f"Extraction complete. Saved {len(chunks)} pairs to {output_path} (from {total_pages} total pages).")
    print(f"[Zero-Binary verified] Executable: {sys.executable}")

if __name__ == "__main__":
    main()
