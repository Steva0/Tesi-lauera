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
    con un analisi del divario che confronta il modello ideale con lo stato attuale di RVC, identificando le aree di intervento affrontate nei capitoli successivi.
])
#v(1em)

== Sicurezza strutturale nei sistemi di versionamento distribuito

Un sistema di versionamento distribuito è considerato sicuro quando garantisce, per ogni operazione e indipendentemente dal canale di distribuzione, le seguenti proprietà fondamentali.

- *Integrità* — il contenuto di ogni #gl("commit") non può essere alterato senza che la modifica sia rilevabile. Questa proprietà è garantita da funzioni di #gl("hash") crittografiche: dato un archivio ZIP, la sua impronta #gl("sha256") è univoca e deterministica. Qualsiasi modifica — anche di un singolo byte — produce un hash completamente diverso. Un sistema che garantisce l'integrità permette a chiunque di verificare che il contenuto ricevuto sia identico a quello prodotto dall'autore, senza dover contattare nessuna fonte autoritativa.

- *Autenticità* — ogni #gl("commit") è crittograficamente attribuibile all'autore che l'ha prodotta. L'autenticità è garantita dalla #gl("firma-digitale"): l'autore firma il #gl("commit") con la propria #gl("chiave-privata") e chiunque può verificare la firma usando la corrispondente #gl("chiave-pubblica"). Senza autenticità, un sistema può garantire che i dati non siano stati modificati durante il trasferimento, ma non può garantire chi li abbia prodotti originariamente.

- *Non ripudio* — un autore non può negare di aver prodotto una #gl("commit") firmata con la propria #gl("chiave-privata"). Il non ripudio è una conseguenza diretta della firma digitale: poiché solo il possessore della chiave privata può produrre una firma valida, la presenza di una firma valida è prova crittografica della paternità. Questa proprietà è rilevante in contesti contrattuali e legali — se un fornitore di software distribuisce codice firmato, non può successivamente sostenere di non averlo prodotto.

- *Ordine verificabile* — la sequenza temporale delle modifiche è verificabile e non manipolabile retroattivamente. Questa proprietà è la più complessa da garantire in un sistema distribuito. Non è sufficiente che ogni #gl("commit") sia integra e autentica — è necessario anche che la loro sequenza sia crittograficamente vincolata, in modo che inserire, rimuovere o riordinare commit sia rilevabile. Questa proprietà è garantita dalla struttura a catena degli hash: ogni #gl("commit") incorpora l'hash della precedente, rendendo impossibile modificare un elemento della catena senza invalidare tutti quelli successivi.

=== Confronto con i sistemi esistenti

In #gl("git", capitalize: true) l'integrità è garantita dalla catena di hash #gl("sha256") — modificare una #gl("commit") invalida tutte quelle successive. Autenticità e non ripudio sono invece opzionali: la firma crittografica tramite #gl("ssh", capitalize: true) o GPG deve essere abilitata esplicitamente e non fa parte del flusso di lavoro standard. L'ordine temporale non è verificabile in senso assoluto — #gl("git", capitalize: true) non verifica i timestamp e permette la creazione di #gl("commit") con date arbitrarie:

```bash
GIT_AUTHOR_DATE="2020-01-01T00:00:00" git commit -m "commit retrodatata"
```

Il risultato è una #gl("commit") inserita nella storia con una data arbitraria, indistinguibile da una #gl("commit") legittima. Questa non è una vulnerabilità ma una scelta progettuale documentata — #gl("git", capitalize: true) garantisce l'ordine relativo tramite la catena di hash, non l'ordine temporale assoluto.

La distinzione tra disponibilità e correttezza di un sistema centralizzato è emersa concretamente il 23 aprile 2026, quando un bug nella funzionalità di merge queue di GitHub ha causato la generazione silenziosa di #gl("commit") errate per 2.092 pull request in 658 #gl("repository"). Le modifiche precedentemente unite sono state ripristinate dai merge successivi senza alcun avviso. La piattaforma era tecnicamente operativa durante tutto l'incidente — gli sviluppatori potevano ancora fare push, aprire pull request e fare merge. Il fatto che il merge stesse corrompendo silenziosamente il codice non risultava come incidente nella dashboard di stato. Disponibilità e correttezza non sono la stessa proprietà: un sistema può essere raggiungibile e simultaneamente produrre risultati errati. Un sistema distribuito che incorpora le garanzie crittografiche descritte sopra non dipende dalla correttezza del server per verificare l'integrità dei propri dati.

=== Applicazione in RVC

#gl("rvc", capitalize: true) garantisce l'integrità tramite il `cumulativeHash` — ogni #gl("commit") incorpora crittograficamente l'intera storia precedente. La firma #gl("ssh", capitalize: true) garantisce autenticità e non ripudio. L'ordine temporale presenta la stessa limitazione di #gl("git", capitalize: true) — gli identificativi sono timestamp codificati in base36 basati sull'orologio della macchina. Il `cumulativeHash` garantisce però l'ordine *relativo*: anche con timestamp errati o manipolati, la sequenza crittografica è verificabile e non manipolabile senza invalidare l'intera catena. Questa limitazione viene documentata come scelta consapevole — per il contesto d'uso di #gl("rvc", capitalize: true) la garanzia di ordine relativo è sufficiente e la complessità aggiuntiva di un sistema di timestamping certificato non è giustificata.

