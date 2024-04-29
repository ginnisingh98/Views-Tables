--------------------------------------------------------
--  DDL for Package Body GL_FLATTEN_ACCESS_SETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_FLATTEN_ACCESS_SETS" AS
/* $Header: gluflasb.pls 120.11 2006/01/13 02:21:38 spala ship $ */

-- ********************************************************************

  FUNCTION Fix_Explicit_Sets RETURN BOOLEAN IS
    ret_val		BOOLEAN;
    GLSTFL_fatal_err	EXCEPTION;
  BEGIN

    -- This is the routine that processes changes in explicit ledger
    -- sets.  All changes in GL_ACCESS_SET_NORM_ASSIGN are done
    -- through the form, so this routine only needs to call
    -- Fix_Flattened_Table to maintain GL_ACCESS_SET_ASSIGNMENTS.
    -- There is no need to clean up data before processing since
    -- changes to GL_ACCESS_SET_ASSIGNMENTS will not be committed
    -- until everything is done.

    GL_MESSAGE.Func_Ent
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Fix_Explicit_Sets');

    -- Call Fix_Flattened_Table to maintain GL_ACCESS_SET_ASSIGNMENTS.
    ret_val := GL_FLATTEN_ACCESS_SETS.Fix_Flattened_Table;

    IF (NOT ret_val) THEN
      RAISE GLSTFL_fatal_err;
    END IF;

    GL_MESSAGE.Func_Succ
	(func_name	=> 'GL_FLATTEN_ACCESS_SETS.Fix_Explicit_Sets');

    RETURN TRUE;

  -- Exception handling
  EXCEPTION
    WHEN GLSTFL_fatal_err THEN

      GL_MESSAGE.Write_Log
	(msg_name  => 'FLAT0002',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'GL_FLATTEN_ACCESS_SETS.Fix_Explicit_Sets()');

      GL_MESSAGE.Func_Fail
	(func_name =>'GL_FLATTEN_ACCESS_SETS.Fix_Explicit_Sets');

      RETURN FALSE;

    WHEN OTHERS THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0203',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'GL_FLATTEN_ACCESS_SETS.Fix_Explicit_Sets()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

      GL_MESSAGE.Func_Fail
	  (func_name	=> 'GL_FLATTEN_ACCESS_SETS.Fix_Explicit_Sets');

      RETURN FALSE;

  END Fix_Explicit_Sets;

-- ******************************************************************

  Function  Fix_Implicit_Sets(Any_Ledger_Hier_Changes 	BOOLEAN)
						RETURN BOOLEAN IS
    row_count		NUMBER := 0;
    ret_val		BOOLEAN;
    GLSTFL_fatal_err    EXCEPTION;
  BEGIN

    -- This is the routine that processes changes in the implicit
    -- access sets due to modifications to the respective ledger
    -- hierarchies.
    -- The basic flow is as follows:
    -- 1) Clean up GL_ACCESS_SET_NORM_ASSIGN for all implicit acces sets
    --    within the chart of accounts.  There is no need to clean
    --    up GL_ACCESS_SET_ASSIGNMENTS since no changes should be
    --    committed there unless everything has been completed.
    -- 2) Call routine Fix_Norm_Table to maintain GL_ACCESS_SET_NORM_ASSIGN.
    -- 3) Call routine Fix_Flattened_Table to maintain
    --    GL_ACCESS_SET_ASSIGNMENTS.

    GL_MESSAGE.Func_Ent
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Fix_Implicit_Sets');

    -- Clean up GL_ACCESS_SET_NORM_ASSIGN
    -- for any unprocessed data left over from previous failed run

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Fix_Implicit_Sets()',
         t2        => 'ACTION',
         v2        => 'Deleting records with status code I in ' ||
                      'GL_ACCESS_SET_NORM_ASSIGN...');
    END IF;

    DELETE from GL_ACCESS_SET_NORM_ASSIGN
    WHERE status_code = 'I'
    AND   access_set_id IN
	  (SELECT access_set_id
	   FROM   GL_ACCESS_SETS
  	   WHERE  chart_of_accounts_id =
			GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
	   AND	  automatically_created_flag = 'Y');

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0119',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_ACCESS_SET_NORM_ASSIGN');
    row_count := 0;

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Fix_Implicit_Sets()',
         t2        => 'ACTION',
         v2        => 'Updating records with status code D or U in ' ||
                      'GL_ACCESS_SET_NORM_ASSIGN...');
    END IF;

    UPDATE GL_ACCESS_SET_NORM_ASSIGN
    SET   status_code = NULL
    WHERE status_code IN ('D', 'U')
    AND   access_set_id IN
	  (SELECT access_set_id
	   FROM   GL_ACCESS_SETS
	   WHERE  chart_of_accounts_id =
			GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
	   AND	  automatically_created_flag = 'Y');

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0118',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_ACCESS_SET_NORM_ASSIGN');
    row_count := 0;

    -- Commit all clean up work
    FND_CONCURRENT.Af_Commit;

    -- Call routines Fix_Norm_Table and Fix_Flattened_Table to
    -- process data
    ret_val := GL_FLATTEN_ACCESS_SETS.Fix_Norm_Table
		(Ledgers_And_Hier => Any_Ledger_Hier_Changes);

    IF (NOT ret_val) THEN
      RAISE GLSTFL_fatal_err;
    END IF;

   ret_val := GL_FLATTEN_ACCESS_SETS.Fix_Flattened_Table;

    IF (NOT ret_val) THEN
      RAISE GLSTFL_fatal_err;
    END IF;

    GL_MESSAGE.Func_Succ
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Fix_Implicit_Sets');

    RETURN TRUE;

  EXCEPTION
    WHEN GLSTFL_fatal_err THEN

      GL_MESSAGE.Write_Log
	(msg_name  => 'FLAT0002',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'GL_FLATTEN_ACCESS_SETS.Fix_Implicit_Sets()');

      -- Rollback
      FND_CONCURRENT.Af_Rollback;

      GL_MESSAGE.Func_Fail
	(func_name =>'GL_FLATTEN_ACCESS_SETS.Fix_Implicit_Sets');

      RETURN FALSE;

    WHEN OTHERS THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0203',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'GL_FLATTEN_ACCESS_SETS.Fix_Implicit_Sets()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

      -- Rollback
      FND_CONCURRENT.Af_Rollback;

      GL_MESSAGE.Func_Fail
	  (func_name	=> 'GL_FLATTEN_ACCESS_SETS.Fix_Implicit_Sets');

      RETURN FALSE;

  END Fix_Implicit_Sets;

-- *****************************************************************

  Function  Fix_Norm_Table(Ledgers_And_Hier	BOOLEAN)
						 RETURN BOOLEAN IS
    row_count	NUMBER := 0;
  BEGIN

    -- This routine maintains GL_ACCESS_SET_NORM_ASSIGN.
    -- Here is the sequence of events:
    -- 1) For each new ledger, create a self mapping
    --    access set assignment for the ledger
    --    itself if it doesn't exist already.
    --**    ALC changes:
    --**    Also insert associated ALC ledgers under the primary/source
    --**    ledger implicit access set.


   /*-------------------------------------------------------------------+
    | The following process has been suspended since we have no ledger
    | hierarchy in Accounting Setup Flow.
    +-------------------------------------------------------------------*/
   /* *** -- If input parameter indicates there are changes in hierarchies:
   *** --
   *** -- 2) Mark records in GL_ACCESS_SET_NORM_ASSIGN for delete
   *** --    based on marked records in GL_LEDGER_LEDGERS
   *** --	  Again, different statements will be used to process
   *** --	  legal and management hierarchies.
   *** -- 3) Update records in GL_ACCESS_SET_NORM_ASSIGN based
   *** --    on updated records in GL_LEDGER___HIERARCHIES.
   *** -- 4) Insert new records into GL_ACCESS_SET_NORM_ASSIGN based
   *** --    on new records in GL_LEDGER_HIERARCHIES.  Several
   *** --    statements will be run to process legal and management
   *** --    hierarchies. */

    GL_MESSAGE.Func_Ent
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Fix_Norm_Table');

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	  (msg_name  => 'SHRD0180',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Fix_Norm_Table()',
           t2        => 'ACTION',
           v2        => 'Inserting self mapping records and ALCs  ' ||
                        'under its source ledger access set into ' ||
		        'GL_ACCESS_SET_NORM_ASSIGN ' ||
		        'for any new ledgers...');
    END IF;

    INSERT into GL_ACCESS_SET_NORM_ASSIGN
    (access_set_id, ledger_id, all_segment_value_flag,
     segment_value_type_code, access_privilege_code, status_code,
     record_id, last_update_date, last_updated_by, last_update_login,
     creation_date, created_by, request_id, segment_value,
     start_date, end_date, link_id)
    (SELECT	gll.implicit_access_set_id, glr.target_ledger_id, 'Y',
		'S', 'B', 'I', GL_ACCESS_SET_NORM_ASSIGN_S.nextval,
		SYSDATE, GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID, SYSDATE,
		GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID,
		NULL, NULL, NULL, NULL
     FROM	GL_LEDGERS gll,
                GL_LEDGER_RELATIONSHIPS glr
     WHERE	gll.chart_of_accounts_id =
			GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
     AND	gll.object_type_code = 'L'
     AND        gll.implicit_access_set_id  <>-1
     AND        glr.source_ledger_id = gll.ledger_id
     AND        glr.target_ledger_category_code  IN  ( 'ALC',
                 DECODE(gll.ledger_category_code,'PRIMARY','PRIMARY',''),
                 DECODE(gll.ledger_category_code,'SECONDARY', 'SECONDARY',''))
     AND        glr.relationship_type_code IN ('NONE','JOURNAL','SUBLEDGER')
     AND        glr.application_id = 101
     AND	NOT EXISTS
		(SELECT	1
		 FROM 	GL_ACCESS_SET_NORM_ASSIGN glasna
		 WHERE	glasna.access_set_id = gll.implicit_access_set_id
		 AND	glasna.ledger_id = glr.target_ledger_id
		 AND	glasna.all_segment_value_flag = 'Y'
		 AND	glasna.segment_value_type_code = 'S'
		 AND	glasna.access_privilege_code = 'B'
		 AND	glasna.segment_value is NULL
		 AND	glasna.start_date is NULL
		 AND	glasna.end_date is NULL
		 AND	NVL(glasna.status_code, 'X') <> 'D'));

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0117',
	 	 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_ACCESS_SET_NORM_ASSIGN');
    row_count := 0;

      -- Commit all work
      FND_CONCURRENT.Af_Commit;


    GL_MESSAGE.Func_Succ
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Fix_Norm_Table');

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
       GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0203',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'GL_FLATTEN_ACCESS_SETS.Fix_Norm_Table()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

       FND_CONCURRENT.Af_Rollback;

       GL_MESSAGE.Func_Fail
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Fix_Norm_Table');

       RETURN FALSE;

  END Fix_Norm_Table;

