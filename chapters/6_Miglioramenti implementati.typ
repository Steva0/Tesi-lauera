#import "../config/thesis-config.typ": gl, glpl, glossary-style, linkfn, terminal, terminal-io
#import "../config/variables.typ": *
#pagebreak(to:"odd")

= Miglioramenti implementati <cap:miglioramenti-implementati>
#text(style: "italic", [
    Il capitolo descrive le modifiche apportate al codice sorgente di #gl("rvc", capitalize: true) in risposta alle vulnerabilità e alle carenze individuate nei capitoli precedenti. Per ciascun intervento sono illustrati la motivazione, le scelte progettuali e gli estratti di codice #gl("cpl", capitalize: true) rilevanti.
])
#v(1em)

== Visione d'insieme

La @cap:modello-sicurezza ha definito quindici requisiti di sicurezza distribuiti in cinque categorie — integrità, autenticità, gestione delle identità, sicurezza configurabile e gestione dei branch — e ne ha quantificato il divario rispetto alla versione iniziale di #gl("rvc", capitalize: true). La @cap:simulazione-scenari-di-attacco ha verificato empiricamente le conseguenze di tali carenze attraverso quattro scenari di attacco progressivi. L'implementazione ha colmato sistematicamente il divario intervenendo sui moduli `ProjectImage.cpl`, `RvcEngine.cpl`, `FileManifest.cpl` e sul nuovo modulo `Init.cpl`.

Il punto architetturale comune a quasi tutti gli interventi è la classe `CommitValidation`, che rappresenta il contenuto serializzato del file .sig associato a ogni commit. Nella versione iniziale la struttura conteneva solo i campi necessari per la catena di hash; la sua estensione con i campi richiesti dal modello di sicurezza ha reso possibile implementare tutti gli altri controlli senza modificare né il formato dei file ZIP né il meccanismo di base del commit.

Le sezioni che seguono descrivono gli interventi nell'ordine delle cinque categorie di requisiti, il meccanismo di Redazione Trasparente e, infine, il lavoro di robustezza e correzione delle vulnerabilità di injection emerse dallo scenario S5.

== Estensione della struttura CommitValidation

La classe CommitValidation è il nucleo del file .sig: ogni campo che il verificatore deve controllare senza aprire lo ZIP deve essere presente in questa struttura. La scelta di includere metadati di sicurezza direttamente nel .sig è necessaria perché un verificatore che riceve una #gl("repository") da un canale non fidato non può presumere di riuscire ad aprire ogni ZIP — ad esempio perché cifrato al livello 4 — ma deve poter comunque accertare l'integrità e l'autenticità della catena.

La versione iniziale conteneva solo i campi strettamente necessari per la catena crittografica di base. Il modello di sicurezza ha richiesto tre gruppi di campi.

Il primo gruppo, già presente, costituisce la catena crittografica originale: hash dello ZIP corrente, hash dello ZIP precedente e hash cumulativo. Il secondo gruppo permette al verificatore di operare senza aprire lo ZIP: livello di sicurezza, stato del branch, chiavi autorizzate, riferimento all'ultimo commit di \_rvc_root e nome del branch vengono estratti dallo ZIP al momento del commit e scritti direttamente nel .sig. Il terzo gruppo supporta la Redazione Trasparente (sezione @cap:redazione[]) ed è compilato esclusivamente quando un commit viene redatto dalla chiave master.

#figure(caption: "Campi di CommitValidation")[
```cpl
class CommitValidation
  -- Gruppo 1: catena crittografica originale
  var str author, comment, fn
  var str id, prevId
  var str hash, prevHash, cumulativeHash
  var array[str] merged, mergedHash
  var str authorPublicKey

  -- Gruppo 2: campi del modello di sicurezza 
  var str securityLevel   -- 0-4
  var str branchStatus    -- active / archived / compromised
  var str allowedSigners  -- chiavi autorizzate separate da ';'
  var str rvcRootId       -- ID ultimo commit di \_rvc_root
  var str branchName, mergeFrom, recipients

  -- Gruppo 3: Redazione Trasparente
  var bool redacted
  var str redactionZipHash, redactionAuthority
  var str redactionTimestamp, redactionLegalRef
  var str redactionContent, redactionSignature
  var str redactionCount, redactionOriginalSig
end
```
]

La scelta di includere allowedSigners nel .sig — che è già firmato — garantisce che le chiavi autorizzate usate in fase di verifica siano esattamente quelle vigenti al momento del commit, e che non possano essere alterate successivamente. Questo risolve il problema della verifica storica: la revoca di un dipendente non invalida i commit prodotti prima della revoca, poiché le chiavi registrate nel loro .sig riflettono lo stato delle autorizzazioni vigente quando furono prodotti. Il campo recipients, analogo, serve alla cifratura al livello 4: elenca le chiavi SSH pubbliche dei destinatari autorizzati, consentendo al verificatore di controllarne la lista senza decifrare il file.

== Integrità e ordine verificabile (RS01–RS04)

I requisiti RS01 e RS02 erano già soddisfatti nella versione iniziale mediante la catena di hash cumulativi. L'intervento in questa categoria ha riguardato RS03 (unicità degli identificativi content-dependent) e RS04 (documentazione delle limitazioni).

#figure(caption: "Requisiti di integrità")[
  #table(
    columns: (auto, 1fr),
    table.header([*Requisito*], [*Descrizione*]),
    [RS01], [Verificabilità hash di ogni commit],
    [RS02], [Catena hash verificabile, modifica invalida i successivi],
    [RS03], [Identificativi univoci, non manipolabili tramite timestamp],
    [RS04], [Limitazioni temporali documentate esplicitamente],
  )
]

