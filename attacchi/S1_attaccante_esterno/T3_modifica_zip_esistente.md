# T3 — Modifica del contenuto di uno ZIP esistente

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante modifica il contenuto di un file ZIP già presente nella
repository — ad esempio sostituisce un file sorgente con una versione
malevola — senza aggiornare il .sig corrispondente.

## Prerequisiti
- Repository di test con almeno due commit legittimi
- Accesso in scrittura alla cartella della repository
- Strumento per modificare archivi ZIP

## Passi dell'attacco
1. Identificare un commit target nella repository
2. Estrarre il file ZIP corrispondente
3. Modificare uno o più file all'interno dello ZIP
4. Sovrascrivere il file ZIP originale con quello modificato
5. Lasciare il .sig invariato
6. Eseguire il verificatore

## Risultato atteso
Il verificatore rileva [FAIL] hash:FAIL sul commit modificato e
[FAIL] catena:FAIL su tutti i commit successivi, poiché il
cumulativeHash dipende dall'hash del commit alterato.

## Risultato osservato (versione iniziale)
[da compilare]

## Analisi dell'impatto
[da compilare]

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS01, RS02
- Proprietà violata: Integrità, Ordine verificabile