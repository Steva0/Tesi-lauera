# Risultati S5 — Injection e robustezza dell'input

## Data di esecuzione
2026-05-19

## Riepilogo esecutivo

Su 10 categorie di test, sono stati identificati:
- **1 vulnerabilità di sicurezza** (command injection via cv.author — corretta)
- **1 vulnerabilità potenziale** (injection via config tamperata — fix difensivo aggiunto)
- **1 fallimento silenzioso** (cifratura age bypassata da recipients malformati — fix aggiunto)
- **1 bug critico funzionale** (CheckValidity blocca tutti i commit delta — corretto)
- **14 crash di robustezza** — tutti corretti con messaggi di errore utili
- **2 collisioni di naming** — corrette (`-vers` → `-allver`)

## Tabella risultati

| ID | Tecnica | Vulnerabilità | Gravità | Stato |
|----|---------|--------------|---------|-------|
| T1 | Injection CLI con metacaratteri | No (shell protegge) | — | ✓ Sicuro |
| T2 | Injection cv.author in .sig | **Sì** (CWE-78) | Alta | ✓ Corretto |
| T3 | Injection recipients age | Parziale (fallimento silenzioso) | Media | ✓ Fix aggiunto |
| T4 | Config file tamperata (default_key) | Potenziale (richiede accesso locale) | Bassa | ✓ Fix difensivo |
| T5 | Config file tamperata (rvc_home) | Potenziale (richiede accesso locale) | Bassa | ✓ Fix difensivo |
| T6 | Nomi lunghi (>64 chars) | **Sì** (crash MAX_PATH) | Media | ✓ Corretto |
| T7 | Parametri mancanti (14 crash) | **Sì** (crash + leak interno) | Media | ✓ Tutti corretti |
| T8 | File con nomi speciali nella WD | No | — | ✓ Sicuro |
| T9 | Contenuto file con payload | No | — | ✓ Sicuro |
| T10 | Bug CheckValidity delta commits | **Sì** (funzionalità bloccata) | Critica | ✓ Corretto |

## Comandi e output finali dopo i fix

### integrity completa (tutti i progetti OK)
```
Progetto: TestProj  [level=0]
[OK] ... hash:OK catena:OK firma:OK  (Michele)
[OK] ... hash:OK catena:OK firma:OK  (Michele)
...
Progetto: SecureProj  [level=4] (contenuto cifrato)
  Recipients:
    - Michele
[OK] ... hash:OK catena:OK firma:OK [cifrato]  (Michele)
...
Risultato: 0 commit con problemi.
Risultato: 0 commit con warning.
```

### Test crash (tutti danno errori puliti, nessun traceback)
```
ERROR:Parametro -master-pub= obbligatorio: chiave pubblica master non trovata.
ERROR:Parametro -name= obbligatorio: specificare il nome del progetto.
ERROR:Livello di sicurezza non valido: 9. Valori ammessi: 0, 1, 2, 3, 4.
ERROR:Parametro -file=<percorso> obbligatorio.
ERROR:Specificare -id (singolo), -range (id1..id2), o -branch (nome)
ERROR:Versione non trovata nel repository: NONEXISTENT
ERROR:Il path di directory non può contenere il carattere ": C:\fakedir" & ...
```

## Modifiche ai file

| File | N. modifiche |
|------|-------------|
| `rvc2/ProjectImage.cpl` | 8 |
| `rvc.cpl` | 5 |
| `rvc2/RvcEngine.cpl` | 1 |
| `rvc2/Init.cpl` | 1 |
