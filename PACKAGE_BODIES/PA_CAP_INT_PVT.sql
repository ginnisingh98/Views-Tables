--------------------------------------------------------
--  DDL for Package Body PA_CAP_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CAP_INT_PVT" AS
-- $Header: PACINTTB.pls 120.1.12010000.5 2009/09/11 06:35:36 rrambati ship $


 /*
    This package contains the procedures and functions required to process Capitalized
    Interest.  The functions performed are:

	Generation of Capitalized Interest (concurrent request)
	Generation and Auto-Release of Capitalized Interest (concurrent request)
	Release of Capitalized Interest (from form button)
	Purge of Capitalized Interest Source Details (concurrent request)

    When the main procedure, GENERATE_CAP_INTEREST, is called from an Oracle Report, the
    following parameters are used:

	p_from_project_num => Low project to calculate (NULL if no lower bound)
	p_to_project_num   => High project to calculate (NULL if no higher bound)
	p_gl_period        => GL Period for the calculated interest (required)
	p_exp_item_date    => Expenditure Item Date for the calculated interest (required)
	p_source_details   => Y = create source details
	p_autorelease      => Y = auto-release each run batch

    All interest rates setup for the submitter's M/O ORG_ID that exist in schedules associated
    with projects between the parameter project numbers will be processed.  Each rate processed
    will create a single run row.  If any problem are encountered on a project, no transactions
    for that project will be created.  A project can only be successfully processed once per
    month.  Summarized control numbers are reported on the log while the calling report shows
    more detailed results.

    If the release of a Capitalized Interest run is requested from the form, the run_id is
    passed to the GENERATE_CAP_INTEREST procedure through a parameter.

    When the main procedure, PURGE_SOURCE_DETAIL, is called from an Oracle Report, the
    following parameters are used:

	p_gl_period        => GL Period for the source details (required)
	p_from_project_num => Low project to calculate (NULL if no lower bound)
	p_to_project_num   => High project to calculate (NULL if no higher bound)

    The source details from the earliest period through the parameter GL period that belong
    to projects between the parameter project numbers will be purged.  Summarized control
    numbers are reported on the log while the calling report shows more detailed results.

 */


------------------------------------------------------------------
------------------------------------------------------------------
--	G  L  O  B  A  L     V  A  R  I  A  B  L  E  S		--
------------------------------------------------------------------
------------------------------------------------------------------


	-- Debug mode
	g_debug_mode			VARCHAR2(1);


	-- Standard Who columns
	g_created_by			NUMBER;
	g_last_updated_by		NUMBER;
	g_last_update_login		NUMBER;


	-- Request ID
	g_request_id			NUMBER;


	-- GL application ID
	g_gl_app_id			gl_period_statuses.application_id%TYPE := 101;


	-- Alloc Rule ID for Capitalized Interest
	g_cap_int_rule_id		pa_alloc_rules_all.rule_id%TYPE := -1;


	-- Globally used variables
	g_gl_period			gl_period_statuses.period_name%TYPE;
	g_project_id			pa_projects_all.project_id%TYPE;
	g_rate_name			pa_ind_cost_codes.ind_cost_code%TYPE;
	g_period_end_date		gl_period_statuses.end_date%TYPE;
	g_period_start_date		gl_period_statuses.end_date%TYPE;
        g_exp_item_date                 gl_period_statuses.end_date%TYPE;
	g_bdgt_entry_level_code         varchar2(2) := 'L'; -- Lowest level task


------------------------------------------------------------------
------------------------------------------------------------------
--	E  X  T  E  R  N  A  L     F  U  N  C  T  I  O  N  S	--
------------------------------------------------------------------
------------------------------------------------------------------


	/* --------------------------------------
	   Returns the run period being processed
	   -------------------------------------- */
	FUNCTION gl_period RETURN VARCHAR2 IS
	BEGIN RETURN g_gl_period; END;



	/* -------------------------------------------------------
	   Returns the end date for the run period being processed
	   ------------------------------------------------------- */
	FUNCTION period_end_date RETURN DATE IS
	BEGIN RETURN g_period_end_date; END;



	/* ----------------------------------------------
	   Returns the current project id being processed
	   ---------------------------------------------- */
	FUNCTION project_id RETURN NUMBER IS
	BEGIN RETURN g_project_id; END;



	/* ---------------------------------------------
	   Returns the current rate name being processed
	   --------------------------------------------- */
	FUNCTION rate_name RETURN VARCHAR2 IS
	BEGIN RETURN g_rate_name; END;


	/* This API returns 'Y' if the transactions exists in pa_alloc_txn_details
         * based on this the release of Transaction import process will be called
         */
	FUNCTION release_capint_txns_exists
		(p_run_id  IN NUMBER) RETURN VARCHAR2 IS

		l_exists   varchar2(1):= 'N';

	BEGIN
	    IF p_run_id is NOT NULL then

		SELECT 'Y'
		INTO l_exists
		FROM dual
		WHERE EXISTS
			(SELECT NULL
			 FROM PA_ALLOC_TXN_DETAILS
			 WHERE run_id = p_run_id);
	    End If;

            IF g_debug_mode = 'Y' THEN
                  pa_debug.write_file('LOG','Inside release_capint_txns_exists['||l_exists||']');
            End If;
            RETURN l_exists;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
                      IF g_debug_mode = 'Y' THEN
                          pa_debug.write_file('LOG','Inside release_capint_txns_exists['||l_exists||']');
                      End If;
			RETURN l_exists;

		WHEN OTHERS THEN
			RETURN l_exists;

	END release_capint_txns_exists;


	/* Bug fix: 2972865 Task level Threshold should be calculated based on the
         * budget entry method. This API returns the budget entry method for the
         * given project,plan Id and budget type code
	 * Fin plan type id takes the precedence over the budget type code
         */
	FUNCTION Get_Bdgt_entry_level_code
                   (p_project_id         IN NUMBER
                   ,p_threshold_amt_type IN VARCHAR2
                   ,p_budget_type_code   IN VARCHAR2
                   ,p_fin_plan_type_id   IN NUMBER
                   ) RETURN VARCHAR2 IS

		cursor threshold_type IS
    			SELECT 	bv.budget_version_id
				,bv.budget_entry_method_code
				,bv.fin_plan_type_id
	       			,decode(bv.fin_plan_type_id, null,'BUDGET TYPE','PLAN TYPE') threshold_Type
     			FROM     pa_budget_versions bv
     			WHERE    bv.project_id = p_project_id
     			AND      bv.current_flag  = 'Y'
     			AND      ( (bv.fin_plan_type_id is not NULL
	             	            and bv.version_type IN ('COST','ALL')
				    and bv.fin_plan_type_id = p_fin_plan_type_id
				    and bv.budget_type_code is null )
				 OR
				 (bv.fin_plan_type_id is NULL
				  and bv.budget_type_code = p_budget_type_code
				  and NOT EXISTS (select 'Y'
				    		  from pa_budget_versions bv1
						  where bv1.project_id = bv.project_id
						  and bv1.fin_plan_type_id = p_fin_plan_type_id)
				 )
			  );

		cursor bdgt_entry_code(p_bdgt_entry_method varchar2) IS
			SELECT distinct ENTRY_LEVEL_CODE
			--	,CATEGORIZATION_CODE
			FROM   pa_budget_entry_methods
			WHERE  BUDGET_ENTRY_METHOD_CODE = p_bdgt_entry_method ;

		cursor plan_entry_code(p_plan_version_id  Number) IS
			SELECT nvl(decode(fin_plan_option_level_code
	            	,'PLAN_VERSION',decode(fin_plan_preference_code
					 ,'COST_ONLY'
			                    ,decode(COST_FIN_PLAN_LEVEL_CODE,null,ALL_FIN_PLAN_LEVEL_CODE
							,COST_FIN_PLAN_LEVEL_CODE)
				         ,'COST_AND_REV_SEP'
					    ,decode(COST_FIN_PLAN_LEVEL_CODE,null,ALL_FIN_PLAN_LEVEL_CODE
                                                        ,COST_FIN_PLAN_LEVEL_CODE))
                	,'PROJECT',decode(fin_plan_preference_code
					,'COST_ONLY'
				            ,decode(COST_FIN_PLAN_LEVEL_CODE,null,ALL_FIN_PLAN_LEVEL_CODE
							,COST_FIN_PLAN_LEVEL_CODE)
				        ,'COST_AND_REV_SEP'
                                            ,decode(COST_FIN_PLAN_LEVEL_CODE,null,ALL_FIN_PLAN_LEVEL_CODE
                                                        ,COST_FIN_PLAN_LEVEL_CODE))
                	,'PLAN_TYPE',decode(fin_plan_preference_code
					,'COST_ONLY'
				            ,decode(COST_FIN_PLAN_LEVEL_CODE,null,ALL_FIN_PLAN_LEVEL_CODE
							,COST_FIN_PLAN_LEVEL_CODE)
				        ,'COST_AND_REV_SEP'
                                            ,decode(COST_FIN_PLAN_LEVEL_CODE,null,ALL_FIN_PLAN_LEVEL_CODE
                                                        ,COST_FIN_PLAN_LEVEL_CODE))
                 		),'~') entry_level_code
    			FROM pa_proj_fp_options
    			WHERE  project_id       = p_project_id
			AND fin_plan_version_id = p_plan_version_id
			AND fin_plan_type_id    = p_fin_plan_type_id
			AND fin_plan_preference_code in ('COST_ONLY','COST_AND_REV_SEP')
			ORDER BY entry_level_code;


		cur_thres_type  threshold_type%ROWTYPE;
		l_entry_method    varchar2(1):= 'L'; -- Lowest task level


        BEGIN
		IF p_threshold_amt_type = 'BUDGET' Then
			OPEN threshold_type;
			FETCH threshold_type INTO cur_thres_type;
			IF g_debug_mode = 'Y' THEN
				PA_DEBUG.write_file('LOG','Inside get_bdgt_entry level Type['
				||cur_thres_type.threshold_Type||
				 ']entry method code['||cur_thres_type.budget_entry_method_code||
				 ']Bdgt Version['||cur_thres_type.budget_version_id||
				 ']');
			END IF;
			IF threshold_type%FOUND Then

			    IF cur_thres_type.threshold_Type = 'BUDGET TYPE' Then
				OPEN bdgt_entry_code(cur_thres_type.budget_entry_method_code);
				FETCH bdgt_entry_code INTO l_entry_method;
				CLOSE bdgt_entry_code;

			    ELSIF cur_thres_type.threshold_Type = 'PLAN TYPE' Then
				OPEN plan_entry_code(cur_thres_type.budget_version_id);
				FETCH plan_entry_code INTO l_entry_method;
				CLOSE plan_entry_code;

			    END IF;
			END IF;
			IF NVL(l_entry_method,'P') <> 'L' Then
				l_entry_method := 'P'; -- project level
			End If;
			CLOSE threshold_type;

		END IF;
		IF g_debug_mode = 'Y' THEN
			pa_debug.write_file('LOG','Budget Entry level code['||l_entry_method||']');
		END IF;

		Return l_entry_method;

	EXCEPTION
		WHEN OTHERS THEN
			RAISE;

	END Get_Bdgt_entry_level_code;



	/* -------------------------------------------------------------
	   Determine if the cost distribution line is 'OPEN' or 'CLOSED'
	   ------------------------------------------------------------- */
	FUNCTION cdl_status
		(p_cutoff_date IN DATE
		,p_expenditure_item_id IN NUMBER
		,p_line_num IN NUMBER)
	RETURN VARCHAR2
	IS
		lv_value		VARCHAR2(30);
	BEGIN
		-- Test if the cdl row has already been placed in service
		SELECT	'CLOSED'
		INTO	lv_value
		FROM	DUAL
		WHERE	EXISTS
			(SELECT	'X'
			 FROM	pa_project_asset_line_details	ppald
			 WHERE	ppald.reversed_flag = 'N'
			 AND	ppald.line_num = p_line_num
			 AND	ppald.expenditure_item_id = p_expenditure_item_id);

		RETURN NVL(lv_value,'OPEN');
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RETURN 'OPEN';
		WHEN OTHERS THEN
			RETURN 'CLOSED';
	END;




	/* -------------------------------------------------------
	   Determine if the associated exp type should be excluded
	   ------------------------------------------------------- */
	FUNCTION exclude_expenditure_type
		(p_exp_type IN VARCHAR2
		,p_rate_name IN VARCHAR2
		,p_interest_calc_method IN VARCHAR2)
	RETURN VARCHAR2
	IS
		lv_exp_type		pa_ind_cost_codes.expenditure_type%TYPE;
		ln_count		NUMBER;
	BEGIN
		-- Test for exclusion based on simple interest method
		IF p_interest_calc_method = 'SIMPLE' THEN
			SELECT	picc.expenditure_type
			INTO	lv_exp_type
			FROM	pa_ind_cost_codes	picc
			WHERE	picc.ind_cost_code = p_rate_name;

			IF lv_exp_type = p_exp_type THEN
				RETURN 'Y';
			END IF;
		END IF;


		-- Test for specified exclusion
		SELECT	1
		INTO	ln_count
		FROM    dual
		WHERE EXISTS(
			SELECT null
			FROM	pa_cint_exp_type_excl	pcete
			WHERE	pcete.expenditure_type = p_exp_type
			AND	pcete.ind_cost_code = p_rate_name
			);

		IF ln_count <> 0 THEN
			RETURN 'Y';
		END IF;


		-- If all tests passed, return no exclusion
		RETURN 'N';
	EXCEPTION
		WHEN OTHERS THEN
			RETURN 'N';
	END;



	/* ---------------------------------------------
	   Determine if the task is capitalizable or not
	   --------------------------------------------- */
	FUNCTION task_capital_flag
		(p_project_id  IN NUMBER
                 ,p_task_id IN NUMBER
		 ,p_task_bill_flag IN VARCHAR2)
	RETURN VARCHAR2
	IS
		lv_billable_flag        VARCHAR2(1);
		lv_work_type_id         NUMBER(15);
	BEGIN
		-- Use the work type to determine capital status for the task if appropriate

		lv_work_type_id := PA_UTILS4.get_work_type_id
			   ( p_project_id     => p_project_id
                             ,p_task_id       => p_task_id
                             ,p_assignment_id  => 0
                           );

		lv_billable_flag := PA_UTILS4.get_trxn_work_billabilty
			   (p_work_type_id       => lv_work_type_id
                            ,p_tc_extn_bill_flag =>p_task_bill_flag  );

		RETURN NVL(lv_billable_flag,'N');
	EXCEPTION
		WHEN OTHERS THEN
			RETURN 'N';
	END;