-- ******************************************************************

  FUNCTION Fix_Flattened_Table RETURN BOOLEAN IS
    row_count		NUMBER := 0;
    ret_val		BOOLEAN;
    GLSTFL_fatal_err	EXCEPTION;
    bal_vs_id		NUMBER(15);
    mgt_vs_id		NUMBER(15);
    curr_as		VARCHAR2(30) := NULL;
    curr_ldg		VARCHAR2(30) := NULL;
    curr_seg_val	VARCHAR2(15) := NULL;
  BEGIN

    -- This routine will call Populate_Temp_Table to process
    -- all changes to access sets and populate GL_ACCESS_SET_ASSIGN_INT.
    -- After determining which access set assignments should be
    -- effective, all final data will be populated back to
    -- GL_ACCESS_SET_ASSIGNMENTS.
    -- Here is the sequence of events:
    -- 1) For modes VH, LH, LS and AS, obtain a shared lock on both
    --    the balancing and the management segments.
    -- 2) Call Populate_Temp_Table to populate data into
    --    GL_ACCESS_SET_ASSIGN_INT
    -- 3) Delete records from GL_ACCESS_SET_ASSIGNMENTS based on
    --    GL_ACCESS_SET_ASSIGN_INT
    -- 4) Call Enable_Record to enable/disable correct assignments in
    --    GL_ACCESS_SET_ASSIGNMENTS.
    -- 5) Insert new records into GL_ACCESS_SET_ASSIGNMENTS
    -- 6) For modes LH and VH, update records in GL_ACCESS_SET_ASSIGNMENTS.
    --***  Step 6 is no longer required since we do not have ledger hierarchies
    --*** and no updated records.
    -- 7) For modes LH, VH, SH and FF, check if there are overlapping date
    --    ranges for a particular ledger/segment value assignment in
    --    any management hierarchies.
    --    If so, report as error and abort processing.

    GL_MESSAGE.Func_Ent
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Fix_Flattened_Table');

    -- For modes LH, LS, VS and AS, obtain shared lock on both balancing
    -- and management segments.
    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE IN
		('VH', 'LH', 'LS', 'AS', 'VS')) THEN

      IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
        GL_MESSAGE.Write_Log
	  (msg_name  => 'SHRD0180',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Fix_Flattened_Table()',
           t2        => 'ACTION',
           v2        => 'Obtain shared lock on balancing segment...');
      END IF;

      ret_val := GL_FLATTEN_SETUP_DATA.Request_Lock
			(X_Param_Type 	=> 'V',
			 X_Param_Id   	=>
				GL_FLATTEN_SETUP_DATA.GLSTFL_BAL_VS_ID,
			 X_Lock_Mode  	=> 4,  -- SHARED mode
			 X_Keep_Looping	=> TRUE,
			 X_Max_Trys	=> 5);

      IF (NOT ret_val) THEN
	RAISE GLSTFL_fatal_err;
      END IF;

      -- Obtain the second lock iff bal_vs_id <> mgt_vs_id

     -- Now the Management segment value set is optional.
     /*  IF (GL_FLATTEN_SETUP_DATA.GLSTFL_BAL_VS_ID <>
	  GL_FLATTEN_SETUP_DATA.GLSTFL_MGT_VS_ID) THEN */

      IF (GL_FLATTEN_SETUP_DATA.GLSTFL_MGT_VS_ID IS NOT NULL) THEN

       IF (GL_FLATTEN_SETUP_DATA.GLSTFL_BAL_VS_ID <>
	           GL_FLATTEN_SETUP_DATA.GLSTFL_MGT_VS_ID) THEN
        IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
          GL_MESSAGE.Write_Log
	    (msg_name  => 'SHRD0180',
             token_num => 2,
             t1        => 'ROUTINE',
             v1        => 'Fix_Flattened_Table()',
             t2        => 'ACTION',
             v2        => 'Obtain shared lock on management segment...');
        END IF;

        ret_val := GL_FLATTEN_SETUP_DATA.Request_Lock
			(X_Param_Type 	=> 'V',
			 X_Param_Id   	=>
				GL_FLATTEN_SETUP_DATA.GLSTFL_MGT_VS_ID,
			 X_Lock_Mode  	=> 4,  -- SHARED mode
			 X_Keep_Looping	=> TRUE,
			 X_Max_Trys	=> 5);

        IF (NOT ret_val) THEN
	  RAISE GLSTFL_fatal_err;
        END IF;
      END IF;
     END IF;
    END IF;

    -- Call Populate_Temp_Table
    ret_val := GL_FLATTEN_ACCESS_SETS.Populate_Temp_Table;

    IF (NOT ret_val) THEN
      RAISE GLSTFL_fatal_err;
    END IF;

    -- Delete records from GL_ACCESS_SET_ASSIGNMENTS based on
    -- GL_ACCESS_SET_ASSIGN_INT
    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	  (msg_name  => 'SHRD0180',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Fix_Flattened_Table()',
           t2        => 'ACTION',
           v2        => 'Deleting records from GL_ACCESS_SET_ASSIGNMENTS...');
    END IF;

    DELETE from GL_ACCESS_SET_ASSIGNMENTS glasa
    WHERE (ABS(glasa.access_set_id), glasa.ledger_id,
	   glasa.segment_value, glasa.parent_record_id) IN
    	  (SELECT glasai.access_set_id, glasai.ledger_id,
		  glasai.segment_value, glasai.parent_record_id
  	   FROM   GL_ACCESS_SET_ASSIGN_INT glasai
	   WHERE  glasai.status_code = 'D');

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0119',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_ACCESS_SET_ASSIGNMENTS');
    row_count :=0;

    -- Here only call Enable_Record when not processing implicit access
    -- sets ONLY.  This means that the routine will NOT be called in modes
    -- LH and VH
    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE NOT IN ('LH', 'VH')) THEN
      ret_val := GL_FLATTEN_ACCESS_SETS.Enable_Record;

      IF (NOT ret_val) THEN
        RAISE GLSTFL_fatal_err;
      END IF;
    END IF;

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN

      BEGIN
        SELECT count(*)
        INTO row_count
        FROM GL_ACCESS_SET_ASSIGN_INT;
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  row_count := 0;
      END;

      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Fix_Flattened_Table()',
         t2        => 'ACTION',
         v2        => 'GL_ACCESS_SET_ASSIGN_INT has ' || TO_CHAR(row_count) ||
			' records...');

      row_count := 0;
    END IF;

    -- Insert new records into GL_ACCESS_SET_ASSIGNMENTS
    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Fix_Flattened_Table()',
         t2        => 'ACTION',
         v2        => 'Inserting records into GL_ACCESS_SET_ASSIGNMENTS...');
    END IF;

    INSERT into GL_ACCESS_SET_ASSIGNMENTS
    (access_set_id, ledger_id, segment_value, access_privilege_code,
     parent_record_id, last_update_date, last_updated_by, last_update_login,
     creation_date, created_by, start_date, end_date)
    (SELECT glasai.access_set_id, glasai.ledger_id, glasai.segment_value,
	    glasai.access_privilege_code, glasai.parent_record_id, SYSDATE,
	    GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
	    GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID, SYSDATE,
	    GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
  	    glasai.start_date, glasai.end_date
     FROM   GL_ACCESS_SET_ASSIGN_INT glasai
     WHERE  glasai.status_code = 'I'
     AND    NOT EXISTS
	    (SELECT 1
	     FROM   GL_ACCESS_SET_ASSIGNMENTS glasa
	     WHERE  (    glasa.access_set_id = glasai.access_set_id
		      OR glasa.access_set_id = -glasai.access_set_id)
	     AND    glasa.parent_record_id = glasai.parent_record_id
	     AND    glasa.ledger_id = glasai.ledger_id
	     AND    glasa.segment_value = glasai.segment_value
	     AND    NVL(glasa.start_date,
			TO_DATE('01/01/1950', 'MM/DD/YYYY')) =
		    NVL(glasai.start_date,
			TO_DATE('01/01/1950', 'MM/DD/YYYY'))
	     AND    NVL(glasa.end_date,
			TO_DATE('12/31/9999', 'MM/DD/YYYY')) =
		    NVL(glasai.end_date,
			TO_DATE('12/31/9999', 'MM/DD/YYYY'))));

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0117',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_ACCESS_SET_ASSIGNMENTS');
    row_count :=0;


    -- Check if a particular ledger/segment value have overlapping effective
    -- dates for management hierarchies
    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE in ('LH', 'SH', 'FF', 'VH')) THEN
     IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
        GL_MESSAGE.Write_Log
	  (msg_name  => 'SHRD0180',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Fix_Flattened_Table()',
           t2        => 'ACTION',
           v2        => 'Checking if any ledger/segment value ' ||
			'assignment associated with management hierarchies ' ||
			'has overlapping effective date ranges...');
      END IF;

      -- Here we do not need to use ABS( ) around access_set_id since for
      -- management hierarchies no records will be disabled
      BEGIN

        SELECT 	1
	INTO	row_count
        FROM	GL_ACCESS_SETS glas,
		GL_ACCESS_SET_ASSIGN_INT glasai,
		GL_ACCESS_SET_ASSIGNMENTS glasa1,
		GL_ACCESS_SET_ASSIGNMENTS glasa2
	WHERE	(     glas.secured_seg_value_set_id =
			GL_FLATTEN_SETUP_DATA.GLSTFL_MGT_VS_ID
		  OR  glas.secured_seg_value_set_id =
			GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID)
        AND	glas.automatically_created_flag = 'Y'
        AND	glas.security_segment_code = 'M'
	AND	glasai.access_set_id = glas.access_set_id
        AND	glasa1.access_set_id = glasai.access_set_id
 	AND 	glasa1.ledger_id = glasai.ledger_id
  	AND	glasa1.segment_value = glasai.segment_value
        AND	glasa2.access_set_id = glasa1.access_set_id
        AND	glasa2.ledger_id = glasa1.ledger_id
        AND	glasa2.segment_value = glasa1.segment_value
        AND	glasa2.rowid <> glasa1.rowid
        AND	(   	     NVL(glasa1.start_date,
			   	 TO_DATE('01/01/1950', 'MM/DD/YYYY'))
		     BETWEEN NVL(glasa2.start_date,
				 TO_DATE('01/01/1950', 'MM/DD/YYYY'))
		     AND     NVL(glasa2.end_date,
				 TO_DATE('12/31/9999', 'MM/DD/YYYY'))
		 OR  	     NVL(glasa1.end_date,
				 TO_DATE('12/31/9999', 'MM/DD/YYYY'))
		     BETWEEN NVL(glasa2.start_date,
				 TO_DATE('01/01/1950', 'MM/DD/YYYY'))
		     AND     NVL(glasa2.end_date,
				 TO_DATE('12/31/9999', 'MM/DD/YYYY')))
        AND	rownum <= 1;

      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  NULL;
      END;

      IF (SQL%FOUND) THEN
	-- Overlapping date ranges found, print out error message
	-- and abort.
        GL_MESSAGE.Write_Log(msg_name	=> 'FLAT0016',
	  	 	      token_num	=> 0);

	DECLARE
	  CURSOR overlap_dates_cursor IS
            SELECT distinct glas.name, gll.name, glasa1.segment_value
	    FROM   GL_ACCESS_SETS glas,
		   GL_ACCESS_SET_ASSIGN_INT glasai,
		   GL_ACCESS_SET_ASSIGNMENTS glasa1,
		   GL_ACCESS_SET_ASSIGNMENTS glasa2,
		   GL_LEDGERS gll
	    WHERE  (     glas.secured_seg_value_set_id =
			    	GL_FLATTEN_SETUP_DATA.GLSTFL_MGT_VS_ID
		     OR  glas.secured_seg_value_set_id =
			  	GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID)
            AND	glas.automatically_created_flag = 'Y'
            AND	glas.security_segment_code = 'M'
	    AND	glasai.access_set_id = glas.access_set_id
            AND	glasa1.access_set_id = glasai.access_set_id
 	    AND	glasa1.ledger_id = glasai.ledger_id
  	    AND	glasa1.segment_value = glasai.segment_value
            AND	glasa2.access_set_id = glasa1.access_set_id
            AND	glasa2.ledger_id = glasa1.ledger_id
            AND	glasa2.segment_value = glasa1.segment_value
            AND	glasa2.rowid <> glasa1.rowid
            AND	(   	     NVL(glasa1.start_date,
			   	 TO_DATE('01/01/1950', 'MM/DD/YYYY'))
		     BETWEEN NVL(glasa2.start_date,
				 TO_DATE('01/01/1950', 'MM/DD/YYYY'))
		     AND     NVL(glasa2.end_date,
				 TO_DATE('12/31/9999', 'MM/DD/YYYY'))
		 OR  	     NVL(glasa1.end_date,
				 TO_DATE('12/31/9999', 'MM/DD/YYYY'))
		     BETWEEN NVL(glasa2.start_date,
				 TO_DATE('01/01/1950', 'MM/DD/YYYY'))
		     AND     NVL(glasa2.end_date,
				 TO_DATE('12/31/9999', 'MM/DD/YYYY')))
	    AND gll.ledger_id = glasa1.ledger_id;
        BEGIN
	  IF (NOT overlap_dates_cursor%ISOPEN) THEN
	    OPEN overlap_dates_cursor;
 	  END IF;

	  LOOP
	    FETCH overlap_dates_cursor INTO curr_as, curr_ldg, curr_seg_val;
	    EXIT WHEN overlap_dates_cursor%NOTFOUND;

	    IF (curr_as IS NOT NULL) THEN
	      GL_MESSAGE.Write_Log
			(msg_name  => 'FLAT0003',
                         token_num => 3,
                         t1        => 'ACCESS_SET_NAME',
			 v1 	   => curr_as,
			 t2	   => 'LEDGER_NAME',
			 v2 	   => curr_ldg,
			 t3	   => 'SEG_VAL',
			 v3	   => curr_seg_val);
	    END IF;
	  END LOOP;
	EXCEPTION
	  WHEN OTHERS THEN
	    NULL;
	END;

	RAISE GLSTFL_fatal_err;
      END IF;
    END IF;  -- IF (...OP_MODE IN ('LV', 'LH'...

    -- Note here we do not release the shared lock on balancing and
    -- management segments since we want to pass it on to other
    -- packages.  The locks will be released by the main routine
    -- when all clean up work is completed.  This is to make sure
    -- that SH and FF processes cannot start until all status codes
    -- are reset to current.

    GL_MESSAGE.Func_Succ
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Fix_Flattened_Table');

    RETURN TRUE;

  EXCEPTION
    WHEN GLSTFL_fatal_err THEN

      GL_MESSAGE.Write_Log
	 (msg_name  => 'FLAT0002',
          token_num => 1,
          t1        => 'ROUTINE_NAME',
          v1        => 'GL_FLATTEN_ACCESS_SETS.Fix_Flattened_Table()');

      GL_MESSAGE.Func_Fail
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Fix_Flattened_Table');

      RETURN FALSE;

    WHEN OTHERS THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0203',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'GL_FLATTEN_ACCESS_SETS.Fix_Flattened_Table()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

      GL_MESSAGE.Func_Fail
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Fix_Flattened_Table');

      RETURN FALSE;

  END Fix_Flattened_Table;

-- ******************************************************************

  FUNCTION Populate_Temp_Table RETURN BOOLEAN IS
    row_count			NUMBER  := 0;
    cont_processing		BOOLEAN := TRUE;
    sh_ff_all_val_changed	BOOLEAN := TRUE;
    as_all_val_changed		BOOLEAN := TRUE;
    as_single_val_changed	BOOLEAN := TRUE;
    as_parent_val_changed	BOOLEAN	:= TRUE;
  BEGIN

    -- This routine will populate GL_ACCESS_SET_ASSIGN_INT based on
    -- the mode of operation.  Since this is a relatively expensive
    -- operation, we will only do work when there are indeed changes
    -- that will affect the access sets.
    -- Here is the sequence of events:
    -- 1) For modes FF, SH, LS and AS, check if further processing is
    --    necessary here.
    -- 2) If processing is needed, run statements to populate
    --    GL_ACCESS_SET_ASSIGN_INT based on the mode of operation.

    GL_MESSAGE.Func_Ent
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Populate_Temp_Table');

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Populate_Temp_Table()',
         t2        => 'ACTION',
         v2        => 'Checking if further processing is needed ' ||
		      'based on mode of operation...');
    END IF;

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE IN ('SH', 'FF')) THEN

      -- Check if there are new values added to the value set and
      -- there are access sets associated with this value set with
      -- segment_value_type_code of 'A'

      BEGIN
      row_count := 0;
	SELECT 	1
	INTO	row_count
      	FROM	DUAL
      	WHERE	EXISTS
		(SELECT 1
		 FROM 	GL_SEG_VAL_HIERARCHIES glsvh
		 WHERE	glsvh.flex_value_set_id =
				GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
		 AND	glsvh.parent_flex_value = 'T'
		 AND	glsvh.status_code = 'I');

       -- Performance bug 4861665 fix.

        IF (row_count = 1) THEN
	   SELECT 	1
	   INTO	row_count
      	   FROM	DUAL
      	   WHERE	EXISTS
		(SELECT 1
		 FROM 	GL_ACCESS_SETS glas,
			GL_ACCESS_SET_NORM_ASSIGN glasna
		 WHERE	glas.secured_seg_value_set_id =
				GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
		 AND	glas.security_segment_code <> 'F'
		 AND	glasna.access_set_id = glas.access_set_id
		 AND	glasna.all_segment_value_flag = 'Y');
       END IF;
      EXCEPTION
      	WHEN NO_DATA_FOUND THEN
          sh_ff_all_val_changed := SQL%FOUND;
      END;

    ELSIF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE IN ('LS', 'VS')) THEN

      -- Check if any access set assignment contains the changed
      -- ledger set.
      BEGIN
	-- NOTE: gllsa records should never have a status_code of U
      	SELECT	1
	INTO	row_count
      	FROM 	DUAL
      	WHERE 	EXISTS
		(SELECT	1
		 FROM 	GL_ACCESS_SET_NORM_ASSIGN glasna
		 WHERE	glasna.ledger_id IN
		 	(SELECT distinct gllsa.ledger_set_id
			 FROM	GL_LEDGER_SET_ASSIGNMENTS gllsa,
				GL_LEDGERS gll
			 WHERE	gllsa.status_code IN ('I', 'D')
			 AND	gll.ledger_id = gllsa.ledger_set_id
			 AND	gll.chart_of_accounts_id =
				  GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
			 AND	gll.object_type_code = 'S'
			 AND	gll.automatically_created_flag = 'N'));
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
          cont_processing := SQL%FOUND;
      END;

    ELSIF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE = 'AS') THEN

      -- There are 3 checks we have to do here to determine what
      -- statements should be run for further processing.
      -- 1) If changes occurred in full ledger type access sets or
      --    access set using a single segment value.
      -- 2) If changes occurred in access sets using parent segment value
      --    and their descendants.
      -- 3) If changes occurred in access sets using all segment values.

      BEGIN
   	SELECT	1
	INTO	row_count
	FROM 	DUAL
	WHERE	EXISTS
		(SELECT	1
		 FROM 	GL_ACCESS_SETS glas,
			GL_ACCESS_SET_NORM_ASSIGN glasna
		 WHERE	glas.chart_of_accounts_id =
			  	GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
		 AND	glas.automatically_created_flag = 'N'
		 AND	glasna.access_set_id = glas.access_set_id
		 AND	glasna.request_id =
			  GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
		 AND	glasna.status_code IN ('I', 'D', 'U')
		 AND	(   (    glasna.all_segment_value_flag = 'N'
		 	     AND glasna.segment_value_type_code = 'S')
			 OR (glas.security_segment_code = 'F')));
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  as_single_val_changed := SQL%FOUND;
      END;

      BEGIN
	SELECT	1
	INTO	row_count
	FROM	DUAL
	WHERE 	EXISTS
		(SELECT 1
		 FROM 	GL_ACCESS_SETS glas,
			GL_ACCESS_SET_NORM_ASSIGN glasna
		 WHERE 	glas.chart_of_accounts_id =
				GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
		 AND	glas.automatically_created_flag = 'N'
		 AND	glasna.access_set_id = glas.access_set_id
		 AND	glasna.request_id =
			  GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
		 AND	glasna.status_code IN ('I', 'D', 'U')
	 	 AND	glasna.segment_value_type_code = 'C');

      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  as_parent_val_changed := SQL%FOUND;
      END;

      BEGIN
	SELECT	1
	INTO	row_count
    	FROM 	DUAL
	WHERE	EXISTS
		(SELECT	1
		 FROM	GL_ACCESS_SETS glas,
			GL_ACCESS_SET_NORM_ASSIGN glasna
		 WHERE	glas.chart_of_accounts_id =
				GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
		 AND	glas.automatically_created_flag = 'N'
		 AND	glas.security_segment_code <> 'F'
		 AND	glasna.access_set_id = glas.access_set_id
		 AND	glasna.request_id =
			  GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
		 AND	glasna.status_code IN ('I', 'D', 'U')
		 AND	glasna.all_segment_value_flag = 'Y');
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  as_all_val_changed := SQL%FOUND;
      END;

      -- Program shoud continue processing if any changes are found
      cont_processing := (as_single_val_changed OR as_parent_val_changed OR
			  as_all_val_changed);
    END IF;

    IF (cont_processing) THEN

      IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
     	GL_MESSAGE.Write_Log
		(msg_name	=> 'FLAT0017',
	 	 token_num	=> 1,
	 	 t1		=> 'OP_MODE',
	 	 v1		=> GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE);
      END IF;

      -- Since changes related to access sets are found, start
      -- populating GL_ACCESS_SET_ASSIGN_INT for various modes
      -- of operation.

      IF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE IN ('FF', 'SH')) THEN

	row_count := 0;

	-- This statement process all segment value hierarchy changes,
	-- thus it will be run in mode SH only.  It is not relevant to
        -- mode FF.
	IF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE = 'SH') THEN

      	  IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      	    GL_MESSAGE.Write_Log
		(msg_name  => 'SHRD0180',
           	 token_num => 2,
          	 t1        => 'ROUTINE',
          	 v1        => 'Populate_Temp_Table()',
         	 t2        => 'ACTION',
           	 v2        => 'Inserting records into ' ||
			      'GL_ACCESS_SET_ASSIGN_INT for segment ' ||
			      'value hierarchy changes...');
	  END IF;

	  INSERT into GL_ACCESS_SET_ASSIGN_INT
	  (access_set_id, ledger_id, segment_value, access_privilege_code,
	   status_code, parent_record_id, last_update_date, last_updated_by,
	   last_update_login, creation_date, created_by, start_date, end_date)
	  (SELECT glasna.access_set_id,
		  DECODE(gllsa.ledger_id,
		         NULL, glasna.ledger_id, gllsa.ledger_id),
		  glsvh.child_flex_value, glasna.access_privilege_code,
		  glsvh.status_code, glasna.record_id, SYSDATE,
		  GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		  GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID, SYSDATE,
		  GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		  glasna.start_date, glasna.end_date
	   FROM	GL_SEG_VAL_HIERARCHIES glsvh,
		GL_ACCESS_SETS glas,
		GL_ACCESS_SET_NORM_ASSIGN glasna,
		GL_LEDGER_SET_ASSIGNMENTS gllsa
	   WHERE glsvh.flex_value_set_id = GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
	   AND	 glsvh.status_code in ('I', 'D')
	   AND   glas.security_segment_code <> 'F'
	   AND	 glas.secured_seg_value_set_id =
			GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
	   AND   glasna.access_set_id = glas.access_set_id
	   AND	 glasna.all_segment_value_flag = 'N'
	   AND	 glasna.segment_value_type_code = 'C'
	   AND	 glasna.segment_value = glsvh.parent_flex_value
	   AND	 NVL(glasna.status_code, 'X') <> 'I'
	   AND	 gllsa.ledger_set_id(+) = glasna.ledger_id
	   AND	 NVL(gllsa.status_code(+), 'X') <> 'I');

    	  -- The above statement should process U records in glasna
          -- since this will only happen in dates update of management
          -- hierarchy assignments.  We need to make sure all segment
          -- value hierarchies changes in place to make sure that
          -- the other process will update the right records.
	  -- (Update is done with parent_record_id and thus will not
          -- check for the integrity of the segment value assignments!
          --
          -- Also, records in gllsa will never have a status_code of U.

	  row_count := SQL%ROWCOUNT;
    	  GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0117',
		   	        token_num	=> 2,
			        t1		=> 'NUM',
			        v1		=> TO_CHAR(row_count),
			        t2		=> 'TABLE',
			        v2		=> 'GL_ACCESS_SET_ASSIGN_INT');
    	  row_count := 0;
	END IF;

	-- If there are new segment values added to the value set and
	-- there are access set assignments associated with this value
	-- set with all_segment_value_flag of 'Y', run this statement
	-- to add in the new segment values to the assignments.
	IF (sh_ff_all_val_changed) THEN

	  IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      	    GL_MESSAGE.Write_Log
		(msg_name  => 'SHRD0180',
           	 token_num => 2,
          	 t1        => 'ROUTINE',
          	 v1        => 'Populate_Temp_Table()',
         	 t2        => 'ACTION',
           	 v2        => 'Inserting records into ' ||
			      'GL_ACCESS_SET_ASSIGN_INT for new ' ||
			      'segment values...');
	  END IF;

  	  INSERT into GL_ACCESS_SET_ASSIGN_INT
	  (access_set_id, ledger_id, segment_value, access_privilege_code,
	   status_code, parent_record_id, last_update_date, last_updated_by,
	   last_update_login, creation_date, created_by, start_date, end_date)
	  (SELECT glasna.access_set_id,
		  DECODE(gllsa.ledger_id,
			 NULL, glasna.ledger_id, gllsa.ledger_id),
		  glsvh.child_flex_value, glasna.access_privilege_code,
		  'I', glasna.record_id, SYSDATE,
		  GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		  GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID, SYSDATE,
		  GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		  glasna.start_date, glasna.end_date
	   FROM	  GL_SEG_VAL_HIERARCHIES glsvh,
		  GL_ACCESS_SETS glas,
		  GL_ACCESS_SET_NORM_ASSIGN glasna,
		  GL_LEDGER_SET_ASSIGNMENTS gllsa
	   WHERE  glsvh.flex_value_set_id = GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
	   AND	  glsvh.parent_flex_value = 'T'
	   AND	  glsvh.status_code = 'I'
	   AND	  glas.secured_seg_value_set_id =
			GL_FLATTEN_SETUP_DATA.GLSTFL_VS_ID
	   AND	  glas.security_segment_code <> 'F'
	   AND	  glasna.access_set_id = glas.access_set_id
	   AND	  glasna.all_segment_value_flag = 'Y'
	   AND	  NVL(glasna.status_code, 'X') <> 'I'
	   AND    gllsa.ledger_set_id(+) = glasna.ledger_id
	   AND	  NVL(gllsa.status_code(+), 'X') <> 'I');

	  row_count := SQL%ROWCOUNT;
    	  GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0117',
		 	  	token_num	=> 2,
			  	t1		=> 'NUM',
			  	v1		=> TO_CHAR(row_count),
			  	t2		=> 'TABLE',
			  	v2		=> 'GL_ACCESS_SET_ASSIGN_INT');
    	  row_count := 0;

	END IF;  -- IF (sh_ff_all_val_changed)...

      ELSIF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE IN ('LH', 'VH')) THEN

	row_count := 0;

	IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      	  GL_MESSAGE.Write_Log
		(msg_name  => 'SHRD0180',
           	 token_num => 2,
          	 t1        => 'ROUTINE',
          	 v1        => 'Populate_Temp_Table()',
         	 t2        => 'ACTION',
           	 v2        => 'Inserting records into ' ||
			      'GL_ACCESS_SET_ASSIGN_INT for legal ' ||
			      'and management implicit access sets...');
	END IF;

	-- This statement will process implicit access set changes from
	-- legal hierarchies.

	INSERT into GL_ACCESS_SET_ASSIGN_INT
	(access_set_id, ledger_id, segment_value, access_privilege_code,
	 status_code, parent_record_id, last_update_date, last_updated_by,
	 last_update_login, creation_date, created_by, start_date, end_date)
	(SELECT	glasna.access_set_id, glasna.ledger_id,
		NVL(glasna.segment_value, '-1'), glasna.access_privilege_code,
		glasna.status_code, glasna.record_id, SYSDATE,
		GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID, SYSDATE,
		GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		glasna.start_date, glasna.end_date
	 FROM	GL_ACCESS_SET_NORM_ASSIGN glasna,
		GL_LEDGERS gll
	 WHERE	glasna.status_code IN ('I')
	 AND	glasna.request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
	 AND	gll.implicit_access_set_id = glasna.access_set_id
	 AND	gll.chart_of_accounts_id =
			GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
	 AND	gll.object_type_code = 'L');



	row_count := SQL%ROWCOUNT;
    	GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0117',
	 	  	      token_num	=> 2,
			      t1	=> 'NUM',
			      v1	=> TO_CHAR(row_count),
			      t2	=> 'TABLE',
			      v2	=> 'GL_ACCESS_SET_ASSIGN_INT');
    	row_count := 0;


      ELSIF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE IN ('LS', 'VS')) THEN

	-- This section will process access set changes due to changes
	-- in the explicit ledger sets, as well as any changes that affect
	-- the implicit access set tied to these ledger sets.

	row_count := 0;

	IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      	  GL_MESSAGE.Write_Log
		(msg_name  => 'SHRD0180',
           	 token_num => 2,
          	 t1        => 'ROUTINE',
          	 v1        => 'Populate_Temp_Table()',
         	 t2        => 'ACTION',
           	 v2        => 'Inserting records into ' ||
			      'GL_ACCESS_SET_ASSIGN_INT for changed ' ||
			      'ledger sets ' ||
			      'contained in full ledger type access sets ' ||
			      'or access assignment with a single segment '||
			      'value...');
	END IF;

	-- This statement will not join to GL_SEG_VAL_HIERARCHIES since
	-- it only process changes in explicit ledger sets in full ledger
 	-- type access sets, or access assignment with a single segment value.
	INSERT into GL_ACCESS_SET_ASSIGN_INT
	(access_set_id, ledger_id, segment_value, access_privilege_code,
	 status_code, parent_record_id, last_update_date, last_updated_by,
	 last_update_login, creation_date, created_by, start_date, end_date)
	(SELECT	glasna.access_set_id, gllsa.ledger_id,
		NVL(glasna.segment_value, '-1'), glasna.access_privilege_code,
		gllsa.status_code, glasna.record_id, SYSDATE,
		GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID, SYSDATE,
		GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		glasna.start_date, glasna.end_date
	 FROM 	GL_LEDGER_SET_ASSIGNMENTS gllsa,
		GL_LEDGERS gll,
		GL_ACCESS_SET_NORM_ASSIGN glasna,
		GL_ACCESS_SETS glas
	 WHERE	gllsa.status_code IN ('I', 'D')
	 AND 	gll.ledger_id = gllsa.ledger_set_id
	 AND	gll.chart_of_accounts_id = GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
	 AND	gll.object_type_code = 'S'
	 AND	gll.automatically_created_flag = 'N'
	 AND	glasna.ledger_id = gllsa.ledger_set_id
	 AND	NVL(glasna.status_code, 'X') NOT IN ('I', 'U')
	 AND	glas.access_set_id = glasna.access_set_id
	 AND	(	glas.security_segment_code = 'F'
		  OR    (	glasna.segment_value_type_code = 'S'
			 AND	glasna.all_segment_value_flag = 'N')));

	row_count := SQL%ROWCOUNT;
    	GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0117',
	 	  	      token_num	=> 2,
			      t1	=> 'NUM',
			      v1	=> TO_CHAR(row_count),
			      t2	=> 'TABLE',
			      v2	=> 'GL_ACCESS_SET_ASSIGN_INT');
    	row_count := 0;

	IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      	  GL_MESSAGE.Write_Log
		(msg_name  => 'SHRD0180',
           	 token_num => 2,
          	 t1        => 'ROUTINE',
          	 v1        => 'Populate_Temp_Table()',
         	 t2        => 'ACTION',
           	 v2        => 'Inserting records into ' ||
			      'GL_ACCESS_SET_ASSIGN_INT for access sets ' ||
			      'containing changed explicit ledger sets ' ||
			      'with all segment values assigned...');
	END IF;

	INSERT into GL_ACCESS_SET_ASSIGN_INT
	(access_set_id, ledger_id, segment_value, access_privilege_code,
	 status_code, parent_record_id, last_update_date, last_updated_by,
	 last_update_login, creation_date, created_by, start_date, end_date)
	(SELECT	glasna.access_set_id, gllsa.ledger_id,
		glsvh.child_flex_value, glasna.access_privilege_code,
		gllsa.status_code, glasna.record_id, SYSDATE,
		GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID, SYSDATE,
		GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		glasna.start_date, glasna.end_date
	 FROM 	GL_LEDGER_SET_ASSIGNMENTS gllsa,
		GL_LEDGERS gll,
		GL_ACCESS_SET_NORM_ASSIGN glasna,
		GL_ACCESS_SETS glas,
		GL_SEG_VAL_HIERARCHIES glsvh
	 WHERE	gllsa.status_code IN ('I', 'D')
	 AND	gll.ledger_id = gllsa.ledger_set_id
	 AND	gll.chart_of_accounts_id = GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
	 AND	gll.object_type_code = 'S'
	 AND	gll.automatically_created_flag = 'N'
	 AND	glasna.ledger_id = gllsa.ledger_set_id
	 AND	glasna.all_segment_value_flag = 'Y'
	 AND	NVL(glasna.status_code, 'X') NOT IN ('I', 'U')
	 AND	glas.access_set_id = glasna.access_set_id
	 AND	glas.security_segment_code <> 'F'
	 AND	glsvh.flex_value_set_id = glas.secured_seg_value_set_id
	 AND	glsvh.parent_flex_value = 'T'
	 AND	NVL(glsvh.status_code, 'X') <> 'I');

	row_count := SQL%ROWCOUNT;
    	GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0117',
	 	  	      token_num	=> 2,
			      t1	=> 'NUM',
			      v1	=> TO_CHAR(row_count),
			      t2	=> 'TABLE',
			      v2	=> 'GL_ACCESS_SET_ASSIGN_INT');
    	row_count := 0;

	IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      	  GL_MESSAGE.Write_Log
		(msg_name  => 'SHRD0180',
           	 token_num => 2,
          	 t1        => 'ROUTINE',
          	 v1        => 'Populate_Temp_Table()',
         	 t2        => 'ACTION',
           	 v2        => 'Inserting records into ' ||
			      'GL_ACCESS_SET_ASSIGN_INT for access sets ' ||
			      'containing changed explicit ledger sets ' ||
			      'with parent segment values assigned...');
	END IF;

	INSERT into GL_ACCESS_SET_ASSIGN_INT
	(access_set_id, ledger_id, segment_value, access_privilege_code,
	 status_code, parent_record_id, last_update_date, last_updated_by,
	 last_update_login, creation_date, created_by, start_date, end_date)
	(SELECT	glasna.access_set_id, gllsa.ledger_id,
		glsvh.child_flex_value, glasna.access_privilege_code,
		gllsa.status_code, glasna.record_id, SYSDATE,
		GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID, SYSDATE,
		GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		glasna.start_date, glasna.end_date
	 FROM 	GL_LEDGER_SET_ASSIGNMENTS gllsa,
		GL_LEDGERS gll,
		GL_ACCESS_SET_NORM_ASSIGN glasna,
		GL_ACCESS_SETS glas,
		GL_SEG_VAL_HIERARCHIES glsvh
	 WHERE	gllsa.status_code IN ('I', 'D')
	 AND	gll.ledger_id = gllsa.ledger_set_id
	 AND	gll.chart_of_accounts_id = GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
	 AND	gll.object_type_code = 'S'
	 AND	gll.automatically_created_flag = 'N'
	 AND	glasna.ledger_id = gllsa.ledger_set_id
	 AND	glasna.all_segment_value_flag = 'N'
	 AND	glasna.segment_value_type_code = 'C'
	 AND	NVL(glasna.status_code, 'X') NOT IN ('I', 'U')
	 AND	glas.access_set_id = glasna.access_set_id
	 AND	glas.security_segment_code <> 'F'
	 AND	glsvh.flex_value_set_id = glas.secured_seg_value_set_id
	 AND	glsvh.parent_flex_value = glasna.segment_value
	 AND	NVL(glsvh.status_code, 'X') <> 'I');

	row_count := SQL%ROWCOUNT;
    	GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0117',
	 	  	      token_num	=> 2,
			      t1	=> 'NUM',
			      v1	=> TO_CHAR(row_count),
			      t2	=> 'TABLE',
			      v2	=> 'GL_ACCESS_SET_ASSIGN_INT');
    	row_count := 0;

	IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      	  GL_MESSAGE.Write_Log
		(msg_name  => 'SHRD0180',
           	 token_num => 2,
          	 t1        => 'ROUTINE',
          	 v1        => 'Populate_Temp_Table()',
         	 t2        => 'ACTION',
           	 v2        => 'Inserting records into ' ||
			      'GL_ACCESS_SET_ASSIGN_INT for implicit ' ||
			      'access sets associated with changed ' ||
			      'explicit ledger sets... ');
	END IF;

	INSERT into GL_ACCESS_SET_ASSIGN_INT
	(access_set_id, ledger_id, segment_value, access_privilege_code,
	 status_code, parent_record_id, last_update_date, last_updated_by,
	 last_update_login, creation_date, created_by, start_date, end_date)
	(SELECT	glasna.access_set_id, gllsa.ledger_id,
		NVL(glasna.segment_value, '-1'), glasna.access_privilege_code,
		gllsa.status_code, glasna.record_id, SYSDATE,
		GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID, SYSDATE,
		GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		glasna.start_date, glasna.end_date
	 FROM 	GL_LEDGER_SET_ASSIGNMENTS gllsa,
		GL_LEDGERS gll,
		GL_ACCESS_SET_NORM_ASSIGN glasna
	 WHERE	gllsa.status_code IN ('I', 'D')
	 AND 	gll.ledger_id = gllsa.ledger_set_id
	 AND	gll.chart_of_accounts_id = GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
	 AND	gll.automatically_created_flag = 'N'
	 AND	gll.object_type_code = 'S'
	 AND	glasna.access_set_id = gll.implicit_access_set_id
	 AND	glasna.ledger_id = gllsa.ledger_set_id
 	 AND	glasna.status_code = 'I'
	 AND	glasna.request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID);

	row_count := SQL%ROWCOUNT;
    	GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0117',
	 	  	      token_num	=> 2,
			      t1	=> 'NUM',
			      v1	=> TO_CHAR(row_count),
			      t2	=> 'TABLE',
			      v2	=> 'GL_ACCESS_SET_ASSIGN_INT');
    	row_count := 0;

      ELSIF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE = 'AS') THEN

	-- This section will process changes in explicit access sets.
	-- Different statement will be run depending on the type
	-- of changes occurred as indicated by the checks earlier.

	row_count := 0;

	IF (as_single_val_changed) THEN

  	  IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      	    GL_MESSAGE.Write_Log
		(msg_name  => 'SHRD0180',
           	 token_num => 2,
          	 t1        => 'ROUTINE',
          	 v1        => 'Populate_Temp_Table()',
         	 t2        => 'ACTION',
           	 v2        => 'Inserting records into ' ||
			      'GL_ACCESS_SET_ASSIGN_INT for changed ' ||
			      'access sets having full ledger access or ' ||
			      'access assignments with single segment ' ||
			      'value assigned...');
	  END IF;

 	  INSERT into GL_ACCESS_SET_ASSIGN_INT
	  (access_set_id, ledger_id, segment_value, access_privilege_code,
	   status_code, parent_record_id, last_update_date, last_updated_by,
	   last_update_login, creation_date, created_by, start_date, end_date)
	  (SELECT glasna.access_set_id,
		  DECODE(gllsa.ledger_id,
		         NULL, glasna.ledger_id, gllsa.ledger_id),
		  NVL(glasna.segment_value, '-1'), glasna.access_privilege_code,
		  glasna.status_code, glasna.record_id, SYSDATE,
		  GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		  GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID, SYSDATE,
		  GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		  glasna.start_date, glasna.end_date
	   FROM	 GL_ACCESS_SET_NORM_ASSIGN glasna,
		 GL_ACCESS_SETS glas,
		 GL_LEDGER_SET_ASSIGNMENTS gllsa
	   WHERE glasna.status_code IN ('I', 'D')
	   AND	 glasna.request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
	   AND	 glas.access_set_id = glasna.access_set_id
	   AND	 glas.chart_of_accounts_id =
			GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
	   AND	 glas.automatically_created_flag = 'N'
	   AND	 (	(	glasna.all_segment_value_flag = 'N'
			 AND	glasna.segment_value_type_code = 'S')
		  OR	glas.security_segment_code = 'F')
	   AND	 gllsa.ledger_set_id(+) = glasna.ledger_id
	   AND	 NVL(gllsa.status_code(+), 'X') <> 'I');
	   -- gllsa never has U records

  	  row_count := SQL%ROWCOUNT;
    	  GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0117',
	 	  	        token_num	=> 2,
			        t1		=> 'NUM',
			        v1		=> TO_CHAR(row_count),
			        t2		=> 'TABLE',
			        v2		=> 'GL_ACCESS_SET_ASSIGN_INT');
      	  row_count := 0;
	END IF; -- IF (as_single_val_changed) ...

	IF (as_all_val_changed) THEN

  	  IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      	    GL_MESSAGE.Write_Log
		(msg_name  => 'SHRD0180',
           	 token_num => 2,
          	 t1        => 'ROUTINE',
          	 v1        => 'Populate_Temp_Table()',
         	 t2        => 'ACTION',
           	 v2        => 'Inserting records into ' ||
			      'GL_ACCESS_SET_ASSIGN_INT for changed ' ||
			      'access sets having access assignments ' ||
			      'with all segment values assigned...');
	  END IF;

	  INSERT into GL_ACCESS_SET_ASSIGN_INT
	  (access_set_id, ledger_id, segment_value, access_privilege_code,
	   status_code, parent_record_id, last_update_date, last_updated_by,
	   last_update_login, creation_date, created_by, start_date, end_date)
	  (SELECT glasna.access_set_id,
		  DECODE(gllsa.ledger_id,
		         NULL, glasna.ledger_id, gllsa.ledger_id),
		  glsvh.child_flex_value, glasna.access_privilege_code,
		  glasna.status_code, glasna.record_id, SYSDATE,
		  GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		  GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID, SYSDATE,
		  GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		  glasna.start_date, glasna.end_date
	   FROM	 GL_ACCESS_SET_NORM_ASSIGN glasna,
		 GL_ACCESS_SETS glas,
		 GL_LEDGER_SET_ASSIGNMENTS gllsa,
		 GL_SEG_VAL_HIERARCHIES glsvh
	   WHERE glasna.status_code IN ('I', 'D', 'U')
	   AND	 glasna.request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
	   AND	 glasna.all_segment_value_flag = 'Y'
	   AND	 glas.access_set_id = glasna.access_set_id
	   AND	 glas.chart_of_accounts_id =
			GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
	   AND	 glas.automatically_created_flag = 'N'
	   AND	 glas.security_segment_code <> 'F'
	   AND	 gllsa.ledger_set_id(+) = glasna.ledger_id
	   AND	 NVL(gllsa.status_code(+), 'X') <> 'I'
	   AND	 glsvh.flex_value_set_id = glas.secured_seg_value_set_id
	   AND	 glsvh.parent_flex_value = 'T'
	   AND 	 NVL(glsvh.status_code, 'X') <> 'I');

	  row_count := SQL%ROWCOUNT;
    	  GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0117',
	 	  	        token_num	=> 2,
			        t1		=> 'NUM',
			        v1		=> TO_CHAR(row_count),
			        t2		=> 'TABLE',
			        v2		=> 'GL_ACCESS_SET_ASSIGN_INT');
    	  row_count := 0;
	END IF; -- IF (as_all_val_changed) ...

	IF (as_parent_val_changed) THEN

	  IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      	    GL_MESSAGE.Write_Log
		(msg_name  => 'SHRD0180',
           	 token_num => 2,
          	 t1        => 'ROUTINE',
          	 v1        => 'Populate_Temp_Table()',
         	 t2        => 'ACTION',
           	 v2        => 'Inserting records into ' ||
			      'GL_ACCESS_SET_ASSIGN_INT for changed ' ||
			      'access sets having parent segment values ' ||
			      'assigned...');
	  END IF;

	  INSERT into GL_ACCESS_SET_ASSIGN_INT
	  (access_set_id, ledger_id, segment_value, access_privilege_code,
	   status_code, parent_record_id, last_update_date, last_updated_by,
	   last_update_login, creation_date, created_by, start_date, end_date)
	  (SELECT glasna.access_set_id,
		  DECODE(gllsa.ledger_id,
		         NULL, glasna.ledger_id, gllsa.ledger_id),
		  glsvh.child_flex_value, glasna.access_privilege_code,
		  glasna.status_code, glasna.record_id, SYSDATE,
		  GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		  GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID, SYSDATE,
		  GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		  glasna.start_date, glasna.end_date
	   FROM	 GL_ACCESS_SET_NORM_ASSIGN glasna,
		 GL_ACCESS_SETS glas,
		 GL_LEDGER_SET_ASSIGNMENTS gllsa,
		 GL_SEG_VAL_HIERARCHIES glsvh
	   WHERE glasna.status_code IN ('I', 'D', 'U')
	   AND	 glasna.request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
	   AND	 glasna.all_segment_value_flag = 'N'
	   AND	 glasna.segment_value_type_code = 'C'
	   AND	 glas.access_set_id = glasna.access_set_id
	   AND	 glas.chart_of_accounts_id =
			GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
	   AND	 glas.automatically_created_flag = 'N'
	   AND	 glas.security_segment_code <> 'F'
	   AND	 gllsa.ledger_set_id(+) = glasna.ledger_id
	   AND	 NVL(gllsa.status_code(+), 'X') <> 'I'
	   AND	 glsvh.flex_value_set_id = glas.secured_seg_value_set_id
	   AND	 glsvh.parent_flex_value = glasna.segment_value
	   AND	 NVL(glsvh.status_code, 'X') <> 'I');

	  row_count := SQL%ROWCOUNT;
    	  GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0117',
	 	  	        token_num	=> 2,
			        t1		=> 'NUM',
			        v1		=> TO_CHAR(row_count),
			        t2		=> 'TABLE',
			        v2		=> 'GL_ACCESS_SET_ASSIGN_INT');
    	  row_count := 0;
	END IF; -- IF (as_parent_val_changed) ...

     END IF;  -- IF (...OP_MODE IN ('SH', 'FF')) THEN ...

    ELSE

      IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
     	GL_MESSAGE.Write_Log
		(msg_name	=> 'FLAT0017',
	 	 token_num	=> 1,
	 	 t1		=> 'OP_MODE',
	 	 v1		=> GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE);
      END IF;

    END IF;  -- IF (cont_processing...) THEN ...

    --  Commit all work
    FND_CONCURRENT.Af_Commit;

    GL_MESSAGE.Func_Succ
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Populate_Temp_Table');

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0203',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'GL_FLATTEN_ACCESS_SETS.Populate_Temp_Table()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

      -- Rollback
      FND_CONCURRENT.Af_Rollback;

      GL_MESSAGE.Func_Fail
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Populate_Temp_Table');

      RETURN FALSE;

  END Populate_Temp_Table;

