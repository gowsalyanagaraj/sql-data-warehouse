/*
============================
Create Databases and Schemas
============================
This script creates a new database named 'DataWarehouse' 
and adds three schemas namely 'bronze', 'silver' and 'gold'.

WARNING: Running this scripts will drop the database
*/

-- create database 'DataWarehouse'

USE master;

-- check if the db alreaduy exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END:
GO;

CREATE DATABASE DataWarehouse;

USE DataWarehouse;

-- create schema for each layer
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO;
CREATE SCHEMA gold;
GO;