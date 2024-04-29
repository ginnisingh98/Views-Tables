--------------------------------------------------------
--  DDL for Package Body GL_FLATTEN_LEDGER_SEG_VALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_FLATTEN_LEDGER_SEG_VALS" AS
/* $Header: glufllvb.pls 120.9 2006/03/15 22:06:19 spala ship $ */

 -- ********************************************************************
-- FUNCTION
--   FIX_BY_COA
-- PURPOSE
--   This function  is the entry point when flattening program is called in
--   LV mode, it indicates changes in the ledger definition.
-- HISTORY
--   06-04-2001       Srini Pala    Created
-- ARGUMENTS
-- EXAMPLE
--   RET_STATUS := FIX_BY_COA()
--


  FUNCTION  FIX_BY_COA RETURN    BOOLEAN IS

    l_number_of_rows           NUMBER    := 0;
    ret_val                    BOOLEAN   := TRUE;
    GLSTFL_FATAL_ERR	       EXCEPTION;
    l_status_flag              VARCHAR2(1);
  BEGIN

    GL_MESSAGE.FUNC_ENT (FUNC_NAME =>
                        'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa');


    -- The flow of this routine is as follows
    -- First clean records with status_code 'I' and update records with
    -- status_code ='D' to NULL in the GL_LEDGER_SEGMENT_VALUES table
    -- Detect any changes in GL_LEDGER_NORM_SEG_VALS table, then mainatain
    -- GL_LEDGER_SEGMENT_VALUES based on these changes.
    -- Calls routine Error_Check to makesure that the data is fine.


    -- Cleaning GL_LEDGER_SEGMENT_VALUES before processing

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_DEBUG) THEN
      GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0180',
                            TOKEN_NUM => 2,
                            T1        =>'ROUTINE',
                            V1        =>
                                     'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa()',
                            T2        =>'ACTION',
                            V2        =>'DELETING RECORDS WITH STATUS CODE I '
                                      ||' IN THE TABLE'
                                      ||' GL_LEDGER_SEGMENT_VALUES');
    END IF;

    -- To improve performance for bug fix # 5075776
       l_status_flag := 'I';

    DELETE
    FROM  GL_LEDGER_SEGMENT_VALUES
    WHERE STATUS_CODE = l_status_flag
    AND   LEDGER_ID IN
         (SELECT LEDGER_ID
          FROM   GL_LEDGERS
          WHERE  CHART_OF_ACCOUNTS_ID = GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID);

    L_Number_Of_Rows := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0119',
                          TOKEN_NUM =>2,
                          T1        =>'NUM',
                          V1        => TO_CHAR(L_NUMBER_OF_ROWS),
                          T2        =>'TABLE',
                          V2        =>'GL_LEDGER_SEGMENT_VALUES');


    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_DEBUG) THEN
      GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0180',
                            TOKEN_NUM => 2,
                            T1        =>'ROUTINE',
                            V1        =>
                                     'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa()',
                            T2        =>'ACTION',
                            V2        =>'Updating records with status code D'
                                      ||' in the table'
                                      ||' GL_LEDGER_SEGMENT_VALUES');
    END IF;

    UPDATE GL_LEDGER_SEGMENT_VALUES
    SET    status_code = NULL
    WHERE  status_code  = 'D'
    AND    ledger_id IN
          (SELECT ledger_id
           FROM GL_LEDGERS
           WHERE chart_of_accounts_id = GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID);

    L_Number_Of_Rows := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0118',
                          TOKEN_NUM =>2,
                          T1        =>'NUM',
                          V1        => TO_CHAR(L_NUMBER_OF_ROWS),
                          T2        =>'TABLE',
                          V2        =>'GL_LEDGER_SEGMENT_VALUES');

    FND_CONCURRENT.AF_COMMIT;  -- COMMIT Point

    -- Update Start_Date/End_Date In GL_LEDGER_SEGMENT_VALUES

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_DEBUG) THEN
      GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0180',
                            TOKEN_NUM => 2,
                            T1        =>'ROUTINE',
                            V1        =>
                                     'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa()',
                            T2        =>'ACTION',
                            V2        =>'UPDATING START_DATE/END_DATE'
                                      ||' IN THE TABLE'
                                      ||' GL_LEDGER_SEGMENT_VALUES');
    END IF;

    UPDATE GL_LEDGER_SEGMENT_VALUES GLLSV
    SET   (GLLSV.START_DATE, GLLSV.END_DATE) =
          (SELECT GLLNSV.START_DATE, GLLNSV.END_DATE
           FROM   GL_LEDGER_NORM_SEG_VALS GLLNSV
           WHERE  GLLNSV.RECORD_ID = GLLSV.PARENT_RECORD_ID)
    WHERE  GLLSV.PARENT_RECORD_ID IN
          (SELECT GLLNSV2.RECORD_ID
           FROM   GL_LEDGERS GLL,
                  GL_LEDGER_NORM_SEG_VALS GLLNSV2
           WHERE  GLL.CHART_OF_ACCOUNTS_ID =
                      GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
           AND    GLLNSV2.STATUS_CODE = 'U'
           AND    GLLNSV2.REQUEST_ID =
                  GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
           AND    GLLNSV2.LEDGER_ID = GLL.LEDGER_ID);

    L_Number_Of_Rows := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0118',
                          TOKEN_NUM =>2,
                          T1        =>'NUM',
                          V1        => TO_CHAR(L_NUMBER_OF_ROWS),
                          T2        =>'TABLE',
                          V2        =>'GL_LEDGER_SEGMENT_VALUES');

    -- Marking outdated records in GL_LEDGER_SEGMENT_VALUES for delete.

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_DEBUG) THEN
      GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0180',
                            TOKEN_NUM => 2,
                            T1        =>'ROUTINE',
                            V1        =>
                                     'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa()',
                            T2        =>'ACTION',
                            V2        =>'Updating outdated records'
                                     ||' in the table'
                                     ||' GL_LEDGER_SEGMENT_VALUES for delete');
    END IF;

    UPDATE GL_LEDGER_SEGMENT_VALUES
    SET   STATUS_CODE = 'D'
    WHERE PARENT_RECORD_ID IN
          (SELECT RECORD_ID
           FROM  GL_LEDGERS GLL,
                 GL_LEDGER_NORM_SEG_VALS GLLNSV
           WHERE GLL.CHART_OF_ACCOUNTS_ID =
                     GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
           AND   GLLNSV.STATUS_CODE = 'D'
           AND   GLLNSV.LEDGER_ID   = GLL.LEDGER_ID);

    L_Number_Of_Rows := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0118',
                          TOKEN_NUM =>2,
                          T1        =>'NUM',
                          V1        => TO_CHAR(l_number_of_rows),
                          T2        =>'TABLE',
                          V2        =>'GL_LEDGER_SEGMENT_VALUES');

    -- Inserting new Ledger-Segment value assignments into the table
    -- GL_LEDGER_SEGMENT_VALUES.

    -- The following statement inserts a record into GL_LEDGER_SEGMENT_VALUES
    -- table for every new record in GL_LEDGER_NORM_SEG_VALS with
    -- status_code 'I' and segment_value_type_code of 'S'.

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_DEBUG) THEN
      GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0180',
                            TOKEN_NUM => 2,
                            T1        =>'ROUTINE',
                            V1        =>
                                     'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa()',
                            T2        =>'ACTION',
                            V2        =>'Inserting new record(S) Into'
                                      ||' GL_LEDGER_SEGMENT_VALUES'
                                      ||' for every record with status code I '
                                      ||' and segment_value_type_code of S'
                                      ||' in the table'
                                      ||' GL_LEDGER_NORM_SEG_VALS ');
    END IF;

    INSERT INTO GL_LEDGER_SEGMENT_VALUES
           (LEDGER_ID, SEGMENT_TYPE_CODE, SEGMENT_VALUE, STATUS_CODE,
            PARENT_RECORD_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
            CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, START_DATE,
            END_DATE)
           (SELECT GLLNSV.LEDGER_ID, GLLNSV.SEGMENT_TYPE_CODE,
                   GLLNSV.SEGMENT_VALUE, 'I', GLLNSV.RECORD_ID,
                   SYSDATE,
                   GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
                   SYSDATE,
                   GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
                    GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID,
                   GLLNSV.START_DATE, GLLNSV.END_DATE
            FROM   GL_LEDGERS GLL,
                   GL_LEDGER_NORM_SEG_VALS GLLNSV
            WHERE  GLL.CHART_OF_ACCOUNTS_ID =
                       GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
            AND    GLLNSV.LEDGER_ID = GLL.LEDGER_ID
            AND    GLLNSV.STATUS_CODE = 'I'
            AND    GLLNSV.REQUEST_ID =
                   GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
            AND    GLLNSV.SEGMENT_VALUE_TYPE_CODE = 'S');

    L_Number_Of_Rows := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0117',
                            TOKEN_NUM =>2,
                            T1        =>'NUM',
                            V1        =>TO_CHAR(L_NUMBER_OF_ROWS),
                            T2        =>'TABLE',
                            V2        =>'GL_LEDGER_SEGMENT_VALUES');
    l_number_of_rows := 0;

    -- The following statement inserts a record into GL_LEDGER_SEGMENT_VALUES
    -- table for every new record in GL_LEDGER_NORM_SEG_VALS with
    -- status_code 'I' and segment_value_type_code of 'C'.

    If (GL_FLATTEN_SETUP_DATA.GLSTFL_DEBUG) THEN
      GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0180',
                            TOKEN_NUM => 2,
                            T1        =>'ROUTINE',
                            V1        =>
                                     'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa()',
                            T2        =>'ACTION',
                            V2        =>'INSERT NEW RECORD(S) INTO'
                                      ||' GL_LEDGER_SEGMENT_VALUES'
                                      ||' FOR EVERY RECORD WITH STATUS CODE I '
                                      ||' AND SEGMENT_VALUE_TYPE_CODE OF C'
                                      ||' IN THE TABLE'
                                      ||' GL_LEDGER_NORM_SEG_VALS ');
    END IF;

   -- Obtain a shared Lock on balancing and management value set ids

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE =  'VH') OR
         (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE =  'LV')THEN

      IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
        GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0181',
			      token_num	=> 3,
			      t1	=> 'ROUTINE',
			      v1	=>
                              'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa()',
			      t2 	=> 'VARIABLE',
			      v2	=> 'GLSTFL_Bal_Vs_Id',
			      t3	=> 'VALUE',
			      v3	=>
                              TO_CHAR(GL_FLATTEN_SETUP_DATA.GLSTFL_Bal_Vs_Id));

        GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0181',
			      token_num	=> 3,
			      t1	=> 'ROUTINE',
			      v1	=>
                              'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa()',
			      t2 	=> 'VARIABLE',
			      v2	=> 'GLSTFL_Mgt_Vs_Id',
			      t3	=> 'VALUE',
			      v3	=>
                              TO_CHAR(GL_FLATTEN_SETUP_DATA.GLSTFL_Mgt_Vs_Id));
      END IF;

      IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
        GL_MESSAGE.Write_Log
	  (msg_name  => 'SHRD0180',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa()',
           t2        => 'ACTION',
           v2        => 'Obtain shared lock on balancing segment...');
      END IF;

      ret_val := GL_FLATTEN_SETUP_DATA.Request_Lock
			(X_Param_Type 	=> 'V',
			 X_Param_Id   	=>
                                        GL_FLATTEN_SETUP_DATA.GLSTFL_Bal_Vs_Id,
			 X_Lock_Mode  	=> 4,  -- SHARED mode
			 X_Keep_Looping	=> TRUE,
			 X_Max_Trys	=> 5);

      IF (NOT ret_val) THEN
	RAISE GLSTFL_fatal_err;
      END IF;

      IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
        GL_MESSAGE.Write_Log
	  (msg_name  => 'SHRD0180',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa()',
           t2        => 'ACTION',
           v2        => 'Obtain shared lock on management segment...');
      END IF;

      -- If mgt_vs_id is different from bal_vs_id, obtain SHARED lock for
      -- management segment Value set id

      IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Bal_Vs_Id <>
                           GL_FLATTEN_SETUP_DATA.GLSTFL_Mgt_Vs_Id) THEN

         ret_val := GL_FLATTEN_SETUP_DATA.Request_Lock
		    (X_Param_Type 	=> 'V',
		     X_Param_Id   	=>
                                        GL_FLATTEN_SETUP_DATA.GLSTFL_Mgt_Vs_Id,
	             X_Lock_Mode  	=> 4,  -- SHARED mode
                     X_Keep_Looping	=> TRUE,
                     X_Max_Trys	        => 5);

          IF (NOT ret_val) THEN
	    RAISE GLSTFL_fatal_err;
          END IF;

      END IF;

    END IF; -- End for operation mode 'VH'

    -- These locks will be released in GL_FLATTEN_SETUP_DATA.Main()package
    -- after successfull completion of the clean up routines.

    INSERT INTO GL_LEDGER_SEGMENT_VALUES
           (LEDGER_ID, SEGMENT_TYPE_CODE,SEGMENT_VALUE, STATUS_CODE,
            PARENT_RECORD_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
            CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, START_DATE,
            END_DATE)
           (SELECT GLLNSV.LEDGER_ID, GLLNSV.SEGMENT_TYPE_CODE,
                   GLSVH.CHILD_FLEX_VALUE, 'I', GLLNSV.RECORD_ID,
                   SYSDATE,
                   GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
                   SYSDATE,
                   GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
                   GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID,
                   GLLNSV.START_DATE, GLLNSV.END_DATE
            FROM   GL_LEDGERS GLL,
                   GL_LEDGER_NORM_SEG_VALS GLLNSV,
                   GL_SEG_VAL_HIERARCHIES GLSVH
            WHERE  GLL.CHART_OF_ACCOUNTS_ID =
                       GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
            AND    GLLNSV.LEDGER_ID = GLL.LEDGER_ID
            AND    GLLNSV.STATUS_CODE = 'I'
            AND    GLLNSV.REQUEST_ID =
                   GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
            AND    GLLNSV.SEGMENT_VALUE_TYPE_CODE = 'C'
            AND    GLSVH.FLEX_VALUE_SET_ID =
                         DECODE(GLLNSV.SEGMENT_TYPE_CODE,
                               'B',GLL.BAL_SEG_VALUE_SET_ID,
                               'M',GLL.MGT_SEG_VALUE_SET_ID)
            AND   GLSVH.PARENT_FLEX_VALUE = GLLNSV.SEGMENT_VALUE
            AND   GLSVH.STATUS_CODE IS NULL);

    L_Number_Of_Rows := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0117',
                          TOKEN_NUM =>2,
                          T1        =>'NUM',
                          V1        =>TO_CHAR(L_NUMBER_OF_ROWS),
                          T2        =>'TABLE',
                          V2        =>'GL_LEDGER_SEGMENT_VALUES');

    l_number_of_rows := 0;

   -- ALC changes.
   -- In the new Additional ledger representation , all ALCs associated with
   -- a source ledger should also have records for the specific segment values.

   -- The following statment will takes care of the above requirement and
   -- if there is a new ALC added to the source ledger.

   -- Update and delete of these rows will be taken care by the original
   -- logic in FIX_BY_COA() of this package.


    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_DEBUG) THEN
      GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0180',
                            TOKEN_NUM => 2,
                            T1        =>'ROUTINE',
                            V1        =>
                                     'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa()',
                            T2        =>'ACTION',
                            V2        =>'Inserting ALC ledger record(S) into'
                                      ||' GL_LEDGER_SEGMENT_VALUES'
                                      ||' for every source ledger '
                                      ||' in the '
                                      ||' GL_LEDGER_NORM_SEG_VALS table');
    END IF;

    INSERT INTO GL_LEDGER_SEGMENT_VALUES
           (LEDGER_ID, SEGMENT_TYPE_CODE, SEGMENT_VALUE, STATUS_CODE,
            PARENT_RECORD_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
            CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, START_DATE,
            END_DATE)
           (SELECT glr.target_ledger_id,gllsv.segment_type_code,
                   gllsv.segment_value, 'I', gllsv.parent_record_id,
                   sysdate,
                   GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
                   sysdate,
                   GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
                   GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID,
                   gllsv.start_date, gllsv.end_date
            FROM     GL_LEDGERS gll
                    ,GL_LEDGER_RELATIONSHIPS glr
                    ,GL_LEDGER_SEGMENT_VALUES gllsv
            WHERE  gll.chart_of_accounts_id =
                      GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
            AND    (gll.bal_seg_value_option_code = 'I' OR
                     gll.mgt_seg_value_option_code = 'I')
            AND    gll.alc_ledger_type_code = 'TARGET'
            AND    glr.target_ledger_id = gll.ledger_id
            AND    glr.target_ledger_category_code = 'ALC'
            AND    glr.relationship_type_code IN ('JOURNAL', 'SUBLEDGER')
            AND    glr.application_id = 101
            AND    gllsv.ledger_id = glr.source_ledger_id
            AND    gllsv.segment_type_code IN
                       (DECODE(gll.bal_seg_value_option_code,'I','B',''),
                          DECODE(gll.mgt_seg_value_option_code,'I','M',''))
            AND    NVL(GLLSV.STATUS_CODE,'X') <> 'D'
            AND    NOT EXISTS
                  (SELECT 1
                   FROM GL_LEDGER_SEGMENT_VALUES gllsv2
                   WHERE gllsv2.ledger_id = glr.target_ledger_id
                   AND   gllsv2.segment_type_code = gllsv.SEGMENT_TYPE_CODE
                   AND   gllsv2.segment_value = gllsv.segment_value
                   AND   NVL(gllsv2.start_date,
                           TO_DATE('01/01/1950','MM/DD/YYYY'))
                           = NVL(gllsv.start_date,
                               TO_DATE('01/01/1950','MM/DD/YYYY'))
                   AND   NVL(gllsv2.end_date,
                           TO_DATE('12/31/9999','MM/DD/YYYY'))
                           = NVL(gllsv.end_date,
                               TO_DATE('12/31/9999','MM/DD/YYYY'))));


    l_number_of_rows := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0117',
                            TOKEN_NUM =>2,
                            T1        =>'NUM',
                            V1        =>TO_CHAR(L_NUMBER_OF_ROWS),
                            T2        =>'TABLE',
                            V2        =>'GL_LEDGER_SEGMENT_VALUES');
    l_number_of_rows := 0;

   -- Check for any date overlap

    IF (NOT ERROR_CHECK) THEN

      RAISE GLSTFL_Fatal_Err;

    END IF;

    FND_CONCURRENT.AF_COMMIT;  -- COMMIT POINT

    GL_MESSAGE.FUNC_SUCC(FUNC_NAME =>
                         'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa');

    RETURN TRUE;

  EXCEPTION

    WHEN GLSTFL_FATAL_ERR THEN

      GL_MESSAGE.Write_Log(MSG_NAME  =>'FLAT0002',
                            TOKEN_NUM => 1,
                            T1        =>'ROUTINE_NAME',
                            V1        =>
                                    'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa()');


      GL_MESSAGE.FUNC_FAIL(FUNC_NAME =>
                           'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa');

      FND_CONCURRENT.AF_ROLLBACK;  -- ROLLBACK POINT

      RETURN FALSE;

    WHEN OTHERS THEN

      GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0203',
                            TOKEN_NUM =>2,
                            T1        =>'FUNCTION',
                            V1        =>'FIX_BY_COA()',
                            T2        =>'SQLERRMC',
                            V2        => SQLERRM);

      GL_MESSAGE.FUNC_FAIL(FUNC_NAME =>
                          'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa');

      FND_CONCURRENT.AF_ROLLBACK; -- ROLLBACK POINT

      RETURN FALSE;

  END FIX_BY_COA;

