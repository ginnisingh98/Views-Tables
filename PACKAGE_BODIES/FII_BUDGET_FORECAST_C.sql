--------------------------------------------------------
--  DDL for Package Body FII_BUDGET_FORECAST_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_BUDGET_FORECAST_C" AS
/* $Header: FIIBUUPB.pls 120.59 2007/09/11 09:10:41 wywong ship $ */

        g_retcode              VARCHAR2(20)    := NULL;
        g_phase                VARCHAR2(120);

/************************************************************************
     			 PRIVATE FUNCIONTS
************************************************************************/

-------------------------------------------------------------------------------

  -- Procedure
  --   	Purge_All
  -- Purpose
  --   	This routine will purge all records for the given plan type
  --    from FII_BUDGET_BASE.  Then it will reset the truncation
  --    flag and profile option setting in FII_CHANGE_LOG.
  -- History
  --   	06-20-02	 S Kung	        Created
  -- Arguments
  --    None
  -- Example
  --    result := FII_BUDGET_FORECAST_C.Purge_All;
  -- Notes
  --
  FUNCTION Purge_All RETURN BOOLEAN IS
    FIIBUUP_fatal_err		EXCEPTION;

  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.Purge_All');
    END IF;

    -- Purge all records from FII_BUDGET_BASE for the specified plan type
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Purge_All()',
           t2        => 'ACTION',
           v2        => 'Purging all records from FII_BUDGET_BASE...');
    END IF;

    g_phase := 'delete from FII_BUDGET_BASE';
    DELETE from FII_BUDGET_BASE
    WHERE plan_type_code = FIIBUUP_PURGE_PLAN_TYPE;

    IF (FIIBUUP_DEBUG) THEN
    FII_MESSAGE.Write_Log
	(msg_name 	=> 'FII_DEL_REC',
	 token_num 	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_BASE');
    END IF;

    -- Reset truncation indicator back to normal and
    -- update FII_CHANGE_LOG to reflect latest profile setting
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Purge_All()',
           t2        => 'ACTION',
           v2        => 'Resetting FII_CHANGE_LOG...');
    END IF;

    g_phase := 'Update FII_CHANGE_LOG';
    IF (FIIBUUP_PURGE_PLAN_TYPE = 'B') THEN
      UPDATE FII_CHANGE_LOG
      SET item_value = 'N',
		  last_update_date = SYSDATE,
		  last_updated_by = FIIBUUP_USER_ID,
		  last_update_login = FIIBUUP_LOGIN_ID
      WHERE log_item = 'TRUNCATE_BUDGET';

      IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	(msg_name 	=> 'FII_UPD_REC',
	 token_num 	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_CHANGE_LOG');
      END IF;

      UPDATE FII_CHANGE_LOG
      SET item_value = FIIBUUP_BUDGET_TIME_UNIT,
		  last_update_date = SYSDATE,
		  last_updated_by = FIIBUUP_USER_ID,
		  last_update_login = FIIBUUP_LOGIN_ID
      WHERE log_item = 'BUDGET_TIME_UNIT';

      IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	(msg_name 	=> 'FII_UPD_REC',
	 token_num 	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_CHANGE_LOG');
      END IF;

    ELSIF (FIIBUUP_PURGE_PLAN_TYPE = 'F') THEN
      UPDATE FII_CHANGE_LOG
      SET item_value = 'N',
		  last_update_date = SYSDATE,
		  last_updated_by = FIIBUUP_USER_ID,
		  last_update_login = FIIBUUP_LOGIN_ID
      WHERE log_item = 'TRUNCATE_FORECAST';

      IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	(msg_name 	=> 'FII_UPD_REC',
	 token_num 	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_CHANGE_LOG');
      END IF;

      UPDATE FII_CHANGE_LOG
      SET item_value = FIIBUUP_FORECAST_TIME_UNIT,
		  last_update_date = SYSDATE,
		  last_updated_by = FIIBUUP_USER_ID,
		  last_update_login = FIIBUUP_LOGIN_ID
      WHERE log_item = 'FORECAST_TIME_UNIT';

      IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	(msg_name 	=> 'FII_UPD_REC',
	 token_num 	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_CHANGE_LOG');
      END IF;

    END IF;

    -- Commit everything to database before returning
    FND_CONCURRENT.Af_Commit;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.Purge_All');
    END IF;
    RETURN TRUE;

  -- Exception handling
  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN

      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.Purge_All()');


      FII_MESSAGE.Func_Fail
	(func_name =>'FII_BUDGET_FORECAST_C.Purge_All');

      fii_util.put_line ('Phase: ' || g_phase ||
                          'Error: ' || sqlerrm);

      RETURN FALSE;

    WHEN OTHERS THEN

      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERROR',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'FII_BUDGET_FORECAST_C.Purge_All()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

      FII_MESSAGE.Func_Fail
	  (func_name	=> 'FII_BUDGET_FORECAST_C.Purge_All');

       fii_util.put_line ('Phase: ' || g_phase ||
                          'Error: ' || sqlerrm);

      RETURN FALSE;

  END Purge_All;

-------------------------------------------------------------------------------

  -- Procedure
  --   	Purge_Partial
  -- Purpose
  --   	This routine will purge all records for the given plan type
  --    in a given time period from FII_BUDGET_BASE.
  -- History
  --   	06-20-02	 S Kung	        Created
  -- Arguments
  --    None
  -- Example
  --    result := FII_BUDGET_FORECAST_C.Purge_Partial;
  -- Notes
  --
  FUNCTION Purge_Partial RETURN BOOLEAN IS
    FIIBUUP_fatal_err		EXCEPTION;
    l_time_period_valid 	BOOLEAN 	:= TRUE;
    l_purge_time_id		NUMBER(15)	:= NULL;
    l_purge_period_type_id	NUMBER(15)	:= NULL;
    l_sqlstmt			VARCHAR2(5000)  := NULL;

  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.Purge_Partial');
    END IF;

    -- Check if the specified time period is valid
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Purge_Partial()',
           t2        => 'ACTION',
           v2        => 'Check if time period is valid...');
    END IF;

    g_phase := 'Get time information';
    IF (FIIBUUP_PURGE_TIME_UNIT = 'D') THEN
      BEGIN
	SELECT report_date_julian
	INTO l_purge_time_id
	FROM FII_TIME_DAY
	WHERE report_date = FIIBUUP_PURGE_DATE;
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  l_time_period_valid := FALSE;
      END;

      l_purge_period_type_id := 1;

    ELSIF (FIIBUUP_PURGE_TIME_UNIT = 'P') THEN
      BEGIN
	SELECT ent_period_id
	INTO l_purge_time_id
	FROM FII_TIME_ENT_PERIOD
	WHERE name = FIIBUUP_PURGE_TIME_PERIOD;
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  l_time_period_valid := FALSE;
      END;

      l_purge_period_type_id := 32;

    ELSIF (FIIBUUP_PURGE_TIME_UNIT = 'Q') THEN
      BEGIN
	SELECT ent_qtr_id
	INTO l_purge_time_id
	FROM FII_TIME_ENT_QTR
	WHERE name = FIIBUUP_PURGE_TIME_PERIOD;
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  l_time_period_valid := FALSE;
      END;

      l_purge_period_type_id := 64;

    ELSIF (FIIBUUP_PURGE_TIME_UNIT = 'Y') THEN
      BEGIN
	SELECT ent_year_id
	INTO l_purge_time_id
	FROM FII_TIME_ENT_YEAR
	WHERE name = FIIBUUP_PURGE_TIME_PERIOD;
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  l_time_period_valid := FALSE;
      END;

      l_purge_period_type_id := 128;

    END IF;

    g_phase := 'Build SQL statement';
    -- First, subtract the purge amount from their respective rollup records
    l_sqlstmt := 'UPDATE FII_BUDGET_BASE b ' ||
 	       	'SET (b.prim_amount_g, b.sec_amount_g, ' ||
                'b.prim_amount_total, b.sec_amount_total, '||
		'b.last_update_date, b.last_updated_by, ' ||
		'b.last_update_login) = ' ||
	       	'(SELECT (b.prim_amount_g-SUM(b2.prim_amount_g)), ' ||
	       	'(b.sec_amount_g-SUM(b2.sec_amount_g)), '||
                '(b.prim_amount_total-SUM(b2.prim_amount_total)), '||
                '(b.sec_amount_total-SUM(b2.sec_amount_total)), '||
                'SYSDATE, ' ||
		':user_id, :login_id ' ||
	       	'FROM FII_BUDGET_BASE b2 ' ||
		'WHERE b2.plan_type_code = b.plan_type_code ' ||
    	        'AND b2.ledger_id = b.ledger_id '||
    	        'AND b2.company_id = b.company_id '||
    	        'AND b2.cost_center_id = b.cost_center_id '||
		'AND b2.fin_category_id = b.fin_category_id ' ||
		'AND NVL(b2.category_id, -1) = NVL(b.category_id, -1) ' ||
    	        'AND b2.user_dim1_id = b.user_dim1_id '||
		'AND b2.time_id = :l_purge_time_id ' ||
		'AND b2.period_type_id = :l_purge_period_type_id '||
                'AND b2.plan_type_code = :plan_type_code '||
                'AND NVL(b2.version_date, :global_start_date) = NVL(b.version_date, :global_start_date)) ' ||
		'WHERE b.time_id IN ' ;

    IF (FIIBUUP_PURGE_TIME_UNIT = 'D') THEN

      -- Bug fix 2653837
      --   Added new conditions to account for WEEK

      l_sqlstmt := l_sqlstmt ||
		 '(SELECT DECODE(glrm.multiplier, 1, d.week_id, ' ||
		 '2, d.ent_period_id, 3, d.ent_qtr_id, 4, d.ent_year_id) ' ||
		 'FROM GL_ROW_MULTIPLIERS glrm, FII_TIME_DAY d ' ||
		 'WHERE glrm.multiplier BETWEEN 1 AND 4 ' ||
		 'AND d.report_date_julian = :l_purge_time_id) ';

    ELSIF (FIIBUUP_PURGE_TIME_UNIT = 'P') THEN
      l_sqlstmt := l_sqlstmt ||
	        '(ROUND(:l_purge_time_id/100), ROUND(:l_purge_time_id/1000)) ';
    ELSIF (FIIBUUP_PURGE_TIME_UNIT = 'Q') THEN
      l_sqlstmt := l_sqlstmt ||
		 '(ROUND(:l_purge_time_id/10)) ';
    END IF;  -- No need to perform subtraction if purging yearly data

    l_sqlstmt := l_sqlstmt ||
		'AND (b.plan_type_code, ' ||
                'b.ledger_id, '||
                'b.company_id, '||
                'b.cost_center_id, '||
		'b.fin_category_id, ' ||
		'NVL(b.category_id, -1), '||
                'b.user_dim1_id, '||
                'NVL(b.version_date, :global_start_date)) IN ' ||
		'(SELECT b3.plan_type_code, ' ||
                'b3.ledger_id, '||
                'b3.company_id, '||
                'b3.cost_center_id, '||
		'b3.fin_category_id, ' ||
		'NVL(b3.category_id, -1), '||
                'b3.user_dim1_id, ' ||
                'NVL(b3.version_date, :global_start_date) ' ||
		'FROM FII_BUDGET_BASE b3 ' ||
		'WHERE b3.plan_type_code = :plan_type_code ' ||
		'AND b3.time_id = :l_purge_time_id ' ||
		'AND b3.period_type_id = :l_purge_period_type_id) ';

    IF (FIIBUUP_DEBUG) THEN

--      FND_FILE.put_line(FND_FILE.LOG, l_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Purge_Partial()',
         t2        	=> 'VARIABLE',
         v2        	=> 'l_sqlstmt',
         t3        	=> 'VALUE',
         v3        	=> l_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Purge_Partial()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_sqlstmt)));

      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Purge_Partial()',
           t2        => 'ACTION',
           v2        => 'Subtracting purged amounts from rollup...');
    END IF;

    g_phase := 'Execute the built sql statement';
    IF (FIIBUUP_PURGE_TIME_UNIT IN ('D', 'Q')) THEN
      EXECUTE IMMEDIATE l_sqlstmt
	USING FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID, l_purge_time_id,
	      l_purge_period_type_id, FIIBUUP_PURGE_PLAN_TYPE,
              FIIBUUP_GLOBAL_START_DATE, FIIBUUP_GLOBAL_START_DATE,
              l_purge_time_id,
              FIIBUUP_GLOBAL_START_DATE, FIIBUUP_GLOBAL_START_DATE,
              FIIBUUP_PURGE_PLAN_TYPE,
	      l_purge_time_id, l_purge_period_type_id;
    ELSIF (FIIBUUP_PURGE_TIME_UNIT = 'P') THEN
      EXECUTE IMMEDIATE l_sqlstmt
	USING FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID, l_purge_time_id,
	      l_purge_period_type_id, FIIBUUP_PURGE_PLAN_TYPE,
              FIIBUUP_GLOBAL_START_DATE, FIIBUUP_GLOBAL_START_DATE,
              l_purge_time_id, l_purge_time_id,
              FIIBUUP_GLOBAL_START_DATE, FIIBUUP_GLOBAL_START_DATE,
	      FIIBUUP_PURGE_PLAN_TYPE, l_purge_time_id, l_purge_period_type_id;
    END IF;

    IF (FIIBUUP_DEBUG) THEN
    FII_MESSAGE.Write_Log
	(msg_name 	=> 'FII_UPD_REC',
	 token_num 	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_BASE');
    END IF;

    -- Next, purge records
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Purge_Partial()',
           t2        => 'ACTION',
           v2        => 'Purging records from FII_BUDGET_BASE...');
    END IF;

    g_phase := 'Delete from FII_BUDGET_BASE';
    DELETE from FII_BUDGET_BASE
    WHERE plan_type_code = FIIBUUP_PURGE_PLAN_TYPE
    AND (	(time_id = l_purge_time_id
    		 AND period_type_id = l_purge_period_type_id)
	  OR 	(prim_amount_g = 0));

    IF (FIIBUUP_DEBUG) THEN
    FII_MESSAGE.Write_Log
	(msg_name	=> 'FII_DEL_REC',
	 token_num	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_BASE');
    END IF;

    -- Commit all work
    FND_CONCURRENT.Af_Commit;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.Purge_Partial');
    END IF;
    RETURN TRUE;

  -- Exception handling
  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN

      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.Purge_Partial()');

      FII_MESSAGE.Func_Fail
	(func_name =>'FII_BUDGET_FORECAST_C.Purge_Partial');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);

      RETURN FALSE;

    WHEN OTHERS THEN

      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERROR',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'FII_BUDGET_FORECAST_C.Purge_Partial()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

      FII_MESSAGE.Func_Fail
	  (func_name	=> 'FII_BUDGET_FORECAST_C.Purge_Partial');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);

      RETURN FALSE;

  END Purge_Partial;

-------------------------------------------------------------------------------

  -- Procedure
  --   	Purge_Eff_Date
  -- Purpose
  --    This routine will purge budget or forecast records with version_date
  --    equal to or greater then the given version date.
  -- Arguments
  --    None
  -- Example
  --    result := FII_BUDGET_FORECAST_C.Purge_Eff_Date(version_date);
  -- Notes
  --
  FUNCTION Purge_Eff_Date (version_date DATE) RETURN BOOLEAN IS
    FIIBUUP_fatal_err		EXCEPTION;
    l_tmpstmt			VARCHAR2(1000);

  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.Purge_Eff_Date');
    END IF;

    -- Purge all records from FII_BUDGET_BASE for the specified effective
    -- dates.  All records with the same dimensions on and after the effective
    -- date will be purged.
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Purge_Eff_Date()',
           t2        => 'ACTION',
           v2        => 'Purging records from FII_BUDGET_BASE for ' ||
                         version_date ||'...');
    END IF;

    g_phase := 'delete from FII_BUDGET_BASE';
    l_tmpstmt :=
      ' DELETE from FII_BUDGET_BASE b'||
      ' WHERE  b.plan_type_code = :plan_type '||
      ' AND   (b.ledger_id, b.company_id, b.cost_center_id, '||
              'b.fin_category_id, b.category_id, '||
            '  b.user_dim1_id) IN '||
            ' (SELECT b2.ledger_id, b2.company_id, b2.cost_center_id, '||
                    ' b2.fin_category_id, b2.category_id, '||
                ' b2.user_dim1_id '||
             ' FROM  FII_BUDGET_BASE b2 '||
             ' WHERE b2.version_date >= trunc(:version_date)) '||
      ' AND    b.version_date >= trunc(:version_date) ';

    -- Print out the dynamic SQL statements if running in debug mode
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.purge_eff_date()',
         t2        	=> 'VARIABLE',
         v2        	=> 'l_tmpstmt',
         t3        	=> 'VALUE',
         v3        	=> l_tmpstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.purge_eff_date()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_tmpstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_tmpstmt)));
    END IF;

    EXECUTE IMMEDIATE l_tmpstmt
    USING FIIBUUP_PURGE_PLAN_TYPE, version_date, version_date;

    IF (FIIBUUP_DEBUG) THEN
    FII_MESSAGE.Write_Log
	(msg_name 	=> 'FII_DEL_REC',
	 token_num 	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_BASE');
    END IF;

    -- Reset truncation indicator back to normal and
    -- update FII_CHANGE_LOG to reflect latest profile setting
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Purge_Eff_Date()',
           t2        => 'ACTION',
           v2        => 'Resetting FII_CHANGE_LOG...');
    END IF;

    g_phase := 'Update FII_CHANGE_LOG';
    IF (FIIBUUP_PURGE_PLAN_TYPE = 'B') THEN
      UPDATE FII_CHANGE_LOG
      SET item_value = 'N',
		  last_update_date = SYSDATE,
		  last_updated_by = FIIBUUP_USER_ID,
		  last_update_login = FIIBUUP_LOGIN_ID
      WHERE log_item = 'TRUNCATE_BUDGET';

      IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	(msg_name 	=> 'FII_UPD_REC',
	 token_num 	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_CHANGE_LOG');
      END IF;

      UPDATE FII_CHANGE_LOG
      SET item_value = FIIBUUP_BUDGET_TIME_UNIT,
		  last_update_date = SYSDATE,
		  last_updated_by = FIIBUUP_USER_ID,
		  last_update_login = FIIBUUP_LOGIN_ID
      WHERE log_item = 'BUDGET_TIME_UNIT';

      IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	(msg_name 	=> 'FII_UPD_REC',
	 token_num 	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_CHANGE_LOG');
      END IF;

    ELSIF (FIIBUUP_PURGE_PLAN_TYPE = 'F') THEN
      UPDATE FII_CHANGE_LOG
      SET item_value = 'N',
		  last_update_date = SYSDATE,
		  last_updated_by = FIIBUUP_USER_ID,
		  last_update_login = FIIBUUP_LOGIN_ID
      WHERE log_item = 'TRUNCATE_FORECAST';

      IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	(msg_name 	=> 'FII_UPD_REC',
	 token_num 	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_CHANGE_LOG');
      END IF;

      UPDATE FII_CHANGE_LOG
      SET item_value = FIIBUUP_FORECAST_TIME_UNIT,
		  last_update_date = SYSDATE,
		  last_updated_by = FIIBUUP_USER_ID,
		  last_update_login = FIIBUUP_LOGIN_ID
      WHERE log_item = 'FORECAST_TIME_UNIT';

      IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	(msg_name 	=> 'FII_UPD_REC',
	 token_num 	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_CHANGE_LOG');
      END IF;

    END IF;

    -- Commit everything to database before returning
    FND_CONCURRENT.Af_Commit;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.Purge_Eff_Date');
    END IF;
    RETURN TRUE;

  -- Exception handling
  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN

      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.Purge_Eff_Date()');


      FII_MESSAGE.Func_Fail
	(func_name =>'FII_BUDGET_FORECAST_C.Purge_Eff_Date');

      fii_util.put_line ('Phase: ' || g_phase ||
                          'Error: ' || sqlerrm);

      RETURN FALSE;

    WHEN OTHERS THEN

      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERROR',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'FII_BUDGET_FORECAST_C.Purge_Eff_Date()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

      FII_MESSAGE.Func_Fail
	  (func_name	=> 'FII_BUDGET_FORECAST_C.Purge_Eff_Date');

       fii_util.put_line ('Phase: ' || g_phase ||
                          'Error: ' || sqlerrm);

      RETURN FALSE;

  END Purge_Eff_Date;


-------------------------------------------------------------------------------
  --
  -- Procedure
  --   Psi_Insert_Stg()
  -- Purpose
  --   This routine is used to extract budget data from gl_je_headers/lines
  --   and insert them into fii_budget_stg.
  -- Arguments
  --	None
  -- Example
  --   	result := FII_BUDGET_FORECAST_C.Psi_Insert_Stg
  -- Notes
  --   	Returns a boolean indicating if execution completes successfully
  --
  FUNCTION Psi_Insert_Stg RETURN BOOLEAN IS
    FIIBUUP_fatal_err	EXCEPTION;
    l_sqlstmt		VARCHAR2(10000);
    l_udd1_enabled_flag VARCHAR2(1);

  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.Psi_Insert_Stg');
    END IF;

    -- PSI Budget Extraction will always extract budget data from scratch
    g_phase := 'Truncate the staging table FII_BUDGET_BASE';
    FII_UTIL.truncate_table ('FII_BUDGET_STG', 'FII', g_retcode);

    -- Check if UDD1 is enabled or not
    SELECT DBI_ENABLED_FLAG
    INTO   l_udd1_enabled_flag
    FROM   FII_FINANCIAL_DIMENSIONS
    WHERE  dimension_short_name = 'FII_USER_DEFINED_1';

    g_phase := 'PSI Insert Staging';

    ------------------------------------------------------------------------
    -- Insert data from gl_je_lines into staging table.
    -- We'll pick up data from the set of books/companies set up in FDS
    -- where the functional currency = global primary currency.
    ------------------------------------------------------------------------
    l_sqlstmt :=
    ' INSERT /*+ append parallel(fii_budget_stg)*/ INTO FII_BUDGET_STG'||
    ' ( plan_type_code, day, year,'||
    '   ledger_id, company_id, cost_center_id, fin_category_id,category_id, '||
    '   user_dim1_id, user_dim2_id, prim_amount_g, prim_amount_total, '||
    '   baseline_amount_prim, posted_date, budget_version_id, '||
    '   code_combination_id, last_update_date, '||
    '   last_updated_by, creation_date, created_by, last_update_login ) ' ||
    ' SELECT /*+ ORDERED use_nl(line) use_hash(fcta) parallel(v1) '||
               ' parallel(fin) parallel(slga2) '||
               ' parallel(fslg2) use_hash(v1,line,fin,slga2,fslg2)'||
               ' swap_join_inputs(fin) '||
               ' swap_join_inputs(slga2) '||
               ' swap_join_inputs(fslg2) pq_distribute(fin,none,broadcast)*/'||
    ' b2.plan_type_code, to_number(to_char(line.effective_date, ''J'')),999,'||
    ' line.ledger_id, fin.company_id, fin.cost_center_id, '||
    ' fin.natural_account_id, NVL(fin.prod_category_id, -1), ';

    IF (l_udd1_enabled_flag = 'N') THEN
      l_sqlstmt := l_sqlstmt || ':user_dim1_id, :user_dim2_id, ';
    ELSE
      l_sqlstmt := l_sqlstmt || 'fin.user_dim1_id, :user_dim2_id, ';
    END IF;

    l_sqlstmt := l_sqlstmt ||
    ' decode(fcta.fin_cat_type_code, ''R'', 1, -1) * '||
    '   decode(v1.budget_version_id, '||
           ' b2.budget_version_id, '||
           ' sum(NVL(line.accounted_cr,0) - NVL(line.accounted_dr,0)), '||
           ' 0), '||
    ' decode(fcta.fin_cat_type_code, ''R'', 1, -1) * '||
    '   decode(v1.budget_version_id, '||
           ' b2.budget_version_id, '||
           ' sum(NVL(line.accounted_cr,0) - NVL(line.accounted_dr,0)), '||
           ' 0), '||
    ' decode(fcta.fin_cat_type_code, ''R'', 1, -1) * '||
    '   decode(v1.budget_version_id, '||
           ' b2.base_budget_version_id, '||
           ' sum(NVL(line.accounted_cr,0) - NVL(line.accounted_dr,0)), '||
           ' 0), '||
    ' v1.posted_date, v1.budget_version_id, '||
    ' line.code_combination_id, sysdate, :user_id, sysdate, :user_id, :login_id '||
    ' FROM ( '||
    '   SELECT /*+ no_merge ordered parallel(jeh) parallel(per) '||
                 ' parallel(fset) use_hash(jeh,per,fset) */ '||
             ' distinct jeh.ledger_id, jeh.je_header_id, '||
             ' trunc(p2.start_date) posted_date, '||
             ' jeh.budget_version_id, jeh.default_effective_date '||
     '  FROM gl_je_headers jeh, gl_periods p2,'||
           ' (SELECT /*+ parallel(p) parallel(s) use_hash(s) use_hash(p) */ '||
                   ' p.period_name, s.ledger_id, '||
                   ' b.budget_version_id, '||
                   ' b.base_budget_version_id, '||
                   ' s.period_set_name, s.accounted_period_type '||
            ' FROM   gl_periods p, gl_ledgers_public_v s, '||
                   ' fii_slg_budget_asgns b, fii_source_ledger_groups slg '||
            ' WHERE  slg.usage_code = ''DBI'' '||
            ' AND    b.source_ledger_group_id = slg.source_ledger_group_id '||
            ' AND    s.ledger_id = b.ledger_id '||
            ' AND    p.start_date <= b.to_period_end_date '||
            ' AND    p.end_date   >= b.from_period_start_date '||
            ' AND    p.period_set_name = s.period_set_name '||
            ' AND    p.period_type     = s.accounted_period_type) per, '||
            ' (SELECT /*+ full(fslg) parallel(sob) */ DISTINCT '||
                    ' slga.ledger_id, '||
                    ' DECODE(slga.je_rule_set_id, NULL, ''-1'', '||
                           ' rule.JE_SOURCE_NAME) je_source_name, '||
                    ' DECODE(slga.je_rule_set_id, NULL, ''-1'', '||
                           ' rule.JE_CATEGORY_NAME) je_category_name, '||
                    ' slba.budget_version_id, '||
                    ' slba.base_budget_version_id '||
             ' FROM  fii_slg_assignments slga, '||
                   ' gl_je_inclusion_rules    rule, '||
                   ' fii_slg_budget_asgns slba, '||
                   ' fii_source_ledger_groups fslg, '||
                   ' gl_ledgers_public_v sob '||
             ' WHERE slga.je_rule_set_id = rule.je_rule_set_id (+) '||
             ' AND slga.source_ledger_group_id = fslg.source_ledger_group_id '||
             ' AND fslg.usage_code = ''DBI'' '||
             ' AND sob.ledger_id = slga.ledger_id '||
             ' AND sob.currency_code = :prim_curr '||
             ' AND slba.ledger_id = slga.ledger_id '||
             ' AND slba.source_ledger_group_id = slga.source_ledger_group_id) fset'||
        ' WHERE jeh.ledger_id = fset.ledger_id '||
      ' AND  (jeh.je_source   = fset.je_source_name   OR fset.je_source_name   = ''-1'') '||
      ' AND  (jeh.je_category = fset.je_category_name OR fset.je_category_name = ''-1'') '||
      ' AND   jeh.budget_version_id in (fset.budget_version_id, '||
                                      ' fset.base_budget_version_id)'||
      ' AND     jeh.currency_code = :prim_curr '||
      ' AND     jeh.period_name = per.period_name '||
      ' AND     jeh.ledger_id = per.ledger_id '||
      ' AND     jeh.budget_version_id in ( per.budget_version_id, '||
                                         ' per.base_budget_version_id) '||
      ' AND     jeh.status = ''P'' '||
      ' AND     jeh.actual_flag = ''B'' '||
      ' AND     p2.period_set_name = per.period_set_name '||
      ' AND     p2.period_type     = per.accounted_period_type '||
      ' AND     p2.adjustment_period_flag = ''N'' '||
      ' AND     jeh.posted_date between p2.start_date and p2.end_date '||
      ' ) v1, '||
      ' gl_je_lines line, '||
      ' fii_gl_ccid_dimensions fin, '||
      ' fii_slg_assignments slga2,  '||
      ' fii_source_ledger_groups fslg2, '||
      ' fii_slg_budget_asgns b2, '||
      ' fii_fin_cat_type_assgns fcta '||
 ' WHERE v1.je_header_id 	      = line.je_header_id '||
 ' AND   line.code_combination_id     = fin.code_combination_id '||
 ' AND ( fin.company_id	              = slga2.bal_seg_value_id OR'||
       ' slga2.bal_seg_value_id       = -1 ) '||
 ' AND 	fin.chart_of_accounts_id      = slga2.chart_of_accounts_id '||
 ' AND  line.ledger_id = slga2.ledger_id '||
 ' AND 	slga2.source_ledger_group_id  = fslg2.source_ledger_group_id '||
 ' AND  b2.source_ledger_group_id     = fslg2.source_ledger_group_id '||
 ' AND  v1.default_effective_date between b2.from_period_start_date '||
                                ' and b2.to_period_end_date '||
 ' AND 	fslg2.usage_code              = ''DBI'' '||
 ' AND v1.ledger_id = slga2.ledger_id '||
 ' AND  fcta.fin_category_id          = fin.natural_account_id '||
 ' AND  fcta.fin_cat_type_code IN (''EXP'', ''R'') '||
 ' GROUP BY '||
      ' v1.posted_date, line.effective_date, '||
      ' fin.company_id,	fin.cost_center_id, fin.natural_account_id, '||
      ' NVL(fin.prod_category_id, -1), ';

    IF (l_udd1_enabled_flag = 'N') THEN
      l_sqlstmt := l_sqlstmt || ':user_dim1_id, :user_dim2_id, ';
    ELSE
      l_sqlstmt := l_sqlstmt || 'fin.user_dim1_id, :user_dim2_id, ';
    END IF;

    l_sqlstmt := l_sqlstmt ||
      ' v1.budget_version_id, b2.budget_version_id, '||
      ' b2.base_budget_version_id, '||
      ' fcta.fin_cat_type_code, '||
      ' line.code_combination_id, line.ledger_id, b2.plan_type_code ';

    -- Print out the dynamic SQL statements if running in debug mode
    IF (FIIBUUP_DEBUG) THEN
      fii_util.put_line('l_sqlstmt = '|| l_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Psi_Insert_Stg()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_sqlstmt)));
    END IF;

    -- Execute statement
    IF (l_udd1_enabled_flag = 'N') THEN
      EXECUTE IMMEDIATE l_sqlstmt
      USING FIIBUUP_UNASSIGNED_UDD_ID, FIIBUUP_UNASSIGNED_UDD_ID,
            FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
            FIIBUUP_PRIM_CURR_CODE, FIIBUUP_PRIM_CURR_CODE,
            FIIBUUP_UNASSIGNED_UDD_ID, FIIBUUP_UNASSIGNED_UDD_ID;
    ELSE
      EXECUTE IMMEDIATE l_sqlstmt
      USING FIIBUUP_UNASSIGNED_UDD_ID,
            FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
            FIIBUUP_PRIM_CURR_CODE, FIIBUUP_PRIM_CURR_CODE,
            FIIBUUP_UNASSIGNED_UDD_ID;
    END IF;

    IF  (FIIBUUP_DEBUG) THEN
      fii_util.put_line('Inserted '||SQL%ROWCOUNT||
                        ' rows into fii_budget_stg');
    END IF;

    -- Need to commit after inserting data into base in parallel mode
    FND_CONCURRENT.Af_Commit;

    -- Psi_Insert_Stg is completed, return with success.
    IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Psi_Insert_Stg()',
           t2        => 'ACTION',
           v2        => 'PSI Insert Stage completed successfully...');
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.Psi_Insert_Stg');
    END IF;
    RETURN TRUE;

  -- Exception handling
  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.Psi_Insert_Stg()');

      FII_MESSAGE.Func_Fail
	(func_name =>'FII_BUDGET_FORECAST_C.Psi_Insert_Stg');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

    WHEN OTHERS THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERROR',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'FII_BUDGET_FORECAST_C.Psi_Insert_Stg()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

      FII_MESSAGE.Func_Fail
	  (func_name	=> 'FII_BUDGET_FORECAST_C.Psi_Insert_Stg');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

  END Psi_Insert_Stg;

-------------------------------------------------------------------------------
  --
  -- Procedure
  --   Psi_Carry_Forward()
  -- Purpose
  --   This routine is used to extract budget data that is carried forward
  --   to the new fiscal year from gl_balances.  These carry forward amounts
  --   are updated in gl_balances directly without any journals.
  -- Arguments
  --	None
  -- Example
  --   	result := FII_BUDGET_FORECAST_C.Psi_Carry_Forward
  -- Notes
  --   	Returns a boolean indicating if execution completes successfully
  --
  FUNCTION Psi_Carry_Forward RETURN BOOLEAN IS
    FIIBUUP_fatal_err	EXCEPTION;
    l_sqlstmt		VARCHAR2(10000);
    l_udd1_enabled_flag VARCHAR2(1);

  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.Psi_Carry_Forward');
    END IF;

    -- Check if UDD1 is enabled or not
    SELECT DBI_ENABLED_FLAG
    INTO   l_udd1_enabled_flag
    FROM   FII_FINANCIAL_DIMENSIONS
    WHERE  dimension_short_name = 'FII_USER_DEFINED_1';

    g_phase := 'PSI Carry Forward';

    ------------------------------------------------------------------------
    -- Insert data from gl_balances into staging table.
    -- We'll pick up data from the set of books/companies set up in FDS
    -- where the functional currency = global primary currency and
    -- begin_balance_dr/begin_balance_cr is not zero.
    ------------------------------------------------------------------------
    l_sqlstmt :=
    ' INSERT /*+ append parallel(fii_budget_stg)*/ INTO FII_BUDGET_STG'||
    ' ( plan_type_code, day, year,'||
    '   ledger_id, company_id, cost_center_id, fin_category_id,category_id, '||
    '   user_dim1_id, user_dim2_id, prim_amount_g, prim_amount_total, '||
    '   baseline_amount_prim, posted_date, budget_version_id, '||
    '   code_combination_id, last_update_date, '||
    '   last_updated_by, creation_date, created_by, last_update_login ) ' ||
    ' SELECT /*+ parallel(sob) parallel(p) pq_distribute(p hash,hash)  '||
             ' parallel(slga) use_hash(fslg,b,fin) parallel(b) '||
             ' pq_distribute(b hash,hash) '||
             ' parallel(fin) parallel(fcta) pq_distribute(fin hash,hash) */'||
    ' slba.plan_type_code, to_number(to_char(p.start_date, ''J'')), 999,'||
    ' b.ledger_id, fin.company_id, fin.cost_center_id, '||
    ' fin.natural_account_id, NVL(fin.prod_category_id, -1), ';

    IF (l_udd1_enabled_flag = 'N') THEN
      l_sqlstmt := l_sqlstmt || ':user_dim1_id, :user_dim2_id, ';
    ELSE
      l_sqlstmt := l_sqlstmt || 'fin.user_dim1_id, :user_dim2_id, ';
    END IF;

    l_sqlstmt := l_sqlstmt ||
    ' decode(fcta.fin_cat_type_code, ''R'', 1, -1) * '||
    '   decode(b.budget_version_id, '||
           ' slba.budget_version_id, '||
           ' sum(NVL(b.begin_balance_cr,0) - NVL(b.begin_balance_dr,0)), '||
           ' 0), '||
    ' decode(fcta.fin_cat_type_code, ''R'', 1, -1) * '||
    '   decode(b.budget_version_id, '||
           ' slba.budget_version_id, '||
           ' sum(NVL(b.begin_balance_cr,0) - NVL(b.begin_balance_dr,0)), '||
           ' 0), '||
    ' decode(fcta.fin_cat_type_code, ''R'', 1, -1) * '||
    '   decode(b.budget_version_id, '||
           ' slba.base_budget_version_id, '||
           ' sum(NVL(b.begin_balance_cr,0) - NVL(b.begin_balance_dr,0)), '||
           ' 0), '||
    ' p.start_date,  b.budget_version_id, '||
    ' b.code_combination_id, sysdate, :user_id, sysdate, :user_id, :login_id '||
    ' FROM FII_SOURCE_LEDGER_GROUPS fslg, '||
         ' FII_SLG_ASSIGNMENTS      slga, '||
         ' FII_SLG_BUDGET_ASGNS     slba, '||
         ' FII_GL_CCID_DIMENSIONS   fin, '||
         ' FII_FIN_CAT_TYPE_ASSGNS  fcta, '||
         ' GL_BALANCES              b, '||
         ' GL_PERIODS               p, '||
         ' GL_LEDGERS_PUBLIC_V      sob '||
    ' WHERE fslg.usage_code = ''DBI'' '||
    ' AND   slga.source_ledger_group_id = fslg.source_ledger_group_id '||
    ' AND   slba.source_ledger_group_id = slga.source_ledger_group_id '||
    ' AND   slba.ledger_id = slga.ledger_id '||
    ' AND   sob.ledger_id = slba.ledger_id '||
    ' AND   p.period_set_name = sob.period_set_name '||
    ' AND   p.period_type     = sob.accounted_period_type '||
    ' AND   p.period_num      = 1 '||
    ' AND   p.start_date     <= slba.to_period_end_date '||
    ' AND   p.end_date       >= slba.from_period_start_date '||
    ' AND   b.actual_flag     = ''B'' '||
    ' AND   b.period_name     = p.period_name '||
    ' AND   b.ledger_id = slga.ledger_id '||
    ' AND   (b.budget_version_id = slba.budget_version_id OR '||
           ' b.budget_version_id = slba.base_budget_version_id) '||
    ' AND   b.currency_code = :prim_curr '||
    ' AND  (b.begin_balance_dr <> 0 OR b.begin_balance_cr <> 0) '||
    ' AND   b.code_combination_id = fin.code_combination_id '||
    ' AND   (fin.company_id = slga.bal_seg_value_id OR '||
           ' slga.bal_seg_value_id = -1) '||
    ' AND   fin.chart_of_accounts_id = slga.chart_of_accounts_id '||
    ' AND   fcta.fin_category_id = fin.natural_account_id '||
    ' AND   fcta.fin_cat_type_code in (''EXP'', ''R'') '||
    ' GROUP BY '||
        ' slba.plan_type_code, p.start_date, b.ledger_id, '||
      ' fin.company_id,	fin.cost_center_id, fin.natural_account_id, '||
      ' NVL(fin.prod_category_id, -1), ';

    IF (l_udd1_enabled_flag = 'N') THEN
      l_sqlstmt := l_sqlstmt || ':user_dim1_id, :user_dim2_id, ';
    ELSE
      l_sqlstmt := l_sqlstmt || 'fin.user_dim1_id, :user_dim2_id, ';
    END IF;

    l_sqlstmt := l_sqlstmt ||
      ' fcta.fin_cat_type_code, b.budget_version_id, slba.budget_version_id, '||
      ' slba.base_budget_version_id, b.code_combination_id ';

    -- Print out the dynamic SQL statements if running in debug mode
    IF (FIIBUUP_DEBUG) THEN
      fii_util.put_line('l_sqlstmt = '|| l_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Psi_Carry_Forward()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_sqlstmt)));
    END IF;

    -- Execute statement
    IF (l_udd1_enabled_flag = 'N') THEN
      EXECUTE IMMEDIATE l_sqlstmt
      USING FIIBUUP_UNASSIGNED_UDD_ID, FIIBUUP_UNASSIGNED_UDD_ID,
            FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
            FIIBUUP_PRIM_CURR_CODE,
            FIIBUUP_UNASSIGNED_UDD_ID, FIIBUUP_UNASSIGNED_UDD_ID;
    ELSE
      EXECUTE IMMEDIATE l_sqlstmt
      USING FIIBUUP_UNASSIGNED_UDD_ID,
            FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
            FIIBUUP_PRIM_CURR_CODE,
            FIIBUUP_UNASSIGNED_UDD_ID;
    END IF;

    IF  (FIIBUUP_DEBUG) THEN
      fii_util.put_line('Inserted '||SQL%ROWCOUNT||
                        ' rows into fii_budget_stg');
    END IF;

    -- Need to commit after inserting data into base in parallel mode
    FND_CONCURRENT.Af_Commit;

    -- Psi_Carry_Forward is completed, return with success.
    IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Psi_Carry_Forward()',
           t2        => 'ACTION',
           v2        => 'PSI Carry Forward completed successfully...');
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.Psi_Carry_Forward');
    END IF;
    RETURN TRUE;

  -- Exception handling
  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.Psi_Carry_Forward()');

      FII_MESSAGE.Func_Fail
	(func_name =>'FII_BUDGET_FORECAST_C.Psi_Carry_Forward');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

    WHEN OTHERS THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERROR',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'FII_BUDGET_FORECAST_C.Psi_Carry_Forward()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

      FII_MESSAGE.Func_Fail
	  (func_name	=> 'FII_BUDGET_FORECAST_C.Psi_Carry_Forward');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

  END Psi_Carry_Forward;


