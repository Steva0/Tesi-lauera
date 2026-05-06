# Scenario 1 — Attaccante esterno senza credenziali

## Contesto
Chi è: un soggetto esterno che ha ottenuto accesso fisico o di rete
alla cartella della repository ma non possiede nessuna chiave SSH
valida e non conosce nessuna credenziale.

## Cosa ha a disposizione
- Accesso in lettura e scrittura alla cartella della repository
- I file ZIP e .sig esistenti
- Conoscenza della struttura del formato RVC (pubblica)

## Obiettivo dell'attaccante
Inserire modifiche non autorizzate che risultino valide,
oppure alterare la storia esistente senza che sia rilevabile.

## Tecniche documentate
- T1: inserimento di un commit non firmato
- T2: modifica del contenuto di uno ZIP esistente  
- T3: replay di un commit legittimo su un branch diverso

## Stato complessivo
- Prima delle implementazioni: [da compilare]
- Dopo le implementazioni: [da compilare]