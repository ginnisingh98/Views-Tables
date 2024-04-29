--------------------------------------------------------
--  DDL for Package Body GL_FLATTEN_SETUP_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_FLATTEN_SETUP_DATA" AS
/* $Header: gluflsdb.pls 120.17 2005/09/01 00:03:37 spala noship $ */



--********************************************************************
 -- Private function.
  FUNCTION Check_Seg_val_Hierarchy(x_mode VARCHAR2,
                                   x_vs_id NUMBER)
                                   RETURN BOOLEAN IS
  l_cont_processing BOOLEAN;
  Seg_val_Hier_err  EXCEPTION;
  result_val        BOOLEAN;
  tab_val_vs        VARCHAR2(30);
  tab_val_VS_col    VARCHAR2(30);

  BEGIN



    GL_MESSAGE.Func_Ent(func_name =>
              'GL_FLATTEN_SETUP_DATA.Check_Seg_val_Hierarchy');

      GLSTFL_VS_ID := x_vs_id ;
       GL_MESSAGE.Write_Log(msg_name	=> 'Value Set is '||GLSTFL_VS_ID,
			  	token_num	=> 0);

      -- Call routine to check if the value set is a table
      -- validated set.
      result_val := GL_FLATTEN_SETUP_DATA.Get_Value_Set_Info
		      (X_Vs_Id		=> GLSTFL_VS_ID,
		       Table_Name	  => tab_val_vs,
                       Column_Name          => tab_val_vs_col);

      IF (NOT result_val) THEN
	RAISE Seg_val_Hier_err;
      END IF;

      GLSTFL_VS_TAB_NAME := tab_val_vs;
      GLSTFL_VS_COL_NAME := tab_val_vs_col;
      -- Request exclusive lock on the value set ID
      result_val := GL_FLATTEN_SETUP_DATA.Request_Lock
			     (X_Param_Type	=> 'V',
		   	      X_Param_Id	=> GLSTFL_VS_ID,
		   	      X_Lock_Mode	=> 6,  -- EXCLUSIVE mode
		   	      X_Keep_Looping	=> TRUE,
		   	      X_Max_Trys	=> 5);

      IF (NOT result_val) THEN
	RAISE Seg_val_Hier_err;
      END IF;

      -- Call routine to fix value set and segment value hierarchies first.
      result_val := GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier
			(Is_Seg_Hier_Changed => l_cont_processing);

      IF (NOT result_val) THEN
	RAISE Seg_val_Hier_err;
      END IF;

      -- Release exclusive lock on the value set ID
      result_val := GL_FLATTEN_SETUP_DATA.Release_Lock
			     (X_Param_Type	=> 'V',
		   	      X_Param_Id	=> GLSTFL_VS_ID);

      IF (NOT result_val) THEN
	RAISE Seg_val_Hier_err;
      END IF;


           -- Call routine to clean up value set and
      -- segment value hierarchies first.
      result_val := GL_FLATTEN_SEG_VAL_HIERARCHIES.Clean_Up;

      IF (NOT result_val) THEN
	RAISE Seg_val_Hier_err;
      END IF;

     GL_MESSAGE.Func_Succ(func_name =>
                'GL_FLATTEN_SETUP_DATA.Check_Seg_val_Hierarchy');

     Return True;

   EXCEPTION
     WHEN Seg_val_Hier_err THEn
       -- Release exclusive lock on the value set ID
        result_val := GL_FLATTEN_SETUP_DATA.Release_Lock
			 (X_Param_Type	=> 'V',
	   		  X_Param_Id	=> GLSTFL_VS_ID);
      GL_MESSAGE.Func_Fail(func_name =>
                      'GL_FLATTEN_SETUP_DATA.Check_Seg_val_Hierarchy');
      Return False;

  END Check_Seg_val_Hierarchy;

-- ********************************************************************

  PROCEDURE Main(X_Mode			VARCHAR2,
	  	 X_Mode_Parameter	VARCHAR2,
		 X_Debug		VARCHAR2 DEFAULT NULL) IS
    GLSTFL_fatal_err	EXCEPTION;
    ret_val		BOOLEAN;
    cont_processing	BOOLEAN;
    is_vs_tab_validated	BOOLEAN	:= FALSE;
    vs_tab_name		VARCHAR2(240) := NULL;
    vs_col_name         VARCHAR2(240) := NULL;
    row_count		NUMBER := 0;
    l_dmode_profile     fnd_profile_option_values.profile_option_value%TYPE;
    rval                BOOLEAN     := FALSE;
    dummy1              VARCHAR2(2) := NULL;
    dummy2              VARCHAR2(2) := NULL;
    schema              VARCHAR2(30):= NULL;

  BEGIN

    GL_MESSAGE.Func_Ent(func_name => 'GL_FLATTEN_SETUP_DATA.Main');

    -- Obtain user ID, login ID and concurrent request ID and initialize

    -- package variables

    GLSTFL_USER_ID 	:= FND_GLOBAL.User_Id;
    GLSTFL_LOGIN_ID	:= FND_GLOBAL.Login_Id;
    GLSTFL_REQ_ID	:= FND_GLOBAL.Conc_Request_Id;

    -- If any of the above values is not set, error out
    IF (GLSTFL_USER_ID is NULL OR
	GLSTFL_LOGIN_ID is NULL OR
	GLSTFL_REQ_ID is NULL) THEN

      -- Fail to initialize
      GL_MESSAGE.Write_Log(msg_name	=> 'FLAT0011',
			    token_num	=> 0);

      RAISE GLSTFL_fatal_err;
    END IF;

     FND_PROFILE.GET('GL_DEBUG_MODE', l_dmode_profile);

GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                              token_num => 3 ,
                              t1        =>'ROUTINE',
                              v1        =>
                                       'GL_FLATTEN_SETUP_DATA.Main',
                              t2        =>'VARIABLE',
                              v2        =>'Application Profile Debug Mode:',
                              t3        =>'VALUE',
                              v3        => l_dmode_profile);

    -- Determine if process will be run in debug mode
    IF (NVL(X_Debug, 'N') <> 'N') OR (l_dmode_profile = 'Y') THEN
      GLSTFL_Debug := TRUE;
    ELSE
      GLSTFL_Debug := FALSE;
    END IF;


    -- Turn trace on if process is run in debug mode
    IF (GLSTFL_Debug) THEN

      -- Program running in debug mode, turning trace on
      GL_MESSAGE.Write_Log(msg_name	=> 'FLAT0012',
			    token_num	=> 0);

      EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE TRUE';

    END IF;

    -- Initialize other package variables based on operation mode
    -- Valid operation modes are:
    --   SH: Value set and Segment Value Hierarchy Maintenance
    --   FF: Value Set Maintenance Only
    --   LV: Ledger Segment Values Maintenance
    --   LH: Ledger Hierarchy Maintenance  -- obsolete
    --   VH: Ledger Segment Values and Hierarchy Maintenance
    --   LS: Explicit Ledger Sets Maintenance on ledger assignments
    --   VS: Explicit Ledger Sets Maintenance on both ledger
    --	     assignments and segment value assignments.
    --   AS: Explicit Access Sets Maintenance

    IF (X_Mode IN ('SH', 'FF')) THEN
      GLSTFL_OP_MODE := X_Mode;
      GLSTFL_VS_ID := TO_NUMBER(X_Mode_Parameter);

      -- Call routine to check if the value set is a table
      -- validated set.
      ret_val := GL_FLATTEN_SETUP_DATA.Get_Value_Set_Info
		  (X_Vs_Id		=> GLSTFL_VS_ID,
		   Table_Name		=> vs_tab_name,
                   Column_Name          => vs_col_name);

      IF (NOT ret_val) THEN
	RAISE GLSTFL_fatal_err;
      END IF;

      GLSTFL_VS_TAB_NAME := vs_tab_name;
      GLSTFL_VS_COL_NAME := vs_col_name;

    ELSIF (X_Mode IN ('LV', 'LH', 'VH', 'LS', 'AS', 'VS')) THEN
      GLSTFL_OP_MODE := X_Mode;
      GLSTFL_COA_ID:= TO_NUMBER(X_Mode_Parameter);

      -- Populate the value set IDs of the balancing and management
      -- segments for this chart of accounts
      SELECT bal_seg_value_set_id, mgt_seg_value_set_id
      INTO   GLSTFL_BAL_VS_ID, GLSTFL_MGT_VS_ID
      FROM   GL_LEDGERS
      WHERE  chart_of_accounts_id = GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID
      AND    rownum = 1;

    ELSE
      -- Invalid Operation mode, error out
      GL_MESSAGE.Write_Log(msg_name	=> 'FLAT0013',
			    token_num	=> 0);

      RAISE GLSTFL_fatal_err;

    END IF;

    -- Print out program parameters
    GL_MESSAGE.Write_Log(msg_name	=> 'FLAT0014',
			  token_num	=> 5,
			  t1		=> 'REQ_ID',
			  v1		=> TO_CHAR(GLSTFL_REQ_ID),
			  t2		=> 'OP_MODE',
			  v2		=> GLSTFL_OP_MODE,
			  t3		=> 'COA_ID',
			  v3		=> TO_CHAR(GLSTFL_COA_ID),
			  t4		=> 'VS_ID',
			  v4		=> TO_CHAR(GLSTFL_VS_ID),
			  t5		=> 'VS_TAB_NAME',
			  v5		=> GLSTFL_VS_TAB_NAME);

    GL_MESSAGE.Write_Log(msg_name	=> 'FLAT0018',
			  token_num	=> 3,
			  t1		=> 'BAL_VS_ID',
			  v1		=> TO_CHAR(GLSTFL_BAL_VS_ID),
			  t2		=> 'MGT_VS_ID',
			  v2		=> TO_CHAR(GLSTFL_MGT_VS_ID),
			  t3		=> 'DEBUG_MODE',
			  v3		=> NVL(X_Debug, 'N'));

    -- Obtain the appropriate locks depending on the operation mode
    IF (GLSTFL_OP_MODE IN ('SH', 'FF')) THEN

      -- Request exclusive lock on the value set ID
      ret_val := GL_FLATTEN_SETUP_DATA.Request_Lock
			     (X_Param_Type	=> 'V',
		   	      X_Param_Id	=> GLSTFL_VS_ID,
		   	      X_Lock_Mode	=> 6,  -- EXCLUSIVE mode
		   	      X_Keep_Looping	=> TRUE,
		   	      X_Max_Trys	=> 5);

      IF (NOT ret_val) THEN
	RAISE GLSTFL_fatal_err;
      END IF;

    ELSIF (GLSTFL_OP_MODE IN ('LV', 'LH', 'VH', 'LS', 'AS', 'VS')) THEN

      -- Request exclusive lock on the chart of accounts ID
      ret_val := GL_FLATTEN_SETUP_DATA.Request_Lock
			     (X_Param_Type	=> 'C',
		   	      X_Param_Id	=> GLSTFL_COA_ID,
		   	      X_Lock_Mode	=> 6,  -- EXCLUSIVE mode
		   	      X_Keep_Looping	=> TRUE,
		   	      X_Max_Trys	=> 5);

       IF (NOT ret_val) THEN
      	 RAISE GLSTFL_fatal_err;
       END IF;

    END IF;

    -- Populate the REQUEST_ID column of the various norm tables based
    -- on the operation mode.
    -- 1) GL_LEDGER_NORM_SEG_VALS: LV, VH, VS
    -- 2) GL_LEDGER___NORM___HIERARCHY: VH, LH
    -- 3) GL_LEDGER_SET_NORM_ASSIGN: VS, LS
    -- 4) GL_ACCESS_SET_NORM_ASSIGN: AS
    IF (GLSTFL_OP_MODE IN ('LV', 'VH', 'VS')) THEN
      IF (GLSTFL_Debug) THEN
        GL_MESSAGE.Write_Log
	  (msg_name  => 'SHRD0180',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Main()',
           t2        => 'ACTION',
           v2        => 'Locking down changed records in ' ||
			'GL_LEDGER_NORM_SEG_VALS by populating ' ||
			'the REQUEST_ID column...');
      END IF;

      UPDATE GL_LEDGER_NORM_SEG_VALS
      SET request_id = GLSTFL_REQ_ID
      WHERE status_code is NOT NULL
      AND   ledger_id IN ( SELECT LEDGER_ID FROM GL_LEDGERS
                           WHERE chart_of_accounts_id =
                                    GL_FLATTEN_SETUP_DATA.GLSTFL_COA_ID);

      IF (GLSTFL_Debug) THEN
        row_count := SQL%ROWCOUNT;
        GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0118',
	   	 	      token_num	=> 2,
			      t1	=> 'NUM',
			      v1	=> TO_CHAR(row_count),
			      t2	=> 'TABLE',
			      v2	=> 'GL_LEDGER_NORM_SEG_VALS');

        row_count := 0;
     END IF;
    END IF;

    IF (GLSTFL_OP_MODE IN ('LS', 'VS')) THEN
      IF (GLSTFL_Debug) THEN
        GL_MESSAGE.Write_Log
	  (msg_name  => 'SHRD0180',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Main()',
           t2        => 'ACTION',
           v2        => 'Locking down changed records in ' ||
			'GL_LEDGER_SET_NORM_ASSIGN by populating ' ||
			'the REQUEST_ID column...');
      END IF;

      UPDATE GL_LEDGER_SET_NORM_ASSIGN
      SET request_id = GLSTFL_REQ_ID
      WHERE status_code is NOT NULL;

      IF (GLSTFL_Debug) THEN
        row_count := SQL%ROWCOUNT;
        GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0118',
	  	 	      token_num	=> 2,
			      t1	=> 'NUM',
			      v1	=> TO_CHAR(row_count),
			      t2	=> 'TABLE',
			      v2	=> 'GL_LEDGER_SET_NORM_ASSIGN');

        row_count := 0;
      END IF;
    END IF;

    IF (GLSTFL_OP_MODE = 'AS') THEN
      IF (GLSTFL_Debug) THEN
        GL_MESSAGE.Write_Log
	  (msg_name  => 'SHRD0180',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Main()',
           t2        => 'ACTION',
           v2        => 'Locking down changed records in ' ||
			'GL_ACCESS_SET_NORM_ASSIGN by populating ' ||
			'the REQUEST_ID column...');
      END IF;

      UPDATE GL_ACCESS_SET_NORM_ASSIGN
      SET request_id = GLSTFL_REQ_ID
      WHERE status_code is NOT NULL;

      IF (GLSTFL_Debug) THEN
	row_count := SQL%ROWCOUNT;
      	GL_MESSAGE.Write_Log(msg_name	=> 'SHRD0118',
	  	 	      token_num	=> 2,
			      t1	=> 'NUM',
			      v1	=> TO_CHAR(row_count),
			      t2	=> 'TABLE',
			      v2	=> 'GL_ACCESS_SET_NORM_ASSIGN');

      	row_count := 0;
      END IF;
    END IF;

    -- Commit all work
    FND_CONCURRENT.Af_Commit;

    -- Start processing work according to the mode of operation.
    --
    -- Here is the list of routines called by each mode:
    -- 1) Modes SH, FF:
    --      GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier
    --      GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Value_Set
    --      GL_FLATTEN_ACCESS_SETS.Fix_Flattened_Table
    -- 2) Mode LV:
    --	    GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa
    -- 3) Mode LH:
    --      GL_FLATTEN_LEDGER_HIERARCHIES.Flatten_Ledger_Hier
    --	    GL_FLATTEN_LEDGER_SETS.Fix_Implicit_Sets
    --	    GL_FLATTEN_ACCESS_SETS.Fix_Implicit_Sets
    -- 4) Mode LS:
    --	    GL_FLATTEN_LEDGER_SETS.Fix_Explicit_Sets
    --	    GL_FLATTEN_ACCESS_SETS.Fix_Flattened_Table
    -- 5) Mode VS:
    --	    GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa
    --	    GL_FLATTEN_LEDGER_SETS.Fix_Explicit_Sets
    --	    GL_FLATTEN_ACCESS_SETS.Fix_Flattened_Table
    -- 6) Mode AS:
    --	    GL_FLATTEN_ACCESS_SETS.Fix_Explicit_Sets
    -- 7) Mode VH:
    --	    GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa
    --      GL_FLATTEN_LEDGER_HIERARCHIES.Flatten_Ledger_Hier
    --	    GL_FLATTEN_LEDGER_SETS.Fix_Implicit_Sets
    --	    GL_FLATTEN_ACCESS_SETS.Fix_Implicit_Sets

    IF (GLSTFL_OP_MODE IN ('SH', 'FF')) THEN

      -- Call routine to fix value set and segment value hierarchies first.
      ret_val := GL_FLATTEN_SEG_VAL_HIERARCHIES.Flatten_Seg_Val_Hier
			(Is_Seg_Hier_Changed => cont_processing);

      IF (NOT ret_val) THEN
	RAISE GLSTFL_fatal_err;
      END IF;

      -- Call routine to fix ledger/segment value assignments
      -- only if some changes occurred in the segment value
      -- hierarchies
      IF (cont_processing) THEN

	-- print out debug message
	IF (GLSTFL_Debug) THEN
    	  GL_MESSAGE.Write_Log(msg_name	=> 'FLAT0015',
			  	token_num	=> 0);
	END IF;

      	ret_val := GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Value_Set;

      	IF (NOT ret_val) THEN
   	  RAISE GLSTFL_fatal_err;
      	END IF;

      	-- Call routine to fix GL_ACCESS_SET_ASSIGNMENTS
      	ret_val := GL_FLATTEN_ACCESS_SETS.Fix_Flattened_Table;

      	IF (NOT ret_val) THEN
	  RAISE GLSTFL_fatal_err;
      	END IF;
      END IF;

    ELSIF (GLSTFL_OP_MODE = 'LV') THEN

      -- Call routine to fix ledger/segment value assignments
      ret_val := GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa;

      IF (NOT ret_val) THEN
   	RAISE GLSTFL_fatal_err;
      END IF;