-------------------------------------------------------------------------------
  --
  -- Procedure
  --   Psi_Rollup()
  -- Purpose
  --   This routine will rollup budget data extracted from gl_je_headers/lines
  --   along the time dimension.
  -- Arguments
  --	None
  -- Example
  --   	result := FII_BUDGET_FORECAST_C.Psi_Rollup;
  -- Notes
  --   	Returns a boolean indicating if execution completes successfully
  --
  FUNCTION Psi_Rollup RETURN BOOLEAN IS
    FIIBUUP_fatal_err	EXCEPTION;
    l_sqlstmt		VARCHAR2(10000);

  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.Psi_Rollup');
    END IF;

    g_phase := 'PSI Rollup';

    ------------------------------------------------------------------------
    -- Rollup data in fii_budget_stg along time dimension
    ------------------------------------------------------------------------
    l_sqlstmt :=
      ' INSERT /*+ append parallel(fii_budget_stg) */ INTO fii_budget_stg '||
         ' ( plan_type_code, period, quarter, year, ledger_id, '||
           ' company_id, cost_center_id, fin_category_id, category_id, '||
           ' user_dim1_id, user_dim2_id, prim_amount_g, '||
           ' prim_amount_total, baseline_amount_prim, '||
           ' posted_date, code_combination_id, budget_version_id, last_update_date, '||
           ' last_updated_by, creation_date, created_by, last_update_login) '||
      ' SELECT * FROM ( '||
       '  SELECT  /*+ parallel(b) parallel(fday) use_hash(fday) */ '||
       '    b.plan_type_code, '||
       '    fday.ent_period_id, fday.ent_qtr_id, fday.ent_year_id, '||
       '    b.ledger_id, b.company_id, b.cost_center_id, '||
       '    b.fin_category_id, b.category_id, b.user_dim1_id, '||
       '    b.user_dim2_id, '||
       '    SUM(b.prim_amount_g) prim_amount_g, '||
       '    SUM(b.prim_amount_total) prim_amount_total, '||
       '    SUM(b.baseline_amount_prim )baseline_amount_prim, '||
       '    b.posted_date, b.code_combination_id, b.budget_version_id, '||
       '    b.last_update_date, b.last_updated_by, '||
       '    b.creation_date, b.created_by, b.last_update_login '||
       '  FROM   fii_budget_stg b, '||
       '         fii_time_day fday '||
       ' WHERE  b.day  = fday.report_date_julian '||
       ' GROUP BY '||
       '   b.plan_type_code, b.ledger_id, b.company_id, b.cost_center_id, '||
       '   b.fin_category_id, b.category_id, b.user_dim1_id, b.user_dim2_id,'||
       '   b.posted_date, b.code_combination_id, b.budget_version_id, '||
       '   b.last_update_date, b.last_updated_by, '||
       '   b.creation_date, b.created_by, b.last_update_login, '||
       ' ROLLUP (fday.ent_year_id, '||
       '         fday.ent_qtr_id, '||
       '         fday.ent_period_id )) '||
       ' WHERE ent_year_id IS NOT NULL ';

    -- Print out the dynamic SQL statements if running in debug mode
    IF (FIIBUUP_DEBUG) THEN
      fii_util.put_line('l_sqlstmt = '|| l_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Psi_Rollup()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_sqlstmt)));
    END IF;

    -- Execute statement
    EXECUTE IMMEDIATE l_sqlstmt;

    IF  (FIIBUUP_DEBUG) THEN
      fii_util.put_line('Inserted '||SQL%ROWCOUNT||
                        ' rows into fii_budget_stg');
    END IF;

    -- Need to commit
    FND_CONCURRENT.Af_Commit;

    -- PSI Budget Extraction is completed, return with success.
    IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Psi_Rollup()',
           t2        => 'ACTION',
           v2        => 'PSI Rollup completed successfully...');
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.Psi_Rollup');
    END IF;
    RETURN TRUE;

  -- Exception handling
  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.Psi_Rollup()');

      FII_MESSAGE.Func_Fail
	(func_name =>'FII_BUDGET_FORECAST_C.Psi_Rollup');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

    WHEN OTHERS THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERROR',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'FII_BUDGET_FORECAST_C.Psi_Rollup()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

      FII_MESSAGE.Func_Fail
	  (func_name	=> 'FII_BUDGET_FORECAST_C.Psi_Rollup');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

  END Psi_Rollup;

-------------------------------------------------------------------------------
  --
  -- Procedure
  --   Psi_DeleteDiff()
  -- Purpose
  --   This routine will delete budget data with time/dimension combination
  --   that exists in fii_budget_base but not in fii_budget_stg (new data).
  -- Arguments
  --	None
  -- Example
  --   	result := FII_BUDGET_FORECAST_C.Psi_DeleteDiff;
  -- Notes
  --   	Returns a boolean indicating if execution completes successfully
  --
  FUNCTION Psi_DeleteDiff RETURN BOOLEAN IS
    FIIBUUP_fatal_err	EXCEPTION;
    l_sqlstmt		VARCHAR2(10000);

  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.Psi_DeleteDiff');
    END IF;

    g_phase := 'PSI DeleteDiff';

    ------------------------------------------------------------------------
    -- Delete rows from fii_budget_base if time/dimension combination does
    -- not exists in the new data in fii_budget_stg.
    ------------------------------------------------------------------------
    l_sqlstmt :=
      ' DELETE FROM fii_budget_base '||
      ' WHERE ( plan_type_code, '||
              ' time_id, '||
              ' period_type_id, '||
              ' ledger_id, '||
              ' company_id, '||
              ' cost_center_id, '||
              ' NVL(company_cost_center_org_id, -1), '||
              ' fin_category_id, '||
              ' category_id, '||
              ' user_dim1_id, '||
              ' user_dim2_id, '||
              ' posted_date, '||
              ' prim_amount_g, '||
              ' baseline_amount_prim) '||
      ' IN (SELECT plan_type_code, '||
                 ' time_id, '||
                 ' period_type_id, '||
                 ' ledger_id, '||
                 ' company_id, '||
                 ' cost_center_id, '||
                 ' NVL(company_cost_center_org_id, -1), '||
                 ' fin_category_id, '||
                 ' category_id, '||
                 ' user_dim1_id, '||
                 ' user_dim2_id, '||
                 ' posted_date, '||
                 ' prim_amount_g, '||
                 ' baseline_amount_prim '||
          ' FROM fii_budget_base '||
          ' MINUS '||
          ' SELECT  plan_type_code, '||
                  ' nvl(day, nvl(period, nvl(quarter, year))), '||
                  ' decode(day, null, '||
                    ' decode(period, null, '||
                      ' decode(quarter, null, 128, 64), 32), 1), '||
                  ' ledger_id, '||
                  ' company_id, '||
                  ' cost_center_id, '||
                  ' NVL(company_cost_center_org_id, -1), '||
                  ' fin_category_id, '||
                  ' category_id, '||
                  ' user_dim1_id, '||
                  ' user_dim2_id, '||
                  ' posted_date, '||
                  ' sum(prim_amount_g), '||
                  ' sum(baseline_amount_prim) '||
          ' FROM fii_budget_stg '||
          ' GROUP BY plan_type_code, '||
                   ' nvl(day, nvl(period, nvl(quarter, year))), '||
                   ' decode(day, null, '||
                     ' decode(period, null, '||
                       ' decode(quarter, null, 128, 64), 32), 1), '||
                   ' ledger_id, '||
                   ' company_id, '||
                   ' cost_center_id, '||
                   ' NVL(company_cost_center_org_id, -1), '||
                   ' fin_category_id, '||
                   ' category_id, '||
                   ' user_dim1_id, '||
                   ' user_dim2_id, '||
                   ' posted_date)  ';

    -- Print out the dynamic SQL statements if running in debug mode
    IF (FIIBUUP_DEBUG) THEN
      fii_util.put_line('l_sqlstmt = '|| l_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Psi_DeleteDiff()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_sqlstmt)));
    END IF;

    -- Execute statement
    EXECUTE IMMEDIATE l_sqlstmt;

    IF  (FIIBUUP_DEBUG) THEN
      fii_util.put_line('Deleted '||SQL%ROWCOUNT||
                        ' rows from fii_budget_base');
    END IF;

    -- Need to commit
    FND_CONCURRENT.Af_Commit;

    -- PSI Budget Extraction is completed, return with success.
    IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Psi_DeleteDiff()',
           t2        => 'ACTION',
           v2        => 'PSI DeleteDiff completed successfully...');
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.Psi_DeleteDiff');
    END IF;
    RETURN TRUE;

  -- Exception handling
  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.Psi_DeleteDiff()');

      FII_MESSAGE.Func_Fail
	(func_name =>'FII_BUDGET_FORECAST_C.Psi_DeleteDiff');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

    WHEN OTHERS THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERROR',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'FII_BUDGET_FORECAST_C.Psi_DeleteDiff()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

      FII_MESSAGE.Func_Fail
	  (func_name	=> 'FII_BUDGET_FORECAST_C.Psi_DeleteDiff');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

  END Psi_DeleteDiff;

-------------------------------------------------------------------------------
  --
  -- Procedure
  --   Psi_Insert_Base()
  -- Purpose
  --   This routine will merge new/modified budget data from fii_budget_stg
  --   into fii_budget_base.
  -- Arguments
  --	None
  -- Example
  --   	result := FII_BUDGET_FORECAST_C.Psi_Insert_Base;
  -- Notes
  --   	Returns a boolean indicating if execution completes successfully
  --
  FUNCTION Psi_Insert_Base RETURN BOOLEAN IS
    FIIBUUP_fatal_err	EXCEPTION;
    l_sqlstmt		VARCHAR2(10000);

  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.Psi_Insert_Base');
    END IF;

    g_phase := 'PSI Insert Base';

    ------------------------------------------------------------------------
    -- Insert new/modified budget data in fii_budget_stg into fii_budget_base
    ------------------------------------------------------------------------
    -- Bug 5004852: Changed to populate company_cost_center_org_id as well
    -- Bug 4943332: Added hints suggested by the performance team
    l_sqlstmt :=
    ' INSERT /*+ append parallel(b)*/ INTO fii_budget_base b '||
    ' ( plan_type_code, time_id, period_type_id, '||
      ' prim_amount_g, prim_amount_total, '||
      ' baseline_amount_prim, ledger_id, company_cost_center_org_id, '||
      ' company_id, cost_center_id, fin_category_id, category_id, '||
      ' user_dim1_id, user_dim2_id, posted_date, '||
      ' creation_date, created_by, last_update_date, '||
      ' last_updated_by, last_update_login, version_date ) '||
      ' SELECT /*+ parallel(stg) */ plan_type_code, '||
                  ' nvl(day, nvl(period, nvl(quarter, year))), '||
                  ' decode(day, null, '||
                    ' decode(period, null, '||
                      ' decode(quarter, null, 128, 64), 32), 1), '||
                  ' sum(prim_amount_g), sum(prim_amount_total), '||
                  ' sum(baseline_amount_prim), '||
                  ' ledger_id, '||
                  ' company_cost_center_org_id, '||
                  ' company_id, '||
                  ' cost_center_id, '||
                  ' fin_category_id, '||
                  ' category_id, '||
                  ' user_dim1_id, '||
                  ' user_dim2_id, '||
                  ' trunc(posted_date), '||
                  ' sysdate, :user_id, sysdate, :user_id, :login_id, '||
                  ' :ver_date '||
          ' FROM fii_budget_stg '||
          ' GROUP BY plan_type_code, '||
                   ' nvl(day, nvl(period, nvl(quarter, year))), '||
                   ' decode(day, null, '||
                     ' decode(period, null, '||
                       ' decode(quarter, null, 128, 64), 32), 1), '||
                   ' ledger_id, '||
                   ' company_cost_center_org_id, '||
                   ' company_id, '||
                   ' cost_center_id, '||
                   ' fin_category_id, '||
                   ' category_id, '||
                   ' user_dim1_id, '||
                   ' user_dim2_id, '||
                   ' posted_date '||
          ' MINUS '||
          'SELECT /*+ parallel(b1) */ plan_type_code, '||
                 ' time_id, '||
                 ' period_type_id, '||
                 ' prim_amount_g, '||
                 ' prim_amount_total, '||
                 ' baseline_amount_prim, '||
                 ' ledger_id, '||
                 ' company_cost_center_org_id, '||
                 ' company_id, '||
                 ' cost_center_id, '||
                 ' fin_category_id, '||
                 ' category_id, '||
                 ' user_dim1_id, '||
                 ' user_dim2_id, '||
                 ' trunc(posted_date), '||
                 ' sysdate, :user_id, sysdate, :user_id, :login_id, '||
                 ' :ver_date '||
          ' FROM fii_budget_base ';

    -- Print out the dynamic SQL statements if running in debug mode
    IF (FIIBUUP_DEBUG) THEN
      fii_util.put_line('l_sqlstmt = '|| l_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Psi_Insert_Base()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_sqlstmt)));
    END IF;

    -- Execute statement
    EXECUTE IMMEDIATE l_sqlstmt
    USING FIIBUUP_USER_ID, FIIBUUP_USER_ID,
          FIIBUUP_LOGIN_ID, FIIBUUP_GLOBAL_START_DATE,
          FIIBUUP_USER_ID, FIIBUUP_USER_ID,
          FIIBUUP_LOGIN_ID, FIIBUUP_GLOBAL_START_DATE;

    IF  (FIIBUUP_DEBUG) THEN
      fii_util.put_line('Inserted '||SQL%ROWCOUNT||
                        ' rows into fii_budget_base');
    END IF;

    -- Need to commit
    FND_CONCURRENT.Af_Commit;

    -- PSI Budget Extraction is completed, return with success.
    IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Psi_Insert_Base()',
           t2        => 'ACTION',
           v2        => 'PSI Merge completed successfully...');
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.Psi_Insert_Base');
    END IF;
    RETURN TRUE;

  -- Exception handling
  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.Psi_Insert_Base()');

      FII_MESSAGE.Func_Fail
	(func_name =>'FII_BUDGET_FORECAST_C.Psi_Insert_Base');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

    WHEN OTHERS THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERROR',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'FII_BUDGET_FORECAST_C.Psi_Insert_Base()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

      FII_MESSAGE.Func_Fail
	  (func_name	=> 'FII_BUDGET_FORECAST_C.Psi_Insert_Base');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

  END Psi_Insert_Base;

-------------------------------------------------------------------------------
  --
  -- Procedure
  --   Psi_Budget_Extract()
  -- Purpose
  --   When the profile 'INDUSTRY' = 'G', i.e. public sector install, this
  --   routine will be called to extract budget data from gl_je_headers/lines.
  -- Arguments
  --	None
  -- Example
  --   	result := FII_BUDGET_FORECAST_C.Psi_Budget_Extract;
  -- Notes
  --   	Returns a boolean indicating if execution completes successfully
  --
  PROCEDURE Psi_Budget_Extract (retcode IN OUT NOCOPY VARCHAR2) IS
    FIIBUUP_fatal_err	EXCEPTION;
    l_sqlstmt		VARCHAR2(10000);
    l_sob_name          VARCHAR2(30);
    l_currency_code     VARCHAR2(15);
    l_acct              VARCHAR2(350);
    l_budget_name       VARCHAR2(15);
    l_print_hdr1        BOOLEAN := FALSE;
    l_row_exists        NUMBER;

    CURSOR sobCursor (global_prim_curr VARCHAR2) IS
    SELECT DISTINCT sob.name, sob.currency_code
    FROM  fii_slg_assignments slga,
          fii_source_ledger_groups fslg,
          gl_ledgers_public_v sob
    WHERE sob.ledger_id = slga.ledger_id
    AND   slga.source_ledger_group_id = fslg.source_ledger_group_id
    AND   fslg.usage_code = 'DBI'
    AND   sob.currency_code NOT IN (global_prim_curr);

    CURSOR dupCursor IS
    SELECT /*+ parallel(bud) parallel(stg3) */
           DISTINCT acct.concatenated_segments,
                    bud.budget_name
    FROM   gl_code_combinations_kfv acct,
           gl_budget_versions bud,
          (SELECT code_combination_id, count(*)
           FROM   (SELECT /*+ parallel(stg) */ stg.code_combination_id,
                          stg.budget_version_id
                   FROM   fii_budget_stg stg
                   GROUP BY stg.code_combination_id, stg.budget_version_id)
           GROUP BY code_combination_id
           HAVING COUNT(*) > 1) stg2,
           fii_budget_stg stg3
    WHERE acct.code_combination_id = stg2.code_combination_id
    AND   stg3.code_combination_id = stg2.code_combination_id
    AND   bud.budget_version_id    = stg3.budget_version_id
    ORDER BY acct.concatenated_segments, bud.budget_name;

    CURSOR BaselineAmtCursor IS
      SELECT distinct sob.name from (
        SELECT  nvl(day, nvl(period, nvl(quarter, year))) time_id,
                decode(day, null,    decode(period, null,
                   decode(quarter, null, 128, 64), 32), 1) period_type_id,
                ledger_id, company_id, cost_center_id, fin_category_id,
                category_id, user_dim1_id, user_dim2_id, posted_date,
                baseline_amount_prim
        FROM   fii_budget_stg
        MINUS
        SELECT time_id, period_type_id,
               ledger_id, company_id, cost_center_id, fin_category_id,
               category_id, user_dim1_id, user_dim2_id, posted_date,
               baseline_amount_prim
        FROM   fii_budget_base) v,
               gl_ledgers_public_v sob
        WHERE sob.ledger_id = v.ledger_id;

    -- Bug 5004852: Added to select the company_cost_center_org_id for the
    --              company_id and cost_center_id of FII_BUDGET_STG
    CURSOR ccc_org_cursor IS
      SELECT DISTINCT NVL(cccorg.ccc_org_id, -1),
             stg.company_id, stg.cost_center_id
      FROM   FII_CCC_MGR_GT cccorg,
             FII_BUDGET_STG stg
      WHERE  cccorg.company_id (+) = stg.company_id
      AND    cccorg.cost_center_id (+) = stg.cost_center_id;

    -- Bug 5004852: Added the new record types and variables required
    TYPE num_type    IS TABLE OF NUMBER;
    TYPE ccc_org_rec IS RECORD(l_ccc_org_id num_type,
                               l_com_id     num_type,
                               l_cc_id      num_type);
    l_ccc_org_rec    CCC_ORG_REC;
    l_status         VARCHAR2(1);
  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.Psi_Budget_Extract');
    END IF;

    -- Alter session comments recommendated by the performance team
    EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
    EXECUTE IMMEDIATE 'ALTER SESSION SET HASH_AREA_SIZE = 100000000';
    EXECUTE IMMEDIATE 'ALTER SESSION SET SORT_AREA_SIZE = 100000000';

    retcode := 'S';

    ------------------------------------------------------------------------
    -- Validate SOB currencies
    -- We'll check that all set of books set up in FDS has their functional
    -- currency = global primary currency.  If not, we'll print the set of
    -- book names and its functional currency in the output file.
    ------------------------------------------------------------------------
    g_phase := 'Validate functional currencies';

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Psi_Budget_Extract()',
           t2        => 'ACTION',
           v2        => 'Validating functional currencies are global...');
    END IF;

    l_print_hdr1 := FALSE;

    FOR rec_csr IN sobCursor(FIIBUUP_PRIM_CURR_CODE) LOOP
      l_sob_name      := rec_csr.name;
      l_currency_code := rec_csr.currency_code;
      IF (NOT l_print_hdr1) THEN
        -- Set the return code so the program will ends with warning.
        retcode := 'W';

        FII_UTIL.Write_Output ('   ');
        FII_MESSAGE.Write_Log (msg_name  => 'FII_INV_FUNC_CURR_CODE',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
        FII_MESSAGE.Write_Output (msg_name  => 'FII_INV_FUNC_CURR_CODE',
                                  token_num => 0);
           l_print_hdr1 := TRUE;
      END IF;

      FII_UTIL.Write_Output (l_sob_name || ' (' || l_currency_code || ')');
    END LOOP;

    ------------------------------------------------------------------------
    -- Insert budget data into FII_BUDGET_STG from gl_je_headers/lines
    ------------------------------------------------------------------------
    IF (NOT FII_BUDGET_FORECAST_C.Psi_Insert_Stg) THEN
      raise FIIBUUP_fatal_err;
    END IF;

    ------------------------------------------------------------------------
    -- Insert carry forward budget data into FII_BUDGET_STG from gl_balances
    ------------------------------------------------------------------------
    IF (NOT FII_BUDGET_FORECAST_C.Psi_Carry_Forward) THEN
      raise FIIBUUP_fatal_err;
    END IF;

    ------------------------------------------------------------------------
    -- Check if a code combination is used across different budget.
    -- If so, print a warning message in the output file.
    ------------------------------------------------------------------------
    g_phase := 'Validate code combination';
    l_print_hdr1 := FALSE;

    FOR rec_csr IN dupCursor LOOP
      l_acct        := rec_csr.concatenated_segments;
      l_budget_name := rec_csr.budget_name;

      IF (NOT l_print_hdr1) THEN
        FII_UTIL.Write_Output ('   ');
        FII_MESSAGE.Write_Log (msg_name  => 'FII_CCID_ACROSS_BUDGETS',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
        FII_MESSAGE.Write_Output
            (msg_name	=> 'FII_CCID_ACROSS_BUDGETS',
             token_num	=> 0);
           l_print_hdr1 := TRUE;
      END IF;

      FII_UTIL.Write_Output (l_acct|| '       ' || l_budget_name );
    END LOOP;

    ------------------------------------------------------------------------
    -- Rollup budget data along time dimension
    ------------------------------------------------------------------------
    IF (NOT FII_BUDGET_FORECAST_C.Psi_Rollup) THEN
      raise FIIBUUP_fatal_err;
    END IF;

    ------------------------------------------------------------------------
    -- Check if baseline amounts has changed.  If so, print a warning message.
    ------------------------------------------------------------------------
    g_phase := 'Validate baseline amounts';
    l_print_hdr1 := FALSE;

    FOR rec_csr IN BaselineAmtCursor LOOP
      l_sob_name      := rec_csr.name;

        IF (NOT l_print_hdr1) THEN
          retcode := 'W';
          FII_UTIL.Write_Output ('   ');
          FII_MESSAGE.Write_Log (msg_name  => 'FII_PSI_BASELINE_CHANGED',
                                 token_num => 0);
          FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                                 token_num => 0);
          FII_MESSAGE.Write_Output (msg_name  => 'FII_PSI_BASELINE_CHANGED',
                                    token_num => 0);
         l_print_hdr1 := TRUE;

        END IF;
        FII_UTIL.Write_Output (l_sob_name);
    END LOOP;

    ------------------------------------------------------------------------
    -- Delete time/dimension combination not exists in new data in fii_budget_stg
    ------------------------------------------------------------------------
    IF (NOT FII_BUDGET_FORECAST_C.Psi_DeleteDiff) THEN
      raise FIIBUUP_fatal_err;
    END IF;

    -- Bug 5004852: Populate CCC - Mgr mappings temp table before opening the
    --              ccc_org_cursor to select company_cost_center_org_id
    g_phase := 'Populate the temp table FII_CCC_MGR_GT';
    l_status := null;

    FII_GL_EXTRACTION_UTIL.LOAD_CCC_MGR (l_status);

    IF l_status = -1 then
      fii_util.write_log('Error in FII_GL_EXTRACTION_UTIL.LOAD_CCC_MGR ...');
      fii_util.write_log('Table FII_CCC_MGR_GT is not populated');
      raise NO_DATA_FOUND;
    END IF;

    -- Bug 5004852: Populate company_cost_center_org_id in fii_budget_stg
    --              before inserting data into fii_budget_base
    g_phase := 'Open ccc_org_cursor to cache the CCC ORG IDs';

    OPEN ccc_org_cursor;
    FETCH ccc_org_cursor BULK COLLECT INTO l_ccc_org_rec.l_ccc_org_id,
                                           l_ccc_org_rec.l_com_id,
                                           l_ccc_org_rec.l_cc_id;

    g_phase := 'Populate CCC Org IDs of FII_BUDGET_STG';

    FORALL i in l_ccc_org_rec.l_cc_id.FIRST .. l_ccc_org_rec.l_cc_id.LAST
      UPDATE fii_budget_stg stg
      SET    stg.company_cost_center_org_id = l_ccc_org_rec.l_ccc_org_id(i)
      WHERE  stg.company_id = l_ccc_org_rec.l_com_id(i)
      AND    stg.cost_center_id = l_ccc_org_rec.l_cc_id(i);

    CLOSE ccc_org_cursor;

    ------------------------------------------------------------------------
    -- Merge data in fii_budget_stg into fii_budget_base
    ------------------------------------------------------------------------
    IF (NOT FII_BUDGET_FORECAST_C.Psi_Insert_Base) THEN
      raise FIIBUUP_fatal_err;
    END IF;

    ------------------------------------------------------------------------
    -- Check if there is any budget data in base table.  If not, print a
    -- warning message.
    ------------------------------------------------------------------------
    g_phase := 'Validate any budget data exists in base table';
    BEGIN
      -- Bug fix 4943332: Change to return 1 if any row exists
      SELECT 1
      INTO l_row_exists
      FROM fii_budget_base
      WHERE rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FII_MESSAGE.Write_Log (msg_name => 'FII_PSI_NO_RECS', token_num => 0);
        retcode := 'W';
    END;

    -- PSI Budget Extraction is completed, return with success.
    IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Psi_Budget_Extract()',
           t2        => 'ACTION',
           v2        => 'PSI Budget Extraction completed successfully...');
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.Psi_Budget_Extract');
    END IF;

  -- Exception handling
  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN

      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.Psi_Budget_Extract()');

      FII_MESSAGE.Func_Fail
	(func_name =>'FII_BUDGET_FORECAST_C.Psi_Budget_Extract');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);

      retcode := 'E';

    WHEN OTHERS THEN

      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERROR',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'FII_BUDGET_FORECAST_C.Psi_Budget_Extract()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

      FII_MESSAGE.Func_Fail
	  (func_name	=> 'FII_BUDGET_FORECAST_C.Psi_Budget_Extract');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);

      retcode := 'E';

  END Psi_Budget_Extract;

