--------------------------------------------------------
--  DDL for Package Body PA_FP_SPREAD_AMTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_SPREAD_AMTS_PKG" AS
--$Header: PAFPSCPB.pls 120.6.12010000.5 2010/05/06 09:53:17 kmaddi ship $

  	g_module_name VARCHAR2(100) := 'pa.plsql.PA_FP_SPREAD_AMTS_PKG';
  	P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
  	G_rate_based_flag   Varchar2(10) := NULL;
  	G_Curr_code         Varchar2(80) := NULL;
	G_User_Id           Number:= fnd_global.user_id;
        G_Login_Id          Number:= fnd_global.login_id;
	G_budget_line_source Varchar2(10) := 'SP';  --Indicates that budget lines are created through spread api

  	/* Declare variables for Bulk Processing of inserting budget lines */
	-- for inserting new budget lines
   	g_bl_res_assignment_id_tab 		pa_plsql_datatypes.NumTabTyp;
   	g_bl_start_date_tab			pa_plsql_datatypes.DateTabTyp;
   	g_bl_end_date_tab			pa_plsql_datatypes.DateTabTyp;
   	g_bl_period_name_tab			pa_plsql_datatypes.Char50TabTyp;
   	g_bl_txn_curr_code_tab			pa_plsql_datatypes.Char50TabTyp;
	g_bl_txn_curr_code_ovr_tab              pa_plsql_datatypes.Char50TabTyp;
   	g_bl_budget_line_id_tab			pa_plsql_datatypes.NumTabTyp;
   	g_bl_budget_version_id_tab		pa_plsql_datatypes.NumTabTyp;
   	g_bl_proj_curr_code_tab			pa_plsql_datatypes.Char50TabTyp;
   	g_bl_projfunc_curr_code_tab		pa_plsql_datatypes.Char50TabTyp;


	-- for inserting rollup tmp lines without budget lines
        g_rl_res_assignment_id_tab              pa_plsql_datatypes.NumTabTyp;
        g_rl_start_date_tab                     pa_plsql_datatypes.DateTabTyp;
        g_rl_end_date_tab                       pa_plsql_datatypes.DateTabTyp;
        g_rl_period_name_tab                    pa_plsql_datatypes.Char50TabTyp;
        g_rl_txn_curr_code_tab                  pa_plsql_datatypes.Char50TabTyp;
        g_rl_txn_curr_code_ovr_tab              pa_plsql_datatypes.Char50TabTyp;
        g_rl_budget_line_id_tab                 pa_plsql_datatypes.NumTabTyp;
        g_rl_budget_version_id_tab              pa_plsql_datatypes.NumTabTyp;
        g_rl_proj_curr_code_tab                 pa_plsql_datatypes.Char50TabTyp;
        g_rl_projfunc_curr_code_tab             pa_plsql_datatypes.Char50TabTyp;
	g_rl_quantity_tab                       pa_plsql_datatypes.NumTabTyp;
	g_rl_txn_raw_cost_tab                   pa_plsql_datatypes.NumTabTyp;
	g_rl_txn_cost_rate_tab                  pa_plsql_datatypes.NumTabTyp;
	g_rl_txn_cost_rate_ovr_tab              pa_plsql_datatypes.NumTabTyp;
	g_rl_txn_burden_cost_tab                pa_plsql_datatypes.NumTabTyp;
	g_rl_txn_burden_rate_tab                pa_plsql_datatypes.NumTabTyp;
	g_rl_txn_burden_rate_ovr_tab            pa_plsql_datatypes.NumTabTyp;
	g_rl_txn_revenue_tab                    pa_plsql_datatypes.NumTabTyp;
	g_rl_txn_bill_rate_tab                  pa_plsql_datatypes.NumTabTyp;
	g_rl_txn_bill_rate_ovr_tab              pa_plsql_datatypes.NumTabTyp;


        -- for inserting rollup tmp lines with budgetlines
        g_rbl_res_assignment_id_tab              pa_plsql_datatypes.NumTabTyp;
        g_rbl_start_date_tab                     pa_plsql_datatypes.DateTabTyp;
        g_rbl_end_date_tab                       pa_plsql_datatypes.DateTabTyp;
        g_rbl_period_name_tab                    pa_plsql_datatypes.Char50TabTyp;
        g_rbl_txn_curr_code_tab                  pa_plsql_datatypes.Char50TabTyp;
        g_rbl_txn_curr_code_ovr_tab              pa_plsql_datatypes.Char50TabTyp;
        g_rbl_budget_line_id_tab                 pa_plsql_datatypes.NumTabTyp;
        g_rbl_budget_version_id_tab              pa_plsql_datatypes.NumTabTyp;
        g_rbl_proj_curr_code_tab                 pa_plsql_datatypes.Char50TabTyp;
        g_rbl_projfunc_curr_code_tab             pa_plsql_datatypes.Char50TabTyp;
        g_rbl_quantity_tab                       pa_plsql_datatypes.NumTabTyp;
        g_rbl_txn_raw_cost_tab                   pa_plsql_datatypes.NumTabTyp;
        g_rbl_txn_cost_rate_tab                  pa_plsql_datatypes.NumTabTyp;
        g_rbl_txn_cost_rate_ovr_tab              pa_plsql_datatypes.NumTabTyp;
        g_rbl_txn_burden_cost_tab                pa_plsql_datatypes.NumTabTyp;
        g_rbl_txn_burden_rate_tab                pa_plsql_datatypes.NumTabTyp;
        g_rbl_txn_burden_rate_ovr_tab            pa_plsql_datatypes.NumTabTyp;
        g_rbl_txn_revenue_tab                    pa_plsql_datatypes.NumTabTyp;
        g_rbl_txn_bill_rate_tab                  pa_plsql_datatypes.NumTabTyp;
        g_rbl_txn_bill_rate_ovr_tab              pa_plsql_datatypes.NumTabTyp;


	-- for bulk update of rounding diff lines
	g_edist_rndiff_quantity			pa_plsql_datatypes.NumTabTyp;
        g_edist_blId				pa_plsql_datatypes.NumTabTyp;
        g_edist_RaId				pa_plsql_datatypes.NumTabTyp;
        g_edist_txn_quantity_addl		pa_plsql_datatypes.NumTabTyp;
        g_edist_txn_plan_quantity		pa_plsql_datatypes.NumTabTyp;
        g_edist_Curcode				pa_plsql_datatypes.Char50TabTyp;
        g_edist_Curcode_ovr			pa_plsql_datatypes.Char50TabTyp;
        g_edist_sdate				pa_plsql_datatypes.DateTabTyp;
        g_edist_edate				pa_plsql_datatypes.DateTabTyp;
        g_edist_etc_sdate			pa_plsql_datatypes.DateTabTyp;
        g_edist_line_start_date			pa_plsql_datatypes.DateTabTyp;
        g_edist_source_context			pa_plsql_datatypes.Char100TabTyp;




  	TYPE spread_record_type IS RECORD
	(start_date	DATE,
	end_date	DATE,
	period_name	gl_periods.period_name%TYPE, --VARCHAR2,
	actual_days	INTEGER,
	actual_periods	NUMBER,
	allocation	NUMBER,
	percentage	NUMBER,
	number_of_amounts	INTEGER,
	amount1		NUMBER,
	amount2		NUMBER,
	amount3		NUMBER,
	amount4		NUMBER,
	amount5		NUMBER,
	amount6		NUMBER,
	amount7		NUMBER,
	amount8		NUMBER,
	amount9		NUMBER,
	amount10	NUMBER
	);


  	TYPE spread_table_type IS TABLE OF spread_record_type;

  	TYPE start_end_date_record_type IS RECORD
	(start_date	DATE,
	end_date	DATE);

  	TYPE start_end_date_table_type IS TABLE OF start_end_date_record_type;

  	TYPE spread_curve_type IS TABLE OF NUMBER;

  	TYPE resource_assignment_rec_type IS RECORD (
		RESOURCE_ASSIGNMENT_ID PA_FP_RES_ASSIGNMENTS_TMP.RESOURCE_ASSIGNMENT_ID%TYPE
		,BUDGET_VERSION_ID 	PA_FP_RES_ASSIGNMENTS_TMP.BUDGET_VERSION_ID%TYPE
		,PROJECT_ID 		PA_FP_RES_ASSIGNMENTS_TMP.PROJECT_ID%TYPE
		,TASK_ID 		PA_FP_RES_ASSIGNMENTS_TMP.TASK_ID%TYPE
		,RESOURCE_LIST_MEMBER_ID PA_FP_RES_ASSIGNMENTS_TMP.RESOURCE_LIST_MEMBER_ID%TYPE
		,PLANNING_START_DATE 	PA_FP_RES_ASSIGNMENTS_TMP.PLANNING_START_DATE%TYPE
		,PLANNING_END_DATE 	PA_FP_RES_ASSIGNMENTS_TMP.PLANNING_END_DATE%TYPE
		,SPREAD_CURVE_ID 	PA_FP_RES_ASSIGNMENTS_TMP.SPREAD_CURVE_ID%TYPE
		,SP_FIXED_DATE 		PA_FP_RES_ASSIGNMENTS_TMP.SP_FIXED_DATE%TYPE
		,TXN_CURRENCY_CODE 	PA_FP_RES_ASSIGNMENTS_TMP.TXN_CURRENCY_CODE%TYPE
		,TXN_CURRENCY_CODE_OVERRIDE PA_FP_RES_ASSIGNMENTS_TMP.TXN_CURRENCY_CODE%TYPE
		,PROJECT_CURRENCY_CODE 	PA_FP_RES_ASSIGNMENTS_TMP.TXN_CURRENCY_CODE%TYPE
		,PROJFUNC_CURRENCY_CODE PA_FP_RES_ASSIGNMENTS_TMP.TXN_CURRENCY_CODE%TYPE
		,TXN_REVENUE 		PA_FP_RES_ASSIGNMENTS_TMP.TXN_REVENUE%TYPE
		,TXN_REVENUE_ADDL 	PA_FP_RES_ASSIGNMENTS_TMP.TXN_REVENUE_ADDL%TYPE
		,TXN_RAW_COST 		PA_FP_RES_ASSIGNMENTS_TMP.TXN_RAW_COST%TYPE
		,TXN_RAW_COST_ADDL 	PA_FP_RES_ASSIGNMENTS_TMP.TXN_RAW_COST_ADDL%TYPE
		,TXN_BURDENED_COST 	PA_FP_RES_ASSIGNMENTS_TMP.TXN_BURDENED_COST%TYPE
		,TXN_BURDENED_COST_ADDL PA_FP_RES_ASSIGNMENTS_TMP.TXN_BURDENED_COST_ADDL%TYPE
		,TXN_PLAN_QUANTITY 	PA_FP_RES_ASSIGNMENTS_TMP.TXN_PLAN_QUANTITY%TYPE
		,TXN_PLAN_QUANTITY_ADDL PA_FP_RES_ASSIGNMENTS_TMP.TXN_PLAN_QUANTITY_ADDL%TYPE
		,LINE_START_DATE 	PA_FP_RES_ASSIGNMENTS_TMP.LINE_START_DATE%TYPE
		,LINE_END_DATE 		PA_FP_RES_ASSIGNMENTS_TMP.LINE_END_DATE%TYPE
		,SOURCE_CONTEXT 	PA_FP_RES_ASSIGNMENTS_TMP.SOURCE_CONTEXT%TYPE
		,RAW_COST_RATE 		PA_FP_RES_ASSIGNMENTS_TMP.RAW_COST_RATE%TYPE
		,RAW_COST_RATE_OVERRIDE PA_FP_RES_ASSIGNMENTS_TMP.RW_COST_RATE_OVERRIDE%TYPE
		,BURDEN_COST_RATE 	PA_FP_RES_ASSIGNMENTS_TMP.BURDEN_COST_RATE%TYPE
		,BURDEN_COST_RATE_OVERRIDE PA_FP_RES_ASSIGNMENTS_TMP.BURDEN_COST_RATE_OVERRIDE%TYPE
		,BILL_RATE 		PA_FP_RES_ASSIGNMENTS_TMP.BILL_RATE%TYPE
		,BILL_RATE_OVERRIDE 	PA_FP_RES_ASSIGNMENTS_TMP.BILL_RATE_OVERRIDE%TYPE
		,RATE_BASED_FLAG 	PA_FP_RES_ASSIGNMENTS_TMP.RATE_BASED_FLAG%TYPE
		,SPREAD_AMOUNTS_FLAG 	PA_FP_RES_ASSIGNMENTS_TMP.SPREAD_AMOUNTS_FLAG%TYPE
		,INIT_QUANTITY          NUMBER
		,TXN_INIT_RAW_COST      NUMBER
		,TXN_INIT_BURDENED_COST NUMBER
		,TXN_INIT_REVENUE       NUMBER
		);
/**
procedure calc_log(p_msg  varchar2) IS

        pragma autonomous_transaction ;
BEGIN
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
      IF P_PA_DEBUG_MODE = 'Y' Then
	pa_debug.g_err_stage := substr('LOG:'||p_msg,1,240);
        PA_DEBUG.write
                (x_Module       => g_module_name
                ,x_Msg          => pa_debug.g_err_stage
                ,x_Log_Level    => 3);
	null;
      END IF;
END PRINT_MSG;

PROCEDURE Process_Rounding_Diff(p_budget_version_id IN NUMBER
                               ,x_return_status     OUT NOCOPY VARCHAR2
                               ) IS
	v_total_quantity 	NUMBER := 0;
	v_bl_total_quantity 	NUMBER := 0;
	l_cntr  NUMBER := 0;
	l_stage   Varchar2(1000);

BEGIN
	x_return_status := 'S';
	l_stage := 'Entered Process_Rounding_Diff API';
	print_msg(l_stage);
	IF g_edist_blId.COUNT > 0 THEN
	   l_cntr := 0;
	   FOR i IN g_edist_blId.FIRST .. g_edist_blId.LAST LOOP
		l_cntr := l_cntr + 1;
		g_edist_rndiff_quantity(l_cntr) := 0;
		v_total_quantity 	:= 0;
		v_bl_total_quantity 	:= 0;

		Begin
			l_stage := 'Get sum of quantity from rollup tmp';
		        --print_msg(l_stage);
			SELECT sum(nvl(bl.quantity,0))
			INTO v_total_quantity
			FROM pa_fp_rollup_tmp bl
			WHERE bl.RESOURCE_ASSIGNMENT_ID = g_edist_RaId(i)
			AND bl.TXN_CURRENCY_CODE = NVL(g_edist_Curcode_ovr(i),g_edist_Curcode(i))
                	AND bl.START_DATE BETWEEN g_edist_sdate(i) AND g_edist_edate(i)
                	AND bl.END_DATE BETWEEN   g_edist_sdate(i) AND g_edist_edate(i)
                	AND bl.PERIOD_NAME IS NOT NULL;
		Exception
				when no_data_found then
					v_total_quantity := 0;
		End;

		If g_edist_etc_sdate(i) is NOT NULL Then
                        /* Bug fix: 3844739 getting the totals from budgetlines prior to ETC start date to get the sum of total
		         * this is required as the total ra Plan quantity is always includes the lines prior to ETC start date
			 */
                    Begin
			l_stage := 'Get sum of quantity from from bl prior to etc start date';
		        --print_msg(l_stage);
                        SELECT sum(nvl(bl.quantity,0))
                        INTO v_bl_total_quantity
                        FROM pa_budget_lines bl
			    ,pa_fp_res_assignments_tmp rtmp
                        WHERE bl.budget_version_id = p_budget_version_id
			AND  bl.RESOURCE_ASSIGNMENT_ID = g_edist_RaId(i)
                        AND  bl.TXN_CURRENCY_CODE = g_edist_Curcode(i)
			AND  bl.budget_version_id = rtmp.budget_version_id
			AND  rtmp.resource_assignment_id = bl.resource_assignment_id
			AND  rtmp.txn_currency_code = bl.txn_currency_code
			AND  ((rtmp.SOURCE_CONTEXT  = 'BUDGET_LINE'
			      AND rtmp.LINE_START_DATE = g_edist_line_start_date(i))
			      OR
			      rtmp.SOURCE_CONTEXT  <> 'BUDGET_LINE'
			     )
			AND bl.START_DATE BETWEEN decode(rtmp.SOURCE_CONTEXT,'BUDGET_LINE',rtmp.LINE_START_DATE
                                                   ,decode(sign(bl.START_DATE - rtmp.planning_start_date),-1,bl.START_DATE,rtmp.planning_start_date))
						AND decode(rtmp.SOURCE_CONTEXT,'BUDGET_LINE',rtmp.LINE_END_DATE,rtmp.planning_end_date)
                        AND bl.END_DATE BETWEEN decode(rtmp.SOURCE_CONTEXT,'BUDGET_LINE',rtmp.LINE_START_DATE,rtmp.planning_start_date )
						AND decode(rtmp.SOURCE_CONTEXT,'BUDGET_LINE',rtmp.LINE_END_DATE
                                                     ,decode(sign(bl.END_DATE - rtmp.planning_end_date),1,bl.END_DATE,rtmp.planning_end_date))
			AND bl.END_DATE < g_edist_etc_sdate(i)
                        AND bl.PERIOD_NAME IS NOT NULL;
                    Exception
                                when no_data_found then
                                        v_bl_total_quantity := 0;
                    End;
		End If;
            	g_edist_rndiff_quantity(l_cntr) := nvl(g_edist_txn_plan_quantity(i),0) - (nvl(v_total_quantity,0)+ nvl(v_bl_total_quantity,0));
		--print_msg('Last Bl with diffamt rndiff_quantity['||g_edist_rndiff_quantity(l_cntr)||']');
	   END LOOP;
	END IF;

	/* bulk update the rollup tmp with spread rounding diff amount */
	IF g_edist_blId.COUNT > 0 THEN
	   l_stage := 'Finally one bulk update of rollup tmp lines ';
	   print_msg(l_stage);
           FORALL i IN g_edist_blId.FIRST .. g_edist_blId.LAST
                UPDATE PA_FP_ROLLUP_TMP tmp
                SET tmp.QUANTITY = decode(NVL(g_edist_txn_quantity_addl(i),0),0,tmp.QUANTITY,(nvl(tmp.QUANTITY,0)+g_edist_rndiff_quantity(i)))
                WHERE tmp.budget_version_id = p_budget_version_id
		AND  tmp.BUDGET_LINE_ID = g_edist_blId(i);
	END IF;

EXCEPTION

        WHEN OTHERS THEN
                print_msg('Unexpected error in Process_Rounding_Diff ['||sqlcode||sqlerrm||']');
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_FP_SPREAD_AMTS_PKG',
                                        p_procedure_name => 'Process_Rounding_Diff'||l_stage);
		If p_pa_debug_mode = 'Y' Then
                	pa_debug.reset_err_stack;
		End If;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;

END Process_Rounding_Diff;

PROCEDURE Initialize_spread_plsqlTabs IS

BEGIN

   	g_bl_res_assignment_id_tab.delete;
   	g_bl_start_date_tab.delete;
   	g_bl_end_date_tab.delete;
   	g_bl_period_name_tab.delete;
   	g_bl_txn_curr_code_tab.delete;
	g_bl_txn_curr_code_ovr_tab.delete;
   	g_bl_budget_line_id_tab.delete;
   	g_bl_budget_version_id_tab.delete;
   	g_bl_proj_curr_code_tab.delete;
   	g_bl_projfunc_curr_code_tab.delete;

	-- for inserting rollup tmp lines without budget lines
        g_rl_res_assignment_id_tab.delete;
        g_rl_start_date_tab.delete;
        g_rl_end_date_tab.delete;
        g_rl_period_name_tab.delete;
        g_rl_txn_curr_code_tab.delete;
        g_rl_txn_curr_code_ovr_tab.delete;
        g_rl_budget_line_id_tab.delete;
        g_rl_budget_version_id_tab.delete;
        g_rl_proj_curr_code_tab.delete;
        g_rl_projfunc_curr_code_tab.delete;
	g_rl_quantity_tab.delete;
	g_rl_txn_raw_cost_tab.delete;
	g_rl_txn_cost_rate_tab.delete;
	g_rl_txn_cost_rate_ovr_tab.delete;
	g_rl_txn_burden_cost_tab.delete;
	g_rl_txn_burden_rate_tab.delete;
	g_rl_txn_burden_rate_ovr_tab.delete;
	g_rl_txn_revenue_tab.delete;
	g_rl_txn_bill_rate_tab.delete;
	g_rl_txn_bill_rate_ovr_tab.delete;

        -- for inserting rollup tmp lines with budgetlines
        g_rbl_res_assignment_id_tab.delete;
        g_rbl_start_date_tab.delete;
        g_rbl_end_date_tab.delete;
        g_rbl_period_name_tab.delete;
        g_rbl_txn_curr_code_tab.delete;
        g_rbl_txn_curr_code_ovr_tab.delete;
        g_rbl_budget_line_id_tab.delete;
        g_rbl_budget_version_id_tab.delete;
        g_rbl_proj_curr_code_tab.delete;
        g_rbl_projfunc_curr_code_tab.delete;
        g_rbl_quantity_tab.delete;
        g_rbl_txn_raw_cost_tab.delete;
        g_rbl_txn_cost_rate_tab.delete;
        g_rbl_txn_cost_rate_ovr_tab.delete;
        g_rbl_txn_burden_cost_tab.delete;
        g_rbl_txn_burden_rate_tab.delete;
        g_rbl_txn_burden_rate_ovr_tab.delete;
        g_rbl_txn_revenue_tab.delete;
        g_rbl_txn_bill_rate_tab.delete;
        g_rbl_txn_bill_rate_ovr_tab.delete;

	-- for bulk update of rollup tmp lines with rounding diff amounts
	g_edist_rndiff_quantity.delete;
        g_edist_blId.delete;
        g_edist_RaId.delete;
        g_edist_txn_quantity_addl.delete;
        g_edist_txn_plan_quantity.delete;
        g_edist_Curcode.delete;
        g_edist_Curcode_ovr.delete;
        g_edist_sdate.delete;
        g_edist_edate.delete;
        g_edist_etc_sdate.delete;
        g_edist_line_start_date.delete;
        g_edist_source_context.delete;

END Initialize_spread_plsqlTabs;

/* This API bulk inserts the budget lines from plsql tables*/
PROCEDURE blkInsertBudgetLines(x_return_status	OUT NOCOPY Varchar2)  IS

	l_stage 	varchar2(1000);

BEGIN
	x_return_status := 'S';

	IF g_bl_res_assignment_id_tab.COUNT > 0 THEN
		l_stage := 'Bulk Insert of Budget Lines';
		FORALL i IN g_bl_res_assignment_id_tab.FIRST .. g_bl_res_assignment_id_tab.LAST
			INSERT INTO PA_BUDGET_LINES
				(
                                BUDGET_LINE_ID
                                ,BUDGET_VERSION_ID
                                ,RESOURCE_ASSIGNMENT_ID
                                ,START_DATE
                                ,END_DATE
                                ,PERIOD_NAME
                                ,TXN_CURRENCY_CODE
                                ,PROJECT_CURRENCY_CODE
                                ,PROJFUNC_CURRENCY_CODE
                                ,CREATED_BY
                                ,CREATION_DATE
                                ,LAST_UPDATED_BY
                                ,LAST_UPDATE_DATE
                                ,LAST_UPDATE_LOGIN
				,QUANTITY_SOURCE
				,RAW_COST_SOURCE
				,BURDENED_COST_SOURCE
				,REVENUE_SOURCE
				)
			VALUES (
                                g_bl_budget_line_id_tab(i)
                                ,g_bl_budget_version_id_tab(i)
                                ,g_bl_res_assignment_id_tab(i)
                                ,g_bl_start_date_tab(i)
                                ,g_bl_end_date_tab(i)
                                ,g_bl_period_name_tab(i)
                                ,NVL(g_bl_txn_curr_code_ovr_tab(i),g_bl_txn_curr_code_tab(i))
                                ,g_bl_proj_curr_code_tab(i)
                                ,g_bl_projfunc_curr_code_tab(i)
                                ,g_user_id
                                ,SYSDATE
                                ,g_user_id
				,SYSDATE
                                ,g_login_id
				,G_BUDGET_LINE_SOURCE
				,G_BUDGET_LINE_SOURCE
				,G_BUDGET_LINE_SOURCE
				,G_BUDGET_LINE_SOURCE
				);
	END IF;
EXCEPTION

        WHEN OTHERS THEN
                print_msg('Unexpected error in blkInsertBudgetLines['||sqlcode||sqlerrm||']');
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_FP_SPREAD_AMTS_PKG',
                                        p_procedure_name => 'blkInsertBudgetLines'||l_stage);
		If p_pa_debug_mode = 'Y' Then
                	pa_debug.reset_err_stack;
		End If;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
END blkInsertBudgetLines;

/* This API bulk inserts the lines into pa_fp_rollup_tmp from plsql tables */
PROCEDURE blkInsertFpLines(x_return_status  OUT NOCOPY Varchar2) IS

	l_stage         varchar2(1000);
BEGIN
	x_return_status := 'S';
        IF g_rl_res_assignment_id_tab.COUNT > 0 THEN
		l_stage := 'Bulk Insert of Fp rollup Tmp lines';
                FORALL i IN g_rl_res_assignment_id_tab.FIRST .. g_rl_res_assignment_id_tab.LAST
                        INSERT INTO PA_FP_ROLLUP_TMP
                                (
                                BUDGET_LINE_ID
                                ,BUDGET_VERSION_ID
                                ,RESOURCE_ASSIGNMENT_ID
                                ,START_DATE
                                ,END_DATE
                                ,PERIOD_NAME
                                ,TXN_CURRENCY_CODE
                                ,PROJECT_CURRENCY_CODE
                                ,PROJFUNC_CURRENCY_CODE
				,QUANTITY
                                ,TXN_RAW_COST
                                ,COST_RATE
                                ,RW_COST_RATE_OVERRIDE
                                ,TXN_BURDENED_COST
                                ,BURDEN_COST_RATE
                                ,BURDEN_COST_RATE_OVERRIDE
                                ,TXN_REVENUE
                                ,BILL_RATE
                                ,BILL_RATE_OVERRIDE
				,QUANTITY_SOURCE
				,RAW_COST_SOURCE
				,BURDENED_COST_SOURCE
				,REVENUE_SOURCE
                                )
                        VALUES (
                                g_rl_budget_line_id_tab(i)
                                ,g_rl_budget_version_id_tab(i)
                                ,g_rl_res_assignment_id_tab(i)
                                ,g_rl_start_date_tab(i)
                                ,g_rl_end_date_tab(i)
                                ,g_rl_period_name_tab(i)
                                ,NVL(g_rl_txn_curr_code_ovr_tab(i),g_rl_txn_curr_code_tab(i))
                                ,g_rl_proj_curr_code_tab(i)
                                ,g_rl_projfunc_curr_code_tab(i)
				,decode(g_rl_quantity_tab(i),0,NULL,g_rl_quantity_tab(i))
        			,decode(g_rl_txn_raw_cost_tab(i),0,NULL,g_rl_txn_raw_cost_tab(i))
        			,decode(g_rl_txn_cost_rate_tab(i),0,NULL,g_rl_txn_cost_rate_tab(i))
				/* bug fix:4693839 : removed decode to have 0,NULL for override rates */
        			--,decode(g_rl_txn_cost_rate_ovr_tab(i),0,NULL,g_rl_txn_cost_rate_ovr_tab(i))
				,g_rl_txn_cost_rate_ovr_tab(i)
        			,decode(g_rl_txn_burden_cost_tab(i),0,NULL,g_rl_txn_burden_cost_tab(i))
        			,decode(g_rl_txn_burden_rate_tab(i),0,NULL,g_rl_txn_burden_rate_tab(i))
        			--,decode(g_rl_txn_burden_rate_ovr_tab(i),0,NULL,g_rl_txn_burden_rate_ovr_tab(i))
				,g_rl_txn_burden_rate_ovr_tab(i)
        			,decode(g_rl_txn_revenue_tab(i),0,NULL,g_rl_txn_revenue_tab(i))
        			,decode(g_rl_txn_bill_rate_tab(i),0,NULL,g_rl_txn_bill_rate_tab(i))
        			--,decode(g_rl_txn_bill_rate_ovr_tab(i),0,NULL,g_rl_txn_bill_rate_ovr_tab(i))
				,g_rl_txn_bill_rate_ovr_tab(i)
				,G_BUDGET_LINE_SOURCE
				,G_BUDGET_LINE_SOURCE
				,G_BUDGET_LINE_SOURCE
				,G_BUDGET_LINE_SOURCE
				);
        END IF;

EXCEPTION

        WHEN OTHERS THEN
                print_msg('Unexpected error in blkInsertFpLines['||sqlcode||sqlerrm||']');
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_FP_SPREAD_AMTS_PKG',
                                        p_procedure_name => 'blkInsertFpLines'||l_stage);
		If p_pa_debug_mode = 'Y' Then
                	pa_debug.reset_err_stack;
		End If;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;

END blkInsertFpLines;

/* This API bulk inserts lines into pa_fp_rollup_tmp from pa_budget_lines */
PROCEDURE blkInsertBlFpLines(x_return_status  OUT NOCOPY Varchar2) IS

	l_stage         varchar2(1000);
