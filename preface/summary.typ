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
Lo stage ha riguardato l'analisi della sicurezza di #gl("rvc"), un sistema di versionamento distribuito sviluppato internamente da #myCompany come alternativa a #gl("git"). A differenza dei sistemi tradizionali, RVC non richiede un server centrale: i #gl("commit") vengono distribuiti come archivi firmati, navigabili direttamente tramite filesystem. L'integrità dei contenuti è garantita attraverso la verifica crittografica degli #gl("hash") di ogni commit, con l'obiettivo di permettere a qualsiasi utente di accertare autonomamente l'autenticità della repository ricevuta, indipendentemente dalla fonte.
\ \
Il lavoro ha previsto lo studio delle tecnologie crittografiche alla base del sistema — chiavi #gl("ssh"), #gl("firma-digitale") e strumenti di cifratura — seguito dalla simulazione di scenari di attacco con diversi livelli di accesso. Per ciascuno scenario sono state individuate le vulnerabilità presenti, analizzate le possibili conseguenze e proposte contromisure concrete.

#linebreak()
#text(24pt, weight: "semibold")[Organizzazione del testo]
#linebreak()
#v(1em)

/ #link(<cap:introduzione>)[Il primo capitolo]: presenta l'azienda ospitante, introduce il progetto RVC e illustra le motivazioni che mi hanno portato a scegliere questo stage;
/ #link(<cap:descrizione-stage>)[Il secondo capitolo]: descrive l'organizzazione del lavoro, le competenze richieste, i vincoli tecnologici e l'analisi dei rischi affrontati durante il tirocinio;
/ #link(<cap:analisi-sicurezza>)[Il terzo capitolo]: espone le analisi di sicurezza condotte sul sistema, descrivendo gli scenari di attacco simulati, le vulnerabilità individuate e le contromisure proposte;
/ #link(<cap:conclusioni>)[Il quarto capitolo]: riassume i risultati raggiunti, valuta il grado di soddisfacimento degli obiettivi prefissati e propone una riflessione personale sull'esperienza.

#linebreak()
#text(24pt, weight: "semibold", "Convenzioni tipografiche")
#linebreak()
#v(1em)
Durante la stesura del testo sono state adottate le seguenti convenzioni tipografiche:

- Gli acronimi, le abbreviazioni e i termini di uso non comune vengono definiti nel #link(<glossary>)[glossario], situato alla fine del documento (#link(<glossary>)[p. #context counter(page).at(<glossary>).at(0)]);
- Alla prima occorrenza, i termini presenti nel glossario sono indicati con la notazione: #glossary-style[termine]\;
- I termini in lingua straniera non di uso comune o appartenenti al gergo tecnico sono evidenziati in _corsivo_;
- I nomi di funzioni, variabili o comandi sono scritti con carattere `monospaziato`;
- I riferimenti bibliografici sono indicati con il numero identificativo della fonte, es. $[1]$;
- I blocchi di codice sorgente sono rappresentati nel seguente modo:
#linebreak()
#figure(caption: "Esempio di funzione CPL estratta dal sorgente di " + gl("rvc") + ".")[
```cpl
proc ReportInfo(FileManifestPersistent fm, bool files:=false)
  ? 'project:', fm.project
  ? 'version:', fm.ver
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