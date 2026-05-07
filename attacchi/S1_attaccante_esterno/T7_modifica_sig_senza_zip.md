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
- Capacità di modificare il formato binario del .sig

## Passi dell'attacco
1. Identificare un commit legittimo firmato
2. Modificare il campo author o comment nel .sig
3. Lasciare la firma SSH invariata in fondo al .sig
4. Lasciare lo ZIP invariato
5. Eseguire il verificatore

## Risultato atteso
Il verificatore rileva [FAIL] firma:FAIL poiché la firma SSH
copre il .sig nella sua interezza — qualsiasi modifica a qualsiasi
campo invalida la firma. Questo dimostra positivamente che la
firma protegge l'integrità dei metadati.

## Risultato osservato (versione iniziale)
[da compilare]

## Analisi dell'impatto
[da compilare]

## Contromisura implementata
Nessuna necessaria — questa protezione è già presente nella
versione iniziale grazie alla firma SSH.

## Risultato osservato (dopo implementazione)
Non applicabile — la protezione è già attiva.

## Riferimenti
- Requisito: RS06 (parzialmente soddisfatto)
- Proprietà protetta: Autenticità, Non ripudio