-------------------------------------------------------------------------------
  --
  -- Procedure
  --   Id_Convert()
  -- Purpose
  --   Perform value to ID conversion on dimensional columns
  --   This is for cases when user upload data to fii_budget_interface directly
  --   and they insert flex values for the dimensional columns.
  -- Arguments
  --	None
  -- Example
  --   	result := FII_BUDGET_FORECAST_C.Id_Convert;
  -- Notes
  --   	Returns a boolean indicating if execution completes successfully
  --
  FUNCTION Id_Convert RETURN BOOLEAN IS
    FIIBUUP_fatal_err	EXCEPTION;

    CURSOR sob_cursor IS
      SELECT DISTINCT nvl(f.ledger_id, i.ledger_id),
             nvl(i.ledger, '-1')
      FROM   FII_BUDGET_INTERFACE i,
             (SELECT DISTINCT sob.ledger_id, int.ledger
             FROM   FII_BUDGET_INTERFACE int,
                    GL_LEDGERS_PUBLIC_V sob
             WHERE (sob.ledger_id = int.ledger_id OR
                    sob.name               = int.ledger)) f
      WHERE i.ledger = f.ledger(+);

    CURSOR co_cursor IS
      SELECT DISTINCT nvl(f.flex_value_id, i.company_id),
             nvl(i.company, '-1'), f.ledger_id
      FROM   FII_BUDGET_INTERFACE i,
            (SELECT DISTINCT fv.flex_value_id, int.company, int.ledger_id
             FROM   FII_BUDGET_INTERFACE int,
                    FII_DIM_MAPPING_RULES r,
                    FND_FLEX_VALUES fv,
                    GL_LEDGERS_PUBLIC_V sob
             WHERE r.dimension_short_name  = 'FII_COMPANIES'
             AND   r.chart_of_accounts_id  = sob.chart_of_accounts_id
             AND   (sob.ledger_id = int.ledger_id OR
                    sob.name               = int.ledger)
             AND   fv.flex_value_set_id    = r.FLEX_VALUE_SET_ID1
             AND   int.company             = fv.flex_value) f
      WHERE i.company = f.company(+);

    CURSOR cc_cursor IS
      SELECT DISTINCT nvl(f.flex_value_id, i.cost_center_id),
             nvl(i.cost_center, '-1'), f.ledger_id
      FROM   FII_BUDGET_INTERFACE i,
            (SELECT DISTINCT fv.flex_value_id, int.cost_center, int.ledger_id
             FROM   FII_BUDGET_INTERFACE int,
                    FII_DIM_MAPPING_RULES r,
                    FND_FLEX_VALUES fv,
                    GL_LEDGERS_PUBLIC_V sob
             WHERE r.dimension_short_name  = 'HRI_CL_ORGCC'
             AND   r.chart_of_accounts_id  = sob.chart_of_accounts_id
             AND   (sob.ledger_id = int.ledger_id OR
                    sob.name               = int.ledger)
             AND   fv.flex_value_set_id    = r.FLEX_VALUE_SET_ID1
             AND   int.cost_center         = fv.flex_value) f
      WHERE i.cost_center = f.cost_center(+);

    CURSOR ccc_org_cursor IS
      SELECT DISTINCT NVL(cccorg.ccc_org_id, -1),
             int.company_id, int.cost_center_id
      FROM   FII_CCC_MGR_GT cccorg,
             FII_BUDGET_INTERFACE int
      WHERE  cccorg.company_id (+) = int.company_id
      AND    cccorg.cost_center_id (+) = int.cost_center_id
      AND    int.company_cost_center_org_id IS NULL;

    CURSOR fc_cursor IS
      SELECT DISTINCT nvl(f.flex_value_id, i.fin_category_id),
             nvl(i.fin_item, '-1'), f.ledger_id
      FROM   FII_BUDGET_INTERFACE i,
            (SELECT DISTINCT fv.flex_value_id, int.fin_item, int.ledger_id
             FROM FII_DIM_MAPPING_RULES r,
                  FII_BUDGET_INTERFACE int,
                  FND_FLEX_VALUES fv,
                  GL_LEDGERS_PUBLIC_V sob
             WHERE r.dimension_short_name  = 'GL_FII_FIN_ITEM'
             AND   r.chart_of_accounts_id  = sob.chart_of_accounts_id
             AND   (sob.ledger_id = int.ledger_id OR
                    sob.name               = int.ledger)
             AND   fv.flex_value_set_id    = r.FLEX_VALUE_SET_ID1
             AND   int.fin_item             = fv.flex_value) f
      WHERE i.fin_item = f.fin_item(+);

    -- Cursor used for User-Defined Dimension dimension
    CURSOR udd1_cursor IS
      SELECT DISTINCT nvl(f.flex_value_id, FIIBUUP_UNASSIGNED_UDD_ID),
             nvl(i.user_dim1, 'UNASSIGNED'), f.ledger_id
      FROM   FII_BUDGET_INTERFACE i,
            (SELECT DISTINCT fv.flex_value_id, int.user_dim1 , int.ledger_id
             FROM   FII_DIM_MAPPING_RULES r,
                    FII_BUDGET_INTERFACE int,
                    FND_FLEX_VALUES fv,
                    GL_LEDGERS_PUBLIC_V sob
             WHERE  r.dimension_short_name = 'FII_USER_DEFINED_1'
             AND    r.chart_of_accounts_id = sob.chart_of_accounts_id
             AND    (sob.ledger_id = int.ledger_id OR
                    sob.name               = int.ledger)
             AND    fv.flex_value_set_id   = r.flex_value_set_id1
             AND    int.user_dim1          = fv.flex_value) f
      WHERE i.user_dim1 = f.user_dim1(+);

    -- Cursor used for Product Category dimension
    CURSOR prod_cat_cursor IS
      SELECT DISTINCT m.category_id, int.product_code
      FROM   mtl_categories_tl m, fii_budget_interface int
      WHERE  m.description = int.product_code
      AND    m.language    = userenv('LANG');

    TYPE num_type   IS TABLE OF NUMBER;
    TYPE value_type IS TABLE OF VARCHAR2(150);

    -- Table for storing flex value id to value mapping
    TYPE id_val_rec IS RECORD(
      l_id         num_type,
      l_value      value_type,
      l_ledger_id  num_type );

    -- Table for finding ccc_org_id
    TYPE ccc_org_rec IS RECORD(
      l_ccc_org_id num_type,
      l_com_id     num_type,
      l_cc_id      num_type);

    l_id_val_rec        ID_VAL_REC;
    l_ccc_org_rec       CCC_ORG_REC;
    l_udd1_enabled_flag VARCHAR2(1);
    l_status            VARCHAR2(1) := null;

  BEGIN
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.Id_Convert');
    END IF;

    ----------------------------------------------------
    -- Populate CCC - Mgr mappings temp table
    ----------------------------------------------------
    g_phase := 'Call program that populates CCC - Mgr mappings temp table.';
    FII_GL_EXTRACTION_UTIL.LOAD_CCC_MGR (l_status);

    IF l_status = -1 then
      fii_util.write_log('Error in FII_GL_EXTRACTION_UTIL.LOAD_CCC_MGR ...');
      fii_util.write_log('Table FII_CCC_MGR_GT is not populated');
      raise NO_DATA_FOUND;
    END IF;

    g_phase := 'Value to ID Conversion';

    -- Store value to ID mappings for the ledger dimension

    OPEN  sob_cursor;
    FETCH sob_cursor BULK COLLECT INTO l_id_val_rec.l_id, l_id_val_rec.l_value;

    FORALL i in l_id_val_rec.l_id.FIRST .. l_id_val_rec.l_id.LAST
      UPDATE fii_budget_interface int
      SET   int.ledger_id = l_id_val_rec.l_id(i)
      WHERE int.ledger    = l_id_val_rec.l_value(i);

    CLOSE sob_cursor;

    -- Store value to ID mappings for the company dimension
    OPEN  co_cursor;
    FETCH co_cursor BULK COLLECT INTO l_id_val_rec.l_id,
                                      l_id_val_rec.l_value,
                                      l_id_val_rec.l_ledger_id;

    FORALL i in l_id_val_rec.l_id.FIRST .. l_id_val_rec.l_id.LAST
      UPDATE fii_budget_interface int
      SET   int.company_id = l_id_val_rec.l_id(i)
      WHERE int.company    = l_id_val_rec.l_value(i)
      AND   int.ledger_id  = l_id_val_rec.l_ledger_id(i);

    CLOSE co_cursor;

    -- Store value to ID mappings for the cost center dimension
    OPEN  cc_cursor;
    FETCH cc_cursor BULK COLLECT INTO l_id_val_rec.l_id,
                                      l_id_val_rec.l_value,
                                      l_id_val_rec.l_ledger_id;

    FORALL i in l_id_val_rec.l_id.FIRST .. l_id_val_rec.l_id.LAST
      UPDATE fii_budget_interface int
      SET   int.cost_center_id = l_id_val_rec.l_id(i)
      WHERE int.cost_center    = l_id_val_rec.l_value(i)
      AND   int.ledger_id      = l_id_val_rec.l_ledger_id(i);

    CLOSE cc_cursor;

    -- Now we should have the company IDs and cost center IDs in the
    -- interface table.  Now find out the ccc org IDs.
    OPEN  ccc_org_cursor;
    FETCH ccc_org_cursor BULK COLLECT INTO l_ccc_org_rec.l_ccc_org_id,
                                           l_ccc_org_rec.l_com_id,
                                           l_ccc_org_rec.l_cc_id;

    IF (l_ccc_org_rec.l_cc_id.FIRST IS NOT NULL) THEN
      FORALL i in l_ccc_org_rec.l_cc_id.FIRST .. l_ccc_org_rec.l_cc_id.LAST
        UPDATE fii_budget_interface int
        SET    int.company_cost_center_org_id = l_ccc_org_rec.l_ccc_org_id(i)
        WHERE  int.company_id = l_ccc_org_rec.l_com_id(i)
        AND    int.cost_center_id = l_ccc_org_rec.l_cc_id(i);
    END IF;

    CLOSE ccc_org_cursor;

    -- Store value to ID mappings for the financial category dimension
    OPEN  fc_cursor;
      FETCH fc_cursor BULK COLLECT INTO l_id_val_rec.l_id,
                                        l_id_val_rec.l_value,
                                        l_id_val_rec.l_ledger_id;

      FORALL i in l_id_val_rec.l_id.FIRST .. l_id_val_rec.l_id.LAST
        UPDATE fii_budget_interface int
        SET   int.fin_category_id = l_id_val_rec.l_id(i)
        WHERE int.fin_item        = l_id_val_rec.l_value(i)
        AND   int.ledger_id       = l_id_val_rec.l_ledger_id(i);
    CLOSE fc_cursor;

    -- Process UDD1 Dimension
    -- Check if UDD1 is enabled or not

    SELECT DBI_ENABLED_FLAG
    INTO   l_udd1_enabled_flag
    FROM   FII_FINANCIAL_DIMENSIONS
    WHERE  dimension_short_name = 'FII_USER_DEFINED_1';

    IF (l_udd1_enabled_flag = 'Y') THEN
      -- UDD1 is enabled.  Perform value to ID conversion.
      OPEN udd1_cursor;
      FETCH udd1_cursor BULK COLLECT INTO l_id_val_rec.l_id,
                                          l_id_val_rec.l_value,
                                          l_id_val_rec.l_ledger_id;

      FORALL i in l_id_val_rec.l_id.FIRST .. l_id_val_rec.l_id.LAST
        UPDATE fii_budget_interface int
        SET  (int.user_dim1_id, int.user_dim1,
              int.user_dim2_id, int.user_dim2) =
              (SELECT l_id_val_rec.l_id(i), l_id_val_rec.l_value(i),
                      FIIBUUP_UNASSIGNED_UDD_ID, 'UNASSIGNED' from dual)
        WHERE NVL(int.user_dim1, 'UNASSIGNED') = l_id_val_rec.l_value(i)
        AND   int.ledger_id                    = l_id_val_rec.l_ledger_id(i);

      CLOSE udd1_cursor;

    ELSE
      -- UDD1 is disabled.  Update user_dim1 to UNASSIGNED and user_dim1_id to
      -- the pre-seeded unassigned ID.
      UPDATE fii_budget_interface int
      SET  (int.user_dim1_id, int.user_dim1, int.user_dim2_id, int.user_dim2) =
           (SELECT FIIBUUP_UNASSIGNED_UDD_ID, 'UNASSIGNED',
                   FIIBUUP_UNASSIGNED_UDD_ID, 'UNASSIGNED' from dual);

    END IF;

    -- Process Product Category Dimension
    OPEN prod_cat_cursor;
    FETCH prod_cat_cursor BULK COLLECT INTO l_id_val_rec.l_id,
                                            l_id_val_rec.l_value;

    IF (l_id_val_rec.l_id.FIRST IS NOT NULL) THEN
      FORALL i in l_id_val_rec.l_id.FIRST .. l_id_val_rec.l_id.LAST
        UPDATE fii_budget_interface int
        SET   int.prod_category_id = l_id_val_rec.l_id(i)
        WHERE int.product_code     = l_id_val_rec.l_value(i);
    END IF;

    CLOSE prod_cat_cursor;

    -- Value to ID conversion is completed, return with success.
    IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Id_Convert()',
           t2        => 'ACTION',
           v2        => 'Value to ID Conversion completed successfully...');
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.Id_Convert');
    END IF;
    RETURN TRUE;

  -- Exception handling
  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN

      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.Id_Convert()');

      FII_MESSAGE.Func_Fail
	(func_name =>'FII_BUDGET_FORECAST_C.Id_Convert');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);

      RETURN FALSE;

    WHEN OTHERS THEN

      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERROR',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'FII_BUDGET_FORECAST_C.Id_Convert()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

      FII_MESSAGE.Func_Fail
	  (func_name	=> 'FII_BUDGET_FORECAST_C.Id_Convert');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);

      RETURN FALSE;

  END Id_convert;