--    LH mode is obsolete


--    ELSIF (GLSTFL_OP_MODE = 'LH') THEN

    -- Call routine to fix ledger hierarchies first
--      ret_val := GL_FLATTEN_LEDGER_HIERARCHIES.Flatten_Ledger_Hier
--			(Is_Ledger_Hier_Changed => cont_processing);

      IF (NOT ret_val) THEN
        RAISE GLSTFL_fatal_err;
      END IF;
-- Commneted out becuase it is not required to call for Ledger Hierararchy
--      IF (cont_processing) THEN

        -- Call routine to fix implicit ledger sets
        --ret_val := GL_FLATTEN_LEDGER_SETS.Fix_Implicit_Sets;

--        IF (NOT ret_val) THEN
--          RAISE GLSTFL_fatal_err;
--        END IF;
--     END IF;

     -- Call routine to fix implicit access sets
--     ret_val := GL_FLATTEN_ACCESS_SETS.Fix_Implicit_Sets
--			(Any_Ledger_Hier_Changes => cont_processing);

--     IF (NOT ret_val) THEN
--       RAISE GLSTFL_fatal_err;
--     END IF;

    ELSIF (GLSTFL_OP_MODE = 'LS') THEN

      -- Call routine to fix explicit ledger sets

      ret_val := GL_FLATTEN_LEDGER_SETS.Fix_Explicit_Sets;

      IF (NOT ret_val) THEN
        RAISE GLSTFL_fatal_err;
      END IF;

      -- Call routine to fix GL_ACCESS_SET_ASSIGNMENTS
      ret_val := GL_FLATTEN_ACCESS_SETS.Fix_Flattened_Table;

      IF (NOT ret_val) THEN
        RAISE GLSTFL_fatal_err;
      END IF;

    ELSIF (GLSTFL_OP_MODE = 'VS') THEN

      -- Call routine to fix explicit ledger sets
      ret_val := GL_FLATTEN_LEDGER_SETS.Fix_Explicit_Sets;

      IF (NOT ret_val) THEN
        RAISE GLSTFL_fatal_err;
      END IF;

      -- Call routine to fix GL_ACCESS_SET_ASSIGNMENTS
      ret_val := GL_FLATTEN_ACCESS_SETS.Fix_Flattened_Table;

      IF (NOT ret_val) THEN
        RAISE GLSTFL_fatal_err;
      END IF;

      -- Call routine to fix ledger/segment value assignments
      ret_val := GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa;

      IF (NOT ret_val) THEN
   	RAISE GLSTFL_fatal_err;
      END IF;

    ELSIF (GLSTFL_OP_MODE = 'AS') THEN

      -- Call routine to fix explicit access sets
      ret_val := GL_FLATTEN_ACCESS_SETS.Fix_Explicit_Sets;

      IF (NOT ret_val) THEN
        RAISE GLSTFL_fatal_err;
      END IF;

    ELSIF (GLSTFL_OP_MODE = 'VH') THEN

      -- This is the combination of both modes LV and LH.
      -- So this mode will do the work of those 2 modes combined.


      -- The following check is to insure there will be
      -- rows in GL_SEG_VAL_HIERARCHIES when a newly created chart of
      -- accounts is used in a Ledger/BSV assignment.

      -- Actually this is a cornor case. A new value set is created and
      -- included this value set in a new Chart Of Accounts. Immediately
      -- assigned this COA to a newly created Ledger. At this time there
      -- will be no rows populated for Balancing segment and management
      -- segment of this COA in GL_SEG_VAL_HIERARCHIES. Flattening program
      -- could not be launched until a new value or a hierarchy change
      -- happens to a value set.


      ret_val := Check_Seg_val_Hierarchy(x_mode => 'SH',
                                        x_vs_id => GLSTFL_BAL_VS_ID);

      IF (NOT ret_val) THEN
        RAISE GLSTFL_fatal_err;
      END IF;

      IF (GLSTFL_BAL_VS_ID <> GLSTFL_MGT_VS_ID) THEN
          ret_val := Check_Seg_val_Hierarchy(x_mode => 'SH',
                                        x_vs_id => GLSTFL_MGT_VS_ID);

          IF (NOT ret_val) THEN
            RAISE GLSTFL_fatal_err;
          END IF;
      END IF;

      -- Call routine to fix ledger hierarchies
