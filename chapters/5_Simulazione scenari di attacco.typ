#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#import "../config/thesis-config.typ": gl, glpl, glossary-style, linkfn, terminal, terminal-io
#import "../config/variables.typ": *
#pagebreak(to:"odd")
= Simulazione scenari di attacco <cap:simulazione-scenari-di-attacco>
#text(style: "italic", [
    In questo capitolo vengono documentati gli scenari di attacco simulati
    in ambiente controllato sulla versione iniziale di #gl("rvc", capitalize: true).
    Per ciascuno scenario viene descritto il contesto dell'attaccante, le tecniche
    impiegate e i risultati osservati, distinguendo ciò che il motore rileva
    preventivamente da ciò che emerge solo tramite verifica esplicita. Il capitolo
    si conclude con una sintesi trasversale che mette in relazione i risultati
    osservati con i requisiti definiti nel @cap:modello-sicurezza.
])
#v(1em)

== Ambiente di simulazione e metodo

I test sono stati condotti su una #gl("repository") locale composta da cinque commit legittimi firmati con chiave #gl("ssh", capitalize: true), ripristinata allo stato iniziale prima di ogni tecnica tramite una copia di backup. La struttura dei commit dello stato iniziale è la seguente:

#figure(caption: "Struttura della repository di test allo stato iniziale.")[
  #table(
    columns: (auto, auto, 1fr),
    table.header([*Identificativo*], [*Operazione*], [*File coinvolto*]),
    [`0Q6PHT7QCI`], [Aggiunta], [`file.txt`],
    [`0Q6PHUAOSV`], [Modifica], [`file.txt`],
    [`0Q6PHV1YTU`], [Aggiunta], [`fileNuovo.txt`],
    [`0Q6PHW0IJW`], [Modifica], [`fileNuovo.txt`],
    [`0Q6PHWPMPQ`], [Aggiunta], [`fileSuperPrivato.txt`],
  )
]

Il verificatore di integrità sviluppato durante lo stage espone il comando `rvc integrity` con il parametro `-signers` che accetta il percorso di un file `allowed_signers` nel formato OpenSSH. Per ogni commit della #gl("repository") il verificatore controlla tre proprietà indipendenti: l'hash SHA256 del file ZIP, la catena dei `cumulativeHash` e la validità della firma #gl("ssh", capitalize: true) rispetto alla lista degli autorizzati. L'output classifica ogni commit con tre stati — `[OK]`, `[WARN]` e `[ERR]` — e produce un contatore finale degli errori critici e degli avvisi.

Lo stato iniziale pulito produce il seguente output del verificatore:

#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers\"",
  "
Verifica integrita repository: tutti i progetti
allowed_signers: C:\\Users\\stemic\\stage\\allowed_signers
analyzing repository C:\\Users\\stemic\\stage\\repo\\ ...
[OK]  0Q6PHT7QCI  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHV1YTU  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHW0IJW  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHWPMPQ  hash:OK  catena:OK  firma:OK  (Michele)
Risultato: 0/5 commit con problemi.
Risultato: 0/5 commit con warning."
)

Per ogni tecnica sono stati documentati i comandi eseguiti, l'output completo del verificatore e il comportamento del motore durante le operazioni normali successive all'attacco.

== Scenario 1 — Attaccante esterno senza credenziali

L'attaccante è un soggetto esterno che ha ottenuto accesso fisico o di rete alla cartella della #gl("repository") ma non possiede nessuna chiave #gl("ssh", capitalize: true) valida. Conosce il formato dei file #gl("rvc", capitalize: true) dall'osservazione della struttura della #gl("repository"). L'obiettivo è inserire modifiche non autorizzate oppure alterare la storia esistente senza che sia rilevabile dal motore.

=== T1 — Commit senza firma

L'attaccante produce un commit tramite il motore #gl("rvc", capitalize: true) senza fornire una chiave #gl("ssh", capitalize: true). Nella versione iniziale la firma è opzionale e il motore non la richiede.

#terminal-io(
  "echo Aggiunto testo malevolo >> fileSuperPrivato.txt",
  ""
)
#terminal-io(
  "rvc commit -project=simulazione -tag=Produzione -note=MoltoImportante",
  "
Reading manifest, path:.\\
packing simulazione.0Q6PI7VZWV.0Q6PHWPMPQ.+Produzione.zip
copying simulazione.0Q6PI7VZWV.0Q6PHWPMPQ.+Produzione.zip to repo\\ ...
copying simulazione.0Q6PI7VZWV.sig to repo\\ ...
tot. exec time: 0.23 sec"
)
#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers\"",
  "
Verifica integrita repository: tutti i progetti
[OK]   0Q6PHWPMPQ  hash:OK  catena:OK  firma:OK      (Michele)
[WARN] 0Q6PI7VZWV  hash:OK  catena:OK  firma:ASSENTE (?)
Risultato: 0/6 commit con problemi.
Risultato: 1/6 commit con warning."
)

*Risultato.* Il motore accetta il commit senza nessun avviso. Il verificatore segnala `[WARN] firma:ASSENTE` ma non incrementa il contatore degli errori critici. Tutte le operazioni successive del motore procedono normalmente.

*Impatto: Alto.* L'attaccante può inserire qualsiasi modifica al codice sorgente senza che il motore lo rilevi. Il commit fraudolento è visibile nella history con un autore vuoto ma non produce nessun segnale automatico di anomalia — è rilevabile solo tramite esecuzione esplicita del verificatore.

*Requisiti violati:* RS06 — autenticità e non ripudio.

=== T2 — Commit con identità falsa

L'attaccante produce un commit senza firma dichiarando nel campo `author` il nome di un autore autorizzato. Poiché non esiste una firma crittografica, il campo `author` non è verificabile e può contenere qualsiasi valore.

#terminal-io(
  "rvc commit -project=simulazione -tag=Produzione -note=MoltoImportante -author=Michele",
  "
Reading manifest, path:.\\
packing simulazione.0Q6PK4VQQR.0Q6PHWPMPQ.{Michele}+Produzione.zip
ERRORE: chiave-privata non trovata ne in rvc.config ne in identities\\
La commit e stata salvata senza firma Ssh.
copying simulazione.0Q6PK4VQQR.sig to repo\\ ...
tot. exec time: 0.14 sec"
)
#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers\"",
  "
[WARN] 0Q6PK4VQQR  hash:OK  catena:OK  firma:ASSENTE  (Michele)
Risultato: 0/6 commit con problemi.
Risultato: 1/6 commit con warning."
)

*Risultato.* Il motore segnala che la chiave-privata non è stata trovata ma accetta comunque il commit senza firma. Il verificatore produce lo stesso risultato di T1 — `[WARN] firma:ASSENTE` con il nome dell'autore dichiarato. Un osservatore che legge la history vede il commit attribuito a Michele senza nessun indicatore di anomalia.

Va notato che se l'attaccante dichiara un autore non presente nel file `allowed_signers`, il verificatore segnala `[ERR] firma:FALLITA` anziché `[WARN] firma:ASSENTE` — non è quindi possibile impersonare un autore completamente arbitrario senza essere rilevati.

*Impatto: Alto.* L'attaccante può impersonare qualsiasi autore autorizzato producendo un commit che nella history risulta indistinguibile da uno legittimo. Il rischio aumenta significativamente in contesti dove la firma non è considerata obbligatoria nella pratica operativa.

