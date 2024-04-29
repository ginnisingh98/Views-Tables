--------------------------------------------------------
--  DDL for Package Body PA_FUNDS_CONTROL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FUNDS_CONTROL_UTILS" as
-- $Header: PAFCUTLB.pls 120.21.12010000.5 2009/11/27 12:32:17 sgottimu ship $

P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

G_PROJ_ID NUMBER;
G_FC_ENABLED VARCHAR2(1);

-- For R12
   g_input_bvid             pa_budget_versions.budget_version_id%type;
   g_current_baseline_bvid  pa_budget_versions.budget_version_id%type;
   g_api_project_id         pa_budget_versions.project_id%type;
   g_api_task_id            pa_tasks.task_id%type;
   g_api_top_task_id        pa_tasks.top_task_id%type;
   g_api_rlmi               pa_resource_list_members.resource_list_member_id%type;
   g_api_parent_rlmi        pa_resource_list_members.parent_member_id%type;
   g_txn_exists_for_bvid    Varchar2(1);
-- R12 complete


--This Api Initialize the  pa_funds_control_utils package
-- global variables ( this  is used as a one level cache)
PROCEDURE init_util_variables IS

BEGIN
        g_project_id            := null;
        g_bdgt_version_id       := null;
        g_calling_mode          := null;
        g_calling_mode1         := null;
        g_calling_mode2         := null;
        g_calling_mode3         := null;
        g_task_id               := null;
        g_exp_type              := null;
        g_exp_item_date         := null;
        g_exp_org_id            := null;
        g_budget_ccid           := null;
        g_start_date            := null;
        g_end_date              := null;
        g_rlmi                  := null;
        g_period_name           := null;
        g_compiled_set_id       := null;
        g_multiplier            := null;
        g_fnd_reqd_flag         := null;
        g_encum_type_id         := null;
        g_ext_bdgt_link         := null;
	g_sch_rev_id            := null;

END init_util_variables;

PROCEDURE print_message(p_msg in varchar2) IS
BEGIN
    	--dbms_output.put_line('Log: ' || p_msg);
        --r_debug.r_msg('Log: ' || p_msg);
    null;
END print_message;

-- -----------------------------------------------------------------------------+
-- This api provides the compiled set id for the given task, exp item date
-- and for the given organiation this is like a wraper api for the
-- pa_cost_plus.get_compiled_set_id
-- -----------------------------------------------------------------------------+

FUNCTION get_fc_compiled_set_id
        ( p_task_id     IN NUMBER
         ,p_ei_date     IN DATE
        ,p_org_id       IN NUMBER
        ,p_sch_type     IN VARCHAR2 DEFAULT 'C'
        ,p_calling_mode IN VARCHAR2 DEFAULT 'COMPILE_SET_ID'
        ,p_exp_type     IN VARCHAR2  /** added for Burdening changes PAL */
        ) return NUMBER is

        l_compiled_set_id   NUMBER ;
        l_sch_id            NUMBER ;
        l_sch_date          DATE;
        l_stage             NUMBER;
        l_status            NUMBER;
        l_sch_fixed_date    DATE;
        l_rate_sch_rev_id   NUMBER;
	l_base              VARCHAR2(100);
	l_cp_structure      VARCHAR2(100);

BEGIN

	If (g_task_id is NULL or g_task_id <> p_task_id ) OR
	   (g_exp_item_date is NULL or p_ei_date <> g_exp_item_date ) OR
	   (g_exp_org_id is NULL or p_org_id <> g_exp_org_id )OR
           (g_exp_type is NULL or g_exp_type  <> p_exp_type ) THEN

		print_message('sch type = '||p_sch_type);
           If p_sch_type  = 'C' then
                BEGIN
			/* Bug fix: The schedule override at the project or task is not taking
			   this issue is noticed during the DISTVIADJ process at PAL stage
			   this is fixed without logging any bugs.
                        SELECT  t.cost_ind_rate_sch_id,
                                t.cost_ind_sch_fixed_date
                        INTO    l_sch_id ,l_sch_date
                        FROM    pa_tasks t,
                                pa_ind_rate_schedules irs
                        WHERE   t.task_id = p_task_id
                        AND     t.cost_ind_rate_sch_id = irs.ind_rate_sch_id
                        AND     irs.cost_ovr_sch_flag = 'Y';
			*/
			-- Select the Task level schedule override if not found
			-- then select the Project level override
        		SELECT irs.ind_rate_sch_id,
               			t.cost_ind_sch_fixed_date
			INTO   l_sch_id,l_sch_date
        		FROM   pa_tasks t,
               			pa_ind_rate_schedules irs
        		WHERE  t.task_id = p_task_id
        		AND    t.task_id = irs.task_id
        		AND    irs.cost_ovr_sch_flag = 'Y';

                EXCEPTION

                        WHEN NO_DATA_FOUND then
				-- Select the project level sch override
				BEGIN
           				SELECT irs.ind_rate_sch_id,
                  				p.cost_ind_sch_fixed_date
					INTO   l_sch_id,l_sch_date
           				FROM   pa_tasks t,
                  				pa_projects_all p,
                  				pa_ind_rate_schedules irs
           				WHERE  t.task_id = p_task_id
           				AND    t.project_id = p.project_id
           				AND    t.project_id = irs.project_id
           				AND    irs.cost_ovr_sch_flag = 'Y'
           				AND    irs.task_id is null;
				EXCEPTION

				        WHEN NO_DATA_FOUND THEN
					        -- select the schedule at the task
						BEGIN
						    SELECT  t.cost_ind_rate_sch_id,
                                			t.cost_ind_sch_fixed_date
                        			    INTO    l_sch_id ,l_sch_date
                        			    FROM    pa_tasks t,
                                			pa_ind_rate_schedules irs
                        			    WHERE   t.task_id = p_task_id
                        			    AND     t.cost_ind_rate_sch_id = irs.ind_rate_sch_id;
						EXCEPTION

                        				WHEN OTHERS THEN
                                		    		raise;

						END;
				END;

                END;
		print_message('Schid['||l_sch_id||']date['||l_sch_date||']');

                If  l_sch_id is NOT NULL then
			print_message('calling pa_cost_plus.get_revision_by_date');

                        pa_cost_plus.get_revision_by_date
                                (l_sch_id
                                ,l_sch_fixed_date
                                ,p_ei_date
                                ,l_rate_sch_rev_id
                                ,l_status
                                ,l_stage);
			 print_message('sch rev id = '||l_rate_sch_rev_id||' status ='||l_status);



                        If l_rate_sch_rev_id is NOT NULL then

			     /* Added these for PAL changes : Burdening enhancements */
			      pa_cost_plus.get_cost_plus_structure
                        	(rate_sch_rev_id  =>l_rate_sch_rev_id
                         	 ,cp_structure    =>l_cp_structure
                         	 ,status          =>l_status
                         	 ,stage           =>l_stage);

			      pa_cost_plus.get_cost_base
                                (exp_type         => p_exp_type
                         	,cp_structure     => l_cp_structure
                         	,c_base           => l_base
                         	,status           => l_status
                         	,stage            => l_stage);

                              pa_cost_plus.get_compiled_set_id
                                        (l_rate_sch_rev_id,
                                         p_org_id,
					 l_base,
                                         l_compiled_set_id,
                                         l_status,
                                         l_stage);
				print_message('compiled set id = '||l_compiled_set_id||' status ='||l_status);
			Else
				print_message('sch rev id is null so burden cost is zero'||' status ='||l_status);
				null;

                        End if;

                End if;

		-- assign the values to global variables
		g_task_id  := p_task_id;
		g_exp_item_date  := p_ei_date;
		g_exp_org_id  := p_org_id;
		g_exp_type         := p_exp_type ;
		g_compiled_set_id  := l_compiled_set_id;
		g_sch_rev_id       := l_rate_sch_rev_id;

	   End if;  -- sch type

	Else
		print_message('inside compiled set api same condition');
		l_compiled_set_id := g_compiled_set_id;
		l_rate_sch_rev_id := g_sch_rev_id;


        End if;

        If l_compiled_set_id is NULL then
                l_compiled_set_id := 0;
        End if;

        /** Added this to make use of same api to return schedule revision id */
	If p_calling_mode = 'SCH_REV_ID' then
		return l_rate_sch_rev_id;
	Else
		return l_compiled_set_id;
	End if;

END get_fc_compiled_set_id;

-- -----------------------------------------------------------------------------------------+
-- This api provides the compiled multipliers for the given task, exp item date,exp type
-- and for the given organiation this is like a wraper api for the
-- pa_cost_plus.get_compiled_multipliers
-- -----------------------------------------------------------------------------------------+
FUNCTION get_fc_compiled_multiplier
		( p_exp_org_id 	   IN  NUMBER,
		  p_task_id        IN  VARCHAR2,
		  P_exp_item_date  IN  date,
		  p_sch_type       IN varchar2 default 'C',
		  p_exp_type       IN  varchar2
		) return NUMBER is

	l_multiplier  Number := 0;
	l_sch_rev_id  Number := 0;
	l_compile_set_id Number := 0;
BEGIN


        If (g_task_id is NULL or g_task_id <> p_task_id ) OR
           (g_exp_item_date is NULL or P_exp_item_date <> g_exp_item_date ) OR
           (g_exp_org_id is NULL or p_exp_org_id <> g_exp_org_id)  OR
	   (g_exp_type is NULL or g_exp_type  <> p_exp_type ) THEN

	/* bug fix: 2795051 Performance Issues driving the table from
	   pa_compiled_multipliers to pa_ind_rate_sch_revisions is causing FTS
	   on pa_ind_rate_sch_revisions. Refer to the above bug for Explain plan and other details
         */

	l_sch_rev_id := get_fc_compiled_set_id
                        ( p_task_id => p_task_id
                        , p_ei_date => p_exp_item_date
                        , p_org_id  => p_exp_org_id
                        , p_sch_type =>p_sch_type
			, p_calling_mode => 'SCH_REV_ID'
			, p_exp_type   => p_exp_type );

	l_compile_set_id := get_fc_compiled_set_id
                        ( p_task_id => p_task_id
                        , p_ei_date => p_exp_item_date
                        , p_org_id  => p_exp_org_id
                        , p_sch_type =>p_sch_type
			, p_calling_mode => 'COMPILE_SET_ID'
                        , p_exp_type   => p_exp_type );

        --     Bug 3687283 : Modified select statement in get_fc_compiled_multiplier procedure to
        --                   remove join with pa_expensiture_types table as the cost code may not be always mapped
        --                   to a expenditure type.Also removed unnecessary joins as the compiled_set_id and
        --                   ind_sch_rev_id are already derived.

        If l_sch_rev_id is NOT NULL and l_compile_set_id is NOT NULL Then

           SELECT SUM(NVL(cm.compiled_multiplier,0))
             INTO   l_multiplier
             FROM   pa_ind_rate_sch_revisions irsr,
                pa_cost_base_exp_types cbet,
                pa_compiled_multipliers cm
             WHERE irsr.ind_rate_sch_revision_id = l_sch_rev_id
	     AND cbet.cost_plus_structure = irsr.cost_plus_structure
	     AND cbet.cost_base_type =  'INDIRECT COST'
             AND cbet.expenditure_type = p_exp_type
             AND cm.cost_base = cbet.cost_base
             AND cm.ind_compiled_set_id = l_compile_set_id
             AND cm.compiled_multiplier <> 0 ;

        END IF;

	--	SELECT SUM(cm.compiled_multiplier)
	--	INTO   l_multiplier
	--	FROM
	--        	pa_ind_rate_sch_revisions irsr,
	--       		pa_cost_bases cb,
	--        	pa_expenditure_types et,
	--        	pa_ind_cost_codes icc,
	--        	pa_cost_base_exp_types cbet,
	--        	pa_ind_rate_schedules_all_bg irs,
	--        	pa_ind_compiled_sets ics,
	--        	pa_compiled_multipliers cm
	--        WHERE irsr.cost_plus_structure = cbet.cost_plus_structure
	--        AND cb.cost_base = cbet.cost_base
	--        AND cb.cost_base_type = 'INDIRECT COST'  /*cbet.cost_base_type changed the order */
	--        AND et.expenditure_type = icc.expenditure_type
	--        AND icc.ind_cost_code = cm.ind_cost_code
	--        AND cbet.cost_base = cm.cost_base
	--        AND cbet.cost_base_type =  cb.cost_base_type  /* 'INDIRECT COST' changed the order */
	--        AND cbet.expenditure_type = p_exp_type
	--        AND irs.ind_rate_sch_id = irsr.ind_rate_sch_id
	--        AND ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id
	--        AND irsr.ind_rate_sch_revision_id = l_sch_rev_id  /* Bug fix :2795051 to make use of index */
	--        AND ics.organization_id = p_exp_org_id
	--	AND cm.ind_compiled_set_id = ics.ind_compiled_set_id
	--        AND cm.compiled_multiplier <> 0
	--        AND ics.ind_compiled_set_id = l_compile_set_id
	--        AND ics.cost_base = cb.cost_base;  -- added for burdening enhancements
			/* Bug fix 2795051  commented out. assigned to variable
			       get_fc_compiled_set_id
				(  p_task_id
				, p_exp_item_date
				, p_exp_org_id
				, p_sch_type)  ;  */


           g_task_id :=  p_task_id ;
           g_exp_item_date := P_exp_item_date ;
           g_exp_org_id :=  p_exp_org_id ;
           g_exp_type :=  g_exp_type  ;
	   g_multiplier := l_multiplier;

	Else
		--r_msg('inside compiled multiplier api same condition');
		l_multiplier  := g_multiplier;

	End if;


	If NVl(l_multiplier,0) = 0 then
		l_multiplier := 0;
	End if;

	--r_msg('compiled multiplier is = '||l_multiplier);

	Return l_multiplier;