--      ret_val := GL_FLATTEN_LEDGER_HIERARCHIES.Flatten_Ledger_Hier
--			(Is_Ledger_Hier_Changed => cont_processing);

--      IF (NOT ret_val) THEN
--        RAISE GLSTFL_fatal_err;
--      END IF;

-- There are no ledger Hierarchies in the flattening program.
--      IF (cont_processing) THEN
        -- Call routine to fix implicit ledger sets

--        ret_val := GL_FLATTEN_LEDGER_SETS.Fix_Implicit_Sets;
--
--        IF (NOT ret_val) THEN
--          RAISE GLSTFL_fatal_err;
--        END IF;
--      END IF;

     /*------------------------------------------------------------------+
      | Added the following assignment after removing the ledger         |
      | hierarchy calls from the GL_FLATTEN_ACCESS_SETS package          |
      +------------------------------------------------------------------*/
      cont_processing := TRUE;

      -- Call routine to fix implicit access sets
      ret_val := GL_FLATTEN_ACCESS_SETS.Fix_Implicit_Sets
			(Any_Ledger_Hier_Changes => cont_processing);

      IF (NOT ret_val) THEN
        RAISE GLSTFL_fatal_err;
      END IF;

      -- Call routine to fix ledger/segment value assignments
      ret_val := GL_FLATTEN_LEDGER_SEG_VALS.Fix_By_Coa;

      IF (NOT ret_val) THEN
   	RAISE GLSTFL_fatal_err;
      END IF;

    END IF;

    -- Call Clean_Up
    IF (NOT Clean_Up) THEN
      RAISE GLSTFL_fatal_err;
    END IF;

    -- Perform full refresh on materialized view GL_ACCESS_SET_LEDGERS
    IF (GLSTFL_OP_MODE NOT IN ('SH', 'FF', 'LV')) THEN
      GL_MESSAGE.Func_Ent(func_name => 'GL_FLATTEN_SETUP_DATA.MV_Refresh');

      rval := fnd_installation.get_app_info('SQLGL', dummy1, dummy2, schema);

      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                              token_num => 3 ,
                              t1        =>'ROUTINE',
                              v1        =>
                                  'GL_FLATTEN_SETUP_DATA.MV_Refresh',
                              t2        =>'VARIABLE',
                              v2        =>'schema',
                              t3        =>'VALUE',
                              v3        => schema);

      DBMS_MVIEW.Refresh('GL_ACCESS_SET_LEDGERS');

      GL_MESSAGE.Func_Succ(func_name => 'GL_FLATTEN_SETUP_DATA.MV_Refresh');

    END IF;

    -- Release all locks
    IF (GLSTFL_OP_MODE IN ('SH', 'FF')) THEN

      -- Release exclusive lock on the value set ID
      ret_val := GL_FLATTEN_SETUP_DATA.Release_Lock
			     (X_Param_Type	=> 'V',
		   	      X_Param_Id	=> GLSTFL_VS_ID);

      IF (NOT ret_val) THEN
	RAISE GLSTFL_fatal_err;
      END IF;

    ELSIF (GLSTFL_OP_MODE IN ('LV', 'LH', 'VH', 'LS', 'AS', 'VS')) THEN

      -- Release exclusive lock on the chart of accounts ID
      ret_val := GL_FLATTEN_SETUP_DATA.Release_Lock
			     (X_Param_Type	=> 'C',
		   	      X_Param_Id	=> GLSTFL_COA_ID);

      IF (NOT ret_val) THEN
	RAISE GLSTFL_fatal_err;
      END IF;

      -- Also release the shared lock on both balancing and management
      -- segments
      ret_val := GL_FLATTEN_SETUP_DATA.Release_Lock
			     (X_Param_Type	=> 'V',
		   	      X_Param_Id	=> GLSTFL_BAL_VS_ID);

      IF (NOT ret_val) THEN
	RAISE GLSTFL_fatal_err;
      END IF;

      -- Relese the second shared lock iff bal_vs_id <> mgt_vs_id
     -- IF (GLSTFL_BAL_VS_ID <> GLSTFL_MGT_VS_ID) THEN

      /* To support optional management segment value set */
      IF (GLSTFL_MGT_VS_ID) IS NOT NULL THEN
       IF (GLSTFL_BAL_VS_ID <> GLSTFL_MGT_VS_ID) THEN
        ret_val := GL_FLATTEN_SETUP_DATA.Release_Lock
			     (X_Param_Type	=> 'V',
		   	      X_Param_Id	=> GLSTFL_MGT_VS_ID);

      	IF (NOT ret_val) THEN
	  RAISE GLSTFL_fatal_err;
      	END IF;
      END IF;
     END IF;
    END IF;

    GL_MESSAGE.Func_Succ(func_name => 'GL_FLATTEN_SETUP_DATA.Main');

    ret_val := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'COMPLETE', message => NULL);

  -- Exception handling
  EXCEPTION
    WHEN GLSTFL_fatal_err THEN
      -- Release locks
      IF (GLSTFL_OP_MODE IN ('SH', 'FF')) THEN
        -- Release exclusive lock on the value set ID
        ret_val := GL_FLATTEN_SETUP_DATA.Release_Lock
			 (X_Param_Type	=> 'V',
	   		  X_Param_Id	=> GLSTFL_VS_ID);
      ELSIF (GLSTFL_OP_MODE IN ('LV', 'LH', 'VH', 'LS', 'AS', 'VS')) THEN
      	-- Release exclusive lock on the chart of accounts ID
      	ret_val := GL_FLATTEN_SETUP_DATA.Release_Lock
			 (X_Param_Type	=> 'C',
	   	          X_Param_Id	=> GLSTFL_COA_ID);

        -- Also release the shared lock on both balancing and management
        -- segments
        ret_val := GL_FLATTEN_SETUP_DATA.Release_Lock
			     (X_Param_Type	=> 'V',
		   	      X_Param_Id	=> GLSTFL_BAL_VS_ID);

        -- Relese the second shared lock iff bal_vs_id <> mgt_vs_id
        --IF (GLSTFL_BAL_VS_ID <> GLSTFL_MGT_VS_ID) THEN
        /* To support optional management segment value set */
        IF (GLSTFL_MGT_VS_ID) IS NOT NULL THEN
          ret_val := GL_FLATTEN_SETUP_DATA.Release_Lock
			     (X_Param_Type	=> 'V',
		   	      X_Param_Id	=> GLSTFL_MGT_VS_ID);
        END IF;
      END IF;

      GL_MESSAGE.Write_Log
	 (msg_name  => 'FLAT0002',
          token_num => 1,
          t1        => 'ROUTINE_NAME',
          v1        => 'GL_FLATTEN_SETUP_DATA.Main()');

      GL_MESSAGE.Func_Fail(func_name	=> 'GL_FLATTEN_SETUP_DATA.Main');

      ret_val := FND_CONCURRENT.Set_Completion_Status
			(status  => 'ERROR', message => NULL);

    WHEN OTHERS THEN
      -- Release locks
      IF (GLSTFL_OP_MODE IN ('SH', 'FF')) THEN
        -- Release exclusive lock on the value set ID
	ret_val := GL_FLATTEN_SETUP_DATA.Release_Lock
			 (X_Param_Type	=> 'V',
	    		  X_Param_Id	=> GLSTFL_VS_ID);
      ELSIF (GLSTFL_OP_MODE IN ('LV', 'LH', 'VH', 'LS', 'AS', 'VS')) THEN
      	-- Release exclusive lock on the chart of accounts ID
      	ret_val := GL_FLATTEN_SETUP_DATA.Release_Lock
			 (X_Param_Type	=> 'C',
	   	          X_Param_Id	=> GLSTFL_COA_ID);

        -- Also release the shared lock on both balancing and management
        -- segments
        ret_val := GL_FLATTEN_SETUP_DATA.Release_Lock
			     (X_Param_Type	=> 'V',
		   	      X_Param_Id	=> GLSTFL_BAL_VS_ID);

        -- Relese the second shared lock iff bal_vs_id <> mgt_vs_id
        --IF (GLSTFL_BAL_VS_ID <> GLSTFL_MGT_VS_ID) THEN
       /* To support optional management segment value set */
       IF (GLSTFL_MGT_VS_ID) IS NOT NULL THEN
          ret_val := GL_FLATTEN_SETUP_DATA.Release_Lock
			     (X_Param_Type	=> 'V',
		   	      X_Param_Id	=> GLSTFL_MGT_VS_ID);
	END IF;
      END IF;

      GL_MESSAGE.Write_Log(msg_name  => 'SHRD0203',
                            token_num => 2,
                            t1        => 'FUNCTION',
                            v1        => 'GL_FLATTEN_SETUP_DATA.Main()',
                            t2        => 'SQLERRMC',
                            v2        => SQLERRM);

      GL_MESSAGE.Func_Fail(func_name	=> 'GL_FLATTEN_SETUP_DATA.Main');

      ret_val := FND_CONCURRENT.Set_Completion_Status
			(status  => 'ERROR', message => NULL);

  END Main;

