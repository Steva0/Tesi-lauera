# Scenario 3 — Chiave privata di un dipendente compromessa

## Contesto
L'attaccante ha ottenuto la chiave privata SSH di un dipendente
legittimo — tramite furto, phishing, accesso fisico al dispositivo
o esposizione accidentale. Può produrre commit firmati
crittograficamente identici a quelli del dipendente legittimo.
Il verificatore non può distinguerli dalla firma — la chiave è
quella corretta e il firmatario è nell'allowed_signers.

Questo è lo scenario più insidioso: la firma è valida, il
firmatario è autorizzato, e non esiste nessun meccanismo automatico
per distinguere un commit legittimo da uno fraudolento senza
un'analisi manuale della storia.

## Cosa ha a disposizione
- La chiave privata SSH di un dipendente legittimo
- Accesso in scrittura alla cartella della repository
- Conoscenza del formato RVC e del progetto

## Obiettivo dell'attaccante
Produrre commit fraudolenti che risultino completamente validi
al verificatore, sfruttando la finestra di rischio tra la
compromissione della chiave e la sua revoca.

## Nota sul verificatore
Il verificatore attuale usa un file allowed_signers esterno e
statico. Questo comporta una differenza rispetto al modello
proposto, dove ogni commit porta il proprio allowed_Dipendenti
interno al momento della firma. Per documentare entrambi i
comportamenti vengono usati due file allowed_signers separati:
- allowed_signers_con_chiave: include la chiave compromessa
- allowed_signers_senza_chiave: non include la chiave compromessa
Questo permette di simulare sia il comportamento durante la
finestra di rischio sia quello dopo la revoca, evidenziando
la differenza tra il verificatore attuale e il modello proposto.

## Tecniche documentate
- T1: commit fraudolento indistinguibile dal legittimo
- T2: commit fraudolenti durante la finestra di rischio
- T3: propagazione nella catena dopo la revoca
- T4: recovery chiave compromessa