EXCEPTION

	when others then
		--r_msg('error in getting compiled multiplier');
 		Raise;

END get_fc_compiled_multiplier;

-- -------------------------------------------------------------------------------+
-- This Api provides the Burdened cost for the given Expenditure item id and
-- and cdl line number
-- ------------------------------------------------------------------------------+
FUNCTION get_fc_proj_burdn_cost
		(p_exp_item_id 	IN NUMBER
		,p_line_num	IN NUMBER
		)return NUMBER is

	l_burdened_cost 	NUMBER := 0;
BEGIN

	SELECT NVL(cdl.burdened_cost,cdl.amount)
		+ NVL(PROJFUNC_BURDENED_CHANGE,0) /* added for Burdening Enhanceents */
	INTO   l_burdened_cost
	FROM  	pa_cost_distribution_lines_all cdl,
		pa_expenditure_items_all ei,
		pa_transaction_sources pts
	WHERE
		cdl.expenditure_item_id = p_exp_item_id
	AND cdl.line_num = p_line_num
	AND ei.expenditure_item_id       =  cdl.expenditure_item_id
	AND  ei.cost_dist_rejection_code is NULL
	AND  cdl.line_type  ='R'
	AND  ei.system_linkage_function  <> 'BTC'
	AND  NVL(ei.cost_distributed_flag,'N')    = 'Y'
	AND (ei.transaction_source       = pts.transaction_source (+)
	AND nvl(pts.cost_burdened_flag,'N') <> 'Y');

	return l_burdened_cost;


EXCEPTION

	WHEN NO_DATA_FOUND THEN
		RETURN l_burdened_cost;

	WHEN OTHERS THEN
		Raise;
END get_fc_proj_burdn_cost;

-- --------------------------------------------------------------------------------------------+
-- This Api gets the open and closed periods start date, end date, period name and status
-- for the given start date ( Amount type) and end date ( boundary code) and sob
-- the out parameter will be in form of PLSQL  table and also it returns the no of rows in
-- plsql table
-- ---------------------------------------------------------------------------------------------+
PROCEDURE get_gl_periods
                (p_start_date           IN      date
                ,p_end_date             IN      date
                ,p_set_of_books_id      IN      gl_period_statuses.set_of_books_id%type
                ,x_tab_count            IN OUT  NOCOPY Number
                ,x_tab_pds              IN OUT  NOCOPY pa_funds_control_utils.tab_closed_period
                ,x_return_status        IN OUT  NOCOPY varchar2
                ) is


        CURSOR cls_periods is
                SELECT  period_name
                        ,start_date
                        ,end_date
                        ,closing_status
                FROM    gl_period_statuses
                WHERE   application_id = 101
                AND     adjustment_period_flag = 'N'
                AND     set_of_books_id = p_set_of_books_id
                AND     (   (start_date between trunc(p_start_date) and trunc(p_end_date)
                	      AND end_date  between trunc(p_start_date) and trunc(p_end_date)
			    )
			 OR (
				trunc(p_start_date) between start_date and end_date
				or trunc(p_end_date) between start_date and end_date
			    )
			)
                AND     closing_status in ('C','O','P');

        l_count_rows  NUMBER := 0;
        l_tab_count     NUMBER:=0;
	l_tab_rec    pa_funds_control_utils.tab_closed_period;


BEGIN
        -- Initialize the error statck
        PA_DEBUG.init_err_stack('PA_FUNDS_CHECK_UTILS.get_closed_periods');

        -- set the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --Initialize the plsql table to the null values
        x_tab_pds.delete;

        for i in cls_periods LOOP

                l_tab_count := l_tab_count + 1;
                x_tab_pds(l_tab_count).period_name      := i.period_name;
                x_tab_pds(l_tab_count).start_date       := i.start_date;
                x_tab_pds(l_tab_count).end_date         := i.end_date;
                x_tab_pds(l_tab_count).closing_status   := i.closing_status;

        End loop;


        l_count_rows := x_tab_pds.count;
	x_tab_count     := l_count_rows;

	-- the below condition is commented as it is not required
        --If l_count_rows <= 0 then
                --x_return_status := FND_API.G_RET_STS_ERROR;
                --x_tab_count     := 0;
        --Else
                --x_tab_count     := l_count_rows;
        --End if;
        -- reset the error stack
        PA_DEBUG.reset_err_stack;


EXCEPTION
        when others then
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                x_tab_count     := 0;
                RAISE;
END get_gl_periods;

-- -----------------------------------------------------------------------------------+
--This API is a wrapper for the get_budgt_ctrl_options This api provides differenct
--options for the given project_id and calling mode
-- -----------------------------------------------------------------------------------+
FUNCTION  get_fnd_reqd_flag
	(p_project_id	IN 	NUMBER
	,p_calling_mode IN	VARCHAR2 -- STD / CBC
	) return varchar2 IS

	l_fnd_chk_req_flag	varchar2(20) := 'N';
	l_bdgt_version_id	PA_BUDGET_VERSIONS.budget_version_id%TYPE;
	l_encum_type_id		number(15)	:= null;
	l_bdgt_link		VARCHAR2(20)  := 'N';
	l_calling_mode		VARCHAR2(20);
	l_balance_type		VARCHAR2(20);
	l_return_status 	VARCHAR2(20);
	l_msg_data		VARCHAR2(2000);
	l_msg_count		number(15);
BEGIN

	If (g_project_id is NULL or p_project_id <> g_project_id ) OR
	   (g_calling_mode is NULL or p_calling_mode <> g_calling_mode ) THEN

		IF p_calling_mode = 'STD' THEN
			l_calling_mode := 'STANDARD';
		Elsif p_calling_mode = 'CBC' then
			l_calling_mode := 'COMMITMENT';
		End if;

		PA_BUDGET_FUND_PKG.get_budget_ctrl_options
 		( p_project_id           =>p_project_id
   		,p_budget_type_code      => null
   		,p_calling_mode          =>l_calling_mode
		,X_BALANCE_TYPE          =>l_balance_type
   		,x_fck_req_flag          =>l_fnd_chk_req_flag
   		,x_bdgt_intg_flag        =>l_bdgt_link
   		,x_bdgt_ver_id           =>l_bdgt_version_id
   		,x_encum_type_id         =>l_encum_type_id
   		,X_Return_Status         =>l_return_status
   		,X_Msg_Data              =>l_msg_data
   		,X_Msg_Count             =>l_msg_count
		);

		If l_bdgt_link in ('G','C') then
			l_bdgt_link := 'Y';
		Else
			l_bdgt_link := 'N';
		End if;

		If l_encum_type_id is null then
			l_encum_type_id := 0;
		End if;

		g_project_id := p_project_id;
		g_calling_mode := p_calling_mode;
		g_fnd_reqd_flag := l_fnd_chk_req_flag;
	Else
		--r_msg('inside fnd reqd flag api same condition');
		l_fnd_chk_req_flag := g_fnd_reqd_flag;

	End if;
	return Nvl(l_fnd_chk_req_flag,'N');

EXCEPTION
	WHEN OTHERS THEN
		raise;
END get_fnd_reqd_flag;

-- -----------------------------------------------------------------------------------+
--This API is a wrapper for the get_budgt_ctrl_options This api provides differenct
--options for the given project_id and calling mode
-- -----------------------------------------------------------------------------------+
FUNCTION  get_bdgt_version_id
	(p_project_id	IN 	NUMBER
	,p_calling_mode IN	VARCHAR2 -- STD / CBC
	) return PA_BUDGET_VERSIONS.budget_version_id%TYPE IS

        l_fnd_chk_req_flag      varchar2(20) := 'N';
        l_bdgt_version_id       PA_BUDGET_VERSIONS.budget_version_id%TYPE;
        l_encum_type_id         number(15)      := null;
        l_bdgt_link             VARCHAR2(20)  := 'N';
        l_calling_mode          VARCHAR2(20);
        l_balance_type          VARCHAR2(20);
        l_return_status         VARCHAR2(20);
        l_msg_data              VARCHAR2(2000);
        l_msg_count             number(15);
BEGIN

	IF (g_project_id  is NULL or p_project_id  <> g_project_id ) OR
	   (g_calling_mode1 is NULL or p_calling_mode <> g_calling_mode1) THEN
        	IF p_calling_mode = 'STD' THEN
                	l_calling_mode := 'STANDARD';
        	Elsif p_calling_mode = 'CBC' then
                	l_calling_mode := 'COMMITMENT';
        	End if;

        	PA_BUDGET_FUND_PKG.get_budget_ctrl_options
        	( p_project_id           =>p_project_id
        	,p_budget_type_code      => null
        	,p_calling_mode          =>l_calling_mode
        	,X_BALANCE_TYPE          =>l_balance_type
        	,x_fck_req_flag          =>l_fnd_chk_req_flag
        	,x_bdgt_intg_flag        =>l_bdgt_link
        	,x_bdgt_ver_id           =>l_bdgt_version_id
        	,x_encum_type_id         =>l_encum_type_id
        	,X_Return_Status         =>l_return_status
        	,X_Msg_Data              =>l_msg_data
        	,X_Msg_Count             =>l_msg_count
        	);
        	If l_bdgt_link in ('G','C') then
                	l_bdgt_link := 'Y';
        	Else
                	l_bdgt_link := 'N';
        	End if;

        	If l_encum_type_id is null then
                	l_encum_type_id := 0;
        	End if;

		g_project_id  := p_project_id;
		g_calling_mode1 := p_calling_mode;
		g_bdgt_version_id := l_bdgt_version_id;

	Else
		--r_msg('inside get bdgt version api same condition');
		l_bdgt_version_id := g_bdgt_version_id;
	End if;

	return l_bdgt_version_id;

EXCEPTION
	WHEN OTHERS THEN
		raise;
END get_bdgt_version_id;

-- -------------------------------------------------------------------------------------------+
-- R12 Funds management changes --Rshaik
-- IN R12, project encumbrance type is no more user enterable in Project
-- budgetary control window .This is seeded into gl_encumbrance types
-- Hence existing API has been modified to return seeded encumbrance type id
-- for BC enabled projects if encumbrance type in pa_budgetary_control_options is NULL
-- Also for performance reasons instead of calling PA_BUDGET_FUND_PKG.get_budget_ctrl_options
-- have cursor C_BUDGET_CONTROL to fetch required details.
-- -------------------------------------------------------------------------------------------+

FUNCTION  get_encum_type_id
	(p_project_id	              IN NUMBER
	,p_calling_mode               IN VARCHAR2  -- STD / CBC
	) return number IS

CURSOR get_seeded_enc_type_id IS
SELECT encumbrance_type_id
  FROM gl_encumbrance_types
 WHERE encumbrance_type_key = 'Projects';

l_encumbrance_type_id   PA_BUDGETARY_CONTROL_OPTIONS.encumbrance_type_id%TYPE;

BEGIN

 -- Note:
 -- Bug 5618583 : With new upgrade strategy ,all transactions upgraded/unupgraded will use
 -- only R12 seeded encumbrance types.Hence obsoleted logic associated with p_txn_sla_notupgraded_flag.

 IF (g_project_id  is NULL or p_project_id  <> g_project_id ) OR
    (g_calling_mode2 is NULL or p_calling_mode <> g_calling_mode2) THEN

    	   OPEN  get_seeded_enc_type_id;
	   FETCH get_seeded_enc_type_id INTO l_encumbrance_type_id;
	   CLOSE get_seeded_enc_type_id;

           g_project_id := p_project_id;
	   g_calling_mode2 :=  p_calling_mode;
	   g_encum_type_id := l_encumbrance_type_id;

 ELSE
   	   l_encumbrance_type_id := g_encum_type_id;
 END IF;
 RETURN l_encumbrance_type_id;

EXCEPTION
	WHEN OTHERS THEN
		raise;
END get_encum_type_id;

