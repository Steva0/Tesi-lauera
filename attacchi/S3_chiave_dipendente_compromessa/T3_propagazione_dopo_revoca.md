# T3 — Propagazione nella catena dopo la revoca

## Scenario padre
S3 — Chiave privata di un dipendente compromessa

## Descrizione
Dopo che la chiave compromessa viene rimossa dall'allowed_signers,
il verificatore rieseguito sull'intera storia mostra due
comportamenti distinti a seconda del file used: con
allowed_signers_con_chiave i commit fraudolenti risultano validi,
con allowed_signers_senza_chiave risultano FAIL. Questo dimostra
la differenza tra il verificatore attuale — che usa una lista
statica — e il modello proposto — dove ogni commit porta la
lista valida al momento della firma.

L'obiettivo è documentare che i commit fraudolenti rimangono
nella catena e sono identificabili tramite analisi manuale
della storia nel periodo sospetto, come descritto nel modello.

## Prerequisiti
- Repository con commit legittimi e commit fraudolenti prodotti
  durante la simulazione di T2
- File allowed_signers_con_chiave e allowed_signers_senza_chiave

## Passi dell'attacco
1. Partire dalla repository prodotta in T2 con commit misti
   legittimi e fraudolenti
2. Eseguire il verificatore con allowed_signers_con_chiave —
   documentare quali commit risultano validi
3. Eseguire il verificatore con allowed_signers_senza_chiave —
   documentare quali commit risultano FAIL
4. Confrontare i due output e identificare i commit fraudolenti
5. Verificare che la catena degli hash rimanga intatta
   indipendentemente dalla validità delle firme

## Risultato atteso
Con allowed_signers_con_chiave: tutti i commit risultano [OK]
inclusi quelli fraudolenti — la catena è integra e le firme
sono valide rispetto alla lista che include la chiave.
Con allowed_signers_senza_chiave: i commit fraudolenti
risultano [FAIL] firma, quelli legittimi rimangono [OK].
La catena degli hash risulta intatta in entrambi i casi —
i commit fraudolenti non hanno alterato la struttura
crittografica della storia.

Questo evidenzia la limitazione del verificatore attuale
rispetto al modello proposto e dimostra perché l'allowed_Dipendenti
interno a ogni commit è una scelta architetturale necessaria.

## Risultato osservato (versione iniziale)
[da compilare]

## Analisi dell'impatto
[da compilare]

## Contromisura implementata
[da compilare]

## Risultato osservato (dopo implementazione)
[da compilare]

## Riferimenti
- Requisito coinvolto: RS09
- Proprietà violata: Autenticità, Non ripudio
- Limitazione documentata: differenza tra verificatore attuale
  e modello proposto nella gestione della revoca retroattiva