RS03 è stato soddisfatto aggiungendo al nome del file ZIP un suffisso di otto caratteri derivato dall'hash SHA256 del contenuto. RS04 è stato soddisfatto documentando esplicitamente nel @cap:modello-sicurezza i limiti strutturali della garanzia temporale assoluta, affidata al cumulativeHash e non al timestamp.

=== Identificativi content-dependent (RS03)

La versione iniziale utilizzava solo un timestamp codificato in #gl("base36") come identificativo del commit, con due problemi: collisioni tra commit generati nello stesso millisecondo e manipolabilità del contenuto senza modifica del nome file.

La soluzione adottata aggiunge al nome file un suffisso di otto caratteri derivato dall'hash SHA256 del contenuto del commit:

#figure(caption: "Formato nome file ZIP")[
```
mioprogetto.0Q7BK6WQRB_D7000B46.0Q7BK1LOZY_E168FAB3.{Michele}.zip
            └timestamp┘└─hash8─┘└──── prevId ──────┘
```
]

L'ID effettivo del commit è la coppia `timestamp_hash8`, ad esempio `0Q7BK6WQRB_D7000B46`. La generazione avviene in due fasi: creazione dello ZIP, poi calcolo dello SHA256 e rinomina del file includendo i primi otto caratteri dell'hash. Questo rende il nome _content-dependent_: qualsiasi sostituzione del contenuto modifica il nome e invalida la catena successiva.

#figure(caption: "Generazione ID content-dependent")[
```cpl
cv.hash := crypt.SHA256(zipPath)
newId := timestamp + '_' + Left(cv.hash, 8)
os.Rename(zipPath, Strtran(zipPath, oldId, newId))
```
]

È importante precisare cosa questa modifica garantisce e cosa no. Il suffisso content-dependent rende la sostituzione silenziosa rilevabile meccanicamente, ma la garanzia dell'ordine temporale assoluto rimane affidata al cumulativeHash: un sistema con orologio alterato può produrre timestamp arbitrari.

== Autenticità e non ripudio (RS05–RS07)

#figure(caption: "Requisiti di autenticità")[
  #table(
    columns: (auto, 1fr),
    table.header([*Requisito*], [*Descrizione*]),
    [RS05], [Radice di fiducia verificabile autonomamente],
    [RS06], [Firma SSH obbligatoria per livello >= 1],
    [RS07], [Ogni commit referenzia lo stato corrente di \_rvc_root],
  )
]

RS05 è stato soddisfatto introducendo il progetto speciale \_rvc_root, il cui primo commit include la chiave pubblica master direttamente nel .sig tramite il campo masterPubBootstrap. RS06 è stato soddisfatto rendendo la firma SSH obbligatoria per tutti i commit su progetti con livello ≥ 1, con namespace `-n file` che impedisce il riutilizzo della firma in altri contesti. RS07 è stato soddisfatto aggiungendo il campo rvcRootId in CommitValidation, che àncora crittograficamente ogni commit allo stato delle autorizzazioni vigente al momento della sua produzione.

=== Il progetto \_rvc_root e la chiave master (RS05)

Nella versione iniziale non esisteva alcuna radice di fiducia verificabile autonomamente. Il modello introduce \_rvc_root, un progetto speciale creato con `rvc init` che funge da ancora crittografica per l'intera #gl("repository").

L'inizializzazione richiede due chiavi distinte: la chiave pubblica master (`-master-pub=`) e la chiave privata master (`-master-key=`), più la chiave pubblica operativa dell'amministratore (`-op-key=`). La distinzione è intenzionale: la chiave master è destinata a un supporto _#gl("air-gapped")_ e usata esclusivamente per operazioni straordinarie, mentre la chiave operativa è quella impiegata nei commit ordinari.

#figure(caption: "Sintassi rvc init")[
```
rvc init
  -master-pub=<path>      chiave pubblica master       [OBBLIGATORIO]
  -master-key=<path>      chiave privata master        [OBBLIGATORIO]
  [-op-key=<path>]        chiave pubblica operativa admin (singola)
  [-op-keys=<path>]       file multi-admin (formato allowed_signers)
  [-responsabili=<path>]  chiavi responsabili di progetto
  [-author=<nome>]        nome dell'amministratore
  [-dir=<dir>]            directory di lavoro
  [-repo=<path>]          path della repository
```
]

#terminal-io(
  [rvc init -master-pub=C:\chiavi\master.pub -master-key=C:\chiavi\master_key \
   -op-key=C:\Users\Michele\.ssh\id_ed25519.pub \
   -responsabili=C:\chiavi\responsabili.pub \
   -author=Michele -repo=C:\stage\repo],
  [analyzing repository C:\stage\repo\ ...\
   packing \_rvc_root.0Q7BJJFHEH.\{Michele\}.zip\
   copying \_rvc_root.0Q7BJJFHEH.0Q7BJJFHEH_1EEBDB09.sig to C:\stage\repo\ ...\
   Repository inizializzata. Progetto \_rvc_root creato.]
)

Il primo commit di \_rvc_root contiene tre file speciali: master.pub, allowed_Dipendenti e allowed_Responsabili. Il campo masterPubBootstrap nel .sig contiene la chiave pubblica master in chiaro, rendendola disponibile al verificatore senza dipendenze da infrastrutture esterne. Qualsiasi verifica dell'intera catena di fiducia può partire da questa chiave, distribuibile fuori banda. Tutti i commit su \_rvc_root devono essere firmati con la chiave master; il motore rifiuta qualsiasi commit che non soddisfi questo vincolo, indipendentemente dall'identità del richiedente.

=== Firma SSH obbligatoria nel flusso di commit (RS06)

