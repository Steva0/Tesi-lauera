# T6 — Replay di un commit legittimo

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante copia un commit legittimo esistente — ZIP e .sig —
e lo reintroduce nella repository con un nuovo nome file, come se
fosse un commit nuovo. La firma è valida perché è quella originale,
ma il contenuto è duplicato.

## Prerequisiti
- Repository di test con almeno un commit legittimo firmato
- Accesso in scrittura alla cartella della repository

## Passi dell'attacco
1. Copiare ZIP e .sig di un commit legittimo
2. Rinominare i file con un nuovo identificativo timestamp
3. Copiare i file rinominati nella repository
4. Eseguire il verificatore

## Risultato atteso
Il verificatore rileva [FAIL] catena:FAIL sul commit reintrodotto
poiché il prevId e prevHash nel .sig originale non corrispondono
alla posizione in cui è stato inserito. La firma risulta OK perché
è quella originale, ma la catena è interrotta.

## Risultato osservato (versione iniziale)
[da compilare]

## Analisi dell'impatto
[da compilare]

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS02, RS03
- Proprietà violata: Ordine verificabile