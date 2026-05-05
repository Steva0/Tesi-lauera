#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#import "../config/thesis-config.typ": gl, glpl, glossary-style, linkfn
#import "../config/variables.typ": *

#pagebreak(to:"odd")

= Requisiti e modello di sicurezza <cap:modello-sicurezza>
#text(style: "italic", [
    In questo capitolo viene definito il modello di sicurezza che un sistema di 
    versionamento distribuito moderno dovrebbe soddisfare. Partendo dalle proprietà 
    fondamentali richieste, vengono analizzate le scelte architetturali, i trade-off 
    e le motivazioni che portano alla definizione di un sistema gerarchico di fiducia, 
    di livelli di sicurezza configurabili e di requisiti formali. Il capitolo si conclude 
    con un'analisi del divario che confronta il modello ideale con lo stato attuale di #gl("rvc", capitalize: true), identificando le aree di intervento affrontate nei capitoli successivi.
    Data la centralità di questi aspetti all'interno del progetto, il capitolo risulta volutamente più esteso rispetto agli altri, così da consentire un'analisi dettagliata ed esaustiva delle problematiche considerate e delle soluzioni adottate.
])
#v(1em)

== Sicurezza strutturale nei sistemi di versionamento distribuito

Un sistema di versionamento distribuito è considerato sicuro quando garantisce, per ogni operazione e indipendentemente dal canale di distribuzione, le seguenti proprietà fondamentali.

- *Integrità* — il contenuto di ogni #gl("commit") non può essere alterato senza che la modifica sia rilevabile. Questa proprietà è garantita da funzioni di #gl("hash") crittografiche: dato un archivio ZIP, la sua impronta SHA256 è univoca e deterministica. Qualsiasi modifica — anche di un singolo byte — produce un #gl("hash") completamente diverso. Un sistema che garantisce l'integrità permette a chiunque di verificare che il contenuto ricevuto sia identico a quello prodotto dall'autore, senza dover contattare nessuna fonte autoritativa.

- *Autenticità* — ogni #gl("commit") è crittograficamente attribuibile all'autore che l'ha prodotta. L'autenticità è garantita dalla firma-digitale: l'autore firma il #gl("commit") con la propria chiave-privata e chiunque può verificare la firma usando la corrispondente chiave-pubblica. Senza autenticità, un sistema può garantire che i dati non siano stati modificati durante il trasferimento, ma non può garantire chi li abbia prodotti originariamente.

- *Non ripudio* — un autore non può negare di aver prodotto un #gl("commit") firmato con la propria chiave-privata. Il non ripudio è una conseguenza diretta della firma-digitale: poiché solo il possessore della chiave-privata può produrre una firma valida, la presenza di una firma valida è prova crittografica della paternità. Questa proprietà è rilevante in contesti contrattuali e legali — se un fornitore di software distribuisce codice firmato, non può successivamente sostenere di non averlo prodotto.

- *Ordine verificabile* — la sequenza temporale delle modifiche è verificabile e non manipolabile retroattivamente. Questa proprietà è la più complessa da garantire in un sistema distribuito. Non è sufficiente che ogni #gl("commit") sia integro e autentico — è necessario anche che la loro sequenza sia crittograficamente vincolata, in modo che inserire, rimuovere o riordinare #gl("commit") sia rilevabile. Questa proprietà è garantita dalla struttura a catena degli #gl("hash"): ogni #gl("commit") incorpora l'hash del precedente, rendendo impossibile modificare un elemento della catena senza invalidare tutti quelli successivi.

=== Confronto con i sistemi esistenti

In #gl("git", capitalize: true) l'integrità è garantita dalla catena di #gl("hash") SHA256 — modificare un #gl("commit") invalida tutti quelli successivi. Autenticità e non ripudio sono invece opzionali: la firma crittografica tramite #gl("ssh", capitalize: true) o GPG deve essere abilitata esplicitamente e non fa parte del flusso di lavoro standard. L'ordine temporale non è verificabile in senso assoluto — #gl("git", capitalize: true) non verifica i timestamp e permette la creazione di #gl("commit") con date arbitrarie:

```bash
GIT_AUTHOR_DATE="2020-01-01T00:00:00" git commit -m "commit retrodatata"
```

Il risultato è un #gl("commit") inserito nella storia con una data arbitraria, indistinguibile da un #gl("commit") legittimo. Questa non è una vulnerabilità ma una scelta progettuale documentata — #gl("git", capitalize: true) garantisce l'ordine relativo tramite la catena di #gl("hash"), non l'ordine temporale assoluto.

Disponibilità e correttezza non sono la stessa proprietà: un sistema può essere raggiungibile e simultaneamente produrre risultati errati. Un sistema distribuito che incorpora le garanzie crittografiche descritte sopra non dipende dalla correttezza del server per verificare l'integrità dei propri dati.
La distinzione tra disponibilità e correttezza di un sistema centralizzato è emersa concretamente il 23 aprile 2026, quando un bug nella funzionalità di merge queue di GitHub ha causato la generazione silenziosa di #gl("commit") errati per 2.092 pull request in 658 #gl("repository"). Le modifiche precedentemente unite sono state ripristinate dai merge successivi senza alcun avviso. La piattaforma era tecnicamente operativa durante tutto l'incidente — gli sviluppatori potevano ancora fare push, aprire pull request e fare merge. Il fatto che il merge stesse corrompendo silenziosamente il codice non risultava come incidente nella dashboard di stato. 

=== Applicazione in RVC

#gl("rvc", capitalize: true) garantisce l'integrità tramite il `cumulativeHash` — ogni #gl("commit") incorpora crittograficamente l'intera storia precedente. La firma #gl("ssh", capitalize: true) garantisce autenticità e non ripudio. L'ordine temporale presenta la stessa limitazione di #gl("git", capitalize: true) — gli identificativi sono timestamp codificati in base36 basati sull'orologio della macchina. Il `cumulativeHash` garantisce però l'ordine *relativo*: anche con timestamp errati o manipolati, la sequenza crittografica è verificabile e non manipolabile senza invalidare l'intera catena. Questa limitazione viene documentata come scelta consapevole — per il contesto d'uso di #gl("rvc", capitalize: true) la garanzia di ordine relativo è sufficiente e la complessità aggiuntiva di un sistema di timestamping certificato non è giustificata.

Per mitigare parzialmente questa limitazione, il modello proposto prevede che l'identificativo di ogni #gl("commit") sia composto da due componenti: il timestamp codificato in base36 per mantenere l'ordinamento cronologico visivo, e una porzione dell'hash del contenuto per garantire l'unicità crittografica. Un identificativo nella forma `0Q6JTD7XVZ_A3F2B1C4` — dove la prima parte è il timestamp e la seconda sono i primi otto caratteri dell'hash SHA256 dell'archivio ZIP — rende praticamente impossibile la collisione intenzionale mantenendo la leggibilità e l'ordinamento per nome file. Questa modifica è identificata come requisito nel modello ideale e discussa nell'analisi del divario nella @sec:analisi-divario.

== Requisiti di sicurezza formali

A partire dalle proprietà definite nella sezione precedente, è possibile derivare un insieme di requisiti formali che un sistema di versionamento distribuito sicuro deve soddisfare. Ogni requisito è classificato per priorità obbligatorio (O) o desiderabile (D) e verrà ripreso nell'analisi del divario per valutare lo stato attuale di #gl("rvc", capitalize: true).

=== Integrità e ordine verificabile

L'integrità è la proprietà fondamentale di qualsiasi sistema di versionamento — senza di essa non è possibile fidarsi del contenuto ricevuto. In un sistema distribuito questa garanzia non può dipendere dalla fiducia nel canale di distribuzione ma deve essere incorporata nei dati stessi. Ogni #gl("commit") deve portare con sé la prova crittografica della propria integrità, e la struttura della catena deve rendere rilevabile qualsiasi tentativo di modifica retroattiva. Il problema dell'ordine temporale assoluto, come discusso nella sezione precedente, viene trattato come limitazione documentata piuttosto che come requisito da risolvere completamente — il sistema deve però garantire l'ordine relativo e rendere non manipolabili gli identificativi dei #gl("commit").

