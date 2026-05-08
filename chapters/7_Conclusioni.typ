#import "data/requirements_list.typ": *
#import "../config/variables.typ": *
#pagebreak(to:"odd")

= Conclusioni<cap:conclusioni>
#text(style: "italic", [
    In questo capitolo traggo le conclusioni sul progetto.
])
#v(1em)
== Consuntivo finale
Una volta terminato il progetto ho redatto il consuntivo orario finale nella @fig:tabella-calcolo-ore che suddivide in maniera approssimata le ore dedicate alle varie fasi.
#v(1em)
#set table(
  align: (center+horizon, center+horizon), 
)
#figure(
  caption: [Consuntivo orario finale.],
  table(
    columns: 2,
    table.header([*Fase*], [*Ore*]),
    [_Onboarding_ del progetto],[5],
    [Analisi dei requisiti],[30],
    [...], [...],
    [*Totale*],[320]
  )
)<fig:tabella-calcolo-ore>
#v(1em)

== Raggiungimento degli obiettivi

== Requisiti soddisfatti
Arrivato alla fine del progetto ho implementato...
#v(1em)
#figure(
  table(
    columns: (auto, 1fr, 1fr, auto, auto),
    table.header([*Tipo*], [*Mandatory*], [*Desirable*],[*Optional*], [*Somma*]),
    [Functional], [0/#getFR(getLen: true).at(0)], [0/#getFR(getLen: true).at(1)], [0/#getFR(getLen: true).at(2)], [0/#getFR(getLen: true).sum()],
    [Qualitative], [0/#getQR(getLen: true).at(0)], [0/#getQR(getLen: true).at(1)], [0/#getQR(getLen: true).at(2)], [0/#getQR(getLen: true).sum()],
    [Constraint], [0/#getCR(getLen: true).at(0)], [0/#getCR(getLen: true).at(1)], [0/#getCR(getLen: true).at(2)], [0/#getCR(getLen: true).sum()],
    [*Totale*],
      [*0/#{getFR(getLen: true).at(0)+getQR(getLen: true).at(0)+getCR(getLen: true).at(0)}*],
      [*0/#{getFR(getLen: true).at(1)+getQR(getLen: true).at(1)+getCR(getLen: true).at(1)}*],
      [*0/#{getFR(getLen: true).at(2)+getQR(getLen: true).at(2)+getCR(getLen: true).at(2)}*],
      [*0/#{getFR(getLen: true).sum()+getQR(getLen: true).sum()+getCR(getLen: true).sum()}*],
    align: (center+horizon)
  ),
  caption: "Riepilogo dei requisiti soddisfatti."
)<tab:requisiti-soddisfatti>
== Rischi occorsi e mitigati
I rischi emersi durante lo stage sono riportati in @fig:rischi-occorsi.\
#v(1em)
#figure(
  caption: [Rischi occorsi con la loro mitigazione.],
  table(
    columns: 2,
    table.header([*Descrizione*],[*Mitigazione*]),
    [*R1* -- Descrizione del rischio],[Soluzione]
  )
)<fig:rischi-occorsi>
#v(1em)
== Valutazione personale

== Sviluppi futuri
=== Permessi per branch
Il modello attuale definisce i permessi a livello di progetto tramite il file allowed_Dipendenti, valido su tutti i branch. Un'estensione naturale sarebbe permettere liste di autorizzati diverse per branch diversi, consentendo ad esempio di limitare i commit sul branch principale a un sottoinsieme dei dipendenti del progetto. Questa estensione introduce però complessità gestionale significativa — in particolare nella gestione delle merge tra branch con liste diverse — e richiederebbe una definizione formale di quale allowed_Dipendenti prevalga in caso di conflitto. Per questi motivi è stata identificata come sviluppo futuro piuttosto che requisito del modello corrente.

=== Gestione fork
Un'altra possibile estensione del modello è la gestione dei fork, che permetterebbe a sviluppatori esterni al progetto di creare una copia del repository per proporre modifiche tramite pull request. Questo richiederebbe l'introduzione di un nuovo tipo di entità (il fork) e di nuove regole per la gestione dei permessi e delle merge tra repository diversi. Anche questa estensione è stata identificata come sviluppo futuro a causa della complessità aggiuntiva che comporterebbe.

=== Propagazione automatica della redazione
Il meccanismo di Redazione Trasparente nella sua forma attuale rimuove il contenuto problematico dalla repository ma non può raggiungere le copie già scaricate sui dispositivi locali — limitazione strutturale di qualsiasi sistema distribuito. Un'estensione naturale è la propagazione automatica della redazione: quando il motore riceve un aggiornamento contenente un .sig con redacted: true firmato dalla chiave master, sostituisce ed elimina automaticamente il vecchio ZIP locale, diventando a sua volta vettore della redazione verso i client successivi. Il meccanismo si propaga con la normale sincronizzazione della repository, analogamente a un vaccino che si diffonde attraverso la rete di contatti. Questa estensione risolve la limitazione residua ma introduce questioni di governance — in particolare la dipendenza dalla correttezza del motore su ogni client e l'irrevocabilità della propagazione in caso di redazione errata — che richiedono riflessione ulteriore prima dell'adozione.