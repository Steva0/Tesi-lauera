#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#import "../config/thesis-config.typ": gl, glpl, glossary-style, linkfn
#import "../config/variables.typ": *
#pagebreak(to:"odd")

= Tecnologie e fondamenti teorici <cap:tecnologie>
#text(style: "italic", [
    In questo capitolo illustro le tecnologie e i concetti teorici alla base del progetto. Partendo dalla crittografia asimmetrica, descrivo SSH, AGE e i sistemi di controllo versione, fino ad arrivare all'architettura di RVC.
])
#v(1em)

== Crittografia asimmetrica e firma digitale

La crittografia è la disciplina che studia le tecniche per proteggere le informazioni rendendole illeggibili a chi non è autorizzato. Nella sua forma classica, detta _crittografia simmetrica_, mittente e destinatario condividono una stessa chiave segreta per cifrare e decifrare i messaggi. Questo approccio presenta un problema fondamentale: come si trasmette la chiave in modo sicuro prima ancora di poter comunicare in modo sicuro?

La risposta a questo problema arrivò negli anni '70 con la _crittografia asimmetrica_, detta anche _crittografia a chiave pubblica_. L'idea è elegante: ogni utente genera una coppia di chiavi matematicamente collegate tra loro. La *chiave pubblica* può essere distribuita liberamente a chiunque. La *#gl("chiave-privata")* deve rimanere segreta e non lasciare mai il dispositivo del proprietario. Le due chiavi sono collegate da una relazione matematica tale per cui ciò che viene cifrato con una può essere decifrato solo con l'altra, ma è computazionalmente impossibile ricavare la chiave privata a partire da quella pubblica.

Questo meccanismo permette due operazioni fondamentali:

- *Cifratura*: chiunque può cifrare un messaggio usando la chiave pubblica del destinatario. Solo il destinatario, possedendo la chiave privata corrispondente, potrà decifrarlo.
- *Firma digitale*: il mittente cifra un messaggio con la propria chiave privata. Chiunque, usando la chiave pubblica del mittente, può verificare che il messaggio provenga effettivamente da lui e non sia stato alterato.

// [IMMAGINE SUGGERITA: schema che mostra cifratura e firma digitale con chiave pubblica/privata]

=== La firma digitale in dettaglio

La #gl("firma-digitale") non cifra il messaggio intero — sarebbe inefficiente. Funziona invece in questo modo:

+ Il mittente calcola l'_#gl("hash")_ del messaggio, ovvero una sua impronta digitale di dimensione fissa prodotta da una funzione matematica non invertibile.
+ Il mittente cifra quell'hash con la propria chiave privata. Il risultato è la firma digitale.
+ Il destinatario riceve messaggio e firma. Decifra la firma usando la chiave pubblica del mittente, ottenendo l'hash originale.
+ Il destinatario calcola autonomamente l'hash del messaggio ricevuto e confronta i due valori. Se coincidono, la firma è valida: il messaggio proviene dal mittente dichiarato e non è stato modificato.

La sicurezza di questo meccanismo si basa su due proprietà: la resistenza alle collisioni delle funzioni di hash (è praticamente impossibile trovare due messaggi diversi con lo stesso hash) e l'impossibilità computazionale di produrre una firma valida senza possedere la chiave privata.

=== Curve ellittiche: Ed25519

Gli algoritmi crittografici moderni si basano su problemi matematici computazionalmente difficili. RSA, il primo algoritmo a chiave pubblica diffuso, si basa sulla difficoltà di fattorizzare numeri molto grandi. Gli algoritmi moderni basati su _curve ellittiche_ offrono lo stesso livello di sicurezza con chiavi molto più corte, risultando più veloci ed efficienti.

*Ed25519* è un algoritmo di firma digitale basato sulla curva ellittica Curve25519. Produce chiavi di 256 bit e firme di 512 bit, con un livello di sicurezza equivalente a RSA con chiavi da 3000 bit. È l'algoritmo raccomandato oggi per la firma SSH ed è quello utilizzato in questo progetto.

// [IMMAGINE SUGGERITA: confronto visivo tra dimensioni chiavi RSA e Ed25519 per equivalente sicurezza]

== SSH e ssh-keygen

#gl("ssh") è un protocollo di rete che permette di stabilire connessioni sicure tra due macchine attraverso una rete non sicura. Nato come sostituto sicuro di Telnet e rsh, SSH cifra tutto il traffico e autentica sia il server che il client, impedendo attacchi di tipo _man-in-the-middle_.

=== Autenticazione con chiavi

SSH supporta due modalità principali di autenticazione: tramite password e tramite coppia di chiavi. L'autenticazione con chiavi è considerata più sicura e viene raccomandata in tutti i contesti professionali. Il funzionamento è il seguente:

