#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#import "../config/thesis-config.typ": gl, glpl, glossary-style, linkfn
#import "../config/variables.typ" : *

= Introduzione <cap:introduzione>
#text(style: "italic", [
    In questo capitolo viene descritta l'azienda ospitante, introdotto il progetto e illustrate le motivazioni che hanno portato alla scelta di questo stage.
])
#v(1em)

== L'azienda

Zucchetti S.p.A. è un'azienda italiana con sede principale a Lodi che produce soluzioni software, hardware e servizi per aziende, professionisti e associazioni di categoria. Le origini risalgono al 1977, quando lo studio del commercialista Domenico "Mino" Zucchetti realizzò il primo software in Italia per l'elaborazione automatica delle dichiarazioni dei redditi. L'anno successivo, nel 1978, fu fondata formalmente l'azienda.

Oggi il gruppo conta più di 8.000 dipendenti, di cui 2.000 dedicati alla Ricerca e Sviluppo, e serve oltre 700.000 clienti tramite sedi distribuite in tutta Italia e più di 1.650 partner. A livello internazionale è presente con proprie società in diversi paesi europei e oltreoceano, con una rete di oltre 350 partner in 50 paesi. Zucchetti si posiziona oggi come la prima _software house_ in Italia per fatturato.

Lo stage è stato svolto presso la sede di Padova e di Noventa Padovana (PD), sotto la supervisione del tutor aziendale #myTutor.

#figure(
  image("../images/zucchetti-logo.png", width: 100%),
  caption: "Logo di Zucchetti S.p.A."
)

== Il progetto

Il progetto ha riguardato l'analisi della sicurezza di #gl("rvc", capitalize: true), un sistema di versionamento distribuito sviluppato internamente da Zucchetti S.p.A. come alternativa a #gl("git", capitalize: true). A differenza dei sistemi tradizionali, #gl("rvc", capitalize: true) non richiede un server centrale: i _commit_ vengono distribuiti come archivi firmati, navigabili direttamente tramite filesystem. L'integrità dei contenuti è garantita attraverso la verifica crittografica degli #gl("hash") di ogni _commit_, con l'obiettivo di permettere a qualsiasi utente di accertare autonomamente l'autenticità della _repository_ ricevuta, indipendentemente dalla fonte di distribuzione.

L'autenticazione e la firma dei _commit_ avvengono tramite chiavi #gl("ssh", capitalize: true), rendendo ogni modifica crittograficamente attribuibile al suo autore. Questo approccio distingue #gl("rvc", capitalize: true) non solo per l'architettura distribuita, ma anche per le garanzie di autenticità che offre rispetto ai sistemi di versionamento convenzionali.

La versione di #gl("rvc", capitalize: true) fornita per lo stage è una versione di sviluppo deliberatamente priva di alcuni meccanismi di sicurezza, con l'obiettivo di permettere uno studio autonomo delle vulnerabilità e la progettazione di soluzioni originali. Questo approccio ha consentito di affrontare il problema della sicurezza senza vincoli architetturali predefiniti, producendo analisi e implementazioni indipendenti.

== Scelta del progetto

Ho scelto questo progetto per l'interesse verso la sicurezza informatica e la crittografia applicata, temi che avevo già incontrato durante il percorso universitario ma che non avevo mai avuto l'occasione di approfondire in un contesto reale. L'analisi di un sistema in uso aziendale, con l'obiettivo di individuare vulnerabilità concrete e proporre miglioramenti, rappresenta un'opportunità difficilmente replicabile in ambito accademico.

La natura del lavoro — che combina studio teorico delle tecnologie crittografiche, progettazione di modelli di sicurezza e simulazione pratica di scenari di attacco — mi ha convinto che fosse il progetto più adatto per concludere il percorso triennale con un contributo originale e tangibile.

#pagebreak()

== Obiettivi dello stage

Gli obiettivi dello stage sono stati definiti in accordo con il tutor aziendale e classificati secondo tre livelli di priorità:

- *Obbligatori* (O): obiettivi il cui soddisfacimento è vincolante per la riuscita del progetto;
- *Desiderabili* (D): obiettivi non strettamente necessari ma dal riconoscibile valore aggiunto;
- *Facoltativi* (F): obiettivi che rappresentano un ulteriore contributo non competitivo.