Nella versione iniziale la firma SSH era opzionale. Il @cap:simulazione-scenari-di-attacco ha dimostrato che questa opzionalità consente di riscrivere la storia di un progetto senza produrre anomalie nel verificatore.

Il modello richiede che la firma sia prodotta per tutti i commit su progetti con livello ≥ 1 e che la sua assenza o invalidità sia rilevata come anomalia. L'intervento ha integrato la firma direttamente nel flusso di commit tramite la procedura `SaveAndSignCommitSignature`, che invoca `ssh-keygen -Y sign` al termine della costruzione del .sig. Il namespace `-n file` è scelto per il suo significato nella specifica OpenSSH: le firme prodotte in tale contesto non possono essere riutilizzate per l'autenticazione SSH, prevenendo attacchi di riutilizzo.

#figure(caption: "SaveAndSignCommitSignature")[
```cpl
proc SaveAndSignCommitSignature(str path, str project, CommitValidation cv, bool sign)
  -- Ricerca della chiave privata
  keyPath := identityDir + cv.author
  if !file.Exist(keyPath) then keyPath := ReadConfig('default_key') end

  -- Firma del file .sig con ssh-keygen -Y sign -n file
  if sign and keyPath <> nil
    os.Exec('cmd /C ssh-keygen -Y sign -n file -f "' 
            + keyPath + '" "' + sigPath + '"')
    -- Accodamento della firma al file .sig 
    appendAndDelete(sigPath + '.sig', sigPath)
  end
end
```
]

La chiave privata viene cercata prima per nome nel registro delle identità (che consente a sistemi multi-utente di avere ciascuno la propria chiave), poi come chiave di default nella configurazione utente impostabile con:

#terminal-io(
  [rvc config -author=Michele -private_key=C:\Users\Michele\.ssh\id_ed25519],
  [default_author : Michele\
   default_key    : C:\Users\Michele\.ssh\id_ed25519]
)

Le tre funzioni che gestiscono la configurazione locale sono:

#figure(caption: "Gestione configurazione locale")[
```cpl
func str ReadConfig(str key)

proc WriteConfig(str key, str value)

proc EnsureConfig()
```
]

=== Ancoraggio a \_rvc_root (RS07)

Anche con la firma obbligatoria, un verificatore che riceve una #gl("repository") in un momento successivo non dispone di informazioni sullo stato di \_rvc_root — e quindi sulle autorizzazioni vigenti — al momento di ogni commit. Senza questa informazione non è possibile distinguere un commit prodotto prima di una revoca da uno prodotto dopo.

La soluzione è il campo rvcRootId in CommitValidation: al momento di ogni commit il motore recupera l'ID dell'ultimo commit di \_rvc_root e lo scrive nel .sig. Questo crea un legame crittografico tra ogni commit e lo stato delle autorizzazioni vigente in quel momento, rendendo la verifica storica accurata anche dopo cambi di personale o revoche di chiave.

== Gestione delle identità (RS08–RS11)

#figure(caption: "Requisiti di gestione identità")[
  #table(
    columns: (auto, 1fr),
    table.header([*Requisito*], [*Descrizione*]),
    [RS08], [Gerarchia a tre livelli: amministratore, responsabile, dipendente],
    [RS09], [Permessi configurabili per progetto tramite file versionato],
    [RS10], [Revoca efficace dal commit successivo alla modifica],
    [RS11], [Successione responsabile gestita solo dall'amministratore],
  )
]

RS08 è stato soddisfatto implementando la gerarchia tramite \_rvc_root — che contiene allowed_Dipendenti per l'amministratore e allowed_Responsabili per i responsabili — con doppia verifica per qualsiasi commit che modifica file speciali. RS09 è stato soddisfatto versionando allowed_Dipendenti dentro ogni commit ZIP: la storia delle autorizzazioni è parte integrante della catena crittografica. RS10 è soddisfatto strutturalmente: la revoca è efficace dal commit successivo alla rimozione della chiave, mentre i commit storici del dipendente revocato restano validi perché il campo allowedSigners del loro .sig riflette lo stato vigente al momento della firma. RS11 è stato soddisfatto richiedendo la firma con chiave master per qualsiasi commit su \_rvc_root.

=== Il file allowed_Dipendenti e il controllo preventivo (RS08, RS09)

Il file allowed_Dipendenti è il registro delle identità autorizzate a fare commit su un progetto. È un file di testo nel formato OpenSSH allowed_signers, dove ogni riga associa un nome identificativo (il _principal_) alla corrispondente chiave pubblica:

#figure(caption: "Formato allowed_Dipendenti")[
```
Michele ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGieAS3G0opZtqDPs3...
Luigi   ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFOUpazh3bucxj4lf6...
```
]

Il _principal_ deve corrispondere al nome autore usato al momento del commit: è il meccanismo con cui `ssh-keygen -Y verify -I <autore>` seleziona quale riga confrontare con la firma. Il file è _versionato_: viene archiviato nello ZIP di ogni commit e la sua modifica richiede un commit firmato dal responsabile di progetto.

La gerarchia a tre livelli è implementata attraverso due file in \_rvc_root: allowed_Dipendenti (chiave amministratore) e allowed_Responsabili (chiavi responsabili). Ogni progetto ha il proprio allowed_Dipendenti locale. Un commit che modifica file speciali è autorizzato solo se il firmatario è presente sia in allowed_Responsabili di \_rvc_root che in allowed_Dipendenti del progetto: questa doppia verifica impedisce l'auto-promozione.

Il controllo preventivo è implementato nella funzione `CheckValidity`, invocata prima di ogni commit su progetti con livello ≥ 2:

#figure(caption: "CheckValidity — controllo autore e file speciali")[
```cpl
func bool CheckValidity(str path, str project, str author, 
                        str masterKey, str branch)
  -- 1. Legge security_level da .rvc_policy risalendo la storia dei commit
  secLevel := getSecLevelFromHistory(project)

  -- 2. Per livello >= 2 verifica autore in allowed_Dipendenti
  if secLevel >= 2 and masterKey = nil
    pubKey := getAuthorPubKeyContent(author)
    if !Init.isKeyInFile(pubKey, getFileFromHistory(project, 
                                                    'allowed_Dipendenti'))
      errormsg := 'Autore "' + author + '" non autorizzato.'
      result := false
    end
  end

  -- 3. Rileva modifiche a file speciali (allowed_Dipendenti, .rvc_policy)
  if specialFileChanged and masterKey = nil
    if !checkResponsabile(author, project) and !checkAdmin(author)
      errormsg := 'Modifica a file speciali richiede Admin o Responsabile.'
      result := false
    end
  end
end
```
]

Se `CheckValidity` restituisce `false`, il commit non viene prodotto e non rimangono file parziali nella #gl("repository"). Il tentativo di commit da parte di un autore non autorizzato produce:

#terminal-io(
  [rvc commit -author=Intruso -note="modifica non autorizzata" \
   -dir=C:\stage\test_work -repo=C:\stage\repo],
  [ERROR:Autore "Intruso" non autorizzato su "TestProj" branch "principale"\
   (chiave non in allowed_Dipendenti).]
)

Un bug critico scoperto durante lo scenario S5 riguardava questa funzione: il codice originale cercava allowed_Dipendenti solo nell'ultimo ZIP con `readFileFromCommit`. Poiché i commit successivi al primo sono commit _delta_ — contengono nello ZIP solo i file modificati — se allowed_Dipendenti non era stato modificato nell'ultimo commit il risultato era `nil`, e il confronto `nil <> contenuto_su_disco` risultava sempre `true`, causando il rifiuto sistematico di qualsiasi commit successivo al primo. La correzione ha sostituito `readFileFromCommit` con `getFileFromHistory`, che risale la catena fino al commit che contiene il file:

#figure(caption: "Correzione ricerca file speciali")[
```cpl
-- Prima: cercava il file solo nell'ultimo commit delta
var str dipContent := Init.readFileFromCommit(project, 
                                              'allowed_Dipendenti', 
                                              repos)

-- Dopo: risale la catena fino al commit che contiene il file
var str dipContent := getFileFromHistory(project, 'allowed_Dipendenti')
```
]

=== Protezione dei file speciali (RS08)

I file .rvc_policy, allowed_Dipendenti e allowed_Responsabili sono _file speciali_ la cui modifica altera le regole di sicurezza del progetto. Il tentativo di modifica di allowed_Dipendenti da parte di un dipendente non autorizzato produce:

#terminal-io(
  [rvc commit -author=Dipendente -note="aggiorno i permessi" \
   -dir=C:\stage\test_work -repo=C:\stage\repo],
  [ERROR:Commit rifiutato: Modifica a file speciali richiede Admin
   (in \_rvc_root/allowed_Dipendenti) o Responsabile (in allowed_Responsabili
   E nel progetto allowed_Dipendenti). Autore "Dipendente" non autorizzato.]
)

Il progetto \_rvc_root è protetto ulteriormente: il suo livello di sicurezza è forzato a 3 indipendentemente dal file .rvc_policy e qualsiasi commit deve essere firmato con la chiave master. Per i commit legittimi su \_rvc_root — ad esempio aggiornamento di allowed_Responsabili per un cambio di personale — si usa il parametro `-master-key=`:

#figure(caption: "Commit su \_rvc_root con chiave master")[
```
rvc commit -master-key=C:\chiavi\master_key -dir=C:\stage\_rvc_root -repo=C:\stage\repo
```
]

=== Revoca e successione (RS10, RS11)

La revoca di un'identità avviene tramite un commit amministrativo che rimuove la riga corrispondente da allowed_Dipendenti. A partire dal commit successivo, la chiave rimossa non è più autorizzata. I commit prodotti prima della revoca continuano a risultare validi perché il campo allowedSigners del loro .sig registra lo stato delle chiavi vigente al momento della firma.

La successione di un responsabile segue lo stesso meccanismo, con il vincolo aggiuntivo che la modifica di allowed_Responsabili in \_rvc_root deve essere firmata con la chiave master. Il flusso prevede: checkout di \_rvc_root, modifica di allowed_Responsabili, commit con chiave master. Il nuovo responsabile diventa operativo a partire dal commit successivo.

== Sicurezza configurabile (RS12–RS13)

#figure(caption: "Requisiti di sicurezza configurabile")[
  #table(
    columns: (auto, 1fr),
    table.header([*Requisito*], [*Descrizione*]),
    [RS12], [Livelli di sicurezza configurabili per progetto, non abbassabili],
    [RS13], [Cifratura dei contenuti con #gl("age", capitalize: true) per progetti riservati],
  )
]

RS12 è stato soddisfatto implementando il file .rvc_policy versionato con controllo di monotonicità in `CheckValidity`. RS13 è stato soddisfatto integrando age nel flusso di commit per il livello 4, sfruttando direttamente le chiavi SSH Ed25519 senza conversioni di formato.

=== Il file .rvc_policy e i livelli di sicurezza (RS12)

Il livello di sicurezza è definito nel file .rvc_policy, archiviato come file tracciato nella directory di lavoro e incluso in ogni commit ZIP. Per un progetto al livello 4 il contenuto è:

