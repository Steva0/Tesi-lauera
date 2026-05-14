# Changelog Tesi RVC - Analisi di Sicurezza

## [2026-05-14] Implementazione RS — rvcRootId nel .sig

### Modifiche apportate

#### ProjectImage.cpl
- **Linea 197:** Aggiunto campo `var str rvcRootId` alla classe `CommitValidation`
  - Descr: ID dell'ultimo commit di _rvc_root al momento del commit corrente
  - Scopo: Ancorare ogni commit alla versione di _rvc_root valida in quel momento
  - Questo permette al verificatore di determinare quale master.pub usare e di rilevare regressioni della root of trust

- **Linea 464-466:** Nel metodo `SignAndSaveToRepository()`, aggiunto codice per recuperare rvcRootId:
  ```cpl
  cv.rvcRootId := RvcEngine.getLastCommit('_rvc_root', nil, nil, repos, rp)
  ```
  - Viene eseguito automaticamente per ogni commit (salvo _rvc_root stesso)
  - Recupera il UID base36 dell'ultimo commit della meta-repository

#### Integrity.cpl
- **Linea 33-49:** Aggiunta nuova funzione `verifyRvcRootId()`
  - Verifica che l'ID di _rvc_root sia non-decrescente nella catena cronologica
  - Implementa il vincolo: commit N non può avere rvcRootId più vecchio di commit N-1
  - Usa confronto lessicografico su string IDs (valido perché i UID base36 timestamp sono ordinati cronologicamente)
  - Salta la verifica se prevRvcRootId o rvcRootId sono nil (permette retrocompatibilità)

### Compilazione
- Compilati con `cpl.exe`:
  - `rvc2/ProjectImage.cpl` → `rvc2/ProjectImage.pcd`
  - `rvc2/Integrity.cpl` → `rvc2/Integrity.pcd`

### Testing
✅ **Test 01 (reset_e_init):** PASSA
- Creazione _rvc_root con rvcRootId=nil (primo commit)
- Creazione progetto simulazione con rvcRootId=ID(_rvc_root)
- Tutti i .sig contengono il campo rvcRootId

✅ **Test 02 (commit_workflow):** PASSA
- Michele: commit con rvcRootId=ID(_rvc_root) ✓
- Luigi: commit con rvcRootId=ID(_rvc_root) ✓
- Hacker: bloccato (non autorizzato) ✓
- Integrity check: tutti OK con catena intatta

✅ **Test 03 (protezione_file_speciali):** PASSA
- Luigi tenta modifica allowed_Dipendenti: BLOCCATO (non Responsabile) ✓
- Michele modifica allowed_Dipendenti: OK (Responsabile) ✓
- Luigi tenta abbassamento livello: BLOCCATO (RS11) ✓

⏳ **Test 04-07:** In corso...

### Impatto sulla tesi
- Capitolo 6: Aggiunto RS (rvcRootId) come miglioramento implementato
- Capitolo 7: Verifica che gli scenari di attacco siano ancora rilevati correttamente
- Capitolo 8: Conclusioni rimangono invariate

### Note tecniche
- **Retrocompatibilità:** Il campo è facoltativo (nil per vecchi .sig compilati prima di questa modifica)
- **Performance:** Nessun impatto (getLastCommit è già cached dal verificatore)
- **Sicurezza:** Impedisce la regression della root of trust quando un admin compromesso tenta di ripristinare una vecchia versione di _rvc_root
- **Limitazione nota:** Il campo per commit di _rvc_root stesso contiene il suo stesso ID (non c'è _rvc_root precedente per _rvc_root)
