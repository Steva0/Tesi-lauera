# T1 — Injection via parametri CLI con metacaratteri shell

## Scenario padre
S5 — Injection e robustezza dell'input

## Descrizione
Un attaccante tenta di eseguire comandi arbitrari del sistema operativo
passando metacaratteri shell (`&`, `|`, `;`, `>`) come valore dei
parametri RVC da riga di comando, sfruttando eventuali utilizzi
non sanificati di `os.Exec` con quei valori.

## Prerequisiti
- Accesso alla riga di comando con RVC installato
- Un repository valido

## Passi dell'attacco

### 1. Injection via -author= con `&`
```cmd
rvc commit -repo=... -dir=... -author=bad&calc.exe
```

### 2. Injection via -author= con `|`
```cmd
rvc commit -repo=... -dir=... -author=bad|evil
```

### 3. Injection via -project= con caratteri speciali
```cmd
rvc new-project -repo=... -name=proj;evil
rvc new-project -repo=... -name=proj&calc
rvc new-project -repo=... -name=../evil
```

### 4. Injection via -tag= con metacaratteri
```cmd
rvc commit -repo=... -tag=bad tag
rvc commit -repo=... -tag=bad;tag
```

### 5. Injection via -note= con payload completo
```cmd
rvc commit -repo=... -note='" & echo INJECTED > C:\INJECTED.txt & "'
```

## Risultato osservato

**`-author=bad&calc.exe`**: PowerShell/cmd interpretano `&` come operatore
di shell PRIMA di passare l'argomento a RVC. RVC riceve solo `bad` come
autore. La calcolatrice viene aperta dal SO, non da RVC. `bad` da solo
è un nome autore valido e viene accettato. Questo è comportamento atteso
della shell, non un problema di RVC.

**`-author=bad|evil`**: La shell esegue `bad` come comando e poi `evil`
come comando separato. RVC non riceve mai il valore con `|`. Problema
di shell, non di RVC.

**Nomi progetto con metacaratteri**: Tutti bloccati dalla validazione regex
`isValidProjectName([0-9A-Za-z_]+)` con errore chiaro "Invalid project name".

**Tag con metacaratteri**: Tutti bloccati dalla validazione regex con errore
"Invalid tag name".

**`-note=` con payload**: La nota viene accettata (le note non vengono mai
passate a os.Exec) e salvata nel .sig come dato inerte.

## Analisi dell'impatto
Nessuna injection interna a RVC. Il vettore principale (metacaratteri
da riga di comando) viene neutralizzato dalla shell stessa prima che i
valori raggiungano RVC. Le validazioni regex proteggono i campi usati in
nomi di file (project, author, branch, tag).

## Contromisura implementata
Preesistente: validazione regex su project, author, branch, tag.
Aggiunta in questa sessione: limite massimo di lunghezza (64 chars per
project/author/branch, 128 chars per tag) per prevenire crash da
Windows MAX_PATH.

## Risultato osservato (dopo implementazione)
Tutti i casi testati danno errori puliti senza crash né esecuzione
arbitraria di codice.

```
ERROR:Invalid project name: proj;evil
ERROR:Invalid author name:bad;evil
ERROR:Invalid tag name:bad tag
```

## Riferimenti
- Requisiti: RS04 (autenticità), RS06 (firma)
- Proprietà: Integrità del motore