#figure(caption: "Contenuto di .rvc_policy per livello 4")[
```
security_level=4
recipients=Michele ssh-ed25519 AAAA...;Luigi ssh-ed25519 AAAA...
```
]

#figure(caption: "Livelli di sicurezza")[
  #table(
    columns: (auto, 1fr, auto, auto),
    align: (center, left, center, center),
    table.header([*Livello*], [*Descrizione*], [*Firma*], [*Cifratura*]),
    [0], [Accesso anonimo — nessun controllo di identità], [no], [no],
    [1], [Firma SSH registrata], [sì], [no],
    [2], [Firma verificata — autore deve essere in allowed_Dipendenti], [sì], [no],
    [3], [Integrità pre-commit — catena verificata prima di ogni commit], [sì], [no],
    [4], [Cifratura ZIP con #gl("age", capitalize: true) per i soli destinatari autorizzati], [sì], [sì],
  )
]

I livelli sono cumulativi. La creazione di un nuovo progetto specifica il livello desiderato:

#terminal-io(
  [rvc new-project -name=TestProj2 -level=2 \
   -signers=allowed.txt -author=Michele -repo=C:\stage\repo],
  [packing TestProj2.0Q7BK1NYLS.\{Michele\}.zip\
   copying TestProj2.0Q7BK1NYLS.0Q7BK1NYLS_9B5749ED.sig to C:\stage\repo\ ...\
   Progetto TestProj2 creato a livello di sicurezza 2.]
)

La monotonicità del livello è implementata in `CheckValidity`: prima di accettare un commit che modifica .rvc_policy, il motore confronta il nuovo security_level con quello del commit precedente e rifiuta il commit se il valore è inferiore:

#terminal-io(
  [rvc commit -author=Michele -note="porto a livello 0" \
   -dir=C:\stage\test_work -repo=C:\stage\repo],
  [ERROR:Impossibile abbassare il livello di sicurezza da 2 a 0\
   (RS11: livello non riducibile).]
)

Questa scelta progettuale previene attacchi che tentano di degradare temporaneamente le garanzie di sicurezza per inserire commit senza firma.

=== Integrazione di #gl("age", capitalize: true) per il livello 4 (RS13)

Al livello 4, il file ZIP del commit viene cifrato con #gl("age", capitalize: true) prima di essere archiviato nella #gl("repository"). Solo i destinatari le cui chiavi pubbliche sono elencate nel campo recipients del .rvc_policy possono decifrarlo. La lista è scritta anche in cv.recipients nel .sig, consentendo al verificatore di controllare i destinatari autorizzati senza aprire lo ZIP.

age accetta direttamente chiavi Ed25519 in formato OpenSSH — le stesse usate per la firma — senza bisogno di un keyring separato o di conversioni di formato. Prima di passare le chiavi ad age, viene estratta la parte `<keytype> <base64data>` escludendo il _principal_, che age non accetterebbe:

#figure(caption: "Cifratura age per livello 4")[
```cpl
-- Costruisce il comando age con un parametro -r per ogni destinatario.
-- I destinatari sono separati da ';' nel campo recipients del .rvc_policy.
ageCmd := '"' + ageExe + '" --encrypt'
for each rcpKey in split(recipients, ';')
  -- Estrae la parte chiave 
  ageRcpKey := Substr(rcpKey, firstOf(rcpKey, 'ssh-', 'ecdsa-', 'sk-'))
  -- Guard: un carattere '"' nel path spezzerebbe le 
  -- virgolette del comando.
  if At('"', ageRcpKey) = 0
    ageCmd := ageCmd + ' -r "' + ageRcpKey + '"'
  end
end
os.Exec(ageCmd + ' -o "' + encPath + '" "' + zipPath + '"')
```
]

Le chiavi di tutti gli amministratori vengono aggiunte automaticamente ai destinatari alla creazione del progetto, garantendo che un progetto non possa diventare illeggibile all'amministratore:

#terminal-io(
  [rvc new-project -name=SecureProj -level=4 -author=Michele -repo=C:\stage\repo],
  [\[INFO\] level 4: chiave di "Michele" aggiunta automaticamente a recipients.\
   packing SecureProj.0Q7BKD2LIZ.\{Michele\}.zip\
   copying SecureProj.0Q7BKD2LIZ_45083758.sig to C:\stage\repo\ ...]
)

Il checkout richiede la chiave privata SSH dell'utente (la stessa usata per la firma):

#terminal-io(
  [rvc checkout -project=SecureProj \
   -age-key=C:\Users\Michele\.ssh\id_ed25519 \
   -dir=C:\stage\secure_work -repo=C:\stage\repo],
  [checkout project: SecureProj version:0Q7BKD2LIZ_45083758\
   Checkout version 0Q7BKD2LIZ completato.]
)

Se la chiave non corrisponde a nessun destinatario autorizzato:

#terminal-io(
  [rvc checkout -project=SecureProj \
   -age-key=C:\Users\Intruso\.ssh\id_ed25519 \
   -dir=C:\stage\test -repo=C:\stage\repo],
  [ERROR:Chiave non autorizzata o errata per il progetto level 4 "SecureProj".]
)

Il verificatore `rvc integrity` può operare su progetti al livello 4 senza decifrazione: l'hash nel .sig è calcolato sul file ZIP cifrato e la firma copre tutti i metadati del commit:

#terminal-io(
  [rvc integrity -project=SecureProj -repo=C:\stage\repo],
  [Progetto: SecureProj  \[level=4\]\
   \[OK\]      0Q7BKD2LIZ_45083758  2026-05-19 07:48  hash:OK  catena:OK  firma:OK  \[cifrato\]  (Michele)\
   Risultato: 0 commit con problemi.]
)

== Gestione dei branch (RS14–RS15)

