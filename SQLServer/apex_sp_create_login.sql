USE [master]
GO

/****** Object:  StoredProcedure [dbo].[apex_sp_create_login]    Script Date: 07/03/2014 18.17.17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[apex_sp_create_login] @loginToCreate varchar(500)
as
declare @creaLogin  varchar(600)
declare @creaServerRole  varchar(600)
declare @creaUser  varchar(600)
declare @creaRole  varchar(600)
begin 
  set nocount on

  set @creaLogin = 'use master ' + char(13) + 'CREATE LOGIN ' + @loginToCreate + ' WITH PASSWORD=' + + char(39) + @loginToCreate + + char(39) + 
  ', DEFAULT_DATABASE= ' + @loginToCreate + ', DEFAULT_LANGUAGE=[Italiano], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF'
  
  exec (@creaLogin)

  set @creaServerRole = 'ALTER SERVER ROLE [sysadmin] ADD MEMBER ' + @loginToCreate 
  
  exec (@creaServerRole)

  set @creaUser='USE ' + @loginToCreate + char(13) + 'CREATE USER ' + @loginToCreate+ ' FOR LOGIN ' + @loginToCreate + ' WITH DEFAULT_SCHEMA=[dbo]'

  exec (@creaUser)

  set @creaRole= 'USE ' + @loginToCreate + char(13) +  ' exec sp_addrolemember N''db_owner'', ' + @loginToCreate

  --print @creaRole
  exec (@creaRole)

  --sp_change_users_login update_one, AM_GIGI, AM_GIGI

end


GO