-- ******************************************************************
-- FUNCTION
--   FIX_BY_VALUE_SET
-- PURPOSE
--   This Function is the entry point when flattening program is called in
--   SH mode, it indicates changes in segment hierarchy.
-- HISTORY
--   06-04-2001       SRINI PALA    CREATED
-- ARGUMENTS

-- EXAMPLE
--   RET_STATUS := FIX_BY_VALUE_SET()
--

  FUNCTION FIX_BY_VALUE_SET RETURN BOOLEAN IS

    L_Number_Of_Rows  NUMBER :=0;
    L_Check_Id        NUMBER :=0;
    GLSTFL_fatal_err  EXCEPTION;

  BEGIN

    GL_MESSAGE.FUNC_ENT(FUNC_NAME =>
              'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Value_Set');

    BEGIN

      -- Checking if the value set is used by any ledger(S)

      SELECT 1 INTO L_Check_Id
      FROM   DUAL
      WHERE EXISTS
            (SELECT 1
             FROM   GL_LEDGERS GLL
             WHERE  GLL.BAL_SEG_VALUE_SET_ID =
                        GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
             OR     GLL.MGT_SEG_VALUE_SET_ID =
                        GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
             AND    ROWNUM = 1);

    EXCEPTION

      WHEN NO_DATA_FOUND THEN
      L_Check_Id := 0;

    END;

    IF (L_Check_Id <> 1) THEN
       GL_MESSAGE.Write_Log(MSG_NAME  =>'FLAT0001',
                             TOKEN_NUM => 1,
                             T1        =>'ROUTINE_NAME',
                             V1        =>
                            'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Value_Set()');

       GL_MESSAGE.FUNC_SUCC(FUNC_NAME =>
                            'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Value_Set');

       RETURN TRUE;

    ELSE

      -- Cleaning GL_LEDGER_SEGMENT_VALUES before processing

      IF (GL_FLATTEN_SETUP_DATA.GLSTFL_DEBUG) THEN
        GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0180',
                              TOKEN_NUM => 2,
                              T1        =>'ROUTINE',
                              V1        =>
                              'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Value_Set()',
                              T2        =>'ACTION',
                              V2        =>'DELETING RECORDS WITH'
                                        ||' STATUS CODE I'
                                        ||' IN THE TABLE'
                                        ||' GL_LEDGER_SEGMENT_VALUES');
      END IF;

      DELETE
      FROM   GL_LEDGER_SEGMENT_VALUES
      WHERE  STATUS_CODE  = 'I'
      AND LEDGER_ID  IN
                     (SELECT LEDGER_ID
                      FROM   GL_LEDGERS
                      WHERE  BAL_SEG_VALUE_SET_ID =
                             GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
                      OR     MGT_SEG_VALUE_SET_ID =
                             GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID);

       L_Number_Of_Rows := SQL%ROWCOUNT;
       GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0119',
                             TOKEN_NUM =>2,
                             T1        =>'NUM',
                             V1        =>TO_CHAR(L_NUMBER_OF_ROWS),
                             T2        =>'TABLE',
                             V2        =>'GL_LEDGER_SEGMENT_VALUES');

       -- Cleaning GL_LEDGER_SEGMENT_VALUES before processing

       IF (GL_FLATTEN_SETUP_DATA.GLSTFL_DEBUG) THEN
         GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0180',
                               TOKEN_NUM => 2,
                               T1        =>'ROUTINE',
                               V1        =>
                              'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Value_Set()',
                               T2        =>'ACTION',
                               V2        =>'UPDATING RECORDS WITH STATUS'
                                         ||' CODE D TO NULL IN THE TABLE'
                                         ||' GL_LEDGER_SEGMENT_VALUES');
       END IF;

       UPDATE GL_LEDGER_SEGMENT_VALUES
       SET    STATUS_CODE  = NULL
       WHERE  STATUS_CODE = 'D'
       AND    LEDGER_ID IN
                       (SELECT LEDGER_ID
                        FROM GL_LEDGERS
                        WHERE BAL_SEG_VALUE_SET_ID =
                              GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
                        OR    MGT_SEG_VALUE_SET_ID =
                              GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID);


       L_Number_Of_Rows := SQL%ROWCOUNT;
       GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0118',
                             TOKEN_NUM =>2,
                             T1        =>'NUM',
                             V1        =>TO_CHAR(L_NUMBER_OF_ROWS),
                             T2        =>'TABLE',
                             V2        =>'GL_LEDGER_SEGMENT_VALUES');

       FND_CONCURRENT.AF_COMMIT;   -- COMMIT Point

      -- Marking Parent-Child segment value mappings in
      -- GL_LEDGER_SEGMENT_VALUES for delete

      IF (GL_FLATTEN_SETUP_DATA.GLSTFL_DEBUG) THEN
         GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0180',
                               TOKEN_NUM => 2,
                               T1        =>'ROUTINE',
                               V1        =>
                               'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Value_Set()',
                               T2        =>'ACTION',
                               V2        =>'UPDATING PARENT-CHILD SEGMENT'
                                         ||' VALUE MAPPINGS IN'
                                         ||' GL_LEDGER_SEGMENT_VALUES'
                                         ||' FOR DELETE');
      END IF;

      UPDATE GL_LEDGER_SEGMENT_VALUES GLLSV
      SET    GLLSV.STATUS_CODE  = 'D'
      WHERE  (GLLSV.LEDGER_ID, GLLSV.PARENT_RECORD_ID,
              GLLSV.SEGMENT_VALUE) IN
             (SELECT GLLNSV.LEDGER_ID, GLLNSV.RECORD_ID,
                     GLSVH.CHILD_FLEX_VALUE
              FROM   GL_SEG_VAL_HIERARCHIES GLSVH,
                     GL_LEDGER_NORM_SEG_VALS GLLNSV,
                     GL_LEDGERS GLL
              WHERE  GLSVH.FLEX_VALUE_SET_ID =
                     GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
              AND    GLSVH.STATUS_CODE = 'D'
              AND    GLLNSV.SEGMENT_VALUE_TYPE_CODE = 'C'
              AND    GLLNSV.STATUS_CODE  IS NULL
              AND    GLLNSV.SEGMENT_VALUE =
                            GLSVH.PARENT_FLEX_VALUE
              AND    GLL.LEDGER_ID = GLLNSV.LEDGER_ID
              AND   (
                         (    GLL.BAL_SEG_VALUE_SET_ID  =
                                  GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
                          AND GLLNSV.SEGMENT_TYPE_CODE = 'B')
                     OR
                         (    GLL.MGT_SEG_VALUE_SET_ID =
                                  GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
                          AND GLLNSV.SEGMENT_TYPE_CODE = 'M')));

      L_Number_Of_Rows := SQL%ROWCOUNT;
      GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0118',
                            TOKEN_NUM =>2,
                            T1        =>'NUM',
                            V1        =>TO_CHAR(L_NUMBER_OF_ROWS),
                            T2        =>'TABLE',
                            V2        =>'GL_LEDGER_SEGMENT_VALUES');



       -- Inserting New Parent-Child segment value mappings into
       -- GL_LEDGER_SEGMENT_VALUES.

       IF (GL_FLATTEN_SETUP_DATA.GLSTFL_DEBUG) THEN

         GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0180',
                               TOKEN_NUM => 2,
                               T1        =>'ROUTINE',
                               V1        =>
                               'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Value_Set()',
                               T2        =>'ACTION',
                               V2        =>'Insert new segment values'
                                         ||' from segment value hierarchy'
                                         ||' into GL_LEDGER_SEGMENT_VALUES');


       END IF;

       INSERT INTO GL_LEDGER_SEGMENT_VALUES
              (LEDGER_ID, SEGMENT_TYPE_CODE, SEGMENT_VALUE, STATUS_CODE,
               PARENT_RECORD_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
               CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, START_DATE,
               END_DATE)
              (SELECT GLLNSV.LEDGER_ID, GLLNSV.SEGMENT_TYPE_CODE,
                      GLSVH.CHILD_FLEX_VALUE, 'I', GLLNSV.RECORD_ID,
                      SYSDATE,
                      GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
                      SYSDATE,
                      GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
                      GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID,
                      GLLNSV.START_DATE, GLLNSV.END_DATE
               FROM   GL_SEG_VAL_HIERARCHIES GLSVH,
                      GL_LEDGER_NORM_SEG_VALS GLLNSV,
                      GL_LEDGERS GLL
               WHERE  GLSVH.FLEX_VALUE_SET_ID =
                            GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
               AND    GLSVH.STATUS_CODE = 'I'
               AND    GLLNSV.SEGMENT_VALUE_TYPE_CODE = 'C'
               AND    GLLNSV.STATUS_CODE IS NULL
               AND    GLLNSV.SEGMENT_VALUE = GLSVH.PARENT_FLEX_VALUE
               AND    GLL.LEDGER_ID = GLLNSV.LEDGER_ID
               AND    (
                        (GLL.BAL_SEG_VALUE_SET_ID =
                             GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
                         AND GLLNSV.SEGMENT_TYPE_CODE = 'B')
                       OR
                        (GLL.MGT_SEG_VALUE_SET_ID =
                             GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
                         AND GLLNSV.SEGMENT_TYPE_CODE = 'M')));


      L_Number_Of_Rows := SQL%ROWCOUNT;
      GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0117',
                            TOKEN_NUM =>2,
                            T1        =>'NUM',
                            V1        =>TO_CHAR(L_NUMBER_OF_ROWS),
                            T2        =>'TABLE',
                            V2        =>'GL_LEDGER_SEGMENT_VALUES');

  END IF;   -- Value set ID If - Else control ends here.

    IF (NOT ERROR_CHECK) THEN

      RAISE GLSTFL_FATAL_ERR;

    END IF;

    FND_CONCURRENT.AF_COMMIT;   -- COMMIT Point

    GL_MESSAGE.FUNC_SUCC(FUNC_NAME =>
               'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Value_Set');

    RETURN TRUE;

  EXCEPTION

    WHEN GLSTFL_FATAL_ERR THEN

      GL_MESSAGE.Write_Log(MSG_NAME  =>'FLAT0002',
                            TOKEN_NUM => 1,
                            T1        =>'ROUTINE_NAME',
                            V1        => 'Fix_By_Value_Set()');

      GL_MESSAGE.FUNC_FAIL(FUNC_NAME =>
                 'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Value_Set');

      FND_CONCURRENT.AF_ROLLBACK;  -- ROLLBACK Point

      RETURN FALSE;

    WHEN OTHERS THEN

      GL_MESSAGE.Write_Log (MSG_NAME  =>'SHRD0102',
                             TOKEN_NUM => 1,
                             T1        =>'EMESSAGE',
                             V1        => SQLERRM);

      GL_MESSAGE.FUNC_FAIL(FUNC_NAME =>
                'GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Value_Set');

      FND_CONCURRENT.AF_ROLLBACK;

      RETURN FALSE;

  END FIX_BY_VALUE_SET;

