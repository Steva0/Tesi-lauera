#!/usr/bin/env python3
"""
glossary_tagger.py
------------------
Legge i termini direttamente da appendix/glossary/terms.typ.
Per ogni file:
1. Rimuove eventuali tag #gl() preesistenti e ripristina il termine testuale.
2. Inserisce #gl() ad OGNI occorrenza del termine nel testo.
3. Se il termine nel testo inizia con lettera maiuscola, aggiunge capitalize: true.
4. Se il termine inizia con lettera minuscola, non aggiunge capitalize.

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
SUMMARY_FILE = "preface/summary.typ"
CHAPTERS_DIR = "chapters"

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
# LOGICA DI CONTROLLO CONTESTO
# ─────────────────────────────────────────────

def is_inside_gl(text: str, match_start: int) -> bool:
    """Controlla se il match è già dentro un #gl()"""
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
    """Controlla se il match è dentro un commento //"""
    line_start = text.rfind('\n', 0, match_start) + 1
    line_prefix = text[line_start:match_start].lstrip()
    return line_prefix.startswith('//')


def is_inside_code_block(text: str, match_start: int) -> bool:
    """Controlla se il match è dentro un blocco ```"""
    before = text[:match_start]
    count = before.count('```')
    return count % 2 == 1


def is_inside_raw_inline(text: str, match_start: int) -> bool:
    """Controlla se il match è dentro un inline `codice`"""
    before = text[:match_start]
    cleaned = before.replace('```', '')
    count = cleaned.count('`')
    return count % 2 == 1


def is_inside_figure_or_import(text: str, match_start: int) -> bool:
    """Controlla se il match è dentro #figure, #import o #include"""
    line_start = text.rfind('\n', 0, match_start) + 1
    line_prefix = text[line_start:match_start].lstrip()
    for keyword in ('#figure', '#import', '#include', '#let', '#set', '#show'):
        if line_prefix.startswith(keyword):
            return True
    return False


def should_skip(text: str, match_start: int) -> bool:
    """Controlla se il match va saltato per qualsiasi motivo"""
    return (
        is_inside_gl(text, match_start) or
        is_inside_comment(text, match_start) or
        is_inside_code_block(text, match_start) or
        is_inside_raw_inline(text, match_start) or
        is_inside_figure_or_import(text, match_start) or
        is_inside_heading(text, match_start)
    )


# ─────────────────────────────────────────────
# GENERAZIONE TAG
# ─────────────────────────────────────────────

def make_gl_tag(key: str, matched_text: str) -> str:
    """
    Genera il tag #gl() appropriato.
    Se il testo originale inizia con maiuscola, aggiunge capitalize: true.
    """
    if matched_text and matched_text[0].isupper():
        return f'#gl("{key}", capitalize: true)'
    else:
        return f'#gl("{key}")'


# ─────────────────────────────────────────────
# ELABORAZIONE FILE
# ─────────────────────────────────────────────

def process_file(filepath: str, terms: dict) -> tuple:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    total_replacements = 0

    # ==========================================
    # FASE 1: PULIZIA
    # Rimuove tutti i #gl() preesistenti e ripristina il testo originale.
    # Gestisce sia #gl("chiave") che #gl("chiave", capitalize: true)
    # ==========================================
    for key, forms in terms.items():
        primary_term = forms[0]  # forma di base (minuscola)

        # Rimuove #gl("chiave", capitalize: true) → forma maiuscola
        pattern_capitalize = r'#gl\(\s*["\']?' + re.escape(key) + r'["\']?\s*,\s*capitalize\s*:\s*true\s*\)'
        # Prima lettera maiuscola del termine
        capitalized_term = primary_term[0].upper() + primary_term[1:] if primary_term else primary_term
        content = re.sub(pattern_capitalize, capitalized_term, content)

        # Rimuove #gl("chiave") → forma minuscola
        pattern_gl = r'#gl\(\s*["\']?' + re.escape(key) + r'["\']?\s*\)'
        content = re.sub(pattern_gl, primary_term, content)

    # ==========================================
    # FASE 2: TAGGING
    # Inserisce #gl() ad ogni occorrenza valida.
    # Ordina per lunghezza decrescente per evitare match parziali.
    # ==========================================
    sorted_keys = sorted(
        terms.keys(),
        key=lambda k: max(len(f) for f in terms[k]),
        reverse=True
    )

    for key in sorted_keys:
        forms = terms[key]
        sorted_forms = sorted(forms, key=len, reverse=True)
        escaped_forms = [re.escape(f) for f in sorted_forms]

        # Pattern case-insensitive con word boundary
        pattern = r'(?<![#\w"\'-])(?:' + '|'.join(escaped_forms) + r')(?![\w"\'-])'

        # Raccoglie tutti i match prima di sostituire (per non perdere le posizioni)
        matches = list(re.finditer(pattern, content, re.IGNORECASE))

        # Sostituisce partendo dalla fine per non invalidare le posizioni
        for m in reversed(matches):
            start = m.start()
            if should_skip(content, start):
                continue

            matched_text = m.group(0)
            tag = make_gl_tag(key, matched_text)
            content = content[:start] + tag + content[m.end():]
            total_replacements += 1

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

    # Costruisce la lista dei file da elaborare
    files_to_process = []

    summary_path = os.path.join(script_dir, SUMMARY_FILE)
    if os.path.exists(summary_path):
        files_to_process.append(SUMMARY_FILE)

    chapters_path = os.path.join(script_dir, CHAPTERS_DIR)
    if os.path.exists(chapters_path):
        found_files = [
            f for f in os.listdir(chapters_path)
            if f.endswith('.typ') and os.path.isfile(os.path.join(chapters_path, f))
        ]
        found_files.sort()
        for f in found_files:
            files_to_process.append(os.path.join(CHAPTERS_DIR, f).replace('\\', '/'))
    else:
        print(f"Attenzione: cartella '{CHAPTERS_DIR}' non trovata.")

    total = 0
    for relative_path in files_to_process:
        filepath = os.path.join(script_dir, relative_path)

        if not os.path.exists(filepath):
            print(f"Attenzione: file non trovato: {relative_path}")
            continue

        new_content, count = process_file(filepath, terms)

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)

        if count > 0:
            print(f"OK {relative_path}: {count} tag inserito/i")
        else:
            print(f"-- {relative_path}: nessun tag inserito (file ripulito)")

        total += count

    print()
    print("=" * 60)
    print(f"Totale tag inseriti: {total}")
    print("=" * 60)

def is_inside_heading(text: str, match_start: int) -> bool:
    """Controlla se il match è dentro un titolo == o ==="""
    line_start = text.rfind('\n', 0, match_start) + 1
    line_prefix = text[line_start:match_start].lstrip()
    return line_prefix.startswith('=')




if __name__ == "__main__":
    main()