BEGIN
	x_return_status := 'S';
        IF g_rbl_budget_line_id_tab.COUNT > 0 THEN
		l_stage := 'Bulk Insert of rollup Tmp with Budget Lines';
                FORALL i IN g_rbl_budget_line_id_tab.FIRST .. g_rbl_budget_line_id_tab.LAST

                /* Bug Fix 4332086
                Whenever currency is overridden along with a change in quantity in the workplan flow
                in Update Task Details page, the following piece of code gets executed.

                This code caches several attributes from pa_budget_lines table and will use them in the
                later part of the flow, thus causing the above bug. When ever currency code is overwritten
                we need to use the new currency's conversion attributes, but where as this code will use
                old currency's conversion attributes.

                As a fix the following insert is commented out and a new insert is written with a change
                in the select statement of values clause.

                        INSERT INTO  PA_FP_ROLLUP_TMP
                                (
                                BUDGET_LINE_ID
                                ,BUDGET_VERSION_ID
                                ,RESOURCE_ASSIGNMENT_ID
                                ,START_DATE
                                ,END_DATE
                                ,PERIOD_NAME
                                ,TXN_CURRENCY_CODE
                                ,PROJECT_CURRENCY_CODE
                                ,PROJFUNC_CURRENCY_CODE
                                ,QUANTITY
                                ,TXN_RAW_COST
                                ,COST_RATE
                                ,RW_COST_RATE_OVERRIDE
                                ,TXN_BURDENED_COST
                                ,BURDEN_COST_RATE
                                ,BURDEN_COST_RATE_OVERRIDE
                                ,TXN_REVENUE
                                ,BILL_RATE
                                ,BILL_RATE_OVERRIDE
				,PROJFUNC_RAW_COST
                		,PROJFUNC_BURDENED_COST
                		,PROJFUNC_REVENUE
                		,COST_REJECTION_CODE
                		,REVENUE_REJECTION_CODE
                		,BURDEN_REJECTION_CODE
                		,PROJFUNC_COST_RATE_TYPE
                		,PROJFUNC_COST_EXCHANGE_RATE
                		,PROJFUNC_COST_RATE_DATE_TYPE
                		,PROJFUNC_COST_RATE_DATE
                		,PROJFUNC_REV_RATE_TYPE
                		,PROJFUNC_REV_EXCHANGE_RATE
                		,PROJFUNC_REV_RATE_DATE_TYPE
                		,PROJFUNC_REV_RATE_DATE
                		,PROJECT_COST_RATE_TYPE
                		,PROJECT_COST_EXCHANGE_RATE
                		,PROJECT_COST_RATE_DATE_TYPE
                		,PROJECT_COST_RATE_DATE
                		,PROJECT_RAW_COST
                		,PROJECT_BURDENED_COST
                		,PROJECT_REV_RATE_TYPE
                		,PROJECT_REV_EXCHANGE_RATE
                		,PROJECT_REV_RATE_DATE_TYPE
                		,PROJECT_REV_RATE_DATE
                		,PROJECT_REVENUE
                		,INIT_QUANTITY
                		,TXN_INIT_RAW_COST
                		,TXN_INIT_BURDENED_COST
                		,TXN_INIT_REVENUE
                		,BILL_MARKUP_PERCENTAGE
                		,COST_IND_COMPILED_SET_ID
				,QUANTITY_SOURCE
				,RAW_COST_SOURCE
				,BURDENED_COST_SOURCE
				,REVENUE_SOURCE
				,INIT_RAW_COST
				,INIT_BURDENED_COST
				,INIT_REVENUE
				,PROJECT_INIT_RAW_COST
				,PROJECT_INIT_BURDENED_COST
				,PROJECT_INIT_REVENUE
                                )
                        SELECT
                                g_rbl_budget_line_id_tab(i)
                                ,g_rbl_budget_version_id_tab(i)
                                ,g_rbl_res_assignment_id_tab(i)
                                ,g_rbl_start_date_tab(i)
                                ,g_rbl_end_date_tab(i)
                                ,g_rbl_period_name_tab(i)
                                ,NVL(g_rbl_txn_curr_code_ovr_tab(i),g_rbl_txn_curr_code_tab(i))
                                ,g_rbl_proj_curr_code_tab(i)
                                ,g_rbl_projfunc_curr_code_tab(i)
                                ,decode(g_rbl_quantity_tab(i),0,NULL,g_rbl_quantity_tab(i))
                                ,decode(g_rbl_txn_raw_cost_tab(i),0,NULL,g_rbl_txn_raw_cost_tab(i))
                                ,decode(g_rbl_txn_cost_rate_tab(i),0,NULL,g_rbl_txn_cost_rate_tab(i))
                                ,decode(g_rbl_txn_curr_code_ovr_tab(i),NULL,NVL(g_rbl_txn_cost_rate_ovr_tab(i),bl.txn_cost_rate_override)
					 ,g_rbl_txn_cost_rate_ovr_tab(i))
                                ,decode(g_rbl_txn_burden_cost_tab(i),0,NULL,g_rbl_txn_burden_cost_tab(i))
                                ,decode(g_rbl_txn_burden_rate_tab(i),0,NULL,g_rbl_txn_burden_rate_tab(i))
                                ,decode(g_rbl_txn_curr_code_ovr_tab(i),NULL,NVL(g_rbl_txn_burden_rate_ovr_tab(i),bl.burden_cost_rate_override)
					,g_rbl_txn_burden_rate_ovr_tab(i))
                                ,decode(g_rbl_txn_revenue_tab(i),0,NULL,g_rbl_txn_revenue_tab(i))
                                ,decode(g_rbl_txn_bill_rate_tab(i),0,NULL,g_rbl_txn_bill_rate_tab(i))
                                ,decode(g_rbl_txn_curr_code_ovr_tab(i),NULL,NVL(g_rbl_txn_bill_rate_ovr_tab(i),bl.txn_bill_rate_override)
					,g_rbl_txn_bill_rate_ovr_tab(i))
				,bl.RAW_COST
                                ,bl.BURDENED_COST
                                ,bl.REVENUE
                                ,bl.COST_REJECTION_CODE
                                ,bl.REVENUE_REJECTION_CODE
                                ,bl.BURDEN_REJECTION_CODE
                                ,bl.PROJFUNC_COST_RATE_TYPE
                                ,bl.PROJFUNC_COST_EXCHANGE_RATE
                                ,bl.PROJFUNC_COST_RATE_DATE_TYPE
                                ,bl.PROJFUNC_COST_RATE_DATE
                                ,bl.PROJFUNC_REV_RATE_TYPE
                                ,bl.PROJFUNC_REV_EXCHANGE_RATE
                                ,bl.PROJFUNC_REV_RATE_DATE_TYPE
                                ,bl.PROJFUNC_REV_RATE_DATE
                                ,bl.PROJECT_COST_RATE_TYPE
                                ,bl.PROJECT_COST_EXCHANGE_RATE
                                ,bl.PROJECT_COST_RATE_DATE_TYPE
                                ,bl.PROJECT_COST_RATE_DATE
                                ,bl.PROJECT_RAW_COST
                                ,bl.PROJECT_BURDENED_COST
                                ,bl.PROJECT_REV_RATE_TYPE
                                ,bl.PROJECT_REV_EXCHANGE_RATE
                                ,bl.PROJECT_REV_RATE_DATE_TYPE
                                ,bl.PROJECT_REV_RATE_DATE
                                ,bl.PROJECT_REVENUE
                                ,bl.INIT_QUANTITY
                                ,bl.TXN_INIT_RAW_COST
                                ,bl.TXN_INIT_BURDENED_COST
                                ,bl.TXN_INIT_REVENUE
                                ,bl.TXN_MARKUP_PERCENT
                                ,bl.COST_IND_COMPILED_SET_ID
				,bl.QUANTITY_SOURCE
				,bl.RAW_COST_SOURCE
				,bl.BURDENED_COST_SOURCE
				,bl.REVENUE_SOURCE
				,bl.INIT_RAW_COST
                                ,bl.INIT_BURDENED_COST
                                ,bl.INIT_REVENUE
                                ,bl.PROJECT_INIT_RAW_COST
                                ,bl.PROJECT_INIT_BURDENED_COST
                                ,bl.PROJECT_INIT_REVENUE
                        FROM PA_BUDGET_LINES bl
			WHERE bl.budget_line_id = g_rbl_budget_line_id_tab(i)

                        End of Bug Fix 4332086.
                        */

                        INSERT INTO  PA_FP_ROLLUP_TMP
                                (
                                BUDGET_LINE_ID
                                ,BUDGET_VERSION_ID
                                ,RESOURCE_ASSIGNMENT_ID
                                ,START_DATE
                                ,END_DATE
                                ,PERIOD_NAME
                                ,TXN_CURRENCY_CODE
                                ,PROJECT_CURRENCY_CODE
                                ,PROJFUNC_CURRENCY_CODE
                                ,QUANTITY
                                ,TXN_RAW_COST
                                ,COST_RATE
                                ,RW_COST_RATE_OVERRIDE
                                ,TXN_BURDENED_COST
                                ,BURDEN_COST_RATE
                                ,BURDEN_COST_RATE_OVERRIDE
                                ,TXN_REVENUE
                                ,BILL_RATE
                                ,BILL_RATE_OVERRIDE
				,PROJFUNC_RAW_COST
                		,PROJFUNC_BURDENED_COST
                		,PROJFUNC_REVENUE
                		,COST_REJECTION_CODE
                		,REVENUE_REJECTION_CODE
                		,BURDEN_REJECTION_CODE
                		,PROJFUNC_COST_RATE_TYPE
                		,PROJFUNC_COST_EXCHANGE_RATE
                		,PROJFUNC_COST_RATE_DATE_TYPE
                		,PROJFUNC_COST_RATE_DATE
                		,PROJFUNC_REV_RATE_TYPE
                		,PROJFUNC_REV_EXCHANGE_RATE
                		,PROJFUNC_REV_RATE_DATE_TYPE
                		,PROJFUNC_REV_RATE_DATE
                		,PROJECT_COST_RATE_TYPE
                		,PROJECT_COST_EXCHANGE_RATE
                		,PROJECT_COST_RATE_DATE_TYPE
                		,PROJECT_COST_RATE_DATE
                		,PROJECT_RAW_COST
                		,PROJECT_BURDENED_COST
                		,PROJECT_REV_RATE_TYPE
                		,PROJECT_REV_EXCHANGE_RATE
                		,PROJECT_REV_RATE_DATE_TYPE
                		,PROJECT_REV_RATE_DATE
                		,PROJECT_REVENUE
                		,INIT_QUANTITY
                		,TXN_INIT_RAW_COST
                		,TXN_INIT_BURDENED_COST
                		,TXN_INIT_REVENUE
                		,BILL_MARKUP_PERCENTAGE
                		,COST_IND_COMPILED_SET_ID
				,QUANTITY_SOURCE
				,RAW_COST_SOURCE
				,BURDENED_COST_SOURCE
				,REVENUE_SOURCE
				,INIT_RAW_COST
				,INIT_BURDENED_COST
				,INIT_REVENUE
				,PROJECT_INIT_RAW_COST
				,PROJECT_INIT_BURDENED_COST
				,PROJECT_INIT_REVENUE
                                )
                        SELECT
                                 g_rbl_budget_line_id_tab(i)
                                ,g_rbl_budget_version_id_tab(i)
                                ,g_rbl_res_assignment_id_tab(i)
                                ,g_rbl_start_date_tab(i)
                                ,g_rbl_end_date_tab(i)
                                ,g_rbl_period_name_tab(i)
                                ,NVL(g_rbl_txn_curr_code_ovr_tab(i),g_rbl_txn_curr_code_tab(i))
                                ,g_rbl_proj_curr_code_tab(i)
                                ,g_rbl_projfunc_curr_code_tab(i)
                                ,decode(g_rbl_quantity_tab(i),0,NULL,g_rbl_quantity_tab(i))
                                ,decode(g_rbl_txn_raw_cost_tab(i),0,NULL,g_rbl_txn_raw_cost_tab(i))
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,decode(g_rbl_txn_cost_rate_tab(i),0,NULL,g_rbl_txn_cost_rate_tab(i)),NULL)
,decode(g_rbl_txn_curr_code_ovr_tab(i),NULL,NVL(g_rbl_txn_cost_rate_ovr_tab(i),bl.txn_cost_rate_override),g_rbl_txn_cost_rate_ovr_tab(i))
                                ,decode(g_rbl_txn_burden_cost_tab(i),0,NULL,g_rbl_txn_burden_cost_tab(i))
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,decode(g_rbl_txn_burden_rate_tab(i),0,NULL,g_rbl_txn_burden_rate_tab(i)),NULL)
                                ,decode(g_rbl_txn_curr_code_ovr_tab(i),NULL,NVL(g_rbl_txn_burden_rate_ovr_tab(i),bl.burden_cost_rate_override),g_rbl_txn_burden_rate_ovr_tab(i))
                                ,decode(g_rbl_txn_revenue_tab(i),0,NULL,g_rbl_txn_revenue_tab(i))
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,decode(g_rbl_txn_bill_rate_tab(i),0,NULL,g_rbl_txn_bill_rate_tab(i)),NULL)
,decode(g_rbl_txn_curr_code_ovr_tab(i),NULL,NVL(g_rbl_txn_bill_rate_ovr_tab(i),bl.txn_bill_rate_override),g_rbl_txn_bill_rate_ovr_tab(i))
            			,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.RAW_COST,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.BURDENED_COST,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.REVENUE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.COST_REJECTION_CODE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.REVENUE_REJECTION_CODE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.BURDEN_REJECTION_CODE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJFUNC_COST_RATE_TYPE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJFUNC_COST_EXCHANGE_RATE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJFUNC_COST_RATE_DATE_TYPE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJFUNC_COST_RATE_DATE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJFUNC_REV_RATE_TYPE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJFUNC_REV_EXCHANGE_RATE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJFUNC_REV_RATE_DATE_TYPE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJFUNC_REV_RATE_DATE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJECT_COST_RATE_TYPE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJECT_COST_EXCHANGE_RATE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJECT_COST_RATE_DATE_TYPE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJECT_COST_RATE_DATE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJECT_RAW_COST,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJECT_BURDENED_COST,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJECT_REV_RATE_TYPE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJECT_REV_EXCHANGE_RATE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJECT_REV_RATE_DATE_TYPE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJECT_REV_RATE_DATE,NULL)
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.PROJECT_REVENUE,NULL)
                                ,bl.INIT_QUANTITY
                                ,bl.TXN_INIT_RAW_COST
                                ,bl.TXN_INIT_BURDENED_COST
                                ,bl.TXN_INIT_REVENUE
                                ,bl.TXN_MARKUP_PERCENT
                                ,DECODE(g_rbl_txn_curr_code_ovr_tab(i),NULL,bl.COST_IND_COMPILED_SET_ID,NULL)
					  ,bl.QUANTITY_SOURCE
				 	  ,bl.RAW_COST_SOURCE
					  ,bl.BURDENED_COST_SOURCE
					  ,bl.REVENUE_SOURCE
					  ,bl.INIT_RAW_COST
                                ,bl.INIT_BURDENED_COST
                                ,bl.INIT_REVENUE
                                ,bl.PROJECT_INIT_RAW_COST
                                ,bl.PROJECT_INIT_BURDENED_COST
                                ,bl.PROJECT_INIT_REVENUE
                        FROM PA_BUDGET_LINES bl
			WHERE bl.budget_line_id = g_rbl_budget_line_id_tab(i)

			/*Perf Bug fix:4251959 AND  bl.budget_version_id = g_rbl_budget_version_id_tab(i) */
			;
        END IF;
EXCEPTION

        WHEN OTHERS THEN
                print_msg('Unexpected error in blkInsertBlFpLines['||sqlcode||sqlerrm||']');
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_FP_SPREAD_AMTS_PKG',
                                        p_procedure_name => 'blkInsertBlFpLines'||l_stage);
		If p_pa_debug_mode = 'Y' Then
                	pa_debug.reset_err_stack;
		End If;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;

END blkInsertBlFpLines;

/* This API populates the plsql tables with budget lines for bulk insert */
PROCEDURE insert_budget_line(
	p_resource_assignment_id IN pa_budget_lines.RESOURCE_ASSIGNMENT_ID%TYPE
	,p_start_date		 IN pa_budget_lines.START_DATE%TYPE
	,p_end_date		 IN pa_budget_lines.END_DATE%TYPE
	,p_period_name		 IN pa_budget_lines.PERIOD_NAME%TYPE
	,p_txn_currency_code	 IN pa_budget_lines.TXN_CURRENCY_CODE%TYPE
	,p_txn_curr_code_ovr	 IN pa_budget_lines.TXN_CURRENCY_CODE%TYPE
	,x_budget_line_id	 OUT NOCOPY pa_budget_lines.BUDGET_LINE_ID%TYPE
	,p_budget_version_id	 IN pa_budget_lines.BUDGET_VERSION_ID%TYPE
	,p_proj_curr_cd		 IN pa_projects_all.project_currency_code%TYPE
	,p_projfunc_curr_cd	 IN pa_projects_all.projfunc_currency_code%TYPE
        ,x_return_status         OUT NOCOPY VARCHAR2
        ,x_msg_count             OUT NOCOPY NUMBER
        ,x_msg_data              OUT NOCOPY VARCHAR2) IS


  	l_stage			VARCHAR2(1000);
  	l_budget_line_id 	NUMBER;

BEGIN
	l_stage := '1100 :: Entered insert_budget_line()';
  	x_return_status := 'S';
	x_msg_count	:= 0;
	x_msg_data	:= NULL;

	-- get Budget Line ID
	SELECT PA_BUDGET_LINES_S.NEXTVAL
	INTO l_budget_line_id
	FROM DUAL;

	x_budget_line_id := l_budget_line_id;
	g_bl_budget_line_id_tab(nvl(g_bl_budget_line_id_tab.LAST,0)+1)		:= x_budget_line_id;
        g_bl_budget_version_id_tab(nvl(g_bl_budget_version_id_tab.LAST,0)+1)	:= p_budget_version_id;
        g_bl_res_assignment_id_tab(nvl(g_bl_res_assignment_id_tab.LAST,0)+1)	:= p_resource_assignment_id;
        g_bl_start_date_tab(nvl(g_bl_start_date_tab.LAST,0)+1)			:= p_start_date;
        g_bl_end_date_tab(nvl(g_bl_end_date_tab.LAST,0)+1)			:= p_end_date;
        g_bl_period_name_tab(nvl(g_bl_period_name_tab.LAST,0)+1)		:= p_period_name;
        g_bl_txn_curr_code_tab(nvl(g_bl_txn_curr_code_tab.LAST,0)+1)		:= p_txn_currency_code;
        g_bl_txn_curr_code_ovr_tab(nvl(g_bl_txn_curr_code_ovr_tab.LAST,0)+1)	:= p_txn_curr_code_ovr;
        g_bl_proj_curr_code_tab(nvl(g_bl_proj_curr_code_tab.LAST,0)+1)		:= p_proj_curr_cd;
        g_bl_projfunc_curr_code_tab(nvl(g_bl_projfunc_curr_code_tab.LAST,0)+1)  := p_projfunc_curr_cd;



EXCEPTION
	WHEN OTHERS THEN
		print_msg(l_stage||sqlcode||sqlerrm);
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_FP_SPREAD_AMTS_PKG',
				p_procedure_name => 'insert_budget_line'||l_stage);
		If p_pa_debug_mode = 'Y' Then
			pa_debug.reset_err_stack;
		End If;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;

END insert_budget_line;

/* This API populates the plsql tables with rollup tmp lines for bulk insert */
PROCEDURE insert_rollup_tmp(
  	p_ra_rec		IN resource_assignment_rec_type
	,p_budget_version_id    IN NUMBER
	,p_start_date		IN pa_fp_rollup_tmp.START_DATE%TYPE
	,p_end_date		IN pa_fp_rollup_tmp.END_DATE%TYPE
	,p_period_name		IN pa_fp_rollup_tmp.PERIOD_NAME%TYPE
	,p_budget_line_id	IN pa_fp_rollup_tmp.BUDGET_LINE_ID%TYPE
	,p_quantity		IN pa_fp_rollup_tmp.QUANTITY%TYPE
	,p_txn_raw_cost		IN pa_fp_rollup_tmp.TXN_RAW_COST%TYPE
	,p_txn_burdened_cost	IN pa_fp_rollup_tmp.TXN_BURDENED_COST%TYPE
	,p_txn_revenue		IN pa_fp_rollup_tmp.TXN_REVENUE%TYPE
        ,x_return_status        OUT NOCOPY VARCHAR2
        ,x_msg_count            OUT NOCOPY NUMBER
        ,x_msg_data             OUT NOCOPY VARCHAR2) IS

  	l_stage			VARCHAR2(1000);


BEGIN
	l_stage := '1200::Entered insert_rollup_tmp()';
  	x_return_status := 'S';
	x_msg_data      := NULL;

	g_rl_res_assignment_id_tab(nvl(g_rl_res_assignment_id_tab.LAST,0)+1) 		:= p_ra_rec.RESOURCE_ASSIGNMENT_ID;
        g_rl_start_date_tab(nvl(g_rl_start_date_tab.LAST,0) +1)				:= p_start_date;
        g_rl_end_date_tab(nvl(g_rl_end_date_tab.LAST,0) +1 )				:= p_end_date;
        g_rl_period_name_tab(nvl(g_rl_period_name_tab.LAST,0)+1)			:= p_period_name;
        g_rl_txn_curr_code_tab(nvl(g_rl_txn_curr_code_tab.LAST,0)+1)			:= p_ra_rec.TXN_CURRENCY_CODE;
        g_rl_txn_curr_code_ovr_tab(nvl(g_rl_txn_curr_code_ovr_tab.LAST,0)+1)		:= p_ra_rec.TXN_CURRENCY_CODE_OVERRIDE;
        g_rl_budget_line_id_tab(nvl(g_rl_budget_line_id_tab.LAST,0)+1)			:= p_budget_line_id;
        g_rl_budget_version_id_tab(nvl(g_rl_budget_version_id_tab.LAST,0)+1)		:= p_budget_version_id;
        g_rl_proj_curr_code_tab(nvl(g_rl_proj_curr_code_tab.LAST,0)+1)			:= p_ra_rec.PROJECT_CURRENCY_CODE;
        g_rl_projfunc_curr_code_tab(nvl(g_rl_projfunc_curr_code_tab.LAST,0)+1)		:= p_ra_rec.PROJFUNC_CURRENCY_CODE;
        g_rl_quantity_tab(nvl(g_rl_quantity_tab.LAST,0)+1)				:= p_quantity;
        g_rl_txn_raw_cost_tab(nvl(g_rl_txn_raw_cost_tab.LAST,0)+1)			:= p_txn_raw_cost;
        g_rl_txn_cost_rate_tab(nvl(g_rl_txn_cost_rate_tab.LAST,0)+1)			:= p_ra_rec.RAW_COST_RATE;
        g_rl_txn_cost_rate_ovr_tab(nvl(g_rl_txn_cost_rate_ovr_tab.LAST,0)+1)		:= p_ra_rec.RAW_COST_RATE_OVERRIDE;
        g_rl_txn_burden_cost_tab(nvl(g_rl_txn_burden_cost_tab.LAST,0)+1)		:= p_txn_burdened_cost;
        g_rl_txn_burden_rate_tab(nvl(g_rl_txn_burden_rate_tab.LAST,0)+1)		:= p_ra_rec.BURDEN_COST_RATE;
        g_rl_txn_burden_rate_ovr_tab(nvl(g_rl_txn_burden_rate_ovr_tab.LAST,0)+1)	:= p_ra_rec.BURDEN_COST_RATE_OVERRIDE;
        g_rl_txn_revenue_tab(nvl(g_rl_txn_revenue_tab.LAST,0)+1)			:= p_txn_revenue;
        g_rl_txn_bill_rate_tab(nvl(g_rl_txn_bill_rate_tab.LAST,0)+1)			:= p_ra_rec.BILL_RATE;
        g_rl_txn_bill_rate_ovr_tab(nvl(g_rl_txn_bill_rate_ovr_tab.LAST,0)+1)		:= p_ra_rec.BILL_RATE_OVERRIDE;

EXCEPTION
	WHEN OTHERS THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_FP_SPREAD_AMTS_PKG',
				p_procedure_name => 'insert_rollup_tmp()'||l_stage);
		If p_pa_debug_mode = 'Y' Then
			pa_debug.reset_err_stack;
		End If;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;

END insert_rollup_tmp;

/* This API populates the plsql tables with rollup tmp lines for bulk insert */
PROCEDURE insert_rollup_tmp_with_bl(
  	p_ra_rec		IN resource_assignment_rec_type
	,p_budget_version_id    IN NUMBER
	,p_start_date		IN pa_fp_rollup_tmp.START_DATE%TYPE
	,p_end_date		IN pa_fp_rollup_tmp.END_DATE%TYPE
	,p_period_name		IN pa_fp_rollup_tmp.PERIOD_NAME%TYPE
	,p_budget_line_id	IN pa_fp_rollup_tmp.BUDGET_LINE_ID%TYPE
	,p_quantity		IN pa_fp_rollup_tmp.QUANTITY%TYPE
	,p_txn_raw_cost		IN pa_fp_rollup_tmp.TXN_RAW_COST%TYPE
	,p_txn_burdened_cost	IN pa_fp_rollup_tmp.TXN_BURDENED_COST%TYPE
	,p_txn_revenue		IN pa_fp_rollup_tmp.TXN_REVENUE%TYPE
        ,x_return_status        OUT NOCOPY VARCHAR2
        ,x_msg_count            OUT NOCOPY NUMBER
        ,x_msg_data             OUT NOCOPY VARCHAR2) IS


  	l_stage		VARCHAR2(1000);

BEGIN
	l_stage := '1400:: Entered insert_rollup_tmp_with_bl()';
  	x_return_status := 'S';
	x_msg_count	:= 0;
	x_msg_data	:= NULL;

        g_rbl_res_assignment_id_tab(nvl(g_rbl_res_assignment_id_tab.LAST,0)+1)           := p_ra_rec.RESOURCE_ASSIGNMENT_ID;
        g_rbl_start_date_tab(nvl(g_rbl_start_date_tab.LAST,0) +1)                        := p_start_date;
        g_rbl_end_date_tab(nvl(g_rbl_end_date_tab.LAST,0) +1 )                           := p_end_date;
        g_rbl_period_name_tab(nvl(g_rbl_period_name_tab.LAST,0)+1)                       := p_period_name;
        g_rbl_txn_curr_code_tab(nvl(g_rbl_txn_curr_code_tab.LAST,0)+1)                   := p_ra_rec.TXN_CURRENCY_CODE;
        g_rbl_txn_curr_code_ovr_tab(nvl(g_rbl_txn_curr_code_ovr_tab.LAST,0)+1)           := p_ra_rec.TXN_CURRENCY_CODE_OVERRIDE;
        g_rbl_budget_line_id_tab(nvl(g_rbl_budget_line_id_tab.LAST,0)+1)                 := p_budget_line_id;
        g_rbl_budget_version_id_tab(nvl(g_rbl_budget_version_id_tab.LAST,0)+1)           := p_budget_version_id;
        g_rbl_proj_curr_code_tab(nvl(g_rbl_proj_curr_code_tab.LAST,0)+1)                 := p_ra_rec.PROJECT_CURRENCY_CODE;
        g_rbl_projfunc_curr_code_tab(nvl(g_rbl_projfunc_curr_code_tab.LAST,0)+1)         := p_ra_rec.PROJFUNC_CURRENCY_CODE;
        g_rbl_quantity_tab(nvl(g_rbl_quantity_tab.LAST,0)+1)                             := p_quantity;
        g_rbl_txn_raw_cost_tab(nvl(g_rbl_txn_raw_cost_tab.LAST,0)+1)                     := p_txn_raw_cost;
        g_rbl_txn_cost_rate_tab(nvl(g_rbl_txn_cost_rate_tab.LAST,0)+1)                   := p_ra_rec.RAW_COST_RATE;
        g_rbl_txn_cost_rate_ovr_tab(nvl(g_rbl_txn_cost_rate_ovr_tab.LAST,0)+1)           := p_ra_rec.RAW_COST_RATE_OVERRIDE;
        g_rbl_txn_burden_cost_tab(nvl(g_rbl_txn_burden_cost_tab.LAST,0)+1)               := p_txn_burdened_cost;
        g_rbl_txn_burden_rate_tab(nvl(g_rbl_txn_burden_rate_tab.LAST,0)+1)               := p_ra_rec.BURDEN_COST_RATE;
        g_rbl_txn_burden_rate_ovr_tab(nvl(g_rbl_txn_burden_rate_ovr_tab.LAST,0)+1)       := p_ra_rec.BURDEN_COST_RATE_OVERRIDE;
        g_rbl_txn_revenue_tab(nvl(g_rbl_txn_revenue_tab.LAST,0)+1)                       := p_txn_revenue;
        g_rbl_txn_bill_rate_tab(nvl(g_rbl_txn_bill_rate_tab.LAST,0)+1)                   := p_ra_rec.BILL_RATE;
        g_rbl_txn_bill_rate_ovr_tab(nvl(g_rbl_txn_bill_rate_ovr_tab.LAST,0)+1)           := p_ra_rec.BILL_RATE_OVERRIDE;


EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_FP_SPREAD_AMTS_PKG',
				p_procedure_name => 'insert_rollup_tmp_with_bl()'||l_stage);
		If p_pa_debug_mode = 'Y' Then
			pa_debug.reset_err_stack;
		End If;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;

END insert_rollup_tmp_with_bl;

/* This API rounds the given amount/quantity to following precision level
 * If rate base flag is 'Y' then quantity will be rounded to 5 decimals and amount will be rounded as per the currency precision
 * If rate base flag is 'N' then quantity will be rounded as per the currency precision level
 */
FUNCTION Round_Qty_Amts(p_rate_base_flag  Varchar2 default 'N'
			,p_quantity_flag   Varchar2
			,p_currency_code   Varchar2
			,p_amounts         Number ) RETURN NUMBER IS

	l_return_Amounts  Number := NULL;
BEGIN
	l_return_Amounts := p_amounts;
	If p_quantity_flag = 'Y' Then
		If p_amounts is NOT NULL Then
		 	If nvl(p_rate_base_flag,'N') = 'Y' Then
			   l_return_Amounts := round(l_return_Amounts,5);
		    Else
			   l_return_Amounts := pa_currency.round_trans_currency_amt1(p_amounts,p_currency_code);
		    End If;
		End If;

	Else
		l_return_Amounts := pa_currency.round_trans_currency_amt1(p_amounts,p_currency_code);
	End If;

	RETURN l_return_Amounts;
EXCEPTION
	WHEN OTHERS THEN
		print_msg('Unexpected error in Round_Qty_Amts['||sqlcode||sqlerrm||']');
                FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_FP_SPREAD_AMTS_PKG',
                                        p_procedure_name => 'spread');
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
END Round_Qty_Amts;

PROCEDURE spread ( p_number_of_amounts	IN INTEGER,
	                         p_amount1                        IN NUMBER,
 	                         p_amount2                        IN NUMBER,
 	                         p_amount3                        IN NUMBER,
 	                         p_amount4                        IN NUMBER,
 	                         p_amount5                        IN NUMBER,
 	                         p_amount6                        IN NUMBER,
 	                         p_amount7                        IN NUMBER,
 	                         p_amount8                        IN NUMBER,
 	                         p_amount9                        IN NUMBER,
 	                         p_amount10                IN NUMBER,
 	                         p_start_end_date        IN start_end_date_table_type,
 	                         p_spread_curve                 IN spread_curve_type,
 	                         p_start_period                IN INTEGER := 0,
 	                         p_end_period                 IN INTEGER := 0,
 	                         p_global_start_date        IN Date,
 	                         x_spread_amounts         IN OUT NOCOPY spread_table_type,
 	                         x_return_status         OUT NOCOPY VARCHAR2,
 	                         x_msg_count             OUT NOCOPY NUMBER,
 	                         x_msg_data              OUT NOCOPY VARCHAR2) IS

 	   l_start_period        INTEGER;
 	   l_end_period          INTEGER;
 	   l_spread_curve        spread_curve_type;        -- Spread Curve
 	   nofp          NUMBER;                -- Actual number of periods
 	   time_step     NUMBER;                -- Time Step
 	   allocation    NUMBER;                -- position of allocation of period
 	   accumulated_allocation NUMBER;-- position of accumulated allocation
 	   weight_sum    NUMBER;
 	   amount_sum    NUMBER;
 	   tmp_start_date        DATE;
 	   tmp_end_date  DATE;
 	   tmp_rec       spread_record_type;
 	   k             INTEGER;
 	   j             INTEGER;
 	   l_period_counter  INTEGER;
 	   exit_flag     BOOLEAN;

 	   l_msg_count       NUMBER := 0;
 	   l_data            VARCHAR2(2000);
 	   l_msg_data        VARCHAR2(2000);
 	   l_msg_index_out   NUMBER;
 	   l_debug_mode      VARCHAR2(30);

 	   l_global_actual_periods       NUMBER;
 	   l_global_allocation           NUMBER;
 	   l_global_percentage           NUMBER;

 	   l_stage           INTEGER;

 	   BEGIN
 	         l_stage := 10;
 	         print_msg('        '||l_stage||' enter spread()');
 	         x_return_status := FND_API.G_RET_STS_SUCCESS;
 	         If p_pa_debug_mode = 'Y' Then
 	                 pa_debug.init_err_stack('PA_FP_SPREAD_AMTS_PKG.spread');
 	         End If;

 	         fnd_profile.get('PA_DEBUG_MODE', l_debug_mode);
 	         pa_debug.set_process('PLSQL', 'LOG', l_debug_mode);

 	         pa_debug.g_err_stage := 'Entered PA_FP_SPREAD_AMTS_PKG.spread';
 	         IF P_PA_DEBUG_MODE = 'Y' THEN
 	                 pa_debug.write('spread: '||g_module_name,
 	                         pa_debug.g_err_stage,
 	                         3);
 	         END IF;

 	         l_stage := 20;
 	         print_msg('        '||l_stage||' p_number_of_amounts        => '||p_number_of_amounts);
 	         /*
 	         print_msg('        '||'p_amount1                => '||p_amount1);
 	         print_msg('        '||'p_amount2                => '||p_amount2);
 	         print_msg('        '||'p_amount3                => '||p_amount3);
 	         print_msg('        '||'p_amount4                => '||p_amount4);
 	         print_msg('        '||'p_amount5                => '||p_amount5);
 	         print_msg('        '||'p_amount6                => '||p_amount6);
 	         print_msg('        '||'p_amount7                => '||p_amount7);
 	         print_msg('        '||'p_amount8                => '||p_amount8);
 	         print_msg('        '||'p_amount9                => '||p_amount9);
 	         print_msg('        '||'p_amount10                => '||p_amount10);

 	         FOR i IN 1 .. p_start_end_date.COUNT()
 	         LOOP
 	                 NULL;
 	                 print_msg('        '||'plan start/end date        => '||p_start_end_date(i).start_date||'/'||p_start_end_date(i).end_date);
 	         END LOOP;

 	         print_msg('        '||'spread curve        => '||p_spread_curve(1)||' '||p_spread_curve(2)||' '||p_spread_curve(3));
 	         print_msg('      '||p_spread_curve(4)||' '||p_spread_curve(5)||' '||p_spread_curve(6)||' '||p_spread_curve(7));
 	         print_msg('      '||p_spread_curve(8)||' '||p_spread_curve(9)||' '||p_spread_curve(10));
 	         print_msg('        '||'start/end period        => '||p_start_period||'/'||p_end_period);
 	         print_msg('        '||'p_global_start_date        => '||p_global_start_date);

 	         FOR i IN 1 .. x_spread_amounts.COUNT()
 	         LOOP
 	                 IF i = 1 OR i = x_spread_amounts.COUNT() THEN
 	                 NULL;
 	                 print_msg('        '||'start/end date '||i||'        => '||x_spread_amounts(i).start_date||'/'||x_spread_amounts(i).end_date);
 	                 END IF;
 	         END LOOP;
 	         */

 	         -- Validating

 	         l_stage := 30;
 	         print_msg('        '||l_stage||' before validate p_number_of_amounts');
 	         -- p_number_of_amounts cannot overflow
 	         IF NOT p_number_of_amounts BETWEEN 1 AND 10 THEN

 	                 x_return_status := FND_API.G_RET_STS_ERROR;
 	                 x_msg_data := 'PA_FP_NUM_OF_AMTS_OVERFLOW';
 	                 If p_pa_debug_mode = 'Y' Then
 	                         pa_debug.reset_err_stack;
 	                 End If;
 	                 RETURN;
 	         END IF;

 	         l_stage := 40;
 	         print_msg('        '||l_stage||' before validate p_start_end_date');
 	         -- p_start_end_date cannot be null and
 	         -- each start_date must earlier than end_date in p_start_end_date,
 	         -- and they cannot overlap each other.
 	         IF p_start_end_date IS NULL THEN
 	                 x_return_status := FND_API.G_RET_STS_ERROR;
 	                 x_msg_data := 'PA_FP_PLAN_START_END_DATE_NULL';
 	                 If p_pa_debug_mode = 'Y' Then
 	                         pa_debug.reset_err_stack;
 	                 End If;
 	                 RETURN;
 	         END IF;
 	         FOR k IN 1 .. p_start_end_date.COUNT()
 	         LOOP
 	                 IF --p_start_end_date(k) IS NULL OR
 	                         p_start_end_date(k).start_date IS NULL OR
 	                         p_start_end_date(k).end_date IS NULL OR
 	                         p_start_end_date(k).start_date >
 	                         p_start_end_date(k).end_date OR
 	                         k < p_start_end_date.COUNT() AND
 	                         p_start_end_date(k + 1).start_date <=
 	                         p_start_end_date(k).end_date THEN

 	                         x_return_status := FND_API.G_RET_STS_ERROR;
 	                         x_msg_data := 'PA_FP_START_END_DATE_OVERLAP';
 	                         If p_pa_debug_mode = 'Y' Then
 	                                 pa_debug.reset_err_stack;
 	                         End If;
 	                         RETURN;
 	                 END IF;
 	         END LOOP;

 	         l_stage := 50;
 	         print_msg('        '||l_stage||' before validate p_spread_curve');
 	         -- If p_spread_curve is null, spread as equal distribution.
 	         IF p_spread_curve IS NULL THEN
 	                 l_spread_curve :=
 	                         spread_curve_type(10,10,10,10,10,10,10,10,10,10);
 	         ELSE
 	                 l_spread_curve := p_spread_curve;
 	         END IF;

 	         l_stage := 60;
 	         print_msg('        '||l_stage||' before validate x_spread_amounts');
 	         -- x_spread_amounts cannot be NULL and
 	         -- x_spread_amounts' start end date must match with p_start_end_date.
 	         IF (x_spread_amounts IS NULL OR x_spread_amounts.COUNT() = 0 ) THEN
 	                 x_return_status := FND_API.G_RET_STS_ERROR;
 	                 x_msg_data := 'PA_FP_PERIODS_IS_NULL';
 	                 print_msg('x_msg_data['||x_msg_data||']');
 	                 If p_pa_debug_mode = 'Y' Then
 	                         pa_debug.reset_err_stack;
 	                 End If;
 	                 RETURN;
 	         END IF;
 	         --print_msg('Count of x_spread_amounts.COUNT()['||x_spread_amounts.COUNT()||']');
 	         FOR k IN 1 .. x_spread_amounts.COUNT()
 	         LOOP
 	                 IF --x_spread_amounts(k) IS NULL OR
 	                         x_spread_amounts(k).start_date IS NULL OR
 	                         x_spread_amounts(k).end_date IS NULL OR
 	                         x_spread_amounts(k).start_date >
 	                         x_spread_amounts(k).end_date OR
 	                         k < x_spread_amounts.COUNT() AND
 	                         x_spread_amounts(k + 1).start_date <=
 	                         x_spread_amounts(k).end_date THEN

 	                         x_return_status := FND_API.G_RET_STS_ERROR;
 	                         x_msg_data := 'PA_FP_START_END_DATE_NOT_MATCH';
 	                         If p_pa_debug_mode = 'Y' Then
 	                                 pa_debug.reset_err_stack;
 	                         End If;
 	                         --print_msg('x_msg_data['||x_msg_data||']');
 	                         RETURN;
 	                 END IF;
 	         END LOOP;
 	         IF p_start_end_date(1).start_date >
 	                 x_spread_amounts(1).end_date OR
 	                 p_start_end_date(p_start_end_date.COUNT()).end_date <
 	                 x_spread_amounts(x_spread_amounts.COUNT()).start_date THEN

 	                         x_return_status := FND_API.G_RET_STS_ERROR;
 	                         x_msg_data := 'PA_FP_START_END_DATE_NOT_MATCH';
 	                         --print_msg('x_msg_data['||x_msg_data||']');
 	                         If p_pa_debug_mode = 'Y' Then
 	                                 pa_debug.reset_err_stack;
 	                         End If;
 	                         RETURN;
 	         END IF;


 	         l_stage := 70;
 	         print_msg('        '||l_stage||' before validate p_start/end_period');
 	         -- p_start_period/p_end_period validateing
 	         IF NOT (p_start_period BETWEEN 1 AND x_spread_amounts.COUNT() AND
 	                 p_end_period BETWEEN 1 AND x_spread_amounts.COUNT() AND
 	                 p_start_period <= p_end_period) THEN
 	                 -- update 032504 iand
 	                 -- OR
 	                 -- p_start_period BETWEEN 1 AND x_spread_amounts.COUNT() AND
 	                 -- p_end_period = 0 OR
 	                 -- p_start_period = 0 AND
 	                 -- p_end_period BETWEEN 1 AND x_spread_amounts.COUNT() OR
 	                 -- p_start_period = 0 AND p_end_period = 0) THEN

 	                         x_return_status := FND_API.G_RET_STS_ERROR;
 	                         x_msg_data := 'PA_FP_PERIOD_NO_MATCH';
 	                         print_msg('x_msg_data['||x_msg_data||']');
 	                         If p_pa_debug_mode = 'Y' Then
 	                                 pa_debug.reset_err_stack;
 	                         End If;
 	                         RETURN;
 	         END IF;
 	         l_start_period := p_start_period;
 	         l_end_period := p_end_period;
 	         l_stage := 80;
 	         print_msg('        '||l_stage||' after validation');

 	         -- Calculate the number of period for each period and
 	         -- total number of period

 	         FOR k IN 1 .. x_spread_amounts.COUNT()
 	         LOOP
 	                 x_spread_amounts(k).actual_days := 0;
 	         END LOOP;


 	         k := 1;
 	         FOR j IN 1 .. x_spread_amounts.COUNT()
 	         LOOP

 	             IF x_spread_amounts(j).end_date <
 	                 p_start_end_date(k).start_date THEN

 	                 x_spread_amounts(j).actual_days := 0;
 	                 x_spread_amounts(j).actual_periods := 0;

 	             ELSE

 	                 IF p_start_end_date(k).start_date BETWEEN
 	                         x_spread_amounts(j).start_date AND
 	                         x_spread_amounts(j).end_date THEN
 	                         tmp_start_date := p_start_end_date(k).start_date;
 	                 ELSE
 	                         tmp_start_date := x_spread_amounts(j).start_date;
 	                 END IF;
 	                 IF p_start_end_date(k).end_date BETWEEN
 	                         x_spread_amounts(j).start_date AND
 	                         x_spread_amounts(j).end_date THEN
 	                         tmp_end_date := p_start_end_date(k).end_date;
 	                 ELSE
 	                         tmp_end_date := x_spread_amounts(j).end_date;
 	                 END IF;
 	                 x_spread_amounts(j).actual_days :=
 	                         x_spread_amounts(j).actual_days +
 	                         tmp_end_date - tmp_start_date + 1;
 	                 x_spread_amounts(j).actual_periods :=
 	                         x_spread_amounts(j).actual_days /
 	                         (x_spread_amounts(j).end_date
 	                          - x_spread_amounts(j).start_date + 1);

 	                 LOOP
 	                 EXIT WHEN NOT (k < p_start_end_date.COUNT() AND
 	                         p_start_end_date(k + 1).end_date <=
 	                         x_spread_amounts(j).end_date);

 	                         k := k + 1;

 	                         x_spread_amounts(j).actual_days :=
 	                                 x_spread_amounts(j).actual_days +
 	                                 p_start_end_date(k).end_date -
 	                                 p_start_end_date(k).start_date + 1;
 	                         x_spread_amounts(j).actual_periods :=
 	                                 x_spread_amounts(j).actual_days /
 	                                 (x_spread_amounts(j).end_date
 	                                  - x_spread_amounts(j).start_date + 1);

 	                     END LOOP;

 	                 IF k < p_start_end_date.COUNT() AND
 	                         p_start_end_date(k + 1).start_date <=
 	                         x_spread_amounts(j).end_date THEN

 	                         k := k + 1;
 	                         tmp_start_date := p_start_end_date(k).start_date;
 	                         tmp_end_date := x_spread_amounts(j).end_date;
 	                         x_spread_amounts(j).actual_days :=
 	                                 x_spread_amounts(j).actual_days +
 	                                 tmp_end_date - tmp_start_date + 1;
 	                         x_spread_amounts(j).actual_periods :=
 	                                 x_spread_amounts(j).actual_days /
 	                                 (x_spread_amounts(j).end_date
 	                                  - x_spread_amounts(j).start_date + 1);
 	                 END IF;

 	                 IF k < p_start_end_date.COUNT() AND
 	                         p_start_end_date(k).end_date <=
 	                         x_spread_amounts(j).end_date THEN
 	                         k := k + 1;
 	                 END IF;

 	             END IF;

 	         END LOOP;
 	         IF p_global_start_date IS NOT NULL THEN
 	                 --print_msg('end date['||x_spread_amounts(l_start_period).end_date||']StartDate['||x_spread_amounts(l_start_period).start_date||']');
 	                 l_global_actual_periods :=
 	                         (x_spread_amounts(l_start_period).end_date -
 	                         p_global_start_date + 1) /
 	                         (x_spread_amounts(l_start_period).end_date -
 	                         x_spread_amounts(l_start_period).start_date + 1);
 	                 --print_msg('l_global_actual_periods['||l_global_actual_periods||']');
 	         END IF;
 	         l_stage := 81;
 	         --print_msg('        '||l_stage||' after calculate actual period for global start date '||round(l_global_actual_periods,2));
 	         --print_msg('Actual num of periods['||x_spread_amounts(k).actual_periods||']SpCount['||x_spread_amounts.COUNT||']');
 	         nofp := 0;
 	         FOR k IN 1 .. x_spread_amounts.COUNT()
 	         LOOP
 	                 nofp := nofp + x_spread_amounts(k).actual_periods;
 	                 --print_msg('nofp['||nofp||']spactualperiods['||x_spread_amounts(k).actual_periods||']');
 	         END LOOP;
 	         l_stage := 90;
 	         print_msg('        '||l_stage||' after calculate number of period');

 	         -- Calculate bucket time step
 	         print_msg('l_spread_curve['||l_spread_curve.count||']');
 	         time_step := l_spread_curve.COUNT()/nofp;
 	         l_stage := 100;
 	         print_msg('        '||l_stage||' after calculate bucket time step ['||time_step||']');

 	         -- Calculate bucket allocation for each period

 	         FOR k IN 1 .. x_spread_amounts.COUNT()
 	         LOOP

 	                 x_spread_amounts(k).allocation :=
 	                         x_spread_amounts(k).actual_periods * time_step;

 	         END LOOP;
 	         l_stage := 110;
 	         print_msg(l_stage||' after calculate allocation of period global_sDate['||p_global_start_date||']timeStep['||time_step||']alloc['||x_spread_amounts(k).allocation||']');
 	         -- update 032204 iand
 	         IF p_global_start_date IS NOT NULL THEN
 	                 l_global_allocation := l_global_actual_periods * time_step;
 	                 print_msg('l_global_allocation['||l_global_allocation||']');
 	         END IF;
 	         l_stage := 111;
 	         print_msg(l_stage||' after calculate allocation for global start date '||round(l_global_allocation,2));

 	         -- Calculate percentage for each period

 	         j := 1;                                -- position of weight in l_spread_curve
 	         allocation := 0;                -- position of allocation of period
 	         accumulated_allocation := 0;        -- position of accumulated allocation
 	         FOR k IN 1 .. x_spread_amounts.COUNT()
 	         LOOP
 	                 allocation := allocation + x_spread_amounts(k).allocation;
 	                 x_spread_amounts(k).percentage := 0;
 	                 LOOP
 	                         IF allocation >= j THEN
 	                                 x_spread_amounts(k).percentage :=
 	                                         x_spread_amounts(k).percentage +
 	                                         (j - accumulated_allocation) *
 	                                         l_spread_curve(j);
 	                                 accumulated_allocation := j;
 	                                 j := j + 1;
 	                         END IF;
 	                         EXIT WHEN allocation < j;
 	                 END LOOP;
 	                 IF j <= l_spread_curve.COUNT() THEN
 	                         x_spread_amounts(k).percentage :=
 	                                 x_spread_amounts(k).percentage +
 	                                 (allocation - accumulated_allocation) *
 	                                 l_spread_curve(j);
 	                 END IF;
 	                 accumulated_allocation := allocation;

 	         END LOOP;
 	         l_stage := 120;
 	         print_msg('        '||l_stage||' after calculate percentage of period');
 	         IF p_global_start_date IS NOT NULL THEN
 	     /** Bug 3825695 Raja Aug 11 2004 -- the logic to compute global periods is wrong
 	                                      -- so the following is going for a toss

 	         allocation := 0;
 	                 FOR k IN 1 .. l_start_period
 	                 LOOP
 	                         --print_msg('allocation['||allocation||']spAlloc['||x_spread_amounts(k).allocation||']');
 	                         allocation :=
 	                                 allocation + x_spread_amounts(k).allocation;
 	                 END LOOP;
 	                 accumulated_allocation := allocation - l_global_allocation;
 	                 --accumulated_allocation := l_global_allocation - allocation ;
 	                 print_msg('accumulated_allocation['||accumulated_allocation||']l_global_allocation['||l_global_allocation||']');
 	                 j := ceil(accumulated_allocation);
 	                 print_msg('value of j['||j||']');
 	                 l_global_percentage := 0;
 	                 LOOP
 	                         IF allocation >= j THEN
 	                                 l_global_percentage :=
 	                                         l_global_percentage +
 	                                         (j - accumulated_allocation) *
 	                                         l_spread_curve(j);
 	                                 accumulated_allocation := j;
 	                                 j := j + 1;
 	                         END IF;
 	                         EXIT WHEN allocation < j;
 	                 END LOOP;
 	                 IF j <= l_spread_curve.COUNT() THEN
 	                         l_global_percentage :=
 	                                 l_global_percentage +
 	                                 (allocation - accumulated_allocation) *
 	                                 l_spread_curve(j);
 	                 END IF;
 	     */
 	         -- Reusing already calculated percentages
 	         l_global_percentage := 0;
 	         FOR k IN 1 .. l_start_period
 	         LOOP
 	             l_global_percentage := l_global_percentage + nvl(x_spread_amounts(k).percentage,0);
 	         END LOOP;
 	         END IF;
 	         l_stage := 121;
 	         print_msg('        '||l_stage||' after calculate percentage for global start date '||round(l_global_percentage,2));

 	         -- Calculate amounts for each period
 	         IF p_global_start_date IS NOT NULL THEN
 	                 x_spread_amounts(l_start_period).percentage :=
 	                         nvl(l_global_percentage,0);
 	         END IF;

 	         weight_sum := 0;
 	         FOR k IN l_start_period .. l_end_period
 	         LOOP
 	                 weight_sum := weight_sum + x_spread_amounts(k).percentage;
 	         END LOOP;

 	         --print_msg('Total Weigt_sum to spread proportionately['||weight_sum||']');
 	         FOR k IN 1 .. x_spread_amounts.COUNT()
 	         LOOP

 	                 FOR j IN 1 .. p_number_of_amounts --p_amounts.COUNT()
 	                 LOOP

 	                     x_spread_amounts(k).number_of_amounts :=
 	                                 p_number_of_amounts;

 	                         IF k BETWEEN l_start_period AND l_end_period THEN
 	                         --tmp_amounts(j) := p_amounts(j) *
 	                       If NVL(weight_sum,0) <> 0 Then
 	                         IF j = 1 THEN
 	                                 x_spread_amounts(k).amount1 := p_amount1 *
 	                                 x_spread_amounts(k).percentage / weight_sum;
 	                         ELSIF j = 2 THEN
 	                                 x_spread_amounts(k).amount2 := p_amount2 *
 	                                 x_spread_amounts(k).percentage / weight_sum;
 	                         ELSIF j = 3 THEN
 	                                 x_spread_amounts(k).amount3 := p_amount3 *
 	                                 x_spread_amounts(k).percentage / weight_sum;
 	                         ELSIF j = 4 THEN
 	                                 x_spread_amounts(k).amount4 := p_amount4 *
 	                                 x_spread_amounts(k).percentage / weight_sum;
 	                         ELSIF j = 5 THEN
 	                                 x_spread_amounts(k).amount5 := p_amount5 *
 	                                 x_spread_amounts(k).percentage / weight_sum;
 	                         ELSIF j = 6 THEN
 	                                 x_spread_amounts(k).amount6 := p_amount6 *
 	                                 x_spread_amounts(k).percentage / weight_sum;
 	                         ELSIF j = 7 THEN
 	                                 x_spread_amounts(k).amount7 := p_amount7 *
 	                                 x_spread_amounts(k).percentage / weight_sum;
 	                         ELSIF j = 8 THEN
 	                                 x_spread_amounts(k).amount8 := p_amount8 *
 	                                 x_spread_amounts(k).percentage / weight_sum;
 	                         ELSIF j = 9 THEN
 	                                 x_spread_amounts(k).amount9 := p_amount9 *
 	                                 x_spread_amounts(k).percentage / weight_sum;
 	                         ELSIF j = 10 THEN
 	                                 x_spread_amounts(k).amount10 := p_amount10 *
 	                                 x_spread_amounts(k).percentage / weight_sum;
 	                         END IF;
 	                      End If;
 	                         ELSE
 	                         IF j = 1 THEN x_spread_amounts(k).amount1 := 0;
 	                         ELSIF j = 2 THEN x_spread_amounts(k).amount2 := 0;
 	                         ELSIF j = 3 THEN x_spread_amounts(k).amount3 := 0;
 	                         ELSIF j = 4 THEN x_spread_amounts(k).amount4 := 0;
 	                         ELSIF j = 5 THEN x_spread_amounts(k).amount5 := 0;
 	                         ELSIF j = 6 THEN x_spread_amounts(k).amount6 := 0;
 	                         ELSIF j = 7 THEN x_spread_amounts(k).amount7 := 0;
 	                         ELSIF j = 8 THEN x_spread_amounts(k).amount8 := 0;
 	                         ELSIF j = 9 THEN x_spread_amounts(k).amount9 := 0;
 	                         ELSIF j = 10 THEN x_spread_amounts(k).amount10 := 0;
 	                         END IF;
 	                         --tmp_amounts(j) := 0;
 	                     END IF;

 	                 END LOOP;


 	         END LOOP;

 	         FOR k IN 1 .. x_spread_amounts.COUNT()
 	         LOOP
 	                 -- make sure that amount1 is always passed with quantity
 	                 x_spread_amounts(k).amount1 :=
 	                         Round_Qty_Amts(G_rate_based_flag,'Y',G_curr_code,(x_spread_amounts(k).amount1));
 	                 x_spread_amounts(k).amount2 :=
 	                         Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount2));
 	                 x_spread_amounts(k).amount3 :=
 	                         Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount3));
 	                 x_spread_amounts(k).amount4 :=
 	                         Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount4));
 	                 x_spread_amounts(k).amount5 :=
 	                         Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount5));
 	                 x_spread_amounts(k).amount6 :=
 	                         Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount6));
 	                 x_spread_amounts(k).amount7 :=
 	                         Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount7));
 	                 x_spread_amounts(k).amount8 :=
 	                         Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount8));
 	                 x_spread_amounts(k).amount9 :=
 	                         Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount9));
 	                 x_spread_amounts(k).amount10 :=
 	                         Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount10));
 	         END LOOP;
 	         l_stage := 130;
 	         print_msg('        '||l_stage||' after calculate amounts');

 	         -- Adjust the amounts for last period
 	         FOR k IN 1 .. p_number_of_amounts  --p_amounts.COUNT()
 	         LOOP

 	                 amount_sum := 0;
 	                 FOR j IN 1 .. x_spread_amounts.COUNT()
 	                 LOOP
 	                         IF k = 1 THEN
 	                                 amount_sum := amount_sum +
 	                                 nvl(x_spread_amounts(j).amount1,0);
 	                         ELSIF k = 2 THEN
 	                                 amount_sum := amount_sum +
 	                                 nvl(x_spread_amounts(j).amount2,0);
 	                         ELSIF k = 3 THEN
 	                                 amount_sum := amount_sum +
 	                                 nvl(x_spread_amounts(j).amount3,0);
 	                         ELSIF k = 4 THEN
 	                                 amount_sum := amount_sum +
 	                                 nvl(x_spread_amounts(j).amount4,0);
 	                         ELSIF k = 5 THEN
 	                                 amount_sum := amount_sum +
 	                                 nvl(x_spread_amounts(j).amount5,0);
 	                         ELSIF k = 6 THEN
 	                                 amount_sum := amount_sum +
 	                                 nvl(x_spread_amounts(j).amount6,0);
 	                         ELSIF k = 7 THEN
 	                                 amount_sum := amount_sum +
 	                                 nvl(x_spread_amounts(j).amount7,0);
 	                         ELSIF k = 8 THEN
 	                                 amount_sum := amount_sum +
 	                                 nvl(x_spread_amounts(j).amount8,0);
 	                         ELSIF k = 9 THEN
 	                                 amount_sum := amount_sum +
 	                                 nvl(x_spread_amounts(j).amount9,0);
 	                         ELSIF k = 10 THEN
 	                                 amount_sum := amount_sum +
 	                                 nvl(x_spread_amounts(j).amount10,0);
 	                         END IF;
 	                 END LOOP;

 	                 /* Bug fix: 3961955 : The last period is getting updated with -ve amounts when spread curve weightage is zero
 	                  * Logic: The following code is updating the last budget line with the rounding diff amount
 	                  * Loop through the periodic budget lines in the reverse order. If the last period line is having zero weightage
 	                  * then put the diff amounts in the previous period.  If all the periods are zero weightage then put the
 	                  * entire amounts/diff amounts in the Last period of the profile
 	                  */
 	                 IF k = 1 THEN
 	                         IF (p_amount1 - amount_sum) <> 0 Then
 	                            IF (p_amount1 - amount_sum) > 0 Then
 	                                 x_spread_amounts(l_end_period).amount1 := nvl(x_spread_amounts(l_end_period).amount1,0) +
 	                                                 (p_amount1 - amount_sum);
 	                            Else
 	                                 l_period_counter := l_end_period;
 	                                 FOR i IN REVERSE l_start_period .. l_end_period LOOP
 	                                         If x_spread_amounts.EXISTS(i) Then
 	                                                 IF nvl(x_spread_amounts(i).amount1,0) <> 0 Then
 	                                                    If (nvl(x_spread_amounts(i).amount1,0) + (p_amount1 - amount_sum)) > 0 Then
 	                                                         x_spread_amounts(i).amount1 := nvl(x_spread_amounts(i).amount1,0) +
 	                                                                 (p_amount1 - amount_sum);
 	                                                         x_spread_amounts(i).amount1 :=
 	                                                         Round_Qty_Amts(G_rate_based_flag,'Y',G_curr_code,(x_spread_amounts(i).amount1));
 	                                                         Exit;
 	                                                    End If;
 	                                                 End If;
 	                                         End If;
 	                                         l_period_counter := i;
 	                                 END LOOP;
 	                                 /* check all the periods are having zero weightage so put the amounts in the last period */
 	                                 If l_period_counter = l_start_period Then
 	                                         x_spread_amounts(l_end_period).amount1 := nvl(x_spread_amounts(l_end_period).amount1,0) +
 	                                                 (p_amount1 - amount_sum);
 	                                         print_msg('Adding round diff makes all the lines -ve,so just put diff in first bucket');
 	                                         x_spread_amounts(l_end_period).amount1 :=
 	                                         Round_Qty_Amts(G_rate_based_flag,'Y',G_curr_code,(x_spread_amounts(l_end_period).amount1));
 	                                 End If;
 	                            End If;
 	                         End If;
 	                 ELSIF k = 2 THEN
 	                         IF (p_amount2 - amount_sum) <> 0 Then
 	                            IF (p_amount2 - amount_sum) > 0 Then
 	                                         x_spread_amounts(l_end_period).amount2 := nvl(x_spread_amounts(l_end_period).amount2,0) +
 	                                                 (p_amount2 - amount_sum);
 	                            ELSE
 	                                 l_period_counter := l_end_period;
 	                                 FOR i IN REVERSE l_start_period .. l_end_period LOOP
 	                                         If x_spread_amounts.EXISTS(i) Then
 	                                                 IF nvl(x_spread_amounts(i).amount2,0) <> 0 Then
 	                                                    If(nvl(x_spread_amounts(i).amount2,0) + (p_amount2 - amount_sum)) > 0 Then
 	                                                         x_spread_amounts(i).amount2 := nvl(x_spread_amounts(i).amount2,0) +
 	                                                                 (p_amount2 - amount_sum);
 	                                                         Exit;
 	                                                    End If;
 	                                                 End If;
 	                                         End If;
 	                                         l_period_counter := i;
 	                                 END LOOP;
 	                                 /* check all the periods are having zero weightage so put the amounts in the last period */
 	                                 If l_period_counter = l_start_period Then
 	                                         x_spread_amounts(l_end_period).amount2 := nvl(x_spread_amounts(l_end_period).amount2,0) +
 	                                                 (p_amount2 - amount_sum);
 	                                 End If;
 	                            END IF;
 	                         End If;
 	                 ELSIF k = 3 THEN
 	                         IF (p_amount3 - amount_sum) <> 0 Then
 	                            IF (p_amount3 - amount_sum) > 0 Then
 	                                         x_spread_amounts(l_end_period).amount3 := nvl(x_spread_amounts(l_end_period).amount3,0) +
 	                                                 (p_amount3 - amount_sum);
 	                            ELSE
 	                                 l_period_counter := l_end_period;
 	                                 FOR i IN REVERSE l_start_period .. l_end_period LOOP
 	                                         If x_spread_amounts.EXISTS(i) Then
 	                                                 IF nvl(x_spread_amounts(i).amount3,0) <> 0 Then
 	                                                    If (nvl(x_spread_amounts(i).amount3,0)+ (p_amount3 - amount_sum)) > 0 Then
 	                                                         x_spread_amounts(i).amount3 := nvl(x_spread_amounts(i).amount3,0) +
 	                                                                 (p_amount3 - amount_sum);
 	                                                         Exit;
 	                                                    End If;
 	                                                 End If;
 	                                         End If;
 	                                         l_period_counter := i;
 	                                 END LOOP;
 	                                 /* check all the periods are having zero weightage so put the amounts in the last period */
 	                                 If l_period_counter = l_start_period Then
 	                                         x_spread_amounts(l_end_period).amount3 := nvl(x_spread_amounts(l_end_period).amount3,0) +
 	                                                 (p_amount3 - amount_sum);
 	                                 End If;
 	                            END IF;
 	                         End If;
 	                 ELSIF k = 4 THEN
 	                         IF (p_amount4 - amount_sum) <> 0 Then
 	                            IF (p_amount4 - amount_sum) > 0 Then
 	                                    x_spread_amounts(l_end_period).amount4 := nvl(x_spread_amounts(l_end_period).amount4,0) +
 	                                                 (p_amount4 - amount_sum);
 	                            ELSE
 	                                 l_period_counter := l_end_period;
 	                                 FOR i IN REVERSE l_start_period .. l_end_period LOOP
 	                                         If x_spread_amounts.EXISTS(i) Then
 	                                                 IF nvl(x_spread_amounts(i).amount4,0) <> 0 Then
 	                                                    If (nvl(x_spread_amounts(i).amount4,0) + (p_amount4 - amount_sum)) > 0 Then
 	                                                         x_spread_amounts(i).amount4 := nvl(x_spread_amounts(i).amount4,0) +
 	                                                                 (p_amount4 - amount_sum);
 	                                                         Exit;
 	                                                    End If;
 	                                                 End If;
 	                                         End If;
 	                                         l_period_counter := i;
 	                                 END LOOP;
 	                                 /* check all the periods are having zero weightage so put the amounts in the last period */
 	                                 If l_period_counter = l_start_period Then
 	                                         x_spread_amounts(l_end_period).amount4 := nvl(x_spread_amounts(l_end_period).amount4,0) +
 	                                                 (p_amount4 - amount_sum);
 	                                 End If;
 	                            END IF;
 	                         End If;
 	                 ELSIF k = 5 THEN
 	                         IF (p_amount5 - amount_sum) <> 0 Then
 	                            IF (p_amount5 - amount_sum) > 0 Then
 	                                 x_spread_amounts(l_end_period).amount5 := nvl(x_spread_amounts(l_end_period).amount5,0) +
 	                                                 (p_amount5 - amount_sum);
 	                            Else
 	                                 l_period_counter := l_end_period;
 	                                 FOR i IN REVERSE l_start_period .. l_end_period LOOP
 	                                         If x_spread_amounts.EXISTS(i) Then
 	                                                 IF nvl(x_spread_amounts(i).amount5,0) <> 0 Then
 	                                                    If (nvl(x_spread_amounts(i).amount5,0) + (p_amount5 - amount_sum)) > 0 Then
 	                                                         x_spread_amounts(i).amount5 := nvl(x_spread_amounts(i).amount5,0) +
 	                                                                 (p_amount5 - amount_sum);
 	                                                         Exit;
 	                                                    End If;
 	                                                 End If;
 	                                         End If;
 	                                         l_period_counter := i;
 	                                 END LOOP;
 	                                 /* check all the periods are having zero weightage so put the amounts in the last period */
 	                                 If l_period_counter = l_start_period Then
 	                                         x_spread_amounts(l_end_period).amount5 := nvl(x_spread_amounts(l_end_period).amount5,0) +
 	                                                 (p_amount5 - amount_sum);
 	                                 End If;
 	                            End If;
 	                         End If;
 	                 ELSIF k = 6 THEN
 	                         IF (p_amount6 - amount_sum) <> 0 Then
 	                            IF (p_amount6 - amount_sum) > 0 Then
 	                                 x_spread_amounts(l_end_period).amount6 := nvl(x_spread_amounts(l_end_period).amount6,0) +
 	                                                 (p_amount6 - amount_sum);
 	                            Else
 	                                 l_period_counter := l_end_period;
 	                                 FOR i IN REVERSE l_start_period .. l_end_period LOOP
 	                                         If x_spread_amounts.EXISTS(i) Then
 	                                                 IF nvl(x_spread_amounts(i).amount6,0) <> 0 Then
 	                                                    If (nvl(x_spread_amounts(i).amount6,0) + (p_amount6 - amount_sum)) > 0 Then
 	                                                         x_spread_amounts(i).amount6 := nvl(x_spread_amounts(i).amount6,0) +
 	                                                                 (p_amount6 - amount_sum);
 	                                                         Exit;
 	                                                    End If;
 	                                                 End If;
 	                                         End If;
 	                                         l_period_counter := i;
 	                                 END LOOP;
 	                                 /* check all the periods are having zero weightage so put the amounts in the last period */
 	                                 If l_period_counter = l_start_period Then
 	                                         x_spread_amounts(l_end_period).amount6 := nvl(x_spread_amounts(l_end_period).amount6,0) +
 	                                                 (p_amount6 - amount_sum);
 	                                 End If;
 	                            End If;
 	                         End If;
 	                 ELSIF k = 7 THEN
 	                         IF (p_amount7 - amount_sum) <> 0 Then
 	                            IF (p_amount7 - amount_sum) > 0 Then
 	                                 x_spread_amounts(l_end_period).amount7 := nvl(x_spread_amounts(l_end_period).amount7,0) +
 	                                                 (p_amount7 - amount_sum);
 	                            Else
 	                                 l_period_counter := l_end_period;
 	                                 FOR i IN REVERSE l_start_period .. l_end_period LOOP
 	                                         If x_spread_amounts.EXISTS(i) Then
 	                                                 IF nvl(x_spread_amounts(i).amount7,0) <> 0 Then
 	                                                    If (nvl(x_spread_amounts(i).amount7,0) + (p_amount7 - amount_sum)) > 0 Then
 	                                                         x_spread_amounts(i).amount7 := nvl(x_spread_amounts(i).amount7,0) +
 	                                                                 (p_amount7 - amount_sum);
 	                                                         Exit;
 	                                                    End If;
 	                                                 End If;
 	                                         End If;
 	                                         l_period_counter := i;
 	                                 END LOOP;
 	                                 /* check all the periods are having zero weightage so put the amounts in the last period */
 	                                 If l_period_counter = l_start_period Then
 	                                         x_spread_amounts(l_end_period).amount7 := nvl(x_spread_amounts(l_end_period).amount7,0) +
 	                                                 (p_amount7 - amount_sum);
 	                                 End If;
 	                            End If;
 	                         End If;
 	                 ELSIF k = 8 THEN
 	                         IF (p_amount8 - amount_sum) <> 0 Then
 	                            IF (p_amount8 - amount_sum) > 0 Then
 	                                 x_spread_amounts(l_end_period).amount8 := nvl(x_spread_amounts(l_end_period).amount8,0) +
 	                                                 (p_amount8 - amount_sum);
 	                            Else
 	                                 l_period_counter := l_end_period;
 	                                 FOR i IN REVERSE l_start_period .. l_end_period LOOP
 	                                         If x_spread_amounts.EXISTS(i) Then
 	                                                 IF nvl(x_spread_amounts(i).amount8,0) <> 0 Then
 	                                                    If (nvl(x_spread_amounts(i).amount8,0) + (p_amount8 - amount_sum)) > 0 Then
 	                                                         x_spread_amounts(i).amount8 := nvl(x_spread_amounts(i).amount8,0) +
 	                                                                 (p_amount8 - amount_sum);
 	                                                         Exit;
 	                                                    End If;
 	                                                 End If;
 	                                         End If;
 	                                         l_period_counter := i;
 	                                 END LOOP;
 	                                 /* check all the periods are having zero weightage so put the amounts in the last period */
 	                                 If l_period_counter = l_start_period Then
 	                                         x_spread_amounts(l_end_period).amount8 := nvl(x_spread_amounts(l_end_period).amount8,0) +
 	                                                 (p_amount8 - amount_sum);
 	                                 End If;
 	                            End If;
 	                         End If;
 	                 ELSIF k = 9 THEN
 	                         IF (p_amount9 - amount_sum) <> 0 Then
 	                            IF (p_amount9 - amount_sum) > 0 Then
 	                                 x_spread_amounts(l_end_period).amount9 := nvl(x_spread_amounts(l_end_period).amount9,0) +
 	                                                 (p_amount9 - amount_sum);
 	                            Else
 	                                 l_period_counter := l_end_period;
 	                                 FOR i IN REVERSE l_start_period .. l_end_period LOOP
 	                                         If x_spread_amounts.EXISTS(i) Then
 	                                                 IF nvl(x_spread_amounts(i).amount9,0) <> 0 Then
 	                                                    If (nvl(x_spread_amounts(i).amount9,0) + (p_amount9 - amount_sum)) > 0 Then
 	                                                         x_spread_amounts(i).amount9 := nvl(x_spread_amounts(i).amount9,0) +
 	                                                                 (p_amount9 - amount_sum);
 	                                                         Exit;
 	                                                    End If;
 	                                                 End If;
 	                                         End If;
 	                                         l_period_counter := i;
 	                                 END LOOP;
 	                                 /* check all the periods are having zero weightage so put the amounts in the last period */
 	                                 If l_period_counter = l_start_period Then
 	                                         x_spread_amounts(l_end_period).amount9 := nvl(x_spread_amounts(l_end_period).amount9,0) +
 	                                                 (p_amount9 - amount_sum);
 	                                 End If;
 	                            End If;
 	                         End If;
 	                 ELSIF k = 10 THEN
 	                         IF (p_amount10 - amount_sum) <> 0 Then
 	                            IF (p_amount10 - amount_sum) > 0 Then
 	                                 x_spread_amounts(l_end_period).amount10 := nvl(x_spread_amounts(l_end_period).amount10,0) +
 	                                                 (p_amount10 - amount_sum);
 	                            Else
 	                                 l_period_counter := l_end_period;
 	                                 FOR i IN REVERSE l_start_period .. l_end_period LOOP
 	                                         If x_spread_amounts.EXISTS(i) Then
 	                                                 IF nvl(x_spread_amounts(i).amount10,0) <> 0 Then
 	                                                    If (nvl(x_spread_amounts(i).amount10,0) + (p_amount10 - amount_sum)) > 0 Then
 	                                                         x_spread_amounts(i).amount10 := nvl(x_spread_amounts(i).amount10,0) +
 	                                                                 (p_amount10 - amount_sum);
 	                                                         Exit;
 	                                                    End If;
 	                                                 End If;
 	                                         End If;
 	                                         l_period_counter := i;
 	                                 END LOOP;
 	                                 /* check all the periods are having zero weightage so put the amounts in the last period */
 	                                 If l_period_counter = l_start_period Then
 	                                         x_spread_amounts(l_end_period).amount10 := nvl(x_spread_amounts(l_end_period).amount10,0) +
 	                                                 (p_amount10 - amount_sum);
 	                                 End If;
 	                            End If;
 	                         End If;
 	                 END IF;

 	         END LOOP;

 	         pa_debug.g_err_stage := 'Leaving PA_FP_SPREAD_AMTS_PKG.spread';
 	         IF P_PA_DEBUG_MODE = 'Y' THEN
 	                 pa_debug.write('spread: '||g_module_name,
 	                         pa_debug.g_err_stage,
 	                         3);
 	         END IF;
 	         If p_pa_debug_mode = 'Y' Then
 	                 pa_debug.reset_err_stack;
 	         End If;
 	         l_stage := 140;
 	         print_msg('        '||l_stage||' leave spread()');

 	   EXCEPTION

 	         WHEN OTHERS THEN
 	                 print_msg('Unexpected error in Spread['||sqlcode||sqlerrm||']');
 	                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 	                 FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_FP_SPREAD_AMTS_PKG',
 	                                         p_procedure_name => 'spread');
 	                 If p_pa_debug_mode = 'Y' Then
 	                         pa_debug.reset_err_stack;
 	                 End If;
 	                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
 	   END spread;


