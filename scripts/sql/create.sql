-- Ensures that the database does not already exist before creation
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'TomCarSales')
BEGIN
	CREATE DATABASE TomCarSales;
END;
USE TomCarSales;

-- Function to check for a valid url being entered when entering a car's make logo
-- This function is used in the Make table's CHECK constraint
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE Name = 'ValidURL')
BEGIN
	EXECUTE sp_executesql N'CREATE FUNCTION dbo.ValidURL(@url varchar(2048)) RETURNS tinyint AS
	BEGIN
		IF CHARINDEX(''https://'',@url) <> 1 AND CHARINDEX(''http://'',@url) <> 1
		BEGIN
			RETURN 0;
		END;
	
		SET @url = REPLACE(@url,''https://'','''');
		SET @url = REPLACE(@url,''http://'','''');
	
		IF (@url LIKE ''%[^a-z0-9]%.%[^a-z0-9]%.%[^a-z0-9]%'')
		BEGIN
			RETURN 0;
		END;
	
		RETURN 1;
	END;';
END;

-- Ensures the 'Users' table does not exist before creation
IF OBJECT_ID('Users','U') IS NULL
BEGIN
	CREATE TABLE Users (
		user_id int IDENTITY(0,1) NOT NULL,
		username varchar(35) NOT NULL,
		password varchar(35) NOT NULL,
		CONSTRAINT Users_PK PRIMARY KEY (user_id),
		CONSTRAINT Users_UN UNIQUE (username,password)
	);
END;

-- Ensures the 'Makes' table does not exist before creation
IF OBJECT_ID('Makes','U') IS NULL
BEGIN
	CREATE TABLE Makes (
		make_id int IDENTITY(0,1) NOT NULL,
		name varchar(30) NOT NULL,
		logo_link varchar(2048) NOT NULL,
		CONSTRAINT Makes_PK PRIMARY KEY (make_id),
		CONSTRAINT Makes_UN UNIQUE (name),
		CONSTRAINT Makes_CHK CHECK (dbo.ValidURL(logo_link)=1)
	);
END;

-- Ensures the 'Cars' table does not exist before creation
IF OBJECT_ID('Cars','U') IS NULL
BEGIN
	CREATE TABLE Cars (
		car_id int IDENTITY(0,1) NOT NULL,
		fk_user_id int NULL,
		name varchar(100) NOT NULL,
		fuel_type varchar(6) NOT NULL,
		colour varchar(100) NOT NULL,
		horsepower int NOT NULL,
		top_speed int NOT NULL,
		zero_sixty float NOT NULL,
		price float NOT NULL,
		model varchar(100) NOT NULL,
		fk_make_id int NOT NULL,
		registration varchar(8) NOT NULL,
		CONSTRAINT Cars_PK PRIMARY KEY (car_id),
		CONSTRAINT Cars_UN UNIQUE (registration),
		CONSTRAINT Cars_CHK CHECK (fuel_type IN ('Petrol','Diesel')),
		CONSTRAINT make_id_FK FOREIGN KEY (fk_make_id) REFERENCES Makes(make_id) ON DELETE CASCADE ON UPDATE CASCADE,
		CONSTRAINT user_id_FK FOREIGN KEY (fk_user_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
	);
END;

-- Ensures the 'Selling' table does not exist before creation
IF OBJECT_ID('Selling','U') IS NULL
BEGIN
	CREATE TABLE Selling (
		sale_id int IDENTITY(0,1) NOT NULL,
		markup float NOT NULL DEFAULT 0,
		fk_car_id int NOT NULL,
		fk_user_id int NULL,
		CONSTRAINT Selling_PK PRIMARY KEY (sale_id),
		CONSTRAINT Selling_UN UNIQUE (fk_car_id),
		CONSTRAINT Selling_CHK CHECK (markup<=100 AND markup>=0),
		CONSTRAINT Selling_FK FOREIGN KEY (fk_car_id) REFERENCES Cars(car_id),
		CONSTRAINT Selling_FK_1 FOREIGN KEY (fk_user_id) REFERENCES Users(user_id)
	);
END;

-- Ensures the 'Watching' table does not exist before creation
IF OBJECT_ID('Watching','U') IS NULL
BEGIN
	CREATE TABLE Watching(
		watching_id int IDENTITY(0,1) NOT NULL,
		fk_user_id int NOT NULL,
		fk_car_id INT NOT NULL,
		CONSTRAINT Watching_PK PRIMARY KEY (watching_id),
		CONSTRAINT Watching_UN UNIQUE (fk_user_id,fk_car_id),
		CONSTRAINT Watching_FK_1 FOREIGN KEY (fk_car_id) REFERENCES Cars(car_id),
		CONSTRAINT Watching_FK FOREIGN KEY (fk_user_id) REFERENCES Users(user_id)
	);
END;

-- Ensures that no data is present before inserting dummy data
IF NOT EXISTS (SELECT 1 FROM Users WHERE user_id=0)
BEGIN
	INSERT INTO Users(username,password) VALUES
		('testuser','testuserpassword'),
		('testuser2','testuser2password');
END;

-- Ensures that no data is present before inserting dummy data
IF NOT EXISTS (SELECT 1 FROM Makes WHERE make_id=0)
BEGIN
	INSERT INTO Makes(name,logo_link) VALUES
		('VW','https://www.carlogos.org/logo/Volkswagen-logo-2019-1500x1500.png'),
		('Ford','https://www.citypng.com/public/uploads/preview/ford-logo-emblem-hd-png-11662415032kf3jq1wpbh.png');
END;

-- Ensures that no data is present before inserting dummy data
IF NOT EXISTS (SELECT 1 FROM Cars WHERE fk_user_id=0)
BEGIN
	INSERT INTO Cars(fk_user_id,name,fuel_type,colour,horsepower,top_speed,zero_sixty,price,model,fk_make_id,registration) VALUES
		(0,'CarWithUser','Petrol','Blue','100','120','5.35','1250','Hatchback',1,'TT00 TTT'),
		(NULL,'CarWithoutUser','Diesel','Red','75','100','7.35','750.2','Estate',0,'TT01 TTT');
END;

-- Ensures that no data is present before inserting dummy data
IF NOT EXISTS (SELECT 1 FROM Selling WHERE fk_car_id=0)
BEGIN
	INSERT INTO Selling(markup,fk_car_id,fk_user_id) VALUES
		(25,0,0),
		(DEFAULT,1,NULL);
END;

-- Ensures that no data is present before inserting dummy data
IF NOT EXISTS (SELECT 1 FROM Watching WHERE fk_car_id=0)
BEGIN
	INSERT INTO Watching(fk_user_id,fk_car_id) VALUES
		(0,0),
		(1,0);
END;