------------------------------------------------------------------
------------------------------------------------------------------
--	U  T  I  L  I  T  Y     P  R  O  C  E  D  U  R  E  S	--
------------------------------------------------------------------
------------------------------------------------------------------

	/* -------------------------------------
	   Get the GL period start and end dates
	   ------------------------------------- */
	PROCEDURE get_period_dates
		(p_gl_period IN VARCHAR2
		,x_start_date OUT NOCOPY DATE
		,x_end_date OUT NOCOPY DATE
		,x_fiscal_year OUT NOCOPY NUMBER
		,x_quarter_num OUT NOCOPY NUMBER
		,x_period_num OUT NOCOPY NUMBER
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2)
	IS
	BEGIN
		-- Get information for the parameter GL period
		SELECT	gps.start_date
			,gps.end_date
			,gps.period_year
			,gps.quarter_num
			,gps.period_num
		INTO	x_start_date
			,x_end_date
			,x_fiscal_year
			,x_quarter_num
			,x_period_num
		FROM	gl_period_statuses	gps
			,pa_implementations	pi
		WHERE	gps.period_name = p_gl_period
		AND	gps.application_id = g_gl_app_id
		AND	gps.set_of_books_id = pi.set_of_books_id;

		x_return_status := 'S';
		x_error_msg_count := 0;
		x_error_msg_code := NULL;
	EXCEPTION
		WHEN OTHERS THEN
			x_return_status := 'U';
			x_error_msg_count := 1;
			x_error_msg_code := SQLERRM;
	END;



	/* -------------------------------------
	   Get the GL period start and end dates
	   ------------------------------------- */
	PROCEDURE get_next_period
		(p_fiscal_year IN NUMBER
		,p_period_num IN NUMBER
		,x_fiscal_year OUT NOCOPY NUMBER
		,x_period_num OUT NOCOPY NUMBER
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2)
	IS
		ld_curr_date		DATE;
		ld_next_date		DATE;
	BEGIN
		-- Get the next non-adjustment period after the parameter period
		SELECT	gps.period_year
			,gps.period_num
		INTO	x_fiscal_year
			,x_period_num
		FROM	gl_period_statuses	gps
			,pa_implementations	pi
		WHERE	gps.application_id = g_gl_app_id
		AND	gps.set_of_books_id = pi.set_of_books_id
		AND	gps.adjustment_period_flag = 'N'
		AND	gps.start_date =
			(SELECT	MIN(gps.start_date)
			 FROM	gl_period_statuses	gps
				,pa_implementations	pi
			 WHERE	gps.application_id = g_gl_app_id
			 AND	gps.set_of_books_id = pi.set_of_books_id
			 AND	gps.adjustment_period_flag = 'N'
			 AND	gps.start_date >
				(SELECT	gps.end_date
				 FROM	gl_period_statuses	gps
			 		,pa_implementations	pi
			 	 WHERE	gps.application_id = g_gl_app_id
			 	 AND	gps.set_of_books_id = pi.set_of_books_id
			 	 AND	gps.period_year = p_fiscal_year
			 	 AND	gps.period_num = p_period_num));

		x_return_status := 'S';
		x_error_msg_count := 0;
		x_error_msg_code := NULL;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			x_fiscal_year := NULL;
			x_period_num := NULL;
			x_return_status := 'S';
			x_error_msg_count := 0;
			x_error_msg_code := NULL;
		WHEN OTHERS THEN
			x_return_status := 'U';
			x_error_msg_count := 1;
			x_error_msg_code := SQLERRM;
	END;



	/* --------------------------------------------------------------
	   Return the number of non-adjustment periods in the fiscal year
	   -------------------------------------------------------------- */
	FUNCTION num_of_periods
		(p_fiscal_year IN NUMBER)
	RETURN NUMBER
	IS
		ln_count		NUMBER;
	BEGIN
		-- Test if the cdl row has already been placed in service
		SELECT	COUNT(*)
		INTO	ln_count
		FROM	gl_period_statuses	gps
			,pa_implementations	pi
		WHERE	gps.period_year = p_fiscal_year
		AND	gps.application_id = g_gl_app_id
		AND	gps.set_of_books_id = pi.set_of_books_id
		AND	adjustment_period_flag = 'N';

		RETURN ln_count;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN 0;
	END;



	/* --------------------------------------------------------------------------------
	   Check for the existence of Cap Interest batches for the project, period and rate
	   -------------------------------------------------------------------------------- */
	PROCEDURE check_project_batches
		(p_project_id IN NUMBER
		,p_rule_id IN NUMBER
		,p_fiscal_year IN NUMBER
		,p_quarter_num IN NUMBER
		,p_period_num IN NUMBER
		,p_rate_name IN VARCHAR2
		,x_bypass OUT NOCOPY VARCHAR2
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2)
	IS
	BEGIN
		-- Look for interest transactions against the project, period and rate
		SELECT	'Y'
		INTO	x_bypass
		FROM	DUAL
		WHERE	EXISTS
			(SELECT	'X'
			 FROM	pa_alloc_txn_details	patd
				,pa_alloc_runs		par
			 WHERE	patd.project_id = p_project_id
			 AND	patd.run_id = par.run_id
			 AND	par.run_status <> 'RV'
			 AND	par.cint_rate_name = p_rate_name
			 AND	par.period_num = p_period_num
			 AND	par.quarter = p_quarter_num
			 AND	par.fiscal_year = p_fiscal_year
			 AND	par.rule_id = p_rule_id)
		/* This condition is added to check the CRL migrated trxns
		 * Since we are only migrating the rate name defaulted at the BG
                 * but the transactions includes the rate name defaulted at BG and
                 * overriding rate names.
                 * EX: projects p1,,,p5 are associated with rate1 are at BG and p7 - rate2 (overide)
                 * Before migration capint run for FEB-02 and we migrated p1 to p7
                 * again when user runs capint for FEB-02 after migration
		 * ideally p7 should not be picked up for processing. In order to avoid this
		 * the following condition is added : check run irresepective of rate name
                 * for the given project and period and the rate name doesnot exists in the
                 * pa_ind_cost_codes table
                 */
		  OR EXISTS (SELECT 'X'
			    FROM   pa_alloc_txn_details    patd
                                ,pa_alloc_runs          par
                            WHERE  patd.run_id = par.run_id
                            AND    par.run_status <> 'RV'
			    AND    patd.project_id = p_project_id
                            AND    par.period_num = p_period_num
                            AND    par.quarter = p_quarter_num
                            AND    par.fiscal_year = p_fiscal_year
                            AND    par.rule_id = p_rule_id
                            AND    NOT EXISTS ( -- check for override rates which are not migrated
                                            select null
					    from pa_ind_cost_codes icc
					    where icc.ind_cost_code = par.cint_rate_name
					    and  icc.ind_cost_code_usage = 'CAPITALIZED_INTEREST'
                                           )
                          );

		x_return_status := 'S';
		x_error_msg_count := 0;
		x_error_msg_code := NULL;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			x_bypass := 'N';
			x_return_status := 'S';
			x_error_msg_count := 0;
			x_error_msg_code := NULL;
		WHEN OTHERS THEN
			x_return_status := 'U';
			x_error_msg_count := 1;
			x_error_msg_code := SQLERRM;
	END;




	/* -----------------------------------------------------------------------------
	   Check for a valid compiled version for the project schedule and exp item date
	   ----------------------------------------------------------------------------- */
	PROCEDURE check_project_schedule
		(p_int_sch_id IN NUMBER
		,p_test_date IN DATE
		,x_sched_version_id OUT NOCOPY NUMBER
		,x_bypass OUT NOCOPY VARCHAR2
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2)
	IS
	BEGIN
		SELECT	ind_rate_sch_revision_id
		INTO	x_sched_version_id
		FROM	pa_ind_rate_sch_revisions	pirsr
		WHERE	TRUNC(p_test_date) BETWEEN
			TRUNC(pirsr.start_date_active) AND TRUNC(NVL(pirsr.end_date_active, p_test_date))
		AND	pirsr.compiled_flag = 'Y'
		AND	pirsr.ind_rate_sch_id = p_int_sch_id;

		x_bypass := 'N';
		x_return_status := 'S';
		x_error_msg_count := 0;
		x_error_msg_code := NULL;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			x_bypass := 'Y';
			x_return_status := 'S';
			x_error_msg_count := 0;
			x_error_msg_code := NULL;
		WHEN OTHERS THEN
			x_return_status := 'U';
			x_error_msg_count := 1;
			x_error_msg_code := SQLERRM;
	END;

        /* -----------------------------------------------------------------------------
           Check the schedule contains this rate name or not
           ----------------------------------------------------------------------------- */
        PROCEDURE check_schedule_has_ratename
                 (p_sch_id               IN Number
                 ,p_sch_rev_date         IN date
                 ,p_sch_rev_id           IN Number
                 ,p_rate_name            IN Varchar2
                 ,x_bypass_project       OUT NOCOPY Varchar2
                 ,x_return_status        OUT NOCOPY Varchar2
                 ,x_error_msg_count      OUT NOCOPY Number
                 ,x_error_msg_code       OUT NOCOPY Varchar2 )
        IS
		l_rate_falg varchar2(10);

        BEGIN
		SELECT 'Y'
		INTO l_rate_falg
		FROM DUAL
		WHERE EXISTS (
                	SELECT  null
                	FROM    pa_cint_rate_multipliers rate
                	WHERE   rate.ind_rate_sch_id = p_sch_id
			AND     rate.ind_rate_sch_revision_id = p_sch_rev_id
                	AND     rate.rate_name = p_rate_name
                          );
                x_bypass_project := 'N';
                x_return_status := 'S';
                x_error_msg_count := 0;
                x_error_msg_code := NULL;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_bypass_project:= 'Y';
                        x_return_status := 'S';
                        x_error_msg_count := 0;
                        x_error_msg_code := NULL;
                WHEN OTHERS THEN
                        x_return_status := 'U';
                        x_error_msg_count := 1;
                        x_error_msg_code := SQLERRM;
        END;

	/* --------------------------------------------------------------------
	   Check the project or task against the duration and amount thresholds
	   -------------------------------------------------------------------- */
	PROCEDURE check_thresholds
		(p_project_id IN NUMBER
		,p_task_id IN NUMBER
		,p_rate_name IN VARCHAR2
		,p_start_date IN DATE
		,p_end_date IN DATE
		,p_threshold_amt_type IN VARCHAR2
		,p_budget_type IN VARCHAR2
		,p_fin_plan_type_id IN NUMBER
		,p_interest_calc_method IN VARCHAR2
		,p_cip_cost_type IN VARCHAR2
		,x_duration_threshold IN OUT NOCOPY NUMBER
		,x_amt_threshold IN OUT NOCOPY NUMBER
		,x_bypass OUT NOCOPY VARCHAR2
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2)
	IS
		ln_duration		NUMBER;
		ln_amount		NUMBER;
		ln_task_amt		NUMBER;
		/**
		CURSOR	cur_non_cap_tasks IS
		SELECT	task_id
		FROM	pa_tasks
		WHERE	project_id = p_project_id
		AND	task_capital_flag(task_id) = 'N';

		r_task			cur_non_cap_tasks%ROWTYPE;
		**/
	BEGIN
              IF g_debug_mode = 'Y' THEN
                  pa_debug.write_file('LOG','Inside Check Thresholds: Budget Type['||p_budget_type||
			']Finplan type['||p_fin_plan_type_id||']Amt Type['||p_threshold_amt_type||
			']Cost Type['||p_cip_cost_type||']Duration['||x_duration_threshold||
			']Threshold Amt['||x_amt_threshold||']p_start_date['||p_start_date||']');
              END IF;

		-- Call the client extension to reset the threshold values if desired
		pa_client_extn_cap_int.check_thresholds
			(p_project_id
			,p_task_id
			,p_rate_name
			,p_start_date
			,p_end_date
			,p_threshold_amt_type
			,p_budget_type
                        ,p_fin_plan_type_id
			,p_interest_calc_method
			,p_cip_cost_type
			,x_duration_threshold
			,x_amt_threshold
			,x_return_status
			,x_error_msg_count
			,x_error_msg_code);
              IF g_debug_mode = 'Y' THEN
                  pa_debug.write_file('LOG','Threshold amt from Client Extn:Amt['||x_amt_threshold||
				']Duration['||x_duration_threshold||']x_return_status['||x_return_status||
				']g_bdgt_entry_level_code['||g_bdgt_entry_level_code||']');
	      End If;


		-- If client extension returns an error, then return immediately
		IF NVL(x_return_status,'S') <> 'S' THEN
                        x_return_status := 'U';
                        x_error_msg_count := 1;
                        x_error_msg_code := SQLERRM;
			RETURN;
		END IF;


		-- Initialize the bypass variable for the delivered test
		x_bypass := 'N';


		-- Check the duration threshold
		IF NVL(x_duration_threshold,0) <> 0 AND p_start_date IS NOT NULL THEN
		    ln_duration := (TRUNC(p_end_date) + 1) - TRUNC(p_start_date);

		    IF ln_duration < x_duration_threshold THEN
			x_bypass := 'Y';
		    END IF;
		END IF;


		-- Check the amount threshold if set to 'budget'
		IF x_bypass = 'N' AND NVL(x_amt_threshold,0) <> 0 AND
		   p_threshold_amt_type = 'BUDGET' THEN

		   -- Get the current budgeted amount for the project (and task id specified)
		   IF (p_task_id IS NULL OR g_bdgt_entry_level_code = 'L') Then /* added for bug fix:2972865 */
			    ln_amount := NVL(pa_fin_plan_utils.get_budgeted_amount
						(p_project_id => p_project_id
						,p_task_id => p_task_id
						,p_fin_plan_type_id => p_fin_plan_type_id
						,p_budget_type_code => p_budget_type
						,p_amount_type => p_cip_cost_type)
					,0);

			IF g_debug_mode = 'Y' THEN
                  		pa_debug.write_file('LOG','Budget/Plan amt from Finplanutils API['||ln_amount||']');
			End If;

			/** This check is not required as the setup of budget should be ensured that
                         ** the budget is only for Capitalized projects and Tasks
			-- Subtract budgeted amounts for non-capital tasks if checking at the project-level
			IF p_task_id IS NULL THEN
				FOR r_task in cur_non_cap_tasks LOOP
					ln_task_amt := NVL(pa_fin_plan_utils.get_budgeted_amount
								(p_project_id
								,r_task.task_id
								,p_fin_plan_type_id
								,p_budget_type
								,p_cip_cost_type)
							,0);

					ln_amount := ln_amount - ln_task_amt;
				END LOOP;
			END IF;
			***/

			IF NVL(ln_amount,0) < x_amt_threshold THEN
			    x_bypass := 'Y';
			END IF;

		   END IF; -- end of Task level check

		END IF; -- end of threshold amt type

		x_return_status := 'S';
		x_error_msg_count := 0;
		x_error_msg_code := NULL;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			x_bypass := 'Y';
			x_return_status := 'S';
			x_error_msg_count := 0;
			x_error_msg_code := NULL;
		WHEN OTHERS THEN
			x_return_status := 'U';
			x_error_msg_count := 1;
			x_error_msg_code := SQLERRM;
	END;




	/* -------------------------------------------
	   Validate the task for capitalized interest
	   ------------------------------------------- */
	PROCEDURE validate_task
		(p_project_id IN NUMBER
		,p_task_id IN NUMBER
		,p_exp_item_date IN DATE
		,p_period_end_date IN DATE
		,x_bypass OUT NOCOPY VARCHAR2
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2)
	IS
		ln_task_id		NUMBER;
		lv_cap_flag		VARCHAR2(1);
	BEGIN
		SELECT	pt.task_id,nvl(pt.billable_flag,'N')
		INTO	ln_task_id,lv_cap_flag
		FROM	pa_tasks		pt
		WHERE	TRUNC(p_period_end_date) <= TRUNC(NVL(pt.cint_stop_date,p_period_end_date))
		AND	NVL(pt.cint_eligible_flag,'Y') = 'Y'
		AND	TRUNC(p_exp_item_date) BETWEEN
				TRUNC(NVL(pt.start_date,p_exp_item_date)) AND
				TRUNC(NVL(pt.completion_date,p_exp_item_date))
		--AND	pt.chargeable_flag = 'Y'
		AND	pt.task_id = p_task_id
		AND	pt.project_id = p_project_id;


		-- Perform a special capitalizable check to allow specific error returns
		lv_cap_flag := task_capital_flag(p_project_id => p_project_id
                                                 ,p_task_id   => p_task_id
					         ,p_task_bill_flag => 'Y'
						  -- capint EIs are always billable
                                                  -- irrespective of task billability lv_cap_flag );
                                                 );

		IF lv_cap_flag = 'Y' THEN
			x_bypass := 'N';
			x_return_status := 'S';
			x_error_msg_count := 0;
			x_error_msg_code := NULL;
		ELSE
			x_bypass := 'Y';
			x_return_status := 'E';
			x_error_msg_count := 1;
			x_error_msg_code := 'NON_CAPITAL';
		END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			x_bypass := 'Y';
			x_return_status := 'S';
			x_error_msg_count := 0;
			x_error_msg_code := NULL;
		WHEN OTHERS THEN
			x_return_status := 'U';
			x_error_msg_count := 1;
			x_error_msg_code := SQLERRM;
	END;




	/* --------------------------------------------------
	   Get the interest rate multiplier from the schedule
	   -------------------------------------------------- */
	PROCEDURE get_rate_multiplier
		(p_rate_name IN VARCHAR2
		,p_sched_version_id IN NUMBER
		,p_task_owning_org_id IN NUMBER
		,p_proj_owning_org_id IN NUMBER
		,x_rate_mult OUT NOCOPY NUMBER
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2)
	IS
		ln_organization_id		hr_all_organization_units.organization_id%TYPE;

		CURSOR	cur_mult IS
		SELECT	multiplier
		FROM	pa_cint_rate_multipliers
		WHERE	rate_name = p_rate_name
		AND	organization_id = ln_organization_id
		AND	ind_rate_sch_revision_id = p_sched_version_id;

	BEGIN
		-- Retrieve the rate multiplier for the task owning org
		ln_organization_id := p_task_owning_org_id;

		OPEN	cur_mult;
		FETCH	cur_mult INTO x_rate_mult;
		CLOSE	cur_mult;

		-- If no rate found for the task org, try the project org
		IF x_rate_mult IS NULL THEN
			ln_organization_id := p_proj_owning_org_id;

			OPEN	cur_mult;
			FETCH	cur_mult INTO x_rate_mult;
			CLOSE	cur_mult;
		END IF;


		-- Set the return variables accordingly
		IF x_rate_mult IS NULL THEN
			x_return_status := 'E';
			x_error_msg_count := 1;
			x_error_msg_code := 'No rate value found for task or project organizations';
		ELSE
			x_return_status := 'S';
			x_error_msg_count := 0;
			x_error_msg_code := NULL;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			x_return_status := 'U';
			x_error_msg_count := 1;
			x_error_msg_code := SQLERRM;
	END;



