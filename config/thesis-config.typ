#import "@preview/glossarium:0.5.9": make-glossary, register-glossary, print-glossary, gls, glspl, gls-short, gls-description
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#import "../config/constants.typ": chapter, appendix
#import "../appendix/glossary/terms.typ": glossary-terms

// This file sets up the properties of the document and the libraries used

#let config(
  myAuthor: "Michele Stevanin",
  myMatricola: "",
  myTitle: "Analisi di sicurezza e integrità crittografica di un sistema di versionamento distribuito",
  myLang: "it",
  myNumbering: "1.1",
  body,
) = {
  // Set the document's basic properties (PDF/A metadata)
  set document(
    author: myAuthor,
    title: myTitle,
    keywords: ("RVC", "sicurezza", "crittografia", "versionamento", "SSH", "firma digitale"),
  )

  // Codly bootstrap and setup
  show: codly-init.with()
  codly(
    languages: (
      ..codly-languages,
      CPL: (name: "CPL", color: rgb("#6b9bd2"), icon: none),
    ),
    zebra-fill: gray.lighten(90%)
  )

  // Page and typography settings
  // Interlinea 1.5 come da specifiche FIUP
  set page(
    margin: 3cm,
    numbering: myNumbering,
    number-align: center,
  )
  set par(
    leading: 1em,
    spacing: 1.2em,
    justify: true,
  )
  set text(
    font: "New Computer Modern",
    lang: myLang,
    size: 11pt,
  )
  set heading(numbering: myNumbering)

  // Codice monospaziato
  show raw: set text(font: "DejaVu Sans Mono", size: 10pt)

  // Spaziatura headings — struttura accessibile
  show heading: set block(above: 2em, below: 1.4em)

  // Heading di livello 1 con numero capitolo in evidenza
  show heading.where(level: 1): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    stack(
      spacing: 2em,
      if it.numbering == "A.1" {
        text(size: 1.5em, weight: "bold")[#appendix #counter(heading).display()]
      } else if it.numbering != none {
        text(size: 1.5em, weight: "bold")[#chapter #counter(heading).display()]
      },
      text(size: 1.7em, weight: "bold", it.body),
      [],
    )
  }

  // Liste con simboli accessibili
  set list(marker: (sym.bullet, sym.dash))

  // Tabelle accessibili:
  // - testo allineato a sinistra
  // - righe alternate per leggibilità (senza affidarsi solo al colore)
  // - inset generoso per leggibilità
  set table(
    inset: 10pt,
    align: left,
    fill: (x, y) => {
      if y == 0 {
        rgb(220, 220, 220)  // grigio chiaro invece di scuro
      } else if calc.odd(y) {
        white
      } else {
        rgb(235, 235, 235)
      }
    },
    stroke: (x, y) => (
      bottom: 0.5pt + gray.darken(20%),
    ),
  )

  // Intestazione tabella: testo bianco su sfondo scuro per contrasto accessibile
  show table.cell.where(y: 0): set text(fill: black, weight: "bold")

  // Figure: spazio attorno, caption accessibile con numero senza prefisso
  // Numerazione: 1.1, 1.2 ... per figure e tabelle (senza "Figura" o "Tabella")
  set figure(
    supplement: none,
    numbering: (..nums) => {
      let chapter-num = counter(heading.where(level: 1)).get().first()
      let fig-num = nums.pos().last()
      [#chapter-num.#fig-num]
    },
    gap: 1em,
  )
  show figure: it => {
    v(1em)
    block(breakable: false, it)
    v(1em)
  }

  // Caption delle figure: allineata a sinistra, testo leggermente ridotto
  show figure.caption: it => {
    set text(size: 0.9em)
    set align(center)
    it
  }

  // Immagini: accessibilità — alt text tramite il parametro label di #figure
  // Ricorda di usare sempre #figure(image(..., alt: "descrizione"), caption: "...") nei capitoli

  // Link cliccabili e visibili (colore accessibile, non solo sottolineatura)
  show link: set text(fill: rgb(0, 80, 160))

  show outline: it => {
    show link: set text(fill: black)
    it
  }

  show outline: it => {
    show link: set text(fill: black)
    // Nasconde lo stile glossario nell'indice
    show text.where(style: "italic"): it => text(style: "normal", fill: black, it)
    it
  }

  // Glossary bootstrap and setup
  show: make-glossary
  register-glossary(glossary-terms)

  body
}

// ── Wrapper Glossarium ──────────────────────────────────────────────────────
// Stile: corsivo + colore identificativo + apice G
// Il colore rgb(155, 0, 20) ha contrasto sufficiente su sfondo bianco (ratio ~5.5:1)

#let glossary-style(body) = {
  // Sovrascrive il colore base dei link solo qui dentro
  show link: set text(fill: rgb(155, 0, 20))
  // Aggiunge la sottolineatura ai link
  show link: underline
  
  // Applica corsivo e rosso a tutto (compresa la G)
  text(
    style: "italic", 
    fill: rgb(155, 0, 20), 
    body + sub[G]
  )
}

#let gl(
  key,
  suffix: none,
  long: false,
  display: none,
  link: true,
  update: true,
  capitalize: false,
) = glossary-style(
  gls(
    key,
    suffix: suffix,
    long: long,
    display: display,
    link: link,
    update: update,
    capitalize: capitalize,
  )
)

#let glpl(
  key,
  long: false,
  link: true,
  update: true,
  capitalize: false,
) = glossary-style(
  glspl(
    key,
    capitalize: capitalize,
    link: link,
    long: long,
    update: update,
  )
)

// Utile per quando si introducono le tecnologie (link + corsivo + footnote con URL)
#let linkfn(url, body) = (
  link(url, text(style: "italic", fill: rgb(0, 80, 160), body)) + footnote(link(url))
)
