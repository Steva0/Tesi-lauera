#import "../config/constants.typ": abstract
#import "../config/variables.typ": *
#import "../config/thesis-config.typ": glossary-style, gl
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#pagebreak(to: "odd")
#v(4em)

#text(24pt, weight: "semibold", abstract)

#v(1em)
Questa relazione descrive il lavoro svolto durante lo stage curricolare presso #text(myCompany), della durata di trecentoquattro ore, sotto la supervisione del tutor aziendale #myTutor e del tutor accademico #text(myProf).
\ \
Lo stage ha riguardato l'analisi della sicurezza di #gl("rvc", capitalize: true), un sistema di versionamento distribuito sviluppato internamente da #myCompany come alternativa a #gl("git", capitalize: true). A differenza dei sistemi tradizionali, #gl("rvc", capitalize: true) non richiede un server centrale per la verifica di autenticità dei commit: i commit vengono distribuiti come archivi firmati, navigabili direttamente tramite filesystem. L'integrità dei contenuti è garantita attraverso la verifica crittografica degli #gl("hash") di ogni commit, con l'obiettivo di permettere a qualsiasi utente di accertare autonomamente l'autenticità della #gl("repository") ricevuta, indipendentemente dalla fonte.
\ \
Il lavoro ha previsto lo studio delle tecnologie crittografiche alla base del sistema — chiavi #gl("ssh", capitalize: true) #gl("ed25519"), firma-digitale e cifratura asimmetrica con #gl("age") — seguito dalla definizione di un modello di sicurezza formale composto da quattordici requisiti classificati per priorità e tipologia. Il modello introduce una gerarchia di fiducia a tre livelli (amministratore, responsabile di progetto, dipendente), un progetto speciale `_rvc_root` come radice di fiducia verificabile autonomamente tramite chiave master, e cinque livelli di sicurezza configurabili per progetto — dall'accesso anonimo senza firma (livello 0) alla cifratura dei contenuti tramite #gl("age") (livello 4). Ogni commit è vincolato a una catena crittografica basata su un `cumulativeHash` progressivo che incorpora l'intera storia precedente, permettendo la verifica dell'ordine dei commit indipendentemente da qualsiasi server centrale.
\ \
Il lavoro include la simulazione di quattro scenari di attacco con livelli crescenti di accesso dell'attaccante — dall'esterno senza credenziali fino alla compromissione della chiave dell'amministratore — e la successiva implementazione dei miglioramenti nel codice sorgente in linguaggio #gl("cpl"). Tra le funzionalità realizzate figurano il verificatore di integrità della catena crittografica, il controllo preventivo delle autorizzazioni per progetto tramite file `allowed_Dipendenti` versionato, la protezione dei file speciali di configurazione e il meccanismo di redazione trasparente per la rimozione forense di contenuti dalla storia. Gli stessi scenari di attacco vengono quindi ripetuti sulla versione aggiornata del sistema per documentare l'efficacia dei controlli introdotti.
\ \

#linebreak()
#text(24pt, weight: "semibold")[Organizzazione del testo]
#linebreak()
#v(1em)

/ #link(<cap:introduzione>)[Il primo capitolo]: presenta l'azienda ospitante, introduce il progetto #gl("rvc", capitalize: true) e illustra le motivazioni che mi hanno portato a scegliere questo stage, con gli obiettivi definiti, la pianificazione e l'analisi dei rischi;
/ #link(<cap:descrizione-stage>)[Il secondo capitolo]: descrive l'organizzazione del lavoro durante il tirocinio, l'ambiente di sviluppo, gli strumenti utilizzati e l'approccio metodologico seguito;
/ #link(<cap:tecnologie>)[Il terzo capitolo]: illustra le tecnologie e i concetti teorici alla base del progetto, dalla crittografia-asimmetrica e #gl("ssh", capitalize: true) fino all'architettura di #gl("rvc", capitalize: true) e al confronto con #gl("git", capitalize: true);
/ #link(<cap:modello-sicurezza>)[Il quarto capitolo]: definisce il modello di sicurezza che un sistema di versionamento distribuito moderno dovrebbe soddisfare analizzando i requisiti formali, gerarchia di fiducia, livelli di sicurezza configurabili e meccanismo di Redazione Trasparente — concludendo con l'analisi del divario rispetto alla versione iniziale iniziale di #gl("rvc", capitalize: true);
/ #link(<cap:simulazione-scenari-di-attacco>)[Il quinto capitolo]: documenta gli scenari di attacco simulati in ambiente controllato, con livelli di accesso crescenti, distinguendo le vulnerabilità rilevabili solo tramite verifica esplicita da quelle bloccate preventivamente dal motore;
/ #link(<cap:miglioramenti-implementati>)[Il sesto capitolo]: descrive i miglioramenti implementati nel codice sorgente di #gl("rvc", capitalize: true), tra cui il sistema di configurazione dinamico, la firma #gl("ssh", capitalize: true) integrata, la verifica dell'integrità della catena e i meccanismi di controllo delle identità autorizzate;
/ #link(<cap:simulazione-scenari-post>)[Il settimo capitolo]: ripete i quattro scenari di attacco del quinto capitolo sulla versione aggiornata di #gl("rvc", capitalize: true), documentando per ogni tecnica il comportamento dei nuovi controlli preventivi — firma obbligatoria, verifica dell'autorizzazione per progetto, protezione dei file speciali — e confrontando i risultati con quelli della versione iniziale per valutare l'efficacia dei miglioramenti;
/ #link(<cap:conclusioni>)[L'ottavo capitolo]: riassume i risultati raggiunti, valuta il grado di soddisfacimento degli obiettivi prefissati e propone una riflessione personale sull'esperienza e sugli sviluppi futuri.

#linebreak()
#text(24pt, weight: "semibold", "Convenzioni tipografiche")
#linebreak()
#v(1em)
Durante la stesura del testo sono state adottate le seguenti convenzioni tipografiche:

- Gli acronimi, le abbreviazioni e i termini di uso non comune vengono definiti nel #link(<glossary>)[glossario], situato alla fine del documento (#link(<glossary>)[p. #context counter(page).at(<glossary>).at(0)]);
- I termini presenti nel glossario sono indicati con la notazione: #gl("rvc", capitalize: true)\;
- I termini in lingua straniera non di uso comune o appartenenti al gergo tecnico sono evidenziati in _corsivo_;
- I nomi di funzioni, variabili o comandi sono scritti con carattere `monospaziato`;
- I riferimenti bibliografici sono indicati con il numero identificativo della fonte, es. $[1]$;
- I blocchi di codice sorgente sono rappresentati nel seguente modo:
#linebreak()
#figure(caption: "Esempio di funzione CPL estratta dal sorgente di " + gl("rvc") + ".")[
```cpl
proc ReportInfo(FileManifestPersistent fm, bool files:=false)
  if fm.tag <> nil
    ? '    tag:', fm.tag
  end
  if fm.prev <> nil
    ? '   prev:', fm.prev
  end
end
```
]