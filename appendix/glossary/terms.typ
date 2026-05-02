#let glossary-terms = (
  (
    key: "rvc",
    short: "RVC",
    long: "Repositoryless Version Control",
    description: [Sistema di versionamento distribuito sviluppato da Zucchetti S.p.A. come alternativa a Git. Garantisce l'integrità dei contenuti tramite verifica crittografica degli hash di ogni commit, permettendo a qualsiasi utente di accertare autonomamente l'autenticità della repository ricevuta.]
  ),
  (
    key: "git",
    short: "Git",
    description: [Sistema di versionamento distribuito open source, creato da Linus Torvalds nel 2005. Garantisce l'integrità della storia tramite una catena di hash crittografici.]
  ),
  (
    key: "ssh",
    short: "SSH",
    long: "Secure Shell",
    description: [Protocollo crittografico per la comunicazione sicura su reti non affidabili. Utilizza crittografia asimmetrica per l'autenticazione e la cifratura del canale.]
  ),
  (
    key: "hash",
    short: "hash",
    description: [Funzione matematica che trasforma un dato di dimensione arbitraria in una stringa di lunghezza fissa. Una minima modifica dell'input produce un output completamente diverso, garantendo l'integrità dei dati.]
  ),
  (
    key: "commit",
    short: "commit",
    description: [Unità atomica di modifica in un sistema di versionamento. Rappresenta uno snapshot dello stato dei file in un determinato momento, accompagnato da metadati quali autore, data e messaggio descrittivo.]
  ),
  (
    key: "firma-digitale",
    short: "firma digitale",
    description: [Meccanismo crittografico che garantisce autenticità e integrità di un documento. Prodotta con la chiave privata del firmatario, può essere verificata da chiunque possieda la chiave pubblica corrispondente.]
  ),
  (
    key: "chiave-pubblica",
    short: "chiave pubblica",
    description: [Componente pubblica di una coppia di chiavi asimmetriche. Può essere distribuita liberamente e viene utilizzata per cifrare messaggi o verificare firme digitali.]
  ),
  (
    key: "chiave-privata",
    short: "chiave privata",
    description: [Componente segreta di una coppia di chiavi asimmetriche. Deve essere custodita esclusivamente dal proprietario e viene utilizzata per decifrare messaggi o produrre firme digitali.]
  ),
  (
    key: "crittografia-asimmetrica",
    short: "crittografia asimmetrica",
    description: [Sistema crittografico che utilizza una coppia di chiavi matematicamente correlate: una pubblica e una privata. Ciò che viene cifrato con una chiave può essere decifrato solo con l'altra.]
  ),
  (
    key: "threat-modeling",
    short: "threat modeling",
    description: [Processo strutturato di analisi della sicurezza che identifica gli asset da proteggere, i possibili attaccanti, le minacce e le contromisure appropriate.]
  ),
  (
    key: "age",
    short: "AGE",
    long: "Actually Good Encryption",
    description: [Strumento moderno per la cifratura di file. Utilizza algoritmi crittografici contemporanei come X25519 e ChaCha20-Poly1305, con un'interfaccia volutamente semplice.]
  ),
  (
    key: "mitre-attack",
    short: "MITRE ATT&CK",
    description: [Framework pubblico che cataloga tattiche e tecniche usate dagli attaccanti in scenari reali. Utilizzato per pianificare analisi di sicurezza e mappare scenari di attacco.]
  ),
  (
    key: "repository",
    short: "repository",
    description: [Archivio che contiene la storia completa delle modifiche di un progetto sotto controllo versione, inclusi tutti i commit, i branch e i tag.]
  ),
  (
    key: "branch",
    short: "branch",
    description: [Linea di sviluppo parallela all'interno di un sistema di versionamento. Permette di lavorare su funzionalità o correzioni in modo isolato rispetto al ramo principale.]
  ),
  (
    key: "checkout",
    short: "checkout",
    description: [Operazione che estrae una versione specifica di un progetto dalla repository, portando i file nella directory di lavoro.]
  ),
  (
    key: "vcs",
    short: "VCS",
    long: "Version Control System",
    description: [Sistema software che registra le modifiche ai file nel tempo, permettendo di recuperare versioni precedenti, confrontare cambiamenti e coordinare il lavoro di più sviluppatori.]
  ),
  (
    key: "crittografia-simmetrica",
    short: "crittografia simmetrica",
    description: [Sistema crittografico in cui mittente e destinatario utilizzano la stessa chiave segreta per cifrare e decifrare i messaggi. Richiede uno scambio sicuro della chiave prima della comunicazione.]
  ),
  (
    key: "ed25519",
    short: "Ed25519",
    description: [Algoritmo di firma digitale basato sulla curva ellittica Curve25519. Produce chiavi di 256 bit con un livello di sicurezza equivalente a RSA con chiavi da 3000 bit, risultando più efficiente e compatto.]
  ),
  (
    key: "allowed-signers",
    short: "allowed signers",
    description: [File di testo contenente l'elenco delle identità autorizzate a firmare, ciascuna associata alla propria chiave pubblica SSH. Utilizzato da ssh-keygen per verificare che una firma provenga da un firmatario riconosciuto.]
  ),
  (
    key: "namespace",
    short: "namespace",
    description: [Nel contesto della firma SSH, stringa che identifica il contesto d'uso di una firma e previene attacchi di riutilizzo: una firma prodotta con un certo namespace non può essere usata in un contesto diverso.]
  ),
  (
    key: "blockchain",
    short: "blockchain",
    description: [Struttura dati in cui ogni elemento contiene il riferimento crittografico all'elemento precedente, formando una catena in cui qualsiasi modifica a un elemento invalida tutti i successivi.]
  ),
  (
    key: "cpl",
    short: "CPL",
    long: "CodePainter Language",
    description: [Linguaggio di programmazione proprietario sviluppato da Zucchetti S.p.A. Interpretato, tipizzato staticamente, con sintassi simile al Pascal. Utilizzato per lo sviluppo di RVC e dei prodotti software Zucchetti.]
  ),
  (
    key: "sha256",
    short: "SHA-256",
    long: "Secure Hash Algorithm 256",
    description: [Funzione di hash crittografica che produce un'impronta digitale di 256 bit. Ampiamente utilizzata per verificare l'integrità dei dati grazie alla sua resistenza alle collisioni e alla non invertibilità.]
  ),
  (
    key: "jit",
    short: "JIT",
    long: "Just-In-Time",
    description: [Tecnica di compilazione che traduce il codice intermedio in codice macchina durante l'esecuzione, migliorando le prestazioni rispetto alla sola interpretazione.]
  ),
  (
    key: "manifest",
    short: "manifest",
    description: [Nel contesto di RVC, file che descrive lo stato di tutti i file tracciati in un progetto in un dato momento: nomi, dimensioni, hash e versione di ogni file.]
  ),
  (
    key: "delta",
    short: "delta",
    description: [Differenza tra due versioni di un file o di un insieme di file. Nei sistemi di controllo versione, memorizzare solo i delta invece delle versioni complete riduce significativamente lo spazio occupato.]
  ),
  (
    key: "smart-working",
    short: "smart working",
    description: [Modalità di lavoro che consente di svolgere l'attività lavorativa da remoto, tipicamente da casa, utilizzando strumenti digitali per la comunicazione e la collaborazione.]
  ),
  (
    key: "llm",
    short: "LLM",
    long: "Large Language Model",
    description: [Modello di intelligenza artificiale addestrato su grandi quantità di testo, capace di generare, riassumere e analizzare linguaggio naturale. Utilizzato come strumento di supporto durante lo stage.]
  ),
  (
    key: "man-in-the-middle",
    short: "man-in-the-middle",
    description: [Tipo di attacco informatico in cui un attaccante si interpone nella comunicazione tra due parti senza che queste ne siano consapevoli, potendo intercettare o modificare i messaggi scambiati.]
  ),
  (
    key: "passphrase",
    short: "passphrase",
    description: [Sequenza di parole o caratteri utilizzata per proteggere una chiave privata. Più lunga e complessa di una password tradizionale, viene richiesta ogni volta che si utilizza la chiave.]
  ),
  (
    key: "white-box",
    short: "white-box",
    description: [Approccio di analisi della sicurezza con piena visibilità del codice sorgente e dell'architettura interna del sistema. Si contrappone all'analisi black-box, condotta senza accesso ai sorgenti.]
  ),
  (
    key: "black-box",
    short: "black-box",
    description: [Approccio di analisi della sicurezza condotto senza accesso al codice sorgente, osservando esclusivamente il comportamento esterno del sistema in risposta agli input forniti.]
  ),
)
