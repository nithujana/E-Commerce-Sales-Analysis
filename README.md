# E-Commerce Sales Analysis | Python, MySQL & Power BI

An end-to-end data analytics project that transforms e-commerce source data into a cleaned master dataset, answers business questions using SQL, and presents sales and profit performance in an interactive Power BI dashboard.

## Project Workflow
![Work Flow](E-Commerce Analytics Workflow Infographic.png)

**Pipeline:** Original CSV files → Python data cleaning → Cleaned master dataset → MySQL business analysis → Power BI dashboard → GitHub documentation.

## Tools & Technologies

- **Python:** Pandas, data inspection, data cleaning, dataset merging
- **MySQL:** Business analysis queries, aggregation, ranking, window functions, revenue and profit calculations
- **Power BI:** KPI cards, trend analysis, category and channel comparisons, state-level analysis, payment-method visualization
- **GitHub:** Version control and project documentation

## Dataset

The cleaned master dataset included in this repository contains **15,608 rows and 17 columns**.

Key fields include:

- Order details: `order_id`, `order_date`, `status`
- Customer details: `customer_id`, `signup_date`, `state`
- Product details: `product_id`, `product_name`, `category`
- Transaction details: `quantity`, `unit_price`, `unit_cost`, `discount_amount`, `shipping_fee`
- Marketing/payment details: `acquisition_channel`, `payment_method`, `discount_code`

The Python notebook loads four source tables (`customers`, `orders`, `order_items`, and `products`), checks data quality, standardizes product categories, converts date fields, removes duplicate order records, fills missing unit prices from product list prices where available, and merges the tables into a master dataset.

> **Data note:** The four original source CSVs are not included in this repository by default. The cleaned master CSV is provided. Add the original files only if you have permission to share them.

## Business Questions Answered with SQL

The SQL script covers questions including:

1. Who are the top 10 customers by revenue?
2. How does revenue change month by month?
3. Which acquisition channels generate the most revenue and customers?
4. Which states generate the highest sales and revenue?
5. Which products generate the highest profit?
6. What percentage of revenue comes from each category?
7. What is each customer's lifetime revenue?
8. How many repeat customers are there, and how much revenue do they contribute?
9. Which product has the highest revenue within each category?
10. Do paid-shipping orders have a higher average order value than free-shipping orders?
11. What is cumulative revenue over time?
12. How do customers rank by revenue?
13. What is the month-over-month revenue growth rate?
14. Which products are purchased together most frequently?
15. Do discounted orders generate more revenue than non-discounted orders?

The SQL file also includes statements to add and calculate `revenue` and `profit` columns.

### Calculation logic

- **Revenue:** `(quantity × unit_price) − discount_amount`
- **Profit:** `(quantity × unit_price) − discount_amount − (quantity × unit_cost)`

The SQL analysis generally filters to records with `status = 'completed'`. Check each query's filter and aggregation level when interpreting results.

## Power BI Dashboard

The dashboard summarizes sales, customer, product, and channel performance. It includes:

- KPI cards for Total Revenue, Total Profit, Total Orders, Total Customers, and Quantity Sold
- Revenue by product category
- Monthly revenue trend
- Revenue by acquisition channel
- Revenue by state
- Orders by payment method
- Profit by category
- Slicers for date range, state, and category

The accompanying PDF is a static export of the dashboard. Open the `.pbix` file in Power BI Desktop to explore and edit the report.

## Repository Structure

```text
ecommerce-sales-analysis/
├── README.md
├── workflow.png
├── data/
│   └── ecommerce_master.csv
├── notebooks/
│   └── ecommerce_analysis.ipynb
├── sql/
│   └── ecommerce_analysis.sql
└── powerbi/
    ├── ecommerce_analysis.pbix
    └── ecommerce_analysis.pdf
```

Create these folders and place each supplied file in the matching location before uploading to GitHub. Rename `ecommerce_master(4).csv` to `ecommerce_master.csv` for consistency.

## How to Run the Project

### 1. Python data preparation

1. Open `notebooks/ecommerce_analysis.ipynb` in Jupyter Notebook or JupyterLab.
2. Install the required packages if needed:

   ```bash
   pip install pandas sqlalchemy pymysql
   ```

3. Update the source CSV file paths in the notebook to match your local folders.
4. Run the notebook cells in order to inspect, clean, merge, and export the dataset.

### 2. Load the cleaned data into MySQL

1. Install and start MySQL Server.
2. Create the database:

   ```sql
   CREATE DATABASE ecommerce_analysis;
   USE ecommerce_analysis;
   ```

3. Import `data/ecommerce_master.csv` into a table named `ecommerce_master` using MySQL Workbench's **Table Data Import Wizard**, or use the Python SQLAlchemy loading code after configuring your database connection.
4. Open `sql/ecommerce_analysis.sql` in MySQL Workbench and execute the queries you want to run.

**Security:** Before publishing the notebook, remove any hard-coded database password or private connection details. Use local environment variables or a local, untracked configuration file for credentials. Never commit passwords, API keys, or other secrets to GitHub.

### 3. Open the Power BI report

1. Open `powerbi/ecommerce_analysis.pbix` in Power BI Desktop.
2. If Power BI asks for a data source, connect it to your cleaned CSV or MySQL table, depending on how the report was built.
3. Verify the field mappings and refresh the data if required.
4. Save the report after confirming that visuals and slicers work.

### 4. Add the project to GitHub

1. Sign in to GitHub and select **New repository**.
2. Use a repository name such as `ecommerce-sales-analysis`.
3. Add a short description: `End-to-end e-commerce analysis using Python, MySQL and Power BI`.
4. Choose **Public** if you want recruiters to view it, and confirm that the dataset contains no confidential or restricted data.
5. Create the repository.
6. On the repository page, choose **Add file → Create new file** to add `README.md`, or upload the prepared README.
7. Upload `workflow.png` to the repository root.
8. Create the folders shown in the repository structure and upload the notebook, cleaned CSV, SQL script, PBIX file, and PDF.
9. Open the repository page and confirm that the README workflow image renders and all file links work.

### Optional: Upload with Git

After creating the repository on GitHub, open a terminal inside your local project folder and run:

```bash
git init
git add README.md workflow.png data/ notebooks/ sql/ powerbi/
git commit -m "Add e-commerce sales analysis project"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/ecommerce-sales-analysis.git
git push -u origin main
```

Replace `YOUR-USERNAME` with your GitHub username and use the repository URL GitHub gives you. If Git reports that the remote already contains commits, follow GitHub's instructions to sync the repository rather than force-pushing.

## Important Checks Before Publishing

- Remove passwords and other secrets from the notebook.
- Make notebook paths relative to the project, not a personal drive such as `H:\...`.
- Confirm the revenue/profit formulas and the definition of an order are consistent across SQL and Power BI.
- Validate dashboard totals against the SQL results; differences can occur if filters, status rules, or aggregation levels differ.
- Include only data you are allowed to share publicly.
- If the `.pbix` file is too large for the standard GitHub upload interface, use Git from the terminal or Git Large File Storage (Git LFS).

## Project Outcome

This project demonstrates an end-to-end analytics workflow: data quality checks and preparation in Python, business-focused querying in MySQL, and interactive reporting in Power BI. It is designed to communicate actionable insights about revenue, profitability, customers, products, and sales channels.
