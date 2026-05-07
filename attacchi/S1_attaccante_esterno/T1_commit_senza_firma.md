# T1 — Commit senza firma

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante produce un commit normale tramite il motore RVC senza
fornire un autore. Il commit viene accettato dal motore perché
nella versione iniziale la firma è opzionale.

## Prerequisiti
- Repository di test con almeno un commit legittimo firmato
- Nessuna chiave SSH

## Passi dell'attacco
- Eseguire una modifica arbitraria
```bash
C:\Users\stemic\stage\simulazione>echo Aggiunto testo malevolo >> fileSuperPrivato.txt
C:\Users\stemic\stage\simulazione>type fileSuperPrivato.txt
Aggiunto testo malevolo
```

- Fare la commit senza specificare l'autore
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc commit -project=simulazione -tag=Produzione -note=MoltoImportante
Reading manifest, path:.\
Readed manifest, path:.\
packing C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6PI7VZWV.0Q6PHWPMPQ.+Produzione.zip
Starting scanner and collector ...
Scan excuted in 218 ms, collect in 0 ms tot:218 ms
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6PI7VZWV.0Q6PHWPMPQ.+Produzione.zip to C:\Users\stemic\stage\repo\ ...
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6PI7VZWV.sig to C:\Users\stemic\stage\repo\ ...
tot. exec time: 0.23 sec
```

- Controllare che la commit sia andata a buon fine
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc history
analyzing repository C:\Users\stemic\stage\repo\ ...

 = master-simulazione                                        simulazione                                               work       0Q6PI7VZWV
 o                                                           simulazione                          Produzione           0Q6PI7VZWV 0Q6PHWPMPQ
 o                                                           simulazione                          documentazione       0Q6PHWPMPQ 0Q6PHW0IJW
 o                                                           simulazione                          documentazione       0Q6PHW0IJW 0Q6PHV1YTU
 o                                                           simulazione                          documentazione       0Q6PHV1YTU 0Q6PHUAOSV
 o                                                           simulazione                          documentazione       0Q6PHUAOSV 0Q6PHT7QCI
 o                                                           simulazione                          documentazione       0Q6PHT7QCI    

tot. exec time: 0.01 sec
```

Avviare il verificatore
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
[WARN] 0Q6PI7VZWV  hash:OK  catena:OK  firma:ASSENTE  (?)

Risultato: 0/6 commit con problemi.
Risultato: 1/6 commit con warning.
tot. exec time: 1.17 sec
```

## Risultato atteso
Il motore accetta il commit. Il verificatore segnala [WARN] firma:ASSENTE.
Il contatore degli errori critici rimane a zero.

## Risultato osservato (versione iniziale)
Il motore effettua la commit senza alcun avviso.
Il verificatore segnala uno warning perchè manca la firma.
Il contatore degli errori critici rimane a zero.
Tutte le operazioni del motore successive al commit non segnano
alcun errore e il motore si comporta normalmente. 

## Analisi dell'impatto
Un attaccante può inserire commit non firmati senza che il motore lo noti o segnali.
Così facendo può modificare codice e aggiungere commit.
E' rilevabile solo tramite verificatore.

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS06
- Proprietà violata: Autenticità, Non ripudio
