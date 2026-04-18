# SQL Data Analytics Project

A hands-on SQL analytics project built on a fictional bike company's data warehouse.
Covers everything from database setup to advanced reporting views.

---

## Project Structure

```
sql-analytics-guide/
├── datasets/
│   └── flat-files/
│       ├── dim_customers.csv
│       ├── dim_products.csv
│       └── fact_sales.csv
├── scripts/
│   ├── 00_init_database.sql
│   ├── 01_database_exploration.sql
│   ├── 02_dimensions_exploration.sql
│   ├── 03_date_range_exploration.sql
│   ├── 04_measures_exploration.sql
│   ├── 05_magnitude_analysis.sql
│   ├── 06_ranking_analysis.sql
│   ├── 07_change_over_time_analysis.sql
│   ├── 08_cumulative_analysis.sql
│   ├── 09_performance_analysis.sql
│   ├── 10_data_segmentation.sql
│   ├── 11_part_to_whole_analysis.sql
│   ├── 12_report_customers.sql
│   ├── 13_report_products.sql
│   └── mysql/               ← MySQL-compatible versions of all scripts
├── .gitignore
└── README.md
```

---

## Prerequisites

**SQL Server (default scripts)**
- SQL Server 2019+ or SQL Server Express (free)
- SQL Server Management Studio (SSMS) or Azure Data Studio

**MySQL (alternative)**
- MySQL 8.0+
- MySQL Workbench or any MySQL client

---

## How to Run

### Step 1 — Clone the repo

```bash
git clone https://github.com/ganeshreddymaredla/sql-data-analytics-project.git
cd sql-data-analytics-project
```

### Step 2 — Update the CSV file paths

Open `scripts/00_init_database.sql` and update the three `BULK INSERT` paths to match
where you cloned the repo on your machine. Example:

```sql
BULK INSERT gold.dim_customers
FROM 'C:\Projects\sql-analytics-guide\datasets\flat-files\dim_customers.csv'
```

> MySQL users: open `scripts/mysql/00_init_database.sql` and update the `LOAD DATA INFILE` paths instead.

### Step 3 — Run the init script first

In SSMS, open and run `scripts/00_init_database.sql`.
This will:
- Create the `DataWarehouseAnalytics` database
- Create the `gold` schema and all three tables
- Load data from the CSV files

### Step 4 — Run scripts in order

Run each script sequentially (01 through 13). Each script is self-contained
and builds on the database created in step 3.

> MySQL users: run the scripts inside `scripts/mysql/` in the same order,
> or use `scripts/mysql/run_all.sql` to execute everything at once.

---

## Script Summary

| Script | Topic |
|--------|-------|
| 00 | Database init & data load |
| 01 | Schema & table exploration |
| 02 | Dimension exploration |
| 03 | Date range exploration |
| 04 | Key metrics (totals, averages) |
| 05 | Magnitude analysis by category/country |
| 06 | Ranking — top/bottom products & customers |
| 07 | Time-series — monthly sales trends |
| 08 | Cumulative running totals & moving averages |
| 09 | Year-over-Year performance analysis |
| 10 | Customer & product segmentation |
| 11 | Part-to-whole (category % of total revenue) |
| 12 | Customer report view (VIP/Regular/New, KPIs) |
| 13 | Product report view (High/Mid/Low performer, KPIs) |

---

## Data Model

Star schema with one fact table and two dimension tables:

```
gold.dim_customers  ──┐
                       ├──  gold.fact_sales
gold.dim_products   ──┘
```

- `dim_customers` — ~18,000 customers across Australia, US, Canada, UK, Germany, France
- `dim_products` — 295 products: Bikes, Components, Clothing, Accessories
- `fact_sales` — ~60,000 sales transactions from 2013 onward

---

## How to Push to GitHub

```bash
git init
git add .
git commit -m "Initial commit: SQL analytics project"

# Create a new repo on github.com, then:
git remote add origin https://github.com/ganeshreddymaredla/sql-data-analytics-project.git
git branch -M main
git push -u origin main
```

---

## License

MIT — free to use, modify, and share with attribution.
