# T2 — Injection via cv.author in file .sig manomesso

## Scenario padre
S5 — Injection e robustezza dell'input

## Descrizione
Un attaccante con accesso in scrittura al repository manomette un file .sig
inserendo un valore malevolo nel campo `author`. Quando RVC esegue
`integrity` o `CheckValidity`, il valore viene usato nel comando:

```
cmd /c ssh-keygen -Y verify -n file -f <allowedSigners> -I cv.author -s ...
```

Se `cv.author` non è quotato e contiene metacaratteri cmd.exe, il codice
dopo `&` viene eseguito come comando shell separato.

## Prerequisiti
- Accesso in scrittura al file system della repository
- Conoscenza del formato interno dei file .sig di RVC

## Passi dell'attacco

1. Identificare un file .sig nella repository
2. Modificare il campo `author` inserendo:
   ```
   Michele" & echo INJECTED > C:\INJECTED.txt & REM
   ```
3. Eseguire `rvc integrity` (che chiama `VerifySignature`)
4. Il comando diventerebbe:
   ```
   cmd /c ssh-keygen ... -I "Michele" & echo INJECTED > C:\INJECTED.txt & REM" ...
   ```

## Risultato osservato (versione iniziale)
Il campo `cv.author` veniva inserito NON quotato nel comando ssh-keygen.
Se il .sig contenesse un valore con `"`, il comando cmd.exe avrebbe
interpretato i caratteri dopo la `"` di chiusura come operatori separati.

## Analisi dell'impatto
**Critico**: un attaccante con accesso al repository potrebbe eseguire
comandi arbitrari su ogni macchina che esegue `rvc integrity` su quel
repository manomesso. L'attacco è silenzioso (il comando malevolo
è incapsulato nella verifica di routine).

## Contromisura implementata

### Fix 1 — Quotatura del valore
```cpl
-- Prima (vulnerabile):
os.Exec('cmd /c ... -I '+cv.author+' -s ...', ...)

-- Dopo (sicuro):
os.Exec('cmd /c ... -I "'+cv.author+'" -s ...', ...)
```

### Fix 2 — Validazione anticipata
```cpl
if !RvcEngine.isValidAuthorName(cv.author)
  result := false
else
  os.Exec(...)
end
```

`isValidAuthorName` ammette solo `[0-9A-Za-z_\-.@]+` (max 64 chars).
Nessuno di questi caratteri è un metacarattere cmd.exe.
Un .sig manomesso con author malevolo viene ora rifiutato prima dell'exec.

## Risultato osservato (dopo implementazione)
Un .sig con author invalido causa `firma:FAIL` nell'integrity senza
eseguire alcun codice arbitrario. Il guard blocca l'exec.

## Riferimenti
- File modificato: `rvc2/ProjectImage.cpl`, funzione `VerifySignature`
- Requisito violato (prima): RS04 (autenticità), RS03 (integrità motore)
- CWE: CWE-78 (OS Command Injection)
