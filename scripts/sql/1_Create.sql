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
		image_link varchar(2048) NOT NULL,
		CONSTRAINT Cars_PK PRIMARY KEY (car_id),
		CONSTRAINT Cars_UN UNIQUE (registration),
		CONSTRAINT Cars_CHK CHECK (fuel_type IN ('Petrol','Diesel')),
		CONSTRAINT Cars_CHK_1 CHECK (doors IN (3,5)),
		CONSTRAINT Cars_CHK_2 CHECK (transmission IN ('Manual','Automatic')),
		CONSTRAINT Cars_CHK_3 CHECK (dbo.ValidURL(image_link)=1),
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
		CONSTRAINT Selling_CHK CHECK (markup BETWEEN 0 and 200),
		CONSTRAINT Selling_FK FOREIGN KEY (fk_car_id) REFERENCES Cars(car_id)
	);
END;

-- Ensures the 'Watching' table does not exist before creation
IF OBJECT_ID('Watching','U') IS NULL
BEGIN
	CREATE TABLE Watching(
		watching_id int IDENTITY(0,1) NOT NULL,
		fk_user_id int NOT NULL,
		fk_car_id int NOT NULL,
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
	INSERT INTO Cars(fk_user_id,fk_make_id,name,fuel_type,colour,transmission,horsepower,top_speed,zero_sixty,price,model,doors,registration,image_link) VALUES
		(0,0,'Golf','Petrol','White','Manual',89,101,10,3250,'Hatchback',5,'LC61 OBJ','https://w7.pngwing.com/pngs/475/575/png-transparent-2012-volkswagen-jetta-sportwagen-car-volkswagen-golf-2011-volkswagen-jetta-mini-golf-compact-car-sedan-car.png'),
		(1,1,'Fiesta','Petrol','Grey','Manual',87,101,7,3000,'Hatchback',3,'WP56 VZZ','https://i.ibb.co/qWzqzRn/image-removebg-preview-1.png'),
		(0,2,'9-3','Diesel','Dark grey','Automatic',158,134,9.80,4750,'Estate',5,'S26 RFD','https://w7.pngwing.com/pngs/1018/220/png-transparent-2010-saab-9-3-2011-saab-9-3-2008-saab-9-3-2012-saab-9-3-saab-file-compact-car-sedan-car.png'),
		(1,3,'Cayenne','Petrol','Black','Manual',340,150,7.2,2480,'SUV',5,'FJ56 BYA','https://w7.pngwing.com/pngs/350/341/png-transparent-2018-porsche-cayenne-car-sport-utility-vehicle-manumatic-porsche-compact-car-car-vehicle.png');
END;

-- Ensures that no data is present before inserting dummy data
IF NOT EXISTS (SELECT 1 FROM Watching WHERE fk_car_id=0)
BEGIN
	INSERT INTO Watching(fk_user_id,fk_car_id) VALUES
		(0,0),
		(1,0);
END;

-- Ensures that no data is present before inserting dummy data
IF NOT EXISTS (SELECT 1 FROM Selling WHERE fk_car_id=0)
BEGIN
	INSERT INTO Selling(markup,fk_car_id) VALUES
	(DEFAULT,0),
	(200,3)
END;


-- Creates a view to select all cars with model information - this is used in the user interface
CREATE VIEW cars_and_makes AS
	SELECT
		car_id as '!car_id',
		Cars.name as 'name',
		fuel_type,
		colour,
		horsepower,
		top_speed,
		zero_sixty,
		price,
		model,
		doors,
		transmission,
		registration,
		image_link as '!image_link',
		logo_link as '!logo_link'
	FROM Cars
		INNER JOIN Makes ON Cars.fk_make_id=make_id;



CREATE VIEW cars_being_sold AS
	SELECT
		sale_id as '!sale_id',Cars.fk_user_id as '!user_id',markup,cars_and_makes.*
	FROM cars_and_makes
		INNER JOIN Selling on [!car_id]=fk_car_id
		INNER JOIN Cars on [!car_id]=car_id;


CREATE VIEW cars_being_watched AS
	SELECT
		watching_id as '!watching_id',fk_user_id as '!user_id',cars_and_makes.*
	FROM cars_and_makes
		INNER JOIN Watching on [!car_id]=fk_car_id;




