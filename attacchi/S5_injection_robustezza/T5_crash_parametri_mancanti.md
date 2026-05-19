# T5 — Crash e comportamento indefinito con parametri mancanti

## Scenario padre
S5 — Injection e robustezza dell'input

## Descrizione
Verifica sistematica di tutti i comandi RVC con parametri obbligatori
assenti o non validi. L'obiettivo è garantire che ogni errore di input
produca un messaggio utile invece di un crash del runtime CPL
("Error at rvc2.xxx: Invalid operation on nil").

## Casi testati e risultati

### Comandi admin

| Comando | Input mancante | Comportamento pre-fix | Comportamento post-fix |
|---------|---------------|----------------------|------------------------|
| `init` | Nessun parametro | crash doppia stampa errore | ERROR singolo chiaro |
| `init` | `-master-pub=` assente | crash doppia stampa | ERROR: Parametro -master-pub= obbligatorio |
| `init` | `-master-key=` assente | crash doppia stampa | ERROR: Parametro -master-key= obbligatorio |
| `init` | `-master-pub=` è chiave privata | crash | ERROR: file non sembra chiave pubblica SSH |
| `new-project` | `-name=` assente | ERROR generico "Failed..." | ERROR: Parametro -name= obbligatorio |
| `new-project` | `-level=9` | **accettato silenziosamente** | ERROR: livello non valido (0-4) |
| `new-project` | `-name=My Project` | ERROR generico "Failed..." | ERROR: Invalid project name: My Project |

### Comandi workflow

| Comando | Input mancante | Comportamento pre-fix | Comportamento post-fix |
|---------|---------------|----------------------|------------------------|
| `checkout` | `-project=` assente | ERROR (già) | ERROR: Missing project name |
| `checkout lv4` | `-age-key=` assente | ERROR:??? (nil errormsg) | ERROR: Progetto cifrato, usare -age-key= |
| `info -vers` | — | **crash** ArchiverByExt(nil) | rinominato in `-allver` |
| `info -ver=BADVER` | — | **crash** ArchiverByExt(nil) | ERROR: Versione non trovata nel repository |
| `info -ver=../evil` | — | **crash** ArchiverByExt(nil) | ERROR: Versione non trovata nel repository |

### Comandi informazione

| Comando | Input mancante | Comportamento pre-fix | Comportamento post-fix |
|---------|---------------|----------------------|------------------------|
| `file` | `-file=` assente | **crash** in FindFile | ERROR: Parametro -file= obbligatorio |
| `security` | `-project=` assente | ERROR (già) | ERROR (già) |

### Verifica & sicurezza

| Comando | Input mancante | Comportamento pre-fix | Comportamento post-fix |
|---------|---------------|----------------------|------------------------|
| `redact` | Nessun parametro | silenzio (ok=true, errormsg non stampato) | ERROR: Specificare -id/-range/-branch |
| `redact` | `-project=` assente | silenzio | ERROR: Parametro -project= obbligatorio |
| `redact` | `-master-key=` assente | **crash** SHA256(nil) | ERROR: Parametro -master-key= obbligatorio |

## Cause dei crash analizzate

### Pattern ricorrente 1: ArchiverByExt(nil)
`getManifest` chiamava `genericPacker.ArchiverByExt(pkn)` senza verificare
che `pkn` (risultato di `getCommitFileNameForExtraction`) fosse non-nil.
Un ID versione inesistente produceva pkn=nil → crash.

**Fix**: `if pkn = nil; errormsg := 'Versione non trovata nel repository: ' + version`

### Pattern ricorrente 2: doppia stampa errore
`InitRepo` chiamava `rp.Error(errormsg)` internamente E l'outer handler
in `rvc.cpl` lo chiamava di nuovo su `!ok`. Ogni errore appariva due volte.

**Fix**: rimossi tutti i `rp.Error()` interni a `InitRepo`; solo `errormsg` impostato.

### Pattern ricorrente 3: errormsg sovrascritta con nil
`Checkout` per level 4 impostava `errormsg := 'Progetto cifrato...'` e
`result := false`. Ma dopo `fmc.Checkout` non veniva chiamato, la riga
`errormsg := fmc.errormsg` sovrascriveva con `fmc.errormsg = nil` → ERROR:???

**Fix**: `if fmc.errormsg <> nil; errormsg := fmc.errormsg; end`

### Pattern ricorrente 4: collisione nome flag
`-vers` veniva interpretato dal parser CPL come `-ver=s` (param `ver` con
valore `s`). `Info()` cercava la versione `"s"` → non trovata → crash.

**Fix**: rinominato flag in `-allver` (non inizia con `ver`).

## Analisi dell'impatto
I crash di runtime espongono il traceback interno CPL all'utente, rivelando
nomi di moduli, percorsi interni e struttura del codice. In produzione
questo è un leak di informazioni. I crash ripetibili possono essere usati
per mappare la struttura interna del sistema.

## Risultato finale
Tutti i 14 casi di crash corretti. Tutti i comandi producono messaggi
di errore descrittivi in italiano senza mai mostrare traceback CPL.

## Riferimenti
- File modificati: `rvc.cpl`, `rvc2/ProjectImage.cpl`, `rvc2/RvcEngine.cpl`
- CWE: CWE-476 (NULL Pointer Dereference)
- CWE: CWE-703 (Improper Check or Handling of Exceptional Conditions)