Per mitigare parzialmente questa limitazione, il modello proposto prevede che 
l'identificativo di ogni #gl("commit") sia composto da due componenti: il timestamp 
codificato in base36 per mantenere l'ordinamento cronologico visivo, e una 
porzione dell'hash del contenuto per garantire l'unicità crittografica. Un 
identificativo nella forma `0Q6JTD7XVZ_A3F2B1C4` — dove la prima parte è il 
timestamp e la seconda sono i primi otto caratteri dell'#gl("hash") #gl("sha256") 
dell'archivio ZIP — rende praticamente impossibile la collisione intenzionale 
mantenendo la leggibilità e l'ordinamento per nome file. Questa modifica è 
identificata come requisito nel modello ideale e discussa nella gap analysis 
nella @sec:gap-analysis.

== Requisiti di sicurezza formali

A partire dalle proprietà definite nella sezione precedente, è possibile derivare un insieme di requisiti formali che un sistema di versionamento distribuito sicuro deve soddisfare. Ogni requisito è classificato per priorità obbligatorio (O) o desiderabile (D) e verrà ripreso nella _gap analysis_ per valutare lo stato attuale di #gl("rvc", capitalize: true).

=== Integrità e ordine verificabile

L'integrità è la proprietà fondamentale di qualsiasi sistema di versionamento — senza di essa non è possibile fidarsi del contenuto ricevuto. In un sistema distribuito questa garanzia non può dipendere dalla fiducia nel canale di distribuzione ma deve essere incorporata nei dati stessi. Ogni #gl("commit") deve portare con sé la prova crittografica della propria integrità, e la struttura della catena deve rendere rilevabile qualsiasi tentativo di modifica retroattiva. Il problema dell'ordine temporale assoluto, come discusso nella sezione precedente, viene trattato come limitazione documentata piuttosto che come requisito da risolvere completamente — il sistema deve però garantire l'ordine relativo e rendere non manipolabili gli identificativi dei #gl("commit").

#figure(caption: "Requisiti di integrità e ordine verificabile.")[
  #table(
    columns: (auto, 1fr, auto),
    table.header([*Codice*], [*Descrizione*], [*Priorità*]),
    [RS01], [Ogni #gl("commit") deve essere verificabile tramite #gl("hash") crittografico del proprio contenuto], [O],
    [RS02], [La catena degli hash deve essere verificabile in modo che qualsiasi modifica a una #gl("commit") invalidi tutte le successive], [O],
    [RS03], [Gli identificativi dei #gl("commit") devono essere univoci e non manipolabili tramite timestamp arbitrari], [O],
    [RS04], [Il sistema deve documentare esplicitamente le proprie limitazioni in termini di ordine temporale assoluto], [O],
  )
]

=== Autenticità e non ripudio

Garantire l'integrità del contenuto non è sufficiente se non è possibile stabilire chi lo ha prodotto. L'autenticità richiede che ogni #gl("commit") sia crittograficamente attribuibile al suo autore tramite firma digitale. Il non ripudio è una conseguenza diretta di questa scelta — un autore non può negare di aver prodotto una #gl("commit") firmata con la propria #gl("chiave-privata"). La radice di fiducia dell'intera #gl("repository") è la prima #gl("commit"), che deve essere verificabile autonomamente da qualsiasi terzo in possesso della chiave pubblica dell'amministratore, senza dipendere da infrastrutture esterne.

#figure(caption: "Requisiti di autenticità e non ripudio.")[
  #table(
    columns: (auto, 1fr, auto),
    table.header([*Codice*], [*Descrizione*], [*Priorità*]),
    [RS05], [La prima #gl("commit") di ogni #gl("repository") deve costituire una radice di fiducia verificabile autonomamente], [O],
    [RS06], [Il sistema deve supportare e imporre la firma digitale tramite chiave #gl("ssh", capitalize: true) per ogni #gl("commit") nei progetti configurati con livello di sicurezza maggiore o uguale a 1], [O],
  )
]

=== Gestione delle identità

In un sistema multi-utente la gestione delle identità è il meccanismo che traduce le garanzie crittografiche in un modello organizzativo concreto. Non è sufficiente che le firme siano tecnicamente valide — è necessario che il sistema definisca chi è autorizzato a firmare, come vengono gestiti i cambi di personale e chi ha il potere di modificare questi elenchi. La gerarchia a tre livelli — amministratore, responsabile e dipendente — riflette la struttura organizzativa tipica di un'azienda software e permette di delegare la gestione dei permessi mantenendo un controllo centralizzato sulla radice di fiducia. La revoca deve essere immediata e non richiedere operazioni straordinarie — è sufficiente aggiornare il file di autorizzazione nella #gl("commit") successiva.

#figure(caption: "Requisiti di gestione delle identità.")[
  #table(
    columns: (auto, 1fr, auto),
    table.header([*Codice*], [*Descrizione*], [*Priorità*]),
    [RS07], [Il sistema deve supportare una gerarchia di fiducia a tre livelli: amministratore, responsabile e dipendente], [O],
    [RS08], [I permessi di scrittura devono essere configurabili per progetto tramite un file di autorizzazione versionato], [O],
    [RS09], [La revoca di un'identità deve essere efficace dalla #gl("commit") successiva alla modifica del file di autorizzazione], [O],
    [RS10], [La successione di un responsabile deve essere gestita esclusivamente dall'amministratore del sistema], [D],
  )
]

=== Sicurezza configurabile

Non tutti i progetti richiedono lo stesso livello di protezione. Un prototipo interno ha esigenze diverse da un modulo che gestisce dati sensibili di un cliente. Imporre lo stesso livello di sicurezza a tutti i progetti sarebbe eccessivamente restrittivo per alcuni e insufficiente per altri. Il modello proposto prevede livelli di sicurezza configurabili per progetto, con il vincolo che il livello non possa essere abbassato nel tempo — una scelta che previene attacchi che cercano di degradare le garanzie di sicurezza di un progetto già avviato. Per i progetti che richiedono la massima riservatezza, il contenuto delle #gl("commit") può essere cifrato con #gl("age", capitalize: true), rendendo il codice leggibile solo agli utenti autorizzati. La gestione della visibilità dei destinatari introduce un ulteriore grado di configurabilità, permettendo di bilanciare usabilità e privacy in base al contesto.

#figure(caption: "Requisiti di sicurezza configurabile.")[
  #table(
    columns: (auto, 1fr, auto),
    table.header([*Codice*], [*Descrizione*], [*Priorità*]),
    [RS11], [Il sistema deve supportare livelli di sicurezza configurabili per progetto, non abbassabili nel tempo], [D],
    [RS12], [Il contenuto delle #gl("commit") deve poter essere cifrato con #gl("age", capitalize: true) per progetti riservati], [D],
    [RS13], [La gestione dei destinatari nei progetti cifrati deve supportare modalità configurabili di visibilità], [D],
  )
]

