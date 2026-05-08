# T10 — Iniezione di una repository fasulla

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante crea da zero una repository completa con una catena
di commit non firmati, strutturalmente valida dal punto di vista
degli hash, e tenta di farla passare come repository legittima.
Questo scenario tocca direttamente il problema della radice di
fiducia — senza un primo commit firmato da un'autorità verificabile,
non c'è modo di distinguere una repository legittima da una fasulla.

## Prerequisiti
- Nessuna — l'attaccante parte da zero
- Nessuna chiave SSH

## Passi dell'attacco
1. Creare una nuova directory come repository fasulla
2. Produrre una catena di commit con hash e cumulativeHash
   calcolati correttamente ma senza firme SSH
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc commit -project=simulazione -tag=Documentazione -note=MoltoImportante -repo=C:\Users\stemic\stage\repo
packing C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6R82GADL..+Documentazione.zip
Starting scanner and collector ...
Scan excuted in 219 ms, collect in 0 ms tot:219 ms
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6R82GADL..+Documentazione.zip to C:\Users\stemic\stage\repo\ ...
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6R82GADL.sig to C:\Users\stemic\stage\repo\ ...
tot. exec time: 0.25 sec

C:\Users\stemic\stage\simulazione>echo aggiunto codice >> file.txt

C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc commit -project=simulazione -tag=Documentazione -note=MoltoImportante -repo=C:\Users\stemic\stage\repo
Reading manifest, path:.\
Readed manifest, path:.\
packing C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6R832YWQ.0Q6R82GADL.+Documentazione.zip
Starting scanner and collector ...
Scan excuted in 156 ms, collect in 0 ms tot:156 ms
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6R832YWQ.0Q6R82GADL.+Documentazione.zip to C:\Users\stemic\stage\repo\ ...
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6R832YWQ.sig to C:\Users\stemic\stage\repo\ ...
tot. exec time: 0.19 sec

C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc commit -project=simulazione -tag=Documentazione -note=MoltoImportante
Reading manifest, path:.\
Readed manifest, path:.\
packing C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6R83HVQD.0Q6R832YWQ.+Documentazione.zip
Starting scanner and collector ...
Scan excuted in 140 ms, collect in 0 ms tot:140 ms
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6R83HVQD.0Q6R832YWQ.+Documentazione.zip to C:\Users\stemic\stage\repo\ ...
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6R83HVQD.sig to C:\Users\stemic\stage\repo\ ...
tot. exec time: 0.16 sec

C:\Users\stemic\stage\simulazione>echo aggiunto codice >> fileNuovo.txt

C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc commit -project=simulazione -tag=Documentazione -note=MoltoImportante
Reading manifest, path:.\
Readed manifest, path:.\
packing C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6R83ULIB.0Q6R83HVQD.+Documentazione.zip
Starting scanner and collector ...
Scan excuted in 156 ms, collect in 0 ms tot:156 ms
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6R83ULIB.0Q6R83HVQD.+Documentazione.zip to C:\Users\stemic\stage\repo\ ...
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6R83ULIB.sig to C:\Users\stemic\stage\repo\ ...
tot. exec time: 0.16 sec

C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc commit -project=simulazione -tag=Documentazione -note=MoltoImportante
Reading manifest, path:.\
Readed manifest, path:.\
packing C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6R844SKJ.0Q6R83ULIB.+Documentazione.zip
Starting scanner and collector ...
Scan excuted in 140 ms, collect in 0 ms tot:140 ms
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6R844SKJ.0Q6R83ULIB.+Documentazione.zip to C:\Users\stemic\stage\repo\ ...
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6R844SKJ.sig to C:\Users\stemic\stage\repo\ ...
tot. exec time: 0.17 sec
```

3. Distribuire la repository fasulla come se fosse legittima

4. Eseguire il verificatore sulla repository fasulla

```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc integrity -signers="C:\Users\stemic\stage\allowed_signers"

Verifica integrita repository: tutti i progetti
allowed_signers: C:\Users\stemic\stage\allowed_signers

analyzing repository C:\Users\stemic\stage\repo\ ...
[WARN] 0Q6R82GADL  hash:OK  catena:OK  firma:ASSENTE  (?)
[WARN] 0Q6R832YWQ  hash:OK  catena:OK  firma:ASSENTE  (?)
[WARN] 0Q6R83HVQD  hash:OK  catena:OK  firma:ASSENTE  (?)
[WARN] 0Q6R83ULIB  hash:OK  catena:OK  firma:ASSENTE  (?)
[WARN] 0Q6R844SKJ  hash:OK  catena:OK  firma:ASSENTE  (?)

Risultato: 0/5 commit con problemi.
Risultato: 5/5 commit con warning.
tot. exec time: 0.03 sec
```
C:\Users\stemic\stage\simulazione>
5. Confrontare l'output con quello della repository legittima
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
tot. exec time: 1.30 sec
```

## Risultato atteso
Il verificatore segnala [WARN] firma:ASSENTE su tutti i commit
ma non rileva errori critici — la catena degli hash è
strutturalmente valida. Non esiste nessun meccanismo nella
versione iniziale per distinguere questa repository da una
legittima. Questo dimostra direttamente l'assenza di RS05.

## Risultato osservato (versione iniziale)
Come era stato previsto il verificatore accetta la repository segnalando sempicemente dei warning.
Questo comporta che in una repo dove nessuno firma, i suoi commit sarebbero irrintracciabili e non distinguibili da commit eseguiti da persone fidate.

## Analisi dell'impatto
Un attaccante può distribuire codice arbitrario
in una repository che supera tutti i controlli strutturali del
verificatore. Senza radice di fiducia verificabile, l'intera
catena degli hash garantisce solo la coerenza interna della
repository fasulla, non la sua legittimità.

## Contromisura implementata
[da compilare — questa è la motivazione principale di RS05
e del progetto _rvc_root nel modello proposto]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS05
- Proprietà violata: Autenticità, Radice di fiducia