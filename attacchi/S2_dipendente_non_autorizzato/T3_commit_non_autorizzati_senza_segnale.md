# T3 — Volume di commit non autorizzati senza rilevamento operativo

## Scenario padre
S2 — Dipendente con chiave SSH valida ma non autorizzato

## Descrizione
Il dipendente produce una serie di commit firmati con la propria chiave
su un progetto non autorizzato nel corso del tempo. L'obiettivo non è
un singolo attacco puntuale ma dimostrare che il motore non emette mai
nessun segnale operativo durante le operazioni normali — history, commit,
lettura — indipendentemente dal numero di commit non autorizzati presenti.
Solo una verifica esplicita con il verificatore rivela il problema.
Questo dimostra che l'assenza di RS07 e RS08 non produce nessun
indicatore visibile senza strumenti dedicati.

## Prerequisiti
- Chiave SSH valida del dipendente non autorizzato
- Accesso in scrittura alla cartella della repository

## Passi dell'attacco
1. Produrre almeno 3 commit firmati con la chiave non autorizzata
   in momenti diversi
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc commit -project=simulazione -tag=attaccante -author=Luigi -note=QuestoCommitFattoDaLuigi
Reading manifest, path:.\
Readed manifest, path:.\
packing C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RLK7XSL.0Q6PHWPMPQ.{Luigi}+attaccante.zip
Starting scanner and collector ...
Scan excuted in 188 ms, collect in 0 ms tot:188 ms
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RLK7XSL.0Q6PHWPMPQ.{Luigi}+attaccante.zip to C:\Users\stemic\stage\repo\ ...
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RLK7XSL.sig to C:\Users\stemic\stage\repo\ ...
tot. exec time: 0.47 sec

C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc commit -project=simulazione -tag=attaccante -author=Luigi -note=QuestoCommitFattoDaLuigi
Reading manifest, path:.\
Readed manifest, path:.\
packing C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RLK9DFH.0Q6RLK7XSL.{Luigi}+attaccante.zip
Starting scanner and collector ...
Scan excuted in 141 ms, collect in 0 ms tot:141 ms
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RLK9DFH.0Q6RLK7XSL.{Luigi}+attaccante.zip to C:\Users\stemic\stage\repo\ ...
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RLK9DFH.sig to C:\Users\stemic\stage\repo\ ...
tot. exec time: 0.41 sec

C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc commit -project=simulazione -tag=attaccante -author=Luigi -note=QuestoCommitFattoDaLuigi
Reading manifest, path:.\
Readed manifest, path:.\
packing C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RLKAHPC.0Q6RLK9DFH.{Luigi}+attaccante.zip
Starting scanner and collector ...
Scan excuted in 125 ms, collect in 0 ms tot:125 ms
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RLKAHPC.0Q6RLK9DFH.{Luigi}+attaccante.zip to C:\Users\stemic\stage\repo\ ...
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RLKAHPC.sig to C:\Users\stemic\stage\repo\ ...
tot. exec time: 0.42 sec

C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc commit -project=simulazione -tag=attaccante -author=Luigi -note=QuestoCommitFattoDaLuigi
Reading manifest, path:.\
Readed manifest, path:.\
packing C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RLKCNCY.0Q6RLKAHPC.{Luigi}+attaccante.zip
Starting scanner and collector ...
Scan excuted in 141 ms, collect in 0 ms tot:141 ms
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RLKCNCY.0Q6RLKAHPC.{Luigi}+attaccante.zip to C:\Users\stemic\stage\repo\ ...
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RLKCNCY.sig to C:\Users\stemic\stage\repo\ ...
tot. exec time: 0.44 sec
```

2. Dopo ogni commit eseguire operazioni normali — history, lettura,
   nuovo commit
3. Eseguire il verificatore solo alla fine dell'intera sequenza
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
[ERR] 0Q6RLK7XSL  hash:OK  catena:OK  firma:FALLITA  (Luigi)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6RLK9DFH  hash:OK  catena:OK  firma:FALLITA  (Luigi)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6RLKAHPC  hash:OK  catena:OK  firma:FALLITA  (Luigi)
       ERRORE:  Firma SSH non valida
[ERR] 0Q6RLKCNCY  hash:OK  catena:OK  firma:FALLITA  (Luigi)
       ERRORE:  Firma SSH non valida

Risultato: 4/9 commit con problemi.
Risultato: 0/9 commit con warning.
tot. exec time: 2.45 sec
```
## Risultato atteso
Il motore non emette nessun avviso durante nessuna delle operazioni
normali, indipendentemente dal numero di commit non autorizzati
presenti nella repository. Il verificatore, eseguito esplicitamente
alla fine, rileva tutti i commit non autorizzati in una singola
analisi. Questo evidenzia la dipendenza da una verifica attiva e
periodica in assenza di controlli preventivi del motore.

## Risultato osservato (versione iniziale)
Il motore esegue tutte le operazioni di commit e di history senza segnalare alcun tipo di problema.
Solo il verificatore vede la discrepanza tra le chiavi usate.

## Analisi dell'impatto
E' possibile sporcare una repository e far firmare ad altri commit successive se non dovesse essere eseguita l'integrità della repo ad ogni commit.

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS07, RS08
- Proprietà violata: Autorizzazione