------------------------------------------------------------------
------------------------------------------------------------------
--	O  U  T  P  U  T     P  R  O  C  E  D  U  R  E  S	--
------------------------------------------------------------------
------------------------------------------------------------------

	/* -------------------------------------------
	   Write the Run row for the Cap Interest rate
	   ------------------------------------------- */
	PROCEDURE write_run
		(p_gl_period IN VARCHAR2
		,p_rule_id IN NUMBER
		,p_exp_type IN VARCHAR2
		,p_exp_item_date IN DATE
		,p_currency_code IN VARCHAR2
		,p_fiscal_year IN NUMBER
		,p_quarter_num IN NUMBER
		,p_period_num IN NUMBER
		,p_org_id IN NUMBER
		,p_rate_name IN VARCHAR2
		,p_autorelease IN VARCHAR2
		,x_run_id OUT NOCOPY NUMBER
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2)
	IS
	BEGIN
		SELECT	pa_alloc_runs_s.nextval
		INTO	x_run_id
		FROM	DUAL;

		pa_alloc_run.insert_alloc_runs
			(x_run_id                  => x_run_id
			,p_rule_id                 => p_rule_id
			,p_run_period              => p_gl_period
			,p_expnd_item_date         => p_exp_item_date
			,p_creation_date           => SYSDATE
			,p_created_by              => g_created_by
			,p_last_update_date        => SYSDATE
			,p_last_updated_by         => g_last_updated_by
			,p_last_update_login       => g_last_update_login
			,p_pool_percent            => NULL
			,p_period_type             => NULL
			,p_source_amount_type      => NULL
			,p_source_balance_category => NULL
			,p_source_balance_type     => NULL
			,p_alloc_resource_list_id  => NULL
			,p_auto_release_flag       => p_autorelease
			,p_allocation_method       => NULL
			,p_imp_with_exception      => NULL
			,p_dup_targets_flag        => NULL
			,p_target_exp_type_class   => 'PJ'
			,p_target_exp_org_id       => NULL
			,p_target_exp_type         => p_exp_type
			,p_target_cost_type        => NULL
			,p_offset_exp_type_class   => NULL
			,p_offset_exp_org_id       => NULL
			,p_offset_exp_type         => NULL
			,p_offset_cost_type        => NULL
			,p_offset_method           => NULL
			,p_offset_project_id       => NULL
			,p_offset_task_id          => NULL
			,p_run_status              => 'DS'
			,p_basis_method            => NULL
			,p_basis_relative_period   => NULL
			,p_basis_amount_type       => NULL
			,p_basis_balance_category  => NULL
			,p_basis_budget_type_code  => NULL
			,p_basis_balance_type      => NULL
			,p_basis_resource_list_id  => NULL
			,p_fiscal_year             => p_fiscal_year
			,p_quarter                 => p_quarter_num
			,p_period_num              => p_period_num
			,p_target_exp_group        => p_rate_name
			,p_offset_exp_group        => NULL
			,p_total_pool_amount       => NULL
			,p_allocated_amount        => 0
			,p_reversal_date           => NULL
			,p_draft_request_id        => g_request_id
			,p_draft_request_date      => SYSDATE
			,p_release_request_id      => NULL
			,p_release_request_date    => NULL
			,p_denom_currency_code     => p_currency_code
			,p_fixed_amount            => NULL
			,p_rev_target_exp_group    => NULL
			,p_rev_offset_exp_group    => NULL
			,p_org_id                  => p_org_id
			,p_limit_target_projects_code => 'O'
			,p_cint_rate_name	   => p_rate_name);

		x_return_status := 'S';
		x_error_msg_count := 0;
		x_error_msg_code := NULL;
	EXCEPTION
		WHEN OTHERS THEN
			x_return_status := 'U';
			x_error_msg_count := 1;
			x_error_msg_code := SQLERRM;
	END;



	/* ----------------------------------------
	   Write exception information to the table
	   ---------------------------------------- */
	PROCEDURE write_exception
		(p_exception_code IN VARCHAR2
		,p_task_id IN NUMBER
		,p_project_id IN NUMBER
		,p_rule_id IN NUMBER
		,p_run_id IN NUMBER
		,p_exception_type IN VARCHAR2
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2)
	IS
	BEGIN

		pa_alloc_run.ins_alloc_exceptions
			(p_rule_id           => p_rule_id
			,p_run_id            => p_run_id
			,p_creation_date     => SYSDATE
			,p_created_by        => g_created_by
			,p_last_updated_date => SYSDATE
			,p_last_updated_by   => g_last_updated_by
			,p_last_update_login => g_last_update_login
			,p_level_code        => 'T'
			,p_exception_type    => p_exception_type
			,p_project_id        => p_project_id
			,p_task_id           => p_task_id
			,p_exception_code    => p_exception_code);

		x_return_status := 'S';
		x_error_msg_count := 0;
		x_error_msg_code := NULL;
	EXCEPTION
		WHEN OTHERS THEN
			x_return_status := 'U';
			x_error_msg_count := 1;
			x_error_msg_code := SQLERRM;
	END;



------------------------------------------------------------------
------------------------------------------------------------------
--	R  E  M  O  V  A  L     P  R  O  C  E  D  U  R  E  S	--
------------------------------------------------------------------
------------------------------------------------------------------


	/* ------------------------------------------
	   Remove the run row for the rate and period
	   ------------------------------------------ */
	PROCEDURE remove_run
		(p_run_id IN NUMBER
		,p_mode   IN VARCHAR2
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2)
	IS
		l_exists varchar2(1) := 'N';
	BEGIN
        	IF p_mode <> 'EXCEPTION' Then
			DELETE FROM pa_alloc_runs_all
			WHERE run_id = p_run_id;
		ELSE
			BEGIN
			       /* Bug fix:3051131 if there is any un-expected error encounters and If there are no trxn or exceptions
                      		*  created then delete the run created in the exception portion
                       		*/
                       		IF g_debug_mode = 'Y' THEN
                  			pa_debug.write_file('LOG','Inside remove_run  mode = EXCEPTION');
            			End If;
	    			IF p_run_id is NOT NULL then

					SELECT 'Y'
					INTO l_exists
					FROM dual
					WHERE EXISTS
						(SELECT NULL
			 			FROM PA_ALLOC_TXN_DETAILS det
			 			WHERE det.run_id = p_run_id)
					 OR
					  EXISTS (SELECT null
						FROM pa_alloc_exceptions exc
						where exc.run_id = p_run_id ) ;

					IF l_exists = 'Y' Then
						UPDATE pa_alloc_runs_all run
						SET run.run_status = 'DF'
						WHERE  run.run_id = p_run_id
						AND EXISTS (SELECT null
						            FROM pa_alloc_exceptions exc
						            WHERE exc.run_id = run.run_id ) ;
						Commit;
					End If;


	    			End If;


			EXCEPTION
				WHEN NO_DATA_FOUND THEN
                      			IF g_debug_mode = 'Y' THEN
                          			pa_debug.write_file('LOG',' No Trxn found, Removing the run');
                      			End If;
                      			IF l_exists = 'N' Then
                      			  Delete from pa_alloc_runs_all
                      			  where run_id = p_run_id;
                      			  Commit;
                      			End If;
                      		WHEN OTHERS THEN
                      			RAISE;
                	END;
               	END IF; -- end of p_mode

		x_return_status := 'S';
		x_error_msg_count := 0;
		x_error_msg_code := NULL;
	EXCEPTION
		WHEN OTHERS THEN
			x_return_status := 'U';
			x_error_msg_count := 1;
			x_error_msg_code := SQLERRM;
	END;



