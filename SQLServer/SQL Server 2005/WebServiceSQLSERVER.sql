http://www.codeguru.com/csharp/csharp/cs_network/internetweb/article.php/c15493/

use CRM

drop procedure GetOperatori
go

create procedure GetOperatori
As
select cda_matricola as matricola, des_cognome as cognome
from OPERATORI
go

drop endpoint GetOperatori
go
CREATE ENDPOINT GetOperatori
    STATE = STARTED
AS HTTP
(
    PATH = '/Operatori',
    AUTHENTICATION = (INTEGRATED),
    PORTS = (CLEAR),
    SITE = 'localhost'
)
FOR SOAP
(
    WEBMETHOD 'ListaOperatori'
        (NAME='CRM.dbo.OPERATORI'),
    BATCHES = DISABLED,
    WSDL = DEFAULT,
    DATABASE = 'CRM',
    NAMESPACE = 'http://AdventureWorks/Employee'
)
go