-- ********************************************************************

  PROCEDURE Main(errbuf		OUT NOCOPY	VARCHAR2,
		 retcode	OUT NOCOPY	VARCHAR2,
		 X_Mode			VARCHAR2,
	  	 X_Mode_Parameter	VARCHAR2,
		 X_Debug		VARCHAR2 DEFAULT NULL) IS
  BEGIN
    GL_FLATTEN_SETUP_DATA.Main(X_Mode		=> X_Mode,
                               X_Mode_Parameter	=> X_Mode_Parameter,
			       X_Debug		=> X_Debug);
  EXCEPTION
    WHEN OTHERS THEN
      errbuf := SQLERRM ;
      retcode := '2';
  --    l_message := errbuf;
  --    FND_FILE.put_line(FND_FILE.LOG,l_message);
      app_exception.raise_exception;
  END Main;

-- ******************************************************************

  FUNCTION  Clean_Up	RETURN BOOLEAN IS
    ret_val		BOOLEAN;
    GLSTFL_fatal_err    EXCEPTION;
  BEGIN

    GL_MESSAGE.Func_Ent(func_name => 'GL_FLATTEN_SETUP_DATA.Clean_Up');

    -- Start cleaning up according to the mode of operation.
    --
    -- Here is the list of routines called by each mode:
    -- 1) Modes SH, FF:
    --      GL_FLATTEN_SEG_VAL_HIERARCHIES.Clean_Up
    --      GL_FLATTEN_LEDGER_SEG_VALS.Clean_Up_By_Value_Set
    -- 2) Mode LV:
    --	    GL_FLATTEN_LEDGER_SEG_VALS.Clean_Up_By_Coa
    -- 3) Mode LH:
    --      GL_FLATTEN_LEDGER_HIERARCHIES.Clean_Up
    --	    GL_FLATTEN_LEDGER_SETS.Clean_Up_Implicit_Sets
    --	    GL_FLATTEN_ACCESS_SETS.Clean_Up_By_Coa
    -- 4) Mode LS:
    --	    GL_FLATTEN_LEDGER_SETS.Clean_Up_Explicit_Sets
    --	    GL_FLATTEN_ACCESS_SETS.Clean_Up_By_Coa
    -- 5) Mode VS:
    --	    GL_FLATTEN_LEDGER_SEG_VALS.Clean_Up_By_Coa
    --	    GL_FLATTEN_LEDGER_SETS.Clean_Up_Explicit_Sets
    --	    GL_FLATTEN_ACCESS_SETS.Clean_Up_By_Coa
    -- 6) Mode AS:
    --	    GL_FLATTEN_ACCESS_SETS.Clean_Up_By_Coa
    -- 7) Mode VH:
    --	    GL_FLATTEN_LEDGER_SEG_VALS.Clean_Up_By_Coa
    --      GL_FLATTEN_LEDGER_HIERARCHIES.Clean_Up
    --	    GL_FLATTEN_LEDGER_SETS.Clean_Up_Implicit_Sets
    --	    GL_FLATTEN_ACCESS_SETS.Clean_Up_By_Coa

    IF (GLSTFL_OP_MODE IN ('SH', 'FF')) THEN

      -- Call routine to clean up value set and
      -- segment value hierarchies first.
      ret_val := GL_FLATTEN_SEG_VAL_HIERARCHIES.Clean_Up;

      IF (NOT ret_val) THEN
	RAISE GLSTFL_fatal_err;
      END IF;

      -- Call routine to clean up ledger/segment value assignments
      ret_val := GL_FLATTEN_LEDGER_SEG_VALS.Clean_Up_By_Value_Set;

      IF (NOT ret_val) THEN
   	RAISE GLSTFL_fatal_err;
      END IF;

    ELSIF (GLSTFL_OP_MODE = 'LV') THEN

      -- Call routine to clean up ledger/segment value assignments
      ret_val := GL_FLATTEN_LEDGER_SEG_VALS.Clean_Up_By_Coa;

      IF (NOT ret_val) THEN
   	RAISE GLSTFL_fatal_err;
      END IF;

