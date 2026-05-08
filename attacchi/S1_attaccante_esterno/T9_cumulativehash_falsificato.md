# T9 — Commit con cumulativeHash falsificato

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante produce un commit con hash e cumulativeHash calcolati
correttamente sul nuovo ZIP ma con prevHash che punta a un commit
inesistente o scorretto, tentando di inserire un punto di ingresso
alternativo nella catena.

## Prerequisiti
- Repository di test con almeno un commit legittimo
- Accesso in scrittura alla cartella della repository
- Capacità di produrre un .sig strutturalmente valido

## Passi dell'attacco
1. Produrre un nuovo ZIP con contenuto arbitrario
```bash
C:\Users\stemic\stage\repo>mkdir temp_estrazione
C:\Users\stemic\stage\repo>tar -xf simulazione.0Q6PHV1YTU.0Q6PHUAOSV.{Michele}+documentazione.zip -C temp_estrazione
C:\Users\stemic\stage\repo>cd temp_estrazione
C:\Users\stemic\stage\repo\temp_estrazione>echo aggiunta di codice malevolo >> fileNuovo.txt
C:\Users\stemic\stage\repo\temp_estrazione>tar -a -c -f simulazione.0Q6PHV1YTU.0Q6PHUAOSV.{Michele}+documentazione.zip -C temp_estrazione .
tar: could not chdir to 'temp_estrazione'
C:\Users\stemic\stage\repo\temp_estrazione>cd ..
C:\Users\stemic\stage\repo>tar -a -c -f simulazione.0Q6PHV1ZZZ.0Q6PHUAYYY.{Michele}+documentazione.zip -C temp_estrazione .
C:\Users\stemic\stage\repo>rmdir /s /q temp_estrazione
```

2. Calcolare hash e cumulativeHash corretti per questo ZIP
C:\Users\stemic\stage\repo>python -c "import hashlib; print(hashlib.sha256(open('simulazione.0Q6PHV1ZZZ.0Q6PHUAYYY.{Michele}+documentazione.zip','rb').read()).hexdigest().upper())"
368C55D0B84E68B5C197A063B6144C1F21ECE73E372E7E4279D86034A2D7E8DF
3. Impostare prevHash con un valore arbitrario o inesistente
4. Produrre il .sig senza firma SSH
6. Eseguire il verificatore
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc integrity -signers="C:\Users\stemic\stage\allowed_signers"

Verifica integrita repository: tutti i progetti
allowed_signers: C:\Users\stemic\stage\allowed_signers

analyzing repository C:\Users\stemic\stage\repo\ ...
[OK]  0Q6PHT7QCI  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHV1YTU  hash:OK  catena:OK  firma:OK  (Michele)
[ERR] 0Q6PHV1ZZZ  hash:OK  catena:FALLITO  firma:ASSENTE  (Michele)
       ERRORE:  CumulativeHash non corrisponde
[OK]  0Q6PHW0IJW  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHWPMPQ  hash:OK  catena:OK  firma:OK  (Michele)

Risultato: 1/6 commit con problemi.
Risultato: 0/6 commit con warning.
tot. exec time: 1.26 sec
```

## Risultato atteso
Il verificatore rileva [FAIL] catena:FAIL poiché il prevHash
dichiarato non corrisponde al cumulativeHash del commit
precedente nella catena. Il commit risulta isolato —
non si aggancia alla storia legittima.

## Risultato osservato (versione iniziale)
Il verificatore rileva atena fail per quel commit lasciando invece valida la catena per gli altri commit veri.
E' obbligatorio non mettere la password e risulta impossibile calcolare il cumulativeHash puntando questo commit a un commit non esistente.
L'unico caso è metterlo come commit di testa e quindi senza un prevHash ma risulta comunque impossibile mettere la firma nel sig.

## Analisi dell'impatto
Il verificatore nota la manomissione e inserimento di una commit scollagata dal resto.
Segnala errore e la invalida. L'attaccante non ha la possibilità di inserire commit arbitrari senza essere rilevati a meno di assenze di firme con inserimento del commit come commit di testa.

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS02, RS03
- Proprietà violata: Integrità, Ordine verificabile