-- ******************************************************************

  FUNCTION Enable_Record RETURN BOOLEAN IS
    row_count		NUMBER :=0;
    curr_as_id		NUMBER :=0;
    curr_ldg_id		NUMBER :=0;
    curr_seg_val	VARCHAR2(15) := NULL;
    tot_row_fetch	NUMBER :=0;

    CURSOR dup_access_assign_cursor IS
      SELECT DISTINCT MIN(glasai.access_set_id),
		      MIN(glasai.ledger_id), MIN(glasai.segment_value)
      FROM	GL_ACCESS_SET_ASSIGN_INT glasai,
		GL_ACCESS_SETS glas
      WHERE	glasai.status_code = 'I'
      AND	glasai.access_set_id > 0
      AND	glas.access_set_id = ABS(glasai.access_set_id)
      AND	glas.automatically_created_flag = 'N'
      GROUP BY	glasai.access_set_id, glasai.ledger_id,
		glasai.segment_value
      HAVING	count(*) > 1;

  BEGIN

    -- After all changes have been processed, the program needs to
    -- determine which records should be enabled to take effect
    -- for a particular access set/ledger/segment value combination.
    -- This routine will do so by changing the access set ID to be
    -- negative for disabled records (positive for enabled ones).
    -- This routine will not process any records associated with
    -- implicit access sets.  The algorithm used to maintain implicit
    -- access sets should guarantee that there will only be one
    -- record for each date range, in which case the record should
    -- always be enabled.
    -- The sequence of events is as follows:
    -- 1) Enable records in GL_ACCESS_SET_ASSIGNMENTS since the
    --    effective record might be deleted.
    -- 2) Disable records in GL_ACCESS_SET_ASSIGN_INT based on effective
    --    records in GL_ACCESS_SET_ASSIGNMENTS.
    -- 3) Pick the record in GL_ACCESS_SET_ASSIGN_INT having the greatest
    --    access code with the smallest rowid, then disable all other records.
    -- 4) Disable records in GL_ACCESS_SET_ASSIGNMENTS if there exists an
    --    effective record in GL_ACCESS_SET_ASSIGN_INT that has a higher
    --    access privilege.

    GL_MESSAGE.Func_Ent
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Enable_Record');

    -- Pick a record with access_privilege_code of B that has
    -- the smallest rowid, and disable all other records
    -- Note this will only happen when the current effective
    -- record has been deleted.  Thus we can make use of the
    -- 'D' records in GL_ACCESS_SET_ASSIGN_INT to search
    -- for the new effective record.
    -- Also here we do not need to check if the access sets are
    -- implicit or not, since only explicit access sets will ever
    -- have records with a negative access_set_id.  This is because
    -- for implicit access sets they should never have more than
    -- 1 record for each access set/ledger/segment value combination.
    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
		(msg_name  => 'SHRD0180',
           	 token_num => 2,
          	 t1        => 'ROUTINE',
          	 v1        => 'Enable_Record()',
         	 t2        => 'ACTION',
           	 v2        => 'Searching for disabled records in ' ||
			      'GL_ACCESS_SET_ASSIGNMENTS with access ' ||
			      'privilege B which has the smallest ' ||
			      'rowid, then enable this record...');
    END IF;

    UPDATE	GL_ACCESS_SET_ASSIGNMENTS glasa1
    SET		glasa1.access_set_id = -glasa1.access_set_id
    WHERE	glasa1.rowid IN
		(SELECT MIN(glasa2.rowid)
		 FROM 	GL_ACCESS_SET_ASSIGN_INT glasai,
			GL_ACCESS_SET_ASSIGNMENTS glasa2,
			GL_ACCESS_SET_ASSIGNMENTS glasa3
		 WHERE 	glasai.status_code = 'D'
		 AND	glasa2.access_set_id = -glasai.access_set_id
	 	 AND	glasa2.ledger_id = glasai.ledger_id
		 AND	glasa2.segment_value = glasai.segment_value
		 AND	glasa2.access_privilege_code = 'B'
		 AND	glasa3.access_set_id(+) = glasai.access_set_id
		 AND	glasa3.ledger_id(+) = glasai.ledger_id
		 AND 	glasa3.segment_value(+) = glasai.segment_value
		 AND	glasa3.rowid is NULL
		 GROUP BY glasa2.access_set_id, glasa2.ledger_id,
			  glasa2.segment_value);

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0118',
		  	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_ACCESS_SET_ASSIGNMENTS');
    row_count := 0;

    -- Then, pick a record with access_privilege of R having the
    -- smallest rowid and disable all other records.
    -- This statement will only update records if the first
    -- statement does not enable any record, since otherwise
    -- it will never pass the outer join test.
    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
		(msg_name  => 'SHRD0180',
           	 token_num => 2,
          	 t1        => 'ROUTINE',
          	 v1        => 'Enable_Record()',
         	 t2        => 'ACTION',
           	 v2        => 'Updating records in ' ||
			      'GL_ACCESS_SET_ASSIGNMENTS to enable ' ||
			      'access assignments using the smallest ' ||
			      'rowid with access privilege R...');
    END IF;

    UPDATE	GL_ACCESS_SET_ASSIGNMENTS glasa1
    SET		glasa1.access_set_id = -glasa1.access_set_id
    WHERE	glasa1.rowid IN
		(SELECT MIN(glasa2.rowid)
		 FROM 	GL_ACCESS_SET_ASSIGN_INT glasai,
			GL_ACCESS_SET_ASSIGNMENTS glasa2,
			GL_ACCESS_SET_ASSIGNMENTS glasa3
		 WHERE 	glasai.status_code = 'D'
		 AND	glasa2.access_set_id = -glasai.access_set_id
	 	 AND	glasa2.ledger_id = glasai.ledger_id
		 AND	glasa2.segment_value = glasai.segment_value
		 AND	glasa2.access_privilege_code = 'R'
		 AND	glasa3.access_set_id(+) = glasai.access_set_id
		 AND	glasa3.ledger_id(+) = glasai.ledger_id
		 AND 	glasa3.segment_value(+) = glasai.segment_value
		 AND	glasa3.rowid is NULL
		 GROUP BY glasa2.access_set_id, glasa2.ledger_id,
			  glasa2.segment_value);

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0118',
	 	  	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_ACCESS_SET_ASSIGNMENTS');
    row_count := 0;

    -- Check if there exists a record in GL_ACCESS_SET_ASSIGNMENTS
    -- that has a higher or equal access privilege.  If so, disable the
    -- corresponding record(s) in GL_ACCESS_SET_ASSIGN_INT.
    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
		(msg_name  => 'SHRD0180',
           	 token_num => 2,
          	 t1        => 'ROUTINE',
          	 v1        => 'Enable_Record()',
         	 t2        => 'ACTION',
           	 v2        => 'Updating records in ' ||
			      'GL_ACCESS_SET_ASSIGN_INT based on ' ||
			      'GL_ACCESS_SET_ASSIGNMENTS to disable ' ||
			      'access assignments...');
    END IF;

    UPDATE	GL_ACCESS_SET_ASSIGN_INT glasai1
    SET		glasai1.access_set_id = -glasai1.access_set_id
    WHERE	glasai1.rowid IN
		(SELECT glasai2.rowid
		 FROM 	GL_ACCESS_SET_ASSIGN_INT glasai2,
			GL_ACCESS_SETS glas,
			GL_ACCESS_SET_ASSIGNMENTS glasa
		 WHERE 	glasai2.status_code = 'I'
		 AND	glasai2.access_set_id > 0
		 AND	glas.access_set_id = glasai2.access_set_id
		 AND	glas.automatically_created_flag = 'N'
		 AND	glasa.access_set_id = glasai2.access_set_id
		 AND	glasa.ledger_id = glasai2.ledger_id
		 AND	glasa.segment_value = glasai2.segment_value
		 AND	(     glasa.access_privilege_code = 'B'
			 OR  (    glasa.access_privilege_code = 'R'
			      AND glasai2.access_privilege_code = 'R')));

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0118',
	  	    	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_ACCESS_SET_ASSIGN_INT');
    row_count := 0;


    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      	GL_MESSAGE.Write_Log
		(msg_name  => 'SHRD0180',
           	 token_num => 2,
          	 t1        => 'ROUTINE',
          	 v1        => 'Enable_Record()',
         	 t2        => 'ACTION',
           	 v2        => 'Searching for records in ' ||
			      'GL_ACCESS_SET_ASSIGN_INT with access ' ||
			      'privilege B which has the smallest ' ||
			      'rowid, then disable all other records...');
    END IF;

    -- For efficiency purposes, if all the records within
    -- GL_ACCESS_SET_ASSIGN_INT are unique, i.e. only 1 record
    -- exists in the table for each access_set_id/ledger_id/segment_value
    -- combination, the program will not need to run the enabling code
    -- within GL_ACCESS_SET_ASSIGN_INT.  This is because no rows will
    -- be updated in the end.
    IF (NOT dup_access_assign_cursor%ISOPEN) THEN
      OPEN dup_access_assign_cursor;
    END IF;

    LOOP
      FETCH dup_access_assign_cursor
	INTO curr_as_id, curr_ldg_id, curr_seg_val;
      EXIT WHEN dup_access_assign_cursor%NOTFOUND;

      IF (curr_as_id IS NOT NULL) THEN

