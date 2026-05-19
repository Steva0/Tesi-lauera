# S5 — Injection e robustezza dell'input

## Descrizione dello scenario

Questo scenario testa la resistenza di RVC a input malevoli o malformati
che potrebbero causare: (1) crash del motore, (2) esecuzione arbitraria
di comandi del sistema operativo (command injection), (3) bypass dei
controlli di sicurezza attraverso valori di input non sanificati.

L'attaccante in questo scenario è un utente locale che può:
- controllare i parametri da riga di comando
- modificare file di configurazione locali (rvc.config)
- fornire file di chiavi o signers con contenuto malevolo

## Ambito del test

| Categoria | Cosa viene testato |
|-----------|-------------------|
| Validazione input | Nomi progetto/autore/tag con metacaratteri, lunghezze estreme |
| Parameter injection | Metacaratteri shell nei parametri CLI (`&`, `|`, `;`, `>`, `"`) |
| Path injection | Path con `"` nelle chiamate `cmd /C` (mkdir, ssh-keygen) |
| Recipients injection | Chiavi SSH con `"` iniettate nel comando `age --encrypt` |
| Config tampering | default_key con `"` nel path → ssh-keygen injection |
| Script injection | rvc_home con `"` → injection nel file PS1 generato |
| File names | Commit con file dai nomi speciali (`&`, `;`, `(`) nella working dir |
| .sig tampering | cv.author malevolo nel file .sig (vettore lato repository) |
| Comandi mancanti | Tutti i comandi con parametri obbligatori assenti |
| Versioni inesistenti | -ver= con ID non esistente o con path traversal |

## Superfici d'attacco identificate (tutte le chiamate os.Exec)

| Chiamata | Parametro utente | Tipo shell | Esito test |
|----------|-----------------|------------|------------|
| `cmd /C mkdir "path"` | `-dir=` | cmd.exe | Sicuro — shell strips `"` prima di RVC |
| `cmd /C ssh-keygen -Y sign -f "keyPath"` | `default_key` config | cmd.exe | Sicuro — ssh-keygen entra in modalità stdin senza file arg |
| `cmd /C ssh-keygen -Y sign -f "keyPath"` | `-master-key=` | cmd.exe | Sicuro — pre-flight blocca prima di arrivare alla firma |
| `cmd /c ssh-keygen -Y verify -I cv.author` | `.sig` manomesso | cmd.exe | **Risolto** — quotato + validazione regex |
| `age.exe --encrypt -r "ageRcpKey"` | `-recipients=` file | diretto | Sicuro — age usa CreateProcess, `&` non interpretato |
| `powershell -File "tmpPs1"` | `rvc_home` config | PS1 generato | Sicuro — shell strips `"` prima di RVC |

## Tecniche testate

| ID | Tecnica | Esito |
|----|---------|-------|
| T1 | Injection via parametri CLI con metacaratteri shell | Sicuro — shell strips prima di RVC |
| T2 | Injection via recipients age con " nel valore | Sicuro + fix difensivo aggiunto |
| T3 | Injection via cv.author in .sig manomesso | **Vulnerabilità corretta** |
| T4 | Injection via default_key tamperata in config | Sicuro in pratica (richiede accesso locale) + fix difensivo |
| T5 | Injection via rvc_home in script PS1 | Sicuro in pratica + fix difensivo |
| T6 | Input non sanificati: nomi progetto/autore troppo lunghi | **Vulnerabilità corretta** |
| T7 | Input non sanificati: flag -vers crash per collisione con -ver= | **Vulnerabilità corretta** |
| T8 | File con nomi speciali nella working dir | Sicuro — packing non usa os.Exec |
| T9 | Crash su comandi con parametri mancanti | **14 crash corretti** |
| T10 | Errori falsi positivi in CheckValidity | **Vulnerabilità critica corretta** |

## Tabella di stato

| Tecnica | Stato |
|---------|-------|
| T1 | ✓ Completata |
| T2 | ✓ Completata |
| T3 | ✓ Completata |
| T4 | ✓ Completata |
| T5 | ✓ Completata |
| T6 | ✓ Completata |
| T7 | ✓ Completata |
| T8 | ✓ Completata |
| T9 | ✓ Completata |
| T10 | ✓ Completata |

## Riferimenti
- Requisiti rilevanti: RS03 (integrità hash), RS04 (firma), RS06 (autenticità)
- Data di esecuzione: 2026-05-19
