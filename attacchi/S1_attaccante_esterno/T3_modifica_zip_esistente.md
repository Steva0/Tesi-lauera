# T3 — Modifica del contenuto di uno ZIP esistente

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante modifica il contenuto di un file ZIP già presente nella
repository — ad esempio sostituisce un file sorgente con una versione
malevola — senza aggiornare il .sig corrispondente.

## Prerequisiti
- Repository di test con almeno due commit legittimi
- Accesso in scrittura alla cartella della repository
- Strumento per modificare archivi ZIP

## Passi dell'attacco
1. Scegliere il file .zip da modificare
```bash
C:\Users\stemic\stage\simulazione>dir ..\repo

07/05/2026  14:24    <DIR>          .
07/05/2026  12:55    <DIR>          ..
07/05/2026  11:46               526 simulazione.0Q6PHT7QCI..{Michele}+documentazione.zip
07/05/2026  11:46               668 simulazione.0Q6PHT7QCI.sig
07/05/2026  11:46               562 simulazione.0Q6PHUAOSV.0Q6PHT7QCI.{Michele}+documentazione.zip
07/05/2026  11:46               774 simulazione.0Q6PHUAOSV.sig
07/05/2026  11:47               893 simulazione.0Q6PHV1YTU.0Q6PHUAOSV.{Michele}+documentazione.zip
07/05/2026  11:47               779 simulazione.0Q6PHV1YTU.sig
07/05/2026  11:48               619 simulazione.0Q6PHW0IJW.0Q6PHV1YTU.{Michele}+documentazione.zip
07/05/2026  11:48               779 simulazione.0Q6PHW0IJW.sig
07/05/2026  11:48               627 simulazione.0Q6PHWPMPQ.0Q6PHW0IJW.{Michele}+documentazione.zip
07/05/2026  11:48               786 simulazione.0Q6PHWPMPQ.sig
```

2. Aprire lo zip, modificare un file in modo arbitrario e ricompattare lo zip
```bash
C:\Users\stemic\stage\repo>mkdir temp_estrazione
C:\Users\stemic\stage\repo>tar -xf simulazione.0Q6PHV1YTU.0Q6PHUAOSV.{Michele}+documentazione.zip -C temp_estrazione
C:\Users\stemic\stage\repo>cd temp_estrazione
C:\Users\stemic\stage\repo\temp_estrazione>echo aggiunta di codice malevolo >> fileNuovo.txt
C:\Users\stemic\stage\repo\temp_estrazione>cd ..
C:\Users\stemic\stage\repo>tar -a -c -f simulazione.0Q6PHV1YTU.0Q6PHUAOSV.{Michele}+documentazione.zip -C temp_estrazione .
C:\Users\stemic\stage\repo>rmdir /s /q temp_estrazione
C:\Users\stemic\stage\repo>cd ..\simulazione
```

3. Avviare il verificatore 
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc integrity -signers="C:\Users\stemic\stage\allowed_signers"

Verifica integrita repository: tutti i progetti
allowed_signers: C:\Users\stemic\stage\allowed_signers

analyzing repository C:\Users\stemic\stage\repo\ ...
[OK]  0Q6PHT7QCI  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK  firma:OK  (Michele)
[ERR] 0Q6PHV1YTU  hash:FALLITO  catena:NON VERIFICABILE  firma:OK  (Michele)
       ERRORE: Hash ZIP non corrisponde
[ERR] 0Q6PHW0IJW  hash:OK  catena:FALLITO  firma:OK  (Michele)
       ERRORE:  CumulativeHash non corrisponde
[ERR] 0Q6PHWPMPQ  hash:OK  catena:FALLITO  firma:OK  (Michele)
       ERRORE:  CumulativeHash non corrisponde

Risultato: 3/5 commit con problemi.
Risultato: 0/5 commit con warning.
tot. exec time: 1.19 sec
```

## Risultato atteso
Il verificatore rileva [FAIL] hash:FAIL sul commit modificato e
[FAIL] catena:FAIL su tutti i commit successivi, poiché il
cumulativeHash dipende dall'hash del commit alterato.

## Risultato osservato (versione iniziale)
Come immaginato il verificatore nota la discrepanza tra l'hash all'interno del file sig del commit 0Q6PHV1YTU rispetto al suo hash reale dopo essere stato modificato.
A cascata vengono segnati come errori tutti i commit successivi collegati a quel commit.

## Analisi dell'impatto
La manomissione è possibile ma facilmente individuabile.
L'attaccante non ha possibilità di modificare un commit solamente alterando il file .zip.
L'attacco è rilevabile solamente dal verificatore.
Il motore a seguito di questa alterazione continua a lavorare senza anomalie.

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS01, RS02
- Proprietà violata: Integrità, Ordine verificabile