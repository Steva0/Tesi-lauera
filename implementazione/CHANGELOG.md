# Changelog implementazioni RVC

Formato: `[DATA] FILE — descrizione sintetica della modifica`
Ogni riga = una modifica atomica. Aggiornare ad ogni sessione di lavoro.

---

[2026-05-14] rvc2/ProjectImage.cpl — F01 Branch Redaction (COMPLETATA): SignAndSaveToRepository() aggiunto param branch:=nil; propaga branchName a CommitValidation per .sig
[2026-05-14] rvc2/ProjectImage.cpl — CommitValidation: aggiunto campo var str branchName (riga 199)
[2026-05-14] rvc2/ProjectImage.cpl — Commit(): passa branch param a SignAndSaveToRepository (riga 305)
[2026-05-14] rvc2/ProjectImage.cpl — Recording() e NewProject(): passano branch:=nil a SignAndSaveToRepository
[2026-05-14] rvc2/ProjectImage.cpl — GetBranchCommits() (NEW): helper per cercare commit per branch, legge sia da .sig (campo branchName) che da filename pattern [branchName]
[2026-05-14] rvc2/ProjectImage.cpl — RedactBranch(): usa GetBranchCommits() per trovare tutti i commit del branch, itera e chiama Redact() per ognuno
[2026-05-14] rvc2/ProjectImage.cpl — byStrDescending() (NEW): helper di sort per string array in ordine discendente
[2026-05-14] test_rvc/test_branch_with_changes.cmd (NEW) — test completo F01 Branch Redaction: init → 2 commit main + 2 commit branch → redact branch → integrity
[2026-05-14] Risultati test: Redatti 2/2 commit del branch feature_work; entrambi [REDACTED] con redact_zip:OK + redact_sig:OK(master); auto-marked branch_status=compromised ✓
[2026-05-14] Limitazione NOTA: Commit con "Nothing to do!" non salvati in repository (RVC architecture), non possono essere redatti — soluzione: assicurarsi che commit abbiano modifiche reali
[2026-05-14] rvc2/ProjectImage.cpl — Blocco commit vuoti: Commit() ora verifica che ZIP non sia vuoto (0 file) usando ArchiverByExt + Dir(); blocca con "Nothing to commit (no changes detected)" ✓
[2026-05-14] test_rvc/test_empty_block.cmd (NEW) — verifica blocco commit vuoti: Test 1 empty (bloccato) + Test 2 with changes (successo)
[2026-05-14] rvc2/FileManifest.cpl — Conversione al maschile: "una commit" → "un commit", "la commit" → "il commit", etc. (10+ occorrenze)
[2026-05-14] rvc2/ProjectImage.cpl — Conversione al maschile: tutte le stampe relative a commit convertite da femminile a maschile (20+ occorrenze)
[2026-05-14] rvc2/RvcEngine.cpl — Conversione al maschile: "la commit" → "il commit", etc. (8+ occorrenze)
[2026-05-14] test_rvc/test_email.cmd (NEW) — verifica email come nomi utente: init, new-project, commit con mario@company.com ✓ FUNZIONA
[2026-05-14] NOTA: Email addresses come nomi utente funzionano correttamente; parser già robusto grazie a `{email}` nei filenames

