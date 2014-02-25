-- drop all pk
begin
declare @fetch_status integer
declare c1 cursor for 
select 'alter table ' + table_name + ' drop constraint ' + constraint_name  
from information_schema.CONSTRAINT_TABLE_USAGE where constraint_name like 'PK%'
declare @sql varchar(2000)

open c1
fetch c1 into @sql
while @@fetch_status = 0
begin
     exec(@sql)
     fetch c1 into @sql
end
close c1
deallocate c1
end
go
