#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#import "@preview/cetz:0.3.1": canvas, draw
#import "../config/thesis-config.typ": gl, glpl, glossary-style, linkfn
#import "../config/variables.typ": *
#pagebreak(to:"odd")

= Tecnologie e fondamenti teorici <cap:tecnologie>
#text(style: "italic", [
    In questo capitolo sono illustrate le tecnologie e i concetti teorici alla base del progetto. Partendo dalla #gl("crittografia-asimmetrica"), vengono descritti #gl("ssh", capitalize: true), #gl("age", capitalize: true) e i sistemi di controllo versione, fino ad arrivare all'architettura di #gl("rvc", capitalize: true).
])
#v(1em)

== Crittografia asimmetrica e firma digitale

La crittografia è la disciplina che studia le tecniche per proteggere le informazioni rendendole illeggibili a chi non è autorizzato. Nella sua forma classica, detta _crittografia simmetrica_, mittente e destinatario condividono una stessa chiave segreta per cifrare e decifrare i messaggi. Questo approccio presenta un problema fondamentale: come si trasmette la chiave in modo sicuro prima ancora di poter comunicare in modo sicuro?

La risposta a questo problema arrivò negli anni '70 con la _crittografia asimmetrica_, detta anche _crittografia a chiave pubblica_. L'idea è elegante: ogni utente genera una coppia di chiavi matematicamente collegate tra loro. La *#gl("chiave-pubblica")* può essere distribuita liberamente a chiunque. La *#gl("chiave-privata")* deve rimanere segreta e non lasciare mai il dispositivo del proprietario. Le due chiavi sono collegate da una relazione matematica tale per cui ciò che viene cifrato con una può essere decifrato solo con l'altra, ma è computazionalmente impossibile ricavare la #gl("chiave-privata") a partire da quella pubblica.

Questo meccanismo permette due operazioni fondamentali:

- *Cifratura*: chiunque può cifrare un messaggio usando la #gl("chiave-pubblica") del destinatario. Solo il destinatario, possedendo la #gl("chiave-privata") corrispondente, potrà decifrarlo.
- *#gl("firma-digitale", capitalize: true)*: il mittente cifra un messaggio con la propria #gl("chiave-privata"). Chiunque, usando la #gl("chiave-pubblica") del mittente, può verificare che il messaggio provenga effettivamente da lui e non sia stato alterato.

#figure(
  image("../images/flusso_crittografia_chiave_asimmetrica.png", width: 60%),
  caption: "Flusso trasferimento messaggio con uso di chiave pubblica e privata"
)

=== La firma digitale in dettaglio

La #gl("firma-digitale") non cifra il messaggio intero — sarebbe inefficiente. Funziona invece in questo modo:

+ Il mittente calcola l'_hash_ del messaggio, ovvero una sua impronta digitale di dimensione fissa prodotta da una funzione matematica non invertibile.
+ Il mittente cifra quell'hash con la propria #gl("chiave-privata"). Il risultato è la #gl("firma-digitale").
+ Il destinatario riceve messaggio e firma. Decifra la firma usando la #gl("chiave-pubblica") del mittente, ottenendo l'hash originale.
+ Il destinatario calcola autonomamente l'hash del messaggio ricevuto e confronta i due valori. Se coincidono, la firma è valida: il messaggio proviene dal mittente dichiarato e non è stato modificato.

La sicurezza di questo meccanismo si basa su due proprietà: la resistenza alle collisioni delle funzioni di #gl("hash") (è praticamente impossibile trovare due messaggi diversi con lo stesso #gl("hash")) e l'impossibilità computazionale di produrre una firma valida senza possedere la #gl("chiave-privata").

#figure(
  image("../images/firma_documento.png", width: 73%),
  caption: "Flusso firma di un documento con chiave pubblica e privata"
)

=== Curve ellittiche: Ed25519

Gli algoritmi crittografici moderni si basano su problemi matematici computazionalmente difficili. RSA, il primo algoritmo a #gl("chiave-pubblica") diffuso, si basa sulla difficoltà di fattorizzare numeri molto grandi. Gli algoritmi moderni basati su _curve ellittiche_ offrono lo stesso livello di sicurezza con chiavi molto più corte, risultando più veloci ed efficienti.

