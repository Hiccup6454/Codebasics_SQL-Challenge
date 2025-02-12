Use Atliq;

/* 1. Provide the list of markets in which customer "Atliq Exclusive" operates its
business in the APAC region */

SELECT DISTINCT(Market) AS 'APAC Markets'
FROM dim_customer
WHERE customer = 'Atliq Exclusive' AND region = 'APAC';

/* 2. What is the percentage of unique product increase in 2021 vs. 2020? The
final output contains these fields,
    unique_products_2020
    unique_products_2021
	percentage_chg */
    
SELECT * FROM atliq.fact_sales_monthly;

with CTE as 
      (
      SELECT 
      Count(distinct case when fiscal_year=2020 then product_code end) 
      as unique_products_2020,
      count(distinct case when fiscal_year=2021 then product_code end) 
      as unique_products_2021
      from fact_sales_monthly
      )
SELECT unique_products_2020, unique_products_2021,
round((unique_products_2021 - unique_products_2020) / unique_products_2020*100,2) 
as Percentage_change
FROM CTE;

/* 3. Provide a report with all the unique product counts for each segment and
sort them in descending order of product counts. The final output contains
2 fields,
segment
product_count */

Select segment, Count(Distinct(Product)) as Product_count
From dim_product
Group by segment
Order by product_count DESC;

/* 4. Follow-up: Which segment had the most increase in unique products in
2021 vs 2020? The final output contains these fields,
segment
product_count_2020
product_count_2021
difference */

With CTE AS
        (
        Select segment,
        count(distinct case when fiscal_year=2020 then dp.product end)
        As product_count_2020,
        count(distinct case when fiscal_year=2021 then dp.product end)
        As product_count_2021
        From fact_sales_monthly fsm
        join dim_product dp
        on fsm.product_code = dp.product_code
        group by segment
        )
Select segment, product_count_2020, product_count_2021, abs(product_count_2020-product_count_2021) as Difference
From CTE 
order by difference desc;

/* 5. Get the products that have the highest and lowest manufacturing costs.
The final output should contain these fields,
product_code
product
manufacturing_cost */

Select fmc.product_code, dp.product, fmc.manufacturing_cost
From fact_manufacturing_cost fmc
join dim_product dp
on fmc.product_code = dp.product_code
Where manufacturing_cost in ((select max(manufacturing_cost) from fact_manufacturing_cost),
                            (Select min(manufacturing_cost) from fact_manufacturing_cost));
                            
/* 6. Generate a report which contains the top 5 customers who received an
average high pre_invoice_discount_pct for the fiscal year 2021 and in the
Indian market. The final output contains these fields,
customer_code
customer
average_discount_percentage */

Select fpid.customer_code, dc.customer, avg(pre_invoice_discount_pct) as average_discount_percentage
From fact_pre_invoice_deductions fpid
Join dim_customer dc
on fpid.customer_code = dc.customer_code
where fiscal_year = 2021 AND market = 'India'
Group by customer, fpid.customer_code
order by average_discount_percentage desc
limit 5;

/* 7. Get the complete report of the Gross sales amount for the customer “Atliq
Exclusive” for each month. This analysis helps to get an idea of low and
high-performing months and take strategic decisions.
The final report contains these columns:
Month
Year
Gross sales Amount */         

        
Select month(FSM.date) as Months, 
FSM.fiscal_year as Year, 
Sum(FSM.sold_quantity * FGP.gross_price) as Gross_Sales_Amount
from fact_sales_monthly FSM
Join Fact_gross_price FGP
On FSM.product_code = FGP.Product_code
Join dim_customer DM
On FSM.customer_code = DM.customer_code
Where customer = 'Atliq Exclusive'
Group by months, year
order by year, months

/* 8. In which quarter of 2020, got the maximum total_sold_quantity? The final
output contains these fields sorted by the total_sold_quantity,
Quarter
total_sold_quantity */

Select 
Case
When month(date) in (9,10,11) then 'QTR-1'
When month(date) in (12,1,2) then 'QTR-2'
When month(date) in (3,4,5) then 'QTR-3'
When month(date) in (6,7,8) then 'QTR-4'
END as Quarter,
sum(sold_quantity) as Total_sold_Quanity
From Fact_sales_monthly
Where fiscal_year = 2020
Group by quarter
order by Total_sold_Quanity desc;

/* 9. Which channel helped to bring more gross sales in the fiscal year 2021
and the percentage of contribution? The final output contains these fields,
channel
gross_sales_mln
percentage */


With CTE as
(
Select channel, round(sum(fsm.sold_quantity * fgp.gross_price)/1000000,2) as Gross_Sales_mln
from fact_sales_monthly fsm
Join fact_gross_price fgp
On fsm.product_code = fgp.product_code
Join dim_customer dm
On fsm.customer_code = dm.customer_code
Where fsm.fiscal_year = 2021
Group by channel
Order by gross_sales_mln desc
)
Select *, (Gross_Sales_mln *100) / sum(gross_sales_mln) over () as Percentage
From CTE

/* 10. Get the Top 3 products in each division that have a high
total_sold_quantity in the fiscal_year 2021? The final output contains these
fields,
division
product_code */

With CTE1 AS
(
Select dm.division, fsm.product_code, dm.product, sum(sold_quantity) as Total_quantity
From dim_product dm
Join fact_sales_monthly fsm
on dm.product_code = fsm.product_code
group by dm.division, fsm.product_code, dm.product
),

CTE2 AS
(
Select *, rank() over(partition by division order by total_quantity desc) as Rank_order
From CTE1
)

Select *
From cte2
Where rank_order < 4












                            










