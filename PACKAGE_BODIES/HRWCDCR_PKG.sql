--------------------------------------------------------
--  DDL for Package Body HRWCDCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRWCDCR_PKG" AS
--  $Header: pywcdcr.pkb 115.3 99/08/24 11:55:22 porting ship  $
--
--
--
--
PROCEDURE INSERT_ROW( X_ROWID IN OUT      VARCHAR2,
                      X_FUND_ID IN OUT    NUMBER,
                      X_BUSINESS_GROUP_ID NUMBER,
                      X_CARRIER_ID        NUMBER,
                      X_LOCATION_ID       NUMBER,
                      X_STATE_CODE        VARCHAR2,
                      X_CALCULATION_METHOD  VARCHAR2,
                      X_CALCULATION_METHOD2 VARCHAR2,
                      X_CALCULATION_METHOD3 VARCHAR2) IS
BEGIN
hr_utility.set_location('pywcdcr.insert_row', 0);
--
   SELECT PAY_WC_FUNDS_S.NEXTVAL
   INTO   X_FUND_ID
   FROM   DUAL;
--
hr_utility.set_location('pywcdcr.insert_row', 1);
--
   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;
--
hr_utility.set_location('pywcdcr.insert_row', 2);
--
   INSERT INTO PAY_WC_FUNDS
      (FUND_ID, BUSINESS_GROUP_ID, CARRIER_ID, LOCATION_ID,
       STATE_CODE, CALCULATION_METHOD, CALCULATION_METHOD2, CALCULATION_METHOD3)
   VALUES
      (X_FUND_ID, X_BUSINESS_GROUP_ID, X_CARRIER_ID, X_LOCATION_ID,
       X_STATE_CODE, X_CALCULATION_METHOD, X_CALCULATION_METHOD2, X_CALCULATION_METHOD3);
--
hr_utility.set_location('pywcdcr.insert_row', 3);
--
   SELECT ROWID
   INTO   X_ROWID
   FROM   PAY_WC_FUNDS
   WHERE  FUND_ID = X_FUND_ID;
--
hr_utility.set_location('pywcdcr.insert_row', 4);
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
                      X_FUND_ID           NUMBER,
                      X_BUSINESS_GROUP_ID NUMBER,
                      X_CARRIER_ID        NUMBER,
                      X_LOCATION_ID       NUMBER,
                      X_STATE_CODE        VARCHAR2,
                      X_CALCULATION_METHOD  VARCHAR2,
                      X_CALCULATION_METHOD2 VARCHAR2,
                      X_CALCULATION_METHOD3 VARCHAR2) IS
BEGIN
hr_utility.set_location('pywcdcr.update_row', 0);
--
   UPDATE PAY_WC_FUNDS
   SET    FUND_ID             = X_FUND_ID
   ,      BUSINESS_GROUP_ID   = X_BUSINESS_GROUP_ID
   ,      CARRIER_ID          = X_CARRIER_ID
   ,      LOCATION_ID         = X_LOCATION_ID
   ,      STATE_CODE          = X_STATE_CODE
   ,      CALCULATION_METHOD  = X_CALCULATION_METHOD
   ,      CALCULATION_METHOD2 = X_CALCULATION_METHOD2
   ,      CALCULATION_METHOD3 = X_CALCULATION_METHOD3
   WHERE  ROWID = X_ROWID;
--
hr_utility.set_location('pywcdcr.update_row', 1);
--
   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;
--
hr_utility.set_location('pywcdcr.update_row', 2);
--
END UPDATE_ROW;
--
--
--
PROCEDURE DELETE_ROW( X_ROWID             VARCHAR2,
                      X_FUND_ID           NUMBER,
                      X_BUSINESS_GROUP_ID NUMBER,
                      X_CARRIER_ID        NUMBER,
                      X_LOCATION_ID       NUMBER,
                      X_STATE_CODE        VARCHAR2,
                      X_CALCULATION_METHOD  VARCHAR2,
                      X_CALCULATION_METHOD2 VARCHAR2,
                      X_CALCULATION_METHOD3 VARCHAR2) IS
