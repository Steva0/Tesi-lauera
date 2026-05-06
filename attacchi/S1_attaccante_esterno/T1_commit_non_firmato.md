# T1 — Inserimento di un commit non firmato

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante crea manualmente un file ZIP e un file .sig senza
firma SSH, rispettando il formato RVC, e li copia nella cartella
della repository. Obiettivo: far accettare il commit dal motore
come se fosse legittimo.

## Prerequisiti
- Repository di test inizializzata con almeno un commit legittimo
- Nessuna chiave SSH

## Passi dell'attacco
1. [comando o azione concreta]
2. [comando o azione concreta]
3. [verifica del risultato]

## Risultato atteso (ipotesi)
Nella versione iniziale di RVC, dove la firma è opzionale,
il commit viene accettato senza errori.

## Risultato osservato (versione iniziale)
[da compilare dopo il test]

## Analisi dell'impatto
[cosa può fare l'attaccante con questo accesso,
quanto è grave, quali garanzie crittografiche viola]

## Contromisura implementata
[da compilare dopo l'implementazione — quale modifica al codice
risolve questa tecnica]

## Risultato osservato (dopo implementazione)
[da compilare dopo il ritesto]

## Riferimenti
- Requisito violato: RS06
- Proprietà di sicurezza violata: Autenticità, Non ripudio