-- *****************************************************************

-- FUNCTION
--   Clean_Up_By_Coa
-- PURPOSE
--   This Function is to clean the tables GL_LEDGER_NORM_SEG_VALUES
--   and GL_LEDGER_SEGMENT_VALUES for a particular Chart Of Accounts.
-- HISTORY
--   06-04-2001       SRINI PALA    CREATED
-- ARGUMENTS

-- EXAMPLE
--   RET_STATUS := Clean_Up_By_Coa();
--
--

  FUNCTION Clean_Up_By_Coa RETURN BOOLEAN IS


    L_Number_Of_Rows        NUMBER :=0;
    l_status                VARCHAR2(1);

  BEGIN

    GL_MESSAGE.FUNC_ENT(FUNC_NAME =>
                       'GL_FLATTEN_LEDGER_SEG_VALS.Clean_Up_By_Coa');

    UPDATE GL_LEDGER_NORM_SEG_VALS
    SET    STATUS_CODE = NULL, request_id = NULL
    WHERE  STATUS_CODE  IN ( 'I','U')
    AND    request_id =
                        GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID;
 /*   AND LEDGER_ID  IN
                   (SELECT LEDGER_ID
                    FROM GL_LEDGERS
                    WHERE CHART_OF_ACCOUNTS_ID =
                          GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID); */

    L_Number_Of_Rows := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0118',
                          TOKEN_NUM =>2,
                          T1        =>'NUM',
                          V1        =>TO_CHAR(L_NUMBER_OF_ROWS),
                          T2        => 'TABLE',
                          V2        => 'GL_LEDGER_NORM_SEG_VALS');

    l_number_of_rows := 0;

    UPDATE GL_LEDGER_SEGMENT_VALUES
    SET    STATUS_CODE = NULL
    WHERE  STATUS_CODE  = 'I'
    AND    LEDGER_ID  IN
                   (SELECT LEDGER_ID
                    FROM GL_LEDGERS
                    WHERE CHART_OF_ACCOUNTS_ID =
                          GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID);

    L_Number_Of_Rows := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0118',
                          TOKEN_NUM =>2,
                          T1        =>'NUM',
                          V1        =>TO_CHAR(L_NUMBER_OF_ROWS),
                          T2        => 'TABLE',
                          V2        => 'GL_LEDGER_SEGMENT_VALUES');
    l_number_of_rows := 0;

    -- To improve performance for bug fix # 5075776
    l_status := 'D';

    DELETE
    FROM  GL_LEDGER_NORM_SEG_VALS
    WHERE  STATUS_CODE  = l_status
    AND LEDGER_ID  IN
                   (SELECT LEDGER_ID
                    FROM GL_LEDGERS
                    WHERE CHART_OF_ACCOUNTS_ID =
                          GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID);

    L_Number_Of_Rows := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0119',
                          TOKEN_NUM => 2,
                          T1        => 'NUM',
                          V1        => TO_CHAR(L_NUMBER_OF_ROWS),
                          T2        =>'TABLE',
                          V2        => 'GL_LEDGER_NORM_SEG_VALS');
    l_number_of_rows := 0;

    DELETE
    FROM  GL_LEDGER_SEGMENT_VALUES
    WHERE  STATUS_CODE  = l_status
    AND LEDGER_ID  IN
                   (SELECT LEDGER_ID
                    FROM GL_LEDGERS
                    WHERE CHART_OF_ACCOUNTS_ID =
                          GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID);

    L_Number_Of_Rows := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0119',
                          TOKEN_NUM => 2,
                          T1        => 'NUM',
                          V1        => TO_CHAR(L_NUMBER_OF_ROWS),
                          T2        =>'TABLE',
                          V2        => 'GL_LEDGER_SEGMENT_VALUES');
    l_number_of_rows := 0;

    GL_MESSAGE.FUNC_SUCC(FUNC_NAME =>
              'GL_FLATTEN_LEDGER_SEG_VALS.Clean_Up_By_Coa');

    RETURN TRUE;

  EXCEPTION

    WHEN OTHERS THEN
      GL_MESSAGE.Write_Log (MSG_NAME  =>'SHRD0102',
                             TOKEN_NUM => 1,
                             T1        =>'EMESSAGE',
                             V1        => SQLERRM);

      GL_MESSAGE.FUNC_FAIL(FUNC_NAME =>
                 'GL_FLATTEN_LEDGER_SEG_VALS.Clean_Up_By_Coa');

      FND_CONCURRENT.AF_ROLLBACK;  -- ROLLBACK Point

      RETURN FALSE;

  END CLEAN_UP_BY_COA;

