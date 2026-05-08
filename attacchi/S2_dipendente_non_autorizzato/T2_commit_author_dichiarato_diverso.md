# T2 — Commit firmato con author dichiarato diverso dal firmatario

## Scenario padre
S2 — Dipendente con chiave SSH valida ma non autorizzato

## Descrizione
Il dipendente firma il commit con la propria chiave SSH ma dichiara
nel campo author il nome o l'identificativo di un collega autorizzato.
Il motore accetta il commit perché la firma è crittograficamente valida.
Il verificatore rileva la discrepanza tra l'author dichiarato nel .sig
e la chiave effettivamente usata per la firma — i due non corrispondono.
Questo dimostra che senza RS07 l'identità dichiarata e quella
crittografica possono divergere senza nessun blocco preventivo.

## Prerequisiti
- Chiave SSH valida del dipendente non autorizzato
- Conoscenza dell'identificativo o del nome di un collega autorizzato
- Accesso in scrittura alla cartella della repository

## Passi dell'attacco
1. Produrre un commit dichiarando come author il nome di un
   collega autorizzato
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc commit -project=simulazione -tag=attaccante -author=Michele -note=QuestoCommitFattoDaLuigiSottoNomeDiMichele
Reading manifest, path:.\
Readed manifest, path:.\
packing C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RJWRDEU.0Q6PHWPMPQ.{Michele}+attaccante.zip
Starting scanner and collector ...
Scan excuted in 188 ms, collect in 0 ms tot:188 ms
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RJWRDEU.0Q6PHWPMPQ.{Michele}+attaccante.zip to C:\Users\stemic\stage\repo\ ...
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6RJWRDEU.sig to C:\Users\stemic\stage\repo\ ...
tot. exec time: 0.50 sec
```

2. Verificare che il commit sia stato accettato dal motore
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc history
analyzing repository C:\Users\stemic\stage\repo\ ...
 = master-simulazione                                        simulazione                                               work       0Q6RJWRDEU
 o                                                           simulazione                          attaccante           0Q6RJWRDEU 0Q6PHWPMPQ
 o                                                           simulazione                          documentazione       0Q6PHWPMPQ 0Q6PHW0IJW
 o                                                           simulazione                          documentazione       0Q6PHW0IJW 0Q6PHV1YTU
 o                                                           simulazione                          documentazione       0Q6PHV1YTU 0Q6PHUAOSV
 o                                                           simulazione                          documentazione       0Q6PHUAOSV 0Q6PHT7QCI
 o                                                           simulazione                          documentazione       0Q6PHT7QCI    
tot. exec time: 0.02 sec
```

3. Eseguire il verificatore con il file allowed_signers corretto

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
[ERR] 0Q6RJWRDEU  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida

Risultato: 1/6 commit con problemi.
Risultato: 0/6 commit con warning.
tot. exec time: 1.76 sec
```

## Risultato atteso
Il motore accetta il commit. Il verificatore rileva che la firma
non corrisponde all'author dichiarato — la chiave usata per la firma
appartiene a un soggetto diverso da quello indicato nel campo author.
Senza il verificatore il commit è indistinguibile da uno legittimo
prodotto dal collega.

## Risultato osservato (versione iniziale)
Il motore non alza eccezzioni e non nota nessuna discrepanza.
I lverificatore invece da errore poichè la firma con la chiave privata usata per firmare fallisce il controllo contro la chiave pubblica presente nel file allowed_signers.

## Analisi dell'impatto
L'attaccante può eseguire commit firmando con la sua chiave privata e mettendo il nome di chiunque.
Al motore ciò non crea problemi.
Il verificatore nota la discrepanza quando confronta la firma con la chiave pubblica presente nel file allowed_signers.
Il rischio importante esiste nelle repo dove non viene eseguito il verificatore per le firme ssh ma basta la presenza di una qualunque firma.

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS07, RS08
- Proprietà violata: Autenticità, Autorizzazione