if object_id('gold.dim_custmoers','U') is not null
    drop view gold.dim_customers

create view gold.dim_customers as 
select 
row_number() over(order by cst_id) as customer_key,
ci.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as first_name,
ci.cst_lastname as last_name,
ci.cst_marital_status as marital_status,
case when ci.cst_gndr ! ='n/a' then ci.cst_gndr
	else coalesce(ca.gen,'n/a')
end as gender,
ci.cst_create_date as create_date,
ca.BDATE as birthdate,
la.CNTRY as country

from silver.crm_cust_info ci
left join silver.erp_cust_info ca
on ci.cst_key= ca.CID
left join silver.erp_loc_info la
on ci.cst_key= la.CID


if object_id('gold.dim_products','U') is not null
    drop view gold.dim_products
create view gold.dim_products as 
select 
row_number() over(order by pd.prd_start_dt,pd.prd_key) as product_key,
pd.prd_id as product_id,
pd.cat_id as category_id,
pd.prd_key as product_number,
pd.prd_nm as product_name,
pd.prd_cost as cost,
pd.prd_line as product_line,
pd.prd_start_dt as start_date,
pc.CAT as category,
pc.SUBCAT as subcategory,
pc.MAINTENANCE

from silver.crm_prd_info pd
left join silver.erp_PXCAT_info pc
on pd.cat_id=pc.ID
where pd.prd_end_dt is null -- filter out historical data 



if object_id('gold.fact_sales','U') is not null
    drop view gold.fact_sales
create view gold.fact_sales as 
select 
sls.sls_ord_num as order_number,
pr.product_key ,
cu.customer_key,
sls.sls_order_dt as order_date,
sls.sls_ship_dt as shipping_date,
sls.sls_due_dt as due_date,
sls.sls_sales as sales_amount,
sls.sls_quantity as quantity,
sls.sls_price as price
from silver.crm_sales_info sls
left join gold.dim_products pr
on sls.sls_prd_key= pr.product_number
left join gold.dim_customers cu
on sls.sls_cust_id= cu.customer_id
