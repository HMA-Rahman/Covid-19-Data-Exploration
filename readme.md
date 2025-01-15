# Covid-19 Data Exploration & Analysis with SQL & Power BI.
## Tech Stack
**Google Spreadsheet**, **MSSQL**, **Microsoft Power BI.**
## Project Walkthrough
First, I imported the data on Google Sheets. Checked all the rows for blanks and null values (using filter). Fixed any issues regarding data format. Made sure they are in correct format and eliminated null values.

Then, I imported the cleaned data to MSSQL. Where I did the all the analysis.

The analyses I did, 

*  Selected the specific Columns I used.
*  Total Cases vs Total Deaths and Death Percentage per day [grouped by country]
* Countries with highest infection rate.
* Countries with highest death and death percentage.
* Death count by continent and their population.
*  Total Cases vs Total Deaths and Death Percentage [World] [Overall]
* Joined two datasets [Covid Death and Vaccination]
* Total Population vs Vaccination / Day across the world.

For these analyses I used, basic SQL functions and some advanced ones as well, like Subquery, CTE, Window function and Temp Table.

You can checkout the SQL queries [here](https://github.com/true-B0T/Covid-19-Data-Exploration/blob/main/Sql%20Files/COVID%20Data%20Exploration%20using%20SQL.sql).


After that, I imported these data to Power BI. Where I made an interactive dashboard which shows all these information at a glance. 

Here are some screenshots of the report I made. 

<img src="Dashboard/Full Final 1.png" width="1280" height="720"></br>

<img src="Dashboard/Partial 1.png" width="1280" height="720"></br>

<img src="Dashboard/Partial 2.png" width="1280" height="720"></br>

<img src="Dashboard/Partial 3.png" width="1280" height="720"></br>

<img src="Dashboard/Partial 4.png" width="1280" height="720"></br>

<img src="Dashboard/Showing 2020.png" width="1280" height="720"></br>