#figure(caption: "Obiettivi dello stage.")[
  #table(
    columns: (auto, 1fr),
    align: (center, left),
    table.header([*Codice*], [*Descrizione*]),
    [O01], [Studio delle tecnologie #gl("ssh", capitalize: true), #gl("age", capitalize: true) e #gl("rvc", capitalize: true)],
    [O02], [Analisi del sistema #gl("rvc", capitalize: true): architettura, formato dei commit e individuazione delle vulnerabilità],
    [O03], [Definizione di un modello di sicurezza formale per sistemi di versionamento distribuito, con requisiti classificati per priorità e confronto con lo stato iniziale di #gl("rvc", capitalize: true)],
    [O04], [Valutazione del grado di soddisfacimento del modello di sicurezza proposto a seguito degli interventi migliorativi implementati],
    [O05], [Produzione della documentazione tecnica e della relazione finale],
    [D01], [Progettazione della gerarchia di fiducia e dei livelli di sicurezza configurabili per #gl("repository") distribuite],
    [D02], [Simulazione di scenari di attacco con diversi livelli di accesso e analisi delle vulnerabilità individuate],
    [D03], [Implementazione dei miglioramenti prioritari nel codice sorgente #gl("cpl", capitalize: true) di #gl("rvc", capitalize: true)],
    [F01], [Progettazione del meccanismo di #gl("redazione-trasparente", capitalize: true) per la gestione di contenuto illegale o sensibile nella #gl("repository")],
    [F02], [Analisi delle possibilità di adozione di una struttura monorepo o polirepo in #gl("rvc", capitalize: true)],
  )
]

#pagebreak()

== Pianificazione

Il lavoro è stato organizzato su otto settimane per un totale di 304 ore, suddivise tra studio delle tecnologie, analisi della sicurezza, sviluppo e documentazione.

#figure(caption: "Pianificazione del periodo di stage.")[
  #table(
    columns: (auto, auto, 1fr),
    align: (center, center, left),
    table.header([*Settimana*], [*Ore*], [*Attività*]),
    [1], [32], [Studio di #gl("ssh", capitalize: true), crittografia-asimmetrica, firma-digitale e #gl("age", capitalize: true)],
    [2], [40], [Studio di #gl("rvc", capitalize: true): architettura, formato dei commit],
    [3], [40], [Simulazione scenari di attacco senza credenziali e con chiave compromessa],
    [4], [40], [to do: descrizione attività],
    [5], [40], [to do: descrizione attività],
    [6], [32], [to do: descrizione attività],
    [7], [40], [to do: descrizione attività],
    [8], [40], [Completamento e revisione della relazione finale],
  )
]

#pagebreak()

== Analisi dei rischi

Prima dell'avvio del progetto è stata condotta un'analisi preventiva dei rischi, al fine di individuare le possibili criticità e predisporre le opportune contromisure.

#figure(caption: "Analisi preventiva dei rischi.")[
  #table(
    columns: (1fr, 1fr, auto),
    align: (left, left, center),
    table.header(
      [*Descrizione*], [*Contromisura*], [*Probabilità \ Impatto*]
    ),
    [Codice sorgente di #gl("rvc", capitalize: true) non disponibile nella fase iniziale, con impossibilità di analisi #gl("white-box")],
    [Analisi #gl("black-box") tramite osservazione del comportamento esterno e dei file prodotti],
    [Alta \ Alto],
    [Linguaggio #gl("cpl", capitalize: true) proprietario senza documentazione pubblica, con curva di apprendimento elevata],
    [Studio della documentazione interna fornita dall'azienda e confronto diretto col tutor],
    [Alta \ Medio],
    [Comportamenti silenziosi del sistema in caso di errore, che rendono difficile il debug],
    [Aggiunta sistematica di istruzioni di debug nel codice sorgente durante l'analisi],
    [Media \ Alto],
    [Vulnerabilità individuate già risolte nella versione interna, rendendo il lavoro ridondante],
    [Verifica periodica col tutor aziendale sull'allineamento tra la versione di test e quella interna],
    [Media \ Medio],
  )
]