*#gl("ed25519", capitalize: true)* è un algoritmo di #gl("firma-digitale") basato sulla curva ellittica Curve25519. Produce chiavi di 256 bit e firme di 512 bit, con un livello di sicurezza equivalente a RSA con chiavi da 3000 bit. È l'algoritmo raccomandato oggi per la firma #gl("ssh", capitalize: true) ed è quello utilizzato in questo progetto.

#figure(
  image("../images/dimensione_chiave.png", width: 65%),
  caption: "Comparazione dimensione tra tipologie di chiavi"
)

== SSH e ssh-keygen

#gl("ssh", capitalize: true) è un protocollo di rete che permette di stabilire connessioni sicure tra due macchine attraverso una rete non sicura. Nato come sostituto sicuro di Telnet e rsh, #gl("ssh", capitalize: true) cifra tutto il traffico e autentica sia il server che il client, impedendo attacchi di tipo _man-in-the-middle_.

=== Autenticazione con chiavi

#gl("ssh", capitalize: true) supporta due modalità principali di autenticazione: tramite password e tramite coppia di chiavi. L'autenticazione con chiavi è considerata più sicura e viene raccomandata in tutti i contesti professionali. Il funzionamento è il seguente:

+ L'utente genera una coppia di chiavi con `ssh-keygen`.
+ La #gl("chiave-pubblica") viene copiata sul server remoto, nella cartella `~/.ssh/authorized_keys`.
+ Al momento della connessione, il server invia una sfida cifrata con la #gl("chiave-pubblica") dell'utente.
+ Il client dimostra di possedere la #gl("chiave-privata") corrispondente risolvendo la sfida.
+ La connessione viene stabilita senza che la #gl("chiave-privata") abbia mai lasciato il client.

=== ssh-keygen per la firma di file

Oltre alla gestione delle chiavi #gl("ssh", capitalize: true), `ssh-keygen` offre una funzionalità meno nota ma molto utile: la firma e verifica di file arbitrari. Questo è il meccanismo che #gl("rvc", capitalize: true) utilizza per firmare crittograficamente i _commit_.

Il comando per firmare un file è:

```bash
ssh-keygen -Y sign -n <namespace> -f <chiave_privata> <file>
```

Il parametro `-n` specifica il _namespace_, una stringa che identifica il contesto d'uso della firma e previene attacchi di riutilizzo — una firma prodotta con #gl("namespace") `git` non può essere spacciata per una firma con #gl("namespace") `file`.

Il comando per verificare una firma è:

```bash
ssh-keygen -Y verify -n <namespace> -f <allowed_signers> -I <identità> -s <firma> < <file>
```

Il file `allowed_signers` è un elenco di identità autorizzate con le rispettive chiavi pubbliche, nel formato:

```
identita@esempio.com ssh-ed25519 AAAA...chiave...
```

Se la firma è valida e l'identità è presente nel file, il comando restituisce `Good "file" signature for <identità>`.

== AGE

*#gl("age", capitalize: true)* (_Actually Good Encryption_) è uno strumento moderno per la cifratura di file, progettato con l'obiettivo di essere semplice, sicuro e componibile. A differenza di PGP, che nel corso degli anni ha accumulato una complessità notevole, #gl("age", capitalize: true) offre un'interfaccia minimale con poche opzioni ben definite.

#gl("age", capitalize: true) supporta tre modalità di cifratura:

- *#gl("chiave-pubblica", capitalize: true)*: il file viene cifrato con la #gl("chiave-pubblica") del destinatario e può essere decifrato solo con la corrispondente #gl("chiave-privata").
- *Chiave #gl("ssh", capitalize: true)*: #gl("age", capitalize: true) può utilizzare le stesse chiavi #gl("ssh", capitalize: true) già esistenti (incluse le chiavi #gl("ed25519", capitalize: true)) come chiavi di cifratura, senza bisogno di generare nuove chiavi dedicate.
- *#gl("passphrase", capitalize: true)*: il file viene cifrato con una #gl("passphrase"), usando la funzione di derivazione `scrypt` per proteggersi da attacchi a dizionario.

