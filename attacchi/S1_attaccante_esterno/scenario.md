# Scenario 1 — Attaccante esterno senza credenziali

## Contesto
L'attaccante è un soggetto esterno che ha ottenuto accesso fisico o di rete
alla cartella della repository ma non possiede nessuna chiave SSH valida e
non conosce nessuna credenziale. Conosce il formato dei file RVC — informazione
pubblica ricavabile dall'osservazione della struttura della repository.

## Cosa ha a disposizione
- Accesso in lettura e scrittura alla cartella della repository
- I file ZIP e .sig esistenti
- Conoscenza della struttura del formato RVC

## Obiettivo dell'attaccante
Inserire modifiche non autorizzate che risultino valide agli occhi del motore,
oppure alterare la storia esistente senza che sia rilevabile.

## Tecniche documentate
- T1: commit senza firma
- T2: commit con identità falsa
- T3: modifica del contenuto di uno ZIP esistente
- T4: sostituzione completa di ZIP e .sig
- T5: inserimento di un commit in mezzo alla catena
- T6: replay di un commit legittimo
- T7: modifica del .sig senza modificare lo ZIP
- T8: troncamento della catena
- T9: commit con cumulativeHash falsificato
- T10: iniezione in una repository non inizializzata

## Stato complessivo
| Tecnica | Rilevata pre-implementazione | Rilevata post-implementazione |
|---------|------------------------------|-------------------------------|
| T1      | -                            | -                             |
| T2      | -                            | -                             |
| T3      | -                            | -                             |
| T4      | -                            | -                             |
| T5      | -                            | -                             |
| T6      | -                            | -                             |
| T7      | -                            | -                             |
| T8      | -                            | -                             |
| T9      | -                            | -                             |
| T10     | -                            | -                             |