=== Gestione dei branch

I branch sono uno strumento fondamentale nello sviluppo software parallelo, ma introducono scenari di sicurezza che vanno gestiti esplicitamente. Un branch può diventare inutile al termine di una funzionalità, oppure può risultare compromesso a seguito di una #gl("commit") fraudolenta o non autorizzata. In entrambi i casi il sistema deve fornire un meccanismo formale per dichiarare lo stato del branch, senza cancellare la storia — che rimane immutabile e verificabile — ma aggiungendo una #gl("commit") firmata che ne attesti la chiusura o la compromissione. Questo approccio mantiene la tracciabilità completa degli eventi, inclusa la prova della compromissione stessa.

#figure(caption: "Requisiti di gestione dei branch.")[
  #table(
    columns: (auto, 1fr, auto),
    table.header([*Codice*], [*Descrizione*], [*Priorità*]),
    [RS14], [I branch compromessi devono poter essere chiusi con una #gl("commit") firmata che ne attesti la compromissione], [D],
  )
]

I requisiti obbligatori definiscono le proprietà minime senza le quali il sistema non può essere considerato sicuro per il contesto d'uso descritto. I requisiti desiderabili estendono il modello con funzionalità che aumentano significativamente il livello di sicurezza, ma la cui assenza non compromette le garanzie fondamentali.

I requisiti RS01, RS02 e RS03 corrispondono alla proprietà di integrità e alla gestione dell'ordine verificabile. RS05 e RS06 garantiscono le proprietà di autenticità e non ripudio. RS07, RS08, RS09 e RS10 definiscono il modello di gestione delle identità e dei permessi. RS11, RS12 e RS13 estendono il modello con funzionalità di sicurezza configurabile. RS04 e RS14 affrontano rispettivamente la documentazione delle limitazioni note e la gestione degli incidenti sui branch.

== Gerarchia di fiducia

In un sistema di versionamento distribuito la fiducia non può essere delegata a un server centrale — deve essere incorporata nella struttura stessa dei dati. Il modello proposto definisce una gerarchia a tre livelli operativi più un livello esterno di sola lettura, ciascuno con responsabilità e permessi ben definiti. La gerarchia è asimmetrica: ogni livello superiore può esercitare i poteri del livello inferiore, ma non viceversa.

=== Amministratore (CapoProgetto)

L'amministratore è la radice assoluta di fiducia dell'intera #gl("repository"). Dispone di due chiavi crittografiche distinte: una chiave operativa utilizzata nelle operazioni quotidiane e una chiave master conservata offline su un dispositivo air-gapped o in una cassaforte fisica. La separazione tra le due chiavi limita la finestra di rischio in caso di compromissione: se la chiave operativa viene rubata o esposta, l'amministratore usa la chiave master per revocarla e nominarne una nuova senza perdere il controllo della #gl("repository").

La prima operazione alla creazione di una #gl("repository") è produrre il file `allowed_Responsabili` — l'elenco delle chiavi pubbliche dei responsabili autorizzati — e firmarlo con la chiave privata operativa. Questo file e la sua firma costituiscono la prima #gl("commit") della #gl("repository") e la radice di fiducia da cui deriva tutta la catena di verifica successiva. L'amministratore ha accesso in lettura e scrittura a tutti i progetti della #gl("repository") a qualsiasi livello di sicurezza, incluso il livello 4 con contenuto cifrato — la sua chiave pubblica è sempre inclusa tra i destinatari autorizzati.

=== Responsabile di progetto

Il responsabile gestisce uno o più progetti all'interno della #gl("repository"). Il ruolo viene assegnato dall'amministratore tramite inclusione nel file `allowed_Responsabili` — non può essere auto-assegnato né delegato a un altro responsabile. Per ogni progetto gestito, il responsabile mantiene il file `allowed_Dipendenti`, che elenca le chiavi pubbliche dei dipendenti autorizzati a committare. Questo file è versionato all'interno dello ZIP di ogni #gl("commit") del progetto, fa parte del contenuto hashato e firmato, e la sua storia è completamente tracciabile.

