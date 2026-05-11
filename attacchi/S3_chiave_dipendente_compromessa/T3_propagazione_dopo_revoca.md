# T3 — Propagazione nella catena dopo la revoca

## Scenario padre
S3 — Chiave privata di un dipendente compromessa

## Descrizione
Dopo che la chiave compromessa viene rimossa dall'allowed_signers,
il verificatore rieseguito sull'intera storia mostra due
comportamenti distinti a seconda del file used: con
allowed_signers_con_chiave i commit fraudolenti risultano validi,
con allowed_signers_senza_chiave risultano FAIL. Questo dimostra
la differenza tra il verificatore attuale — che usa una lista
statica — e il modello proposto — dove ogni commit porta la
lista valida al momento della firma.

L'obiettivo è documentare che i commit fraudolenti rimangono
nella catena e sono identificabili tramite analisi manuale
della storia nel periodo sospetto, come descritto nel modello.

## Prerequisiti
- Repository con commit legittimi e commit fraudolenti prodotti
  durante la simulazione di T2
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc history
analyzing repository C:\Users\stemic\stage\repo\ ...

 = master-simulazione                                        simulazione                                               work       0Q6WTKCDJL
 o                                                           simulazione                          produzione           0Q6WTKCDJL 0Q6WTK5GET
 o                                                           simulazione                          produzione           0Q6WTK5GET 0Q6WRGCMHR
 o                                                           simulazione                          produzione           0Q6WRGCMHR 0Q6PHWPMPQ
 o                                                           simulazione                          documentazione       0Q6PHWPMPQ 0Q6PHW0IJW
 o                                                           simulazione                          documentazione       0Q6PHW0IJW 0Q6PHV1YTU
 o                                                           simulazione                          documentazione       0Q6PHV1YTU 0Q6PHUAOSV
 o                                                           simulazione                          documentazione       0Q6PHUAOSV 0Q6PHT7QCI
 o                                                           simulazione                          documentazione       0Q6PHT7QCI    
tot. exec time: 0.01 sec
```
- File allowed_signers_con_chiave e allowed_signers_senza_chiave

## Passi dell'attacco
1. Partire dalla repository prodotta in T2 con commit misti
   legittimi e fraudolenti
2. Eseguire il verificatore con allowed_signers_con_chiave —
   documentare quali commit risultano validi
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
[OK]  0Q6WRGCMHR  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6WTK5GET  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6WTKCDJL  hash:OK  catena:OK  firma:OK  (Michele)

Risultato: 0/8 commit con problemi.
Risultato: 0/8 commit con warning.
tot. exec time: 1.78 sec
```
3. Eseguire il verificatore con allowed_signers_senza_chiave —
   documentare quali commit risultano FAIL
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
[ERR] 0Q6WRGCMHR  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6WTK5GET  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6WTKCDJL  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida

Risultato: 8/8 commit con problemi.
Risultato: 0/8 commit con warning.
tot. exec time: 1.86 sec
```
4. Confrontare i due output e identificare i commit fraudolenti
5. Verificare che la catena degli hash rimanga intatta
   indipendentemente dalla validità delle firme

## Risultato atteso
Con allowed_signers_con_chiave: tutti i commit risultano [OK]
inclusi quelli fraudolenti — la catena è integra e le firme
sono valide rispetto alla lista che include la chiave.
Con allowed_signers_senza_chiave: i commit fraudolenti
risultano [FAIL] firma, quelli legittimi rimangono [OK].
La catena degli hash risulta intatta in entrambi i casi —
i commit fraudolenti non hanno alterato la struttura
crittografica della storia.

Questo evidenzia la limitazione del verificatore attuale
rispetto al modello proposto e dimostra perché l'allowed_Dipendenti
interno a ogni commit è una scelta architetturale necessaria.

## Risultato osservato (versione iniziale)
Si può vedere come usando un file statico di allowed_signer alla modifica del file stesso tutte le firme risultano Ok o errate in contemporanea.
La catena degli hash risulta corretta perchè i commit essendo stati generati con la chiave reale compromessa risultano comunque corretti.

## Analisi dell'impatto
Con questo verificatore è difficile simulare il comportamento desiderato. L'impatto comunque sarebbe altissimo perchè la manomissione non è rilevabile nè da motore nè da verificatore in modo automatico. L'unica contromisura è solo con un controllo manuale del codice committato e da un rinnovo continuo delle chiavi.


## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito coinvolto: RS09
- Proprietà violata: Autenticità, Non ripudio
- Limitazione documentata: differenza tra verificatore attuale
  e modello proposto nella gestione della revoca retroattiva