-- -----------------------------------------------------------------------------------+
--This API is a wrapper for the get_budgt_ctrl_options This api provides differenct
--options for the given project_id and calling mode
-- -----------------------------------------------------------------------------------+
FUNCTION  get_bdgt_link
	(p_project_id	IN 	NUMBER
	,p_calling_mode IN	VARCHAR2  -- STD / CBC
	) return varchar2 IS

        l_fnd_chk_req_flag      varchar2(20) := 'N';
        l_bdgt_version_id       PA_BUDGET_VERSIONS.budget_version_id%TYPE;
        l_encum_type_id         number(15)      := null;
        l_bdgt_link             VARCHAR2(20)  := 'N';
        l_calling_mode          VARCHAR2(20);
        l_balance_type          VARCHAR2(20);
        l_return_status         VARCHAR2(20);
        l_msg_data              VARCHAR2(2000);
        l_msg_count             number(15);
BEGIN

	If (g_calling_mode3 is NULL or p_calling_mode <> g_calling_mode3 ) OR
	   (g_project_id  is  NULL or g_project_id <> p_project_id  ) THEN
        	IF p_calling_mode = 'STD' THEN
                	l_calling_mode := 'STANDARD';
        	Elsif p_calling_mode = 'CBC' then
                	l_calling_mode := 'COMMITMENT';
        	End if;
        	PA_BUDGET_FUND_PKG.get_budget_ctrl_options
        	( p_project_id           =>p_project_id
        	,p_budget_type_code      => null
        	,p_calling_mode          =>l_calling_mode
        	,X_BALANCE_TYPE          =>l_balance_type
        	,x_fck_req_flag          =>l_fnd_chk_req_flag
        	,x_bdgt_intg_flag        =>l_bdgt_link
        	,x_bdgt_ver_id           =>l_bdgt_version_id
        	,x_encum_type_id         =>l_encum_type_id
        	,X_Return_Status         =>l_return_status
        	,X_Msg_Data              =>l_msg_data
        	,X_Msg_Count             =>l_msg_count
        	);

        	If l_bdgt_link in ('G','C') then
                	l_bdgt_link := 'Y';
        	Else
                	l_bdgt_link := 'N';
        	End if;

        	If l_encum_type_id is null then
                	l_encum_type_id := 0;
        	End if;
                g_project_id := p_project_id;
                g_calling_mode3 :=  p_calling_mode;
                g_ext_bdgt_link := l_bdgt_link;

        Else

		--r_msg('inside get bdgt link api same condition');
                l_bdgt_link := g_ext_bdgt_link;

        End if;


	return Nvl(l_bdgt_link,'N');

EXCEPTION
	WHEN OTHERS THEN
		raise;
END get_bdgt_link;

-- ---------------------------------------------------------------------+
--The following API returns the Budget CCID for a given project, task,
--resource list member id, budget version id and start date.
-- ---------------------------------------------------------------------+
PROCEDURE Get_Budget_CCID (
                 p_project_id           in number,
                 p_task_id              in number,
                 p_top_task_id          in number,
                 p_res_list_mem_id      in number,
                 p_start_date           in date,
                 p_budget_version_id    in number,
                 p_entry_level_code     in varchar2,
                 x_budget_ccid          out NOCOPY number,
                 x_budget_line_id       out NOCOPY number,
                 x_return_status        out NOCOPY varchar2,
                 x_error_message_code   out NOCOPY varchar2) is
BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF P_DEBUG_MODE = 'Y' THEN
       pa_funds_control_utils.print_message('Get_Budget_CCID: ' || 'Inside Get Budget CCID');
       pa_fck_util.debug_msg('Get_Budget_CCID: ' || 'PB:Inside Get Budget CCID');
       pa_fck_util.debug_msg('Get_Budget_CCID: ' || 'PB:P:T:TT:R:S:B:E = ' || p_project_id || ':' || p_task_id || ':' || p_top_task_id|| ':' || p_res_list_mem_id ||':'|| p_start_date || ':' || p_budget_version_id ||':'|| p_entry_level_code);
    END IF;

    select pbl.code_combination_id, pbl.budget_line_id
      into x_budget_ccid, x_budget_line_id
    from pa_resource_assignments pra,
         pa_budget_lines pbl
    where ((p_entry_level_code = 'P' and
            pra.task_id = 0)
          or
          (p_entry_level_code in ('L','M','T') and
           pra.task_id in (p_task_id,p_top_task_id)))
    and pra.budget_version_id = p_budget_version_id
    and pra.project_id = p_project_id
    and pra.resource_list_member_id = p_res_list_mem_id
    and pra.resource_assignment_id = pbl.resource_assignment_id
    and trunc(pbl.start_date) = trunc(p_start_date);

    IF P_DEBUG_MODE = 'Y' THEN
       pa_funds_control_utils.print_message('Get_Budget_CCID: ' || 'End of Get Budget CCID');
       pa_fck_util.debug_msg('Get_Budget_CCID: ' || 'PB:End of Get Budget CCID = ' || x_budget_ccid||' Line id:'||x_budget_line_id);
    END IF;

EXCEPTION
    when no_data_found then
        x_return_status := fnd_api.g_ret_sts_error;
        x_error_message_code := 'PA_BC_BUDGET_CCID_NULL';
    when others then
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        raise;
END Get_Budget_CCID;

--The following API returns the Time Phased Type Code for a budget_version_id.
PROCEDURE Get_Time_Phased_Type_Code(
              p_budget_version_id       in number,
              x_time_phased_type_code   out NOCOPY varchar2,
              x_return_status           out NOCOPY varchar2,
              x_error_message_code      out NOCOPY varchar2) is
BEGIN
  x_return_status := fnd_api.g_ret_sts_success;

  IF P_DEBUG_MODE = 'Y' THEN
     pa_funds_control_utils.print_message('Get_Time_Phased_Type_Code: ' || 'Inside Get Time Phased Type Code');
     pa_fck_util.debug_msg('Get_Time_Phased_Type_Code: ' || 'PB:Inside Get Time Phased Type Code');
  END IF;

  select time_phased_type_code
    into x_time_phased_type_code
    from pa_budget_entry_methods a,
         pa_budget_versions b
   where a.budget_entry_method_code = b.budget_entry_method_code
     and b.budget_version_id  = p_budget_version_id;

  IF P_DEBUG_MODE = 'Y' THEN
     pa_funds_control_utils.print_message('Get_Time_Phased_Type_Code: ' || 'End of Get Time Phased Type Code');
     pa_fck_util.debug_msg('Get_Time_Phased_Type_Code: ' || 'PB:End of Get Time Phased Type Code');
  END IF;

EXCEPTION
    when no_data_found then
        x_return_status := fnd_api.g_ret_sts_error;
        x_error_message_code := 'PA_BC_TIME_PHASE_CODE_NULL';
    when others then
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        raise;
END Get_Time_Phased_Type_Code;

-- -----------------------------------------------------------------------------------+
--The following API gets the current baselined budget version id for the project id.
-- -----------------------------------------------------------------------------------+
PROCEDURE Get_Baselined_Budget_Version(
            p_calling_mode        in varchar2, -- GL,CC
            p_project_id          in number,
            x_base_version_id     out NOCOPY number,
            x_res_list_id         out NOCOPY number,
            x_entry_level_code    out NOCOPY varchar2,
            x_return_status       out NOCOPY varchar2,
            x_error_message_code  out NOCOPY varchar2) is
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   IF P_DEBUG_MODE = 'Y' THEN
      pa_funds_control_utils.print_message('Inside Get_Baselined_Budget_Version');
      pa_fck_util.debug_msg('PB:Inside Get_Baselined_Budget_Version');
   END IF;

   select pbv.budget_version_id, pbv.resource_list_id, pbm.entry_level_code
   into x_base_version_id,x_res_list_id,x_entry_level_code
   from pa_budget_versions pbv,
        --pa_budget_types pbt,
        pa_budget_entry_methods pbm,
        pa_budgetary_control_options pbco
   where pbv.project_id = p_project_id
   and pbv.current_flag = 'Y'
   and pbv.budget_status_code = 'B'
   and pbv.budget_type_code = pbco.budget_type_code
   and pbv.project_id = pbco.project_id
   and pbco.bdgt_cntrl_flag = 'Y'
   and ((p_calling_mode = 'GL' and pbco.external_budget_code = 'GL')
       or
       (p_calling_mode = 'CC' and pbco.external_budget_code = 'CC')
       or
       (p_calling_mode = 'GL' and pbco.external_budget_code is null))
   --and pbv.budget_type_code = pbt.budget_type_code
   --and pbt.budget_amount_code = 'C'
   and pbv.budget_entry_method_code = pbm.budget_entry_method_code;

   IF P_DEBUG_MODE = 'Y' THEN
      pa_funds_control_utils.print_message('End of Get_Baselined_Budget_Version');
      pa_fck_util.debug_msg('Get_Baselined_Budget_Version: ' || 'PB:Output = '|| x_base_version_id || ':' || x_res_list_id || ':'|| x_entry_level_code);
      pa_fck_util.debug_msg('PB:End of Get_Baselined_Budget_Version');
   END IF;

EXCEPTION
   when no_data_found then
      x_base_version_id := null;
      x_res_list_id := null;
      x_entry_level_code := null;
      --x_return_status := fnd_api.g_ret_sts_error;
      --x_error_message_code := 'PA_BC_BSLND_BDGT_VER_NULL';
   when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      raise;
END Get_Baselined_Budget_Version;

-- --------------------------------------------------------------------------------------------------+
--The following API returns the available balance for the budget_version, budget_CCID and start_date
--from PA_BUDGET_ACCT_LINES
-- --------------------------------------------------------------------------------------------------+
FUNCTION Get_Acct_Line_Balance(
            p_budget_version_id in number,
            p_start_date in date,
            p_end_date in date,
            p_budget_ccid in number) RETURN NUMBER IS
	x_avail_balance number;
BEGIN
        IF P_DEBUG_MODE = 'Y' THEN
           pa_funds_control_utils.print_message('Get_Acct_Line_Balance: ' || 'Inside Get Acct Line Balance');
           pa_fck_util.debug_msg('Get_Acct_Line_Balance: ' || 'PB:Inside Get Acct Line Balance');
        END IF;
	/*
	--select bal.Curr_Ver_Available_Amount
	--into x_avail_balance
	--from pa_budget_acct_lines bal,
	--     gl_period_statuses gps
	--where trunc(gps.start_date) = trunc(p_start_date)
	--and trunc(gps.end_date) = trunc(p_end_date)
	--and gps.period_name = bal.gl_period_name
        --and gps.application_id = 101
	--and bal.budget_version_id = p_budget_version_id
	--and bal.code_combination_id = p_budget_ccid;
	*/

	/**
	 * Bug fix : 1892535 nvl function is added in query
         */

	SELECT 	sum(nvl(bal.Curr_Ver_Available_Amount,0))
	INTO 	x_avail_balance
	FROM 	pa_budget_acct_lines bal
	WHERE 	bal.budget_version_id = p_budget_version_id
	AND   	bal.code_combination_id = p_budget_ccid
	AND   	start_date between trunc(p_start_date) and trunc(p_end_date)
	AND   	end_date between trunc(p_start_date) and trunc(p_end_date);

        IF P_DEBUG_MODE = 'Y' THEN
           pa_funds_control_utils.print_message('Get_Acct_Line_Balance: ' || 'End of Get Acct Line Balance');
           pa_fck_util.debug_msg('Get_Acct_Line_Balance: ' || 'PB:End of Get Acct Line Balance');
        END IF;
	return nvl(x_avail_balance,0);
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	     return 0;
	WHEN OTHERS THEN
	     return 0;
END Get_Acct_Line_Balance;

-- --------------------------------------------------------------------------------------------------+
FUNCTION Is_Budget_Baselined_Before(p_project_id in number) RETURN VARCHAR2 IS
        x_baselined varchar2(1);
        l_count NUMBER;
BEGIN

        IF P_DEBUG_MODE = 'Y' THEN
           pa_funds_control_utils.print_message('Is_Budget_Baselined_Before: ' || 'Inside Is budget baselined before');
           pa_fck_util.debug_msg('Is_Budget_Baselined_Before: ' || 'PB:Inside Is budget baselined before');
        END IF;

        select 1 into l_count
	from pa_budget_versions pbv,
             pa_budget_types pbt
	where pbv.project_id = p_project_id
	and pbv.budget_status_code = 'B'
	and pbv.budget_type_code = pbt.budget_type_code
        and pbt.budget_amount_code = 'C'
        and rownum = 1;

 	if l_count > 0 then
	    x_baselined := 'Y';
	else
	    x_baselined := 'N';
        end if;

        IF P_DEBUG_MODE = 'Y' THEN
           pa_funds_control_utils.print_message('Is_Budget_Baselined_Before: ' || 'After Is budget baselined before = ' || x_baselined);
           pa_fck_util.debug_msg('Is_Budget_Baselined_Before: ' || 'PB:After Is budget baselined before = ' || x_baselined);
        END IF;
        return x_baselined;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        return 'N';
   WHEN OTHERS THEN
        return 'N';
END Is_Budget_Baselined_Before;

-- -----------------------------------------------+
-- Submit sweeper process as a concurrent request
-- -----------------------------------------------+
FUNCTION RunSweeper RETURN NUMBER is
 l_reqid     number;