BEGIN
hr_utility.set_location('pywcdcr.delete_row', 0);
--
   DELETE FROM PAY_WC_FUNDS
   WHERE  ROWID = X_ROWID;
--
hr_utility.set_location('pywcdcr.delete_row', 1);
--
   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;
--
hr_utility.set_location('pywcdcr.delete_row', 2);
--
END DELETE_ROW;
--
--
--
PROCEDURE LOCK_ROW( X_ROWID             VARCHAR2,
                    X_FUND_ID           NUMBER,
                    X_BUSINESS_GROUP_ID NUMBER,
                    X_CARRIER_ID        NUMBER,
                    X_LOCATION_ID       NUMBER,
                    X_STATE_CODE        VARCHAR2,
                    X_CALCULATION_METHOD  VARCHAR2,
                    X_CALCULATION_METHOD2 VARCHAR2,
                    X_CALCULATION_METHOD3 VARCHAR2) IS
--
   CURSOR C IS
   SELECT *
   FROM   PAY_WC_FUNDS
   WHERE  ROWID = X_ROWID
   FOR    UPDATE OF FUND_ID NOWAIT;
--
   RECINFO C%ROWTYPE;
--
BEGIN

hr_utility.set_location('pywcdcr.lock_row', 0);
--
   OPEN C;
   FETCH C INTO RECINFO;
   IF (C%NOTFOUND) THEN
      CLOSE C;
      RAISE NO_DATA_FOUND;
   END IF;
   CLOSE C;
--
hr_utility.set_location('pywcdcr.lock_row', 1);
--
--
-- rtrim char fields
--
Recinfo.state_code := RTRIM(Recinfo.state_code);
--
hr_utility.set_location('pywcdcr.lock_row', 2);
--
   IF( ( ( RECINFO.FUND_ID = X_FUND_ID)
      OR ( RECINFO.FUND_ID IS NULL AND X_FUND_ID IS NULL))
    AND
       ( ( RECINFO.BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID)
      OR ( RECINFO.BUSINESS_GROUP_ID IS NULL AND X_BUSINESS_GROUP_ID IS NULL))
    AND
       ( ( RECINFO.CARRIER_ID = X_CARRIER_ID)
      OR ( RECINFO.CARRIER_ID IS NULL AND X_CARRIER_ID IS NULL))
    AND
       ( ( RECINFO.LOCATION_ID = X_LOCATION_ID)
      OR ( RECINFO.LOCATION_ID IS NULL AND X_LOCATION_ID IS NULL))
    AND
       ( ( RECINFO.STATE_CODE = X_STATE_CODE)
      OR ( RECINFO.STATE_CODE IS NULL AND X_STATE_CODE IS NULL))
    AND
       ( ( RECINFO.CALCULATION_METHOD = X_CALCULATION_METHOD)
      OR ( RECINFO.CALCULATION_METHOD IS NULL AND X_CALCULATION_METHOD IS NULL))
    AND
       ( ( RECINFO.CALCULATION_METHOD2 = X_CALCULATION_METHOD2)
      OR ( RECINFO.CALCULATION_METHOD2 IS NULL AND X_CALCULATION_METHOD2 IS NULL))
    AND
       ( ( RECINFO.CALCULATION_METHOD3 = X_CALCULATION_METHOD3)
      OR ( RECINFO.CALCULATION_METHOD3 IS NULL AND X_CALCULATION_METHOD3 IS NULL))
     ) THEN
--
hr_utility.set_location('pywcdcr.lock_row', 3);
--
      RETURN;
   ELSE
--
hr_utility.set_location('pywcdcr.lock_row', 4);
--
      hr_utility.set_message(0, 'FORM_RECORD_CHANGED');
      hr_utility.raise_error;
   END IF;
--
END LOCK_ROW;
--
--
PROCEDURE CARRIER_STATE_LOC_UNIQUE( P_ROWID       VARCHAR2,
                                    P_CARRIER_ID  NUMBER,
                                    P_STATE_CODE  VARCHAR2,
                                    P_LOCATION_ID NUMBER) IS
