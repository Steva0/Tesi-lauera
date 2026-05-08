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
2. Firmare il commit con la propria chiave SSH
3. Verificare che il commit sia stato accettato dal motore
4. Eseguire il verificatore con il file allowed_signers corretto

## Risultato atteso
Il motore accetta il commit. Il verificatore rileva che la firma
non corrisponde all'author dichiarato — la chiave usata per la firma
appartiene a un soggetto diverso da quello indicato nel campo author.
Senza il verificatore il commit è indistinguibile da uno legittimo
prodotto dal collega.

## Risultato osservato (versione iniziale)
[da compilare]

## Analisi dell'impatto
[da compilare]

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito violato: RS07, RS08
- Proprietà violata: Autenticità, Autorizzazione