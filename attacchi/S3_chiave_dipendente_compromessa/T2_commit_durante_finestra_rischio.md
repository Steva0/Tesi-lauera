# T2 — Commit fraudolenti durante la finestra di rischio

## Scenario padre
S3 — Chiave privata di un dipendente compromessa

## Descrizione
L'attaccante produce più commit nell'intervallo tra la
compromissione della chiave e la sua revoca dall'allowed_signers.
Questo dimostra concretamente la finestra di rischio descritta
nel modello — tutti i commit prodotti in questo intervallo
risultano validi al verificatore eseguito con
allowed_signers_con_chiave, e rimangono nella storia anche
dopo la revoca.

## Prerequisiti
- Chiave privata SSH del dipendente compromesso
- File allowed_signers_con_chiave e allowed_signers_senza_chiave
- Repository di test nello stato iniziale pulito

## Passi dell'attacco
1. Produrre 3 commit fraudolenti firmati con la chiave rubata
   simulando la finestra di rischio
```bash
C:\Users\stemic\stage\simulazione>echo "Contenuto codice malevolo" >> fileSuperPrivato.txt

C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc commit -project=simulazione -tag=produzione -author=Michele -note=CommitFattoDaQulcunaltro
Reading manifest, path:.\
Readed manifest, path:.\
packing C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6WRGCMHR.0Q6PHWPMPQ.{Michele}+produzione.zip
Starting scanner and collector ...
Scan excuted in 109 ms, collect in 0 ms tot:109 ms
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6WRGCMHR.0Q6PHWPMPQ.{Michele}+produzione.zip to C:\Users\stemic\stage\repo\ ...
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6WRGCMHR.sig to C:\Users\stemic\stage\repo\ ...
tot. exec time: 0.33 sec

C:\Users\stemic\stage\simulazione>echo "Contenuto codice malevolo" >> fileSuperPrivato.txt

C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc commit -project=simulazione -tag=produzione -author=Michele -note=CommitFattoDaQulcunaltro
Reading manifest, path:.\
Readed manifest, path:.\
packing C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6WTK5GET.0Q6WRGCMHR.{Michele}+produzione.zip
Starting scanner and collector ...
Scan excuted in 156 ms, collect in 0 ms tot:156 ms
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6WTK5GET.0Q6WRGCMHR.{Michele}+produzione.zip to C:\Users\stemic\stage\repo\ ...
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6WTK5GET.sig to C:\Users\stemic\stage\repo\ ...
tot. exec time: 0.39 sec

C:\Users\stemic\stage\simulazione>echo "Contenuto codice malevolo" >> fileSuperPrivato.txt

C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc commit -project=simulazione -tag=produzione -author=Michele -note=CommitFattoDaQulcunaltro
Reading manifest, path:.\
Readed manifest, path:.\
packing C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6WTKCDJL.0Q6WTK5GET.{Michele}+produzione.zip
Starting scanner and collector ...
Scan excuted in 110 ms, collect in 0 ms tot:110 ms
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6WTKCDJL.0Q6WTK5GET.{Michele}+produzione.zip to C:\Users\stemic\stage\repo\ ...
copying C:\ProgramData\spr\STEMIC\rvc\simulazione.0Q6WTKCDJL.sig to C:\Users\stemic\stage\repo\ ...
tot. exec time: 0.31 sec
```

2. Eseguire il verificatore con allowed_signers_con_chiave —
   tutti i commit risultano validi
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
3. Simulare la revoca aggiornando l'allowed_signers rimuovendo
   la chiave compromessa
4. Eseguire il verificatore con allowed_signers_senza_chiave —
   documentare il comportamento sui commit prodotti prima
   della revoca
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
## Risultato atteso
Con allowed_signers_con_chiave: tutti i commit fraudolenti
risultano [OK] — erano firmati da una chiave autorizzata
al momento della firma.
Con allowed_signers_senza_chiave: i commit fraudolenti
risultano [FAIL] firma — il verificatore usa la lista
aggiornata e non riconosce più la chiave.

Nota: questo comportamento differisce dal modello proposto,
dove ogni commit porta il proprio allowed_Dipendenti interno.
Nel modello proposto i commit prodotti prima della revoca
rimarrebbero validi perché la lista al momento della firma
includeva la chiave. Il verificatore attuale non distingue
tra "chiave valida al momento della firma" e "chiave valida
ora" — limitazione documentata come motivazione per il
modello proposto.

## Risultato osservato (versione iniziale)
I commit vengono correttamente eseguiti e visualizzati.
Passano i controlli del verificatore.
Al cambio del file allowed_signers risultano tutti ERR. Questo differisce dal modo in cui il modello dovrebbe funzionare perchè al momento il verificatore usa un file statico esterno ai commit mentre il modello prevedere l'uso di un file allowed_signers interno al commit e quindi immutabile.

## Analisi dell'impatto
L'attaccante ha piena possibilità di commitare.
Questa possibilità di attacco è di altissimo impatto.
Non è rilevabile nè da motore nè da verificatore in modo automatico. L'unica contromisura è solo con un controllo manuale del codice committato e da un rinnovo continuo delle chiavi.

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito coinvolto: RS09
- Proprietà violata: Autenticità, Integrità della storia