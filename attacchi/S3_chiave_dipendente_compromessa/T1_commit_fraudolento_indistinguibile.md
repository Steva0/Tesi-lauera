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
2. Verificare che il commit sia accettato dal motore
3. Eseguire il verificatore con allowed_signers_con_chiave
4. Documentare che il commit risulta completamente valido

## Risultato atteso
Il verificatore segnala [OK] su tutti i campi — hash, catena
e firma — per il commit fraudolento. Il commit è
crittograficamente indistinguibile da uno legittimo.
Nessuna operazione normale del motore produce avvisi.

## Risultato osservato (versione iniziale)
[da compilare]

## Analisi dell'impatto
[da compilare]

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