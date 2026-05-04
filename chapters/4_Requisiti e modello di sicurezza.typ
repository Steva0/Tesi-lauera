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

A partire dalle proprietà definite nella sezione precedente, è possibile derivare un insieme di requisiti formali che un sistema di versionamento distribuito sicuro deve soddisfare. Ogni requisito è classificato per priorità — obbligatorio (O), desiderabile (D) o facoltativo (F) — e verrà ripreso nella _gap analysis_ per valutare lo stato attuale di #gl("rvc", capitalize: true).

#figure(caption: "Requisiti di sicurezza del modello proposto.")[
  #table(
    columns: (auto, 1fr, auto),
    align: (center, left, center),
    table.header([*Codice*], [*Descrizione*], [*Priorità*]),
    
    // Integrità e radice di fiducia
    [RS01], [Ogni #gl("commit") deve essere verificabile tramite #gl("hash") crittografico del proprio contenuto], [O],
    [RS02], [La catena degli hash deve essere verificabile in modo che qualsiasi modifica a una #gl("commit") invalidi tutte le successive], [O],
    [RS03], [La prima #gl("commit") di ogni #gl("repository") deve costituire una radice di fiducia verificabile autonomamente], [O],
    
    // Autenticità e non ripudio
    [RS04], [Il sistema deve supportare e imporre la firma digitale tramite chiave SSH per ogni commit nei progetti configurati con livello di sicurezza maggiore o uguale a 1], [O],
    
    // Gestione delle identità e dei permessi
    [RS05], [Il sistema deve supportare una gerarchia di fiducia a tre livelli: amministratore, responsabile e dipendente], [O],
    [RS06], [I permessi di scrittura devono essere configurabili per progetto tramite un file di autorizzazione versionato], [O],
    [RS07], [La revoca di un'identità deve essere efficace dalla #gl("commit") successiva alla modifica del file di autorizzazione], [O],
    [RS08], [La successione di un responsabile deve essere gestita esclusivamente dall'amministratore del sistema], [D],
    
    // Ordine temporale
    [RS09], [Gli identificativi dei #gl("commit") devono essere univoci e non manipolabili tramite timestamp arbitrari], [O],
    [RS10], [Il sistema deve documentare esplicitamente le proprie limitazioni in termini di ordine temporale assoluto], [O],
    
    // Sicurezza configurabile e funzionalità avanzate
    [RS11], [Il sistema deve supportare livelli di sicurezza configurabili per progetto, non abbassabili nel tempo], [D],
    [RS12], [Il contenuto delle #gl("commit") deve poter essere cifrato con #gl("age", capitalize: true) per progetti riservati], [D],
    [RS13], [La gestione dei destinatari nei progetti cifrati deve supportare modalità configurabili di visibilità], [D],
    [RS14], [I branch compromessi devono poter essere chiusi con una #gl("commit") firmata che ne attesti la compromissione], [D],
  )
]

I requisiti obbligatori definiscono le proprietà minime senza le quali il sistema non può essere considerato sicuro per il contesto d'uso descritto. I requisiti desiderabili estendono il modello con funzionalità che aumentano significativamente il livello di sicurezza, ma la cui assenza non compromette le garanzie fondamentali.

I requisiti RS01, RS02 e RS12 corrispondono alla proprietà di integrità e alla definizione della radice di fiducia. RS03 garantisce le proprietà di autenticità e non ripudio. RS04, RS05, RS06 e RS13 definiscono il modello di gestione delle identità e dei permessi. RS07 e RS11 affrontano il problema dell'ordine temporale. Infine, i requisiti RS08, RS09, RS10 e RS14 estendono il modello con funzionalità avanzate, quali la sicurezza configurabile, la cifratura e la risposta alle compromissioni.

== Gap analysis <sec:gap-analysis>