/*
        IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
          GL_MESSAGE.Write_Log
		(msg_name  => 'FLAT0020',
           	 token_num => 3,
          	 t1        => 'AS_ID',
          	 v1        => TO_CHAR(curr_as_id),
         	 t2        => 'LDG_ID',
           	 v2        => TO_CHAR(curr_ldg_id),
		 t3	   => 'SEG_VAL',
		 v3	   => curr_seg_val);
	END IF;
*/

    -- IF (NOT dup_access_assign_cursor%NOTFOUND) THEN

    -- Then, pick a record with access_privilege_code of B that has
    -- the smallest rowid, and disable all other records

    UPDATE	GL_ACCESS_SET_ASSIGN_INT glasai1
    SET		glasai1.access_set_id = -glasai1.access_set_id
    WHERE	glasai1.access_set_id = curr_as_id
    AND		glasai1.ledger_id = curr_ldg_id
    AND		glasai1.segment_value = curr_seg_val
    AND		glasai1.status_code = 'I'
    AND		EXISTS
		(SELECT	1
		 FROM 	GL_ACCESS_SET_ASSIGN_INT glasai2,
			GL_ACCESS_SETS glas
		 WHERE	glasai2.status_code IN ('I', 'U')
		 AND	glasai2.access_set_id = glasai1.access_set_id
		 AND	glasai2.ledger_id = glasai1.ledger_id
		 AND	glasai2.segment_value = glasai1.segment_value
		 AND	glas.access_set_id = glasai1.access_set_id
		 AND	glas.automatically_created_flag = 'N'
		 AND	(     (	    glasai2.access_privilege_code =
					glasai1.access_privilege_code
			 	AND  glasai2.rowid < glasai1.rowid)
			 OR   (     glasai2.access_privilege_code = 'B'
				AND glasai1.access_privilege_code = 'R')));

        row_count := row_count + 1;

      END IF;
    END LOOP;