Un file cifrato con #gl("age", capitalize: true) contiene nell'intestazione le informazioni necessarie per la decifratura (il tipo di chiave usata e la chiave di sessione cifrata), seguite dal contenuto cifrato con ChaCha20-Poly1305, un algoritmo moderno che garantisce sia riservatezza che integrità.

Nel contesto di questo progetto, #gl("age", capitalize: true) è stato studiato come tecnologia di riferimento per la fase successiva del lavoro, che prevede la progettazione di _repository_ cifrate con distribuzione dei permessi di accesso. In questa fase #gl("age", capitalize: true) permette di cifrare il contenuto di una _repository_ in modo che solo gli utenti autorizzati — identificati dalle loro chiavi pubbliche — possano decifrarla, senza dover condividere nessuna chiave segreta.

#figure(
  image("../images/file_age.png", width: 100%),
  caption: "Esempio di un file cifrato con AGE"
)

== Sistemi di controllo versione

=== Storia e evoluzione

I sistemi di controllo versione (_Version Control System_, #gl("vcs", capitalize: true)) nascono dalla necessità pratica di tenere traccia delle modifiche al codice sorgente nel tempo. Prima della loro diffusione, era comune affidare il versionamento a convenzioni manuali: copie di file con date nel nome, cartelle numerate, archivi compressi. Questo approccio era fragile, difficile da gestire in team e privo di qualsiasi garanzia di integrità.

Il primo sistema formale di controllo versione ampiamente adottato fu *SCCS* (_Source Code Control System_), sviluppato da Bell Labs nel 1972. SCCS introduceva il concetto di _delta_: invece di salvare ogni versione completa del file, memorizzava solo le differenze rispetto alla versione precedente, riducendo significativamente lo spazio occupato.

*RCS* (_Revision Control System_), sviluppato nel 1982, migliorò SCCS rendendolo più accessibile e introducendo il concetto di _branching_, ossia la possibilità di sviluppare linee di codice parallele a partire da un punto comune.

Entrambi questi sistemi operavano però a livello di singolo file e su singola macchina. Il passo successivo fu l'introduzione dei sistemi _centralizzati_.

==== Sistemi centralizzati

*CVS* (_Concurrent Versions System_), negli anni '90, portò il controllo versione in rete. Per la prima volta più sviluppatori potevano lavorare contemporaneamente sullo stesso progetto, con un server centrale che coordinava le modifiche. Il modello era semplice: il server custodisce l'intera storia del progetto; i client effettuano _checkout_ (scaricano una versione) e _commit_ (inviano le modifiche).

*Subversion* (SVN), rilasciato nel 2000, nacque esplicitamente come sostituto migliorato di CVS, correggendo molte delle sue limitazioni tecniche. SVN trattava l'intera struttura del progetto come un'unità atomica: un #gl("commit") poteva riguardare più file contemporaneamente, con la garanzia che o tutte le modifiche venivano salvate o nessuna.

Il limite fondamentale dei sistemi centralizzati era però strutturale: la presenza di un singolo punto di fallimento. Se il server non era raggiungibile, nessuno poteva fare #gl("commit"). Se il server veniva perso, si perdeva l'intera storia del progetto.

#figure(
  image("../images/Differenza-tra-controllo-delle-versioni-centralizzato-e-distribuito.png", width: 70%),
  caption: "Controllo versioni centralizzato vs distribuito"
)

==== Sistemi distribuiti

*#gl("git", capitalize: true)*, sviluppato da Linus Torvalds nel 2005 per gestire lo sviluppo del kernel Linux, rivoluzionò il campo introducendo un modello completamente distribuito. In #gl("git", capitalize: true) non esiste un server centrale: ogni sviluppatore possiede una copia completa dell'intera storia del progetto. I #gl("commit") avvengono localmente e possono essere sincronizzati con altri #gl("repository") in un secondo momento.

Questa architettura offre vantaggi significativi: si può lavorare offline, la storia del progetto è replicata su ogni macchina riducendo il rischio di perdita dei dati, e il _branching_ è diventato un'operazione economica e centrale nel flusso di lavoro.

