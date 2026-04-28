#!/usr/bin/env python3
"""
glossary_tagger.py
------------------
Legge i termini direttamente da appendix/glossary/terms.typ.
Per ogni file:
1. Rimuove eventuali tag #gl() preesistenti e ripristina il termine testuale.
2. Inserisce #gl() solo alla PRIMA occorrenza nel summary e alla PRIMA
   occorrenza nei capitoli.

Ogni termine sarà taggato al massimo 2 volte nel documento finale.

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
    La prima forma della lista è quella considerata "principale" per ripristinare il testo.
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

        # Estraiamo prima lo short (sarà la forma principale di ripristino)
        short_match = re.search(r'short:\s*\[([^\]]+)\]', block_text)
        if not short_match:
            short_match = re.search(r'short:\s*"([^"]+)"', block_text)
        if short_match:
            forms.append(short_match.group(1).strip())

        # Poi estraiamo il long
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
# LOGICA DI CONTROLLO
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


# ─────────────────────────────────────────────
# ELABORAZIONE FILE
# ─────────────────────────────────────────────

def process_file(filepath: str, terms: dict, tagged_keys: set) -> tuple:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    total_replacements = 0

    # ==========================================
    # FASE 1: PULIZIA (Ripristino testo)
    # Rimuove i #gl("chiave") preesistenti e ci rimette la parola.
    # Se il termine era duplicato, diventerà testo normale.
    # ==========================================
    for key, forms in terms.items():
        # Usiamo forms[0] (di solito lo "short") come termine testuale di base da rimettere
        primary_term = forms[0]
        # Regex per catturare: #gl("chiave"), #gl('chiave') o #gl(chiave)
        pattern_gl = r'#gl\(\s*["\']?' + re.escape(key) + r'["\']?\s*\)'
        content = re.sub(pattern_gl, primary_term, content)

    # ==========================================
    # FASE 2: TAGGING (Solo prima occorrenza)
    # ==========================================
    # Ordino le chiavi in base alla forma più lunga per evitare sovrapposizioni errate
    sorted_keys = sorted(terms.keys(), key=lambda k: max(len(f) for f in terms[k]), reverse=True)

    for key in sorted_keys:
        if key in tagged_keys:
            continue

        forms = terms[key]
        sorted_forms = sorted(forms, key=len, reverse=True)
        escaped_forms = [re.escape(f) for f in sorted_forms]
        
        # Pattern che cerca qualsiasi delle forme del termine
        pattern = r'(?<![#\w"\'-])(?:' + '|'.join(escaped_forms) + r')(?![\w"\'-])'

        replaced = False

        for m in re.finditer(pattern, content, re.IGNORECASE):
            start = m.start()
            if (is_inside_gl(content, start) or
                is_inside_comment(content, start) or
                is_inside_code_block(content, start) or
                is_inside_raw_inline(content, start)):
                continue # Falso positivo (commenti, codice, ecc.)
            else:
                # Trovata la PRIMA occorrenza valida testuale nel file: la tagghiamo
                content = content[:start] + f'#gl("{key}")' + content[m.end():]
                replaced = True
                break # Interrompiamo la ricerca di questa chiave in questo file

        if replaced:
            tagged_keys.add(key)
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

    # Memorie indipendenti per assicurare le due occorrenze massime
    tagged_in_summary = set()
    tagged_in_chapters = set()

    total = 0
    for relative_path in CHAPTER_FILES:
        filepath = os.path.join(script_dir, relative_path)

        if not os.path.exists(filepath):
            print(f"Attenzione: file non trovato: {relative_path}")
            continue

        if "summary.typ" in relative_path:
            active_tagged_set = tagged_in_summary
        else:
            active_tagged_set = tagged_in_chapters

        new_content, count = process_file(filepath, terms, active_tagged_set)

        # Scriviamo in ogni caso il file per consolidare l'untagging (Fase 1)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
            
        if count > 0:
            print(f"OK {relative_path}: {count} nuovo/i tag inserito/i (e file ripulito)")
        else:
            print(f"-- {relative_path}: nessun nuovo tag (file ripulito)")

        total += count

    print()
    print("=" * 60)
    print(f"Totale nuovi tag inseriti: {total}")
    print(f"Termini taggati nel summary: {len(tagged_in_summary)}")
    print(f"Termini taggati nei capitoli: {len(tagged_in_chapters)}")
    print("=" * 60)


if __name__ == "__main__":
    main()