/* Questo file serve per:
- Gestire i capitoli
- Gestire lo stile e la numerazione del conteggio delle pagine
*/

// Frontmatter
#include "preface/firstpage.typ"
#include "preface/copyright.typ"

#set page(numbering: "i")
#include "preface/dedication.typ"

#include "preface/summary.typ"
#include "preface/table-of-contents.typ"

// Mainmatter
#set page(numbering: none)
#pagebreak(to: "odd")
#counter(page).update(1)
#set page(numbering: "1.")
#include "chapters/1_Introduzione.typ"
#include "chapters/2_Descrizione dello stage.typ"
#include "chapters/3_Tecnologie e fondamenti teorici.typ"
#include "chapters/4_Analisi del codice sorgente.typ"
#include "chapters/5_Simulazione scenari di attacco.typ"
#include "chapters/6_Miglioramenti implementati.typ"
#include "chapters/7_Conclusioni.typ"

// #include "docs/esempi.typ"

// Backmatter
#include "appendix/glossary/glossary.typ"
// #include "appendix/bibliography/bibliography.typ"
#include "preface/acknowledgements.typ"

/*
Capitolo 1 — Introduzione
  - L'azienda
  - Il progetto RVC
  - Scelta e motivazioni
  - Obiettivi
  - Pianificazione
  - Analisi dei rischi  

Capitolo 2 — Descrizione dello stage
  - Organizzazione del lavoro
  - Ambiente di sviluppo e strumenti
  - Vincoli tecnologici
  - Approccio metodologico

Capitolo 3 — Tecnologie e fondamenti teorici
  - Crittografia asimmetrica e firma digitale
  - SSH e ssh-keygen
  - AGE
  - Git e RVC a confronto
  - RVC: architettura e funzionamento

Capitolo 4 — Analisi del codice sorgente
  - Struttura dei file CPL
  - Vulnerabilità individuate
  - Threat modeling e MITRE ATT&CK

Capitolo 5 — Simulazione scenari di attacco
  - Attacchi senza credenziali
  - Attacchi con chiave privata compromessa
  - Attacchi con chiave capo progetto
  - Propagazione nella catena

Capitolo 6 — Miglioramenti implementati
  - Sistema di configurazione dinamico
  - Firma SSH obbligatoria
  - Verifica integrità della catena
  - Allowed signers

Capitolo 7 — Conclusioni
  - Obiettivi raggiunti
  - Riflessione personale
  - Sviluppi futuri
*/