-------------------------------------------------------------------------------
  --
  -- Procedure
  --   Validate
  -- Purpose
  --   Validate all data in FII_BUDGET_INTERFACE and reports any
  --   violations found:
  --
  --   1. Validate records are either for budgets or forecast
  --   2. Check if any record is missing any time period information
  --   3. Validate that the time dimension provided in the interface table
  --      is valid in the global calendar and time granularity is at the
  --      same level as the profile
  --   4. Validate that company information is provided
  --      Validate that company is defined as leaf nodes in vs setup in FDS
  --   5. Validate that cost center information is provided
  --      Validate that cost center is defined as leaf nodes in vs setup in FDS
  --   6. Validate that fin cat ID is provided and valid in vs setup in FDS
  --   7. Validate that prod category ID is provided and is valid
  --   8. Validate that user defined dim1 is provided if udd1 enabled and
  --      it is valid in vs setup in FDS
  --   9. Validate conversion rates is provided if only primary amount is given
  --      and primary and secondary currency are not the same.
  --      Also validate that conversion rates are positive and non-zero.
  --  10. Validate only one record exists for the time/dimension combination
  --  11. Validate version date is equal to or greater than global start date.
  --      Also validate that it is greater than or equal to the latest version
  --      date for the period/dimension combination.
  --
  -- Arguments
  --	None
  -- Example
  --   	result := FII_BUDGET_FORECAST_C.Validate;
  -- Notes
  --   	Returns a boolean indicating if execution completes successfully
  PROCEDURE Validate (retcode IN OUT NOCOPY VARCHAR2) IS
    TYPE anyCursor IS REF CURSOR;
    FIIBUUP_fatal_err	EXCEPTION;
    l_sqlstmt		VARCHAR2(5000);
    l_print_hdr1	BOOLEAN 	:= FALSE;
    l_print_hdr2	BOOLEAN 	:= FALSE;
    l_violations_found	BOOLEAN		:= FALSE;
    l_timeUnitCursor	anyCursor;
    l_plan_code		VARCHAR2(1) 	:= NULL;
    l_time_unit		VARCHAR2(100) 	:= NULL;
    l_prim_amount_g     NUMBER;
    l_ledger            VARCHAR2(150);
    l_ledger_id         NUMBER(15);
    l_com               VARCHAR2(150);
    l_com_id            NUMBER(15);
    l_cc                VARCHAR2(150);
    l_cc_id             NUMBER(15);
    l_fin_item          VARCHAR2(150);
    l_fin_cat_id        NUMBER(15);
    l_prod_cat_id       NUMBER(15);
    l_prod_code         VARCHAR2(150);
    l_udd1              VARCHAR2(150);
    l_udd1_id           NUMBER(15);
    l_ver_date          DATE;
    P_MTC_STRUCTURE_ID  NUMBER(15);
    l_count             NUMBER(15);
    l_pcat_enabled_flag VARCHAR2(1);

    -- This is the cursor to print out invalid plan_type_code
    CURSOR planCursor IS
    SELECT plan_type_code, prim_amount_g
    FROM   FII_BUDGET_INTERFACE
    WHERE  plan_type_code NOT IN ('B', 'F')
    FOR UPDATE OF STATUS_CODE;

    -- This is the cursor to print out records with null time
    CURSOR csr_null_time_1 IS
    SELECT plan_type_code, prim_amount_g
    FROM   FII_BUDGET_INTERFACE
    WHERE  report_time_period IS NULL
    FOR UPDATE OF STATUS_CODE;

    CURSOR csr_null_time_2 IS
    SELECT plan_type_code, prim_amount_g
    FROM   FII_BUDGET_INTERFACE
    WHERE  plan_type_code = 'B'
    AND    report_time_period IS NULL
    FOR UPDATE OF STATUS_CODE;

    CURSOR csr_null_time_3 IS
    SELECT plan_type_code, prim_amount_g
    FROM   FII_BUDGET_INTERFACE
    WHERE  plan_type_code = 'F'
    AND    report_time_period IS NULL
    FOR UPDATE OF STATUS_CODE;

    -- This is the cursor that print out all null ledger
    CURSOR csr_null_ledger_id IS
    SELECT plan_type_code, prim_amount_g
    FROM   FII_BUDGET_INTERFACE
    WHERE  ledger IS NULL
    AND    ledger_id IS NULL
    FOR UPDATE OF STATUS_CODE;

    -- Validate that the ledger_id provided are valid and
    -- set up in FDS
    CURSOR ledgerCursor IS
    SELECT b.ledger, b.ledger_id
    FROM   FII_BUDGET_INTERFACE b
    WHERE (b.ledger IS NOT NULL AND b.ledger_id IS NULL) OR
          (nvl(b.ledger_id, -1) NOT IN (
          SELECT ledger_id
          FROM FII_SLG_ASSIGNMENTS))
    FOR UPDATE OF STATUS_CODE;

    -- This is the cursor that print out all null company id
    CURSOR csr_null_com_id IS
    SELECT plan_type_code, prim_amount_g
    FROM   FII_BUDGET_INTERFACE
    WHERE  company IS NULL
    AND    company_id IS NULL
    FOR UPDATE OF STATUS_CODE;

    -- This is the cursor that validates all company_id provided are
    -- from the value sets of the BSVs of the ledgers setup in FDS
    CURSOR comCursor IS
    SELECT b.company, b.company_id
    FROM   FII_BUDGET_INTERFACE b
    WHERE (b.company IS NOT NULL AND b.company_id IS NULL) OR
          NOT EXISTS (
             SELECT '1'
             FROM   FND_FLEX_VALUES fv,
                    FND_ID_FLEX_SEGMENTS  fs,
                    FII_DIM_MAPPING_RULES mr,
                    FND_SEGMENT_ATTRIBUTE_VALUES b
             WHERE fs.application_id          = 101
             AND   fs.id_flex_code            = 'GL#'
             AND   fs.id_flex_num             = mr.chart_of_accounts_id
--             AND   fs.application_column_name = mr.application_column_name1
--             AND   mr.dimension_short_name    = 'FII_COMPANIES'
             AND   fs.application_id          = b.application_id
             AND   fs.id_flex_code            = b.id_flex_code
             AND   fs.id_flex_num             = b.id_flex_num
             AND   fs.application_column_name = b.application_column_name
             AND   b.attribute_value         = 'Y'
             AND   b.segment_attribute_type = 'GL_BALANCING'
             AND   fv.flex_value_set_id       = fs.flex_value_set_id
             AND   fv.summary_flag            = 'N'
             AND   (nvl(b.company_id, -1)     = fv.flex_value_id ))
    FOR UPDATE OF STATUS_CODE;

    -- This is the cursor that print out all null cost_center_id
    CURSOR csr_null_cc_id IS
    SELECT plan_type_code, prim_amount_g
    FROM   FII_BUDGET_INTERFACE
    WHERE  cost_center IS NULL
    AND    cost_center_id IS NULL
    FOR UPDATE OF STATUS_CODE;

    -- This is the cursor that validates all cost_center_id provided are
    -- from the value sets of the cost center segment of ledgers setup in FDS
    CURSOR ccCursor IS
    SELECT b.cost_center, b.cost_center_id
    FROM   FII_BUDGET_INTERFACE b
    WHERE (b.cost_center IS NOT NULL and b.cost_center_id IS NULL) OR
          NOT EXISTS (
             SELECT '1'
             FROM   FND_FLEX_VALUES fv,
                    FND_ID_FLEX_SEGMENTS  fs,
                   FII_DIM_MAPPING_RULES mr,
                    FND_SEGMENT_ATTRIBUTE_VALUES b
             WHERE fs.application_id          = 101
             AND   fs.id_flex_code            = 'GL#'
             AND   fs.id_flex_num             = mr.chart_of_accounts_id
--             AND   fs.application_column_name = mr.application_column_name1
--             AND   mr.dimension_short_name    = 'HRI_CL_ORGCC'
             AND   fs.application_id          = b.application_id
             AND   fs.id_flex_code            = b.id_flex_code
             AND   fs.id_flex_num             = b.id_flex_num
             AND   fs.application_column_name = b.application_column_name
             AND   b.attribute_value          = 'Y'
             AND   b.segment_attribute_type   = 'FA_COST_CTR'
             AND   fv.flex_value_set_id       = fs.flex_value_set_id
             AND   fv.summary_flag            = 'N'
             AND   (nvl(b.cost_center_id, -1) = fv.flex_value_id ))
    FOR UPDATE OF STATUS_CODE;

    -- This is the cursor that print out all null fin_category_id
    CURSOR csr_null_fin_cat_id IS
    SELECT plan_type_code, prim_amount_g
    FROM   FII_BUDGET_INTERFACE
    WHERE  fin_item IS NULL
    AND    fin_category_id IS NULL
    FOR UPDATE OF STATUS_CODE;

    -- This is the cursor that validates all fin_category_id
    -- provided are indeed defined in the system.
    CURSOR fincatCursor IS
    SELECT b.fin_item, b.fin_category_id
    FROM   FII_BUDGET_INTERFACE b
    WHERE (b.fin_item IS NOT NULL AND b.fin_category_id IS NULL) OR
          NOT EXISTS (
             SELECT '1'
             FROM   fnd_flex_values fv,
                    fnd_id_flex_segments  fs,
                    fnd_segment_attribute_values b,
                    fii_dim_mapping_rules mr
             WHERE  fs.application_id          = 101
             AND    fs.id_flex_code            = 'GL#'
             AND    fs.id_flex_num             = mr.chart_of_accounts_id
--             AND    fs.application_column_name = mr.application_column_name1
--             AND    mr.dimension_short_name    = 'GL_FII_FIN_ITEM'
             AND   fs.application_id          = b.application_id
             AND   fs.id_flex_code            = b.id_flex_code
             AND   fs.id_flex_num             = b.id_flex_num
             AND   fs.application_column_name = b.application_column_name
             AND   b.attribute_value          = 'Y'
             AND   b.segment_attribute_type   = 'GL_ACCOUNT'
             AND    fv.flex_value_set_id       = fs.flex_value_set_id
             AND   (nvl(b.fin_category_id, -1) = fv.flex_value_id))
    FOR UPDATE OF b.STATUS_CODE;

    -- This is the cursor that validates all product categories
    -- provided are indeed defined in the system.
    CURSOR prodCursor IS
    SELECT b.product_code, b.prod_category_id
    FROM   FII_BUDGET_INTERFACE b
    WHERE  (b.prod_category_id IS NULL AND b.product_code IS NOT NULL) OR
           (b.prod_category_id NOT IN
             (SELECT mck.category_id
              FROM   MTL_CATEGORIES_KFV mck
              WHERE  mck.structure_id = p_mtc_structure_id))
    FOR UPDATE OF b.STATUS_CODE;

    -- This is the cursor that validates all user_dim1_id
    -- provided are indeed defined in the system.
    CURSOR udd1Cursor IS
    SELECT b.user_dim1, b.user_dim1_id
    FROM   FII_BUDGET_INTERFACE b
    WHERE (b.user_dim1 IS NOT NULL AND b.user_dim1_id IS NULL) OR
          (nvl(b.user_dim1_id, -1) NOT IN (
             SELECT fv.flex_value_id
             FROM   fnd_flex_values fv,
                    fnd_id_flex_segments  fs,
                    fii_dim_mapping_rules mr
             WHERE  fs.application_id          = 101
             AND    fs.id_flex_code            = 'GL#'
             AND    fs.id_flex_num             = mr.chart_of_accounts_id
             AND    fs.application_column_name = mr.application_column_name1
             AND    mr.dimension_short_name    = 'FII_USER_DEFINED_1'
             AND    fv.flex_value_set_id       = fs.flex_value_set_id
             UNION
             SELECT FIIBUUP_UNASSIGNED_UDD_ID from DUAL))
    FOR UPDATE OF b.STATUS_CODE;

    -- This is the cursor that validates conversion rates are present
    -- for any record with only the primary global amount provided, and
    -- the primary global currency is different from the secondary global
    -- currency.  It also validates that the conversion rate is positive
    -- and non-zero.
    CURSOR rateCursor IS
      SELECT plan_type_code, prim_amount_g
      FROM   FII_BUDGET_INTERFACE
      WHERE  FIIBUUP_SEC_CURR_CODE is NOT NULL
      AND    sec_amount_g is NULL
      AND    (conversion_rate is NULL OR conversion_rate <= 0)
      FOR UPDATE OF STATUS_CODE;

    -- This is the cursor that checks if more than one records exist
    -- with the same plan_type_code/period/ledger_id/company_id/cost_center_id/
    -- fin_category_id/prod_category_id/user_dim1_id/version_date combination
    CURSOR dupRecordCursor IS
      SELECT plan_type_code, trunc(version_date),
             report_time_period,
	     ledger_id, company_id, cost_center_id, fin_category_id,
             prod_category_id, user_dim1_id
      FROM FII_BUDGET_INTERFACE
      GROUP BY plan_type_code, trunc(version_date),
               report_time_period,
	       ledger_id, company_id, cost_center_id, fin_category_id,
               prod_category_id, user_dim1_id
      HAVING count(prim_amount_g) > 1
      ORDER BY 1;

    -- This is the cursor that validates version date is on or after global
    -- start date.  Also,, version date in interface is greater than or equal
    -- to the latest effective date for the time/dimension combination in
    -- the base table.
    CURSOR verDateCursorPer IS
      SELECT i.plan_type_code, trunc(i.version_date),
             i.report_time_period, i.ledger_id,
	     i.company_id, i.cost_center_id, i.fin_category_id,
             i.prod_category_id, i.user_dim1_id
      FROM   FII_BUDGET_INTERFACE i
      WHERE  ((trunc(i.version_date) < FIIBUUP_GLOBAL_START_DATE) OR
              (trunc(i.version_date) <
                    (SELECT MAX(b.version_date)
                     FROM FII_BUDGET_BASE b, FII_TIME_ENT_PERIOD p
                     WHERE p.name = i.report_time_period
                     AND   b.time_id = p.ent_period_id
                     AND   b.ledger_id = i.ledger_id
                     AND   b.company_id = i.company_id
                     AND   b.cost_center_id = i.cost_center_id
                     AND   b.fin_category_id = i.fin_category_id
                     AND   NVL(b.category_id, -1) = NVL(i.prod_category_id, -1)
                     AND   b.user_dim1_id = i.user_dim1_id
                     AND   trunc(b.upload_date) <> trunc(i.upload_date))))
      GROUP BY i.plan_type_code, trunc(i.version_date), i.report_time_period,
               i.ledger_id, i.company_id, i.cost_center_id, i.fin_category_id,
               i.prod_category_id, i.user_dim1_id;

    CURSOR verDateCursorQtr IS
      SELECT i.plan_type_code, trunc(i.version_date),
             i.report_time_period, i.ledger_id,
	     i.company_id, i.cost_center_id, i.fin_category_id,
             i.prod_category_id, i.user_dim1_id
      FROM   FII_BUDGET_INTERFACE i
      WHERE  ((trunc(i.version_date) < FIIBUUP_GLOBAL_START_DATE) OR
              (trunc(i.version_date) <
                    (SELECT MAX(b.version_date)
                     FROM FII_BUDGET_BASE b, FII_TIME_ENT_QTR q
                     WHERE q.name = i.report_time_period
                     AND   b.time_id = q.ent_qtr_id
                     AND   b.ledger_id = i.ledger_id
                     AND   b.company_id = i.company_id
                     AND   b.cost_center_id = i.cost_center_id
                     AND   b.fin_category_id = i.fin_category_id
                     AND   NVL(b.category_id, -1) = NVL(i.prod_category_id, -1)
                     AND   b.user_dim1_id = i.user_dim1_id
                     AND   trunc(b.upload_date) <> trunc(i.upload_date))))
      GROUP BY i.plan_type_code, trunc(i.version_date), i.report_time_period,
               i.ledger_id, i.company_id, i.cost_center_id, i.fin_category_id,
               i.prod_category_id, i.user_dim1_id;

    CURSOR verDateCursorYr IS
      SELECT i.plan_type_code, trunc(i.version_date),
             i.report_time_period, i.ledger_id,
	     i.company_id, i.cost_center_id, i.fin_category_id,
             i.prod_category_id, i.user_dim1_id
      FROM   FII_BUDGET_INTERFACE i
      WHERE  ((trunc(i.version_date) < FIIBUUP_GLOBAL_START_DATE) OR
              (trunc(i.version_date) <
                    (SELECT MAX(b.version_date)
                     FROM FII_BUDGET_BASE b, FII_TIME_ENT_YEAR y
                     WHERE y.name = i.report_time_period
                     AND   b.time_id = y.ent_year_id
                     AND   b.ledger_id = i.ledger_id
                     AND   b.company_id = i.company_id
                     AND   b.cost_center_id = i.cost_center_id
                     AND   b.fin_category_id = i.fin_category_id
                     AND   NVL(b.category_id, -1) = NVL(i.prod_category_id, -1)
                     AND   b.user_dim1_id = i.user_dim1_id
                     AND   trunc(b.upload_date) <> trunc(i.upload_date))))
      GROUP BY i.plan_type_code, trunc(i.version_date), i.report_time_period,
               i.ledger_id, i.company_id, i.cost_center_id, i.fin_category_id,
               i.prod_category_id, i.user_dim1_id;

    l_err_count NUMBER;

  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.Validate');
    END IF;

    retcode := 'S';

    --Remove records with non-null status_code from the interface table
    IF (FIIBUUP_DEBUG) THEN
      FII_UTIL.Write_Log ('Removing last processed records from the interface table');
    END IF;

    g_phase := 'Delete from FII_BUDGET_INTERFACE for not-null status_code';
    delete from FII_BUDGET_INTERFACE
    where status_code is not NULL;

    -- Update records as 'VALIDATED' and set the upload date to sysdate
    IF (FIIBUUP_DEBUG) THEN
      FII_UTIL.Write_Log ('Updating new records in the interface table');
    END IF;

    g_phase := 'Update all other records to status_code = VALIDATED and upload_date = sysdate';
    update FII_BUDGET_INTERFACE
       set (status_code, upload_date) = (SELECT 'VALIDATED', sysdate from dual);

    -- Bug fix 4943332: We don't need to count the rows of FII_BUDGET_INTERFACE
    --                  as we can get the row count updated by previuos SQL
    IF (SQL%ROWCOUNT = 0) THEN
      FII_MESSAGE.Write_Log (msg_name => 'FII_BUD_NO_RECS', token_num => 0);
      retcode := 'W';
      RETURN;
    END IF;

    -----------------------------------------------------------------------
    -- 1. Validate records are either for budgets or forecast
    -----------------------------------------------------------------------
    l_print_hdr1 := FALSE;

    -- Validates that all plan_type_code are valid
    FOR rec_csr IN planCursor LOOP
        l_plan_code     := rec_csr.plan_type_code;
        l_prim_amount_g := rec_csr.prim_amount_g;
        IF (NOT l_print_hdr1) THEN
          FII_UTIL.Write_Output ('   ');
          FII_MESSAGE.Write_Log (msg_name  => 'FII_INV_PLAN_TYPE_CODE',
                                 token_num => 0);
          FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                                 token_num => 0);
          FII_MESSAGE.Write_Output
            (msg_name	=> 'FII_INV_PLAN_TYPE_CODE',
             token_num	=> 0);
           FII_MESSAGE.Write_Output
            (msg_name	=> 'FII_BUDGET_RECORD_TAB',
             token_num	=> 0);
           l_print_hdr1 := TRUE;
        END IF;

        FII_UTIL.Write_Output (l_plan_code || '       ' || l_prim_amount_g);

        UPDATE FII_BUDGET_INTERFACE
        SET    status_code = 'ERROR'
        WHERE CURRENT OF planCursor;
    End Loop;

    -----------------------------------------------------------------------
    -- 2. Check if any record is missing any time period information
    -----------------------------------------------------------------------
    g_phase := 'Check if any record is missing time period information';
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Validate()',
           t2        => 'ACTION',
           v2        => 'Checking for missing time units...');
    END IF;

    l_print_hdr1 := FALSE;
    IF (FIIBUUP_BUDGET_TIME_UNIT = FIIBUUP_FORECAST_TIME_UNIT) THEN

      For rec_csr IN csr_null_time_1 LOOP
          l_plan_code     := rec_csr.plan_type_code;
          l_prim_amount_g := rec_csr.prim_amount_g;
          IF (NOT l_print_hdr1) THEN
            FII_UTIL.Write_Output ('   ');
          FII_MESSAGE.Write_Log (msg_name  => 'FII_MISS_TIME_BUD_FRC',
                                 token_num => 0);
          FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                                 token_num => 0);
            FII_MESSAGE.Write_Output
	         (msg_name	=> 'FII_MISS_TIME_BUD_FRC',
	          token_num	=> 0);
            FII_MESSAGE.Write_Output
	         (msg_name	=> 'FII_BUDGET_RECORD_TAB',
	          token_num	=> 0);
            l_print_hdr1 := TRUE;
          END IF;

          FII_UTIL.Write_Output (l_plan_code || '       ' || l_prim_amount_g);

          UPDATE FII_BUDGET_INTERFACE
             SET Status_Code = 'ERROR'
           WHERE CURRENT OF csr_null_time_1;
      End Loop;

    ELSE
      -- Validate budget data
      For rec_csr IN csr_null_time_2 LOOP
          l_plan_code     := rec_csr.plan_type_code;
          l_prim_amount_g := rec_csr.prim_amount_g;
          IF (NOT l_print_hdr1) THEN
            FII_UTIL.Write_Output ('   ');
            FII_MESSAGE.Write_Log (msg_name  => 'FII_MISS_TIME_BUD',
                                   token_num => 0);
            FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                                   token_num => 0);
            FII_MESSAGE.Write_Output
	         (msg_name	=> 'FII_MISS_TIME_BUD',
	          token_num	=> 0);
            FII_MESSAGE.Write_Output
	         (msg_name	=> 'FII_BUDGET_RECORD_TAB',
	          token_num	=> 0);
            l_print_hdr1 := TRUE;
          END IF;

          FII_UTIL.Write_Output (l_plan_code || '       ' || l_prim_amount_g);

          UPDATE FII_BUDGET_INTERFACE
             SET Status_Code = 'ERROR'
           WHERE CURRENT OF csr_null_time_2;
      End Loop;

      -- Validate forecast data
      l_print_hdr1 := FALSE;

      For rec_csr IN csr_null_time_3 LOOP
          l_plan_code     := rec_csr.plan_type_code;
          l_prim_amount_g := rec_csr.prim_amount_g;
          IF (NOT l_print_hdr1) THEN
            FII_UTIL.Write_Output ('   ');
          FII_MESSAGE.Write_Log (msg_name  => 'FII_MISS_TIME_FRC',
                                 token_num => 0);
          FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                                 token_num => 0);
            FII_MESSAGE.Write_Output
	         (msg_name	=> 'FII_MISS_TIME_FRC',
	          token_num	=> 0);
            FII_MESSAGE.Write_Output
	         (msg_name	=> 'FII_BUDGET_RECORD_TAB',
	          token_num	=> 0);
            l_print_hdr1 := TRUE;
          END IF;

          FII_UTIL.Write_Output (l_plan_code || '       ' || l_prim_amount_g);

          UPDATE FII_BUDGET_INTERFACE
             SET Status_Code = 'ERROR'
           WHERE CURRENT OF csr_null_time_3;
      End Loop;
    END IF;

    -----------------------------------------------------------------------
    -- 3. Validate that the time dimension provided in the interface table
    --    is valid in the global calendar and time granularity is at the
    --    same level as the profile
    -----------------------------------------------------------------------
    g_phase := 'Validate that all time unit references are valid';
    l_print_hdr1 := FALSE;
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Validate()',
           t2        => 'ACTION',
           v2        => 'Validating all time units specified...');
    END IF;

    l_sqlstmt := 'SELECT p1.report_time_period TIME ' ||
               'FROM (SELECT distinct report_time_period ' ||
	       '        FROM FII_BUDGET_INTERFACE' ||
	        '       WHERE report_time_period is not NULL';

    IF (FIIBUUP_BUDGET_TIME_UNIT = FIIBUUP_FORECAST_TIME_UNIT) THEN
      l_sqlstmt := l_sqlstmt || ' ) p1, ';
    ELSE
      l_sqlstmt := l_sqlstmt || ' AND plan_type_code = ''B'') p1, ';
    END IF;

    IF (FIIBUUP_BUDGET_TIME_UNIT = 'P') THEN
      l_sqlstmt := l_sqlstmt || 'FII_TIME_ENT_PERIOD b ';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Q') THEN
      l_sqlstmt := l_sqlstmt || 'FII_TIME_ENT_QTR b ';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Y') THEN
      l_sqlstmt := l_sqlstmt || 'FII_TIME_ENT_YEAR b ';
    END IF;

    l_sqlstmt := l_sqlstmt ||
              'WHERE b.name(+) = p1.report_time_period ' ||
	      'AND b.rowid is NULL ';

    l_sqlstmt := l_sqlstmt || 'ORDER BY TIME';

    -- Print out the dynamic SQL statement if running in debug mode
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Validate()',
         t2        	=> 'VARIABLE',
         v2        	=> 'l_sqlstmt',
         t3        	=> 'VALUE',
         v3        	=> l_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Validate()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_sqlstmt)));
    END IF;

    IF (NOT l_timeUnitCursor%ISOPEN) THEN
      OPEN l_timeUnitCursor FOR l_sqlstmt;
    END IF;

    LOOP
      FETCH l_timeUnitCursor INTO l_time_unit;
      EXIT WHEN l_timeUnitCursor%NOTFOUND;

      l_violations_found := TRUE;

      IF (NOT l_print_hdr1) THEN
        FII_UTIL.Write_Output ('   ');
        FII_MESSAGE.Write_Log (msg_name  => 'FII_INV_RPT_TIME_BUD',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
        FII_MESSAGE.Write_Output
	  (msg_name	=> 'FII_INV_RPT_TIME_BUD',
	   token_num	=> 0);
	l_print_hdr1 := TRUE;
      END IF;


      -- Print out individual invalid reporting time period
      FII_MESSAGE.Write_Output
	  (msg_name	=> 'FII_TIM_PRD',
	   token_num	=> 1,
	   t1		=> 'TIME_PERIOD',
	   v1		=> l_time_unit);

      --Update the Status_Code to 'ERROR'

        Update FII_BUDGET_INTERFACE
           Set Status_Code = 'ERROR'
         Where report_time_period = l_time_unit;

    END LOOP;

    CLOSE l_timeUnitCursor;
    l_sqlstmt := NULL;
    l_print_hdr1 := FALSE;

    -- Build the another statement to verify forecast time periods
    -- if profile setting for
    -- forecast is different from that for budget
    IF (FIIBUUP_BUDGET_TIME_UNIT <> FIIBUUP_FORECAST_TIME_UNIT) THEN

      l_sqlstmt := 'SELECT p2.report_time_period TIME ' ||
                 'FROM (SELECT distinct report_time_period ' ||
	         '        FROM FII_BUDGET_INTERFACE ' ||
		 '       WHERE report_time_period is not NULL ' ||
                 '         AND plan_type_code = ''F'') p2, ';

      IF (FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
        l_sqlstmt := l_sqlstmt || 'FII_TIME_ENT_PERIOD f ';
      ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
        l_sqlstmt := l_sqlstmt || 'FII_TIME_ENT_QTR f ';
      ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Y') THEN
        l_sqlstmt := l_sqlstmt || 'FII_TIME_ENT_YEAR f ';
      END IF;

      l_sqlstmt := l_sqlstmt ||
                'WHERE f.name(+) = p2.report_time_period ' ||
		'AND f.rowid is NULL ';

      l_sqlstmt := l_sqlstmt || 'ORDER BY TIME';

      -- Print out the dynamic SQL statement if running in debug mode
      IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  	=> 'FII_ROUTINE_VAL',
           token_num 	=> 3 ,
           t1        	=> 'ROUTINE',
           v1        	=> 'FII_BUDGET_FORECAST_C.Validate()',
           t2        	=> 'VARIABLE',
           v2        	=> 'l_sqlstmt',
           t3        	=> 'VALUE',
           v3        	=> l_sqlstmt);

        FII_MESSAGE.Write_Log
	  (msg_name  	=> 'FII_ROUTINE_VAL',
           token_num 	=> 3 ,
           t1        	=> 'ROUTINE',
           v1        	=> 'FII_BUDGET_FORECAST_C.Validate()',
           t2        	=> 'VARIABLE',
           v2        	=> 'LENGTH(l_sqlstmt)',
           t3        	=> 'VALUE',
           v3        	=> TO_CHAR(LENGTH(l_sqlstmt)));
      END IF;

      IF (NOT l_timeUnitCursor%ISOPEN) THEN
        OPEN l_timeUnitCursor FOR l_sqlstmt;
      END IF;

      LOOP
        FETCH l_timeUnitCursor INTO l_time_unit;
        EXIT WHEN l_timeUnitCursor%NOTFOUND;

        l_violations_found := TRUE;

        -- Print header information to output file.
    	IF (NOT l_print_hdr1) THEN
          FII_UTIL.Write_Output ('   ');
          FII_MESSAGE.Write_Log (msg_name  => 'FII_INV_RPT_TIME_FRC',
                                 token_num => 0);
          FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                                 token_num => 0);
	  FII_MESSAGE.Write_Output
	    (msg_name	=> 'FII_INV_RPT_TIME_FRC',
	     token_num	=> 0);
	  l_print_hdr1 := TRUE;
        END IF;

        -- Print out individual invalid reporting time period
        FII_MESSAGE.Write_Output
	  (msg_name	=> 'FII_TIM_PRD',
	   token_num	=> 1,
	   t1		=> 'TIME_PERIOD',
	   v1		=> l_time_unit);

        --Update the Status_Code to 'ERROR'
          Update FII_BUDGET_INTERFACE
             Set Status_Code = 'ERROR'
           Where report_time_period = l_time_unit;

      END LOOP;

      CLOSE l_timeUnitCursor;
      l_sqlstmt := NULL;
      l_print_hdr1 := FALSE;
      l_print_hdr2 := FALSE;

    END IF;

    -----------------------------------------------------------------------
    -- Validate that ledger information is provided
    -----------------------------------------------------------------------
    g_phase := 'Validate ledger';
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Validate()',
           t2        => 'ACTION',
           v2        => 'Validating all ledger is specified ...');
    END IF;

    --Check if ledger/ledger_id is null
    FOR rec_csr IN csr_null_ledger_id LOOP
      l_plan_code     := rec_csr.plan_type_code;
      l_prim_amount_g := rec_csr.prim_amount_g;
      IF (NOT l_print_hdr1) THEN
        FII_UTIL.Write_Output ('   ');
        FII_MESSAGE.Write_Log (msg_name  => 'FII_MISS_LEDGER_ID_BUD',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
        FII_MESSAGE.Write_Output
	     (msg_name	=> 'FII_MISS_LEDGER_ID_BUD',
	      token_num	=> 0);

        FII_MESSAGE.Write_Output
             (msg_name	=> 'FII_BUDGET_RECORD_TAB',
	      token_num	=> 0);
        l_print_hdr1 := TRUE;
      END IF;

      FII_UTIL.Write_Output (l_plan_code || '       ' || l_prim_amount_g);

      UPDATE FII_BUDGET_INTERFACE
      SET    status_code = 'ERROR'
      WHERE  CURRENT OF csr_null_ledger_id;
    END LOOP;
    l_print_hdr1 := FALSE;

    -----------------------------------------------------------------------
    -- 4. Validate that company information is provided
    -----------------------------------------------------------------------
    g_phase := 'Validate company id';
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Validate()',
           t2        => 'ACTION',
           v2        => 'Validating all company specified and valid...');
    END IF;

    --Check if company_id is null
    FOR rec_csr IN csr_null_com_id LOOP
      l_plan_code     := rec_csr.plan_type_code;
      l_prim_amount_g := rec_csr.prim_amount_g;
      IF (NOT l_print_hdr1) THEN
        FII_UTIL.Write_Output ('   ');
        FII_MESSAGE.Write_Log (msg_name  => 'FII_MISS_CO_ID_BUD',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
        FII_MESSAGE.Write_Output
	     (msg_name	=> 'FII_MISS_CO_ID_BUD',
	      token_num	=> 0);

        FII_MESSAGE.Write_Output
             (msg_name	=> 'FII_BUDGET_RECORD_TAB',
	      token_num	=> 0);
        l_print_hdr1 := TRUE;
      END IF;

      FII_UTIL.Write_Output (l_plan_code || '       ' || l_prim_amount_g);

      UPDATE FII_BUDGET_INTERFACE
      SET    status_code = 'ERROR'
      WHERE  CURRENT OF csr_null_com_id;
    END LOOP;
    l_print_hdr1 := FALSE;

    -----------------------------------------------------------------------
    -- 5. Validate that cost center information is provided
    -----------------------------------------------------------------------
    g_phase := 'Validate cost center id';
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Validate()',
           t2        => 'ACTION',
           v2        => 'Validating all cost center specified and valid...');
    END IF;

    --Check if cost_center_id is null
    FOR rec_csr IN csr_null_cc_id LOOP
      l_plan_code     := rec_csr.plan_type_code;
      l_prim_amount_g := rec_csr.prim_amount_g;
      IF (NOT l_print_hdr1) THEN
        FII_UTIL.Write_Output ('   ');
        FII_MESSAGE.Write_Log (msg_name  => 'FII_MISS_CC_ID_BUD',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
        FII_MESSAGE.Write_Output
	     (msg_name	=> 'FII_MISS_CC_ID_BUD',
	      token_num	=> 0);

        FII_MESSAGE.Write_Output
             (msg_name	=> 'FII_BUDGET_RECORD_TAB',
	      token_num	=> 0);
        l_print_hdr1 := TRUE;
      END IF;

      FII_UTIL.Write_Output (l_plan_code || '       ' || l_prim_amount_g);

      UPDATE FII_BUDGET_INTERFACE
      SET    status_code = 'ERROR'
      WHERE  CURRENT OF csr_null_cc_id;
    END LOOP;

    l_print_hdr1 := FALSE;

    -----------------------------------------------------------------------
    -- 6. Validate that fin cat ID is provided
    -----------------------------------------------------------------------
    -- Validate fin category id
    g_phase := 'Validate fin category id';
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Validate()',
           t2        => 'ACTION',
           v2        => 'Validating all financial category specified...');
    END IF;

    --Check if fin_category_id is null
    FOR rec_csr IN csr_null_fin_cat_id LOOP
      l_plan_code     := rec_csr.plan_type_code;
      l_prim_amount_g := rec_csr.prim_amount_g;
      IF (NOT l_print_hdr1) THEN
        FII_UTIL.Write_Output ('   ');
        FII_MESSAGE.Write_Log (msg_name  => 'FII_MISS_FIN_CAT_ID_BUD',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
        FII_MESSAGE.Write_Output
	     (msg_name	=> 'FII_MISS_FIN_CAT_ID_BUD',
	      token_num	=> 0);

        FII_MESSAGE.Write_Output
             (msg_name	=> 'FII_BUDGET_RECORD_TAB',
	      token_num	=> 0);
        l_print_hdr1 := TRUE;
      END IF;

      FII_UTIL.Write_Output (l_plan_code || '       ' || l_prim_amount_g);

      UPDATE FII_BUDGET_INTERFACE
         SET Status_Code = 'ERROR'
       WHERE CURRENT OF csr_null_fin_cat_id;
    End Loop;
    l_print_hdr1 := FALSE;

    -----------------------------------------------------------------------
    -- We have validated that company, cost center and fin category
    -- ID or values are provided.  Now do value to ID conversion for
    -- all dimension values.
    -----------------------------------------------------------------------
    g_phase := 'Value to ID conversion';

    -- Bug fix 4943332: Changed to return 1 if any error row exists
    BEGIN
      SELECT 1
      INTO l_err_count
      FROM FII_BUDGET_INTERFACE
      WHERE status_code = 'ERROR'
	  AND rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_err_count := 0;
    END;

    IF (l_err_count > 0) THEN
      FII_MESSAGE.Write_Log (msg_name  => 'FII_MISS_MANDATORY_DIM',
                             token_num => 0);
      raise FIIBUUP_fatal_err;
    END IF;

    IF(NOT FII_BUDGET_FORECAST_C.Id_Convert) THEN
      raise FIIBUUP_fatal_err;
    END IF;

    -----------------------------------------------------------------------
    --   Validate that ledger is defined as leaf nodes in vs setup in FDS
    -----------------------------------------------------------------------
    g_phase := 'Validate ledger id are valid';
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Validate()',
           t2        => 'ACTION',
           v2        => 'Validating all ledger specified are valid...');
    END IF;

    -- Validates that all ledger IDs are defined
    FOR rec_csr IN ledgerCursor LOOP
      l_ledger_id := rec_csr.ledger_id;
      l_ledger    := rec_csr.ledger;
      l_violations_found := TRUE;

      -- print header information into output file
      IF (NOT l_print_hdr1) THEN
        FII_UTIL.Write_Output ('   ');
        FII_MESSAGE.Write_Log (msg_name  => 'FII_INV_LEDGER_ID_DATA',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
	FII_MESSAGE.Write_Output
	  (msg_name	=> 'FII_INV_LEDGER_ID_DATA',
	   token_num	=> 0);

	l_print_hdr1 := TRUE;
      END IF;

      -- print out individual invalid ledger id
      FII_UTIL.Write_Output (l_ledger_id || '  ' || l_ledger);

      UPDATE FII_BUDGET_INTERFACE
      SET    status_code = 'ERROR'
      WHERE CURRENT OF ledgerCursor;

    END LOOP;
    l_print_hdr1 := FALSE;

    -----------------------------------------------------------------------
    --   Validate that company is defined as leaf nodes in vs setup in FDS
    -----------------------------------------------------------------------
    g_phase := 'Validate company id are valid';
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Validate()',
           t2        => 'ACTION',
           v2        => 'Validating all company specified are valid...');
    END IF;

    -- Validates that all company IDs are defined
    FOR rec_csr IN comCursor LOOP
      l_com_id := rec_csr.company_id;
      l_com    := rec_csr.company;
      l_violations_found := TRUE;

      -- print header information into output file
      IF (NOT l_print_hdr1) THEN
        FII_UTIL.Write_Output ('   ');
        FII_MESSAGE.Write_Log (msg_name  => 'FII_INV_CO_ID_DATA',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
	FII_MESSAGE.Write_Output
	  (msg_name	=> 'FII_INV_CO_ID_DATA',
	   token_num	=> 0);

	l_print_hdr1 := TRUE;
      END IF;

      -- print out individual invalid company id
      FII_UTIL.Write_Output (l_com_id || '  ' || l_com);

      UPDATE FII_BUDGET_INTERFACE
      SET    status_code = 'ERROR'
      WHERE CURRENT OF comCursor;

    END LOOP;
    l_print_hdr1 := FALSE;

    -----------------------------------------------------------------------
    --    Validate that cost center is defined as leaf nodes in vs setup in FDS
    -----------------------------------------------------------------------
    g_phase := 'Validate cost center are valid';
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Validate()',
           t2        => 'ACTION',
           v2        => 'Validating all cost center specified are valid...');
    END IF;

    -- Validates that all cost center IDs are defined
    FOR rec_csr IN ccCursor LOOP
      l_cc_id := rec_csr.cost_center_id;
      l_cc    := rec_csr.cost_center;
      l_violations_found := TRUE;

      -- print header information into output file
      IF (NOT l_print_hdr1) THEN
        FII_UTIL.Write_Output ('   ');
        FII_MESSAGE.Write_Log (msg_name  => 'FII_INV_CC_ID_DATA',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
	FII_MESSAGE.Write_Output
	  (msg_name	=> 'FII_INV_CC_ID_DATA',
	   token_num	=> 0);

	l_print_hdr1 := TRUE;
      END IF;

      -- print out individual invalid cost center id
      FII_UTIL.Write_Output (l_cc_id || '  ' || l_cc);

      UPDATE FII_BUDGET_INTERFACE
      SET    status_code = 'ERROR'
      WHERE CURRENT OF ccCursor;

    END LOOP;
    l_print_hdr1 := FALSE;

    -----------------------------------------------------------------------
    -- Validates that all financial categories are defined
    -----------------------------------------------------------------------
    g_phase := 'Validate financial categories are valid';
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Validate()',
           t2        => 'ACTION',
           v2        => 'Validating all financial categories specified are valid...');
    END IF;

    FOR rec_csr IN fincatCursor LOOP
      l_fin_cat_id := rec_csr.fin_category_id;
      l_fin_item   := rec_csr.fin_item;
      l_violations_found := TRUE;

      -- print header information into output file
      IF (NOT l_print_hdr1) THEN
        FII_UTIL.Write_Output ('   ');
        FII_MESSAGE.Write_Log (msg_name  => 'FII_INV_FIN_CAT_ID_DATA',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
	FII_MESSAGE.Write_Output
	  (msg_name	=> 'FII_INV_FIN_CAT_ID_DATA',
	   token_num	=> 0);

	l_print_hdr1 := TRUE;
      END IF;

      -- print out individual invalid financial category id
      FII_UTIL.Write_Output (l_fin_cat_id || '  ' || l_fin_item);

       UPDATE FII_BUDGET_INTERFACE
       SET    status_code = 'ERROR'
       WHERE CURRENT OF fincatCursor;

    END LOOP;
    l_print_hdr1 := FALSE;

    -----------------------------------------------------------------------
    -- 7. Validate that prod category ID is provided and is valid
    -----------------------------------------------------------------------
    -- Validates that all product categories are defined
    g_phase := 'Validates that all product categories are defined (1)';

    -- Check if product category dimension is enabled or not.
    SELECT DBI_ENABLED_FLAG
    INTO   l_pcat_enabled_flag
    FROM   FII_FINANCIAL_DIMENSIONS
    WHERE  dimension_short_name = 'ENI_ITEM_VBH_CAT';

    IF (l_pcat_enabled_flag = 'Y') THEN
      SELECT structure_id INTO p_mtc_structure_id
      FROM   MTL_CATEGORY_SETS_VL
      WHERE  category_set_id = ENI_DENORM_HRCHY.get_category_set_id;

      g_phase := 'Validates that all product categories are defined (2)';
      FOR rec_csr IN prodCursor LOOP
        l_prod_cat_id := rec_csr.prod_category_id;
        l_prod_code   := rec_csr.product_code;
        l_violations_found := TRUE;

        -- print header information into output file
        IF (NOT l_print_hdr1) THEN
          FII_UTIL.Write_Output ('   ');
          FII_MESSAGE.Write_Log (msg_name  => 'FII_INV_PROD_CAT_ID_DATA',
                                 token_num => 0);
          FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                                 token_num => 0);
	  FII_MESSAGE.Write_Output
	    (msg_name	=> 'FII_INV_PROD_CAT_ID_DATA',
  	     token_num	=> 0);

  	l_print_hdr1 := TRUE;
        END IF;

        -- print out individual invalid product category id
        FII_UTIL.Write_Output (l_prod_cat_id || '       ' || l_prod_code);

         UPDATE FII_BUDGET_INTERFACE
         SET Status_Code = 'ERROR'
         WHERE CURRENT OF prodCursor;

      END LOOP;
      l_print_hdr1 := FALSE;
    END IF;

    -----------------------------------------------------------------------
    -- 8. Validate that user defined dim1 is provided if udd1 enabled and
    --    it is valid in vs setup in FDS
    -----------------------------------------------------------------------
    -- Validate user_dim1_id
    g_phase := 'Validate user dimension 1 id';
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Validate()',
           t2        => 'ACTION',
           v2        => 'Validating all user defined dimension1 specified...');
    END IF;

    -- Validates that all user defined dimension 1 are defined
    FOR rec_csr IN udd1Cursor LOOP
      l_udd1_id := rec_csr.user_dim1_id;
      l_udd1    := rec_csr.user_dim1;
      l_violations_found := TRUE;

      -- print header information into output file
      IF (NOT l_print_hdr1) THEN
        FII_UTIL.Write_Output ('   ');
        FII_MESSAGE.Write_Log (msg_name  => 'FII_INV_UDD1_ID_DATA',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
	FII_MESSAGE.Write_Output
	  (msg_name	=> 'FII_INV_UDD1_ID_DATA',
	   token_num	=> 0);

	l_print_hdr1 := TRUE;
      END IF;

      -- print out individual invalid user defined dimension 1 ID
      FII_UTIL.Write_Output (l_udd1_id || '  ' || l_udd1);

       UPDATE FII_BUDGET_INTERFACE
       SET    status_code = 'ERROR'
       WHERE CURRENT OF udd1Cursor;

    END LOOP;
    l_print_hdr1 := FALSE;

    -----------------------------------------------------------------------
    -- 9. Validate conversion rates is provided if only primary amount is given
    --    and primary and secondary currency are not the same.
    --    Also validate that conversion rates are positive and non-zero.
    -----------------------------------------------------------------------
    -- If the primary and secondary global currencies are different,
    -- validates all conversion rate information.
    g_phase := 'Validate currency rate';
    IF (FIIBUUP_PRIM_CURR_CODE <> FIIBUUP_SEC_CURR_CODE) THEN
      IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Validate()',
           t2        => 'ACTION',
           v2        => 'Validating required conversion rates...');
      END IF;

      --print out all records with bad conversion rate information
      For rec_csr IN rateCursor LOOP
        l_plan_code     := rec_csr.plan_type_code;
        l_prim_amount_g := rec_csr.prim_amount_g;
        IF (NOT l_print_hdr1) THEN
          FII_UTIL.Write_Output ('   ');
          FII_MESSAGE.Write_Log (msg_name  => 'FII_CUR_GLB_PRM',
                                 token_num => 0);
          FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                                 token_num => 0);
          FII_MESSAGE.Write_Output
        	     (msg_name	=> 'FII_CUR_GLB_PRM',
	              token_num	=> 0);
          FII_MESSAGE.Write_Output
               (msg_name	=> 'FII_BUDGET_RECORD_TAB',
	        token_num	=> 0);
          l_print_hdr1 := TRUE;
        END IF;

        FII_UTIL.Write_Output (l_plan_code || '       ' || l_prim_amount_g);

        UPDATE FII_BUDGET_INTERFACE
           SET Status_Code = 'ERROR'
         WHERE CURRENT OF rateCursor;
      End Loop;
      l_print_hdr1 := FALSE;

    END IF;

    -----------------------------------------------------------------------
    -- 10. Validate only one record exists for the time/dimension combination
    -----------------------------------------------------------------------
    g_phase := 'Validate duplicate records';
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Validate()',
           t2        => 'ACTION',
           v2        => 'Validating duplicate upload information...');
    END IF;

    IF (NOT dupRecordCursor%ISOPEN) THEN
      OPEN dupRecordCursor;
    END IF;

    LOOP
      FETCH dupRecordCursor INTO l_plan_code, l_ver_date, l_time_unit,
                                 l_ledger_id, l_com_id, l_cc_id, l_fin_cat_id,
                                 l_prod_cat_id, l_udd1_id;
      EXIT WHEN dupRecordCursor%NOTFOUND;
      l_violations_found := TRUE;

      -- Print header information to output file.
      IF (l_plan_code = 'B' AND (NOT l_print_hdr1)) THEN
        FII_UTIL.Write_Output ('   ');
        FII_MESSAGE.Write_Log (msg_name  => 'FII_BUD_MLTP_REC',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
	FII_MESSAGE.Write_Output
	  (msg_name	=> 'FII_BUD_MLTP_REC',
	   token_num	=> 0);

	l_print_hdr1 := TRUE;
      ELSIF (l_plan_code = 'F' AND (NOT l_print_hdr2)) THEN
        FII_MESSAGE.Write_Log (msg_name  => 'FII_FRC_MLTP_REC',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
	FII_MESSAGE.Write_Output
	  (msg_name	=> 'FII_FRC_MLTP_REC',
	   token_num	=> 0);
	l_print_hdr2 := TRUE;
      END IF;

      -- Print out individual duplicate record
      FII_UTIL.Write_Output (l_ver_date       || '   ' ||
                             l_time_unit      || '   ' ||
                             l_ledger_id      || '   ' ||
                             l_com_id         || '   ' ||
                             l_cc_id          || '   ' ||
                             l_fin_cat_id     || '   ' ||
                             l_prod_cat_id    || '   ' ||
                             l_udd1_id);

      --Update the Status_Code
      UPDATE FII_BUDGET_INTERFACE
      SET    status_code = 'ERROR'
      WHERE plan_type_code              = l_plan_code
      AND   ledger_id                   = l_ledger_id
      AND   company_id                  = l_com_id
      AND   cost_center_id              = l_cc_id
      AND   fin_category_id             = l_fin_cat_id
      AND   nvl(prod_category_id, -999) = nvl(l_prod_cat_id, -999)
      AND   user_dim1_id                = l_udd1_id;

    END LOOP;
    CLOSE dupRecordCursor;
    l_print_hdr1 := FALSE;
    l_print_hdr2 := FALSE;

    -----------------------------------------------------------------------
    -- 11. Validate version date is equal to or greater than global start date.
    --     Also validate that it is greater than or equal to the latest version
    --     date for the period/dimension combination.
    -----------------------------------------------------------------------
    g_phase := 'Validate version dates';
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Validate()',
           t2        => 'ACTION',
           v2        => 'Validating version dates...');
    END IF;

    IF (FIIBUUP_BUDGET_TIME_UNIT = 'P' OR FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
     OPEN verDateCursorPer;
     LOOP
      FETCH verDateCursorPer INTO l_plan_code, l_ver_date, l_time_unit,
                               l_ledger_id, l_com_id, l_cc_id, l_fin_cat_id,
                               l_prod_cat_id, l_udd1_id;
      EXIT WHEN verDateCursorPer%NOTFOUND;
      l_violations_found := TRUE;

      -- Print header information to output file.
      IF (l_plan_code = 'B' AND (NOT l_print_hdr1)) THEN
        FII_UTIL.Write_Output ('   ');
        FII_MESSAGE.Write_Log (msg_name  => 'FII_BUD_INV_VER_DATE',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
	FII_MESSAGE.Write_Output
	  (msg_name	=> 'FII_BUD_INV_VER_DATE',
	   token_num	=> 0);

	l_print_hdr1 := TRUE;
      ELSIF (l_plan_code = 'F' AND (NOT l_print_hdr2)) THEN
        FII_MESSAGE.Write_Log (msg_name  => 'FII_FRC_INV_VER_DATE',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
	FII_MESSAGE.Write_Output
	  (msg_name	=> 'FII_FRC_INV_VER_DATE',
	   token_num	=> 0);
	l_print_hdr2 := TRUE;
      END IF;

      -- Print out individual record with invalid version date
      FII_UTIL.Write_Output (l_ver_date       || '   ' ||
                             l_time_unit      || '   ' ||
                             l_ledger_id      || '   ' ||
                             l_com_id         || '   ' ||
                             l_cc_id          || '   ' ||
                             l_fin_cat_id     || '   ' ||
                             l_prod_cat_id    || '   ' ||
                             l_udd1_id);

      --Update the Status_Code
      UPDATE FII_BUDGET_INTERFACE
      SET    status_code = 'ERROR'
      WHERE plan_type_code              = l_plan_code
      AND   trunc(version_date)         = trunc(l_ver_date)
      AND   report_time_period          = l_time_unit
      AND   ledger_id                   = l_ledger_id
      AND   company_id                  = l_com_id
      AND   cost_center_id              = l_cc_id
      AND   fin_category_id             = l_fin_cat_id
      AND   nvl(prod_category_id, -999) = nvl(l_prod_cat_id, -999)
      AND   user_dim1_id                = l_udd1_id;

     END LOOP;
     CLOSE verDateCursorPer;
    END IF;

    IF (FIIBUUP_BUDGET_TIME_UNIT = 'Q' OR FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
     OPEN verDateCursorQtr;
     LOOP
      FETCH verDateCursorQtr INTO l_plan_code, l_ver_date, l_time_unit,
                               l_ledger_id, l_com_id, l_cc_id, l_fin_cat_id,
                               l_prod_cat_id, l_udd1_id;
      EXIT WHEN verDateCursorQtr%NOTFOUND;
      l_violations_found := TRUE;

      -- Print header information to output file.
      IF (l_plan_code = 'B' AND (NOT l_print_hdr1)) THEN
        FII_UTIL.Write_Output ('   ');
        FII_MESSAGE.Write_Log (msg_name  => 'FII_BUD_INV_VER_DATE',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
	FII_MESSAGE.Write_Output
	  (msg_name	=> 'FII_BUD_INV_VER_DATE',
	   token_num	=> 0);

	l_print_hdr1 := TRUE;
      ELSIF (l_plan_code = 'F' AND (NOT l_print_hdr2)) THEN
        FII_MESSAGE.Write_Log (msg_name  => 'FII_FRC_INV_VER_DATE',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
	FII_MESSAGE.Write_Output
	  (msg_name	=> 'FII_FRC_INV_VER_DATE',
	   token_num	=> 0);
	l_print_hdr2 := TRUE;
      END IF;

      -- Print out individual record with invalid version date
      FII_UTIL.Write_Output (l_ver_date       || '   ' ||
                             l_time_unit      || '   ' ||
                             l_ledger_id      || '   ' ||
                             l_com_id         || '   ' ||
                             l_cc_id          || '   ' ||
                             l_fin_cat_id     || '   ' ||
                             l_prod_cat_id    || '   ' ||
                             l_udd1_id);

      --Update the Status_Code
      UPDATE FII_BUDGET_INTERFACE
      SET    status_code = 'ERROR'
      WHERE plan_type_code              = l_plan_code
      AND   trunc(version_date)         = trunc(l_ver_date)
      AND   report_time_period          = l_time_unit
      AND   ledger_id                   = l_ledger_id
      AND   company_id                  = l_com_id
      AND   cost_center_id              = l_cc_id
      AND   fin_category_id             = l_fin_cat_id
      AND   nvl(prod_category_id, -999) = nvl(l_prod_cat_id, -999)
      AND   user_dim1_id                = l_udd1_id;

     END LOOP;
     CLOSE verDateCursorQtr;
    END IF;

    IF (FIIBUUP_BUDGET_TIME_UNIT = 'Y' OR FIIBUUP_FORECAST_TIME_UNIT = 'Y') THEN
     OPEN verDateCursorYr;
     LOOP
      FETCH verDateCursorYr INTO l_plan_code, l_ver_date, l_time_unit,
                               l_ledger_id, l_com_id, l_cc_id, l_fin_cat_id,
                               l_prod_cat_id, l_udd1_id;
      EXIT WHEN verDateCursorYr%NOTFOUND;
      l_violations_found := TRUE;

      -- Print header information to output file.
      IF (l_plan_code = 'B' AND (NOT l_print_hdr1)) THEN
        FII_UTIL.Write_Output ('   ');
        FII_MESSAGE.Write_Log (msg_name  => 'FII_BUD_INV_VER_DATE',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
	FII_MESSAGE.Write_Output
	  (msg_name	=> 'FII_BUD_INV_VER_DATE',
	   token_num	=> 0);

	l_print_hdr1 := TRUE;
      ELSIF (l_plan_code = 'F' AND (NOT l_print_hdr2)) THEN
        FII_MESSAGE.Write_Log (msg_name  => 'FII_FRC_INV_VER_DATE',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
	FII_MESSAGE.Write_Output
	  (msg_name	=> 'FII_FRC_INV_VER_DATE',
	   token_num	=> 0);
	l_print_hdr2 := TRUE;
      END IF;

      -- Print out individual record with invalid version date
      FII_UTIL.Write_Output (l_ver_date       || '   ' ||
                             l_time_unit      || '   ' ||
                             l_ledger_id      || '   ' ||
                             l_com_id         || '   ' ||
                             l_cc_id          || '   ' ||
                             l_fin_cat_id     || '   ' ||
                             l_prod_cat_id    || '   ' ||
                             l_udd1_id);

      --Update the Status_Code
      UPDATE FII_BUDGET_INTERFACE
      SET    status_code = 'ERROR'
      WHERE plan_type_code              = l_plan_code
      AND   trunc(version_date)         = trunc(l_ver_date)
      AND   report_time_period          = l_time_unit
      AND   ledger_id                   = l_ledger_id
      AND   company_id                  = l_com_id
      AND   cost_center_id              = l_cc_id
      AND   fin_category_id             = l_fin_cat_id
      AND   nvl(prod_category_id, -999) = nvl(l_prod_cat_id, -999)
      AND   user_dim1_id                = l_udd1_id;

     END LOOP;
     CLOSE verDateCursorYr;
    END IF;

    -- We need to commit here for status_code
    FND_CONCURRENT.Af_Commit;

    -- Bug fix 4943332: Changed to return 1 if any error row exists
    BEGIN
      SELECT 1
      INTO l_count
      FROM FII_BUDGET_INTERFACE
      WHERE status_code = 'ERROR'
	  AND rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_count := 0;
    END;

    IF l_count > 0 THEN
      FII_UTIL.Write_Log ('There is invalid data in the interface table...');
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.Validate');
      retcode := 'E';
      RETURN;
    END IF;

    -- All validations have passed, return with success.
    IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Validate()',
           t2        => 'ACTION',
           v2        => 'All validations completed successfully...');
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.Validate');
    END IF;
    RETURN;

  -- Exception handling
  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.Validate()');

      FII_MESSAGE.Func_Fail
	(func_name =>'FII_BUDGET_FORECAST_C.Validate');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      retcode := 'E';
      RETURN;

    WHEN OTHERS THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERROR',
         token_num => 2,
         t1        => 'FUNCTION',
         v1        => 'FII_BUDGET_FORECAST_C.Validate()',
         t2        => 'SQLERRMC',
         v2        => SQLERRM);

      FII_MESSAGE.Func_Fail
	  (func_name	=> 'FII_BUDGET_FORECAST_C.Validate');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      retcode := 'E';
      RETURN;
  END Validate;

-------------------------------------------------------------------------------
  --
  -- Procedure
  --    Prior_version
  --
  -- Purpose
  --   	Given the version_date in the parameter, this procedure will determine
  --    the type of data we have in the interface table and assign a data_type
  --    to the row for further processing.  If we have a prior version for the
  --    period/dimension combination, the procedure also find out the latest
  --    version of such combination in the base table and store it in the
  --    prior_version_date column.
  --
  -- Arguments
  --    version_date
  -- Example
  --    result := FII_BUDGET_FORECAST_C.Prior_version(version_date);
  -- Notes
  --	Returns a boolean indicating if execution completes successfully
  FUNCTION Prior_version (version_date DATE) RETURN BOOLEAN IS
    FIIBUUP_fatal_err		EXCEPTION;
    l_tmpstmt			VARCHAR2(1000);
    l_bud_sqlstmt		VARCHAR2(32000);
    l_fc_sqlstmt		VARCHAR2(32000);
    l_bud_join_col_name		VARCHAR2(30) := NULL;
    l_fc_join_col_name		VARCHAR2(30) := NULL;
    l_bud_time_tab_name         VARCHAR2(30) := NULL;
    l_fc_time_tab_name          VARCHAR2(30) := NULL;

  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent(
          'FII_BUDGET_FORECAST_C.Prior_version - version_date = ' ||
          version_date);
    END IF;

    -- Determine which time column should be used
    IF (FIIBUUP_BUDGET_TIME_UNIT = 'P') THEN
      l_bud_join_col_name := 'ent_period_id ';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Q') THEN
      l_bud_join_col_name := 'ent_qtr_id ';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Y') THEN
      l_bud_join_col_name := 'ent_year_id ';
    END IF;

    IF (FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
      l_fc_join_col_name := 'ent_period_id ';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
      l_fc_join_col_name := 'ent_qtr_id ';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Y') THEN
      l_fc_join_col_name := 'ent_year_id ';
    END IF;

    -- Determine which time table should be used
    IF (FIIBUUP_BUDGET_TIME_UNIT = 'P') THEN
      l_bud_time_tab_name := 'FII_TIME_ENT_PERIOD t';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Q') THEN
      l_bud_time_tab_name := 'FII_TIME_ENT_QTR t';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Y') THEN
      l_bud_time_tab_name := 'FII_TIME_ENT_YEAR t';
    END IF;

    IF (FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
      l_fc_time_tab_name := 'FII_TIME_ENT_PERIOD t';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
      l_fc_time_tab_name := 'FII_TIME_ENT_QTR t';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Y') THEN
      l_fc_time_tab_name := 'FII_TIME_ENT_YEAR t';
    END IF;

    -- The statment for prior_version needs to be built dynamically
    -- because of the variable time period involved.
    g_phase := 'Build the SQL statement';

    -- Start building the SQL statement
    l_tmpstmt := 'INSERT INTO FII_BUDGET_DELTAS ' ||
	       ' (plan_type_code, version_date, time_id, '||
               '  ledger_id, company_id, '||
               '  cost_center_id, fin_category_id, prod_category_id, '||
               '  user_dim1_id, data_type, '||
               '  prior_version_date, orig_prim_amount_total, '||
               '  orig_prim_amount_g, orig_sec_amount_total, '||
               '  orig_sec_amount_g, last_update_date, last_updated_by, '||
               '  creation_date, created_by, last_update_login ) '||

----------------------------------------------------------------------------
-- Case 1: Version date is provided and time/dimension combination does not
--         exist in base table.
----------------------------------------------------------------------------
               'SELECT '||
               '  bi.plan_type_code, trunc(bi.version_date), ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || 't.' ||
                     l_bud_join_col_name || ', ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || 't.' ||
                     l_fc_join_col_name  || ', ';

    l_tmpstmt := '  bi.ledger_id, bi.company_id, bi.cost_center_id, ' ||
               '  bi.fin_category_id, bi.prod_category_id, '||
               '  bi.user_dim1_id, -1, NULL, '||
               '  NULL, NULL, NULL, NULL, '||
               '  SYSDATE, :user_id, SYSDATE, :user_id, :login_id '||
               'FROM FII_BUDGET_INTERFACE bi, ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || l_bud_time_tab_name;
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || l_fc_time_tab_name;

    l_tmpstmt := ' WHERE trunc(bi.version_date) = trunc(:version_date) ' ||
                'AND   bi.report_time_period  = t.name '||
                'AND   NOT EXISTS ('||
                         'SELECT 1 '||
                         'FROM   FII_BUDGET_BASE bb, ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || l_bud_time_tab_name || '2 ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || l_fc_time_tab_name || '2 ';

    l_tmpstmt := ' WHERE bi.plan_type_code = bb.plan_type_code '||
               ' AND   bi.report_time_period = t2.name ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                   ' AND t2.' || l_bud_join_col_name || '= bb.time_id ';

    l_fc_sqlstmt  := l_fc_sqlstmt || l_tmpstmt ||
                   ' AND t2.' || l_fc_join_col_name || '= bb.time_id ';

    l_tmpstmt := 'AND   bi.ledger_id = bb.ledger_id '||
               'AND   bi.company_id = bb.company_id '||
               'AND   bi.cost_center_id = bb.cost_center_id '||
               'AND   bi.fin_category_id = bb.fin_category_id '||
               'AND   NVL(bi.prod_category_id, 0) = NVL(bb.category_id, 0) '||
               'AND   bi.user_dim1_id    = bb.user_dim1_id) ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                   ' AND  bi.plan_type_code = ''B'' ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt ||
                   ' AND  bi.plan_type_code = ''F'' ';

----------------------------------------------------------------------
-- Case 2: When version_date in interface > version_date in base
--         and the same version_date does not exist in base
----------------------------------------------------------------------
    l_tmpstmt := ' UNION ALL ' ||
               ' SELECT bi.plan_type_code, trunc(bi.version_date), ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || 't.' ||
                     l_bud_join_col_name ||', ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || 't.' ||
                     l_fc_join_col_name  ||', ';

    l_tmpstmt := ' bi.ledger_id, '||
               ' bi.company_id, bi.cost_center_id, bi.fin_category_id, '||
               ' bi.prod_category_id, bi.user_dim1_id, '||
               ' -2, max(bb.version_date), NULL, NULL, NULL, NULL, '||
               ' SYSDATE, :user_id, SYSDATE, :user_id, :login_id '||
               ' FROM FII_BUDGET_INTERFACE bi, '||
                    ' FII_BUDGET_BASE bb, ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || l_bud_time_tab_name;
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || l_fc_time_tab_name;

    l_tmpstmt := ' WHERE trunc(bi.version_date) = trunc(:version_date) '||
                'AND   bi.report_time_period = t.name ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                   ' AND t.' || l_bud_join_col_name || '= bb.time_id ';
    l_fc_sqlstmt  := l_fc_sqlstmt || l_tmpstmt ||
                   ' AND t.' || l_fc_join_col_name  || '= bb.time_id ';

    l_tmpstmt := 'AND bb.version_date < trunc(bi.version_date) '||
               'AND bb.no_version_flag = ''N'' ' ||
               'AND NOT EXISTS ( '||
                        'SELECT 1 '||
                        'FROM FII_BUDGET_BASE bb2, ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || l_bud_time_tab_name || '2 ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || l_fc_time_tab_name || '2 ';

    l_tmpstmt := 'WHERE trunc(bi.version_date) = trunc(:version_date) '||
               'AND   bi.plan_type_code = bb2.plan_type_code ' ||
               'AND   bi.report_time_period = t2.name ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                   ' AND t2.' || l_bud_join_col_name || '= bb2.time_id ';
    l_fc_sqlstmt  := l_fc_sqlstmt || l_tmpstmt ||
                   ' AND t2.' || l_fc_join_col_name || '= bb2.time_id ';

    l_tmpstmt:= 'AND   bb2.version_date            = trunc(bi.version_date) '||
                 'AND   bb2.no_version_flag         = ''N'' '||
                 'AND   bi.ledger_id                = bb2.ledger_id '||
                 'AND   bi.company_id               = bb2.company_id '||
                 'AND   bi.cost_center_id           = bb2.cost_center_id '||
                 'AND   bi.fin_category_id          = bb2.fin_category_id '||
                 'AND   NVL(bi.prod_category_id,0) = NVL(bb2.category_id,0) '||
                 'AND   bi.user_dim1_id             = bb2.user_dim1_id) '||
               'AND   bi.plan_type_code            = bb.plan_type_code '||
               'AND   bi.ledger_id                 = bb.ledger_id '||
               'AND   bi.company_id                = bb.company_id '||
               'AND   bi.cost_center_id            = bb.cost_center_id '||
               'AND   bi.fin_category_id           = bb.fin_category_id '||
               'AND   NVL(bi.prod_category_id, 0) = NVL (bb.category_id, 0) '||
               'AND   bi.user_dim1_id              = bb.user_dim1_id ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                     'AND   bi.plan_type_code = ''B'' ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt ||
                     'AND   bi.plan_type_code = ''F'' ';

    l_tmpstmt := 'GROUP BY bi.plan_type_code, trunc(bi.version_date), ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || 't.' ||
                     l_bud_join_col_name || ', ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || 't.' ||
                     l_fc_join_col_name || ', ' ;

    l_tmpstmt :=  ' bi.fin_category_id, bi.ledger_id, bi.company_id, '||
                  ' bi.cost_center_id, '||
                  ' bi.prod_category_id, bi.user_dim1_id ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt;
    l_fc_sqlstmt  := l_fc_sqlstmt || l_tmpstmt;

----------------------------------------------------------------------
-- Case 3: Version date is provided and the same version/time/dimension
--         combination exists in base table with no_version_flag = 'N'.
--         Both records are updated on the same day.
----------------------------------------------------------------------
    l_tmpstmt := ' UNION ALL ' ||
               ' SELECT bi.plan_type_code, trunc(bi.version_date), ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || 't.' ||
                     l_bud_join_col_name ||', ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || 't.' ||
                     l_fc_join_col_name  ||', ';

    l_tmpstmt := ' bi.ledger_id, '||
               ' bi.company_id, bi.cost_center_id, bi.fin_category_id, '||
               ' bi.prod_category_id, bi.user_dim1_id, '||
               ' -3, NULL, bb.prim_amount_total, bb.prim_amount_g, '||
               ' bb.sec_amount_total, bb.sec_amount_g, '||
               ' SYSDATE, :user_id, SYSDATE, :user_id, :login_id '||
               ' FROM FII_BUDGET_INTERFACE bi, FII_BUDGET_BASE bb, ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || l_bud_time_tab_name;
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || l_fc_time_tab_name;

    l_tmpstmt := ' WHERE trunc(bi.version_date) = trunc(:version_date) '||
                'AND   bi.report_time_period = t.name ' ||
                'AND   bb.no_version_flag = ''N'' ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                   ' AND bb.time_id = t.' || l_bud_join_col_name ;
    l_fc_sqlstmt  := l_fc_sqlstmt || l_tmpstmt ||
                   ' AND bb.time_id = t.' || l_fc_join_col_name;

    l_tmpstmt := 'AND   bb.plan_type_code       = bi.plan_type_code ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                     'AND   bi.plan_type_code = ''B'' ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt ||
                     'AND   bi.plan_type_code = ''F'' ';

    l_tmpstmt := 'AND   bb.version_date         = trunc(bi.version_date) '||
               'AND   bb.ledger_id            = bi.ledger_id '||
               'AND   bb.company_id           = bi.company_id '||
               'AND   bb.cost_center_id       = bi.cost_center_id '||
               'AND   bb.fin_category_id      = bi.fin_category_id '||
               'AND   NVL(bb.category_id, 0)  = NVL(bi.prod_category_id, 0) '||
               'AND   bb.user_dim1_id         = bi.user_dim1_id '||
               'AND   bb.prim_amount_total   != bi.prim_amount_g '||
               'AND   nvl(bb.sec_amount_total,0) != nvl(bi.sec_amount_g,0) '||
               'AND   EXISTS ( '||
                -- Make sure the same version/time/dimension combination
                -- record was uploaded on the same date
                  'SELECT 1 '||
                  'FROM ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || l_bud_time_tab_name;
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || l_fc_time_tab_name;

    l_tmpstmt :=  ' WHERE bi.report_time_period = t.name ' ||
                  ' AND   bi.ledger_id = bb.ledger_id '||
                  ' AND   bi.company_id = bb.company_id '||
                  ' AND   bi.cost_center_id = bb.cost_center_id '||
                  ' AND   bi.fin_category_id = bb.fin_category_id '||
                  ' AND   NVL(bi.prod_category_id,0)=NVL(bb.category_id, 0) '||
                  ' AND   bi.user_dim1_id = bb.user_dim1_id ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                  ' AND t.' || l_bud_join_col_name || '= bb.time_id ' ||
                  ' AND   TRUNC(bi.upload_date) = TRUNC(bb.upload_date))';
    l_fc_sqlstmt  := l_fc_sqlstmt || l_tmpstmt ||
                  ' AND t.' || l_fc_join_col_name  || '= bb.time_id ' ||
                  ' AND   TRUNC(bi.upload_date) = TRUNC(bb.upload_date))';

----------------------------------------------------------------------------
-- Case 4: Version date is provided and time/dimension combination exists
--         in base table with no_version_flag = 'Y'
----------------------------------------------------------------------------
    l_tmpstmt := ' UNION ALL ' ||
               ' SELECT bi.plan_type_code, trunc(bi.version_date), ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || 't.' ||
                     l_bud_join_col_name ||', ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || 't.' ||
                     l_fc_join_col_name  ||', ';

    l_tmpstmt := ' bi.ledger_id, '||
               ' bi.company_id, bi.cost_center_id, bi.fin_category_id, '||
               ' bi.prod_category_id, bi.user_dim1_id, '||
               ' -4, bb2.version_date, bb2.prim_amount_total, '||
               ' bb2.prim_amount_g, '||
               ' bb2.sec_amount_total, bb2.sec_amount_g, '||
               ' SYSDATE, :user_id, SYSDATE, :user_id, :login_id '||
               ' FROM FII_BUDGET_INTERFACE bi, FII_BUDGET_BASE bb2, ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || l_bud_time_tab_name;
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || l_fc_time_tab_name;

    l_tmpstmt :=
    ',(SELECT v.name, v.plan_type_code, v.ledger_id, v.company_id, '||
            ' v.cost_center_id, v.fin_category_id, v.category_id, '||
            ' v.user_dim1_id, v.version_date '||
     ' FROM ( '||
      ' SELECT  t.name, bb.plan_type_code, bb.ledger_id, bb.company_id, '||
              ' bb.cost_center_id, bb.fin_category_id, bb.category_id, '||
              ' bb.user_dim1_id, bb.version_date, '||
              ' rank() over (partition by t.name, bb.plan_type_code, '||
                           ' bb.ledger_id, bb.company_id, '||
                           ' bb.cost_center_id,bb.fin_category_id, '||
                           ' bb.category_id, bb.user_dim1_id'||
                           ' order by bb.version_date desc) Rank '||
      ' FROM  FII_BUDGET_BASE bb, ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || l_bud_time_tab_name;
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || l_fc_time_tab_name;

    l_tmpstmt := ', fii_budget_interface bi '||
                 ' WHERE bi.report_time_period       = t.name '||
                 ' AND   bb.no_version_flag          = ''Y'' ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                   ' AND t.' || l_bud_join_col_name || '= bb.time_id ';
    l_fc_sqlstmt  := l_fc_sqlstmt || l_tmpstmt ||
                   ' AND t.' || l_fc_join_col_name || '= bb.time_id ';

    l_tmpstmt :=
      '   AND   bi.plan_type_code           = bb.plan_type_code '||
      '   AND   bi.ledger_id                = bb.ledger_id '||
      '   AND   bi.company_id               = bb.company_id '||
      '   AND   bi.cost_center_id           = bb.cost_center_id '||
      '   AND   bi.fin_category_id          = bb.fin_category_id '||
      '   AND   NVL(bi.prod_category_id, 0) = NVL(bb.category_id, 0) '||
      '   AND   NVL(bi.user_dim1_id, 0)     = NVL(bb.user_dim1_id, 0)) v '||
      ' WHERE v.rank = 1) cver '||
   ' WHERE trunc(bi.version_date) = trunc(:version_date) '||
   'AND   bi.report_time_period = t.name ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                   ' AND bb2.time_id = t.' || l_bud_join_col_name ;
    l_fc_sqlstmt  := l_fc_sqlstmt || l_tmpstmt ||
                   ' AND bb2.time_id = t.' || l_fc_join_col_name;

    l_tmpstmt :=  'AND   bb2.no_version_flag = ''Y'' '||
                'AND   bb2.plan_type_code          = bi.plan_type_code ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                     'AND   bi.plan_type_code = ''B'' ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt ||
                     'AND   bi.plan_type_code = ''F'' ';

    l_tmpstmt :=  'AND   bb2.ledger_id               = bi.ledger_id '||
                'AND   bb2.company_id              = bi.company_id '||
                'AND   bb2.cost_center_id          = bi.cost_center_id '||
                'AND   bb2.fin_category_id         = bi.fin_category_id '||
                'AND   NVL(bi.prod_category_id,0) = NVL(bb2.category_id, 0) '||
                'AND   bi.user_dim1_id             = bb2.user_dim1_id '||
                'AND   bb2.prim_amount_total      != bi.prim_amount_g '||
                'AND   nvl(bb2.sec_amount_total,0)!= nvl(bi.sec_amount_g,0) '||
                'AND   bi.report_time_period = cver.name '||
                'AND   bi.plan_type_code  = cver.plan_type_code '||
                'AND   bi.ledger_id      = cver.ledger_id '||
                'AND   bi.company_id      = cver.company_id '||
                'AND   bi.cost_center_id  = cver.cost_center_id '||
                'AND   bi.fin_category_id = cver.fin_category_id '||
                'AND   nvl(bi.prod_category_id, 0)=nvl(cver.category_id, 0) '||
                'AND   bi.user_dim1_id   = cver.user_dim1_id '||
                'AND   bb2.version_date   = cver.version_date ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt;
    l_fc_sqlstmt  := l_fc_sqlstmt || l_tmpstmt;

    -- Print out the dynamic SQL statements if running in debug mode
    IF (FIIBUUP_DEBUG) THEN
      fii_util.put_line('l_bud_sqlstmt = '|| l_bud_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Prior_version()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_bud_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_bud_sqlstmt)));

      fii_util.put_line('l_fc_sqlstmt = '|| l_fc_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Prior_version()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_fc_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_fc_sqlstmt)));
    END IF;

    -- Execute both statements for budget and forecast
    EXECUTE IMMEDIATE l_bud_sqlstmt
    USING FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID, version_date,
          FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID, version_date,
          version_date,
          FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID, version_date,
          FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID, version_date;

    IF  (FIIBUUP_DEBUG) THEN
      fii_util.put_line('Inserted '||SQL%ROWCOUNT||
                        ' budget rows into fii_budget_deltas');
    END IF;

    EXECUTE IMMEDIATE l_fc_sqlstmt
    USING FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID, version_date,
          FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID, version_date,
          version_date,
          FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID, version_date,
          FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID, version_date;

    IF  (FIIBUUP_DEBUG) THEN
      fii_util.put_line('Inserted '||SQL%ROWCOUNT||
                        ' forecast rows into fii_budget_deltas');
    END IF;

    -- Prior_version completed, return with success
    IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Prior_version()',
           t2        => 'ACTION',
           v2        => 'Prior_version done...');
    END IF;

    FND_CONCURRENT.Af_Commit;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.Prior_version' ||
                            version_date);
    END IF;
    RETURN TRUE;

  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.Prior_version()');

      FII_MESSAGE.Func_Fail
	(func_name => 'FII_BUDGET_FORECAST_C.Prior_version');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

    WHEN OTHERS THEN
      FND_CONCURRENT.Af_Rollback;

      -- SQL error occurs. Print out the error
      FII_MESSAGE.Write_Log(msg_name => 'FII_ERROR',
 			   token_num => 2,
			   t1	     => 'FUNCTION',
			   v1	     => 'FII_BUDGET_FORECAST_C.Prior_version',
 			   t2	     => 'SQLERRMC',
			   v2	     => SQLERRM);

      FII_MESSAGE.Func_Fail
	(func_name => 'FII_BUDGET_FORECAST_C.Prior_version' || version_date);

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;
  END Prior_version;

-------------------------------------------------------------------------------
  --
  -- Procedure
  --    Prior_version
  --
  -- Purpose
  --   	This procedure will determine the type of data we have in the interface
  --    table and assign a data_type to the row for further processing.
  --    This is similar to prior_version(version_date) except that this one is
  --    intended for cases without version date.
  --
  -- Arguments
  --    version_date
  -- Example
  --    result := FII_BUDGET_FORECAST_C.Prior_version;
  -- Notes
  --	Returns a boolean indicating if execution completes successfully
  FUNCTION Prior_version RETURN BOOLEAN IS
    FIIBUUP_fatal_err		EXCEPTION;
    l_tmpstmt			VARCHAR2(1000);
    l_bud_sqlstmt		VARCHAR2(5000);
    l_fc_sqlstmt		VARCHAR2(5000);
    l_bud_join_col_name		VARCHAR2(30) := NULL;
    l_fc_join_col_name		VARCHAR2(30) := NULL;
    l_bud_time_tab_name         VARCHAR2(30) := NULL;
    l_fc_time_tab_name          VARCHAR2(30) := NULL;

  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.Prior_version');
    END IF;

    -- Determine which time column should be used
    IF (FIIBUUP_BUDGET_TIME_UNIT = 'P') THEN
      l_bud_join_col_name := 'ent_period_id ';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Q') THEN
      l_bud_join_col_name := 'ent_qtr_id ';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Y') THEN
      l_bud_join_col_name := 'ent_year_id ';
    END IF;

    IF (FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
      l_fc_join_col_name := 'ent_period_id ';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
      l_fc_join_col_name := 'ent_qtr_id ';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Y') THEN
      l_fc_join_col_name := 'ent_year_id ';
    END IF;

    -- Determine which time table should be used
    IF (FIIBUUP_BUDGET_TIME_UNIT = 'P') THEN
      l_bud_time_tab_name := 'FII_TIME_ENT_PERIOD t';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Q') THEN
      l_bud_time_tab_name := 'FII_TIME_ENT_QTR t';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Y') THEN
      l_bud_time_tab_name := 'FII_TIME_ENT_YEAR t';
    END IF;

    IF (FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
      l_fc_time_tab_name := 'FII_TIME_ENT_PERIOD t';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
      l_fc_time_tab_name := 'FII_TIME_ENT_QTR t';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Y') THEN
      l_fc_time_tab_name := 'FII_TIME_ENT_YEAR t';
    END IF;

    -- The statment for prior_version needs to be built dynamically
    -- because of the variable time period involved.
    g_phase := 'Build the SQL statement';

    -- Start building the SQL statement
    l_tmpstmt := 'INSERT INTO FII_BUDGET_DELTAS ' ||
	       ' (plan_type_code, version_date, time_id, '||
               '  ledger_id, company_id, '||
               '  cost_center_id, fin_category_id, prod_category_id, '||
               '  user_dim1_id, data_type, '||
               '  prior_version_date, orig_prim_amount_total, '||
               '  orig_prim_amount_g, orig_sec_amount_total, '||
               '  orig_sec_amount_g, last_update_date, last_updated_by, '||
               '  creation_date, created_by, last_update_login ) '||

----------------------------------------------------------------------------
-- Case 5: Version date is NULL and time/dimension combination does not
--         exist in base table
----------------------------------------------------------------------------
              'SELECT bi.plan_type_code, '||
                    ' trunc(bi.version_date), ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || 't.' ||
                     l_bud_join_col_name || ', ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || 't.' ||
                     l_fc_join_col_name  || ', ';

    l_tmpstmt :=      ' bi.ledger_id, bi.company_id, '||
                    ' bi.cost_center_id, '||
                    ' bi.fin_category_id, '||
                    ' bi.prod_category_id, '||
                    ' bi.user_dim1_id, '||
                    ' -5, NULL, NULL, NULL, NULL, NULL, '||
                    ' SYSDATE, :user_id, SYSDATE, :user_id, :login_id '||
              ' FROM  FII_BUDGET_INTERFACE bi, ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || l_bud_time_tab_name;
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || l_fc_time_tab_name;

    l_tmpstmt := ' WHERE trunc(bi.version_date) IS NULL '||
               ' AND   bi.report_time_period = t.name ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                     'AND   bi.plan_type_code = ''B'' ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt ||
                     'AND   bi.plan_type_code = ''F'' ';

    l_tmpstmt :=   ' AND   NOT EXISTS ( '||
                 ' SELECT 1 '||
                 ' FROM  FII_BUDGET_BASE bb, ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || l_bud_time_tab_name || '2 ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || l_fc_time_tab_name  || '2 ';

    l_tmpstmt :=   ' WHERE bi.report_time_period       = t2.name ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                 ' AND t2.' || l_bud_join_col_name || ' = bb.time_id ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt ||
                 ' AND t2.' || l_fc_join_col_name || ' = bb.time_id ';

    l_tmpstmt :=   ' AND   bi.plan_type_code           = bb.plan_type_code '||
                 ' AND   bi.ledger_id                = bb.ledger_id '||
                 ' AND   bi.company_id               = bb.company_id '||
                 ' AND   bi.cost_center_id           = bb.cost_center_id '||
                 ' AND   bi.fin_category_id          = bb.fin_category_id '||
                 ' AND   NVL(bi.prod_category_id, 0)=NVL(bb.category_id, 0) '||
                 ' AND   bi.user_dim1_id             = bb.user_dim1_id) ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt;
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt;

----------------------------------------------------------------------------
-- Case 6: Version date is NULL and time/dimension combination exists in base
----------------------------------------------------------------------------
    l_tmpstmt := 'UNION ALL ' ||
               'SELECT bi.plan_type_code, '||
                      'trunc(bi.version_date), ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || 't.' ||
                     l_bud_join_col_name || ', ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || 't.' ||
                     l_fc_join_col_name  || ', ';

    l_tmpstmt :=      ' bi.ledger_id, bi.company_id, '||
                    ' bi.cost_center_id, '||
                    ' bi.fin_category_id, '||
                    ' bi.prod_category_id, '||
                    ' bi.user_dim1_id, '||
                    ' -6, bb2.version_date, bb2.prim_amount_total, '||
                    ' bb2.prim_amount_g, bb2.sec_amount_total, '||
                    ' bb2.sec_amount_g, '||
                    ' SYSDATE, :user_id, SYSDATE, :user_id, :login_id '||
              ' FROM  FII_BUDGET_INTERFACE bi, ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || l_bud_time_tab_name || ', ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || l_fc_time_tab_name || ', ';

    l_tmpstmt :=
    ' FII_BUDGET_BASE bb2, '||
    ' (SELECT v.name, v.plan_type_code, v.ledger_id, v.company_id, '||
            ' v.cost_center_id, v.fin_category_id, v.category_id, '||
            ' v.user_dim1_id, v.version_date '||
     ' FROM ( '||
      ' SELECT  t.name, bb.plan_type_code, bb.ledger_id, bb.company_id, '||
              ' bb.cost_center_id, bb.fin_category_id, bb.category_id, '||
              ' bb.user_dim1_id, bb.version_date, '||
              ' rank() over (partition by t.name, bb.plan_type_code, '||
                           ' bb.ledger_id, bb.company_id, '||
                           ' bb.cost_center_id,bb.fin_category_id, '||
                           ' bb.category_id, bb.user_dim1_id'||
                           ' order by bb.version_date desc) Rank '||
      ' FROM  FII_BUDGET_BASE bb, ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || l_bud_time_tab_name;
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || l_fc_time_tab_name;

    l_tmpstmt := ', fii_budget_interface bi '||
                 ' WHERE bi.report_time_period       = t.name ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                   ' AND t.' || l_bud_join_col_name || '= bb.time_id ';
    l_fc_sqlstmt  := l_fc_sqlstmt || l_tmpstmt ||
                   ' AND t.' || l_fc_join_col_name || '= bb.time_id ';

    l_tmpstmt :=
      '   AND   bi.plan_type_code           = bb.plan_type_code '||
      '   AND   bi.ledger_id                = bb.ledger_id '||
      '   AND   bi.company_id               = bb.company_id '||
      '   AND   bi.cost_center_id           = bb.cost_center_id '||
      '   AND   bi.fin_category_id          = bb.fin_category_id '||
      '   AND   NVL(bi.prod_category_id, 0) = NVL(bb.category_id, 0) '||
      '   AND   NVL(bi.user_dim1_id, 0)     = NVL(bb.user_dim1_id, 0)) v '||
      ' WHERE v.rank = 1) cver '||
      'WHERE trunc(bi.version_date) IS NULL '||
      'AND   bi.report_time_period = t.name ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
               ' AND bb2.time_id = t.' || l_bud_join_col_name ||
               ' AND bi.plan_type_code = ''B'' ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt ||
               'AND bb2.time_id = t.' || l_fc_join_col_name ||
               ' AND bi.plan_type_code = ''F'' ';

    l_tmpstmt := --'AND   bb2.no_version_flag = ''Y'' '||
               'AND   bb2.plan_type_code = bi.plan_type_code '||
               'AND   bb2.ledger_id = bi.ledger_id '||
               'AND   bb2.company_id = bi.company_id '||
               'AND   bb2.cost_center_id = bi.cost_center_id '||
               'AND   bb2.fin_category_id = bi.fin_category_id '||
               'AND   NVL(bi.prod_category_id, 0) = NVL(bb2.category_id, 0) '||
               'AND   bi.user_dim1_id     = bb2.user_dim1_id '||
               'AND   bb2.prim_amount_total != bi.prim_amount_g '||
               'AND   nvl(bb2.sec_amount_total,0) != nvl(bi.sec_amount_g,0) '||
               'AND   bi.report_time_period = cver.name '||
               'AND   bi.plan_type_code  = cver.plan_type_code '||
               'AND   bi.ledger_id      = cver.ledger_id '||
               'AND   bi.company_id      = cver.company_id '||
               'AND   bi.cost_center_id  = cver.cost_center_id '||
               'AND   bi.fin_category_id = cver.fin_category_id '||
               'AND   nvl(bi.prod_category_id, 0)=nvl(cver.category_id, 0) '||
               'AND   bi.user_dim1_id   = cver.user_dim1_id '||
               'AND   bb2.version_date = cver.version_date ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt;
    l_fc_sqlstmt  := l_fc_sqlstmt || l_tmpstmt;

    -- Print out the dynamic SQL statements if running in debug mode
    IF (FIIBUUP_DEBUG) THEN

      fii_util.put_line('l_bud_sqlstmt = '|| l_bud_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Prior_version()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_bud_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_bud_sqlstmt)));

      fii_util.put_line('l_fc_sqlstmt = '|| l_fc_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Prior_version()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_fc_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_fc_sqlstmt)));
    END IF;

    -- Execute both statements for budget and forecast
    EXECUTE IMMEDIATE l_bud_sqlstmt
    USING FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
          FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID;

    IF  (FIIBUUP_DEBUG) THEN
      fii_util.put_line('Inserted '||SQL%ROWCOUNT||
                        ' budget rows into fii_budget_deltas');
    END IF;

    EXECUTE IMMEDIATE l_fc_sqlstmt
    USING FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
          FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID;

    IF  (FIIBUUP_DEBUG) THEN
      fii_util.put_line('Inserted '||SQL%ROWCOUNT||
                        ' forecast rows into fii_budget_deltas');
    END IF;

    -- Prior_version completed, return with success
    IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Prior_version()',
           t2        => 'ACTION',
           v2        => 'Prior_version done...');
    END IF;

    FND_CONCURRENT.Af_Commit;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.Prior_version');
    END IF;
    RETURN TRUE;

  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.Prior_version()');

      FII_MESSAGE.Func_Fail
	(func_name => 'FII_BUDGET_FORECAST_C.Prior_version');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

    WHEN OTHERS THEN
      FND_CONCURRENT.Af_Rollback;

      -- SQL error occurs. Print out the error
      FII_MESSAGE.Write_Log(msg_name => 'FII_ERROR',
 			   token_num => 2,
			   t1	     => 'FUNCTION',
			   v1	     => 'FII_BUDGET_FORECAST_C.Prior_version',
 			   t2	     => 'SQLERRMC',
			   v2	     => SQLERRM);

      FII_MESSAGE.Func_Fail
	(func_name => 'FII_BUDGET_FORECAST_C.Prior_version');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;
  END Prior_version;

