# T8 — Troncamento della catena

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante elimina fisicamente uno o più commit dalla repository
cancellando i file ZIP e .sig corrispondenti, creando un buco
nella catena.

## Prerequisiti
- Repository di test con almeno tre commit legittimi
- Accesso in scrittura alla cartella della repository

## Passi dell'attacco
1. Identificare uno o più commit da eliminare che non siano l'ultimo della catena
```bash
C:\Users\stemic\stage\repo>dir
07/05/2026  11:46               526 simulazione.0Q6PHT7QCI..{Michele}+documentazione.zip
07/05/2026  11:46               668 simulazione.0Q6PHT7QCI.sig
07/05/2026  11:46               562 simulazione.0Q6PHUAOSV.0Q6PHT7QCI.{Michele}+documentazione.zip
07/05/2026  11:46               774 simulazione.0Q6PHUAOSV.sig
07/05/2026  11:47               575 simulazione.0Q6PHV1YTU.0Q6PHUAOSV.{Michele}+documentazione.zip
07/05/2026  11:47               779 simulazione.0Q6PHV1YTU.sig
07/05/2026  11:48               619 simulazione.0Q6PHW0IJW.0Q6PHV1YTU.{Michele}+documentazione.zip
07/05/2026  11:48               779 simulazione.0Q6PHW0IJW.sig
07/05/2026  11:48               627 simulazione.0Q6PHWPMPQ.0Q6PHW0IJW.{Michele}+documentazione.zip
07/05/2026  11:48               786 simulazione.0Q6PHWPMPQ.sig
```
2. Cancellare i file ZIP e .sig corrispondenti
```bash
C:\Users\stemic\stage\repo>del "simulazione.0Q6PHV1YTU.0Q6PHUAOSV.{Michele}+documentazione.zip"
C:\Users\stemic\stage\repo>del simulazione.0Q6PHV1YTU.sig
```
3. Eseguire il verificatore
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc integrity -signers="C:\Users\stemic\stage\allowed_signers"

Verifica integrita repository: tutti i progetti
allowed_signers: C:\Users\stemic\stage\allowed_signers

analyzing repository C:\Users\stemic\stage\repo\ ...
[OK]  0Q6PHT7QCI  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK  firma:OK  (Michele)
[ERR] 0Q6PHW0IJW  hash:OK  catena:FALLITO  firma:OK  (Michele)
       ERRORE:  CumulativeHash non corrisponde
[ERR] 0Q6PHWPMPQ  hash:OK  catena:FALLITO  firma:OK  (Michele)
       ERRORE:  CumulativeHash non corrisponde

Risultato: 2/4 commit con problemi.
Risultato: 0/4 commit con warning.
tot. exec time: 0.95 sec
```
4. Tentare operazioni normali sul progetto (commit, lettura)
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc history
analyzing repository C:\Users\stemic\stage\repo\ ...

 = master-simulazione                                        simulazione                                               work       0Q6PHWPMPQ
 o                                                           simulazione                          documentazione       0Q6PHWPMPQ 0Q6PHW0IJW
 o                                                           simulazione                          documentazione       0Q6PHW0IJW 0Q6PHV1YTU
 |   O master-simulazione                                    simulazione                          documentazione       0Q6PHUAOSV 0Q6PHT7QCI
 |   o                                                       simulazione                          documentazione       0Q6PHT7QCI
 |
 :
tot. exec time: 0.00 sec
```
C:\Users\stemic\stage\simulazione>

## Risultato atteso
Il verificatore rileva la discontinuità nella catena — il commit
successivo a quelli eliminati ha un prevId che non corrisponde
a nessun commit presente. Da verificare come reagisce il motore
durante le operazioni normali.

## Risultato osservato (versione iniziale)
Il verificatore da errore poichè non trova i prevhash e quindi pensa che siano commit iniziali.
Questo viene rispecchiato anche dalla history della repo dopo aver effettuato le modifiche.

## Analisi dell'impatto
Con questa tecnica l'attacante non può fare niente a causa degli errori generati dai commit di coda lasciati senza predecessori.
Viene rilevato questo problema solo dal verificatore.

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS02
- Proprietà violata: Integrità, Ordine verificabile