BEGIN
        l_reqid:= fnd_request.submit_request('PA','PAFCUPAE','','',FALSE);

        return l_reqid;

END RunSweeper;

-- -----------------------------------------------------------------------------------------+
-- #This function has been created in base release 12 for SLA - FC integration project
-- #Function "Is_account_change_allowed" is the API that will be called from
-- #budgets form and from funds check tieback processing. This function will
-- #check if there exists any transaction, against any budget line, whose
-- #account has been modified. It will return 'N' if there exists transaction
-- #against a budget line, else it will return 'Y'.

-- # Code flow is as follows for each of the BEM: Lowest Task/Top Task/Project Level
-- # If API called through Check funds or form
--      Check if txn exists in pa_bc_packets or in pa_bc_commitments_all
--   Elsif API called during Baseline/YearEnd
--      Check if txn exists in pa_bc_balances or pa_bc_packets
-- # For baseline/yearend , we're using bc_balances to increase performance ..
-- -----------------------------------------------------------------------------------------+
FUNCTION Is_account_change_allowed (P_budget_version_id       IN Number,
                                    P_resource_assignment_id  IN Number,
                                    P_period_name             IN Varchar2,
                                    P_budget_entry_level_code IN Varchar2 default null)
return Varchar2
IS
 l_return_status           varchar2(1);
 l_budget_entry_level_code pa_budget_entry_methods.entry_level_code%type;
 l_period_name             pa_budget_lines.period_name%type;
 l_start_date              pa_budget_lines.start_date%type;
 l_rlmi                    pa_resource_assignments.resource_list_member_id%type;
 l_task_id                 pa_resource_assignments.task_id%type;

Begin
l_return_status            := 'N';
 l_budget_entry_level_code := P_budget_entry_level_code;
 l_period_name              := p_period_name;

  IF P_DEBUG_MODE = 'Y' THEN
     pa_fck_util.debug_msg('Is_account_change_allowed: l_budget_entry_level_code['||l_budget_entry_level_code||
                           ']P_budget_version_id['||P_budget_version_id||']P_resource_assignment_id['||
                           P_resource_assignment_id||']P_period_name['||l_period_name||
                           ']pa_budget_fund_pkg.g_processing_mode['||pa_budget_fund_pkg.g_processing_mode||']'
                           );
  END IF;

  -- -----------------------------------------------------------+
  -- Derive the latest baseline version and also
  -- see to it that the query does not execute multiple times..
  -- If its the same, we dont even need to assign ..
  -- -----------------------------------------------------------+
  If nvl(g_input_bvid,-1) <> P_budget_version_id then  -- I

     g_txn_exists_for_bvid   := 'N';
     g_current_baseline_bvid := null;
     g_api_project_id        := null;

     -- -------------------------------------+
     -- # get current baseline version ..
     -- -------------------------------------+
     Begin
      select pbv.budget_version_id,pbv.project_id
      into   g_current_baseline_bvid,g_api_project_id
      from   pa_budget_versions pbv
      where  (pbv.project_id,pbv.budget_type_code) in
          (select project_id,budget_type_code
           from pa_budget_versions
           where budget_version_id = p_budget_version_id)
      and     pbv.budget_status_code = 'B'
      and     pbv.current_flag       = 'Y';
     Exception
     When no_Data_found then
       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('Is_account_change_allowed: No baseline budget exists');
       END IF;

       g_current_baseline_bvid := -2;
       g_api_project_id        := -2;

     End;

     -- -----------------------------------------------------+
     -- # Check if any txn. exists for the baseline version ..
     -- -----------------------------------------------------+
     -- Following code can cause one issue .. If user is
     -- not closing the form and then creating a txn.. in this case
     -- following code will not fire and then user may be able to modify account
     -- If user tries the above workaround, baseline will anyways fail .. :)

     If g_current_baseline_bvid <> -2 then
        Begin
           select 'Y'
           into   g_txn_exists_for_bvid
           from   dual
           where  exists (select 1
                          from   pa_bc_balances pbb
                          where  pbb.budget_version_id = g_current_baseline_bvid
                          and    pbb.project_id        = g_api_project_id
                          and    pbb.balance_type      <> 'BGT');
        Exception
           When no_data_found then

                Begin
                    select 'Y'
                    into   g_txn_exists_for_bvid
                    from   dual
                    where  exists (select 1
                                   from   pa_bc_packets pbb
                                   where  pbb.project_id   = g_api_project_id
                                   and    pbb.status_code  in   ('A','P','I','Z') );
                Exception
                  When no_data_found then
                       null;
                End;
        End;

     Else
       g_txn_exists_for_bvid := 'N';
     End If;

     -- -------------------------------------+
     -- # Initialize  global var. ...
     -- -------------------------------------+
     g_input_bvid := P_budget_version_id;

 End If; -- I

   IF P_DEBUG_MODE = 'Y' THEN
     pa_fck_util.debug_msg('Is_account_change_allowed: g_current_baseline_bvid['
                          ||g_current_baseline_bvid||'] g_api_project_id ['
                          ||g_api_project_id||'] g_txn_exists_for_bvid ['
                          || g_txn_exists_for_bvid ||']');
   END IF;

  -- ------------------------------------------------------------------------------------------+
  -- Return 'Y' if there exists no baseline version ..
  -- This can only happen if this API is called before first time baseline ..
  -- ------------------------------------------------------------------------------------------+
  If nvl(g_txn_exists_for_bvid,'N') = 'N' then
       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('Is_account_change_allowed: No txn. exists - return Y');
       END IF;
     RETURN 'Y';
  End If;

  -- -------------------------------------+
  -- Derive BEM if top and lowest task ..
  -- -------------------------------------+
 If  l_budget_entry_level_code is null then

  select pbem.entry_level_code
  into   l_budget_entry_level_code
  from   pa_budget_entry_methods pbem,
         pa_budget_versions pbv
  where  pbv.budget_version_id         = P_budget_version_id
  and    pbem.budget_entry_method_code = pbv.budget_entry_method_code;


  IF P_DEBUG_MODE = 'Y' THEN
     pa_fck_util.debug_msg('Is_account_change_allowed: l_budget_entry_level_code['||l_budget_entry_level_code);
  END IF;

 End If;

 If l_budget_entry_level_code = 'M' then

    Begin
      Select 'T'
      into   l_budget_entry_level_code
      from   pa_resource_assignments pra,
             pa_tasks pt
      where  pra.resource_assignment_id = P_resource_assignment_id
      and    pra.budget_version_id      = P_budget_version_id
      and    pt.task_id                 = pra.task_id
      and    pt.top_task_id             = pra.task_id;
    Exception
      when no_data_found then
           l_budget_entry_level_code := 'L';
    End;

    IF P_DEBUG_MODE = 'Y' THEN
     pa_fck_util.debug_msg('Is_account_change_allowed: l_budget_entry_level_code(L/T?)['||l_budget_entry_level_code);
    END IF;

 End If; -- If l_budget_entry_level_code = 'M'

   -- Derive values reqd. for "Is_Account_change_allowed2 API"..
    IF P_DEBUG_MODE = 'Y' THEN
     pa_fck_util.debug_msg('Is_account_change_allowed: get task/rlmi from resource assignments');
    END IF;

      select task_id,resource_list_member_id
      into   l_task_id,l_rlmi
      from   pa_resource_assignments pra
      where  pra.resource_assignment_id = P_resource_assignment_id;

    IF P_DEBUG_MODE = 'Y' THEN
     pa_fck_util.debug_msg('Is_account_change_allowed: get parent rlmi');
    END IF;

      If nvl(g_api_rlmi,-1) <> l_rlmi then

           select nvl(parent_member_id,-99) into g_api_parent_rlmi
           from   pa_resource_list_members prlm where resource_list_member_id = l_rlmi;

           g_api_rlmi        := l_rlmi;
      End If;

    IF P_DEBUG_MODE = 'Y' THEN
     pa_fck_util.debug_msg('Is_account_change_allowed: get top task');
    END IF;

      If nvl(g_api_task_id,-1) <> l_task_id then
        If l_budget_entry_level_code = 'P' then
           g_api_top_task_id := 0;
        Else
           select top_task_id into g_api_top_task_id
           from   pa_tasks where task_id = l_task_id;

           g_api_task_id     := l_task_id;
        End if;
      End If;

    IF P_DEBUG_MODE = 'Y' THEN
     pa_fck_util.debug_msg('Is_account_change_allowed: get start date');
    END IF;

      select distinct start_date into l_start_date from pa_budget_lines
      where  budget_version_id      = p_budget_version_id
      and    resource_assignment_id = P_resource_assignment_id
      and    period_name            = l_period_name;

   IF P_DEBUG_MODE = 'Y' THEN
     pa_fck_util.debug_msg('Is_account_change_allowed: l_top_task_id['
                          ||g_api_top_task_id||'] l_task_id ['
                          ||l_task_id||'] l_rlmi ['||l_rlmi||']l_parent_rlmi['
                          ||g_api_parent_rlmi||']l_start_date['||l_start_date
                          ||'] l_period_name['||l_period_name ||']');
     pa_fck_util.debug_msg('Is_account_change_allowed: Calling Is_Account_change_allowed2');
   END IF;


     If Is_Account_change_allowed2
              (p_budget_version_id       => g_current_baseline_bvid,
               p_project_id              => g_api_project_id,
               p_top_task_id             => g_api_top_task_id,
               p_task_id                 => l_task_id,
               p_parent_resource_id      => g_api_parent_rlmi,
               p_resource_list_member_id => l_rlmi,
               p_start_date              => l_start_date,
               p_period_name             => l_period_name,
               p_entry_level_code        => l_budget_entry_level_code,
               p_mode                    => 'FORM') = 'N' then

            IF P_DEBUG_MODE = 'Y' THEN
               pa_fck_util.debug_msg('Is_account_change_allowed: Is_Account_change_allowed2 -> N');
            End If;

         return 'N';
     Else
            IF P_DEBUG_MODE = 'Y' THEN
               pa_fck_util.debug_msg('Is_account_change_allowed: Is_Account_change_allowed2 -> Y');
            End If;

         return'Y';
     End If;

