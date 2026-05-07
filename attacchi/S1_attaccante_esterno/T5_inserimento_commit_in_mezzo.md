# T5 — Inserimento di un commit in mezzo alla catena

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante tenta di inserire un commit tra due commit esistenti,
modificando i riferimenti prevId e prevHash per far sembrare che
il nuovo commit sia parte legittima della catena.

## Prerequisiti
- Repository di test con almeno due commit legittimi
- Accesso in scrittura alla cartella della repository

## Passi dell'attacco
1. Identificare due commit consecutivi A e B nella catena
2. Produrre un nuovo commit C con prevId e prevHash che puntano ad A
3. Modificare il .sig di B per far puntare prevId e prevHash a C
4. Ricalcolare il cumulativeHash di B in base al nuovo prevHash
5. Copiare i file nella repository
6. Eseguire il verificatore

## Risultato atteso
Il verificatore rileva [FAIL] catena:FAIL su B poiché la firma
di B non corrisponde più al contenuto del .sig modificato — la
firma originale copriva i valori originali di prevId e prevHash.
Il commit inserito C risulta [WARN] firma:ASSENTE.

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
- Proprietà violata: Integrità, Ordine verificabile