*Requisiti violati:* RS06 — autenticità e non ripudio.

=== T3 — Modifica del contenuto di uno ZIP esistente

L'attaccante modifica il contenuto di un file ZIP già presente nella #gl("repository") senza aggiornare il `.sig` corrispondente.

#terminal-io(
  "mkdir temp_estrazione",
  ""
)
#terminal-io(
  "tar -xf simulazione.0Q6PHV1YTU.0Q6PHUAOSV.{Michele}+documentazione.zip -C temp_estrazione",
  ""
)
#terminal-io(
  "echo aggiunta di codice malevolo >> temp_estrazione\\fileNuovo.txt",
  ""
)
#terminal-io(
  "tar -a -c -f simulazione.0Q6PHV1YTU.0Q6PHUAOSV.{Michele}+documentazione.zip -C temp_estrazione .",
  ""
)
#terminal-io(
  "rmdir /s /q temp_estrazione",
  ""
)
#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers\"",
  "
[OK]  0Q6PHUAOSV  hash:OK      catena:OK              firma:OK  (Michele)
[ERR] 0Q6PHV1YTU  hash:FALLITO catena:NON VERIFICABILE firma:OK  (Michele)
      ERRORE: Hash ZIP non corrisponde
[ERR] 0Q6PHW0IJW  hash:OK      catena:FALLITO          firma:OK  (Michele)
      ERRORE: CumulativeHash non corrisponde
[ERR] 0Q6PHWPMPQ  hash:OK      catena:FALLITO          firma:OK  (Michele)
      ERRORE: CumulativeHash non corrisponde
Risultato: 3/5 commit con problemi.
Risultato: 0/5 commit con warning."
)

*Risultato.* Il verificatore rileva immediatamente la discrepanza tra l'hash del file ZIP modificato e quello dichiarato nel `.sig`. Il commit alterato produce errori a cascata su tutti i successivi. Il motore continua a funzionare normalmente senza rilevare l'alterazione.

*Impatto: Basso.* La catena degli #gl("hash") è già una garanzia operativa nella versione iniziale — la modifica è rilevabile in modo inequivocabile. La protezione è però solo reattiva: il motore non blocca l'alterazione, la rileva solo il verificatore su richiesta esplicita.

*Requisiti violati:* RS01, RS02 — integrità e ordine verificabile.

=== T4 — Sostituzione completa di ZIP e .sig

L'attaccante sostituisce sia il file ZIP che il `.sig` di un commit esistente con valori ricalcolati su contenuto alterato, nel tentativo di produrre un commit che superi la verifica dell'hash.

#terminal-io(
  "python -c \"import hashlib; print(hashlib.sha256(open('simulazione.0Q6PHV1YTU...zip','rb').read()).hexdigest().upper())\"",
  "
35EFF8161A9E587248B4595AE1921FE3389663C4E1EFFCA44990918DB3853980"
)
#terminal-io(
  "python -c \"import hashlib; h1='35EFF8...'; h2='7047DC...'; print(hashlib.sha256((h1+h2).encode('utf-16-le')).hexdigest().upper())\"",
  "
2D2239E1A71520B807315AA212A765C00CDB6508F6A2C939A5B6BC7D7EF513A7"
)
#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers\"",
  "
[WARN] 0Q6PHV1YTU  hash:OK  catena:OK      firma:ASSENTE  (Michele)
[ERR]  0Q6PHW0IJW  hash:OK  catena:FALLITO  firma:OK       (Michele)
       ERRORE: CumulativeHash non corrisponde
[ERR]  0Q6PHWPMPQ  hash:OK  catena:FALLITO  firma:OK       (Michele)
       ERRORE: CumulativeHash non corrisponde
Risultato: 2/5 commit con problemi.
Risultato: 1/5 commit con warning."
)

*Risultato.* Il commit alterato supera la verifica dell'hash — il ricalcolo corretto inganna il verificatore sul nodo modificato. La catena si rompe nel commit successivo. Applicando il ricalcolo in cascata su tutti i commit successivi è possibile eliminare gli errori critici riducendo l'output a soli warning.

*Impatto: Alto.* Questa tecnica è il vettore di attacco più significativo dello scenario 1. In assenza di firme #gl("ssh", capitalize: true) obbligatorie, un attaccante sufficientemente determinato può riscrivere silenziosamente la storia di un progetto producendo solo warning. La firma #gl("ssh", capitalize: true) è l'unica protezione che impedisce questo scenario: se presente, il `.sig` modificato produce `[ERR] firma:FALLITA` e l'attacco è immediatamente rilevabile.

*Requisiti violati:* RS01, RS02 — integrità e ordine verificabile. RS06 come contromisura necessaria.

=== T5 — Inserimento di un commit in mezzo alla catena

L'attaccante tenta di inserire un commit tra due commit esistenti modificando i riferimenti `prevId` e `prevHash` e ricalcolando la catena degli #gl("hash") in cascata. Il risultato è analogo a T4 — i commit modificati producono warning per la firma assente e i commit successivi producono errori di catena fino al completamento del ricalcolo in cascata.

*Impatto: Alto.* Le implicazioni sono identiche a T4 — senza firme obbligatorie è possibile inserire commit arbitrari in qualsiasi punto della storia riducendo l'output a soli warning. La firma #gl("ssh", capitalize: true) è la contromisura necessaria: qualsiasi modifica al `.sig` originale invalida la firma e produce un errore critico.

*Requisiti violati:* RS02, RS03 — integrità e ordine verificabile.

=== T6 — Replay di un commit legittimo

L'attaccante copia un commit legittimo esistente e lo reintroduce nella #gl("repository") con un nuovo nome file.

#terminal-io(
  "copy \"simulazione.0Q6PHWPMPQ.0Q6PHW0IJW.{Michele}+documentazione.zip\" \"simulazione.0Q6PHWPZZZ.0Q6PHWPMPQ.{Michele}+documentazione.zip\"",
  "
1 file copiati."
)
#terminal-io(
  "copy simulazione.0Q6PHWPMPQ.sig simulazione.0Q6PHWPZZZ.sig",
  "
1 file copiati."
)
#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers\"",
  "
[OK]  0Q6PHWPMPQ  hash:OK  catena:OK      firma:OK  (Michele)
[ERR] 0Q6PHWPZZZ  hash:OK  catena:FALLITO  firma:OK  (Michele)
      ERRORE: CumulativeHash non corrisponde
Risultato: 1/6 commit con problemi.
Risultato: 0/6 commit con warning."
)

*Risultato.* Il verificatore rileva immediatamente l'errore di catena. La history mostra il commit reintrodotto come un #gl("branch") separato. Il ricalcolo del `cumulativeHash` è possibile ma non permette di alterare il contenuto dello ZIP — la firma originale diventerebbe invalida.

*Impatto: Basso.* L'attaccante non può inserire codice arbitrario — può solo duplicare commit esistenti creando #gl("branch") con lo stesso nome, sporcando la history senza modificarne il contenuto.

*Requisiti violati:* RS02, RS03 — ordine verificabile.

=== T7 — Modifica del .sig senza modificare lo ZIP

L'attaccante modifica solo il file `.sig` di un commit firmato lasciando lo ZIP intatto e la firma originale invariata.

#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers\"",
  "