/* =====================================================================================+
-- ------------------------------- 'L' ---------------------------------------------------+

If l_budget_entry_level_code = 'L' then

 If (nvl(pa_budget_fund_pkg.g_processing_mode,'CHECK_FUNDS') = 'CHECK_FUNDS') then
 -- CHECK_FUNDS/THROUGH FORM ..this if condition ..
 -- BASELINE/YEAR_END ..else part ..

   -- If its Check funds, then we need to look at data from pa_bc_commitments_all
   Begin -- 'L' : pa_bc_packets

    Select 'N'
    into   l_return_status
    from   pa_resource_assignments pra
    where  pra.budget_version_id      = p_budget_version_id
    and    pra.resource_assignment_id = p_resource_assignment_id
    and    exists(select 1
                from   pa_bc_packets pbc
                where  pbc.project_id        = pra.project_id
	        and    pbc.resource_list_member_id = pra.resource_list_member_id
                and    pbc.period_name       = p_period_name
                and    pbc.task_id           = pra.task_id);
   Exception
    When no_data_found then
      Begin -- 'L' : pa_bc_commitments_all
         Select 'N'
         into   l_return_status
         from   pa_resource_assignments pra
         where  pra.budget_version_id      = p_budget_version_id
         and    pra.resource_assignment_id = p_resource_assignment_id
         and    exists(select 1
                       from   pa_bc_commitments_all pbc
                       where  pbc.project_id        = pra.project_id
                       and    pbc.resource_list_member_id = pra.resource_list_member_id
                       and    pbc.period_name       = p_period_name
                       and    pbc.task_id           = pra.task_id);
      Exception
        When no_data_found then
             return 'Y';
        End; -- 'L' : pa_bc_commitments_all
    End; -- 'L' : pa_bc_packets

 Else

 Begin -- 'L' : pa_bc_balances

  Select 'N'
  into   l_return_status
  from   pa_resource_assignments pra,
         pa_budget_lines         pbl
  where  pbl.budget_version_id      = p_budget_version_id
  and    pbl.resource_assignment_id = p_resource_assignment_id
  and    pbl.period_name            = P_period_name
  and    pra.resource_assignment_id = pbl.resource_assignment_id
  and    pra.budget_version_id      = pbl.budget_version_id
  and    exists(select 1
                from   pa_bc_balances pbb
                where  pbb.budget_version_id = pra.budget_version_id
                and    pbb.project_id        = pra.project_id
                and    pbb.task_id           = pra.task_id
                and    pbb.resource_list_member_id = pra.resource_list_member_id
                and    trunc(pbb.start_date) = trunc(pbl.start_date)
                and    pbb.balance_type      <> 'BGT');

 Exception
  When no_data_found then

  Begin -- 'L' : pa_bc_packets

   Select 'N'
   into   l_return_status
   from   pa_resource_assignments pra
   where  pra.budget_version_id      = p_budget_version_id
   and    pra.resource_assignment_id = p_resource_assignment_id
   and    exists(select 1
                from   pa_bc_packets pbc
                where  pbc.budget_version_id = pra.budget_version_id
                and    pbc.project_id        = pra.project_id
                and    pbc.task_id           = pra.task_id
	        and    pbc.resource_list_member_id = pra.resource_list_member_id
                and    pbc.period_name       = p_period_name
                and    pbc.status_code       in ('A','P') );
  Exception
   When no_data_found then
       return 'Y';
   End; -- 'L' : pa_bc_packets
 End;   -- 'L' : pa_bc_balances

 End if; --Check funds or regular mode

-- ------------------------------- 'T' ---------------------------------------------------+
ElsIf l_budget_entry_level_code = 'T' then

 If (nvl(pa_budget_fund_pkg.g_processing_mode,'CHECK_FUNDS') = 'CHECK_FUNDS') then

   -- If its Check funds, then we need to look at data from pa_bc_commitments_all
   Begin -- 'T' : pa_bc_packets

    Select 'N'
    into   l_return_status
    from   pa_resource_assignments pra
    where  pra.budget_version_id      = p_budget_version_id
    and    pra.resource_assignment_id = p_resource_assignment_id
    and    exists(select 1
                from   pa_bc_packets pbc
                where  pbc.project_id        = pra.project_id
    	        and    pbc.resource_list_member_id = pra.resource_list_member_id
                and    pbc.period_name       = p_period_name
                and    pbc.top_task_id       = pra.task_id);
   Exception
    When no_data_found then
      Begin -- 'T' : pa_bc_commitments_all
        Select 'N'
        into   l_return_status
        from   pa_resource_assignments pra
        where  pra.budget_version_id      = p_budget_version_id
        and    pra.resource_assignment_id = p_resource_assignment_id
        and    exists(select 1
                      from   pa_bc_commitments_all pbc
                      where  pbc.project_id        = pra.project_id
    	              and    pbc.resource_list_member_id = pra.resource_list_member_id
                      and    pbc.period_name       = p_period_name
                      and    pbc.top_task_id       = pra.task_id);
      Exception
        When no_data_found then
             return 'Y';
      End; -- 'T' : pa_bc_commitments_all

    End; -- 'T' : pa_bc_packets

 Else

 Begin -- 'T' : pa_bc_balances

  Select 'N'
  into   l_return_status
  from   pa_resource_assignments pra,
         pa_budget_lines         pbl
  where  pbl.budget_version_id      = p_budget_version_id
  and    pbl.resource_assignment_id = p_resource_assignment_id
  and    pbl.period_name            = P_period_name
  and    pra.resource_assignment_id = pbl.resource_assignment_id
  and    pra.budget_version_id      = pbl.budget_version_id
  and    exists(select 1
                from   pa_bc_balances pbb
                where  pbb.budget_version_id = pra.budget_version_id
                and    pbb.project_id        = pra.project_id
                and    pbb.top_task_id       = pra.task_id
                and    pbb.resource_list_member_id = pra.resource_list_member_id
                and    trunc(pbb.start_date) = trunc(pbl.start_date)
                and    pbb.balance_type      <> 'BGT');
 Exception
  When no_data_found then

  Begin -- 'T' : pa_bc_packets

   Select 'N'
   into   l_return_status
   from   pa_resource_assignments pra
   where  pra.budget_version_id      = p_budget_version_id
   and    pra.resource_assignment_id = p_resource_assignment_id
   and    exists(select 1
                from   pa_bc_packets pbc
                where  pbc.budget_version_id = pra.budget_version_id
                and    pbc.project_id        = pra.project_id
                and    pbc.top_task_id       = pra.task_id
	        and    pbc.resource_list_member_id = pra.resource_list_member_id
                and    pbc.period_name       = p_period_name
                and    pbc.status_code       in ('A','P') );
  Exception
   When no_data_found then
       return 'Y';
  End; -- 'T' : pa_bc_packets
 End;  -- 'T' : pa_bc_balances

 End If; -- checkfunds or regular mode

-- ------------------------------- 'P' ---------------------------------------------------+
ElsIf l_budget_entry_level_code = 'P' then

  If (nvl(pa_budget_fund_pkg.g_processing_mode,'CHECK_FUNDS') = 'CHECK_FUNDS') then

   -- If its Check funds, then we need to look at data from pa_bc_commitments_all
   Begin -- 'P' : pa_bc_packets

    Select 'N'
    into   l_return_status
    from   pa_resource_assignments pra
    where  pra.budget_version_id      = p_budget_version_id
    and    pra.resource_assignment_id = p_resource_assignment_id
    and    exists(select 1
                from   pa_bc_packets pbc
                where  pbc.project_id        = pra.project_id
    	        and    pbc.resource_list_member_id = pra.resource_list_member_id
                and    pbc.period_name       = p_period_name);
   Exception
    When no_data_found then
      Begin -- 'P' : pa_bc_commitments_all
        Select 'N'
        into   l_return_status
        from   pa_resource_assignments pra
        where  pra.budget_version_id      = p_budget_version_id
        and    pra.resource_assignment_id = p_resource_assignment_id
        and    exists(select 1
                      from   pa_bc_commitments_all pbc
                      where  pbc.project_id        = pra.project_id
       	              and    pbc.resource_list_member_id = pra.resource_list_member_id
                      and    pbc.period_name       = p_period_name);
      Exception
        When no_data_found then
         return 'Y';
      End; -- 'P' : pa_bc_commitments_all

    End; -- 'P' : pa_bc_packets

 Else

 Begin -- 'P' : pa_bc_balances

  Select 'N'
  into   l_return_status
  from   pa_resource_assignments pra,
         pa_budget_lines         pbl
  where  pbl.budget_version_id      = p_budget_version_id
  and    pbl.resource_assignment_id = p_resource_assignment_id
  and    pbl.period_name            = P_period_name
  and    pra.resource_assignment_id = pbl.resource_assignment_id
  and    pra.budget_version_id      = pbl.budget_version_id
  and    exists(select 1
                from   pa_bc_balances pbb
                where  pbb.budget_version_id = pra.budget_version_id
                and    pbb.project_id        = pra.project_id
                and    pbb.resource_list_member_id = pra.resource_list_member_id
                and    trunc(pbb.start_date) = trunc(pbl.start_date)
                and    pbb.balance_type      <> 'BGT');

 Exception
  When no_data_found then

  Begin -- 'P' : pa_bc_packets

   Select 'N'
   into   l_return_status
   from   pa_resource_assignments pra
   where  pra.budget_version_id      = p_budget_version_id
   and    pra.resource_assignment_id = p_resource_assignment_id
   and    exists(select 1
                from   pa_bc_packets pbc
                where  pbc.budget_version_id = pra.budget_version_id
                and    pbc.project_id        = pra.project_id
	        and    pbc.resource_list_member_id = pra.resource_list_member_id
                and    pbc.period_name       = p_period_name
                and    pbc.status_code       in ('A','P') );
  Exception
   When no_data_found then
       return 'Y';
  End; -- 'P' : pa_bc_packets
 End;  -- 'P' : pa_bc_balances

 End if; -- checkfunds or normal mode

End If;

 RETURN l_return_status; -- Value will be 'N'
 ======================================================================== */
End Is_account_change_allowed;

-- --------------------------------------------------------------------------------------+
-- ## Another variation of is_account_change_allowed
-- ## This is called from pa_budget_account_pkg and pa_funds_control_pkg
-- ## This API was written as the previous one was not performing as required
-- ## Above API was being used from budgets form, but eventually we will remove that
-- ## dependancy too

FUNCTION   Is_Account_change_allowed2
              (p_budget_version_id       IN Number,
               p_project_id              IN Number,
               p_top_task_id             IN Number,
               p_task_id                 IN Number,
               p_parent_resource_id      IN Number,
               p_resource_list_member_id IN Number,
               p_start_date              IN Date,
               p_period_name             IN Varchar2,
               p_entry_level_code        IN Varchar2,
               p_mode                    IN Varchar2)
return Varchar2
IS
 l_budget_entry_level_code pa_budget_entry_methods.entry_level_code%type;
 l_allowed_flag            varchar2(1);
Begin
    IF P_DEBUG_MODE = 'Y' THEN
     pa_fck_util.debug_msg('In Is_account_change_allowed2:');
    END IF;

 l_allowed_flag := 'Y';

 -- # Determine entry level code if its 'M'.
 If p_entry_level_code = 'M' then
    -- task_id being passed is that on pa_resource_assignments ...
    -- top task id is determined from pa_tasks
    If p_task_id = p_top_task_id then
       l_budget_entry_level_code := 'T';
    Else
       l_budget_entry_level_code := 'L';
    End If;

 Else
   l_budget_entry_level_code := p_entry_level_code;
 End if;

  IF P_DEBUG_MODE = 'Y' THEN
   pa_fck_util.debug_msg('Is_account_change_allowed2: l_budget_entry_level_code::'||l_budget_entry_level_code);
  END IF;

 If p_mode = 'FORM' then -- ------------------------------+ FORM
 -- ------------------------------------------------------------------------+
 -- # Account check for Lowest Task level
 If l_budget_entry_level_code = 'L' then
  Begin

   Select 'N'
   into    l_allowed_flag
   from dual
   where   exists(select 1
                  from   pa_bc_balances pbb
                  where  pbb.budget_version_id         = p_budget_version_id
                  and    pbb.task_id                   = p_task_id
                  and    nvl(pbb.parent_member_id,-99) = nvl(p_parent_resource_id,-99)
                  and    pbb.resource_list_member_id   = p_resource_list_member_id
                  and    pbb.start_date                = p_start_date
                  and    pbb.balance_type              <> 'BGT');

  Exception
    When no_data_found then
         Select 'N'
         into   l_allowed_flag
         from dual
         where  exists(select 1
                       from   pa_bc_packets pbc
                       where  pbc.budget_version_id           = p_budget_version_id
                       and    pbc.bud_task_id                 = p_task_id
                       and    pbc.bud_resource_list_member_id = p_resource_list_member_id
                       and    pbc.period_name                 = p_period_name
                       and    pbc.status_code       in ('A','P','I','Z') );
  End;

 End If; -- 'L'
 -- ------------------------------------------------------------------------+
 -- # Account check for Top Task level
If l_budget_entry_level_code = 'T' then
  Begin

   Select 'N'
   into    l_allowed_flag
   from dual
   where   exists(select 1
                  from   pa_bc_balances pbb
                  where  pbb.budget_version_id         = p_budget_version_id
                  and    pbb.top_task_id               = p_top_task_id
                  and    nvl(pbb.parent_member_id,-99) = nvl(p_parent_resource_id,-99)
                  and    pbb.resource_list_member_id   = p_resource_list_member_id
                  and    pbb.start_date                = p_start_date
                  and    pbb.balance_type              <> 'BGT');

  Exception
    When no_data_found then
         Select 'N'
         into   l_allowed_flag
         from dual
         where  exists(select 1
                       from   pa_bc_packets pbc
                       where  pbc.budget_version_id           = p_budget_version_id
                       and    pbc.bud_task_id                 = p_top_task_id
                       and    pbc.bud_resource_list_member_id = p_resource_list_member_id
                       and    pbc.period_name                 = p_period_name
                       and    pbc.status_code       in ('A','P','I','Z') );
  End;

 End If; -- 'T'
 -- ------------------------------------------------------------------------+
 -- # Account check for Project level
If l_budget_entry_level_code = 'P' then
  Begin

   Select 'N'
   into    l_allowed_flag
   from dual
   where   exists(select 1
                  from   pa_bc_balances pbb
                  where  pbb.budget_version_id         = p_budget_version_id
                  and    nvl(pbb.parent_member_id,-99) = nvl(p_parent_resource_id,-99)
                  and    pbb.resource_list_member_id   = p_resource_list_member_id
                  and    pbb.start_date                = p_start_date
                  and    pbb.balance_type              <> 'BGT');

  Exception
    When no_data_found then
         Select 'N'
         into   l_allowed_flag
         from dual
         where  exists(select 1
                       from   pa_bc_packets pbc
                       where  pbc.budget_version_id           = p_budget_version_id
                       and    pbc.bud_resource_list_member_id = p_resource_list_member_id
                       and    pbc.period_name                 = p_period_name
                       and    pbc.status_code       in ('A','P','I','Z') );
  End;

 End If; -- 'P'


 -- ------------------------------------------------------------------------+
 End If; --If p_mode = 'FORM' then -- ------------------------------+ FORM


 If p_mode = 'BASELINE' then -- ------------------------------+ BASELINE
 -- ------------------------------------------------------------------------+
 -- # Account check for Lowest Task level
 If l_budget_entry_level_code = 'L' then
  Begin

    Select 'N'
    into   l_allowed_flag
    from dual
    where  exists(select 1
                  from   pa_bc_packets pbc
                  where  pbc.budget_version_id           = p_budget_version_id
                  and    pbc.bud_task_id                 = p_task_id
                  and    pbc.bud_resource_list_member_id = p_resource_list_member_id
                  and    pbc.period_name                 = p_period_name
                  and    pbc.status_code                 = 'A');
  Exception
    When no_data_found then
      Select 'N'
      into    l_allowed_flag
      from dual
      where   exists(select 1
                  from   pa_bc_balances pbb
                  where  pbb.budget_version_id         = p_budget_version_id
                  and    pbb.task_id                   = p_task_id
                  and    nvl(pbb.parent_member_id,-99) = nvl(p_parent_resource_id,-99)
                  and    pbb.resource_list_member_id   = p_resource_list_member_id
                  and    pbb.start_date                = p_start_date
                  and    pbb.balance_type              <> 'BGT');

  End;

 End If; -- 'L'
 -- ------------------------------------------------------------------------+
 -- # Account check for Top Task level