#figure(caption: "Requisiti di gestione branch")[
  #table(
    columns: (auto, 1fr),
    table.header([*Requisito*], [*Descrizione*]),
    [RS14], [Branch compromessi chiudibili con commit firmato da Responsabile],
    [RS15], [Autorizzazioni differenziate per branch tramite allowed_Dipendenti],
  )
]

RS14 è stato soddisfatto tramite il campo branchStatus nel .sig e il file .rvc_branch_status nella directory di lavoro: un commit firmato da un Responsabile può marcare il branch come archived o compromised, impedendo qualsiasi commit ordinario successivo. RS15 è stato soddisfatto estendendo `CheckValidity` al confronto del file allowed_Dipendenti specifico per ogni branch.

Lo stato di un branch è tracciato nel campo branchStatus di ogni `CommitValidation` e nel file .rvc_branch_status. I valori possibili sono active, archived e compromised. Un branch marcato come archived o compromised non può ricevere nuovi commit ordinari. Il campo mergeFrom nel .sig registra il nome del branch sorgente nei commit di merge, permettendo al verificatore di controllare l'autorizzazione del merge.

== Verificatore di integrità della catena (RS02, RS11)

Il verificatore `rvc integrity` è il controllo post-hoc che completa il sistema: mentre `CheckValidity` agisce prima del commit come guardia preventiva, `VerifyIntegrity` può essere eseguito in qualsiasi momento — anche su una #gl("repository") ricevuta da un canale non fidato — per accertare l'integrità della catena dall'inizio alla fine.

Per ogni commit nella catena, il verificatore controlla quattro proprietà in cascata:

+ *Hash ZIP*: ricalcola lo SHA256 del file ZIP e lo confronta con cv.hash.
+ *Hash catena*: verifica che cv.prevHash coincida con cv.hash del commit precedente.
+ *Hash cumulativo*: ricalcola `SHA256(cv.hash + prevCumulativeHash)` e lo confronta con cv.cumulativeHash.
+ *Firma SSH*: invoca `ssh-keygen -Y verify -n file` usando cv.allowedSigners estratto dal .sig, verificando che l'autore fosse autorizzato secondo le chiavi vigenti al momento del commit.

#figure(caption: "VerifyIntegrity — verifica per commit")[
```cpl
func bool VerifyIntegrity(str project, ...)
  hst := getCommitsHistory(project)   -- ordine dal più vecchio al più recente
  for each ci in hst
    cv := ReadCommitSignature(sigPathFor(ci.id))
    hashOk    := crypt.SHA256(zipPathFor(ci.id)) = cv.hash
    catenaOk  := cv.prevHash = prevHash
    cumHashOk := crypt.SHA256(cv.hash + prevCumHash) = cv.cumulativeHash
    firmaOk   := VerifySignature(sigPath, cv.allowedSigners)
    -- Continua anche in caso di errore: in contesto forense è necessario
    -- conoscere l'estensione completa della manomissione.
    prevCumHash := cv.cumulativeHash
    rp.Report(formatRow(ci.id, hashOk, catenaOk, cumHashOk, 
                        firmaOk, cv.author))
  end
end
```
]

La scelta di continuare la verifica anche dopo il primo errore è deliberata: in un contesto forense è necessario conoscere l'estensione completa della manomissione, non solo il punto di ingresso. L'output su una #gl("repository") integra:

#terminal-io(
  [rvc integrity -project=TestProj -repo=C:\stage\repo],
  [analyzing repository C:\stage\repo\ ...\
   Progetto: TestProj  \[level=0\]\
   \[OK\]      0Q7BK1LOZY_E168FAB3  2026-05-19 07:41  hash:OK  catena:OK  firma:OK  autorita:OK  (Michele)\
   \[OK\]      0Q7BK6WQRB_D7000B46  2026-05-19 07:44  hash:OK  catena:OK  firma:OK  (Michele)\
   \[OK\]      0Q7BK7VQZR_F6794C35  2026-05-19 07:45  hash:OK  catena:OK  firma:OK  (Michele)\
   Risultato: 0 commit con problemi.\
   Risultato: 0 commit con warning.]
)

== Redazione trasparente <cap:redazione>

La Redazione Trasparente (F01) consente di rimuovere dalla storia di una #gl("repository") il contenuto di un commit sensibile — ad esempio dati personali caricati per errore in violazione del GDPR o credenziali accidentalmente committate — senza interrompere la catena crittografica.

Il problema è strutturalmente vincolato: la catena di cumulativeHash rende impossibile modificare un commit senza invalidare tutti i successivi. Qualsiasi sostituzione del contenuto richiede quindi il ricalcolo dell'intera catena a partire dal commit redatto. `rvc redact` non simula l'eliminazione del commit, ma lo sostituisce con un commit che dichiara esplicitamente la propria natura, firmato dalla chiave master.

=== Il meccanismo di sostituzione

L'esecuzione di `rvc redact` prevede i seguenti passi:

+ Lettura del .sig del commit da redarre
+ Costruzione di un nuovo ZIP contenente solo REDACTION_NOTICE.json, con riferimento legale, timestamp e autore originale
+ Aggiornamento di cv.hash sul nuovo ZIP; il vecchio hash è registrato in cv.redactionZipHash
+ Conservazione della firma originale del dipendente in cv.redactionOriginalSig come evidenza forense
+ Ricalcolo di cumulativeHash per il commit redatto e per tutti i commit successivi
+ Firma della CommitValidation aggiornata con la chiave master, producendo cv.redactionSignature