[OK]  0Q6PHT7QCI  hash:OK  catena:OK  firma:OK      (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK  firma:OK      (Michele)
[OK]  0Q6PHV1YTU  hash:OK  catena:OK  firma:OK      (Michele)
[ERR] 0Q6PHW0IJW  hash:OK  catena:OK  firma:FALLITA (Michele)
      ERRORE: Firma Ssh non valida
[OK]  0Q6PHWPMPQ  hash:OK  catena:OK  firma:OK      (Michele)
Risultato: 1/5 commit con problemi.
Risultato: 0/5 commit con warning."
)

*Risultato.* Qualsiasi modifica a qualsiasi campo del `.sig` invalida la firma #gl("ssh", capitalize: true), che copre il file nella sua interezza. L'errore è localizzato al solo commit modificato — i successivi rimangono validi perché il `cumulativeHash` non è stato alterato.

*Impatto: Nullo.* La firma #gl("ssh", capitalize: true) è una protezione già operativa nella versione iniziale — qualsiasi tentativo di alterare i metadati di un commit firmato è immediatamente rilevabile.

*Requisiti soddisfatti:* RS06 — la firma #gl("ssh", capitalize: true) protegge l'integrità del `.sig` nella sua interezza.

=== T8 — Troncamento della catena

L'attaccante elimina fisicamente uno o più commit dalla #gl("repository") cancellando i file ZIP e `.sig` corrispondenti.

#terminal-io(
  "del \"simulazione.0Q6PHV1YTU.0Q6PHUAOSV.{Michele}+documentazione.zip\"",
  ""
)
#terminal-io(
  "del simulazione.0Q6PHV1YTU.sig",
  ""
)
#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers\"",
  "
[OK]  0Q6PHT7QCI  hash:OK  catena:OK      firma:OK  (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK      firma:OK  (Michele)
[ERR] 0Q6PHW0IJW  hash:OK  catena:FALLITO  firma:OK  (Michele)
      ERRORE: CumulativeHash non corrisponde
[ERR] 0Q6PHWPMPQ  hash:OK  catena:FALLITO  firma:OK  (Michele)
      ERRORE: CumulativeHash non corrisponde
Risultato: 2/4 commit con problemi.
Risultato: 0/4 commit con warning."
)

*Risultato.* Il verificatore rileva la discontinuità nella catena. La history mostra la catena spezzata come due #gl("branch") separati senza connessione.

*Impatto: Nullo.* Il troncamento è immediatamente rilevabile e non produce nessun vantaggio per l'attaccante. I commit successivi al punto di eliminazione producono errori critici e la history risulta incoerente.

*Requisiti violati:* RS02 — ordine verificabile.

=== T9 — Commit con cumulativeHash falsificato

L'attaccante produce un commit con #gl("hash") e `cumulativeHash` calcolati correttamente sul nuovo ZIP ma con `prevHash` che punta a un commit inesistente.

#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers\"",
  "
[OK]  0Q6PHT7QCI  hash:OK  catena:OK      firma:OK      (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK      firma:OK      (Michele)
[OK]  0Q6PHV1YTU  hash:OK  catena:OK      firma:OK      (Michele)
[ERR] 0Q6PHV1ZZZ  hash:OK  catena:FALLITO  firma:ASSENTE (Michele)
      ERRORE: CumulativeHash non corrisponde
[OK]  0Q6PHW0IJW  hash:OK  catena:OK      firma:OK      (Michele)
[OK]  0Q6PHWPMPQ  hash:OK  catena:OK      firma:OK      (Michele)
Risultato: 1/6 commit con problemi.
Risultato: 0/6 commit con warning."
)

*Risultato.* Il verificatore rileva l'errore di catena sul commit anomalo lasciando validi tutti gli altri. Il commit risulta isolato e non collegato alla storia legittima.

*Impatto: Basso.* L'attaccante non riesce a inserire un commit che si agganci alla storia legittima senza produrre errori critici. Il commit falsificato è immediatamente identificabile come anomalo e isolato dalla catena principale.

*Requisiti violati:* RS02, RS03 — integrità e ordine verificabile.

*Nota.* I commit successivi risultano OK perchè non sono collegati al commit falsificato, che è isolato come un #gl("branch") separato.

=== T10 — Iniezione di una repository fasulla

L'attaccante crea da zero una #gl("repository") completa con una catena di commit senza firma, strutturalmente valida dal punto di vista degli #gl("hash"), e la distribuisce come se fosse legittima.

#terminal-io(
  "rvc commit -project=simulazione -tag=Documentazione -note=MoltoImportante",
  "
packing simulazione.0Q6R82GADL..+Documentazione.zip \ copying simulazione.0Q6R82GADL.sig to repo\\ ..."
)
#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers\"",
  "
Verifica integrita repository: tutti i progetti
[WARN] 0Q6R82GADL  hash:OK  catena:OK  firma:ASSENTE  (?)
[WARN] 0Q6R832YWQ  hash:OK  catena:OK  firma:ASSENTE  (?)
[WARN] 0Q6R83HVQD  hash:OK  catena:OK  firma:ASSENTE  (?)
[WARN] 0Q6R83ULIB  hash:OK  catena:OK  firma:ASSENTE  (?)
[WARN] 0Q6R844SKJ  hash:OK  catena:OK  firma:ASSENTE  (?)
Risultato: 0/5 commit con problemi.
Risultato: 5/5 commit con warning."
)

*Risultato.* Il verificatore non rileva errori critici — la catena è strutturalmente valida. La #gl("repository") fasulla produce solo warning per la firma assente, identici a quelli di qualsiasi progetto senza firme #gl("ssh", capitalize: true).

*Impatto: Alto.* Un attaccante può distribuire codice arbitrario in una #gl("repository") che supera tutti i controlli strutturali del verificatore. Senza una radice di fiducia verificabile non esiste nessun meccanismo automatico per distinguere questa #gl("repository") da una legittima. Questa tecnica dimostra direttamente l'assenza di RS05 e la necessità del progetto `_rvc_root` proposto nel modello.

*Requisiti violati:* RS05 — radice di fiducia verificabile autonomamente.

=== Sintesi dello scenario 1

#figure(caption: "Sintesi dei risultati — Scenario 1.")[
  #table(
    columns: (auto, 1fr, auto, auto, auto),
    table.header([*Tecnica*], [*Descrizione*], [*Verificatore*], [*Motore*], [*Impatto*]),
    [T1],  [Commit senza firma],         [WARN],     [No], [Alto],
    [T2],  [Identità falsa],                                      [WARN],     [No], [Alto],
    [T3],  [Modifica ZIP esistente],                              [ERR],      [No], [Basso],
    [T4],  [Sostituzione ZIP e .sig],                             [WARN+ERR], [No], [Alto],
    [T5],  [Inserimento in mezzo],                                [WARN+ERR], [No], [Alto],
    [T6],  [Replay commit legittimo],                     [ERR],      [No], [Basso],
    [T7],  [Modifica .sig senza ZIP],                             [ERR],      [No], [Nullo],
    [T8],  [Troncamento catena],                                  [ERR],      [No], [Nullo],
    [T9],  [`cumulativeHash` falsificato],                        [ERR],      [No], [Basso],
    [T10], [#gl("repository", capitalize: true) fasulla],         [WARN],     [No], [Alto],
  )
]

