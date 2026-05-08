# T6 — Replay di un commit legittimo

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante copia un commit legittimo esistente — ZIP e .sig —
e lo reintroduce nella repository con un nuovo nome file, come se
fosse un commit nuovo. La firma è valida perché è quella originale,
ma il contenuto è duplicato.

## Prerequisiti
- Repository di test con almeno un commit legittimo firmato
- Accesso in scrittura alla cartella della repository

## Passi dell'attacco
1. Copiare ZIP e .sig di un commit legittimo e rinominarli
```bash
C:\Users\stemic\stage\repo>copy "simulazione.0Q6PHWPMPQ.0Q6PHW0IJW.{Michele}+documentazione.zip" "simulazione.0Q6PHWPZZZ.0Q6PHWPMPQ.{Michele}+documentazione.zip"
        1 file copiati.

C:\Users\stemic\stage\repo>copy simulazione.0Q6PHWPMPQ.sig simulazione.0Q6PHWPZZZ.sig
        1 file copiati.
```
2. Eseguire il verificatore
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
[ERR] 0Q6PHWPZZZ  hash:OK  catena:FALLITO  firma:OK  (Michele)
       ERRORE:  CumulativeHash non corrisponde

Risultato: 1/6 commit con problemi.
Risultato: 0/6 commit con warning.
tot. exec time: 1.52 sec
```

3. Eseguire il comando history
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc history
analyzing repository C:\Users\stemic\stage\repo\ ...

 = master-simulazione                                        simulazione                                               work       0Q6PHWPMPQ
 |   O master-simulazione                                    simulazione                          documentazione       0Q6PHWPZZZ 0Q6PHWPMPQ
 o---+                                                       simulazione                          documentazione       0Q6PHWPMPQ 0Q6PHW0IJW
 o                                                           simulazione                          documentazione       0Q6PHW0IJW 0Q6PHV1YTU
 o                                                           simulazione                          documentazione       0Q6PHV1YTU 0Q6PHUAOSV
 o                                                           simulazione                          documentazione       0Q6PHUAOSV 0Q6PHT7QCI
 o                                                           simulazione                          documentazione       0Q6PHT7QCI    

tot. exec time: 0.02 sec
```

## Risultato atteso
Il verificatore rileva [FAIL] catena:FAIL sul commit reintrodotto
poiché il prevId e prevHash nel .sig originale non corrispondono
alla posizione in cui è stato inserito. La firma risulta OK perché
è quella originale, ma la catena è interrotta.

## Risultato osservato (versione iniziale)
Il verificatore segnala errore poichè il cumulativeHash non risulta corretto.
E' possibile ricalcolare il cumulativeHash per non essere esgnalato dal verificatore.
Se viene eseguito questo attacco e viene ricalcolato il cumulativeHash il verificatore non segnala niente.
Questo attacco però comporta il fatto che non sia possibile alterare il contenuto dello zip altrimenti la firma non sarà più valida. Questo comporta il fatto che sempliecemente viene creato un nuovo nodo di simulando un nuovo branch ma con lo stesso nome.

## Analisi dell'impatto
L'attaccante non ha la possibilità di inserire codice malevolo o modificare commit già esistenti.
Può però duplicare o moltiplicare un commit creando agigungendo decine di branch con lo stesso nome del branch da cui era stato copiato il nodo e sporcando il contenuto della repo.

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS02, RS03
- Proprietà violata: Ordine verificabile