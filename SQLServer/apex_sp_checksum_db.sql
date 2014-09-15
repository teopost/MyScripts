/*

Backup Sample: 
exec apex_sp_checksum_db 'AM_ROMIRI' /* Database*/, 'S' /* S=Summary, R=Report*/ 
go

*/

USE [master]
GO

/****** Object:  StoredProcedure [dbo].[sp_backup_db]    Script Date: 07/03/2014 18.23.35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[apex_sp_checksum_db] @database_name varchar(100) = null,  @mode varchar(1) = 'S' /* S= Summary, R=Report*/ 
as
declare 
  @dbname sysname, 
  @hash_value BIGINT,
  @o_name VARCHAR(MAX),
  @o_count BIGINT

begin 
	set nocount ON
  
	if @database_name IS null begin
	   set @database_name =  db_name()
	end
     
	CREATE TABLE #schema_stats (OBJ_NAME VARCHAR(MAX), OBJ_COUNT VARCHAR(MAX)) 

	INSERT INTO #schema_stats
	SELECT 'Tables: ' AS OBJ_NAME, COUNT(*) AS OBJ_COUNT   FROM INFORMATION_SCHEMA.TABLES
	UNION ALL
	SELECT 'Views: ' , COUNT(*) FROM INFORMATION_SCHEMA.TABLES
	UNION ALL
	SELECT 'Columns: ' , COUNT(*)  FROM INFORMATION_SCHEMA.COLUMNS
	UNION ALL
	SELECT 'Check constraints: ' , COUNT(*)  FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS
	UNION ALL
	SELECT 'Constraint usage: ' , COUNT(*)  FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
	UNION ALL
	SELECT 'Key usage: ' , COUNT(*)  FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
	UNION ALL
	SELECT 'Ref constraints: ' , COUNT(*)  FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
	UNION ALL
	SELECT 'Schemata: ' , COUNT(*)  FROM INFORMATION_SCHEMA.SCHEMATA
	UNION ALL
	SELECT 'Parameters: ' , COUNT(*)  FROM INFORMATION_SCHEMA.PARAMETERS

	SELECT
		 @hash_value = CHECKSUM_AGG(BINARY_CHECKSUM (OBJ_COUNT)) 
	FROM  
		#schema_stats

    if @mode = 'S' 
	BEGIN
       PRINT   @database_name +': ' + CAST(@hash_value AS VARCHAR)
       PRINT '---------------------------'   

	end
	ELSE 
	  BEGIN
        PRINT   @database_name +': ' + CAST(@hash_value AS VARCHAR) 
		PRINT '---------------------------'   
		declare cdball cursor for select obj_name, obj_count  from #schema_stats 
		open cdball
		fetch cdball into @o_name, @o_count
		while @@fetch_status = 0 
		begin 
		EXEC master.dbo.apex_sp_backup_db @o_name, @o_count

	    PRINT   @o_name +': ' + CAST(@o_count AS VARCHAR)

		fetch cdball into @o_name, @o_count
		end 
		close cdball
		deallocate cdball

	end


  drop table #schema_stats
end

GO
