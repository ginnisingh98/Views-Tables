--------------------------------------------------------
--  DDL for Package Body FII_GL_BUDGET_EXTRACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_BUDGET_EXTRACTION" AS
/*$Header: FIIBUDXB.pls 120.4 2007/06/20 04:05:31 wywong ship $*/

   g_usage_code CONSTANT VARCHAR2(10) := 'DBI';
   g_debug_flag CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
   g_phase VARCHAR2(100);
   g_prim_curr VARCHAR2(30) := NULL;
   g_sec_curr VARCHAR2(30) := NULL;
   g_fii_user_id NUMBER(15);
   g_fii_login_id NUMBER(15);
   g_unassigned_id NUMBER(15);
   g_global_start_date CONSTANT DATE := to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'),'MM/DD/YYYY');


-----------------------------------------------------------------------
-- PROCEDURE INIT
-----------------------------------------------------------------------
PROCEDURE Init(retcode IN OUT NOCOPY VARCHAR2) is

	l_vset_id number;
	l_ret_code varchar2(15);
    G_LOGIN_INFO_NOT_AVABLE  EXCEPTION;
    G_UNASSIGNED_API_ERROR  EXCEPTION;
BEGIN

    if g_debug_flag = 'Y' then
     FII_UTIL.write_log('Calling procedure: INIT');
     FII_UTIL.write_log('');
    end if;

     g_phase := 'Find currency information.';

     -- Find all currency related information
     --------------------------------------------------------------
     g_prim_curr := BIS_COMMON_PARAMETERS.get_currency_code;
	 g_sec_curr := BIS_COMMON_PARAMETERS.get_secondary_currency_code;

	 g_phase := 'Find login information.';

     -- Find login information
     --------------------------------------------------------------
 	 g_fii_user_id := FND_GLOBAL.User_Id;
	 g_fii_login_id := FND_GLOBAL.Login_Id;

     IF (g_fii_user_id IS NULL OR g_fii_login_id IS NULL) THEN
                RAISE G_LOGIN_INFO_NOT_AVABLE;
     END IF;

     IF g_debug_flag = 'Y' THEN
  	 	FII_UTIL.write_log('User ID: ' || g_fii_user_id || '  Login ID: ' || g_fii_login_id);
     END IF;

	 g_phase := 'Find the unassigned value for user_dim1 and user dim2.';

	--Gets the unassigned id value for user_dim1_id and user_dim2_id
    --------------------------------------------------------------
	FII_GL_EXTRACTION_UTIL.get_unassigned_id(g_unassigned_id, l_vset_id, l_ret_code);
	IF(l_ret_code = -1) THEN
	       raise G_UNASSIGNED_API_ERROR;
	END IF;