PROCEDURE spread_day_level( p_number_of_amounts       IN INTEGER,
			p_amount1			IN NUMBER,
			p_amount2			IN NUMBER,
			p_amount3			IN NUMBER,
			p_amount4			IN NUMBER,
			p_amount5			IN NUMBER,
			p_amount6			IN NUMBER,
			p_amount7			IN NUMBER,
			p_amount8			IN NUMBER,
			p_amount9			IN NUMBER,
			p_amount10		IN NUMBER,
			p_start_end_date	IN start_end_date_table_type,
			p_start_period		IN INTEGER := 0,
			p_end_period 		IN INTEGER := 0,
			p_global_start_date	IN Date,
			x_spread_amounts 	IN OUT NOCOPY spread_table_type,
                        x_return_status        	OUT NOCOPY VARCHAR2,
                        x_msg_count            	OUT NOCOPY NUMBER,
                        x_msg_data            	OUT NOCOPY VARCHAR2) IS

  l_start_period	INTEGER;
  l_end_period		INTEGER;
  --accumulated_allocation NUMBER;-- position of accumulated allocation
  amount_sum	NUMBER;
  tmp_start_date	DATE;
  tmp_end_date	DATE;
  --tmp_rec	spread_record_type;
  k		INTEGER;
  j		INTEGER;
  l_period_counter  INTEGER;
  exit_flag	BOOLEAN;

  l_msg_count       NUMBER := 0;
  l_data            VARCHAR2(2000);
  l_msg_data        VARCHAR2(2000);
  l_msg_index_out   NUMBER;
  l_debug_mode	    VARCHAR2(30);

  --l_global_actual_periods	NUMBER;
  --l_global_allocation		NUMBER;
  --l_global_percentage		NUMBER;
  l_resource_assign_duration NUMBER;

  l_stage	    INTEGER;

  BEGIN
	l_stage := 10.1;
	print_msg('        '||l_stage||' enter spread_daily_level()');
  	x_return_status := FND_API.G_RET_STS_SUCCESS;
	If p_pa_debug_mode = 'Y' Then
		pa_debug.init_err_stack('PA_FP_SPREAD_AMTS_PKG.spread_daily_level');
	End If;

	fnd_profile.get('PA_DEBUG_MODE', l_debug_mode);
	pa_debug.set_process('PLSQL', 'LOG', l_debug_mode);

	pa_debug.g_err_stage := 'Entered PA_FP_SPREAD_AMTS_PKG.spread_daily_level';
	IF P_PA_DEBUG_MODE = 'Y' THEN
		pa_debug.write('spread: '||g_module_name,
			pa_debug.g_err_stage,
			3);
	END IF;

	l_stage := 20.1;
	print_msg('	'||l_stage||' p_number_of_amounts	=> '||p_number_of_amounts);

	print_msg('	'||'p_amount1		=> '||p_amount1);
	print_msg('	'||'p_amount2		=> '||p_amount2);
	print_msg('	'||'p_amount3		=> '||p_amount3);
	print_msg('	'||'p_amount4		=> '||p_amount4);
	print_msg('	'||'p_amount5		=> '||p_amount5);
	print_msg('	'||'p_amount6		=> '||p_amount6);
	print_msg('	'||'p_amount7		=> '||p_amount7);
	print_msg('	'||'p_amount8		=> '||p_amount8);
	print_msg('	'||'p_amount9		=> '||p_amount9);
	print_msg('	'||'p_amount10		=> '||p_amount10);

	-- Validating

	l_stage := 30.1;
	print_msg('	'||l_stage||' before validate p_number_of_amounts');
	-- p_number_of_amounts cannot overflow
	IF NOT p_number_of_amounts BETWEEN 1 AND 10 THEN

		x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := 'PA_FP_NUM_OF_AMTS_OVERFLOW';
		If p_pa_debug_mode = 'Y' Then
			pa_debug.reset_err_stack;
		End If;
		RETURN;
	END IF;

	l_stage := 40.1;
	print_msg('	'||l_stage||' before validate p_start_end_date');
	-- p_start_end_date cannot be null and
	-- each start_date must earlier than end_date in p_start_end_date,
	-- and they cannot overlap each other.
	IF p_start_end_date IS NULL THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_msg_data := 'PA_FP_PLAN_START_END_DATE_NULL';
		If p_pa_debug_mode = 'Y' Then
			pa_debug.reset_err_stack;
		End If;
		RETURN;
	END IF;
	FOR k IN 1 .. p_start_end_date.COUNT()
	LOOP
		IF --p_start_end_date(k) IS NULL OR
			p_start_end_date(k).start_date IS NULL OR
			p_start_end_date(k).end_date IS NULL OR
			p_start_end_date(k).start_date >
			p_start_end_date(k).end_date OR
			k < p_start_end_date.COUNT() AND
			p_start_end_date(k + 1).start_date <=
			p_start_end_date(k).end_date THEN

			x_return_status := FND_API.G_RET_STS_ERROR;
			x_msg_data := 'PA_FP_START_END_DATE_OVERLAP';
			If p_pa_debug_mode = 'Y' Then
				pa_debug.reset_err_stack;
			End If;
			RETURN;
		END IF;
	END LOOP;

	l_stage := 60.1;
	print_msg('	'||l_stage||' before validate x_spread_amounts');
	-- x_spread_amounts cannot be NULL and
	-- x_spread_amounts' start end date must match with p_start_end_date.
	IF (x_spread_amounts IS NULL OR x_spread_amounts.COUNT() = 0 ) THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_msg_data := 'PA_FP_PERIODS_IS_NULL';
		print_msg('x_msg_data['||x_msg_data||']');
		If p_pa_debug_mode = 'Y' Then
			pa_debug.reset_err_stack;
		End If;
		RETURN;
	END IF;
	--print_msg('Count of x_spread_amounts.COUNT()['||x_spread_amounts.COUNT()||']');
	FOR k IN 1 .. x_spread_amounts.COUNT()
	LOOP
		IF --x_spread_amounts(k) IS NULL OR
			x_spread_amounts(k).start_date IS NULL OR
			x_spread_amounts(k).end_date IS NULL OR
			x_spread_amounts(k).start_date >
			x_spread_amounts(k).end_date OR
			k < x_spread_amounts.COUNT() AND
			x_spread_amounts(k + 1).start_date <=
			x_spread_amounts(k).end_date THEN

			x_return_status := FND_API.G_RET_STS_ERROR;
			x_msg_data := 'PA_FP_START_END_DATE_NOT_MATCH';
			If p_pa_debug_mode = 'Y' Then
				pa_debug.reset_err_stack;
			End If;
			--print_msg('x_msg_data['||x_msg_data||']');
			RETURN;
		END IF;
	END LOOP;
	IF p_start_end_date(1).start_date >
		x_spread_amounts(1).end_date OR
		p_start_end_date(p_start_end_date.COUNT()).end_date <
		x_spread_amounts(x_spread_amounts.COUNT()).start_date THEN

			x_return_status := FND_API.G_RET_STS_ERROR;
			x_msg_data := 'PA_FP_START_END_DATE_NOT_MATCH';
			--print_msg('x_msg_data['||x_msg_data||']');
			If p_pa_debug_mode = 'Y' Then
				pa_debug.reset_err_stack;
			End If;
			RETURN;
	END IF;


	l_stage := 70;
	print_msg('	'||l_stage||' before validate p_start/end_period');
	-- p_start_period/p_end_period validateing
	IF NOT (p_start_period BETWEEN 1 AND x_spread_amounts.COUNT() AND
		p_end_period BETWEEN 1 AND x_spread_amounts.COUNT() AND
		p_start_period <= p_end_period) THEN

			x_return_status := FND_API.G_RET_STS_ERROR;
			x_msg_data := 'PA_FP_PERIOD_NO_MATCH';
			print_msg('x_msg_data['||x_msg_data||']');
			If p_pa_debug_mode = 'Y' Then
				pa_debug.reset_err_stack;
			End If;
			RETURN;
	END IF;
	l_start_period := p_start_period;
	l_end_period := p_end_period;
	l_stage := 80;
	print_msg('	'||l_stage||' after validation');

	-- Calculate the number of period for each period and
	-- total number of period

	FOR k IN 1 .. x_spread_amounts.COUNT()
	LOOP
		x_spread_amounts(k).actual_days := 0;
	END LOOP;


	k := 1;
	FOR j IN 1 .. x_spread_amounts.COUNT()
	LOOP

	    IF x_spread_amounts(j).end_date < p_start_end_date(k).start_date THEN

		x_spread_amounts(j).actual_days := 0;
		x_spread_amounts(j).actual_periods := 0;

	    ELSE

		IF p_start_end_date(k).start_date BETWEEN
			x_spread_amounts(j).start_date AND
			x_spread_amounts(j).end_date THEN
			tmp_start_date := p_start_end_date(k).start_date;
		ELSE
			tmp_start_date := x_spread_amounts(j).start_date;
		END IF;
		IF p_start_end_date(k).end_date BETWEEN
			x_spread_amounts(j).start_date AND
			x_spread_amounts(j).end_date THEN
			tmp_end_date := p_start_end_date(k).end_date;
		ELSE
			tmp_end_date := x_spread_amounts(j).end_date;
		END IF;
		x_spread_amounts(j).actual_days :=
			x_spread_amounts(j).actual_days +
			tmp_end_date - tmp_start_date + 1;
		x_spread_amounts(j).actual_periods :=
			x_spread_amounts(j).actual_days /
			(x_spread_amounts(j).end_date
			 - x_spread_amounts(j).start_date + 1);

		LOOP
		EXIT WHEN NOT (k < p_start_end_date.COUNT() AND
			p_start_end_date(k + 1).end_date <=
			x_spread_amounts(j).end_date);

			k := k + 1;

			x_spread_amounts(j).actual_days :=
				x_spread_amounts(j).actual_days +
				p_start_end_date(k).end_date -
				p_start_end_date(k).start_date + 1;
			x_spread_amounts(j).actual_periods :=
				x_spread_amounts(j).actual_days /
				(x_spread_amounts(j).end_date
			 	- x_spread_amounts(j).start_date + 1);

	    	END LOOP;

		IF k < p_start_end_date.COUNT() AND
			p_start_end_date(k + 1).start_date <=
			x_spread_amounts(j).end_date THEN

			k := k + 1;
			tmp_start_date := p_start_end_date(k).start_date;
			tmp_end_date := x_spread_amounts(j).end_date;
			x_spread_amounts(j).actual_days :=
				x_spread_amounts(j).actual_days +
				tmp_end_date - tmp_start_date + 1;
			x_spread_amounts(j).actual_periods :=
				x_spread_amounts(j).actual_days /
				(x_spread_amounts(j).end_date
			 	- x_spread_amounts(j).start_date + 1);
		END IF;

		IF k < p_start_end_date.COUNT() AND
			p_start_end_date(k).end_date <=
			x_spread_amounts(j).end_date THEN
			k := k + 1;
		END IF;

	    END IF;

	END LOOP;
	/*
	IF p_global_start_date IS NOT NULL THEN
		--print_msg('end date['||x_spread_amounts(l_start_period).end_date||']StartDate['||x_spread_amounts(l_start_period).start_date||']');
		l_global_actual_periods :=
			(x_spread_amounts(l_start_period).end_date -
			p_global_start_date + 1) /
			(x_spread_amounts(l_start_period).end_date -
			x_spread_amounts(l_start_period).start_date + 1);
		--print_msg('l_global_actual_periods['||l_global_actual_periods||']');
	END IF;
	l_stage := 81;
	print_msg('        '||l_stage||' after calculate actual period for global start date '||round(l_global_actual_periods,2));
	print_msg('Actual num of periods['||x_spread_amounts(k).actual_periods||']SpCount['||x_spread_amounts.COUNT||']');

	l_stage := 90;
	FOR k IN 1 .. x_spread_amounts.COUNT()
	LOOP

	print_msg('p_global_start_date['||p_global_start_date||']');
	*/
	--      IF p_global_start_date IS NOT NULL THEN

	l_stage := 121;
	FOR r IN 1 .. p_start_end_date.COUNT() LOOP

       print_msg('p_start_end_date index :'||r);
       print_msg('p_start_end_date(r).end_date'||p_start_end_date(r).end_date);
       print_msg('p_start_end_date(r).start_date'||p_start_end_date(r).start_date);

	END LOOP;

         l_resource_assign_duration := (p_start_end_date(1).end_date - p_start_end_date(1).start_date) + 1;
	print_msg('l_resource_assign_duration'||To_Char(l_resource_assign_duration));


	FOR k IN 1 .. x_spread_amounts.COUNT()
	LOOP

		FOR j IN 1 .. p_number_of_amounts --p_amounts.COUNT()
		LOOP

		    x_spread_amounts(k).number_of_amounts :=
				p_number_of_amounts;

	    	    IF k BETWEEN l_start_period AND l_end_period THEN
			--tmp_amounts(j) := p_amounts(j) *

			IF j = 1 THEN
				x_spread_amounts(k).amount1 := p_amount1 *
				x_spread_amounts(k).actual_days / l_resource_assign_duration ;
			ELSIF j = 2 THEN
				x_spread_amounts(k).amount2 := p_amount2 *
				x_spread_amounts(k).actual_days / l_resource_assign_duration ;
			ELSIF j = 3 THEN
				x_spread_amounts(k).amount3 := p_amount3 *
				x_spread_amounts(k).actual_days / l_resource_assign_duration ;
			ELSIF j = 4 THEN
				x_spread_amounts(k).amount4 := p_amount4 *
				x_spread_amounts(k).actual_days / l_resource_assign_duration ;
			ELSIF j = 5 THEN
				x_spread_amounts(k).amount5 := p_amount5 *
				x_spread_amounts(k).actual_days / l_resource_assign_duration ;
			ELSIF j = 6 THEN
				x_spread_amounts(k).amount6 := p_amount6 *
				x_spread_amounts(k).actual_days / l_resource_assign_duration ;
			ELSIF j = 7 THEN
				x_spread_amounts(k).amount7 := p_amount7 *
				x_spread_amounts(k).actual_days / l_resource_assign_duration ;
			ELSIF j = 8 THEN
				x_spread_amounts(k).amount8 := p_amount8 *
				x_spread_amounts(k).actual_days / l_resource_assign_duration ;
			ELSIF j = 9 THEN
				x_spread_amounts(k).amount9 := p_amount9 *
				x_spread_amounts(k).actual_days / l_resource_assign_duration ;
			ELSIF j = 10 THEN
				x_spread_amounts(k).amount10 := p_amount10 *
				x_spread_amounts(k).actual_days / l_resource_assign_duration ;
			END IF;
	    	    ELSE
			IF j = 1 THEN x_spread_amounts(k).amount1 := 0;
			ELSIF j = 2 THEN x_spread_amounts(k).amount2 := 0;
			ELSIF j = 3 THEN x_spread_amounts(k).amount3 := 0;
			ELSIF j = 4 THEN x_spread_amounts(k).amount4 := 0;
			ELSIF j = 5 THEN x_spread_amounts(k).amount5 := 0;
			ELSIF j = 6 THEN x_spread_amounts(k).amount6 := 0;
			ELSIF j = 7 THEN x_spread_amounts(k).amount7 := 0;
			ELSIF j = 8 THEN x_spread_amounts(k).amount8 := 0;
			ELSIF j = 9 THEN x_spread_amounts(k).amount9 := 0;
			ELSIF j = 10 THEN x_spread_amounts(k).amount10 := 0;
			END IF;
			--tmp_amounts(j) := 0;
		    END IF;

		print_msg('printing x_spread_amounts  values');
 	        print_msg('x_spread_amounts(k) index # '||k);
 	        print_msg('x_spread_amounts(k).actual_days amount of days in the period'||x_spread_amounts(k).actual_days);
 	        print_msg('x_spread_amounts(k).amount1 value is :'||x_spread_amounts(k).amount1);
 	        print_msg('x_spread_amounts(k).amount2 value is :'||x_spread_amounts(k).amount2);
 	        print_msg('x_spread_amounts(k).amount3 value is :'||x_spread_amounts(k).amount3);
 	        print_msg('x_spread_amounts(k).amount4 value is :'||x_spread_amounts(k).amount4);

		END LOOP;


	END LOOP;

	FOR k IN 1 .. x_spread_amounts.COUNT()
	LOOP
		-- make sure that amount1 is always passed with quantity
		x_spread_amounts(k).amount1 :=
			Round_Qty_Amts(G_rate_based_flag,'Y',G_curr_code,(x_spread_amounts(k).amount1));
		x_spread_amounts(k).amount2 :=
			Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount2));
		x_spread_amounts(k).amount3 :=
			Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount3));
		x_spread_amounts(k).amount4 :=
			Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount4));
		x_spread_amounts(k).amount5 :=
			Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount5));
		x_spread_amounts(k).amount6 :=
			Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount6));
		x_spread_amounts(k).amount7 :=
			Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount7));
		x_spread_amounts(k).amount8 :=
			Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount8));
		x_spread_amounts(k).amount9 :=
			Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount9));
		x_spread_amounts(k).amount10 :=
			Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,(x_spread_amounts(k).amount10));
	END LOOP;
	l_stage := 130;
	print_msg('	'||l_stage||' after calculate amounts');

	-- Adjust the amounts for last period
	FOR k IN 1 .. p_number_of_amounts  --p_amounts.COUNT()
	LOOP

		amount_sum := 0;
		FOR j IN 1 .. x_spread_amounts.COUNT()
		LOOP
			IF k = 1 THEN
				amount_sum := amount_sum +
				nvl(x_spread_amounts(j).amount1,0);
			ELSIF k = 2 THEN
				amount_sum := amount_sum +
				nvl(x_spread_amounts(j).amount2,0);
			ELSIF k = 3 THEN
				amount_sum := amount_sum +
				nvl(x_spread_amounts(j).amount3,0);
			ELSIF k = 4 THEN
				amount_sum := amount_sum +
				nvl(x_spread_amounts(j).amount4,0);
			ELSIF k = 5 THEN
				amount_sum := amount_sum +
				nvl(x_spread_amounts(j).amount5,0);
			ELSIF k = 6 THEN
				amount_sum := amount_sum +
				nvl(x_spread_amounts(j).amount6,0);
			ELSIF k = 7 THEN
				amount_sum := amount_sum +
				nvl(x_spread_amounts(j).amount7,0);
			ELSIF k = 8 THEN
				amount_sum := amount_sum +
				nvl(x_spread_amounts(j).amount8,0);
			ELSIF k = 9 THEN
				amount_sum := amount_sum +
				nvl(x_spread_amounts(j).amount9,0);
			ELSIF k = 10 THEN
				amount_sum := amount_sum +
				nvl(x_spread_amounts(j).amount10,0);
			END IF;
		END LOOP;

		/* Bug fix: 3961955 : The last period is getting updated with -ve amounts when spread curve weightage is zero
		 * Logic: The following code is updating the last budget line with the rounding diff amount
		 * Loop through the periodic budget lines in the reverse order. If the last period line is having zero weightage
		 * then put the diff amounts in the previous period.  If all the periods are zero weightage then put the
		 * entire amounts/diff amounts in the Last period of the profile
		 */
		IF k = 1 THEN
			IF (p_amount1 - amount_sum) <> 0 Then
			   IF (p_amount1 - amount_sum) > 0 Then
				x_spread_amounts(l_end_period).amount1 := nvl(x_spread_amounts(l_end_period).amount1,0) +
                                                (p_amount1 - amount_sum);
			   Else
				l_period_counter := l_end_period;
				FOR i IN REVERSE l_start_period .. l_end_period LOOP
					If x_spread_amounts.EXISTS(i) Then
						IF nvl(x_spread_amounts(i).amount1,0) <> 0 Then
						   If (nvl(x_spread_amounts(i).amount1,0) + (p_amount1 - amount_sum)) > 0 Then
							x_spread_amounts(i).amount1 := nvl(x_spread_amounts(i).amount1,0) +
                                        			(p_amount1 - amount_sum);
							x_spread_amounts(i).amount1 :=
                                                        Round_Qty_Amts(G_rate_based_flag,'Y',G_curr_code,(x_spread_amounts(i).amount1));
							Exit;
						   End If;
						End If;
					End If;
					l_period_counter := i;
				END LOOP;
				/* check all the periods are having zero weightage so put the amounts in the last period */
				If l_period_counter = l_start_period Then
					x_spread_amounts(l_end_period).amount1 := nvl(x_spread_amounts(l_end_period).amount1,0) +
                                        	(p_amount1 - amount_sum);
					print_msg('Adding round diff makes all the lines -ve,so just put diff in first bucket');
					x_spread_amounts(l_end_period).amount1 :=
					Round_Qty_Amts(G_rate_based_flag,'Y',G_curr_code,(x_spread_amounts(l_end_period).amount1));
				End If;
			   End If;
			End If;
		ELSIF k = 2 THEN
                        IF (p_amount2 - amount_sum) <> 0 Then
			   IF (p_amount2 - amount_sum) > 0 Then
                                        x_spread_amounts(l_end_period).amount2 := nvl(x_spread_amounts(l_end_period).amount2,0) +
                                                (p_amount2 - amount_sum);
			   ELSE
                                l_period_counter := l_end_period;
                                FOR i IN REVERSE l_start_period .. l_end_period LOOP
                                        If x_spread_amounts.EXISTS(i) Then
                                                IF nvl(x_spread_amounts(i).amount2,0) <> 0 Then
						   If(nvl(x_spread_amounts(i).amount2,0) + (p_amount2 - amount_sum)) > 0 Then
                                                        x_spread_amounts(i).amount2 := nvl(x_spread_amounts(i).amount2,0) +
                                                                (p_amount2 - amount_sum);
                                                        Exit;
						   End If;
                                                End If;
                                        End If;
                                        l_period_counter := i;
                                END LOOP;
                                /* check all the periods are having zero weightage so put the amounts in the last period */
                                If l_period_counter = l_start_period Then
                                        x_spread_amounts(l_end_period).amount2 := nvl(x_spread_amounts(l_end_period).amount2,0) +
                                                (p_amount2 - amount_sum);
                                End If;
			   END IF;
                        End If;
		ELSIF k = 3 THEN
                        IF (p_amount3 - amount_sum) <> 0 Then
			   IF (p_amount3 - amount_sum) > 0 Then
                                        x_spread_amounts(l_end_period).amount3 := nvl(x_spread_amounts(l_end_period).amount3,0) +
                                                (p_amount3 - amount_sum);
			   ELSE
                                l_period_counter := l_end_period;
                                FOR i IN REVERSE l_start_period .. l_end_period LOOP
                                        If x_spread_amounts.EXISTS(i) Then
                                                IF nvl(x_spread_amounts(i).amount3,0) <> 0 Then
						   If (nvl(x_spread_amounts(i).amount3,0)+ (p_amount3 - amount_sum)) > 0 Then
                                                        x_spread_amounts(i).amount3 := nvl(x_spread_amounts(i).amount3,0) +
                                                                (p_amount3 - amount_sum);
                                                        Exit;
						   End If;
                                                End If;
                                        End If;
                                        l_period_counter := i;
                                END LOOP;
                                /* check all the periods are having zero weightage so put the amounts in the last period */
                                If l_period_counter = l_start_period Then
                                        x_spread_amounts(l_end_period).amount3 := nvl(x_spread_amounts(l_end_period).amount3,0) +
                                                (p_amount3 - amount_sum);
                                End If;
			   END IF;
                        End If;
		ELSIF k = 4 THEN
                        IF (p_amount4 - amount_sum) <> 0 Then
			   IF (p_amount4 - amount_sum) > 0 Then
                                   x_spread_amounts(l_end_period).amount4 := nvl(x_spread_amounts(l_end_period).amount4,0) +
                                                (p_amount4 - amount_sum);
			   ELSE
                                l_period_counter := l_end_period;
                                FOR i IN REVERSE l_start_period .. l_end_period LOOP
                                        If x_spread_amounts.EXISTS(i) Then
                                                IF nvl(x_spread_amounts(i).amount4,0) <> 0 Then
						   If (nvl(x_spread_amounts(i).amount4,0) + (p_amount4 - amount_sum)) > 0 Then
                                                        x_spread_amounts(i).amount4 := nvl(x_spread_amounts(i).amount4,0) +
                                                                (p_amount4 - amount_sum);
                                                        Exit;
						   End If;
                                                End If;
                                        End If;
                                        l_period_counter := i;
                                END LOOP;
                                /* check all the periods are having zero weightage so put the amounts in the last period */
                                If l_period_counter = l_start_period Then
                                        x_spread_amounts(l_end_period).amount4 := nvl(x_spread_amounts(l_end_period).amount4,0) +
                                                (p_amount4 - amount_sum);
                                End If;
			   END IF;
                        End If;
		ELSIF k = 5 THEN
                        IF (p_amount5 - amount_sum) <> 0 Then
                           IF (p_amount5 - amount_sum) > 0 Then
                                x_spread_amounts(l_end_period).amount5 := nvl(x_spread_amounts(l_end_period).amount5,0) +
                                                (p_amount5 - amount_sum);
                           Else
                                l_period_counter := l_end_period;
                                FOR i IN REVERSE l_start_period .. l_end_period LOOP
                                        If x_spread_amounts.EXISTS(i) Then
                                                IF nvl(x_spread_amounts(i).amount5,0) <> 0 Then
                                                   If (nvl(x_spread_amounts(i).amount5,0) + (p_amount5 - amount_sum)) > 0 Then
                                                        x_spread_amounts(i).amount5 := nvl(x_spread_amounts(i).amount5,0) +
                                                                (p_amount5 - amount_sum);
                                                        Exit;
                                                   End If;
                                                End If;
                                        End If;
                                        l_period_counter := i;
                                END LOOP;
                                /* check all the periods are having zero weightage so put the amounts in the last period */
                                If l_period_counter = l_start_period Then
                                        x_spread_amounts(l_end_period).amount5 := nvl(x_spread_amounts(l_end_period).amount5,0) +
                                                (p_amount5 - amount_sum);
                                End If;
                           End If;
                        End If;
		ELSIF k = 6 THEN
                        IF (p_amount6 - amount_sum) <> 0 Then
                           IF (p_amount6 - amount_sum) > 0 Then
                                x_spread_amounts(l_end_period).amount6 := nvl(x_spread_amounts(l_end_period).amount6,0) +
                                                (p_amount6 - amount_sum);
                           Else
                                l_period_counter := l_end_period;
                                FOR i IN REVERSE l_start_period .. l_end_period LOOP
                                        If x_spread_amounts.EXISTS(i) Then
                                                IF nvl(x_spread_amounts(i).amount6,0) <> 0 Then
                                                   If (nvl(x_spread_amounts(i).amount6,0) + (p_amount6 - amount_sum)) > 0 Then
                                                        x_spread_amounts(i).amount6 := nvl(x_spread_amounts(i).amount6,0) +
                                                                (p_amount6 - amount_sum);
                                                        Exit;
                                                   End If;
                                                End If;
                                        End If;
                                        l_period_counter := i;
                                END LOOP;
                                /* check all the periods are having zero weightage so put the amounts in the last period */
                                If l_period_counter = l_start_period Then
                                        x_spread_amounts(l_end_period).amount6 := nvl(x_spread_amounts(l_end_period).amount6,0) +
                                                (p_amount6 - amount_sum);
                                End If;
                           End If;
                        End If;
		ELSIF k = 7 THEN
                        IF (p_amount7 - amount_sum) <> 0 Then
                           IF (p_amount7 - amount_sum) > 0 Then
                                x_spread_amounts(l_end_period).amount7 := nvl(x_spread_amounts(l_end_period).amount7,0) +
                                                (p_amount7 - amount_sum);
                           Else
                                l_period_counter := l_end_period;
                                FOR i IN REVERSE l_start_period .. l_end_period LOOP
                                        If x_spread_amounts.EXISTS(i) Then
                                                IF nvl(x_spread_amounts(i).amount7,0) <> 0 Then
                                                   If (nvl(x_spread_amounts(i).amount7,0) + (p_amount7 - amount_sum)) > 0 Then
                                                        x_spread_amounts(i).amount7 := nvl(x_spread_amounts(i).amount7,0) +
                                                                (p_amount7 - amount_sum);
                                                        Exit;
                                                   End If;
                                                End If;
                                        End If;
                                        l_period_counter := i;
                                END LOOP;
                                /* check all the periods are having zero weightage so put the amounts in the last period */
                                If l_period_counter = l_start_period Then
                                        x_spread_amounts(l_end_period).amount7 := nvl(x_spread_amounts(l_end_period).amount7,0) +
                                                (p_amount7 - amount_sum);
                                End If;
                           End If;
                        End If;
		ELSIF k = 8 THEN
                        IF (p_amount8 - amount_sum) <> 0 Then
                           IF (p_amount8 - amount_sum) > 0 Then
                                x_spread_amounts(l_end_period).amount8 := nvl(x_spread_amounts(l_end_period).amount8,0) +
                                                (p_amount8 - amount_sum);
                           Else
                                l_period_counter := l_end_period;
                                FOR i IN REVERSE l_start_period .. l_end_period LOOP
                                        If x_spread_amounts.EXISTS(i) Then
                                                IF nvl(x_spread_amounts(i).amount8,0) <> 0 Then
                                                   If (nvl(x_spread_amounts(i).amount8,0) + (p_amount8 - amount_sum)) > 0 Then
                                                        x_spread_amounts(i).amount8 := nvl(x_spread_amounts(i).amount8,0) +
                                                                (p_amount8 - amount_sum);
                                                        Exit;
                                                   End If;
                                                End If;
                                        End If;
                                        l_period_counter := i;
                                END LOOP;
                                /* check all the periods are having zero weightage so put the amounts in the last period */
                                If l_period_counter = l_start_period Then
                                        x_spread_amounts(l_end_period).amount8 := nvl(x_spread_amounts(l_end_period).amount8,0) +
                                                (p_amount8 - amount_sum);
                                End If;
                           End If;
                        End If;
		ELSIF k = 9 THEN
                        IF (p_amount9 - amount_sum) <> 0 Then
                           IF (p_amount9 - amount_sum) > 0 Then
                                x_spread_amounts(l_end_period).amount9 := nvl(x_spread_amounts(l_end_period).amount9,0) +
                                                (p_amount9 - amount_sum);
                           Else
                                l_period_counter := l_end_period;
                                FOR i IN REVERSE l_start_period .. l_end_period LOOP
                                        If x_spread_amounts.EXISTS(i) Then
                                                IF nvl(x_spread_amounts(i).amount9,0) <> 0 Then
                                                   If (nvl(x_spread_amounts(i).amount9,0) + (p_amount9 - amount_sum)) > 0 Then
                                                        x_spread_amounts(i).amount9 := nvl(x_spread_amounts(i).amount9,0) +
                                                                (p_amount9 - amount_sum);
                                                        Exit;
                                                   End If;
                                                End If;
                                        End If;
                                        l_period_counter := i;
                                END LOOP;
                                /* check all the periods are having zero weightage so put the amounts in the last period */
                                If l_period_counter = l_start_period Then
                                        x_spread_amounts(l_end_period).amount9 := nvl(x_spread_amounts(l_end_period).amount9,0) +
                                                (p_amount9 - amount_sum);
                                End If;
                           End If;
                        End If;
		ELSIF k = 10 THEN
                        IF (p_amount10 - amount_sum) <> 0 Then
                           IF (p_amount10 - amount_sum) > 0 Then
                                x_spread_amounts(l_end_period).amount10 := nvl(x_spread_amounts(l_end_period).amount10,0) +
                                                (p_amount10 - amount_sum);
                           Else
                                l_period_counter := l_end_period;
                                FOR i IN REVERSE l_start_period .. l_end_period LOOP
                                        If x_spread_amounts.EXISTS(i) Then
                                                IF nvl(x_spread_amounts(i).amount10,0) <> 0 Then
                                                   If (nvl(x_spread_amounts(i).amount10,0) + (p_amount10 - amount_sum)) > 0 Then
                                                        x_spread_amounts(i).amount10 := nvl(x_spread_amounts(i).amount10,0) +
                                                                (p_amount10 - amount_sum);
                                                        Exit;
                                                   End If;
                                                End If;
                                        End If;
                                        l_period_counter := i;
                                END LOOP;
                                /* check all the periods are having zero weightage so put the amounts in the last period */
                                If l_period_counter = l_start_period Then
                                        x_spread_amounts(l_end_period).amount10 := nvl(x_spread_amounts(l_end_period).amount10,0) +
                                                (p_amount10 - amount_sum);
                                End If;
                           End If;
                        End If;
		END IF;

	END LOOP;

 END spread_day_level;

  PROCEDURE get_options (
	p_budget_version_id	IN pa_budget_versions.
					budget_version_id%TYPE,
 	x_period_set_name       OUT NOCOPY gl_sets_of_books.
					period_set_name%TYPE,
    	x_accounted_period_type OUT NOCOPY gl_sets_of_books.
					accounted_period_type%TYPE,
    	x_pa_period_type        OUT NOCOPY pa_implementations_all.
					pa_period_type%TYPE,
	x_time_phase_code	OUT NOCOPY pa_proj_fp_options.
					all_time_phased_code%TYPE,
        x_return_status      OUT NOCOPY VARCHAR2,
        x_msg_count          OUT NOCOPY NUMBER,
        x_msg_data           OUT NOCOPY VARCHAR2) IS

  l_msg_count       NUMBER := 0;
  l_data            VARCHAR2(2000);
  l_msg_data        VARCHAR2(2000);
  l_msg_index_out   NUMBER;
  l_debug_mode	    VARCHAR2(30);



  l_stage		INTEGER;

  CURSOR get_name_and_type_csr IS
      SELECT                                        --gsb.period_set_name /*Start changes for bug 6156873*/
   	decode(decode(pbv.version_type,
		              'COST',ppfo.cost_time_phased_code,
                	'REVENUE',ppfo.revenue_time_phased_code,
			              ppfo.all_time_phased_code)
			     ,'P', pia.period_set_name
			     ,gsb.period_set_name) period_set_name          /*End changes for bug 6156873*/
         	,gsb.accounted_period_type
		,pia.pa_period_type
		,decode(pbv.version_type,
		        'COST',ppfo.cost_time_phased_code,
                	'REVENUE',ppfo.revenue_time_phased_code,
			 ppfo.all_time_phased_code) time_phase_code
	 FROM gl_sets_of_books       	gsb
	     	,pa_implementations_all pia
		,pa_projects_all        ppa
		,pa_budget_versions     pbv
		,pa_proj_fp_options     ppfo
	WHERE ppa.project_id        = pbv.project_id
	  AND pbv.budget_version_id = ppfo.fin_plan_version_id
	  /* MOAC Changes: AND nvl(ppa.org_id,-99)   = nvl(pia.org_id,-99) */
          AND ppa.org_id   = pia.org_id
	  AND gsb.set_of_books_id   = pia.set_of_books_id
	  AND pbv.budget_version_id = p_budget_version_id;


  get_name_and_type_rec       get_name_and_type_csr%ROWTYPE;

  BEGIN
	l_stage := 200;
	print_msg('	'||l_stage||' enter get_options()');

  	x_return_status := FND_API.G_RET_STS_SUCCESS;
	If p_pa_debug_mode = 'Y' Then
		pa_debug.init_err_stack( 'PA_FP_SPREAD_AMTS_PKG.get_options');
		pa_debug.set_process('PLSQL', 'LOG', p_pa_debug_mode);
	End If;

	l_stage := 205;
	print_msg(l_stage||'input parameters:p_budget_version_id=> '||p_budget_version_id);


	-- get set name, period type and time phase
	get_name_and_type_rec := NULL;
    	OPEN  get_name_and_type_csr;
    	FETCH get_name_and_type_csr INTO get_name_and_type_rec;

    	IF get_name_and_type_csr%NOTFOUND THEN

		CLOSE get_name_and_type_csr;

		x_return_status := FND_API.G_RET_STS_ERROR;
		x_msg_data := 'PA_FP_CANNOT_GET_TIME_PHASE';
		If p_pa_debug_mode = 'Y' Then
        		pa_debug.reset_err_stack;
		End If;
		l_stage := 206;
		print_msg('	'||'cannot found name  type');
		RETURN;
	END IF;

	CLOSE get_name_and_type_csr;

 	x_period_set_name         :=
		get_name_and_type_rec.period_set_name;
    	x_accounted_period_type   :=
		get_name_and_type_rec.accounted_period_type;
    	x_pa_period_type          :=
		get_name_and_type_rec.pa_period_type;
	x_time_phase_code	  :=
		get_name_and_type_rec.time_phase_code;
	l_stage := 230;
	If p_pa_debug_mode = 'Y' Then
	print_msg('	'||l_stage||' after get set name,period type,time phase');
	print_msg('	'||'period_set_name		=> '||get_name_and_type_rec.period_set_name);
	print_msg('	'||'accounted_period_type	=> '||get_name_and_type_rec.accounted_period_type);
	print_msg('	'||'pa_period_type		=> '||get_name_and_type_rec.pa_period_type);
	print_msg('	'||'time_phase_code		=> '||get_name_and_type_rec.time_phase_code);
 	End If;

	/* reset error stack */
	If p_pa_debug_mode = 'Y' Then
		pa_debug.reset_err_stack;
	End If;
	l_stage := 240;
	print_msg('	'||l_stage||' leave get options');

  EXCEPTION

	WHEN OTHERS THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_FP_SPREAD_AMTS_PKG',
					p_procedure_name => 'get_options');
		If p_pa_debug_mode = 'Y' Then
			pa_debug.reset_err_stack;
		End If;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;

  END get_options;

  PROCEDURE get_periods (
	p_start_date		IN pa_budget_lines.start_date%TYPE,
	p_end_date		IN pa_budget_lines.end_date%TYPE,
 	p_period_set_name       IN gl_sets_of_books.
					period_set_name%TYPE,
    	p_accounted_period_type IN gl_sets_of_books.
					accounted_period_type%TYPE,
    	p_pa_period_type        IN pa_implementations_all.
					pa_period_type%TYPE,
	p_time_phase_code	IN pa_proj_fp_options.
					all_time_phased_code%TYPE,
	x_spread_amounts	OUT NOCOPY spread_table_type,
        x_return_status      OUT NOCOPY VARCHAR2,
        x_msg_count          OUT NOCOPY NUMBER,
        x_msg_data           OUT NOCOPY VARCHAR2) IS

  l_msg_count       NUMBER := 0;
  l_data            VARCHAR2(2000);
  l_msg_data        VARCHAR2(2000);
  l_msg_index_out   NUMBER;
  l_debug_mode	    VARCHAR2(30);

  l_period_set_name		gl_sets_of_books.period_set_name%TYPE;
  l_accounted_period_type	gl_sets_of_books.accounted_period_type%TYPE;
  l_pa_period_type		pa_implementations_all.pa_period_type%TYPE;
  l_time_phase_code		pa_proj_fp_options.cost_time_phased_code%TYPE;
  l_start_date			DATE;
  l_end_date			DATE;

  tmp_rec		spread_record_type;
  n			INTEGER;

  l_stage		INTEGER;


	/** Explain plan for the tuned sql
	================
	EXPLAIN PLAN IS:
	================
	1:SELECT STATEMENT   :(cost=8,rows=2)
 	 2:SORT ORDER BY  :(cost=8,rows=2)
   	  3:TABLE ACCESS BY INDEX ROWID GL_PERIODS :(cost=4,rows=2)
     	   4:INDEX RANGE SCAN GL_PERIODS_U2 :(cost=2,rows=2)
	**/
	CURSOR get_gl_periods_csr IS
        SELECT START_DATE, END_DATE, PERIOD_NAME
        FROM gl_periods gp
        WHERE gp.period_set_name  = l_period_set_name
        AND gp.period_type        = decode(l_time_phase_code,'G',l_accounted_period_type,'P',l_pa_period_type)
	AND gp.adjustment_period_flag = 'N'
	AND gp.start_date  <= l_end_date   -- plan end date
	AND  gp.end_date   >= l_start_date -- planning start date
	ORDER BY gp.start_date;

    	/** Performance Fix: SQL modified to avoid hitting MIN and MAX again and again
	================
	EXPLAIN PLAN IS:
	================
	1:SELECT STATEMENT   :(cost=8,rows=1)
 	 2:FILTER   :(cost=,rows=)
   	  3:TABLE ACCESS BY INDEX ROWID GL_PERIODS :(cost=8,rows=1)
     	   4:INDEX RANGE SCAN GL_PERIODS_N1 :(cost=2,rows=1)
       	    5:SORT AGGREGATE  :(cost=,rows=1)
             6:TABLE ACCESS BY INDEX ROWID GL_PERIODS :(cost=4,rows=4)
              7:INDEX RANGE SCAN GL_PERIODS_U2 :(cost=2,rows=4)
          3:SORT AGGREGATE  :(cost=,rows=1)
           4:TABLE ACCESS BY INDEX ROWID GL_PERIODS :(cost=4,rows=5)
            5:INDEX RANGE SCAN GL_PERIODS_U2 :(cost=2,rows=5)
  	CURSOR get_gl_periods_csr IS
     	SELECT START_DATE, END_DATE, PERIOD_NAME
       	FROM gl_periods gp
      	WHERE gp.period_set_name = l_period_set_name
        AND gp.period_type 	= decode(l_time_phase_code,'G',l_accounted_period_type,'P',l_pa_period_type)
        AND gp.start_date       >=
			(SELECT MIN(start_date)
			FROM gl_periods
			WHERE end_date >= l_start_date
			AND period_set_name = l_period_set_name
			AND period_type =
				decode(l_time_phase_code,'G',
				l_accounted_period_type,
        			'P',l_pa_period_type)
			AND adjustment_period_flag = 'N')
       	AND gp.end_date         <=
			(SELECT MAX(end_date)
			FROM gl_periods
			WHERE start_date <= l_end_date
			AND period_set_name = l_period_set_name
			AND period_type =
				decode(l_time_phase_code,'G',
				l_accounted_period_type,
        			'P',l_pa_period_type)
			AND adjustment_period_flag = 'N')
       	AND gp.adjustment_period_flag = 'N'
      	ORDER BY gp.start_date;
	*****End of Performance fix **/

  BEGIN
	l_stage := 250;
	print_msg('	'||l_stage||' enter get_periods()');

  	x_return_status := FND_API.G_RET_STS_SUCCESS;
	If p_pa_debug_mode = 'Y' Then
		pa_debug.init_err_stack('PA_FP_SPREAD_AMTS_PKG.get_periods');
		pa_debug.set_process('PLSQL', 'LOG', p_pa_debug_mode);
	End If;

	l_stage := 255;
	print_msg('	'||'input parameters:');
	print_msg('	'||'p_start/end_date	=> '||p_start_date||'/'||p_end_date);

	--Validation

	l_stage := 260;
	print_msg('	'||l_stage||' before validate p_start/end_date');
	-- p_start_date must less than p_end_date
	IF p_start_date > p_end_date THEN

		x_return_status := FND_API.G_RET_STS_ERROR;
		x_msg_data := 'PA_FP_START_END_DATE_OVERLAP';
		If p_pa_debug_mode = 'Y' Then
			pa_debug.reset_err_stack;
		End If;
		RETURN;
	END IF;
	l_stage := 270;
	print_msg('	'||l_stage||' after validation');


 	l_period_set_name         := p_period_set_name;
    	l_accounted_period_type   := p_accounted_period_type;
    	l_pa_period_type          := p_pa_period_type;
	l_time_phase_code	  := p_time_phase_code;
	l_stage := 280;
	If p_pa_debug_mode = 'Y' Then
	print_msg('	'||l_stage||' after assign set name,period type,time phase');
	print_msg('	'||'period_set_name		=> '||l_period_set_name);
	print_msg('	'||'accounted_period_type	=> '||l_accounted_period_type);
	print_msg('	'||'pa_period_type		=> '||l_pa_period_type);
	print_msg('	'||'time_phase_code		=> '||l_time_phase_code);
	End If;


    	-- Get periods from gl_periods

	l_start_date := p_start_date;
	l_end_date := p_end_date;
    	x_spread_amounts := spread_table_type();
    	n := 0;
	FOR rec IN get_gl_periods_csr
	LOOP
		--print_msg('inside get_gl_periods_csr for SD['||rec.start_date||']');
		    	n := n + 1;
		    	x_spread_amounts.EXTEND();
		    	tmp_rec.start_date := rec.start_date;
		    	tmp_rec.end_date := rec.end_date;
		    	tmp_rec.period_name := rec.period_name;
		    	tmp_rec.actual_days := 0;
		    	x_spread_amounts(n) := tmp_rec;
        END LOOP;

	IF n = 0 AND (l_time_phase_code = 'G' OR l_time_phase_code = 'P') THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
			x_msg_data := 'PA_FP_PERIODS_IS_NULL';
			If p_pa_debug_mode = 'Y' Then
				pa_debug.reset_err_stack;
			End If;
			RETURN;
	END IF;
	If p_pa_debug_mode = 'Y' Then
		pa_debug.reset_err_stack;
	End If;
	l_stage := 290;
	print_msg('	'||l_stage||' leave get period');

  EXCEPTION

	WHEN OTHERS THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_FP_SPREAD_AMTS_PKG',
					p_procedure_name => 'get_periods');
		If p_pa_debug_mode = 'Y' Then
			pa_debug.reset_err_stack;
		End If;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;

  END get_periods;