/*
**    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
**      GL_MESSAGE.Write_Log
**	(msg_name	=> 'FLAT0020',
**	 token_num	=> 1,
**	 t1		=> 'NUM',
**	 v1		=> TO_CHAR(dup_access_assign_cursor%ROWCOUNT));
**    END IF;
*/
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0118',
	 	  	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_ACCESS_SET_ASSIGN_INT');
    row_count := 0;

    CLOSE dup_access_assign_cursor;

    -- Here the only conflict that needs to be resolve is
    -- that the enabled record in GL_ACCESS_SET_ASSIGNMENTS has
    -- access privilege of R, while the enabled record in
    -- GL_ACCESS_SET_ASSIGN_INT has access privilege of B.
    -- In this case, the record in GL_ACCESS_SET_ASSIGNMENTS will
    -- be disabled.

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
		(msg_name  => 'SHRD0180',
           	 token_num => 2,
          	 t1        => 'ROUTINE',
          	 v1        => 'Enable_Record()',
         	 t2        => 'ACTION',
           	 v2        => 'Updating records in ' ||
			      'GL_ACCESS_SET_ASSIGNMENTS to disable ' ||
			      'those with access privilege R if there ' ||
			      'exists a record in GL_ACCESS_SET_ASSIGN_INT '||
			      'with access privilege of B...');
    END IF;

    UPDATE	GL_ACCESS_SET_ASSIGNMENTS glasa
    SET		glasa.access_set_id = -glasa.access_set_id
    WHERE	glasa.access_privilege_code = 'R'
    AND		glasa.access_set_id > 0
    AND		(glasa.access_set_id, glasa.ledger_id,
		 glasa.segment_value) IN
		(SELECT DISTINCT
			glasai.access_set_id, glasai.ledger_id,
			glasai.segment_value
		 FROM 	GL_ACCESS_SET_ASSIGN_INT glasai,
			GL_ACCESS_SETS glas
		 WHERE 	glasai.status_code IN ('I', 'U')
		 AND	glasai.access_privilege_code = 'B'
		 AND	glasai.access_set_id > 0
		 AND	glas.access_set_id = glasai.access_set_id
		 AND	glas.automatically_created_flag = 'N');

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0118',
	 	  	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_ACCESS_SET_ASSIGNMENTS');
    row_count := 0;

    GL_MESSAGE.Func_Succ
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Enable_Record');

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0203',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'GL_FLATTEN_ACCESS_SETS.Enable_Record()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

      GL_MESSAGE.Func_Fail
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Enable_Record');

      RETURN FALSE;

  END Enable_Record;