+ L'utente genera una coppia di chiavi con `ssh-keygen`.
+ La chiave pubblica viene copiata sul server remoto, nella cartella `~/.ssh/authorized_keys`.
+ Al momento della connessione, il server invia una sfida cifrata con la chiave pubblica dell'utente.
+ Il client dimostra di possedere la chiave privata corrispondente risolvendo la sfida.
+ La connessione viene stabilita senza che la chiave privata abbia mai lasciato il client.

=== ssh-keygen per la firma di file

Oltre alla gestione delle chiavi SSH, `ssh-keygen` offre una funzionalità meno nota ma molto utile: la firma e verifica di file arbitrari. Questo è il meccanismo che RVC utilizza per firmare crittograficamente i _commit_.

Il comando per firmare un file è:

```bash
ssh-keygen -Y sign -n <namespace> -f <chiave_privata> <file>
```

Il parametro `-n` specifica il _namespace_, una stringa che identifica il contesto d'uso della firma e previene attacchi di riutilizzo — una firma prodotta con namespace `git` non può essere spacciata per una firma con namespace `file`.

Il comando per verificare una firma è:

```bash
ssh-keygen -Y verify -n <namespace> -f <allowed_signers> -I <identità> -s <firma> < <file>
```

Il file `allowed_signers` è un elenco di identità autorizzate con le rispettive chiavi pubbliche, nel formato:

```
identita@esempio.com ssh-ed25519 AAAA...chiave...
```

Se la firma è valida e l'identità è presente nel file, il comando restituisce `Good "file" signature for <identità>`.

// [IMMAGINE SUGGERITA: schema del flusso firma-verifica con ssh-keygen]

=== PuTTY

Durante lo stage ho utilizzato *PuTTY*, un client SSH open source per Windows, per stabilire connessioni sicure con le macchine di test. PuTTY include anche `puttygen` per la generazione e conversione di chiavi, e `pageant` come agente SSH per gestire le chiavi senza dover reinserire la passphrase ad ogni utilizzo.

== AGE

*AGE* (_Actually Good Encryption_) è uno strumento moderno per la cifratura di file, progettato con l'obiettivo di essere semplice, sicuro e componibile. A differenza di PGP, che nel corso degli anni ha accumulato una complessità notevole, AGE offre un'interfaccia minimale con poche opzioni ben definite.

AGE supporta tre modalità di cifratura:

- *Chiave pubblica*: il file viene cifrato con la chiave pubblica del destinatario e può essere decifrato solo con la corrispondente chiave privata.
- *Chiave SSH*: AGE può utilizzare le stesse chiavi SSH già esistenti (incluse le chiavi Ed25519) come chiavi di cifratura, senza bisogno di generare nuove chiavi dedicate.
- *Passphrase*: il file viene cifrato con una passphrase, usando la funzione di derivazione `scrypt` per proteggersi da attacchi a dizionario.

Un file cifrato con AGE contiene nell'intestazione le informazioni necessarie per la decifratura (il tipo di chiave usata e la chiave di sessione cifrata), seguite dal contenuto cifrato con ChaCha20-Poly1305, un algoritmo moderno che garantisce sia riservatezza che integrità.

Nel contesto di questo progetto, AGE è stato studiato come tecnologia di riferimento per la fase successiva del lavoro, che prevede la progettazione di _repository_ cifrate con distribuzione dei permessi di accesso. In questa fase AGE permette di cifrare il contenuto di una _repository_ in modo che solo gli utenti autorizzati — identificati dalle loro chiavi pubbliche — possano decifrarla, senza dover condividere nessuna chiave segreta.

// [IMMAGINE SUGGERITA: schema anatomia file .age con header e corpo cifrato]

== Sistemi di controllo versione

=== Storia e evoluzione

I sistemi di controllo versione (_Version Control System_, VCS) nascono dalla necessità pratica di tenere traccia delle modifiche al codice sorgente nel tempo. Prima della loro diffusione, era comune affidare il versionamento a convenzioni manuali: copie di file con date nel nome, cartelle numerate, archivi compressi. Questo approccio era fragile, difficile da gestire in team e privo di qualsiasi garanzia di integrità.

Il primo sistema formale di controllo versione ampiamente adottato fu *SCCS* (_Source Code Control System_), sviluppato da Bell Labs nel 1972. SCCS introduceva il concetto di _delta_: invece di salvare ogni versione completa del file, memorizzava solo le differenze rispetto alla versione precedente, riducendo significativamente lo spazio occupato.