-------------------------------------------------------------------------------
  --
  -- Procedure
  --    Stage
  --
  -- Purpose
  --    This routine populates data into fii_budget_stg.
  -- Arguments
  --    version_date
  -- Example
  --    result := FII_BUDGET_FORECAST_C.Stage(version_date);
  -- Notes
  --	Returns a boolean indicating if execution completes successfully
  FUNCTION Stage (version_date DATE) RETURN BOOLEAN IS
    FIIBUUP_fatal_err		EXCEPTION;
    l_tmpstmt			VARCHAR2(3000);
    l_bud_sqlstmt		VARCHAR2(5000);
    l_fc_sqlstmt		VARCHAR2(5000);
    l_bud_join_col_name		VARCHAR2(30) := NULL;
    l_fc_join_col_name		VARCHAR2(30) := NULL;
    l_bud_time_tab_name         VARCHAR2(30) := NULL;
    l_fc_time_tab_name          VARCHAR2(30) := NULL;
    l_bud_stg_col_name		VARCHAR2(30) := NULL;
    l_fc_stg_col_name		VARCHAR2(30) := NULL;

  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.stage - version_date = ' ||
                           version_date);
    END IF;

    -- Determine which time column should be used for staging
    IF (FIIBUUP_BUDGET_TIME_UNIT = 'P') THEN
      l_bud_stg_col_name := 'PERIOD';
      l_bud_join_col_name := 'ent_period_id ';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Q') THEN
      l_bud_stg_col_name := 'QUARTER';
      l_bud_join_col_name := 'ent_qtr_id ';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Y') THEN
      l_bud_stg_col_name := 'YEAR';
      l_bud_join_col_name := 'ent_year_id ';
    END IF;

    IF (FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
      l_fc_stg_col_name := 'PERIOD';
      l_fc_join_col_name := 'ent_period_id ';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
      l_fc_stg_col_name := 'QUARTER';
      l_fc_join_col_name := 'ent_qtr_id ';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Y') THEN
      l_fc_stg_col_name := 'YEAR';
      l_fc_join_col_name := 'ent_year_id ';
    END IF;

    -- Determine which time table should be used
    IF (FIIBUUP_BUDGET_TIME_UNIT = 'P') THEN
      l_bud_time_tab_name := 'FII_TIME_ENT_PERIOD t';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Q') THEN
      l_bud_time_tab_name := 'FII_TIME_ENT_QTR t';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Y') THEN
      l_bud_time_tab_name := 'FII_TIME_ENT_YEAR t';
    END IF;

    IF (FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
      l_fc_time_tab_name := 'FII_TIME_ENT_PERIOD t';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
      l_fc_time_tab_name := 'FII_TIME_ENT_QTR t';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Y') THEN
      l_fc_time_tab_name := 'FII_TIME_ENT_YEAR t';
    END IF;

    -- The statment for stage needs to be built dynamically
    -- because of the variable time period involved.
    g_phase := 'Build the SQL statement';

    -- Start building the SQL statement
    l_bud_sqlstmt := ' INSERT INTO FII_BUDGET_STG ( ' ||
                   ' version_date, ' || l_bud_stg_col_name || ', ';

    l_fc_sqlstmt := ' INSERT INTO FII_BUDGET_STG ( ' ||
                  ' version_date, ' || l_fc_stg_col_name || ', ';

    l_tmpstmt := ' plan_type_code, creation_date, created_by, '||
               ' last_update_date, last_updated_by, last_update_login, '||
               ' ledger_id, company_cost_center_org_id, '||
               ' company_id, cost_center_id, fin_category_id, '||
               ' category_id, user_dim1_id, user_dim2_id, '||
               ' prim_amount_total,  prim_amount_g, '||
               ' sec_amount_total, sec_amount_g, overwrite_version_date, '||
               ' data_type, no_version_flag ) '||
               ' SELECT ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt;
    l_fc_sqlstmt  := l_fc_sqlstmt || l_tmpstmt;

    IF (version_date IS NOT NULL) THEN
     l_tmpstmt := ' decode(d.data_type, -4, d.prior_version_date, '||
                         ' trunc(i.version_date)), ';
    ELSE
     l_tmpstmt := ' decode(d.data_type, -5, :global_start_date, '||
                         ' d.prior_version_date), ';
    END IF;

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
               ' t.' || l_bud_join_col_name || ', ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt ||
               ' t.' || l_fc_join_col_name || ', ';

    l_tmpstmt := ' i.plan_type_code, '||
               ' SYSDATE, :user_id, SYSDATE, :user_id, :login_id,  '||
               ' i.ledger_id, i.company_cost_center_org_id, '||
               ' i.company_id, i.cost_center_id, i.fin_category_id, '||
               ' i.prod_category_id, i.user_dim1_id, i.user_dim2_id, '||
               ' i.prim_amount_g, ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt;
    l_fc_sqlstmt  := l_fc_sqlstmt || l_tmpstmt;

    IF (version_date IS NOT NULL) THEN
      l_tmpstmt := ' DECODE (d.data_type, '||
                  ' -1, i.prim_amount_g, '||
                  ' -2, i.prim_amount_g - b.prim_amount_total, '||
        ' i.prim_amount_g - d.orig_prim_amount_total + d.orig_prim_amount_g '||
                 '), ';
    ELSE
      l_tmpstmt := ' DECODE (d.data_type, '||
                    ' -5, i.prim_amount_g, '||
        ' i.prim_amount_g - d.orig_prim_amount_total + d.orig_prim_amount_g '||
                   ' ), ';
    END IF;

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt;
    l_fc_sqlstmt  := l_fc_sqlstmt || l_tmpstmt;

    l_tmpstmt :=   ' DECODE(i.conversion_rate, '||
                   ' NULL, i.sec_amount_g, '||
                     ' DECODE(:sec_curr_code, '||
                         ' :prim_curr_code, i.prim_amount_g, '||
                         ' ROUND((i.prim_amount_g*i.conversion_rate)/:l_mau)*:l_mau)), ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt;
    l_fc_sqlstmt  := l_fc_sqlstmt || l_tmpstmt;

    IF (version_date IS NOT NULL) THEN
      l_tmpstmt :=      ' DECODE (d.data_type, '||
                         ' -1, DECODE(i.conversion_rate, '||
                             ' NULL, i.sec_amount_g, '||
                             ' DECODE(:sec_curr_code, :prim_curr_code, i.prim_amount_g, '||
                            ' ROUND((i.prim_amount_g*i.conversion_rate)/:l_mau)*:l_mau)), '||
                         ' -2, DECODE(i.conversion_rate, '||
                                 'NULL, i.sec_amount_g,'||
                             ' DECODE(:sec_curr_code, :prim_curr_code, i.prim_amount_g, '||
                          ' ROUND((i.prim_amount_g*i.conversion_rate)/:l_mau)*:l_mau)) - b.sec_amount_total, '||
                         ' DECODE(i.conversion_rate, '||
                             ' NULL, i.sec_amount_g, '||
                             ' DECODE(:sec_curr, :prim_curr, i.prim_amount_g, '||
                            ' ROUND((i.prim_amount_g*i.conversion_rate)/:l_mau)*:l_mau)) '||
                         ' - d.orig_sec_amount_total + d.orig_sec_amount_g '||
                      '), '||
                  ' DECODE(d.data_type, -4, trunc(i.version_date), NULL), '||
                  ' d.data_type, ''N'' '||
         'FROM FII_BUDGET_INTERFACE i, FII_BUDGET_DELTAS d, FII_BUDGET_BASE b, ';

    ELSE
      l_tmpstmt :=  ' DECODE (d.data_type, '||
                    ' -5, DECODE(i.conversion_rate, '||
                           ' NULL, i.sec_amount_g, '||
                           ' DECODE(:sec_curr_code, :prim_curr_code, i.prim_amount_g, '||
                           ' ROUND((i.prim_amount_g*i.conversion_rate)/:l_mau)*:l_mau)), '||
                    ' DECODE(i.conversion_rate, '||
                           ' NULL, i.sec_amount_g, '||
                           ' DECODE(:sec_curr_code, :prim_curr_code, i.prim_amount_g, '||
                           ' ROUND((i.prim_amount_g*i.conversion_rate)/:l_mau)*:l_mau)) '||
                       ' - d.orig_sec_amount_total + d.orig_sec_amount_g '||
                    ' ),'||
                  ' DECODE(d.data_type, -6, trunc(i.version_date), NULL), '||
                  ' d.data_type,'||
                  ' ''Y'' '||
            'FROM FII_BUDGET_INTERFACE i, FII_BUDGET_DELTAS d, FII_BUDGET_BASE b,';
    END IF;

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || l_bud_time_tab_name ||
                   ' WHERE d.time_id = t.' || l_bud_join_col_name;

    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || l_fc_time_tab_name ||
                   ' WHERE d.time_id = t.' || l_fc_join_col_name;

    IF (version_date IS NOT NULL) THEN
      l_tmpstmt := ' AND   trunc(d.version_date) = trunc(i.version_date) '||
                 ' AND   d.data_type in (-1, -2, -3, -4) '||
                 ' AND   trunc(i.version_date) = trunc(:version_date) ';
    ELSE
      l_tmpstmt := ' AND d.version_date IS NULL '||
                 ' AND d.data_type in (-5, -6) '||
                 ' AND i.version_date IS NULL ';
    END IF;

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                     'AND   i.plan_type_code = ''B'' ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt ||
                     'AND   i.plan_type_code = ''F'' ';


    l_tmpstmt := ' AND   i.plan_type_code(+) = d.plan_type_code '||
                 ' AND   i.ledger_id(+)      = d.ledger_id '||
                 ' AND   i.company_id(+)     = d.company_id '||
                 ' AND   i.cost_center_id(+) = d.cost_center_id '||
                 ' AND   i.fin_category_id(+) = d.fin_category_id '||
                 ' AND   nvl(i.prod_category_id(+),-1)= nvl(d.prod_category_id,-1) '||
                 ' AND   i.user_dim1_id(+)   = d.user_dim1_id '||
                 ' AND   t.name           = i.report_time_period '||
                 ' AND   b.version_date(+)   = trunc(d.prior_version_date) '||
                 ' AND   b.plan_type_code(+) = decode(d.data_type, -2, d.plan_type_code, NULL) '||
                 ' AND   b.time_id(+)        = d.time_id '||
                 ' AND   b.ledger_id(+)      = d.ledger_id '||
                 ' AND   b.company_id(+)     = d.company_id '||
                 ' AND   b.cost_center_id(+) = d.cost_center_id '||
                 ' AND   b.fin_category_id(+) = d.fin_category_id '||
                 ' AND   NVL(b.category_id(+), -1) = NVL(d.prod_category_id, -1) '||
                 ' AND   b.user_dim1_id(+) = d.user_dim1_id ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt;
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt;

    -- Print out the dynamic SQL statements if running in debug mode
    IF (FIIBUUP_DEBUG) THEN
      fii_util.put_line('l_bud_sqlstmt = '|| l_bud_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.stage()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_bud_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_bud_sqlstmt)));

      fii_util.put_line('l_fc_sqlstmt = '|| l_fc_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.stage()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_fc_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_fc_sqlstmt)));
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Stage()',
           t2        => 'ACTION',
           v2        => 'Staging budget records...');
    END IF;

    g_phase := 'Execute the built SQL l_bud_sqlstmt';
    IF (version_date IS NOT NULL) THEN
      EXECUTE IMMEDIATE l_bud_sqlstmt
	USING FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
	      FIIBUUP_SEC_CURR_CODE, FIIBUUP_PRIM_CURR_CODE,
	      FIIBUUP_SEC_CURR_MAU, FIIBUUP_SEC_CURR_MAU,
	      FIIBUUP_SEC_CURR_CODE, FIIBUUP_PRIM_CURR_CODE,
	      FIIBUUP_SEC_CURR_MAU, FIIBUUP_SEC_CURR_MAU,
	      FIIBUUP_SEC_CURR_CODE, FIIBUUP_PRIM_CURR_CODE,
	      FIIBUUP_SEC_CURR_MAU, FIIBUUP_SEC_CURR_MAU,
	      FIIBUUP_SEC_CURR_CODE, FIIBUUP_PRIM_CURR_CODE,
	      FIIBUUP_SEC_CURR_MAU, FIIBUUP_SEC_CURR_MAU, version_date;
    ELSE
      EXECUTE IMMEDIATE l_bud_sqlstmt
	USING FIIBUUP_GLOBAL_START_DATE,
              FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
	      FIIBUUP_SEC_CURR_CODE, FIIBUUP_PRIM_CURR_CODE,
	      FIIBUUP_SEC_CURR_MAU, FIIBUUP_SEC_CURR_MAU,
	      FIIBUUP_SEC_CURR_CODE, FIIBUUP_PRIM_CURR_CODE,
	      FIIBUUP_SEC_CURR_MAU, FIIBUUP_SEC_CURR_MAU,
	      FIIBUUP_SEC_CURR_CODE, FIIBUUP_PRIM_CURR_CODE,
	      FIIBUUP_SEC_CURR_MAU, FIIBUUP_SEC_CURR_MAU;
    END IF;

    IF (FIIBUUP_DEBUG) THEN
    FII_MESSAGE.Write_log
	(msg_name	=> 'FII_INST_REC',
	 token_num	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_STG');
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Stage()',
           t2        => 'ACTION',
           v2        => 'Staging forecast records...');
    END IF;

    g_phase := 'Execute the built SQL l_fc_sqlstmt';
    IF (version_date IS NOT NULL) THEN
      EXECUTE IMMEDIATE l_fc_sqlstmt
	USING FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
	      FIIBUUP_SEC_CURR_CODE, FIIBUUP_PRIM_CURR_CODE,
	      FIIBUUP_SEC_CURR_MAU, FIIBUUP_SEC_CURR_MAU,
	      FIIBUUP_SEC_CURR_CODE, FIIBUUP_PRIM_CURR_CODE,
	      FIIBUUP_SEC_CURR_MAU, FIIBUUP_SEC_CURR_MAU,
	      FIIBUUP_SEC_CURR_CODE, FIIBUUP_PRIM_CURR_CODE,
	      FIIBUUP_SEC_CURR_MAU, FIIBUUP_SEC_CURR_MAU,
	      FIIBUUP_SEC_CURR_CODE, FIIBUUP_PRIM_CURR_CODE,
	      FIIBUUP_SEC_CURR_MAU, FIIBUUP_SEC_CURR_MAU, version_date;
    ELSE
      EXECUTE IMMEDIATE l_fc_sqlstmt
	USING FIIBUUP_GLOBAL_START_DATE,
              FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
	      FIIBUUP_SEC_CURR_CODE, FIIBUUP_PRIM_CURR_CODE,
	      FIIBUUP_SEC_CURR_MAU, FIIBUUP_SEC_CURR_MAU,
	      FIIBUUP_SEC_CURR_CODE, FIIBUUP_PRIM_CURR_CODE,
	      FIIBUUP_SEC_CURR_MAU, FIIBUUP_SEC_CURR_MAU,
	      FIIBUUP_SEC_CURR_CODE, FIIBUUP_PRIM_CURR_CODE,
	      FIIBUUP_SEC_CURR_MAU, FIIBUUP_SEC_CURR_MAU;
    END IF;

    IF (FIIBUUP_DEBUG) THEN
    FII_MESSAGE.Write_log
	(msg_name	=> 'FII_INST_REC',
	 token_num	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_STG');
    END IF;

    -- stage completed, return with success
    IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'stage()',
           t2        => 'ACTION',
           v2        => 'Staging done...');
    END IF;

    FND_CONCURRENT.Af_Commit;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.stage');
    END IF;
    RETURN TRUE;

  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.stage()');

      FII_MESSAGE.Func_Fail
	(func_name => 'FII_BUDGET_FORECAST_C.stage');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

    WHEN OTHERS THEN
      FND_CONCURRENT.Af_Rollback;

      -- SQL error occurs. Print out the error
      FII_MESSAGE.Write_Log(msg_name => 'FII_ERROR',
 			   token_num => 2,
			   t1	     => 'FUNCTION',
			   v1	     => 'FII_BUDGET_FORECAST_C.stage',
 			   t2	     => 'SQLERRMC',
			   v2	     => SQLERRM);

      FII_MESSAGE.Func_Fail
	(func_name => 'FII_BUDGET_FORECAST_C.stage');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;
  END Stage;

