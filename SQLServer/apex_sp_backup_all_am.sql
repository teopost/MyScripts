create  proc [dbo].[apex_sp_backup_all_am] @backupDir varchar(50)
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