Il risultato più significativo dello scenario 1 è la distinzione tra due categorie di tecniche. Le tecniche T3, T6, T7, T8 e T9 producono errori critici rilevabili dal verificatore — la catena degli #gl("hash") e la firma #gl("ssh", capitalize: true) forniscono già protezione efficace, con impatto nullo o basso. Le tecniche T1, T2, T4, T5 e T10 producono solo warning — l'attaccante può agire senza produrre errori critici, con impatto alto in tutti i casi. Il denominatore comune è l'assenza di firma #gl("ssh", capitalize: true) obbligatoria. T4 e T5 meritano attenzione particolare: con ricalcolo in cascata degli #gl("hash") è possibile riscrivere la storia di un progetto producendo solo warning, rendendo l'attacco praticamente invisibile a chi non esegue il verificatore in modo sistematico.

== Scenario 2 — Dipendente con chiave SSH valida ma non autorizzato

Il secondo scenario simula un dipendente dell'organizzazione che possiede una chiave #gl("ssh", capitalize: true) valida e sa produrre commit firmati correttamente, ma non è autorizzato a operare su uno o più progetti specifici. A differenza dello scenario 1, i commit prodotti sono crittograficamente validi — la firma è presente e corretta. Il verificatore deve quindi distinguere tra "firma valida" e "firmatario autorizzato", due proprietà che nella versione iniziale non sono entrambe verificate preventivamente dal motore.

=== T1 — Commit firmato da chiave non autorizzata

Il dipendente firma un commit con la propria chiave #gl("ssh", capitalize: true) valida su un progetto a cui non dovrebbe avere accesso. Il motore non verifica se la chiave del firmatario sia presente in una lista di autorizzati — nella versione iniziale questa lista non esiste.

#terminal-io(
  "rvc commit -project=simulazione -tag=attaccante -author=Luigi -note=QuestoCommitFattoDaLuigi",
  "
Reading manifest, path:.\\
packing simulazione.0Q6RCTTRWQ.0Q6PHWPMPQ.{Luigi}+attaccante.zip
copying simulazione.0Q6RCTTRWQ.0Q6PHWPMPQ.{Luigi}+attaccante.zip to repo\\ ...
copying simulazione.0Q6RCTTRWQ.sig to repo\\ ...
tot. exec time: 0.41 sec"
)
#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers\"",
  "
[OK]  0Q6PHT7QCI  hash:OK  catena:OK  firma:OK      (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK  firma:OK      (Michele)
[OK]  0Q6PHV1YTU  hash:OK  catena:OK  firma:OK      (Michele)
[OK]  0Q6PHW0IJW  hash:OK  catena:OK  firma:OK      (Michele)
[OK]  0Q6PHWPMPQ  hash:OK  catena:OK  firma:OK      (Michele)
[ERR] 0Q6RCTTRWQ  hash:OK  catena:OK  firma:FALLITA (Luigi)
      ERRORE: Firma Ssh non valida
Risultato: 1/6 commit con problemi.
Risultato: 0/6 commit con warning."
)

*Risultato.* Il motore accetta il commit senza nessun avviso e le operazioni successive procedono normalmente. Il verificatore rileva il problema segnalando `[ERR] firma:FALLITA` — la chiave di Luigi non è presente nel file `allowed_signers`. L'anomalia è rilevabile solo tramite verifica esplicita.

*Impatto: Alto.* Un dipendente non autorizzato può produrre commit su qualsiasi progetto senza che il motore lo impedisca. Il commit è crittograficamente firmato e appare nella history come un commit normale — la differenza rispetto a uno legittimo emerge solo dal verificatore. In assenza di verifiche periodiche, l'accesso non autorizzato può passare inosservato a lungo.

*Requisiti violati:* RS07, RS08 — gerarchia di fiducia e permessi configurabili per progetto.

=== T2 — Commit firmato con author dichiarato diverso dal firmatario

Il dipendente firma il commit con la propria chiave #gl("ssh", capitalize: true) ma dichiara nel campo `author` il nome di un collega autorizzato. Il motore accetta il commit perché la firma è crittograficamente valida. Il verificatore rileva la discrepanza tra l'autore dichiarato e la chiave effettivamente usata per la firma.

#terminal-io(
  "rvc commit -project=simulazione -tag=attaccante -author=Michele -note=QuestoCommitFattoDaLuigiSottoNomeDiMichele",
  "
Reading manifest, path:.\\
packing simulazione.0Q6RJWRDEU.0Q6PHWPMPQ.{Michele}+attaccante.zip
copying simulazione.0Q6RJWRDEU.0Q6PHWPMPQ.{Michele}+attaccante.zip to repo\\ ...
copying simulazione.0Q6RJWRDEU.sig to repo\\ ...
tot. exec time: 0.50 sec"
)
#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers\"",
  "
[OK]  0Q6PHT7QCI  hash:OK  catena:OK  firma:OK      (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK  firma:OK      (Michele)
[OK]  0Q6PHV1YTU  hash:OK  catena:OK  firma:OK      (Michele)
[OK]  0Q6PHW0IJW  hash:OK  catena:OK  firma:OK      (Michele)
[OK]  0Q6PHWPMPQ  hash:OK  catena:OK  firma:OK      (Michele)
[ERR] 0Q6RJWRDEU  hash:OK  catena:OK  firma:FALLITA (Michele)
      ERRORE: Firma Ssh non valida
Risultato: 1/6 commit con problemi.
Risultato: 0/6 commit con warning."
)

*Risultato.* Il motore non rileva nessuna discrepanza. Il verificatore segnala `[ERR] firma:FALLITA` perché la chiave usata per firmare appartiene a Luigi ma il campo `author` dichiara Michele — il confronto tra autore dichiarato e chiave-pubblica nel file `allowed_signers` fallisce.

*Impatto: Alto.* Il rischio principale esiste nei contesti dove la verifica delle firme non è eseguita sistematicamente ma basta la presenza di una qualsiasi firma. In quel caso il commit appare firmato da un autore autorizzato — Michele — e passa inosservato. Solo il verificatore con il file `allowed_signers` corretto rivela che la chiave usata non appartiene all'autore dichiarato.

*Requisiti violati:* RS07, RS08 — autenticità e autorizzazione.

=== T3 — Volume di commit non autorizzati senza rilevamento operativo

Il dipendente produce una serie di commit firmati con la propria chiave su un progetto non autorizzato nel corso del tempo. L'obiettivo è dimostrare che il motore non emette nessun segnale operativo durante le operazioni normali, indipendentemente dal numero di commit non autorizzati presenti.

#terminal-io(
  "rvc commit -project=simulazione -tag=attaccante -author=Luigi -note=QuestoCommitFattoDaLuigi",
  "
copying simulazione.0Q6RLK7XSL.sig to repo\\ ... tot. exec time: 0.47 sec"
)
#terminal-io(
  "rvc commit -project=simulazione -tag=attaccante -author=Luigi -note=QuestoCommitFattoDaLuigi",
  "
copying simulazione.0Q6RLK9DFH.sig to repo\\ ... tot. exec time: 0.41 sec"
)
#terminal-io(
  "rvc commit -project=simulazione -tag=attaccante -author=Luigi -note=QuestoCommitFattoDaLuigi",
  "
copying simulazione.0Q6RLKAHPC.sig to repo\\ ... tot. exec time: 0.42 sec"
)
#terminal-io(
  "rvc commit -project=simulazione -tag=attaccante -author=Luigi -note=QuestoCommitFattoDaLuigi",
  "
copying simulazione.0Q6RLKCNCY.sig to repo\\ ... tot. exec time: 0.44 sec"
)
#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers\"",
  "