--------------------------------------------------------------------------------
  --
  -- Procedure
  --    Adjust_Amount
  --
  -- Purpose
  --    This routine determines the adjustments we need to make to the rolled
  --    up time dimension for cases where we are overwriting existing records
  --    in fii_budget_base.
  -- Arguments
  --    version_date
  -- Example
  --    result := FII_BUDGET_FORECAST_C.Adjust_Amount;
  -- Notes
  --	Returns a boolean indicating if execution completes successfully
  FUNCTION Adjust_Amount RETURN BOOLEAN IS
    FIIBUUP_fatal_err		EXCEPTION;
    l_tmpstmt			VARCHAR2(3000);
    l_bud_sqlstmt		VARCHAR2(5000) := NULL;
    l_fc_sqlstmt		VARCHAR2(5000) := NULL;
    l_bud_join_col_name		VARCHAR2(30) := NULL;
    l_fc_join_col_name		VARCHAR2(30) := NULL;
    l_bud_time_tab_name         VARCHAR2(30) := NULL;
    l_fc_time_tab_name          VARCHAR2(30) := NULL;
    l_bud_stg_col_name		VARCHAR2(30) := NULL;
    l_fc_stg_col_name		VARCHAR2(30) := NULL;

  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.adjust_amount');
    END IF;

    -- Determine which time column should be used for staging
    IF (FIIBUUP_BUDGET_TIME_UNIT = 'P') THEN
      l_bud_stg_col_name := 'PERIOD';
      l_bud_join_col_name := 'ent_period_id ';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Q') THEN
      l_bud_stg_col_name := 'QUARTER';
      l_bud_join_col_name := 'ent_qtr_id ';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Y') THEN
      l_bud_stg_col_name := 'YEAR';
      l_bud_join_col_name := 'ent_year_id ';
    END IF;

    IF (FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
      l_fc_stg_col_name := 'PERIOD';
      l_fc_join_col_name := 'ent_period_id ';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
      l_fc_stg_col_name := 'QUARTER';
      l_fc_join_col_name := 'ent_qtr_id ';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Y') THEN
      l_fc_stg_col_name := 'YEAR';
      l_fc_join_col_name := 'ent_year_id ';
    END IF;

    -- Determine which time table should be used
    IF (FIIBUUP_BUDGET_TIME_UNIT = 'P') THEN
      l_bud_time_tab_name := 'FII_TIME_ENT_PERIOD t';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Q') THEN
      l_bud_time_tab_name := 'FII_TIME_ENT_QTR t';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Y') THEN
      l_bud_time_tab_name := 'FII_TIME_ENT_YEAR t';
    END IF;

    IF (FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
      l_fc_time_tab_name := 'FII_TIME_ENT_PERIOD t';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
      l_fc_time_tab_name := 'FII_TIME_ENT_QTR t';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Y') THEN
      l_fc_time_tab_name := 'FII_TIME_ENT_YEAR t';
    END IF;

    -- The statment for stage needs to be built dynamically for
    -- budget and forecast
    g_phase := 'Build the SQL statement';

    -- Start building the SQL statement
    l_tmpstmt :=
      'INSERT INTO FII_BUDGET_BASE_T '||
        ' (plan_type_code, version_date, overwrite_version_date, '||
        '  no_version_flag, '||
        '  data_type, prim_amount_total, sec_amount_total, '||
        '  prim_amount_g, sec_amount_g, creation_date, created_by, '||
        '  last_update_date, last_updated_by, last_update_login, '||
        '  ledger_id, company_cost_center_org_id, '||
        '  company_id, cost_center_id, fin_category_id, '||
        '  category_id, user_dim1_id, user_dim2_id, '||
        '  time_id, period_type_id, day, week, period, quarter, year '||
      ' )'||
      ' SELECT '||
        ' b.plan_type_code, s.version_date, s.overwrite_version_date, '||
        ' s.no_version_flag, s.data_type, '||
        ' s.prim_amount_total - b.prim_amount_total, '||
        ' s.sec_amount_total - b.sec_amount_total, '||
        ' s.prim_amount_g - b.prim_amount_g, '||
        ' s.sec_amount_g - b.sec_amount_g, b.creation_date, '||
        ' b.created_by, '||
        ' b.last_update_date, b.last_updated_by, b.last_update_login, '||
        ' b.ledger_id, s.company_cost_center_org_id, '||
        ' b.company_id, b.cost_center_id, b.fin_category_id, '||
        ' b.category_id, b.user_dim1_id, b.user_dim2_id, '||
        ' b.time_id, b.period_type_id, '||
        ' s.day, s.week, s.period, s.quarter, s.year '||
      ' FROM FII_BUDGET_BASE b, FII_BUDGET_STG s '||
      ' WHERE b.plan_type_code             = s. plan_type_code '||
      ' AND   b.ledger_id = s.ledger_id '||
      ' AND   b.company_id = s.company_id '||
      ' AND   b.cost_center_id = s.cost_center_id '||
      ' AND   b.fin_category_id            = s.fin_category_id '||
      ' AND   NVL(b.category_id, -1)       = NVL(s.category_id, -1) '||
      ' AND   b.user_dim1_id      = s.user_dim1_id '||
      ' AND   b.version_date = s.version_date '||
      ' AND   s.data_type in (-3, -4, -6) '||
      ' AND   b.time_id = NVL(s.day, NVL(s.week, '||
                             'NVL(s.period, NVL(s.quarter, s.year)))) '||
      ' AND   b.period_type_id = '||
                  'DECODE(s.day, null, '||
                   ' DECODE(s.week, null, DECODE(s.period, null, '||
                  '    DECODE(s.quarter, null, 128, 64), 32), 16), 1) ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                     ' AND s.plan_type_code = ''B'' ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt ||
                     ' AND s.plan_type_code = ''F'' ';

    -- Print out the dynamic SQL statements if running in debug mode
    IF (FIIBUUP_DEBUG) THEN
      fii_util.put_line('l_bud_sqlstmt = '|| l_bud_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.adjust_amount()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_bud_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_bud_sqlstmt)));

      fii_util.put_line('l_fc_sqlstmt = '|| l_fc_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.adjust_amount()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_fc_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_fc_sqlstmt)));
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'adjust_amount()',
           t2        => 'ACTION',
           v2        => 'Adjusting budget amounts...');
    END IF;

    g_phase := 'Execute the built SQL l_bud_sqlstmt';
    EXECUTE IMMEDIATE l_bud_sqlstmt;

    IF (FIIBUUP_DEBUG) THEN
    FII_MESSAGE.Write_log
	(msg_name	=> 'FII_INST_REC',
	 token_num	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_BASE_T');
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Adjust_Amount()',
           t2        => 'ACTION',
           v2        => 'Adjust forecast records...');
    END IF;

    g_phase := 'Execute the built SQL l_fc_sqlstmt';
    EXECUTE IMMEDIATE l_fc_sqlstmt;

    IF (FIIBUUP_DEBUG) THEN
    FII_MESSAGE.Write_log
	(msg_name	=> 'FII_INST_REC',
	 token_num	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_BASE_T');
    END IF;

    l_bud_sqlstmt := NULL;
    l_fc_sqlstmt  := NULL;

    -- Roll up adjustments along time dimension
      l_tmpstmt :=
        ' INSERT INTO FII_BUDGET_BASE_T ( '||
            ' version_date, overwrite_version_date, no_version_flag, '||
            ' data_type, period, quarter, year, plan_type_code, '||
            ' creation_date, created_by, last_update_date, last_updated_by, '||
            ' last_update_login, ledger_id, company_cost_center_org_id, '||
            ' company_id, cost_center_id, '||
            ' fin_category_id, '||
            ' category_id, user_dim1_id, user_dim2_id, prim_amount_total, '||
            ' prim_amount_g, sec_amount_total, sec_amount_g) '||
        ' SELECT '||
            ' s.version_date, s.overwrite_version_date, s.no_version_flag, '||
            ' s.data_type, to_number(NULL), ';

      IF (FIIBUUP_BUDGET_TIME_UNIT = 'P') THEN
        l_bud_sqlstmt := l_tmpstmt || ' t.ent_qtr_id, t.ent_year_id, ';
      ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Q') THEN
        l_bud_sqlstmt := l_tmpstmt || ' to_number(NULL), t.ent_year_id, ';
      END IF;

      IF (FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
        l_fc_sqlstmt := l_tmpstmt || ' t.ent_qtr_id, t.ent_year_id, ';
      ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
        l_fc_sqlstmt := l_tmpstmt || ' to_number(NULL), t.ent_year_id, ';
      END IF;

      l_tmpstmt :=
        ' s.plan_type_code, sysdate, :user_id, sysdate, '||
        ' :user_id, :login_id, '||
        ' s.ledger_id, s.company_cost_center_org_id, '||
        ' s.company_id, s.cost_center_id, s.fin_category_id, '||
        ' s.category_id, s.user_dim1_id, s.user_dim2_id, '||
        ' sum(s.prim_amount_total), sum(s.prim_amount_g), '||
        ' sum(s.sec_amount_total), sum(s.sec_amount_g) '||
        ' FROM FII_BUDGET_BASE_T s, ';

      IF (FIIBUUP_BUDGET_TIME_UNIT <> 'Y') THEN
        l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || l_bud_time_tab_name ||
                       ' WHERE s.plan_type_code = ''B'' ' ||
                       ' AND   s.' || l_bud_stg_col_name || ' = t.' ||
                       l_bud_join_col_name;
      END IF;

      IF (FIIBUUP_FORECAST_TIME_UNIT <> 'Y') THEN
        l_fc_sqlstmt := l_fc_sqlstmt || l_tmpstmt || l_fc_time_tab_name ||
                      ' WHERE s.plan_type_code = ''F'' ' ||
                       ' AND   s.' || l_fc_stg_col_name || ' = t.' ||
                       l_fc_join_col_name;
      END IF;

      l_tmpstmt :=
        ' GROUP BY s.version_date, s.overwrite_version_date, '||
        ' s.no_version_flag, '||
        ' s.data_type, s.plan_type_code, '||
        ' sysdate, :user_di, sysdate, :user_id, :login_id, '||
        ' s.ledger_id, s.company_cost_center_org_id, '||
        ' s.company_id, s.cost_center_id, s.fin_category_id, '||
        ' s.category_id, s.user_dim1_id, s.user_dim2_id, ';

      IF (FIIBUUP_BUDGET_TIME_UNIT = 'P') THEN
        l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                         ' t.ent_year_id, ROLLUP(t.ent_qtr_id) ';
      ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Q') THEN
        l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || ' t.ent_year_id ';
      END IF;

      IF (FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
        l_fc_sqlstmt := l_fc_sqlstmt || l_tmpstmt ||
                        ' t.ent_year_id, ROLLUP(t.ent_qtr_id) ';
      ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
        l_fc_sqlstmt := l_fc_sqlstmt || l_tmpstmt || ' t.ent_year_id ';
      END IF;

    -- Print out the dynamic SQL statements if running in debug mode
    IF (FIIBUUP_DEBUG) THEN
      fii_util.put_line('l_bud_sqlstmt = '|| l_bud_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.adjust_amount()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_bud_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_bud_sqlstmt)));

      fii_util.put_line('l_fc_sqlstmt = '|| l_fc_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.adjust_amount()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_fc_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_fc_sqlstmt)));
    END IF;

    IF (FIIBUUP_BUDGET_TIME_UNIT <> 'Y') THEN
      g_phase := 'Execute the built SQL l_bud_sqlstmt';

      IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'adjust_amount()',
           t2        => 'ACTION',
           v2        => 'Adjusting budget amounts...');
      END IF;

      EXECUTE IMMEDIATE l_bud_sqlstmt
	USING FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
              FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID;

      IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_log
	  (msg_name	=> 'FII_INST_REC',
  	   token_num	=> 2,
	   t1		=> 'NUM',
	   v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	   t2		=> 'TABLE',
	   v2		=> 'FII_BUDGET_BASE_T');
        END IF;
      END IF;

    IF (FIIBUUP_FORECAST_TIME_UNIT <> 'Y') THEN
      g_phase := 'Execute the built SQL l_fc_sqlstmt';

      IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Adjust_Amount()',
           t2        => 'ACTION',
           v2        => 'Adjusting forecast amounts...');
      END IF;

      EXECUTE IMMEDIATE l_fc_sqlstmt
	USING FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
              FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID;
    END IF;

    IF (FIIBUUP_DEBUG) THEN
    FII_MESSAGE.Write_log
	(msg_name	=> 'FII_INST_REC',
	 token_num	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_BASE_T');
    END IF;

    -- adjust_amount completed, return with success
    IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'adjust_amount()',
           t2        => 'ACTION',
           v2        => 'adjust_amount done...');
    END IF;

    FND_CONCURRENT.Af_Commit;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.adjust_amount');
    END IF;
    RETURN TRUE;

  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.adjust_amount()');

      FII_MESSAGE.Func_Fail
	(func_name => 'FII_BUDGET_FORECAST_C.adjsut_stage');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

    WHEN OTHERS THEN
      FND_CONCURRENT.Af_Rollback;

      -- SQL error occurs. Print out the error
      FII_MESSAGE.Write_Log(msg_name => 'FII_ERROR',
 			   token_num => 2,
			   t1	     => 'FUNCTION',
			   v1	     => 'FII_BUDGET_FORECAST_C.adjust_amount',
 			   t2	     => 'SQLERRMC',
			   v2	     => SQLERRM);

      FII_MESSAGE.Func_Fail
	(func_name => 'FII_BUDGET_FORECAST_C.adjust_amount');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

END Adjust_Amount;

