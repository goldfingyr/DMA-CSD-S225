-- OPTIMISTIC CC
--
-- Revision History
-- 2019.04.09 Karsten Jeppesen (kaje@ucn.dk) initial push
--
-- Update performed during OCC


UPDATE Optimistic
SET sku = 'connection 2: updated' WHERE partid = 1
GO

USE master