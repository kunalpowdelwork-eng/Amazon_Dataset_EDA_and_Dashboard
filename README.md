# 📦 Amazon Marketplace: Categorical & Sales Analysis
-------
## 🏢 Problem Statement

Amazon India's marketplace contains thousands of products across multiple categories and price segments with no single view of where estimated revenue is concentrated, which brands dominate, and whether discount strategy is actually driving demand. This end-to-end analysis aims to address that gap by analysing and visualising product, brand, and category performance using a sales proxy metric built from available data.

## Tools Used

• 💻**Python (Pandas, NumPy, Matplotlib)**: To clean and transform data from original CSV, convert into Dataframe and plot distribution and correlation charts. <br>
• 🛢**PostgreSQL**: To store the data transformed and cleaned after cleaning in Python environment. <br>
• 📊 **Power BI**: For creating interactive Dashboard based on cleaned Data from Pandas and SQL. <br>

---

## Dataset
**Source:** https://www.kaggle.com/datasets/karkavelrajaj/amazon-sales-dataset

Dataset was acquired from Kaggle and had following columns in its Dataset: <br>
| Column | Data Type | Description |
|--------|-----------|-------------|
| product_id | String | Unique identifier for each product |
| product_name | String | Name of the product |
| category | String | Product category |
| discounted_price | String | Selling price after discount |
| actual_price | String | Original product price |
| discount_percentage | String | Percentage discount offered |
| rating | String | Average customer rating |
| rating_count | String | Number of customer ratings |
| about_product | String | Product description and features |
| user_id | String | Unique identifier of the reviewer |
| user_name | String | Name of the reviewer |
| review_id | String | Unique review identifier |
| review_title | String | Title of the customer review |
| review_content | String | Full customer review |
| img_link | String | URL of the product image |
| product_link | String | URL of the Amazon product page |

The original dataset consisted of 1,455 rows and 16 columns which after cleaning, removal of 114 duplicates and transformation was reduced to
1351 rows and 14 columns with data of products including categories with attributes such as pricing, discounts, ratings, and review counts.
 <br>

**Note on Revenue Figures**: Actual transaction data is not available in this dataset. A **Sales Proxy** metric was engineered as `Discounted Price × Rating Count` to approximate relative demand and revenue potential across products. All revenue figures are estimates and should be interpreted as directional signals, not as a true KPI.

------- 

### Workflow Followed:

### Stage 1: Cleaning of Data and CSV Loading [Python (Notebook)]
Raw CSV was cleaned, transformed, and enriched with three feature engineered columns; `sales_proxy`, `rating_type`, and `price_band` before being exported to a cleaned CSV used by both SQL and Power BI. Datatypes of multiple columns were changed from String to Float for doing aggregation functions such as Max and Min. Furthermore, duplication and null-values were replaced before exporting into CSV.
 <br> 
| Action Taken | Reason |
|---|---|
|Dropped Review related and Link related Columns| As Sentiment Analysis is not primary objective of this project|
| Dropped 114 duplicate rows | Based on `product_id + product_name` as a unique composite key |
| Split category into 3 levels | Original pipe-delimited string contained category, subcategory, domain and additional information|
| Brand extracted from product name | No dedicated brand column existed; first word extracted and title-cased |
| Rating nulls filled with subcategory mean | Preserves relative rating context rather than using a global mean |
| Rating count nulls filled with 1 | Conservative assumption at least one reviewer per listed product |
| Domains with no value filled as 'Not Available' | 35 products had no third-level category hierarchy |
 <br> 

### Final Dataset Information

| Column | Data Type | Description |
|--------|-----------|-------------|
| brand | String | Brand of the product |
| product_id | String | Unique product identifier |
| product_name | String | Name of the product |
| category | String | Main product category |
| subcategory | String | Product subcategory |
| domain | String | Product domain or department |
| discounted_price | Float | Selling price after discount |
| actual_price | Float | Original product price |
| discount_percentage | Float | Percentage discount offered |
| rating | Float | Average customer rating |
| rating_count | Float | Number of customer ratings |
| sales_proxy | Float | Estimated sales metric derived from ratings and review count |
| rating_type | Category | Rating classification (e.g., Excellent, Good, Average) |
| price_band | Category | Price segment (e.g., Budget, Mid-range, Premium) |
 <br> 

------- 
### Step 2: SQL (PostgreSQL)
Nine analytical queries were written against the cleaned dataset including Pareto (80%) analysis on revenue and customer engagement, price band performance, brand concentration, and top product identification per category.

-- **Q1. Which categories account for 80% of the marketplace's assumed sales?** 
<br>
Electronics category alone accounts for the 82% of the assumed sales in marketplace with total sales of 56.62 billion in Indian rupees.

-- **Q2. Which brands account for 80% of the assumed sales ?** <br>
Out of total 404 unique brands, 18 alone amounted for marketplace's 80% sales within which all top 5 were from the Electronics Category.
[Redmi, Samsung, Mi, Oneplus, Iqoo, Boat]

-- **Q3. Which products account for 80% of the marketplace's assumed sales ?** <br>
A total 149 products out of 1351 accounted for 80%  of the sales.

-- **Q4. Which categories account for 80% of total customer engagement (Rating Count)?** <br>
Two categories: Electronics and Computers&Accessories accounted for the 80% of the total rating counts.

-- **Q5. Which brands account for 80% of total customer engagement (Rating Count)?** <br>
31 Brands amounted for 80% of the total customer engagement over the platform. <br>
Top 5 Brands within the same where Boat, Redmi, Sandisk, Tp-Link and Amazonbasics.