*Mercurial*, rilasciato nello stesso anno di #gl("git", capitalize: true), adottò un approccio simile ma con un'interfaccia considerata più accessibile. Oggi #gl("git", capitalize: true) domina il mercato, ma l'ecosistema dei #gl("vcs", capitalize: true) distribuiti rimane vivo con strumenti come Fossil e Pijul.

=== Git in dettaglio

In #gl("git", capitalize: true) ogni oggetto — _blob_ (contenuto di un file), _tree_ (struttura di una directory), _commit_, _tag_ — è identificato da un #gl("hash") SHA del suo contenuto. Questo significa che l'identità di ogni oggetto è determinata dal suo contenuto: due oggetti con lo stesso contenuto hanno lo stesso #gl("hash"), e qualsiasi modifica produce un #gl("hash") diverso.

Un _commit_ #gl("git", capitalize: true) contiene: il riferimento all'albero dei file in quello stato, il riferimento al #gl("commit") precedente (_parent_), i metadati dell'autore e del committer, il messaggio di #gl("commit"). Questa struttura crea una catena crittograficamente collegata: modificare un #gl("commit") invalida tutti i #gl("commit") successivi, poiché i loro #gl("hash") dipendono dal #gl("hash") del precedente.

#gl("git", capitalize: true) supporta la firma crittografica dei #gl("commit") tramite GPG o #gl("ssh", capitalize: true). Tuttavia questa funzionalità è opzionale e deve essere abilitata esplicitamente — non fa parte del flusso di lavoro standard.

=== RVC a confronto con Git

#gl("rvc", capitalize: true) condivide con #gl("git", capitalize: true) il modello distribuito ma si differenzia in aspetti fondamentali di architettura e sicurezza.