--
--
l_comb_exists VARCHAR2(2);
--
CURSOR DUP_REC IS
SELECT 'Y'
FROM   PAY_WC_FUNDS
WHERE  CARRIER_ID = P_CARRIER_ID
AND    STATE_CODE = P_STATE_CODE
AND  ((LOCATION_ID = P_LOCATION_ID
   AND P_LOCATION_ID IS NOT NULL)
 OR   (LOCATION_ID IS NULL
   AND P_LOCATION_ID IS NULL))
AND  ((ROWID <> P_ROWID
   AND P_ROWID IS NOT NULL)
 OR
      (P_ROWID IS NULL));
--
--
BEGIN
--
hr_utility.set_location('pywcdcr.carrier_state_loc_unique', 0);
--
--
-- initialise variable
   l_comb_exists := 'N';
--
-- open fetch and close the cursor - if a record is found then the local
-- variable will be set to 'Y', otherwise it will remain 'N'
--
   OPEN DUP_REC;
   FETCH DUP_REC INTO l_comb_exists;
   CLOSE DUP_REC;
--
hr_utility.set_location('pywcdcr.carrier_state_loc_unique', 1);
--
-- go ahead and check the value of the local variable - if it's 'Y' then this
-- record is duplicated
--
   IF (l_comb_exists = 'Y')
   THEN
      hr_utility.set_message(801, 'HR_13104_WC_FUND_STATE_LOC_DUP');
      hr_utility.raise_error;
   END IF;
--
hr_utility.set_location('pywcdcr.carrier_state_loc_unique', 2);
--
--
END CARRIER_STATE_LOC_UNIQUE;
--
--
PROCEDURE FUND_WC_CODE_UNIQUE( P_ROWID   VARCHAR2,
                               P_FUND_ID NUMBER,
                               P_WC_CODE NUMBER) IS
--
--
l_comb_exists VARCHAR2(2);
--
CURSOR DUP_REC IS
SELECT 'Y'
FROM   PAY_WC_RATES
WHERE  FUND_ID = P_FUND_ID
AND    WC_CODE = P_WC_CODE
AND  ((ROWID <> P_ROWID
   AND P_ROWID IS NOT NULL)
 OR
      (P_ROWID IS NULL));
--
--
BEGIN
--
hr_utility.set_location('pywcdcr.fund_wc_code_unique', 0);
--
-- initialise variable
   l_comb_exists := 'N';
--
-- open fetch and close the cursor - if a record is found then the local
-- variable will be set to 'Y', otherwise it will remain 'N'
--
   OPEN DUP_REC;
   FETCH DUP_REC INTO l_comb_exists;
   CLOSE DUP_REC;
--
hr_utility.set_location('pywcdcr.fund_wc_code_unique', 1);
--
-- go ahead and check the value of the local variable - if it's 'Y' then this
-- record is duplicated
--
   IF (l_comb_exists = 'Y')
   THEN
      hr_utility.set_message(801, 'HR_13105_WC_DUP_WC_CODE');
      hr_utility.raise_error;
   END IF;
--
hr_utility.set_location('pywcdcr.fund_wc_code_unique', 2);
--
--
END FUND_WC_CODE_UNIQUE;
--
--
PROCEDURE CODES_AND_RATES_EXIST( P_FUND_ID NUMBER) IS
--
--
l_rec_exists VARCHAR2(2);
--
CURSOR REC_EXISTS IS
SELECT 'Y'
FROM   PAY_WC_RATES
WHERE  FUND_ID = P_FUND_ID;
--
--
BEGIN
--
hr_utility.set_location('pywcdcr.codes_and_rates_exist', 0);
--
-- initialise variable
   l_rec_exists := 'N';
--
-- open fetch and close the cursor - if a record is found then the local
-- variable will be set to 'Y', otherwise it will remain 'N'
--
   OPEN REC_EXISTS;
   FETCH REC_EXISTS INTO l_rec_exists;
   CLOSE REC_EXISTS;