-- **Q6. Which products account for 80% of total customer engagement (Rating Count)?** <br>
Total of 1351, 306 product accounted for 80% of the total customer engagement. <br>
Top 10 Products within the same were from Amazon itself, Boat and Redmi.

-- **Q7. What are the best brands estimated sales wise from each category?** <br>

Brand Name | Category
|---|---|
Gizga | HomeImprovement
Faber-Castell | Toys&Games
Reffair | Car&Motorbike
Dr | Health&PersonalCare
Casio |	OfficeProducts
Boya | MusicalInstruments
Aquaguard |Home&Kitchen
Sandisk | Computers&Accessories
Redmi | Electronics

-- **Q8. How many products have the highest rating in each category?** <br>

Category | Total Count
|---|---|
OfficeProducts |	7
Home&Kitchen |	3
Computers&Accessories | 3
Electronics| 2
Health&PersonalCare | 1
MusicalInstruments | 1
HomeImprovement | 1
Toys&Games |	1
Car&Motorbike	| 1

-- **Q9. Which price bands generate the most revenue and engagement and where should be assortment focused?** <br>

Premium Category showed most revenue followed siglightly by Budget where as Expensive and Premium showed best and second-best average ratings.
This thus calls for more product placement from Premium Segment.

------- 
### Step 3: Dashboard Creation (Power BI)
An interactive dashboard was built by importing cleaned data from Postgre Database, with slicers for Category, Subcategory, Domain, Rating Type, and Price Band. 
<br> <br>

**🔹 Dashboard Objectives**<br>
- Identify which categories and subcategories drive the majority of estimated marketplace sales
- Analyse brand concentration and understand which brands dominate each category
- Evaluate whether discount depth correlates with higher sales or customer ratings
- Compare performance across price bands to understand where revenue is generated vs. where products are listed
- Enable dynamic filtering across category hierarchy, rating quality, and price segments for granular drilldowns  <br>
![image](https://github.com/kunalpowdelwork-eng/Amazon_Dataset_EDA_and_Dashboard/blob/main/Amazon%20Dashboard%20PNG.png)
------- 
### 🔹 KPI Tiles
| Metric | Description |
|---|---|
| **Total Products** | Count of distinct SKUs in the current filtered view |
| **Total Brand** | Count of unique brands present in the filtered view |
| **Total Estimated Sales** | Sum of Sales Proxy (`Discounted Price × Rating Count`)  |
| **Avg. Product Sales** | Shows Average Sales Proxy per product |
---

### 🔹 Charts

**📊 Discount & Revenue (Avg) vs Category**:
Overlays average discount percentage and average sales proxy across all product categories. Built to test whether categories offering deeper discounts generate proportionally higher sales.

**📊 Total Sales / Products by Subcategory**:
Ranks all subcategories by the selected KPI toggle metric. In Sales view, Mobiles & Accessories (31bn) and Home Theatre (17bn) lead revealing where within broad categories the real revenue concentration sits beyond top-level category labels.

**📊 Total Sales / Products by Brand**:
Ranks brands by the selected metric. In Sales view, Redmi (19bn), Samsung (7bn), and Mi (7bn) dominate, confirming the brand concentration finding from SQL Pareto analysis.

**📊 Total Sales / Products by Category**:
Shows performance across all 8 top-level categories. Electronics leads at 57bn, with Home&Kitchen and Computers&Accessories at 6bn each directly visualising the Pareto finding that one category drives a disproportionate share of total estimated sales.

**📊 Total Sales / Products by Price Band**:
Compares four price segments: Under ₹1,000, Budget, Premium, and Expensive.

---

## Key Findings of the Analysis
- **Domination of Selective Categories**: <br> **Electronics** accounted for estimated sales of 57bn which is more than all other categories combined. Home&Kitchen and Computers&Accessories are distant second and third at ~6bn each. This further indicates high sales potential of these three categories (Electronics, Home&Kitchen and Computers&Accessories) and further need of focus on operations and category management on the same.

- **Discounting are not driving sales nor ratings**: <br> A correlation of **-0.19** between discount percentage and sales proxy indicates that higher discounts are not associated with higher revenue. Similarly, a correlation of **-0.16** between discount and rating suggests discounts do not improve customer satisfaction either.

- **Premium price band punches above its weight** despite having far fewer products than the Under ₹1,000 segment, the Premium (₹10K–₹30K) band segment generates the highest total estimated sales, indicating that high-value products drive disproportionate revenue.

- **Brand concentration is high in Electronics**: Redmi (19bn), Samsung (7bn), and Mi (7bn) together account for the majority of (estimated) Electronics revenue, indicating a concentrated, brand-driven market structure. <br>
**Insight**: Future products of these brands should be monitored in terms of stock availability with vendors to facitilate proper user purchase experience, which also avoid existing base customer to switch to another platform.

- **Customer ratings skew positive**: 824 products (61%) are rated Great (4–4.5★) and 489 (36%) are rated Good (3–4★). Only 10 products across the entire dataset fall below a 3★ rating. <br>
**Insight**: Apart from the Product's own attributes, customer satisfication in an E-Commerce is affected by logistical and transporation as product damages may happen before product even lands to the customer. High Positive rating indicates proper functioning of these operations which is crucial in products that are fragile (such as Electronics) or require special care.
---
**Kindly Note**: Dataset is only for portfolio and learning purposes only.
