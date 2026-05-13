# Changelog implementazioni RVC

Formato: `[DATA] FILE — descrizione sintetica della modifica`
Ogni riga = una modifica atomica. Aggiornare ad ogni sessione di lavoro.

---

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