--
hr_utility.set_location('pywcdcr.codes_and_rates_exist', 1);
--
-- go ahead and check the value of the local variable - if it's 'Y' then this
-- record is duplicated
--
   IF (l_rec_exists = 'Y')
   THEN
      hr_utility.set_message(801, 'HR_13106_WC_CODES_RATES_EXIST');
      hr_utility.raise_error;
   END IF;
--
hr_utility.set_location('pywcdcr.codes_and_rates_exist', 2);
--
--
END CODES_AND_RATES_EXIST;
--
--
PROCEDURE CODE_IN_USE ( P_FUND_ID           NUMBER,
                        P_STATE_CODE        VARCHAR2,
                        P_ROWID             VARCHAR2,
                        P_WC_CODE           NUMBER,
                        P_BUSINESS_GROUP_ID NUMBER,
                        P_CARRIER_ID        NUMBER,
                        P_LOCATION_ID       NUMBER) IS
--
-- Overview
--
-- This validation ensures that a WC code is not deleted if there are either
--
--    a) any jobs using this code (for the specified state code)
--
--    b) if there are any WC overrides using the code
--
-- Case b) (above) is not entirely straightforward: WC codes/rates are
-- defined either for a specific location (ie a location_id is present) or
-- the user can leave the location null. When the location is left null then
-- that code/rate is treated as the default. There can be many instances of
-- the same code being defined more than once for a given fund - eg the
-- California State Fund may have a rate set up for San Francisco, another
-- for Los Angeles, another for Sacremento and a rate which is used for all
-- other locations in California: all of these rates use the same WC code.
-- When determining whether it is possible to delete a WC code/rate record
-- you must ensure any assignment's override is valid. For example, if the
-- user attempted to delete the code 1234 which has been set up for Los
-- Angeles, then the validation must ensure that there is a default code/rate
-- which can be used (ie the location code is null); similarly, if the
-- user wishes to delete the default rates then the validation must ensure
-- that each override is valid (ie using the above example all assignments
-- which use an override WC code must have a location of either San
-- Francisco, Los Angeles or Sacremento).
--
-- When attempting to validate b) there are three possible scenarios -
--
--   i) there is only one occurrance of the WC code defined for the state:
--   therefore if any overrides are using this code then disallow the delete
--
--   ii) there are multiple occurrences of the WC code defined for the state:
--   in this case check if there are any overrides using this code -
--
--      if there are any then ensure that these overrides are still valid
--      (ie it is still possible to find a rate based on the location, SUI
--      state and organization)
--
--      if there are no overrides using this code then go ahead and do the
--      delete
--
--
-- The validation is split into two, depending on how many occurrences of
-- the code exist for the state -
--
--   a) if there is only one occurrence of this code (ie the record being
--   deleted is the only one) then disallow the delete if there are any
--   jobs using the WC code, or if there are any overrides using this code
--
--   b) there are multiple occurrences of this code then you do not need to
--   check the job wc code usages table to see if a job is using this code;
--   you will need to ensure that any overrides using this code are still
--   valid.
--
--
--
--
-- OK, here's the code...
--
l_rec_exists VARCHAR2(2);
--
--
-- determines whether there are any other funds for the same state using the
-- same WC code as the one about to be deleted
--
CURSOR SAME_CODE_EXISTS IS
SELECT 'Y'
FROM   PAY_WC_FUNDS WCF
WHERE  WCF.STATE_CODE = P_STATE_CODE
AND    WCF.ROWID <> P_ROWID
AND    EXISTS (
          SELECT 1
          FROM   PAY_WC_RATES WCR
          WHERE  WCR.FUND_ID = WCF.FUND_ID
          AND    WCR.WC_CODE = P_WC_CODE);
