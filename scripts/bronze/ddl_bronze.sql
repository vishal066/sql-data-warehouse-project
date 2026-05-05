
if OBJECT_ID('bronze.erp_PXCAT_info','U') is not null
		drop table bronze.erp_PXCAT_info;
create table bronze.erp_PXCAT_info(
ID nvarchar(50),
CAT nvarchar(50),
SUBCAT nvarchar(50),
MAINTENANCE nvarchar(50)
)  ---like this create table for each table

ALTER TABLE bronze.crm_sales_details
		alter column sls_due_dt int;


create or alter procedure bronze.load_bronze as 
begin

	declare @start_time datetime, @end_time datetime,@batch_start_time datetime,@batch_end_time datetime;
	begin try 
		
		set @batch_start_time= GETDATE();
		set @start_time= GETDATE();
		truncate table bronze.crm_crust_info
		bulk insert bronze.crm_crust_info
		from 'C:\Users\datta\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
		with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
		);
		set @end_time= GETDATE();
		print '>>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'==========================================================================================';
		
		set @start_time= GETDATE();
		truncate table bronze.crm_prd_info
		bulk insert bronze.crm_prd_info
		from 'C:\Users\datta\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
		with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
		);
		set @end_time= GETDATE();
		print '>>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'==========================================================================================';

		set @start_time= GETDATE();
		truncate table bronze.crm_sales_details
		bulk insert bronze.crm_sales_details
		from 'C:\Users\datta\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
		with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
		);
		set @end_time= GETDATE();
		print '>>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'==========================================================================================';

		set @start_time= GETDATE();
		truncate table bronze.erp_cust_info
		bulk insert bronze.erp_cust_info
		from 'C:\Users\datta\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
		with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
		);
		set @end_time= GETDATE();
		print '>>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'==========================================================================================';

		set @start_time= GETDATE();
		truncate table bronze.erp_loc_info
		bulk insert bronze.erp_loc_info
		from 'C:\Users\datta\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
		with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
		);
		set @end_time= GETDATE();
		print '>>> load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'==========================================================================================';

		set @start_time= GETDATE();
		truncate table bronze.erp_PXCAT_info
		bulk insert bronze.erp_PXCAT_info
		from 'C:\Users\datta\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
		with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
		);
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






