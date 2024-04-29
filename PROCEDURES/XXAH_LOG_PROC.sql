--------------------------------------------------------
--  DDL for Procedure XXAH_LOG_PROC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."XXAH_LOG_PROC" (p_log VARCHAR2)
AS PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  SAVEPOINT sav1;

  INSERT INTO xxah_log_tab(
    sequence
  , timestamp
  , log)
  VALUES(
    xxah_log_tab_s.nextval
  , sysdate
  , p_log
  );

  COMMIT;

EXCEPTION WHEN OTHERS THEN
  ROLLBACK TO sav1;
END xxah_log_proc;
 

/
