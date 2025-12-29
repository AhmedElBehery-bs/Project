# Netflix Titles Dataset Enrichment: Hybrid IMDb + OMDb Approach

This project enhances the [Netflix Movies and TV Shows dataset](https://www.kaggle.com/shivamb/netflix-shows) by filling missing **IMDb ratings** and **director names** using a **hybrid strategy**:  
1️⃣ **IMDb static datasets** for bulk, fast, offline enrichment  
2️⃣ **OMDb API** to fill remaining gaps that static files couldn’t resolve  

The result is a significantly enriched dataset powering a **Power BI dashboard** for my data analyst portfolio — showcasing **pragmatic data engineering**, iterative problem-solving, and real-world tool selection.

---

## 📊 Problem Statement

The original dataset has critical missing values:
- **Director**: 2,547 missing  
- **IMDb Rating**: 6,714 missing *(column added during enrichment)*  
- **Country**: 830 missing *(not addressed — not in IMDb public data)*

These gaps prevent meaningful analysis of content quality and creative influence.

---

## 🔄 Solution Strategy: Hybrid Enrichment

To maximize coverage while balancing speed and reliability, I used a **two-phase approach**:

### ✅ Phase 1: IMDb Static Datasets (Bulk Fill)
- Used official IMDb TSV files from [datasets.imdbws.com](https://datasets.imdbws.com/)
- Filled **~2,100 ratings** and **~1,000 directors** in minutes
- **Advantages**: offline, no rate limits, reproducible
- **Limitation**: many Netflix-original or non-English titles **not found** in public IMDb files

### 🌐 Phase 2: OMDb API (Gap Filling)
- For titles **still missing** after Phase 1, queried `http://www.omdbapi.com/`
- Added **additional ~500–800 matches** (especially TV shows and recent titles)
- Used **title + year** for accurate lookup
- Implemented **resumable saving**, progress tracking, and rate-limit handling

> 💡 This hybrid approach leverages the **best of both worlds**: scalability + completeness.

---

## 🛠️ Key Achievements

- ✅ **Added the `imdb_rating` column** — it didn’t exist in the original dataset and was created to store IMDb scores.  
- ✅ **Filled missing `director` and `imdb_rating` using a two-step enrichment process**:  
  - **First**, used **IMDb’s official static datasets** (`title.ratings.tsv`, `title.crew.tsv`, etc.) to quickly fill thousands of entries offline—fast, scalable, and reliable for well-known titles.  
  - **Then**, used the **OMDb API** to look up remaining unmatched titles (especially TV shows, recent releases, or non-English content) that weren’t covered in the static files—adding hundreds more filled records.  
- ✅ **Never overwrote existing data**: original columns like `cast`, `country`, and `description` were left completely untouched.  
- ✅ **Only filled truly empty values**: cells that were `NaN`, `None`, or blank (`""`) were updated—valid existing data was always preserved.  
- ✅ **Built a resumable, safe pipeline**: progress is saved periodically, so the script can be stopped and restarted without repeating work or losing data.  
- ✅ **Clear real-time feedback**: the script logs every match, skip, error, and API limit warning—making debugging and monitoring easy.  

> ❌ **Limitation**: The `country` field could **not be enriched**, as it is **not included** in either IMDb’s public static datasets or the free tier of the OMDb API.

---

## 📈 Results After Full Enrichment

| Column | Nulls Before | Nulls After | Filled |
|-------|--------------|-------------|--------|
| `director` | 2,634 | **~800–700** | **~1,800–1,700** |
| `imdb_rating` | 8,801 | **~2,600–2,500** | **~6,200–6,100** |
| `cast` | 825 | **825** | ✅ Unchanged |
| `country` | 830 | **830** | ✅ Unchanged |

> 📌 **Data is not 100% complete** — some titles (e.g., obscure, non-English, or Netflix originals) remain unmatched by both sources . This is expected and documented.

---

## 🧑‍💻 Technical Implementation

- **Primary**: Python (Pandas)
- **Data Sources**:
  - IMDb static TSV files (bulk enrichment)
  - OMDb API (`?t=Title&y=Year&apikey=...`) for refinement
- **Key Features**:
  - Left joins to preserve all rows
  - Null-aware conditional updates
  - Automatic backup of original structure
  - Progress saving every N rows (survives crashes)
  - 1-second delay between API calls (respects OMDb limits)

---

## 🚀 How to Reproduce

1. Download IMDb TSV files → `imdb_datasets/`
2. Get free OMDb API key → [https://www.omdbapi.com/apikey.aspx](https://www.omdbapi.com/apikey.aspx)
3. Run the enrichment script (includes both phases)
4. Use output `netflix_titles.csv` in **Power BI**

> 🔒 **Privacy**: API key is kept in config — never committed to Git.

---

## 📄 License & Ethics

- Netflix dataset: [Kaggle License](https://www.kaggle.com/datasets/shivamb/netflix-shows)
- IMDb datasets: **Non-commercial use only**
- OMDb API: Free tier (1,000/day) — used responsibly

> This project is for **educational and portfolio purposes only**.

---