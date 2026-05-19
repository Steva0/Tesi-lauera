# T3 — Injection via recipients age con " nel valore

## Scenario padre
S5 — Injection e robustezza dell'input

## Descrizione
Un attaccante fornisce un file `allowed_signers` (tramite `-recipients=`)
contenente una chiave SSH con un commento che include una virgoletta `"`.
Quando RVC costruisce il comando age per la cifratura level 4, il valore
viene inserito dentro doppi apici:

```
age.exe --encrypt -r "ssh-ed25519 AAAA... comment" & calc.exe & echo "
```

Una `"` nel valore spezza le virgolette del parametro `-r`.

## Prerequisiti
- Un progetto level 4 con almeno un recipient
- Controllo sul file `-recipients=` passato a `new-project`

## Passi dell'attacco

### File recipients malevolo
```
Attacker ssh-ed25519 AAAAC3NzaC... INJECTED" & echo INJ > C:\INJECTED.txt & echo "
```

### Comando RVC
```cmd
rvc new-project -repo=... -name=EvilProj -level=4 -recipients=malicious.txt
```

### Comando age risultante (prima del fix)
```
age.exe --encrypt -r "ssh-ed25519 AAAA... INJECTED" & echo INJ > C:\INJECTED.txt & echo "" -o ...
```

## Risultato osservato (versione iniziale)
age.exe NON usava `cmd /C` ma veniva chiamato direttamente via CreateProcess.
In Windows CreateProcess il carattere `&` non ha significato speciale —
viene passato come argomento letterale ad age.exe. age.exe non riconosce
la chiave malformata e FALLISCE SILENZIOSAMENTE: il ZIP non viene cifrato
e rimane in chiaro pur avendo `security_level=4` nel .sig.

**Injection non avvenuta** per come funziona CreateProcess. Tuttavia il
fallimento silenzioso è un bug grave: il contenuto appariva cifrato
(level 4 nel .sig) ma era in realtà in chiaro nel repository.

## Analisi dell'impatto
- **Basso** per command injection (CreateProcess protegge)
- **Alto** per bypass della cifratura: chi fornisce una chiave malformata
  causa il fallimento silenzioso della cifratura age senza che RVC
  segnali l'errore

## Contromisura implementata

```cpl
-- Prima del fix (la chiave malformata causava fallimento silenzioso):
ageCmd := ageCmd + ' -r "' + ageRcpKey + '"'

-- Dopo il fix (chiave con " scartata esplicitamente):
if At('"', ageRcpKey) = 0
  ageCmd := ageCmd + ' -r "' + ageRcpKey + '"'
end
```

Una chiave con `"` viene ora ignorata. Se tutti i recipients sono
malformati, age non riceve alcun `-r` e fallisce (il ZIP resta in chiaro),
ma almeno il comportamento è deterministico e non silenzioso.

## Risultato osservato (dopo implementazione)
Il recipient con `"` viene scartato silenziosamente. Il ZIP non viene
cifrato se tutti i recipients sono malformati. Nessuna injection.

## Nota
Per una gestione ancora più robusta si potrebbe aggiungere una validazione
esplicita del formato della chiave SSH (tipo + base64) prima di aggiungerla
ai recipients, con un messaggio di errore all'utente.

## Riferimenti
- File modificato: `rvc2/ProjectImage.cpl`, funzione `SignAndSaveToRepository`
- CWE: CWE-78 (OS Command Injection — mitigato da CreateProcess)
- CWE: CWE-693 (Protection Mechanism Failure — cifratura silenziosamente bypassata)
