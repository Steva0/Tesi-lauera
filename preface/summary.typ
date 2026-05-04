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
Lo stage ha riguardato l'analisi della sicurezza di #gl("rvc", capitalize: true), un sistema di versionamento distribuito sviluppato internamente da #myCompany come alternativa a #gl("git", capitalize: true). A differenza dei sistemi tradizionali, #gl("rvc", capitalize: true) non richiede un server centrale per la verifica di autenticità dei #gl("commit"): i #gl("commit") vengono distribuiti come archivi firmati, navigabili direttamente tramite filesystem. L'integrità dei contenuti è garantita attraverso la verifica crittografica degli #gl("hash") di ogni #gl("commit"), con l'obiettivo di permettere a qualsiasi utente di accertare autonomamente l'autenticità della #gl("repository") ricevuta, indipendentemente dalla fonte.
\ \
Il lavoro ha previsto lo studio delle tecnologie crittografiche alla base del sistema — chiavi #gl("ssh", capitalize: true), #gl("firma-digitale") e strumenti di cifratura — seguito dalla simulazione di scenari di attacco con diversi livelli di accesso. Per ciascuno scenario sono state individuate le vulnerabilità presenti, analizzate le possibili conseguenze e proposte contromisure concrete.

#linebreak()
#text(24pt, weight: "semibold")[Organizzazione del testo]
#linebreak()
#v(1em)

/ #link(<cap:introduzione>)[Il primo capitolo]: presenta l'azienda ospitante, introduce il progetto #gl("rvc", capitalize: true) e illustra le motivazioni che mi hanno portato a scegliere questo stage, con gli obiettivi definiti, la pianificazione e l'analisi dei rischi;
/ #link(<cap:descrizione-stage>)[Il secondo capitolo]: descrive l'organizzazione del lavoro durante il tirocinio, l'ambiente di sviluppo, gli strumenti utilizzati e l'approccio metodologico seguito;
/ #link(<cap:tecnologie>)[Il terzo capitolo]: illustra le tecnologie e i concetti teorici alla base del progetto, dalla #gl("crittografia-asimmetrica") e #gl("ssh", capitalize: true) fino all'architettura di #gl("rvc", capitalize: true) e al confronto con #gl("git", capitalize: true);
/ #link(<cap:analisi-dei-requisiti>)[Il quarto capitolo]: espone l'analisi del codice sorgente #gl("cpl", capitalize: true) di #gl("rvc", capitalize: true), descrive le vulnerabilità individuate e presenta il modello di minaccia costruito secondo il framework #gl("mitre-attack", capitalize: true);
/ #link(<cap:simulazione-scenari-di-attacco>)[Il quinto capitolo]: presenta gli scenari di attacco simulati in ambiente controllato, con diversi livelli di accesso — da attaccante esterno fino a compromissione della chiave del capo progetto — e analizza la propagazione degli errori nella catena degli #gl("hash");
/ #link(<cap:miglioramenti-implementati>)[Il sesto capitolo]: descrive i miglioramenti implementati nel codice sorgente di #gl("rvc", capitalize: true), tra cui il sistema di configurazione dinamico, la firma #gl("ssh", capitalize: true) integrata, la verifica dell'integrità della catena e la gestione degli _allowed signers_;
/ #link(<cap:conclusioni>)[Il settimo capitolo]: riassume i risultati raggiunti, valuta il grado di soddisfacimento degli obiettivi prefissati e propone una riflessione personale sull'esperienza e sugli sviluppi futuri.

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
  if fm.merge <> nil
    ? '  merge:', fm.merge
  end
end
```
]