[OK]  0Q6PHT7QCI  hash:OK  catena:OK  firma:OK      (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK  firma:OK      (Michele)
[OK]  0Q6PHV1YTU  hash:OK  catena:OK  firma:OK      (Michele)
[OK]  0Q6PHW0IJW  hash:OK  catena:OK  firma:OK      (Michele)
[OK]  0Q6PHWPMPQ  hash:OK  catena:OK  firma:OK      (Michele)
[ERR] 0Q6RLK7XSL  hash:OK  catena:OK  firma:FALLITA (Luigi)
      ERRORE: Firma Ssh non valida
[ERR] 0Q6RLK9DFH  hash:OK  catena:OK  firma:FALLITA (Luigi)
      ERRORE: Firma Ssh non valida
[ERR] 0Q6RLKAHPC  hash:OK  catena:OK  firma:FALLITA (Luigi)
      ERRORE: Firma Ssh non valida
[ERR] 0Q6RLKCNCY  hash:OK  catena:OK  firma:FALLITA (Luigi)
      ERRORE: Firma Ssh non valida
Risultato: 4/9 commit con problemi.
Risultato: 0/9 commit con warning."
)

*Risultato.* Il motore esegue tutti i commit e tutte le operazioni di history senza segnalare nessuna anomalia. Solo il verificatore, eseguito esplicitamente alla fine, rileva tutti i commit non autorizzati in una singola analisi.

*Impatto: Alto.* L'assenza di RS07 e RS08 non produce nessun segnale operativo visibile — il sistema non avvisa mai autonomamente che qualcosa non va. La rilevazione dipende interamente dall'esecuzione periodica e sistematica del verificatore. In un contesto operativo reale dove il verificatore non viene eseguito ad ogni commit, un dipendente non autorizzato può operare indisturbato per un periodo prolungato, accumulando modifiche non autorizzate che risultano crittograficamente valide.

*Requisiti violati:* RS07, RS08 — gerarchia di fiducia e permessi configurabili per progetto.

=== Sintesi dello scenario 2

#figure(caption: "Sintesi dei risultati — Scenario 2.")[
  #table(
    columns: (auto, 1fr, auto, auto, auto),
    table.header([*Tecnica*], [*Descrizione*], [*Verificatore*], [*Motore*], [*Impatto*]),
    [T1], [Commit da chiave non autorizzata],  [ERR], [No], [Alto],
    [T2], [Author dichiarato diverso dal firmatario], [ERR], [No], [Alto],
    [T3], [Commit multipli senza segnale operativo],  [ERR], [No], [Alto],
  )
]

A differenza dello scenario 1, tutte le tecniche dello scenario 2 producono errori critici nel verificatore — la firma #gl("ssh", capitalize: true) è presente e il verificatore può confrontarla con il file `allowed_signers`. Tuttavia questo non riduce la gravità: il motore non blocca mai nessuno di questi commit preventivamente. La protezione esiste solo a posteriori, tramite verifica esplicita. Il risultato chiave di questo scenario è che nella versione iniziale di #gl("rvc", capitalize: true) non esiste distinzione tra un dipendente autorizzato e uno non autorizzato — chiunque possieda una chiave #gl("ssh", capitalize: true) valida può operare su qualsiasi progetto senza restrizioni operative.

== Scenario 3 — Chiave privata di un dipendente compromessa

Il terzo scenario simula la compromissione della chiave-privata #gl("ssh", capitalize: true) di un dipendente legittimo. L'attaccante può produrre commit firmati crittograficamente identici a quelli del dipendente reale — la chiave è quella corretta e il firmatario è presente nel file `allowed_signers`. Questo è lo scenario più insidioso: la firma è valida, il firmatario è autorizzato, e non esiste nessun meccanismo automatico per distinguere un commit fraudolento da uno legittimo.

Una nota sul verificatore: il verificatore attuale usa un file `allowed_signers` esterno e statico. Nel modello proposto ogni commit porta il proprio `allowed_Dipendenti` interno al momento della firma — i commit prodotti prima della revoca rimarrebbero validi perché la lista includeva la chiave al momento della firma. Per simulare entrambi i comportamenti vengono usati due file separati: `allowed_signers_con_chiave` che include la chiave compromessa, e `allowed_signers_senza_chiave` che non la include.

=== T1 — Commit fraudolento indistinguibile dal legittimo

L'attaccante produce un commit firmato con la chiave rubata del dipendente legittimo. Il verificatore eseguito con `allowed_signers_con_chiave` segnala il commit come completamente valido.

#terminal-io(
  "rvc commit -project=simulazione -tag=produzione -author=Michele -note=CommitFattoDaQualcunaltro",
  "
Reading manifest, path:.\\
packing simulazione.0Q6WRGCMHR.0Q6PHWPMPQ.{Michele}+produzione.zip
copying simulazione.0Q6WRGCMHR.0Q6PHWPMPQ.{Michele}+produzione.zip to repo\\ ...
copying simulazione.0Q6WRGCMHR.sig to repo\\ ...
tot. exec time: 0.33 sec"
)
#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers_con_chiave\"",
  "
[OK]  0Q6PHT7QCI  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHV1YTU  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHW0IJW  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHWPMPQ  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6WRGCMHR  hash:OK  catena:OK  firma:OK  (Michele)
Risultato: 0/6 commit con problemi.
Risultato: 0/6 commit con warning."
)

*Risultato.* Il commit è accettato dal motore e risulta completamente valido al verificatore. Non esiste nessun indicatore automatico che permetta di distinguerlo da un commit legittimo prodotto dal dipendente reale.

*Impatto: Alto.* L'attaccante ha piena capacità di committare codice arbitrario che supera tutti i controlli automatici. Non è rilevabile né dal motore né dal verificatore — l'unica contromisura possibile è un controllo manuale del contenuto committato e una rotazione periodica delle chiavi. Questa è una limitazione strutturale di qualsiasi sistema basato su crittografia-asimmetrica: la chiave-privata è l'unico indicatore di identità e la sua compromissione annulla tutte le garanzie crittografiche.

*Requisiti coinvolti:* RS09 — revoca efficace delle identità.

=== T2 — Commit fraudolenti durante la finestra di rischio

L'attaccante produce più commit nell'intervallo tra la compromissione della chiave e la sua revoca, dimostrando concretamente la finestra di rischio descritta nel modello.

#terminal-io(
  "rvc commit -project=simulazione -tag=produzione -author=Michele -note=CommitFattoDaQualcunaltro",
  "
copying simulazione.0Q6WRGCMHR.sig to repo\\ ... tot. exec time: 0.33 sec"
)
#terminal-io(
  "rvc commit -project=simulazione -tag=produzione -author=Michele -note=CommitFattoDaQualcunaltro",
  "
copying simulazione.0Q6WTK5GET.sig to repo\\ ... tot. exec time: 0.39 sec"
)
#terminal-io(
  "rvc commit -project=simulazione -tag=produzione -author=Michele -note=CommitFattoDaQualcunaltro",
  "
copying simulazione.0Q6WTKCDJL.sig to repo\\ ... tot. exec time: 0.31 sec"
)
#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers_con_chiave\"",
  "
[OK]  0Q6PHT7QCI  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHV1YTU  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHW0IJW  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHWPMPQ  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6WRGCMHR  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6WTK5GET  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6WTKCDJL  hash:OK  catena:OK  firma:OK  (Michele)
Risultato: 0/8 commit con problemi.
Risultato: 0/8 commit con warning."
)

