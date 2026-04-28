#let glossary-terms = (
  (
    key: "rvc",
    short: [RVC],
    long: [Repositoryless Version Control],
    description: [Sistema di versionamento distribuito sviluppato da Zucchetti S.p.A. come alternativa a Git. Garantisce l'integrità dei contenuti tramite verifica crittografica degli hash di ogni commit, permettendo a qualsiasi utente di accertare autonomamente l'autenticità della repository ricevuta.]
  ),
  (
    key: "git",
    short: [Git],
    description: [Sistema di versionamento distribuito open source, creato da Linus Torvalds nel 2005. Garantisce l'integrità della storia tramite una catena di hash crittografici.]
  ),
  (
    key: "ssh",
    short: [SSH],
    long: [Secure Shell],
    description: [Protocollo crittografico per la comunicazione sicura su reti non affidabili. Utilizza crittografia asimmetrica per l'autenticazione e la cifratura del canale.]
  ),
  (
    key: "hash",
    short: [hash],
    description: [Funzione matematica che trasforma un dato di dimensione arbitraria in una stringa di lunghezza fissa. Una minima modifica dell'input produce un output completamente diverso, garantendo l'integrità dei dati.]
  ),
  (
    key: "commit",
    short: [commit],
    description: [Unità atomica di modifica in un sistema di versionamento. Rappresenta uno snapshot dello stato dei file in un determinato momento, accompagnato da metadati quali autore, data e messaggio descrittivo.]
  ),
  (
    key: "firma-digitale",
    short: [firma digitale],
    description: [Meccanismo crittografico che garantisce autenticità e integrità di un documento. Prodotta con la chiave privata del firmatario, può essere verificata da chiunque possieda la chiave pubblica corrispondente.]
  ),
  (
    key: "chiave-pubblica",
    short: [chiave pubblica],
    description: [Componente pubblica di una coppia di chiavi asimmetriche. Può essere distribuita liberamente e viene utilizzata per cifrare messaggi o verificare firme digitali.]
  ),
  (
    key: "chiave-privata",
    short: [chiave privata],
    description: [Componente segreta di una coppia di chiavi asimmetriche. Deve essere custodita esclusivamente dal proprietario e viene utilizzata per decifrare messaggi o produrre firme digitali.]
  ),
  (
    key: "crittografia-asimmetrica",
    short: [crittografia asimmetrica],
    description: [Sistema crittografico che utilizza una coppia di chiavi matematicamente correlate: una pubblica e una privata. Ciò che viene cifrato con una chiave può essere decifrato solo con l'altra.]
  ),
  (
    key: "threat-modeling",
    short: [threat modeling],
    description: [Processo strutturato di analisi della sicurezza che identifica gli asset da proteggere, i possibili attaccanti, le minacce e le contromisure appropriate.]
  ),
  (
    key: "age",
    short: [AGE],
    long: [Actually Good Encryption],
    description: [Strumento moderno per la cifratura di file. Utilizza algoritmi crittografici contemporanei come X25519 e ChaCha20-Poly1305, con un'interfaccia volutamente semplice.]
  ),
  (
    key: "mitre-attack",
    short: [MITRE ATT\&CK],
    description: [Framework pubblico che cataloga tattiche e tecniche usate dagli attaccanti in scenari reali. Utilizzato per pianificare analisi di sicurezza e mappare scenari di attacco.]
  ),
)