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