Il responsabile aggiunge o rimuove dipendenti dal proprio progetto in autonomia. L'amministratore può sovrascrivere il file `allowed_Dipendenti` di qualsiasi progetto in qualsiasi momento — il suo potere non è vincolato dalla struttura gerarchica. Se un responsabile lascia l'azienda o viene rimosso dal ruolo, l'amministratore nomina un sostituto aggiornando il file `allowed_Responsabili`. Fino alla nomina del sostituto il progetto entra in stato di attesa: i dipendenti esistenti possono continuare a committare, ma non è possibile aggiungere nuovi dipendenti né modificare i permessi esistenti.

=== Dipendente

Il dipendente è autorizzato a committare su un progetto se e solo se la propria chiave pubblica è presente nel file `allowed_Dipendenti` della #gl("commit") più recente di quel progetto. I permessi sono definiti per progetto — un dipendente autorizzato su ProgettoA non ha accesso a ProgettoB, anche se entrambi appartengono alla stessa #gl("repository"). Non esistono permessi per branch: un dipendente autorizzato su un progetto può committare su qualsiasi branch di quel progetto.

La revoca è operativa dalla #gl("commit") successiva alla modifica del file `allowed_Dipendenti`: il dipendente rimosso non può produrre #gl("commit") valide sul progetto. Le #gl("commit") prodotte prima della revoca rimangono valide in quanto firmate da un'identità che era autorizzata al momento della firma — la storia del progetto è immutabile e ogni modifica ai permessi è tracciata nella catena.

=== Cliente

Il cliente riceve la #gl("repository") e verifica autonomamente autenticità e integrità del contenuto, senza dipendere dall'infrastruttura del produttore. La verifica parte dalla chiave pubblica operativa dell'amministratore, ottenuta tramite un canale indipendente dalla #gl("repository") stessa — ad esempio il sito ufficiale del produttore distribuito tramite HTTPS. Con questa chiave il cliente verifica la firma sul file `allowed_Responsabili` della prima #gl("commit") e da lì risale crittograficamente all'intera catena di autorizzazioni e #gl("commit").

Il cliente non ha permessi di scrittura sulla #gl("repository"). Quando riceve un aggiornamento, verifica che le nuove #gl("commit") si colleghino correttamente alla catena già in suo possesso, partendo dalla stessa radice di fiducia. Nei progetti di livello 4 la chiave pubblica del cliente deve essere registrata tra i destinatari autorizzati per poter decifrare il contenuto — la verifica della catena e delle firme è comunque possibile senza decifrare, poiché l'hash nel file `.sig` è calcolato sul contenuto cifrato.

=== Inizializzazione della repository

La creazione di una nuova #gl("repository") segue questa procedura:

+ L'amministratore genera la coppia di chiavi master con `ssh-keygen -t ed25519` e conserva la chiave privata master su un dispositivo offline. La chiave pubblica master è l'ancora di fiducia primaria del sistema.
+ L'amministratore genera la coppia di chiavi operativa con `ssh-keygen -t ed25519`. La chiave pubblica operativa viene firmata con la chiave privata master, creando un certificato che attesta la delega operativa.
+ L'amministratore crea il file `allowed_Responsabili` con le chiavi pubbliche dei responsabili nominati e lo firma con la chiave privata operativa.
+ Il file `allowed_Responsabili`, la sua firma e il certificato della chiave operativa costituiscono la prima #gl("commit") della #gl("repository") — la radice di fiducia verificabile da qualsiasi terzo in possesso della chiave pubblica master.
+ La chiave pubblica master viene pubblicata su un canale indipendente dalla #gl("repository"). Chiunque la possieda può verificare la legittimità della chiave operativa e, da lì, tutta la catena di autorizzazioni.

In caso di compromissione della chiave operativa, l'amministratore genera una nuova coppia operativa, la firma con la chiave master e pubblica una #gl("commit") di revoca che dichiara la vecchia chiave non più valida e introduce la nuova. La chiave master non viene mai esposta durante le operazioni ordinarie — il suo utilizzo è limitato alla firma della chiave operativa e alle operazioni di revoca.

=== Inizializzazione di un progetto

La creazione di un nuovo progetto all'interno di una #gl("repository") esistente è gestita dal responsabile nominato per quel progetto, senza necessità di intervento dell'amministratore:

+ Il responsabile crea il file `allowed_Dipendenti` con le chiavi pubbliche dei dipendenti autorizzati.
+ Il responsabile crea il file `.rvc_policy` con il livello di sicurezza scelto per il progetto.
+ Il responsabile produce la prima #gl("commit") del progetto, firmata con la propria chiave privata. La firma è verificabile tramite il file `allowed_Responsabili` della #gl("repository").
+ Da questo momento i dipendenti elencati in `allowed_Dipendenti` sono autorizzati a committare sul progetto.

Il livello di sicurezza definito nella prima #gl("commit") non può essere abbassato — può essere alzato in qualsiasi momento tramite una #gl("commit") firmata dal responsabile o dall'amministratore. Questa scelta elimina la possibilità di degradare le garanzie di sicurezza di un progetto già avviato.

=== File amministrativi della repository

In RVC ogni #gl("commit") appartiene a un progetto — non esiste il concetto di #gl("commit") globale della #gl("repository"). I file amministrativi `allowed_Responsabili` e la sua firma devono però risiedere nella #gl("repository") in modo verificabile e versionato, indipendentemente da qualsiasi progetto specifico.

