# Metodo di esecuzione dei test

Questo documento descrive il metodo che ho seguito per eseguire
e documentare ogni tecnica di attacco in modo riproducibile
e confrontabile tra scenari diversi.

## Passi seguiti per ogni tecnica

### Passo 1 — Preparazione dello stato pulito
Prima di ogni tecnica ho ripristinato la repository a uno stato
noto e pulito, partendo da una copia di backup contenente 4-5
commit legittimi firmati. Questo garantisce che ogni tecnica
parta dalle stesse condizioni e che i risultati siano
confrontabili tra loro.

### Passo 2 — Esecuzione dell'attacco
Ho seguito i passi descritti nel file della tecnica, documentando
i comandi esatti utilizzati tramite copia-incolla nel campo
"Risultato osservato" del file markdown corrispondente.
Questo rende ogni test riproducibile.

### Passo 3 — Esecuzione del verificatore

```bash
rvc integrity -signers="C:\Users\stemic\stage\simulazione\allowed_signers"
```

Ho copiato l'output completo nel file markdown sotto
"Risultato osservato (versione iniziale)".

### Passo 4 — Verifica delle operazioni normali
Dopo ogni attacco ho tentato di eseguire un commit normale,
una lettura e un aggiornamento, documentando se il motore
si comportava normalmente o rilevava anomalie. Il motore e
il verificatore sono strumenti separati — in alcuni casi
uno rileva problemi che l'altro non vede.

### Passo 5 — Analisi dell'impatto
Per ogni tecnica ho risposto a queste tre domande:
- Cosa può fare concretamente l'attaccante con questa tecnica?
- Quanto è grave — può modificare codice, impersonare autori,
  cancellare storia?
- È rilevabile senza il verificatore, solo con il verificatore,
  o non è rilevabile affatto?

## Struttura dell'output del verificatore
[OK]    id  hash:OK  catena:OK  firma:OK      (autore)
[WARN]  id  hash:OK  catena:OK  firma:ASSENTE (autore, non verificato)
[FAIL]  id  hash:FAIL  ...                    (autore)

Risultato finale:
Risultato: N/TOT commit con problemi.
Risultato: N/TOT commit con warning.

## Note
- Ho documentato sempre i comandi esatti utilizzati
- I file delle tecniche sono stati compilati solo nei campi
  "da compilare" senza modificare la struttura predefinita
- I risultati inattesi sono stati documentati con una nota
  di analisi aggiuntiva
- La tabella di stato in scenario.md è stata aggiornata
  dopo il completamento di ogni tecnica