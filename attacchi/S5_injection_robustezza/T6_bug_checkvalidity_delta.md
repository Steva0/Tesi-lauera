# T6 — Bug critico: CheckValidity blocca tutti i commit delta

## Scenario padre
S5 — Injection e robustezza dell'input

## Descrizione
Un bug nella funzione `CheckValidity` causava il rifiuto di **tutti** i commit
successivi al primo per qualsiasi progetto che avesse un file
`allowed_Dipendenti`. Il meccanismo di confronto dei "file speciali" usava
`readFileFromCommit` che leggeva solo l'**ultimo commit** (un delta ZIP
che contiene solo i file modificati), trovava `allowed_Dipendenti` assente
nel delta, confrontava il file su disco con una stringa vuota, e concludeva
che il file era stato "modificato" → `specialFileChanged = true` → blocco.

## Impatto
**Critico per la funzionalità**: un repository correttamente inizializzato
non permetteva commit normali dopo il primo. Ogni commit dopo il setup
riceveva:
```
ERROR:Commit rifiutato: Modifica a file speciali richiede Admin (in
_rvc_root/allowed_Dipendenti) o Responsabile (in allowed_Responsabili
E nel progetto allowed_Dipendenti). Autore "Michele" non autorizzato.
```
anche se nessun file speciale era stato effettivamente modificato.

Questo bug rendeva RVC inutilizzabile per qualsiasi progetto level ≥ 0
con `allowed_Dipendenti` presente, dopo il commit iniziale.

## Causa tecnica

```cpl
-- Il problema:
if dipContent = nil
  -- readFileFromCommit legge solo l'ULTIMO commit ZIP
  -- I commit delta non contengono allowed_Dipendenti!
  dipContent := Init.readFileFromCommit(project, 'allowed_Dipendenti', repos)
end
-- Se dipContent=nil (non trovato nel delta):
-- Strtran(wdDip, ...) <> '' → specialFileChanged = true → BLOCCO
```

`Init.readFileFromCommit` apre solo il ZIP dell'ultimo commit.
Nei commit delta, `allowed_Dipendenti` non è presente (non è cambiato).
`dipContent` rimane nil.
Il confronto diventa `contenuto_su_disco <> ''` → sempre true se il file ha contenuto.

## Fix

```cpl
-- Prima del fix:
if dipContent = nil
  dipContent := Init.readFileFromCommit(project, 'allowed_Dipendenti', repos)
end

-- Dopo il fix:
if dipContent = nil
  -- getFileFromHistory attraversa l'intera catena di commit
  dipContent := getFileFromHistory(project, 'allowed_Dipendenti')
end
```

`getFileFromHistory` naviga la catena di commit partendo dal più recente
finché non trova il file, anche se è in un commit lontano nella storia.

## Risultato osservato (prima del fix)
Tentativo di commit in InjProj2 dopo il commit iniziale:
```
ERROR:Commit rifiutato: Modifica a file speciali richiede Admin ...
```
Anche con `diff` che mostrava solo `a.txt` modificato (nessun file speciale).

## Risultato osservato (dopo il fix)
Commit normale eseguito correttamente:
```
packing ... InjProj2.0Q7BN6DDYV...zip
copying ... to repo ...
```
Integrity mostra `[OK]` per tutti i commit.

## Note
Questo bug non era un vettore di attacco ma un'interferenza critica con
la funzionalità di base. Emerge solo durante il testing completo del flusso
commit-dopo-commit, e non sarebbe stato trovato testando solo il commit iniziale.

## Riferimenti
- File modificato: `rvc2/ProjectImage.cpl`, funzione `CheckValidity`
- Funzione coinvolta: `readFileFromCommit` vs `getFileFromHistory`
