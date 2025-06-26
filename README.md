# HIV & ECD Intervention Program: Annual Program Review (APR) Scripts

This repository contains Stata do-files used to process and analyze program data for the **Annual Program Review (APR)** of a combined **HIV and Early Childhood Development (ECD)** intervention. The APR aims to assess program performance across key domains, including the **HIV 95-95-95 targets**, **HIV prevention**, **program retention**, and **ECD outcomes**.

---

## 🎯 Project Purpose

- To harmonize and integrate data from **multiple form types** (e.g., caregiver, child, adolescent).
- To ensure compatibility between **old and new versions** of program data collection tools.
- To generate program indicators and summaries used in the APR.
- To support evidence-based decision-making for program improvement and stakeholder reporting.

---

## 📁 Repository Structure
There are two sets of do-files - one for data preprocessing and another for analysis
### `import_clean_merge/`

These do-files are for:

- Importing raw data collected using different versions of program forms (e.g., caregiver, infant, child/adolescent).
- Renaming and harmonizing variables across **old and new form versions**.
- Merging all relevant datasets into a single **integrated dataset** for analysis.
- Creating **derived variables** from raw fields to support indicator calculations.

**Key Input Forms:**
- Caregiver (Mother) Form – old and new
- Infant Form – old and new
- Child/Adolescent Form – old and new

### `analysis/`

These do-files for domain-specific analysis:

- **HIV 95-95-95 cascade** (testing, treatment, viral suppression)
- **HIV prevention indicators**
- **Program retention** metrics across time and demographic groups
- **ECD outcome measures**, including developmental milestones and risk factors
- Indicator calculation and summary table generation for APR reporting

---
