--------------------------------------------------------
--  DDL for Package Body PA_FP_CALC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_CALC_UTILS" AS
--$Header: PAFPCL1B.pls 120.20.12010000.12 2009/12/30 04:29:20 skkoppul ship $

    g_module_name VARCHAR2(100) := 'pa.plsql.PA_FP_CALC_UTILS';
    g_stage          Varchar2(1000);
    P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
    g_LAST_UPDATE_DATE  Date  := SYSDATE;
    g_LAST_UPDATED_BY   Number:= fnd_global.user_id;
    g_CREATION_DATE Date  := SYSDATE;
    g_CREATED_BY        Number:= fnd_global.user_id;
    g_LAST_UPDATE_LOGIN   Number:= fnd_global.login_id;
    g_rollup_required_flag   Varchar2(10) := 'Y';
    g_budget_version_id      Number;
    g_budget_version_type    Varchar2(100);
    g_budget_version_name    Varchar2(250);
    g_etc_start_date     Date;
    g_wp_version_flag        Varchar2(10);
    g_project_name           pa_projects_all.segment1%type;
    g_project_id             Number;
    g_ciid                   Number;
    g_Plan_Class_Type        Varchar2(50);
    g_project_currency_code  Varchar2(50);
    g_projfunc_currency_code  Varchar2(50);
    g_refresh_rates_flag     Varchar2(10);
    g_refresh_conv_rates_flag Varchar2(10);
    g_mass_adjust_flag    Varchar2(10);
    g_source_context          Varchar2(100);
    g_apply_progress_flag     Varchar2(10);
    g_baseline_funding_flag   Varchar2(10);
    g_approved_revenue_flag   Varchar2(10);
    g_calling_module          Varchar2(100);

	g_time_phase_changed_flag   Varchar2(1) := 'N'; /* Bug fix:4613444 */
	g_wp_cost_changed_flag      Varchar2(1) := 'N';

    g_RsAtrb_RaId_tab       pa_plsql_datatypes.NumTabTyp;
        g_RsAtrb_TxnCur_tab     pa_plsql_datatypes.Char50TabTyp;

    g_Rspd_RaId_tab         pa_plsql_datatypes.NumTabTyp;
        g_Rspd_TxnCur_tab       pa_plsql_datatypes.Char50TabTyp;
        g_Rspd_Pjcur_tab        pa_plsql_datatypes.Char50TabTyp;
        g_Rspd_pjf_cur_tab      pa_plsql_datatypes.Char50TabTyp;
        g_Rspd_SdShrk_Flg_tab       pa_plsql_datatypes.Char1TabTyp;
        g_Rspd_EdShrk_Flg_tab       pa_plsql_datatypes.Char1TabTyp;
        g_Rspd_SD_old_tab       pa_plsql_datatypes.DateTabTyp;
        g_Rspd_SD_new_tab       pa_plsql_datatypes.DateTabTyp;
        g_Rspd_ED_old_tab       pa_plsql_datatypes.DateTabTyp;
        g_Rspd_ED_new_tab       pa_plsql_datatypes.DateTabTyp;

    /* cursor to fetch the period details for the given budget version */
        CURSOR periodDetails(p_budget_version_id Number) IS
        SELECT gsb.period_set_name              period_set_name
                ,gsb.accounted_period_type      accounted_period_type
                ,pia.pa_period_type             pa_period_type
                ,pbv.version_type               version_type
                ,decode(pbv.version_type,
                        'COST',ppfo.cost_time_phased_code,
                        'REVENUE',ppfo.revenue_time_phased_code,
                         ppfo.all_time_phased_code) time_phased_code
         FROM gl_sets_of_books          gsb
                ,pa_implementations_all pia
                ,pa_projects_all        ppa
                ,pa_budget_versions     pbv
                ,pa_proj_fp_options     ppfo
        WHERE ppa.project_id        = pbv.project_id
        AND pbv.budget_version_id = ppfo.fin_plan_version_id
        /* MOAC changes: AND nvl(ppa.org_id,-99)   = nvl(pia.org_id,-99) */
	AND  ppa.org_id = pia.org_id
        AND gsb.set_of_books_id   = pia.set_of_books_id
        AND pbv.budget_version_id = p_budget_version_id;
        perdRec         periodDetails%ROWTYPE;


    /* curosr to select the version level details */
    CURSOR cur_bvDetails(p_budget_version_id Number) IS
    SELECT decode(nvl(bv.wp_version_flag,'N'),'Y',NVL(pfo.track_workplan_costs_flag,'N'),'Y') track_workplan_costs_flag
          ,bv.version_type
          ,bv.resource_list_id
          ,bv.approved_rev_plan_type_flag
          ,nvl(pfo.plan_in_multi_curr_flag,'N') plan_in_multi_curr_flag
          ,bv.etc_start_date
          ,nvl(bv.wp_version_flag,'N') wp_version_flag
          ,decode(bv.version_type,
                  'COST',NVL(pfo.cost_time_phased_code,'N'),
                  'REVENUE',NVL(pfo.revenue_time_phased_code,'N'),
                  NVL(pfo.all_time_phased_code,'N')) time_phased_code
      ,pp.segment1  project_name
      ,pp.project_currency_code
      ,pp.projfunc_currency_code
      ,bv.version_name
      ,NVL(pp.baseline_funding_flag,'N') baseline_funding_flag
        ,bv.project_id
        ,bv.ci_id ciId
        ,decode(fpt.plan_class_code,'BUDGET'
            ,decode(bv.wp_version_flag,'Y','WORKPLAN',fpt.plan_class_code),fpt.plan_class_code) Plan_Class_Type
        FROM pa_proj_fp_options pfo
            ,pa_budget_versions bv
        ,pa_projects_all pp
        ,pa_fin_plan_types_b fpt
        WHERE pfo.fin_plan_version_id = bv.budget_version_id
        AND bv.project_id = pp.project_id
        AND bv.budget_version_id = p_budget_version_id
        AND  fpt.fin_plan_type_id = pfo.fin_plan_type_id;
    bvDetailsRec    cur_bvDetails%ROWTYPE;

/**
procedure calc_log(p_msg  varchar2) IS

        pragma autonomous_transaction ;
BEGIN
        --dbms_output.put_line(p_msg);
        --IF P_PA_DEBUG_MODE = 'Y' Then
            NULL;
            INSERT INTO PA_FP_CALCULATE_LOG
                (SESSIONID
                ,SEQ_NUMBER
                ,LOG_MESSAGE)
            VALUES
                (userenv('sessionid')
                ,HR.PAY_US_GARN_FEE_RULES_S.nextval
                ,substr(P_MSG,1,240)
                );
        --END IF;
        COMMIT;

end calc_log;
**/
procedure PRINT_MSG(P_MSG  VARCHAR2) is

BEGIN
        --calc_log(P_MSG);
    --dbms_output.put_line(P_MSG);
        IF P_PA_DEBUG_MODE = 'Y' Then
            pa_debug.g_err_stage := substr('LOG:'||p_msg,1,240);
            PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
        END IF;
        Return;
END PRINT_MSG;

PROCEDURE Init_plsqlTabs IS

BEGIN
    g_RsAtrb_RaId_tab.delete;
        g_RsAtrb_TxnCur_tab.delete;

        g_Rspd_RaId_tab.delete;
        g_Rspd_TxnCur_tab.delete;
        g_Rspd_Pjcur_tab.delete;
        g_Rspd_pjf_cur_tab.delete;
        g_Rspd_SdShrk_Flg_tab.delete;
        g_Rspd_EdShrk_Flg_tab.delete;
        g_Rspd_SD_old_tab.delete;
        g_Rspd_SD_new_tab.delete;
        g_Rspd_ED_old_tab.delete;
        g_Rspd_ED_new_tab.delete;
END;
FUNCTION IsResMultiCurrency(p_resAsgnId  Number
            ,p_budget_version_id  Number) RETURN varchar2 IS

    CURSOR cur_check IS
    SELECT 'Y'
    FROM dual
    WHERE EXISTS ( select null
            from pa_budget_lines bl
            where bl.budget_version_id = p_budget_version_id
            and   bl.resource_assignment_id = p_resAsgnId
            GROUP BY bl.resource_assignment_id
            HAVING COUNT(*) > 1
             );

    l_exists_flag  Varchar2(1);
BEGIN
    OPEN cur_check;
    FETCH cur_check INTO l_exists_flag;
    CLOSE cur_check;

    RETURN NVL(l_exists_flag,'N');

END IsResMultiCurrency;

/* bug fix:5726773 */
 	 /* This API gets the sum of budget line quantity for the given resource assignment id and txn currency
 	  * combo. This API is used to check whether user try to change amounts only when budget lines exists which makes
 	  * total sum of quantity is zero. This causes the ORA error:divide-by-zero error
 	  */
 	 PROCEDURE get_bl_sum
 	                 (p_budget_version_id Number
 	                 ,p_ra_id Number
 	                 ,p_txn_cur_code Varchar2
 	                 ,p_source_context  varchar2 default 'RESOURCE_ASSIGNMENT'
 	                 ,p_start_date date
 	                 ,p_end_date   date
 	                 ,x_bl_qty_sum  OUT NOCOPY NUMBER ) IS

 	     /* bug fix:5726773: Added for supporting neg or zero quantity spread */

 	     Cursor  cur_asgn_bl_sumchk IS
 	     SELECT /*+ INDEX(BL PA_BUDGET_LINES_U1) */
 	         sum(bl.quantity)  bl_sum_quantity
 	         ,sum(bl.init_quantity) bl_sum_act_quantity
 	     FroM pa_budget_lines bl
 	     where bl.resource_assignment_id = p_ra_id
 	     and bl.txn_currency_code = p_txn_cur_code
 	     and bl.budget_version_id = p_budget_version_id;


 	     Cursor  cur_periodic_bl_sumchk IS
 	     SELECT /*+ INDEX(BL PA_BUDGET_LINES_U1) */
 	         sum(bl.quantity) bl_sum_quantity
 	         ,sum(bl.init_quantity) bl_sum_act_quantity
 	     FroM pa_budget_lines bl
 	     where bl.resource_assignment_id = p_ra_id
 	     and bl.txn_currency_code = p_txn_cur_code
 	     and bl.budget_version_id = p_budget_version_id
 	     and bl.start_date between p_start_date and p_end_date;

 	         l_bl_act_sum   Number;

 	 BEGIN
 	         x_bl_qty_sum := NULL;
 	         l_bl_act_sum := NULL;

 	         If p_source_context = 'BUDGET_LINE' then
 	                 OPEN cur_periodic_bl_sumchk;
 	                 FETCH cur_periodic_bl_sumchk INTO x_bl_qty_sum,l_bl_act_sum;
 	                 CLOSE cur_periodic_bl_sumchk;
 	         Else
 	                 OPEN cur_asgn_bl_sumchk;
 	                 FETCH cur_asgn_bl_sumchk INTO x_bl_qty_sum,l_bl_act_sum;
 	                 CLOSE cur_asgn_bl_sumchk;
 	         End If;
 	         /* Note: nvl should not be added to x_bl_qty_sum, the idea is to check the
 	          * budget line quantity sum which makes zero */
 	         x_bl_qty_sum := x_bl_qty_sum - nvl(l_bl_act_sum,0);

 	 END get_bl_sum;

/* Throw an error If budget lines having zero qty and actuals, these lines corrupted budget lines
 * getting created through the AMG apis and budget generation process. Just abort the process
*/
PROCEDURE Check_ZeroQty_Bls
                ( p_budget_version_id  IN NUMBER
                 ,x_return_status    OUT NOCOPY VARCHAR2
                ) IS

    CURSOR cur_CorruptedBls IS
    SELECT tmp.resource_assignment_id
          ,rl.alias resource_name
          ,tmp.txn_currency_code
    FROM  pa_fp_spread_calc_tmp tmp
         ,pa_resource_assignments ra
         ,pa_resource_list_members rl
    WHERE tmp.budget_version_id = p_budget_version_id
    AND   ra.resource_assignment_id = tmp.resource_assignment_id
    AND   rl.resource_list_member_id = ra.resource_list_member_id
    AND EXISTS (SELECT NULL
            FROM pa_budget_lines bl
                WHERE  bl.resource_assignment_id = tmp.resource_assignment_id
            AND  bl.txn_currency_code = tmp.txn_currency_code
            /* Bug fix: 4294902 :Check zero quantity only for the open periods */
                AND   NVL(g_etc_start_date,bl.start_date) BETWEEN bl.start_date and bl.end_date
                AND  ((NVL(bl.quantity,0)       = 0
                  AND (NVL(bl.txn_raw_cost,0)   <> 0
                OR NVL(bl.txn_burdened_cost,0)<> 0
                OR NVL(bl.txn_revenue,0)    <> 0
                OR NVL(bl.init_quantity,0)  <> 0 )
              )
            OR
                    (NVL(bl.init_quantity,0)    = 0
                         AND (NVL(bl.txn_init_raw_cost,0)   <> 0
                             OR NVL(bl.txn_init_burdened_cost,0) <> 0
                             OR NVL(bl.txn_init_revenue,0)  <> 0)
                        ))
         );

    /* This cursor picks all the resource assignments where budget line end date is less than start date */
    /* Bug fix:4440255 changes will provide the following xplain plan
     * EXPLAIN PLAN IS:
     * ================
     *1:SELECT STATEMENT   :(cost=22,rows=1)
     * 2:NESTED LOOPS   :(cost=22,rows=1)
         *  3:NESTED LOOPS   :(cost=21,rows=1)
         *   4:HASH JOIN SEMI  :(cost=20,rows=1)
         *    5:TABLE ACCESS BY INDEX ROWID PA_FP_SPREAD_CALC_TMP :(cost=6,rows=82)
         *      6:INDEX RANGE SCAN PA_FP_SPREAD_CALC_TMP_N2 :(cost=2,rows=33)
         *    5:TABLE ACCESS BY INDEX ROWID PA_BUDGET_LINES :(cost=13,rows=8)
         *      6:INDEX RANGE SCAN PA_BUDGET_LINES_N3 :(cost=2,rows=1)
         *   4:TABLE ACCESS BY INDEX ROWID PA_RESOURCE_ASSIGNMENTS :(cost=1,rows=1)
         *    5:INDEX UNIQUE SCAN PA_RESOURCE_ASSIGNMENTS_U1 :(cost=,rows=1)
         *  3:TABLE ACCESS BY INDEX ROWID PA_RESOURCE_LIST_MEMBERS :(cost=1,rows=1)
         *   4:INDEX UNIQUE SCAN PA_RESOURCE_LIST_MEMBERS_U1 :(cost=,rows=1)
     **/
    CURSOR cur_blDatesCheck IS
    SELECT tmp.resource_assignment_id
              ,rl.alias resource_name
          ,tmp.txn_currency_code
        FROM  pa_fp_spread_calc_tmp tmp
             ,pa_resource_assignments ra
             ,pa_resource_list_members rl
        WHERE tmp.budget_version_id = p_budget_version_id
        AND   ra.resource_assignment_id = tmp.resource_assignment_id
        AND   rl.resource_list_member_id = ra.resource_list_member_id
        AND EXISTS (SELECT /*+ NO_UNNEST INDEX (BL,PA_BUDGET_LINES_U1) */ NULL  -- Bug#4728472
                    FROM pa_budget_lines bl
                    WHERE  bl.resource_assignment_id = tmp.resource_assignment_id
                    AND  bl.txn_currency_code = tmp.txn_currency_code
            AND  bl.end_date < bl.start_date
            /* Bug:4440255 : added the following conditions reduces the FTS on pa_budget_lines and cost will reduce from 50 to 22 */
            AND bl.budget_version_id = tmp.budget_version_id
            /* end of bug fix:4440255 */
           );
BEGIN

    x_return_status := 'S';
    If P_PA_DEBUG_MODE = 'Y' Then
    	print_msg('Entered Check_ZeroQty_Bls API');
    End If;
    /* cache the period details info */
        perdRec := NULL;
        OPEN periodDetails(p_budget_version_id);
        FETCH periodDetails INTO perdRec;
        CLOSE periodDetails;

    /* Bug fix: 4296019: As discussed with Ramesh, Mani ,Sakthi and sanjay, removing this check as a short term solution
         * This corruption needs to be avoided, otherwise data corruption will be carried forward
    --print_msg('Check for Quantity corruption');
    FOR i IN  cur_CorruptedBls LOOP
                x_return_status := 'E';
        PA_UTILS.ADD_MESSAGE
                 (p_app_short_name => 'PA'
                 ,p_msg_name       => 'PA_FP_ZERO_QTY_BL_CORRUPTED'
                 ,p_token1         => 'BUDGET_VERSION_NAME'
                 ,p_value1         =>  g_budget_version_name
                 ,p_token2         => 'RESOURCE_NAME'
                 ,p_value2         => i.resource_name
                 ,p_token3         => 'RESOURCE_ASSIGNMENT'
                 ,p_value3         => i.resource_assignment_id
         ,p_token4         => 'TXN_CURRENCY_CODE'
         ,p_value4         => i.txn_currency_code
         ,p_token5         => 'Error Message'
         ,p_value5         => 'Budget Lines Corrupted: Lines with zero/Null quantity exists'
                 );
    END LOOP;
    * End of bug fix: 4296019 **/

    IF P_PA_DEBUG_MODE = 'Y' Then
    print_msg('Check for Dates corruption');
    End If;
    FOR i IN  cur_blDatesCheck LOOP
                x_return_status := 'E';
                PA_UTILS.ADD_MESSAGE
                 (p_app_short_name => 'PA'
                 ,p_msg_name       => 'PA_FP_BL_DATES_CORRUPTED'
                 ,p_token1         => 'BUDGET_VERSION_NAME'
                 ,p_value1         =>  g_budget_version_name
                 ,p_token2         => 'RESOURCE_NAME'
                 ,p_value2         => i.resource_name
                 ,p_token3         => 'RESOURCE_ASSIGNMENT'
                 ,p_value3         => i.resource_assignment_id
         ,p_token4         => 'TXN_CURRENCY_CODE'
                 ,p_value4         => i.txn_currency_code
                 ,p_token5         => 'Error Message'
                 ,p_value5         => 'Budget Lines Corrupted: End date is prior to start date'
                 );
        END LOOP;

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                print_msg('Failed in Check_ZeroQty_ActualBlsAPI'||sqlcode||sqlerrm);
                 fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'Check_ZeroQty_Bls');
                RAISE;
END Check_ZeroQty_Bls;

/* Bug fix:5309529: This is new API created to pre-process the IN params
 * table. This avoids additional loop through plsql arrays just to extend the plsql table
 * Logic:
 * if param passes value is fnd_api.g_miss_num then user intentionally entered null value from UI or AMG
 * so null out the param.  if param value passed is null or param is not passed at all,
 * then copy the db value from budget lines to the param so that user has made no change.
 * if param value is passed, then retain the param value.
 */
PROCEDURE pre_process_param_values
	(p_budget_version_id 		IN NUMBER
	,p_resource_assignment		IN NUMBER
	,p_txn_currency_code		IN VARCHAR2
	,p_txn_currency_override	IN VARCHAR2
	,p_bdgt_line_sDate		IN DATE
	,p_bdgt_line_eDate		IN DATE
	,p_delete_bl_flag               IN VARCHAR2
	,p_Qty_miss_num_flag		IN VARCHAR2
	,p_bl_quantity			IN NUMBER
	,p_bl_init_quantity		IN NUMBER
	,x_total_quantity		IN OUT NOCOPY NUMBER
	,p_Rw_miss_num_flag		IN VARCHAR2
	,p_bl_txn_raw_cost		IN NUMBER
	,p_bl_txn_init_raw_cost		IN NUMBER
	,x_total_raw_cost		IN OUT NOCOPY NUMBER
	,p_Br_miss_num_flag		IN VARCHAR2
	,p_bl_txn_burdened_cost		IN NUMBER
	,p_bl_txn_init_burdened_cost	IN NUMBER
	,x_total_burdened_cost		IN OUT NOCOPY NUMBER
	,p_Rv_miss_num_flag		IN VARCHAR2
	,p_bl_txn_revenue		IN NUMBER
	,p_bl_txn_init_revenue		IN NUMBER
	,x_total_revenue		IN OUT NOCOPY NUMBER
	,p_cost_rt_miss_num_flag	IN VARCHAR2
	,p_bl_etc_cost_rate		IN NUMBER
	,p_bl_etc_cost_rate_override	IN NUMBER
	,x_raw_cost_rate		IN OUT NOCOPY NUMBER
	,x_rw_cost_rate_override	IN OUT NOCOPY NUMBER
	,p_burd_rt_miss_num_flag	IN VARCHAR2
	,p_bl_etc_burden_rate		IN NUMBER
	,p_bl_etc_burden_rate_override	IN NUMBER
	,x_b_cost_rate			IN OUT NOCOPY NUMBER
	,x_b_cost_rate_override		IN OUT NOCOPY NUMBER
	,p_bill_rt_miss_num_flag	IN VARCHAR2
	,p_bl_etc_bill_rate		IN NUMBER
	,p_bl_etc_bill_rate_override	IN NUMBER
	,x_bill_rate			IN OUT NOCOPY NUMBER
	,x_bill_rate_override		IN OUT NOCOPY NUMBER
	,x_return_status		OUT NOCOPY VARCHAR2
	) IS

	l_message_name		varchar2(100);
	l_invalid_exception	EXCEPTION;
BEGIN

	x_return_status := 'S';
        IF p_resource_assignment is NULL OR p_txn_currency_code is NULL Then
        	--print_msg(to_char(l_stage)||' ERROR Resource assignment or currency NOT passed');
        	pa_utils.add_message
        	( p_app_short_name => 'PA',
        	p_msg_name       => 'PA_FP_CALC_RA_BL_REQ',
        	p_token1         => 'BUDGET_VERSION_ID',
        	p_value1         =>  p_budget_version_id,
        	p_token2         => 'PROJECT_ID',
        	p_value2         =>  g_project_id);
        	x_return_status := 'E';
		Raise l_invalid_exception;
        END IF;

        IF  g_source_context  = 'BUDGET_LINE' THEN
        	IF p_bdgt_line_sDate is NULL OR p_bdgt_line_eDate is NULL Then
        	pa_utils.add_message
        	( p_app_short_name => 'PA'
        	,p_msg_name       => 'PA_FP_CALC_BL_DATES_REQ'
        	,p_token1         => 'BUDGET_VERSION_ID'
        	,p_value1         =>  p_budget_version_id
        	,p_token2         => 'PROJECT_ID'
        	,p_value2         =>  g_project_id
        	,p_token3         =>  'RESOURCE_ASSIGNMENT'
        	,p_value3         =>  p_resource_assignment
        	,p_token4         =>  'TXN_CURRENCY'
        	,p_value4         =>  p_txn_currency_code
        	);
        	x_return_status := 'E';
		Raise l_invalid_exception;
        	END IF;
        END IF;

	/* Start of Bug fix:5726773: printing all input parameters  */
 	         If p_pa_debug_mode = 'Y' Then

 	             print_msg('p_resource_assignment          => '||p_resource_assignment        );
 	             print_msg('p_txn_currency_code            => '||p_txn_currency_code );
 	             print_msg('p_txn_currency_override        => '||p_txn_currency_override     );
 	             print_msg('p_bdgt_line_sDate              => '||p_bdgt_line_sDate   );
 	             print_msg('p_bdgt_line_eDate              => '||p_bdgt_line_eDate   );
 	             print_msg('p_delete_bl_flag               => '||p_delete_bl_flag    );
 	             print_msg('p_Qty_miss_num_flag            => '||p_Qty_miss_num_flag );
 	             print_msg('p_bl_quantity                  => '||p_bl_quantity       );
 	             print_msg('p_bl_init_quantity             => '||p_bl_init_quantity  );
 	             print_msg('x_total_quantity               => '||x_total_quantity    );
 	             print_msg('p_Rw_miss_num_flag             => '||p_Rw_miss_num_flag  );
 	             print_msg('p_bl_txn_raw_cost              => '||p_bl_txn_raw_cost   );
 	             print_msg('p_bl_txn_init_raw_cost         => '||p_bl_txn_init_raw_cost      );
 	             print_msg('x_total_raw_cost               => '||x_total_raw_cost    );
 	             print_msg('p_Br_miss_num_flag             => '||p_Br_miss_num_flag  );
 	             print_msg('p_bl_txn_burdened_cost         => '||p_bl_txn_burdened_cost      );
 	             print_msg('p_bl_txn_init_burdened_cost    => '||p_bl_txn_init_burdened_cost );
 	             print_msg('x_total_burdened_cost          => '||x_total_burdened_cost       );
 	             print_msg('p_Rv_miss_num_flag             => '||p_Rv_miss_num_flag  );
 	             print_msg('p_bl_txn_revenue               => '||p_bl_txn_revenue    );
 	             print_msg('p_bl_txn_init_revenue          => '||p_bl_txn_init_revenue       );
 	             print_msg('x_total_revenue                => '||x_total_revenue     );
 	             print_msg('p_cost_rt_miss_num_flag        => '||p_cost_rt_miss_num_flag     );
 	             print_msg('p_bl_etc_cost_rate             => '||p_bl_etc_cost_rate  );
 	             print_msg('p_bl_etc_cost_rate_override    => '||p_bl_etc_cost_rate_override );
 	             print_msg('x_raw_cost_rate                => '||x_raw_cost_rate     );
 	             print_msg('x_rw_cost_rate_override        => '||x_rw_cost_rate_override     );
 	             print_msg('p_burd_rt_miss_num_flag        => '||p_burd_rt_miss_num_flag     );
 	             print_msg('p_bl_etc_burden_rate           => '||p_bl_etc_burden_rate        );
 	             print_msg('p_bl_etc_burden_rate_override  => '||p_bl_etc_burden_rate_override       );
 	             print_msg('x_b_cost_rate                  => '||x_b_cost_rate       );
 	             print_msg('x_b_cost_rate_override         => '||x_b_cost_rate_override      );
 	             print_msg('p_bill_rt_miss_num_flag        => '||p_bill_rt_miss_num_flag     );
 	             print_msg('p_bl_etc_bill_rate             => '||p_bl_etc_bill_rate  );
 	             print_msg('p_bl_etc_bill_rate_override    => '||p_bl_etc_bill_rate_override );
 	             print_msg('x_bill_rate                    => '||x_bill_rate );
 	             print_msg('x_bill_rate_override               => '||x_bill_rate_override        );

 	          End If;
 	/* End of Bug fix:5726773 */

        /* Now open up the budget line cursor and follow the logic
         * if param passes value is fnd_api.g_miss_num then user purposely entered null value from UI or AMG
         * so null out the param.  if param passed value is null, the copy the value from budget lines
	 * so that no change is made from top if param passed value is not null, then retain the param value.
        */

	/* start of quantity param processing */
        IF NVL(p_Qty_miss_num_flag,'N') = 'Y' Then
        	x_total_quantity := NULL;
        Elsif x_total_quantity is NULL Then
           	IF g_calling_module <> 'FORECAST_GENERATION' Then  /* Bug fix:4211776 */
                	x_total_quantity := p_bl_quantity;
	   	Else
			x_total_quantity := nvl(x_total_quantity,0) + NVL(p_bl_init_quantity,0);
           	End If;
	Else
	   	IF g_calling_module <> 'FORECAST_GENERATION' Then  /* Bug fix:4211776 */
                	NULL; -- retain parameter value
           	Else
                	x_total_quantity := nvl(x_total_quantity,0) + NVL(p_bl_init_quantity,0);
           	End If;
	End If;

	/* start of raw cost param processing */
	IF NVL(p_Rw_miss_num_flag,'N') = 'Y' Then
                  x_total_raw_cost := 0;
        Elsif x_total_raw_cost is NULL Then
        	If p_txn_currency_override is NULL Then
        	   IF g_calling_module <> 'FORECAST_GENERATION' Then /* Bug fix:4211776 */
        		x_total_raw_cost := p_bl_txn_raw_cost;
		   Else
			x_total_raw_cost := NVL(x_total_raw_cost,0) + nvl(p_bl_txn_init_raw_cost,0);
		   End If;
        	END IF;
	Else
		If p_txn_currency_override is NULL Then
                   IF g_calling_module <> 'FORECAST_GENERATION' Then /* Bug fix:4211776 */
                        NULL;  -- retain the param value
                   Else
                        x_total_raw_cost := NVL(x_total_raw_cost,0) + nvl(p_bl_txn_init_raw_cost,0);
                   End If;
                END IF;
        End If;

	/* start of burden cost param processing */
        IF NVL(p_Br_miss_num_flag,'N') = 'Y' Then
            x_total_burdened_cost := 0;
        Elsif x_total_burdened_cost is NULL Then
        	If p_txn_currency_override is NULL  Then
        	   IF g_calling_module <> 'FORECAST_GENERATION' Then /* Bug fix:4211776 */
        		x_total_burdened_cost := p_bl_txn_burdened_cost;
		   Else
			x_total_burdened_cost := NVL(x_total_burdened_cost,0)+NVL(p_bl_txn_init_burdened_cost,0);
		   End If;
        	End If;
	Else
        	If p_txn_currency_override is NULL  Then
                   IF g_calling_module <> 'FORECAST_GENERATION' Then /* Bug fix:4211776 */
                        NULL; -- retain the param value
                   Else
                        x_total_burdened_cost := NVL(x_total_burdened_cost,0)+NVL(p_bl_txn_init_burdened_cost,0);
                   End If;
        	End If;
	End If;

	/* start of revenue param processing */
        IF NVL(p_Rv_miss_num_flag,'N') = 'Y' Then
        	x_total_revenue := 0;
        Elsif x_total_revenue is NULL Then
        	If p_txn_currency_override is NULL Then
        	   IF g_calling_module <> 'FORECAST_GENERATION' Then /* Bug fix:4211776 */
        		x_total_revenue := p_bl_txn_revenue;
		   Else
			x_total_revenue := NVL(x_total_revenue,0)+NVL(p_bl_txn_init_revenue,0);
        	   End If;
        	End If;
	Else
                If p_txn_currency_override is NULL Then
                   IF g_calling_module <> 'FORECAST_GENERATION' Then /* Bug fix:4211776 */
                        NULL; --retain param value
                   Else
                        x_total_revenue := NVL(x_total_revenue,0)+NVL(p_bl_txn_init_revenue,0);
                   End If;
                End If;
        End If;

	/* start of cost rate param processing */
	IF NVL(p_cost_rt_miss_num_flag,'N') = 'Y' Then
		x_raw_cost_rate := NULL;
	Elsif x_raw_cost_rate is NULL Then
		If p_txn_currency_override is NULL Then
        	  IF g_calling_module <> 'FORECAST_GENERATION' Then /* Bug fix:4211776 */
        	    /* Bug fix:4232221 x_raw_cost_rate := NVL(blrec.etc_cost_rate,blrec.txn_standard_cost_rate); */
        	    x_raw_cost_rate := p_bl_etc_cost_rate;
        	  End If;
        	Elsif (p_txn_currency_override is NOT NULL ) Then
        	--print_msg('Cost rate is passed but override cur exists so null out this and keep override cost rate');
        	    x_raw_cost_rate := NULL;
        	End IF;
	Else
                If p_txn_currency_override is NULL Then
                    NULL; -- retain param value
                Elsif (p_txn_currency_override is NOT NULL ) Then
                --print_msg('Cost rate is passed but override cur exists so null out this and keep override cost rate');
                    x_raw_cost_rate := NULL;
                End IF;
	End If;

	/* start of cost rate override param processing */
	IF NVL(p_cost_rt_miss_num_flag,'N') = 'Y' Then
                x_rw_cost_rate_override := NULL;
        Elsif x_rw_cost_rate_override is NULL Then
		x_rw_cost_rate_override := NULL;
	Else
		NULL; -- retain param value
        End IF;

	/* start of burden rate param processing */
	If NVL(p_burd_rt_miss_num_flag,'N') = 'Y' Then
                x_b_cost_rate := NULL;
        Elsif x_b_cost_rate is NULL Then
        	If p_txn_currency_override is NULL Then
        	   IF g_calling_module <> 'FORECAST_GENERATION' Then /* Bug fix:4211776 */
        	   /* Bug fix:4232221 x_b_cost_rate := NVL(blrec.etc_burden_rate,blrec.burden_cost_rate); */
        		x_b_cost_rate :=  p_bl_etc_burden_rate;
        	   End If;
		Elsif (p_txn_currency_override is NOT NULL ) Then
			x_b_cost_rate := NULL;
        	End If;
	Else
		If p_txn_currency_override is NULL Then
			NULL; -- retain param value
        	ElsIf (p_txn_currency_override is NOT NULL ) Then
        		print_msg('Burd Cost rate is passed but override cur exists so null out this rate');
			x_b_cost_rate := NULL;
		End If;
	End If;

	/* start of burden rate override param processing */
	If NVL(p_burd_rt_miss_num_flag,'N') = 'Y' Then
            	x_b_cost_rate_override := NULL;
        Elsif x_b_cost_rate_override is NULL Then
		x_b_cost_rate_override := NULL;
	Else
		NULL; -- retain the param value
        End If;

	/* start of bill rate param processing */
	IF NVL(p_bill_rt_miss_num_flag,'N') = 'Y' Then
               	x_bill_rate := NULL;

       	Elsif x_bill_rate is NULL Then
       		If p_txn_currency_override is NULL Then
       		  IF g_calling_module <> 'FORECAST_GENERATION' Then /* Bug fix:4211776 */
       		   /* Bug fix:4232221 x_bill_rate := NVL(blrec.etc_bill_rate,blrec.txn_standard_bill_rate);*/
       			x_bill_rate := p_bl_etc_bill_rate;
       		  End If;
       		Elsif (p_txn_currency_override is NOT NULL ) Then
       		  	print_msg('Bill rate is passed but override cur exists so null out this rate');
       			x_bill_rate := NULL;
		End If;
	Else
		If p_txn_currency_override is NULL Then
			NULL; --retain param value
		Elsif (p_txn_currency_override is NOT NULL ) Then
			x_bill_rate := NULL;
		End If;
	End If;


	/* start of bill rate override param processing */
	IF NVL(p_bill_rt_miss_num_flag,'N') = 'Y' Then
            	x_bill_rate_override := NULL;
	Elsif x_bill_rate_override is NULL Then
		x_bill_rate_override := NULL;
	Else
		NULL; -- retain the param value
        End IF;

     	/* BUG FIX:4211776 FORECAST GENERATION PROCESS CREATEs BUDGET LINES WITH ACTUALS = PLAN
	*PRIOR TO ETC START DATE. Then PASSES ETC VALUES to CALC API
	*(but calc api ALWAYS EXPECTS PLAN QTY/AMOUNTS FROM ALL FLOWS).
	*IN ORDER TO ACCOMODATE THE FORECAST GENERATION FLOW, ADD BACK THE ACTUAL FROM BL TO PARAM VALUES TO
	*ARRIVE AT THE PLAN QTY / AMOUNTS
	*/
        IF g_calling_module = 'FORECAST_GENERATION' Then
		If x_total_quantity = 0 then x_total_quantity := NULL; End if;
		If x_total_raw_cost = 0 then x_total_raw_cost := NULL; end if;
		If x_total_burdened_cost = 0 then x_total_burdened_cost := NULL; end if;
		If x_total_revenue = 0 then x_total_revenue := NULL; end if;
        END IF;

      	/* Bug fix:4343985 : Logic:
       	* 1.Always ensure that etc qty is +ve or zero
       	* 2.Plan quantity must be > or = Actual quantity
       	* 3.Plan quantity should not be zero when acutals exists
       	*/
       	/* Bug fix:5726773: The following condition is removed for enhancement support
	 * negative quantity spread
	 * IF NVL(p_delete_bl_flag,'N') <> 'Y' Then --{
	 * END IF; --}
	 *****End of bug fix:5726773 */
	--print_msg('End of  pre_process_param_values API');
EXCEPTION
	WHEN l_invalid_exception Then
		print_msg('exception occured inpre_process_param_values['||sqlcode||sqlerrm);
                x_return_status := 'E';

	WHEN OTHERS THEN
		print_msg('exception occured inpre_process_param_values['||sqlcode||sqlerrm);
		x_return_status := 'E';
		Raise;
END pre_process_param_values;

/* Bug fix:5309529: This API extends the IN param araays and bulk inserts into spread calc tmp
 * table. This avoids looping through plsql arrays just to extend the plsql table
 * Did performance test on pjperf instance. if the number of records in plsql table increases
 * the time gain is almost half of the original time.
 * Example:
 * Num#RAs      Old Code     New Code
 * --------------------------------------
 *  1698        1.52 sec     1.01 sec
 *  8574       13.23 sec     9.25 sec
 *  10206      15.69 sec    10.99 sec
 */
PROCEDURE insert_calcTmp_records
	  ( x_resource_assignment_tab       IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_delete_budget_lines_tab       IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_spread_amts_flag_tab          IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_txn_currency_code_tab         IN  OUT NOCOPY SYSTEM.pa_varchar2_15_tbl_type
                ,x_txn_currency_override_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_15_tbl_type
                ,x_total_qty_tab                 IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_addl_qty_tab                  IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_total_raw_cost_tab            IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_addl_raw_cost_tab             IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_total_burdened_cost_tab       IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_addl_burdened_cost_tab        IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_total_revenue_tab             IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_addl_revenue_tab              IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_raw_cost_rate_tab             IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_rw_cost_rate_override_tab     IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_b_cost_rate_tab               IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_b_cost_rate_override_tab      IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_bill_rate_tab                 IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_bill_rate_override_tab        IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_line_start_date_tab           IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_line_end_date_tab             IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_apply_progress_flag_tab       IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_spread_curve_id_old_tab       IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_spread_curve_id_new_tab       IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_sp_fixed_date_old_tab         IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_sp_fixed_date_new_tab         IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_plan_start_date_old_tab       IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_plan_start_date_new_tab       IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_plan_end_date_old_tab         IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
		,x_plan_end_date_new_tab         IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_re_spread_flag_tab            IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_sp_curve_change_flag_tab      IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_plan_dates_change_flag_tab    IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_spfix_date_flag_tab           IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_mfc_cost_change_flag_tab      IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_mfc_cost_type_id_old_tab      IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_mfc_cost_type_id_new_tab      IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
        	,x_rlm_id_change_flag_tab        IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
        	,x_plan_sdate_shrunk_flag_tab    IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_plan_edate_shrunk_flag_tab    IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_mfc_cost_refresh_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
        	,x_ra_in_multi_cur_flag_tab      IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
        	,x_quantity_changed_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_raw_cost_changed_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_cost_rate_changed_flag_tab    IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_burden_cost_changed_flag_tab  IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_burden_rate_changed_flag_tab  IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_rev_changed_flag_tab          IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_bill_rate_changed_flag_tab    IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_multcur_plan_start_date_tab   IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_multcur_plan_end_date_tab     IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_fp_task_billable_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_cost_rt_miss_num_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_burd_rt_miss_num_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_bill_rt_miss_num_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_Qty_miss_num_flag_tab         IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_Rw_miss_num_flag_tab          IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_Br_miss_num_flag_tab          IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_Rv_miss_num_flag_tab          IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_rev_only_entry_flag_tab       IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_return_status                 OUT NOCOPY VARCHAR2
                ,x_msg_data                      OUT NOCOPY varchar2
                ) IS

	CURSOR cur_validate IS
	SELECT tmp.resource_assignment_id
		,tmp.txn_currency_code
		,tmp.start_date
	FROM pa_fp_spread_calc_tmp tmp
	WHERE tmp.budget_version_id = g_budget_version_id
	AND   (tmp.start_date is NULL OR tmp.end_date is NULL);

	l_miss_num 	Number := fnd_api.g_miss_num;
	l_miss_char	Varchar2(1000) := fnd_api.g_miss_char;
	l_miss_date     Date := fnd_api.g_miss_date;
	l_numRows       Integer;


BEGIN
	x_return_status := 'S';
	x_msg_data := NULL;
	l_numRows := x_resource_assignment_tab.count;
	If l_numRows > 0 Then --{
		 --extend the tables where plsql tabs are not passed
	   	If x_delete_budget_lines_tab.count = 0 Then
			x_delete_budget_lines_tab.extend(l_numRows);
		End If;
                If x_spread_amts_flag_tab.count = 0 Then
			x_spread_amts_flag_tab.extend(l_numRows);
                End If;
                If x_txn_currency_code_tab.count = 0 Then
			x_txn_currency_code_tab.extend(l_numRows);
                End If;
                If x_txn_currency_override_tab.count = 0 Then
			x_txn_currency_override_tab.extend(l_numRows);
                End If;
                If x_total_qty_tab.count = 0 Then
			x_total_qty_tab.extend(l_numRows);
                End If;
                If x_addl_qty_tab.count = 0 Then
			x_addl_qty_tab.extend(l_numRows);
                End If;
                If x_total_raw_cost_tab.count = 0 Then
			x_total_raw_cost_tab.extend(l_numRows);
                End If;
                If x_addl_raw_cost_tab.count = 0 Then
			x_addl_raw_cost_tab.extend(l_numRows);
                End If;
                If x_total_burdened_cost_tab.count = 0 Then
			x_total_burdened_cost_tab.extend(l_numRows);
                End If;
                If x_addl_burdened_cost_tab.count = 0 Then
			x_addl_burdened_cost_tab.extend(l_numRows);
                End If;
                If x_total_revenue_tab.count = 0 Then
			x_total_revenue_tab.extend(l_numRows);
                End If;
                If x_addl_revenue_tab.count = 0 Then
			x_addl_revenue_tab.extend(l_numRows);
                End If;
                If x_raw_cost_rate_tab.count = 0 Then
			x_raw_cost_rate_tab.extend(l_numRows);
                End If;
                If x_rw_cost_rate_override_tab.count = 0 Then
			x_rw_cost_rate_override_tab.extend(l_numRows);
                End If;
                If x_b_cost_rate_tab.count = 0 Then
			x_b_cost_rate_tab.extend(l_numRows);
                End If;
                If x_b_cost_rate_override_tab.count = 0 Then
			x_b_cost_rate_override_tab.extend(l_numRows);
                End If;
                If x_bill_rate_tab.count = 0 Then
			x_bill_rate_tab.extend(l_numRows);
                End If;
                If x_bill_rate_override_tab.count = 0 Then
			x_bill_rate_override_tab.extend(l_numRows);
                End If;
                If x_line_start_date_tab.count = 0 Then
			x_line_start_date_tab.extend(l_numRows);
                End If;
                If x_line_end_date_tab.count = 0 Then
			x_line_end_date_tab.extend(l_numRows);
                End If;
                If x_apply_progress_flag_tab.count = 0 Then
			x_apply_progress_flag_tab.extend(l_numRows);
                End If;
                If x_spread_curve_id_old_tab.count = 0 Then
			x_spread_curve_id_old_tab.extend(l_numRows);
                End If;
                If x_spread_curve_id_new_tab.count = 0 Then
			x_spread_curve_id_new_tab.extend(l_numRows);
                End If;
                If x_sp_fixed_date_old_tab.count = 0 Then
			x_sp_fixed_date_old_tab.extend(l_numRows);
                End If;
                If x_sp_fixed_date_new_tab.count = 0 Then
			x_sp_fixed_date_new_tab.extend(l_numRows);
                End If;
                If x_plan_start_date_old_tab.count = 0 Then
			x_plan_start_date_old_tab.extend(l_numRows);
                End If;
                If x_plan_start_date_new_tab.count = 0 Then
			x_plan_start_date_new_tab.extend(l_numRows);
                End If;
                If x_plan_end_date_old_tab.count = 0 Then
			x_plan_end_date_old_tab.extend(l_numRows);
                End If;
                If x_plan_end_date_new_tab.count = 0 Then
			x_plan_end_date_new_tab.extend(l_numRows);
                End If;
                If x_re_spread_flag_tab.count = 0 Then
			x_re_spread_flag_tab.extend(l_numRows);
                End If;
                If x_sp_curve_change_flag_tab.count = 0 Then
			x_sp_curve_change_flag_tab.extend(l_numRows);
                End If;
                If x_plan_dates_change_flag_tab.count = 0 Then
			x_plan_dates_change_flag_tab.extend(l_numRows);
                End If;
                If x_spfix_date_flag_tab.count = 0 Then
			x_spfix_date_flag_tab.extend(l_numRows);
                End If;
		If x_mfc_cost_change_flag_tab.count = 0 Then
			x_mfc_cost_change_flag_tab.extend(l_numRows);
                End If;
                If x_mfc_cost_type_id_old_tab.count = 0 Then
			x_mfc_cost_type_id_old_tab.extend(l_numRows);
                End If;
                If x_mfc_cost_type_id_new_tab.count = 0 Then
			x_mfc_cost_type_id_new_tab.extend(l_numRows);
                End If;
                If x_rlm_id_change_flag_tab.count = 0 Then
			x_rlm_id_change_flag_tab.extend(l_numRows);
                End If;
                If x_fp_task_billable_flag_tab.count = 0 Then
			x_fp_task_billable_flag_tab.extend(l_numRows);
                End If;
                If x_cost_rt_miss_num_flag_tab.count = 0 Then
			x_cost_rt_miss_num_flag_tab.extend(l_numRows);
                End If;
                If x_burd_rt_miss_num_flag_tab.count = 0 Then
			x_burd_rt_miss_num_flag_tab.extend(l_numRows);
                End If;
                If x_bill_rt_miss_num_flag_tab.count = 0 Then
			x_bill_rt_miss_num_flag_tab.extend(l_numRows);
                End If;
                If x_Qty_miss_num_flag_tab.count = 0 Then
			x_Qty_miss_num_flag_tab.extend(l_numRows);
                End If;
                If x_Rw_miss_num_flag_tab.count = 0 Then
			x_Rw_miss_num_flag_tab.extend(l_numRows);
                End If;
                If x_Br_miss_num_flag_tab.count = 0 Then
			x_Br_miss_num_flag_tab.extend(l_numRows);
                End If;
                If x_Rv_miss_num_flag_tab.count = 0 Then
			x_Rv_miss_num_flag_tab.extend(l_numRows);
                End If;
	   If p_pa_debug_mode = 'Y' Then
	   print_msg(' Inserting records into spread calc tmp table');
	   End If;
           FORALL i IN x_resource_assignment_tab.FIRST .. x_resource_assignment_tab.LAST
                INSERT INTO pa_fp_spread_calc_tmp
                        (RESOURCE_ASSIGNMENT_ID --resource_assignment_id
                         ,DELETE_BL_FLAG          --delete_budget_lines_flag
                         ,SPREAD_AMTS_FLAG      --spread_amts_flag
                         ,TXN_CURRENCY_CODE     --txn_currency_code
                         ,TXN_CURR_CODE_OVERRIDE --txn_currency_override
                         ,QUANTITY              --total_qty
                         ,SYSTEM_REFERENCE_NUM1 --addl_qty
                         ,TXN_RAW_COST          --total_raw_cost
                         ,SYSTEM_REFERENCE_NUM2 --addl_raw_cost
                         ,TXN_BURDENED_COST     --total_burdened_cost
                         ,SYSTEM_REFERENCE_NUM3 --addl_burdened_cost
                         ,TXN_REVENUE           --total_revenue
                         ,SYSTEM_REFERENCE_NUM4 --addl_revenue
                         ,COST_RATE             --raw_cost_rate
                         ,COST_RATE_OVERRIDE    --rw_cost_rate_override
                         ,BURDEN_COST_RATE      --b_cost_rate
                         ,BURDEN_COST_RATE_OVERRIDE --b_cost_rate_override
                         ,BILL_RATE             --bill_rate
                         ,BILL_RATE_OVERRIDE    --bill_rate_override
                         ,START_DATE            --line_start_date
                         ,END_DATE              --line_end_date
                         ,APPLY_PROGRESS_FLAG   --apply_progress_flag
                         ,BUDGET_VERSION_ID     --budget_version_id
                         ,OLD_SPREAD_CURVE_ID   --x_spread_curve_id_old_tab
                         ,NEW_SPREAD_CURVE_ID   --x_spread_curve_id_new_tab
                         ,OLD_SP_FIX_DATE       --x_sp_fixed_date_old_tab
                         ,NEW_SP_FIX_DATE       --x_sp_fixed_date_new_tab
                         ,OLD_PLAN_START_DATE   --x_plan_start_date_old_tab
                         ,NEW_PLAN_START_DATE   --x_plan_start_date_new_tab
                         ,OLD_PLAN_END_DATE     --x_plan_end_date_old_tab
                         ,NEW_PLAN_END_DATE     --x_plan_end_date_new_tab
                         ,RE_SPREAD_AMTS_FLAG   --x_re_spread_flag_tab
                         ,SP_CURVE_CHANGE_FLAG  --x_sp_curve_change_flag_tab
                         ,PLAN_DATES_CHANGE_FLAG --x_plan_dates_change_flag_tab
                         ,SP_FIX_DATE_CHANGE_FLAG --x_spfix_date_flag_tab
                         ,MFC_COST_CHANGE_FLAG   --x_mfc_cost_change_flag_tab
                         ,OLD_MFC_COST_TYPE_ID   --x_mfc_cost_type_id_old_tab
                         ,NEW_MFC_COST_TYPE_ID   --x_mfc_cost_type_id_new_tab
             		 ,ETC_START_DATE
             		,PROJECT_CURRENCY_CODE
             		,PROJFUNC_CURRENCY_CODE
             		,RLM_ID_CHANGE_FLAG
             		,BUDGET_VERSION_TYPE
            		,BILLABLE_FLAG
			,COST_RATE_G_MISS_NUM_FLAG
			,BURDEN_RATE_G_MISS_NUM_FLAG
			,BILL_RATE_G_MISS_NUM_FLAG
			,QUANTITY_G_MISS_NUM_FLAG
			,RAW_COST_G_MISS_NUM_FLAG
			,BURDEN_COST_G_MISS_NUM_FLAG
			,REVENUE_G_MISS_NUM_FLAG
                        )
                VALUES (
                        x_resource_assignment_tab(i)
			,decode(NVL(g_wp_cost_changed_flag,'N'),'Y',decode(NVL(g_time_phase_changed_flag,'N'),'Y','Y')
                         ,decode(NVL(g_time_phase_changed_flag,'N'),'Y','Y'
			  ,decode(g_source_context,'RESOURCE_ASSIGNMENT','N'
			   ,decode(x_delete_budget_lines_tab(i),l_miss_char,'N',NULL,'N'
			    ,x_delete_budget_lines_tab(i)))))
                        ,decode(NVL(g_wp_cost_changed_flag,'N'),'Y'
 	                  ,decode(NVL(g_time_phase_changed_flag,'N'),'Y','Y','N')
 	                    ,decode(NVL(g_time_phase_changed_flag,'N'),'Y','Y','N'))
                        ,x_txn_currency_code_tab(i)
                        ,decode(x_txn_currency_override_tab(i),l_miss_char,NULL
			  ,NULL,NULL,x_txn_currency_code_tab(i),NULL,x_txn_currency_override_tab(i))
                        ,decode(x_total_qty_tab(i),l_miss_num,NULL,x_total_qty_tab(i))
                        ,NULL  --x_addl_qty_tab(i)
                        ,decode(x_total_raw_cost_tab(i),l_miss_num,0,x_total_raw_cost_tab(i))
                        ,NULL --x_addl_raw_cost_tab(i)
                        ,decode(x_total_burdened_cost_tab(i),l_miss_num,0,x_total_burdened_cost_tab(i))
                        ,NULL  --x_addl_burdened_cost_tab(i)
                        ,decode(x_total_revenue_tab(i),l_miss_num,0,x_total_revenue_tab(i))
                        ,NULL  --x_addl_revenue_tab(i)
                        ,decode(x_raw_cost_rate_tab(i),l_miss_num,NULL,x_raw_cost_rate_tab(i))
                        ,decode(x_rw_cost_rate_override_tab(i),l_miss_num,NULL,x_rw_cost_rate_override_tab(i))
                        ,decode(x_b_cost_rate_tab(i),l_miss_num,NULL,x_b_cost_rate_tab(i))
                        ,decode(x_b_cost_rate_override_tab(i),l_miss_num,NULL,x_b_cost_rate_override_tab(i))
                        ,decode(x_bill_rate_tab(i),l_miss_num,NULL,x_bill_rate_tab(i))
                        ,decode(x_bill_rate_override_tab(i),l_miss_num,NULL,x_bill_rate_override_tab(i))
                        ,decode(g_source_context,'RESOURCE_ASSIGNMENT',NULL
				,decode(x_line_start_date_tab(i),l_miss_date,NULL,x_line_start_date_tab(i)))
                        ,decode(g_source_context,'RESOURCE_ASSIGNMENT',NULL
				,decode(x_line_end_date_tab(i),l_miss_date,NULL,x_line_end_date_tab(i)))
                        ,NVL(g_apply_progress_flag,'N') --x_apply_progress_flag_tab(i)
                        ,g_budget_version_id
                        ,decode(x_spread_curve_id_old_tab(i),l_miss_num,NULL,x_spread_curve_id_old_tab(i))
                        ,decode(x_spread_curve_id_new_tab(i),l_miss_num,NULL,x_spread_curve_id_new_tab(i))
                        ,decode(x_sp_fixed_date_old_tab(i),l_miss_date,NULL,x_sp_fixed_date_old_tab(i))
                        ,decode(x_sp_fixed_date_new_tab(i),l_miss_date,NULL,x_sp_fixed_date_new_tab(i))
                        ,decode(x_plan_start_date_old_tab(i),l_miss_date,NULL,x_plan_start_date_old_tab(i))
                        ,decode(x_plan_start_date_new_tab(i),l_miss_date,NULL,x_plan_start_date_new_tab(i))
                        ,decode(x_plan_end_date_old_tab(i),l_miss_date,NULL,x_plan_end_date_old_tab(i))
                        ,decode(x_plan_end_date_new_tab(i),l_miss_date,NULL,x_plan_end_date_new_tab(i))
                        ,decode(x_re_spread_flag_tab(i),l_miss_char,'N',NULL,'N',x_re_spread_flag_tab(i))
                        ,decode(x_sp_curve_change_flag_tab(i),l_miss_char,'N',NULL,'N'
					,x_sp_curve_change_flag_tab(i))
                        ,decode(x_plan_dates_change_flag_tab(i),l_miss_char,'N',NULL,'N'
					,x_plan_dates_change_flag_tab(i))
                        ,decode(x_spfix_date_flag_tab(i),l_miss_char,'N',NULL,'N'
					,x_spfix_date_flag_tab(i))
                        ,decode(x_mfc_cost_change_flag_tab(i),l_miss_char,'N',NULL,'N'
					,x_mfc_cost_change_flag_tab(i))
                        ,decode(x_mfc_cost_type_id_old_tab(i),l_miss_num,NULL,x_mfc_cost_type_id_old_tab(i))
                        ,decode(x_mfc_cost_type_id_new_tab(i),l_miss_num,NULL,x_mfc_cost_type_id_new_tab(i))
            		,g_etc_start_date
            		,g_project_currency_code
            		,g_projfunc_currency_code
            		,decode(x_rlm_id_change_flag_tab(i),l_miss_char,'N',NULL,'N'
				,x_rlm_id_change_flag_tab(i))
            		,g_budget_version_type
            		,decode(x_fp_task_billable_flag_tab(i),l_miss_char,'D',NULL,'D'
				,x_fp_task_billable_flag_tab(i))
			,decode(x_rw_cost_rate_override_tab(i),l_miss_num,'Y'
				,decode(x_raw_cost_rate_tab(i),l_miss_num,'Y'
				,'N')) -- x_cost_rt_miss_num_flag_tab(i)
                	,decode(x_b_cost_rate_tab(i),l_miss_num,'Y'
                          	,decode(x_b_cost_rate_override_tab(i),l_miss_num,'Y'
				,'N'))  --x_burd_rt_miss_num_flag_tab(i)
                	,decode(x_bill_rate_tab(i),l_miss_num,'Y'
                        	,decode(x_bill_rate_override_tab(i),l_miss_num,'Y'
				,'N')) --x_bill_rt_miss_num_flag_tab(i)
			,decode(x_total_qty_tab(i),l_miss_num,'Y','N') --x_Qty_miss_num_flag_tab(i)
                	,decode(x_total_raw_cost_tab(i),l_miss_num,'Y','N') --x_Rw_miss_num_flag_tab(i)
                	,decode(x_total_burdened_cost_tab(i),l_miss_num,'Y','N') --x_Br_miss_num_flag_tab(i)
                	,decode(x_total_revenue_tab(i),l_miss_num,'Y','N') --x_Rv_miss_num_flag_tab(i)
              );
	     If p_pa_debug_mode = 'Y' Then
		print_msg('Number of records inserted into calctemp:['||sql%rowcount||']');
	     End If;
	     IF  g_source_context  = 'BUDGET_LINE' THEN
                FOR i IN cur_validate LOOP
                pa_utils.add_message
                ( p_app_short_name => 'PA'
                ,p_msg_name       => 'PA_FP_CALC_BL_DATES_REQ'
                ,p_token1         => 'BUDGET_VERSION_ID'
                ,p_value1         =>  g_budget_version_id
                ,p_token2         => 'PROJECT_ID'
                ,p_value2         =>  g_project_id
                ,p_token3         =>  'RESOURCE_ASSIGNMENT'
                ,p_value3         =>  i.resource_assignment_id
                ,p_token4         =>  'TXN_CURRENCY'
                ,p_value4         =>  i.txn_currency_code
                );
                x_return_status := 'E';
		END LOOP;
       	     END IF;

	     /* bug fix: 5726773: For non-timephased records generation process passes 0,0,1 as rate
 	      * overrides to indicate that revenue only records exists in cost and revenue together version
 	      * During generation process calculate skips most of the code which resets rates, rate baseflags, qty
 	      * etc.. In order to minimize the code impact, the following code is added
 	      * Logic: populate the fp_gen_rate_tmp table (which is populated by generation process in all flows
 	      * except for non-timephase) with rate overrides as 0,0,1 and use these rates to stamp on the budget
 	      * lines before calling rate api. so that rate api donot derive rawcost and burden cost
 	      */
 	                 IF g_calling_module in ('BUDGET_GENERATION','FORECAST_GENERATION')
 	                    and perdRec.time_phased_code = 'N' and g_refresh_rates_flag = 'N'
 	                    and g_budget_version_type = 'ALL'
 	                    and g_source_context = 'RESOURCE_ASSIGNMENT' Then

 	                         INSERT INTO pa_fp_gen_rate_tmp fptmp
 	                         (fptmp.target_res_asg_id
 	                         ,fptmp.txn_currency_code
 	                         ,fptmp.raw_cost_rate
 	                         ,fptmp.burdened_cost_rate
 	                         ,fptmp.revenue_bill_rate
 	                         )
 	                         SELECT tmp.resource_assignment_id
 	                                 ,tmp.txn_currency_code
 	                                 ,tmp.cost_rate_override
 	                                 ,tmp.burden_cost_rate_override
 	                                 ,tmp.bill_rate_override
 	                         FROM pa_fp_spread_calc_tmp tmp
 	                         WHERE tmp.budget_version_id = g_budget_version_id
 	                         AND tmp.cost_rate_override = 0
 	                         AND tmp.burden_cost_rate_override = 0
 	                         AND tmp.bill_rate_override = 1
 	                         AND NOT EXISTS (select null
 	                                         from pa_fp_gen_rate_tmp fptmp1
 	                                         where fptmp1.target_res_asg_id = tmp.resource_assignment_id
 	                                         and fptmp1.txn_currency_code = tmp.txn_currency_code
 	                                         );
 	                         print_msg('Number of records inserted into pa_fp_gen_rate_tmp['||sql%rowcount||']');
 	     End If;
	End If; --}

exception
	when others then
		print_msg('Exception occured in insert_calcTmp_records['||sqlerrm||sqlcode||']');
		x_return_status := 'U';
		raise;

END insert_calcTmp_records;

PROCEDURE Compare_bdgtLine_Values
           (p_budget_version_id             IN  Number
           ,p_budget_version_type           IN  Varchar2
           ,p_source_context                IN  pa_fp_res_assignments_tmp.source_context%TYPE
           ,p_apply_progress_flag           IN  Varchar2 DEFAULT 'N'
       ,x_return_status                 OUT NOCOPY Varchar2
           ,x_msg_data                      OUT NOCOPY Varchar2
           ) IS

    CURSOR cur_bl_vals IS
    SELECT tmp2.quantity        bl_quantity
               ,tmp2.txn_raw_cost   bl_txn_raw_cost
               ,tmp2.txn_burdened_cost  bl_txn_burdened_cost
               ,tmp2.txn_revenue    bl_txn_revenue
               ,tmp2.init_quantity  bl_init_quantity
               ,tmp2.txn_init_raw_cost  bl_txn_init_raw_cost
               ,tmp2.txn_init_burdened_cost bl_txn_init_burdened_cost
               ,tmp2.txn_init_revenue    bl_txn_init_revenue
               ,tmp2.cost_rate       bl_cost_rate
               ,tmp2.cost_rate_override  bl_cost_rate_override
               ,tmp2.burden_cost_rate    bl_burden_cost_rate
               ,tmp2.burden_cost_rate_override  bl_burden_cost_rate_override
               ,tmp2.bill_rate      bl_bill_rate
               ,tmp2.bill_rate_override bl_bill_rate_override
           ,tmp.quantity
               ,tmp.txn_raw_cost
               ,tmp.txn_burdened_cost
               ,tmp.txn_revenue
               ,tmp.cost_rate
               ,tmp.cost_rate_override
               ,tmp.burden_cost_rate
               ,tmp.burden_cost_rate_override
               ,tmp.bill_rate
               ,tmp.bill_rate_override
           ,tmp.txn_curr_code_override
           ,tmp.rowid
           ,tmp.resource_assignment_id
           ,tmp.txn_currency_code
           ,nvl(ra.rate_based_flag,'N') rate_based_flag
	    /*Bug fix:  */
	   ,tmp2.system_reference_num1         	bl_zero_null_quantity
           ,tmp2.system_reference_num2         	bl_zero_null_rawcost
           ,tmp2.system_reference_num3     	bl_zero_null_burdencost
           ,tmp2.system_reference_num4          bl_zero_null_revenue
	   ,tmp2.system_reference_var1  	avg_zero_null_cost_rate
           ,tmp2.system_reference_var2  	avg_zero_null_burden_rate
           ,tmp2.system_reference_var3  	avg_zero_null_bill_rate
	   ,NVL(ra.resource_rate_based_flag,'N') resource_rate_based_flag
	   ,tmp2.bill_markup_percentage
	   ,NVL(tmp.cost_rate_g_miss_num_flag,'N') cost_rate_g_miss_num_flag
	   ,NVL(tmp.burden_rate_g_miss_num_flag,'N') burden_rate_g_miss_num_flag
	   ,NVL(tmp.bill_rate_g_miss_num_flag,'N') bill_rate_g_miss_num_flag
	   ,nvl(tmp.raw_cost_g_miss_num_flag,'N') raw_cost_g_miss_num_flag
	   ,nvl(tmp.burden_cost_g_miss_num_flag,'N') burden_cost_g_miss_num_flag
	   ,nvl(tmp.revenue_g_miss_num_flag,'N') revenue_g_miss_num_flag
	   ,nvl(tmp.quantity_g_miss_num_flag,'N') quantity_g_miss_num_flag
	   ,rlm.unit_of_measure resource_uom
	   ,tmp.start_date
	   ,tmp.end_date
	   ,NVL(tmp.delete_bl_flag,'N') delete_bl_flag
    FROM pa_fp_spread_calc_tmp tmp
        ,pa_fp_spread_calc_tmp2 tmp2
        ,pa_resource_assignments ra
	,pa_resource_list_members rlm
    WHERE tmp.budget_version_id = p_budget_version_id
    AND   ra.resource_assignment_id = tmp.resource_assignment_id
    AND   rlm.resource_list_member_id = ra.resource_list_member_id
    AND   tmp.resource_assignment_id = tmp2.resource_assignment_id
    AND   tmp.txn_currency_code = tmp2.txn_currency_code
    AND   ((p_source_context = 'BUDGET_LINE'
          and tmp.start_date = tmp2.start_date)
          OR
          p_source_context <> 'BUDGET_LINE'
         );

    l_cntr                  INTEGER;
    l_res_Asgn_Id_Tab   pa_plsql_datatypes.NumTabTyp;
    l_txn_cur_code_Tab  pa_plsql_datatypes.Char50TabTyp;
    l_Start_date_tab    pa_plsql_datatypes.DateTabTyp;
    l_end_date_tab      pa_plsql_datatypes.DateTabTyp;
    l_rowid_tab     pa_plsql_datatypes.rowIdTabTyp;
    l_quantity_ch_flag_tab      pa_plsql_datatypes.Char1TabTyp;
    l_rawCost_ch_flag_tab      pa_plsql_datatypes.Char1TabTyp;
    l_burdenCost_ch_flag_tab      pa_plsql_datatypes.Char1TabTyp;
    l_Revnue_ch_flag_tab      pa_plsql_datatypes.Char1TabTyp;
    l_costRt_ch_flag_tab      pa_plsql_datatypes.Char1TabTyp;
    l_burdRt_ch_flag_tab      pa_plsql_datatypes.Char1TabTyp;
    l_billRt_ch_flag_tab      pa_plsql_datatypes.Char1TabTyp;

    l_resource_assingment_id_tab    pa_plsql_datatypes.NumTabTyp;
    l_txn_currency_code_tab         pa_plsql_datatypes.Char50TabTyp;
    l_bl_Start_date_tab             pa_plsql_datatypes.DateTabTyp;
    l_bl_quantity_tab       pa_plsql_datatypes.NumTabTyp;
        l_bl_txn_raw_cost_tab       pa_plsql_datatypes.NumTabTyp;
        l_bl_txn_burden_cost_tab    pa_plsql_datatypes.NumTabTyp;
        l_bl_txn_revenue_tab        pa_plsql_datatypes.NumTabTyp;
        l_bl_init_quantity_tab      pa_plsql_datatypes.NumTabTyp;
        l_bl_txn_init_raw_cost_tab  pa_plsql_datatypes.NumTabTyp;
        l_bl_txn_init_burden_cost_tab   pa_plsql_datatypes.NumTabTyp;
        l_bl_txn_init_revenue_tab   pa_plsql_datatypes.NumTabTyp;
        l_bl_cost_rate_tab      pa_plsql_datatypes.NumTabTyp;
        l_bl_cost_rate_override_tab pa_plsql_datatypes.NumTabTyp;
        l_bl_burden_cost_rate_tab   pa_plsql_datatypes.NumTabTyp;
        l_bl_burden_rate_override_tab   pa_plsql_datatypes.NumTabTyp;
        l_bl_bill_rate_tab      pa_plsql_datatypes.NumTabTyp;
        l_bl_bill_rate_override_tab pa_plsql_datatypes.NumTabTyp;
    l_rate_based_flag_tab           pa_plsql_datatypes.Char10TabTyp;
    l_res_rate_based_flag_tab           pa_plsql_datatypes.Char10TabTyp;
	l_bl_txn_markup_tab		pa_plsql_datatypes.NumTabTyp;
	l_costRt_g_miss_num_flag_tab   pa_plsql_datatypes.Char1TabTyp;
        l_burdRt_g_miss_num_flag_tab   pa_plsql_datatypes.Char1TabTyp;
        l_revRt_g_miss_num_flag_tab    pa_plsql_datatypes.Char1TabTyp;
	l_rwCost_g_miss_num_flag_tab   pa_plsql_datatypes.Char1TabTyp;
	l_brdCost_g_miss_num_flag_tab   pa_plsql_datatypes.Char1TabTyp;
	l_revenue_g_miss_num_flag_tab   pa_plsql_datatypes.Char1TabTyp;
	l_resource_uom_tab		pa_plsql_datatypes.Char50TabTyp;

	l_quantity_tab			pa_plsql_datatypes.NumTabTyp;
	l_raw_cost_tab			pa_plsql_datatypes.NumTabTyp;
	l_burdened_cost_tab		pa_plsql_datatypes.NumTabTyp;
	l_revenue_tab			pa_plsql_datatypes.NumTabTyp;
	l_raw_cost_rate_tab		pa_plsql_datatypes.NumTabTyp;
	l_rw_cost_rate_override_tab	pa_plsql_datatypes.NumTabTyp;
	l_b_cost_rate_tab		pa_plsql_datatypes.NumTabTyp;
	l_b_cost_rate_override_tab	pa_plsql_datatypes.NumTabTyp;
	l_bill_rate_tab			pa_plsql_datatypes.NumTabTyp;
	l_bill_rate_override_tab	pa_plsql_datatypes.NumTabTyp;

	-- Bug fix:5726773
 	l_negQty_Change_flag_tab        pa_plsql_datatypes.Char1TabTyp;
 	l_negRawCst_Change_flag_tab     pa_plsql_datatypes.Char1TabTyp;
 	l_neg_BurdCst_Change_flag_tab   pa_plsql_datatypes.Char1TabTyp;
 	l_neg_revChange_flag_tab        pa_plsql_datatypes.Char1TabTyp;

	l_return_status 	Varchar2(1);
	skip_record		EXCEPTION;
BEGIN
    x_return_status := 'S';
    l_return_status := 'S';
    x_msg_data := NULL;
    IF P_PA_DEBUG_MODE = 'Y' Then
    print_msg('Entered Compare_bdgtLine_Values API');
    End If;
        DELETE FROM pa_fp_spread_calc_tmp2
        WHERE budget_version_id = p_budget_version_id;
        l_res_Asgn_Id_Tab.delete;
        l_txn_cur_code_Tab.delete;
        l_start_date_tab.delete;
                l_end_date_tab.delete;
        l_rowid_tab.delete;
            l_quantity_ch_flag_tab.delete;
            l_rawCost_ch_flag_tab.delete;
            l_burdenCost_ch_flag_tab.delete;
            l_Revnue_ch_flag_tab.delete;
            l_costRt_ch_flag_tab.delete;
            l_burdRt_ch_flag_tab.delete;
            l_billRt_ch_flag_tab.delete;
        SELECT  tmp.resource_assignment_id
            ,tmp.txn_currency_code
            ,decode(p_source_context,'BUDGET_LINE',tmp.start_date,to_date(null))
            ,decode(p_source_context,'BUDGET_LINE',tmp.end_date,to_date(null))
        BULK COLLECT INTO
            l_res_Asgn_Id_Tab
            ,l_txn_cur_code_Tab
            ,l_start_date_tab
                        ,l_end_date_tab
        FROM pa_fp_spread_calc_tmp tmp
        WHERE tmp.budget_version_id = p_budget_version_id;

        IF l_res_Asgn_Id_Tab.COUNT > 0 Then  --{
	   IF P_PA_DEBUG_MODE = 'Y' Then
           print_msg('NumOf Lines inserted['||l_res_Asgn_Id_Tab.count||']');
	   End If;
           FORALL i IN  l_res_Asgn_Id_Tab.FIRST .. l_res_Asgn_Id_Tab.LAST
            INSERT INTO pa_fp_spread_calc_tmp2
                (BUDGET_VERSION_ID
                ,BUDGET_VERSION_TYPE
                ,RESOURCE_ASSIGNMENT_ID
                ,TXN_CURRENCY_CODE
                ,START_DATE
                ,END_DATE
                )
            VALUES (p_budget_version_id
                ,p_budget_version_type
                ,l_res_Asgn_Id_Tab(i)
                ,l_txn_cur_code_Tab(i)
                ,l_start_date_tab(i)
                ,l_end_date_tab(i)
                );
	 IF p_source_context = 'RESOURCE_ASSIGNMENT' Then --{
	        IF P_PA_DEBUG_MODE = 'Y' Then
		print_msg('Inserting records into sprdcalctmp2 for resource assignment context');
		End If;
		FORALL i IN l_res_Asgn_Id_Tab.FIRST .. l_res_Asgn_Id_Tab.LAST
		UPDATE /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP2_N1) */ pa_fp_spread_calc_tmp2 tmp
            	SET ( tmp.quantity
                ,tmp.txn_raw_cost
                ,tmp.txn_burdened_cost
                ,tmp.txn_revenue
                ,tmp.init_quantity
                ,tmp.txn_init_raw_cost
                ,tmp.txn_init_burdened_cost
                ,tmp.txn_init_revenue
                ,tmp.cost_rate
                ,tmp.cost_rate_override
                ,tmp.burden_cost_rate
                ,tmp.burden_cost_rate_override
                ,tmp.bill_rate
                ,tmp.bill_rate_override
                ,tmp.system_reference_num1  --quantity
                ,tmp.system_reference_num2  --txnRaw
                ,tmp.system_reference_num3  --txnburd
                ,tmp.system_reference_num4  --txnrev
		,tmp.system_reference_var1  --avg_zero_null_cost_rate
                ,tmp.system_reference_var2  --avg_zero_null_burden_rate
                ,tmp.system_reference_var3  --avg_zero_null_bill_rate
		) =
		(SELECT decode(rtx.total_quantity,0,null,rtx.total_quantity) quantity
                ,decode(rtx.total_txn_raw_cost,0,NULL,rtx.total_txn_raw_cost) txn_raw_cost
                ,decode(rtx.total_txn_burdened_cost,0,NULL,rtx.total_txn_burdened_cost) txn_burdened_cost
                ,decode(rtx.total_txn_revenue,0,NULL,rtx.total_txn_revenue) txn_revenue
                ,decode(rtx.total_init_quantity,0,NULL,rtx.total_init_quantity) init_quantity
                ,decode(rtx.total_txn_init_raw_cost,0,NULL,rtx.total_txn_init_raw_cost) init_raw_cost
                ,decode(rtx.total_txn_init_burdened_cost,0,NULL,rtx.total_txn_init_burdened_cost) init_burdened_cost
                ,decode(rtx.total_txn_init_revenue,0,NULL,rtx.total_txn_init_revenue) init_revenue
                ,rtx.TXN_ETC_RAW_COST_RATE              etc_cost_rate
                ,rtx.TXN_RAW_COST_RATE_OVERRIDE         etc_cost_rate_override
                ,rtx.TXN_ETC_BURDEN_COST_RATE           etc_burden_rate
                ,rtx.TXN_BURDEN_COST_RATE_OVERRIDE      etc_burden_rate_override
                ,rtx.TXN_ETC_BILL_RATE                  etc_bill_rate
                ,rtx.TXN_BILL_RATE_OVERRIDE             etc_bill_rate_override
                ,rtx.total_quantity                     bl_zero_null_quantity
                ,rtx.total_txn_raw_cost                 bl_zero_null_rawcost
                ,rtx.total_txn_burdened_cost            bl_zero_null_burdencost
                ,rtx.total_txn_revenue                  bl_zero_null_revenue
	        ,rtx.TXN_RAW_COST_RATE_OVERRIDE
		,rtx.TXN_BURDEN_COST_RATE_OVERRIDE
		,rtx.TXN_BILL_RATE_OVERRIDE
        	FROM pa_resource_asgn_curr rtx
        	WHERE rtx.resource_assignment_id = l_res_Asgn_Id_Tab(i)
        	AND  rtx.txn_currency_code = l_txn_cur_code_Tab(i)
		)
	     WHERE tmp.resource_assignment_id = l_res_Asgn_Id_Tab(i)
             AND  tmp.txn_currency_code = l_txn_cur_code_Tab(i);

		/* update table with txn markup percentage */
		UPDATE /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP2_N1) */ pa_fp_spread_calc_tmp2 tmp
		SET tmp.bill_markup_percentage = (select AVG(bl.txn_markup_percent)
						  from pa_budget_lines bl
						  where bl.resource_assignment_id = tmp.resource_assignment_id
						  and  bl.txn_currency_code = tmp.txn_currency_code
						 )
		WHERE tmp.budget_version_id = p_budget_version_id
		AND EXISTS ( select null
			     from pa_budget_lines bl1
                             where bl1.resource_assignment_id = tmp.resource_assignment_id
                             and  bl1.txn_currency_code = tmp.txn_currency_code
			   );

	 ELSE
	    IF P_PA_DEBUG_MODE = 'Y' Then
            print_msg('Updating calcTmp2 with budgetLine values');
	    End If;
            FORALL i IN l_res_Asgn_Id_Tab.FIRST .. l_res_Asgn_Id_Tab.LAST
                UPDATE  /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP2_N1) */ pa_fp_spread_calc_tmp2 tmp
                SET (tmp.avg_cost_rate_override
                    ,tmp.avg_burden_rate_override
                    ,tmp.avg_bill_rate_override
		    /* Bug fix:4693839 */
		    ,tmp.system_reference_var1  --avg_zero_null_cost_rate
		    ,tmp.system_reference_var2  --avg_zero_null_burden_rate
		    ,tmp.system_reference_var3  --avg_zero_null_bill_rate
		    ,tmp.bill_markup_percentage
		    ) =
                    (SELECT /*+ INDEX(BLAVGRT PA_BUDGET_LINES_U1) */
				AVG(DECODE((nvl(blavgrt.quantity,0) - nvl(blavgrt.init_quantity,0)),0
                                                ,NULL,blavgrt.txn_cost_rate_override)) avg_txn_cost_rate_override
                                         ,AVG(DECODE((nvl(blavgrt.quantity,0) - nvl(blavgrt.init_quantity,0)),0
                                                ,NULL,blavgrt.burden_cost_rate_override))   avg_burden_cost_rate_override
                                         ,AVG(DECODE((nvl(blavgrt.quantity,0) - nvl(blavgrt.init_quantity,0)),0
                                                ,NULL,blavgrt.txn_bill_rate_override)) avg_txn_bill_rate_override
				     	,AVG(NVL(blavgrt.txn_cost_rate_override,blavgrt.txn_standard_cost_rate))
				    	,AVG(NVL(blavgrt.burden_cost_rate_override,blavgrt.burden_cost_rate))
					,AVG(NVL(blavgrt.txn_bill_rate_override,blavgrt.txn_standard_bill_rate))
					,AVG(blavgrt.txn_markup_percent)
                                    FROM pa_budget_lines blavgrt
                                    WHERE blavgrt.budget_version_id = p_budget_version_id
                                    AND  blavgrt.resource_assignment_id = tmp.resource_assignment_id
                                    AND blavgrt.txn_currency_code      = tmp.txn_currency_code
                                    AND ( (tmp.start_date is NULL AND tmp.end_date is NULL )
                                        OR
                                        (tmp.start_date is NOT NULL AND tmp.end_date is NOT NULL
                                        AND blavgrt.start_date BETWEEN tmp.start_date AND tmp.end_date))
                                        )
                /* Perf fix: WHERE tmp.budget_version_id = p_budget_version_id to avoid N2 index */
                WHERE tmp.resource_assignment_id = l_res_Asgn_Id_Tab(i)
                AND   tmp.txn_currency_code = l_txn_cur_code_Tab(i)
                AND   ((tmp.start_date is NOT NULL
                    and tmp.start_date = l_start_date_tab(i))
                      OR tmp.start_date is NULL
                      );

           FORALL i IN  l_res_Asgn_Id_Tab.FIRST .. l_res_Asgn_Id_Tab.LAST
            UPDATE /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP2_N1) */ pa_fp_spread_calc_tmp2 tmp
            SET (tmp.quantity
                ,tmp.txn_raw_cost
                ,tmp.txn_burdened_cost
                ,tmp.txn_revenue
                ,tmp.init_quantity
                ,tmp.txn_init_raw_cost
                ,tmp.txn_init_burdened_cost
                ,tmp.txn_init_revenue
                ,tmp.cost_rate
                ,tmp.cost_rate_override
                ,tmp.burden_cost_rate
                ,tmp.burden_cost_rate_override
                ,tmp.bill_rate
                ,tmp.bill_rate_override
		/* Bug fix:4693839 */
		,tmp.system_reference_num1  --quantity
		,tmp.system_reference_num2  --txnRaw
		,tmp.system_reference_num3  --txnburd
		,tmp.system_reference_num4  --txnrev
		) =
               ( SELECT /*+ INDEX(BL PA_BUDGET_LINES_U1) */
                decode(sum(bl.quantity),0,NULL,sum(bl.quantity)) --quantity
                ,decode(sum(bl.txn_raw_cost),0,NULL,sum(bl.txn_raw_cost))  --txn_raw_cost
                ,decode(sum(bl.txn_burdened_cost),0,NULL,sum(bl.txn_burdened_cost)) --txn_burdened_cost
                ,decode(sum(bl.txn_revenue),0,NULL,sum(bl.txn_revenue)) --txn_revenue
                ,decode(sum(bl.init_quantity),0,NULL,sum(bl.init_quantity)) --init_quantity
                ,decode(sum(bl.txn_init_raw_cost),0,NULL,sum(bl.txn_init_raw_cost)) --init_raw_cost
                ,decode(sum(bl.txn_init_burdened_cost),0,NULL,sum(bl.txn_init_burdened_cost)) --init_burdened_cost
                ,decode(sum(bl.txn_init_revenue),0,NULL,sum(bl.txn_init_revenue)) --init_revenue
                ,(sum(( decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                         ,decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,null
                         ,((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)) * nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)))))))
                    / DECODE((sum(decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                                ,decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,null
                       		  ,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0))))))
			      ,0,NULL,
			       	(sum(decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                                ,decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,null
                                  ,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0))))))
				)
                  ) --etc_cost_rate
                ,(sum(decode(tmp.avg_cost_rate_override,NULL,NULL
                               ,decode((nvl(bl.quantity,0) - nvl(bl.init_quantity,0)),0,NULL
                                ,decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,NULL
                                     ,((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)) * nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)))))))
                    / DECODE((sum(decode(tmp.avg_cost_rate_override,NULL,NULL
                            ,decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,NULL
                              ,decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,null
                    	        ,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0)))))))
			 ,0,NULL,
			  (sum(decode(tmp.avg_cost_rate_override,NULL,NULL
                            ,decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,NULL
                              ,decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,null
                                ,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0)))))))
			 )
                 ) --etc_cost_rate_override
                ,(sum(( decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                       ,decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,null
                           ,((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)) * nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)))))))
                   / DECODE((sum(decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                        ,decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,null
                    	  ,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0))))))
			,0,NULL,
			(sum(decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                        ,decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,null
                          ,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0))))))
		   	)
                 ) --etc_burden_rate
                ,(sum(decode(tmp.avg_burden_rate_override,NULL,NULL
                     ,decode((nvl(bl.quantity,0) - nvl(bl.init_quantity,0)),0,NULL
                       ,decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,NULL
                          ,((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)) * nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)))))))
                    / DECODE((sum(decode(tmp.avg_burden_rate_override,NULL,NULL
                          ,decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,NULL
                            ,decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,NULL
                         	,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0)))))))
			,0,NULL,
			(sum(decode(tmp.avg_burden_rate_override,NULL,NULL
                          ,decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,NULL
                            ,decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,NULL
                                ,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0)))))))
			)
                 ) --etc_burden_rate_override
                ,(sum((decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                       ,decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0,null
                         ,((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)) * nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)))))))
                   / DECODE((sum(decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                       ,decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0,null
                    	  ,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0))))))
			,0,NULL,
			(sum(decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                       ,decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0,null
                          ,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0))))))
			)
                 ) --etc_bill_rate
                ,(sum(decode(tmp.avg_bill_rate_override,NULL,NULL
                      , decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,NULL
                         ,decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0,NULL
                            ,((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)) * nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)))))))
                   / DECODE((sum(decode(tmp.avg_bill_rate_override,NULL,NULL
                        ,decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,NULL
                          ,decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0,null
                      		,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0)))))))
			,0,NULL,
			(sum(decode(tmp.avg_bill_rate_override,NULL,NULL
                        ,decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,NULL
                          ,decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0,null
                                ,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0)))))))
			)
                ) --etc_bill_rate_override
		/* Bug fix:4693839 Currently all the UI page shows null instead of zeros, and when they pass to param value
		 * will be passed null, representing no change, but some other API like AMG etc, may pass zero in param value.
	         * In order to avoid changing all the calling api, this api is modified to handle nulls and zeros carefully */
		,SUM(tmp.quantity)	 	-- bl_zero_null_quantity
                ,SUM(tmp.txn_raw_cost)	   	-- bl_zero_null_rawcost
                ,SUM(tmp.txn_burdened_cost)	-- bl_zero_null_burdencost
                ,SUM(tmp.txn_revenue)		-- bl_zero_null_revenue
                FROM pa_budget_lines bl
                WHERE bl.budget_version_id = p_budget_version_id
                AND  bl.resource_assignment_id = tmp.resource_assignment_id
                AND bl.txn_currency_code      = tmp.txn_currency_code
                AND ( (tmp.start_date is NULL AND tmp.end_date is NULL )
                            OR
                           (tmp.start_date is NOT NULL AND tmp.end_date is NOT NULL
                            AND bl.start_date BETWEEN tmp.start_date AND tmp.end_date)
                       )
                )
      	/* Perf fix: WHERE tmp.budget_version_id = p_budget_version_id to avoid N2 index */
      	WHERE tmp.resource_assignment_id = l_res_Asgn_Id_Tab(i)
      	AND   tmp.txn_currency_code = l_txn_cur_code_Tab(i)
      	AND   ((tmp.start_date is NOT NULL
                  and tmp.start_date = l_start_date_tab(i))
                OR tmp.start_date is NULL
              );
            --print_msg('Number of budgtLines got updated['||l_res_Asgn_Id_Tab.count||']');
	END IF; --}
            /** added this for debug testing
            FOR tmp in (select * from pa_fp_spread_calc_tmp2 where budget_version_id = p_budget_version_id) LOOP
            print_msg('Res['||tmp.resource_assignment_id||']blTxncur['||tmp.txn_currency_code||'blQty['||tmp.quantity||']');
            print_msg('RawCst['||tmp.txn_raw_cost||']BdCst['||tmp.txn_burdened_cost||']Rev['||tmp.txn_revenue||']');
            print_msg('cstRt['||tmp.cost_rate||']cstRtOvr['||tmp.cost_rate_override||']BdRt['||tmp.burden_cost_rate||']');
            print_msg('BdRtOv['||tmp.burden_cost_rate_override||']BilRt['||tmp.bill_rate||']BilRtOvr['||tmp.bill_rate_override||']');
	    print_msg('init_quantity['||tmp.init_quantity||']txn_init_raw_cost['||tmp.txn_init_raw_cost||']');
            END LOOP;
            **/
            l_cntr := 0;
            l_resource_assingment_id_tab.delete;
		l_txn_currency_code_tab.delete;
                l_bl_Start_date_tab.delete;
                l_bl_quantity_tab.delete;
                l_bl_txn_raw_cost_tab.delete;
                l_bl_txn_burden_cost_tab.delete;
                l_bl_txn_revenue_tab.delete;
                l_bl_init_quantity_tab.delete;
                l_bl_txn_init_raw_cost_tab.delete;
                l_bl_txn_init_burden_cost_tab.delete;
                l_bl_txn_init_revenue_tab.delete;
                l_bl_cost_rate_tab.delete;
                l_bl_cost_rate_override_tab.delete;
                l_bl_burden_cost_rate_tab.delete;
                l_bl_burden_rate_override_tab.delete;
                l_bl_bill_rate_tab.delete;
                l_bl_bill_rate_override_tab.delete;
            	l_rate_based_flag_tab.delete;
		l_res_rate_based_flag_tab.delete;
		l_bl_txn_markup_tab.delete;
		l_costRt_g_miss_num_flag_tab.delete;
                l_burdRt_g_miss_num_flag_tab.delete;
                l_revRt_g_miss_num_flag_tab.delete;
		l_rwCost_g_miss_num_flag_tab.delete;
        	l_brdCost_g_miss_num_flag_tab.delete;
        	l_revenue_g_miss_num_flag_tab.delete;
	        l_resource_uom_tab.delete;
		l_quantity_tab.delete;
        	l_raw_cost_tab.delete;
        	l_burdened_cost_tab.delete;
        	l_revenue_tab.delete;
        	l_raw_cost_rate_tab.delete;
        	l_rw_cost_rate_override_tab.delete;
        	l_b_cost_rate_tab.delete;
        	l_b_cost_rate_override_tab.delete;
        	l_bill_rate_tab.delete;
        	l_bill_rate_override_tab.delete;
		--bug fix:5726773
 	        l_negQty_Change_flag_tab.delete;
 	        l_negRawCst_Change_flag_tab.delete;
 	        l_neg_BurdCst_Change_flag_tab.delete;
 	        l_neg_revChange_flag_tab.delete;

            FOR i IN cur_bl_vals LOOP
		BEGIN --{
                l_cntr := l_cntr +1;
                l_rowid_tab(l_cntr) := i.rowid;
                        l_quantity_ch_flag_tab(l_cntr)  := 'N';
                        l_rawCost_ch_flag_tab(l_cntr)  := 'N';
                        l_burdenCost_ch_flag_tab(l_cntr)  := 'N';
                        l_Revnue_ch_flag_tab(l_cntr)  := 'N';
                        l_costRt_ch_flag_tab(l_cntr)  := 'N';
                        l_burdRt_ch_flag_tab(l_cntr)  := 'N';
                        l_billRt_ch_flag_tab(l_cntr)  := 'N';
                l_resource_assingment_id_tab(l_cntr)    := i.resource_assignment_id;
                            l_txn_currency_code_tab(l_cntr)     := i.txn_currency_code;
			l_resource_uom_tab(l_cntr)    := i.resource_uom;
                            l_bl_quantity_tab(l_cntr)       := i.bl_quantity;
                            l_bl_txn_raw_cost_tab(l_cntr)       := i.bl_txn_raw_cost;
                            l_bl_txn_burden_cost_tab(l_cntr)    := i.bl_txn_burdened_cost;
                            l_bl_txn_revenue_tab(l_cntr)        := i.bl_txn_revenue;
                            l_bl_init_quantity_tab(l_cntr)      := i.bl_init_quantity;
                            l_bl_txn_init_raw_cost_tab(l_cntr)      := i.bl_txn_init_raw_cost;
                            l_bl_txn_init_burden_cost_tab(l_cntr)   := i.bl_txn_init_burdened_cost;
                            l_bl_txn_init_revenue_tab(l_cntr)   := i.bl_txn_init_revenue;
                            l_bl_cost_rate_tab(l_cntr)          := i.bl_cost_rate;
                            l_bl_cost_rate_override_tab(l_cntr)     := i.bl_cost_rate_override;
                            l_bl_burden_cost_rate_tab(l_cntr)   := i.bl_burden_cost_rate;
                            l_bl_burden_rate_override_tab(l_cntr)   := i.bl_burden_cost_rate_override;
                            l_bl_bill_rate_tab(l_cntr)          := i.bl_bill_rate;
                            l_bl_bill_rate_override_tab(l_cntr)     := i.bl_bill_rate_override;
                l_rate_based_flag_tab(l_cntr)       := i.rate_based_flag;
                l_res_rate_based_flag_tab(l_cntr)       := i.resource_rate_based_flag;
		l_bl_txn_markup_tab(l_cntr)       := i.bill_markup_percentage;
		l_costRt_g_miss_num_flag_tab(l_cntr) := i.cost_rate_g_miss_num_flag;
                l_burdRt_g_miss_num_flag_tab(l_cntr) := i.burden_rate_g_miss_num_flag;
                l_revRt_g_miss_num_flag_tab(l_cntr)  := i.bill_rate_g_miss_num_flag;
		l_rwCost_g_miss_num_flag_tab(l_cntr)  := i.raw_cost_g_miss_num_flag;
                l_brdCost_g_miss_num_flag_tab(l_cntr)  := i.burden_cost_g_miss_num_flag;
                l_revenue_g_miss_num_flag_tab(l_cntr)  := i.revenue_g_miss_num_flag;
		-- Bug fix:5726773
 	        l_negQty_Change_flag_tab(l_cntr)            := 'N';
 	        l_negRawCst_Change_flag_tab(l_cntr)     := 'N';
 	        l_neg_BurdCst_Change_flag_tab(l_cntr)        := 'N';
 	        l_neg_revChange_flag_tab(l_cntr)            := 'N';


		/*Perf Impr:5309529 Added this and removed muliple execution of AvgblRec cursor for param validation*/
		pre_process_param_values
        	(p_budget_version_id            => p_budget_version_id
        	,p_resource_assignment          => i.resource_assignment_id
        	,p_txn_currency_code            => i.txn_currency_code
        	,p_txn_currency_override        => i.txn_curr_code_override
        	,p_bdgt_line_sDate              => i.start_date
        	,p_bdgt_line_eDate              => i.end_date
        	,p_delete_bl_flag               => i.delete_bl_flag
        	,p_Qty_miss_num_flag            => i.quantity_g_miss_num_flag
        	,p_bl_quantity                  => i.bl_quantity
        	,p_bl_init_quantity             => i.bl_init_quantity
        	,x_total_quantity               => i.quantity
        	,p_Rw_miss_num_flag             => i.raw_cost_g_miss_num_flag
        	,p_bl_txn_raw_cost              => i.bl_txn_raw_cost
        	,p_bl_txn_init_raw_cost         => i.bl_txn_init_raw_cost
        	,x_total_raw_cost               => i.txn_raw_cost
        	,p_Br_miss_num_flag             => i.burden_cost_g_miss_num_flag
        	,p_bl_txn_burdened_cost         => i.bl_txn_burdened_cost
        	,p_bl_txn_init_burdened_cost    => i.bl_txn_init_burdened_cost
        	,x_total_burdened_cost          => i.txn_burdened_cost
        	,p_Rv_miss_num_flag             => i.revenue_g_miss_num_flag
        	,p_bl_txn_revenue               => i.bl_txn_revenue
        	,p_bl_txn_init_revenue          => i.bl_txn_init_revenue
        	,x_total_revenue                => i.txn_revenue
        	,p_cost_rt_miss_num_flag        => i.cost_rate_g_miss_num_flag
        	,p_bl_etc_cost_rate             => i.bl_cost_rate
        	,p_bl_etc_cost_rate_override    => i.bl_cost_rate_override
        	,x_raw_cost_rate                => i.cost_rate
        	,x_rw_cost_rate_override        => i.cost_rate_override
        	,p_burd_rt_miss_num_flag        => i.burden_rate_g_miss_num_flag
        	,p_bl_etc_burden_rate           => i.bl_burden_cost_rate
        	,p_bl_etc_burden_rate_override  => i.bl_burden_cost_rate_override
        	,x_b_cost_rate                  => i.burden_cost_rate
        	,x_b_cost_rate_override         => i.burden_cost_rate_override
        	,p_bill_rt_miss_num_flag        => i.bill_rate_g_miss_num_flag
        	,p_bl_etc_bill_rate             => i.bl_bill_rate
        	,p_bl_etc_bill_rate_override    => i.bl_bill_rate_override
        	,x_bill_rate                    => i.bill_rate
        	,x_bill_rate_override           => i.bill_rate_override
        	,x_return_status                => l_return_status
        	);

		If NVL(l_return_status,'S') <> 'S' Then
			x_return_status := l_return_status;
			Raise skip_record;
		End If;
		l_quantity_tab(l_cntr)  		:= i.quantity;
                l_raw_cost_tab(l_cntr)  		:= i.txn_raw_cost;
                l_burdened_cost_tab(l_cntr)  		:= i.txn_burdened_cost;
                l_revenue_tab(l_cntr)  			:= i.txn_revenue;
                l_raw_cost_rate_tab(l_cntr)  		:= i.cost_rate;
                l_rw_cost_rate_override_tab(l_cntr)  	:= i.cost_rate_override;
                l_b_cost_rate_tab(l_cntr)  		:= i.burden_cost_rate;
                l_b_cost_rate_override_tab(l_cntr)  	:= i.burden_cost_rate_override;
                l_bill_rate_tab(l_cntr)  		:= i.bill_rate;
                l_bill_rate_override_tab(l_cntr)  	:= i.bill_rate_override;
		/* end of Perf Impr:5309529 */

		If g_wp_version_flag = 'Y' Then
                  If ((Nvl(i.quantity,0) <> NVL(i.bl_quantity,0)) OR
	            (i.quantity = 0 AND i.bl_zero_null_quantity is NULL)) Then /* Bug fix:4693839 */
                    l_quantity_ch_flag_tab(l_cntr)  := 'Y';
                  End If;

		Else
		  If g_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION') and i.resource_rate_based_flag = 'N' Then
			/* ignore change of quantity for non-rate base resources */
			l_quantity_ch_flag_tab(l_cntr)  := 'N';
		  Else
		     If ((Nvl(i.quantity,0) <> NVL(i.bl_quantity,0)) OR
                    	(i.quantity = 0 AND i.bl_zero_null_quantity is NULL)) Then /* Bug fix:4693839 */
                    	 l_quantity_ch_flag_tab(l_cntr)  := 'Y';
		     End If;
                  /*
             Bug 6429285
             Below if condition will handle a corner case
             If a rate based resource is added as non rate based resource assignment
             in pa_resource_asgn_curr and pa_budget_lines quantity will be populated
             as raw_cost and display_quantity will be null.Now if we want to enter
             the quantity same as raw cost (i.e existing quantity) the above if condition will fail because
             the user entered quantity is same as what is alreay existing*/

             -- Added condition and i.quantity <> '' as part of fix 7704110
             /* Bug 8871025 : skkoppul commented the following condition
             If (i.quantity is not null and i.quantity <> '' and i.resource_rate_based_flag = 'Y' and i.rate_based_flag = 'N') Then
                    l_quantity_ch_flag_tab(l_cntr)  := 'Y';
             END If;
             Bug 8871025 : skkoppul end of commented code */
             --End 6429285
                  End If;
		End if;

		/* Bug fix:5726773: when quantity is changed from +ve to -ve or -ve to +ve then
 	          * initialize the flags. Later in the spread api. place the additional quantity in
 	          * in the last existing period. Refer to TAD for detail architecture
 	          * Logic: Example shows when to initialize the flags
 	          *    ExistingDB value  paramValue   Result
 	          *  1.          -10         20          Y
 	          *  2.          100         -100        Y
 	          *  3.          100         150         N
 	          *  4.          0           100         N
 	          *  5.          0           -100        N
 	          *  6.          10          0           N
 	          *  7.          -10         0           N
 	        */
 	        If l_quantity_ch_flag_tab(l_cntr) = 'Y' Then
 	            If nvl(i.bl_zero_null_quantity,0) <> 0 AND Nvl(i.quantity,0) <> 0 Then
 	                   If sign(nvl(i.bl_zero_null_quantity,0)) <> sign(Nvl(i.quantity,0)) Then
 	                        l_negQty_Change_flag_tab(l_cntr)        := 'Y';
 	                   End If;
 	            End If;
 	        End If;
 	        /* end of bug fix:5726773 */

                If ((NVL(i.txn_raw_cost,0) <> NVL(i.bl_txn_raw_cost,0))
		    OR (i.txn_raw_cost = 0 AND i.bl_zero_null_rawcost is NULL ))  Then /* Bug fix:4693839 */
                   /* Bug fix:4293020: Changing the quantity and currency for Non-rate base resource is nulling out the quantity
                    * Reason: the below flag setting to y makes the cost is changed and precedence rules will copy the
                    * null costs to quantity.
                    * fix: When override currency is passed, set the flag based on the user passed amounts in the param.
                    * donot retain the costs from the budget lines.
                    */
                    If (i.txn_curr_code_override is NOT NULL AND NVL(i.txn_raw_cost,0) = 0) Then
                    l_rawCost_ch_flag_tab(l_cntr) := 'N';
                    Else
                    l_rawCost_ch_flag_tab(l_cntr) := 'Y';
                    End If;
                End If;

		/* Bug fix:5726773: */
 	            If l_rawCost_ch_flag_tab(l_cntr) = 'Y' Then
 	                If nvl(i.bl_zero_null_rawcost,0) <> 0 AND Nvl(i.txn_raw_cost,0) <> 0 Then
 	                     If sign(nvl(i.bl_zero_null_rawcost,0)) <> sign(Nvl(i.txn_raw_cost,0)) Then
 	                         l_negRawCst_Change_flag_tab(l_cntr)    := 'Y';
 	                    End If;
 	              End If;
 	            End If;
 	        /* end of bug fix:5726773 */

                IF ((nvl(i.txn_burdened_cost,0) <> nvl(i.bl_txn_burdened_cost,0))
		    OR (i.txn_burdened_cost = 0 AND i.bl_zero_null_burdencost is NULL )) Then /* Bug fix:4693839 */
                    /* bug fix:4293020 */
                    If (i.txn_curr_code_override is NOT NULL AND nvl(i.txn_burdened_cost,0) = 0) Then
                    l_burdenCost_ch_flag_tab(l_cntr) := 'N';
                    Else
                    l_burdenCost_ch_flag_tab(l_cntr) := 'Y';
                    End If;
                End If;

		 /* Bug fix:5726773: */
 	             If l_burdenCost_ch_flag_tab(l_cntr) = 'Y' Then
 	                 If nvl(i.bl_zero_null_burdencost,0) <> 0 AND Nvl(i.txn_burdened_cost,0) <> 0 Then
 	                      If sign(nvl(i.bl_zero_null_burdencost,0)) <> sign(Nvl(i.txn_burdened_cost,0)) Then
 	                          l_neg_BurdCst_Change_flag_tab(l_cntr)    := 'Y';
 	                      End If;
 	                End If;
 	             End If;
 	         /* end of bug fix:5726773 */

                IF ((nvl(i.txn_revenue,0) <> nvl(i.bl_txn_revenue,0))
		    OR ( i.txn_revenue = 0 AND i.bl_zero_null_revenue is NULL )) Then /* Bug fix:4693839 */
                    /* bug fix:4293020 */
                    If (i.txn_curr_code_override is NOT NULL AND nvl(i.txn_revenue,0) = 0) Then
                    	l_Revnue_ch_flag_tab(l_cntr) := 'N';
                    Else
                    	l_Revnue_ch_flag_tab(l_cntr) := 'Y';
                    End If;
                End If;

		/* Bug fix:5726773: */
 	            If l_Revnue_ch_flag_tab(l_cntr) = 'Y' Then
 	                If nvl(i.bl_zero_null_revenue,0) <> 0 AND Nvl(i.txn_revenue,0) <> 0 Then
 	                     If sign(nvl(i.bl_zero_null_revenue,0)) <> sign(Nvl(i.txn_revenue,0)) Then
 	                          l_neg_revChange_flag_tab(l_cntr)    := 'Y';
 	                     End If;
 	               End If;
 	            End If;
 	       /* end of bug fix:5726773 */

                /*** Bug fix:4297663 : While comparing the nulls should be handled properly.Add NVLs **/
                If p_source_context = 'BUDGET_LINE' Then
		  If ( NVL(i.cost_rate_override,NVL(i.cost_rate,0)) <>
                     	nvl(i.bl_cost_rate_override,NVL(i.bl_cost_rate,0))
                     OR (i.cost_rate = 0 AND i.avg_zero_null_cost_rate is NULL) /* Bug fix:4693839 */
                     OR (i.cost_rate_override = 0 AND i.avg_zero_null_cost_rate is NULL)) Then
			  print_msg('Setting the cost rate changed flag to Y');
                           l_costRt_ch_flag_tab(l_cntr) := 'Y';
		  End If;
		Else -- with new entity changes compare only the rate overrides, as all the calling apis passes
		     -- rate overrides only
		  If i.resource_rate_based_flag = 'Y'
		     AND ( NVL(i.cost_rate_override,nvl(i.bl_cost_rate_override,0)) <> nvl(i.bl_cost_rate_override,0)
                     OR (i.cost_rate_override = 0 AND i.avg_zero_null_cost_rate is NULL)) Then
			If i.rate_based_flag = 'N' Then
			   if l_quantity_ch_flag_tab(l_cntr) = 'N' then
				l_costRt_ch_flag_tab(l_cntr) := 'N';
			   else
				l_costRt_ch_flag_tab(l_cntr) := 'Y';
			   End If;
			Else
                           l_costRt_ch_flag_tab(l_cntr) := 'Y';
			End If;
		  Else
			l_costRt_ch_flag_tab(l_cntr) := 'N';
                  End If;
                End If;

                If p_source_context = 'BUDGET_LINE' Then
		   If (( NVL(i.burden_cost_rate_override,NVL(i.burden_cost_rate,0)) <>
                         NVL(i.bl_burden_cost_rate_override,NVL(i.bl_burden_cost_rate,0)))
		      OR ( i.burden_cost_rate = 0 AND i.avg_zero_null_burden_rate is NULL ) /* Bug fix:4693839 */
		      OR ( i.burden_cost_rate_override = 0 AND i.avg_zero_null_burden_rate is NULL )) Then
                           l_burdRt_ch_flag_tab(l_cntr)  := 'Y';
		   End If;
		Else
		  If g_wp_version_flag = 'Y' Then
		     If (( NVL(i.burden_cost_rate_override,NVL(i.bl_burden_cost_rate_override,0)) <>
                         NVL(i.bl_burden_cost_rate_override,0))
                        OR ( i.burden_cost_rate_override = 0 AND i.avg_zero_null_burden_rate is NULL )) Then
                           l_burdRt_ch_flag_tab(l_cntr)  := 'Y';
		     End If;
		  Else
		     If i.resource_rate_based_flag = 'Y'
			AND (( NVL(i.burden_cost_rate_override,NVL(i.bl_burden_cost_rate_override,0)) <>
                         NVL(i.bl_burden_cost_rate_override,0))
                         OR ( i.burden_cost_rate_override = 0 AND i.avg_zero_null_burden_rate is NULL )) Then
			l_burdRt_ch_flag_tab(l_cntr)  := 'Y';
		     Else
			l_burdRt_ch_flag_tab(l_cntr)  := 'N';
		     End If;
		  End If;
                End If;

                If p_source_context = 'BUDGET_LINE' Then
		   If ((NVL(i.bill_rate_override,NVL(i.bill_rate,0)) <>
                         nvl (i.bl_bill_rate_override,NVL(i.bl_bill_rate,0)))
		     OR (i.bill_rate = 0 AND i.avg_zero_null_bill_rate is NULL ) /* Bug fix:4693839 */
		     OR (i.bill_rate_override = 0 AND i.avg_zero_null_bill_rate is NULL )) Then
                           l_billRt_ch_flag_tab(l_cntr) := 'Y';
		   End If;
		Else
		   If i.resource_rate_based_flag = 'Y'
		     AND ((NVL(i.bill_rate_override,NVL(i.bl_bill_rate_override,0)) <>
                         nvl (i.bl_bill_rate_override,0))
                     OR (i.bill_rate_override = 0 AND i.avg_zero_null_bill_rate is NULL )) Then
                           l_billRt_ch_flag_tab(l_cntr) := 'Y';
		   Else
			l_billRt_ch_flag_tab(l_cntr) := 'N';
                   End If;
                End If;

                IF i.txn_curr_code_override is NOT NULL Then
                    If i.cost_rate_override is NOT NULL Then
                        l_costRt_ch_flag_tab(l_cntr) := 'Y';
                    End If;
                    If i.burden_cost_rate_override is NOT NULL Then
                        l_burdRt_ch_flag_tab(l_cntr)  := 'Y';
                    End If;
                    If i.bill_rate_override is NOT NULL Then
                        l_billRt_ch_flag_tab(l_cntr) := 'Y';
                    End If;
                END IF;
		--print_msg('G_MissNumFlgs:Cst['||i.cost_rate_g_miss_num_flag||']');
		--print_msg('Burd['||i.burden_rate_g_miss_num_flag||']Bil['||i.bill_rate_g_miss_num_flag||']');

	        If g_wp_version_flag = 'Y' Then
		  IF i.rate_based_flag = 'Y' and i.cost_rate_g_miss_num_flag = 'Y' Then
			l_costRt_ch_flag_tab(l_cntr) := 'Y';
		  End If;

		  IF i.burden_rate_g_miss_num_flag = 'Y' Then
                        l_burdRt_ch_flag_tab(l_cntr) := 'Y';
                  End If;
		End If;

		/* handling g miss nums for rates */
		If g_wp_version_flag = 'N' Then --{
		  If i.rate_based_flag = 'Y' Then
		      If NVL(l_rawCost_ch_flag_tab(l_cntr),'N') = 'Y'
			 and l_quantity_ch_flag_tab(l_cntr) = 'Y' Then
			 i.cost_rate_g_miss_num_flag := 'N';
			 l_costRt_g_miss_num_flag_tab(l_cntr) := 'N';
			 l_costRt_ch_flag_tab(l_cntr) := 'N';
		      Elsif NVL(l_rawCost_ch_flag_tab(l_cntr),'N') = 'Y'
			  and i.cost_rate_g_miss_num_flag = 'Y' Then
			 i.cost_rate_g_miss_num_flag := 'N';
                         l_costRt_g_miss_num_flag_tab(l_cntr) := 'N';
                         l_costRt_ch_flag_tab(l_cntr) := 'N';
                      ElsIF i.cost_rate_g_miss_num_flag = 'Y' Then
                        l_costRt_ch_flag_tab(l_cntr) := 'Y';
                      End If;

		    If NVL(l_burdenCost_ch_flag_tab(l_cntr),'N') = 'Y'
			and i.burden_rate_g_miss_num_flag = 'Y' Then
			i.burden_rate_g_miss_num_flag := 'N';
			l_burdRt_ch_flag_tab(l_cntr) := 'Y';
			l_burdRt_g_miss_num_flag_tab(l_cntr) := 'N';
                    ElsIF i.burden_rate_g_miss_num_flag = 'Y' Then
                        l_burdRt_ch_flag_tab(l_cntr) := 'Y';
                    End If;

		    If NVL(l_Revnue_ch_flag_tab(l_cntr),'N') = 'Y'
			and i.bill_rate_g_miss_num_flag = 'Y' Then
			i.bill_rate_g_miss_num_flag := 'N';
			l_billRt_ch_flag_tab(l_cntr) := 'N';
			l_revRt_g_miss_num_flag_tab(l_cntr) := 'N';
		    ElsIF i.bill_rate_g_miss_num_flag = 'Y' Then
			print_msg('setting bill rate change flag to Y due to g_miss_num');
                        l_billRt_ch_flag_tab(l_cntr) := 'Y';
                    End If;

		  Else
		     If i.resource_rate_based_flag = 'Y' AND i.rate_based_flag = 'N'  then
			If NVL(l_quantity_ch_flag_tab(l_cntr),'N') = 'Y' Then
				IF i.cost_rate_g_miss_num_flag = 'Y' Then
                        		l_costRt_ch_flag_tab(l_cntr) := 'Y';
                    		End If;
                    		IF i.burden_rate_g_miss_num_flag = 'Y' Then
                        		l_burdRt_ch_flag_tab(l_cntr) := 'Y';
                    		End If;
                    		IF i.bill_rate_g_miss_num_flag = 'Y' Then
                        		l_billRt_ch_flag_tab(l_cntr) := 'Y';
                    		End If;
		        Else
				l_costRt_ch_flag_tab(l_cntr) := 'N';
				l_burdRt_ch_flag_tab(l_cntr) := 'N';
				l_billRt_ch_flag_tab(l_cntr) := 'N';
			   	l_costRt_g_miss_num_flag_tab(l_cntr) := 'N';
			   	l_burdRt_g_miss_num_flag_tab(l_cntr) := 'N';
			   	l_revRt_g_miss_num_flag_tab(l_cntr) := 'N';
			End If;
		      Elsif i.resource_rate_based_flag = 'N' AND i.rate_based_flag = 'N' Then
				l_costRt_ch_flag_tab(l_cntr) := 'N';
                                l_burdRt_ch_flag_tab(l_cntr) := 'N';
                                l_billRt_ch_flag_tab(l_cntr) := 'N';
				l_costRt_g_miss_num_flag_tab(l_cntr) := 'N';
                                l_burdRt_g_miss_num_flag_tab(l_cntr) := 'N';
                                l_revRt_g_miss_num_flag_tab(l_cntr) := 'N';
		      End If;
		  End If;
		End If; --}
		/* handling g miss nums for the amounts */
	--print_msg('corrected G_MissNumFlgs:Cst['||l_costRt_g_miss_num_flag_tab(l_cntr)||']');
	--print_msg('Burd['||l_burdRt_g_miss_num_flag_tab(l_cntr)||']Bil['||l_revRt_g_miss_num_flag_tab(l_cntr)||']');
	  	EXCEPTION
			WHEN skip_record THEN
				NULL;
		END; --}
            END LOOP;

            IF NVL(x_return_status,'S') = 'S' AND l_rowid_tab.COUNT > 0 Then
		IF P_PA_DEBUG_MODE = 'Y' Then
                print_msg('setting the Changed Flags NumofRowsUpd['||l_rowid_tab.COUNT||']');
		End If;
		--/** added this for debug testing
		for i IN l_rowid_tab.FIRST .. l_rowid_tab.LAST loop
		print_msg('Raid['||l_resource_assingment_id_tab(i)||']TxnCur['||l_txn_currency_code_tab(i)||']');
		print_msg('QtyFlag['||l_quantity_ch_flag_tab(i)||']CstFlg['||l_rawCost_ch_flag_tab(i)||']');
		print_msg('CstRtFlg['||l_costRt_ch_flag_tab(i)||']');
		print_msg('BdFlg['||l_burdenCost_ch_flag_tab(i)||']BdRtFlg['||l_burdRt_ch_flag_tab(i)||']');
		print_msg('Rev['||l_Revnue_ch_flag_tab(i)||']BilRtFlg['||l_billRt_ch_flag_tab(i)||']');
		end loop;
		--*/

                FORALL i IN l_rowid_tab.FIRST .. l_rowid_tab.LAST
                   UPDATE  pa_fp_spread_calc_tmp tmp
                   SET  tmp.QUANTITY_CHANGED_FLAG      = NVL(l_quantity_ch_flag_tab(i),'N')
                    ,tmp.COST_RATE_CHANGED_FLAG   = NVL(l_costRt_ch_flag_tab(i),'N')
                    ,tmp.BURDEN_RATE_CHANGED_FLAG = NVL(l_burdRt_ch_flag_tab(i),'N')
                    ,tmp.BILL_RATE_CHANGED_FLAG   = NVL(l_billRt_ch_flag_tab(i),'N')
                    ,tmp.RAW_COST_CHANGED_FLAG    = NVL(l_rawCost_ch_flag_tab(i),'N')
                    ,tmp.BURDEN_COST_CHANGED_FLAG = NVL(l_burdenCost_ch_flag_tab(i),'N')
                    ,tmp.REVENUE_CHANGED_FLAG     = NVL(l_Revnue_ch_flag_tab(i),'N')
		    ,tmp.QUANTITY                 = decode(NVL(l_quantity_ch_flag_tab(i),'N'),'Y'
							,l_quantity_tab(i),l_bl_quantity_tab(i))
                    ,tmp.BL_QUANTITY          = l_bl_quantity_tab(i)
                    ,tmp.BL_TXN_RAW_COST      = l_bl_txn_raw_cost_tab(i)
                    ,tmp.BL_TXN_BURDENED_COST     = l_bl_txn_burden_cost_tab(i)
                    ,tmp.BL_TXN_REVENUE           = l_bl_txn_revenue_tab(i)
                    ,tmp.BL_TXN_INIT_RAW_COST     = l_bl_txn_init_raw_cost_tab(i)
                    ,tmp.BL_TXN_INIT_BURDENED_COST = l_bl_txn_init_burden_cost_tab(i)
                    ,tmp.BL_TXN_INIT_REVENUE      =l_bl_txn_init_revenue_tab(i)
                    ,tmp.BL_INIT_QUANTITY     = l_bl_init_quantity_tab(i)
                    ,tmp.BL_COST_RATE         = l_bl_cost_rate_tab(i)
                    ,tmp.BL_COST_RATE_OVERRIDE    = l_bl_cost_rate_override_tab(i)
                    ,tmp.BL_BURDEN_COST_RATE      = l_bl_burden_cost_rate_tab(i)
                    ,tmp.BL_BURDEN_COST_RATE_OVERRIDE = l_bl_burden_rate_override_tab(i)
                    ,tmp.BL_BILL_RATE          = l_bl_bill_rate_tab(i)
                    ,tmp.BL_BILL_RATE_OVERRIDE     = l_bl_bill_rate_override_tab(i)
                    /* Bug fix:4293020 : For rate base resource retain the param value. for non-rate base
                     * resource: hard code the cost rate 1 and bill rate to 1 based on the version type
                     * Reason: the rates cannot be changed for non-rate base resource
                    ,tmp.COST_RATE_OVERRIDE        = decode(l_rate_based_flag_tab(i),'Y',tmp.COST_RATE_OVERRIDE
                                           ,decode(g_budget_version_type,'COST',nvl(tmp.COST_RATE_OVERRIDE,1)
                                          ,'ALL',nvl(tmp.COST_RATE_OVERRIDE,1),tmp.COST_RATE_OVERRIDE))
                    ,tmp.BILL_RATE_OVERRIDE        = decode(l_rate_based_flag_tab(i),'Y',tmp.BILL_RATE_OVERRIDE
                                          ,decode(g_budget_version_type,'REVENUE',nvl(tmp.BILL_RATE_OVERRIDE,1)
                                         ,tmp.BILL_RATE_OVERRIDE))
                    **/
                    ,tmp.COST_RATE_OVERRIDE = decode(l_costRt_g_miss_num_flag_tab(i),'Y',NULL
					,decode(NVL(l_costRt_ch_flag_tab(i),'N'),'N',NULL
					,decode(l_rate_based_flag_tab(i),'Y',l_rw_cost_rate_override_tab(i)
					,decode(l_res_rate_based_flag_tab(i),'Y'
						,l_rw_cost_rate_override_tab(i)
						,decode(l_bl_cost_rate_override_tab(i),0,0,1)))))
                    ,tmp.BILL_RATE_OVERRIDE = decode(l_revRt_g_miss_num_flag_tab(i),'Y',NULL
					,decode(NVL(l_billRt_ch_flag_tab(i),'N'),'N',NULL
					,decode(l_rate_based_flag_tab(i),'Y',l_bill_rate_override_tab(i)
                                        ,decode(g_budget_version_type,'REVENUE'
					,decode(l_res_rate_based_flag_tab(i),'Y',l_bill_rate_override_tab(i),1)
						,'ALL',l_bill_rate_override_tab(i)
						,l_bill_rate_override_tab(i)))))
		    ,tmp.BILL_MARKUP_PERCENTAGE   = decode(l_revRt_g_miss_num_flag_tab(i),'Y',NULL,l_bl_txn_markup_tab(i))
		    ,tmp.burden_cost_rate_override  = decode(l_burdRt_g_miss_num_flag_tab(i),'Y',NULL
						        ,decode(NVL(l_burdRt_ch_flag_tab(i),'N'),'N',NULL
							   ,l_b_cost_rate_override_tab(i)))
		    ,tmp.cost_rate_g_miss_num_flag  = l_costRt_g_miss_num_flag_tab(i)
                    ,tmp.burden_rate_g_miss_num_flag = l_burdRt_g_miss_num_flag_tab(i)
                    ,tmp.bill_rate_g_miss_num_flag = l_revRt_g_miss_num_flag_tab(i)
		    ,tmp.rate_based_flag	= l_rate_based_flag_tab(i)
		    ,tmp.resource_rate_based_flag = l_res_rate_based_flag_tab(i)
		    ,tmp.resource_uom	= l_resource_uom_tab(i)
		    /* added for perf impr: removed loop and execution of cursor */
                    ,tmp.txn_raw_cost = l_raw_cost_tab(i)
                    ,tmp.txn_burdened_cost = l_burdened_cost_tab(i)
                    ,tmp.txn_revenue = l_revenue_tab(i)
                    ,tmp.cost_rate = l_raw_cost_rate_tab(i)
                    ,tmp.burden_cost_rate = l_b_cost_rate_tab(i)
                    ,tmp.bill_rate = l_bill_rate_tab(i)
		    /* bug fix: 5726773 */
 	            ,tmp.NEG_QUANTITY_CHANGE_FLAG  = l_negQty_Change_flag_tab(i)
 	            ,tmp.NEG_RAWCOST_CHANGE_FLAG  = l_negRawCst_Change_flag_tab(i)
 	            ,tmp.NEG_BURDEN_CHANGE_FALG =  l_neg_BurdCst_Change_flag_tab(i)
 	            ,tmp.NEG_REVENUE_CHANGE_FLAG  = l_neg_revChange_flag_tab(i)
                   WHERE tmp.rowid = l_rowid_tab(i) ;

            End IF;

        END IF;  --}
	IF P_PA_DEBUG_MODE = 'Y' Then
        	print_msg('End of Compare_bdgtLine_Values api ReturnStatus['||x_return_status||']');
	End If;

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                x_msg_data := sqlcode||sqlerrm;
                print_msg('Failed in Compare_bdgtLine_Values API'||x_msg_data);
                 fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'Compare_bdgtLine_Values');
                RAISE;

END Compare_bdgtLine_Values;

/* IPM Changes: This is the new api created to handle to massag the data before calling the spread
 * for non-rate based resources.
 * This API sets the rate overrides for a non-rate base resources when any of the planning
 * resource attributes such as spread curve, plan dates, etc changes and when user perform
 * the distribute(re-spread) action from periodic page.
 * Test Cases: When user enters say revenue only for a planning resource
 * from periodic page and presses distribute button. The process should distribute revenue only
 * it should not derive raw cost or burden cost for all other feilds.
 */

PROCEDURE process_NonRtBsRec_forSprd
		(p_budget_version_id              IN  Number
                ,p_source_context                IN  pa_fp_res_assignments_tmp.source_context%TYPE
                ,x_return_status                 OUT NOCOPY VARCHAR2
                ) IS

        CURSOR cur_NonRtBsRecs IS
        SELECT tmp.resource_assignment_id
                ,tmp.txn_currency_code
                ,tmp.start_date
                ,tmp.end_date
                ,ra.resource_rate_based_flag
                ,ra.rate_based_flag
                ,tmp.raw_cost_changed_flag
                ,tmp.burden_cost_changed_flag
                ,tmp.revenue_changed_flag
                ,tmp.revenue_only_entered_flag
                ,tmp.burden_only_entered_flag
		,tmp.bl_txn_raw_cost
		,tmp.bl_txn_burdened_cost
		,tmp.bl_txn_revenue
		,tmp.BL_TXN_INIT_RAW_COST
                ,tmp.BL_TXN_INIT_BURDENED_COST
                ,tmp.BL_TXN_INIT_REVENUE
                ,NVL(tmp.RE_SPREAD_AMTS_FLAG,'N')  re_spread_amts_flag
                ,NVL(tmp.SP_CURVE_CHANGE_FLAG,'N')  sp_curve_change_flag
                ,NVL(tmp.PLAN_DATES_CHANGE_FLAG,'N') plan_dates_change_flag
                ,NVL(tmp.SP_FIX_DATE_CHANGE_FLAG,'N') spfix_date_change_flag
                ,NVL(tmp.MFC_COST_CHANGE_FLAG,'N') mfc_cost_change_flag
                ,NVL(tmp.RLM_ID_CHANGE_FLAG,'N') rlm_id_change_flag
                ,NVL(tmp.system_reference_var1 ,'N') ra_in_multi_cur_flag
        FROM pa_fp_spread_calc_tmp tmp
                ,pa_resource_assignments ra
        WHERE tmp.budget_version_id = p_budget_version_id
        AND   tmp.resource_assignment_id = ra.resource_assignment_id
        AND   ra.rate_based_flag = 'N'
        AND   ( (NVL(tmp.bl_txn_raw_cost,0) = nvl(tmp.bl_quantity,0)
		and NVL(tmp.bl_txn_raw_cost,0) <> 0 )
	        OR
		(NVL(tmp.bl_txn_revenue,0) = nvl(tmp.bl_quantity,0)
		 and NVL(tmp.bl_txn_revenue,0) <> 0)
	      )
	 and  (nvl(tmp.bl_txn_raw_cost,0) - nvl(tmp.bl_txn_init_raw_cost,0)) <> 0 --Added for bug 6842835
	AND  (NVL(tmp.RE_SPREAD_AMTS_FLAG,'N')  = 'Y'
              OR NVL(tmp.SP_CURVE_CHANGE_FLAG,'N')  = 'Y'
              OR NVL(tmp.PLAN_DATES_CHANGE_FLAG,'N') = 'Y'
              OR NVL(tmp.SP_FIX_DATE_CHANGE_FLAG,'N') = 'Y'
              --OR NVL(tmp.MFC_COST_CHANGE_FLAG,'N') = 'Y'
              OR NVL(tmp.RLM_ID_CHANGE_FLAG,'N') = 'Y'
	     );

        l_resource_assignment_tab       pa_plsql_datatypes.NumTabTyp;
        l_txn_currency_code_tab         pa_plsql_datatypes.Char50TabTyp;
        l_start_date_tab                pa_plsql_datatypes.DateTabTyp;
        l_end_date_tab                  pa_plsql_datatypes.DateTabTyp;
        l_bilRtSetFlag_Tab              pa_plsql_datatypes.Char1TabTyp;
        l_resetamts_Tab         pa_plsql_datatypes.Char1TabTyp;
        l_bl_resprd_flag_tab            pa_plsql_datatypes.Char1TabTyp;
	l_cost_rate_override_tab        pa_plsql_datatypes.NumTabTyp;
	l_burden_rate_override_tab      pa_plsql_datatypes.NumTabTyp;
	l_bill_rate_override_tab        pa_plsql_datatypes.NumTabTyp;
        l_Cntr                          INTEGER := 0;


BEGIN
        x_return_status := 'S';
        l_resource_assignment_tab.delete;
        l_txn_currency_code_tab.delete;
        l_start_date_tab.delete;
        l_end_date_tab.delete;
        l_bilRtSetFlag_Tab.delete;
        l_bl_resprd_flag_tab.delete;
        l_resetAmts_Tab.delete;
	l_cost_rate_override_tab.delete;
        l_burden_rate_override_tab.delete;
        l_bill_rate_override_tab.delete;
        l_Cntr := 0;
        IF g_wp_version_flag = 'N' Then
		IF P_PA_DEBUG_MODE = 'Y' Then
		print_msg('Entered process_NonRtBsRec_forSprd API');
		End If;
		FOR i IN cur_NonRtBsRecs LOOP
		   l_Cntr := l_Cntr +1 ;
		   l_resource_assignment_tab(l_Cntr) := i.resource_assignment_id;
                   l_txn_currency_code_tab(l_Cntr) := i.txn_currency_code;
                   l_start_date_tab(l_Cntr) := i.start_date;
                   l_end_date_tab(l_Cntr) := i.end_date;
		   l_cost_rate_override_tab(l_Cntr) := NULL;
        	   l_burden_rate_override_tab(l_Cntr) := NULL;
        	   l_bill_rate_override_tab(l_Cntr) := NULL;
		   If g_budget_version_type = 'ALL' Then
			If i.bl_txn_raw_cost is NULL Then
			   -- revenue only record
			   l_cost_rate_override_tab(l_Cntr) := 0;
			   l_burden_rate_override_tab(l_Cntr) := 0;
			   l_bill_rate_override_tab(l_Cntr) := 1;
			Else
			   l_cost_rate_override_tab(l_Cntr) := 1;
                           l_burden_rate_override_tab(l_Cntr) :=
				(nvl(i.bl_txn_burdened_cost,0) - nvl(i.bl_txn_init_burdened_cost,0))/
				 (nvl(i.bl_txn_raw_cost,0) - nvl(i.bl_txn_init_raw_cost,0));
			   If i.bl_txn_revenue is NOT NULL Then
                              l_bill_rate_override_tab(l_Cntr) :=
				(nvl(i.bl_txn_revenue,0) - nvl(i.bl_txn_init_revenue,0))/
				 (nvl(i.bl_txn_raw_cost,0) - nvl(i.bl_txn_init_raw_cost,0));
			   End If;
			End If;
		   Elsif g_budget_version_type = 'COST' Then
			   l_cost_rate_override_tab(l_Cntr) := 1;
                           l_burden_rate_override_tab(l_Cntr) :=
                                (nvl(i.bl_txn_burdened_cost,0) - nvl(i.bl_txn_init_burdened_cost,0))/
                                 (nvl(i.bl_txn_raw_cost,0) - nvl(i.bl_txn_init_raw_cost,0));
		   Elsif g_budget_version_type = 'REVENUE' Then
			   l_bill_rate_override_tab(l_Cntr) := 1;
		   End If;
		END LOOP;
	End If;

	If l_resource_assignment_tab.COUNT > 0 Then
		FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
                  UPDATE pa_resource_asgn_curr rtx
                  SET   rtx.txn_raw_cost_rate_override = l_cost_rate_override_tab(i)
                        ,rtx.txn_burden_cost_rate_override = l_burden_rate_override_tab(i)
                        ,rtx.txn_bill_rate_override = l_bill_rate_override_tab(i)
                   WHERE rtx.resource_assignment_id = l_resource_assignment_tab(i)
                   AND rtx.txn_currency_code = l_txn_currency_code_tab(i);

		FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
                UPDATE pa_budget_lines bl
                SET bl.txn_bill_rate_override = l_bill_rate_override_tab(i)
                    ,bl.txn_cost_rate_override = l_cost_rate_override_tab(i)
                    ,bl.burden_cost_rate_override = l_burden_rate_override_tab(i)
                WHERE bl.resource_assignment_id = l_resource_assignment_tab(i)
                AND  bl.txn_currency_code = l_txn_currency_code_tab(i);

		FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
                   UPDATE /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP_N1) */ pa_fp_spread_calc_tmp tmp
                   SET  tmp.cost_rate_override = l_cost_rate_override_tab(i)
			,tmp.burden_cost_rate_override = l_burden_rate_override_tab(i)
			,tmp.bill_rate_override = l_bill_rate_override_tab(i)
                   WHERE tmp.resource_assignment_id = l_resource_assignment_tab(i)
                   AND  tmp.txn_currency_code = l_txn_currency_code_tab(i);

	End If;


EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                print_msg('Failed in process_NonRtBsRec_forSprd'||sqlcode||sqlerrm);
                 fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'process_NonRtBsRec_forSprd');
                RAISE;
END process_NonRtBsRec_forSprd;


/* This API is newly added to handle the mixture of revenue only in some priodic lines
 * and cost and revenue together in some periodic lines for ALL (cost and revenue together)
 * version.
 * Test Case1: When user enters raw cost or burden cost for a planning resource
 *             that has revenue only entered earlier.
 * Test case2: When planning resource attribute changes / re-spreads for
 *             a mixture of revenue only and cost and revenue lines
 */
PROCEDURE pre_process_Revenue_Only_Recs
		(p_budget_version_id              IN  Number
                ,p_source_context                IN  pa_fp_res_assignments_tmp.source_context%TYPE
                ,x_return_status                 OUT NOCOPY VARCHAR2
                ) IS

	CURSOR cur_RevOnlyRecs IS
	SELECT tmp.resource_assignment_id
		,tmp.txn_currency_code
		,tmp.start_date
		,tmp.end_date
		,ra.resource_rate_based_flag
		,ra.rate_based_flag
		,tmp.raw_cost_changed_flag
		,tmp.burden_cost_changed_flag
		,tmp.revenue_changed_flag
		,tmp.revenue_only_entered_flag
		,tmp.burden_only_entered_flag
		,tmp.txn_raw_cost
		,tmp.txn_burdened_cost
		,tmp.txn_revenue
		,tmp.BL_TXN_INIT_RAW_COST
                ,tmp.BL_TXN_INIT_BURDENED_COST
                ,tmp.BL_TXN_INIT_REVENUE
		,tmp.bl_txn_raw_cost
		,tmp.bl_quantity
		,NVL(tmp.RE_SPREAD_AMTS_FLAG,'N')  re_spread_amts_flag
                ,NVL(tmp.SP_CURVE_CHANGE_FLAG,'N')  sp_curve_change_flag
                ,NVL(tmp.PLAN_DATES_CHANGE_FLAG,'N') plan_dates_change_flag
                ,NVL(tmp.SP_FIX_DATE_CHANGE_FLAG,'N') spfix_date_change_flag
                ,NVL(tmp.MFC_COST_CHANGE_FLAG,'N') mfc_cost_change_flag
		,NVL(tmp.RLM_ID_CHANGE_FLAG,'N') rlm_id_change_flag
		,NVL(tmp.system_reference_var1 ,'N') ra_in_multi_cur_flag
		,NVL(tmp.DELETE_BL_FLAG,'N') delete_bl_flag
	FROM pa_fp_spread_calc_tmp tmp
		,pa_resource_assignments ra
	WHERE tmp.budget_version_id = p_budget_version_id
	AND   tmp.resource_assignment_id = ra.resource_assignment_id
	AND   nvl(ra.rate_based_flag,'N') = 'N'
	AND   NVL(tmp.quantity_changed_flag,'N') = 'N'
	AND   NVL(tmp.bl_txn_raw_cost,0) <> 0
	AND   NVL(tmp.bl_txn_raw_cost,0) <> nvl(tmp.bl_quantity,0)
	AND   NVL(tmp.revenue_only_entered_flag,'N') <> 'Y'
	/*AND   NVL(tmp.RE_SPREAD_AMTS_FLAG,'N')  = 'N'
        AND   NVL(tmp.SP_CURVE_CHANGE_FLAG,'N')  = 'N'
        AND   NVL(tmp.PLAN_DATES_CHANGE_FLAG,'N') = 'N'
        AND   NVL(tmp.SP_FIX_DATE_CHANGE_FLAG,'N') = 'N'
        AND   NVL(tmp.RLM_ID_CHANGE_FLAG,'N') = 'N'
	*/
	AND   NVL(tmp.DELETE_BL_FLAG,'N') = 'N'
	AND   EXISTS ( select null
			from pa_budget_lines bl
			where bl.resource_assignment_id = tmp.resource_assignment_id
			and   bl.txn_currency_code = tmp.txn_currency_code
			and   ((p_source_context = 'BUDGET_LINE'
				and bl.start_date between tmp.start_date and tmp.end_date)
				OR
				p_source_context <> 'BUDGET_LINE'
				)
		    );

    	l_resource_assignment_tab   	pa_plsql_datatypes.NumTabTyp;
    	l_txn_currency_code_tab     	pa_plsql_datatypes.Char50TabTyp;
    	l_start_date_tab             	pa_plsql_datatypes.DateTabTyp;
    	l_end_date_tab             	pa_plsql_datatypes.DateTabTyp;
	l_bilRtSetFlag_Tab   		pa_plsql_datatypes.Char1TabTyp;
	l_resetamts_Tab		pa_plsql_datatypes.Char1TabTyp;
	l_bl_resprd_flag_tab            pa_plsql_datatypes.Char1TabTyp;
	l_Cntr				INTEGER := 0;
	l_cost_rate_override_tab        pa_plsql_datatypes.NumTabTyp;
        l_burden_rate_override_tab      pa_plsql_datatypes.NumTabTyp;
        l_bill_rate_override_tab        pa_plsql_datatypes.NumTabTyp;

BEGIN
	x_return_status := 'S';
	IF P_PA_DEBUG_MODE = 'Y' Then
	print_msg('1: Inside pre_process_Revenue_Only_Recs api');
	End If;
	l_resource_assignment_tab.delete;
        l_txn_currency_code_tab.delete;
        l_start_date_tab.delete;
        l_end_date_tab.delete;
        l_bilRtSetFlag_Tab.delete;
	l_bl_resprd_flag_tab.delete;
	l_resetAmts_Tab.delete;
	l_cost_rate_override_tab.delete;
        l_burden_rate_override_tab.delete;
        l_bill_rate_override_tab.delete;
	l_Cntr := 0;
	IF g_wp_version_flag = 'N' AND g_budget_version_type = 'ALL' Then
	   FOR i IN cur_RevOnlyRecs LOOP
		--print_msg('inside loop: rawCost['||i.bl_txn_raw_cost||']qty['||i.bl_quantity||']');
		l_Cntr := l_Cntr +1 ;
		If (NVL(i.re_spread_amts_flag,'N' ) = 'Y'
                   	OR i.sp_curve_change_flag = 'Y'
               		OR i.spfix_date_change_flag = 'Y'
               		OR i.rlm_id_change_flag = 'Y'
                   	OR (nvl(i.ra_in_multi_cur_flag,'N') = 'N'
			   AND i.plan_dates_change_flag = 'Y') ) Then
			--print_msg('1.1: Resetting Amnts and Rate overrides Resource attribute changes');
			l_resetAmts_Tab(l_Cntr) := 'Y';
                        l_resource_assignment_tab(l_Cntr) := i.resource_assignment_id;
                        l_txn_currency_code_tab(l_Cntr) := i.txn_currency_code;
                        l_start_date_tab(l_Cntr) := i.start_date;
                        l_end_date_tab(l_Cntr) := i.end_date;

		Elsif (NVL(i.raw_cost_changed_flag,'N') = 'Y'
		   OR (nvl(i.burden_cost_changed_flag,'N') = 'Y'
			and nvl(i.burden_only_entered_flag,'N') = 'Y')) Then
			--print_msg('1.2:Resetting bill rates for mix of rev and cost and reve lines ');
			l_bilRtSetFlag_Tab(l_Cntr) := 'Y';
			l_resource_assignment_tab(l_Cntr) := i.resource_assignment_id;
			l_txn_currency_code_tab(l_Cntr) := i.txn_currency_code;
			l_start_date_tab(l_Cntr) := i.start_date;
			l_end_date_tab(l_Cntr) := i.end_date;
			l_bl_resprd_flag_tab(l_Cntr) := 'Y';
			l_cost_rate_override_tab(l_Cntr) := NULL;
                   	l_burden_rate_override_tab(l_Cntr) := NULL;
                   	l_bill_rate_override_tab(l_Cntr) := NULL;
			If nvl(i.burden_cost_changed_flag,'N') = 'Y' Then
				l_burden_rate_override_tab(l_Cntr) :=
					(NVL(i.txn_burdened_cost,0)-nvl(i.bl_txn_init_burdened_cost,0))/
					(nvl(i.txn_raw_cost,0) - nvl(i.bl_txn_init_raw_cost,0));
			End If;
			If nvl(i.revenue_changed_flag,'N') = 'Y' Then
				l_bill_rate_override_tab(l_Cntr) :=
					(nvl(i.txn_revenue,0) - nvl(i.bl_txn_init_revenue,0))/
					(nvl(i.txn_raw_cost,0) - nvl(i.bl_txn_init_raw_cost,0));
			End If;
		End If;
	   END LOOP;

	   /* rederive the budget rate overrides on the budget lines to retain the amounts
	    * in case of re spread, planning dates change etc
	    */
	   If p_source_context = 'RESOURCE_ASSIGNMENT' and l_resetAmts_Tab.COUNT > 0 Then --{
		IF P_PA_DEBUG_MODE = 'Y' Then
		print_msg('1.3: Upd Resource asgn cur with rate overrides ');
		End If;
		FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
                  UPDATE pa_resource_asgn_curr rtx
                  SET   (rtx.txn_raw_cost_rate_override
			,rtx.txn_burden_cost_rate_override
			,rtx.txn_bill_rate_override) =
                        (select decode(sum(nvl(bl.txn_raw_cost,0) - nvl(bl.txn_init_raw_cost,0)),0,rtx.txn_raw_cost_rate_override,1)
				,decode(sum(nvl(bl.txn_raw_cost,0) - nvl(bl.txn_init_raw_cost,0)),0,0
					,(sum(nvl(bl.txn_burdened_cost,0) - nvl(bl.txn_init_burdened_cost,0))/
					(sum(nvl(bl.txn_raw_cost,0) - nvl(bl.txn_init_raw_cost,0)))))
				,decode(sum(nvl(bl.txn_revenue,0)-nvl(bl.txn_init_revenue,0)),0,rtx.txn_bill_rate_override
					,(sum(nvl(bl.txn_revenue,0)-nvl(bl.txn_init_revenue,0)))/
					 (sum(nvl(bl.txn_raw_cost,0) - nvl(bl.txn_init_raw_cost,0))))
                        from pa_budget_lines bl
                        where bl.resource_assignment_id = rtx.resource_assignment_id
                        and bl.txn_currency_code = rtx.txn_currency_code
                        )
                   WHERE rtx.resource_assignment_id = l_resource_assignment_tab(i)
                   AND rtx.txn_currency_code = l_txn_currency_code_tab(i)
                   AND EXISTS (select null
				from pa_budget_lines bl1
				where bl1.resource_assignment_id = rtx.resource_assignment_id
				and bl1.txn_currency_code = rtx.txn_currency_code
				);

		/* Now spread the raw cost: so copy raw cost to quantity param */
		IF P_PA_DEBUG_MODE = 'Y' Then
		print_msg('1.4: Update spread calc tmp with quantity = raw cost');
		End If;
		FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
                   UPDATE /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP_N1) */ pa_fp_spread_calc_tmp tmp
                   SET tmp.quantity =
				(select decode(sum(bl.txn_raw_cost),NULL,sum(bl.txn_revenue),sum(bl.txn_raw_cost))
				from pa_budget_lines bl
                        	where bl.resource_assignment_id = tmp.resource_assignment_id
                        	and bl.txn_currency_code = tmp.txn_currency_code
				)
                   WHERE tmp.resource_assignment_id = l_resource_assignment_tab(i)
                   AND  tmp.txn_currency_code = l_txn_currency_code_tab(i)
		   AND EXISTS (select null
                                from pa_budget_lines bl1
                                where bl1.resource_assignment_id = tmp.resource_assignment_id
                                and bl1.txn_currency_code = tmp.txn_currency_code
                                );

		--print_msg('1.5: update budget lines set override rates to null');
		FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
                UPDATE pa_budget_lines bl
                SET bl.txn_bill_rate_override = null
		    ,bl.burden_cost_rate_override = null
                    ,bl.txn_cost_rate_override = 1
                WHERE bl.resource_assignment_id = l_resource_assignment_tab(i)
                AND  bl.txn_currency_code = l_txn_currency_code_tab(i);
	   End If; --} // end of sprd processing

	   If l_bilRtSetFlag_Tab.count > 0 Then --{
		--print_msg('1.1.1: Update budget lines to set override rates');
		FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
		UPDATE pa_budget_lines bl
		SET bl.txn_bill_rate_override = l_bill_rate_override_tab(i)
			/* bug fix: 5089153 stamp bill rate override only if revenue is changed along with cost
			decode(bl.txn_cost_rate_override,0
			,decode(bl.txn_bill_rate_override,1,l_bill_rate_override_tab(i)
				,nvl(l_bill_rate_override_tab(i),bl.txn_bill_rate_override))
			,decode(bl.txn_bill_rate_override,1,l_bill_rate_override_tab(i)
				,nvl(l_bill_rate_override_tab(i),bl.txn_bill_rate_override))) */
		    ,bl.txn_cost_rate_override = 1
		    ,bl.burden_cost_rate_override =
			decode(bl.txn_cost_rate_override,0,l_burden_rate_override_tab(i)
				,NULL,l_burden_rate_override_tab(i)
				,NVL(l_burden_rate_override_tab(i),bl.burden_cost_rate_override))
		WHERE bl.resource_assignment_id = l_resource_assignment_tab(i)
		AND  bl.txn_currency_code = l_txn_currency_code_tab(i)
		AND  ((p_source_context = 'BUDGET_LINE'
                       and bl.start_date between l_start_date_tab(i) and l_end_date_tab(i))
                       OR
                       p_source_context <> 'BUDGET_LINE'
                     );

		If p_source_context <> 'BUDGET_LINE' Then
		  --print_msg('1.1.2: update resource asgn cur to set rate overrides');
		  FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
		  UPDATE pa_resource_asgn_curr rtx
		  SET (rtx.txn_bill_rate_override
			,rtx.txn_burden_cost_rate_override ) =
			(select decode(rtx.txn_bill_rate_override,NULL
				  ,nvl(l_bill_rate_override_tab(i),rtx.txn_bill_rate_override)
				,decode((nvl(tmp.bl_txn_raw_cost,0)-nvl(tmp.bl_txn_init_raw_cost,0)),0
				 ,nvl(l_bill_rate_override_tab(i),rtx.txn_bill_rate_override)
			          ,((tmp.txn_revenue - nvl(tmp.bl_txn_init_revenue,0))/
				  (nvl(tmp.bl_txn_raw_cost,0)-nvl(tmp.bl_txn_init_raw_cost,0)))))
			  ,decode(nvl(tmp.burden_cost_changed_flag,'N'), 'Y'
					,nvl(l_burden_rate_override_tab(i),rtx.txn_burden_cost_rate_override))
		  	from pa_fp_spread_calc_tmp tmp
			where tmp.resource_assignment_id = rtx.resource_assignment_id
			and tmp.txn_currency_code = rtx.txn_currency_code
			and tmp.raw_cost_changed_flag = 'Y'
			)
		   WHERE rtx.resource_assignment_id = l_resource_assignment_tab(i)
		   AND rtx.txn_currency_code = l_txn_currency_code_tab(i)
		   ;

		End If;
		--print_msg('1.1.3: update spread calc tmp to rate overrides');
		   FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
		   UPDATE /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP_N1) */ pa_fp_spread_calc_tmp tmp
		   SET tmp.re_spread_amts_flag =
				decode(tmp.re_spread_amts_flag,'Y','Y',l_bl_resprd_flag_tab(i))
			,tmp.delete_bl_flag = decode(tmp.delete_bl_flag,'Y','Y'
				,decode(l_bl_resprd_flag_tab(i),'Y','Y',tmp.delete_bl_flag))
			,tmp.bill_rate_override =
				nvl(l_bill_rate_override_tab(i),tmp.bill_rate_override)
			,tmp.burden_cost_rate_override =
				nvl(l_burden_rate_override_tab(i),tmp.burden_cost_rate_override)
			/* bug fix:5463690 */
 	                ,tmp.NEG_QUANTITY_CHANGE_FLAG  = decode(nvl(l_bl_resprd_flag_tab(i),'N'),'Y','N'
 	                                                         ,tmp.NEG_QUANTITY_CHANGE_FLAG)
 	                ,tmp.NEG_RAWCOST_CHANGE_FLAG = decode(nvl(l_bl_resprd_flag_tab(i),'N'),'Y','N'
 	                                                         ,tmp.NEG_RAWCOST_CHANGE_FLAG)
 	                ,tmp.NEG_BURDEN_CHANGE_FALG = decode(nvl(l_bl_resprd_flag_tab(i),'N'),'Y','N'
 	                                                         ,tmp.NEG_BURDEN_CHANGE_FALG)
 	                ,tmp.NEG_REVENUE_CHANGE_FLAG = decode(nvl(l_bl_resprd_flag_tab(i),'N'),'Y','N'
 	                                                         ,tmp.NEG_REVENUE_CHANGE_FLAG)
		   WHERE tmp.resource_assignment_id = l_resource_assignment_tab(i)
                   AND  tmp.txn_currency_code = l_txn_currency_code_tab(i)
                   AND  ((p_source_context = 'BUDGET_LINE'
                       and tmp.start_date = l_start_date_tab(i) )
                       OR
                       p_source_context <> 'BUDGET_LINE'
                     );

	   End If; --}
	End If;
EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                print_msg('Failed in pre_process_Revenue_Only_RecsAPI'||sqlcode||sqlerrm);
                 fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'pre_process_Revenue_Only_Recs');
                RAISE;
END pre_process_Revenue_Only_Recs;

/* This api is added as an IPM enhancement request: For a rate based planning transaction if no quantity is passed
 * then mark the resource as a Non-Rate planning transaction, Again when user enters quantity and or rates
 * revert back the Non-rate base to rate base flag
 */
PROCEDURE Reset_ratebased_pltrxns(
                p_budget_version_id              IN  Number
                ,p_source_context                IN  pa_fp_res_assignments_tmp.source_context%TYPE
                ,x_return_status                 OUT NOCOPY VARCHAR2
                ) IS

    l_resource_assignment_tab   pa_plsql_datatypes.NumTabTyp;
    l_txn_currency_code_tab     pa_plsql_datatypes.Char50TabTyp;
    l_start_date_tab             pa_plsql_datatypes.DateTabTyp;
    l_end_date_tab               pa_plsql_datatypes.DateTabTyp;
    l_period_name_tab            pa_plsql_datatypes.Char50TabTyp;
    l_quantity_tab              pa_plsql_datatypes.NumTabTyp;
    l_raw_cost_tab              pa_plsql_datatypes.NumTabTyp;
    l_burden_cost_tab           pa_plsql_datatypes.NumTabTyp;
    l_revenue_tab               pa_plsql_datatypes.NumTabTyp;
    l_revenue_only_flag_tab     pa_plsql_datatypes.Char1TabTyp;
    l_burden_only_flag_tab     pa_plsql_datatypes.Char1TabTyp;
    l_reset_rate_based_flag_tab pa_plsql_datatypes.Char1TabTyp;
    l_bd_cost_rate_override_tab pa_plsql_datatypes.NumTabTyp;
    l_rw_cost_rate_override_tab pa_plsql_datatypes.NumTabTyp;
    l_bill_rate_override_tab    pa_plsql_datatypes.NumTabTyp;
    l_mark_non_rate_base_flag   Varchar2(1);
    l_exists_flag               Varchar2(1);
    l_tbl_counter               Number;
    l_start_date            DATE;
    l_end_date          DATE;
    l_uom_tab			pa_plsql_datatypes.Char30TabTyp;
	l_rwRtSetFlag_Tab	pa_plsql_datatypes.Char1TabTyp;
           l_bilRtSetFlag_Tab	pa_plsql_datatypes.Char1TabTyp;
	l_bdRtSetFlag_tab	pa_plsql_datatypes.Char1TabTyp;
	l_reCalcbdRt_Tab	pa_plsql_datatypes.Char1TabTyp;
        l_reCalcBilRt_Tab	pa_plsql_datatypes.Char1TabTyp;
	l_costRt_g_miss_num_flag_tab pa_plsql_datatypes.Char1TabTyp;
        l_burdRt_g_miss_num_flag_tab pa_plsql_datatypes.Char1TabTyp;
        l_revRt_g_miss_num_flag_tab  pa_plsql_datatypes.Char1TabTyp;

    Cursor cur_ra IS
    SELECT tmp.resource_assignment_id
        ,tmp.txn_currency_code
        ,tmp.quantity
        ,tmp.txn_raw_cost
        ,tmp.txn_burdened_cost
        ,tmp.txn_revenue
        ,g_budget_version_type  version_type
        ,tmp.start_date
        ,tmp.end_date
        ,rlm.alias
        ,g_budget_version_name  version_name
        ,tmp.bl_quantity
	,tmp.bl_txn_raw_cost
	,tmp.bl_cost_rate_override bl_rw_cost_rate
	,tmp.bl_burden_cost_rate_override bl_burd_rate
	,tmp.bl_bill_rate_override bl_bill_rate
	,tmp.cost_rate_override
	,tmp.burden_cost_rate_override
	,tmp.bill_rate_override
	,tmp.bl_init_quantity  		init_quantity
	,tmp.bl_txn_init_raw_cost 	txn_init_raw_cost
	,tmp.bl_txn_init_burdened_cost 	txn_init_burdened_cost
	,tmp.bl_txn_init_revenue	txn_init_revenue
        ,NVL(ra.resource_rate_based_flag,'N') resource_rate_based_flag
	,NVL(ra.rate_based_flag ,'N') rate_based_flag
	,rlm.unit_of_measure UOM
	,ra.unit_of_measure currentUOM
	,NVL(tmp.quantity_changed_flag,'N') quantity_changed_flag
	,NVL(tmp.cost_rate_changed_flag,'N') cost_rate_changed_flag
	,NVL(tmp.burden_rate_changed_flag,'N') burden_rate_changed_flag
	,NVL(tmp.bill_rate_changed_flag,'N') bill_rate_changed_flag
	,NVL(tmp.raw_cost_changed_flag,'N') raw_cost_changed_flag
	,NVL(tmp.burden_cost_changed_flag,'N') burden_cost_changed_flag
	,NVL(tmp.revenue_changed_flag,'N') revenue_changed_flag
    FROM pa_fp_spread_calc_tmp tmp
        ,pa_resource_assignments ra
        ,pa_resource_list_members rlm
    WHERE ra.budget_version_id = p_budget_version_id
    AND  ra.resource_assignment_id = tmp.resource_assignment_id
    AND  rlm.resource_list_member_id = ra.resource_list_member_id
    AND  NVL(ra.rate_based_flag,'N') <> NVL(ra.resource_rate_based_flag,'N')
    AND  NVL(ra.resource_rate_based_flag,'N') = 'Y'
    ORDER BY tmp.resource_assignment_id,tmp.txn_currency_code;

    Cursor cur_NonRtRas IS
    SELECT tmp.resource_assignment_id
        ,tmp.txn_currency_code
        ,tmp.quantity
        ,tmp.txn_raw_cost
        ,tmp.txn_burdened_cost
        ,tmp.txn_revenue
        ,g_budget_version_type  version_type
        ,tmp.start_date
        ,tmp.end_date
        ,rlm.alias
        ,g_budget_version_name  version_name
        ,tmp.bl_quantity
	,tmp.bl_txn_raw_cost
        ,tmp.bl_cost_rate_override bl_rw_cost_rate
        ,tmp.bl_burden_cost_rate_override bl_burd_rate
	,tmp.bl_bill_rate_override bl_bill_rate
        ,tmp.cost_rate_override
        ,tmp.burden_cost_rate_override
        ,tmp.bill_rate_override
	,tmp.bl_init_quantity           init_quantity
        ,tmp.bl_txn_init_raw_cost       txn_init_raw_cost
        ,tmp.bl_txn_init_burdened_cost  txn_init_burdened_cost
        ,tmp.bl_txn_init_revenue        txn_init_revenue
        ,NVL(ra.resource_rate_based_flag,'N') resource_rate_based_flag
        ,NVL(ra.rate_based_flag ,'N') rate_based_flag
        ,rlm.unit_of_measure UOM
	,ra.unit_of_measure currentUOM
        ,NVL(tmp.quantity_changed_flag,'N') quantity_changed_flag
        ,NVL(tmp.cost_rate_changed_flag,'N') cost_rate_changed_flag
        ,NVL(tmp.burden_rate_changed_flag,'N') burden_rate_changed_flag
        ,NVL(tmp.bill_rate_changed_flag,'N') bill_rate_changed_flag
        ,NVL(tmp.raw_cost_changed_flag,'N') raw_cost_changed_flag
        ,NVL(tmp.burden_cost_changed_flag,'N') burden_cost_changed_flag
        ,NVL(tmp.revenue_changed_flag,'N') revenue_changed_flag
	,tmp.bill_markup_percentage
    FROM pa_fp_spread_calc_tmp tmp
        ,pa_resource_assignments ra
        ,pa_resource_list_members rlm
    WHERE ra.budget_version_id = p_budget_version_id
    AND  ra.resource_assignment_id = tmp.resource_assignment_id
    AND  rlm.resource_list_member_id = ra.resource_list_member_id
    AND  NVL(ra.rate_based_flag,'N') = 'N'
    AND  ( (tmp.txn_raw_cost is NOT NULL or tmp.txn_revenue is NOT NULL)
 	           OR
 	        /* added this to pickup the lines where budget line exists and sum raw is zero and sum revenue is zero
 	          * and user changed burdened cost only
 	        */
 	        (nvl(tmp.txn_raw_cost,0)=0 and nvl(tmp.txn_revenue,0) =0 and tmp.txn_burdened_cost is NOT NULL)
 	        )
    AND  NVL(ra.resource_rate_based_flag,'N') = 'N'
    /* bug fix:5726773: commented out this and added exist clause
     * reason: when budget line exists and total plan qty is zero, the above cursor fails
     * AND  tmp.quantity is not null */
 	     AND  EXISTS (select /*+ INDEX(BL PA_BUDGET_LINES_U1) */ null
 	                  from pa_budget_lines bl1
 	                  where bl1.resource_assignment_id = tmp.resource_assignment_id
 	                  and bl1.txn_currency_code = tmp.txn_currency_code
 	                  and ((g_source_context = 'BUDGET_LINE'
 	                        and bl1.start_date between tmp.start_date and tmp.end_date)
 	                         OR
 	                        (g_source_context <> 'BUDGET_LINE')
 	                      )
 	                 )
    ORDER BY tmp.resource_assignment_id,tmp.txn_currency_code;

	l_NonRrtRec_Exists_Exception	EXCEPTION;
	l_NonRrtRec_Exists_Flg		VARCHAR2(1);

BEGIN
	x_return_status := 'S';
	   l_resource_assignment_tab.delete;
           l_txn_currency_code_tab.delete;
           l_quantity_tab.delete;
           l_raw_cost_tab.delete;
           l_burden_cost_tab.delete;
           l_revenue_tab.delete;
           l_start_date_tab.delete;
           l_end_date_tab.delete;
           l_revenue_only_flag_tab.delete;
	   l_reset_rate_based_flag_tab.delete;
	   l_bd_cost_rate_override_tab.delete;
	   l_rw_cost_rate_override_tab.delete;
	   l_bill_rate_override_tab.delete;
	   l_uom_tab.delete;
	   l_rwRtSetFlag_Tab.delete;
	   l_bilRtSetFlag_Tab.delete;
	   l_bdRtSetFlag_tab.delete;
	   l_reCalcbdRt_Tab.delete;
           l_reCalcBilRt_Tab.delete;
	   l_revenue_only_flag_tab.delete;
	   l_costRt_g_miss_num_flag_tab.delete;
           l_burdRt_g_miss_num_flag_tab.delete;
           l_revRt_g_miss_num_flag_tab.delete;
	   l_burden_only_flag_tab.delete;

	  l_tbl_counter := 0;
	   For i IN cur_ra LOOP --{

		/*
		print_msg('Looping through RAs for Rate Base flg = N and Resource Rate base flag = Y');
		print_msg('OrgRwCst['||i.txn_raw_cost||']Rt['||i.bl_rw_cost_rate||']OrgBurd['||i.txn_burdened_cost||']Rt['||i.bl_burd_rate||']');
		print_msg('OrgRev['||i.txn_revenue||']Rt['||i.bl_bill_rate||']OrgQty['||i.quantity||']');
		print_msg('currentUOM['||i.currentUOM||']ResUOM['||i.UOM||']');
		*/
		l_tbl_counter := l_tbl_counter + 1;
		l_resource_assignment_tab(l_tbl_counter) := i.resource_assignment_id;
		l_txn_currency_code_tab(l_tbl_counter) := i.txn_currency_code;
		l_start_date_tab(l_tbl_counter) := i.start_date;
           	l_end_date_tab(l_tbl_counter) := i.end_date;
		l_quantity_tab(l_tbl_counter) := null;
		l_raw_cost_tab(l_tbl_counter) := null;
		l_burden_cost_tab(l_tbl_counter) := null;
		l_revenue_tab(l_tbl_counter) := null;
		l_revenue_only_flag_tab(l_tbl_counter) := 'N';
		l_reset_rate_based_flag_tab(l_tbl_counter) := 'N';
		l_bd_cost_rate_override_tab(l_tbl_counter) := null;
           	l_rw_cost_rate_override_tab(l_tbl_counter) := null;
           	l_bill_rate_override_tab(l_tbl_counter) := null;
		l_uom_tab(l_tbl_counter) := i.UOM;
		l_rwRtSetFlag_Tab(l_tbl_counter) := 'N';
           	l_bilRtSetFlag_Tab(l_tbl_counter) := 'N';
		l_bdRtSetFlag_tab(l_tbl_counter) := 'N';
		l_reCalcbdRt_Tab(l_tbl_counter) := 'N';
		l_reCalcBilRt_Tab(l_tbl_counter) := 'N';
	        l_revenue_only_flag_tab(l_tbl_counter ) := 'N';
		l_costRt_g_miss_num_flag_tab(l_tbl_counter ) := NULL;
        	l_burdRt_g_miss_num_flag_tab(l_tbl_counter ) := NULL;
        	l_revRt_g_miss_num_flag_tab(l_tbl_counter ) := NULL;
		l_burden_only_flag_tab(l_tbl_counter ) := 'N';
		IF i.version_type = 'COST' Then
		   If i.rate_based_flag = 'N' and i.resource_rate_based_flag = 'Y' Then
			If i.quantity_changed_flag = 'Y' Then
			   l_reset_rate_based_flag_tab(l_tbl_counter) := 'Y';
			   IF i.cost_rate_changed_flag = 'Y'
			       and i.raw_cost_changed_flag = 'Y' Then
				If (nvl(i.quantity,0) - nvl(i.init_quantity,0) <> 0 ) Then
			   	   l_rw_cost_rate_override_tab(l_tbl_counter) :=
					(NVL(i.txn_raw_cost,0) - NVL(i.txn_init_raw_cost,0)) /
						(nvl(i.quantity,0) - nvl(i.init_quantity,0));
				End If;
			   ElsIf i.cost_rate_changed_flag = 'N' and i.raw_cost_changed_flag = 'Y' Then
				If (nvl(i.quantity,0) - nvl(i.init_quantity,0) <> 0 ) Then
                                   l_rw_cost_rate_override_tab(l_tbl_counter) :=
                                        (NVL(i.txn_raw_cost,0) - NVL(i.txn_init_raw_cost,0)) /
                                                (nvl(i.quantity,0) - nvl(i.init_quantity,0));
                                End If;
			   ElsIf i.cost_rate_changed_flag = 'N' and i.raw_cost_changed_flag = 'N' then
				l_rw_cost_rate_override_tab(l_tbl_counter) := NULL;
                                l_rwRtSetFlag_tab(l_tbl_counter) := 'Y';
			   End if;

			   If i.burden_cost_changed_flag = 'Y' then
				If (nvl(i.quantity,0) - nvl(i.init_quantity,0) <> 0 ) Then
                                   l_bd_cost_rate_override_tab(l_tbl_counter) :=
                                        (NVL(i.txn_burdened_cost,0) - NVL(i.txn_init_burdened_cost,0)) /
                                                (nvl(i.quantity,0) - nvl(i.init_quantity,0));
                                End If;
                           Elsif i.burden_rate_changed_flag = 'N' Then
                                l_bdRtSetFlag_tab(l_tbl_counter) := 'Y';
                                l_bd_cost_rate_override_tab(l_tbl_counter) := NULL;
                           End If;
			Else -- quantity dnot changed
			   IF i.raw_cost_changed_flag = 'Y' and i.burden_cost_changed_flag = 'N'  and nvl(i.bl_burd_rate,0) in (1,0) Then
				l_bdRtSetFlag_tab(l_tbl_counter) := 'Y';
                                l_bd_cost_rate_override_tab(l_tbl_counter) := NULL;
			   End If;
			   If i.burden_cost_changed_flag = 'Y' then
                                If (nvl(i.quantity,0) - nvl(i.init_quantity,0) <> 0 ) Then
                                   l_bd_cost_rate_override_tab(l_tbl_counter) :=
                                        (NVL(i.txn_burdened_cost,0) - NVL(i.txn_init_burdened_cost,0)) /
                                                (nvl(i.quantity,0) - nvl(i.init_quantity,0));
                                End If;
                           End If;

			End If;
		   End If;
		Elsif i.version_type = 'REVENUE' Then
		   If i.rate_based_flag = 'N' and i.resource_rate_based_flag = 'Y' Then
			If i.quantity_changed_flag = 'Y' Then
			   l_reset_rate_based_flag_tab(l_tbl_counter) := 'Y';
                           IF i.bill_rate_changed_flag = 'N'
				and i.revenue_changed_flag = 'Y' Then
				If (nvl(i.quantity,0) - nvl(i.init_quantity,0) <> 0 ) Then
                           	    l_bill_rate_override_tab(l_tbl_counter) :=
					(nvl(i.txn_revenue,0) - nvl(i.txn_init_revenue,0)) /
					   (nvl(i.quantity,0) - nvl(i.init_quantity,0));
				End If;
			   Elsif i.bill_rate_changed_flag = 'Y' and i.revenue_changed_flag = 'Y' Then
				If (nvl(i.quantity,0) - nvl(i.init_quantity,0) <> 0 ) Then
                                    l_bill_rate_override_tab(l_tbl_counter) :=
                                        (nvl(i.txn_revenue,0) - nvl(i.txn_init_revenue,0)) /
                                           (nvl(i.quantity,0) - nvl(i.init_quantity,0));
                                End If;
			   Elsif i.bill_rate_changed_flag = 'N' and i.revenue_changed_flag = 'N' Then
				l_bilRtSetFlag_tab(l_tbl_counter) := 'Y';
				l_bill_rate_override_tab(l_tbl_counter) := NULL;
			   End If;
			Else -- quantity is not changed
			   If i.bill_rate_changed_flag = 'Y' Then
			   	l_reCalcBilRt_tab(l_tbl_counter) := 'Y';
			   	l_bill_rate_override_tab(l_tbl_counter) := 1;
			   End If;
			End If;
		   End If;
		Elsif i.version_type = 'ALL' then
		   If i.rate_based_flag = 'N' and i.resource_rate_based_flag = 'Y' Then
			If i.quantity_changed_flag = 'Y' Then
				l_reset_rate_based_flag_tab(l_tbl_counter) := 'Y';
				If i.raw_cost_changed_flag = 'Y' Then
				  If (nvl(i.quantity,0) - nvl(i.init_quantity,0) <> 0 ) Then
                                   	l_rw_cost_rate_override_tab(l_tbl_counter) :=
                                        (NVL(i.txn_raw_cost,0) - NVL(i.txn_init_raw_cost,0)) /
                                                (nvl(i.quantity,0) - nvl(i.init_quantity,0));
                                  End If;
				Elsif i.cost_rate_changed_flag = 'N' Then
					l_rw_cost_rate_override_tab(l_tbl_counter) := NULL;
					l_rwRtSetFlag_tab(l_tbl_counter) := 'Y';
				End If;
				If i.burden_cost_changed_flag = 'Y' then
				  If (nvl(i.quantity,0) - nvl(i.init_quantity,0) <> 0 ) Then
                                   	l_bd_cost_rate_override_tab(l_tbl_counter) :=
                                        (NVL(i.txn_burdened_cost,0) - NVL(i.txn_init_burdened_cost,0)) /
                                                (nvl(i.quantity,0) - nvl(i.init_quantity,0));
                                  End If;
				Elsif i.burden_rate_changed_flag = 'N' Then
					l_bdRtSetFlag_tab(l_tbl_counter) := 'Y';
					l_bd_cost_rate_override_tab(l_tbl_counter) := NULL;
				End If;

				If i.revenue_changed_flag = 'Y' Then
				  If (nvl(i.quantity,0) - nvl(i.init_quantity,0) <> 0 ) Then
                                    	l_bill_rate_override_tab(l_tbl_counter) :=
                                        (nvl(i.txn_revenue,0) - nvl(i.txn_init_revenue,0)) /
                                           (nvl(i.quantity,0) - nvl(i.init_quantity,0));
                                  End If;
				Elsif i.bill_rate_changed_flag = 'N' Then
					l_bill_rate_override_tab(l_tbl_counter) := NULL;
					l_bilRtSetFlag_Tab(l_tbl_counter) := 'Y';
				End If;
				/* in case if we donot want calculate raw and burden then open this code
				l_bill_rate_override_tab(l_tbl_counter) := i.txn_revenue / i.quantity;
				if i.cost_rate_changed_flag = 'N' and i.raw_cost_changed_flag = 'N' and i.bl_rw_cost_rate = 0 Then
                                      l_rw_cost_rate_override_tab(l_tbl_counter) := 0;
				Else
					l_rw_cost_rate_override_tab(l_tbl_counter) := i.txn_raw_cost / i.quantity;
                                End If;
				*/

			Elsif i.quantity_changed_flag = 'N' Then
				--print_msg('Qty not changed');
				l_quantity_tab(l_tbl_counter) := i.quantity;

				If i.resource_rate_based_flag = 'Y' AND i.rate_based_flag = 'N'  then
                                	l_costRt_g_miss_num_flag_tab(l_tbl_counter) := 'N';
                                	l_burdRt_g_miss_num_flag_tab(l_tbl_counter) := 'N';
                                	l_revRt_g_miss_num_flag_tab(l_tbl_counter) := 'N';
                      		Elsif i.resource_rate_based_flag = 'N' AND i.rate_based_flag = 'N' Then
                                	l_costRt_g_miss_num_flag_tab(l_tbl_counter) := 'N';
                                	l_burdRt_g_miss_num_flag_tab(l_tbl_counter) := 'N';
                                	l_revRt_g_miss_num_flag_tab(l_tbl_counter) := 'N';
                      		End If;
				If i.revenue_changed_flag = 'Y' Then --{
				   --print_msg('Rev changed');
				   If i.raw_cost_changed_flag = 'Y' OR i.burden_cost_changed_flag = 'Y' then
					If i.raw_cost_changed_flag = 'Y' Then
						--print_msg('RawChanged');
						l_quantity_tab(l_tbl_counter) := i.txn_raw_cost;
						l_rw_cost_rate_override_tab(l_tbl_counter) := 1;
						If i.burden_cost_changed_flag = 'N' and nvl(i.bl_burd_rate,0) in (1) Then
						    l_bdRtSetFlag_Tab(l_tbl_counter) := 'Y';
						End If;
					End If;
					If i.burden_cost_changed_flag = 'Y' and i.raw_cost_changed_flag = 'N'
					   and NVL(i.bl_rw_cost_rate,0) = 0 and NVL(i.bl_burd_rate,0) IN (1,0) and i.bl_txn_raw_cost is NULL Then
						--print_msg('burden cost changed');
					    l_quantity_tab(l_tbl_counter) := i.txn_burdened_cost;
					    l_raw_cost_tab(l_tbl_counter) := i.txn_burdened_cost;
					    l_burden_only_flag_tab(l_tbl_counter ) := 'Y';
					     l_rw_cost_rate_override_tab(l_tbl_counter) := 1;
					     l_bd_cost_rate_override_tab(l_tbl_counter) := 1;
					Elsif i.burden_cost_changed_flag = 'Y' and i.bl_rw_cost_rate in (1,0) and i.bl_burd_rate NOT IN (1) Then
					    If (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0) <> 0) Then
						If i.bl_txn_raw_cost is NOT NULL and i.bl_txn_raw_cost = i.bl_quantity Then
					           l_bd_cost_rate_override_tab(l_tbl_counter) :=
							(nvl(i.txn_burdened_cost,0) - nvl(i.txn_init_burdened_cost,0))/
							 (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0));
						Else
						   l_bd_cost_rate_override_tab(l_tbl_counter) :=
                                                        (nvl(i.txn_burdened_cost,0) - nvl(i.txn_init_burdened_cost,0))/
                                                         (NVL(l_raw_cost_tab(l_tbl_counter),i.bl_txn_raw_cost)-nvl(i.txn_init_raw_cost,0));
						End If;
					    End If;
					End If;
				   End If;
					--l_bill_rate_override_tab(l_tbl_counter) := i.txn_revenue / l_quantity_tab(l_tbl_counter);
				    if i.cost_rate_changed_flag = 'N' and i.raw_cost_changed_flag = 'N' and i.burden_cost_changed_flag = 'N'
					and (i.bl_rw_cost_rate = 0 OR i.bl_txn_raw_cost is NULL )  Then
					l_rw_cost_rate_override_tab(l_tbl_counter) := 0;
				    End If;
				    if i.burden_rate_changed_flag = 'N' and i.burden_cost_changed_flag = 'N'
				       and i.raw_cost_changed_flag = 'N' and i.bl_burd_rate = 0 Then
					l_bd_cost_rate_override_tab(l_tbl_counter) := 0;

				    /* when burden rate only changed for non-rate base resource ignore the rate */
				    ElsIf g_wp_version_flag = 'N' and i.burden_rate_changed_flag = 'Y' and i.burden_cost_changed_flag = 'N' Then
					l_reCalcbdRt_Tab(l_tbl_counter) := 'Y';
					l_bd_cost_rate_override_tab(l_tbl_counter) := NULL;
				    End If;

				    If  i.raw_cost_changed_flag = 'N'
                                     and i.burden_cost_changed_flag = 'N'
                                     and (i.bl_rw_cost_rate = 0 OR i.bl_txn_raw_cost is NULL ) Then
                                        l_quantity_tab(l_tbl_counter) := i.txn_revenue;
					l_revenue_only_flag_tab(l_tbl_counter) := 'Y';
					If (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0) <> 0) Then
                                        	l_bill_rate_override_tab(l_tbl_counter) :=
						 (nvl(i.txn_revenue,0) - nvl(i.txn_init_revenue,0)) /
						 (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0));
					End If;
                                    Else
                                        If (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0) <> 0) Then
                                                l_bill_rate_override_tab(l_tbl_counter) :=
                                                 (nvl(i.txn_revenue,0) - nvl(i.txn_init_revenue,0)) /
                                                 (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0));
                                        End If;
                                    End If;
				Elsif i.revenue_changed_flag = 'N' Then
                                   If i.bill_rate_changed_flag = 'Y' Then
                                        l_reCalcBilRt_tab(l_tbl_counter) := 'Y';
                                        l_bill_rate_override_tab(l_tbl_counter) := NULL;
                                   End If;
				   If (i.raw_cost_changed_flag = 'Y' OR i.burden_cost_changed_flag = 'Y') then --{
					--print_msg('Rev not changed');
					If i.raw_cost_changed_flag = 'Y' Then
						--print_msg('Rawchanged');
                                                l_quantity_tab(l_tbl_counter) := i.txn_raw_cost;
					        l_rw_cost_rate_override_tab(l_tbl_counter) := 1;
						If i.bl_bill_rate = 1 Then
                                                	l_bilRtSetFlag_Tab(l_tbl_counter) := 'Y';
                                        	End If;
                                                If i.burden_cost_changed_flag = 'N' and nvl(i.bl_burd_rate,0) in (0,1) Then
                                                    l_bdRtSetFlag_Tab(l_tbl_counter) := 'Y';
						/* ignore the burden rate changes for non-rate base resource */
						ElsIf g_wp_version_flag = 'N' and i.burden_rate_changed_flag = 'Y' and i.burden_cost_changed_flag = 'N' then
                                        		l_reCalcbdRt_Tab(l_tbl_counter) := 'Y';
                                        		l_bd_cost_rate_override_tab(l_tbl_counter) := NULL;
                                                End If;
                                        End If;
                                        If i.burden_cost_changed_flag = 'Y' and i.raw_cost_changed_flag = 'N'
                                           and NVL(i.bl_rw_cost_rate,0) = 0 and NVL(i.bl_burd_rate,0) IN (1,0) and i.bl_txn_raw_cost is NULL Then
                                            l_quantity_tab(l_tbl_counter) := i.txn_burdened_cost;
                                            l_raw_cost_tab(l_tbl_counter) := i.txn_burdened_cost;
					    l_burden_only_flag_tab(l_tbl_counter ) := 'Y';
					    l_rw_cost_rate_override_tab(l_tbl_counter) := 1;
					    l_bd_cost_rate_override_tab(l_tbl_counter) := 1;
					    If i.bl_bill_rate = 1 Then
                                                   l_bilRtSetFlag_Tab(l_tbl_counter) := 'Y';
                                            End If;
                                        Elsif i.burden_cost_changed_flag = 'Y' and (i.bl_rw_cost_rate in (1,0) )
					       and i.bl_burd_rate NOT IN (1) Then
					    If (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0) <> 0) Then
					       If nvl(l_raw_cost_tab(l_tbl_counter),i.bl_txn_raw_cost) = nvl(l_quantity_tab(l_tbl_counter),0) Then
                                            	l_bd_cost_rate_override_tab(l_tbl_counter) :=
						   (nvl(i.txn_burdened_cost,0) - nvl(i.txn_init_burdened_cost,0))/
						    (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0));
					       Else
						l_bd_cost_rate_override_tab(l_tbl_counter) :=
                                                   (nvl(i.txn_burdened_cost,0) - nvl(i.txn_init_burdened_cost,0))/
                                                    (NVL(l_raw_cost_tab(l_tbl_counter),i.bl_txn_raw_cost)-nvl(i.txn_init_raw_cost,0));
						End If;
					    End If;
                                        End If;
				    Elsif g_wp_version_flag = 'N' and i.burden_rate_changed_flag = 'Y' and i.burden_cost_changed_flag = 'N' then
					   /* ignore the burden rate change for non-rate base resource */
					   l_reCalcbdRt_Tab(l_tbl_counter) := 'Y';
                                           l_bd_cost_rate_override_tab(l_tbl_counter) := NULL;
				    End If; --}
				End If; --}
		   	End If;
		  End If;
	     End If;
	   End LOOP; --}

	/* process records for Non rate base when revenue only entered */
	If g_budget_version_type = 'ALL' Then --{
	   FOR i IN cur_NonRtRas LOOP
		l_tbl_counter := l_tbl_counter + 1;
                l_resource_assignment_tab(l_tbl_counter) := i.resource_assignment_id;
                l_txn_currency_code_tab(l_tbl_counter) := i.txn_currency_code;
		l_start_date_tab(l_tbl_counter) := i.start_date;
                l_end_date_tab(l_tbl_counter) := i.end_date;
                l_quantity_tab(l_tbl_counter) := null;
                l_raw_cost_tab(l_tbl_counter) := null;
                l_burden_cost_tab(l_tbl_counter) := null;
                l_revenue_tab(l_tbl_counter) := null;
                l_revenue_only_flag_tab(l_tbl_counter) := 'N';
                l_reset_rate_based_flag_tab(l_tbl_counter) := 'N';
                l_bd_cost_rate_override_tab(l_tbl_counter) := null;
                l_rw_cost_rate_override_tab(l_tbl_counter) := null;
                l_bill_rate_override_tab(l_tbl_counter) := null;
                l_uom_tab(l_tbl_counter) := i.UOM;
                l_rwRtSetFlag_Tab(l_tbl_counter) := 'N';
                l_bilRtSetFlag_Tab(l_tbl_counter) := 'N';
                l_bdRtSetFlag_tab(l_tbl_counter) := 'N';
		l_reCalcbdRt_Tab(l_tbl_counter) := 'N';
                l_reCalcBilRt_Tab(l_tbl_counter) := 'N';
		l_revenue_only_flag_tab(l_tbl_counter ) := 'N';
		l_costRt_g_miss_num_flag_tab(l_tbl_counter ) := NULL;
                l_burdRt_g_miss_num_flag_tab(l_tbl_counter ) := NULL;
                l_revRt_g_miss_num_flag_tab(l_tbl_counter ) := NULL;
		l_burden_only_flag_tab(l_tbl_counter ) := 'N';
		/*
		print_msg('Looping through RAs for Rate Base flg = N and Resource Rate base flag = N');
		print_msg('bdRtflag['||i.burden_cost_changed_flag||']RwFlag['||i.raw_cost_changed_flag||']');
		print_msg('RevFlag['||i.revenue_changed_flag||']');
		print_msg('currentUOM['||i.currentUOM||']ResUOM['||i.UOM||']');
		*/
		If i.rate_based_flag = 'N' and i.resource_rate_based_flag = 'N' Then
			l_quantity_tab(l_tbl_counter) := i.quantity;
                        if i.resource_rate_based_flag = 'N' AND i.rate_based_flag = 'N' Then
                              l_costRt_g_miss_num_flag_tab(l_tbl_counter) := 'N';
                              l_burdRt_g_miss_num_flag_tab(l_tbl_counter) := 'N';
                              l_revRt_g_miss_num_flag_tab(l_tbl_counter) := 'N';
                        End If;
                        If i.raw_cost_changed_flag = 'Y' Then
				l_quantity_tab(l_tbl_counter) := i.txn_raw_cost;
				l_rw_cost_rate_override_tab(l_tbl_counter) := 1;
				If i.burden_cost_changed_flag = 'Y' Then
				  If (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0) <> 0) Then
                                       l_bd_cost_rate_override_tab(l_tbl_counter) :=
                                         (nvl(i.txn_burdened_cost,0) - nvl(i.txn_init_burdened_cost,0))/
                                         (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0));
                                  End If;
				Elsif i.burden_cost_changed_flag = 'N' and nvl(i.bl_burd_rate,0) in (0,1) Then
				  l_bdRtSetFlag_tab(l_tbl_counter) := 'Y';
				  l_bd_cost_rate_override_tab(l_tbl_counter) := NULL;
				Elsif g_wp_version_flag = 'N' and i.burden_rate_changed_flag = 'Y' and i.burden_cost_changed_flag = 'N' then
                                           /* ignore the burden rate change for non-rate base resource */
                                           l_reCalcbdRt_Tab(l_tbl_counter) := 'Y';
                                           l_bd_cost_rate_override_tab(l_tbl_counter) := NULL;
				End If;

				If i.revenue_changed_flag = 'Y' Then
					If (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0) <> 0) Then
                                                l_bill_rate_override_tab(l_tbl_counter) :=
                                                 (nvl(i.txn_revenue,0) - nvl(i.txn_init_revenue,0)) /
                                                 (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0));
                                        End If;
				Elsif i.revenue_changed_flag = 'N' and nvl(i.bl_bill_rate,0) in (1) Then
					l_bill_rate_override_tab(l_tbl_counter) := NULL;
					l_bilRtSetFlag_tab(l_tbl_counter) := 'Y';
				End If;
			End If;

			If i.burden_cost_changed_flag = 'Y' Then
			    	If i.raw_cost_changed_flag = 'N' and ((NVL(i.bl_rw_cost_rate,0) = 0 and i.bl_txn_raw_cost is NULL) OR (i.txn_init_raw_cost = i.bl_txn_raw_cost) ) Then --Bug 6781055

					l_quantity_tab(l_tbl_counter) := i.txn_burdened_cost;
					l_raw_cost_tab(l_tbl_counter) := i.txn_burdened_cost;
					l_rw_cost_rate_override_tab(l_tbl_counter) := 1;
			        	l_bd_cost_rate_override_tab(l_tbl_counter) := 1;
					l_burden_only_flag_tab(l_tbl_counter ) := 'Y';
			    	Else
					If (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0) <> 0) Then
					  if NVL(l_raw_cost_tab(l_tbl_counter),i.bl_txn_raw_cost) = NVL(l_quantity_tab(l_tbl_counter),0) Then
                                            l_bd_cost_rate_override_tab(l_tbl_counter) :=
                                              (nvl(i.txn_burdened_cost,0) - nvl(i.txn_init_burdened_cost,0))/
                                              (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0));
                                          -- Modified Else to Elsif for Bug# 6784234
					  Elsif (NVL(l_raw_cost_tab(l_tbl_counter),i.bl_txn_raw_cost)-nvl(i.txn_init_raw_cost,0)) <> 0 Then

					    l_bd_cost_rate_override_tab(l_tbl_counter) :=
                                              (nvl(i.txn_burdened_cost,0) - nvl(i.txn_init_burdened_cost,0))/
                                              (NVL(l_raw_cost_tab(l_tbl_counter),i.bl_txn_raw_cost)-nvl(i.txn_init_raw_cost,0));
					  End If;
                                  	End If;
			    	End If;

			    	If i.revenue_changed_flag = 'Y' Then
                                        If (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0) <> 0) Then
                                                l_bill_rate_override_tab(l_tbl_counter) :=
                                                 (nvl(i.txn_revenue,0) - nvl(i.txn_init_revenue,0)) /
                                                 (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0));
                                        End If;
                                Elsif i.revenue_changed_flag = 'N' and nvl(i.bl_bill_rate,0) in (1) Then
                                        l_bill_rate_override_tab(l_tbl_counter) := NULL;
                                        l_bilRtSetFlag_tab(l_tbl_counter) := 'Y';
                                End If;
			End If;

			If i.revenue_changed_flag = 'Y' Then
				If ( (i.bl_rw_cost_rate = 0 OR i.bl_txn_raw_cost is NULL ) OR (i.txn_init_raw_cost = i.bl_txn_raw_cost) ) and NVL(i.bl_burd_rate,0) = 0 --Bug 6781055
				   and i.raw_cost_changed_flag = 'N' and i.burden_cost_changed_flag = 'N' Then
                                        -- revenue only entered for pl resource
                                        l_quantity_tab(l_tbl_counter) := i.txn_revenue;
					l_revenue_only_flag_tab(l_tbl_counter) := 'Y';
					If i.txn_revenue = 0 then
						l_bill_rate_override_tab(l_tbl_counter) := 0;
					Else
						l_bill_rate_override_tab(l_tbl_counter) := 1;
					End If;
				 Else
					If (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0) <> 0) Then
                                                l_bill_rate_override_tab(l_tbl_counter) :=
                                                 (nvl(i.txn_revenue,0) - nvl(i.txn_init_revenue,0)) /
                                                 (NVL(l_quantity_tab(l_tbl_counter),0)-nvl(i.init_quantity,0));
                                        End If;
                                 End If;
                                 if i.cost_rate_changed_flag = 'N' and i.raw_cost_changed_flag = 'N'
 	                                     and i.bl_rw_cost_rate = 0
 	                                     and i.burden_cost_changed_flag = 'N' Then
                                        l_rw_cost_rate_override_tab(l_tbl_counter) := 0;
                                 End If;
                                 if i.burden_rate_changed_flag = 'N' and i.burden_cost_changed_flag = 'N' and i.bl_burd_rate = 0 Then
                                       l_bd_cost_rate_override_tab(l_tbl_counter) := 0;
				 Elsif g_wp_version_flag = 'N' and i.burden_rate_changed_flag = 'Y' and i.burden_cost_changed_flag = 'N' Then
					/* ignore the burden rate change for non-rate base resource */
                                           l_reCalcbdRt_Tab(l_tbl_counter) := 'Y';
                                           l_bd_cost_rate_override_tab(l_tbl_counter) := NULL;
                                 End If;
			Else
			    	if i.bill_rate_changed_flag = 'Y' Then
                              		l_reCalcBilRt_tab(l_tbl_counter) := 'Y';
                              		l_bill_rate_override_tab(l_tbl_counter) := NULL;
				End If;
			End If;
			If g_wp_version_flag = 'N' and i.burden_rate_changed_flag = 'Y' and i.burden_cost_changed_flag = 'N'
				and i.revenue_changed_flag = 'N' and i.raw_cost_changed_flag = 'N' Then
                                           /* ignore the burden rate change for non-rate base resource */
                                           l_reCalcbdRt_Tab(l_tbl_counter) := 'Y';
                                           l_bd_cost_rate_override_tab(l_tbl_counter) := NULL;
			End If;
                End If;
	   END LOOP;
	End If; --}

	   /* Update the RA and set the rate based flag = Y */
       	If x_return_status = 'S' AND l_resource_assignment_tab.COUNT > 0 Then --{

	/*
	for i in l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST loop
	print_msg('Contxt['||p_source_context||']raid['||l_resource_assignment_tab(i)||']');
	print_msg('txnCur['||l_txn_currency_code_tab(i)||']');
	print_msg('ResetFlg['||l_reset_rate_based_flag_tab(i)||']uom['||l_uom_tab(i)||']Qty['||l_quantity_tab(i)||']');
	print_msg('RwCost['||l_raw_cost_tab(i)||']Rt['||l_rw_cost_rate_override_tab(i)||']');
	print_msg('billRt['||l_bill_rate_override_tab(i)||']');
	print_msg('resetCstFlg['||l_rwRtSetFlag_Tab(i)||']resetBilFlg['||l_bilRtSetFlag_Tab(i)||']');
	print_msg('resetBdRtFlg['||l_bdRtSetFlag_Tab(i)||']');
	print_msg('reCalcBdFlag['||l_reCalcBdRt_tab(i)||']reCalcBilRtFlag['||l_reCalcBilRt_tab(i)||']');
	print_msg('RevOnlyFlg['||l_revenue_only_flag_tab(i)||']');
	end loop;
	*/
	     IF p_source_context = 'RESOURCE_ASSIGNMENT' Then

		/* before resetting the rate base flag check whenter budget lines exists for this planning
		 * resource with other currency. if so abort the process
		 */
		DELETE FROM pa_fp_spread_calc_tmp2;
		FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
		INSERT INTO pa_fp_spread_calc_tmp2 tmp2
		   	(budget_version_id
			,resource_assignment_id
			,txn_currency_code
			,task_id
			,resource_name
			)
		SELECT /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP_N1) */ p_budget_version_id
			,tmp.resource_assignment_id
			,tmp.txn_currency_code
			,tmp.task_id
			,tmp.resource_name
		FROM pa_fp_spread_calc_tmp tmp
		WHERE tmp.budget_version_id = p_budget_version_id
		AND tmp.resource_assignment_id = l_resource_assignment_tab(i)
		AND tmp.txn_currency_code = l_txn_currency_code_tab(i)
		AND  l_reset_rate_based_flag_tab(i) = 'Y'
		AND EXISTS (select null
				from pa_budget_lines bl
				WHERE tmp.resource_assignment_id = bl.resource_assignment_id
				AND  (tmp.txn_currency_code <> bl.txn_currency_code
				    OR
				    ( tmp.txn_currency_code = bl.txn_currency_code
				      and nvl(bl.init_quantity,0) <> 0 )
				     )
			   );

	     ELSE  -- source context = BUDGET LINE then

                DELETE FROM pa_fp_spread_calc_tmp2;
                FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
                INSERT INTO pa_fp_spread_calc_tmp2 tmp2
                        (budget_version_id
                        ,resource_assignment_id
                        ,txn_currency_code
                        ,task_id
                        ,resource_name
                        ,start_date
                        ,end_date
                        )
                SELECT /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP_N1) */ p_budget_version_id
                        ,tmp.resource_assignment_id
                        ,tmp.txn_currency_code
                        ,tmp.task_id
                        ,tmp.resource_name
                        ,tmp.start_date
                        ,tmp.end_date
                FROM pa_fp_spread_calc_tmp tmp
                WHERE tmp.budget_version_id = p_budget_version_id
                AND tmp.resource_assignment_id = l_resource_assignment_tab(i)
                AND tmp.txn_currency_code = l_txn_currency_code_tab(i)
		AND tmp.start_date = l_start_date_tab(i)
                AND l_reset_rate_based_flag_tab(i) = 'Y'
                AND EXISTS (select null
                                from pa_budget_lines bl
                                WHERE tmp.resource_assignment_id = bl.resource_assignment_id
                                AND  ( (tmp.txn_currency_code <> bl.txn_currency_code)
				      OR (tmp.txn_currency_code = bl.txn_currency_code
					  --and bl.start_date NOT BETWEEN tmp.start_date and tmp.end_date
					  and nvl(bl.init_quantity,0) <> 0  --7185263
					 ))
                           );
	     END IF;

		/* loop through each record add it to stack and then raise error */
		l_NonRrtRec_Exists_Flg := 'N';
		FOR i IN (SELECT tmp2.resource_assignment_id
				,tmp2.txn_currency_code
				,tmp2.task_id
				,tmp2.resource_name
				,tmp2.start_date
			 FROM pa_fp_spread_calc_tmp2 tmp2
			 WHERE tmp2.budget_version_id = p_budget_version_id ) LOOP --{

			g_stage := 'PA_FP_RATE_BASE_QTY_REQD:RaId['||i.resource_assignment_id||']';
			g_stage := 'Currency['||i.txn_currency_code||']SDate['||i.start_date||']';
                	IF P_PA_DEBUG_MODE = 'Y' Then
                	   print_msg(g_stage);
                	End If;

			PA_UTILS.ADD_MESSAGE
                            (p_app_short_name => 'PA'
                            ,p_msg_name       => 'PA_FP_RATE_BASE_RES_QTY_REQD'
                            ,p_token1         => 'P_BUDGET_VERSION_NAME'
                            ,p_value1         => g_budget_version_name
                            ,p_token2         => 'P_RESOURCE_NAME'
                            ,p_value2         => i.resource_name
                            ,p_token3         => 'P_RESOURCE_ASSIGNMENT'
                            ,p_value3         => i.resource_assignment_id
                            ,p_token4         => 'P_TXN_CURRENCY_CODE'
                            ,p_value4         => i.txn_currency_code
                            ,p_token5         => 'P_START_DATE'
                            ,p_value5         => i.start_date
                            );

			    x_return_status := 'E';
			    l_NonRrtRec_Exists_Flg := 'Y';
		END LOOP; --}

		If l_NonRrtRec_Exists_Flg = 'Y' THEN
			x_return_status := 'E';
			g_stage := 'Found Errors during reset Rate base flag validation: Raising Error';
                        IF P_PA_DEBUG_MODE = 'Y' Then
                           print_msg(g_stage);
                        End If;
			RAISE l_NonRrtRec_Exists_Exception;
		End If;

        	g_stage := 'reset_ratebased_pltrxns:104';
		IF P_PA_DEBUG_MODE = 'Y' Then
        	print_msg(g_stage);
		End If;
        	FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
            		UPDATE PA_RESOURCE_ASSIGNMENTS ra
            		SET ra.rate_based_flag = 'Y'
               		,ra.unit_of_measure = l_uom_tab(i)
            	WHERE ra.resource_assignment_id = l_resource_assignment_tab(i)
		AND l_reset_rate_based_flag_tab(i) = 'Y';
		IF P_PA_DEBUG_MODE = 'Y' Then
		print_msg('reset the override rates in new entity');
		End If;
		FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
			UPDATE PA_RESOURCE_ASGN_CURR rtx
			SET rtx.txn_raw_cost_rate_override = decode(l_rwRtSetFlag_Tab(i),'Y',NULL,rtx.txn_raw_cost_rate_override)
			    ,rtx.txn_bill_rate_override = decode(l_bilRtSetFlag_Tab(i),'Y',NULL,rtx.txn_bill_rate_override)
			    ,rtx.txn_burden_cost_rate_override = decode(l_bdRtSetFlag_Tab(i),'Y',NULL,rtx.txn_burden_cost_rate_override)
			WHERE rtx.resource_assignment_id = l_resource_assignment_tab(i)
                        AND  rtx.txn_currency_code = l_txn_currency_code_tab(i)
			AND  (l_rwRtSetFlag_Tab(i) = 'Y' OR l_bilRtSetFlag_Tab(i) = 'Y' OR l_bdRtSetFlag_Tab(i) = 'Y' )
			AND ( p_source_context = 'RESOURCE_ASSIGNMENT'
			      OR
			      (p_source_context = 'BUDGET_LINE'
				and l_reset_rate_based_flag_tab(i) = 'Y')
			    );
		IF P_PA_DEBUG_MODE = 'Y' Then
		print_msg('reset the override rates in budgetLines');
		End If;
                FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
                        UPDATE PA_BUDGET_LINES bl
                        SET bl.txn_cost_rate_override = decode(l_rwRtSetFlag_Tab(i),'Y',NULL,bl.txn_cost_rate_override)
                            ,bl.txn_bill_rate_override = decode(l_bilRtSetFlag_Tab(i),'Y',NULL,bl.txn_bill_rate_override)
			    ,bl.burden_cost_rate_override = decode(l_bdRtSetFlag_Tab(i),'Y',NULL,bl.burden_cost_rate_override)
                        WHERE bl.resource_assignment_id = l_resource_assignment_tab(i)
                        AND  bl.txn_currency_code = l_txn_currency_code_tab(i)
			AND  ((p_source_context = 'BUDGET_LINE'
				and bl.start_date BETWEEN l_start_date_tab(i) and l_end_date_tab(i))
			      OR
				p_source_context <> 'BUDGET_LINE'
			     )
                        AND  (l_rwRtSetFlag_Tab(i) = 'Y' OR l_bilRtSetFlag_Tab(i) = 'Y' OR l_bdRtSetFlag_Tab(i) = 'Y');
		IF P_PA_DEBUG_MODE = 'Y' Then
        	g_stage := 'reset_ratebased_pltrxns:105';
		End If;
        	/* Now update the rollup tmp with the new qty and raw cost */
        	print_msg('Updating tmp table  with qty = rawcost or burden cost');
        	FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
            		UPDATE /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP_N1) */ pa_fp_spread_calc_tmp tmp
            		SET tmp.quantity = NVL(l_quantity_tab(i),tmp.quantity)
               		,tmp.txn_raw_cost = NVL(l_raw_cost_tab(i),tmp.txn_raw_cost)
               		,tmp.cost_rate_override = decode(l_rwRtSetFlag_Tab(i),'Y',NULL,NVL(l_rw_cost_rate_override_tab(i),tmp.cost_rate_override))
			,tmp.bill_rate_override = decode(l_bilRtSetFlag_Tab(i),'Y',NULL,NVL(l_bill_rate_override_tab(i),tmp.bill_rate_override))
			,tmp.burden_cost_rate_override = decode(l_bdRtSetFlag_Tab(i),'Y',NULL
							   ,decode(l_reCalcBdRt_tab(i),'Y',NULL,NVL(l_bd_cost_rate_override_tab(i),tmp.burden_cost_rate_override)))
			,tmp.burden_rate_changed_flag = decode(l_bdRtSetFlag_Tab(i),'Y',tmp.burden_rate_changed_flag
							   ,decode(l_reCalcBdRt_tab(i),'Y','N',tmp.burden_rate_changed_flag))
			,tmp.burden_rate_g_miss_num_flag = decode(l_bdRtSetFlag_Tab(i),'Y',nvl(l_burdRt_g_miss_num_flag_tab(i),tmp.burden_rate_g_miss_num_flag)
								,decode(l_reCalcBdRt_tab(i),'Y','N'
								  ,nvl(l_burdRt_g_miss_num_flag_tab(i), tmp.burden_rate_g_miss_num_flag)))
			,tmp.bill_rate_changed_flag = decode(l_bilRtSetFlag_tab(i),'Y',tmp.bill_rate_changed_flag
								,decode(l_reCalcBilRt_tab(i),'Y','N',tmp.bill_rate_changed_flag))
			,tmp.revenue_only_entered_flag = l_revenue_only_flag_tab(i)
                        ,tmp.cost_rate_g_miss_num_flag = NVL(l_costRt_g_miss_num_flag_tab(i),tmp.cost_rate_g_miss_num_flag)
                        ,tmp.bill_rate_g_miss_num_flag = NVL(l_revRt_g_miss_num_flag_tab(i),tmp.bill_rate_g_miss_num_flag)
			,tmp.burden_only_entered_flag = l_burden_only_flag_tab(i)
			,(tmp.rate_based_flag
                 	 ,tmp.resource_rate_based_flag
			 ,tmp.resource_UOM) =
                                        (select nvl(ra.rate_based_flag,'N' )
                                                ,nvl(ra.resource_rate_based_flag,'N')
						,l_uom_tab(i)
                                        from pa_resource_assignments ra
                                        where ra.resource_assignment_id = tmp.resource_assignment_id)
			/* bug fix:5116157: to store the reset flag so that correct rate base flag and uom can pass to PJI*/
			,tmp.system_reference_var3 = NVL(l_reset_rate_based_flag_tab(i),'N') -- Reset_Rate_Base_Flag
			/* bug fix:5726773 */
 	                ,tmp.NEG_QUANTITY_CHANGE_FLAG = decode(nvl(l_reset_rate_based_flag_tab(i),'N'),'Y','N'
 	                                                         ,tmp.NEG_QUANTITY_CHANGE_FLAG)
 	                ,tmp.NEG_RAWCOST_CHANGE_FLAG = decode(nvl(l_reset_rate_based_flag_tab(i),'N'),'Y','N'
 	                                                         ,tmp.NEG_RAWCOST_CHANGE_FLAG)
 	                ,tmp.NEG_BURDEN_CHANGE_FALG= decode(nvl(l_reset_rate_based_flag_tab(i),'N'),'Y','N'
 	                                                         ,tmp.NEG_BURDEN_CHANGE_FALG)
 	                ,tmp.NEG_REVENUE_CHANGE_FLAG = decode(nvl(l_reset_rate_based_flag_tab(i),'N'),'Y','N'
 	                                                         ,tmp.NEG_REVENUE_CHANGE_FLAG)
            		WHERE tmp.resource_assignment_id = l_resource_assignment_tab(i)
            		AND  tmp.txn_currency_code = l_txn_currency_code_tab(i)
			AND  ((p_source_context = 'BUDGET_LINE'
                                and tmp.start_date BETWEEN l_start_date_tab(i) and l_end_date_tab(i))
                              OR
                                p_source_context <> 'BUDGET_LINE'
                             );


       	End If; --}
    	g_stage := 'reset_ratebased_pltrxns:107';
	IF P_PA_DEBUG_MODE = 'Y' Then
    	print_msg('Leaving reset_ratebased_pltrxns with retSts['||x_return_status||']');
	End If;
EXCEPTION
	WHEN l_NonRrtRec_Exists_Exception THEN
		x_return_status := 'E';
		RETURN;
        WHEN OTHERS THEN
                x_return_status := 'U';
                print_msg('Failed in Reset_ratebased_pltrxns API'||sqlcode||sqlerrm);
                 fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'Reset_ratebased_pltrxns');
                RAISE;

END Reset_ratebased_pltrxns;


/* This api is added as an enhancement request: For a rate based planning transaction if no quantity is passed
 * then mark the resource as a Non-Rate planning transaction
 * Logic:  For source context Resource assignment: check budget line exists for RAID and Txn cur combo
 * If NO budget line exists and passed in param value of quantity is NULL is then
 *  mark this transaction as NON-RATE based and copy raw cost to quantity
 * For source context Budget Line: check whether the periodic line exists, If not check budget line exists for RA and txn currency
 *  If No budget line exists and user has entered mix and match of qty and amounts
 *  then throw an error:'Enter quantity for rate based planning transaction'
 */
PROCEDURE Check_ratebased_pltrxns(
                p_budget_version_id              IN  Number
                ,p_source_context                IN  pa_fp_res_assignments_tmp.source_context%TYPE
                ,x_return_status                 OUT NOCOPY VARCHAR2
                ) IS

    l_resource_assignment_tab   pa_plsql_datatypes.NumTabTyp;
    l_txn_currency_code_tab     pa_plsql_datatypes.Char50TabTyp;
    l_start_date_tab             pa_plsql_datatypes.DateTabTyp;
    l_end_date_tab               pa_plsql_datatypes.DateTabTyp;
    l_period_name_tab            pa_plsql_datatypes.Char50TabTyp;
    l_quantity_tab              pa_plsql_datatypes.NumTabTyp;
    l_raw_cost_tab              pa_plsql_datatypes.NumTabTyp;
    l_burden_cost_tab           pa_plsql_datatypes.NumTabTyp;
    l_revenue_tab               pa_plsql_datatypes.NumTabTyp;
    l_revenue_only_flag_tab     pa_plsql_datatypes.Char1TabTyp;
    l_burden_only_flag_tab      pa_plsql_datatypes.Char1TabTyp;
    l_costRt_g_miss_num_flag_tab pa_plsql_datatypes.Char1TabTyp;
    l_burdRt_g_miss_num_flag_tab pa_plsql_datatypes.Char1TabTyp;
    l_revRt_g_miss_num_flag_tab  pa_plsql_datatypes.Char1TabTyp;

    l_costRt_changed_flag_tab    pa_plsql_datatypes.Char1TabTyp;
    l_burdRt_changed_flag_tab    pa_plsql_datatypes.Char1TabTyp;
    l_billRt_changed_flag_tab    pa_plsql_datatypes.Char1TabTyp;
    l_uom_tab			 pa_plsql_datatypes.Char50TabTyp;
    l_mark_non_rate_base_flag   Varchar2(1);
    l_exists_flag               Varchar2(1);
    l_tbl_counter               Number;
    l_start_date            DATE;
    l_end_date          DATE;



    Cursor cur_ra IS
    SELECT tmp.resource_assignment_id
        ,tmp.txn_currency_code
        ,tmp.quantity
        ,tmp.txn_raw_cost
        ,tmp.txn_burdened_cost
        ,tmp.txn_revenue
        ,g_budget_version_type  version_type
        ,tmp.start_date
        ,tmp.end_date
        ,rlm.alias
        ,g_budget_version_name  version_name
        ,tmp.bl_quantity
	,ra.resource_rate_based_flag
	,rlm.unit_of_measure uom
	/* bug fix:5726773 */
 	,to_number(null) bl_sum_qty
 	,nvl(tmp.cost_rate_changed_flag,'N') cost_rate_changed_flag
 	,nvl(tmp.burden_rate_changed_flag,'N') burden_rate_changed_flag
 	,nvl(tmp.bill_rate_changed_flag,'N') bill_rate_changed_flag
 	,NVL(tmp.RE_SPREAD_AMTS_FLAG,'N') re_spread_amts_flag
 	,NVL(tmp.SP_CURVE_CHANGE_FLAG,'N') sp_curve_change_flag
 	,NVL(tmp.PLAN_DATES_CHANGE_FLAG,'N') plan_dates_change_flag
 	,NVL(tmp.SP_FIX_DATE_CHANGE_FLAG,'N') sp_fix_date_change_flag
 	,NVL(tmp.MFC_COST_CHANGE_FLAG,'N') mfc_cost_change_flag
 	,NVL(tmp.RLM_ID_CHANGE_FLAG,'N') rlm_id_change_flag
 	,NVL(tmp.delete_bl_flag,'N') delete_bl_flag
 	,NVL(tmp.raw_cost_changed_flag,'N') raw_cost_changed_flag
 	,NVL(tmp.burden_cost_changed_flag,'N') burden_cost_changed_flag
 	,NVL(tmp.revenue_changed_flag,'N') revenue_changed_flag
    FROM pa_fp_spread_calc_tmp tmp
        ,pa_resource_assignments ra
        ,pa_resource_list_members rlm
    WHERE ra.budget_version_id = p_budget_version_id
    AND  ra.resource_assignment_id = tmp.resource_assignment_id
    AND  rlm.resource_list_member_id = ra.resource_list_member_id
    AND  NVL(ra.rate_based_flag,'N') = 'Y'
        AND  NVL(tmp.quantity,0) = 0
    AND NVL(tmp.quantity_changed_flag,'N') = 'N'
    ORDER BY tmp.resource_assignment_id,tmp.txn_currency_code;

    Cursor  cur_bl_chk(p_ra_id Number,p_txn_cur_code Varchar2) IS
    SELECT 'Y'
    FROM dual
    WHERE EXISTS (select null
            from pa_budget_lines bl
                ,pa_resource_assignments ra
            where ra.resource_assignment_id = p_ra_id
            and bl.resource_assignment_id = ra.resource_assignment_id
            and NVL(ra.rate_based_flag,'N') = 'Y'
            /* Bug fix:4083873 and bl.txn_currency_code = p_txn_cur_code */
            and bl.budget_version_id = p_budget_version_id
             );

    Cursor cur_tmp_chk(p_ra_id Number,p_txn_cur_code Varchar2) IS
        SELECT 'Y'
        FROM dual
        WHERE EXISTS (select null
                        from pa_fp_spread_calc_tmp bl
                        where bl.resource_assignment_id = p_ra_id
                        /* Bug fix:4083873 and bl.txn_currency_code = p_txn_cur_code */
            and nvl(bl.quantity,0) <>  0
                     );

    /* Bug fix: 4156225 : For a Non-rate base resource If burden cost only entered then copy
    * burden cost to raw cost and quantity and set rate override as 1
        */
    CURSOR cur_NonRtBaseRa IS
        SELECT tmp.resource_assignment_id
                ,tmp.txn_currency_code
                ,tmp.quantity
                ,tmp.txn_raw_cost
                ,tmp.txn_burdened_cost
                ,tmp.txn_revenue
                ,tmp.start_date
                ,tmp.end_date
        	,tmp.bl_quantity
		,rlm.unit_of_measure uom
        FROM pa_fp_spread_calc_tmp tmp
        ,pa_resource_assignments ra
	,pa_resource_list_members rlm
        WHERE tmp.budget_version_id = p_budget_version_id
        AND   ra.resource_assignment_id = tmp.resource_assignment_id
	AND  rlm.resource_list_member_id = ra.resource_list_member_id
        AND  NVL(ra.rate_based_flag,'N') = 'N'
        AND  ( g_budget_version_type IN ('COST','ALL')
        AND NVL(tmp.quantity,0) = 0
        AND NVL(tmp.txn_raw_cost,0) = 0
        AND ((NVL(tmp.txn_burdened_cost,0) <> 0 )
             OR
             NVL(tmp.txn_revenue,0) <> 0
            )
         )
    AND NOT EXISTS ( select null
            from pa_budget_lines bl
            where bl.budget_version_id = p_budget_version_id
            and   bl.resource_assignment_id = tmp.resource_assignment_id
            and  bl.txn_currency_code = tmp.txn_currency_code
            and  (p_source_context <> 'BUDGET_LINE'
                 OR
                 (p_source_context = 'BUDGET_LINE'
                  and bl.start_date between tmp.start_date and tmp.end_date)
                 )
            );
    l_reset_plsql_tab_flag  VARCHAR2(10) := 'N';

    -- bug 4431269: added the followings
    -- variables to be used to call process_errors in web adi flow.
    l_webadi_task_id                   pa_resource_assignments.task_id%TYPE;
    l_webadi_rlm_id                    pa_resource_assignments.resource_list_member_id%TYPE;
    l_webAdi_context                   VARCHAR2(250) ;

    /* bug fix:5726773 */
    SKIP_RECORD         EXCEPTION;
    l_message_name      VARCHAR2(30);
    l_lkp_code          VARCHAR2(30);

BEGIN
    x_return_status := 'S';
    IF P_PA_DEBUG_MODE = 'Y' Then
    print_msg('start of Check_ratebased_pltrxns API');
    End If;
    g_stage := 'Check_ratebased_pltrxns:100';
    l_webAdi_context := PA_FP_WEBADI_PKG.G_FP_WA_CALC_CALLING_CONTEXT;

       l_resource_assignment_tab.delete;
           l_txn_currency_code_tab.delete;
           l_quantity_tab.delete;
           l_raw_cost_tab.delete;
           l_burden_cost_tab.delete;
           l_revenue_tab.delete;
           l_start_date_tab.delete;
           l_end_date_tab.delete;
	   l_revenue_only_flag_tab.delete;
	   l_costRt_g_miss_num_flag_tab.delete;
           l_burdRt_g_miss_num_flag_tab.delete;
           l_revRt_g_miss_num_flag_tab.delete;
	   l_costRt_changed_flag_tab.delete;
    	   l_burdRt_changed_flag_tab.delete;
    	   l_billRt_changed_flag_tab.delete;
	   l_burden_only_flag_tab.delete;
	   l_uom_tab.delete;
    g_stage := 'Check_ratebased_pltrxns:101';
    --print_msg('Check for Non-rate resource with qty and raw cost are not passed');
    l_tbl_counter := 0;
    /* Start of Bug fix:4156225 process rate based resources */
    /* Bug fix:4214137 If version type is revenue only then plsql tabs are not populated, hence opening cursor fails with
     * ORA-22160: element at index [1] does not exist in Package
     * Fix: Open the cursor only if budget version is cost or all */
    IF g_budget_version_type IN ('COST','ALL') Then
       FOR i IN cur_NonRtBaseRa LOOP
	/*
        print_msg('RA['||i.resource_assignment_id||']Cur['||i.txn_currency_code||']');
	print_msg('qty['||i.quantity||']Raw['||i.txn_raw_cost||']brd['||i.txn_burdened_cost||']');
	*/
        l_tbl_counter := l_tbl_counter +1;
        If p_source_context = 'RESOURCE_ASSIGNMENT' then
                        l_start_date := NULL;
                        l_end_date := NULL;
                Else
                        l_start_date := i.start_date;
                        l_end_date := i.end_date;
                End If;
        l_resource_assignment_tab(l_tbl_counter) := i.resource_assignment_id;
        l_txn_currency_code_tab(l_tbl_counter) := i.txn_currency_code;
        l_start_date_tab(l_tbl_counter)        := i.start_date;
        l_end_date_tab(l_tbl_counter)        := i.end_date;
	l_uom_tab(l_tbl_counter)        := i.uom;
	l_revenue_only_flag_tab(l_tbl_counter) := 'N';
	l_costRt_g_miss_num_flag_tab(l_tbl_counter ) := NULL;
        l_burdRt_g_miss_num_flag_tab(l_tbl_counter ) := NULL;
        l_revRt_g_miss_num_flag_tab(l_tbl_counter ) := NULL;
	l_costRt_changed_flag_tab(l_tbl_counter ) := NULL;
        l_burdRt_changed_flag_tab(l_tbl_counter ) := NULL;
        l_billRt_changed_flag_tab(l_tbl_counter ) := NULL;
	l_burden_only_flag_tab(l_tbl_counter) := 'N';
        IF g_budget_version_type in ('COST') Then
            --print_msg('Assigning burden cost to quantity');
            l_quantity_tab(l_tbl_counter) := i.txn_burdened_cost;
            l_raw_cost_tab(l_tbl_counter) := i.txn_burdened_cost;
	    l_burden_only_flag_tab(l_tbl_counter) := 'Y';
	    l_costRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
	    l_costRt_changed_flag_tab(l_tbl_counter ) := 'N';
	    l_burdRt_changed_flag_tab(l_tbl_counter ) := 'N';
        Elsif g_budget_version_type in ('ALL') Then
            If NVL(i.txn_burdened_cost,0) <> 0 Then
               --print_msg('Assigning burden cost to quantity');
               l_quantity_tab(l_tbl_counter) := i.txn_burdened_cost;
               l_raw_cost_tab(l_tbl_counter) := i.txn_burdened_cost;
		l_burden_only_flag_tab(l_tbl_counter) := 'Y';
	        l_costRt_changed_flag_tab(l_tbl_counter ) := 'N';
                l_burdRt_changed_flag_tab(l_tbl_counter ) := 'N';
		l_billRt_changed_flag_tab(l_tbl_counter ) := 'N';
	       l_costRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
        	l_burdRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
        	l_revRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
            Else
               --print_msg('Assigning Revenue to quantity');
                l_quantity_tab(l_tbl_counter) := i.txn_revenue;
                l_raw_cost_tab(l_tbl_counter) := i.txn_revenue;
		l_revenue_only_flag_tab(l_tbl_counter) := 'Y';
		l_costRt_changed_flag_tab(l_tbl_counter ) := 'N';
                l_burdRt_changed_flag_tab(l_tbl_counter ) := 'N';
		l_billRt_changed_flag_tab(l_tbl_counter ) := 'N';
		l_costRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
                l_burdRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
                l_revRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
            End If;
        End If;
       END LOOP;
       IF l_resource_assignment_tab.COUNT > 0 Then
        g_stage := 'Check_ratebased_pltrxns:102';
        --print_msg(g_stage);
        l_reset_plsql_tab_flag := 'Y';
        FORALL i IN l_resource_assignment_tab.FIRST ..l_resource_assignment_tab.LAST
            UPDATE /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP_N1) */ pa_fp_spread_calc_tmp tmp
                        SET tmp.quantity = l_quantity_tab(i)
                           ,tmp.txn_raw_cost = decode(nvl(tmp.txn_raw_cost,0),0,l_raw_cost_tab(i),tmp.txn_raw_cost)
               		   ,tmp.cost_rate_override = decode(l_revenue_only_flag_tab(i),'Y',0,1)
			   ,tmp.burden_cost_rate_override = decode(l_revenue_only_flag_tab(i),'Y',0
						,decode(g_wp_version_flag,'Y',tmp.burden_cost_rate_override
						 , decode(nvl(tmp.burden_cost_changed_flag,'N'),'N',NULL,tmp.burden_cost_rate_override)))
			   ,tmp.revenue_only_entered_flag = l_revenue_only_flag_tab(i)
			   ,tmp.cost_rate_g_miss_num_flag = NVL(l_costRt_g_miss_num_flag_tab(i),tmp.cost_rate_g_miss_num_flag)
			   ,tmp.burden_rate_g_miss_num_flag = nvl(l_burdRt_g_miss_num_flag_tab(i),tmp.burden_rate_g_miss_num_flag)
                           ,tmp.bill_rate_g_miss_num_flag = NVL(l_revRt_g_miss_num_flag_tab(i),tmp.bill_rate_g_miss_num_flag)
			   ,tmp.cost_rate_changed_flag = nvl(l_costRt_changed_flag_tab(i),tmp.cost_rate_changed_flag)
			   ,tmp.burden_rate_changed_flag = Nvl(l_burdRt_changed_flag_tab(i),tmp.burden_rate_changed_flag)
			   ,tmp.bill_rate_changed_flag = nvl(l_billRt_changed_flag_tab(i),tmp.bill_rate_changed_flag)
			   ,tmp.burden_only_entered_flag = l_burden_only_flag_tab(i)
                        WHERE tmp.resource_assignment_id = l_resource_assignment_tab(i)
                        AND  tmp.txn_currency_code = l_txn_currency_code_tab(i)
                        AND  ((p_source_context = 'RESOURCE_ASSIGNMENT')
                              OR
                              (p_source_context = 'BUDGET_LINE'
                               and tmp.start_date = l_start_date_tab(i)
                               and tmp.end_date = l_end_date_tab(i)
                             ));
       End If;
    END IF;
    /* end of bug fix: 4156225 */
    IF P_PA_DEBUG_MODE = 'Y' Then
    print_msg('Check for Rateresource with qty and raw cost are not passed');
    End If;
    /* process rate based resources */
    l_tbl_counter := 0;
    l_resource_assignment_tab.delete;
        l_txn_currency_code_tab.delete;
        l_quantity_tab.delete;
        l_raw_cost_tab.delete;
        l_burden_cost_tab.delete;
        l_revenue_tab.delete;
        l_start_date_tab.delete;
        l_end_date_tab.delete;
	l_revenue_only_flag_tab.delete;
	l_costRt_g_miss_num_flag_tab.delete;
        l_burdRt_g_miss_num_flag_tab.delete;
        l_revRt_g_miss_num_flag_tab.delete;
	l_costRt_changed_flag_tab.delete;
           l_burdRt_changed_flag_tab.delete;
           l_billRt_changed_flag_tab.delete;
	 l_burden_only_flag_tab.delete;
	 l_uom_tab.delete;
    g_stage := 'Check_ratebased_pltrxns:103';

    FOR i IN cur_ra LOOP
	BEGIN  --{ bug fix:5726773
      -- bug 4431269: initializing the following variables to null
      IF l_webAdi_context = 'WEBADI_CALCULATE' AND
         (l_webadi_task_id IS NOT NULL OR l_webadi_rlm_id IS NOT NULL) THEN
          l_webadi_task_id := null;
          l_webadi_rlm_id  := null;
      END IF;

      IF (NVl(i.txn_raw_cost,0) = 0
             AND NVL(i.txn_burdened_cost,0) = 0
             AND NVL(i.txn_revenue,0) = 0) THEN       --{
                 --this is a new record, needs to be skipped
                 NULL;
      ELSIF (i.re_spread_amts_flag = 'Y'
 	                 or i.sp_curve_change_flag = 'Y'
 	                 or i.plan_dates_change_flag = 'Y'
 	                 or i.sp_fix_date_change_flag = 'Y'
 	                 or i.mfc_cost_change_flag = 'Y'
 	                 or i.rlm_id_change_flag = 'Y'
 	                 or i.delete_bl_flag = 'Y' ) Then
 	                 -- Resource attribute changed, so skip this record
 	                 NULL;
 	       ELSIF ((i.version_type in ('COST','ALL')
 	                 and i.raw_cost_changed_flag = 'N'
 	                 and i.burden_cost_changed_flag ='N'
 	                 and i.revenue_changed_flag = 'N') OR
 	              (i.version_type = 'REVENUE' and i.revenue_changed_flag = 'N')) Then
 	                 -- amounts are not changed so skip this record
 	                 NULL;
      ELSE
	-- amounts only changed for a rate based resource
 	         IF P_PA_DEBUG_MODE = 'Y' Then
 	                 print_msg('amounts only changed for rate based planning resource:'||i.resource_assignment_id);
 	         End If;
        If p_source_context = 'RESOURCE_ASSIGNMENT' then
            l_start_date := NULL;
                        l_end_date := NULL;
        Else
            l_start_date := i.start_date;
            l_end_date := i.end_date;
        End If;

	/* bug fix:5726773 */
 	         get_bl_sum
 	                 (p_budget_version_id => p_budget_version_id
 	                 ,p_ra_id        => i.resource_assignment_id
 	                 ,p_txn_cur_code => i.txn_currency_code
 	                 ,p_source_context  =>p_source_context
 	                 ,p_start_date      => l_start_date
 	                 ,p_end_date        => l_end_date
 	                 ,x_bl_qty_sum  => i.bl_sum_qty );

        If p_source_context = 'BUDGET_LINE' Then
            If i.bl_quantity is NULL and  NVL(i.quantity,0) = 0 Then
               print_msg('periodic budget lines not exists, now check at least budget line exists for ra ');
               l_mark_non_rate_base_flag := 'N';
               l_exists_flag := 'N';
               OPEN cur_bl_chk(i.resource_assignment_id,i.txn_currency_code);
               FETCH cur_bl_chk INTO l_exists_flag;
               CLOSE cur_bl_chk;

	       /*bug fix:5726773 */
 	                If i.bl_sum_qty = 0 and l_exists_flag = 'Y' Then
 	                  If ((i.version_type in ('COST','ALL') and i.cost_rate_changed_flag = 'Y')
 	                      OR (i.version_type = 'REVENUE' and i.bill_rate_changed_flag = 'Y')) Then
 	                         print_msg('By passing planning resource record from Check Rate base resource@BUDGET-lINE');
 	                         RAISE SKIP_RECORD;
 	                  End If;
 	                End If;

               If NVL(l_exists_flag,'N') = 'Y' Then
                print_msg('budget line exists and user has entered only the amounts so throw an error');
 	                      /*bug fix:5726773 */
 	                         If i.bl_sum_qty = 0 and l_exists_flag = 'Y' Then
 	                            If g_Plan_Class_Type = 'BUDGET' Then
 	                                 l_message_name := 'PA_FP_RATE_BASE_PLAN_QTY_REQD';
 	                                 l_lkp_code := 'PA_FP_WA_CAL_NO_QTY_ERR';
 	                            Else
 	                                 l_message_name := 'PA_FP_RATE_BASE_ETC_QTY_REQD';
 	                                 l_lkp_code := 'PA_FP_WA_CAL_NO_ETCQTY_ERR';
 	                            End If;
 	                         Else
 	                                 l_message_name :='PA_FP_RATE_BASE_QTY_REQD';
 	                                 l_lkp_code := 'PA_FP_WA_CAL_NO_QTY_ERR';
 	                         End If;
                    -- bug 4431269: added the following condition
                    IF l_webAdi_context = 'WEBADI_CALCULATE' THEN
                        -- getting task_id and rlm_id for the corresponding ra_id
                        -- only for the invalid records
                        SELECT pra.task_id,
                               pra.resource_list_member_id
                        INTO   l_webadi_task_id,
                               l_webadi_rlm_id
                        FROM   pa_resource_assignments pra
                        WHERE  pra.resource_assignment_id = i.resource_assignment_id
                        AND    pra.budget_version_id = p_budget_version_id;
                        -- populating the error tables.
                        --print_msg('1100.1.1.1:Web ADI context populating errors');
                        PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.EXTEND(1);
			--bug fix:5726773 PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                        --(PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).error_code   := 'PA_FP_WA_CAL_NO_QTY_ERR';
			PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
			(PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).error_code := l_lkp_code;
 	                         PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
 	                           (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).task_id      := l_webadi_task_id;
 	                         PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
 	                           (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).rlm_id       := l_webadi_rlm_id;
 	                         PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
 	                           (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).txn_currency := i.txn_currency_code;
                    ELSE

                          PA_UTILS.ADD_MESSAGE
                            (p_app_short_name => 'PA'
                            ,p_msg_name       => l_message_name
                            ,p_token1         => 'P_BUDGET_VERSION_NAME'
                            ,p_value1         => i.version_name
                            ,p_token2         => 'P_RESOURCE_NAME'
                            ,p_value2         => i.alias
                            ,p_token3         => 'P_RESOURCE_ASSIGNMENT'
                            ,p_value3         => i.resource_assignment_id
                            );
                    END IF;
                    x_return_status := 'E';
               Else
                l_exists_flag := 'N';
                OPEN cur_tmp_chk(i.resource_assignment_id,i.txn_currency_code);
                            FETCH cur_tmp_chk INTO l_exists_flag;
                            CLOSE cur_tmp_chk;
                If NVL(l_exists_flag,'N') = 'Y' Then
                     print_msg('user has entered mix and match of qty and amounts so throw an error');
 	                         /*bug fix:5726773 */
 	                         If i.bl_sum_qty = 0 and l_exists_flag = 'Y' Then
 	                            If g_Plan_Class_Type = 'BUDGET' Then
 	                                 l_message_name := 'PA_FP_RATE_BASE_PLAN_QTY_REQD';
 	                                 l_lkp_code := 'PA_FP_WA_CAL_NO_QTY_ERR';
 	                            Else
 	                                 l_message_name := 'PA_FP_RATE_BASE_ETC_QTY_REQD';
 	                                 l_lkp_code := 'PA_FP_WA_CAL_NO_ETCQTY_ERR';
 	                            End If;
 	                         Else
 	                                 l_message_name :='PA_FP_RATE_BASE_QTY_REQD';
 	                                 l_lkp_code := 'PA_FP_WA_CAL_NO_QTY_ERR';
 	                         End If;
                     -- bug 4431269: added the following condition
                    IF l_webAdi_context = 'WEBADI_CALCULATE' THEN
                        -- getting task_id and rlm_id for the corresponding ra_id
                        -- only for the invalid records
                        SELECT pra.task_id,
                               pra.resource_list_member_id
                        INTO   l_webadi_task_id,
                               l_webadi_rlm_id
                        FROM   pa_resource_assignments pra
                        WHERE  pra.resource_assignment_id = i.resource_assignment_id
                        AND    pra.budget_version_id = p_budget_version_id;
                        -- populating the error tables.
                        --print_msg('1100.1.1.1:Web ADI context populating errors');
                        PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.EXTEND(1);
			--bug fix:5726773 added new lookup code :l_lkp_code to display based on plan class type
			--PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
			--(PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).error_code   := 'PA_FP_WA_CAL_NO_QTY_ERR';
			PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
 	                           (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).error_code := l_lkp_code;
 	                         PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
 	                           (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).task_id      := l_webadi_task_id;
 	                         PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
 	                           (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).rlm_id       := l_webadi_rlm_id;
 	                         PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
 	                           (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).txn_currency := i.txn_currency_code;
                    ELSE
                                      PA_UTILS.ADD_MESSAGE
                                (p_app_short_name => 'PA'
                                        ,p_msg_name       => l_message_name
                                        ,p_token1         => 'P_BUDGET_VERSION_NAME'
                                        ,p_value1         => i.version_name
                                        ,p_token2         => 'P_RESOURCE_NAME'
                                        ,p_value2         => i.alias
                                        ,p_token3         => 'P_RESOURCE_ASSIGNMENT'
                                        ,p_value3         => i.resource_assignment_id
                                        );
                    END IF;
                    x_return_status := 'E';
                Else
                    --print_msg('Mark this transaction as Non-Rate based');
                    l_mark_non_rate_base_flag := 'Y';
                End If;
               End If;
            End If;
        End If;

        /* Now populate the local plsql tabls to copy the costs to qty and make trx as non-rate base */
                IF ( p_source_context = 'RESOURCE_ASSIGNMENT' OR l_mark_non_rate_base_flag = 'Y' ) Then
                        If i.bl_quantity is NULL and  NVL(i.quantity,0) = 0 Then

              /* Check budgetline exists for this resource with other currency */
              If p_source_context = 'RESOURCE_ASSIGNMENT' Then
                l_exists_flag := 'N';
                            OPEN cur_bl_chk(i.resource_assignment_id,i.txn_currency_code);
                            FETCH cur_bl_chk INTO l_exists_flag;
                            CLOSE cur_bl_chk;

			    /*bug fix:5726773 */
 	                         If i.bl_sum_qty = 0 and l_exists_flag = 'Y' Then
 	                          If ((i.version_type in ('COST','ALL') and i.cost_rate_changed_flag = 'Y')
 	                            OR (i.version_type = 'REVENUE' and i.bill_rate_changed_flag = 'Y')) Then
 	                               print_msg('By passing planning resource record from Check Rate base resource@BUDGET-lINE');
 	                               RAISE SKIP_RECORD;
 	                          End If;
 	                         End If;

 	                         If i.bl_sum_qty = 0 and l_exists_flag = 'Y' Then
 	                            If g_Plan_Class_Type = 'BUDGET' Then
 	                                 l_message_name := 'PA_FP_RATE_BASE_PLAN_QTY_REQD';
 	                                 l_lkp_code := 'PA_FP_WA_CAL_NO_QTY_ERR';
 	                            Else
 	                                 l_message_name := 'PA_FP_RATE_BASE_ETC_QTY_REQD';
 	                                 l_lkp_code := 'PA_FP_WA_CAL_NO_ETCQTY_ERR';
 	                            End If;
 	                         Else
 	                                 l_message_name :='PA_FP_RATE_BASE_QTY_REQD';
 	                                 l_lkp_code := 'PA_FP_WA_CAL_NO_QTY_ERR';
 	                         End If;
 	                         /* end of bug fix:5726773 */

                            If NVL(l_exists_flag,'N') = 'Y' Then
                                      PA_UTILS.ADD_MESSAGE
                                (p_app_short_name => 'PA'
                                        ,p_msg_name       => l_message_name
                                        ,p_token1         => 'P_BUDGET_VERSION_NAME'
                                        ,p_value1         => i.version_name
                                        ,p_token2         => 'P_RESOURCE_NAME'
                                        ,p_value2         => i.alias
                                        ,p_token3         => 'P_RESOURCE_ASSIGNMENT'
                                        ,p_value3         => i.resource_assignment_id
                                        );
                                        x_return_status := 'E';
                End If;
               End If;
               IF x_return_status = 'S'  Then  --{
                                print_msg('No budget lines exists, User has entered only the amounts for rate based trxn');
                                l_tbl_counter := l_tbl_counter +1;
                                l_resource_assignment_tab(l_tbl_counter) := i.resource_assignment_id;
                                l_txn_currency_code_tab(l_tbl_counter) := i.txn_currency_code;
				l_uom_tab(l_tbl_counter) := i.Uom;
                                l_quantity_tab(l_tbl_counter) := i.quantity;
                                l_raw_cost_tab(l_tbl_counter) := i.txn_raw_cost;
                                l_burden_cost_tab(l_tbl_counter) := i.txn_burdened_cost;
                                l_revenue_tab(l_tbl_counter) := i.txn_revenue;
                                l_start_date_tab(l_tbl_counter) := i.start_date;
                                l_end_date_tab(l_tbl_counter) := i.end_date;
				l_revenue_only_flag_tab(l_tbl_counter) := 'N';
				l_costRt_g_miss_num_flag_tab(l_tbl_counter ) := NULL;
                		l_burdRt_g_miss_num_flag_tab(l_tbl_counter ) := NULL;
                		l_revRt_g_miss_num_flag_tab(l_tbl_counter ) := NULL;
				l_burden_only_flag_tab(l_tbl_counter) := 'N';
                                IF i.version_type = 'ALL' Then
                                   If nvl(i.txn_raw_cost,0) = 0
                                      and nvl(i.txn_burdened_cost,0) = 0
                                      and nvl(i.txn_revenue,0) <> 0 Then
                                        -- revenue only entered so copy this to quantity
                                        l_quantity_tab(l_tbl_counter) := i.txn_revenue;
					l_revenue_only_flag_tab(l_tbl_counter) := 'Y';
					l_costRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
                			l_burdRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
                			l_revRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
					l_costRt_changed_flag_tab(l_tbl_counter ) := 'N';
                			l_burdRt_changed_flag_tab(l_tbl_counter ) := 'N';
                			l_billRt_changed_flag_tab(l_tbl_counter ) := 'N';
                                   Elsif nvl(i.txn_raw_cost,0) = 0
                                        and nvl(i.txn_burdened_cost,0) <> 0 Then
                                        -- only burden and revenu is entered so copy burden to raw and qty
                                        l_quantity_tab(l_tbl_counter) := i.txn_burdened_cost;
                                        l_raw_cost_tab(l_tbl_counter) := i.txn_burdened_cost;
					l_burden_only_flag_tab(l_tbl_counter) := 'Y';
					l_costRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
                			l_burdRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
                			l_revRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
					l_costRt_changed_flag_tab(l_tbl_counter ) := 'N';
                			l_burdRt_changed_flag_tab(l_tbl_counter ) := 'N';
                			l_billRt_changed_flag_tab(l_tbl_counter ) := 'N';
                                   Elsif nvl(i.txn_raw_cost,0) <> 0 Then
                                        l_quantity_tab(l_tbl_counter) := i.txn_raw_cost;
					l_costRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
                                        l_burdRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
                                        l_revRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
					l_costRt_changed_flag_tab(l_tbl_counter ) := 'N';
                			l_burdRt_changed_flag_tab(l_tbl_counter ) := 'N';
                			l_billRt_changed_flag_tab(l_tbl_counter ) := 'N';
                                   End If;
                                Elsif i.version_type = 'COST' Then
                                   If nvl(i.txn_raw_cost,0) = 0
                                        and nvl(i.txn_burdened_cost,0) <> 0 Then
                                        -- only burden cost is entered so copy burden to raw and qty
                                        l_quantity_tab(l_tbl_counter) := i.txn_burdened_cost;
                                        l_raw_cost_tab(l_tbl_counter) := i.txn_burdened_cost;
					l_burden_only_flag_tab(l_tbl_counter) := 'Y';
					l_costRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
                                        l_burdRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
                                        l_revRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
					l_costRt_changed_flag_tab(l_tbl_counter ) := 'N';
                			l_burdRt_changed_flag_tab(l_tbl_counter ) := 'N';
                			l_billRt_changed_flag_tab(l_tbl_counter ) := 'N';
                                   Elsif nvl(i.txn_raw_cost,0) <> 0 Then
                                        l_quantity_tab(l_tbl_counter) := i.txn_raw_cost;
					l_costRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
                                        l_burdRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
                                        l_revRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
					l_costRt_changed_flag_tab(l_tbl_counter ) := 'N';
                			l_burdRt_changed_flag_tab(l_tbl_counter ) := 'N';
                			l_billRt_changed_flag_tab(l_tbl_counter ) := 'N';
                                   End If;
                                Elsif i.version_type = 'REVENUE' Then
                                   If  nvl(i.txn_revenue,0) <> 0 Then
                                        -- revenue only entered so copy this to quantity
                                        l_quantity_tab(l_tbl_counter) := i.txn_revenue;
					l_costRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
                                        l_burdRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
                                        l_revRt_g_miss_num_flag_tab(l_tbl_counter ) := 'N';
					l_costRt_changed_flag_tab(l_tbl_counter ) := 'N';
                			l_burdRt_changed_flag_tab(l_tbl_counter ) := 'N';
                			l_billRt_changed_flag_tab(l_tbl_counter ) := 'N';
                                   End If;
                                End if;
                           End If;
            End If; --}
        End IF;
       END IF; --}

       EXCEPTION
 	          WHEN SKIP_RECORD then
 	                 NULL;
 	END; --}
    END LOOP;

    IF l_resource_assignment_tab.count > 0 Then
       If x_return_status = 'S' Then
        g_stage := 'Check_ratebased_pltrxns:104';
        l_reset_plsql_tab_flag := 'Y';

        /* bug fix:5088944: When rate base resource changed to Non-rate base then clear out any override rates present */
        --print_msg('Updating Resource asgn curr table clear out rate overrides');
        FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
                UPDATE pa_resource_asgn_curr rtx
                SET rtx.txn_raw_cost_rate_override = NULL
                   ,rtx.txn_burden_cost_rate_override = NULL
                   ,rtx.txn_bill_rate_override = NULL
                WHERE rtx.resource_assignment_id = l_resource_assignment_tab(i)
                AND rtx.txn_currency_code = l_txn_currency_code_tab(i)
                AND EXISTS ( select null
                                from pa_resource_assignments ra
                                where ra.rate_based_flag = 'Y'
                                and ra.resource_assignment_id = rtx.resource_assignment_id
                        );

        /* update the resource assignments mark it as Non-Rate based */
	IF P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Updating RA with Non-Rate base flag');
	End If;
        FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
            UPDATE PA_RESOURCE_ASSIGNMENTS ra
            SET ra.rate_based_flag = 'N'
               ,ra.unit_of_measure = 'DOLLARS'
            WHERE ra.resource_assignment_id = l_resource_assignment_tab(i);

        g_stage := 'Check_ratebased_pltrxns:105';
        /* Now update the rollup tmp with the new qty and raw cost */
	IF P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Updating rollup tmp with qty = rawcost or burden cost');
	End If;
        FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
            UPDATE /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP_N1) */ pa_fp_spread_calc_tmp tmp
            SET tmp.quantity = l_quantity_tab(i)
               ,tmp.txn_raw_cost = decode(nvl(tmp.txn_raw_cost,0),0,l_raw_cost_tab(i),tmp.txn_raw_cost)
	       ,tmp.cost_rate_override = decode(nvl(l_revenue_only_flag_tab(i),'N'),'Y',0
					   ,decode(nvl(l_burden_only_flag_tab(i),'N'),'Y',1,tmp.cost_rate_override))
	       ,tmp.burden_cost_rate_override = decode(l_revenue_only_flag_tab(i),'Y',0
                                                ,decode(g_wp_version_flag,'Y',tmp.burden_cost_rate_override
                                                 , decode(nvl(tmp.burden_cost_changed_flag,'N'),'N',NULL,tmp.burden_cost_rate_override)))
	       ,tmp.revenue_only_entered_flag = l_revenue_only_flag_tab(i)
		,tmp.cost_rate_g_miss_num_flag = NVL(l_costRt_g_miss_num_flag_tab(i),tmp.cost_rate_g_miss_num_flag)
               ,tmp.burden_rate_g_miss_num_flag = nvl(l_burdRt_g_miss_num_flag_tab(i),tmp.burden_rate_g_miss_num_flag)
               ,tmp.bill_rate_g_miss_num_flag = NVL(l_revRt_g_miss_num_flag_tab(i),tmp.bill_rate_g_miss_num_flag)
		,tmp.cost_rate_changed_flag = nvl(l_costRt_changed_flag_tab(i),tmp.cost_rate_changed_flag)
                ,tmp.burden_rate_changed_flag = Nvl(l_burdRt_changed_flag_tab(i),tmp.burden_rate_changed_flag)
                ,tmp.bill_rate_changed_flag = nvl(l_billRt_changed_flag_tab(i),tmp.bill_rate_changed_flag)
		,tmp.burden_only_entered_flag = l_burden_only_flag_tab(i)
		,(tmp.rate_based_flag
		 ,tmp.resource_rate_based_flag
		 ,tmp.resource_uom) =
					(select nvl(ra.rate_based_flag,'N' )
						,nvl(ra.resource_rate_based_flag,'N')
						,l_uom_tab(i)
					from pa_resource_assignments ra
					where ra.resource_assignment_id = tmp.resource_assignment_id)
            WHERE tmp.resource_assignment_id = l_resource_assignment_tab(i)
            AND  tmp.txn_currency_code = l_txn_currency_code_tab(i)
            AND  ((p_source_context = 'RESOURCE_ASSIGNMENT')
                  OR
                  (p_source_context = 'BUDGET_LINE'
                   and tmp.start_date = l_start_date_tab(i)
                   and tmp.end_date = l_end_date_tab(i)
                 ));
       End If;
    END If;
    g_stage := 'Check_ratebased_pltrxns:107';
	IF P_PA_DEBUG_MODE = 'Y' Then
    	print_msg('Leaving Check_ratebased_pltrxns with retSts['||x_return_status||']');
	End if;
        RETURN;
EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                print_msg('Failed in Check_ratebased_pltrxns API'||sqlcode||sqlerrm);
                 fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'Check_ratebased_pltrxns');
                RAISE;
END Check_ratebased_pltrxns;

/* Bug fix:5483430: This API checks at lease one period exists between planning start and end date
 * Logic: If time phase code is GL
 *  Check at lease one gl period exists between the planning resource assignment dates
 *  If the time phase code is PA
 *  Check at least one PA period exists between the planning resource assignment dates
 *  If the time phase is none then donot check as the period make no sense for non-time phase budgets
 *  For a fixed date spread curve, period must be defined for the sp_fixed_date
 */
PROCEDURE Check_GLPA_periods_exists(
                        p_budget_verson_id  IN NUMBER
                        ,p_time_phase_code  IN VARCHAR2
                        ,x_return_status    OUT NOCOPY VARCHAR2
                        ,x_msg_data         OUT NOCOPY VARCHAR2
                        ) IS

	CURSOR get_name_and_type_csr IS
        SELECT gsb.period_set_name 		period_set_name
                ,gsb.accounted_period_type	accounted_period_type
                ,pia.pa_period_type		pa_period_type
         FROM gl_sets_of_books          gsb
                ,pa_implementations_all pia
                ,pa_projects_all        ppa
                ,pa_budget_versions     pbv
                ,pa_proj_fp_options     ppfo
        WHERE ppa.project_id        = pbv.project_id
          AND pbv.budget_version_id = ppfo.fin_plan_version_id
          AND ppa.org_id   = pia.org_id
          AND gsb.set_of_books_id   = pia.set_of_books_id
          AND pbv.budget_version_id = p_budget_verson_id;

	periodDetailsRec 	get_name_and_type_csr%rowtype;

	CURSOR get_ra_error_details IS
	SELECT ra.resource_assignment_id
		,ra.task_id
		,DECODE(ra.spread_curve_id,6,ra.sp_fixed_date
			,decode(LEAST(NVL(g_etc_start_date,ra.planning_start_date),ra.planning_end_date),ra.planning_end_date,ra.planning_start_date,NVL(g_etc_start_date,ra.planning_start_date))) planning_start_date   --Bug#6936782
		,DECODE(ra.spread_curve_id,6,ra.sp_fixed_date,ra.planning_end_date) planning_end_date
		,tmp.task_name
		,tmp.resource_name
	FROM pa_resource_assignments ra
	    ,pa_fp_spread_calc_tmp tmp
	WHERE ra.budget_version_id = p_budget_verson_id
	AND  ra.resource_assignment_id = tmp.resource_assignment_id
	AND NOT EXISTS
		(SELECT 'No period exist'
        	FROM gl_periods gp
        	WHERE gp.period_set_name  = periodDetailsRec.period_set_name
        	AND gp.period_type        = decode(p_time_phase_code,'G',periodDetailsRec.accounted_period_type
							,'P',periodDetailsRec.pa_period_type)
        	AND gp.adjustment_period_flag = 'N'
        	AND gp.start_date  <= decode(nvl(ra.spread_curve_id,1),6
					 ,ra.sp_fixed_date,ra.planning_end_date)   -- plan end date
        	AND  gp.end_date   >= decode(nvl(ra.spread_curve_id,1),6
					,ra.sp_fixed_date,decode(LEAST(NVL(g_etc_start_date,ra.planning_start_date),ra.planning_end_date),ra.planning_end_date,ra.planning_start_date,NVL(g_etc_start_date,ra.planning_start_date)))
					-- planning start date Bug#6936782
		);

BEGIN
	x_return_status := 'S';
	x_msg_data := NULL;
	IF p_time_phase_code IN ('G','P') Then
		/* get set of book details from implementation setups */
		OPEN get_name_and_type_csr;
		FETCH get_name_and_type_csr INTO periodDetailsRec;
		IF get_name_and_type_csr%NOTFOUND THEN
			--raise others;
			null;
		END If;
		CLOSE get_name_and_type_csr;

		/* loop through each record for which no period has been defined in GL / PA
		* populate error message for each planning resource
		*/
		FOR i IN get_ra_error_details LOOP
            		x_return_status := 'E';
            		PA_UTILS.ADD_MESSAGE
            		(p_app_short_name => 'PA'
                        ,p_msg_name      => 'PA_FP_PERIODS_IS_NULL'
            		,p_token1         => 'L_PROJECT_NAME'
                        ,p_value1         => g_project_name
                        ,p_token2         => 'L_TASK_NAME'
                        ,p_value2         => i.task_name
                        ,p_token3         => 'L_RESOURCE_NAME'
                        ,p_value3         => i.resource_name
                        ,p_token4         => 'L_LINE_START_DATE'
                        ,p_value4         => i.planning_start_date
                        ,p_token5        => 'L_LINE_END_DATE'
                        ,p_value5        => i.planning_end_date
            		);
		END LOOP;
	Else
		NULL;
	END If;
	IF P_PA_DEBUG_MODE = 'Y' Then
         print_msg('End of Check_GLPA_periods_exists api ReturnStatus['||x_return_status||']');
        End If;

EXCEPTION

        WHEN OTHERS THEN
                x_return_status := 'U';
                print_msg('Failed in Check_GLPA_periods_exists API'||sqlcode||sqlerrm);
                 fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'Check_GLPA_periods_exists');
                RAISE;

END Check_GLPA_periods_exists;


/* This API will process the Non-Time phased budget lines */
PROCEDURE process_NonTimePhase_Lines
                  (p_budget_version_id         IN Number
                  ,p_time_phased_code          IN Varchar2
                  ,p_apply_progress_flag       IN Varchar2
                  ,p_source_context            IN Varchar2
                  ,x_return_status             OUT NOCOPY Varchar2
                  ,x_msg_data                  OUT NOCOPY Varchar2
                  ) IS

        l_budget_line_id_tab       pa_plsql_datatypes.NumTabTyp;
        l_resAsgn_id_tab           pa_plsql_datatypes.NumTabTyp;
        l_txn_curr_code_tab        pa_plsql_datatypes.Char50TabTyp;
        l_start_date_tab           pa_plsql_datatypes.dateTabTyp;
        l_end_date_tab             pa_plsql_datatypes.dateTabTyp;
        l_rwCounter                INTEGER;

    CURSOR cur_blCorrupted IS
    SELECT tmp.resource_assignment_id
          ,tmp.txn_currency_code
          ,ra.planning_start_date
          ,ra.planning_end_date
          ,rl.alias resource_name
    FROM  pa_fp_spread_calc_tmp tmp
         ,pa_resource_assignments ra
         ,pa_resource_list_members rl
    WHERE tmp.budget_version_id = p_budget_version_id
    AND   ra.resource_assignment_id = tmp.resource_assignment_id
    AND   rl.resource_list_member_id = ra.resource_list_member_id
    AND   EXISTS ( select null
            from pa_budget_lines bl
            where bl.budget_version_id = p_budget_version_id
            and bl.resource_assignment_id = tmp.resource_assignment_id
            and bl.txn_currency_code = tmp.txn_currency_code
            group by bl.resource_assignment_id,bl.txn_currency_code
            having count(*) > 1
             );

    CURSOR cur_NonTimePhLines IS
    SELECT /*+ INDEX(BL PA_BUDGET_LINES_U1) */ bl.budget_line_id
                ,bl.resource_assignment_id
                ,bl.txn_currency_code
                ,bl.start_date
                ,bl.end_date
                ,bl.period_name
                ,bl.budget_version_id
                ,bl.quantity bl_quantity
                ,bl.txn_standard_cost_rate
                ,bl.txn_cost_rate_override
                ,bl.txn_raw_cost
                ,bl.burden_cost_rate
                ,bl.burden_cost_rate_override
                ,bl.txn_burdened_cost
                ,bl.txn_standard_bill_rate
                ,bl.txn_bill_rate_override
                ,bl.txn_revenue
                ,bl.project_currency_code
                ,bl.project_raw_cost
                ,bl.project_burdened_cost
                ,bl.project_revenue
                ,bl.projfunc_currency_code
                ,bl.raw_cost
                ,bl.burdened_cost
                ,bl.revenue
                ,bl.cost_rejection_code
                ,bl.burden_rejection_code
                ,bl.revenue_rejection_code
                ,bl.pc_cur_conv_rejection_code
                ,bl.pfc_cur_conv_rejection_code
                ,bl.init_quantity  bl_init_quantity
                ,bl.txn_init_raw_cost
                ,bl.txn_init_burdened_cost
                ,bl.txn_init_revenue
                ,tmp.new_plan_start_date   plan_start_date
        ,tmp.new_plan_end_date    plan_end_date
        FROM pa_budget_lines bl
            ,pa_fp_spread_calc_tmp tmp
        WHERE bl.budget_version_id = p_budget_version_id
        AND  bl.resource_assignment_id = tmp.resource_assignment_id
        AND  bl.txn_currency_code = tmp.txn_currency_code
    AND  NVL(tmp.plan_dates_change_flag,'N') = 'Y'
    AND  NVL(tmp.system_reference_var1,'N') = 'Y'  --ResourceWithMultiCurrency
    AND  ( (bl.start_date <> trunc(tmp.new_plan_start_date))
          OR
           (bl.end_date <> trunc(tmp.new_plan_end_date))
         );

    l_r_budget_line_id_tab          pa_plsql_datatypes.NumTabTyp;
        l_r_assignment_id_tab           pa_plsql_datatypes.NumTabTyp;
        l_r_txn_currency_code_tab       pa_plsql_datatypes.Char30TabTyp;
        l_r_start_date_tab          pa_plsql_datatypes.DateTabTyp;
        l_r_end_date_tab            pa_plsql_datatypes.DateTabTyp;
        l_r_period_name_tab         pa_plsql_datatypes.Char50TabTyp;
        l_r_quantity_tab            pa_plsql_datatypes.NumTabTyp;
        l_r_txn_raw_cost_tab            pa_plsql_datatypes.NumTabTyp;
        l_r_txn_burdened_cost_tab       pa_plsql_datatypes.NumTabTyp;
        l_r_txn_revenue_tab         pa_plsql_datatypes.NumTabTyp;
        l_r_project_currency_code_tab       pa_plsql_datatypes.Char30TabTyp;
        l_r_project_raw_cost_tab        pa_plsql_datatypes.NumTabTyp;
        l_r_project_burdened_cost_tab       pa_plsql_datatypes.NumTabTyp;
        l_r_project_revenue_tab         pa_plsql_datatypes.NumTabTyp;
        l_r_projfunc_currency_code_tab      pa_plsql_datatypes.Char30TabTyp;
        l_r_raw_cost_tab            pa_plsql_datatypes.NumTabTyp;
        l_r_burdened_cost_tab           pa_plsql_datatypes.NumTabTyp;
        l_r_revenue_tab             pa_plsql_datatypes.NumTabTyp;
        l_r_cost_rejection_code_tab     pa_plsql_datatypes.Char30TabTyp;
        l_r_burden_rejection_code_tab       pa_plsql_datatypes.Char30TabTyp;
        l_r_revenue_rejection_code_tab      pa_plsql_datatypes.Char30TabTyp;
        l_r_pc_cur_rejection_code_tab       pa_plsql_datatypes.Char30TabTyp;
        l_r_pfc_cur_rejection_code_tab      pa_plsql_datatypes.Char30TabTyp;


    Procedure InitReturningPlsqlTabls IS

    Begin
        l_r_budget_line_id_tab.delete;
            l_r_assignment_id_tab.delete;
            l_r_txn_currency_code_tab.delete;
            l_r_start_date_tab.delete;
            l_r_end_date_tab.delete;
            l_r_period_name_tab.delete;
            l_r_quantity_tab.delete;
            l_r_txn_raw_cost_tab.delete;
            l_r_txn_burdened_cost_tab.delete;
            l_r_txn_revenue_tab.delete;
            l_r_project_currency_code_tab.delete;
            l_r_project_raw_cost_tab.delete;
            l_r_project_burdened_cost_tab.delete;
            l_r_project_revenue_tab.delete;
            l_r_projfunc_currency_code_tab.delete;
            l_r_raw_cost_tab.delete;
            l_r_burdened_cost_tab.delete;
            l_r_revenue_tab.delete;
            l_r_cost_rejection_code_tab.delete;
            l_r_burden_rejection_code_tab.delete;
            l_r_revenue_rejection_code_tab.delete;
            l_r_pc_cur_rejection_code_tab.delete;
            l_r_pfc_cur_rejection_code_tab.delete;

    End InitReturningPlsqlTabls;


BEGIN
    x_return_status := 'S';
    x_msg_data      := NULL;

    IF (p_time_phased_code NOT IN ('P','G') AND p_source_context <> 'BUDGET_LINE') Then  --{
        FOR i IN cur_blCorrupted LOOP
            x_return_status := 'E';
            PA_UTILS.ADD_MESSAGE
            (p_app_short_name => 'PA'
                        ,p_msg_name      => 'PA_FP_MULTI_NON_PERIOD'
            ,p_token1         => 'L_PROJECT_NAME'
                        ,p_value1         => g_project_name
                        ,p_token2         => 'L_TASK_NAME'
                        ,p_value2         => null
                        ,p_token3         => 'L_RESOURCE_NAME'
                        ,p_value3         => i.resource_name
                        ,p_token4         => 'L_LINE_START_DATE'
                        ,p_value4         => i.planning_start_date
                        ,p_token5        => 'L_LINE_END_DATE'
                        ,p_value5        => i.planning_end_date
            );

        END LOOP;
        IF x_return_status = 'S' Then  --{
           l_budget_line_id_tab.delete;
               l_resAsgn_id_tab.delete;
               l_txn_curr_code_tab.delete;
               l_start_date_tab.delete;
               l_end_date_tab.delete;
               l_rwCounter := 0;
           FOR i IN cur_NonTimePhLines LOOP
                   /* populate the plsql tabs for bulk update of budget lines later */
                   l_rwCounter := l_rwCounter + 1;
                   l_budget_line_id_tab(l_rwCounter) := i.budget_line_id;
                   l_resAsgn_id_tab(l_rwCounter) := i.resource_assignment_id;
                   l_txn_curr_code_tab(l_rwCounter) := i.txn_currency_code;
                   l_start_date_tab(l_rwCounter) := i.plan_start_date;
                   l_end_date_tab(l_rwCounter) := i.plan_end_date;

                   IF (g_rollup_required_flag = 'Y'
		       /* bug fix:5031388
                       AND i.cost_rejection_code is NULL
                       AND i.burden_rejection_code is NULL
                       AND i.revenue_rejection_code is NULL
                       AND i.pc_cur_conv_rejection_code is NULL
                       AND i.pfc_cur_conv_rejection_code is NULL */
		      	)  Then

                       /* before updating the existing budget line call the reporting API to pass -ve amts */
                       PA_FP_CALC_PLAN_PKG.Add_Toreporting_Tabls
                       (p_calling_module               => 'CALCULATE_API'
                       ,p_activity_code                => 'UPDATE'
                       ,p_budget_version_id            => p_budget_version_id
                       ,p_budget_line_id               => i.budget_line_id
                       ,p_resource_assignment_id       => i.resource_assignment_id
                       ,p_start_date                   => i.start_date
                       ,p_end_date                     => i.end_date
                       ,p_period_name                  => i.period_name
                       ,p_txn_currency_code            => i.txn_currency_code
                       ,p_quantity                     => i.bl_quantity *-1
                       ,p_txn_raw_cost                 => i.txn_raw_cost *-1
                       ,p_txn_burdened_cost            => i.txn_burdened_cost *-1
                       ,p_txn_revenue                  => i.txn_revenue *-1
                       ,p_project_currency_code        => i.project_currency_code
                       ,p_project_raw_cost             => i.project_raw_cost *-1
                       ,p_project_burdened_cost        => i.project_burdened_cost *-1
                       ,p_project_revenue              => i.project_revenue *-1
                       ,p_projfunc_currency_code       => i.projfunc_currency_code
                       ,p_projfunc_raw_cost            => i.raw_cost *-1
                       ,p_projfunc_burdened_cost       => i.burdened_cost *-1
                       ,p_projfunc_revenue             => i.revenue *-1
			,p_rep_line_mode               => 'REVERSAL'
                       ,x_msg_data                     => x_msg_data
                       ,x_return_status                => x_return_status
                       );
                  End If;
              END LOOP;
          IF l_budget_line_id_tab.COUNT > 0 THEN  --{
            InitReturningPlsqlTabls;
            --print_msg('Updating budget lines with planning start and end dates for Non-TimePhase budget');
            FORALL i IN l_budget_line_id_tab.FIRST .. l_budget_line_id_tab.LAST
            UPDATE PA_BUDGET_LINES bl
            SET bl.start_date = NVL(l_start_date_tab(i),bl.start_date)
               ,bl.end_date   = NVL(l_end_date_tab(i),bl.end_date)
            WHERE bl.budget_version_id = p_budget_version_id
            AND  bl.budget_line_id = l_budget_line_id_tab(i)
            RETURNING
             bl.budget_line_id
            ,bl.resource_assignment_id
            ,bl.txn_currency_code
            ,bl.start_date
            ,bl.end_date
            ,bl.period_name
            ,bl.quantity
            ,bl.txn_raw_cost
            ,bl.txn_burdened_cost
            ,bl.txn_revenue
            ,bl.project_currency_code
            ,bl.project_raw_cost
            ,bl.project_burdened_cost
            ,bl.project_revenue
            ,bl.projfunc_currency_code
            ,bl.raw_cost
            ,bl.burdened_cost
            ,bl.revenue
            ,bl.cost_rejection_code
                        ,bl.burden_rejection_code
                        ,bl.revenue_rejection_code
                        ,bl.pc_cur_conv_rejection_code
                        ,bl.pfc_cur_conv_rejection_code
            BULK COLLECT INTO
                l_r_budget_line_id_tab
                            ,l_r_assignment_id_tab
                            ,l_r_txn_currency_code_tab
                            ,l_r_start_date_tab
                            ,l_r_end_date_tab
                            ,l_r_period_name_tab
                            ,l_r_quantity_tab
                            ,l_r_txn_raw_cost_tab
                            ,l_r_txn_burdened_cost_tab
                            ,l_r_txn_revenue_tab
                            ,l_r_project_currency_code_tab
                            ,l_r_project_raw_cost_tab
                            ,l_r_project_burdened_cost_tab
                            ,l_r_project_revenue_tab
                            ,l_r_projfunc_currency_code_tab
                            ,l_r_raw_cost_tab
                            ,l_r_burdened_cost_tab
                            ,l_r_revenue_tab
                            ,l_r_cost_rejection_code_tab
                            ,l_r_burden_rejection_code_tab
                            ,l_r_revenue_rejection_code_tab
                            ,l_r_pc_cur_rejection_code_tab
                            ,l_r_pfc_cur_rejection_code_tab ;
            /* Now pass the +ve values to pji rollup api */
            IF g_rollup_required_flag = 'Y' Then  --{
            IF l_r_budget_line_id_tab.COUNT > 0 Then
                    FOR i IN l_r_budget_line_id_tab.FIRST .. l_r_budget_line_id_tab.LAST LOOP
                          IF (g_rollup_required_flag = 'Y'
			   /* bug fix:5031388
                           AND l_r_cost_rejection_code_tab(i) is NULL
                           AND l_r_burden_rejection_code_tab(i) is NULL
                           AND l_r_revenue_rejection_code_tab(i) is NULL
                           AND l_r_pc_cur_rejection_code_tab(i) is NULL
                           AND l_r_pfc_cur_rejection_code_tab(i) is NULL */
				)  Then

                           /* After updating the budget line dates, pass the +ve values */
                           PA_FP_CALC_PLAN_PKG.Add_Toreporting_Tabls
                           (p_calling_module               => 'CALCULATE_API'
                           ,p_activity_code                => 'UPDATE'
                           ,p_budget_version_id            => p_budget_version_id
                           ,p_budget_line_id               => l_r_budget_line_id_tab(i)
                           ,p_resource_assignment_id       => l_r_assignment_id_tab(i)
                           ,p_start_date                   => l_r_start_date_tab(i)
                           ,p_end_date                     => l_r_end_date_tab(i)
                           ,p_period_name                  => l_r_period_name_tab(i)
                           ,p_txn_currency_code            => l_r_txn_currency_code_tab(i)
                           ,p_quantity                     => l_r_quantity_tab(i)
                           ,p_txn_raw_cost                 => l_r_txn_raw_cost_tab(i)
                           ,p_txn_burdened_cost            => l_r_txn_burdened_cost_tab(i)
                           ,p_txn_revenue                  => l_r_txn_revenue_tab(i)
                           ,p_project_currency_code        => l_r_project_currency_code_tab(i)
                           ,p_project_raw_cost             => l_r_project_raw_cost_tab(i)
                           ,p_project_burdened_cost        => l_r_project_burdened_cost_tab(i)
                           ,p_project_revenue              => l_r_project_revenue_tab(i)
                           ,p_projfunc_currency_code       => l_r_projfunc_currency_code_tab(i)
                           ,p_projfunc_raw_cost            => l_r_raw_cost_tab(i)
                           ,p_projfunc_burdened_cost       => l_r_burdened_cost_tab(i)
                           ,p_projfunc_revenue             => l_r_revenue_tab(i)
			   ,p_rep_line_mode               => 'POSITIVE_ENTRY'
                           ,x_msg_data                     => x_msg_data
                           ,x_return_status                => x_return_status
                           );
                       End If;
                      END LOOP;
              END IF;
              /* release the buffer */
              InitReturningPlsqlTabls;
              END If; --}
          END IF; --}
        END IF; --}
    END IF; --}
	IF P_PA_DEBUG_MODE = 'Y' Then
         print_msg('End of process_NonTimePhase_Lines api ReturnStatus['||x_return_status||']');
	End If;

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                x_msg_data := sqlcode||sqlerrm;
                print_msg('Failed in process_NonTimePhase_Lines API'||x_msg_data);
                 fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'process_NonTimePhase_Lines');
                RAISE;
END process_NonTimePhase_Lines;

/* This API deletes all the budget lines which falls beyond the planning start and end dates
*/
PROCEDURE delete_budget_lines(
        p_budget_version_id             IN Number
                ,p_budget_version_type          IN Varchar2
                ,p_rollup_required_flag         IN Varchar2
        ,p_process_mode                 IN Varchar2
                ,x_return_status                OUT NOCOPY Varchar2
                ,x_msg_data                     OUT NOCOPY Varchar2
                ) IS
        /* This cursor picks all the budget lines which falls beyond the plan dates
         * where actual donot exists and deletes the records from pa_budget_lines table
         */
        CURSOR cur_Delbl_Lines IS
        SELECT /*+ INDEX(BL PA_BUDGET_LINES_U1) */ bl.budget_line_id
                ,bl.resource_assignment_id
                ,bl.txn_currency_code
                ,bl.start_date
                ,bl.end_date
                ,bl.period_name
                ,bl.budget_version_id
                ,bl.quantity bl_quantity
                ,bl.txn_standard_cost_rate
                ,bl.txn_cost_rate_override
                ,bl.txn_raw_cost
                ,bl.burden_cost_rate
                ,bl.burden_cost_rate_override
                ,bl.txn_burdened_cost
                ,bl.txn_standard_bill_rate
                ,bl.txn_bill_rate_override
                ,bl.txn_revenue
                ,bl.project_currency_code
                ,bl.project_raw_cost
                ,bl.project_burdened_cost
                ,bl.project_revenue
                ,bl.projfunc_currency_code
                ,bl.raw_cost
                ,bl.burdened_cost
                ,bl.revenue
                ,bl.cost_rejection_code
                ,bl.burden_rejection_code
                ,bl.revenue_rejection_code
                ,bl.pc_cur_conv_rejection_code
                ,bl.pfc_cur_conv_rejection_code
                ,bl.init_quantity  bl_init_quantity
                ,bl.txn_init_raw_cost
                ,bl.txn_init_burdened_cost
                ,bl.txn_init_revenue
        ,tmp.start_date  plan_start_date ,tmp.end_date plan_end_date
        FROM pa_budget_lines bl
            ,pa_fp_rollup_tmp tmp
        WHERE bl.budget_version_id = p_budget_version_id
        AND  bl.resource_assignment_id = tmp.resource_assignment_id
        AND  bl.txn_currency_code = tmp.txn_currency_code
    AND  NVL(tmp.processed_flag,'N') = 'Y'
    AND  ( NVL(bl.init_quantity,0) = 0
        and NVL(bl.txn_init_raw_cost,0) = 0
        and NVL(bl.txn_init_burdened_cost,0) = 0
        and NVL(bl.txn_init_revenue,0) = 0
         )
        AND  (( p_process_mode = 'PLAN_START_DATE'
        AND NVL(plan_Start_Date_shrunk_flag,'N') = 'Y'
            AND bl.end_date  < tmp.start_date )
         OR (p_process_mode = 'PLAN_END_DATE'
        AND NVL(plan_End_Date_shrunk_flag,'N') = 'Y'
        AND bl.start_date > tmp.END_DATE)
        );

    l_budget_line_id_tab       pa_plsql_datatypes.NumTabTyp;
        l_resAsgn_id_tab           pa_plsql_datatypes.NumTabTyp;
        l_txn_curr_code_tab        pa_plsql_datatypes.Char50TabTyp;
        l_start_date_tab           pa_plsql_datatypes.dateTabTyp;
    l_rwCounter                INTEGER;
    l_populate_mrc_tab_flag   Varchar2(10) := 'N';  --MRC Elimination Changes:NVL(PA_FP_CALC_PLAN_PKG.G_populate_mrc_tab_flag,'N');
BEGIN
        x_return_status := 'S';
        /* Initialize the error stack */
    If p_pa_debug_mode = 'Y' Then
            pa_debug.init_err_stack('PA_FP_CALC_UTILS.delete_budget_lines');
    End If;

    --print_msg('Entered delete_budget_lines api');
        /* Initialize the plsql tabs */
        l_budget_line_id_tab.delete;
        l_resAsgn_id_tab.delete;
        l_txn_curr_code_tab.delete;
        l_start_date_tab.delete;
        l_rwCounter := 0;

        FOR i IN cur_Delbl_Lines LOOP  --{
        --print_msg('Loop for bdgetlined['||i.budget_line_id||']curCode['||i.txn_currency_code||']plSd['||i.plan_start_date||']plEd['||i.plan_end_date||']');
           /* populate the plsql tabs for bulk update of budget lines later */
           l_rwCounter := l_rwCounter + 1;
           l_budget_line_id_tab(l_rwCounter) := i.budget_line_id;
           l_resAsgn_id_tab(l_rwCounter) := i.resource_assignment_id;
           l_txn_curr_code_tab(l_rwCounter) := i.txn_currency_code;
           l_start_date_tab(l_rwCounter) := i.start_date;

           IF (p_rollup_required_flag = 'Y'
		/* bug fix:5031388
                AND i.cost_rejection_code is NULL
                AND i.burden_rejection_code is NULL
                AND i.revenue_rejection_code is NULL
                AND i.pc_cur_conv_rejection_code is NULL
                AND i.pfc_cur_conv_rejection_code is NULL */
		 )  Then

                /* before updating the existing budget line call the reporting API to pass -ve amts */
                PA_FP_CALC_PLAN_PKG.Add_Toreporting_Tabls
                (p_calling_module               => 'CALCULATE_API'
                ,p_activity_code                => 'UPDATE'
                ,p_budget_version_id            => p_budget_version_id
                ,p_budget_line_id               => i.budget_line_id
                ,p_resource_assignment_id       => i.resource_assignment_id
                ,p_start_date                   => i.start_date
                ,p_end_date                     => i.end_date
                ,p_period_name                  => i.period_name
                ,p_txn_currency_code            => i.txn_currency_code
                ,p_quantity                     => i.bl_quantity *-1
                ,p_txn_raw_cost                 => i.txn_raw_cost *-1
                ,p_txn_burdened_cost            => i.txn_burdened_cost *-1
                ,p_txn_revenue                  => i.txn_revenue *-1
                ,p_project_currency_code        => i.project_currency_code
                ,p_project_raw_cost             => i.project_raw_cost *-1
                ,p_project_burdened_cost        => i.project_burdened_cost *-1
                ,p_project_revenue              => i.project_revenue *-1
                ,p_projfunc_currency_code       => i.projfunc_currency_code
                ,p_projfunc_raw_cost            => i.raw_cost *-1
                ,p_projfunc_burdened_cost       => i.burdened_cost *-1
                ,p_projfunc_revenue             => i.revenue *-1
		,p_rep_line_mode               => 'REVERSAL'
                ,x_msg_data                     => x_msg_data
                ,x_return_status                => x_return_status
                );
          End If;

      /* Added for MRC enhancements */
          IF NVL(l_populate_mrc_tab_flag,'N') = 'Y' Then --{
        PA_FP_CALC_PLAN_PKG.populate_MRC_plsqltabs
                (p_calling_module               => 'CALCULATE_API'
                ,p_budget_version_id            => p_budget_version_id
                ,p_budget_line_id               => i.budget_line_id
                ,p_resource_assignment_id       => i.resource_assignment_id
                ,p_start_date                   => i.start_date
                ,p_end_date                     => i.end_date
                ,p_period_name                  => i.period_name
                ,p_txn_currency_code            => i.txn_currency_code
                ,p_quantity                     => i.bl_quantity
                ,p_txn_raw_cost                 => i.txn_raw_cost
                ,p_txn_burdened_cost            => i.txn_burdened_cost
                ,p_txn_revenue                  => i.txn_revenue
                ,p_project_currency_code        => i.project_currency_code
                ,p_project_raw_cost             => i.project_raw_cost
                ,p_project_burdened_cost        => i.project_burdened_cost
                ,p_project_revenue              => i.project_revenue
                ,p_projfunc_currency_code       => i.projfunc_currency_code
                ,p_projfunc_raw_cost            => i.raw_cost
                ,p_projfunc_burdened_cost       => i.burdened_cost
                ,p_projfunc_revenue             => i.revenue
        ,p_delete_flag                  => 'Y'
                ,x_msg_data                     => x_msg_data
                ,x_return_status                => x_return_status
                );
      End If;

    END LOOP;

    print_msg('Number of budgetLines deleted['||l_budget_line_id_tab.COUNT||']');
    /* Now delete the budget lines */
    IF l_budget_line_id_tab.COUNT > 0 THEN
        FORALL i IN l_budget_line_id_tab.FIRST .. l_budget_line_id_tab.LAST
        DELETE FROM PA_BUDGET_LINES bl
        WHERE bl.budget_version_id = p_budget_version_id
        AND bl.budget_line_id = l_budget_line_id_tab(i);
    END IF;

    --print_msg('ReturnStatus['||x_return_status||']');
        /* reset the error stack */
    If p_pa_debug_mode = 'Y' Then
            pa_debug.reset_err_stack;
    End If;

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                x_msg_data := sqlcode||sqlerrm;
                print_msg('Failed in delete_budget_lines API'||x_msg_data);
        If p_pa_debug_mode = 'Y' Then
                    pa_debug.reset_err_stack;
        End If;
                 fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'delete_budget_lines');
                RAISE;
END delete_budget_lines ;

/* This API inserts a new budget line with the given quantity for new budget line dates
 * If duplicate line exists then updates the existing line by adding the given quantity
 */
PROCEDURE insert_budget_lines(
        p_budget_version_id             IN Number
        ,p_budget_version_type          IN Varchar2
        ,p_rollup_required_flag         IN Varchar2
        ,x_return_status                OUT NOCOPY Varchar2
        ,x_msg_data                     OUT NOCOPY Varchar2
        ) IS

    CURSOR cur_Oldbl_Lines IS
    SELECT /*+ INDEX(BL PA_BUDGET_LINES_U1) */ bl.budget_line_id
        ,bl.resource_assignment_id
        ,bl.txn_currency_code
        ,bl.start_date
        ,bl.end_date
        ,bl.period_name
        ,bl.budget_version_id
        ,bl.quantity bl_quantity
        ,bl.txn_standard_cost_rate
        ,bl.txn_cost_rate_override
        ,bl.txn_raw_cost
        ,bl.burden_cost_rate
        ,bl.burden_cost_rate_override
        ,bl.txn_burdened_cost
        ,bl.txn_standard_bill_rate
        ,bl.txn_bill_rate_override
        ,bl.txn_revenue
        ,bl.project_currency_code
        ,bl.project_raw_cost
        ,bl.project_burdened_cost
        ,bl.project_revenue
        ,bl.projfunc_currency_code
        ,bl.raw_cost
        ,bl.burdened_cost
        ,bl.revenue
        ,bl.cost_rejection_code
        ,bl.burden_rejection_code
        ,bl.revenue_rejection_code
        ,bl.pc_cur_conv_rejection_code
        ,bl.pfc_cur_conv_rejection_code
        ,bl.init_quantity  bl_init_quantity
        ,bl.txn_init_raw_cost
        ,bl.txn_init_burdened_cost
        ,bl.txn_init_revenue
        ,tmp.quantity  fp_quantity
    FROM pa_budget_lines bl
        ,pa_fp_rollup_tmp tmp
    WHERE bl.budget_version_id = p_budget_version_id
    AND  bl.resource_assignment_id = tmp.resource_assignment_id
    AND  bl.txn_currency_code = tmp.txn_currency_code
    AND  bl.start_date = tmp.start_date
    AND  NVL(tmp.quantity,0) <> 0 ;

    /* This cursor picks all the records from rollup tmp where budget line donot exists
     * and insert these records into budget lines */
    CURSOR cur_newtmp_lines IS
    SELECT PA_BUDGET_LINES_S.NEXTVAL
           ,tmp.resource_assignment_id
           ,tmp.txn_currency_code
           ,tmp.start_date
           ,tmp.end_date
        ,tmp.period_name
        ,tmp.quantity
        ,tmp.project_currency_code
        ,tmp.projfunc_currency_code
    FROM pa_fp_rollup_tmp tmp
    WHERE tmp.budget_version_id = p_budget_version_id
    AND NOT EXISTS
        (SELECT null
        FROM pa_budget_lines bl
        WHERE bl.budget_version_id = p_budget_version_id
        AND  bl.resource_assignment_id = tmp.resource_assignment_id
            AND  bl.txn_currency_code = tmp.txn_currency_code
            AND  bl.start_date = tmp.start_date
        );

    l_budget_line_id_tab       pa_plsql_datatypes.NumTabTyp;
    l_resAsgn_id_tab           pa_plsql_datatypes.NumTabTyp;
    l_txn_curr_code_tab        pa_plsql_datatypes.Char50TabTyp;
    l_start_date_tab           pa_plsql_datatypes.dateTabTyp;
    l_end_date_tab             pa_plsql_datatypes.dateTabTyp;
    l_period_name_tab      pa_plsql_datatypes.Char50TabTyp;
    l_quantity_tab             pa_plsql_datatypes.NumTabTyp;
    l_proj_curr_code_tab       pa_plsql_datatypes.Char50TabTyp;
    l_projfunc_curr_code_tab   pa_plsql_datatypes.Char50TabTyp;
    l_txn_raw_cost_tab     pa_plsql_datatypes.NumTabTyp;
    l_txn_burden_cost_tab      pa_plsql_datatypes.NumTabTyp;
    l_txn_revenue_tab      pa_plsql_datatypes.NumTabTyp;

    l_rwCounter        Number;
    l_populate_mrc_tab_flag   Varchar2(10) := 'N'; --MRC Elimination changes:NVL(PA_FP_CALC_PLAN_PKG.G_populate_mrc_tab_flag,'N');

BEGIN

    x_return_status := 'S';
    /* Initialize the error stack */
    If p_pa_debug_mode = 'Y' Then
        pa_debug.init_err_stack('PA_FP_CALC_UTILS.insert_budget_lines');
    End If;
    --print_msg('Entered insert_budget_lines api');
        /* Initialize the plsql tabs */
        l_budget_line_id_tab.delete;
        l_resAsgn_id_tab.delete;
        l_txn_curr_code_tab.delete;
        l_start_date_tab.delete;
        l_end_date_tab.delete;
        l_period_name_tab.delete;
        l_quantity_tab.delete;
        l_proj_curr_code_tab.delete;
        l_projfunc_curr_code_tab.delete;
    l_txn_raw_cost_tab.delete;
    l_txn_burden_cost_tab.delete;
    l_txn_revenue_tab.delete;
    l_rwCounter := 0;

    FOR i IN cur_Oldbl_Lines LOOP  --{

       --print_msg('Inside Loop OldbdgtLineId['||i.budget_line_id||']Qty['||i.bl_quantity||']FpQty['||i.fp_quantity||']');
       /* populate the plsql tabs for bulk update of budget lines later */
       l_rwCounter := l_rwCounter + 1;
       l_budget_line_id_tab(l_rwCounter) := i.budget_line_id;
       l_resAsgn_id_tab(l_rwCounter) := i.resource_assignment_id;
       l_txn_curr_code_tab(l_rwCounter) := i.txn_currency_code;
       l_start_date_tab(l_rwCounter) := i.start_date;
       l_end_date_tab(l_rwCounter) := i.end_date;
       l_period_name_tab(l_rwCounter) := i.period_name;
       l_quantity_tab(l_rwCounter) :=  nvl(i.fp_quantity,0);
       IF p_budget_version_type in ('ALL','COST') Then
            l_txn_raw_cost_tab(l_rwCounter) := pa_currency.round_trans_currency_amt1((((nvl(i.bl_quantity,0)-nvl(i.bl_init_quantity,0) + nvl(i.fp_quantity,0))*
                                        nvl(i.txn_cost_rate_override,i.txn_standard_cost_rate)) +nvl(i.txn_init_raw_cost,0)),i.txn_currency_code);
                l_txn_burden_cost_tab(l_rwCounter) := pa_currency.round_trans_currency_amt1((((nvl(i.bl_quantity,0)-nvl(i.bl_init_quantity,0) + nvl(i.fp_quantity,0))*
                                        nvl(i.burden_cost_rate_override,i.burden_cost_rate)) + nvl(i.txn_init_burdened_cost,0)),i.txn_currency_code);
       ELSE
        l_txn_raw_cost_tab(l_rwCounter) := NULL;
        l_txn_burden_cost_tab(l_rwCounter) := NULL;
       END IF;
       IF p_budget_version_type in ('ALL','REVENUE') Then
                l_txn_revenue_tab(l_rwCounter) := pa_currency.round_trans_currency_amt1((((nvl(i.bl_quantity,0)-nvl(i.bl_init_quantity,0) + nvl(i.fp_quantity,0))*
                                        nvl(i.txn_bill_rate_override,i.txn_standard_bill_rate)) +nvl(i.txn_init_revenue,0)),i.txn_currency_code);
       Else
        l_txn_revenue_tab(l_rwCounter) := NULL;
       End If;

       IF (p_rollup_required_flag = 'Y'
	/* bug fix:5031388
        AND i.cost_rejection_code is NULL
        AND i.burden_rejection_code is NULL
        AND i.revenue_rejection_code is NULL
        AND i.pc_cur_conv_rejection_code is NULL
        AND i.pfc_cur_conv_rejection_code is NULL */
	 )  Then

        /* before updating the existing budget line call the reporting API to pass -ve amts */
        PA_FP_CALC_PLAN_PKG.Add_Toreporting_Tabls
                (p_calling_module               => 'CALCULATE_API'
                ,p_activity_code                => 'UPDATE'
                ,p_budget_version_id            => p_budget_version_id
                ,p_budget_line_id               => i.budget_line_id
                ,p_resource_assignment_id       => i.resource_assignment_id
                ,p_start_date                   => i.start_date
                ,p_end_date                     => i.end_date
                ,p_period_name                  => i.period_name
                ,p_txn_currency_code            => i.txn_currency_code
                ,p_quantity                     => i.bl_quantity *-1
                ,p_txn_raw_cost                 => i.txn_raw_cost *-1
                ,p_txn_burdened_cost            => i.txn_burdened_cost *-1
                ,p_txn_revenue                  => i.txn_revenue *-1
                ,p_project_currency_code        => i.project_currency_code
                ,p_project_raw_cost             => i.project_raw_cost *-1
                ,p_project_burdened_cost        => i.project_burdened_cost *-1
                ,p_project_revenue              => i.project_revenue *-1
                ,p_projfunc_currency_code       => i.projfunc_currency_code
                ,p_projfunc_raw_cost            => i.raw_cost *-1
                ,p_projfunc_burdened_cost       => i.burdened_cost *-1
                ,p_projfunc_revenue             => i.revenue *-1
		,p_rep_line_mode               => 'REVERSAL'
                ,x_msg_data                     => x_msg_data
                ,x_return_status                => x_return_status
                );
      End If;

    END LOOP;  --}

    /* Now bulk update the budget lines */
    IF l_budget_line_id_tab.COUNT > 0 THEN
        --print_msg('Number of budget Lines updated['||l_budget_line_id_tab.COUNT||']');
        FORALL i IN l_budget_line_id_tab.FIRST .. l_budget_line_id_tab.LAST
            /* now update the budget lines with new quantity */
            UPDATE PA_BUDGET_LINES bl
            SET bl.quantity = NVL(bl.quantity,0) + NVL(l_quantity_tab(i),0)
                ,bl.txn_raw_cost =  decode(p_budget_version_type,'REVENUE',bl.txn_raw_cost,l_txn_raw_cost_tab(i))
                ,bl.txn_burdened_cost = decode(p_budget_version_type,'REVENUE',bl.txn_burdened_cost,l_txn_burden_cost_tab(i))
                ,bl.txn_revenue = decode(p_budget_version_type,'COST',bl.txn_revenue,l_txn_revenue_tab(i))
            WHERE bl.budget_line_id = l_budget_line_id_tab(i)
            AND   bl.budget_version_id = p_budget_version_id ;

        FORALL i IN l_budget_line_id_tab.FIRST .. l_budget_line_id_tab.LAST
            UPDATE PA_BUDGET_LINES bl
                SET bl.project_raw_cost = decode(p_budget_version_type,'REVENUE',bl.project_raw_cost
                    ,decode(bl.project_currency_code,bl.txn_currency_code,bl.txn_raw_cost
                    ,pa_currency.round_trans_currency_amt1((bl.txn_raw_cost * bl.project_cost_exchange_rate ),bl.project_currency_code)))
                ,bl.project_burdened_cost = decode(p_budget_version_type,'REVENUE',bl.project_burdened_cost
                    ,decode(bl.project_currency_code,bl.txn_currency_code,bl.txn_burdened_cost
                    ,pa_currency.round_trans_currency_amt1((bl.txn_burdened_cost * bl.project_cost_exchange_rate ),bl.project_currency_code)))
                ,bl.project_revenue = decode(p_budget_version_type,'COST',bl.project_revenue
                    ,decode(bl.project_currency_code,bl.txn_currency_code,bl.project_revenue
                    ,pa_currency.round_trans_currency_amt1((bl.project_revenue*bl.project_rev_exchange_rate ),bl.project_currency_code)))
                ,bl.raw_cost = decode(p_budget_version_type,'REVENUE',bl.raw_cost
                    ,decode(bl.projfunc_currency_code,bl.txn_currency_code,bl.txn_raw_cost
                                        ,pa_currency.round_trans_currency_amt1((bl.txn_raw_cost * bl.projfunc_cost_exchange_rate ),bl.projfunc_currency_code)))
                    ,bl.burdened_cost = decode(p_budget_version_type,'REVENUE',bl.burdened_cost
                    ,decode(bl.projfunc_currency_code,bl.txn_currency_code,bl.txn_burdened_cost
                                        ,pa_currency.round_trans_currency_amt1((bl.txn_burdened_cost * bl.projfunc_cost_exchange_rate ),bl.projfunc_currency_code)))
                    ,bl.revenue = decode(p_budget_version_type,'COST',bl.revenue
                    ,decode(bl.projfunc_currency_code,bl.txn_currency_code,bl.project_revenue
                                        ,pa_currency.round_trans_currency_amt1((bl.project_revenue*bl.projfunc_rev_exchange_rate ),bl.projfunc_currency_code)))
                WHERE bl.budget_line_id = l_budget_line_id_tab(i)
                AND   bl.budget_version_id = p_budget_version_id ;

    END IF;

    /* after updating the budget lines pass +ve values to pji reporting apis */
    IF p_rollup_required_flag = 'Y' OR NVL(l_populate_mrc_tab_flag,'N') = 'Y'  Then
       FOR i IN cur_Oldbl_Lines LOOP
              IF (p_rollup_required_flag = 'Y'
		/* bug fix:5031388
        	AND i.cost_rejection_code is NULL
                AND i.burden_rejection_code is NULL
                AND i.revenue_rejection_code is NULL
                AND i.pc_cur_conv_rejection_code is NULL
                AND i.pfc_cur_conv_rejection_code is NULL */
		)  Then

                /* before updating the existing budget line call the reporting API to pass -ve amts */
                PA_FP_CALC_PLAN_PKG.Add_Toreporting_Tabls
                (p_calling_module               => 'CALCULATE_API'
                ,p_activity_code                => 'UPDATE'
                ,p_budget_version_id            => p_budget_version_id
                ,p_budget_line_id               => i.budget_line_id
                ,p_resource_assignment_id       => i.resource_assignment_id
                ,p_start_date                   => i.start_date
                ,p_end_date                     => i.end_date
                ,p_period_name                  => i.period_name
                ,p_txn_currency_code            => i.txn_currency_code
                ,p_quantity                     => i.bl_quantity
                ,p_txn_raw_cost                 => i.txn_raw_cost
                ,p_txn_burdened_cost            => i.txn_burdened_cost
                ,p_txn_revenue                  => i.txn_revenue
                ,p_project_currency_code        => i.project_currency_code
                ,p_project_raw_cost             => i.project_raw_cost
                ,p_project_burdened_cost        => i.project_burdened_cost
                ,p_project_revenue              => i.project_revenue
                ,p_projfunc_currency_code       => i.projfunc_currency_code
                ,p_projfunc_raw_cost            => i.raw_cost
                ,p_projfunc_burdened_cost       => i.burdened_cost
                ,p_projfunc_revenue             => i.revenue
		,p_rep_line_mode               => 'POSITIVE_ENTRY'
                ,x_msg_data                     => x_msg_data
                ,x_return_status                => x_return_status
                );
          END IF;

      /* Added for MRC enhancements */
          IF NVL(l_populate_mrc_tab_flag,'N') = 'Y' Then --{
                PA_FP_CALC_PLAN_PKG.populate_MRC_plsqltabs
        	(p_calling_module               => 'CALCULATE_API'
                ,p_budget_version_id            => p_budget_version_id
                ,p_budget_line_id               => i.budget_line_id
                ,p_resource_assignment_id       => i.resource_assignment_id
                ,p_start_date                   => i.start_date
                ,p_end_date                     => i.end_date
                ,p_period_name                  => i.period_name
                ,p_txn_currency_code            => i.txn_currency_code
                ,p_quantity                     => i.bl_quantity
                ,p_txn_raw_cost                 => i.txn_raw_cost
                ,p_txn_burdened_cost            => i.txn_burdened_cost
                ,p_txn_revenue                  => i.txn_revenue
                ,p_project_currency_code        => i.project_currency_code
                ,p_project_raw_cost             => i.project_raw_cost
                ,p_project_burdened_cost        => i.project_burdened_cost
                ,p_project_revenue              => i.project_revenue
                ,p_projfunc_currency_code       => i.projfunc_currency_code
                ,p_projfunc_raw_cost            => i.raw_cost
                ,p_projfunc_burdened_cost       => i.burdened_cost
                ,p_projfunc_revenue             => i.revenue
        	,p_delete_flag                  => 'N'
                ,x_msg_data                     => x_msg_data
                ,x_return_status                => x_return_status
                );
      End If;
       END LOOP;
    END IF;

    IF    1 = 1 then --{ no budget line exists so insert a new line
        /* Initialize the plsql tabs */
        l_budget_line_id_tab.delete;
                l_resAsgn_id_tab.delete;
                l_txn_curr_code_tab.delete;
                l_start_date_tab.delete;
                l_end_date_tab.delete;
                l_period_name_tab.delete;
                l_quantity_tab.delete;
                l_proj_curr_code_tab.delete;
                l_projfunc_curr_code_tab.delete;

        OPEN cur_newtmp_lines;
        FETCH cur_newtmp_lines BULK COLLECT INTO
            l_budget_line_id_tab
                ,l_resAsgn_id_tab
                ,l_txn_curr_code_tab
                ,l_start_date_tab
                ,l_end_date_tab
                ,l_period_name_tab
                ,l_quantity_tab
                ,l_proj_curr_code_tab
                ,l_projfunc_curr_code_tab;
        CLOSE cur_newtmp_lines;

        IF l_budget_line_id_tab.COUNT > 0 THEN  --{
            --print_msg('Number of New budget lines inserted ['||l_budget_line_id_tab.COUNT||']');
            FORALL i in l_budget_line_id_tab.FIRST .. l_budget_line_id_tab.LAST
                INSERT INTO PA_BUDGET_LINES(
                BUDGET_VERSION_ID
                        ,BUDGET_LINE_ID
                        ,RESOURCE_ASSIGNMENT_ID
                ,TXN_CURRENCY_CODE
                ,PROJECT_CURRENCY_CODE
                    ,PROJFUNC_CURRENCY_CODE
                ,PERIOD_NAME
                    ,START_DATE
                ,END_DATE
                ,QUANTITY
                    ,LAST_UPDATE_DATE
                    ,LAST_UPDATED_BY
                    ,CREATION_DATE
                    ,CREATED_BY
                    ,LAST_UPDATE_LOGIN
                ,QUANTITY_SOURCE
                ,RAW_COST_SOURCE
                ,BURDENED_COST_SOURCE
                ,REVENUE_SOURCE
                    )
                SELECT
                    p_BUDGET_VERSION_ID
                    ,l_budget_line_id_tab(i)
                    ,l_resAsgn_id_tab(i)
                    ,l_txn_curr_code_tab(i)
                    ,l_proj_curr_code_tab(i)
                    ,l_projfunc_curr_code_tab(i)
                    ,l_period_name_tab(i)
                    ,l_start_date_tab(i)
                    ,l_end_date_tab(i)
                ,l_quantity_tab(i)
                    ,g_LAST_UPDATE_DATE
                    ,g_LAST_UPDATED_BY
                    ,g_CREATION_DATE
                    ,g_CREATED_BY
                    ,g_LAST_UPDATE_LOGIN
                ,'SP'
                ,'SP'
                ,'SP'
                ,'SP'
            FROM dual
            WHERE NVL(l_quantity_tab(i),0) <> 0;

            If p_rollup_required_flag = 'Y' Then
            FOR i IN l_budget_line_id_tab.FIRST .. l_budget_line_id_tab.LAST LOOP
                 IF NVL(l_quantity_tab(i),0) <> 0 Then
                        /* before updating the existing budget line call the reporting API to pass -ve amts */
                        PA_FP_CALC_PLAN_PKG.Add_Toreporting_Tabls
                        (p_calling_module               => 'CALCULATE_API'
                        ,p_activity_code                => 'UPDATE'
                        ,p_budget_version_id            => p_budget_version_id
                        ,p_budget_line_id               => l_budget_line_id_tab(i)
                        ,p_resource_assignment_id       => l_resAsgn_id_tab(i)
                        ,p_start_date                   => l_start_date_tab(i)
                        ,p_end_date                     => l_end_date_tab(i)
                        ,p_period_name                  => l_period_name_tab(i)
                        ,p_txn_currency_code            => l_txn_curr_code_tab(i)
                        ,p_quantity                     => l_quantity_tab(i)
                        ,p_txn_raw_cost                 => null
                        ,p_txn_burdened_cost            => null
                        ,p_txn_revenue                  => null
                        ,p_project_currency_code        => l_proj_curr_code_tab(i)
                        ,p_project_raw_cost             => null
                        ,p_project_burdened_cost        => null
                        ,p_project_revenue              => null
                        ,p_projfunc_currency_code       => l_projfunc_curr_code_tab(i)
                        ,p_projfunc_raw_cost            => null
                        ,p_projfunc_burdened_cost       => null
                        ,p_projfunc_revenue             => null
			,p_rep_line_mode               => 'POSITIVE_ENTRY'
                        ,x_msg_data                     => x_msg_data
                        ,x_return_status                => x_return_status
                        );
                END IF;
            END LOOP;
                End If;
        End If; --}
    End If; --}

        /* reset the error stack */
    If p_pa_debug_mode = 'Y' Then
    	print_msg('RetSts of Insert_budget_lines api['||x_return_status||']');
            pa_debug.reset_err_stack;
    End If;

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                x_msg_data := sqlcode||sqlerrm;
                print_msg('Failed in insert_budget_lines API'||x_msg_data);
        If p_pa_debug_mode = 'Y' Then
                    pa_debug.reset_err_stack;
        End If;
                 fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'insert_budget_lines');
                RAISE;
END insert_budget_lines;

/* This API populates the plsql tables required for bulk update of process_ResAttribs */
PROCEDURE Populate_ResAttribTabs
        (p_resource_assignment_id  IN  Number
        ,p_txn_currency_code       IN  Varchar2) IS

BEGIN
    g_RsAtrb_RaId_tab(NVL(g_RsAtrb_RaId_tab.LAST,0)+1) := p_resource_assignment_id;
    g_RsAtrb_TxnCur_tab(NVL(g_RsAtrb_TxnCur_tab.LAST,0)+1) := p_txn_currency_code;

END Populate_ResAttribTabs;

/* LOGIC: When resource is planned in multiple currencies, changing the resource attributes such as
 * spread curve,sp fixed date, mfc cost type, re spread from periodic page spreads the quantity from
 * MIN budget line start date to MAX budget line end date
 * To ensure this, a reference dates SYSTEM_REFERENCE_DAT1 is populated with MIN blstart date
 * and SYSTEM_REFERENCE_DAT2 is populated with MAX blend date
 * These dates will be passed to spread api.
 */
PROCEDURE process_ResAttribs(
                p_budget_version_id              IN  Number
                ,p_resource_assignment_id_tab    IN  pa_plsql_datatypes.NumTabTyp
                ,p_txn_currency_code_tab         IN  pa_plsql_datatypes.Char50TabTyp
                ,x_return_status                 OUT NOCOPY Varchar2
                ,x_msg_data                      OUT NOCOPY Varchar2 ) IS

BEGIN
    x_return_status := 'S';
    x_msg_data      := NULL;
    IF p_resource_assignment_id_tab.COUNT > 0 THEN
        FORALL i IN p_resource_assignment_id_tab.FIRST .. p_resource_assignment_id_tab.LAST
        UPDATE /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP_N1) */ pa_fp_spread_calc_tmp tmp
        SET (tmp.SYSTEM_REFERENCE_DAT1
            ,tmp.SYSTEM_REFERENCE_DAT2) = (select MIN(bl.start_date),MAX(bl.end_date)
                               from pa_budget_lines bl
                           where bl.resource_assignment_id = tmp.resource_assignment_id
                           and   bl.txn_currency_code = tmp.txn_currency_code)
        WHERE tmp.resource_assignment_id = p_resource_assignment_id_tab(i)
        AND  tmp.txn_currency_code = p_txn_currency_code_tab(i)
        AND  NVL(tmp.system_reference_var1,'N') = 'Y'
        AND  tmp.budget_version_id = p_budget_version_id ;
            --print_msg('Number of tmp lines updated with MIN and MAX bldates for ResourcePlanned In Multicurr['||sql%rowcount||']');

        /* If planning start date is prior to MIN start date, then qty should be spread from planning start date similarly
        * if planning end date is prior to MAX date then qty should be spread to planned end date
                * based on this logic Now update the DAT1 and DAT2 from planning dates
        */
        FORALL i IN p_resource_assignment_id_tab.FIRST .. p_resource_assignment_id_tab.LAST
        UPDATE /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP_N1) */ pa_fp_spread_calc_tmp tmp
                SET (tmp.SYSTEM_REFERENCE_DAT1
                    ,tmp.SYSTEM_REFERENCE_DAT2) = (select decode(tmp.SYSTEM_REFERENCE_DAT1,NULL,NULL
                               ,decode(sign(trunc(tmp.SYSTEM_REFERENCE_DAT1)-trunc(ra.planning_start_date)),-1
                                      ,ra.planning_start_date,tmp.SYSTEM_REFERENCE_DAT1))
                            ,decode(tmp.SYSTEM_REFERENCE_DAT2,NULL,NULL
                                                           ,decode(sign(trunc(tmp.SYSTEM_REFERENCE_DAT2)-trunc(ra.planning_end_date)),1
                                                                      ,ra.planning_end_date,tmp.SYSTEM_REFERENCE_DAT2))
                                                   from pa_resource_assignments ra
                                                   where ra.resource_assignment_id = tmp.resource_assignment_id
                           and ra.budget_version_id = tmp.budget_version_id)
                WHERE tmp.resource_assignment_id = p_resource_assignment_id_tab(i)
                AND  NVL(tmp.system_reference_var1,'N') = 'Y'
        AND  tmp.budget_version_id = p_budget_version_id ;
            --print_msg('Number of tmp lines updated with DAT1 and DAT2  for ResourcePlanned In Multicurr['||sql%rowcount||']');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := 'U';
                x_msg_data := sqlcode||sqlerrm;
                print_msg('Failed in insert_budget_lines API'||x_msg_data);
        If p_pa_debug_mode = 'Y' Then
                    pa_debug.reset_err_stack;
        End If;
                 fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'process_ResAttribs');
                RAISE;

END process_ResAttribs;

PROCEDURE populate_planDates_Tabs
        (p_resource_assignment_id        IN  Number
                ,p_txn_currency_code             IN  Varchar2
                ,p_project_currency_code         IN  Varchar2
                ,p_projfunc_currency_code        IN  Varchar2
                ,p_start_dates_shrunk_flag       IN  Varchar2
                ,p_end_dates_shrunk_flag         IN  Varchar2
                ,p_plan_start_date_old           IN  Date
                ,p_plan_start_date_new           IN  Date
                ,p_plan_end_date_old             IN  Date
                ,p_plan_end_date_new             IN  Date ) IS

BEGIN
    g_Rspd_RaId_tab(NVL(g_Rspd_RaId_tab.LAST,0)+1) := p_resource_assignment_id;
        g_Rspd_TxnCur_tab(NVL(g_Rspd_TxnCur_tab.LAST,0)+1) := p_txn_currency_code;
    g_Rspd_Pjcur_tab(NVL(g_Rspd_Pjcur_tab.LAST,0)+1) := p_project_currency_code;
    g_Rspd_pjf_cur_tab(NVL(g_Rspd_pjf_cur_tab.LAST,0)+1) := p_projfunc_currency_code;
    g_Rspd_SdShrk_Flg_tab(NVL(g_Rspd_SdShrk_Flg_tab.LAST,0)+1) := p_start_dates_shrunk_flag;
    g_Rspd_EdShrk_Flg_tab(NVL(g_Rspd_EdShrk_Flg_tab.LAST,0)+1) := p_end_dates_shrunk_flag;
    g_Rspd_SD_old_tab(NVL(g_Rspd_SD_old_tab.LAST,0)+1) := p_plan_start_date_old;
    g_Rspd_SD_new_tab(NVL(g_Rspd_SD_new_tab.LAST,0)+1) := p_plan_start_date_new;
    g_Rspd_ED_old_tab(NVL(g_Rspd_ED_old_tab.LAST,0)+1) := p_plan_end_date_old;
    g_Rspd_ED_new_tab(NVL(g_Rspd_ED_new_tab.LAST,0)+1) := p_plan_end_date_new;

END populate_planDates_Tabs;

/* LOGIC: When both planning start date and end dates are extended then do nothing
 * If Planning Start date is shrunk then sum (quantity) of all bdgt lines prior to plan start date
 * and then delete all the budgetlines prior to new start date and update a budget line existsing on the new plan start
 * date. If no budget line exists then insert a new budget line with the sum (quantity)
 *
 * IF Planning end date is shrunk, then sum (quantity) all budget line later than new end date
 * and then delete all the budget lines later than new plan end date.
 * update existing budget line on new plan end with the above sum(quantity), If no budget line exists then
 * insert a new budget line
 */
PROCEDURE process_planDates_change(
        p_budget_version_id              IN  Number
        ,x_return_status                 OUT NOCOPY Varchar2
        ,x_msg_data                      OUT NOCOPY Varchar2 ) IS

    l_period_type   Varchar2(100);

BEGIN
    x_return_status := 'S';
    If p_pa_debug_mode = 'Y' Then
        pa_debug.init_err_stack('PA_FP_CALC_UTILS.process_planDates_change');
        --print_msg('Entered process_planDates_change api NumLinetoProcess['||g_Rspd_RaId_tab.COUNT||']');
    End If;
    IF perdRec.time_phased_code = 'P' Then
        l_period_type := perdRec.pa_period_type;
    Else
        l_period_type := perdRec.accounted_period_type;
    End If;

    /* reset the rollup tmp table */
    -- bug fix:5203868
    DELETE FROM pa_fp_rollup_tmp
    WHERE budget_version_id = p_budget_version_id;

    IF g_Rspd_RaId_tab.COUNT > 0 Then
        /* populate records for start date change */
        FORALL i IN g_Rspd_RaId_tab.FIRST .. g_Rspd_RaId_tab.LAST
           INSERT INTO pa_fp_rollup_tmp tmp
            (resource_assignment_id
            ,txn_currency_code
            ,start_date
            ,end_date
            ,period_name
            ,project_currency_code
            ,projfunc_currency_code
            ,quantity
            ,plan_Start_Date_shrunk_flag
            )
           SELECT g_Rspd_RaId_tab(i)
            , g_Rspd_TxnCur_tab(i)
            , glp1.start_date
            , glp1.end_date
            , glp1.period_name
            , g_Rspd_Pjcur_tab(i)
            , g_Rspd_Pjf_cur_tab(i)
            , null
            ,NVL(g_Rspd_SdShrk_Flg_tab(i),'N')
           FROM  gl_periods glp1
               WHERE glp1.adjustment_period_flag = 'N'
               AND   glp1.period_set_name = perdRec.period_set_name
               AND   glp1.period_type = l_period_type
               AND   trunc(g_Rspd_SD_new_tab(i)) BETWEEN glp1.start_date and glp1.end_date
           AND   NVL(g_Rspd_SdShrk_Flg_tab(i),'N') = 'Y';
        --print_msg('Number lines inserted into fp_rollupTmp for StartDateShrunk['||sql%rowcount||']');

        /* Now update the rollup tmp table with the sum of bl line quantities prior to new plan start date*/
        UPDATE pa_fp_rollup_tmp tmp
        SET tmp.processed_flag = 'Y'
           ,tmp.quantity = (SELECT SUM(nvl(bl.quantity,0)-nvl(bl.init_quantity,0))
                        FROM  pa_budget_lines bl
                        WHERE bl.budget_version_id = p_budget_version_id
                        AND   bl.resource_assignment_id = tmp.resource_assignment_id
                        AND   bl.txn_currency_code = tmp.txn_currency_code
                            AND   bl.end_date < ( tmp.start_date) )
        WHERE NVL(tmp.processed_flag,'N') = 'N'
        AND  NVL(plan_Start_Date_shrunk_flag,'N') = 'Y';

        /* Delete all the budget lines which falls beyond the plan start date */
        delete_budget_lines(
                p_budget_version_id             => p_budget_version_id
                ,p_budget_version_type          => g_budget_version_type
                ,p_rollup_required_flag         => g_rollup_required_flag
                ,p_process_mode                 => 'PLAN_START_DATE'
                ,x_return_status                => x_return_status
                ,x_msg_data                     => x_msg_data
                );

        /* populate records for end date change */
                FORALL i IN g_Rspd_RaId_tab.FIRST .. g_Rspd_RaId_tab.LAST
                   INSERT INTO pa_fp_rollup_tmp tmp
                        (resource_assignment_id
                        ,txn_currency_code
                        ,start_date
                        ,end_date
                        ,period_name
                        ,project_currency_code
                        ,projfunc_currency_code
                        ,quantity
            ,plan_End_Date_shrunk_flag
                        )
                   SELECT g_Rspd_RaId_tab(i)
                        , g_Rspd_TxnCur_tab(i)
                        , glp1.start_date
                        , glp1.end_date
                        , glp1.period_name
                        , g_Rspd_Pjcur_tab(i)
                        , g_Rspd_Pjf_cur_tab(i)
                        , null
            , NVL(g_Rspd_EdShrk_Flg_tab(i),'N')
                   FROM  gl_periods glp1
                   WHERE glp1.adjustment_period_flag = 'N'
                   AND   glp1.period_set_name = perdRec.period_set_name
                   AND   glp1.period_type = l_period_type
                   AND   trunc(g_Rspd_ED_new_tab(i)) BETWEEN glp1.start_date and glp1.end_date
                   AND   NVL(g_Rspd_EdShrk_Flg_tab(i),'N') = 'Y';

        --print_msg('Number lines inserted into fp_rollupTmp for EndDateShrunk['||sql%rowcount||']');
                /* Now update the rollup tmp table with the sum of bl line quantities later than new plan end date */
                UPDATE pa_fp_rollup_tmp tmp
                SET tmp.processed_flag = 'Y'
                   ,tmp.quantity = (SELECT SUM(nvl(bl.quantity,0)-nvl(bl.init_quantity,0))
                                    FROM  pa_budget_lines bl
                                    WHERE bl.budget_version_id = p_budget_version_id
                                    AND   bl.resource_assignment_id = tmp.resource_assignment_id
                                    AND   bl.txn_currency_code = tmp.txn_currency_code
                                    AND   bl.start_date > ( tmp.end_date) )
        WHERE NVL(tmp.processed_flag,'N') = 'N'
        AND NVL(plan_End_Date_shrunk_flag,'N') = 'Y' ;

        /* Delete all the budget lines which falls beyond the plan end date */
                delete_budget_lines(
                p_budget_version_id             => p_budget_version_id
                ,p_budget_version_type          => g_budget_version_type
                ,p_rollup_required_flag         => g_rollup_required_flag
                ,p_process_mode                 => 'PLAN_END_DATE'
                ,x_return_status                => x_return_status
                ,x_msg_data                     => x_msg_data
                );

        --print_msg('Calling insert_budget_lines api');
        /* Finally update the existing budget line or insert the new budget lines */
        insert_budget_lines(
                p_budget_version_id             => p_budget_version_id
                ,p_budget_version_type          => g_budget_version_type
                ,p_rollup_required_flag         => g_rollup_required_flag
                ,x_return_status                => x_return_status
                ,x_msg_data                     => x_msg_data
                );

    END IF;

    --print_msg('ReturnStatus of process_planDates_change ['||x_return_status||']');
        /* reset the error stack */
    If p_pa_debug_mode = 'Y' Then
            pa_debug.reset_err_stack;
    End If;

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                x_msg_data := sqlcode||sqlerrm;
                print_msg('Failed in process_planDates_change API'||x_msg_data);
        If p_pa_debug_mode = 'Y' Then
                    pa_debug.reset_err_stack;
        End If;
                 fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'process_planDates_change');
                RAISE;
END process_planDates_change;

PROCEDURE populate_blTxnCurCombo
        (p_budget_version_id  IN NUMBER
        ,x_return_status    OUT NOCOPY VARCHAR2
        ) IS

    l_msg_data      Varchar2(1000);
    l_raId_Tab  pa_plsql_datatypes.NumTabTyp;
    l_TxnCur_Tab    pa_plsql_datatypes.Char50TabTyp;
    l_TmpTxnCur_Tab pa_plsql_datatypes.Char50TabTyp;
    l_Qty_Tab   pa_plsql_datatypes.NumTabTyp;
BEGIN
    x_return_status := 'S';
    /* bulk select all the RA+Txn currency combo from budget lines and later insert these records into tmp table
     * for processing
     */
    If p_pa_debug_mode = 'Y' Then
        pa_debug.init_err_stack('PA_FP_CALC_UTILS.populate_blTxnCurCombo');
    	print_msg('Entered populate_blTxnCurCombo api');
    End If;
        SELECT /*+ INDEX(BL PA_BUDGET_LINES_U1) */
	  bl.resource_assignment_id
            ,bl.txn_currency_code
        BULK COLLECT INTO
            l_raId_Tab
            ,l_TxnCur_Tab
        FROM pa_budget_lines bl
             ,pa_fp_spread_calc_tmp tmp
        WHERE bl.budget_version_id = p_budget_version_id
        AND  bl.resource_assignment_id = tmp.resource_assignment_id
        AND  bl.txn_currency_code <> tmp.txn_currency_code
        AND  NVL(tmp.system_reference_var1,'N') = 'Y'
            AND  ( NVL(tmp.sp_curve_change_flag,'N') = 'Y'
                    OR NVL(tmp.plan_dates_change_flag,'N') = 'Y'
                    OR NVL(tmp.mfc_cost_change_flag,'N') = 'Y'
                    OR NVL(tmp.sp_fix_date_change_flag,'N') = 'Y'
            OR NVL(tmp.rlm_id_change_flag,'N') = 'Y'
                    )
        AND  NOT EXISTS (select null
                                from pa_fp_spread_calc_tmp tmp1
                                where tmp1.budget_version_id = p_budget_version_id
                                and tmp1.resource_assignment_id = tmp.resource_assignment_id
                                and tmp1.txn_currency_code = bl.txn_currency_code
                )
        GROUP BY bl.resource_assignment_id
                        ,bl.txn_currency_code ;

        --print_msg('Number of ra+txn combo selected from bl['||sql%rowcount||']');

        IF l_raId_Tab.COUNT > 0 THEN
            FORALL i IN l_raId_Tab.FIRST .. l_raId_Tab.LAST
            INSERT INTO pa_fp_spread_calc_tmp
                            (BUDGET_VERSION_ID
                ,BUDGET_VERSION_TYPE
                ,RESOURCE_ASSIGNMENT_ID --resource_assignment_id
                            ,TXN_CURRENCY_CODE     --txn_currency_code
                ,SYSTEM_REFERENCE_VAR2
                )
            VALUES (p_budget_version_id
                ,g_budget_version_type
                ,l_raId_Tab(i)
                ,l_TxnCur_Tab(i)
                ,'Y'
                );
	    IF P_PA_DEBUG_MODE = 'Y' Then
              print_msg('Number of rows inserted ra+txncur into tmp['||sql%rowcount||']');
	    End If;

            /* Now updates the other attributes for the newly inserted rows */
            FORALL i IN l_raId_Tab.FIRST .. l_raId_Tab.LAST
            UPDATE /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP_N1) */ pa_fp_spread_calc_tmp tmp
            SET tmp.quantity = (select sum(bl.quantity)
                       from pa_budget_lines bl
                       where bl.budget_version_id = tmp.budget_version_id
                           and   bl.resource_assignment_id = tmp.resource_assignment_id
                       and   bl.txn_currency_code = tmp.txn_currency_code)
                ,tmp.system_reference_var2 = NULL
                ,(tmp.OLD_SPREAD_CURVE_ID   --x_spread_curve_id_old_tab
                            ,NEW_SPREAD_CURVE_ID   --x_spread_curve_id_new_tab
                            ,OLD_SP_FIX_DATE       --x_sp_fixed_date_old_tab
                            ,NEW_SP_FIX_DATE       --x_sp_fixed_date_new_tab
                            ,OLD_PLAN_START_DATE   --x_plan_start_date_old_tab
                            ,NEW_PLAN_START_DATE   --x_plan_start_date_new_tab
                            ,OLD_PLAN_END_DATE     --x_plan_end_date_old_tab
                            ,NEW_PLAN_END_DATE     --x_plan_end_date_new_tab
                            ,RE_SPREAD_AMTS_FLAG   --x_re_spread_flag_tab
                            ,SP_CURVE_CHANGE_FLAG  --x_sp_curve_change_flag_tab
                            ,PLAN_DATES_CHANGE_FLAG --x_plan_dates_change_flag_tab
                            ,SP_FIX_DATE_CHANGE_FLAG --x_spfix_date_flag_tab
                            ,MFC_COST_CHANGE_FLAG   --x_mfc_cost_change_flag_tab
                            ,OLD_MFC_COST_TYPE_ID   --x_mfc_cost_type_id_old_tab
                            ,NEW_MFC_COST_TYPE_ID   --x_mfc_cost_type_id_new_tab
                            ,ETC_START_DATE
                            ,PROJECT_CURRENCY_CODE
                            ,PROJFUNC_CURRENCY_CODE
                ,SYSTEM_REFERENCE_VAR1
                ,PLAN_START_DATE_SHRUNK_FLAG
                ,PLAN_END_DATE_SHRUNK_FLAG
                ,RLM_ID_CHANGE_FLAG
                ) = (SELECT /*+ INDEX(TMP1 PA_FP_SPREAD_CALC_TMP_N1) */
                            tmp1.OLD_SPREAD_CURVE_ID
                            ,tmp1.NEW_SPREAD_CURVE_ID
                            ,tmp1.OLD_SP_FIX_DATE
                            ,tmp1.NEW_SP_FIX_DATE
                            ,tmp1.OLD_PLAN_START_DATE
                            ,tmp1.NEW_PLAN_START_DATE
                            ,tmp1.OLD_PLAN_END_DATE
                            ,tmp1.NEW_PLAN_END_DATE
                            ,tmp1.RE_SPREAD_AMTS_FLAG
                            ,tmp1.SP_CURVE_CHANGE_FLAG
                            ,tmp1.PLAN_DATES_CHANGE_FLAG
                            ,tmp1.SP_FIX_DATE_CHANGE_FLAG
                            ,tmp1.MFC_COST_CHANGE_FLAG
                            ,tmp1.OLD_MFC_COST_TYPE_ID
                            ,tmp1.NEW_MFC_COST_TYPE_ID
                            ,tmp1.ETC_START_DATE
                            ,tmp1.PROJECT_CURRENCY_CODE
                            ,tmp1.PROJFUNC_CURRENCY_CODE
                ,tmp1.SYSTEM_REFERENCE_VAR1
                ,tmp1.PLAN_START_DATE_SHRUNK_FLAG
                ,tmp1.PLAN_END_DATE_SHRUNK_FLAG
                ,tmp1.RLM_ID_CHANGE_FLAG
                FROM pa_fp_spread_calc_tmp tmp1
                WHERE tmp1.budget_version_id = p_budget_version_id
                AND   tmp1.resource_assignment_id = tmp.resource_assignment_id
                AND  tmp1.txn_currency_code <> tmp.txn_currency_code
                AND  NVL(tmp1.SYSTEM_REFERENCE_VAR2,'N') = 'N'
                AND rownum =1 )
            WHERE tmp.budget_version_id = p_budget_version_id
            AND  tmp.resource_assignment_id = l_raId_Tab(i)
            AND  tmp.txn_currency_code = l_TxnCur_Tab(i)
            AND  tmp.SYSTEM_REFERENCE_VAR2 = 'Y';
            print_msg('Num of rows updated in tmp ['||sql%rowcount||']');

        END IF;

        /* Note: when planning resource is changed, then ignore all other attribute changes on the RA
         * change in the planning resource should be treated as a new RA
         */
        UPDATE pa_fp_spread_calc_tmp tmp
        SET tmp.SP_CURVE_CHANGE_FLAG  = decode(nvl(tmp.rlm_id_change_flag,'N'),'Y','N',tmp.SP_CURVE_CHANGE_FLAG)
            ,tmp.PLAN_DATES_CHANGE_FLAG = decode(nvl(tmp.rlm_id_change_flag,'N'),'Y','N',tmp.PLAN_DATES_CHANGE_FLAG)
            ,tmp.SP_FIX_DATE_CHANGE_FLAG = decode(nvl(tmp.rlm_id_change_flag,'N'),'Y','N',tmp.SP_FIX_DATE_CHANGE_FLAG)
            ,tmp.MFC_COST_CHANGE_FLAG = decode(nvl(tmp.rlm_id_change_flag,'N'),'Y','N',tmp.MFC_COST_CHANGE_FLAG)
        WHERE tmp.budget_version_id = p_budget_version_id;
        If p_pa_debug_mode = 'Y' Then
            pa_debug.reset_err_stack;
        End If;
EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                l_msg_data := sqlcode||sqlerrm;
                print_msg('Failed in populate_blTxnCurCombo API'||l_msg_data);
        If p_pa_debug_mode = 'Y' Then
                    pa_debug.reset_err_stack;
        End if;
                 fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'populate_blTxnCurCombo');
                RAISE;

END populate_blTxnCurCombo;

PROCEDURE synch_resAttribs(p_budget_version_id Number
             ,p_calling_module  IN Varchar2 ) IS

    l_return_status   Varchar2(1);
    l_msg_data        Varchar2(1000);
BEGIN
    IF P_PA_DEBUG_MODE = 'Y' Then
    print_msg('Enetered synch_resAttribs api');
	End If;
    IF (p_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION')
       and NVL(g_apply_progress_flag,'N') <> 'Y'
        and g_source_context = 'RESOURCE_ASSIGNMENT' ) Then  --{
                /* If multiple RA + Txn cur combo is passed, then updates the res attributes whereever it is null */
            UPDATE pa_fp_spread_calc_tmp tmp
                SET tmp.RLM_ID_CHANGE_FLAG = decode(tmp.RLM_ID_CHANGE_FLAG,NULL,(select tmp1.RLM_ID_CHANGE_FLAG
                                                from pa_fp_spread_calc_tmp tmp1
                                                where tmp1.resource_assignment_id = tmp.resource_assignment_id
                                                and tmp1.txn_currency_code <> tmp.txn_currency_code
                                                and tmp1.RLM_ID_CHANGE_FLAG is not null
                                                and rownum = 1
                                              ),tmp.RLM_ID_CHANGE_FLAG)
                   ,tmp.OLD_SPREAD_CURVE_ID = decode(tmp.OLD_SPREAD_CURVE_ID,NULL,(select tmp1.OLD_SPREAD_CURVE_ID
                                                from pa_fp_spread_calc_tmp tmp1
                                                where tmp1.resource_assignment_id = tmp.resource_assignment_id
                                                and tmp1.txn_currency_code <> tmp.txn_currency_code
                                                and tmp1.OLD_SPREAD_CURVE_ID is not null
                                                and rownum = 1
                                              ),tmp.OLD_SPREAD_CURVE_ID)
                   ,tmp.NEW_SPREAD_CURVE_ID = decode(tmp.NEW_SPREAD_CURVE_ID,NULL,(select tmp1.NEW_SPREAD_CURVE_ID
                                                from pa_fp_spread_calc_tmp tmp1
                                                where tmp1.resource_assignment_id = tmp.resource_assignment_id
                                                and tmp1.txn_currency_code <> tmp.txn_currency_code
                                                and tmp1.NEW_SPREAD_CURVE_ID is not null
                                                and rownum = 1
                                              ),tmp.NEW_SPREAD_CURVE_ID)
                   ,tmp.OLD_SP_FIX_DATE = decode(tmp.OLD_SP_FIX_DATE,NULL,(select tmp1.OLD_SP_FIX_DATE
                                                from pa_fp_spread_calc_tmp tmp1
                                                where tmp1.resource_assignment_id = tmp.resource_assignment_id
                                                and tmp1.txn_currency_code <> tmp.txn_currency_code
                                                and tmp1.OLD_SP_FIX_DATE is not null
                                                and rownum = 1
                                              ),tmp.OLD_SP_FIX_DATE)
                   ,tmp.NEW_SP_FIX_DATE = decode(tmp.NEW_SP_FIX_DATE,NULL,(select tmp1.NEW_SP_FIX_DATE
                                                from pa_fp_spread_calc_tmp tmp1
                                                where tmp1.resource_assignment_id = tmp.resource_assignment_id
                                                and tmp1.txn_currency_code <> tmp.txn_currency_code
                                                and tmp1.NEW_SP_FIX_DATE is not null
                                                and rownum = 1
                                              ),tmp.NEW_SP_FIX_DATE)
                   ,tmp.OLD_MFC_COST_TYPE_ID = decode(tmp.OLD_MFC_COST_TYPE_ID,NULL,(select tmp1.OLD_MFC_COST_TYPE_ID
                                                from pa_fp_spread_calc_tmp tmp1
                                                where tmp1.resource_assignment_id = tmp.resource_assignment_id
                                                and tmp1.txn_currency_code <> tmp.txn_currency_code
                                                and tmp1.OLD_MFC_COST_TYPE_ID is not null
                                                and rownum = 1
                                              ),tmp.OLD_MFC_COST_TYPE_ID)
                   ,tmp.NEW_MFC_COST_TYPE_ID = decode(tmp.NEW_MFC_COST_TYPE_ID,NULL,(select tmp1.NEW_MFC_COST_TYPE_ID
                                                from pa_fp_spread_calc_tmp tmp1
                                                where tmp1.resource_assignment_id = tmp.resource_assignment_id
                                                and tmp1.txn_currency_code <> tmp.txn_currency_code
                                                and tmp1.NEW_MFC_COST_TYPE_ID is not null
                                                and rownum = 1
                                              ),tmp.NEW_MFC_COST_TYPE_ID)
                   ,tmp.OLD_PLAN_START_DATE = decode(tmp.OLD_PLAN_START_DATE,NULL,(select tmp1.OLD_PLAN_START_DATE
                                                from pa_fp_spread_calc_tmp tmp1
                                                where tmp1.resource_assignment_id = tmp.resource_assignment_id
                                                and tmp1.txn_currency_code <> tmp.txn_currency_code
                                                and tmp1.OLD_PLAN_START_DATE is not null
                                                and rownum = 1
                                              ),tmp.OLD_PLAN_START_DATE)
                   ,tmp.OLD_PLAN_END_DATE = decode(tmp.OLD_PLAN_END_DATE,NULL,(select tmp1.OLD_PLAN_END_DATE
                                                from pa_fp_spread_calc_tmp tmp1
                                                where tmp1.resource_assignment_id = tmp.resource_assignment_id
                                                and tmp1.txn_currency_code <> tmp.txn_currency_code
                                                and tmp1.OLD_PLAN_END_DATE is not null
                                                and rownum = 1
                                              ),tmp.OLD_PLAN_END_DATE)
           ,tmp.NEW_PLAN_START_DATE = decode(tmp.NEW_PLAN_START_DATE,NULL,(select ra.planning_start_date
                                                from pa_resource_assignments ra
                                                where ra.resource_assignment_id = tmp.resource_assignment_id
                                              ),tmp.NEW_PLAN_START_DATE)
           ,tmp.NEW_PLAN_END_DATE = decode(tmp.NEW_PLAN_END_DATE,NULL,(select ra.planning_end_date
                                                from pa_resource_assignments ra
                                                where ra.resource_assignment_id = tmp.resource_assignment_id
                                              ),tmp.NEW_PLAN_END_DATE)
            WHERE tmp.budget_version_id = p_budget_version_id;
            --print_msg('synch_Upd: NumOfRowUpdated['||sql%rowcount||']');

                   /* set the respective changed flags */
		   /* Bug #5031939: remove budget_version id joins in the sub query */
                   UPDATE pa_fp_spread_calc_tmp tmp
                   SET tmp.SP_CURVE_CHANGE_FLAG = decode(NVL(tmp.OLD_SPREAD_CURVE_ID,1),NVL(tmp.NEW_SPREAD_CURVE_ID,1),'N','Y')
                   ,tmp.PLAN_DATES_CHANGE_FLAG =decode(tmp.OLD_PLAN_START_DATE,NULL,'N'
                                                            ,decode(tmp.NEW_PLAN_START_DATE,NULL,'N'
                                                             ,decode(tmp.OLD_PLAN_START_DATE,tmp.NEW_PLAN_START_DATE,'N','Y')))
                   ,tmp.SP_FIX_DATE_CHANGE_FLAG = decode(tmp.OLD_SP_FIX_DATE,NULL,'N'
                                                        ,decode(tmp.NEW_SP_FIX_DATE,NULL,'N'
                                                         ,decode(tmp.OLD_SP_FIX_DATE,tmp.NEW_SP_FIX_DATE,'N','Y')))
                   ,tmp.MFC_COST_CHANGE_FLAG = decode(NVL(tmp.OLD_MFC_COST_TYPE_ID,-999),NVL(tmp.NEW_MFC_COST_TYPE_ID,-999),'N','Y')
                   ,tmp.SYSTEM_REFERENCE_VAR1 = (SELECT 'Y'
                                                 FROM dual
                                                 WHERE EXISTS ( select null
                                                                from pa_budget_lines bl
                                                                where bl.budget_version_id = tmp.budget_version_id
                                                                and   bl.resource_assignment_id = tmp.resource_assignment_id
                                                                and   bl.txn_currency_code <> tmp.txn_currency_code
                                                                GROUP BY bl.resource_assignment_id,bl.txn_currency_code
                                                        ))
                   WHERE tmp.budget_version_id = p_budget_version_id;

                   UPDATE pa_fp_spread_calc_tmp tmp
                   SET tmp.PLAN_DATES_CHANGE_FLAG = decode(tmp.PLAN_DATES_CHANGE_FLAG,'Y','Y'
                                                        ,decode(tmp.OLD_PLAN_END_DATE,NULL,'N'
                                                            ,decode(tmp.NEW_PLAN_END_DATE,NULL,'N'
                                                             ,decode(tmp.OLD_PLAN_END_DATE,tmp.NEW_PLAN_END_DATE,'N','Y'))))
                        ,tmp.system_reference_var1 = NVL(system_reference_var1,'N')
                   WHERE tmp.budget_version_id = p_budget_version_id;
                   --print_msg('Number of rows updated with resp resAtrbflag['||sql%rowcount||']');

                   UPDATE pa_fp_spread_calc_tmp tmp
                   SET tmp.PLAN_START_DATE_SHRUNK_FLAG = decode(tmp.PLAN_DATES_CHANGE_FLAG,'N','N'
                                             ,decode(tmp.new_plan_start_date,NULL,'N'
                                              ,decode(tmp.old_plan_start_date,NULL,'N'
                                               ,decode(sign(trunc(tmp.new_plan_start_date) - trunc(tmp.old_plan_start_date)),1 ,'Y','N'))))
                   ,tmp.PLAN_END_DATE_SHRUNK_FLAG = decode(tmp.PLAN_DATES_CHANGE_FLAG,'N','N'
                                             ,decode(tmp.new_plan_end_date,NULL,'N'
                                               ,decode(tmp.old_plan_end_date,NULL,'N'
                                                ,decode(sign(trunc(tmp.new_plan_end_date) - trunc(tmp.old_plan_end_date)),-1 ,'Y','N'))))
                   WHERE tmp.budget_version_id = p_budget_version_id;
    END IF; --}

    IF P_PA_DEBUG_MODE = 'Y' Then
    print_msg('Out of synch_resAttribs api');
    End If;

EXCEPTION
        WHEN OTHERS THEN
                l_return_status := 'U';
                l_msg_data := sqlcode||sqlerrm;
                print_msg('Failed in synch_resAttribs API'||l_msg_data);
                 fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'synch_resAttribs ');
                RAISE;

END synch_resAttribs;

PROCEDURE synch_ChangedFlags(p_budget_version_id Number
            ,p_calling_module   IN Varchar2) IS

    l_msg_data      Varchar2(1000);
    l_return_status Varchar2(1);

BEGIN
	IF P_PA_DEBUG_MODE = 'Y' Then
    		print_msg('Enetered synch_ChangedFlags API');
	End If;
    IF (p_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION')
        and NVL(g_apply_progress_flag,'N') <> 'Y'
    and g_source_context = 'RESOURCE_ASSIGNMENT' ) Then  --{
	   /* Bug #5031939: remove budget_version id joins in the sub query */
            UPDATE pa_fp_spread_calc_tmp tmp
                SET tmp.SP_CURVE_CHANGE_FLAG = (select 'Y'
                            from dual
                        where exists (select null
                                 from pa_fp_spread_calc_tmp tmp1
                                 where tmp1.resource_assignment_id = tmp.resource_assignment_id
                                 and tmp1.sp_curve_change_flag = 'Y' ))
                   ,tmp.PLAN_DATES_CHANGE_FLAG = (select 'Y'
                                                from dual
                                                where exists (select null
                                                             from pa_fp_spread_calc_tmp tmp1
                                                             where tmp1.resource_assignment_id = tmp.resource_assignment_id
                                                             and tmp1.plan_dates_change_flag = 'Y' ))
                   ,tmp.SP_FIX_DATE_CHANGE_FLAG = (select 'Y'
                                                from dual
                                                where exists (select null
                                                             from pa_fp_spread_calc_tmp tmp1
                                                             where tmp1.resource_assignment_id = tmp.resource_assignment_id
                                                             and tmp1.sp_fix_date_change_flag = 'Y' ))
                   ,tmp.MFC_COST_CHANGE_FLAG = (select 'Y'
                                                from dual
                                                where exists (select null
                                                             from pa_fp_spread_calc_tmp tmp1
                                                             where tmp1.resource_assignment_id = tmp.resource_assignment_id
                                                             and tmp1.mfc_cost_change_flag = 'Y' ))
          ,tmp.PLAN_START_DATE_SHRUNK_FLAG = (select 'Y'
                            from dual
                            where exists (select null
                                from pa_fp_spread_calc_tmp tmp1
                                where tmp1.resource_assignment_id = tmp.resource_assignment_id
                                and tmp1.plan_start_date_shrunk_flag = 'Y'))
          ,tmp.PLAN_END_DATE_SHRUNK_FLAG = (select 'Y'
                                                        from dual
                                                        where exists (select null
                                                                from pa_fp_spread_calc_tmp tmp1
                                                                where tmp1.resource_assignment_id = tmp.resource_assignment_id
                                                                and tmp1.plan_end_date_shrunk_flag = 'Y'))
          ,tmp.RLM_ID_CHANGE_FLAG  = (select 'Y'
                                                        from dual
                                                        where exists (select null
                                                                from pa_fp_spread_calc_tmp tmp1
                                                                where tmp1.resource_assignment_id = tmp.resource_assignment_id
                                                                and tmp1.rlm_id_change_flag = 'Y'))
          ,(tmp.task_id,tmp.resource_name) =
                (select ra.task_id,rlm.alias
                 from pa_resource_assignments ra
                    ,pa_resource_list_members rlm
                 where ra.resource_assignment_id = tmp.resource_assignment_id
                 and  rlm.resource_list_member_id = ra.resource_list_member_id
                )
          ,tmp.billable_flag = NVL((select decode(NVL(tmp.billable_flag,'D'),'D'
					,decode(NVL(ra.task_id,0),0,'Y',NVL(t.billable_flag,'N')),NVL(tmp.billable_flag,'N'))
                      from pa_resource_assignments ra
                         ,pa_tasks t
                      where ra.resource_assignment_id = tmp.resource_assignment_id
                      and   t.task_id(+) = ra.task_id
                      ),'N')
	   ,tmp.task_name = (select t.task_name
			     from pa_resource_assignments ra
                         	,pa_tasks t
                      		where ra.resource_assignment_id = tmp.resource_assignment_id
                      		and   t.task_id = ra.task_id
			     )
           WHERE tmp.budget_version_id = p_budget_version_id;
                --print_msg('Number of rows updated with resp resAtrbflag['||sql%rowcount||']');

        /* Now set all the resource attributs N when planning resource is changed */
                UPDATE pa_fp_spread_calc_tmp tmp
                SET tmp.SP_CURVE_CHANGE_FLAG = 'N'
                   ,tmp.PLAN_DATES_CHANGE_FLAG = 'N'
                   ,tmp.SP_FIX_DATE_CHANGE_FLAG = 'N'
                   ,tmp.MFC_COST_CHANGE_FLAG = 'N'
                   ,tmp.PLAN_START_DATE_SHRUNK_FLAG = 'N'
                   ,tmp.PLAN_END_DATE_SHRUNK_FLAG = 'N'
                WHERE tmp.budget_version_id = p_budget_version_id
        AND  tmp.RLM_ID_CHANGE_FLAG  = 'Y' ;
                --print_msg('Number of rows updated with resp resAtrbflag['||sql%rowcount||']');

    ELSE
        /* This is done to avoid executing the cursors multiple times for passing token values */
        UPDATE pa_fp_spread_calc_tmp tmp
        SET (tmp.task_id,tmp.resource_name) =
                                (select ra.task_id,rlm.alias
                                 from pa_resource_assignments ra
                                        ,pa_resource_list_members rlm
                                 where ra.resource_assignment_id = tmp.resource_assignment_id
                                 and  rlm.resource_list_member_id = ra.resource_list_member_id
                                )
                ,tmp.billable_flag = NVL((select decode(NVL(tmp.billable_flag,'D'),'D'
                                        ,decode(NVL(ra.task_id,0),0,'Y',NVL(t.billable_flag,'N')),NVL(tmp.billable_flag,'N'))
                      from pa_resource_assignments ra
                         ,pa_tasks t
                      where ra.resource_assignment_id = tmp.resource_assignment_id
                      and   t.task_id(+) = ra.task_id
                      ),'N')
		,tmp.task_name = (select t.task_name
                             from pa_resource_assignments ra
                                ,pa_tasks t
                                where ra.resource_assignment_id = tmp.resource_assignment_id
                                and   t.task_id = ra.task_id
                             )
                WHERE tmp.budget_version_id = p_budget_version_id;

    END IF; --}
EXCEPTION
        WHEN OTHERS THEN
                l_return_status := 'U';
                l_msg_data := sqlcode||sqlerrm;
                print_msg('Failed in synch_ChangedFlags API'||l_msg_data);
                 fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'synch_ChangedFlags');
                RAISE;

END synch_ChangedFlags;

/* This is the main API called from the calculate api. This api populates the tmp table from passed in
 * plsql params. and later used this global tmp table for further processing in bulk mode
 */
PROCEDURE populate_spreadCalc_Tmp(
                p_budget_version_id              IN  Number
        ,p_budget_version_type           IN  Varchar2
        ,p_calling_module                IN  Varchar2
                ,p_source_context                IN  Varchar2
        ,p_time_phased_code              IN  Varchar2
        ,p_apply_progress_flag           IN  Varchar2 DEFAULT 'N'
        ,p_rollup_required_flag          IN  Varchar2 DEFAULT 'Y'
        ,p_refresh_rates_flag        IN  Varchar2 DEFAULT 'N'
            ,p_refresh_conv_rates_flag   IN  Varchar2 DEFAULT 'N'
            ,p_mass_adjust_flag      IN  Varchar2 DEFAULT 'N'
	    ,p_time_phase_changed_flag   IN Varchar2 DEFAULT 'N' /* Bug fix:4613444 */
	    	,p_wp_cost_changed_flag   IN Varchar2 DEFAULT 'N' /* Bug fix:4613444 */
                ,x_resource_assignment_tab       IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_delete_budget_lines_tab       IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_spread_amts_flag_tab          IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_txn_currency_code_tab         IN  OUT NOCOPY SYSTEM.pa_varchar2_15_tbl_type
                ,x_txn_currency_override_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_15_tbl_type
                ,x_total_qty_tab                 IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_addl_qty_tab                  IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_total_raw_cost_tab            IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_addl_raw_cost_tab             IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_total_burdened_cost_tab       IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_addl_burdened_cost_tab        IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_total_revenue_tab             IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_addl_revenue_tab              IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_raw_cost_rate_tab             IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_rw_cost_rate_override_tab     IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_b_cost_rate_tab               IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_b_cost_rate_override_tab      IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_bill_rate_tab                 IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_bill_rate_override_tab        IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_line_start_date_tab           IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_line_end_date_tab             IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_apply_progress_flag_tab       IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_spread_curve_id_old_tab       IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_spread_curve_id_new_tab       IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_sp_fixed_date_old_tab         IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_sp_fixed_date_new_tab         IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_plan_start_date_old_tab       IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_plan_start_date_new_tab       IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_plan_end_date_old_tab         IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_plan_end_date_new_tab         IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_re_spread_flag_tab            IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_sp_curve_change_flag_tab      IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_plan_dates_change_flag_tab    IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_spfix_date_flag_tab           IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_mfc_cost_change_flag_tab      IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_mfc_cost_type_id_old_tab      IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_mfc_cost_type_id_new_tab      IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
        ,x_rlm_id_change_flag_tab        IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
        ,x_plan_sdate_shrunk_flag_tab    IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_plan_edate_shrunk_flag_tab    IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_mfc_cost_refresh_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
        ,x_ra_in_multi_cur_flag_tab      IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
        ,x_quantity_changed_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_raw_cost_changed_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_cost_rate_changed_flag_tab    IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_burden_cost_changed_flag_tab  IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_burden_rate_changed_flag_tab  IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_rev_changed_flag_tab          IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_bill_rate_changed_flag_tab    IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
        	,x_multcur_plan_start_date_tab   IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_multcur_plan_end_date_tab     IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
        	,x_fp_task_billable_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
		,x_cost_rt_miss_num_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_burd_rt_miss_num_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_bill_rt_miss_num_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_Qty_miss_num_flag_tab         IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_Rw_miss_num_flag_tab          IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_Br_miss_num_flag_tab          IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_Rv_miss_num_flag_tab          IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_rev_only_entry_flag_tab       IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
		/* bug fix:5726773 */
 	        ,x_neg_Qty_Changflag_tab           IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
 	        ,x_neg_Raw_Changflag_tab         IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
 	        ,x_neg_Burd_Changflag_tab          IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
 	        ,x_neg_rev_Changflag_tab           IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_return_status                 OUT NOCOPY VARCHAR2
        ,x_msg_data                      OUT NOCOPY varchar2
                ) IS

    l_stage     Varchar2(1000);

    CURSOR cur_sprdRecs IS
    SELECT tmp.resource_assignment_id
        ,tmp.txn_currency_code
        ,tmp.old_spread_curve_id
        ,tmp.new_spread_curve_id
        ,tmp.old_sp_fix_date
        ,tmp.new_sp_fix_date
        ,tmp.old_plan_start_date
        ,tmp.new_plan_start_date
        ,tmp.old_plan_end_date
        ,tmp.new_plan_end_date
        ,tmp.re_spread_amts_flag
        ,tmp.sp_curve_change_flag
        ,tmp.plan_dates_change_flag
        ,tmp.sp_fix_date_change_flag
        ,tmp.mfc_cost_change_flag
        ,tmp.old_mfc_cost_type_id
        ,tmp.new_mfc_cost_type_id
        ,tmp.etc_start_date
        ,tmp.project_currency_code
        ,tmp.projfunc_currency_code
        ,NVL(tmp.system_reference_var1,'N')  MultiCurrLineFlag
        ,NVL(tmp.plan_start_date_shrunk_flag,'N') plan_start_date_shrunk_flag
        ,NVL(tmp.plan_end_date_shrunk_flag,'N') plan_end_date_shrunk_flag
        ,NVL(tmp.rlm_id_change_flag,'N') rlm_id_change_flag
    FROM pa_fp_spread_calc_tmp tmp
    WHERE  tmp.budget_version_id = p_budget_version_id
    AND    NVL(tmp.system_reference_var1,'N') = 'Y'
    AND    NVL(tmp.rlm_id_change_flag,'N') <> 'Y'
    AND   (tmp.re_spread_amts_flag  = 'Y'
               OR tmp.sp_curve_change_flag  = 'Y'
               OR tmp.plan_dates_change_flag  = 'Y'
               OR tmp.sp_fix_date_change_flag  = 'Y'
               OR tmp.mfc_cost_change_flag = 'Y'
        );


    CURSOR cur_MultipleAdjustments_chk IS
    SELECT 'Y'
    FROM DUAL
    WHERE EXISTS (SELECT 'MultipleLAdjustments'
            FROM pa_fp_spread_calc_tmp tmp
            WHERE tmp.budget_version_id = p_budget_version_id
            AND  ((decode(tmp.OLD_PLAN_START_DATE,NULL,'N'
                                 ,decode(tmp.NEW_PLAN_START_DATE,NULL,'N'
                                  ,decode(tmp.OLD_PLAN_START_DATE,tmp.NEW_PLAN_START_DATE,'N','Y'))) ='Y')
                OR
                (decode(tmp.OLD_PLAN_END_DATE,NULL,'N'
                                 ,decode(tmp.NEW_PLAN_END_DATE,NULL,'N'
                                  ,decode(tmp.OLD_PLAN_END_DATE,tmp.NEW_PLAN_END_DATE,'N','Y'))) = 'Y')
                 )
            GROUP BY tmp.resource_assignment_id
            HAVING count(*) > 1
             );

    /* This cursor picks all the required info to populate error msg stack */
    CURSOR cur_msgStackDetails IS
    SELECT tmp.resource_assignment_id
        ,rl.alias  resource_name
    ,tmp.txn_currency_code
        ,tmp.old_plan_start_date
        ,tmp.new_plan_start_date
        ,tmp.old_plan_end_date
        ,tmp.new_plan_end_date
        ,tmp.old_spread_curve_id
        ,tmp.new_spread_curve_id
        ,tmp.old_sp_fix_date
        ,tmp.new_sp_fix_date
        ,tmp.old_mfc_cost_type_id
        ,tmp.new_mfc_cost_type_id
    FROM pa_fp_spread_calc_tmp tmp
        ,pa_resource_list_members rl
        ,pa_resource_assignments ra
        WHERE tmp.budget_version_id = p_budget_version_id
    AND   ra.resource_assignment_id = tmp.resource_assignment_id
    AND   rl.resource_list_member_id = ra.resource_list_member_id
    /** Bug fix:  ORA-00979: not a GROUP BY expression in Package PA_FP_CALC_UTILS
        AND  ((decode(tmp.OLD_PLAN_START_DATE,NULL,'N'
                ,decode(tmp.NEW_PLAN_START_DATE,NULL,'N'
                  ,decode(tmp.OLD_PLAN_START_DATE,tmp.NEW_PLAN_START_DATE,'N','Y'))) ='Y')
               OR
               (decode(tmp.OLD_PLAN_END_DATE,NULL,'N'
                 ,decode(tmp.NEW_PLAN_END_DATE,NULL,'N'
                   ,decode(tmp.OLD_PLAN_END_DATE,tmp.NEW_PLAN_END_DATE,'N','Y'))) = 'Y')
               )
        GROUP BY tmp.resource_assignment_id
        HAVING count(*) > 1 ;
        *** End of bug fix**/
        AND EXISTS (SELECT 'MultipleLAdjustments'
                    FROM pa_fp_spread_calc_tmp tmpb
                    WHERE tmpb.budget_version_id = tmp.budget_version_id
                    AND   tmpb.resource_assignment_id = tmp.resource_assignment_id
                    AND  ((decode(tmpb.OLD_PLAN_START_DATE,NULL,'N'
                           ,decode(tmpb.NEW_PLAN_START_DATE,NULL,'N'
                            ,decode(tmpb.OLD_PLAN_START_DATE,tmpb.NEW_PLAN_START_DATE,'N','Y'))) ='Y')
                          OR
                           (decode(tmpb.OLD_PLAN_END_DATE,NULL,'N'
                            ,decode(tmpb.NEW_PLAN_END_DATE,NULL,'N'
                             ,decode(tmpb.OLD_PLAN_END_DATE,tmpb.NEW_PLAN_END_DATE,'N','Y'))) = 'Y')
                          )
                    GROUP BY tmpb.resource_assignment_id
                    HAVING count(*) > 1
                    );

    /* This cursor checks that calling api has passed duplicate set of records */
    CURSOR cur_chk_dupRecords IS
        SELECT tmp.resource_assignment_id
                ,tmp.txn_currency_code
        FROM pa_fp_spread_calc_tmp tmp
        WHERE tmp.budget_version_id = p_budget_version_id
        GROUP BY tmp.resource_assignment_id
                ,tmp.txn_currency_code
        HAVING COUNT(*) > 1 ;

    l_plan_start_date_shrunk Varchar2(10) := 'N';
        l_plan_end_date_shrunk   Varchar2(10) := 'N';
    l_MultipleAdjustments_Flag  Varchar2(10) := 'N';

    l_return_status      Varchar2(1) := 'S';

    FUNCTION IsCacheReqd(p_calling_context VARCHAR2 ) RETURN VARCHAR2 IS

        l_return_flg  Varchar2(1) := 'N';
    BEGIN
        SELECT 'Y'
        INTO l_return_flg
        FROM DUAL
        WHERE EXISTS (Select null
                from pa_fp_spread_calc_tmp tmp
                where  ( NVL(tmp.sp_curve_change_flag,'N') = 'Y'
                            OR NVL(tmp.plan_dates_change_flag,'N') = 'Y'
                            OR NVL(tmp.sp_fix_date_change_flag,'N') = 'Y'
                    OR NVL(tmp.re_spread_amts_flag,'N') = 'Y'
                            OR ( (NVL(tmp.mfc_cost_change_flag,'N') = 'Y'
                          AND p_calling_context = 'RATXNCOMBO')
                       )
                    --OR NVL(tmp.rlm_id_changed_flag,'N') = 'Y'
                        ));

        RETURN l_return_flg;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_return_flg := 'N';
            RETURN l_return_flg;
    END IsCacheReqd;

BEGIN
        x_return_status := 'S';
    l_return_status := 'S';
        x_msg_data := NULL;

        /* Initialize the error stack */
    If p_pa_debug_mode = 'Y' Then
        pa_debug.init_err_stack('PA_FP_CALC_UTILS.populate_spreadCalc_Tmp');
    	print_msg(' Entered populate_spreadCalc_Tmp API');
    End If;
    /* populate tmp table with the data */
       Init_plsqlTabs;
       DELETE FROM pa_fp_spread_calc_tmp;
       DELETE FROM pa_fp_rollup_tmp
       WHERE budget_version_id = p_budget_version_id;

       bvDetailsRec := NULL;
       OPEN cur_bvDetails(p_budget_version_id);
       FETCH cur_bvDetails INTO bvDetailsRec;
       CLOSE cur_bvDetails;
       /* cache the period details info */
 	         perdRec := NULL;
 	         OPEN periodDetails(p_budget_version_id);
 	         FETCH periodDetails INTO perdRec;
 	         CLOSE periodDetails;

       g_rollup_required_flag :=  NVL(p_rollup_required_flag,'N');
       g_calling_module       := p_calling_module;
       g_budget_version_id    := p_budget_version_id;
       g_budget_version_type  := bvDetailsRec.version_type;
       g_budget_version_name  := bvDetailsRec.version_name;
       g_etc_start_date       := bvDetailsRec.etc_start_date;
       g_project_name         := bvDetailsRec.project_name;
           g_wp_version_flag      := NVL(bvDetailsRec.wp_version_flag,'N');
       g_refresh_rates_flag    := NVL(p_refresh_rates_flag,'N');
           g_refresh_conv_rates_flag  := NVL(p_refresh_conv_rates_flag,'N');
           g_mass_adjust_flag       := NVL(p_mass_adjust_flag,'N');
           g_source_context         := p_source_context;
           g_apply_progress_flag    := NVL(p_apply_progress_flag,'N');
       g_project_currency_code  := bvDetailsRec.project_currency_code;
       g_projfunc_currency_code  := bvDetailsRec.projfunc_currency_code;
       g_baseline_funding_flag  := NVL(bvDetailsRec.baseline_funding_flag,'N');
       g_approved_revenue_flag  := NVL(bvDetailsRec.approved_rev_plan_type_flag,'N');
	g_project_id    := bvDetailsRec.project_id;
        g_ciId          := bvDetailsRec.ciId;
        g_plan_class_type :=    bvDetailsRec.plan_class_type;
        g_time_phase_changed_flag := NVL(p_time_phase_changed_flag,'N');  /* Bug fix:4613444 */
        g_wp_cost_changed_flag    := NVL(p_wp_cost_changed_flag,'N');

	IF P_PA_DEBUG_MODE = 'Y' Then
       		print_msg('populating spread_calc_tmp table from in params');
	End If;

	/*Start of Perf Impr:5309529: Added this new api as part of perf enhancement */
	  insert_calcTmp_records
		( x_resource_assignment_tab       => x_resource_assignment_tab
                ,x_delete_budget_lines_tab        => x_delete_budget_lines_tab
                ,x_spread_amts_flag_tab           => x_spread_amts_flag_tab
                ,x_txn_currency_code_tab          => x_txn_currency_code_tab
                ,x_txn_currency_override_tab      => x_txn_currency_override_tab
                ,x_total_qty_tab                  => x_total_qty_tab
                ,x_addl_qty_tab                   => x_addl_qty_tab
                ,x_total_raw_cost_tab             => x_total_raw_cost_tab
                ,x_addl_raw_cost_tab              => x_addl_raw_cost_tab
                ,x_total_burdened_cost_tab        => x_total_burdened_cost_tab
                ,x_addl_burdened_cost_tab         => x_addl_burdened_cost_tab
                ,x_total_revenue_tab              => x_total_revenue_tab
                ,x_addl_revenue_tab               => x_addl_revenue_tab
                ,x_raw_cost_rate_tab              => x_raw_cost_rate_tab
                ,x_rw_cost_rate_override_tab      => x_rw_cost_rate_override_tab
                ,x_b_cost_rate_tab                => x_b_cost_rate_tab
                ,x_b_cost_rate_override_tab       => x_b_cost_rate_override_tab
                ,x_bill_rate_tab                  => x_bill_rate_tab
                ,x_bill_rate_override_tab         => x_bill_rate_override_tab
                ,x_line_start_date_tab            => x_line_start_date_tab
                ,x_line_end_date_tab              => x_line_end_date_tab
                ,x_apply_progress_flag_tab        => x_apply_progress_flag_tab
                ,x_spread_curve_id_old_tab        => x_spread_curve_id_old_tab
                ,x_spread_curve_id_new_tab        => x_spread_curve_id_new_tab
                ,x_sp_fixed_date_old_tab          => x_sp_fixed_date_old_tab
                ,x_sp_fixed_date_new_tab          => x_sp_fixed_date_new_tab
                ,x_plan_start_date_old_tab        => x_plan_start_date_old_tab
                ,x_plan_start_date_new_tab        => x_plan_start_date_new_tab
                ,x_plan_end_date_old_tab          => x_plan_end_date_old_tab
		,x_plan_end_date_new_tab          => x_plan_end_date_new_tab
                ,x_re_spread_flag_tab             => x_re_spread_flag_tab
                ,x_sp_curve_change_flag_tab       => x_sp_curve_change_flag_tab
                ,x_plan_dates_change_flag_tab     => x_plan_dates_change_flag_tab
                ,x_spfix_date_flag_tab            => x_spfix_date_flag_tab
                ,x_mfc_cost_change_flag_tab       => x_mfc_cost_change_flag_tab
                ,x_mfc_cost_type_id_old_tab       => x_mfc_cost_type_id_old_tab
                ,x_mfc_cost_type_id_new_tab       => x_mfc_cost_type_id_new_tab
        	,x_rlm_id_change_flag_tab         => x_rlm_id_change_flag_tab
        	,x_plan_sdate_shrunk_flag_tab     => x_plan_sdate_shrunk_flag_tab
                ,x_plan_edate_shrunk_flag_tab     => x_plan_edate_shrunk_flag_tab
                ,x_mfc_cost_refresh_flag_tab      => x_mfc_cost_refresh_flag_tab
        	,x_ra_in_multi_cur_flag_tab       => x_ra_in_multi_cur_flag_tab
        	,x_quantity_changed_flag_tab      => x_quantity_changed_flag_tab
                ,x_raw_cost_changed_flag_tab      => x_raw_cost_changed_flag_tab
                ,x_cost_rate_changed_flag_tab     => x_cost_rate_changed_flag_tab
                ,x_burden_cost_changed_flag_tab   => x_burden_cost_changed_flag_tab
                ,x_burden_rate_changed_flag_tab   => x_burden_rate_changed_flag_tab
                ,x_rev_changed_flag_tab           => x_rev_changed_flag_tab
                ,x_bill_rate_changed_flag_tab     => x_bill_rate_changed_flag_tab
                ,x_multcur_plan_start_date_tab    => x_multcur_plan_start_date_tab
                ,x_multcur_plan_end_date_tab      => x_multcur_plan_end_date_tab
                ,x_fp_task_billable_flag_tab      => x_fp_task_billable_flag_tab
                ,x_cost_rt_miss_num_flag_tab      => x_cost_rt_miss_num_flag_tab
                ,x_burd_rt_miss_num_flag_tab      => x_burd_rt_miss_num_flag_tab
                ,x_bill_rt_miss_num_flag_tab      => x_bill_rt_miss_num_flag_tab
                ,x_Qty_miss_num_flag_tab          => x_Qty_miss_num_flag_tab
                ,x_Rw_miss_num_flag_tab           => x_Rw_miss_num_flag_tab
                ,x_Br_miss_num_flag_tab           => x_Br_miss_num_flag_tab
                ,x_Rv_miss_num_flag_tab           => x_Rv_miss_num_flag_tab
                ,x_rev_only_entry_flag_tab        => x_rev_only_entry_flag_tab
                ,x_return_status                  => l_return_status
                ,x_msg_data                       => x_msg_data
		);
		IF l_return_status <> 'S' Then
			x_return_status := 'E';
		End If;
	   /* end of Perf Impr:5309529 */
	   /*******
           FORALL i IN x_resource_assignment_tab.FIRST .. x_resource_assignment_tab.LAST
                INSERT INTO pa_fp_spread_calc_tmp
                        (RESOURCE_ASSIGNMENT_ID --resource_assignment_id
                         ,DELETE_BL_FLAG          --delete_budget_lines_flag
                         ,SPREAD_AMTS_FLAG      --spread_amts_flag
                         ,TXN_CURRENCY_CODE     --txn_currency_code
                         ,TXN_CURR_CODE_OVERRIDE --txn_currency_override
                         ,QUANTITY              --total_qty
                         ,SYSTEM_REFERENCE_NUM1 --addl_qty
                         ,TXN_RAW_COST          --total_raw_cost
                         ,SYSTEM_REFERENCE_NUM2 --addl_raw_cost
                         ,TXN_BURDENED_COST     --total_burdened_cost
                         ,SYSTEM_REFERENCE_NUM3 --addl_burdened_cost
                         ,TXN_REVENUE           --total_revenue
                         ,SYSTEM_REFERENCE_NUM4 --addl_revenue
                         ,COST_RATE             --raw_cost_rate
                         ,COST_RATE_OVERRIDE    --rw_cost_rate_override
                         ,BURDEN_COST_RATE      --b_cost_rate
                         ,BURDEN_COST_RATE_OVERRIDE --b_cost_rate_override
                         ,BILL_RATE             --bill_rate
                         ,BILL_RATE_OVERRIDE    --bill_rate_override
                         ,START_DATE            --line_start_date
                         ,END_DATE              --line_end_date
                         ,APPLY_PROGRESS_FLAG   --apply_progress_flag
                         ,BUDGET_VERSION_ID     --budget_version_id
                         ,OLD_SPREAD_CURVE_ID   --x_spread_curve_id_old_tab
                         ,NEW_SPREAD_CURVE_ID   --x_spread_curve_id_new_tab
                         ,OLD_SP_FIX_DATE       --x_sp_fixed_date_old_tab
                         ,NEW_SP_FIX_DATE       --x_sp_fixed_date_new_tab
                         ,OLD_PLAN_START_DATE   --x_plan_start_date_old_tab
                         ,NEW_PLAN_START_DATE   --x_plan_start_date_new_tab
                         ,OLD_PLAN_END_DATE     --x_plan_end_date_old_tab
                         ,NEW_PLAN_END_DATE     --x_plan_end_date_new_tab
                         ,RE_SPREAD_AMTS_FLAG   --x_re_spread_flag_tab
                         ,SP_CURVE_CHANGE_FLAG  --x_sp_curve_change_flag_tab
                         ,PLAN_DATES_CHANGE_FLAG --x_plan_dates_change_flag_tab
                         ,SP_FIX_DATE_CHANGE_FLAG --x_spfix_date_flag_tab
                         ,MFC_COST_CHANGE_FLAG   --x_mfc_cost_change_flag_tab
                         ,OLD_MFC_COST_TYPE_ID   --x_mfc_cost_type_id_old_tab
                         ,NEW_MFC_COST_TYPE_ID   --x_mfc_cost_type_id_new_tab
             ,ETC_START_DATE
             ,PROJECT_CURRENCY_CODE
             ,PROJFUNC_CURRENCY_CODE
             ,RLM_ID_CHANGE_FLAG
             ,BUDGET_VERSION_TYPE
            ,BILLABLE_FLAG
			,COST_RATE_G_MISS_NUM_FLAG
			,BURDEN_RATE_G_MISS_NUM_FLAG
			,BILL_RATE_G_MISS_NUM_FLAG
			,QUANTITY_G_MISS_NUM_FLAG
			,RAW_COST_G_MISS_NUM_FLAG
			,BURDEN_COST_G_MISS_NUM_FLAG
			,REVENUE_G_MISS_NUM_FLAG
                        )
                VALUES (
                        x_resource_assignment_tab(i)
                        ,x_delete_budget_lines_tab(i)
                        ,x_spread_amts_flag_tab(i)
                        ,x_txn_currency_code_tab(i)
                        ,x_txn_currency_override_tab(i)
                        ,x_total_qty_tab(i)
                        ,x_addl_qty_tab(i)
                        ,x_total_raw_cost_tab(i)
                        ,x_addl_raw_cost_tab(i)
                        ,x_total_burdened_cost_tab(i)
                        ,x_addl_burdened_cost_tab(i)
                        ,x_total_revenue_tab(i)
                        ,x_addl_revenue_tab(i)
                        ,x_raw_cost_rate_tab(i)
                        ,x_rw_cost_rate_override_tab(i)
                        ,x_b_cost_rate_tab(i)
                        ,x_b_cost_rate_override_tab(i)
                        ,x_bill_rate_tab(i)
                        ,x_bill_rate_override_tab(i)
                        ,x_line_start_date_tab(i)
                        ,x_line_end_date_tab(i)
                        ,x_apply_progress_flag_tab(i)
                        ,g_budget_version_id
                        ,x_spread_curve_id_old_tab(i)
                        ,x_spread_curve_id_new_tab(i)
                        ,x_sp_fixed_date_old_tab(i)
                        ,x_sp_fixed_date_new_tab(i)
                        ,x_plan_start_date_old_tab(i)
                        ,x_plan_start_date_new_tab(i)
                        ,x_plan_end_date_old_tab(i)
                        ,x_plan_end_date_new_tab(i)
                        ,x_re_spread_flag_tab(i)
                        ,x_sp_curve_change_flag_tab(i)
                        ,x_plan_dates_change_flag_tab(i)
                        ,x_spfix_date_flag_tab(i)
                        ,x_mfc_cost_change_flag_tab(i)
                        ,x_mfc_cost_type_id_old_tab(i)
                        ,x_mfc_cost_type_id_new_tab(i)
            		,g_etc_start_date
            		,g_project_currency_code
            		,g_projfunc_currency_code
            		,x_rlm_id_change_flag_tab(i)
            		,g_budget_version_type
            		,x_fp_task_billable_flag_tab(i)
			,x_cost_rt_miss_num_flag_tab(i)
                	,x_burd_rt_miss_num_flag_tab(i)
                	,x_bill_rt_miss_num_flag_tab(i)
			,x_Qty_miss_num_flag_tab(i)
                	,x_Rw_miss_num_flag_tab(i)
                	,x_Br_miss_num_flag_tab(i)
                	,x_Rv_miss_num_flag_tab(i)
              );
	 ************/
	IF P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Number of rows populated['||sql%rowcount||']');
	End If;

        /* Bug fix: 3841644 Added the following check to validate the duplicate records sent by calling API */
                IF g_source_context = 'RESOURCE_ASSIGNMENT'
		   AND NVL(g_time_phase_changed_flag,'N') = 'N' Then
            	   FOR i IN cur_chk_dupRecords LOOP
                        --print_msg('Duplicate Resource Assignments sent for Calcaulate API');
                        pa_utils.add_message
                        ( p_app_short_name => 'PA'
                        ,p_msg_name       => 'PA_FP_DUPRES_RECORDS'
                        ,p_token1       => 'RESOURCE_ID'
                        ,p_value1       => i.resource_assignment_id
                        ,p_token2       => 'TXN_CURRENCY_CODE'
                        ,p_value2       => i.txn_currency_code
                        ,p_token3       => 'BUDGET_VERSION_ID'
                        ,p_value3       => p_budget_version_id
                        );
                        --print_msg('ResId['||i.resource_assignment_id||']txnCur['||i.txn_currency_code||']');
                        l_return_status := 'E';
            		x_return_status := 'E';
                    END LOOP;
        End If;

    IF p_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION') Then  --{
            IF NVL(l_return_status,'S') = 'S'
 	                 AND g_source_context = 'RESOURCE_ASSIGNMENT'
 	                 AND NVL(g_time_phase_changed_flag,'N') = 'N' Then
                   /* Check that If User changes the plan dates for same resource more than once then abort the process */
                   OPEN cur_MultipleAdjustments_chk;
                   FETCH cur_MultipleAdjustments_chk INTO l_MultipleAdjustments_flag;
                   CLOSE cur_MultipleAdjustments_chk;

                   print_msg('Check MultipleLinesAdjustmentFlag['||l_MultipleAdjustments_flag||']');
                   IF NVL(l_MultipleAdjustments_flag,'N') = 'Y' THEN
                        l_return_status := 'E';
                        x_return_status := 'E';
			IF P_PA_DEBUG_MODE = 'Y' Then
                        print_msg('Multiple adjustments found for the single resource');
			End If;
                        FOR i IN cur_msgStackDetails LOOP
                         l_stage := 'RaId['||i.resource_assignment_id||']TxnCur['||i.txn_currency_code||']oldSD[';
                         l_stage := l_stage||i.old_plan_start_date||']NewSD['||i.new_plan_start_date;
                         l_stage := l_stage||']oldED['||i.old_plan_end_date||']newED['||i.new_plan_end_date||']';
                         --print_msg(l_stage);
                            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA'
                                ,p_msg_name      => 'PA_FP_RA_MULTI_ADJUSTMENT'
                                ,p_token1        => 'L_RESOURCE_NAME'
                                ,p_value1        =>  i.resource_name
                                ,p_token2        => 'L_OLD_START_DATE'
                                ,p_value2        =>  i.old_plan_start_date
                                ,p_token3        => 'L_NEW_START_DATE'
                                ,p_value3        => i.new_plan_start_date
                                ,p_token4        => 'L_OLD_END_DATE'
                                ,p_value4        => i.old_plan_end_date
                                ,p_token5        => 'L_NEW_END_DATE'
                                ,p_value5        =>  i.new_plan_end_date
                                );
                        END LOOP;
                   END IF;
           END IF;
        END IF;  --}

        IF ( g_refresh_rates_flag = 'N'
             AND g_refresh_conv_rates_flag = 'N'
	     AND NVL(g_time_phase_changed_flag,'N') = 'N'
             AND g_mass_adjust_flag = 'N') Then  --{

          If NVL(l_return_status,'S') = 'S' Then
            /* Bug fix:4221650,4221590 : AMG apis are creating budget lines with null quantity and calling calculate API
             * to spread the amounts. The existing line distribution methods spreads the quantiy based on the exisiting plan quantity
                     * since budget line donot have any quantity, the spread fails to create a budget lines
                     * This is happening through MSP/AMG flow
             * call to pji api is not required as these corrupted lines was not passed to pji
             */
                /* Bug fix:4272944 Starts */
            IF ( NVL(g_baseline_funding_flag,'N') = 'Y'
            AND NVL(g_baseline_funding_flag,'N') = 'Y' ) THEN
                --print_msg('Bug fix:4272944: DONOT DELETE AUTOBASELINE zero qty budget lines');
                null;
                /* Bug fix:4272944 Ends */
            ELSIF x_resource_assignment_tab.COUNT > 0 THEN
	     IF P_PA_DEBUG_MODE = 'Y' Then
             print_msg('Delete zero Quantity budget lines where actuals donot exists');
	     End If;
             FORALL i IN x_resource_assignment_tab.FIRST .. x_resource_assignment_tab.LAST
             DELETE FROM pa_budget_lines bl
             WHERE bl.budget_version_id = p_budget_version_id
             AND  bl.resource_assignment_id = x_resource_assignment_tab(i)
             AND  NVL(bl.quantity,0)            = 0
             AND (NVL(bl.init_quantity,0)       = 0
              and NVL(bl.txn_raw_cost,0)        = 0
                          and NVL(bl.txn_burdened_cost,0)   = 0
                          and NVL(bl.txn_revenue,0)         = 0
                  and NVL(bl.txn_init_raw_cost,0)   = 0
              and NVL(bl.txn_init_burdened_cost,0)  = 0
              and NVL(bl.txn_init_revenue,0)    = 0
             );
	     IF P_PA_DEBUG_MODE = 'Y' Then
            	print_msg('Number of lines deleted['||sql%rowcount||']');
	     End If;
            END IF;

            IF NVL(l_return_status,'S') = 'S' Then
                /* Now update the Rate/Amount/Qty changed flags on the Tmp table */
		IF P_PA_DEBUG_MODE = 'Y' Then
                print_msg('Calling Compare_bdgtLine_Values Api');
		End If;
                Compare_bdgtLine_Values
            	    (p_budget_version_id             => p_budget_version_id
                    ,p_budget_version_type           => p_budget_version_type
                    ,p_source_context                => p_source_context
                    ,p_apply_progress_flag           => p_apply_progress_flag
            ,x_return_status                 => l_return_status
            ,x_msg_data                      => x_msg_data
            );
                If l_return_status <> 'S' Then
                x_return_status := 'E';
                End If;
            End If;
        END IF;  --}

        /* If multiple RA + Txn cur combo is passed, then updates the res attributes whereever it is null */
	IF P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Calling synchronize resource attributes api');
	End If;
        synch_resAttribs(p_budget_version_id => p_budget_version_id
                ,p_calling_module    => p_calling_module );

        /* now synchronize all the flags */
	IF P_PA_DEBUG_MODE = 'Y' Then
        print_msg('calling synchronize changed flag api');
	End If;
        synch_ChangedFlags(p_budget_version_id => p_budget_version_id
                   ,p_calling_module    => p_calling_module );

        IF ( g_refresh_rates_flag = 'N'
                     AND g_refresh_conv_rates_flag = 'N'
                     AND g_mass_adjust_flag = 'N'
		AND NVL(g_time_phase_changed_flag,'N') = 'N'
             AND g_apply_progress_flag = 'N' ) THEN  --{

         IF (l_return_status = 'S'
             AND bvDetailsRec.Wp_Version_Flag <> 'Y'
             AND IsCacheReqd(p_calling_context => 'RATXNCOMBO') = 'Y'
             AND p_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION')) Then
           /* Now populate the tmp table with other RA +Txn currnecy combo for resource planned in multi currency */
	   IF P_PA_DEBUG_MODE = 'Y' Then
           print_msg('Calling populate_blTxnCurCombo api');
	   End If;
           populate_blTxnCurCombo
                   (p_budget_version_id     => p_budget_version_id
                   ,x_return_status             => l_return_status
                   );
	   IF P_PA_DEBUG_MODE = 'Y' Then
           print_msg('RetSts after populate_blTxnCurCombo ['||l_return_status||']');
	   End If;
           If l_return_status <> 'S' Then
            x_return_status := l_return_status;
            x_msg_data := sqlcode||sqlerrm ;
           End If;
         End IF;

	    /* Ipm changes */
	    If l_return_status = 'S' AND NVL(g_apply_progress_flag,'N') <> 'Y' Then --{
	       If p_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION') Then
		IF P_PA_DEBUG_MODE = 'Y' Then
            	print_msg('Calling Reset_ratebased_pltrxns API');
		End If;
            	Reset_ratebased_pltrxns(
                    p_budget_version_id              => p_budget_version_id
                    ,p_source_context                => p_source_context
                    ,x_return_status                 => l_return_status
                    );
		IF P_PA_DEBUG_MODE = 'Y' Then
            	print_msg('RetSts of Reset_ratebased_pltrxns API ['||l_return_status||']');
		End If;
            	If l_return_status <> 'S' Then
                            x_return_status := 'E';
            	End If;
	       End If;

		If l_return_status = 'S' and p_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION') Then
			IF P_PA_DEBUG_MODE = 'Y' Then
			print_msg('Calling process_NonRtBsRec_forSprd API');
			End If;
			process_NonRtBsRec_forSprd
			(p_budget_version_id              => p_budget_version_id
                    	,p_source_context                => p_source_context
                    	,x_return_status                 => l_return_status
                    	);
			IF P_PA_DEBUG_MODE = 'Y' Then
                        print_msg('RetSts of process_NonRtBsRec_forSprd API ['||l_return_status||']');
			End If;
                        If l_return_status <> 'S' Then
                            x_return_status := 'E';
                        End If;
                End If;


		If p_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION') and
		   g_budget_version_type = 'ALL' and l_return_status = 'S' Then
		   IF P_PA_DEBUG_MODE = 'Y' Then
		   print_msg('Calling pre_process_Revenue_Only_Recs API');
		   End If;
		   pre_process_Revenue_Only_Recs
                    (p_budget_version_id              => p_budget_version_id
                    ,p_source_context                => p_source_context
                    ,x_return_status                 => l_return_status
                    );
			IF P_PA_DEBUG_MODE = 'Y' Then
                	print_msg('RetSts of pre_process_Revenue_Only_Recs API ['||l_return_status||']');
			End If;
                	If l_return_status <> 'S' Then
                            x_return_status := 'E';
                	End If;
		End If;

            If l_return_status = 'S' AND NVL(g_apply_progress_flag,'N') <> 'Y' Then
	    IF P_PA_DEBUG_MODE = 'Y' Then
            print_msg('Calling Check_ratebased_pltrxns API');
	    End If;
            Check_ratebased_pltrxns(
                    p_budget_version_id              => p_budget_version_id
                    ,p_source_context                => p_source_context
                    ,x_return_status                 => l_return_status
                    );
	    IF P_PA_DEBUG_MODE = 'Y' Then
            print_msg('RetSts of Check_ratebased_pltrxns API ['||l_return_status||']');
	    End If;
            If l_return_status <> 'S' Then
                            x_return_status := 'E';
                        End If;
            End If;
          End If;
        END IF; --}
	END IF; --}

        /** added this for debug purpose
        FOR i IN (select * from pa_fp_spread_calc_tmp ) LOOP
            print_msg('Ra['||i.resource_assignment_id||']TxnCur['||i.txn_currency_code||']');
            print_msg('respFlag['||i.re_spread_amts_flag||']');
                    print_msg('spCurvFlag['||i.sp_curve_change_flag||']');
                    print_msg('PlanDtFlag['||i.plan_dates_change_flag||']');
                    print_msg('SpFixDtFlag['||i.sp_fix_date_change_flag||']');
                    print_msg('mfcCstFlag['||i.mfc_cost_change_flag||']');
            print_msg('RlmIdChangFlag['||i.rlm_id_change_flag||']');

        END LOOP;
        **/

        /* Now process the resource attribute changes */
        IF (l_return_status = 'S'
             AND g_refresh_rates_flag = 'N'
                     AND g_refresh_conv_rates_flag = 'N'
                     AND g_mass_adjust_flag = 'N'
                     AND g_apply_progress_flag = 'N'
		AND NVL(g_time_phase_changed_flag,'N') = 'N'
             AND p_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION')
             AND perdRec.time_phased_code IN ('G','P')) Then --{

            FOR i IN cur_sprdRecs LOOP  --{
	    /**
            print_msg('ResMultiCurLineFlag['||i.MultiCurrLineFlag||']');
            print_msg('Looping for RA['||i.resource_assignment_id||']Txncur['||i.txn_currency_code||']');
            print_msg('oldplsd['||i.old_plan_start_date||']newplsd['||i.new_plan_start_date||']');
	    print_msg('oldpled['||i.old_plan_end_date||']');
            print_msg('newpled['||i.new_plan_end_date||']SdShrunkFlg['||i.plan_start_date_shrunk_flag||']');
	    print_msg('EDshrkFlg['||i.plan_end_date_shrunk_flag||']');
	    **/
            IF (i.MultiCurrLineFlag = 'Y' AND bvDetailsRec.Wp_Version_Flag <> 'Y')  Then
               /* process planning dates change */
               IF (NVL(i.re_spread_amts_flag,'N') = 'N'
                    AND (i.plan_end_date_shrunk_flag = 'Y' OR i.plan_start_date_shrunk_flag = 'Y')) THEN

                populate_planDates_Tabs(
                        p_resource_assignment_id        => i.resource_assignment_id
                        ,p_txn_currency_code             => i.txn_currency_code
                ,p_project_currency_code         => i.project_currency_code
                ,p_projfunc_currency_code        => i.projfunc_currency_code
                        ,p_start_dates_shrunk_flag       => i.plan_start_date_shrunk_flag
                        ,p_end_dates_shrunk_flag         => i.plan_end_date_shrunk_flag
                        ,p_plan_start_date_old           => i.old_plan_start_date
                        ,p_plan_start_date_new           => i.new_plan_start_date
                        ,p_plan_end_date_old             => i.old_plan_end_date
                        ,p_plan_end_date_new             => i.new_plan_end_date
                );

               End If;

               /* Process spread curve change */
               IF (NVL(i.sp_curve_change_flag,'N') = 'Y'
                OR NVL(i.sp_fix_date_change_flag,'N') = 'Y'
                --OR NVL(i.mfc_cost_change_flag,'N') = 'Y'
                OR NVL(i.re_spread_amts_flag,'N') = 'Y'
                OR NVL(i.rlm_id_change_flag,'N') = 'Y' ) THEN

                Populate_ResAttribTabs(
                                p_resource_assignment_id        => i.resource_assignment_id
                                ,p_txn_currency_code             => i.txn_currency_code
                                );

               END IF;

            END IF; -- end of MultiCurrLineFlag
           END LOOP; --}
           /* process tmp table for planning dates change*/
           IF g_Rspd_RaId_Tab.COUNT > 0 Then
	    IF P_PA_DEBUG_MODE = 'Y' Then
            print_msg('Calling process_planDates_change api');
	    End If;
            process_planDates_change(
                        p_budget_version_id              => p_budget_version_id
                        ,x_return_status                 => l_return_status
                        ,x_msg_data                      => x_msg_data
                );
	    IF P_PA_DEBUG_MODE = 'Y' Then
            print_msg('returnStatus of process_planDates_change api['||l_return_status||']');
	    End If;
            If l_return_status <> 'S' Then
                x_return_status := l_return_status;
            End If;
           END IF;
           /* process tmp table for other res attribute changes flag */
           IF g_RsAtrb_RaId_tab.COUNT > 0 THEN
	    IF P_PA_DEBUG_MODE = 'Y' Then
            print_msg('Calling process_ResAttribs api');
	    End if;
            process_ResAttribs(
                        p_budget_version_id              => p_budget_version_id
                        ,p_resource_assignment_id_tab    => g_RsAtrb_RaId_tab
                        ,p_txn_currency_code_tab         => g_RsAtrb_Txncur_Tab
                        ,x_return_status                 => l_return_status
                        ,x_msg_data                      => x_msg_data
                );
	    IF P_PA_DEBUG_MODE = 'Y' Then
            print_msg('returnStatus of process_ResAttribs api['||l_return_status||']');
	    End If;
                        If l_return_status <> 'S' Then
                                x_return_status := l_return_status;
                        End If;
           END IF;
        END IF;  --}

        IF ( l_return_status = 'S'
             AND g_refresh_rates_flag = 'N'
                     AND g_refresh_conv_rates_flag = 'N'
                     AND g_mass_adjust_flag = 'N'
                     AND g_apply_progress_flag = 'N'
		AND NVL(g_time_phase_changed_flag,'N') = 'N'
             AND perdRec.time_phased_code NOT IN ('G','P')
             AND p_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION') ) Then --{
		IF P_PA_DEBUG_MODE = 'Y' Then
            print_msg('Calling process_NonTimePhase_Lines API ');
		End If;
            process_NonTimePhase_Lines
                (p_budget_version_id            => p_budget_version_id
                ,p_time_phased_code             => perdRec.time_phased_code
                                ,p_apply_progress_flag          => p_apply_progress_flag
                                ,p_source_context               => p_source_context
                                ,x_return_status                => l_return_status
                                ,x_msg_data                     => x_msg_data
                                );
		IF P_PA_DEBUG_MODE = 'Y' Then
            print_msg('returnStatus of process_NonTimePhase_Lines api['||l_return_status||']');
		End If;
                        If l_return_status <> 'S' Then
                                x_return_status := l_return_status;
                        End If;
        END IF;  --}

        IF (l_return_status = 'S'
           AND g_refresh_rates_flag = 'N'
                   AND g_refresh_conv_rates_flag = 'N'
                   AND g_mass_adjust_flag = 'N'
                   AND g_apply_progress_flag = 'N'
		AND NVL(g_time_phase_changed_flag,'N') = 'N'
           AND p_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION')) Then --{
           IF IsCacheReqd(p_calling_context => 'RATES') = 'Y' Then
                    /* cache all the override rates and currency conversion attributes */
		IF P_PA_DEBUG_MODE = 'Y' Then
            		print_msg('Calling cache_rates API');
		End If;
                    cache_rates(
                        p_budget_verson_id              => p_budget_version_id
                ,p_apply_progress_flag          => p_apply_progress_flag
                        ,p_source_context               => p_source_context
                        ,x_return_status                => l_return_status
                        ,x_msg_data                     => x_msg_data
                            );
		IF P_PA_DEBUG_MODE = 'Y' Then
            		print_msg('returnSts of cache_rates api['||l_return_status||']');
		End If;
            IF l_return_status <> 'S' Then
                x_return_status := l_return_status;
            End If;
           END IF;
        END IF; --}

        /* Bug fix:5483430 */
        IF (l_return_status = 'S'
           AND g_refresh_rates_flag = 'N'
           AND g_refresh_conv_rates_flag = 'N'
           AND g_mass_adjust_flag = 'N'
           AND g_apply_progress_flag = 'N'
           AND NVL(g_time_phase_changed_flag,'N') = 'N'
           AND perdRec.time_phased_code IN ('G','P')
           AND g_source_context = 'RESOURCE_ASSIGNMENT'
           AND p_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION')) Then --{
                IF P_PA_DEBUG_MODE = 'Y' Then
                        print_msg('Calling Check_GLPA_periods_exists ');
                End If;
                Check_GLPA_periods_exists(
                        p_budget_verson_id  => p_budget_version_id
                        ,p_time_phase_code  => perdRec.time_phased_code
                        ,x_return_status    => l_return_status
                        ,x_msg_data         => x_msg_data
                        );
                IF P_PA_DEBUG_MODE = 'Y' Then
                        print_msg('returnSts of Check_GLPA_periods_exists ['||l_return_status||']');
                End If;
        END If;
        /* end of bug:5483430 */

        /* Now reset the plsql indexes. Ideally this is not requires we can use the tmp table
        * this requires lot of code changes in the calculate api. due to time constraint
                * avoiding this and populating the plsql table */
                SELECT tmp.RESOURCE_ASSIGNMENT_ID --resource_assignment_id
                         ,tmp.DELETE_BL_FLAG          --delete_budget_lines_flag
                         ,tmp.SPREAD_AMTS_FLAG      --spread_amts_flag
                         ,tmp.TXN_CURRENCY_CODE     --txn_currency_code
                         ,tmp.TXN_CURR_CODE_OVERRIDE --txn_currency_override
                         ,tmp.QUANTITY              --total_qty
                         ,tmp.SYSTEM_REFERENCE_NUM1 --addl_qty
                         ,tmp.TXN_RAW_COST          --total_raw_cost
                         ,tmp.SYSTEM_REFERENCE_NUM2 --addl_raw_cost
                         ,tmp.TXN_BURDENED_COST     --total_burdened_cost
                         ,tmp.SYSTEM_REFERENCE_NUM3 --addl_burdened_cost
                         ,tmp.TXN_REVENUE           --total_revenue
                         ,tmp.SYSTEM_REFERENCE_NUM4 --addl_revenue
                         ,tmp.COST_RATE             --raw_cost_rate
                         ,tmp.COST_RATE_OVERRIDE    --rw_cost_rate_override
                         ,tmp.BURDEN_COST_RATE      --b_cost_rate
                         ,tmp.BURDEN_COST_RATE_OVERRIDE --b_cost_rate_override
                         ,tmp.BILL_RATE             --bill_rate
                         ,tmp.BILL_RATE_OVERRIDE    --bill_rate_override
                         ,tmp.START_DATE            --line_start_date
                         ,tmp.END_DATE              --line_end_date
                         ,tmp.APPLY_PROGRESS_FLAG   --apply_progress_flag
                         ,tmp.OLD_SPREAD_CURVE_ID   --x_spread_curve_id_old_tab
                         ,tmp.NEW_SPREAD_CURVE_ID   --x_spread_curve_id_new_tab
                         ,tmp.OLD_SP_FIX_DATE       --x_sp_fixed_date_old_tab
                         ,tmp.NEW_SP_FIX_DATE       --x_sp_fixed_date_new_tab
                         ,tmp.OLD_PLAN_START_DATE   --x_plan_start_date_old_tab
                         ,tmp.NEW_PLAN_START_DATE   --x_plan_start_date_new_tab
                         ,tmp.OLD_PLAN_END_DATE     --x_plan_end_date_old_tab
                         ,tmp.NEW_PLAN_END_DATE     --x_plan_end_date_new_tab
                         ,NVL(tmp.RE_SPREAD_AMTS_FLAG,'N')   --x_re_spread_flag_tab
                         ,NVL(tmp.SP_CURVE_CHANGE_FLAG,'N')  --x_sp_curve_change_flag_tab
                         ,NVL(tmp.PLAN_DATES_CHANGE_FLAG,'N') --x_plan_dates_change_flag_tab
                         ,NVL(tmp.SP_FIX_DATE_CHANGE_FLAG,'N') --x_spfix_date_flag_tab
                         ,NVL(tmp.MFC_COST_CHANGE_FLAG,'N')   --x_mfc_cost_change_flag_tab
                         ,tmp.OLD_MFC_COST_TYPE_ID   --x_mfc_cost_type_id_old_tab
                         ,tmp.NEW_MFC_COST_TYPE_ID   --x_mfc_cost_type_id_new_tab
             ,NVL(tmp.RLM_ID_CHANGE_FLAG,'N')
             ,NVL(tmp.plan_start_date_shrunk_flag,'N')
             ,NVL(tmp.plan_end_date_shrunk_flag,'N')
             ,NVL(tmp.mfc_cost_refresh_flag,'N')
             ,NVL(tmp.system_reference_var1 ,'N') --ResourceWithMultiCurrency
             ,NVL(tmp.quantity_changed_flag,'N')
                     ,NVL(tmp.raw_cost_changed_flag,'N')
                     ,NVL(tmp.cost_rate_changed_flag,'N')
                     ,NVL(tmp.burden_cost_changed_flag,'N')
                     ,NVL(tmp.burden_rate_changed_flag,'N')
                     ,NVL(tmp.revenue_changed_flag,'N')
                     ,NVL(tmp.bill_rate_changed_flag,'N')
             ,tmp.system_reference_dat1  --newPlanStartDate for resPlannedIn Multicur
             ,tmp.system_reference_dat2  --newPlanEndDate for resPlannedIn Multicur
			,NVL(tmp.COST_RATE_G_MISS_NUM_FLAG,'N')
                        ,NVL(tmp.BURDEN_RATE_G_MISS_NUM_FLAG,'N')
                        ,NVL(tmp.BILL_RATE_G_MISS_NUM_FLAG,'N')
			,NVL(tmp.revenue_only_entered_flag,'N')
			,NVL(tmp.QUANTITY_G_MISS_NUM_FLAG,'N')
                       ,NVL(tmp.RAW_COST_G_MISS_NUM_FLAG,'N')
                       ,NVL(tmp.BURDEN_COST_G_MISS_NUM_FLAG,'N')
                      ,NVL(tmp.REVENUE_G_MISS_NUM_FLAG,'N')
		      /* bug fix:5726773 */
 	              ,NVL(tmp.NEG_QUANTITY_CHANGE_FLAG,'N') -- negQtyChangeflag
 	              ,NVL(tmp.NEG_RAWCOST_CHANGE_FLAG,'N') -- negRawCostChangeFlag
 	              ,NVL(tmp.NEG_BURDEN_CHANGE_FALG,'N') -- negBurdChangeFlag
 	              ,NVL(tmp.NEG_REVENUE_CHANGE_FLAG,'N') -- negRevChangeFlag
                BULK COLLECT INTO
                        x_resource_assignment_tab
                        ,x_delete_budget_lines_tab
                        ,x_spread_amts_flag_tab
                        ,x_txn_currency_code_tab
                        ,x_txn_currency_override_tab
                        ,x_total_qty_tab
                        ,x_addl_qty_tab
                        ,x_total_raw_cost_tab
                        ,x_addl_raw_cost_tab
                        ,x_total_burdened_cost_tab
                        ,x_addl_burdened_cost_tab
                        ,x_total_revenue_tab
                        ,x_addl_revenue_tab
                        ,x_raw_cost_rate_tab
                        ,x_rw_cost_rate_override_tab
                        ,x_b_cost_rate_tab
                        ,x_b_cost_rate_override_tab
                        ,x_bill_rate_tab
                        ,x_bill_rate_override_tab
                        ,x_line_start_date_tab
                        ,x_line_end_date_tab
                        ,x_apply_progress_flag_tab
                        ,x_spread_curve_id_old_tab
                        ,x_spread_curve_id_new_tab
                        ,x_sp_fixed_date_old_tab
                        ,x_sp_fixed_date_new_tab
                        ,x_plan_start_date_old_tab
                        ,x_plan_start_date_new_tab
                        ,x_plan_end_date_old_tab
                        ,x_plan_end_date_new_tab
                        ,x_re_spread_flag_tab
                        ,x_sp_curve_change_flag_tab
                        ,x_plan_dates_change_flag_tab
                        ,x_spfix_date_flag_tab
                        ,x_mfc_cost_change_flag_tab
                        ,x_mfc_cost_type_id_old_tab
                        ,x_mfc_cost_type_id_new_tab
            ,x_rlm_id_change_flag_tab
            ,x_plan_sdate_shrunk_flag_tab
                    ,x_plan_edate_shrunk_flag_tab
                    ,x_mfc_cost_refresh_flag_tab
            ,x_ra_in_multi_cur_flag_tab
            ,x_quantity_changed_flag_tab
                    ,x_raw_cost_changed_flag_tab
                    ,x_cost_rate_changed_flag_tab
                    ,x_burden_cost_changed_flag_tab
                    ,x_burden_rate_changed_flag_tab
                    ,x_rev_changed_flag_tab
                    ,x_bill_rate_changed_flag_tab
            ,x_multcur_plan_start_date_tab
                    ,x_multcur_plan_end_date_tab
		,x_cost_rt_miss_num_flag_tab
                ,x_burd_rt_miss_num_flag_tab
                ,x_bill_rt_miss_num_flag_tab
		,x_rev_only_entry_flag_tab
		,x_Qty_miss_num_flag_tab
                ,x_Rw_miss_num_flag_tab
                ,x_Br_miss_num_flag_tab
                ,x_Rv_miss_num_flag_tab
		/* bug fix:5726773 */
 	        ,x_neg_Qty_Changflag_tab
 	        ,x_neg_Raw_Changflag_tab
 	        ,x_neg_Burd_Changflag_tab
 	        ,x_neg_rev_Changflag_tab
                FROM PA_FP_SPREAD_CALC_TMP tmp
                WHERE tmp.budget_version_id = p_budget_version_id;

    x_return_status := l_return_status;

        /* reset the error stack */
    If p_pa_debug_mode = 'Y' Then
    	print_msg('RetSts of the populate_spreadTmp_OvrRates ['||x_return_status||']');
        pa_debug.reset_err_stack;
    End If;

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                x_msg_data := sqlcode||sqlerrm;
                print_msg('Failed in populate_spreadTmp_OvrRates API'||x_msg_data);
         fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'populate_spreadCalc_Tmp ');
        If p_pa_debug_mode = 'Y' Then
                    pa_debug.reset_err_stack;
        End If;
                RAISE;

END  populate_spreadCalc_Tmp ;

/* This API caches the override rates,currency conversion attributes, DFFs and other attributes from budget lines to
 * tmp2 table. later after spread, for that matching RA+TXN+START DATE periodic lines the attributes will be stamped back
 * This is required in order to avoid loosing manual periodic overrides during resource attribute changes
 */
PROCEDURE cache_rates(
        p_budget_verson_id              IN  Number
        ,p_apply_progress_flag          IN Varchar2
                ,p_source_context                IN  pa_fp_res_assignments_tmp.source_context%TYPE
        ,x_return_status                 OUT NOCOPY varchar2
        ,x_msg_data                      OUT NOCOPY varchar2
             ) IS

    l_rowcount    Number;

    CURSOR cur_ovr_rts IS
    SELECT tmp.resource_assignment_id
        ,tmp.txn_currency_code
        ,tmp.cost_rate_override
        ,tmp.burden_cost_rate_override
        ,tmp.bill_rate_override
        ,tmp.budget_version_type
        ,tmp.quantity_changed_flag
        ,tmp.cost_rate_changed_flag
        ,tmp.burden_rate_changed_flag
        ,tmp.bill_rate_changed_flag
        ,tmp.mfc_cost_change_flag
    FROM pa_fp_spread_calc_tmp tmp
    WHERE tmp.budget_version_id = p_budget_verson_id
    AND   nvl(tmp.rlm_id_change_flag,'N') <> 'Y'
    AND   (tmp.cost_rate_override is NOT NULL
        OR tmp.burden_cost_rate_override is NOT NULL
        OR tmp.bill_rate_override is NOT NULL
        OR tmp.mfc_cost_change_flag = 'Y' );
BEGIN
    /* Initialize the error stack */
    If p_pa_debug_mode = 'Y' Then
        pa_debug.init_err_stack('PA_FP_CALC_UTILS.cache_rates');
    End If;
    x_return_status := 'S';
    x_msg_data := NULL;

    INSERT INTO pa_fp_spread_calc_tmp1
            (RESOURCE_ASSIGNMENT_ID --resource_assignment_id
                         ,BUDGET_VERSION_ID     --budget_version_id
             ,BUDGET_VERSION_TYPE
             ,BUDGET_LINE_ID
                         ,TXN_CURRENCY_CODE     --txn_currency_code
                         ,TXN_CURR_CODE_OVERRIDE --txn_currency_override
                         ,QUANTITY              --total_qty
                         ,TXN_RAW_COST          --total_raw_cost
                         ,TXN_BURDENED_COST     --total_burdened_cost
                         ,TXN_REVENUE           --total_revenue
                         ,COST_RATE             --raw_cost_rate
                         ,COST_RATE_OVERRIDE    --rw_cost_rate_override
                         ,BURDEN_COST_RATE      --b_cost_rate
                         ,BURDEN_COST_RATE_OVERRIDE --b_cost_rate_override
                         ,BILL_RATE             --bill_rate
                         ,BILL_RATE_OVERRIDE    --bill_rate_override
                         ,START_DATE            --line_start_date
                         ,END_DATE              --line_end_date
             ,PERIOD_NAME
            ,PROJECT_CURRENCY_CODE
            ,PROJFUNC_CURRENCY_CODE
            ,PROJECT_COST_RATE_TYPE
            ,PROJECT_COST_EXCHANGE_RATE
            ,PROJECT_COST_RATE_DATE_TYPE
            ,PROJECT_COST_RATE_DATE
            ,PROJECT_REV_RATE_TYPE
            ,PROJECT_REV_EXCHANGE_RATE
            ,PROJECT_REV_RATE_DATE_TYPE
            ,PROJECT_REV_RATE_DATE
            ,PROJFUNC_COST_RATE_TYPE
            ,PROJFUNC_COST_EXCHANGE_RATE
            ,PROJFUNC_COST_RATE_DATE_TYPE
            ,PROJFUNC_COST_RATE_DATE
            ,PROJFUNC_REV_RATE_TYPE
            ,PROJFUNC_REV_EXCHANGE_RATE
            ,PROJFUNC_REV_RATE_DATE_TYPE
            ,PROJFUNC_REV_RATE_DATE
            ,CHANGE_REASON_CODE
            ,DESCRIPTION
            ,ATTRIBUTE_CATEGORY
            ,ATTRIBUTE1
            ,ATTRIBUTE2
            ,ATTRIBUTE3
            ,ATTRIBUTE4
            ,ATTRIBUTE5
            ,ATTRIBUTE6
            ,ATTRIBUTE7
            ,ATTRIBUTE8
            ,ATTRIBUTE9
            ,ATTRIBUTE10
            ,ATTRIBUTE11
            ,ATTRIBUTE12
            ,ATTRIBUTE13
            ,ATTRIBUTE14
            ,ATTRIBUTE15
            ,RAW_COST_SOURCE
            ,BURDENED_COST_SOURCE
            ,QUANTITY_SOURCE
            ,REVENUE_SOURCE
            ,PM_PRODUCT_CODE
            ,PM_BUDGET_LINE_REFERENCE
            ,CODE_COMBINATION_ID
            ,CCID_GEN_STATUS_CODE
            ,CCID_GEN_REJ_MESSAGE
            ,BORROWED_REVENUE
            ,TP_REVENUE_IN
            ,TP_REVENUE_OUT
            ,REVENUE_ADJ
            ,LENT_RESOURCE_COST
            ,TP_COST_IN
            ,TP_COST_OUT
            ,COST_ADJ
            ,UNASSIGNED_TIME_COST
            ,UTILIZATION_PERCENT
            ,UTILIZATION_HOURS
            ,UTILIZATION_ADJ
            ,CAPACITY
            ,HEAD_COUNT
            ,HEAD_COUNT_ADJ
            ,BUCKETING_PERIOD_CODE
            ,TXN_DISCOUNT_PERCENTAGE
            ,TRANSFER_PRICE_RATE
            ,BL_CREATED_BY
            ,BL_CREATION_DATE
            ,mfc_cost_change_flag
            )
        SELECT /*+ INDEX(BL PA_BUDGET_LINES_U1) */
            bl.RESOURCE_ASSIGNMENT_ID --resource_assignment_id
                         ,bl.BUDGET_VERSION_ID     --budget_version_id
             ,tmp.BUDGET_VERSION_TYPE
             ,bl.BUDGET_LINE_ID
                         ,bl.TXN_CURRENCY_CODE     --txn_currency_code
                         ,tmp.TXN_CURR_CODE_OVERRIDE --txn_currency_override
                         ,bl.QUANTITY              --total_qty
                         ,bl.TXN_RAW_COST          --total_raw_cost
                         ,bl.TXN_BURDENED_COST     --total_burdened_cost
                         ,bl.TXN_REVENUE           --total_revenue
                         ,bl.TXN_STANDARD_COST_RATE             --raw_cost_rate
                         ,bl.TXN_COST_RATE_OVERRIDE    --rw_cost_rate_override
                         ,bl.BURDEN_COST_RATE      --b_cost_rate
                         ,bl.BURDEN_COST_RATE_OVERRIDE --b_cost_rate_override
                         ,bl.TXN_STANDARD_BILL_RATE             --bill_rate
                         ,bl.TXN_BILL_RATE_OVERRIDE    --bill_rate_override
                         ,bl.START_DATE            --line_start_date
                         ,bl.END_DATE              --line_end_date
            ,bl.PERIOD_NAME
            ,bl.PROJECT_CURRENCY_CODE
            ,bl.PROJFUNC_CURRENCY_CODE
            ,bl.PROJECT_COST_RATE_TYPE
            ,bl.PROJECT_COST_EXCHANGE_RATE
            ,bl.PROJECT_COST_RATE_DATE_TYPE
            ,bl.PROJECT_COST_RATE_DATE
            ,bl.PROJECT_REV_RATE_TYPE
            ,bl.PROJECT_REV_EXCHANGE_RATE
            ,bl.PROJECT_REV_RATE_DATE_TYPE
            ,bl.PROJECT_REV_RATE_DATE
            ,bl.PROJFUNC_COST_RATE_TYPE
            ,bl.PROJFUNC_COST_EXCHANGE_RATE
            ,bl.PROJFUNC_COST_RATE_DATE_TYPE
            ,bl.PROJFUNC_COST_RATE_DATE
            ,bl.PROJFUNC_REV_RATE_TYPE
            ,bl.PROJFUNC_REV_EXCHANGE_RATE
            ,bl.PROJFUNC_REV_RATE_DATE_TYPE
            ,bl.PROJFUNC_REV_RATE_DATE
            ,bl.CHANGE_REASON_CODE
            ,bl.DESCRIPTION
            ,bl.ATTRIBUTE_CATEGORY
            ,bl.ATTRIBUTE1
            ,bl.ATTRIBUTE2
            ,bl.ATTRIBUTE3
            ,bl.ATTRIBUTE4
            ,bl.ATTRIBUTE5
            ,bl.ATTRIBUTE6
            ,bl.ATTRIBUTE7
            ,bl.ATTRIBUTE8
            ,bl.ATTRIBUTE9
            ,bl.ATTRIBUTE10
            ,bl.ATTRIBUTE11
            ,bl.ATTRIBUTE12
            ,bl.ATTRIBUTE13
            ,bl.ATTRIBUTE14
            ,bl.ATTRIBUTE15
            ,bl.RAW_COST_SOURCE
            ,bl.BURDENED_COST_SOURCE
            ,bl.QUANTITY_SOURCE
            ,bl.REVENUE_SOURCE
            ,bl.PM_PRODUCT_CODE
            ,bl.PM_BUDGET_LINE_REFERENCE
            ,bl.CODE_COMBINATION_ID
            ,bl.CCID_GEN_STATUS_CODE
            ,bl.CCID_GEN_REJ_MESSAGE
            ,bl.BORROWED_REVENUE
            ,bl.TP_REVENUE_IN
            ,bl.TP_REVENUE_OUT
            ,bl.REVENUE_ADJ
            ,bl.LENT_RESOURCE_COST
            ,bl.TP_COST_IN
            ,bl.TP_COST_OUT
            ,bl.COST_ADJ
            ,bl.UNASSIGNED_TIME_COST
            ,bl.UTILIZATION_PERCENT
            ,bl.UTILIZATION_HOURS
            ,bl.UTILIZATION_ADJ
            ,bl.CAPACITY
            ,bl.HEAD_COUNT
            ,bl.HEAD_COUNT_ADJ
            ,bl.BUCKETING_PERIOD_CODE
            ,bl.TXN_DISCOUNT_PERCENTAGE
            ,bl.TRANSFER_PRICE_RATE
            ,bl.CREATED_BY
            ,bl.CREATION_DATE
            ,tmp.mfc_cost_change_flag
        FROM PA_BUDGET_LINES bl
            ,PA_FP_SPREAD_CALC_TMP tmp
        WHERE bl.budget_version_id = p_budget_verson_id
        AND   bl.budget_version_id = tmp.budget_version_id
        AND   bl.resource_assignment_id = tmp.resource_assignment_id
        AND   bl.txn_currency_code = tmp.txn_currency_code
        AND   ((tmp.ETC_START_DATE is NOT NULL
            AND bl.end_date >= tmp.ETC_START_DATE)
            OR
            tmp.ETC_START_DATE is NULL
              )
        AND  NVL(tmp.RLM_ID_CHANGE_FLAG,'N') <> 'Y'
        AND   (NVL(tmp.SP_CURVE_CHANGE_FLAG,'N') = 'Y'
            OR NVL(tmp.SP_FIX_DATE_CHANGE_FLAG,'N') = 'Y'
            OR NVL(tmp.PLAN_DATES_CHANGE_FLAG,'N') = 'Y'
            OR NVL(tmp.MFC_COST_CHANGE_FLAG,'N') = 'Y'
            OR NVL(tmp.RE_SPREAD_AMTS_FLAG,'N') = 'Y'
              );
    l_rowcount := sql%rowcount;
    IF P_PA_DEBUG_MODE = 'Y' Then
    print_msg('Number of rows cached['||l_rowcount||']');
    End If;

    /* Now update the override rates If any passed from the Page */
    FOR i IN cur_ovr_rts LOOP
	/*
        print_msg('mfcCostFlag['||i.mfc_cost_change_flag||'Ver['||i.budget_version_type||']');
        print_msg('costRtChFlag['||i.cost_rate_changed_flag||']Rt['||i.cost_rate_override||']');
        print_msg('burRtOvr['||i.burden_cost_rate_override||']');
	*/
        UPDATE /*+ INDEX(TMP1 PA_FP_SPREAD_CALC_TMP1_N1) */  pa_fp_spread_calc_tmp1 tmp1
        SET tmp1.cost_rate_override = decode(i.budget_version_type,'REVENUE',tmp1.cost_rate_override
                        ,decode(nvl(i.cost_rate_changed_flag,'N')
                          ,'Y',decode(i.mfc_cost_change_flag,'Y'
                           ,decode(nvl(i.cost_rate_override,0),0,NULL,i.cost_rate_override),i.cost_rate_override)
                          ,'N',decode(i.mfc_cost_change_flag,'Y'
                               ,decode(nvl(i.cost_rate_override,0),0,NULL,i.cost_rate_override),tmp1.cost_rate_override)))
           ,tmp1.burden_cost_rate_override = decode(i.budget_version_type,'REVENUE',tmp1.burden_cost_rate_override
                        ,decode(nvl(i.burden_rate_changed_flag,'N')
                         ,'Y',decode(i.mfc_cost_change_flag,'Y'
                                                   ,decode(nvl(i.burden_cost_rate_override,0),0,NULL,i.burden_cost_rate_override),i.burden_cost_rate_override)
                         ,'N',decode(i.mfc_cost_change_flag,'Y'
                                                       ,decode(nvl(i.burden_cost_rate_override,0),0,NULL,i.burden_cost_rate_override),tmp1.burden_cost_rate_override)))
           ,tmp1.bill_rate_override = decode(i.budget_version_type,'COST',tmp1.bill_rate_override
                        ,decode(nvl(i.bill_rate_changed_flag,'N')
                                                  ,'Y',decode(i.mfc_cost_change_flag,'Y'
                                                   ,decode(nvl(i.bill_rate_override,0),0,NULL,i.bill_rate_override),i.bill_rate_override)
                                                  ,'N',decode(i.mfc_cost_change_flag,'Y'
                                                       ,decode(nvl(i.bill_rate_override,0),0,NULL,i.bill_rate_override),tmp1.bill_rate_override)))
        WHERE tmp1.budget_version_id = p_budget_verson_id
        AND  tmp1.resource_assignment_id = i.resource_assignment_id
        AND  tmp1.txn_currency_code = i.txn_currency_code ;

        l_rowcount := sql%rowcount;
	IF P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Number of cached rows updated['||l_rowcount||']');
	End If;

    END LOOP;

    /* reset the error stack */
    If p_pa_debug_mode = 'Y' Then
        pa_debug.reset_err_stack;
    End If;

EXCEPTION
    WHEN OTHERS THEN
                x_return_status := 'U';
                x_msg_data := sqlcode||sqlerrm;
        print_msg('Failed in cache_rates API'||x_msg_data);
         fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'cache_rates');
        If p_pa_debug_mode = 'Y' Then
            pa_debug.reset_err_stack;
        End If;
                RAISE;

END cache_rates;

/* This API copies the override rates, currency conversion attributes, DFF attributes from cache to rollup tmp lines
 * so the after spread, the old values are retained
 */
PROCEDURE copy_BlAttributes(
                p_budget_verson_id               IN  Number
                ,p_source_context                IN  Varchar2
                ,p_calling_module                IN  Varchar2
                ,p_apply_progress_flag           IN Varchar2
                ,x_return_status                 OUT NOCOPY varchar2
                ,x_msg_data                      OUT NOCOPY varchar2
                 ) IS

    CURSOR fptmpDetails IS
                /* Bug Fix 4332086
                Whenever currency is overridden along with a change in quantity in the workplan flow
                in Update Task Details page, the following piece of code gets executed.

                This code caches several attributes from pa_budget_lines table and will use them in the
                later part of the flow, thus causing the above bug. When ever currency code is overwritten
                we need to use the new currency's conversion attributes, but where as this code will use
                old currency's conversion attributes.

                As a part of the fix the following cursor is rewritten to cache old attrs only if the
                currency code is not overwritten

    SELECT tmp.rowid
              ,tmp.resource_assignment_id
              ,tmp.txn_currency_code
              ,tmp.start_date
              ,tmp.end_date
              ,tmp.period_name
              ,decode(cache.Budget_version_type ,'ALL'
            , decode(cache.txn_curr_code_override,NULL
                ,decode(NVL(cache.mfc_cost_change_flag,'N'),'Y'
                ,cache.cost_rate_override,NVL(cache.cost_rate_override,tmp.rw_cost_rate_override))
                    ,cache.cost_rate_override)
                        ,'COST',decode(cache.txn_curr_code_override,NULL
                            ,decode(NVL(cache.mfc_cost_change_flag,'N'),'Y'
                                 ,cache.cost_rate_override,NVL(cache.cost_rate_override,tmp.rw_cost_rate_override))
                                      ,cache.cost_rate_override)
                 ,tmp.rw_cost_rate_override) cost_rate_override
              ,decode(cache.Budget_version_type ,'ALL', decode(cache.txn_curr_code_override,NULL
                       ,decode(NVL(cache.mfc_cost_change_flag,'N'),'Y'
               ,cache.burden_cost_rate_override,NVL(cache.burden_cost_rate_override,tmp.burden_cost_rate_override))
                    ,cache.burden_cost_rate_override)
                       ,'COST',decode(cache.txn_curr_code_override,NULL
                           ,decode(NVL(cache.mfc_cost_change_flag,'N'),'Y'
                               ,cache.burden_cost_rate_override,NVL(cache.burden_cost_rate_override,tmp.burden_cost_rate_override))
                                  ,cache.burden_cost_rate_override)
            ,tmp.burden_cost_rate_override) burden_rate_override
              ,decode(cache.budget_version_type ,'ALL',decode(cache.txn_curr_code_override,NULL
                        ,decode(NVL(cache.mfc_cost_change_flag,'N'),'Y'
                ,cache.bill_rate_override,NVL(cache.bill_rate_override,tmp.bill_rate_override))
                    ,cache.bill_rate_override)
                        ,'REVENUE',decode(cache.txn_curr_code_override,NULL
                           ,decode(NVL(cache.mfc_cost_change_flag,'N'),'Y'
                              ,cache.bill_rate_override,NVL(cache.bill_rate_override,tmp.bill_rate_override))
                                  ,cache.bill_rate_override)
                             ,tmp.bill_rate_override) bill_rate_override
              ,decode(cache.txn_currency_code,tmp.txn_currency_code,cache.PROJECT_COST_RATE_TYPE
                ,tmp.PROJECT_COST_RATE_TYPE) PROJECT_COST_RATE_TYPE
              ,decode(cache.txn_currency_code,tmp.txn_currency_code
                ,cache.PROJECT_COST_EXCHANGE_RATE,tmp.PROJECT_COST_EXCHANGE_RATE) PROJECT_COST_EXCHANGE_RATE
              ,decode(cache.txn_currency_code,tmp.txn_currency_code
                ,cache.PROJECT_COST_RATE_DATE_TYPE,tmp.PROJECT_COST_RATE_DATE_TYPE) PROJECT_COST_RATE_DATE_TYPE
              ,decode(cache.txn_currency_code,tmp.txn_currency_code
                ,cache.PROJECT_COST_RATE_DATE,tmp.PROJECT_COST_RATE_DATE) PROJECT_COST_RATE_DATE
              ,decode(cache.txn_currency_code,tmp.txn_currency_code
                ,cache.PROJECT_REV_RATE_TYPE,tmp.PROJECT_REV_RATE_TYPE) PROJECT_REV_RATE_TYPE
              ,decode(cache.txn_currency_code,tmp.txn_currency_code
                ,cache.PROJECT_REV_EXCHANGE_RATE,tmp.PROJECT_REV_EXCHANGE_RATE) PROJECT_REV_EXCHANGE_RATE
              ,decode(cache.txn_currency_code,tmp.txn_currency_code
                ,cache.PROJECT_REV_RATE_DATE_TYPE,tmp.PROJECT_REV_RATE_DATE_TYPE) PROJECT_REV_RATE_DATE_TYPE
              ,decode(cache.txn_currency_code,tmp.txn_currency_code
                ,cache.PROJECT_REV_RATE_DATE,tmp.PROJECT_REV_RATE_DATE) PROJECT_REV_RATE_DATE
              ,decode(cache.txn_currency_code,tmp.txn_currency_code
                ,cache.PROJFUNC_COST_RATE_TYPE,tmp.PROJFUNC_COST_RATE_TYPE) PROJFUNC_COST_RATE_TYPE
              ,decode(cache.txn_currency_code,tmp.txn_currency_code
                ,cache.PROJFUNC_COST_EXCHANGE_RATE,tmp.PROJFUNC_COST_EXCHANGE_RATE) PROJFUNC_COST_EXCHANGE_RATE
              ,decode(cache.txn_currency_code,tmp.txn_currency_code
                ,cache.PROJFUNC_COST_RATE_DATE_TYPE,tmp.PROJFUNC_COST_RATE_DATE_TYPE) PROJFUNC_COST_RATE_DATE_TYPE
              ,decode(cache.txn_currency_code,tmp.txn_currency_code
                ,cache.PROJFUNC_COST_RATE_DATE,tmp.PROJFUNC_COST_RATE_DATE) PROJFUNC_COST_RATE_DATE
              ,decode(cache.txn_currency_code,tmp.txn_currency_code
                ,cache.PROJFUNC_REV_RATE_TYPE,tmp.PROJFUNC_REV_RATE_TYPE) PROJFUNC_REV_RATE_TYPE
              ,decode(cache.txn_currency_code,tmp.txn_currency_code
                ,cache.PROJFUNC_REV_EXCHANGE_RATE,tmp.PROJFUNC_REV_EXCHANGE_RATE) PROJFUNC_REV_EXCHANGE_RATE
              ,decode(cache.txn_currency_code,tmp.txn_currency_code
                ,cache.PROJFUNC_REV_RATE_DATE_TYPE,tmp.PROJFUNC_REV_RATE_DATE_TYPE) PROJFUNC_REV_RATE_DATE_TYPE
              ,decode(cache.txn_currency_code,tmp.txn_currency_code
                ,cache.PROJFUNC_REV_RATE_DATE,tmp.PROJFUNC_REV_RATE_DATE) PROJFUNC_REV_RATE_DATE
              */
                SELECT tmp.rowid
              ,tmp.resource_assignment_id
              ,tmp.txn_currency_code
              ,tmp.start_date
              ,tmp.end_date
              ,tmp.period_name
              ,DECODE(cache.txn_curr_code_override,NULL,
               decode(cache.Budget_version_type ,'ALL'
                ,decode(cache.txn_curr_code_override,NULL
                ,decode(NVL(cache.mfc_cost_change_flag,'N'),'Y'
                ,cache.cost_rate_override,NVL(cache.cost_rate_override,tmp.rw_cost_rate_override))
                    ,cache.cost_rate_override)
                        ,'COST',decode(cache.txn_curr_code_override,NULL
                            ,decode(NVL(cache.mfc_cost_change_flag,'N'),'Y'
                                 ,cache.cost_rate_override,NVL(cache.cost_rate_override,tmp.rw_cost_rate_override))
                                      ,cache.cost_rate_override)
                 ,tmp.rw_cost_rate_override),NULL) cost_rate_override
             ,DECODE(cache.txn_curr_code_override,NULL,
               decode(cache.Budget_version_type ,'ALL', decode(cache.txn_curr_code_override,NULL
                       ,decode(NVL(cache.mfc_cost_change_flag,'N'),'Y'
               ,cache.burden_cost_rate_override,NVL(cache.burden_cost_rate_override,tmp.burden_cost_rate_override))
                    ,cache.burden_cost_rate_override)
                       ,'COST',decode(cache.txn_curr_code_override,NULL
                           ,decode(NVL(cache.mfc_cost_change_flag,'N'),'Y'
                               ,cache.burden_cost_rate_override,NVL(cache.burden_cost_rate_override,tmp.burden_cost_rate_override))
                                  ,cache.burden_cost_rate_override)
            ,tmp.burden_cost_rate_override),NULL) burden_rate_override
            ,DECODE(cache.txn_curr_code_override,NULL,
             decode(cache.budget_version_type ,'ALL',decode(cache.txn_curr_code_override,NULL
                        ,decode(NVL(cache.mfc_cost_change_flag,'N'),'Y'
                ,cache.bill_rate_override,NVL(cache.bill_rate_override,tmp.bill_rate_override))
                    ,cache.bill_rate_override)
                        ,'REVENUE',decode(cache.txn_curr_code_override,NULL
                           ,decode(NVL(cache.mfc_cost_change_flag,'N'),'Y'
                              ,cache.bill_rate_override,NVL(cache.bill_rate_override,tmp.bill_rate_override))
                                  ,cache.bill_rate_override)
                             ,tmp.bill_rate_override),NULL) bill_rate_override
               --Bug 4224464. Changed the decode below to handle the G_MISS_XXX values for curreny conversion attributes.
            ,DECODE(cache.txn_curr_code_override,
                                         NULL,decode(cache.txn_currency_code,
                                                        tmp.txn_currency_code,decode(cache.PROJECT_COST_RATE_TYPE,
                                                                                        NULL,tmp.PROJECT_COST_RATE_TYPE,
                                                                                        FND_API.G_MISS_CHAR, NULL,
                                                                                        cache.PROJECT_COST_RATE_TYPE),
                                                        tmp.PROJECT_COST_RATE_TYPE),
                                         NULL) PROJECT_COST_RATE_TYPE
            ,DECODE(cache.txn_curr_code_override,
                                         NULL,decode(cache.txn_currency_code,
                                                        tmp.txn_currency_code,decode(cache.PROJECT_COST_EXCHANGE_RATE,
                                                                                        NULL,tmp.PROJECT_COST_EXCHANGE_RATE,
                                                                                        FND_API.G_MISS_NUM, NULL,
                                                                                        cache.PROJECT_COST_EXCHANGE_RATE),
                                                        tmp.PROJECT_COST_EXCHANGE_RATE),
                                         NULL) PROJECT_COST_EXCHANGE_RATE
            ,DECODE(cache.txn_curr_code_override,
                                         NULL,decode(cache.txn_currency_code,
                                                        tmp.txn_currency_code,decode(cache.PROJECT_COST_RATE_DATE_TYPE,
                                                                                        NULL,tmp.PROJECT_COST_RATE_DATE_TYPE,
                                                                                        FND_API.G_MISS_CHAR, NULL,
                                                                                        cache.PROJECT_COST_RATE_DATE_TYPE),
                                                        tmp.PROJECT_COST_RATE_DATE_TYPE),
                                         NULL) PROJECT_COST_RATE_DATE_TYPE
            ,DECODE(cache.txn_curr_code_override,
                                         NULL,decode(cache.txn_currency_code,
                                                        tmp.txn_currency_code,decode(cache.PROJECT_COST_RATE_DATE,
                                                                                        NULL,tmp.PROJECT_COST_RATE_DATE,
                                                                                        FND_API.G_MISS_DATE, NULL,
                                                                                        cache.PROJECT_COST_RATE_DATE),
                                                        tmp.PROJECT_COST_RATE_DATE),
                                         NULL) PROJECT_COST_RATE_DATE
            ,DECODE(cache.txn_curr_code_override,
                                         NULL,decode(cache.txn_currency_code,
                                                        tmp.txn_currency_code,decode(cache.PROJECT_REV_RATE_TYPE,
                                                                                        NULL,tmp.PROJECT_REV_RATE_TYPE,
                                                                                        FND_API.G_MISS_CHAR, NULL,
                                                                                        cache.PROJECT_REV_RATE_TYPE),
                                                        tmp.PROJECT_REV_RATE_TYPE),
                                         NULL) PROJECT_REV_RATE_TYPE
            ,DECODE(cache.txn_curr_code_override,
                                         NULL,decode(cache.txn_currency_code,
                                                        tmp.txn_currency_code,decode(cache.PROJECT_REV_EXCHANGE_RATE,
                                                                                        NULL,tmp.PROJECT_REV_EXCHANGE_RATE,
                                                                                        FND_API.G_MISS_NUM, NULL,
                                                                                        cache.PROJECT_REV_EXCHANGE_RATE),
                                                        tmp.PROJECT_REV_EXCHANGE_RATE),
                                         NULL) PROJECT_REV_EXCHANGE_RATE
            ,DECODE(cache.txn_curr_code_override,
                                         NULL,decode(cache.txn_currency_code,
                                                        tmp.txn_currency_code,decode(cache.PROJECT_REV_RATE_DATE_TYPE,
                                                                                        NULL,tmp.PROJECT_REV_RATE_DATE_TYPE,
                                                                                        FND_API.G_MISS_CHAR, NULL,
                                                                                        cache.PROJECT_REV_RATE_DATE_TYPE),
                                                        tmp.PROJECT_REV_RATE_DATE_TYPE),
                                         NULL) PROJECT_REV_RATE_DATE_TYPE
            ,DECODE(cache.txn_curr_code_override,
                                         NULL,decode(cache.txn_currency_code,
                                                        tmp.txn_currency_code,decode(cache.PROJECT_REV_RATE_DATE,
                                                                                        NULL,tmp.PROJECT_REV_RATE_DATE,
                                                                                        FND_API.G_MISS_DATE, NULL,
                                                                                        cache.PROJECT_REV_RATE_DATE),
                                                        tmp.PROJECT_REV_RATE_DATE),
                                         NULL) PROJECT_REV_RATE_DATE
            ,DECODE(cache.txn_curr_code_override,
                                         NULL,decode(cache.txn_currency_code,
                                                        tmp.txn_currency_code,decode(cache.PROJFUNC_COST_RATE_TYPE,
                                                                                        NULL,tmp.PROJFUNC_COST_RATE_TYPE,
                                                                                        FND_API.G_MISS_CHAR, NULL,
                                                                                        cache.PROJFUNC_COST_RATE_TYPE),
                                                        tmp.PROJFUNC_COST_RATE_TYPE),
                                         NULL) PROJFUNC_COST_RATE_TYPE
            ,DECODE(cache.txn_curr_code_override,
                                         NULL,decode(cache.txn_currency_code,
                                                        tmp.txn_currency_code,decode(cache.PROJFUNC_COST_EXCHANGE_RATE,
                                                                                        NULL,tmp.PROJFUNC_COST_EXCHANGE_RATE,
                                                                                        FND_API.G_MISS_NUM, NULL,
                                                                                        cache.PROJFUNC_COST_EXCHANGE_RATE),
                                                        tmp.PROJFUNC_COST_EXCHANGE_RATE),
                                         NULL) PROJFUNC_COST_EXCHANGE_RATE
            ,DECODE(cache.txn_curr_code_override,
                                         NULL,decode(cache.txn_currency_code,
                                                        tmp.txn_currency_code,decode(cache.PROJFUNC_COST_RATE_DATE_TYPE,
                                                                                        NULL,tmp.PROJFUNC_COST_RATE_DATE_TYPE,
                                                                                        FND_API.G_MISS_CHAR, NULL,
                                                                                        cache.PROJFUNC_COST_RATE_DATE_TYPE),
                                                        tmp.PROJFUNC_COST_RATE_DATE_TYPE),
                                         NULL) PROJFUNC_COST_RATE_DATE_TYPE
            ,DECODE(cache.txn_curr_code_override,
                                         NULL,decode(cache.txn_currency_code,
                                                        tmp.txn_currency_code,decode(cache.PROJFUNC_COST_RATE_DATE,
                                                                                        NULL,tmp.PROJFUNC_COST_RATE_DATE,
                                                                                        FND_API.G_MISS_DATE, NULL,
                                                                                        cache.PROJFUNC_COST_RATE_DATE),
                                                        tmp.PROJFUNC_COST_RATE_DATE),
                                         NULL) PROJFUNC_COST_RATE_DATE
            ,DECODE(cache.txn_curr_code_override,
                                         NULL,decode(cache.txn_currency_code,
                                                        tmp.txn_currency_code,decode(cache.PROJFUNC_REV_RATE_TYPE,
                                                                                        NULL,tmp.PROJFUNC_REV_RATE_TYPE,
                                                                                        FND_API.G_MISS_CHAR, NULL,
                                                                                        cache.PROJFUNC_REV_RATE_TYPE),
                                                        tmp.PROJFUNC_REV_RATE_TYPE),
                                         NULL) PROJFUNC_REV_RATE_TYPE
            ,DECODE(cache.txn_curr_code_override,
                                         NULL,decode(cache.txn_currency_code,
                                                        tmp.txn_currency_code,decode(cache.PROJFUNC_REV_EXCHANGE_RATE,
                                                                                        NULL,tmp.PROJFUNC_REV_EXCHANGE_RATE,
                                                                                        FND_API.G_MISS_NUM, NULL,
                                                                                        cache.PROJFUNC_REV_EXCHANGE_RATE),
                                                        tmp.PROJFUNC_REV_EXCHANGE_RATE),
                                         NULL) PROJFUNC_REV_EXCHANGE_RATE
            ,DECODE(cache.txn_curr_code_override,
                                         NULL,decode(cache.txn_currency_code,
                                                        tmp.txn_currency_code,decode(cache.PROJFUNC_REV_RATE_DATE_TYPE,
                                                                                        NULL,tmp.PROJFUNC_REV_RATE_DATE_TYPE,
                                                                                        FND_API.G_MISS_CHAR, NULL,
                                                                                        cache.PROJFUNC_REV_RATE_DATE_TYPE),
                                                        tmp.PROJFUNC_REV_RATE_DATE_TYPE),
                                         NULL) PROJFUNC_REV_RATE_DATE_TYPE
            ,DECODE(cache.txn_curr_code_override,
                                         NULL,decode(cache.txn_currency_code,
                                                        tmp.txn_currency_code,decode(cache.PROJFUNC_REV_RATE_DATE,
                                                                                        NULL,tmp.PROJFUNC_REV_RATE_DATE,
                                                                                        FND_API.G_MISS_DATE, NULL,
                                                                                        cache.PROJFUNC_REV_RATE_DATE),
                                                        tmp.PROJFUNC_REV_RATE_DATE),
                                         NULL) PROJFUNC_REV_RATE_DATE
        FROM  pa_fp_rollup_tmp tmp
              ,pa_fp_spread_calc_tmp1 cache
        WHERE  tmp.budget_version_id = p_budget_verson_id
        AND    tmp.budget_version_id = cache.budget_version_id
        AND    tmp.resource_assignment_id = cache.resource_assignment_id
        AND    tmp.txn_currency_code = cache.txn_currency_code
        AND    tmp.start_date = cache.start_date
        ;

    /* This cursor picks budget line attributes which needs to be retained after spread
         * though the currency code changes */
        CURSOR blAttribDetails IS
        SELECT tmp.rowid
              /*Bug 4224464. Changed the decode below for dff's, change reason code,PM_PRODUCT_CODE,PM_BUDGET_LINE_REFERENCE
                and description columns to handle the the G_MISS_XXX values for these columns*/
         , decode(cache.CHANGE_REASON_CODE   ,null, bl.change_reason_code, FND_API.G_MISS_CHAR, null, cache.CHANGE_REASON_CODE)
         , decode(cache.DESCRIPTION          ,null, bl.DESCRIPTION, FND_API.G_MISS_CHAR, null, cache.DESCRIPTION)
         , decode(cache.ATTRIBUTE_CATEGORY   ,null, bl.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE_CATEGORY)
         , decode(cache.ATTRIBUTE1           ,null, bl.ATTRIBUTE1,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE1)
         , decode(cache.ATTRIBUTE2           ,null, bl.ATTRIBUTE2,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE2)
         , decode(cache.ATTRIBUTE3           ,null, bl.ATTRIBUTE3,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE3)
         , decode(cache.ATTRIBUTE4           ,null, bl.ATTRIBUTE4,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE4)
         , decode(cache.ATTRIBUTE5           ,null, bl.ATTRIBUTE5,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE5)
         , decode(cache.ATTRIBUTE6           ,null, bl.ATTRIBUTE6,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE6)
         , decode(cache.ATTRIBUTE7           ,null, bl.ATTRIBUTE7,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE7)
         , decode(cache.ATTRIBUTE8           ,null, bl.ATTRIBUTE8,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE8)
         , decode(cache.ATTRIBUTE9           ,null, bl.ATTRIBUTE9,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE9)
         , decode(cache.ATTRIBUTE10          ,null, bl.ATTRIBUTE10, FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE10)
         , decode(cache.ATTRIBUTE11          ,null, bl.ATTRIBUTE11, FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE11)
         , decode(cache.ATTRIBUTE12          ,null, bl.ATTRIBUTE12, FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE12)
         , decode(cache.ATTRIBUTE13          ,null, bl.ATTRIBUTE13, FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE13)
         , decode(cache.ATTRIBUTE14          ,null, bl.ATTRIBUTE14, FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE14)
         , decode(cache.ATTRIBUTE15          ,null, bl.ATTRIBUTE15, FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE15)
         , cache.RAW_COST_SOURCE
         , cache.BURDENED_COST_SOURCE
         , cache.QUANTITY_SOURCE
         , cache.REVENUE_SOURCE
         , decode(cache.PM_PRODUCT_CODE  ,null,bl.PM_PRODUCT_CODE, FND_API.G_MISS_CHAR, null, cache.PM_PRODUCT_CODE)
         , decode(cache.PM_BUDGET_LINE_REFERENCE ,null,bl.PM_BUDGET_LINE_REFERENCE, FND_API.G_MISS_CHAR, null, cache.PM_BUDGET_LINE_REFERENCE)
         , cache.CODE_COMBINATION_ID
         , cache.CCID_GEN_STATUS_CODE
         , cache.CCID_GEN_REJ_MESSAGE
         , cache.BORROWED_REVENUE
         , cache.TP_REVENUE_IN
         , cache.TP_REVENUE_OUT
         , cache.REVENUE_ADJ
         , cache.LENT_RESOURCE_COST
         , cache.TP_COST_IN
         , cache.TP_COST_OUT
         , cache.COST_ADJ
         , cache.UNASSIGNED_TIME_COST
         , cache.UTILIZATION_PERCENT
         , cache.UTILIZATION_HOURS
         , cache.UTILIZATION_ADJ
         , cache.CAPACITY
         , cache.HEAD_COUNT
         , cache.HEAD_COUNT_ADJ
         , cache.BUCKETING_PERIOD_CODE
         , cache.TXN_DISCOUNT_PERCENTAGE
         , cache.TRANSFER_PRICE_RATE
         , cache.BL_CREATED_BY
         , cache.BL_CREATION_DATE
        FROM  pa_fp_rollup_tmp tmp
              ,pa_fp_spread_calc_tmp1 cache
              ,pa_budget_lines bl
        WHERE  tmp.budget_version_id = p_budget_verson_id
    AND    tmp.budget_version_id = cache.budget_version_id
        AND    tmp.resource_assignment_id = cache.resource_assignment_id
    AND    tmp.txn_currency_code = cache.txn_currency_code
    AND    tmp.start_date = cache.start_date
    and    cache.budget_version_id = bl.budget_version_id(+)    --Bug 4224464. Added the join with pa_budget_lines
        AND    cache.resource_assignment_id = bl.resource_assignment_id(+)
    AND    cache.txn_currency_code = bl.txn_currency_code(+)
    AND    cache.start_date = bl.start_date(+);


    l_rowid_tab                     pa_plsql_datatypes.RowidTabTyp;
        l_resource_assignment_id_tab    pa_plsql_datatypes.IdTabTyp;
        l_txn_currency_code_tab         pa_plsql_datatypes.Char50TabTyp;
        l_start_date_tab                pa_plsql_datatypes.DateTabTyp;
        l_end_date_tab                  pa_plsql_datatypes.DateTabTyp;
        l_period_name_tab               pa_plsql_datatypes.Char50TabTyp;
        l_cost_rate_override_tab        pa_plsql_datatypes.NumTabTyp;
        l_burden_rate_override_tab      pa_plsql_datatypes.NumTabTyp;
        l_bill_rate_override_tab        pa_plsql_datatypes.NumTabTyp;
        l_PROJECT_COST_RATE_TYPE_tab    pa_plsql_datatypes.Char50TabTyp;
        l_PROJECT_COST_EXG_RATE_tab     pa_plsql_datatypes.NumTabTyp;
        l_PROJECT_COST_DATE_TYPE_tab    pa_plsql_datatypes.Char50TabTyp;
        l_PROJECT_COST_RATE_DATE_tab    pa_plsql_datatypes.DateTabTyp;
        l_PROJECT_REV_RATE_TYPE_tab     pa_plsql_datatypes.Char50TabTyp;
        l_PROJECT_REV_EXG_RATE_tab      pa_plsql_datatypes.NumTabTyp;
        l_PROJECT_REV_DATE_TYPE_tab     pa_plsql_datatypes.Char50TabTyp;
        l_PROJECT_REV_RATE_DATE_tab     pa_plsql_datatypes.DateTabTyp;
        l_PROJFUNC_COST_RATE_TYPE_tab   pa_plsql_datatypes.Char50TabTyp;
        l_PROJFUNC_COST_EXG_RATE_tab    pa_plsql_datatypes.NumTabTyp;
        l_PROJFUNC_COST_DATE_TYPE_tab   pa_plsql_datatypes.Char50TabTyp;
        l_PROJFUNC_COST_RATE_DATE_tab   pa_plsql_datatypes.DateTabTyp;
        l_PROJFUNC_REV_RATE_TYPE_tab    pa_plsql_datatypes.Char50TabTyp;
        l_PROJFUNC_REV_EXG_RATE_tab     pa_plsql_datatypes.NumTabTyp;
        l_PROJFUNC_REV_DATE_TYPE_tab    pa_plsql_datatypes.Char50TabTyp;
        l_PROJFUNC_REV_RATE_DATE_tab    pa_plsql_datatypes.DateTabTyp;
    l_CHANGE_REASON_CODE_tab        pa_plsql_datatypes.Char30TabTyp;
    l_DESCRIPTION_tab               pa_plsql_datatypes.Char250TabTyp;
    l_ATTRIBUTE_CATEGORY_tab        pa_plsql_datatypes.Char30TabTyp;
    l_ATTRIBUTE1_tab                pa_plsql_datatypes.Char150TabTyp;
    l_ATTRIBUTE2_tab                pa_plsql_datatypes.Char150TabTyp;
    l_ATTRIBUTE3_tab                pa_plsql_datatypes.Char150TabTyp;
    l_ATTRIBUTE4_tab                pa_plsql_datatypes.Char150TabTyp;
    l_ATTRIBUTE5_tab                pa_plsql_datatypes.Char150TabTyp;
    l_ATTRIBUTE6_tab                pa_plsql_datatypes.Char150TabTyp;
    l_ATTRIBUTE7_tab                pa_plsql_datatypes.Char150TabTyp;
    l_ATTRIBUTE8_tab                pa_plsql_datatypes.Char150TabTyp;
    l_ATTRIBUTE9_tab                pa_plsql_datatypes.Char150TabTyp;
    l_ATTRIBUTE10_tab               pa_plsql_datatypes.Char150TabTyp;
    l_ATTRIBUTE11_tab               pa_plsql_datatypes.Char150TabTyp;
    l_ATTRIBUTE12_tab               pa_plsql_datatypes.Char150TabTyp;
    l_ATTRIBUTE13_tab               pa_plsql_datatypes.Char150TabTyp;
    l_ATTRIBUTE14_tab               pa_plsql_datatypes.Char150TabTyp;
    l_ATTRIBUTE15_tab               pa_plsql_datatypes.Char150TabTyp;
    l_RAW_COST_SOURCE_tab           pa_plsql_datatypes.Char5TabTyp;
    l_BURDENED_COST_SOURCE_tab      pa_plsql_datatypes.Char5TabTyp;
    l_QUANTITY_SOURCE_tab           pa_plsql_datatypes.Char5TabTyp;
    l_REVENUE_SOURCE_tab            pa_plsql_datatypes.Char5TabTyp;
    l_PM_PRODUCT_CODE_tab           pa_plsql_datatypes.Char30TabTyp;
    l_PM_BUDGET_LINE_REFERENCE_tab  pa_plsql_datatypes.Char30TabTyp;
    l_CODE_COMBINATION_ID_tab       pa_plsql_datatypes.NumTabTyp;
    l_CCID_GEN_STATUS_CODE_tab      pa_plsql_datatypes.Char1TabTyp;
    l_CCID_GEN_REJ_MESSAGE_tab      pa_plsql_datatypes.Char2000TabTyp;
    l_BORROWED_REVENUE_tab          pa_plsql_datatypes.NumTabTyp;
    l_TP_REVENUE_IN_tab             pa_plsql_datatypes.NumTabTyp;
    l_TP_REVENUE_OUT_tab            pa_plsql_datatypes.NumTabTyp;
    l_REVENUE_ADJ_tab               pa_plsql_datatypes.NumTabTyp;
    l_LENT_RESOURCE_COST_tab        pa_plsql_datatypes.NumTabTyp;
    l_TP_COST_IN_tab                pa_plsql_datatypes.NumTabTyp;
    l_TP_COST_OUT_tab               pa_plsql_datatypes.NumTabTyp;
    l_COST_ADJ_tab                  pa_plsql_datatypes.NumTabTyp;
    l_UNASSIGNED_TIME_COST_tab      pa_plsql_datatypes.NumTabTyp;
    l_UTILIZATION_PERCENT_tab       pa_plsql_datatypes.NumTabTyp;
    l_UTILIZATION_HOURS_tab         pa_plsql_datatypes.NumTabTyp;
    l_UTILIZATION_ADJ_tab           pa_plsql_datatypes.NumTabTyp;
    l_CAPACITY_tab                  pa_plsql_datatypes.NumTabTyp;
    l_HEAD_COUNT_tab                pa_plsql_datatypes.NumTabTyp;
    l_HEAD_COUNT_ADJ_tab            pa_plsql_datatypes.NumTabTyp;
    l_BUCKETING_PERIOD_CODE_tab     pa_plsql_datatypes.Char30TabTyp;
    l_TXN_DISCOUNT_PERCENTAGE_tab   pa_plsql_datatypes.NumTabTyp;
    l_TRANSFER_PRICE_RATE_tab       pa_plsql_datatypes.NumTabTyp;
    l_BL_CREATED_BY_tab     pa_plsql_datatypes.NumTabTyp;
    l_BL_CREATION_DATE_tab          pa_plsql_datatypes.DateTabTyp;

    PROCEDURE INIT_PLSQL_TABS IS

    BEGIN
                l_rowid_tab.delete;
                l_resource_assignment_id_tab.delete;
                l_txn_currency_code_tab.delete;
                l_start_date_tab.delete;
                l_end_date_tab.delete;
                l_period_name_tab.delete;
                l_cost_rate_override_tab.delete;
                l_burden_rate_override_tab.delete;
                l_bill_rate_override_tab.delete;
                l_PROJECT_COST_RATE_TYPE_tab.delete;
                l_PROJECT_COST_EXG_RATE_tab.delete;
                l_PROJECT_COST_DATE_TYPE_tab.delete;
                l_PROJECT_COST_RATE_DATE_tab.delete;
                l_PROJECT_REV_RATE_TYPE_tab.delete;
                l_PROJECT_REV_EXG_RATE_tab.delete;
                l_PROJECT_REV_DATE_TYPE_tab.delete;
                l_PROJECT_REV_RATE_DATE_tab.delete;
                l_PROJFUNC_COST_RATE_TYPE_tab.delete;
                l_PROJFUNC_COST_EXG_RATE_tab.delete;
                l_PROJFUNC_COST_DATE_TYPE_tab.delete;
                l_PROJFUNC_COST_RATE_DATE_tab.delete;
                l_PROJFUNC_REV_RATE_TYPE_tab.delete;
                l_PROJFUNC_REV_EXG_RATE_tab.delete;
                l_PROJFUNC_REV_DATE_TYPE_tab.delete;
                l_PROJFUNC_REV_RATE_DATE_tab.delete;
        l_CHANGE_REASON_CODE_tab.delete;
        l_DESCRIPTION_tab.delete;
        l_ATTRIBUTE_CATEGORY_tab.delete;
        l_ATTRIBUTE1_tab.delete;
        l_ATTRIBUTE2_tab.delete;
        l_ATTRIBUTE3_tab.delete;
        l_ATTRIBUTE4_tab.delete;
        l_ATTRIBUTE5_tab.delete;
        l_ATTRIBUTE6_tab.delete;
        l_ATTRIBUTE7_tab.delete;
        l_ATTRIBUTE8_tab.delete;
        l_ATTRIBUTE9_tab.delete;
        l_ATTRIBUTE10_tab.delete;
        l_ATTRIBUTE11_tab.delete;
        l_ATTRIBUTE12_tab.delete;
        l_ATTRIBUTE13_tab.delete;
        l_ATTRIBUTE14_tab.delete;
        l_ATTRIBUTE15_tab.delete;
        l_RAW_COST_SOURCE_tab.delete;
        l_BURDENED_COST_SOURCE_tab.delete;
        l_QUANTITY_SOURCE_tab.delete;
        l_REVENUE_SOURCE_tab.delete;
        l_PM_PRODUCT_CODE_tab.delete;
        l_PM_BUDGET_LINE_REFERENCE_tab.delete;
        l_CODE_COMBINATION_ID_tab.delete;
        l_CCID_GEN_STATUS_CODE_tab.delete;
        l_CCID_GEN_REJ_MESSAGE_tab.delete;
        l_BORROWED_REVENUE_tab.delete;
        l_TP_REVENUE_IN_tab.delete;
        l_TP_REVENUE_OUT_tab.delete;
        l_REVENUE_ADJ_tab.delete;
        l_LENT_RESOURCE_COST_tab.delete;
        l_TP_COST_IN_tab.delete;
        l_TP_COST_OUT_tab.delete;
        l_COST_ADJ_tab.delete;
        l_UNASSIGNED_TIME_COST_tab.delete;
        l_UTILIZATION_PERCENT_tab.delete;
        l_UTILIZATION_HOURS_tab.delete;
        l_UTILIZATION_ADJ_tab.delete;
        l_CAPACITY_tab.delete;
        l_HEAD_COUNT_tab.delete;
        l_HEAD_COUNT_ADJ_tab.delete;
        l_BUCKETING_PERIOD_CODE_tab.delete;
        l_TXN_DISCOUNT_PERCENTAGE_tab.delete;
        l_TRANSFER_PRICE_RATE_tab.delete;
        l_BL_CREATED_BY_tab.delete;
        l_BL_CREATION_DATE_tab.delete;

    END INIT_PLSQL_TABS;
BEGIN
        /* Initialize the out variables */
        x_return_status := 'S';
        x_msg_data := NULL;
    If p_pa_debug_mode = 'Y' Then
        pa_debug.init_err_stack('PA_FP_CALC_UTILS.copy_BlAttributes');
    End If;
    IF p_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION') Then  --{
	IF P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Entered copy_BlAttributes API');
	End If;
        INIT_PLSQL_TABS;
                OPEN fptmpDetails;
                FETCH fptmpDetails BULK COLLECT INTO
                        l_rowid_tab
                        ,l_resource_assignment_id_tab
                        ,l_txn_currency_code_tab
                        ,l_start_date_tab
                        ,l_end_date_tab
                        ,l_period_name_tab
                        ,l_cost_rate_override_tab
                        ,l_burden_rate_override_tab
                        ,l_bill_rate_override_tab
                        ,l_PROJECT_COST_RATE_TYPE_tab
                        ,l_PROJECT_COST_EXG_RATE_tab
                        ,l_PROJECT_COST_DATE_TYPE_tab
                        ,l_PROJECT_COST_RATE_DATE_tab
                        ,l_PROJECT_REV_RATE_TYPE_tab
                        ,l_PROJECT_REV_EXG_RATE_tab
                        ,l_PROJECT_REV_DATE_TYPE_tab
                        ,l_PROJECT_REV_RATE_DATE_tab
                        ,l_PROJFUNC_COST_RATE_TYPE_tab
                        ,l_PROJFUNC_COST_EXG_RATE_tab
                        ,l_PROJFUNC_COST_DATE_TYPE_tab
                        ,l_PROJFUNC_COST_RATE_DATE_tab
                        ,l_PROJFUNC_REV_RATE_TYPE_tab
                        ,l_PROJFUNC_REV_EXG_RATE_tab
                        ,l_PROJFUNC_REV_DATE_TYPE_tab
                        ,l_PROJFUNC_REV_RATE_DATE_tab;
                CLOSE fptmpDetails;
                IF l_rowid_tab.COUNT > 0 THEN
                        --print_msg('Number of rows fetched['||l_rowid_tab.COUNT||']');
                        FORALL i IN  l_rowid_tab.FIRST .. l_rowid_tab.LAST
                        UPDATE pa_fp_rollup_tmp tmp
                        SET tmp.rw_cost_rate_override = l_cost_rate_override_tab(i)
                           ,tmp.burden_cost_rate_override = l_burden_rate_override_tab(i)
                           ,tmp.bill_rate_override = l_bill_rate_override_tab(i)
                           ,tmp.PROJECT_COST_RATE_TYPE = l_PROJECT_COST_RATE_TYPE_tab(i)
                           ,tmp.PROJECT_COST_EXCHANGE_RATE = l_PROJECT_COST_EXG_RATE_tab(i)
                           ,tmp.PROJECT_COST_RATE_DATE_TYPE = l_PROJECT_COST_DATE_TYPE_tab(i)
                           ,tmp.PROJECT_COST_RATE_DATE   = l_PROJECT_COST_RATE_DATE_tab(i)
                           ,tmp.PROJECT_REV_RATE_TYPE    = l_PROJECT_REV_RATE_TYPE_tab(i)
                           ,tmp.PROJECT_REV_EXCHANGE_RATE  = l_PROJECT_REV_EXG_RATE_tab(i)
                           ,tmp.PROJECT_REV_RATE_DATE_TYPE = l_PROJECT_REV_DATE_TYPE_tab(i)
                           ,tmp.PROJECT_REV_RATE_DATE   = l_PROJECT_REV_RATE_DATE_tab(i)
                           ,tmp.PROJFUNC_COST_RATE_TYPE   = l_PROJFUNC_COST_RATE_TYPE_tab(i)
                           ,tmp.PROJFUNC_COST_EXCHANGE_RATE  = l_PROJFUNC_COST_EXG_RATE_tab(i)
                           ,tmp.PROJFUNC_COST_RATE_DATE_TYPE  = l_PROJFUNC_COST_DATE_TYPE_tab(i)
                           ,tmp.PROJFUNC_COST_RATE_DATE     = l_PROJFUNC_COST_RATE_DATE_tab(i)
                           ,tmp.PROJFUNC_REV_RATE_TYPE    = l_PROJFUNC_REV_RATE_TYPE_tab(i)
                           ,tmp.PROJFUNC_REV_EXCHANGE_RATE  = l_PROJFUNC_REV_EXG_RATE_tab(i)
                           ,tmp.PROJFUNC_REV_RATE_DATE_TYPE   = l_PROJFUNC_REV_DATE_TYPE_tab(i)
                           ,tmp.PROJFUNC_REV_RATE_DATE = l_PROJFUNC_REV_RATE_DATE_tab(i)
            WHERE tmp.rowid = l_rowid_tab(i);
                        --print_msg('Number of rows updated['||sql%rowcount||']');
                END IF;

        --print_msg('Fetching budget Line Attributes such as DFFs details from cache ');
        INIT_PLSQL_TABS;
                OPEN blAttribDetails;
                FETCH blAttribDetails BULK COLLECT INTO
                        l_rowid_tab
            ,l_CHANGE_REASON_CODE_tab
            ,l_DESCRIPTION_tab
            ,l_ATTRIBUTE_CATEGORY_tab
            ,l_ATTRIBUTE1_tab
            ,l_ATTRIBUTE2_tab
            ,l_ATTRIBUTE3_tab
            ,l_ATTRIBUTE4_tab
            ,l_ATTRIBUTE5_tab
            ,l_ATTRIBUTE6_tab
            ,l_ATTRIBUTE7_tab
            ,l_ATTRIBUTE8_tab
            ,l_ATTRIBUTE9_tab
            ,l_ATTRIBUTE10_tab
            ,l_ATTRIBUTE11_tab
            ,l_ATTRIBUTE12_tab
            ,l_ATTRIBUTE13_tab
            ,l_ATTRIBUTE14_tab
            ,l_ATTRIBUTE15_tab
            ,l_RAW_COST_SOURCE_tab
            ,l_BURDENED_COST_SOURCE_tab
            ,l_QUANTITY_SOURCE_tab
            ,l_REVENUE_SOURCE_tab
            ,l_PM_PRODUCT_CODE_tab
            ,l_PM_BUDGET_LINE_REFERENCE_tab
            ,l_CODE_COMBINATION_ID_tab
            ,l_CCID_GEN_STATUS_CODE_tab
            ,l_CCID_GEN_REJ_MESSAGE_tab
            ,l_BORROWED_REVENUE_tab
            ,l_TP_REVENUE_IN_tab
            ,l_TP_REVENUE_OUT_tab
            ,l_REVENUE_ADJ_tab
            ,l_LENT_RESOURCE_COST_tab
            ,l_TP_COST_IN_tab
            ,l_TP_COST_OUT_tab
            ,l_COST_ADJ_tab
            ,l_UNASSIGNED_TIME_COST_tab
            ,l_UTILIZATION_PERCENT_tab
            ,l_UTILIZATION_HOURS_tab
            ,l_UTILIZATION_ADJ_tab
            ,l_CAPACITY_tab
            ,l_HEAD_COUNT_tab
            ,l_HEAD_COUNT_ADJ_tab
            ,l_BUCKETING_PERIOD_CODE_tab
            ,l_TXN_DISCOUNT_PERCENTAGE_tab
            ,l_TRANSFER_PRICE_RATE_tab
            ,l_BL_CREATED_BY_tab
                    ,l_BL_CREATION_DATE_tab;
                CLOSE blAttribDetails;
                IF l_rowid_tab.COUNT > 0 THEN
                        --print_msg('Number of blAttrib rows fetched['||l_rowid_tab.COUNT||']');
                        FORALL i IN  l_rowid_tab.FIRST .. l_rowid_tab.LAST
                        UPDATE pa_fp_rollup_tmp tmp
                        SET tmp.CHANGE_REASON_CODE = l_CHANGE_REASON_CODE_tab(i)
               ,tmp.DESCRIPTION = l_DESCRIPTION_tab(i)
               ,tmp.ATTRIBUTE_CATEGORY = l_ATTRIBUTE_CATEGORY_tab(i)
               ,tmp.ATTRIBUTE1 = l_ATTRIBUTE1_tab(i)
               ,tmp.ATTRIBUTE2 = l_ATTRIBUTE2_tab(i)
               ,tmp.ATTRIBUTE3 = l_ATTRIBUTE3_tab(i)
               ,tmp.ATTRIBUTE4 = l_ATTRIBUTE4_tab(i)
               ,tmp.ATTRIBUTE5 = l_ATTRIBUTE5_tab(i)
               ,tmp.ATTRIBUTE6 = l_ATTRIBUTE6_tab(i)
               ,tmp.ATTRIBUTE7 = l_ATTRIBUTE7_tab(i)
               ,tmp.ATTRIBUTE8 = l_ATTRIBUTE8_tab(i)
               ,tmp.ATTRIBUTE9 = l_ATTRIBUTE9_tab(i)
               ,tmp.ATTRIBUTE10 = l_ATTRIBUTE10_tab(i)
               ,tmp.ATTRIBUTE11 = l_ATTRIBUTE11_tab(i)
               ,tmp.ATTRIBUTE12 = l_ATTRIBUTE12_tab(i)
               ,tmp.ATTRIBUTE13 = l_ATTRIBUTE13_tab(i)
               ,tmp.ATTRIBUTE14 = l_ATTRIBUTE14_tab(i)
               ,tmp.ATTRIBUTE15 = l_ATTRIBUTE15_tab(i)
               ,tmp.RAW_COST_SOURCE = nvl(l_RAW_COST_SOURCE_tab(i),tmp.RAW_COST_SOURCE)
               ,tmp.BURDENED_COST_SOURCE = nvl(l_BURDENED_COST_SOURCE_tab(i),tmp.BURDENED_COST_SOURCE)
               ,tmp.QUANTITY_SOURCE = nvl(l_QUANTITY_SOURCE_tab(i),tmp.QUANTITY_SOURCE)
               ,tmp.REVENUE_SOURCE = nvl(l_REVENUE_SOURCE_tab(i),tmp.REVENUE_SOURCE)
               ,tmp.PM_PRODUCT_CODE = l_PM_PRODUCT_CODE_tab(i)
               ,tmp.PM_BUDGET_LINE_REFERENCE = l_PM_BUDGET_LINE_REFERENCE_tab(i)
               ,tmp.CODE_COMBINATION_ID = nvl(l_CODE_COMBINATION_ID_tab(i),tmp.CODE_COMBINATION_ID)
               ,tmp.CCID_GEN_STATUS_CODE = nvl(l_CCID_GEN_STATUS_CODE_tab(i),tmp.CCID_GEN_STATUS_CODE)
               ,tmp.CCID_GEN_REJ_MESSAGE = nvl(l_CCID_GEN_REJ_MESSAGE_tab(i),tmp.CCID_GEN_REJ_MESSAGE)
               ,tmp.BORROWED_REVENUE = nvl(l_BORROWED_REVENUE_tab(i),tmp.BORROWED_REVENUE)
               ,tmp.TP_REVENUE_IN = nvl(l_TP_REVENUE_IN_tab(i),tmp.TP_REVENUE_IN)
               ,tmp.TP_REVENUE_OUT = nvl(l_TP_REVENUE_OUT_tab(i),tmp.TP_REVENUE_OUT)
               ,tmp.REVENUE_ADJ  = nvl(l_REVENUE_ADJ_tab(i),tmp.REVENUE_ADJ)
               ,tmp.LENT_RESOURCE_COST = nvl(l_LENT_RESOURCE_COST_tab(i),tmp.LENT_RESOURCE_COST)
               ,tmp.TP_COST_IN   = nvl(l_TP_COST_IN_tab(i),tmp.TP_COST_IN)
               ,tmp.TP_COST_OUT = nvl(l_TP_COST_OUT_tab(i),tmp.TP_COST_OUT)
               ,tmp.COST_ADJ = nvl(l_COST_ADJ_tab(i),tmp.COST_ADJ)
               ,tmp.UNASSIGNED_TIME_COST = nvl(l_UNASSIGNED_TIME_COST_tab(i),tmp.UNASSIGNED_TIME_COST)
               ,tmp.UTILIZATION_PERCENT = nvl(l_UTILIZATION_PERCENT_tab(i),tmp.UTILIZATION_PERCENT)
               ,tmp.UTILIZATION_HOURS = nvl(l_UTILIZATION_HOURS_tab(i),tmp.UTILIZATION_HOURS)
               ,tmp.UTILIZATION_ADJ = nvl(l_UTILIZATION_ADJ_tab(i),tmp.UTILIZATION_ADJ)
               ,tmp.CAPACITY = nvl(l_CAPACITY_tab(i),tmp.CAPACITY)
               ,tmp.HEAD_COUNT = nvl(l_HEAD_COUNT_tab(i),tmp.HEAD_COUNT)
               ,tmp.HEAD_COUNT_ADJ =nvl(l_HEAD_COUNT_ADJ_tab(i),tmp.HEAD_COUNT_ADJ)
               ,tmp.BUCKETING_PERIOD_CODE = nvl(l_BUCKETING_PERIOD_CODE_tab(i),tmp.BUCKETING_PERIOD_CODE)
               ,tmp.TXN_DISCOUNT_PERCENTAGE = nvl(l_TXN_DISCOUNT_PERCENTAGE_tab(i),tmp.TXN_DISCOUNT_PERCENTAGE)
               ,tmp.TRANSFER_PRICE_RATE = nvl(l_TRANSFER_PRICE_RATE_tab(i),tmp.TRANSFER_PRICE_RATE)
               ,tmp.BL_CREATED_BY   = nvl(l_BL_CREATED_BY_tab(i),tmp.BL_CREATED_BY)
               ,tmp.BL_CREATION_DATE   = NVL(l_BL_CREATION_DATE_tab(i),tmp.BL_CREATION_DATE)
                        WHERE tmp.rowid = l_rowid_tab(i);
            --print_msg('Number of rows updated['||sql%rowcount||']');

                END IF;
        /* release the buffer */
        INIT_PLSQL_TABS;
        END IF;  --}
    --print_msg('End of copy_BlAttributes retSts['||x_return_status||']');
    If p_pa_debug_mode = 'Y' Then
        pa_debug.reset_err_stack;
    End If;
EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                x_msg_data := SQLCODE||SQLERRM;
        fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'copy_BlAttributes');
        If p_pa_debug_mode = 'Y' Then
                    pa_debug.reset_err_stack;
        End If;
                RAISE;

END copy_BlAttributes;

/*This API is added to check the duplicate records sent in plsql tables for calculate api
 *If there are any duplicates (resource assignment and txn currency combination ) then
 * delete one of the record and proceed, instead of throwing an error
 * Logic used: Instead of looping through the plsql table in amg mode, the number of rows may be 1000
 * then loop through the plsql table will not scale the performance.
 * so use the tmp table, First dump all the records into tmp table then chk duplicate rows exists, then
 * delete the record from the tmp table finally assign the values from tmp to plsql tables.so that
 * the plsql index need not be manintained.
 */
PROCEDURE Validate_duplicate_records (
                p_budget_version_id              IN  Number
                ,p_source_context                IN  VARCHAR2
        ,p_calling_module                IN  VARCHAR2
                ,x_return_status                 OUT NOCOPY VARCHAR2
        ) IS

    l_duplicate_record_exists  varchar2(10) := 'N';

        CURSOR cur_chk_dupRecords IS
        SELECT tmp.resource_assignment_id
                ,tmp.txn_currency_code
            ,tmp.start_date
        FROM pa_fp_spread_calc_tmp tmp
    WHERE  tmp.budget_version_id = p_budget_version_id
        GROUP BY tmp.resource_assignment_id
                ,tmp.txn_currency_code
        ,tmp.start_date
        HAVING COUNT(*) > 1 ;

BEGIN
    x_return_status := 'S';
    print_msg('Inside Validate_duplicate_records Api');
    g_stage := 'Validate_duplicate_records:100';

    IF p_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION') Then --{
       g_stage := 'Validate_duplicate_records:101';
       l_duplicate_record_exists := 'N';
       FOR i IN cur_chk_dupRecords LOOP
		/*
                print_msg('Duplicate Resource Assignments sent for Calcaulate API');
                print_msg('ResId['||i.resource_assignment_id||']txnCur['||i.txn_currency_code||']');
		*/
        l_duplicate_record_exists := 'Y';
        IF NVL(p_source_context,'RESOURCE_ASSIGNMENT') = 'RESOURCE_ASSIGNMENT' Then
            g_stage := 'Validate_duplicate_records:102';
            DELETE FROM pa_fp_spread_calc_tmp tmp1
            WHERE tmp1.resource_assignment_id = i.resource_assignment_id
            AND  tmp1.txn_currency_code = i.txn_currency_code
            AND tmp1.rowid NOT IN  (select min(rowid) from pa_fp_spread_calc_tmp tmp2
                            where tmp1.resource_assignment_id = tmp2.resource_assignment_id
                    and   tmp1.txn_currency_code = tmp2.txn_currency_code
                    group by tmp2.resource_assignment_id,tmp2.txn_currency_code
                    having count(*) > 1
                    )
            /* added this to make sure that even if code is executed multiple times this should delete the correct combo */
            /* this code is not required if not executed twice for the same combo*/
                        AND EXISTS  (select 'Y' from pa_fp_spread_calc_tmp tmp2
                                     where tmp1.resource_assignment_id = tmp2.resource_assignment_id
                                     and   tmp1.txn_currency_code = tmp2.txn_currency_code
                                     group by tmp2.resource_assignment_id,tmp2.txn_currency_code
                                     having count(*) > 1
                                 );
        Elsif NVL(p_source_context,'RESOURCE_ASSIGNMENT') = 'BUDGET_LINE' Then
            g_stage := 'Validate_duplicate_records:103';
                        DELETE FROM pa_fp_spread_calc_tmp tmp1
                        WHERE tmp1.resource_assignment_id = i.resource_assignment_id
                        AND  tmp1.txn_currency_code = i.txn_currency_code
            AND  tmp1.start_date = i.start_date
                        AND tmp1.rowid NOT IN  (select min(tmp2.rowid) from pa_fp_spread_calc_tmp tmp2
                                where tmp1.resource_assignment_id = tmp2.resource_assignment_id
                                        and   tmp1.txn_currency_code = tmp2.txn_currency_code
                    and   tmp1.start_date = tmp2.start_date
                                        group by tmp2.resource_assignment_id,tmp2.txn_currency_code,tmp2.start_date
                                        having count(*) > 1
                                        )
                       AND EXISTS  (select 'Y' from pa_fp_spread_calc_tmp tmp2
                                    where tmp1.resource_assignment_id = tmp2.resource_assignment_id
                                    and   tmp1.txn_currency_code = tmp2.txn_currency_code
                                    and   tmp1.start_date = tmp2.start_date
                                    group by tmp2.resource_assignment_id,tmp2.txn_currency_code,tmp2.start_date
                                    having count(*) > 1
                                    );
        End If;
        --print_msg('Number of duplicate records deleted['||sql%rowcount||']');
           END LOOP;
    END IF; --}
    g_stage := 'End of Validate_duplicate_records:105';
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := 'U';
        RAISE;

END Validate_duplicate_records;

/* Bug fix: 4184159 The following API will update the budget lines in bulk. This API uses oracle 9i feature of SQL%BULKEXCEPTION
 * during bulk update fails due to dup_val_on_index exception, the process the rejected rows.
 * Earlier the api was updating the budget line inside a loop for each row. this was causing the performance bottle neck
 * This API must be called at the end of calculate API, It copies the value from rollup tmp to budget lines.
 */
PROCEDURE BLK_update_budget_lines
    (p_budget_version_id              IN  NUMBER
    ,p_calling_module                  IN VARCHAR2 DEFAULT 'UPDATE_PLAN_TRANSACTION'-- Added for Bug#5395732
    ,x_return_status                 OUT NOCOPY VARCHAR2
        ,x_msg_count                     OUT NOCOPY NUMBER
        ,x_msg_data                      OUT NOCOPY VARCHAR2) IS

    l_debug_mode        VARCHAR2(30);
    l_stage             NUMBER;
    l_populate_mrc_tab_flag   Varchar2(10) := 'N'; --MRC Elimination Changes:NVL(PA_FP_CALC_PLAN_PKG.G_populate_mrc_tab_flag,'N');
    l_existing_bl_id                pa_budget_lines.budget_line_id%TYPE;

        l_bl_raId_tab               pa_plsql_datatypes.NumTabTyp;
        l_bl_sDate_tab              pa_plsql_datatypes.dateTabTyp;
    l_bl_edate_tab              pa_plsql_datatypes.dateTabTyp;
    l_bl_period_name_tab            pa_plsql_datatypes.char30TabTyp;
        l_bl_budget_line_id_tab         pa_plsql_datatypes.NumTabTyp;
        l_bl_txn_curcode_tab            pa_plsql_datatypes.char30TabTyp;
        l_bl_quantity_tab               pa_plsql_datatypes.NumTabTyp;
        l_bl_pjfc_raw_cost_tab          pa_plsql_datatypes.NumTabTyp;
    l_bl_pjfc_burden_cost_tab       pa_plsql_datatypes.NumTabTyp;
    l_bl_pjfc_revenue_tab           pa_plsql_datatypes.NumTabTyp;
    l_bl_cost_rejection_tab         pa_plsql_datatypes.char30TabTyp;
    l_bl_rev_rejection_tab          pa_plsql_datatypes.char30TabTyp;
    l_bl_burden_rejection_tab       pa_plsql_datatypes.char30TabTyp;
    l_bl_pfc_cur_rejection_tab      pa_plsql_datatypes.char30TabTyp;
    l_bl_pc_cur_rejection_tab       pa_plsql_datatypes.char30TabTyp;
    l_bl_pfc_curcode_tab            pa_plsql_datatypes.char30TabTyp;
        l_bl_pfc_cost_rate_type_tab     pa_plsql_datatypes.char100TabTyp;
        l_bl_pfc_cost_exchng_rate_tab       pa_plsql_datatypes.NumTabTyp;
        l_bl_pfc_cost_date_type_tab     pa_plsql_datatypes.char100TabTyp;
        l_bl_pfc_cost_date_tab          pa_plsql_datatypes.dateTabTyp;
        l_bl_pfc_rev_rate_type_tab      pa_plsql_datatypes.char100TabTyp;
        l_bl_pfc_rev_exchange_rate_tab      pa_plsql_datatypes.NumTabTyp;
        l_bl_pfc_rev_date_type_tab      pa_plsql_datatypes.char100TabTyp;
        l_bl_pfc_rev_date_tab           pa_plsql_datatypes.dateTabTyp;
        l_bl_pc_cur_code_tab            pa_plsql_datatypes.char30TabTyp;
        l_bl_pc_cost_rate_type_tab      pa_plsql_datatypes.char100TabTyp;
        l_bl_pc_cost_exchange_rate_tab      pa_plsql_datatypes.NumTabTyp;
        l_bl_pc_cost_date_type_tab      pa_plsql_datatypes.char100TabTyp;
        l_bl_pc_cost_date_tab           pa_plsql_datatypes.dateTabTyp;
        l_bl_project_raw_cost_tab       pa_plsql_datatypes.NumTabTyp;
        l_bl_project_burdened_cost_tab      pa_plsql_datatypes.NumTabTyp;
        l_bl_pc_rev_rate_type_tab       pa_plsql_datatypes.char100TabTyp;
        l_bl_pc_rev_exchange_rate_tab       pa_plsql_datatypes.NumTabTyp;
        l_bl_pc_rev_date_type_tab       pa_plsql_datatypes.char100TabTyp;
        l_bl_pc_rev_date_tab            pa_plsql_datatypes.dateTabTyp;
        l_bl_project_revenue_tab        pa_plsql_datatypes.NumTabTyp;
        l_bl_txn_raw_cost_tab           pa_plsql_datatypes.NumTabTyp;
        l_bl_txn_burdened_cost_tab      pa_plsql_datatypes.NumTabTyp;
        l_bl_txn_revenue_tab            pa_plsql_datatypes.NumTabTyp;
        l_bl_init_quantity_tab          pa_plsql_datatypes.NumTabTyp;
        l_bl_txn_init_raw_cost_tab      pa_plsql_datatypes.NumTabTyp;
        l_bl_txn_init_burden_cost_tab       pa_plsql_datatypes.NumTabTyp;
        l_bl_txn_init_revenue_tab       pa_plsql_datatypes.NumTabTyp;
        l_bl_pfc_init_raw_cost_tab      pa_plsql_datatypes.NumTabTyp;
        l_bl_pfc_init_burden_cost_tab       pa_plsql_datatypes.NumTabTyp;
        l_bl_pfc_init_revenue_tab       pa_plsql_datatypes.NumTabTyp;
        l_bl_pc_init_raw_cost_tab       pa_plsql_datatypes.NumTabTyp;
        l_bl_pc_init_burden_cost_tab        pa_plsql_datatypes.NumTabTyp;
        l_bl_pc_init_revenue_tab        pa_plsql_datatypes.NumTabTyp;
        l_bl_markup_percentage_tab      pa_plsql_datatypes.NumTabTyp;
        l_bl_bill_rate_tab          pa_plsql_datatypes.NumTabTyp;
        l_bl_cost_rate_tab          pa_plsql_datatypes.NumTabTyp;
        l_bl_cost_rate_override_tab     pa_plsql_datatypes.NumTabTyp;
        l_bl_burden_cost_rate_tab       pa_plsql_datatypes.NumTabTyp;
        l_bl_bill_rate_override_tab     pa_plsql_datatypes.NumTabTyp;
        l_bl_burden_rate_override_tab       pa_plsql_datatypes.NumTabTyp;
        l_bl_compiled_set_id_tab        pa_plsql_datatypes.NumTabTyp;
    l_bl_version_type_tab           pa_plsql_datatypes.char100TabTyp;
    l_bl_final_txn_cur_code_tab     pa_plsql_datatypes.char100TabTyp;
    l_bl_CHANGE_REASON_CODE_tab     pa_plsql_datatypes.char2000TabTyp;
        l_bl_DESCRIPTION_tab            pa_plsql_datatypes.char2000TabTyp;
        l_bl_ATTRIBUTE_CATEGORY_tab         pa_plsql_datatypes.char30TabTyp;
        l_bl_ATTRIBUTE1_tab             pa_plsql_datatypes.Char150TabTyp;
        l_bl_ATTRIBUTE2_tab         pa_plsql_datatypes.Char150TabTyp;
        l_bl_ATTRIBUTE3_tab             pa_plsql_datatypes.Char150TabTyp;
        l_bl_ATTRIBUTE4_tab             pa_plsql_datatypes.Char150TabTyp;
        l_bl_ATTRIBUTE5_tab             pa_plsql_datatypes.Char150TabTyp;
        l_bl_ATTRIBUTE6_tab             pa_plsql_datatypes.Char150TabTyp;
        l_bl_ATTRIBUTE7_tab             pa_plsql_datatypes.Char150TabTyp;
        l_bl_ATTRIBUTE8_tab             pa_plsql_datatypes.Char150TabTyp;
        l_bl_ATTRIBUTE9_tab             pa_plsql_datatypes.Char150TabTyp;
        l_bl_ATTRIBUTE10_tab            pa_plsql_datatypes.Char150TabTyp;
        l_bl_ATTRIBUTE11_tab            pa_plsql_datatypes.Char150TabTyp;
        l_bl_ATTRIBUTE12_tab            pa_plsql_datatypes.Char150TabTyp;
        l_bl_ATTRIBUTE13_tab            pa_plsql_datatypes.Char150TabTyp;
        l_bl_ATTRIBUTE14_tab            pa_plsql_datatypes.Char150TabTyp;
        l_bl_ATTRIBUTE15_tab            pa_plsql_datatypes.Char150TabTyp;
        l_bl_RAW_COST_SOURCE_tab        pa_plsql_datatypes.Char5TabTyp;
        l_bl_BURDENED_COST_SOURCE_tab       pa_plsql_datatypes.Char5TabTyp;
        l_bl_QUANTITY_SOURCE_tab        pa_plsql_datatypes.Char5TabTyp;
        l_bl_REVENUE_SOURCE_tab         pa_plsql_datatypes.Char5TabTyp;
        l_bl_PM_PRODUCT_CODE_tab        pa_plsql_datatypes.char30TabTyp;
        l_bl_PM_LINE_REFERENCE_tab      pa_plsql_datatypes.char30TabTyp;
        l_bl_CODE_COMBINATION_ID_tab        pa_plsql_datatypes.NumTabTyp;
        l_bl_CCID_GEN_STATUS_CODE_tab       pa_plsql_datatypes.Char1TabTyp;
        l_bl_CCID_GEN_REJ_MESSAGE_tab       pa_plsql_datatypes.Char150TabTyp;
        l_bl_BORROWED_REVENUE_tab       pa_plsql_datatypes.NumTabTyp;
        l_bl_TP_REVENUE_IN_tab          pa_plsql_datatypes.NumTabTyp;
        l_bl_TP_REVENUE_OUT_tab         pa_plsql_datatypes.NumTabTyp;
        l_bl_REVENUE_ADJ_tab            pa_plsql_datatypes.NumTabTyp;
        l_bl_LENT_RESOURCE_COST_tab         pa_plsql_datatypes.NumTabTyp;
        l_bl_TP_COST_IN_tab             pa_plsql_datatypes.NumTabTyp;
        l_bl_TP_COST_OUT_tab            pa_plsql_datatypes.NumTabTyp;
        l_bl_COST_ADJ_tab           pa_plsql_datatypes.NumTabTyp;
        l_bl_UNASSIGNED_TIME_COST_tab       pa_plsql_datatypes.NumTabTyp;
        l_bl_UTILIZATION_PERCENT_tab        pa_plsql_datatypes.NumTabTyp;
        l_bl_UTILIZATION_HOURS_tab      pa_plsql_datatypes.NumTabTyp;
        l_bl_UTILIZATION_ADJ_tab        pa_plsql_datatypes.NumTabTyp;
        l_bl_CAPACITY_tab           pa_plsql_datatypes.NumTabTyp;
        l_bl_HEAD_COUNT_tab             pa_plsql_datatypes.NumTabTyp;
        l_bl_HEAD_COUNT_ADJ_tab         pa_plsql_datatypes.NumTabTyp;
        l_bl_BUCKETING_PERIOD_CODE_tab      pa_plsql_datatypes.char30TabTyp;
        l_bl_TXN_DISCOUNT_PERCENT_tab       pa_plsql_datatypes.NumTabTyp;
        l_bl_TRANSFER_PRICE_RATE_tab        pa_plsql_datatypes.NumTabTyp;
        l_bl_BL_CREATED_BY_tab          pa_plsql_datatypes.NumTabTyp;
        l_bl_BL_CREATION_DATE_tab       pa_plsql_datatypes.DateTabTyp;
	l_rate_base_flag_tab            pa_plsql_datatypes.Char1TabTyp;


    CURSOR Cur_RollupLines IS
        SELECT /*+ INDEX(B PA_BUDGET_LINES_U2) */ r.resource_assignment_id
          ,b.start_date
      ,b.end_date
      ,b.period_name
          ,r.budget_line_id
          ,r.txn_currency_code                                  txn_currency_code
          ,case when r.quantity = 0 and r.init_quantity = 0 then null else r.quantity end  quantity
          ,DECODE(r.projfunc_raw_cost,0,NULL,r.projfunc_raw_cost)           projfunc_raw_cost
          ,DECODE(r.projfunc_burdened_cost,0,NULL,r.projfunc_burdened_cost) projfunc_burdened_cost
          ,DECODE(r.projfunc_revenue,0,NULL,r.projfunc_revenue)             projfunc_revenue
          ,r.cost_rejection_code
          ,r.revenue_rejection_code
          ,r.burden_rejection_code
          ,r.pfc_cur_conv_rejection_code
          ,r.pc_cur_conv_rejection_code
          ,r.projfunc_currency_code
          ,r.projfunc_cost_rate_type
          ,r.projfunc_cost_exchange_rate
          ,r.projfunc_cost_rate_date_type
          ,r.projfunc_cost_rate_date
          ,r.projfunc_rev_rate_type
          ,r.projfunc_rev_exchange_rate
          ,r.projfunc_rev_rate_date_type
          ,r.projfunc_rev_rate_date
          ,r.project_currency_code
          ,r.project_cost_rate_type
          ,r.project_cost_exchange_rate
          ,r.project_cost_rate_date_type
          ,r.project_cost_rate_date
          ,DECODE(r.project_raw_cost,0,NULL,r.project_raw_cost)             project_raw_cost
          ,DECODE(r.project_burdened_cost,0,NULL,r.project_burdened_cost)   project_burdened_cost
          ,r.project_rev_rate_type
          ,r.project_rev_exchange_rate
          ,r.project_rev_rate_date_type
          ,r.project_rev_rate_date
          ,DECODE(r.project_revenue,0,NULL,r.project_revenue)               project_revenue
          ,case when r.txn_raw_cost = 0 and r.txn_init_raw_cost = 0 then null else r.txn_raw_cost end txn_raw_cost
          ,case when r.txn_burdened_cost = 0 and r.txn_init_burdened_cost = 0 then null else r.txn_burdened_cost end txn_burdened_cost
          ,case when r.txn_revenue = 0 and r.init_revenue = 0 then null else  r.txn_revenue end txn_revenue
          ,DECODE(r.init_quantity,0,NULL,r.init_quantity)                   init_quantity
          ,DECODE(r.txn_init_raw_cost,0,NULL,r.txn_init_raw_cost)           txn_init_raw_cost
          ,DECODE(r.txn_init_burdened_cost,0,NULL,r.txn_init_burdened_cost) txn_init_burdened_cost
          ,DECODE(r.txn_init_revenue,0,NULL,r.txn_init_revenue)             txn_init_revenue
          ,DECODE(b.init_raw_cost,0,NULL,b.init_raw_cost)                   init_raw_cost
          ,DECODE(b.init_burdened_cost,0,NULL,b.init_burdened_cost)         init_burdened_cost
          ,DECODE(b.init_revenue,0,NULL,b.init_revenue)                     init_revenue
          ,DECODE(b.project_init_raw_cost,0,NULL,b.project_init_raw_cost)   project_init_raw_cost
          ,DECODE(b.project_init_burdened_cost,0,NULL,b.project_init_burdened_cost) project_init_burdened_cost
          ,DECODE(b.project_init_revenue,0,NULL,b.project_init_revenue)     project_init_revenue
          ,r.bill_markup_percentage
          ,DECODE(r.bill_rate,0,NULL,r.bill_rate)                           bill_rate
          ,DECODE(r.cost_rate,0,NULL,r.cost_rate)                           cost_rate
          --,DECODE(r.rw_cost_rate_override,0,NULL,r.rw_cost_rate_override)   rw_cost_rate_override
          ,DECODE(r.rw_cost_rate_override,0,0,NULL,NULL,r.rw_cost_rate_override)   rw_cost_rate_override
          ,DECODE(r.burden_cost_rate,0,NULL,r.burden_cost_rate)             burden_cost_rate
          --,DECODE(r.bill_rate_override,0,NULL,r.bill_rate_override)         bill_rate_override
          ,DECODE(r.bill_rate_override,0,0,NULL,NULL,r.bill_rate_override)         bill_rate_override
          --,DECODE(r.burden_cost_rate_override,0,NULL,r.burden_cost_rate_override)   burden_cost_rate_override
          ,DECODE(r.burden_cost_rate_override,0,0,NULL,NULL,r.burden_cost_rate_override)   burden_cost_rate_override
          ,r.cost_ind_compiled_set_id
      ,g_budget_version_type  version_type
	,r.final_txn_curr_code final_txn_currency_code
        /* bug fix:5014538: Added nvl to retain the exisiting budget line attribs */
        ,nvl(r.CHANGE_REASON_CODE,b.CHANGE_REASON_CODE)                 CHANGE_REASON_CODE
          ,nvl(r.DESCRIPTION,b.DESCRIPTION)                             DESCRIPTION
          ,nvl(r.ATTRIBUTE_CATEGORY,b.ATTRIBUTE_CATEGORY)               ATTRIBUTE_CATEGORY
          ,nvl(r.ATTRIBUTE1,b.ATTRIBUTE1)                               ATTRIBUTE1
          ,nvl(r.ATTRIBUTE2,b.ATTRIBUTE2)                               ATTRIBUTE2
          ,nvl(r.ATTRIBUTE3,b.ATTRIBUTE3)                               ATTRIBUTE3
          ,nvl(r.ATTRIBUTE4,b.ATTRIBUTE4)                               ATTRIBUTE4
          ,nvl(r.ATTRIBUTE5,b.ATTRIBUTE5)                               ATTRIBUTE5
          ,nvl(r.ATTRIBUTE6,b.ATTRIBUTE6)                               ATTRIBUTE6
          ,nvl(r.ATTRIBUTE7,b.ATTRIBUTE7)                               ATTRIBUTE7
          ,nvl(r.ATTRIBUTE8,b.ATTRIBUTE8)                               ATTRIBUTE8
          ,nvl(r.ATTRIBUTE9,b.ATTRIBUTE9)                               ATTRIBUTE9
          ,nvl(r.ATTRIBUTE10,b.ATTRIBUTE10)                             ATTRIBUTE10
          ,nvl(r.ATTRIBUTE11,b.ATTRIBUTE11)                             ATTRIBUTE11
          ,nvl(r.ATTRIBUTE12,b.ATTRIBUTE12)                             ATTRIBUTE12
          ,nvl(r.ATTRIBUTE13,b.ATTRIBUTE13)                             ATTRIBUTE13
          ,nvl(r.ATTRIBUTE14,b.ATTRIBUTE14)                             ATTRIBUTE14
          ,nvl(r.ATTRIBUTE15,b.ATTRIBUTE15)                             ATTRIBUTE15
          ,r.RAW_COST_SOURCE
          ,r.BURDENED_COST_SOURCE
          ,r.QUANTITY_SOURCE
          ,r.REVENUE_SOURCE
	  ,nvl(r.PM_PRODUCT_CODE,b.PM_PRODUCT_CODE)                     PM_PRODUCT_CODE
          ,nvl(r.PM_BUDGET_LINE_REFERENCE,b.PM_BUDGET_LINE_REFERENCE)   PM_BUDGET_LINE_REFERENCE
          ,nvl(r.CODE_COMBINATION_ID,b.CODE_COMBINATION_ID)             CODE_COMBINATION_ID
          ,nvl(r.CCID_GEN_STATUS_CODE,b.CCID_GEN_STATUS_CODE)           CCID_GEN_STATUS_CODE
          ,nvl(r.CCID_GEN_REJ_MESSAGE,b.CCID_GEN_REJ_MESSAGE)           CCID_GEN_REJ_MESSAGE
          ,nvl(r.BORROWED_REVENUE,b.BORROWED_REVENUE)                   BORROWED_REVENUE
          ,nvl(r.TP_REVENUE_IN,b.TP_REVENUE_IN)                         TP_REVENUE_IN
          ,nvl(r.TP_REVENUE_OUT,b.TP_REVENUE_OUT)                       TP_REVENUE_OUT
          ,nvl(r.REVENUE_ADJ,b.REVENUE_ADJ)                             REVENUE_ADJ
          ,nvl(r.LENT_RESOURCE_COST,b.LENT_RESOURCE_COST)               LENT_RESOURCE_COST
          ,nvl(r.TP_COST_IN,b.TP_COST_IN)                               TP_COST_IN
          ,nvl(r.TP_COST_OUT,b.TP_COST_OUT)                             TP_COST_OUT
          ,nvl(r.COST_ADJ,b.COST_ADJ)                                   COST_ADJ
          ,nvl(r.UNASSIGNED_TIME_COST,b.UNASSIGNED_TIME_COST)           UNASSIGNED_TIME_COST
          ,nvl(r.UTILIZATION_PERCENT,b.UTILIZATION_PERCENT)             UTILIZATION_PERCENT
          ,nvl(r.UTILIZATION_HOURS,b.UTILIZATION_HOURS)                 UTILIZATION_HOURS
          ,nvl(r.UTILIZATION_ADJ,b.UTILIZATION_ADJ)                     UTILIZATION_ADJ
          ,nvl(r.CAPACITY,b.CAPACITY)                                   CAPACITY
          ,nvl(r.HEAD_COUNT,b.HEAD_COUNT)                               HEAD_COUNT
          ,nvl(r.HEAD_COUNT_ADJ,b.HEAD_COUNT_ADJ)                       HEAD_COUNT_ADJ
          ,nvl(r.BUCKETING_PERIOD_CODE,b.BUCKETING_PERIOD_CODE)         BUCKETING_PERIOD_CODE
          ,nvl(r.TXN_DISCOUNT_PERCENTAGE,b.TXN_DISCOUNT_PERCENTAGE)     TXN_DISCOUNT_PERCENTAGE
          ,nvl(r.TRANSFER_PRICE_RATE,b.TRANSFER_PRICE_RATE)             TRANSFER_PRICE_RATE
          ,r.BL_CREATED_BY
          ,r.BL_CREATION_DATE
          ,NVL(ra.rate_based_flag,'N')
	FROM pa_fp_rollup_tmp r
           ,pa_budget_lines  b
           ,pa_resource_assignments ra
        WHERE r.budget_line_id = b.budget_line_id
        AND  b.budget_version_id = p_budget_version_id
        AND  b.budget_version_id = r.budget_version_id  --Bug 7520706
        AND  ra.budget_version_id = r.budget_version_id  --Bug 7520706
        AND r.resource_assignment_id = ra.resource_assignment_id
        ORDER by r.resource_assignment_id,r.start_date,decode(b.txn_currency_code,r.txn_currency_code,0,1)
    ;


    /* This cursor is used only for before and after updated the budget line values */
    CURSOR cur_blAmts IS
    SELECT bl.budget_line_id
         ,bl.txn_raw_cost
         ,bl.txn_burdened_cost
         ,bl.txn_revenue
         ,bl.project_raw_cost
         ,bl.project_burdened_cost
         ,bl.project_revenue
         ,bl.raw_cost      projfunc_raw_cost
         ,bl.burdened_cost projfunc_burdened_cost
         ,bl.revenue       projfunc_revenue
         ,bl.quantity
     ,bl.start_date
     ,bl.end_date
     ,bl.period_name
     ,bl.resource_assignment_id
     ,bl.txn_currency_code
     ,bl.project_currency_code
     ,bl.projfunc_currency_code
        FROM pa_budget_lines bl
        ,pa_fp_rollup_tmp r
    WHERE  bl.budget_version_id = p_budget_version_id
    AND  bl.budget_line_id = r.budget_line_id
    AND  NVL(r.processed_flag,'Y') <> 'N';
	/* bug fix:5031388
    	AND  bl.cost_rejection_code         IS NULL
        AND  bl.revenue_rejection_code      IS NULL
        AND  bl.burden_rejection_code       IS NULL
        AND  bl.pfc_cur_conv_rejection_code IS NULL
        AND  bl.pc_cur_conv_rejection_code  IS NULL
	*/

    /* This cursor is used for passing values to rollup api for dupVal rejected bl rows */
    CURSOR cur_ExistingblAmts IS
        SELECT bl.budget_line_id
         ,bl.txn_raw_cost
         ,bl.txn_burdened_cost
         ,bl.txn_revenue
         ,bl.project_raw_cost
         ,bl.project_burdened_cost
         ,bl.project_revenue
         ,bl.raw_cost      projfunc_raw_cost
         ,bl.burdened_cost projfunc_burdened_cost
         ,bl.revenue       projfunc_revenue
         ,bl.quantity
         ,bl.start_date
         ,bl.end_date
         ,bl.period_name
         ,bl.resource_assignment_id
         ,bl.txn_currency_code
         ,bl.project_currency_code
         ,bl.projfunc_currency_code
        FROM pa_budget_lines bl
        ,pa_fp_spread_calc_tmp2 tmp2
        WHERE  bl.budget_version_id = p_budget_version_id
    AND  tmp2.budget_version_id = bl.budget_version_id
    AND  tmp2.resource_assignment_id = bl.resource_assignment_id
    AND  tmp2.txn_currency_code = bl.txn_currency_code
    AND  tmp2.start_date = bl.start_date;
	/* bug fix:5031388
        AND  bl.cost_rejection_code         IS NULL
        AND  bl.revenue_rejection_code      IS NULL
        AND  bl.burden_rejection_code       IS NULL
        AND  bl.pfc_cur_conv_rejection_code IS NULL
        AND  bl.pc_cur_conv_rejection_code  IS NULL
	*/


    l_err_error_code_tab           pa_plsql_datatypes.char30TabTyp;
        l_err_budget_line_id_tab       pa_plsql_datatypes.NumTabTyp;
        l_err_raId_tab                 pa_plsql_datatypes.NumTabTyp;
        l_err_txn_cur_tab              pa_plsql_datatypes.char30TabTyp;
        l_err_sdate_tab                pa_plsql_datatypes.DateTabTyp;
        l_err_quantity_tab             pa_plsql_datatypes.NumTabTyp;
        l_err_cost_rate_tab            pa_plsql_datatypes.NumTabTyp;
        l_err_cost_rate_ovr_tab        pa_plsql_datatypes.NumTabTyp;
        l_err_burden_rate_tab          pa_plsql_datatypes.NumTabTyp;
        l_err_burden_rate_ovr_tab      pa_plsql_datatypes.NumTabTyp;
        l_err_compiled_set_id_tab      pa_plsql_datatypes.NumTabTyp;
        l_err_bill_rate_tab            pa_plsql_datatypes.NumTabTyp;
        l_err_bill_rate_ovr_tab        pa_plsql_datatypes.NumTabTyp;
        l_err_markup_percent_tab       pa_plsql_datatypes.NumTabTyp;
        l_err_cost_rejection_tab       pa_plsql_datatypes.char30TabTyp;
        l_err_revenue_rejection_tab    pa_plsql_datatypes.char30TabTyp;
        l_err_burden_rejection_tab     pa_plsql_datatypes.char30TabTyp;
        l_err_pfc_cur_rejection_tab    pa_plsql_datatypes.char30TabTyp;
        l_err_pc_cur_rejection_tab     pa_plsql_datatypes.char30TabTyp;

    CURSOR cur_errorBdgtLines IS
    SELECT tmp1.budget_line_id
          ,tmp1.resource_assignment_id
          ,tmp1.txn_currency_code
          ,tmp1.start_date
          ,tmp1.end_date
          ,tmp1.quantity
          ,tmp1.cost_rate
          ,tmp1.cost_rate_override
          ,tmp1.burden_cost_rate
          ,tmp1.burden_cost_rate_override
          ,tmp1.bill_rate
          ,tmp1.bill_rate_override
          ,tmp1.cost_ind_compiled_set_id
          ,tmp1.bill_markup_percentage
          ,tmp1.cost_rejection_code
          ,tmp1.revenue_rejection_code
          ,tmp1.burden_rejection_code
          ,tmp1.pfc_cur_conv_rejection_code
          ,tmp1.pc_cur_conv_rejection_code
          ,tmp1.system_reference_num1  Existing_budget_line_id
    FROM pa_fp_spread_calc_tmp1 tmp1
    WHERE tmp1.budget_version_id = p_budget_version_id;

    l_del_budget_line_id_tab        pa_plsql_datatypes.NumTabTyp;
    CURSOR cur_delBlLines IS
    SELECT tmp1.budget_line_id
    FROM pa_fp_spread_calc_tmp1 tmp1
        WHERE tmp1.budget_version_id = p_budget_version_id;


    CURSOR cur_Tmp2ExblAmts(p_budget_line_id Number) IS
        SELECT tmp2.budget_line_id  existing_budget_line_id
     ,tmp2.cost_rate        existing_cost_rate
     ,tmp2.cost_rate_override   existing_cost_rate_ovride
     ,tmp2.burden_cost_rate     existing_burden_rate
     ,tmp2.burden_cost_rate_override existing_burden_rate_ovride
     ,tmp2.bill_rate        existing_bill_rate
     ,tmp2.bill_rate_override   existing_bill_rate_ovride
     ,tmp2.bill_markup_percentage   existing_markup_percentage
     ,tmp2.system_reference_num1    existing_compile_set_id
        FROM pa_fp_spread_calc_tmp2 tmp2
        WHERE  tmp2.budget_version_id = p_budget_version_id
        AND  tmp2.budget_line_id = p_budget_line_id;
    ExBlRec   cur_Tmp2ExblAmts%ROWTYPE;


    l_last_updated_by               NUMBER := FND_GLOBAL.user_id;
    l_last_login_id                 NUMBER := FND_GLOBAL.login_id;
    l_sysdate                       DATE   := SYSDATE;
    l_rep_budget_line_id_tab        pa_plsql_datatypes.NumTabTyp;
    l_rep_txn_raw_cost_tab          pa_plsql_datatypes.NumTabTyp;
        l_rep_txn_burdened_cost_tab     pa_plsql_datatypes.NumTabTyp;
        l_rep_txn_revenue_tab           pa_plsql_datatypes.NumTabTyp;
        l_rep_prj_raw_cost_tab          pa_plsql_datatypes.NumTabTyp;
        l_rep_prj_burdened_cost_tab     pa_plsql_datatypes.NumTabTyp;
        l_rep_prj_revenue_tab           pa_plsql_datatypes.NumTabTyp;
        l_rep_pfc_raw_cost_tab          pa_plsql_datatypes.NumTabTyp;
        l_rep_pfc_burdened_cost_tab     pa_plsql_datatypes.NumTabTyp;
        l_rep_pfc_revenue_tab           pa_plsql_datatypes.NumTabTyp;
        l_rep_quantity_tab              pa_plsql_datatypes.NumTabTyp;
        l_rep_start_date_tab            pa_plsql_datatypes.DateTabTyp;
        l_rep_end_date_tab              pa_plsql_datatypes.DateTabTyp;
        l_rep_period_name_tab           pa_plsql_datatypes.Char30TabTyp;
        l_rep_resAss_id_tab             pa_plsql_datatypes.NumTabTyp;
        l_rep_txn_curr_code_tab         pa_plsql_datatypes.Char30TabTyp;
        l_rep_prj_curr_code_tab         pa_plsql_datatypes.Char30TabTyp;
        l_rep_pfc_curr_code_tab         pa_plsql_datatypes.Char30TabTyp;
        l_rep_called_flag_tab       pa_plsql_datatypes.Char30TabTyp;
    l_rep_cost_rejection_tab    pa_plsql_datatypes.Char30TabTyp;
        l_rep_burden_rejection_tab  pa_plsql_datatypes.Char30TabTyp;
        l_rep_revenue_rejection_tab pa_plsql_datatypes.Char30TabTyp;
        l_rep_pfc_cur_rejection_tab pa_plsql_datatypes.Char30TabTyp;
        l_rep_pc_cur_rejection_tab  pa_plsql_datatypes.Char30TabTyp;

    l_exception_return_status   Varchar2(1) := 'S';
        v_NumErrors         Number := 0;
    V_INDEX_POSITION                Number := 0;
    v_error_code                    Number := 0;
    l_x_cntr            Number := 0;

    l_msg_index_out                 NUMBER;
        l_return_status                 Varchar2(100);
        l_error_msg_code        Varchar2(100);
        l_rep_called_flag           Varchar2(10);
    l_rep_return_status             Varchar2(10);
    l_rep_msg_data              Varchar2(1000);
    l_bl_upd_markup_percentage  Number;
        l_bl_upd_bill_rate      Number;
        l_bl_upd_cost_rate      Number;
        l_bl_upd_burden_rate        Number;
        l_bl_upd_bill_rate_ovride   Number;
        l_bl_upd_cost_rate_ovride   Number;
        l_bl_upd_burden_rate_ovride Number;
        l_bl_upd_compile_set_id     Number;

    l_tmp2_budget_line_id_tab   pa_plsql_datatypes.NumTabTyp;
    l_tmp2_raId_tab         pa_plsql_datatypes.NumTabTyp;
    l_tmp2_sdate_tab        pa_plsql_datatypes.DateTabTyp;
    l_tmp2_txn_curr_code_tab    pa_plsql_datatypes.Char30TabTyp;
        l_tmp2_quantity_tab     pa_plsql_datatypes.NumTabTyp;
        l_tmp2_cost_rejection_tab   pa_plsql_datatypes.Char30TabTyp;
        l_tmp2_revenue_rejection_tab    pa_plsql_datatypes.Char30TabTyp;
        l_tmp2_burden_rejection_tab pa_plsql_datatypes.Char30TabTyp;
        l_tmp2_pfc_cur_rejection_tab    pa_plsql_datatypes.Char30TabTyp;
        l_tmp2_pc_cur_rejection_tab pa_plsql_datatypes.Char30TabTyp;
        l_tmp2_markup_percent_tab   pa_plsql_datatypes.NumTabTyp;
        l_tmp2_bill_rate_tab        pa_plsql_datatypes.NumTabTyp;
        l_tmp2_cost_rate_tab        pa_plsql_datatypes.NumTabTyp;
        l_tmp2_burden_rate_tab      pa_plsql_datatypes.NumTabTyp;
        l_tmp2_bill_rate_ovr_tab    pa_plsql_datatypes.NumTabTyp;
        l_tmp2_cost_rate_ovr_tab    pa_plsql_datatypes.NumTabTyp;
        l_tmp2_burden_rate_ovr_tab  pa_plsql_datatypes.NumTabTyp;
        l_tmp2_compile_set_id_tab   pa_plsql_datatypes.NumTabTyp;
	l_tmp2_rate_based_flag_tab  pa_plsql_datatypes.Char1TabTyp;

    PROCEDURE InitPlsqlTabs IS

    BEGIN
        print_msg('Entered InitPlsqlTabs API');

        /* initialize these plsql tables for bulk exception records*/
        l_err_error_code_tab.delete;
            l_err_budget_line_id_tab.delete;
            l_err_raId_tab.delete;
            l_err_txn_cur_tab.delete;
            l_err_sdate_tab.delete;
            l_err_quantity_tab.delete;
            l_err_cost_rate_tab.delete;
            l_err_cost_rate_ovr_tab.delete;
            l_err_burden_rate_tab.delete;
            l_err_burden_rate_ovr_tab.delete;
            l_err_compiled_set_id_tab.delete;
            l_err_bill_rate_tab.delete;
            l_err_bill_rate_ovr_tab.delete;
            l_err_markup_percent_tab.delete;
            l_err_cost_rejection_tab.delete;
            l_err_revenue_rejection_tab.delete;
            l_err_burden_rejection_tab.delete;
            l_err_pfc_cur_rejection_tab.delete;
            l_err_pc_cur_rejection_tab.delete;

        /* Initialize these plsql tables for budget Lies which needs to updated in bulk after exception
        * records */
        l_tmp2_budget_line_id_tab.delete;
                l_tmp2_raId_tab.delete;
                l_tmp2_sdate_tab.delete;
                l_tmp2_txn_curr_code_tab.delete;
                l_tmp2_quantity_tab.delete;
                l_tmp2_cost_rejection_tab.delete;
                l_tmp2_revenue_rejection_tab.delete;
                l_tmp2_burden_rejection_tab.delete;
                l_tmp2_pfc_cur_rejection_tab.delete;
                l_tmp2_pc_cur_rejection_tab.delete;
                l_tmp2_markup_percent_tab.delete;
                l_tmp2_bill_rate_tab.delete;
                l_tmp2_cost_rate_tab.delete;
                l_tmp2_burden_rate_tab.delete;
                l_tmp2_bill_rate_ovr_tab.delete;
                l_tmp2_cost_rate_ovr_tab.delete;
                l_tmp2_burden_rate_ovr_tab.delete;
                l_tmp2_compile_set_id_tab.delete;
		l_tmp2_rate_based_flag_tab.delete;

        /* Initialize these plsql tables for main rollup rec processing*/
            l_bl_raId_tab.delete;
            l_bl_sDate_tab.delete;
        l_bl_edate_tab.delete;
        l_bl_period_name_tab.delete;
            l_bl_budget_line_id_tab.delete;
            l_bl_txn_curcode_tab.delete;
            l_bl_quantity_tab.delete;
            l_bl_pjfc_raw_cost_tab.delete;
        l_bl_pjfc_burden_cost_tab.delete;
        l_bl_pjfc_revenue_tab.delete;
        l_bl_cost_rejection_tab.delete;
        l_bl_rev_rejection_tab.delete;
        l_bl_burden_rejection_tab.delete;
        l_bl_pfc_cur_rejection_tab.delete;
        l_bl_pc_cur_rejection_tab.delete;
        l_bl_pfc_curcode_tab.delete;
            l_bl_pfc_cost_rate_type_tab.delete;
            l_bl_pfc_cost_exchng_rate_tab.delete;
            l_bl_pfc_cost_date_type_tab.delete;
            l_bl_pfc_cost_date_tab.delete;
            l_bl_pfc_rev_rate_type_tab.delete;
            l_bl_pfc_rev_exchange_rate_tab.delete;
            l_bl_pfc_rev_date_type_tab.delete;
            l_bl_pfc_rev_date_tab.delete;
            l_bl_pc_cur_code_tab.delete;
            l_bl_pc_cost_rate_type_tab.delete;
            l_bl_pc_cost_exchange_rate_tab.delete;
            l_bl_pc_cost_date_type_tab.delete;
            l_bl_pc_cost_date_tab.delete;
            l_bl_project_raw_cost_tab.delete;
            l_bl_project_burdened_cost_tab.delete;
            l_bl_pc_rev_rate_type_tab.delete;
            l_bl_pc_rev_exchange_rate_tab.delete;
            l_bl_pc_rev_date_type_tab.delete;
            l_bl_pc_rev_date_tab.delete;
            l_bl_project_revenue_tab.delete;
            l_bl_txn_raw_cost_tab.delete;
            l_bl_txn_burdened_cost_tab.delete;
            l_bl_txn_revenue_tab.delete;
            l_bl_init_quantity_tab.delete;
            l_bl_txn_init_raw_cost_tab.delete;
            l_bl_txn_init_burden_cost_tab.delete;
            l_bl_txn_init_revenue_tab.delete;
            l_bl_pfc_init_raw_cost_tab.delete;
            l_bl_pfc_init_burden_cost_tab.delete;
            l_bl_pfc_init_revenue_tab.delete;
            l_bl_pc_init_raw_cost_tab.delete;
            l_bl_pc_init_burden_cost_tab.delete;
            l_bl_pc_init_revenue_tab.delete;
            l_bl_markup_percentage_tab.delete;
            l_bl_bill_rate_tab.delete;
            l_bl_cost_rate_tab.delete;
            l_bl_cost_rate_override_tab.delete;
            l_bl_burden_cost_rate_tab.delete;
            l_bl_bill_rate_override_tab.delete;
            l_bl_burden_rate_override_tab.delete;
            l_bl_compiled_set_id_tab.delete;
        l_bl_version_type_tab.delete;
        l_bl_final_txn_cur_code_tab.delete;
        l_bl_CHANGE_REASON_CODE_tab.delete;
            l_bl_DESCRIPTION_tab.delete;
            l_bl_ATTRIBUTE_CATEGORY_tab.delete;
            l_bl_ATTRIBUTE1_tab.delete;
            l_bl_ATTRIBUTE2_tab.delete;
            l_bl_ATTRIBUTE3_tab.delete;
            l_bl_ATTRIBUTE4_tab.delete;
            l_bl_ATTRIBUTE5_tab.delete;
            l_bl_ATTRIBUTE6_tab.delete;
            l_bl_ATTRIBUTE7_tab.delete;
            l_bl_ATTRIBUTE8_tab.delete;
            l_bl_ATTRIBUTE9_tab.delete;
            l_bl_ATTRIBUTE10_tab.delete;
            l_bl_ATTRIBUTE11_tab.delete;
            l_bl_ATTRIBUTE12_tab.delete;
            l_bl_ATTRIBUTE13_tab.delete;
            l_bl_ATTRIBUTE14_tab.delete;
            l_bl_ATTRIBUTE15_tab.delete;
            l_bl_RAW_COST_SOURCE_tab.delete;
            l_bl_BURDENED_COST_SOURCE_tab.delete;
            l_bl_QUANTITY_SOURCE_tab.delete;
            l_bl_REVENUE_SOURCE_tab.delete;
            l_bl_PM_PRODUCT_CODE_tab.delete;
            l_bl_PM_LINE_REFERENCE_tab.delete;
            l_bl_CODE_COMBINATION_ID_tab.delete;
            l_bl_CCID_GEN_STATUS_CODE_tab.delete;
            l_bl_CCID_GEN_REJ_MESSAGE_tab.delete;
            l_bl_BORROWED_REVENUE_tab.delete;
            l_bl_TP_REVENUE_IN_tab.delete;
            l_bl_TP_REVENUE_OUT_tab.delete;
            l_bl_REVENUE_ADJ_tab.delete;
            l_bl_LENT_RESOURCE_COST_tab.delete;
            l_bl_TP_COST_IN_tab.delete;
            l_bl_TP_COST_OUT_tab.delete;
            l_bl_COST_ADJ_tab.delete;
            l_bl_UNASSIGNED_TIME_COST_tab.delete;
            l_bl_UTILIZATION_PERCENT_tab.delete;
            l_bl_UTILIZATION_HOURS_tab.delete;
            l_bl_UTILIZATION_ADJ_tab.delete;
            l_bl_CAPACITY_tab.delete;
            l_bl_HEAD_COUNT_tab.delete;
            l_bl_HEAD_COUNT_ADJ_tab.delete;
            l_bl_BUCKETING_PERIOD_CODE_tab.delete;
            l_bl_TXN_DISCOUNT_PERCENT_tab.delete;
            l_bl_TRANSFER_PRICE_RATE_tab.delete;
            l_bl_BL_CREATED_BY_tab.delete;
            l_bl_BL_CREATION_DATE_tab.delete;
	    l_rate_base_flag_tab.delete;
    END InitPlsqlTabs;

    PROCEDURE Populate_tmp2Plsql_tab IS

    BEGIN
        print_msg('Entered Populate_tmp2Plsql_tab API');
        SELECT tmp2.budget_line_id
            ,tmp2.resource_assignment_id
            ,tmp2.start_date
            ,tmp2.txn_currency_code
            ,tmp2.quantity
            ,tmp2.system_reference_var1   --tmp2.cost_rejection_code
            ,tmp2.system_reference_var2   --tmp2.revenue_rejection_code
            ,tmp2.system_reference_var3   --tmp2.burden_rejection_code
            ,tmp2.system_reference_var4   --tmp2.pfc_cur_conv_rejection_code
            ,tmp2.system_reference_var5   --tmp2.pc_cur_conv_rejection_code
            ,tmp2.bill_markup_percentage
            ,tmp2.bill_rate
            ,tmp2.cost_rate
            ,tmp2.burden_cost_rate
                    ,tmp2.bill_rate_override
                    ,tmp2.cost_rate_override
                    ,tmp2.burden_cost_rate_override
                    ,tmp2.system_reference_num1  --tmp2.compile_set_id
		,NVL(ra.rate_based_flag,'N') /* bug fix: 4900436 */
        BULK COLLECT INTO
            l_tmp2_budget_line_id_tab
            ,l_tmp2_raId_tab
            ,l_tmp2_sdate_tab
            ,l_tmp2_txn_curr_code_tab
                    ,l_tmp2_quantity_tab
                    ,l_tmp2_cost_rejection_tab
                    ,l_tmp2_revenue_rejection_tab
                    ,l_tmp2_burden_rejection_tab
                    ,l_tmp2_pfc_cur_rejection_tab
                    ,l_tmp2_pc_cur_rejection_tab
                    ,l_tmp2_markup_percent_tab
                    ,l_tmp2_bill_rate_tab
                    ,l_tmp2_cost_rate_tab
                    ,l_tmp2_burden_rate_tab
                    ,l_tmp2_bill_rate_ovr_tab
                    ,l_tmp2_cost_rate_ovr_tab
                    ,l_tmp2_burden_rate_ovr_tab
                    ,l_tmp2_compile_set_id_tab
		    ,l_tmp2_rate_based_flag_tab /* bug fix: 4900436 */
	FROM pa_fp_spread_calc_tmp2 tmp2
            ,pa_resource_assignments ra
        WHERE tmp2.budget_version_id = p_budget_version_id
        AND ra.resource_assignment_id = tmp2.resource_assignment_id;
    END Populate_tmp2Plsql_tab;


    /* This API will inserts the bulk exceptions records into tmp1 table
    * later this tmp1 table will be used for populating tmp2 table with budget line
    * details in bulk
    */
    PROCEDURE Populate_blkExcpRecs
                        (p_budget_version_id            IN Number
                        ,p_err_error_code_tab           IN pa_plsql_datatypes.char30TabTyp
                        ,p_err_budget_line_id_tab       IN pa_plsql_datatypes.NumTabTyp
                        ,p_err_raId_tab                 IN pa_plsql_datatypes.NumTabTyp
                        ,p_err_txn_cur_tab              IN pa_plsql_datatypes.char30TabTyp
                        ,p_err_sdate_tab                IN pa_plsql_datatypes.DateTabTyp
                        ,p_err_quantity_tab             IN pa_plsql_datatypes.NumTabTyp
                        ,p_err_cost_rate_tab            IN pa_plsql_datatypes.NumTabTyp
                        ,p_err_cost_rate_ovr_tab        IN pa_plsql_datatypes.NumTabTyp
                        ,p_err_burden_rate_tab          IN pa_plsql_datatypes.NumTabTyp
                        ,p_err_burden_rate_ovr_tab      IN pa_plsql_datatypes.NumTabTyp
                        ,p_err_compiled_set_id_tab      IN pa_plsql_datatypes.NumTabTyp
                        ,p_err_bill_rate_tab            IN pa_plsql_datatypes.NumTabTyp
                        ,p_err_bill_rate_ovr_tab        IN pa_plsql_datatypes.NumTabTyp
                        ,p_err_markup_percent_tab       IN pa_plsql_datatypes.NumTabTyp
                        ,p_err_cost_rejection_tab       IN pa_plsql_datatypes.char30TabTyp
                        ,p_err_revenue_rejection_tab    IN pa_plsql_datatypes.char30TabTyp
                        ,p_err_burden_rejection_tab     IN pa_plsql_datatypes.char30TabTyp
                        ,p_err_pfc_cur_rejection_tab    IN pa_plsql_datatypes.char30TabTyp
                        ,p_err_pc_cur_rejection_tab     IN pa_plsql_datatypes.char30TabTyp
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ) IS
    BEGIN
        x_return_status := 'S';
        print_msg('Entered Populate_blkExcpRecs API');
        DELETE FROM PA_FP_SPREAD_CALC_TMP1;
        FORALL i IN p_err_error_code_tab.FIRST .. p_err_error_code_tab.LAST
            INSERT INTO PA_FP_SPREAD_CALC_TMP1 tmp
        (tmp.budget_line_id
         ,tmp.budget_version_id
                 ,tmp.resource_assignment_id
                 ,tmp.txn_currency_code
                 ,tmp.start_date
                 ,tmp.quantity
                 ,tmp.cost_rate
                 ,tmp.cost_rate_override
                 ,tmp.burden_cost_rate
                 ,tmp.burden_cost_rate_override
                 ,tmp.cost_ind_compiled_set_id
                 ,tmp.bill_rate
                 ,tmp.bill_rate_override
                 ,tmp.bill_markup_percentage
                 ,tmp.cost_rejection_code
                 ,tmp.revenue_rejection_code
                 ,tmp.burden_rejection_code
                 ,tmp.pfc_cur_conv_rejection_code
                 ,tmp.pc_cur_conv_rejection_code
        )
            SELECT p_err_budget_line_id_tab(i)
         ,p_budget_version_id
                 ,p_err_raId_tab(i)
                 ,p_err_txn_cur_tab(i)
                 ,p_err_sdate_tab(i)
                 ,p_err_quantity_tab(i)
                 ,p_err_cost_rate_tab(i)
                 ,p_err_cost_rate_ovr_tab(i)
                 ,p_err_burden_rate_tab(i)
                 ,p_err_burden_rate_ovr_tab(i)
                 ,p_err_compiled_set_id_tab(i)
                 ,p_err_bill_rate_tab(i)
                 ,p_err_bill_rate_ovr_tab(i)
                 ,p_err_markup_percent_tab(i)
                 ,p_err_cost_rejection_tab(i)
                 ,p_err_revenue_rejection_tab(i)
                 ,p_err_burden_rejection_tab(i)
                 ,p_err_pfc_cur_rejection_tab(i)
                 ,p_err_pc_cur_rejection_tab(i)
        FROM DUAL
        WHERE p_err_error_code_tab(i) = 1 ;
         print_msg('Number of rows inserted ['||sql%rowcount||']');
            print_msg('Leaving populate spread calc tmp1 API with retSts['||x_return_status||']');

    EXCEPTION
            WHEN OTHERS THEN
                    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                    fnd_msg_pub.add_exc_msg
                    ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                    ,p_procedure_name => 'Populate_blkExcpRecs' );
                    print_msg('Exception from Populate_blkExcpRecs ['||substr(SQLERRM,1,240));
                    RAISE;

    END Populate_blkExcpRecs;

    /* This API will populate exisiting budget line details(Dup val on index records) into
    * into tmp2 table. Later this table will be used for bulk update of budget lines
    * and rollup tmp tables
    */
    PROCEDURE Populate_ExistingBlRecs
                        (p_budget_version_id            IN Number
                        ,x_return_status                OUT NOCOPY Varchar2
                        ) IS
    BEGIN
            x_return_status := 'S';
        print_msg('Entered Populate_ExistingBlRecs API');
            DELETE FROM PA_FP_SPREAD_CALC_TMP2;
                INSERT INTO PA_FP_SPREAD_CALC_TMP2 tmp
                (tmp.budget_line_id
                 ,tmp.budget_version_id
                 ,tmp.resource_assignment_id
                 ,tmp.txn_currency_code
                 ,tmp.start_date
                 ,tmp.quantity
                 ,tmp.cost_rate
                 ,tmp.cost_rate_override
                 ,tmp.burden_cost_rate
                 ,tmp.burden_cost_rate_override
                 ,tmp.system_reference_num1  --tmp.compiled_set_id
                 ,tmp.bill_rate
                 ,tmp.bill_rate_override
                 ,tmp.bill_markup_percentage
                 ,tmp.system_reference_var1  --tmp.cost_rejection_code
                 ,tmp.system_reference_var2  --tmp.revenue_rejection_code
                 ,tmp.system_reference_var3  --tmp.burden_rejection_code
                 ,tmp.system_reference_var4  --tmp.pfc_cur_conv_rejection_code
                 ,tmp.system_reference_var5  --tmp.pc_cur_conv_rejection_code
             ,tmp.project_currency_code
             ,tmp.projfunc_currency_code
                )
            SELECT bl.budget_line_id
                 ,bl.budget_version_id
                 ,bl.resource_assignment_id
                 ,bl.txn_currency_code
                 ,bl.start_date
                 ,bl.quantity
                 ,bl.txn_standard_cost_rate
                 ,bl.txn_cost_rate_override
                 ,bl.burden_cost_rate
                 ,bl.burden_cost_rate_override
                 ,bl.cost_ind_compiled_set_id
                 ,bl.txn_standard_bill_rate
                 ,bl.txn_bill_rate_override
                 ,bl.txn_markup_percent
                 ,bl.cost_rejection_code
                 ,bl.revenue_rejection_code
                 ,bl.burden_rejection_code
                 ,bl.pfc_cur_conv_rejection_code
                 ,bl.pc_cur_conv_rejection_code
             ,bl.project_currency_code
             ,bl.projfunc_currency_code
                FROM pa_budget_lines bl
                WHERE bl.budget_version_id = p_budget_version_id
            AND EXISTS (select  null
            From pa_fp_spread_calc_tmp1 tmp1
            where tmp1.budget_version_id = p_budget_version_id
            and  tmp1.resource_assignment_id = bl.resource_assignment_id
            and  tmp1.txn_currency_code = bl.txn_currency_code
            and  tmp1.start_date = bl.start_date
            );
        print_msg('Number of lines inserted['||sql%Rowcount||']');

        /* Now store the existing budget line id on tmp1 table to read the values
        * from both tables */
        UPDATE pa_fp_spread_calc_tmp1 tmp1
        SET tmp1.system_reference_num1 = (select tmp2.budget_line_id
                      from pa_fp_spread_calc_tmp2 tmp2
                      where tmp2.budget_version_id = p_budget_version_id
                      and tmp2.resource_assignment_id = tmp1.resource_assignment_id
                      and  tmp2.txn_currency_code = tmp1.txn_currency_code
                      and  tmp2.start_date = tmp1.start_date
                     )
        WHERE tmp1.budget_version_id = p_budget_version_id;
        print_msg('Number of lines updated['||sql%Rowcount||']');
            print_msg('Leaving populate spread calc tmp2 API with retSts['||x_return_status||']');

    EXCEPTION
            WHEN OTHERS THEN
                    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                    fnd_msg_pub.add_exc_msg
                    ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                    ,p_procedure_name => 'Populate_ExistingBlRecs' );
                    print_msg('Exception from Populate_ExistingBlRecs api['|| substr(SQLERRM,1,240));
                    RAISE;

    END Populate_ExistingBlRecs;

BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_return_status := 'S';
    If p_pa_debug_mode = 'Y' Then
            pa_debug.init_err_stack('PA_FP_CALC_PLAN_PKG.BLK_update_budget_lines');
    End If;
	IF P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Entered PA_FP_CALC_PLAN_PKG.BLK_update_budget_lines');
	End If;
        l_stage             := 4000;
    InitPlsqlTabs;
    OPEN Cur_RollupLines;
    FETCH Cur_RollupLines BULK COLLECT INTO
            l_bl_raId_tab
            ,l_bl_sDate_tab
        ,l_bl_edate_tab
        ,l_bl_period_name_tab
            ,l_bl_budget_line_id_tab
            ,l_bl_txn_curcode_tab
            ,l_bl_quantity_tab
            ,l_bl_pjfc_raw_cost_tab
        ,l_bl_pjfc_burden_cost_tab
        ,l_bl_pjfc_revenue_tab
        ,l_bl_cost_rejection_tab
        ,l_bl_rev_rejection_tab
        ,l_bl_burden_rejection_tab
        ,l_bl_pfc_cur_rejection_tab
        ,l_bl_pc_cur_rejection_tab
        ,l_bl_pfc_curcode_tab
            ,l_bl_pfc_cost_rate_type_tab
            ,l_bl_pfc_cost_exchng_rate_tab
            ,l_bl_pfc_cost_date_type_tab
            ,l_bl_pfc_cost_date_tab
            ,l_bl_pfc_rev_rate_type_tab
            ,l_bl_pfc_rev_exchange_rate_tab
            ,l_bl_pfc_rev_date_type_tab
            ,l_bl_pfc_rev_date_tab
            ,l_bl_pc_cur_code_tab
            ,l_bl_pc_cost_rate_type_tab
            ,l_bl_pc_cost_exchange_rate_tab
            ,l_bl_pc_cost_date_type_tab
            ,l_bl_pc_cost_date_tab
            ,l_bl_project_raw_cost_tab
            ,l_bl_project_burdened_cost_tab
            ,l_bl_pc_rev_rate_type_tab
            ,l_bl_pc_rev_exchange_rate_tab
            ,l_bl_pc_rev_date_type_tab
            ,l_bl_pc_rev_date_tab
            ,l_bl_project_revenue_tab
            ,l_bl_txn_raw_cost_tab
            ,l_bl_txn_burdened_cost_tab
            ,l_bl_txn_revenue_tab
            ,l_bl_init_quantity_tab
            ,l_bl_txn_init_raw_cost_tab
            ,l_bl_txn_init_burden_cost_tab
            ,l_bl_txn_init_revenue_tab
            ,l_bl_pfc_init_raw_cost_tab
            ,l_bl_pfc_init_burden_cost_tab
            ,l_bl_pfc_init_revenue_tab
            ,l_bl_pc_init_raw_cost_tab
            ,l_bl_pc_init_burden_cost_tab
            ,l_bl_pc_init_revenue_tab
            ,l_bl_markup_percentage_tab
            ,l_bl_bill_rate_tab
            ,l_bl_cost_rate_tab
            ,l_bl_cost_rate_override_tab
            ,l_bl_burden_cost_rate_tab
            ,l_bl_bill_rate_override_tab
            ,l_bl_burden_rate_override_tab
            ,l_bl_compiled_set_id_tab
        ,l_bl_version_type_tab
        ,l_bl_final_txn_cur_code_tab
        ,l_bl_CHANGE_REASON_CODE_tab
            ,l_bl_DESCRIPTION_tab
            ,l_bl_ATTRIBUTE_CATEGORY_tab
            ,l_bl_ATTRIBUTE1_tab
            ,l_bl_ATTRIBUTE2_tab
            ,l_bl_ATTRIBUTE3_tab
            ,l_bl_ATTRIBUTE4_tab
            ,l_bl_ATTRIBUTE5_tab
            ,l_bl_ATTRIBUTE6_tab
            ,l_bl_ATTRIBUTE7_tab
            ,l_bl_ATTRIBUTE8_tab
            ,l_bl_ATTRIBUTE9_tab
            ,l_bl_ATTRIBUTE10_tab
            ,l_bl_ATTRIBUTE11_tab
            ,l_bl_ATTRIBUTE12_tab
            ,l_bl_ATTRIBUTE13_tab
            ,l_bl_ATTRIBUTE14_tab
            ,l_bl_ATTRIBUTE15_tab
            ,l_bl_RAW_COST_SOURCE_tab
            ,l_bl_BURDENED_COST_SOURCE_tab
            ,l_bl_QUANTITY_SOURCE_tab
            ,l_bl_REVENUE_SOURCE_tab
            ,l_bl_PM_PRODUCT_CODE_tab
            ,l_bl_PM_LINE_REFERENCE_tab
            ,l_bl_CODE_COMBINATION_ID_tab
            ,l_bl_CCID_GEN_STATUS_CODE_tab
            ,l_bl_CCID_GEN_REJ_MESSAGE_tab
            ,l_bl_BORROWED_REVENUE_tab
            ,l_bl_TP_REVENUE_IN_tab
            ,l_bl_TP_REVENUE_OUT_tab
            ,l_bl_REVENUE_ADJ_tab
            ,l_bl_LENT_RESOURCE_COST_tab
            ,l_bl_TP_COST_IN_tab
            ,l_bl_TP_COST_OUT_tab
            ,l_bl_COST_ADJ_tab
            ,l_bl_UNASSIGNED_TIME_COST_tab
            ,l_bl_UTILIZATION_PERCENT_tab
            ,l_bl_UTILIZATION_HOURS_tab
            ,l_bl_UTILIZATION_ADJ_tab
            ,l_bl_CAPACITY_tab
            ,l_bl_HEAD_COUNT_tab
            ,l_bl_HEAD_COUNT_ADJ_tab
            ,l_bl_BUCKETING_PERIOD_CODE_tab
            ,l_bl_TXN_DISCOUNT_PERCENT_tab
            ,l_bl_TRANSFER_PRICE_RATE_tab
            ,l_bl_BL_CREATED_BY_tab
            ,l_bl_BL_CREATION_DATE_tab
	    ,l_rate_base_flag_tab;
    CLOSE Cur_RollupLines;

    IF l_bl_budget_line_id_tab.COUNT > 0 THEN  --{
           <<NEW_BUDGET_LINE>>
	IF P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Entered NEW_BUDGET_LINE block');
	End If;
        BEGIN
            /* Call the update reporting line by passing -ve amounts of the existsing budgetline
             * before update and +ve amounts of budget line after update. so that the delta passing to the reporting
             * will be always in synch with the budget lines
                     */
                IF NVL(g_rollup_required_flag,'N') = 'Y'  THEN
            FOR blRec IN cur_blAmts LOOP
              IF blRec.budget_line_id is NOT NULL Then
                    --print_msg('Getting Budget line Amts for budget_line_id => '||to_char(blrec.budget_line_id));
                    l_stage := 4028;
                --print_msg('Calling Add_Toreporting_Tabls api by old -ve amts of bl['||(blRec.quantity * -1)||']Cur['||blRec.txn_currency_code||']');
                PA_FP_CALC_PLAN_PKG.Add_Toreporting_Tabls
                        (p_calling_module               => 'CALCULATE_API'
                        ,p_activity_code                => 'UPDATE'
                        ,p_budget_version_id            => p_budget_version_id
                        ,p_budget_line_id               => blRec.budget_line_id
                        ,p_resource_assignment_id       => blRec.resource_assignment_id
                        ,p_start_date                   => blRec.start_date
                        ,p_end_date                     => blRec.end_date
                        ,p_period_name                  => blRec.period_name
                        ,p_txn_currency_code            => blRec.txn_currency_code
                        ,p_quantity                     => blRec.quantity * -1
                        ,p_txn_raw_cost                 => blRec.txn_raw_cost * -1
                        ,p_txn_burdened_cost            => blRec.txn_burdened_cost * -1
                        ,p_txn_revenue                  => blRec.txn_revenue * -1
                        ,p_project_currency_code        => blRec.project_currency_code
                        ,p_project_raw_cost             => blRec.project_raw_cost * -1
                        ,p_project_burdened_cost        => blRec.project_burdened_cost * -1
                        ,p_project_revenue              => blRec.project_revenue * -1
                        ,p_projfunc_currency_code       => blRec.projfunc_currency_code
                        ,p_projfunc_raw_cost            => blRec.projfunc_raw_cost * -1
                        ,p_projfunc_burdened_cost       => blRec.projfunc_burdened_cost * -1
                        ,p_projfunc_revenue             => blRec.projfunc_revenue * -1
			,p_rep_line_mode               => 'REVERSAL'
                	,x_msg_data                     => l_rep_msg_data
                        ,x_return_status                => l_rep_return_status
                        );
                --print_msg('After Calling update_reporting_from_b_lines for BdLine['||blRec.budget_line_id||']');
                --print_msg('RtSts['||l_rep_return_status||']x_msgData['||l_rep_msg_data||']');
                    IF l_rep_return_status <> 'S' Then
                    l_error_msg_code := l_rep_msg_data;
                    EXIT;
                END IF;
                   END IF;
             END LOOP;
          END IF ; -- g_rollup requried = Y

            /* update budget line with the new currency and amounts If there budget line is already with
        * the same currency the update will fail with duplicate value on index.
        * in such case update the existing budget line and overrwrite all the amounts
        * with the new bugdetlines
        */
        --print_msg('Bulk updating budget lines');
        /* Now Bulk Update the budget Lines */
        FORALL i IN l_bl_budget_line_id_tab.FIRST .. l_bl_budget_line_id_tab.LAST  SAVE EXCEPTIONS
            UPDATE pa_budget_lines bl
        SET bl.txn_currency_code             = l_bl_txn_curcode_tab(i)
                 ,bl.quantity                        = l_bl_quantity_tab(i)
		 /* Bug fix:4900436 */
                 ,bl.display_quantity                = decode(g_wp_version_flag,'Y',l_bl_quantity_tab(i)
                                                         ,Decode(l_rate_base_flag_tab(i),'N',NULL,l_bl_quantity_tab(i)))
                 /* End of bug fix:4900436 */
                 ,bl.raw_cost                        = l_bl_pjfc_raw_cost_tab(i)
                 ,bl.burdened_cost                   = l_bl_pjfc_burden_cost_tab(i)
                 ,bl.revenue                         = l_bl_pjfc_revenue_tab(i)
                 ,bl.cost_rejection_code             = l_bl_cost_rejection_tab(i)
                 ,bl.revenue_rejection_code          = l_bl_rev_rejection_tab(i)
                 ,bl.burden_rejection_code           = l_bl_burden_rejection_tab(i)
                 ,bl.pfc_cur_conv_rejection_code     = l_bl_pfc_cur_rejection_tab(i)
                 ,bl.pc_cur_conv_rejection_code      = l_bl_pc_cur_rejection_tab(i)
                 ,bl.projfunc_currency_code          = l_bl_pfc_curcode_tab(i)
                 ,bl.projfunc_cost_rate_type         = l_bl_pfc_cost_rate_type_tab(i)
                 ,bl.projfunc_cost_exchange_rate     = l_bl_pfc_cost_exchng_rate_tab(i)
                 ,bl.projfunc_cost_rate_date_type    = l_bl_pfc_cost_date_type_tab(i)
                 ,bl.projfunc_cost_rate_date         = l_bl_pfc_cost_date_tab(i)
                 ,bl.projfunc_rev_rate_type          = l_bl_pfc_rev_rate_type_tab(i)
                 ,bl.projfunc_rev_exchange_rate      = l_bl_pfc_rev_exchange_rate_tab(i)
                 ,bl.projfunc_rev_rate_date_type     = l_bl_pfc_rev_date_type_tab(i)
                 ,bl.projfunc_rev_rate_date          = l_bl_pfc_rev_date_tab(i)
                 ,bl.project_currency_code           = l_bl_pc_cur_code_tab(i)
                 ,bl.project_cost_rate_type          = l_bl_pc_cost_rate_type_tab(i)
                 ,bl.project_cost_exchange_rate      = l_bl_pc_cost_exchange_rate_tab(i)
                 ,bl.project_cost_rate_date_type     = l_bl_pc_cost_date_type_tab(i)
                 ,bl.project_cost_rate_date          = l_bl_pc_cost_date_tab(i)
                 ,bl.project_raw_cost                = l_bl_project_raw_cost_tab(i)
                 ,bl.project_burdened_cost           = l_bl_project_burdened_cost_tab(i)
                 ,bl.project_rev_rate_type           = l_bl_pc_rev_rate_type_tab(i)
                 ,bl.project_rev_exchange_rate       = l_bl_pc_rev_exchange_rate_tab(i)
                 ,bl.project_rev_rate_date_type      = l_bl_pc_rev_date_type_tab(i)
                 ,bl.project_rev_rate_date           = l_bl_pc_rev_date_tab(i)
                 ,bl.project_revenue                 = l_bl_project_revenue_tab(i)
                 ,bl.txn_raw_cost                    = l_bl_txn_raw_cost_tab(i)
                 ,bl.txn_burdened_cost               = l_bl_txn_burdened_cost_tab(i)
                 ,bl.txn_revenue                     = l_bl_txn_revenue_tab(i)
                 ,bl.txn_markup_percent              = l_bl_markup_percentage_tab(i)
                 ,bl.txn_standard_bill_rate          = l_bl_bill_rate_tab(i)
                 ,bl.txn_standard_cost_rate          = l_bl_cost_rate_tab(i)
                 ,bl.txn_cost_rate_override          = l_bl_cost_rate_override_tab(i)
                 ,bl.burden_cost_rate                = l_bl_burden_cost_rate_tab(i)
                 ,bl.txn_bill_rate_override          = l_bl_bill_rate_override_tab(i)
                 ,bl.burden_cost_rate_override       = l_bl_burden_rate_override_tab(i)
                 ,bl.cost_ind_compiled_set_id        = l_bl_compiled_set_id_tab(i)
                 ,bl.last_update_date                = l_sysdate           ---sysdate
                 ,bl.last_updated_by                 = l_last_updated_by   ---fnd_global.user_id
                 ,bl.last_update_login               = l_last_login_id     ---fnd_global.login_id
                 ,bl.CHANGE_REASON_CODE = l_bl_CHANGE_REASON_CODE_tab(i)     /*Bug4224464 Removed the nvl checks from dff's
                  ,change reason code, PM_PRODUCT_CODE, PM_BUDGET_LINE_REFERENCE, and description columns. The cursor
                  definitions in copy_blattributes have been modified to handle the G_MISS_XXX values for these columns.*/
                 ,bl.DESCRIPTION = l_bl_DESCRIPTION_tab(i)
                 ,bl.ATTRIBUTE_CATEGORY = l_bl_ATTRIBUTE_CATEGORY_tab(i)
                 ,bl.ATTRIBUTE1 = l_bl_ATTRIBUTE1_tab(i)
                 ,bl.ATTRIBUTE2 = l_bl_ATTRIBUTE2_tab(i)
                 ,bl.ATTRIBUTE3 = l_bl_ATTRIBUTE3_tab(i)
                 ,bl.ATTRIBUTE4 = l_bl_ATTRIBUTE4_tab(i)
                 ,bl.ATTRIBUTE5 = l_bl_ATTRIBUTE5_tab(i)
                 ,bl.ATTRIBUTE6 = l_bl_ATTRIBUTE6_tab(i)
                 ,bl.ATTRIBUTE7 = l_bl_ATTRIBUTE7_tab(i)
                 ,bl.ATTRIBUTE8 = l_bl_ATTRIBUTE8_tab(i)
                 ,bl.ATTRIBUTE9 = l_bl_ATTRIBUTE9_tab(i)
                 ,bl.ATTRIBUTE10 = l_bl_ATTRIBUTE10_tab(i)
                 ,bl.ATTRIBUTE11 = l_bl_ATTRIBUTE11_tab(i)
                 ,bl.ATTRIBUTE12 = l_bl_ATTRIBUTE12_tab(i)
                 ,bl.ATTRIBUTE13 = l_bl_ATTRIBUTE13_tab(i)
                 ,bl.ATTRIBUTE14 = l_bl_ATTRIBUTE14_tab(i)
                 ,bl.ATTRIBUTE15 = l_bl_ATTRIBUTE15_tab(i)
                 ,bl.RAW_COST_SOURCE = nvl(l_bl_RAW_COST_SOURCE_tab(i),bl.RAW_COST_SOURCE)
                 ,bl.BURDENED_COST_SOURCE = nvl(l_bl_BURDENED_COST_SOURCE_tab(i),bl.BURDENED_COST_SOURCE)
                 ,bl.QUANTITY_SOURCE = nvl(l_bl_QUANTITY_SOURCE_tab(i),bl.QUANTITY_SOURCE)
                 ,bl.REVENUE_SOURCE = nvl(l_bl_REVENUE_SOURCE_tab(i),bl.REVENUE_SOURCE)
                 ,bl.PM_PRODUCT_CODE = l_bl_PM_PRODUCT_CODE_tab(i)
                 ,bl.PM_BUDGET_LINE_REFERENCE = l_bl_PM_LINE_REFERENCE_tab(i)
                 ,bl.CODE_COMBINATION_ID = nvl(l_bl_CODE_COMBINATION_ID_tab(i),bl.CODE_COMBINATION_ID)
                 ,bl.CCID_GEN_STATUS_CODE = nvl(l_bl_CCID_GEN_STATUS_CODE_tab(i),bl.CCID_GEN_STATUS_CODE)
                 ,bl.CCID_GEN_REJ_MESSAGE = nvl(l_bl_CCID_GEN_REJ_MESSAGE_tab(i),bl.CCID_GEN_REJ_MESSAGE)
                 ,bl.BORROWED_REVENUE = nvl(l_bl_BORROWED_REVENUE_tab(i),bl.BORROWED_REVENUE)
                 ,bl.TP_REVENUE_IN = nvl(l_bl_TP_REVENUE_IN_tab(i),bl.TP_REVENUE_IN)
                 ,bl.TP_REVENUE_OUT = nvl(l_bl_TP_REVENUE_OUT_tab(i),bl.TP_REVENUE_OUT)
                 ,bl.REVENUE_ADJ  = nvl(l_bl_REVENUE_ADJ_tab(i),bl.REVENUE_ADJ)
                 ,bl.LENT_RESOURCE_COST = nvl(l_bl_LENT_RESOURCE_COST_tab(i),bl.LENT_RESOURCE_COST)
                 ,bl.TP_COST_IN   = nvl(l_bl_TP_COST_IN_tab(i),bl.TP_COST_IN)
                 ,bl.TP_COST_OUT = nvl(l_bl_TP_COST_OUT_tab(i),bl.TP_COST_OUT)
                 ,bl.COST_ADJ = nvl(l_bl_COST_ADJ_tab(i),bl.COST_ADJ)
                 ,bl.UNASSIGNED_TIME_COST = nvl(l_bl_UNASSIGNED_TIME_COST_tab(i),bl.UNASSIGNED_TIME_COST)
                 ,bl.UTILIZATION_PERCENT = nvl(l_bl_UTILIZATION_PERCENT_tab(i),bl.UTILIZATION_PERCENT)
                 ,bl.UTILIZATION_HOURS = nvl(l_bl_UTILIZATION_HOURS_tab(i),bl.UTILIZATION_HOURS)
                 ,bl.UTILIZATION_ADJ = nvl(l_bl_UTILIZATION_ADJ_tab(i),bl.UTILIZATION_ADJ)
                 ,bl.CAPACITY = nvl(l_bl_CAPACITY_tab(i),bl.CAPACITY)
                 ,bl.HEAD_COUNT = nvl(l_bl_HEAD_COUNT_tab(i),bl.HEAD_COUNT)
                 ,bl.HEAD_COUNT_ADJ =nvl(l_bl_HEAD_COUNT_ADJ_tab(i),bl.HEAD_COUNT_ADJ)
                 ,bl.BUCKETING_PERIOD_CODE = nvl(l_bl_BUCKETING_PERIOD_CODE_tab(i),bl.BUCKETING_PERIOD_CODE)
                 ,bl.TXN_DISCOUNT_PERCENTAGE = nvl(l_bl_TXN_DISCOUNT_PERCENT_tab(i),bl.TXN_DISCOUNT_PERCENTAGE)
                 ,bl.TRANSFER_PRICE_RATE = nvl(l_bl_TRANSFER_PRICE_RATE_tab(i),bl.TRANSFER_PRICE_RATE)
                 ,bl.CREATED_BY   = nvl(l_bl_BL_CREATED_BY_tab(i),bl.CREATED_BY)
                 ,bl.CREATION_DATE   = nvl(l_bl_BL_CREATION_DATE_tab(i),bl.CREATION_DATE)
            WHERE bl.budget_line_id  = l_bl_budget_line_id_tab(i);
        /* Bug fix: returning clause is taking more time performance hit so commenting it out
        RETURNING bl.budget_line_id
                        ,bl.txn_raw_cost
                        ,bl.txn_burdened_cost
                        ,bl.txn_revenue
                        ,bl.project_raw_cost
                        ,bl.project_burdened_cost
                        ,bl.project_revenue
                        ,bl.raw_cost      --projfunc_raw_cost
                        ,bl.burdened_cost --projfunc_burdened_cost
                        ,bl.revenue       --projfunc_revenue
                        ,bl.quantity
                        ,bl.start_date
                        ,bl.end_date
                        ,bl.period_name
                        ,bl.resource_assignment_id
                        ,bl.txn_currency_code
                        ,bl.project_currency_code
                        ,bl.projfunc_currency_code
                        ,bl.cost_rejection_code
                        ,bl.burden_rejection_code
                        ,bl.revenue_rejection_code
                        ,bl.pfc_cur_conv_rejection_code
                        ,bl.pc_cur_conv_rejection_code
        BULK COLLECT INTO
                        l_rep_budget_line_id_tab
                        ,l_rep_txn_raw_cost_tab
                        ,l_rep_txn_burdened_cost_tab
                        ,l_rep_txn_revenue_tab
                        ,l_rep_prj_raw_cost_tab
                        ,l_rep_prj_burdened_cost_tab
                        ,l_rep_prj_revenue_tab
                        ,l_rep_pfc_raw_cost_tab
                        ,l_rep_pfc_burdened_cost_tab
                        ,l_rep_pfc_revenue_tab
                        ,l_rep_quantity_tab
                        ,l_rep_start_date_tab
                        ,l_rep_end_date_tab
                        ,l_rep_period_name_tab
                        ,l_rep_resAss_id_tab
                        ,l_rep_txn_curr_code_tab
                        ,l_rep_prj_curr_code_tab
                        ,l_rep_pfc_curr_code_tab
                        ,l_rep_cost_rejection_tab
                        ,l_rep_burden_rejection_tab
                        ,l_rep_revenue_rejection_tab
                        ,l_rep_pfc_cur_rejection_tab
                        ,l_rep_pc_cur_rejection_tab ;
         ***/
        --print_msg('Number of rows bulk updated ['||sql%rowcount||']');
        /* now pass the +ve values for the updated budget lines based on the processed flag from the tmp table */
                IF NVL(g_rollup_required_flag,'N') = 'Y'  THEN
                  FOR blRec IN cur_blAmts LOOP
                   IF blRec.budget_line_id is NOT NULL Then
                       --print_msg('Getting Budget line Amts for budget_line_id => '||to_char(blrec.budget_line_id));
                       l_stage := 4022;
                       --print_msg('Calling Add_Toreporting_Tabls api by sending old +ve amts of bl['||(blRec.quantity)||']Cur['||blRec.txn_currency_code||']');
                       PA_FP_CALC_PLAN_PKG.Add_Toreporting_Tabls
                       (p_calling_module               => 'CALCULATE_API'
                       ,p_activity_code                => 'UPDATE'
                       ,p_budget_version_id            => p_budget_version_id
                       ,p_budget_line_id               => blRec.budget_line_id
                       ,p_resource_assignment_id       => blRec.resource_assignment_id
                       ,p_start_date                   => blRec.start_date
                       ,p_end_date                     => blRec.end_date
                       ,p_period_name                  => blRec.period_name
                       ,p_txn_currency_code            => blRec.txn_currency_code
                       ,p_quantity                     => blRec.quantity
                       ,p_txn_raw_cost                 => blRec.txn_raw_cost
                       ,p_txn_burdened_cost            => blRec.txn_burdened_cost
                       ,p_txn_revenue                  => blRec.txn_revenue
                       ,p_project_currency_code        => blRec.project_currency_code
                       ,p_project_raw_cost             => blRec.project_raw_cost
                       ,p_project_burdened_cost        => blRec.project_burdened_cost
                       ,p_project_revenue              => blRec.project_revenue
                       ,p_projfunc_currency_code       => blRec.projfunc_currency_code
                       ,p_projfunc_raw_cost            => blRec.projfunc_raw_cost
                       ,p_projfunc_burdened_cost       => blRec.projfunc_burdened_cost
                       ,p_projfunc_revenue             => blRec.projfunc_revenue
		       ,p_rep_line_mode               => 'POSITIVE_ENTRY'
                       ,x_msg_data                     => l_rep_msg_data
                       ,x_return_status                => l_rep_return_status
                       );
                       --print_msg('After Calling update_reporting_from_b_lines for BdLine['||blRec.budget_line_id||']');
                       --print_msg('RtSts['||l_rep_return_status||']x_msgData['||l_rep_msg_data||']');
                       IF l_rep_return_status <> 'S' Then
                            l_error_msg_code := l_rep_msg_data;
                            EXIT;
                       END IF;
                    END IF;
                   END LOOP;
                END IF ; -- g_rollup requried = Y
        /* Note If there is any dup val on index exception then control goes to exception portion
        * so the same call has to make in the exception portion alos */
            --print_msg('End of bulk budget Lines update ');

        EXCEPTION
          WHEN OTHERS THEN
        print_msg('Entered bulk exception portion');
        /* Now process the exceptions lines one-by-one */
        l_exception_return_status := 'S';
            v_NumErrors := SQL%BULK_EXCEPTIONS.COUNT;
        l_x_cntr := 0;
        FOR v_Count IN 1..v_NumErrors LOOP   --{
            l_x_cntr := l_x_cntr +1;
                v_index_position  :=SQL%BULK_EXCEPTIONS(v_Count).error_index;
                v_error_code      :=SQL%BULK_EXCEPTIONS(v_Count).error_code;
            l_err_error_code_tab(l_x_cntr)  := SQL%BULK_EXCEPTIONS(v_Count).error_code;
            l_err_budget_line_id_tab(l_x_cntr)  := l_bl_budget_line_id_tab(v_index_position);
            l_err_raId_tab(l_x_cntr)        := l_bl_raId_Tab(v_index_position);
            l_err_txn_cur_tab(l_x_cntr)     := l_bl_txn_curcode_tab(v_index_position);
            l_err_sdate_tab(l_x_cntr)       := l_bl_sdate_tab(v_index_position);
            l_err_quantity_tab(l_x_cntr)    := l_bl_quantity_tab(v_index_position);
            l_err_cost_rate_tab(l_x_cntr)   := l_bl_cost_rate_tab(v_index_position);
            l_err_cost_rate_ovr_tab(l_x_cntr)   := l_bl_cost_rate_override_tab(v_index_position);
            l_err_burden_rate_tab(l_x_cntr)     := l_bl_burden_cost_rate_tab(v_index_position);
            l_err_burden_rate_ovr_tab(l_x_cntr) := l_bl_burden_rate_override_tab(v_index_position);
            l_err_compiled_set_id_tab(l_x_cntr) := l_bl_compiled_set_id_tab(v_index_position);
            l_err_bill_rate_tab(l_x_cntr)   := l_bl_bill_rate_tab(v_index_position);
            l_err_bill_rate_ovr_tab(l_x_cntr)   := l_bl_bill_rate_override_tab(v_index_position);
            l_err_markup_percent_tab(l_x_cntr)  := l_bl_markup_percentage_tab(v_index_position);
            l_err_cost_rejection_tab(l_x_cntr)  := l_bl_cost_rejection_tab(v_index_position);
            l_err_revenue_rejection_tab(l_x_cntr) :=l_bl_rev_rejection_tab(v_index_position);
            l_err_burden_rejection_tab(l_x_cntr) := l_bl_burden_rejection_tab(v_index_position);
            l_err_pfc_cur_rejection_tab(l_x_cntr) := l_bl_pfc_cur_rejection_tab(v_index_position);
            l_err_pc_cur_rejection_tab(l_x_cntr) := l_bl_pc_cur_rejection_tab(v_index_position);

                If v_error_code <> 1 then -- 1 means unique constraint voilation.
            l_exception_return_status := 'U';
            l_return_status := 'U';
            x_return_status := l_exception_return_status;
            l_error_msg_code := SQLERRM(0 - SQL%BULK_EXCEPTIONS(v_Count).error_code);
            -- add error message to stack and finall raise the error
            PA_UTILS.ADD_MESSAGE
                        (p_app_short_name => 'PA'
            ,p_msg_name       => v_error_code||'-'||l_error_msg_code
                    ,p_token1         => 'G_PROJECT_NAME'
                    ,p_value1         => g_project_name
                    ,p_token2         => 'G_RESOURCE_ASSIGNMENT_ID'
                    ,p_value2         => l_err_raId_tab(l_x_cntr)
                    ,p_token3         => 'G_TXN_CURRENCY_CODE'
                    ,p_value3         => l_err_txn_cur_tab(l_x_cntr)
            ,p_token4         => 'G_BUDGET_LINE_ID'
            ,p_value4         => l_err_budget_line_id_tab(l_x_cntr)
            );
            End If;

        END LOOP; --}
        END ;

        /* Now process the exception records in bulk */
       <<EXISTING_BUDGET_LINES>>
        IF l_exception_return_status = 'S' AND l_err_error_code_tab.COUNT > 0 THEN --{
	IF P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Entered EXISTING_BUDGET_LINES block:NUM ROWS UPTD['||l_rep_budget_line_id_tab.COUNT||']REJECTED['||l_err_budget_line_id_tab.COUNT||']');
	End If;

        /*We should pass the +ve values for the updated rows. having returning clause in the bulk update returns the
                 * rejected records with the updated values, so the returning clause cannot be used. In order to pass the correct bl values
                 * update the rollup tmp processed flag with N for the rejected records */
        FORALL i IN l_err_error_code_tab.FIRST .. l_err_error_code_tab.LAST
        UPDATE PA_FP_ROLLUP_TMP tmp
        SET tmp.processed_flag = 'N'
        WHERE tmp.budget_line_id = l_err_budget_line_id_tab(i);
                /* now pass the +ve values for the updated budget lines based on the processed flag from the tmp table */
                IF NVL(g_rollup_required_flag,'N') = 'Y'  THEN
                  FOR blRec IN cur_blAmts LOOP
                   IF blRec.budget_line_id is NOT NULL Then
                       --print_msg('Getting Budget line Amts for budget_line_id => '||to_char(blrec.budget_line_id));
                       l_stage := 4028;
                       --print_msg('Calling Add_Toreporting_Tabls api by sending old +ve amts of bl['||(blRec.quantity)||']Cur['||blRec.txn_currency_code||']');
                       PA_FP_CALC_PLAN_PKG.Add_Toreporting_Tabls
                       (p_calling_module               => 'CALCULATE_API'
                       ,p_activity_code                => 'UPDATE'
                       ,p_budget_version_id            => p_budget_version_id
                       ,p_budget_line_id               => blRec.budget_line_id
                       ,p_resource_assignment_id       => blRec.resource_assignment_id
                       ,p_start_date                   => blRec.start_date
                       ,p_end_date                     => blRec.end_date
                       ,p_period_name                  => blRec.period_name
                       ,p_txn_currency_code            => blRec.txn_currency_code
                       ,p_quantity                     => blRec.quantity
                       ,p_txn_raw_cost                 => blRec.txn_raw_cost
                       ,p_txn_burdened_cost            => blRec.txn_burdened_cost
                       ,p_txn_revenue                  => blRec.txn_revenue
                       ,p_project_currency_code        => blRec.project_currency_code
                       ,p_project_raw_cost             => blRec.project_raw_cost
                       ,p_project_burdened_cost        => blRec.project_burdened_cost
                       ,p_project_revenue              => blRec.project_revenue
                       ,p_projfunc_currency_code       => blRec.projfunc_currency_code
                       ,p_projfunc_raw_cost            => blRec.projfunc_raw_cost
                       ,p_projfunc_burdened_cost       => blRec.projfunc_burdened_cost
                       ,p_projfunc_revenue             => blRec.projfunc_revenue
		       	,p_rep_line_mode               => 'REVERSAL'  -- special case passing reversal of reversal entries
                       ,x_msg_data                     => l_rep_msg_data
                       ,x_return_status                => l_rep_return_status
                       );
                       --print_msg('After Calling update_reporting_from_b_lines for BdLine['||blRec.budget_line_id||']');
                       --print_msg('RtSts['||l_rep_return_status||']x_msgData['||l_rep_msg_data||']');
                       IF l_rep_return_status <> 'S' Then
                            l_error_msg_code := l_rep_msg_data;
                            EXIT;
                       END IF;
                    END IF;
                   END LOOP;
                END IF ; -- g_rollup requried = Y
                /* Note If there is any dup val on index exception then control comes here. so partly updated budget lines
                * must be passed to rollup api with +ve values */
        /* Now populate tmp1 table with bulk exception records */
        --print_msg('Calling Populate_blkExcpRecs ');
        Populate_blkExcpRecs
            (p_budget_version_id        => p_budget_version_id
            ,p_err_error_code_tab       =>l_err_error_code_tab
            ,p_err_budget_line_id_tab   =>l_err_budget_line_id_tab
                        ,p_err_raId_tab         =>l_err_raId_tab
                        ,p_err_txn_cur_tab      =>l_err_txn_cur_tab
                        ,p_err_sdate_tab        =>l_err_sdate_tab
                        ,p_err_quantity_tab     =>l_err_quantity_tab
                        ,p_err_cost_rate_tab        =>l_err_cost_rate_tab
                        ,p_err_cost_rate_ovr_tab    =>l_err_cost_rate_ovr_tab
                        ,p_err_burden_rate_tab      =>l_err_burden_rate_tab
                        ,p_err_burden_rate_ovr_tab  =>l_err_burden_rate_ovr_tab
                        ,p_err_compiled_set_id_tab  =>l_err_compiled_set_id_tab
                        ,p_err_bill_rate_tab        =>l_err_bill_rate_tab
                        ,p_err_bill_rate_ovr_tab    =>l_err_bill_rate_ovr_tab
                        ,p_err_markup_percent_tab   =>l_err_markup_percent_tab
                        ,p_err_cost_rejection_tab   =>l_err_cost_rejection_tab
                        ,p_err_revenue_rejection_tab    =>l_err_revenue_rejection_tab
                        ,p_err_burden_rejection_tab =>l_err_burden_rejection_tab
                        ,p_err_pfc_cur_rejection_tab    =>l_err_pfc_cur_rejection_tab
                        ,p_err_pc_cur_rejection_tab =>l_err_pc_cur_rejection_tab
            ,x_return_status        => x_return_status
            );

        /* Now populate the tmp2 with exisiting budget line details */
        --print_msg('Calling Populate_ExistingBlRecs ');
        Populate_ExistingBlRecs
            (p_budget_version_id            => p_budget_version_id
            ,x_return_status                => x_return_status
                        );

        /* Before updating the existing budgetLines, we need to pass the -ve entries to rollup api */
        IF NVL(g_rollup_required_flag,'N') = 'Y'  THEN
                     FOR blRec IN cur_ExistingblAmts LOOP
                          IF blRec.budget_line_id is NOT NULL Then
                            --print_msg('Getting Budget line Amts for budget_line_id => '||to_char(blrec.budget_line_id));
                            l_stage := 4028;
                            --print_msg('Calling Add_Toreporting_Tabls by old -ve amts of bl['||(blRec.quantity *-1)||']Cur['||blRec.txn_currency_code||']');
                            PA_FP_CALC_PLAN_PKG.Add_Toreporting_Tabls
                                (p_calling_module               => 'CALCULATE_API'
                                ,p_activity_code                => 'UPDATE'
                                ,p_budget_version_id            => p_budget_version_id
                                ,p_budget_line_id               => blRec.budget_line_id
                                ,p_resource_assignment_id       => blRec.resource_assignment_id
                                ,p_start_date                   => blRec.start_date
                                ,p_end_date                     => blRec.end_date
                                ,p_period_name                  => blRec.period_name
                                ,p_txn_currency_code            => blRec.txn_currency_code
                                ,p_quantity                     => blRec.quantity * -1
                                ,p_txn_raw_cost                 => blRec.txn_raw_cost * -1
                                ,p_txn_burdened_cost            => blRec.txn_burdened_cost * -1
                                ,p_txn_revenue                  => blRec.txn_revenue * -1
                                ,p_project_currency_code        => blRec.project_currency_code
                                ,p_project_raw_cost             => blRec.project_raw_cost * -1
                                ,p_project_burdened_cost        => blRec.project_burdened_cost * -1
                                ,p_project_revenue              => blRec.project_revenue * -1
                                ,p_projfunc_currency_code       => blRec.projfunc_currency_code
                                ,p_projfunc_raw_cost            => blRec.projfunc_raw_cost * -1
                                ,p_projfunc_burdened_cost       => blRec.projfunc_burdened_cost * -1
                                ,p_projfunc_revenue             => blRec.projfunc_revenue * -1
				,p_rep_line_mode               => 'REVERSAL'
                                ,x_msg_data                     => l_rep_msg_data
                                ,x_return_status                => l_rep_return_status
                                );
                            --print_msg('After Calling update_reporting_from_b_lines for BdLine['||blRec.budget_line_id||']');
                            --print_msg('RtSts['||l_rep_return_status||']x_msgData['||l_rep_msg_data||']');
                            IF l_rep_return_status <> 'S' Then
                                 l_error_msg_code := l_rep_msg_data;
                                 EXIT;
                            END IF;
                       END IF;
                   END LOOP;
               END IF ; -- g_rollup requried = Y

           /* Now process the exception records. update the tmp2 with the final quantity , rates and rejections
                * and then finally in one bulk update the budget lines */
           FOR newRec IN cur_errorBdgtLines LOOP

        print_msg('Updating the budgetline with Existsing bl['||newRec.Existing_budget_line_id||']');
        OPEN cur_Tmp2ExblAmts(newRec.Existing_budget_line_id);
        FETCH cur_Tmp2ExblAmts INTO ExBlRec;
        CLOSE cur_Tmp2ExblAmts;

        /* Rounding enhancements:  While updating budget lines, instead of deriving the override rate use the following logic
         * to derive the rates and amounts
         * OldBdgetLine                NewBdgtLine              Resultant
         * --------------------------------------------------------------------------------------
         * 1.Ovrride rate exists      Ovrride rate exists   Use New BdgtLine Override rate
         * 2.Ovrride rate exists      No Override rate          Use Old BdgtLine Override rate
                 * 3.No Override rate         Ovrride rate exists       Use New BdgtLine Override rate
         * 4.No Override rate         No Override rate      Use New BdgtLine rate
         * ---------------------------------------------------------------------------------------
         */

        If newRec.cost_rate_override is NOT NULL Then
            l_bl_upd_cost_rate := newRec.cost_rate_override;
            l_bl_upd_cost_rate_ovride := newRec.cost_rate_override;
        Elsif ExBlRec.existing_cost_rate_ovride IS NOT NULL Then
            l_bl_upd_cost_rate := ExBlRec.existing_cost_rate_ovride;
                        l_bl_upd_cost_rate_ovride := ExBlRec.existing_cost_rate_ovride;
        Else
            l_bl_upd_cost_rate := newRec.cost_rate;
                        l_bl_upd_cost_rate_ovride := NULL;
        End If;

        If newRec.burden_cost_rate_override is NOT NULL Then
            l_bl_upd_burden_rate := newRec.burden_cost_rate_override;
            l_bl_upd_burden_rate_ovride := newRec.burden_cost_rate_override;
            l_bl_upd_compile_set_id := newRec.cost_ind_compiled_set_id;
        Elsif ExBlRec.existing_burden_rate_ovride is NOT NULL Then
            l_bl_upd_burden_rate := ExBlRec.existing_burden_rate_ovride;
                        l_bl_upd_burden_rate_ovride := ExBlRec.existing_burden_rate_ovride;
            l_bl_upd_compile_set_id := ExBlRec.existing_compile_set_id;
        Else
            l_bl_upd_burden_rate := newRec.burden_cost_rate;
                        l_bl_upd_burden_rate_ovride := NULL;
            l_bl_upd_compile_set_id := newRec.cost_ind_compiled_set_id;
        End If;

        If newRec.bill_rate_override is NOT NULL Then
            l_bl_upd_bill_rate := newRec.bill_rate_override;
            l_bl_upd_bill_rate_ovride := newRec.bill_rate_override;
            l_bl_upd_markup_percentage := newRec.bill_markup_percentage;
        Elsif ExBlRec.existing_bill_rate_ovride is NOT NULL Then
            l_bl_upd_bill_rate := ExBlRec.existing_bill_rate_ovride;
                        l_bl_upd_bill_rate_ovride :=ExBlRec.existing_bill_rate_ovride;
            l_bl_upd_markup_percentage := ExBlRec.existing_markup_percentage;
        Else
            l_bl_upd_bill_rate := newRec.bill_rate;
                        l_bl_upd_bill_rate_ovride := NULL;
            l_bl_upd_markup_percentage := newRec.bill_markup_percentage;
        End If;


            UPDATE pa_fp_spread_calc_tmp2 tmp2
        SET tmp2.txn_currency_code              = newRec.txn_currency_code
                 ,tmp2.quantity                         = nvl(tmp2.quantity,0) + newRec.quantity
                 ,tmp2.system_reference_var1        = newRec.cost_rejection_code
                 ,tmp2.system_reference_var2        = newRec.revenue_rejection_code
                 ,tmp2.system_reference_var3        = newRec.burden_rejection_code
                 ,tmp2.system_reference_var4        = newRec.pfc_cur_conv_rejection_code
                 ,tmp2.system_reference_var5        = newRec.pc_cur_conv_rejection_code
                 ,tmp2.bill_markup_percentage           = l_bl_upd_markup_percentage
                 ,tmp2.bill_rate                = l_bl_upd_bill_rate
                 ,tmp2.cost_rate                = l_bl_upd_cost_rate
                 ,tmp2.burden_cost_rate                 = l_bl_upd_burden_rate
                 ,tmp2.bill_rate_override           = l_bl_upd_bill_rate_ovride
                 ,tmp2.cost_rate_override           = l_bl_upd_cost_rate_ovride
                 ,tmp2.burden_cost_rate_override        = l_bl_upd_burden_rate_ovride
                 ,tmp2.system_reference_num1            = l_bl_upd_compile_set_id
            WHERE tmp2.budget_line_id  = ExBlRec.Existing_budget_line_id;

         END LOOP;


         /* Now update the budgetLines in bulk from tmp2 table */
         Populate_tmp2Plsql_tab;
         IF l_tmp2_budget_line_id_tab.COUNT > 0 THEN --{
        --print_msg('Bulk updating dup val index exception rows');
        FORALL i IN l_tmp2_budget_line_id_tab.FIRST .. l_tmp2_budget_line_id_tab.LAST
        UPDATE pa_budget_lines bl
                SET bl.txn_currency_code             = l_tmp2_txn_curr_code_tab(i)
                 ,bl.quantity                        = l_tmp2_quantity_tab(i)
		 /* Bug fix:4900436 */
                 ,bl.display_quantity                = decode(g_wp_version_flag,'Y',l_tmp2_quantity_tab(i)
                                                         ,decode(NVL(l_tmp2_rate_based_flag_tab(i),'N'),'N',NULL
							   	,l_tmp2_quantity_tab(i)))
                 /* Bug fix:4900436 */
                 ,bl.cost_rejection_code             = l_tmp2_cost_rejection_tab(i)
                 ,bl.revenue_rejection_code          = l_tmp2_revenue_rejection_tab(i)
                 ,bl.burden_rejection_code           = l_tmp2_burden_rejection_tab(i)
                 ,bl.pfc_cur_conv_rejection_code     = l_tmp2_pfc_cur_rejection_tab(i)
                 ,bl.pc_cur_conv_rejection_code      = l_tmp2_pc_cur_rejection_tab(i)
                 ,bl.txn_markup_percent              = l_tmp2_markup_percent_tab(i)
                 ,bl.txn_standard_bill_rate          = l_tmp2_bill_rate_tab(i)
                 ,bl.txn_standard_cost_rate          = l_tmp2_cost_rate_tab(i)
                 ,bl.burden_cost_rate                = l_tmp2_burden_rate_tab(i)
                 ,bl.txn_bill_rate_override          = l_tmp2_bill_rate_ovr_tab(i)
                 ,bl.txn_cost_rate_override          = l_tmp2_cost_rate_ovr_tab(i)
                 ,bl.burden_cost_rate_override       = l_tmp2_burden_rate_ovr_tab(i)
                 ,bl.cost_ind_compiled_set_id        = l_tmp2_compile_set_id_tab(i)
                 ,bl.last_update_date                = l_sysdate
                 ,bl.last_updated_by                 = l_last_updated_by
                 ,bl.last_update_login               = l_last_login_id
                WHERE bl.budget_line_id  = l_tmp2_budget_line_id_tab(i);

            --print_msg(' Num Of rows UPDATED ['||sql%rowcount||']');
        FORALL i IN l_tmp2_budget_line_id_tab.FIRST .. l_tmp2_budget_line_id_tab.LAST
                UPDATE pa_budget_lines bl
                SET bl.txn_raw_cost = decode((nvl(bl.txn_init_raw_cost,0) + pa_currency.round_trans_currency_amt1(
                                        (nvl(bl.quantity,0) - nvl(bl.init_quantity,0)) *
                                        (nvl(bl.txn_cost_rate_override,nvl(txn_standard_cost_rate,0))),bl.txn_currency_code)),0,NULL,
                    (nvl(bl.txn_init_raw_cost,0) + pa_currency.round_trans_currency_amt1(
                    (nvl(bl.quantity,0) - nvl(bl.init_quantity,0)) *
                    (nvl(bl.txn_cost_rate_override,nvl(txn_standard_cost_rate,0))),bl.txn_currency_code)))
           ,bl.txn_burdened_cost = decode((nvl(bl.txn_init_burdened_cost,0) + pa_currency.round_trans_currency_amt1(
                                        (nvl(bl.quantity,0) - nvl(bl.init_quantity,0)) *
                                        (nvl(bl.burden_cost_rate_override,nvl(burden_cost_rate,0))),bl.txn_currency_code)),0,NULL,
                                        (nvl(bl.txn_init_burdened_cost,0) + pa_currency.round_trans_currency_amt1(
                                        (nvl(bl.quantity,0) - nvl(bl.init_quantity,0)) *
                                        (nvl(bl.burden_cost_rate_override,nvl(burden_cost_rate,0))),bl.txn_currency_code)))
           ,bl.txn_revenue = decode((nvl(bl.txn_init_raw_cost,0) + pa_currency.round_trans_currency_amt1(
                                        (nvl(bl.quantity,0) - nvl(bl.init_quantity,0)) *
                                        (nvl(bl.txn_bill_rate_override,nvl(txn_standard_bill_rate,0))),bl.txn_currency_code)),0,NULL,
                                        (nvl(bl.txn_init_raw_cost,0) + pa_currency.round_trans_currency_amt1(
                                        (nvl(bl.quantity,0) - nvl(bl.init_quantity,0)) *
                                        (nvl(bl.txn_bill_rate_override,nvl(txn_standard_bill_rate,0))),bl.txn_currency_code)))
                WHERE bl.budget_line_id  = l_tmp2_budget_line_id_tab(i);

        /* Call the pc and pfc conv attributes for this budget line */
            FOR exBlId IN l_tmp2_budget_line_id_tab.FIRST .. l_tmp2_budget_line_id_tab.LAST LOOP
            --print_msg('Calling pa_fp_multi_currency_pkg.convert_txn_currency api()');
                    pa_fp_multi_currency_pkg.convert_txn_currency
                        ( p_budget_version_id         => g_budget_version_id
             ,p_budget_line_id            => l_tmp2_budget_line_id_tab(exBlId)
                         ,p_source_context            => 'BUDGET_LINE'
                         ,p_entire_version            => 'Y'
                         ,p_calling_module              => p_calling_module -- Added for Bug#5395732
                         ,x_return_status             => l_return_status
                         ,x_msg_count                 => x_msg_count
                         ,x_msg_data                  => x_msg_data
                         );
            -- Note the return status of converttxn currn need not checked as the rejections will be stamped on budgetLines
                    --print_msg('End of convert_txn_currency api retSts['||l_return_status||']');
        END LOOP;

           /* Now delete the exception records from budget lines */
        InitPlsqlTabs;
        l_del_budget_line_id_tab.delete;
        OPEN cur_delBlLines;
        FETCH cur_delBlLines BULK COLLECT INTO l_del_budget_line_id_tab;
        CLOSE cur_delBlLines;
        IF l_del_budget_line_id_tab.COUNT > 0 THEN  --{
        /* MRC enhancements */
        IF NVL(l_populate_mrc_tab_flag,'N') = 'Y' Then
            FORALL i IN l_del_budget_line_id_tab.FIRST .. l_del_budget_line_id_tab.LAST
            UPDATE pa_fp_rollup_tmp tmp
            SET tmp.delete_flag = 'Y'
        WHERE tmp.budget_line_id = l_del_budget_line_id_tab(i);
        END IF;

        /* Now delete the duplval budget lines */
            FORALL i IN l_del_budget_line_id_tab.FIRST .. l_del_budget_line_id_tab.LAST
                DELETE FROM pa_budget_lines bl
                WHERE bl.budget_line_id = l_del_budget_line_id_tab(i);
         END IF; --}

    /* MRC ehancements changes: */
    IF NVL(l_populate_mrc_tab_flag,'N') = 'Y' AND l_tmp2_budget_line_id_tab.COUNT > 0 THEN --{
	/* update rollup data with existing budget lines data */
        FORALL exBlId IN l_tmp2_budget_line_id_tab.FIRST .. l_tmp2_budget_line_id_tab.LAST
        UPDATE pa_fp_rollup_tmp tmp
        SET ( tmp.quantity
             ,tmp.txn_raw_cost
             ,tmp.txn_burdened_cost
             ,tmp.txn_revenue
             ,tmp.project_raw_cost
             ,tmp.project_burdened_cost
             ,tmp.project_revenue
             ,tmp.projfunc_raw_cost
             ,tmp.projfunc_burdened_cost
             ,tmp.projfunc_revenue
             ,tmp.project_cost_rate_type
             ,tmp.project_cost_exchange_rate
             ,tmp.project_cost_rate_date_type
             ,tmp.project_cost_rate_date
             ,tmp.project_rev_rate_type
             ,tmp.project_rev_exchange_rate
             ,tmp.project_rev_rate_date_type
             ,tmp.project_rev_rate_date
             ,tmp.projfunc_cost_rate_type
             ,tmp.projfunc_cost_exchange_rate
             ,tmp.projfunc_cost_rate_date_type
             ,tmp.projfunc_cost_rate_date
             ,tmp.projfunc_rev_rate_type
             ,tmp.projfunc_rev_exchange_rate
             ,tmp.projfunc_rev_rate_date_type
             ,tmp.projfunc_rev_rate_date
           ) =
          (SELECT bl.quantity
              ,bl.txn_raw_cost
              ,bl.txn_burdened_cost
              ,bl.txn_revenue
              ,bl.project_raw_cost
              ,bl.project_burdened_cost
              ,bl.project_revenue
              ,bl.raw_cost
              ,bl.burdened_cost
              ,bl.revenue
              ,bl.project_cost_rate_type
              ,bl.project_cost_exchange_rate
              ,bl.project_cost_rate_date_type
              ,bl.project_cost_rate_date
              ,bl.project_rev_rate_type
              ,bl.project_rev_exchange_rate
              ,bl.project_rev_rate_date_type
              ,bl.project_rev_rate_date
              ,bl.projfunc_cost_rate_type
              ,bl.projfunc_cost_exchange_rate
              ,bl.projfunc_cost_rate_date_type
              ,bl.projfunc_cost_rate_date
              ,bl.projfunc_rev_rate_type
              ,bl.projfunc_rev_exchange_rate
              ,bl.projfunc_rev_rate_date_type
              ,bl.projfunc_rev_rate_date
          FROM pa_budget_lines bl
          WHERE bl.budget_line_id = tmp.budget_line_id
          )
        WHERE tmp.budget_line_id = l_tmp2_budget_line_id_tab(exBlId);

	/* Copy the rows from budget lines to rollup tmp when existing budget line id doesnot exists in rollup tmp */
	FORALL exBlId IN l_tmp2_budget_line_id_tab.FIRST .. l_tmp2_budget_line_id_tab.LAST
        INSERT INTO  pa_fp_rollup_tmp tmp
            ( tmp.budget_line_id
	     ,tmp.budget_version_id
	     ,tmp.resource_assignment_id
	     ,tmp.txn_currency_code
	     ,tmp.start_date
	     ,tmp.end_date
	     ,tmp.period_name
	     ,tmp.quantity
             ,tmp.txn_raw_cost
             ,tmp.txn_burdened_cost
             ,tmp.txn_revenue
             ,tmp.project_raw_cost
             ,tmp.project_burdened_cost
             ,tmp.project_revenue
             ,tmp.projfunc_raw_cost
             ,tmp.projfunc_burdened_cost
             ,tmp.projfunc_revenue
             ,tmp.project_cost_rate_type
             ,tmp.project_cost_exchange_rate
             ,tmp.project_cost_rate_date_type
             ,tmp.project_cost_rate_date
             ,tmp.project_rev_rate_type
             ,tmp.project_rev_exchange_rate
             ,tmp.project_rev_rate_date_type
             ,tmp.project_rev_rate_date
             ,tmp.projfunc_cost_rate_type
             ,tmp.projfunc_cost_exchange_rate
             ,tmp.projfunc_cost_rate_date_type
             ,tmp.projfunc_cost_rate_date
             ,tmp.projfunc_rev_rate_type
             ,tmp.projfunc_rev_exchange_rate
             ,tmp.projfunc_rev_rate_date_type
             ,tmp.projfunc_rev_rate_date
           )
	SELECT bl.budget_line_id
	     ,bl.budget_version_id
             ,bl.resource_assignment_id
             ,bl.txn_currency_code
             ,bl.start_date
             ,bl.end_date
             ,bl.period_name
	     ,bl.quantity
             ,bl.txn_raw_cost
             ,bl.txn_burdened_cost
             ,bl.txn_revenue
             ,bl.project_raw_cost
             ,bl.project_burdened_cost
             ,bl.project_revenue
             ,bl.raw_cost
             ,bl.burdened_cost
             ,bl.revenue
             ,bl.project_cost_rate_type
             ,bl.project_cost_exchange_rate
             ,bl.project_cost_rate_date_type
             ,bl.project_cost_rate_date
             ,bl.project_rev_rate_type
             ,bl.project_rev_exchange_rate
             ,bl.project_rev_rate_date_type
             ,bl.project_rev_rate_date
             ,bl.projfunc_cost_rate_type
             ,bl.projfunc_cost_exchange_rate
             ,bl.projfunc_cost_rate_date_type
             ,bl.projfunc_cost_rate_date
             ,bl.projfunc_rev_rate_type
             ,bl.projfunc_rev_exchange_rate
             ,bl.projfunc_rev_rate_date_type
             ,bl.projfunc_rev_rate_date
          FROM pa_budget_lines bl
          WHERE bl.budget_line_id = l_tmp2_budget_line_id_tab(exBlId)
	  AND NOT EXISTS ( SELECT NULL
			   FROM PA_FP_ROLLUP_TMP tmp1
			   WHERE tmp1.budget_line_id = l_tmp2_budget_line_id_tab(exBlId)
			);

    END IF; --}

        /* Now pass the +ve values for the updated existing budget Lines */
        IF NVL(g_rollup_required_flag,'N') = 'Y'  THEN
                     FOR blRec IN cur_ExistingblAmts LOOP
                          IF blRec.budget_line_id is NOT NULL Then
                                l_stage := 4028;
                                --print_msg('Calling ExistAdd_Toreporting_Tabls api by New +ve amts of bl qty['||blRec.quantity||']cur['||blRec.txn_currency_code||']');
                                PA_FP_CALC_PLAN_PKG.Add_Toreporting_Tabls
                                (p_calling_module               => 'CALCULATE_API'
                                ,p_activity_code                => 'UPDATE'
                                ,p_budget_version_id            => p_budget_version_id
                                ,p_budget_line_id               => blRec.budget_line_id
                                ,p_resource_assignment_id       => blRec.resource_assignment_id
                                ,p_start_date                   => blRec.start_date
                                ,p_end_date                     => blRec.end_date
                                ,p_period_name                  => blRec.period_name
                                ,p_txn_currency_code            => blRec.txn_currency_code
                                ,p_quantity                     => blRec.quantity
                                ,p_txn_raw_cost                 => blRec.txn_raw_cost
                                ,p_txn_burdened_cost            => blRec.txn_burdened_cost
                                ,p_txn_revenue                  => blRec.txn_revenue
                                ,p_project_currency_code        => blRec.project_currency_code
                                ,p_project_raw_cost             => blRec.project_raw_cost
                                ,p_project_burdened_cost        => blRec.project_burdened_cost
                                ,p_project_revenue              => blRec.project_revenue
                                ,p_projfunc_currency_code       => blRec.projfunc_currency_code
                                ,p_projfunc_raw_cost            => blRec.projfunc_raw_cost
                                ,p_projfunc_burdened_cost       => blRec.projfunc_burdened_cost
                                ,p_projfunc_revenue             => blRec.projfunc_revenue
				,p_rep_line_mode                => 'POSITIVE_ENTRY'
                                ,x_msg_data                     => l_rep_msg_data
                                ,x_return_status                => l_rep_return_status
                                );
                                --print_msg('After Calling update_reporting_from_b_lines for BdLine['||blRec.budget_line_id||']');
                                --print_msg('RtSts['||l_rep_return_status||']x_msgData['||l_rep_msg_data||']');
                                IF l_rep_return_status <> 'S' Then
                                        l_error_msg_code := l_rep_msg_data;
                                        EXIT;
                                END IF;
                       END IF;
                   END LOOP;
               END IF ; -- g_rollup requried = Y
         END IF; --}
       END IF; --}  -- end of existing budget Line

       /* Now release the buffer */
       InitPlsqlTabs;
    END IF; --}  -- end of New budget Line
    x_return_status := l_return_status;
        print_msg('Leaving BLK_update_budget_lines:x_return_status : '||x_return_status);
    If p_pa_debug_mode = 'Y' Then
            pa_debug.reset_err_stack;
    End If;

EXCEPTION
    WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data := SQLCODE||SQLERRM;
            fnd_msg_pub.add_exc_msg
            ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                ,p_procedure_name => 'BLK_update_budget_lines' );
            pa_debug.g_err_stage := 'Stage : '||to_char(l_stage)||' '||substr(SQLERRM,1,240);
            l_stage := 4120;
            print_msg(to_char(l_stage)||' substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
        If p_pa_debug_mode = 'Y' Then
                pa_debug.reset_err_stack;
        End If;
            RAISE;

END BLK_update_budget_lines;


/*Bug 4224464.This procedure update_dffcols would be called to insert into pa_fp_rollup_tmp
 * all those budget lines which are not already present in pa_fp_rollup_tmp.
 * These lines would be the ones with no changes to qty/amnt and rate columns.
 * The lines with changes to qty/amnt and rate columns would not be processed by this API
 * as earlier call to copy_blattributes would have handled theselines  Also using the
 * same signature for this API as used for copy_blattributes above.
 */
PROCEDURE update_dffcols(
                 p_budget_verson_id               IN  Number
                ,p_source_context                 IN  Varchar2
                ,p_calling_module                 IN  Varchar2
                ,p_apply_progress_flag            IN Varchar2
                ,x_return_status                  OUT NOCOPY varchar2
                ,x_msg_count                      OUT NOCOPY NUMBER
                ,x_msg_data                       OUT NOCOPY varchar2
                 ) IS

        /* This cursor picks budget line attributes which needs to be retained and updated even if there was no change detected by
           core calculate api flow -- that is, no qty/amt/rate changed */
        CURSOR blAttribDetails IS
        SELECT /*+ INDEX(BL PA_BUDGET_LINES_U1) */ cache.resource_assignment_id
              ,cache.start_date
              ,cache.period_name
              ,cache.end_Date
              ,cache.budget_version_id
              ,bl.budget_line_id
              ,bl.quantity
              ,bl.txn_raw_cost
              ,bl.txn_burdened_cost
              ,bl.txn_revenue
              ,bl.init_quantity
              ,bl.txn_init_raw_cost
              ,bl.txn_init_burdened_cost
              ,bl.txn_init_revenue
              ,bl.txn_cost_rate_override
              ,bl.burden_cost_rate_override
              ,bl.txn_bill_rate_override
              ,bl.raw_cost
              ,bl.burdened_cost
              ,bl.revenue
              ,bl.cost_rejection_code
              ,bl.revenue_rejection_code
              ,bl.burden_rejection_code
              ,bl.project_raw_cost
              ,bl.project_burdened_cost
              ,bl.project_revenue
              ,bl.txn_markup_percent
              ,bl.txn_standard_bill_rate
              ,bl.txn_standard_cost_rate
              ,bl.burden_cost_rate
              ,bl.cost_ind_compiled_set_id
              ,bl.init_raw_cost
              ,bl.init_burdened_cost
              ,bl.init_revenue
              ,bl.project_init_raw_cost
              ,bl.project_init_burdened_cost
              ,bl.project_init_revenue
              ,cache.txn_currency_code
              ,cache.projfunc_currency_code
              ,cache.PROJECT_CURRENCY_CODE
              ,decode(cache.PROJECT_COST_RATE_TYPE,      null, bl.PROJECT_COST_RATE_TYPE, FND_API.G_MISS_CHAR, null, cache.PROJECT_COST_RATE_TYPE)
              ,decode(cache.PROJECT_COST_EXCHANGE_RATE,  null, bl.project_cost_exchange_rate, FND_API.G_MISS_NUM, null, cache.PROJECT_COST_EXCHANGE_RATE)
              ,decode(cache.PROJECT_COST_RATE_DATE_TYPE, null, bl.project_cost_rate_date_type, FND_API.G_MISS_CHAR, null, cache.PROJECT_COST_RATE_DATE_TYPE)
              ,decode(cache.PROJECT_COST_RATE_DATE,      null, bl.project_cost_rate_date, FND_API.G_MISS_DATE, null, cache.PROJECT_COST_RATE_DATE)
              ,decode(cache.PROJECT_REV_RATE_TYPE,       null, bl.project_rev_rate_type, FND_API.G_MISS_CHAR, null, cache.PROJECT_REV_RATE_TYPE)
              ,decode(cache.PROJECT_REV_EXCHANGE_RATE,   null, bl.project_rev_exchange_rate, FND_API.G_MISS_NUM, null, cache.PROJECT_REV_EXCHANGE_RATE)
              ,decode(cache.PROJECT_REV_RATE_DATE_TYPE,  null, bl.project_rev_rate_date_type, FND_API.G_MISS_CHAR, null, cache.PROJECT_REV_RATE_DATE_TYPE)
              ,decode(cache.PROJECT_REV_RATE_DATE,       null, bl.project_rev_rate_date, FND_API.G_MISS_DATE, null, cache.PROJECT_REV_RATE_DATE)
              ,decode(cache.PROJFUNC_COST_RATE_TYPE,     null, bl.projfunc_cost_rate_type, FND_API.G_MISS_CHAR, null, cache.PROJFUNC_COST_RATE_TYPE)
              ,decode(cache.PROJFUNC_COST_EXCHANGE_RATE, null, bl.projfunc_cost_exchange_rate, FND_API.G_MISS_NUM, null, cache.PROJFUNC_COST_EXCHANGE_RATE)
              ,decode(cache.PROJFUNC_COST_RATE_DATE_TYPE,null, bl.projfunc_cost_rate_date_type, FND_API.G_MISS_CHAR, null, cache.PROJFUNC_COST_RATE_DATE_TYPE)
              ,decode(cache.PROJFUNC_COST_RATE_DATE,     null, bl.projfunc_cost_rate_date, FND_API.G_MISS_DATE, null, cache.PROJFUNC_COST_RATE_DATE)
              ,decode(cache.PROJFUNC_REV_RATE_TYPE,      null, bl.projfunc_rev_rate_type, FND_API.G_MISS_CHAR, null, cache.PROJFUNC_REV_RATE_TYPE)
              ,decode(cache.PROJFUNC_REV_EXCHANGE_RATE,  null, bl.projfunc_rev_exchange_rate, FND_API.G_MISS_NUM, null, cache.PROJFUNC_REV_EXCHANGE_RATE)
              ,decode(cache.PROJFUNC_REV_RATE_DATE_TYPE, null, bl.projfunc_rev_rate_date_type, FND_API.G_MISS_CHAR, null, cache.PROJFUNC_REV_RATE_DATE_TYPE)
              ,decode(cache.PROJFUNC_REV_RATE_DATE,      null, bl.projfunc_rev_rate_date, FND_API.G_MISS_DATE, null, cache.PROJFUNC_REV_RATE_DATE)
              ,decode(cache.CHANGE_REASON_CODE,          null, bl.change_reason_code, FND_API.G_MISS_CHAR, null, cache.CHANGE_REASON_CODE)
              ,decode(cache.DESCRIPTION          ,null, bl.DESCRIPTION, FND_API.G_MISS_CHAR, null, cache.DESCRIPTION)
              ,decode(cache.ATTRIBUTE_CATEGORY   ,null, bl.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE_CATEGORY)
              ,decode(cache.ATTRIBUTE1           ,null, bl.ATTRIBUTE1,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE1)
              ,decode(cache.ATTRIBUTE2           ,null, bl.ATTRIBUTE2,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE2)
              ,decode(cache.ATTRIBUTE3           ,null, bl.ATTRIBUTE3,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE3)
              ,decode(cache.ATTRIBUTE4           ,null, bl.ATTRIBUTE4,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE4)
              ,decode(cache.ATTRIBUTE5           ,null, bl.ATTRIBUTE5,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE5)
              ,decode(cache.ATTRIBUTE6           ,null, bl.ATTRIBUTE6,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE6)
              ,decode(cache.ATTRIBUTE7           ,null, bl.ATTRIBUTE7,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE7)
              ,decode(cache.ATTRIBUTE8           ,null, bl.ATTRIBUTE8,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE8)
              ,decode(cache.ATTRIBUTE9           ,null, bl.ATTRIBUTE9,  FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE9)
              ,decode(cache.ATTRIBUTE10          ,null, bl.ATTRIBUTE10, FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE10)
              ,decode(cache.ATTRIBUTE11          ,null, bl.ATTRIBUTE11, FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE11)
              ,decode(cache.ATTRIBUTE12          ,null, bl.ATTRIBUTE12, FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE12)
              ,decode(cache.ATTRIBUTE13          ,null, bl.ATTRIBUTE13, FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE13)
              ,decode(cache.ATTRIBUTE14          ,null, bl.ATTRIBUTE14, FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE14)
              ,decode(cache.ATTRIBUTE15          ,null, bl.ATTRIBUTE15, FND_API.G_MISS_CHAR, null, cache.ATTRIBUTE15)
              ,cache.RAW_COST_SOURCE
              ,cache.BURDENED_COST_SOURCE
              ,cache.QUANTITY_SOURCE
              ,cache.REVENUE_SOURCE
              , decode(cache.PM_PRODUCT_CODE  ,null,bl.PM_PRODUCT_CODE, FND_API.G_MISS_CHAR, null, cache.PM_PRODUCT_CODE)
              , decode(cache.PM_BUDGET_LINE_REFERENCE ,null,bl.PM_BUDGET_LINE_REFERENCE, FND_API.G_MISS_CHAR, null, cache.PM_BUDGET_LINE_REFERENCE)
              , cache.CODE_COMBINATION_ID
              , cache.CCID_GEN_STATUS_CODE
              , cache.CCID_GEN_REJ_MESSAGE
              , cache.BORROWED_REVENUE
              , cache.TP_REVENUE_IN
              , cache.TP_REVENUE_OUT
              , cache.REVENUE_ADJ
              , cache.LENT_RESOURCE_COST
              , cache.TP_COST_IN
              , cache.TP_COST_OUT
              , cache.COST_ADJ
              , cache.UNASSIGNED_TIME_COST
              , cache.UTILIZATION_PERCENT
              , cache.UTILIZATION_HOURS
              , cache.UTILIZATION_ADJ
              , cache.CAPACITY
              , cache.HEAD_COUNT
              , cache.HEAD_COUNT_ADJ
              , cache.BUCKETING_PERIOD_CODE
              , cache.TXN_DISCOUNT_PERCENTAGE
              , cache.TRANSFER_PRICE_RATE
              , cache.BL_CREATED_BY
              , cache.BL_CREATION_DATE
              FROM   pa_fp_spread_calc_tmp1 cache, pa_budget_lines bl
              WHERE  cache.budget_version_id = p_budget_verson_id
              AND    cache.budget_version_id = bl.budget_version_id
              AND    cache.resource_assignment_id = bl.resource_assignment_id
              AND    cache.txn_currency_code = bl.txn_currency_code
              AND    cache.start_date = bl.start_date
            /*If a new budget line (not exists in pa_budget_lines) is attempted to be created with all amts/qty/rate as null but
             * with dffs/mc/change reason, from amg flow, that budget line would not be selected due to the join with pa_budget_lines.
             * This is only intended as budget lines with null amts/qty are not maintained in pa_budget_lines any more.
             */
              AND    NOT EXISTS (SELECT 'X' FROM pa_fp_rollup_tmp  tmp WHERE tmp.budget_version_id = cache.budget_version_id
              AND    tmp.resource_assignment_id = cache.resource_assignment_id
              AND    tmp.txn_currency_code = cache.txn_currency_code
              AND    tmp.start_date = cache.start_date);

        l_resource_assignment_id_tab     pa_plsql_datatypes.Num15TabTyp;
        l_start_date_tab                 pa_plsql_datatypes.DateTabTyp;
        l_period_name_tab                pa_plsql_datatypes.Char50TabTyp;
        l_end_date_tab                   pa_plsql_datatypes.DateTabTyp;
        l_budget_line_id_tab             pa_plsql_datatypes.Num15TabTyp;
        l_quantity_tab                   pa_plsql_datatypes.NumTabTyp;
        l_txn_raw_cost_tab               pa_plsql_datatypes.NumTabTyp;
        l_txn_burdened_cost_tab          pa_plsql_datatypes.NumTabTyp;
        l_txn_revenue_tab                pa_plsql_datatypes.NumTabTyp;
        l_init_quantity_tab              pa_plsql_datatypes.NumTabTyp;
        l_txn_init_raw_cost_tab          pa_plsql_datatypes.NumTabTyp;
        l_txn_init_burdened_cost_tab     pa_plsql_datatypes.NumTabTyp;
        l_txn_init_revenue_tab           pa_plsql_datatypes.NumTabTyp;
        l_cost_rate_override_tab         pa_plsql_datatypes.NumTabTyp;
        l_burden_rate_override_tab       pa_plsql_datatypes.NumTabTyp;
        l_bill_rate_override_tab         pa_plsql_datatypes.NumTabTyp;
        l_pjfc_raw_cost_tab              pa_plsql_datatypes.NumTabTyp;
        l_pjfc_burden_cost_tab           pa_plsql_datatypes.NumTabTyp;
        l_pjfc_revenue_tab               pa_plsql_datatypes.NumTabTyp;
        l_cost_rejection_tab             pa_plsql_datatypes.Char30TabTyp;
        l_rev_rejection_tab              pa_plsql_datatypes.Char30TabTyp;
        l_burden_rejection_tab           pa_plsql_datatypes.Char30TabTyp;
        l_project_raw_cost_tab           pa_plsql_datatypes.NumTabTyp;
        l_project_burdened_cost_tab      pa_plsql_datatypes.NumTabTyp;
        l_project_revenue_tab            pa_plsql_datatypes.NumTabTyp;
        l_markup_percentage_tab          pa_plsql_datatypes.NumTabTyp;
        l_bill_rate_tab                  pa_plsql_datatypes.NumTabTyp;
        l_cost_rate_tab                  pa_plsql_datatypes.NumTabTyp;
        l_burden_cost_rate_tab           pa_plsql_datatypes.NumTabTyp;
        l_compiled_set_id_tab            pa_plsql_datatypes.Num15TabTyp;
        l_init_raw_cost_tab              pa_plsql_datatypes.NumTabTyp;
        l_init_burdened_cost_tab         pa_plsql_datatypes.NumTabTyp;
        l_init_revenue_tab               pa_plsql_datatypes.NumTabTyp;
        l_project_init_raw_cost_tab      pa_plsql_datatypes.NumTabTyp;
        l_prjct_init_burdened_cost_tab   pa_plsql_datatypes.NumTabTyp;
        l_project_init_revenue_tab       pa_plsql_datatypes.NumTabTyp;
        l_txn_currency_code_tab          pa_plsql_datatypes.Char50TabTyp;
        l_projfunc_currency_code_tab     pa_plsql_datatypes.Char15TabTyp;
        l_PROJECT_CURRENCY_CODE_tab      pa_plsql_datatypes.Char15TabTyp;
        l_PROJECT_COST_RATE_TYPE_tab     pa_plsql_datatypes.Char50TabTyp;
        l_PROJECT_COST_EXG_RATE_tab      pa_plsql_datatypes.NumTabTyp;
        l_PROJECT_COST_DATE_TYPE_tab     pa_plsql_datatypes.Char50TabTyp;
        l_PROJECT_COST_RATE_DATE_tab     pa_plsql_datatypes.DateTabTyp;
        l_PROJECT_REV_RATE_TYPE_tab      pa_plsql_datatypes.Char50TabTyp;
        l_PROJECT_REV_EXG_RATE_tab       pa_plsql_datatypes.NumTabTyp;
        l_PROJECT_REV_DATE_TYPE_tab      pa_plsql_datatypes.Char50TabTyp;
        l_PROJECT_REV_RATE_DATE_tab      pa_plsql_datatypes.DateTabTyp;
        l_PROJFUNC_COST_RATE_TYPE_tab    pa_plsql_datatypes.Char50TabTyp;
        l_PROJFUNC_COST_EXG_RATE_tab     pa_plsql_datatypes.NumTabTyp;
        l_PROJFUNC_COST_DATE_TYPE_tab    pa_plsql_datatypes.Char50TabTyp;
        l_PROJFUNC_COST_RATE_DATE_tab    pa_plsql_datatypes.DateTabTyp;
        l_PROJFUNC_REV_RATE_TYPE_tab     pa_plsql_datatypes.Char50TabTyp;
        l_PROJFUNC_REV_EXG_RATE_tab      pa_plsql_datatypes.NumTabTyp;
        l_PROJFUNC_REV_DATE_TYPE_tab     pa_plsql_datatypes.Char50TabTyp;
        l_PROJFUNC_REV_RATE_DATE_tab     pa_plsql_datatypes.DateTabTyp;
        l_CHANGE_REASON_CODE_tab         pa_plsql_datatypes.Char30TabTyp;
        l_DESCRIPTION_tab                pa_plsql_datatypes.Char250TabTyp;
        l_ATTRIBUTE_CATEGORY_tab         pa_plsql_datatypes.Char30TabTyp;
        l_ATTRIBUTE1_tab                 pa_plsql_datatypes.Char150TabTyp;
        l_ATTRIBUTE2_tab                 pa_plsql_datatypes.Char150TabTyp;
        l_ATTRIBUTE3_tab                 pa_plsql_datatypes.Char150TabTyp;
        l_ATTRIBUTE4_tab                 pa_plsql_datatypes.Char150TabTyp;
        l_ATTRIBUTE5_tab                 pa_plsql_datatypes.Char150TabTyp;
        l_ATTRIBUTE6_tab                 pa_plsql_datatypes.Char150TabTyp;
        l_ATTRIBUTE7_tab                 pa_plsql_datatypes.Char150TabTyp;
        l_ATTRIBUTE8_tab                 pa_plsql_datatypes.Char150TabTyp;
        l_ATTRIBUTE9_tab                 pa_plsql_datatypes.Char150TabTyp;
        l_ATTRIBUTE10_tab                pa_plsql_datatypes.Char150TabTyp;
        l_ATTRIBUTE11_tab                pa_plsql_datatypes.Char150TabTyp;
        l_ATTRIBUTE12_tab                pa_plsql_datatypes.Char150TabTyp;
        l_ATTRIBUTE13_tab                pa_plsql_datatypes.Char150TabTyp;
        l_ATTRIBUTE14_tab                pa_plsql_datatypes.Char150TabTyp;
        l_ATTRIBUTE15_tab                pa_plsql_datatypes.Char150TabTyp;
        l_RAW_COST_SOURCE_tab            pa_plsql_datatypes.Char2TabTyp;
        l_BURDENED_COST_SOURCE_tab       pa_plsql_datatypes.Char2TabTyp;
        l_QUANTITY_SOURCE_tab            pa_plsql_datatypes.Char2TabTyp;
        l_REVENUE_SOURCE_tab             pa_plsql_datatypes.Char2TabTyp;
        l_PM_PRODUCT_CODE_tab            pa_plsql_datatypes.Char30TabTyp;
        l_PM_BUDGET_LINE_REFERENCE_tab   pa_plsql_datatypes.Char30TabTyp;
        l_CODE_COMBINATION_ID_tab        pa_plsql_datatypes.Num15TabTyp;
        l_CCID_GEN_STATUS_CODE_tab       pa_plsql_datatypes.Char1TabTyp;
        l_CCID_GEN_REJ_MESSAGE_tab       pa_plsql_datatypes.Char2000TabTyp;
        l_BORROWED_REVENUE_tab           pa_plsql_datatypes.NumTabTyp;
        l_TP_REVENUE_IN_tab              pa_plsql_datatypes.NumTabTyp;
        l_TP_REVENUE_OUT_tab             pa_plsql_datatypes.NumTabTyp;
        l_REVENUE_ADJ_tab                pa_plsql_datatypes.NumTabTyp;
        l_LENT_RESOURCE_COST_tab         pa_plsql_datatypes.NumTabTyp;
        l_TP_COST_IN_tab                 pa_plsql_datatypes.NumTabTyp;
        l_TP_COST_OUT_tab                pa_plsql_datatypes.NumTabTyp;
        l_COST_ADJ_tab                   pa_plsql_datatypes.NumTabTyp;
        l_UNASSIGNED_TIME_COST_tab       pa_plsql_datatypes.NumTabTyp;
        l_UTILIZATION_PERCENT_tab        pa_plsql_datatypes.NumTabTyp;
        l_UTILIZATION_HOURS_tab          pa_plsql_datatypes.NumTabTyp;
        l_UTILIZATION_ADJ_tab            pa_plsql_datatypes.NumTabTyp;
        l_CAPACITY_tab                   pa_plsql_datatypes.NumTabTyp;
        l_HEAD_COUNT_tab                 pa_plsql_datatypes.NumTabTyp;
        l_HEAD_COUNT_ADJ_tab             pa_plsql_datatypes.NumTabTyp;
        l_BUCKETING_PERIOD_CODE_tab      pa_plsql_datatypes.Char30TabTyp;
        l_TXN_DISCOUNT_PERCENTAGE_tab    pa_plsql_datatypes.NumTabTyp;
        l_TRANSFER_PRICE_RATE_tab        pa_plsql_datatypes.NumTabTyp;
        l_BL_CREATED_BY_tab              pa_plsql_datatypes.NumTabTyp;
        l_BL_CREATION_DATE_tab           pa_plsql_datatypes.DateTabTyp;

        l_budget_version_id_tab          pa_plsql_datatypes.Num15TabTyp;

    PROCEDURE INIT_PLSQL_TABS IS
    BEGIN
                        l_resource_assignment_id_tab.delete;
            l_start_date_tab.delete;
            l_period_name_tab.delete;
            l_end_date_tab.delete;
            l_budget_line_id_tab.delete;
            l_quantity_tab.delete;
                    l_txn_raw_cost_tab.delete;
                        l_txn_burdened_cost_tab.delete;
                    l_txn_revenue_tab.delete;
                    l_init_quantity_tab.delete;
                    l_txn_init_raw_cost_tab.delete;
                    l_txn_init_burdened_cost_tab.delete;
                    l_txn_init_revenue_tab.delete;
                    l_cost_rate_override_tab.delete;
            l_burden_rate_override_tab.delete;
            l_bill_rate_override_tab.delete;
            l_pjfc_raw_cost_tab.delete;
            l_pjfc_burden_cost_tab.delete;
            l_pjfc_revenue_tab.delete;
            l_cost_rejection_tab.delete;
            l_rev_rejection_tab.delete;
            l_burden_rejection_tab.delete;
            l_project_raw_cost_tab.delete;
            l_project_burdened_cost_tab.delete;
            l_project_revenue_tab.delete;
            l_markup_percentage_tab.delete;
            l_bill_rate_tab.delete;
            l_cost_rate_tab.delete;
            l_burden_cost_rate_tab.delete;
            l_compiled_set_id_tab.delete;
            l_init_raw_cost_tab.delete;
            l_init_burdened_cost_tab.delete;
            l_init_revenue_tab.delete;
            l_project_init_raw_cost_tab.delete;
            l_prjct_init_burdened_cost_tab.delete;
            l_project_init_revenue_tab.delete;
            l_txn_currency_code_tab.delete;
            l_projfunc_currency_code_tab.delete;
            l_PROJECT_CURRENCY_CODE_tab.delete;
            l_PROJECT_COST_RATE_TYPE_tab.delete;
            l_PROJECT_COST_EXG_RATE_tab.delete;
            l_PROJECT_COST_DATE_TYPE_tab.delete;
            l_PROJECT_COST_RATE_DATE_tab.delete;
            l_PROJECT_REV_RATE_TYPE_tab.delete;
            l_PROJECT_REV_EXG_RATE_tab.delete;
            l_PROJECT_REV_DATE_TYPE_tab.delete;
            l_PROJECT_REV_RATE_DATE_tab.delete;
            l_PROJFUNC_COST_RATE_TYPE_tab.delete;
            l_PROJFUNC_COST_EXG_RATE_tab.delete;
            l_PROJFUNC_COST_DATE_TYPE_tab.delete;
            l_PROJFUNC_COST_RATE_DATE_tab.delete;
            l_PROJFUNC_REV_RATE_TYPE_tab.delete;
            l_PROJFUNC_REV_EXG_RATE_tab.delete;
            l_PROJFUNC_REV_DATE_TYPE_tab.delete;
            l_PROJFUNC_REV_RATE_DATE_tab.delete;
            l_CHANGE_REASON_CODE_tab.delete;
            l_DESCRIPTION_tab.delete;
            l_ATTRIBUTE_CATEGORY_tab.delete;
            l_ATTRIBUTE1_tab.delete;
            l_ATTRIBUTE2_tab.delete;
            l_ATTRIBUTE3_tab.delete;
            l_ATTRIBUTE4_tab.delete;
            l_ATTRIBUTE5_tab.delete;
            l_ATTRIBUTE6_tab.delete;
            l_ATTRIBUTE7_tab.delete;
            l_ATTRIBUTE8_tab.delete;
            l_ATTRIBUTE9_tab.delete;
            l_ATTRIBUTE10_tab.delete;
            l_ATTRIBUTE11_tab.delete;
            l_ATTRIBUTE12_tab.delete;
            l_ATTRIBUTE13_tab.delete;
            l_ATTRIBUTE14_tab.delete;
            l_ATTRIBUTE15_tab.delete;
            l_RAW_COST_SOURCE_tab.delete;
            l_BURDENED_COST_SOURCE_tab.delete;
            l_QUANTITY_SOURCE_tab.delete;
            l_REVENUE_SOURCE_tab.delete;
            l_PM_PRODUCT_CODE_tab.delete;
            l_PM_BUDGET_LINE_REFERENCE_tab.delete;
            l_CODE_COMBINATION_ID_tab.delete;
            l_CCID_GEN_STATUS_CODE_tab.delete;
            l_CCID_GEN_REJ_MESSAGE_tab.delete;
            l_BORROWED_REVENUE_tab.delete;
            l_TP_REVENUE_IN_tab.delete;
            l_TP_REVENUE_OUT_tab.delete;
            l_REVENUE_ADJ_tab.delete;
            l_LENT_RESOURCE_COST_tab.delete;
            l_TP_COST_IN_tab.delete;
            l_TP_COST_OUT_tab.delete;
            l_COST_ADJ_tab.delete;
            l_UNASSIGNED_TIME_COST_tab.delete;
            l_UTILIZATION_PERCENT_tab.delete;
            l_UTILIZATION_HOURS_tab.delete;
            l_UTILIZATION_ADJ_tab.delete;
            l_CAPACITY_tab.delete;
            l_HEAD_COUNT_tab.delete;
            l_HEAD_COUNT_ADJ_tab.delete;
            l_BUCKETING_PERIOD_CODE_tab.delete;
            l_TXN_DISCOUNT_PERCENTAGE_tab.delete;
            l_TRANSFER_PRICE_RATE_tab.delete;
            l_BL_CREATED_BY_tab.delete;
            l_BL_CREATION_DATE_tab.delete;
            l_budget_version_id_tab.delete;
    END INIT_PLSQL_TABS;
BEGIN
        /* Initialize the out variables */
        x_return_status := 'S';
        x_msg_data := NULL;
        x_msg_count := fnd_msg_pub.count_msg;
        If p_pa_debug_mode = 'Y' Then
                pa_debug.init_err_stack('PA_FP_CALC_UTILS.update_dffcols');
        End If;
        IF p_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION') Then  --{
                INIT_PLSQL_TABS;
                --print_msg('Fetching budget Line Attributes such as DFFs details from cache ');
                OPEN blAttribDetails;
                FETCH blAttribDetails BULK COLLECT INTO
                         l_resource_assignment_id_tab
                        ,l_start_date_tab
                        ,l_period_name_tab
                        ,l_end_date_tab
                        ,l_budget_version_id_tab
                        ,l_budget_line_id_tab
                        ,l_quantity_tab
                        ,l_txn_raw_cost_tab
                        ,l_txn_burdened_cost_tab
                        ,l_txn_revenue_tab
                        ,l_init_quantity_tab
                        ,l_txn_init_raw_cost_tab
                        ,l_txn_init_burdened_cost_tab
                        ,l_txn_init_revenue_tab
                        ,l_cost_rate_override_tab
                        ,l_burden_rate_override_tab
                        ,l_bill_rate_override_tab
                        ,l_pjfc_raw_cost_tab
                        ,l_pjfc_burden_cost_tab
                        ,l_pjfc_revenue_tab
                        ,l_cost_rejection_tab
                        ,l_rev_rejection_tab
                        ,l_burden_rejection_tab
                        ,l_project_raw_cost_tab
                        ,l_project_burdened_cost_tab
                        ,l_project_revenue_tab
                        ,l_markup_percentage_tab
                        ,l_bill_rate_tab
                        ,l_cost_rate_tab
                        ,l_burden_cost_rate_tab
                        ,l_compiled_set_id_tab
                        ,l_init_raw_cost_tab
                        ,l_init_burdened_cost_tab
                        ,l_init_revenue_tab
                        ,l_project_init_raw_cost_tab
                        ,l_prjct_init_burdened_cost_tab
                        ,l_project_init_revenue_tab
                        ,l_txn_currency_code_tab
                        ,l_projfunc_currency_code_tab
                        ,l_PROJECT_CURRENCY_CODE_tab
                        ,l_PROJECT_COST_RATE_TYPE_tab
                        ,l_PROJECT_COST_EXG_RATE_tab
                        ,l_PROJECT_COST_DATE_TYPE_tab
                        ,l_PROJECT_COST_RATE_DATE_tab
                        ,l_PROJECT_REV_RATE_TYPE_tab
                        ,l_PROJECT_REV_EXG_RATE_tab
                        ,l_PROJECT_REV_DATE_TYPE_tab
                        ,l_PROJECT_REV_RATE_DATE_tab
                        ,l_PROJFUNC_COST_RATE_TYPE_tab
                        ,l_PROJFUNC_COST_EXG_RATE_tab
                        ,l_PROJFUNC_COST_DATE_TYPE_tab
                        ,l_PROJFUNC_COST_RATE_DATE_tab
                        ,l_PROJFUNC_REV_RATE_TYPE_tab
                        ,l_PROJFUNC_REV_EXG_RATE_tab
                        ,l_PROJFUNC_REV_DATE_TYPE_tab
                        ,l_PROJFUNC_REV_RATE_DATE_tab
                        ,l_CHANGE_REASON_CODE_tab
                        ,l_DESCRIPTION_tab
                        ,l_ATTRIBUTE_CATEGORY_tab
                        ,l_ATTRIBUTE1_tab
                        ,l_ATTRIBUTE2_tab
                        ,l_ATTRIBUTE3_tab
                        ,l_ATTRIBUTE4_tab
                        ,l_ATTRIBUTE5_tab
                        ,l_ATTRIBUTE6_tab
                        ,l_ATTRIBUTE7_tab
                        ,l_ATTRIBUTE8_tab
                        ,l_ATTRIBUTE9_tab
                        ,l_ATTRIBUTE10_tab
                        ,l_ATTRIBUTE11_tab
                        ,l_ATTRIBUTE12_tab
                        ,l_ATTRIBUTE13_tab
                        ,l_ATTRIBUTE14_tab
                        ,l_ATTRIBUTE15_tab
                        ,l_RAW_COST_SOURCE_tab
                        ,l_BURDENED_COST_SOURCE_tab
                        ,l_QUANTITY_SOURCE_tab
                        ,l_REVENUE_SOURCE_tab
                        ,l_PM_PRODUCT_CODE_tab
                        ,l_PM_BUDGET_LINE_REFERENCE_tab
                        ,l_CODE_COMBINATION_ID_tab
                        ,l_CCID_GEN_STATUS_CODE_tab
                        ,l_CCID_GEN_REJ_MESSAGE_tab
                        ,l_BORROWED_REVENUE_tab
                        ,l_TP_REVENUE_IN_tab
                        ,l_TP_REVENUE_OUT_tab
                        ,l_REVENUE_ADJ_tab
                        ,l_LENT_RESOURCE_COST_tab
                        ,l_TP_COST_IN_tab
                        ,l_TP_COST_OUT_tab
                        ,l_COST_ADJ_tab
                        ,l_UNASSIGNED_TIME_COST_tab
                        ,l_UTILIZATION_PERCENT_tab
                        ,l_UTILIZATION_HOURS_tab
                        ,l_UTILIZATION_ADJ_tab
                        ,l_CAPACITY_tab
                        ,l_HEAD_COUNT_tab
                        ,l_HEAD_COUNT_ADJ_tab
                        ,l_BUCKETING_PERIOD_CODE_tab
                        ,l_TXN_DISCOUNT_PERCENTAGE_tab
                        ,l_TRANSFER_PRICE_RATE_tab
                        ,l_BL_CREATED_BY_tab
                        ,l_BL_CREATION_DATE_tab;
                CLOSE blAttribDetails;
                --print_msg('Number of blAttrib rows fetched['||l_resource_assignment_id_tab.COUNT||']');

                IF l_resource_assignment_id_tab.COUNT > 0 THEN
                        --print_msg('Number of blAttrib rows fetched['||l_resource_assignment_id_tab.COUNT||']');

                        FORALL i IN  l_resource_assignment_id_tab.FIRST .. l_resource_assignment_id_tab.LAST
                        INSERT INTO pa_fp_rollup_tmp tmp
            (
             budget_version_id
            ,resource_assignment_id
            ,start_date
            ,period_name
            ,end_date
            ,budget_line_id
            ,quantity
            ,txn_raw_cost
            ,txn_burdened_cost
            ,txn_revenue
            ,init_quantity
            ,txn_init_raw_cost
            ,txn_init_burdened_cost
            ,txn_init_revenue
            ,rw_cost_rate_override
            ,burden_cost_rate_override
            ,bill_rate_override
            ,projfunc_raw_cost
            ,projfunc_burdened_cost
            ,projfunc_revenue
            ,cost_rejection_code
            ,revenue_rejection_code
            ,burden_rejection_code
            ,project_raw_cost
            ,project_burdened_cost
            ,project_revenue
            ,bill_markup_percentage
            ,bill_rate
            ,cost_rate
            ,burden_cost_rate
            ,cost_ind_compiled_set_id
            ,init_raw_cost
            ,init_burdened_cost
            ,init_revenue
            ,project_init_raw_cost
            ,project_init_burdened_cost
            ,project_init_revenue
            ,txn_currency_code
            ,projfunc_currency_code
            ,project_currency_code
            ,project_cost_rate_type
            ,project_cost_exchange_rate
            ,project_cost_rate_date_type
            ,project_cost_rate_date
            ,project_rev_rate_type
            ,project_rev_exchange_rate
            ,project_rev_rate_date_type
            ,project_rev_rate_date
            ,projfunc_cost_rate_type
            ,projfunc_cost_exchange_rate
            ,projfunc_cost_rate_date_type
            ,projfunc_cost_rate_date
            ,projfunc_rev_rate_type
            ,projfunc_rev_exchange_rate
            ,projfunc_rev_rate_date_type
            ,projfunc_rev_rate_date
            ,CHANGE_REASON_CODE
            ,DESCRIPTION
            ,ATTRIBUTE_CATEGORY
            ,ATTRIBUTE1
            ,ATTRIBUTE2
            ,ATTRIBUTE3
            ,ATTRIBUTE4
            ,ATTRIBUTE5
            ,ATTRIBUTE6
            ,ATTRIBUTE7
            ,ATTRIBUTE8
            ,ATTRIBUTE9
            ,ATTRIBUTE10
            ,ATTRIBUTE11
            ,ATTRIBUTE12
            ,ATTRIBUTE13
            ,ATTRIBUTE14
            ,ATTRIBUTE15
            ,RAW_COST_SOURCE
            ,BURDENED_COST_SOURCE
            ,QUANTITY_SOURCE
            ,REVENUE_SOURCE
            ,PM_PRODUCT_CODE
            ,PM_BUDGET_LINE_REFERENCE
            ,CODE_COMBINATION_ID
            ,CCID_GEN_STATUS_CODE
            ,CCID_GEN_REJ_MESSAGE
            ,BORROWED_REVENUE
            ,TP_REVENUE_IN
            ,TP_REVENUE_OUT
            ,REVENUE_ADJ
            ,LENT_RESOURCE_COST
            ,TP_COST_IN
            ,TP_COST_OUT
            ,COST_ADJ
            ,UNASSIGNED_TIME_COST
            ,UTILIZATION_PERCENT
            ,UTILIZATION_HOURS
            ,UTILIZATION_ADJ
            ,CAPACITY
            ,HEAD_COUNT
            ,HEAD_COUNT_ADJ
            ,BUCKETING_PERIOD_CODE
            ,TXN_DISCOUNT_PERCENTAGE
            ,TRANSFER_PRICE_RATE
            ,BL_CREATED_BY
            ,BL_CREATION_DATE
            )
            VALUES
            (
             l_budget_version_id_tab(i)
            ,l_resource_assignment_id_tab(i)
            ,l_start_date_tab(i)
            ,l_period_name_tab(i)
            ,l_end_date_tab(i)
            ,l_budget_line_id_tab(i)
            ,l_quantity_tab(i)
            ,l_txn_raw_cost_tab(i)
            ,l_txn_burdened_cost_tab(i)
            ,l_txn_revenue_tab(i)
            ,l_init_quantity_tab(i)
            ,l_txn_init_raw_cost_tab(i)
            ,l_txn_init_burdened_cost_tab(i)
            ,l_txn_init_revenue_tab(i)
            ,l_cost_rate_override_tab(i)
            ,l_burden_rate_override_tab(i)
            ,l_bill_rate_override_tab(i)
            ,l_pjfc_raw_cost_tab(i)
            ,l_pjfc_burden_cost_tab(i)
            ,l_pjfc_revenue_tab(i)
            ,l_cost_rejection_tab(i)
            ,l_rev_rejection_tab(i)
            ,l_burden_rejection_tab(i)
            ,l_project_raw_cost_tab(i)
            ,l_project_burdened_cost_tab(i)
            ,l_project_revenue_tab(i)
            ,l_markup_percentage_tab(i)
            ,l_bill_rate_tab(i)
            ,l_cost_rate_tab(i)
            ,l_burden_cost_rate_tab(i)
            ,l_compiled_set_id_tab(i)
            ,l_init_raw_cost_tab(i)
            ,l_init_burdened_cost_tab(i)
            ,l_init_revenue_tab(i)
            ,l_project_init_raw_cost_tab(i)
            ,l_prjct_init_burdened_cost_tab(i)
            ,l_project_init_revenue_tab(i)
            ,l_txn_currency_code_tab(i)
            ,l_projfunc_currency_code_tab(i)
            ,l_PROJECT_CURRENCY_CODE_tab(i)
            ,l_PROJECT_COST_RATE_TYPE_tab(i)
            ,l_PROJECT_COST_EXG_RATE_tab(i)
            ,l_PROJECT_COST_DATE_TYPE_tab(i)
            ,l_PROJECT_COST_RATE_DATE_tab(i)
            ,l_PROJECT_REV_RATE_TYPE_tab(i)
            ,l_PROJECT_REV_EXG_RATE_tab(i)
            ,l_PROJECT_REV_DATE_TYPE_tab(i)
            ,l_PROJECT_REV_RATE_DATE_tab(i)
            ,l_PROJFUNC_COST_RATE_TYPE_tab(i)
            ,l_PROJFUNC_COST_EXG_RATE_tab(i)
            ,l_PROJFUNC_COST_DATE_TYPE_tab(i)
            ,l_PROJFUNC_COST_RATE_DATE_tab(i)
            ,l_PROJFUNC_REV_RATE_TYPE_tab(i)
            ,l_PROJFUNC_REV_EXG_RATE_tab(i)
            ,l_PROJFUNC_REV_DATE_TYPE_tab(i)
            ,l_PROJFUNC_REV_RATE_DATE_tab(i)
            ,l_CHANGE_REASON_CODE_tab(i)
            ,l_DESCRIPTION_tab(i)
            ,l_ATTRIBUTE_CATEGORY_tab(i)
            ,l_ATTRIBUTE1_tab(i)
            ,l_ATTRIBUTE2_tab(i)
            ,l_ATTRIBUTE3_tab(i)
            ,l_ATTRIBUTE4_tab(i)
            ,l_ATTRIBUTE5_tab(i)
            ,l_ATTRIBUTE6_tab(i)
            ,l_ATTRIBUTE7_tab(i)
            ,l_ATTRIBUTE8_tab(i)
            ,l_ATTRIBUTE9_tab(i)
            ,l_ATTRIBUTE10_tab(i)
            ,l_ATTRIBUTE11_tab(i)
            ,l_ATTRIBUTE12_tab(i)
            ,l_ATTRIBUTE13_tab(i)
            ,l_ATTRIBUTE14_tab(i)
            ,l_ATTRIBUTE15_tab(i)
            ,l_RAW_COST_SOURCE_tab(i)
            ,l_BURDENED_COST_SOURCE_tab(i)
            ,l_QUANTITY_SOURCE_tab(i)
            ,l_REVENUE_SOURCE_tab(i)
            ,l_PM_PRODUCT_CODE_tab(i)
            ,l_PM_BUDGET_LINE_REFERENCE_tab(i)
            ,l_CODE_COMBINATION_ID_tab(i)
            ,l_CCID_GEN_STATUS_CODE_tab(i)
            ,l_CCID_GEN_REJ_MESSAGE_tab(i)
            ,l_BORROWED_REVENUE_tab(i)
            ,l_TP_REVENUE_IN_tab(i)
            ,l_TP_REVENUE_OUT_tab(i)
            ,l_REVENUE_ADJ_tab(i)
            ,l_LENT_RESOURCE_COST_tab(i)
            ,l_TP_COST_IN_tab(i)
            ,l_TP_COST_OUT_tab(i)
            ,l_COST_ADJ_tab(i)
            ,l_UNASSIGNED_TIME_COST_tab(i)
            ,l_UTILIZATION_PERCENT_tab(i)
            ,l_UTILIZATION_HOURS_tab(i)
            ,l_UTILIZATION_ADJ_tab(i)
            ,l_CAPACITY_tab(i)
            ,l_HEAD_COUNT_tab(i)
            ,l_HEAD_COUNT_ADJ_tab(i)
            ,l_BUCKETING_PERIOD_CODE_tab(i)
            ,l_TXN_DISCOUNT_PERCENTAGE_tab(i)
            ,l_TRANSFER_PRICE_RATE_tab(i)
            ,l_BL_CREATED_BY_tab(i)
            ,l_BL_CREATION_DATE_tab(i) );
            --print_msg('Number of rows updated['||sql%rowcount||']');
                END IF;
        /* release the buffer */
        INIT_PLSQL_TABS;
        END IF;  --}

        x_msg_count := fnd_msg_pub.count_msg;
    --print_msg('End of update_dffcols retSts['||x_return_status||']');
    If p_pa_debug_mode = 'Y' Then
        pa_debug.reset_err_stack;
    End If;

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                x_msg_data := SQLCODE||SQLERRM;
        fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'update_dffcols');
        If p_pa_debug_mode = 'Y' Then
                    pa_debug.reset_err_stack;
        End If;
                RAISE;

END update_dffcols;

/*Bug:4272944: Added new procedure to insert zero qty budget lines from pa_fp_spread_calc_tmp1 to
*pa_budget_lines. This fix is done specific to Funding of Autobase line is failing.
*donot populate or use pa_fp_spread_calc_tmp1 table for any other purpose.
*Note: Calling API may populate this table only for AMG/MSP/Autobaseline purpose.
*/
PROCEDURE InsertFunding_ReqdLines
	( p_budget_verson_id               IN  Number
         ,p_source_context                 IN  Varchar2
         ,p_calling_module                 IN  Varchar2
         ,p_apply_progress_flag            IN  Varchar2
	 ,p_approved_rev_flag              IN  Varchar2
	 ,p_autoBaseLine_flag              IN  Varchar2
         ,x_return_status                  OUT NOCOPY varchar2
         ) IS

	CURSOR cur_tmp1Recs IS
	SELECT tmp.resource_assignment_id
		,tmp.txn_currency_code
		,tmp.start_date
		,tmp.end_date
		,tmp.period_name
		,pa_budget_lines_s.nextval
	FROM  pa_fp_spread_calc_tmp1 tmp
	WHERE tmp.budget_version_id = p_budget_verson_id;

	l_bl_source		VARCHAR2(10) := 'AB';  --'indicates lines created for funding auto baseline'
	l_resource_assignment_id_tab     pa_plsql_datatypes.Num15TabTyp;
	l_txn_cur_code_tab		 pa_plsql_datatypes.Char30TabTyp;
        l_start_date_tab                 pa_plsql_datatypes.DateTabTyp;
        l_end_date_tab                   pa_plsql_datatypes.DateTabTyp;
        l_period_name_tab                pa_plsql_datatypes.Char50TabTyp;
        l_budget_line_id_tab             pa_plsql_datatypes.Num15TabTyp;
        l_quantity_tab                   pa_plsql_datatypes.NumTabTyp;
	l_exception_return_status  Varchar2(1);
	l_error_msg_code  Varchar2(1000);
	v_NumErrors 	Number;
	l_x_cntr	Number;
	v_index_position  Number;
	v_error_code      Number;
	l_err_error_code_tab    	pa_plsql_datatypes.Char80TabTyp;
	l_err_budget_line_id_tab	pa_plsql_datatypes.IdTabTyp;
	l_err_raId_tab			pa_plsql_datatypes.IdTabTyp;
	l_err_txn_cur_tab		pa_plsql_datatypes.Char80TabTyp;
	l_err_sdate_tab			pa_plsql_datatypes.DateTabTyp;
	l_err_edate_tab			pa_plsql_datatypes.DateTabTyp;


	PROCEDURE INIT_PLSQL_TABS IS
    	BEGIN
            l_resource_assignment_id_tab.delete;
	    l_txn_cur_code_tab.delete;
            l_start_date_tab.delete;
            l_end_date_tab.delete;
            l_period_name_tab.delete;
	    l_budget_line_id_tab.delete;
	    l_err_error_code_tab.delete;
            l_err_budget_line_id_tab.delete;
            l_err_raId_tab.delete;
            l_err_txn_cur_tab.delete;
            l_err_sdate_tab.delete;
            l_err_edate_tab.delete;
	END;
BEGIN

	x_return_status := 'S';
	IF NVL(p_approved_rev_flag,'N') = 'Y' AND NVL(p_autoBaseLine_flag,'N') = 'Y' Then
		Init_plsql_tabs;
		OPEN cur_tmp1Recs;
		FETCH cur_tmp1Recs BULK COLLECT INTO
			l_resource_assignment_id_tab
            		,l_txn_cur_code_tab
            		,l_start_date_tab
            		,l_end_date_tab
            		,l_period_name_tab
            		,l_budget_line_id_tab;
		CLOSE cur_tmp1Recs;
		--print_msg('Number of lines present in calc_tmp1 table inserted by calling api ['||l_budget_line_id_tab.COUNT||']');
		IF l_budget_line_id_tab.COUNT > 0 THEN --{
		 BEGIN  --{

		  FORALL i IN l_budget_line_id_tab.FIRST .. l_budget_line_id_tab.LAST
			INSERT INTO PA_BUDGET_LINES bl
            		(bl.BUDGET_LINE_ID
			,bl.RESOURCE_ASSIGNMENT_ID --resource_assignment_id
                         ,bl.BUDGET_VERSION_ID     --budget_version_id
                         ,bl.TXN_CURRENCY_CODE     --txn_currency_code
                         ,bl.QUANTITY              --total_qty
                         ,bl.TXN_RAW_COST          --total_raw_cost
                         ,bl.TXN_BURDENED_COST     --total_burdened_cost
                         ,bl.TXN_REVENUE           --total_revenue
                         ,bl.TXN_STANDARD_COST_RATE             --raw_cost_rate
                         ,bl.TXN_COST_RATE_OVERRIDE    --rw_cost_rate_override
                         ,bl.BURDEN_COST_RATE      --b_cost_rate
                         ,bl.BURDEN_COST_RATE_OVERRIDE --b_cost_rate_override
                         ,bl.TXN_STANDARD_BILL_RATE             --bill_rate
                         ,bl.TXN_BILL_RATE_OVERRIDE    --bill_rate_override
                         ,bl.START_DATE            --line_start_date
                         ,bl.END_DATE              --line_end_date
            		 ,bl.PERIOD_NAME
            		 ,bl.PROJECT_CURRENCY_CODE
            		 ,bl.PROJFUNC_CURRENCY_CODE
            		 ,bl.PROJECT_COST_RATE_TYPE
            		 ,bl.PROJECT_COST_EXCHANGE_RATE
            		 ,bl.PROJECT_COST_RATE_DATE_TYPE
            		 ,bl.PROJECT_COST_RATE_DATE
            		 ,bl.PROJECT_REV_RATE_TYPE
            		 ,bl.PROJECT_REV_EXCHANGE_RATE
            		 ,bl.PROJECT_REV_RATE_DATE_TYPE
            		 ,bl.PROJECT_REV_RATE_DATE
            		 ,bl.PROJFUNC_COST_RATE_TYPE
            		 ,bl.PROJFUNC_COST_EXCHANGE_RATE
            		 ,bl.PROJFUNC_COST_RATE_DATE_TYPE
            		 ,bl.PROJFUNC_COST_RATE_DATE
            		 ,bl.PROJFUNC_REV_RATE_TYPE
            		 ,bl.PROJFUNC_REV_EXCHANGE_RATE
            		 ,bl.PROJFUNC_REV_RATE_DATE_TYPE
            		 ,bl.PROJFUNC_REV_RATE_DATE
            		 ,bl.CHANGE_REASON_CODE
            		 ,bl.DESCRIPTION
            		 ,bl.ATTRIBUTE_CATEGORY
            		 ,bl.ATTRIBUTE1
            		 ,bl.ATTRIBUTE2
            		,bl.ATTRIBUTE3
            		,bl.ATTRIBUTE4
            		,bl.ATTRIBUTE5
            		,bl.ATTRIBUTE6
            		,bl.ATTRIBUTE7
            		,bl.ATTRIBUTE8
            		,bl.ATTRIBUTE9
            		,bl.ATTRIBUTE10
            		,bl.ATTRIBUTE11
            		,bl.ATTRIBUTE12
            		,bl.ATTRIBUTE13
            		,bl.ATTRIBUTE14
            		,bl.ATTRIBUTE15
            		,bl.RAW_COST_SOURCE
            		,bl.BURDENED_COST_SOURCE
            		,bl.QUANTITY_SOURCE
            		,bl.REVENUE_SOURCE
            		,bl.PM_PRODUCT_CODE
            		,bl.PM_BUDGET_LINE_REFERENCE
            		,bl.CODE_COMBINATION_ID
            		,bl.CCID_GEN_STATUS_CODE
            		,bl.CCID_GEN_REJ_MESSAGE
            		,bl.BORROWED_REVENUE
            		,bl.TP_REVENUE_IN
            		,bl.TP_REVENUE_OUT
            		,bl.REVENUE_ADJ
            		,bl.LENT_RESOURCE_COST
            		,bl.TP_COST_IN
            		,bl.TP_COST_OUT
            		,bl.COST_ADJ
            		,bl.UNASSIGNED_TIME_COST
            		,bl.UTILIZATION_PERCENT
			,bl.UTILIZATION_HOURS
            		,bl.UTILIZATION_ADJ
            		,bl.CAPACITY
            		,bl.HEAD_COUNT
            		,bl.HEAD_COUNT_ADJ
            		,bl.BUCKETING_PERIOD_CODE
            		,bl.TXN_DISCOUNT_PERCENTAGE
            		,bl.TRANSFER_PRICE_RATE
            		,bl.CREATED_BY
            		,bl.CREATION_DATE
			,bl.LAST_UPDATED_BY
			,bl.LAST_UPDATE_LOGIN
			,bl.LAST_UPDATE_DATE
				)
            		SELECT /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP1_N1) */ l_budget_line_id_tab(i)
			 ,tmp.RESOURCE_ASSIGNMENT_ID --resource_assignment_id
                         ,tmp.BUDGET_VERSION_ID     --budget_version_id
                         ,tmp.TXN_CURRENCY_CODE     --txn_currency_code
                         ,tmp.QUANTITY              --total_qty
                         ,tmp.TXN_RAW_COST          --total_raw_cost
                         ,tmp.TXN_BURDENED_COST     --total_burdened_cost
                         ,tmp.TXN_REVENUE           --total_revenue
                         ,tmp.COST_RATE             --raw_cost_rate
                         ,tmp.COST_RATE_OVERRIDE    --rw_cost_rate_override
                         ,tmp.BURDEN_COST_RATE      --b_cost_rate
                         ,tmp.BURDEN_COST_RATE_OVERRIDE --b_cost_rate_override
                         ,tmp.BILL_RATE             --bill_rate
                         ,tmp.BILL_RATE_OVERRIDE    --bill_rate_override
                         ,tmp.START_DATE            --line_start_date
                         ,tmp.END_DATE              --line_end_date
             		,tmp.PERIOD_NAME
            		,tmp.PROJECT_CURRENCY_CODE
            		,tmp.PROJFUNC_CURRENCY_CODE
            		,tmp.PROJECT_COST_RATE_TYPE
            		,tmp.PROJECT_COST_EXCHANGE_RATE
            		,tmp.PROJECT_COST_RATE_DATE_TYPE
            		,tmp.PROJECT_COST_RATE_DATE
            		,tmp.PROJECT_REV_RATE_TYPE
            		,tmp.PROJECT_REV_EXCHANGE_RATE
            		,tmp.PROJECT_REV_RATE_DATE_TYPE
            		,tmp.PROJECT_REV_RATE_DATE
            		,tmp.PROJFUNC_COST_RATE_TYPE
            		,tmp.PROJFUNC_COST_EXCHANGE_RATE
            		,tmp.PROJFUNC_COST_RATE_DATE_TYPE
            		,tmp.PROJFUNC_COST_RATE_DATE
            		,tmp.PROJFUNC_REV_RATE_TYPE
            		,tmp.PROJFUNC_REV_EXCHANGE_RATE
            		,tmp.PROJFUNC_REV_RATE_DATE_TYPE
            		,tmp.PROJFUNC_REV_RATE_DATE
            		,tmp.CHANGE_REASON_CODE
            		,tmp.DESCRIPTION
            		,tmp.ATTRIBUTE_CATEGORY
            		,tmp.ATTRIBUTE1
            		,tmp.ATTRIBUTE2
            		,tmp.ATTRIBUTE3
            		,tmp.ATTRIBUTE4
            		,tmp.ATTRIBUTE5
            		,tmp.ATTRIBUTE6
            		,tmp.ATTRIBUTE7
            		,tmp.ATTRIBUTE8
            		,tmp.ATTRIBUTE9
            		,tmp.ATTRIBUTE10
            		,tmp.ATTRIBUTE11
            		,tmp.ATTRIBUTE12
            		,tmp.ATTRIBUTE13
            		,tmp.ATTRIBUTE14
            		,tmp.ATTRIBUTE15
            		,NVL(tmp.RAW_COST_SOURCE,l_bl_source)
            		,NVL(tmp.BURDENED_COST_SOURCE,l_bl_source)
            		,NVL(tmp.QUANTITY_SOURCE,l_bl_source)
            		,NVL(tmp.REVENUE_SOURCE,l_bl_source)
            		,tmp.PM_PRODUCT_CODE
            		,tmp.PM_BUDGET_LINE_REFERENCE
            		,tmp.CODE_COMBINATION_ID
            		,tmp.CCID_GEN_STATUS_CODE
            		,tmp.CCID_GEN_REJ_MESSAGE
            		,tmp.BORROWED_REVENUE
            		,tmp.TP_REVENUE_IN
            		,tmp.TP_REVENUE_OUT
            		,tmp.REVENUE_ADJ
            		,tmp.LENT_RESOURCE_COST
            		,tmp.TP_COST_IN
            		,tmp.TP_COST_OUT
            		,tmp.COST_ADJ
            		,tmp.UNASSIGNED_TIME_COST
            		,tmp.UTILIZATION_PERCENT
            		,tmp.UTILIZATION_HOURS
            		,tmp.UTILIZATION_ADJ
            		,tmp.CAPACITY
            		,tmp.HEAD_COUNT
            		,tmp.HEAD_COUNT_ADJ
            		,tmp.BUCKETING_PERIOD_CODE
            		,tmp.TXN_DISCOUNT_PERCENTAGE
            		,tmp.TRANSFER_PRICE_RATE
            		,tmp.BL_CREATED_BY
            		,tmp.BL_CREATION_DATE
			,tmp.BL_CREATED_BY  --last updated by
			,tmp.BL_CREATED_BY  -- lastupdate login
			,trunc(sysdate)    -- last update dated
        		FROM PA_FP_SPREAD_CALC_TMP1 tmp
        		WHERE  tmp.resource_assignment_id = l_resource_assignment_id_tab(i)
        		AND   tmp.txn_currency_code =	l_txn_cur_code_tab(i)
			AND   tmp.start_date = 	l_start_date_tab(i);

		 EXCEPTION
			WHEN OTHERS THEN
        			print_msg('Entered AutoBaseline bulk exception portion');
        			/* Now process the exceptions lines one-by-one */
        			l_exception_return_status := 'S';
            			v_NumErrors := SQL%BULK_EXCEPTIONS.COUNT;
        			l_x_cntr := 0;
        			FOR v_Count IN 1..v_NumErrors LOOP   --{
            			  l_x_cntr := l_x_cntr +1;
                		  v_index_position  :=SQL%BULK_EXCEPTIONS(v_Count).error_index;
                		  v_error_code      :=SQL%BULK_EXCEPTIONS(v_Count).error_code;
            			  l_err_error_code_tab(l_x_cntr)  := SQL%BULK_EXCEPTIONS(v_Count).error_code;
            			  l_err_budget_line_id_tab(l_x_cntr)  := l_budget_line_id_tab(v_index_position);
            			  l_err_raId_tab(l_x_cntr) := l_resource_assignment_id_tab(v_index_position);
            			  l_err_txn_cur_tab(l_x_cntr) := l_txn_cur_code_tab(v_index_position);
            			  l_err_sdate_tab(l_x_cntr)   := l_start_date_tab(v_index_position);
				  l_err_edate_tab(l_x_cntr)   := l_end_date_tab(v_index_position);
				  If v_error_code <> 1 then -- 1 means unique constraint voilation.
            				l_exception_return_status := 'U';
            				x_return_status := l_exception_return_status;
            				l_error_msg_code := SQLERRM(0 - SQL%BULK_EXCEPTIONS(v_Count).error_code);
					print_msg('ErrorRaId['||l_err_raId_tab(l_x_cntr)||']TxnCur['||l_err_txn_cur_tab(l_x_cntr)||']');
				        print_msg('SD['||l_err_sdate_tab(l_x_cntr)||']ED['||l_err_edate_tab(l_x_cntr)||']ErrorCode['||l_error_msg_code);
            				PA_UTILS.ADD_MESSAGE
                        		(p_app_short_name => 'PA'
            				,p_msg_name       => v_error_code||'-'||l_error_msg_code
                    			,p_token1         => 'G_PROJECT_NAME'
                    			,p_value1         => g_project_name
                    			,p_token2         => 'G_RESOURCE_ASSIGNMENT_ID'
                    			,p_value2         => l_err_raId_tab(l_x_cntr)
                    			,p_token3         => 'G_TXN_CURRENCY_CODE'
                    			,p_value3         => l_err_txn_cur_tab(l_x_cntr)
            				,p_token4         => 'G_BUDGET_LINE_ID'
            				,p_value4         => l_err_budget_line_id_tab(l_x_cntr)
            				);
            			  End If;
			        END LOOP; --}
				x_return_status := l_exception_return_status;
		 END; --}
		END IF; --} end of l_budget_line_id_tab.COUNT > 0
	END IF;
	Init_plsql_tabs;
	IF P_PA_DEBUG_MODE = 'Y' Then
	print_msg('Return Status of InsertFunding_ReqdLines api ['||x_return_status||']');
	End If;
EXCEPTION

 	WHEN OTHERS THEN
                x_return_status := 'U';
                print_msg('Error occured in InsertFunding_ReqdLines['|| SQLCODE||SQLERRM);
        	fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_UTILS'
                 ,p_procedure_name => 'InsertFunding_ReqdLines');
                RAISE;

END InsertFunding_ReqdLines;


END PA_FP_CALC_UTILS;

/