If l_budget_entry_level_code = 'T' then
  Begin

    Select 'N'
    into   l_allowed_flag
    from dual
    where  exists(select 1
                  from   pa_bc_packets pbc
                  where  pbc.budget_version_id           = p_budget_version_id
                  and    pbc.bud_task_id                 = p_top_task_id
                  and    pbc.bud_resource_list_member_id = p_resource_list_member_id
                  and    pbc.period_name                 = p_period_name
                  and    pbc.status_code                 = 'A');
  Exception
    When no_data_found then
      Select 'N'
      into    l_allowed_flag
      from dual
      where   exists(select 1
                  from   pa_bc_balances pbb
                  where  pbb.budget_version_id         = p_budget_version_id
                  and    pbb.top_task_id               = p_top_task_id
                  and    nvl(pbb.parent_member_id,-99) = nvl(p_parent_resource_id,-99)
                  and    pbb.resource_list_member_id   = p_resource_list_member_id
                  and    pbb.start_date                = p_start_date
                  and    pbb.balance_type              <> 'BGT');

  End;

 End If; -- 'T'
 -- ------------------------------------------------------------------------+
 -- # Account check for Project level
If l_budget_entry_level_code = 'P' then
  Begin

    Select 'N'
    into   l_allowed_flag
    from dual
    where  exists(select 1
                  from   pa_bc_packets pbc
                  where  pbc.budget_version_id           = p_budget_version_id
                  and    pbc.bud_resource_list_member_id = p_resource_list_member_id
                  and    pbc.period_name                 = p_period_name
                  and    pbc.status_code                 = 'A');
  Exception
    When no_data_found then
      Select 'N'
      into    l_allowed_flag
      from dual
      where   exists(select 1
                  from   pa_bc_balances pbb
                  where  pbb.budget_version_id         = p_budget_version_id
                  and    nvl(pbb.parent_member_id,-99) = nvl(p_parent_resource_id,-99)
                  and    pbb.resource_list_member_id   = p_resource_list_member_id
                  and    pbb.start_date                = p_start_date
                  and    pbb.balance_type              <> 'BGT');

  End;

 End If; -- 'P'


 -- ------------------------------------------------------------------------+
 End If; --If p_mode = 'FORM' then -- ------------------------------+ BASELINE

   IF P_DEBUG_MODE = 'Y' THEN
    pa_fck_util.debug_msg('In Is_account_change_allowed2:l_allowed_flag::'||l_allowed_flag);
   END IF;

  RETURN l_allowed_flag;

Exception
  When no_data_found then
   IF P_DEBUG_MODE = 'Y' THEN
    pa_fck_util.debug_msg('In Is_account_change_allowed2:l_allowed_flag::'||'Y');
   END IF;

   RETURN 'Y';
End Is_account_change_allowed2;
-- ----------------------------------------------------------------------------+

