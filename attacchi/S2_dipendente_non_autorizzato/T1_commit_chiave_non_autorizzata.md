# T1 — Commit firmato da chiave non autorizzata

## Scenario padre
S2 — Dipendente con chiave SSH valida ma non autorizzato

## Descrizione
Il dipendente firma un commit con la propria chiave SSH valida su un
progetto a cui non dovrebbe avere accesso. Il motore non verifica se
la chiave del firmatario sia presente in una lista di autorizzati —
nella versione iniziale questa lista non esiste. Il commit viene
accettato senza obiezioni. Solo il verificatore, confrontando la chiave
usata per la firma con il file allowed_signers, rileva il problema.

## Prerequisiti
- Chiave SSH valida generata dal dipendente non autorizzato
- Accesso in scrittura alla cartella della repository
- File allowed_signers contenente solo le chiavi degli autorizzati
  (usato dal verificatore, non dal motore)

## Passi dell'attacco
1. Firmare e produrre un commit con la chiave del dipendente
   non autorizzato
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc commit -project=simulazione -tag=attaccante -author=Luigi -note=QuestoCommitFattoDaLuigi
Reading manifest, path:.\
Readed manifest, path:.\
packing C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RCTTRWQ.0Q6PHWPMPQ.{Luigi}+attaccante.zip
Starting scanner and collector ...
Scan excuted in 141 ms, collect in 0 ms tot:141 ms
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RCTTRWQ.0Q6PHWPMPQ.{Luigi}+attaccante.zip to C:\Users\stemic\stage\repo\ ...
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RCTTRWQ.sig to C:\Users\stemic\stage\repo\ ...
tot. exec time: 0.41 sec
```

2. Verificare che il commit sia stato accettato dal motore

```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc history
analyzing repository C:\Users\stemic\stage\repo\ ...

 = master-simulazione                                        simulazione                                               work       0Q6RCTTRWQ
 o                                                           simulazione                          attaccante           0Q6RCTTRWQ 0Q6PHWPMPQ
 o                                                           simulazione                          documentazione       0Q6PHWPMPQ 0Q6PHW0IJW
 o                                                           simulazione                          documentazione       0Q6PHW0IJW 0Q6PHV1YTU
 o                                                           simulazione                          documentazione       0Q6PHV1YTU 0Q6PHUAOSV
 o                                                           simulazione                          documentazione       0Q6PHUAOSV 0Q6PHT7QCI
 o                                                           simulazione                          documentazione       0Q6PHT7QCI    
tot. exec time: 0.02 sec
```

3. Tentare operazioni normali sul progetto — history, lettura

4. Eseguire il verificatore con il file allowed_signers corretto

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
[ERR] 0Q6RCTTRWQ  hash:OK  catena:OK  firma:FALLITA  (Luigi)
       ERRORE:  Firma SSH non valida

Risultato: 1/6 commit con problemi.
Risultato: 0/6 commit con warning.
tot. exec time: 1.72 sec
```

## Risultato atteso
Il motore accetta il commit senza avvisi. Il verificatore segnala
[FAIL] firma:FAIL o un avviso equivalente poiché la chiave usata
per la firma non è presente nell'allowed_signers. Le operazioni
normali del motore non producono nessun segnale di anomalia.

## Risultato osservato (versione iniziale)
Il motore non da alcun segnale di errore, accetta il commit e lo firma.
Il motore continua a funzionare normalmente e i comandi non alzano eccezzioni o errori.
Il verificatore è l'unico che segna errore poichè la chiave di Luigi non è presente tra gli allowed_signers

## Analisi dell'impatto
L'attaccante può effettuare commit senza problemi e gli altri utenti se non verificano l'integrità non notano nulla di strano.
Il verificatore lo vede e non è possibile per l'attaccante non far vedere l'errore.

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS07, RS08
- Proprietà violata: Autorizzazione