--    ELSIF (GLSTFL_OP_MODE = 'LH') THEN

      -- Call routine to clean up ledger hierarchies first
--      ret_val := GL_FLATTEN_LEDGER_HIERARCHIES.Clean_Up;

--      IF (NOT ret_val) THEN
--        RAISE GLSTFL_fatal_err;
--      END IF;

      -- Call routine to clean up implicit ledger sets
--      ret_val := GL_FLATTEN_LEDGER_SETS.Clean_Up_Implicit_Sets;

--      IF (NOT ret_val) THEN
--        RAISE GLSTFL_fatal_err;
--      END IF;

      -- Call routine to clean up access assignments
--      ret_val := GL_FLATTEN_ACCESS_SETS.Clean_Up_By_Coa;

--      IF (NOT ret_val) THEN
--   	RAISE GLSTFL_fatal_err;
--      END IF;

    ELSIF (GLSTFL_OP_MODE = 'LS') THEN

      -- Call routine to clean up explicit ledger sets
      ret_val := GL_FLATTEN_LEDGER_SETS.Clean_Up_Explicit_Sets;

      IF (NOT ret_val) THEN
        RAISE GLSTFL_fatal_err;
      END IF;

      -- Call routine to clean up access assignments
      ret_val := GL_FLATTEN_ACCESS_SETS.Clean_Up_By_Coa;

      IF (NOT ret_val) THEN
   	RAISE GLSTFL_fatal_err;
      END IF;

    ELSIF (GLSTFL_OP_MODE = 'VS') THEN

      -- Call routine to clean up explicit ledger sets
      ret_val := GL_FLATTEN_LEDGER_SETS.Clean_Up_Explicit_Sets;

      IF (NOT ret_val) THEN
        RAISE GLSTFL_fatal_err;
      END IF;

      -- Call routine to clean up access assignments
      ret_val := GL_FLATTEN_ACCESS_SETS.Clean_Up_By_Coa;

      IF (NOT ret_val) THEN
   	RAISE GLSTFL_fatal_err;
      END IF;

      -- Call routine to clean up ledger/segment value assignments
      ret_val := GL_FLATTEN_LEDGER_SEG_VALS.Clean_Up_By_Coa;

      IF (NOT ret_val) THEN
   	RAISE GLSTFL_fatal_err;
      END IF;


    ELSIF (GLSTFL_OP_MODE = 'AS') THEN

      -- Call routine to clean up access assignments
      ret_val := GL_FLATTEN_ACCESS_SETS.Clean_Up_By_Coa;

      IF (NOT ret_val) THEN
   	RAISE GLSTFL_fatal_err;
      END IF;

    ELSIF (GLSTFL_OP_MODE = 'VH') THEN

      -- This is the combination of both modes LV and LH.
      -- So this mode will do the work of those 2 modes combined.

      -- Call routine to clean up ledger/segment value assignments
      ret_val := GL_FLATTEN_LEDGER_SEG_VALS.Clean_Up_By_Coa;

      IF (NOT ret_val) THEN
   	RAISE GLSTFL_fatal_err;
      END IF;

      -- Call routine to clean up ledger hierarchies
--      ret_val := GL_FLATTEN_LEDGER_HIERARCHIES.Clean_Up;

--      IF (NOT ret_val) THEN
--        RAISE GLSTFL_fatal_err;
--      END IF;

      -- Call routine to clean up implicit ledger sets
--      ret_val := GL_FLATTEN_LEDGER_SETS.Clean_Up_Implicit_Sets;

--      IF (NOT ret_val) THEN
--        RAISE GLSTFL_fatal_err;
--      END IF;

      -- Call routine to clean up access assignments
      ret_val := GL_FLATTEN_ACCESS_SETS.Clean_Up_By_Coa;

      IF (NOT ret_val) THEN
   	RAISE GLSTFL_fatal_err;
      END IF;

    END IF;

    -- Commit all work
    FND_CONCURRENT.Af_Commit;

    GL_MESSAGE.Func_Succ(func_name => 'GL_FLATTEN_SETUP_DATA.Clean_Up');

    RETURN TRUE;

  EXCEPTION
    WHEN GLSTFL_fatal_err THEN

      GL_MESSAGE.Write_Log(msg_name  => 'FLAT0002',
                            token_num => 1,
                            t1        => 'ROUTINE_NAME',
                            v1        => 'GL_FLATTEN_SETUP_DATA.Clean_Up()');

      -- Rollback
      FND_CONCURRENT.Af_Rollback;

      GL_MESSAGE.Func_Fail(func_name =>'GL_FLATTEN_SETUP_DATA.Clean_Up');

      RETURN FALSE;

  END Clean_Up;

