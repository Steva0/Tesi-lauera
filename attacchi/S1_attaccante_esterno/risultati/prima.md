# Risultati pre-implementazione — S1 Attaccante esterno

| Tecnica | Rilevata dal verificatore | Bloccata dal motore | Impatto | Requisiti violati |
|---------|--------------------------|---------------------|---------|-------------------|
| T1 commit senza firma         | WARN | No | Alto   | RS06 |
| T2 identità falsa             | WARN | No | Alto   | RS06 |
| T3 modifica ZIP               | -    | -  | -      | RS01, RS02 |
| T4 sostituzione ZIP e .sig    | -    | -  | -      | RS01, RS02 |
| T5 inserimento in mezzo       | -    | -  | -      | RS02, RS03 |
| T6 replay commit              | -    | -  | -      | RS02, RS03 |
| T7 modifica .sig              | -    | -  | -      | RS06 |
| T8 troncamento catena         | -    | -  | -      | RS02 |
| T9 cumulativeHash falsificato | -    | -  | -      | RS02, RS03 |
| T10 repository fasulla        | -    | -  | -      | RS05 |

## Note generali
[da compilare dopo i test]