/*
Esempio di ripristino


USE master 
go

EXEC apex_sp_restore_db 'AM_SAMMIEXPORT', 'c:\tmp\migrazione\AM_SAMMIEXPORT.bak', 'D:\Program Files\Microsoft SQL Server\MSSQL11.IORDER\MSSQL\DATA', 'E:\Program Files\Microsoft SQL Server\MSSQL11.IORDER\MSSQL\DATA'
go

EXEC apex_sp_create_login 'AM_SAMMIEXPORT'
go

USE LICENSE_MANAGER
go

EXEC sp_change_users_login 'Auto_Fix', 'LICENSE_MANAGER'
go



*/

USE [master]
GO

/****** Object:  StoredProcedure [dbo].[apex_sp_restore_db]    Script Date: 07/03/2014 18.15.08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[apex_sp_restore_db]  @dbToCreate varchar(100), @backupToRestore varchar(100), @pathDatafiles varchar(400), @pathLogfiles varchar(400)
as
declare @dbname   sysname

declare @reststmt    varchar(600)
declare @ntstmt   varchar(100) 
declare @datafilename sysname
declare @physicalname sysname
declare @logfilename sysname
declare @i        int
declare @pos1     int

declare @fileListTable table
(
    LogicalName          nvarchar(128),
    PhysicalName         nvarchar(260),
    [Type]               char(1),
    FileGroupName        nvarchar(128),
    Size                 numeric(20,0),
    MaxSize              numeric(20,0),
    FileID               bigint,
    CreateLSN            numeric(25,0),
    DropLSN              numeric(25,0),
    UniqueID             uniqueidentifier,
    ReadOnlyLSN          numeric(25,0),
    ReadWriteLSN         numeric(25,0),
    BackupSizeInBytes    bigint,
    SourceBlockSize      int,
    FileGroupID          int,
    LogGroupGUID         uniqueidentifier,
    DifferentialBaseLSN  numeric(25,0),
    DifferentialBaseGUID uniqueidentifier,
    IsReadOnl            bit,
    IsPresent            bit,
    TDEThumbprint        varbinary(32)
)

begin
   set nocount on

	insert into @fileListTable
      exec ('RESTORE filelistonly from disk=' + '''' +  @backupToRestore + '''')
    
	select @datafilename = LogicalName from @fileListTable where type = 'D'
	select @logfilename = LogicalName from @fileListTable where type = 'L'
	select @physicalname = PhysicalName from @fileListTable where type = 'D'

   
	set @reststmt = 'restore Database ' + @dbToCreate + ' from ' +
	  'Disk = ' + char(39) +@backupToRestore + + char(39) + ' ' +
      ' with move ' + char(39) + @datafilename + char(39) + ' to ' + char(39) + @pathDatafiles + '\' + @dbToCreate + '.mdf' + char(39) + 
		', move ' + char(39) + @logfilename + char(39) + ' to ' + char(39) +  @pathLogfiles + '\'  + @dbToCreate + '.ldf' + char(39)
	
    print @physicalname
    print @reststmt
	exec (@reststmt)
	
   
end




GO