-- ******************************************************************

  FUNCTION Clean_Up_By_Coa RETURN BOOLEAN IS
    row_count		NUMBER := 0;
  BEGIN

    GL_MESSAGE.Func_Ent
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Clean_Up_By_Coa');

    -- Run the following statements using the right parameters
    -- to clean up GL_ACCESS_SET_NORM_ASSIGN

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Clean_Up_By_Coa()',
         t2        => 'ACTION',
         v2        => 'Deleting records from GL_ACCESS_SET_NORM_ASSIGN...');
    END IF;

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE = 'AS') THEN

      DELETE from GL_ACCESS_SET_NORM_ASSIGN
      WHERE status_code = 'D'
      AND   request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
      AND   access_set_id IN
		(SELECT access_set_id
		 FROM 	GL_ACCESS_SETS
		 WHERE  chart_of_accounts_id =
			  GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
		 AND	automatically_created_flag = 'N');

    ELSIF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE IN ('LH', 'VH')) THEN

      DELETE from GL_ACCESS_SET_NORM_ASSIGN
      WHERE status_code = 'D'
      AND   request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
      AND   access_set_id IN
		(SELECT implicit_access_set_id
		 FROM 	GL_LEDGERS
		 WHERE  chart_of_accounts_id =
			  GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
		 AND	object_type_code = 'L');

    END IF;

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0119',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_ACCESS_SET_NORM_ASSIGN');
    row_count := 0;

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Clean_Up_By_Coa()',
         t2        => 'ACTION',
         v2        => 'Updating records in GL_ACCESS_SET_NORM_ASSIGN...');
    END IF;

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE IN ('LS', 'VS')) THEN

      UPDATE GL_ACCESS_SET_NORM_ASSIGN
      SET status_code = NULL, request_id = NULL
      WHERE status_code IN ('I', 'U')
      AND   request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
      AND   access_set_id IN
		(SELECT implicit_access_set_id
		 FROM 	GL_LEDGERS
		 WHERE  chart_of_accounts_id =
			  GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
		 AND	object_type_code = 'S');

    ELSIF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE = 'AS') THEN

      UPDATE GL_ACCESS_SET_NORM_ASSIGN
      SET status_code = NULL, request_id = NULL
      WHERE status_code IN ('I', 'U')
      AND   request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
      AND   access_set_id IN
		(SELECT access_set_id
		 FROM 	GL_ACCESS_SETS
		 WHERE  chart_of_accounts_id =
			  GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
		 AND	automatically_created_flag = 'N');

    ELSIF (GL_FLATTEN_SETUP_DATA.GLSTFL_OP_MODE IN ('LH', 'VH')) THEN

      UPDATE GL_ACCESS_SET_NORM_ASSIGN
      SET status_code = NULL, request_id = NULL
      WHERE status_code IN ('I', 'U')
      AND   request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
      AND   access_set_id IN
		(SELECT implicit_access_set_id
		 FROM 	GL_LEDGERS
		 WHERE  chart_of_accounts_id =
			  GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
		 AND	object_type_code = 'L');

    END IF;

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0118',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_ACCESS_SET_NORM_ASSIGN');
    row_count := 0;

    GL_MESSAGE.Func_Succ
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Clean_Up_By_Coa');

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
       GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0203',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'GL_FLATTEN_ACCESS_SETS.Clean_Up_By_Coa()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

       GL_MESSAGE.Func_Fail
	(func_name => 'GL_FLATTEN_ACCESS_SETS.Clean_Up_By_Coa');

       RETURN FALSE;

  END Clean_Up_By_Coa;

-- ******************************************************************

END GL_FLATTEN_ACCESS_SETS;


/