[2026-05-12] rvc2/Init.cpl (nuovo) — helper puri per init repo e new-project: signWithKey, copyTextFile, readFileFromCommit, isKeyInFile, createRvcRootFiles, createProjectFiles, cleanupRvcRootDir, cleanupProjectDir
[2026-05-12] rvc2/Init.cpl — aggiunto import os,file,RvcEngine,FileManifest,genericPacker,scanDir,MsgReporter + var str errormsg
[2026-05-12] rvc2/Init.cpl — fix signWithKey: path con spazi ora quotati nel comando ssh-keygen
[2026-05-12] rvc2/Init.cpl — aggiunta copyPubKeyAsAllowedSigners: genera allowed_Dipendenti in formato OpenSSH allowed_signers (principal + chiave)
[2026-05-12] rvc2/Init.cpl — createRvcRootFiles e createProjectFiles: usano copyPubKeyAsAllowedSigners; createRvcRootFiles aggiunto param author
[2026-05-12] rvc2/ProjectImage.cpl — aggiunti metodi InitRepo() e NewProject() alla classe ProjectImage
[2026-05-12] rvc2/ProjectImage.cpl — import Init aggiunto; cleanupTmpDir sostituito con cleanupRvcRootDir/cleanupProjectDir
[2026-05-12] rvc2/ProjectImage.cpl — SaveAndSignCommitSignature: fallback su default_key da config se identities/<author> non trovato; path quotati; log non più hardcoded
[2026-05-12] rvc2/ProjectImage.cpl — ReadConfig e WriteConfig: corretto path (era \rvc.config, ora \rvc\rvc.config)
[2026-05-12] rvc.cpl — aggiunti dispatch "init", "new-project", "config" + aggiornato usage()
[2026-05-12] rvc.cpl — aggiunto import ReadConfig, WriteConfig da ProjectImage
[2026-05-12] rvc.cpl — effectiveAuthor: -author salva in config al primo uso, successive esecuzioni lo leggono automaticamente
[2026-05-12] rvc.cpl — fix IntVal() al posto di Int() per conversione str→int del parametro -level
[2026-05-12] rvc2/Init.cpl — cleanupRvcRootDir e cleanupProjectDir: aggiunto os.Rd() per rimuovere la directory temporanea dopo i file
[2026-05-12] rvc2/Integrity.cpl (nuovo) — verifyCumulativeHash: verifica blockchain hash (primo commit: hash=cumulative; successivi: SHA256(hash+prevCumulative))
[2026-05-12] rvc2/ProjectImage.cpl — aggiunto import Integrity; aggiunto metodo VerifyIntegrity() alla classe ProjectImage
[2026-05-12] rvc2/ProjectImage.cpl — VerifyIntegrity: output dettagliato hash/catena/firma per commit, contatori problemi/warning, supporto all-projects (project=nil)
[2026-05-12] rvc2/ProjectImage.cpl — VerifyIntegrity: per _rvc_root usa master.pub (prefissato con cv.author) invece di allowed_Dipendenti per la verifica firma
[2026-05-12] rvc.cpl — aggiunto dispatch "integrity"
[2026-05-12] rvc2/Integrity.cpl (nuovo) — verifyCumulativeHash: verifica blockchain hash
[2026-05-12] rvc2/ProjectImage.cpl — import Integrity; aggiunto VerifyIntegrity() con output dettagliato hash/catena/firma, all-projects, _rvc_root su master.pub, fallback allowed_Dipendenti
[2026-05-12] rvc2/ProjectImage.cpl — getAuthorPubKeyContent(): legge chiave pubblica da identities/<author>.pub o default_key+.pub
[2026-05-12] rvc2/ProjectImage.cpl — CheckValidity(): pre-commit enforcement, blocca commit se chiave autore non in allowed_Dipendenti (security_level >= 2)
[2026-05-12] rvc2/ProjectImage.cpl — Commit(): chiama CheckValidity() prima di CreateNewVersion per aggiornamenti
[2026-05-12] rvc2/ProjectImage.cpl — CheckValidity(): protezione file speciali (allowed_Dipendenti/.rvc_policy richiedono Responsabile in allowed_Responsabili)
[2026-05-12] rvc2/ProjectImage.cpl — CheckValidity(): usa getFileFromHistory() per trovare .rvc_policy e allowed_Dipendenti in commit incrementali
[2026-05-12] rvc2/ProjectImage.cpl — getFileFromHistory(): risale la history per trovare un file in commit incrementali (ogni ZIP contiene solo file modificati)
[2026-05-12] rvc2/ProjectImage.cpl — VerifyIntegrity(): authority chain check — se un commit modifica file speciali verifica che il firmatario fosse in allowed_Responsabili; output autorita:OK/FAIL
[2026-05-12] rvc2/ProjectImage.cpl — VerifyIntegrity(): legge allowed_Responsabili da _rvc_root una volta per progetto (cache nel loop)
[2026-05-12] rvc2/Init.cpl — createRvcRootFiles(): aggiunto param author; usa copyPubKeyAsAllowedSigners per allowed_Dipendenti
[2026-05-12] C:\Users\stemic\stage\allowed_Responsabili — creato file con chiave Michele per init con responsabili
[2026-05-12] C:\Users\stemic\.ssh\luigi_key — generata chiave SSH per Luigi (dipendente non-Responsabile)
[2026-05-12] C:\Users\stemic\stage\comandi_rvc.cmd — aggiornato file comandi di riferimento
[2026-05-12] rvc2/ProjectImage.cpl — VerifyIntegrity(): aggiunto param silent:=false per uso interno (level 3 e _rvc_root pre-check)
[2026-05-12] rvc2/ProjectImage.cpl — VerifyIntegrity(): verifica _rvc_root come root of trust PRIMA di verificare i progetti; se fallisce, autorita non verificabile
[2026-05-12] rvc2/ProjectImage.cpl — CheckValidity(): level 3 = esegue VerifyIntegrity silenzioso prima del commit; blocca se storia non integra
[2026-05-12] C:\Users\stemic\.ssh\luigi_key — chiave SSH generata per Luigi (dipendente non-Responsabile)
[2026-05-12] rvc2/ProjectImage.cpl — VerifyIntegrity(): level 1 enforcement (firma:FAIL(richiesta) se signStatus=0 e level>=1); mostra [level=N] nell'header del progetto
[2026-05-12] rvc2/ProjectImage.cpl — SignAndSaveToRepository(): aggiunto param masterKey; se fornita usa Init.signWithKey al posto del signing SSH standard
[2026-05-12] rvc2/ProjectImage.cpl — Commit(): aggiunto param masterKey, propagato a SignAndSaveToRepository
[2026-05-12] rvc2/ProjectImage.cpl — SecurityInfo(): nuovo metodo — mostra root of trust, responsabili, livello e dipendenti autorizzati per un progetto
[2026-05-12] rvc.cpl — dispatch "security <progetto>" aggiunto; dispatch "commit" passa master-key a pm.Commit; dispatch "integrity" usa ok:=true
[2026-05-12] C:\Users\stemic\stage\allowed_Responsabili — file created con chiave Michele per init
[2026-05-12] _rvc_root — aggiornato con Luigi in allowed_Responsabili via commit con master-key
[2026-05-12] rvc2/ProjectImage.cpl — VerifyIntegrity(): catena verificata tramite lookup diretto su cv.prevId (robusto a timestamp non monotoni tra commit rapidi)
[2026-05-12] rvc2/ProjectImage.cpl — VerifyIntegrity(): getFileFromHistory usa reporter:=rp (reporter:=nil causava mancato riconoscimento di commit appena creati)
[2026-05-12] rvc2/ProjectImage.cpl — CheckValidity(): RS11 non-downgradable level — blocca abbassamento security_level anche per Responsabili
[2026-05-12] rvc2/ProjectImage.cpl — CheckValidity(): RS13 branch status — blocca commit su branch archiviati/compromessi (file speciale .rvc_branch_status)
[2026-05-12] rvc2/ProjectImage.cpl — CheckValidity(): fix Strtran per normalizzazione newline (LRtrim non rimuove Chr(10) in CPL); applicato a tutti i confronti di file speciali
[2026-05-12] rvc2/ProjectImage.cpl — CheckValidity(): "if specialFileChanged and result" — evita sovrascrittura errormsg quando branch check ha già bloccato
[2026-05-12] rvc.cpl — dispatch "integrity": ok:=true per evitare doppio messaggio di errore (VerifyIntegrity stampa già il resoconto)
[2026-05-12] C:\Users\stemic\stage\test_rvc\ — cartella con file .cmd per test di tutti i comandi: 01_reset_e_init, 02_commit_workflow, 03_protezione_file_speciali, 04_scenari_attacco, 05_rvcroot_e_master_key, 06_verifica_livelli, 07_branch_status
[2026-05-13] rvc2/ProjectImage.cpl — VerifyIntegrity(): aggiunto parametro opzionale masterPubPath; se fornito estrae master.pub dall'ultimo commit di _rvc_root e confronta con chiave esterna; OK prosegue, FAIL blocca tutto (catena non verificabile)
[2026-05-13] rvc.cpl — dispatch "integrity": passa -master-pub=<path> a VerifyIntegrity come masterPubPath
[2026-05-13] rvc.cpl — usage(): aggiornato con [-master-pub=<path>] per integrity
[2026-05-13] C:\Users\stemic\stage\test_rvc\test_masterpub_auto.cmd — script test per verifica -master-pub (OK con chiave corretta, FAIL con chiave sbagliata)
[2026-05-13] rvc2/ProjectImage.cpl — SecurityInfo(): aggiunto branch status corrente del progetto (legge .rvc_branch_status da history, default "active")
[2026-05-13] rvc2/ProjectImage.cpl — VerifyIntegrity(): per ogni commit che contiene .rvc_branch_status, mostra "branch:<valore>" nella riga di output
[2026-05-13] rvc2/ProjectImage.cpl — NewProject(): check Responsabile ora obbligatorio; blocca se allowed_Responsabili è vuoto (prima saltava il controllo)
[2026-05-13] rvc2/ProjectImage.cpl — NewProject(): fallback su default_key da config per leggere la chiave pubblica dell'author (non solo identities/<author>.pub)
[2026-05-13] rvc2/ProjectImage.cpl — NewProject(): se -signers non fornito, usa la chiave dell'author (da config) come sorgente per allowed_Dipendenti; auto-inclusione garantita
[2026-05-13] rvc2/ProjectImage.cpl — NewProject(): se chiave author non è in allowed_Dipendenti del file -signers fornito, viene aggiunta automaticamente
[2026-05-13] rvc2/ProjectImage.cpl — InitRepo(): se -op-key non fornito, usa default_key dal config + ".pub" come chiave operativa per allowed_Dipendenti di _rvc_root
[2026-05-13] rvc2/ProjectImage.cpl — CommitValidation: aggiunti campi F01 (redacted, redactionZipHash, redactionLegalRef, redactionContent, redactionCount, redactionTimestamp, redactionOriginalSig)
[2026-05-13] rvc2/ProjectImage.cpl — ReadSigText(): nuova funzione; estrae il blocco SSH signature dal .sig per preservarlo come evidenza nella redazione
[2026-05-13] rvc2/ProjectImage.cpl — Redact(): nuovo metodo F01; sostituisce ZIP con REDACTION_NOTICE.json, aggiunge campi di redazione al .sig, ri-firma con master key; preserva firma originale dipendente in redactionOriginalSig
[2026-05-13] rvc2/ProjectImage.cpl — VerifyIntegrity(): per commit redatti mostra riga [REDACTED] con redact_zip:OK/FAIL, redact_sig:OK(master)/FAIL, count, legal_ref
[2026-05-13] rvc2/ProjectImage.cpl — VerifyIntegrity(): skip hash e catena per commit redatti; verifica firma master key invece di firma dipendente
[2026-05-13] rvc2/ProjectImage.cpl — VerifyIntegrity(): catena post-redazione corretta; se commit precedente è redatto il suo ZIP è cambiato, prevHash non verificabile via ZIP ma è corretto per costruzione (skip)
[2026-05-13] rvc2/ProjectImage.cpl — VerifyIntegrity(): primo commit di _rvc_root mostrato con label [BOOTSTRAP] (verifica self-contained: master.pub estratta dallo stesso ZIP)
[2026-05-13] rvc.cpl — dispatch "redact" aggiunto; usage() aggiornato con sintassi del comando
[2026-05-13] C:\Users\stemic\stage\test_rvc\test_bootstrap_redact.cmd — script test: [BOOTSTRAP] su _rvc_root, redazione commit con GDPR ref, integrity post-redazione (catena integra)
[2026-05-13] rvc2/Init.cpl — aggiunta funzione sshKeygenExe(): centralizza path ssh-keygen (era hardcodato in 3 punti); signWithKey aggiornato a usarla
[2026-05-13] rvc2/ProjectImage.cpl — SaveAndSignCommitSignature() e VerifySignature(): sostituito path ssh-keygen hardcodato con Init.sshKeygenExe()
[2026-05-13] rvc2/ProjectImage.cpl — CommitValidation: aggiunti campi securityLevel, branchStatus, allowedSigners (estratti dallo ZIP e scritti nel .sig; permettono verifica senza aprire lo ZIP, necessario per level 4 cifrato)
[2026-05-13] rvc2/ProjectImage.cpl — SignAndSaveToRepository(): popola securityLevel da .rvc_policy (working dir o history), branchStatus da .rvc_branch_status (working dir o history, default "active"), allowedSigners da allowed_Dipendenti (solo level >= 2)
[2026-05-13] rvc2/ProjectImage.cpl — NewProject(): blocca creazione di progetto con nome "_rvc_root" (nome riservato al sistema)
[2026-05-13] rvc2/ProjectImage.cpl — Redact(): dopo redazione controlla branch_status; se non è già "compromised" stampa [WARN] con istruzione per aggiornarlo manualmente
[2026-05-13] rvc2/Init.cpl — createRvcRootFiles(): aggiunto parametro opKeysPath per file multi-admin in formato allowed_signers; ha precedenza su opKeyPath se entrambi forniti
[2026-05-13] rvc2/ProjectImage.cpl — InitRepo(): aggiunto parametro opKeysPath passato a createRvcRootFiles; fallback su default_key solo se né opKeyPath né opKeysPath forniti
[2026-05-13] rvc.cpl — dispatch "init": aggiunto -op-keys=<path>; usage aggiornato con [-op-key=<path> | -op-keys=<path>]
[2026-05-13] rvc2/ProjectImage.cpl — NewProject(): biforcazione admin/responsabile per level 0/1 vs 2+; level<2 richiede chiave in _rvc_root/allowed_Dipendenti (solo admin); level>=2 richiede chiave in allowed_Responsabili (comportamento precedente)
[2026-05-13] rvc2/ProjectImage.cpl — CommitValidation: aggiunto campo uniqueId (RS03); formato timestamp_base36 + '_' + prime 8 cifre SHA256 ZIP (es. 0Q6ZML7LYA_A3F2B1C4); content-dependent, non manipolabile via timestamp arbitrario
[2026-05-13] rvc2/ProjectImage.cpl — SignAndSaveToRepository(): popola cv.uniqueId := cv.id + '_' + Left(cv.hash, 8) dopo il calcolo dell'hash ZIP
[2026-05-13] rvc2/ProjectImage.cpl — SignAndSaveToRepository(): aggiunto default '0' per securityLevel se .rvc_policy non trovato (evita IntVal(nil))
[2026-05-13] rvc2/ProjectImage.cpl — VerifyIntegrity(): mostra uniqueId nell'output invece del solo timestamp; verifica che uniqueId == id + '_' + hash[:8]; uniqueId:FAIL se manomesso
[2026-05-13] rvc2/ProjectImage.cpl — VerifyIntegrity(): per commit redatti, aggiorna lastKnownDipendenti da cv.allowedSigners (il ZIP redatto non ha piu` allowed_Dipendenti)
[2026-05-13] rvc2/ProjectImage.cpl — fileIdFromCommitId(): nuova funzione helper; estrae il timestamp dal formato esteso RS03 per i file lookup nella repo
[2026-05-13] rvc2/ProjectImage.cpl — Redact(): usa fileIdFromCommitId per tutti i file lookup; aggiunto parametro dir per auto-commit branch_status=compromised con chiave operativa del responsabile
[2026-05-13] rvc2/ProjectImage.cpl — commitHashPrefixLen(): nuova funzione; centralizza il numero di caratteri hash nel uniqueId (default 8, testato anche 16); modificare qui per cambiare la lunghezza
[2026-05-13] rvc2/ProjectImage.cpl — RS03 nei nomi file: ZIP e .sig rinominati con formato timestamp_hash8 (es. simulazione.0Q70OBCWUV_A3F2B1C4.zip); hash nel nome rende il file content-dependent e non sostituibile silenziosamente
[2026-05-13] rvc2/RvcEngine.cpl — getFileName(): aggiunto fallback RS03 per ricerca file con suffisso hash nel nome (pattern commit* oltre a commit.*)
[2026-05-13] rvc2/RvcEngine.cpl — getCommitFileNameInPath(): aggiunto fallback RS03 (pattern commit*)
[2026-05-13] rvc2/RvcEngine.cpl — getSignatureFileNameForExtraction(): aggiunto fallback RS03 con os.Dir per trovare .sig con suffisso hash
[2026-05-13] rvc2/RvcEngine.cpl — updateCacheEntry(): nuova procedura pubblica; aggiorna cache SQLite dopo rename RS03 (os.Delete non funziona su SQLite aperto)
[2026-05-13] rvc2/Init.cpl — createRvcRootFiles(): aggiunge .rvc_policy con security_level=2 a _rvc_root (come da tesi: _rvc_root opera sempre a level 2+)
[2026-05-13] rvc2/Init.cpl — cleanupRvcRootDir(): aggiunto os.Delete per .rvc_policy
[2026-05-13] rvc2/ProjectImage.cpl — CheckValidity(): aggiunto parametro masterKey:=nil; bypass check allowed_Dipendenti se masterKey != nil (chiave master ha autorità suprema)
[2026-05-13] rvc2/ProjectImage.cpl — CheckValidity(): regole speciali per _rvc_root: allowed_Dipendenti/master.pub richiedono master key; allowed_Responsabili ammette chiave operativa admin
[2026-05-13] rvc2/ProjectImage.cpl — Commit(): passa masterKey a CheckValidity
[2026-05-13] rvc2/ProjectImage.cpl — VerifyIntegrity(): refactoring verifica _rvc_root: usa masterPubBootstrap (primo commit) per TUTTI i commit successivi; previene attacco di sostituzione master.pub
[2026-05-13] rvc2/ProjectImage.cpl — VerifyIntegrity(): per _rvc_root, fallback a chiave operativa (allowed_Dipendenti) se firma master key fallisce (per commit che modificano solo allowed_Responsabili)
[2026-05-13] rvc2/ProjectImage.cpl — VerifyIntegrity(): authority check speciale per _rvc_root (allowed_Dipendenti/master.pub richiede masterPubBootstrap)
[2026-05-13] C:\Users\stemic\stage\test_rvc\test_revoca_chiave.cmd — nuovo script test: revoca chiave operativa con master key, checkout/commit _rvc_root, verifica integrità pre/post revoca
[2026-05-14] rvc2/ProjectImage.cpl — CommitValidation: aggiunto campo rvcRootId (ID ultimo commit di _rvc_root al momento della commit corrente, per ancorare a root of trust)
[2026-05-14] rvc2/ProjectImage.cpl — SignAndSaveToRepository(): recupera rvcRootId via RvcEngine.getLastCommit('_rvc_root') durante ogni commit; salvato nel .sig per verifica offline
[2026-05-14] rvc2/Integrity.cpl — verifyRvcRootId(): nuova funzione; verifica che rvcRootId sia non-decrescente nella catena (commit N non ha rvcRootId < commit N-1); usa confronto lessicografico su string IDs
[2026-05-14] rvc2/ProjectImage.cpl + rvc2/Integrity.cpl — compilati con cpl.exe per aggiornare bytecode .pcd
[2026-05-14] C:\Users\stemic\stage\test_rvc\03_protezione_file_speciali.cmd — fix: sostituito `update` con `checkout` (righe 18, 35) per ripristino file corretti da repository
[2026-05-14] C:\Users\stemic\stage\test_rvc\04_scenari_attacco.cmd — fix: Python → PowerShell per tampering file in cmd.exe (righe 15-24, 36-45, 54-61)
[2026-05-14] Test execution (2026-05-14) — Tutti 7 test .cmd eseguiti e superati:
  - Test 01 (init): init repo + new-project ✓
  - Test 02 (workflow): commit Michele, Luigi, Hacker-blocking ✓
  - Test 03 (protezione): Luigi bloccato da allowed_Dipendenti, security_level non abbassabile ✓
  - Test 04 (attacchi): S1/S2/S3 rilevati correttamente (hash:FAIL, catena:FAIL) ✓
  - Test 05 (_rvc_root): master key, aggiunta Responsabili, BOOTSTRAP marker ✓
  - Test 06 (livelli): level 0/1 bloccati, level 2/3 creati ✓
  - Test 07 (branch): archivio funzionante, commit su archived branch bloccato ✓
[2026-05-14] rvc2/ProjectImage.cpl — Debug output: "[DEBUG-ALLOWED] Trovato in history:" per trace allowed_Dipendenti lettura
[2026-05-14] Verificatore (VerifyIntegrity) — testato su tutti scenari: hash, catena, firma, autorita, branch status, rvcRootId verificati correttamente
[2026-05-14] rvc/rvc.cpl — Completamente riscritto funzione usage() (linee 57-94):
  - Aggiunta 6 categorie logiche: ADMIN, WORKFLOW, INFORMATION, MERGE, VERIFICATION, CONFIGURATION
  - Una riga di descrizione per ogni comando (non solo sintassi)
  - Parametri indentati per leggibilità
  - Abbreviazioni consistenti (p=project, b=branch, t=tag, a=author)
  - Sezione GLOBAL PARAMETERS per parametri comuni
  - 6 esempi pratici di utilizzo
  - Output migliorato da ~32 a ~94 righe, ma molto più leggibile
[2026-05-14] C:\Users\stemic\rvc\README.md — Creato documentazione completa (~2500 righe):
  - Quick Start (5 linee per setup iniziale)
  - Commands Overview (tabella con tutti i 17 comandi)
  - Documentazione dettagliata per ogni comando:
    * Sintassi con tipo di parametri (REQUIRED, optional, default)
    * Descrizione cosa fa il comando
    * Parametri spiegati singolarmente
    * Security checks applicati (se presenti)
    * Output format e esempio
    * 2-3 esempi di utilizzo per comando
  - Sezione GLOBAL PARAMETERS (validi per tutti)
  - Configuration section per config command
  - Complete workflow examples (init → commit → verify)
  - Security enforcement examples con error messages
  - Merge conflict resolution example
  - Integrity verification example (simula attacco)
  - Common errors & solutions table (8 casi comuni)
  - File formats documentation (.sig CommitValidation, .FileManifest)
  - Architecture notes (RS03, rvcRootId, cumulative hash)
[2026-05-14] C:\Users\stemic\stage\test_rvc\test_all_commands.cmd — Creato script test completo:
  - Testa tutti i 17 comandi RVC
  - Testa combinazioni di parametri
  - Verificate categorie: admin, workflow, info, diff, merge, verification, special
[2026-05-14] Help output validation — Nuovo output visualizzato e verificato:
  - Output ordinato per categoria
  - Ogni comando con descrizione breve
  - Parametri ben formattati e leggibili
  - Terminal-friendly (non affatica su schermi stretti)
[2026-05-14] rvc2/ProjectImage.cpl — CommitValidation: aggiunti 9 campi F01 Redazione Trasparente:
  - redacted (bool): true se commit redatto dalla master key
  - redactionZipHash (str): SHA256 del nuovo ZIP sostitutivo
  - redactionAuthority (str): impronta (SHA256) della master key che ha autorizzato redazione
  - redactionTimestamp (str): quando redazione è stata eseguita
  - redactionLegalRef (str): riferimento legale/organizzativo della redazione
  - redactionContent (str): tipo contenuto (none/sanitized/encrypted_master/encrypted_authority)
  - redactionSignature (str): firma master key su REDACTION_NOTICE.json (evidenza della decisione)
  - redactionCount (str): contatore redazioni (parte da '1', incrementa per ri-redazioni)
  - redactionOriginalSig (str): firma SSH originale del dipendente (evidenza forense preservata)
[2026-05-14] rvc2/ProjectImage.cpl — Redact() singolo: implementazione completa F01
  - Lettura commit originale dal .sig
  - Preservazione firma SSH originale in redactionOriginalSig
  - Creazione REDACTION_NOTICE.json con metadati completi
  - Firma REDACTION_NOTICE con master key → redactionSignature
  - Creazione ZIP sostitutivo contenente solo REDACTION_NOTICE
  - Calcolo SHA256(nuovo ZIP) → redactionZipHash
  - Salvataggio cv aggiornato (redacted:true) e firma con master key
  - Sostituzione ZIP e .sig originali nel repository
  - Auto-commit branch_status=compromised con master key
  - Proprietà critica: hash originale e cumulativeHash NON vengono modificati (preserva catena)
[2026-05-14] rvc2/ProjectImage.cpl — VerifyIntegrity() modificato per redacted commits:
  - Rileva redacted:true e mostra [REDACTED] nello stato del commit
  - Salta verificazione hash ordinaria (il ZIP è sostituito)
  - Verifica redactionZipHash (hash del nuovo ZIP sostitutivo) — fallisce se ZIP modificato
  - Verifica firma master key (non firma dipendente originale) usando master.pub da _rvc_root
  - Verifica redactionSignature è presente (altrimenti commit invalido)
  - Preserva catena anche per commit redatti: cumulativeHash originale non modificato
  - Commit successivi: prevHash non verificabile per commit redatti (ZIP sostituito), ma OK per costruzione
  - Output mostra: redact_zip:OK/FAIL e redact_sig:OK(master)/FAIL
[2026-05-14] rvc2/Integrity.cpl — verifyRvcRootId() già presente per non-decreasing lexicographic check
[2026-05-14] Test F01: test_redact_singolo.cmd creato per validazione redazione singolo
  - Verifica commit redatto mostra [REDACTED]
  - Verifica redact_zip_hash corrisponde
  - Verifica redact_sig:OK(master) — firma master key valida
  - Verifica commit successivi verificano correctamente (prevHash OK per commit redatti)
  - STATUS: ✓ FUNZIONANTE — redacted commits mostrano [REDACTED] e verificano con redact_zip:OK + redact_sig:OK(master)
[2026-05-14] rvc2/ProjectImage.cpl — RedactRange() nuovo metodo per F01 range redaction
  - Sintassi: -range=id1..id2 specifica sequenza di commit
  - Valida che i commit siano nella storia del progetto
  - Ordina automaticamente gli indici (non importa ordine di inserimento)
  - Itera da più vecchio a più recente nel range
  - Chiama Redact() per ogni commit
  - Ogni commit riceve redactionCount incrementato singolarmente
  - Auto-marca branch come compromesso se almeno un commit redatto
  - Output: "Redatti N/M commit del range" e "Branch_status aggiornato a compromised"
[2026-05-14] rvc2/ProjectImage.cpl — RedactBranch() nuovo metodo per F01 branch redaction
  - Sintassi: -branch=<branchName> specifica intero branch
  - Usa getCommitsHistory(project, nil, branchName, ...) per recuperare commit del branch
  - Logica corretta ma filtaggio branch ha limitazioni in RvcEngine
  - Itera su tutti commit del branch e chiama Redact() per ognuno
  - Limiti noti: RvcEngine.getCommitsHistory() non filtra sempre correttamente per branch
[2026-05-14] rvc.cpl — Aggiunto dispatch per -id, -range, -branch nel comando redact
  - Parameter parsing esteso: rileva quale modalità redazione è richiesta
  - Chiama Redact() per -id (singolo)
  - Chiama RedactRange() per -range (sequenza)
  - Chiama RedactBranch() per -branch (intero branch)
  - Error handling: richiede esattamente uno dei tre parametri
[2026-05-14] Test F01: test_redact_range_branch.cmd creato per validazione range
  - Redazione su range di 2 commit consecutivi con -range=id1..id2
  - Crea 5 commit, redatta il range su 2 di loro
  - Verifica pre/post redazione
  - Test finale conclusivo:
    * Prima: 6 commit [OK]
    * Redact range su 2 commit consecutivi
    * Dopo: 2 [REDACTED] con redact_zip:OK + redact_sig:OK(master)
    * 4 commit rimanenti [OK] (precedenti e successivi)
    * Branch status aggiornato a compromised
  - STATUS: ✓ COMPLETO — redazione range funzionante e verificata
  - Limitazione nota: RedactBranch() ha limitazioni in RvcEngine filtraggio
[2026-05-14] rvc2/ProjectImage.cpl — RedactBranch() correzione parametro branch
  - ERRORE CORRETTO: parametro branch era passato come 3° (tag) invece che 2°
  - PRIMA: getCommitsHistory(project, nil, branchName, nil, true, ...)
  - DOPO: getCommitsHistory(project, branchName, nil, nil, true, ...)
  - Correzione permette al codice di tentare filtraggio corretto del branch
[2026-05-14] Test F01 COMPLETO: Test finale tutte e 3 le modalità di redazione
  - Test creato: PowerShell script test_f01_complete_final
  - Test SINGOLO (-id=<commitId>):
    * Status: ✓ FUNZIONANTE
    * Output: "Commit 0Q72SLNKGD_42955B32 di "demo" redatto."
    * Integrity mostra: [REDACTED] 0Q72SLNKGD_42955B32 redact_zip:OK redact_sig:OK(master)
  - Test RANGE (-range=id1..id2):
    * Status: ✓ FUNZIONANTE
    * Output: "Redatti 2/2 commit del range"
    * Integrity mostra: 2 [REDACTED] commit con redact_zip:OK redact_sig:OK(master)
    * Ordina automaticamente indici (non importa ordine input)
    * Commit precedenti/successivi rimangono [OK]
  - Test BRANCH (-branch=<branchName>):
    * Status: ⚠️ CODICE COMPLETO ma RvcEngine limitato
    * Errore: "Nessun commit trovato per il branch feature"
    * Causa: RvcEngine.getCommitsHistory() non registra commit su branch in history
    * Workaround: Usare -range con IDs estratti manualmente
    * Implicazione: Feature implementata ma RvcEngine ha limitazioni strutturali
  - RIEPILOGO FINALE: 
    * ✅ Singolo: COMPLETAMENTE FUNZIONANTE
    * ✅ Range: COMPLETAMENTE FUNZIONANTE
    * ✅ Branch: Codice completo, limitazioni in RvcEngine
  - NOTE IMPORTANTI:
    * Tutte le redazioni preservano proprieta` critiche (hash/cumulativeHash)
    * Tutti i commit redatti verificano correttamente in integrity
    * redactionCount traccia numero di redazioni per commit
    * Branch status aggiornato a compromised dopo redazioni
    * Tutti i commit successivi a redazioni verificano correttamente

[2026-05-15] STATUS CHECKPOINT — Stato stabile delle implementazioni:
  - **COMPLETATE**: RS01, RS02, RS03 (uniqueId nei file), RS04 (doc limitazioni timestamp), RS05, RS06, RS07, RS08, RS09/F01 (Redazione Trasparente singolo/range/branch), RS10 (master key succession), RS11 (non-downgradable levels), RS13 (branch status), RS15 (rvcRootId)
  - **IN SOSPESO**: RS12 (age encryption level 4)

[2026-05-15] rvc2/ProjectImage.cpl — RS14 (COMPLETATA): Permessi merge e allowed_Dipendenti per branch
  - CommitValidation: aggiunto campo `mergeFrom` (branch sorgente nei commit di merge)
  - getFileFromHistory(): aggiunto parametro opzionale `branch:=nil` per filtrare per branch specifico
  - CheckValidity(): aggiunto parametro `branch:=nil`; rileva primo commit di nuovo branch (solo Responsabile o Admin); legge allowed_Dipendenti dal branch specifico (non dalla storia globale)
  - Commit(): calcola mergeFrom da PendingMerge() leggendo branchName dal .sig del commit mergiato; ripristina file speciali del branch destinazione (allowed_Dipendenti, .rvc_policy, .rvc_branch_status) prima di CreateNewVersion() per evitare che il branch sorgente li sovrascriva
  - SignAndSaveToRepository(): aggiunto parametro mergeFrom propagato a cv.mergeFrom nel .sig
  - VerifyIntegrity(): mostra [MERGE from:branchName] per commit di merge
  - Test (2026-05-15): merge feature→main ✓; [MERGE from:feature] in integrity ✓; allowed_Dipendenti main preservato dopo merge ✓; tutti commit [OK]
  - **TEST**: Tutti 7 test .cmd superati ✓; Verificatore integrity funzionante ✓; Helper functions centralizzate ✓
  - **TESI**: Capitoli 1-5 completati; Capitolo 6-8 scheletri vuoti, pronti per documentazione implementazioni e retest scenari
  - **AMBIENTE**: rvc callable globalmente, ssh-keygen e age bundled in C:\Users\stemic\rvc\, config supporta default_author e default_key
