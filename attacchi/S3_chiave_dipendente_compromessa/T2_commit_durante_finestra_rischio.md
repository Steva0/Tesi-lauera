# T2 — Commit fraudolenti durante la finestra di rischio

## Scenario padre
S3 — Chiave privata di un dipendente compromessa

## Descrizione
L'attaccante produce più commit nell'intervallo tra la
compromissione della chiave e la sua revoca dall'allowed_signers.
Questo dimostra concretamente la finestra di rischio descritta
nel modello — tutti i commit prodotti in questo intervallo
risultano validi al verificatore eseguito con
allowed_signers_con_chiave, e rimangono nella storia anche
dopo la revoca.

## Prerequisiti
- Chiave privata SSH del dipendente compromesso
- File allowed_signers_con_chiave e allowed_signers_senza_chiave
- Repository di test nello stato iniziale pulito

## Passi dell'attacco
1. Produrre 3 commit fraudolenti firmati con la chiave rubata
   simulando la finestra di rischio
2. Eseguire il verificatore con allowed_signers_con_chiave —
   tutti i commit risultano validi
3. Simulare la revoca aggiornando l'allowed_signers rimuovendo
   la chiave compromessa
4. Eseguire il verificatore con allowed_signers_senza_chiave —
   documentare il comportamento sui commit prodotti prima
   della revoca

## Risultato atteso
Con allowed_signers_con_chiave: tutti i commit fraudolenti
risultano [OK] — erano firmati da una chiave autorizzata
al momento della firma.
Con allowed_signers_senza_chiave: i commit fraudolenti
risultano [FAIL] firma — il verificatore usa la lista
aggiornata e non riconosce più la chiave.

Nota: questo comportamento differisce dal modello proposto,
dove ogni commit porta il proprio allowed_Dipendenti interno.
Nel modello proposto i commit prodotti prima della revoca
rimarrebbero validi perché la lista al momento della firma
includeva la chiave. Il verificatore attuale non distingue
tra "chiave valida al momento della firma" e "chiave valida
ora" — limitazione documentata come motivazione per il
modello proposto.

## Risultato osservato (versione iniziale)
[da compilare]

## Analisi dell'impatto
[da compilare]

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito coinvolto: RS09
- Proprietà violata: Autenticità, Integrità della storia