Dopo la simulazione della revoca, il verificatore viene rieseguito con `allowed_signers_senza_chiave`:

#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers_senza_chiave\"",
  "
[ERR] 0Q6PHT7QCI  hash:OK  catena:OK  firma:FALLITA  (Michele)
      ERRORE: Firma Ssh non valida
[ERR] 0Q6PHUAOSV  hash:OK  catena:OK  firma:FALLITA  (Michele)
      ERRORE: Firma Ssh non valida
[ERR] 0Q6PHV1YTU  hash:OK  catena:OK  firma:FALLITA  (Michele)
      ERRORE: Firma Ssh non valida
[ERR] 0Q6PHW0IJW  hash:OK  catena:OK  firma:FALLITA  (Michele)
      ERRORE: Firma Ssh non valida
[ERR] 0Q6PHWPMPQ  hash:OK  catena:OK  firma:FALLITA  (Michele)
      ERRORE: Firma Ssh non valida
[ERR] 0Q6WRGCMHR  hash:OK  catena:OK  firma:FALLITA  (Michele)
      ERRORE: Firma Ssh non valida
[ERR] 0Q6WTK5GET  hash:OK  catena:OK  firma:FALLITA  (Michele)
      ERRORE: Firma Ssh non valida
[ERR] 0Q6WTKCDJL  hash:OK  catena:OK  firma:FALLITA  (Michele)
      ERRORE: Firma Ssh non valida
Risultato: 8/8 commit con problemi.
Risultato: 0/8 commit con warning."
)

*Risultato.* Con la chiave presente nell'`allowed_signers` tutti i commit — legittimi e fraudolenti — risultano validi. Dopo la rimozione della chiave, tutti risultano in errore indistintamente. Questo comportamento differisce dal modello proposto: con `allowed_Dipendenti` interno a ogni commit, i commit prodotti prima della revoca rimarrebbero validi perché la lista al momento della firma includeva la chiave. Il verificatore attuale non distingue tra "chiave valida al momento della firma" e "chiave valida ora".

*Impatto: Alto.* Durante la finestra di rischio l'attaccante può produrre qualsiasi numero di commit fraudolenti che risultano indistinguibili da quelli legittimi. La dimensione di questa finestra dipende interamente dalla rapidità con cui la compromissione viene identificata e comunicata.

*Requisiti coinvolti:* RS09 — revoca efficace delle identità.

=== T3 — Propagazione nella catena dopo la revoca

Con la #gl("repository") prodotta in T2, il verificatore viene eseguito con entrambi i file `allowed_signers` per confrontare i comportamenti e identificare i commit sospetti.

#terminal(
"Con allowed_signers_con_chiave:
[OK]  tutti i commit — legittimi e fraudolenti risultano validi

Con allowed_signers_senza_chiave:
[ERR] tutti i commit — legittimi e fraudolenti risultano in errore"
)

*Risultato.* Con il verificatore attuale non è possibile distinguere automaticamente i commit fraudolenti da quelli legittimi dopo la revoca — entrambi cambiano stato in blocco al cambio del file `allowed_signers`. La catena degli #gl("hash") risulta intatta in entrambi i casi — i commit fraudolenti non hanno alterato la struttura crittografica della storia.

*Impatto: Alto.* L'identificazione dei commit fraudolenti richiede un'analisi manuale della history nel periodo sospetto. Nel modello proposto con `allowed_Dipendenti` interno questa distinzione sarebbe automatica — i commit legittimi prodotti prima della revoca rimarrebbero validi mentre quelli fraudolenti prodotti con la stessa chiave sarebbero distinguibili per contenuto. Questa limitazione è la motivazione principale della scelta architetturale dell'`allowed_Dipendenti` versionato nel modello proposto.

*Requisiti coinvolti:* RS09 — revoca efficace delle identità.

=== T4 — Recovery dopo compromissione della chiave

Questa tecnica non documenta un attacco ma la procedura di risposta — come il sistema gestisce il ripristino delle garanzie di sicurezza dopo la compromissione.

#terminal-io(
  "ssh-keygen -t ed25519 -f chiave_nuova",
  "
Generating public/private ed25519 key pair."
)

Dopo aver aggiornato il file `allowed_signers` rimuovendo la chiave compromessa e aggiungendo quella nuova, il verificatore mostra:

#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers\"",
  "
[ERR] 0Q6PHT7QCI  hash:OK  catena:OK  firma:FALLITA  (Michele)
[ERR] 0Q6PHUAOSV  hash:OK  catena:OK  firma:FALLITA  (Michele)
[ERR] 0Q6PHV1YTU  hash:OK  catena:OK  firma:FALLITA  (Michele)
[ERR] 0Q6PHW0IJW  hash:OK  catena:OK  firma:FALLITA  (Michele)
[ERR] 0Q6PHWPMPQ  hash:OK  catena:OK  firma:FALLITA  (Michele)
[ERR] 0Q6WWOWTGV  hash:OK  catena:OK  firma:FALLITA  (Michele)
[ERR] 0Q6WWP3QDM  hash:OK  catena:OK  firma:FALLITA  (Michele)
[ERR] 0Q6WWP4TNH  hash:OK  catena:OK  firma:FALLITA  (Michele)"
)

Dopo aver prodotto un nuovo commit firmato con la nuova chiave:

#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers\"",
  "
[ERR] 0Q6PHT7QCI  hash:OK  catena:OK  firma:FALLITA  (Michele)
[ERR] 0Q6PHUAOSV  hash:OK  catena:OK  firma:FALLITA  (Michele)
[ERR] 0Q6PHV1YTU  hash:OK  catena:OK  firma:FALLITA  (Michele)
[ERR] 0Q6PHW0IJW  hash:OK  catena:OK  firma:FALLITA  (Michele)
[ERR] 0Q6PHWPMPQ  hash:OK  catena:OK  firma:FALLITA  (Michele)
[ERR] 0Q6WWOWTGV  hash:OK  catena:OK  firma:FALLITA  (Michele)
[ERR] 0Q6WWP3QDM  hash:OK  catena:OK  firma:FALLITA  (Michele)
[ERR] 0Q6WWP4TNH  hash:OK  catena:OK  firma:FALLITA  (Michele)
[OK]  0Q6WWTIPTA  hash:OK  catena:OK  firma:OK        (Michele)
Risultato: 8/9 commit con problemi.
Risultato: 0/9 commit con warning."
)

*Risultato.* La procedura di recovery è operativa — il nuovo commit firmato con la nuova chiave risulta immediatamente valido. I commit precedenti risultano tutti in errore indistintamente, senza distinzione tra legittimi e fraudolenti — limitazione già documentata in T3.

*Impatto.* La recovery non richiede interventi straordinari — è sufficiente aggiornare il file `allowed_signers`. La finestra di rischio si chiude dal commit successivo alla revoca. La limitazione principale è che il verificatore attuale non distingue i commit legittimi prodotti prima della revoca da quelli fraudolenti — nel modello proposto con `allowed_Dipendenti` interno questa distinzione sarebbe automatica.

*Obiettivo stage soddisfatto:* D03 — studio e implementazione delle tecniche di recovery delle credenziali.

=== Sintesi dello scenario 3