#figure(caption: "Requisiti di integrità e ordine verificabile.")[
  #table(
    columns: (auto, 1fr, auto),
    table.header([*Codice*], [*Descrizione*], [*Priorità*]),
    [RS01], [Ogni #gl("commit") deve essere verificabile tramite #gl("hash") crittografico del proprio contenuto], [O],
    [RS02], [La catena degli #gl("hash") deve essere verificabile in modo che qualsiasi modifica a un #gl("commit") invalidi tutti i successivi], [O],
    [RS03], [Gli identificativi dei #gl("commit") devono essere univoci e non manipolabili tramite timestamp arbitrari], [O],
    [RS04], [Il sistema deve documentare esplicitamente le proprie limitazioni in termini di ordine temporale assoluto], [O],
  )
]

=== Autenticità e non ripudio

Garantire l'integrità del contenuto non è sufficiente se non è possibile stabilire chi lo ha prodotto. L'autenticità richiede che ogni #gl("commit") sia crittograficamente attribuibile al suo autore tramite firma-digitale. Il non ripudio è una conseguenza diretta di questa scelta — un autore non può negare di aver prodotto un #gl("commit") firmato con la propria chiave-privata. La radice di fiducia dell'intera #gl("repository") è il primo #gl("commit"), firmato dall'amministratore con la propria chiave-privata. Poiché l'autenticità di tutti i #gl("commit") successivi dipende dalla verificabilità di questa firma, il primo #gl("commit") è un requisito di autenticità prima ancora che di integrità — senza di esso non è possibile stabilire da chi provenga la catena di autorizzazioni che legittima ogni singola firma successiva.

#figure(caption: "Requisiti di autenticità e non ripudio.")[
  #table(
    columns: (auto, 1fr, auto),
    table.header([*Codice*], [*Descrizione*], [*Priorità*]),
    [RS05], [Il primo #gl("commit") di ogni #gl("repository") deve costituire una radice di fiducia verificabile autonomamente], [O],
    [RS06], [Il sistema deve supportare e imporre la firma-digitale tramite chiave #gl("ssh", capitalize: true) per ogni #gl("commit") nei progetti configurati con livello di sicurezza maggiore o uguale a 1], [O],
  )
]

=== Gestione delle identità

In un sistema multi-utente la gestione delle identità è il meccanismo che traduce le garanzie crittografiche in un modello organizzativo concreto. Non è sufficiente che le firme siano tecnicamente valide — è necessario che il sistema definisca chi è autorizzato a firmare, come vengono gestiti i cambi di personale e chi ha il potere di modificare questi elenchi. La gerarchia a tre livelli — amministratore, responsabile e dipendente — riflette la struttura organizzativa tipica di un'azienda software e permette di delegare la gestione dei permessi mantenendo un controllo centralizzato sulla radice di fiducia. La revoca deve essere immediata e non richiedere operazioni straordinarie — è sufficiente aggiornare il file di autorizzazione nel #gl("commit") successivo.

#figure(caption: "Requisiti di gestione delle identità.")[
  #table(
    columns: (auto, 1fr, auto),
    table.header([*Codice*], [*Descrizione*], [*Priorità*]),
    [RS07], [Il sistema deve supportare una gerarchia di fiducia a tre livelli: amministratore, responsabile e dipendente], [O],
    [RS08], [I permessi di scrittura devono essere configurabili per progetto tramite un file di autorizzazione versionato], [O],
    [RS09], [La revoca di un'identità deve essere efficace dal #gl("commit") successivo alla modifica del file di autorizzazione], [O],
    [RS10], [La successione di un responsabile deve essere gestita esclusivamente dall'amministratore del sistema], [D],
  )
]

=== Sicurezza configurabile

Non tutti i progetti richiedono lo stesso livello di protezione. Un prototipo interno ha esigenze diverse da un modulo che gestisce dati sensibili di un cliente. Imporre lo stesso livello di sicurezza a tutti i progetti sarebbe eccessivamente restrittivo per alcuni e insufficiente per altri. Il modello proposto prevede livelli di sicurezza configurabili per progetto, con il vincolo che il livello non possa essere abbassato nel tempo — una scelta che previene attacchi che cercano di degradare le garanzie di sicurezza di un progetto già avviato. Per i progetti che richiedono la massima riservatezza, il contenuto dei #gl("commit") può essere cifrato con #gl("age", capitalize: true), rendendo il codice leggibile solo agli utenti autorizzati.

#figure(caption: "Requisiti di sicurezza configurabile.")[
  #table(
    columns: (auto, 1fr, auto),
    table.header([*Codice*], [*Descrizione*], [*Priorità*]),
    [RS11], [Il sistema deve supportare livelli di sicurezza configurabili per progetto, non abbassabili nel tempo], [D],
    [RS12], [Il contenuto dei #gl("commit") deve poter essere cifrato con #gl("age", capitalize: true) per progetti riservati], [D],
  )
]

=== Gestione dei branch

I #gl("branch") sono uno strumento fondamentale nello sviluppo software parallelo, ma introducono scenari di sicurezza che vanno gestiti esplicitamente. Un #gl("branch") può diventare inutile al termine di una funzionalità, oppure può risultare compromesso a seguito di un #gl("commit") fraudolento o non autorizzato. In entrambi i casi il sistema deve fornire un meccanismo formale per dichiarare lo stato del #gl("branch"), senza cancellare la storia — che rimane immutabile e verificabile — ma aggiungendo un #gl("commit") firmato che ne attesti la chiusura o la compromissione. Questo approccio mantiene la tracciabilità completa degli eventi, inclusa la prova della compromissione stessa.

#figure(caption: "Requisiti di gestione dei branch.")[
  #table(
    columns: (auto, 1fr, auto),
    table.header([*Codice*], [*Descrizione*], [*Priorità*]),
    [RS13], [I #gl("branch") compromessi devono poter essere chiusi con un #gl("commit") firmato che ne attesti la compromissione], [D],
  )
]

I requisiti obbligatori definiscono le proprietà minime senza le quali il sistema non può essere considerato sicuro per il contesto d'uso descritto. I requisiti desiderabili estendono il modello con funzionalità che aumentano significativamente il livello di sicurezza, ma la cui assenza non compromette le garanzie fondamentali.

I requisiti RS01, RS02 e RS03 corrispondono alla proprietà di integrità e alla gestione dell'ordine verificabile. RS05 e RS06 garantiscono le proprietà di autenticità e non ripudio. RS07, RS08, RS09 e RS10 definiscono il modello di gestione delle identità e dei permessi. RS11 e RS12 estendono il modello con funzionalità di sicurezza configurabile. RS04 e RS13 affrontano rispettivamente la documentazione delle limitazioni note e la gestione degli incidenti sui #gl("branch").

== Gerarchia di fiducia

In un sistema di versionamento distribuito la fiducia non può essere delegata a un server centrale — deve essere incorporata nella struttura stessa dei dati. Il modello proposto definisce una gerarchia a tre livelli operativi più un livello esterno di sola lettura, ciascuno con responsabilità e permessi ben definiti. La gerarchia è asimmetrica: ogni livello superiore può esercitare i poteri del livello inferiore, ma non viceversa.

=== Commit ordinari e commit amministrativi

Il modello distingue due categorie di #gl("commit") in base al contenuto dello ZIP.

*#gl("commit", capitalize: true) ordinario* — crea o modifica esclusivamente file del progetto, senza toccare nessun file speciale. Può essere firmato da qualsiasi dipendente presente in `allowed_signers`.

*#gl("commit", capitalize: true) amministrativo* — crea, modifica o elimina almeno uno dei seguenti file speciali: `allowed_Dipendenti`, `.rvc_policy` o `.rvc_branch_status`. Tutti i #gl("commit") del progetto `_rvc_root` sono amministrativi per definizione. 

