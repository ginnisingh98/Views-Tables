--------------------------------------------------------
--  DDL for Package Body GL_FLATTEN_LEDGER_SETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_FLATTEN_LEDGER_SETS" AS
/* $Header: glufllsb.pls 120.9 2005/05/05 01:38:15 kvora ship $ */

-- ********************************************************************

  FUNCTION Fix_Explicit_Sets RETURN BOOLEAN IS
    row_count		NUMBER := 0;
    stop_processing	BOOLEAN := FALSE;
    loop_exists		NUMBER := 0;
    GLSTFL_fatal_err	EXCEPTION;
  BEGIN

    -- This is the routine that processes changes in explicit ledger
    -- sets.  The basic flow is as follows:
    -- 1) Clean up GL_LEDGER_SET_ASSIGNMENTS
    -- 2) Clean up GL_ACCESS_SET_NORM_ASSIGN
    -- 3) For all newly created ledger sets, populate implicit access set
    --    information into GL_ACCESS_SET_NORM_ASSIGN
    -- 4) Mark all outdated mappings in GL_LEDGER_SET_ASSIGNMENTS for
    --    delete.
    -- 5) Insert new mappings into GL_LEDGER_SET_ASSIGNMENTS
    -- 6) Check if looping exists in the ledger set assignments.  If so,
    --    error out.

    GL_MESSAGE.Func_Ent
	(func_name => 'GL_FLATTEN_LEDGER_SETS.Fix_Explicit_Sets');

    -- Clean up the GL_LEDGER_SET_ASSIGNMENTS table for any
    -- unprocessed data left over from previous failed run

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Fix_Explicit_Sets()',
         t2        => 'ACTION',
         v2        => 'Deleting records with status code I in ' ||
                      'GL_LEDGER_SET_ASSIGNMENTS...');
    END IF;

    DELETE from GL_LEDGER_SET_ASSIGNMENTS
    WHERE status_code = 'I'
    AND   ledger_set_id IN
	  (SELECT ledger_id
	   FROM	  GL_LEDGERS
	   WHERE  object_type_code = 'S'
 	   AND 	  chart_of_accounts_id = GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID);

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0119',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_LEDGER_SET_ASSIGNMENTS');
    row_count := 0;

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Fix_Explicit_Sets()',
         t2        => 'ACTION',
         v2        => 'Updating records with status code D in ' ||
                      'GL_LEDGER_SET_ASSIGNMENTS...');
    END IF;

    UPDATE GL_LEDGER_SET_ASSIGNMENTS
    SET	   status_code = NULL
    WHERE  status_code = 'D'
    AND	   ledger_set_id IN
	   (SELECT ledger_id
	    FROM   GL_LEDGERS
            WHERE  object_type_code = 'S'
            AND    chart_of_accounts_id =
			GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID);

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0118',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_LEDGER_SET_ASSIGNMENTS');
    row_count := 0;

    -- Delete from  GL_ACCESS_SET_NORM_ASSIGN for any new assignments
    -- created for the implicit access sets associated with
    -- these explicit ledger sets that are left over from pervious runs.
    -- We don't need to reset the D record for this table since the
    -- implicit access sets of ledger sets only contain 1 assignment,
    -- and that is the ledger set itself.
    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Fix_Explicit_Sets()',
         t2        => 'ACTION',
         v2        => 'Deleting records with status code I in ' ||
                      'GL_ACCESS_SET_NORM_ASSIGN...');
    END IF;

    DELETE from GL_ACCESS_SET_NORM_ASSIGN
    WHERE status_code = 'I'
    AND   access_set_id IN
	  (SELECT implicit_access_set_id
	   FROM	  GL_LEDGERS
	   WHERE  object_type_code = 'S'
 	   AND 	  chart_of_accounts_id = GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID);

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0119',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_ACCESS_SET_NORM_ASSIGN');
    row_count := 0;

    -- Commit all work so far
    FND_CONCURRENT.Af_Commit;

    -- Populate access information into GL_ACCESS_SET_NORM_ASSIGN
    -- for all newly created ledger sets.

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Fix_Explicit_Sets()',
         t2        => 'ACTION',
         v2        => 'Insert access information into ' ||
		      'GL_ACCESS_SET_NORM_ASSIGN ' ||
		      'for new ledger sets...');
    END IF;

    INSERT INTO GL_ACCESS_SET_NORM_ASSIGN
    (access_set_id, ledger_id, all_segment_value_flag,
     segment_value_type_code, access_privilege_code, status_code,
     record_id, link_id, last_update_date, last_updated_by,
     last_update_login, creation_date, created_by, request_id,
     segment_value, start_date, end_date)
    (SELECT distinct
 	    gll.implicit_access_set_id, gllsna.ledger_set_id, 'Y',
	    'S', 'B', 'I', -1,
	    NULL, SYSDATE, GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
	    GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID, SYSDATE,
	    GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
	    GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID,
	    NULL, gllsna.start_date, gllsna.end_date
     FROM   GL_LEDGER_SET_NORM_ASSIGN gllsna,
	    GL_LEDGERS gll
     WHERE  gllsna.status_code = 'I'
     AND    gllsna.request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
     AND    gll.ledger_id = gllsna.ledger_set_id
     AND    gll.chart_of_accounts_id = GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
     AND    gll.automatically_created_flag = 'N'
     AND    NOT EXISTS
	    (SELECT 1
	     FROM 	GL_ACCESS_SET_NORM_ASSIGN glasna
	     WHERE	glasna.access_set_id =
				gll.implicit_access_set_id
  	     AND	glasna.ledger_id = gllsna.ledger_set_id
	     AND	glasna.access_privilege_code = 'B'
 	     AND	glasna.all_segment_value_flag = 'Y'
	     AND	glasna.segment_value_type_code = 'S'
 	     AND	glasna.segment_value is NULL
   	     AND	NVL(glasna.status_code, 'X') <> 'D'));

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0117',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_ACCESS_SET_NORM_ASSIGN');
    row_count := 0;

    -- Update the record_id column of the newly created records
    -- in GL_ACCESS_SET_NORM_ASSIGN

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Fix_Explicit_Sets()',
         t2        => 'ACTION',
         v2        => 'Updating records with new record_id in ' ||
		      'GL_ACCESS_SET_NORM_ASSIGN ' ||
		      'for new ledger sets...');
    END IF;

    UPDATE GL_ACCESS_SET_NORM_ASSIGN glasna
    SET	glasna.record_id = GL_ACCESS_SET_NORM_ASSIGN_S.nextval
    WHERE glasna.status_code = 'I'
    AND   glasna.request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
    AND	  glasna.record_id = -1
    AND   glasna.access_set_id IN
	  (SELECT gll.implicit_access_set_id
	   FROM   GL_LEDGERS gll
	   WHERE  gll.chart_of_accounts_id =
			GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
	   AND    gll.automatically_created_flag = 'N'
	   AND	  gll.object_type_code = 'S');

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0118',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_ACCESS_SET_NORM_ASSIGN');
    row_count := 0;

    -- Commit all work
    FND_CONCURRENT.Af_Commit;

    -- This section of code will mark any outdated ledger set/ledger
    -- mappings for delete.
    -- Here is the sequence of events:
    -- 1) For all records in GL_LEDGER_SET_NORM_ASSIGN with a status_code
    --    of 'D', go into GL_LEDGER_SET_ASSIGNMENTS and determine all
    --    records that contain the deleted mappings, and mark them for
    --    delete as well.
    -- 2) For any ledger sets that are deleted, mark all of their
    --	  descendants for delete as well.
    -- 3) Restore any mappings that are included via other paths.  This
    --    will be run in a loop until no changes occur.

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Fix_Explicit_Sets()',
         t2        => 'ACTION',
         v2        => 'Marking outdated ledger set/ledger mappings ' ||
	 	      'in GL_LEDGER_SET_ASSIGNMENTS for delete...');

      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Fix_Explicit_Sets()',
         t2        => 'ACTION',
         v2        => 'First, mark all ascendants containing the ' ||
		      'deleted links ' ||
		      'for delete in GL_LEDGER_SET_ASSIGNMENTS...');
    END IF;

    UPDATE GL_LEDGER_SET_ASSIGNMENTS gllsa1
    SET	   gllsa1.status_code = 'D'
    WHERE  NVL(gllsa1.status_code, 'X') <> 'D'
    AND	   (gllsa1.ledger_set_id, gllsa1.ledger_id) IN
	   (SELECT distinct gllsa2.ledger_set_id, gllsna.ledger_id
  	    FROM   GL_LEDGER_SET_NORM_ASSIGN gllsna,
		   GL_LEDGERS gll,
		   GL_LEDGER_SET_ASSIGNMENTS gllsa2
	    WHERE  gllsna.status_code = 'D'
	    AND	   gllsna.request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
	    AND	   gll.ledger_id = gllsna.ledger_set_id
   	    AND	   gll.chart_of_accounts_id =
			GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
 	    AND	   gll.automatically_created_flag = 'N'
	    AND	   gll.object_type_code = 'S'
 	    AND	   gllsa2.ledger_id = gllsna.ledger_set_id)
    AND    gllsa1.ledger_set_id <> gllsa1.ledger_id;

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0118',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_LEDGER_SET_ASSIGNMENTS');
    row_count := 0;

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Fix_Explicit_Sets()',
         t2        => 'ACTION',
         v2        => 'Second, mark descendants of deleted ledger sets ' ||
		      'for delete in GL_LEDGER_SET_ASSIGNMENTS...');
    END IF;

    UPDATE GL_LEDGER_SET_ASSIGNMENTS gllsa1
    SET	   gllsa1.status_code = 'D'
    WHERE  NVL(gllsa1.status_code, 'X') <> 'D'
    AND	   (gllsa1.ledger_set_id, gllsa1.ledger_id) IN
	   (SELECT distinct gllsa2.ledger_set_id, gllsa3.ledger_id
	    FROM   GL_LEDGER_SET_NORM_ASSIGN gllsna,
		   GL_LEDGERS gll,
		   GL_LEDGER_SET_ASSIGNMENTS gllsa2,
		   GL_LEDGER_SET_ASSIGNMENTS gllsa3
  	    WHERE  gllsna.status_code = 'D'
	    AND	   gllsna.request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
	    AND	   gll.ledger_id = gllsna.ledger_set_id
	    AND    gll.chart_of_accounts_id =
			GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
	    AND	   gll.automatically_created_flag = 'N'
	    AND	   gll.object_type_code = 'S'
    	    AND	   gllsa2.ledger_id = gllsna.ledger_set_id
 	    AND    gllsa3.ledger_set_id = gllsna.ledger_id)
    AND	   gllsa1.ledger_set_id <> gllsa1.ledger_id;

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0118',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_LEDGER_SET_ASSIGNMENTS');
    row_count := 0;

    -- Commit changes so far before going into a loop
    FND_CONCURRENT.Af_Commit;

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Fix_Explicit_Sets()',
         t2        => 'ACTION',
         v2        => 'Third, reconnect all deleted mappings in ' ||
		      'GL_LEDGER_SET_ASSIGNMENTS that are included via ' ||
		      'other effective paths...');
    END IF;

    WHILE NOT stop_processing
    LOOP
      UPDATE GL_LEDGER_SET_ASSIGNMENTS gllsa1
      SET    gllsa1.status_code = NULL
      WHERE  gllsa1.status_code = 'D'
      AND    gllsa1.ledger_set_id IN
	     (SELECT gll.ledger_id
 	      FROM   GL_LEDGERS gll
	      WHERE  gll.chart_of_accounts_id =
			GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
	      AND    gll.object_type_code = 'S'
	      AND    gll.automatically_created_flag = 'N')
      AND    (	  EXISTS
	     		(SELECT 1
	      		 FROM   GL_LEDGER_SET_ASSIGNMENTS gllsa2,
		     		GL_LEDGER_SET_ASSIGNMENTS gllsa3
	      		 WHERE  gllsa2.status_code is NULL
	      		 AND    gllsa2.ledger_id = gllsa1.ledger_id
	      		 AND    gllsa3.status_code is NULL
	      		 AND    gllsa3.ledger_set_id = gllsa1.ledger_set_id
	      		 AND    gllsa3.ledger_id = gllsa2.ledger_set_id)
	      OR  EXISTS
			(SELECT 1
			 FROM 	GL_LEDGER_SET_NORM_ASSIGN gllsna
			 WHERE	gllsna.ledger_set_id = gllsa1.ledger_set_id
			 AND	gllsna.ledger_id = gllsa1.ledger_id
			 AND	gllsna.status_code is NULL));

      row_count := row_count + NVL(SQL%ROWCOUNT, 0);
      stop_processing := SQL%NOTFOUND;

      FND_CONCURRENT.Af_Commit;
    END LOOP;

    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0118',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_LEDGER_SET_ASSIGNMENTS');

    row_count := 0;

    -- This section of the code will insert new ledger set/ledger
    -- mappings into GL_LEDGER_SET_ASSIGNMENTS.
    -- Here is the sequence of events:
    -- 1) Insert a self mapping record for each new ledger set.
    -- 2) Add all newly added ledgers to the respective ledger sets.
    -- 3) Insert mappings for all descendants of newly added child ledger
    --    sets.  This will be run in a loop until no changes occur.

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Fix_Explicit_Sets()',
         t2        => 'ACTION',
         v2        => 'Inserting self mapping record for new ledger sets ' ||
		      'into GL_LEDGER_SET_ASSIGNMENTS');
    END IF;

    INSERT INTO GL_LEDGER_SET_ASSIGNMENTS
    (ledger_set_id, ledger_id, status_code, last_update_date,
     last_updated_by, last_update_login, creation_date,
     created_by, start_date, end_date)
    (SELECT distinct gll.ledger_id, gll.ledger_id, 'I', SYSDATE,
		     GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		     GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID,
		     SYSDATE, GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		     NULL, NULL
     FROM   GL_LEDGERS gll
     WHERE  gll.object_type_code = 'S'
     AND    gll.chart_of_accounts_id = GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
     AND    gll.automatically_created_flag = 'N'
     AND    NOT EXISTS
		(SELECT 1
		 FROM 	GL_LEDGER_SET_ASSIGNMENTS gllsa
		 WHERE	gllsa.ledger_set_id = gll.ledger_id
		 AND	gllsa.ledger_id = gll.ledger_id
		 AND	NVL(gllsa.status_code, 'X') <> 'D'));

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0117',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_LEDGER_SET_ASSIGNMENTS');
    row_count := 0;

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Fix_Explicit_Sets()',
         t2        => 'ACTION',
         v2        => 'Inserting new ledgers to the respective ' ||
		      'ledger sets into GL_LEDGER_SET_ASSIGNMENTS...');
    END IF;

    INSERT INTO GL_LEDGER_SET_ASSIGNMENTS
    (ledger_set_id, ledger_id, status_code, last_update_date,
     last_updated_by, last_update_login, creation_date,
     created_by, start_date, end_date)
    (SELECT distinct gllsa.ledger_set_id, gllsna.ledger_id, 'I', SYSDATE,
		     GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		     GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID,
		     SYSDATE, GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		     NULL, NULL
     FROM   GL_LEDGER_SET_NORM_ASSIGN gllsna,
	    GL_LEDGERS gll,
	    GL_LEDGER_SET_ASSIGNMENTS gllsa
     WHERE  gllsna.status_code = 'I'
     AND    gllsna.request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
     AND    gll.ledger_id = gllsna.ledger_id
     AND    gll.chart_of_accounts_id = GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
     AND    gll.object_type_code = 'L'
     AND    gllsa.ledger_id = gllsna.ledger_set_id
     AND    NVL(gllsa.status_code, 'X') <> 'D'
     AND    NOT EXISTS
		(SELECT 1
		 FROM 	GL_LEDGER_SET_ASSIGNMENTS gllsa2
		 WHERE	gllsa2.ledger_set_id = gllsa.ledger_set_id
	  	 AND	gllsa2.ledger_id = gllsna.ledger_id
 		 AND	NVL(gllsa2.status_code, 'X') <> 'D'));

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0117',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_LEDGER_SET_ASSIGNMENTS');
    row_count := 0;

    -- Commit before going into a loop
    FND_CONCURRENT.Af_Commit;

    stop_processing := FALSE;

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Fix_Explicit_Sets()',
         t2        => 'ACTION',
         v2        => 'Inserting all descendants of new ledger sets into ' ||
		      'GL_LEDGER_SET_ASSIGNMENTS...');
    END IF;

    WHILE NOT stop_processing
    LOOP
      INSERT INTO GL_LEDGER_SET_ASSIGNMENTS
      (ledger_set_id, ledger_id, status_code, last_update_date,
       last_updated_by, last_update_login, creation_date,
       created_by, start_date, end_date)
      (SELECT distinct gllsa1.ledger_set_id, gllsa2.ledger_id,
		       'I', SYSDATE, GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		       GL_FLATTEN_SETUP_DATA.GLSTFL_LOGIN_ID, SYSDATE,
		       GL_FLATTEN_SETUP_DATA.GLSTFL_USER_ID,
		       NULL, NULL
	FROM  GL_LEDGER_SET_NORM_ASSIGN gllsna,
	      GL_LEDGERS gll,
	      GL_LEDGER_SET_ASSIGNMENTS gllsa1,
	      GL_LEDGER_SET_ASSIGNMENTS gllsa2
   	WHERE gllsna.status_code = 'I'
	AND   gllsna.request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
	AND   gll.ledger_id = gllsna.ledger_set_id
	AND   gll.chart_of_accounts_id =
		GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
	AND   gll.object_type_code = 'S'
 	AND   gll.automatically_created_flag = 'N'
	AND   gllsa1.ledger_id = gllsna.ledger_set_id
	AND   NVL(gllsa1.status_code, 'X') <> 'D'
 	AND   gllsa2.ledger_set_id = gllsna.ledger_id
	AND   NVL(gllsa2.status_code, 'X') <> 'D'
	AND   NOT EXISTS
		(SELECT 1
		 FROM 	GL_LEDGER_SET_ASSIGNMENTS gllsa3
		 WHERE	gllsa3.ledger_set_id = gllsa1.ledger_set_id
		 AND	gllsa3.ledger_id = gllsa2.ledger_id
		 AND	NVL(gllsa3.status_code, 'X') <> 'D'));

      row_count := row_count + NVL(SQL%ROWCOUNT, 0);
      stop_processing := SQL%NOTFOUND;

      FND_CONCURRENT.Af_Commit;
    END LOOP;

    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0117',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_LEDGER_SET_ASSIGNMENTS');

    BEGIN
      SELECT 1
      INTO loop_exists
      FROM DUAL
      WHERE EXISTS
	   (SELECT 	1
            FROM 	GL_LEDGER_SET_ASSIGNMENTS gllsa1,
			GL_LEDGERS gll,
			GL_LEDGER_SET_ASSIGNMENTS gllsa2
	    WHERE	gllsa1.status_code = 'I'
	    AND		gll.ledger_id = gllsa1.ledger_set_id
	    AND		gll.chart_of_accounts_id =
				GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
	    AND		gll.object_type_code = 'S'
	    AND		gll.automatically_created_flag = 'N'
	    AND		gllsa1.ledger_set_id <> gllsa1.ledger_id
	    AND 	NVL(gllsa2.status_code, 'X') <> 'D'
	    AND		gllsa2.ledger_set_id = gllsa1.ledger_id
 	    AND		gllsa2.ledger_id = gllsa1.ledger_set_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	loop_exists := 0;
      END;

    IF (loop_exists <> 0) THEN
      -- report error
      FND_FILE.put_line(FND_FILE.LOG,
			  'loop count := ' || TO_CHAR(NVL(SQL%ROWCOUNT,0)));

      GL_MESSAGE.Write_Log(msg_name	=> 'FLAT0019',
			    token_num	=> 0);

      RAISE GLSTFL_fatal_err;
    END IF;


    GL_MESSAGE.Func_Succ
	(func_name	=> 'GL_FLATTEN_LEDGER_SETS.Fix_Explicit_Sets');

    RETURN TRUE;

  -- Exception handling
  EXCEPTION
    WHEN GLSTFL_fatal_err THEN

      GL_MESSAGE.Write_Log
	(msg_name  => 'FLAT0002',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'GL_FLATTEN_LEDGER_SETS.Fix_Exlicit_Sets()');

      -- Rollback
      FND_CONCURRENT.Af_Rollback;

      GL_MESSAGE.Func_Fail
	(func_name =>'GL_FLATTEN_LEDGER_SETS.Fix_Explicit_Sets');

      RETURN FALSE;

    WHEN OTHERS THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0203',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'GL_FLATTEN_LEDGER_SETS.Fix_Explicit_Sets()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

      -- Rollback
      FND_CONCURRENT.Af_Rollback;

      GL_MESSAGE.Func_Fail
	  (func_name	=> 'GL_FLATTEN_LEDGER_SETS.Fix_Explicit_Sets');

      RETURN FALSE;

  END Fix_Explicit_Sets;

-- ******************************************************************

  FUNCTION Clean_Up_Explicit_Sets RETURN BOOLEAN IS
    row_count	NUMBER := 0;
  BEGIN

    GL_MESSAGE.Func_Ent
	(func_name => 'GL_FLATTEN_LEDGER_SETS.Clean_Up_Explicit_Sets');

    -- Run the following statements to clean up both
    -- GL_LEDGER_SET_NORM_ASSIGN and GL_LEDGER_SET_ASSIGNMENTS

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Clean_Up_Explicit_Sets()',
         t2        => 'ACTION',
         v2        => 'Deleting records from GL_LEDGER_SET_NORM_ASSIGN...');
    END IF;

    -- Delete records from GL_LEDGER_SET_NORM_ASSIGN

    DELETE from GL_LEDGER_SET_NORM_ASSIGN
    WHERE status_code = 'D'
    AND	  request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
    AND   ledger_set_id IN
	 	(SELECT ledger_id
		 FROM 	GL_LEDGERS
		 WHERE	object_type_code = 'S'
		 AND	chart_of_accounts_id =
				GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID);

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0119',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_LEDGER_SET_NORM_ASSIGN');
    row_count := 0;

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Clean_Up_Explicit_Sets()',
         t2        => 'ACTION',
         v2        => 'Updating records in GL_LEDGER_SET_NORM_ASSIGN...');
    END IF;

    -- Update records in GL_LEDGER_SET_NORM_ASSIGN
    -- Bear in mind there will never be U records in gllsna

    UPDATE GL_LEDGER_SET_NORM_ASSIGN
    SET   status_code = NULL, request_id = NULL
    WHERE status_code = 'I'
    AND	  request_id = GL_FLATTEN_SETUP_DATA.GLSTFL_REQ_ID
    AND   ledger_set_id IN
	 	(SELECT ledger_id
		 FROM 	GL_LEDGERS
		 WHERE	object_type_code = 'S'
		 AND	chart_of_accounts_id =
				GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID);

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0118',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_LEDGER_SET_NORM_ASSIGN');
    row_count := 0;

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Clean_Up_Explicit_Sets()',
         t2        => 'ACTION',
         v2        => 'Deleting records from GL_LEDGER_SET_ASSIGNMENTS...');
    END IF;

    -- Delete records from GL_LEDGER_SET_ASSIGNMENTS

    DELETE from GL_LEDGER_SET_ASSIGNMENTS
    WHERE status_code = 'D'
    AND   ledger_set_id IN
	 	(SELECT ledger_id
		 FROM 	GL_LEDGERS
		 WHERE	object_type_code = 'S'
		 AND	chart_of_accounts_id =
				GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID);

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0119',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_LEDGER_SET_ASSIGNMENTS');
    row_count := 0;

    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
      GL_MESSAGE.Write_log
	(msg_name  => 'SHRD0180',
         token_num => 2,
         t1        => 'ROUTINE',
         v1        => 'Clean_Up_Explicit_Sets()',
         t2        => 'ACTION',
         v2        => 'Updating records in GL_LEDGER_SET_ASSIGNMENTS...');
    END IF;

    -- Update records in GL_LEDGER_SET_ASSIGNMENTS
    -- Bear in mind there will never be U records in gllsa

    UPDATE GL_LEDGER_SET_ASSIGNMENTS
    SET   status_code = NULL
    WHERE status_code = 'I'
    AND   ledger_set_id IN
	 	(SELECT ledger_id
		 FROM 	GL_LEDGERS
		 WHERE	object_type_code = 'S'
		 AND	chart_of_accounts_id =
				GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID);

    row_count := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0118',
		 	  token_num	=> 2,
			  t1		=> 'NUM',
			  v1		=> TO_CHAR(row_count),
			  t2		=> 'TABLE',
			  v2		=> 'GL_LEDGER_SET_ASSIGNMENTS');

    GL_MESSAGE.Func_Succ
	(func_name => 'GL_FLATTEN_LEDGER_SETS.Clean_Up_Explicit_Sets');

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
       GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0203',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'GL_FLATTEN_LEDGER_SETS.Clean_Up_Explicit_Sets()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

       GL_MESSAGE.Func_Fail
	(func_name => 'GL_FLATTEN_LEDGER_SETS.Clean_Up_Explicit_Sets');

       RETURN FALSE;

  END Clean_Up_Explicit_Sets;

-- ******************************************************************

END GL_FLATTEN_LEDGER_SETS;


/
