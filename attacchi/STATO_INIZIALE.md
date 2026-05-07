# Stato iniziale della repository di test

Questo documento descrive lo stato della repository prima
dell'esecuzione di qualsiasi test. Prima di ogni tecnica
la repository viene ripristinata a questo stato tramite
la copia di backup `stato_iniziale_pulito/`.

## Struttura dei commit

| ID | Operazione | File coinvolto |
|----|------------|----------------|
| 0Q6PFBCITQ | Aggiunta | file.txt |
| 0Q6PFCSTYO | Modifica | file.txt |
| 0Q6PFDXALZ | Aggiunta | FileSuperPrivato.txt |
| 0Q6PFFWYUY | Modifica | FileSuperPrivato.txt |
| 0Q6PFI6GHY | Aggiunta | fileNuovo.txt |

## Output del verificatore sullo stato iniziale

```bash
rvc integrity -signers="C:\Users\stemic\stage\allowed_signers"
Verifica integrita repository: tutti i progetti
allowed_signers: C:\Users\stemic\stage\allowed_signers
analyzing repository C:\Users\stemic\stage\repo\ ...
[OK]  0Q6PFBCITQ  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PFCSTYO  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PFDXALZ  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PFFWYUY  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PFI6GHY  hash:OK  catena:OK  firma:OK  (Michele)
Risultato: 0/5 commit con problemi.
Risultato: 0/5 commit con warning.
```

## Note
- Tutti i commit sono firmati con la chiave SSH di Michele
- Il file allowed_signers contiene la chiave pubblica di Michele
- Branch principale: master-simulazione
- Progetto: simulazione