La verifica dei #gl("commit") amministrativi avviene prima che il #gl("commit") venga prodotto, ed è il punto cruciale per la segregazione dei permessi tra progetti diversi. Il motore confronta il contenuto dello ZIP con quello del #gl("commit") precedente e, se rileva modifiche ai file speciali, richiede che la firma appartenga all'amministratore o al responsabile del progetto. 
Per verificare che il firmatario sia il legittimo responsabile di quel progetto, il motore esegue un controllo congiunto: verifica che la chiave del firmatario appartenga a un responsabile (ovvero sia presente nel file `allowed_Responsabili` di `_rvc_root`) e contemporaneamente che sia già presente all'interno del file `allowed_Dipendenti` del progetto stesso. Questo doppio vincolo impedisce a un responsabile di alterare le policy o i permessi di un progetto assegnato a un altro responsabile. L'amministratore (identificato invece dalla presenza della sua chiave nel file `allowed_Dipendenti` di `_rvc_root`) è esente dal controllo locale e ha facoltà di produrre #gl("commit") amministrativi su qualsiasi progetto. Se la verifica fallisce, il #gl("commit") viene rifiutato prima ancora della generazione del file `.sig`.

Nel caso specifico del primo #gl("commit") assoluto di un nuovo progetto, non esistendo uno stato precedente, il motore applica un'eccezione logica: accetta la creazione dei file speciali verificando che il firmatario sia un responsabile in `_rvc_root` e che si sia auto-incluso nel file `allowed_Dipendenti` appena creato.

Il primo #gl("commit") di qualsiasi progetto è sempre amministrativo — crea `allowed_Dipendenti` e `.rvc_policy` per la prima volta. Di conseguenza solo il responsabile o l'amministratore può inizializzare un progetto.

Questa verifica preventiva ha una conseguenza diretta sulla catena di fiducia: se un #gl("commit") esiste ed è crittograficamente valido, chiunque lo verifichi può assumere che il firmatario avesse i permessi necessari al momento della produzione. Non è quindi necessario accedere al contenuto dello ZIP per verificare la legittimità di una modifica ai file speciali — è sufficiente verificare che la firma del #gl("commit") sia valido e che il firmatario fosse autorizzato secondo `_rvc_root`. Questa proprietà vale per tutti i livelli di sicurezza incluso il livello 4, dove la verifica avviene prima della cifratura sul contenuto in chiaro.

I #gl("commit") amministrativi richiedono sempre la verifica dell'identità del firmatario, indipendentemente dal livello di sicurezza del progetto. Ai livelli 0 e 1 non esiste il file `allowed_Dipendenti` e quindi non esiste la figura del responsabile di progetto — l'unico soggetto autorizzato a produrre #gl("commit") amministrativi è l'amministratore, che firma con la propria chiave operativa. Questa regola garantisce che i file speciali siano sempre protetti da una firma verificabile anche nei progetti con il livello di sicurezza più basso, dove i #gl("commit") ordinari non richiedono firma o non verificano l'identità. Il progetto `_rvc_root` segue sempre le stesse regole indipendentemente dal livello — tutti i suoi #gl("commit") sono amministrativi e devono essere firmati dall'amministratore.

=== Amministratore (CapoProgetto)

L'amministratore è la radice assoluta di fiducia dell'intera #gl("repository"). Questo ruolo può essere ricoperto da un singolo individuo o da un gruppo direttivo (ad esempio i fondatori o i direttori tecnici). A livello crittografico, il sistema si basa su una netta separazione: esiste un'unica chiave master conservata offline su un dispositivo air-gapped o in una cassaforte fisica, e una o più chiavi operative (una per ciascun amministratore autorizzato) utilizzate per le operazioni quotidiane su macchine connesse. La separazione tra la chiave master e le chiavi operative limita la finestra di rischio in caso di compromissione: se una chiave operativa viene rubata o esposta, la chiave master interviene per revocarla e nominarne una nuova senza invalidare le altre chiavi operative o perdere il controllo della #gl("repository").

La prima operazione alla creazione di una #gl("repository") è produrre il file `allowed_Responsabili` — l'elenco delle chiavi pubbliche dei responsabili autorizzati — e firmarlo con la chiave-privata operativa. Questo file e la sua firma costituiscono il primo #gl("commit") della #gl("repository") e la radice di fiducia da cui deriva tutta la catena di verifica successiva. L'amministratore ha accesso in lettura e scrittura a tutti i progetti della #gl("repository") a qualsiasi livello di sicurezza, incluso il livello 4 con contenuto cifrato — la sua chiave pubblica è sempre inclusa tra i destinatari autorizzati.

=== Responsabile di progetto

Il responsabile gestisce uno o più progetti all'interno della #gl("repository"). Il ruolo viene assegnato dall'amministratore tramite inclusione nel file `allowed_Responsabili` — non può essere auto-assegnato né delegato a un altro responsabile. Per ogni progetto gestito, il responsabile mantiene il file `allowed_Dipendenti`, che elenca le chiavi pubbliche dei dipendenti autorizzati a committare. Questo file è versionato all'interno dello ZIP di ogni #gl("commit") del progetto, fa parte del contenuto hashato e firmato, e la sua storia è completamente tracciabile.

Il responsabile aggiunge o rimuove dipendenti dal proprio progetto in autonomia tramite #gl("commit") amministrativi — modificando il file `allowed_Dipendenti` e firmando i #gl("commit") con la propria chiave-privata. L'amministratore può sovrascrivere il file `allowed_Dipendenti` di qualsiasi progetto in qualsiasi momento — il suo potere non è vincolato dalla struttura gerarchica. Se un responsabile lascia l'azienda o viene rimosso dal ruolo, l'amministratore nomina un sostituto aggiornando il file `allowed_Responsabili`. Fino alla nomina del sostituto il progetto entra in stato di attesa: i dipendenti esistenti possono continuare a committare, ma non è possibile aggiungere nuovi dipendenti né modificare i permessi esistenti.

Il responsabile può alzare il livello di sicurezza del proprio progetto in qualsiasi momento producendo un #gl("commit") firmato che aggiorna il file `.rvc_policy`. Il livello non può essere abbassato — questa operazione viene rifiutata dal motore indipendentemente dall'identità del firmatario. L'amministratore ha lo stesso potere su qualsiasi progetto della #gl("repository").

=== Dipendente

Il dipendente è autorizzato a produrre #gl("commit") ordinari su un progetto se e solo se la propria chiave-pubblica è presente nel campo `allowed_signers` del #gl("commit") più recente di quel progetto. I permessi sono definiti per progetto — un dipendente autorizzato su ProgettoA non ha accesso a ProgettoB, anche se entrambi appartengono alla stessa #gl("repository"). Non esistono permessi per #gl("branch"): un dipendente autorizzato su un progetto può committare su qualsiasi #gl("branch") di quel progetto.

I dipendenti non possono produrre #gl("commit") amministrativi — qualsiasi tentativo di creare, modificare o eliminare un file speciale (`allowed_Dipendenti`, `.rvc_policy`, `.rvc_branch_status`) viene rifiutato dal motore indipendentemente dalla presenza della firma. Questa restrizione vale per tutti i livelli di sicurezza.

La revoca è operativa dal #gl("commit") successivo alla modifica del file `allowed_Dipendenti`: il dipendente rimosso non può produrre #gl("commit") validi sul progetto. I #gl("commit") prodotti prima della revoca rimangono validi in quanto firmati da un'identità che era autorizzata al momento della firma — la storia del progetto è immutabile e ogni modifica ai permessi è tracciata nella catena.

=== Cliente o Guest

Il cliente o guest riceve la #gl("repository") e verifica autonomamente autenticità e integrità del contenuto, senza dipendere dall'infrastruttura del produttore. La verifica parte dalla chiave-pubblica operativa dell'amministratore, ottenuta tramite un canale indipendente dalla #gl("repository") stessa — ad esempio il sito ufficiale del produttore distribuito tramite HTTPS. Con questa chiave il cliente verifica la firma sul file `allowed_Responsabili` del primo #gl("commit") e da lì risale crittograficamente all'intera catena di autorizzazioni e #gl("commit").

