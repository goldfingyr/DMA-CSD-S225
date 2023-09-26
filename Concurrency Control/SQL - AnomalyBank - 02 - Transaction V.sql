-- This Script is part of the AnomalyBank Series
--
-- Anomaly: Inconsistent retrieval
--
-- Revision History
-- 2019.04.09 Karsten Jeppesen (kaje@ucn.dk) initial push
-- 2020.03.30 Karsten Jeppesen (kaje@ucn.dk) Spellcheck
--
-- PreReq: SQL - AnomalyBank - 01 - Initialize Bank
--
-- Distributed Systems, Concepts and Design, page 522, Figure 13.6
-- The Inconsistent Retrievals Problem, Transaction V
-- Start this script first and the other no later than 5 secs after
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

-- First we set the start environment
UPDATE Accounts SET Balance=200 where Customer='a'
UPDATE Accounts SET Balance=200 where Customer='b'
UPDATE Accounts SET Balance=200 where Customer='c'

-- And here comes The Inconsistent Retrievals Problem

DECLARE @Balance int
DECLARE @Done int = 0;
DECLARE @DeadlockErr int = 1205;
DECLARE @LockTimeout int = 1222;

WHILE @Done = 0
BEGIN
	PRINT 'Transacion Start';
	BEGIN TRANSACTION T1 WITH MARK N'Move funds';
	BEGIN TRY
		-- a.withdraw(100)
		SELECT @Balance=Balance FROM Accounts WHERE Customer='a';
		SET @Balance = @Balance - 100;
		UPDATE Accounts SET Balance=@Balance WHERE Customer='a';
		-- AND NOW WE GO FISHING FOR 10 SECONDS TO LOOSE AN UPDATE
		Waitfor Delay '00:00:05';
		-- b.deposit(100)
		SELECT @Balance=Balance FROM Accounts WHERE Customer='b';
		SET @Balance = @Balance + 100;
		UPDATE Accounts SET Balance=@Balance WHERE Customer='b';
		COMMIT TRANSACTION T1;
		SET @Done = 1;
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