# Risultati pre-implementazione — S3 Chiave dipendente compromessa

| Tecnica | Verificatore (con chiave) | Verificatore (senza chiave) | Bloccata dal motore | Requisiti coinvolti |
|---------|--------------------------|----------------------------|---------------------|---------------------|
| T1 commit fraudolento indistinguibile | - | - | - | RS09 |
| T2 commit durante finestra di rischio | - | - | - | RS09 |
| T3 propagazione dopo revoca           | - | - | - | RS09 |

## Limitazione documentata
Il verificatore attuale usa un file allowed_signers esterno e
statico. Il comportamento osservato con allowed_signers_senza_chiave
differisce da quello del modello proposto, dove i commit prodotti
prima della revoca rimarrebbero validi perché la lista interna
al commit includeva la chiave al momento della firma.