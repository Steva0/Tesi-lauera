# T1 — Commit senza firma

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante produce un commit normale tramite il motore RVC senza
fornire una chiave SSH. Il commit viene accettato dal motore perché
nella versione iniziale la firma è opzionale.

## Prerequisiti
- Repository di test con almeno un commit legittimo firmato
- Nessuna chiave SSH

## Passi dell'attacco
1. Modificare un file nella directory di lavoro
2. Eseguire `rvc commit` senza parametri di firma
3. Verificare che il commit sia stato accettato nella repository
4. Eseguire il verificatore

## Risultato atteso
Il motore accetta il commit. Il verificatore segnala [WARN] firma:ASSENTE.
Il contatore degli errori critici rimane a zero.

## Risultato osservato (versione iniziale)
[da compilare]

## Analisi dell'impatto
[da compilare]

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS06
- Proprietà violata: Autenticità, Non ripudio