--
--
-- determines whether any jobs are using the WC code about to be deleted
-- (need only check for records in the same US state)
--
CURSOR CODE_USED_BY_JOB IS
SELECT 'Y'
FROM   PAY_JOB_WC_CODE_USAGES
WHERE  STATE_CODE = P_STATE_CODE
AND    WC_CODE = P_WC_CODE
AND    BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID;
--
--
-- determines whether there are any assignment SCLs using the
-- soon-to-be-deleted WC code override
--
-- note the convoluted access path -> in English, the query must find all
-- assignment SCL where the override WC code = the one about to be deleted;
-- this search has a context of US state, so we must restrict the assignments
-- by the WC Fund's state (ie we are deleting a Californian code, so we
-- should only check assignments with a SUI state for California) - the SUI
-- state is held on yet more SCL, but hidden by a view (PAY_EMP_FED_TAX_V1);
-- finally, we restrict the search to assignments which use the carrier as
-- defined by the fund - yep, you've got it - more SCL - an assignment's SCL
-- holds the tax unit and the tax unit holds the WC carrier id in (drum role)
-- more SCL.
--
-- It's all very simple, really.
--
CURSOR ONE_CODE_AND_OVERRIDES_EXIST IS
SELECT 'Y'
FROM   HR_ORGANIZATION_INFORMATION ORG
,      PAY_US_EMP_FED_TAX_RULES_F EFT
,      PER_ALL_ASSIGNMENTS_F ASS
,      HR_SOFT_CODING_KEYFLEX SCF
,      FND_ID_FLEX_STRUCTURES_VL IFS
WHERE  ORG.ORG_INFORMATION8 = P_CARRIER_ID
AND    ORG.ORG_INFORMATION1 = P_STATE_CODE
AND    ORG.ORG_INFORMATION_CONTEXT = 'State Tax Rules'
AND    ORG.ORGANIZATION_ID = SCF.SEGMENT1
AND    EFT.SUI_STATE_CODE = P_STATE_CODE
AND    EFT.ASSIGNMENT_ID = ASS.ASSIGNMENT_ID
AND    ASS.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
AND    ASS.SOFT_CODING_KEYFLEX_ID = SCF.SOFT_CODING_KEYFLEX_ID
AND    SCF.SEGMENT8 = TO_CHAR(P_WC_CODE)
AND    SCF.ID_FLEX_NUM = IFS.ID_FLEX_NUM
AND    IFS.ID_FLEX_STRUCTURE_NAME = 'GREs and other data';
--
--
CURSOR MANY_CODES_AND_OVERRIDES_EXIST IS
SELECT 'Y'
FROM   HR_ORGANIZATION_INFORMATION ORG
,      PAY_US_EMP_FED_TAX_RULES_F EFT
,      PER_ALL_ASSIGNMENTS_F ASS
,      HR_SOFT_CODING_KEYFLEX SCF
,      FND_ID_FLEX_STRUCTURES_VL IFS
WHERE  ORG.ORG_INFORMATION8 = P_CARRIER_ID
AND    ORG.ORG_INFORMATION1 = P_STATE_CODE
AND    ORG.ORG_INFORMATION_CONTEXT = 'State Tax Rules'
AND    ORG.ORGANIZATION_ID = SCF.SEGMENT1
AND    EFT.SUI_STATE_CODE = P_STATE_CODE
AND    EFT.ASSIGNMENT_ID = ASS.ASSIGNMENT_ID
AND    ASS.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
AND    ASS.SOFT_CODING_KEYFLEX_ID = SCF.SOFT_CODING_KEYFLEX_ID
AND    SCF.SEGMENT8 = TO_CHAR(P_WC_CODE)
AND    SCF.ID_FLEX_NUM = IFS.ID_FLEX_NUM
AND    IFS.ID_FLEX_STRUCTURE_NAME = 'GREs and other data'
AND    NOT EXISTS (
          SELECT 1
          FROM   PAY_WC_FUNDS WCF
          WHERE  WCF.CARRIER_ID = P_CARRIER_ID
          AND    WCF.STATE_CODE = P_STATE_CODE
          AND    WCF.ROWID <> P_ROWID
          AND  ((WCF.LOCATION_ID IS NULL)
           OR   (WCF.LOCATION_ID = P_LOCATION_ID
             AND WCF.LOCATION_ID IS NOT NULL
             AND P_LOCATION_ID IS NOT NULL)));
