-- This Script is part of the AnomalyBank Series
--
-- This script initializes the AnomalyBank database
--
-- Revision History
-- 2019.04.09 Karsten Jeppesen (kaje@ucn.dk) initial push

USE master
GO

DROP DATABASE IF EXISTS AnomalyBank
GO

CREATE DATABASE AnomalyBank
GO

USE AnomalyBank
CREATE TABLE Accounts (Customer nchar PRIMARY KEY, Balance int)

INSERT INTO Accounts (Customer, Balance) VALUES ('a' , 100 )
INSERT INTO Accounts (Customer, Balance) VALUES ('b' , 200 )
INSERT INTO Accounts (Customer, Balance) VALUES ('c' , 300 )

SELECT * FROM Accounts

-- Remember to USE master when exiting the script
USE master