-- ******************************************************************

-- FUNCTION
--   Clean_Up_By_Value_Set
-- PURPOSE
--   This Function is to clean the tables GL_LEDGER_NORM_SEG_VALUES
--   and GL_LEDGER_SEGMENT_VALUES for a particular value set.
-- HISTORY
--   06-04-2001       Srini Pala    Created
-- ARGUMENTS

-- EXAMPLE
--   RET_STATUS := Clean_Up_By_Value_Set();
--

  FUNCTION  CLEAN_UP_BY_VALUE_SET RETURN BOOLEAN IS

    L_Number_Of_Rows   NUMBER :=0;

  BEGIN

    GL_MESSAGE.FUNC_ENT(FUNC_NAME =>
              'GL_FLATTEN_LEDGER_SEG_VALS.Clean_Up_By_Value_Set');

    UPDATE GL_LEDGER_SEGMENT_VALUES
    SET STATUS_CODE = NULL
    WHERE STATUS_CODE = 'I'
    AND LEDGER_ID IN
        (SELECT LEDGER_ID
         FROM GL_LEDGERS
         WHERE BAL_SEG_VALUE_SET_ID =
               GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
         OR    MGT_SEG_VALUE_SET_ID =
               GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID);

    L_Number_Of_Rows := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0118',
                          TOKEN_NUM =>2,
                          T1        =>'NUM',
                          V1        =>TO_CHAR(L_NUMBER_OF_ROWS),
                          T2        => 'TABLE',
                          V2        => 'GL_LEDGER_SEGMENT_VALUES');

    DELETE
    FROM   GL_LEDGER_SEGMENT_VALUES
    WHERE  STATUS_CODE = 'D'
    AND    LEDGER_ID IN
           (SELECT LEDGER_ID
           FROM GL_LEDGERS
           WHERE BAL_SEG_VALUE_SET_ID =
                 GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
           OR MGT_SEG_VALUE_SET_ID    =
                 GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID);

    L_Number_Of_Rows := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0119',
                          TOKEN_NUM => 2,
                          T1        => 'NUM',
                          V1        => TO_CHAR(L_NUMBER_OF_ROWS),
                          T2        =>'TABLE',
                          V2        => 'GL_LEDGER_SEGMENT_VALUES');


    GL_MESSAGE.FUNC_SUCC(FUNC_NAME  =>
              'GL_FLATTEN_LEDGER_SEG_VALS.Clean_Up_By_Value_Set');

    RETURN TRUE;

  EXCEPTION

    WHEN OTHERS THEN

      GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0102',
                            TOKEN_NUM => 1,
                            T1        =>'EMESSAGE',
                            V1        => SQLERRM);

      GL_MESSAGE.FUNC_FAIL(FUNC_NAME  =>
                 'GL_FLATTEN_LEDGER_SEG_VALS.Clean_Up_By_Value_Set');

      FND_CONCURRENT.AF_ROLLBACK; -- ROLLBACK Point

      RETURN FALSE;

  END Clean_Up_By_Value_Set;


