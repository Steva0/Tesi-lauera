# T5 — Inserimento di un commit in mezzo alla catena

## Scenario padre
S1 — Attaccante esterno senza credenziali

## Descrizione
L'attaccante tenta di inserire un commit tra due commit esistenti,
modificando i riferimenti prevId e prevHash per far sembrare che
il nuovo commit sia parte legittima della catena.

## Prerequisiti
- Repository di test con almeno due commit legittimi
- Accesso in scrittura alla cartella della repository

## Passi dell'attacco
1. Identificare due commit consecutivi A e B nella catena
```bash
C:\Users\stemic\stage\simulazione>dir ..\repo
07/05/2026  16:02    <DIR>          .
07/05/2026  16:03    <DIR>          ..
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

2. Copiare il commit A e il .sig corrispondente

3. Modificare il commit aggiungendo file arbitrari

4. Rinominare il commit modificando la parte del suo id per alterarne l'ordinamento lessicografico e inserirlo artificialmente nella sequenza temporale tra i commit A e B.

5. Rinominare il commit modificando la parte del prevId inserendo l'Id del commit A.

6. Rinominare il commit B in modo che il prevId sia l'Id del commit fittizio.

7. Modificare i file sig del commit fittizio e del commit B in modo che hash, prevHash e cumulativeHash siano corretti e togliere le firme ssh. Guardare come nel T4.

8. Eseguire il verificatore

## Risultato atteso
Il verificatore rileva [FAIL] catena:FAIL su B poiché la firma
di B non corrisponde più al contenuto del .sig modificato — la
firma originale copriva i valori originali di prevId e prevHash.
Il commit inserito C risulta [WARN] firma:ASSENTE.

## Risultato osservato (versione iniziale)
Il commit modificato risulta come warning per l'assenza della chiave che deve essere tolta obbligatoriamente dato che la firma viene calcolata sull'hash del sig che è stato modificato e quindi non risulterebbe più valida.
I nodi successivi vengono segnati come errore.
E' possibile eseguiro questo ricalcolo di hash e sostituizione nei file sig più volte per arrivare ad avere solo warning.

## Analisi dell'impatto
Questa possibilità di attacco implica che se le firme ssh non fossero obbligatorie in una repo, esisterebbe la possibilità di manomettere un sig e tutti quelli successivi per poter inserire un commit alterato in mezzo.
Questo è molto grave perchè può inserire codice malevolo o cambiare la storia e ordine dei commit
Questa cosa è rilevabile solo se il commit di partenza aveva la firma ssh, altrimenti in sua assenza sarebbe impossibile essere rintracciato.

## Note
Se dopo aver rinominato .zip o .sig il comando integrity dovesse dire di quel commit: "ERRORE: File ZIP non trovato", eliminare la cache che si trova nella cartella che contiene la repo.

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS02, RS03
- Proprietà violata: Integrità, Ordine verificabile