#figure(caption: "Confronto tra Git e RVC.")[
  #table(
    columns: (1fr, 1fr, 1fr),
    align: (left, left, left),
    table.header([*Caratteristica*], [*#gl("git", capitalize: true)*], [*#gl("rvc", capitalize: true)*]),
    [Struttura], [_Repository_ con oggetti indicizzati], [File ZIP navigabili su filesystem],
    [Identificazione #gl("commit")], [#gl("hash", capitalize: true) SHA dell'oggetto #gl("commit")], [Timestamp codificato in base36],
    [Firma #gl("commit")], [Opzionale (GPG o #gl("ssh", capitalize: true))], [Integrata nell'architettura],
    [Server centrale], [Non richiesto ma comune], [Non richiesto per design],
    [#gl("repository", capitalize: true) multiple], [Un remote alla volta tipicamente], [Più #gl("repository") sincronizzate nativamente],
    [Linguaggio], [C], [#gl("cpl", capitalize: true)],
  )
]

La differenza più significativa riguarda la sicurezza: mentre in #gl("git", capitalize: true) la firma è un'opzione che il singolo sviluppatore può scegliere di abilitare o meno, in #gl("rvc", capitalize: true) è parte del modello stesso. Ogni _commit_ produce un file `.sig` che contiene gli #gl("hash") crittografici del contenuto e della catena precedente, costruendo una struttura analoga a una _blockchain_: modificare un #gl("commit") invalida tutti quelli successivi perché l'hash cumulativo non corrisponde più.

== RVC: architettura e funzionamento

=== Struttura della repository

Una _repository_ #gl("rvc", capitalize: true) è una semplice cartella sul filesystem, senza strutture dati complesse o indici da mantenere. Ogni _commit_ è rappresentato da due file:

- Un archivio *ZIP* contenente il _commit_ del progetto nella versione corrispondente, incluso il file `.FileManifest` che descrive lo stato di tutti i file tracciati.
- Un file *.sig* contenente i metadati del #gl("commit") e, opzionalmente, la firma #gl("ssh", capitalize: true).

I file seguono una convenzione di denominazione che codifica la struttura della storia:

```
<progetto>.<id>.<idPrecedente>.{autore}+tag.zip
<progetto>.<id>.sig
```

L'`id` è un timestamp codificato in base36 (cifre 0-9 e lettere A-Z), che permette l'ordinamento cronologico dei #gl("commit") semplicemente confrontando i nomi dei file. Il riferimento al #gl("commit") precedente è incorporato nel nome del file ZIP, rendendo la struttura della storia navigabile senza alcun indice aggiuntivo.

=== Il file .sig e la blockchain degli hash

Il file `.sig` è il cuore del sistema di sicurezza di #gl("rvc", capitalize: true). Contiene in formato binario proprietario i seguenti campi:

- `author`: il nome dell'autore del #gl("commit")
- `comment`: il messaggio del #gl("commit")
- `fn`: il nome del file ZIP corrispondente
- `id`: l'identificativo del #gl("commit")
- `prevId`: l'identificativo del #gl("commit") precedente
- `hash`: lo SHA256 del file ZIP di questo #gl("commit")
- `prevHash`: lo SHA256 del file ZIP del #gl("commit") precedente
- `cumulativeHash`: lo SHA256 della concatenazione dell'hash attuale con il `cumulativeHash` del #gl("commit") precedente

Il `cumulativeHash` è la chiave della sicurezza: ogni #gl("commit") incorpora crittograficamente l'intera storia precedente. Verificare che il `cumulativeHash` di un #gl("commit") sia corretto significa verificare implicitamente che tutti i #gl("commit") precedenti siano integri.

#figure(
  image("../images/cumulative_hash.png", width: 80%),
  caption: "Struttura del file .sig e la catena degli hash cumulativi"
)

Dopo i metadati, il file `.sig` contiene una firma #gl("ssh", capitalize: true) nel formato standard:

```
-----BEGIN SSH SIGNATURE-----
...
-----END SSH SIGNATURE-----
```

Questa firma attesta che l'autore dichiarato ha effettivamente prodotto il #gl("commit"), rendendo ogni modifica crittograficamente attribuibile.

=== Il linguaggio CPL

#gl("rvc", capitalize: true) è scritto in *#gl("cpl", capitalize: true)* (_CodePainter Language_), un linguaggio proprietario sviluppato da Zucchetti S.p.A. #gl("cpl", capitalize: true) è un linguaggio interpretato tipizzato staticamente, con supporto a classi, moduli e gestione dei file. Viene eseguito tramite un interprete (`cpl.exe`) che supporta sia interpretazione diretta che compilazione #gl("jit", capitalize: true).

Le caratteristiche principali che distinguono #gl("cpl", capitalize: true) dai linguaggi comuni includono la sintassi di assegnazione con `:=`, l'assenza dell'istruzione `return` esplicita (si usa invece la variabile implicita `result`), la dichiarazione obbligatoria di tutte le variabili in cima alla funzione prima di qualsiasi blocco di codice, e la distinzione tra `func` (funzione con valore di ritorno) e `proc` (procedura senza valore di ritorno).

Il codice sorgente di #gl("rvc", capitalize: true) è organizzato in diversi moduli #gl("cpl", capitalize: true), ciascuno con responsabilità ben definite: `ProjectImage.cpl` contiene la logica ad alto livello, `RvcEngine.cpl` gestisce la #gl("repository") fisica, `FileManifest.cpl` gestisce il #gl("manifest") dei file tracciati.

#figure(
  image("../images/struttura_rvc.png", width: 110%),
  caption: "Struttura dei moduli principali di RVC"
)

=== Flusso di un commit

Quando un utente esegue `rvc commit`, il sistema esegue i seguenti passi:

+ Legge il file `.FileManifest` nella directory di lavoro per conoscere lo stato corrente del progetto.
+ Scansiona la directory e calcola le differenze rispetto allo stato precedente.
+ Crea un archivio ZIP con i file modificati e il nuovo `.FileManifest`.
+ Calcola lo SHA256 dell'archivio ZIP.
+ Recupera l'hash e il `cumulativeHash` del #gl("commit") precedente dal suo file `.sig`.
+ Calcola il nuovo `cumulativeHash` come SHA256 della concatenazione dell'hash attuale con il `cumulativeHash` precedente.
+ Crea il file `.sig` con tutti i metadati.
+ Esegue `ssh-keygen -Y sign` per firmare il file `.sig` e accoda la firma al file.
+ Copia i due file nella #gl("repository").
