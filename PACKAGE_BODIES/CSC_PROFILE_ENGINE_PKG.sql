--------------------------------------------------------
--  DDL for Package Body CSC_PROFILE_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROFILE_ENGINE_PKG" AS
/* $Header: csccpepb.pls 120.22.12010000.8 2009/12/30 09:20:01 spamujul ship $ */

			--
			-- Constant values
			--
			debug       CONSTANT BOOLEAN 	  := FALSE; -- Run engine in debug or normal mode
			date_format CONSTANT VARCHAR2(30) := 'YYYY/MM/DD HH24:MI:SS';
			--
			-- Global variables
			--
			warning_msg	VARCHAR2(2000)  := ''; -- non-fatal error messages
			error_flag	BOOLEAN 	:= FALSE; -- error evaluating one or more blk/chk
			--user_id		NUMBER;
			--login_id		NUMBER;

			--up_total	Number := 0;
			--ip_total	Number := 0;
			--ua_total	NUmber := 0;
			--ia_total	Number := 0;

			--g_for_insert	Varchar2(1) := 'Y';
			--g_for_party	Varchar2(1) := 'Y';
			--period_date	Date := null;

			g_error		Varchar2(2000);

			--
			-- Utility to delete all records in pl/sql tables
			--
PROCEDURE Table_Delete;


--
-- Run_Engine
--   Loop through all the effective profile checks and evaluate the results
--   for each party and account.
--   This program can be called in:
--      a. customer profile setup form, when changes takes place on the profile definition
--      b. customer profile and dashboard window, when refresh button is clicked.
--      c. Stand alone as a concurrent program
--         note: if no parameters are passed it is assumed that the package will be run
--               as a concurrent program. and will update all results for party and account.
-- IN
--  p_block_tbl - if there are changes in the setup in the profile checks (blocks),
--                a table of profile checks is passed.
--  p_check_tbl - if there are changes in the setup in the check variable, a table of check
--                variables is passed.
--  p_party_id
--  p_acct_id
--  p_group_id
--	 -- this parameters is used when the refresh button is pressed. only those profile
--	    checks, check variables that falls into the group for that party or account will
--	    be calculated.
-- OUT
--   errbuf - return any error messages
--   retcode - return completion status (returns 0 for success, 1 for success
--             with warnings, and 2 for error)
-- ------------------------ -------------------------
--  Changed the Run_Engine procedure for ER#8473903
--  Added the p_psite_id parameter  for Party_site_id input.
-- The above parameter is used to process the Customer profiles at  site level.
--- --------------------------------------------------

PROCEDURE Run_Engine (p_errbuf		OUT NOCOPY VARCHAR2,
						    p_retcode		OUT NOCOPY NUMBER,
						    p_party_id		IN  NUMBER,
			                            p_acct_id		IN  NUMBER,
					            p_psite_id		IN   NUMBER DEFAULT NULL, -- added by spamujul for ER#8473903
		                                    p_group_id	IN  NUMBER
						    ) IS

			  v_block_count		NUMBER := 0;
			  v_check_count		NUMBER := 0;
			  v_errbuf			Varchar2(240);
			  v_retcode			Number;
			  v_exception			BOOLEAN;
			  v_date				Date := null;
			  --l_period_date	Date := null;
			  l_up_total			Number := 0;
			  l_ip_total			Number := 0;
			  l_ua_total			NUmber := 0;
			  l_ia_total			Number := 0;
			  l_us_total			Number := 0; -- added by spamujul for ER#8473903
			  l_is_total			Number := 0; -- added by spamujul for ER#8473903
			  l_custom_hook_enabled varchar2(1);         /* added for Custom Hook Enhancement */
			  l_ref_cursor csc_utils.Party_Ref_Cur_Type; /* added for Custom Hook Enhancement */
			  l_party_rec csc_utils.Prof_Rec_Type;       /* added for Custom Hook Enhancement */
			  l_party_id			Number;

BEGIN

		   -- Default user and login IDs
		   --user_id  := fnd_global.user_id;
		   --login_id := fnd_global.login_id;

		   l_up_total	:=  0;
		   l_ip_total	:=  0;
		   l_ua_total	:=  0;
		   l_ia_total	:=  0;
		   l_us_total	:= 0;		-- added by spamujul for ER#8473903
		   l_is_total	:= 0;		 -- added by spamujul for ER#8473903
		   table_delete;

    /*************************************************************************************
				START OF CUSTOM HOOK ENHANCEMENT
   CSC_PROF_PARTY_SQL_CUHK will be invoked to get the select statement for fetching party
   records by the profile engine.
   *************************************************************************************/
	   l_custom_hook_enabled := 'N';
	   IF  p_party_id IS NULL THEN
	      IF JTF_USR_HKS.ok_to_execute('CSC_PROF_PARTY_SQL_CUHK','GET_PARTY_SQL_PRE','B','C') THEN
		   l_custom_hook_enabled := 'Y';
		   CSC_PROF_PARTY_SQL_CUHK.Get_Party_Sql_Pre(l_ref_cursor);
		LOOP
			FETCH l_ref_cursor INTO l_party_id;
			EXIT WHEN l_ref_cursor%NOTFOUND;
			IF l_party_id is not NULL then
				IF p_group_id is NULL then
					Evaluate_Checks3(l_party_id,
									    null,
									    null,
									    NULL, -- added by spamujul for ER#8473903
									    v_errbuf,
									    v_retcode
									    );
			       ELSE /* group_id is not null */
					Evaluate_Checks2(l_party_id,
										null,
										NULL, -- added by spamujul for ER#8473903
										p_group_id,
										'N',
										v_errbuf,
										v_retcode
									);
			       END IF;
			 END IF;
			p_errbuf  := v_errbuf;
			p_retcode := v_retcode;
		END LOOP;
		ELSE
			l_custom_hook_enabled := 'N';
		END IF; /* IF JTF_USR_HKS.ok_to_execute */
	   END IF; /*  IF  p_party_id IS NULL */

	    IF l_custom_hook_enabled = 'N' THEN
	    /*Existing logic is used */
	   /*******************************************************************************************
					END OF CUSTOM HOOK ENHANCEMENT
	   ********************************************************************************************/
		IF (p_party_id is null and p_group_id is NULL ) THEN
  			-- Populate the check results table for all parties and accounts for type 'B'
		        Evaluate_Checks1_Var;
		        IF g_check_no_batch = 'Y' THEN
				  -- Call Evaluate_Blocks1_No_Batch and Evaluate_Checks1_No_Batch
				  -- to process profile variables with no batch sql stmnt for type Variable ('B')
				   Evaluate_Blocks1_No_Batch(l_up_total,
											 l_ip_total,
											 l_ua_total,
											 l_ia_total
											 ,l_us_total, -- added by spamujul for ER#8473903
											  l_is_total -- added by spamujul for ER#8473903
											 );
				   Evaluate_Checks1_No_Batch(v_errbuf, v_retcode);
				   p_errbuf := v_errbuf;
				   p_retcode := v_retcode;
			END IF;
			-- Populate the check results table for all parties and accounts for type 'T'
			Evaluate_Checks1_Rule(v_errbuf, v_retcode);
			p_errbuf := v_errbuf;
			p_retcode := v_retcode;
			-- Call Relationship Plan Engine
			Csc_Plan_Assignment_Pkg.Run_Plan_Engine (v_errbuf, v_retcode, null, null, null, null);
		  ELSIF (p_party_id IS NOT NULL and p_group_id IS NOT NULL) THEN
			-- Evaluate for this party Alone, only for Valid checks present in the given group
			    Evaluate_Checks2(p_party_id		=> p_party_id,
								 p_acct_id		=>  p_acct_id,
								 p_psite_id		=> p_psite_id,-- added by spamujul for ER#8473903
								 p_group_id		=> p_group_id,
								 p_critical_flag	=> 'N',
							         errbuf			=> v_errbuf,
							         retcode			=> v_retcode);
			party_id_plan_table(1) 	 := p_party_id;
			account_id_plan_table(1) := p_acct_id;
			-- Commented the following code for bug 8471528 by spamujul
			--Csc_Plan_Assignment_Pkg.Run_Plan_Engine (v_errbuf, v_retcode, null, null, p_party_id, null); -- added by mpathani for bug 6928322
			   Csc_Plan_Assignment_Pkg.Run_Plan_Engine (v_errbuf, v_retcode, null, null, p_party_id, p_acct_id); -- Fix bug 8471528 by spamujul
		 ELSIF (p_party_id IS NOT NULL and p_group_id is null ) THEN
			-- Evaluate for all Valid Checks and For this party ;
			Evaluate_Checks3(p_party_id,
						      p_acct_id,
						      p_psite_id, -- added by spamujul for ER#8473903
						      p_group_id,
						      v_errbuf,
						      v_retcode
						      );
			party_id_plan_table(1)   := p_party_id;
			account_id_plan_table(1) := p_acct_id;
			-- Commented the following code for bug 8471528 by spamujul
			--Csc_Plan_Assignment_Pkg.Run_Plan_Engine (v_errbuf, v_retcode, null, null, p_party_id, null); -- added by mpathani for bug 6928322
			 Csc_Plan_Assignment_Pkg.Run_Plan_Engine (v_errbuf, v_retcode, null, null, p_party_id, p_acct_id); -- Fix bug 8471528 by spamujul

		ELSIF (p_party_id IS NULL and p_group_id is NOT null ) THEN -- added for 1850508
			-- Assume Group is given, but party and Account are null , Process for all parties
			-- This is specifically for cases, where the customers can start 'n' concurrent pgms
			-- for different groups.
			-- Populate the check results table for all parties and accounts
			Evaluate_Checks4_Var(p_Group_id);
			-- Call Evaluate_Blocks4_No_Batch and Evaluate_Checks4_No_Batch
			-- to process profile variables with no batch sql stmnt
			IF g_check_no_batch = 'Y' THEN
				   Evaluate_Blocks4_No_Batch(l_up_total,
										 l_ip_total,
										 l_ua_total,
										 l_ia_total,
										 l_us_total, -- added by spamujul for ER#8473903
										 l_is_total, -- added by spamujul for ER#8473903
										 p_group_id);
				   Evaluate_Checks4_No_Batch(v_errbuf, v_retcode, p_Group_id);
				   p_errbuf := v_errbuf;
				   p_retcode := v_retcode;
			END IF;
			Evaluate_Checks4_Rule(v_errbuf, v_retcode, p_Group_id);
			p_errbuf := v_errbuf;
			p_retcode := v_retcode;

			-- Call Relationship Plan Engine
			-- Check How to call Plans engine
			-- Csc_Plan_Assignment_Pkg.Run_Plan_Engine (v_errbuf, v_retcode, null, null, null, null);
		END IF;
	END IF; /* IF l_custom_hook_enabled = 'N' */
Exception
	when others then
		table_delete;
		g_error := sqlcode || ' ' || sqlerrm;
		fnd_file.put_line(fnd_file.log , g_error);
END Run_Engine;

  --
  -- Bug 1942032 to run engine as a concurrent program - overloaded procedure when
  -- Account Id is removed from conc. program parameters.
  --
  PROCEDURE Run_Engine (p_errbuf		OUT NOCOPY VARCHAR2,
    		      				      p_retcode	OUT NOCOPY NUMBER,
						      p_party_id	IN  NUMBER,
						      p_group_id	IN  NUMBER ) Is

  begin
			   run_engine(p_errbuf 		=> p_errbuf,
						      p_retcode 	=> p_retcode,
						      p_party_id	=> p_party_id,
						      p_acct_id		=> NULL,
						      p_psite_id	=> NULL, -- added by spamujul for ER#8473903
						      p_group_id	=> p_group_id
				      );
  End Run_engine;

/* added the overloaded procedure for JIT enhancement */
PROCEDURE Run_Engine_jit (p_party_id		IN NUMBER,
							  p_acct_id		IN NUMBER,
				   		          p_psite_id		IN   NUMBER DEFAULT NULL, -- added by spamujul for ER#8473903
							  p_group_id		IN NUMBER,
			  			          p_critical_flag	IN VARCHAR2,
							  p_party_type	IN VARCHAR2 DEFAULT 'CUSTOMER'
							  ) IS
			   v_errbuf  VARCHAR2(240);
			   v_retcode NUMBER;
BEGIN
	/* If party_type is customer -then g_dashboard_for_employee is Y else N */
	 IF upper(p_party_type) ='CUSTOMER' then
	     g_dashboard_for_employee := 'N';
	 elsif upper(p_party_type) ='EMPLOYEE' then
	     g_dashboard_for_employee := 'Y';
	 else
	     g_dashboard_for_employee := ' ';
	 end if;
	Evaluate_Checks2(p_party_id		=> p_party_id,
				     p_acct_id			=> p_acct_id,
				     p_psite_id		=> p_psite_id, -- added by spamujul for ER#8473903
				     p_group_id		=> p_group_id,
				     p_critical_flag		=> p_critical_flag,
				     errbuf				=> v_errbuf,
				     retcode			=> v_retcode);
END Run_Engine_jit;

/* Overloaded procedure for R12 Employee HelpDesk Modifications */
PROCEDURE Run_Engine_All (p_errbuf		OUT	NOCOPY VARCHAR2,
    					                   p_retcode		OUT	NOCOPY NUMBER,
					                   p_party_type	IN		VARCHAR2,
					                   p_party_id          IN		NUMBER,
					                   p_group_id        IN		NUMBER
							   )
							IS
BEGIN
/* If party_type is customer -then g_dashboard_for_employee is Y else N */
	 IF upper(p_party_type) ='CUSTOMER' then
	     g_dashboard_for_employee := 'N';
	 elsif upper(p_party_type) ='EMPLOYEE' then
	     g_dashboard_for_employee := 'Y';
	 else
	     g_dashboard_for_employee := ' ';
	 end if;
	 run_engine(p_errbuf 			=> p_errbuf,
		      p_retcode 			=> p_retcode,
	              p_party_id			=> p_party_id,
	              p_acct_id				=> null,
		      p_psite_id			=> NULL, -- added by spamujul for ER#8473903
		      p_group_id			=> p_group_id);
END Run_Engine_All;
--
-- Evaluate_Checks1_Var
--   Loop through all checks and evaluate the results
--   for each customer and account for type 'B'(Variable)
--   Processing if only Batch_Sql_Stmnt is not null
--   if check_id is null, party_id is null, account_id is null
--	      and block_id is null
--

PROCEDURE Evaluate_Checks1_Var
			IS
		  chk_id					Number;
		  chk_name				Varchar2(240);
		  sel_blk_id				Number;
		  data_type				Varchar2(90);
		  fmt_mask				Varchar2(90);
		  rule					Varchar2(32767);
		  chk_u_l_flag			Varchar2(3);
		  Thd_grade				Varchar2(9);
		  truncate_flag			Varchar2(1)		:= 'N';
		  blk_id					Number := null;
		  sql_stmt				Varchar2(2000)	:= null;
		  batch_sql_stmnt		Varchar2(4000)  := null;
		  curr_code				Varchar2(15)		:= null;
		  v_party_in_sql			Number := 0;
		  v_acct_in_sql			Number := 0;
		  v_psite_in_sql			Number:=0; 	-- Added by spamujul for ER#8473903
		  v_party_id				Number;
		  v_check_level			Varchar2(10);
		  curr_date				DATE := SYSDATE;
		  insert_stmnt			VARCHAR2(4000);
		  insert_stmnt_sum		VARCHAR2(4000);
		  insert_stmnt_final		VARCHAR2(4000);
		  insert_stmnt_party		VARCHAR2(4000);
		  insert_stmnt_acct		VARCHAR2(4000);
		--Fix bug#7329039 by mpathani
		--select_clause       VARCHAR2(100);
		--v_select_clause     VARCHAR2(100);
		  select_clause			VARCHAR2(2000);
		  v_select_clause			VARCHAR2(2000);
		  Range_Low_Value		VARCHAR2(240);
		  Range_High_Value		VARCHAR2(240);
		  val						VARCHAR2(240) := null;
		  /* variables for columns of insert statement */
		  c_fmt_mask			VARCHAR2(1000);
		  c_grade				VARCHAR2(1000);
		  c_curr_code			VARCHAR2(1000);
		  c_threshold				VARCHAR2(1000);
		  c_rating				VARCHAR2(1000);
		  c_color					VARCHAR2(1000);
		  v_count				NUMBER;
		  v_chk_count			NUMBER;
		  v_batch_count			NUMBER;
		-- varlables for getting CSC schema name
		  v_schema_status		VARCHAR2(1);
		  v_industry				VARCHAR2(1);
		  v_schema_name		VARCHAR2(30);
		  v_get_appl				BOOLEAN;
		-- variables to build the batch sql for summation
		  v_select_pos			number;
		  v_select_length			number;
		  v_from_pos				number;
		  v_from_sum			varchar2(2000);
		  v_select_sum			varchar2(2000) := 'SELECT hz.party_id, null,NULL,  '; -- Added 'NULL' for party_site_id  by spamujul for ER#8473903
		  v_group_pos			number;
		  v_group				varchar2(2000) := 'GROUP BY hz.party_id';
		  return_status			varchar2(50);
		-- variables for handling contact profile variables
		  v_where_clause_no_rel	VARCHAR2(1000) := 'HZ.PARTY_TYPE IN (' || '''' || 'PERSON' || '''' || ', ' || '''' ||  'ORGANIZATION' || '''' || ')' ;
		  v_where_clause_rel		VARCHAR2(1000) := 'HZ.PARTY_TYPE = ' || '''' ||'PARTY_RELATIONSHIP'|| '''' ;
		  TABLESEGMENT_FULL  EXCEPTION;
		  INDEXSEGMENT_FULL  EXCEPTION;
		  SNAPSHOT_TOO_OLD   EXCEPTION;
		  INTERNAL_ERROR		EXCEPTION;
		  SUMMATION_ERROR    EXCEPTION;
		  PRAGMA EXCEPTION_INIT(TABLESEGMENT_FULL, -1653);
		  PRAGMA EXCEPTION_INIT(INDEXSEGMENT_FULL, -1654);
		  PRAGMA EXCEPTION_INIT(SNAPSHOT_TOO_OLD, -1555);
		  PRAGMA EXCEPTION_INIT(INTERNAL_ERROR, -600);
		  checks_csr				checks_cur_var;

		  CURSOR block_csr IS
		      SELECT block_id,
					sql_stmnt,
					batch_sql_stmnt,
					currency_code,
					select_clause
			FROM csc_prof_blocks_b a
		       WHERE a.block_id = sel_blk_id;

		   Cursor val_csr3 IS
		     Select Range_Low_Value,
				Range_High_Value
		     From   csc_prof_check_ratings
		     Where  check_id = chk_id
		     and    check_rating_grade = thd_grade;

		   CURSOR rating_crs IS
		     SELECT rating_code,
					check_rating_grade,
					color_code,
					range_low_value,
					range_high_value
		       FROM csc_prof_check_ratings
		      WHERE check_id = chk_id;

BEGIN
	   COMMIT;
	   EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
	   EXECUTE IMMEDIATE 'ALTER SESSION SET SKIP_UNUSABLE_INDEXES=TRUE';
	   v_get_appl :=  FND_INSTALLATION.GET_APP_INFO('CSC', v_schema_status, v_industry, v_schema_name);
	   EXECUTE IMMEDIATE 'ALTER TABLE ' || v_schema_name || '.CSC_PROF_CHECK_RESULTS NOLOGGING';
	   EXECUTE IMMEDIATE 'ALTER TABLE ' || v_schema_name || '.CSC_PROF_BATCH_RESULTS2_T NOLOGGING';
	   EXECUTE IMMEDIATE 'ALTER TABLE ' || v_schema_name || '.CSC_PROF_BATCH_RESULTS1_T NOLOGGING';
	   SELECT count(*)
	   INTO v_chk_count
	   FROM csc_prof_check_results;

	   SELECT count(*)
	   INTO v_batch_count
	   FROM CSC_PROF_BATCH_RESULTS2_T;

	   IF v_chk_count = 0 AND v_batch_count <> 0 THEN
		      EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N2 UNUSABLE';
		      EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N3 UNUSABLE';
		      EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N4 UNUSABLE';
			INSERT /*+ PARALLEL (csc_prof_check_results, 12) */
			INTO csc_prof_check_results
					(check_results_id,
					  check_id,
					  party_id,
					  cust_account_id,
					  party_site_id, -- Added by spamujul for  ER#8473903
					  value,
					  currency_code,
					  grade,
					  created_by,
					  creation_date,
					  last_updated_by,
					  last_update_date,
					  last_update_login,
					  results_threshold_flag,
					  rating_code,
					  color_code
					 )
			SELECT  check_results_id,
					  check_id,
					  party_id,
					  cust_account_id,
					  party_site_id, -- Added by spamujul for  ER#8473903
					  value,
					  currency_code,
					  grade,
					  created_by,
					  creation_date,
					   last_updated_by,
					   last_update_date,
					   last_update_login,
					   results_threshold_flag,
					   rating_code,
					   color_code
				FROM  CSC_PROF_BATCH_RESULTS2_T;
		COMMIT;
		EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N2 REBUILD NOLOGGING';
		EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N3 REBUILD NOLOGGING';
		EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N4 REBUILD NOLOGGING';
	END IF;
	EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || v_schema_name ||'.CSC_PROF_BATCH_RESULTS2_T' ;
	IF g_dashboard_for_contact IS NULL THEN
		FND_PROFILE.GET('CSC_DASHBOARD_VIEW_FOR_CONTACT',g_dashboard_for_contact);
	END IF;
	/* R12 Employee HelpDesk Modifications */
	   /* If g_dashboard_for_employee ='Y' then honour only employee level checks.If
	'N',honour party_level checks with option for contact level fetched from profile option */
	IF g_dashboard_for_employee ='Y' THEN
		OPEN checks_csr FOR
				SELECT check_id,
						 select_block_id,
						 check_level,
						 data_type,
						 format_mask,
						 check_upper_lower_flag,
						 threshold_grade
				FROM csc_prof_checks_b
				 WHERE SYSDATE BETWEEN Nvl(start_date_active, Sysdate)
				AND Nvl(end_date_active, Sysdate)
				 AND select_type = 'B'
				 AND check_level IN ('EMPLOYEE');
	ELSIF g_dashboard_for_employee ='N' THEN
			IF g_dashboard_for_contact = 'Y' THEN
				OPEN checks_csr FOR
					SELECT check_id,
							 select_block_id,
							 check_level,
							data_type,
							format_mask,
							check_upper_lower_flag,
							threshold_grade
					FROM csc_prof_checks_b
			            WHERE SYSDATE BETWEEN Nvl(start_date_active, Sysdate)
					 AND Nvl(end_date_active, Sysdate)
			               AND select_type = 'B'
				      AND check_level IN ('PARTY',
									      'ACCOUNT',
									      'CONTACT',
									      'SITE' -- Added by spamujul for ER#8473903
									      );
			ELSIF g_dashboard_for_contact = 'N' THEN
				OPEN checks_csr FOR
					SELECT check_id
							 , select_block_id,
							 check_level,
							data_type,
							format_mask,
							check_upper_lower_flag,
							threshold_grade
					FROM csc_prof_checks_b
					WHERE SYSDATE BETWEEN Nvl(start_date_active, Sysdate)
					 AND Nvl(end_date_active, Sysdate)
					 AND select_type = 'B'
					 AND check_level IN ('PARTY',
										'ACCOUNT'
										,'SITE'   -- Added by spamujul for ER#8473903
										);
			END IF;
	END IF;
		/* End of  R12 Employee HelpDesk Modifications */
		LOOP
			FETCH checks_csr
			INTO chk_id,
				  sel_blk_id,
				  v_check_level,
				  data_type,
				  fmt_mask,
				  chk_u_l_flag,
				  Thd_grade;
		       EXIT WHEN checks_csr%notfound;
		     Open block_csr;
			Fetch block_csr
			INTO blk_id,
				  sql_stmt,
				  batch_sql_stmnt,
				  curr_code,
				  select_clause;
		       Close block_csr;
			IF batch_sql_stmnt IS NOT NULL THEN
				 IF v_check_level = 'CONTACT' THEN
					IF g_dashboard_for_contact = 'Y' THEN
						batch_sql_stmnt := UPPER(batch_sql_stmnt);
				                batch_sql_stmnt := REPLACE(batch_sql_stmnt, v_where_clause_no_rel, v_where_clause_rel);
			                END IF;
			         END IF;
			          IF sql_stmt IS NOT NULL Then
					 v_party_in_sql	:=	INSTR(lower(sql_stmt),':party_id',1);
				         v_acct_in_sql	:=	INSTR(lower(sql_stmt),':cust_account_id',1);
					 v_psite_in_sql	:=	INSTR(lower(sql_stmt),':party_site_id',1); -- Added by spamujul for ER#8473903
				 Else
					v_party_in_sql	:=	0;
					v_acct_in_sql	:=	0;
					v_psite_in_sql	:=	0;  -- Added by spamujul for ER#8473903
				End if;
				EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || v_schema_name ||'.CSC_PROF_BATCH_RESULTS1_T' ;

				--insert_stmnt := 'INSERT INTO CSC_PROF_BATCH_RESULTS1_T ' || batch_sql_stmnt; -- Commented the following code by spamujul for ER#8473903
				-- Added the following code by spamujul for  ER#8473903
				insert_stmnt := 'INSERT INTO CSC_PROF_BATCH_RESULTS1_T(PARTY_ID,ACCOUNT_ID,PARTY_SITE_ID,VALUE) '  || batch_sql_stmnt;
			        EXECUTE IMMEDIATE (insert_stmnt);
				IF v_acct_in_sql <> 0 AND v_check_level = 'PARTY' THEN
			             v_select_pos := NULL;
				     v_select_length := NULL;
				     v_from_pos := NULL;
				     v_from_sum := NULL;
				     v_select_sum := 'SELECT hz.party_id, null,NULL,  '; -- Added 'NULL' for party_site_id  by spamujul for ER#8473903
				     v_select_clause := NULL;
				     v_group_pos := NULL;
				     v_select_clause := rtrim(ltrim(UPPER(select_clause)));
				     v_select_sum := v_select_sum || v_select_clause;
				     v_select_pos := instr(upper(batch_sql_stmnt), v_select_clause);
				     v_select_length := length(v_select_clause);
				     v_from_pos := v_select_pos + v_select_length;
				     v_from_sum := substr(batch_sql_stmnt, v_from_pos);
				     v_group_pos := instr(upper(v_from_sum), 'GROUP BY HZ.PARTY_ID');
				     v_from_sum := substr(v_from_sum, 1, v_group_pos -1);
				     v_from_sum := v_from_sum || v_group;
				     v_select_sum := v_select_sum || '  ' || v_from_sum;
				     -- validate the sql statement
				    csc_core_utils_pvt.validate_sql_stmnt( p_sql_stmnt => v_select_sum,
                                                    x_return_status => return_status);
				     IF return_status = 'S' THEN
				     	  -- insert_stmnt_sum := 'INSERT INTO CSC_PROF_BATCH_RESULTS1_T ' || v_select_sum ;  -- Commented the following code by spamujul for ER#8473903
					  	-- Added the following code by spamujul for  ER#8473903
					      insert_stmnt_sum := 'INSERT INTO CSC_PROF_BATCH_RESULTS1_T(PARTY_ID,ACCOUNT_ID,PARTY_SITE_ID,VALUE) ' || v_select_sum ;
					   EXECUTE IMMEDIATE (insert_stmnt_sum);
				     ELSE
					RAISE SUMMATION_ERROR;
					fnd_file.put_line(fnd_file.log, 'Summation SQL failed for check_id' || chk_id);
				     END IF;
		          END IF;
		          IF v_check_level = 'PARTY' THEN
					INSERT INTO CSC_PROF_BATCH_RESULTS1_T(PARTY_ID,
																     ACCOUNT_ID,
																     PARTY_SITE_ID,-- Added by spamujul for ER#8473903
																     VALUE)
					SELECT party_id,
							NULL,
							NULL, -- Added by spamujul for ER#8473903
							NULL
					FROM hz_parties hz
					WHERE NOT EXISTS (SELECT 1 FROM CSC_PROF_BATCH_RESULTS1_T c
										WHERE c.party_id = hz.party_id
										AND C.PARTY_SITE_ID IS NULL -- Added by spamujul for ER#8473903
										)
						AND hz.status = 'A'
						AND hz.party_type IN ('PERSON', 'ORGANIZATION')
						;
			ELSIF v_check_level = 'CONTACT' THEN
					INSERT INTO CSC_PROF_BATCH_RESULTS1_T(PARTY_ID,
																     ACCOUNT_ID,
																     PARTY_SITE_ID,-- Added by spamujul for ER#8473903
																     VALUE)
				    SELECT party_id,
						     NULL,
						     NULL, -- Added 'NULL' for party_site_id by spamujul for ER#8473903
						     NULL
				       FROM hz_parties hz
				      WHERE NOT EXISTS (SELECT 1 FROM CSC_PROF_BATCH_RESULTS1_T c
												 WHERE c.party_id = hz.party_id
												 AND C.PARTY_SITE_ID IS NULL -- Added by spamujul for ER#8473903
												 )
					AND hz.status = 'A'
					AND hz.party_type = 'PARTY_RELATIONSHIP' ;
			ELSIF v_check_level = 'ACCOUNT' THEN
				     INSERT INTO CSC_PROF_BATCH_RESULTS1_T(PARTY_ID,
																 ACCOUNT_ID,
																  PARTY_SITE_ID,-- Added by spamujul for ER#8473903
																 VALUE
																 )
				     SELECT party_id,
						      cust_account_id,
						      NULL, -- Added 'NULL' for party_site_id by spamujul for ER#8473903
						      NULL
				       FROM hz_cust_accounts hz
				      WHERE NOT EXISTS (SELECT 1
										FROM CSC_PROF_BATCH_RESULTS1_T c
										WHERE c.account_id = hz.cust_account_id
										AND C.PARTY_SITE_ID IS NULL -- Added by spamujul for ER#8473903
										)
					AND hz.status = 'A'
					;
			ELSIF v_check_level = 'EMPLOYEE' THEN
				     INSERT INTO CSC_PROF_BATCH_RESULTS1_T(PARTY_ID,
																  ACCOUNT_ID,
																 PARTY_SITE_ID,-- Added by spamujul for ER#8473903
																  VALUE)
				     SELECT person_id,
						      NULL,
						      NULL , -- Added 'NULL' for party_site_id by spamujul for ER#8473903
						      NULL
				       FROM per_workforce_current_x hz
				      WHERE NOT EXISTS (SELECT 1
										FROM CSC_PROF_BATCH_RESULTS1_T c
										WHERE c.party_id = hz.person_id
										AND C.PARTY_SITE_ID IS NULL -- Added by spamujul for ER#8473903
				      ) ;

			-- Begin fix by spamujul for  ER#8473903
			ELSIF v_check_level = 'SITE' THEN
				   INSERT INTO CSC_PROF_BATCH_RESULTS1_T(PARTY_ID,
															     ACCOUNT_ID,
															     PARTY_SITE_ID,
															     VALUE)
				     SELECT hz.party_id,
						      NULL,
						      hz.party_site_id ,
						      NULL
					FROM hz_party_sites hz
					WHERE NOT EXISTS (SELECT 1 FROM CSC_PROF_BATCH_RESULTS1_T c
												  WHERE c.party_id = hz.party_id
												  and c.party_site_id = hz.party_site_id)
					AND hz.status = 'A'
					AND nvl(hz.created_by_module,'XXX') <> 'SR_ONETIME';
		-- End fix by spamujul for  ER#8473903
			END IF;

          OPEN val_csr3;
          FETCH val_csr3
	  INTO Range_Low_Value,
		    Range_High_Value;
          IF val_csr3%NOTFOUND THEN
             Range_Low_Value := NULL;
             Range_High_Value := NULL;
          END IF;
          CLOSE val_csr3;

          SELECT COUNT(*) INTO v_count FROM csc_prof_check_ratings
          WHERE check_id = chk_id;

          rating_tbl.delete;

          IF v_count > 0 THEN
             OPEN rating_crs;
             FOR a in 1..v_count LOOP
                FETCH rating_crs INTO rating_tbl(a);
             END LOOP;
             CLOSE rating_crs;
          END IF;

          c_fmt_mask := 'CSC_Profile_Engine_PKG.format_mask(' ||
                        '''' || curr_code || '''' || ',' ||
                        '''' || data_type || '''' || ','||
	                'value, '||
		        ''''|| fmt_mask || '''' || ')' ;

          c_grade := 'CSC_Profile_Engine_PKG.rating_color(' ||
                     chk_id || ', ' ||
                     'party_id, account_id,party_site_id, value, ' || -- included 'party_site_id'  by spamujul for  ER#8473903
                     '''' || data_type || '''' || ', ' ||
                     '''' || 'GRADE' || '''' ||', ' ||
                     '''' || v_count || '''' || ')'    ;

          c_curr_code := '''' || curr_code || '''';

          c_threshold := 'CSC_Profile_Engine_PKG.calc_threshold(' ||
                         'value, '||
	                 '''' || Range_Low_Value || '''' || ', '||
	                 '''' || Range_High_Value || '''' || ', '||
		         '''' || data_type || '''' || ', ' ||
		         '''' || chk_u_l_flag || '''' || ')'   ;

          c_rating := 'CSC_Profile_Engine_PKG.rating_color(' ||
                      chk_id || ', ' ||
                      'party_id, account_id,party_site_id, value, ' || -- included 'party_site_id'  by spamujul for  ER#8473903
                      '''' || data_type || '''' || ', ' ||
                      '''' || 'RATING' || '''' ||', ' ||
	              '''' || v_count || '''' || ')'    ;

          c_color := 'CSC_Profile_Engine_PKG.rating_color(' ||
                      chk_id || ', ' ||
                     'party_id, account_id,party_site_id, value, ' || -- included 'party_site_id'  by spamujul for  ER#8473903
                     '''' || data_type || '''' || ', ' ||
                     '''' || 'COLOR' || '''' ||', ' ||
                     '''' || v_count || '''' || ')'    ;


          IF v_check_level = 'ACCOUNT' THEN
             insert_stmnt_final := 'INSERT /*+ PARALLEL(CSC_PROF_BATCH_RESULTS2_T, 12) */ INTO CSC_PROF_BATCH_RESULTS2_T ' ||
                             '(check_results_id, check_id, party_id, cust_account_id, party_site_id,value, currency_code, grade, '|| -- Inlcuded 'party_site_id' for ER#8473903
			     ' created_by, creation_date, last_updated_by, last_update_date, last_update_login, '||
			     ' results_threshold_flag, rating_code, color_code)' ||
                             ' SELECT csc_prof_check_results_s.nextval, '
			      || chk_id || ', party_id, account_id,party_site_id, ' -- Inlcuded 'party_site_id' by spamujul for ER#8473903
			      || c_fmt_mask ||', '
			      || c_curr_code || ', '
			      || c_grade
			      || ', FND_GLOBAL.USER_ID, Sysdate, FND_GLOBAL.USER_ID, Sysdate, FND_GLOBAL.CONC_LOGIN_ID, '
			      || c_threshold ||', '
			      || c_rating || ', '
			      || c_color
			      ||' FROM CSC_PROF_BATCH_RESULTS1_T where nvl(account_id, -999999) <> -999999 and PARTY_SITE_ID IS NULL'; -- Inlcuded 'party_site_id' IS NULL FOR ER#8473903
	-- Begin fix by spamujul for ER# 8473903
	ELSIF  v_check_level = 'SITE' THEN
		insert_stmnt_final := 'INSERT /*+ PARALLEL(CSC_PROF_BATCH_RESULTS2_T, 12) */ INTO CSC_PROF_BATCH_RESULTS2_T ' ||
                  --          '(check_results_id, check_id, party_id, cust_account_id,value, currency_code, grade, '||
		  -- added party_site_id in the below line for ER#8473903
			  '(check_results_id, check_id, party_id, cust_account_id,party_site_id, value, currency_code, grade, '|| -- Inlcuded 'party_site_id' for ER#8473903
			     ' created_by, creation_date, last_updated_by, last_update_date, last_update_login, '||
			     ' results_threshold_flag, rating_code, color_code)' ||
                             ' SELECT csc_prof_check_results_s.nextval, '
			--      || chk_id || ', party_id, account_id, '
			 -- added party_site_id in the below line for ER#8473903
			      || chk_id || ', party_id, account_id,party_site_id, ' -- Inlcuded 'party_site_id' by spamujul  for ER#8473903
			      || c_fmt_mask ||', '
			      || c_curr_code || ', '
			      || c_grade
			      || ', FND_GLOBAL.USER_ID, Sysdate, FND_GLOBAL.USER_ID, Sysdate, FND_GLOBAL.CONC_LOGIN_ID, '
			      || c_threshold ||', '
			      || c_rating || ', '
			      || c_color
			      ||' FROM CSC_PROF_BATCH_RESULTS1_T where nvl(party_site_id, -999999) <> -999999 and account_id IS NULL';
-- End fix by spamujul for ER#8473903
          ELSE
             insert_stmnt_final := 'INSERT /*+ PARALLEL(CSC_PROF_BATCH_RESULTS2_T, 12) */ INTO CSC_PROF_BATCH_RESULTS2_T ' ||
                             '(check_results_id, check_id, party_id, cust_account_id, party_site_id,value, currency_code, grade, '|| -- Inlcuded 'party_site_id' for ER#8473903
			     ' created_by, creation_date, last_updated_by, last_update_date, last_update_login, '||
			     ' results_threshold_flag, rating_code, color_code)' ||
                             ' SELECT csc_prof_check_results_s.nextval, '
			      || chk_id || ', party_id, account_id,party_site_id ,'
			      || c_fmt_mask ||', '
			      || c_curr_code || ', '
			      || c_grade
			      || ', FND_GLOBAL.USER_ID, Sysdate, FND_GLOBAL.USER_ID, Sysdate, FND_GLOBAL.CONC_LOGIN_ID, '
			      || c_threshold ||', '
			      || c_rating || ', '
			      || c_color
			      ||' FROM CSC_PROF_BATCH_RESULTS1_T where account_id IS NULL and PARTY_SITE_ID IS NULL'; -- Inlcuded 'party_site_id' IS NULL FOR ER#8473903';
          END IF;
          EXECUTE IMMEDIATE (insert_stmnt_final);
          COMMIT;
      ELSE
         /* set the global variable to Y to indicate that profile checks without batch sql exist */
         g_check_no_batch := 'Y';
      END IF ; /* batch_sql_stmnt IS NOT NULL */
   END LOOP;
   CLOSE checks_csr;

--   INSERT /*+ PARALLEL (CSC_PROF_BATCH_RESULTS2_T, 12) */
/*   INTO CSC_PROF_BATCH_RESULTS2_T
			(check_results_id,
			 check_id,
			 party_id,
			 cust_account_id,
			 party_site_id,  -- Added by spamujul for  ER#8473903
			value,
			currency_code,
			grade,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			results_threshold_flag,
			rating_code,
			color_code
      )
   SELECT
		check_results_id,
		check_id,
		party_id,
		cust_account_id,
		party_site_id,  -- Added by spamujul for  ER#8473903
		value,
		currency_code,
		grade,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
		results_threshold_flag,
		rating_code,
		color_code
   FROM  csc_prof_check_results a
   WHERE NOT EXISTS (SELECT null FROM csc_prof_checks_b b
                      WHERE a.check_id = b.check_id
                        AND b.select_type = 'B');
*/
   COMMIT;

   EXECUTE IMMEDIATE 'TRUNCATE TABLE '|| v_schema_name ||'.csc_prof_check_results';


   EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N2 UNUSABLE';
   EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N3 UNUSABLE';
   EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N4 UNUSABLE';

   INSERT /*+ PARALLEL (csc_prof_check_results, 12) */
   INTO csc_prof_check_results
		(check_results_id,
		check_id,
		party_id,
		cust_account_id,
		party_site_id,  -- Added by spamujul for  ER#8473903
		value,
		currency_code,
		grade,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
		results_threshold_flag,
		rating_code,
		color_code
      )
   SELECT
		 check_results_id,
		 check_id,
		 party_id,
		 cust_account_id,
		 party_site_id,  -- Added by spamujul for  ER#8473903
		value,
		currency_code,
		grade,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
		results_threshold_flag,
		rating_code,
		color_code
   FROM  CSC_PROF_BATCH_RESULTS2_T;

   COMMIT;

   EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N2 REBUILD NOLOGGING';
   EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N3 REBUILD NOLOGGING';
   EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N4 REBUILD NOLOGGING';

   EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || v_schema_name ||'.CSC_PROF_BATCH_RESULTS2_T' ;

   EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';
   EXECUTE IMMEDIATE 'ALTER TABLE ' || v_schema_name || '.CSC_PROF_CHECK_RESULTS LOGGING';

EXCEPTION
        when Tablesegment_full then
             CSC_Profile_Engine_PKG.Handle_Exception;
             g_error := sqlcode || ' ' || sqlerrm;
             fnd_file.put_line(fnd_file.log , g_error);
             App_Exception.raise_exception;

        when Indexsegment_full then
             CSC_Profile_Engine_PKG.Handle_Exception;
             g_error := sqlcode || ' ' || sqlerrm;
             fnd_file.put_line(fnd_file.log , g_error);
             App_Exception.raise_exception;

        when SNAPSHOT_TOO_OLD THEN
             CSC_Profile_Engine_PKG.Handle_Exception;
             g_error := sqlcode || ' ' || sqlerrm;
             fnd_file.put_line(fnd_file.log,g_error);
             App_Exception.raise_exception;

        WHEN INTERNAL_ERROR THEN
             CSC_Profile_Engine_PKG.Handle_Exception;
             g_error := sqlcode || ' ' || sqlerrm;
             fnd_file.put_line(fnd_file.log,g_error);
             App_Exception.raise_exception;

        WHEN SUMMATION_ERROR THEN
             CSC_Profile_Engine_PKG.Handle_Exception;
             set_context('Evaluate_Checks1_Var',
                         'Summation SQL failed for chk_id => '||to_char(chk_id));
             RAISE;

	WHEN OTHERS THEN
             CSC_Profile_Engine_PKG.Handle_Exception;
	     g_error := sqlcode || ' ' || sqlerrm;
	     fnd_file.put_line(fnd_file.log , g_error);

END Evaluate_Checks1_Var;
--
-- Evaluate_Checks1_No_Batch
--   Loop through all checks and evaluate the results
--   for each customer and account for type variable ('B')
--   The procedure is called if the Batch_Sql_Stmnt is null (for backward compatibility)
--   if check_id is null, party_id is null, account_id is null
--	      and block_id is null
--
PROCEDURE Evaluate_Checks1_No_Batch   ( errbuf	OUT	NOCOPY VARCHAR2,
											retcode	OUT	NOCOPY NUMBER
										    ) IS

			  chk_id				Number;
			  chk_name			Varchar2(240);
			  cparty_id			Number;
			  ccust_acct_id		Number;
			  ccust_psite_id		Number;  -- added by spamujul for ER#8473903
			  sel_type			Varchar2(3);
			  sel_blk_id			Number;
			  data_type			Varchar2(90);
			  fmt_mask			Varchar2(90);
			  rule				Varchar2(32767);
			  Chk_u_l_flag		Varchar2(3);
			  Thd_grade			Varchar2(9);
			  truncate_flag		Varchar2(1) := 'N';
			  acct_flag			Varchar2(1);
			  blk_id				Number 		:= null;
			  blk_name			Varchar2(240)	:= null;
			  sql_stmt			Varchar2(2000)	:= null;
			  curr_code			Varchar2(15)	:= null;
			  v_party_in_sql		Number := 0;
			  v_acct_in_sql		Number := 0;
			  v_psite_in_sql		Number :=0; -- added by spamujul for ER#8473903
			  v_check_level		Varchar2(10);
			  l_for_insert			varchar2(1) := 'Y';
			  l_for_party			varchar2(1) := 'Y';
			  l_for_psite			Varchar2(1) := 'N';-- added by spamujul for ER#8473903
			  l_up_total			Number := 0;
			  l_ip_total			Number := 0;
			  l_ua_total			Number := 0;
			  l_ia_total			Number := 0;
			  l_us_total			Number :=0; -- added by spamujul for ER#8473903
			  l_is_total			Number :=0; -- added by spamujul for ER#8473903
			  v_party_id			Number;


			  CURSOR checks_csr IS
			  SELECT check_id, select_type, select_block_id,
				 data_type, format_mask,check_upper_lower_flag,
					 threshold_grade, check_level
			    FROM csc_prof_checks_b a
			   WHERE check_id IN (SELECT check_id FROM csc_prof_group_checks)
			     AND select_type = 'B'
			     AND CHECK_ID =42
			     AND check_level IN ('PARTY',
								   'ACCOUNT',
								   'SITE' --Added  'SITE' by spamujul for ER#8473903
								   )
			     AND EXISTS (SELECT null
					   FROM csc_prof_blocks_b b
					  WHERE a.select_block_id = b.block_id
					    AND b.batch_sql_stmnt IS NULL)
			     AND SYSDATE BETWEEN Nvl(start_date_active, SYSDATE)
					     AND Nvl(end_date_active, SYSDATE);

			  CURSOR cparty_csr IS
			     SELECT party_id
			     FROM hz_parties
			    WHERE status = 'A'
			    AND  PARTY_TYPE IN ('PERSON','ORGANIZATION');
			    -- Person, ORG added for 1850508

			  CURSOR caccount_csr IS
			     SELECT party_id, cust_account_id
			     FROM hz_cust_accounts
			     WHERE  party_id=v_party_id
			     AND  status = 'A' ;
			      -- Begin fix by spamujul for NCR ER#8473903
				CURSOR cpsite_csr IS
				      SELECT party_id, party_site_id
				      FROM hz_party_sites
				      WHERE  party_id=v_party_id
				      AND  status = 'A'
				      AND NVL(created_by_module,'XXX') <> 'SR_ONETIME';
			  -- End fix by spamujul for NCR ER#8473903
			  CURSOR block_csr IS
			      SELECT block_id, sql_stmnt, currency_code
			      FROM csc_prof_blocks_b a
			      WHERE a.block_id = sel_blk_id;

			cid 		number;
			val		VARCHAR2(240) := null;

BEGIN
		/* R12 Employee HelpDesk Modifications */

		/* The processing to be done for either employee level(employee) or customer level(party,account,contact) */
		IF g_dashboard_for_employee = 'N' THEN
			   l_ip_total := 0;
			   l_up_total := 0;
			   l_ia_total := 0;
			   l_ua_total := 0;
			   l_us_total := 0; -- added by spamujul for ER#8473903
			   l_is_total := 0; -- added by spamujul for ER#8473903
			OPEN checks_csr;
				LOOP
					 FETCH checks_csr
					  INTO      chk_id,
							  sel_type,
							  sel_blk_id,
							  data_type,
							  fmt_mask,
							  chk_u_l_flag,
							  Thd_grade,
							  v_check_level;
					 EXIT WHEN checks_csr%notfound;
					  Open block_csr;
						      Fetch block_csr
						      INTO blk_id,
								sql_stmt,
								curr_code;
					   Close block_csr;

					      IF sql_stmt IS NOT NULL Then
						 v_party_in_sql := INSTR(lower(sql_stmt),':party_id',1);
						 v_acct_in_sql  := INSTR(lower(sql_stmt),':cust_account_id',1);
						  v_psite_in_sql  := INSTR(lower(sql_stmt),':cust_account_id',1); -- added by spamujul for ER#8473903
					      Else
						 v_party_in_sql :=   0;
						 v_acct_in_sql  :=   0;
						 v_psite_in_sql  := 0; -- added by spamujul for ER#8473903
					      End if;
					      Begin
							 cid := dbms_sql.open_cursor;
							 dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
							 dbms_sql.define_column(cid,1,val,240);
							 OPEN cparty_csr;
								   LOOP
									    FETCH cparty_csr INTO cparty_id;
									    EXIT WHEN cparty_csr%notfound;
									    If v_check_level='PARTY' Then
									  Evaluate_One_Check(truncate_flag,
														     chk_id,
														     cparty_id,
														     null,
														     NULL, -- added by spamujul for ER#8473903
														     v_check_level,
														     sel_type,
														     sel_blk_id,
														     data_type,
														     fmt_mask,
														     chk_u_l_flag,
														     Thd_grade,
														     rule,
														     blk_id,
														     sql_stmt,
														     curr_code,
														     l_up_total,
														     l_ip_total,
														     l_ua_total,
														     l_ia_total ,
														     l_us_total, -- added by spamujul for ER#8473903
														     l_is_total, -- added by spamujul for ER#8473903
														     cid);
									End if;
								        /* added this condition for Bug 1937730*/
								        v_party_id:=cparty_id;
									 IF v_check_level = 'ACCOUNT' Then
										If (v_acct_in_sql = 0)  Then
											 NULL;
										Else
											 OPEN caccount_csr;
													LOOP
														     FETCH caccount_csr
														      INTO cparty_id, ccust_acct_id;
														     EXIT WHEN caccount_csr%notfound;
														     Evaluate_One_Check(truncate_flag,
																			chk_id,
																			cparty_id,
																			ccust_acct_id,
																			NULL,  -- added by spamujul for ER#8473903
																			v_check_level,
																			sel_type,
																			sel_blk_id,
																			data_type,
																			fmt_mask,
																			chk_u_l_flag,
																			Thd_grade,
																			rule,
																			blk_id,
																			sql_stmt,
																			curr_code,
																			l_up_total,
																			l_ip_total,
																			l_ua_total,
																			l_ia_total ,
																			l_us_total, -- added by spamujul for ER#8473903
																			l_is_total, -- added by spamujul for ER#8473903
																			cid);
													 END LOOP;
											CLOSE caccount_csr;
										End if; -- added for 1850508
									END IF;
									-- Begin fix by spamujul for ER#8473903
								IF v_check_level = 'SITE' THEN
									IF (v_psite_in_sql = 0)  THEN
											 NULL;
										ELSE
											OPEN cpsite_csr ;
												LOOP
													FETCH cpsite_csr
													    INTO cparty_id,
														       ccust_psite_id;
													    EXIT WHEN cpsite_csr%notfound;
													    Evaluate_One_Check(truncate_flag,
																		chk_id,
																		cparty_id,
																		NULL,
																		ccust_psite_id,
																		v_check_level,
																		sel_type,
																		sel_blk_id,
																		data_type,
																		fmt_mask,
																		chk_u_l_flag,
																		Thd_grade,
																		rule,
																		blk_id,
																		sql_stmt,
																		curr_code,
																		l_up_total,
																		l_ip_total,
																		l_ua_total
																		, l_ia_total ,
																		l_us_total,
																		l_is_total,
																		cid
																		);
												END LOOP;
											CLOSE cpsite_csr;
										END IF;
								END IF;
								-- End fix by spamujul for ER#8473903
						END LOOP;
				CLOSE cparty_csr;
				 IF (dbms_sql.is_open(cid)) THEN
				    dbms_sql.close_cursor(cid);
				 end if;
			Exception
					When others then
						     IF (dbms_sql.is_open(cid)) THEN
							dbms_sql.close_cursor(cid);
						     end if;
						     set_context('Evaluate_Checks1_No_Batch',
							'chk_id=>'||to_char(chk_id),
							'party_id=>'||to_char(cparty_id),
							'account_id=>'||to_char(ccust_acct_id)
							,'party_site_id=>'||to_char(ccust_psite_id) -- added by spamujul for ER#8473903
							);
						     g_error := sqlcode || ' ' || sqlerrm;
						     set_context(NULL, g_error);
			End;
		END LOOP;
	CLOSE checks_csr;
	   -- check if there are still records to be inserted
	   IF l_ip_total <> 0 THEN
		l_for_insert	:= 'Y';
		l_for_party	:= 'Y';
		l_for_psite	:= 'N';-- added by spamujul for ER#8473903
		Insert_Update_Check_Results(l_ip_total,
								 l_for_insert,
								 l_for_party
								,l_for_psite -- added by spamujul for ER#8473903
								 );
		l_ip_total :=0;
	   END IF;
	   -- check if there are still records to be updated
	   IF l_up_total <> 0 THEN
		l_for_insert	:= 'N';
		l_for_party	:= 'Y';
		l_for_psite	:= 'N';-- added by spamujul for ER#8473903
		Insert_Update_Check_Results(l_up_total,
								 l_for_insert,
								 l_for_party
								,l_for_psite -- added by spamujul for ER#8473903
								 );
		l_up_total :=0;
	   END IF;

	   -- check if there are still records to be inserted
	   IF l_ia_total <> 0 THEN
		l_for_insert	:= 'Y';
		l_for_party	:= 'N';
		l_for_psite	:= 'N';-- added by spamujul for ER#8473903
		Insert_Update_Check_Results(l_ia_total,
								  l_for_insert,
								  l_for_party
								 ,l_for_psite -- added by spamujul for ER#8473903
								  );
		l_ia_total :=0;
	   END IF;
	   -- check if there are still records to be updated
	   IF l_ua_total <> 0 THEN
		l_for_insert	:= 'N';
		l_for_party	:= 'N';
		l_for_psite	:= 'N';-- added by spamujul for ER#8473903
		Insert_Update_Check_Results(l_ua_total,
								 l_for_insert,
								 l_for_party
								,l_for_psite -- added by spamujul for ER#8473903
								 );
		l_ua_total :=0;
	   END IF;
	    -- Begin fix by spamujul for ER#8473903
	 IF l_is_total <> 0 THEN
			l_for_insert	:= 'Y';
			l_for_party	:= 'N';
			l_for_psite	:= 'Y';
			Insert_Update_Check_Results(l_is_total,
										l_for_insert,
										l_for_party
										,l_for_psite -- added by spamujul for ER#8473903
										);
			l_is_total :=0;
	   END IF;
	   IF l_us_total <> 0 THEN
		l_for_insert	:= 'N';
		l_for_party	:= 'N';
		l_for_psite	:= 'N'; -- added by spamujul for ER#8473903
		Insert_Update_Check_Results(l_us_total,
								 l_for_insert,
								 l_for_party
								,l_for_psite -- added by spamujul for ER#8473903
								 );
		l_us_total :=0;
	   END IF;
	 -- End fix by spamujul ER#8473903
   IF g_dashboard_for_contact IS NULL THEN
      FND_PROFILE.GET('CSC_DASHBOARD_VIEW_FOR_CONTACT',g_dashboard_for_contact);
   END IF;

   IF g_dashboard_for_contact = 'Y' THEN
       l_ip_total := 0;
       l_up_total := 0;
       l_ia_total := 0;
       l_ua_total := 0;
       l_us_total := 0; -- added by spamujul for ER#8473903
       l_is_total := 0; -- added by spamujul for ER#8473903

       Evaluate_blocks_Rel(p_up_total => l_up_total,
						   p_ip_total => l_ip_total,
						   p_ua_total => l_ua_total,
						   p_ia_total => l_ia_total,
						   p_us_total => l_us_total, -- added by spamujul for ER#8473903
						   p_is_total  => l_is_total , -- added by spamujul for ER#8473903
						   p_no_batch_sql => 'Y' );

       Evaluate_checks_Rel(errbuf => errbuf,
                           retcode => retcode,
                           p_no_batch_sql => 'Y');
   END IF;

   COMMIT;

   -- Return 0 for successful completion, 1 for warnings, 2 for error
   IF (error_flag) THEN
      errbuf := Sqlerrm;
      retcode := 2;
   ELSIF (warning_msg <> '') THEN
      errbuf := warning_msg;
      retcode := 1;
   ELSE
      errbuf := '';
      retcode := 0;
   END IF;

ELSIF g_dashboard_for_employee = 'Y' THEN
       l_ip_total := 0;
       l_up_total := 0;
       l_ia_total := 0;
       l_ua_total := 0;
       l_us_total := 0; -- added by spamujul for ER#8473903
       l_is_total := 0; -- added by spamujul for ER#8473903

       Evaluate_blocks_Emp(p_up_total => l_up_total,
                           p_ip_total => l_ip_total,
                           p_ua_total => l_ua_total,
                           p_ia_total => l_ia_total,
			   p_us_total => l_us_total, -- added by spamujul for ER#8473903
			   p_is_total => l_is_total, -- added by spamujul for ER#8473903
                           p_no_batch_sql => 'Y' );

       Evaluate_checks_Emp(errbuf => errbuf,
                           retcode => retcode,
                           p_no_batch_sql => 'Y');
END IF;

   COMMIT;

   -- Return 0 for successful completion, 1 for warnings, 2 for error
   IF (error_flag) THEN
      errbuf := Sqlerrm;
      retcode := 2;
   ELSIF (warning_msg <> '') THEN
      errbuf := warning_msg;
      retcode := 1;
   ELSE
      errbuf := '';
      retcode := 0;
   END IF;

   IF (debug) THEN
      fnd_file.close;
   END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         IF (checks_csr%isopen) THEN
	    CLOSE checks_csr;
	 END IF;
	 IF (cparty_csr%isopen) THEN
	    CLOSE cparty_csr;
	 END IF;
	 IF (caccount_csr%isopen) THEN
	    CLOSE caccount_csr;
	 END IF;
	 -- Begin fix by spamujul for ER#8473903
	 IF (cpsite_csr%isopen) THEN
	    CLOSE cpsite_csr;
	 END IF;
	-- End  fix by spamujul for ER#8473903
	 IF (debug) THEN
	    fnd_file.close;
	 END IF;

         -- Retrieve error message into errbuf
         errbuf := Sqlerrm;

      	 -- Return 2 for error
         retcode := 2;

	 g_error := sqlcode || ' ' || sqlerrm;
	 fnd_file.put_line(fnd_file.log , g_error);

/* End of R12 Employee HelpDesk Modifications */

END Evaluate_Checks1_No_Batch;

--
-- Evaluate_Checks1_Rule
--   Loop through all checks and evaluate the results
--   for each customer and account for type 'T' (Rules)
--   if check_id is null, party_id is null, account_id is null
--	      and block_id is null
--
PROCEDURE Evaluate_Checks1_Rule   ( errbuf	OUT	NOCOPY VARCHAR2,
									    retcode	OUT	NOCOPY NUMBER
									    ) IS

			  chk_id				Number;
			  chk_name			Varchar2(240);
			  cparty_id			Number;
			  ccust_acct_id		Number;
			  cpsite_id			Number; -- added by spamujul for ER#8473903
			  sel_type			Varchar2(3);
			  sel_blk_id			Number;
			  data_type			Varchar2(90);
			  fmt_mask			Varchar2(90);
			  rule				Varchar2(32767);
			  chk_u_l_flag		Varchar2(3);
			  Thd_grade			Varchar2(9);
			  truncate_flag		Varchar2(1) := 'N';
			  acct_flag			Varchar2(1);
			  blk_id				Number 		:= null;
			  blk_name			Varchar2(240)	:= null;
			  sql_stmt			Varchar2(2000)	:= null;
			  curr_code			Varchar2(15)	:= null;
			  v_party_in_sql		Number := 0;
			  v_acct_in_sql		Number := 0;
			  v_psite_in_sql		Number	:= 0; -- added by spamujul for ER#8473903
			  l_for_insert			varchar2(1) := 'Y';
			  l_for_party			varchar2(1) := 'Y';
			  l_for_psite			Varchar2(1) := 'N'; -- added by spamujul for ER#8473903
			  l_up_total			Number := 0;
			  l_ip_total			Number := 0;
			  l_ua_total			Number := 0;
			  l_ia_total			Number := 0;
			  l_us_total			Number := 0;   -- added by spamujul for ER#8473903
			  l_is_total			Number := 0;   -- added by spamujul for ER#8473903
			  /* added this variable for Bug 1937730*/
			  v_party_id			Number;
			  v_check_level		Varchar2(10);
			  v_chk_count		NUMBER := 0;

			  CURSOR checks_csr IS
			     SELECT check_id,
					      select_type,
					      select_block_id,
					      check_level,
					      data_type,
					      format_mask,
					      check_upper_lower_flag,
					      threshold_grade
			     FROM csc_prof_checks_b
			     WHERE Sysdate BETWEEN Nvl(start_date_active, Sysdate)
					AND Nvl(end_date_active, Sysdate)
			       AND check_level IN ('PARTY',
								      'ACCOUNT'
								      ,'SITE' -- added by spamujul for ER#8473903
								      )
			       AND select_type = 'T'
			     ORDER BY check_id;

			  CURSOR checks_count IS
			     SELECT COUNT(*)
			       FROM csc_prof_checks_b
			      WHERE Sysdate BETWEEN Nvl(start_date_active, Sysdate)
						     AND Nvl(end_date_active, Sysdate)
				AND select_type = 'T';

			  CURSOR cparty_csr IS
			     SELECT party_id
			     FROM hz_parties
			    WHERE status = 'A'
			    AND  PARTY_TYPE IN ('PERSON','ORGANIZATION');
			    -- Person, ORG added for 1850508

/* added this condition party_id=v_party_id for Bug 1937730*/
			  CURSOR caccount_csr IS
			     SELECT party_id, cust_account_id
			     FROM hz_cust_accounts
			     WHERE  party_id=v_party_id
			     AND  status = 'A';
			   -- Begin fix by spamujul for ER#8473903
			   CURSOR cpsite_csr IS
				      SELECT party_id, party_site_id
				      FROM hz_party_sites
				      WHERE  party_id=v_party_id
				      AND  status = 'A'
				      AND NVL(created_by_module,'XXX') <> 'SR_ONETIME';
			 -- End fix by spamujul for ER#8473903

			  CURSOR block_csr IS
			      SELECT block_id, sql_stmnt, currency_code
			      FROM csc_prof_blocks_b a
			      WHERE a.block_id = sel_blk_id;

    -- added for 1850508
			cid 		number;
			val		VARCHAR2(240) := null;

BEGIN

		/* R12 Employee HelpDesk Modifications */

		/* The processing to be done for either employee level(employee) or customer level(party,account,contact) */
		IF g_dashboard_for_employee = 'N' THEN
			OPEN checks_count;
				   FETCH checks_count INTO v_chk_count;
			CLOSE checks_count;
			IF v_chk_count > 0 THEN
			      /* blocks will be evaluated only if the type is T */
			  -- Populate the block results table for all parties and accounts
				   Evaluate_Blocks1(l_up_total,
								l_ip_total,
								l_ua_total,
								l_ia_total
								,l_us_total, -- added by spamujul for ER#8473903
								l_is_total  -- added by spamujul for ER#8473903
								);
			   END IF;
			   l_ip_total := 0;
			   l_up_total := 0;
			   l_ia_total := 0;
			   l_ua_total := 0;
			   l_us_total  := 0;  -- added by spamujul for ER#8473903
			   l_ia_total   := 0;  -- added by spamujul for ER#8473903
			  OPEN checks_csr;
					 LOOP
						   FETCH checks_csr
							INTO chk_id,
								   sel_type,
								   sel_blk_id,
								   v_check_level,
								   data_type,
								   fmt_mask,
								   chk_u_l_flag,
								   Thd_grade;
						         EXIT WHEN checks_csr%notfound;
							 IF (sel_type = 'T') THEN
							   acct_flag := 'N';
							   build_rule(acct_flag,chk_id,v_check_level, rule);
							ELSIF (sel_type = 'B') THEN
								   Open block_csr;
									     Fetch block_csr
									     INTO blk_id,
											sql_stmt,
											curr_code;
									Close block_csr;

			/* Uncommented this condition for Bug 1937730*/
			   /*****************/
			   IF sql_stmt IS NOT NULL Then
			      v_party_in_sql := INSTR(lower(sql_stmt),':party_id',1);
			      v_acct_in_sql  := INSTR(lower(sql_stmt),':cust_account_id',1);
			      v_psite_in_sql  := INSTR(lower(sql_stmt),':party_site_id',1);  -- added by spamujul for ER#8473903
			   Else
			      v_party_in_sql	:= 0;
			      v_acct_in_sql		:= 0;
			       v_psite_in_sql	:= 0;  -- added by spamujul for ER#8473903
			   End if;
			   /***************/
		END IF;
		/* This begin, end exception is added mainly for exception handing for Bug 1980004*/
		Begin
		           IF ((sel_type='B' ) OR  (sel_type='T') ) Then -- Only valid types
					cid := dbms_sql.open_cursor;
					   if (sel_type = 'B') then
					   	dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
					   elsif (sel_type = 'T') then
				           	dbms_sql.parse(cid, rule, dbms_sql.native);
					   end if;
					   dbms_sql.define_column(cid,1,val,240);
					   -- pass the cid
					   OPEN cparty_csr;
							   LOOP
								      FETCH cparty_csr
								      INTO cparty_id;
								      EXIT WHEN cparty_csr%notfound;
									If v_check_level='PARTY' Then
										  Evaluate_One_Check(truncate_flag,
														     chk_id,
														     cparty_id,
														     null,
														     NULL,  -- added by spamujul for ER#8473903
														     v_check_level,
														     sel_type,
														     sel_blk_id,
														     data_type,
														     fmt_mask,
														     chk_u_l_flag,
														     Thd_grade,
														     rule,
														     blk_id,
														     sql_stmt,
														     curr_code,
														     l_up_total,
														     l_ip_total,
														     l_ua_total,
														     l_ia_total ,
														     l_us_total,  -- added by spamujul for ER#8473903
														     l_is_total,   -- added by spamujul for ER#8473903
														     cid);
									      End if;
										/* added this condition for Bug 1937730*/
									       v_party_id:=cparty_id;
										IF (sel_type = 'T') THEN
											acct_flag := 'Y';
											build_rule(acct_flag,chk_id,v_check_level, rule);
										END IF;
										IF ((sel_type='B' ) OR (sel_type='T') ) and v_check_level='ACCOUNT' Then -- Only valid Types now
											If ((v_acct_in_sql = 0) and sel_type = 'B') and v_check_level='ACCOUNT' Then -- added for 1850508
											      -- Check can be made only for 'B' types,
											      -- If acct is not present as bind variable, the sql might return wrong
											      -- rows (party level counts) at account leve.

											      --and (v_party_in_sql <> 0 and v_acct_in_sql <> 0)) OR
											      --(sel_type='T') ) Then
								                              NULL;
											Else
											      -- Loop through all parties with accounts
											      -- added for 1850508
											      --Open Cursor
											      -- dbms_output.put_line('Opening and PArsing in checks1 Accounts Check_id -'||to_char(chk_id));
											      OPEN caccount_csr;
											      LOOP
												   FETCH caccount_csr
												   INTO cparty_id, ccust_acct_id;
												   EXIT WHEN caccount_csr%notfound;
												   Evaluate_One_Check(truncate_flag,
																      chk_id,
																      cparty_id,
																      ccust_acct_id,
																      NULL,  -- added by spamujul for ER#8473903
																      v_check_level,
																      sel_type,
																      sel_blk_id,
																      data_type,
																      fmt_mask,
																      chk_u_l_flag,
																      Thd_grade,
																      rule,
																      blk_id,
																      sql_stmt,
																      curr_code,
																      l_up_total,
																      l_ip_total,
																      l_ua_total,
																      l_ia_total ,
																      l_us_total,  -- added by spamujul for ER#8473903
																      l_is_total,   -- added by spamujul for ER#8473903
																     cid);
											      END LOOP;
											      CLOSE caccount_csr;
										    End if; -- added for 1850508
										END IF;
										-- Begin fix by spamujul for ER#8473903
										 v_party_id:=cparty_id;
										 IF ((sel_type='B' ) OR (sel_type='T') ) AND v_check_level='SITE' THEN
											IF ((v_psite_in_sql = 0) AND sel_type = 'B') AND v_check_level='SITE' THEN
												NULL;
											ELSE
												cid := dbms_sql.open_cursor;
												IF (sel_type = 'B') THEN
													dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
												ELSIF (sel_type = 'T') THEN
													dbms_sql.parse(cid, rule, dbms_sql.native);
												END IF;
												 dbms_sql.define_column(cid,1,val,240);
												OPEN  cpsite_csr;
												LOOP
													FETCH  cpsite_csr
													INTO cparty_id,
														 cpsite_id;
													EXIT WHEN cpsite_csr%notfound;
													 Evaluate_One_Check(truncate_flag,
																			      chk_id,
																			       cparty_id,
																			       null,
																			       cpsite_id,
																			       v_check_level,
																			       sel_type,
																			       sel_blk_id,
																				data_type,
																				fmt_mask,
																				chk_u_l_flag,
																				Thd_grade,
																				rule,
																				blk_id,
																				sql_stmt,
																				curr_code,
																				l_up_total,
																				l_ip_total,
																				l_ua_total
																				, l_ia_total ,
																				l_us_total,
																				l_is_total,
																				cid);
												END LOOP;
											CLOSE cpsite_csr;
											IF (dbms_sql.is_open(cid)) THEN
												dbms_sql.close_cursor(cid);
											END IF;
										END IF;
									END IF;
							-- End fix by  spamujul for ER#8473903
								   END LOOP;
						   CLOSE cparty_csr;
						   IF (dbms_sql.is_open(cid)) THEN
						      dbms_sql.close_cursor(cid);
						   end if;
					END IF;
			 Exception
					 When others then
							  IF (dbms_sql.is_open(cid)) THEN
							      dbms_sql.close_cursor(cid);
							  end if;
							  set_context('Evaluate_Checks1_Rule',
								'chk_id=>'||to_char(chk_id),
								'party_id=>'||to_char(cparty_id),
								'account_id=>'||to_char(ccust_acct_id));
							  g_error := sqlcode || ' ' || sqlerrm;
							  set_context(NULL, g_error);
			End;
		 END LOOP;
	CLOSE checks_csr;
	   -- check if there are still records to be inserted
	   IF l_ip_total <> 0 THEN
		l_for_insert := 'Y';
		l_for_party  := 'Y';
		l_for_psite   := 'N'; -- added by spamujul for ER#8473903
		Insert_Update_Check_Results(l_ip_total,
								 l_for_insert,
								 l_for_party
								 ,l_for_psite -- added by spamujul for ER#8473903
								 );
		l_ip_total :=0;
	   END IF;
	   -- check if there are still records to be updated
	   IF l_up_total <> 0 THEN
		l_for_insert := 'N';
		l_for_party  := 'Y';
		l_for_psite   := 'N'; -- added by spamujul for ER#8473903
		Insert_Update_Check_Results (l_up_total,
								  l_for_insert,
								  l_for_party
								 ,l_for_psite -- added by spamujul for ER#8473903
								  );
		l_up_total :=0;
	   END IF;

   -- check if there are still records to be inserted
   IF l_ia_total <> 0 THEN
	l_for_insert := 'Y';
	l_for_party  := 'N';
	l_for_psite   := 'N'; -- added by spamujul for ER#8473903
	Insert_Update_Check_Results(l_ia_total,
							 l_for_insert,
							 l_for_party
							,l_for_psite -- added by spamujul for ER#8473903
							 );
	l_ia_total :=0;
   END IF;
   -- check if there are still records to be updated
   IF l_ua_total <> 0 THEN
	l_for_insert := 'N';
	l_for_party  := 'N';
	l_for_psite   := 'N'; -- added by spamujul for ER#8473903
	Insert_Update_Check_Results (l_ua_total,
							  l_for_insert,
							  l_for_party
							 ,l_for_psite -- added by spamujul for ER#8473903
							  );
	l_ua_total :=0;
   END IF;
 -- Begin fix by spamujul for  ER#8473903
	 IF l_is_total <> 0 THEN
	l_for_insert := 'Y';
	l_for_party  := 'N';
	l_for_psite   := 'N'; -- added by spamujul for ER#8473903
	Insert_Update_Check_Results(l_is_total,
							 l_for_insert,
							 l_for_party
							,l_for_psite -- added by spamujul for ER#8473903
							 );
	l_is_total :=0;
   END IF;
   -- check if there are still records to be updated
   IF l_us_total <> 0 THEN
	l_for_insert := 'N';
	l_for_party  := 'N';
	l_for_psite   := 'N'; -- added by spamujul for ER#8473903
	Insert_Update_Check_Results (l_us_total,
							  l_for_insert,
							  l_for_party
							 ,l_for_psite -- added by spamujul for ER#8473903
							  );
	l_us_total :=0;
   END IF;
 -- End fix by spamujul for  ER#8473903
/* End of R12 Employee HelpDesk Modifications */
   IF g_dashboard_for_contact = 'Y' THEN
       l_ip_total := 0;
       l_up_total := 0;
       l_ia_total := 0;
       l_ua_total := 0;
       l_us_total :=0; -- added by spamujul for ER#8473903
       l_is_total :=0; -- added by spamujul for ER#8473903

       Evaluate_blocks_Rel(p_up_total => l_up_total,
                           p_ip_total => l_ip_total,
                           p_ua_total => l_ua_total,
                           p_ia_total => l_ia_total,
			   p_us_total => l_us_total, -- added by spamujul for ER#8473903
			   p_is_total => l_is_total, -- added by spamujul for ER#8473903
                           p_rule_only => 'Y' );

       Evaluate_checks_Rel(errbuf => errbuf,
                           retcode => retcode,
                           p_rule_only => 'Y');
   END IF;

   COMMIT;

   -- Return 0 for successful completion, 1 for warnings, 2 for error
   IF (error_flag) THEN
      errbuf := Sqlerrm;
      retcode := 2;
   ELSIF (warning_msg <> '') THEN
      errbuf := warning_msg;
      retcode := 1;
   ELSE
      errbuf := '';
      retcode := 0;
   END IF;

  ELSIF g_dashboard_for_employee = 'Y' THEN
       l_ip_total := 0;
       l_up_total := 0;
       l_ia_total := 0;
       l_ua_total := 0;
       l_us_total :=0; -- added by spamujul for ER#8473903
       l_is_total :=0; -- added by spamujul for ER#8473903
       Evaluate_blocks_Emp(p_up_total => l_up_total,
                           p_ip_total => l_ip_total,
                           p_ua_total => l_ua_total,
                           p_ia_total => l_ia_total,
			   p_us_total => l_us_total, -- added by spamujul for ER#8473903
			   p_is_total => l_is_total, -- added by spamujul for ER#8473903
                           p_rule_only => 'Y' );

       Evaluate_checks_Emp(errbuf => errbuf,
                           retcode => retcode,
                           p_rule_only => 'Y');
   END IF;

   COMMIT;

   -- Return 0 for successful completion, 1 for warnings, 2 for error
   IF (error_flag) THEN
      errbuf := Sqlerrm;
      retcode := 2;
   ELSIF (warning_msg <> '') THEN
      errbuf := warning_msg;
      retcode := 1;
   ELSE
      errbuf := '';
      retcode := 0;
   END IF;

     IF (debug) THEN
      fnd_file.close;
   END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         IF (checks_csr%isopen) THEN
	    CLOSE checks_csr;
	 END IF;
	 IF (cparty_csr%isopen) THEN
	    CLOSE cparty_csr;
	 END IF;
	 IF (caccount_csr%isopen) THEN
	    CLOSE caccount_csr;
	 END IF;
	 -- Begin fix by spamujul for ER#8473903
	 IF (cpsite_csr%isopen) THEN
	    CLOSE cpsite_csr;
	 END IF;
	 -- End fix by spamujul for ER#8473903
	 IF (debug) THEN
	    fnd_file.close;
	 END IF;

         -- Retrieve error message into errbuf
         errbuf := Sqlerrm;

      	 -- Return 2 for error
         retcode := 2;

	 g_error := sqlcode || ' ' || sqlerrm;
	 fnd_file.put_line(fnd_file.log , g_error);

END Evaluate_Checks1_Rule;

/******************************************
   EVALUATE_CHECKS2_JIT
   added this procedure for JIT enhancement -- Bug 4535407
   Evaluate_Checks2_JIT is called by Evaluate_Checks2.
   Evaluate_Checks2 will open different cursors for JIT and non-JIT flows
   and calls this procedure for every record
******************************************/

PROCEDURE Evaluate_Checks2_JIT ( p_party_id		IN NUMBER,
							 p_acct_id				IN NUMBER,
							 p_psite_id				IN NUMBER DEFAULT NULL, -- Added by spamujul for ER#8473903
							 p_check_id				IN NUMBER,
							 p_select_type			IN VARCHAR2,
							 p_select_block_id		IN NUMBER,
							 p_data_type				IN VARCHAR2,
							 p_format_mask			IN VARCHAR2,
							 p_chk_upp_low_flag		IN VARCHAR2,
							 p_threshold_grade		IN VARCHAR2,
							 p_check_level			IN VARCHAR2,
							 p_group_id				IN NUMBER ) IS
			chk_id				NUMBER;
			chk_name			VARCHAR2(240);
			sel_type				VARCHAR2(3);
			sel_blk_id			NUMBER;
			data_type			VARCHAR2(90);
			fmt_mask			VARCHAR2(90);
			rule					VARCHAR2(32767);
			Chk_u_l_flag		VARCHAR2(3);
			Thd_grade			VARCHAR2(9);
			v_block_id			NUMBER;
			truncate_flag			VARCHAR2(1)		:= 'N';
			acct_flag			VARCHAR2(1);
			blk_id				NUMBER			:= NULL;
			blk_name			VARCHAR2(240)		:= NULL;
			sql_stmt			VARCHAR2(2000)	:= NULL;
			curr_code			VARCHAR2(15)		:= NULL;
			l_for_insert			VARCHAR2(1)		:= 'Y';
			l_for_party			VARCHAR2(1)		:= 'Y';
			l_for_psite			VARCHAR2(1)		:= 'N'; -- added by spamujul for ER#8473903
			l_up_total			NUMBER			:= 0;
			l_ip_total			NUMBER			:= 0;
			l_ua_total			NUMBER			:= 0;
			l_ia_total			NUMBER			:= 0;
			l_us_total			NUMBER			:= 0; -- added by spamujul for ER#8473903
			l_is_total			NUMBER			:= 0; -- added by spamujul for ER#8473903
			v_party_in_sql		NUMBER			:= 0;
			v_acct_in_sql		NUMBER			:= 0;
			v_psite_in_sql		NUMBER			:= 0; -- added by spamujul for ER#8473903
			v_check_level		VARCHAR2(10);
			v_rel_party			NUMBER ;
			v_incident_id		NUMBER			:=  p_psite_id;	-- added by spamujul for ER#8473903;
			v_incident_flag		VARCHAR2(2)		:=  'Y';			-- added by spamujul for ER#8473903

/* added these variable for Bug 1937730*/
		   v_party_id				Number;
		   cparty_id				Number;
		   ccust_acct_id			Number;
		   cpsite_id				Number; -- added by spamujul for ER#8473903
		   cid					Number;
		   val					Varchar2(240)		:= null;


  -- cursor to get the blocks related to the check
		   CURSOR cblocks_csr IS
			SELECT DISTINCT block_id
			FROM            csc_prof_check_rules_b
			WHERE           check_id = chk_id
			      UNION
			      (SELECT DISTINCT expr_to_block_id
			      FROM             csc_prof_check_rules_b
			      WHERE            check_id = chk_id
						 );
		   CURSOR block_csr IS
		      SELECT block_id,
				sql_stmnt,
				currency_code
			FROM csc_prof_blocks_b a
		       WHERE a.block_id = p_select_block_id;

/* added this condition party_id=v_party_id for Bug 1937730*/
		   CURSOR caccount_csr IS
		      SELECT party_id,
				  cust_account_id
			FROM hz_cust_accounts
		       WHERE party_id=v_party_id
			 AND status = 'A' ;
 -- Begin fix by spamujul for ER#8473903
		  CURSOR cpsite_csr IS
			 SELECT party_id,
					party_site_id
			  FROM   HZ_PARTY_SITES
			  WHERE party_id =  v_party_id
			      AND status ='A'
			      AND NVL(created_by_module,'XXX') <>'SR_ONETIME';
     -- End fix by spamujul for ER#8473903
BEGIN
	   l_ip_total   :=0;
	   l_up_total :=0;
	   l_ia_total  :=0;
	   l_ua_total :=0;
	   l_us_total :=0;  -- added by spamujul for ER#8473903
	   l_is_total  :=0;  -- added by spamujul for ER#8473903

	   chk_id		:= p_check_id;
	   sel_type	:= p_select_type;
	   sel_blk_id	:= p_select_block_id;
	   data_type	:= p_data_type;
	   fmt_mask	:= p_format_mask;
	   chk_u_l_flag := p_chk_upp_low_flag;
	   thd_grade	:= p_threshold_grade;
	   v_check_level := p_check_level;

	   IF sel_type = 'T' then
	      OPEN cblocks_csr;
			LOOP
			FETCH cblocks_csr into v_block_id;
			EXIT when cblocks_csr%notfound;
			 Evaluate_Blocks2(v_block_id,
						      p_party_id,
						      p_acct_id,
						      p_psite_id, -- added by spamujul for ER#8473903
						      l_up_total,
						      l_ip_total,
						      l_ua_total,
						      l_ia_total
						     ,l_us_total, -- added by spamujul for ER#8473903
						      l_is_total  -- added by spamujul for ER#8473903
						      );
		      END LOOP;
	      CLOSE cblocks_csr;
	   END IF;
	   l_ip_total :=0;
	   l_up_total :=0;
	   l_ia_total :=0;
	   l_ua_total :=0;
	   l_us_total :=0;  -- added by spamujul for ER#8473903
	   l_is_total  :=0;  -- added by spamujul for ER#8473903
	   IF (sel_type = 'T') THEN
	      IF p_acct_id IS NULL THEN
		 acct_flag := 'N';
		 build_rule(acct_flag,
				  chk_id,
				  v_check_level,
				  rule);
	      ELSE
		 acct_flag := 'Y';
		 build_rule(acct_flag,
				 chk_id,
				 v_check_level,
				 rule);
	      END IF;
	   ELSIF (sel_type = 'B') THEN
	      OPEN block_csr;
	      FETCH block_csr INTO blk_id, sql_stmt, curr_code;
	      CLOSE block_csr;
	      IF sql_stmt IS NOT NULL THEN
		 v_party_in_sql		:= INSTR(lower(sql_stmt),':party_id',1);
		 v_acct_in_sql		:= INSTR(lower(sql_stmt),':cust_account_id',1);
		 v_psite_in_sql		:= INSTR(lower(sql_stmt),':party_site_id',1); -- added by spamujul for ER#8473903
	      ELSE
		 v_party_in_sql		:= 0;
		 v_acct_in_sql		:= 0;
		 v_psite_in_sql		:= 0; -- added by spamujul for ER#8473903
	      END IF;
	   END IF;
	/* R12 Employee HelpDesk Modifications */
	   IF v_check_level in('PARTY','CONTACT','EMPLOYEE') THEN
	     -- p_cid is passed as null as Cursor has to be parsed always
		Evaluate_One_Check(truncate_flag,
						   chk_id,
						   p_party_id,
						   Null,
						   NULL,  -- added by spamujul for ER#8473903
						   v_check_level,
						   sel_type,
						   sel_blk_id,
						   data_type,
						   fmt_mask,
						   chk_u_l_flag,
						   Thd_grade,
						   rule,
						   blk_id,
						   sql_stmt,
						   curr_code,
						   l_up_total,
						   l_ip_total,
						   l_ua_total,
						   l_ia_total ,
						   l_us_total,  -- added by spamujul for ER#8473903
						   l_is_total,  -- added by spamujul for ER#8473903
						   NULL);
	   END IF;
	/* End of R12 Employee HelpDesk Modifications */
    /* This begin, end exception is added mainly for exception handing for Bug 1980004*/
    /* added this condition for Bug 1937730*/
	   BEGIN
	      v_party_id := p_party_id;
	      IF ((sel_type = 'B' ) OR (sel_type = 'T') ) and v_check_level = 'ACCOUNT' THEN -- Only valid Types now
		 IF ((v_acct_in_sql = 0) and sel_type = 'B') and v_check_level = 'ACCOUNT' THEN -- added for 1850508
		       -- Check can be made only for 'B' types,
		       -- If acct is not present as bind variable, the sql might returnwrong
		       -- rows (party level counts) at account leve.
			 --and (v_party_in_sql <> 0 and v_acct_in_sql <> 0)) OR
			 --(sel_type='T') ) Then
		     NULL;
		  ELSE
		     -- Loop through all parties with accounts
		     -- added for 1850508
		     --Open Cursor
		     -- dbms_output.put_line('Opening and PArsing in checks1 Accounts Check_id -'||to_char(chk_id));
		     cid := dbms_sql.open_cursor;
		     IF (sel_type = 'B') THEN
			dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
		     ELSIF (sel_type = 'T') THEN
			dbms_sql.parse(cid, rule, dbms_sql.native);
		     END IF;
		     dbms_sql.define_column(cid,1,val,240);

		     OPEN caccount_csr;
		     LOOP
			FETCH caccount_csr INTO cparty_id, ccust_acct_id;
			EXIT WHEN caccount_csr%notfound;

			Evaluate_One_Check(truncate_flag,
							   chk_id,
							   cparty_id,
							   ccust_acct_id,
							   NULL,  -- added by spamujul for ER#8473903
							   v_check_level,
							   sel_type,
							   sel_blk_id,
							   data_type,
							   fmt_mask,
							   chk_u_l_flag,
							   Thd_grade,
							   rule,
							   blk_id,
							   sql_stmt,
							   curr_code,
							    l_up_total,
							    l_ip_total,
							    l_ua_total,
							    l_ia_total
							    ,l_us_total,  -- added by spamujul for ER#8473903
							    l_is_total	 -- added by spamujul for ER#8473903
				    ,cid);
		     END LOOP;
		     CLOSE caccount_csr;

		     IF (dbms_sql.is_open(cid)) THEN
			dbms_sql.close_cursor(cid);
		     END IF;

		  END IF; -- added for 1850508
	       END IF;
	   EXCEPTION
	      WHEN OTHERS THEN
		 IF (dbms_sql.is_open(cid)) THEN
		    dbms_sql.close_cursor(cid);
		 END IF;

		  set_context('Evaluate_Checks2_JIT',
			'chk_id=>'||to_char(chk_id),
			'party_id=>'||to_char(cparty_id),
			'account_id=>'||to_char(ccust_acct_id));
		  g_error := sqlcode || ' ' || sqlerrm;
		  set_context(NULL, g_error);
	   END;
-- Begin  fix by spamujul for ER#8473903
            Begin
	  	 v_party_id:=p_party_id;
		   IF ((sel_type='B' ) OR (sel_type='T') ) AND v_check_level='SITE' THEN
			IF ((v_psite_in_sql = 0) AND sel_type = 'B') AND v_check_level='SITE' THEN
				NULL;
			ELSE
				cid := dbms_sql.open_cursor;
				IF (sel_type = 'B') THEN
					dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
				ELSIF (sel_type = 'T') THEN
					dbms_sql.parse(cid, rule, dbms_sql.native);
				END IF;
					 dbms_sql.define_column(cid,1,val,240);
				OPEN  cpsite_csr;
						LOOP
							FETCH  cpsite_csr
							INTO cparty_id,
								 cpsite_id;
							EXIT WHEN cpsite_csr%notfound;
							-- Added the Following Code to If refreshed the customer profile engine for Incident Address
							IF (v_incident_id IS NOT  NULL AND v_incident_id = cpsite_id)  AND  v_incident_flag <> 'N' THEN
								v_incident_flag := 'N';
							END IF;
							 Evaluate_One_Check(truncate_flag,
										       chk_id,
										       cparty_id,
										       NULL, -- For site level profile check, account parameter should be null
										       cpsite_id,
										       v_check_level,
										       sel_type,
										       sel_blk_id,
										       data_type,
											fmt_mask,
											chk_u_l_flag,
											Thd_grade,
											rule,
											blk_id,
											sql_stmt,
											curr_code,
											l_up_total,
											l_ip_total,
											l_ua_total,
											l_ia_total ,
											l_us_total,
											l_is_total,
											cid);
							END LOOP;
					CLOSE cpsite_csr;
					-- Added the following code to refresh the incident Address
					IF v_incident_id IS NOT  NULL AND  v_incident_flag ='Y' THEN
					    Evaluate_One_Check(truncate_flag,
										       chk_id,
										       p_party_id,
										       NULL, -- For site level profile check, account parameter should be null
										       p_psite_id,
										       v_check_level,
										       sel_type,
										       sel_blk_id,
										       data_type,
											fmt_mask,
											chk_u_l_flag,
											Thd_grade,
											rule,
											blk_id,
											sql_stmt,
											curr_code,
											l_up_total,
											l_ip_total,
											l_ua_total,
											l_ia_total ,
											l_us_total,
											l_is_total,
											cid);
						   v_incident_flag := 'N';
					END IF;
					-- Ended the incident address refresh operation
					IF (dbms_sql.is_open(cid)) THEN
						dbms_sql.close_cursor(cid);
					 end if;
			END IF;
		 END IF;
		 Exception
		When others then
			 IF (dbms_sql.is_open(cid)) THEN
				dbms_sql.close_cursor(cid);
			end if;
			set_context('Evaluate_Checks2_JIT',
			'chk_id=>'||to_char(chk_id),
			'party_id=>'||to_char(cparty_id),
			'account_id=>'|| NULL
			,'party_site_id =>'||to_char(cpsite_id)
			);
			g_error := sqlcode || ' ' || sqlerrm;
	  	        set_context(NULL, g_error);
	     End;
-- End  fix by spamujul for ER#8473903
    IF l_ip_total <> 0 THEN
      l_for_insert := 'Y';
      l_for_party  := 'Y';
       l_for_psite	 :='N'; -- added by spamujul for ER#8473903
      Insert_Update_Check_Results(l_ip_total,
						       l_for_insert,
						       l_for_party
						       ,l_for_psite  -- added by spamujul for ER#8473903
						       );
      l_ip_total :=0;
   END IF;
     -- check if there are still records to be updated
   IF l_up_total <> 0 THEN
      l_for_insert := 'N';
      l_for_party  := 'Y';
      l_for_psite	 :='N'; -- added by spamujul for ER#8473903
      Insert_Update_Check_Results (l_up_total,
							  l_for_insert,
							  l_for_party
							 ,l_for_psite -- added by spamujul for ER#8473903
							  );
      l_up_total :=0;
   END IF;

   -- check if there are still records to be inserted
   IF l_ia_total <> 0 THEN
      l_for_insert := 'Y';
      l_for_party  := 'N';
      l_for_psite	 :='N'; -- added by spamujul for ER#8473903
      Insert_Update_Check_Results(l_ia_total,
							  l_for_insert,
							  l_for_party
							 ,l_for_psite -- added by spamujul for ER#8473903
							  );
      l_ia_total :=0;
   END IF;
   -- check if there are still records to be updated
   IF l_ua_total <> 0 THEN
      l_for_insert := 'N';
      l_for_party  := 'N';
      l_for_psite	 :='N'; -- added by spamujul for ER#8473903
      Insert_Update_Check_Results(l_ua_total,
							 l_for_insert,
							 l_for_party
							,l_for_psite -- added by spamujul for ER#8473903
							 );
      l_ua_total :=0;
   END IF;
    -- Begin fix by spamujul for ER#8473903
	IF l_is_total <> 0 THEN
		 l_for_insert := 'Y';
		 l_for_party  := 'N';
		 l_for_psite   := 'Y';-- added by spamujul for ER#8473903
		 Insert_Update_Check_Results(l_is_total,
								  l_for_insert,
								  l_for_party
								 ,l_for_psite -- added by spamujul for ER#8473903
								  );
		 l_is_total :=0;
   END IF;
	   IF l_us_total <> 0 THEN
	     l_for_insert := 'N';
	     l_for_party  := 'N';
	     l_for_psite   := 'Y';-- added by spamujul for ER#8473903
	     Insert_Update_Check_Results(l_us_total,
								 l_for_insert,
								 l_for_party
								,l_for_psite -- added by spamujul for ER#8473903
								 );
	     l_us_total :=0;
	  END IF;
    -- End fix by spamujul for ER#8473903

  COMMIT;
END Evaluate_Checks2_JIT;

--
-- Evaluate_Checks2
--   Loop through all checks and evaluate the results
--   for the Given Party
--   if Party and Group are Provided
--   Only the checks and blocks for a given group_id
--   This is used when the refresh button is pressed or from JIT process
--

PROCEDURE Evaluate_Checks2
		  ( p_party_id			IN	NUMBER,
		    p_acct_id			IN	NUMBER,
		    p_psite_id			IN	 NUMBER DEFAULT NULL, -- added by spamujul for ER#8473903
		    p_group_id		IN	NUMBER,
		    p_critical_flag		IN      VARCHAR2 DEFAULT 'N', /* added for JIT enhancement */
		    errbuf				OUT	NOCOPY VARCHAR2,
		    retcode			OUT	NOCOPY NUMBER ) IS

	   CURSOR checks_csr IS
	      SELECT check_id,
				select_type,
				select_block_id,
				data_type,
				format_mask,
				check_upper_lower_flag,
				threshold_grade, check_level
		FROM csc_prof_checks_b chk
	       WHERE check_level IN ('PARTY',
							    'ACCOUNT',
							    'SITE' --Added  'SITE' by spamujul for ER#8473903
							    )
		 AND (Sysdate BETWEEN Nvl(start_date_active, Sysdate)
		      AND nvl(end_date_active, Sysdate))
		 AND EXISTS ( SELECT a.check_id
				FROM csc_prof_group_checks a
			       WHERE a.group_id   = p_group_id
				 AND chk.check_id = a.check_id);

		   /* added cursor checks_crit_csr for JIT enhancement -- Bug 4535407 */
		   CURSOR checks_crit_csr IS
		      SELECT check_id,
					select_type,
					select_block_id,
					data_type,
					format_mask,
					check_upper_lower_flag,
					threshold_grade,
					check_level
			FROM csc_prof_checks_b chk
		       WHERE check_level IN ('PARTY',
								    'ACCOUNT',
								    'SITE'   --  Added 'SITE' by spamujul for ER#8473903
 								    )
			 AND (Sysdate BETWEEN Nvl(start_date_active, Sysdate)
			      AND nvl(end_date_active, Sysdate))
			 AND EXISTS ( SELECT a.check_id
					FROM csc_prof_group_checks a
				       WHERE a.group_id   = p_group_id
					 AND chk.check_id = a.check_id
					 AND a.critical_flag = 'Y');

		   CURSOR rel_party_csr(c_party_id IN NUMBER) IS
		     SELECT 1
		       FROM hz_parties
		      WHERE party_id = c_party_id
			AND party_type = 'PARTY_RELATIONSHIP'
			AND status = 'A';

		   CURSOR employee_csr(c_party_id IN NUMBER) IS
		     SELECT 1
		       FROM per_workforce_current_x
		      WHERE person_id = c_party_id;


		   CURSOR rel_checks_csr IS
		      SELECT check_id,
					select_type,
					select_block_id,
					data_type,
					format_mask,
					check_upper_lower_flag,
					threshold_grade,
					check_level
			FROM csc_prof_checks_b chk
		       WHERE check_level  IN ( 'CONTACT',
									'SITE'  --Added 'SITE'  by spamujul for ER#8473903
									)
			 AND (Sysdate BETWEEN Nvl(start_date_active, Sysdate)
			      AND nvl(end_date_active, Sysdate))
			 AND EXISTS ( SELECT a.check_id
					FROM csc_prof_group_checks a
				       WHERE a.group_id   = p_group_id
					 AND chk.check_id = a.check_id);

   /* added cursor checks_csr_jit for JIT enhancement -- Bug 4535407 */
		   CURSOR rel_checks_crit_csr IS
		      SELECT check_id,
					select_type,
					select_block_id,
					data_type,
					format_mask,
					check_upper_lower_flag,
					threshold_grade,
					check_level
			FROM csc_prof_checks_b chk
		       WHERE check_level  IN ( 'CONTACT',
									'SITE' --Added 'SITE'  by spamujul for ER#8473903
									)
			 AND (Sysdate BETWEEN Nvl(start_date_active, Sysdate)
			      AND nvl(end_date_active, Sysdate))
			 AND EXISTS ( SELECT a.check_id
					FROM csc_prof_group_checks a
				       WHERE a.group_id   = p_group_id
					 AND chk.check_id = a.check_id
					 AND a.critical_flag = 'Y');

		/* R12 Employee HelpDesk Modifications */
		CURSOR emp_checks_csr IS
		      SELECT check_id,
					select_type,
					select_block_id,
					data_type,
					format_mask,
					check_upper_lower_flag,
					threshold_grade,
					check_level
			FROM csc_prof_checks_b chk
		       WHERE check_level = 'EMPLOYEE'
			 AND (Sysdate BETWEEN Nvl(start_date_active, Sysdate)
			      AND nvl(end_date_active, Sysdate))
			 AND EXISTS ( SELECT a.check_id
					FROM csc_prof_group_checks a
				       WHERE a.group_id   = p_group_id
					 AND chk.check_id = a.check_id);

		CURSOR emp_checks_crit_csr IS
		      SELECT check_id,
					select_type,
					select_block_id,
					data_type,
					format_mask,
					check_upper_lower_flag,
					threshold_grade,
					check_level
			FROM csc_prof_checks_b chk
		       WHERE check_level = 'EMPLOYEE'
			 AND (Sysdate BETWEEN Nvl(start_date_active, Sysdate)
			      AND nvl(end_date_active, Sysdate))
			 AND EXISTS ( SELECT a.check_id
					FROM csc_prof_group_checks a
				       WHERE a.group_id   = p_group_id
					 AND chk.check_id = a.check_id
					 AND a.critical_flag = 'Y');

			/* End of R12 Employee HelpDesk Modifications */

			   l_rel_refresh VARCHAR2(1) := 'N';
			   v_rel_party   NUMBER;

			   l_emp_refresh VARCHAR2(1) := 'N';
			   v_emp_party   NUMBER;



BEGIN
	/* Moved the code to Evaluate_Checks2_JIT for JIT enhancement. -- Bug 4535407
	   Logic
	   -----
	   IF jit_flag = 'Y' THEN
	      OPEN checks_crit_csr;
	      CALL Evaluate_Checks2_JIT;
	   ELSE
	      OPEN checks_csr;
	      CALL Evaluate_Checks2_JIT;
	   END IF;

	*/
	/* Bug 5168090 Fix - scenario where employee_id and party_id from hz_parties have the same value */
	  IF g_dashboard_for_employee = 'Y' THEN
		  l_emp_refresh      := 'Y';
	  ELSE
		  OPEN rel_party_csr(p_party_id);
		  FETCH rel_party_csr
		  INTO  v_rel_party;
		  IF rel_party_csr%FOUND THEN
			  l_rel_refresh := 'Y';
		  END IF;
		  CLOSE rel_party_csr;
	  END IF;
 /* Bug 5168090 Fix */
		   IF l_rel_refresh           = 'Y' THEN
			IF p_critical_flag = 'Y' THEN
				FOR i     IN rel_checks_crit_csr
					LOOP
						   Evaluate_Checks2_JIT
						      ( p_party_id			=> p_party_id,
							p_acct_id			=> p_acct_id,
							p_psite_id			=> p_psite_id,	 --added by spamujul for ER#8473903
							p_check_id			=> i.check_id,
							p_select_type		=> i.select_type,
							p_select_block_id	=> i.select_block_id,
							p_data_type			=> i.data_type,
							p_format_mask		=> i.format_mask,
							p_chk_upp_low_flag => i.check_upper_lower_flag,
							p_threshold_grade	=> i.threshold_grade,
							p_check_level		=> i.check_level,
							p_group_id			=> p_group_id
						       );
					END LOOP;
			ELSE
				FOR i IN rel_checks_csr
					LOOP
						   Evaluate_Checks2_JIT
						      ( p_party_id			=> p_party_id,
							p_acct_id			=> p_acct_id,
							p_psite_id			=> p_psite_id,	--added by spamujul for ER#8473903
							p_check_id			=> i.check_id,
							p_select_type		=> i.select_type,
							p_select_block_id	=> i.select_block_id,
							p_data_type			=> i.data_type,
							p_format_mask		=> i.format_mask,
							p_chk_upp_low_flag => i.check_upper_lower_flag,
							p_threshold_grade	=> i.threshold_grade,
							p_check_level		=> i.check_level,
							p_group_id			=> p_group_id
						       );
				  END LOOP;
			END IF;
		ELSIF l_emp_refresh = 'Y' THEN
			/* R12 Employee HelpDesk Modifications */
			IF p_critical_flag = 'Y' THEN
				FOR i     IN emp_checks_crit_csr
					LOOP
						   Evaluate_Checks2_JIT
						      ( p_party_id			=> p_party_id,
							p_acct_id			=> p_acct_id,
							p_psite_id			=> p_psite_id,	 --added by spamujul for ER#8473903
							p_check_id			=> i.check_id,
							p_select_type		 => i.select_type,
							p_select_block_id	=> i.select_block_id,
							p_data_type			=> i.data_type,
							p_format_mask		=> i.format_mask,
							p_chk_upp_low_flag => i.check_upper_lower_flag,
							p_threshold_grade	 => i.threshold_grade,
							p_check_level		=> i.check_level,
							p_group_id			=> p_group_id
						       );
				  END LOOP;
			ELSE
				FOR i IN emp_checks_csr
					LOOP
						   Evaluate_Checks2_JIT
						      ( p_party_id			=> p_party_id,
							p_acct_id			=> p_acct_id,
							p_psite_id			=> p_psite_id,	--added by spamujul for ER#8473903
							p_check_id			=> i.check_id,
							p_select_type		=> i.select_type,
							p_select_block_id	=> i.select_block_id,
							p_data_type			=> i.data_type,
							p_format_mask		=> i.format_mask,
							p_chk_upp_low_flag	 => i.check_upper_lower_flag,
							p_threshold_grade	=> i.threshold_grade,
							p_check_level		=> i.check_level,
							p_group_id			=> p_group_id
						       );
				 END LOOP;
			END IF;
			/* End of R12 Employee HelpDesk Modifications */
		ELSE
			IF p_critical_flag = 'Y' THEN
				FOR i     IN checks_crit_csr
					LOOP
						   Evaluate_Checks2_JIT
						      ( p_party_id			=> p_party_id,
							p_acct_id			=> p_acct_id,
							p_psite_id			=> p_psite_id,	--added by spamujul for ER#8473903
							p_check_id			=> i.check_id,
							p_select_type		=> i.select_type,
							p_select_block_id	=> i.select_block_id,
							p_data_type			=> i.data_type,
							p_format_mask		=> i.format_mask,
							p_chk_upp_low_flag	=> i.check_upper_lower_flag,
							p_threshold_grade	 => i.threshold_grade,
							p_check_level		=> i.check_level,
							p_group_id			=> p_group_id
						       );
				     END LOOP;
			ELSE
				FOR i IN checks_csr
					LOOP
						   Evaluate_Checks2_JIT
						      ( p_party_id			=> p_party_id,
							p_acct_id			=> p_acct_id,
							p_psite_id			=> p_psite_id,	--added by spamujul for ER#8473903
							p_check_id			=> i.check_id,
							p_select_type		=> i.select_type,
							p_select_block_id	 => i.select_block_id,
							p_data_type			=> i.data_type,
							p_format_mask		=> i.format_mask,
							p_chk_upp_low_flag	=> i.check_upper_lower_flag,
							p_threshold_grade	 => i.threshold_grade,
							p_check_level		=> i.check_level,
							p_group_id			=> p_group_id
						       );
				     END LOOP;
			END IF;
		END IF;
		   -- Return 0 for successful completion, 1 for warnings, 2 for error
		   IF (error_flag) THEN
		      errbuf := Sqlerrm;
		      retcode := 2;
		   ELSIF (warning_msg <> '') THEN
		      errbuf := warning_msg;
		      retcode := 1;
		   ELSE
		      errbuf := '';
		      retcode := 0;
		   END IF;

		   IF (debug) THEN
		      fnd_file.close;
		   END IF;
EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			 IF (checks_csr%isopen) THEN
				CLOSE checks_csr;
		        END IF;
			IF (debug) THEN
				fnd_file.close;
		        END IF;
			-- Retrieve error message into errbuf
			errbuf := Sqlerrm;
		   -- Return 2 for error
		      retcode := 2;
			g_error := sqlcode || ' ' || sqlerrm;
			fnd_file.put_line(fnd_file.log , g_error);
END Evaluate_Checks2;
  --
  -- Evaluate_Checks3
  --   Loop through all checks and evaluate the results
  --   for each customer and account.
  --   if check_id is null, party_id is not null or account_id is not null
  --         and block_id is null
  --   get only the checks and blocks for a given group_id
  --   This is used when the refresh button is pressed
  --
  PROCEDURE Evaluate_Checks3( p_party_id		IN   NUMBER,
								  p_acct_id		IN   NUMBER,
								  p_psite_id		IN   NUMBER DEFAULT NULL, -- added by spamujul for ER#8473903
								  p_group_id		IN   NUMBER,
								  errbuf			OUT NOCOPY VARCHAR2,
								  retcode			OUT NOCOPY NUMBER
								  ) IS

				chk_id				Number;
				chk_name			Varchar2(240);
				sel_type				Varchar2(3);
				sel_blk_id			Number;
				data_type			Varchar2(90);
				fmt_mask			Varchar2(90);
				rule					Varchar2(32767);
				Chk_u_l_flag		Varchar2(3);
				Thd_grade			Varchar2(9);
				v_block_id			Number;
				truncate_flag			Varchar2(1)		:= 'N';
				acct_flag			Varchar2(1);
				blk_id				Number			:= null;
				blk_name			Varchar2(240)	:= null;
				sql_stmt			Varchar2(2000)	:= null;
				curr_code			Varchar2(15)		:= null;
				l_for_insert			varchar2(1)		:= 'Y';
				l_for_party			varchar2(1)		:= 'Y';
				l_for_psite			Varchar2(1)		:= 'N'; -- added by spamujul for ER#8473903
				l_up_total			Number			:= 0;
				l_ip_total			Number			:= 0;
				l_ua_total			NUmber			:= 0;
				l_ia_total			Number			:= 0;
				l_us_total			Number			:= 0; -- added by spamujul for ER#8473903
				l_is_total			Number			:= 0; -- added by spamujul for ER#8473903
				v_party_in_sql		Number			:= 0;
				v_acct_in_sql		Number			:=  0;
				v_psite_in_sql		Number			:= 0; -- added by spamujul for ER#8473903
				v_check_level		Varchar2(10);
				 v_rel_refresh		Varchar2(1)		 := 'N';

				/* added these variable for Bug 1937730*/
				v_party_id			Number;
				cparty_id			Number;
				ccust_acct_id		Number;
				cpsite_id			Number; -- added by spamujul for ER#8473903
				cid					Number;
				val					Varchar2(240) := null;

				-- cursor to retrieve all checks that belong to that group
				CURSOR checks_csr IS
				  SELECT check_id,
					      select_type,
					      select_block_id,
					      data_type,
					      format_mask,
					      check_upper_lower_flag,
					      threshold_grade,
					     check_level
				  FROM csc_prof_checks_b chk
				  WHERE check_level IN ('PARTY',
									       'ACCOUNT',  -- Added 'SITE' by spamujul for ER#8473903
									       'SITE'
									       )
				  AND (Sysdate BETWEEN Nvl(start_date_active, Sysdate)
							  AND nvl(end_date_active, Sysdate))
				  AND Exists ( SELECT a.check_id
						FROM csc_prof_group_checks a
						WHERE chk.check_id = a.check_id
						AND sysdate between
					       nvl(a.start_date_active,sysdate)
					       AND nvl(a.end_date_active,sysdate));
					/* R12 Employee HelpDesk Modifications */
						CURSOR  checks_emp_csr IS
						  SELECT check_id,
								select_type,
								select_block_id,
								data_type,
								format_mask,
								check_upper_lower_flag,
								threshold_grade,
							check_level
						  FROM csc_prof_checks_b chk
						  WHERE check_level IN ('EMPLOYEE')
						  AND (Sysdate BETWEEN Nvl(start_date_active, Sysdate)
									  AND nvl(end_date_active, Sysdate))
						  AND Exists ( SELECT a.check_id
								FROM csc_prof_group_checks a
								WHERE chk.check_id = a.check_id
								AND sysdate between
							       nvl(a.start_date_active,sysdate)
							       AND nvl(a.end_date_active,sysdate));
					/* End of R12 Employee HelpDesk Modifications */

				-- cursor to get the blocks related to the check
				 CURSOR cblocks_csr IS
					  Select distinct block_id
					  From csc_prof_check_rules_b
					  Where check_id = chk_id
					  UNION
					  (Select distinct expr_to_block_id
					  From csc_prof_check_rules_b
					  Where check_id = chk_id);

					CURSOR block_csr IS
					  SELECT block_id,
							sql_stmnt,
							currency_code
					  FROM csc_prof_blocks_b a
					  WHERE a.block_id = sel_blk_id;

			       /* added this condition party_id=v_party_id for Bug 1937730*/
				CURSOR caccount_csr IS
				  SELECT party_id, cust_account_id
				  FROM hz_cust_accounts
				  WHERE  party_id=v_party_id
				  AND  status = 'A' ;
			     -- Begin fix by spamujul for ER#8473903
				CURSOR cpsite_csr IS
				 SELECT party_id,party_site_id
				  FROM   HZ_PARTY_SITES
				  WHERE party_id = p_party_id
				      AND NVL(created_by_module,'XXX') <>'SR_ONETIME';
			     -- End fix by spamujul for ER#8473903

			    CURSOR checks_relparty_csr IS
			     SELECT check_id,
					  select_type,
					  select_block_id,
					  data_type,
					  format_mask,
					  check_upper_lower_flag,
					  threshold_grade,
					  check_level
			     FROM csc_prof_checks_b chk
			     WHERE check_level  IN ( 'CONTACT',
									    'SITE' -- Added'SITE' by spamujul for ER#8473903
									    )
			       AND (Sysdate BETWEEN Nvl(start_date_active, Sysdate)
					AND nvl(end_date_active, Sysdate))
			     AND Exists ( SELECT a.check_id
						FROM csc_prof_group_checks a
						WHERE chk.check_id = a.check_id
						AND sysdate between nvl(a.start_date_active,sysdate)
						AND nvl(a.end_date_active,sysdate));

			  CURSOR crelparty_csr(c_party_id IN NUMBER) IS
			     SELECT party_id FROM hz_parties
			     WHERE party_id = c_party_id
			      AND party_type = 'PARTY_RELATIONSHIP'
			      AND status = 'A';

BEGIN
	  l_ip_total	 :=0;
	  l_up_total	 :=0;
	  l_ia_total	 :=0;
	  l_ua_total	 :=0;
	  l_us_total	 := 0;  -- added by spamujul for ER#8473903
	  l_is_total	 := 0;  -- added by spamujul for ER#8473903
   -- Loop through check_id and update block results for a party or account
	OPEN checks_csr;
		LOOP
			FETCH checks_csr
			  INTO chk_id,
				   sel_type,
				   sel_blk_id,
				   data_type,
				   fmt_mask,
				   chk_u_l_flag,
				   Thd_grade,
				   v_check_level;
			  EXIT WHEN checks_csr%notfound;
			  IF sel_type = 'T' then
				OPEN cblocks_csr;
				LOOP
					FETCH cblocks_csr into v_block_id;
					Exit when cblocks_csr%notfound;
					Evaluate_Blocks2(v_block_id,
						p_party_id,
						p_acct_id,
						p_psite_id, -- added by spamujul for ER#8473903
						l_up_total,
						l_ip_total,
						l_ua_total,
						l_ia_total
					       ,l_us_total, -- added by spamujul for ER#8473903
						l_is_total  -- added by spamujul for ER#8473903
						);

				 END LOOP;
				CLOSE cblocks_csr;
			END IF;
		END LOOP;
	CLOSE checks_csr;
	  l_ip_total := 0;
	  l_up_total :=0;
	  l_ia_total := 0;
	  l_ua_total :=0;
	  l_us_total := 0;  -- added by spamujul for ER#8473903
	  l_is_total  := 0;  -- added by spamujul for ER#8473903

-- Loop through check_id and update check results for a party or account
	  OPEN checks_csr;
		LOOP
			FETCH checks_csr
			INTO chk_id,
				 sel_type,
				 sel_blk_id,
				 data_type,
				 fmt_mask,
				 chk_u_l_flag,
				 Thd_grade,
				 v_check_level;
			EXIT WHEN checks_csr%notfound;
		  --  IF (chk_id NOT BETWEEN 21 AND 24) THEN
		  IF (sel_type = 'T') THEN
		     IF p_acct_id IS NULL THEN
			   acct_flag := 'N';
			   build_rule(acct_flag,chk_id,v_check_level, rule);
		     ELSE
			   acct_flag := 'Y';
			   build_rule(acct_flag,chk_id,v_check_level, rule);
		     END IF;

		  ELSIF (sel_type = 'B') THEN
			Open block_csr;
			Fetch block_csr
			INTO blk_id,
				sql_stmt,
				curr_code;
			Close block_csr;

			/* Uncommented this condition for Bug 1937730*/
			 /******************/
			 IF sql_stmt IS NOT NULL Then
				v_party_in_sql := INSTR(lower(sql_stmt),':party_id',1);
				v_acct_in_sql  :=  INSTR(lower(sql_stmt),':cust_account_id',1);
				v_psite_in_sql :=  INSTR(lower(sql_stmt),':party_site_id',1); -- Added by spamujul for ER#8473903
			 Else
				v_party_in_sql := 0;
				v_acct_in_sql  :=  0;
				v_psite_in_sql :=  0;   -- Added by spamujul for ER#8473903
			 End if;
			/******************/

		   END IF;

	       If v_check_level='PARTY' then
		  -- p_cid is passed as null as Cursor has to be parsed always
			  Evaluate_One_Check(truncate_flag,
							     chk_id,
							     p_party_id,
							     null,
							     NULL,  -- added by spamujul for ER#8473903
							     v_check_level,
							     sel_type,
							     sel_blk_id,
							     data_type,
							     fmt_mask,
							     chk_u_l_flag,
							     Thd_grade,
							     rule,
							     blk_id,
							     sql_stmt,
							     curr_code,
							     l_up_total,
							     l_ip_total,
							     l_ua_total,
							     l_ia_total ,
							     l_us_total,  -- added by spamujul for ER#8473903
							     l_is_total ,  -- added by spamujul for ER#8473903
							     NULL );
	       End if;
   --END IF;

/* This begin, end exception is added mainly for exception handing for Bug 19800
04*/

	Begin
		 /* added this condition for Bug 1937730*/
		  v_party_id:=p_party_id;
			IF ((sel_type='B' ) OR (sel_type='T') ) and v_check_level='ACCOUNT' Then -- Only valid Types now
				If ((v_acct_in_sql = 0) and sel_type = 'B') and v_check_level='ACCOUNT' Then -- added for 1850508
				-- Check can be made only for 'B' types,
				-- If acct is not present as bind variable, the sql might returnwrong
				-- rows (party level counts) at account leve.

				 --and (v_party_in_sql <> 0 and v_acct_in_sql <> 0)) OR
				   --(sel_type='T') ) Then
					NULL;
				Else
					 -- Loop through all parties with accounts
					 -- added for 1850508
					 --Open Cursor
					 -- dbms_output.put_line('Opening and PArsing in checks1 Accounts Check_id -'||to_char(chk_id));
					cid := dbms_sql.open_cursor;
					 if (sel_type = 'B') then
						dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
					 elsif (sel_type = 'T') then
						dbms_sql.parse(cid, rule, dbms_sql.native);
					 end if;
					 dbms_sql.define_column(cid,1,val,240);

					OPEN caccount_csr;
						LOOP
							FETCH caccount_csr
							INTO cparty_id,
								 ccust_acct_id;
							EXIT WHEN caccount_csr%notfound;
							 Evaluate_One_Check(truncate_flag,
										       chk_id,
										       cparty_id,
										       ccust_acct_id,
										       NULL,  -- added by spamujul for ER#8473903
										       v_check_level,
										       sel_type,
										       sel_blk_id,
										       data_type,
											fmt_mask,
											chk_u_l_flag,
											Thd_grade,
											rule,
											blk_id,
											sql_stmt,
											curr_code,
											l_up_total,
											l_ip_total,
											l_ua_total,
											l_ia_total ,
											l_us_total,  -- added by spamujul for ER#8473903
											l_is_total,  -- added by spamujul for ER#8473903
											cid);
							END LOOP;
					CLOSE caccount_csr;
					IF (dbms_sql.is_open(cid)) THEN
						dbms_sql.close_cursor(cid);
					 end if;
				End if; -- added for 1850508
		     END IF;
	   Exception
		When others then
			 IF (dbms_sql.is_open(cid)) THEN
				dbms_sql.close_cursor(cid);
			end if;
			set_context('Evaluate_Checks3',
			'chk_id=>'||to_char(chk_id),
			'party_id=>'||to_char(cparty_id),
			'account_id=>'||to_char(ccust_acct_id)
			,'party_site_id =>'|| NULL -- added by spamujul for ER#8473903
			);
			g_error := sqlcode || ' ' || sqlerrm;
			set_context(NULL, g_error);
	    End;
-- Begin  fix by spamujul for ER#8473903
            Begin
		 v_party_id:=p_party_id;
		 IF ((sel_type='B' ) OR (sel_type='T') ) AND v_check_level='SITE' THEN
			IF ((v_psite_in_sql = 0) AND sel_type = 'B') AND v_check_level='SITE' THEN
				NULL;
			ELSE
				cid := dbms_sql.open_cursor;
				IF (sel_type = 'B') THEN
					dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
				ELSIF (sel_type = 'T') THEN
					dbms_sql.parse(cid, rule, dbms_sql.native);
				END IF;
					 dbms_sql.define_column(cid,1,val,240);
				OPEN  cpsite_csr;
						LOOP
							FETCH  cpsite_csr
							INTO cparty_id,
								 cpsite_id;
							EXIT WHEN cpsite_csr%notfound;
							 Evaluate_One_Check(truncate_flag,
										       chk_id,
										       cparty_id,
										       NULL, -- For site level profile check, account parameter should be null
										       cpsite_id,
										       v_check_level,
										       sel_type,
										       sel_blk_id,
										       data_type,
											fmt_mask,
											chk_u_l_flag,
											Thd_grade,
											rule,
											blk_id,
											sql_stmt,
											curr_code,
											l_up_total,
											l_ip_total,
											l_ua_total,
											l_ia_total ,
											l_us_total,
											l_is_total,
											cid);
							END LOOP;
					CLOSE cpsite_csr;
					IF (dbms_sql.is_open(cid)) THEN
						dbms_sql.close_cursor(cid);
					 end if;
			END IF;
		 END IF;
		 Exception
		When others then
			 IF (dbms_sql.is_open(cid)) THEN
				dbms_sql.close_cursor(cid);
			end if;
			set_context('Evaluate_Checks3',
			'chk_id=>'||to_char(chk_id),
			'party_id=>'||to_char(cparty_id),
			'account_id=>'|| NULL
			,'party_site_id =>'||to_char(cpsite_id)
			);
			g_error := sqlcode || ' ' || sqlerrm;
	  	        set_context(NULL, g_error);
	     End;
-- End  fix by spamujul for ER#8473903
    END LOOP;
   CLOSE checks_csr;



/*Commented this if condition for Bug 1937730*/
--   IF p_acct_id IS NULL THEN
    -- check if there are still records to be inserted
    IF l_ip_total <> 0 THEN
	  l_for_insert := 'Y';
          l_for_party  := 'Y';
	  l_for_psite   := 'N';-- added by spamujul for ER#8473903
	  Insert_Update_Check_Results(l_ip_total,
						       l_for_insert,
						       l_for_party
						       ,l_for_psite  -- added by spamujul for ER#8473903
						       );
          l_ip_total :=0;
    END IF;
    -- check if there are still records to be updated
    IF l_up_total <> 0 THEN
	  l_for_insert := 'N';
	  l_for_party  := 'Y';
	  l_for_psite   := 'N';-- added by spamujul for ER#8473903
	 Insert_Update_Check_Results (l_up_total,
							  l_for_insert,
							  l_for_party
							 ,l_for_psite -- added by spamujul for ER#8473903
							  );
	  l_up_total :=0;
    END IF;

 -- ELSE
   -- check if there are still records to be inserted
   IF l_ia_total <> 0 THEN
	 l_for_insert := 'Y';
         l_for_party  := 'N';
	 l_for_psite   := 'N';-- added by spamujul for ER#8473903
         Insert_Update_Check_Results(l_ia_total,
							  l_for_insert,
							  l_for_party
							 ,l_for_psite -- added by spamujul for ER#8473903
							  );
	 l_ia_total :=0;
   END IF;

-- check if there are still records to be updated
  IF l_ua_total <> 0 THEN
     l_for_insert := 'N';
     l_for_party  := 'N';
     l_for_psite   := 'N';-- added by spamujul for ER#8473903
     Insert_Update_Check_Results(l_ua_total,
							 l_for_insert,
							 l_for_party
							,l_for_psite -- added by spamujul for ER#8473903
							 );
     l_ua_total :=0;
  END IF;
  -- Begin fix by spamujul for ER#8473903
	IF l_is_total <> 0 THEN
		 l_for_insert := 'Y';
		 l_for_party  := 'N';
		 l_for_psite   := 'Y';-- added by spamujul for ER#8473903
		 Insert_Update_Check_Results(l_is_total,
								  l_for_insert,
								  l_for_party
								 ,l_for_psite -- added by spamujul for ER#8473903
								  );
		 l_is_total :=0;
   END IF;
	   IF l_us_total <> 0 THEN
	     l_for_insert := 'N';
	     l_for_party  := 'N';
	     l_for_psite   := 'Y';-- added by spamujul for ER#8473903
	     Insert_Update_Check_Results(l_us_total,
								 l_for_insert,
								 l_for_party
								,l_for_psite -- added by spamujul for ER#8473903
								 );
	     l_us_total :=0;
	  END IF;
    -- End fix by spamujul for ER#8473903
  --New changes
  IF g_dashboard_for_contact IS NULL THEN
      FND_PROFILE.GET('CSC_DASHBOARD_VIEW_FOR_CONTACT',g_dashboard_for_contact);
  END IF;
  IF g_dashboard_for_contact = 'Y' THEN
	   l_ip_total :=0;
	   l_up_total :=0;
	   l_ia_total :=0;
	   l_ua_total :=0;
	   l_us_total := 0;  -- added by spamujul for ER#8473903
	   l_is_total := 0;   -- added by spamujul for ER#8473903
	   -- Loop through check_id and update block results for a party or account
		OPEN checks_relparty_csr;
			LOOP
				FETCH checks_relparty_csr
				  INTO chk_id,
						sel_type,
						sel_blk_id,
						data_type,
						fmt_mask,
						chk_u_l_flag,
						Thd_grade,
						v_check_level;
		  EXIT WHEN checks_relparty_csr%notfound;
		IF sel_type = 'T' then
			OPEN cblocks_csr;
				  LOOP
				     FETCH cblocks_csr into v_block_id;
				     Exit when cblocks_csr%notfound;
				     Evaluate_Blocks5(v_block_id,
								 p_party_id,
								 p_psite_id,	  -- added by spamujul for ER#8473903
								 l_up_total,
								 l_ip_total,
								 l_ua_total,
								 l_ia_total
								 ,l_us_total, -- added by spamujul for ER#8473903
								  l_is_total  -- added by spamujul for ER#8473903
								 );
				END LOOP;
			CLOSE cblocks_csr;
		END IF;
	END LOOP;
	CLOSE checks_relparty_csr;
	    l_ip_total := 0;
	    l_up_total := 0;
	    l_ia_total := 0;
	    l_ua_total := 0;
	    l_us_total := 0;  -- added by spamujul for ER#8473903
	    l_is_total :=  0;  -- added by spamujul for ER#8473903

-- Loop through check_id and update check results for a party or account
  OPEN checks_relparty_csr;
  LOOP
	  FETCH checks_relparty_csr
	  INTO chk_id,
			sel_type,
			sel_blk_id,
			data_type,
			fmt_mask,
			chk_u_l_flag,
			Thd_grade,
			v_check_level;
	  EXIT WHEN checks_relparty_csr%notfound;
	  IF (sel_type = 'T') THEN
		build_rule('N',chk_id,v_check_level, rule);
	  ELSIF (sel_type = 'B') THEN
		Open block_csr;
		Fetch block_csr INTO blk_id, sql_stmt, curr_code;
		Close block_csr;
		 IF sql_stmt IS NOT NULL Then
			v_party_in_sql	:= INSTR(lower(sql_stmt),':party_id',1);
			v_psite_in_sql	:=  INSTR(lower(sql_stmt),':party_site_id',1);		-- Added by spamujul for ER#8473903
		 Else
			v_party_in_sql	:= 0;
			v_psite_in_sql	:= 0;		-- Added by spamujul for ER#8473903
		 End if;

	   END IF;
         If v_check_level='CONTACT' then
		Evaluate_One_Check(truncate_flag,
					   chk_id,
					   p_party_id,
					   null,
					   NULL,  -- added by spamujul for ER#8473903
					   v_check_level,
					   sel_type,
					   sel_blk_id,
					   data_type,
					   fmt_mask,
					   chk_u_l_flag,
					   Thd_grade,
					   rule,
					   blk_id,
					   sql_stmt,
					   curr_code,
					   l_up_total,
					   l_ip_total,
					   l_ua_total,
					   l_ia_total ,
					   l_us_total,  -- added by spamujul for ER#8473903
					   l_is_total,  -- added by spamujul for ER#8473903
					   NULL );
      End if;
      -- Begin fix by spamujul for ER#8473903
	Begin
		 v_party_id:=p_party_id;
		 IF ((sel_type='B' ) OR (sel_type='T') ) AND v_check_level='SITE' THEN
			IF ((v_psite_in_sql = 0) AND sel_type = 'B') AND v_check_level='SITE' THEN
				NULL;
			ELSE
				cid := dbms_sql.open_cursor;
				IF (sel_type = 'B') THEN
					dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
				ELSIF (sel_type = 'T') THEN
					dbms_sql.parse(cid, rule, dbms_sql.native);
				END IF;
					 dbms_sql.define_column(cid,1,val,240);
				OPEN  cpsite_csr;
						LOOP
							FETCH  cpsite_csr
							INTO cparty_id,
								 cpsite_id;
							EXIT WHEN cpsite_csr%notfound;
							 Evaluate_One_Check(truncate_flag,
										       chk_id,
										       cparty_id,
										       NULL, -- For site level profile check, account parameter should be null
										       cpsite_id,
										       v_check_level,
										       sel_type,
										       sel_blk_id,
										       data_type,
											fmt_mask,
											chk_u_l_flag,
											Thd_grade,
											rule,
											blk_id,
											sql_stmt,
											curr_code,
											l_up_total,
											l_ip_total,
											l_ua_total,
											l_ia_total ,
											l_us_total,
											l_is_total,
											cid);
							END LOOP;
					CLOSE cpsite_csr;
					IF (dbms_sql.is_open(cid)) THEN
						dbms_sql.close_cursor(cid);
					 end if;
			END IF;
		 END IF;
		 Exception
		When others then
			 IF (dbms_sql.is_open(cid)) THEN
				dbms_sql.close_cursor(cid);
			end if;
			set_context('Evaluate_Checks3',
			'chk_id=>'||to_char(chk_id),
			'party_id=>'||to_char(cparty_id),
			'account_id=>'|| NULL
			,'party_site_id =>'||to_char(cpsite_id)
			);
			g_error := sqlcode || ' ' || sqlerrm;
	  	        set_context(NULL, g_error);
	     End;
      -- End  fix by spamujul for ER#8473903

    END LOOP;
   CLOSE checks_relparty_csr;
    IF l_ip_total <> 0 THEN
	  l_for_insert	:= 'Y';
          l_for_party	:= 'Y';
	  l_for_psite   := 'N';-- added by spamujul for ER#8473903
	  Insert_Update_Check_Results(l_ip_total,
						       l_for_insert,
						       l_for_party
						       ,l_for_psite  -- added by spamujul for ER#8473903
						       );
          l_ip_total :=0;
    END IF;
    -- check if there are still records to be updated
    IF l_up_total <> 0 THEN
	  l_for_insert := 'N';
	  l_for_party  := 'Y';
	  l_for_psite   := 'N';-- added by spamujul for ER#8473903
	Insert_Update_Check_Results (l_up_total,
							  l_for_insert,
							  l_for_party
							 ,l_for_psite -- added by spamujul for ER#8473903
							  );
	  l_up_total :=0;
    END IF;
    -- Begin fix by spamujul for ER#8473903
	IF l_is_total <> 0 THEN
		 l_for_insert := 'Y';
		 l_for_party  := 'N';
		 l_for_psite   := 'Y';-- added by spamujul for ER#8473903
		 Insert_Update_Check_Results(l_is_total,
								  l_for_insert,
								  l_for_party
								 ,l_for_psite -- added by spamujul for ER#8473903
								  );
		 l_is_total :=0;
   END IF;
	   IF l_us_total <> 0 THEN
	     l_for_insert := 'N';
	     l_for_party  := 'N';
	     l_for_psite   := 'Y';-- added by spamujul for ER#8473903
	     Insert_Update_Check_Results(l_us_total,
								 l_for_insert,
								 l_for_party
								,l_for_psite -- added by spamujul for ER#8473903
								 );
	     l_us_total :=0;
	  END IF;
    -- End fix by spamujul for ER#8473903

  END IF; -- global if
  --End of new changes

    --New changes for Employee HelpDesk

  IF g_dashboard_for_employee = 'Y' THEN
   l_ip_total :=0;
   l_up_total :=0;
   l_ia_total :=0;
   l_ua_total :=0;
   l_us_total := 0;  -- added by spamujul for ER#8473903
   l_is_total := 0;  -- added by spamujul for ER#8473903
   -- Loop through check_id and update block results for a party or account
	OPEN checks_emp_csr;
	  LOOP
	  FETCH checks_emp_csr
	  INTO chk_id, sel_type, sel_blk_id, data_type, fmt_mask,chk_u_l_flag,Thd_grade,v_check_level;
	  EXIT WHEN checks_emp_csr%notfound;

	  IF sel_type = 'T' then
	  OPEN cblocks_csr;
	  LOOP
	     FETCH cblocks_csr into v_block_id;
	     Exit when cblocks_csr%notfound;
	     Evaluate_Blocks5(v_block_id,
					 p_party_id,
					  p_psite_id, -- added by spamujul for ER#8473903
					 l_up_total,
					 l_ip_total,
					 l_ua_total,
					 l_ia_total
					 ,l_us_total, -- added by spamujul for ER#8473903
	  				 l_is_total  -- added by spamujul for ER#8473903
					 );
	 END LOOP;
	 CLOSE cblocks_csr;
	 END IF;
   END LOOP;
   CLOSE checks_emp_csr;

    l_ip_total :=0;
    l_up_total :=0;
    l_ia_total :=0;
    l_ua_total :=0;

-- Loop through check_id and update check results for a party or account
  OPEN checks_emp_csr;
  LOOP
	  FETCH checks_emp_csr
	  INTO chk_id, sel_type, sel_blk_id, data_type, fmt_mask,chk_u_l_flag,Thd_grade,v_check_level;
	  EXIT WHEN checks_emp_csr%notfound;
	  IF (sel_type = 'T') THEN
	     build_rule('N',chk_id,v_check_level, rule);
     ELSIF (sel_type = 'B') THEN
		Open block_csr;
		Fetch block_csr INTO blk_id, sql_stmt, curr_code;
		Close block_csr;
		IF sql_stmt IS NOT NULL Then
			v_party_in_sql := INSTR(lower(sql_stmt),':party_id',1);
		 Else
			v_party_in_sql := 0;
		 End if;

	   END IF;

      If v_check_level='EMPLOYEE' then
		Evaluate_One_Check(truncate_flag,
						   chk_id,
						   p_party_id,
						   null,
						   NULL,  -- added by spamujul for ER#8473903
						   v_check_level,
						  sel_type,
						  sel_blk_id,
						  data_type,
						  fmt_mask,
						  chk_u_l_flag,
						  Thd_grade,
						  rule,
						  blk_id,
						  sql_stmt,
						  curr_code,
						  l_up_total,
						  l_ip_total,
						  l_ua_total,
						  l_ia_total ,
						  l_us_total,  -- added by spamujul for ER#8473903
						  l_is_total,  -- added by spamujul for ER#8473903
						  NULL );
      End if;
    END LOOP;
   CLOSE checks_emp_csr;
    IF l_ip_total <> 0 THEN
	  l_for_insert := 'Y';
          l_for_party  := 'Y';
	  l_for_psite   := 'N';-- added by spamujul for ER#8473903
	 Insert_Update_Check_Results(l_ip_total,
						       l_for_insert,
						       l_for_party
						       ,l_for_psite  -- added by spamujul for ER#8473903
						       );
          l_ip_total :=0;
    END IF;
    -- check if there are still records to be updated
    IF l_up_total <> 0 THEN
	  l_for_insert := 'N';
	  l_for_party  := 'Y';
	  l_for_psite   := 'N';-- added by spamujul for ER#8473903
	Insert_Update_Check_Results (l_up_total,
							  l_for_insert,
							  l_for_party
							 ,l_for_psite -- added by spamujul for ER#8473903
							  );
	  l_up_total :=0;
    END IF;
  END IF; -- global if
  --End of new changes

  COMMIT;

-- Return 0 for successful completion, 1 for warnings, 2 for error
  IF (error_flag) THEN
	errbuf := Sqlerrm;
	retcode := 2;
  ELSIF (warning_msg <> '') THEN
	errbuf := warning_msg;
	retcode := 1;
  ELSE
	errbuf := '';
	retcode := 0;
  END IF;

  IF (debug) THEN
	  fnd_file.close;
  END IF;

  EXCEPTION
	 WHEN OTHERS THEN
		 ROLLBACK;
		 IF (checks_csr%isopen) THEN
		    CLOSE checks_csr;
	         END IF;
	         IF (debug) THEN
		    fnd_file.close;
		 END IF;
		 -- Retrieve error message into errbuf
		 errbuf := Sqlerrm;
		 -- Return 2 for error
		 retcode := 2;
		 g_error := sqlcode || ' ' || sqlerrm;
		 fnd_file.put_line(fnd_file.log , g_error);
END Evaluate_Checks3;

--  This procedure evaluates the checks for all parties/account in a particular group
--  The batch sql statement is not null and profile check is of type variable ('B')
PROCEDURE Evaluate_Checks4_Var(p_group_id NUMBER) 	IS
			  chk_id				Number;
			  chk_name			Varchar2(240);
			  sel_blk_id			Number;
			  data_type			Varchar2(90);
			  fmt_mask			Varchar2(90);
			  rule				Varchar2(32767);
			  chk_u_l_flag		Varchar2(3);
			  Thd_grade			Varchar2(9);
			  truncate_flag		Varchar2(1) := 'N';
			  blk_id				Number := null;
			  sql_stmt			Varchar2(2000) := null;
			  batch_sql_stmnt	Varchar2(4000)  := null;
			  curr_code			Varchar2(15) := null;
			  v_party_in_sql		Number := 0;
			  v_acct_in_sql		Number := 0;
			  v_psite_in_sql		Number :=0; -- Added by spamujul for ER#8473903
			  v_party_id			Number;
			  v_check_level		Varchar2(10);
			  curr_date			DATE := SYSDATE;
			  insert_stmnt		VARCHAR2(4000);
			  insert_stmnt_sum	VARCHAR2(4000);
			  insert_stmnt_final	VARCHAR2(4000);
			  insert_stmnt_party	VARCHAR2(4000);
			  insert_stmnt_acct	VARCHAR2(4000);
			--Fix bug#7329039 by mpathani
			--select_clause       VARCHAR2(100);
			--v_select_clause     VARCHAR2(100);
			  select_clause		VARCHAR2(2000);
			  v_select_clause		VARCHAR2(2000);
			  Range_Low_Value    VARCHAR2(240);
			  Range_High_Value   VARCHAR2(240);
			  val					VARCHAR2(240) := null;
			  /* variables for columns of insert statement */
			  c_fmt_mask		VARCHAR2(1000);
			  c_grade			VARCHAR2(1000);
			  c_curr_code		VARCHAR2(1000);
			  c_threshold			VARCHAR2(1000);
			  c_rating			VARCHAR2(1000);
			  c_color				VARCHAR2(1000);
			  v_count			NUMBER;
			  v_chk_count		NUMBER;
			  v_batch_count		NUMBER;
			-- varlables for getting CSC schema name
			  v_schema_status	VARCHAR2(1);
			  v_industry			VARCHAR2(1);
			  v_schema_name	VARCHAR2(30);
			  v_get_appl			BOOLEAN;

			-- variables to build the batch sql for summation
			  v_select_pos		number;
			  v_select_length		number;
			  v_from_pos			number;
			  v_from_sum		varchar2(2000);
			  v_select_sum		varchar2(2000) := 'SELECT hz.party_id, null,null,  '; -- Included 'NULL'  value for party_site_id by spamujul for  ER#8473903
			  v_group_pos		number;
			  v_group			varchar2(2000) := 'GROUP BY hz.party_id';
			  return_status		varchar2(50);
			-- variables for handling contact profile variables
			  v_where_clause_no_rel VARCHAR2(1000) := 'HZ.PARTY_TYPE IN (' || '''' || 'PERSON' || '''' || ', ' || '''' ||  'ORGANIZATION' || '''' || ')' ;
			  v_where_clause_rel VARCHAR2(1000) := 'HZ.PARTY_TYPE = ' || '''' ||'PARTY_RELATIONSHIP'|| '''' ;

			  TABLESEGMENT_FULL  EXCEPTION;
			  INDEXSEGMENT_FULL  EXCEPTION;
			  SNAPSHOT_TOO_OLD   EXCEPTION;
			  INTERNAL_ERROR		EXCEPTION;
			  SUMMATION_ERROR	EXCEPTION;

			  PRAGMA EXCEPTION_INIT(TABLESEGMENT_FULL, -1653);
			  PRAGMA EXCEPTION_INIT(INDEXSEGMENT_FULL, -1654);
			  PRAGMA EXCEPTION_INIT(SNAPSHOT_TOO_OLD, -1555);
			  PRAGMA EXCEPTION_INIT(INTERNAL_ERROR, -600);

			checks_csr  checks_cur_var;

			  CURSOR block_csr IS
			      SELECT block_id,
						sql_stmnt,
						UPPER(batch_sql_stmnt),
						currency_code,
						select_clause
				FROM csc_prof_blocks_b a
			       WHERE a.block_id = sel_blk_id;

			   Cursor val_csr3 IS
			     Select Range_Low_Value,
					Range_High_Value
			     From   csc_prof_check_ratings
			     Where  check_id = chk_id
			     and    check_rating_grade = thd_grade;

			   CURSOR rating_crs IS
			     SELECT rating_code,
						check_rating_grade,
						color_code,
						range_low_value,
						range_high_value
			       FROM csc_prof_check_ratings
			      WHERE check_id = chk_id;

BEGIN
           COMMIT;
	   EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
	   EXECUTE IMMEDIATE 'ALTER SESSION SET SKIP_UNUSABLE_INDEXES=TRUE';

	   v_get_appl :=  FND_INSTALLATION.GET_APP_INFO('CSC', v_schema_status, v_industry, v_schema_name);

	   EXECUTE IMMEDIATE 'ALTER TABLE ' || v_schema_name || '.CSC_PROF_CHECK_RESULTS NOLOGGING';
	   EXECUTE IMMEDIATE 'ALTER TABLE ' || v_schema_name || '.CSC_PROF_BATCH_RESULTS2_T NOLOGGING';
	   EXECUTE IMMEDIATE 'ALTER TABLE ' || v_schema_name || '.CSC_PROF_BATCH_RESULTS1_T NOLOGGING';

	   SELECT count(*) INTO v_chk_count FROM csc_prof_check_results;
	   SELECT count(*) INTO v_batch_count FROM CSC_PROF_BATCH_RESULTS2_T;
	   IF v_chk_count = 0 AND v_batch_count <> 0 THEN
	      EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N2 UNUSABLE';
	      EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N3 UNUSABLE';
	      EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N4 UNUSABLE';
	      INSERT /*+ PARALLEL (csc_prof_check_results, 12) */
	      INTO csc_prof_check_results
	 		 (check_results_id,
			  check_id,
			  party_id,
			  cust_account_id,
			  party_site_id, -- Added by spamujul for ER#8473903
			  value,
			 currency_code,
			 grade,
			 created_by,
			 creation_date,
			 last_updated_by,
			 last_update_date,
			 last_update_login,
			 results_threshold_flag,
			 rating_code,
			 color_code
		   )
	      SELECT
			check_results_id,
			check_id,
			party_id,
			cust_account_id,
			party_site_id, -- Added by spamujul for ER#8473903
			value,
			currency_code,
			grade,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			results_threshold_flag,
			rating_code,
			color_code
	      FROM  CSC_PROF_BATCH_RESULTS2_T;
	      COMMIT;
	      EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N2 REBUILD NOLOGGING';
	      EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N3 REBUILD NOLOGGING';
	      EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N4 REBUILD NOLOGGING';
	   END IF;
	   EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || v_schema_name ||'.CSC_PROF_BATCH_RESULTS2_T' ;
	   IF g_dashboard_for_contact IS NULL THEN
	       FND_PROFILE.GET('CSC_DASHBOARD_VIEW_FOR_CONTACT', g_dashboard_for_contact);
	   END IF;
	  /* R12 Employee HelpDesk Modifications */
	 IF g_dashboard_for_employee ='Y' THEN
	      OPEN checks_csr FOR
		 SELECT check_id,
				select_block_id,
				check_level,
				data_type,
				format_mask,
				check_upper_lower_flag,
				threshold_grade
		   FROM csc_prof_checks_b
		   WHERE check_id IN (SELECT check_id FROM csc_prof_group_checks
				      WHERE group_id = p_group_id)
				      AND SYSDATE BETWEEN Nvl(start_date_active, Sysdate)
				      AND Nvl(end_date_active, Sysdate)
				      AND select_type = 'B'
				      AND check_level IN ('EMPLOYEE');
	 ELSIF g_dashboard_for_employee ='N' THEN
			IF g_dashboard_for_contact = 'Y' THEN
			    OPEN checks_csr FOR
				 SELECT check_id,
					     select_block_id,
					     check_level,
					     data_type,
					     format_mask,
					     check_upper_lower_flag,
					     threshold_grade
				  FROM csc_prof_checks_b
				  WHERE check_id IN (SELECT check_id FROM csc_prof_group_checks
						      WHERE group_id = p_group_id)
						      AND  SYSDATE BETWEEN Nvl(start_date_active, Sysdate)
						      AND Nvl(end_date_active, Sysdate)
						      AND select_type = 'B'
						      AND check_level IN ('PARTY', 'ACCOUNT', 'CONTACT','SITE') -- Included 'SITE' by spamujul for ER#8473903
						      ;
			  ELSIF g_dashboard_for_contact = 'N' THEN
			      OPEN checks_csr FOR
				 SELECT check_id,
						select_block_id,
						check_level,
						data_type,
						format_mask,
						check_upper_lower_flag,
						threshold_grade
				   FROM csc_prof_checks_b
				  WHERE check_id IN (SELECT check_id FROM csc_prof_group_checks
						      WHERE group_id = p_group_id)
						      AND SYSDATE BETWEEN Nvl(start_date_active, Sysdate)
						      AND Nvl(end_date_active, Sysdate)
						      AND select_type = 'B'
						      AND check_level IN ('PARTY', 'ACCOUNT','SITE') -- Included 'SITE' by spamujul for ER#8473903
						      ;
			   END IF;
	END IF;
	/* End of R12 Employee HelpDesk Modifications */
	   LOOP
	       FETCH checks_csr
	       INTO chk_id,
			sel_blk_id,
			v_check_level,
			data_type,
			fmt_mask,
			chk_u_l_flag,
			Thd_grade;
	       EXIT WHEN checks_csr%notfound;
	       OPEN block_csr;
	       FETCH block_csr
			INTO blk_id,
			sql_stmt,
			batch_sql_stmnt,
			curr_code,
			select_clause;
	       CLOSE block_csr;
	       IF batch_sql_stmnt IS NOT NULL THEN
		  IF v_check_level = 'CONTACT' THEN
		     IF g_dashboard_for_contact = 'Y' THEN
			batch_sql_stmnt := UPPER(batch_sql_stmnt);
			batch_sql_stmnt := REPLACE(batch_sql_stmnt, v_where_clause_no_rel, v_where_clause_rel);
		     END IF;
		  END IF;
		  IF sql_stmt IS NOT NULL THEN
		     v_party_in_sql :=    INSTR(lower(sql_stmt),':party_id',1);
		     v_acct_in_sql  :=    INSTR(lower(sql_stmt),':cust_account_id',1);
		     v_psite_in_sql :=   INSTR(lower(sql_stmt),':party_site_id',1); -- Added by spamujul for ER#8473903
		  ELSE
		    v_party_in_sql :=  0;
		    v_acct_in_sql  :=  0;
		    v_psite_in_sql := 0;   -- Added by spamujul for ER#8473903
		  END IF;
		  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || v_schema_name ||'.CSC_PROF_BATCH_RESULTS1_T' ;
--		  insert_stmnt := 'INSERT INTO CSC_PROF_BATCH_RESULTS1_T ' || batch_sql_stmnt; -- Commnted the following code by spamujul for ER#8473903
		  insert_stmnt := 'INSERT INTO CSC_PROF_BATCH_RESULTS1_T(PARTY_ID,ACCOUNT_ID,PARTY_SITE_ID,VALUE) ' || batch_sql_stmnt;  -- Added by spamujul for ER#8473903
		  EXECUTE IMMEDIATE (insert_stmnt);
		  IF v_acct_in_sql <> 0 AND v_check_level = 'PARTY' THEN
		     v_select_pos := NULL;
		     v_select_length := NULL;
		     v_from_pos := NULL;
		     v_from_sum := NULL;
		     v_select_sum := 'SELECT hz.party_id, null, NULL, ';   -- Added Last 'Null' for Site operation
		     v_select_clause := NULL;
		     v_group_pos := NULL;
		     v_select_clause := rtrim(ltrim(UPPER(select_clause)));
		     v_select_sum := v_select_sum || v_select_clause;
		     v_select_pos := instr(upper(batch_sql_stmnt), v_select_clause);
		     v_select_length := length(v_select_clause);
		     v_from_pos := v_select_pos + v_select_length;
		     v_from_sum := substr(batch_sql_stmnt, v_from_pos);
		     v_group_pos := instr(upper(v_from_sum), 'GROUP BY HZ.PARTY_ID');
		     v_from_sum := substr(v_from_sum, 1, v_group_pos -1);
		     v_from_sum := v_from_sum || v_group;
		     v_select_sum := v_select_sum || '  ' || v_from_sum;
	    -- validate the sql statement
		    csc_core_utils_pvt.validate_sql_stmnt( p_sql_stmnt => v_select_sum,
                                                    x_return_status => return_status);
		    IF return_status = 'S' THEN
		        -- insert_stmnt_sum := 'INSERT INTO CSC_PROF_BATCH_RESULTS1_T ' || v_select_sum ;  -- Commented the following code by spamujul for ER#8473903
			 -- Added the following code by spamujul for ER#8473903
			    insert_stmnt_sum := 'INSERT INTO CSC_PROF_BATCH_RESULTS1_T(PARTY_ID,ACCOUNT_ID,PARTY_SITE_ID,VALUE)'  || v_select_sum ;
				EXECUTE IMMEDIATE (insert_stmnt_sum);
	             ELSE
			        RAISE SUMMATION_ERROR;
				fnd_file.put_line(fnd_file.log, 'Summation SQL failed for check_id' || chk_id);
		    END IF;
               END IF;
		IF v_check_level = 'PARTY' THEN
				INSERT INTO CSC_PROF_BATCH_RESULTS1_T(PARTY_ID,
															     ACCOUNT_ID,
															     PARTY_SITE_ID, --Included party_site_id for ER#8473903
															     VALUE)
		             SELECT party_id, NULL, NULL,NULL -- Included NULL for  party_site_id for ER#8473903
				FROM hz_parties hz
				WHERE NOT EXISTS (SELECT 1 FROM CSC_PROF_BATCH_RESULTS1_T c WHERE c.party_id = hz.party_id)
				AND hz.status = 'A'
				AND hz.party_type IN ('PERSON', 'ORGANIZATION');
		ELSIF v_check_level = 'CONTACT' THEN
			INSERT INTO CSC_PROF_BATCH_RESULTS1_T(PARTY_ID,
														   ACCOUNT_ID,
														   PARTY_SITE_ID, --Included party_site_id for ER#8473903
														   VALUE)
			SELECT party_id, NULL, NULL ,NULL -- Included NULL for  party_site_id for ER#8473903
			FROM hz_parties hz
			WHERE NOT EXISTS (SELECT 1 FROM CSC_PROF_BATCH_RESULTS1_T c WHERE c.party_id = hz.party_id)
				AND hz.status = 'A'
		                AND hz.party_type = 'PARTY_RELATIONSHIP';
		ELSIF v_check_level = 'ACCOUNT' THEN
			INSERT INTO CSC_PROF_BATCH_RESULTS1_T(PARTY_ID,
														     ACCOUNT_ID,
														     PARTY_SITE_ID, --Included party_site_id for ER#8473903
														     VALUE)
		             SELECT party_id, cust_account_id, NULL ,NULL -- Included NULL for  party_site_id for ER#8473903
				FROM hz_cust_accounts hz
		              WHERE NOT EXISTS (SELECT 1 FROM CSC_PROF_BATCH_RESULTS1_T c WHERE c.account_id = hz.cust_account_id)
				AND hz.status = 'A';
		ELSIF v_check_level = 'EMPLOYEE' THEN
			     INSERT INTO CSC_PROF_BATCH_RESULTS1_T(PARTY_ID,ACCOUNT_ID,PARTY_SITE_ID,VALUE) --Included party_site_id for ER#8473903
			     SELECT person_id, NULL, NULL,NULL -- Included NULL for  party_site_id for ER#8473903
		               FROM per_workforce_current_x hz
				WHERE NOT EXISTS (SELECT 1 FROM CSC_PROF_BATCH_RESULTS1_T c WHERE c.party_id = hz.person_id) ;
		-- Begin fix by spamujul for  ER#8473903
		ELSIF v_check_level = 'SITE' THEN
			   INSERT INTO CSC_PROF_BATCH_RESULTS1_T(PARTY_ID,
														     ACCOUNT_ID,
														     PARTY_SITE_ID, --Included party_site_id for ER#8473903
														     VALUE)
		             SELECT hz.party_id, NULL, hz.party_site_id ,NULL -- Included NULL for  party_site_id for ER#8473903
				FROM hz_party_sites hz
				WHERE NOT EXISTS (SELECT 1 FROM CSC_PROF_BATCH_RESULTS1_T c WHERE c.party_id = hz.party_id and c.party_site_id = hz.party_site_id)
				AND hz.status = 'A'
				AND nvl(hz.created_by_module,'XXX') <> 'SR_ONETIME';
		-- End fix by spamujul for  ER#8473903
		        END IF;
          OPEN val_csr3;
          FETCH val_csr3
		INTO Range_Low_Value,
		Range_High_Value;
          IF val_csr3%NOTFOUND THEN
             Range_Low_Value := NULL;
             Range_High_Value := NULL;
          END IF;
          CLOSE val_csr3;

	  SELECT COUNT(*) INTO v_count FROM csc_prof_check_ratings
          WHERE check_id = chk_id;
          rating_tbl.delete;
          IF v_count > 0 THEN
             OPEN rating_crs;
             FOR a in 1..v_count LOOP
                FETCH rating_crs INTO rating_tbl(a);
             END LOOP;
             CLOSE rating_crs;
          END IF;
          c_fmt_mask := 'CSC_Profile_Engine_PKG.format_mask(' ||
                        '''' || curr_code || '''' || ',' ||
                        '''' || data_type || '''' || ','||
	                'value, '||
		        ''''|| fmt_mask || '''' || ')' ;

          c_grade := 'CSC_Profile_Engine_PKG.rating_color(' ||
                     chk_id || ', ' ||
                     'party_id, account_id,party_site_id, value, ' || -- included by spamujul for  ER#8473903
                     '''' || data_type || '''' || ', ' ||
                     '''' || 'GRADE' || '''' ||', ' ||
                     '''' || v_count || '''' || ')'    ;
          c_curr_code := '''' || curr_code || '''';
          c_threshold := 'CSC_Profile_Engine_PKG.calc_threshold(' ||
                         'value, '||
	                 '''' || Range_Low_Value || '''' || ', '||
	                 '''' || Range_High_Value || '''' || ', '||
		         '''' || data_type || '''' || ', ' ||
		         '''' || chk_u_l_flag || '''' || ')'   ;

          c_rating := 'CSC_Profile_Engine_PKG.rating_color(' ||
                      chk_id || ', ' ||
                      'party_id, account_id,party_site_id, value, ' || -- included by spamujul for  ER#8473903
                      '''' || data_type || '''' || ', ' ||
                      '''' || 'RATING' || '''' ||', ' ||
	              '''' || v_count || '''' || ')'    ;

          c_color := 'CSC_Profile_Engine_PKG.rating_color(' ||
                      chk_id || ', ' ||
                     'party_id, account_id,party_site_id, value, ' || -- included by spamujul for  ER#8473903
                     '''' || data_type || '''' || ', ' ||
                     '''' || 'COLOR' || '''' ||', ' ||
                     '''' || v_count || '''' || ')'    ;

          IF v_check_level = 'ACCOUNT' THEN
             insert_stmnt_final := 'INSERT /*+ PARALLEL(CSC_PROF_BATCH_RESULTS2_T, 12) */ INTO CSC_PROF_BATCH_RESULTS2_T ' ||
                  --          '(check_results_id, check_id, party_id, cust_account_id,value, currency_code, grade, '||
		  -- added party_site_id in the below line for ER#8473903
			  '(check_results_id, check_id, party_id, cust_account_id,party_site_id, value, currency_code, grade, '||
			     ' created_by, creation_date, last_updated_by, last_update_date, last_update_login, '||
			     ' results_threshold_flag, rating_code, color_code)' ||
                             ' SELECT csc_prof_check_results_s.nextval, '
			--      || chk_id || ', party_id, account_id, '
			 -- added party_site_id in the below line for ER#8473903
			      || chk_id || ', party_id, account_id,party_site_id, '
			      || c_fmt_mask ||', '
			      || c_curr_code || ', '
			      || c_grade
			      || ', FND_GLOBAL.USER_ID, Sysdate, FND_GLOBAL.USER_ID, Sysdate, FND_GLOBAL.CONC_LOGIN_ID, '
			      || c_threshold ||', '
			      || c_rating || ', '
			      || c_color
			      ||' FROM CSC_PROF_BATCH_RESULTS1_T where nvl(account_id, -999999) <> -999999 and party_site_id IS NULL'; -- Added 'AND PARTY_SITE_ID IS NULL' for ER#8473903
	-- Begin fix by spamujul for ER# 8473903
	ELSIF  v_check_level = 'SITE' THEN
		insert_stmnt_final := 'INSERT /*+ PARALLEL(CSC_PROF_BATCH_RESULTS2_T, 12) */ INTO CSC_PROF_BATCH_RESULTS2_T ' ||
                  --          '(check_results_id, check_id, party_id, cust_account_id,value, currency_code, grade, '||
		  -- added party_site_id in the below line for ER#8473903
			  '(check_results_id, check_id, party_id, cust_account_id,party_site_id, value, currency_code, grade, '||
			     ' created_by, creation_date, last_updated_by, last_update_date, last_update_login, '||
			     ' results_threshold_flag, rating_code, color_code)' ||
                             ' SELECT csc_prof_check_results_s.nextval, '
			--      || chk_id || ', party_id, account_id, '
			 -- added party_site_id in the below line for ER#8473903
			      || chk_id || ', party_id, account_id,party_site_id, '
			      || c_fmt_mask ||', '
			      || c_curr_code || ', '
			      || c_grade
			      || ', FND_GLOBAL.USER_ID, Sysdate, FND_GLOBAL.USER_ID, Sysdate, FND_GLOBAL.CONC_LOGIN_ID, '
			      || c_threshold ||', '
			      || c_rating || ', '
			      || c_color
			      ||' FROM CSC_PROF_BATCH_RESULTS1_T where nvl(party_site_id, -999999) <> -999999 and account_id IS NULL';
-- End fix by spamujul for ER#8473903
          ELSE
             insert_stmnt_final := 'INSERT /*+ PARALLEL(CSC_PROF_BATCH_RESULTS2_T, 12) */ INTO CSC_PROF_BATCH_RESULTS2_T ' ||
                          --   '(check_results_id, check_id, party_id, cust_account_id, value, currency_code, grade, '||
			  -- added party_site_id in the below line for ER#8473903
			     '(check_results_id, check_id, party_id, cust_account_id,party_site_id, value, currency_code, grade, '||
			     ' created_by, creation_date, last_updated_by, last_update_date, last_update_login, '||
			     ' results_threshold_flag, rating_code, color_code)' ||
                             ' SELECT csc_prof_check_results_s.nextval, '
     			    --  || chk_id || ', party_id, account_id, '
			      -- added party_site_id in the below line for ER#8473903
			      || chk_id || ', party_id, account_id,party_site_id, '
			      || c_fmt_mask ||', '
			      || c_curr_code || ', '
			      || c_grade
			      || ', FND_GLOBAL.USER_ID, Sysdate, FND_GLOBAL.USER_ID, Sysdate, FND_GLOBAL.CONC_LOGIN_ID, '
			      || c_threshold ||', '
			      || c_rating || ', '
			      || c_color
			      ||' FROM CSC_PROF_BATCH_RESULTS1_T where account_id IS NULL and party_site_id  IS NULL'; -- Added 'AND PARTY_SITE_ID IS NULL' for ER#8473903
          END IF;
	  EXECUTE IMMEDIATE (insert_stmnt_final);
          COMMIT;
      ELSE
         /* set the global variable to Y to indicate that profile checks without batch sql exist */
         g_check_no_batch := 'Y';
      END IF ; /* batch_sql_stmnt IS NOT NULL */
   END LOOP;
   CLOSE checks_csr;

   INSERT /*+ PARALLEL (CSC_PROF_BATCH_RESULTS2_T, 12) */
   INTO CSC_PROF_BATCH_RESULTS2_T
	     (check_results_id,
	      check_id,
	      party_id,
	      cust_account_id,
	      party_site_id, -- Added by spamujul for ER#8473903
	      value,
	      currency_code,
	      grade,
	      created_by,
	      creation_date,
	      last_updated_by,
	      last_update_date,
	      last_update_login,
	      results_threshold_flag,
	      rating_code,
	      color_code
	      )
   SELECT
	     check_results_id,
	     check_id,
	     party_id,
	     cust_account_id,
	     party_site_id, -- Added by spamujul for ER#8473903
	      value,
	      currency_code,
	      grade,
	      created_by,
	      creation_date,
	      last_updated_by,
	      last_update_date,
	      last_update_login,
	      results_threshold_flag,
	      rating_code,
	      color_code
   FROM  csc_prof_check_results
   WHERE check_id IN (SELECT check_id FROM csc_prof_group_checks
                      MINUS
                      SELECT check_id FROM csc_prof_group_checks a
                       WHERE group_id = p_group_id
                         AND EXISTS (SELECT 1 FROM csc_prof_checks_b b
                                      WHERE a.check_id = b.check_id AND b.select_type = 'B'));
   COMMIT;
   EXECUTE IMMEDIATE 'TRUNCATE TABLE '|| v_schema_name ||'.csc_prof_check_results';

   EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N2 UNUSABLE';
   EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N3 UNUSABLE';
   EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N4 UNUSABLE';

   INSERT /*+ PARALLEL (csc_prof_check_results, 12) */
   INTO csc_prof_check_results
	     (check_results_id,
	      check_id,
	      party_id,
	      cust_account_id,
	      party_site_id, -- Added by spamujul for ER#8473903
	      value,
	      currency_code,
	      grade,
	      created_by,
	      creation_date,
	      last_updated_by,
	      last_update_date,
	      last_update_login,
	      results_threshold_flag,
	      rating_code,
	      color_code
	      )
   SELECT
     check_results_id,
     check_id,
     party_id,
     cust_account_id,
     party_site_id, -- Added by spamujul for ER#8473903
     value,
     currency_code,
     grade,
     created_by,
     creation_date,
     last_updated_by,
     last_update_date,
     last_update_login,
     results_threshold_flag,
     rating_code, color_code
   FROM  CSC_PROF_BATCH_RESULTS2_T;

   COMMIT;


   EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N2 REBUILD NOLOGGING';
   EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N3 REBUILD NOLOGGING';
   EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N4 REBUILD NOLOGGING';

   EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || v_schema_name ||'.CSC_PROF_BATCH_RESULTS2_T' ;
   EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || v_schema_name ||'.CSC_PROF_BATCH_RESULTS1_T' ;

   EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';
   EXECUTE IMMEDIATE 'ALTER TABLE ' || v_schema_name || '.CSC_PROF_CHECK_RESULTS LOGGING';

EXCEPTION
        WHEN Tablesegment_full then
             CSC_Profile_Engine_PKG.Handle_Exception;
             g_error := sqlcode || ' ' || sqlerrm;
             set_context('Evaluate_Checks4_Var',
                         'check_id => ' || chk_id,
                         'Error => ' || g_error);
             App_Exception.raise_exception;

        WHEN Indexsegment_full then
             CSC_Profile_Engine_PKG.Handle_Exception;
             g_error := sqlcode || ' ' || sqlerrm;
             set_context('Evaluate_Checks4_Var',
                         'check_id => ' || chk_id,
                         'Error => ' || g_error);
             App_Exception.raise_exception;

        WHEN SNAPSHOT_TOO_OLD THEN
             CSC_Profile_Engine_PKG.Handle_Exception;
             g_error := sqlcode || ' ' || sqlerrm;
             set_context('Evaluate_Checks4_Var',
                         'check_id => ' || chk_id,
                         'Error => ' || g_error);
             App_Exception.raise_exception;

        WHEN INTERNAL_ERROR THEN
             CSC_Profile_Engine_PKG.Handle_Exception;
             g_error := sqlcode || ' ' || sqlerrm;
             set_context('Evaluate_Checks4_Var',
                         'check_id => ' || chk_id,
                         'Error => ' || g_error);
             App_Exception.raise_exception;

        WHEN SUMMATION_ERROR THEN
             CSC_Profile_Engine_PKG.Handle_Exception;
             set_context('Evaluate_Checks4_Var',
                         'Summation SQL failed for chk_id => '||to_char(chk_id));
             RAISE;

	WHEN OTHERS THEN
             CSC_Profile_Engine_PKG.Handle_Exception;
	     g_error := sqlcode || ' ' || sqlerrm;
             set_context('Evaluate_Checks4_Var',
                         'check_id => ' || chk_id,
                         'Error => ' || g_error);
             RAISE;

END Evaluate_Checks4_Var;

--  This procedure evaluates the checks
--  for which the batch sql statement is NULL and group_id is not null

PROCEDURE Evaluate_Checks4_No_Batch
					  ( errbuf			OUT	NOCOPY VARCHAR2,
					    retcode		OUT	NOCOPY NUMBER ,
					    p_group_id	in		Number
					    ) IS

			  chk_id				Number;
			  chk_name			Varchar2(240);
			  cparty_id			Number;
			  ccust_acct_id		Number;
			  ccust_psite_id		Number;  -- added by spamujul for ER#8473903
			  sel_type			Varchar2(3);
			  sel_blk_id			Number;
			  data_type			Varchar2(90);
			  fmt_mask			Varchar2(90);
			  rule				Varchar2(32767);
			  Chk_u_l_flag		Varchar2(3);
			  Thd_grade			Varchar2(9);
			  truncate_flag		Varchar2(1)		 := 'N';
			  acct_flag			Varchar2(1);
			  blk_id				Number 		:= null;
			  blk_name			Varchar2(240)	:= null;
			  sql_stmt			Varchar2(2000)	:= null;
			  curr_code			Varchar2(15)		:= null;
			  v_party_in_sql		Number			:= 0;
			  v_acct_in_sql		Number			:= 0;
			  v_psite_in_sql		Number			:= 0;		 -- added by spamujul for ER#8473903
			  v_check_level		Varchar2(10);
			  l_for_insert			varchar2(1)		:= 'Y';
			  l_for_party			varchar2(1)		:= 'Y';
			  l_for_psite			Varchar2(1)		:= 'N';	-- added by spamujul for ER#8473903
			  l_up_total			Number := 0;
			  l_ip_total			Number := 0;
			  l_ua_total			Number := 0;
			  l_ia_total			Number := 0;
			  l_us_total			Number := 0;  -- added by spamujul for ER#8473903
			  l_is_total			Number := 0;  -- added by spamujul for ER#8473903
			  v_party_id			Number;

			  CURSOR checks_csr IS
					 SELECT check_id,
							  select_type,
							  select_block_id,
							 data_type,
							 format_mask,
							 check_upper_lower_flag,
							threshold_grade,
							check_level
			    FROM csc_prof_checks_b a
			   WHERE check_id IN (SELECT check_id
									FROM csc_prof_group_checks
									WHERE group_id = p_group_id)
									AND select_type = 'B'
									AND check_level IN ('PARTY','ACCOUNT','SITE') -- Included the 'SITE' by spamujul for ER#8473903
			     AND EXISTS (SELECT null
					   FROM csc_prof_blocks_b b
					  WHERE a.select_block_id = b.block_id
					    AND b.batch_sql_stmnt IS NULL)
			     AND SYSDATE BETWEEN Nvl(start_date_active, SYSDATE)
								AND Nvl(end_date_active, SYSDATE);

			  CURSOR cparty_csr IS
			     SELECT party_id
			     FROM hz_parties
			    WHERE status = 'A'
			    AND  PARTY_TYPE IN ('PERSON','ORGANIZATION');
			    -- Person, ORG added for 1850508

			  CURSOR caccount_csr IS
			     SELECT party_id, cust_account_id
			     FROM hz_cust_accounts
			     WHERE  party_id=v_party_id
			     AND  status = 'A' ;
			    -- Begin fix by spamujul for NCR ER#8473903
				CURSOR cpsite_csr IS
				      SELECT party_id, party_site_id
				      FROM hz_party_sites
				      WHERE  party_id=v_party_id
				      AND  status = 'A'
				      AND NVL(created_by_module,'XXX') <> 'SR_ONETIME';
			  -- End fix by spamujul for NCR ER#8473903

			  CURSOR block_csr IS
			      SELECT block_id, sql_stmnt, currency_code
			      FROM csc_prof_blocks_b a
			      WHERE a.block_id = sel_blk_id;

		cid 			number;
		val			VARCHAR2(240) := null;

BEGIN
			/* R12 Employee HelpDesk Modifications */
			/* The processing to be done for either employee level(employee) or customer level(party,account,contact) */
			IF g_dashboard_for_employee = 'N' THEN
				   l_ip_total := 0;
				   l_up_total := 0;
				   l_ia_total := 0;
				   l_ua_total := 0;
				   l_us_total  := 0;  -- added by spamujul for ER#8473903
				   l_is_total := 0;	 -- added by spamujul for ER#8473903
				   OPEN checks_csr;
					 LOOP
						FETCH checks_csr
						INTO chk_id,
							 sel_type,
							 sel_blk_id,
							 data_type,
							 fmt_mask,
							 chk_u_l_flag,
							 Thd_grade,
							 v_check_level;
						EXIT WHEN checks_csr%notfound;
						Open block_csr;
							Fetch block_csr INTO
								   blk_id,
								   sql_stmt,
								   curr_code;
						Close block_csr;
						IF sql_stmt IS NOT NULL Then
							 v_party_in_sql	:= INSTR(lower(sql_stmt),':party_id',1);
							 v_acct_in_sql	:= INSTR(lower(sql_stmt),':cust_account_id',1);
							 v_psite_in_sql	:= INSTR(lower(sql_stmt),':party_site_id',1); -- added by spamujul for ER#8473903
						Else
							 v_party_in_sql		:=	0;
							 v_acct_in_sql		:=	0;
							 v_psite_in_sql		:=	0; -- added by spamujul for ER#8473903
						End if;
				Begin
						cid := dbms_sql.open_cursor;
						dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
						dbms_sql.define_column(cid,1,val,240);
						OPEN cparty_csr;
							LOOP
								FETCH cparty_csr
								INTO cparty_id;
								EXIT WHEN cparty_csr%notfound;
								If v_check_level='PARTY' Then
										Evaluate_One_Check(truncate_flag,
															     chk_id,
															     cparty_id,
															     null,
															     NULL,  -- added by spamujul for ER#8473903
															     v_check_level,
															     sel_type,
															     sel_blk_id,
															     data_type,
															     fmt_mask,
															     chk_u_l_flag,
															     Thd_grade,
															     rule,
															     blk_id,
															     sql_stmt,
															     curr_code,
															     l_up_total,
															     l_ip_total,
															     l_ua_total,
															     l_ia_total ,
															     l_us_total,  -- added by spamujul for ER#8473903
															     l_is_total ,  -- added by spamujul for ER#8473903
															     cid);
								End if;
								/* added this condition for Bug 1937730*/
								v_party_id:= cparty_id;
								IF v_check_level = 'ACCOUNT' Then
									If (v_acct_in_sql = 0)  Then
										 NULL;
									Else
										OPEN caccount_csr;
											LOOP
												FETCH caccount_csr
												      INTO cparty_id,
														ccust_acct_id;
												EXIT WHEN caccount_csr%notfound;
												 Evaluate_One_Check(truncate_flag,
																	chk_id,
																	cparty_id,
																	ccust_acct_id,
																	NULL,  -- added by spamujul for ER#8473903
																	v_check_level,
																	sel_type,
																	sel_blk_id,
																	data_type,
																	fmt_mask,
																	chk_u_l_flag,
																	Thd_grade,
																	rule,
																	blk_id,
																	sql_stmt,
																	curr_code,
																	l_up_total,
																	l_ip_total,
																	l_ua_total
																	, l_ia_total ,
																	l_us_total,  -- added by spamujul for ER#8473903
																	l_is_total,  -- added by spamujul for ER#8473903
																	cid
																	);
											 END LOOP;
											CLOSE caccount_csr;
									End if;  -- added for 1850508
								END IF;
								-- Begin fix by spamujul for ER#8473903
								IF v_check_level = 'SITE' THEN
										IF (v_psite_in_sql = 0)  THEN
											 NULL;
										ELSE
											OPEN cpsite_csr ;
												LOOP
													FETCH cpsite_csr
													    INTO cparty_id,
														       ccust_psite_id;
													    EXIT WHEN cpsite_csr%notfound;
													    Evaluate_One_Check(truncate_flag,
																		chk_id,
																		cparty_id,
																		NULL,
																		ccust_psite_id,
																		v_check_level,
																		sel_type,
																		sel_blk_id,
																		data_type,
																		fmt_mask,
																		chk_u_l_flag,
																		Thd_grade,
																		rule,
																		blk_id,
																		sql_stmt,
																		curr_code,
																		l_up_total,
																		l_ip_total,
																		l_ua_total
																		, l_ia_total ,
																		l_us_total,
																		l_is_total,
																		cid
																		);
												END LOOP;
											CLOSE cpsite_csr;
										END IF;
								END IF;
								-- End fix by spamujul for ER#8473903
						END LOOP;
					CLOSE cparty_csr;
					 IF (dbms_sql.is_open(cid)) THEN
					    dbms_sql.close_cursor(cid);
					 end if;
				Exception
						 When others then
								IF (dbms_sql.is_open(cid)) THEN
									dbms_sql.close_cursor(cid);
							     end if;
							     set_context('Evaluate_Checks4_No_Batch',
								'chk_id=>'||to_char(chk_id),
								'party_id=>'||to_char(cparty_id),
								'account_id=>'||to_char(ccust_acct_id)
								,'party_site_id=>'||to_char(ccust_psite_id) -- added by spamujul for ER#8473903
								);
								g_error := sqlcode || ' ' || sqlerrm;
								set_context(NULL, g_error);
				End;
			END LOOP;
		CLOSE checks_csr;
	   -- check if there are still records to be inserted
		   IF l_ip_total <> 0 THEN
			l_for_insert	:= 'Y';
			l_for_party	:= 'Y';
			l_for_psite	:= 'N';-- added by spamujul for ER#8473903
			Insert_Update_Check_Results(l_ip_total,
								       l_for_insert,
								       l_for_party
								       ,l_for_psite  -- added by spamujul for ER#8473903
								       );
			l_ip_total :=0;
		   END IF;
		   -- check if there are still records to be updated
		   IF l_up_total <> 0 THEN
			l_for_insert	:= 'N';
			l_for_party	:= 'Y';
			l_for_psite	:= 'N';-- added by spamujul for ER#8473903
			Insert_Update_Check_Results (l_up_total,
									  l_for_insert,
									  l_for_party
									 ,l_for_psite -- added by spamujul for ER#8473903
									  );
			l_up_total :=0;
		   END IF;
		   -- check if there are still records to be inserted
	   IF l_ia_total <> 0 THEN
		l_for_insert	:= 'Y';
		l_for_party	:= 'N';
		l_for_psite	:= 'N';-- added by spamujul for ER#8473903
		Insert_Update_Check_Results(l_ia_total,
								  l_for_insert,
								  l_for_party
								 ,l_for_psite -- added by spamujul for ER#8473903
								  );
		l_ia_total :=0;
	   END IF;
	   -- check if there are still records to be updated
	   IF l_ua_total <> 0 THEN
		l_for_insert	:= 'N';
		l_for_party	:= 'N';
		l_for_psite	:= 'N';-- added by spamujul for ER#8473903
		Insert_Update_Check_Results(l_ua_total,
								 l_for_insert,
								 l_for_party
								,l_for_psite -- added by spamujul for ER#8473903
								 );
		l_ua_total :=0;
	   END IF;
	 -- Begin fix by spamujul for ER#8473903
	 IF l_is_total <> 0 THEN
			l_for_insert	:= 'Y';
			l_for_party	:= 'N';
			l_for_psite	:= 'Y';
			Insert_Update_Check_Results(l_is_total,
										l_for_insert,
										l_for_party
										,l_for_psite -- added by spamujul for ER#8473903
										);
			l_is_total :=0;
	   END IF;
	   IF l_us_total <> 0 THEN
		l_for_insert	:= 'N';
		l_for_party	:= 'N';
		l_for_psite	:= 'N'; -- added by spamujul for ER#8473903
		Insert_Update_Check_Results(l_us_total,
								 l_for_insert,
								 l_for_party
								,l_for_psite -- added by spamujul for ER#8473903
								 );
		l_us_total :=0;
	   END IF;
	 -- End fix by spamujul ER#8473903
	   IF g_dashboard_for_contact IS NULL THEN
	      FND_PROFILE.GET('CSC_DASHBOARD_VIEW_FOR_CONTACT',g_dashboard_for_contact);
	   END IF;
	   IF g_dashboard_for_contact = 'Y' THEN
		       l_ip_total := 0;
		       l_up_total := 0;
		       l_ia_total := 0;
		       l_ua_total := 0;
		       l_us_total :=0; -- added by spamujul for ER#8473903
		       l_is_total := 0; -- added by spamujul for ER#8473903
			Evaluate_blocks_Rel(p_up_total	=>	 l_up_total,
							   p_ip_total		=>	l_ip_total,
							   p_ua_total		=>	l_ua_total,
							   p_ia_total		=>	l_ia_total,
							   p_us_total		=>	l_us_total, -- added by spamujul for ER#8473903
							   p_is_total		=>	l_is_total, -- added by spamujul for ER#8473903
							   p_group_id	=>	p_group_id,
							   p_no_batch_sql => 'Y' );
			Evaluate_checks_Rel(errbuf => errbuf,
						 retcode => retcode,
						p_group_id => p_group_id,
						p_no_batch_sql => 'Y'
						);
	END IF;
	COMMIT;
   -- Return 0 for successful completion, 1 for warnings, 2 for error
	 IF (error_flag) THEN
		errbuf := Sqlerrm;
		retcode := 2;
	ELSIF (warning_msg <> '') THEN
		errbuf := warning_msg;
		retcode := 1;
	ELSE
		errbuf := '';
		retcode := 0;
	END IF;
  ELSIF g_dashboard_for_employee = 'Y' THEN
	       l_ip_total := 0;
	       l_up_total := 0;
	       l_ia_total := 0;
	       l_ua_total := 0;
	       l_us_total :=0; -- added by spamujul for ER#8473903
	       l_is_total := 0; -- added by spamujul for ER#8473903
	       Evaluate_blocks_Emp(p_up_total => l_up_total,
							   p_ip_total => l_ip_total,
							   p_ua_total => l_ua_total,
							   p_ia_total => l_ia_total,
							   p_us_total => l_us_total, -- added by spamujul for ER#8473903
							   p_is_total => l_is_total, -- added by spamujul for ER#8473903
							   p_group_id => p_group_id,
							   p_no_batch_sql => 'Y' );
		 Evaluate_checks_Emp(errbuf => errbuf,
							   retcode => retcode,
							   p_group_id => p_group_id,
							   p_no_batch_sql => 'Y');
   END IF;
   COMMIT;
   -- Return 0 for successful completion, 1 for warnings, 2 for error
   IF (error_flag) THEN
		errbuf := Sqlerrm;
		retcode := 2;
   ELSIF (warning_msg <> '') THEN
		errbuf := warning_msg;
		retcode := 1;
   ELSE
		errbuf := '';
		retcode := 0;
   END IF;
   IF (debug) THEN
	fnd_file.close;
   END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         IF (checks_csr%isopen) THEN
	    CLOSE checks_csr;
	 END IF;
	 IF (cparty_csr%isopen) THEN
	    CLOSE cparty_csr;
	 END IF;
	 IF (caccount_csr%isopen) THEN
	    CLOSE caccount_csr;
	 END IF;
	 -- Begin fix by spamujul for  ER#8473903
	  IF (cpsite_csr%isopen) THEN
	    CLOSE cpsite_csr;
	 END IF;
	 -- End fix by spamujul for  ER#8473903
	 IF (debug) THEN
	    fnd_file.close;
	 END IF;

         -- Retrieve error message into errbuf
         errbuf := Sqlerrm;

      	 -- Return 2 for error
         retcode := 2;

	 g_error := sqlcode || ' ' || sqlerrm;
	 fnd_file.put_line(fnd_file.log , g_error);

END Evaluate_Checks4_No_Batch;
--
-- Evaluate_Checks4_Rule
--   if Party_id is null, Account_id is null and Group_id is not null
--   Loop through Checks in this group and evaluate the results
--   for all Parties and Accounts for Profile check type Rule ('T')
--
PROCEDURE Evaluate_Checks4_Rule  ( errbuf	OUT	NOCOPY VARCHAR2,
									    retcode	OUT	NOCOPY NUMBER ,
									    p_group_id  in      Number
									    ) IS

	  chk_id				Number;
	  chk_name			Varchar2(240);
	  cparty_id			Number;
	  ccust_acct_id		Number;
	  cpsite_id			Number;   -- added by spamujul for ER#8473903
	  sel_type			Varchar2(3);
	  sel_blk_id			Number;
	  data_type			Varchar2(90);
	  fmt_mask			Varchar2(90);
	  rule				Varchar2(32767);
	  Chk_u_l_flag		Varchar2(3);
	  Thd_grade			Varchar2(9);
	  truncate_flag		Varchar2(1)		:= 'N';
	  acct_flag			Varchar2(1);
	  blk_id				Number 		:= null;
	  blk_name			Varchar2(240)	:= null;
	  sql_stmt			Varchar2(2000)	:= null;
	  curr_code			Varchar2(15)		:= null;
	  v_party_in_sql		Number		:= 0;
	  v_acct_in_sql		Number		:= 0;
	  v_psite_in_sql		Number		:= 0;  -- added by spamujul for ER#8473903
	  v_check_level		Varchar2(10);
	  l_for_insert			varchar2(1)	:= 'Y';
	  l_for_party			varchar2(1)	:= 'Y';
	  l_for_psite			Varchar2(1)	:= 'N'; -- added by spamujul for ER#8473903
	  l_up_total			Number		:= 0;
	  l_ip_total			Number		:= 0;
	  l_ua_total			Number		:= 0;
	  l_ia_total			Number		:= 0;
	  l_us_total			Number		:= 0;  -- added by spamujul for ER#8473903
	  l_is_total			Number		:= 0;  -- added by spamujul for ER#8473903
	  v_chk_count           NUMBER := 0;
	/* added this variable for Bug 1937730*/
	v_party_id            Number;
	CURSOR checks_csr IS
		SELECT check_id,
				select_type,
				select_block_id,
				data_type,
				format_mask,
				check_upper_lower_flag,
				threshold_grade,
				check_level
	     FROM csc_prof_checks_b
		WHERE check_id in (select check_id
							from csc_prof_group_checks
							 where group_id = p_group_id)
	AND check_level IN ('PARTY','ACCOUNT','SITE') -- Included by spamujul for  ER#8473903
	AND  Sysdate BETWEEN Nvl(start_date_active, Sysdate)
                       AND Nvl(end_date_active, Sysdate)
	AND select_type = 'T';
	CURSOR checks_count IS
		SELECT COUNT(*)
		 FROM csc_prof_checks_b
		WHERE check_id in (select check_id
							from csc_prof_group_checks
				                       where group_id = p_group_id)
	        AND Sysdate BETWEEN Nvl(start_date_active, Sysdate)
	                     AND Nvl(end_date_active, Sysdate)
		AND select_type = 'T';
	  CURSOR cparty_csr IS
	     SELECT party_id
	     FROM hz_parties
	    WHERE status = 'A'
	    AND  PARTY_TYPE IN ('PERSON','ORGANIZATION');
	    -- Person, ORG added for 1850508
/* added this condition party_id=v_party_id for Bug 1937730*/
	  CURSOR caccount_csr IS
	     SELECT party_id, cust_account_id
	     FROM hz_cust_accounts
	     WHERE  party_id=v_party_id
	     AND  status = 'A' ;
	   -- Begin fix by spamujul for ER#8473903
	   CURSOR cpsite_csr IS
		      SELECT party_id, party_site_id
		      FROM hz_party_sites
		      WHERE  party_id=v_party_id
		      AND  status = 'A'
		      AND NVL(created_by_module,'XXX') <> 'SR_ONETIME';
   -- End fix by spamujul for ER#8473903
	  CURSOR block_csr IS
	      SELECT block_id, sql_stmnt, currency_code
	      FROM csc_prof_blocks_b a
	      WHERE a.block_id = sel_blk_id;

		cid 	number;
		val		VARCHAR2(240) := null;
BEGIN
		/* R12 Employee HelpDesk Modifications */
		 /* The processing to be done for either employee level(employee) or customer level(party,account,contact) */
		IF g_dashboard_for_employee = 'N' THEN
		   OPEN checks_count;
				 FETCH checks_count
				 INTO v_chk_count;
		   CLOSE checks_count;
		   IF v_chk_count > 0 THEN
		      /* blocks will be evaluated only if the type is T */
		      Evaluate_Blocks4(l_up_total,
							l_ip_total,
							l_ua_total,
							l_ia_total,
							l_us_total, -- added by spamujul for ER#8473903
							l_is_total,  -- added by spamujul for ER#8473903
							p_group_id
							);
		   END IF;
		   l_ip_total := 0;
		   l_up_total := 0;
		   l_ia_total := 0;
		   l_ua_total := 0;
		   l_us_total := 0;  -- added by spamujul for ER#8473903
		   l_is_total  := 0;  -- added by spamujul for ER#8473903
		   OPEN checks_csr;
			   LOOP
			       FETCH checks_csr
			       INTO chk_id,
					  sel_type,
					  sel_blk_id,
					  data_type,
					  fmt_mask,
					  chk_u_l_flag,
					  Thd_grade,
					  v_check_level;
			       EXIT WHEN checks_csr%notfound;
			       IF (sel_type = 'T') THEN
				   acct_flag := 'N';
				   build_rule(acct_flag,
							chk_id,
							v_check_level,
							rule);
			       ELSIF (sel_type = 'B') THEN
				   Open block_csr;
					   Fetch block_csr
					   INTO blk_id,
						     sql_stmt,
						     curr_code;
				   Close block_csr;
			       END IF;
				IF sql_stmt IS NOT NULL Then
					v_party_in_sql	:= INSTR(lower(sql_stmt),':party_id',1);
					v_acct_in_sql	:= INSTR(lower(sql_stmt),':cust_account_id',1);
					v_psite_in_sql	:= INSTR(lower(sql_stmt),':party_site_id',1); -- added by spamujul for ER#8473903
				Else
					v_party_in_sql	:= 0;
					v_acct_in_sql	:= 0;
					v_psite_in_sql	:= 0;  -- added by spamujul for ER#8473903
				End if;
			/* This begin, end exception is added mainly for exception handing for Bug 19800
			04*/
			Begin
			       IF ((sel_type='B' ) OR  (sel_type='T') ) Then -- Only valid types
				       	   -- Loop through all parties
					   -- Open the Cursor
					   cid := dbms_sql.open_cursor;
					   if (sel_type = 'B') then
						dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
					   elsif (sel_type = 'T') then
						dbms_sql.parse(cid, rule, dbms_sql.native);
					   end if;
					   dbms_sql.define_column(cid,1,val,240);
			   	        -- pass the cid
				       OPEN cparty_csr;
						   LOOP
							      FETCH cparty_csr
							      INTO cparty_id;
							      EXIT WHEN cparty_csr%notfound;
							      If v_check_level='PARTY' Then
									  Evaluate_One_Check(truncate_flag,
													     chk_id,
													     cparty_id,
													     null,
													     NULL,  -- added by spamujul for ER#8473903
													     v_check_level,
													     sel_type,
													     sel_blk_id,
													     data_type,
													     fmt_mask,
													     chk_u_l_flag,
													     Thd_grade,
													     rule,
													     blk_id,
													     sql_stmt,
													     curr_code,
													     l_up_total,
													     l_ip_total,
													     l_ua_total,
													     l_ia_total ,
													     l_us_total,  -- added by spamujul for ER#8473903
													     l_is_total,  -- added by spamujul for ER#8473903
													     cid);
							End if;
					                /* added this condition for Bug 1937730*/
					                v_party_id:=cparty_id;
					              IF (sel_type = 'T') THEN
					                     acct_flag := 'Y';
					                     build_rule(acct_flag,
										chk_id,
										v_check_level,
										rule);
							END IF;
					              IF ((sel_type='B' ) OR (sel_type='T') ) and v_check_level='ACCOUNT' Then -- Only valid Types now
						                   If ((v_acct_in_sql = 0) and sel_type = 'B') and v_check_level='ACCOUNT'  Then -- added for1850508
									      -- Check can be made only for 'B' types,
									      -- If acct is not present as bind variable, the sql might return wrong
									      -- rows (party level counts) at account leve.

									      --and (v_party_in_sql <> 0 and v_acct_in_sql <> 0) OR
									      --(sel_type='T') ) Then
								               NULL;
						                   Else
									   -- Loop through all parties with accounts
										      -- added for 1850508
										      --Open Cursor
										      -- dbms_output.put_line('Opening and PArsing in checks1 Accounts Check_id -'||to_char(chk_id));
										OPEN caccount_csr;
											      LOOP
												   FETCH caccount_csr
												   INTO cparty_id, ccust_acct_id;
												   EXIT WHEN caccount_csr%notfound;
												   Evaluate_One_Check(truncate_flag,
																      chk_id,
																       cparty_id,
																       ccust_acct_id,
																       NULL,  -- added by spamujul for ER#8473903
																       v_check_level,
																       sel_type,
																       sel_blk_id,
																	data_type,
																	fmt_mask,
																	chk_u_l_flag,
																	Thd_grade,
																	rule,
																	blk_id,
																	sql_stmt,
																	curr_code,
																	l_up_total,
																	l_ip_total,
																	l_ua_total
																	, l_ia_total ,
																	l_us_total,  -- added by spamujul for ER#8473903
																	l_is_total,  -- added by spamujul for ER#8473903
																	cid);
											      END LOOP;
											CLOSE caccount_csr;
										End if; -- added for 1850508
							END IF;
							-- Begin fix by spamujul for ER#8473903
							 v_party_id:=cparty_id;
							 IF ((sel_type='B' ) OR (sel_type='T') ) AND v_check_level='SITE' THEN
								IF ((v_psite_in_sql = 0) AND sel_type = 'B') AND v_check_level='SITE' THEN
									NULL;
								ELSE
									cid := dbms_sql.open_cursor;
									IF (sel_type = 'B') THEN
										dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
									ELSIF (sel_type = 'T') THEN
										dbms_sql.parse(cid, rule, dbms_sql.native);
									END IF;
									 dbms_sql.define_column(cid,1,val,240);
									OPEN  cpsite_csr;
									LOOP
										FETCH  cpsite_csr
										INTO cparty_id,
											 cpsite_id;
										EXIT WHEN cpsite_csr%notfound;
										 Evaluate_One_Check(truncate_flag,
																      chk_id,
																       cparty_id,
																       null,
																       cpsite_id,
																       v_check_level,
																       sel_type,
																       sel_blk_id,
																	data_type,
																	fmt_mask,
																	chk_u_l_flag,
																	Thd_grade,
																	rule,
																	blk_id,
																	sql_stmt,
																	curr_code,
																	l_up_total,
																	l_ip_total,
																	l_ua_total
																	, l_ia_total ,
																	l_us_total,
																	l_is_total,
																	cid);
										END LOOP;
									CLOSE cpsite_csr;
									IF (dbms_sql.is_open(cid)) THEN
										dbms_sql.close_cursor(cid);
									END IF;
								END IF;
							 END IF;
							-- End fix by  spamujul for ER#8473903
				   END LOOP;
				CLOSE cparty_csr;
				   IF (dbms_sql.is_open(cid)) THEN
					dbms_sql.close_cursor(cid);
				   end if;
		        END IF;
		  Exception
		        When others then
				  IF (dbms_sql.is_open(cid)) THEN
				      dbms_sql.close_cursor(cid);
				  end if;
			          set_context('Evaluate_Checks4_Rule',
				'chk_id=>'||to_char(chk_id),
				'party_id=>'||to_char(cparty_id),
				'account_id=>'||to_char(ccust_acct_id)
				,'party_site_id =>'||to_char(cpsite_id) -- added by spamujul for ER#8473903
				);
				g_error := sqlcode || ' ' || sqlerrm;
			         set_context(NULL, g_error);
		  End;
	END LOOP;
	CLOSE checks_csr;

	   -- check if there are still records to be inserted
	   IF l_ip_total <> 0 THEN
		l_for_insert := 'Y';
		l_for_party  := 'Y';
		l_for_psite   := 'N';-- added by spamujul for ER#8473903
		Insert_Update_Check_Results(l_ip_total,
							       l_for_insert,
							       l_for_party
							       ,l_for_psite  -- added by spamujul for ER#8473903
							       );
		l_ip_total :=0;
	   END IF;
	   -- check if there are still records to be updated
	   IF l_up_total <> 0 THEN
		l_for_insert := 'N';
		l_for_party  := 'Y';
		l_for_psite   := 'N';-- added by spamujul for ER#8473903
		Insert_Update_Check_Results (l_up_total,
								  l_for_insert,
								  l_for_party
								 ,l_for_psite -- added by spamujul for ER#8473903
								  );
		l_up_total :=0;
	   END IF;

	   -- check if there are still records to be inserted
	   IF l_ia_total <> 0 THEN
		l_for_insert := 'Y';
		l_for_party  := 'N';
		l_for_psite   := 'N';-- added by spamujul for ER#8473903
		Insert_Update_Check_Results(l_ia_total,
								  l_for_insert,
								  l_for_party
								 ,l_for_psite -- added by spamujul for ER#8473903
								  );
		l_ia_total :=0;
	   END IF;
	   -- check if there are still records to be updated
	   IF l_ua_total <> 0 THEN
		l_for_insert := 'N';
		l_for_party  := 'N';
		l_for_psite   := 'N';-- added by spamujul for ER#8473903
		Insert_Update_Check_Results(l_ua_total,
								 l_for_insert,
								 l_for_party
								,l_for_psite -- added by spamujul for ER#8473903
								 );
		l_ua_total :=0;
	   END IF;
	   -- Begin fix by spamujul for ER#8473903
	    IF l_is_total <> 0 THEN
		l_for_insert := 'Y';
		l_for_party  := 'N';
		l_for_psite   := 'Y';
		Insert_Update_Check_Results(l_ia_total,
								  l_for_insert,
								  l_for_party
								 ,l_for_psite
								  );
		l_is_total :=0;
	   END IF;
	   IF l_us_total <> 0 THEN
		l_for_insert := 'N';
		l_for_party  := 'N';
		l_for_psite   := 'Y';
		Insert_Update_Check_Results(l_ua_total,
								 l_for_insert,
								 l_for_party
								,l_for_psite
								 );
		l_us_total :=0;
	   END IF;
	   -- End fix by spamujul for ER#8473903
	   IF g_dashboard_for_contact = 'Y' THEN
	       l_ip_total := 0;
	       l_up_total := 0;
	       l_ia_total := 0;
	       l_ua_total := 0;
		l_us_total :=0; -- added by spamujul for ER#8473903
		l_is_total := 0; -- added by spamujul for ER#8473903

	       Evaluate_blocks_Rel(p_up_total => l_up_total,
				   p_ip_total => l_ip_total,
				   p_ua_total => l_ua_total,
				   p_ia_total => l_ia_total,
				   p_group_id => p_group_id,
				   p_us_total => l_us_total, -- added by spamujul for ER#8473903
				   p_is_total => l_is_total, -- added by spamujul for ER#8473903
				   p_rule_only => 'Y' );

	       Evaluate_checks_Rel(errbuf => errbuf,
				   retcode => retcode,
				   p_group_id => p_group_id,
				   p_rule_only => 'Y');
	   END IF;
	   COMMIT;

	   -- Return 0 for successful completion, 1 for warnings, 2 for error
	   IF (error_flag) THEN
	      errbuf := Sqlerrm;
	      retcode := 2;
	   ELSIF (warning_msg <> '') THEN
	      errbuf := warning_msg;
	      retcode := 1;
	   ELSE
	      errbuf := '';
	      retcode := 0;
	   END IF;
	/* R12 Employee HelpDesk Modifications */
	  ELSIF g_dashboard_for_employee = 'Y' THEN
	       l_ip_total := 0;
	       l_up_total := 0;
	       l_ia_total := 0;
	       l_ua_total := 0;
		l_us_total :=0; -- added by spamujul for ER#8473903
		l_is_total := 0; -- added by spamujul for ER#8473903

	       Evaluate_blocks_Emp(p_up_total => l_up_total,
				   p_ip_total => l_ip_total,
				   p_ua_total => l_ua_total,
				   p_ia_total => l_ia_total,
				   p_us_total => l_us_total, -- added by spamujul for ER#8473903
				   p_is_total => l_is_total, -- added by spamujul for ER#8473903
				   p_group_id => p_group_id,
				   p_rule_only => 'Y' );

		Evaluate_checks_Emp(errbuf => errbuf,
				 retcode => retcode,
				  p_group_id => p_group_id,
				p_rule_only => 'Y');
	END IF;
/* End of  R12 Employee HelpDesk Modifications */
	COMMIT;
	   -- Return 0 for successful completion, 1 for warnings, 2 for error
	   IF (error_flag) THEN
	      errbuf := Sqlerrm;
	      retcode := 2;
	   ELSIF (warning_msg <> '') THEN
	      errbuf := warning_msg;
	      retcode := 1;
	   ELSE
	      errbuf := '';
	      retcode := 0;
	   END IF;

	   IF (debug) THEN
	      fnd_file.close;
	   END IF;
   EXCEPTION
			 WHEN OTHERS THEN
				         ROLLBACK;
				         IF (checks_csr%isopen) THEN
					    CLOSE checks_csr;
					 END IF;
					 IF (cparty_csr%isopen) THEN
					    CLOSE cparty_csr;
					 END IF;
					 IF (caccount_csr%isopen) THEN
					    CLOSE caccount_csr;
					 END IF;
					 -- Begin fix by spamujul for ER#8473903
					IF (cpsite_csr%isopen) THEN
					    CLOSE cpsite_csr;
					 END IF;
					 -- End fix by spamujul for  ER#8473903
	 IF (debug) THEN
	    fnd_file.close;
	 END IF;

         -- Retrieve error message into errbuf
         errbuf := Sqlerrm;

      	 -- Return 2 for error
         retcode := 2;

	 g_error := sqlcode || ' ' || sqlerrm;
	 fnd_file.put_line(fnd_file.log , g_error);

END Evaluate_Checks4_Rule;
--
-- Evaluate_One_Check
--   Evaluate the given profile check and store the result in the
--   CSC_PROF_CHECK_RESULTS table. Also store the grade if ranges are
--   specified.
-- IN
--   chk_id  	- profile check identifier
--   cust_id 	- customer identifier for which check is evaluated
--   acct_id 	- customer's account identifier
--   sel_type 	- 'B' for block; 'T' for true or false ("indicator" check)
--   sel_blk_id - building block identifier (required if select type is block)
--   data_type 	- data type of check result (used for applying format mask)
--   fmt_mask 	- format mask for check result (ignored if data type is char or
--              	currency code is present)
--   rule  	- sql statement that returns 0 or 1 row for an indicator check
--   P_CID 	- Cursor passed from calling routine to avoid re-parsing the same sql statement
PROCEDURE Evaluate_One_Check
		  ( p_truncate_flag	IN	VARCHAR2,
		    p_chk_id			IN	NUMBER,
		    p_party_id			IN	NUMBER,
		    p_acct_id			IN	NUMBER	 DEFAULT NULL,
		    p_psite_id			IN	NUMBER    DEFAULT NULL, -- added by spamujul for ER#8473903
		    p_check_level		IN     VARCHAR2 DEFAULT NULL,
		    p_sel_type		IN	VARCHAR2,
		    p_sel_blk_id		IN	NUMBER   DEFAULT NULL,
		    p_data_type     		IN	VARCHAR2 DEFAULT NULL,
		    p_fmt_mask		IN	VARCHAR2 DEFAULT NULL,
		    p_chk_u_l_flag	IN      VARCHAR2 DEFAULT NULL,
		    p_thd_grade		IN      VARCHAR2 DEFAULT NULL,
		    p_rule				IN	VARCHAR2 DEFAULT NULL,
		    p_blk_id			IN	NUMBER   DEFAULT NULL,
		    p_sql_stmt		IN	VARCHAR2 DEFAULT NULL,
		    p_curr_code		IN	VARCHAR2 DEFAULT NULL,
		    p_up_total      	IN OUT NOCOPY NUMBER ,
		    p_ip_total      	IN OUT NOCOPY NUMBER ,
		    p_ua_total      	IN OUT NOCOPY NUMBER ,
		    p_ia_total      	IN OUT NOCOPY NUMBER ,
		    p_us_total		IN OUT NOCOPY NUMBER, -- added by spamujul for ER#8473903
		    p_is_total		IN OUT NOCOPY NUMBER, -- added by spamujul for ER#8473903
		    p_cid			IN	NUMBER) IS

	    v_party_in_sql		 Number := 0;
	    v_acct_in_sql		 Number := 0;
	    v_employee_in_sql	 Number := 0;
	    v_psite_in_sql		 Number := 0;  -- Added by spamujul for ER#8473903

	    val				 VARCHAR2(240) := null;
	    curr_code			 VARCHAR2(15)  := null;
	    grd				 VARCHAR2(3)   := null;
	    cid				 NUMBER        := null;
	    dummy				 NUMBER;

	    Rng_h_v			Varchar2(240);
	    Rng_l_v			Varchar2(240);
	    Result				Varchar2(3);


	    --l_period_date	Date := NULL;
	    l_for_insert			varchar2(1) := 'Y';
	    l_for_party			varchar2(1) := 'Y';
	    l_for_psite			varchar2(1) := 'N'; -- Added by spamujul for ER#8473903

	    v_rating_code		Varchar2(240);
	    v_color_code		 Varchar2(240);

	    v_party_count		Number := 0;
	    v_account_count		Number := 0;
	    v_psite_count		Number := 0; -- Added by spamujul for ER#8473903
	    v_val				Number := 0;
	    v_format_date		DATE;

	  Cursor val_crs1 IS
	     Select check_rating_grade,
			rating_code,
			color_code
	     From csc_prof_check_ratings
	     Where check_id = p_chk_id
	     And ( nvl(Range_Low_Value,val) <= v_val AND
		   nvl(Range_High_Value,val) >= v_val );

	  Cursor val_crs2 IS
	     Select check_rating_grade,
			rating_code,
			color_code
	     From csc_prof_check_ratings
	     Where check_id = p_chk_id
	     And ( nvl(Range_Low_Value,val) <= val AND
		   nvl(Range_High_Value,val) >= val );

/* This Cursor added for BUG 1534103 - VIS115P: THRESHOLD FUNCTIONALITY IS NOT WORKING. */
	   Cursor val_crs3 IS
	     Select Range_Low_Value,
			Range_High_Value
	     From   csc_prof_check_ratings
	     Where  check_id = p_chk_id
	     and    check_rating_grade=p_thd_grade;

/*
     -- for party level
     Cursor party_check_crs IS
	Select count(*)
	From csc_prof_check_results
	Where check_id = p_chk_id
	And party_id = p_party_id
	And cust_account_id IS NULL;

     -- for account level
     Cursor account_check_crs IS
	Select count(*)
	From csc_prof_check_results
	Where check_id = p_chk_id
	And party_id = p_party_id
	And cust_account_id = p_acct_id;
*/
BEGIN
	IF (p_sel_type = 'B') THEN
		Begin
		    -- P_CID is the Cursor to avoid reparsing the sql stmt
		    -- P_CID would not be null when engine runs for more than 1 party (e.g. evaluate_checks1)
		    -- P_CID would be null when engine is being run for 1 party (e.g. evaluate_checks2)
			    -- added for 1850508
			    if p_cid is null then
				cid := dbms_sql.open_cursor;
				dbms_sql.parse(cid, p_sql_stmt, dbms_sql.native);
				dbms_sql.define_column(cid,1,val,240);
			    else
				cid := p_cid;
			    end if;
			  IF p_sql_stmt IS NOT NULL Then
			      v_party_in_sql		:= INSTR(lower(p_sql_stmt),':party_id',1);
			      v_acct_in_sql			:= INSTR(lower(p_sql_stmt),':cust_account_id',1);
			      v_employee_in_sql	:= INSTR(lower(p_sql_stmt),':employee_id',1);
			      v_psite_in_sql		:= INSTR(lower(p_sql_stmt),':party_site_id',1);  -- Added by spamujul for ER#8473903
			  Else
			      v_party_in_sql		:= 0;
			      v_acct_in_sql			:= 0;
			       v_employee_in_sql	:= 0;
			       v_psite_in_sql		:= 0;  -- Added by spamujul for ER#8473903
			  End if;
         -- For Bug 1935015 commented this if statement and created 2 variables
			if p_check_level='PARTY' OR p_check_level = 'CONTACT' then
			    if v_party_in_sql  > 0 then
				dbms_sql.bind_variable(cid, ':party_id', p_party_id);
			    end if;
			    if v_acct_in_sql  > 0 then
				dbms_sql.bind_variable(cid, ':cust_account_id',p_acct_id);
			    end if;
			elsif p_check_level='ACCOUNT' then
			    if v_party_in_sql  > 0 then
				dbms_sql.bind_variable(cid, ':party_id', p_party_id);
			    end if;
			    if v_acct_in_sql  > 0 then
				dbms_sql.bind_variable(cid, ':cust_account_id',p_acct_id);
			    end if;
			   /* R12 Employee HelpDesk Modifications */
			elsif p_check_level='EMPLOYEE' then
			    if v_employee_in_sql  > 0 then
				dbms_sql.bind_variable(cid, ':employee_id', p_party_id);
			    end if;
			  -- Begin Fix by spamujul  for ER#8473903
			  ELSIF p_check_level='SITE' THEN
				IF v_psite_in_sql  > 0 THEN
					dbms_sql.bind_variable(cid, ':party_site_id', p_psite_id);
	   		       END IF;
				IF v_party_in_sql  > 0 THEN
					dbms_sql.bind_variable(cid, ':party_id', p_party_id);
			        END IF;
			  -- End Fix by spamujul  for ER#8473903
			 END IF;
			dummy := dbms_sql.execute_and_fetch(cid);
		     /* added the below condition for bug 3787383 */
		     IF dummy > 0 THEN
		       dbms_sql.column_value(cid,1,val);
		     ELSE
		       val := NULL;
		     END IF;
		    if p_cid is null then
			dbms_sql.close_cursor(cid);
		    end if;
--	  END IF;
	Exception
	  When Others then
		if p_cid is null then
			IF (dbms_sql.is_open(cid)) THEN
			    dbms_sql.close_cursor(cid);
			END IF;
		end if;
		val := '0';
	End;
	 ELSIF (p_sel_type = 'T') THEN
		Begin
    		-- added for 1850508
			   if (p_cid is null) then
				cid := dbms_sql.open_cursor;
				dbms_sql.parse(cid, p_rule, dbms_sql.native);
			   else
				cid := p_cid;
			   end if;
			     -- for Bug 1935015 changed instr(sql_stmt..) to INSTR(lower(sql_stmt)..)
			  IF p_rule IS NOT NULL Then
			      v_party_in_sql		:= INSTR(lower(p_rule),':party_id',1);
			      v_acct_in_sql			:= INSTR(lower(p_rule),':cust_account_id',1);
			       v_employee_in_sql	:= INSTR(lower(p_rule),':employee_id',1);
			        v_psite_in_sql		:= INSTR(lower(p_rule),':party_site_id',1);  -- Added by spamujul for ER#8473903
			  Else
			      v_party_in_sql		:= 0;
			      v_acct_in_sql			:= 0;
			       v_employee_in_sql	:= 0;
			       v_psite_in_sql		:= 0;  -- Added by spamujul for ER#8473903
			  End if;
			   IF p_check_level='PARTY' OR p_check_level = 'CONTACT' THEN
				 if v_party_in_sql  > 0 then
					 dbms_sql.bind_variable(cid, ':party_id', p_party_id);
				 end if;
				 if v_acct_in_sql  > 0 then
					 dbms_sql.bind_variable(cid, ':cust_account_id',p_acct_id);
				 end if;
			   ELSIF p_check_level='ACCOUNT' then
				 if v_party_in_sql  > 0 then
					 dbms_sql.bind_variable(cid, ':party_id', p_party_id);
				 end if;

				 if v_acct_in_sql  > 0 then
					 dbms_sql.bind_variable(cid, ':cust_account_id', p_acct_id);
				 end if;
				 /* R12 Employee HelpDesk Modifications */
			    ELSIF p_check_level='EMPLOYEE' then
				if v_employee_in_sql  > 0 then
					dbms_sql.bind_variable(cid, ':employee_id', p_party_id);
				    end if;
			   -- Begin Fix by spamujul  for ER#8473903
			  ELSIF p_check_level='SITE' THEN
				IF v_psite_in_sql  > 0 THEN
					dbms_sql.bind_variable(cid, ':party_site_id', p_psite_id);
	   		       END IF;
				IF v_party_in_sql  > 0 THEN
					dbms_sql.bind_variable(cid, ':party_id', p_party_id);
			        END IF;
			  -- End Fix by spamujul  for ER#8473903
			   END IF;
		           val := dbms_sql.execute_and_fetch(cid); -- returns 0 if no rows found
			    -- added for 1850508
			   if (p_cid is null) then
				dbms_sql.close_cursor(cid);
			   end if;
		Exception
			   When Others THEN
				if (p_cid is null) then
					IF (dbms_sql.is_open(cid)) THEN
						dbms_sql.close_cursor(cid);
					end if;
				end if;
				val := null;
			End;
	END IF;
/* This condition added for BUG 1534103 - VIS115P: THRESHOLD FUNCTIONALITY IS NOT WORKING. */

	IF (p_sel_type = 'B') and (p_data_type IN ('NUMBER', 'DATE')) THEN
	     IF p_data_type = 'NUMBER' Then
		   IF val IS NULL Then
			val := '0';
		   END IF;
		   OPEN val_crs3;
			   FETCH val_crs3
			   INTO Rng_l_v,
				    rng_h_v;
			   IF val_crs3%notfound THEN
				Result := 'Y';
			   END IF;
		  CLOSE val_crs3;
		If p_chk_u_l_flag ='U' Then
			If to_number(val)>to_number(rng_h_v) then
				Result:='Y';
		        Else
				Result:='N';
	                End If;
		Elsif p_chk_u_l_flag ='L' Then
		       If to_number(val)<to_number(rng_l_v) then
			  Result:='Y';
			Else
			  Result:='N';
			End If;
	          Else
			Result:='N';
	        End If;
	    ELSE
		/* added the below code for bug 4071727 */
		OPEN val_crs3;
			FETCH val_crs3
			INTO Rng_l_v,
				 rng_h_v;
			   IF val_crs3%notfound THEN
				Result := 'Y';
			   END IF;
		CLOSE val_crs3;
	          /* added till here for bug 4071727 */
		If val is not null then
			If p_chk_u_l_flag ='U' Then
				/* added to_date for bug 4071727 */
		           If to_Date(val, 'DD-MM-RRRR') > to_date(rng_h_v, 'DD-MM-RRRR') Then
				  Result:='Y';
	                   Else
				  Result:='N';
			   End If;
	               Elsif p_chk_u_l_flag ='L' Then
				 /* added to_date for bug 4071727 */
			  If to_Date(val, 'DD-MM-RRRR') < to_Date(rng_l_v, 'DD-MM-RRRR') Then
			       Result:='Y';
			   Else
			       Result:='N';
			   End If;
		       Else
			   Result:='N';
		       End If;
		End if;
        END IF;
  -- ELSE
   --     grd := NULL;
   END IF;
/* Condition for BUG 1534103 - VIS115P: THRESHOLD FUNCTIONALITY IS NOT WORKING. ended*/
   IF (p_sel_type = 'B') and (p_data_type IN ('NUMBER', 'DATE')) THEN
	IF p_data_type = 'NUMBER' Then
	   IF val IS NULL Then
		val := '0';
	   END IF;
	   v_val := to_number(val);
	   val := to_char(v_val);
	   OPEN val_crs1;
		     FETCH val_crs1
		     INTO grd,
			      v_rating_code,
			      v_color_code;
		   IF val_crs1%notfound THEN
			grd := NULL;
			/* added for Bug 2227062 */
			v_rating_code := NULL;
			v_color_code := NULL;
		   END IF;
	   CLOSE val_crs1;
	ELSE
	      IF val is not null then
		     OPEN val_crs2;
		     FETCH val_crs2 INTO grd,v_rating_code,v_color_code;
		     IF val_crs2%notfound THEN
			grd := NULL;
			/* added for Bug 2227062 */
			v_rating_code := NULL;
			v_color_code := NULL;
		     END IF;
		     CLOSE val_crs2;
	    END IF;
	END IF;
   ELSE
	  grd := NULL;
   END IF;
   -- Only convert to format mask if result is not True/False
   IF ((p_sel_type = 'B') AND (curr_code IS NULL)) THEN
      IF (p_fmt_mask IS NOT NULL) THEN
	 IF (p_data_type = 'NUMBER') THEN
	    val := To_char(To_number(val), p_fmt_mask);
         ELSIF (p_data_type = 'DATE') THEN
            BEGIN
               /* modified the to_date to RRRR format for bug 4177903 */
               v_format_date := to_date(val, 'DD-MM-RRRR');
               val := To_char(v_format_date, p_fmt_mask);
            EXCEPTION
               WHEN OTHERS THEN
                  val := null;
            END;
         END IF;
      END IF;
   ELSIF (p_sel_type = 'T') THEN
      IF (val > 0) THEN
	 val := 'Y';
       ELSE
	 val := 'N';
      END IF;
   END IF;
	BEGIN
		IF p_psite_id  IS NULL THEN  -- Added by spamujul for ER#8473903
			IF p_acct_id IS NULL THEN
				 IF p_truncate_flag = 'N' THEN
					   begin
					     select 1 into v_party_count
					     from csc_prof_check_results
					     where check_id = p_chk_id
					     and party_id = p_party_id
					     and cust_account_id is null
					     and party_site_id is null  -- Added by spamujul for ER#8473903
					     ;
					   exception when no_data_found then
					       v_party_count := 0;
					   when others then
					       v_party_count := null;
					  end;
					/*
						    OPEN party_check_crs;
						    FETCH party_check_crs INTO v_party_count;
						    IF party_check_crs%notfound THEN
						       v_party_count := 0;
						    END IF;
						    CLOSE party_check_crs;
					*/
				ELSE
					v_party_count := 0;
				END IF;
				 IF v_party_count = 0 THEN
					    p_ip_total := p_ip_total + 1;
					    -- assign values to insert party check results
					    ip_check_id(p_ip_total) := p_chk_id;
					    ip_party_id(p_ip_total) := p_party_id;
					    ip_account_id(p_ip_total) := NULL;
					    ip_psite_id(p_ip_total)   := NULL; -- Added by spamujul for ER#8473903
					    ip_value(p_ip_total) := val;
					    ip_currency(p_ip_total) := curr_code;
					    ip_grade(p_ip_total) := grd;
					    ip_rating_code(p_ip_total) :=v_rating_code;
					    ip_color_code(p_ip_total) :=v_color_code;
					    ip_results(p_ip_total) := result;
					    IF p_ip_total = 1000 THEN
						l_for_insert := 'Y';
						l_for_party  := 'Y';
						l_for_psite  :='N'; -- Added by spamujul for ER#8473903
						Insert_Update_Check_Results(p_ip_total,
												 l_for_insert,
												 l_for_party
											       , l_for_psite  -- Added by spamujul for ER#8473903
												 );
						p_ip_total :=0;
					    END IF;
				 ELSIF v_party_count = 1 THEN
					    p_up_total := p_up_total + 1;

					    -- assign values to update party check results
					    up_check_id(p_up_total) := p_chk_id;
					    up_party_id(p_up_total) := p_party_id;
					    up_account_id(p_up_total) := NULL;
					     up_psite_id(p_up_total)  := NULL; -- Added by spamujul for ER#8473903
					    up_value(p_up_total) := val;
					    up_currency(p_up_total) := curr_code;
					    up_grade(p_up_total) := grd;
					    up_rating_code(p_up_total) :=v_rating_code;
					    up_color_code(p_up_total) :=v_color_code;
					    up_results(p_up_total) := result;
					    IF p_up_total = 1000 THEN
						l_for_insert := 'N';
						l_for_party  := 'Y';
						l_for_psite  :='N';  -- Added by spamujul for ER#8473903
						Insert_Update_Check_Results(p_up_total,
												  l_for_insert,
												  l_for_party
												 ,l_for_psite  -- Added by spamujul for ER#8473903
												  );
						p_up_total := 0;
					    END IF;

				 END IF;
			ELSE
				 IF p_truncate_flag = 'N' THEN
				    begin
					      select 1 into v_account_count from csc_prof_check_results
					      where check_id = p_chk_id
					      and party_id = p_party_id
					      and party_site_id is null  -- Added by spamujul for ER#8473903
					      and CUST_ACCOUNT_ID =p_acct_id;  -- Bug 5255227 Fix
				     Exception
						when no_data_found then
						      v_account_count := 0;
			  		        when TOO_MANY_ROWS then
							v_account_count := 1;
		   			        when others then
							v_account_count := null;
				    end ;
			/*
				    OPEN account_check_crs;
				    FETCH account_check_crs INTO v_account_count;
				    IF account_check_crs%notfound THEN
				       v_account_count := 0;
				    END IF;
				    CLOSE account_check_crs;
			*/
				 ELSE
				   v_account_count := 0;
				 END IF;

				 IF v_account_count = 0 THEN
					    p_ia_total := p_ia_total + 1;
					    -- assign values to insert
					    ia_check_id(p_ia_total) := p_chk_id;
					    ia_party_id(p_ia_total) := p_party_id;
					    ia_account_id(p_ia_total) := p_acct_id;
					    ia_psite_id(p_ia_total)   := NULL; -- Added by spamujul for ER#8473903
					    ia_value(p_ia_total) := val;
					    ia_currency(p_ia_total) := curr_code;
					    ia_grade(p_ia_total) := grd;
					    ia_rating_code(p_ia_total) := v_rating_code;
					    ia_color_code(p_ia_total) := v_color_code;
					    ia_results(p_ia_total) := result;

					    IF p_ia_total = 1000 THEN
						l_for_insert := 'Y';
						l_for_party  := 'N';
						l_for_psite  := 'N';  -- Added by spamujul for ER#8473903
						Insert_Update_Check_Results(p_ia_total,
												l_for_insert,
												l_for_party
											       ,l_for_psite  -- Added by spamujul for ER#8473903
												);
						p_ia_total := 0;
					    END IF;

				 ELSIF v_account_count = 1 THEN
					    p_ua_total := p_ua_total + 1;

					    -- assign values to update party tables
					    ua_check_id(p_ua_total) := p_chk_id;
					    ua_party_id(p_ua_total) := p_party_id;
					    ua_account_id(p_ua_total) := p_acct_id;
					    ua_psite_id(p_ua_total)   := NULL; -- Added by spamujul for ER#8473903
					    ua_value(p_ua_total) := val;
					    ua_currency(p_ua_total) := curr_code;
					    -- This is a Bug fix for 1934720, changing p_ia_total to p_ua_total
					    ua_grade(p_ua_total) := grd;
					    ua_rating_code(p_ua_total) := v_rating_code;
					    ua_color_code(p_ua_total) := v_color_code;
					    ua_results(p_ua_total) := result;
					    IF p_ua_total = 1000 THEN
						l_for_insert := 'N';
						l_for_party  := 'N';
						l_for_psite  := 'N';   -- Added by spamujul for ER#8473903
						Insert_Update_Check_Results (p_ua_total,
												  l_for_insert,
												  l_for_party
											         ,l_for_psite -- Added by spamujul for ER#8473903
												  );
						p_ua_total := 0;
					    END IF;

				END IF;
			END IF;
-- Begin Fix by spamujul  for ER#8473903
		ELSE
			Begin
			     IF p_truncate_flag = 'N' THEN
				begin
					select 1 into v_psite_count
					from csc_prof_check_results
					where check_id = p_chk_id
					and party_id = p_party_id
					and cust_account_id is null
					and party_site_id =p_psite_id;
					Exception when no_data_found then
						v_psite_count := 0;
					  when others then
						v_psite_count := null;
					end;
				ELSE
						v_psite_count := 0;
				END IF;
			IF v_psite_count = 0 THEN
				p_is_total := p_is_total + 1;
				is_check_id(p_is_total) := p_chk_id;
				is_party_id(p_is_total) := p_party_id;
				is_account_id(p_is_total) := NULL;
				is_psite_id(p_is_total)  := p_psite_id;
				is_value(p_is_total) := val;
				is_currency(p_is_total) := curr_code;
				is_grade(p_is_total) := grd;
				is_rating_code(p_is_total) :=v_rating_code;
				is_color_code(p_is_total) :=v_color_code;
				is_results(p_is_total) := result;
				IF p_is_total = 1000 THEN
					l_for_insert := 'Y';
					l_for_party  := 'N';
					l_for_psite  := 'Y';
					Insert_Update_Check_Results
							(p_is_total,
							 l_for_insert,
							 l_for_party
							 ,l_for_psite
							 );
					p_is_total :=0;
				 END IF;
			ELSIF v_psite_count = 1 THEN
				p_us_total := p_us_total + 1;
				us_check_id(p_us_total) := p_chk_id;
				us_party_id(p_us_total) := p_party_id;
				us_account_id(p_us_total) := NULL;
				us_psite_id(p_us_total) := p_psite_id;
				us_value(p_us_total) := val;
				us_currency(p_us_total) := curr_code;
				us_grade(p_us_total) := grd;
				us_rating_code(p_us_total) :=v_rating_code;
				us_color_code(p_us_total) :=v_color_code;
				us_results(p_us_total) := result;
				IF p_us_total = 1000 THEN
					l_for_insert := 'N';
					l_for_party  := 'Y';
					l_for_psite  :='Y';
					Insert_Update_Check_Results(p_us_total,
								    l_for_insert,
								    l_for_party
								   ,l_for_psite
								    );
					p_us_total := 0;
				END IF;
			END IF;
			Exception
				WHEN OTHERS THEN
					IF val_crs1%isopen THEN
					   CLOSE val_crs1;
					END IF;
					IF val_crs2%isopen THEN
					   CLOSE val_crs2;
					END IF;
					if p_cid is null then
						IF (dbms_sql.is_open(cid)) THEN
						    dbms_sql.close_cursor(cid);
						END IF;
					end if;
					set_context('Evaluate_One_Check',
							'chk_id=>'||to_char(p_chk_id),
							'party_id=>'||to_char(p_party_id),
							'account_id=>'||to_char(p_acct_id),
							'party_id =>'||to_char(p_psite_id)
							,'party_site_id =>'||to_char(p_acct_id)
							);
					g_error := sqlcode || ' ' || sqlerrm;
					set_context(NULL, g_error);
			End;
	   END IF ;
	-- End Fix by spamujul  for ER#8473903
       END;
    EXCEPTION
      -- If an exception is raised, close cursor before exiting
      WHEN OTHERS THEN
	IF val_crs1%isopen THEN
	   CLOSE val_crs1;
	END IF;
	IF val_crs2%isopen THEN
	   CLOSE val_crs2;
	END IF;
/*
	IF party_check_crs%isopen THEN
	   CLOSE party_check_crs;
	END IF;
	IF account_check_crs%isopen THEN
	   CLOSE account_check_crs;
	END IF;
*/
	if p_cid is null then
		IF (dbms_sql.is_open(cid)) THEN
		    dbms_sql.close_cursor(cid);
		END IF;
	end if;
	set_context('Evaluate_One_Check',
		'chk_id=>'||to_char(p_chk_id),
		'party_id=>'||to_char(p_party_id),
		'account_id=>'||to_char(p_acct_id)
		,'party_site_id =>'||to_char(p_acct_id) -- Added by spamujul for ER#8473903
		);
	g_error := sqlcode || ' ' || sqlerrm;
	set_context(NULL, g_error);
	--table_delete;
END Evaluate_One_Check;


--
-- Evaluate_Blocks1
--   Loop through all the effective building blocks and evaluate the results
--   for each customer.
--   if block_id is null, party_id is null and account_id is null
--
PROCEDURE Evaluate_Blocks1 (     p_up_total		IN	OUT NOCOPY NUMBER ,
								    p_ip_total		IN	OUT NOCOPY NUMBER ,
								    p_ua_total		IN	OUT NOCOPY NUMBER ,
								    p_ia_total		IN	OUT NOCOPY NUMBER ,
								    p_us_total		IN	OUT NOCOPY NUMBER, -- added by spamujul for ER#8473903
								    p_is_total		IN	OUT NOCOPY NUMBER -- added by spamujul for ER#8473903
							    ) IS

				  blk_id			NUMBER;
				  blk_name		Varchar2(240);
				  sql_stmt		Varchar2(2000);
				  curr_code		Varchar2(15);
				  bparty_id		Number;
				  bacct_id		Number;
				  bpsite_id		Number;  -- Added by spamujul for ER#8473903
				  truncate_flag	Varchar2(1)	:=	'N';
				  l_for_insert		varchar2(1)	:=	'Y';
				  l_for_party		varchar2(1)	:=	'Y';
				  l_for_psite		Varchar2(1)	:=	'N'; -- Added by spamujul for ER#8473903
				  v_party_in_sql	Number		:= 0;
				  v_acct_in_sql	Number		:= 0;
				  v_psite_in_sql	Number		:= 0; -- Added by spamujul for ER#8473903
				/* added this variable for Bug 1937730*/
				  v_party_id            Number;
   -- cursor to run all blocks
			   CURSOR blocks_csr IS
			      SELECT block_id, sql_stmnt, currency_code
			      FROM csc_prof_blocks_b a
			      WHERE exists ( Select b.block_id
				     From csc_prof_check_rules_b b
				     where b.block_id 	      = a.block_id
					or b.expr_to_block_id = a.block_id)
			      AND  Sysdate BETWEEN Nvl(start_date_active, Sysdate)
					AND Nvl(end_date_active, Sysdate)
					AND block_level IN ('PARTY',
									     'ACCOUNT'
									     ,'SITE' -- Added by spamujul for ER#8473903
									     );
			   -- cursor to update all results of a party
			   CURSOR bparty_csr IS
			      SELECT party_id
			      FROM hz_parties
			      WHERE status='A'
			      AND  PARTY_TYPE IN ('PERSON','ORGANIZATION');
			      -- Person, ORG added for 1850508

			   -- cursor to update all results of an account
			/* added this condition party_id=v_party_id for Bug 1937730*/
			   CURSOR baccount_csr IS
			      SELECT party_id, cust_account_id
			      FROM hz_cust_accounts
			      WHERE  party_id=v_party_id
			      AND  status = 'A' ;

		-- Begin fix by spamujul for NCR ER#8473903
		    CURSOR bpsite_csr IS
		      SELECT party_id, party_site_id
		      FROM hz_party_sites
		      WHERE  party_id=v_party_id
		      AND  status = 'A'
		      AND NVL(created_by_module,'XXX') <> 'SR_ONETIME';
		-- End fix by spamujul for NCR ER#8473903
			    -- added for 1850508
			cid 				number;
			val		VARCHAR2(240) := null;

BEGIN
		  -- Loop through blocks for party level
		  BEGIN
				OPEN blocks_csr;
					    LOOP
						      FETCH blocks_csr
						      INTO blk_id,
								sql_stmt,
								curr_code;
						      EXIT WHEN blocks_csr%notfound;
							-- for Bug 1935015 changed instr(sql_stmt..) to INSTR(lower(sql_stmt)..)
						      v_party_in_sql := INSTR(lower(sql_stmt),':party_id',1);
						      v_acct_in_sql  := INSTR(lower(sql_stmt),':cust_account_id',1);
						      v_psite_in_sql  := INSTR(lower(sql_stmt),':party_site_id',1); -- Added by spamujul for ER#8473903
							/* This begin, end exception is added mainly for exception handing for Bug 19800
							04*/
							Begin
								   -- IF ((v_party_in_sql <> 0) and (v_acct_in_sql <> 0)) Then
								   -- Loop through per party
								   -- added for 1850508
								   -- dbms_output.put_line('Evaluate blocks1  Opening and Parsing.PARTY Level.'||to_char(blk_id));
								   cid := dbms_sql.open_cursor;
								   dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
								   dbms_sql.define_column(cid, 1, val, 240);
								  OPEN bparty_csr;
								  	      LOOP
											FETCH bparty_csr
											INTO bparty_id;
											EXIT WHEN bparty_csr%notfound;
											Evaluate_One_Block(truncate_flag,
															 blk_id,
															 bparty_id,
															null,
															NULL, -- added by spamujul for ER#8473903
															sql_stmt,
															curr_code,
															p_up_total,
															p_ip_total,
															p_ua_total,
															p_ia_total,
															p_us_total,-- added by spamujul for ER#8473903
															p_is_total,-- added by spamujul for ER#8473903
															cid
															);
															 /* added this condition for Bug 1937730*/
											v_party_id:=bparty_id;
											If (v_acct_in_sql <> 0)  then -- added for 1850508
												      -- If acct is not present as bind variable, the sql might return wrong
												      -- rows (party level counts) at account leve.
												      --p_old_block_id:=null;

												      -- dbms_output.put_line('Evaluate blocks1  Opening and Parsing. ACCTLevel.'||to_char(blk_id));
												     OPEN baccount_csr;
														 LOOP
															   FETCH baccount_csr
																INTO bparty_id, bacct_id;
																 EXIT WHEN baccount_csr%notfound;
																   Evaluate_One_Block(truncate_flag,
																				     blk_id,
																				     bparty_id,
																				      bacct_id,
																				      NULL, -- added by spamujul for ER#8473903
																				      sql_stmt,
																				      curr_code,
																				      p_up_total,
																				      p_ip_total,
																				      p_ua_total,
																				      p_ia_total,
																				      p_us_total,-- added by spamujul for ER#8473903
																				      p_is_total,-- added by spamujul for ER#8473903
																				      cid);
														END LOOP;
												CLOSE baccount_csr;
											END IF; -- added for 1850508
											 -- Begin fix by spamujul for NCR ER# 8473903
											    Begin
												   bparty_id :=0;
												   IF (v_psite_in_sql <> 0)  THEN
													       cid := dbms_sql.open_cursor;
													       dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
													       dbms_sql.define_column(cid, 1, val, 240);
													       v_party_id := bparty_id;
													       OPEN bpsite_csr;
													       LOOP
														   FETCH bpsite_csr
														   INTO bparty_id, bpsite_id;
														   EXIT WHEN bpsite_csr%notfound;
														   Evaluate_One_Block(truncate_flag,
																		    blk_id,
																		    bparty_id,
																		    NULL,
																		    bpsite_id,
																		    sql_stmt,
																		    curr_code,
																		    p_up_total,
																		    p_ip_total,
																		    p_ua_total,
																		    p_ia_total,
																		    p_us_total,
																		    p_is_total
																		    ,cid);
													      END LOOP;
													      CLOSE bpsite_csr;
													      IF (dbms_sql.is_open(cid)) THEN
														      dbms_sql.close_cursor(cid);
													      End if;
													END IF;
											    Exception
												When others then
												  IF (dbms_sql.is_open(cid)) THEN
														      dbms_sql.close_cursor(cid);
												  End if;
												  set_context('Evaluate_Blocks2', blk_id, bparty_id,bpsite_id);
												  g_error := sqlcode || ' ' || sqlerrm;
												  set_context(NULL, g_error);
											    End;
											    IF p_is_total <> 0 THEN
												l_for_insert := 'Y';
												l_for_party  := 'N';
												l_for_psite  := 'Y';
												Insert_Update_Block_Results(p_is_total,
																		l_for_insert,
																		l_for_party
																		,l_for_psite
																		);
												p_is_total :=0;
											 END IF;
											IF p_us_total <> 0 THEN
												l_for_insert := 'N';
												l_for_party  := 'N';
												l_for_psite  := 'Y';
												Insert_Update_Block_Results 	(p_us_total,
																		 l_for_insert,
																		 l_for_party
																		 ,l_for_psite
																		 );
												p_us_total :=0;
											END IF;
										-- End fix by spamujul for NCR ER# 8473903
								 END LOOP;
						    CLOSE bparty_csr;
						    IF (dbms_sql.is_open(cid)) THEN
								dbms_sql.close_cursor(cid);
						    end if;
						    -- END IF
					Exception
							When others then
								  IF (dbms_sql.is_open(cid)) THEN
								      dbms_sql.close_cursor(cid);
								  end if;
							          set_context('Evaluate_Blocks1', blk_id, bparty_id);
								   g_error := sqlcode || ' ' || sqlerrm;
								   set_context(NULL, g_error);
					 End;
			END LOOP;
		   CLOSE blocks_csr;
		   -- check if there are still records to be inserted
		   IF p_ip_total <> 0 THEN
			l_for_insert	 := 'Y';
			l_for_party	 := 'Y';
			l_for_psite	 := 'N';	 -- Added by spamujul for ER#8473903
			Insert_Update_Block_Results	(p_ip_total,
									  l_for_insert,
									  l_for_party
									  ,l_for_psite  -- Added by spamujul for ER#8473903
									  );
			p_ip_total :=0;
		   END IF;
		   -- check if there are still records to be updated
		   IF p_up_total <> 0 THEN
			l_for_insert := 'N';
			l_for_party  := 'Y';
			Insert_Update_Block_Results(p_up_total,
									l_for_insert,
									l_for_party
									,l_for_psite  -- Added by spamujul for ER#8473903
									);
			p_up_total :=0;
		   END IF;
		  EXCEPTION
				      WHEN OTHERS THEN
				       IF (blocks_csr%isopen) THEN
					  CLOSE blocks_csr;
				       END IF;
				       IF (bparty_csr%isopen) THEN
					   CLOSE bparty_csr;
				       END IF;
				       IF (baccount_csr%isopen) THEN
					   CLOSE baccount_csr;
				       END IF;
				       -- Begin fix by spamujul for  ER#8473903
					IF (bpsite_csr%isopen) THEN
					   CLOSE bpsite_csr;
				       END IF;
				       -- End fix by spamujul for ER#8473903
				       set_context('Evaluate_Blocks', blk_id, bparty_id);
				       g_error := sqlcode || ' ' || sqlerrm;
				       set_context(NULL, g_error);
				       --set_context(NULL, Sqlerrm);
				       table_delete;
				       RAISE;
				END;
   -- check if there are still records to be inserted
		   IF p_ia_total <> 0 THEN
			l_for_insert := 'Y';
			l_for_party  := 'N';
			l_for_psite	 := 'N';	 -- Added by spamujul for ER#8473903
			Insert_Update_Block_Results(p_ia_total,
									l_for_insert,
									l_for_party
									,l_for_psite  -- Added by spamujul for ER#8473903
									);
			p_ia_total :=0;
		   END IF;

		   -- check if there are still records to be updated
		   IF p_ua_total <> 0 THEN
			l_for_insert := 'N';
			l_for_party  := 'N';
			l_for_psite	 := 'N';	 -- Added by spamujul for ER#8473903
			Insert_Update_Block_Results	(p_ua_total,
									l_for_insert,
									l_for_party
									,l_for_psite  -- Added by spamujul for ER#8473903
									);
			p_ua_total :=0;
		   END IF;
END Evaluate_Blocks1;

--  This procedure evaluates the blocks
--  for which the batch sql statement is NULL and select_type is 'B' (Variable)
PROCEDURE Evaluate_Blocks1_No_Batch (    p_up_total	 IN OUT NOCOPY NUMBER ,
										    p_ip_total		IN OUT NOCOPY NUMBER ,
										    p_ua_total		IN OUT NOCOPY NUMBER ,
										    p_ia_total		IN OUT NOCOPY NUMBER,
										    p_us_total		IN OUT NOCOPY NUMBER, -- added by spamujul for ER#8473903
										    p_is_total		IN OUT NOCOPY NUMBER -- added by spamujul for ER#8473903
										) IS

			  blk_id			Number;
			  blk_name		Varchar2(240);
			  sql_stmt		Varchar2(2000);
			  curr_code		Varchar2(15);
			  bparty_id		Number;
			  bacct_id		Number;
			  bpsite_id		Number; -- added by spamujul for ER#8473903
			  truncate_flag	Varchar2(1)	:= 'N';

			  l_for_insert		varchar2(1)	:= 'Y';
			  l_for_party		varchar2(1)	:= 'Y';
			  l_for_psite		Varchar2(1)	:='N';-- added by spamujul for ER#8473903

			  v_party_in_sql	Number		:= 0;
			  v_acct_in_sql	Number		:= 0;
			  v_psite_in_sql	Number		:= 0; -- added by spamujul for ER#8473903
			  v_party_id            Number;

-- cursor to run all blocks for all checks present in that group
		   CURSOR blocks_csr IS
		      SELECT block_id, sql_stmnt, currency_code
			FROM csc_prof_blocks_b a
		       WHERE EXISTS ( SELECT null
					FROM csc_prof_checks_b b
				       WHERE b.select_block_id = a.block_id
					 AND b.select_type = 'B'
					 AND check_id IN (SELECT check_id FROM csc_prof_group_checks))
			 AND  SYSDATE BETWEEN Nvl(start_date_active, SYSDATE)
					  AND Nvl(end_date_active, SYSDATE)
			 AND  batch_sql_stmnt IS NULL;

-- cursor to update all results of a party
			   CURSOR bparty_csr IS
			      SELECT party_id
			      FROM hz_parties
			      WHERE status='A'
			      AND  PARTY_TYPE IN ('PERSON','ORGANIZATION');

-- cursor to update all results of an account
			   CURSOR baccount_csr IS
			      SELECT party_id, cust_account_id
			      FROM hz_cust_accounts
			      WHERE  party_id=v_party_id
			      AND  status = 'A' ;

			  -- Begin fx by spamujul for ER#8473903
			CURSOR bpsite_csr IS
				 SELECT party_id,
					party_site_id
			  FROM   HZ_PARTY_SITES
			  WHERE party_id = v_party_id
			      AND status ='A'
			      AND NVL(created_by_module,'XXX') <>'SR_ONETIME';
			-- End fx by spamujul for ER#8473903

		    cid 		number;
		    val		VARCHAR2(240) := null;

BEGIN
		 -- Loop through blocks for party level
		BEGIN
			OPEN blocks_csr;
					LOOP
					         FETCH blocks_csr
						 INTO blk_id, sql_stmt, curr_code;
					         EXIT WHEN blocks_csr%notfound;
						v_party_in_sql	:=	INSTR(lower(sql_stmt),':party_id',1);
					        v_acct_in_sql	:=	INSTR(lower(sql_stmt),':cust_account_id',1);
    					        v_psite_in_sql	:=	INSTR(lower(sql_stmt),':party_site_id',1);  -- added by spamujul for ER#8473903
						Begin
							    cid := dbms_sql.open_cursor;
							    dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
							    dbms_sql.define_column(cid, 1, val, 240);
							   OPEN bparty_csr;
									 LOOP
										FETCH bparty_csr
										INTO bparty_id;
										EXIT WHEN bparty_csr%notfound;
									       Evaluate_One_Block(truncate_flag,
														blk_id,
														bparty_id,
														null,
														NULL, -- added by spamujul for ER#8473903
														sql_stmt,
														curr_code,
														p_up_total,
														p_ip_total,
														p_ua_total,
														p_ia_total,
														p_us_total,-- added by spamujul for ER#8473903
														p_is_total,-- added by spamujul for ER#8473903
														cid);
										v_party_id:=bparty_id;
										If (v_acct_in_sql <> 0)  then
											OPEN baccount_csr;
												LOOP
													FETCH baccount_csr
													INTO bparty_id, bacct_id;
													EXIT WHEN baccount_csr%notfound;
													 Evaluate_One_Block(truncate_flag,
																      blk_id,
																      bparty_id,
																      bacct_id,
																      NULL, -- added by spamujul for ER#8473903
																      sql_stmt,
																      curr_code,
																      p_up_total,
																      p_ip_total,
																      p_ua_total,
																      p_ia_total,
																      p_us_total,-- added by spamujul for ER#8473903
																      p_is_total,-- added by spamujul for ER#8473903
																      cid);
												END LOOP;
										CLOSE baccount_csr;
									END IF; -- added for 1850508
									-- Begin fix by spamujul for ER#8473903
										v_party_id:=bparty_id;
										 If (v_psite_in_sql <> 0)  then
											OPEN bpsite_csr;
													LOOP
													     FETCH bpsite_csr
													      INTO bparty_id,
															bpsite_id;
													     EXIT WHEN bpsite_csr%notfound;
													     Evaluate_One_Block(truncate_flag,
																	       blk_id,
																	       bparty_id,
																	       NULL,
																		bpsite_id,
																	       sql_stmt,
																	       curr_code,
																	       p_up_total,
																	       p_ip_total,
																	       p_ua_total,
																	       p_ia_total,
																	       p_us_total,
																	       p_is_total,
																	       cid);
													END LOOP;
											CLOSE bpsite_csr;
										End IF;
										-- End fix by spamujul for  ER#8473903
							END LOOP;
						CLOSE bparty_csr;
						IF (dbms_sql.is_open(cid)) THEN
							dbms_sql.close_cursor(cid);
						 end if;
						Exception
								When others then
									       IF (dbms_sql.is_open(cid)) THEN
										  dbms_sql.close_cursor(cid);
									       end if;
										set_context('Evaluate_Blocks4_No_Batch', blk_id, bparty_id);
										g_error := sqlcode || ' ' || sqlerrm;
										set_context(NULL, g_error);
						 End;
					 END LOOP;
				CLOSE blocks_csr;
			   -- check if there are still records to be inserted
			      IF p_ip_total <> 0 THEN
				 l_for_insert		:= 'Y';
				 l_for_party		:= 'Y';
				 l_for_psite		:='N'; -- Added by spamujul for ER#8473903
				 Insert_Update_Block_Results	(p_ip_total,
										  l_for_insert,
										  l_for_party
										  ,l_for_psite  -- Added by spamujul for ER#8473903
										  );
				 p_ip_total :=0;
			      END IF;
			   -- check if there are still records to be updated
			      IF p_up_total <> 0 THEN
				 l_for_insert := 'N';
				 l_for_party  := 'Y';
				 l_for_psite		:='N'; -- Added by spamujul for ER#8473903
				 Insert_Update_Block_Results(p_up_total,
										l_for_insert,
										l_for_party
										,l_for_psite  -- Added by spamujul for ER#8473903
										);
				 p_up_total :=0;
			      END IF;
		   EXCEPTION
				      WHEN OTHERS THEN
							IF (blocks_csr%isopen) THEN
								CLOSE blocks_csr;
							END IF;
							IF (bparty_csr%isopen) THEN
								CLOSE bparty_csr;
							END IF;
							IF (baccount_csr%isopen) THEN
								CLOSE baccount_csr;
							 END IF;
							 -- Begin fix by spamujul for ER#8473903
							IF (bpsite_csr%isopen) THEN
								CLOSE bpsite_csr;
							 END IF;
							 -- End fix by spamujul for  ER#8473903
							 IF (dbms_sql.is_open(cid)) THEN
							    dbms_sql.close_cursor(cid);
							 end if;
							 set_context('Evaluate_Blocks4_No_Batch', blk_id, bparty_id);
							 g_error := sqlcode || ' ' || sqlerrm;
							 set_context(NULL, g_error);
							 table_delete;
							RAISE;
				 END;
			   -- check if there are still records to be inserted
			   IF p_ia_total <> 0 THEN
				l_for_insert		:= 'Y';
				l_for_party		:= 'N';
				l_for_psite		:='N'; -- Added by spamujul for ER#8473903
				Insert_Update_Block_Results	(p_ia_total,
										l_for_insert,
										l_for_party
										,l_for_psite  -- Added by spamujul for ER#8473903
										);
				p_ia_total :=0;
			   END IF;

			   -- check if there are still records to be updated
			   IF p_ua_total <> 0 THEN
				l_for_insert		:= 'N';
				l_for_party		:= 'N';
				l_for_psite		:='N'; -- Added by spamujul for ER#8473903
				Insert_Update_Block_Results	(p_ua_total,
										l_for_insert,
										l_for_party
										,l_for_psite  -- Added by spamujul for ER#8473903
										);
				p_ua_total :=0;
			   END IF;
			 -- Begin fix by spamujul for ER#8473903
			 IF p_is_total <> 0 THEN
			l_for_insert		:= 'Y';
			l_for_party		 := 'N';
			l_for_psite		:= 'Y';
			Insert_Update_Block_Results(p_is_total,
									l_for_insert,
									l_for_party
									,l_for_psite
									);
			p_is_total :=0;
		   END IF;
		   IF p_us_total <> 0 THEN
			l_for_insert		:= 'N';
			l_for_party		:= 'N';
			l_for_psite		:= 'Y';
			Insert_Update_Block_Results(p_us_total,
									l_for_insert,
									l_for_party
									,l_for_psite
									);
			p_us_total :=0;
		   END IF;
		-- End  fix by spamujul for ER#8473903
END Evaluate_Blocks1_No_Batch;
--
-- Evaluate_Blocks2
--   Loop through all the effective building blocks and evaluate the results
--   for given customer.
--   if block_id is not null, party_id is not null or account_id is not null
--
PROCEDURE Evaluate_Blocks2 ( p_block_id		IN NUMBER,
							    p_party_id		IN NUMBER,
							    p_acct_id		IN NUMBER,
							    p_psite_id		IN NUMBER DEFAULT NULL, -- added by spamujul for ER#8473903
							    p_up_total		IN OUT NOCOPY NUMBER ,
							    p_ip_total		IN OUT NOCOPY NUMBER ,
							    p_ua_total		IN OUT NOCOPY NUMBER ,
							    p_ia_total		IN OUT NOCOPY NUMBER ,
							    p_us_total		IN OUT NOCOPY NUMBER,		-- added by spamujul for ER#8473903
							    p_is_total		IN OUT NOCOPY NUMBER			-- added by spamujul for ER#8473903
							  )   IS

		  blk_id				NUMBER;
		  blk_name			Varchar2(240);
		  sql_stmt			Varchar2(2000);
		  curr_code			Varchar2(15);
		  truncate_flag		Varchar2(1) := 'N';
		  l_for_insert			varchar2(1) := 'Y';
		  l_for_party			varchar2(1) := 'Y';
		  l_for_psite			Varchar2(1) := 'N'; -- added by spamujul for ER#8473903
		  v_party_in_sql		Number := 0;
		  v_acct_in_sql		Number := 0;
		  v_psite_in_sql		Number := 0;	-- added by spamujul for ER#8473903
		/*  added these variable for Bug 1937730*/
		  bparty_id			Number;
		  bacct_id			Number;
		  v_party_id			Number;
		  bpsite_id			Number; -- added by spamujul for ER#8473903
		  cid					Number;
		  val					Varchar2(240) := null;
		  v_incident_id	       Number  	:= p_psite_id	; -- added by spamujul for ER#8473903
		  v_incident_flag	       Number		:= 'Y';  -- added by spamujul for ER#8473903
	 -- cursor to run a specific block
		 CURSOR blocks_csr IS
				SELECT block_id,
					     sql_stmnt,
					     currency_code
		    FROM csc_prof_blocks_b
		    WHERE block_id = p_block_id
		    AND (Sysdate BETWEEN Nvl(start_date_active, Sysdate)
			AND Nvl(end_date_active, Sysdate));

		-- cursor to update all results of an account
		/* added this condition party_id=v_party_id for Bug 1937730*/
		   CURSOR baccount_csr IS
		      SELECT party_id, cust_account_id
		      FROM hz_cust_accounts
		      WHERE  party_id=v_party_id
		      AND  status = 'A' ;
		-- Begin fix by spamujul for NCR ER#8473903
		    CURSOR bpsite_csr IS
		      SELECT party_id, party_site_id
		      FROM hz_party_sites
		      WHERE  party_id=v_party_id
		      AND  status = 'A'
		      AND NVL(created_by_module,'XXX') <> 'SR_ONETIME';
		-- End fix by spamujul for NCR ER#8473903

	BEGIN
		-- Loop through the given block_id for party level
		   OPEN blocks_csr;
		   FETCH blocks_csr
		   INTO blk_id,
			    sql_stmt,
			    curr_code;
		   IF blocks_csr%found THEN
		 CLOSE blocks_csr;
    -- for Bug 1935015 changed instr(sql_stmt..) to INSTR(lower(sql_stmt)..)
		    v_party_in_sql	:=	INSTR(lower(sql_stmt),':party_id',1);
		    v_acct_in_sql	:=	INSTR(lower(sql_stmt),':cust_account_id',1);
		    v_psite_in_sql	:=	INSTR(lower(sql_stmt),':party_site_id',1); -- Added by spamujul for ER#8473903

    --  IF ((v_party_in_sql <> 0) and (v_acct_in_sql <> 0)) Then
/* Commented this if condition for Bug1937730*/
--	IF (p_acct_id IS NULL) THEN
	    -- P_CID is null as cursor should be parsed each time.
		    Evaluate_One_Block(truncate_flag,
								blk_id,
								p_party_id,
								null,
								NULL, -- added by spamujul for ER#8473903
								sql_stmt,
								curr_code,
								p_up_total,
								p_ip_total,
								p_ua_total,
								p_ia_total,
								p_us_total,-- added by spamujul for ER#8473903
								p_is_total,  -- added by spamujul for ER#8473903
								NULL );

		   -- check if there are still records to be inserted
	   IF p_ip_total <> 0 THEN
		l_for_insert := 'Y';
		l_for_party  := 'Y';
		l_for_psite  := 'N'; -- added by spamujul for ER#8473903
		Insert_Update_Block_Results (p_ip_total,
								l_for_insert,
								l_for_party
								,l_for_psite -- added by spamujul for ER#8473903
								);
		p_ip_total :=0;
	   END IF;
	   -- check if there are still records to be updated
	   IF p_up_total <> 0 THEN
		l_for_insert := 'N';
		l_for_party  := 'Y';
		l_for_psite  := 'N'; -- added by spamujul for ER#8473903
		Insert_Update_Block_Results(p_up_total,
								l_for_insert,
								l_for_party
								,l_for_psite -- added by spamujul for ER#8473903
								);
		p_up_total :=0;
	   END IF;

		/* added this condition for Bug 1937730*/
		--	ELSIF (p_acct_id IS NOT NULL) THEN

		/* This begin, end exception is added mainly for exception handing for Bug 19800
		04*/
			Begin
			   -- P_CID is null as cursor should be parsed
			   If (v_acct_in_sql <> 0)  then -- added for 1850508
				      -- If acct is not present as bind variable, the sql might return wrong
				      -- rows (party level counts) at account leve.
				      --p_old_block_id:=null;
				      -- dbms_output.put_line('Evaluate blocks1  Opening and Parsing. ACCTLevel.'||to_char(blk_id));
				       cid := dbms_sql.open_cursor;
				       dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
				       dbms_sql.define_column(cid, 1, val, 240);
				       /* changed bparty_id to p_party_id for bug 5351401 */
				       v_party_id := p_party_id;
				       OPEN baccount_csr;
				       LOOP
					   FETCH baccount_csr
					   INTO bparty_id, bacct_id;
					   EXIT WHEN baccount_csr%notfound;
					   Evaluate_One_Block(truncate_flag,
									    blk_id,
									    bparty_id,
									    bacct_id,
									    NULL, -- added by spamujul for ER#8473903
									    sql_stmt,
									    curr_code,
									     p_up_total,
									     p_ip_total,
									     p_ua_total,
									     p_ia_total,
									     p_us_total,-- added by spamujul for ER#8473903
									     p_is_total -- added by spamujul for ER#8473903
									   ,cid);
				      END LOOP;
				      CLOSE baccount_csr;
				      IF (dbms_sql.is_open(cid)) THEN
					      dbms_sql.close_cursor(cid);
				      End if;
			    END IF; -- added for 1850508
				/*	   Evaluate_One_Block(truncate_flag, blk_id, p_party_id,
							p_acct_id, sql_stmt, curr_code,
						  p_up_total, p_ip_total, p_ua_total, p_ia_total,NULL );
				*/

					   -- check if there are still records to be inserted
			Exception
				When others then
				  IF (dbms_sql.is_open(cid)) THEN
						      dbms_sql.close_cursor(cid);
				  End if;
				  set_context('Evaluate_Blocks2', blk_id, bparty_id);
				  g_error := sqlcode || ' ' || sqlerrm;
				  set_context(NULL, g_error);
			End;
			 IF p_ia_total <> 0 THEN
				l_for_insert := 'Y';
				l_for_party  := 'N';
				l_for_psite  := 'N'; -- Added by spamujul for ER#8473903
				Insert_Update_Block_Results(p_ia_total,
											l_for_insert,
											l_for_party
											,l_for_psite  -- Added by spamujul for ER# 8473903
											);
				p_ia_total :=0;
			 END IF;
		   -- check if there are still records to be updated
			IF p_ua_total <> 0 THEN
				l_for_insert := 'N';
				l_for_party  := 'N';
				l_for_psite  := 'N'; -- Added by spamujul for ER#8473903
				Insert_Update_Block_Results 	(p_ua_total,
												l_for_insert,
												l_for_party
												,l_for_psite  -- Added by spamujul for ER# 8473903
										 );
				p_ua_total :=0;
			END IF;
			--	END IF;
			   --   END IF;  --((v_party_in_sql <> 0) and (v_acct_in_sql <> 0))
			 -- Begin fix by spamujul for NCR ER# 8473903
			    Begin
    				   bparty_id :=0;
				   IF (v_psite_in_sql <> 0)  THEN
					       cid := dbms_sql.open_cursor;
					       dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
					       dbms_sql.define_column(cid, 1, val, 240);
					       v_party_id := p_party_id;
					       OPEN bpsite_csr;
					       LOOP
						   FETCH bpsite_csr
						   INTO bparty_id, bpsite_id;
						   EXIT WHEN bpsite_csr%notfound;
						   /* Added the following code to When incident Address is refreshed
						    in Dashboard
						   */
						   IF (v_incident_id IS NOT NULL AND v_incident_id = bpsite_id) AND v_incident_flag <> 'N' THEN
							v_incident_flag := 'N';
						   END IF;
						   -- End of Incident Address Refresh
						   Evaluate_One_Block(truncate_flag,
										    blk_id,
										    bparty_id,
										    NULL,
										    bpsite_id,
										    sql_stmt,
										    curr_code,
										    p_up_total,
										    p_ip_total,
										    p_ua_total,
										    p_ia_total,
										    p_us_total,
										    p_is_total
										    ,cid);
					      END LOOP;
					      CLOSE bpsite_csr;
					       -- Added the following code  when incident address is refreshed in Dashboard
							IF v_incident_id IS NOT NULL AND v_incident_flag ='Y' THEN
	        						Evaluate_One_Block(truncate_flag,
										    blk_id,
										    p_party_id,
										    NULL,
										    p_psite_id,
										    sql_stmt,
										    curr_code,
										    p_up_total,
										    p_ip_total,
										    p_ua_total,
										    p_ia_total,
										    p_us_total,
										    p_is_total
										    ,cid);
								v_incident_flag  := 'N';
							END IF;
					-- End of the code  when incident address is refreshed in Dashboard

					      IF (dbms_sql.is_open(cid)) THEN
						      dbms_sql.close_cursor(cid);
					      End if;
					END IF;
			    Exception
				When others then
				  IF (dbms_sql.is_open(cid)) THEN
						      dbms_sql.close_cursor(cid);
				  End if;
				  set_context('Evaluate_Blocks2', blk_id, bparty_id,bpsite_id);
				  g_error := sqlcode || ' ' || sqlerrm;
				  set_context(NULL, g_error);
			    End;
			    IF p_is_total <> 0 THEN
				l_for_insert := 'Y';
				l_for_party  := 'N';
				l_for_psite  := 'Y';
				Insert_Update_Block_Results(p_is_total,
										l_for_insert,
										l_for_party
										,l_for_psite
										);
				p_is_total :=0;
			 END IF;
		 	IF p_us_total <> 0 THEN
				l_for_insert := 'N';
				l_for_party  := 'N';
				l_for_psite  := 'Y';
				Insert_Update_Block_Results 	(p_us_total,
										 l_for_insert,
										 l_for_party
										 ,l_for_psite
										 );
				p_us_total :=0;
			END IF;
		-- End fix by spamujul for NCR ER# 8473903
   ELSE
      CLOSE blocks_csr;
   END IF;

   EXCEPTION
      WHEN OTHERS THEN
       IF (blocks_csr%isopen) THEN
	  CLOSE blocks_csr;
       END IF;
       set_context('Evaluate_Blocks2',
			     blk_id,
			     p_party_id,
			     p_acct_id
			     ,p_psite_id  -- Added by spamujul for NCR ER# 8473903
			     );
       g_error := sqlcode || ' ' || sqlerrm;
       set_context(NULL, g_error);

END Evaluate_Blocks2;

--
-- Evaluate_Blocks4 -- added for 1850508
--   When Group Id is given but not party_id or Account_id
--   Calculate for All Parties, Accounts * For all checks present in the group
--
PROCEDURE Evaluate_Blocks4 (    p_up_total      IN OUT NOCOPY NUMBER ,
								    p_ip_total      IN OUT NOCOPY NUMBER ,
								    p_ua_total      IN OUT NOCOPY NUMBER ,
								    p_ia_total      IN OUT NOCOPY NUMBER ,
								    p_us_total	  IN OUT NOCOPY NUMBER, -- added by spamujul for ER#8473903
								    p_is_total	  IN OUT NOCOPY NUMBER, -- added by spamujul for ER#8473903
								    p_group_id      IN     NUMBER
								) IS

		  blk_id			Number;
		  blk_name		Varchar2(240);
		  sql_stmt		Varchar2(2000);
		  curr_code		Varchar2(15);
		  bparty_id		Number;
		  bacct_id		Number;
		  bpsite_id		Number; -- added by spamujul for ER#8473903
		  truncate_flag	Varchar2(1):= 'N';
		  l_for_insert		varchar2(1) := 'Y';
		  l_for_party		varchar2(1) := 'Y';
		  l_for_psite		Varchar2(1) := 'N'; -- added by spamujul for ER#8473903
		  v_party_in_sql	Number := 0;
		  v_acct_in_sql	Number := 0;
		  v_psite_in_sql	Number := 0;  -- added by spamujul for ER#8473903
		/* added this variable for Bug 1937730*/
		  v_party_id            Number;
		   -- cursor to run all blocks for all checks present in that group
		CURSOR blocks_csr IS
			SELECT block_id,
					sql_stmnt,
					currency_code
		      FROM csc_prof_blocks_b a
			WHERE exists ( Select b.block_id
							From csc_prof_check_rules_b b
						     where (b.block_id 	      = a.block_id
							or b.expr_to_block_id = a.block_id)
						     And check_id in (Select check_id
											from csc_prof_group_checks
											where group_id = p_group_id))
							AND  Sysdate BETWEEN Nvl(start_date_active, Sysdate)
							AND Nvl(end_date_active, Sysdate)
							AND block_level IN ('PARTY','ACCOUNT','SITE') -- Included by spamujul  for ER#8473903
							;
		   -- cursor to update all results of a party
		   CURSOR bparty_csr IS
		      SELECT party_id
		      FROM hz_parties
		      WHERE status='A'
		      AND  PARTY_TYPE IN ('PERSON','ORGANIZATION');
		      -- Person, ORG added for 1850508
/* added this condition party_id=v_party_id for Bug 1937730*/
   -- cursor to update all results of an account
		CURSOR baccount_csr IS
			SELECT party_id, cust_account_id
			    FROM hz_cust_accounts
		         WHERE  party_id=v_party_id
				AND  status = 'A' ;
    -- added for 1850508
	    -- Begin fix by spamujul for ER#8473903
		CURSOR bpsite_csr IS
		 SELECT party_id,
				party_site_id
		  FROM   HZ_PARTY_SITES
		  WHERE party_id = v_party_id
		      AND status ='A'
		      AND NVL(created_by_module,'XXX') <>'SR_ONETIME';
	    -- End fix by spamujul for ER#8473903
		cid 		number;
		val		VARCHAR2(240) := null;
BEGIN
			-- Loop through blocks for party level
		 BEGIN
			 OPEN blocks_csr;
			   LOOP
				      FETCH blocks_csr
				      INTO blk_id,
						sql_stmt,
						curr_code;
				      EXIT WHEN blocks_csr%notfound;
				      -- for Bug 1935015 changed instr(sql_stmt..) to INSTR(lower(sql_stmt)..)
				      v_party_in_sql	:= INSTR(lower(sql_stmt),':party_id',1);
				      v_acct_in_sql		:= INSTR(lower(sql_stmt),':cust_account_id',1);
				      v_psite_in_sql	:= INSTR(lower(sql_stmt),':party_site_id',1); -- added by spamujul for ER#8473903
				/* This begin, end exception is added mainly for exception handing for Bug 19800
				04*/
				Begin
				      -- IF ((v_party_in_sql <> 0) and (v_acct_in_sql <> 0)) Then
				      -- Loop through per party
				      -- added for 1850508
				      -- dbms_output.put_line('Evaluate blocks4 Opening and Parsing.PARTY Level.'||to_char(blk_id));
				      cid := dbms_sql.open_cursor;
				      dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
				      dbms_sql.define_column(cid, 1, val, 240);
					 OPEN bparty_csr;
						      LOOP
								FETCH bparty_csr
								INTO bparty_id;
								EXIT WHEN bparty_csr%notfound;
								  Evaluate_One_Block(truncate_flag,
													    blk_id,
													    bparty_id,
													    null,
													    NULL,-- added by spamujul for ER#8473903
													    sql_stmt,
													    curr_code,
													    p_up_total,
													    p_ip_total,
													    p_ua_total,
													    p_ia_total,
													    p_us_total,-- added by spamujul for ER#8473903
													    p_is_total,-- added by spamujul for ER#8473903
													    cid);
													 /* added this condition for Bug 1937730*/
						              v_party_id:=bparty_id;
							   If (v_acct_in_sql <> 0)  then -- added for 1850508
								      -- If acct is not present as bind variable, the sql might return wrong
								      -- rows (party level counts) at account leve.
								      --p_old_block_id:=null;

								      -- dbms_output.put_line('Evaluate blocks1  Opening and Parsing. ACCTLevel.'||to_char(blk_id));
								       OPEN baccount_csr;
										LOOP
											   FETCH baccount_csr
											   INTO bparty_id, bacct_id;
											   EXIT WHEN baccount_csr%notfound;
											   Evaluate_One_Block(truncate_flag,
															    blk_id,
															    bparty_id,
															    bacct_id,
															    NULL,-- added by spamujul for ER#8473903
															    sql_stmt,
															    curr_code,
															   p_up_total,
															   p_ip_total,
															   p_ua_total,
															   p_ia_total,
															   p_us_total,-- added by spamujul for ER#8473903
															   p_is_total,-- added by spamujul for ER#8473903
															   cid);
										END LOOP;
								      CLOSE baccount_csr;
							 END IF; -- added for 1850508
							 -- Begin fix by spamujul for  ER#8473903
							 IF (v_psite_in_sql <> 0)  THEN -- added for 1850508
							 	       OPEN bpsite_csr;
										LOOP
											   FETCH bpsite_csr
											   INTO bparty_id, bpsite_id;
											   EXIT WHEN bpsite_csr%notfound;
											   Evaluate_One_Block(truncate_flag,
															    blk_id,
															    bparty_id,
															    bacct_id,
															    NULL,
															    sql_stmt,
															    curr_code,
															   p_up_total,
															   p_ip_total,
															   p_ua_total,
															   p_ia_total,
															   p_us_total,
															   p_is_total,
															   cid
															   );
										END LOOP;
								      CLOSE bpsite_csr;
							 END IF;
							 -- End fix by spamujul for ER#8473903
					      END LOOP;
					CLOSE bparty_csr;
					IF (dbms_sql.is_open(cid)) THEN
					        dbms_sql.close_cursor(cid);
				      end if;
				      -- END IF;
				Exception
					        When others then
						          IF (dbms_sql.is_open(cid)) THEN
						                dbms_sql.close_cursor(cid);
							  end if;
						          set_context('Evaluate_Blocks4', blk_id, bparty_id);
						          g_error := sqlcode || ' ' || sqlerrm;
						          set_context(NULL, g_error);
				End;
			   END LOOP;
		   CLOSE blocks_csr;
		-- check if there are still records to be inserted
		   IF p_ip_total <> 0 THEN
			l_for_insert	:= 'Y';
			l_for_party	:= 'Y';
			l_for_psite	:= 'N'; -- Added by spamujul for ER#8473903
			Insert_Update_Block_Results(p_ip_total,
									l_for_insert,
									l_for_party
									,l_for_psite  -- Added by spamujul for ER#8473903
									);
			p_ip_total :=0;
		   END IF;
		   -- check if there are still records to be updated
		   IF p_up_total <> 0 THEN
			l_for_insert := 'N';
			l_for_party  := 'Y';
			l_for_psite	:= 'N'; -- Added by spamujul for ER#8473903
			Insert_Update_Block_Results(p_up_total,
									l_for_insert,
									l_for_party
									,l_for_psite  -- Added by spamujul for ER#8473903
									);
			p_up_total :=0;
		   END IF;
		   -- check if there are still records to be inserted
		   IF p_ia_total <> 0 THEN
			l_for_insert	:= 'Y';
			l_for_party	:= 'N';
			l_for_psite	:= 'N';  -- Added by spamujul for ER#8473903
			Insert_Update_Block_Results(p_ia_total,
									l_for_insert,
									l_for_party
									,l_for_psite  -- Added by spamujul for ER#8473903
									);
			p_ia_total :=0;
		   END IF;
		   -- check if there are still records to be updated
		   IF p_ua_total <> 0 THEN
			l_for_insert	:= 'N';
			l_for_party	:= 'N';
			l_for_psite	:= 'N'; -- Added by spamujul for ER#8473903
			Insert_Update_Block_Results(p_ua_total,
									l_for_insert,
									l_for_party
									,l_for_psite  -- Added by spamujul for ER#8473903
									);
			p_ua_total :=0;
		   END IF;
		   -- Begin fix by spamujul for  ER#8473903
		   IF p_is_total <> 0 THEN
			l_for_insert	:= 'Y';
			l_for_party	:= 'N';
			l_for_psite	:= 'Y';
			Insert_Update_Block_Results(p_ia_total,
									l_for_insert,
									l_for_party
									,l_for_psite
									);
			p_is_total :=0;
		   END IF;
		   IF p_us_total <> 0 THEN
			l_for_insert	:= 'N';
			l_for_party	:= 'N';
			l_for_psite	:= 'Y';
			Insert_Update_Block_Results(p_ua_total,
									l_for_insert,
									l_for_party
									,l_for_psite
									);
			p_us_total :=0;
		   END IF;
		   -- End fix by spamujul for ER#8473903
	EXCEPTION
			WHEN OTHERS THEN
			       IF (blocks_csr%isopen) THEN
					  CLOSE blocks_csr;
			       END IF;
			       IF (bparty_csr%isopen) THEN
				   CLOSE bparty_csr;
			       END IF;
			       IF (baccount_csr%isopen) THEN
					CLOSE baccount_csr;
			       END IF;
			       -- Begin fix by spamujul for  ER#8473903
				IF (bpsite_csr%isopen) THEN
					CLOSE bpsite_csr;
			       END IF;
			        -- End fix by spamujul for  ER#8473903
				IF (dbms_sql.is_open(cid)) THEN
				           dbms_sql.close_cursor(cid);
			       end if;
				set_context('Evaluate_Blocks4', blk_id, bparty_id);
				 g_error := sqlcode || ' ' || sqlerrm;
			       set_context(NULL, g_error);
				--set_context(NULL, Sqlerrm);
				 table_delete;
			 RAISE;
	END;
END Evaluate_Blocks4;

--  This procedure evaluates the blocks
--  for which the batch sql statement is NULL and select_type is 'B' (Variable)
-- Group_id is not null
PROCEDURE Evaluate_Blocks4_No_Batch (    p_up_total		IN OUT NOCOPY NUMBER ,
											    p_ip_total		IN OUT NOCOPY NUMBER ,
											    p_ua_total		IN OUT NOCOPY NUMBER ,
											    p_ia_total		IN OUT NOCOPY NUMBER ,
											    p_us_total		IN OUT NOCOPY NUMBER, -- added by spamujul for ER#8473903
											    p_is_total		IN OUT NOCOPY NUMBER, -- added by spamujul for ER#8473903
											    p_group_id	IN     NUMBER
											) IS

				  blk_id			Number;
				  blk_name		Varchar2(240);
				  sql_stmt		Varchar2(2000);
				  curr_code		Varchar2(15);
				  bparty_id		Number;
				  bacct_id		Number;
				  bpsite_id		Number;  -- added by spamujul for ER#8473903
				  truncate_flag	Varchar2(1):= 'N';

				  l_for_insert		varchar2(1) := 'Y';
				  l_for_party		varchar2(1) := 'Y';
				  l_for_psite		Varchar2(1) := 'N'; -- added by spamujul for ER#8473903

				  v_party_in_sql	Number := 0;
				  v_acct_in_sql	Number := 0;
				  v_psite_in_sql	Number :=0; -- added by spamujul for ER#8473903
				  v_party_id            Number;

   -- cursor to run all blocks for all checks present in that group
				   CURSOR blocks_csr IS
				      SELECT block_id,
							sql_stmnt,
							currency_code
					FROM csc_prof_blocks_b a
				       WHERE EXISTS ( SELECT null
							FROM csc_prof_checks_b b
						       WHERE b.select_block_id = a.block_id
							 AND b.select_type = 'B'
							 AND check_id IN (SELECT check_id FROM csc_prof_group_checks
									   WHERE group_id = p_group_id))
					 AND  SYSDATE BETWEEN Nvl(start_date_active, SYSDATE)
							  AND Nvl(end_date_active, SYSDATE)
					 AND  batch_sql_stmnt IS NULL;

				   -- cursor to update all results of a party
				   CURSOR bparty_csr IS
				      SELECT party_id
				      FROM hz_parties
				      WHERE status='A'
				      AND  PARTY_TYPE IN ('PERSON','ORGANIZATION');

   -- cursor to update all results of an account
				   CURSOR baccount_csr IS
				      SELECT party_id, cust_account_id
				      FROM hz_cust_accounts
				      WHERE  party_id=v_party_id
				      AND  status = 'A' ;
-- Begin fx by spamujul for ER#8473903
				CURSOR bpsite_csr IS
					 SELECT party_id,
						party_site_id
				  FROM   HZ_PARTY_SITES
				  WHERE party_id = v_party_id
				      AND status ='A'
				      AND NVL(created_by_module,'XXX') <>'SR_ONETIME';
-- End fx by spamujul for ER#8473903
				cid 		number;
				val		VARCHAR2(240) := null;

BEGIN
			 -- Loop through blocks for party level
		BEGIN
			OPEN blocks_csr;
				      LOOP
					         FETCH blocks_csr INTO blk_id,
											       sql_stmt,
											       curr_code;
					         EXIT WHEN blocks_csr%notfound;
					         v_party_in_sql	:=	INSTR(lower(sql_stmt),':party_id',1);
					         v_acct_in_sql	:=	INSTR(lower(sql_stmt),':cust_account_id',1);
						 v_psite_in_sql	:=	INSTR(lower(sql_stmt),':party_site_id',1);  -- added by spamujul for ER#8473903
						Begin
						            cid := dbms_sql.open_cursor;
						            dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
						            dbms_sql.define_column(cid, 1, val, 240);
							OPEN bparty_csr;
							            LOOP
								               FETCH bparty_csr
									       INTO bparty_id;
								               EXIT WHEN bparty_csr%notfound;
									       Evaluate_One_Block(truncate_flag,
														blk_id,
														bparty_id,
														null,
														NULL, -- added by spamujul for ER#8473903
														sql_stmt,
														curr_code,
														p_up_total,
														p_ip_total,
														p_ua_total,
														p_ia_total,
														p_us_total,-- added by spamujul for ER#8473903
														p_is_total,-- added by spamujul for ER#8473903
														cid
														);
										v_party_id:=bparty_id;
										 If (v_acct_in_sql <> 0)  then
											OPEN baccount_csr;
													LOOP
													     FETCH baccount_csr
													      INTO bparty_id, bacct_id;
													     EXIT WHEN baccount_csr%notfound;
													     Evaluate_One_Block(truncate_flag,
																	       blk_id,
																	       bparty_id,
																	       bacct_id,
																	       NULL, -- added by spamujul for ER#8473903
																	       sql_stmt,
																	       curr_code,
																	       p_up_total,
																	       p_ip_total,
																	       p_ua_total,
																	       p_ia_total,
																	       p_us_total,-- added by spamujul for ER#8473903
																	       p_is_total,-- added by spamujul for ER#8473903
																	       cid);
													END LOOP;
											CLOSE baccount_csr;
										END IF; -- added for 1850508
										-- Begin fix by spamujul for ER#8473903
										v_party_id:=bparty_id;
										 If (v_psite_in_sql <> 0)  then
											OPEN bpsite_csr;
													LOOP
													     FETCH bpsite_csr
													      INTO bparty_id,
															bpsite_id;
													     EXIT WHEN bpsite_csr%notfound;
													     Evaluate_One_Block(truncate_flag,
																	       blk_id,
																	       bparty_id,
																	       NULL,
																		bpsite_id,
																	       sql_stmt,
																	       curr_code,
																	       p_up_total,
																	       p_ip_total,
																	       p_ua_total,
																	       p_ia_total,
																	       p_us_total,
																	       p_is_total,
																	       cid);
													END LOOP;
											CLOSE bpsite_csr;
										End IF;
										-- End fix by spamujul for  ER#8473903
								 END LOOP;
							CLOSE bparty_csr;
						    IF (dbms_sql.is_open(cid)) THEN
						       dbms_sql.close_cursor(cid);
						    end if;
					Exception
							When others then
									 IF (dbms_sql.is_open(cid)) THEN
										 dbms_sql.close_cursor(cid);
									end if;
									set_context('Evaluate_Blocks4_No_Batch', blk_id, bparty_id);
									g_error := sqlcode || ' ' || sqlerrm;
									set_context(NULL, g_error);
					End;

			 END LOOP;
		CLOSE blocks_csr;

   -- check if there are still records to be inserted
		      IF p_ip_total <> 0 THEN
			 l_for_insert		:= 'Y';
			 l_for_party		:= 'Y';
			 l_for_psite		:= 'N';	 -- Added by spamujul for ER#8473903
			 Insert_Update_Block_Results	(p_ip_total,
									 l_for_insert,
									 l_for_party
									 ,l_for_psite  -- Added by spamujul for ER#8473903
									 );
			 p_ip_total :=0;
		      END IF;
		   -- check if there are still records to be updated
		      IF p_up_total <> 0 THEN
			 l_for_insert		:= 'N';
			 l_for_party		:= 'Y';
			 l_for_psite		:= 'N';	 -- Added by spamujul for ER#8473903
			 Insert_Update_Block_Results(p_up_total,
									 l_for_insert,
									 l_for_party
									 ,l_for_psite  -- Added by spamujul for ER#8473903
									 );
			 p_up_total :=0;
		      END IF;
		-- Begin fix by spamujul for ER#8473903
			 IF p_is_total <> 0 THEN
			l_for_insert		:= 'Y';
			l_for_party		 := 'N';
			l_for_psite		:= 'Y';
			Insert_Update_Block_Results(p_is_total,
									l_for_insert,
									l_for_party
									,l_for_psite
									);
			p_is_total :=0;
		   END IF;
		   -- check if there are still records to be updated
		   IF p_us_total <> 0 THEN
			l_for_insert		:= 'N';
			l_for_party		:= 'N';
			l_for_psite		:= 'Y';
			Insert_Update_Block_Results(p_us_total,
									l_for_insert,
									l_for_party
									,l_for_psite
									);
			p_us_total :=0;
		   END IF;
		-- End  fix by spamujul for ER#8473903
		EXCEPTION
					WHEN OTHERS THEN
							 IF (blocks_csr%isopen) THEN
							    CLOSE blocks_csr;
							 END IF;
							 IF (bparty_csr%isopen) THEN
							    CLOSE bparty_csr;
							 END IF;
							 IF (baccount_csr%isopen) THEN
							   CLOSE baccount_csr;
							 END IF;
							 -- Begin fix by spamujul for ER#8473903
							IF (bpsite_csr%isopen) THEN
							   CLOSE bpsite_csr;
							 END IF;
							--  End  fix by spamujul for ER#8473903
							 IF (dbms_sql.is_open(cid)) THEN
							    dbms_sql.close_cursor(cid);
							 end if;
							set_context('Evaluate_Blocks4_No_Batch', blk_id, bparty_id);
							 g_error := sqlcode || ' ' || sqlerrm;
							set_context(NULL, g_error);
							table_delete;
						         RAISE;
		   END;
		   -- check if there are still records to be inserted
		   IF p_ia_total <> 0 THEN
			l_for_insert		:= 'Y';
			l_for_party		:= 'N';
			l_for_psite		:= 'N';	 -- Added by spamujul for ER#8473903
			Insert_Update_Block_Results(p_ia_total,
									l_for_insert,
									l_for_party
									,l_for_psite  -- Added by spamujul for ER#8473903
									);
			p_ia_total :=0;
		   END IF;
		   -- check if there are still records to be updated
		   IF p_ua_total <> 0 THEN
			l_for_insert		:= 'N';
			l_for_party		:= 'N';
			l_for_psite		:= 'N';	 -- Added by spamujul for ER#8473903
			Insert_Update_Block_Results(p_ua_total,
									l_for_insert,
									l_for_party
									,l_for_psite  -- Added by spamujul for ER#8473903
									);
			p_ua_total :=0;
		   END IF;

END Evaluate_Blocks4_No_Batch;

PROCEDURE Evaluate_Blocks5
				  ( p_block_id		IN	NUMBER,
				    p_party_id			IN	NUMBER,
				    p_psite_id			IN	NUMBER DEFAULT NULL,   -- added by spamujul for ER#8473903
				    p_up_total			IN OUT NOCOPY NUMBER ,
				    p_ip_total			IN OUT NOCOPY NUMBER ,
				    p_ua_total			IN OUT NOCOPY NUMBER ,
				    p_ia_total			IN OUT NOCOPY NUMBER
				    ,p_us_total		IN OUT NOCOPY NUMBER, -- added by spamujul for ER#8473903
				    p_is_total			IN OUT NOCOPY NUMBER -- added by spamujul for ER#8473903
				    )
				  IS

		  v_blk_id			NUMBER;
		  v_blk_name		Varchar2(240);
		  v_sql_stmt			Varchar2(2000);
		  v_curr_code		Varchar2(15);
		  v_truncate_flag		Varchar2(1) := 'N';

		  l_for_insert			varchar2(1) := 'Y';
		  l_for_party			varchar2(1) := 'Y';
		  l_for_psite			Varchar2(1) := 'N'; -- added by spamujul for ER#8473903

		  v_party_in_sql		Number		:= 0;
		  v_acct_in_sql		Number		:= 0;
		  v_psite_in_sql		Number		:= 0; -- added by spamujul for ER#8473903

		  bparty_id			Number;
		  bacct_id			Number;
		  bpsite_id			Number;  -- added by spamujul for ER#8473903
		  v_party_id			Number;
		  cid					Number;
		  val					Varchar2(240) := null;


		 -- cursor to run a specific block
		 CURSOR blocks_csr(c_block_id IN NUMBER) IS
		    SELECT block_id,
				     sql_stmnt,
				     currency_code
		    FROM csc_prof_blocks_b
		    WHERE block_id = c_block_id
		    AND block_level in( 'CONTACT','EMPLOYEE','SITE')   -- 'Included 'SITE' by spamujul for ER#8473903
		    AND (Sysdate BETWEEN Nvl(start_date_active, Sysdate)
			 AND Nvl(end_date_active, Sysdate));
 -- Begin fix by spamujul for NCR ER#8473903
	    CURSOR bpsite_csr IS
	      SELECT party_id, party_site_id
	      FROM hz_party_sites
	      WHERE  party_id=v_party_id
	      AND  status = 'A'
	      AND NVL(created_by_module,'XXX') <> 'SR_ONETIME';
	-- End fix by spamujul for NCR ER#8473903
BEGIN
  -- Loop through the given block_id for party level
		OPEN blocks_csr(p_block_id);
			     FETCH blocks_csr
			     INTO v_blk_id,
			     v_sql_stmt,
			     v_curr_code;
			    IF blocks_csr%found THEN
					 v_psite_in_sql	:=	INSTR(lower( v_sql_stmt),':party_site_id',1); -- Added by spamujul for ER#8473903
					 Evaluate_One_Block(v_truncate_flag,
										  v_blk_id,
										  p_party_id,
										  null,
										  NULL, -- added by spamujul for ER#8473903
										  v_sql_stmt,
										  v_curr_code,
										  p_up_total,
										  p_ip_total,
										  p_ua_total,
										  p_ia_total,
										  p_us_total,-- added by spamujul for ER#8473903
										  p_is_total,-- added by spamujul for ER#8473903
										  NULL );
						 -- check if there are still records to be inserted
						   IF p_ip_total <> 0 THEN
							l_for_insert	:= 'Y';
							l_for_party	:= 'Y';
							l_for_psite	:= 'N' ; -- added by spamujul for ER#8473903
							Insert_Update_Block_Results(p_ip_total,
													l_for_insert,
													l_for_party
													,l_for_psite  -- Added by spamujul for ER#8473903
													);
							p_ip_total :=0;
						   END IF;
						   -- check if there are still records to be updated
						   IF p_up_total <> 0 THEN
							l_for_insert := 'N';
							l_for_party  := 'Y';
							l_for_psite	:= 'N' ; -- added by spamujul for ER#8473903
							Insert_Update_Block_Results(p_up_total,
													l_for_insert,
													l_for_party
													,l_for_psite  -- Added by spamujul for ER#8473903
													);
							p_up_total :=0;
						   END IF;
					END IF;
			-- Begin fix by spamujul for  ER#8473903
		-- Begin fix by spamujul for NCR ER# 8473903
			    Begin
    				   bparty_id :=0;
				   IF (v_psite_in_sql <> 0)  THEN
					       cid := dbms_sql.open_cursor;
					       dbms_sql.parse(cid,  v_sql_stmt, dbms_sql.native);
					       dbms_sql.define_column(cid, 1, val, 240);
					       v_party_id := p_party_id;
					       OPEN bpsite_csr;
					       LOOP
						   FETCH bpsite_csr
						   INTO bparty_id, bpsite_id;
						   EXIT WHEN bpsite_csr%notfound;
						   Evaluate_One_Block(V_truncate_flag,
										    v_blk_id,
										    bparty_id,
										    NULL,
										    bpsite_id,
										     v_sql_stmt,
										    v_curr_code,
										    p_up_total,
										    p_ip_total,
										    p_ua_total,
										    p_ia_total,
										    p_us_total,
										    p_is_total
										    ,cid);
					      END LOOP;
					      CLOSE bpsite_csr;
					      IF (dbms_sql.is_open(cid)) THEN
						      dbms_sql.close_cursor(cid);
					      End if;
					END IF;
			    Exception
				When others then
				  IF (dbms_sql.is_open(cid)) THEN
						      dbms_sql.close_cursor(cid);
				  End if;
				  set_context('Evaluate_Blocks5', v_blk_id, bparty_id,bpsite_id);
				  g_error := sqlcode || ' ' || sqlerrm;
				  set_context(NULL, g_error);
			    End;
			    IF p_is_total <> 0 THEN
				l_for_insert := 'Y';
				l_for_party  := 'N';
				l_for_psite  := 'Y';
				Insert_Update_Block_Results(p_is_total,
										l_for_insert,
										l_for_party
										,l_for_psite
										);
				p_is_total :=0;
			 END IF;
		 	IF p_us_total <> 0 THEN
				l_for_insert := 'N';
				l_for_party  := 'N';
				l_for_psite  := 'Y';
				Insert_Update_Block_Results 	(p_us_total,
										 l_for_insert,
										 l_for_party
										 ,l_for_psite
										 );
				p_us_total :=0;
			END IF;
	-- End fix by spamujul for ER#8473903
      CLOSE blocks_csr;
EXCEPTION
      WHEN OTHERS THEN
       IF (blocks_csr%isopen) THEN
	    CLOSE blocks_csr;
       END IF;
       set_context('Evaluate_Blocks5',
			     v_blk_id,
			     p_party_id,
			     p_psite_id,  -- added by spamujul for ER#8473903
			     null);
       g_error := sqlcode || ' ' || sqlerrm;
       set_context(NULL, g_error);
END Evaluate_Blocks5;

PROCEDURE Evaluate_Blocks_Rel (p_up_total			IN	OUT NOCOPY NUMBER ,
								    p_ip_total			IN	OUT NOCOPY NUMBER ,
								    p_ua_total			IN	OUT NOCOPY NUMBER ,
								    p_ia_total			IN	OUT NOCOPY NUMBER ,
								    p_us_total			IN	OUT NOCOPY NUMBER, -- added by spamujul for ER#8473903
								    p_is_total			IN	OUT NOCOPY NUMBER, -- added by spamujul for ER#8473903
								    p_group_id		IN	NUMBER DEFAULT NULL,
								    p_no_batch_sql	IN	VARCHAR2 DEFAULT NULL,
								    p_rule_only		IN	VARCHAR2 DEFAULT NULL
								) IS

			  truncate_flag		Varchar2(1)	:= 'N';
			  l_for_insert			varchar2(1)	:= 'Y';
			  l_for_party			varchar2(1)	:= 'Y';
			  l_for_psite			Varchar2(1)	:= 'N'; -- Added by spamujul for ER#8473903
			  v_party_in_sql		Number := 0;
			  v_acct_in_sql		Number := 0;
			  v_psite_in_sql		Number := 0; -- Added by spamujul for ER#8473903
			  v_party_id			Number;
			   v_block_id			Number;
			   bpsite_id			Number	:= 0 ; -- Added by spamujul for ER#8473903
			   bparty_id			Number := 0;  -- Added by spamujul for ER#8473903

			v_block_curvar  blocks_curtype;
			 v_rec_var  r_blk_rectype;

			CURSOR relparty_csr IS
			SELECT party_id
			FROM hz_parties
			WHERE status='A'
			AND  PARTY_TYPE = 'PARTY_RELATIONSHIP';
			 -- Begin fix by spamujul for ER#8473903
			  CURSOR bpsite_csr IS
				 SELECT party_id,
						party_site_id
				  FROM   HZ_PARTY_SITES
				  WHERE party_id = v_party_id
				      AND status ='A'
				      AND NVL(created_by_module,'XXX') <>'SR_ONETIME';
			     -- End fix by spamujul for ER#8473903

			cid 				number;
			val				VARCHAR2(240) := null;

BEGIN
		BEGIN
				IF p_group_id IS NULL THEN
					IF p_no_batch_sql = 'Y' THEN
						OPEN v_block_curvar FOR
								SELECT block_id,
										sql_stmnt,
										currency_code
								   FROM csc_prof_blocks_b a
								  WHERE EXISTS ( SELECT null
										   FROM csc_prof_checks_b b
										  WHERE b.select_block_id = a.block_id
										    AND b.select_type = 'B'
										    AND check_id IN (SELECT check_id FROM csc_prof_group_checks))
								    AND SYSDATE BETWEEN Nvl(start_date_active, SYSDATE)
										    AND Nvl(end_date_active, SYSDATE)
								    AND batch_sql_stmnt IS NULL
								    AND block_level  IN ( 'CONTACT','SITE'); -- Included 'SITE' by spamujul for ER#8473903
							      ELSIF p_rule_only = 'Y' THEN
								 OPEN v_block_curvar FOR
								 SELECT block_id,
								 		 sql_stmnt,
										 currency_code
								   FROM csc_prof_blocks_b a
								  WHERE exists ( SELECT b.block_id
										   FROM csc_prof_check_rules_b b, csc_prof_checks_b c
										  WHERE (b.block_id  = a.block_id
											 or b.expr_to_block_id = a.block_id)
										    AND c.select_type = 'T'
										    AND b.check_id = c.check_id)
								    AND Sysdate BETWEEN Nvl(start_date_active, Sysdate)
								    AND Nvl(end_date_active, Sysdate)
								    AND block_level IN ('CONTACT','SITE'); -- Included 'SITE' by spamujul for ER#8473903
					ELSE
							OPEN v_block_curvar FOR
							SELECT block_id,
									sql_stmnt,
									currency_code
							   FROM csc_prof_blocks_b a
							  WHERE exists ( Select b.block_id
									   From csc_prof_check_rules_b b
									  where b.block_id  = a.block_id
									     or b.expr_to_block_id = a.block_id)
							    AND Sysdate BETWEEN Nvl(start_date_active, Sysdate)
							    AND Nvl(end_date_active, Sysdate)
							    AND block_level IN ('CONTACT','SITE'); -- Included 'SITE' by spamujul for ER#8473903
				END IF;
			ELSE
					IF p_no_batch_sql = 'Y' THEN
						OPEN v_block_curvar FOR
								SELECT block_id,
										sql_stmnt,
										currency_code
								   FROM csc_prof_blocks_b a
								  WHERE EXISTS ( SELECT null
										   FROM csc_prof_checks_b b
										  WHERE b.select_block_id = a.block_id
										    AND b.select_type = 'B'
										    AND check_id IN (SELECT check_id FROM csc_prof_group_checks
												      WHERE group_id = p_group_id))
								    AND SYSDATE BETWEEN Nvl(start_date_active, SYSDATE)
										    AND Nvl(end_date_active, SYSDATE)
								    AND batch_sql_stmnt IS NULL
								    AND block_level IN ( 'CONTACT','SITE'); -- Included 'SITE' by spamujul for ER#8473903
					ELSIF p_rule_only = 'Y' THEN
						OPEN v_block_curvar FOR
							 SELECT block_id,
									 sql_stmnt,
									 currency_code
							 FROM csc_prof_blocks_b a
							 WHERE EXISTS ( SELECT b.block_id
									  FROM csc_prof_check_rules_b b, csc_prof_checks_b c
									 WHERE (b.block_id = a.block_id
										OR b.expr_to_block_id = a.block_id)
									   AND c.select_type = 'T'
									   AND b.check_id = c.check_id
									   AND b.check_id IN (SELECT check_id from csc_prof_group_checks
											     WHERE group_id = p_group_id))
							  AND Sysdate BETWEEN Nvl(start_date_active, Sysdate)
							  AND Nvl(end_date_active, Sysdate)
							  AND block_level  IN ('CONTACT','SITE'); -- Included 'SITE' by spamujul for ER#8473903
					ELSE
							OPEN v_block_curvar FOR
							SELECT block_id,
									 sql_stmnt,
									 currency_code
							   FROM csc_prof_blocks_b a
							  WHERE EXISTS ( SELECT b.block_id
									   FROM csc_prof_check_rules_b b
									  WHERE (b.block_id = a.block_id
										 or b.expr_to_block_id = a.block_id)
							   AND check_id IN (Select check_id from csc_prof_group_checks
									     where group_id = p_group_id))
							   AND Sysdate BETWEEN Nvl(start_date_active, Sysdate)
							   AND Nvl(end_date_active, Sysdate)
							   AND block_level IN ('CONTACT','SITE'); -- Included 'SITE' by spamujul for ER#8473903
					END IF;
			END IF;
			LOOP
				FETCH v_block_curvar
				INTO v_rec_var;
				EXIT WHEN v_block_curvar%notfound;
				v_party_in_sql	:=	INSTR(lower(v_rec_var.sql_stmnt),':party_id',1);
				v_psite_in_sql	:=	INSTR(lower(v_rec_var.sql_stmnt),':party_site_id',1);
				v_block_id		:=	v_rec_var.block_id;
			      BEGIN
				      cid := dbms_sql.open_cursor;
				      dbms_sql.parse(cid, v_rec_var.sql_stmnt, dbms_sql.native);
				      dbms_sql.define_column(cid, 1, val, 240);
					OPEN relparty_csr;
						      LOOP
								   FETCH relparty_csr
								   INTO v_party_id;
								   EXIT WHEN relparty_csr%notfound;
								   Evaluate_One_Block(truncate_flag,
												     v_block_id,
												     v_party_id,
												     null,
												     NULL, -- added by spamujul for ER#8473903
												     v_rec_var.sql_stmnt,
												     v_rec_var.currency,
												     p_up_total,
												     p_ip_total,
												     p_ua_total,
												     p_ia_total,
												     p_us_total,-- added by spamujul for ER#8473903
													p_is_total,-- added by spamujul for ER#8473903
												     cid);
								-- Begin fix by spamujul for ER#8473903
								Begin
									   bparty_id :=0;
									   IF (v_psite_in_sql <> 0)  THEN
										       cid := dbms_sql.open_cursor;
										       dbms_sql.parse(cid, v_rec_var.sql_stmnt, dbms_sql.native);
										       dbms_sql.define_column(cid, 1, val, 240);
										       OPEN bpsite_csr;
										       LOOP
											   FETCH bpsite_csr
											   INTO bparty_id, bpsite_id;
											   EXIT WHEN bpsite_csr%notfound;
											   Evaluate_One_Block(truncate_flag,
															    v_block_id,
															    bparty_id,
															    NULL,
															    bpsite_id,
															    v_rec_var.sql_stmnt,
															    v_rec_var.currency,
															    p_up_total,
															    p_ip_total,
															    p_ua_total,
															    p_ia_total,
															    p_us_total,
															    p_is_total
															    ,cid);
										      END LOOP;
										CLOSE bpsite_csr;
									      IF (dbms_sql.is_open(cid)) THEN
										      dbms_sql.close_cursor(cid);
									      End if;
									END IF;
								Exception
										When others then
										  IF (dbms_sql.is_open(cid)) THEN
												      dbms_sql.close_cursor(cid);
										  End if;
										  set_context('Evaluate_Blocks_rel', v_block_id, bparty_id,bpsite_id);
										  g_error := sqlcode || ' ' || sqlerrm;
										  set_context(NULL, g_error);
								End;
							        IF p_is_total <> 0 THEN
									l_for_insert := 'Y';
									l_for_party  := 'N';
									l_for_psite  := 'Y';
									Insert_Update_Block_Results(p_is_total,
																l_for_insert,
																l_for_party
																,l_for_psite
																);
									p_is_total :=0;
								 END IF;
								IF p_us_total <> 0 THEN
									l_for_insert := 'N';
									l_for_party  := 'N';
									l_for_psite  := 'Y';
									Insert_Update_Block_Results 	(p_us_total,
																	 l_for_insert,
																	 l_for_party
																	 ,l_for_psite
																	 );
									p_us_total :=0;
								END IF;
								-- End fix by spamujul for ER#8473903
						END LOOP;
					CLOSE relparty_csr;
				       IF (dbms_sql.is_open(cid)) THEN
					dbms_sql.close_cursor(cid);
				       END IF;
			EXCEPTION
				WHEN others THEN
					  IF (dbms_sql.is_open(cid)) THEN
					      dbms_sql.close_cursor(cid);
					  END IF;
					   IF (bpsite_csr%isopen) THEN
						CLOSE bpsite_csr;
					 END IF;
					  set_context('Evaluate_Blocks_Rel', v_block_id, v_party_id);
					  g_error := sqlcode || ' ' || sqlerrm;
					  set_context(NULL, g_error);
			END;
		END LOOP;
	CLOSE v_block_curvar;
	   -- check if there are still records to be inserted
	   IF p_ip_total <> 0 THEN
		l_for_insert	:= 'Y';
		l_for_party	:= 'Y';
		l_for_psite	:='N' ;  -- Added by spamujul for ER#8473903
		Insert_Update_Block_Results (p_ip_total,
								l_for_insert,
								l_for_party
								,l_for_psite  -- Added by spamujul for ER#8473903
								);
		p_ip_total :=0;
	   END IF;
	   -- check if there are still records to be updated
	   IF p_up_total <> 0 THEN
		l_for_insert	:= 'N';
		l_for_party	:= 'Y';
		l_for_psite	:='N'; -- Added by spamujul for ER#8473903
		Insert_Update_Block_Results(p_up_total,
								l_for_insert,
								l_for_party
								,l_for_psite  -- Added by spamujul for ER#8473903
								);
		p_up_total :=0;
	 END IF;
   EXCEPTION
		      WHEN OTHERS THEN
		       IF (v_block_curvar%isopen) THEN
			     CLOSE v_block_curvar;
		       END IF;
		       IF (relparty_csr%isopen) THEN
			      CLOSE relparty_csr;
		       END IF;
			set_context('Evaluate_Blocks_Rel', v_block_id, v_party_id);
		       g_error := sqlcode || ' ' || sqlerrm;
		       set_context(NULL, g_error);
		       table_delete;
		       RAISE;
  END;
END Evaluate_Blocks_Rel;

PROCEDURE Evaluate_Checks_Rel ( errbuf				OUT	NOCOPY VARCHAR2,
						  		       retcode				OUT	NOCOPY NUMBER,
								       p_group_id			IN		NUMBER		DEFAULT NULL,
   								      p_no_batch_sql		IN		VARCHAR2		DEFAULT NULL,
								      p_rule_only			IN		VARCHAR2		DEFAULT NULL ) IS

			  chk_id				Number;
			  chk_name			Varchar2(240);
			  cparty_id			Number;
			  cpsite_id			Number; -- added by spamujul for ER#8473903
			  sel_type			Varchar2(3);
			  sel_blk_id			Number;
			  data_type			Varchar2(90);
			  fmt_mask			Varchar2(90);
			  rule				Varchar2(32767);
			  chk_u_l_flag		Varchar2(3);
			  Thd_grade			Varchar2(9);
			  truncate_flag		Varchar2(1) := 'N';
			  acct_flag			Varchar2(1);
			  blk_id				Number 		:= null;
			  blk_name			Varchar2(240)	:= null;
			  sql_stmt			Varchar2(2000)	:= null;
			  curr_code			Varchar2(15)	:= null;
			  v_party_in_sql		Number := 0;
			  v_psite_in_sql		Number := 0;	 -- added by spamujul for ER#8473903
			  l_for_insert			varchar2(1) := 'Y';
			  l_for_party			varchar2(1) := 'Y';
			  l_for_psite			Varchar2(1) := 'N'; -- added by spamujul for ER#8473903
			  l_up_total			Number := 0;
			  l_ip_total			Number := 0;
			  l_ua_total			Number := 0;
			  l_ia_total			Number := 0;
			  l_us_total			Number := 0;  -- added by spamujul for ER#8473903
			  l_is_total			Number := 0;  -- added by spamujul for ER#8473903
			  v_party_id			Number;
			  v_check_level		Varchar2(10);
			  v_checks_curvar	checks_curtype;
			  v_rec_var			r_chk_rectype;

			  CURSOR block_csr IS
			      SELECT block_id, sql_stmnt, currency_code
			      FROM csc_prof_blocks_b a
			      WHERE a.block_id = sel_blk_id;

			   CURSOR crelparty_csr IS
			      SELECT party_id
			      FROM hz_parties
			      WHERE status='A'
			      AND  party_type = 'PARTY_RELATIONSHIP';
			      -- Begin fix by spamujul for ER#8473903
			  CURSOR cpsite_csr IS
				 SELECT party_id,
						party_site_id
				  FROM   HZ_PARTY_SITES
				  WHERE party_id = v_party_id
				      AND status ='A'
				      AND NVL(created_by_module,'XXX') <>'SR_ONETIME';
			     -- End fix by spamujul for ER#8473903

			cid 				number;
			val				VARCHAR2(240) := null;

BEGIN
		   l_ip_total := 0;
		   l_up_total := 0;
		   l_ia_total := 0;
		   l_ua_total := 0;
		   l_us_total  := 0;  -- added by spamujul for ER#8473903
		   l_is_total   := 0;  -- added by spamujul for ER#8473903
		  IF p_group_id IS NULL THEN
			      IF p_no_batch_sql = 'Y' THEN
					OPEN v_checks_curvar FOR
						 SELECT check_id,
								  select_type,
								  select_block_id,
								  data_type,
								  format_mask,
								  check_upper_lower_flag,
							          threshold_grade, check_level
						   FROM csc_prof_checks_b a
						  WHERE check_id IN (SELECT check_id
											 FROM csc_prof_group_checks)
											    AND select_type = 'B'
											    AND check_level  IN ( 'CONTACT','SITE') -- Included by spamujul for  ER#8473903
											    AND EXISTS (SELECT null
													  FROM csc_prof_blocks_b b
													 WHERE a.select_block_id = b.block_id
													   AND b.batch_sql_stmnt IS NULL)
											    AND SYSDATE BETWEEN Nvl(start_date_active, SYSDATE)
													    AND Nvl(end_date_active, SYSDATE);
			     ELSIF p_rule_only = 'Y' THEN
					 OPEN v_checks_curvar FOR
							SELECT check_id,
									select_type,
									select_block_id,
									data_type,
									format_mask,
									check_upper_lower_flag,
									threshold_grade,
									check_level
							   FROM csc_prof_checks_b
							  WHERE check_level  IN ( 'CONTACT','SITE') -- Included by spamujul for  ER#8473903
							    AND select_type = 'T'
							    AND Sysdate BETWEEN Nvl(start_date_active, Sysdate)
								AND Nvl(end_date_active, Sysdate);
			      ELSE
					 OPEN v_checks_curvar FOR
					 SELECT check_id,
							  select_type,
							  select_block_id,
							 data_type,
							 format_mask,
							 check_upper_lower_flag,
							 threshold_grade,
						         check_level
					   FROM csc_prof_checks_b
					  WHERE check_level  IN ( 'CONTACT','SITE') -- Included by spamujul for  ER#8473903
					    AND Sysdate BETWEEN Nvl(start_date_active, Sysdate)
						AND Nvl(end_date_active, Sysdate);
			      END IF;
		ELSE
			   IF p_no_batch_sql = 'Y' THEN
				 OPEN v_checks_curvar FOR
					 SELECT check_id,
							  select_type,
							  select_block_id,
							  data_type,
							  format_mask,
							  check_upper_lower_flag,
							  threshold_grade,
							  check_level
					   FROM csc_prof_checks_b a
					  WHERE check_id IN (SELECT check_id
										 FROM csc_prof_group_checks
										WHERE group_id = p_group_id)
										    AND select_type = 'B'
										    AND check_level IN ( 'CONTACT','SITE') -- Included by spamujul for  ER#8473903'
										    AND EXISTS (SELECT null
												  FROM csc_prof_blocks_b b
												 WHERE a.select_block_id = b.block_id
												   AND b.batch_sql_stmnt IS NULL)
										    AND SYSDATE BETWEEN Nvl(start_date_active, SYSDATE)
												    AND Nvl(end_date_active, SYSDATE);
			ELSIF p_rule_only = 'Y' THEN
				 OPEN v_checks_curvar FOR
					  SELECT check_id,
							   select_type,
							   select_block_id,
							   data_type,
							   format_mask,
							   check_upper_lower_flag,
							   threshold_grade,
							  check_level
					    FROM csc_prof_checks_b
					   WHERE check_level IN ( 'CONTACT','SITE') -- Included by spamujul for  ER#8473903'
					     AND select_type = 'T'
					     AND check_id in (select check_id
										from csc_prof_group_checks
									       where group_id = p_group_id)
							     And Sysdate BETWEEN Nvl(start_date_active, Sysdate)
							     AND Nvl(end_date_active, Sysdate);
			ELSE
				 OPEN v_checks_curvar FOR
					  SELECT check_id,
							   select_type,
							   select_block_id,
							   data_type,
							   format_mask,
							   check_upper_lower_flag,
							   threshold_grade,
							   check_level
					    FROM csc_prof_checks_b
					   WHERE check_level IN ( 'CONTACT','SITE') -- Included by spamujul for  ER#8473903'
					     AND check_id in (select check_id from csc_prof_group_checks
							       where group_id = p_group_id)
					     And Sysdate BETWEEN Nvl(start_date_active, Sysdate)
					     AND Nvl(end_date_active, Sysdate);
			      END IF;
		END IF;
		   LOOP
			       FETCH v_checks_curvar INTO v_rec_var;
				sel_type := v_rec_var.select_type;
				chk_id := v_rec_var.check_id;
				sel_blk_id := v_rec_var.select_block_id;
				v_check_level:= v_rec_var.check_level;
				data_type:=v_rec_var.data_type;
				fmt_mask:=v_rec_var.format_mask;
				chk_u_l_flag:= v_rec_var.check_upper_lower_flag;
				thd_grade := v_rec_var.threshold_grade;
				EXIT WHEN v_checks_curvar%notfound;
			       IF (sel_type = 'T') THEN
				   build_rule('N',chk_id,v_check_level, rule);
			       ELSIF (sel_type = 'B') THEN
				      Open block_csr;
				      Fetch block_csr
				      INTO blk_id,
						sql_stmt,
						curr_code;
				      Close block_csr;
				     IF sql_stmt IS NOT NULL Then
					   v_party_in_sql := INSTR(lower(sql_stmt),':party_id',1);
					    v_psite_in_sql := INSTR(lower(sql_stmt),':party_site_id',1); -- Added by spamujul for  ER#8473903'
				     Else
				       v_party_in_sql := 0;
				       v_psite_in_sql := 0; -- Added by spamujul for  ER#8473903'
				     End if;
				   END IF;

		BEGIN
				IF ((sel_type='B' ) OR  (sel_type='T') ) THEN
					cid := dbms_sql.open_cursor;
					IF (sel_type = 'B') THEN
						 dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
					ELSIF (sel_type = 'T') then
						dbms_sql.parse(cid, rule, dbms_sql.native);
					END IF;
					dbms_sql.define_column(cid,1,val,240);
					OPEN crelparty_csr;
						 LOOP
							FETCH crelparty_csr INTO cparty_id;
							EXIT WHEN crelparty_csr%notfound;
							Evaluate_One_Check(truncate_flag,
											   chk_id,
											   cparty_id,
											   null,
											   NULL,  -- added by spamujul for ER#8473903
											   v_check_level,
											   sel_type,
											   sel_blk_id,
											   data_type,
											   fmt_mask,
											   chk_u_l_flag,
											   Thd_grade,
											   rule,
											   blk_id,
											   sql_stmt,
											   curr_code,
											   l_up_total,
											   l_ip_total,
											   l_ua_total,
											   l_ia_total ,
											   l_us_total,  -- added by spamujul for ER#8473903
											   l_is_total,  -- added by spamujul for ER#8473903
											   cid
											   );
							-- Begin fix by spamujul for ER#8473903
							Begin
								 v_party_id:=cparty_id;
								 IF ((sel_type='B' ) OR (sel_type='T') ) AND v_check_level='SITE' THEN
									IF ((v_psite_in_sql = 0) AND sel_type = 'B') AND v_check_level='SITE' THEN
										NULL;
									ELSE
										cid := dbms_sql.open_cursor;
										IF (sel_type = 'B') THEN
											dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
										ELSIF (sel_type = 'T') THEN
											dbms_sql.parse(cid, rule, dbms_sql.native);
										END IF;
											 dbms_sql.define_column(cid,1,val,240);
										OPEN  cpsite_csr;
												LOOP
													FETCH  cpsite_csr
													INTO cparty_id,
														 cpsite_id;
													EXIT WHEN cpsite_csr%notfound;
													 Evaluate_One_Check(truncate_flag,
																       chk_id,
																       cparty_id,
																       NULL, -- For site level profile check, account parameter should be null
																       cpsite_id,
																       v_check_level,
																       sel_type,
																       sel_blk_id,
																       data_type,
																	fmt_mask,
																	chk_u_l_flag,
																	Thd_grade,
																	rule,
																	blk_id,
																	sql_stmt,
																	curr_code,
																	l_up_total,
																	l_ip_total,
																	l_ua_total,
																	l_ia_total ,
																	l_us_total,
																	l_is_total,
																	cid);
													END LOOP;
												CLOSE cpsite_csr;
												IF (dbms_sql.is_open(cid)) THEN
													dbms_sql.close_cursor(cid);
												 end if;
									END IF;
								END IF;
						 Exception
								When others then
									 IF (dbms_sql.is_open(cid)) THEN
										dbms_sql.close_cursor(cid);
									end if;
									set_context('Evaluate_Checks_Rel',
									'chk_id=>'||to_char(chk_id),
									'party_id=>'||to_char(cparty_id),
									'account_id=>'|| NULL
									,'party_site_id =>'||to_char(cpsite_id) -- added by spamujul for ER#8473903
									);
									g_error := sqlcode || ' ' || sqlerrm;
									set_context(NULL, g_error);
						End;
							-- End fix by spamujul for  ER#8473903
				END LOOP;
			CLOSE crelparty_csr;
			-- Begin fix by spamujul for ER#8473903
			IF l_is_total <> 0 THEN
				 l_for_insert := 'Y';
				 l_for_party  := 'N';
				 l_for_psite   := 'Y';-- added by spamujul for ER#8473903
				 Insert_Update_Check_Results(l_is_total,
										  l_for_insert,
										  l_for_party
										 ,l_for_psite -- added by spamujul for ER#8473903
										  );
				 l_is_total :=0;
		   END IF;
			   IF l_us_total <> 0 THEN
			     l_for_insert := 'N';
			     l_for_party  := 'N';
			     l_for_psite   := 'Y';-- added by spamujul for ER#8473903
			     Insert_Update_Check_Results(l_us_total,
										 l_for_insert,
										 l_for_party
										,l_for_psite -- added by spamujul for ER#8473903
										 );
			     l_us_total :=0;
			  END IF;
		    -- End fix by spamujul for ER#8473903
		      IF (dbms_sql.is_open(cid)) THEN
			  dbms_sql.close_cursor(cid);
		      END IF;
				 END IF;
		Exception
				When others then
				  IF (dbms_sql.is_open(cid)) THEN
				      dbms_sql.close_cursor(cid);
				  end if;
				  set_context('Evaluate_Checks_Rel',
					'chk_id			=>'||to_char(chk_id),
					'party_id			=>'||to_char(cparty_id),
					'account_id		=>'||NULL,
					'party_site_id	=>'||NULL  -- added by spamujul for ER#8473903
					);
				  g_error := sqlcode || ' ' || sqlerrm;
				  set_context(NULL, g_error);
		End;
   END LOOP;
   CLOSE v_checks_curvar;
   -- check if there are still records to be inserted
   IF l_ip_total <> 0 THEN
	l_for_insert := 'Y';
	l_for_party  := 'Y';
	l_for_psite   := 'N';-- added by spamujul for ER#8473903
	Insert_Update_Check_Results(l_ip_total,
						       l_for_insert,
						       l_for_party
						       ,l_for_psite  -- added by spamujul for ER#8473903
						       );
	l_ip_total :=0;
   END IF;
   -- check if there are still records to be updated
   IF l_up_total <> 0 THEN
	l_for_insert := 'N';
	l_for_party  := 'Y';
	l_for_psite   := 'N';-- added by spamujul for ER#8473903
	Insert_Update_Check_Results (l_up_total,
							  l_for_insert,
							  l_for_party
							 ,l_for_psite -- added by spamujul for ER#8473903
							  );
	l_up_total :=0;
   END IF;

   COMMIT;

   -- Return 0 for successful completion, 1 for warnings, 2 for error
   IF (error_flag) THEN
      errbuf := Sqlerrm;
      retcode := 2;
   ELSIF (warning_msg <> '') THEN
      errbuf := warning_msg;
      retcode := 1;
   ELSE
      errbuf := '';
      retcode := 0;
   END IF;

   IF (debug) THEN
      fnd_file.close;
   END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         IF (v_checks_curvar%isopen) THEN
	    CLOSE v_checks_curvar;
	 END IF;
	 IF (crelparty_csr%isopen) THEN
	    CLOSE crelparty_csr;
	 END IF;

	 IF (debug) THEN
	    fnd_file.close;
	 END IF;
         errbuf := Sqlerrm;
         retcode := 2;

	 g_error := sqlcode || ' ' || sqlerrm;
	 fnd_file.put_line(fnd_file.log , g_error);

END Evaluate_Checks_Rel;

/* R12 Employee HelpDesk Modifications */

PROCEDURE Evaluate_Blocks_Emp( p_up_total      IN OUT NOCOPY NUMBER ,
								    p_ip_total      IN OUT NOCOPY NUMBER ,
								    p_ua_total      IN OUT NOCOPY NUMBER ,
								    p_ia_total      IN OUT NOCOPY NUMBER ,
								    p_us_total	  IN OUT NOCOPY NUMBER, -- added by spamujul for ER#8473903
								    p_is_total	  IN OUT NOCOPY NUMBER, -- added by spamujul for ER#8473903
								    p_group_id      IN NUMBER DEFAULT NULL,
								    p_no_batch_sql  IN VARCHAR2 DEFAULT NULL,
								    p_rule_only     IN VARCHAR2 DEFAULT NULL
								) IS
  truncate_flag		Varchar2(1):= 'N';
  l_for_insert		varchar2(1) := 'Y';
  l_for_party		varchar2(1) := 'Y';
  l_for_psite		Varchar2(1) := 'N'; -- Added by spamujul for ER#8473903
  v_employee_in_sql	Number := 0;
  v_party_id            Number;
  v_block_id            Number;
  v_block_curvar  blocks_curtype;
  v_rec_var  r_blk_rectype;

   CURSOR employee_csr IS
      SELECT person_id
      FROM per_workforce_current_x;
    cid 	number;
    val		VARCHAR2(240) := null;
BEGIN
   BEGIN
  IF p_group_id IS NULL THEN
      IF p_no_batch_sql = 'Y' THEN
         OPEN v_block_curvar FOR
         SELECT block_id, sql_stmnt, currency_code
           FROM csc_prof_blocks_b a
          WHERE EXISTS ( SELECT null
                           FROM csc_prof_checks_b b
                          WHERE b.select_block_id = a.block_id
                            AND b.select_type = 'B'
                            AND check_id IN (SELECT check_id FROM csc_prof_group_checks))
			   AND SYSDATE BETWEEN Nvl(start_date_active, SYSDATE)
                            AND Nvl(end_date_active, SYSDATE)
		            AND batch_sql_stmnt IS NULL
                            AND block_level = 'EMPLOYEE';
      ELSIF p_rule_only = 'Y' THEN
         OPEN v_block_curvar FOR
         SELECT block_id, sql_stmnt, currency_code
           FROM csc_prof_blocks_b a
          WHERE exists ( SELECT b.block_id
                           FROM csc_prof_check_rules_b b, csc_prof_checks_b c
                          WHERE (b.block_id  = a.block_id
                                 or b.expr_to_block_id = a.block_id)
                            AND c.select_type = 'T'
                            AND b.check_id = c.check_id)
                            AND Sysdate BETWEEN Nvl(start_date_active, Sysdate)
                            AND Nvl(end_date_active, Sysdate)
                            AND block_level ='EMPLOYEE';
      ELSE
         OPEN v_block_curvar FOR
         SELECT block_id, sql_stmnt, currency_code
           FROM csc_prof_blocks_b a
          WHERE exists ( Select b.block_id
                           From csc_prof_check_rules_b b
                          where b.block_id  = a.block_id
                             or b.expr_to_block_id = a.block_id)
                           AND Sysdate BETWEEN Nvl(start_date_active, Sysdate)
                           AND Nvl(end_date_active, Sysdate)
                           AND block_level ='EMPLOYEE';
      END IF;
  ELSE
      IF p_no_batch_sql = 'Y' THEN
         OPEN v_block_curvar FOR
         SELECT block_id, sql_stmnt, currency_code
           FROM csc_prof_blocks_b a
          WHERE EXISTS ( SELECT null
                           FROM csc_prof_checks_b b
                          WHERE b.select_block_id = a.block_id
                            AND b.select_type = 'B'
                            AND check_id IN (SELECT check_id FROM csc_prof_group_checks
                                              WHERE group_id = p_group_id))
                            AND SYSDATE BETWEEN Nvl(start_date_active, SYSDATE)
                            AND Nvl(end_date_active, SYSDATE)
                            AND batch_sql_stmnt IS NULL
                            AND block_level = 'EMPLOYEE';
      ELSIF p_rule_only = 'Y' THEN
         OPEN v_block_curvar FOR
         SELECT block_id, sql_stmnt, currency_code
         FROM csc_prof_blocks_b a
         WHERE EXISTS ( SELECT b.block_id
                          FROM csc_prof_check_rules_b b, csc_prof_checks_b c
                         WHERE (b.block_id = a.block_id
                                OR b.expr_to_block_id = a.block_id)
                           AND c.select_type = 'T'
                           AND b.check_id = c.check_id
                           AND b.check_id IN (SELECT check_id from csc_prof_group_checks
                                             WHERE group_id = p_group_id))
                           AND Sysdate BETWEEN Nvl(start_date_active, Sysdate)
                           AND Nvl(end_date_active, Sysdate)
                           AND block_level = 'EMPLOYEE';
      ELSE
         OPEN v_block_curvar FOR
         SELECT block_id, sql_stmnt, currency_code
           FROM csc_prof_blocks_b a
          WHERE EXISTS ( SELECT b.block_id
                           FROM csc_prof_check_rules_b b
                          WHERE (b.block_id = a.block_id
                                 or b.expr_to_block_id = a.block_id)
                          AND check_id IN (Select check_id from csc_prof_group_checks
                             where group_id = p_group_id))
                          AND Sysdate BETWEEN Nvl(start_date_active, Sysdate)
                          AND Nvl(end_date_active, Sysdate)
                          AND block_level ='EMPLOYEE';
      END IF;

   END IF;

   LOOP
      FETCH v_block_curvar INTO v_rec_var;
      EXIT WHEN v_block_curvar%notfound;
      v_employee_in_sql := INSTR(lower(v_rec_var.sql_stmnt),':employee_id',1);
      v_block_id := v_rec_var.block_id;
      BEGIN
	      cid := dbms_sql.open_cursor;
	      dbms_sql.parse(cid, v_rec_var.sql_stmnt, dbms_sql.native);
	      dbms_sql.define_column(cid, 1, val, 240);

	      OPEN employee_csr;
	      LOOP
		   FETCH employee_csr INTO v_party_id;
		   EXIT WHEN employee_csr%notfound;

		   Evaluate_One_Block(truncate_flag,
						    v_block_id,
						    v_party_id,
					  	    null,
						    NULL,-- added by spamujul for ER#8473903
						    v_rec_var.sql_stmnt,
						    v_rec_var.currency,
					            p_up_total,
						    p_ip_total,
						    p_ua_total,
						    p_ia_total,
						    p_us_total, -- added by spamujul for ER#8473903
						    p_is_total, -- added by spamujul for ER#8473903
						    cid);
	      END LOOP;
	      CLOSE employee_csr;

	      IF (dbms_sql.is_open(cid)) THEN
	        dbms_sql.close_cursor(cid);
	      END IF;

     EXCEPTION
     WHEN others THEN
          IF (dbms_sql.is_open(cid)) THEN
              dbms_sql.close_cursor(cid);
          END IF;

          set_context('Evaluate_Blocks_Emp', v_block_id, v_party_id);
          g_error := sqlcode || ' ' || sqlerrm;
          set_context(NULL, g_error);
     END;

   END LOOP;
   CLOSE v_block_curvar;

   -- check if there are still records to be inserted
   IF p_ip_total <> 0 THEN
	l_for_insert	:= 'Y';
	l_for_party	:= 'Y';
	l_for_psite	:= 'N'; -- Added by spamujul for ER#8473903
	Insert_Update_Block_Results(p_ip_total,
							l_for_insert,
							l_for_party
							,l_for_psite  -- Added by spamujul for ER#8473903
							);
	p_ip_total :=0;
   END IF;
   -- check if there are still records to be updated
   IF p_up_total <> 0 THEN
	l_for_insert := 'N';
	l_for_party  := 'Y';
	l_for_psite	:= 'N'; -- Added by spamujul for ER#8473903
	Insert_Update_Block_Results(p_up_total,
							l_for_insert,
							l_for_party
							,l_for_psite  -- Added by spamujul for ER#8473903
							);
	p_up_total :=0;
   END IF;


   EXCEPTION
      WHEN OTHERS THEN
       IF (v_block_curvar%isopen) THEN
	     CLOSE v_block_curvar;
       END IF;
       IF (employee_csr%isopen) THEN
	      CLOSE employee_csr;
       END IF;

       set_context('Evaluate_Blocks_Emp', v_block_id, v_party_id);
       g_error := sqlcode || ' ' || sqlerrm;
       set_context(NULL, g_error);
       table_delete;
       RAISE;
  END;

END Evaluate_Blocks_Emp;

PROCEDURE Evaluate_Checks_Emp ( errbuf	OUT	NOCOPY VARCHAR2,
									retcode	OUT	NOCOPY NUMBER,
									p_group_id  IN NUMBER   DEFAULT NULL,
									p_no_batch_sql  IN VARCHAR2 DEFAULT NULL,
									p_rule_only     IN VARCHAR2 DEFAULT NULL ) IS
  chk_id				Number;
  chk_name			Varchar2(240);
  cparty_id			Number;
  sel_type			Varchar2(3);
  sel_blk_id			Number;
  data_type			Varchar2(90);
  fmt_mask			Varchar2(90);
  rule				Varchar2(32767);
  chk_u_l_flag		Varchar2(3);
  Thd_grade			Varchar2(9);
  truncate_flag		Varchar2(1) := 'N';
  acct_flag			Varchar2(1);
  blk_id				Number 		:= null;
  blk_name			Varchar2(240)	:= null;
  sql_stmt			Varchar2(2000)	:= null;
  curr_code			Varchar2(15)	:= null;
  v_employee_in_sql     Number :=0;
  l_for_insert			varchar2(1) := 'Y';
  l_for_party			varchar2(1) := 'Y';
  l_for_psite			Varchar2(1) := 'N'; -- Added by spamujul for ER#8473903
  l_up_total			Number := 0;
  l_ip_total			Number := 0;
  l_ua_total			Number := 0;
  l_ia_total			Number := 0;
  l_us_total			Number := 0;  -- added by spamujul for ER#8473903
  l_is_total			Number := 0;  -- added by spamujul for ER#8473903
  v_party_id			Number;
  v_check_level		Varchar2(10);
    v_checks_curvar  checks_curtype;
  v_rec_var  r_chk_rectype;

  CURSOR block_csr IS
      SELECT block_id, sql_stmnt, currency_code
      FROM csc_prof_blocks_b a
      WHERE a.block_id = sel_blk_id;

   CURSOR employee_csr IS
      SELECT person_id
      FROM per_workforce_current_x;


    cid 	number;
    val		VARCHAR2(240) := null;

BEGIN
   l_ip_total := 0;
   l_up_total := 0;
   l_ia_total := 0;
   l_ua_total := 0;
   l_us_total := 0;  -- added by spamujul for ER#8473903
   l_is_total   := 0;  -- added by spamujul for ER#8473903
   IF p_group_id IS NULL THEN
      IF p_no_batch_sql = 'Y' THEN
         OPEN v_checks_curvar FOR
         SELECT check_id, select_type, select_block_id,
                data_type, format_mask, check_upper_lower_flag,
                threshold_grade, check_level
           FROM csc_prof_checks_b a
           WHERE check_id IN (SELECT check_id FROM csc_prof_group_checks)
            AND select_type = 'B'
            AND check_level = 'EMPLOYEE'
            AND EXISTS (SELECT null
                          FROM csc_prof_blocks_b b
                         WHERE a.select_block_id = b.block_id
                           AND b.batch_sql_stmnt IS NULL)
            AND SYSDATE BETWEEN Nvl(start_date_active, SYSDATE)
                            AND Nvl(end_date_active, SYSDATE);
      ELSIF p_rule_only = 'Y' THEN
         OPEN v_checks_curvar FOR
         SELECT check_id, select_type, select_block_id,
                data_type, format_mask,check_upper_lower_flag,threshold_grade,
                check_level
           FROM csc_prof_checks_b
          WHERE check_level ='EMPLOYEE'
            AND select_type = 'T'
            AND Sysdate BETWEEN Nvl(start_date_active, Sysdate)
                AND Nvl(end_date_active, Sysdate);
      ELSE
         OPEN v_checks_curvar FOR
         SELECT check_id, select_type, select_block_id,
                data_type, format_mask,check_upper_lower_flag,threshold_grade,
                check_level
           FROM csc_prof_checks_b
          WHERE check_level ='EMPLOYEE'
            AND Sysdate BETWEEN Nvl(start_date_active, Sysdate)
                AND Nvl(end_date_active, Sysdate);
      END IF;
   ELSE
      IF p_no_batch_sql = 'Y' THEN
         OPEN v_checks_curvar FOR
         SELECT check_id, select_type, select_block_id,
                data_type, format_mask,check_upper_lower_flag,
	        threshold_grade, check_level
           FROM csc_prof_checks_b a
          WHERE check_id IN (SELECT check_id FROM csc_prof_group_checks
                              WHERE group_id = p_group_id)
            AND select_type = 'B'
            AND check_level = 'EMPLOYEE'
            AND EXISTS (SELECT null
                          FROM csc_prof_blocks_b b
                         WHERE a.select_block_id = b.block_id
                           AND b.batch_sql_stmnt IS NULL)
            AND SYSDATE BETWEEN Nvl(start_date_active, SYSDATE)
                            AND Nvl(end_date_active, SYSDATE);
      ELSIF p_rule_only = 'Y' THEN
         OPEN v_checks_curvar FOR
          SELECT check_id, select_type, select_block_id,
                 data_type, format_mask,check_upper_lower_flag,threshold_grade,
                 check_level
            FROM csc_prof_checks_b
           WHERE check_level = 'EMPLOYEE'
             AND select_type = 'T'
             AND check_id in (select check_id from csc_prof_group_checks
                               where group_id = p_group_id)
             And Sysdate BETWEEN Nvl(start_date_active, Sysdate)
	     AND Nvl(end_date_active, Sysdate);
      ELSE
         OPEN v_checks_curvar FOR
          SELECT check_id, select_type, select_block_id,
                 data_type, format_mask,check_upper_lower_flag,threshold_grade,
                 check_level
            FROM csc_prof_checks_b
           WHERE check_level = 'EMPLOYEE'
             AND check_id in (select check_id from csc_prof_group_checks
                               where group_id = p_group_id)
             And Sysdate BETWEEN Nvl(start_date_active, Sysdate)
	     AND Nvl(end_date_active, Sysdate);
      END IF;
   END IF;

   LOOP
       FETCH v_checks_curvar INTO v_rec_var;
        sel_type := v_rec_var.select_type;
        chk_id := v_rec_var.check_id;
        sel_blk_id := v_rec_var.select_block_id;
        v_check_level:= v_rec_var.check_level;
        data_type:=v_rec_var.data_type;
        fmt_mask:=v_rec_var.format_mask;
        chk_u_l_flag:= v_rec_var.check_upper_lower_flag;
        thd_grade := v_rec_var.threshold_grade;

       EXIT WHEN v_checks_curvar%notfound;
       IF (sel_type = 'T') THEN
   	   build_rule('N',chk_id,v_check_level, rule);
       ELSIF (sel_type = 'B') THEN
	      Open block_csr;
	      Fetch block_csr INTO blk_id, sql_stmt, curr_code;
	      Close block_csr;

	     IF sql_stmt IS NOT NULL Then
	       v_employee_in_sql := INSTR(lower(sql_stmt),':employee_id',1);
	     Else
	       v_employee_in_sql := 0;
	     End if;
	   END IF;

      BEGIN

        IF ((sel_type='B' ) OR  (sel_type='T') ) THEN
           cid := dbms_sql.open_cursor;


	     IF (sel_type='B') THEN

                dbms_sql.parse(cid, sql_stmt, dbms_sql.native);
	      ELSIF (sel_type = 'T') THEN
	         dbms_sql.parse(cid, rule, dbms_sql.native);
             END IF;

    	        dbms_sql.define_column(cid,1,val,240);
    	    OPEN employee_csr;

	       LOOP
	        FETCH employee_csr INTO cparty_id;
	        EXIT WHEN employee_csr%notfound;
                Evaluate_One_Check(truncate_flag,
						   chk_id,
						   cparty_id,
						   null,
						   NULL,  -- added by spamujul for ER#8473903
						   v_check_level,
						    sel_type,
						    sel_blk_id,
						    data_type,
						    fmt_mask,
						    chk_u_l_flag,
						    Thd_grade,
						    rule,
						    blk_id,
						    sql_stmt,
						    curr_code,
						    l_up_total,
						    l_ip_total,
						    l_ua_total,
						    l_ia_total ,
						    l_us_total,  -- added by spamujul for ER#8473903
						    l_is_total,  -- added by spamujul for ER#8473903
						    cid);
	       END LOOP;
	       CLOSE employee_csr;
 	      IF (dbms_sql.is_open(cid)) THEN
	          dbms_sql.close_cursor(cid);
	      END IF;
        END IF;


          IF (dbms_sql.is_open(cid)) THEN
              dbms_sql.close_cursor(cid);
          end if;

    End;

   END LOOP;
   CLOSE v_checks_curvar;



   -- check if there are still records to be inserted
   IF l_ip_total <> 0 THEN
	l_for_insert := 'Y';
	l_for_party  := 'Y';
	l_for_psite   := 'N';-- added by spamujul for ER#8473903
	Insert_Update_Check_Results(l_ip_total,
						       l_for_insert,
						       l_for_party
						       ,l_for_psite  -- added by spamujul for ER#8473903
						       );
	l_ip_total :=0;
   END IF;
   -- check if there are still records to be updated
   IF l_up_total <> 0 THEN
	l_for_insert := 'N';
	l_for_party  := 'Y';
	l_for_psite   := 'N';-- added by spamujul for ER#8473903
	Insert_Update_Check_Results (l_up_total,
							  l_for_insert,
							  l_for_party
							 ,l_for_psite -- added by spamujul for ER#8473903
							  );
	l_up_total :=0;
   END IF;

   COMMIT;

   -- Return 0 for successful completion, 1 for warnings, 2 for error
   IF (error_flag) THEN
      errbuf := Sqlerrm;
      retcode := 2;
   ELSIF (warning_msg <> '') THEN
      errbuf := warning_msg;
      retcode := 1;
   ELSE
      errbuf := '';
      retcode := 0;
   END IF;

   IF (debug) THEN
      fnd_file.close;
   END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         IF (v_checks_curvar%isopen) THEN
	    CLOSE v_checks_curvar;
	 END IF;
	 IF (employee_csr%isopen) THEN
	    CLOSE employee_csr;
	 END IF;

	 IF (debug) THEN
	    fnd_file.close;
	 END IF;
         errbuf := Sqlerrm;
         retcode := 2;

	 g_error := sqlcode || ' ' || sqlerrm;
	 fnd_file.put_line(fnd_file.log , g_error);

END Evaluate_Checks_Emp;

/* End of R12 Employee HelpDesk Modifications */
--
-- Evaluate_One_Block
--   Execute dynamic SQL to evaluate the given building block and store the
--   result in the CSC_PROF_BLOCK_RESULTS table.
-- IN
--   blk_id 	- profile check building block identifier
--   party_id 	- customer identifier for which building block is evaluated
--   acct_id 	- account id
--   sql_stmt 	- sql statement to execute dynamically
--   P_CID 	- Cursor passed from calling routine to avoid re-parsing the same sql statement
--
PROCEDURE Evaluate_One_Block
		  ( p_truncate_flag	IN VARCHAR2,
		    p_blk_id		IN NUMBER,
		    p_party_id		IN NUMBER,
		    p_acct_id		IN NUMBER,
		    p_psite_id		IN     NUMBER DEFAULT NULL, -- added by spamujul for ER#8473903
		    p_sql_stmt		IN VARCHAR2,
		    p_curr_code		IN VARCHAR2,
		    p_up_total      IN OUT NOCOPY NUMBER ,
		    p_ip_total      IN OUT NOCOPY NUMBER ,
		    p_ua_total      IN OUT NOCOPY NUMBER ,
		    p_ia_total      IN OUT NOCOPY NUMBER ,
		    p_us_total	      IN OUT NOCOPY NUMBER, -- added by spamujul for ER#8473903
		    p_is_total	      IN OUT NOCOPY NUMBER, -- added by spamujul for ER#8473903
		    p_cid	    IN	NUMBER) IS

		     cid			NUMBER;
		     val			VARCHAR2(80);
		     curr_code		VARCHAR2(15);
		     dummy		NUMBER;

		     l_for_insert		varchar2(1) := 'Y';
		     l_for_party		varchar2(1) := 'Y';
		     l_for_psite		varchar2(1) := 'N';  -- added by spamujul for ER#8473903

		     v_party_count		Number := 0;
		     v_account_count		Number := 0;
		     v_psite_count		Number := 0; -- added by spamujul for ER#8473903

		     v_party_in_sql	Number := 0;
		     v_acct_in_sql	Number := 0;
		     v_emp_in_sql	Number := 0;
		     v_psite_in_sql	Number := 0;  -- added by spamujul for ER#8473903
/*
     -- for party level
     Cursor party_block_crs IS
	Select count(*)
	From csc_prof_block_results
	Where block_id 	= p_blk_id
	And party_id 	= p_party_id
	And cust_account_id IS NULL;

     -- for account level
     Cursor account_block_crs IS
	Select count(*)
	From csc_prof_block_results
	Where block_id 	= p_blk_id
	And party_id 	= p_party_id
	And cust_account_id = p_acct_id;
*/

BEGIN
      Begin
		-- dbms_output.put_line('Inside evaluate_one_block .p_cid.'||to_char(p_cid));
		 -- P_CID is the Cursor to avoid reparsing the sql stmt
		 -- P_CID would not be null when engine runs for more than 1 party (e.g. evaluate_checks1)
		 -- P_CID would be null when engine is being run for 1 party (e.g. evaluate_checks2)
		 if p_cid is null then
			cid := dbms_sql.open_cursor;
			dbms_sql.parse(cid, p_sql_stmt, dbms_sql.native);
			dbms_sql.define_column(cid, 1, val, 240);
		 else
			cid := p_cid;
		 end if;
		  -- added for 1850508
		  -- if p_old_block_id!=p_blk_id OR p_old_block_id is null then
			-- p_old_block_id:=p_blk_id;
		  -- End If;
		  -- Check for existence of variables before binding
		-- for Bug 1935015 changed instr(sql_stmt..) to INSTR(lower(sql_stmt)..)
		  IF p_sql_stmt IS NOT NULL Then
		      v_party_in_sql :=	INSTR(lower(p_sql_stmt),':party_id',1);
		      v_acct_in_sql  :=	INSTR(lower(p_sql_stmt),':cust_account_id',1);
		      v_emp_in_sql  :=	INSTR(lower(p_sql_stmt),':employee_id',1);
		      v_psite_in_sql :=	INSTR(lower(p_sql_stmt),':party_site_id',1); -- added by spamujul for ER#8473903
		  Else
		      v_party_in_sql :=	0;
		      v_acct_in_sql  :=	0;
		      v_emp_in_sql   :=	 0;
		      v_psite_in_sql :=	0;  -- added by spamujul for ER#8473903
		  End if;
		 -- For Bug 1935015 commented this if statement and created 2 variables
		 -- v_party_in_sql and v_acct_in_sql and used them in the if stmt.
		  --if INSTR(lower(p_sql_stmt),':party_id',1)  > 0 then
		  if v_party_in_sql  > 0 then
			 dbms_sql.bind_variable(cid, ':party_id', p_party_id);
		  end if;
		  --if INSTR(lower(p_sql_stmt),':cust_account_id',1)  > 0 then
		  if v_acct_in_sql  > 0 then
			 dbms_sql.bind_variable(cid, ':cust_account_id', p_acct_id);
		  end if;
		  if v_emp_in_sql  > 0 then
			 dbms_sql.bind_variable(cid, ':employee_id', p_party_id);
		  end if;
		  -- Begin fix by spamujul for NCR  ER#8473903
		   If v_psite_in_sql  > 0 then
		         dbms_sql.bind_variable(cid, ':party_site_id', p_psite_id);
		  End if;
		    -- End fix by spamujul for NCR  ER#8473903
		  /***********************
		  dbms_sql.bind_variable(cid, ':party_id', p_party_id);
		  dbms_sql.bind_variable(cid, ':cust_account_id', p_acct_id);
		  ***************/
		  dummy := dbms_sql.execute_and_fetch(cid);
		  dbms_sql.column_value(cid, 1, val);
		  if p_cid is null then
			dbms_sql.close_cursor(cid);
		  end if;
	      Exception
		When Others Then
			-- dbms_output.put_line('Exception Others in Blocks...');
		     if p_cid is null then
			IF (dbms_sql.is_open(cid)) THEN
			     dbms_sql.close_cursor(cid);
			end if;
		     end if;
		     val := 0;
	End;
	If  p_psite_id IS NULL THEN  -- Added by spamujul for NCR ER#8473903
		IF p_acct_id IS NULL THEN
			 IF p_truncate_flag = 'N' THEN
				   begin
				      select 1 into v_party_count from csc_prof_block_results
				      where block_id = p_blk_id
				      and party_id = p_party_id
				      and cust_account_id is null
				      and party_site_id is NULL -- Added by spamujul for ER#8473903
				      ;
				   exception
				      when no_data_found then
					 v_party_count := 0;
				      when others then
					v_party_count := null;
				    end;
				  /*
					    OPEN party_block_crs;
					    FETCH party_block_crs INTO v_party_count;
					    IF party_block_crs%notfound THEN
					       v_party_count := 0;
					    END IF;
					    CLOSE party_block_crs;
				   */
			ELSE
				v_party_count := 0;
			END IF;
			 IF v_party_count = 0 THEN
			    p_ip_total				:=	p_ip_total + 1;
			    -- assign values to insert party
			    ip_block_id(p_ip_total)	:=	p_blk_id;
			    ip_party_id(p_ip_total)	:=	p_party_id;
			    ip_account_id(p_ip_total)	:= NULL;
			    ip_psite_id(p_ip_total)		:= NULL; -- Added by spamujul for ER#8473903
			    ip_value(p_ip_total)		:= val;
			    ip_currency(p_ip_total)	:=	p_curr_code;
			    IF p_ip_total = 1000 THEN
				l_for_insert	:= 'Y';
				l_for_party	:= 'Y';
				l_for_psite	:= 'N'; -- Added by spamujul for ER#8473903
				Insert_Update_Block_Results	(p_ip_total,
										l_for_insert,
										l_for_party
										,l_for_psite -- Added by spamujul for ER#8473903
										);
				p_ip_total :=0;
			    END IF;
			 ELSIF v_party_count = 1 THEN
				    p_up_total					:= p_up_total + 1;
				    -- assign values to update party tables
				    up_block_id(p_up_total)		:= p_blk_id;
				    up_party_id(p_up_total)		:= p_party_id;
				    up_account_id(p_up_total)		:= NULL;
				    up_psite_id(p_up_total)		:= NULL; -- Added by spamujul for ER#8473903
				    up_value(p_up_total)			:= val;
				    up_currency(p_up_total)		:= p_curr_code;
				    IF p_up_total = 1000 THEN
					l_for_insert := 'N';
					l_for_party  := 'Y';
					l_for_psite   := 'N'; -- Added by spamujul for ER#8473903
					Insert_Update_Block_Results (p_up_total,
											 l_for_insert,
											 l_for_party
											,l_for_psite -- Added by spamujul for ER#8473903
											 );
					p_up_total := 0;
				    END IF;
			 END IF;
		      ELSE
				 IF p_truncate_flag = 'N' THEN
				    begin
				      select 1 into v_account_count from csc_prof_block_results
				      where block_id = p_blk_id
				      and party_id = p_party_id
				      and cust_account_id = p_acct_id
				      and party_site_id  is null -- Added by spamujul for ER#8473903
				      ;
				    exception when no_data_found then
					v_account_count := 0;
				    when others then
					v_account_count := null;
				    end;

					/*	    OPEN account_block_crs;
						    FETCH account_block_crs INTO v_account_count;
						    IF account_block_crs%notfound THEN
						       v_account_count := 0;
						    END IF;
						    CLOSE account_block_crs;
					 */
				 ELSE
				   v_account_count := 0;
				 END IF;
				 IF v_account_count = 0 THEN
					    p_ia_total := p_ia_total + 1;

					    -- assign values to insert
					    ia_block_id(p_ia_total) := p_blk_id;
					    ia_party_id(p_ia_total) := p_party_id;
					    ia_account_id(p_ia_total) := p_acct_id;
					    ia_psite_id(p_ia_total) := NULL; -- Added by spamujul for ER#8473903
					    ia_value(p_ia_total) := val;
					    ia_currency(p_ia_total) := p_curr_code;
					    IF p_ia_total = 1000 THEN
						l_for_insert := 'Y';
						l_for_party  := 'N';
						l_for_psite   := 'N'; -- Added by spamujul for ER#8473903
						Insert_Update_Block_Results 	(p_ia_total,
												 l_for_insert,
												 l_for_party
												 ,l_for_psite  -- Added by spamujul for ER#8473903
												 );
						p_ia_total := 0;
					    END IF;
				 ELSIF v_account_count = 1 THEN
					    p_ua_total := p_ua_total + 1;
					    -- assign values to update party tables
					    ua_block_id(p_ua_total) := p_blk_id;
					    ua_party_id(p_ua_total) := p_party_id;
					    ua_account_id(p_ua_total) := p_acct_id;
					    ua_psite_id(p_ua_total) := NULL;  -- Added by spamujul for ER#8473903
					    ua_value(p_ua_total) := val;
					    ua_currency(p_ua_total) := p_curr_code;
					    IF p_ua_total = 1000 THEN
						l_for_insert := 'N';
						l_for_party  := 'N';
						l_for_psite   := 'N'; -- Added by spamujul for ER#8473903
						Insert_Update_Block_Results(p_ua_total,
												l_for_insert,
												l_for_party
												,l_for_psite  -- Added by spamujul for ER#8473903
												);
						p_ua_total := 0;
					    END IF;
				 END IF;
			END IF;
-- Begin fix by spamujul fro NCR ER#8473903
	ELSE
		IF p_truncate_flag = 'N' THEN
				    begin
				      select 1 into v_psite_count from csc_prof_block_results
				      where block_id = p_blk_id
				      and party_id = p_party_id
				      and cust_account_id   IS NULL
				      and party_site_id  =p_psite_id ;

				    Exception when no_data_found then
							v_psite_count := 0;
					when others then
							v_psite_count := null;
				    end;

		 ELSE
				   v_psite_count := 0;
		 END IF;
		 IF v_psite_count = 0 THEN
		 	    p_is_total					:= p_is_total + 1;
			    is_block_id(p_is_total)		:= p_blk_id;
			    is_party_id(p_is_total)		:= p_party_id;
			    is_account_id(p_is_total)	:= p_acct_id;
			    is_psite_id(p_is_total)		:= p_psite_id;
			    is_value(p_is_total)		:= val;
			    is_currency(p_is_total)	:= p_curr_code;
			    IF p_ia_total = 1000 THEN
				l_for_insert := 'Y';
				l_for_party  := 'N';
				l_for_psite   := 'Y';
				Insert_Update_Block_Results 	(p_is_total,
										 l_for_insert,
										 l_for_party
										 ,l_for_psite
										 );
				p_is_total := 0;
			    END IF;
		 ELSIF v_psite_count = 1 THEN
			    p_us_total := p_us_total + 1;
			    -- assign values to update party tables
			    us_block_id(p_us_total) := p_blk_id;
			    us_party_id(p_us_total) := p_party_id;
			    us_account_id(p_us_total) := p_acct_id;
			    us_psite_id(p_us_total) :=p_psite_id;
			    us_value(p_us_total) := val;
			    us_currency(p_us_total) := p_curr_code;
			    IF p_us_total = 1000 THEN
				l_for_insert := 'N';
				l_for_party  := 'N';
				l_for_psite   := 'Y';
				Insert_Update_Block_Results(p_us_total,
										l_for_insert,
										l_for_party
										,l_for_psite
										);
				p_us_total := 0;
			    END IF;
		 END IF;
	END IF;
-- End  fix by spamujul fro NCR ER#8473903
      EXCEPTION
        -- If an exception is raised, close cursor before exiting
        WHEN OTHERS THEN
		-- dbms_output.put_line('Exception Others in Blocks...');
	   if p_cid is null then
		   IF (dbms_sql.is_open(cid)) THEN
			dbms_sql.close_cursor(cid);
		   END IF;
	   end if;
	   set_context('Evaluate_One_Block',
			  'blk_id=>'||to_char(p_blk_id),
			  'party_id=>'||to_char(p_party_id),
			  'account_id=>'||to_char(p_acct_id));
           g_error := sqlcode || ' ' || sqlerrm;
           set_context(NULL, g_error);
END Evaluate_One_Block;


--
-- Insert or Update Records into Csc_Prof_Block_Results Table
-- IN
--    p_count	   - the number of records to be inserted or updated
--    p_for_party  - flag to check if the insert or update is for party or account
--    p_for_insert - flag to check if for insert or update.
--
PROCEDURE Insert_Update_Block_Results
					( p_count	IN Number,
					  p_for_insert	IN Varchar2,
					  p_for_party	IN Varchar2
					  ,p_for_psite	IN Varchar2 -- Added by spamujul for ER#8473903
					  ) IS

TABLESEGMENT_FULL                EXCEPTION;
INDEXSEGMENT_FULL                EXCEPTION;
SNAPSHOT_TOO_OLD		  EXCEPTION;

PRAGMA EXCEPTION_INIT(TABLESEGMENT_FULL, -1653);
PRAGMA EXCEPTION_INIT(INDEXSEGMENT_FULL, -1654);
PRAGMA EXCEPTION_INIT(SNAPSHOT_TOO_OLD, -1555);

Begin
   -- Default user and login IDs
   --user_id  := fnd_global.user_id;
   --login_id := fnd_global.login_id;
          IF P_FOR_PSITE ='N' Then -- Added by spamujul for ER#8473903
		   IF p_for_party = 'Y' THEN
			-- PARTY level insert or update of records
			IF p_for_insert = 'Y' THEN
			   -- Insert Records into Csc_Prof_Block_Results Table
			   FORALL i IN 1..p_count
				INSERT INTO Csc_Prof_Block_Results
				  ( block_results_id
				    , block_id
				    , party_id
				    , cust_account_id
				    ,party_site_id -- Added by spamujul for ER#8473903
				    , value
				    , currency_code
				    , created_by
				    , creation_date
				    , last_updated_by
				    , last_update_date
				    , last_update_login)
				  VALUES
				   (csc_prof_block_results_s.nextval
				    , ip_block_id(i)
				    , ip_party_id(i)
				    , ip_account_id(i)
				    , ip_psite_id(i) -- Added by spamujul for ER#8473903
				    , ip_value(i)
				    , ip_currency(i)
				    , FND_GLOBAL.USER_ID
				    , Sysdate
				    , FND_GLOBAL.USER_ID
				    , Sysdate
				    , FND_GLOBAL.CONC_LOGIN_ID );

				ip_block_id.DELETE;
				ip_party_id.DELETE;
				ip_account_id.DELETE;
				ip_psite_id.DELETE; -- Added by spamujul for ER#8473903
				ip_value.DELETE;
				ip_currency.DELETE;
			ELSE
			    FORALL i IN 1..p_count
				UPDATE Csc_Prof_Block_Results
				Set value = up_value(i)
				   , currency_code = up_currency(i)
				   , last_updated_by = FND_GLOBAL.USER_ID
				   , last_update_date = sysdate
				   , last_update_login = FND_GLOBAL.CONC_LOGIN_ID
				Where block_id = up_block_id(i)
				And party_id = up_party_id(i)
				AND cust_account_id  IS NULL AND party_site_id  IS NULL -- Added by spamujul for ER#8473903
				;
				up_block_id.DELETE;
				up_party_id.DELETE;
				up_account_id.DELETE;
				up_psite_id.DELETE; -- Added by spamujul for ER#8473903
				up_value.DELETE;
				up_currency.DELETE;
			END IF;
		   ELSE
			-- ACCOUNT level insert or update of records
			IF p_for_insert = 'Y' THEN
			   -- Insert Records into Csc_Prof_Block_Results Table
			   FORALL i IN 1..p_count
				INSERT INTO Csc_Prof_Block_Results
				  ( block_results_id
				    , block_id
				    , party_id
				    , cust_account_id
				    , party_site_id -- Added by spamujul for ER#8473903
				    , value
				    , currency_code
				    , created_by
				    , creation_date
				    , last_updated_by
				    , last_update_date
				    , last_update_login)
				  VALUES
				   (csc_prof_block_results_s.nextval
				    , ia_block_id(i)
				    , ia_party_id(i)
				    , ia_account_id(i)
				    , ia_psite_id(i) -- Added by spamujul for ER#8473903
				    , ia_value(i)
				    , ia_currency(i)
				    , FND_GLOBAL.USER_ID
				    , Sysdate
				    , FND_GLOBAL.USER_ID
				    , Sysdate
				    , FND_GLOBAL.CONC_LOGIN_ID );

				ia_block_id.DELETE;
				ia_party_id.DELETE;
				ia_account_id.DELETE;
				ia_psite_id.DELETE; -- Added by spamujul for ER#8473903
				ia_value.DELETE;
				ia_currency.DELETE;
			ELSE
			    FORALL i IN 1..p_count
				UPDATE Csc_Prof_Block_Results
				Set value = ua_value(i)
				   , currency_code = ua_currency(i)
				   , last_updated_by = FND_GLOBAL.USER_ID
				   , last_update_date = sysdate
				   , last_update_login = FND_GLOBAL.CONC_LOGIN_ID
				Where block_id = ua_block_id(i)
				And party_id = ua_party_id(i)
				And cust_account_id = ua_account_id(i)
				And party_site_id IS NULL -- Added by spamujul for ER#8473903
				;

				ua_block_id.DELETE;
				ua_party_id.DELETE;
				ua_account_id.DELETE;
				ua_psite_id.DELETE; -- Added by spamujul for ER#8473903
				ua_value.DELETE;
				ua_currency.DELETE;
			END IF;
		   END IF;
-- Begin fix by spamujul for NCR ER# 8473903
	ELSE
		      IF p_for_insert = 'Y' THEN
			   -- Insert Records into Csc_Prof_Block_Results Table
			   FORALL i IN 1..p_count
			       INSERT INTO Csc_Prof_Block_Results
				  (  block_results_id
				    , block_id
				    , party_id
				    , cust_account_id
				    , value
				    , currency_code
				    , created_by
				    , creation_date
				    , last_updated_by
				    , last_update_date
				    , last_update_login
				    , party_site_id
				   )
				  VALUES
				   (csc_prof_block_results_s.nextval
				    , is_block_id(i)
				    , is_party_id(i)
				    , is_account_id(i)
				    , is_value(i)
				    , is_currency(i)
				    , FND_GLOBAL.USER_ID
				    , Sysdate
				    , FND_GLOBAL.USER_ID
				    , Sysdate
				    , FND_GLOBAL.CONC_LOGIN_ID
				     , is_psite_id(i)
				   );
				is_block_id.DELETE;
				is_party_id.DELETE;
				is_account_id.DELETE;
				is_psite_id.DELETE;
				is_value.DELETE;
				is_currency.DELETE;
			ELSE
			    FORALL i IN 1..p_count
				UPDATE Csc_Prof_Block_Results
				Set value = us_value(i)
				   , currency_code = us_currency(i)
				   , last_updated_by = FND_GLOBAL.USER_ID
				   , last_update_date = sysdate
				   , last_update_login = FND_GLOBAL.CONC_LOGIN_ID
				Where block_id = us_block_id(i)
				And party_id = us_party_id(i)
				And cust_account_id IS NULL
				And party_site_id = us_psite_id(i)
				;
				us_block_id.DELETE;
				us_party_id.DELETE;
				us_account_id.DELETE;
				us_psite_id.DELETE;
				us_value.DELETE;
				us_currency.DELETE;
			END IF;
	END IF;
-- End fix by spamujul for NCR ER# 8473903
   commit;

exception
       when Indexsegment_full then
             g_error := sqlcode || ' ' || sqlerrm;
             fnd_file.put_line(fnd_file.log , g_error);
             App_Exception.raise_exception;

        when Tablesegment_full then
             g_error := sqlcode || ' ' || sqlerrm;
             fnd_file.put_line(fnd_file.log , g_error);
             App_Exception.raise_exception;

        WHEN SNAPSHOT_TOO_OLD THEN
             g_error := sqlcode || ' ' || sqlerrm;
             fnd_file.put_line(fnd_file.log,g_error);
             App_Exception.raise_exception;

	when Others then
	    table_delete;
	     g_error := sqlcode || ' ' || sqlerrm;
	     fnd_file.put_line(fnd_file.log , g_error);

END Insert_Update_Block_Results;

--
-- Insert or Update Records into Csc_Prof_Check_Results Table
-- IN
--    p_count	   - the number of records to be inserted or updated
--    p_for_party  - flag to check if the insert or update is for party or account
--    p_for_insert - flag to check if for insert or update.
--
PROCEDURE Insert_Update_Check_Results ( p_count      IN NUMBER,
                                        p_for_insert IN VARCHAR2,
                                        p_for_party  IN VARCHAR2 ,
                                        p_for_psite  IN VARCHAR2 -- Added by spamujul for ER#8473903
                                        )
IS
        TABLESEGMENT_FULL EXCEPTION;
        INDEXSEGMENT_FULL EXCEPTION;
        SNAPSHOT_TOO_OLD  EXCEPTION;
        PRAGMA EXCEPTION_INIT(TABLESEGMENT_FULL, -1653);
        PRAGMA EXCEPTION_INIT(INDEXSEGMENT_FULL, -1654);
        PRAGMA EXCEPTION_INIT(SNAPSHOT_TOO_OLD, -1555);
BEGIN
        -- Default user and login IDs
        --user_id  := fnd_global.user_id;
        --login_id := fnd_global.login_id;
        IF p_for_psite         ='N' THEN -- Added by spamujul for ER#8473903
                IF p_for_party = 'Y' THEN
                        -- PARTY level insert or update of records
                        IF p_for_insert = 'Y' THEN
                                -- Insert Records into Csc_Prof_Check_Results Table
                                FORALL i IN 1..p_count
                                INSERT
                                INTO   Csc_Prof_Check_Results
                                       (
                                              check_results_id ,
                                              check_id         ,
                                              party_id         ,
                                              cust_account_id,
                                              party_site_id, -- Added by spamujul for ER#8473903
                                              value                  ,
                                              results_threshold_flag ,
                                              currency_code          ,
                                              grade                  ,
                                              rating_code            ,
                                              color_code             ,
                                              created_by             ,
                                              creation_date          ,
                                              last_updated_by        ,
                                              last_update_date       ,
                                              last_update_login
                                       )
                                       VALUES
                                       (
                                              csc_prof_check_results_s.nextval ,
                                              ip_check_id(i)                   ,
                                              ip_party_id(i)                   ,
                                              ip_account_id(i)                 ,
                                              ip_psite_id(i), -- Added by spamujul for ER#8473903
                                              ip_value(i)        ,
                                              ip_results(i)      ,
                                              ip_currency(i)     ,
                                              ip_grade(i)        ,
                                              ip_rating_code(i)  ,
                                              ip_color_code(i)   ,
                                              FND_GLOBAL.USER_ID ,
                                              SYSDATE            ,
                                              FND_GLOBAL.USER_ID ,
                                              SYSDATE            ,
                                              FND_GLOBAL.CONC_LOGIN_ID
                                       );

                                ip_check_id.DELETE;
                                ip_party_id.DELETE;
                                ip_account_id.DELETE;
                                ip_psite_id.DELETE; -- Added by spamujul for ER#8473903
                                ip_value.DELETE;
                                ip_currency.DELETE;
                                ip_grade.DELETE;
                                ip_rating_code.DELETE;
                                ip_color_code.DELETE;
                                ip_results.DELETE;
                        ELSE
                                FORALL i IN 1..p_count
                                UPDATE Csc_Prof_Check_Results
                                SET    value                  = up_value(i)        ,
                                       results_threshold_flag = up_results(i)      ,
                                       currency_code          = up_currency(i)     ,
                                       grade                  = up_grade(i)        ,
                                       rating_code            = up_rating_code(i)  ,
                                       color_code             = up_color_code(i)   ,
                                       last_updated_by        = FND_GLOBAL.USER_ID ,
                                       last_update_date       = SYSDATE            ,
                                       last_update_login      = FND_GLOBAL.CONC_LOGIN_ID
                                WHERE  check_id               = up_check_id(i)
                                   AND party_id               = up_party_id(i)
                                   AND cust_account_id IS NULL
                                   AND party_site_id IS NULL -- Added by spamujul for ER#8473903
                                       ;

                                up_check_id.DELETE;
                                up_party_id.DELETE;
                                up_account_id.DELETE;
                                up_psite_id.DELETE; -- Added by spamujul for ER#8473903
                                up_value.DELETE;
                                up_currency.DELETE;
                                up_grade.DELETE;
                                up_rating_code.DELETE;
                                up_color_code.DELETE;
                                up_results.DELETE;
                        END IF;
                ELSE
                        -- ACCOUNT level insert or update of records
                        IF p_for_insert = 'Y' THEN
                                -- Insert Records into Csc_Prof_Check_Results Table
                                FORALL i IN 1..p_count
                                INSERT
                                INTO   Csc_Prof_Check_Results
                                       (
                                              check_results_id       ,
                                              check_id               ,
                                              party_id               ,
                                              cust_account_id        ,
					      party_site_id ,  -- Added by spamujul for ER#8473903
                                              value                  ,
                                              results_threshold_flag ,
                                              currency_code          ,
                                              grade                  ,
                                              rating_code            ,
                                              color_code             ,
                                              created_by             ,
                                              creation_date          ,
                                              last_updated_by        ,
                                              last_update_date       ,
                                              last_update_login
                                       )
                                       VALUES
                                       (
                                              csc_prof_check_results_s.nextval ,
                                              ia_check_id(i)                   ,
                                              ia_party_id(i)                   ,
                                              ia_account_id(i)                 ,
					      ia_psite_id(i)                  ,  -- Added by spamujul for ER#8473903
                                              ia_value(i)                      ,
                                              ia_results(i)                    ,
                                              ia_currency(i)                   ,
                                              ia_grade(i)                      ,
                                              ia_rating_code(i)                ,
                                              ia_color_code(i)                 ,
                                              FND_GLOBAL.USER_ID               ,
                                              SYSDATE                          ,
                                              FND_GLOBAL.USER_ID               ,
                                              SYSDATE                          ,
                                              FND_GLOBAL.CONC_LOGIN_ID
                                       );

                                ia_check_id.DELETE;
                                ia_party_id.DELETE;
                                ia_account_id.DELETE;
				ia_psite_id.DELETE; -- Added by spamujul for ER#8473903
                                ia_value.DELETE;
                                ia_currency.DELETE;
                                ia_grade.DELETE;
                                ia_rating_code.DELETE;
                                ia_color_code.DELETE;
                                ia_results.DELETE;
                        ELSE
                                FORALL i IN 1..p_count
                                UPDATE Csc_Prof_Check_Results
                                SET    value                  = ua_value(i)        ,
                                       results_threshold_flag = ua_results(i)      ,
                                       currency_code          = ua_currency(i)     ,
                                       grade                  = ua_grade(i)        ,
                                       rating_code            = ua_rating_code(i)  ,
                                       color_code             = ua_color_code(i)   ,
                                       last_updated_by        = FND_GLOBAL.USER_ID ,
                                       last_update_date       = SYSDATE            ,
                                       last_update_login      = FND_GLOBAL.CONC_LOGIN_ID
                                WHERE  check_id               = ua_check_id(i)
                                   AND party_id               = ua_party_id(i)
                                   AND cust_account_id        = ua_account_id(i)
				   AND party_site_id	 IS NULL  -- Added by spamujul for ER#8473903
				   ;

                                ua_check_id.DELETE;
                                ua_party_id.DELETE;
                                ua_account_id.DELETE;
				ua_psite_id.DELETE;  -- Added by spamujul for ER#8473903
                                ua_value.DELETE;
                                ua_currency.DELETE;
                                ua_grade.DELETE;
                                ua_rating_code.DELETE;
                                ua_color_code.DELETE;
                                ua_results.DELETE;
                        END IF;
                END IF;
--Begin fix by spamujul for ER#8473903
      ELSE
        IF p_for_insert   = 'Y' THEN
                FORALL i IN 1..p_count
                INSERT
                INTO   Csc_Prof_Check_Results
                       (
                              check_results_id       ,
                              check_id               ,
                              party_id               ,
                              cust_account_id        ,
                              party_site_id          ,
                              value                  ,
                              results_threshold_flag ,
                              currency_code          ,
                              grade                  ,
                              rating_code            ,
                              color_code             ,
                              created_by             ,
                              creation_date          ,
                              last_updated_by        ,
                              last_update_date       ,
                              last_update_login
                       )
                       VALUES
                       (
                              csc_prof_check_results_s.nextval ,
                              is_check_id(i)                   ,
                              is_party_id(i)                   ,
                              is_account_id(i)                 ,
                              is_psite_id(i)                   ,
                              is_value(i)                      ,
                              is_results(i)                    ,
                              is_currency(i)                   ,
                              is_grade(i)                      ,
                              is_rating_code(i)                ,
                              is_color_code(i)                 ,
                              FND_GLOBAL.USER_ID               ,
                              SYSDATE                          ,
                              FND_GLOBAL.USER_ID               ,
                              SYSDATE                          ,
                              FND_GLOBAL.CONC_LOGIN_ID
                       );

                is_check_id.DELETE;
                is_party_id.DELETE;
                is_account_id.DELETE;
                is_psite_id.DELETE;
                is_value.DELETE;
                is_currency.DELETE;
                is_grade.DELETE;
                is_rating_code.DELETE;
                is_color_code.DELETE;
                is_results.DELETE;
        ELSE
                FORALL i IN 1..p_count
                UPDATE Csc_Prof_Check_Results
                SET    value                  = us_value(i)        ,
                       results_threshold_flag = us_results(i)      ,
                       currency_code          = us_currency(i)     ,
                       grade                  = us_grade(i)        ,
                       rating_code            = us_rating_code(i)  ,
                       color_code             = us_color_code(i)   ,
                       last_updated_by        = FND_GLOBAL.USER_ID ,
                       last_update_date       = SYSDATE            ,
                       last_update_login      = FND_GLOBAL.CONC_LOGIN_ID
                WHERE  check_id               = us_check_id(i)
                   AND party_id               = us_party_id(i)
                   AND cust_account_id IS NULL
                   AND party_site_id = us_psite_id(i);

                us_check_id.DELETE;
                us_party_id.DELETE;
                us_account_id.DELETE;
                us_psite_id.DELETE;
                us_value.DELETE;
                us_currency.DELETE;
                us_grade.DELETE;
                us_rating_code.DELETE;
                us_color_code.DELETE;
                us_results.DELETE;
        END IF;
   END IF;
-- Begin fix by spamujul for ER#8473903
        COMMIT;
EXCEPTION
WHEN Tablesegment_full THEN
        g_error := SQLCODE
        || ' '
        || sqlerrm;
        fnd_file.put_line(fnd_file.log , g_error);
        App_Exception.raise_exception;
WHEN Indexsegment_full THEN
        g_error := SQLCODE
        || ' '
        || sqlerrm;
        fnd_file.put_line(fnd_file.log , g_error);
        App_Exception.raise_exception;
WHEN SNAPSHOT_TOO_OLD THEN
        g_error := SQLCODE
        || ' '
        || sqlerrm;
        fnd_file.put_line(fnd_file.log,g_error);
        App_Exception.raise_exception;
WHEN OTHERS THEN
        table_delete;
        g_error := SQLCODE
        || ' '
        || sqlerrm;
        fnd_file.put_line(fnd_file.log , g_error);
END Insert_Update_Check_Results;


/*******************************************
  UPDATE_JIT_STATUS
  added this procedure for JIT enhancement -- Bug 4535407
  Updates the columns jit_status, jit_err_code in CCT_MEDIA_ITEMS.
  Called from CSC_PROF_JIT
********************************************/

PROCEDURE update_jit_status ( p_status			 VARCHAR2 DEFAULT NULL,
							      p_err_code		 NUMBER DEFAULT NULL,
							      p_media_item_id	 NUMBER
							   )	IS
	PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
		UPDATE CCT_MEDIA_ITEMS
			SET jit_status = p_status,
			        jit_err_code = p_err_code
		   WHERE media_item_id = p_media_item_id;
		   COMMIT;
END update_jit_status;


/*******************************************
  CSC_PROF_JIT
  added this procedure for JIT enhancement -- Bug 4535407
  Called from OTM java code
  Calls profile engine for the party_id passed from OTM.
  OTM passes the key-value pair in a VARRAY (cct_keyvalue_varr)
********************************************/

PROCEDURE csc_prof_jit ( p_key_value_varr	IN	cct_keyvalue_varr,
						  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
						  p_critical_flag		IN	VARCHAR2 DEFAULT NULL,
						  x_return_status		OUT NOCOPY VARCHAR2,
						  x_msg_count		OUT NOCOPY NUMBER,
						  x_msg_data		OUT NOCOPY VARCHAR2
						 )
					IS
		   l_media_item_id	NUMBER;
		   l_party_id			NUMBER;
		   l_hidden_party_id    NUMBER;
		   l_rel_id			NUMBER;
		   l_acct_id			NUMBER;
		   l_psite_id			NUMBER := NULL; -- added by spamujul for ER#8473903
		   l_resp_id			NUMBER;
		   l_emp_id			NUMBER;
		   l_resp_appl_id		NUMBER;
		   l_party_type		VARCHAR2(30);
		   l_form_name		VARCHAR2(30) := 'CSCCCCRC';
		   l_view_by_acct		VARCHAR2(255);
		   l_view_by			VARCHAR2(255);
		   l_acct_new_old		VARCHAR2(255);
		   l_show_active_acct	 VARCHAR2(255);
		   l_status			VARCHAR2(30);
		   l_group_id			NUMBER;
		   l_which_ivr			VARCHAR2(30);
		   l_media_exists		VARCHAR2(1);
		   l_party_exists		VARCHAR2(1);
		   l_rel_exists		VARCHAR2(1);
		   l_acct_exists		VARCHAR2(1);
		   l_resp_exists		VARCHAR2(1);
		   l_resp_appl_exists	VARCHAR2(1);
		   l_emp_exists		VARCHAR2(1);
		   l_which_ivr_exists	VARCHAR2(1);
		   l_contact_type		VARCHAR2(30);
		   l_critical_flag		VARCHAR2(1);
		   l_party_rec			CSC_UTILS.dashboard_Rec_Type;
		   l_api_name		VARCHAR2(30) := 'CSC_PROF_JIT';
		   l_jit_prg_status		VARCHAR2(30) := 'PROGRESS';
		   l_jit_err_status		VARCHAR2(30) := 'ERROR';
		   l_jit_complete_status VARCHAR2(30) := 'COMPLETED';
		   l_sql_code			NUMBER;
		   CURSOR chk_status IS
		      SELECT jit_status
			FROM CCT_MEDIA_ITEMS
		       WHERE media_item_id = l_media_item_id;

		   CURSOR group_crs IS
		      SELECT a.dashboard_group_id
			FROM csc_prof_module_groups	a,
				     csc_prof_groups_b		b
		       WHERE a.dashboard_group_id = b.group_id
			 AND a.party_type IN (l_party_type, 'ALL')
			 AND a.form_function_name = l_form_name
			 AND (((a.responsibility_id = l_resp_id AND a.resp_appl_id = l_resp_appl_id)
				AND a.responsibility_id IS NOT NULL)
			      OR a.responsibility_id IS NULL)
			 AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(b.start_date_active, SYSDATE))
			 AND TRUNC(NVL(b.end_date_active, SYSDATE))
		      ORDER BY a.party_type desc, a.responsibility_id;

		   CURSOR get_party_type IS
		      SELECT party_type
			FROM hz_parties
		       WHERE party_id = l_party_id;

		   CURSOR get_acct_latest IS
		      SELECT cust_account_id
			FROM hz_cust_accounts
		       WHERE party_id = l_party_id
			 AND ((status = 'A' AND l_show_active_acct = 'Y')
			       OR (l_show_active_acct = 'N'))
			 AND status NOT IN ('M', 'D')
		      ORDER BY creation_date DESC;

		   CURSOR get_acct_oldest IS
		      SELECT cust_account_id
			FROM hz_cust_accounts
		       WHERE party_id = l_party_id
			 AND ((status = 'A' AND l_show_active_acct = 'Y')
			       OR (l_show_active_acct = 'N'))
			 AND status NOT IN ('M', 'D')
		      ORDER BY creation_date;

		   CURSOR get_cust_from_cont IS
		      SELECT obj_party_id, obj_party_type
			FROM csc_hz_parties_rel_v
		       WHERE rel_party_id = l_party_id;

BEGIN
		   IF FND_API.to_Boolean( p_init_msg_list ) THEN
		      FND_MSG_PUB.initialize;
		   END IF;
		   x_return_status := FND_API.G_RET_STS_SUCCESS;
		   /* get values from varray parameter p_key_value_varr */
		   l_media_item_id := CCT_COLLECTION_UTIL_PUB.Get
				      ( p_key_value_varr => p_key_value_varr,
					p_key => 'occtMediaItemID',
					x_key_exists => l_media_exists);
		   l_party_id := CCT_COLLECTION_UTIL_PUB.Get
				      ( p_key_value_varr => p_key_value_varr,
					p_key => 'PARTY_ID',
					x_key_exists => l_party_exists);
		   l_rel_id := CCT_COLLECTION_UTIL_PUB.Get
				      ( p_key_value_varr => p_key_value_varr,
					p_key => 'REL_PARTY_ID',
					x_key_exists => l_rel_exists);
		   l_acct_id := CCT_COLLECTION_UTIL_PUB.Get
				      ( p_key_value_varr => p_key_value_varr,
					p_key => 'CUST_ACCOUNT_ID',
					x_key_exists => l_acct_exists);
		   l_resp_id := CCT_COLLECTION_UTIL_PUB.Get
				      ( p_key_value_varr => p_key_value_varr,
					p_key => 'occtRespID',
					x_key_exists => l_resp_exists);
		   l_resp_appl_id := CCT_COLLECTION_UTIL_PUB.Get
				      ( p_key_value_varr => p_key_value_varr,
					p_key => 'occtAppID',
					x_key_exists => l_resp_appl_exists);
		   l_emp_id := CCT_COLLECTION_UTIL_PUB.Get
				      ( p_key_value_varr => p_key_value_varr,
					p_key => 'employeeID',
					x_key_exists => l_emp_exists);
		   l_which_ivr := CCT_COLLECTION_UTIL_PUB.Get
				      ( p_key_value_varr => p_key_value_varr,
					p_key => 'WhichIVR',
					x_key_exists => l_which_ivr_exists);

		   IF (l_media_item_id IS NULL
		       OR (l_party_id IS NULL AND l_emp_id is NULL)
		       OR l_resp_id IS NULL
		       OR l_resp_appl_id IS NULL) THEN
		      RETURN;
		   END IF;
		OPEN chk_status;
			FETCH chk_status INTO l_status;
		   /* OTM updates jit_status to null before calling this procedure.
		      IF screenpop happens when the call to this procedure is in queue, then
		      forms would have populated jit_status column. In such cases return back
		   */
		IF l_status IS NOT NULL OR chk_status%NOTFOUND THEN
			RETURN;
		END IF;
		CLOSE chk_status;
		   update_jit_status
		     ( p_status => l_jit_prg_status,
		       p_err_code => NULL,
		       p_media_item_id => l_media_item_id );
		 /* get the value of auto refresh PO if not passed from OTM */
		   IF p_critical_flag IS NULL THEN
			l_critical_flag := FND_PROFILE.value_specific ( name => 'CSC_DASHBOARD_AUTO_REFRESH',
													      responsibility_id => l_resp_id,
													      application_id => l_resp_appl_id,
													      user_id => -999
														);
		ELSE
				 l_critical_flag := p_critical_flag;
		END IF;
		   /* profile option for defaulting view by in CC */
		 l_view_by := FND_PROFILE.value_specific ( name => 'CSC_CC_DEFAULT_VIEW_BY',
												      responsibility_id => l_resp_id,
												      application_id => l_resp_appl_id,
												      user_id => -999
										                    );
		   /* Employee HelpDesk Changes
		   If emp_id is not null
		     If view_by is Customer - then get hidden customer's id from Profile Option -process for customer
		     If view_by is Contact - then process for employee
		    elsif party_id is not null
		      existing logic
		    */
		IF l_emp_id IS NOT NULL AND l_which_ivr ='Employee' THEN
				IF l_view_by = 'CUSTOMER' THEN ---Refresh only for hidden customer
						l_hidden_party_id := FND_PROFILE.value_specific( name => 'CS_SR_DEFAULT_CUSTOMER_NAME',
																	       responsibility_id => l_resp_id,
																	       application_id => l_resp_appl_id,
																	       user_id => -999
																	  );
				/* Refresh for Customer only if Profile Option CS_SR_DEFAULT_CUSTOMER_NAME returns a value */
						 IF l_hidden_party_id IS NOT NULL THEN
								 /* profile option for view_by_account in dashboard tab */
								 l_view_by_acct := FND_PROFILE.value_specific( name => 'CSC_DASHBOARD_TO_QUERY_BY_PARTY_OR_ACCOUNT',
																				responsibility_id => l_resp_id,
																				application_id => l_resp_appl_id,
																				user_id => -999
																			);

							      /* if view_by_account is yes, check whether account_id is passed.
								 If not passed, then check whether only one account exists for the customer.
								 If yes, use this account.
								 Else get account_id based on profile option CSC_CC_DEFAULT_ACCT */
								IF l_view_by_acct = 'ACCOUNT' THEN
									 IF l_acct_id IS NULL THEN
										 l_show_active_acct := FND_PROFILE.value_specific( name => 'CSC_CONTACT_CENTER_SHOW_ACTIVE_ACCOUNTS',
																						      responsibility_id => l_resp_id,
																						      application_id => l_resp_appl_id,
																						      user_id => -999
																						);
										BEGIN
											       SELECT cust_account_id
												 INTO l_acct_id
												 FROM hz_cust_accounts
												WHERE party_id = l_party_id
												  AND ((status = 'A' AND l_show_active_acct = 'Y') OR (l_show_active_acct = 'N'))
												  AND status NOT IN ('M', 'D');
										 EXCEPTION
												WHEN OTHERS THEN
														l_acct_id := NULL;
										 END;
										 IF l_acct_id IS NULL THEN
											 l_acct_new_old := FND_PROFILE.value_specific( name => 'CSC_CC_DEFAULT_ACCT',
																						 responsibility_id => l_resp_id,
																						 application_id => l_resp_appl_id,
																						 user_id => -999
																						);

												IF l_acct_new_old = 'Y' THEN
													OPEN get_acct_oldest;
													FETCH get_acct_oldest INTO l_acct_id;
													CLOSE get_acct_oldest;
												ELSIF l_acct_new_old = 'L' THEN
													OPEN get_acct_latest;
													FETCH get_acct_latest INTO l_acct_id;
													CLOSE get_acct_latest;
												END IF;
										END IF; /* l_acct_id is null -- inner*/
									END IF; /* l_acct_id is null -- outer */
							 END IF; /* l_view_by_acct = 'Y' */
						      /* If user hook for dashboard group is enabled, call user hook to get group_id.
							 Else use the existing logic from setup form to get group_id */
						IF JTF_USR_HKS.ok_to_execute('CSC_DASHBOARD_GROUP_CUHK', 'GET_DASHBOARD_GROUP_PRE', 'B', 'C') THEN
							 l_party_rec.Cust_Party_Id  := l_hidden_party_id;
							 l_party_rec.Cust_Account_Id  := l_acct_id;
						         CSC_DASHBOARD_GROUP_CUHK.get_dashboard_group_pre(l_party_rec);
         l_group_id := l_party_rec.group_id;
      ELSE
         OPEN group_crs;
         FETCH group_crs INTO l_group_id;
            IF (group_crs%notfound) THEN
               CLOSE group_crs;
               l_form_name := 'CSCCCCDB';
               OPEN group_crs;
               FETCH group_crs into l_group_id;
               CLOSE group_Crs;
            ELSE
               CLOSE group_crs;
            END IF;
      END IF;

      /* if err_code is -20001, Contact Center will display message that says that no group is attached */
      IF l_group_id IS NULL THEN
         update_jit_status
            ( p_status => l_jit_err_status,
              p_err_code => -20001,
              p_media_item_id => l_media_item_id );
          RETURN;
      END IF;

      CSC_PROFILE_ENGINE_PKG.run_engine_jit
             ( p_party_id => l_hidden_party_id,
               p_acct_id => l_acct_id,
	       p_psite_id => l_psite_id, -- added by spamujul for ER#8473903
               p_group_id => l_group_id,
               p_critical_flag => l_critical_flag,
	       p_party_type => 'CUSTOMER');
	    END IF; /* l_hidden_party_id is not null */

      ELSIF l_view_by = 'CONTACT' THEN --Refresh for employee

       IF JTF_USR_HKS.ok_to_execute('CSC_DASHBOARD_GROUP_CUHK', 'GET_DASHBOARD_GROUP_PRE', 'B', 'C') THEN
            l_party_rec.Cust_Party_Id  := l_emp_id;
            l_party_rec.Cust_Party_Type  := upper(l_which_ivr);


            CSC_DASHBOARD_GROUP_CUHK.get_dashboard_group_pre(l_party_rec);
            l_group_id := l_party_rec.group_id;
         ELSE

            OPEN group_crs;
            FETCH group_crs INTO l_group_id;
               IF (group_crs%notfound) THEN
                  CLOSE group_crs;
                  l_form_name := 'CSCCCCDB';
                  OPEN group_crs;
                  FETCH group_crs into l_group_id;
                  CLOSE group_Crs;
               ELSE
                  CLOSE group_crs;
               END IF;
        END IF;

         IF l_group_id IS NULL THEN
            update_jit_status
            ( p_status => l_jit_err_status,
              p_err_code => -20001,
              p_media_item_id => l_media_item_id );
             RETURN;
         END IF;

	 CSC_PROFILE_ENGINE_PKG.run_engine_jit
             ( p_party_id => l_emp_id,
               p_acct_id => NULL,
	       p_psite_id => NULL, -- added by spamujul for ER#8473903
               p_group_id => l_group_id,
               p_critical_flag => l_critical_flag,
               p_party_type => 'EMPLOYEE');

      END IF; /* l_view_by for HelpDesk Context */

ELSIF l_emp_id IS NOT NULL AND l_which_ivr ='SR' THEN
       l_contact_type := FND_PROFILE.value_specific
		              ( name => 'CSC_CC_DEFAULT_CONTACT_TYPE',
			        responsibility_id => l_resp_id,
				application_id => l_resp_appl_id,
	                        user_id => -999
		               );

          IF l_view_by = 'CUSTOMER' THEN
             --refresh dashboard for customer using l_party_id
	    IF l_party_id IS NOT NULL THEN
		  /* profile option for view_by_account in dashboard tab */
	        l_view_by_acct := FND_PROFILE.value_specific
		              ( name => 'CSC_DASHBOARD_TO_QUERY_BY_PARTY_OR_ACCOUNT',
			        responsibility_id => l_resp_id,
				application_id => l_resp_appl_id,
	                        user_id => -999
		               );

	      /* if view_by_account is yes, check whether account_id is passed.
		 If not passed, then check whether only one account exists for the customer.
	         If yes, use this account.
		 Else get account_id based on profile option CSC_CC_DEFAULT_ACCT */

		IF l_view_by_acct = 'ACCOUNT' THEN
	         IF l_acct_id IS NULL THEN
		    l_show_active_acct := FND_PROFILE.value_specific
                                    ( name => 'CSC_CONTACT_CENTER_SHOW_ACTIVE_ACCOUNTS',
                                      responsibility_id => l_resp_id,
                                      application_id => l_resp_appl_id,
                                      user_id => -999
                                    );
	            BEGIN
		       SELECT cust_account_id
			 INTO l_acct_id
	                 FROM hz_cust_accounts
		        WHERE party_id = l_party_id
			  AND ((status = 'A' AND l_show_active_acct = 'Y') OR (l_show_active_acct = 'N'))
	                  AND status NOT IN ('M', 'D');
		    EXCEPTION
	               WHEN OTHERS THEN
		          l_acct_id := NULL;
	            END;

		    IF l_acct_id IS NULL THEN
	               l_acct_new_old := FND_PROFILE.value_specific
                                       ( name => 'CSC_CC_DEFAULT_ACCT',
                                         responsibility_id => l_resp_id,
                                         application_id => l_resp_appl_id,
                                         user_id => -999
                                       );

		       IF l_acct_new_old = 'Y' THEN
			  OPEN get_acct_oldest;
	                  FETCH get_acct_oldest INTO l_acct_id;
		          CLOSE get_acct_oldest;
	               ELSIF l_acct_new_old = 'L' THEN
		          OPEN get_acct_latest;
			  FETCH get_acct_latest INTO l_acct_id;
	                  CLOSE get_acct_latest;
		       END IF;
	            END IF; /* l_acct_id is null -- inner*/
		 END IF; /* l_acct_id is null -- outer */
	        END IF; /* l_view_by_acct = 'Y' */

      /* If user hook for dashboard group is enabled, call user hook to get group_id.
         Else use the existing logic from setup form to get group_id */

     IF JTF_USR_HKS.ok_to_execute('CSC_DASHBOARD_GROUP_CUHK', 'GET_DASHBOARD_GROUP_PRE', 'B', 'C') THEN
         l_party_rec.Cust_Party_Id  := l_hidden_party_id;
         l_party_rec.Cust_Account_Id  := l_acct_id;

         CSC_DASHBOARD_GROUP_CUHK.get_dashboard_group_pre(l_party_rec);
         l_group_id := l_party_rec.group_id;
      ELSE
         OPEN group_crs;
         FETCH group_crs INTO l_group_id;
            IF (group_crs%notfound) THEN
               CLOSE group_crs;
               l_form_name := 'CSCCCCDB';
               OPEN group_crs;
               FETCH group_crs into l_group_id;
               CLOSE group_Crs;
            ELSE
               CLOSE group_crs;
            END IF;
      END IF;

      /* if err_code is -20001, Contact Center will display message that says that no group is attached */
      IF l_group_id IS NULL THEN
         update_jit_status
            ( p_status => l_jit_err_status,
              p_err_code => -20001,
              p_media_item_id => l_media_item_id );
          RETURN;
      END IF;

      CSC_PROFILE_ENGINE_PKG.run_engine_jit
             ( p_party_id => l_party_id,
               p_acct_id => l_acct_id,
	       p_psite_id => l_psite_id, -- added by spamujul for ER#8473903
               p_group_id => l_group_id,
               p_critical_flag => l_critical_flag,
	       p_party_type => 'CUSTOMER');
    END IF; /* l_party_id is not null */

    ELSIF l_view_by = 'CONTACT' and l_contact_type ='EMPLOYEE' THEN

       IF JTF_USR_HKS.ok_to_execute('CSC_DASHBOARD_GROUP_CUHK', 'GET_DASHBOARD_GROUP_PRE', 'B', 'C') THEN
            l_party_rec.Cust_Party_Id  := l_emp_id;
            l_party_rec.Cust_Party_Type  := 'EMPLOYEE';


            CSC_DASHBOARD_GROUP_CUHK.get_dashboard_group_pre(l_party_rec);
            l_group_id := l_party_rec.group_id;
         ELSE

            OPEN group_crs;
            FETCH group_crs INTO l_group_id;
               IF (group_crs%notfound) THEN
                  CLOSE group_crs;
                  l_form_name := 'CSCCCCDB';
                  OPEN group_crs;
                  FETCH group_crs into l_group_id;
                  CLOSE group_Crs;
               ELSE
                  CLOSE group_crs;
               END IF;
        END IF;

         IF l_group_id IS NULL THEN
            update_jit_status
            ( p_status => l_jit_err_status,
              p_err_code => -20001,
              p_media_item_id => l_media_item_id );
             RETURN;
         END IF;

	 CSC_PROFILE_ENGINE_PKG.run_engine_jit
             ( p_party_id => l_emp_id,
               p_acct_id => NULL,
	       p_psite_id => NULL, -- added by spamujul for ER#8473903
               p_group_id => l_group_id,
               p_critical_flag => l_critical_flag,
               p_party_type => 'EMPLOYEE');

    ELSIF l_view_by = 'CONTACT' and l_contact_type ='CUSTOMER' THEN
	 --refresh dashboard for contact (use party_id to fetch contact_id for refreshing)
         OPEN get_party_type;
           FETCH get_party_type INTO l_party_type;
         CLOSE get_party_type;

	  /* if view_by is contact and contact_id is not passed, don't process */
      IF l_party_type = 'PARTY_RELATIONSHIP' THEN
        IF JTF_USR_HKS.ok_to_execute('CSC_DASHBOARD_GROUP_CUHK', 'GET_DASHBOARD_GROUP_PRE', 'B', 'C') THEN
            l_party_rec.Cust_Party_Id  := l_party_id;
            l_party_rec.Cust_Party_Type  := l_party_type;
            l_party_rec.Cust_Account_Id  := l_acct_id;

            CSC_DASHBOARD_GROUP_CUHK.get_dashboard_group_pre(l_party_rec);
            l_group_id := l_party_rec.group_id;
         ELSE

            OPEN group_crs;
            FETCH group_crs INTO l_group_id;
               IF (group_crs%notfound) THEN
                  CLOSE group_crs;
                  l_form_name := 'CSCCCCDB';
                  OPEN group_crs;
                  FETCH group_crs into l_group_id;
                  CLOSE group_Crs;
               ELSE
                  CLOSE group_crs;
               END IF;
        END IF;

         IF l_group_id IS NULL THEN
            update_jit_status
            ( p_status => l_jit_err_status,
              p_err_code => -20001,
              p_media_item_id => l_media_item_id );
             RETURN;
         END IF;

	 CSC_PROFILE_ENGINE_PKG.run_engine_jit
             ( p_party_id => l_party_id,
               p_acct_id => NULL,
	       p_psite_id => NULL,  -- added by spamujul for ER#8473903
               p_group_id => l_group_id,
               p_critical_flag => l_critical_flag,
	       p_party_type => 'CUSTOMER');
      END IF;
    END IF;

ELSIF  l_party_id IS NOT NULL THEN

   OPEN get_party_type;
   FETCH get_party_type INTO l_party_type;
   CLOSE get_party_type;

   IF l_view_by = 'CUSTOMER' THEN

      /* if view by is customer and contact_id is passed,
         get customer_id using contact_id */
      IF l_party_type = 'PARTY_RELATIONSHIP' THEN
         OPEN get_cust_from_cont;
         FETCH get_cust_from_cont into l_party_id, l_party_type;
	 CLOSE get_cust_from_cont;
      END IF;

      /* profile option for view_by_account in dashboard tab */
      l_view_by_acct := FND_PROFILE.value_specific
                        ( name => 'CSC_DASHBOARD_TO_QUERY_BY_PARTY_OR_ACCOUNT',
                          responsibility_id => l_resp_id,
                          application_id => l_resp_appl_id,
                          user_id => -999
                        );

      /* if view_by_account is yes, check whether account_id is passed.
         If not passed, then check whether only one account exists for the customer.
         If yes, use this account.
         Else get account_id based on profile option CSC_CC_DEFAULT_ACCT */

      IF l_view_by_acct = 'ACCOUNT' THEN
         IF l_acct_id IS NULL THEN
            l_show_active_acct := FND_PROFILE.value_specific
                                    ( name => 'CSC_CONTACT_CENTER_SHOW_ACTIVE_ACCOUNTS',
                                      responsibility_id => l_resp_id,
                                      application_id => l_resp_appl_id,
                                      user_id => -999
                                    );
            BEGIN
               SELECT cust_account_id
                 INTO l_acct_id
                 FROM hz_cust_accounts
                WHERE party_id = l_party_id
                  AND ((status = 'A' AND l_show_active_acct = 'Y') OR (l_show_active_acct = 'N'))
                  AND status NOT IN ('M', 'D');
            EXCEPTION
               WHEN OTHERS THEN
                  l_acct_id := NULL;
            END;

            IF l_acct_id IS NULL THEN
               l_acct_new_old := FND_PROFILE.value_specific
                                       ( name => 'CSC_CC_DEFAULT_ACCT',
                                         responsibility_id => l_resp_id,
                                         application_id => l_resp_appl_id,
                                         user_id => -999
                                       );

               IF l_acct_new_old = 'Y' THEN
                  OPEN get_acct_oldest;
                  FETCH get_acct_oldest INTO l_acct_id;
                  CLOSE get_acct_oldest;
               ELSIF l_acct_new_old = 'L' THEN
                  OPEN get_acct_latest;
                  FETCH get_acct_latest INTO l_acct_id;
                  CLOSE get_acct_latest;
               END IF;
            END IF; /* l_acct_id is null -- inner*/
         END IF; /* l_acct_id is null -- outer */
      END IF; /* l_view_by_acct = 'Y' */

      /* If user hook for dashboard group is enabled, call user hook to get group_id.
         Else use the existing logic from setup form to get group_id */

     IF JTF_USR_HKS.ok_to_execute('CSC_DASHBOARD_GROUP_CUHK', 'GET_DASHBOARD_GROUP_PRE', 'B', 'C') THEN
         l_party_rec.Cust_Party_Id  := l_party_id;
         l_party_rec.Cust_Party_Type  := l_party_type;
         l_party_rec.Cust_Account_Id  := l_acct_id;

         CSC_DASHBOARD_GROUP_CUHK.get_dashboard_group_pre(l_party_rec);
         l_group_id := l_party_rec.group_id;
      ELSE
         OPEN group_crs;
         FETCH group_crs INTO l_group_id;
            IF (group_crs%notfound) THEN
               CLOSE group_crs;
               l_form_name := 'CSCCCCDB';
               OPEN group_crs;
               FETCH group_crs into l_group_id;
               CLOSE group_Crs;
            ELSE
               CLOSE group_crs;
            END IF;
      END IF;

      /* if err_code is -20001, Contact Center will display message that says that no group is attached */
      IF l_group_id IS NULL THEN
         update_jit_status
            ( p_status => l_jit_err_status,
              p_err_code => -20001,
              p_media_item_id => l_media_item_id );
          RETURN;
      END IF;

      CSC_PROFILE_ENGINE_PKG.run_engine_jit
             ( p_party_id => l_party_id,
               p_acct_id => l_acct_id,
	       p_psite_id => l_psite_id, -- added by spamujul for ER#8473903
               p_group_id => l_group_id,
               p_critical_flag => l_critical_flag,
	       p_party_type => 'CUSTOMER');

   ELSIF l_view_by = 'CONTACT' THEN

      /* if view_by is contact and contact_id is not passed, don't process */
      IF l_party_type = 'PARTY_RELATIONSHIP' THEN
        IF JTF_USR_HKS.ok_to_execute('CSC_DASHBOARD_GROUP_CUHK', 'GET_DASHBOARD_GROUP_PRE', 'B', 'C') THEN
            l_party_rec.Cust_Party_Id  := l_party_id;
            l_party_rec.Cust_Party_Type  := l_party_type;
            l_party_rec.Cust_Account_Id  := l_acct_id;

            CSC_DASHBOARD_GROUP_CUHK.get_dashboard_group_pre(l_party_rec);
            l_group_id := l_party_rec.group_id;
         ELSE

            OPEN group_crs;
            FETCH group_crs INTO l_group_id;
               IF (group_crs%notfound) THEN
                  CLOSE group_crs;
                  l_form_name := 'CSCCCCDB';
                  OPEN group_crs;
                  FETCH group_crs into l_group_id;
                  CLOSE group_Crs;
               ELSE
                  CLOSE group_crs;
               END IF;
        END IF;

         IF l_group_id IS NULL THEN
            update_jit_status
            ( p_status => l_jit_err_status,
              p_err_code => -20001,
              p_media_item_id => l_media_item_id );
             RETURN;
         END IF;

	 CSC_PROFILE_ENGINE_PKG.run_engine_jit
             ( p_party_id => l_party_id,
               p_acct_id => NULL,
	       p_psite_id => NULL,  -- added by spamujul for ER#8473903
               p_group_id => l_group_id,
               p_critical_flag => l_critical_flag,
	       p_party_type => 'CUSTOMER');
      END IF;
   END IF; /* l_view_by */
END IF; /* l_party_id or l_emp_id is null */

   update_jit_status
      ( p_status => l_jit_complete_status,
        p_err_code => NULL,
        p_media_item_id => l_media_item_id );

EXCEPTION
   WHEN OTHERS THEN
      l_sql_code := sqlcode;

      update_jit_status
        ( p_status => l_jit_err_status,
          p_err_code => l_sql_code,
          p_media_item_id => l_media_item_id );

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
           ( p_pkg_name => G_PKG_NAME,
             p_procedure_name => l_api_name );
      END IF;

      FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count,
          p_data => x_msg_data );

END csc_prof_jit;


/*******************************************
  GET_PROFILE_VALUE_RESP
  added this procedure for JIT enhancement -- Bug 4535407
  Returns Profile Option value at the responsibility level.
  This function has been added as API fnd_profile.value_specific is
  not defined at form level FND_PROFILE package (pld)
********************************************/

FUNCTION get_profile_value_resp ( p_profile_name VARCHAR2,
								     p_resp_id      NUMBER,
								     p_resp_appl_id NUMBER,
								     p_user_id      NUMBER
								  ) RETURN VARCHAR2
								IS
			l_prof_value VARCHAR2(255);
BEGIN
			   l_prof_value := FND_PROFILE.value_specific
					    ( name => p_profile_name,
					      responsibility_id => p_resp_id,
					      application_id => p_resp_appl_id,
					      user_id => p_user_id
					    );
			   RETURN l_prof_value;
END get_profile_value_resp;

/******************************
 * Begin Utilities Definition *
 ******************************/

--
-- Build_Rule
--   Construct the rule as a SQL statement for an indicator check
-- IN
--   check_id - profile check identifier
-- OUT
--   rule - sql statement that returns 0 or 1 row (0 for false, 1 for true)
--
PROCEDURE Build_Rule	( acct_flag		IN 	VARCHAR2,
						chk_id			IN	NUMBER,
						chk_level		IN      VARCHAR2,
						rule				OUT	NOCOPY VARCHAR2
						)   IS

		     v_blk_id	Number;
		     v_blk_level  Varchar2(10);
		     CURSOR rules_csr IS
			SELECT logical_operator,
					left_paren,
					block_id,
					comparison_operator,
					expression,
					expr_to_block_id,
					right_paren
			FROM csc_prof_check_rules_vl
			WHERE check_id = chk_id;

		      cursor blk_crs is
			  select block_level from
			     csc_prof_blocks_b
			  where block_id=v_blk_id;

BEGIN
   --
   -- Construct indicator check rule as a SQL statement as follows:
   --   SELECT 1
   --     FROM dual
   --     WHERE {condition}
   --     <logical_operator> {condition}
   --     ...
   --
   -- A {condition} has the following form:
   --   <left_paren> EXISTS ( {subquery} ) <right_paren>
   --
   -- A {subquery} has the following three forms:
   --   SELECT 1
   --     FROM csc_prof_block_results
   --     WHERE block_id = <block_id>
   --     AND party_id = <party_id>
   --     AND value <comparison_operator> [<expression1> [AND <expression2>]]
   --
		rule := 'SELECT 1 FROM dual WHERE';
		  IF chk_level = 'ACCOUNT' THEN
			FOR rules_rec IN rules_csr LOOP
				v_blk_id:=rules_rec.block_id;
				open blk_crs;
				fetch blk_crs into v_blk_level;
				close blk_crs;
				if v_blk_level='PARTY' then
					rule := rule || ' ' || rules_rec.logical_operator || ' ' ||
					rules_rec.left_paren ||
					'EXISTS (SELECT 1 FROM csc_prof_block_results WHERE block_id = ' ||
					rules_rec.block_id || ' AND party_id = :party_id' ||
					' AND cust_account_id IS NULL AND party_site_id IS NULL AND value ' || rules_rec.comparison_operator; -- Included "PARTY_SITE_ID IS NULL" by spamujul for ER#8473903
					IF rules_rec.expression IS NOT NULL  THEN
						IF (rules_rec.comparison_operator NOT IN ('IS NULL', 'IS NOT NULL')) THEN
							rule := rule || ' ' || rules_rec.expression;
						END IF;
					ELSE
						rule := rule || '(SELECT value from csc_prof_block_results WHERE block_id = '||
						rules_rec.expr_to_block_id || ' AND cust_account_id IS NULL AND party_site_id IS NULL )'; -- Included "PARTY_SITE_ID IS NULL" by spamujul for ER#8473903
					END IF;
					rule := rule || ')' || rules_rec.right_paren;
				ELSIF v_blk_level='ACCOUNT' then
				      rule := rule || ' ' || rules_rec.logical_operator || ' ' ||
						rules_rec.left_paren ||
						'EXISTS (SELECT 1 FROM csc_prof_block_results WHERE block_id = ' ||
						rules_rec.block_id || ' AND party_id = :party_id' ||
						' AND cust_account_id = :cust_account_id AND party_site_id IS NULL' || -- Included "PARTY_SITE_ID IS NULL" by spamujul for ER#8473903
						' AND value ' || rules_rec.comparison_operator;
				     IF rules_rec.expression IS NOT NULL  THEN
						IF (rules_rec.comparison_operator NOT IN ('IS NULL', 'IS NOT NULL')) THEN
						       rule := rule || ' ' || rules_rec.expression;
						END IF;
				     ELSE
						rule := rule || '(SELECT value from csc_prof_block_results WHERE block_id = '
						   || rules_rec.expr_to_block_id ||  ' AND party_id = :party_id' ||
								' AND cust_account_id = :cust_account_id AND party_site_id IS NULL )' ; -- Included "PARTY_SITE_ID IS NULL" by spamujul for ER#8473903
				      END IF;
				      rule := rule || ')' || rules_rec.right_paren;
				end if;
			END LOOP;
 -- Begin fix by spamujul for ER#8473903
		ELSIF (chk_level='SITE') then
			FOR rules_rec IN rules_csr LOOP
				v_blk_id:=rules_rec.block_id;
				open blk_crs;
				fetch blk_crs into v_blk_level;
				close blk_crs;
				IF v_blk_level='PARTY' THEN
					rule := rule || ' ' || rules_rec.logical_operator || ' ' ||
					rules_rec.left_paren ||
					'EXISTS (SELECT 1 FROM csc_prof_block_results WHERE block_id = ' ||
					rules_rec.block_id || ' AND party_id = :party_id' ||
					' AND cust_account_id IS NULL AND PARTY_SITE_ID IS NULL AND value ' || rules_rec.comparison_operator;
					IF rules_rec.expression IS NOT NULL  THEN
						IF (rules_rec.comparison_operator NOT IN ('IS NULL', 'IS NOT NULL')) THEN
							rule := rule || ' ' || rules_rec.expression;
						END IF;
					ELSE
						rule := rule || '(SELECT value from csc_prof_block_results WHERE block_id = '||
						rules_rec.expr_to_block_id || ' AND cust_account_id IS NULL AND PARTY_SITE_ID IS NULL)';
					END IF;
					rule := rule || ')' || rules_rec.right_paren;
				ELSIF v_blk_level='SITE' then
					rule := rule || ' ' || rules_rec.logical_operator || ' ' ||
					rules_rec.left_paren ||
					'EXISTS (SELECT 1 FROM csc_prof_block_results WHERE block_id = ' ||
					rules_rec.block_id || ' AND party_id = :party_id' ||
					' AND party_site_id = :party_site_id and cust_account_id is null' ||
					' AND value ' || rules_rec.comparison_operator;
					IF rules_rec.expression IS NOT NULL  THEN
						IF (rules_rec.comparison_operator NOT IN ('IS NULL', 'IS NOT NULL')) THEN
							rule := rule || ' ' || rules_rec.expression;
						END IF;
					ELSE
						rule := rule || '(SELECT value from csc_prof_block_results WHERE block_id = '
						||rules_rec.expr_to_block_id ||  ' AND party_id = :party_id' ||
						' AND party_site_id = :party_site_id and cust_account_id is null)' ;
					END IF;
					rule := rule || ')' || rules_rec.right_paren;
				END IF;
			END LOOP;

 -- End fix by spamujul for ER#8473903
		  ELSIF (chk_level='PARTY' OR chk_level='CONTACT' or chk_level='EMPLOYEE') THEN
			    FOR rules_rec IN rules_csr LOOP
			      rule := rule || ' ' || rules_rec.logical_operator || ' ' ||
					rules_rec.left_paren ||
					'EXISTS (SELECT 1 FROM csc_prof_block_results WHERE block_id = ' ||
					rules_rec.block_id || ' AND party_id = :party_id' ||
					' AND cust_account_id IS NULL AND party_site_id IS NULL AND value ' || rules_rec.comparison_operator; -- Included "PARTY_SITE_ID IS NULL" by spamujul for ER#8473903

				IF rules_rec.expression IS NOT NULL  THEN
				   IF (rules_rec.comparison_operator NOT IN ('IS NULL', 'IS NOT NULL')) THEN
				       rule := rule || ' ' || rules_rec.expression;
				   END IF;
				ELSE
					rule := rule || '(SELECT value from csc_prof_block_results WHERE block_id = '||
						rules_rec.expr_to_block_id || ' AND cust_account_id IS NULL  AND party_site_id IS NULL)'; -- Included "PARTY_SITE_ID IS NULL" by spamujul for ER#8473903
				END IF;
			      rule := rule || ')' || rules_rec.right_paren;
			    END LOOP;
		  END IF;
END Build_Rule;


--
-- Set_Context
--   Set procedure context (for stack trace).
-- IN
--   proc_name - procedure/function name
--   arg1 - first IN argument
--   argn - n'th IN argument
--
PROCEDURE Set_Context   ( proc_name	IN	VARCHAR2,
							    arg1		IN	VARCHAR2 DEFAULT '*none*',
							    arg2		IN	VARCHAR2 DEFAULT '*none*',
							    arg3		IN	VARCHAR2 DEFAULT '*none*',
							    arg4		IN	VARCHAR2 DEFAULT '*none*',
							    arg5		IN	VARCHAR2 DEFAULT '*none*'
						   )    IS
BEGIN
	   -- Start with procedure name.
	   IF (proc_name IS NOT NULL) THEN
	      fnd_file.put(FND_FILE.LOG, proc_name||'(');
	   END IF;
	   -- Add all defined args.
	   IF (arg1 <> '*none*') THEN
	      fnd_file.put(FND_FILE.LOG, arg1);
	   END IF;
	   IF (arg2 <> '*none*') THEN
	      fnd_file.put(FND_FILE.LOG, ', '||arg2);
	   END IF;
	   IF (arg3 <> '*none*') THEN
	      fnd_file.put(FND_FILE.LOG, ', '||arg3);
	   END IF;
	   IF (arg4 <> '*none*') THEN
	      fnd_file.put(FND_FILE.LOG, ', '||arg4);
	   END IF;
	   IF (arg5 <> '*none*') THEN
	      fnd_file.put(FND_FILE.LOG, ', '||arg5);
	   END IF;

	   IF (proc_name IS NOT NULL) THEN
	      fnd_file.put_line(FND_FILE.LOG, ')');
	    ELSE
	      fnd_file.new_line(FND_FILE.LOG);
	   END IF;
  EXCEPTION
		   WHEN UTL_FILE.INVALID_FILEHANDLE THEN
				fnd_message.set_name('CSC', 'CSC_PROFILE_INVALID_FILEHANDLE');
				warning_msg := fnd_message.get;
		   WHEN UTL_FILE.INVALID_OPERATION THEN
				fnd_message.set_name('CSC', 'CSC_PROFILE_INVALID_OPERATION');
				warning_msg := fnd_message.get;
		   WHEN UTL_FILE.WRITE_ERROR THEN
				fnd_message.set_name('CSC', 'CSC_PROFILE_WRITE_ERROR');
				warning_msg := fnd_message.get;
END Set_Context;


--
-- Utility to delete all records in the tables
--
PROCEDURE Table_Delete IS
Begin

	   IP_Block_Id.delete;
	   IP_Check_Id.delete;
	   IP_Party_Id.delete;
	   IP_Account_Id.delete;
	   IP_Psite_id.delete;	-- added by spamujul for ER#8473903
	   IP_Value.delete;
	   IP_Currency.delete;

	   UP_Grade.delete;
	   UP_Block_Id.delete;
	   UP_Check_Id.delete;
	   UP_Party_Id.delete;
	   UP_Account_Id.delete;
	   UP_Psite_id.delete;	-- added by spamujul for ER#8473903
	   UP_Value.delete;
	   UP_Currency.delete;
	   UP_Grade.delete;

	   IA_Block_Id.delete;
	   IA_Check_Id.delete;
	   IA_Party_Id.delete;
	   IA_Account_Id.delete;
	   IA_Psite_id.delete;	 -- added by spamujul for ER#8473903
	   IA_Value.delete;
	   IA_Currency.delete;

	   UA_Grade.delete;
	   UA_Block_Id.delete;
	   UA_Check_Id.delete;
	   UA_Party_Id.delete;
	   UA_Account_Id.delete;
	   UA_Psite_id.delete;	-- added by spamujul for ER#8473903
	   UA_Value.delete;
	   UA_Currency.delete;
	   UA_Grade.delete;
	-- Begin Fix by spamujul  for ER#8473903
	  US_Block_Id.delete;
	  US_Check_Id.delete;
	  US_Party_Id.delete;
	  US_Account_Id.delete;
	  US_Psite_Id.delete;
	  US_Value.delete;
	  US_Currency.delete;
	  US_Grade.delete;
	  US_Rating_code.delete;
	  US_Color_code.delete;
	  US_Results.delete;

	  IS_Block_Id.delete;
	  IS_Check_Id.delete;
	  IS_Party_Id.delete;
	  IS_Account_Id.delete;
	  IS_Psite_Id.delete;
	  IS_Value.delete;
	  IS_Currency.delete;
	  IS_Grade.delete;
	  IS_Rating_Code.delete;
	  IS_Color_Code.delete;
	  IS_Results.delete;
	-- End Fix by spamujul  for ER#8473903
	   -- Relationship Plan tables
	   plan_id_plan_table.delete;
	   check_id_plan_table.delete;
	   party_id_plan_table.delete;
	   account_id_plan_table.delete;
END Table_Delete;

FUNCTION  Calc_Threshold (  p_val			VARCHAR2,
							   p_low_val		VARCHAR2,
							   p_high_val		VARCHAR2,
							   p_data_type	VARCHAR2,
							   p_chk_u_l_flag VARCHAR2
						    ) RETURN VARCHAR2 IS
		   RESULT		VARCHAR2(3);
		   val			VARCHAR2(240) :=	null;
BEGIN
	   IF p_low_val is NULL AND p_high_val IS NULL THEN
	      RETURN 'Y';
	   END IF;
	  IF  p_data_type IN ('NUMBER', 'DATE') THEN
		IF p_data_type = 'NUMBER' THEN
			IF p_val IS NULL Then
		            val := '0';
			ELSE
			   val := p_val;
		         END IF;
			IF p_chk_u_l_flag ='U' THEN
			      IF to_number(val) > to_number(p_high_val) THEN
				  Result := 'Y';
			      Else
				  Result := 'N';
			      End If;
		   Elsif p_chk_u_l_flag = 'L' Then
			       If to_number(val) < to_number(p_low_val) then
					Result := 'Y';
				Else
					Result := 'N';
				End If;
		  Else
				 Result := 'N';
		  End If;
        ELSE
		IF val IS NOT NULL THEN
			 If p_chk_u_l_flag = 'U' Then
				If val > p_high_val then
					Result := 'Y';
				Else
					Result := 'N';
				 End If;
			Elsif p_chk_u_l_flag = 'L' Then
				   If val < p_low_val then
					Result := 'Y';
				   Else
					Result := 'N';
				   End If;
			       Else
					Result := 'N';
			       End If;
			End if;
		END IF;
	END IF;
	RETURN RESULT;
END Calc_Threshold;

FUNCTION Format_Mask (   p_curr_code	VARCHAR2,
						    p_data_type	VARCHAR2,
						    p_val			VARCHAR2,
						    p_fmt_mask	VARCHAR2
						)  RETURN VARCHAR2  IS
			   val VARCHAR2(240);
			   v_format_date DATE;
BEGIN
		val := p_val;
		IF (p_curr_code IS NULL OR p_curr_code = '') THEN
			 IF (p_fmt_mask IS NOT NULL OR p_fmt_mask <> '') THEN
			          IF (p_data_type = 'NUMBER') THEN
				             val := To_char(To_number(nvl(p_val, '0')), p_fmt_mask);
				  ELSIF (p_data_type = 'DATE') THEN
				             v_format_date := to_date(p_val,'DD-MM-YYYY');
				             val := To_char(v_format_date, p_fmt_mask);
			          END IF;
		      END IF;
	   END IF;
	   IF p_data_type = 'NUMBER' AND val IS NULL THEN
	      val := '0';
	   END IF;
	   RETURN val;
END Format_Mask;

FUNCTION rating_color   (p_chk_id		NUMBER,
						   p_party_id		NUMBER,
						   p_account_id	NUMBER,
						   p_psite_id		NUMBER, -- added by spamujul for ER#8473903
						   p_val			VARCHAR2,
						   p_data_type	VARCHAR2,
						   p_column		VARCHAR2,
						   p_count		NUMBER
						 )  RETURN VARCHAR2 IS
	   v_val				NUMBER;
	   val				VARCHAR2(240) := p_val;
	   v_color_code		VARCHAR2(240);
	   v_rating_code		VARCHAR2(240);
	   grd				VARCHAR2(240);
BEGIN
			   IF nvl(g_check_id, -99) = nvl(p_chk_id, -99)
			      AND nvl(g_party_id, -99) = nvl(p_party_id, -99)
			      AND nvl(g_account_id, -99) = nvl(p_account_id, -99)
			      AND nvl(g_psite_id, -99) = nvl(p_psite_id, -99)  -- Added by spamujul for ER#8473903
			      AND nvl(g_value, -99) = nvl(p_val, -99)
			THEN
					NULL;
			ELSE
					IF p_count > 0 THEN
						 IF (p_data_type IN ('NUMBER', 'DATE')) THEN
						            IF p_data_type = 'NUMBER' Then
								     IF val IS NULL Then
									    val := '0';
								     END IF;
								     v_val := to_number(val);
								     val := to_char(v_val);
								       FOR a in 1..p_count LOOP
									  IF v_val BETWEEN nvl(rating_tbl(a).low_value, v_val) AND nvl(rating_tbl(a).high_value, v_val) THEN
									     v_color_code := rating_tbl(a).color_code;
									     v_rating_code := rating_tbl(a).rating_code;
									     grd := rating_tbl(a).grade;
									     EXIT;
									  END IF;
								       END LOOP;
							ELSE
								       IF val IS NOT NULL THEN
										FOR a IN 1..p_count LOOP
											IF val BETWEEN nvl(rating_tbl(a).low_value, val) AND nvl(rating_tbl(a).high_value, val) THEN
												v_color_code := rating_tbl(a).color_code;
												v_rating_code := rating_tbl(a).rating_code;
												grd := rating_tbl(a).grade;
												EXIT;
											END IF;
										END LOOP;
								       END IF;
							 END IF;
				         END IF;
			      END IF;
   			      /* populate the global variables */
			      g_check_id := p_chk_id;
			      g_party_id := p_party_id;
			      g_account_id := p_account_id;
			      g_psite_id	:= p_psite_id;  -- Added by spamujul for ER#8473903
			      g_value := p_val;
			      g_color_code := v_color_code;
			      g_rating := v_rating_code;
			      g_grade := grd;
		   END IF;
		   IF p_column = 'COLOR' THEN
		      RETURN g_color_code;
		   ELSIF p_column = 'RATING' THEN
		      RETURN g_rating;
		   ELSIF p_column = 'GRADE' THEN
		      RETURN g_grade;
		   END IF;
END rating_color;

/* This procedure reverts back to the state before the start of the concurrent program */
PROCEDURE Handle_Exception IS
			   -- varlables for getting CSC schema name
			   v_schema_status VARCHAR2(1);
			   v_industry      VARCHAR2(1);
			   v_schema_name   VARCHAR2(30);
			   v_get_appl      BOOLEAN;
BEGIN
		   v_get_appl :=  FND_INSTALLATION.GET_APP_INFO('CSC', v_schema_status, v_industry, v_schema_name);
		   EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N2 REBUILD NOLOGGING';
		   EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N3 REBUILD NOLOGGING';
		   EXECUTE IMMEDIATE 'ALTER INDEX '|| v_schema_name ||'.CSC_PROF_CHECK_RESULTS_N4 REBUILD NOLOGGING';
		   EXECUTE IMMEDIATE 'ALTER TABLE ' || v_schema_name || '.CSC_PROF_CHECK_RESULTS LOGGING';
END Handle_Exception;

/******************************
 *  End Utilities Definition  *
 ******************************/

END CSC_Profile_Engine_PKG;

/
