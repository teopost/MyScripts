CREATE   function INITCAP (@inString varchar(4000) ) 
/*
 INITCAP returns char, with the first letter of each word in uppercase,
 all other letters in lowercase. 
 Words are delimited by white space or characters that are not alphanumeric   
 */
returns varchar(4000)
as
BEGIN
DECLARE @i int, @c char(1),@result varchar(255)
SET @result=LOWER(@inString)
SET @i=2
SET @result=STUFF(@result,1,1,UPPER(SUBSTRING(@inString,1,1)))
WHILE @i<=LEN(@inString)
 BEGIN
 SET @c=SUBSTRING(@inString,@i,1)
 IF (@c=' ') OR (@c=';') OR (@c=':') OR (@c='!') OR (@c='?') OR (@c=',')OR (@c='.')OR (@c='_')
  IF @i<LEN(@inString)
   BEGIN
   SET @i=@i+1
   SET @result=STUFF(@result,@i,1,UPPER(SUBSTRING(@inString,@i,1)))
   END
 SET @i=@i+1
 END
RETURN  @result
END
go