-- *****************************************************************

  FUNCTION  Get_Value_Set_Info(	X_Vs_Id			NUMBER,
				Table_Name	   OUT NOCOPY	VARCHAR2,
                                Column_Name        OUT NOCOPY   VARCHAR2)
                                 			RETURN BOOLEAN IS
    tab_name	VARCHAR2(240) := NULL;
    col_name    VARCHAR2(240) := NULL;
  BEGIN

    GL_MESSAGE.Func_Ent
	(func_name => 'GL_FLATTEN_SETUP_DATA.Get_Value_Set_Info');

    -- Execute statement to determine if the value set is table validated
    BEGIN
      SELECT fvt.application_table_name,
             fvt.value_column_name
      INTO   tab_name,col_name
      FROM   fnd_flex_validation_tables fvt,
             fnd_flex_value_sets fvs
      WHERE  fvs.flex_value_set_id = X_vs_id
      AND    fvs.validation_type = 'F'
      AND    fvt.flex_value_set_id = fvs.flex_value_set_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        Table_Name := NULL;
        Column_Name:= NULL;
    END;

    IF (tab_name IS NOT NULL) THEN
      Table_Name := tab_name;
      Column_Name := col_name;
    END IF;

    GL_MESSAGE.Func_Succ
	(func_name => 'GL_FLATTEN_SETUP_DATA.Get_Value_Set_Info');

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
       GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0203',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'GL_FLATTEN_SETUP_DATA.Get_Value_Set_Info()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

       GL_MESSAGE.Func_Fail
	(func_name => 'GL_FLATTEN_SETUP_DATA.Get_Value_Set_Info');

       FND_CONCURRENT.Af_Rollback;

       RETURN FALSE;

  END Get_Value_Set_Info;

-- ******************************************************************

  FUNCTION Request_Lock(X_Param_Type		VARCHAR2,
			X_Param_Id		NUMBER,
			X_Lock_Mode		INTEGER,
			X_Keep_Looping		BOOLEAN,
			X_Max_Trys		NUMBER) RETURN BOOLEAN IS
    lkname		VARCHAR2(128)	 := NULL;
    lkhandle		VARCHAR2(128)	 := NULL;
    exp_secs		constant INTEGER := 864000;
    waittime		constant INTEGER := 120;
    sleep_time		constant NUMBER	 := 300;
    lkresult		INTEGER;
    GLSTFL_fatal_err	EXCEPTION;
    got_lock		BOOLEAN		 := FALSE;
    trial_num		NUMBER		 := 0;
  BEGIN

    GL_MESSAGE.Func_Ent(func_name => 'GL_FLATTEN_SETUP_DATA.Request_Lock');

    -- generate name for the user defined lock
    IF (X_Param_Type = 'C') THEN
      lkname := 'GLSTFL_COA_' || TO_CHAR(X_Param_Id);
    ELSIF (X_Param_Type = 'V') THEN
      lkname := 'GLSTFL_VS_' || TO_CHAR(X_Param_Id);
    ELSE
      -- Invalid parameter type, print message and error out

      -- PARAM_VALUE is not a valid value for parameter PARAM_NAME
      GL_MESSAGE.Write_Log(msg_name  => 'FLAT0006',
			    token_num => 2,
			    t1	      => 'PARAM_NAME',
			    v1	      => 'X_Param_Type',
			    t2 	      => 'PARAM_VALUE',
   			    v2	      => X_Param_Type);

      RAISE GLSTFL_fatal_err;
    END IF;

    -- get Oracle-assigned lock handle
    DBMS_LOCK.Allocate_Unique(lockname		=> lkname,
     		              lockhandle	=> lkhandle,
			      expiration_secs	=> exp_secs);

    -- request the lock in a loop.  If timeout and X_Keep_Looping is TRUE,
    -- put process to sleep for 2 minutes then try again.
    -- If process cannot obtain lock after X_Max_Trys, set X_Time_Out to
    -- TRUE and exit from the loop.
    WHILE (NOT got_lock AND X_Keep_Looping AND
	   (trial_num <= X_Max_Trys))
    LOOP

      -- Try to obtain the lock with max. wait time of 2 minutes
      lkresult := DBMS_LOCK.Request(lockhandle	=> lkhandle,
       			      	    lockmode	=> X_Lock_Mode,
				    timeout	=> waittime);

      IF ((lkresult = 0) OR (lkresult = 4)) THEN
        -- locking successful
	got_lock := TRUE;
      ELSIF (lkresult = 1) THEN
	-- Timeout, put process to sleep for 5 minutes, then try
        -- again.  Increment trial_num to track number of attempts
        trial_num := trial_num + 1;

	-- Cannot obtain user named lock LOCK_NAME, putting the proccess
	-- to sleep for SLEEP_TIME minutes before trying again.
	GL_MESSAGE.Write_Log(msg_name	=> 'FLAT0007',
			      token_num => 2,
			      t1	=> 'LOCK_NAME',
			      v1	=> lkname,
			      t2 	=> 'SLEEP_TIME',
			      v2	=> TO_CHAR(sleep_time/60));

	DBMS_LOCK.Sleep(seconds	=> sleep_time);

      ELSE
	-- Either encounter deadlock, parameter error or illegal lock handle.
	-- Print out appropriate message and error out

	-- Fatal error occurred when obtaining user named lock LOCK_NAME
	GL_MESSAGE.Write_Log(msg_name	=> 'FLAT0008',
			      token_num => 1,
			      t1	=> 'LOCK_NAME',
			      v1	=> lkname);
	RAISE GLSTFL_fatal_err;
      END IF;
  END LOOP;

  IF (got_lock) THEN
    GL_MESSAGE.Func_Succ(func_name => 'GL_FLATTEN_SETUP_DATA.Request_Lock');

    RETURN TRUE;
  ELSE
    -- Cannot obtain lock after maximum number of attempts.
    -- Print out appropriate message and raise exception

    -- Program failed to obtain user named lock LOCK_NAME after
    -- MAX_ATTEMPTS attempts.
    GL_MESSAGE.Write_Log(msg_name	=> 'FLAT0009',
			  token_num	=> 2,
			  t1		=> 'LOCK_NAME',
			  v1		=> lkname,
			  t2		=> 'MAX_ATTEMPTS',
			  v2		=> TO_CHAR(X_Max_Trys));
    RAISE GLSTFL_fatal_err;
  END IF;

  EXCEPTION
    WHEN GLSTFL_fatal_err THEN

      GL_MESSAGE.Write_Log
	(msg_name  => 'FLAT0002',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'GL_FLATTEN_SETUP_DATA.Request_Lock()');

      GL_MESSAGE.Func_Fail(func_name => 'GL_FLATTEN_SETUP_DATA.Request_Lock');

      FND_CONCURRENT.Af_Rollback;

      RETURN FALSE;

    WHEN OTHERS THEN
       GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0203',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'GL_FLATTEN_SETUP_DATA.Request_Lock()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

       GL_MESSAGE.Func_Fail
	(func_name => 'GL_FLATTEN_SETUP_DATA.Request_Lock');

       FND_CONCURRENT.Af_Rollback;

       RETURN FALSE;

  END Request_Lock;

