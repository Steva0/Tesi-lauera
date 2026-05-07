# T2 — Commit con identità falsa

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante produce un commit senza firma dichiarando nel .sig di essere
un autore legittimo. Poiché non c'è firma crittografica, il campo author
nel .sig non è verificabile e può contenere qualsiasi valore.

## Prerequisiti
- Repository di test con almeno un commit legittimo firmato
- Conoscenza del nome o identificativo di un autore legittimo
- Nessuna chiave SSH

## Passi dell'attacco
1. Modificare un file nella directory di lavoro
2. Eseguire `rvc commit` senza firma, specificando come autore
   il nome di un utente legittimo
3. Verificare che il commit sia stato accettato nella repository
4. Eseguire il verificatore

## Risultato atteso
Il motore accetta il commit. Il verificatore segnala [WARN] firma:ASSENTE
con il nome dell'autore dichiarato tra parentesi seguito da "non verificato".
Non è possibile distinguere questo commit da uno legittimo senza
esaminare la firma.

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