*RCS* (_Revision Control System_), sviluppato nel 1982, migliorò SCCS rendendolo più accessibile e introducendo il concetto di _branching_, ossia la possibilità di sviluppare linee di codice parallele a partire da un punto comune.

Entrambi questi sistemi operavano però a livello di singolo file e su singola macchina. Il passo successivo fu l'introduzione dei sistemi _centralizzati_.

==== Sistemi centralizzati

*CVS* (_Concurrent Versions System_), negli anni '90, portò il controllo versione in rete. Per la prima volta più sviluppatori potevano lavorare contemporaneamente sullo stesso progetto, con un server centrale che coordinava le modifiche. Il modello era semplice: il server custodisce l'intera storia del progetto; i client effettuano _checkout_ (scaricano una versione) e _commit_ (inviano le modifiche).

*Subversion* (SVN), rilasciato nel 2000, nacque esplicitamente come sostituto migliorato di CVS, correggendo molte delle sue limitazioni tecniche. SVN trattava l'intera struttura del progetto come un'unità atomica: un commit poteva riguardare più file contemporaneamente, con la garanzia che o tutte le modifiche venivano salvate o nessuna.

Il limite fondamentale dei sistemi centralizzati era però strutturale: la presenza di un singolo punto di fallimento. Se il server non era raggiungibile, nessuno poteva fare commit. Se il server veniva perso, si perdeva l'intera storia del progetto.

// [IMMAGINE SUGGERITA: schema architettura centralizzata vs distribuita]

==== Sistemi distribuiti

*Git*, sviluppato da Linus Torvalds nel 2005 per gestire lo sviluppo del kernel Linux, rivoluzionò il campo introducendo un modello completamente distribuito. In Git non esiste un server centrale: ogni sviluppatore possiede una copia completa dell'intera storia del progetto. I commit avvengono localmente e possono essere sincronizzati con altri repository in un secondo momento.

Questa architettura offre vantaggi significativi: si può lavorare offline, la storia del progetto è replicata su ogni macchina riducendo il rischio di perdita dei dati, e il _branching_ è diventato un'operazione economica e centrale nel flusso di lavoro.

*Mercurial*, rilasciato nello stesso anno di Git, adottò un approccio simile ma con un'interfaccia considerata più accessibile. Oggi Git domina il mercato, ma l'ecosistema dei VCS distribuiti rimane vivo con strumenti come Fossil e Pijul.

=== Git in dettaglio

In Git ogni oggetto — _blob_ (contenuto di un file), _tree_ (struttura di una directory), _commit_, _tag_ — è identificato da un hash SHA del suo contenuto. Questo significa che l'identità di ogni oggetto è determinata dal suo contenuto: due oggetti con lo stesso contenuto hanno lo stesso hash, e qualsiasi modifica produce un hash diverso.

Un _commit_ Git contiene: il riferimento all'albero dei file in quello stato, il riferimento al commit precedente (_parent_), i metadati dell'autore e del committer, il messaggio di commit. Questa struttura crea una catena crittograficamente collegata: modificare un commit invalida tutti i commit successivi, poiché i loro hash dipendono dal hash del precedente.

Git supporta la firma crittografica dei commit tramite GPG o SSH. Tuttavia questa funzionalità è opzionale e deve essere abilitata esplicitamente — non fa parte del flusso di lavoro standard.

=== RVC a confronto con Git

RVC (_Repositoryless Version Control_) condivide con Git il modello distribuito ma si differenzia in aspetti fondamentali di architettura e sicurezza.

#figure(caption: "Confronto tra Git e RVC.")[
  #table(
    columns: (1fr, 1fr, 1fr),
    align: (left, left, left),
    table.header([*Caratteristica*], [*Git*], [*RVC*]),
    [Struttura], [_Repository_ con oggetti indicizzati], [File ZIP navigabili su filesystem],
    [Identificazione commit], [Hash SHA dell'oggetto commit], [Timestamp codificato in base36],
    [Firma commit], [Opzionale (GPG o SSH)], [Integrata nell'architettura],
    [Server centrale], [Non richiesto ma comune], [Non richiesto per design],
    [Repository multiple], [Un remote alla volta tipicamente], [Più repository sincronizzate nativamente],
    [Linguaggio], [C], [CPL (proprietario Zucchetti)],
  )
]

La differenza più significativa riguarda la sicurezza: mentre in Git la firma è un'opzione che il singolo sviluppatore può scegliere di abilitare o meno, in RVC è parte del modello stesso. Ogni _commit_ produce un file `.sig` che contiene gli hash crittografici del contenuto e della catena precedente, costruendo una struttura analoga a una _blockchain_: modificare un commit invalida tutti quelli successivi perché l'hash cumulativo non corrisponde più.

== RVC: architettura e funzionamento