Il cliente opera in sola lettura e non ha permessi di scrittura sulla #gl("repository"). Quando riceve un aggiornamento, verifica che i nuovi #gl("commit") si colleghino correttamente alla catena già in suo possesso. Nei progetti di livello 4 la chiave-pubblica #gl("age", capitalize: true) del cliente deve essere registrata tra i destinatari autorizzati (`recipients`) per poter decifrare il contenuto. Questo meccanismo sfrutta la separazione architetturale dei permessi: il cliente è autorizzato alla lettura tramite #gl("age", capitalize: true), ma la sua assenza dal file `allowed_Dipendenti` gli impedisce crittograficamente di produrre #gl("commit") validi, proteggendo l'integrità dello sviluppo. La verifica della catena e delle firme rimane comunque possibile anche per i non autorizzati senza decifrare, poiché l'hash nel file `.sig` è calcolato sul contenuto cifrato.

=== Inizializzazione della repository

La creazione di una nuova #gl("repository") segue questa procedura:

+ L'amministratore genera la singola coppia di chiavi master con `ssh-keygen -t ed25519` e conserva la chiave-privata master su un dispositivo offline.
+ Gli amministratori generano le proprie coppie di chiavi operative sui rispettivi computer di lavoro. Usando la chiave-privata master, vengono firmate tutte le chiavi pubbliche operative autorizzate.
+ Viene creato il primissimo #gl("commit") del progetto `_rvc_root`. Questo #gl("commit") è fondamentale perché inizializza lo stato del motore e deve contenere:
  - Il file `master.pub` (la chiave-pubblica master in chiaro).
  - I file di certificato `.sig` (le firme crittografiche della master sulle chiavi operative).
  - Il file `allowed_Dipendenti` contenente l'elenco di tutte le chiavi pubbliche operative.
  - Il file `allowed_Responsabili` (inizialmente vuoto o con i primi nominati).
+ Questo primo #gl("commit") viene firmato con la chiave master stessa, stabilendo l'ancora di fiducia interna al sistema. 
+ Infine, la chiave-pubblica master viene pubblicata su un canale indipendente (es. sito web HTTPS). Il cliente verifica che la `master.pub` dentro la #gl("repository") coincida con quella sul sito web, validando a cascata l'intera catena.

=== Compromissione di una chiave operativa

La compromissione di una chiave operativa è lo scenario critico del modello. Si utilizza la chiave master — conservata offline — per revocare esclusivamente la chiave operativa compromessa, lasciando intatte le eventuali altre chiavi operative valide. La procedura è la seguente:

+ Viene recuperato il dispositivo offline contenente la chiave-privata master.
+ Se necessario, il soggetto compromesso genera una nuova coppia di chiavi operativa, la cui parte pubblica viene firmata con la chiave master per creare un nuovo certificato di delega.
+ Viene prodotto un speciale #gl("commit") amministrativo su `_rvc_root` che aggiorna il file `allowed_Dipendenti` (inserendo la nuova chiave e/o rimuovendo la vecchia compromessa) e aggiorna i certificati.
+ Questo #gl("commit") di revoca viene firmato eccezionalmente con la *chiave-privata master*.
+ Il motore di #gl("rvc", capitalize: true) riceve il #gl("commit"). Poiché la chiave master non è elencata in `allowed_Dipendenti`, il motore procederebbe a rifiutarlo. Tuttavia, prima di emettere il rifiuto definitivo, il motore verifica la firma del #gl("commit") contro il file `master.pub` registrato in modo immutabile nel #gl("commit") iniziale di `_rvc_root`. Se la firma combacia, il motore riconosce l'autorità suprema della chiave master e accetta il #gl("commit"); altrimenti lo rifiuta.

=== Inizializzazione di un progetto

La creazione di un nuovo progetto all'interno di una #gl("repository") esistente segue percorsi diversi a seconda del livello di sicurezza scelto. Il primo #gl("commit") di qualsiasi progetto è sempre un #gl("commit") amministrativo, ma i file da generare e i soggetti autorizzati cambiano in base al contesto.

Per i *progetti ai livelli di sicurezza 2, 3 e 4*, l'inizializzazione è gestita dal responsabile nominato, senza necessità di intervento dell'amministratore. La procedura è la seguente:
+ Il responsabile crea il file `allowed_Dipendenti` con le chiavi pubbliche dei dipendenti autorizzati. In questa fase inaugurale, il motore richiede tassativamente che il responsabile includa la propria chiave-pubblica nel file, in modo da stabilire il vincolo di appartenenza al progetto discusso in precedenza.
+ Il responsabile crea il file `.rvc_policy` con il livello di sicurezza scelto (da 2 a 4) e, per il livello 4, la lista iniziale dei destinatari autorizzati alla decifratura.
+ Il responsabile produce il primo #gl("commit") del progetto, firmato con la propria chiave-privata. Il motore accetta il #gl("commit") verificando che il firmatario sia in `_rvc_root` e si sia auto-incluso nel nuovo `allowed_Dipendenti`.

Per i *progetti ai livelli di sicurezza 0 e 1*, non esistendo il file `allowed_Dipendenti` né la figura del responsabile, l'inizializzazione può essere eseguita esclusivamente dall'amministratore. L'amministratore produce un primo #gl("commit") contenente unicamente il file `.rvc_policy` (che dichiara il livello 0 o 1) e la firma con la propria chiave operativa. Qualsiasi tentativo da parte di un responsabile o di un dipendente di inizializzare un progetto a questi livelli viene rifiutato dal motore.

Il livello di sicurezza definito nel primo #gl("commit") non può essere abbassato — può essere alzato in qualsiasi momento tramite un #gl("commit") amministrativo firmato dal responsabile o dall'amministratore. Questa scelta elimina la possibilità di degradare le garanzie di sicurezza di un progetto già avviato.

=== File amministrativi della repository

In #gl("rvc", capitalize: true) ogni #gl("commit") appartiene a un progetto — non esiste il concetto di #gl("commit") globale della #gl("repository"). I file amministrativi `allowed_Responsabili` e la sua firma devono però risiedere nella #gl("repository") in modo verificabile e versionato, indipendentemente da qualsiasi progetto specifico.

Il modello proposto risolve questo problema definendo un progetto riservato con nome convenzionale `_rvc_root`, dedicato esclusivamente all'amministrazione della #gl("repository"). Al suo interno risiede il file `allowed_Responsabili` e la sua firma. Anche `_rvc_root` contiene al suo interno un proprio file `allowed_Dipendenti`. In questo file è presente unicamente la chiave-pubblica operativa dell'amministratore. Solo l'amministratore è quindi autorizzato a committare su questo progetto, seguendo la medesima struttura logica di tutti gli altri.

Il nome `_rvc_root` è riservato per convenzione del modello. Per prevenire conflitti, il motore verifica all'inizializzazione che questo nome non sia già in uso e lo riserva automaticamente — qualsiasi tentativo di creare un progetto con questo nome da parte di un responsabile o dipendente viene rifiutato.

Questa scelta è preferita all'alternativa di file speciali nella radice della #gl("repository") perché non richiede modifiche architetturali al motore e mantiene la coerenza del modello — la verifica della radice di fiducia usa esattamente la stessa logica della verifica di qualsiasi altro progetto.

Il progetto `_rvc_root` opera al livello di sicurezza 2 — ogni #gl("commit") deve essere firmato dall'amministratore e la firma viene verificata contro il campo `allowed_signers` del `.sig`, che contiene esclusivamente la chiave-pubblica operativa dell'amministratore. Il livello 2 è il minimo che garantisce la verifica dell'identità del firmatario senza richiedere la cifratura del contenuto — `_rvc_root` deve rimanere leggibile da qualsiasi soggetto che voglia verificare la catena di fiducia.

=== Il file .rvc_policy

Il file `.rvc_policy` definisce le proprietà di sicurezza di un progetto ed è collocato nella radice dello ZIP di ogni #gl("commit"). È un file speciale — la sua creazione e modifica sono operazioni amministrative riservate al responsabile o all'amministratore. I campi che il file deve contenere sono i seguenti:

- `security_level`: valore intero da 0 a 4 che definisce il livello di sicurezza del progetto. Questo valore viene estratto dal motore e riportato nel campo `security_level` del `.sig` ad ogni #gl("commit"), in modo che il livello sia verificabile senza accedere allo ZIP. Il livello non può essere abbassato nei #gl("commit") successivi.
- `recipients`: lista delle chiavi pubbliche dei destinatari autorizzati alla decifratura. Presente solo nei progetti a livello 4. Definisce la lista iniziale dei destinatari al momento della creazione del progetto e include sia i soggetti autorizzati alla scrittura sia eventuali "Guest" in sola lettura (clienti, auditor). Le modifiche successive avvengono tramite #gl("commit") amministrativi che aggiornano sia questo campo che l'header #gl("age", capitalize: true) dello ZIP cifrato.

