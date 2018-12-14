/*PARTIAL TRIGGER*/
/*PATIENT table default entry at 3AM every day from specified date*/
CREATE EVENT patientTabInsertion
ON SCHEDULE EVERY 1 DAY STARTS '2018-10-10 03:00:00'
DO
INSERT INTO DiaHCMS.PATIENT VALUES(CURDATE(),0.0,'N','N','N',0.0,0.0);

--------------------------------------------------------------------------------

/*STORED PROCEDURE*/
/*returns the next id to be used in ANOMALY table*/
CREATE PROCEDURE DiaHCMS.getNextAnoID(OUT new_ano_id VARCHAR(10))
BEGIN
  SELECT CONCAT('AN', LP.ZF) INTO new_ano_id FROM (
    SELECT LPAD(LT.R,2,'0') as ZF FROM (
      SELECT RIGHT(A.A_ID,2)+1 AS R FROM (
        SELECT A_ID FROM DiaHCMS.ANOMALY ORDER BY A_ID DESC LIMIT 1)
      AS A)
    as LT)
  as LP;
END;

--------------------------------------------------------------------------------

/*STORED PROCEDURE
TO GENERATE NEXT INSULIN TABLE I_ID AND INSERT CORRESPONDING INSULIN DOSE FOR THE MEAL*/
CREATE PROCEDURE DiaHCMS.insTabAfterMeal(IN ins_units float, IN bs_amt float, OUT new_ins_id VARCHAR(10))
BEGIN
  SELECT CONCAT('IN', LP.ZF) INTO new_ins_id FROM (
    SELECT LPAD(LT.R,2,'0') as ZF FROM (
      SELECT RIGHT(I.I_ID,2)+1 AS R FROM (
        SELECT I_ID FROM DiaHCMS.INSULIN ORDER BY I_ID DESC LIMIT 1)
      AS I)
    as LT)
  as LP;
  INSERT INTO INSULIN VALUES(new_ins_id,CURDATE(),CURTIME(),ins_units,bs_amt);
END;

--------------------------------------------------------------------------------

/*Check stored procedure*/
call insTabAfterMeal(4,92,@m);
select @m;

--------------------------------------------------------------------------------

/*TRIGGER*/
/*to update an anomaly when BS_AM/BS_PM are out of normal ranges*/
CREATE TRIGGER bsNotInRange AFTER UPDATE
ON DiaHCMS.PATIENT
FOR EACH ROW
BEGIN
  DECLARE bsa_id VARCHAR(10);
  DECLARE bs_am FLOAT;
  DECLARE bs_pm FLOAT;
  CALL getNextAnoID(@bsa_id);
  SELECT BS_AM INTO @bs_am FROM DiaHCMS.PATIENT WHERE DiaHCMS.PATIENT.DATE=CURDATE();
  SELECT BS_PM INTO @bs_pm FROM DiaHCMS.PATIENT WHERE DiaHCMS.PATIENT.DATE=CURDATE();
  CASE
    WHEN NEW.bs_am<>OLD.bs_am AND NEW.bs_am<80 THEN
      INSERT INTO DiaHCMS.ANOMALY VALUES(@bsa_id,curdate(),curtime(),NEW.bs_am,'LOW BS_AM');
    WHEN NEW.bs_pm<>OLD.bs_pm AND NEW.bs_pm<90 THEN
      INSERT INTO DiaHCMS.ANOMALY VALUES(@bsa_id,curdate(),curtime(),NEW.bs_pm,'LOW BS_PM');
    WHEN NEW.bs_am<>OLD.bs_am AND NEW.bs_am>130 THEN
      INSERT INTO DiaHCMS.ANOMALY VALUES(@bsa_id,curdate(),curtime(),NEW.bs_am,'HIGH BS_AM');
    WHEN NEW.bs_pm<>OLD.bs_pm AND NEW.bs_pm>150 THEN
      INSERT INTO DiaHCMS.ANOMALY VALUES(@bsa_id,curdate(),curtime(),NEW.bs_pm,'HIGH BS_PM');
    ELSE
      BEGIN
      END;
  END CASE;
END;

--------------------------------------------------------------------------------

/* SAMPLE PARTIAL TRIGGER*/
/*example event to show insertions based on schedule*/
CREATE EVENT peTabInsertion
ON SCHEDULE EVERY 10 SECOND STARTS '2018-11-10 15:21:00'
DO
INSERT INTO DiaHCMS.PE_DONE VALUES('PP01',CURDATE(),CURTIME(),15);

--------------------------------------------------------------------------------

/*PATIENT default entry*/
/*PARTIAL TRIGGER for default entry after 2 seconds*/
CREATE EVENT patientTabInsertion
ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 2 SECOND
DO
INSERT INTO DiaHCMS.PATIENT VALUES(CURDATE(),0.0,'N','N','N',0.0,0.0);

--------------------------------------------------------------------------------

SET GLOBAL event_scheduler = ON;
SHOW EVENTS;
ALTER EVENT myevent ON SCHEDULE EVERY 1 MONTH STARTS '2011-12-01 01:00:00' |

/*scheduled event will run every day at 00:20:00 o’clock*/
CREATE EVENT update_days_taken
ON SCHEDULE EVERY 1 DAY STARTS '2015-06-21 00:20:00'
DO
....
END;

ALTER EVENT update_days_taken
ON SCHEDULE EVERY 12 HOUR STARTS '2015-06-21 00:20:00'
DO
....
END;

--------------------------------------------------------------------------------

/*PATIENT table PARTIAL TRIGGER for default entry on specified date and time*/
create event pin
ON SCHEDULE AT '2018-11-10 14:40:00'
DO
INSERT INTO DiaHCMS.PATIENT VALUES(CURDATE(),0.0,'N','N','N',0.0,0.0);

--------------------------------------------------------------------------------