-- ******************************************************************

  FUNCTION Release_Lock(X_Param_Type		VARCHAR2,
			X_Param_Id		NUMBER) RETURN BOOLEAN IS
    lkname		VARCHAR2(128)	 := NULL;
    lkhandle		VARCHAR2(128)	 := NULL;
    exp_secs		constant INTEGER := 864000;
    lkresult		INTEGER;
    GLSTFL_fatal_err	EXCEPTION;
  BEGIN

    GL_MESSAGE.Func_Ent(func_name => 'GL_FLATTEN_SETUP_DATA.Release_Lock');


    -- generate name for the user defined lock
    IF (X_Param_Type = 'C') THEN
      lkname := 'GLSTFL_COA_' || TO_CHAR(X_Param_Id);
    ELSIF (X_Param_Type = 'V') THEN
      lkname := 'GLSTFL_VS_' || TO_CHAR(X_Param_Id);
    ELSE
      -- Invalid parameter type, print message and error out
      GL_MESSAGE.Write_Log(msg_name  => 'FLAT0006',
			    token_num => 2,
			    t1	      => 'PARAM_NAME',
			    v1	      => 'X_Param_Type',
			    t2 	      => 'PARAM_VALUE',
   			    v2	      => X_Param_Type);

      RAISE GLSTFL_fatal_err;
    END IF;
    IF (GL_FLATTEN_SETUP_DATA.GLSTFL_Debug) THEN
        GL_MESSAGE.Write_Log
	  (msg_name  => 'SHRD0180',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Main()',
           t2        => 'ACTION',
           v2        => lkname);
    END IF;
    -- get Oracle-assigned lock handle
    DBMS_LOCK.Allocate_Unique(lockname		=> lkname,
  		              lockhandle	=> lkhandle,
			      expiration_secs	=> exp_secs);

    -- release the user named lock
    lkresult := DBMS_LOCK.Release(lockhandle	=> lkhandle);

    IF (lkresult = 0) THEN
      GL_MESSAGE.Func_Succ(func_name => 'GL_FLATTEN_SETUP_DATA.Release_Lock');

      RETURN TRUE;
    ELSE
      -- Errors encountered when releasing the lock
      GL_MESSAGE.Write_Log(msg_name	=> 'FLAT0010',
			    token_num	=> 0);
      RAISE GLSTFL_fatal_err;
    END IF;

  EXCEPTION
    WHEN GLSTFL_fatal_err THEN

      GL_MESSAGE.Write_Log
	(msg_name  => 'FLAT0002',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'GL_FLATTEN_SETUP_DATA.Release_Lock()');

      GL_MESSAGE.Func_Fail
	(func_name =>'GL_FLATTEN_SETUP_DATA.Release_Lock');

      FND_CONCURRENT.Af_Rollback;

      RETURN FALSE;

    WHEN OTHERS THEN
       GL_MESSAGE.Write_Log
	(msg_name  => 'SHRD0203',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'GL_FLATTEN_SETUP_DATA.Release_Lock()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

       GL_MESSAGE.Func_Fail
	(func_name => 'GL_FLATTEN_SETUP_DATA.Release_Lock');

       FND_CONCURRENT.Af_Rollback;

       RETURN FALSE;

  END Release_Lock;

-- ******************************************************************

-- ******************************************************************
-- Function
--   GL_Flatten_Rule
-- Purpose
--   This Function will be used as a run function for the new
--   business event oracle.apps.fnd.flex.vst.hierarchy.compiled
-- History
--   10-Oct-2004       Srini pala		Created
-- Arguments
--   p_subscription_guid 	raw unique subscription id
--
--    p_event		        wf_event_t workflow business event
--
-- Example
--   ret_status := GL_FLATTEN_SETUP_DATA.GL_Flatten_Rule( );
--

  FUNCTION  GL_FLATTEN_RULE(
                         p_subscription_guid in     raw,
                         p_event             in out nocopy wf_event_t)
            RETURN VARCHAR2 IS

         i        NUMBER;
         parmlist wf_parameter_list_t;
         req_id   NUMBER;
         result   BOOLEAN;
         vs_id    NUMBER;

   BEGIN

        parmlist := p_event.getParameterList();

        IF (parmlist is not null) THEN

           i := parmlist.FIRST;

           WHILE (i <= parmlist.LAST) LOOP

            if (parmlist(i).getName() = 'FLEX_VALUE_SET_ID') THEN
              vs_id := parmlist(i).getValue();
              result := fnd_request.set_options('NO', 'NO', NULL, NULL,NULL);

              req_id := FND_REQUEST.Submit_Request(
                'SQLGL', 'GLSTFL', '', '', FALSE,
                'SH',TO_CHAR(vs_id), 'N',chr(0),
                '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '');

              IF (req_id = 0) THEN

                WF_CORE.CONTEXT('GL_FLATTEN_SETUP_DAT','GL_Flatten_Rule',
                               p_event.getEventName( ), p_subscription_guid);
                WF_EVENT.setErrorInfo(p_event, FND_MESSAGE.get);
                return 'WARNING';

              END IF;

           END If;

           i := parmlist.NEXT(i);

            END LOOP;
        END IF;



        RETURN 'SUCCESS';

    EXCEPTION
       WHEN OTHERS THEN
          WF_CORE.CONTEXT('GL_FLATTEN_SETUP_DAT','GL_Flatten_Rule',
                               p_event.getEventName( ), p_subscription_guid);
          WF_EVENT.setErrorInfo(p_event, 'ERROR');

          return 'ERROR';
   END GL_Flatten_Rule;


-- ******************************************************************


END GL_FLATTEN_SETUP_DATA;


/
