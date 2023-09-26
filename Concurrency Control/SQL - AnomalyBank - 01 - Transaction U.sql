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
-- The Lost Update, Transaction U
-- Start this script right after Transaction T script
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

-- No setting anything up here. Transaction T script does that

-- And here comes The Lost Update
SET LOCK_TIMEOUT 5000;
go
DECLARE @Balance int;
DECLARE @Temp int;
DECLARE @cBalance int;
DECLARE @Done int = 0;
DECLARE @DeadlockErr int = 1205;
DECLARE @LockTimeout int = 1222;

WHILE @Done = 0
BEGIN
	PRINT 'Transaction start';
	BEGIN TRANSACTION T1 WITH MARK N'Deposit b';
	PRINT 'Try start';
	BEGIN TRY
		PRINT 'Get Balance b';
		-- balance = b.getBalance();
--		select cmd,* from sys.sysprocesses where blocked > 0;
		SELECT @Balance=Balance FROM Accounts WHERE Customer='b';
		-- We just press on unless locks are encountered
		-- Waitfor Delay '00:00:05'
		-- b.setBalance(balance*1.1);
		SET @Temp = @Balance * 1.1;
		Print 'Updating';
		UPDATE Accounts SET Balance=@Temp WHERE Customer='b';
		-- c.withdraw(balance/10)
		SELECT @cBalance=Balance FROM Accounts WHERE Customer='c';
		SET @Temp = @Balance * 0.1;
		SET @cBalance = @cBalance - @Temp;
		UPDATE Accounts SET Balance=@cBalance WHERE Customer='c';
		COMMIT TRANSACTION;
		SET @Done = 1;
		PRINT 'Transaction commit';
	END TRY
	BEGIN CATCH
		IF (ERROR_NUMBER() = @DeadlockErr)
		BEGIN
			PRINT 'ABORTED BY DEADLOCK';
			ROLLBACK;
			CONTINUE;
		END
		IF (ERROR_NUMBER() = 1222)
		BEGIN
			PRINT 'ABORTED BY LOCKTIMEOUT';
			ROLLBACK;
			CONTINUE;
		END
		PRINT 'ABORTED BY UNHANDLED ERROR ERROR_NUMBER()';
		PRINT ERROR_NUMBER();
		SELECT 'ABORTED BY UNHANDLED ERROR';
		SET @Done = 1;
	END CATCH
END






select * FROM Accounts
USE master