Il modello proposto risolve questo problema definendo un progetto riservato con nome convenzionale `_rvc_root`, dedicato esclusivamente all'amministrazione della #gl("repository"). Solo l'amministratore è autorizzato a committare su questo progetto — il file `allowed_Responsabili` e la sua firma risiedono all'interno dello ZIP di ogni #gl("commit") di `_rvc_root`, seguendo la stessa struttura di qualsiasi altro progetto. La verifica della radice di fiducia usa lo stesso codice che verifica qualsiasi altra #gl("commit") — nessun caso speciale è necessario nel motore.

Il nome `_rvc_root` è riservato per convenzione del modello. Per prevenire conflitti, il motore verifica all'inizializzazione che questo nome non sia già in uso e lo riserva automaticamente — qualsiasi tentativo di creare un progetto con questo nome da parte di un responsabile o dipendente viene rifiutato. Questa è l'unica modifica richiesta al motore di RVC rispetto al comportamento standard.

Questa scelta è preferita all'alternativa di file speciali nella radice della #gl("repository") perché non richiede modifiche architetturali al motore e mantiene la coerenza del modello — la verifica della radice di fiducia usa esattamente la stessa logica della verifica di qualsiasi altro progetto.

=== Catena di fiducia tra progetti

Il progetto `_rvc_root` non collega crittograficamente i progetti della #gl("repository") tra loro — ogni progetto mantiene una propria catena di #gl("commit") indipendente. La funzione di `_rvc_root` è certificare le identità autorizzate, non la struttura dei dati. La fiducia tra i progetti è gerarchica attraverso le identità, non crittografica attraverso la struttura.

La verifica di una #gl("commit") di un qualsiasi progetto segue questa catena:

+ La firma della #gl("commit") viene verificata contro le chiavi presenti in `allowed_Dipendenti`.
+ La firma di `allowed_Dipendenti` viene verificata contro la chiave del responsabile.
+ La chiave del responsabile viene verificata contro `allowed_Responsabili` presente in `_rvc_root`.
+ La firma di `allowed_Responsabili` viene verificata con la chiave pubblica master dell'amministratore, ottenuta fuori banda.

Questa catena implica un requisito operativo: la verifica completa di qualsiasi #gl("commit") richiede la presenza di `_rvc_root` nella #gl("repository"). Chi riceve la #gl("repository") riceve automaticamente tutti i progetti incluso `_rvc_root` — ma un sistema che distribuisce solo i file di un singolo progetto non permette la verifica completa della catena di fiducia.

=== Implicazioni di sicurezza della radice pubblica

Il progetto `_rvc_root` non può essere cifrato — deve essere leggibile da qualsiasi soggetto che voglia verificare la catena di fiducia, incluso il cliente. Questa necessità introduce una tensione strutturale tra verificabilità pubblica e riservatezza organizzativa.

Il contenuto di `_rvc_root` espone le chiavi pubbliche dei responsabili e, implicitamente, la struttura organizzativa dell'azienda. Le chiavi pubbliche non sono segrete per definizione, ma la lista dei responsabili è informazione sensibile — rivela chi ha potere decisionale sulla #gl("repository") e rende questi soggetti bersagli privilegiati per attacchi di ingegneria sociale e spear phishing. Analogamente, i nomi dei file ZIP nella #gl("repository") rivelano i nomi dei progetti anche quando il contenuto è cifrato a livello 4.

Il modello propone due mitigazioni parziali. La prima riguarda le identità: invece di utilizzare indirizzi email o nomi reali nel file `allowed_Responsabili`, si possono adottare identificativi opachi — ad esempio `resp-001` — riducendo la leggibilità immediata senza eliminare la tracciabilità per chi ha accesso alle informazioni di mappatura. La seconda riguarda i nomi dei progetti: l'uso di identificativi non descrittivi — ad esempio `PRJ-4A2F` invece di `ModuloPagamenti` — impedisce la mappatura immediata del contenuto della #gl("repository") a partire dalla struttura dei file.

Queste mitigazioni riducono la superficie di esposizione ma non la eliminano. Il trade-off tra verificabilità pubblica e riservatezza organizzativa è una limitazione strutturale del modello — qualsiasi sistema che permette la verifica autonoma della catena di fiducia deve necessariamente rendere pubblica almeno la radice di quella catena.

== Livelli di sicurezza configurabili

Un sistema di versionamento distribuito utilizzato in contesti aziendali deve servire esigenze di sicurezza eterogenee. Un prototipo interno in fase esplorativa, un modulo di produzione distribuito a clienti e un componente che gestisce dati finanziari hanno requisiti di protezione radicalmente diversi. Imporre un livello di sicurezza uniforme a tutti i progetti è eccessivamente restrittivo per alcuni e insufficiente per altri.

Il modello proposto introduce livelli di sicurezza configurabili per progetto, definiti alla creazione del progetto nel file `.rvc_policy` e non abbassabili nel tempo. Il vincolo di non abbassabilità è una scelta deliberata: un attaccante che compromette l'account di un responsabile non può degradare le garanzie di sicurezza di un progetto già avviato — può solo alzarle. Ogni livello è un sovrainsieme del precedente: un progetto a livello 3 soddisfa tutti i requisiti dei livelli 0, 1 e 2.

=== Livello 0 — Aperto

