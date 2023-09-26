--
-- Revision History
-- 2019.04.09 Karsten Jeppesen (kaje@ucn.dk) initial push
--
-- Transaction protected by OCC

DROP TABLE IF EXISTS Optimistic
CREATE TABLE Optimistic
(
partid INT identity(1,1) not null PRIMARY KEY,
partname NVARCHAR(50) not null UNIQUE,
sku NVARCHAR(50) not null,
rowid ROWVERSION not null
)
go

INSERT INTO Optimistic (partname, sku) VALUES ('Widget', 'default sku')
GO

-- Starting the show
DECLARE @rowid ROWVERSION

SELECT @rowid = rowid
FROM Optimistic
WHERE partid = 1

-- wait 30 seconds to simulate
-- a user examining the row and
-- making a data modification
RAISERROR( 'Sleeping...',0,1) WITH NOWAIT
WAITFOR DELAY '00:00:10'
RAISERROR( 'Sleeping... Done',0,1) WITH NOWAIT


UPDATE Optimistic
SET sku = 'connection 1: updated'
WHERE partid = 1
AND rowid = @rowid

IF @@rowcount = 0
BEGIN
      IF NOT EXISTS (select 1 from Optimistic where partid = 1)
		  RAISERROR( 'this row was deleted by another user!',0,1) WITH NOWAIT
      ELSE
		  RAISERROR( 'this row was updated by another user!',0,1) WITH NOWAIT
END
ELSE
  RAISERROR( 'this row was updated by by me.',0,1) WITH NOWAIT
go

USE master
