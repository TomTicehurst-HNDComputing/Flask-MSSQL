DECLARE @password nvarchar(16);
SET @password = CONVERT(nvarchar(16),SUBSTRING(CONVERT(nvarchar(255),NEWID()),1,16));

PRINT 'Password: ' + @password;

EXEC sp_addlogin 'UserInterface',@password,'TomCarSales';

USE TomCarSales;
EXEC sp_adduser 'UserInterface';
EXEC sp_addrolemember 'db_datareader','UserInterface';
EXEC sp_addrolemember 'db_datawriter','UserInterface';
EXEC sp_addrolemember 'db_ddladmin','UserInterface';