Il file `.rvc_policy` non contiene informazioni sulle identità dei dipendenti — quelle risiedono in `allowed_Dipendenti`. La separazione tra policy di sicurezza e lista delle identità permette di aggiornare i due aspetti indipendentemente, mantenendo in entrambi i casi la tracciabilità completa nella catena dei #gl("commit").

=== Struttura del file .sig nel modello proposto

Il file `.sig` è il punto di contatto tra il contenuto crittografico e il modello di sicurezza. Nel modello proposto la sua struttura estende quella attuale di #gl("rvc", capitalize: true) con i campi necessari per supportare la gerarchia di fiducia, i livelli di sicurezza configurabili e la gestione dei #gl("branch"). Il `.sig` è firmato crittograficamente nella sua interezza — qualsiasi modifica a uno qualsiasi dei suoi campi invalida la firma e quindi il #gl("commit").

I campi del `.sig` nel modello proposto sono i seguenti:

- `author`: identificativo dell'autore del #gl("commit"), nella forma definita dal file `allowed_Dipendenti` del progetto. Il formato — email, nome opaco o qualsiasi altra convenzione — è una scelta dell'organizzazione che gestisce la #gl("repository").
- `comment`: messaggio descrittivo del #gl("commit").
- `fn`: nome del file ZIP corrispondente.
- `id`: identificativo del #gl("commit"), composto da timestamp in base36 e #gl("hash") parziale del contenuto — ad esempio `0Q6JTD7XVZ_A3F2B1C4`.
- `prevId`: identificativo del #gl("commit") precedente.
- `hash`: SHA256 del file ZIP di questo #gl("commit").
- `prevHash`: SHA256 del file ZIP del #gl("commit") precedente.
- `cumulativeHash`: SHA256 della concatenazione dell'hash attuale con il `cumulativeHash` del #gl("commit") precedente.
- `security_level`: livello di sicurezza del progetto — da 0 a 4. Estratto dal file `.rvc_policy` dello ZIP e riportato in chiaro nel `.sig` per permettere al motore di applicare le regole corrette senza dover decifrare il contenuto. Questo è necessario in particolare per i progetti a livello 4 — il motore deve sapere che il contenuto è cifrato prima ancora di tentare di leggerlo. La conseguenza è che il livello di sicurezza di un progetto è visibile a chiunque possa leggere il `.sig`, incluso il fatto che un progetto sia riservato. Questo è considerato accettabile perché l'esistenza di un progetto è già visibile dalla struttura dei file nella #gl("repository").
- `allowed_signers`: elenco delle chiavi pubbliche #gl("ssh", capitalize: true) degli identificativi autorizzati a committare al momento di questo #gl("commit"). Presente solo nei progetti a livello 2, 3 e 4 — estratto dal file `allowed_Dipendenti` dello ZIP prima di qualsiasi cifratura e riportato in chiaro nel `.sig`. Questo garantisce che il campo sia sempre leggibile indipendentemente dal livello di sicurezza del progetto: anche al livello 4, dove lo ZIP viene cifrato dopo l'estrazione, `allowed_signers` rimane in chiaro nel `.sig` e permette la verifica delle firme senza dover decifrare il contenuto. Per il progetto `_rvc_root` contiene esclusivamente la chiave-pubblica operativa dell'amministratore. Ai livelli 0 e 1 questo campo è assente.
- `branch_status`: stato corrente del #gl("branch") — `active`, `archived` o `compromised`. È presente in ogni #gl("commit") e riflette il contenuto del file `.rvc_branch_status` dentro lo ZIP. Il motore legge sempre questo campo direttamente dal `.sig` — senza dover accedere allo ZIP — indipendentemente dal livello di sicurezza del progetto. Questo garantisce che la gestione dei #gl("branch") funzioni correttamente anche per i progetti a livello 4 dove lo ZIP è cifrato. Il file `.rvc_branch_status` dentro lo ZIP rimane la fonte di verità completa e può contenere informazioni aggiuntive — motivazione, riferimenti, note — accessibili a chi ha i permessi di lettura.
- `recipients`: elenco delle identità complete dei destinatari autorizzati alla decifratura del contenuto ZIP. Presente solo nei progetti a livello 4. Contiene le chiavi pubbliche #gl("age", capitalize: true) dei destinatari in chiaro — chiunque possa leggere il `.sig` può determinare chi ha accesso al contenuto cifrato. Questa scelta è deliberata: la complessità di meccanismi di oscuramento parziale introduce buchi nella verificabilità senza offrire garanzie di riservatezza robuste.

Dopo questi campi il file `.sig` contiene la firma #gl("ssh", capitalize: true) dell'autore nel formato standard, assente al livello 0:

#figure(
  caption: [Esempio di firma #gl("ssh")],
  block(width: auto)[
    ```
    -----BEGIN OPENSSH SIGNATURE-----
    <contenuto della firma>
    -----END OPENSSH SIGNATURE-----
    ```
  ]
)

La presenza di `allowed_signers` nel `.sig` in chiaro risolve il problema della verificabilità per qualsiasi livello di sicurezza: il motore di #gl("rvc", capitalize: true) e qualsiasi terzo possono verificare la firma del #gl("commit") e la legittimità del firmatario leggendo esclusivamente il `.sig`, senza dover decifrare il contenuto dello ZIP. Il file `allowed_Dipendenti` dentro lo ZIP rimane la fonte di verità completa — contiene le chiavi pubbliche degli autorizzati con le relative informazioni ed eventuali dati aggiuntivi ad uso interno — ma non è necessario per la verifica crittografica.

=== Catena di fiducia tra progetti

Il progetto `_rvc_root` non collega crittograficamente i progetti della #gl("repository") tra loro — ogni progetto mantiene una propria catena di #gl("commit") indipendente. La funzione di `_rvc_root` è certificare le identità autorizzate, non la struttura dei dati. La fiducia tra i progetti è gerarchica attraverso le identità, non crittografica attraverso la struttura.

La verifica completa di un #gl("commit") di un qualsiasi progetto segue questa catena:

+ La firma del #gl("commit") viene verificata crittograficamente contro le chiavi pubbliche presenti nel campo `allowed_signers` del `.sig` di quel #gl("commit"). Il campo `allowed_signers` è fidato perché il motore garantisce che solo il responsabile o l'amministratore possano produrre i #gl("commit") amministrativi che lo modificano — qualsiasi altra modifica viene rifiutata prima della creazione del #gl("commit"). Di conseguenza, se un #gl("commit") esiste ed è crittograficamente valida, il suo campo `allowed_signers` riflette una lista di autorizzati approvata da chi ne aveva il potere.
+ La firma del #gl("commit") di `_rvc_root` che ha prodotto la versione corrente di `allowed_Responsabili` viene verificata contro la chiave-pubblica operativa dell'amministratore, presente nel campo `allowed_signers` del `.sig` di `_rvc_root`. A differenza degli altri progetti, il campo `allowed_signers` di `_rvc_root` contiene esclusivamente la chiave-pubblica operativa dell'amministratore — i responsabili sono il contenuto di `_rvc_root`, non i suoi firmatari.
+ La legittimità della chiave-pubblica operativa viene verificata tramite il certificato firmato con la chiave master, presente nel primo #gl("commit") di `_rvc_root`.
+ La chiave-pubblica master viene verificata tramite il canale indipendente dalla #gl("repository").

Questa catena implica un requisito operativo: la verifica completa di qualsiasi #gl("commit") richiede la presenza di `_rvc_root` nella #gl("repository"). Chi riceve la #gl("repository") riceve automaticamente tutti i progetti incluso `_rvc_root` — ma un sistema che distribuisce solo i file di un singolo progetto non permette la verifica completa della catena di fiducia.