-------------------------------------------------------------------------------
  --
  -- Procedure
  --    Rollup_Stage
  --
  -- Purpose
  --    Rollup records in fii_budget_stg along time dimension.
  -- Arguments
  --    version_date
  -- Example
  --    result := FII_BUDGET_FORECAST_C.Rollup_Stage;
  -- Notes
  --	Returns a boolean indicating if execution completes successfully
  FUNCTION Rollup_Stage RETURN BOOLEAN IS
    FIIBUUP_fatal_err		EXCEPTION;
    l_tmpstmt			VARCHAR2(3000);
    l_bud_sqlstmt			VARCHAR2(5000);
    l_fc_sqlstmt			VARCHAR2(5000);
    l_bud_join_col_name		VARCHAR2(30) := NULL;
    l_fc_join_col_name		VARCHAR2(30) := NULL;
    l_bud_time_tab_name           VARCHAR2(30) := NULL;
    l_fc_time_tab_name            VARCHAR2(30) := NULL;
    l_bud_stg_col_name		VARCHAR2(30) := NULL;
    l_fc_stg_col_name		VARCHAR2(30) := NULL;

  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.rollup_stage');
    END IF;

    -- Determine which time column should be used for staging
    IF (FIIBUUP_BUDGET_TIME_UNIT = 'P') THEN
      l_bud_stg_col_name := 'PERIOD';
      l_bud_join_col_name := 'ent_period_id ';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Q') THEN
      l_bud_stg_col_name := 'QUARTER';
      l_bud_join_col_name := 'ent_qtr_id ';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Y') THEN
      l_bud_stg_col_name := 'YEAR';
      l_bud_join_col_name := 'ent_year_id ';
    END IF;

    IF (FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
      l_fc_stg_col_name := 'PERIOD';
      l_fc_join_col_name := 'ent_period_id ';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
      l_fc_stg_col_name := 'QUARTER';
      l_fc_join_col_name := 'ent_qtr_id ';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Y') THEN
      l_fc_stg_col_name := 'YEAR';
      l_fc_join_col_name := 'ent_year_id ';
    END IF;

    -- Determine which time table should be used
    IF (FIIBUUP_BUDGET_TIME_UNIT = 'P') THEN
      l_bud_time_tab_name := 'FII_TIME_ENT_PERIOD t';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Q') THEN
      l_bud_time_tab_name := 'FII_TIME_ENT_QTR t';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Y') THEN
      l_bud_time_tab_name := 'FII_TIME_ENT_YEAR t';
    END IF;

    IF (FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
      l_fc_time_tab_name := 'FII_TIME_ENT_PERIOD t';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
      l_fc_time_tab_name := 'FII_TIME_ENT_QTR t';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Y') THEN
      l_fc_time_tab_name := 'FII_TIME_ENT_YEAR t';
    END IF;

    -- The statment for stage needs to be built dynamically for
    -- budget and forecast
    g_phase := 'Build the SQL statement';

    -- Start building the SQL statement
    l_tmpstmt :=
      ' INSERT INTO FII_BUDGET_STG ( '||
        ' version_date, period, quarter, year, plan_type_code, '||
        ' creation_date, created_by, last_update_date, '||
        ' last_updated_by, last_update_login, ledger_id, '||
        ' company_cost_center_org_id, company_id, '||
        ' cost_center_id, fin_category_id, category_id, '||
        ' user_dim1_id, user_dim2_id, no_version_flag, '||
        ' overwrite_version_date, data_type, prim_amount_total, '||
        ' prim_amount_g, sec_amount_total, sec_amount_g) '||
      ' SELECT '||
        ' s.version_date, to_number(NULL), ';

      IF (FIIBUUP_BUDGET_TIME_UNIT = 'P') THEN
        l_bud_sqlstmt := l_tmpstmt || ' t.ent_qtr_id, t.ent_year_id, ';
      ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Q') THEN
        l_bud_sqlstmt := l_tmpstmt || ' to_number(NULL), t.ent_year_id, ';
      END IF;

      IF (FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
        l_fc_sqlstmt := l_tmpstmt ||
                        ' t.ent_qtr_id, t.ent_year_id, ';
      ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
        l_fc_sqlstmt := l_tmpstmt ||
                        ' to_number(NULL), t.ent_year_id, ';
      END IF;

      l_tmpstmt :=
        ' s.plan_type_code, sysdate, :user_id, sysdate, '||
        ' :user_id, :login_id, '||
        ' s.ledger_id, s.company_cost_center_org_id, '||
        ' s.company_id, s.cost_center_id, s.fin_category_id, '||
        ' s.category_id, s.user_dim1_id, s.user_dim2_id, '||
        ' s.no_version_flag, s.overwrite_version_date, s.data_type, '||
        ' SUM(s.prim_amount_total), SUM(s.prim_amount_g), '||
        ' SUM(s.sec_amount_total), SUM(s.sec_amount_g) '||
        ' FROM FII_BUDGET_STG s, ';

      IF (FIIBUUP_BUDGET_TIME_UNIT <> 'Y') THEN
        l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || l_bud_time_tab_name ||
                       ' WHERE s.plan_type_code = ''B'' ' ||
                       ' AND   s.' || l_bud_stg_col_name || ' = t.' ||
                       l_bud_join_col_name;
      END IF;

      IF (FIIBUUP_FORECAST_TIME_UNIT <> 'Y') THEN
        l_fc_sqlstmt := l_fc_sqlstmt || l_tmpstmt || l_fc_time_tab_name ||
                      ' WHERE s.plan_type_code = ''F'' ' ||
                       ' AND   s.' || l_fc_stg_col_name || ' = t.' ||
                       l_fc_join_col_name;
      END IF;

      l_tmpstmt :=
        ' AND   s.data_type in (-1, -2, -5) '||
        ' GROUP BY s.version_date, s.plan_type_code, sysdate, :user_id, '||
        ' sysdate, :user_id, :log_id, s.ledger_id, '||
        ' s.company_cost_center_org_id, s.company_id, s.cost_center_id, '||
        ' s.fin_category_id, s.category_id, s.user_dim1_id, s.user_dim2_id, '||
        ' s.no_version_flag, '||
        ' s.overwrite_version_date, s.data_type, ';

      IF (FIIBUUP_BUDGET_TIME_UNIT = 'P') THEN
        l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                         ' t.ent_year_id, ROLLUP(t.ent_qtr_id) ';
      ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Q') THEN
        l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || ' t.ent_year_id ';
      END IF;

      IF (FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
        l_fc_sqlstmt := l_fc_sqlstmt || l_tmpstmt ||
                        ' t.ent_year_id, ROLLUP(t.ent_qtr_id) ';
      ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
        l_fc_sqlstmt := l_fc_sqlstmt || l_tmpstmt || ' t.ent_year_id ';
      END IF;

    -- Print out the dynamic SQL statements if running in debug mode
    IF (FIIBUUP_DEBUG) THEN
      fii_util.put_line('l_bud_sqlstmt = '|| l_bud_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.rollup_stage()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_bud_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_bud_sqlstmt)));

      fii_util.put_line('l_fc_sqlstmt = '|| l_fc_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.rollup_stage()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_fc_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_fc_sqlstmt)));
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'rollup_stage()',
           t2        => 'ACTION',
           v2        => 'Rolling up staging records...');
    END IF;

    g_phase := 'Execute the built SQL l_bud_sqlstmt';

    IF (FIIBUUP_BUDGET_TIME_UNIT <> 'Y') THEN
      EXECUTE IMMEDIATE l_bud_sqlstmt
	USING FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
              FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID;
    END IF;

    IF (FIIBUUP_DEBUG) THEN
    FII_MESSAGE.Write_log
	(msg_name	=> 'FII_INST_REC',
	 token_num	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_STG');
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Rollup_Stage()',
           t2        => 'ACTION',
           v2        => 'Rolling up staging budget records...');
    END IF;

    g_phase := 'Execute the built SQL l_fc_sqlstmt';
    IF (FIIBUUP_FORECAST_TIME_UNIT <> 'Y') THEN
      EXECUTE IMMEDIATE l_fc_sqlstmt
	USING FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
              FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID;
    END IF;

    IF (FIIBUUP_DEBUG) THEN
    FII_MESSAGE.Write_log
	(msg_name	=> 'FII_INST_REC',
	 token_num	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_STG');
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Rollup_Stage()',
           t2        => 'ACTION',
           v2        => 'Rolling up staging forecast records...');
    END IF;

    -- rollup_stage completed, return with success
    IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'rollup_stage()',
           t2        => 'ACTION',
           v2        => 'rollup_stage done...');
    END IF;

    FND_CONCURRENT.Af_Commit;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.rollup_stage');
    END IF;
    RETURN TRUE;

  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.rollup_stage()');

      FII_MESSAGE.Func_Fail
	(func_name => 'FII_BUDGET_FORECAST_C.rollup_stage');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

    WHEN OTHERS THEN
      FND_CONCURRENT.Af_Rollback;

      -- SQL error occurs. Print out the error
      FII_MESSAGE.Write_Log(msg_name => 'FII_ERROR',
 			   token_num => 2,
			   t1	     => 'FUNCTION',
			   v1	     => 'FII_BUDGET_FORECAST_C.rollup_stage',
 			   t2	     => 'SQLERRMC',
			   v2	     => SQLERRM);

      FII_MESSAGE.Func_Fail
	(func_name => 'FII_BUDGET_FORECAST_C.rollup_stage');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

END Rollup_Stage;

-------------------------------------------------------------------------------
  --
  -- Procedure
  --    Adjust_Stage
  --
  -- Purpose
  --    For cases where we are overwriting existing records in fii_budget_base,
  --    we'll add the adjustment records we need to make to the rolled up
  --    time dimension into fii_budget_stg.
  -- Arguments
  --    version_date
  -- Example
  --    result := FII_BUDGET_FORECAST_C.Adjust_Stage;
  -- Notes
  --	Returns a boolean indicating if execution completes successfully
  FUNCTION Adjust_Stage RETURN BOOLEAN IS
    FIIBUUP_fatal_err		EXCEPTION;
    l_tmpstmt			VARCHAR2(3000);
    l_bud_sqlstmt			VARCHAR2(5000);
    l_fc_sqlstmt			VARCHAR2(5000);

  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.adjust_stage');
    END IF;

    -- The statment for stage needs to be built dynamically for
    -- budget and forecast
    g_phase := 'Build the SQL statement';

    -- Start building the SQL statement
    l_tmpstmt :=
      ' INSERT INTO FII_BUDGET_STG ( '||
        ' version_date, period, quarter, year, plan_type_code, '||
        ' creation_date, created_by, last_update_date, '||
        ' last_updated_by, last_update_login, ledger_id, '||
        ' company_cost_center_org_id, company_id, '||
        ' cost_center_id, fin_category_id, category_id, '||
        ' user_dim1_id, user_dim2_id, prim_amount_total, '||
        ' prim_amount_g, sec_amount_total, sec_amount_g, '||
        ' data_type, overwrite_version_date, no_version_flag ) '||
      ' SELECT '||
        ' version_date, period, quarter, year, plan_type_code, '||
        ' creation_date, created_by, last_update_date, '||
        ' last_updated_by, last_update_login, ledger_id, '||
        ' company_cost_center_org_id, company_id, '||
        ' cost_center_id, fin_category_id, category_id, '||
        ' user_dim1_id, user_dim2_id, prim_amount_total, '||
        ' prim_amount_g, sec_amount_total, sec_amount_g, '||
        ' data_type, overwrite_version_date, no_version_flag '||
      ' FROM  FII_BUDGET_BASE_T ';

    IF (FIIBUUP_BUDGET_TIME_UNIT = 'P') THEN
      l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                     ' WHERE period IS NULL AND plan_type_code = ''B'' ';
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Q') THEN
      l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt ||
                     ' WHERE quarter IS NULL AND plan_type_code = ''B'' ';
    END IF;

    IF (FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
      l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt ||
                     ' WHERE period IS NULL AND plan_type_code = ''F'' ';
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
      l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt ||
                     ' WHERE quarter IS NULL AND plan_type_code = ''F'' ';
    END IF;

    -- Print out the dynamic SQL statements if running in debug mode
    IF (FIIBUUP_DEBUG) THEN
      fii_util.put_line('l_bud_sqlstmt = '|| l_bud_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.adjust_stage()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_bud_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_bud_sqlstmt)));

      fii_util.put_line('l_fc_sqlstmt = '|| l_fc_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.adjust_stage()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_fc_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_fc_sqlstmt)));
      END IF;

    IF (FIIBUUP_BUDGET_TIME_UNIT <> 'Y') THEN
      IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'adjust_stage()',
           t2        => 'ACTION',
           v2        => 'Adjusting budget staging records...');
      END IF;

      g_phase := 'Execute the built SQL l_bud_sqlstmt';
      EXECUTE IMMEDIATE l_bud_sqlstmt;

      IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_log
	(msg_name	=> 'FII_INST_REC',
	 token_num	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_STG');
      END IF;
    END IF;

    IF (FIIBUUP_FORECAST_TIME_UNIT <> 'Y') THEN
      IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Adjust_Stage()',
           t2        => 'ACTION',
           v2        => 'Adjusting forecast staging records...');
      END IF;

      g_phase := 'Execute the built SQL l_fc_sqlstmt';
      EXECUTE IMMEDIATE l_fc_sqlstmt;

      IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_log
	(msg_name	=> 'FII_INST_REC',
	 token_num	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_STG');
      END IF;
    END IF;

    -- adjust_stage completed, return with success
    IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'adjust_stage()',
           t2        => 'ACTION',
           v2        => 'adjust_stage done...');
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.adjust_stage');
    END IF;
    RETURN TRUE;

  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.adjust_stage()');

      FII_MESSAGE.Func_Fail
	(func_name => 'FII_BUDGET_FORECAST_C.adjsut_stage');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

    WHEN OTHERS THEN
      FND_CONCURRENT.Af_Rollback;

      -- SQL error occurs. Print out the error
      FII_MESSAGE.Write_Log(msg_name => 'FII_ERROR',
 			   token_num => 2,
			   t1	     => 'FUNCTION',
			   v1	     => 'FII_BUDGET_FORECAST_C.adjust_stage',
 			   t2	     => 'SQLERRMC',
			   v2	     => SQLERRM);

      FII_MESSAGE.Func_Fail
	(func_name => 'FII_BUDGET_FORECAST_C.adjust_stage');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

END Adjust_Stage;

-------------------------------------------------------------------------------
  --
  -- Procedure
  --    Merge
  --
  -- Purpose
  --    This routine will add new records or update existing records with
  --    the new amounts into fii_budget_base.
  -- Arguments
  --    version_date
  -- Example
  --    result := FII_BUDGET_FORECAST_C.Merge;
  -- Notes
  --	Returns a boolean indicating if execution completes successfully
  FUNCTION Merge RETURN BOOLEAN IS
    FIIBUUP_fatal_err		EXCEPTION;
    l_tmpstmt			VARCHAR2(5000);
    l_bud_sqlstmt			VARCHAR2(5000);
    l_fc_sqlstmt			VARCHAR2(5000);
    l_per_type_id               NUMBER;

  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.merge');
    END IF;

    -- The statment for stage needs to be built dynamically for
    -- budget and forecast
    g_phase := 'Build the SQL statement';

    -- Start building the SQL statement
    l_tmpstmt :=
      ' MERGE /*+ PARALLEL(b)*/  INTO FII_BUDGET_BASE b '||
      ' USING '||
      ' (SELECT /*+ PARALLEL(stg)*/   '||
        ' version_date, plan_type_code, '||
        ' NVL(period, NVL(quarter, year)) time_id, '||
        ' DECODE(period, '||
               ' null, DECODE(quarter, '||
                           ' null, 128, 64), 32) PERIOD_TYPE_ID, '||
        ' ledger_id, company_cost_center_org_id, '||
        ' company_id, cost_center_id, fin_category_id, '||
        ' category_id, user_dim1_id, user_dim2_id, '||
        ' no_version_flag, sum(prim_amount_total) PRIM_AMOUNT_TOTAL, '||
        ' sum(sec_amount_total) SEC_AMOUNT_TOTAL, '||
        ' sum(prim_amount_g) PRIM_AMOUNT_G, '||
        ' sum(sec_amount_g) SEC_AMOUNT_G '||
      ' FROM FII_BUDGET_STG stg ' ||
      ' WHERE plan_type_code = :plan_type_code '||
      ' GROUP BY version_date, plan_type_code, '||
               ' NVL(period, NVL(quarter, year)), '||
               ' DECODE(period, '||
                      ' null, DECODE(quarter, '||
                                     ' null, 128, 64), 32), '||
               ' ledger_id, company_cost_center_org_id, '||
               ' company_id, cost_center_id, fin_category_id, '||
               ' category_id, user_dim1_id, user_dim2_id, '||
               ' no_version_flag) s '||
      ' ON(    b.plan_type_code        = s.plan_type_code '||
         ' AND b.time_id               = s.time_id '||
         ' AND b.period_type_id        = s.period_type_id '||
         ' AND b.version_date          = s.version_date '||
         ' AND b.ledger_id             = s.ledger_id '||
         ' AND b.company_id            = s.company_id '||
         ' AND b.cost_center_id        = s.cost_center_id '||
         ' AND b.fin_category_id       = s.fin_category_id '||
         ' AND NVL(b.category_id, -1)  = NVL(s.category_id, -1) '||
         ' AND b.user_dim1_id          = s.user_dim1_id '||
         ' AND b.user_dim2_id          = s.user_dim2_id) '||
      ' WHEN MATCHED THEN UPDATE SET ' ||
	 ' b.prim_amount_total = decode(b.period_type_id, '||
                           ' :per_type_id, s.prim_amount_total, '||
                           ' b.prim_amount_total + s.prim_amount_total), '||
         ' b.prim_amount_g = decode(b.period_type_id, '||
                           ' :per_type_id, s.prim_amount_g, '||
                           ' b.prim_amount_g + s.prim_amount_g), '||
	 ' b.sec_amount_total = decode(b.period_type_id, '||
                           ' :per_type_id, s.sec_amount_total, '||
                           ' b.sec_amount_total + s.sec_amount_total), '||
         ' b.sec_amount_g = decode(b.period_type_id, '||
                           ' :per_type_id, s.sec_amount_g, '||
                           ' b.sec_amount_g + s.sec_amount_g), '||
         ' b.no_version_flag =  s.no_version_flag, '||
         ' b.company_cost_center_org_id = s.company_cost_center_org_id, '||
	 ' b.last_update_date = SYSDATE, '||
	 ' b.last_updated_by = :user_id, '||
	 ' b.last_update_login = :login_id, '||
         ' b.upload_date = SYSDATE '||
       ' WHEN NOT MATCHED THEN INSERT '||
       ' (b.version_date, b.plan_type_code, b.time_id, b.period_type_id,'||
       '  b.ledger_id, b.company_cost_center_org_id, '||
       '  b.company_id, b.cost_center_id, b.fin_category_id, '||
       '  b.category_id, '||
       '  b.user_dim1_id, b.user_dim2_id, '||
       '  b.prim_amount_total, b.prim_amount_g, '||
       '  b.sec_amount_total, b.sec_amount_g, b.no_version_flag, '||
       '  b.creation_date, b.created_by, '||
       '  b.last_update_date, b.last_updated_by, b.last_update_login, '||
       '  b.upload_date, b.posted_date) '||
       ' VALUES '||
       ' (s.version_date, s.plan_type_code, s.time_id, s.period_type_id, '||
       '  s.ledger_id, s.company_cost_center_org_id, '||
       '  s.company_id, s.cost_center_id, s.fin_category_id, '||
       '  s.category_id, '||
       '  s.user_dim1_id, s.user_dim2_id, '||
       '  s.prim_amount_total, s.prim_amount_g, '||
       '  s.sec_amount_total, s.sec_amount_g, s.no_version_flag, '||
       '  SYSDATE, :user_id, SYSDATE, '||
       '  :user_id, :login_id, SYSDATE, :default_posted_date) ';


    -- Print out the dynamic SQL statements if running in debug mode
    IF (FIIBUUP_DEBUG) THEN
      fii_util.put_line('merge stmt = '|| l_tmpstmt );

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.merge()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_tmpstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_tmpstmt)));

    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'merge()',
           t2        => 'ACTION',
           v2        => 'Merging budget records into fii_budget_base...');
    END IF;

    g_phase := 'Execute the built SQL l_tmpstmt';
    IF (FIIBUUP_BUDGET_TIME_UNIT = 'P') THEN
      l_per_type_id := 32;
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Q') THEN
      l_per_type_id := 64;
    ELSIF (FIIBUUP_BUDGET_TIME_UNIT = 'Y') THEN
      l_per_type_id := 128;
    END IF;

    EXECUTE IMMEDIATE l_tmpstmt
      USING 'B', l_per_type_id, l_per_type_id, l_per_type_id, l_per_type_id,
            FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
            FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
            FIIBUUP_GLOBAL_START_DATE;

    IF (FIIBUUP_DEBUG) THEN
    FII_MESSAGE.Write_log
	(msg_name	=> 'FII_INST_REC',
	 token_num	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_BASE');
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'merge()',
           t2        => 'ACTION',
           v2        => 'Merging forecast records into fii_budget_base...');
    END IF;

    -- Bug 4674640: Added commit after enabling parallel dml
    FND_CONCURRENT.Af_Commit;

    g_phase := 'Execute the built SQL l_tmpstmt';
    IF (FIIBUUP_FORECAST_TIME_UNIT = 'P') THEN
      l_per_type_id := 32;
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Q') THEN
      l_per_type_id := 64;
    ELSIF (FIIBUUP_FORECAST_TIME_UNIT = 'Y') THEN
      l_per_type_id := 128;
    END IF;

    EXECUTE IMMEDIATE l_tmpstmt
      USING 'F', l_per_type_id, l_per_type_id, l_per_type_id, l_per_type_id,
            FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
            FIIBUUP_USER_ID, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID,
            FIIBUUP_GLOBAL_START_DATE;

    IF (FIIBUUP_DEBUG) THEN
    FII_MESSAGE.Write_log
	(msg_name	=> 'FII_INST_REC',
	 token_num	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_BASE');
    END IF;

    FND_CONCURRENT.Af_Commit;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.merge');
    END IF;
    RETURN TRUE;

  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.merge()');

      FII_MESSAGE.Func_Fail
	(func_name => 'FII_BUDGET_FORECAST_C.merge');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

    WHEN OTHERS THEN
      FND_CONCURRENT.Af_Rollback;

      -- SQL error occurs. Print out the error
      FII_MESSAGE.Write_Log(msg_name => 'FII_ERROR',
 			   token_num => 2,
			   t1	     => 'FUNCTION',
			   v1	     => 'FII_BUDGET_FORECAST_C.merge',
 			   t2	     => 'SQLERRMC',
			   v2	     => SQLERRM);

      FII_MESSAGE.Func_Fail
	(func_name => 'FII_BUDGET_FORECAST_C.merge');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

END Merge;

--------------------------------------------------------------------------------
  --
  -- Procedure
  --    Adjust_Ver_Date
  --
  -- Purpose
  --    This routine update the version_date of the record which has a version
  --    date in the current upload but did not have a version date in prior
  --    upload.
  -- Arguments
  --    version_date
  -- Example
  --    result := FII_BUDGET_FORECAST_C.Adjust_Ver_Date;
  -- Notes
  --	Returns a boolean indicating if execution completes successfully
  FUNCTION Adjust_Ver_Date RETURN BOOLEAN IS
    FIIBUUP_fatal_err		EXCEPTION;
    l_tmpstmt			VARCHAR2(3000);
    l_bud_sqlstmt			VARCHAR2(5000);
    l_fc_sqlstmt			VARCHAR2(5000);

  BEGIN

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.adjust_ver_date');
    END IF;

    -- The statment for stage needs to be built dynamically for
    -- budget and forecast
    g_phase := 'Build the SQL statement';

    -- Start building the SQL statement
    l_tmpstmt :=
      ' UPDATE FII_BUDGET_BASE b '||
      ' SET (b.version_date, b.no_version_flag) = '||
          ' (SELECT MAX(s.overwrite_version_date), MAX(s.no_version_flag) '||
          '  FROM   FII_BUDGET_STG s '||
          '  WHERE  ';

    l_bud_sqlstmt := l_tmpstmt || ' s.plan_type_code = ''B'' ';
    l_fc_sqlstmt  := l_tmpstmt || ' s.plan_type_code = ''F'' ';

    l_tmpstmt :=
          '  AND  s.version_date = b.version_date '||
          '  AND    s.ledger_id = b.ledger_id '||
          '  AND    s.company_id = b.company_id '||
          '  AND    s.cost_center_id = b.cost_center_id '||
          '  AND    s.fin_category_id = b.fin_category_id '||
          '  AND    s.user_dim1_id = b.user_dim1_id '||
          '  AND    s.version_date = b.version_date '||
          '  AND    s.data_type = -4) '||
      ' WHERE (b.plan_type_code, b.time_id, b.period_type_id, b.ledger_id, '||
             ' b.company_id, b.cost_center_id, b.fin_category_id, b.category_id, '||
             ' b.user_dim1_id, b.user_dim2_id, b.version_date'||
             ' ) IN ( '||
             '   SELECT s2.plan_type_code, '||
                      ' NVL(s2.period, NVL(s2.quarter, s2.year)), '||
                      ' DECODE(period,  null, DECODE(quarter,  null, 128, 64), 32), '||
                      ' ledger_id, company_id, cost_center_id, fin_category_id, '||
                      ' category_id, user_dim1_id, user_dim2_id, version_date '||
               ' FROM fii_budget_stg s2 '||
               ' WHERE data_type = -4) ';

    l_bud_sqlstmt := l_bud_sqlstmt || l_tmpstmt || ' AND   b.plan_type_code = ''B'' ';
    l_fc_sqlstmt  := l_fc_sqlstmt  || l_tmpstmt || ' AND   b.plan_type_code = ''F'' ';

    -- Print out the dynamic SQL statements if running in debug mode
    IF (FIIBUUP_DEBUG) THEN
      fii_util.put_line('adjust_ver_date l_bud_sqlstmt = '|| l_bud_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.adjust_ver_date()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_bud_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_bud_sqlstmt)));

      fii_util.put_line('adjust_ver_date l_fc_sqlstmt = '|| l_fc_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.adjust_ver_date()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_fc_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_fc_sqlstmt)));

    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'adjust_ver_date()',
           t2        => 'ACTION',
           v2        => 'Adjusting verion dates for budgets...');
    END IF;

    g_phase := 'Execute the built SQL l_bud_sqlstmt';
    EXECUTE IMMEDIATE l_bud_sqlstmt;

    IF (FIIBUUP_DEBUG) THEN
    FII_MESSAGE.Write_log
	(msg_name	=> 'FII_INST_REC',
	 token_num	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_BASE');
    END IF;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'adjust_ver_date()',
           t2        => 'ACTION',
           v2        => 'Adjusting verion dates for forecasts...');
    END IF;

    g_phase := 'Execute the built SQL l_fc_sqlstmt';
    EXECUTE IMMEDIATE l_fc_sqlstmt;

    IF (FIIBUUP_DEBUG) THEN
    FII_MESSAGE.Write_log
	(msg_name	=> 'FII_INST_REC',
	 token_num	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_BASE');
    END IF;

    FND_CONCURRENT.Af_Commit;

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ('FII_BUDGET_FORECAST_C.adjust_ver_date');
    END IF;
    RETURN TRUE;

  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN
      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	(msg_name  => 'FII_ERR_ENC_ROUT',
         token_num => 1,
         t1        => 'ROUTINE_NAME',
         v1        => 'FII_BUDGET_FORECAST_C.adjust_ver_date()');

      FII_MESSAGE.Func_Fail
	(func_name => 'FII_BUDGET_FORECAST_C.adjust_ver_date');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

    WHEN OTHERS THEN
      FND_CONCURRENT.Af_Rollback;

      -- SQL error occurs. Print out the error
      FII_MESSAGE.Write_Log(msg_name => 'FII_ERROR',
 			   token_num => 2,
			   t1	     => 'FUNCTION',
			   v1	     =>'FII_BUDGET_FORECAST_C.adjust_ver_date',
 			   t2	     => 'SQLERRMC',
			   v2	     => SQLERRM);

      FII_MESSAGE.Func_Fail
	(func_name => 'FII_BUDGET_FORECAST_C.adjust_ver_date');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);
      RETURN FALSE;

END Adjust_Ver_Date;

/************************************************************************
     			 PUBLIC PROCEDURES
************************************************************************/

