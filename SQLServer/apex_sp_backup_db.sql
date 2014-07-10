/*

Backup Sample: 
exec apex_sp_backup_db 'AM_ROMIRI', 'c:\tmp'
go

*/

USE [master]
GO

/****** Object:  StoredProcedure [dbo].[sp_backup_db]    Script Date: 07/03/2014 18.23.35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[apex_sp_backup_db] @amDbModel varchar(50), @backupDir varchar(50)
as
declare @dbname sysname
declare @bckstmt varchar(500)
begin 
  set nocount on
  create table #userdbs (name sysname)
  insert into #userdbs select name from sysdatabases where name = '' + @amDbModel + ''
  declare cdb cursor for select name from #userdbs 
  open cdb
  fetch cdb into @dbname
  while @@fetch_status = 0 
  begin 
    set @bckstmt = 'BackUp Database ' + @dbname + ' to ' +
      'Disk = ' + char(39) + @backupDir + '\' + rtrim(ltrim(@dbname)) + '.bak' + char(39) + ' ' +
      'WITH NOFORMAT,INIT' 
   exec (@bckstmt)
    print @bckstmt
    fetch cdb into @dbname
  end 
  close cdb
  deallocate cdb
  drop table #userdbs
end



GO