----------------------------------------------------------
----------------------------------------------------------
--	M  A  I  N     P  R  O  C  E  D  U  R  E  S	--
----------------------------------------------------------
----------------------------------------------------------

	/* -------------------------------------
	   Generate cap interest transactions
	   ------------------------------------- */
	PROCEDURE generate_cap_interest
		(p_from_project_num IN VARCHAR2 DEFAULT NULL
		,p_to_project_num IN VARCHAR2 DEFAULT NULL
		,p_gl_period IN VARCHAR2
		,p_exp_item_date IN DATE
		,p_source_details IN VARCHAR2 DEFAULT 'N'
		,p_autorelease IN VARCHAR2 DEFAULT 'N'
		,p_mode IN VARCHAR2 DEFAULT 'G'
		,x_run_id IN OUT NOCOPY NUMBER
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2)
	IS

		-- Alloc Exception Codes
		c_proj_lock			pa_alloc_exceptions.exception_code%TYPE :=
						'PA_CINT_PROJ_LOCK';
		c_proj_batches			pa_alloc_exceptions.exception_code%TYPE :=
						'PA_CINT_PROJ_BATCHES';
		c_proj_sched			pa_alloc_exceptions.exception_code%TYPE :=
						'PA_CINT_PROJ_SCHEDULES';
		c_proj_sch_no_rate              pa_alloc_exceptions.exception_code%TYPE :=
						'PA_CINT_PROJ_SCH_NO_RATE';
		c_proj_threshold		pa_alloc_exceptions.exception_code%TYPE :=
						'PA_CINT_PROJ_THRESHOLDS';
		c_proj_no_txns			pa_alloc_exceptions.exception_code%TYPE :=
						'PA_CINT_PROJ_NO_TXNS';
		c_task_threshold		pa_alloc_exceptions.exception_code%TYPE :=
						'PA_CINT_TASK_THRESHOLDS';
		c_task_null_target		pa_alloc_exceptions.exception_code%TYPE :=
						'PA_CINT_TASK_NULL_TARGET';
		c_task_not_valid		pa_alloc_exceptions.exception_code%TYPE :=
						'PA_CINT_TASK_NOT_VALID';
		c_rate_mult			pa_alloc_exceptions.exception_code%TYPE :=
						'PA_CINT_RATE_MULTIPLIER';


		-- PLSQL table types and variables

		TYPE  Char4000TabTyp  IS TABLE OF VARCHAR2(4000)
			INDEX BY BINARY_INTEGER;

		lt_alloc_txn_id			pa_plsql_datatypes.idtabtyp;
		lt_task_id			pa_plsql_datatypes.idtabtyp;
		lt_task_num			pa_plsql_datatypes.char30tabtyp;
		lt_task_owning_org_id		pa_plsql_datatypes.idtabtyp;
		lt_task_start_date		pa_plsql_datatypes.datetabtyp;
		lt_task_end_date		pa_plsql_datatypes.datetabtyp;
		lt_exp_org_id			pa_plsql_datatypes.idtabtyp;
		lt_rate_mult			pa_plsql_datatypes.amttabtyp;
		lt_grouping_method		char4000tabtyp;
		lt_cdl_status			pa_plsql_datatypes.char30tabtyp;
		lt_prior_period_amt		pa_plsql_datatypes.amttabtyp;
		lt_curr_period_amt		pa_plsql_datatypes.amttabtyp;
		lt_target_task_id		pa_plsql_datatypes.idtabtyp;
		lt_cap_int_amt			pa_plsql_datatypes.amttabtyp;
		lt_attribute_category		pa_plsql_datatypes.char30tabtyp;
		lt_attribute1			pa_plsql_datatypes.char150tabtyp;
		lt_attribute2			pa_plsql_datatypes.char150tabtyp;
		lt_attribute3			pa_plsql_datatypes.char150tabtyp;
		lt_attribute4			pa_plsql_datatypes.char150tabtyp;
		lt_attribute5			pa_plsql_datatypes.char150tabtyp;
		lt_attribute6			pa_plsql_datatypes.char150tabtyp;
		lt_attribute7			pa_plsql_datatypes.char150tabtyp;
		lt_attribute8			pa_plsql_datatypes.char150tabtyp;
		lt_attribute9			pa_plsql_datatypes.char150tabtyp;
		lt_attribute10			pa_plsql_datatypes.char150tabtyp;
		lt_process_task_flag		pa_plsql_datatypes.char1tabtyp;


		-- Process control variables

		lv_bypass_project		VARCHAR2(1);
		lv_bypass_task			VARCHAR2(1);
		lv_exception_code		pa_alloc_exceptions.exception_code%TYPE;

		ln_proj_processed		NUMBER;
		ln_proj_written			NUMBER;
		ln_trans_written		NUMBER;
		ln_error_written		NUMBER;
		ln_warning_written		NUMBER;
		ln_proj_trans_count		NUMBER;
		ln_proj_error_count		NUMBER;
		ln_proj_warning_count		NUMBER;
		ln_proj_detail_count		NUMBER;

		process_error			EXCEPTION;


		-- Working storage variables

		ln_org_id			pa_implementations_all.org_id%TYPE;
		lv_currency_code		gl_sets_of_books.currency_code%TYPE;

		ld_period_start_date		gl_period_statuses.start_date%TYPE;

		ln_fiscal_year			gl_period_statuses.period_year%TYPE;
		ln_quarter_num			gl_period_statuses.quarter_num%TYPE;
		ln_period_num			gl_period_statuses.period_num%TYPE;

		ln_curr_period_mult		NUMBER;
		ln_period_mult			NUMBER;
		ln_rate_mult			pa_ind_cost_multipliers.multiplier%TYPE;

		ln_run_id			pa_alloc_runs_all.run_id%TYPE;
		lv_exp_org_source		pa_cint_rate_info_all.exp_org_source%TYPE;
		lv_interest_calc_method		pa_cint_rate_info_all.interest_calculation_method%TYPE;
		lv_threshold_amt_type		pa_cint_rate_info_all.threshold_amt_type%TYPE;
		ln_proj_duration_threshold	pa_cint_rate_info_all.proj_duration_threshold%TYPE;
		ln_proj_amt_threshold		pa_cint_rate_info_all.proj_amt_threshold%TYPE;
		ln_task_duration_threshold	pa_cint_rate_info_all.task_duration_threshold%TYPE;
		ln_task_amt_threshold		pa_cint_rate_info_all.task_amt_threshold%TYPE;

		ln_proj_owning_org_id		pa_projects_all.carrying_out_organization_id%TYPE;
		ln_sched_version_id		pa_ind_rate_sch_revisions.ind_rate_sch_revision_id%TYPE;
		lv_cip_cost_type		pa_project_types_all.capital_cost_type_code%TYPE;
		lv_burden_method		pa_project_types_all.burden_amt_display_method%TYPE;
		lv_tot_burden_flag		pa_project_types_all.total_burden_flag%TYPE;

		ln_target_task_id		pa_tasks.task_id%TYPE;
		ln_except_task_id		pa_tasks.task_id%TYPE;
		lv_target_task_num		pa_tasks.task_number%TYPE;

		ln_curr_task_id			pa_tasks.task_id%TYPE;
		lv_curr_task_num		pa_tasks.task_number%TYPE;
		ln_rate_trans_amt		NUMBER;
		lv_rate_status			pa_alloc_runs.run_status%TYPE;
		ln_proj_tot_amt			NUMBER;
		ln_proj_open_amt		NUMBER;
		ln_task_tot_amt			NUMBER;
		ln_task_open_amt		NUMBER;

		ln_task_start			NUMBER;
		ln_task_last			NUMBER;

		lv_first_exp_flag		VARCHAR2(1);
		lv_exception_type		pa_alloc_exceptions.exception_type%TYPE;

		ln_cap_int_amt			NUMBER;
		v_success_flag                  NUMBER;

		l_init_run_id 			NUMBER;	-- R12 NOCOPY Mandate

		-- Rate Cursor

/* Commented for Bug 6757697 End */
/*		CURSOR cur_rates IS
		SELECT	picc.ind_cost_code		rate_name
			,picc.expenditure_type		exp_type
			,pcri.exp_org_source		exp_org_source
			,pcri.threshold_amt_type	threshold_amt_type
			,pcri.budget_type_code		budget_type
			,pcri.proj_amt_threshold	proj_amt_threshold
			,pcri.task_amt_threshold	task_amt_threshold
			,pcri.proj_duration_threshold	proj_duration_threshold
			,pcri.task_duration_threshold	task_duration_threshold
			,pcri.curr_period_convention	curr_period_convention
			,pcri.interest_calculation_method interest_calc_method
			,pcri.period_rate_code		period_rate_code
			,pcri.fin_plan_type_id          fin_plan_type_id
		FROM	pa_cint_rate_info	pcri
			,pa_ind_cost_codes	picc
		WHERE	pcri.ind_cost_code = picc.ind_cost_code
		AND	picc.ind_cost_code_usage = 'CAPITALIZED_INTEREST'
		/* Start Bug fix :3028240
		AND     /** As discussed with murali the end date of the run period be between the
                         * start date active and end date active, we need not take the partial effective
                         * of the rate names
                         --((trunc(g_period_start_date) BETWEEN trunc(picc.start_date_active)
                         --AND trunc(nvl(picc.end_date_active,g_period_end_date)))
                         --OR
                         **
                         (trunc(g_period_end_date)  BETWEEN trunc(picc.start_date_active)
                         AND trunc(nvl(picc.end_date_active,g_period_end_date)))
			--)
		/* End Bug fix :3028240
		AND	EXISTS
			(SELECT	'X'
			 FROM	pa_projects			pp
				,pa_ind_rate_schedules_all_bg	pirs
				,pa_ind_rate_sch_revisions	pirsv
				/* Bug fix:3208751 ,pa_cint_rate_multipliers	pccm
				,pa_ind_cost_multipliers        pccm
			 WHERE	pp.cint_rate_sch_id = pirs.ind_rate_sch_id
			 AND	pirs.ind_rate_sch_usage = 'CAPITALIZED_INTEREST'
			 AND	pirs.ind_rate_sch_id = pirsv.ind_rate_sch_id
			 AND	pccm.ind_rate_sch_revision_id = pirsv.ind_rate_sch_revision_id
			 /** Added this condtion for bug fix :2984441 *
			 AND    TRUNC(g_period_end_date) BETWEEN
                                TRUNC(pirsv.start_date_active) AND TRUNC(NVL(pirsv.end_date_active,g_period_end_date))
			 --AND    NVL(pirsv.compiled_flag,'N') = 'Y'
			 /** End of bug fix:2984441 **/
			 /* Bug fix: 3208751 AND  pccm.rate_name = picc.ind_cost_code
			 AND    pccm.ind_cost_code = picc.ind_cost_code
			 AND	pp.segment1 BETWEEN
				NVL(p_from_project_num,pp.segment1) AND NVL(p_to_project_num,pp.segment1)
			)
		ORDER BY picc.ind_cost_code; */
/* Commented for Bug 6757697 End */
/* Added for Bug 6757697 Start */
		CURSOR cur_rates IS
		SELECT	distinct picc.ind_cost_code		rate_name  -- added distinct  for bug 8876299
			,picc.expenditure_type		exp_type
			,pcri.exp_org_source		exp_org_source
			,pcri.threshold_amt_type	threshold_amt_type
			,pcri.budget_type_code		budget_type
			,pcri.proj_amt_threshold	proj_amt_threshold
			,pcri.task_amt_threshold	task_amt_threshold
			,pcri.proj_duration_threshold	proj_duration_threshold
			,pcri.task_duration_threshold	task_duration_threshold
			,pcri.curr_period_convention	curr_period_convention
			,pcri.interest_calculation_method interest_calc_method
			,pcri.period_rate_code		period_rate_code
			,pcri.fin_plan_type_id          fin_plan_type_id
			,pirs.ind_rate_sch_id		interest_sch_id
		FROM	pa_cint_rate_info	pcri
			,pa_ind_cost_codes	picc
			,pa_ind_rate_schedules_all_bg	pirs
			,pa_ind_rate_sch_revisions	pirsv
			,pa_ind_cost_multipliers        pccm
		WHERE	pcri.ind_cost_code = picc.ind_cost_code
		AND	picc.ind_cost_code_usage = 'CAPITALIZED_INTEREST'
		AND     (trunc(g_period_end_date)  BETWEEN trunc(picc.start_date_active)
	        		 AND	trunc(nvl(picc.end_date_active,g_period_end_date)))
		 AND	pirs.ind_rate_sch_id = pirsv.ind_rate_sch_id
		  /* Added the condition for bug 8334911 */
                 AND    (TRUNC(g_period_end_date) BETWEEN
                                TRUNC(pirsv.start_date_active) AND TRUNC(NVL(pirsv.end_date_active,g_period_end_date)))
		 AND	pccm.ind_rate_sch_revision_id = pirsv.ind_rate_sch_revision_id
		 AND    pccm.ind_cost_code = picc.ind_cost_code
		-- AND	pccm.ORGANIZATION_ID = pcri.org_id  /* commented for bug 8625855 */
		 AND EXISTS
		  (SELECT 'X'
		   FROM pa_projects		pp
		   WHERE pp.cint_rate_sch_id = pirs.ind_rate_sch_id
	 	 AND	pp.template_flag = 'N'
		 AND	pp.segment1 BETWEEN
			NVL(p_from_project_num,pp.segment1) AND NVL(p_to_project_num,pp.segment1))
		ORDER BY picc.ind_cost_code;
