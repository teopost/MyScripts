/*

Backup of all AM_% database

Backup Sample:

exec apex_sp_backup_all_am  'c:\temp'
go

*/

USE [master]
GO

/****** Object:  StoredProcedure [dbo].[sp_backup_db]    Script Date: 07/03/2014 18.23.35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create proc [dbo].[apex_sp_backup_all_am] @backupDir varchar(50)
as
declare @dbname sysname
begin 
  set nocount on
  create table #userdbs (name sysname)
  insert into #userdbs select name from sysdatabases where name LIKE 'AM_%'
  declare cdball cursor for select name from #userdbs 
  open cdball
  fetch cdball into @dbname
  while @@fetch_status = 0 
  begin 
    EXEC master.dbo.apex_sp_backup_db @dbname, @backupDir
    print @dbname
    fetch cdball into @dbname
  end 
  close cdball
  deallocate cdball
  drop table #userdbs
end
go