Nessuna firma è richiesta. Chiunque abbia accesso fisico alla #gl("repository") può aggiungere #gl("commit"). Non vengono verificate né l'identità dell'autore né l'integrità della catena. Questo livello è appropriato per prototipi interni in fase esplorativa dove la velocità di sviluppo è prioritaria e la tracciabilità formale non è richiesta. Non fornisce nessuna delle quattro proprietà di sicurezza definite nella sezione 4.1.

=== Livello 1 — Autenticato

Ogni #gl("commit") deve essere firmata digitalmente, ma non esiste una lista di identità autorizzate — qualsiasi chiave #gl("ssh", capitalize: true) valida è accettata. Il sistema verifica che la firma sia crittograficamente valida e che corrisponda a una chiave privata reale, ma non verifica se quella chiave appartenga a un soggetto autorizzato. Questo livello garantisce autenticità e non ripudio — ogni #gl("commit") è attribuibile a chi possiede la chiave corrispondente — ma non autorizzazione. È appropriato per repository interne dove tutti i partecipanti sono implicitamente fidati ma si vuole mantenere la tracciabilità delle modifiche.

=== Livello 2 — Autorizzato

Ogni #gl("commit") deve essere firmata da una chiave presente nel file `allowed_Dipendenti` del progetto. Il sistema verifica sia la validità crittografica della firma sia l'appartenenza dell'identità alla lista degli autorizzati. Questo livello garantisce autenticità, non ripudio e autorizzazione — solo i soggetti esplicitamente nominati dal responsabile possono produrre #gl("commit") valide. È il livello base raccomandato per qualsiasi progetto in produzione.

=== Livello 3 — Verificato

Come il livello 2, con l'aggiunta della verifica obbligatoria della catena degli hash a ogni operazione. Nessuna operazione — lettura, aggiornamento, push — può procedere se la catena risulta corrotta o incompleta. Mentre nei livelli precedenti la verifica della catena è un'operazione esplicita eseguita su richiesta, al livello 3 è una precondizione implicita di qualsiasi interazione con il progetto. Questo livello è appropriato per codice distribuito a clienti esterni, dove la garanzia di integrità deve essere continua e non delegabile a verifiche periodiche manuali.

=== Livello 4 — Riservato

Come il livello 3, con l'aggiunta della cifratura del contenuto degli archivi ZIP tramite #gl("age", capitalize: true). Solo i soggetti la cui chiave pubblica è registrata tra i destinatari autorizzati possono decifrare e leggere il contenuto. La verifica della catena e delle firme rimane possibile senza decifrare — l'#gl("hash") nel file `.sig` è calcolato sul contenuto cifrato, non su quello in chiaro. Questo livello è appropriato per progetti che contengono codice o dati la cui riservatezza è un requisito contrattuale o legale.

AGE supporta nativamente la cifratura per destinatari multipli: il contenuto è cifrato una volta sola con una chiave di sessione, e la chiave di sessione è cifrata separatamente per ogni destinatario autorizzato. Aggiungere o rimuovere un destinatario richiede solo la modifica dell'header del file cifrato nella #gl("commit") successiva — il contenuto non deve essere ricitrato.

=== Gestione dei destinatari nel livello 4

La cifratura del contenuto introduce il problema della visibilità dei destinatari: come può un utente sapere se ha accesso a un progetto riservato senza tentare la decifratura? Il modello propone tre modalità configurabili nel file `.rvc_policy`:

*Modalità nascosta* (`recipients_mode: hidden`) — nessuna informazione sui destinatari è esposta. L'utente deve tentare la decifratura per scoprire se ha accesso. Questa modalità offre la massima riservatezza — un osservatore esterno non può determinare chi ha accesso al progetto — ma comporta un'esperienza d'uso meno immediata e non permette la costruzione di strumenti di gestione automatica dei permessi.

*Modalità impronta* (`recipients_mode: fingerprint`) — il file `.sig` include i fingerprint delle chiavi pubbliche dei destinatari, calcolati come #gl("sha256") della chiave. Un utente che conosce la propria chiave pubblica può calcolare il proprio fingerprint e verificare se è presente nella lista senza rivelare la propria identità a osservatori esterni. Questa modalità è il compromesso raccomandato tra usabilità e riservatezza.

*Modalità pubblica* (`recipients_mode: public`) — le identità complete dei destinatari sono elencate in chiaro nel file `.sig`. Questa modalità offre la massima usabilità — è immediatamente verificabile chi ha accesso — ma espone la lista dei partecipanti a qualsiasi osservatore. In contesti dove anche la lista dei partecipanti è informazione sensibile, questa modalità introduce un rischio di target enumeration: un attaccante può identificare quali soggetti hanno accesso al codice più riservato e concentrare su di essi eventuali attacchi.

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

Il livello di sicurezza è definito nella prima #gl("commit") del progetto e non può essere abbassato. Questa proprietà è garantita dal motore di RVC: prima di accettare una nuova #gl("commit"), il sistema verifica che il livello dichiarato nel file `.rvc_policy` sia maggiore o uguale a quello della #gl("commit") precedente. Qualsiasi tentativo di abbassare il livello viene rifiutato indipendentemente dall'identità del firmatario.

== Gestione delle identità e ciclo di vita delle chiavi

