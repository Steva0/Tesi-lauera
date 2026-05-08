# T1 — Commit firmato da chiave non autorizzata

## Scenario padre
S2 — Dipendente con chiave SSH valida ma non autorizzato

## Descrizione
Il dipendente firma un commit con la propria chiave SSH valida su un
progetto a cui non dovrebbe avere accesso. Il motore non verifica se
la chiave del firmatario sia presente in una lista di autorizzati —
nella versione iniziale questa lista non esiste. Il commit viene
accettato senza obiezioni. Solo il verificatore, confrontando la chiave
usata per la firma con il file allowed_signers, rileva il problema.

## Prerequisiti
- Chiave SSH valida generata dal dipendente non autorizzato
- Accesso in scrittura alla cartella della repository
- File allowed_signers contenente solo le chiavi degli autorizzati
  (usato dal verificatore, non dal motore)

## Passi dell'attacco
1. Firmare e produrre un commit con la chiave del dipendente
   non autorizzato
2. Verificare che il commit sia stato accettato dal motore
3. Tentare operazioni normali sul progetto — history, lettura
4. Eseguire il verificatore con il file allowed_signers corretto

## Risultato atteso
Il motore accetta il commit senza avvisi. Il verificatore segnala
[FAIL] firma:FAIL o un avviso equivalente poiché la chiave usata
per la firma non è presente nell'allowed_signers. Le operazioni
normali del motore non producono nessun segnale di anomalia.

## Risultato osservato (versione iniziale)
[da compilare]

## Analisi dell'impatto
[da compilare]

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS07, RS08
- Proprietà violata: Autorizzazione