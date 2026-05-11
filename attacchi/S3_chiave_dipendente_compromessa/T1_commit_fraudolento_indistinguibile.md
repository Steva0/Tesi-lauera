# T1 — Commit fraudolento indistinguibile dal legittimo

## Scenario padre
S3 — Chiave privata di un dipendente compromessa

## Descrizione
L'attaccante produce un commit firmato con la chiave rubata del
dipendente legittimo. Il verificatore eseguito con
allowed_signers_con_chiave segnala il commit come completamente
valido — hash OK, catena OK, firma OK — perché la chiave è quella
corretta e il firmatario è nell'allowed_signers. Non esiste nessun
meccanismo automatico per distinguere questo commit da uno
legittimo prodotto dal dipendente reale.

## Prerequisiti
- Chiave privata SSH del dipendente compromesso
- File allowed_signers_con_chiave contenente la chiave compromessa
- Repository di test nello stato iniziale pulito

## Passi dell'attacco
1. Produrre un commit con contenuto arbitrario firmato con
   la chiave rubata
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
```
2. Verificare che il commit sia accettato dal motore
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc history
analyzing repository C:\Users\stemic\stage\repo\ ...

 = master-simulazione                                        simulazione                                               work       0Q6WRGCMHR
 o                                                           simulazione                          produzione           0Q6WRGCMHR 0Q6PHWPMPQ
 o                                                           simulazione                          documentazione       0Q6PHWPMPQ 0Q6PHW0IJW
 o                                                           simulazione                          documentazione       0Q6PHW0IJW 0Q6PHV1YTU
 o                                                           simulazione                          documentazione       0Q6PHV1YTU 0Q6PHUAOSV
 o                                                           simulazione                          documentazione       0Q6PHUAOSV 0Q6PHT7QCI
 o                                                           simulazione                          documentazione       0Q6PHT7QCI    
tot. exec time: 0.00 sec
```
3. Eseguire il verificatore con allowed_signers_con_chiave
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

Risultato: 0/6 commit con problemi.
Risultato: 0/6 commit con warning.
tot. exec time: 1.16 sec
```
4. Documentare che il commit risulta completamente valido

## Risultato atteso
Il verificatore segnala [OK] su tutti i campi — hash, catena
e firma — per il commit fraudolento. Il commit è
crittograficamente indistinguibile da uno legittimo.
Nessuna operazione normale del motore produce avvisi.

## Risultato osservato (versione iniziale)
Il commit è stato accettato e verificato.
Questo è perchè la chiave è indicie di verità e quindi firmare con quella vuol dire essere il legittimo possessore della chiave.

## Analisi dell'impatto
L'attaccante ha piena possibilità di commitare.
Questa possibilità di attacco è di altissimo impatto.
Non è rilevabile nè da motore nè da verificatore in modo automatico. L'unica contromisura è solo con un controllo manuale del codice committato e da un rinnovo continuo delle chiavi.

## Contromisura implementata
Nessuna contromisura tecnica può impedire questo attacco una
volta che la chiave è compromessa — è una limitazione strutturale
di qualsiasi sistema basato su crittografia asimmetrica. La
mitigazione è procedurale: rotazione periodica delle chiavi,
rilevamento rapido della compromissione e revoca immediata.
Nel modello proposto la revoca è operativa dal commit successivo
alla modifica dell'allowed_Dipendenti.

## Risultato osservato (dopo implementazione)
Non applicabile — la protezione non è tecnica ma procedurale.

## Riferimenti
- Requisito coinvolto: RS09
- Proprietà violata: Autenticità, Non ripudio