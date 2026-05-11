# Risultati pre-implementazione — S3 Chiave dipendente compromessa

| Tecnica | Verificatore (con chiave) | Verificatore (senza chiave) | Bloccata dal motore | Requisiti coinvolti |
|---------|--------------------------|----------------------------|---------------------|---------------------|
| T1 commit fraudolento indistinguibile | OK su tutti i commit | N/A | No | RS09 |
| T2 commit durante finestra di rischio | OK su tutti i commit | ERR su tutti i commit | No | RS09 |
| T3 propagazione dopo revoca | OK su tutti i commit | ERR su tutti i commit | No | RS09 |
| T4 recovery chiave compromessa | ERR su commit vecchi, OK su nuovo | ERR su commit vecchi, OK su nuovo | No | RS09 |

## Osservazioni generali
Tutti e quattro i test confermano che la chiave SSH è l'unico
indicatore di fiducia nel sistema. Una chiave compromessa produce
commit crittograficamente indistinguibili da quelli legittimi —
né il motore né il verificatore possono rilevarli automaticamente.

La finestra di rischio tra compromissione e revoca è completamente
esposta: durante questo intervallo l'attaccante può produrre
qualsiasi numero di commit fraudolenti che risultano tutti validi.

La recovery è operativa e non richiede interventi straordinari —
è sufficiente aggiornare il file allowed_signers. I nuovi commit
firmati con la nuova chiave risultano immediatamente validi.

## Limitazione documentata del verificatore attuale
Il verificatore usa un file allowed_signers esterno e statico.
Alla rimozione della chiave compromessa tutti i commit precedenti
— sia legittimi che fraudolenti — risultano ERR in modo indistinto.
Nel modello proposto con allowed_Dipendenti interno a ogni commit,
i commit prodotti prima della revoca rimarrebbero validi perché
la lista al momento della firma includeva la chiave. Questa è
la motivazione principale per la scelta architetturale dell'
allowed_Dipendenti versionato nel modello proposto.

## Impatto complessivo dello scenario
Alto — la compromissione di una chiave privata è lo scenario
più insidioso perché non produce nessun segnale automatico.
L'unica mitigazione è procedurale: rotazione periodica delle
chiavi, rilevamento rapido della compromissione e revoca
immediata. La dimensione della finestra di rischio dipende
interamente dalla rapidità con cui la compromissione viene
identificata e comunicata.