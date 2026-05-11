# Risultati pre-implementazione — S4 Chiave amministratore compromessa

| Tecnica | Verificatore (con chiave) | Bloccata dal motore | Requisiti coinvolti |
|---------|--------------------------|---------------------|---------------------|
| T1 compromissione totale e silenziosa | OK su tutti i commit | No | RS05, RS07, RS08, RS09, RS10 |

## Osservazioni generali
Nella versione iniziale questo scenario è tecnicamente identico
allo scenario 3 — la compromissione della chiave dell'amministratore
non produce nessun segnale aggiuntivo rispetto alla compromissione
di qualsiasi altra chiave. Il motore accetta tutti i commit, il
verificatore li segnala come validi.

Il valore di questo scenario emerge nel confronto con il modello
proposto: mentre nello scenario 3 la compromissione riguarda un
dipendente con permessi limitati, qui la compromissione riguarda
il soggetto con i poteri più ampi sull'intera repository. Nel
modello proposto le conseguenze sarebbero qualitativamente diverse
e molto più gravi — l'attaccante potrebbe alterare la struttura
di fiducia dell'intera repository, non solo di un singolo progetto.

## Contromisure architetturali identificate
La separazione tra chiave master e chiave operativa — proposta
nel modello — è la principale mitigazione per questo scenario.
La chiave master, conservata offline, permette di revocare la
chiave operativa compromessa e ristabilire le garanzie di
sicurezza senza perdere la catena di fiducia. Questa contromisura
non è implementabile nella versione iniziale perché richiede
l'intera infrastruttura di _rvc_root e del modello proposto.