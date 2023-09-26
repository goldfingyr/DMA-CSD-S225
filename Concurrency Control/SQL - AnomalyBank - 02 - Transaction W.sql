-- This Script is part of the AnomalyBank Series
--
-- Problem: Inconsistent retrieval
--
-- Revision History
-- 2019.04.09 Karsten Jeppesen (kaje@ucn.dk) initial push
-- 2020.03.30 Karsten Jeppesen (kaje@ucn.dk) Spellcheck
--
-- Anomaly: Inconsistent retrieval
--
-- PreReq: SQL - AnomalyBank - 01 - Initialize Bank
--
-- Distributed Systems, Concepts and Design, page 684, Figure 16.6
-- The Inconsistent Retrievals Problem, Transaction W
-- Start this script no later than 5 secs after Transaction V
-- +------------------------------+------------------------------------+
-- |      Transaction V           |     Transaction W                  |
-- +------------------------------+------------------------------------+
-- | a.withdraw(100);    100      |                                    |
-- |                              | total = a.getBalance( )        100 |
-- |                              | total = total + b.getBalance() 300 |
-- |                              | total = total + c.getBalance() 500 |
-- | b.deposit(100)      200      |                                    |
-- +------------------------------+------------------------------------+
--
-- The Correct Branch balance is 600 NOT 500
--
-- EXERCISE: Try the different ISOLATION levels.
-- SET TRANSACTION ISOLATION LEVEL
--     { READ UNCOMMITTED
--     | READ COMMITTED
--     | REPEATABLE READ
--     | SNAPSHOT
--     | SERIALIZABLE
--     }


USE AnomalyBank
-- CHOOSE ONE OF THE FOLLOWING BY UNCOMMENTING
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--SET TRANSACTION ISOLATION LEVEL READ COMMITTED
--SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
--SET TRANSACTION ISOLATION LEVEL SNAPSHOT
--SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

-- Nothing to initialize

-- And here comes The Inconsistent Retrievals Problem

DECLARE @Balance int
DECLARE @Total int
DECLARE @Done int = 0;
DECLARE @DeadlockErr int = 1205;
DECLARE @LockTimeout int = 1222;

WHILE @Done = 0
BEGIN
	PRINT 'Branch totalling start';
	BEGIN TRANSACTION T1 WITH MARK N'Branch Total';
	BEGIN TRY
		SET @Total = 0;
		-- total = a.getBalance( )
		SELECT @Balance=Balance FROM Accounts WHERE Customer='a';
		SET @Total = @Total + @Balance;
		-- total = total + b.getBalance()
		SELECT @Balance=Balance FROM Accounts WHERE Customer='b';
		SET @Total = @Total + @Balance;
		-- total = total + c.getBalance()
		SELECT @Balance=Balance FROM Accounts WHERE Customer='c';
		SET @Total = @Total + @Balance;
		PRINT N'Total balance is';
		PRINT @Total;
		SET @Done = 1;
		COMMIT TRANSACTION T1;
	END TRY
	BEGIN CATCH
		if (ERROR_NUMBER() = @DeadlockErr)
		BEGIN
			PRINT 'ABORTED BY DEADLOCK';
			ROLLBACK;
			CONTINUE;
		END
		if (ERROR_NUMBER() = @LockTimeout)
		BEGIN
			PRINT 'ABORTED BY LOCK TIMEOUT';
			ROLLBACK;
			CONTINUE;
		END
		SELECT 'ABORTED BY UNHANDLED ERROR';
		SET @Done = 1;
	END CATCH
END









select * FROM Accounts
USE master