# Scenario 2 — Dipendente con chiave SSH valida ma non autorizzato

## Contesto
L'attaccante è un dipendente dell'organizzazione che possiede una chiave
SSH valida e sa produrre commit firmati correttamente. Non è tuttavia
autorizzato a operare su uno o più progetti specifici. Nella versione
iniziale di RVC non esiste nessun meccanismo di controllo degli accessi
per progetto — l'unica distinzione tra un commit autorizzato e uno non
autorizzato è rilevabile solo tramite verifica esplicita a posteriori,
non preventivamente dal motore.

## Cosa ha a disposizione
- Una coppia di chiavi SSH valida e funzionante
- Accesso in lettura e scrittura alla cartella della repository
- Conoscenza del formato RVC dall'interno

## Obiettivo dell'attaccante
Produrre commit validi dal punto di vista crittografico su progetti
a cui non dovrebbe avere accesso, senza che il motore emetta alcun
avviso durante le operazioni normali.

## Differenza rispetto allo scenario 1
A differenza dell'attaccante esterno, questo attaccante produce commit
crittograficamente firmati e validi. Il verificatore deve distinguere
tra "firma valida" e "firmatario autorizzato" — due proprietà che nella
versione iniziale non sono entrambe verificate preventivamente dal motore.

## Tecniche documentate
- T1: commit firmato da chiave non autorizzata
- T2: commit firmato con author dichiarato diverso dal firmatario
- T3: volume di commit non autorizzati senza rilevamento operativo

## Stato complessivo
| Tecnica | Rilevata pre-implementazione | Rilevata post-implementazione |
|---------|------------------------------|-------------------------------|
| T1      | -                            | -                             |
| T2      | -                            | -                             |
| T3      | -                            | -                             |