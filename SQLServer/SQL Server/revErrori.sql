-- delete errori
go
select 'insert into errori values (' + cast( iderrore as varchar) + ',''' + replace(descrierrore,'''','''''') + ''')' from errori
go