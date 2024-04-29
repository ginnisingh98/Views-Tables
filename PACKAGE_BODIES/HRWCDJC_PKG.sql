--------------------------------------------------------
--  DDL for Package Body HRWCDJC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRWCDJC_PKG" AS
/* $Header: pywcdjc.pkb 115.1 99/07/17 06:50:10 porting ship  $ */
--
--
--
--
PROCEDURE INSERT_ROW( X_ROWID IN OUT      VARCHAR2,
                      X_STATE_CODE        VARCHAR2,
                      X_BUSINESS_GROUP_ID NUMBER,
                      X_JOB_ID            NUMBER,
                      X_WC_CODE           NUMBER) IS
BEGIN
--
   INSERT INTO PAY_JOB_WC_CODE_USAGES
      (STATE_CODE, BUSINESS_GROUP_ID, JOB_ID, WC_CODE)
   VALUES
      (X_STATE_CODE, X_BUSINESS_GROUP_ID, X_JOB_ID, X_WC_CODE);
--
   SELECT ROWID
   INTO   X_ROWID
   FROM   PAY_JOB_WC_CODE_USAGES
   WHERE  STATE_CODE = X_STATE_CODE
   AND    JOB_ID = X_JOB_ID;
--
   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;
--
END INSERT_ROW;
--
--
--
PROCEDURE UPDATE_ROW( X_ROWID             VARCHAR2,
                      X_STATE_CODE        VARCHAR2,
                      X_BUSINESS_GROUP_ID NUMBER,
                      X_JOB_ID            NUMBER,
                      X_WC_CODE           NUMBER) IS
BEGIN
--
   UPDATE PAY_JOB_WC_CODE_USAGES
   SET    STATE_CODE        = X_STATE_CODE
   ,      BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID
   ,      JOB_ID            = X_JOB_ID
   ,      WC_CODE           = X_WC_CODE
   WHERE  ROWID = X_ROWID;
--
   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;
--
END UPDATE_ROW;
--
--
--
PROCEDURE DELETE_ROW( X_ROWID             VARCHAR2,
                      X_STATE_CODE        VARCHAR2,
                      X_BUSINESS_GROUP_ID NUMBER,
                      X_JOB_ID            NUMBER,
                      X_WC_CODE           NUMBER) IS
BEGIN
--
   DELETE FROM PAY_JOB_WC_CODE_USAGES
   WHERE  ROWID = X_ROWID;
--
   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;
--
END DELETE_ROW;
--
--
--
PROCEDURE LOCK_ROW( X_ROWID             VARCHAR2,
                    X_STATE_CODE        VARCHAR2,
                    X_BUSINESS_GROUP_ID NUMBER,
                    X_JOB_ID            NUMBER,
                    X_WC_CODE           NUMBER) IS
--
   CURSOR C IS
   SELECT *
   FROM   PAY_JOB_WC_CODE_USAGES
   WHERE  ROWID = X_ROWID
   FOR    UPDATE OF STATE_CODE NOWAIT;
--
   RECINFO C%ROWTYPE;
--
BEGIN
--
   OPEN C;
   FETCH C INTO RECINFO;
   IF (C%NOTFOUND) THEN
      CLOSE C;
      RAISE NO_DATA_FOUND;
   END IF;
   CLOSE C;
--
-- rtrim char columns
--
Recinfo.state_code := RTRIM(Recinfo.state_code);
--
   IF( ( ( RECINFO.STATE_CODE = X_STATE_CODE)
      OR ( RECINFO.STATE_CODE IS NULL AND X_STATE_CODE IS NULL))
    AND
       ( ( RECINFO.BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID)
      OR ( RECINFO.BUSINESS_GROUP_ID IS NULL AND X_BUSINESS_GROUP_ID IS NULL))
    AND
       ( ( RECINFO.JOB_ID = X_JOB_ID)
      OR ( RECINFO.JOB_ID IS NULL AND X_JOB_ID IS NULL))
    AND
       ( ( RECINFO.WC_CODE = X_WC_CODE)
      OR ( RECINFO.WC_CODE IS NULL AND X_WC_CODE IS NULL))
     ) THEN
      RETURN;
   ELSE
--      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
--      APP_EXCEPTION.RAISE_EXCEPTION;
      hr_utility.set_message(0, 'FORM_RECORD_CHANGED');
      hr_utility.raise_error;
   END IF;
--
END LOCK_ROW;
--
--
PROCEDURE JOB_STATE_UNIQUE( P_ROWID      VARCHAR2,
                            P_STATE_CODE VARCHAR2,
                            P_JOB_ID     NUMBER) IS
--
--
l_job_exists VARCHAR2(2);
--
CURSOR DUP_JOB IS
SELECT 'Y'
FROM   PAY_JOB_WC_CODE_USAGES
WHERE  STATE_CODE = P_STATE_CODE
AND    JOB_ID = P_JOB_ID
AND  ((ROWID <> P_ROWID
   AND P_ROWID IS NOT NULL)
 OR
      (P_ROWID IS NULL));
--
--
BEGIN
--
--
-- initialise variable
   l_job_exists := 'N';
--
-- open fetch and close the cursor - if a record is found then the local
-- variable will be set to 'Y', otherwise it will remain 'N'
--
   OPEN DUP_JOB;
   FETCH DUP_JOB INTO l_job_exists;
   CLOSE DUP_JOB;
--
-- go ahead and check the value of the local variable - if it's 'Y' then this
-- job has already got a WC code for the state
--
   IF (l_job_exists = 'Y')
   THEN
      hr_utility.set_message(801, 'HR_13102_WC_ONE_WCCODE_PER_JOB');
      hr_utility.raise_error;
   END IF;
--
--
END JOB_STATE_UNIQUE;
--
--
--
--
END HRWCDJC_PKG;

/