La sicurezza di un sistema basato su crittografia asimmetrica dipende interamente dalla riservatezza delle chiavi private. Una chiave privata compromessa annulla tutte le garanzie crittografiche — autenticità, non ripudio e autorizzazione diventano prive di significato se un attaccante può produrre firme valide a nome di un utente legittimo. Il modello deve quindi definire procedure esplicite per la gestione ordinaria delle chiavi e per la risposta agli eventi straordinari.

=== Cambio chiave ordinario

Un dipendente può cambiare la propria coppia di chiavi #gl("ssh", capitalize: true) in qualsiasi momento — per cambio di dispositivo, per policy aziendale di rotazione periodica o per precauzione in seguito a eventi sospetti. La procedura è la seguente:

+ Il dipendente genera una nuova coppia di chiavi con `ssh-keygen -t ed25519`.
+ Il dipendente comunica la nuova chiave pubblica al responsabile.
+ Il responsabile aggiorna il file `allowed_Dipendenti` rimuovendo la vecchia chiave pubblica e aggiungendo la nuova.
+ Il responsabile produce una #gl("commit") firmata con la modifica al file `allowed_Dipendenti`.
+ Dalla #gl("commit") successiva il dipendente firma con la nuova chiave privata.

Le #gl("commit") prodotte con la vecchia chiave rimangono valide — erano firmate da un'identità autorizzata al momento della firma e il file `allowed_Dipendenti` di quelle #gl("commit") conteneva la vecchia chiave pubblica. La storia del progetto è immutabile e ogni cambio di chiave è tracciato nella catena.

=== Revoca per compromissione

Se una chiave privata viene compromessa — rubata, esposta accidentalmente o sospettata tale — la revoca deve avvenire nel minor tempo possibile. La procedura è identica al cambio ordinario ma con priorità immediata: il responsabile aggiorna `allowed_Dipendenti` rimuovendo la chiave compromessa e produce una #gl("commit") di revoca esplicita che documenta l'evento.

Esiste una finestra di rischio tra il momento della compromissione e la #gl("commit") di revoca: durante questo intervallo un attaccante in possesso della chiave privata rubata può produrre #gl("commit") fraudolente che risultano valide. La dimensione di questa finestra dipende dalla rapidità con cui la compromissione viene rilevata e comunicata al responsabile. Il sistema non può eliminare questa finestra — è una limitazione strutturale di qualsiasi sistema basato su revoca — ma la minimizza richiedendo che la revoca sia operativa dalla #gl("commit") successiva senza procedure straordinarie.

Le #gl("commit") fraudolente prodotte durante la finestra di rischio rimangono nella storia e risultano valide rispetto al file `allowed_Dipendenti` di quel momento. La loro identificazione richiede un'analisi manuale della storia del progetto nel periodo sospetto. 

=== Revoca offline

In un sistema distribuito non esiste un meccanismo di revoca immediata globale — la revoca è una #gl("commit") che deve raggiungere tutti i nodi della rete. Se un dipendente revocato tenta di fare push su una #gl("repository") che non ha ancora ricevuto la #gl("commit") di revoca, il push viene accettato localmente ma rifiutato al momento della sincronizzazione con una #gl("repository") aggiornata.

Questo comportamento è accettabile nel contesto d'uso di RVC: la sincronizzazione avviene tipicamente tramite push esplicito, e il rifiuto è immediato al primo tentativo di push successivo alla revoca. Se il dipendente revocato ha accesso fisico diretto alla #gl("repository") — ad esempio può copiare file nella cartella della repository senza passare per il motore di RVC — il problema non è più di sicurezza del sistema di versionamento ma di controllo degli accessi fisici all'infrastruttura, che è fuori dallo scope di questo modello.

=== Successione del responsabile

Se un responsabile lascia l'azienda o viene rimosso dal ruolo, l'amministratore è l'unico soggetto autorizzato a nominare un sostituto. La procedura è la seguente:

+ L'amministratore aggiorna il file `allowed_Responsabili` in `_rvc_root` rimuovendo la chiave del responsabile uscente e aggiungendo quella del nuovo responsabile.
+ L'amministratore firma la modifica con la propria chiave operativa e produce una #gl("commit") su `_rvc_root`.
+ Il nuovo responsabile acquisisce immediatamente i permessi sul progetto e può modificare `allowed_Dipendenti`.

Fino alla nomina del sostituto il progetto rimane in stato di attesa: i dipendenti esistenti continuano a committare normalmente, ma nessuna modifica ai permessi è possibile. Questo stato non interrompe lo sviluppo — interrompe solo la gestione amministrativa del progetto. Se il responsabile uscente era l'unico soggetto con la conoscenza operativa del progetto, il problema è organizzativo e non tecnico — il sistema garantisce la continuità delle #gl("commit") esistenti ma non può sostituire la conoscenza umana.

=== Compromissione della chiave dell'amministratore

La compromissione della chiave operativa dell'amministratore è lo scenario più critico del modello. L'amministratore usa la chiave master — conservata offline — per revocare la chiave operativa compromessa e nominarne una nuova. La procedura è la seguente:

+ L'amministratore recupera il dispositivo offline contenente la chiave master.
+ Genera una nuova coppia di chiavi operativa.
+ Firma la nuova chiave pubblica operativa con la chiave privata master.
+ Produce una #gl("commit") su `_rvc_root` che dichiara la vecchia chiave operativa non più valida e introduce la nuova, firmata con la chiave master.
+ Pubblica la nuova chiave pubblica operativa sul canale indipendente dalla #gl("repository").

