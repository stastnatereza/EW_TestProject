# EW - Test Project

### **Project Overview**
Smyslem testovacího projektu byl ingest dat ze zdrojových souborů, jejich následná transformace a příprava dat pro zodpovězení business otázek pomocí reportů. Cílem tedy bylo připravit takový návrh architektury, která bude připravena pro denní aktualizaci ve všech vrstvách. K celému procesu je vypracována stručná dokumentace.

---
### **Architecture Solution**
- Technologická platforma: MS Fabric (reporting Power BI)
- Architektura: Medallion
- Zdroj dat: soubory v různých formátech (.txt, .xlsx, .csv)

| Layer | Description |
| ----------- | ----------- |
| BRONZE (raw) | Raw data ze zdrojových souborů, uložená bez transformací (struktura stejná jako na zdroji) |
| SILVER (cleansed) | Vyčištěná, opravená a transformovaná data z bronze vrstvy |
| GOLD (reporting) | Data připravená pro následných reporting - zodpovězení business otázek |

- Vzorový task flow:
  - Get data: nejprve je nutné provést ingest dat ze zdrojových systémů/souborů
  - Store data (BRONZE): data v neměnné struktuře nahrána do úložiště
  - Prepare data: prostor pro transformace/úpravy dat z bronze vrstvy
  - Store data (SILVER): data již v upravené struktuře nahrána do úložiště
  - Prepare data: příprava business-ready dat pro vizualizace
  - Store data (GOLD): data připravené přímo pro vizualizace, nahrána do úložiště
  - Visualize: reporting nad daty z gold vrstvy

![Task Flow](images/TaskFlow.jpg)

- Shrnutí architektury: zdrojové soubory -> Bronze (Lakehouse) -> čištění a transformace dat -> Silver (Warehouse schema) -> transformace dat pro reporting -> Gold (Warehouse schema) -> Power BI)

---
### **Data Ingestion (BRONZE)**
- Ingest dat ze zdrojových systémů v různých formátech (.txt, .xlsx, .csv)
  -  DS1_Customers.txt
  -  DS2_Invoices.xlsx
  -  DS3_Payments.csv
- Pro ukázku práce s MS Fabric použit pro každý soubor jiný způsob ingestu
  - Ingest Customers (dataflow):
    - Rozhraní dataflow vychází z klasického Power Query - vhodné řešení pro pracovníky, kteří chtějí no-code řešení a dobře znají prostředí Power Query (nicméně nevýhodou náročnost na spotřebu CU a méně možností)
  - Ingest Invoices (pipeline - copy data activity):
    - Velmi jednoduché nastavení source/destination
  - Ingest Payments (PySpark notebook):
    - Mnoho možností s využitím PySpark
- Data vždy načtena v originální podobě bez úprav a změn datových typů
    
---
### **Data Quality & Cleansing (SILVER)**
POPSAT DATOVOU KVALITU A PROCES ČIŠTĚNÍ

---
### **Reporting (GOLD)**
- Pro reporting využito klasické star schema
- Model připraven do klasického sémantického modelu v rámci MS Fabric pro následný reporting pomocí Power BI

---
### **Orchestration**
SCREEN PIPELINY