#figure(caption: "Sintesi dei risultati — Scenario 3.")[
  #table(
    columns: (auto, 1fr, auto, auto, auto),
    table.header([*Tecnica*], [*Descrizione*], [*Verificatore*], [*Motore*], [*Impatto*]),
    [T1], [Commit fraudolento indistinguibile], [OK (con chiave)],  [No], [Alto],
    [T2], [Finestra di rischio],                                          [OK→ERR],          [No], [Alto],
    [T3], [Propagazione dopo revoca],                                     [ERR indistinto],  [No], [Alto],
    [T4], [Recovery chiave compromessa],                                  [OK (nuova)],      [No], [-],
  )
]

Lo scenario 3 è il più critico dell'intera simulazione — nessuna delle tecniche è rilevabile automaticamente durante la finestra di rischio. La compromissione di una chiave-privata azzera tutte le garanzie crittografiche perché la chiave è l'unico indicatore di identità del sistema. Le uniche mitigazioni sono procedurali: rotazione periodica delle chiavi e revoca immediata alla scoperta della compromissione. Il modello proposto con `allowed_Dipendenti` interno a ogni commit migliora la situazione post-revoca permettendo di distinguere automaticamente i commit legittimi da quelli fraudolenti — ma non elimina la finestra di rischio, che rimane una limitazione strutturale di qualsiasi sistema basato su crittografia-asimmetrica.

== Scenario 4 — Chiave operativa dell'amministratore compromessa

Il quarto scenario simula la compromissione della chiave-privata #gl("ssh", capitalize: true) operativa dell'amministratore — il soggetto con i poteri più ampi sull'intera #gl("repository"). Nella versione iniziale di #gl("rvc", capitalize: true) questo scenario non è distinguibile tecnicamente dagli scenari precedenti — non esistono controlli di permessi differenziati per ruolo e la chiave dell'amministratore non ha nessun trattamento speciale da parte del motore.

Il valore di questo scenario è quindi principalmente analitico: dimostrare che nella versione iniziale la compromissione dell'amministratore non produce nessun segnale aggiuntivo rispetto alla compromissione di qualsiasi altro utente, e analizzare perché nel modello proposto questo scenario sarebbe invece il più critico in assoluto.

=== T1 — Compromissione totale e silenziosa

L'attaccante usa la chiave operativa dell'amministratore per produrre commit su più progetti della #gl("repository"). Il motore accetta tutto senza distinzione. Il verificatore segnala tutti i commit come validi perché la chiave è presente nel file `allowed_signers`.

#terminal-io(
  "rvc commit -project=simulazione -tag=produzione -author=Michele -note=CommitFattoDaQualcunaltro",
  "
Reading manifest, path:.\\
packing simulazione.0Q6WWOWTGV.0Q6PHWPMPQ.{Michele}+produzione.zip
copying simulazione.0Q6WWOWTGV.sig to repo\\ ...
tot. exec time: 0.33 sec"
)
#terminal-io(
  "rvc commit -project=simulazione -tag=produzione -author=Michele -note=CommitFattoDaQualcunaltro",
  "
copying simulazione.0Q6WWP3QDM.sig to repo\\ ... tot. exec time: 0.31 sec"
)
#terminal-io(
  "rvc commit -project=simulazione -tag=produzione -author=Michele -note=CommitFattoDaQualcunaltro",
  "
copying simulazione.0Q6WWP4TNH.sig to repo\\ ... tot. exec time: 0.29 sec"
)
#terminal-io(
  "rvc integrity -signers=\"C:\\Users\\stemic\\stage\\allowed_signers\"",
  "
[OK]  0Q6PHT7QCI  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHV1YTU  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHW0IJW  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHWPMPQ  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6WWOWTGV  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6WWP3QDM  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6WWP4TNH  hash:OK  catena:OK  firma:OK  (Michele)
Risultato: 0/8 commit con problemi.
Risultato: 0/8 commit con warning."
)

*Risultato.* Il motore accetta tutti i commit senza avvisi. Il verificatore li segnala tutti come validi — la chiave è quella corretta e il firmatario è nel file `allowed_signers`. Il risultato è tecnicamente identico allo scenario 3: la versione iniziale non distingue tra ruoli.

*Impatto nella versione iniziale: Alto, identico allo scenario 3.* Non è rilevabile né dal motore né dal verificatore in modo automatico. L'unica contromisura è procedurale.

*Impatto nel modello proposto: Critico.* Nel modello proposto la compromissione della chiave operativa dell'amministratore è lo scenario più grave in assoluto perché l'attaccante acquisisce poteri esclusivi che nessun altro soggetto possiede:

- Può modificare `allowed_Responsabili` in `_rvc_root` — aggiungendo identità false o rimuovendo responsabili legittimi
- Può produrre commit amministrativi su qualsiasi progetto senza nessun vincolo di appartenenza
- Può alterare le policy di sicurezza di qualsiasi progetto modificando il file `.rvc_policy`
- Può revocare l'accesso a dipendenti legittimi su qualsiasi progetto

Queste azioni compromettono non solo la #gl("repository") attuale ma l'intera struttura di fiducia — incluse le autorizzazioni future di tutti i soggetti. A differenza della compromissione di un dipendente, che ha effetti limitati al proprio progetto, la compromissione dell'amministratore può invalidare l'intera catena di fiducia della #gl("repository").

*Contromisure architetturali nel modello proposto.* Il modello affronta questo scenario con due meccanismi complementari. Il primo è la separazione tra chiave master e chiave operativa: la chiave master è conservata offline su un dispositivo #gl("air-gapped") e non viene mai usata nelle operazioni ordinarie. La compromissione della chiave operativa non comporta la perdita del controllo della #gl("repository") — la chiave master può revocarla e nominarne una nuova senza perdere la catena di fiducia. Il secondo meccanismo è la revoca con chiave master: il commit di revoca firmato con la chiave master è riconosciuto dal motore come autoritativo anche se la chiave master non è in `allowed_Dipendenti` — è il meccanismo eccezionale descritto nella sezione sulla compromissione della chiave dell'amministratore nel @cap:modello-sicurezza.

*Requisiti coinvolti:* RS05, RS07, RS08, RS09, RS10 — radice di fiducia, gerarchia, permessi, revoca e successione.

*Obiettivo stage soddisfatto:* D01 — simulazione di attacchi con chiave del capo progetto compromessa.

=== Sintesi dello scenario 4

#figure(caption: "Sintesi dei risultati — Scenario 4.")[
  #table(
    columns: (auto, 1fr, auto, auto, auto),
    table.header([*Tecnica*], [*Descrizione*], [*Verificatore*], [*Motore*], [*Impatto*]),
    [T1], [Compromissione totale e silenziosa], [OK], [No], [Critico],
  )
]

Lo scenario 4 conferma che nella versione iniziale di #gl("rvc", capitalize: true) non esiste nessuna distinzione tecnica tra la compromissione dell'amministratore e quella di qualsiasi altro utente — il motore tratta tutte le chiavi allo stesso modo. Il valore di questo scenario è quindi prospettico: dimostrare perché il modello proposto introduce una gerarchia di fiducia asimmetrica con la chiave master offline come ultima ancora di sicurezza. Senza questa separazione, la compromissione dell'amministratore comporterebbe la perdita irreversibile del controllo dell'intera #gl("repository").

== Sintesi complessiva

