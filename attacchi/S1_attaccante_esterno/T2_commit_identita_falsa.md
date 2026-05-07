# T2 — Commit con identità falsa

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante produce un commit senza firma shh dichiarando però il campo author. Poiché non c'è firma crittografica, il campo author nel .sig non è verificabile e può contenere qualsiasi valore.

## Prerequisiti
- Repository di test con almeno un commit legittimo firmato
- Nessuna chiave SSH

## Passi dell'attacco
1. Avviare il verificatore per vedere le identità valide per firmare i commit
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

Risultato: 0/5 commit con problemi.
Risultato: 0/5 commit con warning.
tot. exec time: 1.02 sec
```

2. Eseguire una modifica arbitraria
```bash
C:\Users\stemic\stage\simulazione>echo Aggiunto testo malevolo >> fileSuperPrivato.txt
C:\Users\stemic\stage\simulazione>type fileSuperPrivato.txt
Aggiunto testo malevolo
```

3. Effettuare un commit specificando come autore uno tra gli autori autorizzati
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc commit -project=simulazione -tag=Produzione -note=MoltoImportante -author=Michele
Reading manifest, path:.\
Readed manifest, path:.\
packing C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6PK4VQQR.0Q6PHWPMPQ.{Michele}+Produzione.zip
Starting scanner and collector ...
Scan excuted in 109 ms, collect in 0 ms tot:109 ms
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6PK4VQQR.0Q6PHWPMPQ.{Michele}+Produzione.zip to C:\Users\stemic\stage\repo\ ...
ERRORE: chiave privata non trovata ne in rvc.config ne in identities\
La commit e stata salvata senza firma SSH.
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6PK4VQQR.sig to C:\Users\stemic\stage\repo\ ...
tot. exec time: 0.14 sec
```

4. Controllare che il commit sia andato a buon fine
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc history
analyzing repository C:\Users\stemic\stage\repo\ ...

 = master-simulazione                                        simulazione                                               work       0Q6PK4VQQR
 o                                                           simulazione                          Produzione           0Q6PK4VQQR 0Q6PHWPMPQ
 o                                                           simulazione                          documentazione       0Q6PHWPMPQ 0Q6PHW0IJW
 o                                                           simulazione                          documentazione       0Q6PHW0IJW 0Q6PHV1YTU
 o                                                           simulazione                          documentazione       0Q6PHV1YTU 0Q6PHUAOSV
 o                                                           simulazione                          documentazione       0Q6PHUAOSV 0Q6PHT7QCI
 o                                                           simulazione                          documentazione       0Q6PHT7QCI    

tot. exec time: 0.01 sec
```

5. Avviare il verificatore
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
[WARN] 0Q6PK4VQQR  hash:OK  catena:OK  firma:ASSENTE  (Michele)

Risultato: 0/6 commit con problemi.
Risultato: 1/6 commit con warning.
tot. exec time: 1.02 sec
```

## Risultato atteso
E' possibile effettuare qualunque commit.
Il motore effettua la commit senza alcun avviso.
Il verificatore segnala uno warning perchè manca la firma ma mostra il nome dell'autore.
Il contatore degli errori critici rimane a zero.
Tutte le operazioni del motore successive al commit non segnano
alcun errore e il motore si comporta normalmente. 

## Risultato osservato (versione iniziale)
Il motore accetta il commit. Il verificatore segnala [WARN] firma:ASSENTE.
Il contatore degli errori critici rimane a zero.
E' la stessa risposta al T1_commit_senza_firma.

## Analisi dell'impatto
Un attaccante può inserire commit non firmati senza che il motore lo noti o segnali.
Così facendo può modificare codice e aggiungere commit con nel campo author presente il nome di un autore autorizzato.
E' rilevabile solo tramite verificatore.

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS06
- Proprietà violata: Autenticità, Non ripudio