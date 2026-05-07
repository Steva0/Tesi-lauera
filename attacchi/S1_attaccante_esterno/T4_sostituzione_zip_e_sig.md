# T4 — Sostituzione completa di ZIP e .sig

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante sostituisce sia lo ZIP che il .sig di un commit esistente
con valori ricalcolati su un contenuto alterato. Hash e cumulativeHash
nel nuovo .sig sono corretti rispetto al nuovo ZIP, ma il cumulativeHash
del commit successivo nella catena non corrisponde più.

## Prerequisiti
- Repository di test con almeno due commit legittimi
- Accesso in scrittura alla cartella della repository
- Capacità di produrre un .sig valido dal punto di vista
  strutturale (senza firma SSH)

## Passi dell'attacco
1. Identificare un commit target che non sia l'ultimo della catena
```bash
C:\Users\stemic\stage\repo>dir
07/05/2026  14:14    <DIR>          .
07/05/2026  12:55    <DIR>          ..
07/05/2026  11:47               716 .FileManifest
07/05/2026  11:45                 0 fileNuovo.txt
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

2. Produrre un nuovo ZIP con contenuto alterato
```bash
C:\Users\stemic\stage\repo>mkdir temp_estrazione
C:\Users\stemic\stage\repo>tar -xf simulazione.0Q6PHV1YTU.0Q6PHUAOSV.{Michele}+documentazione.zip -C temp_estrazione
C:\Users\stemic\stage\repo>cd temp_estrazione
C:\Users\stemic\stage\repo\temp_estrazione>echo aggiunta di codice malevolo >> fileNuovo.txt
C:\Users\stemic\stage\repo\temp_estrazione>cd ..
C:\Users\stemic\stage\repo>tar -a -c -f simulazione.0Q6PHV1YTU.0Q6PHUAOSV.{Michele}+documentazione.zip -C temp_estrazione .
C:\Users\stemic\stage\repo>rmdir /s /q temp_estrazione
C:\Users\stemic\stage\repo>cd ..\simulazione
```
3. Calcolare il nuovo hash SHA256 del ZIP
```bash
PS C:\Users\stemic\stage\repo> python -c "import hashlib; print(hashlib.sha256(open('simulazione.0Q6PHV1YTU.0Q6PHUAOSV.{Michele}+documentazione.zip','rb').read()).hexdigest().upper())"
35EFF8161A9E587248B4595AE1921FE3389663C4E1EFFCA44990918DB3853980
```
4. Calcolare il nuovo cumulativeHash
```bash
PS C:\Users\stemic\stage\repo> python -c "import hashlib; h1='35EFF8161A9E587248B4595AE1921FE3389663C4E1EFFCA44990918DB3853980'; h2='7047DC005E8CEC866A7BA7493AD5F0E09AD1C943056A03915192CD0696805E78'; print(hashlib.sha256((h1+h2).encode('utf-16-le')).hexdigest().upper())"
2D2239E1A71520B807315AA212A765C00CDB6508F6A2C939A5B6BC7D7EF513A7
```

5. Sostituire nel file .sig il nuovo hash e cumulative hash e togliere la firma se presente

6. Eseguire il verificatore
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc integrity -signers="C:\Users\stemic\stage\allowed_signers"

Verifica integrita repository: tutti i progetti
allowed_signers: C:\Users\stemic\stage\allowed_signers

analyzing repository C:\Users\stemic\stage\repo\ ...
[OK]  0Q6PHT7QCI  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK  firma:OK  (Michele)
[WARN] 0Q6PHV1YTU  hash:OK  catena:OK  firma:ASSENTE  (Michele)
[ERR] 0Q6PHW0IJW  hash:OK  catena:FALLITO  firma:OK  (Michele)
       ERRORE:  CumulativeHash non corrisponde
[ERR] 0Q6PHWPMPQ  hash:OK  catena:FALLITO  firma:OK  (Michele)
       ERRORE:  CumulativeHash non corrisponde

Risultato: 2/5 commit con problemi.
Risultato: 1/5 commit con warning.
tot. exec time: 0.83 sec
```

## Risultato atteso
Il verificatore segnala [FAIL] catena:FAIL sul commit successivo
a quello sostituito, poiché il prevHash non corrisponde al
cumulativeHash del commit alterato. Il commit alterato stesso
potrebbe risultare hash:OK se il ricalcolo è corretto, ma la
catena si rompe nel punto successivo.

## Risultato osservato (versione iniziale)
Il commit modificato risulta come warning per l'assenza della chiave che deve essere tolta obbligatoriamente dato che la firma viene calcolata sull'hash del sig che è stato modificato e quindi non risulterebbe più valida.
I nodi successivi vengono segnati come errore.
E' possibile eseguiro questo ricalcolo di hash e sostituizione nei file sig più volte per arrivare ad avere solo warning.

## Analisi dell'impatto
Questa possibilità di attacco implica che se le firme ssh non fossero obbligatorie in una repo, esisterebbe la possibilità di manomettere un sig e tutti quelli successivi per poter inserire un commit alterato in mezzo.
Questo è molto grave perchè può inserire codice malevolo o cambiare la storia e ordine dei commit
Questa cosa è rilevabile solo se il commit di partenza aveva la firma ssh, altrimenti in sua assenza sarebbe impossibile essere rintracciato.

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS01, RS02
- Proprietà violata: Integrità, Ordine verificabile