#figure(caption: "Redact — sostituzione e ricalcolo catena")[
```cpl
func bool Redact(str project, str commitId, str masterKeyPath, str legalRef, ...)
  cv := ReadCommitSignature(sigPathFor(commitId))
  -- Sostituisce lo ZIP con un archivio contenente solo REDACTION_NOTICE.json
  newZipPath := buildRedactionZip(legalRef, cv.author, commitId)
  -- Aggiorna i campi di redazione nel .sig
  cv.redactionZipHash     := crypt.SHA256(newZipPath)
  cv.redactionAuthority   := crypt.SHA256File(masterKeyPath + '.pub')
  cv.redactionTimestamp   := RvcEngine.NewUID(6)
  cv.redactionLegalRef    := legalRef
  cv.redactionCount       := Str(IntVal(cv.redactionCount) + 1)
  cv.redactionOriginalSig := extractSignatureBlock(sigPath)
  cv.redacted             := true
  recomputeCumulativeHashChain(project, commitId, repos)
  Init.signWithKey(sigPath, masterKeyPath)
end
```
]

Il redactionCount permette di tracciare eventuali ri-redazioni successive dello stesso commit; ogni ri-redazione incrementa il contatore e produce una nuova redactionSignature.

=== Varianti del comando

Il comando `rvc redact` supporta tre modalità. La prima opera su un singolo commit:

#terminal-io(
  [rvc redact -project=mioprogetto \
   -id=0Q7BK6WQRB_D7000B46 \
   -master-key=C:\chiavi\master_key \
   -legal-ref="GDPR Art.17 - Diritto all'oblio" \
   -repo=C:\stage\repo],
  [Redazione singola: commit 0Q7BK6WQRB_D7000B46 redatto.\
   Catena aggiornata: N commit successivi ricalcolati.\
   Firma master applicata.]
)

La seconda opera su un intervallo consecutivo di commit, specificato con due ID separati da `..`:

#terminal-io(
  [rvc redact -project=mioprogetto \
   -range=0Q7BK6WQRB_D7000B46..0Q7BK7VQZR_F6794C35 \
   -master-key=C:\chiavi\master_key \
   -repo=C:\stage\repo],
  [Redazione range: 3 commit redatti.\
   Catena aggiornata: M commit successivi ricalcolati.]
)

La terza redige tutti i commit di un branch, marcandolo automaticamente come compromised:

#terminal-io(
  [rvc redact -project=mioprogetto \
   -branch=feature-xyz \
   -master-key=C:\chiavi\master_key \
   -repo=C:\stage\repo],
  [Redazione branch: tutti i commit del branch feature-xyz redatti.\
   Branch marcato come compromised.]
)

=== Proprietà garantite

La redazione trasparente soddisfa quattro proprietà simultaneamente:

- *Contenuto rimosso*: il file ZIP originale è fisicamente sostituito con un ZIP contenente solo REDACTION_NOTICE.json; il contenuto sensibile non è recuperabile dalla #gl("repository")
- *Catena intatta*: il cumulativeHash è ricalcolato sull'intera catena successiva; un verificatore esterno ottiene risultato "integro" dopo la redazione
- *Trasparenza*: il .sig dichiara esplicitamente la natura del commit redatto, con riferimento legale e timestamp; il verificatore lo mostra come [REDACTED] con indicazione della chiave master autorizzante
- *Evidenza forense*: la firma originale del dipendente (redactionOriginalSig) e la firma master (redactionSignature) coesistono nel .sig, permettendo di ricostruire sia la paternità del contenuto originale sia l'autorizzazione alla sua rimozione

== Robustezza e fix injection (scenario S5) <cap:robustezza>

Lo scenario S5 ha testato la resistenza del motore a input malevoli, crash da parametri mancanti e tentativi di injection tramite campi stringa. Sono stati identificati diciassette problemi distinti, raggruppati in tre categorie: vulnerabilità di injection, crash da assenza di guard e collisioni di naming.

=== Validazione degli input

Prima degli interventi, i parametri ricevuti dalla riga di comando venivano utilizzati direttamente nelle operazioni interne senza validazione preventiva. Il principio adottato per la correzione è la _validazione al confine_: ogni valore proveniente dall'esterno viene validato all'ingresso nel motore, prima di qualsiasi utilizzo.

Sono state introdotte quattro funzioni di validazione nel modulo RvcEngine.cpl:

#figure(caption: "Funzioni di validazione input")[
```cpl
func bool isValidProjectName(str project)
  -- Pattern [0-9A-Za-z_]+, max 64 caratteri.
  -- Esclude metacaratteri shell e limita la lunghezza del path ZIP entro MAX_PATH.

func bool isValidAuthorName(str author)
  -- Pattern [0-9A-Za-z_\-.@]+, max 64 caratteri.
  -- Permette formato email (mario.rossi@az.it); esclude &, |, ;, >, <, ", spazio.

func bool isValidBranchName(str branch)
  -- Pattern [-]?[0-9A-Za-z_.]+, max 64 caratteri.
  -- Il trattino iniziale opzionale identifica branch chiusi per convenzione.

func bool isValidTagName(str tag)
  -- Pattern ([0-9A-Za-z_.]+)((\+[0-9A-Za-z_.]+)*), max 128 caratteri.
  -- Il '+' separa tag multipli (es. 'release+stable').
```
]

I limiti di lunghezza non sono arbitrari: Windows impone un limite di 260 caratteri per i path dei file (MAX_PATH). Il nome del file ZIP include nome progetto, due ID commit (~18 caratteri ciascuno), nome autore ed estensione; un nome di progetto di 300 caratteri porterebbe sistematicamente il path oltre tale limite. Limitando progetto e autore a 64 caratteri si garantisce che il path risultante non superi mai il limite di sistema.

=== Fix injection sul campo author

