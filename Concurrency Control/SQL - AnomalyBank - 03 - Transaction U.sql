-- This Script is part of the AnomalyBank Series
--
-- Anomaly: Dirty Read
--
-- Revision History
-- 2019.04.09 Karsten Jeppesen (kaje@ucn.dk) initial push
-- 2020.03.30 Karsten Jeppesen (kaje@ucn.dk) Spellcheck
--
-- PreReq: SQL - AnomalyBank - 01 - Initialize Bank
--
-- Distributed Systems, Concepts and Design, page 526, Figure 13.11
-- The Dirty Read, Transaction U
-- Start this script no later than 5 secs after the first one
-- +---------------------------------+---------------------------------+
-- |      Transaction T              |     Transaction U               |
-- +---------------------------------+---------------------------------+
-- | balance = a.getBalance();  100  |                                 |
-- | a.setBalance(balance + 10) 110  |                                 |
-- |                                 | balance = a.getBalance()    110 |
-- |                                 | a.setBalance(balance + 20)  130 |
-- |                                 | commit transaction              |
-- | abort transaction               |                                 |
-- +---------------------------------+---------------------------------+
--
-- The Correct balance for account 'a' is 120 and NOT 130
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

-- Nothing to set up

-- And here comes The Dirty Read

SET LOCK_TIMEOUT 5000;
go
DECLARE @Temp int;
DECLARE @Balance int;
DECLARE @Done int = 0;
DECLARE @DeadlockErr int = 1205;
DECLARE @LockTimeout int = 1222;

WHILE @Done = 0
BEGIN
	PRINT 'Transacion Start';
	BEGIN TRANSACTION T1 WITH MARK N'Dirty Read';
	BEGIN TRY
		-- balance = a.getBalance();
		-- If not isolated correctly this read will be dirty
		SELECT @Balance=Balance FROM Accounts WHERE Customer='a';
		-- a.setBalance(balance + 20)
		SET @Balance = @Balance + 20;
		UPDATE Accounts SET Balance=@Balance WHERE Customer='a';
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






PRINT 'Customer a should show a balance of 120 and not 130'
SELECT @Balance=Balance FROM Accounts WHERE Customer='a';
PRINT @Balance
USE master