/* Added for Bug 6757697 End */

		r_rate				cur_rates%ROWTYPE;


		-- Project Cursor

		CURSOR cur_projects IS
		SELECT	pp.project_id			project_id
			,pp.segment1			project_num
			,pp.carrying_out_organization_id	owning_org_id
			,pp.cint_rate_sch_id		interest_sch_id
			,pp.start_date			start_date
			,ppt.capital_cost_type_code	cip_cost_type
			,ppt.burden_amt_display_method	burden_method
			,ppt.total_burden_flag		tot_burden_flag
		FROM	pa_project_types	ppt
			,pa_projects		pp
		WHERE	TRUNC(g_period_end_date) <= TRUNC(NVL(pp.cint_stop_date,g_period_end_date))
		AND	pp.cint_rate_sch_id IS NOT NULL
		AND	NVL(pp.cint_eligible_flag,'Y') = 'Y'
		AND	TRUNC(g_exp_item_date) BETWEEN
			TRUNC(NVL(pp.start_date,g_exp_item_date)) AND TRUNC(NVL(pp.completion_date,g_exp_item_date))
		AND	pa_project_utils.Check_prj_stus_action_allowed
				(pp.project_status_code
				,'CAPITALIZED_INTEREST') = 'Y'
		AND	pa_project_utils.Check_prj_stus_action_allowed
				(pp.project_status_code
				,'NEW_TXNS') = 'Y'
		AND	pp.project_status_code <> 'CLOSED'
		AND	ppt.project_type_class_code = 'CAPITAL'
		AND	ppt.project_type = pp.project_type
		AND	pp.template_flag = 'N'
		AND	pp.segment1 BETWEEN
			NVL(p_from_project_num,pp.segment1) AND NVL(p_to_project_num,pp.segment1)
		ORDER BY pp.segment1;

		r_project			cur_projects%ROWTYPE;


		-- Task / Cost Distribution Line Cursor

		CURSOR	cur_cdls IS
		SELECT	pctd.task_id				task_id
			,pctd.task_number			task_num
			,pctd.task_owning_org_id		task_owning_org_id
			,pctd.task_start_date			task_start_date
			,pctd.task_completion_date		task_end_date
			,pctd.target_exp_organization_id	exp_org_id
			,pctd.rate_multiplier			rate_mult
			,pctd.cint_grouping_method		grouping_method
			,pctd.cint_cdl_status			cdl_status
			,SUM(DECODE(SIGN(ld_period_start_date - pctd.gl_date)
				,1, pctd.amount
				  , 0))				prior_period_amt
			,SUM(DECODE(SIGN(ld_period_start_date - pctd.gl_date)
				,1, 0
				  , pctd.amount))		curr_period_amt
			,'Y'					process_task_flag
                         --Bug fix:3051022 Added these columns to initialize collection tables for each element
                        ,NULL alloc_txn_id
			,NULL target_task_id
			,NULL cap_int_amt
			,NULL attribute_category
			,NULL attribute1
			,NULL attribute2
			,NULL attribute3
			,NULL attribute4
			,NULL attribute5
			,NULL attribute6
			,NULL attribute7
			,NULL attribute8
			,NULL attribute9
			,NULL attribute10
		FROM	pa_cint_txn_details_v		pctd
		WHERE	/* Commented out this condition for performance issues
			--(
			-- (NVL(lv_threshold_amt_type,'TOTAL_CIP') = 'TOTAL_CIP')
		  	-- OR
		  	-- (NVL(lv_threshold_amt_type,'TOTAL_CIP') <> 'TOTAL_CIP'
			--  AND pctd.cint_cdl_status = 'OPEN')
		        --)
			--AND
			**/
			pctd.gl_date <= TRUNC(g_period_end_date)
		AND	TRUNC(g_period_end_date) <= TRUNC(NVL(pctd.task_cint_stop_date, g_period_end_date))
		AND	TRUNC(g_exp_item_date) BETWEEN
				TRUNC(NVL(pctd.task_start_date, g_exp_item_date)) AND
				TRUNC(NVL(pctd.task_completion_date, g_exp_item_date))
		AND	pctd.project_id = g_project_id
		AND	pctd.cint_rate_name = g_rate_name
		AND     pctd.period_name   = g_gl_period
		GROUP BY pctd.task_id
			,pctd.task_number
			,pctd.task_owning_org_id
			,pctd.task_start_date
			,pctd.task_completion_date
			,pctd.target_exp_organization_id
			,pctd.rate_multiplier
			,pctd.cint_grouping_method
			,pctd.cint_cdl_status
			,'Y'
		ORDER BY pctd.task_id
			,pctd.target_exp_organization_id
			,pctd.rate_multiplier
			,pctd.cint_grouping_method;


	BEGIN

	    -- Initialize the out variables
	    x_return_status := 'S';
	    x_error_msg_count := 0;
	    x_error_msg_code := NULL;
            l_init_run_id := x_run_id; -- store passed in value for when others.

	    -- Initialize the error stack
	    pa_debug.init_err_stack ('PA_CAP_INT_PVT.GENERATE_CAP_INTEREST');

	    fnd_profile.get('PA_DEBUG_MODE',g_debug_mode);
	    g_debug_mode := NVL(g_debug_mode, 'N');

	    pa_debug.set_process
		(x_process => 'PLSQL'
		,x_write_file => 'LOG'
		,x_debug_mode => g_debug_mode);


	    -- Clear the message stack
	    fnd_msg_pub.initialize;

	    If 	g_debug_mode = 'Y' Then
                pa_debug.write_file('LOG',substr('INSIDE Generate Capint API IN PARAMS: p_from_project_num ['
                                        ||p_from_project_num||']p_to_project_num['||p_to_project_num||
                                        ']p_gl_period['||p_gl_period||']p_exp_item_date['||p_exp_item_date||
                                        ']p_source_details['||p_source_details||']p_autorelease['||p_autorelease||
                                        ']p_mode['||p_mode||']x_run_id['||x_run_id||']',1,250) );
	    End If;


	    -- Initialize process variable
	    g_created_by := NVL(TO_NUMBER(fnd_profile.value('USER_ID')),-1);
	    g_last_update_login := NVL(TO_NUMBER(fnd_profile.value('LOGIN_ID')), -1);
	    g_last_updated_by := g_created_by;
	    g_request_id := fnd_global.conc_request_id;


	    -- Execution section if this is run in 'Generate' mode
	    IF p_mode = 'G' THEN

		IF g_debug_mode = 'Y' THEN
			pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:') ||' Start program');
		END IF;


		-- Get the start and end dates for the parameter GL period
		get_period_dates
			(p_gl_period
			,ld_period_start_date
			,g_period_end_date
			,ln_fiscal_year
			,ln_quarter_num
			,ln_period_num
			,x_return_status
			,x_error_msg_count
			,x_error_msg_code);

		IF x_return_status = 'U' THEN
			pa_debug.g_err_stage := 'Get_Period_Dates for Period '||p_gl_period||
				']x-errmsg['||x_error_msg_code||']';
			RAISE process_error;
		END IF;


		-- Get currency code and ORG_ID
		pa_multi_currency.init;
		lv_currency_code := pa_multi_currency.g_accounting_currency_code;
		ln_org_id := pa_utils4.get_org_id;


		-- Set global variable for GL period
		g_gl_period := p_gl_period;
		g_period_start_date := ld_period_start_date;

		-- Set global variable for Exp Item Date
		g_exp_item_date := NVL(p_exp_item_date,g_period_end_date);

                IF g_debug_mode = 'Y' THEN
                        pa_debug.write_file('LOG','Global Var:Currency['||lv_currency_code||']Org['||ln_org_id||
				']g_gl_period['||g_gl_period||']g_period_start_date['||g_period_start_date||
				']g_period_end_date['||g_period_end_date||']g_exp_item_date['||g_exp_item_date||
				']');
		END IF;

		--------------------------------------
		-- Loop through the Cap Interest rates
		--------------------------------------
		FOR r_rate IN cur_rates LOOP

			IF g_debug_mode = 'Y' THEN
				pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:') ||
					' Rate ['||r_rate.rate_name||']');
			END IF;

			-- Initialize rate process variables
			ln_proj_processed := 0;
			ln_proj_written := 0;
			ln_trans_written := 0;
			ln_error_written := 0;
			ln_warning_written := 0;
			ln_rate_trans_amt := 0;

			g_rate_name := r_rate.rate_name;
			lv_exp_org_source := r_rate.exp_org_source;
			lv_interest_calc_method := r_rate.interest_calc_method;
			lv_threshold_amt_type := r_rate.threshold_amt_type;

			-- Determine the current period multiplier
			IF r_rate.curr_period_convention = 'FULL' THEN
				ln_curr_period_mult := 1;
			ELSIF r_rate.curr_period_convention = 'HALF' THEN
				ln_curr_period_mult := .5;
			ELSE
				ln_curr_period_mult := 0;
			END IF;

			IF g_debug_mode = 'Y' THEN
				pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:') ||
				 ' Current Period Multiplier['||TO_CHAR(ln_curr_period_mult)||']');
			END IF;


			-- Determine the monthly multiplier
			IF r_rate.period_rate_code = 'BY_NUMBER_OF_DAYS' THEN
				ln_period_mult := ((g_period_end_date + 1) - ld_period_start_date)/365;
			ELSE
				ln_period_mult := 1/num_of_periods(ln_fiscal_year);
			END IF;

			IF g_debug_mode = 'Y' THEN
				pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:') ||
					' Period Rate Multiplier['||SUBSTR(TO_CHAR(ln_period_mult),1,6)||']');
			END IF;


			-- Write the run row for this rate
			write_run
				(g_gl_period
				,g_cap_int_rule_id
				,r_rate.exp_type
				,g_exp_item_date
				,lv_currency_code
				,ln_fiscal_year
				,ln_quarter_num
				,ln_period_num
				,ln_org_id
				,g_rate_name
				,p_autorelease
				,ln_run_id
				,x_return_status
				,x_error_msg_count
				,x_error_msg_code);

			IF x_return_status = 'U' THEN
				pa_debug.g_err_stage := 'Write_Run for Rate['||g_rate_name||
                                                        'Error-msg['||x_error_msg_code;
				pa_debug.write_file('LOG',substr(pa_debug.g_err_stage,1,250));
				RAISE process_error;
			END IF;

			COMMIT;

			IF g_debug_mode = 'Y' THEN
				pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:') ||
					' Run ID ['||TO_CHAR(ln_run_id)||']');
			END IF;


			----------------------------
			-- Loop through the projects
			----------------------------
			FOR r_project IN cur_projects LOOP

			IF R_RATE.INTEREST_SCH_ID = R_PROJECT.INTEREST_SCH_ID THEN		/* Added for Bug 6757697 */

				IF g_debug_mode = 'Y' THEN
					pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:') ||
						' Project Number ['||r_project.project_num||']' ||
						' ID ['||TO_CHAR(r_project.project_id)||']');
				END IF;


				-- Acquire a lock on the project info
				IF pa_debug.acquire_user_lock('PA_CAP_INT_'||to_char(r_project.project_id))<>0 THEN
					IF g_debug_mode = 'Y' THEN
						pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:') ||
						' Could not lock the project '||r_project.project_num);
					END IF;

					lv_bypass_project := 'Y';
					pa_debug.g_err_stage := 'Lock for Project '||r_project.project_num;
					lv_exception_code := c_proj_lock;
					lv_exception_type := 'E';
				END IF;

				-- Initialize project process variables
				g_project_id := r_project.project_id;
				ln_proj_owning_org_id := r_project.owning_org_id;
				lv_cip_cost_type := r_project.cip_cost_type;
				lv_burden_method := r_project.burden_method;
				lv_tot_burden_flag := r_project.tot_burden_flag;

				ln_proj_duration_threshold := r_rate.proj_duration_threshold;
				ln_proj_amt_threshold := r_rate.proj_amt_threshold;

				ln_proj_processed := ln_proj_processed + 1;
				lv_bypass_project := 'N';
				ln_proj_trans_count := 0;
				ln_proj_error_count := 0;
				ln_proj_warning_count := 0;
				ln_proj_detail_count := 0;

				lv_first_exp_flag := 'Y';
				ln_curr_task_id := -99;


				-- Check whether the project exists in current batches
				IF lv_bypass_project = 'N' AND x_return_status = 'S' THEN
					IF g_debug_mode = 'Y' THEN
                                            pa_debug.write_file('LOG','Check Project batch exists for the period');
                                        END IF;
					check_project_batches
						(g_project_id
						,g_cap_int_rule_id
						,ln_fiscal_year
						,ln_quarter_num
						,ln_period_num
						,g_rate_name
						,lv_bypass_project
						,x_return_status
						,x_error_msg_count
						,x_error_msg_code);

					pa_debug.g_err_stage := 'Check_Project_Batches for Project '||
								r_project.project_num;
                                        IF g_debug_mode = 'Y' THEN
                                            pa_debug.write_file('LOG','lv_bypass_project['||lv_bypass_project||
								']x_return_status['||x_return_status||
								']x-errmsg['||x_error_msg_code||']' );
                                        END IF;

					IF x_return_status = 'U' THEN
						RAISE process_error;
					END IF;

					IF lv_bypass_project = 'Y' THEN
						lv_exception_code := c_proj_batches;
						lv_exception_type := 'W';
					END IF;
				END IF;


				-- Check whether the project has a compiled Cap Interest schedule for the exp item date
				IF lv_bypass_project = 'N' AND x_return_status = 'S' THEN
                                        IF g_debug_mode = 'Y' THEN
                                            pa_debug.write_file('LOG','Check Project Schedule exists for the period');
                                        END IF;
					check_project_schedule
						(r_project.interest_sch_id
						,g_period_end_date
						,ln_sched_version_id
						,lv_bypass_project
						,x_return_status
						,x_error_msg_count
						,x_error_msg_code);

					pa_debug.g_err_stage := 'Check_Project_Schedule for Project '||
								r_project.project_num;

                                        IF g_debug_mode = 'Y' THEN
                                            pa_debug.write_file('LOG','lv_bypass_project['||lv_bypass_project||
                                                                ']x_return_status['||x_return_status||
								']x-errmsg['||x_error_msg_code||']' );
                                        END IF;

					IF x_return_status = 'U' THEN
						RAISE process_error;
					END IF;

					IF lv_bypass_project = 'Y' THEN
						lv_exception_code := c_proj_sched;
						lv_exception_type := 'W';
					END IF;
				END IF;

				/* Bug fix: 3227816 Starts here */
				--Check if the rate name is used for this schedule
                                IF lv_bypass_project = 'N' AND x_return_status = 'S' THEN
                                        IF g_debug_mode = 'Y' THEN
                                            pa_debug.write_file('LOG','Check Schedule has Ratename ');
                                        END IF;
                                        check_schedule_has_ratename
                                                (p_sch_id      		=> r_project.interest_sch_id
                                                ,p_sch_rev_date    	=> g_period_end_date
                                                ,p_sch_rev_id  		=> ln_sched_version_id
                                                ,p_rate_name  		=> r_rate.rate_name
                                                ,x_bypass_project 	=> lv_bypass_project
                                                ,x_return_status 	=> x_return_status
                                                ,x_error_msg_count 	=> x_error_msg_count
                                                ,x_error_msg_code 	=> x_error_msg_code );

                                        IF g_debug_mode = 'Y' THEN
                                            pa_debug.write_file('LOG','lv_bypass_project['||lv_bypass_project||
                                                                ']x_return_status['||x_return_status||
                                                                ']x-errmsg['||x_error_msg_code||']' );
                                        END IF;

                                        IF x_return_status = 'U' THEN
                                                RAISE process_error;
                                        END IF;

                                        IF lv_bypass_project = 'Y' THEN
                                                lv_exception_code := c_proj_sch_no_rate;
                                                lv_exception_type := 'W';
                                        END IF;
                                END IF;
				/* Bug fix: 3227816 Ends here */


				-- Check whether the project has met the threshold values
				IF lv_bypass_project = 'N' AND x_return_status = 'S' Then
                                        IF g_debug_mode = 'Y' THEN
                                            pa_debug.write_file('LOG','Check Project Thresholds');
                                        END IF;

				       /* Bug fix:2972865  Set the Budget entry level code */
					g_bdgt_entry_level_code := Get_Bdgt_entry_level_code
						(p_project_id => g_project_id
						,p_threshold_amt_type => lv_threshold_amt_type
						,p_budget_type_code => r_rate.budget_type
						,p_fin_plan_type_id =>r_rate.fin_plan_type_id
						);

					check_thresholds
						(g_project_id
						,NULL
						,g_rate_name
						,r_project.start_date
						,g_period_end_date
						,lv_threshold_amt_type
						,r_rate.budget_type
						,r_rate.fin_plan_type_id
						,lv_interest_calc_method
						,lv_cip_cost_type
						,ln_proj_duration_threshold
						,ln_proj_amt_threshold
						,lv_bypass_project
						,x_return_status
						,x_error_msg_count
						,x_error_msg_code);

					pa_debug.g_err_stage := 'Check_Thresholds for Project '||r_project.project_num;
                                        IF g_debug_mode = 'Y' THEN
                                            pa_debug.write_file('LOG','lv_bypass_project['||lv_bypass_project||
                                                                ']x_return_status['||x_return_status||
								']x-errmsg['||x_error_msg_code||']');
                                        END IF;
					IF x_return_status = 'U' THEN
						RAISE process_error;
					END IF;

					IF lv_bypass_project = 'Y' THEN
						lv_exception_code := c_proj_threshold;
						lv_exception_type := 'W';
					END IF;
				END IF;



				---------------------------------------------
				-- Process the task/cdl rows for the project
				---------------------------------------------
				IF lv_bypass_project = 'N' THEN

				    -- Initialize the task/cdl plsql tables
				    lt_alloc_txn_id.DELETE;
				    lt_task_id.DELETE;
				    lt_task_num.DELETE;
				    lt_task_owning_org_id.DELETE;
				    lt_task_start_date.DELETE;
				    lt_task_end_date.DELETE;
				    lt_exp_org_id.DELETE;
				    lt_rate_mult.DELETE;
				    lt_grouping_method.DELETE;
				    lt_cdl_status.DELETE;
				    lt_prior_period_amt.DELETE;
				    lt_curr_period_amt.DELETE;
				    lt_target_task_id.DELETE;
				    lt_cap_int_amt.DELETE;
				    lt_attribute_category.DELETE;
				    lt_attribute1.DELETE;
				    lt_attribute2.DELETE;
				    lt_attribute3.DELETE;
				    lt_attribute4.DELETE;
				    lt_attribute5.DELETE;
				    lt_attribute6.DELETE;
				    lt_attribute7.DELETE;
				    lt_attribute8.DELETE;
				    lt_attribute9.DELETE;
				    lt_attribute10.DELETE;
				    lt_process_task_flag.DELETE;


				    IF g_debug_mode = 'Y' THEN
					pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:') ||
						' Load the CDL cursor rows');
				    END IF;


				    -- Retrieve the task/cdl rows for the current project
				    OPEN cur_cdls;
				    FETCH cur_cdls BULK COLLECT INTO
					lt_task_id
					,lt_task_num
					,lt_task_owning_org_id
					,lt_task_start_date
					,lt_task_end_date
					,lt_exp_org_id
					,lt_rate_mult
					,lt_grouping_method
					,lt_cdl_status
					,lt_prior_period_amt
					,lt_curr_period_amt
					,lt_process_task_flag
                                        --Bug fix:3051022 Added these columns to initialize collection tables
                                        ,lt_alloc_txn_id
				        ,lt_target_task_id
				        ,lt_cap_int_amt
				        ,lt_attribute_category
				        ,lt_attribute1
				        ,lt_attribute2
				        ,lt_attribute3
				        ,lt_attribute4
			                ,lt_attribute5
				        ,lt_attribute6
				        ,lt_attribute7
				        ,lt_attribute8
				        ,lt_attribute9
				        ,lt_attribute10;
				    CLOSE cur_cdls;

				    IF g_debug_mode = 'Y' THEN
					pa_debug.write_file('LOG', 'After Load the CDL cursor Number of rows['||
					                 lt_process_task_flag.count||']');
				    END IF;


				    -- If no rows are retrieved, set the project bypass variable and exception
				    IF lt_task_id.COUNT = 0 THEN

					lv_bypass_project := 'Y';
					lv_exception_code := c_proj_no_txns;
					lv_exception_type := 'W';
					pa_debug.g_err_stage := 'No CDLs for Project '||r_project.project_num;


				    -- Otherwise, process the cdl rows for this project
				    ELSE

					-----------------------------------
					-- Perform project threshold checks
					-----------------------------------
					IF NVL(ln_proj_amt_threshold,0) > 0 AND
					   lv_threshold_amt_type IN ('TOTAL_CIP','OPEN_CIP') THEN

					    -- Intialize the project totals
					    ln_proj_tot_amt := 0;
					    ln_proj_open_amt := 0;

					    -- Loop through every row and accumulate the amounts
					    FOR i IN lt_task_id.FIRST..lt_task_id.LAST LOOP
						ln_proj_tot_amt := ln_proj_tot_amt
							     + lt_prior_period_amt(i)
							     + lt_curr_period_amt(i);

						IF lt_cdl_status(i) = 'OPEN' THEN
						    ln_proj_open_amt := ln_proj_open_amt
								+ lt_prior_period_amt(i)
								+ lt_curr_period_amt(i);
						END IF;
					    END LOOP;


					    -- Check the project threshold
					    IF (lv_threshold_amt_type = 'TOTAL_CIP' AND
						ln_proj_tot_amt < ln_proj_amt_threshold)
						OR
					       (lv_threshold_amt_type = 'OPEN_CIP' AND
						ln_proj_open_amt < ln_proj_amt_threshold) THEN

						lv_bypass_project := 'Y';
						lv_exception_code := c_proj_threshold;
						lv_exception_type := 'W';

						pa_debug.g_err_stage := 'Check CIP Thresholds for Project '||
								r_project.project_num;
					    END IF;
					END IF;


					-- If the project threshold is passed, loop through all rows again
					-- to perform task checks and create transactions accordingly
					IF lv_bypass_project = 'N' THEN

					    -- Loop through every row and accumulate the amounts
					    FOR i IN lt_task_id.FIRST..lt_task_id.LAST LOOP

                                                IF g_debug_mode = 'Y' THEN
					           pa_debug.write_file('LOG','Loop index['||i||']lv_first_exp_flag['||
					             lv_first_exp_flag||']lt_task_id['||
						     lt_task_id(i)||']lv_bypass_task['||lv_bypass_task||']ln_curr_task_id['||
						     ln_curr_task_id||']ln_task_tot_amt['||ln_task_tot_amt||
						    ']lv_threshold_amt_type['||lv_threshold_amt_type||']' );
 				                End If;


						-------------------------------
						-- Perform one-time task checks
						-------------------------------
						IF lv_first_exp_flag = 'Y' OR
						   ln_curr_task_id <> lt_task_id(i) THEN

						    -- Check CIP thresholds on prior task if appropriate
						    IF (lv_first_exp_flag = 'N' AND lv_bypass_task = 'N')
						         AND
						       ((lv_threshold_amt_type = 'TOTAL_CIP' AND
						         ln_task_tot_amt < NVL(ln_task_amt_threshold,0))
							OR
						        (lv_threshold_amt_type = 'OPEN_CIP' AND
						         ln_task_open_amt < NVL(ln_task_amt_threshold,0))) THEN

							FOR j IN ln_task_start..ln_task_last LOOP
							    lt_process_task_flag(j) := 'N';

							    ln_proj_trans_count := ln_proj_trans_count - 1;
							    ln_rate_trans_amt := ln_rate_trans_amt
									- lt_prior_period_amt(j)
									- lt_curr_period_amt(j);
							END LOOP;

							-- Write the exception for the task if appropriate
							write_exception
								(c_task_threshold
								,ln_curr_task_id
								,g_project_id
								,g_cap_int_rule_id
								,ln_run_id
								,'W'
								,x_return_status
								,x_error_msg_count
								,x_error_msg_code);

							IF g_debug_mode = 'Y' THEN
								pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:')
								   ||' Task '||lv_curr_task_num
								   ||' bypassed by Actual Task Threshold');
							END IF;

							IF x_return_status = 'U' THEN
							    pa_debug.g_err_stage := 'Write_Exception for Task '
							      ||lv_curr_task_num||' in Project '
							      ||r_project.project_num||
								']x-errmsg['||x_error_msg_code||']';
							    RAISE process_error;
							END IF;

							ln_proj_warning_count := ln_proj_warning_count + 1;
						    END IF;


						    IF g_debug_mode = 'Y' THEN
							pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:') ||
								' Task Number ['||lt_task_num(i)||']' ||
								' ID ['||TO_CHAR(lt_task_id(i))||']');
						    END IF;


						    -- Initialize task variables
						    lv_first_exp_flag := 'N';
						    ln_task_tot_amt := 0;
						    ln_task_open_amt := 0;
						    ln_task_start := i;
						    ln_curr_task_id := lt_task_id(i);
						    lv_curr_task_num := lt_task_num(i);
						    lv_bypass_task := 'N';

						    ln_task_duration_threshold := r_rate.task_duration_threshold;
						    ln_task_amt_threshold := r_rate.task_amt_threshold;


						    -- Check whether the task has met the duration and
						    -- budget threshold values
						    IF lv_bypass_task = 'N' AND x_return_status = 'S' THEN
							IF g_debug_mode = 'Y' THEN
							   pa_debug.write_file('LOG','Check Task Thresholds');
							End If;
							check_thresholds
								(g_project_id
								,ln_curr_task_id
								,g_rate_name
								,lt_task_start_date(i)
								,g_period_end_date
								,lv_threshold_amt_type
								,r_rate.budget_type
						                ,r_rate.fin_plan_type_id
								,lv_interest_calc_method
								,lv_cip_cost_type
								,ln_task_duration_threshold
								,ln_task_amt_threshold
								,lv_bypass_task
								,x_return_status
								,x_error_msg_count
								,x_error_msg_code);

							pa_debug.g_err_stage := 'Check_Thresholds for Task '
							||lv_curr_task_num||' in Project '||r_project.project_num;
                                                      IF g_debug_mode = 'Y' THEN
                                                         pa_debug.write_file('LOG','lv_bypass_task['
								||lv_bypass_task||']x_return_status['
								||x_return_status||
								']x-errmsg['||x_error_msg_code||']');
                                                      END IF;

							IF x_return_status = 'U' THEN
								RAISE process_error;
							END IF;

							IF lv_bypass_task = 'Y' THEN
								ln_except_task_id := ln_curr_task_id;
								lv_exception_code := c_task_threshold;
								lv_exception_type := 'W';
							END IF;
						    END IF;


						    -- Get the target task
						    IF lv_bypass_task = 'N' AND x_return_status = 'S' THEN
							IF g_debug_mode = 'Y' THEN
								pa_debug.write_file('LOG','get target Task');
							End If;
							pa_client_extn_cap_int.get_target_task
								(ln_curr_task_id
								,lv_curr_task_num
								,g_rate_name
								,ln_target_task_id
								,lv_target_task_num
								,x_return_status
								,x_error_msg_count
								,x_error_msg_code);

							pa_debug.g_err_stage := 'Get_Target_Task for Task '
							||lv_curr_task_num||' in Project '||r_project.project_num
							||']x-errmsg['||x_error_msg_code||']';

							IF x_return_status = 'U' THEN
								RAISE process_error;
							END IF;

							IF ln_target_task_id IS NULL THEN
								ln_except_task_id := ln_curr_task_id;
								lv_exception_code := c_task_null_target;
								lv_exception_type := 'E';
								lv_bypass_task := 'Y';
							END IF;
						    END IF;


						    -- Revalidate the target task
						    IF lv_bypass_task = 'N' AND x_return_status = 'S' THEN
							IF g_debug_mode = 'Y' THEN
								pa_debug.write_file('LOG','Validate Target Task');
							End If;
							validate_task
								(g_project_id
								,ln_target_task_id
								,g_exp_item_date
								,g_period_end_date
								,lv_bypass_task
								,x_return_status
								,x_error_msg_count
								,x_error_msg_code);

							pa_debug.g_err_stage := 'Validate_Target_Task for Task '
							||lv_target_task_num||' in Project '||r_project.project_num;

                                                        IF g_debug_mode = 'Y' THEN
                                                          pa_debug.write_file('LOG','lv_bypass_task['
                                                                ||lv_bypass_task||']x_return_status['
                                                                ||x_return_status||
								']x-errmsg['||x_error_msg_code||']');
                                                        END IF;

							IF x_return_status = 'U' THEN
								RAISE process_error;
							END IF;

							IF lv_bypass_task = 'Y' THEN
								ln_except_task_id := ln_target_task_id;
								lv_exception_code := c_task_not_valid;
								lv_exception_type := 'E';
							END IF;
						    END IF;


						    -- Get the rate multiplier if source specified is task owning org
						    IF lv_bypass_task = 'N' AND x_return_status = 'S' THEN
					               IF g_debug_mode = 'Y' THEN
							pa_debug.write_file('LOG','Calling get_rate_multiplier');
						       End If;
							get_rate_multiplier
								(g_rate_name
								,ln_sched_version_id
								,lt_task_owning_org_id(i)
								,ln_proj_owning_org_id
								,ln_rate_mult
								,x_return_status
								,x_error_msg_count
								,x_error_msg_code);

							pa_debug.g_err_stage := 'Get_Rate_Multiplier for Rate '
								||g_rate_name||' and Task '||lv_curr_task_num
								||' in Project['||r_project.project_num
								||']x-errmsg['||x_error_msg_code||']';

							IF x_return_status = 'U' THEN
								RAISE process_error;
							END IF;

							IF ln_rate_mult IS NULL THEN
								ln_except_task_id := ln_curr_task_id;
								lv_exception_code := c_rate_mult;
								lv_exception_type := 'E';
								lv_bypass_task := 'Y';
							END IF;
						    END IF;



						    IF lv_bypass_task = 'Y' THEN

							IF g_debug_mode = 'Y' THEN
								pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:') ||
								' Task bypassed by '||pa_debug.g_err_stage);
							END IF;

							-- Write the exception for the task if appropriate
							write_exception
								(lv_exception_code
								,ln_except_task_id
								,g_project_id
								,g_cap_int_rule_id
								,ln_run_id
								,lv_exception_type
								,x_return_status
								,x_error_msg_count
								,x_error_msg_code);

							IF x_return_status = 'U' THEN
							    pa_debug.g_err_stage := 'Write_Exception for Task '
								||lv_curr_task_num||' in Project['
								||r_project.project_num
								||']x-errmsg['||x_error_msg_code||']';
							    RAISE process_error;
							END IF;

							IF lv_exception_type = 'E' THEN
								ln_proj_error_count := ln_proj_error_count + 1;
							ELSE
								ln_proj_warning_count := ln_proj_warning_count + 1;
							END IF;
						    END IF;

						END IF;


						---------------------------------
						-- Perform transaction processing
						---------------------------------

						-- Update the accumulators for task-level threshold testing
						ln_task_tot_amt := ln_task_tot_amt
							     + lt_prior_period_amt(i)
							     + lt_curr_period_amt(i);

						IF lt_cdl_status(i) = 'OPEN' THEN
							ln_task_open_amt := ln_task_open_amt
									+ lt_prior_period_amt(i)
									+ lt_curr_period_amt(i);
						END IF;



						-- If the task should be bypassed, mark all of the cdl rows accordingly
						IF lv_bypass_task = 'Y' THEN
						    lt_process_task_flag(i) := 'N';


						-- If the CIP costs are closed, mark the row to be excluded from interest
						ELSIF lt_cdl_status(i) = 'CLOSED' THEN
						    lt_process_task_flag(i) := 'N';


						-- Otherwise, continue checking the transaction
						ELSE
						    -- Set the rate from the proj/task if not set by the client extension
						    IF lt_rate_mult(i) IS NULL THEN
							lt_rate_mult(i) := ln_rate_mult;
						    END IF;


						    -- If the rate is not zero, continue the calculation
						    IF lt_rate_mult(i) = 0 THEN
							lt_process_task_flag(i) := 'N';

						    ELSE
							-- Calculate cap interest using the standard algorithm
							ln_cap_int_amt :=
								ROUND((lt_rate_mult(i) * ln_period_mult)
									* (lt_prior_period_amt(i)
									+ (lt_curr_period_amt(i) * ln_curr_period_mult))
							     	,2);

							-- Perform a custom calculation if desired
						      IF g_debug_mode = 'Y' THEN
							pa_debug.write_file('LOG','Calling Client Extn calculate_capInt');
						      End if;
							pa_client_extn_cap_int.calculate_cap_interest
								(g_gl_period
								,g_rate_name
								,ln_curr_period_mult
								,ln_period_mult
								,g_project_id
								,ln_curr_task_id
								,ln_target_task_id
								,lt_exp_org_id(i)
								,g_exp_item_date
								,lt_prior_period_amt(i)
								,lt_curr_period_amt(i)
								,lt_grouping_method(i)
								,lt_rate_mult(i)
								,ln_cap_int_amt
								,x_return_status
								,x_error_msg_count
								,x_error_msg_code);

							-- Check the results of the custom calculation
							IF x_return_status = 'U' THEN
							pa_debug.g_err_stage := 'Calculate_Cap_Interest client extension x-errmsg['||x_error_msg_code||']';
								RAISE process_error;
							END IF;


							-- Save the results of the calculation
							IF NVL(ln_cap_int_amt,0) = 0 THEN
							    lt_process_task_flag(i) := 'N';

							ELSE

							    -- Call the client extension to retrieve attribute values
							    pa_client_extn_cap_int.get_txn_attributes
								(g_project_id
								,ln_curr_task_id
								,ln_target_task_id
								,g_rate_name
								,lt_grouping_method(i)
								,lt_attribute_category(i)
								,lt_attribute1(i)
								,lt_attribute2(i)
								,lt_attribute3(i)
								,lt_attribute4(i)
								,lt_attribute5(i)
								,lt_attribute6(i)
								,lt_attribute7(i)
								,lt_attribute8(i)
								,lt_attribute9(i)
								,lt_attribute10(i)
								,x_return_status
								,x_error_msg_count
								,x_error_msg_code);


							    -- Check the results of the attribute retrieval
							    IF x_return_status = 'U' THEN
						                pa_debug.g_err_stage :=
							          'Get_Txn_Attributes client extension'||
								']x-errmsg['||x_error_msg_code||']';
								RAISE process_error;
							    END IF;


							    -- Store the cap interest information
							    lt_cap_int_amt(i) := ln_cap_int_amt;
							    lt_target_task_id(i) := ln_target_task_id;

							    BEGIN
								SELECT	pa_alloc_txn_details_s.nextval
								INTO	lt_alloc_txn_id(i)
								FROM	DUAL;
							    EXCEPTION
								WHEN OTHERS THEN
									x_return_status := 'U';
									x_error_msg_count := 1;
									x_error_msg_code := SQLERRM;
									pa_debug.g_err_stage := 'Get Alloc Txn ID'||
									']x-errmsg['||x_error_msg_code||']';
									RAISE process_error;
							    END;


							    -- Update accumulators
							    ln_rate_trans_amt := ln_rate_trans_amt + lt_cap_int_amt(i);
							    ln_proj_trans_count := ln_proj_trans_count + 1;
							END IF;
						    END IF;
						END IF;

						ln_task_last := i;
					    END LOOP;


					    -----------------------------------------
					    -- Perform threshold checks for last task
					    -----------------------------------------
					    -- Check CIP thresholds on prior task if appropriate
					    IF (lv_first_exp_flag = 'N' AND lv_bypass_task = 'N')
					         AND
					       ((lv_threshold_amt_type = 'TOTAL_CIP' AND
					         ln_task_tot_amt < NVL(ln_task_amt_threshold,0))
						OR
					        (lv_threshold_amt_type = 'OPEN_CIP' AND
					         ln_task_open_amt < NVL(ln_task_amt_threshold,0))) THEN

						FOR j IN ln_task_start..ln_task_last LOOP
						    lt_process_task_flag(j) := 'N';

						    ln_proj_trans_count := ln_proj_trans_count - 1;
						    ln_rate_trans_amt := ln_rate_trans_amt
									- lt_prior_period_amt(j)
									- lt_curr_period_amt(j);
						END LOOP;

						IF g_debug_mode = 'Y' THEN
							pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:')
							   ||' Task '||lv_curr_task_num
							   ||' bypassed by Actual Task Threshold');
						END IF;

						-- Write the exception for the task if appropriate
						write_exception
							(c_task_threshold
							,ln_curr_task_id
							,g_project_id
							,g_cap_int_rule_id
							,ln_run_id
							,'W'
							,x_return_status
							,x_error_msg_count
							,x_error_msg_code);

						IF x_return_status = 'U' THEN
						    pa_debug.g_err_stage := 'Write_Exception for Task '
							  ||lv_curr_task_num||' in Project '||r_project.project_num||
							  ']x-errmsg['||x_error_msg_code||']';
						    RAISE process_error;
						END IF;

						ln_proj_warning_count := ln_proj_warning_count + 1;
					    END IF;


					    -- Reset trans to create to zero if an errors encountered in order
					    -- to prevent any transactions from being created for the project
					    IF ln_proj_error_count > 0 THEN
						ln_proj_trans_count := 0;
					    END IF;


					    ---------------------------------------------------------------------------
					    -- Bulk load the appropriate interest transactions from the current project
					    ---------------------------------------------------------------------------
					    IF ln_proj_trans_count > 0 THEN
					      IF g_debug_mode = 'Y' THEN
						pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:') ||
							' Create the Interest Transactions');
					      END IF;

					      BEGIN
						IF g_debug_mode = 'Y' THEN
							pa_debug.write_file('LOG','Insert pa_alloc_txn_details');
					                pa_debug.write_file('LOG','Task_count'||lt_task_id.count||
					                     ']alloctxnid_count ['||lt_alloc_txn_id.count||
						             ']target_task_count['||lt_target_task_id.count||
                                                             ']capintamtcount['   ||lt_cap_int_amt.count||
                                                             ']lt taskid count['  ||lt_task_id.count||
                                                             ']orgidcount['       ||lt_exp_org_id.count||
                                                             ']rate mult count['  ||lt_rate_mult.count||
                                                             ']period amt count[' || lt_curr_period_amt.count||
                                                             ']prior amt count['  ||lt_prior_period_amt.count||
                                                             ']categry count['    ||lt_attribute_category.count||
                                                             ']attribute1['       ||lt_attribute1.count||
                                                             ']attribute2['       ||lt_attribute2.count||
                                                             ']attribute3['       ||lt_attribute3.count||
                                                             ']attribute4['       ||lt_attribute4.count||
                                                             ']attribute5['       ||lt_attribute5.count||
                                                             ']attribute6['       ||lt_attribute6.count||
                                                             ']attribute7['       ||lt_attribute7.count||
                                                             ']attribute8['       ||lt_attribute8.count||
                                                             ']attribute9['       ||lt_attribute9.count||
                                                             ']attribute10['      ||lt_attribute10.count||
                                                             ']proc flag count['  ||lt_process_task_flag.count||
						            ']' );
						End If;
						FORALL k IN lt_task_id.FIRST..lt_task_id.LAST
						    INSERT INTO pa_alloc_txn_details
							(alloc_txn_id
							,run_id
							,rule_id
							,transaction_type
							,fiscal_year
							,quarter_num
							,period_num
							,run_period
							,line_num
							,creation_date
							,created_by
							,last_update_date
							,last_updated_by
							,last_update_login
							,project_id
							,task_id
							,expenditure_type
							,current_allocation
							,status_code
							,cint_source_task_id
							,cint_exp_org_id
							,cint_rate_multiplier
							,cint_current_basis_amt
							,cint_prior_basis_amt
							,attribute_category
							,attribute1
							,attribute2
							,attribute3
							,attribute4
							,attribute5
							,attribute6
							,attribute7
							,attribute8
							,attribute9
							,attribute10
							,ind_rate_sch_revision_id)
						    SELECT
							 lt_alloc_txn_id(k)
							,ln_run_id
							,g_cap_int_rule_id
							,'T'
							,ln_fiscal_year
							,ln_quarter_num
							,ln_period_num
							,g_gl_period
							,-1
							,SYSDATE
							,g_created_by
							,SYSDATE
							,g_last_updated_by
							,g_last_update_login
							,g_project_id
							,lt_target_task_id(k)
							,r_rate.exp_type
							,lt_cap_int_amt(k)
							,'P'
							,lt_task_id(k)
							,lt_exp_org_id(k)
							,lt_rate_mult(k)
							/* Bug fix:3038119 */
							,NVL(lt_curr_period_amt(k),0)* NVL(ln_curr_period_mult,0)
							,lt_prior_period_amt(k)
							,lt_attribute_category(k)
							,lt_attribute1(k)
							,lt_attribute2(k)
							,lt_attribute3(k)
							,lt_attribute4(k)
							,lt_attribute5(k)
							,lt_attribute6(k)
							,lt_attribute7(k)
							,lt_attribute8(k)
							,lt_attribute9(k)
							,lt_attribute10(k)
							,ln_sched_version_id
						    FROM  DUAL
						    WHERE lt_process_task_flag(k) = 'Y';
					      EXCEPTION
						WHEN OTHERS THEN
                                                        x_return_status := 'U';
                                                        x_error_msg_count := 1;
                                                        x_error_msg_code := SQLERRM;
							pa_debug.g_err_stage :=
								'Insert Interest Transactions for Project '
								||r_project.project_num||']x-errMsg['||x_error_msg_code
								||']' ;
							RAISE process_error;
					      END;


					      ------------------------------------------------------
					      -- Bulk load the associated source detail if requested
					      ------------------------------------------------------
					      IF p_source_details = 'Y' THEN
						IF g_debug_mode = 'Y' THEN
							pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:') ||
							' Create the Source Details');
						END IF;

						BEGIN
						    -- Loop through every row and accumulate the amounts
						    FOR k IN lt_task_id.FIRST..lt_task_id.LAST LOOP

							IF lt_process_task_flag(k) = 'Y' THEN

							    INSERT INTO pa_cint_source_details
								(alloc_txn_id
								,run_period_end_date
								,project_id
								,expenditure_item_id
								,line_num
								,prior_amount
								,current_amount
								,fiscal_year
                                                                ,period_num
								,creation_date
								,created_by
								,last_update_date
								,last_updated_by
								,last_update_login)
							    SELECT
								 lt_alloc_txn_id(k)
								,g_period_end_date
								,pctd.project_id
								,pctd.expenditure_item_id
								,pctd.line_num
								,DECODE(SIGN(ld_period_start_date - pctd.gl_date)
									,1, pctd.amount
									  , 0)
								,DECODE(SIGN(ld_period_start_date - pctd.gl_date)
									,1, 0
									  , pctd.amount)
								,ln_fiscal_year
								,ln_period_num
								,SYSDATE
								,g_created_by
								,SYSDATE
								,g_last_updated_by
								,g_last_update_login
							    FROM pa_cint_txn_details_v		pctd
							    WHERE pctd.target_exp_organization_id = lt_exp_org_id(k)
							    AND	NVL(pctd.rate_multiplier, lt_rate_mult(k)) =
								lt_rate_mult(k)
							    AND	NVL(pctd.cint_grouping_method,'@#$') =
								NVL(lt_grouping_method(k),'@#$')
							    AND pctd.task_id = lt_task_id(k)
							    AND	pctd.cint_cdl_status = 'OPEN'
							    AND	pctd.gl_date <= TRUNC(g_period_end_date)
							    AND	TRUNC(g_period_end_date) <=
								TRUNC(NVL(pctd.task_cint_stop_date, g_period_end_date))
							    AND	TRUNC(g_exp_item_date) BETWEEN
								TRUNC(NVL(pctd.task_start_date, g_exp_item_date)) AND
								TRUNC(NVL(pctd.task_completion_date, g_exp_item_date))
							    AND	pctd.project_id = g_project_id
							    AND	pctd.cint_rate_name = g_rate_name;

							    ln_proj_detail_count := ln_proj_detail_count + SQL%ROWCOUNT;
							END IF;
						    END LOOP;
						EXCEPTION
							WHEN OTHERS THEN
                                                                x_return_status := 'U';
                                                                x_error_msg_count := 1;
                                                                x_error_msg_code := SQLERRM;
							pa_debug.g_err_stage :=
							'Insert Source Details for Project'||r_project.project_num||
							']x-errMsg['||x_error_msg_code||']';
								RAISE process_error;
						END;
					      END IF; -- if source details to be written

					    END IF; -- if trans to be written

					END IF;	-- bypass project because of thresholds

				    END IF; -- task/cdl rows found

				END IF;	-- bypass project for various reasons


				IF lv_bypass_project = 'Y' THEN

					-- Write the exception for the project if appropriate
					write_exception
						(lv_exception_code
						,NULL
						,g_project_id
						,g_cap_int_rule_id
						,ln_run_id
						,lv_exception_type
						,x_return_status
						,x_error_msg_count
						,x_error_msg_code);

					IF g_debug_mode = 'Y' THEN
						pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:')
						||' Project bypassed by '||pa_debug.g_err_stage);
					END IF;

					IF x_return_status = 'U' THEN
					    pa_debug.g_err_stage := 'Write_Exception for Project '||r_project.project_num
						||']x-errMsg['||x_error_msg_code||']';
					    RAISE process_error;
					END IF;

					IF lv_exception_type = 'E' THEN
						ln_proj_error_count := ln_proj_error_count + 1;
					ELSE
						ln_proj_warning_count := ln_proj_warning_count + 1;
					END IF;
				END IF;


				ln_proj_written := ln_proj_written + 1;
				ln_trans_written := ln_trans_written + ln_proj_trans_count;
				ln_error_written := ln_error_written + ln_proj_error_count;
				ln_warning_written := ln_warning_written + ln_proj_warning_count;


				IF g_debug_mode = 'Y' THEN
					pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:')
						||' Num of Trans '||TO_CHAR(ln_proj_trans_count));
					pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:')
						||' Num of Details is '||TO_CHAR(ln_proj_detail_count));
					pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:')
						||' Num of Errors '||TO_CHAR(ln_proj_error_count));
					pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:')
						||' Num of Warnings '||TO_CHAR(ln_proj_warning_count));
				END IF;


				-- Release the project lock
				IF pa_debug.release_user_lock('PA_CAP_INT_'||to_char(r_project.project_id)) < 0  THEN
					pa_debug.g_err_stage := 'Lock Release for Project '||r_project.project_num;
					x_return_status := 'U';
					x_error_msg_count := 1;
					x_error_msg_code := NVL(fnd_message.get_string('PA', 'PA_CAP_CANNOT_RELS_LOCK'),
								'PA_CAP_CANNOT_RELS_LOCK');
					RAISE process_error;
				END IF;


				-- Commit all transactions for the project
				COMMIT;

			END IF;  -- Interest Sch ID						/* Added for Bug 6757697 */

			END LOOP; -- project


			-- If no trans or exceptions written, remove the run for the rate
			IF ln_trans_written = 0 AND
			   ln_error_written = 0 AND
			   ln_warning_written = 0 THEN
				remove_run
					(ln_run_id
					,'INPROCESS'
					,x_return_status
					,x_error_msg_count
					,x_error_msg_code);

				IF x_return_status <> 'S' THEN
				    pa_debug.g_err_stage := 'Remove_Run for Rate '||g_rate_name||
					']x-errMsg['||x_error_msg_code||']';
				    RAISE process_error;
				END IF;

				COMMIT;

			-- Otherwise, complete processing the run
			ELSE
				IF ln_error_written > 0 OR ln_warning_written > 0 THEN
					lv_rate_status := 'DF';
				ELSE
					lv_rate_status := 'DS';
				END IF;

				BEGIN
					-- Update the total transaction amount for the run
					UPDATE	pa_alloc_runs_all run
					SET	run.allocated_amount = -- Bug fix:2959030 ln_rate_trans_amt
                                                 (select sum(nvl(txn.current_allocation,0))
						  from pa_alloc_txn_details txn
						  where txn.run_id = run.run_id
                                                 )
						,run.run_status = lv_rate_status
					WHERE	run.run_id = ln_run_id;

					COMMIT;
				EXCEPTION
					WHEN OTHERS THEN
                                                x_return_status := 'U';
                                                x_error_msg_count := 1;
                                                x_error_msg_code := SQLERRM;
						pa_debug.g_err_stage := 'Updating Total Trans Amt for Rate '
							||g_rate_name||']x-errMsg['||x_error_msg_code||']';
						RAISE process_error;
				END;

				-- Auto-release if specified
				IF p_autorelease = 'Y' THEN
				  /* Bug fix:3005559 : The release process should not be called if there
                                   * no successful transactions exists in pa_alloc_txn_details table
                                   */
				  IF release_capint_txns_exists(ln_run_id) = 'Y' THEN
                                      IF g_debug_mode = 'Y' THEN
                                          pa_debug.write_file('LOG','Calling pa_alloc_run.release_capint_txns API');
                                      End If;

				      pa_alloc_run.release_capint_txns
					(ln_run_id
					,x_return_status
					,x_error_msg_count
					,x_error_msg_code);

				      IF x_return_status = 'U' THEN
					  pa_debug.g_err_stage := 'Release_Alloc_Txns for Rate '||g_rate_name||
						']x-errMsg['||x_error_msg_code||']';
					  RAISE process_error;
				      END IF;
				  END IF; -- End of txn_exists
			       END IF; --end of p_autorelease
			END IF; -- end of successful run
		END LOOP; -- rate

		IF g_debug_mode = 'Y' THEN
			pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:') ||' End program');
		END IF;

	    -- Execution section if called from the form button in 'Release' mode
	    ELSE

                /* Bug fix:3005559 : The release process should not be called if there
                 * no successful transactions exists in pa_alloc_txn_details table
                 */
                IF release_capint_txns_exists(x_run_id) = 'Y' THEN
                   IF g_debug_mode = 'Y' THEN
                      pa_debug.write_file('LOG','Calling pa_alloc_run.release_capint_txns API');
                   End If;

		   pa_alloc_run.release_capint_txns
			(x_run_id
			,x_return_status
			,x_error_msg_count
			,x_error_msg_code);

		   IF x_return_status = 'U' THEN
			pa_debug.g_err_stage := 'Release_Alloc_Txns for Run ID '||TO_CHAR(x_run_id)||
				']x-errMsg['||x_error_msg_code||']';
			RAISE process_error;
		   END IF;
                END IF ;  -- end of txns_exists
	    END IF;

	    pa_debug.reset_err_stack;
	EXCEPTION
		WHEN process_error THEN
			pa_debug.write_file('LOG',substr('EXCEPTION:'||pa_debug.g_err_stage||'X-errMsg['||
				x_error_msg_code||']X-retStats['||x_return_status||']'||sqlcode||sqlerrm,1,500));
			ROLLBACK; -- Added here as the releasing dbms lock always causes commit
			IF p_mode = 'G' and ln_run_id is NOT NULL Then
				remove_run
				(ln_run_id
				,'EXCEPTION'
				,x_return_status
				,x_error_msg_count
				,x_error_msg_code);
			End If;
                        IF p_mode = 'G' and g_project_id is not NULL then
                                   v_success_flag :=pa_debug.release_user_lock('PA_CAP_INT_'||to_char(g_project_id));
                        End If;

			pa_debug.reset_err_stack;
			RAISE;
                -- R12 NOCOPY mandate - adding when others for param x_run_id
		WHEN OTHERS THEN
			pa_debug.write_file('LOG',substr('EXCEPTION:' || sqlcode
                                                         ||sqlerrm,1,500));
			ROLLBACK; -- Added here as the releasing dbms lock always causes commit
                        x_return_status := 'U';
                        x_error_msg_count := x_error_msg_count + 1;
                        x_error_msg_code := sqlerrm;
                        -- Copy back the value that was passed in.
                        x_run_id := l_init_run_id;
	END;



	/* ----------------------------------------------------
	   Purge Source Details through the parameter GL period
	   ---------------------------------------------------- */
	PROCEDURE purge_source_detail
		(p_gl_period IN VARCHAR2
		,p_from_project_num IN VARCHAR2 DEFAULT NULL
		,p_to_project_num IN VARCHAR2 DEFAULT NULL
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2)
	IS

		-- Process control variables

		c_max_del_rows			NUMBER := 10000;	-- maximum rows to delete per statement
		process_error			EXCEPTION;


		-- Working storage variables

		ld_period_start_date		gl_period_statuses.start_date%TYPE;
		ld_period_end_date		gl_period_statuses.end_date%TYPE;
		ln_period_num			gl_period_statuses.period_num%TYPE;
		ln_fiscal_year			gl_period_statuses.period_year%TYPE;
		ln_quarter_num			gl_period_statuses.quarter_num%TYPE;

		ln_rows_deleted			NUMBER;
		ln_tot_rows_deleted		NUMBER;

	BEGIN

		-- Initialize the out variables
		x_return_status := 'S';
		x_error_msg_count := 0;
		x_error_msg_code := NULL;


		-- Initialize the error stack
		pa_debug.init_err_stack ('PA_CAP_INT_PVT.GENERATE_CAP_INTEREST');

		fnd_profile.get('PA_DEBUG_MODE',g_debug_mode);
		g_debug_mode := NVL(g_debug_mode, 'N');

		pa_debug.set_process
			(x_process => 'PLSQL'
			,x_write_file => 'LOG'
			,x_debug_mode => g_debug_mode);


		-- Clear the message stack
		fnd_msg_pub.initialize;


		-- Initialize variables
		ln_tot_rows_deleted := 0;
		g_created_by := NVL(TO_NUMBER(fnd_profile.value('USER_ID')),-1);
		g_last_update_login := NVL(TO_NUMBER(fnd_profile.value('LOGIN_ID')), -1);
		g_last_updated_by := g_created_by;
		g_request_id := fnd_global.conc_request_id;


		IF g_debug_mode = 'Y' THEN
			pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:') ||' Start program');
		END IF;


		-- Get information for the parameter GL period
		get_period_dates
			(p_gl_period
			,ld_period_start_date
			,ld_period_end_date
			,ln_fiscal_year
			,ln_quarter_num
			,ln_period_num
			,x_return_status
			,x_error_msg_count
			,x_error_msg_code);

		IF x_return_status = 'U' THEN
			pa_debug.g_err_stage := 'Get_Period_Dates for Period '||p_gl_period;
			RAISE process_error;
		END IF;


		-- Delete rows in specified increments until no rows remain to be deleted
		LOOP
			BEGIN
				DELETE	FROM pa_cint_source_details   pcsd
				WHERE	pcsd.run_period_end_date <= ld_period_end_date
				AND	EXISTS
					(SELECT	pp.project_id
					 FROM	pa_projects  pp
					 WHERE	pp.segment1 BETWEEN
						NVL(p_from_project_num, pp.segment1) AND
						NVL(p_to_project_num, pp.segment1)
					 AND	pp.project_id = pcsd.project_id)
				AND	rownum <= c_max_del_rows;

				ln_rows_deleted := SQL%ROWCOUNT;

				COMMIT;

				IF g_debug_mode = 'Y' THEN
					pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:')
						||' Rows deleted ['||TO_CHAR(ln_rows_deleted)||']');
				END IF;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					ln_rows_deleted := 0;
				WHEN OTHERS THEN
                                        x_return_status := 'U';
                                        x_error_msg_count := 1;
                                        x_error_msg_code := SQLERRM;
					pa_debug.g_err_stage := 'Delete_Source_Detail x-errMsg['||x_error_msg_code||']';
					RAISE process_error;
			END;


			-- Determine if all rows have been deleted
			IF ln_rows_deleted = 0 THEN
				EXIT;
			ELSE
				ln_tot_rows_deleted := ln_tot_rows_deleted + ln_rows_deleted;
			END IF;
		END LOOP;


		IF g_debug_mode = 'Y' THEN
			pa_debug.write_file('LOG', TO_CHAR(SYSDATE,'HH24:MI:SS:')
				||' Total Rows deleted ['||TO_CHAR(ln_tot_rows_deleted)||']');
		END IF;

		pa_debug.reset_err_stack;
	EXCEPTION
		WHEN process_error THEN
		  pa_debug.write_file('LOG',substr('EXCEPTION IN PURGE_SOURCE_DETAIL:'||x_error_msg_code,1,500));
		  pa_debug.reset_err_stack;
		  RAISE;
	END;


END PA_CAP_INT_PVT;

/
