# T8 — Troncamento della catena

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante elimina fisicamente uno o più commit dalla repository
cancellando i file ZIP e .sig corrispondenti, creando un buco
nella catena.

## Prerequisiti
- Repository di test con almeno tre commit legittimi
- Accesso in scrittura alla cartella della repository

## Passi dell'attacco
1. Identificare uno o più commit da eliminare che non siano
   l'ultimo della catena
2. Cancellare i file ZIP e .sig corrispondenti
3. Eseguire il verificatore
4. Tentare operazioni normali sul progetto (commit, lettura)

## Risultato atteso
Il verificatore rileva la discontinuità nella catena — il commit
successivo a quelli eliminati ha un prevId che non corrisponde
a nessun commit presente. Da verificare come reagisce il motore
durante le operazioni normali.

## Risultato osservato (versione iniziale)
[da compilare]

## Analisi dell'impatto
[da compilare]

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS02
- Proprietà violata: Integrità, Ordine verificabile