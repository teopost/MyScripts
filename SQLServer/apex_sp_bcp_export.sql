
USE [master]
GO

/****** Object:  StoredProcedure [dbo].[sp_bcp_export]    Script Date: 07/03/2014 18.25.17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE  Proc [dbo].[apex_sp_bcp_export]
@dbName varchar(30),  
@tbName varchar(30),  
@filePath varchar(80)
as 

-- To allow advanced options to be changed.
-- EXEC sp_configure 'show advanced options', 1
-- GO
 -- To update the currently configured value for advanced options.
-- RECONFIGURE
-- GO
-- To enable the feature.
-- EXEC sp_configure 'xp_cmdshell', 1
-- GO
-- To update the currently configured value for this feature.
-- RECONFIGURE

-- GO

-- Esempio di utilizzo: exec sp_bcp_export 'AM_SONNLEONARDO',  'IMPOSTAZIONI',  'c:\temp\Ordini.bcp' 
		 
declare @cmd varchar(200), @sname VARCHAR(500)
begin 

SET @sname = cast(SERVERPROPERTY('ServerName') AS VARCHAR)

set @cmd = 'bcp.exe "select * from ' +  @dbName + '..' + @tbName + '" queryout ' +  @filePath + ' -N -S ' +  @sname  + ' -T -E'
print @cmd
exec xp_cmdShell @cmd  
end 


GO


