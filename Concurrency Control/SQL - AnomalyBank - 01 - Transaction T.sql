-- This Script is part of the AnomalyBank Series
--
-- Anomaly: Lost Update
--
-- Revision History
-- 2019.04.09 Karsten Jeppesen (kaje@ucn.dk) initial push
-- 2020.03.30 Karsten Jeppesen (kaje@ucn.dk) Spellcheck
--
-- PreReq: SQL - AnomalyBank - 01 - Initialize Bank
--
-- Distributed Systems, Concepts and Design, page 522, Figure 13.5
-- The Lost Update, Transaction T
-- Start this script first and the Transaction U no later than 5 secs after
-- +---------------------------------+--------------------------------+
-- |      Transaction T              |     Transaction U              |
-- +---------------------------------+--------------------------------+
-- | balance = b.getBalance();  200  |                                |
-- |                                 | balance = b.getBalance();  200 |
-- |                                 | b.setBalance(balance*1.1); 220 |
-- | b.setBalance(balance*1.1); 220  |                                |
-- | a.withdraw(balance/10)      80  |                                |
-- |                                 | c.withdraw(balance/10)     280 |
-- +---------------------------------+--------------------------------+
--
-- The Correct balance for account B is 242 and NOT 220
--
-- EXERCISE: Try the different ISOLATION levels. MUST BE SET IN TRANSACTION U SCRIPT TOO !!!
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
UPDATE Accounts SET Balance=100 where Customer='a'
UPDATE Accounts SET Balance=200 where Customer='b'
UPDATE Accounts SET Balance=300 where Customer='c'

-- And here comes The Lost Update
SET LOCK_TIMEOUT 5000;
go
DECLARE @Balance int;
DECLARE @Temp int;
DECLARE @aBalance int;
DECLARE @Done int = 0;
DECLARE @DeadlockErr int = 1205;
DECLARE @LockTimeout int = 1222;

WHILE @Done = 0
BEGIN
	PRINT 'Transacion Start';
	BEGIN TRANSACTION T1 WITH MARK N'Deposit b';
	BEGIN TRY
		PRINT 'Get Balance b';
		-- balance = b.getBalance();
		SELECT @Balance=Balance FROM Accounts WHERE Customer='b';
		-- AND NOW WE GO FISHING FOR 5 SECONDS TO LOOSE AN UPDATE
		PRINT 'Sleeping';
		Waitfor Delay '00:00:05';
		PRINT 'Woke up';
		-- b.setBalance(balance*1.1);
		SET @Temp = @Balance * 1.1;
		PRINT 'Updating customer b account';
		UPDATE Accounts SET Balance=@Temp WHERE Customer='b'
		PRINT 'Committing';
		COMMIT TRANSACTION T1;
		-- a.withdraw(balance/10)
		SELECT @aBalance=Balance FROM Accounts WHERE Customer='a';
		SET @Temp = @Balance * 0.1;
		SET @aBalance = @aBalance - @Temp;
		UPDATE Accounts SET Balance=@aBalance WHERE Customer='a';
		SET @Done = 1;
		PRINT 'Transaction commit';
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