Questa catena di verifica si applica ai progetti a livello 2 o superiore, dove il campo `allowed_signers` è presente nel `.sig`. Per i progetti a livello 0 e 1 la verifica delle identità attraverso la catena non è applicabile — è una conseguenza diretta del livello di sicurezza scelto, che non prevede né l'autorizzazione esplicita né la lista degli autorizzati. In questi progetti l'unica garanzia verificabile è l'integrità della catena degli #gl("hash"). Questa limitazione è documentata come scelta consapevole: i livelli 0 e 1 sono destinati a contesti dove la tracciabilità formale delle identità non è un requisito.

=== Implicazioni di sicurezza della radice pubblica

Il progetto `_rvc_root` non può essere cifrato — deve essere leggibile da qualsiasi soggetto che voglia verificare la catena di fiducia, incluso il cliente. Questa necessità introduce una tensione strutturale tra verificabilità pubblica e riservatezza organizzativa.

Il contenuto di `_rvc_root` espone le chiavi pubbliche dei responsabili e, implicitamente, la struttura organizzativa dell'azienda. Le chiavi pubbliche non sono segrete per definizione, ma la lista dei responsabili è informazione sensibile — rivela chi ha potere decisionale sulla #gl("repository") e rende questi soggetti bersagli privilegiati per attacchi di ingegneria sociale e spear phishing. Analogamente, i nomi dei file ZIP nella #gl("repository") rivelano i nomi dei progetti anche quando il contenuto è cifrato a livello 4.

Il modello propone due mitigazioni parziali. La prima riguarda le identità: invece di utilizzare indirizzi email o nomi reali nel file `allowed_Responsabili`, si possono adottare identificativi opachi — ad esempio `resp-001` — riducendo la leggibilità immediata senza eliminare la tracciabilità per chi ha accesso alle informazioni di mappatura. La seconda riguarda i nomi dei progetti: l'uso di identificativi non descrittivi — ad esempio `PRJ-4A2F` invece di `ModuloPagamenti` — impedisce la mappatura immediata del contenuto della #gl("repository") a partire dalla struttura dei file.

Queste mitigazioni riducono la superficie di esposizione ma non la eliminano. Il trade-off tra verificabilità pubblica e riservatezza organizzativa è una limitazione strutturale del modello — qualsiasi sistema che permette la verifica autonoma della catena di fiducia deve necessariamente rendere pubblica almeno la radice di quella catena.

== Livelli di sicurezza configurabili

Un sistema di versionamento distribuito utilizzato in contesti aziendali deve servire esigenze di sicurezza eterogenee. Un prototipo interno in fase esplorativa, un modulo di produzione distribuito a clienti e un componente che gestisce dati finanziari hanno requisiti di protezione radicalmente diversi. Imporre un livello di sicurezza uniforme a tutti i progetti è eccessivamente restrittivo per alcuni e insufficiente per altri.

Il modello proposto introduce livelli di sicurezza configurabili per progetto, definiti alla creazione del progetto nel file `.rvc_policy` e non abbassabili nel tempo. Il vincolo di non abbassabilità è una scelta deliberata: un attaccante che compromette l'account di un responsabile non può degradare le garanzie di sicurezza di un progetto già avviato — può solo alzarle. Ogni livello è un sovrainsieme del precedente: un progetto a livello 3 soddisfa tutti i requisiti dei livelli 0, 1 e 2.

=== Livello 0 — Aperto

Nessuna firma è richiesta per i #gl("commit") ordinari. I #gl("commit") amministrativi (come il primo #gl("commit") di inizializzazione prodotto dall'amministratore) costituiscono un'eccezione architetturale globale: devono sempre essere firmati e includere il campo `allowed_signers` nel `.sig`. Per i #gl("commit") ordinari, invece, chiunque abbia accesso fisico alla #gl("repository") può aggiungere #gl("commit"). Il sistema non impone la verifica automatica dell'identità né dell'integrità, sebbene quest'ultima resti calcolabile matematicamente tramite la catena degli #gl("hash"). Il file `.sig` per i #gl("commit") ordinari al livello 0 contiene solo i campi strutturali — `author`, `comment`, `fn`, `id`, `prevId`, `hash`, `prevHash`, `cumulativeHash`, `security_level` e `branch_status` — ma non il campo `allowed_signers` e non la firma #gl("ssh", capitalize: true). L'assenza della firma nei #gl("commit") ordinari è la caratteristica distintiva del livello 0 e viene rilevata dal motore come indicazione che il progetto opera senza controllo delle identità.

Questo livello è appropriato per prototipi interni in fase esplorativa dove la velocità di sviluppo è prioritaria e la tracciabilità formale non è richiesta. Non fornisce nessuna delle quattro proprietà di sicurezza definite nella sezione precedente — né integrità crittografica delle identità, né autenticità, né non ripudio, né ordine verificabile tramite firme.

=== Livello 1 — Autenticato

Ogni #gl("commit") deve contenere una firma #gl("ssh", capitalize: true) valida nel formato standard. Il motore verifica che la firma sia presente e crittograficamente corretta — non verifica l'identità del firmatario né se la chiave appartenga a un soggetto autorizzato. Questo livello garantisce autenticità e non ripudio: ogni #gl("commit") è attribuibile a chi possiede la chiave-privata corrispondente alla firma, e la presenza della firma è prova crittografica della paternità. Non garantisce autorizzazione — chiunque possieda una chiave #gl("ssh", capitalize: true) può committare. È appropriato per #gl("repository") interne dove tutti i partecipanti sono implicitamente fidati ma si vuole mantenere la tracciabilità delle modifiche.

=== Livello 2 — Autorizzato

Ogni #gl("commit") deve essere firmato da una chiave presente nel file `allowed_Dipendenti` del progetto. Il sistema verifica sia la validità crittografica della firma sia l'appartenenza dell'identità alla lista degli autorizzati. Questo livello garantisce autenticità, non ripudio e autorizzazione — solo i soggetti esplicitamente nominati dal responsabile possono produrre #gl("commit") validi. È il livello base raccomandato per qualsiasi progetto in produzione.

=== Livello 3 — Verificato

Come il livello 2, con l'aggiunta della verifica obbligatoria della catena degli #gl("hash") a ogni operazione. Nessuna operazione — lettura, aggiornamento, push — può procedere se la catena risulta corrotta o incompleta. Mentre nei livelli precedenti la verifica della catena è un'operazione esplicita eseguita su richiesta, al livello 3 è una precondizione implicita di qualsiasi interazione con il progetto. Questo livello è appropriato per codice distribuito a clienti esterni, dove la garanzia di integrità deve essere continua e non delegabile a verifiche periodiche manuali.

=== Livello 4 — Riservato

Come il livello 3, con l'aggiunta della cifratura del contenuto degli archivi ZIP tramite #gl("age", capitalize: true). Solo i soggetti la cui chiave-pubblica è registrata tra i destinatari autorizzati possono decifrare e leggere il contenuto. La verifica della catena e delle firme rimane possibile senza decifrare — l'hash nel file `.sig` è calcolato sul contenuto cifrato, non su quello in chiaro. Questo livello è appropriato per progetti che contengono codice o dati la cui riservatezza è un requisito contrattuale o legale.

Una proprietà fondamentale del Livello 4 è il disaccoppiamento esplicito tra permessi di lettura e permessi di scrittura. Mentre la capacità di produrre #gl("commit") è governato dal file `allowed_Dipendenti`, la capacità di leggere i sorgenti è governata dalla lista dei destinatari in `.rvc_policy`. Questa asimmetria permette di definire la figura del "Guest" (ad esempio auditor, tester o clienti): utenti la cui chiave è inclusa tra i destinatari per consentire l'ispezione del codice, ma a cui è inibita la scrittura poiché assenti dall'elenco degli `allowed_Dipendenti`. In un progetto a Livello 4, l'insieme degli utenti autorizzati in scrittura deve essere un sottoinsieme degli utenti autorizzati in lettura.

#gl("age", capitalize: true) supporta nativamente la cifratura per destinatari multipli: il contenuto è cifrato una volta sola con una chiave di sessione, e la chiave di sessione è cifrata separatamente per ogni destinatario autorizzato. Aggiungere o rimuovere un destinatario richiede solo la modifica dell'header del file cifrato nel #gl("commit") successivo — il contenuto non deve essere nuovamente cifrato.