Chiunque possieda la chiave pubblica master può verificare la legittimità della nuova chiave operativa e, da lì, ricominciare a verificare la catena di fiducia. Le #gl("commit") prodotte con la vecchia chiave operativa rimangono valide — erano legittime al momento della firma. Le #gl("commit") prodotte da un attaccante con la chiave compromessa durante la finestra di rischio sono identificabili come fraudolente tramite analisi della storia nel periodo sospetto.

La chiave master non viene mai usata nelle operazioni ordinarie — il suo utilizzo è limitato a questo scenario e alla firma iniziale della chiave operativa. Questa separazione garantisce che la compromissione della chiave operativa, per quanto critica, non comporti la perdita irreversibile del controllo della #gl("repository").

== Gestione dei branch

I branch sono uno strumento fondamentale nello sviluppo software parallelo — permettono di isolare funzionalità, correzioni e sperimentazioni senza interferire con il lavoro principale. In un sistema di versionamento sicuro la gestione dei branch introduce scenari che vanno affrontati esplicitamente: un branch può diventare obsoleto, può essere abbandonato o può risultare compromesso a seguito di #gl("commit") non autorizzate.

Il principio fondamentale che governa la gestione dei branch nel modello proposto è l'*immutabilità della storia*: nessuna #gl("commit") viene mai cancellata o modificata retroattivamente. Qualsiasi intervento su un branch — archiviazione, chiusura o dichiarazione di compromissione — avviene aggiungendo nuove #gl("commit") che ne attestano lo stato, non rimuovendo quelle esistenti. Questo principio garantisce che la storia del progetto rimanga sempre verificabile nella sua interezza, inclusa la traccia degli eventi straordinari.

=== Archiviazione di branch inutili

Un branch di sviluppo che ha concluso il proprio ciclo di vita — perché la funzionalità è stata integrata nel branch principale o perché è stata abbandonata — può essere marcato come archiviato. Il responsabile produce una #gl("commit") firmata sul branch con un file speciale `.rvc_branch_status` all'interno dello ZIP che dichiara lo stato `archived` e la motivazione. Lo stato viene riportato anche nel campo `branch_status` del file `.sig` di quella #gl("commit") — in chiaro e firmato crittograficamente insieme agli altri metadati. Questo permette al motore di RVC di rilevare lo stato del branch leggendo esclusivamente il `.sig`, senza dover decifrare lo ZIP, garantendo il corretto funzionamento anche per i progetti a livello 4.

Il motore tratta i branch archiviati come sola lettura — è possibile leggerne la storia ma non aggiungere nuove #gl("commit"). L'archiviazione è reversibile: il responsabile o l'amministratore può produrre una nuova #gl("commit") che riporta lo stato a `active`. Questa operazione è tracciata nella catena e richiede una firma autorizzata.

=== Chiusura di branch compromessi

Un branch compromesso è un branch su cui è stata prodotta una o più #gl("commit") fraudolente o non autorizzate — ad esempio durante la finestra di rischio successiva alla compromissione di una chiave privata. La gestione di questo scenario segue una procedura in due fasi.

Nella prima fase il branch compromesso viene dichiarato tale tramite una #gl("commit") firmata dal responsabile o dall'amministratore. Il file `.rvc_branch_status` all'interno dello ZIP dichiara lo stato `compromised`, il riferimento all'identificativo della prima #gl("commit") sospetta e la motivazione. Lo stato `compromised` viene riportato anche nel campo `branch_status` del file `.sig` — in chiaro e firmato — in modo che il motore possa imporre il blocco immediato del branch senza dover decifrare il contenuto, indipendentemente dal livello di sicurezza del progetto. Il branch viene immediatamente bloccato — nessuna nuova #gl("commit") è accettata. Le #gl("commit") fraudolente rimangono nella storia e sono visibili, ma il branch è marcato come non affidabile.

Nella seconda fase viene creato un nuovo branch pulito a partire dall'ultima #gl("commit") verificata come integra prima della compromissione. Lo sviluppo riprende sul nuovo branch. Il branch compromesso rimane nella #gl("repository") come evidenza dell'incidente — la sua storia è verificabile e costituisce la prova crittografica di cosa è accaduto e quando.

Questa procedura garantisce che la risposta a una compromissione non introduca ambiguità nella storia del progetto. Un approccio alternativo — cancellare le #gl("commit") fraudolente — comprometterebbe l'integrità della catena e renderebbe impossibile distinguere una storia ripulita da una storia alterata da un attaccante.

=== Branch e permessi

Come definito nella sezione sulla gerarchia di fiducia, i permessi sono per progetto e non per branch. Un dipendente autorizzato su un progetto può committare su qualsiasi branch di quel progetto. La disciplina sui branch — lavorare su branch di sviluppo e fare merge sul branch principale solo quando il codice è verificato — è una convenzione operativa del team, non un vincolo tecnico imposto dal sistema.

Questa scelta è deliberata: introdurre permessi per branch aggiungerebbe complessità gestionale significativa senza un corrispondente aumento delle garanzie di sicurezza. La sicurezza del sistema si basa sull'autenticità delle #gl("commit"), non sulla restrizione dei branch su cui è possibile scrivere. Un dipendente che produce una #gl("commit") non autorizzata — ad esempio direttamente sul branch principale saltando il processo di verifica — è comunque identificabile tramite la firma crittografica e la sua azione è permanentemente tracciata nella storia del progetto.

== Gap analysis <sec:gap-analysis>