-- /*============================================================================+
-- R12 Funds management enhancement --rshaik
-- API name     : get_sla_notupgraded_flag
-- Type         : private
-- Description  : Returns Y/N depending on whether the distribution and associated
--                budget are non upgraded
--                This procedure calls PSA_BC_XLA_PUB.Get_sla_notupgraded_flag
--                for both REQ/PO transaction and associated budget .Even if one them
--                is not upgraded then this function will consider it as nonupgraded
--                transaction and returns 'Y'.
-- /*============================================================================+

FUNCTION get_sla_notupgraded_flag ( p_application_id            IN NUMBER,
                                    p_entity_code               IN VARCHAR2,
                                    p_document_header_id	IN NUMBER,
                                    p_document_distribution_id	IN NUMBER,
                                    p_dist_link_type 	        IN VARCHAR2,
                                    p_budget_version_id       	IN NUMBER,
                                    p_budget_line_id            IN NUMBER )
RETURN VARCHAR2 IS

-- Bug 5503577 : Cursor to check if the budget has been baselined in R12.
CURSOR c_check_budget_upg_status IS
SELECT 'UPGRADED'
  FROM pa_budget_lines
 WHERE budget_version_id = p_budget_version_id
   AND bc_event_id IS NOT NULL
   AND rownum = 1;

l_budget_upgraded_status  VARCHAR2(10);

BEGIN

  -- Check if transaction is not upgraded
  IF PSA_BC_XLA_PUB.Get_sla_notupgraded_flag
                               	(p_application_id         => p_application_id ,
                                 p_entity_code            => p_entity_code,
                                 p_source_id_int_1        => p_document_header_id,
                                 p_dist_link_type         => p_dist_link_type,
                                 p_distribution_id        => p_document_distribution_id) = 'Y' THEN
     RETURN 'Y';

   END IF;

   --  Bug 5503577 : Check if associated budget is not upgraded
   -- Note : p_budget_line_id will be NULL when called from sla extracts ,as fundscheck is not yet fired.

   OPEN c_check_budget_upg_status;
   FETCH c_check_budget_upg_status INTO l_budget_upgraded_status;
   CLOSE c_check_budget_upg_status;

   IF NVL(l_budget_upgraded_status,'NOTUPGRADED') = 'NOTUPGRADED' THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;

EXCEPTION
WHEN OTHERS THEN
   RETURN 'N';
END get_sla_notupgraded_flag;

-- Bug 5206341 : Function to check if there exists any closed periods in current budget version

FUNCTION CLOSED_PERIODS_EXISTS_IN_BUDG (p_budget_version_id IN NUMBER)
RETURN VARCHAR2 IS

CURSOR c_closed_periods_exists IS
SELECT 'Y'
  FROM PA_BUDGET_ACCT_LINES PBA,
       GL_PERIOD_STATUSES   GLS
 WHERE GLS.application_id = 101
   AND GLS.set_of_books_id in (SELECT set_of_books_id FROM pa_implementations)
   AND GLS.period_name = PBA.gl_period_name
   AND GLS.closing_status = 'C'
   AND PBA.budget_version_id = p_budget_version_id
   AND rownum = 1;

l_closed_periods_exists VARCHAR2(1) := NULL;

BEGIN

  OPEN c_closed_periods_exists;
  FETCH c_closed_periods_exists INTO l_closed_periods_exists;
  CLOSE c_closed_periods_exists;

  RETURN NVL(l_closed_periods_exists,'N');

END CLOSED_PERIODS_EXISTS_IN_BUDG;

--=======================================================================================+
-- #R12 Funds management enhancement
-- #API name     : Update_bvid_blid_on_cdl_bccom
-- #Type         : private
-- #Description  : Stamps latest budget version id and  budget_line_id on
--                 1. CDL when called from baselining process
--                 2. CDL and bc commitments when called from yearend rollover process
--=======================================================================================+

PROCEDURE Update_bvid_blid_on_cdl_bccom ( p_bud_ver_id  IN NUMBER,
                                          p_calling_mode IN VARCHAR2) IS

 l_DocHdrTab   PA_PLSQL_DATATYPES.IdTabTyp;
 l_DocDistTab  PA_PLSQL_DATATYPES.IdTabTyp;
 l_bccomidTab  PA_PLSQL_DATATYPES.IdTabTyp;
 l_bvidTab     PA_PLSQL_DATATYPES.IdTabTyp;
 l_blidTab     PA_PLSQL_DATATYPES.IdTabTyp;
 l_burcodeTab  PA_PLSQL_DATATYPES.Char10TabTyp;
 l_projidTab   PA_PLSQL_DATATYPES.IdTabTyp;
 l_taskidTab   PA_PLSQL_DATATYPES.IdTabTyp;
 l_toptaskidTab   PA_PLSQL_DATATYPES.IdTabTyp;
 l_rlmidTab       PA_PLSQL_DATATYPES.IdTabTyp;
 l_startdateTab   PA_PLSQL_DATATYPES.DateTabTyp;
 l_entrylevelcode PA_PLSQL_DATATYPES.Char10TabTyp;
 l_glprdstatustab PA_PLSQL_DATATYPES.Char10TabTyp;
 l_closed_prd_exists   VARCHAR2(1);


 -- Driving cursor for updating CDL budget version and line details for baselining process
 -- Note: Sweeper process will be later run by baselining process which will handle bc_commitments update.
 CURSOR c_bc_packets IS
 SELECT bc.document_header_id,
        bc.document_distribution_id,
	bc.bc_commitment_id,
	bc.project_id,
	bc.task_id,
	bc.top_task_id,
	bc.resource_list_member_id,
        NULL start_date,       -- Required only for closed period transactions
        bc.burden_method_code,
	NULL entry_level_code, -- Required only for closed period transactions
	bc.budget_version_id,
	bc.budget_line_id,
	NULL gl_period_status  -- Required only for closed period transactions
  from  pa_bc_packets bc
  WHERE bc.budget_version_id = p_bud_ver_id -- current baselined version id
    AND bc.status_code ='A'
    -- Parent bc packet id will be -99 for BTC and CWK lines --check logic in PA_BGT_BASELINE_PKG
    AND NVL(bc.parent_bc_packet_id,-99) = -99
    AND bc.actual_flag ='A'
    AND bc.document_type ='EXP'
 UNION ALL
 -- Bug 5206341 : Cursor to pick transactions associated with last baselined version and which were not picked in current
 -- run as the GL period has been closed.
 SELECT bc.exp_item_id,
        to_number(bc.reference3),
        bc.bc_commitment_id,
        bc.project_id,
        bc.task_id,
        bc.top_task_id,
        bc.resource_list_member_id,
        gl.start_date,
        bc.burden_method_code,
        BEM.entry_level_code,
        p_bud_ver_id budget_version_id,
        NULL budget_line_id,
	'C' gl_period_status
   FROM pa_bc_commitments bc,
        pa_budget_versions pbv,
        pa_budget_entry_methods bem,
	gl_period_statuses gl
  WHERE GL.application_id = 101
    AND GL.set_of_books_id = bc.set_of_books_id
    AND gl.period_name  = bc.period_name
    AND GL.closing_status = 'C'
    AND bc.budget_version_id = pbv.budget_version_id
    AND BEM.Budget_Entry_Method_Code = PBV.Budget_Entry_Method_Code
    AND pbv.budget_version_id = pa_budget_fund_pkg.g_cost_prev_bvid
    AND l_closed_prd_exists = 'Y';

 -- Driving cursor for updating CDL and bc_commitments budget version and budget line for year end rollover process
 -- Note : Sweeper process is run in start of year end rollover process, hence all the data exists in bc_commitments
 CURSOR c_bccom_packets IS
 SELECT bc.exp_item_id,
	to_number(bc.reference3),
        bc.bc_commitment_id,
        bc.project_id,
	bc.task_id,
	bc.top_task_id,
        bc.resource_list_member_id,
	gl.start_date,
        bc.burden_method_code,
	BEM.entry_level_code,
	p_bud_ver_id budget_version_id,
	NULL budget_line_id,
	DECODE(pbv.budget_version_id,pa_budget_fund_pkg.g_cost_prev_bvid,'C',NULL) gl_period_status
  from  pa_bc_commitments bc,
        pa_budget_versions pbv,
        pa_budget_entry_methods bem,
	gl_period_statuses gl
  WHERE GL.application_id = 101
    AND GL.set_of_books_id = bc.set_of_books_id
    AND gl.period_name  = bc.period_name
    AND GL.closing_status = DECODE(pbv.budget_version_id,pa_budget_fund_pkg.g_cost_prev_bvid,'C',GL.closing_status)
    AND bc.budget_version_id = pbv.budget_version_id
    AND BEM.Budget_Entry_Method_Code = PBV.Budget_Entry_Method_Code
    AND pbv.budget_version_id in (SELECT p_bud_ver_id
                                    FROM dual
				  UNION ALL
				  -- Bug 5206341 :Transactions in closed period are picked for latest budget details stamping
				  SELECT pa_budget_fund_pkg.g_cost_prev_bvid
				    FROM dual
                                   WHERE l_closed_prd_exists = 'Y');


   l_ccid                pa_bc_packets.budget_ccid%type := null;
   l_error_message_code  varchar2(200) := null;
   l_return_status       varchar2(10) := 'S';

PROCEDURE Intialize_plsql_tables IS
BEGIN
       l_DocHdrTab.delete;
       l_DocDistTab.delete;
       l_bccomidTab.delete;
       l_bvidTab.delete;
       l_blidTab.delete;
       l_burcodeTab.delete;
       l_projidTab.delete;
       l_taskidTab.delete;
       l_toptaskidTab.delete;
       l_rlmidTab.delete;
       l_startdateTab.delete;
       l_entrylevelcode.delete;
       l_glprdstatustab.delete;

END Intialize_plsql_tables;

BEGIN


  IF P_DEBUG_MODE = 'Y' THEN
     pa_fck_util.debug_msg('Update_bvid_blid_on_cdl_bccom: Start p_bud_ver_id ='||p_bud_ver_id );
     pa_fck_util.debug_msg('Update_bvid_blid_on_cdl_bccom: Start p_calling_mode ='||p_calling_mode );
  END IF;

  -- Bug 5206341 : Check if closed GL periods exists for this baseline run.
  -- If exists we need to have additional logic to stamp latest budget version id and
  -- budget_line_id on CDL and bc commitments as baseline process donot pick these
  -- transactions for fundschecking

  l_closed_prd_exists := PA_FUNDS_CONTROL_UTILS.CLOSED_PERIODS_EXISTS_IN_BUDG(p_bud_ver_id);

  IF P_DEBUG_MODE = 'Y' THEN
     pa_fck_util.debug_msg('Update_bvid_blid_on_cdl_bccom: Start l_closed_prd_exists ='||l_closed_prd_exists );
     pa_fck_util.debug_msg('Update_bvid_blid_on_cdl_bccom: Start p_bud_ver_id ='||p_bud_ver_id );
  END IF;

  IF p_calling_mode = 'RESERVE_BASELINE' THEN

    OPEN c_bc_packets;
    LOOP

       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('Clearing local plsql tabs');
       END IF;

       Intialize_plsql_tables;

       FETCH c_bc_packets BULK COLLECT INTO
       l_DocHdrTab,
       l_DocDistTab,
       l_bccomidTab,
       l_projidTab,
       l_taskidTab,
       l_toptaskidTab,
       l_rlmidTab,
       l_startdateTab,
       l_burcodeTab,
       l_entrylevelcode,
       l_bvidTab,
       l_blidTab,
       l_glprdstatustab
       LIMIT 500;

       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('Number of records fetched from pa_bc_packets ='||l_DocHdrTab.count);
       END IF;

       FOR i in 1..l_DocHdrTab.count LOOP
          pa_fck_util.debug_msg('Value of l_DocHdrTab ('||i||')='||l_DocHdrTab(i));
          pa_fck_util.debug_msg('Value of l_DocDistTab('||i||')='||l_DocDistTab(i));
          pa_fck_util.debug_msg('Value of l_bccomidTab ('||i||')='||l_bccomidTab(i));
          pa_fck_util.debug_msg('Value of l_projidTab ('||i||')='||l_projidTab(i));
          pa_fck_util.debug_msg('Value of l_taskidTab ('||i||')='||l_taskidTab(i));
          pa_fck_util.debug_msg('Value of l_toptaskidTab ('||i||')='||l_toptaskidTab(i));
          pa_fck_util.debug_msg('Value of l_rlmidTab ('||i||')='||l_rlmidTab(i));
          pa_fck_util.debug_msg('Value of l_startdateTab ('||i||')='||l_startdateTab(i));
          pa_fck_util.debug_msg('Value of l_entrylevelcode ('||i||')='||l_entrylevelcode(i));
          pa_fck_util.debug_msg('Value of l_burcodeTab ('||i||')='||l_burcodeTab(i));
          pa_fck_util.debug_msg('Value of l_bvidTab ('||i||')='||l_bvidTab(i));
          pa_fck_util.debug_msg('Value of l_glprdstatustab ('||i||')='||l_glprdstatustab(i));
       END LOOP;

       IF l_DocHdrTab.count = 0 THEN
         IF P_DEBUG_MODE = 'Y' THEN
            pa_fck_util.debug_msg('No more records to process');
         END IF;
         EXIT;
       END IF;

       -- Bug 5206341 : Logic to derive new budget_line_id for transactions which are falling with in
       -- closed periods.For transactions falling in open/future periods ,baselining process has already derived
       -- the latest budget details.
       IF l_closed_prd_exists = 'Y' THEN

        FOR i in l_DocHdrTab.first..l_DocHdrTab.last LOOP

	  IF l_glprdstatustab(i) = 'C' THEN

           IF P_DEBUG_MODE = 'Y' THEN
                 pa_fck_util.debug_msg('Update_bvid_blid_on_cdl_bccom: Deriving budget details for closed period txns');
           END IF;

           Get_Budget_CCID (
                 p_project_id        => l_projidTab(i),
                 p_task_id           => l_taskidTab(i),
                 p_top_task_id       => l_toptaskidTab(i),
                 p_res_list_mem_id   => l_rlmidTab(i),
                 p_start_date        => l_startdateTab(i),
                 p_budget_version_id => l_bvidTab(i),
                 p_entry_level_code  => l_entrylevelcode(i),
                 x_budget_ccid       => l_ccid,
                 x_budget_line_id    => l_blidTab(i),
                 x_return_status     => l_return_status,
                 x_error_message_code  => l_error_message_code );

          END IF;

          IF P_DEBUG_MODE = 'Y' THEN
             pa_fck_util.debug_msg( 'Value of l_blidTab(i) '||l_blidTab(i));
          END IF;

        END LOOP;

       END IF; -- IF l_closed_prd_exists = 'Y' THEN

       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg( 'Updating budget_version_id and budget_line_id on pa_cost_distribution_lines_all ');
       END IF;

       FORALL i in l_DocHdrTab.first..l_DocHdrTab.last
       UPDATE pa_cost_distribution_lines_all cdl
         SET  cdl.budget_version_id = NVL(l_bvidTab(i),cdl.budget_version_id),
	      cdl.budget_line_id = NVL(l_blidTab(i),cdl.budget_line_id)
	WHERE cdl.expenditure_item_id = l_DocHdrTab(i)
	  AND ( cdl.line_num = l_DocDistTab(i) OR (l_burcodeTab(i) = 'S' AND cdl.line_type ='D'))
	  AND cdl.budget_version_id IS NOT NULL
	  AND (cdl.acct_event_id IS NULL OR -- events which are not processed by SLA
	       EXISTS (SELECT 1
	                 FROM xla_events xev
			WHERE xev.event_id = cdl.acct_event_id
			  AND xev.application_id = 275
			  AND xev.process_status_code <> 'P' )
               );

       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg( 'Number of pa_cost_distribution_lines_all updated'||SQL%ROWCOUNT);
          pa_fck_util.debug_msg( 'Updating budget_version_id and budget_line_id on pa_bc_commitments_all ');
       END IF;

       -- Bug 5206341 : Logic to stamp new budget_line_id for transactions which are falling with in
       -- closed periods.For transactions falling in open/future periods ,sweeper process will be updating
       -- the latest budget details.

       IF l_closed_prd_exists = 'Y' THEN

        FORALL i in l_DocHdrTab.first..l_DocHdrTab.last
        UPDATE pa_bc_commitments_all bccom
          SET  bccom.budget_version_id = NVL(l_bvidTab(i), bccom.budget_version_id),
	       bccom.budget_line_id = NVL(l_blidTab(i),bccom.budget_line_id)
   	 WHERE bccom.bc_commitment_id = l_bccomidTab(i)
	   AND l_glprdstatustab(i) = 'C'
	   AND bccom.budget_version_id = pa_budget_fund_pkg.g_cost_prev_bvid;

        IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg( 'Number of pa_bc_commitments_all updated'||SQL%ROWCOUNT);
        END IF;

       END IF; -- IF l_closed_prd_exists = 'Y' THEN

    END LOOP;
    CLOSE c_bc_packets;

  ELSE --IF p_calling_mode = 'YEAR END ROLLOVER' THEN

       -- For year end rollover , below update will update latest budget version id and budget line id
       -- on expenditure records which got created while interfacing AP/PO to projects

    OPEN c_bccom_packets;
    LOOP

       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('Clearing local plsql tabs');
       END IF;

       Intialize_plsql_tables;

       FETCH c_bccom_packets BULK COLLECT INTO
       l_DocHdrTab,
       l_DocDistTab,
       l_bccomidTab,
       l_projidTab,
       l_taskidTab,
       l_toptaskidTab,
       l_rlmidTab,
       l_startdateTab,
       l_burcodeTab,
       l_entrylevelcode,
       l_bvidTab,
       l_blidTab,
       l_glprdstatustab
       LIMIT 500;

       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('Number of records fetched from pa_bc_packets ='||l_DocHdrTab.count);
       END IF;

       FOR i in 1..l_DocHdrTab.count LOOP
          pa_fck_util.debug_msg('Value of l_DocHdrTab ('||i||')='||l_DocHdrTab(i));
          pa_fck_util.debug_msg('Value of l_DocDistTab('||i||')='||l_DocDistTab(i));
          pa_fck_util.debug_msg('Value of l_bccomidTab ('||i||')='||l_bccomidTab(i));
          pa_fck_util.debug_msg('Value of l_projidTab ('||i||')='||l_projidTab(i));
          pa_fck_util.debug_msg('Value of l_taskidTab ('||i||')='||l_taskidTab(i));
          pa_fck_util.debug_msg('Value of l_toptaskidTab ('||i||')='||l_toptaskidTab(i));
          pa_fck_util.debug_msg('Value of l_rlmidTab ('||i||')='||l_rlmidTab(i));
          pa_fck_util.debug_msg('Value of l_startdateTab ('||i||')='||l_startdateTab(i));
          pa_fck_util.debug_msg('Value of l_entrylevelcode ('||i||')='||l_entrylevelcode(i));
          pa_fck_util.debug_msg('Value of l_burcodeTab ('||i||')='||l_burcodeTab(i));
          pa_fck_util.debug_msg('Value of l_bvidTab ('||i||')='||l_bvidTab(i));
          pa_fck_util.debug_msg('Value of l_glprdstatustab ('||i||')='||l_glprdstatustab(i));
       END LOOP;

       IF l_DocHdrTab.count = 0 THEN
         IF P_DEBUG_MODE = 'Y' THEN
            pa_fck_util.debug_msg('No more records to process');
         END IF;
         EXIT;
       END IF;

       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg( 'deriving budget_version_id and budget_line_id  ');
       END IF;

       FOR i in l_DocHdrTab.first..l_DocHdrTab.last LOOP

          Get_Budget_CCID (
                 p_project_id        => l_projidTab(i),
                 p_task_id           => l_taskidTab(i),
                 p_top_task_id       => l_toptaskidTab(i),
                 p_res_list_mem_id   => l_rlmidTab(i),
                 p_start_date        => l_startdateTab(i),
                 p_budget_version_id => l_bvidTab(i),
                 p_entry_level_code  => l_entrylevelcode(i),
                 x_budget_ccid       => l_ccid,
                 x_budget_line_id    => l_blidTab(i),
                 x_return_status     => l_return_status,
                 x_error_message_code  => l_error_message_code );

          IF P_DEBUG_MODE = 'Y' THEN
             pa_fck_util.debug_msg( 'Value of l_blidTab(i) '||l_blidTab(i));
          END IF;

       END LOOP;

       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg( 'Updating budget_version_id and budget_line_id on pa_cost_distribution_lines_all for EXP');
       END IF;

       FORALL i in l_DocHdrTab.first..l_DocHdrTab.last
       UPDATE pa_cost_distribution_lines_all cdl
         SET  cdl.budget_version_id = NVL(l_bvidTab(i),cdl.budget_version_id),
	      cdl.budget_line_id = NVL(l_blidTab(i),cdl.budget_line_id)
	WHERE cdl.expenditure_item_id = l_DocHdrTab(i)
    	  -- All the pending EXP lines associated with commitment should get updated ,hence no doc_dist_id join
	  AND ( cdl.line_type = 'R' OR (l_burcodeTab(i) = 'S' AND cdl.line_type ='D'))
	  AND cdl.budget_version_id IS NOT NULL
          AND l_DocHdrTab(i) is NOT NULL -- this record corresponds to EXP record in projects
	  AND (cdl.acct_event_id IS NULL OR -- events which are not processed by SLA
	       EXISTS (SELECT 1
	                 FROM xla_events xev
			WHERE xev.event_id = cdl.acct_event_id
			  AND xev.application_id = 275
			  AND xev.process_status_code <> 'P' )
               );

       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg( 'Number of pa_cost_distribution_lines_all updated'||SQL%ROWCOUNT);
          pa_fck_util.debug_msg( 'Updating budget_version_id and budget_line_id on pa_cost_distribution_lines_all for BTC');
       END IF;

       FORALL i in l_DocHdrTab.first..l_DocHdrTab.last
       UPDATE pa_cost_distribution_lines_all cdl
         SET  cdl.budget_version_id = NVL(l_bvidTab(i),cdl.budget_version_id),
	      cdl.budget_line_id = NVL(l_blidTab(i),cdl.budget_line_id)
	WHERE cdl.expenditure_item_id IN (SELECT exp2.expenditure_item_id
	                                    FROM pa_cost_distribution_lines_all cdl1,
					         pa_expenditure_items_all exp2  -- BTC
					   WHERE cdl1.expenditure_item_id = l_DocHdrTab(i)
					     AND cdl1.burden_sum_source_run_id = exp2.burden_sum_dest_run_id
					     AND exp2.system_linkage_function = 'BTC')
	  AND l_burcodeTab(i) <>  'S'
          AND l_DocHdrTab(i) is NOT NULL -- this record corresponds to EXP record in projects
	  AND cdl.budget_version_id IS NOT NULL
	  AND (cdl.acct_event_id IS NULL OR -- events which are not processed by SLA
	       EXISTS (SELECT 1
	                 FROM xla_events xev
			WHERE xev.event_id = cdl.acct_event_id
			  AND xev.application_id = 275
			  AND xev.process_status_code <> 'P' )
               );

       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg( 'Number of pa_cost_distribution_lines_all updated'||SQL%ROWCOUNT);
          pa_fck_util.debug_msg( 'Updating budget_version_id and budget_line_id on pa_bc_commitments_all ');
       END IF;

       FORALL i in l_DocHdrTab.first..l_DocHdrTab.last
       UPDATE pa_bc_commitments_all bccom
         SET  bccom.budget_version_id = NVL(l_bvidTab(i), bccom.budget_version_id),
	      bccom.budget_line_id = NVL(l_blidTab(i),bccom.budget_line_id)
	WHERE bccom.bc_commitment_id = l_bccomidTab(i);

       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg( 'Number of pa_bc_commitments updated'||SQL%ROWCOUNT);
       END IF;

    END LOOP;
    CLOSE c_bccom_packets;

  END IF; --IF p_calling_mode = 'YEAR END ROLLOVER' THEN

  IF P_DEBUG_MODE = 'Y' THEN
     pa_fck_util.debug_msg('Update_bvid_blid_on_cdl_bccom: End' );
  END IF;

Exception
  When OTHERS then
       IF P_DEBUG_MODE = 'Y' THEN
          pa_fck_util.debug_msg('EXCEPTION: '||SQLERRM);
       END IF;
      RAISE;
END Update_bvid_blid_on_cdl_bccom;

--=======================================================================================+
-- #Bug 5191768
-- #API name     : Get_cost_rejection_reason
-- #Type         : private
-- #Description  : Fundscheck rejection reasons are fetched from
--                   a. gms_lookups for Grants related transactions
--                   b. pa_lookups for Project related transactions
--                 Transaction rejection reason/cost distribution rejection reason are
--                 derived from pa_lookups
--=======================================================================================+

FUNCTION Get_cost_rejection_reason ( p_Lookup_code               IN VARCHAR2,
				     p_sponsored_flag            IN VARCHAR2)
return VARCHAR2 IS

l_meaning   pa_lookups.meaning%TYPE;

CURSOR c_pa_lookup_meaning IS
SELECT LOOKUP.Meaning
  FROM PA_Lookups LOOKUP
 WHERE LOOKUP.Lookup_Type  IN ('IND COST DIST REJECTION CODE','COST DIST REJECTION CODE', 'FC_RESULT_CODE', 'TRANSACTION REJECTION REASON')
   AND LOOKUP.Lookup_Code  = p_Lookup_code;

CURSOR c_gms_lookup_meaning IS
SELECT GMSLKUP.Meaning
  FROM GMS_Lookups GMSLKUP
 WHERE GMSLKUP.Lookup_Type  = 'FC_RESULT_CODE'
   AND GMSLKUP.Lookup_Code  = p_Lookup_code;

BEGIN

     IF p_sponsored_flag = 'Y' THEN

        OPEN c_gms_lookup_meaning ;
        FETCH c_gms_lookup_meaning INTO l_meaning;
        CLOSE c_gms_lookup_meaning ;

     END IF;

     IF l_meaning IS NULL THEN

        OPEN c_pa_lookup_meaning ;
        FETCH c_pa_lookup_meaning INTO l_meaning;
        CLOSE c_pa_lookup_meaning ;

     END IF;

     RETURN l_meaning;

END Get_cost_rejection_reason;

-- #R12 Funds management enhancement
-- #API name     : get_ap_acct_reversal_attr
-- #Type         : private
-- #Description  : Returns parent distribution id if its a AP cancel scenario .
--                 SLA accounting reversal logic will be fired if this api returns NOT NULL

FUNCTION get_ap_acct_reversal_attr ( p_event_type_code               IN VARCHAR2,
                                     p_document_distribution_id      IN NUMBER  ,
				     p_document_distribution_type    IN VARCHAR2 ) RETURN NUMBER IS

CURSOR C_get_inv_parent_id IS
SELECT AID.Parent_Reversal_id
  FROM ap_invoice_distributions_all aid
 WHERE aid.invoice_distribution_id = p_document_distribution_id
   AND decode(nvl(AID.cancellation_flag,'N'), 'Y', decode(AID.Parent_Reversal_id, null,'N','Y'),'N') = 'Y';

CURSOR C_get_prepay_parent_id IS
SELECT APAD.REVERSED_PREPAY_APP_DIST_ID
  FROM AP_PREPAY_APP_DISTS APAD,
       AP_PREPAY_HISTORY_ALL APPH,
       AP_INVOICES_ALL AI
 WHERE APAD.Prepay_App_Distribution_ID = p_document_distribution_id
   AND APPH.prepay_history_id          = APAD.prepay_history_id
   AND AI.invoice_id                   = APPH.invoice_id
   AND decode(p_event_type_code, 'PREPAYMENT UNAPPLIED', decode(nvl(AI.historical_flag,'N'), 'Y','N',
              decode(APAD.REVERSED_PREPAY_APP_DIST_ID, null, 'N','Y') ),'N') = 'Y' ;

BEGIN

 -- Check if cached
 IF NVL(g_event_type_code,-1) = NVL(p_event_type_code ,-1) AND
    NVL(g_document_distribution_id,-1)  = NVL(p_document_distribution_id,-1) AND
    NVL(g_document_distribution_type,-1) = NVL(p_document_distribution_type,-1) THEN

    RETURN g_parent_distribution_id;

 ELSE

    g_event_type_code := p_event_type_code;
    g_document_distribution_id := p_document_distribution_id;
    g_document_distribution_type := p_document_distribution_type;

    -- SUBSTR is used to cover other types of prepayment application dists
    IF SUBSTR(p_document_distribution_type,1,11)  ='PREPAY APPL' THEN

        OPEN    C_get_prepay_parent_id;
        FETCH   C_get_prepay_parent_id INTO g_parent_distribution_id;
	CLOSE   C_get_prepay_parent_id;

    ELSE

        OPEN    C_get_inv_parent_id;
        FETCH   C_get_inv_parent_id INTO g_parent_distribution_id;
	CLOSE   C_get_inv_parent_id;

    END IF;

    RETURN g_parent_distribution_id;

  END IF;

END get_ap_acct_reversal_attr;

-----------------------------------------------------------------------------------
-- #R12 Funds management enhancement
-- #API name     : get_ap_sla_reversed_status
-- #Type         : private
-- #Description  : Returns 'Y' if AP is cancelled and the SLA lines associated with
--                 AP has been reversed .Business flow cannot be used in this scenario.
--                 This function uses same logic as that of ap extract which indentifies
--                 scenarios where line level reversals are used.
-------------------------------------------------------------------------------------
FUNCTION get_ap_sla_reversed_status (p_invoice_id              IN NUMBER,
                                     p_invoice_distribution_id IN NUMBER ) RETURN VARCHAR2 IS

CURSOR C_check_reversing_dist IS
SELECT nvl(AID.cancellation_flag,'N')
  FROM ap_invoice_distributions_all aid
 WHERE aid.invoice_distribution_id = p_invoice_distribution_id
   AND decode(nvl(AID.cancellation_flag,'N'), 'Y', decode(AID.Parent_Reversal_id, null,'N','Y'),'N') = 'Y';

CURSOR C_check_main_cancelled_dist IS
SELECT 'Y'
  FROM dual
 WHERE exists ( select 1
                  from ap_invoice_distributions_all aid
		 where aid.invoice_id = p_invoice_id
		   and aid.Parent_Reversal_id = p_invoice_distribution_id);

l_ap_sla_reversed_status  VARCHAR2(1);

BEGIN

 l_ap_sla_reversed_status := 'N';

 OPEN  C_check_main_cancelled_dist;
 FETCH C_check_main_cancelled_dist INTO l_ap_sla_reversed_status;
 CLOSE C_check_main_cancelled_dist;

 IF NVL(l_ap_sla_reversed_status,'N') = 'N' THEN

    OPEN  C_check_reversing_dist;
    FETCH C_check_reversing_dist INTO l_ap_sla_reversed_status;
    CLOSE C_check_reversing_dist;

 END IF;

 l_ap_sla_reversed_status := NVL(l_ap_sla_reversed_status,'N');

 RETURN l_ap_sla_reversed_status;

END get_ap_sla_reversed_status;
-----------------------------------------------------------------------------------
-- R12 Funds Management Uptake
-- Procedure to derive credit/debit side of the amount for PO and REQ  distributions
-- This has logic in synch with R12 PO and REQ JLT's
-- Note: PO is maintaining similar logic in PO_ENCUMBRANCE_POSTPROCESSING.get_sign_for_amount
-- which needs to centralized by PSA .Will be logging bug against PSA and once fixed we can
-- directly call psa package.
-- For now since PO's logic is complicated ,PA will maintain below function .
-------------------------------------------------------------------------------------

FUNCTION DERIVE_PO_REQ_AMT_SIDE (p_event_type_code     IN VARCHAR2,
                                 p_main_or_backing_doc IN VARCHAR2,
                                 p_distribution_type   IN VARCHAR2 ) RETURN NUMBER IS

l_cr_dr_side     NUMBER := 0; -- If -1 then CR elsif +1 then DR

BEGIN

     IF (p_event_type_code             IN ( 'PO_PA_RESERVED' ,
                                            'PO_PA_CR_MEMO_CANCELLED',
                                            'RELEASE_REOPEN_FINAL_CLOSED',
                                            'RELEASE_CR_MEMO_CANCELLED',
                                            'RELEASE_RESERVED',
                                            'REQ_RESERVED',
                                            'PO_REOPEN_FINAL_MATCH',
                                            -- g_tab_entered_amount and g_tab_accted_amount will be negative for below events
                                            'PO_PA_CANCELLED',
                                            'RELEASE_CANCELLED',
                                            'REQ_CANCELLED'
                                            ) OR
          (p_event_type_code ='REQ_ADJUSTED' AND p_distribution_type = 'REQUISITION_ADJUSTED_NEW'))
     THEN

       IF p_main_or_backing_doc = 'M' THEN
          	l_cr_dr_side := 1;
       ELSE
          	l_cr_dr_side := -1;
       END IF;

    ELSIF (p_event_type_code             IN ('PO_PA_UNRESERVED' ,
                                             'PO_PA_FINAL_CLOSED',
                                             'PO_PA_REJECTED',
                                             'PO_PA_INV_CANCELLED',
                                             'RELEASE_FINAL_CLOSED',
                                             'RELEASE_INV_CANCELLED',
                                             'RELEASE_REJECTED',
                                             'RELEASE_UNRESERVED',
                                             'REQ_FINAL_CLOSED',
                                             'REQ_REJECTED',
                                             'REQ_RETURNED',
                                             'REQ_UNRESERVED') OR
        (p_event_type_code ='REQ_ADJUSTED' AND p_distribution_type = 'REQUISITION_ADJUSTED_OLD'))

    THEN

       IF p_main_or_backing_doc = 'M' THEN
                l_cr_dr_side := -1;
       ELSE
          	l_cr_dr_side := 1;
       END IF;

    END IF;

    RETURN l_cr_dr_side;

END DERIVE_PO_REQ_AMT_SIDE;

------------------------------------------------------------------------------
-- This Api tells if a particular project has funds check enbaled or not.
------------------------------------------------------------------------------
FUNCTION is_funds_check_enabled -- Added for bug 8530651
		(p_proj_id 	IN NUMBER
		)return VARCHAR2 is

	l_fc_enabled VARCHAR2(1) := 'N';
	l_rec_count number := 0;
BEGIN

  IF nvl(G_PROJ_ID,-1) <> p_proj_id
  THEN

     SELECT count(*)
       INTO l_rec_count
       FROM pa_budgetary_control_options
      WHERE project_id = p_proj_id
        AND bdgt_cntrl_flag = 'Y';

     if  l_rec_count >= 1 then
       l_fc_enabled := 'Y';
     end if;

	G_PROJ_ID    := p_proj_id;
	G_FC_ENABLED := l_fc_enabled;

	return G_FC_ENABLED;

  ELSE

    RETURN G_FC_ENABLED;

  END IF;


EXCEPTION

	WHEN NO_DATA_FOUND THEN

		RETURN l_fc_enabled;

	WHEN OTHERS THEN
		Raise;
END is_funds_check_enabled;


-- -----------------------------------------------------------------------------------------+

END PA_FUNDS_CONTROL_UTILS ;

/
