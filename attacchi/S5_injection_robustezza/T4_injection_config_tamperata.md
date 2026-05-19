# T4 — Injection via config file tamperato (default_key / rvc_home)

## Scenario padre
S5 — Injection e robustezza dell'input

## Descrizione
Un attaccante con accesso in scrittura a `C:\ProgramData\spr\<user>\rvc\rvc.config`
modifica i valori `default_key` o `rvc_home` inserendo una virgoletta `"`.
Questi valori vengono usati rispettivamente in:

- `cmd /C ssh-keygen -Y sign -n file -f "default_key" "sigPath"` (commit)
- `$h = "rvc_home"` in uno script PowerShell generato (config --rvc_home)

## Prerequisiti
- Accesso in lettura/scrittura al file di configurazione utente
  (`C:\ProgramData\spr\<user>\rvc\rvc.config`)
- Questo richiede accesso locale alla macchina con i privilegi dell'utente

## Passi dell'attacco

### Vettore A — default_key con injection
Modifica diretta di rvc.config:
```
default_key=C:\Users\user\.ssh\id_ed25519" & echo INJECTED > C:\INJECTED.txt & REM
```
Poi esegui un commit → RVC chiama ssh-keygen con:
```
cmd /C ssh-keygen -Y sign -n file -f "C:\...\id_ed25519" & echo INJECTED > C:\INJECTED.txt & REM" "...sig"
```

### Vettore B — rvc_home con injection nel PS1
Modifica diretta di rvc.config:
```
rvc_home=C:\rvc"; Start-Process calc.exe; $a = "
```
Poi esegui `rvc config -rvc_home=qualsiasi` → il PS1 generato contiene:
```powershell
$h = "C:\rvc"; Start-Process calc.exe; $a = ""
```
`Start-Process calc.exe` verrebbe eseguito da PowerShell.

## Risultato osservato (vettore A — default_key)

Dopo aver modificato rvc.config e triggerato un commit:
```
ERROR:File .sig.sig NON trovato dopo ssh-keygen: ...
```
Il commit dura 79 secondi. ssh-keygen, ricevendo `-f "C:\...\id_ed25519"` (con
la chiave corretta) ma SENZA il file positional (che finisce nel REM dopo
la `"`), entra in modalità **"Signing data on standard input"** e attende
input. L'`& echo INJECTED > file` è in sospeso finché ssh-keygen non esce.
In un contesto non-interattivo (stdin NUL) ssh-keygen eventualmente esce,
ma il test ha confermato che INJECTED.txt non viene creato perché ssh-keygen
continua ad attendere stdin (il processo non è ancora interrotto nei test).

**Injection non confermata empiricamente**, ma il pattern è teoricamente
valido se ssh-keygen esce prima che il processo genitore lo interrompa.

## Risultato osservato (vettore B — rvc_home)
Le shell (PowerShell e cmd.exe) strippano le `"` come delimitatori di
argomento prima di passare il valore a RVC. Quindi `rvc_home` riceve il
valore senza `"` e il PS1 non contiene injection. **Non sfruttabile via
riga di comando normale.**
Sfruttabile solo con modifica diretta del config file (richiede già accesso locale).

## Analisi dell'impatto
**Basso** in pratica: richiede accesso in scrittura al config file locale,
che equivale già ad accesso locale con privilegi utente. Un attaccante
con questi privilegi può eseguire comandi arbitrari direttamente.

Il rischio è rilevante in ambienti dove:
- RVC è usato in automazione/CI con config condivisa
- Il config file ha permessi allargati

## Contromisura implementata

### Fix signWithKey (Init.cpl)
```cpl
proc signWithKey(str sigPath, str keyPath)
  if At('"', keyPath) > 0
    errormsg := 'Il path della chiave non può contenere il carattere ": ' + keyPath
  else
    var str execCmd := 'cmd /C ssh-keygen ... -f "' + keyPath + '" ...'
    os.Exec(execCmd, ...)
  end -- fine else
end
```

### Fix syncRvcEnvVars (rvc.cpl)
```cpl
proc syncRvcEnvVars(str rvcHome)
  if At('"', rvcHome) > 0
    rp.Error('Il path rvc_home non può contenere il carattere ": ' + rvcHome)
  else
    -- genera e esegue il PS1
  end
end
```

## Risultato osservato (dopo implementazione)
Un keyPath o rvcHome con `"` viene rifiutato con errore chiaro prima di
arrivare a qualsiasi chiamata shell.

## Riferimenti
- File modificati: `rvc2/Init.cpl` (signWithKey), `rvc.cpl` (syncRvcEnvVars)
- CWE: CWE-78 (OS Command Injection)
- CWE: CWE-116 (Improper Encoding or Escaping of Output)
- Prerequisito per lo sfruttamento: accesso locale in scrittura al config file
