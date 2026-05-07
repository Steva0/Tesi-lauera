# T9 — Commit con cumulativeHash falsificato

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante produce un commit con hash e cumulativeHash calcolati
correttamente sul nuovo ZIP ma con prevHash che punta a un commit
inesistente o scorretto, tentando di inserire un punto di ingresso
alternativo nella catena.

## Prerequisiti
- Repository di test con almeno un commit legittimo
- Accesso in scrittura alla cartella della repository
- Capacità di produrre un .sig strutturalmente valido

## Passi dell'attacco
1. Produrre un nuovo ZIP con contenuto arbitrario
2. Calcolare hash e cumulativeHash corretti per questo ZIP
3. Impostare prevHash con un valore arbitrario o inesistente
4. Produrre il .sig senza firma SSH
5. Copiare i file nella repository
6. Eseguire il verificatore

## Risultato atteso
Il verificatore rileva [FAIL] catena:FAIL poiché il prevHash
dichiarato non corrisponde al cumulativeHash del commit
precedente nella catena. Il commit risulta isolato —
non si aggancia alla storia legittima.

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