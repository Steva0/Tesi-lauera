# T7 — Modifica del .sig senza modificare lo ZIP

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante modifica solo il file .sig di un commit esistente —
ad esempio cambia il campo author o comment — lasciando lo ZIP
intatto. Obiettivo: verificare se la firma SSH rileva modifiche
al .sig.

## Prerequisiti
- Repository di test con almeno un commit legittimo firmato
- Accesso in scrittura alla cartella della repository
- Capacità di modificare il file .sig

## Passi dell'attacco
1. Identificare un commit legittimo firmato
2. Modificare il campo author o comment nel .sig
3. Lasciare la firma SSH invariata in fondo al .sig
4. Lasciare lo ZIP invariato
5. Eseguire il verificatore
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc integrity -signers="C:\Users\stemic\stage\allowed_signers"

Verifica integrita repository: tutti i progetti
allowed_signers: C:\Users\stemic\stage\allowed_signers

analyzing repository C:\Users\stemic\stage\repo\ ...
[OK]  0Q6PHT7QCI  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHV1YTU  hash:OK  catena:OK  firma:OK  (Michele)
[ERR] 0Q6PHW0IJW  hash:OK  catena:OK  firma:FALLITA  (Michele)
       ERRORE:  Firma SSH non valida
[OK]  0Q6PHWPMPQ  hash:OK  catena:OK  firma:OK  (Michele)

Risultato: 1/5 commit con problemi.
Risultato: 0/5 commit con warning.
tot. exec time: 1.05 sec
```

## Risultato atteso
Il verificatore rileva [FAIL] firma:FAIL poiché la firma SSH
copre il .sig nella sua interezza — qualsiasi modifica a qualsiasi
campo invalida la firma. Questo dimostra positivamente che la
firma protegge l'integrità dei metadati.

## Risultato osservato (versione iniziale)
Il verificatore rileva giustamente qualunque modifica al file sig se è presente la firma ssh.
Non viene lasciato spazio all'attaccante di modificare il file sig senza essere visto.

## Analisi dell'impatto
Con questa tecnica l'attaccante non può effettuare alcun tipo di attacco.
E' rilevabile solo con il verificatore.

## Contromisura implementata
Nessuna necessaria — questa protezione è già presente nella
versione iniziale grazie alla firma SSH.

## Risultato osservato (dopo implementazione)
Non applicabile — la protezione è già attiva.

## Riferimenti
- Requisito: RS06 (parzialmente soddisfatto)
- Proprietà protetta: Autenticità, Non ripudio