PROCEDURE spread_amounts
            ( p_budget_version_id  IN pa_budget_versions.budget_version_id%TYPE
             ,x_return_status      OUT NOCOPY VARCHAR2
             ,x_msg_count          OUT NOCOPY NUMBER
             ,x_msg_data           OUT NOCOPY VARCHAR2) IS

  l_msg_count       NUMBER := 0;
  l_data            VARCHAR2(2000);
  l_msg_data        VARCHAR2(2000);
  l_msg_index_out   NUMBER;
  l_debug_mode	    VARCHAR2(30);

  v_return_status VARCHAR2(3);
  v_msg_count NUMBER;
  v_msg_data VARCHAR2(2000);

  l_stage			INTEGER;

  l_err_msg			VARCHAR2(2000);

  l_project_name      pa_projects_all.name%TYPE;
  l_task_name         pa_proj_elements.name%TYPE;
  l_resource_name     pa_resource_list_members.alias%TYPE;
  l_proj_curr_cd	pa_projects_all.project_currency_code%TYPE;
  l_projfunc_curr_cd	pa_projects_all.projfunc_currency_code%TYPE;

  v_spread_amounts	spread_table_type;
  v_spread_curve 	spread_curve_type;
  v_start_end_date 	start_end_date_table_type;
  v_start_end 		start_end_date_record_type;
  i 			INTEGER;
  bl_exist		BOOLEAN;

  --l_time_phase_code		pa_proj_fp_options.all_time_phased_code%TYPE;
  l_line_start			INTEGER;
  l_line_end			INTEGER;
  l_line_start_date		DATE;
  l_line_end_date		DATE;
  l_plan_start_date		DATE;
  l_plan_end_date		DATE;
  l_budget_line_time_phase_count	INTEGER;
  l_fixed_date			DATE;
  l_fixed_date_period_count	INTEGER;
  l_last_budget_line_id		pa_budget_lines.budget_line_id%TYPE;
  l_spread_curve_id		pa_spread_curves_b.spread_curve_id%TYPE;
  v_budget_line_id		pa_budget_lines.budget_line_id%TYPE;

  v_resource_assignment_id	pa_budget_lines.resource_assignment_id%TYPE;
  v_txn_currency_code		pa_budget_lines.txn_currency_code%TYPE;

  v_total_quantity		pa_budget_lines.quantity%TYPE;
  v_total_raw_cost		pa_budget_lines.raw_cost%TYPE;
  v_total_burdened_cost		pa_budget_lines.burdened_cost%TYPE;
  v_total_revenue		pa_budget_lines.revenue%TYPE;

  l_sum_txn_quantity		pa_budget_lines.quantity%TYPE;
  l_avg_raw_cost_rate		pa_budget_lines.txn_standard_cost_rate%TYPE;
  l_avg_raw_cost_rate_override	pa_budget_lines.txn_cost_rate_override%TYPE;
  l_sum_txn_raw_cost		pa_budget_lines.raw_cost%TYPE;
  l_avg_burden_cost_rate		pa_budget_lines.burden_cost_rate%TYPE;
  l_avg_burden_cost_rate_ovrid	pa_budget_lines.
					burden_cost_rate_override%TYPE;
  l_sum_txn_burdened_cost	pa_budget_lines.burdened_cost%TYPE;
  l_avg_bill_rate		pa_budget_lines.txn_standard_bill_rate%TYPE;
  l_avg_bill_rate_override	pa_budget_lines.txn_bill_rate_override%TYPE;
  l_sum_txn_revenue		pa_budget_lines.revenue%TYPE;

  tmp_quantity			NUMBER;
  tmp_txn_raw_cost		NUMBER;
  tmp_txn_burdened_cost		NUMBER;
  tmp_txn_revenue		NUMBER;

  l_quantity			pa_budget_lines.quantity%TYPE;
  l_txn_raw_cost		pa_budget_lines.raw_cost%TYPE;
  l_txn_burdened_cost		pa_budget_lines.burdened_cost%TYPE;
  l_txn_revenue			pa_budget_lines.revenue%TYPE;

  l_g_start_date		DATE;
  l_g_init_quantity		pa_budget_lines.init_quantity%TYPE;
  l_g_txn_init_raw_cost		pa_budget_lines.txn_init_raw_cost%TYPE;
  l_g_txn_init_burdened_cost	pa_budget_lines.txn_init_burdened_cost%TYPE;
  l_g_txn_init_revenue		pa_budget_lines.txn_init_revenue%TYPE;
  l_g_sum_etc_quantity		pa_budget_lines.init_quantity%TYPE;
  l_g_sum_txn_etc_raw_cost	pa_budget_lines.txn_init_raw_cost%TYPE;
  l_g_sum_txn_etc_burdened_cost pa_budget_lines.txn_init_burdened_cost%TYPE;
  l_g_sum_txn_etc_revenue	pa_budget_lines.txn_init_revenue%TYPE;
  l_g_bl_init_count			INTEGER;

  l_g_bl_count			INTEGER;
  l_g_sum_txn_quantity		pa_budget_lines.quantity%TYPE;
  l_g_sum_txn_raw_cost		pa_budget_lines.txn_raw_cost%TYPE;
  l_g_sum_txn_burdened_cost	pa_budget_lines.txn_burdened_cost%TYPE;
  l_g_sum_txn_revenue		pa_budget_lines.txn_revenue%TYPE;

  l_txn_quantity_addl		pa_fp_res_assignments_tmp.
				TXN_PLAN_QUANTITY%TYPE;
  l_txn_raw_cost_addl		pa_fp_res_assignments_tmp.
				TXN_RAW_COST%TYPE;
  l_txn_burdened_cost_addl	pa_fp_res_assignments_tmp.
				TXN_BURDENED_COST%TYPE;
  l_txn_revenue_addl		pa_fp_res_assignments_tmp.
				TXN_REVENUE%TYPE;

  l_bl_count			INTEGER;
  l_dummy_count			INTEGER;
  l_bl_line_id                  Number;
  l_dummy_bl_id            	Number;

  l_period_set_name		gl_sets_of_books.period_set_name%TYPE;
  l_accounted_period_type	gl_sets_of_books.accounted_period_type%TYPE;
  l_pa_period_type		pa_implementations_all.pa_period_type%TYPE;
  l_time_phase_code		pa_proj_fp_options.cost_time_phased_code%TYPE;

  /* bug fix:5726773 */
  l_neg_qty_er_flag             VARCHAR2(1);

	/* This cursor is used for fixed date spread curve */
  	CURSOR cur_spFixDateBdgtLines IS
	SELECT RESOURCE_ASSIGNMENT_ID,
		START_DATE,
		END_DATE,
		PERIOD_NAME,
		QUANTITY,
		TXN_RAW_COST,
		TXN_BURDENED_COST,
		TXN_REVENUE,
		INIT_QUANTITY,
		TXN_INIT_RAW_COST,
		TXN_INIT_BURDENED_COST,
		TXN_INIT_REVENUE,
		TXN_CURRENCY_CODE,
		BUDGET_LINE_ID,
		BUDGET_VERSION_ID
	FROM PA_BUDGET_LINES
	WHERE RESOURCE_ASSIGNMENT_ID = v_resource_assignment_id
	AND TXN_CURRENCY_CODE = v_txn_currency_code
	AND START_DATE BETWEEN l_line_start_date AND l_line_end_date
	AND END_DATE BETWEEN l_line_start_date AND l_line_end_date
	AND PERIOD_NAME IS NOT NULL
	ORDER BY START_DATE;


	/* This cursor is used for Existing Line Distributioin Method */
        CURSOR cur_ExistBdgtLines(p_resAsgnId  Number
				,p_txn_cur_code Varchar2
				,p_line_start_date Date
				,p_line_end_date   Date ) IS
        SELECT RESOURCE_ASSIGNMENT_ID,
                START_DATE,
                END_DATE,
                PERIOD_NAME,
                QUANTITY,
                TXN_RAW_COST,
                TXN_BURDENED_COST,
                TXN_REVENUE,
                INIT_QUANTITY,
                TXN_INIT_RAW_COST,
                TXN_INIT_BURDENED_COST,
                TXN_INIT_REVENUE,
                TXN_CURRENCY_CODE,
                BUDGET_LINE_ID,
                BUDGET_VERSION_ID
        FROM PA_BUDGET_LINES
        WHERE RESOURCE_ASSIGNMENT_ID = p_resAsgnId
        AND TXN_CURRENCY_CODE = p_txn_cur_code
        AND START_DATE BETWEEN p_line_start_date AND p_line_end_date
        AND END_DATE BETWEEN p_line_start_date AND p_line_end_date
        AND PERIOD_NAME IS NOT NULL
        ORDER BY START_DATE;

	/* This Cursor is used for Non-Time phase budgets */
  	CURSOR budget_line_time_phase_csr IS
	SELECT BUDGET_LINE_ID
	FROM PA_BUDGET_LINES
	WHERE RESOURCE_ASSIGNMENT_ID = v_resource_assignment_id
	AND TXN_CURRENCY_CODE = v_txn_currency_code
	--AND START_DATE = l_plan_start_date 	bug 6339811
	--AND END_DATE = l_plan_end_date 		bug 6339811
	AND PERIOD_NAME IS NULL;

  	budget_line_time_phase_rec	budget_line_time_phase_csr%ROWTYPE;

  	-- notes: for periodic page
  	CURSOR resource_assignment_csr IS
	SELECT RESOURCE_ASSIGNMENT_ID
		,BUDGET_VERSION_ID
		,PROJECT_ID
		,TASK_ID
		,RESOURCE_LIST_MEMBER_ID
		,PLANNING_START_DATE
		,PLANNING_END_DATE
		,SPREAD_CURVE_ID
		,SP_FIXED_DATE
		,TXN_CURRENCY_CODE
		,TXN_CURRENCY_CODE_OVERRIDE
		,PROJECT_CURRENCY_CODE
		,PROJFUNC_CURRENCY_CODE
		,TXN_REVENUE
		,TXN_REVENUE_ADDL
		,TXN_RAW_COST
		,TXN_RAW_COST_ADDL
		,TXN_BURDENED_COST
		,TXN_BURDENED_COST_ADDL
		,TXN_PLAN_QUANTITY
		,TXN_PLAN_QUANTITY_ADDL
		,LINE_START_DATE
		,LINE_END_DATE
		,SOURCE_CONTEXT
		,RAW_COST_RATE
		,RW_COST_RATE_OVERRIDE
		,BURDEN_COST_RATE
		,BURDEN_COST_RATE_OVERRIDE
		,BILL_RATE
		,BILL_RATE_OVERRIDE
		,RATE_BASED_FLAG
		,SPREAD_AMOUNTS_FLAG
		,INIT_QUANTITY
		,TXN_INIT_RAW_COST
		,TXN_INIT_BURDENED_COST
		,TXN_INIT_REVENUE
		/* Bug fix:5726773 : Added the following columns to store the negative quantity/amt change flags*/
 	        ,NVL(NEG_QUANTITY_CHANGE_FLAG,'N')        neg_Qty_Change_flag
 	        ,NVL(NEG_RAWCOST_CHANGE_FLAG,'N')        neg_RawCst_Change_flag
 	        ,NVL(NEG_BURDEN_CHANGE_FALG,'N')        neg_BurdCst_Change_flag
 	        ,NVL(NEG_REVENUE_CHANGE_FLAG,'N')        neg_rev_Change_flag
	FROM PA_FP_RES_ASSIGNMENTS_TMP tmp
	WHERE tmp.BUDGET_VERSION_ID = p_budget_version_id
	AND (NVL(tmp.TXN_PLAN_QUANTITY_ADDL,0) <> 0
	    OR NVL(tmp.TXN_RAW_COST_ADDL,0) <> 0
	    OR NVL(tmp.TXN_BURDENED_COST_ADDL,0) <> 0
	    OR NVL(tmp.TXN_REVENUE_ADDL,0) <> 0
	   );
	/* Now the spread is called in bulk mode
	AND RESOURCE_ASSIGNMENT_ID = p_res_assignment_id
	AND TXN_CURRENCY_CODE = p_txn_currency_code
	AND ((p_line_start_date IS NULL and p_line_end_date IS NULL)
            OR
	     (p_line_start_date IS NOT NULL and p_line_end_date IS NOT NULL
	      and LINE_START_DATE = p_line_start_date
              and LINE_END_DATE = p_line_end_date)
	    );
	*/

  resource_assignment_rec	resource_assignment_rec_type;

  	CURSOR spread_curve_csr IS
	SELECT POINT1,
		POINT2,
		POINT3,
		POINT4,
		POINT5,
		POINT6,
		POINT7,
		POINT8,
		POINT9,
		POINT10,
	SPREAD_CURVE_CODE
	FROM PA_SPREAD_CURVES_B
	WHERE SPREAD_CURVE_ID = l_spread_curve_id;
  	spread_curve_b_rec		spread_curve_csr%ROWTYPE;


  	CURSOR get_line_info (p_resource_assignment_id IN NUMBER) IS
        SELECT ppa.name project_name
               ,pt.name task_name
               ,prl.alias resource_name
        FROM pa_projects_all ppa
               ,pa_proj_elements pt
               ,pa_resource_list_members prl
               ,pa_resource_assignments pra
        WHERE pra.resource_assignment_id = p_resource_assignment_id
        AND ppa.project_id = pra.project_id
        AND pt.proj_element_id(+) = pra.task_id
        AND prl.resource_list_member_id = pra.resource_list_member_id;

	/* performance bug fix: 4100256 */
	CURSOR bl_details(p_resAsgnId   Number
			,p_txn_cur_code Varchar2
			,p_start_date   Date
			,p_end_date     Date
			,p_source_context Varchar2) IS
	SELECT  sum(bl.quantity)
                ,sum(bl.txn_raw_cost)
                ,sum(bl.txn_burdened_cost)
                ,sum(bl.txn_revenue)
		,min(bl.budget_line_id)
                ,decode(min(bl.budget_line_id),NULL,0,1) NumOfBudgetLines
		,sum(NVL(bl.quantity,0)-NVL(bl.init_quantity,0)) Etc_Quantity
       FROM pa_budget_lines bl
       WHERE bl.resource_assignment_id = p_resAsgnId
       AND bl.txn_currency_code = p_txn_cur_code
       AND bl.START_DATE BETWEEN p_start_date AND p_end_date
       AND bl.END_DATE BETWEEN p_start_date AND p_end_date ;

  	SPREAD_AMOUNTS_EXCEPTION 	EXCEPTION;
  	SKIP_EXCEPTION		EXCEPTION;

	l_sprd_exception_count   Number :=0;
	l_sp_fixed_qty   Number;
	l_sp_fixed_cost  Number;
	l_sp_fixed_burden Number;
	l_sp_fixed_revenue Number;
	v_bl_total_quantity Number := 0;
        v_bl_total_raw_cost Number := 0;
        v_bl_total_burdened_cost Number :=0;
        v_bl_total_revenue  Number := 0;

	L_FINAL_RETURN_STATUS  varchar2(10) := 'S';

  BEGIN
	l_stage := 800;
	print_msg(l_stage||' *** ENTERED SPREAD AMOUNTS API***');
  	x_return_status := 'S';
	L_FINAL_RETURN_STATUS := 'S';
	If p_pa_debug_mode = 'Y' Then
		pa_debug.init_err_stack('PA_FP_SPREAD_AMTS_PKG.spread_amounts');
	End If;
	/* Bug fix: 4078623 Both set_curr_fun and Init_err_stack are similar, since reset_curr_function is not called
	 * This might have been causing the plsql numeric or value error. Not sure because of this.  Just to avoid
         * confusions commenting out this call
	 * PA_DEBUG.Set_Curr_Function( p_function   => 'PA_FP_SPREAD_AMTS_PKG.spread_amounts' ,p_debug_mode => 'Y');
	 */

	-- validation
	IF ( p_budget_version_id IS NULL ) THEN
		l_err_msg := 'PA_FP_BUDGET_RES_CURRENCY_NULL';
		RAISE SPREAD_AMOUNTS_EXCEPTION;
	END IF;

	-- get options
	print_msg('Deriving finplan option information for the budget version');
	get_options( p_budget_version_id,
  			l_period_set_name,
  			l_accounted_period_type,
  			l_pa_period_type,
			l_time_phase_code,
			v_return_status,
			v_msg_count,
			v_msg_data);

	l_stage := 805;
	print_msg(l_stage||'after get_options');
	IF v_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_stage := 806;
		print_msg(l_stage||' get_options() err MsgData['||v_msg_data||']');
		l_err_msg := v_msg_data;
		RAISE SPREAD_AMOUNTS_EXCEPTION;

	END IF;

	/* call to initialize the global tables */
        Initialize_spread_plsqlTabs;

	-- For each resource assignment record in global temporary table
	-- based on budget_version_id, resource_assignment_id and
	-- txn currency code
	-- main looooooooooooop starts here
	FOR raRec IN resource_assignment_csr LOOP  --{

	  BEGIN
	       /* set ETC start date from RA */
       		l_g_start_date := PA_FP_CALC_PLAN_PKG.g_spread_from_date;
       		print_msg('ETC l_g_start_date['||l_g_start_date||']l_line_end_date['||l_line_end_date||']');

	    	/* Without changing much of the code, assiging the loop variable values to record*/
		resource_assignment_rec.RESOURCE_ASSIGNMENT_ID  := raRec.RESOURCE_ASSIGNMENT_ID;
                resource_assignment_rec.BUDGET_VERSION_ID     	:= raRec.BUDGET_VERSION_ID;
                resource_assignment_rec.PROJECT_ID             	:= raRec.PROJECT_ID;
                resource_assignment_rec.TASK_ID                 := raRec.TASK_ID;
                resource_assignment_rec.RESOURCE_LIST_MEMBER_ID := raRec.RESOURCE_LIST_MEMBER_ID;
                resource_assignment_rec.PLANNING_START_DATE    	:= raRec.PLANNING_START_DATE;
                resource_assignment_rec.PLANNING_END_DATE       := raRec.PLANNING_END_DATE;
                resource_assignment_rec.SPREAD_CURVE_ID       	:= raRec.SPREAD_CURVE_ID;
                resource_assignment_rec.SP_FIXED_DATE           := raRec.SP_FIXED_DATE;
                resource_assignment_rec.TXN_CURRENCY_CODE     	:= raRec.TXN_CURRENCY_CODE;
		resource_assignment_rec.TXN_CURRENCY_CODE_OVERRIDE := raRec.TXN_CURRENCY_CODE_OVERRIDE;
                resource_assignment_rec.PROJECT_CURRENCY_CODE  	:= raRec.PROJECT_CURRENCY_CODE;
                resource_assignment_rec.PROJFUNC_CURRENCY_CODE  := raRec.PROJFUNC_CURRENCY_CODE;
                resource_assignment_rec.TXN_REVENUE            	:= raRec.TXN_REVENUE;
                resource_assignment_rec.TXN_REVENUE_ADDL        := raRec.TXN_REVENUE_ADDL;
                resource_assignment_rec.TXN_RAW_COST            := raRec.TXN_RAW_COST;
                resource_assignment_rec.TXN_RAW_COST_ADDL       := raRec.TXN_RAW_COST_ADDL;
                resource_assignment_rec.TXN_BURDENED_COST       := raRec.TXN_BURDENED_COST;
                resource_assignment_rec.TXN_BURDENED_COST_ADDL  := raRec.TXN_BURDENED_COST_ADDL;
                resource_assignment_rec.TXN_PLAN_QUANTITY       := raRec.TXN_PLAN_QUANTITY;
                resource_assignment_rec.TXN_PLAN_QUANTITY_ADDL  := raRec.TXN_PLAN_QUANTITY_ADDL;
                resource_assignment_rec.LINE_START_DATE         := raRec.LINE_START_DATE;
                resource_assignment_rec.LINE_END_DATE          	:= raRec.LINE_END_DATE;
                resource_assignment_rec.SOURCE_CONTEXT         	:= raRec.SOURCE_CONTEXT;
                resource_assignment_rec.RAW_COST_RATE        	:= raRec.RAW_COST_RATE;
                resource_assignment_rec.RAW_COST_RATE_OVERRIDE  := raRec.RW_COST_RATE_OVERRIDE;
                resource_assignment_rec.BURDEN_COST_RATE        := raRec.BURDEN_COST_RATE;
                resource_assignment_rec.BURDEN_COST_RATE_OVERRIDE  := raRec.BURDEN_COST_RATE_OVERRIDE;
                resource_assignment_rec.BILL_RATE              	:= raRec.BILL_RATE;
                resource_assignment_rec.BILL_RATE_OVERRIDE    	:= raRec.BILL_RATE_OVERRIDE;
                resource_assignment_rec.RATE_BASED_FLAG      	:= raRec.RATE_BASED_FLAG;
                resource_assignment_rec.SPREAD_AMOUNTS_FLAG 	:= raRec.SPREAD_AMOUNTS_FLAG;
                resource_assignment_rec.INIT_QUANTITY      	:= raRec.INIT_QUANTITY;
                resource_assignment_rec.TXN_INIT_RAW_COST       := raRec.TXN_INIT_RAW_COST;
                resource_assignment_rec.TXN_INIT_BURDENED_COST  := raRec.TXN_INIT_BURDENED_COST;
                resource_assignment_rec.TXN_INIT_REVENUE  	:= raRec.TXN_INIT_REVENUE;

	    -- Get resource assignment id and txn currency code
	    v_resource_assignment_id := resource_assignment_rec.RESOURCE_ASSIGNMENT_ID;
	    v_txn_currency_code      := resource_assignment_rec.TXN_CURRENCY_CODE;
	    G_rate_based_flag        := NVL(resource_assignment_rec.RATE_BASED_FLAG,'N');
	    G_Curr_code              := NVL(resource_assignment_rec.TXN_CURRENCY_CODE_OVERRIDE,resource_assignment_rec.TXN_CURRENCY_CODE);
	    l_proj_curr_cd	     := resource_assignment_rec.PROJECT_CURRENCY_CODE;
            l_projfunc_curr_cd	     := resource_assignment_rec.PROJFUNC_CURRENCY_CODE;

            /* Bug fix:4030310  if etc start date is less than line start date the set the etc date as null */
            IF l_g_start_date IS NOT NULL AND trunc(l_g_start_date) < trunc(resource_assignment_rec.PLANNING_START_DATE)THEN
                l_stage := 810.1;
                print_msg(l_stage||'set though date to null because earlier than plan start_date');
                l_g_start_date := NULL;
            END IF;

	    l_stage := 820;
	    If p_pa_debug_mode = 'Y' Then
	    print_msg(l_stage||' input data:');
	    print_msg('ra_resource_assignment_id	=> '||resource_assignment_rec.resource_assignment_id);
	    print_msg('ra_BUDGET_VERSION_ID		=> '||resource_assignment_rec.BUDGET_VERSION_ID);
	    print_msg('ra_PLANNING_START/END_DATE	=> '||resource_assignment_rec.PLANNING_START_DATE||'/'||resource_assignment_rec.PLANNING_END_DATE);
	    print_msg('ra_SPREAD_CURVE_ID/FIXED_DATE	=> '||resource_assignment_rec.SPREAD_CURVE_ID||'/'||resource_assignment_rec.SP_FIXED_DATE);
	    print_msg('ra_TXN_CURRENCY_CODE/OVERRIDE	=> '||resource_assignment_rec.TXN_CURRENCY_CODE||'/'||resource_assignment_rec.TXN_CURRENCY_CODE_OVERRIDE);
	    print_msg('ra_TXN_REVENUE/ADDL		=> '||resource_assignment_rec.TXN_REVENUE||'/'||resource_assignment_rec.TXN_REVENUE_ADDL);
	    print_msg('ra_TXN_RAW_COST/ADDL		=> '||resource_assignment_rec.TXN_RAW_COST||'/'||resource_assignment_rec.TXN_RAW_COST_ADDL);
	    print_msg('ra_TXN_BURDENED_COST/ADDL	=> '||resource_assignment_rec.TXN_BURDENED_COST||'/'||resource_assignment_rec.TXN_BURDENED_COST_ADDL);
	    print_msg('ra_TXN_PLAN_QUANTITY/ADDL	=> '||resource_assignment_rec.TXN_PLAN_QUANTITY||'/'||resource_assignment_rec.TXN_PLAN_QUANTITY_ADDL);
	    print_msg('ra_SOURCE_CONTEXT		=> '||resource_assignment_rec.SOURCE_CONTEXT);
	    print_msg('ra_LINE_START/END_DATE		=> '||resource_assignment_rec.LINE_START_DATE||'/'||resource_assignment_rec.LINE_END_DATE);
	    print_msg('ra_RAW_COST_RATE/OVERRIDE	=> '||resource_assignment_rec.RAW_COST_RATE||'/'||resource_assignment_rec.RAW_COST_RATE_OVERRIDE);
	    print_msg('ra_BURDEN_COST_RATE/OVERRIDE	=> '||resource_assignment_rec.BURDEN_COST_RATE||'/'||resource_assignment_rec.BURDEN_COST_RATE_OVERRIDE);
	    print_msg('ra_BILL_RATE/OVERRIDE		=> '||resource_assignment_rec.BILL_RATE||'/'||resource_assignment_rec.BILL_RATE_OVERRIDE);
	    print_msg('ra_RATE_BASED_FLAG		=> '||G_rate_based_flag);
	    print_msg('ra_SPREAD_AMOUNTS_FLAG		=> '||resource_assignment_rec.SPREAD_AMOUNTS_FLAG);
	    print_msg('neg_Qty_Change_flag              => '||raRec.neg_Qty_Change_flag);
	    End If;

	    /*** Bug fix:4194475 execute only when there is error so moved to exception block
	    l_stage := 821;
	    print_msg(l_stage||' get project_name, task_name and resource_name');
            OPEN get_line_info(v_resource_assignment_id);
            FETCH get_line_info
	    INTO l_project_name
		, l_task_name
		, l_resource_name;
            CLOSE get_line_info;
	    ****/

	    -- validate resource assignment record
	    IF ( resource_assignment_rec.PLANNING_START_DATE IS NULL OR
		resource_assignment_rec.PLANNING_END_DATE IS NULL)  OR
		( resource_assignment_rec.PLANNING_START_DATE >
		resource_assignment_rec.PLANNING_END_DATE ) OR
		(resource_assignment_rec.SOURCE_CONTEXT = 'BUDGET_LINE' AND
		((resource_assignment_rec.LINE_START_DATE IS NULL OR
		resource_assignment_rec.LINE_END_DATE IS NULL)  OR
		(resource_assignment_rec.LINE_START_DATE >
		resource_assignment_rec.LINE_END_DATE
		))) THEN

			IF resource_assignment_rec.SOURCE_CONTEXT = 'BUDGET_LINE' THEN
				l_line_start_date := resource_assignment_rec.LINE_START_DATE;
				l_line_end_date := resource_assignment_rec.LINE_END_DATE;
			ELSE
				l_line_start_date := resource_assignment_rec.PLANNING_START_DATE;
				l_line_end_date := resource_assignment_rec.PLANNING_END_DATE;
			END IF;

			l_err_msg := 'PA_FP_PLAN_START_END_DATE_ERR';
			RAISE SPREAD_AMOUNTS_EXCEPTION;

	    END IF;


	    -- skip record when all the amouns are null

	    IF ( resource_assignment_rec.TXN_PLAN_QUANTITY_ADDL IS NULL 	AND
	        resource_assignment_rec.TXN_RAW_COST_ADDL IS NULL 	AND
	       	resource_assignment_rec.TXN_BURDENED_COST_ADDL IS NULL 	AND
	       	resource_assignment_rec.TXN_REVENUE_ADDL IS NULL ) THEN
		l_stage := 841;
		print_msg(l_stage||' all amounts are null, skip the resource assignment');
		RAISE SKIP_EXCEPTION;
	    END IF;



	    -- Note: 1. if plan start/end date shift, all budget lines beyond
	    --		the new plan state/end date will be
	    --		deleted before calling spread_amounts()
	    --       2. if budget line(s) is(are) there, it's not allowed to
	    --		change the time phase code - from N/R to G/P or from G/P
	    --		to N/R or from G to P or from P to G etc.
	    --	     3. line_start/end_date must at begin/end of period

		l_stage := 860;
		print_msg('Deriving period information for the budget version');
	    	get_periods(
		    	NVL(l_g_start_date,resource_assignment_rec.PLANNING_START_DATE),
		    	resource_assignment_rec.PLANNING_END_DATE,
  			l_period_set_name,
  			l_accounted_period_type,
  			l_pa_period_type,
			l_time_phase_code,
			v_spread_amounts,
			v_return_status,
			v_msg_count,
			v_msg_data);
	   	print_msg(l_stage||' after get periods retSts['||v_return_status||']v_spread_amounts.coount['||v_spread_amounts.COUNT||']');
	    	IF v_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			l_err_msg := v_msg_data;
			RAISE SPREAD_AMOUNTS_EXCEPTION;
	   	END IF;

		IF p_pa_debug_mode = 'Y' Then
           	   IF ( v_spread_amounts.COUNT > 0
               	     AND l_time_phase_code IN  ('P','G')) THEN

	       		FOR i IN v_spread_amounts.first.. v_spread_amounts.last LOOP
		   		IF (i = v_spread_amounts.first OR i = v_spread_amounts.last) THEN
                   			NULL;
	    	   			print_msg('start/end date '||i||'=> '||v_spread_amounts(i).start_date||'/'||v_spread_amounts(i).end_date);
		   		END IF;
	       		END LOOP;
            	   END IF;
		END IF;

	    -- updated 030204 Sgoteti
            IF  l_time_phase_code IN  ('P','G')
		AND resource_assignment_rec.SOURCE_CONTEXT = 'BUDGET_LINE'
		AND ((resource_assignment_rec.LINE_END_DATE <
                	v_spread_amounts(1).start_date )
		     OR
                	( v_spread_amounts(v_spread_amounts.COUNT()).end_date <
                	   resource_assignment_rec.LINE_START_DATE)) THEN

                	l_stage := 863;
                	print_msg(l_stage||' line start/end date miss the planning period, skip the resource assignment');
			RAISE SKIP_EXCEPTION;
	    END IF;

            /* Initialize line start and line end date with planning SD and ED*/
            l_line_start_date := NVL(l_g_start_date,resource_assignment_rec.PLANNING_START_DATE);
            l_line_end_date := resource_assignment_rec.PLANNING_END_DATE;

	    -- updated 030204 Sgoteti
            IF l_time_phase_code IN  ('P','G')  THEN
                l_line_start_date := v_spread_amounts(1).start_date;
                l_line_end_date := v_spread_amounts(v_spread_amounts.count()).end_date;

                IF resource_assignment_rec.SOURCE_CONTEXT = 'BUDGET_LINE' THEN
                    IF resource_assignment_rec.LINE_START_DATE > l_line_start_date THEN
                        -- resource_assignment_rec.PLANNING_START_DATE THEN
                            l_line_start_date := resource_assignment_rec.LINE_START_DATE;
                    END IF;
                    IF resource_assignment_rec.LINE_END_DATE < l_line_end_date THEN
                        -- resource_assignment_rec.PLANNING_END_DATE THEN
                            l_line_end_date := resource_assignment_rec.LINE_END_DATE;
                    END IF;
                END IF;

	    -- updated 030204 Sgoteti
            END IF;

            l_stage := 845;
            print_msg(l_stage||' after get line start/end date '||l_line_start_date||'/'||l_line_end_date);

	    /* Get budget line amounts for the given resource */
	    BEGIN
	    	l_stage := 520;
	    	print_msg(l_stage||' before get sum of amounts from budget line');
		/* Initialize the budget line varaibles */
		l_sum_txn_quantity  := NULL;
                l_sum_txn_raw_cost  := NULL;
                l_sum_txn_burdened_cost  := NULL;
                l_sum_txn_revenue  := NULL;
		l_bl_line_id       := NULL;
                l_bl_count := 0;
		OPEN bl_details(v_resource_assignment_id
                        ,v_txn_currency_code
                        ,l_line_start_date
                        ,l_line_end_date
			,resource_assignment_rec.SOURCE_CONTEXT) ;
		FETCH bl_details INTO
			l_sum_txn_quantity
			,l_sum_txn_raw_cost
			,l_sum_txn_burdened_cost
			,l_sum_txn_revenue
			,l_bl_line_id
			,l_bl_count
			,l_g_sum_etc_quantity;
		CLOSE bl_details;
		/* set the linecount variable to zero if its null or the cursor not found */
		IF l_bl_count is NULL Then
			l_bl_count := 0;
		End If;
		print_msg(l_stage||'l_bl_count['||l_bl_count||']');


	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
			null;
	    END;
	    l_stage := 530;
	    If p_pa_debug_mode = 'Y' Then
	    print_msg(l_stage||' Before spread Amts from Budget Line l_time_phase_code '||l_time_phase_code);
	    print_msg(' l_sum_txn_quantity '||l_sum_txn_quantity||']l_sum_txn_raw_cost['||l_sum_txn_raw_cost||']');
	    print_msg(' l_sum_txn_burdened_cost['||l_sum_txn_burdened_cost||']l_sum_txn_revenue['||l_sum_txn_revenue||']');
	    End If;

	    l_stage := 880;
	    -- when time phase code is R or N
	    IF (l_time_phase_code = 'R' OR l_time_phase_code = 'N') THEN

		l_stage := 890;
	    	print_msg(l_stage||' enter time phase is R or N');
		/* Bug fixL: 3877889 For Non-Timephase budgets PlanSDate should be considiered
                 -- l_plan_start_date := NVL(l_g_start_date,resource_assignment_rec.PLANNING_START_DATE);
		*/
		l_plan_start_date := resource_assignment_rec.PLANNING_START_DATE;
		l_plan_end_date := resource_assignment_rec.PLANNING_END_DATE;
		budget_line_time_phase_rec := NULL;
		OPEN budget_line_time_phase_csr;
		FETCH budget_line_time_phase_csr
			INTO budget_line_time_phase_rec;
			l_budget_line_time_phase_count := budget_line_time_phase_csr%ROWCOUNT;
		CLOSE budget_line_time_phase_csr;
		print_msg('l_budget_line_time_phase_count['||l_budget_line_time_phase_count||']');

		       IF l_budget_line_time_phase_count = 0 THEN
				--print_msg('Inserting records into budget line for l_budget_line_time_phase_count = 0');
				-- Insert into PA_BUDGET_LINES,
				insert_budget_line(
				v_resource_assignment_id,
				resource_assignment_rec.PLANNING_START_DATE,
				resource_assignment_rec.PLANNING_END_DATE,
				NULL,
				resource_assignment_rec.TXN_CURRENCY_CODE,
				resource_assignment_rec.TXN_CURRENCY_CODE_OVERRIDE,
				v_budget_line_id,
				p_budget_version_id,
				l_proj_curr_cd,
				l_projfunc_curr_cd,
				v_return_status,
				v_msg_count,
				v_msg_data);

				IF v_return_status <> 'S' Then
					l_err_msg := v_msg_data;
					RAISE SPREAD_AMOUNTS_EXCEPTION;
				END IF;

				--print_msg('Inserting records into rollup tmp for l_budget_line_time_phase_count = 0');
				insert_rollup_tmp(
				resource_assignment_rec,
				p_budget_version_id,
				resource_assignment_rec.PLANNING_START_DATE,
				resource_assignment_rec.PLANNING_END_DATE,
				NULL,
				v_budget_line_id,
				resource_assignment_rec.TXN_PLAN_QUANTITY,
				resource_assignment_rec.TXN_RAW_COST,
				resource_assignment_rec.TXN_BURDENED_COST,
				resource_assignment_rec.TXN_REVENUE,
				v_return_status,
				v_msg_count,
				v_msg_data);

				IF v_return_status <> 'S' Then
					l_err_msg := v_msg_data;
					RAISE SPREAD_AMOUNTS_EXCEPTION;
				END IF;

			ELSIF l_budget_line_time_phase_count = 1 THEN
				--print_msg('Inserting records into rollup tmp for l_budget_line_time_phase_count = 1');
				-- Insert Rollup Temporary Table
				insert_rollup_tmp_with_bl(
				resource_assignment_rec,
				p_budget_version_id,
				resource_assignment_rec.PLANNING_START_DATE,
				resource_assignment_rec.PLANNING_END_DATE,
				NULL,
				budget_line_time_phase_rec.budget_line_id,
				resource_assignment_rec.TXN_PLAN_QUANTITY,
				resource_assignment_rec.TXN_RAW_COST,
				resource_assignment_rec.TXN_BURDENED_COST,
				resource_assignment_rec.TXN_REVENUE,
				v_return_status,
				v_msg_count,
				v_msg_data);

				IF v_return_status <> 'S' Then
					l_err_msg := v_msg_data;
					RAISE SPREAD_AMOUNTS_EXCEPTION;
				END IF;
			ELSE
				l_err_msg := 'FA_FP_MULTI_NON_PERIOD';
				RAISE SPREAD_AMOUNTS_EXCEPTION;
			END IF;

	    ELSE -- time phase code is not R or N
		    l_stage := 850;
	    	    print_msg(l_stage||' Entered time phase code is G or P');
            	    -- get spread curve
            	    l_spread_curve_id := resource_assignment_rec.SPREAD_CURVE_ID;
		    spread_curve_b_rec := NULL;
            	    OPEN spread_curve_csr;
            	    FETCH spread_curve_csr
			INTO spread_curve_b_rec;
	    	    	IF spread_curve_csr%ROWCOUNT = 1 THEN
                   	     v_spread_curve := spread_curve_type(
                        	    spread_curve_b_rec.POINT1,
                        	    spread_curve_b_rec.POINT2,
                        	    spread_curve_b_rec.POINT3,
                        	    spread_curve_b_rec.POINT4,
                        	    spread_curve_b_rec.POINT5,
                        	    spread_curve_b_rec.POINT6,
                        	    spread_curve_b_rec.POINT7,
                        	    spread_curve_b_rec.POINT8,
                        	    spread_curve_b_rec.POINT9,
                        	    spread_curve_b_rec.POINT10);
            	    	ELSE
                   	         v_spread_curve := spread_curve_type
                        	    (10, 10, 10, 10, 10, 10, 10, 10, 10, 10);
            	    	END IF;
            	    CLOSE spread_curve_csr;
                    l_stage := 850;
		    If p_pa_debug_mode = 'Y' Then
   	            print_msg(l_stage||' after get spread curve');
	            print_msg('	'||'spread curve	=> '||v_spread_curve(1)||' '||v_spread_curve(2)||' '||v_spread_curve(3));
            	    print_msg('      '||v_spread_curve(4)||' '||v_spread_curve(5)||' '||v_spread_curve(6)||' '||v_spread_curve(7));
            	    print_msg('      '||v_spread_curve(8)||' '||v_spread_curve(9)||' '||v_spread_curve(10));
		    End If;

		    IF ( l_g_start_date IS NOT NULL
			 AND ( l_g_start_date > l_line_end_date ))THEN
			-- v_spread_amounts(v_spread_amounts.COUNT).end_date
			IF l_g_start_date > resource_assignment_rec.PLANNING_END_DATE THEN
				l_stage := 910;
				print_msg(l_stage||'enter though date after plan end date');
				print_msg(l_stage||'ETC start date is greater than planning end date');
				BEGIN
					bl_exist := TRUE;
					i := v_spread_amounts.COUNT;
					l_quantity  := NULL;
                                        l_txn_raw_cost := NULL;
                                        l_txn_burdened_cost := NULL;
                                        l_txn_revenue := NULL;
                                        v_budget_line_id := NULL;
                                        l_dummy_count := 0;
					OPEN bl_details(v_resource_assignment_id
                        				,v_txn_currency_code
                        				,v_spread_amounts(i).start_date
                        				,v_spread_amounts(i).end_date
							,resource_assignment_rec.SOURCE_CONTEXT);
                			FETCH bl_details INTO
                        			l_quantity
                        			,l_txn_raw_cost
                        			,l_txn_burdened_cost
                        			,l_txn_revenue
                        			,v_budget_line_id
                        			,l_dummy_count
						,l_g_sum_etc_quantity;
                			CLOSE bl_details;
                			/* set the linecount variable to zero if its null or the cursor not found */
                			IF l_dummy_count is NULL Then
                        			l_dummy_count := 0;
                			End If;
					If l_dummy_count = 0 Then
						bl_exist := FALSE;
					End If;

				EXCEPTION
					WHEN NO_DATA_FOUND THEN
						bl_exist := FALSE;
				END;

				IF bl_exist = FALSE THEN
				  print_msg('Budget line not exists');
				  IF (( resource_assignment_rec.TXN_PLAN_QUANTITY_ADDL IS NOT NULL
				       AND resource_assignment_rec.TXN_PLAN_QUANTITY_ADDL <> 0 )
				     OR ( resource_assignment_rec.TXN_RAW_COST_ADDL IS NOT NULL
					AND resource_assignment_rec.TXN_RAW_COST_ADDL <> 0)
				     OR (resource_assignment_rec.TXN_BURDENED_COST_ADDL IS NOT NULL
					AND resource_assignment_rec.TXN_BURDENED_COST_ADDL <> 0)
				     OR (resource_assignment_rec.TXN_REVENUE_ADDL IS NOT NULL
					AND resource_assignment_rec.TXN_REVENUE_ADDL <> 0))  THEN

				  	insert_budget_line(
				  	v_resource_assignment_id,
				  	v_spread_amounts(v_spread_amounts.COUNT).start_date,
				  	v_spread_amounts(v_spread_amounts.COUNT).end_date,
				  	v_spread_amounts(v_spread_amounts.COUNT).period_name,
				  	v_txn_currency_code,
					resource_assignment_rec.TXN_CURRENCY_CODE_OVERRIDE,
				  	v_budget_line_id,
				  	p_budget_version_id,
					l_proj_curr_cd,
					l_projfunc_curr_cd,
				  	v_return_status,
				  	v_msg_count,
				  	v_msg_data);

				  	IF v_return_status <> 'S' Then
					    l_err_msg := v_msg_data;
					    RAISE SPREAD_AMOUNTS_EXCEPTION;
				  	END IF;

				  	l_stage := 1004;
				  	-- print_msg(l_stage||' after insert budget line');
				  	-- Insert into Rollup Temporary Table
				  	insert_rollup_tmp(
				  	resource_assignment_rec,
					p_budget_version_id,
				  	v_spread_amounts(v_spread_amounts.COUNT).start_date,
				  	v_spread_amounts(v_spread_amounts.COUNT).end_date,
				  	v_spread_amounts(v_spread_amounts.COUNT).period_name,
				  	v_budget_line_id,
				  	resource_assignment_rec.TXN_PLAN_QUANTITY_ADDL,
				  	resource_assignment_rec.TXN_RAW_COST_ADDL,
				  	resource_assignment_rec.TXN_BURDENED_COST_ADDL,
				  	resource_assignment_rec.TXN_REVENUE_ADDL,
				  	v_return_status,
				  	v_msg_count,
				  	v_msg_data);

				  	IF v_return_status <> 'S' Then
					    l_err_msg := v_msg_data;
					    RAISE SPREAD_AMOUNTS_EXCEPTION;
				  	END IF;
				  END IF;

				ELSE -- budget line exists

				  insert_rollup_tmp_with_bl(
				  resource_assignment_rec,
				  p_budget_version_id,
				  v_spread_amounts(v_spread_amounts.COUNT).start_date,
				  v_spread_amounts(v_spread_amounts.COUNT).end_date,
				  v_spread_amounts(v_spread_amounts.COUNT).period_name,
				  v_budget_line_id,
				  nvl(l_quantity,0) + resource_assignment_rec.TXN_PLAN_QUANTITY_ADDL,
				  nvl(l_txn_raw_cost,0) + resource_assignment_rec.TXN_RAW_COST_ADDL,
				  nvl(l_txn_burdened_cost,0) + resource_assignment_rec.TXN_BURDENED_COST_ADDL,
				  nvl(l_txn_revenue,0) + resource_assignment_rec.TXN_REVENUE_ADDL,
				  v_return_status,
				  v_msg_count,
				  v_msg_data);

                                        IF v_return_status <> 'S' Then
                                            l_err_msg := v_msg_data;
                                            RAISE SPREAD_AMOUNTS_EXCEPTION;
                                        END IF;
				END IF;
			END IF;
			RAISE SKIP_EXCEPTION;
		    END IF;  -- end of etc start date is greater than planning end date

		    /* if etc start date is less than line start date the set the etc date as null */
		    IF l_g_start_date IS NOT NULL AND l_g_start_date < l_line_start_date THEN
			l_stage := 920;
			print_msg(l_stage||'set though date to null because earlier than line start_date');
			l_g_start_date := NULL;
		    END IF;

		    IF l_g_start_date IS NOT NULL THEN
		    	    FOR i IN 1 .. v_spread_amounts.COUNT  LOOP
				IF (( i > 1)
				   AND l_g_start_date > v_spread_amounts(i - 1).end_date
				   AND l_g_start_date < v_spread_amounts(i).start_date)  THEN
					l_g_start_date := v_spread_amounts(i).start_date;
					l_stage := 930;
					print_msg(l_stage||'set though date to begin of next period because fall between periods '||l_g_start_date);
				END IF;
		    		IF l_g_start_date BETWEEN v_spread_amounts(i).start_date
		    			AND v_spread_amounts(i).end_date THEN
		    			l_line_start_date := v_spread_amounts(i).start_date;
					l_stage := 940;
					print_msg(l_stage||' set line start date to begin of period though date falls '||l_line_start_date);
		    		END IF;
		    	    END LOOP;
		    END IF;

		    IF l_g_start_date IS NOT NULL THEN
			/* get budget line amounts for the period */
			l_g_sum_txn_quantity := NULL;
			l_g_sum_txn_raw_cost := NULL;
			l_g_sum_txn_burdened_cost := NULL;
			l_g_sum_txn_revenue := NULL;
			l_dummy_bl_id := NULL;
			l_g_bl_count := 0;
			OPEN bl_details(v_resource_assignment_id
                                        ,v_txn_currency_code
                                        ,l_line_start_date
                                        ,l_line_end_date
					,resource_assignment_rec.SOURCE_CONTEXT);
                        FETCH bl_details INTO
                              l_g_sum_txn_quantity
                             ,l_g_sum_txn_raw_cost
                             ,l_g_sum_txn_burdened_cost
                             ,l_g_sum_txn_revenue
                             ,l_dummy_bl_id
                             ,l_g_bl_count
			     ,l_g_sum_etc_quantity;
                        CLOSE bl_details;
			If l_g_bl_count is NULL Then
				l_g_bl_count := 0;
			End If;
			l_stage := 950;
			print_msg(l_stage||' get sum of amounts from though date to line end date l_g_bl_count '||l_g_bl_count);

		    END IF;

		    l_txn_quantity_addl := resource_assignment_rec.TXN_PLAN_QUANTITY_ADDL;
		    l_txn_raw_cost_addl := resource_assignment_rec.TXN_RAW_COST_ADDL;
		    l_txn_burdened_cost_addl := resource_assignment_rec.TXN_BURDENED_COST_ADDL;
		    l_txn_revenue_addl := resource_assignment_rec.TXN_REVENUE_ADDL;
		   print_msg('960l_txn_quantity_addl['||l_txn_quantity_addl||']l_txn_raw_cost_addl['||l_txn_raw_cost_addl||']');
		   print_msg('l_txn_burdened_cost_addl['||l_txn_burdened_cost_addl||']l_txn_revenue_addl['||l_txn_revenue_addl||']');

		    IF l_g_start_date IS NOT NULL THEN
				print_msg('setting the l_sum variables');
				l_sum_txn_quantity := l_g_sum_Etc_quantity;
				l_sum_txn_raw_cost := l_g_sum_txn_raw_cost ;
				l_sum_txn_burdened_cost := l_g_sum_txn_burdened_cost;
				l_sum_txn_revenue := l_g_sum_txn_revenue;
		    END IF;
		    l_stage := 970;
		    If p_pa_debug_mode = 'Y' Then
		    print_msg(l_stage||' get amounts addl plus etc');
		    print_msg('l_txn_quantity_addl '||l_txn_quantity_addl||']l_txn_raw_cost_addl['||l_txn_raw_cost_addl||']');
		    print_msg('l_txn_burdened_cost_addl '||l_txn_burdened_cost_addl||']l_txn_revenue_addl['||l_txn_revenue_addl||']');
		    print_msg('l_sum_txn_quantity['||l_sum_txn_quantity||']l_sum_txn_raw_cost['||l_sum_txn_raw_cost||']');
		    End If;

		    -- When spread curve's SPREAD_CURVE_CODE
		    -- is not FIXED
		    IF NOT (spread_curve_b_rec.SPREAD_CURVE_CODE IS NOT NULL
			AND spread_curve_b_rec.SPREAD_CURVE_CODE = 'FIXED_DATE') THEN
		      l_stage := 980;
		      print_msg(l_stage||' Entered spread curve code is NOT Fixed date');

		      l_stage := 1025;
		      print_msg(l_stage||' sum of budget lines minus etc');

		      /* bug fix:5726773 : negative quantity spread
 	                        * when budget lines exists and sum of total quantity is zero then
 	                        * distributing the quantity based on existing line distribution method fails with
 	                        * divide by zero error. In order to avoid this spread the quantity based on the
 	                        * spread curve. This is proposed by PMs
 	                        */
 	                       l_neg_qty_er_flag := 'N';
 	                       If l_bl_count <> 0
 	                         AND l_txn_quantity_addl <> 0
 	                         AND ((l_sum_txn_quantity = 0 and l_g_start_date IS NULL)
 	                              OR (l_g_sum_txn_quantity = 0  and l_g_start_date IS NOT NULL)
 	                              OR (l_g_bl_count = 0 and l_g_sum_Etc_quantity = 0
 	                                 and l_g_sum_txn_quantity <> 0 and l_g_start_date IS NOT NULL)) Then
 	                                  l_neg_qty_er_flag := 'Y';
 	                       End If;

		      -- if need call spread()
		      IF ( l_bl_count = 0
			  OR (l_g_start_date IS NOT NULL AND l_g_bl_count = 0)
			  OR (resource_assignment_rec.SPREAD_AMOUNTS_FLAG = 'Y')
 	                  OR l_neg_qty_er_flag = 'Y' ) THEN /* bug fix:5726773 */

			l_stage := 990;
			print_msg(l_stage||' enter spread or respread');
			-- set start/end date
			v_start_end_date := start_end_date_table_type();
			v_start_end.start_date := NVL(l_g_start_date,resource_assignment_rec.PLANNING_START_DATE);
			v_start_end.end_date := resource_assignment_rec.PLANNING_END_DATE;
			v_start_end_date.EXTEND();
			v_start_end_date(1) := v_start_end;

			-- set line start/end period
			FOR i IN 1 .. v_spread_amounts.COUNT() LOOP
				IF l_line_start_date BETWEEN v_spread_amounts(i).start_date
					        AND v_spread_amounts(i).end_date THEN
					l_line_start := i;
				END IF;
				IF l_line_end_date BETWEEN v_spread_amounts(i).start_date
						AND v_spread_amounts(i).end_date THEN
					l_line_end := i;
				END IF;
			END LOOP;

		     -- change to support fiscal calendar distribution. call proc srepad if spread_code <> "FISCAL CALENDAR" otherwise call spread_day_level
                       IF spread_curve_b_rec.SPREAD_CURVE_CODE <> 'FISCAL_CALENDAR' THEN
			/* Calling Spread api to calculate the amounts,qty and burdened cost to spread across periods*/
			print_msg('CALLING SPREAD api');
			spread(4,
				l_txn_quantity_addl,
				l_txn_raw_cost_addl,
				l_txn_burdened_cost_addl,
				l_txn_revenue_addl,
				0,
				0,
				0,
				0,
				0,
				0,
				v_start_end_date,
				v_spread_curve,
				l_line_start,
				l_line_end,
				l_g_start_date,
				v_spread_amounts,
				v_return_status,
				v_msg_count,
				v_msg_data);

		     ELSE
 	         --Spread As Daily Level Distribution
 	       /* Calling Spread api to calculate the amounts,qty and burdened cost to spread across periods by day level*/


 	         spread_day_level(4,
 	                                 l_txn_quantity_addl,
 	                                 l_txn_raw_cost_addl,
 	                                 l_txn_burdened_cost_addl,
 	                                 l_txn_revenue_addl,
 	                                 0,
 	                                 0,
 	                                 0,
 	                                 0,
 	                                 0,
 	                                 0,
 	                                 v_start_end_date,
 	                                 l_line_start,
 	                                 l_line_end,
 	                                 l_g_start_date,
 	                                 v_spread_amounts,
 	                                 v_return_status,
 	                                 v_msg_count,
 	                                 v_msg_data);

 	         END IF;

			IF v_return_status <> 'S' Then
				l_err_msg := v_msg_data;
				RAISE SPREAD_AMOUNTS_EXCEPTION;
			END IF;

			l_stage := 1000;
			If p_pa_debug_mode = 'Y' Then
			  print_msg(l_stage||' after call spread()');
			  FOR i IN 1 .. v_spread_amounts.COUNT() LOOP
			    IF i = l_line_start OR i = l_line_end THEN
                            NULL;
			    print_msg('start/end date '||i||'=> '||v_spread_amounts(i).start_date||'/'||v_spread_amounts(i).end_date);
			    print_msg('txn quantity '||i||'=> '||v_spread_amounts(i).amount1);
			    print_msg('txn raw cost '||i||'=> '||v_spread_amounts(i).amount2);
			    print_msg('txn burdened cost '||i||'=> '||v_spread_amounts(i).amount3);
			    print_msg('txn revenue '||i||'=> '||v_spread_amounts(i).amount4);
			    END IF;
			  END LOOP;
			End If;


			l_stage := 1001;
			print_msg(l_stage||' before update loop');
			FOR i IN l_line_start .. l_line_end LOOP

				bl_exist := TRUE;

				BEGIN
				  	l_quantity  := NULL;
                                        l_txn_raw_cost := NULL;
                                        l_txn_burdened_cost := NULL;
                                        l_txn_revenue := NULL;
                                        v_budget_line_id := NULL;
                                        l_dummy_count := 0;
                                        OPEN bl_details(v_resource_assignment_id
                                                        ,v_txn_currency_code
                                                        ,v_spread_amounts(i).start_date
                                                        ,v_spread_amounts(i).end_date
							,resource_assignment_rec.SOURCE_CONTEXT);
                                        FETCH bl_details INTO
                                                l_quantity
                                                ,l_txn_raw_cost
                                                ,l_txn_burdened_cost
                                                ,l_txn_revenue
                                                ,v_budget_line_id
                                                ,l_dummy_count
						,l_g_sum_etc_quantity;
                                        CLOSE bl_details;
                                        /* set the linecount variable to zero if its null or the cursor not found */
                                        IF l_dummy_count is NULL Then
                                                l_dummy_count := 0;
                                        End If;
                                        If l_dummy_count = 0 Then
                                                bl_exist := FALSE;
                                        End If;

				EXCEPTION
				  WHEN NO_DATA_FOUND THEN
					bl_exist := FALSE;
				END;


				IF NOT bl_exist THEN

				  l_stage := 1003;
				   --print_msg(l_stage||' enter budget line id not found ');

				  IF v_spread_amounts(i).amount1 IS NOT NULL AND
				  v_spread_amounts(i).amount1 <> 0 OR
				  v_spread_amounts(i).amount2 IS NOT NULL AND
				  v_spread_amounts(i).amount2 <> 0 OR
				  v_spread_amounts(i).amount3 IS NOT NULL AND
				  v_spread_amounts(i).amount3 <> 0 OR
				  v_spread_amounts(i).amount4 IS NOT NULL AND
				  v_spread_amounts(i).amount4 <> 0 THEN

				  -- Insert into PA_BUDGET_LINES,

				  insert_budget_line(
				  v_resource_assignment_id,
				  v_spread_amounts(i).start_date,
				  v_spread_amounts(i).end_date,
				  v_spread_amounts(i).period_name,
				  v_txn_currency_code,
				  resource_assignment_rec.TXN_CURRENCY_CODE_OVERRIDE,
				  v_budget_line_id,
				  p_budget_version_id,
				  l_proj_curr_cd,
				  l_projfunc_curr_cd,
				  v_return_status,
				  v_msg_count,
				  v_msg_data);

				  IF v_return_status <>
					FND_API.G_RET_STS_SUCCESS THEN
					l_err_msg := v_msg_data;
					RAISE SPREAD_AMOUNTS_EXCEPTION;

				  END IF;

				  l_stage := 1004;
				  -- print_msg(l_stage||' after insert budget line');

				  -- Insert into Rollup Temporary Table

				  insert_rollup_tmp(
				  resource_assignment_rec,
				  p_budget_version_id,
				  v_spread_amounts(i).start_date,
				  v_spread_amounts(i).end_date,
				  v_spread_amounts(i).period_name,
				  v_budget_line_id,
				  v_spread_amounts(i).amount1,
				  v_spread_amounts(i).amount2,
				  v_spread_amounts(i).amount3,
				  v_spread_amounts(i).amount4,
				  v_return_status,
				  v_msg_count,
				  v_msg_data);

				  IF v_return_status <>
					FND_API.G_RET_STS_SUCCESS THEN
					l_err_msg := v_msg_data;
					RAISE SPREAD_AMOUNTS_EXCEPTION;

				  END IF;

				  l_stage := 1005;
				  -- print_msg(l_stage||' after insert rollup tmp');
				  END IF; -- all amounts 0 or null

				ELSE -- found one budget line

				  l_stage := 1006;
				  --print_msg(l_stage||' enter budget line id found');
                                        If l_txn_quantity_addl is NOT NULL Then
						If l_neg_qty_er_flag = 'Y' Then        /* bug fix:5726773 */
 	                                                 l_quantity := v_spread_amounts(i).amount1;
 	                                        Else
                                                l_quantity := nvl(l_quantity, 0) + v_spread_amounts(i).amount1;
						End If;
                                        Else
                                                l_quantity := nvl(l_quantity,0) ;
                                        End If;

                                        If l_txn_raw_cost_addl is NOT NULL Then
                                                l_txn_raw_cost := nvl(l_txn_raw_cost, 0) + v_spread_amounts(i).amount2;
                                        Else
                                                l_txn_raw_cost := nvl(l_txn_raw_cost,0) ;
                                        End If;

                                        If l_txn_burdened_cost_addl is NOT NULL Then
                                                l_txn_burdened_cost := nvl(l_txn_burdened_cost, 0)+ v_spread_amounts(i).amount3;
                                        Else
                                                l_txn_burdened_cost := nvl(l_txn_burdened_cost,0) ;
                                        End If;

                                        If l_txn_revenue_addl is NOT NULL Then
                                                l_txn_revenue := nvl(l_txn_revenue, 0) + v_spread_amounts(i).amount4;
                                        Else
                                                l_txn_revenue := nvl(l_txn_revenue,0) ;
                                        End If;

				  insert_rollup_tmp_with_bl(
				  resource_assignment_rec,
				  p_budget_version_id,
				  v_spread_amounts(i).start_date,
				  v_spread_amounts(i).end_date,
				  v_spread_amounts(i).period_name,
				  v_budget_line_id,
				  l_quantity,
				  l_txn_raw_cost,
				  l_txn_burdened_cost,
				  l_txn_revenue,
				  v_return_status,
				  v_msg_count,
				  v_msg_data);

				  IF v_return_status <>
					FND_API.G_RET_STS_SUCCESS THEN

					l_err_msg := v_msg_data;
					RAISE SPREAD_AMOUNTS_EXCEPTION;

				  END IF;
				  l_stage := 1007;
				  -- print_msg(l_stage||' after update rollup tmp');
				  -- END IF; -- all amounts 0
				END IF;
			END LOOP;
			l_stage := 1010;
			print_msg(l_stage||' after update db');



		      ELSE -- spread based on existing distribution

			l_stage := 1020;
			print_msg(l_stage||' enter spread based on existing distribution');

			v_total_quantity := 0;
			v_total_raw_cost := 0;
			v_total_burdened_cost := 0;
			v_total_revenue := 0;
			tmp_quantity := 0;
			tmp_txn_raw_cost :=0;
			tmp_txn_burdened_cost :=0;
			tmp_txn_revenue := 0;

			FOR budget_line_rec IN cur_ExistBdgtLines( v_resource_assignment_id
                                        			,v_txn_currency_code
                                        			,l_line_start_date
                                        			,l_line_end_date ) LOOP

				--print_msg('inside loop For each record in PA_BUDGET_LINES');
			   	-- get Budget Line ID and amounts
			   	-- update amounts based on existing distribution


				l_last_budget_line_id := budget_line_rec.budget_line_id;

                                print_msg('sumtxnqty['||l_sum_txn_quantity||'LnQty['||budget_line_rec.QUANTITY||']LnInit['||budget_line_rec.INIT_QUANTITY||']');
				IF l_sum_txn_quantity IS NOT NULL AND
					l_sum_txn_quantity <> 0 THEN

					/* bug fix:5726773 */
 	                                      If raRec.neg_Qty_Change_flag = 'Y' Then
 	                                         tmp_quantity := nvl(budget_line_rec.QUANTITY,0);
 	                                      Else

				  	IF l_txn_quantity_addl is NOT NULL Then
                                                tmp_quantity :=
                                                    (nvl(l_txn_quantity_addl,0) * ((nvl(budget_line_rec.QUANTITY,0)- nvl(budget_line_rec.INIT_QUANTITY,0)) /
											l_sum_txn_quantity));
						tmp_quantity := Round_Qty_Amts(G_rate_based_flag,'Y',G_curr_code,tmp_quantity);
                                        Else
                                                tmp_quantity := 0;
                                        End If;
					tmp_quantity := tmp_quantity + nvl(budget_line_rec.QUANTITY,0);
					tmp_quantity := Round_Qty_Amts(G_rate_based_flag,'Y',G_curr_code,tmp_quantity);
                                  	--print_msg(' tmp_quantity => '||to_char(tmp_quantity));
                                  	--print_msg(' v_total_quantity => '||to_char(v_total_quantity));
					End If;
				END IF;

				IF l_sum_txn_raw_cost IS NOT NULL AND
					l_sum_txn_raw_cost <> 0 THEN

					If l_txn_raw_cost_addl is NOT NULL Then
                                               tmp_txn_raw_cost :=
                                                 (nvl(l_txn_raw_cost_addl,0) * nvl(budget_line_rec.TXN_RAW_COST,0) / nvl(l_sum_txn_raw_cost,0));
					       tmp_txn_raw_cost := Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,tmp_txn_raw_cost);
                                        Else
                                                tmp_txn_raw_cost := 0;
                                        End If;
                                        tmp_txn_raw_cost := tmp_txn_raw_cost + nvl(budget_line_rec.TXN_RAW_COST,0);
					tmp_txn_raw_cost := Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,tmp_txn_raw_cost);

				END IF;

				IF l_sum_txn_burdened_cost IS NOT NULL AND
					l_sum_txn_burdened_cost <> 0 THEN

				        If l_txn_burdened_cost_addl is NOT NULL Then
                                                tmp_txn_burdened_cost := (nvl(l_txn_burdened_cost_addl,0) *
                                                	(nvl(budget_line_rec.TXN_BURDENED_COST,0) / nvl(l_sum_txn_burdened_cost,0)));
						tmp_txn_burdened_cost := Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,tmp_txn_burdened_cost);
                                        Else
                                                tmp_txn_burdened_cost := 0;
                                        End if;
                                        tmp_txn_burdened_cost := tmp_txn_burdened_cost + nvl(budget_line_rec.TXN_BURDENED_COST,0);
					tmp_txn_burdened_cost := Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,tmp_txn_burdened_cost);
				END IF;

				IF l_sum_txn_revenue IS NOT NULL AND
					l_sum_txn_revenue <> 0 THEN

					If l_txn_revenue_addl is NOT NULL Then
                                                tmp_txn_revenue := (nvl(l_txn_revenue_addl,0) *
                                                	(nvl(budget_line_rec.TXN_REVENUE,0) / nvl(l_sum_txn_revenue,0)));
						tmp_txn_revenue := Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,tmp_txn_revenue);
                                        Else
                                                tmp_txn_revenue := 0;
                                        End if;
                                        tmp_txn_revenue := tmp_txn_revenue + nvl(budget_line_rec.TXN_REVENUE,0);
					tmp_txn_revenue := Round_Qty_Amts(G_rate_based_flag,'N',G_curr_code,tmp_txn_revenue);
				END IF;

				/*
                                print_msg(' Before insert into insert_rollup_tmp_with_bl');
                                print_msg(' tmp_quantity => '||to_char(tmp_quantity)||']tmp_txn_raw_cost['||tmp_txn_raw_cost||']');
                                print_msg('tmp_txn_burdened_cost => '||tmp_txn_burdened_cost||']tmp_txn_revenue['||tmp_txn_revenue||']');
				*/
				-- Insert into rollup tmp table
				insert_rollup_tmp_with_bl(
				resource_assignment_rec,
				p_budget_version_id,
				budget_line_rec.start_date,
				budget_line_rec.end_date,
				budget_line_rec.period_name,
				budget_line_rec.budget_line_id,
				tmp_quantity,
				tmp_txn_raw_cost,
				tmp_txn_burdened_cost,
				tmp_txn_revenue,
				v_return_status,
				v_msg_count,
				v_msg_data);

				IF v_return_status <> 'S' Then
					l_err_msg := v_msg_data;
					RAISE SPREAD_AMOUNTS_EXCEPTION;
				END IF;

			END LOOP; -- existing amounts, for each budget line
			print_msg('End of Existing line distribution Loop');

			If l_last_budget_line_id is NOT NULL Then  --{
                           print_msg(' Adding last budget line id to plsql tab of PA_FP_ROLLUP_TMP with l_last_budget_line_id');
			   /* getting the totals from budgetline to add final difference */
			    g_edist_blId(NVL(g_edist_blId.LAST,0)+1) := l_last_budget_line_id;
			    g_edist_RaId(NVL(g_edist_RaId.LAST,0)+1) := v_resource_assignment_id;
			    g_edist_Curcode(NVL(g_edist_Curcode.LAST,0)+1) := v_txn_currency_code;
			    g_edist_Curcode_ovr(NVL(g_edist_Curcode_ovr.LAST,0)+1) := resource_assignment_rec.txn_currency_code_override;
			    g_edist_sdate(NVL(g_edist_sdate.LAST,0)+1) := l_line_start_date;
			    g_edist_edate(NVL(g_edist_edate.LAST,0)+1) := l_line_end_date;
			    g_edist_etc_sdate(NVL(g_edist_etc_sdate.LAST,0)+1) := l_g_start_date;
                            g_edist_source_context(NVL(g_edist_source_context.LAST,0)+1) := resource_assignment_rec.source_context;
                            g_edist_line_start_date(NVL(g_edist_line_start_date.LAST,0)+1) := resource_assignment_rec.LINE_START_DATE;
                            g_edist_txn_quantity_addl(NVL(g_edist_txn_quantity_addl.LAST,0)+1) := resource_assignment_rec.TXN_PLAN_QUANTITY_ADDL;
                            g_edist_txn_plan_quantity(NVL(g_edist_txn_plan_quantity.LAST,0)+1) := resource_assignment_rec.TXN_PLAN_QUANTITY;
		       End If; --}

		      END IF; -- call spread()?
		    ELSE -- fixed date

			l_stage := 1040;
			print_msg(l_stage||' enter fixed date');


            	    	-- when SP_FIXED_DATE is NULL,
            	    	-- take LINE_START_DATE or PLAN_START_DATE
            	    	-- also when SP_FIX_DATE is not NULL
			-- and not within LINE START/END
            	    	-- or PLAN START/END DATE, report error.

                	IF resource_assignment_rec.SP_FIXED_DATE IS NOT NULL THEN

                    	    l_fixed_date := resource_assignment_rec.SP_FIXED_DATE;
                    	    IF NOT l_fixed_date BETWEEN l_line_start_date AND l_line_end_date THEN
		      	    	l_err_msg := 'PA_FP_FIXED_DATE_NOT_MATCH';
		      	    	RAISE SPREAD_AMOUNTS_EXCEPTION;
                    	    END IF;
                	ELSE
                    	    l_fixed_date := l_line_start_date;
                	END IF;
			l_stage := 1041;
			print_msg(l_stage||' l_fixed_date '||l_fixed_date);

			-- find fixed date period in budget lines
			l_fixed_date_period_count := 0;
			FOR budget_line_rec IN cur_spFixDateBdgtLines LOOP

			    IF l_fixed_date BETWEEN budget_line_rec.START_DATE AND budget_line_rec.END_DATE THEN

				l_stage := 1042;
				print_msg(l_stage||' enter found fixed date period');

				l_fixed_date_period_count := l_fixed_date_period_count + 1;

				-- Insert Rollup Temporary Table
				IF l_g_start_date IS NOT NULL AND
					(budget_line_rec.init_quantity IS NOT NULL OR
					budget_line_rec.txn_init_raw_cost IS NOT NULL OR
					budget_line_rec.txn_init_burdened_cost IS NOT NULL OR
					budget_line_rec.txn_init_revenue IS NOT NULL) THEN

					l_stage := 1043;
					print_msg(l_stage||' enter found fixed date period with init');

					If l_txn_quantity_addl is NOT NULL Then
					   l_sp_fixed_qty :=   (nvl(budget_line_rec.quantity,0) + nvl(l_txn_quantity_addl,0));
					Else
					   l_sp_fixed_qty := nvl(budget_line_rec.quantity,0);
					End If;
					If l_txn_raw_cost_addl is NOT NULL Then
        				   l_sp_fixed_cost := (nvl(budget_line_rec.txn_raw_cost,0) + nvl(l_txn_raw_cost_addl,0));
					Else
					   l_sp_fixed_cost := nvl(budget_line_rec.txn_raw_cost,0);
					End If;
					If l_txn_burdened_cost_addl is NOT NULL Then
        			           l_sp_fixed_burden := (nvl(budget_line_rec.txn_burdened_cost,0) + nvl(l_txn_burdened_cost_addl,0));
					Else
					   l_sp_fixed_burden := nvl(budget_line_rec.txn_burdened_cost,0);
					End If;
					If l_txn_revenue_addl is NOT NULL Then
        			           l_sp_fixed_revenue := (nvl(budget_line_rec.txn_revenue,0) + nvl(l_txn_revenue_addl,0));
					Else
					   l_sp_fixed_revenue := nvl(budget_line_rec.txn_revenue,0);
					End If;

				    insert_rollup_tmp_with_bl(
				    resource_assignment_rec,
				    p_budget_version_id,
				    budget_line_rec.start_date,
				    budget_line_rec.end_date,
				    budget_line_rec.period_name,
				    budget_line_rec.budget_line_id,
				    l_sp_fixed_qty,
				    l_sp_fixed_cost,
				    l_sp_fixed_burden,
				    l_sp_fixed_revenue,
				    v_return_status,
				    v_msg_count,
				    v_msg_data);

				    IF v_return_status <>
					FND_API.G_RET_STS_SUCCESS THEN
					l_err_msg := v_msg_data;
					RAISE SPREAD_AMOUNTS_EXCEPTION;

				    END IF;

				ELSE
				    l_stage := 1044;
				    print_msg(l_stage||' enter found fixed date period without init');


				    insert_rollup_tmp_with_bl(
				    resource_assignment_rec,
				    p_budget_version_id,
				    budget_line_rec.start_date,
				    budget_line_rec.end_date,
				    budget_line_rec.period_name,
				    budget_line_rec.budget_line_id,
				   (nvl(budget_line_rec.quantity,0) + nvl(l_txn_quantity_addl,0)),
				   (nvl(budget_line_rec.txn_raw_cost,0) + nvl(l_txn_raw_cost_addl,0)),
				   (nvl(budget_line_rec.txn_burdened_cost,0) + nvl(l_txn_burdened_cost_addl,0)),
				   (nvl(budget_line_rec.txn_revenue,0) + nvl(l_txn_revenue_addl,0)),
				    v_return_status,
				    v_msg_count,
				    v_msg_data);

				    IF v_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					l_err_msg := v_msg_data;
					RAISE SPREAD_AMOUNTS_EXCEPTION;

				    END IF;

				END IF;
			    ELSE -- fixed date not in period
				l_stage := 1045;
				print_msg(l_stage||' enter found non fixed date period');
				IF l_g_start_date IS NOT NULL AND
					(budget_line_rec.init_quantity IS NOT NULL OR
					budget_line_rec.txn_init_raw_cost IS NOT NULL OR
					budget_line_rec.txn_init_burdened_cost IS NOT NULL OR
					budget_line_rec.txn_init_revenue IS NOT NULL) THEN

					l_stage := 1046;
					print_msg(l_stage||' enter found non fixed date period with init');
				    	insert_rollup_tmp_with_bl(
				    	resource_assignment_rec,
					p_budget_version_id,
				    	budget_line_rec.start_date,
				    	budget_line_rec.end_date,
				    	budget_line_rec.period_name,
				    	budget_line_rec.budget_line_id,
				    	budget_line_rec.init_quantity,
				    	budget_line_rec.txn_init_raw_cost,
				    	budget_line_rec.txn_init_burdened_cost,
				    	budget_line_rec.txn_init_revenue,
				    	v_return_status,
				    	v_msg_count,
				    	v_msg_data);

				    	IF v_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					    l_err_msg := v_msg_data;
					    RAISE SPREAD_AMOUNTS_EXCEPTION;

				    	END IF;
				ELSE
					l_stage := 1047;
					print_msg(l_stage||' enter found non fixed date period when g_start_date is null');
					print_msg('	  or g_start_date is not null but no init, and return err');
					l_err_msg := 'PA_FP_FIXED_DATE_NOT_CLEAR';
					RAISE SPREAD_AMOUNTS_EXCEPTION;
				END IF;
			    END IF;

			END LOOP;

			IF l_fixed_date_period_count = 0 THEN
				l_stage := 1048;
				print_msg(l_stage||' enter no fixed date period found');
				i := 1;
				LOOP
					EXIT WHEN i >
					v_spread_amounts.COUNT OR
					l_fixed_date BETWEEN
					v_spread_amounts(i).start_date
					AND
					v_spread_amounts(i).end_date;
					i := i + 1;
				END LOOP;

				IF i > v_spread_amounts.COUNT() THEN

					l_err_msg := 'PA_FP_FIXED_DATE_NOT_MATCH';
					RAISE SPREAD_AMOUNTS_EXCEPTION;

				END IF;
				l_stage := 1049;
				print_msg(l_stage||' after get fixed date period ');
				print_msg('	 '||v_spread_amounts(i).start_date||'/'||v_spread_amounts(i).end_date);

				-- Insert into PA_BUDGET_LINES,

				insert_budget_line(
				v_resource_assignment_id,
				v_spread_amounts(i).start_date,
				v_spread_amounts(i).end_date,
				v_spread_amounts(i).period_name,
				resource_assignment_rec.TXN_CURRENCY_CODE,
				resource_assignment_rec.TXN_CURRENCY_CODE_OVERRIDE,
				v_budget_line_id,
				p_budget_version_id,
				l_proj_curr_cd,
				l_projfunc_curr_cd,
				v_return_status,
				v_msg_count,
				v_msg_data);

				IF v_return_status <>
					FND_API.G_RET_STS_SUCCESS THEN
					l_err_msg := v_msg_data;
					RAISE SPREAD_AMOUNTS_EXCEPTION;

				END IF;


				-- Insert into Rollup Temporary Table
				-- INSERT INTO PA_FP_ROLLUP_TMP
				insert_rollup_tmp(
				resource_assignment_rec,
				p_budget_version_id,
				v_spread_amounts(i).start_date,
				v_spread_amounts(i).end_date,
				v_spread_amounts(i).period_name,
				v_budget_line_id,
				l_txn_quantity_addl,
				l_txn_raw_cost_addl,
				l_txn_burdened_cost_addl,
				l_txn_revenue_addl,
				v_return_status,
				v_msg_count,
				v_msg_data);

				IF v_return_status <>
					FND_API.G_RET_STS_SUCCESS THEN
					l_err_msg := v_msg_data;
					RAISE SPREAD_AMOUNTS_EXCEPTION;

				END IF;

			END IF;
			l_stage := 1050;
			print_msg(l_stage||' after update db ');

		    END IF; -- fixed date or not

	    END IF; -- whether time phase code is R or N

	  EXCEPTION
		WHEN SKIP_EXCEPTION THEN
			NULL;

		WHEN SPREAD_AMOUNTS_EXCEPTION THEN
			/* bug fix:4194475 open the cursor only when error msg needs to populated */
			print_msg(l_stage||' get project_name, task_name and resource_name');
            		OPEN get_line_info(v_resource_assignment_id);
            		FETCH get_line_info
            		INTO l_project_name
                	   , l_task_name
                	   , l_resource_name;
            	        CLOSE get_line_info;

			l_sprd_exception_count := l_sprd_exception_count + 1;
			L_FINAL_RETURN_STATUS := 'E';
                        IF l_err_msg = 'PA_FP_BUDGET_RES_CURRENCY_NULL' THEN
                                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => l_err_msg
                                );
                        ELSE
                                /* bug fix: 3762278 passing the incorrect msg tokens */
                                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA'
                                ,p_msg_name      => l_err_msg
                                ,p_token1         => 'L_PROJECT_NAME'
                                ,p_value1         => l_project_name
                                ,p_token2         => 'L_TASK_NAME'
                                ,p_value2         => l_task_name
                                ,p_token3         => 'L_RESOURCE_NAME'
                                ,p_value3         => l_resource_name
                                ,p_token4         => 'L_LINE_START_DATE'
                                ,p_value4         => l_line_start_date
                                ,p_token5        => 'L_LINE_END_DATE'
                                ,p_value5        => l_line_end_date);
                        END IF;
	  END;


	END LOOP; --} for each resource assignment

	/* Now Bulk insert all the budget lines */
	print_msg('Bulk update/Insert of budget and rollup tmp lines');
        blkInsertBudgetLines(x_return_status => L_FINAL_RETURN_STATUS);
	blkInsertFpLines(x_return_status     => L_FINAL_RETURN_STATUS);
	blkInsertBlFpLines(x_return_status   => L_FINAL_RETURN_STATUS);

	IF NVL(L_FINAL_RETURN_STATUS,'S') = 'S' Then
		/* update the last rollup tmp line with rounding difference amount */
		IF g_edist_blId.COUNT > 0 THEN
		   print_msg('Calling Process_Rounding_Diff API');
		   Process_Rounding_Diff(p_budget_version_id => p_budget_version_id
					,x_return_status     => L_FINAL_RETURN_STATUS
					);
		   print_msg('RetSts of Process_Rounding_Diff API['||L_FINAL_RETURN_STATUS||']');
		   IF NVL(L_FINAL_RETURN_STATUS,'S') <> 'S' Then
		      x_return_status := L_FINAL_RETURN_STATUS;
		   End IF;
		END IF;
	ELSIF NVL(L_FINAL_RETURN_STATUS,'S') <> 'S' Then
		print_msg('Error occured during the spread, set the return status to E');
		x_return_status := L_FINAL_RETURN_STATUS;
	END IF;

		If p_pa_debug_mode = 'Y' Then
       		    FOR i IN  ( SELECT  tmp.resource_assignment_id resAgnId
				    ,tmp.txn_currency_code	Currency
			            ,sum(tmp.quantity) tmpqty
       				    ,sum(tmp.txn_raw_cost) tmprawcost
       				    ,sum(tmp.txn_burdened_cost) tmpburdencost
       				    ,sum(tmp.txn_revenue) tmprevenue
				    ,sum(tmp.init_quantity) initQty
				    ,sum(tmp.txn_init_raw_cost) initraw
                                    ,sum(tmp.txn_init_burdened_cost) initbud
				    ,sum(tmp.txn_init_revenue) initrev
				    ,count(*) numrows
			    FROM pa_fp_rollup_tmp tmp
			    WHERE tmp.budget_version_id = p_budget_version_id
                            AND   NVL(tmp.system_reference5,'N') = 'N'
			    GROUP BY tmp.resource_assignment_id,tmp.txn_currency_code ) LOOP
			print_msg('Number of Records in rolluptmp after Spread['||i.numrows||']');
			print_msg('tmpRes['||i.resAgnId||']Cur['||i.Currency||']tmpqty['||i.tmpqty||']tmpRaw['||i.tmprawcost||']tmpbd['||i.tmpburdencost||']');
			print_msg('tmprev['||i.tmprevenue||']initQty['||i.initQty||']initRaw['||i.initraw||']initbud['||i.initbud||']initrev['||i.initrev||']');
		   END LOOP;
		End If;
	l_stage := 1060;
	print_msg(l_stage||' **********leave spread_amounts() with retSts['||x_return_status||']');

	/* Reset the error stack */
	If p_pa_debug_mode = 'Y' Then
		pa_debug.reset_err_stack;
	End If;

  EXCEPTION

	WHEN SPREAD_AMOUNTS_EXCEPTION THEN

			x_return_status := FND_API.G_RET_STS_ERROR;
			L_FINAL_RETURN_STATUS := 'E';
			/* bug fix:4194475 open the cursor only when error msg needs to populated */
                        print_msg(l_stage||' get project_name, task_name and resource_name');
                        OPEN get_line_info(v_resource_assignment_id);
                        FETCH get_line_info
                        INTO l_project_name
                           , l_task_name
                           , l_resource_name;
                        CLOSE get_line_info;
			IF l_err_msg = 'PA_FP_BUDGET_RES_CURRENCY_NULL' THEN
				PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
				p_msg_name 	 => l_err_msg
				);
			ELSE
				/* bug fix: 3762278 passing the incorrect msg tokens */
				PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA'
				,p_msg_name 	 => l_err_msg
                        	,p_token1         => 'L_PROJECT_NAME'
                        	,p_value1         => l_project_name
                        	,p_token2         => 'L_TASK_NAME'
                        	,p_value2         => l_task_name
                        	,p_token3         => 'L_RESOURCE_NAME'
                        	,p_value3         => l_resource_name
                        	,p_token4         => 'L_LINE_START_DATE'
                        	,p_value4         => l_line_start_date
				,p_token5	 => 'L_LINE_END_DATE'
				,p_value5	 => l_line_end_date);
			END IF;

                        x_msg_count := fnd_msg_pub.count_msg;
                        /* BUG FIX 3632873 Retrive the msg from stack */
                        print_msg('Retrive the msg from stack MsgCt['||x_msg_count||']');
                        If x_msg_count = 1 then
                                  pa_interface_utils_pub.get_messages
                                  ( p_encoded       => FND_API.G_TRUE
                                   ,p_msg_index     => 1
                                   ,p_data          => x_msg_data
                                   ,p_msg_index_out => l_msg_index_out
                                  );
                                   x_return_status := 'E';
                        Elsif x_msg_count > 1 then
                                   x_return_status := 'E';
                                   x_msg_count := x_msg_count;
                                   x_msg_data := null;
                        End if;
			print_msg('Final ReturnSts['||x_return_status||
				']msgCt['||x_msg_count||']msgData['||x_msg_data||']');
			If p_pa_debug_mode = 'Y' Then
				pa_debug.reset_err_stack;
			End If;
                        RETURN;


	WHEN OTHERS THEN

		print_msg('Encountered Unexpected error from Spread API['||SQLCODE||SQLERRM);
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		L_FINAL_RETURN_STATUS := 'U';
		FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_FP_SPREAD_AMTS_PKG',
					p_procedure_name => 'spread_amounts');
		If p_pa_debug_mode = 'Y' Then
			pa_debug.reset_err_stack;
		End If;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;

  END spread_amounts;


END PA_FP_SPREAD_AMTS_PKG;

/