Nei progetti a livello 4 il file `allowed_Dipendenti` risiede all'interno dello ZIP cifrato — è parte del contenuto riservato e non è accessibile a chi non ha i permessi di lettura. La verifica crittografica rimane comunque possibile per qualsiasi osservatore grazie al campo `allowed_signers` presente in chiaro nel `.sig`: questo campo contiene le chiavi pubbliche degli autorizzati al momento del #gl("commit") ed è parte del contenuto firmato, quindi la sua integrità è garantita dalla firma stessa. Un osservatore senza permessi di lettura può verificare che il #gl("commit") sia firmato da una chiave presente negli `allowed_signers` del `.sig`, risalire alla gerarchia tramite `_rvc_root` e verificare l'intera catena di fiducia — senza mai dover decifrare il contenuto del progetto.

Il file `allowed_Dipendenti` dentro lo ZIP rimane la fonte di verità completa per chi ha i permessi di lettura — contiene le chiavi pubbliche degli autorizzati con le relative informazioni ed eventuali dati aggiuntivi ad uso interno.

=== Gestione dei destinatari nel livello 4

Nei progetti a livello 4 il campo `recipients` del `.sig` contiene le identità complete dei destinatari autorizzati alla decifratura — le loro chiavi pubbliche #gl("age", capitalize: true) in chiaro. Chiunque possa leggere il `.sig` può determinare chi ha accesso al contenuto cifrato.

Questa scelta è deliberata. Meccanismi di oscuramento parziale — come fingerprint delle chiavi o lista nascosta — introducono complessità implementativa e buchi nella verificabilità senza offrire garanzie di riservatezza robuste: un osservatore che conosce le chiavi pubbliche dei candidati può sempre risalire alle identità. La riservatezza reale dei destinatari è garantita dalla scelta organizzativa di non distribuire le chiavi pubbliche dei dipendenti, non da meccanismi tecnici nel `.sig`.

La gestione dei destinatari segue le stesse regole degli `allowed_signers`: l'amministratore è sempre incluso tra i destinatari di qualsiasi progetto a livello 4. Aggiungere o rimuovere un destinatario richiede un nuovo #gl("commit") firmato dal responsabile o dall'amministratore che aggiorna l'header #gl("age", capitalize: true) del file ZIP cifrato — il contenuto non deve essere nuovamente cifrato.

#figure(caption: "Confronto tra i livelli di sicurezza configurabili.")[
  #table(
    columns: (auto, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    table.header(
      [*Livello*], [*Firma\ richiesta*], [*Signers\ verificati*], [*Verifica\ catena*], [*Contenuto\ cifrato*]
    ),
    [0 — Aperto],     [No],  [No],  [No],  [No],
    [1 — Autenticato],[Sì],  [No],  [No],  [No],
    [2 — Autorizzato],[Sì],  [Sì],  [No],  [No],
    [3 — Verificato], [Sì],  [Sì],  [Sì],  [No],
    [4 — Riservato],  [Sì],  [Sì],  [Sì],  [Sì],
  )
]

Il livello di sicurezza è definito nel primo #gl("commit") del progetto tramite il file `.rvc_policy` e non può essere abbassato nei #gl("commit") successivi. Al primo #gl("commit") il motore accetta il livello dichiarato nel `.rvc_policy` senza confronto con #gl("commit") precedenti — non esistendone. Per ogni #gl("commit") successivo il motore verifica che il campo `security_level` del `.sig` sia maggiore o uguale a quello del #gl("commit") precedente. Qualsiasi tentativo di abbassare il livello viene rifiutato indipendentemente dall'identità del firmatario.

L'innalzamento del livello di sicurezza può essere effettuato in qualsiasi momento tramite un #gl("commit") firmato dal responsabile del progetto o dall'amministratore. Una volta alzato, il nuovo livello diventa il minimo accettabile per tutti i #gl("commit") successivi — il sistema non permette di tornare al livello precedente.

== Gestione delle identità e ciclo di vita delle chiavi

La sicurezza di un sistema basato su crittografia-asimmetrica dipende interamente dalla riservatezza delle chiavi private. Una chiave-privata compromessa annulla tutte le garanzie crittografiche — autenticità, non ripudio e autorizzazione diventano prive di significato se un attaccante può produrre firme valide a nome di un utente legittimo. Il modello deve quindi definire procedure esplicite per la gestione ordinaria delle chiavi e per la risposta agli eventi straordinari.

=== Cambio chiave ordinario

Un dipendente può cambiare la propria coppia di chiavi #gl("ssh", capitalize: true) in qualsiasi momento — per cambio di dispositivo, per policy aziendale di rotazione periodica o per precauzione in seguito a eventi sospetti. La procedura è la seguente:

+ Il dipendente genera una nuova coppia di chiavi con `ssh-keygen -t ed25519`.
+ Il dipendente comunica la nuova chiave-pubblica al responsabile.
+ Il responsabile aggiorna il file `allowed_Dipendenti` rimuovendo la vecchia chiave-pubblica e aggiungendo la nuova.
+ Il responsabile produce un #gl("commit") amministrativo firmato con la modifica al file `allowed_Dipendenti` — il motore verifica che la firma appartenga al responsabile o all'amministratore prima di accettarla.
+ Dal #gl("commit") successivo il dipendente firma con la nuova chiave-privata.

I #gl("commit") prodotti con la vecchia chiave rimangono validi — erano firmati da un'identità autorizzata al momento della firma e il file `allowed_Dipendenti` di quei #gl("commit") conteneva la vecchia chiave-pubblica. La storia del progetto è immutabile e ogni cambio di chiave è tracciato nella catena.

=== Revoca per compromissione

Se una chiave-privata viene compromessa — rubata, esposta accidentalmente o sospettata tale — la revoca deve avvenire nel minor tempo possibile. La procedura è identica al cambio ordinario ma con priorità immediata: il responsabile aggiorna `allowed_Dipendenti` rimuovendo la chiave compromessa e produce un #gl("commit") amministrativo che documenta l'evento.

Esiste una finestra di rischio tra il momento della compromissione e il #gl("commit") di revoca: durante questo intervallo un attaccante in possesso della chiave-privata rubata può produrre #gl("commit") fraudolenti che risultano validi. La dimensione di questa finestra dipende dalla rapidità con cui la compromissione viene rilevata e comunicata al responsabile. Il sistema non può eliminare questa finestra — è una limitazione strutturale di qualsiasi sistema basato su revoca — ma la minimizza richiedendo che la revoca sia operativa dal #gl("commit") successivo senza procedure straordinarie.

I #gl("commit") fraudolenti prodotti durante la finestra di rischio rimangono nella storia e risultano valide rispetto al file `allowed_Dipendenti` di quel momento. La loro identificazione richiede un'analisi manuale della storia del progetto nel periodo sospetto. 

=== Revoca offline

In un sistema distribuito non esiste un meccanismo di revoca immediata globale — la revoca è un #gl("commit") che deve raggiungere tutti i nodi della rete. Se un dipendente revocato tenta di fare push su una #gl("repository") che non ha ancora ricevuto il #gl("commit") di revoca, il push viene accettato localmente ma rifiutato al momento della sincronizzazione con una #gl("repository") aggiornata.

Questo comportamento è accettabile nel contesto d'uso di #gl("rvc", capitalize: true): la sincronizzazione avviene tipicamente tramite push esplicito, e il rifiuto è immediato al primo tentativo di push successivo alla revoca. Se il dipendente revocato ha accesso fisico diretto alla #gl("repository") — ad esempio può copiare file nella cartella della #gl("repository") senza passare per il motore di #gl("rvc", capitalize: true) — il problema non è più di sicurezza del sistema di versionamento ma di controllo degli accessi fisici all'infrastruttura, che è fuori dallo scope di questo modello.

=== Successione del responsabile

Se un responsabile lascia l'azienda o viene rimosso dal ruolo, l'amministratore è l'unico soggetto autorizzato a nominare un sostituto. La procedura è la seguente:

+ L'amministratore aggiorna il file `allowed_Responsabili` in `_rvc_root` rimuovendo la chiave del responsabile uscente e aggiungendo quella del nuovo responsabile.
+ L'amministratore firma la modifica con la propria chiave operativa e produce un #gl("commit") su `_rvc_root`.
+ Il nuovo responsabile acquisisce immediatamente i permessi sul progetto e può modificare `allowed_Dipendenti`.

Fino alla nomina del sostituto il progetto rimane in stato di attesa: i dipendenti esistenti continuano a committare normalmente, ma nessuna modifica ai permessi è possibile. Questo stato non interrompe lo sviluppo — interrompe solo la gestione amministrativa del progetto. Se il responsabile uscente era l'unico soggetto con la conoscenza operativa del progetto, il problema è organizzativo e non tecnico — il sistema garantisce la continuità dei #gl("commit") esistenti ma non può sostituire la conoscenza umana.

=== Compromissione della chiave dell'amministratore

La compromissione della chiave operativa dell'amministratore è lo scenario più critico del modello. L'amministratore usa la chiave master — conservata offline — per revocare la chiave operativa compromessa e nominarne una nuova. La procedura è la seguente:

+ L'amministratore recupera il dispositivo offline contenente la chiave-privata master.
+ Genera una nuova coppia di chiavi operativa e ne firma la parte pubblica con la chiave master, creando il nuovo certificato di delega.
+ Produce un speciale #gl("commit") amministrativo su `_rvc_root` che aggiorna il file `allowed_Dipendenti` (inserendo la nuova chiave operativa e rimuovendo la vecchia compromessa) e aggiorna il certificato di delega.
+ Questo #gl("commit") di revoca viene firmato eccezionalmente con la *chiave-privata master*.
+ Il motore di #gl("rvc", capitalize: true) riceve il #gl("commit"). Poiché il firmatario non è in `allowed_Dipendenti` prima di rifutare il #gl("commit") verifica la firma contro il file `master.pub` registrato in modo immutabile nel #gl("commit") iniziale di `_rvc_root`. Se la firma combacia, il motore riconosce l'autorità suprema della chiave master, accetta il #gl("commit") e rende operativa la nuova delega altriemnti rifiuta il #gl("commit").

Chiunque possieda la chiave-pubblica master può verificare la legittimità della nuova chiave operativa e, da lì, ricominciare a verificare la catena di fiducia. I #gl("commit") prodotti con la vecchia chiave operativa rimangono validi — erano legittimi al momento della firma. I #gl("commit") prodotti da un attaccante con la chiave compromessa durante la finestra di rischio sono identificabili come fraudolenti tramite analisi della storia nel periodo sospetto.

La chiave master non viene mai usata nelle operazioni ordinarie — il suo utilizzo è limitato a questo scenario e alla firma iniziale della chiave operativa. Questa separazione garantisce che la compromissione della chiave operativa, per quanto critica, non comporti la perdita irreversibile del controllo della #gl("repository").

== Gestione dei branch

I #gl("branch") sono uno strumento fondamentale nello sviluppo software parallelo — permettono di isolare funzionalità, correzioni e sperimentazioni senza interferire con il lavoro principale. In un sistema di versionamento sicuro la gestione dei #gl("branch") introduce scenari che vanno affrontati esplicitamente: un #gl("branch") può diventare obsoleto, può essere abbandonato o può risultare compromesso a seguito di #gl("commit") non autorizzati.

Il principio fondamentale che governa la gestione dei #gl("branch") nel modello proposto è l'*immutabilità della storia*: nessun #gl("commit") viene mai cancellato o modificato retroattivamente. Qualsiasi intervento su un #gl("branch") — archiviazione, chiusura o dichiarazione di compromissione — avviene aggiungendo nuovi #gl("commit") che ne attestano lo stato, non rimuovendo quelli esistenti. Questo principio garantisce che la storia del progetto rimanga sempre verificabile nella sua interezza, inclusa la traccia degli eventi straordinari.

=== Archiviazione di un branch 

Un #gl("branch") di sviluppo che ha concluso il proprio ciclo di vita — perché la funzionalità è stata integrata nel #gl("branch") principale o perché è stata abbandonata — può essere marcato come archiviato tramite un #gl("commit") amministrativo. Il responsabile produce un #gl("commit") firmato sul #gl("branch") contenente il file speciale `.rvc_branch_status` dentro lo ZIP, che dichiara lo stato `archived` e può includere motivazione, riferimenti e note aggiuntive. Lo stato viene estratto da questo file e riportato nel campo `branch_status` del `.sig` — in chiaro e parte del contenuto firmato. Il motore legge esclusivamente il campo `branch_status` del `.sig` per determinare lo stato del #gl("branch"), senza dover accedere allo ZIP — questo garantisce il corretto funzionamento a qualsiasi livello di sicurezza, incluso il livello 4 con contenuto cifrato.

I #gl("branch") archiviati sono trattati dal motore in una speciale modalità protetta: rifiutano tassativamente qualsiasi nuovo #gl("commit") ordinario, cristallizzando di fatto lo stato del codice. È possibile leggerne la storia in modo completo, ma i dipendenti non possono aggiungervi modifiche.
L'archiviazione è un'operazione reversibile esclusivamente tramite un #gl("commit") amministrativo con la modifica del file `.rvc_branch_status` per impostarlo ad `active`, con il conseguente aggiornamento del campo `branch_status` nel `.sig`. Questo #gl("commit") riporta il #gl("branch") allo stato operativo normale e ristabilisce i permessi di scrittura standard.

=== Chiusura di branch compromessi

Un #gl("branch") compromesso è un #gl("branch") su cui sono state prodotte uno o più #gl("commit") fraudolenti o non autorizzati — ad esempio durante la finestra di rischio successiva alla compromissione di una chiave-privata. La gestione di questo scenario segue una procedura in due fasi.

Nella prima fase il #gl("branch") compromesso viene dichiarato tale tramite un #gl("commit") amministrativo firmato dal responsabile o dall'amministratore. Il file `.rvc_branch_status` dentro lo ZIP dichiara lo stato `compromised`, l'identificativo del primo #gl("commit") sospetto, la motivazione e qualsiasi informazione aggiuntiva utile alla gestione dell'incidente. Lo stato `compromised` viene estratto e riportato nel campo `branch_status` del `.sig` — il motore legge questo campo direttamente e blocca immediatamente il #gl("branch") senza dover decifrare il contenuto, indipendentemente dal livello di sicurezza del progetto. I #gl("commit") fraudolenti rimangono nella storia e sono visibili, ma il #gl("branch") è marcato come non affidabile.

Nella seconda fase viene creato un nuovo #gl("branch") pulito a partire dall'ultimo #gl("commit") verificato come integro prima della compromissione. Lo sviluppo riprende sul nuovo #gl("branch"). Il #gl("branch") compromesso rimane nella #gl("repository") come evidenza dell'incidente — la sua storia è verificabile e costituisce la prova crittografica di cosa è accaduto e quando.

Questa procedura garantisce che la risposta a una compromissione non introduca ambiguità nella storia del progetto. Un approccio alternativo — cancellare i #gl("commit") fraudolenti — comprometterebbe l'integrità della catena e renderebbe impossibile distinguere una storia ripulita da una storia alterata da un attaccante.

=== Branch e permessi

Come definito nella sezione sulla gerarchia di fiducia, i permessi sono per progetto e non per #gl("branch"). Un dipendente autorizzato su un progetto può committare su qualsiasi #gl("branch") di quel progetto. La disciplina sui #gl("branch") — lavorare su #gl("branch") di sviluppo e fare merge sul #gl("branch") principale solo quando il codice è verificato — è una convenzione operativa del team, non un vincolo tecnico imposto dal sistema.

Questa scelta è deliberata: introdurre permessi per #gl("branch") aggiungerebbe complessità gestionale significativa senza un corrispondente aumento delle garanzie di sicurezza. La sicurezza del sistema si basa sull'autenticità dei #gl("commit"), non sulla restrizione dei #gl("branch") su cui è possibile scrivere. Un dipendente che produce un #gl("commit") non autorizzato — ad esempio direttamente sul #gl("branch") principale saltando il processo di verifica — è comunque identificabile tramite la firma crittografica e la sua azione è permanentemente tracciata nella storia del progetto.

== Analisi del divario <sec:analisi-divario>


