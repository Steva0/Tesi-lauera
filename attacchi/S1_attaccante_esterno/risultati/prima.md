# Risultati pre-implementazione — S1 Attaccante esterno

| Tecnica | Rilevata dal verificatore | Bloccata dal motore | Impatto | Requisiti violati |
|---------|--------------------------|---------------------|---------|-------------------|
| T1 commit senza firma         | WARN | No | Alto   | RS06 |
| T2 identità falsa             | WARN | No | Alto   | RS06 |
| T3 modifica ZIP               | ERR  | No | Basso  | RS01, RS02 |
| T4 sostituzione ZIP e .sig    | WARN | No | Alto   | RS01, RS02 |
| T5 inserimento in mezzo       | WARN | No | Medio  | RS02, RS03 |
| T6 replay commit              | ERR  | No | Basso  | RS02, RS03 |
| T7 modifica .sig              | ERR  | No | Nullo  | RS06 |
| T8 troncamento catena         | ERR  | No | Nullo  | RS02 |
| T9 cumulativeHash falsificato | ERR  | No | Basso  | RS02, RS03 |
| T10 repository fasulla        | WARN | No | Alto   | RS05 |

## Note generali
[da compilare dopo i test]