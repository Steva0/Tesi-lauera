# Stato iniziale della repository di test

Questo documento descrive lo stato della repository prima
dell'esecuzione di qualsiasi test. Prima di ogni tecnica
la repository viene ripristinata a questo stato tramite
la copia di backup `stato_iniziale_pulito/`.

## Struttura dei commit

| ID | Operazione | File coinvolto |
|----|------------|----------------|
| 0Q6PHT7QCI | Aggiunta | file.txt |
| 0Q6PHUAOSV | Modifica | file.txt |
| 0Q6PHV1YTU | Aggiunta | fileNuovo.txt |
| 0Q6PHW0IJW | Modifica | fileNuovo.txt |
| 0Q6PHWPMPQ | Aggiunta | fileSuperPrivato.txt |

## Output del verificatore sullo stato iniziale

```bash
rvc integrity -signers="C:\Users\stemic\stage\allowed_signers"
Verifica integrita repository: tutti i progetti
allowed_signers: C:\Users\stemic\stage\allowed_signers
analyzing repository C:\Users\stemic\stage\repo\ ...
[OK]  0Q6PHT7QCI  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHUAOSV  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHV1YTU  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHW0IJW  hash:OK  catena:OK  firma:OK  (Michele)
[OK]  0Q6PHWPMPQ  hash:OK  catena:OK  firma:OK  (Michele)
Risultato: 0/5 commit con problemi.
Risultato: 0/5 commit con warning.
```

## Note
- Tutti i commit sono firmati con la chiave SSH di Michele
- Il file allowed_signers contiene la chiave pubblica di Michele
- Branch principale: master-simulazione
- Progetto: simulazione