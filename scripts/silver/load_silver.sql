create or alter procedure silver.load_silver as 
begin
	declare @start_time datetime, @end_time datetime,@batch_start_time datetime,@batch_end_time datetime;
	begin try 
		set @batch_start_time= GETDATE();
		set @start_time= GETDATE();
		truncate table silver.crm_cust_info;
		print '>>>> inserting the table:';
		insert into silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		select  
		cst_id,
		cst_key,
		trim(cst_firstname),
		trim(cst_lastname),
		case 
			when upper(trim(cst_material_status)) = 'S' then 'Single'
			when upper(trim(cst_material_status)) = 'M' then 'Married'
			else 'N/A'
		end as cst_marital_status,
		case 
		 when upper(trim(cst_gndr)) = 'F' then 'Female'
		 when upper(trim(cst_gndr)) = 'M' then 'Male'
		 else 'N/A'
		end as cst_gndr,
		cst_create_date

		from
		(
		select *,
		ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag_last
		from bronze.crm_crust_info
		where cst_id is not null
		)t where flag_last =1;
		set @end_time= GETDATE();
		print '>>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'==========================================================================================';

		set @start_time= GETDATE();
		truncate table silver.crm_prd_info;
		print '>>>> inserting the table:';
		insert into silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt

		)
		select 
		prd_id,
		replace(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
		SUBSTRING(prd_key,7,len(prd_key)) as prd_key,
		prd_nm,
		isnull(prd_cost,0) as prd_cost,
		case 
			when upper(trim(prd_line)) ='M' then 'Mountain'
			when upper(trim(prd_line)) ='R' then 'Road'
			when upper(trim(prd_line)) ='S' then 'Other_sales'
			when upper(trim(prd_line)) ='T' then 'Touring'
			else 'N/A'
		end as prd_line,
		prd_start_date,
		dateadd(day,-1,lead(prd_start_date) over(partition by prd_key order by prd_start_date)) as prd_end_dt
		from bronze.crm_prd_info
		set @end_time= GETDATE();
		print '>>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'==========================================================================================';

		set @start_time= GETDATE();
		truncate table silver.crm_sales_info;
		print '>> inserting the table:';
		insert into silver.crm_sales_info(
		sls_ord_num ,
		sls_prd_key ,
		sls_cust_id ,
		sls_order_dt ,
		sls_ship_dt ,
		sls_due_dt ,
		sls_sales ,
		sls_quantity ,
		sls_price 
		)
		select 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		case when sls_order_dt <=0 or len(sls_order_dt) !=8 then null
			 else cast(cast(sls_order_dt as varchar) as date)
		end as sls_order_dt,
		case when sls_ship_dt <=0 or len(sls_ship_dt) !=8 then null
			 else cast(cast(sls_ship_dt as varchar) as date)
		end as sls_ship_dt,
		case when sls_due_dt <=0 or len(sls_due_dt) !=8 then null
			 else cast(cast(sls_due_dt as varchar) as date)
		end as sls_due_dt,
		case when sls_sales <=0 or sls_sales is null or sls_sales != sls_quantity* abs(sls_price)
			 then sls_quantity* abs(sls_price)
			 else sls_sales
		end as sls_sales,
		sls_quantity,
		case when sls_price<=0 or sls_price is null 
			 then sls_sales/nullif(sls_quantity,0)
			 else sls_price
		end as sls_price
		from bronze.crm_sales_details
		set @end_time= GETDATE();
		print '>>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'==========================================================================================';

		set @start_time= GETDATE();
		truncate table silver.erp_cust_info;
		print '>> inserting the table:';
		insert into silver.erp_cust_info(
		 cid,
		 bdate,
		 gen
		)

		select 
		case when cid like 'NAS%' then SUBSTRING(cid,4, len(cid))
			 else cid
		end as cid,
		case when bdate > GETDATE() then null
			 else bdate
		end as bdate,
		case when upper(trim(gen)) in ('F','FEMALE') then 'Female'
			 when upper(trim(gen)) in ('M','MALE') then 'Male'
			 else 'N/A'
		end as gen
		from bronze.erp_cust_info
		set @end_time= GETDATE();
		print '>>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'==========================================================================================';

		set @start_time= GETDATE();
		truncate table silver.erp_loc_info;
		print '>> inserting the table:';
		insert into silver.erp_loc_info(cid,CNTRY)
		select 
		replace(cid,'-','') as cid,
		case when trim(CNTRY) = 'DE' then 'Germany'
			 when trim(CNTRY) in ('US','USA') then 'United States'
			 when trim(CNTRY) = '' or cntry is null then 'N/A'
			 else trim(cntry)
		end as cntry
		from bronze.erp_loc_info
		set @end_time= GETDATE();
		print '>>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'==========================================================================================';

		set @start_time= GETDATE();
		truncate table silver.erp_PXCAT_info;
		print '>> inserting the table:';
		insert into silver.erp_PXCAT_info(id,cat,subcat,MAINTENANCE)
		select id,cat,subcat,maintenance from bronze.erp_PXCAT_info
		set @end_time= GETDATE();
		print '>>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'==========================================================================================';
		set @batch_end_time=GETDATE();
		print '>>> batch load duration:' + cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar) + 'seconds';
	end try 
	begin catch
		print '=============================================';
		print '=============================================';
		print 'error message' + error_message();
		print 'error message' + cast(error_number() as nvarchar);
		print 'error message' + cast(error_state() as nvarchar);
	end catch

end

exec silver.load_silver