EXCEPTION
  WHEN G_LOGIN_INFO_NOT_AVABLE THEN
		retcode := 'E';
    	FII_UTIL.write_log('Init: can not get User ID and Login ID, program exits.');
    raise;
  WHEN G_UNASSIGNED_API_ERROR THEN
		retcode := 'E';
    	FII_UTIL.write_log('Init: UNASSIGNED value API errored, program exits.');
    raise;
  WHEN OTHERS THEN
	retcode := 'E';
    FII_UTIL.write_log('
---------------------------------
Error in Procedure: INIT
Phase: '||g_phase||'
Message: '||sqlerrm);
    raise;
END Init;



-----------------------------------------------------------------------
-- PROCEDURE MAIN
-----------------------------------------------------------------------
--retcode returns 'S' for successful execution and 'E' for Errors

PROCEDURE Main (retcode IN OUT NOCOPY VARCHAR2)
IS

    l_row_count NUMBER(15) := 0;
    FIIBUDX_fatal_err EXCEPTION;
	l_status VARCHAR2(1) := null;
	l_retcode varchar2(15) := 0;  --Set to S: Success, E: Error, or W: Warning

/*
	--- Warn user of accounts without a finantial category type in fii_fin_cat_type_assgns---
	-----------------------------------------------------------------------------------------
    CURSOR miss_fin_type_cur IS
		SELECT glv.concatenated_segments,
			   sob.name ledger_name,
			   budv.budget_name
		FROM fii_gl_budget_extract_t t,
			 gl_budget_versions budv,
			 gl_sets_of_books sob,
			 gl_code_combinations_kfv glv,
			 fii_fin_cat_type_assgns fin
		WHERE t.budget_version_id = budv.budget_version_id
		AND t.ledger_id = sob.set_of_books_id
		AND t.code_combination_id = glv.code_combination_id
		AND t.fin_category_id IS NOT NULL
		AND fin.fin_category_id (+) = t.fin_category_id
		AND fin.fin_category_id IS NULL
		GROUP BY glv.concatenated_segments,
			     sob.name,
			     budv.budget_name;
*/
/*
	--- Warn user of accounts not in fii_gl_ccid_dimensions (dimensions not mapped correctly)
	--------------------------------------------------------------------------------------------
    CURSOR miss_ccid_cur IS
		SELECT glv.concatenated_segments,
			   sob.name ledger_name,
			   budv.budget_name
		FROM fii_gl_budget_extract_t t,
			 gl_budget_versions budv,
			 gl_sets_of_books sob,
			 gl_code_combinations_kfv glv,
			 fii_gl_ccid_dimensions ccid
		WHERE t.budget_version_id = budv.budget_version_id
		AND t.ledger_id = sob.set_of_books_id
		AND t.code_combination_id = glv.code_combination_id
		AND ccid.code_combination_id (+) = t.code_combination_id
		AND ccid.code_combination_id IS NULL
		GROUP BY glv.concatenated_segments,
			     sob.name,
			     budv.budget_name;
*/

	--- Warn user of periods not translated to primary currency ---------------------------
	-----------------------------------------------------------------------------------------
	--The missing GL periods are found as the difference between records in the FDS
	--assignments table (fii_slg_budget_asgns) and the temp table (FII_GL_BUDGET_EXTRACT_T)
	-----------------------------------------------------------------------------------------
    CURSOR miss_per_cur_prim IS
	   SELECT /*+ use_nl (setup) use_nl(sob) use_nl(per) use_nl(bud) */
			  sob.name ledger_name, bud.budget_name, per.period_name
			  from fii_slg_budget_asgns setup,
			       gl_periods per,
                               gl_ledgers_public_v sob,
				   gl_budgets_v bud
			  where setup.budget_version_id = bud.budget_version_id
                                and sob.ledger_id = setup.ledger_id
				and sob.period_set_name = per.period_set_name
				and sob.accounted_period_type = per.period_type
				and per.start_date >= setup.from_period_start_date
				and per.end_date <= setup.to_period_end_date
				and per.period_num between bud.first_valid_period_num and bud.last_valid_period_num
				--the last condition serves to avoid pulling in adjusting periods that match the end date of FDS budgets but are not defined in GL as part of the budgets
       MINUS
       SELECT /*+ use_hash(budv, t) parallel(t) */
            sob.name ledger_name, budv.budget_name, t.period_name
            from fii_gl_budget_extract_t t, gl_budget_versions budv,
                 gl_ledgers_public_v sob
            where t.budget_version_id = budv.budget_version_id
            and t.ledger_id = sob.ledger_id
            and t.currency_code =  g_prim_curr;



	--- Warn user of periods not translated to secondary currency ---------------------------
	-----------------------------------------------------------------------------------------
	--The missing GL periods are found as the difference between records in the FDS
	--assignments table (fii_slg_budget_asgns) and the temp table (FII_GL_BUDGET_EXTRACT_T)
	-----------------------------------------------------------------------------------------
    CURSOR miss_per_cur_sec IS
	   SELECT /*+ use_nl (setup) use_nl(sob) use_nl(per) use_nl(bud) */
			  sob.name ledger_name, bud.budget_name, per.period_name
			  from fii_slg_budget_asgns setup,
			       gl_periods per,
                               gl_ledgers_public_v sob,
				   gl_budgets_v bud
			  where setup.budget_version_id = bud.budget_version_id
                                and sob.ledger_id = setup.ledger_id
				and sob.period_set_name = per.period_set_name
				and sob.accounted_period_type = per.period_type
				and per.start_date >= setup.from_period_start_date
				and per.end_date <= setup.to_period_end_date
				and per.period_num between bud.first_valid_period_num and bud.last_valid_period_num
				--the last condition serves to avoid pulling in adjusting periods that match the end date of FDS budgets but are not defined in GL as part of the budgets
       MINUS
       SELECT /*+ use_hash(budv, t) parallel(t) */
		    sob.name ledger_name, budv.budget_name, t.period_name
            from fii_gl_budget_extract_t t, gl_budget_versions budv,
                 gl_ledgers_public_v sob
            where t.budget_version_id = budv.budget_version_id
            and t.ledger_id = sob.ledger_id
            and t.currency_code = g_sec_curr;

	--------------------------------------------------------------------------------
	-- Warn user of names of any duplicate budgets that have been aggregated -------
	-- Duplicate records are found by the count for same ccid/period combination----
	--------------------------------------------------------------------------------
    CURSOR dup_cur IS
        SELECT  /*+  ordered use_hash(sob,budv,glv)  parallel(glv) parallel(t) parallel(sob) pq_distribute(sob hash,hash) pq_distribute(budv hash,hash) pq_distribute(glv hash,hash) parallel(budv) parallel(v) */
			   glv.concatenated_segments,
			   sob.name ledger_name,
			   budv.budget_name
		FROM FII_GL_BUDGET_EXTRACT_T t,
                         GL_LEDGERS_PUBLIC_V sob,
 			 GL_BUDGET_VERSIONS budv,
             gl_code_combinations_kfv glv,
               (select /*+ use_hash(fin,t,ccid) parallel(t) parallel(ccid) parallel(fin) pq_distribute(fin hash,hash) pq_distribute(ccid hash,hash)*/
				   t.code_combination_id, period_name
              from FII_GL_BUDGET_EXTRACT_T t,
			 	   fii_gl_ccid_dimensions ccid,
	    		   fii_fin_cat_type_assgns fin
			  where ccid.code_combination_id = t.code_combination_id
		  	  and fin.fin_category_id = t.fin_category_id
			  and fin.fin_cat_type_code  IN ('EXP','R')
              group by t.plan_type_code_flag,
                     t.period_type_id,
                     t.period_name,
                     t.code_combination_id,
                     t.currency_code
              having COUNT(t.code_combination_id)>1) v
        WHERE v.code_combination_id = t.code_combination_id
          AND v.period_name = t.period_name
          AND glv.code_combination_id = t.code_combination_id
          AND t.ledger_id = sob.ledger_id
          AND t.budget_version_id = budv.budget_version_id
        GROUP BY glv.concatenated_segments,
			     sob.name,
			     budv.budget_name;

	--miss_fin_type_rec miss_fin_type_cur%ROWTYPE;
	--miss_ccid_rec miss_ccid_cur%ROWTYPE;
	miss_per_rec_prim miss_per_cur_prim%ROWTYPE;
	miss_per_rec_sec miss_per_cur_sec%ROWTYPE;
	dup_rec dup_cur%ROWTYPE;

BEGIN

	--Added the following for generating a complete trace file
    execute immediate ('alter session set max_dump_file_size=''unlimited'' events=''10046 trace name context forever, level  8''');

    g_phase := 'Start of main routine in FII_GL_BUDGET_EXTRACTION.';
    retcode := 'S';

    if g_debug_flag = 'Y' then
    	FII_UTIL.write_log('');
    	FII_UTIL.write_log(g_phase);
    end if;

    ------------------------
    -- Enable DBMS_OUTPUT --
    ------------------------
    --DBMS_OUTPUT.enable;

	------------------------------------------------
    -- Initialize other setups
    ------------------------------------------------
    g_phase := 'Calling INIT';
    INIT(retcode);


    ----- FII Budget Source Profile Option must be set to 'GL'
    ---------------------------------------------------------
    g_phase := 'Checking the FII Budget Source Profile Option.';
   	if g_debug_flag = 'Y' then
    	FII_UTIL.write_log(g_phase);
    end if;

	IF FND_PROFILE.value('FII_BUDGET_SOURCE') <> 'GL' THEN
      FII_MESSAGE.Write_Log
				(msg_name	=> 'FII_BUD_SOURCE_PROFILE_E',
				 token_num	=> 0);
      RAISE FIIBUDX_fatal_err;
    END IF;


   -------------------------------------------------------------
    --- Truncate temp table -------------------------------------
	-------------------------------------------------------------
    g_phase := 'Truncating temp table FII_GL_BUDGET_EXTRACT_T.';
   	if g_debug_flag = 'Y' then
    	FII_UTIL.write_log(g_phase);
    end if;

	fii_util.truncate_table('FII_GL_BUDGET_EXTRACT_T', 'FII', l_retcode);
    IF l_retcode = -1 then
      fii_util.write_log('Error in fii_util.truncate_table(''FII_GL_BUDGET_EXTRACT_T'', ''FII'', l_retcode)');
      raise FIIBUDX_fatal_err;
    END IF;

    ----------------------------------------------------
    -- Populate CCC - Mgr mappings temp. table
    -----------------------------------------------------
    g_phase := 'Call program that populates CCC - Mgr mappings temp. table.';
    FII_GL_EXTRACTION_UTIL.LOAD_CCC_MGR (l_status);

    IF l_status = -1 then
      fii_util.write_log('Error in FII_GL_EXTRACTION_UTIL.LOAD_CCC_MGR ...');
      fii_util.write_log('Table FII_CCC_MGR_GT is not populated');
      raise NO_DATA_FOUND;
    END IF;


    -------------------------------------------------------------
    --- Extracting budgets from gl_balances into temp table -----
	-------------------------------------------------------------
    g_phase := 'Extract budgets from gl_balances into temp table FII_GL_BUDGET_EXTRACT_T';

   	if g_debug_flag = 'Y' then
    	FII_UTIL.write_log('');
    	FII_UTIL.write_log(g_phase);
    	FII_UTIL.start_timer;
    end if;

	INSERT /*+ append parallel(t) */ INTO FII_GL_BUDGET_EXTRACT_T t
	        (plan_type_code_flag,
	         time_id,
	         period_type_id,
	         period_name,
			 ledger_id,
			 budget_version_id,
	         prim_amount_g,
	         sec_amount_g,
	         code_combination_id,
	         company_id,
	         cost_center_id,
			 company_cost_center_org_id,
	         fin_category_id,
	         category_id,
	         user_dim1_id,
	         user_dim2_id,
	         currency_code,
			 last_update_date,
			 last_updated_by,
			 creation_date,
		     created_by,
			 last_update_login)
	SELECT  /*+  use_hash(glper,sob, slga, fincat,ccid)
              parallel(ccid) parallel(cccorg) parallel(slga) parallel(glper) pq_distribute(glper hash,hash)
	  parallel(sob) parallel(fincat) pq_distribute(cccorg hash,hash) pq_distribute(slga hash,hash) */

            slga.plan_type_code,
	        null, --time_id
	        32,
	    	glper.period_name,
			slga.ledger_id,
			slga.budget_version_id,
	    	DECODE(bal.currency_code,
	           g_prim_curr, DECODE(fincat.fin_cat_type_code,
	                'R', SUM(bal.period_net_cr - bal.period_net_dr),
	                'EXP', -SUM(bal.period_net_cr - bal.period_net_dr),
					0),
	           g_sec_curr, 0) prim_amount,
	        DECODE(bal.currency_code,
	           g_prim_curr, 0,
	           g_sec_curr, DECODE(fincat.fin_cat_type_code,
	                'R', SUM(bal.period_net_cr - bal.period_net_dr),
	                'EXP', -SUM(bal.period_net_cr - bal.period_net_dr),
					0)) sec_amount,
	        bal.code_combination_id,
	        ccid.company_id,
	        ccid.cost_center_id,
			NVL(cccorg.ccc_org_id, -1) ccc_org_id,
	        ccid.natural_account_id,
	        NVL(ccid.prod_category_id, -1) prod_category_id,
	        NVL(ccid.user_dim1_id, g_unassigned_id) user_dim1_id,
	        NVL(ccid.user_dim2_id, g_unassigned_id) user_dim2_id,
	        bal.currency_code,
	        sysdate,
	        g_fii_user_id,
	        sysdate,
	        g_fii_user_id,
	        g_fii_user_id
	FROM GL_BALANCES bal,
	     FII_GL_CCID_DIMENSIONS ccid,
		 FII_CCC_MGR_GT cccorg,
	     FII_SLG_BUDGET_ASGNS slga,
	     GL_PERIODS glper,
             GL_LEDGERS_PUBLIC_V sob,
	     FII_FIN_CAT_TYPE_ASSGNS fincat
	WHERE fincat.fin_category_id (+) = ccid.natural_account_id
	AND (fincat.fin_cat_type_code  IN ('EXP','R') OR fincat.fin_cat_type_code IS NULL) -- if NULL then amounts will be both 0
	AND bal.code_combination_id = ccid.code_combination_id (+)
        AND bal.ledger_id = slga.ledger_id
	AND bal.budget_version_id = slga.budget_version_id
	AND bal.period_type = glper.period_type
	AND bal.period_name = glper.period_name
	AND glper.period_set_name = sob.period_set_name
        AND sob.ledger_id = slga.ledger_id
	AND glper.start_date >= slga.from_period_start_date
	AND glper.end_date <= slga.to_period_end_date
	AND bal.currency_code IN (g_prim_curr, g_sec_curr)
	AND bal.actual_flag = 'B'
	AND cccorg.company_id (+) = ccid.company_id
	AND cccorg.cost_center_id (+) = ccid.cost_center_id
	GROUP BY  slga.plan_type_code,
	    	  slga.ledger_id,
	    	  slga.budget_version_id,
	          fincat.fin_cat_type_code,
	          glper.period_name,
	          bal.code_combination_id,
	          ccid.company_id,
	          ccid.cost_center_id,
	          NVL(cccorg.ccc_org_id, -1),
	          ccid.natural_account_id,
	          NVL(ccid.prod_category_id, -1),
	          NVL(ccid.user_dim1_id, g_unassigned_id),
	          NVL(ccid.user_dim2_id, g_unassigned_id),
	          bal.currency_code,
	          glper.adjustment_period_flag;

/*      l_row_count := SQL%ROWCOUNT;  */
/*      DBMS_OUTPUT.put_line('Inserted ' || TO_CHAR(l_row_count) || ' rows in FII_GL_BUDGET_EXTRACT_T.');  */
/*  	l_row_count := 0;  */
    if g_debug_flag = 'Y' then
    	FII_UTIL.write_log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_GL_BUDGET_EXTRACT_T.');
    	FII_UTIL.stop_timer;
    	FII_UTIL.print_timer('Duration');
    end if;

	commit;


	--------------------------------------------------------
	--- Warning messages -----------------------------------
	--------------------------------------------------------

	-------------------------------------
	--Display Primary Curreny Warning
	-------------------------------------
    g_phase := 'Warn user of periods not translated to primary currency.';

   	if g_debug_flag = 'Y' then
    	FII_UTIL.write_log('');
    	FII_UTIL.write_log(g_phase);
    end if;

   	OPEN miss_per_cur_prim;
   	FETCH miss_per_cur_prim INTO miss_per_rec_prim;

   	If (miss_per_cur_prim%ROWCOUNT > 0) THEN

		FII_UTIL.write_output('---------------------------------------------------------------------');
		FII_MESSAGE.write_output(msg_name => 'FII_CUR1_TRANS_REC',
								 token_num => 0);
		FII_UTIL.write_output('('||miss_per_rec_prim.ledger_name||
	                         ', '||miss_per_rec_prim.budget_name||
							 ', '||miss_per_rec_prim.period_name||')');

/*  			DBMS_OUTPUT.put_line('---------------------------------------------------------------------');  */
/*  			DBMS_OUTPUT.put_line('Following is a list of budgets with periods that are not available in the primary global currency in GL:');  */
/*  			DBMS_OUTPUT.PUT_LINE('Ledger: '||miss_per_rec_prim.ledger_name||  */
/*  		                         ', Budget: '||miss_per_rec_prim.budget_name||  */
/*  								 ', Period: '||miss_per_rec_prim.period_name);  */


	    LOOP
	     	FETCH miss_per_cur_prim INTO miss_per_rec_prim;
	     	EXIT WHEN miss_per_cur_prim%NOTFOUND;
			FII_UTIL.write_output('('||miss_per_rec_prim.ledger_name||
	                         ', '||miss_per_rec_prim.budget_name||
							 ', '||miss_per_rec_prim.period_name||')');

/*  				DBMS_OUTPUT.PUT_LINE('Ledger: '||miss_per_rec_prim.ledger_name||  */
/*  		                         	 ', Budget: '||miss_per_rec_prim.budget_name||  */
/*  								 	 ', Period: '||miss_per_rec_prim.period_name);  */
	    END LOOP;
	    FII_UTIL.write_output('---------------------------------------------------------------------');
/*  		    DBMS_OUTPUT.put_line('---------------------------------------------------------------------');  */

		retcode := 'W';
	END IF;
	CLOSE miss_per_cur_prim;


	-------------------------------------
	--Display Secondary Curreny Warning
	-------------------------------------
	g_phase := 'Warn user of periods not translated to secondary currency.';

	if g_debug_flag = 'Y' then
		FII_UTIL.write_log('');
		FII_UTIL.write_log(g_phase);
	end if;

      -- Bugfix 6053573

      IF g_sec_curr IS NOT NULL THEN

   	OPEN miss_per_cur_sec;
   	FETCH miss_per_cur_sec INTO miss_per_rec_sec;

   	If (miss_per_cur_sec%ROWCOUNT > 0) THEN

		FII_UTIL.write_output('---------------------------------------------------------------------');
		FII_MESSAGE.write_output(msg_name => 'FII_CUR2_TRANS_REC',
								 token_num => 0);
		FII_UTIL.write_output('('||miss_per_rec_sec.ledger_name||
	                         ', '||miss_per_rec_sec.budget_name||
							 ', '||miss_per_rec_sec.period_name||')');

/*  			DBMS_OUTPUT.put_line('---------------------------------------------------------------------');  */
/*  			DBMS_OUTPUT.put_line('Following is a list of budgets with periods that are not available in the secondary global currency in GL:');  */
/*  			DBMS_OUTPUT.PUT_LINE('Ledger: '||miss_per_rec_sec.ledger_name||  */
/*  		                         ', Budget: '||miss_per_rec_sec.budget_name||  */
/*  								 ', Period: '||miss_per_rec_sec.period_name);  */


	    LOOP
	     	FETCH miss_per_cur_sec INTO miss_per_rec_sec;
	     	EXIT WHEN miss_per_cur_sec%NOTFOUND;
			FII_UTIL.write_output('('||miss_per_rec_sec.ledger_name||
	                         ', '||miss_per_rec_sec.budget_name||
							 ', '||miss_per_rec_sec.period_name||')');
/*  				DBMS_OUTPUT.PUT_LINE('Ledger: '||miss_per_rec_sec.ledger_name||  */
/*  		                         	 ', Budget: '||miss_per_rec_sec.budget_name||  */
/*  								 	 ', Period: '||miss_per_rec_sec.period_name);  */
	    END LOOP;
	    FII_UTIL.write_output('---------------------------------------------------------------------');
/*  		    DBMS_OUTPUT.put_line('---------------------------------------------------------------------');  */

		retcode := 'W';
	END IF;
	CLOSE miss_per_cur_sec;
      END IF;

	-------------------------------------
	-- Display Duplicates Warning
	-------------------------------------
    g_phase := 'Warn user of names of any duplicate budgets that have been aggregated.';

   	if g_debug_flag = 'Y' then
    	FII_UTIL.write_log('');
    	FII_UTIL.write_log(g_phase);
    end if;
   	OPEN dup_cur;
   	FETCH dup_cur INTO dup_rec;

   	If (dup_cur%ROWCOUNT > 0) THEN

		FII_UTIL.write_output('---------------------------------------------------------------------');
		FII_MESSAGE.write_output(msg_name => 'FII_DUP_REC_AGG_REC',
								 token_num => 0);
		FII_UTIL.write_output('('||dup_rec.concatenated_segments||
							 ', '||dup_rec.ledger_name||
	                         ', '||dup_rec.budget_name||')');

/*  			DBMS_OUTPUT.put_line('Following is a list of budgets with duplicate code combinations and time periods:   */
/*  The budgets for these periods have been summed up.' );  */
/*  			DBMS_OUTPUT.PUT_LINE('Ledger: '||dup_rec.ledger_name||  */
/*  		                         ', Budget: '||dup_rec.budget_name);  */


	    LOOP
	     	FETCH dup_cur INTO dup_rec;
	     	EXIT WHEN dup_cur%NOTFOUND;
		FII_UTIL.write_output('('||dup_rec.concatenated_segments||
							 ', '||dup_rec.ledger_name||
	                         ', '||dup_rec.budget_name||')');
/*  				DBMS_OUTPUT.PUT_LINE('Ledger: '||dup_rec.ledger_name||  */
/*  		                         ', Budget: '||dup_rec.budget_name);  */
	    END LOOP;
	    FII_UTIL.write_output('---------------------------------------------------------------------');
/*  		    DBMS_OUTPUT.put_line('---------------------------------------------------------------------------------');  */

		retcode := 'W';
	END IF;
	CLOSE dup_cur;



	----------------------------------------------------------------------------
	--- Inserting into temp table second time (after the warning cursors) for the following reasons:
	---  - insert fii time_id
    --   - add adjusting periods into non-adjusting period based on end date
    --   - remove budgets with 0 amounts (this also takes care of discarding
    --	   records that don't have a financial category type or ccid)
	--   - remove code_combination_id from group by
	----------------------------------------------------------------------------
    g_phase := 'Inserting second time into temp table FII_GL_BUDGET_EXTRACT_T.';

   	if g_debug_flag = 'Y' then
    	FII_UTIL.write_log('');
    	FII_UTIL.write_log(g_phase);
    	FII_UTIL.start_timer;
    end if;

	INSERT /*+ append parallel(t) */ INTO FII_GL_BUDGET_EXTRACT_T t
	        (plan_type_code_flag,
	         time_id,
	         period_type_id,
			 ledger_id,
	         prim_amount_g,
	         sec_amount_g,
	         company_id,
	         cost_center_id,
			 company_cost_center_org_id,
	         fin_category_id,
	         category_id,
	         user_dim1_id,
	         user_dim2_id,
			 last_update_date,
			 last_updated_by,
			 creation_date,
		     created_by,
			 last_update_login)
	SELECT  /*+   parallel(t) parallel(period) parallel(GLPER) parallel(SOB) pq_distribute(glper hash,hash) */
			plan_type_code_flag,
			period.ent_period_id time_id,
			32,
			t.ledger_id,
			SUM(prim_amount_g),
			SUM(sec_amount_g),
			company_id,
			cost_center_id,
			company_cost_center_org_id,
			fin_category_id,
			category_id,
			user_dim1_id,
			user_dim2_id,
		    sysdate,
	        g_fii_user_id,
	        sysdate,
	        g_fii_user_id,
	        g_fii_login_id
	FROM FII_GL_BUDGET_EXTRACT_T t,
	     FII_TIME_ENT_PERIOD period,
	     GL_PERIODS glper,
             GL_LEDGERS_PUBLIC_V sob,
		 fii_slg_budget_asgns setup
	WHERE t.period_name = glper.period_name
        ANd sob.ledger_id = t.ledger_id
	AND sob.period_set_name = glper.period_set_name
	AND sob.accounted_period_type = glper.period_type
	AND ((glper.adjustment_period_flag = 'N' and glper.start_date = period.start_date)
     	OR
     	(glper.adjustment_period_flag = 'Y'))
	AND ((glper.adjustment_period_flag = 'N' and glper.end_date = period.end_date)
     	OR
     	(glper.adjustment_period_flag = 'Y' and glper.end_date between period.start_date and period.end_date))
	AND setup.ledger_id = t.ledger_id
	AND setup.budget_version_id = t.budget_version_id
	AND setup.plan_type_code = t.plan_type_code_flag
	AND period.start_date >= setup.from_period_start_date
	AND period.end_date <= setup.to_period_end_date
    AND ((prim_amount_g <> 0 and sec_amount_g = 0)   --to remove budget amounts that are 0
         OR (prim_amount_g = 0 and sec_amount_g <> 0))
	GROUP BY plan_type_code_flag,
			t.ledger_id,
	        company_id,
	        cost_center_id,
			company_cost_center_org_id,
	        fin_category_id,
	        category_id,
	        user_dim1_id,
	        user_dim2_id,
	        period.ent_period_id;

 --If posted_date is to be populated from
 --the temp table like the rest of the
 --columns, then it should be added to
 --the group by condition since it is part of index FII_BUDGET_BASE_U1.
 --It will also have to be added to the delete statement.


    if g_debug_flag = 'Y' then
    	FII_UTIL.write_log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_GL_BUDGET_EXTRACT_T.');
    	FII_UTIL.stop_timer;
    	FII_UTIL.print_timer('Duration');
    end if;

	commit;

	-------------------------------------------------------------
	--- Rolling Up on time in temp table ------------------------
	-------------------------------------------------------------
    g_phase := 'Rolling Up on time in temp table FII_GL_BUDGET_EXTRACT_T.';

   	if g_debug_flag = 'Y' then
    	FII_UTIL.write_log('');
    	FII_UTIL.write_log(g_phase);
    	FII_UTIL.start_timer;
    end if;

	INSERT /*+ append parallel(a) */ INTO FII_GL_BUDGET_EXTRACT_T a
	            (plan_type_code_flag,
	             time_id,
	             period_type_id,
				 ledger_id,
	             prim_amount_g,
	             sec_amount_g,
	             company_id,
	             cost_center_id,
				 company_cost_center_org_id,
	             fin_category_id,
	             user_dim1_id,
	             user_dim2_id,
	             category_id,
				 last_update_date,
		 		 last_updated_by,
		 		 creation_date,
	     		 created_by,
		 		 last_update_login)
	          SELECT /*+ parallel(temp) parallel(period) pq_distribute(temp hash,hash) */
	              temp.plan_type_code_flag,
	              NVL(period.ent_qtr_id, period.ent_year_id) time_id,
	              DECODE(period.ent_qtr_id, NULL, 128, 64) period_type_id,
				  temp.ledger_id,
	              SUM(temp.prim_amount_g) prim_amount_g,
	              SUM(temp.sec_amount_g) sec_amount_g,
	              temp.company_id,
	              temp.cost_center_id,
				  company_cost_center_org_id,
	              temp.fin_category_id,
	              temp.user_dim1_id,
	              temp.user_dim2_id,
	              temp.category_id,
				  sysdate,
	   	          g_fii_user_id,
	              sysdate,
	        	  g_fii_user_id,
	        	  g_fii_login_id
	          FROM FII_GL_BUDGET_EXTRACT_T temp,
	               FII_TIME_ENT_PERIOD period
	          WHERE  temp.time_id = period.ent_period_id
	          GROUP BY
	              plan_type_code_flag,
				  ledger_id,
	              company_id,
	              cost_center_id,
				  company_cost_center_org_id,
	              fin_category_id,
	              user_dim1_id,
	              user_dim2_id,
	              category_id,
	            ROLLUP (period.ent_year_id,
	                    period.ent_qtr_id)
			  HAVING period.ent_year_id is not null;

    if g_debug_flag = 'Y' then
    	FII_UTIL.write_log('Inserted ' || SQL%ROWCOUNT || ' Roll Up rows in FII_GL_BUDGET_EXTRACT_T on time.');
    	FII_UTIL.stop_timer;
    	FII_UTIL.print_timer('Duration');
    end if;
/*      l_row_count := SQL%ROWCOUNT;  */
/*      DBMS_OUTPUT.put_line('Rolled Up ' || TO_CHAR(l_row_count) || ' rows in FII_GL_BUDGET_EXTRACT_T on time.');  */
/*  	l_row_count := 0;  */

commit;


	--- Deleting from fii_budget_base by diffing with temp table -------------
	--------------------------------------------------------------------------
    g_phase := 'Deleting from fii_budget_base by diffing with temp table.';

   	if g_debug_flag = 'Y' then
    	FII_UTIL.write_log('');
    	FII_UTIL.put_line(g_phase);
    	FII_UTIL.start_timer;
    end if;

	DELETE FROM fii_budget_base
	      WHERE (time_id,
	             period_type_id,
				 ledger_id,
	             company_id,
	             cost_center_id,
				 NVL(company_cost_center_org_id,-1),
	             fin_category_id,
	             NVL(category_id, -1),
	             user_dim1_id,
				 user_dim2_id,
				 plan_type_code,
				 prim_amount_g,
	             sec_amount_g,
				 prim_amount_total,
	             sec_amount_total)
	      IN
	        (SELECT time_id,
	             period_type_id,
				 ledger_id,
	             company_id,
	             cost_center_id,
				 NVL(company_cost_center_org_id,-1),
	             fin_category_id,
	             NVL(category_id, -1),
	             user_dim1_id,
	             user_dim2_id,
				 plan_type_code,
				 prim_amount_g,
	             sec_amount_g,
				 prim_amount_total,
	             sec_amount_total
		     FROM fii_budget_base
	         MINUS
		       SELECT time_id,
	             period_type_id,
			     ledger_id,
	             company_id,
	             cost_center_id,
				 NVL(company_cost_center_org_id, -1),
	             fin_category_id,
	             NVL(category_id, -1),
	             user_dim1_id,
	             user_dim2_id,
				 plan_type_code_flag,
				 prim_amount_g,
	             sec_amount_g,
				 prim_amount_g,
	             sec_amount_g
	           FROM FII_GL_BUDGET_EXTRACT_T
               WHERE time_id is not null);


    if g_debug_flag = 'Y' then
    	FII_UTIL.write_log('Deleted ' || SQL%ROWCOUNT  || ' rows from fii_budget_base.');
    	FII_UTIL.stop_timer;
    	FII_UTIL.print_timer('Duration');
    end if;
/*  	l_row_count := SQL%ROWCOUNT;  */
/*      DBMS_OUTPUT.put_line('Deleted ' || TO_CHAR(l_row_count) || ' rows from fii_budget_base.');  */
/*  	l_row_count := 0;  */


	--- Insert contents of temp table into fii_budget_base --------------------
	--------------------------------------------------------------------------
    g_phase := 'Insert contents of temp table into fii_budget_base.';

   	if g_debug_flag = 'Y' then
    	FII_UTIL.write_log('');
    	FII_UTIL.write_log(g_phase);
    	FII_UTIL.start_timer;
    end if;


	INSERT /*+ append parallel(f) */ INTO fii_budget_base f
	  (plan_type_code,
       time_id,
       period_type_id,
	   ledger_id,
       prim_amount_g,
       sec_amount_g,
       prim_amount_total,
       sec_amount_total,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       category_id,
       user_dim1_id,
       user_dim2_id,
       fin_category_id,
       company_id,
       cost_center_id,
	   company_cost_center_org_id,
       posted_date)
    (SELECT /*+ parallel(t) */ plan_type_code_flag,
            time_id,
            period_type_id,
		    ledger_id,
            prim_amount_g,
            sec_amount_g,
            prim_amount_g,
            sec_amount_g,
            sysdate,
            g_fii_user_id,
            sysdate,
            g_fii_user_id,
            g_fii_login_id,
            category_id,
            user_dim1_id,
            user_dim2_id,
            fin_category_id,
            company_id,
            cost_center_id,
			company_cost_center_org_id,
			g_global_start_date
	 FROM FII_GL_BUDGET_EXTRACT_T t
	 WHERE t.time_id is not null
	 AND NOT EXISTS (SELECT  /*+ parallel(b) */  time_id,
	     		             period_type_id,
			 				 ledger_id,
				             company_id,
				             cost_center_id,
							 NVL(company_cost_center_org_id,-1),
				             fin_category_id,
				             NVL(category_id, -1),
				             user_dim1_id,
				             user_dim2_id,
							 plan_type_code,
							 prim_amount_g,
				             sec_amount_g,
							 prim_amount_total,
				             sec_amount_total
					 FROM fii_budget_base b
					 WHERE time_id = t.time_id
	     		     and   period_type_id = t.period_type_id
	     		     and   ledger_id = t.ledger_id
	     		     and   company_id = t.company_id
	     		     and   cost_center_id = t.cost_center_id
	     		     and   NVL(company_cost_center_org_id,-1) = NVL(t.company_cost_center_org_id,-1)
	     		     and   fin_category_id = t.fin_category_id
	     		     and   NVL(category_id, -1) = NVL(t.category_id, -1)
	     		     and   user_dim1_id = t.user_dim1_id
	     		     and   user_dim2_id = t.user_dim2_id
	     		     and   plan_type_code = t.plan_type_code_flag
	     		     and   prim_amount_g = t.prim_amount_g
	     		     and   sec_amount_g = t.sec_amount_g
	     		     and   prim_amount_total = t.prim_amount_g
	     		     and   sec_amount_total = t.sec_amount_g));


    if g_debug_flag = 'Y' then
    	FII_UTIL.write_log('Inserted ' || SQL%ROWCOUNT  || ' rows into fii_budget_base.');
    	FII_UTIL.stop_timer;
    	FII_UTIL.print_timer('Duration');
    end if;
/*  	l_row_count := SQL%ROWCOUNT;  */
/*      DBMS_OUTPUT.put_line('Inserted ' || TO_CHAR(l_row_count) || ' rows into fii_budget_base.');  */
/*  	l_row_count := 0;  */

    --
    -- Commit all changes
    --
    COMMIT;

EXCEPTION
    WHEN FIIBUDX_fatal_err THEN
      retcode := 'E';
      Rollback;
      FII_UTIL.write_log('Fatal errors occured during the upload process.');
/*        DBMS_OUTPUT.put_line('Fatal errors occured during the upload process.');  */

    WHEN OTHERS Then
      retcode := 'E';
	  Rollback;

      FII_UTIL.write_output('
Error in Function: Main
Phase: '|| g_phase || '
Message: ' || sqlerrm);

/*          DBMS_OUTPUT.put_line('  */
/*  Error in Function: Main  */
/*  Phase: '|| g_phase || '  */
/*  Message: ' || sqlerrm);  */
-------------------------------------------------------------------------------
END;

END FII_GL_BUDGET_EXTRACTION;

/
