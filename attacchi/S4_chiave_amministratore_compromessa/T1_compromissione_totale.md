# T1 — Compromissione totale e silenziosa

## Scenario padre
S4 — Chiave operativa dell'amministratore compromessa

## Descrizione
L'attaccante usa la chiave operativa dell'amministratore per
produrre commit su più progetti della repository. Il motore
accetta tutto senza distinzione. Il verificatore segnala tutti
i commit come validi perché la chiave è presente nell'
allowed_signers. Nessun meccanismo automatico distingue
questa situazione dalla normale attività dell'amministratore.

Questa tecnica dimostra che nella versione iniziale la
compromissione dell'amministratore non è più grave — dal punto
di vista dei controlli tecnici — della compromissione di
qualsiasi altro utente. La differenza emerge solo nel modello
proposto, dove l'amministratore ha poteri esclusivi che
nessun altro soggetto possiede.

## Prerequisiti
- Chiave privata SSH dell'amministratore
- Accesso in scrittura alla cartella della repository
- Repository di test nello stato iniziale pulito

## Passi dell'attacco
1. Produrre commit su più progetti diversi firmati con
   la chiave dell'amministratore
2. Verificare che tutti i commit siano accettati dal motore
3. Eseguire il verificatore
```bash
C:\Users\stemic\stage\simulazione>..\..\rvc\cpl rvc integrity -signers="C:\Users\stemic\stage\allowed_signers"

Verifica integrita repository: tutti i progetti
allowed_signers: C:\Users\stemic\stage\allowed_signers

analyzing repository C:\Users\stemic\stage\repo\ ...
[OK]  0Q6PHT7QCI  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHV1YTU  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHW0IJW  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHWPMPQ  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6WWOWTGV  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6WWP3QDM  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6WWP4TNH  hash:OK  catena:OK  firma:OK  (Michele)

Risultato: 0/8 commit con problemi.
Risultato: 0/8 commit con warning.
tot. exec time: 1.78 sec
```
4. Documentare che tutti i commit risultano validi e
   indistinguibili da quelli legittimi dell'amministratore

## Risultato atteso
Il motore accetta tutti i commit senza avvisi. Il verificatore
segnala [OK] su tutti i commit — hash, catena e firma sono
validi. Nessun meccanismo automatico rileva la compromissione.
Il risultato è identico allo scenario 3 — la versione iniziale
non distingue tra ruoli.

## Risultato osservato (versione iniziale)
La compromissione della chiave risulta nell'accettazione dei commit come con la compromissione
di qualsiasi altra chiave. 

## Analisi dell'impatto — versione iniziale
Nella versione iniziale l'impatto è identico alla compromissione
di qualsiasi altra chiave — alto ma non qualitativamente diverso.
Non è rilevabile né dal motore né dal verificatore in modo
automatico. L'unica contromisura è procedurale.

## Analisi dell'impatto — modello proposto
Nel modello proposto la compromissione della chiave operativa
dell'amministratore è lo scenario più critico in assoluto perché:

- L'attaccante può modificare allowed_Responsabili in _rvc_root —
  aggiungendo identità false o rimuovendo responsabili legittimi
- L'attaccante può produrre commit amministrativi su qualsiasi
  progetto senza nessun vincolo di appartenenza
- L'attaccante può degradare o alterare le policy di sicurezza
  di qualsiasi progetto
- L'attaccante può revocare l'accesso a dipendenti legittimi
  su qualsiasi progetto

Queste azioni compromettono non solo la repository attuale ma
l'intera struttura di fiducia — incluse le autorizzazioni
future di tutti i soggetti.

## Contromisure architetturali nel modello proposto
Il modello proposto affronta questo scenario con due meccanismi:

**Separazione chiave master / chiave operativa** — la chiave
master è conservata offline su un dispositivo air-gapped e
non viene mai usata nelle operazioni ordinarie. La compromissione
della chiave operativa non comporta la perdita del controllo
della repository — la chiave master può revocare la chiave
operativa compromessa e nominarne una nuova senza perdere
la catena di fiducia.

**Revoca con chiave master** — il commit di revoca firmato
con la chiave master è l'unico meccanismo che può ristabilire
le garanzie di sicurezza dopo la compromissione della chiave
operativa. Questo commit è riconosciuto dal motore come
autoritativo anche se la chiave master non è in allowed_Dipendenti
— è il meccanismo eccezionale descritto nella sezione sulla
compromissione della chiave dell'amministratore nel capitolo 4.

Queste contromisure non eliminano la finestra di rischio tra
compromissione e revoca, ma la limitano e garantiscono la
possibilità di recupero completo senza perdere la catena
di fiducia.

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito coinvolto: RS05, RS07, RS08, RS09, RS10
- Proprietà violata: Autenticità, Autorizzazione, Radice di fiducia
- Obiettivo stage: D01