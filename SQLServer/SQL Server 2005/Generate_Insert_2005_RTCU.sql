-- Questo genera lo statement di insert

SELECT 'EXEC sp_generate_inserts ' + '''' + name  + ''''
FROM sysobjects 
WHERE type = 'U' AND 
OBJECTPROPERTY(id,'ismsshipped') = 0
and name like 'RTCU_%'

-- questo è l'output generato

EXEC sp_generate_inserts 'RTCU_Applications'
EXEC sp_generate_inserts 'RTCU_Books'
EXEC sp_generate_inserts 'RTCU_ButtonBars'
EXEC sp_generate_inserts 'RTCU_CmdSets'
EXEC sp_generate_inserts 'RTCU_Commands'
EXEC sp_generate_inserts 'RTCU_Constants'
EXEC sp_generate_inserts 'RTCU_Enums'
EXEC sp_generate_inserts 'RTCU_ErrorMessages'
EXEC sp_generate_inserts 'RTCU_Forms'
EXEC sp_generate_inserts 'RTCU_Graphs'
EXEC sp_generate_inserts 'RTCU_Indicators'
EXEC sp_generate_inserts 'RTCU_PanelFields'
EXEC sp_generate_inserts 'RTCU_PanelGroups'
EXEC sp_generate_inserts 'RTCU_Panels'
EXEC sp_generate_inserts 'RTCU_Reports'
EXEC sp_generate_inserts 'RTCU_RoleItems'
EXEC sp_generate_inserts 'RTCU_Roles'
EXEC sp_generate_inserts 'RTCU_RptBoxes'
EXEC sp_generate_inserts 'RTCU_RptSpans'
EXEC sp_generate_inserts 'RTCU_Sections'
EXEC sp_generate_inserts 'RTCU_Tabbeds'
EXEC sp_generate_inserts 'RTCU_TemplatePages'
EXEC sp_generate_inserts 'RTCU_Timers'
EXEC sp_generate_inserts 'RTCU_TreeItems'
EXEC sp_generate_inserts 'RTCU_Trees'
EXEC sp_generate_inserts 'RTCU_VStyles'