-------------------------------------------------------------------------------

  -- Procedure
  --   	Main
  -- Purpose
  --   	This is the main routine of the DBI budget upload program
  -- History
  --   	05-03-02	 S Kung	        Created
  -- Arguments
  -- 	X_Mode: Mode of Operation.  Either U (Upload) or P (Purge)
  --    X_Plan_Type	: Plan type to operate on.  Either B (Budget)
  --		     	  or F (Forecast).  Used only in Purge.
  --    X_Time_Unit	: Either D (Daily), P (Period), Q (Quarter), Y (Year),
  --		     	  or A (All).  Used only in Purge.
  --    X_Date	   	: Purge date
  --	X_Time_Period   : Purge period (Other than date)
  --    X_Debug    	: Debug mode indicator
  -- Example
  --    result := FII_BUDGET_FORECAST_C.Main;
  -- Notes
  --
  PROCEDURE Main(X_Mode			VARCHAR2,
		 X_Plan_Type		VARCHAR2,
		 X_Time_Unit		VARCHAR2,
		 X_Purge_Date		VARCHAR2,
		 X_Purge_Time_Period	VARCHAR2,
                 X_Purge_Eff_Date       VARCHAR2,
		 X_Debug		VARCHAR2) IS
    FIIBUUP_fatal_err		EXCEPTION;
    l_ret_status		BOOLEAN;
    l_ret_code                  VARCHAR2(1);
    l_int_count			NUMBER;
    l_prev_bud_time_unit	VARCHAR2(1) := NULL;
    l_prev_fc_time_unit		VARCHAR2(1) := NULL;
    l_time_unit_changed		BOOLEAN	:= FALSE;
    l_drop_bud_data		VARCHAR2(1);
    l_drop_fc_data		VARCHAR2(1);

    l_status                  VARCHAR2(30);
    l_industry                VARCHAR2(30);
    l_fii_schema              VARCHAR2(30);
    l_version_date            DATE;
    l_null_ver_date_flag      VARCHAR2(1);
    l_budget_source           VARCHAR2(15);
    l_industry_profile        VARCHAR2(1);
    l_psi_bud_from_bal        VARCHAR2(1);
    l_vs_id                   NUMBER;
    l_ret_num                 NUMBER;

    CURSOR ver_date_cur IS
      SELECT DISTINCT trunc(version_date)
      FROM fii_budget_interface
      WHERE trunc(version_date) IS NOT NULL
      ORDER BY trunc(version_date);

    CURSOR null_ver_date IS
      SELECT 'Y'
      FROM fii_budget_interface
      WHERE version_date IS NULL;

  BEGIN
    l_drop_bud_data := 'N';
    l_drop_fc_data  := 'N';

    IF FND_PROFILE.value('FII_DEBUG_MODE') = 'Y' THEN
      FII_MESSAGE.Func_Ent('FII_BUDGET_FORECAST_C.Main');
    END IF;

    -- Determine if process will be run in debug mode
    IF (NVL(X_Debug, 'N') <> 'N') THEN
      FIIBUUP_DEBUG := TRUE;
    ELSE
      FIIBUUP_DEBUG := FALSE;
      IF FND_PROFILE.value('FII_DEBUG_MODE') = 'Y' then
         FIIBUUP_DEBUG := TRUE;
      END IF;
    END IF;

    -- Turn trace on if process is run in debug mode
    IF (FIIBUUP_DEBUG) THEN

      -- Program running in debug mode, turning trace on
      FII_MESSAGE.Write_Log(msg_name	=> 'FII_CONC_PRG_DEBUG',
			    token_num	=> 0);

      EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE TRUE';

    END IF;

    -- Find out if this is commercial or government install
    l_industry_profile := FND_PROFILE.value('INDUSTRY');

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Main()',
         t2        	=> 'VARIABLE',
         v2        	=> 'Industry',
         t3        	=> 'VALUE',
         v3        	=> l_industry_profile);
    END IF;

    --
    -- Enhancement 6397914: Added an option for PSI customers to optionally
    -- extract their budget data from gl_balances.
    --
    -- If Industry = 'G', and 'FII: Budget Data from GL Balances' is set to 'YES',
    -- then we'll call 'FII_GL_BUDGET_EXTRACTION() to extract budget data from
    -- GL BALANACES.
    -- This behavior will be same as if Industry = 'C' and budget source = 'GL'.

    IF (X_Mode = 'U' AND l_industry_profile = 'G') THEN
      -- If the Industry = 'G', find out if we should retrieve the
      -- budget data from GL_BALANCES

      l_psi_bud_from_bal := FND_PROFILE.value('FII_PSI_BUDGET_FROM_BAL');

      IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  	=> 'FII_ROUTINE_VAL',
           token_num 	=> 3 ,
           t1        	=> 'ROUTINE',
           v1        	=> 'FII_BUDGET_FORECAST_C.Main()',
           t2        	=> 'VARIABLE',
           v2        	=> 'FII: Budget Data from GL Balances',
           t3        	=> 'VALUE',
           v3        	=> l_psi_bud_from_bal);
      END IF;

      -- If the FII: Budget Data from GL Balances profile is turned on,
      -- then we'll retrive budget data from gl_balances.
      -- This is the same behavior when Industry = 'C' and
      -- budget source = 'GL'.
      -- Otherwise, if the profile is not turned on, we'll call
      -- Psi_Budget_Extract() and extract the budget data from budget journals.

      IF (l_psi_bud_from_bal = 'Y') THEN

        FII_GL_BUDGET_EXTRACTION.main(l_ret_code);

        IF (l_ret_code = 'E') THEN
          -- GL Budget Extraction program has failed.
          raise FIIBUUP_fatal_err;
        ELSIF (l_ret_code = 'W') THEN
          -- GL Budget Extraction program ends with warnings.
          l_ret_status := FND_CONCURRENT.Set_Completion_Status
	       	                (status	 => 'WARNING', message => NULL);

          RETURN;
        ELSE
          -- GL Budget Extraction program completes successfully.
          IF (FIIBUUP_DEBUG) THEN
            FII_MESSAGE.Func_Succ(func_name => 'FII_BUDGET_FORECAST_C.Main');
          END IF;

          l_ret_status := FND_CONCURRENT.Set_Completion_Status
	        	        (status	 => 'COMPLETE', message => NULL);

          RETURN;
        END IF;
      END IF;
     END IF;

    IF (X_Mode = 'U' AND l_industry_profile = 'C') THEN
      -- Call Budget Upload or GL Budget Extraction depending on profile
      l_budget_source := FND_PROFILE.value('FII_BUDGET_SOURCE');

      IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  	=> 'FII_ROUTINE_VAL',
           token_num 	=> 3 ,
           t1        	=> 'ROUTINE',
           v1        	=> 'FII_BUDGET_FORECAST_C.Main()',
           t2        	=> 'VARIABLE',
           v2        	=> 'Budget Source',
           t3        	=> 'VALUE',
           v3        	=> l_budget_source);
      END IF;

      -- If profile is set to GL, call the GL Budget Extraction program
      IF l_budget_source = 'GL' THEN
        FII_GL_BUDGET_EXTRACTION.main(l_ret_code);

        IF (l_ret_code = 'E') THEN
          -- GL Budget Extraction program has failed.
          raise FIIBUUP_fatal_err;
        ELSIF (l_ret_code = 'W') THEN
          -- GL Budget Extraction program ends with warnings.
          l_ret_status := FND_CONCURRENT.Set_Completion_Status
	       	                (status	 => 'WARNING', message => NULL);

          RETURN;
        ELSE
          -- GL Budget Extraction program completes successfully.
          IF (FIIBUUP_DEBUG) THEN
            FII_MESSAGE.Func_Succ(func_name => 'FII_BUDGET_FORECAST_C.Main');
          END IF;

          l_ret_status := FND_CONCURRENT.Set_Completion_Status
	        	        (status	 => 'COMPLETE', message => NULL);

          RETURN;
        END IF;
      END IF;

      -- Make sure that profile option value is set to WEBADI
      IF l_budget_source <> 'WEBADI' THEN
        FII_MESSAGE.Write_Log
	  (msg_name	=> 'FII_BUDGET_DATA_SOURCE_ERROR',
  	   token_num	=> 0);

        raise FIIBUUP_fatal_err;
      END IF;
    END IF;

    -- Check if all input parameters are valid
    IF (NVL(X_Mode, 'X') <> 'U' AND NVL(X_Mode, 'X') <> 'P') THEN
      FII_MESSAGE.Write_Log
	(msg_name	=> 'FII_INV_OPER',
	 token_num	=> 0);

      raise FIIBUUP_fatal_err;
    ELSIF (X_Mode = 'P') THEN
      -- Running in Purge mode, check for plan_type
      IF (    (	   X_Plan_Type is NULL
		OR X_Plan_Type NOT IN ('B', 'F'))
	  OR  (	   X_Time_Unit is NULL
	        OR X_Time_Unit NOT IN ('D', 'P', 'Q', 'Y', 'A')))    THEN
	FII_MESSAGE.Write_Log
	  (msg_name	=> 'FII_INV_PAR_PURG',
	   token_num	=> 0);

	raise FIIBUUP_fatal_err;
      END IF;

      FIIBUUP_PURGE_PLAN_TYPE 	:= X_Plan_Type;
      FIIBUUP_PURGE_TIME_UNIT 	:= X_Time_Unit;
      FIIBUUP_PURGE_TIME_PERIOD := X_Purge_Time_Period;
      FIIBUUP_PURGE_DATE	:=
		TO_DATE(X_Purge_Date, 'YYYY/MM/DD HH24:MI:SS');
      FIIBUUP_PURGE_EFF_DATE    :=
                TO_DATE(X_Purge_Eff_Date, 'YYYY/MM/DD HH24:MI:SS');
    END IF;

    /* fix by ilavenil, gather statistics on fii_budget_interface*/
    IF (FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry,
                                      l_fii_schema)) THEN
        FND_STATS.GATHER_TABLE_STATS(
               OWNNAME => l_fii_schema,
               TABNAME => 'FII_BUDGET_INTERFACE');

        -- Bug 4674640: Should enable parallel dml after calling
        -- gather stats
	execute immediate 'alter session enable parallel dml';
    END IF;

    g_phase := 'Get all set up information';
    BEGIN
      -- Get all set up information
      FIIBUUP_PRIM_CURR_CODE 	:=
	BIS_COMMON_PARAMETERS.get_currency_code;

      FIIBUUP_SEC_CURR_CODE 	:=
	BIS_COMMON_PARAMETERS.get_secondary_currency_code;

      FIIBUUP_PRIM_CURR_MAU 	:= FII_CURRENCY.get_mau_primary;
      FIIBUUP_SEC_CURR_MAU  	:= FII_CURRENCY.get_mau_secondary;
      FIIBUUP_USER_ID 		:= FND_GLOBAL.User_Id;
      FIIBUUP_LOGIN_ID		:= FND_GLOBAL.Login_Id;
      FIIBUUP_REQ_ID		:= FND_GLOBAL.Conc_Request_Id;

      FIIBUUP_GLOBAL_START_DATE :=
        TO_DATE(FND_PROFILE.Value('BIS_GLOBAL_START_DATE'),'MM/DD/YYYY');
      FIIBUUP_BUDGET_TIME_UNIT	:=
	FND_PROFILE.Value('FII_BUDGET_TIME_UNIT');
      FIIBUUP_FORECAST_TIME_UNIT	:=
	FND_PROFILE.Value('FII_FORECAST_TIME_UNIT');

      IF (FIIBUUP_BUDGET_TIME_UNIT is NULL) THEN
	-- Print out log message and use default
        IF (FIIBUUP_DEBUG) THEN
	FII_MESSAGE.Write_Log
	  (msg_name	=> 'FII_INV_PRF_OPT',
	   token_num	=> 2,
	   t1		=> 'PROFILE_NAME',
	   v1		=> 'FII_BUDGET_TIME_UNIT',
	   t2		=> 'DEFAULT',
	   V2		=> 'P');
        END IF;

   	FIIBUUP_BUDGET_TIME_UNIT := 'P';
      END IF;

      IF (FIIBUUP_FORECAST_TIME_UNIT is NULL) THEN
	-- Print out log message and use default
        IF (FIIBUUP_DEBUG) THEN
	FII_MESSAGE.Write_Log
	  (msg_name	=> 'FII_INV_PRF_OPT',
	   token_num	=> 2,
	   t1		=> 'PROFILE_NAME',
	   v1		=> 'FII_FORECAST_TIME_UNIT',
	   t2		=> 'DEFAULT',
	   v2		=> 'P');
        END IF;

	FIIBUUP_FORECAST_TIME_UNIT := 'P';
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
	RAISE FIIBUUP_fatal_err;
    END;

    -- If any of the above values is not set, error out
    -- Bug fix 2650924
    -- Note that we will not error out when secondary currency
    -- is not set.  This is because the secondary currency is
    -- optional
    IF (FIIBUUP_USER_ID is NULL OR
	FIIBUUP_LOGIN_ID is NULL OR
	FIIBUUP_REQ_ID is NULL OR
	FIIBUUP_PRIM_CURR_CODE is NULL OR
 	FIIBUUP_PRIM_CURR_MAU is NULL OR
	FIIBUUP_BUDGET_TIME_UNIT is NULL OR
	FIIBUUP_FORECAST_TIME_UNIT is NULL) THEN

      -- Fail to initialize
      FII_MESSAGE.Write_Log (msg_name	=> 'FII_FAIL_INT_PAR_CON_PRG',
			     token_num	=> 0);

      RAISE FIIBUUP_fatal_err;
    END IF;

    -- Print program run information
    IF (FIIBUUP_DEBUG) THEN

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Main()',
         t2        	=> 'VARIABLE',
         v2        	=> 'Operation Mode',
         t3        	=> 'VALUE',
         v3        	=> X_Mode);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Main()',
         t2        	=> 'VARIABLE',
         v2        	=> 'Plan Type',
         t3        	=> 'VALUE',
         v3        	=> NVL(FIIBUUP_PURGE_PLAN_TYPE, 'N/A'));

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Main()',
         t2        	=> 'VARIABLE',
         v2        	=> 'Purge Time Unit',
         t3        	=> 'VALUE',
         v3        	=> NVL(FIIBUUP_PURGE_TIME_UNIT, 'N/A'));

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Main()',
         t2        	=> 'VARIABLE',
         v2        	=> 'Purge Date',
         t3        	=> 'VALUE',
         v3        	=> NVL(TO_CHAR(FIIBUUP_PURGE_DATE,  'YYYY/MM/DD HH24:MI:SS'), 'N/A'));

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Main()',
         t2        	=> 'VARIABLE',
         v2        	=> 'Purge Period',
         t3        	=> 'VALUE',
         v3        	=> NVL(FIIBUUP_PURGE_TIME_PERIOD, 'N/A'));

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Main()',
         t2        	=> 'VARIABLE',
         v2        	=> 'Purge Effective Date',
         t3        	=> 'VALUE',
         v3        	=> NVL(TO_CHAR(FIIBUUP_PURGE_EFF_DATE, 'YYYY/MM/DD HH24:MI:SS'), 'N/A'));

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Main()',
         t2        	=> 'VARIABLE',
         v2        	=> 'Debug Mode',
         t3        	=> 'VALUE',
         v3        	=> NVL(X_Debug, 'N'));

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Main()',
         t2        	=> 'VARIABLE',
         v2        	=> 'Primary Global Currency',
         t3        	=> 'VALUE',
         v3        	=> NVL(FIIBUUP_PRIM_CURR_CODE, 'NULL'));

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Main()',
         t2        	=> 'VARIABLE',
         v2        	=> 'Secondary Global Currency',
         t3        	=> 'VALUE',
         v3        	=> NVL(FIIBUUP_SEC_CURR_CODE, 'NULL'));

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Main()',
         t2        	=> 'VARIABLE',
         v2        	=> 'Budget Time Unit',
         t3        	=> 'VALUE',
         v3        	=> FIIBUUP_BUDGET_TIME_UNIT);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_BUDGET_FORECAST_C.Main()',
         t2        	=> 'VARIABLE',
         v2        	=> 'Forecast Time Unit',
         t3        	=> 'VALUE',
         v3        	=> FIIBUUP_FORECAST_TIME_UNIT);

    END IF;

    -- Then, get prior time unit setting from FII_CHANGE_LOG
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Main()',
           t2        => 'ACTION',
           v2        => 'Checking prior time unit settings...');
    END IF;

    -- Find out the unassigned ID we should use for UDD1 and UDD2
    FII_GL_EXTRACTION_UTIL.get_unassigned_id(FIIBUUP_UNASSIGNED_UDD_ID,
                                             l_vs_id, l_ret_num);

    IF(l_ret_num = -1) THEN
      RAISE FIIBUUP_fatal_err;
    END IF;

    -- Done gathering setup info.  If this is a government install,
    -- and we are running budget upload, call psi_budget_extract
    IF (X_Mode = 'U' AND l_industry_profile = 'G') THEN
      -- Call the PSI Budget Extraction routine since this is a
      -- government install

      FII_BUDGET_FORECAST_C.Psi_Budget_Extract(l_ret_code);

        -- Bug 4674640: Added gather stats for the budget base table
        FND_STATS.gather_table_stats
               (ownname => l_fii_schema,
                tabname => 'FII_BUDGET_BASE');

	execute immediate 'alter session enable parallel dml';

      IF (l_ret_code = 'E') THEN
        -- PSI Budget Extraction program has failed.
        raise FIIBUUP_fatal_err;

      ELSIF (l_ret_code = 'W') THEN
        -- PSI Budget Extraction program ends with warnings.
        l_ret_status := FND_CONCURRENT.Set_Completion_Status
	               (status	 => 'WARNING', message => NULL);

        RETURN;

      ELSE
        IF (FIIBUUP_DEBUG) THEN
          FII_MESSAGE.Func_Succ(func_name => 'FII_BUDGET_FORECAST_C.Main');
        END IF;

        l_ret_status := FND_CONCURRENT.Set_Completion_Status
	      	        (status	 => 'COMPLETE', message => NULL);
        RETURN;
      END IF;
    END IF;

    g_phase := 'Get prior time unit setting from FII_CHANGE_LOG';
    BEGIN
      SELECT l.item_value
      INTO l_prev_bud_time_unit
      FROM FII_CHANGE_LOG l
      WHERE l.log_item = 'BUDGET_TIME_UNIT';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	  INSERT INTO FII_CHANGE_LOG
	  (log_item, item_value, creation_date, created_by,
	   last_update_date, last_updated_by, last_update_login)
	  VALUES
	  ('BUDGET_TIME_UNIT', FIIBUUP_BUDGET_TIME_UNIT, SYSDATE,
	   FIIBUUP_USER_ID, SYSDATE, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID);

	  l_prev_bud_time_unit := FIIBUUP_BUDGET_TIME_UNIT;
    END;

    BEGIN
      SELECT l.item_value
      INTO l_prev_fc_time_unit
      FROM FII_CHANGE_LOG l
      WHERE l.log_item = 'FORECAST_TIME_UNIT';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	  INSERT INTO FII_CHANGE_LOG
	  (log_item, item_value, creation_date, created_by,
	   last_update_date, last_updated_by, last_update_login)
	  VALUES
	  ('FORECAST_TIME_UNIT', FIIBUUP_FORECAST_TIME_UNIT, SYSDATE,
	   FIIBUUP_USER_ID, SYSDATE, FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID);

	  l_prev_fc_time_unit := FIIBUUP_FORECAST_TIME_UNIT;
    END;

    -- Print FII_CHANGE_LOG information
    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Write_Log
	  (msg_name  	=> 'FII_ROUTINE_VAL',
           token_num 	=> 3 ,
           t1        	=> 'ROUTINE',
           v1        	=> 'FII_BUDGET_FORECAST_C.Main()',
           t2        	=> 'VARIABLE',
           v2        	=> 'l_prev_bud_time_unit',
           t3        	=> 'VALUE',
           v3        	=> l_prev_bud_time_unit);

      FII_MESSAGE.Write_Log
	  (msg_name  	=> 'FII_ROUTINE_VAL',
           token_num 	=> 3 ,
           t1        	=> 'ROUTINE',
           v1        	=> 'FII_BUDGET_FORECAST_C.Main()',
           t2        	=> 'VARIABLE',
           v2        	=> 'l_prev_fc_time_unit',
           t3        	=> 'VALUE',
           v3        	=> l_prev_fc_time_unit);
    END IF;

    g_phase := 'Check FII_CHANGE_LOG and see if truncation is needed';
    IF (X_Mode = 'U') THEN

      -- First, get from the FII_CHANGE_LOG and see if truncation is
      -- needed
      IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Main()',
           t2        => 'ACTION',
           v2        => 'Check for truncate flags...');
      END IF;

      BEGIN
	SELECT l1.item_value
      	INTO l_drop_bud_data
      	FROM FII_CHANGE_LOG l1
      	WHERE l1.log_item = 'TRUNCATE_BUDGET';
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  NULL;
      END;

      BEGIN
	SELECT l1.item_value
      	INTO l_drop_fc_data
      	FROM FII_CHANGE_LOG l1
      	WHERE l1.log_item = 'TRUNCATE_FORECAST';
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  NULL;
      END;

      -- Here, we will do the following for both budget and forecast:
      -- 1) If the prior time unit setting is different from the
      --    current setting, tell users that truncation is needed
      --    and error out.
      -- 2) If the prior and current time unit setting is identical,
      --    but the truncation flag is set to Y, we assume that users
      --    have restored to the prior time unit setting and truncation
      --    is no longer needed.  In this case, we reset the truncation
      --    flag back to N.

      IF (NVL(l_prev_bud_time_unit, FIIBUUP_BUDGET_TIME_UNIT) <>
	  FIIBUUP_BUDGET_TIME_UNIT) THEN

        IF (FIIBUUP_DEBUG) THEN
          FII_MESSAGE.Write_Log
	    (msg_name  => 'FII_ROUTINE',
             token_num => 2,
             t1        => 'ROUTINE',
             v1        => 'Main()',
             t2        => 'ACTION',
             v2        =>
		'Budget time unit has changed, set FII_CHANGE_LOG...');
        END IF;

        g_phase := 'Indicate in FII_CHANGE_LOG - budget needs to be dropped';

        MERGE INTO FII_CHANGE_LOG l1
 	USING
	  (SELECT 'TRUNCATE_BUDGET' log_item from DUAL) l2
	ON (l1.log_item = l2.log_item)
	WHEN MATCHED THEN UPDATE SET
	  item_value = 'Y',
	  last_update_date = SYSDATE,
	  last_updated_by = FIIBUUP_USER_ID,
	  last_update_login = FIIBUUP_LOGIN_ID
	WHEN NOT MATCHED THEN INSERT
	  (l1.log_item, l1.item_value, l1.creation_date,
 	   l1.created_by, l1.last_update_date, l1.last_updated_by,
	   l1.last_update_login)
	  VALUES
	  ('TRUNCATE_BUDGET', 'Y', SYSDATE, FIIBUUP_USER_ID, SYSDATE,
	   FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID);

        -- Print out message
        IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name 	=> 'FII_UPD_REC',
	   token_num 	=> 2,
	   t1		=> 'NUM',
	   v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	   t2		=> 'TABLE',
	   v2		=> 'FII_CHANGE_LOG');

	FII_MESSAGE.Write_Log
	  (msg_name	=> 'FII_INV_BUD_TIM_UNIT',
	   token_num 	=> 0);
        END IF;

  	l_time_unit_changed := TRUE;
      END IF;

      IF (l_drop_bud_data = 'Y') THEN
	g_phase := 'Since prior and current time unit setting is identical, reset truncation flag to N';

	UPDATE FII_CHANGE_LOG
	SET item_value = 'N',
		last_update_date = SYSDATE,
		last_updated_by = FIIBUUP_USER_ID,
		last_update_login = FIIBUUP_LOGIN_ID
	WHERE log_item = 'TRUNCATE_BUDGET';

        IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name 	=> 'FII_UPD_REC',
	   token_num 	=> 2,
	   t1		=> 'NUM',
	   v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	   t2		=> 'TABLE',
	   v2		=> 'FII_CHANGE_LOG');
        END IF;

      END IF;

      IF (NVL(l_prev_fc_time_unit, FIIBUUP_FORECAST_TIME_UNIT) <>
	  FIIBUUP_FORECAST_TIME_UNIT) THEN

        g_phase := 'Indicate in FII_CHANGE_LOG that forecast needs to be dropped';

        IF (FIIBUUP_DEBUG) THEN
          FII_MESSAGE.Write_Log
	    (msg_name  => 'FII_ROUTINE',
             token_num => 2,
             t1        => 'ROUTINE',
             v1        => 'Main()',
             t2        => 'ACTION',
             v2        =>
		'Forecast time unit has changed, set FII_CHANGE_LOG...');
        END IF;

        MERGE INTO FII_CHANGE_LOG l1
 	USING
	  (SELECT 'TRUNCATE_FORECAST' log_item from DUAL) l2
	ON (l1.log_item = l2.log_item)
	WHEN MATCHED THEN UPDATE SET
	  item_value = 'Y',
	  last_update_date = SYSDATE,
	  last_updated_by = FIIBUUP_USER_ID,
	  last_update_login = FIIBUUP_LOGIN_ID
	WHEN NOT MATCHED THEN INSERT
	  (l1.log_item, l1.item_value, l1.creation_date,
 	   l1.created_by, l1.last_update_date, l1.last_updated_by,
	   l1.last_update_login)
	  VALUES
	  ('TRUNCATE_FORECAST', 'Y', SYSDATE, FIIBUUP_USER_ID, SYSDATE,
	   FIIBUUP_USER_ID, FIIBUUP_LOGIN_ID);

        -- Print out message
        IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name 	=> 'FII_UPD_REC',
	   token_num 	=> 2,
	   t1		=> 'NUM',
	   v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	   t2		=> 'TABLE',
	   v2		=> 'FII_CHANGE_LOG');

	FII_MESSAGE.Write_Log
	  (msg_name	=> 'FII_INV_FRC_TIM_UNIT',
	   token_num 	=> 0);
        END IF;

  	l_time_unit_changed := TRUE;
      END IF;

      IF (l_drop_fc_data = 'Y') THEN
	g_phase := 'Prior and current time unit setting are identical, reset truncation flag to N';

	UPDATE FII_CHANGE_LOG
	SET item_value = 'N',
		last_update_date = SYSDATE,
		last_updated_by = FIIBUUP_USER_ID,
		last_update_login = FIIBUUP_LOGIN_ID
	WHERE log_item = 'TRUNCATE_BUDGET';

        IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name 	=> 'FII_UPD_REC',
	   token_num 	=> 2,
	   t1		=> 'NUM',
	   v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	   t2		=> 'TABLE',
	   v2		=> 'FII_CHANGE_LOG');
        END IF;

      END IF;

      FND_CONCURRENT.Af_Commit;

      IF (l_time_unit_changed) THEN
	raise FIIBUUP_fatal_err;
      END IF;

      IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Main()',
           t2        => 'ACTION',
           v2        => 'Truncating FII_BUDGET_DELTAS...');
      END IF;

      g_phase := 'Truncate the staging table FII_BUDGET_DELTAS';
      FII_UTIL.truncate_table ('FII_BUDGET_DELTAS', 'FII', g_retcode);

      IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Main()',
           t2        => 'ACTION',
           v2        => 'Truncating FII_BUDGET_BASE_T...');
      END IF;

      g_phase := 'Truncate the staging table FII_BUDGET_BASE_T';
      FII_UTIL.truncate_table ('FII_BUDGET_BASE_T', 'FII', g_retcode);

      IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Main()',
           t2        => 'ACTION',
           v2        => 'Truncating FII_BUDGET_STG...');
      END IF;

      g_phase := 'Truncate the staging table FII_BUDGET_STG';
      FII_UTIL.truncate_table ('FII_BUDGET_STG', 'FII', g_retcode);

      FND_CONCURRENT.Af_Commit;

      -- Check if there is anything to upload.  If nothing,
      -- exit normally.

      -- Bug fix 4943332: Changed to return 1 if any row exists
      BEGIN
        SELECT 1
        INTO l_int_count
        FROM FII_BUDGET_INTERFACE
	    WHERE rownum = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_int_count := 0;
      END;

      IF (l_int_count = 0) THEN
        IF (FIIBUUP_DEBUG) THEN
          FII_MESSAGE.Func_Succ(func_name => 'FII_BUDGET_FORECAST_C.Main');
        END IF;

    	l_ret_status := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'COMPLETE', message => NULL);

	RETURN;
      END IF;

      -- Lock down FII_BUDGET_INTERFACE before processing.
      -- This is to prevent users from uploading new records into the
      -- interface while program is running.
      IF (FIIBUUP_DEBUG) THEN
        FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Main()',
           t2        => 'ACTION',
           v2        => 'Locking down FII_BUDGET_INTERFACE...');
     END IF;

      g_phase := 'Locking down FII_BUDGET_INTERFACE';
      EXECUTE IMMEDIATE
	'Lock Table FII_BUDGET_INTERFACE in exclusive mode nowait';

      -- Start upload process
      FII_BUDGET_FORECAST_C.Validate(l_ret_code);

      -- If Validate() ends with error or warning, we should stop here.
      IF (l_ret_code = 'E') THEN
        -- Validate has failed.
        raise FIIBUUP_fatal_err;

      ELSIF (l_ret_code = 'W') THEN
        -- Validate ends with warnings.
        IF (FIIBUUP_DEBUG) THEN
          FII_MESSAGE.Func_Succ(func_name => 'FII_BUDGET_FORECAST_C.Main');
        END IF;

        l_ret_status := FND_CONCURRENT.Set_Completion_Status
	     	       (status	 => 'WARNING', message => NULL);
        RETURN;
      END IF;

   -- Bug 4255345: Delete data from base table when ledgers are no longer
   -- set up in FDS
/* Bug 4655730: Commented out this delete statement due to performance issue
   and also deleting ledgers from FDS is a corner case.  We'll have a long
   term fix for this tracked in bug 4660166.

   g_phase := 'Delete from FII_BUDGET_BASE when ledgers are no longer set up';

   IF (FIIBUUP_DEBUG) THEN
     FII_MESSAGE.Write_Log
	  (msg_name  => 'FII_ROUTINE',
           token_num => 2,
           t1        => 'ROUTINE',
           v1        => 'Main()',
           t2        => 'ACTION',
           v2        => 'Deleting records from FII_BUDGET_BASE for ledgers that is no longer set up in FDS...');
   END IF;

   DELETE FROM fii_budget_base
   WHERE ledger_id IN (
           SELECT DISTINCT ledger_id
           FROM fii_budget_base
           WHERE ledger_id NOT IN  (SELECT ledger_id
                                    FROM   fii_slg_assignments ));

   IF (FIIBUUP_DEBUG) THEN
     FII_MESSAGE.Write_Log
        (msg_name 	=> 'FII_DEL_REC',
	 token_num 	=> 2,
	 t1		=> 'NUM',
	 v1		=> TO_CHAR(NVL(SQL%ROWCOUNT, 0)),
	 t2		=> 'TABLE',
	 v2		=> 'FII_BUDGET_BASE');
   END IF;
*/
     -- Process NULL version dates
   l_null_ver_date_flag := 'N';
   OPEN null_ver_date;
   FETCH null_ver_date INTO l_null_ver_date_flag;
   CLOSE null_ver_date;

   IF (l_null_ver_date_flag = 'Y') THEN
     IF(NOT FII_BUDGET_FORECAST_C.Prior_version) THEN
	raise FIIBUUP_fatal_err;
     END IF;

     IF(NOT FII_BUDGET_FORECAST_C.Stage(NULL)) THEN
	raise FIIBUUP_fatal_err;
     END IF;

     IF(NOT FII_BUDGET_FORECAST_C.Adjust_Amount) THEN
	raise FIIBUUP_fatal_err;
     END IF;

     IF(NOT FII_BUDGET_FORECAST_C.rollup_Stage) THEN
	raise FIIBUUP_fatal_err;
     END IF;

     IF(NOT FII_BUDGET_FORECAST_C.adjust_Stage) THEN
	raise FIIBUUP_fatal_err;
     END IF;

     IF(NOT FII_BUDGET_FORECAST_C.merge) THEN
	raise FIIBUUP_fatal_err;
     END IF;

     IF(NOT FII_BUDGET_FORECAST_C.adjust_ver_date) THEN
	raise FIIBUUP_fatal_err;
     END IF;

   END IF;

     -- Process other version_dates in interface in ascending order
     OPEN ver_date_cur;
     LOOP
       FETCH ver_date_cur INTO l_version_date;
       EXIT WHEN ver_date_cur%NOTFOUND;

       IF (FIIBUUP_DEBUG) THEN
         FII_MESSAGE.Write_Log
	   (msg_name  => 'FII_ROUTINE',
            token_num => 2,
            t1        => 'ROUTINE',
            v1        => 'Main()',
            t2        => 'ACTION',
            v2        => 'Truncating FII_BUDGET_DELTAS...');
       END IF;

       g_phase := 'Truncate the staging table FII_BUDGET_DELTAS';
       FII_UTIL.truncate_table ('FII_BUDGET_DELTAS', 'FII', g_retcode);

       IF (FIIBUUP_DEBUG) THEN
         FII_MESSAGE.Write_Log
	   (msg_name  => 'FII_ROUTINE',
            token_num => 2,
            t1        => 'ROUTINE',
            v1        => 'Main()',
            t2        => 'ACTION',
            v2        => 'Truncating FII_BUDGET_BASE_T...');
       END IF;

       g_phase := 'Truncate the staging table FII_BUDGET_BASE_T';
       FII_UTIL.truncate_table ('FII_BUDGET_BASE_T', 'FII', g_retcode);

       IF (FIIBUUP_DEBUG) THEN
         FII_MESSAGE.Write_Log
	   (msg_name  => 'FII_ROUTINE',
            token_num => 2,
            t1        => 'ROUTINE',
            v1        => 'Main()',
            t2        => 'ACTION',
            v2        => 'Truncating FII_BUDGET_STG...');
       END IF;

       g_phase := 'Truncate the staging table FII_BUDGET_STG';
       FII_UTIL.truncate_table ('FII_BUDGET_STG', 'FII', g_retcode);

       IF(NOT FII_BUDGET_FORECAST_C.Prior_version(l_version_date)) THEN
	 raise FIIBUUP_fatal_err;
       END IF;

       IF(NOT FII_BUDGET_FORECAST_C.Stage(l_version_date)) THEN
	 raise FIIBUUP_fatal_err;
       END IF;

       IF(NOT FII_BUDGET_FORECAST_C.Adjust_Amount) THEN
	 raise FIIBUUP_fatal_err;
       END IF;

       IF(NOT FII_BUDGET_FORECAST_C.Rollup_Stage) THEN
	 raise FIIBUUP_fatal_err;
       END IF;

       IF(NOT FII_BUDGET_FORECAST_C.Adjust_Stage) THEN
	 raise FIIBUUP_fatal_err;
       END IF;

       IF(NOT FII_BUDGET_FORECAST_C.merge) THEN
	 raise FIIBUUP_fatal_err;
       END IF;

       IF(NOT FII_BUDGET_FORECAST_C.adjust_ver_date) THEN
	 raise FIIBUUP_fatal_err;
       END IF;

     END LOOP;
     CLOSE ver_date_cur;

    ELSIF (X_Mode = 'P') THEN
      IF (FIIBUUP_PURGE_EFF_DATE IS NOT NULL) THEN
        IF(NOT FII_BUDGET_FORECAST_C.purge_eff_date(FIIBUUP_PURGE_EFF_DATE)) THEN
	  raise FIIBUUP_fatal_err;
        END IF;

      ELSE

        IF (FIIBUUP_PURGE_TIME_UNIT = 'A') THEN
          IF (NOT Purge_All) THEN
	    raise FIIBUUP_fatal_err;
          END IF;
        ELSE

          -- Check if purge time unit is the same as the profile.
	  -- If not, error out.
  	  IF ((FIIBUUP_PURGE_PLAN_TYPE = 'B' AND
	       FIIBUUP_PURGE_TIME_UNIT <> l_prev_bud_time_unit) OR
	      (FIIBUUP_PURGE_PLAN_TYPE = 'F' AND
	       FIIBUUP_PURGE_TIME_UNIT <> l_prev_fc_time_unit)) THEN

  	    FII_MESSAGE.Write_Log
	      (msg_name	=> 'FII_INV_PAR_PURG',
	       token_num	=> 0);

	    raise FIIBUUP_fatal_err;
          END IF;

	  IF (NOT Purge_Partial) THEN
	    raise FIIBUUP_fatal_err;
    	  END IF;
        END IF;
      END IF;
    END IF;

    FND_CONCURRENT.Af_Commit;

    -- Bug 4674640: Added gather stats for the budget base table
    FND_STATS.gather_table_stats
           (ownname => l_fii_schema,
            tabname => 'FII_BUDGET_BASE');

    execute immediate 'alter session enable parallel dml';

    IF (FIIBUUP_DEBUG) THEN
      FII_MESSAGE.Func_Succ(func_name => 'FII_BUDGET_FORECAST_C.Main');
    END IF;

    l_ret_status := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'COMPLETE', message => NULL);

  EXCEPTION
    WHEN FIIBUUP_fatal_err THEN

      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log
	 (msg_name  => 'FII_ERR_ENC_ROUT',
          token_num => 1,
          t1        => 'ROUTINE_NAME',
          v1        => 'FII_BUDGET_FORECAST_C.Main()');

      FII_MESSAGE.Func_Fail(func_name	=> 'FII_BUDGET_FORECAST_C.Main');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);

      l_ret_status := FND_CONCURRENT.Set_Completion_Status
			(status  => 'ERROR', message => substr(sqlerrm,1,180));

    WHEN OTHERS THEN

      FND_CONCURRENT.Af_Rollback;

      FII_MESSAGE.Write_Log(msg_name  => 'FII_ERROR',
                            token_num => 2,
                            t1        => 'FUNCTION',
                            v1        => 'FII_BUDGET_FORECAST_C.Main()',
                            t2        => 'SQLERRMC',
                            v2        => SQLERRM);

      FII_MESSAGE.Func_Fail(func_name	=> 'FII_BUDGET_FORECAST_C.Main');

      fii_util.put_line ('Phase: ' || g_phase ||
                         'Error: ' || sqlerrm);

      l_ret_status := FND_CONCURRENT.Set_Completion_Status
			(status  => 'ERROR', message => substr(sqlerrm,1,180));
  END Main;

-------------------------------------------------------------------------------

  --
  -- Procedure
  --   	Upload
  -- Purpose
  --   	This is the concurrent job version of the Upload program.  This will
  --    be used when submitting the program through forms.
  -- History
  --   	05-03-02	 S Kung	        Created
  -- Arguments
  -- 	X_Debug: Debug Mode indicator
  -- Example
  --    result := FII_BUDGET_FORECAST_C.Upload(errbuf, retcode);
  -- Notes
  --
  PROCEDURE Upload(errbuf	OUT NOCOPY VARCHAR2,
		   retcode	OUT NOCOPY VARCHAR2,
		   X_Debug		VARCHAR2) IS
  BEGIN
    FII_BUDGET_FORECAST_C.Main(X_Mode		=> 'U',
			       X_Debug		=> X_Debug);

  EXCEPTION
    WHEN OTHERS THEN
      errbuf := SQLERRM;
      retcode := '2';
      app_exception.raise_exception;
  END Upload;

-------------------------------------------------------------------------------

  --
  -- Procedure
  --   	Purge
  -- Purpose
  --   	This is the concurrent job version of the Purge program.  This will be
  --    used when submitting the program through forms.
  -- History
  --   	05-03-02	 S Kung	        Created
  -- Arguments
  --    X_Plan_Type	: Plan type to operate on.  Either B (Budget)
  --		     	  or F (Forecast).  Used only in Purge.
  --    X_Time_Unit 	: Either D (Daily), P (Period), Q (Quarter), Y (Year),
  --		     	  or A (All).  Used only in Purge.
  --    X_Date	   	: Purge date
  --	X_Time_Period   : Purge period (other than date)
  --    X_Purge_Eff_Date : Purge effective date
  --    X_Debug    : Debug mode indicator
  -- Example
  --    result := FII_BUDGET_FORECAST_C.Purge
  --				(errbuf, retcode, 'B', 'P', 'Jan-01');
  --
  PROCEDURE Purge(errbuf		OUT NOCOPY VARCHAR2,
		  retcode		OUT NOCOPY VARCHAR2,
		  X_Plan_Type			VARCHAR2,
		  X_Time_Unit			VARCHAR2,
 		  X_Purge_Date			VARCHAR2,
		  X_Purge_Time_Period		VARCHAR2,
                  X_Purge_Eff_Date              VARCHAR2,
		  X_Debug			VARCHAR2) IS
  BEGIN

    FII_BUDGET_FORECAST_C.Main(X_Mode			=> 'P',
			       X_Plan_Type		=> X_Plan_Type,
			       X_Time_Unit		=> X_Time_Unit,
			       X_Purge_Date		=> X_Purge_Date,
			       X_Purge_Time_Period	=> X_Purge_Time_Period,
                               X_Purge_Eff_Date         => X_Purge_Eff_Date,
			       X_Debug			=> X_Debug);

  EXCEPTION
    WHEN OTHERS THEN
      errbuf := SQLERRM;
      retcode := '2';
      app_exception.raise_exception;
  END Purge;

-------------------------------------------------------------------------------

END FII_BUDGET_FORECAST_C;

/
