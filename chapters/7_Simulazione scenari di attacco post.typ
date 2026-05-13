#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#import "../config/thesis-config.typ": gl, glpl, glossary-style, linkfn, terminal, terminal-io
#import "../config/variables.typ": *
#pagebreak(to:"odd")

= Simulazione scenari di attacco post-implementazione <cap:simulazione-scenari-post>
#text(style: "italic", [
    In questo capitolo vengono ripetuti gli scenari di attacco del
    @cap:simulazione-scenari-di-attacco sulla versione aggiornata di
    #gl("rvc", capitalize: true), dopo l'implementazione dei miglioramenti
    descritti nel @cap:miglioramenti-implementati.
    Per ciascuno scenario vengono documentati i comandi eseguiti, l'output
    del motore e del verificatore, e il confronto con i risultati della versione
    iniziale, evidenziando quali tecniche sono ora bloccate preventivamente e
    quali rimangono parzialmente o interamente efficaci.
])
#v(1em)
