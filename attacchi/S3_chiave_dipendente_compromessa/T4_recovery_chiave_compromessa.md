# T4 — Recovery dopo compromissione della chiave

## Scenario padre
S3 — Chiave privata di un dipendente compromessa

## Descrizione
Dopo aver identificato la compromissione della chiave di un dipendente,
il responsabile avvia la procedura di recovery. Il dipendente genera
una nuova coppia di chiavi, il responsabile aggiorna l'allowed_signers
rimuovendo la chiave compromessa e aggiungendo la nuova. La procedura
verifica che i commit prodotti prima della revoca rimangano validi
e che i nuovi commit vengano accettati con la nuova chiave.

Questa tecnica non è un attacco ma una procedura di risposta —
documenta formalmente come il sistema gestisce il ripristino
delle garanzie di sicurezza dopo un incidente.

## Prerequisiti
- Repository con commit legittimi e commit fraudolenti prodotti
  durante la simulazione di T2
- Chiave SSH compromessa ancora presente nell'allowed_signers
- Possibilità di generare una nuova coppia di chiavi

## Passi della procedura
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc integrity -signers="C:\Users\stemic\stage\allowed_signers"

Verifica integrita repository: tutti i progetti
allowed_signers: C:\Users\stemic\stage\allowed_signers

analyzing repository C:\Users\stemic\stage\repo\ ...
[OK]  0Q6PHT7QCI  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHV1YTU  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHW0IJW  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHWPMPQ  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6WWOWTGV  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6WWP3QDM  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6WWP4TNH  hash:OK  catena:OK  firma:OK  (Michele)

Risultato: 0/8 commit con problemi.
Risultato: 0/8 commit con warning.
tot. exec time: 1.78 sec
```
1. Generare una nuova coppia di chiavi SSH per il dipendente
ssh-keygen -t ed25519 -f chiave_nuova
2. Aggiornare il file allowed_signers rimuovendo la chiave
   compromessa e aggiungendo quella nuova
3. Eseguire il verificatore con il file allowed_signers aggiornato
   e documentare il comportamento sui commit precedenti
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc integrity -signers="C:\Users\stemic\stage\allowed_signers"

Verifica integrita repository: tutti i progetti
allowed_signers: C:\Users\stemic\stage\allowed_signers

analyzing repository C:\Users\stemic\stage\repo\ ...
[ERR] 0Q6PHT7QCI  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6PHUAOSV  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6PHV1YTU  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6PHW0IJW  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6PHWPMPQ  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6WWOWTGV  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6WWP3QDM  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6WWP4TNH  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
```
4. Produrre un nuovo commit firmato con la nuova chiave
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc commit -project=simulazione -tag=produzione -author=Michele -note=CommitFattoDaQulcunaltro
Reading manifest, path:.\
Readed manifest, path:.\
packing C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6WWTJTEU.0Q6WWTIPTA.{Michele}+produzione.zip
Starting scanner and collector ...
Scan excuted in 125 ms, collect in 0 ms tot:125 ms
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6WWTJTEU.0Q6WWTIPTA.{Michele}+produzione.zip to C:\Users\stemic\stage\repo\ ...
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6WWTJTEU.sig to C:\Users\stemic\stage\repo\ ...
tot. exec time: 0.31 sec
```
5. Eseguire nuovamente il verificatore e documentare il risultato
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc integrity -signers="C:\Users\stemic\stage\allowed_signers"

Verifica integrita repository: tutti i progetti
allowed_signers: C:\Users\stemic\stage\allowed_signers

analyzing repository C:\Users\stemic\stage\repo\ ...
[ERR] 0Q6PHT7QCI  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6PHUAOSV  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6PHV1YTU  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6PHW0IJW  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6PHWPMPQ  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6WWOWTGV  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6WWP3QDM  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6WWP4TNH  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[OK]  0Q6WWTIPTA  hash:OK  catena:OK  firma:OK  (Michele)
```
6. Verificare che i commit prodotti prima della revoca con la
   chiave legittima originale risultino ora FAIL — limitazione
   del verificatore attuale rispetto al modello proposto

## Risultato atteso
Dopo l'aggiornamento dell'allowed_signers i commit prodotti con
la nuova chiave risultano [OK]. I commit prodotti con la vecchia
chiave legittima risultano [FAIL] firma nel verificatore attuale —
limitazione già documentata in T3, che nel modello proposto non
si verificherebbe grazie all'allowed_Dipendenti interno a ogni commit.
I commit fraudolenti prodotti con la chiave rubata risultano
anch'essi [FAIL] e sono ora distinguibili dai commit legittimi
solo tramite analisi manuale della storia nel periodo sospetto.
Il motore accetta normalmente i nuovi commit firmati con la
nuova chiave.

## Risultato osservato (versione iniziale)
Il risultato osservato combacia in pieno con il risultato atteso.

## Analisi dell'impatto
La procedura di recovery è operativa e non richiede interventi
straordinari — è sufficiente aggiornare il file allowed_signers.
La finestra di rischio si chiude dal commit successivo alla revoca.
I commit fraudolenti prodotti durante la finestra rimangono nella
storia e sono identificabili solo tramite analisi manuale.
La limitazione principale è che il verificatore attuale non
distingue tra commit legittimi prodotti prima della revoca e
commit fraudolenti — entrambi risultano FAIL con l'allowed_signers
aggiornato. Il modello proposto con allowed_Dipendenti interno
risolve questa limitazione.

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito coinvolto: RS09
- Obiettivo stage: D03
- Proprietà: Revoca e recovery delle identità