La vulnerabilità più critica riguardava il campo cv.author del file .sig, inserito senza quotatura nella costruzione del comando di verifica della firma. Un .sig manomesso con un campo author contenente caratteri come `"` avrebbe potuto iniettare comandi arbitrari nel processo di verifica tramite `cmd.exe`:

#figure(caption: "Vulnerabilità CWE-78 su author")[
```cpl
-- Prima (vulnerabile): cv.author non quotato nel cmd /c
-- Se cv.author = 'Michele" & calc.exe & echo "'  →  cmd.exe esegue calc.exe
os.Exec('cmd /c ssh-keygen -Y verify -n file -f ' + kn
       + ' -I ' + cv.author + ' -s ' + sn + ' < ' + tn)
```
]

La correzione agisce su due livelli indipendenti:

#figure(caption: "Correzione CWE-78 — doppia difesa")[
```cpl
-- Livello 1: validazione semantica — ammette solo [0-9A-Za-z_\-.@]+ (max 64 char).
-- Un .sig manomesso con author invalido causa firma:FAIL senza eseguire codice.
if !RvcEngine.isValidAuthorName(cv.author)
  result := false
else
  -- Livello 2: quotatura del valore anche se supera la validazione.
  -- Difesa in profondità contro errori futuri nella regex.
  os.Exec('cmd /c ssh-keygen -Y verify -n file -f ' + kn
         + ' -I "' + cv.author + '" -s ' + sn + ' < ' + tn)
end
```
]

I due livelli si difendono da classi di attacchi distinte: la validazione blocca payload con caratteri semanticamente invalidi (e.g. `"`, `&`, `|`, `;`); la quotatura protegge i valori che passano la validazione da interpretazioni shell inattese.

Fix analoghi sono stati applicati ai path di configurazione per prevenire injection da file di configurazione manomessi:

#figure(caption: "Guard injection su path di configurazione")[
```cpl
-- Guard su keyPath in signWithKey: un '"' spezzerebbe le virgolette in cmd /C
proc signWithKey(str sigPath, str keyPath)
  if At('"', keyPath) > 0
    errormsg := 'Il path della chiave non puo'' contenere il carattere ": 
                ' + keyPath
  else
    os.Exec('cmd /C ssh-keygen -Y sign -n file -f "' + keyPath + '" "' 
          + sigPath + '"')
  end
end

-- Guard su rvcHome in syncRvcEnvVars: un '"' spezzerebbe il file PS1 generato
proc syncRvcEnvVars(str rvcHome)
  if At('"', rvcHome) > 0
    rp.Error('Il path rvc_home non puo'' contenere il carattere ": ' + rvcHome)
  else
    -- genera ed esegue lo script PS1 con $h = "rvcHome"
  end
end
```
]

=== Fix crash da parametri mancanti

Lo scenario T5 aveva identificato quattordici situazioni in cui il motore produceva un traceback CPL interno anziché un messaggio leggibile dall'utente. I crash derivavano da tre pattern ricorrenti:

#figure(caption: "Pattern di crash e correzioni")[
  #table(
    columns: ( 1fr, 1fr),
    align: ( left, left),
    table.header( [*Causa*], [*Correzione*]),
     [`ArchiverByExt(nil)` — path ZIP nil quando versione non trovata], [Guard `if pkn <> nil` in `getManifest` con messaggio esplicito],
     [Doppia stampa errore: `rp.Error()` sia in InitRepo sia nell'outer handler], [Rimossi tutti i `rp.Error()` interni; solo `errormsg` impostato],
     [`errormsg` sovrascritta con `nil` da `errormsg := fmc.errormsg`], [Guard `if fmc.errormsg <> nil` prima della sovrascrittura],
     [Flag `-vers` interpretato come `-ver=s`], [Rinominato in `-allver`],
     [Comandi eseguiti senza parametri obbligatori], [Guard all'ingresso con messaggi di errore espliciti],
  )
]

Il pattern di correzione verifica il parametro obbligatorio all'ingresso della funzione, prima di qualsiasi operazione su disco:

#figure(caption: "Guard parametri obbligatori — NewProject")[
```cpl
func bool NewProject(str projectName, int level, ...)
  result := false
  if projectName = nil or projectName.LRtrim() = ''
    errormsg := 'Parametro -name= obbligatorio.'
  elseif level < 0 or level > 4
    errormsg := 'Livello non valido: ' + Str(level) 
                + '. Valori ammessi: 0-4.'
  elseif projectName = '_rvc_root'
    errormsg := 'Nome "_rvc_root" riservato al sistema.'
  elseif getLastCommit('_rvc_root', ...) = nil
    errormsg := '_rvc_root non trovato. Eseguire "rvc init" prima.'
  else
    -- procedura di creazione del progetto
  end
end
```
]

L'output risultante è un messaggio leggibile al posto di un traceback interno:

#terminal-io(
  [rvc new-project -level=9 -name=TestProj -repo=C:\stage\repo],
  [ERROR:Livello di sicurezza non valido: 9. Valori ammessi: 0, 1, 2, 3, 4.]
)

#terminal-io(
  [rvc info -ver=NONEXISTENT -repo=C:\stage\repo -dir=C:\stage\test_work],
  [ERROR:Versione non trovata nel repository: NONEXISTENT]
)

La rinomina del flag `-vers` in `-allver` merita una nota: il parser CLI di #gl("rvc", capitalize: true) usa il prefisso come disambiguatore. Il flag `-vers` veniva interpretato come abbreviazione di `-ver` con valore `s`, producendo una ricerca della versione `"s"` nella #gl("repository") e un crash per `ArchiverByExt(nil)`. La rinomina in `-allver` elimina l'ambiguità senza alterare la funzionalità.
