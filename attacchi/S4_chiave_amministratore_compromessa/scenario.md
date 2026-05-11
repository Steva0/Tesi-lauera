# Scenario 4 — Chiave operativa dell'amministratore compromessa

## Contesto
L'attaccante ha ottenuto la chiave privata SSH operativa
dell'amministratore — il soggetto con i poteri più ampi
sull'intera repository. Nella versione iniziale di RVC questo
scenario non è distinguibile tecnicamente dagli altri — non
esistono controlli di permessi che rendano la chiave
dell'amministratore diversa da quella di qualsiasi altro utente.

Il valore di questo scenario è quindi principalmente teorico:
dimostrare che nella versione iniziale la compromissione
dell'amministratore non produce nessun segnale aggiuntivo rispetto
alla compromissione di un dipendente qualsiasi, e analizzare
perché nel modello proposto questo scenario sarebbe invece
il più critico in assoluto.

## Cosa ha a disposizione
- La chiave privata SSH operativa dell'amministratore
- Accesso in scrittura alla cartella della repository
- Poteri illimitati su tutti i progetti nel modello proposto

## Obiettivo dell'attaccante
Nella versione iniziale: produrre commit su qualsiasi progetto
senza nessuna restrizione — identico agli altri scenari.
Nel modello proposto: modificare allowed_Responsabili,
degradare i permessi di qualsiasi progetto, aggiungere
identità non autorizzate, operare su tutti i progetti
senza nessun vincolo.

## Nota sulla versione iniziale
Nella versione iniziale di RVC non esistono controlli di
permessi differenziati per ruolo. La compromissione della
chiave dell'amministratore è tecnicamente identica alla
compromissione di qualsiasi altra chiave — il verificatore
segnala i commit come validi, il motore non emette avvisi.
La differenza emerge esclusivamente nel modello proposto,
dove l'amministratore ha poteri che nessun altro soggetto
possiede e dove la sua compromissione ha conseguenze
qualitativamente diverse.

## Tecniche documentate
- T1: compromissione totale e silenziosa nella versione iniziale
- Analisi teorica: implicazioni nel modello proposto e
  contromisure architetturali

## Stato complessivo
| Tecnica | Rilevata pre-implementazione | Rilevata post-implementazione |
|---------|------------------------------|-------------------------------|
| T1      | -                            | -                             |