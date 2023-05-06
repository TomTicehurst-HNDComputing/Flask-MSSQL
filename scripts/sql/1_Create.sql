-- Ensures that the database does not already exist before creation
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'TomCarSales')
BEGIN
	CREATE DATABASE TomCarSales COLLATE Latin1_General_CS_AS;
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
		password varchar(102) NOT NULL,
		CONSTRAINT Users_PK PRIMARY KEY (user_id),
		CONSTRAINT Users_UN UNIQUE (username)
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
		fk_make_id int NOT NULL,
		name varchar(100) NOT NULL,
		fuel_type varchar(6) NOT NULL,
		colour varchar(100) NOT NULL,
		horsepower int NOT NULL,
		top_speed int NOT NULL,
		zero_sixty float NOT NULL,
		price float NOT NULL,
		model varchar(100) NOT NULL,
		doors int NOT NULL,
		transmission varchar(9) NOT NULL,
		registration varchar(8) NOT NULL,
		CONSTRAINT Cars_PK PRIMARY KEY (car_id),
		CONSTRAINT Cars_UN UNIQUE (registration),
		CONSTRAINT Cars_CHK CHECK (fuel_type IN ('Petrol','Diesel')),
		CONSTRAINT Cars_CHK_1 CHECK (doors IN (3,5)),
		CONSTRAINT Cars_CHK_2 CHECK (transmission IN ('Manual','Automatic')),
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
		CONSTRAINT Selling_PK PRIMARY KEY (sale_id),
		CONSTRAINT Selling_UN UNIQUE (fk_car_id),
		CONSTRAINT Selling_CHK CHECK (markup BETWEEN 0 and 100),
		CONSTRAINT Selling_FK FOREIGN KEY (fk_car_id) REFERENCES Cars(car_id)
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
		('testuser','pbkdf2:sha256:260000$Bh50Lzv2kv0DMX66$652d7c6a7c59d311fcf3ed78a31a56ac866c2ffdf7b1ed35fc00b1c857a843bc'), --testpassword
		('testuser2','pbkdf2:sha256:260000$Bh50Lzv2kv0DMX66$652d7c6a7c59d311fcf3ed78a31a56ac866c2ffdf7b1ed35fc00b1c857a843bc');
END;

-- Ensures that no data is present before inserting dummy data
IF NOT EXISTS (SELECT 1 FROM Makes WHERE make_id=0)
BEGIN
	INSERT INTO Makes(name,logo_link) VALUES
		('VW','https://www.carlogos.org/logo/Volkswagen-logo-2019-1500x1500.png'),
		('Ford','https://loodibee.com/wp-content/uploads/Ford-Logo.png'),
		('Saab','https://www.eurocarservice.com/wp-content/uploads/2018/07/Is-Saab-Still-Making-Cars.png'),
		('Porsche','https://cdn.freebiesupply.com/logos/large/2x/porsche-6-logo-png-transparent.png');
END;

-- Ensures that no data is present before inserting dummy data
IF NOT EXISTS (SELECT 1 FROM Cars WHERE fk_user_id=0)
BEGIN
	INSERT INTO Cars(fk_user_id,fk_make_id,name,fuel_type,colour,transmission,horsepower,top_speed,zero_sixty,price,model,doors,registration) VALUES
		(0,0,'Golf','Petrol','White','Manual',89,101,10,3250,'Hatchback',5,'LC61 OBJ'),
		(1,1,'Fiesta','Petrol','Black','Manual',87,101,7,3000,'Hatchback',3,'WP56 VZZ'),
		(0,2,'9-3','Diesel','Dark grey','Automatic',158,134,9.80,4750,'Estate',5,'S26 RFD'),
		(1,3,'Cayenne','Petrol','Black','Manual',340,150,7.2,2480,'SUV',5,'FJ56 BYA');
END;

-- Ensures that no data is present before inserting dummy data
IF NOT EXISTS (SELECT 1 FROM Watching WHERE fk_car_id=0)
BEGIN
	INSERT INTO Watching(fk_user_id,fk_car_id) VALUES
		(0,0),
		(1,0);
END;



