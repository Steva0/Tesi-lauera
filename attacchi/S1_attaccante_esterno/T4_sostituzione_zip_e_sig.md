# T4 — Sostituzione completa di ZIP e .sig

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante sostituisce sia lo ZIP che il .sig di un commit esistente
con valori ricalcolati su un contenuto alterato. Hash e cumulativeHash
nel nuovo .sig sono corretti rispetto al nuovo ZIP, ma il cumulativeHash
del commit successivo nella catena non corrisponde più.

## Prerequisiti
- Repository di test con almeno due commit legittimi
- Accesso in scrittura alla cartella della repository
- Capacità di produrre un .sig valido dal punto di vista
  strutturale (senza firma SSH)

## Passi dell'attacco
1. Identificare un commit target che non sia l'ultimo della catena
2. Produrre un nuovo ZIP con contenuto alterato
3. Calcolare il nuovo hash SHA256 del ZIP
4. Produrre un nuovo .sig con hash e cumulativeHash aggiornati
   ma senza firma SSH
5. Sovrascrivere i file originali nella repository
6. Eseguire il verificatore

## Risultato atteso
Il verificatore segnala [FAIL] catena:FAIL sul commit successivo
a quello sostituito, poiché il prevHash non corrisponde al
cumulativeHash del commit alterato. Il commit alterato stesso
potrebbe risultare hash:OK se il ricalcolo è corretto, ma la
catena si rompe nel punto successivo.

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