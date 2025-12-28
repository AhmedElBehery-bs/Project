# VEX Vehicle Insurance Dashboard – Power BI

![VEX Logo](assets/Logo/VEX-logo.png)

A modern, interactive Power BI dashboard analyzing vehicle insurance data. It provides clear insights into policy volumes, premiums, claims, loss ratios, customer demographics, and vehicle usage patterns.



## Project Overview

This dashboard helps insurance managers and analysts understand key performance metrics, including:

* Total policies, premiums and claims
* Loss ratios and profitability trends across years and vehicle types
* Customer segmentation (by gender, usage, vehicle category)
* High-risk segments and year-over-year changes



**Note on originality**  
This project is inspired by a popular vehicle insurance Power BI tutorial by Chandoo on YouTube. I built it as a hands-on learning exercise and then **extended and significantly customized it**:

* Redesigned the entire theme with a professional **deep navy blue and gold color palette** for a more corporate, trustworthy look
* Created a **custom "VEX" brand and logo** to replace the original
* Adjusted the sample data for realism: the original dataset included simulated high-loss scenarios (e.g., overall loss ratio >200%), which is not viable in real operations. I scaled down the `CLAIM\_PAID` column by a factor of 0.4 in Power Query to bring the loss ratio into a realistic range (~70–90%)
* Corrected the key metric from "Premium to Claims Ratio" to the industry-standard **Loss Ratio** (Claims / Premium × 100%)
* Added new measures including **Paid Claim Count**
* Created a separate measure group/folder for adjusted and new measures to improve model organization
* Enhanced visual formatting, conditional coloring, and layout for better readability
* Optimized cards, tables, and charts to align with the new theme

The dataset remains a public tutorial sample containing simulated policy and claims data from 2014–2019.



## Screenshots

### Page 1 – Executive Overview

![Page 1 - Executive Overview](Screenshots/page-1.png)



## How to View the Dashboard Locally

1. Download and install **Power BI Desktop** (free) from Microsoft:  
   https://powerbi.microsoft.com/desktop/
2. Open `VEX Insurance Dashboard.pbix`
3. Explore the report – all visuals are interactive with slicers and filters


## Files Included

* `VEX Insurance Dashboard.pbix` – Main dashboard file
* `data/insurance-data.xlsx` – original source file
* `assets/` – logo, Background, Theme





## Built With

* Power BI Desktop
* DAX for custom measures (including Loss Ratio, Claim Count, Claim Frequency)
* Power Query for data adjustments and transformations
* Custom visual formatting and branding
* PowerPoint For The Background and Tooltip
* Illustrator and AI For The logo Design



This project strengthened my skills in data modeling, DAX, realistic business metric calculation, dashboard design, and visual storytelling in the insurance domain.

Feedback and suggestions are very welcome!  


---

*Note: The original tutorial dataset included intentionally high claim amounts to demonstrate loss-making scenarios. I adjusted the claims data and corrected key metrics to reflect realistic insurance profitability while preserving analytical patterns.*







## Acknowledgements

* [Dataset](https://data.mendeley.com/datasets/34nfrk36dt/1)
* [@Chandoo-org](https://github.com/chandoo-org/)