--
--
BEGIN
hr_utility.set_location('pywcdcr.code_in_use', 0);
--
   -- initialise variable
   --
   l_rec_exists := 'N';
   --
   -- open fetch and close the cursor - if a record is found then the local
   -- variable will be set to 'Y', otherwise it will remain 'N'
   --
   OPEN SAME_CODE_EXISTS;
   FETCH SAME_CODE_EXISTS INTO l_rec_exists;
   CLOSE SAME_CODE_EXISTS;
   --
hr_utility.set_location('pywcdcr.code_in_use', 1);
   --
   -- go ahead and check the value of the local variable - if it's 'Y' then
   -- another fund is using this code; so we can just go ahead and do the delete
   --
   IF (l_rec_exists = 'Y') THEN
      --
hr_utility.set_location('pywcdcr.code_in_use', 2);
      --
      -- re-initialise variable
      --
      l_rec_exists := 'N';
      --
      -- see if there any any overrides which would be invalid if this code
      -- was deleted
      --
      OPEN MANY_CODES_AND_OVERRIDES_EXIST;
      FETCH MANY_CODES_AND_OVERRIDES_EXIST INTO l_rec_exists;
      CLOSE MANY_CODES_AND_OVERRIDES_EXIST;
      --
hr_utility.set_location('pywcdcr.code_in_use', 3);
      --
      -- if a record exists then raise error and tell user that the code is
      -- in use
      --
      IF (l_rec_exists = 'Y')
      THEN
         hr_utility.set_message(801, 'HR_13129_WC_CODE_IS_OVERRIDE');
         hr_utility.raise_error;
      END IF;
hr_utility.set_location('pywcdcr.code_in_use', 4);
      --
   ELSE
      --
hr_utility.set_location('pywcdcr.code_in_use', 5);
      --
      -- this WC code is not defined for this state anywhere else; check to see
      -- if this WC code is associated with any jobs
      --
      --
      -- re-initialise variable
      --
      l_rec_exists := 'N';
      --
      -- see if any jobs are using this code
      --
      OPEN CODE_USED_BY_JOB;
      FETCH CODE_USED_BY_JOB INTO l_rec_exists;
      CLOSE CODE_USED_BY_JOB;
      --
hr_utility.set_location('pywcdcr.code_in_use', 6);
      --
      -- if a record exists then raise error and tell user that the code is
      -- in use
      --
      IF (l_rec_exists = 'Y')
      THEN
         hr_utility.set_message(801, 'HR_13128_WC_CODE_USED_BY_JOB');
         hr_utility.raise_error;
      END IF;
      --
hr_utility.set_location('pywcdcr.code_in_use', 7);
      --
      --
      -- if we've got this far then we need to see if this code is being used
      -- as an override on the assignment SCL!!!
      --
      --
      -- re-initialise variable
      --
      l_rec_exists := 'N';
      --
      -- now see if any assignments are using this code
      --
      OPEN ONE_CODE_AND_OVERRIDES_EXIST;
      FETCH ONE_CODE_AND_OVERRIDES_EXIST INTO l_rec_exists;
      CLOSE ONE_CODE_AND_OVERRIDES_EXIST;
      --
hr_utility.set_location('pywcdcr.code_in_use', 8);
      --
      -- if a record exists then raise error and tell user that the code is
      -- in use
      --
      IF (l_rec_exists = 'Y')
      THEN
         hr_utility.set_message(801, 'HR_13129_WC_CODE_IS_OVERRIDE');
         hr_utility.raise_error;
      END IF;
      --
hr_utility.set_location('pywcdcr.code_in_use', 9);
      --
   END IF;
      --
hr_utility.set_location('pywcdcr.code_in_use', 10);
      --
END CODE_IN_USE;
--
--
--
--
--
END HRWCDCR_PKG;

/