-- ******************************************************************
-- FUNCTION
--   ERROR_CHECK
-- PURPOSE
--   This function  checks if a segment value has been assigned to a
--   particular ledger more than once on a given date range.
--   If it returns FALSE then the package should error out
-- HISTORY
--   06-04-2001       SRINI PALA    CREATED
-- ARGUMENTS
--
-- EXAMPLE
--   RET_STATUS := ERROR_CHECK();
--

   FUNCTION  ERROR_CHECK RETURN BOOLEAN IS

   L_Ledger_Id NUMBER :=0;

   L_Segment_Val VARCHAR2(25);

   L_Ledger_Name VARCHAR2(30);

   BEGIN

     GL_MESSAGE.FUNC_ENT(FUNC_NAME =>
                'GL_FLATTEN_LEDGER_SEG_VALS.Error_Check');

     IF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE = 'VH') OR
         (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE =  'LV') THEN

     -- Separate PL/SQL block for opearation Mode 'VH'

     DECLARE

       CURSOR Cursor_LV_Ledger IS
       SELECT DISTINCT GLLSV1.LEDGER_ID, GLLSV2.SEGMENT_VALUE
       FROM   GL_LEDGERS GLL,
	      GL_LEDGER_SEGMENT_VALUES GLLSV1,
              GL_LEDGER_SEGMENT_VALUES GLLSV2
       WHERE  GLL.CHART_OF_ACCOUNTS_ID =
                  GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
       AND    GLLSV1.LEDGER_ID = GLL.LEDGER_ID
       AND    GLLSV1.LEDGER_ID = GLLSV2.LEDGER_ID
       AND    GLLSV1.SEGMENT_TYPE_CODE = GLLSV2.SEGMENT_TYPE_CODE
       AND    NVL(GLLSV1.STATUS_CODE,'X') <>'D'
       AND    NVL(GLLSV2.STATUS_CODE,'X') <>'D'
       AND    GLLSV1.SEGMENT_VALUE = GLLSV2.SEGMENT_VALUE
       AND    GLLSV1.ROWID <>GLLSV2.ROWID
       AND    (      NVL(GLLSV1.START_DATE,
                     TO_DATE('01/01/1950', 'MM/DD/YYYY'))
                     BETWEEN NVL(GLLSV2.START_DATE,
                                 TO_DATE('01/01/1950','MM/DD/YYYY'))
                     AND     NVL(GLLSV2.END_DATE,
                                 TO_DATE('12/31/9999','MM/DD/YYYY'))
               OR    NVL(GLLSV1.END_DATE,
                                TO_DATE('12/31/9999','MM/DD/YYYY'))
                     BETWEEN NVL(GLLSV2.START_DATE,
                                 TO_DATE('01/01/1950','MM/DD/YYYY'))
                     AND     NVL(GLLSV2.END_DATE,
                                 TO_DATE('12/31/9999','MM/DD/YYYY')));
    BEGIN

       IF (NOT Cursor_LV_Ledger%ISOPEN) THEN

         OPEN Cursor_LV_Ledger;

       END IF;

       LOOP

         FETCH Cursor_LV_Ledger INTO L_Ledger_Id, L_Segment_Val;

         EXIT WHEN Cursor_LV_Ledger%NOTFOUND;

       IF (L_SEGMENT_VAL IS NOT NULL) THEN

         SELECT NAME INTO L_LEDGER_NAME
         FROM   GL_LEDGERS
         WHERE  LEDGER_ID = L_LEDGER_ID;

         GL_MESSAGE.Write_Log(MSG_NAME  =>'FLAT0003',
                               TOKEN_NUM => 2,
                               T1        =>'SEGMENT_VALUE',
                               V1        =>L_SEGMENT_VAL,
                               T2        =>'LEDGER_NAME',
                               V2        =>L_LEDGER_NAME);

       END IF;

       END LOOP;

       IF (Cursor_Lv_Ledger%ROWCOUNT >= 1) THEN

         GL_MESSAGE.FUNC_FAIL(FUNC_NAME =>
                    'GL_FLATTEN_LEDGER_SEG_VALS.Error_Check');

         RETURN FALSE;

       END IF;

       CLOSE Cursor_LV_Ledger;

     EXCEPTION

       WHEN OTHERS THEN

         RETURN FALSE;

     END;   -- VH mode opearation PL/SQL block ends

     END IF; -- VH Opearation mode If control block ends here.

     IF ((GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE = 'FF')
          OR (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE = 'SH')) THEN

       DECLARE

         CURSOR Cursor_SH_Ledger IS
         SELECT GLLSV1.LEDGER_ID, GLLSV2.SEGMENT_VALUE
         FROM   GL_LEDGERS GLL,
	        GL_LEDGER_SEGMENT_VALUES GLLSV1,
                GL_LEDGER_SEGMENT_VALUES GLLSV2
         WHERE   (    GLL.BAL_SEG_VALUE_SET_ID =
                          GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
                  OR  GLL.MGT_SEG_VALUE_SET_ID =
                          GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID)
         AND    GLLSV1.LEDGER_ID = GLL.LEDGER_ID
         AND    GLLSV1.LEDGER_ID = GLLSV2.LEDGER_ID
         AND    GLLSV1.SEGMENT_TYPE_CODE = GLLSV2.SEGMENT_TYPE_CODE
         AND    NVL(GLLSV1.STATUS_CODE,'X') <>'D'
         AND    NVL(GLLSV2.STATUS_CODE,'X') <>'D'
         AND    GLLSV1.SEGMENT_VALUE = GLLSV2.SEGMENT_VALUE
         AND    GLLSV1.ROWID <>GLLSV2.ROWID
         AND    (      NVL(GLLSV1.START_DATE,
                       TO_DATE('01/01/1950', 'MM/DD/YYYY'))
                       BETWEEN NVL(GLLSV2.START_DATE,
                                  TO_DATE('01/01/1950','MM/DD/YYYY'))
                     AND     NVL(GLLSV2.END_DATE,
                                 TO_DATE('12/31/9999','MM/DD/YYYY'))
                OR    NVL(GLLSV1.END_DATE,
                                TO_DATE('12/31/9999','MM/DD/YYYY'))
                     BETWEEN NVL(GLLSV2.START_DATE,
                                 TO_DATE('01/01/1950','MM/DD/YYYY'))
                     AND     NVL(GLLSV2.END_DATE,
                                 TO_DATE('12/31/9999','MM/DD/YYYY')));
       BEGIN

         IF (NOT Cursor_SH_Ledger%ISOPEN) THEN

           OPEN Cursor_SH_Ledger;

         END IF;

         LOOP

           FETCH Cursor_SH_Ledger INTO L_Ledger_Id, L_Segment_Val;

           EXIT WHEN Cursor_SH_Ledger%NOTFOUND;

           IF (L_Segment_Val IS NOT NULL) THEN

             SELECT NAME INTO L_LEDGER_NAME
             FROM   GL_LEDGERS
             WHERE  LEDGER_ID = L_LEDGER_ID;

             GL_MESSAGE.Write_Log(MSG_NAME  =>'FLAT0003',
                                   TOKEN_NUM => 2,
                                   T1        =>'SEGMENT_VALUE',
                                   V1        => L_Segment_Val,
                                   T2        =>'LEDGER_NAME',
                                   V2        =>L_Ledger_Name);

           END IF;

         END LOOP;

         IF (Cursor_SH_Ledger%ROWCOUNT >= 1) THEN

           GL_MESSAGE.FUNC_FAIL(FUNC_NAME =>
                     'GL_FLATTEN_LEDGER_SEG_VALS.Error_Check');

           RETURN FALSE;

         END IF;

         CLOSE Cursor_SH_Ledger;

       EXCEPTION

         WHEN OTHERS THEN

           GL_MESSAGE.FUNC_FAIL(FUNC_NAME =>
                      'GL_FLATTEN_LEDGER_SEG_VALS.Error_Check');

           RETURN FALSE;

       END;   -- 'SH' and 'FF' mode PL/SQL block ends

     END IF; -- 'SH' and 'FF' Opearation mode If control block ends here.

     GL_MESSAGE.FUNC_SUCC(FUNC_NAME =>
                'GL_FLATTEN_LEDGER_SEG_VALS.Error_Check');

     RETURN TRUE;

   EXCEPTION

     WHEN NO_DATA_FOUND THEN

       GL_MESSAGE.FUNC_SUCC(FUNC_NAME =>
                  'GL_FLATTEN_LEDGER_SEG_VALS.Error_Check');

       RETURN TRUE;

     WHEN OTHERS THEN

       GL_MESSAGE.Write_Log(MSG_NAME  =>'SHRD0102',
                             TOKEN_NUM => 1,
                             T1        =>'EMESSAGE',
                             V1        => SQLERRM);

       GL_MESSAGE.FUNC_FAIL(FUNC_NAME =>
                  'GL_FLATTEN_LEDGER_SEG_VALS.Error_Check');

       RETURN FALSE;

   END ERROR_CHECK;

END GL_FLATTEN_LEDGER_SEG_VALS;

/
