#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#import "../config/thesis-config.typ": gl, glpl, glossary-style, linkfn
#import "../config/variables.typ": *
#pagebreak(to:"odd")

= Descrizione dello stage <cap:descrizione-stage>
#text(style: "italic", [
    In questo capitolo viene descritta l'organizzazione del lavoro durante il tirocinio, l'ambiente di sviluppo utilizzato, gli strumenti adottati e l'approccio metodologico seguito.
])
#v(1em)

== Organizzazione del lavoro

Lo stage si è svolto in presenza presso le sedi di Zucchetti S.p.A., con rare eccezioni in modalità _smart working_ nei periodi in cui l'azienda era impegnata in un trasferimento di sede. La prima settimana si è tenuta presso gli uffici di via Giovanni Cittadella a Padova; le settimane successive presso la sede principale di Noventa Padovana (PD), dove ho trascorso la maggior parte del tirocinio.

L'orario di lavoro era strutturato su due fasce giornaliere: dalle 9:00 alle 13:00 e dalle 14:00 alle 18:00, per un totale di otto ore al giorno. Questa organizzazione ha permesso di alternare sessioni di studio teorico al mattino con attività pratiche nel pomeriggio, sfruttando la pausa di mezzogiorno per consolidare i concetti appresi.

=== Rapporto con i tutor

Il confronto con i tutor ha avuto modalità diverse a seconda del ruolo.

Il *tutor aziendale*, #myTutor, era disponibile quasi quotidianamente per chiarimenti, revisioni del lavoro svolto e indicazioni sui passi successivi. Le riunioni non seguivano una cadenza fissa ma avvenivano su richiesta, ogni volta che si presentava un problema tecnico rilevante o si raggiungeva un risultato degno di discussione. Questo approccio ha favorito un dialogo continuo e ha permesso di adattare il percorso in modo flessibile all'avanzamento del lavoro.

Il *tutor accademico*, il Professor #myProf, è stato invece coinvolto con cadenza settimanale tramite scambio di email. Le comunicazioni riguardavano principalmente l'avanzamento dello stage rispetto alle attese previste e la verifica dell'allineamento con gli obiettivi didattici dello stage.

== Ambiente di sviluppo

Per tutta la durata dello stage ho utilizzato un portatile fornito dall'azienda con sistema operativo Windows. La scelta degli strumenti da installare è stata lasciata alla mia discrezione, senza vincoli imposti dall'azienda, il che ha permesso di configurare un ambiente di lavoro ottimale per le esigenze del progetto.

L'accesso ai sistemi aziendali includeva anche i modelli linguistici (_LLM_) disponibili localmente nell'infrastruttura di Zucchetti, utilizzati come supporto durante le fasi di studio e sviluppo.

=== Strumenti utilizzati

Gli strumenti principali adottati durante lo stage sono stati:

*Visual Studio Code* come editor di testo principale, utilizzato sia per la scrittura e modifica del codice sorgente #gl("cpl", capitalize: true) di #gl("rvc", capitalize: true), sia per la stesura della documentazione in Typst. L'editor è stato configurato con estensioni per la sintassi #gl("cpl", capitalize: true) e per la compilazione live dei documenti Typst.

*GitHub* per il versionamento della tesi e dei file di lavoro personali. Il #gl("repository") della relazione finale è ospitato su GitHub con pubblicazione automatica del PDF tramite _GitHub Actions_ e _GitHub Pages_.

*Typst* come sistema di composizione tipografica per la stesura della relazione finale. Typst è un'alternativa moderna a LaTeX che permette di produrre documenti PDF di qualità professionale con una sintassi più accessibile.

*Terminale Windows* (cmd e PowerShell) per l'esecuzione dei comandi #gl("rvc", capitalize: true), la gestione dei file e le operazioni di debug. La maggior parte delle operazioni con #gl("rvc", capitalize: true) avviene tramite interfaccia a riga di comando.

*PuTTY* come client #gl("ssh", capitalize: true) per Windows, utilizzato per la gestione delle chiavi #gl("ssh", capitalize: true) tramite il componente `puttygen`.

*ssh-keygen* (OpenSSH per Windows) per la generazione delle chiavi #gl("ed25519", capitalize: true), la firma crittografica dei file e la verifica delle firme #gl("ssh", capitalize: true). Questo strumento è centrale nel meccanismo di sicurezza implementato in #gl("rvc", capitalize: true).

*#gl("age", capitalize: true)* come strumento di cifratura moderno, studiato durante lo stage in preparazione alla fase di progettazione delle _repository_ cifrate prevista negli obiettivi desiderabili.

== Approccio metodologico

Il percorso di lavoro ha seguito un andamento alternato tra fasi teoriche e fasi pratiche, con transizioni determinate dall'avanzamento della comprensione del sistema e dalla disponibilità del materiale.

Nella *fase iniziale* l'attenzione era rivolta allo studio delle tecnologie crittografiche — chiavi #gl("ssh", capitalize: true), #gl("firma-digitale"), #gl("age", capitalize: true) — attraverso documentazione ufficiale, esempi pratici al terminale e confronto con il tutor aziendale. Parallelamente ho iniziato a esplorare #gl("rvc", capitalize: true) dall'esterno, analizzandone il comportamento tramite i comandi disponibili e studiando il formato dei file prodotti.

Una volta ottenuto accesso ai *sorgenti #gl("cpl", capitalize: true)*, l'approccio è cambiato: dall'analisi esterna (_black-box_) si è passati all'analisi interna (_white-box_), con lettura sistematica del codice, identificazione delle vulnerabilità e progettazione degli interventi migliorativi. Questa fase ha richiesto anche lo studio del linguaggio #gl("cpl", capitalize: true), per il quale non esiste documentazione pubblica — la comprensione è avvenuta tramite lettura del codice esistente e consultazione della documentazione interna fornita dall'azienda.

La *fase di implementazione* ha proceduto in parallelo con l'analisi: man mano che venivano individuate vulnerabilità o carenze, venivano progettate e implementate le relative soluzioni, testandole su una _repository_ di simulazione appositamente creata.

=== Ambiente di simulazione

Per riprodurre scenari di attacco in modo controllato e reversibile, ho configurato un ambiente di test dedicato composto da:

- Una *directory di lavoro* (`simulazione/`) contenente i file di un progetto fittizio su cui eseguire le operazioni #gl("rvc", capitalize: true).
- Una *#gl("repository") locale* (`repo/`) dove vengono archiviati i _commit_, separata dalla directory di lavoro.
- Un file `.git/repository.info` che collega la directory di lavoro alla #gl("repository"), seguendo la convenzione di #gl("rvc", capitalize: true).
- Un file `allowed_signers` contenente le chiavi pubbliche degli autori autorizzati a firmare i _commit_, utilizzato per i test di verifica dell'integrità.

Questo ambiente ha permesso di simulare scenari realistici — inclusi la manomissione dei file di _commit_, la compromissione delle chiavi #gl("ssh", capitalize: true) e la verifica della propagazione degli errori nella catena degli #gl("hash") — senza rischiare di danneggiare dati reali.
