# T3 — Volume di commit non autorizzati senza rilevamento operativo

## Scenario padre
S2 — Dipendente con chiave SSH valida ma non autorizzato

## Descrizione
Il dipendente produce una serie di commit firmati con la propria chiave
su un progetto non autorizzato nel corso del tempo. L'obiettivo non è
un singolo attacco puntuale ma dimostrare che il motore non emette mai
nessun segnale operativo durante le operazioni normali — history, commit,
lettura — indipendentemente dal numero di commit non autorizzati presenti.
Solo una verifica esplicita con il verificatore rivela il problema.
Questo dimostra che l'assenza di RS07 e RS08 non produce nessun
indicatore visibile senza strumenti dedicati.

## Prerequisiti
- Chiave SSH valida del dipendente non autorizzato
- Accesso in scrittura alla cartella della repository

## Passi dell'attacco
1. Produrre almeno 3 commit firmati con la chiave non autorizzata
   in momenti diversi
2. Dopo ogni commit eseguire operazioni normali — history, lettura,
   nuovo commit — e documentare se il motore emette avvisi
3. Eseguire il verificatore solo alla fine dell'intera sequenza

## Risultato atteso
Il motore non emette nessun avviso durante nessuna delle operazioni
normali, indipendentemente dal numero di commit non autorizzati
presenti nella repository. Il verificatore, eseguito esplicitamente
alla fine, rileva tutti i commit non autorizzati in una singola
analisi. Questo evidenzia la dipendenza da una verifica attiva e
periodica in assenza di controlli preventivi del motore.

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
- Proprietà violata: Autorizzazione