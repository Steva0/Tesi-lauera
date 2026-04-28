#!/usr/bin/env python3
"""
glossary_tagger.py
------------------
Legge i termini direttamente da appendix/glossary/terms.typ e sostituisce
ogni occorrenza nei file dei capitoli con #gl("chiave").

Uso:
    python glossary_tagger.py

Posiziona questo script nella root della repository della tesi.
"""

import re
import os

# ─────────────────────────────────────────────
# CONFIGURAZIONE
# ─────────────────────────────────────────────

TERMS_FILE = "appendix/glossary/terms.typ"

CHAPTER_FILES = [
    "preface/summary.typ",
    "chapters/1_introduction.typ",
    "chapters/2_stage-description.typ",
    "chapters/3_requirements.typ",
    "chapters/4_conclusion.typ",
]

# ─────────────────────────────────────────────
# PARSING DI terms.typ
# ─────────────────────────────────────────────

def parse_glossary(filepath: str) -> dict:
    """
    Legge terms.typ ed estrae chiave, short e long per ogni termine.
    Restituisce un dizionario: chiave -> lista di forme testuali da cercare.
    """
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    terms = {}

    block_pattern = re.compile(r'\(\s*(.*?)\s*\),?\s*(?=\(|\))', re.DOTALL)

    for block in block_pattern.finditer(content):
        block_text = block.group(1)

        key_match = re.search(r'key:\s*"([^"]+)"', block_text)
        if not key_match:
            continue
        key = key_match.group(1)

        forms = []

        short_match = re.search(r'short:\s*\[([^\]]+)\]', block_text)
        if not short_match:
            short_match = re.search(r'short:\s*"([^"]+)"', block_text)
        if short_match:
            forms.append(short_match.group(1).strip())

        long_match = re.search(r'long:\s*\[([^\]]+)\]', block_text)
        if not long_match:
            long_match = re.search(r'long:\s*"([^"]+)"', block_text)
        if long_match:
            long_form = long_match.group(1).strip()
            if long_form not in forms:
                forms.append(long_form)

        if forms:
            terms[key] = forms

    return terms


# ─────────────────────────────────────────────
# LOGICA DI SOSTITUZIONE
# ─────────────────────────────────────────────

def is_inside_gl(text: str, match_start: int) -> bool:
    line_start = text.rfind('\n', 0, match_start) + 1
    prefix = text[line_start:match_start]
    last_gl = prefix.rfind('#gl(')
    if last_gl == -1:
        return False
    after_gl = prefix[last_gl + 4:]
    depth = 1
    for ch in after_gl:
        if ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
            if depth == 0:
                return False
    return depth > 0


def is_inside_comment(text: str, match_start: int) -> bool:
    line_start = text.rfind('\n', 0, match_start) + 1
    line_prefix = text[line_start:match_start].lstrip()
    return line_prefix.startswith('//')


def is_inside_code_block(text: str, match_start: int) -> bool:
    before = text[:match_start]
    count = before.count('```')
    return count % 2 == 1


def is_inside_raw_inline(text: str, match_start: int) -> bool:
    before = text[:match_start]
    cleaned = before.replace('```', '')
    count = cleaned.count('`')
    return count % 2 == 1


def process_file(filepath: str, terms: dict) -> tuple:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    total_replacements = 0

    for key, forms in terms.items():
        for form in sorted(forms, key=len, reverse=True):
            pattern = r'(?<![#\w"\'-])' + re.escape(form) + r'(?![\w"\'-])'

            new_content_parts = []
            last_end = 0
            replacements = 0

            for m in re.finditer(pattern, content, re.IGNORECASE):
                start = m.start()
                if (is_inside_gl(content, start) or
                    is_inside_comment(content, start) or
                    is_inside_code_block(content, start) or
                    is_inside_raw_inline(content, start)):
                    new_content_parts.append(content[last_end:m.end()])
                else:
                    new_content_parts.append(content[last_end:start])
                    new_content_parts.append(f'#gl("{key}")')
                    replacements += 1
                last_end = m.end()

            new_content_parts.append(content[last_end:])
            content = ''.join(new_content_parts)
            total_replacements += replacements

    return content, total_replacements


# ─────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))

    print("=" * 60)
    print("Glossary Tagger — Tesi Michele Stevanin")
    print("=" * 60)

    terms_path = os.path.join(script_dir, TERMS_FILE)
    if not os.path.exists(terms_path):
        print(f"Errore: file glossario non trovato: {TERMS_FILE}")
        return

    terms = parse_glossary(terms_path)

    if not terms:
        print("Errore: nessun termine trovato nel glossario.")
        return

    print(f"\nTermini letti da {TERMS_FILE}:")
    for key, forms in terms.items():
        print(f"  {key}: {forms}")
    print()

    total = 0
    for relative_path in CHAPTER_FILES:
        filepath = os.path.join(script_dir, relative_path)

        if not os.path.exists(filepath):
            print(f"Attenzione: file non trovato: {relative_path}")
            continue

        new_content, count = process_file(filepath, terms)

        if count > 0:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"OK {relative_path}: {count} sostituzione/i")
        else:
            print(f"-- {relative_path}: nessuna modifica")

        total += count

    print()
    print("=" * 60)
    print(f"Totale sostituzioni: {total}")
    print("=" * 60)


if __name__ == "__main__":
    main()
