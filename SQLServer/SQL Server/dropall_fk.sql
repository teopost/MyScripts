
begin
declare @fetch_status integer
declare c1 cursor for 
select 'alter table ' + u.table_name + ' drop constraint ' + u.constraint_name  
from 
information_schema.CONSTRAINT_TABLE_USAGE U,
INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C
where U.CONSTRAINT_NAME=C.CONSTRAINT_NAME

declare @sql varchar(2000)

open c1
fetch c1 into @sql
while @@fetch_status = 0
begin
  exec(@sql)
  --print @sql
  fetch c1 into @sql
end
     --fetch c1 into @sql
close c1
deallocate c1
end
go

