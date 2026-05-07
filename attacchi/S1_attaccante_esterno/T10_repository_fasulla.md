# T10 — Iniezione di una repository fasulla

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante crea da zero una repository completa con una catena
di commit non firmati, strutturalmente valida dal punto di vista
degli hash, e tenta di farla passare come repository legittima.
Questo scenario tocca direttamente il problema della radice di
fiducia — senza un primo commit firmato da un'autorità verificabile,
non c'è modo di distinguere una repository legittima da una fasulla.

## Prerequisiti
- Nessuna — l'attaccante parte da zero
- Nessuna chiave SSH

## Passi dell'attacco
1. Creare una nuova directory come repository fasulla
2. Produrre una catena di commit con hash e cumulativeHash
   calcolati correttamente ma senza firme SSH
3. Distribuire la repository fasulla come se fosse legittima
4. Eseguire il verificatore sulla repository fasulla
5. Confrontare l'output con quello della repository legittima

## Risultato atteso
Il verificatore segnala [WARN] firma:ASSENTE su tutti i commit
ma non rileva errori critici — la catena degli hash è
strutturalmente valida. Non esiste nessun meccanismo nella
versione iniziale per distinguere questa repository da una
legittima. Questo dimostra direttamente l'assenza di RS05.

## Risultato osservato (versione iniziale)
[da compilare]

## Analisi dell'impatto
Impatto massimo — un attaccante può distribuire codice arbitrario
in una repository che supera tutti i controlli strutturali del
verificatore. Senza radice di fiducia verificabile, l'intera
catena degli hash garantisce solo la coerenza interna della
repository fasulla, non la sua legittimità.

## Contromisura implementata
[da compilare — questa è la motivazione principale di RS05
e del progetto _rvc_root nel modello proposto]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS05
- Proprietà violata: Autenticità, Radice di fiducia