=== Struttura della repository

Una _repository_ RVC è una semplice cartella sul filesystem, senza strutture dati complesse o indici da mantenere. Ogni _commit_ è rappresentato da due file:

- Un archivio *ZIP* contenente il _#gl("commit")_ del progetto nella versione corrispondente, incluso il file `.FileManifest` che descrive lo stato di tutti i file tracciati.
- Un file *.sig* contenente i metadati del commit e, opzionalmente, la firma SSH.

I file seguono una convenzione di denominazione che codifica la struttura della storia:

```
<progetto>.<id>.<idPrecedente>.{autore}+tag.zip
<progetto>.<id>.sig
```

L'`id` è un timestamp codificato in base36 (cifre 0-9 e lettere A-Z), che permette l'ordinamento cronologico dei commit semplicemente confrontando i nomi dei file. Il riferimento al commit precedente è incorporato nel nome del file ZIP, rendendo la struttura della storia navigabile senza alcun indice aggiuntivo.

// [IMMAGINE SUGGERITA: schema della struttura dei file nella repository con esempio di nomi]

=== Il file .sig e la blockchain degli hash

Il file `.sig` è il cuore del sistema di sicurezza di RVC. Contiene in formato binario proprietario i seguenti campi:

- `author`: il nome dell'autore del commit
- `comment`: il messaggio del commit
- `fn`: il nome del file ZIP corrispondente
- `id`: l'identificativo del commit
- `prevId`: l'identificativo del commit precedente
- `hash`: lo SHA256 del file ZIP di questo commit
- `prevHash`: lo SHA256 del file ZIP del commit precedente
- `cumulativeHash`: lo SHA256 della concatenazione dell'hash attuale con il `cumulativeHash` del commit precedente

Il `cumulativeHash` è la chiave della sicurezza: ogni commit incorpora crittograficamente l'intera storia precedente. Verificare che il `cumulativeHash` di un commit sia corretto significa verificare implicitamente che tutti i commit precedenti siano integri.

// [IMMAGINE SUGGERITA: schema della catena di hash tra commit successivi]

Dopo i metadati, il file `.sig` può contenere una firma SSH nel formato standard:

```
-----BEGIN SSH SIGNATURE-----
...
-----END SSH SIGNATURE-----
```

Questa firma attesta che l'autore dichiarato ha effettivamente prodotto il commit, rendendo ogni modifica crittograficamente attribuibile.

=== Il linguaggio CPL

RVC è scritto in *CPL* (_Custom Programming Language_), un linguaggio proprietario sviluppato da Zucchetti S.p.A. CPL è un linguaggio interpretato con sintassi simile al Pascal, tipizzato staticamente, con supporto a classi, moduli e gestione dei file. Viene eseguito tramite un interprete (`cpl.exe`) che supporta sia interpretazione diretta che compilazione JIT.

Le caratteristiche principali che distinguono CPL dai linguaggi comuni includono la sintassi di assegnazione con `:=`, l'assenza dell'istruzione `return` esplicita (si usa invece la variabile implicita `result`), la dichiarazione obbligatoria di tutte le variabili in cima alla funzione prima di qualsiasi blocco di codice, e la distinzione tra `func` (funzione con valore di ritorno) e `proc` (procedura senza valore di ritorno).

Il codice sorgente di RVC è organizzato in diversi moduli CPL, ciascuno con responsabilità ben definite: `ProjectImage.cpl` contiene la logica ad alto livello, `RvcEngine.cpl` gestisce la repository fisica, `FileManifest.cpl` gestisce il manifest dei file tracciati.

// [IMMAGINE SUGGERITA: schema dell'architettura a moduli di RVC con frecce di dipendenza]

=== Flusso di un commit

Quando un utente esegue `rvc commit`, il sistema esegue i seguenti passi:

+ Legge il file `.FileManifest` nella directory di lavoro per conoscere lo stato corrente del progetto.
+ Scansiona la directory e calcola le differenze rispetto allo stato precedente.
+ Crea un archivio ZIP con i file modificati e il nuovo `.FileManifest`.
+ Calcola lo SHA256 dell'archivio ZIP.
+ Recupera l'hash e il `cumulativeHash` del commit precedente dal suo file `.sig`.
+ Calcola il nuovo `cumulativeHash` come SHA256 della concatenazione dell'hash attuale con il `cumulativeHash` precedente.
+ Crea il file `.sig` con tutti i metadati.
+ Se la firma SSH è configurata, esegue `ssh-keygen -Y sign` per firmare il file `.sig` e accoda la firma al file.
+ Copia i due file nella repository.

// [IMMAGINE SUGGERITA: diagramma di flusso del processo di commit]