I quattro scenari documentano un quadro coerente delle vulnerabilità della versione iniziale di #gl("rvc", capitalize: true). Il sistema dispone di basi crittografiche solide — la catena degli #gl("hash") e la firma #gl("ssh", capitalize: true) sono strumenti efficaci quando presenti — ma manca dei meccanismi organizzativi che trasformano queste garanzie tecniche in un modello di sicurezza praticabile in contesti multi-utente.

#figure(caption: "Sintesi complessiva degli scenari di attacco.")[
  #table(
    columns: (auto, 1fr, auto, auto),
    table.header([*Scenario*], [*Contesto*], [*Rilevabile*], [*Impatto massimo*]),
    [S1], [Esterno senza credenziali],             [Parzialmente], [Alto],
    [S2], [Dipendente con chiave non autorizzata], [Solo verificatore], [Alto],
    [S3], [Chiave dipendente compromessa],         [Non rilevabile], [Alto],
    [S4], [Chiave amministratore compromessa],     [Non rilevabile], [Critico],
  )
]

=== Osservazione 1 — Il motore non costituisce una linea di difesa

In nessuno dei quattro scenari il motore ha bloccato preventivamente un'azione non autorizzata. Ogni tecnica di attacco è stata eseguita con successo dal punto di vista operativo — i commit sono stati accettati, inseriti nella catena e resi disponibili nella history senza nessun avviso. Il verificatore ha rilevato le anomalie solo su esecuzione esplicita e a posteriori.

Questa osservazione ha un'implicazione diretta sul modello di sicurezza operativa: nella versione iniziale di #gl("rvc", capitalize: true) la sicurezza della #gl("repository") dipende interamente dalla disciplina procedurale di chi la gestisce — in particolare dalla frequenza e dalla sistematicità con cui il verificatore viene eseguito. In assenza di questa disciplina, qualsiasi delle tecniche documentate può operare indisturbata per un periodo arbitrariamente lungo.

=== Osservazione 2 — La firma SSH è una protezione necessaria ma non sufficiente

La firma #gl("ssh", capitalize: true) è il meccanismo di sicurezza più maturo della versione iniziale. T7 dimostra che qualsiasi modifica al file `.sig` di un commit firmato produce un errore critico immediatamente rilevabile — la firma copre il file nella sua interezza e non lascia spazio a modifiche parziali. T3 dimostra analogamente che la catena degli #gl("hash") rileva qualsiasi alterazione del contenuto ZIP senza ricalcolo.

Tuttavia la firma è opzionale nella versione iniziale, e questa opzionalità vanifica le protezioni che offre. T4 e T5 dimostrano che in assenza di firma è possibile riscrivere la storia di un progetto — modificando ZIP e ricalcolando gli #gl("hash") in cascata — riducendo l'output del verificatore a soli warning, senza errori critici. La firma #gl("ssh", capitalize: true) obbligatoria è quindi una condizione necessaria per la sicurezza del sistema, non una funzionalità opzionale. Questa osservazione corrisponde direttamente al requisito RS06 identificato nel modello e classificato come obbligatorio.

=== Osservazione 3 — L'assenza di controllo delle identità è la vulnerabilità strutturale principale

Gli scenari 2, 3 e 4 convergono sulla stessa vulnerabilità di fondo: nella versione iniziale non esiste nessuna lista di autorizzati per progetto. Qualsiasi soggetto in possesso di una chiave #gl("ssh", capitalize: true) — autorizzata o meno, legittima o rubata — può produrre commit validi su qualsiasi progetto. Il verificatore può rilevare le anomalie confrontando le firme con un file `allowed_signers` esterno, ma questo controllo è manuale e non integrato nel flusso operativo del motore.

La conseguenza più grave di questa assenza è documentata nello scenario 3: la compromissione di una chiave-privata non produce nessun segnale automatico rilevabile — il verificatore con la chiave ancora presente nell'`allowed_signers` segnala tutti i commit come validi, inclusi quelli fraudolenti. Solo la rimozione esplicita della chiave dall'`allowed_signers` permette di identificare le anomalie, ma a quel punto non è possibile distinguere automaticamente i commit legittimi prodotti prima della revoca da quelli fraudolenti — entrambi risultano in errore indistintamente. Questa limitazione è la motivazione principale della scelta architetturale dell'`allowed_Dipendenti` versionato proposta nel modello, che risolve il problema mantenendo all'interno di ogni commit la lista degli autorizzati valida al momento della firma.

=== Osservazione 4 — La gravità cresce con il livello di privilegio dell'attaccante

I quattro scenari sono stati costruiti in ordine crescente di privilegio dell'attaccante — da nessuna credenziale fino alla chiave dell'amministratore. L'analisi mostra che la gravità degli attacchi segue questa progressione in modo non lineare.

Negli scenari 1 e 2 la rilevabilità è almeno parziale — le firme presenti permettono al verificatore di identificare le anomalie, anche se solo a posteriori. Nello scenario 3 la rilevabilità scompare durante la finestra di rischio — un attaccante con la chiave di un dipendente legittimo è indistinguibile dal dipendente stesso per qualsiasi strumento automatico. Nello scenario 4 la gravità diventa critica non per le azioni immediate — identiche allo scenario 3 nella versione iniziale — ma per le implicazioni nel modello proposto: la compromissione dell'amministratore non riguarda un singolo progetto ma l'intera struttura di fiducia della #gl("repository"), inclusa la capacità di nominare e revocare responsabili, modificare le policy di sicurezza e accedere a qualsiasi progetto cifrato.

Questa progressione non lineare della gravità è esattamente la motivazione per cui il modello proposto introduce la separazione tra chiave master e chiave operativa: limitare le conseguenze della compromissione della chiave operativa a uno scenario recuperabile, preservando attraverso la chiave master la possibilità di ristabilire la catena di fiducia senza perdere il controllo della #gl("repository").

=== Corrispondenza con i requisiti del modello

I risultati degli scenari confermano empiricamente la classificazione dei requisiti stabilita nel @cap:modello-sicurezza. Ogni vulnerabilità documentata corrisponde a uno o più requisiti assenti nella versione iniziale:

#figure(caption: "Corrispondenza tra vulnerabilità osservate e requisiti del modello.")[
  #table(
    columns: (1fr, auto, auto),
    table.header([*Vulnerabilità osservata*], [*Scenario*], [*Requisiti*]),
    [Firma opzionale — storia riscrivibile senza errori critici], [S1 T4, T5], [RS06],
    [Nessuna radice di fiducia — #gl("repository") fasulla indistinguibile], [S1 T10], [RS05],
    [Nessuna lista autorizzati — accesso non controllato per progetto], [S2], [RS07, RS08],
    [Nessuna revoca operativa — finestra di rischio non gestita], [S3], [RS09],
    [Nessuna gerarchia — compromissione admin identica a dipendente], [S4], [RS07, RS10],
    [Nessuna separazione master/operativa — perdita controllo totale], [S4], [RS05, RS10],
  )
]

Tutti i requisiti classificati come assenti nell'analisi del divario del @cap:modello-sicurezza trovano una corrispondenza diretta in almeno una delle tecniche documentate in questo capitolo. I requisiti RS01 e RS02, classificati come parziali, sono confermati: la catena degli #gl("hash") funziona correttamente quando i file non vengono sostituiti interamente, ma non costituisce una protezione sufficiente in assenza di firma obbligatoria. Questi risultati definiscono con precisione la priorità degli interventi descritti nel capitolo successivo.