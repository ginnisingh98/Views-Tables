--------------------------------------------------------
--  DDL for Package Body PA_FP_CALC_PLAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_CALC_PLAN_PKG" AS
--$Header: PAFPCALB.pls 120.25.12010000.10 2009/06/15 10:16:34 gboomina ship $

  g_module_name VARCHAR2(100) := 'pa.plsql.PA_FP_CALC_PLAN_PKG';
  P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

  skip_record EXCEPTION;
  g_stage                            Varchar2(1000);
  g_rowcount                         NUMBER;
  g_budget_version_id                pa_resource_assignments.budget_version_id%TYPE;
  g_project_currency_code            Varchar2(30);
  g_projfunc_currency_code           Varchar2(30);
  g_fp_budget_version_type           pa_budget_versions.version_type%TYPE;
  g_project_id                       pa_resource_assignments.project_id%TYPE;
  g_task_id                          pa_resource_assignments.task_id%TYPE;
  g_time_phased_code                 VARCHAR2(100) := null;
  g_resource_list_member_id          pa_resource_assignments.resource_list_member_id%TYPE;
  g_bv_resource_list_id              pa_budget_versions.resource_list_id%TYPE;
  g_resource_id                      NUMBER := to_number(null);
  g_bv_approved_rev_flag             pa_budget_versions.approved_rev_plan_type_flag%TYPE;
  g_fp_multi_curr_enabled            pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
  g_project_name                     pa_projects_all.name%TYPE;
  g_task_name                        pa_proj_elements.name%TYPE;
  g_resource_name                    pa_resource_list_members.alias%TYPE;
  g_spread_required_flag             VARCHAR2(1) := 'N';
  g_rollup_required_flag             VARCHAR2(1) := 'Y';
  g_wp_version_flag                  pa_budget_versions.wp_version_flag%TYPE;
  g_proj_structure_ver_id            NUMBER;
  g_ra_bl_txn_currency_code          pa_budget_lines.txn_currency_code%TYPE := NULL;
  g_line_start_date                  pa_fp_res_assignments_tmp.line_start_date%TYPE;
  g_line_end_date                    pa_fp_res_assignments_tmp.line_end_date%TYPE;
  g_source_context                   pa_fp_res_assignments_tmp.source_context%TYPE;
  g_clientExtn_api_call_flag         VARCHAR2(1) :=  'Y' ;
  g_session_time                     VARCHAR2(30);
  g_owner_name               Varchar2(100);
  g_Plan_Class_Type                 VARCHAR2(100);
    G_AGR_CONV_REQD_FLAG        VARCHAR2(30) := 'N';
    G_AGR_CURRENCY_CODE         VARCHAR2(30);
    --G_APPLY_PROGRESS_FLAG         VARCHAR2(30) := 'N';
    G_TRACK_WP_COSTS_FLAG           VARCHAR2(30) := 'Y';
    G_refresh_conv_rates_flag       VARCHAR2(30) := 'N';
        G_refresh_rates_flag            VARCHAR2(30) := 'N';
        G_mass_adjust_flag              VARCHAR2(30) := 'N';
    G_MRC_installed_flag            VARCHAR2(30) := 'N';
    G_revenue_generation_method     VARCHAR2(30) := NULL;
    G_proj_rev_rate_type        VARCHAR2(100):= NULL;
        G_proj_rev_exchange_rate    NUMBER       := NULL;
    G_CiId              NUMBER       := NULL;
    G_baseline_funding_flag         VARCHAR2(10) := 'N';
    G_calling_module            VARCHAR2(100);
    G_conv_rates_required_flag      VARCHAR2(10) := 'Y';
    G_fp_cols_rec          PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
    --G_populate_mrc_tab_flag         VARCHAR2(10) := 'N';
    G_call_raTxn_rollup_flag		VARCHAR2(10) := 'Y';

g_ipm_ra_id_tab                    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
g_ipm_curr_code_tab                SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
g_ipm_cost_rate_ovr_tab            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
g_ipm_bill_rate_ovr_tab            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
g_ipm_burden_rate_ovr_tab          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

    /* Billabliity and MRC Enhancements: Note declaring table of records cannot be used in Bulk updates / bulk inserts
     * so 9.2.5.0 version donot support the builk-in-bind of table of records with indexes
     * so commenting it out for time being
    TYPE mrc_fpRec IS RECORD  (
        budget_line_id      pa_fp_rollup_tmp.budget_line_id%type
        ,resource_assignment_id pa_fp_rollup_tmp.resource_assignment_id%type
        ,txn_currency_code      pa_fp_rollup_tmp.txn_currency_code%type
        ,start_date     pa_fp_rollup_tmp.start_date%type
            ,end_date       pa_fp_rollup_tmp.start_date%type
            ,period_name        pa_fp_rollup_tmp.period_name%type
            ,quantity       Number
            ,txn_raw_cost       Number
            ,txn_burdened_cost  Number
            ,txn_revenue        Number
            ,project_currency_code  pa_fp_rollup_tmp.txn_currency_code%type
            ,project_raw_cost   Number
            ,project_burden_cost    Number
            ,project_revenue        Number
            ,projfunc_currency_code pa_fp_rollup_tmp.txn_currency_code%type
            ,projfunc_raw_cost      Number
            ,projfunc_burden_cost   Number
            ,projfunc_revenue       Number
        ,delete_flag            pa_fp_rollup_tmp.delete_flag%type
        ,Billable_flag          pa_fp_rollup_tmp.delete_flag%type
        ,project_cost_rate_type        pa_fp_rollup_tmp.project_cost_rate_type%type
            ,project_cost_exchange_rate    pa_fp_rollup_tmp.project_cost_exchange_rate%type
        ,project_cost_rate_date_type   pa_fp_rollup_tmp.project_cost_rate_date_type%type
            ,project_cost_rate_date     pa_fp_rollup_tmp.project_cost_rate_date%type
            ,project_rev_rate_type      pa_fp_rollup_tmp.project_rev_rate_type%type
            ,project_rev_exchange_rate  pa_fp_rollup_tmp.project_rev_exchange_rate%type
            ,project_rev_rate_date_type pa_fp_rollup_tmp.project_rev_rate_date_type%type
            ,project_rev_rate_date      pa_fp_rollup_tmp.project_rev_rate_date%type
            ,projfunc_cost_rate_type    pa_fp_rollup_tmp.projfunc_cost_rate_type%type
            ,projfunc_cost_exchange_rate    pa_fp_rollup_tmp.projfunc_cost_exchange_rate%type
            ,projfunc_cost_rate_date_type   pa_fp_rollup_tmp.projfunc_cost_rate_date_type%type
            ,projfunc_cost_rate_date    pa_fp_rollup_tmp.projfunc_cost_rate_date%type
            ,projfunc_rev_rate_type     pa_fp_rollup_tmp.projfunc_rev_rate_type%type
            ,projfunc_rev_exchange_rate pa_fp_rollup_tmp.projfunc_rev_exchange_rate%type
            ,projfunc_rev_rate_date_type    pa_fp_rollup_tmp.projfunc_rev_rate_date_type%type
            ,projfunc_rev_rate_date     pa_fp_rollup_tmp.projfunc_rev_rate_date%type
        );
    TYPE mrc_fpTab IS TABLE OF mrc_fpRec INDEX BY  BINARY_INTEGER;
    G_FP_MRC_TAB        mrc_fpTab;
    */
    /* declare global plsql tabls for mrc enhancements */
    g_mrc_budget_line_id_tab                pa_plsql_datatypes.NumTabTyp;
    g_mrc_res_assignment_id_tab         pa_plsql_datatypes.NumTabTyp;
        g_mrc_txn_curr_code_tab         pa_plsql_datatypes.Char80TabTyp;
        g_mrc_start_date_tab                pa_plsql_datatypes.DateTabTyp;
        g_mrc_end_date_tab                  pa_plsql_datatypes.DateTabTyp;
        g_mrc_period_name_tab               pa_plsql_datatypes.Char80TabTyp;
        g_mrc_quantity_tab                  pa_plsql_datatypes.NumTabTyp;
        g_mrc_txn_raw_cost_tab              pa_plsql_datatypes.NumTabTyp;
        g_mrc_txn_burden_cost_tab           pa_plsql_datatypes.NumTabTyp;
        g_mrc_txn_revenue_tab               pa_plsql_datatypes.NumTabTyp;
        g_mrc_project_curr_code_tab         pa_plsql_datatypes.Char80TabTyp;
        g_mrc_project_raw_cost_tab          pa_plsql_datatypes.NumTabTyp;
        g_mrc_project_burden_cost_tab       pa_plsql_datatypes.NumTabTyp;
        g_mrc_project_revenue_tab           pa_plsql_datatypes.NumTabTyp;
        g_mrc_projfunc_curr_code_tab        pa_plsql_datatypes.Char80TabTyp;
        g_mrc_projfunc_raw_cost_tab         pa_plsql_datatypes.NumTabTyp;
        g_mrc_projfunc_burden_cost_tab      pa_plsql_datatypes.NumTabTyp;
        g_mrc_projfunc_revenue_tab          pa_plsql_datatypes.NumTabTyp;
        g_mrc_delete_flag_tab               pa_plsql_datatypes.Char1TabTyp;
        g_mrc_Billable_flag_tab             pa_plsql_datatypes.Char1TabTyp;
        g_mrc_project_cst_rt_type_tab        pa_plsql_datatypes.Char80TabTyp;
        g_mrc_project_cst_exg_rt_tab        pa_plsql_datatypes.NumTabTyp;
        g_mrc_project_cst_dt_type_tab   pa_plsql_datatypes.Char80TabTyp;
        g_mrc_project_cst_rt_dt_tab         pa_plsql_datatypes.DateTabTyp;
        g_mrc_project_rev_rt_type_tab         pa_plsql_datatypes.Char80TabTyp;
        g_mrc_project_rev_exg_rt_tab        pa_plsql_datatypes.NumTabTyp;
        g_mrc_project_rev_dt_type_tab         pa_plsql_datatypes.Char80TabTyp;
        g_mrc_project_rev_rt_dt_tab         pa_plsql_datatypes.DateTabTyp;
        g_mrc_projfunc_cst_rt_type_tab       pa_plsql_datatypes.Char80TabTyp;
        g_mrc_projfunc_cst_exg_rt_tab   pa_plsql_datatypes.NumTabTyp;
        g_mrc_projfunc_cst_dt_type_tab  pa_plsql_datatypes.Char80TabTyp;
        g_mrc_projfunc_cst_rt_dt_tab       pa_plsql_datatypes.DateTabTyp;
        g_mrc_projfunc_rev_rt_type_tab        pa_plsql_datatypes.Char80TabTyp;
        g_mrc_projfunc_rev_exg_rt_tab       pa_plsql_datatypes.NumTabTyp;
        g_mrc_projfunc_rev_dt_type_tab      pa_plsql_datatypes.Char80TabTyp;
        g_mrc_projfunc_rev_rt_dt_tab        pa_plsql_datatypes.DateTabTyp;

    /* The following plsql tabls are declared for bulk processing of spread calls */
        g_sprd_raId_tab         pa_plsql_datatypes.NumTabTyp;
        g_sprd_txn_cur_tab      pa_plsql_datatypes.Char50TabTyp;
        g_sprd_sdate_tab        pa_plsql_datatypes.DateTabTyp;
        g_sprd_edate_tab        pa_plsql_datatypes.DateTabTyp;
        g_sprd_plan_sdate_tab       pa_plsql_datatypes.DateTabTyp;
        g_sprd_plan_edate_tab       pa_plsql_datatypes.DateTabTyp;
        g_sprd_txn_rev_tab      pa_plsql_datatypes.NumTabTyp;
        g_sprd_txn_rev_addl_tab     pa_plsql_datatypes.NumTabTyp;
        g_sprd_txn_raw_tab      pa_plsql_datatypes.NumTabTyp;
        g_sprd_txn_raw_addl_tab     pa_plsql_datatypes.NumTabTyp;
        g_sprd_txn_burd_tab     pa_plsql_datatypes.NumTabTyp;
        g_sprd_txn_burd_addl_tab    pa_plsql_datatypes.NumTabTyp;
        g_sprd_qty_tab          pa_plsql_datatypes.NumTabTyp;
        g_sprd_qty_addl_tab     pa_plsql_datatypes.NumTabTyp;
        g_sprd_txn_cur_ovr_tab      pa_plsql_datatypes.Char50TabTyp;
        g_sprd_txn_init_rev_tab     pa_plsql_datatypes.NumTabTyp;
        g_sprd_txn_init_raw_tab     pa_plsql_datatypes.NumTabTyp;
        g_sprd_txn_init_burd_tab    pa_plsql_datatypes.NumTabTyp;
        g_sprd_txn_init_qty_tab     pa_plsql_datatypes.NumTabTyp;
        g_sprd_spread_reqd_flag_tab pa_plsql_datatypes.Char1TabTyp;
        g_sprd_costRt_tab       pa_plsql_datatypes.NumTabTyp;
        g_sprd_costRt_Ovr_tab       pa_plsql_datatypes.NumTabTyp;
        g_sprd_burdRt_Tab       pa_plsql_datatypes.NumTabTyp;
        g_sprd_burdRt_Ovr_tab       pa_plsql_datatypes.NumTabTyp;
        g_sprd_billRt_tab       pa_plsql_datatypes.NumTabTyp;
        g_sprd_billRt_Ovr_tab       pa_plsql_datatypes.NumTabTyp;
        g_sprd_ratebase_flag_tab    pa_plsql_datatypes.Char1TabTyp;
        g_sprd_projCur_tab      pa_plsql_datatypes.Char50TabTyp;
        g_sprd_projfuncCur_tab      pa_plsql_datatypes.Char50TabTyp;
    g_sprd_task_id_tab              pa_plsql_datatypes.NumTabTyp;
    g_sprd_rlm_id_tab       pa_plsql_datatypes.NumTabTyp;
    g_sprd_sp_fixed_date_tab        pa_plsql_datatypes.DateTabTyp;
    g_sprd_spcurve_id_tab           pa_plsql_datatypes.NumTabTyp;
    g_sprd_cstRtmissFlag_tab    pa_plsql_datatypes.Char1TabTyp;
    g_sprd_bdRtmissFlag_tab    pa_plsql_datatypes.Char1TabTyp;
    g_sprd_bilRtmissFlag_tab    pa_plsql_datatypes.Char1TabTyp;
	g_sprd_QtymissFlag_tab    pa_plsql_datatypes.Char1TabTyp;
    	g_sprd_RawmissFlag_tab    pa_plsql_datatypes.Char1TabTyp;
    	g_sprd_BurdmissFlag_tab    pa_plsql_datatypes.Char1TabTyp;
	g_sprd_RevmissFlag_tab    pa_plsql_datatypes.Char1TabTyp;
	/* Bug fix:5726773 */
 	g_sprd_neg_Qty_Changflag_tab pa_plsql_datatypes.Char1TabTyp;
 	g_sprd_neg_Raw_Changflag_tab pa_plsql_datatypes.Char1TabTyp;
 	g_sprd_neg_Burd_Changflag_tab pa_plsql_datatypes.Char1TabTyp;
 	g_sprd_neg_rev_Changflag_tab pa_plsql_datatypes.Char1TabTyp;


    /* The following plsql tables defined for bulk processing of rollup tmp for refresh action */
    g_plan_raId_tab              pa_plsql_datatypes.NumTabTyp;
    g_plan_txnCur_Tab            pa_plsql_datatypes.Char50TabTyp;
    g_line_sdate_tab                pa_plsql_datatypes.DateTabTyp;
    g_line_edate_tab                pa_plsql_datatypes.DateTabTyp;
    g_Wp_curCode_tab                pa_plsql_datatypes.Char50TabTyp;
    g_refresh_rates_tab     pa_plsql_datatypes.Char1TabTyp;
        g_refresh_conv_rates_tab    pa_plsql_datatypes.Char1TabTyp;
        g_mass_adjust_flag_tab      pa_plsql_datatypes.Char1TabTyp;
    g_mfc_cost_refresh_tab          pa_plsql_datatypes.Char1TabTyp;
    g_skip_record_tab       pa_plsql_datatypes.Char1TabTyp;
	g_process_skip_CstRevrec_tab pa_plsql_datatypes.Char1TabTyp;
    g_mfc_cost_refrsh_Raid_tab      pa_plsql_datatypes.NumTabTyp;
        g_mfc_cost_refrsh_txnCur_tab    pa_plsql_datatypes.Char50TabTyp;

    /* Bug fix:4295967 During Apply progress, If no change in the ETC quantity then re derive the ETC costs*/
    g_applyProg_refreshRts_tab      pa_plsql_datatypes.Char1TabTyp;
    g_applyProg_RaId_tab        pa_plsql_datatypes.NumTabTyp;
        g_applyProg_TxnCur_tab      pa_plsql_datatypes.Char50TabTyp;


    /* The following plsql tables defined for bulk processing of rate ONLY changed resource */
    g_rtChanged_Ra_Flag_tab     pa_plsql_datatypes.Char1TabTyp;
    g_rtChanged_RaId_tab        pa_plsql_datatypes.NumTabTyp;
        g_rtChanged_TxnCur_tab      pa_plsql_datatypes.Char50TabTyp;
    g_rtChanged_sDate_tab       pa_plsql_datatypes.DateTabTyp;
    g_rtChanged_eDate_tab       pa_plsql_datatypes.DateTabTyp;
        g_rtChanged_CostRt_Tab      pa_plsql_datatypes.NumTabTyp;
        g_rtChanged_BurdRt_tab      pa_plsql_datatypes.NumTabTyp;
        g_rtChanged_billRt_tab      pa_plsql_datatypes.NumTabTyp;
    	g_rtChanged_cstMisNumFlg_tab pa_plsql_datatypes.Char1TabTyp;
        g_rtChanged_bdMisNumFlag_tab pa_plsql_datatypes.Char1TabTyp;
        g_rtChanged_blMisNumFlag_tab pa_plsql_datatypes.Char1TabTyp;
	g_rtChanged_QtyMisNumFlg_tab pa_plsql_datatypes.Char1TabTyp;
        g_rtChanged_RwMisNumFlag_tab pa_plsql_datatypes.Char1TabTyp;
        g_rtChanged_BrMisNumFlag_tab pa_plsql_datatypes.Char1TabTyp;
	g_rtChanged_RvMisNumFlag_tab pa_plsql_datatypes.Char1TabTyp;

    g_apply_progress_flag_tab       SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();

	g_etcrevrej_raId_tab		pa_plsql_datatypes.NumTabTyp;
        g_etcrevrej_txnCur_tab		pa_plsql_datatypes.Char30TabTyp;
        g_etcrevrej_revenue_tab	        pa_plsql_datatypes.NumTabTyp;
        g_etcrevrej_start_date_tab	pa_plsql_datatypes.DateTabTyp;
        g_etcrevrej_end_date_tab	pa_plsql_datatypes.DateTabTyp;

    -- Added for Bug# 6781055
    gl_cl_roll_up_tmp_rowid_tab    pa_plsql_datatypes.RowidTabTyp;

    /*Declare global cursors so that the same cursor can be opend at many places
    * and maintenance of the code is simple and easy
    */
    CURSOR get_proj_fp_options_csr(p_budget_version_id  Number) IS
        SELECT nvl(pfo.use_planning_rates_flag,'N') use_planning_rates_flag
          ,decode(nvl(bv.wp_version_flag,'N'),'Y',NVL(pfo.track_workplan_costs_flag,'N'),'Y') track_workplan_costs_flag
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
          ,bv.project_structure_version_id
          ,bv.project_id
          ,pp.project_currency_code
          ,pp.projfunc_currency_code
          ,pp.segment1  project_Name
          ,bv.ci_id     CiId
          /*Bugfix:4272944 */
          ,NVL(pp.baseline_funding_flag,'N') baseline_funding_flag
      ,decode(fpt.plan_class_code,'BUDGET'
            ,decode(bv.wp_version_flag,'Y','WORKPLAN',fpt.plan_class_code),fpt.plan_class_code) Plan_Class_Type
        FROM pa_proj_fp_options pfo
            ,pa_budget_versions bv
            ,pa_projects_all pp
        ,pa_fin_plan_types_b fpt
        WHERE pfo.fin_plan_version_id = bv.budget_version_id
        AND  bv.project_id = pp.project_id
    AND  fpt.fin_plan_type_id = pfo.fin_plan_type_id
        AND bv.budget_version_id = p_budget_version_id;
        ProjFpOptRec    get_proj_fp_options_csr%ROWTYPE;



    /* Rounding enhancements: modified the rate derivation logic. instead of deriving rate = sum(amount) / sum(quantity)
         * derive rate = sum(quantity * periodic line rate) / sum(quantity)
     * this will take care of rounded decimals and on the UI
     * For more details refer to Rounding issues details design doc
     */
    CURSOR cur_avgBlrts(p_resource_asg_id IN NUMBER
                         ,p_txn_curr_code   IN VARCHAR2
                         ,p_line_start_date IN DATE
                         ,p_line_end_date   IN DATE ) IS
    SELECT /*+ INDEX(blavgrt PA_BUDGET_LINES_U1) */
        AVG(DECODE((nvl(blavgrt.quantity,0) - nvl(blavgrt.init_quantity,0)),0,NULL
			,blavgrt.txn_cost_rate_override)) avg_txn_cost_rate_override
               ,AVG(DECODE((nvl(blavgrt.quantity,0) - nvl(blavgrt.init_quantity,0)),0,NULL
			,blavgrt.burden_cost_rate_override))   avg_burden_cost_rate_override
               ,AVG(DECODE((nvl(blavgrt.quantity,0) - nvl(blavgrt.init_quantity,0)),0,NULL
			,blavgrt.txn_bill_rate_override)) avg_txn_bill_rate_override
           /* Bug fix: 5172318 Not required as part of IPM changes
           ,SUM(nvl(blavgrt.quantity,0) - nvl(blavgrt.init_quantity,0)) sum_etc_Qty
           ,SUM(nvl(blavgrt.init_quantity,0)) sum_Actual_Qty
           ,SUM(nvl(blavgrt.quantity,0)) sum_Plan_Qty
	   */
           /*bug fix:4693839 */
           ,AVG(NVL(blavgrt.txn_cost_rate_override,blavgrt.txn_standard_cost_rate)) avg_zero_null_cost_rate
           ,AVG(NVL(blavgrt.burden_cost_rate_override,blavgrt.burden_cost_rate))    avg_zero_null_burden_rate
           ,AVG(NVL(blavgrt.txn_bill_rate_override,blavgrt.txn_standard_bill_rate)) avg_zero_null_bill_rate
             FROM pa_budget_lines blavgrt
             WHERE blavgrt.resource_assignment_id = p_resource_asg_id
             AND blavgrt.txn_currency_code      = p_txn_curr_code
             AND ( (p_line_start_date is NULL AND p_line_end_date is NULL )
                OR
                 (p_line_start_date is NOT NULL AND p_line_end_date is NOT NULL
                  AND blavgrt.start_date BETWEEN p_line_start_date AND p_line_end_date)
                 );

    AvgBlRec   cur_avgBlrts%ROWTYPE;
        CURSOR get_bl_date_csr (p_resource_asg_id IN NUMBER
                         ,p_txn_curr_code   IN VARCHAR2
                         ,p_line_start_date IN DATE
                         ,p_line_end_date   IN DATE
             ,p_avg_txn_cost_rate_override IN NUMBER
             ,p_avg_burden_rate_override IN NUMBER
             ,p_avg_bill_rate_override IN NUMBER ) IS
        SELECT /*+ INDEX(BL PA_BUDGET_LINES_U1) */
          decode(sum(bl.quantity),0,NULL,sum(bl.quantity)) quantity
             ,decode( sum(bl.txn_raw_cost),0,NULL,sum(bl.txn_raw_cost)) txn_raw_cost
             ,decode(sum(bl.txn_burdened_cost),0,NULL,sum(bl.txn_burdened_cost)) txn_burdened_cost
             ,decode(sum(bl.txn_revenue),0,NULL,sum(bl.txn_revenue)) txn_revenue
             -- Actuals for ETC calculation
            ,decode(sum(bl.init_quantity),0,NULL,sum(bl.init_quantity)) init_quantity
            ,decode(sum(bl.txn_init_raw_cost),0,NULL,sum(bl.txn_init_raw_cost)) init_raw_cost
            ,decode(sum(bl.txn_init_burdened_cost),0,NULL,sum(bl.txn_init_burdened_cost)) init_burdened_cost
            ,decode(sum(bl.txn_init_revenue),0,NULL,sum(bl.txn_init_revenue)) init_revenue
             ,(sum(decode(p_avg_txn_cost_rate_override,NULL,NULL
                    ,decode((nvl(bl.quantity,0) - nvl(bl.init_quantity,0)),0,NULL
                    ,decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,NULL
                        ,((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)) *
			  nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)))))))
               / DECODE((sum(decode(p_avg_txn_cost_rate_override,NULL,NULL
                    ,decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,NULL
                    ,decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,null
			,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0)))))))
          	,0,NULL,
          	(sum(decode(p_avg_txn_cost_rate_override,NULL,NULL
                    ,decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,NULL
                    ,decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,null
			,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0)))))))
          	)
              ) etc_cost_rate_override
             ,(sum(decode(p_avg_burden_rate_override,NULL,NULL
                    ,decode((nvl(bl.quantity,0) - nvl(bl.init_quantity,0)),0,NULL
                    ,decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,NULL
                        ,((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)) *
			   nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)))))))
               / DECODE((sum(decode(p_avg_burden_rate_override,NULL,NULL
                    ,decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,NULL
                    ,decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,NULL
			,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0)))))))
          		,0,NULL,
           	(sum(decode(p_avg_burden_rate_override,NULL,NULL
                    ,decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,NULL
                    ,decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,NULL
			,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0)))))))
          	)
              ) etc_burden_rate_override
             ,(sum(decode(p_avg_bill_rate_override,NULL,NULL
                    , decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,NULL
                    ,decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0,NULL
                        ,((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)) *
			nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)))))))
               / DECODE((sum(decode(p_avg_bill_rate_override,NULL,NULL
                    ,decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,NULL
                    ,decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0,null
			,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0)))))))
          	,0,NULL,
           	(sum(decode(p_avg_bill_rate_override,NULL,NULL
                    ,decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,NULL
                    ,decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0,null
			,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0)))))))
           	)
              ) etc_bill_rate_override
             ,(sum(( decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                    ,decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0,null
                        ,((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)) *
			nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)))))))
               / DECODE((sum(decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                    ,decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0,null
			,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0))))))
          	,0,NULL,
           	(sum(decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                    ,decode(nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)),0
			,null,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0))))))
        	)
              ) etc_bill_rate
           	,(sum(( decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                    ,decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,null
                        ,((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)) *
			nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)))))))
               / DECODE((sum(decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                    ,decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,null
			,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0))))))
           	,0,NULL,
            	(sum(decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                    ,decode(nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)),0,null
			,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0))))))
        	)
              ) etc_cost_rate
             ,(sum(( decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                    ,decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,null
                        ,((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)) *
			  nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)))))))
               / DECODE((sum(decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                    ,decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,null
			,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0))))))
          	,0,NULL,
           	(sum(decode((nvl(bl.quantity,0)- nvl(bl.init_quantity,0)),0,null
                    ,decode(nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)),0,null
			,(nvl(bl.quantity,0)- nvl(bl.init_quantity,0))))))
        	)
              ) etc_burden_rate
       		/* Bug fix:4693839 Currently all the UI page shows null instead of zeros, and when they pass to param value
           * will be passed null, representing no change, but some other API like AMG etc, may pass zero in param value.
           * In order to avoid changing all the calling api, this api is modified to handle nulls and zeros carefully */
           ,SUM(bl.quantity)              bl_zero_null_quantity
           ,SUM(bl.txn_raw_cost)          bl_zero_null_rawcost
           ,SUM(bl.txn_burdened_cost)     bl_zero_null_burdencost
           ,SUM(bl.txn_revenue)           bl_zero_null_revenue
           ,SUM(bl.display_quantity)      display_quantity --Bug 6429285
        FROM pa_budget_lines bl
        WHERE bl.resource_assignment_id = p_resource_asg_id
        AND bl.txn_currency_code      = p_txn_curr_code
        AND ( (p_line_start_date is NULL AND p_line_end_date is NULL )
             OR
            (p_line_start_date is NOT NULL AND p_line_end_date is NOT NULL
            AND bl.start_date BETWEEN p_line_start_date AND p_line_end_date)
           ) ;

    /* Bug fix:4900436: IPM Enhancements: */
        CURSOR cur_ra_txn_rates (p_resource_asg_id IN NUMBER
                            ,p_txn_curr_code   IN VARCHAR2) IS
        SELECT  decode(rtx.total_quantity,0,null,rtx.total_quantity) quantity
                ,decode( rtx.total_txn_raw_cost,0,NULL,rtx.total_txn_raw_cost) txn_raw_cost
                ,decode(rtx.total_txn_burdened_cost,0,NULL,rtx.total_txn_burdened_cost) txn_burdened_cost
                ,decode(rtx.total_txn_revenue,0,NULL,rtx.total_txn_revenue) txn_revenue
                ,decode(rtx.total_init_quantity,0,NULL,rtx.total_init_quantity) init_quantity
                ,decode(rtx.total_txn_init_raw_cost,0,NULL,rtx.total_txn_init_raw_cost) init_raw_cost
                ,decode(rtx.total_txn_init_burdened_cost,0,NULL,rtx.total_txn_init_burdened_cost) init_burdened_cost
                ,decode(rtx.total_txn_init_revenue,0,NULL,rtx.total_txn_init_revenue) init_revenue
                ,rtx.TXN_RAW_COST_RATE_OVERRIDE     etc_cost_rate_override
                ,rtx.TXN_BURDEN_COST_RATE_OVERRIDE  etc_burden_rate_override
                ,rtx.TXN_BILL_RATE_OVERRIDE         etc_bill_rate_override
                ,rtx.TXN_ETC_BILL_RATE          etc_bill_rate
                ,rtx.TXN_ETC_RAW_COST_RATE      etc_cost_rate
                ,rtx.TXN_ETC_BURDEN_COST_RATE       etc_burden_rate
            ,rtx.total_quantity                 bl_zero_null_quantity
            ,rtx.total_txn_raw_cost             bl_zero_null_rawcost
            ,rtx.total_txn_burdened_cost        bl_zero_null_burdencost
            ,rtx.total_txn_revenue              bl_zero_null_revenue
            ,rtx.total_display_quantity         display_quantity --Bug 6429285
    FROM pa_resource_asgn_curr rtx
    WHERE rtx.resource_assignment_id = p_resource_asg_id
    AND  rtx.txn_currency_code = p_txn_curr_code;

/*
procedure calc_log(p_msg  varchar2) IS

        pragma autonomous_transaction ;
BEGIN
            INSERT INTO PA_FP_CALCULATE_LOG
                (SESSIONID
                ,SEQ_NUMBER
                ,LOG_MESSAGE)
            VALUES
                (userenv('sessionid')
                ,HR.PAY_US_GARN_FEE_RULES_S.nextval
                ,substr(P_MSG,1,240)
                );
	COMMIT;
end calc_log;
*/

procedure print_plsql_time(P_MSG  VARCHAR2
           ,p_dbug_flag VARCHAR2 default 'N') is

BEGIN
	null;
      	--calc_log(P_MSG);
	--dbms_output.put_line(p_msg);
END print_plsql_time;

procedure PRINT_MSG(P_MSG  VARCHAR2
           ,p_dbug_flag VARCHAR2 default 'N') is

BEGIN
      --calc_log(P_MSG);
        IF (P_PA_DEBUG_MODE = 'Y' ) Then
            pa_debug.g_err_stage := substr('LOG:'||p_msg,1,240);
            PA_DEBUG.write
            (x_Module   => g_module_name
            ,x_Msg      => pa_debug.g_err_stage
            ,x_Log_Level    => 3);
            --pa_debug.write_file('LOG: '||pa_debug.g_err_stage);
        END IF;
    /* Incase of performance issue without enabling the debugs get the timings for each API */
    /**
    IF (P_PA_DEBUG_MODE = 'N' AND nvl(p_dbug_flag,'N') = 'Y' ) THEN
        FND_LOG_REPOSITORY.STR_UNCHKED_INT_WITH_CONTEXT
                (LOG_LEVEL      => 3
                ,MODULE         => g_module_name
                ,MESSAGE_TEXT   => 'LOG:'||p_msg
                );
    END IF;
    **/
    Return;
END PRINT_MSG;

/* Bug fix:5203622: When source planning resource has revenue only, then generating forecast results
 * in irrational ETC revenue calculations. so error message will be displayed on Edit Plan page
 * after Forecast Generation to indicate to users that specific ETC Rev amounts may be calculated improperly
 * and may need manual verification.
 * These error message will be cleared upon any manual update to the ETC Rev amount through calculate process
 */
PROCEDURE clear_etc_rev_other_rejectns
	 (p_budget_version_id     	Number
            ,p_source_context       	Varchar2
            ,p_calling_module     	Varchar2
	    ,p_mode               	Varchar2
            ,x_return_status    OUT NOCOPY Varchar2
            ,x_msg_count        OUT NOCOPY number
            ,x_msg_data     	OUT NOCOPY Varchar2
            ) IS

	CURSOR cur_get_rejLines IS
	SELECT /*+ INDEX(BL PA_BUDGET_LINES_U1) */
		bl.resource_assignment_id
	       ,bl.txn_currency_code
	       ,sum(bl.txn_revenue)
	       ,decode(p_source_context,'BUDGET_LINE',tmp.start_date,NULL) start_date
	       ,decode(p_source_context,'BUDGET_LINE',tmp.end_date,NULL) end_date
	FROM PA_BUDGET_LINES bl
	     ,PA_FP_SPREAD_CALC_TMP tmp
	WHERE tmp.budget_version_id = p_budget_version_id
	AND   bl.resource_assignment_id = tmp.resource_assignment_id
	AND   bl.txn_currency_code = tmp.txn_currency_code
	AND   ((p_source_context = 'BUDGET_LINE'
	       and bl.start_date between tmp.start_date and tmp.end_date )
		OR
		p_source_context <> 'BUDGET_LINE'
	      )
	AND   bl.other_rejection_code is NOT NULL
	GROUP BY bl.resource_assignment_id
		,bl.txn_currency_code
		,decode(p_source_context,'BUDGET_LINE',tmp.start_date,NULL)
		,decode(p_source_context,'BUDGET_LINE',tmp.end_date,NULL) ;

	l_etcrevrej_raId_tab	pa_plsql_datatypes.NumTabTyp;
        l_etcrevrej_txnCur_tab	pa_plsql_datatypes.Char30TabTyp;
        l_etcrevrej_revenue_tab	pa_plsql_datatypes.NumTabTyp;
        l_budget_line_id_tab	pa_plsql_datatypes.NumTabTyp;

BEGIN
	x_return_status := 'S';
	x_msg_count := 0;
	x_msg_data := NULL;
	If P_PA_DEBUG_MODE = 'Y' Then
	print_msg('Inside clear_etc_rev_other_rejectns API');
	End If;

	IF p_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION')
	   and g_fp_budget_version_type = 'ALL'
           and g_ciId is NULL Then --{
		If p_mode = 'CACHE' Then
			-- cache the lines which needs to processed later
			g_etcrevrej_raId_tab.delete;
			g_etcrevrej_txnCur_tab.delete;
			g_etcrevrej_revenue_tab.delete;
			g_etcrevrej_start_date_tab.delete;
			g_etcrevrej_end_date_tab.delete;
			OPEN cur_get_rejLines;
			FETCH cur_get_rejLines BULK COLLECT INTO
				g_etcrevrej_raId_tab
				,g_etcrevrej_txnCur_tab
				,g_etcrevrej_revenue_tab
				,g_etcrevrej_start_date_tab
                                ,g_etcrevrej_end_date_tab;
			CLOSE cur_get_rejLines;

			If P_PA_DEBUG_MODE = 'Y' Then
				print_msg('Number of etc revenue rejected lines cached =['||g_etcrevrej_raId_tab.count||']');
			End If;
		ElsIf p_mode = 'CLEAR_REJECTIONS' Then
			If g_etcrevrej_raId_tab.COUNT > 0 Then --{
				-- now get the latest sum of revenue from budget lines
				-- if the user has made any change to revenue ( the calculated revenue is not same as)
				-- old revenue then null out the other rejection code on the budget line
				l_etcrevrej_raId_tab.delete;
                        	l_etcrevrej_txnCur_tab.delete;
                        	l_etcrevrej_revenue_tab.delete;
				g_etcrevrej_start_date_tab.delete;
				g_etcrevrej_end_date_tab.delete;
                        	OPEN cur_get_rejLines;
                        	FETCH cur_get_rejLines BULK COLLECT INTO
                                	l_etcrevrej_raId_tab
                                	,l_etcrevrej_txnCur_tab
                                	,l_etcrevrej_revenue_tab
					,g_etcrevrej_start_date_tab
					,g_etcrevrej_end_date_tab;
                        	CLOSE cur_get_rejLines;
				If l_etcrevrej_raId_tab.COUNT > 0 Then --{
				FORALL i IN l_etcrevrej_raId_tab.FIRST .. l_etcrevrej_raId_tab.LAST
				UPDATE PA_BUDGET_LINES bl
				SET bl.other_rejection_code = NULL
				WHERE bl.resource_assignment_id = l_etcrevrej_raId_tab(i)
				AND   bl.txn_currency_code = l_etcrevrej_txnCur_tab(i)
				AND   nvl(g_etcrevrej_revenue_tab(i),0) <> nvl(l_etcrevrej_revenue_tab(i),0)
				AND   ((p_source_context = 'BUDGET_LINE'
					and bl.start_date between g_etcrevrej_start_date_tab(i) and g_etcrevrej_end_date_tab(i))
					OR
					p_source_context <> 'BUDGET_LINE'
				      )
				RETURN bl.budget_line_id
				BULK COLLECT INTO l_budget_line_id_tab;

				If P_PA_DEBUG_MODE = 'Y' Then
                                    print_msg('Number of etc revenue rejected lines cleared =['||l_budget_line_id_tab.count||']');
                        	End If;
				END IF; --}

				/* reset plsql cache */
				l_etcrevrej_raId_tab.delete;
                                l_etcrevrej_txnCur_tab.delete;
                                l_etcrevrej_revenue_tab.delete;
				l_budget_line_id_tab.delete;
				g_etcrevrej_raId_tab.delete;
                                g_etcrevrej_txnCur_tab.delete;
                                g_etcrevrej_revenue_tab.delete;
                                g_etcrevrej_start_date_tab.delete;
                                g_etcrevrej_end_date_tab.delete;
			END IF; --}
		End If;
	End If; --}
EXCEPTION
        WHEN OTHERS THEN
                print_msg('Errored in clear_etc_rev_other_rejectns:'||sqlcode||sqlerrm);
        	x_return_status := 'U';
                RAISE;

END clear_etc_rev_other_rejectns;

PROCEDURE delete_raTxn_Tmp IS
BEGIN
    DELETE FROM pa_resource_asgn_curr_tmp;
END delete_raTxn_Tmp;

PROCEDURE print_rlTmp_Values IS

	CURSOR cur_rltmp IS
	SELECT tmp.resource_assignment_id
		,tmp.txn_currency_code
		,tmp.start_date
		,tmp.end_date
		,tmp.quantity
		,tmp.txn_raw_cost
		,tmp.rw_cost_rate_override
		,tmp.txn_burdened_cost
		,tmp.burden_cost_rate_override
		,tmp.txn_revenue
		,tmp.bill_rate_override
		,tmp.budget_line_id
	FROM pa_fp_rollup_tmp tmp
	ORDER BY tmp.resource_assignment_id
                ,tmp.txn_currency_code;

	CURSOR cur_calTmp IS
        SELECT tmp.resource_assignment_id
                ,tmp.txn_currency_code
                ,tmp.start_date
		,tmp.end_date
                ,tmp.quantity
                ,tmp.txn_raw_cost
                ,tmp.cost_rate_override
                ,tmp.txn_burdened_cost
                ,tmp.burden_cost_rate_override
                ,tmp.txn_revenue
                ,tmp.bill_rate_override
        FROM pa_fp_spread_calc_tmp tmp
        ORDER BY tmp.resource_assignment_id
                ,tmp.txn_currency_code;

	l_msg	Varchar2(2000);
BEGIN
	/**
	IF P_PA_DEBUG_MODE = 'Y' Then
		FOR i IN cur_rltmp LOOP
			l_msg := 'RollupTmp:blId['||i.budget_line_id||']RaId['||i.resource_assignment_id||']TxnCur['||i.txn_currency_code||']';
			l_msg := l_msg||'SD['||i.start_date||']ED['||i.end_date||']Qty['||i.quantity||']CstRtOvr['||i.rw_cost_rate_override||']';
			l_msg := l_msg||'BurdRtOvr['||i.burden_cost_rate_override||']BillRtOvr['||i.bill_rate_override||']';
			print_msg(l_msg);
		END LOOP;
		FOR i IN cur_calTmp LOOP
                        l_msg := 'CalcTmp:RaId['||i.resource_assignment_id||']TxnCur['||i.txn_currency_code||']';
                        l_msg := l_msg||'SD['||i.start_date||']ED['||i.end_date||']Qty['||i.quantity||']CstRtOvr['||i.cost_rate_override||']';
                        l_msg := l_msg||'BurdRtOvr['||i.burden_cost_rate_override||']BillRtOvr['||i.bill_rate_override||']';
                        print_msg(l_msg);
                END LOOP;
	END IF;
	**/
	NULL;

END print_rlTmp_Values;

/* IPM Changes: This API populates records into new entity pa_resource_asgn_curr table
 * and calls pa_res_asg_currency_pub.MAINTAIN_DATA to rollup the amounts
 * and updates the rate overrides
 * Logic: When Refresh rates flag = 'Y'
 *          -- Delete all records from the new entity
 *        When source context = BUDGET LINE
 *          -- rollup the amounts in the new entity
 *        When source context = RESOURCE ASSIGNMENT
 *          -- create a new record or update existing records with rate overrides
 *  This API inserts records into temp table based on various combination of input parameters
 *  and finally make call to maintain_data package
 */
PROCEDURE populate_raTxn_Recs (
            p_budget_version_id     Number
            ,p_source_context       Varchar2
            ,p_calling_mode     Varchar2
            ,p_delete_flag      Varchar2 := 'N'
            ,p_delete_raTxn_flag    Varchar2 := 'N'
            ,p_rollup_flag      Varchar2 := 'N'
            ,p_call_raTxn_rollup_flag Varchar2 := 'N'
            ,p_refresh_rate_flag    Varchar2 := 'N'
	    ,p_resource_assignment_id NUMBER := NULL
	    ,p_txn_currency_code      Varchar2 := NULL
	    ,p_start_date	      DATE := NULL
            ,x_return_status    OUT NOCOPY Varchar2
            ,x_msg_count        OUT NOCOPY number
            ,x_msg_data     OUT NOCOPY Varchar2
            ) IS
    l_rowCount Number := 0;
    l_rowCount1 Number := 0;
    -- Added for Bug# 6781055
    l_rw_cost_rate_override      NUMBER;
    l_burden_cost_rate_override  NUMBER;
    l_bill_rate_override         NUMBER;
    l_ra_id                      NUMBER;
    l_txn_currency_code          VARCHAR2(15);
    -- End for Bug# 6781055

   -- gboomina added for AAI requirement Bug 8318932 - start
   -- Cursor to get 'Copy ETC from Plan' flag
   CURSOR get_copy_etc_from_plan_csr
   IS
     SELECT COPY_ETC_FROM_PLAN_FLAG
     FROM PA_PROJ_FP_OPTIONS
     WHERE FIN_PLAN_VERSION_ID = P_BUDGET_VERSION_ID;

   l_copy_etc_from_plan_flag PA_PROJ_FP_OPTIONS.COPY_ETC_FROM_PLAN_FLAG%TYPE;
   -- gboomina added for AAI requirement Bug 8318932 - end

BEGIN

    x_return_status := 'S';
    IF NVL(p_delete_flag,'N') = 'N' Then
      IF p_source_context = 'RESOURCE_ASSIGNMENT' Then
           If NVL(p_refresh_rate_flag,'N') = 'Y' Then --{
            --print_msg('Inserting records into pa_resource_asgn_curr_tmp for Refresh rates action');
            INSERT INTO pa_resource_asgn_curr_tmp raTxn
                        (RA_TXN_ID
                        ,BUDGET_VERSION_ID
                        ,RESOURCE_ASSIGNMENT_ID
                        ,TXN_CURRENCY_CODE
                        ,DELETE_FLAG
                        )
                        SELECT /*+ INDEX(RTX PA_RESOURCE_ASGN_CURR_U2) */ 1 ra_txn_id
                        ,p_budget_version_id
                        ,tmp.resource_assignment_id
                        ,tmp.txn_currency_code
                        ,'Y'
                    FROM pa_fp_spread_calc_tmp tmp
                	,pa_resource_asgn_curr rtx
                    WHERE tmp.budget_version_id = p_budget_version_id
            	    AND tmp.resource_assignment_id = rtx.resource_assignment_id
                    AND tmp.txn_currency_code = rtx.txn_currency_code
		    /* bug fix: If no budge Lines exists then donot delete the resource when refresh is done */
		    AND EXISTS ( select /*+ INDEX(RTMP PA_FP_ROLLUP_TMP_N1) */ null
				 from pa_fp_rollup_tmp rtmp
				 where rtmp.resource_assignment_id = tmp.resource_assignment_id
				 and rtmp.txn_currency_code = tmp.txn_currency_code
				);
                    l_rowCount1      := sql%Rowcount;
                    --print_msg('Number of records inserted ['||l_rowCount1||']');

		    /* Set the override rates to null only for the records exists in spcalctmp table and
		     * no budget lines exists
		     */
		    UPDATE /*+ INDEX(RTX PA_RESOURCE_ASGN_CURR_U2) */ pa_resource_asgn_curr rtx
                    SET rtx.TXN_RAW_COST_RATE_OVERRIDE  = null
                            ,rtx.TXN_BURDEN_COST_RATE_OVERRIDE = null
                            ,rtx.TXN_BILL_RATE_OVERRIDE = null
                    WHERE rtx.budget_version_id = p_budget_version_id
		    AND EXISTS ( select null
				 from pa_fp_spread_calc_tmp tmp
				 where tmp.resource_assignment_id = rtx.resource_assignment_id
				 and tmp.txn_currency_code = rtx.txn_currency_code
				)
                    AND NOT EXISTS ( select null
                                        from pa_fp_rollup_tmp rtmp
                                        where rtmp.resource_assignment_id = rtx.resource_assignment_id
                                        and rtmp.txn_currency_code = rtx.txn_currency_code
                                        );
		     --print_msg('Number of records updated directly with null['||sql%rowcount||']');

                    If l_rowCount1 > 0 Then
                        --print_msg('Calling pa_res_asg_currency_pub.maintain_data for deleting records for refresh rates');
                        pa_res_asg_currency_pub.MAINTAIN_DATA
                        (P_FP_COLS_REC          => G_FP_COLS_REC
                        ,P_CALLING_MODULE       => 'CALCULATE_API'
                        ,P_DELETE_FLAG          => 'Y'
                        ,P_ROLLUP_FLAG          => 'N'
                        ,P_VERSION_LEVEL_FLAG   => 'N'
                        ,X_RETURN_STATUS        => x_return_status
                        ,X_MSG_COUNT            => x_msg_count
                        ,X_MSG_DATA             => x_msg_data
                        );
                        --print_msg('Return Status of the api ['||x_return_status||']');
                   End If;

        Else
            --print_msg('Inserting records in pa_resource_asgn_curr_tmp from spcalctmp tabls');
                        INSERT INTO pa_resource_asgn_curr_tmp
                        (RA_TXN_ID
                        ,BUDGET_VERSION_ID
                        ,RESOURCE_ASSIGNMENT_ID
                        ,TXN_CURRENCY_CODE
                        ,TXN_RAW_COST_RATE_OVERRIDE
                        ,TXN_BURDEN_COST_RATE_OVERRIDE
                        ,TXN_BILL_RATE_OVERRIDE
                        ,DELETE_FLAG
                        )
                        SELECT /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP_N1) */ pa_resource_asgn_curr_s.nextval
                        ,p_budget_version_id
                        ,tmp.resource_assignment_id
                        ,NVL(tmp.txn_curr_code_override,tmp.txn_currency_code)
                        ,decode(p_refresh_rate_flag, 'N', tmp.cost_rate_override, NULL)
                        ,decode(p_refresh_rate_flag, 'N', tmp.burden_cost_rate_override, NULL)
                        ,decode(p_refresh_rate_flag, 'N', tmp.bill_rate_override, NULL)
                        ,p_delete_raTxn_flag
                        FROM pa_fp_spread_calc_tmp tmp
                        WHERE tmp.budget_version_id = p_budget_version_id
                        AND NVL(tmp.RA_RATES_ONLY_CHANGE_FLAG,'N') = 'Y'
                          OR (NVL(tmp.cost_rate_changed_flag,'N') = 'Y'
                          OR NVL(tmp.burden_rate_changed_flag,'N') = 'Y'
                          OR NVL(tmp.bill_rate_changed_flag,'N') = 'Y'
              OR NVL(tmp.raw_cost_changed_flag,'N') = 'Y'
              OR NVL(tmp.burden_cost_changed_flag,'N') = 'Y'
              OR NVL(tmp.revenue_changed_flag,'N') = 'Y'
              OR tmp.txn_curr_code_override is NOT NULL
                         );
                        l_rowCount      := sql%Rowcount;
                        --print_msg('Number of records inserted ['||l_rowCount||']');
           If l_rowCount > 0 Then
                        /* The following update is required with current logic of the
                        * new maintain entity which always blows out the records and inserts new records */
            		--print_msg('Updating pa_resource_asgn_curr_tmp to set rate overrides derived during calculate');
                        UPDATE pa_resource_asgn_curr_tmp tmp
                        SET (tmp.TXN_RAW_COST_RATE_OVERRIDE
                        ,tmp.TXN_BURDEN_COST_RATE_OVERRIDE
                        ,tmp.TXN_BILL_RATE_OVERRIDE) =
                                (SELECT decode(tmp1.cost_rate_g_miss_num_flag,'Y',NULL
					,NVL(tmp1.cost_rate_override,rtx.TXN_RAW_COST_RATE_OVERRIDE))
                                ,decode(tmp1.burden_rate_g_miss_num_flag,'Y',NULL
					,NVL(tmp1.burden_cost_rate_override,rtx.TXN_BURDEN_COST_RATE_OVERRIDE))
                                ,decode(tmp1.bill_rate_g_miss_num_flag,'Y',NULL
					,NVL(tmp1.bill_rate_override,rtx.TXN_BILL_RATE_OVERRIDE))
                                FROM pa_resource_asgn_curr rtx
                    			,pa_fp_spread_calc_tmp tmp1
                                WHERE rtx.resource_assignment_id = tmp.resource_assignment_id
                                AND rtx.txn_currency_code = tmp.txn_currency_code
                		AND tmp1.resource_assignment_id = tmp.resource_assignment_id
                		AND NVL(tmp1.txn_curr_code_override,tmp1.txn_currency_code) = tmp.txn_currency_code
                                )
                        WHERE tmp.budget_version_id = p_budget_version_id
                        AND EXISTS (select null from pa_resource_asgn_curr rtx2
                    			,pa_fp_spread_calc_tmp tmp2
                                        where rtx2.resource_assignment_id = tmp.resource_assignment_id
                                        and rtx2.txn_currency_code = tmp.txn_currency_code
                    			AND tmp2.resource_assignment_id = tmp.resource_assignment_id
                                        AND NVL(tmp2.txn_curr_code_override,tmp2.txn_currency_code) = tmp.txn_currency_code
                                   );
            		--print_msg('Number of records Updated ['||sql%Rowcount||']');
                  End If;

          	/* If only rates are changed then update the changed override rates on rollup tmp and avoid calling spread
               	* and call rate api */
              IF g_rtChanged_RaId_tab.COUNT > 0 Then
                g_stage := 'update pa_resource_asgn_curr_tmp with OvrRts';
                --print_msg(g_stage);
                FORALL i IN g_rtChanged_RaId_tab.FIRST .. g_rtChanged_RaId_tab.LAST
                UPDATE pa_resource_asgn_curr_tmp tmp
                    SET tmp.TXN_RAW_COST_RATE_OVERRIDE       = decode(NVL(g_rtChanged_cstMisNumFlg_tab(i),'N'),'Y',NULL
                                                        ,NVL(g_rtChanged_CostRt_Tab(i),tmp.TXN_RAW_COST_RATE_OVERRIDE))
                            ,tmp.TXN_BURDEN_COST_RATE_OVERRIDE = decode(NVL(g_rtChanged_bdMisNumFlag_tab(i),'N'),'Y',NULL
                                                        ,NVL(g_rtChanged_BurdRt_tab(i),tmp.TXN_BURDEN_COST_RATE_OVERRIDE))
                            ,tmp.TXN_BILL_RATE_OVERRIDE = decode(NVL(g_rtChanged_blMisNumFlag_tab(i),'N'),'Y',NULL
                                                        ,NVL(g_rtChanged_billRt_tab(i),tmp.TXN_BILL_RATE_OVERRIDE))
                WHERE tmp.budget_version_id = p_budget_version_id
                AND   tmp.resource_assignment_id = g_rtChanged_RaId_tab(i)
                AND   tmp.txn_currency_code = g_rtChanged_TxnCur_tab(i);
                --print_msg('Number of rows updated for RateChanges['||sql%rowcount||']');

              END IF;

		/* when calculate api is called with rollup flag = N then override rates changed during the
		 * calcualtion process is not getting stamped on the new entity
		 * so whenever override rates are derived and rollup flag is N, directly update the
		 * new entity with override rates
		 */
	      IF G_call_raTxn_rollup_flag = 'N' Then
			--print_msg('Updating new entity with override rates when rollup flag is N');
			UPDATE /*+ INDEX(RTX PA_RESOURCE_ASGN_CURR_U2) */ pa_resource_asgn_curr rtx
                    	SET (rtx.TXN_RAW_COST_RATE_OVERRIDE
                            ,rtx.TXN_BURDEN_COST_RATE_OVERRIDE
                            ,rtx.TXN_BILL_RATE_OVERRIDE) =
					(SELECT tmp.TXN_RAW_COST_RATE_OVERRIDE
                            			,tmp.TXN_BURDEN_COST_RATE_OVERRIDE
                            			,tmp.TXN_BILL_RATE_OVERRIDE
					FROM pa_resource_asgn_curr_tmp tmp
					WHERE tmp.resource_assignment_id = rtx.resource_assignment_id
					AND   tmp.txn_currency_code = rtx.txn_currency_code
					)
                	WHERE rtx.budget_version_id = p_budget_version_id
			AND EXISTS ( select null
					from pa_resource_asgn_curr_tmp tmp1
                                        where tmp1.resource_assignment_id = rtx.resource_assignment_id
                                        and tmp1.txn_currency_code = rtx.txn_currency_code
                                        );
	      End If;
        End If; --} end of refresh rates flag

      Else
        --BUDGET_LINE CONTEXT
        If NVL(p_calling_mode,'XXX') NOT IN ('CLEAR_CLOSED_PERIOD','RES_ATTRB_CHANGE','DELETE_BL') Then
        --print_msg('Inserting records in pa_resource_asgn_curr_tmp from rollup Tmp for BUDGET_LINE context');
        INSERT INTO pa_resource_asgn_curr_tmp raTxn
                        (RA_TXN_ID
            ,BUDGET_VERSION_ID
            ,RESOURCE_ASSIGNMENT_ID
                        ,TXN_CURRENCY_CODE
                        )
            SELECT 1 ra_txn_id
            ,p_budget_version_id
            ,tmp.resource_assignment_id
                        ,tmp.txn_currency_code
        FROM pa_fp_rollup_tmp tmp
        WHERE tmp.budget_version_id = p_budget_version_id
        GROUP BY p_budget_version_id
            ,tmp.resource_assignment_id
            ,tmp.txn_currency_code,1;
            l_rowCount  := sql%Rowcount;
            --print_msg('Number of records inserted ['||l_rowCount||']');
        End If;

        IF NVL(p_calling_mode,'XXX') IN ('CLEAR_CLOSED_PERIOD','RES_ATTRB_CHANGE','DELETE_BL') and  l_rowCount = 0 Then
            --print_msg('Inserting records in pa_resource_asgn_curr_tmp from sptmp for periodic deletion');
                INSERT INTO pa_resource_asgn_curr_tmp raTxn
                        (RA_TXN_ID
                        ,BUDGET_VERSION_ID
                        ,RESOURCE_ASSIGNMENT_ID
                        ,TXN_CURRENCY_CODE
                        )
                        SELECT 1 ra_txn_id
                        ,p_budget_version_id
                        ,tmp.resource_assignment_id
                        ,tmp.txn_currency_code
                FROM pa_fp_spread_calc_tmp tmp
                WHERE tmp.budget_version_id = p_budget_version_id
		AND tmp.resource_assignment_id = NVL(p_resource_assignment_id,tmp.resource_assignment_id)
		AND tmp.txn_currency_code = NVL(p_txn_currency_code,tmp.txn_currency_code)
		AND NVL(tmp.start_date,trunc(sysdate)) = NVL(p_start_date,nvl(tmp.start_date,trunc(sysdate)))
                AND ( NVL(tmp.delete_bl_flag,'N') = 'Y'
                    	OR NVL(tmp.sp_curve_change_flag,'N') = 'Y'
                	OR NVL(tmp.sp_fix_date_change_flag,'N') = 'Y'
                	OR NVL(tmp.rlm_id_change_flag,'N') = 'Y'
                	OR NVL(tmp.re_spread_amts_flag,'N') = 'Y'
                	OR p_calling_mode = 'CLEAR_CLOSED_PERIOD'
                	OR ((g_wp_version_flag = 'Y' AND NVL(tmp.plan_dates_change_flag,'N') = 'Y')
                   	OR (NVL(tmp.ra_in_multi_cur_flag,'N') = 'N' AND NVL(tmp.plan_dates_change_flag,'N') = 'Y'))
               		);

                        l_rowCount      := sql%Rowcount;
                        --print_msg('Number of records inserted ['||l_rowCount||']');
        End If;

        If l_rowCount > 0 Then
            /* The following update is required with current logic of the
            * new maintain entity which always blows out the records and inserts new records */
            UPDATE pa_resource_asgn_curr_tmp tmp
            SET (tmp.TXN_RAW_COST_RATE_OVERRIDE
                        ,tmp.TXN_BURDEN_COST_RATE_OVERRIDE
                        ,tmp.TXN_BILL_RATE_OVERRIDE) =
                (SELECT rtx.TXN_RAW_COST_RATE_OVERRIDE
                            ,rtx.TXN_BURDEN_COST_RATE_OVERRIDE
                            ,rtx.TXN_BILL_RATE_OVERRIDE
                FROM pa_resource_asgn_curr rtx
                WHERE rtx.resource_assignment_id = tmp.resource_assignment_id
                AND rtx.txn_currency_code = tmp.txn_currency_code
                )
            WHERE tmp.budget_version_id = p_budget_version_id
            AND EXISTS (select null from pa_resource_asgn_curr rtx2
                    where rtx2.resource_assignment_id = tmp.resource_assignment_id
                                    and rtx2.txn_currency_code = tmp.txn_currency_code
                   );
        End If;
        --Start for Bug 6781055.
        --As of now below block is added only for non-time phased versions.
        --It can be opened up for other flows after enough testing.
        IF gl_cl_roll_up_tmp_rowid_tab.COUNT>0 AND g_time_phased_code='N' AND p_calling_mode = 'UPDATE_PLAN_TRANSACTION' THEN
            FOR zz IN 1..gl_cl_roll_up_tmp_rowid_tab.COUNT  LOOP
                SELECT rw_cost_rate_override,
                       burden_cost_rate_override,
                       bill_rate_override,
                       resource_assignment_id,
                       txn_currency_code
                INTO   l_rw_cost_rate_override,
                       l_burden_cost_rate_override,
                       l_bill_rate_override,
                       l_ra_id,
                       l_txn_currency_code
                FROM   pa_fp_rollup_tmp
                WHERE  rowid=gl_cl_roll_up_tmp_rowid_tab(zz);

                UPDATE pa_resource_asgn_curr_tmp
                SET    txn_raw_cost_rate_override    = NVL(l_rw_cost_rate_override,txn_raw_cost_rate_override),
                       txn_burden_cost_rate_override = NVL(l_burden_cost_rate_override,txn_burden_cost_rate_override),
                       txn_bill_rate_override        = NVL(l_bill_rate_override,txn_bill_rate_override)
                WHERE  resource_assignment_id     = l_ra_id
                AND    txn_currency_code          = l_txn_currency_code;

            END LOOP;

            gl_cl_roll_up_tmp_rowid_tab.delete;

        END IF;
        --End for Bug 6781055.
      End If;
    ElsIf p_delete_flag = 'Y' Then
        /* when rollup is not required just delete from tmp table */
        DELETE FROM pa_resource_asgn_curr_tmp;
    END IF;

	/* only for debug purpose
    	for c in (select tmp.TXN_RAW_COST_RATE_OVERRIDE costRt
                        ,tmp.TXN_BURDEN_COST_RATE_OVERRIDE BurdRt
                        ,tmp.TXN_BILL_RATE_OVERRIDE  BillRt
            ,tmp1.cost_rate_override tmpCostRt
                        ,tmp1.burden_cost_rate_override tmpBurdRt
                        ,tmp1.bill_rate_override  tmpBillRt
            from pa_resource_asgn_curr_tmp tmp
                ,pa_fp_spread_calc_tmp tmp1) LOOP
        print_msg('Rates in Tmp Table CostRt['|| c.costRt||']BurdRt['||c.burdRt||']BillRt['||c.billRt||']');
        print_msg('Rates in SpCalcTmp Table tmpCostRt['|| c.tmpcostRt||']tmpBurdRt['||c.tmpburdRt||']tmpBillRt['||c.tmpbillRt||']');
    	end loop;
	*/

    /* When override currency is passed, then delete the records from new entity for the old currency */
    If p_source_context = 'RESOURCE_ASSIGNMENT' and NVL(p_refresh_rate_flag,'N') = 'N' Then
        --print_msg('Inserting records in pa_resource_asgn_curr_tmp from rollup for Override currency code');
        INSERT INTO pa_resource_asgn_curr_tmp raTxn
                        (RA_TXN_ID
                        ,BUDGET_VERSION_ID
                        ,RESOURCE_ASSIGNMENT_ID
                        ,TXN_CURRENCY_CODE
            		,DELETE_FLAG
                        )
                        SELECT 1 ra_txn_id
                        ,p_budget_version_id
                        ,tmp.resource_assignment_id
                        ,tmp.txn_currency_code
            		,'Y'
        FROM pa_fp_spread_calc_tmp tmp
        WHERE tmp.budget_version_id = p_budget_version_id
        AND tmp.txn_curr_code_override is NOT NULL
        AND tmp.txn_curr_code_override <> tmp.txn_currency_code;
        l_rowCount1      := sql%Rowcount;
                --print_msg('Number of records inserted ['||l_rowCount1||']');

        -- gboomina added for AAI requirement Bug 8318932 - start
         OPEN get_copy_etc_from_plan_csr;
         FETCH get_copy_etc_from_plan_csr INTO l_copy_etc_from_plan_flag;
         CLOSE get_copy_etc_from_plan_csr;
         -- skkoppul added for AAI requirement - end

         --AAI Requirement Setting override rates to null for amounts generated from source when copy actuals
         -- selected .
         IF nvl(l_copy_etc_from_plan_flag,'N') = 'Y' AND p_source_context = 'RESOURCE_ASSIGNMENT'
         AND p_calling_mode = 'FORECAST_GENERATION' THEN

             UPDATE pa_resource_asgn_curr rtx
             SET rtx.TXN_RAW_COST_RATE_OVERRIDE  = NULL
                  ,rtx.TXN_BURDEN_COST_RATE_OVERRIDE = NULL
             WHERE rtx.budget_version_id = p_budget_version_id;
         END IF;
        -- gboomina added for AAI requirement Bug 8318932 - end

        If l_rowCount1 > 0 Then
	    If P_PA_DEBUG_MODE = 'Y' Then
            print_msg('Calling pa_res_asg_currency_pub.maintain_data for deleting records');
	    End If;
            pa_res_asg_currency_pub.MAINTAIN_DATA
                    (P_FP_COLS_REC          => G_FP_COLS_REC
                    ,P_CALLING_MODULE       => 'CALCULATE_API'
                    ,P_DELETE_FLAG          => 'Y'
                    ,P_ROLLUP_FLAG          => 'N'
                    ,P_VERSION_LEVEL_FLAG   => 'N'
                    ,X_RETURN_STATUS        => x_return_status
                    ,X_MSG_COUNT            => x_msg_count
                    ,X_MSG_DATA             => x_msg_data
                    );
	    If P_PA_DEBUG_MODE = 'Y' Then
            print_msg('Return Status of the api ['||x_return_status||']');
	    End If;
        End If;

    End If;

    IF p_call_raTxn_rollup_flag = 'Y' AND l_rowCount > 0 Then
        -- Call new entity rollup api
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Calling pa_res_asg_currency_pub.maintain_data');
	End If;
        pa_res_asg_currency_pub.MAINTAIN_DATA
        (P_FP_COLS_REC      => G_FP_COLS_REC
        ,P_CALLING_MODULE   => 'CALCULATE_API'
        ,P_DELETE_FLAG      => 'N'
        ,P_ROLLUP_FLAG      => 'Y' --p_rollup_flag
        ,P_VERSION_LEVEL_FLAG   => 'N'
        ,X_RETURN_STATUS        => x_return_status
        ,X_MSG_COUNT            => x_msg_count
        ,X_MSG_DATA             => x_msg_data
        );
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Return Status of the api ['||x_return_status||']');
	End If;
        IF nvl(X_RETURN_STATUS,'S') <> 'S' Then
            X_RETURN_STATUS := 'E';
        END IF;

    END IF;

EXCEPTION
        WHEN OTHERS THEN
                print_msg('Errored in populate_raTxn_Recs:'||sqlcode||sqlerrm);
            	x_return_status := 'U';
		x_msg_data := SQLCODE||SQLERRM;
                RAISE;
END populate_raTxn_Recs;

/* Bug fix: 4900436 */
/* After the spread of quantity, this API copies the rate overrides from new entity pa_resource_asgn_curr
 * to rollup tmp table.
 */
PROCEDURE RETAIN_RA_TXN_OVR_RATES
                        (p_budget_version_id    IN VARCHAR2
                        ,x_return_status        OUT NOCOPY VARCHAR2
                        ) IS
BEGIN
    x_return_status := 'S';
	IF p_pa_debug_mode = 'Y' Then
                print_rlTmp_Values;
        End If;
    UPDATE pa_fp_rollup_tmp tmp
    SET (tmp.rw_cost_rate_override
        ,tmp.burden_cost_rate_override
        ,tmp.bill_rate_override ) =
        (SELECT /*+ INDEX(RAX PA_RESOURCE_ASGN_CURR_U2) */
	    decode(nvl(tmp1.cost_rate_g_miss_num_flag,'N'),'Y',NULL,nvl(tmp.rw_cost_rate_override,rax.txn_raw_cost_rate_override))
               ,decode(nvl(tmp1.burden_rate_g_miss_num_flag,'N'),'Y',NULL
		    ,decode(nvl(tmp1.rate_based_flag,'N'),'Y',nvl(tmp.burden_cost_rate_override,rax.txn_burden_cost_rate_override)
		       ,decode(g_fp_budget_version_type,'REVENUE',nvl(tmp.burden_cost_rate_override,rax.txn_burden_cost_rate_override)
			,'COST',nvl(tmp.burden_cost_rate_override,rax.txn_burden_cost_rate_override)
			,'ALL'
			,decode(tmp1.burden_cost_changed_flag,'Y'
			 ,decode(tmp1.burden_cost_rate_override,0,0
			  ,decode(nvl(tmp.burden_cost_rate_override,rax.txn_burden_cost_rate_override),0,NULL
					,nvl(tmp.burden_cost_rate_override,rax.txn_burden_cost_rate_override)))
			  ,decode(tmp1.raw_cost_changed_flag,'Y'
                           ,decode(nvl(tmp.burden_cost_rate_override,rax.txn_burden_cost_rate_override),0,NULL
                                        ,nvl(tmp.burden_cost_rate_override,rax.txn_burden_cost_rate_override))
				,nvl(tmp.burden_cost_rate_override,rax.txn_burden_cost_rate_override))))))
               ,decode(nvl(tmp1.bill_rate_g_miss_num_flag,'N'),'Y',NULL
			,decode(nvl(tmp1.rate_based_flag,'N'),'Y',nvl(tmp.bill_rate_override,rax.txn_bill_rate_override)
			 ,decode(tmp1.revenue_changed_flag,'Y',nvl(tmp.bill_rate_override,rax.txn_bill_rate_override)
			 ,decode(g_fp_budget_version_type,'COST',tmp.bill_rate_override
				,'REVENUE',nvl(tmp.bill_rate_override,rax.txn_bill_rate_override)
				,'ALL',decode(tmp1.raw_cost_changed_flag,'Y'
					,decode(nvl(tmp.bill_rate_override,rax.txn_bill_rate_override),1,NULL
						,0,NULL,nvl(tmp.bill_rate_override,rax.txn_bill_rate_override))
					,decode(tmp1.burden_cost_changed_flag,'Y'
					 ,decode(tmp1.txn_raw_cost,tmp1.txn_burdened_cost
					  ,decode(nvl(tmp.bill_rate_override,rax.txn_bill_rate_override),1,NULL
                                                ,0,NULL,nvl(tmp.bill_rate_override,rax.txn_bill_rate_override))
						,nvl(tmp.bill_rate_override,rax.txn_bill_rate_override))
					  ,nvl(tmp.bill_rate_override,rax.txn_bill_rate_override)))))))
        FROM    pa_resource_asgn_curr rax
               ,pa_fp_spread_calc_tmp tmp1
        WHERE rax.resource_assignment_id = tmp.resource_assignment_id
        AND   rax.txn_currency_code = tmp.txn_currency_code
        AND   tmp1.resource_assignment_id = rax.resource_assignment_id
        AND   tmp1.txn_currency_code = rax.txn_currency_code
        AND   (g_source_context = 'RESOURCE_ASSIGNMENT'
	       OR
		(g_source_context = 'BUDGET_LINE'
		 and tmp.start_date between tmp1.start_date and tmp1.end_date)
	     )
        )
    WHERE tmp.budget_version_id = p_budget_version_id
    AND EXISTS (select /*+ INDEX(RAX1 PA_RESOURCE_ASGN_CURR_U2) */ null
                from   pa_resource_asgn_curr rax1
                      ,pa_fp_spread_calc_tmp tmp2
                where rax1.resource_assignment_id = tmp.resource_assignment_id
                and rax1.txn_currency_code = tmp.txn_currency_code
                and tmp2.resource_assignment_id = rax1.resource_assignment_id
                and tmp2.txn_currency_code = rax1.txn_currency_code
	        and   (g_source_context = 'RESOURCE_ASSIGNMENT'
               		OR
                	(g_source_context = 'BUDGET_LINE'
                 	and tmp.start_date between tmp2.start_date and tmp2.end_date)
              		)
           );

	IF p_pa_debug_mode = 'Y' Then
    		print_msg('Number of rows updated in the rollup tmp with raTxnOvr ['||sql%rowCount||']');
		--print_rlTmp_Values;
		NULL;
	End If;
EXCEPTION
        WHEN OTHERS THEN
                print_msg('Errored in retain_ra_txn_ovr_rates:'||sqlcode||sqlerrm);
                x_return_status := 'U';
                RAISE;
END RETAIN_RA_TXN_OVR_RATES;

/* Bug fix:4229022 Performance fix: call copyBlattributs API only if records in the cacle table exists
 * This avoids un-neccessary hitting of budget lines table during copy projects call
 */
FUNCTION CheckCacheRecExists(p_budget_version_id IN NUMBER)
    RETURN VARCHAR2 IS
    l_exists_flag Varchar2(10) := 'N';
BEGIN
    SELECT 'Y'
    INTO l_exists_flag
    FROM DUAL
    WHERE EXISTS (select null
            from pa_fp_spread_calc_tmp1 tmp1
            where tmp1.budget_version_id = p_budget_version_id
        );
    RETURN NVL(l_exists_flag,'N');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        l_exists_flag := 'N';
        RETURN l_exists_flag;

    WHEN OTHERS THEN
        l_exists_flag := 'N';
        RAISE;
END CheckCacheRecExists;

/* This API rounds the given quantity to 5 decimals. This api should be called
 * only for rate based planning resource to round the quantity
 */
FUNCTION round_quantity(p_quantity Number) RETURN NUMBER IS
    l_quantity Number;
BEGIN
    l_quantity := p_quantity;
    If p_quantity is NOT NULL Then
        l_quantity := round(p_quantity,5);
    End If;

    RETURN l_quantity;

END round_quantity;

/* This API checks whether MRC is installed for PA schema or not */
PROCEDURE CHECK_MRC_INSTALLED IS

    l_return_status  Varchar2(10);
    l_msg_count      Number := 0;
    l_msg_data       Varchar2(1000);
BEGIN
    l_return_status := 'S';
    /********Commented for 11.5.10+ change. MRC installed flag is no longer populated/supported by AD Team********
    SELECT nvl(multi_currency_flag,'N')
    INTO G_MRC_INSTALLED_FLAG
    FROM fnd_product_groups
    WHERE  product_group_id=1;

    --Added this check that does the same job as the above select
    IF  gl_mc_info.mrc_enabled(275) THEN
            G_MRC_INSTALLED_FLAG := 'Y';
    ELSE
            G_MRC_INSTALLED_FLAG := 'N';
    END IF;
    ********Commented for 11.5.10+ change. MRC installed flag is no longer populated/supported by AD Team********/

    /* As per mail from venkatesh calling this API instead of standard one using in the costing and billing */
    /****MRC Elimination changes: As we are dropping the mrc_finplan package no need to call this api
    IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
        print_msg('Calling PA_MRC_FINPLAN.CHECK_MRC_INSTALL api');
                PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                        (x_return_status      => l_return_status
                         ,x_msg_count          => l_msg_count
                         ,x_msg_data           => l_msg_data);
        END IF;
    IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS THEN
        G_MRC_INSTALLED_FLAG := 'Y';
    ELSE
        G_MRC_INSTALLED_FLAG := 'N';
    END IF;
    *********/
    G_MRC_INSTALLED_FLAG := 'N';
    --print_msg('retSts['||l_return_status||']Mrc Flag['||G_MRC_INSTALLED_FLAG||']');

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END CHECK_MRC_INSTALLED;

/* This API will set the statistics for global tmp tables. Since Gather_statistics and set_table_stats
 * does the commit in the main session, this api made as autonomous so that main session should not be impacted.
 * Based on the statistics collected for the pa_budget_lines and pa_resource_assignments on pjperf table
 * the tmp table stats will be set as follows
 * If number of rows < 500 then set the number of rows = 500 and num blocks to number of rows/30
 * if number of rows > 500 then set the number of rows to passed in value and block size to numrows / 30
 * This API will be called only once for all tmp tables
 */
PROCEDURE SetGatherTmpTblIndxStats
        (p_table_name    IN VARCHAR2
        ,p_numRow    IN NUMBER
        ,x_return_status OUT NOCOPY VARCHAR2 ) IS

    l_numRows     Number := p_numRow;
    l_AvgRowLg    Number := 150;
    l_num_blks    Number ;
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    x_return_status := 'S';
    --print_msg('Entered SetGatherTmpTblIndxStats API');
    IF g_owner_name is NULL Then
        g_owner_name   := PJI_UTILS.GET_PA_SCHEMA_NAME;
    End If;
    If NVL(l_numRows,0) < 500 Then
        l_numRows := 500;
    End If;
    l_num_blks :=  ROUND((l_numRows / 30));
    IF p_table_name IS NOT NULL Then
        /* Calling Gather_table_stats implicitly commits the data so changed to set_table_stats
        FND_STATS.GATHER_TABLE_STATS
        (ownname    => g_owner_name
                 ,tabname   => UPPER(p_table_name)
                 ,cascade   => TRUE
                 ,percent  in number
                 ,degree in number
                 ,partname in varchar2
                 ,backup_flag  in varchar2
                 ,granularity in varchar2
                 ,hmode in varchar2  default 'LASTRUN'
                 ,invalidate    in varchar2 default 'Y'
                 );
        */
        print_msg('Calling set Table Stats API for ['||p_table_name||']');
        FND_STATS.SET_TABLE_STATS
        	(ownname    => g_owner_name
                ,tabname    => UPPER(p_table_name)
                ,numrows    => l_numRows
                ,numblks    => l_num_blks
                ,avgrlen    => l_AvgRowLg
        	);

    END IF;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := 'U';
        fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                 ,p_procedure_name => 'SetGatherTmpTblIndxStats' );
                print_msg('Failed in SetGatherTmpTblIndxStats substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
        ROLLBACK;
        RAISE;
END SetGatherTmpTblIndxStats;

/* This API initializes the currency attributes based on the budget version and project Id
 * this section of code is moved from convert_ra_txn_currency api to here to avoid executing the sql
 * opening cursors for each budget line record in a loop.
 * this api is added to improve to improve the performance */
PROCEDURE Initialize_fp_cur_details
        (p_budget_version_id  IN  Number
        ,p_project_id         IN  Number
        ,x_return_status      OUT NOCOPY varchar2
         ) IS

        CURSOR get_fp_options_data IS
        SELECT v.project_id
            ,v.fin_plan_type_id
            ,o.projfunc_cost_rate_type
            ,o.projfunc_cost_rate_date_type
            ,o.projfunc_cost_rate_date
            ,o.projfunc_rev_rate_type
            ,o.projfunc_rev_rate_date_type
            ,o.projfunc_rev_rate_date
            ,o.project_cost_rate_type
            ,o.project_cost_rate_date_type
            ,o.project_cost_rate_date
            ,o.project_rev_rate_type
            ,o.project_rev_rate_date_type
            ,o.project_rev_rate_date
        FROM    pa_proj_fp_options o
                ,pa_budget_versions v
        WHERE v.budget_version_id   = p_budget_version_id
        AND o.project_id          = v.project_id
        AND nvl(o.fin_plan_type_id,0)    = nvl(v.fin_plan_type_id,0)
        AND o.fin_plan_version_id = v.budget_version_id;

        CURSOR get_project_lvl_data IS
        SELECT segment1
                ,project_currency_code
                ,projfunc_currency_code
        FROM pa_projects_all
        WHERE project_id = p_project_id;
BEGIN
    x_return_status := 'S';
    g_stage := 'Initialize_fp_cur_details:100';
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg(' ENTERED  Initialize_fp_cur_details calling get_fp_options_data');
	End If;
             -- initialize --
           pa_fp_multi_currency_pkg.g_project_id                     := NULL;
           pa_fp_multi_currency_pkg.g_fin_plan_type_id               := NULL;
           pa_fp_multi_currency_pkg.g_projfunc_cost_rate_type        := NULL;
           pa_fp_multi_currency_pkg.g_projfunc_cost_rate_date_type   := NULL;
           pa_fp_multi_currency_pkg.g_projfunc_cost_rate_date        := NULL;
           pa_fp_multi_currency_pkg.g_projfunc_rev_rate_type         := NULL;
           pa_fp_multi_currency_pkg.g_projfunc_rev_rate_date_type    := NULL;
           pa_fp_multi_currency_pkg.g_projfunc_rev_rate_date         := NULL;
           pa_fp_multi_currency_pkg.g_proj_cost_rate_type            := NULL;
           pa_fp_multi_currency_pkg.g_proj_cost_rate_date_type       := NULL;
           pa_fp_multi_currency_pkg.g_proj_cost_rate_date            := NULL;
           pa_fp_multi_currency_pkg.g_proj_rev_rate_type             := NULL;
           pa_fp_multi_currency_pkg.g_proj_rev_rate_date_type        := NULL;
           pa_fp_multi_currency_pkg.g_proj_rev_rate_date             := NULL;

        OPEN get_fp_options_data;
        FETCH get_fp_options_data INTO
            pa_fp_multi_currency_pkg.g_project_id
           ,pa_fp_multi_currency_pkg.g_fin_plan_type_id
           ,pa_fp_multi_currency_pkg.g_projfunc_cost_rate_type
           ,pa_fp_multi_currency_pkg.g_projfunc_cost_rate_date_type
           ,pa_fp_multi_currency_pkg.g_projfunc_cost_rate_date
           ,pa_fp_multi_currency_pkg.g_projfunc_rev_rate_type
           ,pa_fp_multi_currency_pkg.g_projfunc_rev_rate_date_type
           ,pa_fp_multi_currency_pkg.g_projfunc_rev_rate_date
           ,pa_fp_multi_currency_pkg.g_proj_cost_rate_type
           ,pa_fp_multi_currency_pkg.g_proj_cost_rate_date_type
           ,pa_fp_multi_currency_pkg.g_proj_cost_rate_date
           ,pa_fp_multi_currency_pkg.g_proj_rev_rate_type
           ,pa_fp_multi_currency_pkg.g_proj_rev_rate_date_type
           ,pa_fp_multi_currency_pkg.g_proj_rev_rate_date;
        CLOSE get_fp_options_data;
    g_stage := 'Initialize_fp_cur_details:101';

        print_msg('In Initialize_fp_cur_details Get Project Levle info');
             -- initialize --
         pa_fp_multi_currency_pkg.g_project_number         := NULL;
         pa_fp_multi_currency_pkg.g_proj_currency_code     := NULL;
         pa_fp_multi_currency_pkg.g_projfunc_currency_code := NULL;

        OPEN get_project_lvl_data;
        FETCH get_project_lvl_data INTO
          pa_fp_multi_currency_pkg.g_project_number
         ,pa_fp_multi_currency_pkg.g_proj_currency_code
         ,pa_fp_multi_currency_pkg.g_projfunc_currency_code;
        ClOSE get_project_lvl_data;
    g_stage := 'Initialize_fp_cur_details:102';
    RETURN;

EXCEPTION
    WHEN OTHERS THEN
    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                 ,p_procedure_name => 'initialize_fp_cur_details' );
                print_msg('Failed in initialize_fp_cur_details substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
    RAISE;

END initialize_fp_cur_details;

PROCEDURE Init_MRC_plsqlTabs IS

BEGIN
	--G_FP_MRC_TAB.DELETE;
	g_mrc_budget_line_id_tab.delete;
	g_mrc_res_assignment_id_tab.delete;
        g_mrc_txn_curr_code_tab.delete;
        g_mrc_start_date_tab.delete;
        g_mrc_end_date_tab.delete;
        g_mrc_period_name_tab.delete;
        g_mrc_quantity_tab.delete;
        g_mrc_txn_raw_cost_tab.delete;
        g_mrc_txn_burden_cost_tab.delete;
        g_mrc_txn_revenue_tab.delete;
        g_mrc_project_curr_code_tab.delete;
        g_mrc_project_raw_cost_tab.delete;
        g_mrc_project_burden_cost_tab.delete;
        g_mrc_project_revenue_tab.delete;
        g_mrc_projfunc_curr_code_tab.delete;
        g_mrc_projfunc_raw_cost_tab.delete;
        g_mrc_projfunc_burden_cost_tab.delete;
        g_mrc_projfunc_revenue_tab.delete;
        g_mrc_delete_flag_tab.delete;
        g_mrc_Billable_flag_tab.delete;
        g_mrc_project_cst_rt_type_tab.delete;
        g_mrc_project_cst_exg_rt_tab.delete;
        g_mrc_project_cst_dt_type_tab.delete;
        g_mrc_project_cst_rt_dt_tab.delete;
        g_mrc_project_rev_rt_type_tab.delete;
        g_mrc_project_rev_exg_rt_tab.delete;
        g_mrc_project_rev_dt_type_tab.delete;
        g_mrc_project_rev_rt_dt_tab.delete;
        g_mrc_projfunc_cst_rt_type_tab.delete;
        g_mrc_projfunc_cst_exg_rt_tab.delete;
        g_mrc_projfunc_cst_dt_type_tab.delete;
        g_mrc_projfunc_cst_rt_dt_tab.delete;
        g_mrc_projfunc_rev_rt_type_tab.delete;
        g_mrc_projfunc_rev_exg_rt_tab.delete;
        g_mrc_projfunc_rev_dt_type_tab.delete;
        g_mrc_projfunc_rev_rt_dt_tab.delete;

END Init_MRC_plsqlTabs;


        /*Bug: 4309290.Added the parameter to identify if PA_FP_SPREAD_CALC_TMP1
        is to be deleted or not. Frm AMG flow we will pass N and for
        other calls to calculate api it would be yes*/
PROCEDURE Init_SpreadCalc_Tbls(p_del_spread_calc_tmp1_flg IN VARCHAR2 := 'Y')
IS
	l_return_status 	Varchar2(10);
	l_unexpected_exception	Exception;
BEGIN

    --INITIALIZATION--
        DELETE FROM pa_fp_res_assignments_tmp;
        DELETE FROM pa_fp_rollup_tmp;
        DELETE FROM pa_fp_spread_calc_tmp;
	DELETE FROM pa_resource_asgn_curr_tmp;

        --Bug 4309290.using the new introuced parameter p_del_spread_calc_tmp1_flg to determine delete on pa_fp_spread_calc_tmp1
        IF (p_del_spread_calc_tmp1_flg = 'Y') then

            	DELETE FROM pa_fp_spread_calc_tmp1;
        ELSE
          /* Bug fix:4272944: The following new api call is added to insert zero qty budget lines for Funding baseline */
          IF (NVL(G_baseline_funding_flag,'N') = 'Y'
                AND NVL(g_bv_approved_rev_flag,'N') = 'Y') THEN
		If P_PA_DEBUG_MODE = 'Y' Then
                print_msg('Calling PA_FP_CALC_UTILS.InsertFunding_ReqdLines API');
		End If;
                PA_FP_CALC_UTILS.InsertFunding_ReqdLines
                ( p_budget_verson_id      => g_budget_version_id
                ,p_source_context         => g_source_context
                ,p_calling_module         => g_calling_module
                ,p_apply_progress_flag    => 'N'
                ,p_approved_rev_flag      => g_bv_approved_rev_flag
                ,p_autoBaseLine_flag      => G_baseline_funding_flag
                ,x_return_status          => l_return_status
                );
		If NVL(l_return_status,'S') <> 'S' Then
			RAISE l_unexpected_exception;
		End If;
                DELETE FROM pa_fp_spread_calc_tmp1;
          END IF;
	  null;
        END IF;

        DELETE FROM pa_fp_spread_calc_tmp2;
        g_sprd_raId_tab.delete;
        g_sprd_txn_cur_tab.delete;
        g_sprd_sdate_tab.delete;
        g_sprd_edate_tab.delete;
        g_sprd_plan_sdate_tab.delete;
        g_sprd_plan_edate_tab.delete;
        g_sprd_txn_rev_tab.delete;
        g_sprd_txn_rev_addl_tab.delete;
        g_sprd_txn_raw_tab.delete;
        g_sprd_txn_raw_addl_tab.delete;
        g_sprd_txn_burd_tab.delete;
        g_sprd_txn_burd_addl_tab.delete;
        g_sprd_qty_tab.delete;
        g_sprd_qty_addl_tab.delete;
        g_sprd_txn_cur_ovr_tab.delete;
        g_sprd_txn_init_rev_tab.delete;
        g_sprd_txn_init_raw_tab.delete;
        g_sprd_txn_init_burd_tab.delete;
        g_sprd_txn_init_qty_tab.delete;
        g_sprd_spread_reqd_flag_tab.delete;
        g_sprd_costRt_tab.delete;
        g_sprd_costRt_Ovr_tab.delete;
        g_sprd_burdRt_Tab.delete;
        g_sprd_burdRt_Ovr_tab.delete;
        g_sprd_billRt_tab.delete;
        g_sprd_billRt_Ovr_tab.delete;
        g_sprd_ratebase_flag_tab.delete;
        g_sprd_projCur_tab.delete;
        g_sprd_projfuncCur_tab.delete;
    	g_sprd_task_id_tab.delete;
        g_sprd_rlm_id_tab.delete;
        g_sprd_sp_fixed_date_tab.delete;
        g_sprd_spcurve_id_tab.delete;
	g_sprd_cstRtmissFlag_tab.delete;
        g_sprd_bdRtmissFlag_tab.delete;
        g_sprd_bilRtmissFlag_tab.delete;
        g_sprd_QtymissFlag_tab.delete;
        g_sprd_RawmissFlag_tab.delete;
        g_sprd_BurdmissFlag_tab.delete;
        g_sprd_RevmissFlag_tab.delete;
	/* bug fix:5726773 */
 	g_sprd_neg_Qty_Changflag_tab.delete;
 	g_sprd_neg_Raw_Changflag_tab.delete;
 	g_sprd_neg_Burd_Changflag_tab.delete;
 	g_sprd_neg_rev_Changflag_tab.delete;
        /* The following plsql tables defined for bulk processing of rollup tmp for refresh action */
        g_plan_raId_tab.delete;
        g_plan_txnCur_Tab.delete;
        g_line_sdate_tab.delete;
        g_line_edate_tab.delete;
        g_Wp_curCode_tab.delete;
        g_refresh_rates_tab.delete;
        g_refresh_conv_rates_tab.delete;
        g_mass_adjust_flag_tab.delete;
        g_mfc_cost_refresh_tab.delete;
        g_skip_record_tab.delete;
	g_process_skip_CstRevrec_tab.delete;
        g_mfc_cost_refrsh_Raid_tab.delete;
        g_mfc_cost_refrsh_txnCur_tab.delete;

    /* The following plsql tables are defined for bulk processing of resource where rates are only changed */
    	g_rtChanged_Ra_Flag_tab.delete;
    	g_rtChanged_RaId_tab.delete;
        g_rtChanged_TxnCur_tab.delete;
    	g_rtChanged_sDate_tab.delete;
        g_rtChanged_eDate_tab.delete;
        g_rtChanged_CostRt_Tab.delete;
        g_rtChanged_BurdRt_tab.delete;
        g_rtChanged_billRt_tab.delete;
	g_rtChanged_cstMisNumFlg_tab.delete;
        g_rtChanged_bdMisNumFlag_tab.delete;
        g_rtChanged_blMisNumFlag_tab.delete;
        g_rtChanged_QtyMisNumFlg_tab.delete;
        g_rtChanged_RwMisNumFlag_tab.delete;
        g_rtChanged_BrMisNumFlag_tab.delete;
        g_rtChanged_RvMisNumFlag_tab.delete;

    	g_applyProg_refreshRts_tab.delete;
    	g_applyProg_RaId_tab.delete;
        g_applyProg_TxnCur_tab.delete;

EXCEPTION
	WHEN l_unexpected_exception THEN
	    RAISE;
        WHEN OTHERS THEN
            RAISE;
END ;
/* Initialize reporting tbls */
PROCEDURE Init_reporting_Tbls IS

BEGIN
    g_rep_budget_line_id_tab.delete;
        g_rep_res_assignment_id_tab .delete;
        g_rep_start_date_tab.delete;
        g_rep_end_date_tab.delete;
        g_rep_period_name_tab.delete;
        g_rep_txn_curr_code_tab.delete;
        g_rep_quantity_tab.delete;
        g_rep_txn_raw_cost_tab.delete;
        g_rep_txn_burdened_cost_tab.delete;
        g_rep_txn_revenue_tab.delete;
        g_rep_project_curr_code_tab.delete;
        g_rep_project_raw_cost_tab.delete;
        g_rep_project_burden_cost_tab.delete;
        g_rep_project_revenue_tab.delete;
        g_rep_projfunc_curr_code_tab.delete;
        g_rep_projfunc_raw_cost_tab.delete;
        g_rep_projfunc_burden_cost_tab.delete;
        g_rep_projfunc_revenue_tab.delete;
	g_rep_line_mode_tab.delete;
        g_rep_rate_base_flag_tab.delete;

END ;
/* This API adds the message to error stack */
PROCEDURE ADD_MSGTO_STACK(
     P_MSG_NAME    IN VARCHAR2
    ,p_token1      IN Varchar2 default null
    ,p_value1      IN Varchar2 default null
    ,p_token2      IN Varchar2 default null
    ,p_value2      IN Varchar2 default null
    ,p_token3      IN Varchar2 default null
    ,p_value3      IN Varchar2 default null
    ,p_token4      IN Varchar2 default null
    ,p_value4      IN Varchar2 default null
    ,p_token5      IN Varchar2 default null
    ,p_value5      IN Varchar2 default null
    ) IS

BEGIN
    If P_MSG_name is NOT NULL Then
       pa_utils.add_message
            ( p_app_short_name => 'PA'
              ,p_msg_name       => P_MSG_NAME
            ,p_token1       => p_token1
            ,p_value1       => p_value1
            ,p_token2       => p_token2
            ,p_value2       => p_value2
            ,p_token3       => p_token3
            ,p_value3       => p_value3
            ,p_token4       => p_token4
            ,p_value4       => p_value4
            ,p_token5       => p_token5
            ,p_value5       => p_value5
        );

    End If;

EXCEPTION
    WHEN OTHERS THEN
        PRINT_MSG('Unexpected Error occured while adding msg to Error Stack:'||SQLCODE||SQLERRM);
        RAISE;
END ADD_MSGTO_STACK;

/* This API returns the return status of the fprollup tmp table
 * after calling the rate api and converting the txn to txn currency conv
 * if there is any errors the abort the process
 */
PROCEDURE get_RollupTmp_Status(
        x_return_status OUT NOCOPY varchar2 ) IS

        CURSOR cur_retSts IS
        SELECT 'E'
        FROM DUAL
        WHERE EXISTS (select null
                        from pa_fp_rollup_tmp tmp
                        where ( tmp.cost_rejection_code in ('PA_FP_PROJ_NO_TXNCONVRATE'
                                                        ,'PA_FP_PRJFUNC_CURR_NULL'
                                                        ,'PA_FP_PRJ_CURR_NULL'
                            ,'PA_FP_ERROR_FROM_RATE_API_CALL' )
                                OR tmp.revenue_rejection_code in ('PA_FP_PROJ_NO_TXNCONVRATE'
                                                        ,'PA_FP_PRJFUNC_CURR_NULL'
                                                        ,'PA_FP_PRJ_CURR_NULL'
                            ,'PA_FP_ERROR_FROM_RATE_API_CALL')
                             ));

    l_return_status  Varchar2(100);
BEGIN
    l_return_status := 'S';

        /* set final return status to E if there are any txn cur conv failuresi*/
        OPEN cur_retSts;
        FETCH cur_retSts INTO l_return_status;
    IF cur_retSts%NOTFOUND then
        l_return_status := 'S';
    End If;
        CLOSE cur_retSts;

    l_return_status := NVL(l_return_status,'S');
    x_return_status := l_return_status;

END get_RollupTmp_status;

/* This API builds plsql table of records required for MRC conversions
 */
PROCEDURE Populate_MRC_plsqlTabs
                (p_calling_module               IN      Varchar2 Default 'CALCULATE_API'
                ,p_budget_version_id            IN      Number
                ,p_budget_line_id               IN      Number
                ,p_resource_assignment_id       IN      Number
                ,p_start_date                   IN      Date
                ,p_end_date                     IN      Date
                ,p_period_name                  IN      Varchar2 Default NULL
                ,p_txn_currency_code            IN      Varchar2
                ,p_quantity                     IN      Number   Default NULL
                ,p_txn_raw_cost                 IN      Number   Default NULL
                ,p_txn_burdened_cost            IN      Number   Default NULL
                ,p_txn_revenue                  IN      Number   Default NULL
                ,p_project_currency_code        IN      Varchar2 Default NULL
                ,p_project_raw_cost             IN      Number   Default NULL
                ,p_project_burdened_cost        IN      Number   Default NULL
                ,p_project_revenue              IN      Number   Default NULL
                ,p_projfunc_currency_code       IN      Varchar2 Default NULL
                ,p_projfunc_raw_cost            IN      Number   Default NULL
                ,p_projfunc_burdened_cost       IN      Number   Default NULL
                ,p_projfunc_revenue             IN      Number   Default NULL
		,p_delete_flag                  IN      Varchar2 := 'N'
		,p_billable_flag                IN      Varchar2 := 'Y'
		,p_project_cost_rate_type	IN      Varchar2 default NULL
                ,p_project_cost_exchange_rate	IN      Number   default NULL
                ,p_project_cost_rate_date_type  IN      Varchar2 default NULL
                ,p_project_cost_rate_date	IN      Date     default NULL
                ,p_project_rev_rate_type	IN      Varchar2 default NULL
                ,p_project_rev_exchange_rate	IN      Number   default NULL
                ,p_project_rev_rate_date_type   IN      Varchar2 default NULL
                ,p_project_rev_rate_date	IN      Date     default NULL
                ,p_projfunc_cost_rate_type      IN      Varchar2 default NULL
                ,p_projfunc_cost_exchange_rate	IN      Number   default NULL
                ,p_projfunc_cost_rate_date_type IN      Varchar2 default NULL
                ,p_projfunc_cost_rate_date	IN      Date     default NULL
                ,p_projfunc_rev_rate_type       IN      Varchar2 default NULL
                ,p_projfunc_rev_exchange_rate	IN      Number   default NULL
                ,p_projfunc_rev_rate_date_type  IN      Varchar2 default NULL
                ,p_projfunc_rev_rate_date	IN      Date     default NULL
                ,x_msg_data                     OUT NOCOPY Varchar2
                ,x_return_status                OUT NOCOPY Varchar2
                ) IS

    	l_msg_count   Number :=0;
BEGIN
	x_msg_data        := NULL;
        l_msg_count       := 0;
        x_return_status   := 'S';

	IF NVL(G_populate_mrc_tab_flag,'N') = 'Y' Then
	g_mrc_budget_line_id_tab(NVL(g_mrc_budget_line_id_tab.LAST,0)+1) := p_budget_line_id;
	g_mrc_res_assignment_id_tab(NVL( g_mrc_res_assignment_id_tab.LAST,0)+1) := p_resource_assignment_id;
        g_mrc_txn_curr_code_tab(NVL( g_mrc_txn_curr_code_tab.LAST,0)+1)      := p_txn_currency_code;
        g_mrc_start_date_tab(NVL( g_mrc_start_date_tab.LAST,0)+1)             := p_start_date;
        g_mrc_end_date_tab(NVL( g_mrc_end_date_tab.LAST,0)+1)               := p_end_date;
        g_mrc_period_name_tab(NVL( g_mrc_period_name_tab.LAST,0)+1)            := p_period_name;
        g_mrc_quantity_tab(NVL( g_mrc_quantity_tab.LAST,0)+1)               := p_quantity;
        g_mrc_txn_raw_cost_tab(NVL( g_mrc_txn_raw_cost_tab.LAST,0)+1)           := p_txn_raw_cost;
        g_mrc_txn_burden_cost_tab(NVL( g_mrc_txn_burden_cost_tab.LAST,0)+1)      := p_txn_burdened_cost;
        g_mrc_txn_revenue_tab(NVL( g_mrc_txn_revenue_tab.LAST,0)+1)            := p_txn_revenue;
        g_mrc_project_curr_code_tab(NVL( g_mrc_project_curr_code_tab.LAST,0)+1)  := p_project_currency_code;
        g_mrc_project_raw_cost_tab(NVL( g_mrc_project_raw_cost_tab.LAST,0)+1)       := p_project_raw_cost;
        g_mrc_project_burden_cost_tab(NVL( g_mrc_project_burden_cost_tab.LAST,0)+1)    := p_project_burdened_cost;
        g_mrc_project_revenue_tab(NVL( g_mrc_project_revenue_tab.LAST,0)+1)        := p_project_revenue;
        g_mrc_projfunc_curr_code_tab(NVL( g_mrc_projfunc_curr_code_tab.LAST,0)+1) := p_projfunc_currency_code;
        g_mrc_projfunc_raw_cost_tab(NVL( g_mrc_projfunc_raw_cost_tab.LAST,0)+1)      := p_projfunc_raw_cost;
        g_mrc_projfunc_burden_cost_tab(NVL( g_mrc_projfunc_burden_cost_tab.LAST,0)+1)   := p_projfunc_burdened_cost;
        g_mrc_projfunc_revenue_tab(NVL( g_mrc_projfunc_revenue_tab.LAST,0)+1)       := p_projfunc_revenue;
        g_mrc_delete_flag_tab(NVL( g_mrc_delete_flag_tab.LAST,0)+1)            := p_delete_flag;
        g_mrc_Billable_flag_tab(NVL( g_mrc_Billable_flag_tab.LAST,0)+1)          := p_billable_flag;
        g_mrc_project_cst_rt_type_tab(NVL( g_mrc_project_cst_rt_type_tab.LAST,0)+1)         := p_project_cost_rate_type;
        g_mrc_project_cst_exg_rt_tab(NVL( g_mrc_project_cst_exg_rt_tab.LAST,0)+1)     := p_project_cost_exchange_rate;
        g_mrc_project_cst_dt_type_tab(NVL( g_mrc_project_cst_dt_type_tab.LAST,0)+1)    := p_project_cost_rate_date_type;
        g_mrc_project_cst_rt_dt_tab(NVL( g_mrc_project_cst_rt_dt_tab.LAST,0)+1)         := p_project_cost_rate_date;
        g_mrc_project_rev_rt_type_tab(NVL( g_mrc_project_rev_rt_type_tab.LAST,0)+1)          := p_project_rev_rate_type;
        g_mrc_project_rev_exg_rt_tab(NVL( g_mrc_project_rev_exg_rt_tab.LAST,0)+1)      := p_project_rev_exchange_rate;
        g_mrc_project_rev_dt_type_tab(NVL( g_mrc_project_rev_dt_type_tab.LAST,0)+1)     := p_project_rev_rate_date_type;
        g_mrc_project_rev_rt_dt_tab(NVL( g_mrc_project_rev_rt_dt_tab.LAST,0)+1)          := p_project_rev_rate_date;
        g_mrc_projfunc_cst_rt_type_tab(NVL( g_mrc_projfunc_cst_rt_type_tab.LAST,0)+1)        := p_projfunc_cost_rate_type;
        g_mrc_projfunc_cst_exg_rt_tab(NVL( g_mrc_projfunc_cst_exg_rt_tab.LAST,0)+1)    := p_projfunc_cost_exchange_rate;
        g_mrc_projfunc_cst_dt_type_tab(NVL( g_mrc_projfunc_cst_dt_type_tab.LAST,0)+1)   := p_projfunc_cost_rate_date_type;
        g_mrc_projfunc_cst_rt_dt_tab(NVL( g_mrc_projfunc_cst_rt_dt_tab.LAST,0)+1)        := p_projfunc_cost_rate_date;
        g_mrc_projfunc_rev_rt_type_tab(NVL( g_mrc_projfunc_rev_rt_type_tab.LAST,0)+1)         := p_projfunc_rev_rate_type;
        g_mrc_projfunc_rev_exg_rt_tab(NVL( g_mrc_projfunc_rev_exg_rt_tab.LAST,0)+1)     := p_projfunc_rev_exchange_rate;
        g_mrc_projfunc_rev_dt_type_tab(NVL( g_mrc_projfunc_rev_dt_type_tab.LAST,0)+1)    := p_projfunc_rev_rate_date_type;
        g_mrc_projfunc_rev_rt_dt_tab(NVL( g_mrc_projfunc_rev_rt_dt_tab.LAST,0)+1)         := p_projfunc_rev_rate_date;

	END IF;

EXCEPTION
    WHEN OTHERS THEN
        print_msg('Failed in Populate_MRC_plsqlTabs  API ['||sqlcode||sqlerrm);
        x_return_status := 'U';
        x_msg_data := sqlcode||sqlerrm;
        RAISE;
END Populate_MRC_plsqlTabs;

/* This API inserts mrc plsql table of records into pa_fp_rollup_tmp when mrc conv is required */
PROCEDURE Populate_rollup_WithMrcRecs
	   	(p_budget_version_id            IN      Number
		,x_msg_data                     OUT NOCOPY Varchar2
                ,x_return_status                OUT NOCOPY Varchar2
                ) IS

BEGIN
	x_return_status := 'S';
	x_msg_data := NULL;
	IF NVL(G_populate_mrc_tab_flag,'N') = 'Y' Then
	  IF g_mrc_budget_line_id_tab.COUNT > 0 THEN
		/* FORALL i IN G_FP_MRC_TAB.FIRST .. G_FP_MRC_TAB.LAST
	 	* using forall thorws error:PLS-00436 implementation restriction: cannot reference fields of
	 	* BULK In-BIND table of records
	 	*/
	      --print_msg('Number of records inserting into rollupTmp for MRC processing['||g_mrc_budget_line_id_tab.COUNT||']');
	      FORALL i IN g_mrc_budget_line_id_tab.FIRST .. g_mrc_budget_line_id_tab.LAST
		  INSERT INTO PA_FP_ROLLUP_TMP tmp
			(budget_version_id
       			,budget_line_id
       			,resource_assignment_id
       			,txn_currency_code
       			,start_date
       			,end_date
       			,period_name
       			,quantity
       			,txn_raw_cost
       			,txn_burdened_cost
       			,txn_revenue
       			,project_currency_code
       			,project_raw_cost
       			,project_burdened_cost
       			,project_revenue
       			,project_cost_rate_type
       			,project_cost_exchange_rate
       			,project_cost_rate_date_type
       			,project_cost_rate_date
       			,project_rev_rate_type
       			,project_rev_exchange_rate
       			,project_rev_rate_date_type
       			,project_rev_rate_date
       			,projfunc_currency_code
       			,projfunc_raw_cost
       			,projfunc_burdened_cost
       			,projfunc_revenue
       			,projfunc_cost_rate_type
       			,projfunc_cost_exchange_rate
       			,projfunc_cost_rate_date_type
       			,projfunc_cost_rate_date
       			,projfunc_rev_rate_type
       			,projfunc_rev_exchange_rate
       			,projfunc_rev_rate_date_type
       			,projfunc_rev_rate_date
       			,delete_flag
			)
		SELECT p_budget_version_id
                        ,g_mrc_budget_line_id_tab(i)
                        ,g_mrc_res_assignment_id_tab(i)
                        ,g_mrc_txn_curr_code_tab(i)
                        ,g_mrc_start_date_tab(i)
                        ,g_mrc_end_date_tab(i)
                        ,g_mrc_period_name_tab(i)
                        ,g_mrc_quantity_tab(i)
                        ,g_mrc_txn_raw_cost_tab(i)
                        ,g_mrc_txn_burden_cost_tab(i)
                        ,g_mrc_txn_revenue_tab(i)
                        ,g_mrc_project_curr_code_tab(i)
                        ,g_mrc_project_raw_cost_tab(i)
                        ,g_mrc_project_burden_cost_tab(i)
                        ,g_mrc_project_revenue_tab(i)
                        ,g_mrc_project_cst_rt_type_tab(i)
                        ,g_mrc_project_cst_exg_rt_tab(i)
                        ,g_mrc_project_cst_dt_type_tab(i)
                        ,g_mrc_project_cst_rt_dt_tab(i)
                        ,g_mrc_project_rev_rt_type_tab(i)
                        ,g_mrc_project_rev_exg_rt_tab(i)
                        ,g_mrc_project_rev_dt_type_tab(i)
                        ,g_mrc_project_rev_rt_dt_tab(i)
                        ,g_mrc_projfunc_curr_code_tab(i)
                        ,g_mrc_projfunc_raw_cost_tab(i)
                        ,g_mrc_projfunc_burden_cost_tab(i)
                        ,g_mrc_projfunc_revenue_tab(i)
                        ,g_mrc_projfunc_cst_rt_type_tab(i)
                        ,g_mrc_projfunc_cst_exg_rt_tab(i)
                        ,g_mrc_projfunc_cst_dt_type_tab(i)
                        ,g_mrc_projfunc_cst_rt_dt_tab(i)
                        ,g_mrc_projfunc_rev_rt_type_tab(i)
                        ,g_mrc_projfunc_rev_exg_rt_tab(i)
                        ,g_mrc_projfunc_rev_dt_type_tab(i)
                        ,g_mrc_projfunc_rev_rt_dt_tab(i)
                        ,g_mrc_delete_flag_tab(i)
		FROM DUAL
		WHERE NOT EXISTS (SELECT NULL
				FROM PA_FP_ROLLUP_TMP RLTMP1
				WHERE rltmp1.budget_line_id = g_mrc_budget_line_id_tab(i)
				);
	  END If;
	END IF;


EXCEPTION
    WHEN OTHERS THEN
        print_msg('Failed in Populate_rollup_WithMrcRecs API ['||sqlcode||sqlerrm);
        x_return_status := 'U';
        x_msg_data := sqlcode||sqlerrm;
        RAISE;
END Populate_rollup_WithMrcRecs;

/* This API resets the plsql table indexes for reporting tables in the order
 * so that one-level cache is used inside PJI apis to derive the
 * resource details:
 * As part of bug fix:5116157: When Non-rate base resource changes to Rate base resource
 * this api passes the correct UOM and rate base flag to the reversal lines to PJI
 */
PROCEDURE ResetRepPlsqlTabIdex(p_budget_version_id    IN NUMBER
                           ,x_return_status           OUT NOCOPY VARCHAR2
			   ,x_msg_data		      OUT NOCOPY VARCHAR2
                        ) IS

BEGIN
	x_return_status := 'S';
	IF g_rep_res_assignment_id_tab.COUNT > 0 Then
		Delete pa_fp_spread_calc_tmp1;
		FORALL i IN g_rep_res_assignment_id_tab.FIRST .. g_rep_res_assignment_id_tab.LAST
		INSERT INTO pa_fp_spread_calc_tmp1
		(budget_line_id
		,resource_assignment_id
		,start_date
		,end_date
		,period_name
		,txn_currency_code
		,quantity
		,txn_raw_cost
		,txn_burdened_cost
		,txn_revenue
		,project_currency_code
		,project_raw_cost
		,project_burdened_cost
		,project_revenue
		,projfunc_currency_code
		,projfunc_raw_cost
		,projfunc_burdened_cost
		,projfunc_revenue
		,system_reference_var1
		,budget_version_id
		) VALUES
        	(g_rep_budget_line_id_tab(i)
        	,g_rep_res_assignment_id_tab(i)
        	,g_rep_start_date_tab(i)
        	,g_rep_end_date_tab(i)
        	,g_rep_period_name_tab(i)
        	,g_rep_txn_curr_code_tab(i)
        	,g_rep_quantity_tab(i)
        	,g_rep_txn_raw_cost_tab(i)
        	,g_rep_txn_burdened_cost_tab(i)
        	,g_rep_txn_revenue_tab(i)
        	,g_rep_project_curr_code_tab(i)
        	,g_rep_project_raw_cost_tab(i)
        	,g_rep_project_burden_cost_tab(i)
        	,g_rep_project_revenue_tab(i)
        	,g_rep_projfunc_curr_code_tab(i)
        	,g_rep_projfunc_raw_cost_tab(i)
        	,g_rep_projfunc_burden_cost_tab(i)
        	,g_rep_projfunc_revenue_tab(i)
		,g_rep_line_mode_tab(i)
		,p_budget_version_id
		);

		/* Reset the plsql tabs */
		Init_reporting_Tbls;

		/* bug fix:5116157 : For non-rate base resource when qty is changed, the calculate process sets the rate base flag to Y
                 * while passing reversal lines to pji the old rate base flag should be passed, otherwise this results in data corruption
                 * on view pages
                 * Note: tmp.system_reference_var3 - indicates that Change of Non-rate base to Rate base
                 *       tmp1.system_reference_var1 - indicates that reversal or positive entry of budget line passing to pji
                 */
		UPDATE pa_fp_spread_calc_tmp1 tmp1
		SET tmp1.rate_based_flag  =
			(SELECT decode(nvl(tmp.system_reference_var3,'N'),'Y'
				,decode(nvl(tmp1.system_reference_var1,'XXX'),'REVERSAL','N',NULL),NULL)
			FROM pa_fp_spread_calc_tmp tmp
			WHERE tmp.resource_assignment_id = tmp1.resource_assignment_id
			AND ROWNUM = 1
			)
		WHERE tmp1.budget_version_id = p_budget_version_id
		AND EXISTS (select null
			FROM pa_fp_spread_calc_tmp otmp
                        WHERE otmp.resource_assignment_id = tmp1.resource_assignment_id
                        );
		If P_PA_DEBUG_MODE = 'Y' Then
		print_msg('Number of rows updated for ratebasedFlag for Pjirollup['||sql%rowcount||']');
		End If;

		SELECT
		tmp1.budget_line_id
                ,tmp1.resource_assignment_id
                ,tmp1.start_date
                ,tmp1.end_date
                ,tmp1.period_name
                ,tmp1.txn_currency_code
                ,tmp1.quantity
                ,tmp1.txn_raw_cost
                ,tmp1.txn_burdened_cost
                ,tmp1.txn_revenue
                ,tmp1.project_currency_code
                ,tmp1.project_raw_cost
                ,tmp1.project_burdened_cost
                ,tmp1.project_revenue
                ,tmp1.projfunc_currency_code
                ,tmp1.projfunc_raw_cost
                ,tmp1.projfunc_burdened_cost
                ,tmp1.projfunc_revenue
		,tmp1.system_reference_var1
		,tmp1.rate_based_flag
                BULK COLLECT INTO
                g_rep_budget_line_id_tab
                ,g_rep_res_assignment_id_tab
                ,g_rep_start_date_tab
                ,g_rep_end_date_tab
                ,g_rep_period_name_tab
                ,g_rep_txn_curr_code_tab
                ,g_rep_quantity_tab
                ,g_rep_txn_raw_cost_tab
                ,g_rep_txn_burdened_cost_tab
                ,g_rep_txn_revenue_tab
                ,g_rep_project_curr_code_tab
                ,g_rep_project_raw_cost_tab
                ,g_rep_project_burden_cost_tab
                ,g_rep_project_revenue_tab
                ,g_rep_projfunc_curr_code_tab
                ,g_rep_projfunc_raw_cost_tab
                ,g_rep_projfunc_burden_cost_tab
                ,g_rep_projfunc_revenue_tab
		,g_rep_line_mode_tab
		,g_rep_rate_base_flag_tab
		FROM pa_fp_spread_calc_tmp1 tmp1
		ORDER BY tmp1.resource_assignment_id
			,tmp1.txn_currency_code;

	END IF;

EXCEPTION
    WHEN OTHERS THEN
        print_msg('Failed in ResetRepPlsqlTabIdex API ['||sqlcode||sqlerrm);
        x_return_status := 'U';
        x_msg_data := sqlcode||sqlerrm;
        RAISE;


END ResetRepPlsqlTabIdex;


/* This API calls the PJI reporting procedures to rollup of the budget lines
 * to the task and project level
 */
PROCEDURE Add_Toreporting_Tabls
                (p_calling_module               IN      Varchar2 Default 'CALCULATE_API'
                ,p_activity_code                IN      Varchar2 Default 'UPDATE'
                ,p_budget_version_id            IN      Number
                ,p_budget_line_id               IN      Number
                ,p_resource_assignment_id       IN      Number
                ,p_start_date                   IN      Date
                ,p_end_date                     IN      Date
                ,p_period_name                  IN      Varchar2
                ,p_txn_currency_code            IN      Varchar2
                ,p_quantity                     IN      Number
                ,p_txn_raw_cost                 IN      Number
                ,p_txn_burdened_cost            IN      Number
                ,p_txn_revenue                  IN      Number
                ,p_project_currency_code        IN      Varchar2
                ,p_project_raw_cost             IN      Number
                ,p_project_burdened_cost        IN      Number
                ,p_project_revenue              IN      Number
                ,p_projfunc_currency_code       IN      Varchar2
                ,p_projfunc_raw_cost            IN      Number
                ,p_projfunc_burdened_cost       IN      Number
                ,p_projfunc_revenue             IN      Number
		,p_rep_line_mode                IN      Varchar2
                ,x_msg_data                     OUT NOCOPY Varchar2
                ,x_return_status                OUT NOCOPY Varchar2
                ) IS

    l_msg_count   Number :=0;

BEGIN
    x_msg_data        := NULL;
        l_msg_count       := 0;
        x_return_status   := 'S';
    /* Bug fix: 3867302 : PJI reporting apis should not be called for change order/change requests */
    IF (NVL(G_AGR_CONV_REQD_FLAG,'N') <> 'Y' AND NVL(g_rollup_required_flag,'N') = 'Y') Then
        g_rep_budget_line_id_tab.extend;
        g_rep_budget_line_id_tab(g_rep_budget_line_id_tab.last) := p_budget_line_id;
            g_rep_res_assignment_id_tab.extend;
        g_rep_res_assignment_id_tab(g_rep_res_assignment_id_tab.Last) := p_resource_assignment_id;
            g_rep_start_date_tab.extend;
        g_rep_start_date_tab(g_rep_start_date_tab.Last) := p_start_date;
            g_rep_end_date_tab.extend;
        g_rep_end_date_tab(g_rep_end_date_tab.Last) := p_end_date;
            g_rep_period_name_tab.Extend;
        g_rep_period_name_tab(g_rep_period_name_tab.Last) := p_period_name;
            g_rep_txn_curr_code_tab.extend;
        g_rep_txn_curr_code_tab(g_rep_txn_curr_code_tab.Last) := p_txn_currency_code;
            g_rep_quantity_tab.Extend;
        g_rep_quantity_tab(g_rep_quantity_tab.Last) := p_quantity;
            g_rep_txn_raw_cost_tab.extend;
        g_rep_txn_raw_cost_tab(g_rep_txn_raw_cost_tab.Last) := p_txn_raw_cost;
            g_rep_txn_burdened_cost_tab.extend;
        g_rep_txn_burdened_cost_tab(g_rep_txn_burdened_cost_tab.Last) := p_txn_burdened_cost;
            g_rep_txn_revenue_tab.extend;
        g_rep_txn_revenue_tab(g_rep_txn_revenue_tab.Last) := p_txn_revenue;
            g_rep_project_curr_code_tab.extend;
        g_rep_project_curr_code_tab(g_rep_project_curr_code_tab.Last) := p_project_currency_code;
            g_rep_project_raw_cost_tab.extend;
        g_rep_project_raw_cost_tab(g_rep_project_raw_cost_tab.Last) := p_project_raw_cost;
            g_rep_project_burden_cost_tab.extend;
        g_rep_project_burden_cost_tab(g_rep_project_burden_cost_tab.Last) := p_project_burdened_cost;
            g_rep_project_revenue_tab.extend;
        g_rep_project_revenue_tab(g_rep_project_revenue_tab.Last) := p_project_revenue;
            g_rep_projfunc_curr_code_tab.extend;
        g_rep_projfunc_curr_code_tab(g_rep_projfunc_curr_code_tab.Last) := p_projfunc_currency_code;
            g_rep_projfunc_raw_cost_tab.extend;
        g_rep_projfunc_raw_cost_tab(g_rep_projfunc_raw_cost_tab.Last) := p_projfunc_raw_cost;
            g_rep_projfunc_burden_cost_tab.extend;
        g_rep_projfunc_burden_cost_tab(g_rep_projfunc_burden_cost_tab.Last) := p_projfunc_burdened_cost;
            g_rep_projfunc_revenue_tab.extend;
        g_rep_projfunc_revenue_tab(g_rep_projfunc_revenue_tab.Last) := p_projfunc_revenue;
	g_rep_line_mode_tab.extend;
	g_rep_line_mode_tab(g_rep_line_mode_tab.Last) := p_rep_line_mode;
	g_rep_rate_base_flag_tab.extend;
	g_rep_rate_base_flag_tab(g_rep_rate_base_flag_tab.last) := NULL;
    End If;

EXCEPTION
    WHEN OTHERS THEN
        print_msg('Failed in PA_FP_PJI_INTG_PKG.update_reporting_lines API ['||sqlcode||sqlerrm);
        x_return_status := 'U';
        x_msg_data := sqlcode||sqlerrm;
        RAISE;

END Add_Toreporting_Tabls;

/* This API will print all the values passed to PJI rollup API.  This is only for debug purpose */
PROCEDURE DbugPjiVals IS
	l_msg	Varchar2(2000);
BEGIN
   /**
    IF g_rep_res_assignment_id_tab.COUNT > 0 THEN
        FOR i IN g_rep_res_assignment_id_tab.FIRST .. g_rep_res_assignment_id_tab.LAST LOOP
	    l_msg := 'RaId['||g_rep_res_assignment_id_tab(i)||']TxnCur['||g_rep_txn_curr_code_tab(i)||']SD['||g_rep_start_date_tab(i)||']';
            l_msg := l_msg||'Qty['||g_rep_quantity_tab(i)||']TxnRaw['||g_rep_txn_raw_cost_tab(i)||']Burd['||g_rep_txn_burdened_cost_tab(i)||']';
	    l_msg := l_msg||'RepLineMode['||g_rep_line_mode_tab(i)||']RateBaseFlag['||g_rep_rate_base_flag_tab(i)||']';
	    print_msg(l_msg);
        END LOOP;

    END IF;
   **/
	NULL;

END DbugPjiVals;

PROCEDURE Update_PCPFC_rounding_diff(
        p_project_id                     IN  pa_budget_versions.project_id%type
                ,p_budget_version_id              IN  pa_budget_versions.budget_version_id%TYPE
                ,p_calling_module                IN  VARCHAR2 DEFAULT NULL
                ,p_source_context                IN  pa_fp_res_assignments_tmp.source_context%TYPE
                ,p_wp_cost_enabled_flag          IN  varchar2
                ,p_budget_version_type           IN  varchar2
                ,x_return_status                 OUT NOCOPY VARCHAR2
                ,x_msg_count                     OUT NOCOPY NUMBER
                ,x_msg_data                      OUT NOCOPY VARCHAR2) IS

    CURSOR cur_round_discrepancy_lines IS
    SELECT resource_assignment_id
                ,txn_currency_code
                ,MAX(start_date)
                ,SUM(quantity)
                ,SUM(init_quantity)
                ,SUM(txn_raw_cost)
                ,SUM(txn_init_raw_cost)
                ,SUM(txn_burdened_cost)
                ,SUM(txn_init_burdened_cost)
                ,SUM(txn_revenue)
                ,SUM(txn_init_revenue)
        ,SUM(txn_raw_cost * project_cost_exchange_rate)   unround_project_raw_cost
        ,SUM(txn_burdened_cost * project_cost_exchange_rate) unround_project_burden_cost
        ,SUM(txn_revenue * project_rev_exchange_rate)   unround_project_revenue
        ,SUM(pa_currency.round_trans_currency_amt1((txn_raw_cost * project_cost_exchange_rate),project_currency_code)) round_project_raw_cost
        ,SUM(pa_currency.round_trans_currency_amt1((txn_burdened_cost * project_cost_exchange_rate),project_currency_code)) round_project_burden_cost
        ,SUM(pa_currency.round_trans_currency_amt1((txn_revenue * project_rev_exchange_rate),project_currency_code)) round_project_revenue
        ,SUM(txn_raw_cost * projfunc_cost_exchange_rate)   unround_projfunc_raw_cost
                ,SUM(txn_burdened_cost * projfunc_cost_exchange_rate) unround_projfunc_burden_cost
                ,SUM(txn_revenue * projfunc_rev_exchange_rate)   unround_projfunc_revenue
                ,SUM(pa_currency.round_trans_currency_amt1((txn_raw_cost * projfunc_cost_exchange_rate),projfunc_currency_code)) round_projfunc_raw_cost
                ,SUM(pa_currency.round_trans_currency_amt1((txn_burdened_cost * projfunc_cost_exchange_rate),projfunc_currency_code)) round_projfunc_burden_cost
                ,SUM(pa_currency.round_trans_currency_amt1((txn_revenue * projfunc_rev_exchange_rate),projfunc_currency_code)) round_projfunc_revenue
        ,to_number(NULL) diff_proj_raw_cost
                ,to_number(NULL) diff_proj_burden_cost
                ,to_number(NULL) diff_proj_revenue
        ,to_number(NULL) diff_projfunc_raw_cost
                ,to_number(NULL) diff_projfunc_burden_cost
                ,to_number(NULL) diff_projfunc_revenue
        ,project_currency_code
        ,projfunc_currency_code
        FROM pa_fp_rollup_tmp tmp
    WHERE tmp.budget_version_id = p_budget_version_id
    AND nvl(quantity,0) <> 0
    AND  ( tmp.txn_currency_code <> tmp.project_currency_code
        OR
        tmp.txn_currency_code <> tmp.projfunc_currency_code
         )
    GROUP BY resource_assignment_id
                ,txn_currency_code
        ,project_currency_code
        ,projfunc_currency_code;

    l_return_status    varchar2(10);
    l_msg_count        Number;
    l_msg_data         varchar2(240);

        l_resource_assignment_tab       pa_plsql_datatypes.NumTabTyp;
        l_txn_currency_code_tab         pa_plsql_datatypes.Char50TabTyp;
        l_proj_currency_code_tab        pa_plsql_datatypes.Char50TabTyp;
        l_pjfc_currency_code_tab        pa_plsql_datatypes.Char50TabTyp;
        l_start_date_tab                pa_plsql_datatypes.DateTabTyp;
        l_quantity_tab                  pa_plsql_datatypes.NumTabTyp;
        l_init_quantity_tab             pa_plsql_datatypes.NumTabTyp;
        l_txn_raw_cost_tab              pa_plsql_datatypes.NumTabTyp;
        l_txn_init_raw_cost_tab         pa_plsql_datatypes.NumTabTyp;
        l_txn_burdened_cost_tab         pa_plsql_datatypes.NumTabTyp;
        l_txn_init_burdened_cost_tab    pa_plsql_datatypes.NumTabTyp;
        l_txn_revenue_tab               pa_plsql_datatypes.NumTabTyp;
        l_txn_init_revenue_tab          pa_plsql_datatypes.NumTabTyp;
    l_unround_proj_raw_cost_tab    pa_plsql_datatypes.NumTabTyp;
    l_unround_proj_burd_cost_tab   pa_plsql_datatypes.NumTabTyp;
    l_unround_proj_rev_tab         pa_plsql_datatypes.NumTabTyp;
    l_round_proj_raw_cost_tab      pa_plsql_datatypes.NumTabTyp;
    l_round_proj_burd_cost_tab    pa_plsql_datatypes.NumTabTyp;
    l_round_proj_rev_tab           pa_plsql_datatypes.NumTabTyp;
        l_unround_pjfc_raw_cost_tab    pa_plsql_datatypes.NumTabTyp;
        l_unround_pjfc_burd_cost_tab   pa_plsql_datatypes.NumTabTyp;
        l_unround_pjfc_rev_tab         pa_plsql_datatypes.NumTabTyp;
        l_round_pjfc_raw_cost_tab      pa_plsql_datatypes.NumTabTyp;
        l_round_pjfc_burd_cost_tab    pa_plsql_datatypes.NumTabTyp;
        l_round_pjfc_rev_tab           pa_plsql_datatypes.NumTabTyp;
    l_diff_proj_raw_cost_tab       pa_plsql_datatypes.NumTabTyp;
        l_diff_proj_burd_cost_tab    pa_plsql_datatypes.NumTabTyp;
        l_diff_proj_rev_tab        pa_plsql_datatypes.NumTabTyp;
        l_diff_pjfc_raw_cost_tab       pa_plsql_datatypes.NumTabTyp;
        l_diff_pjfc_burd_cost_tab    pa_plsql_datatypes.NumTabTyp;
        l_diff_pjfc_rev_tab        pa_plsql_datatypes.NumTabTyp;

    l_revenue_generation_method varchar2(10);
        l_null_revenue_amts_flag    varchar2(10);

BEGIN
    /* initialize the out variables */
    x_return_status := 'S';
    x_msg_count     := 0;
    x_msg_data      := NULL;
        l_return_status := 'S';
    l_msg_count := 0;
    l_msg_data      := NULL;
    IF p_pa_debug_mode = 'Y' Then
            pa_debug.init_err_stack('PA_FP_CALC_PLAN_PKG.Update_PCPFCrounding_diff');
    End If;

    g_stage := 'Update_PCPFC_rounding_diff:100';
        pa_debug.g_err_stage := 'Entered Update_PCPFCrounding_diff API';
    --print_msg(pa_debug.g_err_stage);

    IF p_wp_cost_enabled_flag = 'Y' Then
        /* initialize the plsql tabs */
        l_resource_assignment_tab.delete;
            l_txn_currency_code_tab.delete;
            l_start_date_tab.delete;
            l_quantity_tab.delete;
            l_init_quantity_tab.delete;
            l_txn_raw_cost_tab.delete;
            l_txn_init_raw_cost_tab.delete;
            l_txn_burdened_cost_tab.delete;
            l_txn_init_burdened_cost_tab.delete;
            l_txn_revenue_tab.delete;
            l_txn_init_revenue_tab.delete;
        l_unround_proj_raw_cost_tab.delete;
            l_unround_proj_burd_cost_tab.delete;
            l_unround_proj_rev_tab.delete;
            l_round_proj_raw_cost_tab.delete;
            l_round_proj_burd_cost_tab.delete;
            l_round_proj_rev_tab.delete;
            l_unround_pjfc_raw_cost_tab.delete;
            l_unround_pjfc_burd_cost_tab.delete;
            l_unround_pjfc_rev_tab.delete;
            l_round_pjfc_raw_cost_tab.delete;
            l_round_pjfc_burd_cost_tab.delete;
            l_round_pjfc_rev_tab.delete;
            l_diff_proj_raw_cost_tab.delete;
            l_diff_proj_burd_cost_tab.delete;
            l_diff_proj_rev_tab.delete;
            l_diff_pjfc_raw_cost_tab.delete;
            l_diff_pjfc_burd_cost_tab.delete;
            l_diff_pjfc_rev_tab.delete;
        l_proj_currency_code_tab.delete;
        l_pjfc_currency_code_tab.delete;

        OPEN cur_round_discrepancy_lines;
        FETCH cur_round_discrepancy_lines BULK COLLECT INTO
            l_resource_assignment_tab
                    ,l_txn_currency_code_tab
                    ,l_start_date_tab
                    ,l_quantity_tab
                    ,l_init_quantity_tab
                    ,l_txn_raw_cost_tab
                    ,l_txn_init_raw_cost_tab
                    ,l_txn_burdened_cost_tab
                    ,l_txn_init_burdened_cost_tab
                    ,l_txn_revenue_tab
                    ,l_txn_init_revenue_tab
            ,l_unround_proj_raw_cost_tab
                    ,l_unround_proj_burd_cost_tab
                    ,l_unround_proj_rev_tab
                    ,l_round_proj_raw_cost_tab
                    ,l_round_proj_burd_cost_tab
                    ,l_round_proj_rev_tab
                    ,l_unround_pjfc_raw_cost_tab
                    ,l_unround_pjfc_burd_cost_tab
                    ,l_unround_pjfc_rev_tab
                    ,l_round_pjfc_raw_cost_tab
                    ,l_round_pjfc_burd_cost_tab
                    ,l_round_pjfc_rev_tab
                    ,l_diff_proj_raw_cost_tab
                    ,l_diff_proj_burd_cost_tab
                    ,l_diff_proj_rev_tab
                    ,l_diff_pjfc_raw_cost_tab
                    ,l_diff_pjfc_burd_cost_tab
                    ,l_diff_pjfc_rev_tab
            ,l_proj_currency_code_tab
            ,l_pjfc_currency_code_tab;
        CLOSE cur_round_discrepancy_lines;

        --print_msg('Number Of Lines fetched into plsql tabls['||l_resource_assignment_tab.count||']');
        IF l_resource_assignment_tab.COUNT > 0 Then
            g_stage := 'Update_PCPFC_rounding_diff:101';
            FOR i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST LOOP
                l_diff_proj_raw_cost_tab(i) := nvl(l_unround_proj_raw_cost_tab(i),0) - nvl(l_round_proj_raw_cost_tab(i),0);
                l_diff_proj_burd_cost_tab(i) := nvl(l_unround_proj_burd_cost_tab(i),0) - nvl(l_round_proj_burd_cost_tab(i),0);
                l_diff_proj_rev_tab(i)  := nvl(l_unround_proj_rev_tab(i),0) - nvl(l_round_proj_rev_tab(i),0);

                l_diff_proj_raw_cost_tab(i) := pa_currency.round_trans_currency_amt1(l_diff_proj_raw_cost_tab(i),l_proj_currency_code_tab(i));
                l_diff_proj_burd_cost_tab(i) := pa_currency.round_trans_currency_amt1(l_diff_proj_burd_cost_tab(i),l_proj_currency_code_tab(i));
                l_diff_proj_rev_tab(i)  := pa_currency.round_trans_currency_amt1(l_diff_proj_rev_tab(i),l_proj_currency_code_tab(i));
                /* projfunc discrepancy */
                                l_diff_pjfc_raw_cost_tab(i) := nvl(l_unround_pjfc_raw_cost_tab(i),0) - nvl(l_round_pjfc_raw_cost_tab(i),0);
                                l_diff_pjfc_burd_cost_tab(i) := nvl(l_unround_pjfc_burd_cost_tab(i),0) - nvl(l_round_pjfc_burd_cost_tab(i),0);
                                l_diff_pjfc_rev_tab(i)  := nvl(l_unround_pjfc_rev_tab(i),0) - nvl(l_round_pjfc_rev_tab(i),0);

                                l_diff_pjfc_raw_cost_tab(i) := pa_currency.round_trans_currency_amt1(l_diff_pjfc_raw_cost_tab(i),l_pjfc_currency_code_tab(i));
                                l_diff_pjfc_burd_cost_tab(i) := pa_currency.round_trans_currency_amt1(l_diff_pjfc_burd_cost_tab(i),l_pjfc_currency_code_tab(i));
                                l_diff_pjfc_rev_tab(i)  := pa_currency.round_trans_currency_amt1(l_diff_pjfc_rev_tab(i),l_pjfc_currency_code_tab(i));
            END LOOP;

            l_null_revenue_amts_flag := 'N';
            IF (p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION') AND p_budget_version_type = 'ALL'
                 --Bug 6722414 When called from ETC client extension, Dont null out revenue amounts.
            AND NVL(g_from_etc_client_extn_flag,'N')='N' ) THEN
                l_revenue_generation_method := NVL(PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id),'W');
                        IF NVL(l_revenue_generation_method,'W') in ('C','E') Then
                    l_null_revenue_amts_flag := 'Y';
                End IF;
            END IF;

            --print_msg('Updating rollup tmp last line with the rounding difference amount');
            g_stage := 'Update_PCPFC_rounding_diff:102';
            FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
            UPDATE pa_fp_rollup_tmp tmp
                        SET tmp.attribute14 = decode(tmp.txn_currency_code,tmp.project_currency_code,NULL,'PCPFCRoundingDiscrepancyLine')
            /*---Project columns ---*/
            ,tmp.project_raw_cost = decode(p_budget_version_type,'COST',
                            decode(tmp.txn_currency_code,tmp.project_currency_code,tmp.project_raw_cost
                                ,decode((nvl(tmp.project_raw_cost,0)+ NVL(l_diff_proj_raw_cost_tab(i),0)),0,NULL,
                                    (nvl(tmp.project_raw_cost,0)+ NVL(l_diff_proj_raw_cost_tab(i),0))))
                              ,'ALL',
                                                        decode(tmp.txn_currency_code,tmp.project_currency_code,tmp.project_raw_cost
                                                                ,decode((nvl(tmp.project_raw_cost,0)+ NVL(l_diff_proj_raw_cost_tab(i),0)),0,NULL,
                                                                        (nvl(tmp.project_raw_cost,0)+ NVL(l_diff_proj_raw_cost_tab(i),0))))
                              ,'REVENUE',tmp.project_raw_cost)
            ,tmp.project_burdened_cost =decode(p_budget_version_type,'COST',
                                                        decode(tmp.txn_currency_code,tmp.project_currency_code,tmp.project_burdened_cost
                                                                ,decode((nvl(tmp.project_burdened_cost,0)+ NVL(l_diff_proj_burd_cost_tab(i),0)),0,NULL,
                                                                        (nvl(tmp.project_burdened_cost,0)+ NVL(l_diff_proj_burd_cost_tab(i),0))))
                                                      ,'ALL',
                                                        decode(tmp.txn_currency_code,tmp.project_currency_code,tmp.project_burdened_cost
                                                                ,decode((nvl(tmp.project_burdened_cost,0)+ NVL(l_diff_proj_burd_cost_tab(i),0)),0,NULL,
                                                                        (nvl(tmp.project_burdened_cost,0)+ NVL(l_diff_proj_burd_cost_tab(i),0))))
                                                      ,'REVENUE',tmp.project_burdened_cost)
            ,tmp.project_revenue = decode(p_budget_version_type,'COST', tmp.project_revenue
                            ,'ALL',decode(tmp.txn_currency_code,tmp.project_currency_code,tmp.project_revenue
                                ,DECODE(l_null_revenue_amts_flag,'Y',tmp.project_revenue
                                  ,decode((nvl(tmp.project_revenue,0)+nvl(l_diff_proj_rev_tab(i),0)),0,NULL,
                                     (nvl(tmp.project_revenue,0)+nvl(l_diff_proj_rev_tab(i),0)))))
                            ,'REVENUE', decode(tmp.txn_currency_code,tmp.project_currency_code,tmp.project_revenue
                                ,decode((nvl(tmp.project_revenue,0)+nvl(l_diff_proj_rev_tab(i),0)),0,NULL,
                                                                     (nvl(tmp.project_revenue,0)+nvl(l_diff_proj_rev_tab(i),0)))))
            /*---ProjFunc columns ---*/
            ,tmp.projfunc_raw_cost = decode(p_budget_version_type,'COST',
                                                        decode(tmp.txn_currency_code,tmp.projfunc_currency_code,tmp.projfunc_raw_cost
                                                                ,decode((nvl(tmp.projfunc_raw_cost,0)+ NVL(l_diff_pjfc_raw_cost_tab(i),0)),0,NULL,
                                                                        (nvl(tmp.projfunc_raw_cost,0)+ NVL(l_diff_pjfc_raw_cost_tab(i),0))))
                                                      ,'ALL',
                                                        decode(tmp.txn_currency_code,tmp.projfunc_currency_code,tmp.projfunc_raw_cost
                                                                ,decode((nvl(tmp.projfunc_raw_cost,0)+ NVL(l_diff_pjfc_raw_cost_tab(i),0)),0,NULL,
                                                                        (nvl(tmp.projfunc_raw_cost,0)+ NVL(l_diff_pjfc_raw_cost_tab(i),0))))
                                                      ,'REVENUE',tmp.projfunc_raw_cost)
            ,tmp.projfunc_burdened_cost = decode(p_budget_version_type,'COST',
                                                        decode(tmp.txn_currency_code,tmp.projfunc_currency_code,tmp.projfunc_burdened_cost
                                                                ,decode((nvl(tmp.projfunc_burdened_cost,0)+ NVL(l_diff_pjfc_burd_cost_tab(i),0)),0,NULL,
                                                                        (nvl(tmp.projfunc_burdened_cost,0)+ NVL(l_diff_pjfc_burd_cost_tab(i),0))))
                                                      ,'ALL',
                                                        decode(tmp.txn_currency_code,tmp.projfunc_currency_code,tmp.projfunc_burdened_cost
                                                                ,decode((nvl(tmp.projfunc_burdened_cost,0)+ NVL(l_diff_pjfc_burd_cost_tab(i),0)),0,NULL,
                                                                        (nvl(tmp.projfunc_burdened_cost,0)+ NVL(l_diff_pjfc_burd_cost_tab(i),0))))
                                                      ,'REVENUE',tmp.projfunc_burdened_cost)
            ,tmp.projfunc_revenue = decode(p_budget_version_type,'COST', tmp.projfunc_revenue
                                                        ,'ALL',decode(tmp.txn_currency_code,tmp.projfunc_currency_code,tmp.projfunc_revenue
                                                                ,DECODE(l_null_revenue_amts_flag,'Y',tmp.projfunc_revenue
                                                                  ,decode((nvl(tmp.projfunc_revenue,0)+nvl(l_diff_pjfc_rev_tab(i),0)),0,NULL,
                                                                     (nvl(tmp.projfunc_revenue,0)+nvl(l_diff_pjfc_rev_tab(i),0)))))
                                                        ,'REVENUE', decode(tmp.txn_currency_code,tmp.projfunc_currency_code,tmp.projfunc_revenue
                                                                ,decode((nvl(tmp.projfunc_revenue,0)+nvl(l_diff_pjfc_rev_tab(i),0)),0,NULL,
                                                                     (nvl(tmp.projfunc_revenue,0)+nvl(l_diff_pjfc_rev_tab(i),0)))))
                        WHERE tmp.resource_assignment_id = l_resource_assignment_tab(i)
                        AND   tmp.txn_currency_code = l_txn_currency_code_tab(i)
                        AND   tmp.start_date = l_start_date_tab(i)
                        AND   (NVL(l_diff_proj_raw_cost_tab(i),0) <> 0
                     OR NVL(l_diff_proj_burd_cost_tab(i),0) <> 0
                 OR NVL(l_diff_proj_rev_tab(i),0) <> 0
                 OR NVL(l_diff_pjfc_raw_cost_tab(i),0) <> 0
                                 OR NVL(l_diff_pjfc_burd_cost_tab(i),0) <> 0
                                 OR NVL(l_diff_pjfc_rev_tab(i),0) <> 0 );
            /** Bug fix: 4208217 Performance fix:  This is additional condition may not be necessary so commenting out
                        -- added this to ensure that only one budget line in rollup tmp gets updated even if there is duplicate lines
                        AND   tmp.rowid in (select max(rowid)
                                            from pa_fp_rollup_tmp tmp2
                                            where tmp2.resource_assignment_id = tmp.resource_assignment_id
                                            and tmp2.txn_currency_code = tmp.txn_currency_code
                                            and tmp2.start_date = tmp.start_date
                                           );
            **/
                        --print_msg('Number of lines updated['||sql%rowcount||']');
        END IF;
    End If;

    x_return_status := l_return_status;
        x_msg_count     := l_msg_count;
        x_msg_data  := l_msg_data;
    g_stage := 'Update_PCPFC_rounding_diff:103';
    -- reset error stack
    IF p_pa_debug_mode = 'Y' Then
    	print_msg('End of Update_PCPFCrounding_diff API return Sts['||x_return_status||']');
        pa_debug.reset_err_stack;
    End If;

EXCEPTION
    WHEN OTHERS THEN
                print_msg('Failed in Update_PCPFCrounding_diff API ['||sqlcode||sqlerrm);
                x_return_status := 'U';
                x_msg_data := sqlcode||sqlerrm;
        fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                 ,p_procedure_name => 'Update_PCPFC_rounding_diff' );
                print_msg('Failed in Update_PCPFC_rounding_diff substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
        IF p_pa_debug_mode = 'Y' Then
            pa_debug.reset_err_stack;
        End If;
                RAISE;
END Update_PCPFC_rounding_diff;

/* This API rounds off the amounts to currency precision level and the last budget line of resoruce per currency will be
 * updated with the rounding discrepancy amounts
 */
PROCEDURE Update_rounding_diff(
        p_project_id             IN  pa_budget_versions.project_id%type
        ,p_budget_version_id              IN  pa_budget_versions.budget_version_id%TYPE
        ,p_calling_module                IN  VARCHAR2 DEFAULT NULL
        ,p_source_context                IN  pa_fp_res_assignments_tmp.source_context%TYPE
        ,p_wp_cost_enabled_flag          IN  varchar2
        ,p_budget_version_type           IN  varchar2
                ,x_return_status                 OUT NOCOPY VARCHAR2
                ,x_msg_count                     OUT NOCOPY NUMBER
                ,x_msg_data                      OUT NOCOPY VARCHAR2) IS

    CURSOR cur_round_discrepancy_lines IS
    SELECT resource_assignment_id
                ,txn_currency_code
                ,MAX(start_date)
                ,SUM(quantity)
                ,SUM(init_quantity)
                ,SUM(txn_raw_cost)
                ,SUM(txn_init_raw_cost)
                ,SUM(txn_burdened_cost)
                ,SUM(txn_init_burdened_cost)
                ,SUM(txn_revenue)
                ,SUM(txn_init_revenue)
                ,SUM(((NVL(quantity,0) - nvl(init_quantity,0)) * nvl(rw_cost_rate_override,cost_rate))) unrounded_txn_raw_cost
                ,SUM(((NVL(quantity,0) - nvl(init_quantity,0)) * nvl(burden_cost_rate_override,burden_cost_rate))) unrounded_txn_burdened_cost
                ,SUM(((NVL(quantity,0) - nvl(init_quantity,0)) * nvl(bill_rate_override,bill_rate))) unrounded_txn_revenue
        ,SUM(decode(nvl(rw_cost_rate_override,nvl(cost_rate,0)),0,0
            ,pa_currency.round_trans_currency_amt1((nvl(txn_raw_cost,0) - nvl(txn_init_raw_cost,0)),txn_currency_code))) rounded_txn_raw_cost
        ,SUM(decode(nvl(burden_cost_rate_override,nvl(burden_cost_rate,0)),0,0
            ,pa_currency.round_trans_currency_amt1((nvl(txn_burdened_cost,0) - nvl(txn_init_burdened_cost,0)),txn_currency_code))) rounded_txn_burdened_cost
                ,SUM(decode(nvl(bill_rate_override,nvl(bill_rate,0)),0,0
            ,pa_currency.round_trans_currency_amt1((nvl(txn_revenue,0) - nvl(txn_init_revenue,0)),txn_currency_code))) rounded_txn_revenue
        /**
                ,SUM(pa_currency.round_trans_currency_amt1(((NVL(quantity,0) - nvl(init_quantity,0)) * nvl(rw_cost_rate_override,cost_rate))
            ,txn_currency_code)) rounded_txn_raw_cost
                ,SUM(pa_currency.round_trans_currency_amt1(((NVL(quantity,0) - nvl(init_quantity,0)) * nvl(burden_cost_rate_override,burden_cost_rate))
                        ,txn_currency_code)) rounded_txn_burdened_cost
                ,SUM(pa_currency.round_trans_currency_amt1(((NVL(quantity,0) - nvl(init_quantity,0)) * nvl(bill_rate_override,bill_rate))
            ,txn_currency_code)) rounded_txn_revenue
         **/
        ,to_number(NULL) diff_raw_cost
        ,to_number(NULL) diff_burden_cost
        ,to_number(NULL) diff_revenue
        FROM pa_fp_rollup_tmp tmp
    WHERE tmp.budget_version_id = p_budget_version_id
    AND  nvl(quantity,0) <> 0
    GROUP BY resource_assignment_id
                ,txn_currency_code ;

    l_return_status    varchar2(10);
    l_msg_count        Number;
    l_msg_data         varchar2(240);

        l_resource_assignment_tab       pa_plsql_datatypes.NumTabTyp;
        l_txn_currency_code_tab         pa_plsql_datatypes.Char50TabTyp;
        l_start_date_tab                pa_plsql_datatypes.DateTabTyp;
        l_quantity_tab                  pa_plsql_datatypes.NumTabTyp;
        l_init_quantity_tab             pa_plsql_datatypes.NumTabTyp;
        l_txn_raw_cost_tab              pa_plsql_datatypes.NumTabTyp;
        l_txn_init_raw_cost_tab         pa_plsql_datatypes.NumTabTyp;
        l_txn_burdened_cost_tab         pa_plsql_datatypes.NumTabTyp;
        l_txn_init_burdened_cost_tab    pa_plsql_datatypes.NumTabTyp;
        l_txn_revenue_tab               pa_plsql_datatypes.NumTabTyp;
        l_txn_init_revenue_tab          pa_plsql_datatypes.NumTabTyp;
    l_unrounded_txn_raw_cost_tab    pa_plsql_datatypes.NumTabTyp;
    l_unround_txn_burden_cost_tab   pa_plsql_datatypes.NumTabTyp;
    l_unrounded_txn_revenue_tab pa_plsql_datatypes.NumTabTyp;
    l_rounded_txn_raw_cost_tab  pa_plsql_datatypes.NumTabTyp;
    l_rounded_txn_burden_cost_tab   pa_plsql_datatypes.NumTabTyp;
    l_rounded_txn_revenue_tab   pa_plsql_datatypes.NumTabTyp;
    l_diff_raw_cost_tab         pa_plsql_datatypes.NumTabTyp;
    l_diff_burden_cost_tab      pa_plsql_datatypes.NumTabTyp;
    l_diff_revenue_tab      pa_plsql_datatypes.NumTabTyp;

    l_revenue_generation_method varchar2(10);
        l_null_revenue_amts_flag    varchar2(10);

BEGIN
    /* initialize the out variables */
    x_return_status := 'S';
    x_msg_count     := 0;
    x_msg_data      := NULL;
        l_return_status := 'S';
    l_msg_count := 0;
    l_msg_data      := NULL;
    IF p_pa_debug_mode = 'Y' Then
            pa_debug.init_err_stack('PA_FP_CALC_PLAN_PKG.Update_rounding_diff');
    End If;

    g_stage := 'Update_rounding_diff:100';
        pa_debug.g_err_stage := 'Entered Update_rounding_diff API';
    --print_msg(pa_debug.g_err_stage);

    IF p_wp_cost_enabled_flag = 'Y' Then
        /* initialize the plsql tabs */
        l_resource_assignment_tab.delete;
            l_txn_currency_code_tab.delete;
            l_start_date_tab.delete;
            l_quantity_tab.delete;
            l_init_quantity_tab.delete;
            l_txn_raw_cost_tab.delete;
            l_txn_init_raw_cost_tab.delete;
            l_txn_burdened_cost_tab.delete;
            l_txn_init_burdened_cost_tab.delete;
            l_txn_revenue_tab.delete;
            l_txn_init_revenue_tab.delete;
            l_unrounded_txn_raw_cost_tab.delete;
            l_unround_txn_burden_cost_tab.delete;
            l_unrounded_txn_revenue_tab.delete;
            l_rounded_txn_raw_cost_tab.delete;
            l_rounded_txn_burden_cost_tab.delete;
            l_rounded_txn_revenue_tab.delete ;
        l_diff_raw_cost_tab.delete;
            l_diff_burden_cost_tab.delete;
            l_diff_revenue_tab.delete;

        OPEN cur_round_discrepancy_lines;
        FETCH cur_round_discrepancy_lines BULK COLLECT INTO
            l_resource_assignment_tab
                    ,l_txn_currency_code_tab
                    ,l_start_date_tab
                    ,l_quantity_tab
                    ,l_init_quantity_tab
                    ,l_txn_raw_cost_tab
                    ,l_txn_init_raw_cost_tab
                    ,l_txn_burdened_cost_tab
                    ,l_txn_init_burdened_cost_tab
                    ,l_txn_revenue_tab
                    ,l_txn_init_revenue_tab
                    ,l_unrounded_txn_raw_cost_tab
                    ,l_unround_txn_burden_cost_tab
                    ,l_unrounded_txn_revenue_tab
                    ,l_rounded_txn_raw_cost_tab
                    ,l_rounded_txn_burden_cost_tab
                    ,l_rounded_txn_revenue_tab
            ,l_diff_raw_cost_tab
                    ,l_diff_burden_cost_tab
                    ,l_diff_revenue_tab;
        CLOSE cur_round_discrepancy_lines;
        g_stage := 'Update_rounding_diff:101';
        --print_msg('Number Of Lines fetched into plsql tabls['||l_resource_assignment_tab.count||']');
        IF l_resource_assignment_tab.COUNT > 0 Then
            FOR i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST LOOP
                l_diff_raw_cost_tab(i) := nvl(l_unrounded_txn_raw_cost_tab(i),0) - nvl(l_rounded_txn_raw_cost_tab(i),0);
                l_diff_burden_cost_tab(i) := nvl(l_unround_txn_burden_cost_tab(i),0) - nvl(l_rounded_txn_burden_cost_tab(i),0);
                l_diff_revenue_tab(i)  := nvl(l_unrounded_txn_revenue_tab(i),0) - nvl(l_rounded_txn_revenue_tab(i),0);
                l_diff_raw_cost_tab(i) := pa_currency.round_trans_currency_amt1(l_diff_raw_cost_tab(i),l_txn_currency_code_tab(i));
                l_diff_burden_cost_tab(i) := pa_currency.round_trans_currency_amt1(l_diff_burden_cost_tab(i),l_txn_currency_code_tab(i));
                l_diff_revenue_tab(i)  := pa_currency.round_trans_currency_amt1(l_diff_revenue_tab(i),l_txn_currency_code_tab(i));
            END LOOP;

            l_null_revenue_amts_flag := 'N';
            IF (p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION') AND p_budget_version_type = 'ALL'
                --Bug 6722414. When called from ETC client extension, Dont null out revenue amounts.
            AND NVL(g_from_etc_client_extn_flag,'N')='N') THEN
                l_revenue_generation_method := NVL(PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id),'W');
                        IF NVL(l_revenue_generation_method,'W') in ('C','E') Then
                    l_null_revenue_amts_flag := 'Y';
                End IF;
            END IF;
            g_stage := 'Update_rounding_diff:102';
            --print_msg('Updating rollup tmp last line with the rounding difference amount');
            FORALL i IN l_resource_assignment_tab.FIRST .. l_resource_assignment_tab.LAST
            UPDATE /*+ INDEX(TMP PA_FP_ROLLUP_TMP_N1) */ pa_fp_rollup_tmp tmp
                        SET tmp.txn_raw_cost = decode(p_budget_version_type,'COST'
                                                                ,DECODE((nvl(tmp.txn_raw_cost,0)+NVL(l_diff_raw_cost_tab(i),0)),0,NULL
                                                                        ,(nvl(tmp.txn_raw_cost,0)+NVL(l_diff_raw_cost_tab(i),0)))
                                                        ,'ALL',DECODE((nvl(tmp.txn_raw_cost,0)+NVL(l_diff_raw_cost_tab(i),0)),0,NULL
                                                                        ,(nvl(tmp.txn_raw_cost,0)+NVL(l_diff_raw_cost_tab(i),0)))
                                                        ,'REVENUE',tmp.txn_raw_cost)
                        ,tmp.txn_burdened_cost = decode(p_budget_version_type,'COST'
                                                                ,DECODE((nvl(tmp.txn_burdened_cost,0)+NVL(l_diff_burden_cost_tab(i),0)),0,NULL
                                                                        ,(nvl(tmp.txn_burdened_cost,0)+NVL(l_diff_burden_cost_tab(i),0)))
                                                        ,'ALL',DECODE((nvl(tmp.txn_burdened_cost,0)+NVL(l_diff_burden_cost_tab(i),0)),0,NULL
                                                                        ,(nvl(tmp.txn_burdened_cost,0)+NVL(l_diff_burden_cost_tab(i),0)))
                                                        ,'REVENUE',tmp.txn_burdened_cost)
                        ,tmp.txn_revenue = decode(p_budget_version_type,'COST',tmp.txn_revenue
                                                        ,'ALL',DECODE(l_null_revenue_amts_flag,'Y',tmp.txn_revenue
                                                                        ,DECODE((nvl(tmp.txn_revenue,0)+NVL(l_diff_revenue_tab(i),0)),0,NULL
                                                                          ,(nvl(tmp.txn_revenue,0)+NVL(l_diff_revenue_tab(i),0))))
                                                        ,'REVENUE',DECODE((nvl(tmp.txn_revenue,0)+NVL(l_diff_revenue_tab(i),0)),0,NULL
                                                                        ,(nvl(tmp.txn_revenue,0)+NVL(l_diff_revenue_tab(i),0))))
                        ,tmp.attribute15 = 'RoundingDiscrepancyLine'
                        WHERE tmp.resource_assignment_id = l_resource_assignment_tab(i)
                        AND   tmp.txn_currency_code = l_txn_currency_code_tab(i)
                        AND   tmp.start_date = l_start_date_tab(i)
                        AND   (NVL(l_diff_raw_cost_tab(i),0) <> 0 OR NVL(l_diff_burden_cost_tab(i),0) <> 0 OR NVL(l_diff_revenue_tab(i),0) <> 0)
            ;
            /** Bug fix: 4208217 Performance fix:  This is additional condition may not be necessary so commenting out
                        -- added this to ensure that only one budget line in rollup tmp gets updated even if there is duplicate lines
                        AND   tmp.rowid in (select max(rowid)
                                            from pa_fp_rollup_tmp tmp2
                                            where tmp2.resource_assignment_id = tmp.resource_assignment_id
                                            and tmp2.txn_currency_code = tmp.txn_currency_code
                                            and tmp2.start_date = tmp.start_date
                                           );
            **/
            g_stage := 'Update_rounding_diff:103';
                        --print_msg('Number of lines updated['||sql%rowcount||']');
        END IF;
    End If;

    x_return_status := l_return_status;
        x_msg_count     := l_msg_count;
        x_msg_data  := l_msg_data;
    g_stage := 'Update_rounding_diff:104';
    -- reset error stack
    IF p_pa_debug_mode = 'Y' Then
    	print_msg('End of Update_rounding_diff API return Sts['||x_return_status||']');
        pa_debug.reset_err_stack;
    End If;

EXCEPTION
    WHEN OTHERS THEN
                print_msg('Failed in Update_rounding_diff API ['||sqlcode||sqlerrm);
                x_return_status := 'U';
                x_msg_data := sqlcode||sqlerrm;
                fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                 ,p_procedure_name => 'Update_rounding_diff' );
                print_msg('Failed in Update_rounding_diff substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
        IF p_pa_debug_mode = 'Y' Then
            pa_debug.reset_err_stack;
        End If;
                RAISE;
END Update_rounding_diff;

/*
-- PROCEDURE validate_inputs validates all parameters that are passed into
--  calulate API.
--  1.  project_id, budget_version_id, and source_context are required
--  2.  IF p_resource_assignment_tab has a count > 0 THEN
--       txn_currency_code_tab must also have a count > 0 AND
--          txn_currency_code_tab.COUNT must equal p_resource_assignment_tab.COUNT
--  3.  p_resource_assignment_tab and txn_currency_code_tab must not have NULL values if passed
--  4.  If any other parameter is passed they must have an equal count to _resource_assignment_tab
*/
PROCEDURE validate_inputs( p_project_id                    IN  pa_projects_all.project_id%TYPE
                          ,p_budget_version_id             IN  pa_budget_versions.budget_version_id%TYPE
              ,p_calling_module                IN  VARCHAR2 DEFAULT NULL
                      ,p_refresh_rates_flag            IN  VARCHAR2 DEFAULT NULL
                      ,p_refresh_conv_rates_flag       IN  VARCHAR2 DEFAULT NULL
                          ,p_mass_adjust_flag              IN  VARCHAR2
              ,p_qty_adjust_pct                IN  NUMBER
              ,p_cst_rate_adjust_pct       IN  NUMBER
              ,p_bd_rate_adjust_pct        IN  NUMBER
              ,p_bill_rate_adjust_pct      IN  NUMBER
		,p_raw_cost_adj_pct              IN  NUMBER
                      ,p_burden_cost_adj_pct           IN  NUMBER
                      ,p_revenue_adj_pct               IN  NUMBER
                          ,p_spread_required_flag          IN  VARCHAR2
              ,p_wp_cost_changed_flag          IN  VARCHAR2
              ,p_time_phase_changed_flag       IN  VARCHAR2
                          ,p_source_context                IN  pa_fp_res_assignments_tmp.source_context%TYPE
                          ,p_resource_assignment_tab       IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                          ,p_delete_budget_lines_tab       IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
                          ,p_spread_amts_flag_tab          IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
                          ,p_txn_currency_code_tab         IN  SYSTEM.pa_varchar2_15_tbl_type    DEFAULT SYSTEM.pa_varchar2_15_tbl_type()
                          ,p_txn_currency_override_tab     IN  SYSTEM.pa_varchar2_15_tbl_type    DEFAULT SYSTEM.pa_varchar2_15_tbl_type()
                          ,p_total_qty_tab                 IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                          ,p_addl_qty_tab                  IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                          ,p_total_raw_cost_tab            IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                          ,p_addl_raw_cost_tab             IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                          ,p_total_burdened_cost_tab       IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                          ,p_addl_burdened_cost_tab        IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                          ,p_total_revenue_tab             IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                          ,p_addl_revenue_tab              IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                          ,p_raw_cost_rate_tab             IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                          ,p_rw_cost_rate_override_tab     IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                          ,p_b_cost_rate_tab               IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                          ,p_b_cost_rate_override_tab      IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                          ,p_bill_rate_tab                 IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                          ,p_bill_rate_override_tab        IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                          ,p_line_start_date_tab           IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
                          ,p_line_end_date_tab             IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
              /* for enhancement */
              ,p_spread_curve_id_old_tab       IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
              ,p_spread_curve_id_new_tab       IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
              ,p_sp_fixed_date_old_tab         IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
              ,p_sp_fixed_date_new_tab         IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
              ,p_plan_start_date_old_tab       IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
              ,p_plan_start_date_new_tab       IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
              ,p_plan_end_date_old_tab         IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
              ,p_plan_end_date_new_tab         IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
              ,p_re_spread_flag_tab            IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
              ,p_sp_curve_change_flag_tab      IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
              ,p_plan_dates_change_flag_tab    IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
              ,p_spfix_date_flag_tab           IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
              ,p_mfc_cost_change_flag_tab      IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
                          ,p_mfc_cost_type_id_old_tab      IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                          ,p_mfc_cost_type_id_new_tab      IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
              ,p_rlm_id_change_flag_tab        IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
          ,p_fp_task_billable_flag_tab     IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
                          ,x_return_status                 OUT NOCOPY VARCHAR2
                          ,x_msg_count                     OUT NOCOPY NUMBER
                          ,x_msg_data                      OUT NOCOPY VARCHAR2) IS



    l_res_assignment_tab_count NUMBER := 0;
    l_debug_mode               VARCHAR2(30);
    l_stage                    NUMBER;
    l_count                    NUMBER;
    l_msg_index_out            NUMBER;
    l_return_status            Varchar2(100);
    l_error_msg_code           Varchar2(100);
    l_act_exists               Varchar2(10) := 'N';

    CURSOR cur_act_exists IS
    SELECT 'Y'
    FROM dual
    WHERE EXISTS (select null
            from pa_budget_lines bl
            Where bl.budget_version_id = p_budget_version_id
            AND   (nvl(bl.init_quantity,0) <> 0
                OR nvl(bl.txn_init_raw_cost,0) <> 0
                OR nvl(bl.txn_init_burdened_cost,0) <> 0
                OR nvl(bl.txn_init_revenue,0) <> 0
                  )
            );

BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count     := NULL;
        x_msg_data      := NULL;
    l_return_status := 'S';
    IF p_pa_debug_mode = 'Y' Then
            pa_debug.init_err_stack('PA_FP_CALC_PLAN_PKG.validate_inputs');
            pa_debug.g_err_stage := 'Entered PA_FP_CALC_PLAN_PKG.validate_inputs';
    End If;
    g_stage := 'validate_inputs:100';
    /*
    --  Check to see if Budget_version_id, project_id, or source_context
    --  are null.  If they are NULL error and return.  These parameters
    --  are required to calculate
    */

        l_stage := 7010;

        IF p_budget_version_id IS NULL THEN
        l_error_msg_code := 'PA_FP_CALC_BUDGET_VER_ID_REQ';
                l_return_status := 'E';
    End IF ;

        IF l_return_status = 'S' AND p_project_id IS NULL THEN
        l_error_msg_code := 'PA_FP_CALC_PROJ_ID_REQ' ;
                l_return_status := 'E';
        End IF;

    If l_return_status = 'S' Then
        If p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION') Then /* Bug fix: 4251148 : added forecast generation*/
           If nvl(p_refresh_rates_flag,'N') NOT IN ('R','C','Y','N') Then
            l_error_msg_code := 'PA_FP_INVALID_REFRESH_FLAG';
                        l_return_status := 'E';
           End If;
        Else
           If nvl(p_refresh_rates_flag,'N') NOT IN ('Y','N') Then
                l_error_msg_code := 'PA_FP_INVALID_REFRESH_FLAG';
                        l_return_status := 'E';
                   End If;
        End If;
    End If;

    If l_return_status = 'S' Then
        IF nvl(p_wp_cost_changed_flag,'N') = 'Y' OR NVL(p_time_phase_changed_flag,'N') = 'Y' Then
            OPEN cur_act_exists;
            FETCH cur_act_exists INTO l_act_exists;
            IF cur_act_exists%NOTFOUND then
                l_act_exists := 'N';
            End If;
            CLOSE cur_act_exists;

            IF NVL(l_act_exists,'N') = 'Y' Then
                        l_error_msg_code := 'PA_FP_INVALID_WPTIMEPHASE';
                        l_return_status := 'E';
            End If;
        End If;
    End If;


        IF l_return_status = 'S' AND p_source_context IS NULL THEN
            pa_debug.g_err_stage := to_char(l_stage)||': Planning Transaction Calculate'
                                ||' requires Source Context.'
                                ||' Valid Values: RESOURCE_ASSIGNMENT or BUDGET_LINE'
                                ||' -- Returning';
            --print_msg('validate_inputs: ' || g_module_name||pa_debug.g_err_stage);
        l_error_msg_code := 'PA_FP_CALC_SRC_CONTEXT_REQ';
                l_return_status := 'E';
        End IF ;

/* Bug fix:5726773 : support negative quantity adustment
    IF l_return_status = 'S'  AND NVL(p_mass_adjust_flag,'N') = 'Y' THEN
        --print_msg('validate_inputs:  validating mass adjust params');
                IF ( p_qty_adjust_pct is not null AND p_qty_adjust_pct < -100 )
           OR (p_cst_rate_adjust_pct is not null AND p_cst_rate_adjust_pct < -100 )
           OR (p_bd_rate_adjust_pct is not null AND p_bd_rate_adjust_pct < -100 )
           OR (p_bill_rate_adjust_pct is not null AND p_bill_rate_adjust_pct < -100 )
	   OR (p_raw_cost_adj_pct is not null AND p_raw_cost_adj_pct < - 100 )
           OR (p_burden_cost_adj_pct is not null AND p_burden_cost_adj_pct < -100 )
           OR (p_revenue_adj_pct is not null AND p_revenue_adj_pct < - 100 )
             THEN

            --print_msg('validate_inputs: Invalid Mass Adjust Params');
                    l_error_msg_code := 'PA_FP_INVALID_MADJUST_PARAMS';
                    l_return_status := 'E';
        End If;
    END IF;
**/

    /*
    --  Check if p_resource_assignment_tab has values. > 0
    --   If p_resource_assignment_tab > 0 then check to make sure the following
    --   1.  p_txn_currency_code_tab > 0
    --   2.  p_resource_assignment_tab values are NOT NULL
    --   3.  p_txn_currency_code_tab values are NOT NULL
    --   4.  Any table parameter passed with a count > 0 has the same count as p_resource_assignment_tab
    */


        l_stage := 7060;
        l_res_assignment_tab_count := p_resource_assignment_tab.COUNT;
        --print_msg(to_char(l_stage)||' Check if p_resource_assignment_tab has a count['||l_res_assignment_tab_count||']');
        IF l_return_status = 'S' AND l_res_assignment_tab_count > 0 THEN
            IF l_res_assignment_tab_count <> p_txn_currency_code_tab.COUNT THEN
                print_msg('***ERROR*** p_resource_assignment_tab.COUNT <> p_txn_currency_code_tab.COUNT');
            l_error_msg_code := 'PA_FP_CALC_RA_CNT_CUR_CNT_NE';
                    l_return_status := 'E';
            --print_msg('ResTabCt['||l_res_assignment_tab_count||']CurTabCt['||p_txn_currency_code_tab.COUNT||']');
        End If;

        END IF;

        l_stage := 7070;
    IF l_return_status = 'S' AND p_resource_assignment_tab.COUNT > 0 Then
            FOR i IN p_resource_assignment_tab.FIRST..p_resource_assignment_tab.LAST LOOP
                IF p_resource_assignment_tab(i) is NULL THEN
                            l_error_msg_code := 'PA_FP_CALC_RA_ID_NULL';
                            l_return_status := 'E';
                EXIT;
                ELSIF p_txn_currency_code_tab(i) is NULL THEN
                                l_error_msg_code := 'PA_FP_CALC_CURR_CODE_NULL';
                                l_return_status := 'E';
                                EXIT;
            END IF;

            END LOOP;

    END IF;

        l_stage := 7090;
        IF l_return_status = 'S' AND p_delete_budget_lines_tab.COUNT > 0 THEN
            IF p_delete_budget_lines_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code := 'PA_FP_CALC_DEL_CNT';
                        l_return_status := 'E';
            --print_msg('ResTabCt['||l_res_assignment_tab_count||']DelBdgtLineCt['||p_delete_budget_lines_tab.COUNT||']');
        End If;
        END IF;

        l_stage := 7100;
        IF l_return_status = 'S' AND p_spread_amts_flag_tab.COUNT > 0 THEN
            IF p_spread_amts_flag_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code := 'PA_FP_CALC_SPR_CNT';
                        l_return_status := 'E';
            --print_msg('ResTabCt['||l_res_assignment_tab_count||']SprdAmtTabCt['||p_spread_amts_flag_tab.COUNT||']');
                End If;
    End IF;

        l_stage := 7110;
        IF l_return_status = 'S' AND p_txn_currency_override_tab.COUNT > 0 THEN
            IF p_txn_currency_override_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code := 'PA_FP_CALC_CUR_OVR_CNT';
                        l_return_status := 'E';
                End If;
        End IF;

        l_stage := 7120;
        IF l_return_status = 'S' AND p_total_qty_tab.COUNT > 0 THEN
            IF p_total_qty_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code := 'PA_FP_CALC_QTY_CNT' ;
                        l_return_status := 'E';
                End If;
        End IF;

        l_stage := 7130;
        IF l_return_status = 'S' AND p_addl_qty_tab.COUNT > 0 THEN
            IF p_addl_qty_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code := 'PA_FP_CALC_ADL_QTY_CNT';
                        l_return_status := 'E';
                End If;
        End IF;

        l_stage := 7140;
        IF l_return_status = 'S' AND p_total_raw_cost_tab.COUNT > 0 THEN
            IF p_total_raw_cost_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code := 'PA_FP_CALC_RW_CST_CNT';
                        l_return_status := 'E';
                End If;
        End IF;

        l_stage := 7150;
        IF l_return_status = 'S' AND p_addl_raw_cost_tab.COUNT > 0 THEN
            IF p_addl_raw_cost_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code := 'PA_FP_CALC_ADL_RW_CST_CNT';
                        l_return_status := 'E';
                End If;
    End If;

        l_stage := 7160;
        IF l_return_status = 'S' AND  p_total_burdened_cost_tab.COUNT > 0 THEN
            IF p_total_burdened_cost_tab.COUNT <> l_res_assignment_tab_count THEN
            l_error_msg_code := 'PA_FP_CALC_BD_CST_CNT';
                        l_return_status := 'E';
                End If;
        End If;

        l_stage := 7170;
        IF l_return_status = 'S' AND p_addl_burdened_cost_tab.COUNT > 0 THEN
            IF p_addl_burdened_cost_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code := 'PA_FP_CALC_ADL_BD_CST_CNT';
                        l_return_status := 'E';
                End If;
        End If;

        l_stage := 7180;
        IF l_return_status = 'S' AND p_total_revenue_tab.COUNT > 0 THEN
            IF p_total_revenue_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code := 'PA_FP_CALC_REV_CNT';
                        l_return_status := 'E';
                End If;
        End If;


        l_stage := 7190;
        IF l_return_status = 'S' AND  p_addl_revenue_tab.COUNT > 0 THEN
            IF p_addl_revenue_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code := 'PA_FP_CALC_ADL_REV_CNT';
                        l_return_status := 'E';
                End If;
        End If;

        l_stage := 7200;
        IF l_return_status = 'S' AND  p_raw_cost_rate_tab.COUNT > 0 THEN
            IF p_raw_cost_rate_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code := 'PA_FP_CALC_RW_RATE_CNT';
                        l_return_status := 'E';
                End If;
        End If;

        l_stage := 7210;
        IF l_return_status = 'S' AND p_rw_cost_rate_override_tab.COUNT > 0 THEN
            IF p_rw_cost_rate_override_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code := 'PA_FP_CALC_RW_RATE_OVR_CNT';
                        l_return_status := 'E';
                End If;
        End If;

        l_stage := 7220;
        IF l_return_status = 'S' AND p_b_cost_rate_tab.COUNT > 0 THEN
            IF p_b_cost_rate_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code := 'PA_FP_CALC_BD_MULT_CNT';
                        l_return_status := 'E';
                End If;
        End If;

        l_stage := 7230;
        IF l_return_status = 'S' AND p_b_cost_rate_override_tab.COUNT > 0 THEN
            IF p_b_cost_rate_override_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code :=  'PA_FP_CALC_BD_MULT_OVR_CNT';
                        l_return_status := 'E';
                End If;
        End If;

        l_stage := 7240;
        IF l_return_status = 'S' AND p_bill_rate_tab.COUNT > 0 THEN
            IF p_bill_rate_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code :=  'PA_FP_CALC_BILL_RATE_CNT';
                        l_return_status := 'E';
                End If;
        End If;

        l_stage := 7250;
        IF l_return_status = 'S' AND p_bill_rate_override_tab.COUNT > 0 THEN
            IF p_bill_rate_override_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code :=  'PA_FP_CALC_BILL_RATE_OVR_CNT';
                        l_return_status := 'E';
                End If;
        End If;

        l_stage := 7260;
        IF l_return_status = 'S' AND p_line_start_date_tab.COUNT > 0 THEN
            IF p_line_start_date_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code :=   'PA_FP_CALC_START_DT_CNT';
                        l_return_status := 'E';
                End If;
        End If;

        l_stage := 7270;
        IF l_return_status = 'S' AND p_line_end_date_tab.COUNT > 0 THEN
            IF p_line_end_date_tab.COUNT <> l_res_assignment_tab_count THEN
                        l_error_msg_code :=  'PA_FP_CALC_END_DT_CNT';
                        l_return_status := 'E';
                End If;
        End If;

        l_stage := 7280;
    /*--------- p_mass_adjust_flag check ----------*/
        IF l_return_status = 'S' AND  p_mass_adjust_flag = 'Y' THEN
            IF p_resource_assignment_tab.COUNT = 0 THEN
            l_error_msg_code :=  'PA_FP_MA_RA_ID_REQ';
                        l_return_status := 'E';
        Elsif p_txn_currency_code_tab.COUNT = 0 THEN
            l_error_msg_code :=  'PA_FP_MA_CURR_REQ';
                        l_return_status := 'E';
                End If;
        End If;

    If l_return_status = 'S' AND p_spread_curve_id_old_tab.count > 0 Then
        If p_resource_assignment_tab.COUNT <> p_spread_curve_id_old_tab.count Then
            l_error_msg_code :=  'PA_FP_SPCURVE_ID_CNT';
                        l_return_status := 'E';
        End If;
    End If;

        If l_return_status = 'S' AND p_spread_curve_id_new_tab.count > 0 Then
                If p_resource_assignment_tab.COUNT <> p_spread_curve_id_new_tab.count Then
                        l_error_msg_code :=  'PA_FP_SPCURVE_ID_CNT';
                        l_return_status := 'E';
                End If;
        End If;

        If l_return_status = 'S' AND p_sp_fixed_date_old_tab.count > 0 Then
                If p_resource_assignment_tab.COUNT <> p_sp_fixed_date_old_tab.count Then
                        l_error_msg_code :=  'PA_FP_SPFIXED_DATE_CNT';
                        l_return_status := 'E';
                End If;
        End If;
        If l_return_status = 'S' AND p_sp_fixed_date_new_tab.count > 0 Then
                If p_resource_assignment_tab.COUNT <> p_sp_fixed_date_new_tab.count Then
                        l_error_msg_code :=  'PA_FP_SPFIXED_DATE_CNT';
                        l_return_status := 'E';
                End If;
        End If;
        If l_return_status = 'S' AND p_plan_start_date_old_tab.count > 0 Then
                If p_resource_assignment_tab.COUNT <> p_plan_start_date_old_tab.count Then
                        l_error_msg_code :=  'PA_FP_PLAN_DATE_CNT';
                        l_return_status := 'E';
                End If;
        End If;
        If l_return_status = 'S' AND p_plan_start_date_new_tab.count > 0 Then
                If p_resource_assignment_tab.COUNT <> p_plan_start_date_new_tab.count Then
                        l_error_msg_code :=  'PA_FP_PLAN_DATE_CNT';
                        l_return_status := 'E';
                End If;
        End If;
        If l_return_status = 'S' AND p_plan_end_date_old_tab.count > 0 Then
                If p_resource_assignment_tab.COUNT <> p_plan_end_date_old_tab.count Then
                        l_error_msg_code :=  'PA_FP_PLAN_DATE_CNT';
                        l_return_status := 'E';
                End If;
        End If;
        If l_return_status = 'S' AND p_plan_end_date_new_tab.count > 0 Then
                If p_resource_assignment_tab.COUNT <> p_plan_end_date_new_tab.count Then
                        l_error_msg_code :=  'PA_FP_PLAN_DATE_CNT';
                        l_return_status := 'E';
                End If;
        End If;

        If l_return_status = 'S' AND p_re_spread_flag_tab.count > 0 Then
                If p_resource_assignment_tab.COUNT <> p_re_spread_flag_tab.count Then
                        l_error_msg_code :=  'PA_FP_RESPREAD_FLAG_CNT';
                        l_return_status := 'E';
                End If;
        End If;

        If l_return_status = 'S' AND p_sp_curve_change_flag_tab.count > 0 Then
                If p_resource_assignment_tab.COUNT <> p_sp_curve_change_flag_tab.count Then
                        l_error_msg_code :=  'PA_FP_SPCURVE_FLAG_CNT';
                        l_return_status := 'E';
                End If;
        End If;
        If l_return_status = 'S' AND p_plan_dates_change_flag_tab.count > 0 Then
                If p_resource_assignment_tab.COUNT <> p_plan_dates_change_flag_tab.count Then
                        l_error_msg_code :=  'PA_FP_PLANDATES_FLAG_CNT';
                        l_return_status := 'E';
                End If;
        End If;
        If l_return_status = 'S' AND p_spfix_date_flag_tab.count > 0 Then
                If p_resource_assignment_tab.COUNT <> p_spfix_date_flag_tab.count Then
                        l_error_msg_code :=  'PA_FP_FIXDATES_FLAG_CNT';
                        l_return_status := 'E';
                End If;
        End If;
    If l_return_status = 'S' AND p_mfc_cost_change_flag_tab.count > 0 Then
                If p_resource_assignment_tab.COUNT <> p_mfc_cost_change_flag_tab.count Then
                        l_error_msg_code :=  'PA_FP_MFCFLAG_FLAG_CNT';
                        l_return_status := 'E';
                End If;
        End If;
    If l_return_status = 'S' AND p_mfc_cost_type_id_old_tab.count > 0 Then
                If p_resource_assignment_tab.COUNT <> p_mfc_cost_type_id_old_tab.count Then
                        l_error_msg_code :=  'PA_FP_MFCOSTTYPE_CNT';
                        l_return_status := 'E';
                End If;
        End If;
    If l_return_status = 'S' AND p_mfc_cost_type_id_new_tab.count > 0 Then
                If p_resource_assignment_tab.COUNT <> p_mfc_cost_type_id_new_tab.count Then
                        l_error_msg_code :=  'PA_FP_MFCOSTTYPE_CNT';
                        l_return_status := 'E';
                End If;
        End If;
    If l_return_status = 'S' AND p_rlm_id_change_flag_tab.count > 0 Then
                If p_resource_assignment_tab.COUNT <> p_rlm_id_change_flag_tab.count Then
                        l_error_msg_code :=  'PA_FP_MFCFLAG_FLAG_CNT';
                        l_return_status := 'E';
                End If;
        End If;

    If l_return_status = 'S' and p_fp_task_billable_flag_tab.count > 0 Then
        If p_resource_assignment_tab.COUNT <> p_fp_task_billable_flag_tab.count Then
            l_error_msg_code :=  'PA_FP_BILLABLE_FLAG_CNT';
                        l_return_status := 'E';
                End If;
    End If;

     g_stage := 'validate_inputs:101';
    IF l_return_status <> 'S' AND l_error_msg_code is NOT NULL Then
              ADD_MSGTO_STACK
              (p_msg_name       => l_error_msg_code
              ,p_token1         => 'P_BUDGET_VERSION_ID'
              ,p_value1         => p_budget_version_id
              ,p_token2         => 'P_PROJECT_ID'
              ,p_value2         => p_project_id
              );
    END IF;
    x_return_status := l_return_status;
    IF p_pa_debug_mode = 'Y' Then
    	print_msg('Leaving validate_inputs x_return_status : '||x_return_status);
        pa_debug.reset_err_stack;
    End If;

EXCEPTION
    WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SQLCODE||SQLERRM;
            fnd_msg_pub.add_exc_msg
            ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                 ,p_procedure_name => 'validate_inputs' );
            print_msg(to_char(l_stage)||' substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
        IF p_pa_debug_mode = 'Y' Then
                pa_debug.reset_err_stack;
        End If;
            RAISE;

END validate_inputs;

/* This API will reset the planning end to ETC start date if both planning start and end dates are
 * prior to ETC start date
 */
PROCEDURE Reset_Planning_end_date
        (p_calling_module     IN Varchar2
        ,p_budget_version_id      IN Number
        ,p_etc_start_date         IN Date
                --,p_res_ass_id             IN Number
                ,p_source_context         IN Varchar2
        ,x_return_status          OUT NOCOPY Varchar2
                ,x_msg_data               OUT NOCOPY Varchar2
        ) IS

    l_planning_start_date  Date;
        l_planning_end_date    Date;
        l_etc_start_date       Date;
    l_stage                Number;

    CURSOR cur_EvenSpCur IS
    SELECT sp.spread_curve_id
    FROM pa_spread_curves_b sp
    WHERE sp.spread_curve_code = 'EVEN'
    AND  rownum = 1;
    l_evenSpCurveId  NUMBER;
BEGIN
    x_return_status := 'S';
    x_msg_data      := NULL;
    l_stage         := 1.1;

        IF p_etc_start_date is NOT NULL Then
        /* Bug fix: 3846468 when progress date is later than the spread curve fixed, the spread curve and sp fixed date
            * should be made as null.  Else the spread will fail OR put the entire etc in the sp_fixed_date which is prior to
            * to etc start date
            */
        l_evenSpCurveId := NULL;
        OPEN cur_EvenSpCur;
        FETCH cur_EvenSpCur INTO l_evenSpCurveId;
        CLOSE cur_EvenSpCur;

        g_stage :='Reset_Planning_end_date:100';
                UPDATE PA_RESOURCE_ASSIGNMENTS ra
                SET     ra.spread_curve_id = DECODE(ra.spread_curve_id,6
                            ,decode(sign(nvl(ra.sp_fixed_date,p_etc_start_date) - p_etc_start_date),-1,l_evenSpCurveId,ra.spread_curve_id)
                             ,ra.spread_curve_id)
                        ,ra.sp_fixed_date = DECODE(sign(nvl(ra.sp_fixed_date,p_etc_start_date) - p_etc_start_date),-1,NULL,ra.sp_fixed_date)
            /*Bug fix:4122400--,ra.planning_end_date = DECODE(sign(ra.planning_end_date-p_etc_start_date),-1,p_etc_start_date,ra.planning_end_date) */
            ,ra.planning_end_date = DECODE(ra.spread_curve_id,6
                                                 ,decode(sign(nvl(ra.sp_fixed_date,p_etc_start_date) - p_etc_start_date),-1,p_etc_start_date,ra.planning_end_date)
                                                  ,decode(sign(ra.planning_end_date-p_etc_start_date),-1,p_etc_start_date,ra.planning_end_date))
                WHERE ra.budget_version_id = p_budget_version_id
        AND  EXISTS (SELECT null
                 FROM pa_fp_spread_calc_tmp tmp
                 WHERE tmp.budget_version_id = ra.budget_version_id
                 AND   tmp.resource_assignment_id = ra.resource_assignment_id);
        print_msg('Reset Ra sp curve, spfixeddate, and planEnddate: NumofRowsUpd['||sql%rowcount||']');

        IF NVL(g_time_phased_code,'N') NOT IN ('G','P') THEN
           /* For Non-Time phase budgets, Update the budget lines with planning start and planning end dates */
           g_stage :='Reset_Planning_end_date:101';
           -- bug 8512066 skkoppul : updating the start date as well coz budget line dates
           -- should match the resource assignements dates in a non time phase context
           UPDATE pa_budget_lines bl
           SET ( bl.start_date, bl.end_date ) = (select ra.planning_start_date, ra.planning_end_date
                   From pa_resource_assignments ra
                   Where ra.resource_assignment_id = bl.resource_assignment_id)
           WHERE bl.budget_version_id = p_budget_version_id
           AND EXISTS ( SELECT 'Y'
                 FROM pa_resource_assignments pra
                ,pa_fp_spread_calc_tmp tmp
                 WHERE pra.resource_assignment_id = bl.resource_assignment_id
                 AND   pra.budget_version_id = bl.budget_version_id
                 AND   tmp.budget_version_id = pra.budget_version_id
                 AND   tmp.resource_assignment_id = pra.resource_assignment_id
              );
           --print_msg('Num Of BdgtLine rows updated with PlEnd date for Non-TimePhase budget['||sql%rowcount||']');
        END IF;

        End If;
    Return;

EXCEPTION
    WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                x_msg_data := SQLCODE||SQLERRM;
        print_msg('Errored in Reset_Planning_end_date API ['||x_msg_data||']');
                fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                 ,p_procedure_name => 'Reset_Planning_end_date');
                print_msg(to_char(l_stage)||' substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
                RAISE;
END Reset_Planning_end_date;

/* This api bulk updates the resource assignments table for the fixed date spread curve which are having
 * more than one budget line
 */
PROCEDURE PreProcess_BlkProgress_lines
    (p_budget_version_id      IN Number
    ,p_etc_start_date         IN Date
    ,p_apply_progress_flag    IN Varchar2
    ,x_return_status          OUT NOCOPY Varchar2
        ,x_msg_data               OUT NOCOPY Varchar2
        ) IS

        CURSOR cur_spbl_chk IS
        SELECT tmp.resource_assignment_id
        FROM pa_fp_spread_calc_tmp tmp
             ,pa_resource_assignments ra
        WHERE tmp.budget_version_id = p_budget_version_id
        AND  tmp.resource_assignment_id = ra.resource_assignment_id
    AND  NVL(tmp.sp_curve_change_flag,'N') = 'N'
        /* Bug fix: AND  ra.sp_fixed_date is NOT NULL this is commented as in some ofthe flows,
     * the sp fixed date is null but spread curve is 6 */
        AND  ra.spread_curve_id = 6
        AND  EXISTS ( select null
                        from pa_budget_lines bl
                        where bl.budget_version_id = p_budget_version_id
                        and   bl.resource_assignment_id = ra.resource_assignment_id
                        and   bl.txn_currency_code = tmp.txn_currency_code
                        group by bl.resource_assignment_id
                                ,bl.txn_currency_code
                        having count(*) > 1
                        );

        l_raId_tab      pa_plsql_datatypes.NumTabTyp;
    l_return_status varchar2(10) := 'S';
        l_msg_count     Number;
        l_msg_data      Varchar2(1000);

    CURSOR cur_EvenSpCur IS
        SELECT sp.spread_curve_id
        FROM pa_spread_curves_b sp
        WHERE sp.spread_curve_code = 'EVEN'
        AND  rownum = 1;
        l_evenSpCurveId  NUMBER;

    /* This cursor picks the budget lines for the open periods where plan quantity is Less than actuals
         * this should not happen. Ideally when the actuals were collected for the resource if plan < actual
     * then plan should be made equal to actual and etc should be zero
     */
    CURSOR cur_NegEtcLines IS
        SELECT /*+ NO_UNNEST INDEX (BL,PA_BUDGET_LINES_U1) */ bl.budget_line_id -- bug 4873834
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
              ,bl.raw_cost      projfunc_raw_cost
              ,bl.burdened_cost projfunc_burdened_cost
              ,bl.revenue       projfunc_revenue
              ,bl.project_currency_code
              ,bl.projfunc_currency_code
              ,bl.cost_rejection_code
              ,bl.revenue_rejection_code
              ,bl.burden_rejection_code
              ,bl.pfc_cur_conv_rejection_code
              ,bl.pc_cur_conv_rejection_code
              ,bl.init_quantity
              ,bl.txn_init_raw_cost
              ,bl.txn_init_burdened_cost
              ,bl.txn_init_revenue
              ,bl.project_init_raw_cost
              ,bl.project_init_burdened_cost
              ,bl.project_init_revenue
              ,bl.init_raw_cost
              ,bl.init_burdened_cost
              ,bl.init_revenue
        FROM pa_budget_lines bl
         ,pa_fp_spread_calc_tmp tmp
        WHERE tmp.budget_version_id = p_budget_version_id
    AND   bl.budget_version_id = tmp.budget_version_id
    AND   bl.resource_assignment_id = tmp.resource_assignment_id
        AND   bl.txn_currency_code      = tmp.txn_currency_code
        AND g_spread_from_date is NOT NULL
        AND ((bl.start_date >= g_spread_from_date )
             OR (g_spread_from_date BETWEEN bl.start_date AND bl.end_date)
            )
    AND (NVL(bl.quantity,0) - NVL(bl.init_quantity,0)) < 0  --corrupted data
        AND ( NVL(bl.init_quantity,0) <> 0 OR
                 NVL(bl.txn_init_raw_cost ,0) <> 0 OR
                 NVL(bl.txn_init_burdened_cost ,0) <> 0 OR
                 NVL(bl.txn_init_revenue ,0) <> 0
           );


BEGIN
        l_return_status := 'S';
        x_return_status := 'S';
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Entered PreProcess_BlkProgress_lines api ()');
	End If;
        IF p_etc_start_date is NOT NULL Then
                g_stage :='PreProcess_BlkProgress_lines:100';
                /*check and clear spread details on RA when there are multiple budget lines
                * exists for spread curve fixed date. Ideally, for spread fixed date thers should be only one budget line
                * but when actuals come in it may be in different period and budget line will be created where the
                * as of date.
                */
                l_raId_tab.delete;
                OPEN cur_spbl_chk;
                FETCH cur_spbl_chk BULK COLLECT INTO
                        l_raId_tab;
                CLOSE cur_spbl_chk;

                IF l_raId_tab.COUNT > 0 Then
            l_evenSpCurveId := NULL;
                    OPEN cur_EvenSpCur;
                    FETCH cur_EvenSpCur INTO l_evenSpCurveId;
                    CLOSE cur_EvenSpCur;

                        --print_msg('More than one budget Line exists for Spread Curve Fixed Date');
                        FORALL i IN l_raId_tab.FIRST .. l_raId_tab.LAST
                        /* update the RA and set sp_fixed_date to null so that spread api will spread the amts evenly */
                        UPDATE PA_RESOURCE_ASSIGNMENTS ra
                        SET    ra.spread_curve_id = l_evenSpCurveId
                                ,ra.sp_fixed_date = NULL
                                /* bug fix:4122400 for fixed date spread curve, change the plan end date as ETC start date */
                                /* Bug fix: 4247427 ,ra.planning_end_date = p_etc_start_date
                 * ETc start date can be before plannig end date, then donot change the end date */
                ,ra.planning_end_date = decode(sign(ra.planning_end_date-p_etc_start_date),-1,p_etc_start_date,ra.planning_end_date)
                        WHERE ra.resource_assignment_id = l_raId_tab(i);

                End If;


        If ( nvl(g_wp_version_flag,'N') = 'Y'
             --NVL(p_apply_progress_flag,'N') = 'Y'
           )  Then
               FOR i IN cur_NegEtcLines LOOP
                    --print_msg('Corrupted BudgetLines(-ve ETCs) Exists for Open period: RAID['||i.resource_assignment_id||']');
                        add_msgto_stack
                        ( p_msg_name       => 'PA_NEGETC_EXISTS_OPEN_PERIOD'
                        ,p_token1         => 'PROJECT'
                        ,p_value1         => g_project_name
                        ,p_token2         => 'RESOURCE_ASSIGNMENT'
                        ,p_value2         => i.resource_assignment_id
                        ,p_token3         => 'TXN_CURRENCY_CODE'
                        ,p_value3         => i.txn_currency_code
                        ,p_token4         => 'START_DATE'
                        ,p_value4         => i.start_date);
                        x_return_status := 'E';
               END LOOP;
            End If;
    End If;
        g_stage := 'PreProcess_BlkProgress_lines:101';
        x_return_status := l_return_status;
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Leaving PreProcess_BlkProgress_lines api() retSts['||x_return_status||']');
	End If;
EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'U';
                print_msg('Exception occured in PreProcess_BlkProgress_lines ['||sqlcode||sqlerrm);
                RAISE;

END PreProcess_BlkProgress_lines;

/* This API pre process the budget lines when calculate api is called in Apply progress mode */
PROCEDURE Pre_process_progress_lines
              (p_budget_version_id  IN Number
          ,p_res_ass_id         IN Number
              ,p_txn_currency_code  IN Varchar2
              ,p_line_start_date    IN Date
              ,p_line_end_date      IN Date
          ,p_etc_start_date         IN Date
          ,p_source_context         IN Varchar2
              ,p_actuals_exists_flag    IN Varchar2
          ,x_apply_progress_flag    IN OUT NOCOPY Varchar2
          ,x_spread_amount_flag     IN OUT NOCOPY Varchar2
              ,x_return_status      OUT NOCOPY Varchar2
          ,x_msg_data               OUT NOCOPY Varchar2
              ) IS

    l_return_status varchar2(10) := 'S';
    l_exists_flag   varchar2(10);
    l_msg_count     Number;
    l_msg_data      Varchar2(1000);
    l_num_rowsdeleted Number;
    l_spread_amounts_flag  Varchar2(10);
    l_app_prg_flag   Varchar2(10);
    INVALID_EXCPETION    EXCEPTION;


    CURSOR cur_sp_bl_chk IS
    SELECT 'Y'
    FROM DUAL
    WHERE EXISTS (select null
            from pa_budget_lines bl
                 ,pa_resource_assignments ra
            where ra.resource_assignment_id = p_res_ass_id
            and   bl.resource_assignment_id = ra.resource_assignment_id
            and   bl.txn_currency_code = p_txn_currency_code
            and   ra.sp_fixed_date is NOT NULL
            and   ra.spread_curve_id  = 6
            group by bl.resource_assignment_id
                                ,bl.txn_currency_code
                        having count(*) > 1
            );

    CURSOR cur_EvenSpCur IS
        SELECT sp.spread_curve_id
        FROM pa_spread_curves_b sp
        WHERE sp.spread_curve_code = 'EVEN'
        AND  rownum = 1;
        l_evenSpCurveId  NUMBER;

BEGIN
    l_return_status := 'S';
    x_return_status := 'S';
    l_spread_amounts_flag := x_spread_amount_flag;
    l_app_prg_flag := x_apply_progress_flag;
    If P_PA_DEBUG_MODE = 'Y' Then
    print_msg('Entered Pre_process_progress_lines api ()');
    End If;

    IF p_etc_start_date is NOT NULL Then
        g_stage :='Pre_process_progress_lines:100';
        /*check and clear spread details on RA when there are multiple budget lines
            * exists for spread curve fixed date. Ideally, for spread fixed date thers should be only one budget line
            * but when actuals come in it may be in different period and budget line will be created where the
            * as of date.
            */
        l_exists_flag := 'N';
        OPEN cur_sp_bl_chk;
        FETCH cur_sp_bl_chk INTO l_exists_flag;
        CLOSE cur_sp_bl_chk;

        IF l_exists_flag = 'Y'  Then
            l_evenSpCurveId := NULL;
                        OPEN cur_EvenSpCur;
                        FETCH cur_EvenSpCur INTO l_evenSpCurveId;
                        CLOSE cur_EvenSpCur;
            --print_msg('More than one budget Line exists for Spread Curve Fixed Date');
            /* update the RA and set sp_fixed_date to null so that spread api will spread the amts evenly */
            UPDATE PA_RESOURCE_ASSIGNMENTS ra
            SET    ra.spread_curve_id = l_evenSpCurveId
                ,ra.sp_fixed_date = NULL
                /* bug fix:4122400 for fixed date spread curve, change the plan end date as ETC start date */
                                ,ra.planning_end_date = p_etc_start_date
            WHERE ra.resource_assignment_id = p_res_ass_id;

        End If;
                /* call delete budget lines to delete all the lines so that spread will respred the ETC qty */
                /* Bug fix: 4142150 When progress is applied, the quantity should be spread based on
                 * exisitng line distribution method, so donot delete the budget lines
                delete_budget_lines
                ( p_budget_version_id         => p_budget_version_id
                ,p_resource_assignment_id    => p_res_ass_id
                ,p_txn_currency_code          => p_txn_currency_code
                ,p_line_start_date            => p_line_start_date
                ,p_line_end_date              => p_line_end_date
                ,p_source_context             => p_source_context
                ,x_return_status              => l_return_status
                ,x_msg_count                  => l_msg_count
                ,x_msg_data                   => l_msg_data
                ,x_num_rowsdeleted            => l_num_rowsdeleted
                );
                --print_msg('After Calling delete_budget_lines retSts['||l_return_status||']NumRowsDeleted['||l_num_rowsdeleted||']');
                IF l_return_status <> 'S' Then
                        print_msg('Unexpected error from delete_budget_lines');
                        x_msg_data := l_msg_data;
                        RAISE INVALID_EXCPETION;
                END If;
                --setting this flag to tell spread api to spread amounts creating new budget lines
                l_spread_amounts_flag := 'Y';

                --* if actuals donot exists then ETC should be spread in a normal way
                --* so set the apply progress flag to N
                --*
                If NVL(p_actuals_exists_flag,'N') <> 'Y' Then
                        --print_msg('Resetting the l_apply_progress_flag Flag to N');
                        -- if we set the apply progress falg to N the we cannot retain the rate override
                        -- apply progress always calls calculate api with qty and cost needs to check with sanjay
                        l_app_prg_flag := 'N';
                End If;
                ** end of bug fix:4142150 */
    End If;
    g_stage := 'Pre_process_progress_lines:101';
    x_return_status := l_return_status;
    x_spread_amount_flag := l_spread_amounts_flag;
    x_apply_progress_flag := l_app_prg_flag;
    If P_PA_DEBUG_MODE = 'Y' Then
    print_msg('Leaving Pre_process_progress_lines api() retSts['||x_return_status||']SpreadFlag['||x_spread_amount_flag||']x_apply_progress_flag['||x_apply_progress_flag||']');
    End If;
EXCEPTION
    WHEN INVALID_EXCPETION THEN
        x_return_status := l_return_status;
                print_msg('Invalid Exception occured in Pre_process_progress_lines ['||sqlcode||sqlerrm);
                RAISE;
    WHEN OTHERS THEN
        x_return_status := 'U';
        print_msg('Exception occured in Pre_process_progress_lines ['||sqlcode||sqlerrm);
        RAISE;

END Pre_process_progress_lines;


/* This API provides the agreement related details
 * Bug fix: 3679142 Change order versions which have revenue impact should also be in agreement
 * currency. This means all change order versions with version type as ALL or REVENUE
 * should ultimately have the planning txns and budget lines in AGR CURRENCY.
*/
PROCEDURE Get_Agreement_Details
    (p_budget_version_id  IN Number
    ,x_agr_curr_code      OUT NOCOPY Varchar2
    ,x_return_status      OUT NOCOPY Varchar2 ) IS

    l_agreement_id Number;
    l_ci_id       Number;
    l_agr_curr_code Varchar2(100);
    l_agr_con_reqd_flag varchar2(1) := 'N';
    l_version_name   pa_budget_versions.version_name%type;
    l_version_type   pa_budget_versions.version_type%type;
    l_error_msg_code Varchar2(100);
    INVALID_EXCEPTION  EXCEPTION;
BEGIN
    IF p_pa_debug_mode = 'Y' Then
        pa_debug.init_err_stack('PA_FP_CALC_PLAN_PKG.Get_Agreement_Details');
    	print_msg('Entered Get_Agreement_Details Api');
    End If;
    x_return_status := 'S';

    If p_budget_version_id is NOT NULL Then
        --print_msg('Calling PA_FIN_PLAN_UTILS2.Get_Agreement_Details api()');
        g_stage :='Get_Agreement_Details:100';
        PA_FIN_PLAN_UTILS2.Get_Agreement_Details
            (p_budget_version_id  => p_budget_version_id
            ,x_agr_curr_code      => x_agr_curr_code
        ,x_agr_conv_reqd_flag => l_agr_con_reqd_flag
            ,x_return_status      => x_return_status
        );
        --print_msg('After calling PA_FIN_PLAN_UTILS2.Get_Agreement_Details retSts['||x_return_status||']');
        --print_msg('agrCur['||x_agr_curr_code||']Flag['||l_agr_con_reqd_flag||']');
    End If;

    /* Set the global varaibles to call conv rates api*/
    G_AGR_CONV_REQD_FLAG := NVL(l_agr_con_reqd_flag,'N');
    G_AGR_CURRENCY_CODE  := x_agr_curr_code;
    --print_msg('Leaving Get_Agreement_Details G_AGR_CONV_REQD_FLAG['||G_AGR_CONV_REQD_FLAG||']G_AGR_CURRENCY_CODE['||G_AGR_CURRENCY_CODE||']');
    -- reset error stack
    IF p_pa_debug_mode = 'Y' Then
            pa_debug.reset_err_stack;
    End If;

EXCEPTION

    WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                 ,p_procedure_name => 'Get_Agreement_Details' );
                print_msg('Failed in Get_Agreement_Details substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
        IF p_pa_debug_mode = 'Y' Then
                    pa_debug.reset_err_stack;
        End If;
        RAISE;
END Get_Agreement_Details;

/* This API will clear out all the qty,amt,rate columns on
 * budget lines where etc amt are NOT zero prior to etc start date
 */
PROCEDURE clear_closed_period_etcs
        (p_budget_version_id  IN Number
        ,p_etc_start_date   IN Date
        ,x_return_status    OUT NOCOPY Varchar2 ) IS

    /* clear out all the budget lines prior to ETC start date where actuals donot exists
         */
    CURSOR cur_bl_closed_period is
    SELECT /*+ INDEX(BL PA_BUDGET_LINES_U1) */
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
          ,bl.project_raw_cost
          ,bl.project_burdened_cost
          ,bl.project_revenue
          ,bl.raw_cost  projfunc_raw_cost
          ,bl.burdened_cost projfunc_burdened_cost
          ,bl.revenue   projfunc_revenue
          ,bl.project_currency_code
          ,bl.projfunc_currency_code
          ,bl.cost_rejection_code
              ,bl.revenue_rejection_code
              ,bl.burden_rejection_code
              ,bl.pfc_cur_conv_rejection_code
              ,bl.pc_cur_conv_rejection_code
    FROM pa_budget_lines bl
        ,pa_fp_spread_calc_tmp tmp
    WHERE tmp.budget_version_id = p_budget_version_id
    AND  bl.resource_assignment_id = tmp.resource_assignment_id
    AND  bl.txn_currency_code = tmp.txn_currency_code
    AND  bl.start_date < p_etc_start_date
    AND  bl.end_date < p_etc_start_date
    AND  ( (NVL(bl.quantity,0) - NVl(bl.init_quantity,0)) <> 0
         OR (Nvl(bl.txn_raw_cost,0) - Nvl(bl.txn_init_raw_cost,0)) <> 0
         OR (Nvl(bl.txn_burdened_cost,0) - nvl(bl.txn_init_burdened_cost,0)) <> 0
         OR (Nvl(bl.txn_revenue,0) - nvl(bl.txn_init_revenue,0)) <> 0
         )
    AND  (  NVL(bl.init_quantity,0) = 0
                and NVL(bl.txn_init_raw_cost ,0) = 0
                and NVL(bl.txn_init_burdened_cost ,0) = 0
                and NVL(bl.txn_init_revenue ,0) = 0
             );

    /* check any of the actual lines got created before the etc start date
         * is having etc zero or not. If etc is not zero then throw an error
     */
    CURSOR cur_bl_corrupted is
        SELECT /*+ INDEX(BL PA_BUDGET_LINES_U1) */
        bl.budget_line_id
              ,bl.resource_assignment_id
              ,bl.txn_currency_code
              ,bl.start_date
          --,rl.alias resource_name
          ,bl.end_date
              ,bl.period_name
              ,bl.quantity
              ,bl.txn_raw_cost
              ,bl.txn_burdened_cost
              ,bl.txn_revenue
              ,bl.project_raw_cost
              ,bl.project_burdened_cost
              ,bl.project_revenue
              ,bl.raw_cost      projfunc_raw_cost
              ,bl.burdened_cost projfunc_burdened_cost
              ,bl.revenue       projfunc_revenue
              ,bl.project_currency_code
              ,bl.projfunc_currency_code
              ,bl.cost_rejection_code
              ,bl.revenue_rejection_code
              ,bl.burden_rejection_code
              ,bl.pfc_cur_conv_rejection_code
              ,bl.pc_cur_conv_rejection_code
        FROM pa_budget_lines bl
        ,pa_fp_spread_calc_tmp tmp
        WHERE tmp.budget_version_id = p_budget_version_id
        AND  bl.resource_assignment_id = tmp.resource_assignment_id
        AND  bl.txn_currency_code = tmp.txn_currency_code
        AND  bl.start_date < p_etc_start_date
        AND  bl.end_date < p_etc_start_date
        AND  ( (NVL(bl.quantity,0) - NVl(bl.init_quantity,0)) <> 0
             OR (Nvl(bl.txn_raw_cost,0) - Nvl(bl.txn_init_raw_cost,0)) <> 0
             OR (Nvl(bl.txn_burdened_cost,0) - nvl(bl.txn_init_burdened_cost,0)) <> 0
             OR (Nvl(bl.txn_revenue,0) - nvl(bl.txn_init_revenue,0)) <> 0
             )
    AND  (bl.init_quantity is NOT NULL
        or bl.txn_init_raw_cost is NOT NULL
        or bl.txn_init_burdened_cost is NOT NULL
        or bl.txn_init_revenue is NOT NULL
         );

    /* This cursor picks up all the corrupted budget lines for non-rate based planning
         * transactions where actual qty <> to acutal raw cost. IE. while receiving actuals precedence rules were not
         * applied or not maintained
         */
        CURSOR cur_NonRatebase_corrupted_bls is
        SELECT /*+ INDEX(BL PA_BUDGET_LINES_U1) */
        bl.budget_line_id
              ,bl.resource_assignment_id
              ,bl.txn_currency_code
              ,bl.start_date
              ,null  resource_name  --rl.alias resource_name
              ,bl.end_date
              ,bl.period_name
              ,bl.quantity
              ,bl.txn_raw_cost
              ,bl.txn_burdened_cost
              ,bl.txn_revenue
              ,bl.project_raw_cost
              ,bl.project_burdened_cost
              ,bl.project_revenue
              ,bl.raw_cost      projfunc_raw_cost
              ,bl.burdened_cost projfunc_burdened_cost
              ,bl.revenue       projfunc_revenue
              ,bl.project_currency_code
              ,bl.projfunc_currency_code
              ,bl.cost_rejection_code
              ,bl.revenue_rejection_code
              ,bl.burden_rejection_code
              ,bl.pfc_cur_conv_rejection_code
              ,bl.pc_cur_conv_rejection_code
        FROM pa_budget_lines bl
            ,pa_resource_assignments ra
        ,pa_fp_spread_calc_tmp tmp
        WHERE tmp.budget_version_id = p_budget_version_id
        AND  bl.resource_assignment_id = tmp.resource_assignment_id
        AND  bl.txn_currency_code = tmp.txn_currency_code
        AND  ra.resource_assignment_id = tmp.resource_assignment_id
    AND  NVL(ra.rate_based_flag,'N') = 'N'
        AND  bl.start_date < p_etc_start_date
        AND  bl.end_date < p_etc_start_date
        AND  (bl.init_quantity is NOT NULL
                or bl.txn_init_raw_cost is NOT NULL
                or bl.txn_init_burdened_cost is NOT NULL
                or bl.txn_init_revenue is NOT NULL
             )
    AND (  (g_fp_budget_version_type = 'REVENUE'
        and ( nvl(bl.txn_init_raw_cost,0) <> 0
            OR (decode(round(bl.init_quantity,2)
                   ,decode(decode(nvl(g_wp_version_flag,'N'),'Y',NVL(G_TRACK_WP_COSTS_FLAG,'N'),'Y'),'N'
               ,decode(nvl(bl.txn_init_revenue,0),0,round(bl.init_quantity,2),round(bl.txn_init_revenue,2))
                 ,round(bl.txn_init_revenue,2)),'Y','N') <> 'Y'
                    ))
        )OR
         ( g_fp_budget_version_type ='COST'
           and ( nvl(bl.txn_init_revenue,0) <> 0
            OR (decode(round(bl.init_quantity,2)
                ,decode(decode(nvl(g_wp_version_flag,'N'),'Y',NVL(G_TRACK_WP_COSTS_FLAG,'N'),'Y'),'N'
                ,decode(nvl(bl.txn_init_raw_cost,0),0,round(bl.init_quantity,2),round(bl.txn_init_raw_cost,2))
                  ,round(bl.txn_init_raw_cost,2)),'Y','N') <> 'Y' ))
        ) OR
            ( g_fp_budget_version_type  = 'ALL'
           and (decode(round(bl.init_quantity,2)
            ,decode(decode(nvl(g_wp_version_flag,'N'),'Y',NVL(G_TRACK_WP_COSTS_FLAG,'N'),'Y'),'N'
            ,decode(nvl(bl.txn_init_raw_cost,0),0,round(bl.init_quantity,2),round(bl.txn_init_raw_cost,2))
              ,round(bl.txn_init_raw_cost,2)),'Y','N') <> 'Y' )
        )
          );

    l_budget_Line_id_tab   pa_plsql_datatypes.IdTabTyp;
    l_resource_assignment_id_tab pa_plsql_datatypes.IdTabTyp;
    l_txn_currency_code_tab      pa_plsql_datatypes.Char50TabTyp;
    l_start_date_tab             pa_plsql_datatypes.DateTabTyp;
    l_end_date_tab           pa_plsql_datatypes.DateTabTyp;
        l_period_name_tab        pa_plsql_datatypes.Char50TabTyp;
        l_quantity_tab          pa_plsql_datatypes.NumTabTyp;
        l_txn_raw_cost_tab      pa_plsql_datatypes.NumTabTyp;
        l_txn_burdened_cost_tab     pa_plsql_datatypes.NumTabTyp;
        l_txn_revenue_tab       pa_plsql_datatypes.NumTabTyp;
        l_project_raw_cost_tab      pa_plsql_datatypes.NumTabTyp;
        l_project_burdened_cost_tab pa_plsql_datatypes.NumTabTyp;
        l_project_revenue_tab       pa_plsql_datatypes.NumTabTyp;
        l_projfunc_raw_cost_tab     pa_plsql_datatypes.NumTabTyp;
        l_projfunc_burdened_cost_tab    pa_plsql_datatypes.NumTabTyp;
        l_projfunc_revenue_tab      pa_plsql_datatypes.NumTabTyp;
        l_project_curr_code_tab     pa_plsql_datatypes.Char50TabTyp;
        l_projfunc_curr_code_tab    pa_plsql_datatypes.Char50TabTyp;
    l_cost_rejection_code_tab       pa_plsql_datatypes.Char50TabTyp;
        l_revenue_rejection_code_tab    pa_plsql_datatypes.Char50TabTyp;
        l_burden_rejection_code_tab     pa_plsql_datatypes.Char50TabTyp;
        l_pfc_cur_conv_rej_code_tab pa_plsql_datatypes.Char50TabTyp;
        l_pc_cur_conv_rej_code_tab  pa_plsql_datatypes.Char50TabTyp;


    l_upd_budget_Line_id_tab    pa_plsql_datatypes.IdTabTyp;
        l_upd_ra_id_tab         pa_plsql_datatypes.IdTabTyp;
        l_upd_txn_curr_code_tab         pa_plsql_datatypes.Char50TabTyp;
        l_upd_start_date_tab            pa_plsql_datatypes.DateTabTyp;
        l_upd_end_date_tab              pa_plsql_datatypes.DateTabTyp;
        l_upd_period_name_tab           pa_plsql_datatypes.Char50TabTyp;
        l_upd_quantity_tab              pa_plsql_datatypes.NumTabTyp;
        l_upd_txn_raw_cost_tab          pa_plsql_datatypes.NumTabTyp;
        l_upd_txn_burden_cost_tab       pa_plsql_datatypes.NumTabTyp;
        l_upd_txn_revenue_tab           pa_plsql_datatypes.NumTabTyp;
        l_upd_project_raw_cost_tab      pa_plsql_datatypes.NumTabTyp;
        l_upd_project_burden_cost_tab   pa_plsql_datatypes.NumTabTyp;
        l_upd_project_revenue_tab       pa_plsql_datatypes.NumTabTyp;
        l_upd_projfunc_raw_cost_tab     pa_plsql_datatypes.NumTabTyp;
        l_upd_projfunc_burden_cost_tab  pa_plsql_datatypes.NumTabTyp;
        l_upd_projfunc_revenue_tab      pa_plsql_datatypes.NumTabTyp;
        l_upd_project_curr_code_tab     pa_plsql_datatypes.Char50TabTyp;
        l_upd_projfunc_curr_code_tab    pa_plsql_datatypes.Char50TabTyp;
        l_upd_cost_rejection_tab        pa_plsql_datatypes.Char50TabTyp;
        l_upd_revenue_rejection_tab     pa_plsql_datatypes.Char50TabTyp;
        l_upd_burden_rejection_tab      pa_plsql_datatypes.Char50TabTyp;
        l_upd_pfc_cur_conv_rej_tab      pa_plsql_datatypes.Char50TabTyp;
        l_upd_pc_cur_conv_rej_tab       pa_plsql_datatypes.Char50TabTyp;

    l_stage  varchar2(100);
        l_return_status varchar2(100);
        l_msg_data      varchar2(1000);
        l_corrupted_bl_update_rows Number := 0;


    PROCEDURE initPlsqlTabs IS

    BEGIN

        l_budget_Line_id_tab.delete;
        l_resource_assignment_id_tab.delete;
        l_txn_currency_code_tab.delete;
        l_start_date_tab.delete;
        l_end_date_tab.delete;
            l_period_name_tab.delete;
            l_quantity_tab.delete;
            l_txn_raw_cost_tab.delete;
            l_txn_burdened_cost_tab.delete;
            l_txn_revenue_tab.delete;
            l_project_raw_cost_tab.delete;
            l_project_burdened_cost_tab.delete;
            l_project_revenue_tab.delete;
            l_projfunc_raw_cost_tab.delete;
            l_projfunc_burdened_cost_tab.delete;
            l_projfunc_revenue_tab.delete;
            l_project_curr_code_tab.delete;
            l_projfunc_curr_code_tab.delete;
        l_cost_rejection_code_tab.delete;
            l_revenue_rejection_code_tab.delete;
            l_burden_rejection_code_tab.delete;
            l_pfc_cur_conv_rej_code_tab.delete;
            l_pc_cur_conv_rej_code_tab.delete;

    END initPlsqlTabs;

    PROCEDURE initUpdPlsqlTabs IS

    BEGIN
        l_upd_budget_Line_id_tab.delete;
            l_upd_ra_id_tab.delete;
            l_upd_txn_curr_code_tab.delete;
            l_upd_start_date_tab.delete;
            l_upd_end_date_tab.delete;
            l_upd_period_name_tab.delete;
            l_upd_quantity_tab.delete;
            l_upd_txn_raw_cost_tab.delete;
            l_upd_txn_burden_cost_tab.delete;
            l_upd_txn_revenue_tab.delete;
            l_upd_project_raw_cost_tab.delete;
            l_upd_project_burden_cost_tab.delete;
            l_upd_project_revenue_tab.delete;
            l_upd_projfunc_raw_cost_tab.delete;
            l_upd_projfunc_burden_cost_tab.delete;
            l_upd_projfunc_revenue_tab.delete;
            l_upd_project_curr_code_tab.delete;
            l_upd_projfunc_curr_code_tab.delete;
            l_upd_cost_rejection_tab.delete;
            l_upd_revenue_rejection_tab.delete;
            l_upd_burden_rejection_tab.delete;
            l_upd_pfc_cur_conv_rej_tab.delete;
            l_upd_pc_cur_conv_rej_tab.delete;

    END initUpdPlsqlTabs;

BEGIN
    IF p_pa_debug_mode = 'Y' Then
        pa_debug.init_err_stack('PA_FP_CALC_PLAN_PKG.clear_closed_period_etcs');
    End If;
    x_return_status := 'S';
    l_stage := 'Entered clear_closed_period_etcs api ETC Date['||p_etc_start_date||']';
    g_stage := 'clear_closed_period_etcs:100';
    initPlsqlTabs;
    OPEN cur_bl_closed_period;
    FETCH cur_bl_closed_period BULK COLLECT INTO
        l_budget_Line_id_tab
        ,l_resource_assignment_id_tab
        ,l_txn_currency_code_tab
        ,l_start_date_tab
        ,l_end_date_tab
                ,l_period_name_tab
                ,l_quantity_tab
                ,l_txn_raw_cost_tab
                ,l_txn_burdened_cost_tab
                ,l_txn_revenue_tab
                ,l_project_raw_cost_tab
                ,l_project_burdened_cost_tab
                ,l_project_revenue_tab
                ,l_projfunc_raw_cost_tab
                ,l_projfunc_burdened_cost_tab
                ,l_projfunc_revenue_tab
                ,l_project_curr_code_tab
                ,l_projfunc_curr_code_tab
        ,l_cost_rejection_code_tab
            ,l_revenue_rejection_code_tab
            ,l_burden_rejection_code_tab
            ,l_pfc_cur_conv_rej_code_tab
            ,l_pc_cur_conv_rej_code_tab;
    CLOSE cur_bl_closed_period;

    IF l_budget_Line_id_tab.COUNT > 0 Then
        g_stage := 'clear_closed_period_etcs:101';
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('There exists a budgetLine prior to ETC startdate with unbalanced amt NumOfLines['||l_budget_Line_id_tab.COUNT||']');
	End if;
         FOR i IN l_budget_Line_id_tab.FIRST .. l_budget_Line_id_tab.LAST LOOP
             -- call reporting api to update these amounts
             IF NVL(g_rollup_required_flag,'N') = 'Y' Then  --{
		/* bug fix:5031388
                IF (l_cost_rejection_code_tab(i) is NULL AND
                    l_revenue_rejection_code_tab(i) is NULL AND
                    l_burden_rejection_code_tab(i) is NULL AND
                    l_pfc_cur_conv_rej_code_tab(i) is NULL AND
                    l_pc_cur_conv_rej_code_tab(i) is NULL )  THEN
		*/
                    /* update the reporting lines before deleteing the budget lines */
                     Add_Toreporting_Tabls
                                (p_calling_module               => 'CALCULATE_API'
                                ,p_activity_code                => 'UPDATE'
                                ,p_budget_version_id            => p_budget_version_id
                                ,p_budget_line_id               => l_budget_Line_id_tab(i)
                                ,p_resource_assignment_id       => l_resource_assignment_id_tab(i)
                                ,p_start_date                   => l_start_date_tab(i)
                                ,p_end_date                     => l_end_date_tab(i)
                                ,p_period_name                  => l_period_name_tab(i)
                                ,p_txn_currency_code            => l_txn_currency_code_tab(i)
                                ,p_quantity                     => l_quantity_tab(i) * -1
                                ,p_txn_raw_cost                 => l_txn_raw_cost_tab(i) * -1
                                ,p_txn_burdened_cost            => l_txn_burdened_cost_tab(i) * -1
                                ,p_txn_revenue                  => l_txn_revenue_tab(i) * -1
                                ,p_project_currency_code        => l_project_curr_code_tab(i)
                                ,p_project_raw_cost             => l_project_raw_cost_tab(i) * -1
                                ,p_project_burdened_cost        => l_project_burdened_cost_tab(i) * -1
                                ,p_project_revenue              => l_project_revenue_tab(i) * -1
                                ,p_projfunc_currency_code       => l_projfunc_curr_code_tab(i)
                                ,p_projfunc_raw_cost            => l_projfunc_raw_cost_tab(i) * -1
                                ,p_projfunc_burdened_cost       => l_projfunc_burdened_cost_tab(i) * -1
                                ,p_projfunc_revenue             => l_projfunc_revenue_tab(i) * -1
				,p_rep_line_mode               => 'REVERSAL'
                                ,x_msg_data                     => l_msg_data
                                ,x_return_status                => l_return_status
                                );
               /* bug fix:5031388END IF;*/
        END IF; --}

        /* Added for MRC enhancements */
        IF NVL(G_populate_mrc_tab_flag,'N') = 'Y' Then --{
            Populate_MRC_plsqlTabs
                (p_calling_module               => 'CALCULATE_API'
                                ,p_budget_version_id            => p_budget_version_id
                                ,p_budget_line_id               => l_budget_Line_id_tab(i)
                                ,p_resource_assignment_id       => l_resource_assignment_id_tab(i)
                                ,p_start_date                   => l_start_date_tab(i)
                                ,p_end_date                     => l_end_date_tab(i)
                                ,p_period_name                  => l_period_name_tab(i)
                                ,p_txn_currency_code            => l_txn_currency_code_tab(i)
                                ,p_quantity                     => l_quantity_tab(i)
                                ,p_txn_raw_cost                 => l_txn_raw_cost_tab(i)
                                ,p_txn_burdened_cost            => l_txn_burdened_cost_tab(i)
                                ,p_txn_revenue                  => l_txn_revenue_tab(i)
                                ,p_project_currency_code        => l_project_curr_code_tab(i)
                                ,p_project_raw_cost             => l_project_raw_cost_tab(i)
                                ,p_project_burdened_cost        => l_project_burdened_cost_tab(i)
                                ,p_project_revenue              => l_project_revenue_tab(i)
                                ,p_projfunc_currency_code       => l_projfunc_curr_code_tab(i)
                                ,p_projfunc_raw_cost            => l_projfunc_raw_cost_tab(i)
                                ,p_projfunc_burdened_cost       => l_projfunc_burdened_cost_tab(i)
                                ,p_projfunc_revenue             => l_projfunc_revenue_tab(i)
                ,p_delete_flag                  => 'Y'
                                ,x_msg_data                     => l_msg_data
                                ,x_return_status                => l_return_status
                                );
        END IF; --}
          END LOOP;
        g_stage := 'clear_closed_period_etcs:102';
        FORALL i IN l_budget_Line_id_tab.FIRST .. l_budget_Line_id_tab.LAST
        /** As discussed with Sanjay and Neeraj, Not to keep etc zero lines
         * this may cause to pick the wrong currency during the refresh rates
         * so delete all the budget lines instead of updating it to null
         **/
        DELETE FROM pa_budget_lines bl
        WHERE bl.budget_line_id  = l_budget_Line_id_tab(i);
        --print_msg('Number of rows deleted from budgetLine['||l_budget_Line_id_tab.count||']');

    END If;

    /* check if there any corrupted records exists. once the actuals are posted, the
     * etc should be zero, if not the record is corrupted so add msg to the stack
     * and skip the record
     * Had discussion with Neeraj and sanjay, Instead of throwing an error, correct the record (make plan = actrual )
     * and spread the ETC forward
     * so commenting out this section and added new code to handle this.
      FOR i IN cur_bl_corrupted LOOP
        --print_msg('Corrupted BudgetLines Exists prior to ETC period: RAID['||i.resource_assignment_id||']');
                    add_msgto_stack
                        ( p_msg_name       => 'PA_BLAMT_EXISTS_PRIOR_ETC'
                        ,p_token1         => 'PROJECT'
                        ,p_value1         => g_project_name
                        ,p_token2         => 'RESOURCE_ASSIGNMENT'
                        ,p_value2         => i.resource_assignment_id
                        ,p_token3         => 'RESOURCE_NAME'
                        ,p_value3         => i.resource_name
                        ,p_token4         => 'START_DATE'
                        ,p_value4         => i.start_date);
            x_return_status := 'E';
      END LOOP;
     **/
    g_stage := 'clear_closed_period_etcs:103';
     /* The above code is commented and Added the below code for enhacements */
    If NVL(g_track_wp_costs_flag,'N') = 'Y' Then
           FOR i IN cur_NonRatebase_corrupted_bls LOOP
                --print_msg('Corrupted BudgetLines Exists prior to ETC period: RAID['||i.resource_assignment_id||']');
                    add_msgto_stack
                        ( p_msg_name       => 'PA_BLAMT_EXISTS_PRIOR_ETC'
                        ,p_token1         => 'PROJECT'
                        ,p_value1         => g_project_name
                        ,p_token2         => 'RESOURCE_ASSIGNMENT'
                        ,p_value2         => i.resource_assignment_id
                        ,p_token3         => 'RESOURCE_NAME'
                        ,p_value3         => i.resource_name
                        ,p_token4         => 'START_DATE'
                        ,p_value4         => i.start_date);
                        x_return_status := 'E';
           END LOOP;
    End If;
    IF x_return_status = 'S' AND p_etc_start_date is NOT NULL Then  --{
        initPlsqlTabs;
        initUpdPlsqlTabs;
        --print_msg('Opening cur_bl_corrupted cursor');
        OPEN cur_bl_corrupted;
        FETCH cur_bl_corrupted BULK COLLECT INTO
         l_budget_Line_id_tab
                ,l_resource_assignment_id_tab
                ,l_txn_currency_code_tab
                ,l_start_date_tab
                ,l_end_date_tab
                ,l_period_name_tab
                ,l_quantity_tab
                ,l_txn_raw_cost_tab
                ,l_txn_burdened_cost_tab
                ,l_txn_revenue_tab
                ,l_project_raw_cost_tab
                ,l_project_burdened_cost_tab
                ,l_project_revenue_tab
                ,l_projfunc_raw_cost_tab
                ,l_projfunc_burdened_cost_tab
                ,l_projfunc_revenue_tab
                ,l_project_curr_code_tab
                ,l_projfunc_curr_code_tab
                ,l_cost_rejection_code_tab
                ,l_revenue_rejection_code_tab
                ,l_burden_rejection_code_tab
                ,l_pfc_cur_conv_rej_code_tab
                ,l_pc_cur_conv_rej_code_tab;
        CLOSE cur_bl_corrupted;
        g_stage := 'clear_closed_period_etcs:104';
        --print_msg('Number of Budget lines Corrupted ['||l_budget_Line_id_tab.COUNT||']');
        IF l_budget_Line_id_tab.COUNT > 0 Then
             IF NVL(g_rollup_required_flag,'N') = 'Y' Then  --{
              FOR i IN l_budget_Line_id_tab.FIRST .. l_budget_Line_id_tab.LAST LOOP
		/* bug fix:5031388
            	IF (l_cost_rejection_code_tab(i) is NULL AND
                        l_revenue_rejection_code_tab(i) is NULL AND
                        l_burden_rejection_code_tab(i) is NULL AND
                        l_pfc_cur_conv_rej_code_tab(i) is NULL AND
                        l_pc_cur_conv_rej_code_tab(i) is NULL )  THEN
		*/
                        --update the reporting lines before correcting the budget lines
            		--print_msg('Passing -ve of blCorrupt:LnId['||l_budget_Line_id_tab(i)||']Qty['||l_quantity_tab(i) * -1||']');
                        Add_Toreporting_Tabls
                                (p_calling_module               => 'CALCULATE_API'
                                ,p_activity_code                => 'UPDATE'
                                ,p_budget_version_id            => p_budget_version_id
                                ,p_budget_line_id               => l_budget_Line_id_tab(i)
                                ,p_resource_assignment_id       => l_resource_assignment_id_tab(i)
                                ,p_start_date                   => l_start_date_tab(i)
                                ,p_end_date                     => l_end_date_tab(i)
                                ,p_period_name                  => l_period_name_tab(i)
                                ,p_txn_currency_code            => l_txn_currency_code_tab(i)
                                ,p_quantity                     => l_quantity_tab(i) * -1
                                ,p_txn_raw_cost                 => l_txn_raw_cost_tab(i) * -1
                                ,p_txn_burdened_cost            => l_txn_burdened_cost_tab(i) * -1
                                ,p_txn_revenue                  => l_txn_revenue_tab(i) * -1
                                ,p_project_currency_code        => l_project_curr_code_tab(i)
                                ,p_project_raw_cost             => l_project_raw_cost_tab(i) * -1
                                ,p_project_burdened_cost        => l_project_burdened_cost_tab(i) * -1
                                ,p_project_revenue              => l_project_revenue_tab(i) * -1
                                ,p_projfunc_currency_code       => l_projfunc_curr_code_tab(i)
                                ,p_projfunc_raw_cost            => l_projfunc_raw_cost_tab(i) * -1
                                ,p_projfunc_burdened_cost       => l_projfunc_burdened_cost_tab(i) * -1
                                ,p_projfunc_revenue             => l_projfunc_revenue_tab(i) * -1
				,p_rep_line_mode               => 'REVERSAL'
                                ,x_msg_data                     => l_msg_data
                                ,x_return_status                => l_return_status
                                );
                    /* bug fix:5031388 END IF;*/
              END LOOP;
             END IF; --}
        END IF;

        IF l_budget_Line_id_tab.COUNT > 0 Then
         g_stage := 'clear_closed_period_etcs:105';
         --Correct all the budget lines prior to ETC start date. make plan = atcual and set all the currency conv attributes to NULL
         --print_msg('Updating closed period budget lines and correcting the plan amounts');
         l_corrupted_bl_update_rows := 0;
         FORALL i IN l_budget_Line_id_tab.FIRST .. l_budget_Line_id_tab.LAST
         UPDATE pa_budget_lines bl
         SET bl.quantity = bl.init_quantity
           ,bl.txn_raw_cost = bl.txn_init_raw_cost
           ,bl.txn_burdened_cost = bl.txn_init_burdened_cost
           ,bl.txn_revenue = bl.txn_init_revenue
           /* Bug fix: 4071198 As discussed with sanjay, for closed periods, instead of setting the Etc rates as null
            * derive the plan rates. so that the copy version functionality when copies the budget versions
            * proper rates will be copied*/
           ,bl.txn_standard_cost_rate = DECODE(nvl(bl.init_quantity,0),0,NULL,(bl.txn_init_raw_cost/bl.init_quantity))
           ,bl.txn_cost_rate_override = DECODE(nvl(bl.init_quantity,0),0,NULL,(bl.txn_init_raw_cost/bl.init_quantity))
           ,bl.burden_cost_rate = DECODE(nvl(bl.init_quantity,0),0,NULL,(bl.txn_init_burdened_cost/bl.init_quantity))
           ,bl.burden_cost_rate_override = DECODE(nvl(bl.init_quantity,0),0,NULL,(bl.txn_init_burdened_cost/bl.init_quantity))
           ,bl.txn_standard_bill_rate = DECODE(nvl(bl.init_quantity,0),0,NULL,(bl.txn_init_revenue/bl.init_quantity))
           ,bl.txn_bill_rate_override = DECODE(nvl(bl.init_quantity,0),0,NULL,(bl.txn_init_revenue/bl.init_quantity))
           ,bl.raw_cost = bl.init_raw_cost
           ,bl.burdened_cost = bl.init_burdened_cost
           ,bl.revenue = bl.init_revenue
           ,bl.project_raw_cost = bl.project_init_raw_cost
           ,bl.project_burdened_cost = bl.project_init_burdened_cost
           ,bl.project_revenue = bl.project_init_revenue
                   ,bl.projfunc_cost_rate_type         = null
                   ,bl.projfunc_cost_exchange_rate     = null
                   ,bl.projfunc_cost_rate_date_type    = null
                   ,bl.projfunc_cost_rate_date         = null
                   ,bl.projfunc_rev_rate_type          = null
                   ,bl.projfunc_rev_exchange_rate      = null
                   ,bl.projfunc_rev_rate_date_type     = null
                   ,bl.projfunc_rev_rate_date          = null
                   ,bl.project_cost_rate_type          = null
                   ,bl.project_cost_exchange_rate      = null
                   ,bl.project_cost_rate_date_type     = null
                   ,bl.project_cost_rate_date          = null
                   ,bl.project_rev_rate_type           = null
                   ,bl.project_rev_exchange_rate       = null
                   ,bl.project_rev_rate_date_type      = null
                   ,bl.project_rev_rate_date           = null
           ,bl.pfc_cur_conv_rejection_code     = null
                   ,bl.pc_cur_conv_rejection_code      = null
           ,bl.cost_rejection_code             = null
           ,bl.burden_rejection_code           = null
           ,bl.revenue_rejection_code          = null
                   ,bl.last_update_date                = sysdate
                   ,bl.last_updated_by                 = fnd_global.user_id
                   ,bl.last_update_login               = fnd_global.login_id
           /* Bug fix:4257059 storing this value just for tracking purpose is causing
            * issues in the generation flow
            *,bl.other_rejection_code            = 'PA_BLAMT_EXISTS_PRIOR_ETC'
            */
             WHERE bl.budget_line_id = l_budget_Line_id_tab(i)
         /*Bug fix:4257059 Added this returning clause to avoid one-select and one-update*/
         RETURNING
            bl.budget_line_id
                        ,bl.resource_assignment_id
                        ,bl.txn_currency_code
                        ,bl.start_date
                        --,rl.alias resource_name
                        ,bl.end_date
                        ,bl.period_name
                        ,bl.quantity
                        ,bl.txn_raw_cost
                        ,bl.txn_burdened_cost
                        ,bl.txn_revenue
                        ,bl.project_raw_cost
                        ,bl.project_burdened_cost
                        ,bl.project_revenue
                        ,bl.raw_cost      --projfunc_raw_cost
                        ,bl.burdened_cost --projfunc_burdened_cost
                        ,bl.revenue       --projfunc_revenue
                        ,bl.project_currency_code
                        ,bl.projfunc_currency_code
                        ,bl.cost_rejection_code
                        ,bl.revenue_rejection_code
                        ,bl.burden_rejection_code
                        ,bl.pfc_cur_conv_rejection_code
                        ,bl.pc_cur_conv_rejection_code
        BULK COLLECT INTO
                        l_upd_budget_Line_id_tab
                        ,l_upd_ra_id_tab
                        ,l_upd_txn_curr_code_tab
                        ,l_upd_start_date_tab
                        ,l_upd_end_date_tab
                        ,l_upd_period_name_tab
                        ,l_upd_quantity_tab
                        ,l_upd_txn_raw_cost_tab
                        ,l_upd_txn_burden_cost_tab
                        ,l_upd_txn_revenue_tab
                        ,l_upd_project_raw_cost_tab
                        ,l_upd_project_burden_cost_tab
                        ,l_upd_project_revenue_tab
                        ,l_upd_projfunc_raw_cost_tab
                        ,l_upd_projfunc_burden_cost_tab
                        ,l_upd_projfunc_revenue_tab
                        ,l_upd_project_curr_code_tab
                        ,l_upd_projfunc_curr_code_tab
                        ,l_upd_cost_rejection_tab
                        ,l_upd_revenue_rejection_tab
                        ,l_upd_burden_rejection_tab
                        ,l_upd_pfc_cur_conv_rej_tab
                        ,l_upd_pc_cur_conv_rej_tab ;


         l_corrupted_bl_update_rows := l_upd_budget_Line_id_tab.COUNT;
         --print_msg('Number of closed period budget lines updated['||l_corrupted_bl_update_rows||']');
        END IF;

        /** Bug fix:4257059 adding returning clause in the above update
                 * no need to hit the db again , so commentingout the code
        IF (NVL(l_corrupted_bl_update_rows,0) > 0 AND l_upd_budget_Line_id_tab.COUNT > 0 ) Then --{
            BEGIN
                g_stage := 'clear_closed_period_etcs:106';
                 SELECT bl.budget_line_id
                            ,bl.resource_assignment_id
                            ,bl.txn_currency_code
                            ,bl.start_date
                            --,rl.alias resource_name
                            ,bl.end_date
                            ,bl.period_name
                            ,bl.quantity
                            ,bl.txn_raw_cost
                            ,bl.txn_burdened_cost
                            ,bl.txn_revenue
                            ,bl.project_raw_cost
                            ,bl.project_burdened_cost
                            ,bl.project_revenue
                            ,bl.raw_cost      projfunc_raw_cost
                            ,bl.burdened_cost projfunc_burdened_cost
                            ,bl.revenue       projfunc_revenue
                            ,bl.project_currency_code
                            ,bl.projfunc_currency_code
                            ,bl.cost_rejection_code
                            ,bl.revenue_rejection_code
                            ,bl.burden_rejection_code
                            ,bl.pfc_cur_conv_rejection_code
                            ,bl.pc_cur_conv_rejection_code
                BULK COLLECT INTO
                            l_upd_budget_Line_id_tab
                            ,l_upd_ra_id_tab
                            ,l_upd_txn_curr_code_tab
                            ,l_upd_start_date_tab
                            ,l_upd_end_date_tab
                            ,l_upd_period_name_tab
                            ,l_upd_quantity_tab
                            ,l_upd_txn_raw_cost_tab
                            ,l_upd_txn_burden_cost_tab
                            ,l_upd_txn_revenue_tab
                            ,l_upd_project_raw_cost_tab
                            ,l_upd_project_burden_cost_tab
                            ,l_upd_project_revenue_tab
                            ,l_upd_projfunc_raw_cost_tab
                            ,l_upd_projfunc_burden_cost_tab
                            ,l_upd_projfunc_revenue_tab
                            ,l_upd_project_curr_code_tab
                            ,l_upd_projfunc_curr_code_tab
                            ,l_upd_cost_rejection_tab
                            ,l_upd_revenue_rejection_tab
                            ,l_upd_burden_rejection_tab
                            ,l_upd_pfc_cur_conv_rej_tab
                            ,l_upd_pc_cur_conv_rej_tab
                FROM pa_budget_lines bl
                    ,pa_fp_spread_calc_tmp tmp
                        WHERE bl.budget_version_id = p_budget_version_id
                AND  tmp.budget_version_id = bl.budget_version_id
                        AND  bl.resource_assignment_id = tmp.resource_assignment_id
                        AND  bl.txn_currency_code = tmp.txn_currency_code
                        AND  bl.start_date < p_etc_start_date
                        AND  bl.end_date < p_etc_start_date
                AND  bl.other_rejection_code = 'PA_BLAMT_EXISTS_PRIOR_ETC'
                AND  (bl.init_quantity is NOT NULL
                                or bl.txn_init_raw_cost is NOT NULL
                                or bl.txn_init_burdened_cost is NOT NULL
                                or bl.txn_init_revenue is NOT NULL
                                 );
                --print_msg('Number of budget Lines selected after correction['||l_budget_Line_id_tab.count||']');

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL;
            END;
        END IF;  --}
        *** End of bug fix: 4257059 **/
        IF (NVL(l_corrupted_bl_update_rows,0) > 0 AND l_upd_budget_Line_id_tab.COUNT > 0 ) Then --{
            --Now pass the corrected plan amounts to the PJI reporting apis
            IF l_upd_budget_Line_id_tab.COUNT > 0 THEN
                    FOR i IN l_upd_budget_Line_id_tab.FIRST .. l_upd_budget_Line_id_tab.LAST LOOP
                         IF NVL(g_rollup_required_flag,'N') = 'Y' Then  --{
				/* bug fix:5031388
                                IF (l_upd_cost_rejection_tab(i) is NULL AND
                                    l_upd_revenue_rejection_tab(i) is NULL AND
                                    l_upd_burden_rejection_tab(i) is NULL AND
                                    l_upd_pfc_cur_conv_rej_tab(i) is NULL AND
                                    l_upd_pc_cur_conv_rej_tab(i) is NULL )  THEN
				*/
                        	--print_msg('Passing +ve of blCorrupt:LnId['||l_upd_budget_Line_id_tab(i)||']Qty['||l_upd_quantity_tab(i)||']');

                                    --update the reporting lines before deleteing the budget lines
                                    Add_Toreporting_Tabls
                                        (p_calling_module               => 'CALCULATE_API'
                                        ,p_activity_code                => 'UPDATE'
                                        ,p_budget_version_id            => p_budget_version_id
                                        ,p_budget_line_id               => l_upd_budget_Line_id_tab(i)
                                        ,p_resource_assignment_id       => l_upd_ra_id_tab(i)
                                        ,p_start_date                   => l_upd_start_date_tab(i)
                                        ,p_end_date                     => l_upd_end_date_tab(i)
                                        ,p_period_name                  => l_upd_period_name_tab(i)
                                        ,p_txn_currency_code            => l_upd_txn_curr_code_tab(i)
                                        ,p_quantity                     => l_upd_quantity_tab(i)
                                        ,p_txn_raw_cost                 => l_upd_txn_raw_cost_tab(i)
                                        ,p_txn_burdened_cost            => l_upd_txn_burden_cost_tab(i)
                                        ,p_txn_revenue                  => l_upd_txn_revenue_tab(i)
                                        ,p_project_currency_code        => l_upd_project_curr_code_tab(i)
                                        ,p_project_raw_cost             => l_upd_project_raw_cost_tab(i)
                                        ,p_project_burdened_cost        => l_upd_project_burden_cost_tab(i)
                                        ,p_project_revenue              => l_upd_project_revenue_tab(i)
                                        ,p_projfunc_currency_code       => l_upd_projfunc_curr_code_tab(i)
                                        ,p_projfunc_raw_cost            => l_upd_projfunc_raw_cost_tab(i)
                                        ,p_projfunc_burdened_cost       => l_upd_projfunc_burden_cost_tab(i)
                                        ,p_projfunc_revenue             => l_upd_projfunc_revenue_tab(i)
					,p_rep_line_mode               => 'POSITIVE_ENTRY'
                                        ,x_msg_data                     => l_msg_data
                                        ,x_return_status                => l_return_status
                                        );
                                /* bug fix:5031388END IF;*/
                    END IF; --}

            /* Added for MRC enhancements */
                    IF NVL(G_populate_mrc_tab_flag,'N') = 'Y' Then --{
                            Populate_MRC_plsqlTabs
                                        (p_calling_module               => 'CALCULATE_API'
                                        ,p_budget_version_id            => p_budget_version_id
                                        ,p_budget_line_id               => l_upd_budget_Line_id_tab(i)
                                        ,p_resource_assignment_id       => l_upd_ra_id_tab(i)
                                        ,p_start_date                   => l_upd_start_date_tab(i)
                                        ,p_end_date                     => l_upd_end_date_tab(i)
                                        ,p_period_name                  => l_upd_period_name_tab(i)
                                        ,p_txn_currency_code            => l_upd_txn_curr_code_tab(i)
                                        ,p_quantity                     => l_upd_quantity_tab(i)
                                        ,p_txn_raw_cost                 => l_upd_txn_raw_cost_tab(i)
                                        ,p_txn_burdened_cost            => l_upd_txn_burden_cost_tab(i)
                                        ,p_txn_revenue                  => l_upd_txn_revenue_tab(i)
                                        ,p_project_currency_code        => l_upd_project_curr_code_tab(i)
                                        ,p_project_raw_cost             => l_upd_project_raw_cost_tab(i)
                                        ,p_project_burdened_cost        => l_upd_project_burden_cost_tab(i)
                                        ,p_project_revenue              => l_upd_project_revenue_tab(i)
                                        ,p_projfunc_currency_code       => l_upd_projfunc_curr_code_tab(i)
                                        ,p_projfunc_raw_cost            => l_upd_projfunc_raw_cost_tab(i)
                                        ,p_projfunc_burdened_cost       => l_upd_projfunc_burden_cost_tab(i)
                                        ,p_projfunc_revenue             => l_upd_projfunc_revenue_tab(i)
                    			,p_delete_flag                  => 'N'
                                        ,x_msg_data                     => l_msg_data
                                        ,x_return_status                => l_return_status
                                        );

            END IF; --}
                    END LOOP;
            END IF;
        END IF; --}
    End If;  --}
    /* Reset the buffer */
    initPlsqlTabs;
    initUpdPlsqlTabs;
    g_stage := 'clear_closed_period_etcs:107';
    --reset error stack
    IF p_pa_debug_mode = 'Y' Then
    	print_msg('Leaving clear_closed_period_etcs API with retSts['||x_return_status||']');
        pa_debug.reset_err_stack;
    End If;

EXCEPTION
    WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                ,p_procedure_name => 'clear_closed_period_etcs' );
        IF p_pa_debug_mode = 'Y' Then
                    pa_debug.reset_err_stack;
        end if;
                RAISE;

END clear_closed_period_etcs;

/* This API updates the required flags in the spread calc tmp table to process in the bulk mode */
PROCEDURE Upd_spread_calc_tmp(
        p_budget_version_id     IN NUMBER
        ,p_source_context   IN VARCHAR2
        ,x_return_status        OUT NOCOPY VARCHAR2
                ) IS
BEGIN
    x_return_status := 'S';
    g_stage := 'Upd_spread_calc_tmp:100';
    If P_PA_DEBUG_MODE = 'Y' Then
    print_msg('Entered Upd_spread_calc_tmp API');
    End If;
    IF g_plan_raId_tab.COUNT > 0 THEN
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Number Of rowsUpdated['||g_plan_raId_tab.COUNT||']');
	End If;
        FORALL i IN g_plan_raId_tab.FIRST .. g_plan_raId_tab.LAST
            UPDATE /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP_N1) */ PA_FP_SPREAD_CALC_TMP tmp -- bug 4873834
            SET tmp.skip_record_flag    = NVL(g_skip_record_tab(i),'N')
		,tmp.processed_flag  = NVL(g_process_skip_CstRevrec_tab(i),'N')
               ,tmp.REFRESH_RATES_FLAG   = NVL(g_refresh_rates_tab(i),'N')
               ,tmp.REFRESH_CONV_RATES_FLAG  = NVL(g_refresh_conv_rates_tab(i),'N')
               ,tmp.MASS_ADJUST_FLAG    = NVL(g_mass_adjust_flag_tab(i),'N')
               ,tmp.G_WPRABL_CURRENCY_CODE = g_Wp_curCode_tab(i)
               ,tmp.RA_RATES_ONLY_CHANGE_FLAG = NVL(g_rtChanged_Ra_Flag_tab(i),'N')
               ,tmp.SYSTEM_REFERENCE_VAR2  = NVL(g_applyProg_refreshRts_tab(i),'N') /*Bug fix:4295967 */
            WHERE tmp.budget_version_id = p_budget_version_id
            AND   tmp.resource_assignment_id = g_plan_raId_tab(i)
            AND   tmp.txn_currency_code = g_plan_txnCur_Tab(i)
            AND   ((p_source_context = 'BUDGET_LINE'
                and tmp.start_date = g_line_Sdate_tab(i))
                OR
                p_source_context <> 'BUDGET_LINE'
                  );

    END IF;
    --print_msg('mfcCostRefreshCount['||g_mfc_cost_refrsh_Raid_tab.COUNT||']');
    IF g_mfc_cost_refrsh_Raid_tab.COUNT > 0 THEN
        g_stage := 'Upd_spread_calc_tmp:101';
    --print_msg(g_stage);
        FORALL i IN g_mfc_cost_refrsh_Raid_tab.FIRST .. g_mfc_cost_refrsh_Raid_tab.LAST
            UPDATE /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP_N1) */ PA_FP_SPREAD_CALC_TMP tmp
            SET tmp.mfc_cost_refresh_flag = 'Y'
               ,tmp.REFRESH_RATES_FLAG   = 'Y'
            WHERE tmp.budget_version_id = p_budget_version_id
                        AND   tmp.resource_assignment_id = g_mfc_cost_refrsh_Raid_tab(i)
                        AND   tmp.txn_currency_code = g_mfc_cost_refrsh_txnCur_tab(i) ;
    	END IF;

    	/* ipm changes */
    	If g_sprd_raId_tab.COUNT > 0 Then
        g_stage := 'Upd_spread_calc_tmp:102';
        --print_msg(g_stage);
        FORALL i IN g_sprd_raId_tab.FIRST .. g_sprd_raId_tab.LAST
        UPDATE /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP_N1) */ PA_FP_SPREAD_CALC_TMP tmp
        SET tmp.cost_rate_override = decode(tmp.COST_RATE_G_MISS_NUM_FLAG,'Y',NULL
                            ,NVL(g_sprd_costRt_Ovr_tab(i),tmp.cost_rate_override))
           ,tmp.burden_cost_rate_override = decode(tmp.burden_rate_g_miss_num_flag,'Y',NULL
                            ,NVL(g_sprd_burdRt_Ovr_tab(i),tmp.burden_cost_rate_override))
           ,tmp.bill_rate_override = decode(tmp.bill_rate_g_miss_num_flag,'Y',NULL
                            ,NVL(g_sprd_billRt_Ovr_tab(i),tmp.bill_rate_override))
        WHERE tmp.resource_assignment_id = g_sprd_raId_tab(i)
        AND   tmp.txn_currency_code = g_sprd_txn_cur_tab(i)
        AND   NVL(g_sprd_qty_addl_tab(i),0) <> 0
	AND   ((g_source_context <> 'BUDGET_LINE')
                OR
                ((g_source_context = 'BUDGET_LINE')
                and tmp.start_date BETWEEN g_sprd_sDate_tab(i) AND g_sprd_eDate_tab(i)
                ))
        AND   (NVL(tmp.cost_rate_changed_flag,'N') = 'Y'
                          OR NVL(tmp.burden_rate_changed_flag,'N') = 'Y'
                          OR NVL(tmp.bill_rate_changed_flag,'N') = 'Y'
                          OR NVL(tmp.raw_cost_changed_flag,'N') = 'Y'
                          OR NVL(tmp.burden_cost_changed_flag,'N') = 'Y'
                          OR NVL(tmp.revenue_changed_flag,'N') = 'Y'
            );
    	End If;

	If g_rtChanged_RaId_tab.COUNT > 0 Then
		If P_PA_DEBUG_MODE = 'Y' Then
             	print_msg('Updating spread calc tmp with rate overrides');
		End If;
        	FORALL i IN g_rtChanged_RaId_tab.FIRST .. g_rtChanged_RaId_tab.LAST
        	UPDATE /*+ INDEX(TMP PA_FP_SPREAD_CALC_TMP_N1) */ pa_fp_spread_calc_tmp tmp
        	SET tmp.cost_rate_override = decode(NVL(g_rtChanged_cstMisNumFlg_tab(i),'N'),'Y',NULL
                                        ,NVL(g_rtChanged_CostRt_Tab(i),tmp.cost_rate_override))
            	,tmp.burden_cost_rate_override = decode(NVL(g_rtChanged_bdMisNumFlag_tab(i),'N'),'Y',NULL
                                        ,NVL(g_rtChanged_BurdRt_tab(i),tmp.burden_cost_rate_override))
            	,tmp.bill_rate_override  = decode(NVL(g_rtChanged_blMisNumFlag_tab(i),'N'),'Y',NULL
                                        ,NVL(g_rtChanged_billRt_tab(i),tmp.bill_rate_override))
        	WHERE tmp.resource_assignment_id = g_rtChanged_RaId_tab(i)
        	AND   tmp.txn_currency_code = g_rtChanged_TxnCur_tab(i)
        	AND   ((g_source_context <> 'BUDGET_LINE')
              	OR
            	((g_source_context = 'BUDGET_LINE')
             	and tmp.start_date BETWEEN g_rtChanged_sDate_tab(i) AND g_rtChanged_eDate_tab(i)
            	));
		If P_PA_DEBUG_MODE = 'Y' Then
        	print_msg('Number of rows updated for RateChanges['||sql%rowcount||']');
		End If;
	End If;


EXCEPTION
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                ,p_procedure_name => 'Upd_spread_calc_tmp' );
                RAISE;

END  Upd_spread_calc_tmp;

/* During spread process, the periodic line level override rates and currency conv attributes on the budget lines will be lost
 * as we delete all the budget lines before the spread call. The purpose of thei API  is to retain the override rates and
 * currency conversion attributes of the periodic line level on the budget lines. updates the rollup tmp table with the override rates
 */
PROCEDURE Update_rollupTmp_OvrRates
          ( p_budget_version_id         IN  pa_budget_lines.budget_version_id%type
           ,p_calling_module            IN  varchar2
       ,p_generation_context        IN  varchar2  default 'SPREAD'
           ,x_return_status             OUT NOCOPY VARCHAR2
           ,x_msg_count                 OUT NOCOPY NUMBER
           ,x_msg_data                  OUT NOCOPY VARCHAR2
           ) IS

    CURSOR periodDetails IS
    SELECT gsb.period_set_name      period_set_name
                ,gsb.accounted_period_type  accounted_period_type
                ,pia.pa_period_type         pa_period_type
        ,pbv.version_type       version_type
                ,decode(pbv.version_type,
                        'COST',ppfo.cost_time_phased_code,
                        'REVENUE',ppfo.revenue_time_phased_code,
                         ppfo.all_time_phased_code) time_phase_code
         FROM gl_sets_of_books          gsb
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

    perdRec     periodDetails%ROWTYPE;

    CURSOR fptmpDetails IS
    SELECT tmp.rowid
          ,tmp.resource_assignment_id
          ,tmp.txn_currency_code
          ,tmp.start_date
          ,tmp.end_date
          ,fptmp.period_name
          ,decode(perdRec.version_type ,'ALL', NVL(fptmp.raw_cost_rate,tmp.rw_cost_rate_override)
                        ,'COST',NVL(fptmp.raw_cost_rate,tmp.rw_cost_rate_override)
                        ,decode(p_generation_context,'REVENUE_MARKUP' /* bug fix:4213824 added decode to get the cost rt */
                          ,NVL(fptmp.raw_cost_rate,tmp.rw_cost_rate_override),tmp.rw_cost_rate_override)
                        /* bgfix:4250089 having this extra default executes always when version type is revenue
                        ,tmp.rw_cost_rate_override */
                         ) cost_rate_override
              ,decode(perdRec.version_type ,'ALL', NVL(fptmp.burdened_cost_rate,tmp.burden_cost_rate_override)
                                            ,'COST',NVL(fptmp.burdened_cost_rate,tmp.burden_cost_rate_override)
                                            ,decode(p_generation_context,'REVENUE_MARKUP' /* bug fix:4213824 added decode to get the bdRt */
                        ,NVL(fptmp.burdened_cost_rate,tmp.burden_cost_rate_override),tmp.burden_cost_rate_override)
                        /* bug fix:4250089 ,tmp.burden_cost_rate_override */
                        ) burden_rate_override
          ,decode(perdRec.version_type ,'ALL', NVL(fptmp.revenue_bill_rate,tmp.bill_rate_override)
                                            ,'REVENUE',NVL(fptmp.revenue_bill_rate,tmp.bill_rate_override)
                                            ,tmp.bill_rate_override) bill_rate_override
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
        /* Bug fix:4568011: set a flag based on the bill rate override passed from generation process
         * to indicate that revenue should be calculated based on markup or not
         * If bill rate override is passed, then do not calculate markup
         */
        ,decode(p_generation_context,'REVENUE_MARKUP',
                decode(fptmp.revenue_bill_rate,NULL,'Y','N'),'Y') markup_calculation_flag
    FROM  pa_fp_rollup_tmp tmp
          ,pa_fp_gen_rate_tmp fptmp
          ,pa_resource_assignments ra
          ,pa_fp_spread_calc_tmp caltmp
    WHERE  caltmp.budget_version_id = p_budget_version_id
    AND    caltmp.resource_assignment_id = ra.resource_assignment_id
    AND    nvl(caltmp.skip_record_flag,'N') <> 'Y'
    AND    tmp.resource_assignment_id = ra.resource_assignment_id
    AND    tmp.txn_currency_code = caltmp.txn_currency_code
    AND    NVL(tmp.system_reference5,'N') = 'N'  /* donot pick already processed lines */
    AND    fptmp.target_res_asg_id = tmp.resource_assignment_id
    AND    fptmp.txn_currency_code = tmp.txn_currency_code
    AND    NVL(tmp.period_name,'SUMMARY') = nvl(fptmp.period_name,NVL(tmp.period_name,'SUMMARY'))
    /* Bug fix: 4216423 markup should be calculated for both rate and non-rate base resource
    AND    ((p_generation_context = 'SPREAD')
        OR
        ( p_generation_context = 'REVENUE_MARKUP'
          AND NVL(ra.rate_based_flag,'N') = 'N'
        ))
    */
    ;

    /* This cursor will be executed only if the debug profile is set Y
     * this is required in order figure out what overrides are exists in the generation temp table */
    CURSOR cur_dbgGenRtOvr IS
    SELECT tmp.rowid
              ,fptmp.target_res_asg_id    RaId
              ,fptmp.txn_currency_code    CurCode
              ,tmp.start_date
              ,tmp.end_date
              ,fptmp.period_name      period_name
          ,fptmp.raw_cost_rate        cost_rate_override
          ,fptmp.burdened_cost_rate   burden_rate_override
          ,fptmp.revenue_bill_rate    bill_rate_override
      ,decode(p_generation_context,'REVENUE_MARKUP',
                                decode(fptmp.revenue_bill_rate,NULL,'Y','N'),'Y') markup_calculation_flag
    FROM  pa_fp_rollup_tmp tmp
              ,pa_fp_gen_rate_tmp fptmp
              ,pa_resource_assignments ra
              ,pa_fp_spread_calc_tmp caltmp
        WHERE  caltmp.budget_version_id = p_budget_version_id
        AND    caltmp.resource_assignment_id = ra.resource_assignment_id
        AND    nvl(caltmp.skip_record_flag,'N') <> 'Y'
        AND    tmp.resource_assignment_id = ra.resource_assignment_id
        AND    tmp.txn_currency_code = caltmp.txn_currency_code
        AND    NVL(tmp.system_reference5,'N') = 'N'  /* donot pick already processed lines */
        AND    fptmp.target_res_asg_id = tmp.resource_assignment_id
        AND    fptmp.txn_currency_code = tmp.txn_currency_code
        AND    NVL(tmp.period_name,'SUMMARY') = nvl(fptmp.period_name,NVL(tmp.period_name,'SUMMARY'))
    /* Bug fix: 4216423 markup should be calculated for both rate and non-rate base resource
        AND    ((p_generation_context = 'SPREAD')
                OR
                ( p_generation_context = 'REVENUE_MARKUP'
                  AND NVL(ra.rate_based_flag,'N') = 'N'
                ))
    */
    ;

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
    l_markup_calculation_flag_tab   pa_plsql_datatypes.Char1TabTyp;


BEGIN
    /* Initialize the out variables */
    x_return_status := 'S';
    x_msg_data := NULL;
    x_msg_count := 0;
    g_stage :='Update_rollupTmp_OvrRates:100';
    perdRec := NULL;
    OPEN periodDetails;
    FETCH periodDetails INTO perdRec;
    CLOSE periodDetails;

    If perdRec.time_phase_code in ('G','P')  Then
        g_stage :='Update_rollupTmp_OvrRates:101';
        --print_msg('Update rollup tmp period name where it is null');
        UPDATE pa_fp_rollup_tmp tmp
            SET tmp.period_name = (select gp.period_name
                               from gl_periods gp
                               where gp.period_set_name = perdRec.period_set_name
                               and gp.adjustment_period_flag = 'N'
                               and gp.period_type = decode(perdRec.time_phase_code,'G',perdRec.accounted_period_type
                                ,'P',perdRec.pa_period_type,gp.period_type)
                               and  tmp.start_date between gp.start_date and gp.end_date
                   and rownum = 1
                               )
            WHERE tmp.period_name is NULL
        AND  tmp.budget_version_id = p_budget_version_id
        AND NVL(tmp.system_reference5,'N') = 'N'
         ;
        --print_msg('Number of rows updated['||sql%rowcount||']');
    Else
        g_stage :='Update_rollupTmp_OvrRates:102';
        /* Non-Timephased budgets period name must be null */
        UPDATE pa_fp_rollup_tmp tmp
                SET tmp.period_name = NULL
                WHERE tmp.period_name is NOT NULL
        AND NVL(tmp.system_reference5,'N') = 'N'
        AND  tmp.budget_version_id = p_budget_version_id;
                print_msg('Number of rows updated['||sql%rowcount||']');
    End If;

    IF ((p_calling_module in ('FORECAST_GENERATION') AND perdRec.time_phase_code in ('G','P')) OR
       (p_generation_context = 'REVENUE_MARKUP' ) OR
 	(p_calling_module in ('FORECAST_GENERATION','BUDGET_GENERATION') and perdRec.time_phase_code = 'N'
 	and perdRec.version_type = 'ALL'))  Then --{
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
        l_markup_calculation_flag_tab.delete;
        g_stage :='Update_rollupTmp_OvrRates:103';
        --print_msg('Fetching rate overrides details from pa_fp_gen_rate_tmp tables');
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
                    ,l_PROJFUNC_REV_RATE_DATE_tab
            ,l_markup_calculation_flag_tab;
        CLOSE fptmpDetails;
        IF l_rowid_tab.COUNT > 0 THEN
       /*
            If NVL(p_pa_debug_mode,'N')  = 'Y' Then
              for i in cur_dbgGenRtOvr loop
                print_msg('Generation context['||p_generation_context||']');
                print_msg('GenRtRaid['||i.raid||']cur['||i.curcode||']perNa['||i.period_name||']CstRtOv['||i.cost_rate_override||']');
                print_msg('bdRtOvr['||i.burden_rate_override||']billRtOvr['||i.bill_rate_override||']markup_calculation_flag[||i.markup_calculation_flag||']');
              end loop;
            End If;
       */
            g_stage :='Update_rollupTmp_OvrRates:104';
            --print_msg(g_stage||'Number of rows fetched['||l_rowid_tab.COUNT||']');
            FORALL i IN  l_rowid_tab.FIRST .. l_rowid_tab.LAST
            UPDATE pa_fp_rollup_tmp tmp
            SET tmp.rw_cost_rate_override = l_cost_rate_override_tab(i)
               ,tmp.burden_cost_rate_override = l_burden_rate_override_tab(i)
               ,tmp.bill_rate_override = l_bill_rate_override_tab(i)
               ,tmp.PROJECT_COST_RATE_TYPE = nvl(l_PROJECT_COST_RATE_TYPE_tab(i),tmp.PROJECT_COST_RATE_TYPE)
               ,tmp.PROJECT_COST_EXCHANGE_RATE = nvl(l_PROJECT_COST_EXG_RATE_tab(i),tmp.PROJECT_COST_EXCHANGE_RATE)
               ,tmp.PROJECT_COST_RATE_DATE_TYPE = nvl(l_PROJECT_COST_DATE_TYPE_tab(i),tmp.PROJECT_COST_RATE_DATE_TYPE)
               ,tmp.PROJECT_COST_RATE_DATE   = nvl(l_PROJECT_COST_RATE_DATE_tab(i),tmp.PROJECT_COST_RATE_DATE)
               ,tmp.PROJECT_REV_RATE_TYPE    = nvl(l_PROJECT_REV_RATE_TYPE_tab(i),tmp.PROJECT_REV_RATE_TYPE)
               ,tmp.PROJECT_REV_EXCHANGE_RATE  = nvl(l_PROJECT_REV_EXG_RATE_tab(i),tmp.PROJECT_REV_EXCHANGE_RATE)
               ,tmp.PROJECT_REV_RATE_DATE_TYPE = nvl(l_PROJECT_REV_DATE_TYPE_tab(i),tmp.PROJECT_REV_RATE_DATE_TYPE)
               ,tmp.PROJECT_REV_RATE_DATE   = nvl(l_PROJECT_REV_RATE_DATE_tab(i),tmp.PROJECT_REV_RATE_DATE)
               ,tmp.PROJFUNC_COST_RATE_TYPE   = nvl(l_PROJFUNC_COST_RATE_TYPE_tab(i),tmp.PROJFUNC_COST_RATE_TYPE)
               ,tmp.PROJFUNC_COST_EXCHANGE_RATE  = nvl(l_PROJFUNC_COST_EXG_RATE_tab(i),tmp.PROJFUNC_COST_EXCHANGE_RATE)
               ,tmp.PROJFUNC_COST_RATE_DATE_TYPE  = nvl(l_PROJFUNC_COST_DATE_TYPE_tab(i),tmp.PROJFUNC_COST_RATE_DATE_TYPE)
               ,tmp.PROJFUNC_COST_RATE_DATE     = nvl(l_PROJFUNC_COST_RATE_DATE_tab(i),tmp.PROJFUNC_COST_RATE_DATE)
               ,tmp.PROJFUNC_REV_RATE_TYPE    = nvl(l_PROJFUNC_REV_RATE_TYPE_tab(i),tmp.PROJFUNC_REV_RATE_TYPE)
               ,tmp.PROJFUNC_REV_EXCHANGE_RATE  = nvl(l_PROJFUNC_REV_EXG_RATE_tab(i),tmp.PROJFUNC_REV_EXCHANGE_RATE)
               ,tmp.PROJFUNC_REV_RATE_DATE_TYPE   =nvl(l_PROJFUNC_REV_DATE_TYPE_tab(i),tmp.PROJFUNC_REV_RATE_DATE_TYPE)
               ,tmp.PROJFUNC_REV_RATE_DATE = nvl(l_PROJFUNC_REV_RATE_DATE_tab(i),tmp.PROJFUNC_REV_RATE_DATE)
           ,tmp.SYSTEM_REFERENCE6 = nvl(l_markup_calculation_flag_tab(i),'Y')
            WHERE tmp.rowid = l_rowid_tab(i);

        END IF;
    END IF;  --}

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := 'U';
            x_msg_data := SQLCODE||SQLERRM;
            x_msg_count := 1;

END Update_rollupTmp_OvrRates;

/*
This API is called when source context is BUDGET_LINE and delete_budget_lines flag is Y
Before deleting budget lines, this api calls Pji reporting apis to update the balances
and then it deletes the budget lines only if there are no actuals exists.
and the budget start date is greater than ETC start date
*/
PROCEDURE delete_budget_lines
    ( p_budget_version_id         IN  pa_budget_lines.budget_version_id%type
     ,p_resource_assignment_id    IN  pa_resource_assignments.resource_assignment_id%TYPE
         ,p_txn_currency_code         IN  pa_budget_lines.txn_currency_code%TYPE
         ,p_line_start_date           IN  pa_budget_lines.start_date%TYPE
         ,p_line_end_date             IN  pa_budget_lines.end_date%TYPE
     ,p_source_context            IN  varchar2
         ,x_return_status             OUT NOCOPY VARCHAR2
         ,x_msg_count                 OUT NOCOPY NUMBER
         ,x_msg_data                  OUT NOCOPY VARCHAR2
     ,x_num_rowsdeleted       OUT NOCOPY Number
         ) IS

    l_debug_mode               VARCHAR2(30);
    l_stage                    NUMBER;
    l_msg_index_out            NUMBER;
    l_return_status            VARCHAR2(30);
    PJI_EXCEPTION              EXCEPTION;

    CURSOR get_delete_bl_id IS
    SELECT bl.budget_line_id
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
              ,bl.raw_cost      projfunc_raw_cost
              ,bl.burdened_cost projfunc_burdened_cost
              ,bl.revenue       projfunc_revenue
              ,bl.project_currency_code
              ,bl.projfunc_currency_code
          ,bl.cost_rejection_code
              ,bl.revenue_rejection_code
              ,bl.burden_rejection_code
              ,bl.pfc_cur_conv_rejection_code
              ,bl.pc_cur_conv_rejection_code
        FROM pa_budget_lines bl
    WHERE bl.resource_assignment_id = p_resource_assignment_id
    AND   bl.txn_currency_code      = p_txn_currency_code
        AND ((p_line_start_date is NULL AND p_line_end_date is NULL )
             OR (p_line_start_date is NOT NULL AND p_line_end_date is NOT NULL
                and bl.start_date BETWEEN p_line_start_date AND p_line_end_date
        )
        )
/* Bug 4344112 -- Actuals can be stamped as null or zero, in both cases
   we need to delete the lines. In case of this bug actuals are getting
   stamped as ZERO so we are not deleting this line, the spread logic
   breaks becoz of the zero in actuals.
   Lines with zero actuals can be deleted as lines with NULL actuals. */
 /****** AND (bl.init_quantity          IS NULL AND
              bl.txn_init_raw_cost      IS NULL AND
              bl.txn_init_burdened_cost IS NULL AND
              bl.txn_init_revenue       IS NULL);   ******/
    AND (NVL(bl.init_quantity,0)           = 0 AND
         NVL(bl.txn_init_raw_cost ,0)      = 0 AND
         NVL(bl.txn_init_burdened_cost ,0) = 0 AND
         NVL(bl.txn_init_revenue ,0)       = 0);


    /* This cursor picks all the budget lines where ETC start date falls and updates the
    * plan = Actuals so that remaining ETC will be spread forward
    */
        CURSOR cur_UpdBlWithZeroEtc IS
        SELECT bl.budget_line_id
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
              ,bl.raw_cost      projfunc_raw_cost
              ,bl.burdened_cost projfunc_burdened_cost
              ,bl.revenue       projfunc_revenue
              ,bl.project_currency_code
              ,bl.projfunc_currency_code
              ,bl.cost_rejection_code
              ,bl.revenue_rejection_code
              ,bl.burden_rejection_code
              ,bl.pfc_cur_conv_rejection_code
              ,bl.pc_cur_conv_rejection_code
          ,bl.init_quantity
          ,bl.txn_init_raw_cost
          ,bl.txn_init_burdened_cost
          ,bl.txn_init_revenue
          ,bl.project_init_raw_cost
          ,bl.project_init_burdened_cost
          ,bl.project_init_revenue
          ,bl.init_raw_cost
          ,bl.init_burdened_cost
          ,bl.init_revenue
        FROM pa_budget_lines bl
        WHERE bl.resource_assignment_id = p_resource_assignment_id
        AND   bl.txn_currency_code      = p_txn_currency_code
        AND ((p_line_start_date is NULL AND p_line_end_date is NULL )
             OR (p_line_start_date is NOT NULL AND p_line_end_date is NOT NULL
                and bl.start_date BETWEEN p_line_start_date AND p_line_end_date
                )
            )
        AND g_spread_from_date is NOT NULL
        AND ((bl.start_date >= g_spread_from_date )
             /* bug fix: 4139354 and (g_spread_from_date BETWEEN bl.start_date AND bl.end_date)*/
             OR (g_spread_from_date BETWEEN bl.start_date AND bl.end_date)
            )
        AND ( NVL(bl.init_quantity,0) <> 0 OR
                 NVL(bl.txn_init_raw_cost ,0) <> 0 OR
                 NVL(bl.txn_init_burdened_cost ,0) <> 0 OR
                 NVL(bl.txn_init_revenue ,0) <> 0
       );

        l_budget_Line_id_tab   pa_plsql_datatypes.IdTabTyp;
        l_resource_assignment_id_tab pa_plsql_datatypes.IdTabTyp;
        l_txn_currency_code_tab      pa_plsql_datatypes.Char50TabTyp;
        l_start_date_tab             pa_plsql_datatypes.DateTabTyp;
        l_end_date_tab               pa_plsql_datatypes.DateTabTyp;
        l_period_name_tab            pa_plsql_datatypes.Char50TabTyp;
        l_quantity_tab                  pa_plsql_datatypes.NumTabTyp;
        l_txn_raw_cost_tab              pa_plsql_datatypes.NumTabTyp;
        l_txn_burdened_cost_tab         pa_plsql_datatypes.NumTabTyp;
        l_txn_revenue_tab               pa_plsql_datatypes.NumTabTyp;
        l_project_raw_cost_tab          pa_plsql_datatypes.NumTabTyp;
        l_project_burdened_cost_tab     pa_plsql_datatypes.NumTabTyp;
        l_project_revenue_tab           pa_plsql_datatypes.NumTabTyp;
        l_projfunc_raw_cost_tab         pa_plsql_datatypes.NumTabTyp;
        l_projfunc_burdened_cost_tab    pa_plsql_datatypes.NumTabTyp;
        l_projfunc_revenue_tab          pa_plsql_datatypes.NumTabTyp;
        l_project_curr_code_tab         pa_plsql_datatypes.Char50TabTyp;
        l_projfunc_curr_code_tab        pa_plsql_datatypes.Char50TabTyp;
        l_cost_rejection_code_tab               pa_plsql_datatypes.Char50TabTyp;
        l_revenue_rejection_code_tab    pa_plsql_datatypes.Char50TabTyp;
        l_burden_rejection_code_tab             pa_plsql_datatypes.Char50TabTyp;
        l_pfc_cur_conv_rej_code_tab       pa_plsql_datatypes.Char50TabTyp;
        l_pc_cur_conv_rej_code_tab        pa_plsql_datatypes.Char50TabTyp;
    l_init_quantity_tab       pa_plsql_datatypes.NumTabTyp;
    l_txn_init_raw_cost_tab       pa_plsql_datatypes.NumTabTyp;
    l_txn_init_burdened_cost_tab      pa_plsql_datatypes.NumTabTyp;
    l_txn_init_revenue_tab        pa_plsql_datatypes.NumTabTyp;
    l_pj_init_raw_cost_tab        pa_plsql_datatypes.NumTabTyp;
    l_pj_init_burdened_cost_tab   pa_plsql_datatypes.NumTabTyp;
    l_pj_init_revenue_tab         pa_plsql_datatypes.NumTabTyp;
    l_pjf_init_raw_cost_tab       pa_plsql_datatypes.NumTabTyp;
    l_pjf_init_burdened_cost_tab      pa_plsql_datatypes.NumTabTyp;
    l_pjf_init_revenue_tab        pa_plsql_datatypes.NumTabTyp;

BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := 'S';
    x_msg_data := NULL;
    g_stage := 'delete_budget_lines:100';
    IF p_pa_debug_mode = 'Y' Then
            pa_debug.init_err_stack('PA_FP_CALC_PLAN_PKG.delete_budget_lines');
        print_msg('Entered PA_FP_CALC_PLAN_PKG.delete_budget_lines ResAssId['||p_resource_assignment_id||']spreadDate['||g_spread_from_date||']');
    End If;
        l_stage := 7800;
        OPEN  get_delete_bl_id ;
        FETCH get_delete_bl_id BULK COLLECT INTO
                l_budget_Line_id_tab
                ,l_resource_assignment_id_tab
                ,l_txn_currency_code_tab
                ,l_start_date_tab
                ,l_end_date_tab
                ,l_period_name_tab
                ,l_quantity_tab
                ,l_txn_raw_cost_tab
                ,l_txn_burdened_cost_tab
                ,l_txn_revenue_tab
                ,l_project_raw_cost_tab
                ,l_project_burdened_cost_tab
                ,l_project_revenue_tab
                ,l_projfunc_raw_cost_tab
                ,l_projfunc_burdened_cost_tab
                ,l_projfunc_revenue_tab
                ,l_project_curr_code_tab
                ,l_projfunc_curr_code_tab
        ,l_cost_rejection_code_tab
                ,l_revenue_rejection_code_tab
                ,l_burden_rejection_code_tab
                ,l_pfc_cur_conv_rej_code_tab
                ,l_pc_cur_conv_rej_code_tab;
        CLOSE get_delete_bl_id;

    --print_msg('Number Of budget Lines to be deleted ['||l_budget_Line_id_tab.COUNT||']');
        IF l_budget_Line_id_tab.COUNT > 0 Then --{
            FOR i IN l_budget_Line_id_tab.FIRST .. l_budget_Line_id_tab.LAST LOOP
            IF NVL(g_rollup_required_flag,'N') = 'Y' Then  --{
                g_stage := 'delete_budget_lines:101';
                    --print_msg('Call reporting lines api before deleting the budgetLines');
                    -- call reporting api to update these amounts
			/* bug fix:5031388
                    IF (l_cost_rejection_code_tab(i) is NULL AND
                        l_revenue_rejection_code_tab(i) is NULL AND
                        l_burden_rejection_code_tab(i) is NULL AND
                        l_pfc_cur_conv_rej_code_tab(i) is NULL AND
                        l_pc_cur_conv_rej_code_tab(i) is NULL )  THEN
			*/
                        /* update the reporting lines before deleteing the budget lines */
                        Add_Toreporting_Tabls
                                (p_calling_module               => 'CALCULATE_API'
                                ,p_activity_code                => 'UPDATE'
                                ,p_budget_version_id            => p_budget_version_id
                                ,p_budget_line_id               => l_budget_Line_id_tab(i)
                                ,p_resource_assignment_id       => l_resource_assignment_id_tab(i)
                                ,p_start_date                   => l_start_date_tab(i)
                                ,p_end_date                     => l_end_date_tab(i)
                                ,p_period_name                  => l_period_name_tab(i)
                                ,p_txn_currency_code            => l_txn_currency_code_tab(i)
                                ,p_quantity                     => l_quantity_tab(i) * -1
                                ,p_txn_raw_cost                 => l_txn_raw_cost_tab(i) * -1
                                ,p_txn_burdened_cost            => l_txn_burdened_cost_tab(i) * -1
                                ,p_txn_revenue                  => l_txn_revenue_tab(i) * -1
                                ,p_project_currency_code        => l_project_curr_code_tab(i)
                                ,p_project_raw_cost             => l_project_raw_cost_tab(i) * -1
                                ,p_project_burdened_cost        => l_project_burdened_cost_tab(i) * -1
                                ,p_project_revenue              => l_project_revenue_tab(i) * -1
                                ,p_projfunc_currency_code       => l_projfunc_curr_code_tab(i)
                                ,p_projfunc_raw_cost            => l_projfunc_raw_cost_tab(i) * -1
                                ,p_projfunc_burdened_cost       => l_projfunc_burdened_cost_tab(i) * -1
                                ,p_projfunc_revenue             => l_projfunc_revenue_tab(i) * -1
				,p_rep_line_mode               => 'REVERSAL'
                                ,x_msg_data                     => x_msg_data
                                ,x_return_status                => l_return_status
                                );
                	/* bug fix:5031388END If;*/
            --print_msg('After calling Add_Toreporting_Tabls Api retSts['||l_return_status||']');
            If l_return_status <> 'S' Then
                    RAISE PJI_EXCEPTION;
            END IF;
             END IF; --}

        /* MRC enhancement changes */
         IF NVL(G_populate_mrc_tab_flag,'N') = 'Y' Then  --{
                        /* add the deleted budget lines to mrc plsql tabs */
                        Populate_MRC_plsqlTabs
                                (p_calling_module               => 'CALCULATE_API'
                                ,p_budget_version_id            => p_budget_version_id
                                ,p_budget_line_id               => l_budget_Line_id_tab(i)
                                ,p_resource_assignment_id       => l_resource_assignment_id_tab(i)
                                ,p_start_date                   => l_start_date_tab(i)
                                ,p_end_date                     => l_end_date_tab(i)
                                ,p_period_name                  => l_period_name_tab(i)
                                ,p_txn_currency_code            => l_txn_currency_code_tab(i)
                                ,p_quantity                     => l_quantity_tab(i)
                                ,p_txn_raw_cost                 => l_txn_raw_cost_tab(i)
                                ,p_txn_burdened_cost            => l_txn_burdened_cost_tab(i)
                                ,p_txn_revenue                  => l_txn_revenue_tab(i)
                                ,p_project_currency_code        => l_project_curr_code_tab(i)
                                ,p_project_raw_cost             => l_project_raw_cost_tab(i)
                                ,p_project_burdened_cost        => l_project_burdened_cost_tab(i)
                                ,p_project_revenue              => l_project_revenue_tab(i)
                                ,p_projfunc_currency_code       => l_projfunc_curr_code_tab(i)
                                ,p_projfunc_raw_cost            => l_projfunc_raw_cost_tab(i)
                                ,p_projfunc_burdened_cost       => l_projfunc_burdened_cost_tab(i)
                                ,p_projfunc_revenue             => l_projfunc_revenue_tab(i)
                ,p_delete_flag                  => 'Y'
                                ,x_msg_data                     => x_msg_data
                                ,x_return_status                => l_return_status
                                );
             END IF; --}
          END LOOP;
    End If; --}

        l_stage := 7820;
    IF NVL(l_return_status,'S') = 'S' Then
        IF l_budget_Line_id_tab.COUNT > 0 Then
           g_stage := 'delete_budget_lines:102';
           --print_msg('7820.1 Deleteing budget lines');
                   FORALL i IN l_budget_Line_id_tab.FIRST .. l_budget_Line_id_tab.LAST
               DELETE FROM pa_budget_lines bl
               WHERE bl.budget_line_id = l_budget_Line_id_tab(i) ;
           x_num_rowsdeleted := sql%rowcount;
           --print_msg('Num Of Rows Deleted from BdugetLines['||x_num_rowsdeleted||']');
        END IF;
    End IF;

    IF NVL(l_return_status,'S') = 'S' AND g_spread_from_date is NOT NULL Then  --{
            l_stage := 7830;
        --print_msg(l_stage||'Make zero ETC on the budget line where etc start date falls');
        l_budget_Line_id_tab.delete;
                l_resource_assignment_id_tab.delete;
                l_txn_currency_code_tab.delete;
                l_start_date_tab.delete;
                l_end_date_tab.delete;
                l_period_name_tab.delete;
                l_quantity_tab.delete;
                l_txn_raw_cost_tab.delete;
                l_txn_burdened_cost_tab.delete;
                l_txn_revenue_tab.delete;
                l_project_raw_cost_tab.delete;
                l_project_burdened_cost_tab.delete;
                l_project_revenue_tab.delete;
                l_projfunc_raw_cost_tab.delete;
                l_projfunc_burdened_cost_tab.delete;
                l_projfunc_revenue_tab.delete;
                l_project_curr_code_tab.delete;
                l_projfunc_curr_code_tab.delete;
                l_cost_rejection_code_tab.delete;
                l_revenue_rejection_code_tab.delete;
                l_burden_rejection_code_tab.delete;
                l_pfc_cur_conv_rej_code_tab.delete;
                l_pc_cur_conv_rej_code_tab.delete;
                l_init_quantity_tab.delete;
                l_txn_init_raw_cost_tab.delete;
                l_txn_init_burdened_cost_tab.delete;
                l_txn_init_revenue_tab.delete;
        l_pj_init_raw_cost_tab.delete;
            l_pj_init_burdened_cost_tab.delete;
            l_pj_init_revenue_tab.delete;
            l_pjf_init_raw_cost_tab.delete;
            l_pjf_init_burdened_cost_tab.delete;
            l_pjf_init_revenue_tab.delete;
        g_stage := 'delete_budget_lines:103';
            OPEN  cur_UpdBlWithZeroEtc;
            FETCH cur_UpdBlWithZeroEtc BULK COLLECT INTO
                l_budget_Line_id_tab
                ,l_resource_assignment_id_tab
                ,l_txn_currency_code_tab
                ,l_start_date_tab
                ,l_end_date_tab
                ,l_period_name_tab
                ,l_quantity_tab
                ,l_txn_raw_cost_tab
                ,l_txn_burdened_cost_tab
                ,l_txn_revenue_tab
                ,l_project_raw_cost_tab
                ,l_project_burdened_cost_tab
                ,l_project_revenue_tab
                ,l_projfunc_raw_cost_tab
                ,l_projfunc_burdened_cost_tab
                ,l_projfunc_revenue_tab
                ,l_project_curr_code_tab
                ,l_projfunc_curr_code_tab
                ,l_cost_rejection_code_tab
                ,l_revenue_rejection_code_tab
                ,l_burden_rejection_code_tab
                ,l_pfc_cur_conv_rej_code_tab
                ,l_pc_cur_conv_rej_code_tab
        ,l_init_quantity_tab
            ,l_txn_init_raw_cost_tab
            ,l_txn_init_burdened_cost_tab
            ,l_txn_init_revenue_tab
        ,l_pj_init_raw_cost_tab
                ,l_pj_init_burdened_cost_tab
                ,l_pj_init_revenue_tab
                ,l_pjf_init_raw_cost_tab
                ,l_pjf_init_burdened_cost_tab
                ,l_pjf_init_revenue_tab;
            CLOSE cur_UpdBlWithZeroEtc ;

            --print_msg('Number Of budget Lines to be updated ['||l_budget_Line_id_tab.COUNT||']');
            IF l_budget_Line_id_tab.COUNT > 0 Then
            IF NVL(g_rollup_required_flag,'N') = 'Y' Then  --{
            g_stage := 'delete_budget_lines:104';
                    --print_msg('Call reporting lines api before deleting the budgetLines');
                    -- call reporting api to update these amounts
                    FOR i IN l_budget_Line_id_tab.FIRST .. l_budget_Line_id_tab.LAST LOOP
			/* bug fix:5031388
                          IF (l_cost_rejection_code_tab(i) is NULL AND
                            l_revenue_rejection_code_tab(i) is NULL AND
                            l_burden_rejection_code_tab(i) is NULL AND
                            l_pfc_cur_conv_rej_code_tab(i) is NULL AND
                            l_pc_cur_conv_rej_code_tab(i) is NULL )  THEN
			  */
                            /* update the reporting lines before deleteing the budget lines */
                            Add_Toreporting_Tabls
                                (p_calling_module               => 'CALCULATE_API'
                                ,p_activity_code                => 'UPDATE'
                                ,p_budget_version_id            => p_budget_version_id
                                ,p_budget_line_id               => l_budget_Line_id_tab(i)
                                ,p_resource_assignment_id       => l_resource_assignment_id_tab(i)
                                ,p_start_date                   => l_start_date_tab(i)
                                ,p_end_date                     => l_end_date_tab(i)
                                ,p_period_name                  => l_period_name_tab(i)
                                ,p_txn_currency_code            => l_txn_currency_code_tab(i)
                                ,p_quantity                     => l_quantity_tab(i) * -1
                                ,p_txn_raw_cost                 => l_txn_raw_cost_tab(i) * -1
                                ,p_txn_burdened_cost            => l_txn_burdened_cost_tab(i) * -1
                                ,p_txn_revenue                  => l_txn_revenue_tab(i) * -1
                                ,p_project_currency_code        => l_project_curr_code_tab(i)
                                ,p_project_raw_cost             => l_project_raw_cost_tab(i) * -1
                                ,p_project_burdened_cost        => l_project_burdened_cost_tab(i) * -1
                                ,p_project_revenue              => l_project_revenue_tab(i) * -1
                                ,p_projfunc_currency_code       => l_projfunc_curr_code_tab(i)
                                ,p_projfunc_raw_cost            => l_projfunc_raw_cost_tab(i) * -1
                                ,p_projfunc_burdened_cost       => l_projfunc_burdened_cost_tab(i) * -1
                                ,p_projfunc_revenue             => l_projfunc_revenue_tab(i) * -1
				,p_rep_line_mode               => 'REVERSAL'
                                ,x_msg_data                     => x_msg_data
                                ,x_return_status                => l_return_status
                                );
                           /* bug fix:5031388END If;*/

                    END LOOP;
                    --print_msg('After calling Add_Toreporting_Tabls Api retSts['||l_return_status||']');
                    If l_return_status <> 'S' Then
                            RAISE PJI_EXCEPTION;
                    END IF;
           END IF; --}
            End If;
        If NVL(l_return_status,'S') = 'S' Then
          IF l_budget_Line_id_tab.COUNT > 0 Then
            g_stage := 'delete_budget_lines:105';
            FORALL i IN  l_budget_Line_id_tab.FIRST .. l_budget_Line_id_tab.LAST
                UPDATE pa_budget_lines bl
                SET bl.quantity = l_init_quantity_tab(i)
                  ,bl.txn_raw_cost = l_txn_init_raw_cost_tab(i)
                  ,bl.txn_burdened_cost = l_txn_init_burdened_cost_tab(i)
                  ,bl.txn_revenue = l_txn_init_revenue_tab(i)
                  ,bl.project_raw_cost = l_pj_init_raw_cost_tab(i)
                          ,bl.project_burdened_cost = l_pj_init_burdened_cost_tab(i)
                              ,bl.project_revenue = l_pj_init_revenue_tab(i)
                          ,bl.raw_cost = l_pjf_init_raw_cost_tab(i)
                          ,bl.burdened_cost = l_pjf_init_burdened_cost_tab(i)
                          ,bl.revenue = l_pjf_init_revenue_tab(i)
                WHERE bl.budget_line_id = l_budget_Line_id_tab(i);

            /* Now pass +ve budget line values (Updated values) to PJI reporting api */
            l_stage := 7840;
                    l_budget_Line_id_tab.delete;
                    l_resource_assignment_id_tab.delete;
                    l_txn_currency_code_tab.delete;
                    l_start_date_tab.delete;
                    l_end_date_tab.delete;
                    l_period_name_tab.delete;
                    l_quantity_tab.delete;
                    l_txn_raw_cost_tab.delete;
                    l_txn_burdened_cost_tab.delete;
                    l_txn_revenue_tab.delete;
                    l_project_raw_cost_tab.delete;
                    l_project_burdened_cost_tab.delete;
                    l_project_revenue_tab.delete;
                    l_projfunc_raw_cost_tab.delete;
                    l_projfunc_burdened_cost_tab.delete;
                    l_projfunc_revenue_tab.delete;
                    l_project_curr_code_tab.delete;
                    l_projfunc_curr_code_tab.delete;
                    l_cost_rejection_code_tab.delete;
                    l_revenue_rejection_code_tab.delete;
                    l_burden_rejection_code_tab.delete;
                    l_pfc_cur_conv_rej_code_tab.delete;
                    l_pc_cur_conv_rej_code_tab.delete;
                    l_init_quantity_tab.delete;
                    l_txn_init_raw_cost_tab.delete;
                    l_txn_init_burdened_cost_tab.delete;
                    l_txn_init_revenue_tab.delete;
                    l_pj_init_raw_cost_tab.delete;
                    l_pj_init_burdened_cost_tab.delete;
                    l_pj_init_revenue_tab.delete;
                    l_pjf_init_raw_cost_tab.delete;
                    l_pjf_init_burdened_cost_tab.delete;
                    l_pjf_init_revenue_tab.delete;
            g_stage := 'delete_budget_lines:106';
                    OPEN  cur_UpdBlWithZeroEtc;
                    FETCH cur_UpdBlWithZeroEtc BULK COLLECT INTO
                    l_budget_Line_id_tab
                    ,l_resource_assignment_id_tab
                    ,l_txn_currency_code_tab
                    ,l_start_date_tab
                    ,l_end_date_tab
                    ,l_period_name_tab
                    ,l_quantity_tab
                    ,l_txn_raw_cost_tab
                    ,l_txn_burdened_cost_tab
                    ,l_txn_revenue_tab
                    ,l_project_raw_cost_tab
                    ,l_project_burdened_cost_tab
                    ,l_project_revenue_tab
                    ,l_projfunc_raw_cost_tab
                    ,l_projfunc_burdened_cost_tab
                    ,l_projfunc_revenue_tab
                    ,l_project_curr_code_tab
                    ,l_projfunc_curr_code_tab
                    ,l_cost_rejection_code_tab
                    ,l_revenue_rejection_code_tab
                    ,l_burden_rejection_code_tab
                    ,l_pfc_cur_conv_rej_code_tab
                    ,l_pc_cur_conv_rej_code_tab
                    ,l_init_quantity_tab
                    ,l_txn_init_raw_cost_tab
                    ,l_txn_init_burdened_cost_tab
                    ,l_txn_init_revenue_tab
                    ,l_pj_init_raw_cost_tab
                    ,l_pj_init_burdened_cost_tab
                    ,l_pj_init_revenue_tab
                    ,l_pjf_init_raw_cost_tab
                    ,l_pjf_init_burdened_cost_tab
                    ,l_pjf_init_revenue_tab;
                    CLOSE cur_UpdBlWithZeroEtc ;

                    --print_msg('Number Of budget Lines to be deleted ['||l_budget_Line_id_tab.COUNT||']');
                    IF l_budget_Line_id_tab.COUNT > 0 Then
             IF NVL(g_rollup_required_flag,'N') = 'Y' Then  --{
               g_stage := 'delete_budget_lines:107';
                           --print_msg('Call reporting lines api before deleting the budgetLines');
                           -- call reporting api to update these amounts
                          FOR i IN l_budget_Line_id_tab.FIRST .. l_budget_Line_id_tab.LAST LOOP
			    /* bug fix:5031388
                            IF (l_cost_rejection_code_tab(i) is NULL AND
                                l_revenue_rejection_code_tab(i) is NULL AND
                                l_burden_rejection_code_tab(i) is NULL AND
                                l_pfc_cur_conv_rej_code_tab(i) is NULL AND
                                l_pc_cur_conv_rej_code_tab(i) is NULL )  THEN
				*/
                                /* update the reporting lines after updating the budget lines */
                                Add_Toreporting_Tabls
                                (p_calling_module               => 'CALCULATE_API'
                                ,p_activity_code                => 'UPDATE'
                                ,p_budget_version_id            => p_budget_version_id
                                ,p_budget_line_id               => l_budget_Line_id_tab(i)
                                ,p_resource_assignment_id       => l_resource_assignment_id_tab(i)
                                ,p_start_date                   => l_start_date_tab(i)
                                ,p_end_date                     => l_end_date_tab(i)
                                ,p_period_name                  => l_period_name_tab(i)
                                ,p_txn_currency_code            => l_txn_currency_code_tab(i)
                                ,p_quantity                     => l_quantity_tab(i)
                                ,p_txn_raw_cost                 => l_txn_raw_cost_tab(i)
                                ,p_txn_burdened_cost            => l_txn_burdened_cost_tab(i)
                                ,p_txn_revenue                  => l_txn_revenue_tab(i)
                                ,p_project_currency_code        => l_project_curr_code_tab(i)
                                ,p_project_raw_cost             => l_project_raw_cost_tab(i)
                                ,p_project_burdened_cost        => l_project_burdened_cost_tab(i)
                                ,p_project_revenue              => l_project_revenue_tab(i)
                                ,p_projfunc_currency_code       => l_projfunc_curr_code_tab(i)
                                ,p_projfunc_raw_cost            => l_projfunc_raw_cost_tab(i)
                                ,p_projfunc_burdened_cost       => l_projfunc_burdened_cost_tab(i)
                                ,p_projfunc_revenue             => l_projfunc_revenue_tab(i)
				,p_rep_line_mode               => 'POSITIVE_ENTRY'
                                ,x_msg_data                     => x_msg_data
                                ,x_return_status                => l_return_status
                                );
                             /* bug fix:5031388END If;*/
                           END LOOP;
                           --print_msg('After calling Add_Toreporting_Tabls Api retSts['||l_return_status||']');
                           If l_return_status <> 'S' Then
                                RAISE PJI_EXCEPTION;
                           END IF;
            END IF; --}
                     End If;
          End If;
        End If;
    END IF; --}

        IF l_return_status <> 'S' Then
                IF x_msg_data IS NOT NULL THEN
                        add_msgto_stack
                        ( p_msg_name       => x_msg_data
                        ,p_token1         => 'PROJECT'
                        ,p_value1         => g_project_name
                        ,p_token2         => 'TASK'
                        ,p_value2         => g_task_name
                        ,p_token3         => 'RESOURCE_NAME'
                        ,p_value3         => g_resource_name
                        ,p_token4         => 'START_DATE'
                        ,p_value4         => p_line_start_date);
                End IF;

        END IF;
    x_return_status := l_return_status ;
    IF p_pa_debug_mode = 'Y' Then
        	print_msg('x_return_status : '||x_return_status);
        	print_msg('Leaving delete_budget_lines');
            	pa_debug.reset_err_stack;
    End If;

  EXCEPTION
    WHEN PJI_EXCEPTION THEN
        x_return_status := 'E';
        x_msg_count := 1;
        IF x_msg_data IS NOT NULL THEN
                        add_msgto_stack
                        ( p_msg_name       => x_msg_data
                        ,p_token1         => 'PROJECT'
                        ,p_value1         => g_project_name
                        ,p_token2         => 'TASK'
                        ,p_value2         => g_task_name
                        ,p_token3         => 'RESOURCE_NAME'
                        ,p_value3         => g_resource_name
                        ,p_token4         => 'START_DATE'
                        ,p_value4         => p_line_start_date);
                End IF;
        IF p_pa_debug_mode = 'Y' Then
            pa_debug.reset_err_stack;
        End If;
        RAISE;

    WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := 'Stage['||l_stage||SQLCODE||SQLERRM;
            fnd_msg_pub.add_exc_msg
            ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                ,p_procedure_name => 'delete_budget_lines' );
        IF p_pa_debug_mode = 'Y' Then
                pa_debug.reset_err_stack;
        End If;
            RAISE;
END delete_budget_lines;


/*
-- PROCEDURE chk_req_rate_api_inputs checks for required parameters before
-- Calling Rate API
-- p_resource_class, p_item_date, and p_uom should be passed as these are mandatory parameters always.
-- IF p_rate_based_flag ='Y' THEN  p_quantity should not be NULL.
-- IF any Override is entered i.e
-- IF p_cost_override_rate ,p_revenue_override_rate, p_raw_cost, p_burden_cost,
--   p_raw_revenue is passed then  must pass p_override_currency_code
*/

PROCEDURE chk_req_rate_api_inputs
    (  p_budget_version_id             IN pa_budget_versions.budget_version_id%TYPE
          ,p_budget_version_type           IN pa_budget_versions.version_type%TYPE
          ,p_person_id                     IN pa_resource_assignments.person_id%TYPE
          ,p_job_id                        IN pa_resource_assignments.job_id%TYPE
          ,p_resource_class                IN pa_resource_assignments.resource_class_code%TYPE
          ,p_rate_based_flag               IN pa_resource_assignments.rate_based_flag%TYPE
          ,p_uom                           IN pa_resource_assignments.unit_of_measure%TYPE
          ,p_quantity                      IN pa_budget_lines.quantity%TYPE
          ,p_item_date                     IN pa_budget_lines.start_date%TYPE
          ,p_non_labor_resource            IN pa_resource_assignments.non_labor_resource%TYPE
          ,p_expenditure_org_id            IN pa_resource_assignments.rate_expenditure_org_id%TYPE
          ,p_nlr_organization_id           IN pa_resource_assignments.organization_id%TYPE
          ,p_cost_override_rate            IN pa_fp_res_assignments_tmp.rw_cost_rate_override%TYPE
          ,p_revenue_override_rate         IN pa_fp_res_assignments_tmp.bill_rate_override%TYPE
          ,p_raw_cost                      IN pa_fp_res_assignments_tmp.txn_raw_cost%TYPE
          ,p_burden_cost                   IN pa_fp_res_assignments_tmp.txn_burdened_cost%TYPE
          ,p_raw_revenue                   IN pa_fp_res_assignments_tmp.txn_revenue%TYPE
          ,p_override_currency_code        IN pa_fp_res_assignments_tmp.txn_currency_code%TYPE
          ,x_return_status                 OUT NOCOPY VARCHAR2
          ,x_msg_count                     OUT NOCOPY NUMBER
          ,x_msg_data                      OUT NOCOPY VARCHAR2
          ) IS

    l_debug_mode               VARCHAR2(30);
    l_stage                    NUMBER;
    l_count                    NUMBER;
    l_msg_index_out            NUMBER;
    l_return_status            VARCHAR2(30);
    l_error_msg_code           Varchar2(100);
BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := 'S';
    IF p_pa_debug_mode = 'Y' Then
            pa_debug.init_err_stack('PA_FP_CALC_PLAN_PKG.chk_req_rate_api_inputs');
    End If;

    g_stage := 'chk_req_rate_api_inputs:100';
        l_stage := 8010;

        IF l_return_status = 'S' AND p_resource_class IS NULL THEN
        l_error_msg_code := 'PA_FP_RES_CLS_REQ_RATE_API';
                l_return_status := 'E';
        ELSIF p_item_date IS NULL THEN
                l_error_msg_code :=  'PA_FP_ITEM_DT_REQ_RATE_API';
                l_return_status := 'E';
        ELSIF p_uom IS NULL THEN
                l_error_msg_code := 'PA_FP_UOM_REQ_RATE_API';
                l_return_status := 'E';
        END IF;


        IF l_return_status = 'S' AND p_rate_based_flag ='Y' THEN
            IF p_budget_version_type = 'COST' THEN
                IF p_quantity IS NULL AND
                   p_raw_cost IS NULL AND
                   p_burden_cost IS NULL  THEN
                        l_error_msg_code := 'PA_FP_QTY_REQ_RATE_API';
                l_return_status := 'E';

                END IF;
            ELSIF p_budget_version_type = 'REVENUE' THEN
                IF p_quantity IS NULL AND
                   p_raw_revenue IS NULL THEN
                        l_error_msg_code := 'PA_FP_QTY_REV_REQ_RATE_API';
                                l_return_status := 'E';
            End IF;
            ELSIF p_budget_version_type = 'ALL' THEN
                IF p_quantity IS NULL AND
                   p_raw_revenue IS NULL AND
                   p_raw_cost IS NULL AND
                   p_burden_cost IS NULL  THEN
                        l_error_msg_code := 'PA_FP_QTY_ALL_REQ_RATE_API';
                l_return_status := 'E';
            End If;
        END IF;
    END IF;

    IF l_return_status <> 'S' Then
         If l_error_msg_code is NOT NULL Then
        ADD_MSGTO_STACK(
          p_msg_name       => l_error_msg_code
                  ,p_token1         => 'PROJECT'
                  ,p_value1         => g_project_name
                  ,p_token2         => 'TASK'
                  ,p_value2         => g_task_name
                  ,p_token3         => 'RESOURCE_NAME'
                  ,p_value3         => g_resource_name);
         End If;
        END IF;
    g_stage := 'chk_req_rate_api_inputs:101';
    x_return_status := l_return_status;
    IF p_pa_debug_mode = 'Y' Then
            pa_debug.reset_err_stack;
    End If;

EXCEPTION
    WHEN OTHERS THEN

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            fnd_msg_pub.add_exc_msg
            ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                ,p_procedure_name => 'chk_req_rate_api_inputs' );
        IF p_pa_debug_mode = 'Y' Then
                pa_debug.reset_err_stack;
        End If;
            RAISE;

END chk_req_rate_api_inputs;

/*
*This API populates the rollup temp when spread is not required. If spread is called spread API() populates
*the rollup temp table.
*/
PROCEDURE populate_rollup_tmp
    ( p_budget_version_id              IN  NUMBER
          ,x_return_status                 OUT NOCOPY VARCHAR2
          ,x_msg_count                     OUT NOCOPY NUMBER
          ,x_msg_data                      OUT NOCOPY VARCHAR2) IS

    l_debug_mode        VARCHAR2(30);
    l_stage             NUMBER;
    l_count             NUMBER;
    l_msg_index_out     NUMBER;
BEGIN

        x_return_status := 'S';
        l_stage := 2000;
    g_stage := 'populate_rollup_tmp:100';
    IF p_pa_debug_mode = 'Y' Then
            pa_debug.init_err_stack('PA_FP_CALC_PLAN_PKG.populate_rollup_tmp');
        	print_msg(to_char(l_stage)||'Entered PA_FP_CALC_PLAN_PKG.populate_rollup_tmp');
    End If;
	/*
    If P_PA_DEBUG_MODE = 'Y' Then
      for i in (select * from pa_fp_spread_calc_tmp ) LOOP
       print_msg('IN params ResId['||i.resource_assignment_id||']TxnCur['||i.txn_currency_code||']RefrFlag['||i.refresh_rates_flag||']');
       print_msg('RefrConvFlag['||i.refresh_conv_rates_flag||']gSprdFromDt['||g_spread_from_date||']gLnSD['||i.start_date||']');
       print_msg('gLineEnDate['||i.end_date||']massAdflag['||i.mass_adjust_flag||']mfcCstFlag['||i.mfc_cost_refresh_flag||']skipFlag['||i.skip_record_flag||']');
      end loop;
    END IF;
	*/

       INSERT INTO pa_fp_rollup_tmp (
    budget_version_id
        ,resource_assignment_id
       ,start_date
       ,end_date
       ,period_name
       ,quantity
       ,projfunc_raw_cost
       ,projfunc_burdened_cost
       ,projfunc_revenue
       ,cost_rejection_code
       ,revenue_rejection_code
       ,burden_rejection_code
       ,projfunc_currency_code
       ,projfunc_cost_rate_type
       ,projfunc_cost_exchange_rate
       ,projfunc_cost_rate_date_type
       ,projfunc_cost_rate_date
       ,projfunc_rev_rate_type
       ,projfunc_rev_exchange_rate
       ,projfunc_rev_rate_date_type
       ,projfunc_rev_rate_date
       ,project_currency_code
       ,project_cost_rate_type
       ,project_cost_exchange_rate
       ,project_cost_rate_date_type
       ,project_cost_rate_date
       ,project_raw_cost
       ,project_burdened_cost
       ,project_rev_rate_type
       ,project_rev_exchange_rate
       ,project_rev_rate_date_type
       ,project_rev_rate_date
       ,project_revenue
       ,txn_currency_code
       ,txn_raw_cost
       ,txn_burdened_cost
       ,txn_revenue
       ,budget_line_id
       ,init_quantity
       ,txn_init_raw_cost
       ,txn_init_burdened_cost
       ,txn_init_revenue
       ,bill_markup_percentage
       ,bill_rate
       ,cost_rate
       ,rw_cost_rate_override
       ,burden_cost_rate
       ,bill_rate_override
       ,burden_cost_rate_override
       ,cost_ind_compiled_set_id
       ,init_raw_cost
       ,init_burdened_cost
       ,init_revenue
       ,project_init_raw_cost
       ,project_init_burdened_cost
       ,project_init_revenue
       ,billable_flag
       ,rate_based_flag
       ,system_reference4  -- version all revenue only entered
       )
       ( SELECT /*+ INDEX(BL PA_BUDGET_LINES_U1) */
    bl.budget_version_id
        ,bl.resource_assignment_id
       ,bl.start_date
       ,bl.end_date
       ,bl.period_name
       ,bl.quantity
        /* Bug Fix 4332086
           When ever currency is overridden in the workplan flow the exchange rates of old currency
           are used to derive the PFC amounts.
           This is happening due to the following piece of code.
           In the following code we are storing the pa_budget_lines attributes in pa_fp_rollup_tmp
           and then we are using the same in the later part of the code.
           This is resulting in the bug.

           As a fix now we added another decode condition to see if the currency is iverridden.
           If it is then we nullify all the currency related attributes, so they can be retrieved
           for the latest currency instead of caching the old currency's attrs.
        */
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(ra.rate_based_flag,'N',bl.raw_cost
        ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.raw_cost,NULL)
                ,'C',decode(bl.quantity,null,bl.raw_cost,NULL)
                ,'R',bl.raw_cost
                    ,bl.raw_cost
            )
          ),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(ra.rate_based_flag,'N',bl.burdened_cost
        ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.burdened_cost,NULL)
            ,'C',decode(bl.quantity,null,bl.burdened_cost,NULL)
            ,'R',bl.burdened_cost
            ,bl.burdened_cost
            )
          ),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(ra.rate_based_flag,'N',bl.revenue
        ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.revenue,NULL)
                ,'C',bl.revenue
                ,'R',decode(bl.quantity,null,bl.revenue,NULL)
                ,bl.revenue
            )
          ),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_rates_flag,'Y' ,decode(bl.quantity,null,bl.cost_rejection_code,NULL)
            ,'C',decode(bl.quantity,null,bl.cost_rejection_code,NULL)
            ,'R',bl.cost_rejection_code
        ,bl.cost_rejection_code
          ),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.revenue_rejection_code,NULL)
            ,'C',bl.revenue_rejection_code
            ,'R',decode(bl.quantity,null,bl.revenue_rejection_code,NULL)
        ,bl.revenue_rejection_code
          ),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_rates_flag,'Y' ,decode(bl.quantity,null,bl.burden_rejection_code,NULL)
            ,'C',decode(bl.quantity,null,bl.burden_rejection_code,NULL)
            ,'R',bl.burden_rejection_code
        ,bl.burden_rejection_code
          ),NULL)
       ,bl.projfunc_currency_code
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_conv_rates_flag,'Y'
        ,decode(g_source_context,'BUDGET_LINE',bl.projfunc_cost_rate_type,NULL),bl.projfunc_cost_rate_type),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_conv_rates_flag,'Y'
        ,decode(g_source_context,'BUDGET_LINE',bl.projfunc_cost_exchange_rate,NULL),bl.projfunc_cost_exchange_rate),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_conv_rates_flag,'Y'
        ,decode(g_source_context,'BUDGET_LINE',bl.projfunc_cost_rate_date_type,NULL),bl.projfunc_cost_rate_date_type),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_conv_rates_flag,'Y'
        ,decode(g_source_context,'BUDGET_LINE',bl.projfunc_cost_rate_date,NULL),bl.projfunc_cost_rate_date),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_conv_rates_flag,'Y'
        ,decode(g_source_context,'BUDGET_LINE',bl.projfunc_rev_rate_type,NULL),bl.projfunc_rev_rate_type),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_conv_rates_flag,'Y'
        ,decode(g_source_context,'BUDGET_LINE',bl.projfunc_rev_exchange_rate,NULL),bl.projfunc_rev_exchange_rate),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_conv_rates_flag,'Y'
        ,decode(g_source_context,'BUDGET_LINE',bl.projfunc_rev_rate_date_type,NULL),bl.projfunc_rev_rate_date_type),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_conv_rates_flag,'Y'
        ,decode(g_source_context,'BUDGET_LINE',bl.projfunc_rev_rate_date,NULL),bl.projfunc_rev_rate_date),NULL)
       ,bl.project_currency_code
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_conv_rates_flag,'Y'
        ,decode(g_source_context,'BUDGET_LINE',bl.project_cost_rate_type,NULL),bl.project_cost_rate_type),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_conv_rates_flag,'Y'
        ,decode(g_source_context,'BUDGET_LINE',bl.project_cost_exchange_rate,NULL),bl.project_cost_exchange_rate),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_conv_rates_flag,'Y'
        ,decode(g_source_context,'BUDGET_LINE',bl.project_cost_rate_date_type,NULL),bl.project_cost_rate_date_type),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_conv_rates_flag,'Y'
        ,decode(g_source_context,'BUDGET_LINE',bl.project_cost_rate_date,NULL),bl.project_cost_rate_date),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(ra.rate_based_flag,'N',bl.project_raw_cost
        ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.project_raw_cost,NULL)
                ,'C',decode(bl.quantity,null,bl.project_raw_cost,NULL)
                ,'R',bl.project_raw_cost
            ,bl.project_raw_cost
            )
            ),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(ra.rate_based_flag,'N',bl.project_burdened_cost
        ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.project_burdened_cost,NULL)
                ,'C',decode(bl.quantity,null,bl.project_burdened_cost,NULL)
                ,'R',bl.project_burdened_cost
            ,bl.project_burdened_cost
            )
            ),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_conv_rates_flag,'Y'
        ,decode(g_source_context,'BUDGET_LINE',bl.project_rev_rate_type,NULL),bl.project_rev_rate_type),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_conv_rates_flag,'Y'
        ,decode(g_source_context,'BUDGET_LINE',bl.project_rev_exchange_rate,NULL),bl.project_rev_exchange_rate),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_conv_rates_flag,'Y'
        ,decode(g_source_context,'BUDGET_LINE',bl.project_rev_rate_date_type,NULL),bl.project_rev_rate_date_type),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_conv_rates_flag,'Y'
        ,decode(g_source_context,'BUDGET_LINE',bl.project_rev_rate_date,NULL),bl.project_rev_rate_date),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(ra.rate_based_flag,'N',bl.project_revenue
        ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.project_revenue,NULL)
                ,'C',bl.project_revenue
                ,'R',decode(bl.quantity,null,bl.project_revenue,NULL)
            ,bl.project_revenue
               )
          ),NULL)
       ,bl.txn_currency_code
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(ra.rate_based_flag,'N',bl.txn_raw_cost
        ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.txn_raw_cost,NULL)
                ,'C',decode(bl.quantity,null,bl.txn_raw_cost,NULL)
                ,'R',bl.txn_raw_cost
            ,bl.txn_raw_cost
            )
        ),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(ra.rate_based_flag,'N',bl.txn_burdened_cost
        ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.txn_burdened_cost,NULL)
                ,'C',decode(bl.quantity,null,bl.txn_burdened_cost,NULL)
                ,'R',bl.txn_burdened_cost
            ,bl.txn_burdened_cost
            )
        ),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(ra.rate_based_flag,'N',bl.txn_revenue
        ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.txn_revenue,NULL)
                ,'C',bl.txn_revenue
                ,'R',decode(bl.quantity,null,bl.txn_revenue,NULL)
            ,bl.txn_revenue
               )
        ),NULL)
       ,bl.budget_line_id
       ,bl.init_quantity
       ,bl.txn_init_raw_cost
       ,bl.txn_init_burdened_cost
       ,bl.txn_init_revenue
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(NVL(tmp.billable_flag,'N'),'N',bl.txn_markup_percent /* Added for billablity enhancements */
       ,decode(tmp.refresh_rates_flag,'Y'
                /*Bug fix: 4294287 Starts ,decode(bl.quantity,null,bl.txn_markup_percent,NULL) */
                 ,decode(g_fp_budget_version_type ,'REVENUE'
                                    ,decode(NVL(bl.txn_markup_percent,0),0,decode(bl.quantity,null,bl.txn_markup_percent,NULL)
                       ,bl.txn_markup_percent),decode(bl.quantity,null,bl.txn_markup_percent,NULL))
                /* Bug fix: 4294287 ends */
            ,'C',bl.txn_markup_percent
            ,'R'/*Bug fix: 4294287 Starts ,decode(bl.quantity,null,bl.txn_markup_percent,NULL) */
                 ,decode(g_fp_budget_version_type ,'REVENUE'
                                    ,decode(NVL(bl.txn_markup_percent,0),0,decode(bl.quantity,null,bl.txn_markup_percent,NULL)
                                      ,bl.txn_markup_percent),decode(bl.quantity,null,bl.txn_markup_percent,NULL))
                              /* Bug fix: 4294287 ends */
            ,bl.txn_markup_percent
        )),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(ra.rate_based_flag,'N',bl.txn_standard_bill_rate
        ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.txn_standard_bill_rate,NULL)
                ,'C',bl.txn_standard_bill_rate
                ,'R',decode(bl.quantity,null,bl.txn_standard_bill_rate,NULL)
                ,bl.txn_standard_bill_rate
            )
        ),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(ra.rate_based_flag,'N',bl.txn_standard_cost_rate
        ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.txn_standard_cost_rate,NULL)
                ,'C',decode(bl.quantity,null,bl.txn_standard_cost_rate,NULL)
                ,'R',bl.txn_standard_cost_rate
                ,bl.txn_standard_cost_rate
            )
        ),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(ra.rate_based_flag,'N',bl.txn_cost_rate_override
        ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.txn_cost_rate_override,NULL)
                ,'C',decode(bl.quantity,null,bl.txn_cost_rate_override,NULL)
                ,'R',bl.txn_cost_rate_override
                ,bl.txn_cost_rate_override
            )
        ),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(ra.rate_based_flag,'N',bl.burden_cost_rate
        ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.burden_cost_rate,NULL)
                ,'C',decode(bl.quantity,null,bl.burden_cost_rate,NULL)
                ,'R',bl.burden_cost_rate
                ,bl.burden_cost_rate
            )
        ),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(NVL(tmp.billable_flag,'N'),'N',bl.txn_bill_rate_override /* Added for billablity enhancements */
     	  ,decode(ra.rate_based_flag,'N',
               /*Bug:5056986 */
                decode(g_fp_budget_version_type,'ALL'
                	,decode(tmp.refresh_rates_flag,'Y',decode(bl.txn_cost_rate_override,0,bl.txn_bill_rate_override,NULL)
					,'R',decode(bl.txn_cost_rate_override,0,bl.txn_bill_rate_override,NULL)
					, bl.txn_bill_rate_override),bl.txn_bill_rate_override)
           ,decode(tmp.refresh_rates_flag,'Y' /*Bug fix: 4294287 Starts decode(bl.quantity,null,bl.txn_bill_rate_override,NULL)*/
                    ,decode(g_fp_budget_version_type ,'REVENUE'
                        ,decode(NVL(bl.txn_markup_percent,0),0,decode(bl.quantity,null,bl.txn_bill_rate_override,NULL)
                          ,bl.txn_bill_rate_override),decode(bl.quantity,null,bl.txn_bill_rate_override,NULL))
                        /*end bug fix:4294287*/
                ,'C',bl.txn_bill_rate_override
                ,'R' /*Bug fix: 4294287 Starts,decode(bl.quantity,null,bl.txn_bill_rate_override,NULL) */
                    ,decode(g_fp_budget_version_type ,'REVENUE'
                                                ,decode(NVL(bl.txn_markup_percent,0),0,decode(bl.quantity,null,bl.txn_bill_rate_override,NULL)
                                                  ,bl.txn_bill_rate_override),decode(bl.quantity,null,bl.txn_bill_rate_override,NULL))
                     /*end bug fix:4294287*/
                ,bl.txn_bill_rate_override
            )
        )),NULL)
        /** Bug fix:4119950 reverted back the changes made for if raw cost = burden cost then retain burden overrides
     --for non-rate base, if raw cost = burden cost then retain the burden overrides

       ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.burden_cost_rate_override
               ,decode(ra.rate_based_flag,'Y',NULL,decode(bl.txn_raw_cost,bl.txn_burdened_cost,bl.burden_cost_rate_override,NULL)))
        ,'C',decode(bl.quantity,null,bl.burden_cost_rate_override
                       ,decode(ra.rate_based_flag,'Y',NULL,decode(bl.txn_raw_cost,bl.txn_burdened_cost,bl.burden_cost_rate_override,NULL)))
        ,'R',bl.burden_cost_rate_override
        ,bl.burden_cost_rate_override
          )
       ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.cost_ind_compiled_set_id
            ,decode(ra.rate_based_flag,'Y',NULL,decode(bl.txn_raw_cost,bl.txn_burdened_cost,bl.cost_ind_compiled_set_id,NULL)))
         ,'C',decode(bl.quantity,null,bl.cost_ind_compiled_set_id
                        ,decode(ra.rate_based_flag,'Y',NULL,decode(bl.txn_raw_cost,bl.txn_burdened_cost,bl.cost_ind_compiled_set_id,NULL)))
         ,'R',bl.cost_ind_compiled_set_id
         ,bl.cost_ind_compiled_set_id
        )
    **/
    /* Added this for Bug fix:4119950 Refresh burden rate override always
    Note: If user enters a burden cost only, then on refresh user entered burden cost will be lost.  This is acceptable
    as compared to bug 4119950 not refreshing the burden cost at all
    */
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.burden_cost_rate_override,NULL)
                ,'C',decode(bl.quantity,null,bl.burden_cost_rate_override,NULL)
                ,'R',bl.burden_cost_rate_override
                ,bl.burden_cost_rate_override
              ),NULL)
       ,DECODE(tmp.TXN_CURR_CODE_OVERRIDE,NULL
       ,decode(tmp.refresh_rates_flag,'Y',decode(bl.quantity,null,bl.cost_ind_compiled_set_id,NULL)
                 ,'C',decode(bl.quantity,null,bl.cost_ind_compiled_set_id,NULL)
                 ,'R',bl.cost_ind_compiled_set_id
                 ,bl.cost_ind_compiled_set_id
                ),NULL)
       ,bl.init_raw_cost
       ,bl.init_burdened_cost
       ,bl.init_revenue
       ,bl.project_init_raw_cost
       ,bl.project_init_burdened_cost
       ,bl.project_init_revenue
       ,tmp.billable_flag
    /* bug fix:4657962 */
    ,NVL(ra.rate_based_flag,'N')
	,decode(g_mass_adjust_flag,'N','N'
		,decode(NVL(g_wp_version_flag,'N'),'Y','N'
		     ,decode(nvl(ra.rate_based_flag,'N'),'Y','N'
			 ,'N',decode(bl.txn_cost_rate_override,0,'Y','N'))))
       FROM pa_budget_lines bl
           ,pa_resource_assignments ra
       ,pa_fp_spread_calc_tmp tmp
       WHERE tmp.budget_version_id = p_budget_version_id
    AND (NVL(tmp.refresh_rates_flag,'N') in ('Y','R','C')
        OR NVL(tmp.refresh_conv_rates_flag,'N') = 'Y'
        OR NVL(tmp.mass_adjust_flag,'N') = 'Y'
        OR NVL(tmp.mfc_cost_refresh_flag,'N') = 'Y'
        OR NVL(tmp.ra_rates_only_change_flag,'N') = 'Y'
        OR NVL(tmp.system_reference_var2,'N') = 'Y'  /* Bug fix:4295967 to populate rollupt tmp in apply progress mode*/
       )
    AND NVL(tmp.skip_record_flag,'N') <> 'Y'
    AND tmp.resource_assignment_id = ra.resource_assignment_id
        AND bl.resource_assignment_id = ra.resource_assignment_id
        AND bl.txn_currency_code      = tmp.txn_currency_code
        AND ((g_spread_from_date IS NULL)
           OR (g_spread_from_date IS NOT NULL
                   AND ((bl.start_date > g_spread_from_date )
                        OR (g_spread_from_date between bl.start_date and bl.end_date)
                       )
              )
        )
        AND ( (g_source_context <> 'BUDGET_LINE' )
        OR
        (g_source_context = 'BUDGET_LINE'
         AND tmp.start_date IS NOT NULL AND tmp.end_date IS NOT NULL
                 AND bl.start_date BETWEEN tmp.start_date AND tmp.end_date
            )
         )
    );
    g_stage := 'populate_rollup_tmp:101: Number of rows Inserted['||sql%rowcount||']';
    /* Now update rollup tmp override with any override rates passed along with currency code overrides */
    IF (NVL(g_refresh_rates_flag,'N') = 'N'
        AND NVL(g_mass_adjust_flag,'N') = 'N'
        AND NVL(g_refresh_conv_rates_flag,'N') = 'N'
        AND g_applyProg_RaId_tab.COUNT = 0 ) Then
       g_stage := 'populate_rollup_tmp:102';
       UPDATE /*+ INDEX(TMP PA_FP_ROLLUP_TMP_N1) */ pa_fp_rollup_tmp tmp
       SET (tmp.rw_cost_rate_override
        ,tmp.burden_cost_rate_override
        ,tmp.bill_rate_override) =
        (SELECT  decode(caltmp.txn_curr_code_override,NULL,decode(caltmp.mfc_cost_change_flag,'Y',caltmp.cost_rate_override
                        ,tmp.rw_cost_rate_override),caltmp.cost_rate_override)
            ,decode(caltmp.txn_curr_code_override,NULL,decode(caltmp.mfc_cost_change_flag,'Y',caltmp.burden_cost_rate_override
                        ,tmp.burden_cost_rate_override),caltmp.burden_cost_rate_override)
            ,decode(caltmp.txn_curr_code_override,NULL,decode(caltmp.mfc_cost_change_flag,'Y',caltmp.bill_rate_override
                        ,tmp.bill_rate_override),caltmp.bill_rate_override)
        FROM pa_fp_spread_calc_tmp caltmp
        WHERE caltmp.budget_version_id = tmp.budget_version_id
        AND   caltmp.resource_assignment_id = tmp.resource_assignment_id
        AND   caltmp.txn_currency_code = tmp.txn_currency_code
        AND   NVL(caltmp.skip_record_flag,'N') <> 'Y'
        AND  (NVL(g_refresh_rates_flag,'N') = 'N'
                    AND NVL(caltmp.refresh_conv_rates_flag,'N') = 'N'
                    AND NVL(caltmp.mass_adjust_flag,'N') = 'N'
                    AND NVL(caltmp.mfc_cost_refresh_flag,'N') = 'Y'
                 ))
       WHERE tmp.budget_version_id = p_budget_version_id
       AND EXISTS ( select null
            FROM pa_fp_spread_calc_tmp caltmp
                    WHERE caltmp.budget_version_id = tmp.budget_version_id
                    AND   caltmp.resource_assignment_id = tmp.resource_assignment_id
                    AND   caltmp.txn_currency_code = tmp.txn_currency_code
                    AND   NVL(caltmp.skip_record_flag,'N') <> 'Y'
                    AND  (NVL(g_refresh_rates_flag,'N') = 'N'
                            AND NVL(caltmp.refresh_conv_rates_flag,'N') = 'N'
                            AND NVL(caltmp.mass_adjust_flag,'N') = 'N'
                            AND NVL(caltmp.mfc_cost_refresh_flag,'N') = 'Y'
                        ));
	If p_pa_debug_mode = 'Y' Then
        print_msg('Updating rollup tmp with rate overrides for mfc cost refresh['||sql%rowcount||']');
	End If;

    END IF;

    /* If only rates are changed then update the changed override rates on rollup tmp and avoid calling spread
     * and call rate api
     */
    IF g_rtChanged_RaId_tab.COUNT > 0 Then
        g_stage := 'populate_rollup_tmp:103';
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Updating rollup with rate overrides ');
	End If;
        FORALL i IN g_rtChanged_RaId_tab.FIRST .. g_rtChanged_RaId_tab.LAST
        UPDATE /*+ INDEX(TMP PA_FP_ROLLUP_TMP_N1) */ pa_fp_rollup_tmp tmp
        SET (tmp.rw_cost_rate_override
	    ,tmp.burden_cost_rate_override
	    ,tmp.bill_rate_override ) =
		  (SELECT   decode(NVL(g_rtChanged_cstMisNumFlg_tab(i),'N'),'Y',NULL
                            ,NVL(g_rtChanged_CostRt_Tab(i),tmp.rw_cost_rate_override))
                    ,decode(NVL(g_rtChanged_bdMisNumFlag_tab(i),'N'),'Y',NULL
                            ,decode(tmp.rate_based_flag,'Y',NVL(g_rtChanged_BurdRt_tab(i),tmp.burden_cost_rate_override)
			      ,decode(g_fp_budget_version_type,'ALL'
				,decode(caltmp.burden_cost_changed_flag,'Y',NVL(g_rtChanged_BurdRt_tab(i),tmp.burden_cost_rate_override)
				   ,decode(caltmp.raw_cost_changed_flag,'Y'
					,decode(tmp.rw_cost_rate_override,NULL,tmp.burden_cost_rate_override
					  ,0,NVL(g_rtChanged_BurdRt_tab(i),tmp.burden_cost_rate_override), tmp.burden_cost_rate_override)
						,NVL(g_rtChanged_BurdRt_tab(i),tmp.burden_cost_rate_override)))
				 ,NVL(g_rtChanged_BurdRt_tab(i),tmp.burden_cost_rate_override))))
                    ,decode(NVL(g_rtChanged_blMisNumFlag_tab(i),'N'),'Y',NULL
                            ,NVL(g_rtChanged_billRt_tab(i),tmp.bill_rate_override))
		  FROM pa_fp_spread_calc_tmp caltmp
		  WHERE caltmp.resource_assignment_id = tmp.resource_assignment_id
		  AND   caltmp.txn_currency_code = tmp.txn_currency_code
		  AND   ((g_source_context <> 'BUDGET_LINE')
              		OR
            		 ((g_source_context = 'BUDGET_LINE')
             		  and tmp.start_date BETWEEN caltmp.start_date and caltmp.end_date)
			)
		)
        WHERE tmp.budget_version_id = p_budget_version_id
        AND   tmp.resource_assignment_id = g_rtChanged_RaId_tab(i)
        AND   tmp.txn_currency_code = g_rtChanged_TxnCur_tab(i)
        AND   ((g_source_context <> 'BUDGET_LINE')
              OR
            ((g_source_context = 'BUDGET_LINE')
             and tmp.start_date IS NOT NULL
             and tmp.start_date BETWEEN g_rtChanged_sDate_tab(i) AND g_rtChanged_eDate_tab(i)
            )
              );
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Number of rows updated for RateChanges['||sql%rowcount||']');
	End If;
    END IF;

	/**
    If P_PA_DEBUG_MODE = 'Y' Then
            l_stage := 2019;
            SELECT count(*)
            INTO l_count
            FROM pa_fp_rollup_tmp ;
        	g_stage := 'populate_rollup_tmp:104';
            print_msg('Num of rows inserted into rollup Temp['||l_count||']');
	print_rlTmp_Values;
    End If;
	**/
      x_return_status := 'S';
    IF p_pa_debug_mode = 'Y' Then
      	print_msg('x_return_status : '||x_return_status);
      	print_msg('Leaving populate_rollup_tmp');
       	pa_debug.reset_err_stack;
    End If;
EXCEPTION
    WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data := sqlcode||sqlerrm;
            fnd_msg_pub.add_exc_msg
            ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                ,p_procedure_name => 'populate_rollup_tmp' );
            l_stage := 2120;
            print_msg(to_char(l_stage)||' substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
        IF p_pa_debug_mode = 'Y' Then
                pa_debug.reset_err_stack;
        End If;
            RAISE;

END populate_rollup_tmp;

/* bug fix:4657962 : This API is created to improve the mass adjust performance and rounding issues encountered during the
 * multiple assignment mass adjust of quantities
 * IPM changes: This api is modified for adjustment of rawcost, burdened cost and revenue in addition
 * to quantity and rates.
 * Rate-Base Resource: quantity, rates and amounts can be adjusted. adjusting amounts derives override rates
 * Non-Rate base resource: Only amounts can be adjusted.
 */

PROCEDURE mass_adjust_new
    ( p_budget_version_id             IN  NUMBER
         ,p_quantity_adj_pct          IN  NUMBER   := NULL
         ,p_cost_rate_adj_pct         IN  NUMBER   := NULL
         ,p_burdened_rate_adj_pct     IN  NUMBER   := NULL
         ,p_bill_rate_adj_pct         IN  NUMBER   := NULL
	 ,p_raw_cost_adj_pct          IN  NUMBER   := NULL
         ,p_burden_cost_adj_pct       IN  NUMBER   := NULL
         ,p_revenue_adj_pct           IN  NUMBER   := NULL
         ,x_return_status             OUT NOCOPY VARCHAR2
         ,x_msg_count                 OUT NOCOPY VARCHAR2
         ,x_msg_data                  OUT NOCOPY VARCHAR2
         ) IS

    	l_quantity_adj_pct          NUMBER := p_quantity_adj_pct;
        l_cost_rate_adj_pct         NUMBER := p_cost_rate_adj_pct;
        l_burdened_rate_adj_pct     NUMBER := p_burdened_rate_adj_pct;
        l_bill_rate_adj_pct         NUMBER := p_bill_rate_adj_pct;
	l_raw_cost_adj_pct          NUMBER := p_raw_cost_adj_pct;
        l_burden_cost_adj_pct       NUMBER := p_burden_cost_adj_pct;
        l_revenue_adj_pct           NUMBER := p_revenue_adj_pct;

    	/* declare local plsqltabs for bulk processing */
        l_quantity_new_tab              pa_plsql_datatypes.NumTabTyp;
        l_quantity_old_tab              pa_plsql_datatypes.NumTabTyp;
        l_quantity_diff_tab             pa_plsql_datatypes.NumTabTyp;
    	l_raId_tab          		pa_plsql_datatypes.NumTabTyp;
    	l_blId_tab          		pa_plsql_datatypes.NumTabTyp;
    	l_txn_cur_tab           	pa_plsql_datatypes.Char30TabTyp;
    	l_sdate_tab         		pa_plsql_datatypes.DateTabTyp;
    	l_ratebase_tab          	pa_plsql_datatypes.Char10TabTyp;
	l_rawCost_new_tab              pa_plsql_datatypes.NumTabTyp;
        l_rawcost_old_tab              pa_plsql_datatypes.NumTabTyp;
        l_rawcost_diff_tab             pa_plsql_datatypes.NumTabTyp;
	l_revenue_new_tab              pa_plsql_datatypes.NumTabTyp;
        l_revenue_old_tab              pa_plsql_datatypes.NumTabTyp;
        l_revenue_diff_tab             pa_plsql_datatypes.NumTabTyp;

    	CURSOR cur_rndQty IS
        SELECT tmp.resource_assignment_id
            ,tmp.txn_currency_code
            ,max(tmp.start_date)
            ,MAX(tmp.budget_line_id)
            ,NVL(tmp.rate_based_flag,'N') rate_based_flag
            ,decode(g_wp_version_flag,'Y',(sum(nvl(tmp.old_quantity,0) - nvl(tmp.init_quantity,0)) * ((l_quantity_adj_pct + 100)/100))
		, decode(NVL(tmp.rate_based_flag,'N'),'N',0
			,((sum(nvl(tmp.old_quantity,0) - nvl(tmp.init_quantity,0)) * ((l_quantity_adj_pct + 100)/100))))) unRndOldQty
            ,decode(g_wp_version_flag,'Y',(sum(nvl(tmp.quantity,0) - nvl(tmp.init_quantity,0)))
		,decode(NVL(tmp.rate_based_flag,'N'),'N',0,(sum(nvl(tmp.quantity,0) - nvl(tmp.init_quantity,0))))) RndNewQty
            ,to_number(null) Quantity_diff
	    /* amount adjustments is allowed only for financial side */
	    ,decode(g_wp_version_flag,'Y',0
		,decode(NVL(tmp.rate_based_flag,'N'),'Y',0
		  ,((sum(nvl(tmp.old_txn_raw_cost,0) - nvl(tmp.txn_init_raw_cost,0)) * ((l_raw_cost_adj_pct + 100)/100))))) unRndRawCost
	    ,decode(g_wp_version_flag,'Y',0
                ,decode(NVL(tmp.rate_based_flag,'N'),'Y',0
                  ,(sum(nvl(tmp.txn_raw_cost,0) - nvl(tmp.txn_init_raw_cost,0))))) RndRawCost
            ,to_number(null) RawCostDiff
	    ,decode(g_wp_version_flag,'Y',0
                ,decode(NVL(tmp.rate_based_flag,'N'),'Y',0
		  ,((sum(nvl(tmp.old_txn_revenue,0) - nvl(tmp.txn_init_revenue,0)) * ((l_revenue_adj_pct + 100)/100))))) unRndrevenue
	    ,decode(g_wp_version_flag,'Y',0
                ,decode(NVL(tmp.rate_based_flag,'N'),'Y',0
                  ,(sum(nvl(tmp.txn_revenue,0) - nvl(tmp.txn_init_revenue,0))))) RndRevenue
            ,to_number(null) RevenueDiff
        FROM  pa_fp_rollup_tmp tmp
         ,pa_fp_spread_calc_tmp caltmp
        WHERE caltmp.budget_version_id = p_budget_version_id
        AND  caltmp.resource_assignment_id = tmp.resource_assignment_id
        AND  tmp.txn_currency_code      = caltmp.txn_currency_code
        AND  nvl(caltmp.skip_record_flag,'N') <> 'Y'
        AND  nvl(caltmp.mass_adjust_flag,'N') = 'Y'
        GROUP BY tmp.resource_assignment_id,tmp.txn_currency_code,tmp.rate_based_flag
        ORDER BY tmp.resource_assignment_id,tmp.txn_currency_code;

BEGIN

    	x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF p_pa_debug_mode = 'Y' Then
            pa_debug.init_err_stack('PA_FP_CALC_PLAN_PKG.mass_adjust');
        End If;
        g_stage := 'mass_adjust:100';
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('QtyAdjPct['||l_quantity_adj_pct||']RateAdjPct['||l_cost_rate_adj_pct||']RwCostPct['||l_raw_cost_adj_pct||']');
    	print_msg('BdRateAdPct['||l_burdened_rate_adj_pct||']BurdPct['||l_burden_cost_adj_pct||']');
        print_msg('BillRtAdjPct['||l_bill_rate_adj_pct||']RevPct['||l_revenue_adj_pct||']');
	End If;


        /* Bug fix:4171926 Restrict the adjustment percentage to 2 decimals */
        l_quantity_adj_pct       := Round(l_quantity_adj_pct,2);
        l_cost_rate_adj_pct      := Round(l_cost_rate_adj_pct,2);
        l_burdened_rate_adj_pct  := Round(l_burdened_rate_adj_pct,2);
        l_bill_rate_adj_pct      := Round(l_bill_rate_adj_pct,2);
	l_raw_cost_adj_pct 	 := Round(l_raw_cost_adj_pct,2);
        l_burden_cost_adj_pct    := Round(l_burden_cost_adj_pct,2);
        l_revenue_adj_pct	 := Round(l_revenue_adj_pct,2);

	If g_wp_version_flag = 'Y' Then  --{
        g_stage := 'mass_adjust:101';
     	UPDATE /*+ INDEX(TMP PA_FP_ROLLUP_TMP_N1) */ pa_fp_rollup_tmp tmp
     	SET    tmp.old_quantity = decode(l_quantity_adj_pct,NULL,to_number(NULL),tmp.quantity)
            ,tmp.quantity = decode(l_quantity_adj_pct,NULL,tmp.quantity
                   ,decode(NVL(tmp.rate_based_flag,'N'),'N'
                     ,(NVL(tmp.init_quantity,0)+ pa_currency.round_trans_currency_amt1 (
                    ((NVL(tmp.quantity,0) - nvl(tmp.init_quantity,0))
                         * ((l_quantity_adj_pct + 100)/100)),tmp.txn_currency_code))
                        ,(NVL(tmp.init_quantity,0)+ Round(((NVL(tmp.quantity,0) - nvl(tmp.init_quantity,0))
                       * ((l_quantity_adj_pct + 100)/100)),5)))
                    )
            ,tmp.rw_cost_rate_override =
                decode(NVL(tmp.rate_based_flag,'N'),'N',tmp.rw_cost_rate_override
                                   ,Decode(l_cost_rate_adj_pct,NULL,tmp.rw_cost_rate_override
                           ,(NVL(tmp.rw_cost_rate_override,tmp.cost_rate)
                            * ((l_cost_rate_adj_pct + 100)/100)))
                    )
            ,tmp.burden_cost_rate_override =
                Decode(l_burdened_rate_adj_pct,NULL
			,Decode(l_cost_rate_adj_pct,NULL,tmp.burden_cost_rate_override
                           ,Decode(tmp.burden_cost_rate_override,NULL,tmp.burden_cost_rate_override
                              ,decode(NVL(tmp.rw_cost_rate_override,nvl(tmp.cost_rate,0)),0,tmp.burden_cost_rate_override
                                    ,((tmp.burden_cost_rate_override / NVL(tmp.rw_cost_rate_override,tmp.cost_rate))
                                        * (NVL(tmp.rw_cost_rate_override,tmp.cost_rate)* ((l_cost_rate_adj_pct + 100)/100))))))
                        , (NVL(tmp.burden_cost_rate_override,tmp.burden_cost_rate)
                            * ((l_burdened_rate_adj_pct + 100)/100))
                        )
        WHERE tmp.budget_version_id = p_budget_version_id
    	AND  EXISTS ( select null
            from pa_fp_spread_calc_tmp caltmp
                WHERE  caltmp.resource_assignment_id = tmp.resource_assignment_id
                AND  caltmp.txn_currency_code      = tmp.txn_currency_code
                AND  nvl(caltmp.skip_record_flag,'N') <> 'Y'
                AND  nvl(caltmp.mass_adjust_flag,'N') = 'Y'
           );
        g_stage := 'mass_adjust:102: Number of rows Updated['||sql%rowcount||']';

	ELSE  -- for financial budgets / forecasts

	  IF l_quantity_adj_pct is NOT NULL
		OR l_cost_rate_adj_pct is NOT NULL
		or l_burdened_rate_adj_pct is NOT NULL
		or l_bill_rate_adj_pct is NOT NULL Then --{
           g_stage := 'mass_adjust:103';
           UPDATE /*+ INDEX(TMP PA_FP_ROLLUP_TMP_N1) */ pa_fp_rollup_tmp tmp
           SET    tmp.old_quantity = decode(NVL(tmp.rate_based_flag,'N'),'N',tmp.quantity
						,decode(l_quantity_adj_pct,NULL,to_number(NULL),tmp.quantity))
            ,tmp.quantity = decode(NVL(tmp.rate_based_flag,'N'),'N',tmp.quantity
				,decode(l_quantity_adj_pct,NULL,tmp.quantity
                   		  ,decode(NVL(tmp.rate_based_flag,'N'),'N'
                     		     ,(NVL(tmp.init_quantity,0)+ pa_currency.round_trans_currency_amt1 (
                    				((NVL(tmp.quantity,0) - nvl(tmp.init_quantity,0))
                         			* ((l_quantity_adj_pct + 100)/100)),tmp.txn_currency_code))
                        		,(NVL(tmp.init_quantity,0)+ Round(((NVL(tmp.quantity,0) - nvl(tmp.init_quantity,0))
                       				* ((l_quantity_adj_pct + 100)/100)),5)))
                    		 ))
            ,tmp.rw_cost_rate_override =
                decode(NVL(tmp.rate_based_flag,'N'),'N',tmp.rw_cost_rate_override
                                   ,Decode(l_cost_rate_adj_pct,NULL,tmp.rw_cost_rate_override
                           ,(NVL(tmp.rw_cost_rate_override,tmp.cost_rate)
                            * ((l_cost_rate_adj_pct + 100)/100)))
                    )
            ,tmp.burden_cost_rate_override =
                Decode(l_burdened_rate_adj_pct,NULL,decode(NVL(tmp.rate_based_flag,'N'),'N',tmp.burden_cost_rate_override
				,Decode(l_cost_rate_adj_pct,NULL,tmp.burden_cost_rate_override
				   ,Decode(tmp.burden_cost_rate_override,NULL,tmp.burden_cost_rate_override,1,NULL
					  ,decode(NVL(tmp.rw_cost_rate_override,nvl(tmp.cost_rate,0)),0,tmp.burden_cost_rate_override
					     ,((tmp.burden_cost_rate_override / NVL(tmp.rw_cost_rate_override,tmp.cost_rate))
						* (NVL(tmp.rw_cost_rate_override,tmp.cost_rate)* ((l_cost_rate_adj_pct + 100)/100)))))))
                                      , (NVL(tmp.burden_cost_rate_override,tmp.burden_cost_rate)
                        * ((l_burdened_rate_adj_pct + 100)/100))
                        )
            ,tmp.bill_rate_override  =
                DECODE(l_bill_rate_adj_pct ,NULL,decode(l_cost_rate_adj_pct,NULL,tmp.bill_rate_override
			,decode(g_fp_budget_version_type,'COST',tmp.bill_rate_override,'REVENUE',tmp.bill_rate_override
			     ,decode(NVL(tmp.rate_based_flag,'N'),'N',tmp.bill_rate_override
				,decode(NVL(tmp.rw_cost_rate_override,nvl(tmp.cost_rate,0)),0,tmp.bill_rate_override
				  ,decode(tmp.bill_rate_override,1,NULL,NULL,NULL
					,((tmp.bill_rate_override / NVL(tmp.rw_cost_rate_override,tmp.cost_rate))
					  * (NVL(tmp.rw_cost_rate_override,tmp.cost_rate)* ((l_cost_rate_adj_pct + 100)/100))))))))
                           ,Decode(g_fp_budget_version_type,'COST',tmp.bill_rate_override
                    ,'REVENUE',Decode(NVL(tmp.rate_based_flag,'N'),'N',tmp.bill_rate_override
                        ,Decode(NVL(tmp.billable_flag,'N'),'Y'
                          ,(NVL(tmp.bill_rate_override,tmp.bill_rate) *
                            ((l_bill_rate_adj_pct + 100)/100))
                            ,(nvl(tmp.bill_rate_override,tmp.bill_rate) * ((l_bill_rate_adj_pct + 100)/100))))
                    ,'ALL',Decode(NVL(tmp.rate_based_flag,'N'),'N',tmp.bill_rate_override
			  ,Decode(NVL(tmp.billable_flag,'N'),'Y'
                        , (NVL(tmp.bill_rate_override,tmp.bill_rate) *
                        ((l_bill_rate_adj_pct + 100)/100))
                        ,(nvl(tmp.bill_rate_override,tmp.bill_rate) * ((l_bill_rate_adj_pct + 100)/100))))
                    ))
           WHERE tmp.budget_version_id = p_budget_version_id
           AND  EXISTS ( select null
            	from pa_fp_spread_calc_tmp caltmp
                WHERE  caltmp.resource_assignment_id = tmp.resource_assignment_id
                AND  caltmp.txn_currency_code      = tmp.txn_currency_code
                AND  nvl(caltmp.skip_record_flag,'N') <> 'Y'
                AND  nvl(caltmp.mass_adjust_flag,'N') = 'Y'
           );
           g_stage := 'mass_adjust:104: Number of rows Updated['||sql%rowcount||']';

	  ELSIF l_raw_cost_adj_pct is NOT NULL OR l_burden_cost_adj_pct is NOT NULL OR l_revenue_adj_pct is NOT NULL Then
		UPDATE /*+ INDEX(TMP PA_FP_ROLLUP_TMP_N1) */ pa_fp_rollup_tmp tmp
           	SET    tmp.old_txn_raw_cost =
				decode(l_raw_cost_adj_pct,NULL,to_number(null),tmp.txn_raw_cost)
		       ,tmp.old_txn_revenue =
				decode(l_revenue_adj_pct,NULL,to_number(null),tmp.txn_revenue)
		       ,tmp.txn_raw_cost =
				decode(l_raw_cost_adj_pct,NULL,tmp.txn_raw_cost
				   ,decode(tmp.txn_raw_cost,NULL,NULL,0,0
					,(NVL(tmp.txn_init_raw_cost,0)+ pa_currency.round_trans_currency_amt1 (
                                           ((NVL(tmp.txn_raw_cost,0) - nvl(tmp.txn_init_raw_cost,0))
                                             * ((l_raw_cost_adj_pct + 100)/100)),tmp.txn_currency_code))))
		       ,tmp.txn_revenue =
				decode(l_revenue_adj_pct,NULL,tmp.txn_revenue
                                   ,decode(tmp.txn_revenue,NULL,NULL,0,0
                                        ,(NVL(tmp.txn_init_revenue,0)+ pa_currency.round_trans_currency_amt1 (
                                           ((NVL(tmp.txn_revenue,0) - nvl(tmp.txn_init_revenue,0))
                                             * ((l_revenue_adj_pct + 100)/100)),tmp.txn_currency_code))))
		       ,tmp.quantity = decode(NVL(tmp.rate_based_flag,'N'),'Y',tmp.quantity
					 ,decode(l_raw_cost_adj_pct,NULL
					 ,decode(l_revenue_adj_pct, NULL, tmp.quantity
					    ,decode(g_fp_budget_version_type,'COST',tmp.quantity
						 ,'REVENUE', (NVL(tmp.txn_init_revenue,0)+ pa_currency.round_trans_currency_amt1 (
                                           			((NVL(tmp.txn_revenue,0) - nvl(tmp.txn_init_revenue,0))
                                             				* ((l_revenue_adj_pct + 100)/100)),tmp.txn_currency_code))
						,'ALL',decode(nvl(tmp.rw_cost_rate_override,0),0
								,(NVL(tmp.txn_init_revenue,0)+ pa_currency.round_trans_currency_amt1 (
                                                                ((NVL(tmp.txn_revenue,0) - nvl(tmp.txn_init_revenue,0))
                                                                        * ((l_revenue_adj_pct + 100)/100)),tmp.txn_currency_code))
							       ,tmp.quantity)))
					    ,decode(g_fp_budget_version_type,'REVENUE',tmp.quantity
						,'COST',(NVL(tmp.txn_init_raw_cost,0)+ pa_currency.round_trans_currency_amt1 (
                                           		   ((NVL(tmp.txn_raw_cost,0) - nvl(tmp.txn_init_raw_cost,0))
                                             		    * ((l_raw_cost_adj_pct + 100)/100)),tmp.txn_currency_code))
						,'ALL',decode(nvl(tmp.rw_cost_rate_override,0),0,tmp.quantity
							,(NVL(tmp.txn_init_raw_cost,0)+ pa_currency.round_trans_currency_amt1 (
                                                           ((NVL(tmp.txn_raw_cost,0) - nvl(tmp.txn_init_raw_cost,0))
                                                            * ((l_raw_cost_adj_pct + 100)/100)),tmp.txn_currency_code))))))
		       ,tmp.burden_cost_rate_override =
                		Decode(g_fp_budget_version_type,'REVENUE',tmp.burden_cost_rate_override
				 ,Decode(l_burden_cost_adj_pct,NULL
				 ,Decode(l_raw_cost_adj_pct,NULL,tmp.burden_cost_rate_override
                                   ,decode(NVL(tmp.rate_based_flag,'N'),'N',tmp.burden_cost_rate_override
				      ,Decode(tmp.burden_cost_rate_override,NULL,tmp.burden_cost_rate_override,1,NULL
					,decode((nvl(tmp.quantity,0) - nvl(tmp.init_quantity,0)),0,tmp.burden_cost_rate_override
                                          ,decode(NVL(tmp.rw_cost_rate_override,nvl(tmp.cost_rate,0)),0,tmp.burden_cost_rate_override
                                             ,((tmp.burden_cost_rate_override / NVL(tmp.rw_cost_rate_override,tmp.cost_rate))
                                                * (NVL(tmp.rw_cost_rate_override,tmp.cost_rate)* ((l_raw_cost_adj_pct+ 100)/100))))))))
                                      	,(NVL(tmp.burden_cost_rate_override,tmp.burden_cost_rate)
                        			* ((l_burden_cost_adj_pct + 100)/100))
                        		))
		       ,tmp.bill_rate_override =
				decode(g_fp_budget_version_type,'COST', tmp.bill_rate_override
				 ,'REVENUE', decode(l_revenue_adj_pct,NULL,tmp.bill_rate_override
					,decode(NVL(tmp.rate_based_flag,'N'),'N',tmp.bill_rate_override
					 ,(NVL(tmp.bill_rate_override,tmp.bill_rate) * ((l_revenue_adj_pct + 100)/100))))
				,'ALL' , Decode(l_raw_cost_adj_pct,NULL
					  ,decode(l_revenue_adj_pct,NULL,tmp.bill_rate_override
					   ,decode(NVL(tmp.rate_based_flag,'N'),'Y'
						,(NVL(tmp.bill_rate_override,tmp.bill_rate) * ((l_revenue_adj_pct + 100)/100))
						,decode(NVL(tmp.rw_cost_rate_override,0),0,tmp.bill_rate_override
						 ,(NVL(tmp.bill_rate_override,tmp.bill_rate) * ((l_revenue_adj_pct + 100)/100)))))
					  ,decode(NVL(tmp.rate_based_flag,'N'),'N',tmp.bill_rate_override
					   ,decode((nvl(tmp.quantity,0) - nvl(tmp.init_quantity,0)),0,tmp.bill_rate_override
					    ,decode(NVL(tmp.rw_cost_rate_override,nvl(tmp.cost_rate,0)),0,tmp.bill_rate_override
						,((tmp.bill_rate_override / NVL(tmp.rw_cost_rate_override,tmp.cost_rate))
                                                * (NVL(tmp.rw_cost_rate_override,tmp.cost_rate)* ((l_raw_cost_adj_pct+ 100)/100)))))))
					)
		       ,tmp.rw_cost_rate_override =
                                decode(l_raw_cost_adj_pct,NULL,tmp.rw_cost_rate_override
				 ,decode((nvl(tmp.quantity,0) - nvl(tmp.init_quantity,0)),0,tmp.rw_cost_rate_override
                                  ,decode(NVL(tmp.rate_based_flag,'N'),'N',tmp.rw_cost_rate_override
                                   ,Decode(l_raw_cost_adj_pct,NULL,tmp.rw_cost_rate_override
                                     ,(NVL(tmp.rw_cost_rate_override,tmp.cost_rate)
                                       * ((l_raw_cost_adj_pct + 100)/100))))))
		WHERE tmp.budget_version_id = p_budget_version_id
                AND  EXISTS ( select null
                		from pa_fp_spread_calc_tmp caltmp
                		WHERE  caltmp.resource_assignment_id = tmp.resource_assignment_id
                		AND  caltmp.txn_currency_code      = tmp.txn_currency_code
                		AND  nvl(caltmp.skip_record_flag,'N') <> 'Y'
                		AND  nvl(caltmp.mass_adjust_flag,'N') = 'Y' );

	  END IF;
	END IF;  --} //end of g_wp_version_flag

    --print_msg(g_stage);
    IF l_quantity_adj_pct is NOT NULL OR l_raw_cost_adj_pct is NOT NULL OR l_revenue_adj_pct is NOT NULL Then --{
            l_raId_tab.delete;
            l_txn_cur_tab.delete;
            l_sdate_tab.delete;
            l_blId_tab.delete;
            l_ratebase_tab.delete;
            l_quantity_old_tab.delete;
        l_quantity_new_tab.delete;
        l_quantity_diff_tab.delete;
	l_rawCost_new_tab.delete;
        l_rawcost_old_tab.delete;
        l_rawcost_diff_tab.delete;
	l_revenue_new_tab.delete;
        l_revenue_old_tab.delete;
        l_revenue_diff_tab.delete;
        OPEN cur_rndQty;
        FETCH cur_rndQty BULK COLLECT INTO
            l_raId_tab
                ,l_txn_cur_tab
                ,l_sdate_tab
                ,l_blId_tab
                ,l_ratebase_tab
                ,l_quantity_old_tab
                ,l_quantity_new_tab
            	,l_quantity_diff_tab
		,l_rawCost_old_tab
        	,l_rawcost_new_tab
        	,l_rawcost_diff_tab
		,l_revenue_old_tab
        	,l_revenue_new_tab
        	,l_revenue_diff_tab;
        CLOSE cur_rndQty;
        IF l_blId_tab.COUNT > 0 Then
	   If l_quantity_adj_pct is NOT NULL Then --{
            g_stage := 'MassAdjust:Quantity_Rounding adjust:105';
	    If P_PA_DEBUG_MODE = 'Y' Then
            print_msg(g_stage);
	    End if;
            FOR i IN l_blId_tab.FIRST .. l_blId_tab.LAST LOOP
                If l_ratebase_tab(i) = 'Y' Then
                   l_quantity_old_tab(i) := Round_Quantity(l_quantity_old_tab(i));
                Else
                   l_quantity_old_tab(i) := pa_currency.round_trans_currency_amt1
                               (l_quantity_old_tab(i),l_txn_cur_tab(i));
                End If;
                IF l_quantity_old_tab(i) <> l_quantity_new_tab(i) Then
                    l_quantity_diff_tab(i) := l_quantity_old_tab(i) - l_quantity_new_tab(i);
                End If;
            END LOOP;
            g_stage := 'mass_adjust:106';
            FORALL i IN l_blId_tab.FIRST .. l_blId_tab.LAST
            UPDATE pa_fp_rollup_tmp tmp
            SET tmp.quantity = tmp.quantity + nvl(l_quantity_diff_tab(i),0)
            WHERE tmp.budget_line_id = l_blId_tab(i)
            AND NVL(l_quantity_diff_tab(i),0) <> 0;

	 Elsif l_raw_cost_adj_pct is NOT NULL and g_fp_budget_version_type in ('COST','ALL') Then
	    g_stage := 'MassAdjust:RawCost_Rounding adjust:105';
	    If P_PA_DEBUG_MODE = 'Y' Then
            print_msg(g_stage);
	    End If;
            FOR i IN l_blId_tab.FIRST .. l_blId_tab.LAST LOOP
                If l_ratebase_tab(i) = 'N' Then
                   l_rawcost_old_tab(i) := pa_currency.round_trans_currency_amt1
                               (l_rawcost_old_tab(i),l_txn_cur_tab(i));
                End If;
                IF l_rawcost_old_tab(i) <> l_rawcost_new_tab(i) Then
                    l_rawcost_diff_tab(i) := l_rawcost_old_tab(i) - l_rawcost_new_tab(i);
                End If;
            END LOOP;
            g_stage := 'mass_adjust:106';
            FORALL i IN l_blId_tab.FIRST .. l_blId_tab.LAST
            UPDATE pa_fp_rollup_tmp tmp
            SET tmp.quantity = decode(g_fp_budget_version_type,'REVENUE', tmp.quantity
				,'COST', (tmp.txn_raw_cost + nvl(l_rawcost_diff_tab(i),0))
				,'ALL',decode(tmp.rw_cost_rate_override,0,tmp.quantity,NULL,tmp.quantity
					,(tmp.txn_raw_cost + nvl(l_rawcost_diff_tab(i),0))))
	       ,tmp.txn_raw_cost = decode(g_fp_budget_version_type,'REVENUE', tmp.txn_raw_cost
                                ,'COST', (tmp.txn_raw_cost + nvl(l_rawcost_diff_tab(i),0))
                                ,'ALL',decode(tmp.rw_cost_rate_override,0,tmp.txn_raw_cost,NULL,tmp.txn_raw_cost
                                        ,(tmp.txn_raw_cost + nvl(l_rawcost_diff_tab(i),0))))
            WHERE tmp.budget_line_id = l_blId_tab(i)
            AND NVL(l_rawcost_diff_tab(i),0) <> 0
	    AND l_ratebase_tab(i) = 'N' ;

	 Elsif l_revenue_adj_pct is NOT NULL and g_fp_budget_version_type in ('REVENUE','ALL') Then
            g_stage := 'MassAdjust:Revenue_Rounding adjust:105';
	    If P_PA_DEBUG_MODE = 'Y' Then
            print_msg(g_stage);
	    End If;
            FOR i IN l_blId_tab.FIRST .. l_blId_tab.LAST LOOP
                If l_ratebase_tab(i) = 'N' Then
                   l_revenue_old_tab(i) := pa_currency.round_trans_currency_amt1
                               (l_revenue_old_tab(i),l_txn_cur_tab(i));
                End If;
                IF l_revenue_old_tab(i) <> l_revenue_new_tab(i) Then
                    l_revenue_diff_tab(i) := l_revenue_old_tab(i) - l_revenue_new_tab(i);
                End If;
            END LOOP;
            g_stage := 'mass_adjust:106';
            FORALL i IN l_blId_tab.FIRST .. l_blId_tab.LAST
            UPDATE pa_fp_rollup_tmp tmp
            SET tmp.quantity = decode(g_fp_budget_version_type,'COST', tmp.quantity
                                ,'REVENUE', (tmp.txn_revenue + nvl(l_revenue_diff_tab(i),0))
                                ,'ALL',decode(nvl(tmp.rw_cost_rate_override,0),0
					,(tmp.txn_revenue + nvl(l_revenue_diff_tab(i),0)),tmp.quantity))
               ,tmp.txn_revenue = decode(g_fp_budget_version_type,'COST',tmp.txn_revenue
				,'REVENUE', (tmp.txn_revenue + nvl(l_revenue_diff_tab(i),0))
                                ,'ALL', decode(nvl(tmp.rw_cost_rate_override,0),0
                                        ,(tmp.txn_revenue + nvl(l_revenue_diff_tab(i),0)),tmp.quantity))
            WHERE tmp.budget_line_id = l_blId_tab(i)
            AND NVL(l_revenue_diff_tab(i),0) <> 0
            AND l_ratebase_tab(i) = 'N' ;
	 END If; --}
        END IF;

    End If; --}
        IF p_pa_debug_mode = 'Y' Then
        	print_msg('x_return_status : '||x_return_status);
        	print_msg('Leaving mass_adjust');
            	pa_debug.reset_err_stack;
        End If;
EXCEPTION
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_data := sqlcode||sqlerrm;
                fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                ,p_procedure_name => 'mass_adjust' );
                print_msg(g_stage||' substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
            IF p_pa_debug_mode = 'Y' Then
                    pa_debug.reset_err_stack;
            End If;
                RAISE;

END mass_adjust_new;

/*
-- FUNCTION get_resource_list_member_id is used to get the resource_list_member_id from
-- pa_resource_assignments based on a resource_assignment_id and txn_currency_code
*/

FUNCTION get_resource_list_member_id
    ( p_resource_assignment_id IN NUMBER) RETURN NUMBER IS

    x_resource_list_member_id  NUMBER := NULL;

    CURSOR get_res_list_member_csr IS
    SELECT resource_list_member_id
        FROM pa_resource_assignments
        WHERE resource_assignment_id = p_resource_assignment_id;

    get_res_list_member_rec    get_res_list_member_csr%ROWTYPE;

BEGIN
    get_res_list_member_rec := NULL;
        OPEN get_res_list_member_csr;
    FETCH get_res_list_member_csr INTO get_res_list_member_rec;
    CLOSE get_res_list_member_csr;

        x_resource_list_member_id := get_res_list_member_rec.resource_list_member_id;
    If x_resource_list_member_id is NULL Then
        x_resource_list_member_id := NULL;
    End IF;

    RETURN x_resource_list_member_id;

END  get_resource_list_member_id;


/*
--  PROCEDURE rollup_pf_pfc_to_ra is called from PROCEDURE calculate
--  This procedure is called to Rollup PC and PFC numbers stored in
--  pa_budget_line to pa_resource_assignments
*/
-- gboomina for AAI Requirement - Start
-- Modifying this procedure to take calling module as a parameter
-- so that this api can be called from Collect actuals flow
PROCEDURE rollup_pf_pfc_to_ra
        ( p_budget_version_id    IN  NUMBER
         ,p_calling_module       IN  VARCHAR2 DEFAULT 'CALCULATE_API'
         ,x_return_status        OUT NOCOPY VARCHAR2
         ,x_msg_count            OUT NOCOPY NUMBER
         ,x_msg_data             OUT NOCOPY VARCHAR2) IS

    l_stage             NUMBER;

/* Note:5519188 data corruption happens when tmp table has multiple rows with raids. Ex: budget line source context
 	          * OR in RA context with same ra + different txn currency combo. In order to avoid this cartesian join the only way
 	          * is use EXISTS clause or get distinct RAIDs from tmp table and hit budget lines in a loop
*/

    CURSOR rollup_bl_csr is
    SELECT /*+ INDEX(PBL PA_BUDGET_LINES_U1) */
	   pbl.resource_assignment_id
           ,DECODE(sum(pbl.quantity),0,NULL,sum(pbl.quantity))                                      pfc_quantity
           ,DECODE(sum(pbl.raw_cost),0,NULL,sum(pbl.raw_cost))                                      pfc_raw_cost
           ,DECODE(sum(pbl.burdened_cost),0,NULL,sum(pbl.burdened_cost))                            pfc_burdened_cost
           ,DECODE(sum(pbl.revenue),0,NULL,sum(pbl.revenue))                                        pfc_revenue
           ,DECODE(sum(pbl.project_raw_cost),0,NULL,sum(pbl.project_raw_cost))                      project_raw_cost
           ,DECODE(sum(pbl.project_burdened_cost),0,NULL,sum(pbl.project_burdened_cost))            project_burdened_cost
           ,DECODE(sum(pbl.project_revenue),0,NULL,sum(pbl.project_revenue))                        project_revenue
           ,DECODE(sum(pbl.init_quantity),0,NULL,sum(pbl.init_quantity))                            pfc_init_quantity
           ,DECODE(sum(pbl.init_raw_cost),0,NULL,sum(pbl.init_raw_cost))                            pfc_init_raw_cost
           ,DECODE(sum(pbl.init_burdened_cost),0,NULL,sum(pbl.init_burdened_cost))                  pfc_init_burdened_cost
           ,DECODE(sum(pbl.init_revenue),0,NULL,sum(pbl.init_revenue))                              pfc_init_revenue
           ,DECODE(sum(pbl.project_init_raw_cost),0,NULL,sum(pbl.project_init_raw_cost))            project_init_raw_cost
           ,DECODE(sum(pbl.project_init_burdened_cost),0,NULL,sum(pbl.project_init_burdened_cost))  project_init_burdened_cost
           ,DECODE(sum(pbl.project_init_revenue),0,NULL,sum(pbl.project_init_revenue))              project_init_revenue
        FROM pa_budget_lines pbl
	WHERE pbl.budget_version_id = p_budget_version_id
    	AND EXISTS (SELECT NULL
                    FROM pa_fp_spread_calc_tmp tmp
                    WHERE tmp.budget_version_id = p_budget_version_id
                    AND   tmp.resource_assignment_id = pbl.resource_assignment_id
                   )
     GROUP BY pbl.resource_assignment_id;

    -- gboomina AAI Requirement - Start
    -- Cursor to get rolled up amounts from budget lines without temp table
    -- This cursor is used for other flows other than calculate api where in
    -- we might not have data populated in pa_fp_spread_calc_tmp temp table
    CURSOR rollup_bl_generic_csr is
    SELECT
           pbl.resource_assignment_id
           ,DECODE(sum(pbl.quantity),0,NULL,sum(pbl.quantity))                                      pfc_quantity
           ,DECODE(sum(pbl.raw_cost),0,NULL,sum(pbl.raw_cost))                                      pfc_raw_cost
           ,DECODE(sum(pbl.burdened_cost),0,NULL,sum(pbl.burdened_cost))                            pfc_burdened_cost
           ,DECODE(sum(pbl.revenue),0,NULL,sum(pbl.revenue))                                        pfc_revenue
           ,DECODE(sum(pbl.project_raw_cost),0,NULL,sum(pbl.project_raw_cost))                      project_raw_cost
           ,DECODE(sum(pbl.project_burdened_cost),0,NULL,sum(pbl.project_burdened_cost))            project_burdened_cost
           ,DECODE(sum(pbl.project_revenue),0,NULL,sum(pbl.project_revenue))                        project_revenue
           ,DECODE(sum(pbl.init_quantity),0,NULL,sum(pbl.init_quantity))                            pfc_init_quantity
           ,DECODE(sum(pbl.init_raw_cost),0,NULL,sum(pbl.init_raw_cost))                            pfc_init_raw_cost
           ,DECODE(sum(pbl.init_burdened_cost),0,NULL,sum(pbl.init_burdened_cost))                  pfc_init_burdened_cost
           ,DECODE(sum(pbl.init_revenue),0,NULL,sum(pbl.init_revenue))                              pfc_init_revenue
           ,DECODE(sum(pbl.project_init_raw_cost),0,NULL,sum(pbl.project_init_raw_cost))            project_init_raw_cost
           ,DECODE(sum(pbl.project_init_burdened_cost),0,NULL,sum(pbl.project_init_burdened_cost))  project_init_burdened_cost
           ,DECODE(sum(pbl.project_init_revenue),0,NULL,sum(pbl.project_init_revenue))              project_init_revenue
        FROM pa_budget_lines pbl
        WHERE pbl.budget_version_id = p_budget_version_id
     GROUP BY pbl.resource_assignment_id;
    -- gboomina AAI Requirement - End

    l_resource_assignment_id_tab        pa_plsql_datatypes.NumTabTyp;
    l_pfc_quantity_tab          pa_plsql_datatypes.NumTabTyp;
    l_pfc_raw_cost_tab          pa_plsql_datatypes.NumTabTyp;
        l_pfc_burden_cost_tab           pa_plsql_datatypes.NumTabTyp;
        l_pfc_revenue_tab           pa_plsql_datatypes.NumTabTyp;
        l_project_raw_cost_tab          pa_plsql_datatypes.NumTabTyp;
        l_project_burden_cost_tab       pa_plsql_datatypes.NumTabTyp;
        l_project_revenue_tab           pa_plsql_datatypes.NumTabTyp;
        l_pfc_init_quantity_tab         pa_plsql_datatypes.NumTabTyp;
        l_pfc_init_raw_cost_tab         pa_plsql_datatypes.NumTabTyp;
        l_pfc_init_burden_cost_tab      pa_plsql_datatypes.NumTabTyp;
        l_pfc_init_revenue_tab          pa_plsql_datatypes.NumTabTyp;
        l_project_init_raw_cost_tab     pa_plsql_datatypes.NumTabTyp;
        l_project_init_burden_cost_tab      pa_plsql_datatypes.NumTabTyp;
        l_project_init_revenue_tab      pa_plsql_datatypes.NumTabTyp;

    l_user_id   Number;
        l_login_id  Number;

BEGIN
        x_return_status := 'S';
    l_user_id := fnd_global.user_id;
        l_login_id := fnd_global.login_id;
    /* Bug fix: 4251858  */
  -- gboomina AAI Requirement - Start
  if (p_calling_module = 'CALCULATE_API') then
    UPDATE PA_RESOURCE_ASSIGNMENTS ra
        SET ra.total_plan_quantity = null
              ,ra.total_plan_raw_cost = null
              ,ra.total_plan_burdened_cost = null
              ,ra.total_plan_revenue = null
              ,ra.total_project_raw_cost = null
              ,ra.total_project_burdened_cost = null
              ,ra.total_project_revenue = null
              ,ra.last_updated_by = l_user_id
              ,ra.last_update_date = sysdate
              ,ra.last_update_login =  l_login_id
        WHERE EXISTS (SELECT NULL
                    FROM pa_fp_spread_calc_tmp tmp
                    WHERE tmp.budget_version_id = p_budget_version_id
                    AND   tmp.resource_assignment_id = ra.resource_assignment_id
            /* Bug fix: 4322568 AND  NVL(tmp.skip_record_flag,'N') = 'Y' */
                   );

        OPEN rollup_bl_csr;
    FETCH rollup_bl_csr BULK COLLECT INTO
        l_resource_assignment_id_tab
            ,l_pfc_quantity_tab
            ,l_pfc_raw_cost_tab
            ,l_pfc_burden_cost_tab
            ,l_pfc_revenue_tab
            ,l_project_raw_cost_tab
            ,l_project_burden_cost_tab
            ,l_project_revenue_tab
            ,l_pfc_init_quantity_tab
            ,l_pfc_init_raw_cost_tab
            ,l_pfc_init_burden_cost_tab
            ,l_pfc_init_revenue_tab
            ,l_project_init_raw_cost_tab
            ,l_project_init_burden_cost_tab
            ,l_project_init_revenue_tab;
    CLOSE rollup_bl_csr;
  else
    -- if calling module is not 'CALCULATE_API' then get values from
    -- generic cursor
      OPEN rollup_bl_generic_csr;
      FETCH rollup_bl_generic_csr BULK COLLECT INTO
                l_resource_assignment_id_tab
               ,l_pfc_quantity_tab
               ,l_pfc_raw_cost_tab
               ,l_pfc_burden_cost_tab
               ,l_pfc_revenue_tab
               ,l_project_raw_cost_tab
               ,l_project_burden_cost_tab
               ,l_project_revenue_tab
               ,l_pfc_init_quantity_tab
               ,l_pfc_init_raw_cost_tab
               ,l_pfc_init_burden_cost_tab
               ,l_pfc_init_revenue_tab
               ,l_project_init_raw_cost_tab
               ,l_project_init_burden_cost_tab
               ,l_project_init_revenue_tab;
       CLOSE rollup_bl_generic_csr;
   end if;
       -- gboomina AAI Requirement - End

    IF l_resource_assignment_id_tab.COUNT > 0 THEN
       FORALL i IN l_resource_assignment_id_tab.FIRST .. l_resource_assignment_id_tab.LAST
       UPDATE PA_RESOURCE_ASSIGNMENTS ra
       SET ra.total_plan_quantity = l_pfc_quantity_tab(i)
                    ,ra.total_plan_raw_cost = l_pfc_raw_cost_tab(i)
                    ,ra.total_plan_burdened_cost = l_pfc_burden_cost_tab(i)
                    ,ra.total_plan_revenue = l_pfc_revenue_tab(i)
                    ,ra.total_project_raw_cost = l_project_raw_cost_tab(i)
                    ,ra.total_project_burdened_cost = l_project_burden_cost_tab(i)
                    ,ra.total_project_revenue = l_project_revenue_tab(i)
            ,ra.last_updated_by = l_user_id
            ,ra.last_update_date = sysdate
            ,ra.last_update_login =  l_login_id
       WHERE ra.resource_assignment_id = l_resource_assignment_id_tab(i);
    END IF;
	If P_PA_DEBUG_MODE = 'Y' Then
    print_msg('Leaving rollup_pf_pfc_to_ra x_return_status : '||x_return_status);
	End If;

EXCEPTION
    WHEN OTHERS THEN
            x_return_status := 'U';
            fnd_msg_pub.add_exc_msg
            ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                ,p_procedure_name => 'rollup_pf_pfc_to_ra' );
            l_stage := 5140;
            print_msg(to_char(l_stage)||' substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
            RAISE;
END rollup_pf_pfc_to_ra;

/*
--  PROCEDURE rollup_pf_pfc_to_bv is called from PROCEDURE calculate
--  This procedure is called to Rollup PC and PFC numbers stored in
--  pa_resource_assignments to pa_budget_versions
*/
PROCEDURE rollup_pf_pfc_to_bv ( p_budget_version_id             IN  pa_budget_versions.budget_version_id%TYPE
                               ,x_return_status                 OUT NOCOPY VARCHAR2
                               ,x_msg_count                     OUT NOCOPY NUMBER
                               ,x_msg_data                      OUT NOCOPY VARCHAR2) IS

 l_debug_mode        VARCHAR2(30);
 l_stage             NUMBER;

/*
--  Decode is used on total_plan_quantity to split the quantity into
--  equipment_quantity and labor_quantity.  If the resource_class_code = 'PEOPLE'
--  the quantity is rolled up to labor.  IF the resource_class_code = 'EQUIPMENT'
--  the quantity is rolled up to equipment.  All other quantities are ignored.
*/
      CURSOR rollup_ra_csr is
      SELECT DECODE(sum(total_plan_revenue),0,NULL,
                        sum(total_plan_revenue))                             total_plan_revenue
            ,DECODE(sum(total_plan_raw_cost),0,NULL,
                        sum(total_plan_raw_cost))                            total_plan_raw_cost
            ,DECODE(sum(total_plan_burdened_cost),0,NULL,
                        sum(total_plan_burdened_cost))                       total_plan_burdened_cost
        /* Bug fix: 3968340. rollup the labor and equipment effort only if the uom is HOURS
         * the following code is commented out and added the new decode
            ,DECODE(sum(decode(resource_class_code,'PEOPLE',total_plan_quantity,to_number(null))),0,NULL,
                        sum(decode(resource_class_code,'PEOPLE',total_plan_quantity,to_number(null))))
                                                                             total_labor_quantity
            ,DECODE(sum(decode(resource_class_code,'EQUIPMENT',total_plan_quantity,to_number(null))),0,NULL,
                        sum(decode(resource_class_code,'EQUIPMENT',total_plan_quantity,to_number(null))))
                                                                             total_equipment_quantity
        */
            ,DECODE(sum(decode(resource_class_code,'PEOPLE'
                ,decode(pra.unit_of_measure,'HOURS',total_plan_quantity,to_number(null))
                               ,to_number(null))),0,NULL
                        ,sum(decode(resource_class_code,'PEOPLE'
                     ,decode(pra.unit_of_measure,'HOURS',total_plan_quantity,to_number(null))
                          ,to_number(null))
            )) total_labor_quantity
            ,DECODE(sum(decode(resource_class_code,'EQUIPMENT'
                       ,decode(pra.unit_of_measure,'HOURS',total_plan_quantity,to_number(null))
                           ,to_number(null))),0,NULL
                        ,sum(decode(resource_class_code,'EQUIPMENT'
                     ,decode(pra.unit_of_measure,'HOURS',total_plan_quantity,to_number(null))
                  ,to_number(null))
               ))total_equipment_quantity
            ,DECODE(sum(total_project_raw_cost),0,NULL,
                        sum(total_project_raw_cost))                         total_project_raw_cost
            ,DECODE(sum(total_project_burdened_cost),0,NULL,
                        sum(total_project_burdened_cost))                    total_project_burdened_cost
            ,DECODE(sum(total_project_revenue),0,NULL,
                        sum(total_project_revenue))                          total_project_revenue
        FROM pa_resource_assignments pra
        WHERE pra.budget_version_id = p_budget_version_id
    AND  pra.project_id = g_project_id;

    rollup_ra_rec      rollup_ra_csr%ROWTYPE;
    l_msg_index_out    NUMBER;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_stage             := 6000;

    rollup_ra_rec := NULL;
  IF NOT rollup_ra_csr%ISOPEN THEN
    OPEN rollup_ra_csr;
  ELSE
    CLOSE rollup_ra_csr;
    OPEN rollup_ra_csr;
  END IF;

  FETCH rollup_ra_csr into rollup_ra_rec;
    IF rollup_ra_csr%NOTFOUND THEN
      l_stage             := 6010;
      --print_msg(to_char(l_stage)||' rollup_ra_csr%NOTFOUND nothing to rollup to pa_budget_versions');
      BEGIN
        l_stage := 6015;
        UPDATE  pa_budget_versions SET
                raw_cost                      = to_number(NULL)
               ,burdened_cost                 = to_number(NULL)
               ,revenue                       = to_number(NULL)
               ,total_project_raw_cost        = to_number(NULL)
               ,total_project_burdened_cost   = to_number(NULL)
               ,total_project_revenue         = to_number(NULL)
               ,labor_quantity                = to_number(NULL)
               ,equipment_quantity            = to_number(NULL)
               ,record_version_number         = NVL(record_version_number,0) + 1
               ,last_update_date              = sysdate
               ,last_updated_by               = fnd_global.user_id
               ,creation_date                 = sysdate
               ,created_by                    = fnd_global.user_id
               ,last_update_login             = fnd_global.login_id
         WHERE budget_version_id = p_budget_version_id;
      EXCEPTION
         WHEN OTHERS THEN
           print_msg(to_char(l_stage)||' ***ERROR*** Updating pa_budget_versions in rollup_pf_pfc_to_bv');
           pa_debug.g_err_stage := to_char(l_stage)||': ***ERROR*** Updating pa_budget_versions in rollup_pf_pfc_to_bv';
           IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('rollup_pf_pfc_to_bv: ' || g_module_name,pa_debug.g_err_stage,3);
           END IF;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            SELECT TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS') INTO g_session_time
            FROM DUAL;
            print_msg('RETURN bvid => '||g_budget_version_id||' ,pid => '||g_project_id||' ,sesstime => '||g_session_time);
           RETURN;
      END;
    ELSE
      l_stage             := 6020;
    /*print_msg(to_char(l_stage)||'UPDATE pa_budget_versions with the following:');
      print_msg(' raw_cost                      = '||to_char(rollup_ra_rec.total_plan_raw_cost));
      print_msg(' burdened_cost                 = '||to_char(rollup_ra_rec.total_plan_burdened_cost));
      print_msg(' revenue                       = '||to_char(rollup_ra_rec.total_plan_revenue));
      print_msg(' total_project_raw_cost        = '||to_char(rollup_ra_rec.total_project_raw_cost));
      print_msg(' total_project_burdened_cost   = '||to_char(rollup_ra_rec.total_project_burdened_cost));
      print_msg(' total_project_revenue         = '||to_char(rollup_ra_rec.total_project_revenue));
      print_msg(' labor_quantity                = '||to_char(rollup_ra_rec.total_labor_quantity));
      print_msg(' equipment_quantity            = '||to_char(rollup_ra_rec.total_equipment_quantity));
    */

      BEGIN
        l_stage := 6029;
        UPDATE  pa_budget_versions
    SET raw_cost                      = rollup_ra_rec.total_plan_raw_cost
               ,burdened_cost                 = rollup_ra_rec.total_plan_burdened_cost
               ,revenue                       = rollup_ra_rec.total_plan_revenue
               ,total_project_raw_cost        = rollup_ra_rec.total_project_raw_cost
               ,total_project_burdened_cost   = rollup_ra_rec.total_project_burdened_cost
               ,total_project_revenue         = rollup_ra_rec.total_project_revenue
               ,labor_quantity                = rollup_ra_rec.total_labor_quantity
               ,equipment_quantity            = rollup_ra_rec.total_equipment_quantity
               ,record_version_number         = NVL(record_version_number,0) + 1
               ,last_update_date              = sysdate
               ,last_updated_by               = fnd_global.user_id
               ,creation_date                 = sysdate
               ,created_by                    = fnd_global.user_id
               ,last_update_login             = fnd_global.login_id
         WHERE budget_version_id = p_budget_version_id;
      EXCEPTION
         WHEN OTHERS THEN
           print_msg(to_char(l_stage)||' ***ERROR*** Updating pa_budget_versions in rollup_pf_pfc_to_bv');
           pa_debug.g_err_stage := to_char(l_stage)||': ***ERROR*** Updating pa_budget_versions in rollup_pf_pfc_to_bv';
           IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('rollup_pf_pfc_to_bv: ' || g_module_name,pa_debug.g_err_stage,3);
           END IF;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            SELECT TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS') INTO g_session_time
            FROM DUAL;
            print_msg('RETURN bvid => '||g_budget_version_id||' ,pid => '||g_project_id||' ,sesstime => '||g_session_time);
           RETURN;
      END;
    END IF;

  CLOSE rollup_ra_csr;
 /*
  print_msg('x_return_status : '||x_return_status);
  print_msg('Leaving rollup_pf_pfc_to_bv');
 */

  EXCEPTION WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.add_exc_msg
           ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
            ,p_procedure_name => 'rollup_pf_pfc_to_bv' );
        pa_debug.g_err_stage := 'Stage : '||to_char(l_stage)||' '||substr(SQLERRM,1,240);
        l_stage := 6140;
        print_msg(to_char(l_stage)||' substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('rollup_pf_pfc_to_bv: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;

END  rollup_pf_pfc_to_bv;

/* This API populates the spread records in the tmp table and finally spread api is called to process these records */
PROCEDURE populate_spreadRecs
        (p_budget_version_id   IN NUMBER
        ,p_source_context      IN VARCHAR2
        ,x_return_status       OUT NOCOPY VARCHAR2 ) IS

BEGIN
    x_return_status := 'S';
    IF g_sprd_raId_tab.COUNT > 0 THEN
	If P_PA_DEBUG_MODE = 'Y' Then
    print_msg('Inserting records into fp_res_assignment_tmp table count['||g_sprd_raId_tab.COUNT||']fst['||g_sprd_raId_tab.first||']Lst['||g_sprd_raId_tab.last||']');
	End If;

    FORALL i IN g_sprd_raId_tab.FIRST .. g_sprd_raId_tab.LAST
    INSERT INTO PA_FP_RES_ASSIGNMENTS_TMP
            (BUDGET_VERSION_ID
                ,PROJECT_ID
                ,TASK_ID
                ,RESOURCE_LIST_MEMBER_ID
        ,SPREAD_CURVE_ID
        ,SP_FIXED_DATE
        ,SOURCE_CONTEXT
        ,RATE_BASED_FLAG
        ,RESOURCE_ASSIGNMENT_ID
                ,TXN_CURRENCY_CODE
            ,LINE_START_DATE
            ,LINE_END_DATE
            ,PLANNING_START_DATE
        ,PLANNING_END_DATE
            ,TXN_REVENUE
            ,TXN_REVENUE_ADDL
            ,TXN_RAW_COST
            ,TXN_RAW_COST_ADDL
            ,TXN_BURDENED_COST
            ,TXN_BURDENED_COST_ADDL
            ,TXN_PLAN_QUANTITY
            ,TXN_PLAN_QUANTITY_ADDL
            ,TXN_CURRENCY_CODE_OVERRIDE
            ,TXN_INIT_REVENUE
            ,TXN_INIT_RAW_COST
            ,TXN_INIT_BURDENED_COST
            ,INIT_QUANTITY
            ,SPREAD_AMOUNTS_FLAG
            ,RAW_COST_RATE
                ,RW_COST_RATE_OVERRIDE
                ,BURDEN_COST_RATE
                ,BURDEN_COST_RATE_OVERRIDE
                ,BILL_RATE
                ,BILL_RATE_OVERRIDE
        ,PROJECT_CURRENCY_CODE
                ,PROJFUNC_CURRENCY_CODE
		/* bug fix:5726773 : store the value in the sprd table*/
 	        ,NEG_QUANTITY_CHANGE_FLAG --neg_Qty_Change_flag
 	        ,NEG_RAWCOST_CHANGE_FLAG --neg_RawCst_Change_flag
 	        ,NEG_BURDEN_CHANGE_FALG  --neg_BurdCst_Change_flag
 	        ,NEG_REVENUE_CHANGE_FLAG --neg_rev_Change_flag
         )
    VALUES ( p_budget_version_id
        ,g_project_id
        ,g_sprd_task_id_tab(i)
        ,g_sprd_rlm_id_tab(i)
        ,g_sprd_spcurve_id_tab(i)
        ,g_sprd_sp_fixed_date_tab(i)
        ,p_source_context
        ,NVL(g_sprd_ratebase_flag_tab(i),'N')
        ,g_sprd_raId_tab(i)
            ,g_sprd_txn_cur_tab(i)
            ,g_sprd_sdate_tab(i)
            ,g_sprd_edate_tab(i)
            ,g_sprd_plan_sdate_tab(i)
            ,g_sprd_plan_edate_tab(i)
            ,g_sprd_txn_rev_tab(i)
            ,g_sprd_txn_rev_addl_tab(i)
            ,g_sprd_txn_raw_tab(i)
            ,g_sprd_txn_raw_addl_tab(i)
            ,g_sprd_txn_burd_tab(i)
            ,g_sprd_txn_burd_addl_tab(i)
            ,g_sprd_qty_tab(i)
            ,g_sprd_qty_addl_tab(i)
            ,g_sprd_txn_cur_ovr_tab(i)
            ,g_sprd_txn_init_rev_tab(i)
            ,g_sprd_txn_init_raw_tab(i)
            ,g_sprd_txn_init_burd_tab(i)
            ,g_sprd_txn_init_qty_tab(i)
            ,g_sprd_spread_reqd_flag_tab(i)
            ,g_sprd_costRt_tab(i)
            ,g_sprd_costRt_Ovr_tab(i)
            ,g_sprd_burdRt_Tab(i)
            ,g_sprd_burdRt_Ovr_tab(i)
            ,g_sprd_billRt_tab(i)
            ,g_sprd_billRt_Ovr_tab(i)
            ,g_sprd_projCur_tab(i)
            ,g_sprd_projfuncCur_tab(i)
	    /* Bug fix:5463690 */
 	    ,g_sprd_neg_Qty_Changflag_tab(i)
 	    ,g_sprd_neg_Raw_Changflag_tab(i)
 	    ,g_sprd_neg_Burd_Changflag_tab(i)
 	    ,g_sprd_neg_rev_Changflag_tab(i)
        );
	If P_PA_DEBUG_MODE = 'Y' Then
    print_msg('Number of SpreadRecords Inserted['||sql%rowcount||']');
	End If;
    END IF; --}

EXCEPTION
    WHEN OTHERS THEN
        print_msg('Unexpected error from populate_spreadRecs['||sqlcode||sqlerrm);
            x_return_status := 'U';
            fnd_msg_pub.add_exc_msg
            ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                ,p_procedure_name => 'populate_spreadRecs');
            RAISE;
END populate_spreadRecs;
/*
--  PROCEDURE convert_ra_txn_currency calls PA_FP_MULTI_CURRENCY_PKG.convert_mc_bult
--    This is called when the Rate API returns Cost and Revenue in 2 different
--    currencies and cost and revenue amounts are held in one budget line.
--    If the budget is an Approved revenue budget, the project functional currency
--    becomes the transaction currency upon return from this API. The transaction
--    currency amounts change accordingly.
--    If the budget is non-approved revenue budget then the project currency becomes
--    the transaction currency upon return from this API. The transaction currency
--    amounts change accordingly.
*/


PROCEDURE convert_ra_txn_currency
            ( p_budget_version_id         IN pa_budget_versions.budget_version_id%TYPE
             ,p_resource_assignment_id    IN pa_resource_assignments.resource_assignment_id%TYPE
             ,p_txn_currency_code         IN pa_budget_lines.txn_currency_code%TYPE
             ,p_budget_line_id            IN pa_budget_lines.budget_line_id%TYPE
             ,p_txn_raw_cost              IN pa_fp_rollup_tmp.txn_raw_cost%TYPE
             ,p_txn_burdened_cost         IN pa_fp_rollup_tmp.txn_burdened_cost%TYPE
             ,p_txn_revenue               IN pa_fp_rollup_tmp.txn_revenue%TYPE
             ,x_projfunc_currency_code    OUT NOCOPY pa_fp_rollup_tmp.projfunc_currency_code%TYPE
             ,x_projfunc_raw_cost         OUT NOCOPY pa_fp_rollup_tmp.projfunc_raw_cost%TYPE
             ,x_projfunc_burdened_cost    OUT NOCOPY pa_fp_rollup_tmp.projfunc_burdened_cost%TYPE
             ,x_projfunc_revenue          OUT NOCOPY pa_fp_rollup_tmp.projfunc_revenue%TYPE
             ,x_projfunc_rejection_code   OUT NOCOPY pa_fp_rollup_tmp.pfc_cur_conv_rejection_code%TYPE
             ,x_project_currency_code     OUT NOCOPY pa_fp_rollup_tmp.project_currency_code%TYPE
             ,x_project_raw_cost          OUT NOCOPY pa_fp_rollup_tmp.project_raw_cost%TYPE
             ,x_project_burdened_cost     OUT NOCOPY pa_fp_rollup_tmp.project_burdened_cost%TYPE
             ,x_project_revenue           OUT NOCOPY pa_fp_rollup_tmp.project_revenue%TYPE
             ,x_project_rejection_code    OUT NOCOPY pa_fp_rollup_tmp.pc_cur_conv_rejection_code%TYPE
             ,x_return_status             OUT NOCOPY VARCHAR2
             ,x_msg_count                 OUT NOCOPY NUMBER
             ,x_msg_data                  OUT NOCOPY VARCHAR2) IS

    -----added global variables from the multi currency pkg
    /* Bug fix:3801261 l_bl_id_tab SYSTEM.pa_num_tbl_type; */
    l_bl_id_tab                   pa_fp_multi_currency_pkg.number_type_tab;
    l_resource_assignment_id_tab  pa_fp_multi_currency_pkg.number_type_tab;
    l_start_date_tab              pa_fp_multi_currency_pkg.date_type_tab;
    l_end_date_tab                pa_fp_multi_currency_pkg.date_type_tab;
    l_txn_currency_code_tab       pa_fp_multi_currency_pkg.char240_type_tab;
    l_txn_raw_cost_tab            pa_fp_multi_currency_pkg.number_type_tab;
    l_txn_burdened_cost_tab       pa_fp_multi_currency_pkg.number_type_tab;
    l_txn_revenue_tab             pa_fp_multi_currency_pkg.number_type_tab;
    l_projfunc_currency_code_tab  pa_fp_multi_currency_pkg.char240_type_tab;
    l_projfunc_cost_rate_type_tab pa_fp_multi_currency_pkg.char240_type_tab;
    l_projfunc_cost_rate_tab      pa_fp_multi_currency_pkg.number_type_tab;
    l_projfunc_cost_rt_dt_typ_tab pa_fp_multi_currency_pkg.char240_type_tab;
    l_projfunc_cost_rate_date_tab pa_fp_multi_currency_pkg.date_type_tab;
    l_projfunc_rev_rate_type_tab  pa_fp_multi_currency_pkg.char240_type_tab;
    l_projfunc_rev_rate_tab       pa_fp_multi_currency_pkg.number_type_tab;
    l_projfunc_rev_rt_dt_typ_tab  pa_fp_multi_currency_pkg.char240_type_tab;
    l_projfunc_rev_rate_date_tab  pa_fp_multi_currency_pkg.date_type_tab;
    l_projfunc_raw_cost_tab       pa_fp_multi_currency_pkg.number_type_tab;
    l_projfunc_burdened_cost_tab  pa_fp_multi_currency_pkg.number_type_tab;
    l_projfunc_revenue_tab        pa_fp_multi_currency_pkg.number_type_tab;
    l_projfunc_rejection_tab      pa_fp_multi_currency_pkg.char30_type_tab;
    l_proj_currency_code_tab      pa_fp_multi_currency_pkg.char240_type_tab;
    l_proj_cost_rate_type_tab     pa_fp_multi_currency_pkg.char240_type_tab;
    l_proj_cost_rate_tab          pa_fp_multi_currency_pkg.number_type_tab;
    l_proj_cost_rt_dt_typ_tab     pa_fp_multi_currency_pkg.char240_type_tab;
    l_proj_cost_rate_date_tab     pa_fp_multi_currency_pkg.date_type_tab;
    l_proj_rev_rate_type_tab      pa_fp_multi_currency_pkg.char240_type_tab;
    l_proj_rev_rate_tab           pa_fp_multi_currency_pkg.number_type_tab;
    l_proj_rev_rt_dt_typ_tab      pa_fp_multi_currency_pkg.char240_type_tab;
    l_proj_rev_rate_date_tab      pa_fp_multi_currency_pkg.date_type_tab;
    l_proj_raw_cost_tab           pa_fp_multi_currency_pkg.number_type_tab;
    l_proj_burdened_cost_tab      pa_fp_multi_currency_pkg.number_type_tab;
    l_proj_revenue_tab            pa_fp_multi_currency_pkg.number_type_tab;
    l_proj_rejection_tab          pa_fp_multi_currency_pkg.char30_type_tab;
    l_user_validate_flag_tab      pa_fp_multi_currency_pkg.char240_type_tab;
    l_status_flag_tab             pa_fp_multi_currency_pkg.char240_type_tab;

    l_return_status VARCHAR2(240);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);

    l_entire_return_status VARCHAR2(240);
    l_entire_msg_count NUMBER;
    l_entire_msg_data  VARCHAR2(2000);

    l_rowcount number;
    l_stage NUMBER;
    l_msg_index_out  NUMBER;

    Cursor cur_fp_cur_details IS
    Select c.projfunc_cost_exchange_rate
        ,c.projfunc_rev_exchange_rate
        ,c.project_cost_exchange_rate
        ,c.project_rev_exchange_rate
    From pa_fp_txn_currencies c
        where  c.fin_plan_version_id = p_budget_version_id
        and c.txn_currency_code = p_txn_currency_code;

    fp_cur_rec cur_fp_cur_details%rowtype;

    CURSOR rollup_lines IS
    select p_budget_line_id
        ,p_resource_assignment_id
        ,r.start_date
        ,r.end_date
        ,p_txn_currency_code
        ,nvl(p_txn_raw_cost,0)
        ,nvl(p_txn_burdened_cost,0)
        ,nvl(p_txn_revenue,0)
        ,nvl(r.projfunc_currency_code,pa_fp_multi_currency_pkg.g_projfunc_currency_code)
        ,nvl(r.projfunc_cost_rate_type,pa_fp_multi_currency_pkg.g_projfunc_cost_rate_type)
        ,DECODE(r.projfunc_cost_exchange_rate,null,
                                            DECODE(nvl(r.projfunc_cost_rate_type,pa_fp_multi_currency_pkg.g_projfunc_cost_rate_type),'User',
                                                                          fp_cur_rec.projfunc_cost_exchange_rate,
                                                                          r.projfunc_cost_exchange_rate),
                                            r.projfunc_cost_exchange_rate)
                                                                            projfunc_cost_exchange_rate
        ,DECODE(nvl(r.projfunc_cost_rate_type,pa_fp_multi_currency_pkg.g_projfunc_cost_rate_type),'User',Null,
                nvl(r.projfunc_cost_rate_date_type,pa_fp_multi_currency_pkg.g_projfunc_cost_rate_date_type))
        ,DECODE(nvl(r.projfunc_cost_rate_date_type,
                    pa_fp_multi_currency_pkg.g_projfunc_cost_rate_date_type),
                'START_DATE',r.start_date,
                'END_DATE'  ,r.end_date,
                nvl(r.projfunc_cost_rate_date,pa_fp_multi_currency_pkg.g_projfunc_cost_rate_date))
                                                         projfunc_cost_rate_date
        ,nvl(r.projfunc_rev_rate_type,pa_fp_multi_currency_pkg.g_projfunc_rev_rate_type)
        ,DECODE(r.projfunc_rev_exchange_rate,null,
                                            DECODE(nvl(r.projfunc_rev_rate_type,pa_fp_multi_currency_pkg.g_projfunc_rev_rate_type),'User',
                                                                          fp_cur_rec.projfunc_rev_exchange_rate,
                                                                          r.projfunc_rev_exchange_rate),
                                            r.projfunc_rev_exchange_rate)
                                                                            projfunc_rev_exchange_rate
        ,DECODE(nvl(r.projfunc_rev_rate_type,pa_fp_multi_currency_pkg.g_projfunc_rev_rate_type),'User',NULL,
                nvl(r.projfunc_rev_rate_date_type,pa_fp_multi_currency_pkg.g_projfunc_rev_rate_date_type))
        ,DECODE(nvl(r.projfunc_rev_rate_date_type,pa_fp_multi_currency_pkg.g_projfunc_rev_rate_date_type),
                'START_DATE',r.start_date,
                'END_DATE'  ,r.end_date,
                nvl(r.projfunc_rev_rate_date,pa_fp_multi_currency_pkg.g_projfunc_rev_rate_date))
                                                          projfunc_rev_rate_date
        ,nvl(r.project_currency_code,pa_fp_multi_currency_pkg.g_proj_currency_code)
        ,nvl(r.project_cost_rate_type,pa_fp_multi_currency_pkg.g_proj_cost_rate_type)
        ,DECODE(r.project_cost_exchange_rate,null,
                                            DECODE(nvl(r.project_cost_rate_type,pa_fp_multi_currency_pkg.g_proj_cost_rate_type),'User',
                                                                          fp_cur_rec.project_cost_exchange_rate,
                                                                          r.project_cost_exchange_rate),
                                            r.project_cost_exchange_rate)
                                                                            project_cost_exchange_rate
        ,DECODE(nvl(r.project_cost_rate_type,pa_fp_multi_currency_pkg.g_proj_cost_rate_type),'User',NULL,
                nvl(r.project_cost_rate_date_type,pa_fp_multi_currency_pkg.g_proj_cost_rate_date_type))
        ,DECODE(nvl(r.project_cost_rate_date_type,pa_fp_multi_currency_pkg.g_proj_cost_rate_date_type),
                'START_DATE',r.start_date,
                'END_DATE'  ,r.end_date,
                nvl(r.project_cost_rate_date,pa_fp_multi_currency_pkg.g_proj_cost_rate_date))
                                                          project_cost_rate_date
        ,nvl(r.project_rev_rate_type,pa_fp_multi_currency_pkg.g_proj_rev_rate_type)
        ,DECODE(r.project_rev_exchange_rate,null,
                                            DECODE(nvl(r.project_rev_rate_type,pa_fp_multi_currency_pkg.g_proj_rev_rate_type),'User',
                                                                          fp_cur_rec.project_rev_exchange_rate,
                                                                          r.project_rev_exchange_rate),
                                            r.project_rev_exchange_rate)
                                                                            project_rev_exchange_rate
        ,DECODE(nvl(r.project_rev_rate_type,pa_fp_multi_currency_pkg.g_proj_rev_rate_type),'User',NULL,
                nvl(r.project_rev_rate_date_type,pa_fp_multi_currency_pkg.g_proj_rev_rate_date_type))
        ,DECODE(nvl(r.project_rev_rate_date_type,pa_fp_multi_currency_pkg.g_proj_rev_rate_date_type),
                'START_DATE',r.start_date,
                'END_DATE'  ,r.end_date,
                nvl(r.project_rev_rate_date,pa_fp_multi_currency_pkg.g_proj_rev_rate_date))
                                                           project_rev_rate_date
        from pa_fp_rollup_tmp r
    where nvl(r.delete_flag,'N') = 'N'
        and r.budget_line_id = p_budget_line_id
    order by r.resource_assignment_id,
            r.start_date,
            r.txn_currency_code;

BEGIN
    IF p_pa_debug_mode = 'Y' Then
        pa_debug.init_err_stack('PA_FP_CALC_PLAN_PKG.convert_ra_txn_currency');
    End If;
    l_entire_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := 'S';
    l_msg_count := 0;
    l_msg_data  := NULL;
    x_return_status := 'S';
    x_msg_count := 0;
    x_msg_data  := NULL;

    -- Get default attributes for currency conversion from version level proj_fp_options
    l_stage := 6500;
    --print_msg(to_char(l_stage)||' ENTERED  convert_ra_txn_currency');

    fp_cur_rec := null;
    OPEN cur_fp_cur_details;
    FETCH cur_fp_cur_details INTO fp_cur_rec;
    IF cur_fp_cur_details%NOTFOUND Then
        fp_cur_rec := null;
    END IF;
    CLOSE cur_fp_cur_details;

    /*
    print_msg('ProjectCurr=> '||pa_fp_multi_currency_pkg.g_proj_currency_code);
    print_msg('ProjFuncCurr=> '||pa_fp_multi_currency_pkg.g_projfunc_currency_code);
    */
        l_stage := 6560;
        --print_msg(to_char(l_stage)||' In convert_ra_txn_currency');
        --Reset PL/SQL Tables.
       l_bl_id_tab.delete;
       l_resource_assignment_id_tab.delete;
       l_start_date_tab.delete;
       l_end_date_tab.delete;
       l_txn_currency_code_tab.delete;
       l_txn_raw_cost_tab.delete;
       l_txn_burdened_cost_tab.delete;
       l_txn_revenue_tab.delete;
       l_projfunc_currency_code_tab.delete;
       l_projfunc_cost_rate_type_tab.delete;
       l_projfunc_cost_rate_tab.delete;
       l_projfunc_cost_rt_dt_typ_tab.delete;
       l_projfunc_cost_rate_date_tab.delete;
       l_projfunc_rev_rate_type_tab.delete;
       l_projfunc_rev_rate_tab.delete;
       l_projfunc_rev_rt_dt_typ_tab.delete;
       l_projfunc_rev_rate_date_tab.delete;
       l_projfunc_raw_cost_tab.delete;
       l_projfunc_burdened_cost_tab.delete;
       l_projfunc_revenue_tab.delete;
       l_projfunc_rejection_tab.delete;
       l_proj_currency_code_tab.delete;
       l_proj_cost_rate_type_tab.delete;
       l_proj_cost_rate_tab.delete;
       l_proj_cost_rt_dt_typ_tab.delete;
       l_proj_cost_rate_date_tab.delete;
       l_proj_rev_rate_type_tab.delete;
       l_proj_rev_rate_tab.delete;
       l_proj_rev_rt_dt_typ_tab.delete;
       l_proj_rev_rate_date_tab.delete;
       l_proj_raw_cost_tab.delete;
       l_proj_burdened_cost_tab.delete;
       l_proj_revenue_tab.delete;
       l_proj_rejection_tab.delete;
       l_user_validate_flag_tab.delete;
       l_status_flag_tab.delete;

        l_stage := 6580;
        --print_msg(to_char(l_stage)||' In convert_ra_txn_currency Fetch rollup_lines cur');
    OPEN rollup_lines;
        FETCH rollup_lines BULK COLLECT
    INTO l_bl_id_tab
            ,l_resource_assignment_id_tab
            ,l_start_date_tab
            ,l_end_date_tab
            ,l_txn_currency_code_tab
            ,l_txn_raw_cost_tab
            ,l_txn_burdened_cost_tab
            ,l_txn_revenue_tab
            ,l_projfunc_currency_code_tab
            ,l_projfunc_cost_rate_type_tab
            ,l_projfunc_cost_rate_tab
            ,l_projfunc_cost_rt_dt_typ_tab
            ,l_projfunc_cost_rate_date_tab
            ,l_projfunc_rev_rate_type_tab
            ,l_projfunc_rev_rate_tab
            ,l_projfunc_rev_rt_dt_typ_tab
            ,l_projfunc_rev_rate_date_tab
            ,l_proj_currency_code_tab
            ,l_proj_cost_rate_type_tab
            ,l_proj_cost_rate_tab
            ,l_proj_cost_rt_dt_typ_tab
            ,l_proj_cost_rate_date_tab
            ,l_proj_rev_rate_type_tab
            ,l_proj_rev_rate_tab
            ,l_proj_rev_rt_dt_typ_tab
            ,l_proj_rev_rate_date_tab ;
    CLOSE rollup_lines;

    -- initialize --
        L_ROWCOUNT := NULL;
        L_ROWCOUNT := l_bl_id_tab.count;
    --print_msg(to_char(l_stage)||' Number of rows fetched into tab['||L_ROWCOUNT||']');
        IF l_rowcount > 0 THEN
            l_stage := 6590;
            --print_msg(to_char(l_stage)||' Calling pa_fp_multi_currency_pkg.conv_mc_bulk');
            pa_fp_multi_currency_pkg.conv_mc_bulk (
            p_resource_assignment_id_tab  => l_resource_assignment_id_tab
            ,p_start_date_tab              => l_start_date_tab
            ,p_end_date_tab                => l_end_date_tab
            ,p_txn_currency_code_tab       => l_txn_currency_code_tab
            ,p_txn_raw_cost_tab            => l_txn_raw_cost_tab
            ,p_txn_burdened_cost_tab       => l_txn_burdened_cost_tab
            ,p_txn_revenue_tab             => l_txn_revenue_tab
            ,p_projfunc_currency_code_tab  => l_projfunc_currency_code_tab
            ,p_projfunc_cost_rate_type_tab => l_projfunc_cost_rate_type_tab
            ,p_projfunc_cost_rate_tab      => l_projfunc_cost_rate_tab
            ,p_projfunc_cost_rate_date_tab => l_projfunc_cost_rate_date_tab
            ,p_projfunc_rev_rate_type_tab  => l_projfunc_rev_rate_type_tab
            ,p_projfunc_rev_rate_tab       => l_projfunc_rev_rate_tab
            ,p_projfunc_rev_rate_date_tab  => l_projfunc_rev_rate_date_tab
            ,x_projfunc_raw_cost_tab       => l_projfunc_raw_cost_tab
            ,x_projfunc_burdened_cost_tab  => l_projfunc_burdened_cost_tab
            ,x_projfunc_revenue_tab        => l_projfunc_revenue_tab
            ,x_projfunc_rejection_tab      => l_projfunc_rejection_tab
            ,p_proj_currency_code_tab      => l_proj_currency_code_tab
            ,p_proj_cost_rate_type_tab     => l_proj_cost_rate_type_tab
            ,p_proj_cost_rate_tab          => l_proj_cost_rate_tab
            ,p_proj_cost_rate_date_tab     => l_proj_cost_rate_date_tab
            ,p_proj_rev_rate_type_tab      => l_proj_rev_rate_type_tab
            ,p_proj_rev_rate_tab           => l_proj_rev_rate_tab
            ,p_proj_rev_rate_date_tab      => l_proj_rev_rate_date_tab
            ,x_proj_raw_cost_tab           => l_proj_raw_cost_tab
            ,x_proj_burdened_cost_tab      => l_proj_burdened_cost_tab
            ,x_proj_revenue_tab            => l_proj_revenue_tab
            ,x_proj_rejection_tab          => l_proj_rejection_tab
            ,p_user_validate_flag_tab      => l_user_validate_flag_tab
            ,x_return_status               => l_return_status
            ,x_msg_count                   => l_msg_count
            ,x_msg_data                    => l_msg_data);

            l_entire_msg_count := nvl(l_entire_msg_count,0) + nvl(l_msg_count,0);
            l_entire_msg_data  := l_msg_data;
        --print_msg('After calling pa_fp_multi_currency_pkg.conv_mc_bulk msgData['||l_msg_data||'RetSts['||l_return_status||']msgCt['||l_msg_count||']');

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    l_stage := 6600;
                    print_msg(to_char(l_stage)||' Errored In convert_ra_txn_currency');
                    l_entire_return_status := l_return_status;
            END IF;

            l_stage := 6610;
            --print_msg(to_char(l_stage)||' In convert_ra_txn_currency');
                -- initialize --
                x_projfunc_currency_code    := NULL;
                x_projfunc_raw_cost         := NULL;
                x_projfunc_burdened_cost    := NULL;
                x_projfunc_revenue          := NULL;
                x_projfunc_rejection_code   := NULL;
                x_project_currency_code     := NULL;
                x_project_raw_cost          := NULL;
                x_project_burdened_cost     := NULL;
                x_project_revenue           := NULL;
                x_project_rejection_code    := NULL;

                FOR i in 1..l_rowcount LOOP
                    x_projfunc_currency_code    := l_projfunc_currency_code_tab(i);
                    x_projfunc_raw_cost         := l_projfunc_raw_cost_tab(i);
                    x_projfunc_burdened_cost    := l_projfunc_burdened_cost_tab(i);
                    x_projfunc_revenue          := l_projfunc_revenue_tab(i);
                    x_projfunc_rejection_code   := l_projfunc_rejection_tab(i);
                    x_project_currency_code     := l_proj_currency_code_tab(i);
                    x_project_raw_cost          := l_proj_raw_cost_tab(i);
                    x_project_burdened_cost     := l_proj_burdened_cost_tab(i);
                    x_project_revenue           := l_proj_revenue_tab(i);
                    x_project_rejection_code    := l_proj_rejection_tab(i);
                END LOOP;
        END IF; -- rowcount > 0
    x_return_status := l_entire_return_status;
    x_msg_count := l_msg_count;
    x_msg_data := l_msg_data;
    --print_msg('End of convert_ra_txn_currency retSts['||x_return_status||']');
    IF p_pa_debug_mode = 'Y' Then
        pa_debug.reset_err_stack;
    End If;


EXCEPTION
    WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := sqlcode||sqlerrm;
            fnd_msg_pub.add_exc_msg
            ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                ,p_procedure_name => 'convert_ra_txn_currency' );
            pa_debug.g_err_stage := 'Stage : '||to_char(l_stage)||' '||substr(SQLERRM,1,240);
            print_msg('PA_FP_CALC_PLAN_PKG.convert_ra_txn_currency -- Stage : ' ||to_char(l_stage)||' '||substr(SQLERRM,1,240));
        IF p_pa_debug_mode = 'Y' Then
                pa_debug.reset_err_stack;
        End If;
            RAISE;
END convert_ra_txn_currency;

/* This API checks whether the actuals present on the budget line for the given resource
 * assignment Id
 */
PROCEDURE check_actual_exists(p_res_ass_id  IN NUmber
          ,p_start_date  IN date default NULL
          ,p_end_date    IN date default NULL
                  ,x_actual_flag OUT NOCOPY varchar2 ) IS

    cursor getActualBlLines IS
    select 'Y'
    from dual
    where EXISTS
        (select null
         from pa_budget_lines bl
         where bl.resource_assignment_id = p_res_ass_id
         and (bl.init_quantity is not null
                     or bl.txn_init_raw_cost is not null
             or bl.txn_init_burdened_cost is not null
             or bl.txn_init_revenue is not null )
        );
BEGIN
    x_actual_flag := 'N';
    OPEN getActualBlLines;
    FETCH getActualBlLines INTO x_actual_flag;
    CLOSE getActualBlLines;
    IF x_actual_flag is NULL Then
       x_actual_flag := 'N';
    End IF;
    Return;
END check_actual_exists;

/* This API deletes all the budget lines when no quantiy , amounts exists on the budget lines
 * retaining these budget lines create issues during the workplan mode
 * keeping these budget lines will retain the currency code during the resource assignment updates
 */
PROCEDURE Delete_BL_Where_Nulls
                        ( p_budget_version_id        IN  NUmber
                    	,p_resource_assignment_tab   IN  SYSTEM.pa_num_tbl_type   DEFAULT SYSTEM.pa_num_tbl_type()
                        ,x_return_status             OUT NOCOPY varchar2
                        ,x_msg_data                  OUT NOCOPY varchar2
                         ) IS

    	/*Perf Changes: Removed update and added a cusor to fetch the ra+txn currency
	 *This reduces teh cpu time from 350sec to 11sec tested on pjperf instance
         */
	cursor cur_nullBls is
	select tmp1.resource_assignment_id
        	,tmp1.txn_currency_code
        from pa_fp_spread_calc_tmp tmp1
        	,pa_resource_assignments ra
        where tmp1.budget_version_id = p_budget_version_id
        and ra.resource_assignment_id = tmp1.resource_assignment_id
        and NVL(ra.rate_based_flag,'N') = 'N'
        and NOT EXISTS ( select /*+ INDEX(BL PA_BUDGET_LINES_U1) */ null
        	from pa_budget_lines bl
        	where bl.resource_assignment_id = tmp1.resource_assignment_id
        	and bl.txn_currency_code = tmp1.txn_currency_code
        	)
	group by tmp1.resource_assignment_id
                ,tmp1.txn_currency_code;

    l_budget_line_id_tab     pa_plsql_datatypes.IdTabTyp;
    l_raid_tab           pa_plsql_datatypes.IdTabTyp;
    l_txn_cur_code_tab       pa_plsql_datatypes.Char30TabTyp;
    l_start_date_tab         pa_plsql_datatypes.DateTabTyp;
    l_end_date_tab       pa_plsql_datatypes.DateTabTyp;
    l_period_name_tab        pa_plsql_datatypes.Char80TabTyp;
    l_proj_cur_code_tab      pa_plsql_datatypes.Char30TabTyp;
    l_projfunc_cur_code_tab  pa_plsql_datatypes.Char30TabTyp;

BEGIN
    x_return_status := 'S';
    x_msg_data := NULL;
    l_budget_line_id_tab.delete;
    /* Bug fix:4272944 Starts */
    IF ( NVL(g_baseline_funding_flag,'N') = 'Y'
            AND NVL(g_bv_approved_rev_flag,'N') = 'Y' ) THEN
               print_msg('Bug fix:4272944: DONOT DELETE AUTOBASELINE zero qty budget lines');
               null;
        /* Bug fix:4272944 Ends */
    ELSIF p_resource_assignment_tab.COUNT > 0 THEN
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Delete all the budget lines where Qty and Amounts are not exists');
	End If;
    l_budget_line_id_tab.delete;
    l_raid_tab.delete;
    l_txn_cur_code_tab.delete;
    l_start_date_tab.delete;
    l_end_date_tab.delete;
    l_period_name_tab.delete;
    l_proj_cur_code_tab.delete;
    l_projfunc_cur_code_tab.delete;
        FORALL i IN p_resource_assignment_tab.FIRST .. p_resource_assignment_tab.LAST
        DELETE FROM pa_budget_lines bl
        WHERE bl.resource_assignment_id = p_resource_assignment_tab(i)
        AND   bl.budget_version_id = p_budget_version_id
        AND   ( nvl(bl.quantity,0) = 0
              and nvl(bl.txn_raw_cost,0) = 0
              and nvl(bl.txn_burdened_cost,0) = 0
              and nvl(bl.txn_revenue,0) = 0
              and nvl(bl.init_quantity,0) = 0
              and nvl(bl.txn_init_raw_cost,0) = 0
              and nvl(bl.txn_init_burdened_cost,0) = 0
              and nvl(bl.txn_init_revenue,0) = 0
             )
        RETURNING bl.budget_line_id
        ,bl.resource_assignment_id
        ,bl.txn_currency_code
        ,bl.start_date
        ,bl.end_date
        ,bl.period_name
        ,bl.project_currency_code
        ,bl.projfunc_currency_code
        BULK COLLECT INTO
         l_budget_line_id_tab
    ,l_raid_tab
        ,l_txn_cur_code_tab
        ,l_start_date_tab
        ,l_end_date_tab
        ,l_period_name_tab
        ,l_proj_cur_code_tab
        ,l_projfunc_cur_code_tab;

	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Number of rows deleted ['||l_budget_line_id_tab.count||']');
	End If;
     IF l_budget_line_id_tab.COUNT > 0 THEN --{
        FOR i IN l_budget_line_id_tab.FIRST .. l_budget_line_id_tab.LAST LOOP
           /* Added for MRC enhancements */
               IF NVL(G_populate_mrc_tab_flag,'N') = 'Y' Then
                        Populate_MRC_plsqlTabs
                                (p_calling_module               => 'CALCULATE_API'
                                ,p_budget_version_id            => p_budget_version_id
                                ,p_budget_line_id               => l_budget_Line_id_tab(i)
                                ,p_resource_assignment_id       => l_raid_tab(i)
                                ,p_start_date                   => l_start_date_tab(i)
                                ,p_end_date                     => l_end_date_tab(i)
                                ,p_period_name                  => l_period_name_tab(i)
                                ,p_txn_currency_code            => l_txn_cur_code_tab(i)
                                ,p_project_currency_code        => l_proj_cur_code_tab(i)
                                ,p_projfunc_currency_code       => l_projfunc_cur_code_tab(i)
                                ,p_delete_flag                  => 'Y'
                                ,x_msg_data                     => x_msg_data
                                ,x_return_status                => x_return_status
                                );
               END IF;
        END LOOP;
     END IF; --}
       END IF;

	/* Added this check to ensure that for non-rate base resource if no budget lines exists
	* then null out the rate overrides from new entity
	*/
	If nvl(g_wp_version_flag,'N') <> 'Y' AND g_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION') then
		l_raid_tab.delete;
    		l_txn_cur_code_tab.delete;
		OPEN cur_nullBls;
		FETCH cur_nullBls BULK COLLECT INTO
		l_raid_tab
		,l_txn_cur_code_tab;
		CLOSE cur_nullBls;

		IF l_raid_tab.COUNT > 0 Then
		  FORALL i IN l_raid_tab.FIRST .. l_raid_tab.LAST
		  UPDATE /*+ INDEX(RTX PA_RESOURCE_ASGN_CURR_U2) */ pa_resource_asgn_curr rtx
        	  SET rtx.TXN_RAW_COST_RATE_OVERRIDE  = null
            		,rtx.TXN_BURDEN_COST_RATE_OVERRIDE = null
            		,rtx.TXN_BILL_RATE_OVERRIDE = null
        	  WHERE rtx.resource_assignment_id = l_raid_tab(i)
		  AND  rtx.txn_currency_code = l_txn_cur_code_tab(i);

		END IF;
		--print_msg('Number of rows updated for setting null rates['||sql%rowcount||']');
	End If;

	/* Bug fix:5920547: Ideally, this fix should have been put in pa_res_asg_currency_pub.maintain_data().
         * When a calculate API is called, it derives the transaction currency based on the rate schedule setup,
         * and it updates the passed in the txn currency with the rate scheduel currency.
	 * while rollup the amounts, the maintain data() api should update the existing RA+TXN currency,
	 * instead of deleting the old records and creating the new records.
	 * Fix required: In order to fix this issue, calculate api should keep track of old txn currency and new txn currency
	 * per planning resource and then call the maintain_data() api by passing old txn currency to delete and create
	 * record with new txn currency.
	 * Proposal:
         * since the amount of effort reqd to fix is more. adding simple delete of records from new entity
         * for workplan context where quantity is null, and rates are null.
         * This issue happens only for workplan when PC <> PFC and for initial creation of task assignment
        */
        If nvl(g_wp_version_flag,'N') = 'Y' AND g_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION') then
                If g_source_context = 'RESOURCE_ASSIGNMENT' OR g_time_phased_code = 'N'  Then
                 FOR i IN p_resource_assignment_tab.FIRST .. p_resource_assignment_tab.LAST LOOP
                    DELETE FROM pa_resource_asgn_curr rbc
                    WHERE  rbc.budget_version_id = p_budget_version_id
                    AND   rbc.resource_assignment_id = p_resource_assignment_tab(i)
                    AND EXISTS ( SELECT null
                         FROM   pa_budget_lines bl
                         WHERE  bl.resource_assignment_id = rbc.resource_assignment_id
                         AND    bl.txn_currency_code <> rbc.txn_currency_code )
                    AND rbc.total_quantity is NULL
                    AND rbc.total_init_quantity is NULL
                    AND rbc.txn_raw_cost_rate_override is NULL
                    AND rbc.txn_burden_cost_rate_override is NULL
                        ;
                         print_msg('Number of rows deleted from new entity['||sql%rowcount||']');
                 END LOOP;
                End If;
        End If;


EXCEPTION
    WHEN OTHERS THEN
        x_return_status := 'U';
        x_msg_data := substr(SQLCODE||SQLERRM,1,250);
        print_msg('Unexpected error occured in Delete_BL_Where_Nulls['||x_msg_data||']');
        RAISE;

END Delete_BL_Where_Nulls;

/*
* This is main API interface called from self-service and AMG packages
* When the API is called from page/AMG, the api compares the values in params
* with the actual budget lines and stores the diff in addl_tab columns
* based on the addl_tab columns the calculate derives the rates and calls
* reporting and rollup pkgs.
* The following are the must required params
* p_project_id                  Required
* p_budget_version_id       Required
* p_source_context              Required  possible values are 'RESOURCE_ASSIGNMENT' or 'BUDGET_LINE'
* p_calling_module              Required  possible values are  'UPDATE_PLAN_TRANSACTION' / 'BUDGET_GENERATION','FORECAST_GENERATION'
* p_activity_code       Required  possible values are  'CALCULATE'
* If p_mass_adjust_flag  is passed as 'Y' then following one-of the params must be passed
*   p_quantity_adj_pct
*   p_cost_rate_adj_pct
*   p_burdened_rate_adj_pct
*   p_bill_rate_adj_pct
* The following are the valid values for p_refresh_rates_flag
*      'Y'     -- Refresh all Raw cost,burden cost and revenue amounts
*      'C'     -- Refresh only Raw cost and burden cost amounts but retain the Revenue amounts
*      'R'     -- Refresh only Revenue amounts
*      'N'     -- No Refresh
*  Note: The values ('C' and 'R' is valid only in calling module = 'BUDGET_GENERATION' and 'FORECAST_GENERATION' )
* the following params are only for internal purposes, the values passed from AMG or page will be ignored
*   p_addl_qty_tab,p_addl_raw_cost_tab,p_addl_burdened_cost_tab,p_addl_revenue_tab
*
*/
PROCEDURE calculate (  p_project_id                    IN  pa_projects_all.project_id%TYPE
                      ,p_budget_version_id             IN  pa_budget_versions.budget_version_id%TYPE
                      ,p_refresh_rates_flag            IN  VARCHAR2 := 'N'
                      ,p_refresh_conv_rates_flag       IN  VARCHAR2 := 'N'
                      ,p_spread_required_flag          IN  VARCHAR2 := 'Y'
                      ,p_conv_rates_required_flag      IN  VARCHAR2 := 'Y'
                      ,p_rollup_required_flag          IN  VARCHAR2 := 'Y'
                      ,p_mass_adjust_flag              IN  VARCHAR2 := 'N'
                      ,p_apply_progress_flag           IN  VARCHAR2 := 'N'
                      ,p_wp_cost_changed_flag          IN  VARCHAR2 := 'N'
                      ,p_time_phase_changed_flag       IN  VARCHAR2 := 'N'
                      ,p_quantity_adj_pct              IN  NUMBER   := NULL
                      ,p_cost_rate_adj_pct             IN  NUMBER   := NULL
                      ,p_burdened_rate_adj_pct         IN  NUMBER   := NULL
                      ,p_bill_rate_adj_pct             IN  NUMBER   := NULL
		      ,p_raw_cost_adj_pct              IN  NUMBER   := NULL
                      ,p_burden_cost_adj_pct           IN  NUMBER   := NULL
                      ,p_revenue_adj_pct               IN  NUMBER   := NULL
                      ,p_source_context                IN  pa_fp_res_assignments_tmp.source_context%TYPE
                      ,p_calling_module                IN  VARCHAR2  DEFAULT   'UPDATE_PLAN_TRANSACTION'
                      ,p_activity_code                 IN  VARCHAR2  DEFAULT   'CALCULATE'
                      ,p_resource_assignment_tab       IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_delete_budget_lines_tab       IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
                      ,p_spread_amts_flag_tab          IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
                      ,p_txn_currency_code_tab         IN  SYSTEM.pa_varchar2_15_tbl_type    DEFAULT SYSTEM.pa_varchar2_15_tbl_type()
                      ,p_txn_currency_override_tab     IN  SYSTEM.pa_varchar2_15_tbl_type    DEFAULT SYSTEM.pa_varchar2_15_tbl_type()
                      ,p_total_qty_tab                 IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_addl_qty_tab                  IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_total_raw_cost_tab            IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_addl_raw_cost_tab             IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_total_burdened_cost_tab       IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_addl_burdened_cost_tab        IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_total_revenue_tab             IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_addl_revenue_tab              IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_raw_cost_rate_tab             IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_rw_cost_rate_override_tab     IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_b_cost_rate_tab               IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_b_cost_rate_override_tab      IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_bill_rate_tab                 IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_bill_rate_override_tab        IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_line_start_date_tab           IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
                      ,p_line_end_date_tab             IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
              /* Added for Spread enhancements */
                      ,p_mfc_cost_type_id_old_tab      IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_mfc_cost_type_id_new_tab      IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_spread_curve_id_old_tab       IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_spread_curve_id_new_tab       IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_sp_fixed_date_old_tab         IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
                      ,p_sp_fixed_date_new_tab         IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
                      ,p_plan_start_date_old_tab       IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
                      ,p_plan_start_date_new_tab       IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
                      ,p_plan_end_date_old_tab         IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
                      ,p_plan_end_date_new_tab         IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
                      ,p_re_spread_flag_tab            IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
                      ,p_rlm_id_change_flag_tab        IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
                      ,p_del_spread_calc_tmp1_flg      IN  VARCHAR2 := 'Y' /* Bug: 4309290.Added the parameter to identify if
                                                                           PA_FP_SPREAD_CALC_TMP1 is to be deleted or not. Frm AMG flow
                                                                           we will pass N and for other calls to calculate api it would
                                                                           be yes */
              ,p_fp_task_billable_flag_tab     IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type() /* default 'D' */
              ,p_clientExtn_api_call_flag      IN  VARCHAR2 DEFAULT 'Y'
              ,p_raTxn_rollup_api_call_flag    IN  VARCHAR2 DEFAULT 'Y' /* Bug fix:4900436 */
                      ,x_return_status                 OUT NOCOPY VARCHAR2
                      ,x_msg_count                     OUT NOCOPY NUMBER
                      ,x_msg_data                      OUT VARCHAR2) IS

    l_tab_count            NUMBER;
    l_stage                NUMBER;
    l_debug_mode           VARCHAR2(30);
    l_delete_budget_lines  VARCHAR2(1);
    l_return_status        VARCHAR2(240);
    l_entire_return_status VARCHAR2(240);
    l_msg_index_out        NUMBER;
    l_txn_init_quantity    Number;
    l_fp_cols_rec          PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
    l_calling_module       Varchar2(240) := NVL(p_calling_module,'UPDATE_PLAN_TRANSACTION');
    l_activity_code        varchar2(240) := NVL(p_activity_code,'CALCULATE');

    l_apply_progress_flag  varchar2(20) := 'N';
    l_countr        NUMBER ;
    l_message_name         VARCHAR2(100);

-- TABLE IN LOCAL VARIABLES
  l_resource_assignment_tab         SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_delete_budget_lines_tab         SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_spread_amts_flag_tab            SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_txn_currency_code_tab           SYSTEM.pa_varchar2_15_tbl_type    DEFAULT SYSTEM.pa_varchar2_15_tbl_type();
  l_txn_currency_override_tab       SYSTEM.pa_varchar2_15_tbl_type    DEFAULT SYSTEM.pa_varchar2_15_tbl_type();
  l_total_qty_tab                   SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_addl_qty_tab                    SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_total_raw_cost_tab              SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_addl_raw_cost_tab               SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_total_burdened_cost_tab         SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_addl_burdened_cost_tab          SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_total_revenue_tab               SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_addl_revenue_tab                SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_raw_cost_rate_tab               SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_rw_cost_rate_override_tab       SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_b_cost_rate_tab                 SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_b_cost_rate_override_tab        SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_bill_rate_tab                   SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_bill_rate_override_tab          SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_line_start_date_tab             SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type();
  l_line_end_date_tab               SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type();
  l_spread_curve_id_old_tab         SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_spread_curve_id_new_tab         SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_sp_fixed_date_old_tab           SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type();
  l_sp_fixed_date_new_tab           SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type();
  l_plan_start_date_old_tab         SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type();
  l_plan_start_date_new_tab         SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type();
  l_plan_end_date_old_tab           SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type();
  l_plan_end_date_new_tab           SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type();
  l_re_spread_flag_tab              SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_sp_curve_change_flag_tab        SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_plan_dates_change_flag_tab      SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_spfix_date_flag_tab             SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_mfc_cost_type_id_old_tab        SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_mfc_cost_type_id_new_tab        SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type();
  l_mfc_cost_change_flag_tab        SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_rlm_id_change_flag_tab          SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_plan_sdate_shrunk_flag_tab      SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_plan_edate_shrunk_flag_tab      SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_mfc_cost_refresh_flag_tab       SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_ra_in_multi_cur_flag_tab        SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_fp_task_billable_flag_tab       SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();

  l_quantity_changed_flag_tab       SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_raw_cost_changed_flag_tab       SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_cost_rate_changed_flag_tab      SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_burden_cost_changed_flag_tab    SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_burden_rate_changed_flag_tab    SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_rev_changed_flag_tab            SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_bill_rate_changed_flag_tab      SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_multicur_plan_start_date_tab    SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type();
  l_multicur_plan_end_date_tab      SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type();

  l_cost_rt_miss_num_flag_tab       SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_burd_rt_miss_num_flag_tab       SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_bill_rt_miss_num_flag_tab       SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_Qty_miss_num_flag_tab	    SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_Rw_miss_num_flag_tab	    SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_Br_miss_num_flag_tab	    SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_Rv_miss_num_flag_tab	    SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_rev_only_entry_flag_tab         SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();

  /* bug fix:5726773 */
  l_neg_Qty_Changflag_tab         SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_neg_Raw_Changflag_tab         SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_neg_Burd_Changflag_tab         SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
  l_neg_rev_Changflag_tab         SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type();

    --pa_resource_assignemts local variables--
    l_resource_assignment_id           pa_resource_assignments.resource_assignment_id%TYPE;
    l_planning_start_date              pa_resource_assignments.planning_start_date%TYPE;
    l_planning_end_date                pa_resource_assignments.planning_end_date%TYPE;
    l_spread_curve_id                  pa_resource_assignments.spread_curve_id%TYPE;
    l_resource_class_code              pa_resource_assignments.resource_class_code%TYPE;
    l_sp_fixed_date                    pa_resource_assignments.sp_fixed_date%TYPE;
    l_rate_based_flag                  pa_resource_assignments.rate_based_flag%TYPE;
    -- end of pa_resource_assignemts local variables--

    l_txn_currency_code                pa_fp_res_assignments_tmp.txn_currency_code%TYPE;
    l_txn_revenue                      pa_fp_res_assignments_tmp.txn_revenue%TYPE;
    l_txn_revenue_addl                 pa_fp_res_assignments_tmp.txn_revenue_addl%TYPE;
    l_txn_raw_cost                     pa_fp_res_assignments_tmp.txn_raw_cost%TYPE;
    l_txn_raw_cost_addl                pa_fp_res_assignments_tmp.txn_raw_cost_addl%TYPE;
    l_txn_burdened_cost                pa_fp_res_assignments_tmp.txn_burdened_cost%TYPE;
    l_txn_burdened_cost_addl           pa_fp_res_assignments_tmp.txn_burdened_cost_addl%TYPE;
    l_txn_plan_quantity                pa_fp_res_assignments_tmp.txn_plan_quantity%TYPE;
    l_txn_plan_quantity_addl           pa_fp_res_assignments_tmp.txn_plan_quantity_addl%TYPE;
    l_txn_currency_code_override       pa_fp_res_assignments_tmp.txn_currency_code_override%TYPE;
    l_txn_init_revenue                 pa_fp_res_assignments_tmp.txn_init_revenue%TYPE;
    l_txn_init_revenue_addl            pa_fp_res_assignments_tmp.txn_init_revenue_addl%TYPE;
    l_txn_init_raw_cost                pa_fp_res_assignments_tmp.txn_init_raw_cost%TYPE;
    l_txn_init_raw_cost_addl           pa_fp_res_assignments_tmp.txn_init_raw_cost_addl%TYPE;
    l_txn_init_burdened_cost           pa_fp_res_assignments_tmp.txn_init_burdened_cost%TYPE;
    l_txn_init_burdened_cost_addl      pa_fp_res_assignments_tmp.txn_init_burdened_cost_addl%TYPE;
    l_init_quantity                    pa_fp_res_assignments_tmp.init_quantity%TYPE;
    l_init_quantity_addl               pa_fp_res_assignments_tmp.init_quantity_addl%TYPE;
    l_spread_amounts_flag              pa_fp_res_assignments_tmp.spread_amounts_flag%TYPE;
    l_raw_cost_rate                    pa_fp_res_assignments_tmp.raw_cost_rate%TYPE;
    l_rw_cost_rate_override            pa_fp_res_assignments_tmp.rw_cost_rate_override%TYPE;
    l_burden_cost_rate                 pa_fp_res_assignments_tmp.burden_cost_rate%TYPE;
    l_burden_cost_rate_override        pa_fp_res_assignments_tmp.burden_cost_rate_override%TYPE;
    l_bill_rate                        pa_fp_res_assignments_tmp.bill_rate%TYPE;
    l_bill_rate_override               pa_fp_res_assignments_tmp.bill_rate_override%TYPE;
    l_org_id                           pa_projects_all.org_id%TYPE;

    l_cost_rt_miss_num_flag            VARCHAR2(1) := NULL;
    l_burd_rt_miss_num_flag            VARCHAR2(1) := NULL;
    l_bill_rt_miss_num_flag     VARCHAR2(1) := NULL;


    --pa_budget_lines local variables---
    l_budget_line_id                   pa_budget_lines.budget_line_id%TYPE;
    l_bl_quantity                      pa_budget_lines.quantity%TYPE;
    l_bl_raw_cost_rate                 pa_budget_lines.txn_standard_cost_rate%TYPE;
    l_bl_standard_cost_rate            pa_budget_lines.txn_standard_cost_rate%TYPE;
    l_bl_cost_rate_override            pa_budget_lines.txn_cost_rate_override%TYPE;
    l_bl_raw_cost                      pa_budget_lines.txn_raw_cost%TYPE;
    l_bl_avg_burden_cost_rate          pa_budget_lines.burden_cost_rate%TYPE;
    l_bl_burden_cost_rate              pa_budget_lines.burden_cost_rate%TYPE;
    l_bl_burden_cost_rate_override     pa_budget_lines.burden_cost_rate_override%TYPE;
    l_bl_burdened_cost                 pa_budget_lines.txn_burdened_cost%TYPE;
    l_bl_bill_rate                     pa_budget_lines.txn_standard_bill_rate%TYPE;
    l_bl_standard_bill_rate            pa_budget_lines.txn_standard_bill_rate%TYPE;
    l_bl_bill_rate_override            pa_budget_lines.txn_bill_rate_override%TYPE;
    l_bl_revenue                       pa_budget_lines.txn_revenue%TYPE;

    l_actual_exists_flag               VARCHAR2(60);
    l_resAttribChangeFlag              VARCHAR2(1) := 'N';
    l_multicur_plan_start_date         DATE;
    l_multicur_plan_end_date         DATE;

    l_num_rowsdeleted    Number := 0;
    blrec   get_bl_date_csr%ROWTYPE;

    CURSOR get_p_res_asn_curr_code IS
        SELECT resource_assignment_id
            ,txn_currency_code
        FROM pa_budget_lines bl
        WHERE bl.budget_version_id = p_budget_version_id
    GROUP BY resource_assignment_id,txn_currency_code;

    CURSOR get_proj_fp_options_csr IS
        SELECT nvl(pfo.use_planning_rates_flag,'N') use_planning_rates_flag
          ,decode(nvl(bv.wp_version_flag,'N'),'Y',NVL(pfo.track_workplan_costs_flag,'N'),'Y') track_workplan_costs_flag
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
      ,bv.project_structure_version_id
      ,bv.project_id
      ,pp.project_currency_code
      ,pp.projfunc_currency_code
      ,pp.segment1  project_Name
      ,bv.ci_id     CiId
      /*Bugfix:4272944 */
          ,NVL(pp.baseline_funding_flag,'N') baseline_funding_flag
        FROM pa_proj_fp_options pfo
            ,pa_budget_versions bv
        ,pa_projects_all pp
        WHERE pfo.fin_plan_version_id = bv.budget_version_id
    AND  bv.project_id = pp.project_id
        AND bv.budget_version_id = p_budget_version_id;
    ProjFpOptRec    get_proj_fp_options_csr%ROWTYPE;


    CURSOR get_bl_currency IS
        SELECT txn_currency_code
        FROM  pa_budget_lines
        WHERE  resource_assignment_id = l_resource_assignment_id
    ORDER BY start_date;

    CURSOR get_resource_asn_csr (p_resource_asg_id IN NUMBER) IS
        SELECT ra.resource_assignment_id
           ,ra.budget_version_id
           ,ra.project_id
           ,ra.task_id
           ,ra.resource_list_member_id
           ,ra.planning_start_date
           ,ra.planning_end_date
           ,ra.spread_curve_id
           ,ra.etc_method_code
           ,ra.resource_class_code
           ,ra.mfc_cost_type_id
           ,ra.sp_fixed_date
           ,ra.rate_based_flag
       ,rl.alias  Resource_Name
        FROM pa_resource_assignments ra
        ,pa_resource_list_members rl
        WHERE ra.resource_assignment_id = p_resource_asg_id
    AND  ra.resource_list_member_id = rl.resource_list_member_id ;
    ResAsgnRec    get_resource_asn_csr%ROWTYPE;

    -- --Bug 6781055. Added rowid in the cursor
    CURSOR get_client_xtn_rollup_csr IS
        SELECT tmp.rowid
           ,tmp.budget_line_id
           ,tmp.resource_assignment_id
           ,tmp.txn_currency_code
           ,tmp.start_date
           ,tmp.end_date
           ,tmp.period_name
           ,tmp.quantity
           ,tmp.txn_raw_cost
       ,tmp.cost_rate
       ,tmp.rw_cost_rate_override
           ,tmp.txn_burdened_cost
       ,tmp.burden_cost_rate
       ,tmp.burden_cost_rate_override
           ,tmp.txn_revenue
       ,tmp.bill_rate
       ,tmp.bill_rate_override
           ,tmp.pm_product_code
       ,bv.version_type
       ,ra.resource_list_member_id
       ,ra.rate_based_flag
       ,ra.task_id
       ,rl.resource_id
        ,tmp.cost_rejection_code
    ,tmp.burden_rejection_code
    ,tmp.revenue_rejection_code
        -- Bug 6781055
        ,tmp.init_quantity
        ,tmp.txn_init_raw_cost
        ,tmp.txn_init_burdened_cost
        ,tmp.txn_init_revenue
        -- End for 6781055
        FROM pa_fp_rollup_tmp tmp
        ,pa_budget_versions bv
        ,pa_resource_assignments ra
        ,pa_resource_list_members rl
    WHERE bv.budget_version_id = p_budget_version_id
    AND   ra.budget_version_id = bv.budget_version_id
    AND   tmp.resource_assignment_id = ra.resource_assignment_id
    AND   ra.resource_list_member_id = rl.resource_list_member_id
        ORDER BY tmp.resource_assignment_id
        ,tmp.start_date
        ,tmp.txn_currency_code;

    -------------------------------- cursors for rate api variables-------------------
    ---error code cursor---
    CURSOR get_line_info (p_resource_assignment_id IN NUMBER) IS
        SELECT pt.name task_name
               ,prl.alias resource_name
        FROM pa_proj_elements pt
               ,pa_resource_list_members prl
               ,pa_resource_assignments pra
        WHERE pra.resource_assignment_id = p_resource_assignment_id
        AND pt.proj_element_id(+) = pra.task_id
        AND prl.resource_list_member_id = pra.resource_list_member_id;

    l_bdgt_line_sDate       Date := NULL;
        l_bdgt_line_eDate       Date := NULL;
    l_quantity_changed_flag     Varchar2(10) := 'N';
        l_raw_cost_changed_flag     Varchar2(10) := 'N';
        l_rw_cost_rate_changed_flag     Varchar2(10) := 'N';
        l_burden_cost_changed_flag  Varchar2(10) := 'N';
        l_b_cost_rate_changed_flag  Varchar2(10) := 'N';
        l_rev_changed_flag      Varchar2(10) := 'N';
        l_bill_rate_changed_flag    Varchar2(10) := 'N';
        l_bill_rt_ovr_changed_flag  Varchar2(10) := 'N';
        l_bl_init_raw_cost      Number;
        l_bl_init_burdened_cost     Number;
        l_bl_init_revenue       Number;
        l_bl_init_quantity      Number;
    l_agreement_cur_code        Varchar2(15);

        l_curr_burden_rate      Number := NULL; -- IPM
        l_curr_bill_rate        Number := NULL; -- IPM
	l_curr_cost_rate        Number := NULL; -- bug fix:5726773
    l_curr_markup_percentage Number := NULL; --IPM
    /* Bug fix:4263265 the following variables declared to keep track of what is changed before deleteing
         * after deleting budget lines. these variables stores the original changed values passed to calculate
         * by comparing with the budget lines */
    l_org_quantity_changed_flag     Varchar2(10) := 'N';
        l_org_raw_cost_changed_flag     Varchar2(10) := 'N';
        l_org_rw_rate_changed_flag      Varchar2(10) := 'N';
        l_org_burden_cost_changed_flag  Varchar2(10) := 'N';
        l_org_b_cost_rate_changed_flag  Varchar2(10) := 'N';
        l_org_rev_changed_flag          Varchar2(10) := 'N';
        l_org_bill_rate_changed_flag    Varchar2(10) := 'N';
    l_generation_context            Varchar2(50) := 'SPREAD';

    l_re_spread_amts_flag       Varchar2(10) := 'N';
        l_sp_curve_change_flag      Varchar2(10) := 'N';
        l_plan_dates_change_flag    Varchar2(10) := 'N';
        l_spfix_date_change_flag    Varchar2(10) := 'N';
        l_mfc_cost_change_flag      Varchar2(10) := 'N';
        l_rlm_id_change_flag        Varchar2(10) := 'N';
        l_plan_sdate_shrunk_flag    Varchar2(10) := 'N';
        l_plan_edate_shrunk_flag    Varchar2(10) := 'N';
        l_ra_in_multi_cur_flag      Varchar2(10) := 'N';

    /* declared the following tbl for client extn bulk update */
    l_cl_txn_plan_quantity_tab  pa_plsql_datatypes.NumTabTyp;
        l_cl_txn_raw_cost_tab       pa_plsql_datatypes.NumTabTyp;
        l_cl_txn_burdened_cost_tab  pa_plsql_datatypes.NumTabTyp;
        l_cl_txn_revenue_tab        pa_plsql_datatypes.NumTabTyp;
        l_cl_cost_rate_override_tab pa_plsql_datatypes.NumTabTyp;
        l_cl_burden_rate_override_tab   pa_plsql_datatypes.NumTabTyp;
        l_cl_bill_rate_override_tab pa_plsql_datatypes.NumTabTyp;
        l_cl_budget_line_id_tab     pa_plsql_datatypes.NumTabTyp;
    l_cl_raw_rejection_code_tab pa_plsql_datatypes.char30TabTyp;
    l_cl_burd_rejection_code_tab pa_plsql_datatypes.char30TabTyp;
    l_cl_rev_rejection_code_tab  pa_plsql_datatypes.char30TabTyp;
    l_cl_cntr           NUMBER := 0;
    l_cl_raw_rejection_code     VARCHAR2(30);
        l_cl_burd_rejection_code    VARCHAR2(30);
        l_cl_rev_rejection_code     VARCHAR2(30);

	l_raTxnRec_mode		  VARCHAR2(80);

        /* bug fix: 5028631 */
        l_msg_data   Varchar2(2000);

	l_calc_start_time       Number;
	l_pls_start_time	Number;
	l_pls_end_time		Number;

    -- Start for Bug# 6781055
    l_rec_modified_in_cl_flag     VARCHAR2(1);
    l_cl_init_quantity            pa_budget_lines.init_quantity%TYPE;
    l_cl_init_raw_cost            pa_budget_lines.txn_init_raw_cost%TYPE;
    l_cl_init_burd_cost           pa_budget_lines.txn_init_burdened_cost%TYPE;
    l_cl_init_revenue             pa_budget_lines.txn_init_revenue%TYPE;
    -- End for Bug# 6781055

 BEGIN
g_ipm_ra_id_tab.delete;
g_ipm_curr_code_tab.delete;
g_ipm_cost_rate_ovr_tab.delete;
g_ipm_bill_rate_ovr_tab.delete;
g_ipm_burden_rate_ovr_tab.delete;
-- For Bug# 6781055
gl_cl_roll_up_tmp_rowid_tab.delete;

    IF p_pa_debug_mode = 'Y' Then
        pa_debug.init_err_stack('PA_FP_CALC_PLAN_PKG.calculate');
        pa_debug.set_process('PLSQL','LOG',l_debug_mode);
    End If;
        l_return_status        := FND_API.G_RET_STS_SUCCESS;
        l_entire_return_status := FND_API.G_RET_STS_SUCCESS;
        x_return_status        := FND_API.G_RET_STS_SUCCESS;

    /* Initialize the msg stack */
    FND_MSG_PUB.initialize;

    SAVEPOINT start_of_calculate_api;

        /* Bug fix: 4078623 Set curr and init err stack both are calling but reset curr function is not done.
         * This api call is not required as it does the same as init_err_stack
        --pa_debug.set_curr_function( p_function     => 'PA_FP_CALC_PLAN_PKG.calculate'
                                   --,p_debug_mode   =>  p_pa_debug_mode);
         */
	l_calc_start_time := dbms_utility.get_time;
	print_plsql_time('Calculate API start Time:['||l_calc_start_time||']','Y');
	If P_PA_DEBUG_MODE = 'Y' Then
        l_stage := 10;
        print_msg(to_char(l_stage)||' Entered PA_FP_CALC_PLAN_PKG.calculate');
    	print_msg('Calculate API start Time:['||l_calc_start_time||']','Y');
        l_stage := 20;
        print_msg('PA_FP_CALC_PLAN_PKG.calculat IN param(Scalar) values');
        print_msg('p_project_id                  => '|| to_char(p_project_id));
        print_msg('p_budget_version_id           => '|| to_char(p_budget_version_id));
        print_msg('p_refresh_rates_flag          => '|| p_refresh_rates_flag);
        print_msg('p_refresh_conv_rates_flag     => '|| p_refresh_conv_rates_flag);
        print_msg('p_spread_required_flag:Obsoleted: => '|| p_spread_required_flag);
        print_msg('p_conv_rates_required_flag    => '|| p_conv_rates_required_flag);
        print_msg('p_rollup_required_flag        => '|| p_rollup_required_flag);
        print_msg('p_mass_adjust_flag            => '|| p_mass_adjust_flag);
        print_msg('p_quantity_adj_pct            => '|| to_char(p_quantity_adj_pct));
        print_msg('p_cost_rate_adj_pct           => '|| to_char(p_cost_rate_adj_pct));
        print_msg('p_burdened_rate_adj_pct       => '|| to_char(p_burdened_rate_adj_pct));
        print_msg('p_bill_rate_adj_pct           => '|| to_char(p_bill_rate_adj_pct));
	print_msg('p_raw_cost_adj_pct            => '|| to_char(p_raw_cost_adj_pct));
        print_msg('p_burden_cost_adj_pct         => '|| to_char(p_burden_cost_adj_pct));
        print_msg('p_revenue_adj_pct             => '|| to_char(p_revenue_adj_pct));
    	print_msg('p_calling_module              => '|| nvl(p_calling_module,l_calling_module));
        print_msg('p_source_context              => '|| p_source_context);
    	print_msg('p_apply_progress_flag         => '|| p_apply_progress_flag);
    	print_msg('p_wp_cost_changed_flag        => '|| p_wp_cost_changed_flag);
        print_msg('p_time_phase_changed_flag     => '|| p_time_phase_changed_flag);
        print_msg('p_clientExtn_api_call_flag     => '|| p_clientExtn_api_call_flag);
        print_msg('p_raTxn_rollup_api_call_flag	  => '|| p_raTxn_rollup_api_call_flag);
        print_msg(to_char(l_stage)||' Initialization all local plsql tables ');
	End If;

        l_resource_assignment_tab.delete;
        l_delete_budget_lines_tab.delete;
        l_spread_amts_flag_tab.delete;
        l_txn_currency_code_tab.delete;
        l_txn_currency_override_tab.delete;
        l_total_qty_tab.delete;
        l_addl_qty_tab.delete;
        l_total_raw_cost_tab.delete;
        l_addl_raw_cost_tab.delete;
        l_total_burdened_cost_tab.delete;
        l_addl_burdened_cost_tab.delete;
        l_total_revenue_tab.delete;
        l_addl_revenue_tab.delete;
        l_raw_cost_rate_tab.delete;
        l_rw_cost_rate_override_tab.delete;
        l_b_cost_rate_tab.delete;
        l_b_cost_rate_override_tab.delete;
        l_bill_rate_tab.delete;
        l_bill_rate_override_tab.delete;
        l_line_start_date_tab.delete;
        l_line_end_date_tab.delete;
    g_apply_progress_flag_tab.delete;
    l_spread_curve_id_old_tab.delete;
    l_spread_curve_id_new_tab.delete;
    l_sp_fixed_date_old_tab.delete;
    l_sp_fixed_date_new_tab.delete;
    l_plan_start_date_old_tab.delete;
    l_plan_start_date_new_tab.delete;
    l_plan_end_date_old_tab.delete;
    l_plan_end_date_new_tab.delete;
    l_re_spread_flag_tab.delete;
    l_sp_curve_change_flag_tab.delete;
    l_plan_dates_change_flag_tab.delete;
    l_spfix_date_flag_tab.delete;
    l_mfc_cost_change_flag_tab.delete;
    l_mfc_cost_type_id_old_tab.delete;
    l_mfc_cost_type_id_new_tab.delete;
    l_rlm_id_change_flag_tab.delete;
    l_plan_sdate_shrunk_flag_tab.delete;
    l_plan_edate_shrunk_flag_tab.delete;
    l_mfc_cost_refresh_flag_tab.delete;
    l_ra_in_multi_cur_flag_tab.delete;
    l_quantity_changed_flag_tab.delete;
    l_raw_cost_changed_flag_tab.delete;
    l_cost_rate_changed_flag_tab.delete;
    l_burden_cost_changed_flag_tab.delete;
    l_burden_rate_changed_flag_tab.delete;
    l_rev_changed_flag_tab.delete;
    l_bill_rate_changed_flag_tab.delete;
    l_multicur_plan_start_date_tab.delete;
        l_multicur_plan_end_date_tab.delete;
    l_fp_task_billable_flag_tab.delete;
    l_cost_rt_miss_num_flag_tab.delete;
    l_burd_rt_miss_num_flag_tab.delete;
    l_bill_rt_miss_num_flag_tab.delete;
    l_Qty_miss_num_flag_tab.delete;
    l_Rw_miss_num_flag_tab.delete;
    l_Br_miss_num_flag_tab.delete;
    l_Rv_miss_num_flag_tab.delete;
    l_rev_only_entry_flag_tab.delete;

    /* bug fix:5726773 */
    l_neg_Qty_Changflag_tab.delete;
    l_neg_Raw_Changflag_tab.delete;
    l_neg_Burd_Changflag_tab.delete;
    l_neg_rev_Changflag_tab.delete;


        /* Initialize the scalar global variables with in params */
        G_refresh_conv_rates_flag       := p_refresh_conv_rates_flag;
        G_refresh_rates_flag            := p_refresh_rates_flag;
        G_mass_adjust_flag          := p_mass_adjust_flag;
        G_source_context            := p_source_context;
    	G_calling_module                := p_calling_module;
    	G_conv_rates_required_flag      := p_conv_rates_required_flag;
    	G_clientExtn_api_call_flag      := NVL(p_clientExtn_api_call_flag,'Y');

	If NVL(p_wp_cost_changed_flag,'N') = 'Y'
	   and NVL(p_time_phase_changed_flag,'N') = 'N' Then
            print_msg('WP costs changed set the refresh cost flag to Y');
            -- set the refresh costs flag
            G_refresh_rates_flag := 'Y';

        End If;

        l_stage                            := NULL;
        x_return_status                    := 'S';
        x_msg_count                        := 0;
        x_msg_data                         := NULL;
        g_bv_resource_list_id              := NULL;
        g_bv_approved_rev_flag             := NULL;
        g_fp_multi_curr_enabled            := NULL;
        g_spread_from_date                 := NULL;
        g_session_time                     := NULL;
        g_ra_bl_txn_currency_code          := NULL;
        G_AGR_CONV_REQD_FLAG               := 'N';
        G_AGR_CURRENCY_CODE                := NULL;
        g_proj_structure_ver_id            := NULL;
    /* Bug fix:4275007 : since these global variables are not initialized, values got cached if the calculate api is called in the same session */
    g_proj_rev_rate_type               := NULL;
    G_proj_rev_exchange_rate           := NULL;
	G_call_raTxn_rollup_flag	:= NVL(p_raTxn_rollup_api_call_flag,'Y');

        IF p_budget_version_id IS NOT NULL Then
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Calling Init_Globals API: p_del_spread_calc_tmp1_flg['||p_del_spread_calc_tmp1_flg||']');
	End If;
        Init_Globals(
                p_budget_version_id  => p_budget_version_id
                ,p_source_context    => p_source_context
                ,x_return_status     => l_return_status
                );
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('ReturnStatus of Init_Globals ['||l_return_status||']');
	End If;
        IF l_return_status <> 'S' Then
                        x_return_status := l_return_status;
                        l_entire_return_status := l_return_status;
                        GOTO END_OF_PROCESS;
                END IF;
        END IF;

        /* Initialize the spreadCalc global plsql tables */
        /*Bug: 4309290. Added the parameter to identify if PA_FP_SPREAD_CALC_TMP1
        is to be deleted or not. Frm AMG flow we will pass N and for
        other calls to calculate api it would be yes*/
        Init_SpreadCalc_Tbls(p_del_spread_calc_tmp1_flg => p_del_spread_calc_tmp1_flg);

        /* Intialize the Mrc Plsql Tabs */
        Init_MRC_plsqlTabs;

        /* Initialize reporting tables */
        Init_reporting_Tbls;

    /* when calculate api is called in apply progress mode ensure that etc start date is populated */
    IF (NVL(p_apply_progress_flag,'N') = 'Y' AND g_spread_from_date is NULL)  Then
        l_stage := 15;
                print_msg(l_stage||' ETC START DATE NULL for apply progress call');
                pa_utils.add_message
                        ( p_app_short_name => 'PA'
                        ,p_msg_name       => 'PA_FP_ETCSTARTDATE_NULL'
                        ,p_token1         => 'BUDGET_VERSION_ID'
                        ,p_value1         =>  p_budget_version_id
                        ,p_token2         => 'PROJECT_ID'
                        ,p_value2         =>  p_project_id);
                        l_return_status := 'E';
                        x_return_status := 'E';
            l_entire_return_status := l_return_status;
                        GOTO END_OF_PROCESS;
    End If;

        l_stage := 25;
	l_pls_start_time := dbms_utility.get_time;
    	--print_plsql_time('Start of Validate Inputs:['||l_pls_start_time||']','Y');
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg(to_char(l_stage)||' Calling Validate Inputs');
    	print_msg('Start of Validate Inputs:['||l_pls_start_time||']','Y');
	End If;
        pa_fp_calc_plan_pkg.validate_inputs
        ( p_project_id               =>  p_project_id
                ,p_budget_version_id             =>  p_budget_version_id
        ,p_calling_module                =>  l_calling_module
        ,p_refresh_rates_flag            =>  G_refresh_rates_flag
        ,p_refresh_conv_rates_flag       =>  G_refresh_conv_rates_flag
                ,p_mass_adjust_flag              =>  g_mass_adjust_flag
        ,p_qty_adjust_pct                =>  p_quantity_adj_pct
                ,p_cst_rate_adjust_pct           =>  p_cost_rate_adj_pct
                ,p_bd_rate_adjust_pct            =>  p_burdened_rate_adj_pct
                ,p_bill_rate_adjust_pct          =>  p_bill_rate_adj_pct
		,p_raw_cost_adj_pct              => p_raw_cost_adj_pct
                ,p_burden_cost_adj_pct           => p_burden_cost_adj_pct
                ,p_revenue_adj_pct               => p_revenue_adj_pct
                ,p_spread_required_flag          =>  p_spread_required_flag
                ,p_source_context                =>  p_source_context
                ,p_wp_cost_changed_flag          =>  p_wp_cost_changed_flag
                ,p_time_phase_changed_flag       =>  p_time_phase_changed_flag
                ,p_resource_assignment_tab       =>  p_resource_assignment_tab
                ,p_delete_budget_lines_tab       =>  p_delete_budget_lines_tab
                ,p_spread_amts_flag_tab          =>  p_spread_amts_flag_tab
                ,p_txn_currency_code_tab         =>  p_txn_currency_code_tab
                ,p_txn_currency_override_tab     =>  p_txn_currency_override_tab
                ,p_total_qty_tab                 =>  p_total_qty_tab
                ,p_addl_qty_tab                  =>  p_addl_qty_tab
                ,p_total_raw_cost_tab            =>  p_total_raw_cost_tab
                ,p_addl_raw_cost_tab             =>  p_addl_raw_cost_tab
                ,p_total_burdened_cost_tab       =>  p_total_burdened_cost_tab
                ,p_addl_burdened_cost_tab        =>  p_addl_burdened_cost_tab
                ,p_total_revenue_tab             =>  p_total_revenue_tab
                ,p_addl_revenue_tab              =>  p_addl_revenue_tab
                ,p_raw_cost_rate_tab             =>  p_raw_cost_rate_tab
                ,p_rw_cost_rate_override_tab     =>  p_rw_cost_rate_override_tab
                ,p_b_cost_rate_tab               =>  p_b_cost_rate_tab
                ,p_b_cost_rate_override_tab      =>  p_b_cost_rate_override_tab
                ,p_bill_rate_tab                 =>  p_bill_rate_tab
                ,p_bill_rate_override_tab        =>  p_bill_rate_override_tab
                ,p_line_start_date_tab           =>  p_line_start_date_tab
                ,p_line_end_date_tab             =>  p_line_end_date_tab
        /* added for enhancements */
                ,p_spread_curve_id_old_tab       =>  p_spread_curve_id_old_tab
                ,p_spread_curve_id_new_tab       =>  p_spread_curve_id_new_tab
                ,p_sp_fixed_date_old_tab         =>  p_sp_fixed_date_old_tab
                ,p_sp_fixed_date_new_tab         =>  p_sp_fixed_date_new_tab
                ,p_plan_start_date_old_tab       =>  p_plan_start_date_old_tab
                ,p_plan_start_date_new_tab       =>  p_plan_start_date_new_tab
                ,p_plan_end_date_old_tab         =>  p_plan_end_date_old_tab
                ,p_plan_end_date_new_tab         =>  p_plan_end_date_new_tab
                ,p_re_spread_flag_tab            =>  p_re_spread_flag_tab
                ,p_sp_curve_change_flag_tab      =>  l_sp_curve_change_flag_tab
                ,p_plan_dates_change_flag_tab    =>  l_plan_dates_change_flag_tab
                ,p_spfix_date_flag_tab           =>  l_spfix_date_flag_tab
            ,p_mfc_cost_change_flag_tab      =>  l_mfc_cost_change_flag_tab
        ,p_mfc_cost_type_id_old_tab      =>  p_mfc_cost_type_id_old_tab
        ,p_mfc_cost_type_id_new_tab      =>  p_mfc_cost_type_id_new_tab
        ,p_rlm_id_change_flag_tab       =>  p_rlm_id_change_flag_tab
        ,p_fp_task_billable_flag_tab     => p_fp_task_billable_flag_tab
                ,x_return_status                 =>  l_return_status
                ,x_msg_count                     =>  x_msg_count
                ,x_msg_data                      =>  x_msg_data);
	l_pls_end_time := dbms_utility.get_time;
	If P_PA_DEBUG_MODE = 'Y' Then
    		print_msg('End of Validate Inputs:['||l_pls_end_time||']','Y');
	End If;
    		print_plsql_time('End of Validate Inputs: Total time :['||(l_pls_end_time-l_pls_start_time)||']');


        IF l_return_status <> 'S' Then
            print_msg('Failed in validation inputs');
                       x_return_status := l_return_status;
                       l_entire_return_status := l_return_status;
            GOTO END_OF_PROCESS;
                END IF;

    /*
    assign local tab variables the p_tab IN parameters  this needs to be done because table IN parameters needs to be
    extended from here on out use the l_tab variable in place of p_tab variables
    */
        l_resource_assignment_tab     := p_resource_assignment_tab;
        l_txn_currency_code_tab       := p_txn_currency_code_tab;
        l_delete_budget_lines_tab         := p_delete_budget_lines_tab;
        l_spread_amts_flag_tab            := p_spread_amts_flag_tab;
        l_txn_currency_override_tab       := p_txn_currency_override_tab;
        l_total_qty_tab                   := p_total_qty_tab;
        l_addl_qty_tab                    := p_addl_qty_tab;
        l_total_raw_cost_tab              := p_total_raw_cost_tab;
        l_addl_raw_cost_tab               := p_addl_raw_cost_tab;
        l_total_burdened_cost_tab         := p_total_burdened_cost_tab;
        l_addl_burdened_cost_tab          := p_addl_burdened_cost_tab;
        l_total_revenue_tab               := p_total_revenue_tab;
        l_addl_revenue_tab                := p_addl_revenue_tab;
        l_raw_cost_rate_tab               := p_raw_cost_rate_tab;
        l_rw_cost_rate_override_tab       := p_rw_cost_rate_override_tab;
        l_b_cost_rate_tab                 := p_b_cost_rate_tab;
        l_b_cost_rate_override_tab        := p_b_cost_rate_override_tab;
        l_bill_rate_tab                   := p_bill_rate_tab;
        l_bill_rate_override_tab          := p_bill_rate_override_tab;
        l_line_start_date_tab             := p_line_start_date_tab;
        l_line_end_date_tab               := p_line_end_date_tab;
    /* added for spread enhancements */
        l_spread_curve_id_old_tab         := p_spread_curve_id_old_tab;
        l_spread_curve_id_new_tab         := p_spread_curve_id_new_tab;
        l_sp_fixed_date_old_tab           := p_sp_fixed_date_old_tab;
        l_sp_fixed_date_new_tab           := p_sp_fixed_date_new_tab;
        l_plan_start_date_old_tab         := p_plan_start_date_old_tab;
        l_plan_start_date_new_tab         := p_plan_start_date_new_tab;
        l_plan_end_date_old_tab           := p_plan_end_date_old_tab;
        l_plan_end_date_new_tab           := p_plan_end_date_new_tab;
    l_mfc_cost_type_id_old_tab        := p_mfc_cost_type_id_old_tab;
        l_mfc_cost_type_id_new_tab        := p_mfc_cost_type_id_new_tab;
        l_re_spread_flag_tab              := p_re_spread_flag_tab;
    l_rlm_id_change_flag_tab          := p_rlm_id_change_flag_tab;
    l_fp_task_billable_flag_tab   := p_fp_task_billable_flag_tab;
    /*
    Check if p_resource_assignment_tab has values.  If not try to
    populate with values from pa_resource_assignments using
    the budget_version_id.  If there is still no values for
    resource assignment error and return.  Else assign
    resource_assignment_ids to local variable l_resource_assignment_tab.
    l_resource_assignment_tab will be used instead of p_resource_assignment_tab
    for the rest of the procedure
    */
        l_tab_count := l_resource_assignment_tab.COUNT;
        l_stage := 100;
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg(to_char(l_stage)||' Check if p_resource_assignment_tab has values['||l_tab_count||']');
	End If;

        IF l_tab_count = 0 THEN
            l_stage := 110;
            --print_msg(to_char(l_stage)||' p_resource_assignment_tab.COUNT = 0');
            IF ( nvl(p_wp_cost_changed_flag,'N') = 'Y'
             OR nvl(p_time_phase_changed_flag,'N') = 'Y'
             /* Bug fix:4307790 */
             OR NVL(p_refresh_rates_flag,'N') = 'Y'
             OR NVL(p_refresh_conv_rates_flag,'N') = 'Y' ) Then
               OPEN get_p_res_asn_curr_code;
               FETCH get_p_res_asn_curr_code BULK COLLECT INTO
            l_resource_assignment_tab
            ,l_txn_currency_code_tab;
               CLOSE get_p_res_asn_curr_code;
               l_tab_count := l_resource_assignment_tab.COUNT;
		If P_PA_DEBUG_MODE = 'Y' Then
               print_msg(to_char(l_stage)||' l_resource_assignment_tab.COUNT ='||to_char(l_tab_count));
		End If;
        End If;

            IF l_tab_count = 0 THEN
                l_stage := 130;
                print_msg(to_char(l_stage)||' No resource assignments exists simply return with success');
                /*pa_utils.add_message
                    ( p_app_short_name => 'PA',
                    p_msg_name       => 'PA_FP_CALC_RA_BL_REQ',
                    p_token1         => 'BUDGET_VERSION_ID',
                    p_value1         =>  p_budget_version_id,
                    p_token2         => 'PROJECT_ID',
                    p_value2         =>  p_project_id);
            */
            l_return_status := 'S';
            x_return_status := 'S';
            GOTO END_OF_PROCESS;
               END IF;
        END IF;

    	/* Bug fix: 3693097 The inparams contains G_MISS_NUM chars should be validated*/
    	/*************************************************************************************
		l_pls_start_time := dbms_utility.get_time;
 	        --print_plsql_time('Start of MainLopp1:['||l_pls_start_time);
     	*Bug:5309529: Performance improvement changes : the following loop and execution of cursors inside the loop
     	*is removed and added a new api inside the PAFPCL1B.pls insert_spread_calctmp_records
	**************End of Bug fix:5309529 *****************************************/

	l_pls_end_time := dbms_utility.get_time;
	print_plsql_time('End of MainLopp1:Total time['||(l_pls_end_time - l_pls_start_time));
    l_stage := 133;
    IF l_return_status <> 'S' Then
             print_msg(l_stage||'Errors found in the params processing');
             x_return_status := l_return_status;
             l_entire_return_status := l_return_status;
             GOTO END_OF_PROCESS;
        END IF;

         /* End of Bug fix: 3693097 */
 	         /*  Assign g_spread_required_flag value passed from p_spread_required flag.
 	         */
 	         g_spread_required_flag := 'N';
 	         g_ra_bl_txn_currency_code := NULL;
 	         /* Bug fix:5463690: this flag is not used anywhere. spread is always based on the additional qty derived
 	          * so obsolete the parameter p_spread_required_flag:
 	         IF (g_mass_adjust_flag = 'Y'
 	             OR g_refresh_rates_flag = 'Y'
 	             OR g_refresh_conv_rates_flag = 'Y' ) Then
 	                 g_spread_required_flag := 'N';
 	          ELSE
 	                 g_spread_required_flag := p_spread_required_flag;
 	         END IF;
 	 **/

        g_rollup_required_flag := p_rollup_required_flag;
    	IF g_rollup_required_flag is NULL OR g_rollup_required_flag <> 'N' Then
        	g_rollup_required_flag := 'Y';
    	END IF;
    	/* Bug fix:4149684 for budget /forecast generation process the calling api will call the
         * plan update and plan delete pji api. so set the rollup required flag to N */
        /* Bug fix:4189762 discussed with sakthi,saima and sanjay, during apply progress mode no need to call the rollup
         * as the progress API is calling plan_delete and plan_create rollup API to improve the perf
         */
        IF (p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION')
            /* Reverting back:OR NVL(p_apply_progress_flag,'N') = 'Y' as the 4189762 is NOT working properly */
            OR NVL(G_AGR_CONV_REQD_FLAG,'N') = 'Y'  ) Then
                g_rollup_required_flag := 'N';
        End If;
	--print_msg('rollup required flag =>'||g_rollup_required_flag||']');
	l_pls_start_time := dbms_utility.get_time;
    	--print_plsql_time('Start of populate_spreadCalc_tmp:['||l_pls_start_time);

    IF l_resource_assignment_tab.COUNT > 0 THEN --{
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Calling PA_FP_CALC_UTILS.populate_spreadCalc_Tmp API');
	End If;
        PA_FP_CALC_UTILS.populate_spreadCalc_Tmp (
                p_budget_version_id              => p_budget_version_id
        ,p_budget_version_type           => g_fp_budget_version_type
        ,p_calling_module                => l_calling_module
                ,p_source_context                => p_source_context
                ,p_time_phased_code              => g_time_phased_code
        ,p_apply_progress_flag           => p_apply_progress_flag
                ,p_rollup_required_flag          => g_rollup_required_flag
            ,p_refresh_rates_flag            => g_refresh_rates_flag
                ,p_refresh_conv_rates_flag       => g_refresh_conv_rates_flag
                ,p_mass_adjust_flag              => g_mass_adjust_flag
        ,p_time_phase_changed_flag        => NVL(p_time_phase_changed_flag,'N')
	,p_wp_cost_changed_flag           => NVL(p_wp_cost_changed_flag,'N')
        ,x_resource_assignment_tab       =>l_resource_assignment_tab
                ,x_delete_budget_lines_tab       =>l_delete_budget_lines_tab
                ,x_spread_amts_flag_tab          =>l_spread_amts_flag_tab
                ,x_txn_currency_code_tab         =>l_txn_currency_code_tab
                ,x_txn_currency_override_tab     =>l_txn_currency_override_tab
                ,x_total_qty_tab                 =>l_total_qty_tab
                ,x_addl_qty_tab                  =>l_addl_qty_tab
                ,x_total_raw_cost_tab            =>l_total_raw_cost_tab
                ,x_addl_raw_cost_tab             =>l_addl_raw_cost_tab
                ,x_total_burdened_cost_tab       =>l_total_burdened_cost_tab
                ,x_addl_burdened_cost_tab        =>l_addl_burdened_cost_tab
                ,x_total_revenue_tab             =>l_total_revenue_tab
                ,x_addl_revenue_tab              =>l_addl_revenue_tab
                ,x_raw_cost_rate_tab             =>l_raw_cost_rate_tab
                ,x_rw_cost_rate_override_tab     =>l_rw_cost_rate_override_tab
                ,x_b_cost_rate_tab               =>l_b_cost_rate_tab
                ,x_b_cost_rate_override_tab      =>l_b_cost_rate_override_tab
                ,x_bill_rate_tab                 =>l_bill_rate_tab
                ,x_bill_rate_override_tab        =>l_bill_rate_override_tab
                ,x_line_start_date_tab           =>l_line_start_date_tab
                ,x_line_end_date_tab             =>l_line_end_date_tab
                ,x_apply_progress_flag_tab       =>g_apply_progress_flag_tab
                ,x_spread_curve_id_old_tab       =>l_spread_curve_id_old_tab
                ,x_spread_curve_id_new_tab       =>l_spread_curve_id_new_tab
                ,x_sp_fixed_date_old_tab         =>l_sp_fixed_date_old_tab
                ,x_sp_fixed_date_new_tab         =>l_sp_fixed_date_new_tab
                ,x_plan_start_date_old_tab       =>l_plan_start_date_old_tab
                ,x_plan_start_date_new_tab       =>l_plan_start_date_new_tab
                ,x_plan_end_date_old_tab         =>l_plan_end_date_old_tab
                ,x_plan_end_date_new_tab         =>l_plan_end_date_new_tab
                ,x_re_spread_flag_tab            =>l_re_spread_flag_tab
                ,x_sp_curve_change_flag_tab      =>l_sp_curve_change_flag_tab
                ,x_plan_dates_change_flag_tab    =>l_plan_dates_change_flag_tab
                ,x_spfix_date_flag_tab           =>l_spfix_date_flag_tab
                ,x_mfc_cost_change_flag_tab      =>l_mfc_cost_change_flag_tab
                ,x_mfc_cost_type_id_old_tab      =>l_mfc_cost_type_id_old_tab
                ,x_mfc_cost_type_id_new_tab      =>l_mfc_cost_type_id_new_tab
        ,x_rlm_id_change_flag_tab        =>l_rlm_id_change_flag_tab
            ,x_plan_sdate_shrunk_flag_tab    =>l_plan_sdate_shrunk_flag_tab
            ,x_plan_edate_shrunk_flag_tab    =>l_plan_edate_shrunk_flag_tab
            ,x_mfc_cost_refresh_flag_tab     =>l_mfc_cost_refresh_flag_tab
        ,x_ra_in_multi_cur_flag_tab      =>l_ra_in_multi_cur_flag_tab
        ,x_quantity_changed_flag_tab     =>l_quantity_changed_flag_tab
            ,x_raw_cost_changed_flag_tab     =>l_raw_cost_changed_flag_tab
            ,x_cost_rate_changed_flag_tab    =>l_cost_rate_changed_flag_tab
            ,x_burden_cost_changed_flag_tab  =>l_burden_cost_changed_flag_tab
            ,x_burden_rate_changed_flag_tab  =>l_burden_rate_changed_flag_tab
            ,x_rev_changed_flag_tab          =>l_rev_changed_flag_tab
            ,x_bill_rate_changed_flag_tab    =>l_bill_rate_changed_flag_tab
        ,x_multcur_plan_start_date_tab   =>l_multicur_plan_start_date_tab
        ,x_multcur_plan_end_date_tab     =>l_multicur_plan_end_date_tab
        ,x_fp_task_billable_flag_tab  => l_fp_task_billable_flag_tab
        ,x_cost_rt_miss_num_flag_tab  => l_cost_rt_miss_num_flag_tab
        ,x_burd_rt_miss_num_flag_tab  => l_burd_rt_miss_num_flag_tab
        ,x_bill_rt_miss_num_flag_tab  => l_bill_rt_miss_num_flag_tab
        ,x_Qty_miss_num_flag_tab  => l_Qty_miss_num_flag_tab
        ,x_Rw_miss_num_flag_tab  => l_Rw_miss_num_flag_tab
        ,x_Br_miss_num_flag_tab  => l_Br_miss_num_flag_tab
	,x_Rv_miss_num_flag_tab  => l_Rv_miss_num_flag_tab
	,x_rev_only_entry_flag_tab => l_rev_only_entry_flag_tab
	/* bug fix:5726773 */
 	,x_neg_Qty_Changflag_tab   => l_neg_Qty_Changflag_tab
 	,x_neg_Raw_Changflag_tab  => l_neg_Raw_Changflag_tab
 	,x_neg_Burd_Changflag_tab => l_neg_Burd_Changflag_tab
 	,x_neg_rev_Changflag_tab  => l_neg_rev_Changflag_tab
        ,x_return_status                 => l_return_status
        ,x_msg_data                      => x_msg_data
                );
	l_pls_end_time := dbms_utility.get_time;
        print_plsql_time('End of populate_spreadCalc_tmp:Total time :['||(l_pls_end_time-l_pls_start_time)||']');
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('End of calling PA_FP_CALC_UTILS.populate_spreadCalc_Tmp retSts['||l_return_status||']');
	End If;
        If l_return_status <> 'S' Then
                        l_entire_return_status := l_return_status;
                        x_return_status := l_return_status;
                        GOTO END_OF_PROCESS;
                End If;
    END IF; --}

    l_stage := 205;
    /* Initialize the currency conversion details */
    Initialize_fp_cur_details
                (p_budget_version_id  => p_budget_version_id
                ,p_project_id         => g_project_id
        ,x_return_status      => l_return_status
        );

    l_stage := 206;
    /* reset the planning transaction dates if the actual through period dates and planning dates are
        * are not in sync
        */
        IF (NVL(l_return_status,'S') = 'S'
       AND g_spread_from_date IS NOT NULL
       AND p_source_context = 'RESOURCE_ASSIGNMENT'
       AND g_refresh_rates_flag = 'N'
       AND g_refresh_conv_rates_flag = 'N'
       AND g_mass_adjust_flag = 'N')  THEN  --{
                Reset_Planning_end_date
                (p_calling_module         => l_calling_module
                ,p_source_context         => g_source_context
                ,p_budget_version_id      => g_budget_version_id
                ,p_etc_start_date         => g_spread_from_date
                ,x_return_status          => l_return_status
                ,x_msg_data               => x_msg_data
                );
                IF l_return_status <> 'S' Then
                    print_msg('Un expected Error from Reset_Planning_end_date api');
                    l_entire_return_status := l_return_status;
                    x_return_status := l_return_status;
            GOTO END_OF_PROCESS;
                End If;

        /* update resource assignments set planning end date as etc start date for the fixed date
        * spread curves where more than one budget line exists
        */
            PreProcess_BlkProgress_lines
            (p_budget_version_id      => g_budget_version_id
            ,p_etc_start_date         => g_spread_from_date
        ,p_apply_progress_flag    => p_apply_progress_flag
            ,x_return_status          => l_return_status
            ,x_msg_data               => x_msg_data
            );
                IF l_return_status <> 'S' Then
                    print_msg('Un expected Error from PreProcess_BlkProgress_lines api');
                    l_entire_return_status := l_return_status;
                    x_return_status := l_return_status;
                    GOTO END_OF_PROCESS;
                End If;

            /* added this check to make sure that before summing the budget Line amounts
                * the closed period amounts should be null
                */
                IF NVL(l_return_status,'S') = 'S' Then
			If P_PA_DEBUG_MODE = 'Y' Then
                       print_msg('Calling clear_closed_period_etcs API since ETC start date is populated');
			End If;
                       clear_closed_period_etcs
                       (p_budget_version_id       => g_budget_version_id
                       ,p_etc_start_date          => g_spread_from_date
                       ,x_return_status           => l_return_status );
			If P_PA_DEBUG_MODE = 'Y' Then
                       print_msg('End of clear_closed_period_etcs retSts['||l_return_status||']');
			End If;
                       IF l_return_status <> 'S' Then
                         l_entire_return_status := l_return_status;
                         x_return_status := l_return_status;
                         GOTO END_OF_PROCESS;
                       End If;
                End If;

        /* IPM changes: Whenever budget lines get deleted, rollup the amts to new entity
         * otherwise this causes data corruption of amounts and quantity get doubled during apply progress
         */
        IF p_source_context = 'RESOURCE_ASSIGNMENT' AND
                     NVL(p_raTxn_rollup_api_call_flag,'Y') = 'Y' AND nvl(l_entire_return_status,'S') = 'S' Then
			 If P_PA_DEBUG_MODE = 'Y' Then
                         print_msg('Calling populate_raTxn_Recs API for rollup of budgetlines during apply progress');
			 End if;
                         delete_raTxn_Tmp;
                         populate_raTxn_Recs (
                         p_budget_version_id     => g_budget_version_id
                         ,p_source_context       => 'BUDGET_LINE' -- to rollup the amounts
                         ,p_calling_mode         => 'CLEAR_CLOSED_PERIOD'
                         ,p_delete_flag          => 'N'
                         ,p_delete_raTxn_flag    => 'N'
                         ,p_refresh_rate_flag    => 'N'
                         ,p_rollup_flag          => 'Y'
                         ,p_call_raTxn_rollup_flag => 'Y'
                         ,x_return_status        => l_return_status
                         ,x_msg_count            => x_msg_count
                         ,x_msg_data             => x_msg_data
                         );
			 If P_PA_DEBUG_MODE = 'Y' Then
                         print_msg('AFter calling populate_raTxn_Recs retSTst['||l_return_status||']MsgData['||x_msg_data||']');
			 End if;
                         IF l_return_status <> 'S' Then
                            x_return_status := l_return_status;
                            l_entire_return_status := l_return_status;
                         END IF;
               END IF;
        END IF; --}



       /* Throw an error If budget lines having zero qty and actuals, these lines corrupted budget lines
        * getting created through the AMG apis and budget generation process. Just abort the process
        */
       IF (NVL(l_return_status,'S') = 'S'
           AND p_source_context = 'RESOURCE_ASSIGNMENT'
           AND g_refresh_rates_flag = 'N'
           AND g_refresh_conv_rates_flag = 'N'
           AND g_mass_adjust_flag = 'N')  THEN  --{
		If P_PA_DEBUG_MODE = 'Y' Then
                print_msg('Check zero Quantity budget Lines where actuals Exists');
		End if;
                PA_FP_CALC_UTILS.Check_ZeroQty_Bls
                                (p_budget_version_id => p_budget_version_id
                                ,x_return_status      => l_return_status
                                );
		If P_PA_DEBUG_MODE = 'Y' Then
                print_msg('ReturnStatus of Check_ZeroQty_ActualBls API['||l_return_status||']');
		End if;
                If l_return_status <> 'S' Then
                      x_return_status := 'E';
              l_entire_return_status := l_return_status;
              GOTO END_OF_PROCESS;
                End If;
    END IF; --}

	/* Bug fix:5203622 */
	IF l_entire_return_status = 'S' Then
	l_pls_start_time := dbms_utility.get_time;
    --print_plsql_time('Start of clear_etc_rev_other_rejectns :['||l_pls_start_time);
		clear_etc_rev_other_rejectns
         	(p_budget_version_id      => p_budget_version_id
            	,p_source_context         => p_source_context
            	,p_calling_module         => p_calling_module
            	,p_mode                   => 'CACHE'
            	,x_return_status    	  => l_return_status
            	,x_msg_count        	  => x_msg_count
            	,x_msg_data         	  => l_msg_data
            	);
		If l_return_status <> 'S' Then
                      	x_return_status := 'E';
              		l_entire_return_status := l_return_status;
              		GOTO END_OF_PROCESS;
                End If;
	END IF;
	l_pls_end_time := dbms_utility.get_time;
	print_plsql_time('End of clear_etc_rev_other_rejectns Total time :['||(l_pls_end_time-l_pls_start_time)||']');

    l_stage := 210;
	If P_PA_DEBUG_MODE = 'Y' Then
    print_msg(to_char(l_stage)||' Entering loop using the l_resource_assignment_tab.resource_assignment_id');
    print_msg('l_resource_assignment_tab.first['||l_resource_assignment_tab.first||']Last['||l_resource_assignment_tab.last);
    print_msg(l_stage||':Count of Errors:MsgCtinErrStack['||fnd_msg_pub.count_msg||']');
	End If;
	l_pls_start_time := dbms_utility.get_time;
    --print_plsql_time('Start of MainLoop2:['||l_pls_start_time);
    --MAIN CODE STARTS HERE
    l_countr := 0;
    FOR i IN l_resource_assignment_tab.first..l_resource_assignment_tab.last LOOP

        l_countr := l_countr +1 ;
        g_plan_raId_tab(l_countr) := l_resource_assignment_tab(i);
            g_plan_txnCur_Tab(l_countr) := l_txn_currency_code_tab(i);
            g_line_sdate_tab(l_countr) := NULL;
            g_line_edate_tab(l_countr) := NULL;
            g_Wp_curCode_tab(l_countr) := NULL;
            g_refresh_rates_tab(l_countr) := g_refresh_rates_flag;
            g_refresh_conv_rates_tab(l_countr) := g_refresh_conv_rates_flag;
            g_mass_adjust_flag_tab(l_countr) := g_mass_adjust_flag;
            g_mfc_cost_refresh_tab(l_countr) := 'N';
        	g_rtChanged_Ra_Flag_tab(l_countr) := 'N';
            g_skip_record_tab(l_countr) := 'N';
	    g_process_skip_CstRevrec_tab(l_countr) := 'N';
            /* Bug fix:4295967 */
                g_applyProg_refreshRts_tab(l_countr) := 'N';


        /*
        Use BEGIN here to allow for the skip record exception if required parameters needed to update
        budget lines are all null.
        */
        BEGIN
                l_stage := 220;
		If P_PA_DEBUG_MODE = 'Y' Then
                print_msg('************'||l_stage||'Inside MAIN resource assignment loop***********');
                print_msg('PRINT IN PARAMETERS for this Resource Assignment ID');
                print_msg('l_resource_assignment_tab(i)  => '|| to_char(l_resource_assignment_tab(i)));
		End if;
            /* Bug fix:4227820 Open this cursor only when exception is raised
             * so moved this portion just before adding the error msg to stack
                OPEN get_line_info(l_resource_assignment_tab(i));
                FETCH get_line_info INTO
                 g_task_name
                , g_resource_name;
                CLOSE get_line_info;
            **/

            /*
            --  Initialize all local variable used within this loop
            */
                l_resource_assignment_id           := NULL;
                l_planning_start_date              := NULL;
                l_planning_end_date                := NULL;
                l_spread_curve_id                  := NULL;
                l_resource_class_code              := NULL;
                l_sp_fixed_date                    := NULL;
                l_rate_based_flag                  := NULL;
                l_txn_currency_code                := NULL;
                l_txn_revenue                      := NULL;
                l_txn_revenue_addl                 := NULL;
                l_txn_raw_cost                     := NULL;
                l_txn_raw_cost_addl                := NULL;
                l_txn_burdened_cost                := NULL;
                l_txn_burdened_cost_addl           := NULL;
                l_txn_plan_quantity                := NULL;
                l_txn_plan_quantity_addl           := NULL;
                l_txn_currency_code_override       := NULL;
                l_txn_init_revenue                 := NULL;
                l_txn_init_revenue_addl            := NULL;
                l_txn_init_raw_cost                := NULL;
                l_txn_init_raw_cost_addl           := NULL;
                l_txn_init_burdened_cost           := NULL;
                l_txn_init_burdened_cost_addl      := NULL;
                l_init_quantity                    := NULL;
                l_init_quantity_addl               := NULL;
                g_line_start_date                  := NULL;
                g_line_end_date                    := NULL;
                l_spread_amounts_flag              := NULL;
                l_raw_cost_rate                    := NULL;
                l_rw_cost_rate_override            := NULL;
                l_burden_cost_rate                 := NULL;
                l_burden_cost_rate_override        := NULL;
                l_bill_rate                        := NULL;
                l_bill_rate_override               := NULL;
                l_budget_line_id                   := NULL;
        l_cost_rt_miss_num_flag        := NULL;
                l_burd_rt_miss_num_flag        := NULL;
                l_bill_rt_miss_num_flag        := NULL;
                g_resource_name                    := NULL;

                        /* Initialize the bl variables */
                l_bl_quantity                      := NULL;
                l_bl_raw_cost_rate                 := NULL;
                l_bl_standard_cost_rate            := NULL;
                l_bl_cost_rate_override            := NULL;
                l_bl_raw_cost                      := NULL;
                l_bl_avg_burden_cost_rate          := NULL;
                l_bl_burden_cost_rate              := NULL;
                l_bl_burden_cost_rate_override     := NULL;
                l_bl_burdened_cost                 := NULL;
                l_bl_bill_rate                     := NULL;
                l_bl_standard_bill_rate            := NULL;
                l_bl_bill_rate_override            := NULL;
                l_bl_revenue                       := NULL;
            --  end of initalization

            /*
            *Select pa_resource_assignment attributes required for the rate API
            */
                l_stage := 250;
                --print_msg(to_char(l_stage)||' Select pa_resource_assignment attributes required for the rate API');
                --print_msg(' l_resource_assignment_tab(i) => '||to_char(l_resource_assignment_tab(i)));
            ResAsgnRec := NULL;
                OPEN get_resource_asn_csr(l_resource_assignment_tab(i));
                FETCH get_resource_asn_csr INTO ResAsgnRec;
                IF get_resource_asn_csr%NOTFOUND THEN
                        l_stage := 260;
                        --print_msg(to_char(l_stage)||' get_resource_asn_csr%NOTFOUND');
                        NULL;
                END IF;
                CLOSE  get_resource_asn_csr;

            /*
            *Assign local variables values selected from the resource_assignemt cursur
            */
                l_stage := 270;
                --print_msg(to_char(l_stage)||' Assign local variables values selected from the resource_assignemt cursur');
                g_task_id                          := ResAsgnRec.task_id;
                g_resource_list_member_id          := ResAsgnRec.resource_list_member_id;
            g_resource_name                    := ResAsgnRec.resource_name;
                l_planning_start_date              := ResAsgnRec.planning_start_date;
                l_planning_end_date                := ResAsgnRec.planning_end_date;
                l_spread_curve_id                  := ResAsgnRec.spread_curve_id;
                l_resource_class_code              := ResAsgnRec.resource_class_code;
                l_sp_fixed_date                    := ResAsgnRec.sp_fixed_date;
                l_rate_based_flag                  := ResAsgnRec.rate_based_flag;


            /*
            assign tab values to local variables
            */
            l_resource_assignment_id :=l_resource_assignment_tab(i);
            l_txn_currency_code := l_txn_currency_code_tab(i);
                l_delete_budget_lines   := NULL;
                l_txn_currency_code_override := NULL;
            /* Added for spread enhancements */
            l_re_spread_amts_flag    := NVL(l_re_spread_flag_tab(i),'N');
                    l_sp_curve_change_flag   := NVL(l_sp_curve_change_flag_tab(i),'N');
                    l_plan_dates_change_flag := NVL(l_plan_dates_change_flag_tab(i),'N');
                    l_spfix_date_change_flag := NVL(l_spfix_date_flag_tab(i),'N');
                    l_mfc_cost_change_flag   := NVL(l_mfc_cost_change_flag_tab(i),'N');
                    l_rlm_id_change_flag     := NVL(l_rlm_id_change_flag_tab(i),'N');
                    l_plan_sdate_shrunk_flag := NVL(l_plan_sdate_shrunk_flag_tab(i),'N');
                    l_plan_edate_shrunk_flag := NVL(l_plan_edate_shrunk_flag_tab(i),'N');
            l_ra_in_multi_cur_flag   := NVL(l_ra_in_multi_cur_flag_tab(i),'N');
            l_quantity_changed_flag := NVL(l_quantity_changed_flag_tab(i),'N');
                        l_raw_cost_changed_flag := NVL(l_raw_cost_changed_flag_tab(i),'N');
                        l_rw_cost_rate_changed_flag := NVL(l_cost_rate_changed_flag_tab(i),'N');
                        l_burden_cost_changed_flag := NVL(l_burden_cost_changed_flag_tab(i),'N');
                        l_b_cost_rate_changed_flag := NVL(l_burden_rate_changed_flag_tab(i),'N');
                        l_rev_changed_flag         := NVL(l_rev_changed_flag_tab(i),'N');
                        l_bill_rate_changed_flag   := NVL(l_bill_rate_changed_flag_tab(i),'N');
            l_resAttribChangeFlag      := 'N';
            l_multicur_plan_start_date := l_multicur_plan_start_date_tab(i);
            l_multicur_plan_end_date   := l_multicur_plan_end_date_tab(i);
            /* Bug fix:4263265 */
            l_org_quantity_changed_flag    := NVL(l_quantity_changed_flag_tab(i),'N');
                        l_org_raw_cost_changed_flag    := NVL(l_raw_cost_changed_flag_tab(i),'N');
                        l_org_rw_rate_changed_flag     := NVL(l_cost_rate_changed_flag_tab(i),'N');
                        l_org_burden_cost_changed_flag := NVL(l_burden_cost_changed_flag_tab(i),'N');
                        l_org_b_cost_rate_changed_flag := NVL(l_burden_rate_changed_flag_tab(i),'N');
                        l_org_rev_changed_flag         := NVL(l_rev_changed_flag_tab(i),'N');
                        l_org_bill_rate_changed_flag   := NVL(l_bill_rate_changed_flag_tab(i),'N');

                        /* check any actuals exists for this resource */
                        l_actual_exists_flag := 'N';
                        check_actual_exists(p_res_ass_id  => l_resource_assignment_id
                                        ,p_start_date  => null
                                        ,p_end_date    => null
                                        ,x_actual_flag => l_actual_exists_flag );
                  	--print_msg('After calling check_actual_exists flag['||l_actual_exists_flag||']');

                        IF l_delete_budget_lines_tab.EXISTS(i) Then
                           If NVL(l_delete_budget_lines,'N') = 'N' Then  -- this is set 'Y' at override currency changed
                              --print_msg('l_delete_budget_lines_tab(i) ['||l_delete_budget_lines_tab(i)||']');
                              l_delete_budget_lines  := l_delete_budget_lines_tab(i);
                           End If;
                        END IF;

            IF NVL(p_apply_progress_flag,'N') <> 'Y' Then  --{
                 IF (l_re_spread_amts_flag = 'Y'
               OR l_sp_curve_change_flag = 'Y'
               OR l_spfix_date_change_flag = 'Y'
               OR l_rlm_id_change_flag = 'Y' ) Then
                l_delete_budget_lines := 'Y';
                    l_resAttribChangeFlag := 'Y';
             ElsIf ((g_wp_version_flag = 'Y' AND l_plan_dates_change_flag = 'Y')
                   OR (l_ra_in_multi_cur_flag = 'N' AND l_plan_dates_change_flag = 'Y')) Then
                l_delete_budget_lines := 'Y';
                l_resAttribChangeFlag := 'Y';
             Elsif (l_mfc_cost_change_flag = 'Y' AND l_quantity_changed_flag = 'N' ) Then
                /* Note: If only mfc cost type changes with out change in quantity then refresh else spread the addl qty */
                If NVL(l_delete_budget_lines,'N') <> 'Y' Then
                    g_mfc_cost_refresh_tab(l_countr) := 'Y';
                    l_resAttribChangeFlag := 'Y';
                End If;
             End If;
            End If; --}

	    /* bug fix:5726773 */
 	    If l_resAttribChangeFlag = 'Y' Then
 	        l_neg_Qty_Changflag_tab(i) := 'N';
 	        l_neg_Raw_Changflag_tab(i) := 'N';
 	        l_neg_Burd_Changflag_tab(i) := 'N';
 	        l_neg_rev_Changflag_tab(i) := 'N';
 	    End If;

	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Flag Values:l_re_spread_amts_flag['||l_re_spread_amts_flag||']l_sp_curve_change_flag['||l_sp_curve_change_flag||']');
        print_msg('l_rlm_id_change_flag['||l_rlm_id_change_flag||']l_delete_budget_lines['||l_delete_budget_lines||']');
        print_msg('l_resAttribChangeFlag['||l_resAttribChangeFlag||']l_ra_in_multi_cur_flag['||l_ra_in_multi_cur_flag||']');
        print_msg('l_plan_dates_change_flag['||l_plan_dates_change_flag||']l_mfc_cost_change_flag['||l_mfc_cost_change_flag||']');
        print_msg('l_quantity_changed_flag['||l_quantity_changed_flag||']g_wp_version_flag['||g_wp_version_flag||']');
	print_msg('negQtyChagFlag['||l_neg_Qty_Changflag_tab(i)||']negRawChgFlag['||l_neg_Raw_Changflag_tab(i)||']');
 	print_msg('negBurdChagFlag['||l_neg_Burd_Changflag_tab(i)||']negRevChagFlag['||l_neg_rev_Changflag_tab(i)||']');
	End if;
            IF l_txn_currency_override_tab.EXISTS(i) THEN  --{
                           --print_msg('l_txn_currency_override_tab(i) ['||l_txn_currency_override_tab(i));
                           l_txn_currency_code_override  := l_txn_currency_override_tab(i);
                           IF l_txn_currency_code_override is NOT NULL Then
                /* Currency code override can be changed only from TA flow */
                IF g_wp_version_flag <> 'Y' Then
                    OPEN get_line_info(l_resource_assignment_id);
                                FETCH get_line_info INTO
                                         g_task_name,g_resource_name;
                                CLOSE get_line_info;
                    l_stage := 363;
                                        add_msgto_stack
                                        ( p_msg_name => 'PA_FP_INVALID_CURCODE_OVR'
                                        ,p_token1     => 'G_PROJECT_NAME'
                                        ,p_value1     => g_project_name
                                        ,p_token2     => 'G_TASK_NAME'
                                        ,p_value2     => g_task_name
                                        ,p_token3     => 'G_RESOURCE_NAME'
                                        ,p_value3     => g_resource_name
                                        ,p_token4     => 'G_CURRENCY_CODE'
                                        ,p_value4     => l_txn_currency_code_override
                    );
                                        l_entire_return_status := FND_API.G_RET_STS_ERROR;
                        RAISE skip_record;
                Elsif (l_actual_exists_flag = 'Y' AND g_wp_version_flag = 'Y') Then
                    OPEN get_line_info(l_resource_assignment_id);
                                        FETCH get_line_info INTO
                                                 g_task_name,g_resource_name;
                                        CLOSE get_line_info;
                    l_stage := 363;
                                        add_msgto_stack
                                        ( p_msg_name => 'PA_FP_INVALID_ACT_CURCODE_OVR'
                                        ,p_token1     => 'G_PROJECT_NAME'
                                        ,p_value1     => g_project_name
                                        ,p_token2     => 'G_TASK_NAME'
                                        ,p_value2     => g_task_name
                                        ,p_token3     => 'G_RESOURCE_NAME'
                                        ,p_value3     => g_resource_name
                                        ,p_token4     => 'G_CURRENCY_CODE'
                                        ,p_value4     => l_txn_currency_code_override
                                        );
                                        l_entire_return_status := FND_API.G_RET_STS_ERROR;
                    RAISE skip_record;
                /* Note: If only currency with out change in quantity, then refresh else spread the addl qty */
                                ElsIF (NVL(l_delete_budget_lines,'N') <> 'Y' AND l_quantity_changed_flag = 'N'
                    and NVL(p_apply_progress_flag,'N') <> 'Y' ) Then
                   g_mfc_cost_refresh_tab(l_countr) := 'Y';
                                   --print_msg('setting mfc cost refresh tab Y for currency code override');
                End If;
                           END IF;
                        END IF; --}

            l_bdgt_line_sDate := null;
            l_bdgt_line_eDate := null;
                --print_msg(to_char(l_stage)||' Get Budget Lines amts for comparison');
                IF l_line_start_date_tab.EXISTS(i) AND l_line_end_date_tab.EXISTS(i) THEN
                    --print_msg('l_line_start_date_tab.COUNT > 0 AND l_line_end_date_tab.COUNT > 0');
                    IF l_line_start_date_tab(i) IS NOT NULL Then
                   l_bdgt_line_sDate := l_line_start_date_tab(i);
                End IF;
            End If;
            IF l_line_end_date_tab.EXISTS(i) THEN
                If l_line_end_date_tab(i) IS NOT NULL THEN
                                   l_bdgt_line_eDate := l_line_end_date_tab(i);
                                End IF;
            End if;
            IF l_spread_amts_flag_tab.EXISTS(i) Then
                l_spread_amounts_flag     := NVL(l_spread_amts_flag_tab(i),'N');
            Else
                    l_spread_amounts_flag     := 'N';
            End If;
            /* assign the dates only if the process called in BUDGET_LINE context */
            IF p_source_context  = 'BUDGET_LINE' THEN
                    g_line_start_date  := l_bdgt_line_sDate;
                g_line_end_date    := l_bdgt_line_eDate;
                ELSE
                    g_line_start_date  := to_date(NULL);
                    g_line_end_date  := to_date(NULL);
                l_bdgt_line_sDate := null;
                l_bdgt_line_eDate := null;
                END IF;
            g_line_sdate_tab(l_countr) := g_line_start_date ;
                    g_line_edate_tab(l_countr) := g_line_end_date;

            --print_msg('After setting gLineStartEndDates:SD['||g_line_start_date||']ED['||g_line_end_date||']');
            /* check the budget line end dates and etc dates */
                    IF g_spread_from_date IS NOT NULL AND g_line_end_date is NOT NULL THEN
                            IF g_spread_from_date > g_line_end_date THEN
                               l_stage := 363;
                    OPEN get_line_info(l_resource_assignment_id);
                                        FETCH get_line_info INTO
                                                 g_task_name,g_resource_name;
                                        CLOSE get_line_info;
                                add_msgto_stack
                                ( p_msg_name => 'PA_FP_ETC_SPREAD_DATE',
                                p_token1     => 'G_PROJECT_NAME' ,
                                p_value1     => g_project_name,
                                p_token2     => 'G_TASK_NAME',
                                p_value2     => g_task_name,
                                p_token3     => 'G_RESOURCE_NAME',
                                p_value3     => g_resource_name,
                                p_token4     => 'G_SPREAD_FROM_DATE',
                                p_value4     => g_spread_from_date);
                                l_entire_return_status := FND_API.G_RET_STS_ERROR;
                    RAISE skip_record;
                        End IF;
                    END IF;

            If l_total_revenue_tab.EXISTS(i) Then
               l_txn_revenue  := l_total_revenue_tab(i);
            End If;

            If l_total_raw_cost_tab.EXISTS(i) THEN
               l_txn_raw_cost    := l_total_raw_cost_tab(i);
            End if;

            IF l_raw_cost_rate_tab.EXISTS(i) Then
                       l_raw_cost_rate := l_raw_cost_rate_tab(i);
            End IF;

            IF l_rw_cost_rate_override_tab.EXISTS(i) THEN
                        l_rw_cost_rate_override :=  l_rw_cost_rate_override_tab(i);
            End If;

            IF l_total_qty_tab.EXISTS(i) Then
                   l_txn_plan_quantity := l_total_qty_tab(i);
            End IF;

            IF l_addl_qty_tab.EXISTS(i) Then
                   l_txn_plan_quantity_addl   := l_addl_qty_tab(i);
            End IF;
            IF l_total_burdened_cost_tab.EXISTS(i) Then
                   l_txn_burdened_cost   := l_total_burdened_cost_tab(i);
            End IF;

            IF l_b_cost_rate_tab.EXISTS(i) Then
                   l_burden_cost_rate  := l_b_cost_rate_tab(i);
            End IF;
                IF l_b_cost_rate_override_tab.EXISTS(i) Then
                   l_burden_cost_rate_override := l_b_cost_rate_override_tab(i);
                END IF;
                IF l_bill_rate_tab.EXISTS(i) Then
                   l_bill_rate  := l_bill_rate_tab(i);
            End If;
                IF l_bill_rate_override_tab.COUNT > 0 THEN
                   l_bill_rate_override := l_bill_rate_override_tab(i);
            End If;
            l_quantity_changed_flag := 'N';
                l_raw_cost_changed_flag := 'N';
                l_rw_cost_rate_changed_flag := 'N';
                l_burden_cost_changed_flag := 'N';
                l_b_cost_rate_changed_flag := 'N';
                l_rev_changed_flag := 'N';
                l_bill_rate_changed_flag := 'N';
                l_bill_rt_ovr_changed_flag := 'N';

            /* Check for mass adjust is called for the correct attributes
             * from page or AMG apis, For Non-Rate transactions, mass adjust of cost rate is not allowed
             * so if they call then skip this transaction
             */
            If g_mass_adjust_flag = 'Y' Then --{
		IF g_wp_version_flag = 'Y' Then
		   IF l_rate_based_flag = 'N' Then
			If p_cost_rate_adj_pct is NOT NULL Then
				print_msg('Bypassing the pl txn for CostRate Adj for Non-Rate Pl txn');
                            	RAISE skip_record;
			End If;
		   End If;
		Else
                   IF l_rate_based_flag = 'N' Then
                     IF g_fp_budget_version_type in ('COST','ALL') Then
                        If (p_quantity_adj_pct is NOT NULL
			    OR p_cost_rate_adj_pct is NOT NULL
			    OR p_burdened_rate_adj_pct is NOT NULL)  Then
                            print_msg('Bypassing the pl txn for quantity and Rate Adjustments for Non-Rate Pl txn');
                            RAISE skip_record;
                        End If;
                     End If;
		     If  g_fp_budget_version_type in ('REVENUE','ALL') Then
                        If (p_quantity_adj_pct is NOT NULL
			    OR p_bill_rate_adj_pct is NOT NULL ) Then
                            print_msg('Bypassing the pl txn for BillRate Adj for Non-Rate Pl txn');
                            RAISE skip_record;
                        End If;
                     End If;
		  End If;
                End If;
            End If; --}

            l_stage := 275;
            /* Check if the budget is of REVENUE/ALL and related to Change Order/Change Requrest then Only Agreement Currency
             * takes the precedence*/
            IF  G_AGR_CONV_REQD_FLAG = 'Y' Then
                print_msg(l_stage||'The Entire Budget version can have Only one Agremeent Currency['||g_agr_currency_code||']');
                g_ra_bl_txn_currency_code := g_agr_currency_code;
                g_Wp_curCode_tab(l_countr) := g_ra_bl_txn_currency_code;

            Else

               /* the following code is added for workplan: can have only one currency for resource assignment*/
                   IF p_source_context = 'BUDGET_LINE' and g_wp_version_flag = 'Y' Then
                    If g_ra_bl_txn_currency_code is NOT NULL Then
                    null;
                Else
                        g_ra_bl_txn_currency_code := NULL;
                End If;
                   Else
                g_ra_bl_txn_currency_code := NULL;
                   End If;

                   IF g_wp_version_flag = 'Y' and g_ra_bl_txn_currency_code is NULL  THEN
                    OPEN get_bl_currency;
                    FETCH get_bl_currency INTO g_ra_bl_txn_currency_code;
                    IF get_bl_currency%NOTFOUND THEN
                        g_ra_bl_txn_currency_code := NULL;
                        --print_msg(l_stage||':set g_ra_bl_txn_currency_code to NULL := '||g_ra_bl_txn_currency_code);
                    ELSE
                        NULL;
                        --print_msg(l_stage||':set g_ra_bl_txn_currency_code to bl.txn_currency_code := '||g_ra_bl_txn_currency_code);
                    END IF;
                    CLOSE get_bl_currency;

                /* Bug fix: Refresh rates doesnot refresh the currencies */
                IF l_actual_exists_flag = 'N'
                    AND ( g_refresh_rates_flag in ('Y','R','C')
                          OR g_mfc_cost_refresh_tab(l_countr) = 'Y'
                          OR l_rlm_id_change_flag = 'Y' )  Then
                    g_ra_bl_txn_currency_code := NULL;
                            --print_msg(l_stage||':set g_ra_bl_txn_currency_code to NULL during refresh rates mode as no actual exists ');
                End IF;
                            IF l_txn_currency_code_override IS NOT NULL THEN
                                    --print_msg(' set g_ra_bl_txn_currency_code to l_txn_currency_code_override['||l_txn_currency_code_override);
                                    g_ra_bl_txn_currency_code := l_txn_currency_code_override;
                            END IF;
                g_Wp_curCode_tab(l_countr) := g_ra_bl_txn_currency_code ;
                /* Bug fix:4394666: During apply progress mode always retain the transaction currency code for the resource
                                 * Reason: When progress cycle is shifted, we clear all closed periods so the transaction currency is lost
                                 * when etc start date is later than ra planning end date.
                                 */
                                IF NVL(p_apply_progress_flag,'N') = 'Y' Then
                                   IF g_Wp_curCode_tab(l_countr) is NULL Then
                                        g_Wp_curCode_tab(l_countr) := l_txn_currency_code;
                    --print_msg('Setting WP currency to txn currency code during apply progress mode');
                                   End If;
                                End If;
                                /* End of bug fix: 4394666 */

                   END IF; --g_wp_version_flag = 'Y'

            END If; -- end of g_agr_conv_reqd_flag
            /* Bug fix::4396300 */
                        IF (p_calling_module in ('BUDGET_GENERATION','FORECAST_GENERATION')
                            AND g_ra_bl_txn_currency_code  is NULL ) Then
                                --print_msg('Setting the wp currency code context during budget/forecst generation process');
                                g_Wp_curCode_tab(l_countr) := l_txn_currency_code;
                        End If;
                        /* Bug fix:4396300 */
            --print_msg(' Value of g_ra_bl_txn_currency_code ['||g_ra_bl_txn_currency_code||']Wp_curCode_tab['||g_Wp_curCode_tab(l_countr)||']');

                        l_stage := 276;
                        --print_msg(to_char(l_stage)||'CHK if l_delete_budget_lines ['||l_delete_budget_lines||']');
                        IF l_delete_budget_lines = 'Y' THEN
				If P_PA_DEBUG_MODE = 'Y' Then
                                print_msg(to_char(l_stage)||' Delete from pa_budget_lines, rollup pfc numbers, and skip record');
				End if;
                                pa_fp_calc_plan_pkg.delete_budget_lines
                                        (p_budget_version_id          => p_budget_version_id
                                        ,p_resource_assignment_id     => l_resource_assignment_id
                                        ,p_txn_currency_code          => l_txn_currency_code
                                        ,p_line_start_date            => g_line_start_date
                                        ,p_line_end_date              => g_line_end_date
                                        ,p_source_context             => g_source_context
                                        ,x_return_status              => l_return_status
                                        ,x_msg_count                  => x_msg_count
                                        ,x_msg_data                   => x_msg_data
                                        ,x_num_rowsdeleted            => l_num_rowsdeleted
                                        );
				If P_PA_DEBUG_MODE = 'Y' Then
                                print_msg('Number of budgetLines deleted['||l_num_rowsdeleted||']retSts['||l_return_status||']');
				End if;
                                IF l_return_status <> 'S' Then
                                        x_return_status := l_return_status;
                                        l_entire_return_status := l_return_status;
                                END IF;
                		IF NVL(p_raTxn_rollup_api_call_flag,'Y') = 'Y' AND nvl(l_entire_return_status,'S') = 'S' Then
			    	   If p_source_context = 'RESOURCE_ASSIGNMENT' Then
					l_raTxnRec_mode := 'RES_ATTRB_CHANGE';
			    	   Else
					l_raTxnRec_mode := 'DELETE_BL';
			    	End If;
                            	--print_msg('Calling populate_raTxn_Recs API for delete of for Resource attribute changes');
                                delete_raTxn_Tmp;
                                populate_raTxn_Recs (
                                p_budget_version_id     => g_budget_version_id
                                ,p_source_context       => 'BUDGET_LINE' -- to rollup the amounts
                                ,p_calling_mode         => l_raTxnRec_mode
                                ,p_delete_flag          => 'N'
                                ,p_delete_raTxn_flag    => 'N'
                                ,p_refresh_rate_flag    => g_refresh_rates_flag
                                ,p_rollup_flag          => 'Y'
                                ,p_call_raTxn_rollup_flag => 'Y'
				,p_resource_assignment_id => l_resource_assignment_id
            			,p_txn_currency_code	 => l_txn_currency_code
				,p_start_date           => g_line_start_date
                                ,x_return_status        => l_return_status
                                ,x_msg_count            => x_msg_count
                                ,x_msg_data             => x_msg_data
                                );
                            	--print_msg('AFter calling populate_raTxn_Recs retSTst['||l_return_status||']MsgData['||x_msg_data||']');
                            	IF l_return_status <> 'S' Then
                                    x_return_status := l_return_status;
                                    l_entire_return_status := l_return_status;
                            	END IF;
                    		END IF;

                                IF p_source_context = 'RESOURCE_ASSIGNMENT' Then
                                   IF (l_spread_amounts_flag = 'N' OR l_num_rowsdeleted > 0) Then
                                        l_spread_amounts_flag := 'Y';
                                   END If;
                                End If;
                        END IF;  --IF l_delete_budget_lines = 'Y'

            l_stage := 277;
            /*Progess can be applied in two modes, 1. ETC may come in along with actuals
                          2. ETC may come in with NO actuals exists on the budget lines.
                          so this needs to handled properly, when no actuals exists on budget line
                          the ETC qty should be respread, so delete all the budget lines after the etc start date
                          and respread the given ETC so this shoul go through normal flow.
              so set the g_apply_progress_flag to 'N'.
                          When actuals Exists, by pass the apply precedence rules,
             */
            IF g_apply_progress_flag_tab.EXISTS(i) THEN
                l_apply_progress_flag := g_apply_progress_flag_tab(i);
            Else
                l_apply_progress_flag := 'N';
            End If;

        /* BudgetLine comparision and applying precedence rules will require only if we call the spread api
         * to populate the budget lines in rollup tmp. For refresh rates and mass adjust, the existsing lines
         * from budgetlines will be copied into rollup tmp in calculate api. so NO need to apply and compare
         */
            IF (g_refresh_conv_rates_flag ='N'
                AND g_refresh_rates_flag    ='N'
                AND g_mass_adjust_flag      = 'N'
            AND g_mfc_cost_refresh_tab(l_countr) = 'N' ) THEN  --{

            /* Rounding Enhancements: round off the given quantity and amounts before start processing */
               If l_txn_plan_quantity is NOT NULL Then
                If l_rate_based_flag = 'N' THEN
                    l_txn_plan_quantity := pa_currency.round_trans_currency_amt1(l_txn_plan_quantity,l_txn_currency_code);
                Else
                    l_txn_plan_quantity := round_quantity(l_txn_plan_quantity);
                End If;
               End If;

               If l_txn_raw_cost is NOT NULL Then
                l_txn_raw_cost := pa_currency.round_trans_currency_amt1(l_txn_raw_cost,l_txn_currency_code);
               End If;
               If l_txn_burdened_cost is NOT NULL Then
                l_txn_burdened_cost := pa_currency.round_trans_currency_amt1(l_txn_burdened_cost,l_txn_currency_code);
               End If;
               If l_txn_revenue is NOT NULL Then
                l_txn_revenue := pa_currency.round_trans_currency_amt1(l_txn_revenue,l_txn_currency_code);
               End If;

            /* compare with budget line values
            * and populate the changed flags. Based on these flag apply the
            * precedence and set the addl variables to pass it to spread api
            */
            l_stage := 280;
	    If P_PA_DEBUG_MODE = 'Y' Then
            print_msg(l_stage||'Before calling Compare_With_BdgtLine_Values');
            print_msg('l_apply_progress_flag['||l_apply_progress_flag||']l_txn_plan_quantity['||l_txn_plan_quantity||']');
            print_msg('l_txn_raw_cost['||l_txn_raw_cost||']l_raw_cost_rate['||l_raw_cost_rate||']rwcostrateoverride['||l_rw_cost_rate_override);
            print_msg('l_txn_burdened_cost['||l_txn_burdened_cost||']l_burden_cost_rate['||l_burden_cost_rate||']');
            print_msg('l_burden_cost_rate_override['||l_burden_cost_rate_override);
            print_msg('l_txn_revenue['||l_txn_revenue||']l_bill_rate['||l_bill_rate||']l_bill_rate_override['||l_bill_rate_override||']');
            print_msg('l_org_quantity_changed_flag['||l_org_quantity_changed_flag||']l_org_raw_cost_changed_flag['||l_org_raw_cost_changed_flag||']');
            print_msg('l_org_rw_rate_changed_flag['||l_org_rw_rate_changed_flag||']org_burdencostchanged_flag['||l_org_burden_cost_changed_flag||']');
            print_msg('l_org_b_cost_rate_changed_flag['||l_org_b_cost_rate_changed_flag||']l_org_rev_changed_flag['||l_org_rev_changed_flag||']');
            print_msg('l_org_bill_rate_changed_flag['||l_org_bill_rate_changed_flag||']');
	    End If;

            Compare_With_BdgtLine_Values
                (p_resource_ass_id => l_resource_assignment_id
                ,p_txn_currency_code => l_txn_currency_code
                ,p_line_start_date   => g_line_start_date
                ,p_line_end_date     => g_line_end_date
                ,p_bdgt_version_type => g_fp_budget_version_type
                ,p_rate_based_flag   => l_rate_based_flag
                ,p_apply_progress_flag => l_apply_progress_flag
                ,p_resAttribute_changed_flag => l_resAttribChangeFlag
                     /* Bug fix:4263265 Added these param to avoid deriving rate overrides */
                    ,p_qty_changed_flag          => l_org_quantity_changed_flag
                    ,p_raw_cost_changed_flag     => l_org_raw_cost_changed_flag
                    ,p_rw_cost_rate_changed_flag => l_org_rw_rate_changed_flag
                    ,p_burden_cost_changed_flag  => l_org_burden_cost_changed_flag
                    ,p_b_cost_rate_changed_flag  => l_org_b_cost_rate_changed_flag
                    ,p_rev_changed_flag          => l_org_rev_changed_flag
                    ,p_bill_rate_changed_flag    => l_org_bill_rate_changed_flag
		,p_revenue_only_entry_flag  	=> l_rev_only_entry_flag_tab(i)
                /* End of bug fix:4263265 */
                ,p_txn_currency_code_ovr => l_txn_currency_code_override
                ,p_txn_plan_quantity  => l_txn_plan_quantity
                ,p_txn_raw_cost       => l_txn_raw_cost
                ,p_txn_raw_cost_rate  => l_raw_cost_rate
                ,p_txn_rw_cost_rate_override => l_rw_cost_rate_override
                ,p_txn_burdened_cost    => l_txn_burdened_cost
                ,p_txn_b_cost_rate  => l_burden_cost_rate
                ,p_txn_b_cost_rate_override => l_burden_cost_rate_override
                ,p_txn_revenue => l_txn_revenue
                ,p_txn_bill_rate => l_bill_rate
                ,p_txn_bill_rate_override => l_bill_rate_override
                ,x_qty_changed_flag => l_quantity_changed_flag
                ,x_raw_cost_changed_flag => l_raw_cost_changed_flag
                ,x_rw_cost_rate_changed_flag => l_rw_cost_rate_changed_flag
                ,x_burden_cost_changed_flag => l_burden_cost_changed_flag
                ,x_b_cost_rate_changed_flag => l_b_cost_rate_changed_flag
                ,x_rev_changed_flag         => l_rev_changed_flag
                ,x_bill_rate_changed_flag   => l_bill_rate_changed_flag
                ,x_bill_rt_ovr_changed_flag => l_bill_rt_ovr_changed_flag
                    ,x_txn_revenue_addl  => l_txn_revenue_addl
                                ,x_txn_raw_cost_addl => l_txn_raw_cost_addl
                                ,x_txn_plan_quantity_addl => l_txn_plan_quantity_addl
                                ,x_txn_burdened_cost_addl => l_txn_burdened_cost_addl
                ,x_init_raw_cost         => l_txn_init_raw_cost
                        ,x_init_burdened_cost    => l_txn_init_burdened_cost
                        ,x_init_revenue          => l_txn_init_revenue
                        ,x_init_quantity         => l_txn_init_quantity
                ,x_bl_raw_cost           => l_bl_raw_cost
                    ,x_bl_burdened_cost      => l_bl_burdened_cost
                    ,x_bl_revenue            => l_bl_revenue
                    ,x_bl_quantity           => l_bl_quantity
                );

            l_stage := 281;
	    If P_PA_DEBUG_MODE = 'Y' Then
            print_msg(l_stage||'After calling Compare_With_BdgtLine_Values');
            print_msg('l_txn_plan_quantity['||l_txn_plan_quantity||']');
            print_msg('l_txn_raw_cost['||l_txn_raw_cost||']l_raw_cost_rate['||l_raw_cost_rate||']rwcostrateoverride['||l_rw_cost_rate_override);
            print_msg('l_txn_burdened_cost['||l_txn_burdened_cost||']l_burden_cost_rate['||l_burden_cost_rate||']');
            print_msg('l_burden_cost_rate_override['||l_burden_cost_rate_override);
            print_msg('l_txn_revenue['||l_txn_revenue||']l_bill_rate['||l_bill_rate||']l_bill_rate_override['||l_bill_rate_override||']');
            print_msg('l_quantity_changed_flag['||l_quantity_changed_flag||']l_raw_cost_changed_flag['||l_raw_cost_changed_flag||']');
            print_msg('l_rw_cost_rate_changed_flag['||l_rw_cost_rate_changed_flag||']burdencostchanged_flag['||l_burden_cost_changed_flag||']');
            print_msg('l_b_cost_rate_changed_flag['||l_b_cost_rate_changed_flag||']l_rev_changed_flag['||l_rev_changed_flag||']');
            print_msg('l_bill_rate_changed_flag['||l_bill_rate_changed_flag||']billrtovrchanged_flag['||l_bill_rt_ovr_changed_flag||']');
                        print_msg('l_txn_raw_cost_addl['||l_txn_raw_cost_addl||']l_txn_plan_quantity_addl['||l_txn_plan_quantity_addl||']');
                        print_msg('l_txn_burdened_cost_addl['||l_txn_burdened_cost_addl||']l_txn_init_raw_cost['||l_txn_init_raw_cost||']');
                    print_msg('l_txn_init_burdened_cost['||l_txn_init_burdened_cost||']l_txn_init_revenue['||l_txn_init_revenue||']');
                    print_msg('l_txn_init_quantity['||l_txn_init_quantity||']');
             print_msg('l_bl_raw_cost['||l_bl_raw_cost||']l_bl_revenue['||l_bl_revenue||']l_bl_quantity['||l_bl_quantity||']');
	     End If;

            /* Reset changed flag based on the resource Attribute Flags */
            IF ( l_re_spread_amts_flag = 'Y'
                             OR l_sp_curve_change_flag = 'Y'
                             OR l_spfix_date_change_flag = 'Y'
                             OR l_plan_dates_change_flag = 'Y'
                             OR l_rlm_id_change_flag = 'Y'
                 OR NVL(p_apply_progress_flag,'N') = 'Y' ) THEN
                --print_msg('Setting addl columns to NULL');
                -- derive addl quantity and spread addl quantity only then re stamp the
                -- override rates and currency cuonversion attributes
                -- l_quantity_changed_flag := 'N';
                            l_raw_cost_changed_flag := 'N';
                            l_rw_cost_rate_changed_flag := 'N';
                            l_burden_cost_changed_flag := 'N';
                            l_b_cost_rate_changed_flag := 'N';
                            l_rev_changed_flag := 'N';
                            l_bill_rate_changed_flag := 'N';
                            l_bill_rt_ovr_changed_flag := 'N';
                l_txn_raw_cost_addl      := NULL;
                l_txn_burdened_cost_addl := NULL;
                l_txn_revenue_addl       := NULL;
                /* when rates override rates only entered along with planning dates change, then call refresh mode */
                IF l_plan_dates_change_flag = 'Y' AND l_ra_in_multi_cur_flag = 'Y'  Then
                       IF (l_rw_cost_rate_override is NOT NULL AND l_rate_based_flag = 'Y') Then
                    l_rw_cost_rate_changed_flag := 'Y';
                   End If;
                   IF l_burden_cost_rate_override is NOT NULL Then
                    l_b_cost_rate_changed_flag := 'Y';
                   End If;

                   IF g_fp_budget_version_type in ('REVENUE') Then
                     IF (l_bill_rate_override is NOT NULL AND l_rate_based_flag = 'Y')  Then
                    l_bill_rate_changed_flag := 'Y';
                     End IF;
                   Elsif g_fp_budget_version_type in ('ALL') Then
                                     IF (l_bill_rate_override is NOT NULL)  Then
                                        l_bill_rate_changed_flag := 'Y';
                                     End IF;
                   END IF;
                END IF;
            End IF;
            /* Apply precedence rules to the additionals
            * based on the rate based flag, changed_flags
            * the outcome will determine whether spread and rate api needs to be called or not
            * since the logic is different and to avoid using tooo many if conditions to check the variables
            * seperate apis are written for rate base and non rate base
            * transactions
            */

            -- IPM changes - find the current override burden rate
            IF p_source_context = 'RESOURCE_ASSIGNMENT' THEN
               BEGIN
		l_curr_burden_rate := NULL;
 	        l_curr_bill_rate   := NULL;
 	        l_curr_cost_rate := NULL;
               SELECT rtx.txn_burden_cost_rate_override
             ,rtx.txn_bill_rate_override
             ,tmp.bill_markup_percentage
	     ,rtx.txn_raw_cost_rate_override
                 INTO l_curr_burden_rate
            ,l_curr_bill_rate
            ,l_curr_markup_percentage
	    ,l_curr_cost_rate
                 FROM pa_resource_asgn_curr rtx
             ,pa_fp_spread_calc_tmp tmp
                WHERE tmp.resource_assignment_id = l_resource_assignment_id
                  AND tmp.txn_currency_code = l_txn_currency_code
          AND rtx.resource_assignment_id = tmp.resource_assignment_id
          AND rtx.txn_currency_code = tmp.txn_currency_code;
          If l_curr_markup_percentage is NULL Then
            l_curr_bill_rate := NULL;
          End If;
               EXCEPTION WHEN OTHERS THEN
                  l_curr_burden_rate := NULL;
                  l_curr_bill_rate   := NULL;
		  l_curr_cost_rate := NULL;
               END;
            ELSE
               BEGIN
		l_curr_burden_rate := NULL;
 	        l_curr_bill_rate   := NULL;
 	        l_curr_cost_rate := NULL;
                  SELECT AVG(bl.burden_cost_rate_override)
            ,AVG(bl.txn_bill_rate_override)
            ,AVG(bl.txn_markup_percent)
	    ,AVG(bl.txn_cost_rate_override)
                    INTO l_curr_burden_rate
            ,l_curr_bill_rate
            ,l_curr_markup_percentage
	    ,l_curr_cost_rate
                    FROM pa_budget_lines bl
                   WHERE bl.resource_assignment_id = l_resource_assignment_id
                     AND bl.txn_currency_code = l_txn_currency_code
             AND bl.start_date between l_bdgt_line_sDate and l_bdgt_line_eDate;
            If l_curr_markup_percentage is NULL Then
                            l_curr_bill_rate := NULL;
                    End If;
               EXCEPTION WHEN OTHERS THEN
                     l_curr_burden_rate := NULL;
                     l_curr_bill_rate := NULL;
		     l_curr_cost_rate := NULL;
               END;
            END IF;

            IF  NVL(l_apply_progress_flag,'N') <> 'Y' THEN
               IF  l_rate_based_flag = 'N' THEN --{
                l_stage := 282;
		If P_PA_DEBUG_MODE = 'Y' Then
                print_msg(l_stage||'Calling Apply_NON_RATE_BASE_precedence api');
		End If;
                Apply_NON_RATE_BASE_precedence(
                   p_txn_currency_code         => l_txn_currency_code
                  ,p_rate_based_flag           => l_rate_based_flag
                  ,p_budget_version_type       => g_fp_budget_version_type
                  ,p_qty_changed_flag          => l_quantity_changed_flag
                  ,p_raw_cost_changed_flag     => l_raw_cost_changed_flag
                  ,p_rw_cost_rate_changed_flag => l_rw_cost_rate_changed_flag
                  ,p_burden_cost_changed_flag  => l_burden_cost_changed_flag
                  ,p_b_cost_rate_changed_flag  => l_b_cost_rate_changed_flag
                  ,p_rev_changed_flag          => l_rev_changed_flag
                  ,p_bill_rate_changed_flag    => l_bill_rate_changed_flag
                  ,p_bill_rt_ovr_changed_flag  => l_bill_rt_ovr_changed_flag
                  ,p_init_raw_cost             => l_txn_init_raw_cost
                  ,p_init_burdened_cost        => l_txn_init_burdened_cost
                  ,p_init_revenue              => l_txn_init_revenue
                  ,p_init_quantity             => l_txn_init_quantity
                  ,p_bl_raw_cost               => l_bl_raw_cost
                  ,p_bl_burdened_cost          => l_bl_burdened_cost
                  ,p_bl_revenue                => l_bl_revenue
                  ,p_bl_quantity               => l_bl_quantity
		  ,p_curr_cost_rate            => l_curr_cost_rate
                  ,p_curr_burden_rate          => l_curr_burden_rate
                  ,p_curr_bill_rate            => l_curr_bill_rate
		  ,p_revenue_only_entry_flag   => l_rev_only_entry_flag_tab(i)
                  ,x_txn_plan_quantity         => l_txn_plan_quantity
                  ,x_txn_raw_cost              => l_txn_raw_cost
                  ,x_txn_raw_cost_rate         => l_raw_cost_rate
                  ,x_txn_rw_cost_rate_override => l_rw_cost_rate_override
                  ,x_txn_burdened_cost         => l_txn_burdened_cost
                  ,x_txn_b_cost_rate           => l_burden_cost_rate
                  ,x_txn_b_cost_rate_override  => l_burden_cost_rate_override
                  ,x_txn_revenue               => l_txn_revenue
                  ,x_txn_bill_rate             => l_bill_rate
                  ,x_txn_bill_rate_override    => l_bill_rate_override
                  ,x_txn_revenue_addl          => l_txn_revenue_addl
                  ,x_txn_raw_cost_addl         => l_txn_raw_cost_addl
                  ,x_txn_plan_quantity_addl    => l_txn_plan_quantity_addl
                  ,x_txn_burdened_cost_addl    => l_txn_burdened_cost_addl
                  );
		If P_PA_DEBUG_MODE = 'Y' Then
                print_msg(l_stage||'End of Apply_NON_RATE_BASE_precedence api');
		End if;
               ELse -- rate base flag = 'Y'


                l_stage := 283;
		If P_PA_DEBUG_MODE = 'Y' Then
                print_msg(l_stage||'Calling Apply_RATE_BASE_precedence api');
		End If;
                Apply_RATE_BASE_precedence(
                   p_txn_currency_code         => l_txn_currency_code
                  ,p_rate_based_flag           => l_rate_based_flag
                  ,p_budget_version_type       => g_fp_budget_version_type
                  ,p_qty_changed_flag          => l_quantity_changed_flag
                  ,p_raw_cost_changed_flag     => l_raw_cost_changed_flag
                  ,p_rw_cost_rate_changed_flag => l_rw_cost_rate_changed_flag
                  ,p_burden_cost_changed_flag  => l_burden_cost_changed_flag
                  ,p_b_cost_rate_changed_flag  => l_b_cost_rate_changed_flag
                  ,p_rev_changed_flag          => l_rev_changed_flag
                  ,p_bill_rate_changed_flag    => l_bill_rate_changed_flag
                  ,p_bill_rt_ovr_changed_flag  => l_bill_rt_ovr_changed_flag
                  ,p_init_raw_cost             => l_txn_init_raw_cost
                  ,p_init_burdened_cost        => l_txn_init_burdened_cost
                  ,p_init_revenue              => l_txn_init_revenue
                  ,p_init_quantity             => l_txn_init_quantity
                  ,p_bl_raw_cost               => l_bl_raw_cost
                  ,p_bl_burdened_cost          => l_bl_burdened_cost
                  ,p_bl_revenue                => l_bl_revenue
                  ,p_bl_quantity               => l_bl_quantity
		  ,p_curr_cost_rate            => l_curr_cost_rate
                  ,p_curr_burden_rate          => l_curr_burden_rate
                  ,p_curr_bill_rate            => l_curr_bill_rate
                  ,x_txn_plan_quantity         => l_txn_plan_quantity
                  ,x_txn_raw_cost              => l_txn_raw_cost
                  ,x_txn_raw_cost_rate         => l_raw_cost_rate
                  ,x_txn_rw_cost_rate_override => l_rw_cost_rate_override
                  ,x_txn_burdened_cost         => l_txn_burdened_cost
                  ,x_txn_b_cost_rate           => l_burden_cost_rate
                  ,x_txn_b_cost_rate_override  => l_burden_cost_rate_override
                  ,x_txn_revenue               => l_txn_revenue
                  ,x_txn_bill_rate             => l_bill_rate
                  ,x_txn_bill_rate_override    => l_bill_rate_override
                  ,x_txn_revenue_addl          => l_txn_revenue_addl
                  ,x_txn_raw_cost_addl         => l_txn_raw_cost_addl
                  ,x_txn_plan_quantity_addl    => l_txn_plan_quantity_addl
                  ,x_txn_burdened_cost_addl    => l_txn_burdened_cost_addl
                );
		If P_PA_DEBUG_MODE = 'Y' Then
                print_msg(l_stage||'End of Apply_RATE_BASE_precedence api');
		End If;
		End If;  --} // end of precedence rules
 	        /* Bug fix:5726773 */
 	        /* Added check here to catch the quantity change in precedence rules when
 	         * Changing cost and rates may change quantity from +ve to -ve or -ve to +ve */
 	        IF g_wp_version_flag = 'Y' Then --{
 	           If (l_quantity_changed_flag = 'N' and l_total_qty_tab.EXISTS(i)) Then
 	              if nvl(l_txn_plan_quantity,0) <> 0 and nvl(l_total_qty_tab(i),0) <> 0 Then
 	                  if sign(nvl(l_txn_plan_quantity,0)) <> sign(nvl(l_total_qty_tab(i),0)) Then
 	                         l_neg_Qty_Changflag_tab(i) := 'Y';
 	                  end if;
 	              End if;
                   End If;
		Else -- for budgets / forecasts
 	                   if l_rate_based_flag = 'Y' Then
 	                     If (l_quantity_changed_flag = 'N' and l_total_qty_tab.EXISTS(i)) Then
 	                       if nvl(l_txn_plan_quantity,0) <> 0 and nvl(l_total_qty_tab(i),0) <> 0 Then
 	                         if sign(nvl(l_txn_plan_quantity,0)) <> sign(nvl(l_total_qty_tab(i),0)) Then
 	                                 l_neg_Qty_Changflag_tab(i) := 'Y';
 	                         end if;
 	                       End if;
 	                     End If;
 	                   Else -- for non-rate based flag
 	                     If (g_fp_budget_version_type in ('COST','ALL')) Then
 	                         If l_neg_Raw_Changflag_tab(i) = 'Y' Then
 	                            l_neg_Qty_Changflag_tab(i) := 'Y';
 	                         Elsif g_fp_budget_version_type = 'ALL' and l_rev_only_entry_flag_tab(i) = 'Y' Then
 	                           If l_neg_rev_Changflag_tab(i) = 'Y' Then
 	                                 l_neg_Qty_Changflag_tab(i) := 'Y';
 	                           End If;
 	                         End If;
 	                     Elsif g_fp_budget_version_type = 'REVENUE' Then
 	                         If l_neg_rev_Changflag_tab(i) = 'Y' Then
 	                            l_neg_Qty_Changflag_tab(i) := 'Y';
 	                         End If;
 	                     End If;
 	                   End If;
 	                 End IF; --}

        /* IPM changes: If rates are nulled out from UI, it should refresh the rates from rate schedule */
        If l_cost_rt_miss_num_flag_tab(i) = 'Y' Then
                        l_rw_cost_rate_changed_flag := 'Y';
                        l_rw_cost_rate_override := NULL;
                End If;
                If l_burd_rt_miss_num_flag_tab(i) = 'Y' Then
                        l_b_cost_rate_changed_flag := 'Y';
                        l_burden_cost_rate_override := NULL;
                End If;
                If l_bill_rt_miss_num_flag_tab(i) = 'Y' Then
                        l_bill_rate_changed_flag := 'Y';
                        l_bill_rate_override := NULL;
                End If;
              /* Reset Additionals based on the resource Attribute Flags */
                          IF ( l_re_spread_amts_flag = 'Y'
                             OR l_sp_curve_change_flag = 'Y'
                             OR l_spfix_date_change_flag = 'Y'
                             OR l_plan_dates_change_flag = 'Y'
                             OR l_rlm_id_change_flag = 'Y'
                             OR NVL(p_apply_progress_flag,'N') = 'Y' ) THEN
                                -- derive addl quantity and spread addl quantity only then re stamp the
                                -- override rates and currency cuonversion attributes
                                l_txn_raw_cost_addl      := NULL;
                                l_txn_burdened_cost_addl := NULL;
                                l_txn_revenue_addl       := NULL;
				l_neg_Qty_Changflag_tab(i) := 'N';
                          End IF;

              /* Performance Impr: When Rate alone changed, then no need to call the spread api
               * copy budget lines to rollup tmp and update the changed rates
               * doing this will improve performance by 50%
               */
              IF NVL(l_txn_plan_quantity_addl,0) = 0
                 AND ( (l_raw_cost_changed_flag = 'Y' AND
                        l_rate_based_flag = 'Y')
                      OR l_rw_cost_rate_changed_flag = 'Y'
                      OR l_burden_cost_changed_flag = 'Y'
                      OR l_b_cost_rate_changed_flag ='Y'
                      OR l_rev_changed_flag = 'Y'
                      OR l_bill_rate_changed_flag = 'Y'
                      OR l_bill_rt_ovr_changed_flag = 'Y'  ) Then
                g_rtChanged_Ra_Flag_tab(l_countr) := 'Y';
              End If;

              /*Corner case bug 6429285:
                If a rate based resource is added as non rate based resource assignment
                in pa_resource_asgn_curr and pa_budget_lines quantity will be populated
                as raw_cost and display_quantity will be null.Now if we want to enter
                the quantity same as raw cost (i.e existing quantity)the display_quantity will never be populated.
                Also in this case populating the display_quantity is not enough we need to
                give precedence to quantity and re-populate the raw cost,burden cost
                and revenue based on quantity. This will happen only when we recalculate the
                amounts. In this case there is no need to re-spread the amounts. So setting
                rate changed flag because the ra will be treated as rate based and recalculated again
                in this process.

                This fix is inspired by fix 5088589.
              */
              --Bug 6429285
              If g_wp_version_flag ='N' and NVL(l_txn_plan_quantity_addl,0) = 0 and nvl(l_quantity_changed_flag,'N') = 'Y' Then
                    g_rtChanged_Ra_Flag_tab(l_countr) := 'Y';
              end if;
              --Bug 6429285

	     /* bug fix:5088589: Corner case: For revenue only entered trx. when raw cost is changed and which is
             * same as existing quantity, then process ignores the changes
             */
	    If g_fp_budget_version_type = 'ALL'
		AND l_rate_based_flag = 'N'
		AND NVL(l_txn_plan_quantity_addl,0) = 0
		AND g_rtChanged_Ra_Flag_tab(l_countr) = 'N' Then
                If l_raw_cost_changed_flag = 'Y' Then
                   If l_txn_raw_cost = l_bl_quantity and l_bl_quantity = l_bl_revenue Then
                   	--print_msg('283: set the rate change flag to Y so that it goes throguh refresh mode and updates');
			g_rtChanged_Ra_Flag_tab(l_countr) := 'Y';
                   	IF nvl(l_rw_cost_rate_override , 1) <> 0 THEN
                               l_rw_cost_rate_override := 1;
                   	END IF;
                   End If;
		End If;
            End If; --end of bug fix:5088589

            END IF; -- end of applyprogress mode
        END IF;  --}  end of bl comparision

        /* Bug fix:4295967 */
        IF NVL(p_apply_progress_flag,'N') = 'Y' Then
           If NVL(l_txn_plan_quantity_addl,0) = 0 Then
            g_applyProg_refreshRts_tab(l_countr) := 'Y';
           End If;
        End If;

        /* If delete flag is passed in budget line context then, spread or refresh should not be called
        * just delete the budget lines */
        IF p_source_context = 'BUDGET_LINE'
           AND l_delete_budget_lines = 'Y' THEN
            	g_rtChanged_Ra_Flag_tab(l_countr) := 'N';
            	l_txn_raw_cost_addl      := NULL;
                l_txn_burdened_cost_addl := NULL;
                l_txn_revenue_addl       := NULL;
		If g_fp_budget_version_type = 'ALL' Then
		   If l_rate_based_flag = 'N' AND l_re_spread_amts_flag = 'Y' Then
			NULL;
		   Else
            		l_txn_plan_quantity_addl := NULL;
		   End If;
		Else
			l_txn_plan_quantity_addl := NULL;
		End If;
        END IF;

   l_stage := 300;
	If P_PA_DEBUG_MODE = 'Y' Then
   print_msg(to_char(l_stage)||' Local Variables populated from TAB IN parameters');
    print_msg(' l_delete_budget_lines['||l_delete_budget_lines||']l_spread_amounts_flag['||l_spread_amounts_flag||']');
    print_msg('l_txn_currency_code['||l_txn_currency_code||']l_txn_currency_code_override['||l_txn_currency_code_override||']');
    print_msg('l_txn_plan_quantity['||to_char(l_txn_plan_quantity)||']l_txn_plan_quantity_addl['||to_char(l_txn_plan_quantity_addl)||']');
    print_msg('l_txn_raw_cost['||to_char(l_txn_raw_cost)||']l_txn_raw_cost_addl['||to_char(l_txn_raw_cost_addl)||']');
    print_msg('l_txn_burdened_cost['||to_char(l_txn_burdened_cost)||']l_txn_burdened_cost_addl['||to_char(l_txn_burdened_cost_addl)||']');
    print_msg('l_txn_revenue['||to_char(l_txn_revenue)||']l_txn_revenue_addl['||to_char(l_txn_revenue_addl)||']');
    print_msg('l_raw_cost_rate[ '||to_char(l_raw_cost_rate)||']l_rw_cost_rate_override['||to_char(l_rw_cost_rate_override)||']');
    print_msg('l_burden_cost_rate['||to_char(l_burden_cost_rate)||']l_burden_cost_rate_override['||to_char(l_burden_cost_rate_override)||']');
    print_msg('l_bill_rate['||to_char(l_bill_rate)||']l_bill_rate_override['||to_char(l_bill_rate_override)||']');
    print_msg('g_line_start_date['||to_char(g_line_start_date)||']g_line_end_date ['||to_char(g_line_end_date)||']');
    print_msg('blInitRaw['||l_txn_init_raw_cost||']BlInitBurd['||l_txn_init_burdened_cost||'BlInitRev['||l_txn_init_revenue||']');
    print_msg('blinitQty['||l_txn_init_quantity||']blPlanRaw['||l_bl_raw_cost||']BlPlanBurd['||l_bl_burdened_cost||']');
    print_msg('blPlanReve['||l_bl_revenue||']BlPlanQty['||l_bl_quantity||']');
	End If;

                IF   ( NVL(l_txn_plan_quantity_addl,0)          = 0
                    AND g_refresh_conv_rates_flag       = 'N'
                    AND g_refresh_rates_flag            = 'N'
                    AND g_mass_adjust_flag              = 'N'
                AND g_mfc_cost_refresh_tab(l_countr)    = 'N'
                AND g_applyProg_refreshRts_tab(l_countr) = 'N'
                AND g_rtChanged_Ra_Flag_tab(l_countr)   = 'N') Then
                l_stage := 330;
                    print_msg(to_char(l_stage)||' Planning Transaction Calculate is bypassing this txn, required BL parameters are all NULL');
                    RAISE skip_record;
            END IF;

    l_stage := 520;
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg(to_char(l_stage)||' Populate global temporary tables :refresh_conv_rates_flag ['||g_refresh_conv_rates_flag||']');
        print_msg(']refresh_rates_flag['||g_refresh_rates_flag||']');
	End If;

        IF (g_refresh_conv_rates_flag ='Y'
       OR g_refresh_rates_flag    in ('Y','R','C')
           OR g_mass_adjust_flag      = 'Y'
       OR g_mfc_cost_refresh_tab(l_countr) = 'Y'
       OR g_rtChanged_Ra_Flag_tab(l_countr) = 'Y' ) THEN  --{

        g_refresh_rates_tab(l_countr) := g_refresh_rates_flag;
        g_refresh_conv_rates_tab(l_countr) := g_refresh_conv_rates_flag;
        g_mass_adjust_flag_tab(l_countr) := g_mass_adjust_flag;
        IF (g_mfc_cost_refresh_tab(l_countr) = 'Y' AND g_refresh_rates_flag = 'N')  Then
            g_mfc_cost_refrsh_Raid_tab(NVL(g_mfc_cost_refrsh_Raid_tab.last,0)+1) := l_resource_assignment_id;
            g_mfc_cost_refrsh_txnCur_tab(NVL(g_mfc_cost_refrsh_txnCur_tab.last,0)+1) := l_txn_currency_code;
        End If;

        /* process recors where rates only changed */
        IF (g_rtChanged_Ra_Flag_tab(l_countr) = 'Y'
           and g_mfc_cost_refresh_tab(l_countr) = 'N'
           and g_refresh_rates_flag = 'N'
           and g_refresh_conv_rates_flag = 'N'
           and g_mass_adjust_flag = 'N' ) Then
            	g_rtChanged_RaId_tab(NVL(g_rtChanged_RaId_tab.LAST,0)+1) := l_resource_assignment_id;
            	g_rtChanged_TxnCur_tab(NVL(g_rtChanged_TxnCur_tab.LAST,0)+1) := l_txn_currency_code;
            	g_rtChanged_sDate_tab(NVL(g_rtChanged_sDate_tab.LAST,0)+1)   := g_line_start_date;
            	g_rtChanged_eDate_tab(NVL(g_rtChanged_eDate_tab.LAST,0)+1)   := g_line_end_date;
            	g_rtChanged_CostRt_Tab(NVL(g_rtChanged_CostRt_Tab.LAST,0)+1) := l_rw_cost_rate_override;
            	g_rtChanged_BurdRt_tab(NVL(g_rtChanged_BurdRt_tab.LAST,0)+1) := l_burden_cost_rate_override;
            	g_rtChanged_billRt_tab(NVL(g_rtChanged_billRt_tab.LAST,0)+1) := l_bill_rate_override;
        	g_rtChanged_cstMisNumFlg_tab(NVL(g_rtChanged_cstMisNumFlg_tab.LAST,0)+1) := l_cost_rt_miss_num_flag_tab(i);
        	g_rtChanged_bdMisNumFlag_tab(NVL(g_rtChanged_bdMisNumFlag_tab.LAST,0)+1) := l_burd_rt_miss_num_flag_tab(i);
        	g_rtChanged_blMisNumFlag_tab(NVL(g_rtChanged_blMisNumFlag_tab.LAST,0)+1) := l_bill_rt_miss_num_flag_tab(i);
		g_rtChanged_QtyMisNumFlg_tab(NVL(g_rtChanged_QtyMisNumFlg_tab.LAST,0)+1) := l_Qty_miss_num_flag_tab(i);
        	g_rtChanged_RwMisNumFlag_tab(NVL(g_rtChanged_RwMisNumFlag_tab.LAST,0)+1) := l_Rw_miss_num_flag_tab(i);
        	g_rtChanged_BrMisNumFlag_tab(NVL(g_rtChanged_BrMisNumFlag_tab.LAST,0)+1) := l_Br_miss_num_flag_tab(i);
        	g_rtChanged_RvMisNumFlag_tab(NVL(g_rtChanged_RvMisNumFlag_tab.LAST,0)+1) := l_Rv_miss_num_flag_tab(i);
        End If;

        ELSIF ( NVL(l_txn_plan_quantity_addl,0) <> 0 ) THEN
            l_stage := 400;
	    If P_PA_DEBUG_MODE = 'Y' Then
            print_msg(to_char(l_stage)||' Spread Required populte the resAss tmp');
	    End If;
        /*
        --  Populate global temporary table pa_fp_res_assignments_tmp with values assigned to
        --  the local variables.  The spread api queries this table for values
        */
            BEGIN
            /* THIS LOGIC HAS BEEN SHIFTED TO THE SPREAD API
             * Bug fix: 3831350 spread should spread from etc start date. setting the pl start as etc start will
             * will fix this issue
            IF g_spread_from_date is NOT NULL Then
                IF g_spread_from_date BETWEEN l_planning_start_date AND l_planning_end_date THEN
                    l_planning_start_date := g_spread_from_date;
                End IF;
            END IF;
            Bug fix: When currency override is passed, spread should create the lines in new override currency
            IF l_txn_currency_code_override  is NOT NULL Then
                l_txn_currency_code := l_txn_currency_code_override;
            End If;
            **/
                l_stage := 501;
		If P_PA_DEBUG_MODE = 'Y' Then
                print_msg(l_stage||'g_sprd_raId_tab.Last['||g_sprd_raId_tab.Last||']');
                print_msg('MulticurPlanSD['||l_multicur_plan_start_date||']MutiCurPlanEd['||l_multicur_plan_end_date||']');
		End If;
                g_sprd_raId_tab(NVL(g_sprd_raId_tab.last,0)+1) := l_resource_assignment_id;
                g_sprd_txn_cur_tab(NVL(g_sprd_txn_cur_tab.last,0)+1) := l_txn_currency_code;
                g_sprd_sdate_tab(NVL(g_sprd_sdate_tab.last,0)+1) := g_line_start_date;
                g_sprd_edate_tab(NVL(g_sprd_edate_tab.last,0)+1) := g_line_end_date;
                g_sprd_plan_sdate_tab(NVL(g_sprd_plan_sdate_tab.last,0)+1) := NVL(l_multicur_plan_start_date,l_planning_start_date);
                g_sprd_plan_edate_tab(NVL(g_sprd_plan_edate_tab.last,0)+1) := NVL(l_multicur_plan_end_date,l_planning_end_date);
                g_sprd_txn_rev_tab(NVL(g_sprd_txn_rev_tab.last,0)+1) := l_txn_revenue;
                g_sprd_txn_rev_addl_tab(NVL(g_sprd_txn_rev_addl_tab.last,0)+1) := NULL; --l_txn_revenue_addl;
                g_sprd_txn_raw_tab(NVL(g_sprd_txn_raw_tab.last,0)+1) := l_txn_raw_cost;
                g_sprd_txn_raw_addl_tab(NVL(g_sprd_txn_raw_addl_tab.last,0)+1) := NULL; --l_txn_raw_cost_addl;
                g_sprd_txn_burd_tab(NVL(g_sprd_txn_burd_tab.last,0)+1) := l_txn_burdened_cost;
                g_sprd_txn_burd_addl_tab(NVL(g_sprd_txn_burd_addl_tab.last,0)+1) := NULL; --l_txn_burdened_cost_addl;
                g_sprd_qty_tab(NVL(g_sprd_qty_tab.last,0)+1) := l_txn_plan_quantity;
                g_sprd_qty_addl_tab(NVL(g_sprd_qty_addl_tab.last,0)+1) := l_txn_plan_quantity_addl;
                g_sprd_txn_cur_ovr_tab(NVL(g_sprd_txn_cur_ovr_tab.last,0)+1) := l_txn_currency_code_override;
                g_sprd_txn_init_rev_tab(NVL(g_sprd_txn_init_rev_tab.last,0)+1) := l_txn_init_revenue;
                g_sprd_txn_init_raw_tab(NVL(g_sprd_txn_init_raw_tab.last,0)+1) := l_txn_init_raw_cost;
                g_sprd_txn_init_burd_tab(NVL(g_sprd_txn_init_burd_tab.last,0)+1) := l_txn_init_burdened_cost;
                g_sprd_txn_init_qty_tab(NVL(g_sprd_txn_init_qty_tab.last,0)+1) := l_txn_init_quantity;
                g_sprd_spread_reqd_flag_tab(NVL(g_sprd_spread_reqd_flag_tab.last,0)+1) := l_spread_amounts_flag;
                g_sprd_costRt_tab(NVL(g_sprd_costRt_tab.last,0)+1) := l_raw_cost_rate;
                g_sprd_costRt_Ovr_tab(NVL(g_sprd_costRt_Ovr_tab.last,0)+1) := l_rw_cost_rate_override;
                g_sprd_burdRt_Tab(NVL(g_sprd_burdRt_Tab.last,0)+1) := l_burden_cost_rate;
                g_sprd_burdRt_Ovr_tab(NVL(g_sprd_burdRt_Ovr_tab.last,0)+1) := l_burden_cost_rate_override;
                g_sprd_billRt_tab(NVL(g_sprd_billRt_tab.last,0)+1) := l_bill_rate;
                g_sprd_billRt_Ovr_tab(NVL(g_sprd_billRt_Ovr_tab.last,0)+1) := l_bill_rate_override;
                g_sprd_ratebase_flag_tab(NVL(g_sprd_ratebase_flag_tab.last,0)+1) :=  l_rate_based_flag;
                g_sprd_projCur_tab(NVL(g_sprd_projCur_tab.last,0)+1) := g_project_currency_code;
                g_sprd_projfuncCur_tab(NVL(g_sprd_projfuncCur_tab.last,0)+1) := g_projfunc_currency_code;
                g_sprd_task_id_tab(NVL(g_sprd_task_id_tab.last,0)+1) := g_task_id;
                g_sprd_rlm_id_tab(NVL(g_sprd_rlm_id_tab.last,0)+1) := g_resource_list_member_id;
                g_sprd_sp_fixed_date_tab(NVL(g_sprd_sp_fixed_date_tab.last,0)+1) := l_sp_fixed_date;
                g_sprd_spcurve_id_tab(NVL(g_sprd_spcurve_id_tab.last,0)+1) := l_spread_curve_id;
            	g_sprd_cstRtmissFlag_tab(NVL(g_sprd_cstRtmissFlag_tab.last,0)+1) := l_cost_rt_miss_num_flag_tab(i);
                g_sprd_bdRtmissFlag_tab(NVL(g_sprd_bdRtmissFlag_tab.last,0)+1) := l_burd_rt_miss_num_flag_tab(i);
                g_sprd_bilRtmissFlag_tab(NVL(g_sprd_bilRtmissFlag_tab.last,0)+1) := l_bill_rt_miss_num_flag_tab(i);
		g_sprd_QtymissFlag_tab(NVL(g_sprd_QtymissFlag_tab.last,0)+1) :=  l_Qty_miss_num_flag_tab(i);
        	g_sprd_RawmissFlag_tab(NVL(g_sprd_RawmissFlag_tab.last,0)+1) :=  l_Rw_miss_num_flag_tab(i);
        	g_sprd_BurdmissFlag_tab(NVL(g_sprd_BurdmissFlag_tab.last,0)+1):= l_Br_miss_num_flag_tab(i);
        	g_sprd_RevmissFlag_tab(NVL(g_sprd_RevmissFlag_tab.last,0)+1) :=  l_Rv_miss_num_flag_tab(i);
		/* bug fix:5726773 */
 	        g_sprd_neg_Qty_Changflag_tab(NVL(g_sprd_neg_Qty_Changflag_tab.last,0)+1) := l_neg_Qty_Changflag_tab(i);
 	        g_sprd_neg_Raw_Changflag_tab(NVL(g_sprd_neg_Raw_Changflag_tab.last,0)+1) := l_neg_Raw_Changflag_tab(i);
 	        g_sprd_neg_Burd_Changflag_tab(NVL(g_sprd_neg_Burd_Changflag_tab.last,0)+1) :=l_neg_Burd_Changflag_tab(i);
 	        g_sprd_neg_rev_Changflag_tab(NVL(g_sprd_neg_rev_Changflag_tab.last,0)+1) := l_neg_rev_Changflag_tab(i);
            EXCEPTION
                WHEN OTHERS THEN
                    print_msg(to_char(l_stage)||' ***ERROR*** Inserting into pa_fp_res_assignments_tmp');
                    pa_debug.g_err_stage := to_char(l_stage)||':  ***ERROR*** Inserting into pa_fp_res_assignments_tmp';
                RAISE;
            END;
     /* Bug fix:4295967 */
    ELSIF  (NVL(p_apply_progress_flag,'N') = 'Y'
            AND NVL(l_txn_plan_quantity_addl,0) = 0
            AND g_applyProg_refreshRts_tab(l_countr) = 'Y' ) Then
                        g_applyProg_RaId_tab(NVL(g_applyProg_RaId_tab.LAST,0)+1) := l_resource_assignment_id;
                        g_applyProg_TxnCur_tab(NVL(g_applyProg_TxnCur_tab.LAST,0)+1) := l_txn_currency_code;

    END IF; --}

  EXCEPTION
        WHEN skip_record THEN
        print_msg('Planning Transaction is Skipped Either No addl were found Or WrongMassAdjust Call for this Resource');
        g_skip_record_tab(l_countr) := 'Y';
   END;

  END LOOP; --end loop from FOR i in l_resource_assignment_tab.first..l_resource_assignment_tab.last
	l_pls_end_time := dbms_utility.get_time;
    print_plsql_time('End of MainLoop2:Total time :['||(l_pls_end_time-l_pls_start_time)||']');
	If P_PA_DEBUG_MODE = 'Y' Then
    print_msg(to_char(l_stage)||'END RESOURCE_ASSIGNMENTS LOOP ');
	End If;
    IF NVL(l_entire_return_status,'S') = 'S' Then
        /* Now update the spread_calc tmp table with the required flags to process in bulk */
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Calling Upd_spread_calc_tmp API');
	End If;
        Upd_spread_calc_tmp(
                p_budget_version_id     => g_budget_version_id
                ,p_source_context       => g_source_context
                ,x_return_status        => l_return_status
                );
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('After calling Upd_spread_calc_tmp api retSts['||l_return_status||']');
	End If;
                IF l_return_status <> 'S' Then
                        x_return_status := l_return_status;
                        l_entire_return_status := l_return_status;
                        print_msg(to_char(l_stage)||'x_msg_data => '|| x_msg_data);
                        GOTO END_OF_PROCESS;
                End If;
    End If;
	If P_PA_DEBUG_MODE = 'Y' Then
    print_msg('SpreadProcessRecs['||g_sprd_raId_tab.COUNT||']MfcCostProcessRec['||g_mfc_cost_refrsh_Raid_tab.COUNT||']');
    print_msg('RatesOnlyProcRec['||g_rtChanged_RaId_tab.COUNT||']ApplyProgRefreshRecs['||g_applyProg_RaId_tab.COUNT||']');
	End If;

    /* Process spread records,Call spread package only once in bulk mode */
    IF g_sprd_raId_tab.COUNT > 0 THEN  --{
        l_stage := 543;
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Populate spread records in tmp table');
	End If;
        populate_spreadRecs
                (p_budget_version_id   => g_budget_version_id
                ,p_source_context      => g_source_context
                ,x_return_status       => l_return_status
        );
	If P_PA_DEBUG_MODE = 'Y' Then
                print_msg(to_char(l_stage)||' Spread is required call spread_amounts');
	End If;
	l_pls_start_time := dbms_utility.get_time;
        --print_plsql_time('Start of spread amounts:['||l_pls_start_time);
                PA_FP_SPREAD_AMTS_PKG.spread_amounts
                        (  p_budget_version_id         => g_budget_version_id
                          ,x_return_status             => l_return_status
                          ,x_msg_count                 => x_msg_count
                          ,x_msg_data                  => x_msg_data
                          );
	l_pls_end_time := dbms_utility.get_time;
        print_plsql_time('End of spread amounts:Total time :['||(l_pls_end_time-l_pls_start_time)||']');
	If P_PA_DEBUG_MODE = 'Y' Then
                print_msg('After calling spread_amounts api retSts['||l_return_status||']msgdata['||x_msg_data||']');
	End If;
                IF l_return_status <> 'S' Then
                        x_return_status := l_return_status;
                        l_entire_return_status := l_return_status;
                        print_msg(to_char(l_stage)||'x_msg_data => '|| x_msg_data);
                        GOTO END_OF_PROCESS;
                End If;
    END IF; --}

    /* Process the MFC cost type changes records */
    IF ( g_mfc_cost_refrsh_Raid_tab.COUNT > 0
        OR g_rtChanged_RaId_tab.COUNT > 0
        OR g_refresh_conv_rates_flag ='Y'
            OR g_refresh_rates_flag    in ('Y','R','C')
            OR g_mass_adjust_flag      = 'Y' ) THEN  --{
                l_stage := 530;
		If P_PA_DEBUG_MODE = 'Y' Then
                print_msg(to_char(l_stage)||' Spread is not required call populate_rollup_tmp');
            	print_msg(to_char(l_stage)||' Populate global temporary tables :refresh_conv_rates_flag ['||g_refresh_conv_rates_flag||']');
            print_msg(']refresh_rates_flag['||g_refresh_rates_flag||']');
		End if;
	l_pls_start_time := dbms_utility.get_time;
        --print_plsql_time('Start of populate rollupTmp:['||l_pls_start_time);
                pa_fp_calc_plan_pkg.populate_rollup_tmp
                        ( p_budget_version_id          => g_budget_version_id
                          ,x_return_status             => l_return_status
                          ,x_msg_count                 => x_msg_count
                          ,x_msg_data                  => x_msg_data
                          );
		l_pls_end_time := dbms_utility.get_time;
        	print_plsql_time('End of populate rollupTmp:Total time :['||(l_pls_end_time-l_pls_start_time)||']');
		If P_PA_DEBUG_MODE = 'Y' Then
                print_msg('After Calling populate_rollup_tmp retSts['||l_return_status||']');
		End If;
                IF l_return_status <> 'S' Then
                        x_return_status := l_return_status;
                        l_entire_return_status := l_return_status;
                        l_stage := 535;
                        print_msg(to_char(l_stage)||'x_msg_data => '|| x_msg_data);
                        GOTO END_OF_PROCESS;
                END IF;

                IF g_mass_adjust_flag = 'Y' THEN
                        l_stage := 537;
			If P_PA_DEBUG_MODE = 'Y' Then
                        print_msg(l_stage||'Calling pa_fp_calc_plan_pkg.mass_adjust API');
			End If;
            /*bug fix:4657962 */
			l_pls_start_time := dbms_utility.get_time;
            		--print_plsql_time('Start of MassAdjust:['||l_pls_start_time);
                        pa_fp_calc_plan_pkg.mass_adjust_new
                        ( p_budget_version_id         => g_budget_version_id
                         ,p_quantity_adj_pct          => p_quantity_adj_pct
                         ,p_cost_rate_adj_pct         => p_cost_rate_adj_pct
                         ,p_burdened_rate_adj_pct     => p_burdened_rate_adj_pct
                         ,p_bill_rate_adj_pct         => p_bill_rate_adj_pct
			 ,p_raw_cost_adj_pct          => p_raw_cost_adj_pct
                      	 ,p_burden_cost_adj_pct       => p_burden_cost_adj_pct
                         ,p_revenue_adj_pct           => p_revenue_adj_pct
                         ,x_return_status             => l_return_status
                         ,x_msg_count                 => x_msg_count
                         ,x_msg_data                  => x_msg_data
                         );
	    l_pls_end_time := dbms_utility.get_time;
            print_plsql_time('End of MassAdjust:Total time :['||(l_pls_end_time-l_pls_start_time)||']');
			If P_PA_DEBUG_MODE = 'Y' Then
                        print_msg('End of pa_fp_calc_plan_pkg.mass_adjust API retSts['||l_return_status||']');
			End If;
                        IF l_return_status <> 'S' Then
                                x_return_status := l_return_status;
                                l_entire_return_status := l_return_status;
                                l_stage := 539;
                                print_msg(to_char(l_stage)||'x_msg_data => '|| x_msg_data);
                                GOTO END_OF_PROCESS;
                        END IF;
                END IF;

    END IF;  --} end of refresh mfc cost

    	/* Bug fix:4295967 */
    	IF ( NVL(p_apply_progress_flag,'N') = 'Y'
         AND g_applyProg_RaId_tab.COUNT > 0 ) Then
		If P_PA_DEBUG_MODE = 'Y' Then
        	print_msg('Calling populate rollup tmp in apply progress mode to rederive the etc costs');
		End If;
		l_pls_start_time := dbms_utility.get_time;
    		--print_plsql_time('Start of populaterollupTmp inApplyProgMode:['||l_pls_start_time);
        	pa_fp_calc_plan_pkg.populate_rollup_tmp
                        ( p_budget_version_id          => g_budget_version_id
                          ,x_return_status             => l_return_status
                          ,x_msg_count                 => x_msg_count
                          ,x_msg_data                  => x_msg_data
                          );
		l_pls_end_time := dbms_utility.get_time;
        	print_plsql_time('End of populaterollupTmp inApplyProgMode:time :['||(l_pls_end_time-l_pls_start_time)||']');
		If P_PA_DEBUG_MODE = 'Y' Then
                print_msg('After Calling populate_rollup_tmp retSts['||l_return_status||']');
		End If;
                IF l_return_status <> 'S' Then
                        x_return_status := l_return_status;
                        l_entire_return_status := l_return_status;
                        l_stage := 535;
                        print_msg(to_char(l_stage)||'x_msg_data => '|| x_msg_data);
                        GOTO END_OF_PROCESS;
                END IF;
    	END IF;

	/* IPM Changes */
	/*****
	IF l_entire_return_status = 'S' Then
	   IF g_fp_budget_version_type = 'ALL' and g_process_skip_CstRevrec_tab.COUNT > 0 Then
		If P_PA_DEBUG_MODE = 'Y' Then
		print_msg('Calling Process_skipped_records');
		End if;
                Process_skipped_records(p_budget_version_id  => g_budget_version_id
			  ,p_calling_mode		=> 'PROCESS_CST_REV_MIX'
			  ,p_source_context		=> g_source_context
                          ,x_return_status              => l_return_status
                           ,x_msg_count                 => x_msg_count
                           ,x_msg_data                  => l_msg_data
                           );
                --print_msg('After Process_skipped_records l_return_status = ' || l_return_status);

                IF l_return_status  <> 'S' THEN
                        l_entire_return_status := l_return_status;
                        x_msg_data := l_msg_data;
                END IF;
	   End If;
	End If;
	***/

        /* Bug fix:4900436 */
        IF NVL(g_refresh_rates_flag,'N') = 'Y' Then
            delete_raTxn_Tmp;
            populate_raTxn_Recs (
                        p_budget_version_id     => g_budget_version_id
                        ,p_source_context       => g_source_context
                        ,p_calling_mode         => g_calling_module
                        ,p_refresh_rate_flag    => g_refresh_rates_flag
                        ,p_delete_flag          => 'N'
                        ,p_delete_raTxn_flag    => 'Y'
                        ,p_rollup_flag          => 'Y'
                        ,p_call_raTxn_rollup_flag => p_raTxn_rollup_api_call_flag -- Changed from 'Y'
                        ,x_return_status        => l_return_status
                        ,x_msg_count            => x_msg_count
                        ,x_msg_data             => x_msg_data
                        );
        END IF;

        /*
         *  Call RATE API  only if refresh_rates_flag in ('Y','R','C')  or spread_required_flag = 'Y'
        */
        IF NVL(l_entire_return_status,'S') = 'S'
        AND (g_refresh_rates_flag in ('Y','R','C')
            OR   g_refresh_conv_rates_flag ='Y'
            OR   g_mass_adjust_flag = 'Y'
        OR   g_mfc_cost_refrsh_Raid_tab.COUNT > 0
        OR   g_sprd_raId_tab.COUNT > 0
        OR   g_applyProg_RaId_tab.COUNT > 0
        OR   g_rtChanged_RaId_tab.COUNT > 0
	OR   g_process_skip_CstRevrec_tab.COUNT > 0 ) THEN --{

                /* Bug fix:3968748 For Non-rated resource revenue only version, during budget generation revenue should be
                 * calculated based on markup percent on top of raw or burden cost */
             l_generation_context := 'SPREAD';
                 IF (p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION')
                     and g_revenue_generation_method = 'T') THEN
                     If g_fp_budget_version_type = 'REVENUE' Then
                          --print_msg(3968748||'Calling Update_rollupTmp_OvrRates API for REVENUE MARKUP');
                  l_generation_context := 'REVENUE_MARKUP';
             End If;
             End If;

        /*IB6 enhancements for forecast generation : retain the override rates derived in the forecasting module */
                IF (l_calling_module in ('FORECAST_GENERATION')
          OR ( p_calling_module = 'BUDGET_GENERATION'
            AND g_fp_budget_version_type = 'REVENUE'
                AND g_revenue_generation_method = 'T' )
 	                 /* bug fix:5726773 : added this to read rate overrides from tmp table for non-time phase revenue only
 	                  * records in cost and revenue together version */
 	                 OR ( p_calling_module in ('FORECAST_GENERATION','BUDGET_GENERATION')
 	                         AND g_time_phased_code = 'N'
 	                         AND g_fp_budget_version_type = 'ALL')
 	                 ) Then

                        l_stage := 543;
		 If P_PA_DEBUG_MODE = 'Y' Then
                        print_msg(l_stage||'Calling Update_rollupTmp_OvrRates API with genrationContext['||l_generation_context||']');
		End if;
	    l_pls_start_time := dbms_utility.get_time;
            --print_plsql_time('Start of Update_rollupTmp_OvrRates:['||l_pls_start_time);
                        Update_rollupTmp_OvrRates
                          ( p_budget_version_id        => g_budget_version_id
                          ,p_calling_module            => l_calling_module
                          ,p_generation_context        => l_generation_context
                          ,x_return_status             => l_return_status
                          ,x_msg_count                 => x_msg_count
                          ,x_msg_data                  => x_msg_data
                          );
	    l_pls_end_time := dbms_utility.get_time;
            print_plsql_time('End of Update_rollupTmp_OvrRates:Total time :['||(l_pls_end_time-l_pls_start_time)||']');
		If P_PA_DEBUG_MODE = 'Y' Then
                        print_msg('After calling Update_rollupTmp_OvrRates api retSts['||l_return_status||']msgdata['||x_msg_data||']');
		End If;
                        IF l_return_status <> 'S' Then
                           x_return_status := l_return_status;
                           l_entire_return_status := l_return_status;
                           print_msg(to_char(l_stage)||'x_msg_data => '|| x_msg_data);
                           GOTO END_OF_PROCESS;
                        End If;
                End If;

           IF (l_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION')
            AND CheckCacheRecExists(p_budget_version_id => g_budget_version_id) = 'Y') Then
		If P_PA_DEBUG_MODE = 'Y' Then
            print_msg('Calling PA_FP_CALC_UTILS.copy_BlAttributes api');
		End if;
	l_pls_start_time := dbms_utility.get_time;
        --print_plsql_time('Start of CopyBlAttributes:['||l_pls_start_time);
            PA_FP_CALC_UTILS.copy_BlAttributes(
                        p_budget_verson_id               => g_budget_version_id
                        ,p_source_context                => g_source_context
                        ,p_calling_module                => l_calling_module
                        ,p_apply_progress_flag           => p_apply_progress_flag
                        ,x_return_status                 =>l_return_status
                        ,x_msg_data                      => x_msg_data
                        );
	l_pls_end_time := dbms_utility.get_time;
        print_plsql_time('End of CopyBlAttributes:Total time :['||(l_pls_end_time-l_pls_start_time)||']');
		If P_PA_DEBUG_MODE = 'Y' Then
            print_msg('returnSts of PA_FP_CALC_UTILS.copy_BlAttributes['||l_return_status||']');
		End If;
            IF l_return_status <> 'S' Then
                           x_return_status := l_return_status;
                           l_entire_return_status := l_return_status;
                           print_msg(to_char(l_stage)||'x_msg_data => '|| x_msg_data);
                           GOTO END_OF_PROCESS;
                        End If;
           END IF;

       /* bug fix:4900436 */
       IF NVL(l_entire_return_status,'S') = 'S' Then --{
        If NVL(g_refresh_rates_flag,'N') = 'N' and g_source_context = 'RESOURCE_ASSIGNMENT' Then
           /* Bug fix:4900436 */
            delete_raTxn_Tmp;
	    If p_pa_debug_mode = 'Y' Then
            	print_msg('Calling populate_raTxn_Recs API');
	    End If;
                        populate_raTxn_Recs (
                        p_budget_version_id     => g_budget_version_id
                        ,p_source_context       => g_source_context
                        ,p_calling_mode         => g_calling_module
                        ,p_delete_flag          => 'N'
                        ,p_delete_raTxn_flag    => 'N'
                        ,p_rollup_flag          => 'N'
                        ,p_call_raTxn_rollup_flag => p_raTxn_rollup_api_call_flag --'Y'
                        ,x_return_status        => l_return_status
                        ,x_msg_count            => x_msg_count
                        ,x_msg_data             => x_msg_data
                        );
	    If p_pa_debug_mode = 'Y' Then
            	print_msg('retSts of populate_raTxn_Recs ['||l_return_status||']');
	    End If;
            IF l_return_status <> 'S' Then
                           x_return_status := l_return_status;
                           l_entire_return_status := l_return_status;
                           GOTO END_OF_PROCESS;
                        End If;
        End If;
        IF NVL(l_return_status,'S') = 'S' AND NVL(g_refresh_rates_flag,'N') = 'N' Then
	    If P_PA_DEBUG_MODE = 'Y' Then
            print_msg('Calling Retain_RaTxn_OverrideRates');
	    End if;
            RETAIN_RA_TXN_OVR_RATES
            (p_budget_version_id    => g_budget_version_id
            ,x_return_status    => l_return_status
            );
	    If P_PA_DEBUG_MODE = 'Y' Then
            print_msg('returnSts of RETAIN_RA_TXN_OVR_RATES api['||l_return_status||']');
	    End if;
                    IF l_return_status <> 'S' Then
                           x_return_status := l_return_status;
                           l_entire_return_status := l_return_status;
                           GOTO END_OF_PROCESS;
                    End If;
        End If;
       End If; --}

	   If P_PA_DEBUG_MODE = 'Y' Then
               print_msg('Calling Rate API');
	   End if;
		l_pls_start_time := dbms_utility.get_time;
        	--print_plsql_time('Start of Get_Res_RATEs:['||l_pls_start_time);
                Get_Res_RATEs
                (p_calling_module          => l_calling_module
                ,p_activity_code           => l_activity_code
                ,p_budget_version_id       => g_budget_version_id
                ,p_mass_adjust_flag        => g_mass_adjust_flag
                ,p_apply_progress_flag     => p_apply_progress_flag
                ,p_precedence_progress_flag => l_apply_progress_flag
                ,x_return_status           => l_return_status
                ,x_msg_data                => x_msg_data
                ,x_msg_count               => x_msg_count
                ) ;
		l_pls_end_time := dbms_utility.get_time;
        	print_plsql_time('End of Get_Res_RATEs:Total time :['||(l_pls_end_time-l_pls_start_time)||']');
	    If P_PA_DEBUG_MODE = 'Y' Then
                print_msg('After Calling Rate API retSTS['||l_return_status||']');
	    End if;
                /* bug fix: 4078623 Whenever there is a unexpected error from RATE api just abort the process for the first line itself */
                IF l_return_status = 'U' Then
                        x_return_status := l_return_status;
                        l_entire_return_status := l_return_status;
                        print_msg(to_char(l_stage)||'x_msg_data => '|| x_msg_data);
                        GOTO END_OF_PROCESS;
                END IF;

        END IF; --}


      /*Bug 4224464. This API would be called to insert into pa_fp_rollup_tmp all those budget lines which are not already present in
          pa_fp_rollup_tmp. These lines would be the ones with no changes to qty/amnt and rate columns. The lines with changes to
          qty/amnt and rate columns would not be processed by this API as earlier call to copy_blattributes would have handled these
          lines  Also using the same signature for this API as used for copy_blattributes above.*/
      /* This call to update_dffcols is required for non AMG flows too but currently doing for AMG flow only
       *.as the fix is done for AMG rollup. Will ask Ranga to evaluate this for non-AMG flows and remove the if condition.
       *.This can then be put in FP M rollup with extensive QE testing */
        IF ( p_calling_module = 'AMG_API' )
        THEN
	l_pls_start_time := dbms_utility.get_time;
        --print_plsql_time('Start of update_diffcols: time :'||l_pls_start_time);
                PA_FP_CALC_UTILS.update_dffcols(
                         p_budget_verson_id               => g_budget_version_id
                        ,p_source_context                 => g_source_context
                        ,p_calling_module                 => l_calling_module
                        ,p_apply_progress_flag            => p_apply_progress_flag
                        ,x_return_status                  => l_return_status
                        ,x_msg_count                      => x_msg_count
                        ,x_msg_data                       => x_msg_data
                        );
	    l_pls_end_time := dbms_utility.get_time;
            print_plsql_time('End of update_diffcols:Total time :['||(l_pls_end_time-l_pls_start_time)||']');
		If P_PA_DEBUG_MODE = 'Y' Then
                        print_msg('returnSts of PA_FP_CALC_UTILS.update_dff['||l_return_status||']');
		End if;
                IF l_return_status <> 'S' Then
                        x_return_status := l_return_status;
                        l_entire_return_status := l_return_status;
                        print_msg(to_char(l_stage)||'x_msg_data => '|| x_msg_data);
                        GOTO END_OF_PROCESS;
                End If;
        END IF;

    l_stage := 850;
    print_msg(l_stage||'End of Get_Res_RATEs retSts Before Calling  get_RollupTmp_Status api['||l_return_status||']l_entireSts['||l_entire_return_status||']');
    /* check any Trxn currency conv errors exists in the rollup tmp*/
    get_RollupTmp_Status(
                x_return_status => l_return_status);
    print_msg('After Calling retSts['||l_return_status||']l_entire_return_status['||l_entire_return_status||']');
    IF ( nvl(l_return_status,'S') <> 'S'  OR NVL(l_entire_return_status,'S') <> 'S' ) Then
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Errors found in RollupTmp Aborting the process');
	End if;
        SELECT decode(nvl(l_return_status,'S'),'E','E'
                              ,'U','U'
                                  ,'S',decode(nvl(l_entire_return_status,'S')
                                ,'E','E'
                                ,'U','U'
                                ,'S','S'),'E')
        INTO l_return_status
        FROM dual;
        x_return_status := l_return_status;
        l_entire_return_status := l_return_status;
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Final Return Status['||x_return_status||']MsgCtinErrStack['||fnd_msg_pub.count_msg||']');
	End If;
    End IF;

	/* Added for bug 5028631 for populating  pa_roll_up_tmp table with skipped lines*/
	IF nvl(p_calling_module,'BUDGET_GENERATION') = 'BUDGET_GENERATION'
  	AND p_source_context = 'RESOURCE_ASSIGNMENT'
  	AND NVL(G_clientExtn_api_call_flag,'Y') = 'Y'
  	AND NVL(l_entire_return_status,'S') = 'S' Then
		If P_PA_DEBUG_MODE = 'Y' Then
   		print_msg('Calling Process_skipped_records');
		End If;
   		Process_skipped_records(p_budget_version_id  => g_budget_version_id
			  ,p_calling_mode               => 'PROCESS_SKIPP_RECS'
                          ,p_source_context             => g_source_context
                          ,x_return_status              => l_return_status
                           ,x_msg_count                 => x_msg_count
                           ,x_msg_data           	=> x_msg_data
                           );
		If P_PA_DEBUG_MODE = 'Y' Then
   		print_msg('After Process_skipped_records l_return_status = ' || l_return_status);
		End if;
   		IF l_return_status  <> 'S' THEN
        		l_entire_return_status := l_return_status;
        		x_msg_data := x_msg_data;
   		END IF;
 	END IF;
	/* End for bug 5028631 */

        /* Bug 4224464. Call to pa_client_extn_budget  The client extensions wont be called for the AMG flow.
        So added this if condition for this*/
    IF (not (p_calling_module is not null and p_calling_module = 'AMG_API') )
    THEN
    IF NVL(G_clientExtn_api_call_flag,'Y') = 'Y' AND NVL(l_entire_return_status,'S') = 'S' Then
        l_stage := 900;
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg(to_char(l_stage)||'Call to pa_client_extn_budget');
	End if;
        l_cl_txn_plan_quantity_tab.delete;
            l_cl_txn_raw_cost_tab.delete;
            l_cl_txn_burdened_cost_tab.delete;
            l_cl_txn_revenue_tab.delete;
            l_cl_cost_rate_override_tab.delete;
            l_cl_burden_rate_override_tab.delete;
            l_cl_bill_rate_override_tab.delete;
            l_cl_budget_line_id_tab.delete;
        l_cl_raw_rejection_code_tab.delete;
            l_cl_burd_rejection_code_tab.delete;
            l_cl_rev_rejection_code_tab.delete;
        l_cl_cntr := 0;
	l_pls_start_time := dbms_utility.get_time;
    --print_plsql_time('Start of ClientExtnLoop:Start time :['||l_pls_end_time||']');
        FOR rec IN get_client_xtn_rollup_csr LOOP
            l_stage := 910;
            --print_msg(to_char(l_stage)||' INSIDE get_client_xtn_rollup_csr LOOP');
            l_cl_cntr := l_cl_cntr +1;
            l_txn_raw_cost               := rec.txn_raw_cost;
            l_txn_burdened_cost          := rec.txn_burdened_cost;
            l_txn_revenue                := rec.txn_revenue;
            l_txn_plan_quantity          := rec.quantity;
            -- Start for Bug# 6781055
            l_cl_init_quantity           := NVL(rec.init_quantity,0);
            l_cl_init_raw_cost           := NVL(rec.txn_init_raw_cost,0);
            l_cl_init_burd_cost          := NVL(rec.txn_init_burdened_cost,0);
            l_cl_init_revenue            := NVL(rec.txn_init_revenue,0);
            -- End for Bug# 6781055
            g_resource_list_member_id    := rec.resource_list_member_id;
            g_task_id                    := rec.task_id;
            g_resource_id                := rec.resource_id;
            l_rw_cost_rate_override      := NULL;
            l_burden_cost_rate_override  := NULL;
            l_bill_rate_override         := NULL;
        l_cl_raw_rejection_code  := rec.cost_rejection_code;
            l_cl_burd_rejection_code     := rec.burden_rejection_code;
            l_cl_rev_rejection_code  := rec.revenue_rejection_code;
            -- Added for Bug# 6781055
            l_rec_modified_in_cl_flag    := 'N';

            /*print_msg(' BEFORE client extn Values');
            print_msg(' g_resource_list_member_id  => '|| to_char(g_resource_list_member_id));
            print_msg(' l_txn_raw_cost             => ' || to_char(l_txn_raw_cost));
            print_msg(' l_txn_burdened_cost        => ' || to_char(l_txn_burdened_cost));
            print_msg(' l_txn_revenue              => ' || to_char(l_txn_revenue));
            */
            IF rec.version_type in ('ALL','COST') Then
                pa_client_extn_budget.calc_raw_cost
                ( x_budget_version_id       => g_budget_version_id
                                  ,x_project_id              => g_project_id
                                  ,x_task_id                 => g_task_id
                                  ,x_resource_list_member_id => g_resource_list_member_id
                                  ,x_resource_list_id        => g_bv_resource_list_id
                                  ,x_resource_id             => g_resource_id
                                  ,x_start_date              => rec.start_date
                                  ,x_end_date                => rec.end_date
                                  ,x_period_name             => rec.period_name
                                  ,x_quantity                => l_txn_plan_quantity
                                  ,x_raw_cost                => l_txn_raw_cost
                                  ,x_pm_product_code         => rec.pm_product_code
                                  ,x_txn_currency_code       => rec.txn_currency_code
                                  ,x_error_code              => l_return_status
				  ,x_error_message           => l_msg_data --5028631
                                  );

                            IF l_return_status <> '0' THEN
                                  print_msg('retSts of calc_raw_cost ['||l_return_status||']l_msg_data['||l_msg_data||']'); --5028631
                                  x_return_status := 'E';
                                  x_msg_data := l_msg_data; --5028631
                                  l_entire_return_status := FND_API.G_RET_STS_ERROR;
                                  ADD_MSGTO_STACK( P_MSG_NAME    => x_msg_data); --5028631
                                  GOTO END_OF_PROCESS; --5028631
                            END IF;

                            /* if the Client extn amounts override the rate api derived amounts
                             * then re-derive the override rates
                             */
                            IF rec.version_type in ('ALL','COST') Then
                                If rec.rate_based_flag = 'N' Then
                                        If NVL(l_txn_raw_cost,0) <> NVL(rec.txn_raw_cost,0) Then
                                            --Bug 6781055
                                            l_rec_modified_in_cl_flag:='Y';

                        l_txn_raw_cost := pa_currency.round_trans_currency_amt1(l_txn_raw_cost,rec.txn_currency_code);
                                                l_txn_plan_quantity := l_txn_raw_cost;
                        l_cl_raw_rejection_code := NULL;
                                                /* change in raw cost changes the burden cost rate */
                                                --Bug 6781055
                                                If nvl(l_txn_plan_quantity-l_cl_init_quantity,0) <> 0 Then
                                                   l_burden_cost_rate_override :=
(l_txn_burdened_cost-l_cl_init_burd_cost)/(l_txn_plan_quantity-l_cl_init_quantity);
                                                End if;
                        /* change in the quantity changes the bill rate */
                        If rec.version_type = 'ALL' Then
                                                --Bug 6781055
                                                If (nvl(l_txn_plan_quantity-l_cl_init_quantity,0) <> 0 AND nvl(l_txn_plan_quantity,0) <> nvl(rec.quantity,0)) Then
                                                        l_bill_rate_override := (l_txn_revenue-l_cl_init_revenue)/(l_txn_plan_quantity-l_cl_init_quantity);
                                                End If;
                                            End If;
                                        End If;
                                Else
                                        If NVL(l_txn_raw_cost,0) <> NVL(rec.txn_raw_cost,0) Then
                                            --Bug 6781055
                                            l_rec_modified_in_cl_flag:='Y';
                       			     	l_txn_raw_cost := pa_currency.round_trans_currency_amt1(l_txn_raw_cost,rec.txn_currency_code);
                       				l_cl_raw_rejection_code := NULL;
                                            --Bug 6781055
                                           	If nvl(l_txn_plan_quantity-l_cl_init_quantity,0) <> 0 Then
                                                	l_rw_cost_rate_override := (l_txn_raw_cost-l_cl_init_raw_cost)/(l_txn_plan_quantity-l_cl_init_quantity);

                                           	End If;
                                        End If;
                                End If;
                            End If;

                /* Calling client extn for burdened amts*/
                            pa_client_extn_budget.Calc_Burdened_Cost
                                ( x_budget_version_id       => g_budget_version_id
                                  ,x_project_id              => g_project_id
                                  ,x_task_id                 => g_task_id
                                  ,x_resource_list_member_id => g_resource_list_member_id
                                  ,x_resource_list_id        => g_bv_resource_list_id
                                  ,x_resource_id             => g_resource_id
                                  ,x_start_date              => rec.start_date
                                  ,x_end_date                => rec.end_date
                                  ,x_period_name             => rec.period_name
                                  ,x_quantity                => l_txn_plan_quantity
                  		,x_raw_cost                => l_txn_raw_cost
                                  ,x_burdened_cost           => l_txn_burdened_cost
                                  ,x_pm_product_code         => rec.pm_product_code
                                  ,x_txn_currency_code       => rec.txn_currency_code
                                  ,x_error_code              => l_return_status
				  ,x_error_message           => l_msg_data --5028631
                                  );

                           IF l_return_status <> '0' THEN
                                  x_return_status := 'E';
                  		  x_msg_data := l_msg_data; --5028631
                                  l_entire_return_status := FND_API.G_RET_STS_ERROR;
                                  ADD_MSGTO_STACK( P_MSG_NAME    => x_msg_data); --5028631
                                  GOTO END_OF_PROCESS; --5028631
                           END IF;

               /* re derive the burden cost rate override after calling the client extn */
               If NVl(l_txn_burdened_cost,0) <> NVl(rec.txn_burdened_cost,0) Then
                    --Bug 6781055
                    l_rec_modified_in_cl_flag:='Y';
                   l_txn_burdened_cost := pa_currency.round_trans_currency_amt1(l_txn_burdened_cost,rec.txn_currency_code);
                l_cl_burd_rejection_code := NULL;
                                   --Bug 6781055
                                   If nvl(l_txn_plan_quantity-l_cl_init_quantity,0) <> 0 Then
                                          l_burden_cost_rate_override := (l_txn_burdened_cost-l_cl_init_burd_cost)/(l_txn_plan_quantity-l_cl_init_quantity);

                                   End if;
                           End if;
            End If ; -- end of version type

            IF rec.version_type in ('ALL','REVENUE') Then
               /* Calling clinet extn for revenue amts */
               pa_client_extn_budget.calc_revenue
                ( x_budget_version_id       => g_budget_version_id
                                  ,x_project_id              => g_project_id
                                  ,x_task_id                 => g_task_id
                                  ,x_resource_list_member_id => g_resource_list_member_id
                                  ,x_resource_list_id        => g_bv_resource_list_id
                                  ,x_resource_id             => g_resource_id
                                  ,x_start_date              => rec.start_date
                                  ,x_end_date                => rec.end_date
                                  ,x_period_name             => rec.period_name
                                  ,x_quantity                => l_txn_plan_quantity
                  		,x_raw_cost                => l_txn_raw_cost
                  		,x_burdened_cost           => l_txn_burdened_cost
                                  ,x_revenue                 => l_txn_revenue
                                  ,x_pm_product_code         => rec.pm_product_code
                                  ,x_txn_currency_code       => rec.txn_currency_code
                                  ,x_error_code              => l_return_status
				  ,x_error_message           => l_msg_data  --5028631
                                  );
                           IF l_return_status <> '0' THEN
                                  x_return_status := 'E';
                                  x_msg_data := l_msg_data; --5028631
                                  l_entire_return_status := FND_API.G_RET_STS_ERROR;
                                  ADD_MSGTO_STACK( P_MSG_NAME    => x_msg_data); --5028631
                                  GOTO END_OF_PROCESS; --5028631
                           END IF;

               /* rederive the override rates */
                           If rec.version_type in ('ALL','REVENUE') Then
                                If rec.rate_based_flag = 'N' Then
                                        If NVL(l_txn_revenue,0) <> NVL(rec.txn_revenue,0) Then
                                            --Bug 6781055
                                            l_rec_modified_in_cl_flag:='Y';
                       l_txn_revenue := pa_currency.round_trans_currency_amt1(l_txn_revenue,rec.txn_currency_code);
                l_cl_rev_rejection_code := NULL;
                                           If rec.version_type = 'REVENUE' Then
                                                l_txn_plan_quantity := l_txn_revenue;
                        l_bill_rate_override := 1;
                                           Else
                                                --Bug 6781055
                                                If nvl(l_txn_plan_quantity-l_cl_init_quantity,0) <> 0 Then
                                                   l_bill_rate_override := (l_txn_revenue-l_cl_init_revenue)/(l_txn_plan_quantity-l_cl_init_quantity);
                                                End If;
                                           End If;
                                        End If;
                                Else
                                        If NVL(l_txn_revenue,0) <> NVL(rec.txn_revenue,0) Then
                                            --Bug 6781055
                                            l_rec_modified_in_cl_flag:='Y';
                       l_txn_revenue := pa_currency.round_trans_currency_amt1(l_txn_revenue,rec.txn_currency_code);
                    l_cl_rev_rejection_code := NULL;
                                           --Bug 6781055
                                           If nvl(l_txn_plan_quantity-l_cl_init_quantity,0) <> 0 Then
                                                l_bill_rate_override := (l_txn_revenue-l_cl_init_revenue)/(l_txn_plan_quantity-l_cl_init_quantity);

                                           End If;
                                        End If;
                                End If;
                           End If;
            End If; -- end of version type

            /*print_msg(' AFTER client extn Values UPDATE pa_fp_rollup_tmp');
            print_msg(' txn_raw_cost             => ' || to_char(l_txn_raw_cost));
            print_msg(' txn_burdened_cost        => ' || to_char(l_txn_burdened_cost));
            print_msg(' txn_revenue              => ' || to_char(l_txn_revenue));
            */
            --Bug 6781055
            IF l_rec_modified_in_cl_flag ='Y' THEN
                gl_cl_roll_up_tmp_rowid_tab(gl_cl_roll_up_tmp_rowid_tab.COUNT+1):=rec.rowid;
            END IF;

            l_cl_txn_plan_quantity_tab(l_cl_cntr) := l_txn_plan_quantity;
                    l_cl_txn_raw_cost_tab(l_cl_cntr) :=     l_txn_raw_cost;
                    l_cl_txn_burdened_cost_tab(l_cl_cntr) := l_txn_burdened_cost;
                    l_cl_txn_revenue_tab(l_cl_cntr) :=      l_txn_revenue;
                    l_cl_cost_rate_override_tab(l_cl_cntr) :=  l_rw_cost_rate_override;
                    l_cl_burden_rate_override_tab(l_cl_cntr) :=  l_burden_cost_rate_override;
                    l_cl_bill_rate_override_tab(l_cl_cntr) :=   l_bill_rate_override;
                    l_cl_budget_line_id_tab(l_cl_cntr) := rec.budget_line_id;
            l_cl_raw_rejection_code_tab(l_cl_cntr) := l_cl_raw_rejection_code;
                    l_cl_burd_rejection_code_tab(l_cl_cntr) := l_cl_burd_rejection_code;
                    l_cl_rev_rejection_code_tab(l_cl_cntr) := l_cl_rev_rejection_code;

        END LOOP;
        IF l_cl_budget_line_id_tab.COUNT > 0 then
            FORALL i IN l_cl_budget_line_id_tab.FIRST .. l_cl_budget_line_id_tab.LAST
                UPDATE pa_fp_rollup_tmp tmp
                                SET tmp.quantity       = l_cl_txn_plan_quantity_tab(i)
                                ,tmp.txn_raw_cost      = l_cl_txn_raw_cost_tab(i)
                                ,tmp.txn_burdened_cost = l_cl_txn_burdened_cost_tab(i)
                                ,tmp.txn_revenue       = l_cl_txn_revenue_tab(i)
                                ,tmp.rw_cost_rate_override = NVL(l_cl_cost_rate_override_tab(i),tmp.rw_cost_rate_override)
                                ,tmp.burden_cost_rate_override = nvl(l_cl_burden_rate_override_tab(i),tmp.burden_cost_rate_override)
                                ,tmp.bill_rate_override = nvl(l_cl_bill_rate_override_tab(i),tmp.bill_rate_override)
                ,tmp.cost_rejection_code = l_cl_raw_rejection_code_tab(i)
                ,tmp.burden_rejection_code  = l_cl_burd_rejection_code_tab(i)
                ,tmp.revenue_rejection_code = l_cl_rev_rejection_code_tab(i)
                                WHERE tmp.budget_line_id = l_cl_budget_line_id_tab(i);
                        --print_msg('Number rows updated with ClientExtnUpd['||sql%rowcount||']');
                END IF;
        End If;
	l_pls_end_time := dbms_utility.get_time;
        print_plsql_time('End of ClientExtnLoop:Total time :['||(l_pls_end_time-l_pls_start_time)||']');
    End If;  -- end of client extension calls

        /* Rounding Enhancements: Update the last rollup tmp line with the rounding discrepancy amounts */
        IF NVL(l_entire_return_status,'S') = 'S' AND NVL(g_track_wp_costs_flag,'Y') = 'Y' THEN
	l_pls_start_time := dbms_utility.get_time;
        --print_plsql_time('Start of Update_rounding_diff:['||l_pls_start_time);
               Update_rounding_diff(
                p_project_id                     => p_project_id
                ,p_budget_version_id             => g_budget_version_id
                ,p_calling_module                => l_calling_module
                ,p_source_context                => g_source_context
                ,p_wp_cost_enabled_flag          => g_track_wp_costs_flag
                ,p_budget_version_type           => g_fp_budget_version_type
                ,x_return_status                 => l_return_status
                ,x_msg_count                     => x_msg_count
                ,x_msg_data                      => l_msg_data --5028631
                );
	l_pls_end_time := dbms_utility.get_time;
        print_plsql_time('End of Update_rounding_diff:Total time :['||(l_pls_end_time-l_pls_start_time)||']');
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        x_return_status := l_return_status;
			x_msg_data := l_msg_data; --5028631
                        l_entire_return_status := l_return_status;
                END IF;
        End If;

    l_stage := 1000;
    If P_PA_DEBUG_MODE = 'Y' Then
    print_msg(to_char(l_stage)||'CHK g_conv_rates_required_flag = Y');
    print_msg('p_conv_rates_required_flag => '||g_conv_rates_required_flag||']g_track_wp_costs_flag['||g_track_wp_costs_flag||']');
    End if;
    /* Refreshing the rates will also refresh the conversion rates */
    IF NVL(l_entire_return_status,'S') = 'S' AND NVL(g_track_wp_costs_flag,'Y') = 'Y' THEN
       IF (g_conv_rates_required_flag = 'Y' OR g_refresh_rates_flag in ('Y','R','C'))  THEN
        l_stage := 1010;
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg(to_char(l_stage)||'Calling convert_txn_currency with the following parameters:');
	End if;
	l_pls_start_time := dbms_utility.get_time;
        --print_plsql_time('Start of Currency Conversion['||l_pls_start_time);
        pa_fp_multi_currency_pkg.convert_txn_currency
            ( p_budget_version_id         => g_budget_version_id
                        ,p_entire_version            => 'N'
			,p_calling_module            => l_calling_module -- Added for Bug#5395732
                        ,x_return_status             => l_return_status
                        ,x_msg_count                 => x_msg_count
                        ,x_msg_data                  => l_msg_data --5028631
                        );
	l_pls_end_time := dbms_utility.get_time;
    	print_plsql_time('End of Currency ConversionTotal time :['||(l_pls_end_time-l_pls_start_time)||']');
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('AFter calling convert_txn_currency API returnSTS['||l_return_status||']');
	End if;
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        x_return_status := l_return_status;
			x_msg_data := l_msg_data; --5028631
                        l_entire_return_status := l_return_status;
                END IF;

        /** commented out this api call as this needs completed unit and qa testing
        --Bug fix: 4096201 Call rounding discrepanc api to update the pc and pfc amounts in the rollup tmp
        --print_msg('Calling Update_PCPFC_rounding_diff API');
        Update_PCPFC_rounding_diff(
                p_project_id                     => p_project_id
                ,p_budget_version_id             => g_budget_version_id
                ,p_calling_module                => l_calling_module
                ,p_source_context                => g_source_context
                ,p_wp_cost_enabled_flag          => g_track_wp_costs_flag
                ,p_budget_version_type           => g_fp_budget_version_type
                ,x_return_status                 => l_return_status
                ,x_msg_count                     => x_msg_count
                ,x_msg_data                      => l_msg_data --5028631
                );
        --print_msg('AFter calling Update_PCPFC_rounding_diff retSts['||l_return_status||']');
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        x_return_status := l_return_status;
			x_msg_data := l_msg_data; --5028631
                        l_entire_return_status := l_return_status;
                END IF;
        **/
      END IF;
    END IF;

    /*
    *Now the global temporary table pa_fp_rollup_tmp is completely populated and the
    *table pa_budget_lines is ready to be updated with the values stored in pa_fp_rollup_tmp
    *It will update pa_budget_lines with ALL rows stored in pa_fp_rollup_tmp
    */
    l_stage := 1100;
        /* Bug fix: 4184159 moved to bulk update pa_fp_calc_plan_pkg.update_budget_lines */
	l_pls_start_time := dbms_utility.get_time;
        --print_plsql_time('Start of BLK UpdateBudget Lines:['||l_pls_start_time);
            PA_FP_CALC_UTILS.BLK_update_budget_lines
               ( p_budget_version_id           => p_budget_version_id
		,p_calling_module            => l_calling_module -- Added for Bug#5395732
                ,x_return_status              => l_return_status
                ,x_msg_count                  => x_msg_count
                ,x_msg_data                      => l_msg_data --5028631
                );
	    l_pls_end_time := dbms_utility.get_time;
            print_plsql_time('End of BLK UpdateBudget Total time :['||(l_pls_end_time-l_pls_start_time)||']');
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('AFter calling update_budget_lines retSTst['||l_return_status||']MsgData['||l_msg_data||']');
	End if;
                IF l_return_status <> 'S' Then
                        x_return_status := l_return_status;
			x_msg_data := l_msg_data; --5028631
                        l_entire_return_status := l_return_status;
                    GOTO END_OF_PROCESS;
                END IF;

    IF NVL(p_raTxn_rollup_api_call_flag,'Y') = 'Y' AND nvl(l_entire_return_status,'S') = 'S' Then
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Calling populate_raTxn_Recs API');
	End if;
	l_pls_start_time := dbms_utility.get_time;
	    --print_plsql_time('Start of populate_raTxn_Recs :['||l_pls_start_time);
            delete_raTxn_Tmp;
            populate_raTxn_Recs (
                        p_budget_version_id     => g_budget_version_id
                        ,p_source_context       => 'BUDGET_LINE' -- to rollup the amounts
                        ,p_calling_mode         => g_calling_module
                        ,p_delete_flag          => 'N'
                        ,p_delete_raTxn_flag    => 'N'
                        ,p_refresh_rate_flag    => g_refresh_rates_flag
                        ,p_rollup_flag          => 'Y'
                        ,p_call_raTxn_rollup_flag => 'Y'
                        ,x_return_status        => l_return_status
                        ,x_msg_count            => x_msg_count
                        ,x_msg_data                      => l_msg_data --5028631
                        );
	    l_pls_end_time := dbms_utility.get_time;
	    print_plsql_time('End of populate_raTxn_RecsTotal time :['||(l_pls_end_time-l_pls_start_time)||']');
		If P_PA_DEBUG_MODE = 'Y' Then
        	print_msg('AFter calling populate_raTxn_Recs retSTst['||l_return_status||']MsgData['||l_msg_data||']');
		End if;
                IF l_return_status <> 'S' Then
                        x_return_status := l_return_status;
                        l_entire_return_status := l_return_status;
			x_msg_data := l_msg_data; --5028631
                        GOTO END_OF_PROCESS;
                END IF;
    END IF;

    l_stage := 1110;
    IF (nvl(l_entire_return_status,'S') = 'S' AND g_rep_res_assignment_id_tab.COUNT > 0) THEN
       /* Bug fix: 3867302 : PJI reporting apis should not be called for change order/change requests */
       IF NVL(G_AGR_CONV_REQD_FLAG,'N') <> 'Y' AND NVL(g_rollup_required_flag,'N') = 'Y' Then
        --print_msg(l_stage||'Call PJI apis to update the reporting lines only once');
	ResetRepPlsqlTabIdex(p_budget_version_id             => p_budget_version_id
			   ,x_return_status                 => l_return_status
			   ,x_msg_data                      => l_msg_data
			);
	IF l_return_status <> 'S' Then
                        x_return_status := l_return_status;
                        l_entire_return_status := l_return_status;
                        x_msg_data := l_msg_data; --5028631
                        GOTO END_OF_PROCESS;
        END IF;
	If p_pa_debug_mode = 'Y' Then
            DbugPjiVals;
        End If;
	l_pls_start_time := dbms_utility.get_time;
        --print_plsql_time('Start of PJI reporting:['||l_pls_start_time);
        PA_FP_PJI_INTG_PKG.blk_update_reporting_lines
            (p_calling_module                => 'CALCULATE_API'
            ,p_activity_code                 => 'UPDATE'
            ,p_budget_version_id             => p_budget_version_id
            ,p_rep_budget_line_id_tab        => g_rep_budget_line_id_tab
            ,p_rep_res_assignment_id_tab     => g_rep_res_assignment_id_tab
            ,p_rep_start_date_tab            => g_rep_start_date_tab
            ,p_rep_end_date_tab              => g_rep_end_date_tab
            ,p_rep_period_name_tab           => g_rep_period_name_tab
            ,p_rep_txn_curr_code_tab         => g_rep_txn_curr_code_tab
            ,p_rep_quantity_tab              => g_rep_quantity_tab
            ,p_rep_txn_raw_cost_tab          => g_rep_txn_raw_cost_tab
            ,p_rep_txn_burdened_cost_tab     => g_rep_txn_burdened_cost_tab
            ,p_rep_txn_revenue_tab           => g_rep_txn_revenue_tab
            ,p_rep_project_curr_code_tab     => g_rep_project_curr_code_tab
            ,p_rep_project_raw_cost_tab      => g_rep_project_raw_cost_tab
            ,p_rep_project_burden_cost_tab   => g_rep_project_burden_cost_tab
            ,p_rep_project_revenue_tab       => g_rep_project_revenue_tab
            ,p_rep_projfunc_curr_code_tab    => g_rep_projfunc_curr_code_tab
            ,p_rep_projfunc_raw_cost_tab     => g_rep_projfunc_raw_cost_tab
            ,p_rep_projfunc_burden_cost_tab  => g_rep_projfunc_burden_cost_tab
            ,p_rep_projfunc_revenue_tab      => g_rep_projfunc_revenue_tab
	    ,p_rep_line_mode_tab             => g_rep_line_mode_tab
	    ,p_rep_rate_base_flag_tab        => g_rep_rate_base_flag_tab
            ,x_msg_data                      => l_msg_data --5028631
            ,x_msg_count                     => x_msg_count
            ,x_return_status                 => l_return_status
            );
	l_pls_end_time := dbms_utility.get_time;
        print_plsql_time('End of PJI reporting:Total time :['||(l_pls_end_time-l_pls_start_time)||']');
	If P_PA_DEBUG_MODE = 'Y' Then
                print_msg('AFter calling PA_FP_PJI_INTG_PKG retSTst['||l_return_status||']MsgData['||l_msg_data||']');
	End if;
                IF l_return_status <> 'S' Then
                        x_return_status := l_return_status;
                        l_entire_return_status := l_return_status;
			x_msg_data := l_msg_data; --5028631
                        GOTO END_OF_PROCESS;
                END IF;
       End If;
    END If;


    /*
    --  ROLLUP PC and PFC numbers to pa_resource_assignments
    --  For each resource_assignment in the l_resource_assignment_tab the
    --  numbers must be rolled up. Therefore a loop is required.
    */
    IF NVL(l_entire_return_status,'S') = 'S' Then
            l_stage := 1210;
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Rollup PC and PFC to RA ');
	End if;
	l_pls_start_time := dbms_utility.get_time;
	--print_plsql_time('Start of rollup_pf_pfc_to_ra :['||l_pls_start_time);
            pa_fp_calc_plan_pkg.rollup_pf_pfc_to_ra
            ( p_budget_version_id          => g_budget_version_id
                         ,x_return_status              => l_return_status
                         ,x_msg_count                  => x_msg_count
                         ,x_msg_data                      => l_msg_data --5028631
		);
	l_pls_end_time := dbms_utility.get_time;
	print_plsql_time('End of rollup_pf_pfc_to_raTotal time :['||(l_pls_end_time-l_pls_start_time)||']');
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('After calling pa_fp_calc_plan_pkg.rollup_pf_pfc_to_ra retSts['||l_return_status||']msgData['||l_msg_data||']');
	End if;
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        x_return_status := l_return_status;
                        l_entire_return_status := l_return_status;
			x_msg_data := l_msg_data; --5028631
            print_msg('Errored in pa_fp_calc_plan_pkg.rollup_pf_pfc_to_ra');
            GOTO END_OF_PROCESS;
                END IF;
    END IF;

        /* Bug fix:4250222: when -100% adjustment of qty is made, the budget lines got deleted but
         * RA is not rolled up. so move Delete_BL_Where_Nulls after RA rollup */
        l_stage := 1310;
        IF NVL(x_return_status,'S') = 'S' Then
                /* Delete all the budget Lines where quantity and amounts are not exists but only the rate
                 * retaining these budget lines will cause issues in reating the currency for workplan version
                 * ideally budget lines with null amounts and null quantity with rate make no sense
                 */
		If P_PA_DEBUG_MODE = 'Y' Then
            	print_msg(l_stage||'Calling Delete_BL_Where_Nulls API');
		End if;
		l_pls_start_time := dbms_utility.get_time;
		--print_plsql_time('Start of Delete_BL_Where_Nulls :['||l_pls_start_time);
                Delete_BL_Where_Nulls
                        ( p_budget_version_id        => p_budget_version_id
                          ,p_resource_assignment_tab => l_resource_assignment_tab
                          ,x_return_status           => l_return_status
                          ,x_msg_data                      => l_msg_data --5028631
                         );
		l_pls_end_time := dbms_utility.get_time;
		print_plsql_time('End of Delete_BL_Where_NullsTotal time :['||(l_pls_end_time-l_pls_start_time)||']');
		If P_PA_DEBUG_MODE = 'Y' Then
                print_msg('AFter calling Delete_BL_Where_Nulls retSTst['||l_return_status||']MsgData['||l_msg_data||']');
		End if;
                IF l_return_status <> 'S' Then
                        x_return_status := l_return_status;
                        x_msg_count := 1;
                        l_entire_return_status := l_return_status;
			x_msg_data := l_msg_data; --5028631
                        GOTO END_OF_PROCESS;
                END IF;
        End IF;

    /*
    -- call  PROCEDURE maintain_all_mc_budget_line for reporting
    */
    /* dont call mrc for the workplan version enabled budgets*/
    /****MRC Elimination Changes: no need to call MRC as all the MRC objects are obsoleted from r12
    IF (NVL(l_entire_return_status,'S') = 'S' AND NVL(g_wp_version_flag,'N') = 'N'
        AND NVL(g_mrc_installed_flag,'N') = 'Y'
        AND PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A'
    AND NVL(g_conv_rates_required_flag,'Y') = 'Y' )  Then
	l_pls_start_time := dbms_utility.get_time;
    --print_plsql_time('Start of MRC:['||l_pls_start_time);

        l_stage := 1280;
    IF (NVL(G_populate_mrc_tab_flag,'N') = 'Y' AND g_mrc_budget_line_id_tab.COUNT > 0 ) Then
		If P_PA_DEBUG_MODE = 'Y' Then
            print_msg(to_char(l_stage)||' Calling  pa_mrc_finplan.maintain_all_mc_budget_lines:');
		End if;
        Populate_rollup_WithMrcRecs
                (p_budget_version_id            => g_budget_version_id
               	,x_msg_data                      => l_msg_data --5028631
                ,x_return_status                => l_return_status
                );
		If P_PA_DEBUG_MODE = 'Y' Then
            print_msg('After calling Populate_rollup_WithMrcRecs retSts['||l_return_status||']msgData['||l_msg_data||']');
		End if;
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        x_return_status := l_return_status;
                        l_entire_return_status := l_return_status;
			x_msg_data := l_msg_data; --5028631
                        print_msg('Failed Unexpected exception in Populate_rollup_WithMrcRecs API['||sqlcode||sqlerrm);
                        GOTO END_OF_PROCESS;
                END IF;
    END If;

        l_stage := 1280.1;
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg(to_char(l_stage)||' Calling  pa_mrc_finplan.maintain_all_mc_budget_lines:');
	End if;
        pa_mrc_finplan.maintain_all_mc_budget_lines
                ( p_fin_plan_version_id    => g_budget_version_id
                ,p_entire_version         => 'N'
                ,x_return_status          => l_return_status
                ,x_msg_count              => x_msg_count
                ,x_msg_data                      => l_msg_data --5028631
		);
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('After calling pa_mrc_finplan.maintain_all_mc_budget_lines retSts['||l_return_status||']msgData['||l_msg_data||']');
	end if;
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        x_return_status := l_return_status;
                        l_entire_return_status := l_return_status;
			x_msg_data := l_msg_data; --5028631
                    print_msg('Failed Unexpected exception in MRC API['||sqlcode||sqlerrm);
                    GOTO END_OF_PROCESS;
                END IF;
	l_pls_end_time := dbms_utility.get_time;
        print_plsql_time('End of MRC:Total time :['||(l_pls_end_time-l_pls_start_time)||']');
    End If;
    **************END of MRC Elimination changes ***/

    /*
    --  ROLLUP PC and PFC numbers to pa_budget_versions
    */
    IF NVL(l_entire_return_status,'S') = 'S' Then
        l_stage := 1300;
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg(to_char(l_stage)||' Calling rollup_pf_pfc_to_bv with following parameters:');
	End if;
	l_pls_start_time := dbms_utility.get_time;
	--print_plsql_time('Start of rollup_pf_pfc_to_bv:['||l_pls_start_time);
        pa_fp_calc_plan_pkg.rollup_pf_pfc_to_bv
            ( p_budget_version_id          => g_budget_version_id
                         ,x_return_status              => l_return_status
                         ,x_msg_count                  => x_msg_count
                         ,x_msg_data                      => l_msg_data --5028631
		);
	l_pls_end_time := dbms_utility.get_time;
	print_plsql_time('End of rollup_pf_pfc_to_bvTotal time :['||(l_pls_end_time-l_pls_start_time)||']');
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('After calling pa_fp_calc_plan_pkg.rollup_pf_pfc_to_bv retSts['||l_return_status||']msgData['||l_msg_data||']');
	End if;
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        x_return_status := l_return_status;
                        l_entire_return_status := l_return_status;
			x_msg_data := l_msg_data; --5028631
            GOTO END_OF_PROCESS;
               END IF;
    END IF;

    IF NVL(l_entire_return_status,'S') = 'S' AND g_fp_multi_curr_enabled = 'Y' THEN
            l_stage := 1322;
	    If P_PA_DEBUG_MODE = 'Y' Then
            print_msg(to_char(l_stage)||'Call pa_fp_gen_amount_utils only if g_fp_multi_curr_enabled ['||g_fp_multi_curr_enabled||']');
	   End if;
            pa_fp_gen_amount_utils.get_plan_version_dtls
                    (p_project_id         => g_project_id,
                    p_budget_version_id  => g_budget_version_id,
                    x_fp_cols_rec        => l_fp_cols_rec,
                    x_return_status      => l_return_status
                    ,x_msg_count          => x_msg_count
                   ,x_msg_data                      => l_msg_data --5028631
            );
	 If P_PA_DEBUG_MODE = 'Y' Then
         print_msg('After calling pa_fp_gen_amount_utils.get_plan_version_dtls retSts['||l_return_status||']msgData['||l_msg_data||']');
	 End if;
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        x_return_status := l_return_status;
                        l_entire_return_status := l_return_status;
			x_msg_data := l_msg_data; --5028631
                        GOTO END_OF_PROCESS;
               END IF;

            l_stage := 1327;
	    If P_PA_DEBUG_MODE = 'Y' Then
            print_msg(to_char(l_stage)||'  Calling insert_txn_currency api');
	    End if;
            pa_fp_gen_budget_amt_pub.insert_txn_currency
                (p_project_id          => g_project_id,
                    p_budget_version_id   => g_budget_version_id,
                    p_fp_cols_rec         => l_fp_cols_rec,
                    x_return_status       => l_return_status
                    ,x_msg_count           => x_msg_count
                    ,x_msg_data                      => l_msg_data --5028631
            );
	    If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('AFter calling pa_fp_gen_budget_amt_pub.insert_txn_currency API retSts['||l_return_status||']x_msg_date['||l_msg_data||']');
	    End if;
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        x_return_status := l_return_status;
                        l_entire_return_status := l_return_status;
			x_msg_data := l_msg_data; --5028631
                        GOTO END_OF_PROCESS;
               END IF;

    END IF; -- g_fp_multi_curr_enabled = Y

	/* Bug fix:5203622 */
        IF l_entire_return_status = 'S' Then
		l_pls_start_time := dbms_utility.get_time;
		--print_plsql_time('Start of clear_etc_rev_other_rejectns['||l_pls_start_time);
                clear_etc_rev_other_rejectns
                (p_budget_version_id      => p_budget_version_id
                ,p_source_context         => p_source_context
                ,p_calling_module         => p_calling_module
                ,p_mode                   => 'CLEAR_REJECTIONS'
                ,x_return_status          => l_return_status
                ,x_msg_count              => x_msg_count
                ,x_msg_data               => l_msg_data
                );
		l_pls_end_time := dbms_utility.get_time;
		print_plsql_time('end of clear_etc_rev_Total time :['||(l_pls_end_time-l_pls_start_time)||']');
                If l_return_status <> 'S' Then
                        x_return_status := 'E';
                        l_entire_return_status := l_return_status;
			x_msg_data := l_msg_data;
                        GOTO END_OF_PROCESS;
                End If;
        END IF;

    <<END_OF_PROCESS>>
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Set x_return_status := l_entire_return_status => '||l_entire_return_status);
	End if;
        x_return_status := NVL(l_entire_return_status,'S');
        IF x_return_status = 'U' Then
                x_msg_count := 1;
                If x_msg_data is NULL Then
                        x_msg_data := sqlcode||sqlerrm;
                End If;
        ROLLBACK TO start_of_calculate_api;

        ElsIf x_return_status <> 'S' Then
        x_msg_count := fnd_msg_pub.count_msg;
            IF x_msg_count = 1 THEN
                    pa_interface_utils_pub.get_messages
                    ( p_encoded       => FND_API.G_TRUE
                    ,p_msg_index     => 1
                    ,p_data          => x_msg_data
                    ,p_msg_index_out => l_msg_index_out
                    );
            ELSIF x_msg_count > 1 THEN
                x_msg_count := x_msg_count;
                x_msg_data := null;
            END IF;
        ROLLBACK TO start_of_calculate_api;
	IF NVL(x_msg_count,0) = 0 Then
            x_msg_data := NVL(l_msg_data,x_msg_data); --5028631
	    If P_PA_DEBUG_MODE = 'Y' Then
            print_msg('msg count is zero: x_return_status : '||x_return_status||']x_msg_count['||x_msg_count||']x_msg_data['||x_msg_data||']');
	    End if;
        End If;
    End If;
    /* Reset the error stack */
    IF p_pa_debug_mode = 'Y' Then
            pa_debug.reset_err_stack;
    End If;
    /* Bug fix: 4225263. When CST_getItemCost raises no data found, the bill rate rate api adds this msg to stack
         * though the calculate api is passing return sts as sucess(S), and msgct =0 and msgdata = null, the page
         * is getting the count from error stack and raising the unexpected error
         * Just to handle this reset the msg stack
     */
    IF x_return_status = 'S' Then
        x_msg_data := NULL;
        x_msg_count := 0;
        FND_MSG_PUB.initialize;
    End If;
    /* Bug fix: 4343985 */
    IF cur_avgBlrts%ISOPEN then
                CLOSE cur_avgBlrts;
        END If;
        IF get_bl_date_csr%ISOPEN THEN
                CLOSE get_bl_date_csr;
        End If;

    If cur_ra_txn_rates%isopen then
        close cur_ra_txn_rates;
    end if;
	l_pls_end_time := dbms_utility.get_time;
    /* End of bug fix:4343985 */
    If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('LEAVING calculate bvid => '||g_budget_version_id||' ,pid => '||g_project_id||' ,sesstime => '||g_session_time);
    print_msg('x_return_status : '||x_return_status||']x_msg_count['||x_msg_count||']x_msg_data['||x_msg_data||']');
	End if;
    print_plsql_time('End of CalculateAPI:['||l_pls_end_time||']');
    print_plsql_time('End of CalculateAPI:Total time :['||(l_pls_end_time-l_calc_start_time)||']');

 EXCEPTION
    WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF p_pa_debug_mode = 'Y' Then
            pa_debug.write_file('LOG: '||pa_debug.g_err_stage);
                pa_debug.reset_err_stack;
        End If;
        If x_msg_data is NULL Then
            x_msg_data := sqlcode||sqlerrm;
        End If;
            fnd_msg_pub.add_exc_msg
            ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                ,p_procedure_name => 'calculate:'||substr(l_stage,1,240) );
        pa_debug.write_file('LOG: '||substr(l_stage||':'||sqlcode||sqlerrm,1,240));

        /* Bug fix: 4343985 */
        IF cur_avgBlrts%ISOPEN then
            CLOSE cur_avgBlrts;
        END If;
        IF get_bl_date_csr%ISOPEN THEN
            CLOSE get_bl_date_csr;
        End If;
    If cur_ra_txn_rates%isopen then
        close cur_ra_txn_rates;
    End If;
        ROLLBACK TO start_of_calculate_api;
            print_msg(to_char(l_stage)||' substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
        RAISE;
 END calculate;

/* This API derives the final transaction currency after calling the rate API.
 * This is added for rounding enhancement.  before updating the budget lines all the amounts
 * must be rounded as per the currency precision. There should not any currency derivation at time of
 * updating the budget lines
 * Logic: If budget version is approved revenue the Final_Txn_Currency = projfunc_currency_code
 *        For all change orders, set the Final_Txn_Currency = agreement currency code
 *        For budget version is Multi-Currency DISABLED then Final_Txn_Currency = project_currency_code
 *        For workplan context ,set the Final_Txn_Currency = Initial currency code of the RA
 *   To convert from one Txn currency to another Txn currency call Actual (GL) model currency conversion attributes
 */
PROCEDURE Convert_Final_Txn_Cur_Amts(
        p_project_id        IN Number
            ,p_budget_version_id    IN Number
        ,p_budget_version_type  IN varchar2
        ,p_rate_base_flag       IN varchar2
        ,p_exp_org_id           IN Number
        ,p_task_id              IN Number
        ,p_ei_date              IN Date
        ,p_denom_quantity       IN Number
        ,p_denom_raw_cost       IN Number
        ,p_denom_burden_cost    IN Number
        ,p_denom_revenue    IN Number
        ,p_denom_curr_code      IN varchar2
        ,p_final_txn_curr_code  IN varchar2
        ,x_final_txn_rate_type  OUT NOCOPY varchar2
        ,x_final_txn_rate_date  OUT NOCOPY DATE
        ,x_final_txn_exch_rate  OUT NOCOPY Number
        ,x_final_txn_quantity   OUT NOCOPY Number
        ,x_final_txn_raw_cost   OUT NOCOPY Number
        ,x_final_txn_burden_cost OUT NOCOPY Number
        ,x_final_txn_revenue    OUT NOCOPY Number
        ,x_return_status        OUT NOCOPY varchar2
        ,x_msg_data             OUT NOCOPY varchar2
        ,x_stage                OUT NOCOPY varchar2
        ) IS


    l_return_status    Varchar2(100);
    l_status       Varchar2(100);
    x_dummy_curr_code  Varchar2(100);
    x_dummy_rate_date  Date;
    x_dummy_rate_type  Varchar2(100);
    x_dummy_exch_rate  Number;
    x_dummy_cost       Number;
    /* Declared for bug fix: 4275007 */
    l_multi_currency_billing_flag   Varchar2(10);
        l_baseline_funding_flag     Varchar2(10);
        l_revproc_currency_code     Varchar2(100);
        l_invproc_currency_type     Varchar2(100);
        l_invproc_currency_code     Varchar2(100);
        l_project_currency_code     Varchar2(100);
        l_project_bil_rate_date_code    Varchar2(100);
        l_project_bil_rate_type     Varchar2(100);
        l_project_bil_rate_date     Date;
        l_project_bil_exchange_rate Number;
        l_projfunc_currency_code    Varchar2(100);
        l_projfunc_bil_rate_date_code   Varchar2(100);
        l_projfunc_bil_rate_type    Varchar2(100);
        l_projfunc_bil_rate_date    Date;
        l_projfunc_bil_exchange_rate    Number;
        l_funding_rate_date_code    Varchar2(100);
        l_funding_rate_type     Varchar2(100);
        l_funding_rate_date     Date;
        l_funding_exchange_rate     Number;
        l_msg_count         Number;
    /* end OF BUG fix: 4275007 */

BEGIN
        -- INitialize the err stack;
    IF p_pa_debug_mode = 'Y' Then
            PA_DEBUG.INIT_ERR_STACK('PA_FP_CALC_PLAN_PKG.Convert_Final_Txn_Cur_Amts');
    End If;
        l_return_status := 'S';
        x_return_status := 'S';

    IF p_denom_curr_code IS NOT NULL AND p_final_txn_curr_code IS NOT NULL Then
       IF p_denom_curr_code <> p_final_txn_curr_code THEN
        /* Bug fix: 4275007: For revenue only version conversion attributes of revenue type ie.proj_bill_rate_type
         * must be considered.
        */
        IF p_budget_version_type = 'REVENUE' Then
            If ( g_proj_rev_rate_type is NULL OR g_project_id <> p_project_id ) Then
                --print_msg('Calling PA_MULTI_CURRENCY_BILLING.get_project_defaults API');
                g_proj_rev_rate_type := NULL;
                g_proj_rev_exchange_rate := NULL;
                PA_MULTI_CURRENCY_BILLING.get_project_defaults (
                        p_project_id                  =>  p_project_id,
                        x_multi_currency_billing_flag =>  l_multi_currency_billing_flag,
                        x_baseline_funding_flag       =>  l_baseline_funding_flag,
                        x_revproc_currency_code       =>  l_revproc_currency_code,
                        x_invproc_currency_type       =>  l_invproc_currency_type,
                        x_invproc_currency_code       =>  l_invproc_currency_code,
                        x_project_currency_code       =>  l_project_currency_code,
                        x_project_bil_rate_date_code  =>  l_project_bil_rate_date_code,
                        x_project_bil_rate_type       =>  g_proj_rev_rate_type,
                        x_project_bil_rate_date       =>  l_project_bil_rate_date,
                        x_project_bil_exchange_rate   =>  g_proj_rev_exchange_rate,
                        x_projfunc_currency_code      =>  l_projfunc_currency_code,
                        x_projfunc_bil_rate_date_code =>  l_projfunc_bil_rate_date_code,
                        x_projfunc_bil_rate_type      =>  l_projfunc_bil_rate_type,
                        x_projfunc_bil_rate_date      =>  l_projfunc_bil_rate_date,
                        x_projfunc_bil_exchange_rate  =>  l_projfunc_bil_exchange_rate,
                        x_funding_rate_date_code      =>  l_funding_rate_date_code,
                        x_funding_rate_type           =>  l_funding_rate_type,
                        x_funding_rate_date           =>  l_funding_rate_date,
                        x_funding_exchange_rate       =>  l_funding_exchange_rate,
                        x_return_status               =>  l_return_status,
                        x_msg_count                   =>  l_msg_count,
                        x_msg_data                    =>  x_msg_data);

                --print_msg('ReturnSts of PA_MULTI_CURRENCY_BILLING ['||nvl(l_return_status,'S')||']RevRateTyp['||g_proj_rev_rate_type||']');
                If ( NVL(l_return_status,'S') <> 'S' OR g_proj_rev_rate_type is NULL ) Then
                    --print_msg('Error Occured from MultiCurrencyBilling API:x_msg_data['||x_msg_data||']');
                    x_return_status := 'E';
                    pa_utils.add_message
                                    ( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_FP_MULTI_CURR_BILL_ERROR'
                                    ,p_token1         => 'Error_Message'
                                    ,p_value1         =>  x_msg_data
                                    );
                    x_msg_data := 'PA_FP_PROJ_NO_TXNCONVRATE';
                    IF p_pa_debug_mode = 'Y' Then
                                pa_debug.reset_err_stack;
                        End If;
                    RETURN;
                End If;
            End If;
            x_final_txn_rate_type := g_proj_rev_rate_type;
            x_final_txn_exch_rate := g_proj_rev_exchange_rate;
        End If;
        /* End of bug fix:4275007 **/

        /* Call currency conversion api to convert from one txn currency to another txn currency amounts
         * using Actual model(GL) i.e the attributes will be used from task/project not from fp_options
         */
	/*
        print_msg('Calling pa_multi_currency_txn.get_currency_amounts for conversion from['||p_denom_curr_code||']To['||p_final_txn_curr_code||']');
        print_msg('txnRtTyp['||x_final_txn_rate_type||']rateDate['||x_final_txn_rate_date||']Rate['||x_final_txn_exch_rate||']');
	*/
        x_dummy_curr_code := p_denom_curr_code;
        pa_multi_currency_txn.get_currency_amounts (
                       p_project_id                  => p_project_id
                       ,p_exp_org_id                  => p_exp_org_id
                       ,p_calling_module              => 'WORKPLAN'
                       ,p_task_id                     => p_task_id
                       ,p_ei_date                     => p_ei_date
                       ,p_denom_raw_cost              => 1
                       ,p_denom_curr_code             => p_denom_curr_code
                       ,p_acct_curr_code              => x_dummy_curr_code
                       ,p_accounted_flag              => 'N'
                       ,p_acct_rate_date              => x_dummy_rate_date
                       ,p_acct_rate_type              => x_dummy_rate_type
                       ,p_acct_exch_rate              => x_dummy_exch_rate
                       ,p_acct_raw_cost               => x_dummy_cost
                       ,p_project_curr_code           => p_final_txn_curr_code
                       ,p_project_rate_type           => x_final_txn_rate_type
                       ,p_project_rate_date           => x_final_txn_rate_date
                       ,p_project_exch_rate           => x_final_txn_exch_rate
                       ,p_project_raw_cost            => x_final_txn_raw_cost
                       ,p_projfunc_curr_code          => x_dummy_curr_code
                       ,p_projfunc_cost_rate_type     => x_dummy_rate_type
                       ,p_projfunc_cost_rate_date     => x_dummy_rate_date
                       ,p_projfunc_cost_exch_rate     => x_dummy_exch_rate
                       ,p_projfunc_raw_cost           => x_dummy_cost
                       ,p_system_linkage              => 'NER'
               ,p_structure_version_id        => g_proj_structure_ver_id
                       ,p_status                      => l_status
                       ,p_stage                       => x_stage) ;

            --print_msg('After calling get_currency_amounts retSts['||l_status||']x_stage['||x_stage||']Rate['||x_final_txn_exch_rate||']');

                       IF x_final_txn_exch_rate is NULL OR l_status is NOT NULL Then
                print_msg('The error from currency conv api');
                            x_return_status := 'E';
                            l_return_status := 'E';
                            pa_utils.add_message
                            ( p_app_short_name => 'PA'
                            ,p_msg_name       => 'PA_FP_PROJ_NO_TXNCONVRATE'
                            ,p_token1         => 'G_PROJECT_NAME'
                            ,p_value1         =>  g_project_name
                            ,p_token2         => 'FROMCURRENCY'
                            ,p_value2         => p_denom_curr_code
                            ,p_token3         => 'TOCURRENCY'
                            ,p_value3         => p_final_txn_curr_code
                ,p_token4         => 'CONVERSION_TYPE'
                ,p_value4         => x_final_txn_rate_type
                ,p_token5         => 'CONVERSION_DATE'
                ,p_value5         => x_final_txn_rate_date
                            );
                            x_msg_data := 'PA_FP_PROJ_NO_TXNCONVRATE';
                       END IF;

               IF NVL(l_return_status,'S') = 'S' Then
                IF nvl(p_denom_raw_cost,0) <> 0 Then
                    x_final_txn_raw_cost := p_denom_raw_cost * x_final_txn_exch_rate;
                    x_final_txn_raw_cost := pa_currency.round_trans_currency_amt1(x_final_txn_raw_cost,p_final_txn_curr_code);
                End If;
                IF nvl(p_denom_burden_cost,0) <> 0 Then
                    x_final_txn_burden_cost := p_denom_burden_cost * x_final_txn_exch_rate;
                    x_final_txn_burden_cost := pa_currency.round_trans_currency_amt1(x_final_txn_burden_cost,p_final_txn_curr_code);
                End If;
                IF nvl(p_denom_revenue,0) <> 0 Then
                    x_final_txn_revenue := p_denom_revenue * x_final_txn_exch_rate;
                    x_final_txn_revenue := pa_currency.round_trans_currency_amt1(x_final_txn_revenue,p_final_txn_curr_code);
                End If;
               End If;
       END IF;
    END IF;

    x_return_status := NVL(l_return_status,'S');
    IF p_pa_debug_mode = 'Y' Then
            pa_debug.reset_err_stack;
    End If;
        --print_msg('LEAVING Convert_Final_Txn_Cur_Amts x_return_status : '||x_return_status||']x_msg_data['||x_msg_data||']');

EXCEPTION

        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                If x_msg_data is NULL Then
                        x_msg_data := sqlcode||sqlerrm;
                End If;
        IF p_pa_debug_mode = 'Y' Then
            pa_debug.reset_err_stack;
        End If;
                fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                ,p_procedure_name => 'Convert_Final_Txn_Cur_Amts' );
                print_msg('Unexpected Error from Convert_Final_Txn_Cur_Amts :'||x_msg_data);
                RAISE;
END Convert_Final_Txn_Cur_Amts;


/* This API calls the main wrapper RATE api and converts the amounts from txn to txn currency if
 * cost rate and revenue rate currencies are different
 * Note: Before calling this API, pa_fp_rollup_tmp should be populated
 */
PROCEDURE Get_Res_RATEs
    (p_calling_module          IN Varchar2
        ,p_activity_code           IN Varchar2
    ,p_budget_version_id       IN Number
    ,p_mass_adjust_flag        IN varchar2
    ,p_apply_progress_flag     IN varchar2  DEFAULT 'N'
        ,p_precedence_progress_flag IN varchar2  DEFAULT 'N'
    ,x_return_status           OUT NOCOPY varchar2
    ,x_msg_data                OUT NOCOPY varchar2
    ,x_msg_count               OUT NOCOPY Number
    ) IS

    l_task_id  Number;

    /* declared the following local variables as IN (p_)params to avoid massive changes */
    p_resource_assignment_id  Number;
        p_txn_currency_code      Varchar2(50);
    p_line_start_date         Date;
    p_line_end_date         Date;
        p_txn_currency_code_ovr  varchar2(50);
        p_project_id             Number;
        p_task_id                Number;

    CURSOR cur_calcTmp IS
    SELECT /*+ INDEX(CALTMP PA_FP_SPREAD_CALC_TMP_N1) */ caltmp.resource_assignment_id
        ,caltmp.txn_currency_code
        ,caltmp.start_date
        ,caltmp.end_date
        ,caltmp.txn_curr_code_override
        ,caltmp.G_WPRABL_CURRENCY_CODE
        ,ra.project_id
        ,ra.task_id
        ,ra.budget_version_id
        ,NVL(ra.rate_based_flag,'N') rate_based_flag
    ,caltmp.task_name
        ,caltmp.resource_name
    ,caltmp.billable_flag
    FROM pa_fp_spread_calc_tmp caltmp
        ,pa_resource_assignments ra
    WHERE caltmp.budget_version_id = p_budget_version_id
    AND   caltmp.resource_assignment_id = ra.resource_assignment_id
    AND   ( NVL(caltmp.skip_record_flag,'N') <> 'Y'
	    OR
	    ( NVL(caltmp.skip_record_flag,'N') = 'Y'
		and NVL(caltmp.processed_flag,'N') = 'Y'
	     )
	  );

        CURSOR get_rollup_csr(
            p_resource_assignment_id Number
            ,p_txn_currency_code    Varchar2
            ,p_txn_curr_code_Ovr    Varchar2
            ,p_line_start_date      Date
            ,p_line_end_date        Date ) IS
        SELECT  /*+LEADING(TMP) INDEX(TMP PA_FP_ROLLUP_TMP_N1)*/ ra.resource_assignment_id -- bug 4873834
       ,tmp.txn_currency_code
           ,tmp.quantity
           ,tmp.start_date
           ,tmp.budget_line_id
           ,tmp.burden_cost_rate_override
           ,tmp.rw_cost_rate_override
           ,tmp.bill_rate_override
           ,tmp.txn_raw_cost
           ,tmp.txn_burdened_cost
           ,tmp.txn_revenue
       ,ra.task_id
           ,ra.resource_list_member_id
           ,ra.unit_of_measure
           ,ra.standard_bill_rate
           ,ra.wbs_element_version_id
           ,ra.rbs_element_id
           ,ra.planning_start_date
           ,ra.planning_end_date
           ,ra.spread_curve_id
           ,ra.etc_method_code
           ,ra.res_type_code
           ,ra.fc_res_type_code
           ,ra.resource_class_code
           ,ra.organization_id
           ,ra.job_id
           ,ra.person_id
           ,ra.expenditure_type
           ,ra.expenditure_category
       ,ra.revenue_category_code
           ,ra.event_type
           ,ra.supplier_id
           ,ra.non_labor_resource
           ,ra.bom_resource_id
           ,ra.inventory_item_id
           ,ra.item_category_id
           ,ra.billable_percent
           ,ra.mfc_cost_type_id
           ,ra.incurred_by_res_flag
           ,ra.rate_job_id
           ,ra.rate_expenditure_type
           ,ra.sp_fixed_date
           ,ra.person_type_code
           ,NVL(ra.rate_based_flag,'N') rate_based_flag
           ,ra.rate_exp_func_curr_code
           ,ra.rate_expenditure_org_id
           ,ra.incur_by_res_class_code
           ,ra.incur_by_role_id
           ,ra.project_role_id
       ,ra.resource_class_flag
           ,ra.named_role
       ,rl.res_format_id
       ,tmp.init_quantity
       ,tmp.txn_init_raw_cost
       ,tmp.txn_init_burdened_cost
       ,tmp.txn_init_revenue
       /* Bug fix:4294287 */
       ,tmp.bill_markup_percentage
    ,NVL(tmp.system_reference6,'Y') markup_calculation_flag
        FROM pa_resource_assignments ra
            ,pa_fp_rollup_tmp tmp
        ,pa_resource_list_members rl
        WHERE tmp.resource_assignment_id = p_resource_assignment_id
    AND ra.resource_assignment_id = tmp.resource_assignment_id
    AND rl.resource_list_member_id = ra.resource_list_member_id
        AND tmp.txn_currency_code = decode(p_txn_curr_code_Ovr,NULL,p_txn_currency_code
                    ,decode(p_txn_curr_code_Ovr,tmp.txn_currency_code,p_txn_curr_code_Ovr,p_txn_currency_code))
                /* the decode is added to take care of when override currency changes along with qty the spread api is called
                 * this will create rollup lines with override curr. when rates changes along with ovrride currency change then
                 * refresh rates action performed and rollup lines will be created with original txn curr */
        AND ((g_source_context <> 'BUDGET_LINE' )
       OR
        (g_source_context = 'BUDGET_LINE'
         and p_line_start_date is NOT NULL and p_line_end_date is NOT NULL
         and tmp.start_date BETWEEN p_line_start_date and p_line_end_date)
       )
    /* added this to avoid processing the same record twice. This may happend due to deriving the final
     * currency is moved from update_budget_lines to Rate API.*/
    -- commenting out as rate api is called only once AND NVL(tmp.system_reference5,'N') = 'N'
        ORDER BY ra.resource_assignment_id,tmp.start_date,tmp.txn_currency_code ;


        CURSOR get_rate_api_params_cur IS
        SELECT decode(nvl(pfo.use_planning_rates_flag,'N'),'N',pfo.res_class_bill_rate_sch_id,
                          decode(bv.version_type,'REVENUE',pfo.rev_res_class_rate_sch_id,
                                                 'ALL'    ,pfo.rev_res_class_rate_sch_id,
                                                           NULL)) res_class_bill_rate_sch_id
          ,decode(nvl(pfo.use_planning_rates_flag,'N'),'N',pfo.res_class_raw_cost_sch_id,
                          decode(bv.version_type,'COST',pfo.cost_res_class_rate_sch_id,
                                                 'ALL' ,pfo.cost_res_class_rate_sch_id,
                                                           NULL)) res_class_raw_cost_sch_id
          ,nvl(pfo.use_planning_rates_flag,'N') use_planning_rates_flag
          ,decode(nvl(pfo.use_planning_rates_flag,'N'),'N',null,
                          decode(bv.version_type,'REVENUE',pfo.rev_job_rate_sch_id,
                                                 'ALL'    ,pfo.rev_job_rate_sch_id,
                                                 NULL))    rev_job_rate_sch_id
          ,decode(nvl(pfo.use_planning_rates_flag,'N'),'N',null,
                          decode(bv.version_type,'COST'   ,pfo.cost_job_rate_sch_id,
                                                 'ALL'    ,pfo.cost_job_rate_sch_id,
                                                 NULL))     cost_job_rate_sch_id
          ,decode(nvl(pfo.use_planning_rates_flag,'N'),'N',null,
                          decode(bv.version_type,'REVENUE',pfo.rev_emp_rate_sch_id,
                                                 'ALL'    ,pfo.rev_emp_rate_sch_id,
                                                 NULL))    rev_emp_rate_sch_id
          ,decode(nvl(pfo.use_planning_rates_flag,'N'),'N',null,
                          decode(bv.version_type,'COST'   ,pfo.cost_emp_rate_sch_id,
                                                 'ALL'    ,pfo.cost_emp_rate_sch_id,
                                                 NULL))     cost_emp_rate_sch_id
          ,decode(nvl(pfo.use_planning_rates_flag,'N'),'N',null,
                          decode(bv.version_type,'REVENUE',pfo.rev_non_labor_res_rate_sch_id,
                                                 'ALL'    ,pfo.rev_non_labor_res_rate_sch_id,
                                                 NULL))     rev_non_labor_res_rate_sch_id
          ,decode(nvl(pfo.use_planning_rates_flag,'N'),'N',null,
                          decode(bv.version_type,'COST'   ,pfo.cost_non_labor_res_rate_sch_id,
                                                 'ALL'    ,pfo.cost_non_labor_res_rate_sch_id,
                                                 NULL))     cost_non_labor_res_rate_sch_id
          ,decode(nvl(pfo.use_planning_rates_flag,'N'),'N',null,
                          decode(bv.version_type,'COST'   ,pfo.cost_burden_rate_sch_id,
                                                 'ALL'    ,pfo.cost_burden_rate_sch_id,
                                                 NULL))     cost_burden_rate_sch_id
          ,decode(nvl(bv.wp_version_flag,'N'),'Y',NVL(pfo.track_workplan_costs_flag,'N'),'Y') track_workplan_costs_flag
          ,bv.version_type fp_budget_version_type
          ,bv.resource_list_id
          ,nvl(bv.approved_rev_plan_type_flag,'N') approved_rev_plan_type_flag
          ,nvl(pfo.plan_in_multi_curr_flag,'N')    plan_in_multi_curr_flag
          ,bv.etc_start_date
          ,nvl(bv.wp_version_flag,'N') wp_version_flag
      ,pp.assign_precedes_task
          ,pp.bill_job_group_id
          ,pp.carrying_out_organization_id
          ,nvl(pp.multi_currency_billing_flag,'N') multi_currency_billing_flag
          ,pp.org_id
          ,pp.non_labor_bill_rate_org_id
          ,pp.project_currency_code
          ,pp.non_labor_schedule_discount
          ,pp.non_labor_schedule_fixed_date
          ,pp.non_lab_std_bill_rt_sch_id
          ,pp.project_type
          ,pp.projfunc_currency_code
          ,pp.emp_bill_rate_schedule_id
          ,pp.job_bill_rate_schedule_id
          ,pp.labor_bill_rate_org_id
          ,pp.labor_sch_type
          ,pp.non_labor_sch_type
      ,bv.project_structure_version_id
      ,bv.project_id
        FROM pa_proj_fp_options pfo
            ,pa_budget_versions bv
            ,pa_projects_all pp
        WHERE pfo.fin_plan_version_id = bv.budget_version_id
        AND bv.budget_version_id = p_budget_version_id
    AND pp.project_id = bv.project_id
    AND pfo.project_id = pp.project_id;

    rate_rec  get_rate_api_params_cur%ROWtype;

    CURSOR get_tasks_csr(p_project_id  Number
                ,p_task_id     Number ) IS
        SELECT non_labor_bill_rate_org_id
           ,non_labor_schedule_discount
           ,non_labor_schedule_fixed_date
           ,non_lab_std_bill_rt_sch_id
           ,emp_bill_rate_schedule_id
           ,job_bill_rate_schedule_id
           ,labor_bill_rate_org_id
           ,labor_sch_type
           ,non_labor_sch_type
           ,top_task_id
        FROM pa_tasks t
        WHERE t.task_id = p_task_id
    AND  t.project_id = p_project_id;

        tsk_rec        get_tasks_csr%ROWTYPE;


    l_txn_currency_code                 Varchar2(100);
        l_txn_plan_quantity                 Number;
        l_budget_lines_start_date           Date;
        l_budget_line_id                    Number;
        l_burden_cost_rate_override         Number;
        l_rw_cost_rate_override             Number;
        l_bill_rate_override                Number;
        l_txn_raw_cost                      Number;
        l_txn_burdened_cost                 Number;
        l_txn_revenue               Number;
    x_bill_rate                         Number;
        x_cost_rate                         Number;
        x_burden_cost_rate                  Number;
        x_raw_cost                          Number;
        x_burden_cost                       Number;
        x_raw_revenue                       Number;
        x_bill_markup_percentage            Number;
        x_cost_txn_curr_code                Varchar2(100);
        x_rev_txn_curr_code                 Varchar2(100);
        x_raw_cost_rejection_code           Varchar2(100);
        x_burden_cost_rejection_code        Varchar2(100);
        x_revenue_rejection_code            Varchar2(100);
        x_cost_ind_compiled_set_id          Number;
    x_projfunc_currency_code            Varchar2(100) ;
        x_projfunc_raw_cost                 Number;
        x_projfunc_burdened_cost            Number;
        x_projfunc_revenue                  Number;
        x_projfunc_rejection_code           Varchar2(100);
        x_project_currency_code             Varchar2(100);
        x_project_raw_cost                  Number;
        x_project_burdened_cost             Number;
        x_project_revenue                   Number;
        x_project_rejection_code            Varchar2(100);
        x_acct_rate_date                    Date;
        x_acct_rate_type                    Varchar2(100);
        x_acct_exch_rate                    Number;
        x_acct_raw_cost                     Number;
        x_project_rate_type                 Varchar2(100);
        x_project_rate_date             Date;
        x_project_exch_rate                 Number;
        x_projfunc_cost_rate_type           Varchar2(100);
        x_projfunc_cost_rate_date           Date;
        x_projfunc_cost_exch_rate           Number;
    X_BURDEN_MULTIPLIER                 Number;
    l_calculate_mode                    Varchar2(100);
    l_return_status                     Varchar2(100);
    l_stage                             Number;
    l_txn_currency_code_override        Varchar2(100);
    l_cost_rate_multiplier             CONSTANT pa_labor_cost_multipliers.multiplier%TYPE := 1;
    l_bill_rate_multiplier             CONSTANT pa_labor_cost_multipliers.multiplier%TYPE := 1;
    l_cost_sch_type                    VARCHAR2(30) := 'COST';
    l_mfc_cost_source                  CONSTANT NUMBER := 2;
    x_stage                            varchar2(1000);

    l_labor_sch_type           pa_projects_all.labor_sch_type%TYPE;
        l_non_labor_sch_type           pa_projects_all.labor_sch_type%TYPE;

    www   get_rollup_csr%rowtype;
    l_rate_api_called_flag             varchar2(100);
    l_revenue_generation_method        Varchar2(100);

    /* Added these variables for bug fix: 3681314,3828998 */
    l_cost_override_currency           Varchar2(100) := 'N';
    l_burden_override_currency     Varchar2(100) := 'N';
    l_revenue_override_currency        Varchar2(100) := 'N';
    l_override_organization_id         Number;
        l_convert_rawcost_only_flag        Varchar2(100) := 'N';
        l_convert_revenue_only_flag        Varchar2(100) := 'N';
        l_ra_txn_currency_api_call         Varchar2(100) := 'N';

    l_Final_Txn_Currency_Code          Varchar2(100);
    l_Final_Txn_raw_cost               Number;
    l_Final_Txn_burden_cost            Number;
    l_Final_Txn_revenue                Number;
    l_Final_Txn_quantity               Number;
    l_Final_txn_exch_rate              Number;
    l_final_txn_rate_type              Varchar2(100);
    l_final_txn_rate_date              Date;
    l_error_code                       Varchar2(1000);
    l_rev_to_cost_conv_cur             Varchar2(100);

        /* declared for bulk processing of rollup tmp update */
        l_rl_cntr           NUMBER := 0;
        l_rlt_budget_line_id_tab        pa_plsql_datatypes.IdTabTyp;
        l_rlt_quantity_tab              pa_plsql_datatypes.NumTabTyp;
        l_rlt_bill_rate_tab             pa_plsql_datatypes.NumTabTyp;
        l_rlt_bill_rate_ovr_tab         pa_plsql_datatypes.NumTabTyp;
        l_rlt_cost_rate_tab             pa_plsql_datatypes.NumTabTyp;
        l_rlt_rw_cost_rate_ovr_tab      pa_plsql_datatypes.NumTabTyp;
        l_rlt_burden_cost_rate_tab      pa_plsql_datatypes.NumTabTyp;
        l_rlt_burden_cost_rate_ovr_tab  pa_plsql_datatypes.NumTabTyp;
        l_rlt_raw_cost_tab              pa_plsql_datatypes.NumTabTyp;
        l_rlt_burden_cost_tab           pa_plsql_datatypes.NumTabTyp;
        l_rlt_raw_revenue_tab           pa_plsql_datatypes.NumTabTyp;
        l_rlt_bill_markup_percent_tab   pa_plsql_datatypes.NumTabTyp;
        l_rlt_txn_curr_code_tab         pa_plsql_datatypes.Char30TabTyp;
        l_rlt_raw_cost_rejection_tab    pa_plsql_datatypes.Char30TabTyp;
        l_rlt_burden_rejection_tab  pa_plsql_datatypes.Char30TabTyp;
        l_rlt_revenue_rejection_tab     pa_plsql_datatypes.Char30TabTyp;
        l_rlt_projfunc_rejection_tab    pa_plsql_datatypes.Char30TabTyp;
        l_rlt_project_rejection_tab     pa_plsql_datatypes.Char30TabTyp;
        l_rlt_ind_compiled_set_tab  pa_plsql_datatypes.NumTabTyp;

    /* Bug fix: 4294287 */
    l_bill_markup_percentage        Number;
    l_billable_flag                 Varchar2(10);
    l_rateApi_billable_flag         Varchar2(10);

    UNEXPECTED_ERRORS                  EXCEPTION;
    RATEAPI_UNEXPECTED_ERRORS          EXCEPTION;

     -- bug 4474861: for webadi context, for error reporting
    l_webAdi_calling_context           VARCHAR2(100) := PA_FP_WEBADI_PKG.G_FP_WA_CALC_CALLING_CONTEXT;

	l_time_start number ;
	l_time_end number ;
BEGIN

    -- INitialize the err stack;
    IF p_pa_debug_mode = 'Y' Then
        PA_DEBUG.INIT_ERR_STACK('PA_FP_CALC_PLAN_PKG.Get_Res_Rates');
    	print_msg('Entered Get_Res_Rates API');
    End If;
    l_return_status := 'S';
    x_return_status := 'S';
    rate_rec := NULL;
    OPEN get_rate_api_params_cur;
    FETCH get_rate_api_params_cur INTO rate_rec;
    IF get_rate_api_params_cur%FOUND THEN
	  null;
          --print_msg('get_rate_api_params_cur found');
    Else
	  null;
          --print_msg('get_rate_api_params_curnot found');
    End If;
    CLOSE get_rate_api_params_cur;
    l_revenue_generation_method := g_revenue_generation_method; --Bug 5462471
    --l_revenue_generation_method := NVL(PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(rate_rec.project_id),'W');
    --print_msg('After Calling GET_REV_GEN_METHOD ['||l_revenue_generation_method||']');

    /* declared for bulk processing of rollup tmp update */
        l_rl_cntr   := 0;
        l_rlt_budget_line_id_tab.delete;
        l_rlt_quantity_tab.delete;
        l_rlt_bill_rate_tab.delete;
        l_rlt_bill_rate_ovr_tab.delete;
        l_rlt_cost_rate_tab.delete;
        l_rlt_rw_cost_rate_ovr_tab.delete;
        l_rlt_burden_cost_rate_tab.delete;
        l_rlt_burden_cost_rate_ovr_tab.delete;
        l_rlt_raw_cost_tab.delete;
        l_rlt_burden_cost_tab.delete;
        l_rlt_raw_revenue_tab.delete;
        l_rlt_bill_markup_percent_tab.delete;
        l_rlt_txn_curr_code_tab.delete;
        l_rlt_raw_cost_rejection_tab.delete;
        l_rlt_burden_rejection_tab.delete;
        l_rlt_revenue_rejection_tab.delete;
        l_rlt_projfunc_rejection_tab.delete;
        l_rlt_project_rejection_tab.delete;
        l_rlt_ind_compiled_set_tab.delete;

    -- main loooooooooop starts here
    FOR caltmp IN cur_calcTmp LOOP  --{{
    /* assign the cursor value to local variable*/
    p_resource_assignment_id   := caltmp.resource_assignment_id;
        p_txn_currency_code        := caltmp.txn_currency_code;
    p_line_start_date          := caltmp.start_date;
    p_line_end_date            := caltmp.end_date;
        p_txn_currency_code_ovr    := caltmp.txn_curr_code_override;
        p_project_id               := caltmp.project_id;
        p_task_id          := caltmp.task_id;
    g_task_name        := caltmp.task_name;
    g_resource_name    := caltmp.resource_name;
    l_billable_flag    := NVL(caltmp.billable_flag,'N');
    l_rateApi_billable_flag := l_billable_flag;

	If P_PA_DEBUG_MODE = 'Y' Then
    print_msg('LOOOOOP:ResId['||p_resource_assignment_id||']TxnCur['||p_txn_currency_code||']CurOvr['||p_txn_currency_code_ovr||']');
    print_msg('glinesd['||g_line_start_date||']iglineEd['||g_line_end_date||']l_billable_flag['||l_billable_flag||']');
	End if;

    l_txn_currency_code_override := p_txn_currency_code_ovr;
    /* for each resource assignment in calctmp open the task cursor */
    tsk_rec := NULL;
    OPEN get_tasks_csr(p_project_id,p_task_id);
    FETCH get_tasks_csr INTO tsk_rec;
    CLOSE get_tasks_csr;

        IF rate_rec.fp_budget_version_type = 'REVENUE' THEN
            l_calculate_mode  := 'REVENUE';
        ELSIF rate_rec.fp_budget_version_type = 'COST' THEN
            l_calculate_mode  := 'COST';
        ELSIF rate_rec.fp_budget_version_type = 'ALL' THEN
            l_calculate_mode  := 'COST_REVENUE';
        END IF;

    /* Bug fix:3968748 For Non-rated resource revenue only version, during budget generation revenue should be
     * calculated based on markup percent on top of raw or burden cost */
    IF (p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION') and l_revenue_generation_method = 'T') THEN
        If rate_rec.fp_budget_version_type = 'REVENUE' Then
            /* bug fix: 4214050 during generation process, markup should be calculated for both rate and non-rate based
            * planning resource. The generation process must populate cost rate and burden rate overrides in the temp table
            * decision taken by ramesh and pms
            * IF caltmp.rate_based_flag = 'N' Then */
            l_calculate_mode  := 'COST_REVENUE';
           /*End If; */
        End If;
    End If;

    /* Initialize the workplan currency code  for Each RA+Cur combo*/
    g_ra_bl_txn_currency_code := NULL;
    IF (( g_wp_version_flag = 'Y' OR  g_agr_conv_reqd_flag = 'Y')
           /* Bug fix::4396300 */
           OR (p_calling_module in ('BUDGET_GENERATION','FORECAST_GENERATION')
               AND caltmp.G_WPRABL_CURRENCY_CODE is NOT NULL ))
           /* Bug fix:4396300 */
        THEN  --{
                   g_ra_bl_txn_currency_code := caltmp.G_WPRABL_CURRENCY_CODE;
        END IF; --}

        FOR z IN get_rollup_csr(p_resource_assignment_id
                ,p_txn_currency_code
                ,p_txn_currency_code_ovr
                ,p_line_start_date
                ,p_line_end_date)  LOOP --{
        l_stage := 600;

        l_txn_currency_code                 := z.txn_currency_code;
        l_txn_plan_quantity                 := z.quantity;
        l_budget_lines_start_date           := z.start_date;
        l_budget_line_id                    := z.budget_line_id;
        l_burden_cost_rate_override         := z.burden_cost_rate_override;
        l_rw_cost_rate_override             := z.rw_cost_rate_override;
        l_bill_rate_override                := z.bill_rate_override;
        l_txn_raw_cost                      := z.txn_raw_cost;
        l_txn_burdened_cost                 := z.txn_burdened_cost;
        l_txn_revenue                       := z.txn_revenue;
    x_raw_cost                          := z.txn_raw_cost;
        x_burden_cost                       := z.txn_burdened_cost;
        x_raw_revenue                       := z.txn_revenue;
    x_raw_cost_rejection_code           := null;
        x_burden_cost_rejection_code        := null;
        x_revenue_rejection_code            := null;
        x_projfunc_rejection_code           := null;
        x_project_rejection_code            := null;
    l_bill_markup_percentage            := z.bill_markup_percentage;
    x_bill_markup_percentage            := l_bill_markup_percentage;

    /* initialize the ovierride flags */
        l_cost_override_currency     := 'N';
        l_burden_override_currency   := 'N';
        l_revenue_override_currency  := 'N';

    /* set the final transaction currency code */
    IF g_agr_conv_reqd_flag = 'Y' Then
        l_Final_Txn_Currency_Code := g_agr_currency_code;
    Elsif  g_bv_approved_rev_flag  = 'Y' Then
        l_Final_Txn_Currency_Code := rate_rec.projfunc_currency_code;
    Elsif rate_rec.plan_in_multi_curr_flag = 'N' Then
        l_Final_Txn_Currency_Code := rate_rec.project_currency_code;
    Else
        -- the rate api currency code
        l_Final_Txn_Currency_Code := NULL;
    End If;

    l_return_status := 'S';
    x_msg_data := NULL;

	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg(to_char(l_stage)||' Rate API req parameters from pa_fp_rollup_tmp');
        print_msg(' l_txn_currency_code                 := '||l_txn_currency_code);
        print_msg(' l_Final_txn_currency_code           := '||l_Final_txn_currency_code);
        print_msg(' l_txn_plan_quantity                 := '||l_txn_plan_quantity);
        print_msg(' l_budget_lines_start_date           := '||z.start_date);
        print_msg(' l_budget_line_id                    := '||z.budget_line_id);
        print_msg(' l_burden_cost_rate_override         := '||l_burden_cost_rate_override);
        print_msg(' l_rw_cost_rate_override             := '||l_rw_cost_rate_override);
        print_msg(' l_bill_rate_override                := '||l_bill_rate_override);
        print_msg(' l_txn_raw_cost                      := '||l_txn_raw_cost);
        print_msg(' l_txn_burdened_cost                 := '||l_txn_burdened_cost);
        print_msg(' l_txn_revenue                       := '||l_txn_revenue);
        print_msg(' l_rate_based_flag                   := '||z.rate_based_flag);
        print_msg(' l_fp_budget_version_type            := '||rate_rec.fp_budget_version_type);
        print_msg(' l_bill_markup_percentage            := '||z.bill_markup_percentage);
        print_msg(' l_bill_markup_percentage            := '||z.bill_markup_percentage);
        print_msg(' markup_calculation_flag             := '||z.markup_calculation_flag);
	print_msg(' l_init_quantity                     := '||z.init_quantity);
	print_msg(' l_txn_init_raw_cost                 := '||z.txn_init_raw_cost);
	print_msg(' l_txn_init_burden_cost              := '||z.txn_init_burdened_cost);
	print_msg(' l_txn_init_revenue                  := '||z.txn_init_revenue);
	End if;

    /* derive the ETC values and pass it the rate api*/
    l_txn_plan_quantity := l_txn_plan_quantity - nvl(z.init_quantity,0);
    l_txn_raw_cost := l_txn_raw_cost - nvl(z.txn_init_raw_cost,0);
    l_txn_burdened_cost := l_txn_burdened_cost - nvl(z.txn_init_burdened_cost,0);
    l_txn_revenue := l_txn_revenue - nvl(z.txn_init_revenue,0);

    x_raw_cost    := x_raw_cost - nvl(z.txn_init_raw_cost,0);
    x_burden_cost := x_burden_cost - nvl(z.txn_init_burdened_cost,0);
    x_raw_revenue := x_raw_revenue  - nvl(z.txn_init_revenue,0);

        IF z.rate_based_flag = 'N' THEN  --{
               l_stage := 605;
               print_msg(to_char(l_stage)|| ' z.rate_based_flag = N');
       IF rate_rec.fp_budget_version_type in ('COST','ALL') THEN
        If nvl(l_txn_plan_quantity,0) <> 0
		AND (l_rw_cost_rate_override is NOT NULL
			OR l_rw_cost_rate_override = 0 ) Then
            l_txn_raw_cost := null;
        End If;
        /* as Rate api will be always called in this scenerio, burden cost will be calculated
        * based on raw cost or quantity or burden cost override */
        If ((nvl(l_txn_plan_quantity,0) <> 0) OR l_txn_raw_cost is NOT NULL ) Then
            l_txn_burdened_cost := null;
        End If;
       End If;
       IF rate_rec.fp_budget_version_type in ('REVENUE','ALL') Then
        /* bug fix: 4229575 For cost and revenue together non-rate base resource refresh must refresh the bill rate */
        If  rate_rec.fp_budget_version_type = 'ALL' Then
            If (nvl(l_txn_plan_quantity,0) <> 0) Then
                l_txn_revenue := NULL;
            End If;
        Elsif rate_rec.fp_budget_version_type = 'REVENUE' Then
          If nvl(l_txn_plan_quantity,0) <> 0 AND l_bill_rate_override is NOT NULL  Then
            l_txn_revenue := NULL;
            /* Bug fix:3968748 During budget or Forecast generation process, For Non-Rate based resource Revenue is generated based on raw/burden cost
                 * the generation process copies raw / burden to the target version ResAsgnment and populates the bill rate override as 1
             * and calls calculate api to spread the amounts. During this process, revenue should be calculated based on the markup percent
             * on top of raw / burden cost. If bill rate override exists, the RATE api will not calculate the markup.
             * In order to fix this issue, the following logic is included.
             * 1. The generation process must pass either Raw cost OR Burdened cost to resource assignment tab
             * 2. Before calling RATE api, pass cost rate override and burden rate override as 1 so that rate api will not calculate
             *    the raw and burden costs
             * 3. pass bill rate override as NULL. so that markup is applied on top of raw / burden
             * 4. After rate api call, null out the raw cost, burdened cost ,cost rate override and burden rate overrides
             * 5. Copy the revenue to quantity and change the bill rate override to 1
             */
             IF (p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION')
                 and l_revenue_generation_method = 'T') THEN
                If l_rw_cost_rate_override is NULL Then
                   l_rw_cost_rate_override := 1;
                End If;
                If l_burden_cost_rate_override is NULL Then
                   l_burden_cost_rate_override := 1;
                End If;
        IF NVL(l_billable_flag,'N') = 'Y' Then  --Added for billability changes
          IF z.markup_calculation_flag = 'Y' Then  /* Bug fix:4568011 */
                     l_bill_rate_override := NULL;
          End If;
        END IF;
             END IF;
         End If;
           End If;
       End If;

    ELSE  -- rate_based_flag = 'Y'
        IF l_txn_plan_quantity is NOT NULL Then
            l_txn_raw_cost := NULL;
                    l_txn_burdened_cost := NULL;
                    l_txn_revenue := NULL;
            /* bug fix: 4214050 */
            IF (rate_rec.fp_budget_version_type = 'REVENUE'
                and p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION')
                and l_revenue_generation_method = 'T' ) THEN
                If l_rw_cost_rate_override is NULL Then
                         l_rw_cost_rate_override := 1;
                End If;
                If l_burden_cost_rate_override is NULL Then
                         l_burden_cost_rate_override := 1;
                End If;
        IF NVL(l_billable_flag,'N') = 'Y' Then  --Added for billability changes
            IF z.markup_calculation_flag = 'Y' Then  /* Bug fix:4568011 */
                         l_bill_rate_override := NULL;
            End If;
        ElsIF ( NVL(l_billable_flag,'N') = 'N'
            and l_bill_rate_override is NOT NULL ) Then
            NULL;
        End If;
            END IF;
        END IF;
        END IF; -- } IF l_rate_based_flag = 'N'

    IF (rate_rec.fp_budget_version_type = 'REVENUE'
           and p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION')
           and l_revenue_generation_method = 'T'
       and l_txn_plan_quantity is NOT NULL ) THEN
        l_txn_raw_cost := NULL;
                l_txn_burdened_cost := NULL;
    End IF;

    /* setting the quantity to null to avoid call to rate api with 0 qty */
    IF NVL(l_txn_plan_quantity,0) = 0 Then
        l_txn_plan_quantity := NULL;
        /* Bug fix: 4254051 When quantity is nulled out or zeroed, the rate api should not be called
                * so null out all the amounts and rates */
        /* bug fix:5726773
	l_rw_cost_rate_override := NULL;
        l_burden_cost_rate_override := NULL;
        l_bill_rate_override := NULL;
	x_burden_multiplier := NULL;
 	**/
        l_txn_raw_cost := NULL;
        l_txn_burdened_cost := NULL;
        l_txn_revenue := NULL;

        -- Bug 8314994
        -- Avoiding nulling of burdned cost for non rate base case where we have only burdened cost in
        -- system.
        If NOT ( p_calling_module = 'BUDGET_GENERATION' AND NVL(z.rate_based_flag,'N') = 'N'
                 AND (nvl(x_raw_cost,0)=0 AND nvl(x_burden_cost,0)<> 0 )  )Then
                        x_burden_cost := NULL;
        END IF;

        x_raw_cost    := NULL;
				--x_burden_cost := NULL;   Bug 8314994
				x_raw_revenue := NULL;
				x_bill_rate   := NULL;
				x_cost_rate   := NULL;
				x_burden_cost_rate := NULL;

    End If;


        l_stage := 610;
    /*
        print_msg(to_char(l_stage)||' Rate API req parameters from pa_fp_rollup_tmp after rate_based_flag = N check');
        print_msg(' l_txn_currency_code                 := '||l_txn_currency_code);
        print_msg(' l_txn_plan_quantity                 := '||l_txn_plan_quantity);
        print_msg(' l_budget_lines_start_date           := '||l_budget_lines_start_date);
        print_msg(' l_budget_line_id                    := '||l_budget_line_id);
        print_msg(' l_burden_cost_rate_override         := '||l_burden_cost_rate_override);
        print_msg(' l_rw_cost_rate_override             := '||l_rw_cost_rate_override);
        print_msg(' l_bill_rate_override                := '||l_bill_rate_override);
        print_msg(' l_txn_raw_cost                      := '||l_txn_raw_cost);
        print_msg(' l_txn_burdened_cost                 := '||l_txn_burdened_cost);
        print_msg(' l_txn_revenue                       := '||l_txn_revenue);
    */

/*
--  Check to see if all Cost and Revenue numbers are present in transaction currency.
--  If yes then RATE API need not be called for this planning transaction.
 */
        l_stage := 620;
        --print_msg(to_char(l_stage)||' Check to see if all l_fp_track_workplan_costs_flag = N');
        --print_msg(to_char(l_stage)||' Check to see if all Cost and Revenue numbers are present in transaction currency');
    l_rate_api_called_flag := 'N';
        IF rate_rec.track_workplan_costs_flag = 'N' THEN  --{
               l_stage := 625;
               --print_msg(to_char(l_stage)||' No call to Rate API - track_workplan_costs_flag = N set all cost and rates to null');
           --set all the override rates and costs to null
        x_bill_rate                 := null;
                l_bill_rate_override        := null;
                x_cost_rate         := null;
                l_rw_cost_rate_override     := null;
                x_burden_cost_rate          := null;
                l_burden_cost_rate_override     := null;
                x_raw_cost          := null;
                x_burden_cost           := null;
                x_raw_revenue           := null;
                x_bill_markup_percentage    := null;
                x_raw_cost_rejection_code   := null;
                x_burden_cost_rejection_code    := null;
                x_revenue_rejection_code    := null;
                x_projfunc_rejection_code   := null;
                x_project_rejection_code    := null;
                x_cost_ind_compiled_set_id  := null;
               NULL;
    ELSIF (rate_rec.fp_budget_version_type in ('COST','ALL') AND
        l_txn_plan_quantity is NULL    AND
        NVL(l_txn_plan_quantity,0) = 0 AND
        l_txn_raw_cost IS NULL         AND
        NVL(l_txn_raw_cost,0) = 0 ) THEN
        -- calculation of burden and revenue is always based on raw cost so if both qty and raw cost is null
        -- then no need to call rate api. User can enter only burdened cost / revenue.
        --print_msg('Both qty and raw costs are null so no need to call rate api');
        null;
    ELSIF (rate_rec.fp_budget_version_type in ('REVENUE') AND
                l_txn_plan_quantity is NULL    AND
                NVL(l_txn_plan_quantity,0) = 0 )  THEN
        -- in case revenue only , revenue is derived based on cost. to calculate cost qty should be there
        -- so if qty is null then no need to call rate api
        --print_msg('Quantity is null in revenue version no need to call rate api');
        null;
        ELSIF
           rate_rec.fp_budget_version_type = 'COST' AND
             l_txn_raw_cost IS NOT NULL AND nvl(l_txn_raw_cost,0) <> 0 AND
             l_txn_burdened_cost IS NOT NULL AND nvl(l_txn_burdened_cost,0) <> 0 AND
             p_mass_adjust_flag = 'N' THEN
               l_stage := 630;
               --print_msg(to_char(l_stage)||' No call to Rate API - budget_version_type = COST - Raw and Burdened Cost are NOT NULL');
               NULL;
        ELSIF
           rate_rec.fp_budget_version_type = 'REVENUE' AND
             l_txn_revenue IS NOT NULL AND nvl(l_txn_revenue,0) <> 0 AND
             p_mass_adjust_flag = 'N' THEN
               l_stage := 640;
               --print_msg(to_char(l_stage)||' No call to Rate API - budget_version_type = REVENUE - Revenue is NOT NULL');
               NULL;
        ELSIF
           rate_rec.fp_budget_version_type = 'ALL' AND
             l_txn_raw_cost IS NOT NULL AND nvl(l_txn_raw_cost,0) <> 0 AND
             l_txn_burdened_cost IS NOT NULL AND nvl(l_txn_burdened_cost,0) <> 0 AND
             l_txn_revenue IS NOT NULL AND nvl(l_txn_revenue,0) <> 0 AND
             p_mass_adjust_flag = 'N' THEN
               l_stage := 650;
               --print_msg(to_char(l_stage)||' No call to Rate API - budget_version_type = ALL - ALL have values');
               NULL;
        ELSIF
           rate_rec.fp_budget_version_type = 'COST' AND
             (l_txn_plan_quantity IS NULL OR nvl(l_txn_plan_quantity,0) = 0) AND
             (l_txn_raw_cost IS NULL OR nvl(l_txn_raw_cost,0) = 0 ) AND
             ( (l_txn_burdened_cost IS NULL OR nvl(l_txn_burdened_cost,0) = 0) OR
               (l_txn_burdened_cost is NOT NULL ))  THEN
               l_stage := 652;
               --print_msg(to_char(l_stage)||' No call to Rate API - budget_version_type = COST - Quantity AND Raw and Burdened Cost are NULL');
               NULL;
        ELSIF
           rate_rec.fp_budget_version_type = 'REVENUE' AND
             ( l_txn_plan_quantity IS NULL OR nvl(l_txn_plan_quantity,0) = 0) AND
             (l_txn_revenue IS NULL OR nvl(l_txn_revenue,0) = 0) THEN
               l_stage := 654;
               --print_msg(to_char(l_stage)||' No call to Rate API - budget_version_type = REVENUE - Quantity AND Revenue are NULL');
               NULL;
        ELSIF
           rate_rec.fp_budget_version_type = 'ALL' AND
             (l_txn_plan_quantity IS NULL OR nvl(l_txn_plan_quantity,0) = 0) AND
             (l_txn_raw_cost IS NULL OR nvl(l_txn_raw_cost,0) = 0)  AND
             (l_txn_burdened_cost IS NULL OR nvl(l_txn_burdened_cost,0) = 0)  AND
             (l_txn_revenue IS NULL OR nvl(l_txn_revenue,0) = 0) THEN
               l_stage := 656;
               --print_msg(to_char(l_stage)||' No call to Rate API - budget_version_type = ALL - ALL have NULL values');
               NULL;
        ELSE /* some or all txn amounts are not present so need to call rate API */
               l_stage := 660;
               --print_msg(to_char(l_stage)||' Some or all txn amounts are not present so need to call rate API');
               --print_msg(to_char(l_stage)||' Calling chk_req_rate_api_inputs');

            pa_fp_calc_plan_pkg.chk_req_rate_api_inputs
        ( p_budget_version_id                    => p_budget_version_id
                ,p_budget_version_type                  => rate_rec.fp_budget_version_type
                ,p_person_id                            => z.person_id
                ,p_job_id                               => z.job_id
                ,p_resource_class                       => z.resource_class_code
                ,p_rate_based_flag                      => z.rate_based_flag
                ,p_uom                                  => z.unit_of_measure
                ,p_item_date                            => z.start_date
                ,p_non_labor_resource                   => z.non_labor_resource
                ,p_expenditure_org_id                   => z.rate_expenditure_org_id
                ,p_nlr_organization_id                  => z.organization_id
                ,p_quantity                             => l_txn_plan_quantity
                ,p_cost_override_rate                   => l_rw_cost_rate_override
                ,p_revenue_override_rate                => l_bill_rate_override
                ,p_raw_cost                             => l_txn_raw_cost
                ,p_burden_cost                          => l_txn_burdened_cost
                ,p_raw_revenue                          => l_txn_revenue
                ,p_override_currency_code               => l_txn_currency_code
                ,x_return_status                        => l_return_status
                ,x_msg_data                             => x_msg_data
                ,x_msg_count                            => x_msg_count
                );

               IF l_return_status <> 'S' THEN
                         x_return_status := l_return_status;
             x_raw_cost_rejection_code := substr(x_msg_data,1,30);
             x_burden_cost_rejection_code := substr(x_msg_data,1,30);
             x_revenue_rejection_code := substr(x_msg_data,1,30);
             GOTO END_RES_RATE;
               END IF;

        IF l_rw_cost_rate_override IS NOT NULL THEN
            l_stage :=680;
            --print_msg(to_char(l_stage)||' l_rw_cost_rate_override IS NOT NULL');
            --print_msg(to_char(l_stage)||' Check if txn_currency_override is null');
        l_cost_override_currency := 'Y';
            IF l_txn_currency_code_override IS NULL THEN
                l_stage :=683;
                --print_msg(to_char(l_stage)||' Copy l_txn_currency_code into l_txn_currency_code_override');
                l_txn_currency_code_override := l_txn_currency_code;
            END IF;
        END IF;

	If z.rate_based_flag = 'N' Then
		If rate_rec.fp_budget_version_type = 'ALL' AND NVL(g_wp_version_flag,'N') = 'N' then
			If l_rw_cost_rate_override = 0 Then
				l_burden_cost_rate_override := 0;
			End If;
		End If;
	End If;

        IF l_burden_cost_rate_override IS NOT NULL THEN
            l_stage :=685;
            --print_msg(to_char(l_stage)||' l_burden_cost_rate_override IS NOT NULL');
            --print_msg(to_char(l_stage)||' Check if txn_currency_override is null');
        	l_burden_override_currency := 'Y';
            IF l_txn_currency_code_override IS NULL THEN
                l_stage :=687;
                --print_msg(to_char(l_stage)||' Copy l_txn_currency_code into l_txn_currency_code_override');
                l_txn_currency_code_override := l_txn_currency_code;
            END IF;
        END IF;

        IF l_bill_rate_override IS NOT NULL THEN
            l_stage :=689;
            --print_msg(to_char(l_stage)||' l_bill_rate_override IS NOT NULL');
            --print_msg(to_char(l_stage)||' Check if txn_currency_override is null');
        l_revenue_override_currency := 'Y';
            IF l_txn_currency_code_override IS NULL THEN
                l_stage :=690;
                --print_msg(to_char(l_stage)||' Copy l_txn_currency_code into l_txn_currency_code_override');
                l_txn_currency_code_override := l_txn_currency_code;
            END IF;
        END IF;

        IF l_txn_raw_cost IS NOT NULL THEN
            l_stage :=692;
            --print_msg(to_char(l_stage)||' l_txn_raw_cost IS NOT NULL');
            --print_msg(to_char(l_stage)||' Check if txn_currency_override is null');
        l_cost_override_currency := 'Y';
            IF l_txn_currency_code_override IS NULL THEN
                l_stage :=694;
                --print_msg(to_char(l_stage)||' Copy l_txn_currency_code into l_txn_currency_code_override');
                l_txn_currency_code_override := l_txn_currency_code;
            END IF;
        END IF;

        IF l_txn_burdened_cost IS NOT NULL THEN
            l_stage :=696;
            --print_msg(to_char(l_stage)||' l_txn_burdened_cost IS NOT NULL');
            --print_msg(to_char(l_stage)||' Check if txn_currency_override is null');
        l_burden_override_currency := 'Y';
            IF l_txn_currency_code_override IS NULL THEN
                l_stage :=697;
                --print_msg(to_char(l_stage)||' Copy l_txn_currency_code into l_txn_currency_code_override');
                l_txn_currency_code_override := l_txn_currency_code;
            END IF;
        END IF;

        IF l_txn_revenue IS NOT NULL THEN
            l_stage :=698;
            --print_msg(to_char(l_stage)||' l_txn_revenue IS NOT NULL');
            --print_msg(to_char(l_stage)||' Check if txn_currency_override is null');
        l_revenue_override_currency := 'Y';
            IF l_txn_currency_code_override IS NULL THEN
                l_stage :=699;
                --print_msg(to_char(l_stage)||' Copy l_txn_currency_code into l_txn_currency_code_override');
                l_txn_currency_code_override := l_txn_currency_code;
            END IF;
        END IF;

    IF l_txn_currency_code_override is NOT NULL Then
             IF  ( g_wp_version_flag = 'Y' AND g_ra_bl_txn_currency_code IS NULL and g_agr_conv_reqd_flag = 'N' ) THEN
                 /* set the global currency if the currency override ie cost and rates are entered from the page */
                  g_ra_bl_txn_currency_code := l_txn_currency_code_override;
                  --print_msg(' g_ra_bl_txn_currency_code set to Override currency code['||g_ra_bl_txn_currency_code||']');
             END IF;
    END IF;
	/*
    print_msg('Before calling Rate API chk overrids CostCurFlag['||l_cost_override_currency||']BurdCurFlag['||l_burden_override_currency||']');
    print_msg('RevOvrCur['||l_revenue_override_currency||']gRaBlCurCode['||g_ra_bl_txn_currency_code||']TxnCur['||l_txn_currency_code||']');
	*/

        /* Bug fix: 3861970 For people resource class, the organization override must be considered
         * this can be defined at the project level. PA_COST_DIST_OVERRIDES stores configurations defined
         * at the project level that redirect specific costs and revenue to another organization. You can define a
         * cost distribution override to redirect the costs and revenues generated by a specific employee or by all
         * employees assigned to a specified organization. You can optionally redirect only certain costs and
         * revenues by specifying an expenditure category.
         */
        l_override_organization_id := NULL;
        /* Bug fix: 4232181 As per sanjay's discussion with Anders, dinakar and Ramesh the project level override
                 * organization id should be derived for all resource classes. If user doesnot setup proper override organizations
                 * then material and bom-resources may not derive the correct rates. so commenting out the if condition
         * If z.resource_class_code = 'PEOPLE' Then
         */
            IF l_override_organization_id is NULL Then
                l_stage := 699.1;
                                pa_cost.Override_exp_organization
                                (P_item_date                  => z.start_date
                                ,P_person_id                  => z.person_id
                                ,P_project_id                 => p_project_id
                                ,P_incurred_by_organz_id      => z.organization_id
                                ,P_Expenditure_type           => nvl(z.expenditure_type,z.rate_expenditure_type)
                                ,X_overr_to_organization_id   => l_override_organization_id
                                ,X_return_status              => l_return_status
                                ,X_msg_count                  => x_msg_count
                                ,X_msg_data                   => x_msg_data
                                );
                                --print_msg(l_stage||'Return status of pa_cost.Override_exp_organization retSts['||l_return_status||']');
                        End If;
        /* End of bug fix: 4232181 End If; */
        /* End of bug fix: 3861970 */

    /* The following condition is added, to ensure that rate api derives the bill rates and revenue
     * when bill rate override is passed for non-billable tasks */
    If rate_rec.fp_budget_version_type in ('REVENUE','ALL') Then
      If (l_bill_rate_override is NOT NULL
           and l_billable_flag = 'N' ) Then
        l_rateApi_billable_flag := 'Y';
      Else
        l_rateApi_billable_flag := l_billable_flag;
      End If;
    End If;

       l_stage := 700;
	If P_PA_DEBUG_MODE = 'Y' Then
       print_msg(to_char(l_stage)||' All Rate API required parameters');
       print_msg(' ---------LEGEND----------------------------- ');
       print_msg(' **REQUIRED** = MUST BE PASSED TO RATE API');
       print_msg(' p_project_id                => '||p_project_id);
       print_msg(' p_task_id                   => '||z.task_id);
       print_msg(' p_top_task_id               => '||tsk_rec.top_task_id);
       print_msg(' p_person_id                 => '||z.person_id);
       print_msg(' p_job_id                    => '||z.job_id);
       print_msg(' p_bill_job_grp_id           => '||rate_rec.bill_job_group_id);
       print_msg(' p_project_organz_id         => '||rate_rec.carrying_out_organization_id);
       print_msg(' p_rev_res_class_rate_sch_id => '||rate_rec.res_class_bill_rate_sch_id);
       print_msg(' p_cost_res_class_rate_sch_id=> '||rate_rec.res_class_raw_cost_sch_id);
       print_msg(' p_rev_task_nl_rate_sch_id   => '||tsk_rec.non_lab_std_bill_rt_sch_id);
       print_msg(' p_rev_proj_nl_rate_sch_id   => '||rate_rec.non_lab_std_bill_rt_sch_id);
       print_msg(' p_rev_job_rate_sch_id       => '||nvl(tsk_rec.job_bill_rate_schedule_id,rate_rec.job_bill_rate_schedule_id));
       print_msg(' p_rev_emp_rate_sch_id       => '||nvl(tsk_rec.emp_bill_rate_schedule_id,rate_rec.emp_bill_rate_schedule_id));
       print_msg(' p_plan_rev_job_rate_sch_id  => '||rate_rec.rev_job_rate_sch_id);
       print_msg(' p_plan_cost_job_rate_sch_id => '||rate_rec.cost_job_rate_sch_id);
       print_msg(' p_plan_rev_emp_rate_sch_id  => '||rate_rec.rev_emp_rate_sch_id);
       print_msg(' p_plan_cost_emp_rate_sch_id => '||rate_rec.cost_emp_rate_sch_id);
       print_msg(' p_plan_rev_nlr_rate_sch_id  => '||rate_rec.rev_non_labor_res_rate_sch_id);
       print_msg(' p_plan_cost_nlr_rate_sch_id => '||rate_rec.cost_non_labor_res_rate_sch_id);
       print_msg(' p_plan_burden_cost_sch_id   => '||rate_rec.cost_burden_rate_sch_id);
       print_msg(' p_calculate_mode            => '||l_calculate_mode);
       print_msg(' p_mcb_flag                  => '||rate_rec.multi_currency_billing_flag);
       print_msg(' p_cost_rate_multiplier      => '||l_cost_rate_multiplier);
       print_msg(' p_bill_rate_multiplier      => '||l_bill_rate_multiplier);
       print_msg(' p_cost_sch_type             => '||l_cost_sch_type);
       print_msg(' p_labor_sch_type            => '||rate_rec.labor_sch_type);
       print_msg(' p_non_labor_sch_type        => '||rate_rec.non_labor_sch_type);
       print_msg(' p_labor_schdl_discnt        => '||NULL);
       print_msg(' p_labor_bill_rate_org_id    => '||rate_rec.labor_bill_rate_org_id);
       print_msg(' p_labor_std_bill_rate_schdl => '||NULL);
       print_msg(' p_labor_schdl_fixed_date    => '||NULL);
       print_msg(' p_project_org_id            => '||rate_rec.org_id);
       print_msg(' p_project_type              => '||rate_rec.project_type);
       print_msg(' p_expenditure_type          => '||nvl(z.expenditure_type,z.rate_expenditure_type));
       print_msg(' p_non_labor_resource        => '||z.non_labor_resource);
       print_msg(' p_incurred_by_organz_id     => '||z.organization_id);
       print_msg(' p_override_to_organz_id     => '||l_override_organization_id);
       print_msg(' p_expenditure_org_id        => '||nvl(z.rate_expenditure_org_id,rate_rec.org_id));
       print_msg(' p_assignment_precedes_task  => '||rate_rec.assign_precedes_task);
       print_msg(' p_planning_transaction_id   => '||z.budget_line_id);
       print_msg(' p_task_bill_rate_org_id     => '||tsk_rec.non_labor_bill_rate_org_id);
       print_msg(' p_project_bill_rate_org_id  => '||rate_rec.non_labor_bill_rate_org_id);
       print_msg(' p_nlr_organization_id       => '||z.organization_id);
       print_msg(' p_project_sch_date          => '||rate_rec.non_labor_schedule_fixed_date);
       print_msg(' p_task_sch_date             => '||tsk_rec.non_labor_schedule_fixed_date);
       print_msg(' p_project_sch_discount      => '||rate_rec.non_labor_schedule_discount);
       print_msg(' p_task_sch_discount         => '||tsk_rec.non_labor_schedule_discount);
       print_msg(' p_inventory_item_id         => '||z.inventory_item_id);
       print_msg(' p_BOM_resource_Id           => '||z.bom_resource_id);
       print_msg(' P_mfc_cost_type_id          => '||z.mfc_cost_type_id);
       print_msg(' P_item_category_id          => '||z.item_category_id);
       print_msg(' p_mfc_cost_source           => '||l_mfc_cost_source);
       print_msg(' ** p_assignment_id             => '||z.resource_assignment_id);
       print_msg(' ** p_resource_class            => '||z.resource_class_code);
       print_msg(' ** p_planning_resource_format  => '||z.res_format_id);
       print_msg(' ** p_use_planning_rates_flag   => '||rate_rec.use_planning_rates_flag);
       print_msg(' ** p_rate_based_flag           => '||z.rate_based_flag);
       print_msg(' ** p_uom                       => '||z.unit_of_measure);
       print_msg(' ** p_quantity                  => '||l_txn_plan_quantity);
       print_msg(' ** p_item_date                 => '||z.start_date);
       print_msg(' ** p_cost_override_rate        => '||l_rw_cost_rate_override);
       print_msg(' ** p_revenue_override_rate     => '||l_bill_rate_override);
       print_msg(' ** p_override_burden_cost_rate => '||l_burden_cost_rate_override);
       print_msg(' ** p_override_currency_code    => '||l_txn_currency_code_override);
       print_msg(' ** p_txn_currency_code         => '||l_txn_currency_code);
       print_msg(' ** p_raw_cost                  => '||l_txn_raw_cost);
       print_msg(' ** p_burden_cost               => '||l_txn_burdened_cost);
       print_msg(' ** p_raw_revenue               => '||l_txn_revenue);
       print_msg(' ** p_RateApibillability_flag   => '||l_rateApi_billable_flag);
	End if;

       l_stage := 740;
    /*
    *CALL get_planning_rates
    */
        l_stage := 745;
        --print_msg(to_char(l_stage)||' ****Calling get_planning_rates****');
        BEGIN
        /* bug fix: 3737994: For project level budgeting the task id should be passed as NULL instead of zero to calculate
                 * project level bill rate overrides
                 */
         l_task_id := z.task_id;
         If l_task_id = 0 Then
            l_task_id := NULL;
         End If;

        /* Bug fix:4133047 pass the Task level or project level labor and non-labor sch types to bill rate api in order to
        * derive the markup based on burden schedule or bill rate schedule
        */
        If l_task_id IS NOT NULL THEN
                    l_labor_sch_type:= tsk_rec.labor_sch_type;
                    l_non_labor_sch_type  := tsk_rec.non_labor_sch_type;
            Else
                    l_labor_sch_type:= rate_rec.labor_sch_type;
                    l_non_labor_sch_type  := rate_rec.non_labor_sch_type;
            End If;
            pa_plan_revenue.Get_planning_Rates
                (
                                p_project_id                           =>  p_project_id
                                /* bug fix: 3737994 ,p_task_id          => z.task_id */
                                ,p_task_id                              => l_task_id
                                ,p_top_task_id                          => tsk_rec.top_task_id
                                ,p_person_id                            => z.person_id
                                ,p_job_id                               => z.job_id
                                ,p_bill_job_grp_id                      => rate_rec.bill_job_group_id
                                ,p_resource_class                       => z.resource_class_code
                                ,p_planning_resource_format             => z.res_format_id
                                ,p_use_planning_rates_flag              => NVL(rate_rec.use_planning_rates_flag,'N')
                                ,p_rate_based_flag                      => NVL(z.rate_based_flag,'N')
                                ,p_uom                                  => z.unit_of_measure
                                ,p_system_linkage                       => NULL
                                ,p_project_organz_id                    => rate_rec.carrying_out_organization_id
                                ,p_rev_res_class_rate_sch_id            => rate_rec.res_class_bill_rate_sch_id
                                ,p_cost_res_class_rate_sch_id           => rate_rec.res_class_raw_cost_sch_id
                                ,p_rev_task_nl_rate_sch_id              => tsk_rec.non_lab_std_bill_rt_sch_id
                                ,p_rev_proj_nl_rate_sch_id              => rate_rec.non_lab_std_bill_rt_sch_id
				/* bug fix:5056986: Pass task level rate schedule overrides when exists */
                                ,p_rev_job_rate_sch_id                  => nvl(tsk_rec.job_bill_rate_schedule_id,rate_rec.job_bill_rate_schedule_id)
                                ,p_rev_emp_rate_sch_id                  => nvl(tsk_rec.emp_bill_rate_schedule_id,rate_rec.emp_bill_rate_schedule_id)
                                ,p_plan_rev_job_rate_sch_id             => rate_rec.rev_job_rate_sch_id
                                ,p_plan_cost_job_rate_sch_id            => rate_rec.cost_job_rate_sch_id
                                ,p_plan_rev_emp_rate_sch_id             => rate_rec.rev_emp_rate_sch_id
                                ,p_plan_cost_emp_rate_sch_id            => rate_rec.cost_emp_rate_sch_id
                                ,p_plan_rev_nlr_rate_sch_id             => rate_rec.rev_non_labor_res_rate_sch_id
                                ,p_plan_cost_nlr_rate_sch_id            => rate_rec.cost_non_labor_res_rate_sch_id
                                ,p_plan_burden_cost_sch_id              => rate_rec.cost_burden_rate_sch_id
                                ,p_calculate_mode                       => l_calculate_mode
                                ,p_mcb_flag                             => rate_rec.multi_currency_billing_flag
                                ,p_cost_rate_multiplier                 => l_cost_rate_multiplier
                                ,p_bill_rate_multiplier                 => l_bill_rate_multiplier
                                ,p_quantity                             => l_txn_plan_quantity
                                ,p_item_date                            => z.start_date
                                ,p_cost_sch_type                        => l_cost_sch_type
                                ,p_labor_sch_type                       => l_labor_sch_type
                                ,p_non_labor_sch_type                   => l_non_labor_sch_type
                                ,p_labor_schdl_discnt                   => NULL
                                ,p_labor_bill_rate_org_id               => rate_rec.labor_bill_rate_org_id
                                ,p_labor_std_bill_rate_schdl            => NULL
                                ,p_labor_schdl_fixed_date               => NULL
                                ,p_assignment_id                        => z.resource_assignment_id
                                ,p_project_org_id                       => rate_rec.org_id
                                ,p_project_type                         => rate_rec.project_type
                                ,p_expenditure_type                     => nvl(z.expenditure_type,z.rate_expenditure_type)
                                ,p_non_labor_resource                   => z.non_labor_resource
                                ,p_incurred_by_organz_id                => z.organization_id
                                ,p_override_to_organz_id                => l_override_organization_id
                                ,p_expenditure_org_id                   => nvl(z.rate_expenditure_org_id,rate_rec.org_id)
                                ,p_assignment_precedes_task             => rate_rec.assign_precedes_task
                                ,p_planning_transaction_id              => z.budget_line_id
                                ,p_task_bill_rate_org_id                => tsk_rec.non_labor_bill_rate_org_id
                                ,p_project_bill_rate_org_id             => rate_rec.non_labor_bill_rate_org_id
                                ,p_nlr_organization_id                  => z.organization_id
                                ,p_project_sch_date                     => rate_rec.non_labor_schedule_fixed_date
                                ,p_task_sch_date                        => tsk_rec.non_labor_schedule_fixed_date
                                ,p_project_sch_discount                 => rate_rec.non_labor_schedule_discount
                                ,p_task_sch_discount                    => tsk_rec.non_labor_schedule_discount
                                ,p_inventory_item_id                    => z.inventory_item_id
                                ,p_BOM_resource_Id                      => z.bom_resource_id
                                ,P_mfc_cost_type_id                     => z.mfc_cost_type_id
                                ,P_item_category_id                     => z.item_category_id
                                ,p_mfc_cost_source                      => l_mfc_cost_source
                                ,p_cost_override_rate                   => l_rw_cost_rate_override
                                ,p_revenue_override_rate                => l_bill_rate_override
                                ,p_override_burden_cost_rate            => l_burden_cost_rate_override
                                ,p_override_currency_code               => l_txn_currency_code_override
                                ,p_txn_currency_code                    => l_txn_currency_code
                                ,p_raw_cost                             => l_txn_raw_cost
                                ,p_burden_cost                          => l_txn_burdened_cost
                                ,p_raw_revenue                          => l_txn_revenue
                		,p_billability_flag                     => l_rateApi_billable_flag
                                ,x_bill_rate                            => x_bill_rate
                                ,x_cost_rate                            => x_cost_rate
                                ,x_burden_cost_rate                     => x_burden_cost_rate
                                ,x_burden_multiplier                    => x_burden_multiplier
                                ,x_raw_cost                             => x_raw_cost
                                ,x_burden_cost                          => x_burden_cost
                                ,x_raw_revenue                          => x_raw_revenue
                                ,x_bill_markup_percentage               => x_bill_markup_percentage
                                ,x_cost_txn_curr_code                   => x_cost_txn_curr_code
                                ,x_rev_txn_curr_code                    => x_rev_txn_curr_code
                                ,x_raw_cost_rejection_code              => x_raw_cost_rejection_code
                                ,x_burden_cost_rejection_code           => x_burden_cost_rejection_code
                                ,x_revenue_rejection_code               => x_revenue_rejection_code
                                ,x_cost_ind_compiled_set_id             => x_cost_ind_compiled_set_id
                                ,x_return_status                        => l_return_status
                                ,x_msg_data                             => x_msg_data
                                ,x_msg_count                            => x_msg_count
                                );
	    If P_PA_DEBUG_MODE = 'Y' Then
            print_msg('Return status of the RATE API['||l_return_status||']msgData['||x_msg_data||']');
            print_msg('get_plannig_rateAPIMsgCtinErrStack['||fnd_msg_pub.count_msg||']');
	    End if;
                If l_return_status = 'U' Then
                    x_raw_cost_rejection_code      := substr('PA_FP_ERROR_FROM_RATE_API_CALL',1,30);
                        x_burden_cost_rejection_code   := substr(SQLERRM,1,30);
                        x_revenue_rejection_code       := substr('PA_FP_ERROR_FROM_RATE_API_CALL',1,30);
                         pa_utils.add_message
                          ( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_FP_ERROR_FROM_RATE_API_CALL'
                          ,p_token1         => 'G_PROJECT_NAME'
                          ,p_value1         => g_project_name
                          ,p_token2         => 'G_TASK_NAME'
                          ,p_value2         => g_task_name
                          ,p_token3         => 'G_RESOURCE_NAME'
                          ,p_value3         => g_resource_name
                          ,p_token4         => 'TO_CHAR(L_TXN_CURRENCY_CODE)' /*instead of changing the msg and logging seed bug changed the token */
                          ,p_value4         => l_txn_currency_code
                          ,p_token5         => 'TO_CHAR(L_BUDGET_LINES_START_DATE)'
                          ,p_value5         => to_char(z.start_date));

                    x_return_status := l_return_status;
                    /* bug fix: 4078623 GOTO END_RES_RATE; */
                        RAISE RATEAPI_UNEXPECTED_ERRORS;
            End If;

        EXCEPTION
        WHEN OTHERS THEN

            print_msg('Unexpected error occured in RATE API');
                x_raw_cost_rejection_code      := substr('PA_FP_ERROR_FROM_RATE_API_CALL',1,30);
                x_burden_cost_rejection_code   := substr(SQLERRM,1,30);
                x_revenue_rejection_code       := substr('PA_FP_ERROR_FROM_RATE_API_CALL',1,30);
            If l_return_status = 'U' Then
                x_return_status := l_return_status;
             pa_utils.add_message
                          ( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_FP_ERROR_FROM_RATE_API_CALL'
                          ,p_token1         => 'G_PROJECT_NAME'
                          ,p_value1         => g_project_name
                          ,p_token2         => 'G_TASK_NAME'
                          ,p_value2         => g_task_name
                          ,p_token3         => 'G_RESOURCE_NAME'
                          ,p_value3         => g_resource_name
                          ,p_token4         => 'TO_CHAR(L_TXN_CURRENCY_CODE)'
                          ,p_value4         => l_txn_currency_code
                          ,p_token5         => 'TO_CHAR(L_BUDGET_LINES_START_DATE)'
                          ,p_value5         => to_char(z.start_date));
            End If;
            /* bug fix: 4078623 GOTO END_RES_RATE; */
                        RAISE RATEAPI_UNEXPECTED_ERRORS;
    END;

        l_stage := 746;
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg(l_stage||'****AFTER Calling get_planning_rates**** Raw Values returned by Rate API: ');
        print_msg('x_cost_txn_curr_code['||x_cost_txn_curr_code||']x_raw_cost['||x_raw_cost||']x_cost_rate['||x_cost_rate||']');
    print_msg('x_burden_cost['||x_burden_cost||']x_burden_cost_rate['||x_burden_cost_rate||']x_burden_multiplier['||x_burden_multiplier||']');
    print_msg('x_cost_ind_compiled_set_id['||x_cost_ind_compiled_set_id||']');
    print_msg('x_rev_txn_curr_code['||x_rev_txn_curr_code||']x_raw_revenue['||x_raw_revenue||']x_bill_rate['||x_bill_rate||']');
    print_msg('markup['||x_bill_markup_percentage||']x_revenue_rejection_code['||x_revenue_rejection_code||']');
    print_msg('CostRejection['||x_raw_cost_rejection_code||']BurdRejection['||x_burden_cost_rejection_code||']');
	End if;

		/* bug fix:5054395 : donot derive revenue based on bill rate for non-rate base resource when markup% is not exists */
		If p_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION') THEN
			If NVL(z.rate_based_flag,'N') = 'N' Then
				If rate_rec.fp_budget_version_type = 'ALL' Then
				   /* for a non rate based resource if markup percent is not setup then
				    * donot derive the revenue. ignore bill rate
				    */
				     If l_bill_rate_override is NULL and x_bill_markup_percentage is NULL Then
					--print_msg('Resetting the revenue to Null for Non-rate base resources ');
					x_bill_rate := NULL;
					x_raw_revenue := NULL;
				     End If;

				     /* The following conditions are to reset the quantity for revenue only entered transaction
				      * for cost and revenue together version
				      */
				      If l_bill_rate_override is NOT NULL and l_rw_cost_rate_override = 0 Then
					 If l_txn_plan_quantity <> x_raw_revenue Then
						l_txn_plan_quantity := x_raw_revenue;
						l_bill_rate_override := 1;
					 End If;
				      End If;
				End If;
			End If;
		End If;


            /* ER:4376722 : Billability changes */
                IF NVL(l_billable_flag,'N') = 'N' Then --{
                  IF (p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION')) THEN
               /* Added these for future reference: in case if we need to retain the revenue from generation process passes the
                * the bill rate overrides,
                * : July 20, 2005: again decision changed to retain the revenue for Forecast generation process if bill rate override is passed
                */
               IF p_calling_module = 'FORECAST_GENERATION' Then
                             If l_bill_rate_override is NULL Then
                              x_bill_rate := NULL;
                              x_raw_revenue := NULL;
                              x_bill_markup_percentage := NULL;
                              l_bill_rate_override := NULL;
                 End If;
                           End If;
               If p_calling_module = 'BUDGET_GENERATION' Then
                             l_bill_rate_override := NULL;
                             x_bill_rate := NULL;
                             x_raw_revenue := NULL;
                             x_bill_markup_percentage := NULL;
                             x_revenue_rejection_code := NULL;
               End If;
               If (rate_rec.fp_budget_version_type = 'REVENUE'
                              and NVL(z.rate_based_flag,'N') = 'N'
                              --and l_bill_rate_override is NULL
                                ) Then
                                l_txn_plan_quantity := NULL;
                                x_raw_revenue := NULL;
                           End If;
                  ElsIf rate_rec.fp_budget_version_type = 'REVENUE' Then
                    If NVL(z.rate_based_flag,'N') = 'Y' Then
                        If l_bill_rate_override is NULL Then
                           x_bill_rate := NULL;
                           x_revenue_rejection_code := NULL;
                           x_raw_revenue := NULL;
                           x_bill_markup_percentage := NULL;
                        End If;
                    End If;
                  Elsif rate_rec.fp_budget_version_type = 'ALL' Then
                        If l_bill_rate_override is NULL Then
                           x_bill_rate := NULL;
                           x_revenue_rejection_code := NULL;
                           x_raw_revenue := NULL;
                           x_bill_markup_percentage := NULL;
                        End If;
                  End If;
                END If; --}

    /* For workplan version there should not be any rejections from revenue related columns
     * so assign all the params to null or ignore the values returned from rate api for revenue columns
     */
        IF ( rate_rec.fp_budget_version_type = 'COST' OR NVL(g_wp_version_flag,'N') = 'Y' ) THEN
          l_stage := 750;
          --print_msg(to_char(l_stage)||' rate_rec.fp_budget_version_type = COST set REVENUE parameters to NULL');
          x_bill_rate                            := NULL;
          x_raw_revenue                          := NULL;
          x_bill_markup_percentage               := NULL;
          x_rev_txn_curr_code                    := NULL;
          x_revenue_rejection_code               := NULL;
      /* Bug fix: 4293020 set rate overrides to null where appropriate */
      l_bill_rate_override                   := NULL;
        ELSIF ( rate_rec.fp_budget_version_type = 'REVENUE'
        AND ( l_revenue_generation_method <> 'T'
          OR p_calling_module NOT IN ('BUDGET_GENERATION','FORECAST_GENERATION')))  THEN
          l_stage := 755;
          --print_msg(to_char(l_stage)||' rate_rec.fp_budget_version_type = REVENUE set COST parameters to NULL');
          x_cost_rate                            := NULL;
          x_burden_cost_rate                     := NULL;
          x_burden_multiplier                    := NULL;
          x_raw_cost                             := NULL;
          x_burden_cost                          := NULL;
          x_cost_txn_curr_code                   := NULL;
          x_raw_cost_rejection_code              := NULL;
          x_burden_cost_rejection_code           := NULL;
          x_cost_ind_compiled_set_id             := NULL;
      /* Bug fix: 4293020 set rate overrides to null where appropriate */
      l_rw_cost_rate_override        := NULL;
      l_burden_cost_rate_override        := NULL;
        ELSIF rate_rec.fp_budget_version_type = 'ALL'  THEN
          l_stage := 757;
          --print_msg(to_char(l_stage)||' rate_rec.fp_budget_version_type = ALL -- leave x parameters as is');
      /* during Revenue budget generation, If the Revenue generation method is based on Cost or Event Based
           * the calling API will generate the revenue amounts by applying the event markups
       * Bug fix: 3765835
       * Revenue Generation method : C - Cost, E - Event Based, T - Time, W - Wrok
       */
       IF p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION')
           --Bug 6722414 When called from ETC client extension, Dont null out revenue amounts.
       AND  NVL(g_from_etc_client_extn_flag,'N')='N' THEN
          IF NVL(l_revenue_generation_method,'W') in ('C','E') Then
        --print_msg('Revenue Generation Method is COST or EVENT so Null out Revenue columns');
        -- set all the revenue params to NULL
        x_bill_rate                            := NULL;
            x_raw_revenue                          := NULL;
            x_bill_markup_percentage               := NULL;
            x_rev_txn_curr_code                    := NULL;
            x_revenue_rejection_code               := NULL;
        /* Bug fix: 4293020 set rate overrides to null where appropriate */
        l_bill_rate_override                   := NULL;

          End If;
       END IF;
        END IF;

    /* Rounding Enhancements : */
        /* Bug fix:4085836 Derive the burden rate based on the unrounded burdened cost by etc quantity */
        IF rate_rec.fp_budget_version_type in ('COST','ALL') AND NVL(l_burden_override_currency,'N') <> 'Y' THEN
                IF NVL(l_txn_plan_quantity,0) <> 0  AND NVL(x_burden_cost,0) <> 0 AND NVL(x_cost_rate,0) <> 0 THEN
                        IF x_raw_cost = x_burden_cost THEN
                                x_burden_cost_rate := x_cost_rate;
                        ElsIF NVL(x_burden_multiplier,0) <> 0 Then
                                x_burden_cost_rate := ((l_txn_plan_quantity * x_cost_rate) +
                            ((l_txn_plan_quantity * x_cost_rate)*NVL(x_burden_multiplier,0)))/l_txn_plan_quantity;
                x_burden_cost := pa_currency.round_trans_currency_amt1
                         ((l_txn_plan_quantity *x_burden_cost_rate),NVL(x_cost_txn_curr_code,l_txn_currency_code));
                        END IF;
                END IF;
        END IF;

        /* When markup percent is defined for a resource, The rate api is not deriving Bill Rates
         * due to this, the Revenue on the page derives as zero
         */
        IF NVL(x_raw_revenue,0) <> 0 AND NVL(l_txn_plan_quantity,0) <> 0 Then
                IF x_bill_rate is NULL Then
                        /* check whether markup is applied on raw cost or burdened cost then
                         * derive the bill rate based on unrounded revenue
                         */
                        IF NVL(x_bill_markup_percentage,0) <> 0  Then
                             IF x_raw_revenue = (pa_currency.round_trans_currency_amt1(
                                                  ((1+x_bill_markup_percentage/100)*x_raw_cost),NVL(x_rev_txn_curr_code
                                                                                ,NVL(x_cost_txn_curr_code,l_txn_currency_code)))) Then
                                x_bill_rate := ((1+x_bill_markup_percentage/100)*x_raw_cost)/l_txn_plan_quantity;

                             Elsif x_raw_revenue = (pa_currency.round_trans_currency_amt1(
                                                  ((1+x_bill_markup_percentage/100)*x_burden_cost),NVL(x_rev_txn_curr_code
                                                                                ,NVL(x_cost_txn_curr_code,l_txn_currency_code)))) Then
                                x_bill_rate := ((1+x_bill_markup_percentage/100)*x_burden_cost)/l_txn_plan_quantity;

                             ElsIF NVL(x_raw_cost,0) <> 0 Then
                                x_bill_rate := ((1+x_bill_markup_percentage/100)*x_raw_cost)/l_txn_plan_quantity;
                             Else
                                x_bill_rate := x_raw_revenue/l_txn_plan_quantity ;
                             End If;
                        Else
                                x_bill_rate := x_raw_revenue/l_txn_plan_quantity ;
                        End If;
            /* Bug fix:4099096 For non-rate base if bill rate is null set it to 1 */
            If rate_rec.fp_budget_version_type = 'REVENUE' Then
              If NVL(z.rate_based_flag,'N') = 'N' AND x_bill_rate is NULL Then
                x_bill_rate := 1;
              End If;
            End If;
                End If;
        End If;

    /* Bug fix: 4163722 If markup percent is not defined then for non-rate base resource revenue only version
        * revenue should not be derived based on the bill rate * quantity.
        * discussed with Neeraj, sanjay, ramesh assign burdened cost to revenue and mark bill rate override = 1
        */
        IF (p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION') and l_revenue_generation_method = 'T') THEN
                If rate_rec.fp_budget_version_type = 'REVENUE' Then
                    IF caltmp.rate_based_flag = 'N' Then
                        /* Bug fix:4229752 l_calculate_mode  := 'REVENUE'; causing markup calculates only for the first line */
                        If (NVL(x_bill_markup_percentage,0) = 0 AND  z.markup_calculation_flag = 'Y' ) Then
                          x_raw_revenue := NVL(x_burden_cost,x_raw_cost);
                          x_bill_rate := 1;
                          x_rev_txn_curr_code := l_txn_currency_code;
                          l_txn_plan_quantity := x_raw_revenue;
                        End If;
            Else -- for rate base resource
            If (NVL(x_bill_markup_percentage,0) <> 0) Then
                -- mark is applied on raw/burden cost so currency should not change
                x_rev_txn_curr_code := l_txn_currency_code;
            Else
                -- for revenue only version rate is applied on qty so ignore cost currency given by rate api
                If (l_txn_currency_code_override is NOT NULL
                    and x_rev_txn_curr_code <> l_txn_currency_code_override) Then
                   l_txn_currency_code_override := x_rev_txn_curr_code;
                End If;
            End If;
                    End If;
                End If;
        End If;
    /* Bug fix: 4294287 Starts */
    IF (p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION')) THEN
                If rate_rec.fp_budget_version_type = 'REVENUE' Then
          If (NVL(x_bill_markup_percentage,0) <> 0) Then
                  l_bill_rate_override := x_bill_rate;
          End If;
        End If;
    End If;
    IF rate_rec.fp_budget_version_type = 'REVENUE' Then
       If (NVL(x_bill_markup_percentage,0) = 0) Then
        If (NVL(l_bill_markup_percentage,0) <> 0) Then
           x_bill_markup_percentage := l_bill_markup_percentage;
           --print_msg('4294287:copy the old bill markup percentage');
        End If;
       End If;
    End If;
    /* Bug fix:4294287 Ends */

    /* bug fix: 4214050 Starts*/
    IF (rate_rec.fp_budget_version_type = 'REVENUE')  THEN
          l_stage := 4214050;
          --print_msg(to_char(l_stage)||' rate_rec.fp_budget_version_type = REVENUE set COST parameters to NULL');
          x_cost_rate                            := NULL;
          x_burden_cost_rate                     := NULL;
          x_burden_multiplier                    := NULL;
          x_raw_cost                             := NULL;
          x_burden_cost                          := NULL;
          x_cost_txn_curr_code                   := NULL;
          x_raw_cost_rejection_code              := NULL;
          x_burden_cost_rejection_code           := NULL;
          x_cost_ind_compiled_set_id             := NULL;
      l_rw_cost_rate_override                := NULL;
      l_burden_cost_rate_override            := NULL;
    End If;
    /* bug fix: 4214050 Ends */

    /* ER:4376722 : Billability changes */
        IF NVL(l_billable_flag,'N') = 'N' Then --{
          IF (p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION')) THEN
               IF p_calling_module = 'FORECAST_GENERATION' Then
                 If l_bill_rate_override is NULL Then
                   /* Added these for future reference: in case if we need to retain the revenue from generation process passes the
                                * the bill rate overrides,*/
                    x_bill_rate := NULL;
                l_bill_rate_override := NULL;
                x_revenue_rejection_code := NULL;
                                x_raw_revenue := NULL;
                                x_bill_markup_percentage := NULL;
                 End If;
               End If;
               IF p_calling_module = 'BUDGET_GENERATION' Then
                l_bill_rate_override := NULL;
                x_bill_rate := NULL;
                            x_revenue_rejection_code := NULL;
                            x_raw_revenue := NULL;
                            x_bill_markup_percentage := NULL;
               End If;
               If (rate_rec.fp_budget_version_type = 'REVENUE'
                  and NVL(z.rate_based_flag,'N') = 'N'
                  --and l_bill_rate_override is NULL
                ) Then
                l_txn_plan_quantity := NULL;
                x_raw_revenue := NULL;
               End If;
                  ElsIf rate_rec.fp_budget_version_type = 'REVENUE' Then
                    If NVL(z.rate_based_flag,'N') = 'Y' Then
                        If l_bill_rate_override is NULL Then
                           x_bill_rate := NULL;
                           x_revenue_rejection_code := NULL;
                           x_raw_revenue := NULL;
                           x_bill_markup_percentage:= NULL;
                        End If;
                    End If;
                  Elsif rate_rec.fp_budget_version_type = 'ALL' Then
                        If l_bill_rate_override is NULL Then
                           x_bill_rate := NULL;
                           x_revenue_rejection_code := NULL;
                           x_raw_revenue := NULL;
                           x_bill_markup_percentage := NULL;
                        End If;
                  End If;
        END If; --}

    IF NVL(x_raw_cost,0) <> 0 Then
        x_raw_cost := pa_currency.round_trans_currency_amt1(x_raw_cost,NVL(x_cost_txn_curr_code,l_txn_currency_code_override));
    End If;

    IF NVL(x_burden_cost,0) <> 0 Then
        x_burden_cost := pa_currency.round_trans_currency_amt1(x_burden_cost,
                    NVL(l_txn_currency_code_override,x_cost_txn_curr_code));
    End If;

    If NVL(x_raw_revenue,0) <> 0 Then
        x_raw_revenue :=  pa_currency.round_trans_currency_amt1(x_raw_revenue,
                    NVL(x_rev_txn_curr_code,l_txn_currency_code_override));
    End If;

    /***
       print_msg('Corrected Rate API values based on Budget Version Type (COST/REVENUE or ALL');
       print_msg(' x_bill_rate                            => '||to_char(x_bill_rate));
       print_msg(' x_cost_rate                            => '||to_char(x_cost_rate));
       print_msg(' x_burden_cost_rate                     => '||to_char(x_burden_cost_rate));
       print_msg(' x_raw_cost                             => '||to_char(x_raw_cost));
       print_msg(' x_burden_cost                          => '||to_char(x_burden_cost));
       print_msg(' x_raw_revenue                          => '||to_char(x_raw_revenue));
       print_msg(' x_bill_markup_percentage               => '||to_char(x_bill_markup_percentage));
       print_msg(' x_cost_txn_curr_code                   => '||x_cost_txn_curr_code);
       print_msg(' x_rev_txn_curr_code                    => '||x_rev_txn_curr_code);
       print_msg(' x_raw_cost_rejection_code              => '||x_raw_cost_rejection_code);
       print_msg(' x_burden_cost_rejection_code           => '||x_burden_cost_rejection_code);
       print_msg(' x_revenue_rejection_code               => '||x_revenue_rejection_code);
       print_msg(' x_cost_ind_compiled_set_id             => '||to_char(x_cost_ind_compiled_set_id));
    **/

        /*
        --  Check to make sure RATE API does not return 2 different values for
        --  the x_cost_txn_curr_code or x_rev_txn_curr_code.  If the values are different
        --  set Revenue Parameters to NULL and x_revenue_rejection_code := 'MORE_THAN_ONE_CURR'
        --  Else assign l_txn_currency_code with either the cost or rev
        --  txn_curr_code that is not null.  This attribute is needed by the procedure
        --  update_rollup_tmp
        */
                l_convert_rawcost_only_flag     := 'N';
                l_convert_revenue_only_flag     := 'N';
                l_ra_txn_currency_api_call      := 'N';
            IF x_cost_txn_curr_code IS NOT NULL AND x_rev_txn_curr_code IS NULL THEN  --{
                l_stage := 800;
                l_txn_currency_code := x_cost_txn_curr_code;
                --print_msg(l_stage||'l_txn_currency_code set to x_cost_txn_curr_code := '||l_txn_currency_code);
                        /* if only the burden rate is entered then we need to retain the currency of the burden rate but
                         * rate api returns the different currency for the raw cost then we need to convert the
                         * raw cost to the currency of the burden cost */
                         --If ( g_wp_version_flag = 'N' AND  g_agr_conv_reqd_flag = 'N' AND NVL(l_burden_override_currency,'N') = 'Y' ) Then
                         If ( NVL(l_burden_override_currency,'N') = 'Y' ) Then
                                IF NVL(l_cost_override_currency,'N') = 'N' Then
                                        IF (l_txn_currency_code_override is NOT NULL
                                            AND l_txn_currency_code_override <> l_txn_currency_code ) Then
                        --print_msg('800:Setting l_convert_rawcost_only_flag to Y');
                                            l_convert_rawcost_only_flag := 'Y';
                                        End If;
                                End If;
                         End If;
            ELSIF x_cost_txn_curr_code IS NULL AND x_rev_txn_curr_code IS NOT NULL THEN
                l_stage := 801;
                l_txn_currency_code := x_rev_txn_curr_code;
            IF NVL(l_revenue_override_currency,'N') = 'N' Then
                               IF (l_txn_currency_code_override is NOT NULL
                                   AND l_txn_currency_code_override <> l_txn_currency_code ) Then
                                       l_convert_revenue_only_flag := 'Y';
                               End If;
                        End If;
                --print_msg(l_stage||'l_txn_currency_code set to x_rev_txn_curr_code := '||l_txn_currency_code);

            ELSIF x_cost_txn_curr_code IS NOT NULL AND x_rev_txn_curr_code IS NOT NULL THEN
                IF  x_cost_txn_curr_code = x_rev_txn_curr_code THEN
                    l_stage := 802;
                    l_txn_currency_code := x_cost_txn_curr_code;
                    --print_msg('l_txn_currency_code set to x_cost_txn_curr_code := '||l_txn_currency_code);
                                If ( NVL(l_burden_override_currency,'N') = 'Y' ) Then
                                  IF NVL(l_cost_override_currency,'N') = 'N' Then
                                        IF (l_txn_currency_code_override is NOT NULL
                                            AND l_txn_currency_code_override <> l_txn_currency_code ) Then
                        --print_msg('802:Setting l_convert_rawcost_only_flag to Y');
                                            l_convert_rawcost_only_flag := 'Y';
                                        End If;
                                  End If;
                                  IF NVL(l_revenue_override_currency,'N') = 'N' Then
                                        IF (l_txn_currency_code_override is NOT NULL
                                            AND l_txn_currency_code_override <> l_txn_currency_code ) Then
                                            l_convert_revenue_only_flag := 'Y';
                                        End If;
                                  End If;
                                End If;
                ELSIF x_cost_txn_curr_code <> x_rev_txn_curr_code THEN  --{
                    l_stage := 803;
		    /*
                    print_msg(l_stage||'More than one currency returned by Rate API.Revenue Currency and Cost Currency are not equal');
                    print_msg('x_cost_txn_curr_code['||x_cost_txn_curr_code||'x_rev_txn_curr_code['||x_rev_txn_curr_code);
		    */
                l_ra_txn_currency_api_call := 'Y';
                                If ( NVL(l_burden_override_currency,'N') = 'Y' ) Then
                                  IF NVL(l_cost_override_currency,'N') = 'N' Then
                                        IF (l_txn_currency_code_override is NOT NULL
                                            AND l_txn_currency_code_override <> x_cost_txn_curr_code ) Then
                        --print_msg('803:Setting l_convert_rawcost_only_flag to Y');
                                            l_convert_rawcost_only_flag := 'Y';
                                        End If;
                                  End If;
                                  IF NVL(l_revenue_override_currency,'N') = 'N' Then
                                        IF (l_txn_currency_code_override is NOT NULL
                                            AND l_txn_currency_code_override <> x_rev_txn_curr_code ) Then
                                            l_convert_revenue_only_flag := 'Y';
                                        End If;
                                  End If;
                                End If;
                        END IF;  --}
                END IF; --}

                /* The following code is added to handle when qty and burden rate is entered, and rate api gives the different currency
                 * for the cost rate. In such case convert the raw cost to burden cost currency (override currency) */

                -- Bug 6882579 (Handle case where rate is 0 for a resource class rate schedule)

                IF nvl(l_convert_rawcost_only_flag,'N') = 'Y' Then  --{
                        IF ((l_txn_currency_code_override IS NOT NULL) AND
                (l_txn_currency_code_override <> x_cost_txn_curr_code)) THEN --{
                 IF (nvl(x_raw_cost,0) <> 0) THEN
                                l_error_code := NULL;
                                --print_msg('Calling Convert_Final_Txn_Cur_Amts API for Cost amts');
                                Convert_Final_Txn_Cur_Amts(
                                p_project_id            => g_project_id
                                ,p_budget_version_id    => p_budget_version_id
                                ,p_budget_version_type  => rate_rec.fp_budget_version_type
                                ,p_rate_base_flag       => z.rate_based_flag
                                ,p_exp_org_id           => nvl(z.rate_expenditure_org_id,rate_rec.org_id)
                                ,p_task_id              => NVL(z.task_id,g_task_id)
                                ,p_ei_date              => z.start_date
                                ,p_denom_quantity       => l_txn_plan_quantity
                                ,p_denom_raw_cost       => x_raw_cost
                                ,p_denom_burden_cost    => NULL
                                ,p_denom_revenue        => NULL
                                ,p_denom_curr_code      => x_cost_txn_curr_code
                                ,p_final_txn_curr_code  => l_txn_currency_code_override
                                ,x_final_txn_rate_type  => l_Final_txn_rate_type
                                ,x_final_txn_rate_date  => l_Final_txn_rate_date
                                ,x_final_txn_exch_rate  => l_Final_txn_exch_rate
                                ,x_final_txn_quantity   => l_Final_txn_Quantity
                                ,x_final_txn_raw_cost   => l_Final_txn_raw_cost
                                ,x_final_txn_burden_cost =>l_Final_txn_burden_cost
                                ,x_final_txn_revenue    => l_Final_txn_revenue
                                ,x_return_status        => l_return_status
                                ,x_msg_data             => l_error_code
                                ,x_stage                => l_stage
                                );
                                --print_msg('End Of Convert_Final_Txn_Cur_Amts API retSts['||l_return_status||']ErrCode['||l_error_code||']');
                                IF l_return_status <> 'S' Then
                    			x_return_status := 'E';
                                        If rate_rec.fp_budget_version_type in ('ALL','COST') Then
                                          If x_raw_cost_rejection_code is NULL Then
                                              x_raw_cost_rejection_code := substr(l_error_code,1,30);
                                          End If;
                                        End If;
				    	/*bug 4474861: for web adi flow, collect the invalid record informations
                                     	* to call an api to update the interface table with the web adi error code
				     	*/
                                    	IF l_webAdi_calling_context = 'WEBADI_CALCULATE' THEN
                                          IF l_error_code = 'PA_FP_PROJ_NO_TXNCONVRATE' THEN
                                            -- populating the error tables.
                                            -- calling pa_fp_webadi_pkg.process_errors
                                            --print_msg('ConvErr:Web ADI context collecting errors');
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.EXTEND(1);
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
					      (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).error_code :=
							'PA_FP_WA_TXN_CURR_NO_CONV_RATE';
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
						(PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).task_id := z.task_id;
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
						(PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).rlm_id :=
						z.resource_list_member_id;
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
						(PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).txn_currency :=
						l_txn_currency_code;
                                          END IF; -- for the missing txn to txn conv rate only.
                                    	END IF; -- webadi context
                                        GOTO END_RES_RATE;
                ELSE
                    -- derive the rates and amounts
                                        If rate_rec.fp_budget_version_type in ('ALL','COST') Then
                                            l_txn_currency_code          := l_txn_currency_code_override;
                        x_cost_txn_curr_code         := l_txn_currency_code_override;
                                                If (nvl(x_raw_cost,0) <> 0) Then
                                                        x_raw_cost := l_Final_txn_raw_cost;
                                                        IF nvl(l_txn_plan_quantity,0) <> 0 THEN
                                                            x_cost_rate := x_raw_cost/l_txn_plan_quantity;
                                                            If l_rw_cost_rate_override is NOT NULL Then
                                                                l_rw_cost_rate_override := x_raw_cost/l_txn_plan_quantity;
                                                            End If;
                                                        Else
                                                            x_cost_rate := null;
                                                            l_rw_cost_rate_override := null;
                                                        End If;
                                                End If;
                                        End If;
                                END IF;
                           ELSE
				IF rate_rec.fp_budget_version_type in ('ALL','COST') THEN
				l_txn_currency_code          := l_txn_currency_code_override;
				x_cost_txn_curr_code         := l_txn_currency_code_override;
				END IF;
			    END IF;

                        End If; --}
                End If;  --}
                IF nvl(l_convert_revenue_only_flag,'N') = 'Y' Then --{
                        IF  ((l_txn_currency_code_override IS NOT NULL) AND
                 (l_txn_currency_code_override <> x_rev_txn_curr_code) AND nvl(x_raw_revenue,0) <> 0 ) THEN  --{
                                l_error_code := NULL;
                                --print_msg('Calling Convert_Final_Txn_Cur_Amts API for revenue txn_currency_code_override['||l_txn_currency_code_override||']');
                                Convert_Final_Txn_Cur_Amts(
                                p_project_id            => g_project_id
                                ,p_budget_version_id    => p_budget_version_id
                                ,p_budget_version_type  => rate_rec.fp_budget_version_type
                                ,p_rate_base_flag       => z.rate_based_flag
                                ,p_exp_org_id           => nvl(z.rate_expenditure_org_id,rate_rec.org_id)
                                ,p_task_id              => NVL(z.task_id,g_task_id)
                                ,p_ei_date              => z.start_date
                                ,p_denom_quantity       => l_txn_plan_quantity
                                ,p_denom_raw_cost       => NULL
                                ,p_denom_burden_cost    => NULL
                                ,p_denom_revenue        => x_raw_revenue
                                ,p_denom_curr_code      => x_rev_txn_curr_code
                                ,p_final_txn_curr_code  => l_txn_currency_code_override
                                ,x_final_txn_rate_type  => l_Final_txn_rate_type
                                ,x_final_txn_rate_date  => l_Final_txn_rate_date
                                ,x_final_txn_exch_rate  => l_Final_txn_exch_rate
                                ,x_final_txn_quantity   => l_Final_txn_Quantity
                                ,x_final_txn_raw_cost   => l_Final_txn_raw_cost
                                ,x_final_txn_burden_cost =>l_Final_txn_burden_cost
                                ,x_final_txn_revenue    => l_Final_txn_revenue
                                ,x_return_status        => l_return_status
                                ,x_msg_data             => l_error_code
                                ,x_stage                => l_stage
                                );
                                --print_msg('End Of Convert_Final_Txn_Cur_Amts API retSts['||l_return_status||']ErrCode['||l_error_code||']');
                                IF l_return_status <> 'S' Then
                    			x_return_status := 'E';
                                        If rate_rec.fp_budget_version_type in ('ALL','REVENUE') Then
                                          If x_revenue_rejection_code is NULL Then
                                              x_revenue_rejection_code := substr(l_error_code,1,30);
                                          End If;
                                        End If;
					/*bug 4474861: for web adi flow, collect the invalid record informations
                                        * to call an api to update the interface table with the web adi error code
                                        */
                                        IF l_webAdi_calling_context = 'WEBADI_CALCULATE' THEN
                                          IF l_error_code = 'PA_FP_PROJ_NO_TXNCONVRATE' THEN
                                            -- populating the error tables.
                                            -- calling pa_fp_webadi_pkg.process_errors
                                            --print_msg('ConvErr:Web ADI context collecting errors');
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.EXTEND(1);
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                              (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).error_code :=
                                                        'PA_FP_WA_TXN_CURR_NO_CONV_RATE';
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                                (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).task_id := z.task_id;
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                                (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).rlm_id :=
                                                z.resource_list_member_id;
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                                (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).txn_currency :=
                                                l_txn_currency_code;
                                          END IF; -- for the missing txn to txn conv rate only.
                                        END IF; -- webadi context
                                        GOTO END_RES_RATE;
                                ELSE
                                        -- derive the rates and amounts
                    l_txn_currency_code          := l_txn_currency_code_override;
                                        x_rev_txn_curr_code          := l_txn_currency_code_override;
                                        If rate_rec.fp_budget_version_type in ('ALL','REVENUE') Then
                                          If (nvl(x_raw_revenue,0) <> 0 ) Then
                                              x_raw_revenue := l_Final_txn_revenue;
                                              IF nvl(l_txn_plan_quantity,0) <> 0 THEN
                                                 x_bill_rate := x_raw_revenue / l_txn_plan_quantity;
                                                 If l_bill_rate_override is NOT NULL Then
                                                    l_bill_rate_override := x_raw_revenue / l_txn_plan_quantity;
                                                 End If;
                                              Else
                                                 x_bill_rate := NULL;
                                                 l_bill_rate_override := NULL;
                                              End If;
                                          End If;
                                        End If;
                                End If;

                        End If;  --}
                End If; --}
                IF nvl(l_ra_txn_currency_api_call,'N') = 'Y' Then --{

            --Note: Ehancements: If Cost and Revenue currencies are different, then both will be
            --converted to one currency on the following logic:
            --For approved revenue budget convert both cost and revenue to project functional currency
            --Else convert revenue to Cost currency

            IF g_bv_approved_rev_flag  = 'Y' THEN
                --Convert Cost to Projfunc Currency
                If (x_cost_txn_curr_code <> rate_rec.projfunc_currency_code AND
                 (nvl(x_raw_cost,0) <> 0 OR nvl(x_burden_cost,0) <> 0 )) Then --{

                    l_error_code := NULL;
                --print_msg('Calling Convert_Final_Txn_Cur_Amts API for Cost amts');
                Convert_Final_Txn_Cur_Amts(
                        p_project_id            => g_project_id
                        ,p_budget_version_id    => p_budget_version_id
                        ,p_budget_version_type  => rate_rec.fp_budget_version_type
                        ,p_rate_base_flag       => z.rate_based_flag
                        ,p_exp_org_id           => nvl(z.rate_expenditure_org_id,rate_rec.org_id)
                        ,p_task_id              => NVL(z.task_id,g_task_id)
                        ,p_ei_date              => z.start_date
                        ,p_denom_quantity       => l_txn_plan_quantity
                        ,p_denom_raw_cost       => x_raw_cost
                ,p_denom_burden_cost    => x_burden_cost
                ,p_denom_revenue        => NULL
                        ,p_denom_curr_code      => x_cost_txn_curr_code
                        ,p_final_txn_curr_code  => rate_rec.projfunc_currency_code
                        ,x_final_txn_rate_type  => l_Final_txn_rate_type
                        ,x_final_txn_rate_date  => l_Final_txn_rate_date
                        ,x_final_txn_exch_rate  => l_Final_txn_exch_rate
                        ,x_final_txn_quantity   => l_Final_txn_Quantity
                        ,x_final_txn_raw_cost   => l_Final_txn_raw_cost
                        ,x_final_txn_burden_cost =>l_Final_txn_burden_cost
                        ,x_final_txn_revenue    => l_Final_txn_revenue
                        ,x_return_status        => l_return_status
                        ,x_msg_data             => l_error_code
                        ,x_stage                => l_stage
                        );
                --print_msg('End Of Convert_Final_Txn_Cur_Amts API retSts['||l_return_status||']ErrCode['||l_error_code||']');
                IF l_return_status <> 'S' Then
                    If rate_rec.fp_budget_version_type in ('ALL','COST') Then
                      If x_raw_cost_rejection_code is NULL Then
                          x_raw_cost_rejection_code := substr(l_error_code,1,30);
                      End If;
                      If x_burden_cost_rejection_code is NULL Then
                                              x_burden_cost_rejection_code := substr(l_error_code,1,30);
                      End If;
                    End If;
			/*bug 4474861: for web adi flow, collect the invalid record informations
                                        * to call an api to update the interface table with the web adi error code
                                        */
                                        IF l_webAdi_calling_context = 'WEBADI_CALCULATE' THEN
                                          IF l_error_code = 'PA_FP_PROJ_NO_TXNCONVRATE' THEN
                                            -- populating the error tables.
                                            -- calling pa_fp_webadi_pkg.process_errors
                                            --print_msg('ConvErr:Web ADI context collecting errors');
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.EXTEND(1);
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                              (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).error_code :=
                                                        'PA_FP_WA_TXN_CURR_NO_CONV_RATE';
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                                (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).task_id := z.task_id;
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                                (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).rlm_id :=
                                                z.resource_list_member_id;
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                                (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).txn_currency :=
                                                l_txn_currency_code;
                                          END IF; -- for the missing txn to txn conv rate only.
                                        END IF; -- webadi context
                    		GOTO END_RES_RATE;
                ELSE
                    -- derive the rates and amounts
                    If rate_rec.fp_budget_version_type in ('ALL','COST') Then
                        l_txn_currency_code := rate_rec.projfunc_currency_code ;
                        If (nvl(x_raw_cost,0) <> 0) Then
                            x_raw_cost := l_Final_txn_raw_cost;
                            IF nvl(l_txn_plan_quantity,0) <> 0 THEN
                                x_cost_rate := x_raw_cost/l_txn_plan_quantity;
                                If l_rw_cost_rate_override is NOT NULL Then
                                l_rw_cost_rate_override := x_raw_cost/l_txn_plan_quantity;
                                End If;
                            Else
                                x_cost_rate := null;
                                l_rw_cost_rate_override := null;
                            End If;
                        End If;
                        If (nvl(x_burden_cost,0) <> 0)  Then
                            x_burden_cost := l_Final_txn_burden_cost;
                            IF nvl(l_txn_plan_quantity,0) <> 0 THEN
                                x_burden_cost_rate := x_burden_cost/l_txn_plan_quantity;
                                If l_burden_cost_rate_override is NOT NULL Then
                                l_burden_cost_rate_override := x_burden_cost/l_txn_plan_quantity;
                                End If;
                            Else
                                x_burden_cost_rate := NULL;
                                l_burden_cost_rate_override := NULL;
                            End If;
                        End If;
                    End If;
                End If;
            End If;  --}
           End If;  -- end of approved revenue budget
          END IF;  --}

          IF nvl(l_ra_txn_currency_api_call,'N') = 'Y' AND
            (g_bv_approved_rev_flag  = 'Y' OR (x_rev_txn_curr_code <> x_cost_txn_curr_code)) Then  --{

           --set Revenue to ProjFunc currency or Cost currency
            If g_bv_approved_rev_flag = 'Y' Then
            l_rev_to_cost_conv_cur := rate_rec.projfunc_currency_code;
            Else
            l_rev_to_cost_conv_cur := x_cost_txn_curr_code;
            End If;
            --Convert Revenue to ProjFunc currency
            If (x_rev_txn_curr_code <> l_rev_to_cost_conv_cur AND nvl(x_raw_revenue,0) <> 0 )  Then
                                l_error_code := NULL;
                                --print_msg('Calling Convert_Final_Txn_Cur_Amts API for l_rev_to_cost_conv_cur['||l_rev_to_cost_conv_cur||']');
                                Convert_Final_Txn_Cur_Amts(
                                p_project_id            => g_project_id
                                ,p_budget_version_id    => p_budget_version_id
                                ,p_budget_version_type  => rate_rec.fp_budget_version_type
                                ,p_rate_base_flag       => z.rate_based_flag
                                ,p_exp_org_id           => nvl(z.rate_expenditure_org_id,rate_rec.org_id)
                                ,p_task_id              => NVL(z.task_id,g_task_id)
                                ,p_ei_date              => z.start_date
                                ,p_denom_quantity       => l_txn_plan_quantity
                                ,p_denom_raw_cost       => NULL
                                ,p_denom_burden_cost    => NULL
                                ,p_denom_revenue        => x_raw_revenue
                                ,p_denom_curr_code      => x_rev_txn_curr_code
                                ,p_final_txn_curr_code  => l_rev_to_cost_conv_cur
                                ,x_final_txn_rate_type  => l_Final_txn_rate_type
                                ,x_final_txn_rate_date  => l_Final_txn_rate_date
                                ,x_final_txn_exch_rate  => l_Final_txn_exch_rate
                                ,x_final_txn_quantity   => l_Final_txn_Quantity
                                ,x_final_txn_raw_cost   => l_Final_txn_raw_cost
                                ,x_final_txn_burden_cost =>l_Final_txn_burden_cost
                                ,x_final_txn_revenue    => l_Final_txn_revenue
                                ,x_return_status        => l_return_status
                                ,x_msg_data             => l_error_code
                                ,x_stage                => l_stage
                                );
                                --print_msg('End Of Convert_Final_Txn_Cur_Amts API retSts['||l_return_status||']ErrCode['||l_error_code||']');
                                IF l_return_status <> 'S' Then
                        		If rate_rec.fp_budget_version_type in ('ALL','REVENUE') Then
                                          If x_revenue_rejection_code is NULL Then
                                              x_revenue_rejection_code := substr(l_error_code,1,30);
                                          End If;
                                        End If;
					/*bug 4474861: for web adi flow, collect the invalid record informations
                                        * to call an api to update the interface table with the web adi error code
                                        */
                                        IF l_webAdi_calling_context = 'WEBADI_CALCULATE' THEN
                                          IF l_error_code = 'PA_FP_PROJ_NO_TXNCONVRATE' THEN
                                            -- populating the error tables.
                                            -- calling pa_fp_webadi_pkg.process_errors
                                            --print_msg('ConvErr:Web ADI context collecting errors');
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.EXTEND(1);
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                              (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).error_code :=
                                                        'PA_FP_WA_TXN_CURR_NO_CONV_RATE';
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                                (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).task_id := z.task_id;
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                                (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).rlm_id :=
                                                z.resource_list_member_id;
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                                (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).txn_currency :=
                                                l_txn_currency_code;
                                          END IF; -- for the missing txn to txn conv rate only.
                                        END IF; -- webadi context
                    			GOTO END_RES_RATE;
                                ELSE
                                        -- derive the rates and amounts
                    l_txn_currency_code := l_rev_to_cost_conv_cur;
                                        If rate_rec.fp_budget_version_type in ('ALL','REVENUE') Then
                                          If (nvl(x_raw_revenue,0) <> 0 ) Then
                                              x_raw_revenue := l_Final_txn_revenue;
                          IF nvl(l_txn_plan_quantity,0) <> 0 THEN
                                                 x_bill_rate := x_raw_revenue / l_txn_plan_quantity;
                                                 If l_bill_rate_override is NOT NULL Then
                                                    l_bill_rate_override := x_raw_revenue / l_txn_plan_quantity;
                                                 End If;
                          Else
                         x_bill_rate := NULL;
                         l_bill_rate_override := NULL;
                          End If;
                                          End If;
                                        End If;
                                End If;
             END IF;
        END IF;  --} end of l_ra_txn_currency_api_call
                /* If the budget version is of revenue and related to change order/change request the
                * then transaction currency should be converted into agrment currency
                */
                IF g_ra_bl_txn_currency_code is NULL Then
                   If (g_agr_conv_reqd_flag = 'Y' ) Then
                        --print_msg('Setting the g_ra_bl_txn_currency_code to AgreementCur');
                        g_ra_bl_txn_currency_code := g_agr_currency_code;
                   Elsif ( g_wp_version_flag = 'Y'
                        AND  g_agr_conv_reqd_flag = 'N'
                        AND rate_rec.plan_in_multi_curr_flag = 'N' ) Then
                        --print_msg('Setting the g_ra_bl_txn_currency_code to project currency for Multi-Cur disabled project');
                        g_ra_bl_txn_currency_code := rate_rec.project_currency_code;
                   End If;
                End If;

            l_stage := 824;
            --print_msg(to_char(l_stage)||'l_txn_currency_code ['||l_txn_currency_code||'GlobalCur['||g_ra_bl_txn_currency_code||']');
            /* For work plan versions we have to ensure that there is only one transaction currency possible for
            the entire duration of the task assignment. If the rate API returns a different currency than the one
            existing in budget_lines then the rate api returned currency has to be transformed into the budget_line currency
            and the rate api amounts and rates will have to be convereted accordingly.
        */
        IF (( g_wp_version_flag = 'Y' OR  g_agr_conv_reqd_flag = 'Y')
                   /* Bug fix::4396300 */
                    OR (p_calling_module in ('BUDGET_GENERATION','FORECAST_GENERATION')
                    AND caltmp.G_WPRABL_CURRENCY_CODE is NOT NULL ))
                   /* Bug fix:4396300 */
                THEN  --{
               IF (g_ra_bl_txn_currency_code IS NOT NULL AND (g_ra_bl_txn_currency_code <> l_txn_currency_code)) THEN --{
            IF (NVL(x_raw_cost,0) <> 0 OR NVL(x_burden_cost,0) <> 0 OR NVL(x_raw_revenue,0) <> 0 ) THEN   --{
                    l_stage := 826;
		    /*
                    print_msg(to_char(l_stage)||'Converting x_raw_cost to existing transaction currency');
                    print_msg('x_raw_cost => ' || to_char(x_raw_cost));
                    print_msg('From l_txn_currency_code => ' || l_txn_currency_code);
                    print_msg('To g_ra_bl_txn_currency_code => ' || g_ra_bl_txn_currency_code);
		    */
                l_stage := null;
                    l_error_code := NULL;
                --print_msg('Calling Convert_Final_Txn_Cur_Amts API');
                Convert_Final_Txn_Cur_Amts(
                        p_project_id            => g_project_id
                        ,p_budget_version_id    => p_budget_version_id
                        ,p_budget_version_type  => rate_rec.fp_budget_version_type
                        ,p_rate_base_flag       => z.rate_based_flag
                        ,p_exp_org_id           => nvl(z.rate_expenditure_org_id,rate_rec.org_id)
                        ,p_task_id              => NVL(z.task_id,g_task_id)
                        ,p_ei_date              => z.start_date
                        ,p_denom_quantity       => l_txn_plan_quantity
                        ,p_denom_raw_cost       => x_raw_cost
                ,p_denom_burden_cost    => x_burden_cost
                ,p_denom_revenue        => x_raw_revenue
                        ,p_denom_curr_code      => l_txn_currency_code
                        ,p_final_txn_curr_code  => g_ra_bl_txn_currency_code
                        ,x_final_txn_rate_type  => l_Final_txn_rate_type
                        ,x_final_txn_rate_date  => l_Final_txn_rate_date
                        ,x_final_txn_exch_rate  => l_Final_txn_exch_rate
                        ,x_final_txn_quantity   => l_Final_txn_Quantity
                        ,x_final_txn_raw_cost   => l_Final_txn_raw_cost
                        ,x_final_txn_burden_cost =>l_Final_txn_burden_cost
                        ,x_final_txn_revenue    => l_Final_txn_revenue
                        ,x_return_status        => l_return_status
                        ,x_msg_data             => l_error_code
                        ,x_stage                => l_stage
                        );
                --print_msg('End Of Convert_Final_Txn_Cur_Amts API retSts['||l_return_status||']ErrCode['||l_error_code||']');
                IF l_return_status <> 'S' Then
                    x_return_status := 'E';
                    If rate_rec.fp_budget_version_type in ('ALL','COST') Then
                      If x_raw_cost_rejection_code is NULL Then
                          x_raw_cost_rejection_code := substr(l_error_code,1,30);
                      End If;
                      If x_burden_cost_rejection_code is NULL Then
                                              x_burden_cost_rejection_code := substr(l_error_code,1,30);
                      End If;
                    End If;
                    If rate_rec.fp_budget_version_type in ('ALL','REVENUE') Then
                      If x_revenue_rejection_code is NULL Then
                                              x_revenue_rejection_code := substr(l_error_code,1,30);
                      End If;
                    End If;
				/*bug 4474861: for web adi flow, collect the invalid record informations
                                        * to call an api to update the interface table with the web adi error code
                                        */
                                        IF l_webAdi_calling_context = 'WEBADI_CALCULATE' THEN
                                          IF l_error_code = 'PA_FP_PROJ_NO_TXNCONVRATE' THEN
                                            -- populating the error tables.
                                            -- calling pa_fp_webadi_pkg.process_errors
                                            --print_msg('ConvErr:Web ADI context collecting errors');
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.EXTEND(1);
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                              (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).error_code :=
                                                        'PA_FP_WA_TXN_CURR_NO_CONV_RATE';
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                                (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).task_id := z.task_id;
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                                (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).rlm_id :=
                                                z.resource_list_member_id;
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                                (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).txn_currency :=
                                                l_txn_currency_code;
                                          END IF; -- for the missing txn to txn conv rate only.
                                        END IF; -- webadi context
                    	GOTO END_RES_RATE;
                ELSE
                    --derive the rates and amounts
                    l_txn_currency_code          := g_ra_bl_txn_currency_code;
                    If rate_rec.fp_budget_version_type in ('ALL','COST') Then
                        If (nvl(x_raw_cost,0) <> 0) Then
                            x_raw_cost := l_Final_txn_raw_cost;
                            IF nvl(l_txn_plan_quantity,0) <> 0 THEN
                                x_cost_rate := x_raw_cost/l_txn_plan_quantity;
                                If l_rw_cost_rate_override is NOT NULL Then
                                l_rw_cost_rate_override := x_raw_cost/l_txn_plan_quantity;
                                End If;
                             Else
                                x_cost_rate := NULL;
                                l_rw_cost_rate_override := NULL;
                             End If;
                        End If;
                        If (nvl(x_burden_cost,0) <> 0)  Then
                            x_burden_cost := l_Final_txn_burden_cost;
                            IF nvl(l_txn_plan_quantity,0) <> 0 THEN
                                x_burden_cost_rate := x_burden_cost/l_txn_plan_quantity;
                                If l_burden_cost_rate_override is NOT NULL Then
                                l_burden_cost_rate_override := x_burden_cost/l_txn_plan_quantity;
                                End If;
                             Else
                                 x_burden_cost_rate := NULL;
                                 l_burden_cost_rate_override := NULL;
                             End If;
                        End If;
                    End If;
                    If rate_rec.fp_budget_version_type in ('ALL','REVENUE') Then
                        If (nvl(x_raw_revenue,0) <> 0 ) Then
                            x_raw_revenue := l_Final_txn_revenue;
                            If nvl(l_txn_plan_quantity,0) <> 0 THEN
                                x_bill_rate := x_raw_revenue / l_txn_plan_quantity;
                                If l_bill_rate_override is NOT NULL Then
                                l_bill_rate_override := x_raw_revenue / l_txn_plan_quantity;
                                End If;
                            Else
                                x_bill_rate := NULL;
                                l_bill_rate_override := NULL;
                            End If;
                        End If;
                    End If;
                END IF;
                END IF;  --}
                END IF;  --} end of g_ra_bl_txn_currency_code IS NOT NULL
            END IF; --}  end of g_wp_version_flag = 'Y' OR  g_agr_conv_reqd_flag = 'Y'
        END IF; --} end of track workplan flag = 'N'
        <<END_RES_RATE>>
            --print_msg('AFter calling get planning rate api');
                /* For workplan context, Always retain one currency per resource */
                IF  ( g_wp_version_flag = 'Y' AND g_ra_bl_txn_currency_code IS NULL and g_agr_conv_reqd_flag = 'N' ) THEN
                        /* set the global currency if its null after calling the rate api */
                        g_ra_bl_txn_currency_code := l_txn_currency_code;
                        --print_msg(' g_ra_bl_txn_currency_code set to RateAPIl_txn_currency_code['||g_ra_bl_txn_currency_code||']');
                END IF;
        IF ( g_wp_version_flag = 'Y' OR g_agr_conv_reqd_flag = 'Y'
                   /* Bug fix::4396300 */
                    OR (p_calling_module in ('BUDGET_GENERATION','FORECAST_GENERATION')
                    AND caltmp.G_WPRABL_CURRENCY_CODE is NOT NULL )) THEN
                   /* Bug fix:4396300 */
                        IF  (g_ra_bl_txn_currency_code IS NOT NULL AND
                                g_ra_bl_txn_currency_code <> l_txn_currency_code) Then
                                l_txn_currency_code := g_ra_bl_txn_currency_code;
                        End If;
                End If;

        /* Start of rounding enhancements: derive final txn currency*/
        IF rate_rec.track_workplan_costs_flag = 'Y' Then --{
           If ((nvl(x_raw_cost,0) <> 0 OR nvl(x_burden_cost,0) <> 0 OR nvl(x_raw_revenue,0) <> 0 ) AND
                      (nvl(x_raw_cost_rejection_code,'XX') NOT IN ('PA_FP_PROJ_NO_TXNCONVRATE')
               and nvl(x_burden_cost_rejection_code,'XX') NOT IN ('PA_FP_PROJ_NO_TXNCONVRATE')
               and nvl(x_revenue_rejection_code,'XX') NOT IN ('PA_FP_PROJ_NO_TXNCONVRATE'))) Then  --{
            --print_msg('Converting txn amounts to final txn currency code From['||l_txn_currency_code||']To['||l_Final_Txn_Currency_code||']');
            IF l_txn_currency_code IS NOT NULL AND l_Final_Txn_Currency_code IS NOT NULL Then --{
              IF (l_txn_currency_code <> l_Final_Txn_Currency_code) Then  --{
                    l_error_code := NULL;
                --print_msg('Calling Convert_Final_Txn_Cur_Amts API');
                Convert_Final_Txn_Cur_Amts(
                        p_project_id            => g_project_id
                        ,p_budget_version_id    => p_budget_version_id
                        ,p_budget_version_type  => rate_rec.fp_budget_version_type
                        ,p_rate_base_flag       => z.rate_based_flag
                        ,p_exp_org_id           => nvl(z.rate_expenditure_org_id,rate_rec.org_id)
                        ,p_task_id              => NVL(z.task_id,g_task_id)
                        ,p_ei_date              => z.start_date
                        ,p_denom_quantity       => l_txn_plan_quantity
                        ,p_denom_raw_cost       => x_raw_cost
                ,p_denom_burden_cost    => x_burden_cost
                ,p_denom_revenue        => x_raw_revenue
                        ,p_denom_curr_code      => l_txn_currency_code
                        ,p_final_txn_curr_code  => l_Final_Txn_Currency_code
                        ,x_final_txn_rate_type  => l_Final_txn_rate_type
                        ,x_final_txn_rate_date  => l_Final_txn_rate_date
                        ,x_final_txn_exch_rate  => l_Final_txn_exch_rate
                        ,x_final_txn_quantity   => l_Final_txn_Quantity
                        ,x_final_txn_raw_cost   => l_Final_txn_raw_cost
                        ,x_final_txn_burden_cost =>l_Final_txn_burden_cost
                        ,x_final_txn_revenue    => l_Final_txn_revenue
                        ,x_return_status        => l_return_status
                        ,x_msg_data             => l_error_code
                        ,x_stage                => l_stage
                        );
                --print_msg('End Of Convert_Final_Txn_Cur_Amts API retSts['||l_return_status||']ErrCode['||l_error_code||']');
                IF l_return_status <> 'S' Then
                    If rate_rec.fp_budget_version_type in ('ALL','COST') Then
                      If x_raw_cost_rejection_code is NULL Then
                          x_raw_cost_rejection_code := substr(l_error_code,1,30);
                      End If;
                      If x_burden_cost_rejection_code is NULL Then
                                              x_burden_cost_rejection_code := substr(l_error_code,1,30);
                      End If;
                    End If;
                    If rate_rec.fp_budget_version_type in ('ALL','REVENUE') Then
                      If x_revenue_rejection_code is NULL Then
                                              x_revenue_rejection_code := substr(l_error_code,1,30);
                      End If;
                    End If;
			/*bug 4474861: for web adi flow, collect the invalid record informations
                                        * to call an api to update the interface table with the web adi error code
                                        */
                                        IF l_webAdi_calling_context = 'WEBADI_CALCULATE' THEN
                                          IF l_error_code = 'PA_FP_PROJ_NO_TXNCONVRATE' THEN
                                            -- populating the error tables.
                                            -- calling pa_fp_webadi_pkg.process_errors
                                            --print_msg('ConvErr:Web ADI context collecting errors');
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.EXTEND(1);
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                              (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).error_code :=
                                                        'PA_FP_WA_TXN_CURR_NO_CONV_RATE';
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                                (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).task_id := z.task_id;
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                                (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).rlm_id :=
                                                z.resource_list_member_id;
                                            PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl
                                                (PA_FP_WEBADI_PKG.g_fp_webadi_rec_tbl.COUNT).txn_currency :=
                                                l_txn_currency_code;
                                          END IF; -- for the missing txn to txn conv rate only.
                                        END IF; -- webadi context
				GOTO END_RES_RATE;
                ELSE


                                /* set the global currency to final txn currency code */
                                IF  ( g_wp_version_flag = 'Y' AND g_ra_bl_txn_currency_code IS NOT NULL
                        and g_agr_conv_reqd_flag = 'N' AND l_Final_Txn_currency_code is NOT NULL ) THEN
                        If g_ra_bl_txn_currency_code <> l_Final_Txn_currency_code Then
                                        g_ra_bl_txn_currency_code := NVL(l_Final_Txn_currency_code,l_txn_currency_code);
                                        --print_msg(' g_ra_bl_txn_currency_code set to finalTxnCur['||l_Final_Txn_currency_code||']');
                        End If;
                            END IF;
                    /* derive the rates and amounts */
                    If rate_rec.fp_budget_version_type in ('ALL','COST') Then
                        If (nvl(x_raw_cost,0) <> 0) Then
                            x_raw_cost := l_Final_txn_raw_cost;
                            IF nvl(l_txn_plan_quantity,0) <> 0 THEN
                                x_cost_rate := x_raw_cost/l_txn_plan_quantity;
                                If l_rw_cost_rate_override is NOT NULL Then
                                l_rw_cost_rate_override := x_raw_cost/l_txn_plan_quantity;
                                End If;
                             Else
                                x_cost_rate := NULL;
                                l_rw_cost_rate_override := NULL;
                             End If;
                        End If;
                        If (nvl(x_burden_cost,0) <> 0)  Then
                            x_burden_cost := l_Final_txn_burden_cost;
                            IF nvl(l_txn_plan_quantity,0) <> 0 THEN
                                x_burden_cost_rate := x_burden_cost/l_txn_plan_quantity;
                                If l_burden_cost_rate_override is NOT NULL Then
                                l_burden_cost_rate_override := x_burden_cost/l_txn_plan_quantity;
                                End If;
                             Else
                                 x_burden_cost_rate := NULL;
                                 l_burden_cost_rate_override := NULL;
                             End If;
                        End If;
                    End If;
                    If rate_rec.fp_budget_version_type in ('ALL','REVENUE') Then
                        If (nvl(x_raw_revenue,0) <> 0 ) Then
                            x_raw_revenue := l_Final_txn_revenue;
                            If nvl(l_txn_plan_quantity,0) <> 0 THEN
                                x_bill_rate := x_raw_revenue / l_txn_plan_quantity;
                                If l_bill_rate_override is NOT NULL Then
                                l_bill_rate_override := x_raw_revenue / l_txn_plan_quantity;
                                End If;
                            Else
                                x_bill_rate := NULL;
                                l_bill_rate_override := NULL;
                            End If;
                        End If;
                    End If;
                END IF;
               End If;  --}  -- end of txn currency <> final txn currency
            END IF;  --}
            --print_msg('End of Convert amts to final txn currency');
           END IF;  --}
                   IF z.rate_based_flag = 'N' Then
                        /* For non-rate base resource copy the converted amt to quantity*/
                        If (rate_rec.fp_budget_version_type in ('ALL','COST') ) Then
                               If (nvl(x_raw_cost,0) <> 0 AND (nvl(x_raw_cost,0) <> nvl(l_txn_plan_quantity,0)) ) Then
                                    l_txn_plan_quantity := x_raw_cost;
                                    l_rw_cost_rate_override := 1;
                   Elsif (nvl(x_raw_cost,0) <> 0 AND (nvl(x_raw_cost,0) = nvl(l_txn_plan_quantity,0)) ) Then
                    l_rw_cost_rate_override := 1;
                               End If;
                   /* Rederiving the rate here overrwrite the rate api derived values
                   IF (nvl(l_txn_plan_quantity,0) <> 0 and nvl(x_burden_cost,0) <> 0) Then
                                    x_burden_cost_rate := x_burden_cost/l_txn_plan_quantity;
                                    If l_burden_cost_rate_override is NOT NULL Then
                                       l_burden_cost_rate_override := x_burden_cost/l_txn_plan_quantity;
                                    End If;
                   End If;
                   */
                        End If;
                        /* for non-rate base resource of revenue only version copy the converted amt to qty */
                        If (rate_rec.fp_budget_version_type = 'REVENUE') Then
                               If ( nvl(x_raw_revenue,0) <> 0 AND nvl(x_raw_revenue,0) <> nvl(l_txn_plan_quantity,0) ) Then
                                    l_txn_plan_quantity := x_raw_revenue;
                                    l_bill_rate_override := 1;
                   Elsif ( nvl(x_raw_revenue,0) <> 0 AND nvl(x_raw_revenue,0) = nvl(l_txn_plan_quantity,0) ) Then
                    l_bill_rate_override := 1;
                               End If;
                        End If;
                   End If;
                End If;  --}
        /* End of rounding enhancements: derive final txn currency*/

            --print_msg('AFter rounding enhancements: derive final txn currency API');
        /* Bug fix: 3808295: overrides will be populated once the progress is applied
                 * on refresh, all the rate and overrides will be wiped out so we need to
         * re derive the rate where actuals exists on the budget line
                 */
        /***Spread enhancements periodic override rates must be retained **
        If rate_rec.fp_budget_version_type in ('COST','ALL') Then
          IF x_raw_cost_rejection_code is NULL Then
            If (nvl(z.txn_init_raw_cost,0) <> 0 AND nvl(l_txn_plan_quantity,0) <> 0) Then
            If l_rw_cost_rate_override is NULL Then
                  --print_msg('Rederive Cost rate override since actuals exists');
                  l_rw_cost_rate_override := x_raw_cost /l_txn_plan_quantity;
            End If;
            End If;
          End If;

          If x_burden_cost_rejection_code is NULL Then
           If (nvl(z.txn_init_burdened_cost,0) <> 0 AND nvl(l_txn_plan_quantity,0) <> 0) Then
            If l_burden_cost_rate_override is NULL Then
               --print_msg('Rederive Burden rate override since actuals exists');
               l_burden_cost_rate_override := x_burden_cost / l_txn_plan_quantity;
            End If;
           End If;
          End If;
        End If;
        If rate_rec.fp_budget_version_type in ('REVENUE','ALL') Then
                  If x_revenue_rejection_code is NULL Then
                    If (nvl(z.txn_init_revenue,0) <> 0 ANd nvl(l_txn_plan_quantity,0) <> 0) Then
                        If l_bill_rate_override is NULL Then
                           --print_msg('Rederive Bill rate override since actuals exists');
                           l_bill_rate_override := x_raw_revenue/l_txn_plan_quantity;
                        End If;
                    End If;
                  End If;
        End If;
                 ** added for the bug fix: 3846474, when progress is applied, we derive override rate to retain the
                 *  qty, amounts to spread forwards. but after spread and retainig the currency,qty,amounts. we should null out the
                 *  override rates where override rates were not exists previously
                 **
                IF NVL(p_apply_progress_flag,'N') = 'Y' Then
                        IF nvl(p_precedence_progress_flag,'N') = 'N' THEN
                              IF z.rate_based_flag = 'N' Then
                                  l_rw_cost_rate_override := 1;
                              Else
                                l_rw_cost_rate_override := null;
                              End If;
                              l_burden_cost_rate_override := null;
                              --print_msg('setting override rates to NULL for the resources where actuals not present in apply progress mode');
                        End If;
                END IF;
        *****Periodic override rates must be retained donot rederive the rates *****/

        If rate_rec.fp_budget_version_type in ('COST','ALL') Then
          -- set the rates to null if both qty and costs are null
          If l_txn_plan_quantity is NULL and x_raw_cost is NULL Then
           If nvl(z.init_quantity,0) <> 0 and NVL(z.txn_init_raw_cost,0) <> 0 Then
                l_rw_cost_rate_override := z.rw_cost_rate_override;
           Elsif z.rw_cost_rate_override = 0 Then
                l_rw_cost_rate_override := 0;
           Else
                l_rw_cost_rate_override := null;
                x_cost_rate := null;
           End If;
          End If;
          If l_txn_plan_quantity is NULL and x_burden_cost is NULL Then
           If nvl(z.init_quantity,0) <> 0 and NVL(z.txn_init_burdened_cost,0) <> 0 Then
                l_burden_cost_rate_override := z.burden_cost_rate_override;
           Elsif z.burden_cost_rate_override = 0 Then
                l_burden_cost_rate_override := 0;
           Else
                l_burden_cost_rate_override := null;
                x_burden_cost_rate := null;
           End If;
          End If;
        End If;
        If rate_rec.fp_budget_version_type in ('REVENUE','ALL') Then
          -- set the rates to null if both qty and revenue are null
          If x_raw_revenue is NULL and l_txn_plan_quantity is NULL Then
            if nvl(z.init_quantity,0) <> 0 and NVL(z.txn_init_revenue,0) <> 0 then
                l_bill_rate_override := z.bill_rate_override;
            Elsif z.bill_rate_override = 0 Then
                l_bill_rate_override := 0;
            Else
                l_bill_rate_override := null;
                x_bill_rate := null;
            End If;
          End If;
        End If;

        --print_msg('AFter calling get planning rate api');
                /* before updating the rollup tmp add the actuals to etc values to make it plan */
                l_txn_plan_quantity := NVL(l_txn_plan_quantity,0) + nvl(z.init_quantity,0);
        If l_txn_plan_quantity = 0 and nvl(z.init_quantity,0) = 0 Then
            l_txn_plan_quantity := NULL;
        End If;
                x_raw_cost := NVL(x_raw_cost,0) + nvl(z.txn_init_raw_cost,0);
        If x_raw_cost = 0 and nvl(z.txn_init_raw_cost,0) = 0 Then
            x_raw_cost := NULL;
        End If;
                x_burden_cost := NVL(x_burden_cost,0) + nvl(z.txn_init_burdened_cost,0);
        If x_burden_cost = 0 and nvl(z.txn_init_burdened_cost,0) = 0 Then
            x_burden_cost := NULL;
        End If;
                x_raw_revenue := NVL(x_raw_revenue,0) + nvl(z.txn_init_revenue,0);
        If x_raw_revenue = 0 and nvl(z.txn_init_revenue,0) = 0 Then
            x_raw_revenue := NULL;
        End If;

                IF rate_rec.track_workplan_costs_flag = 'N' THEN  --{
                        --print_msg(' Finally check - track_workplan_costs_flag = N set all cost and rates to null');
                        --set all the override rates and costs to null
                                x_bill_rate                     := null;
                                l_bill_rate_override            := null;
                                x_cost_rate                     := null;
                                l_rw_cost_rate_override         := null;
                                x_burden_cost_rate              := null;
                                l_burden_cost_rate_override     := null;
                                x_raw_cost                      := null;
                                x_burden_cost                   := null;
                                x_raw_revenue                   := null;
                                x_bill_markup_percentage        := null;
                                x_raw_cost_rejection_code       := null;
                                x_burden_cost_rejection_code    := null;
                                x_revenue_rejection_code        := null;
                                x_projfunc_rejection_code       := null;
                                x_project_rejection_code        := null;
                                x_cost_ind_compiled_set_id      := null;
        Else
                      /* Rounding Enhancements: Null out costs and Rates if plan quantity is zero */
		      /* bug fix:5726773
                      If NVL(l_txn_plan_quantity,0) = 0 Then
                        x_raw_cost              := NULL;
                        x_burden_cost           := NULL;
                        x_raw_revenue           := NULL;
                        x_cost_rate             := NULL;
                        l_rw_cost_rate_override := NULL;
                        x_burden_cost_rate      := NULL;
                        l_burden_cost_rate_override := NULL;
                        x_bill_rate             := NULL;
                        l_bill_rate_override    := NULL;
                      End If;
		      end of bug fix:5726773**/
              IF rate_rec.fp_budget_version_type = 'ALL'  THEN
                /*Bug fix: 3765835 Revenue Generation method : C - Cost, E - Event Based */
                IF p_calling_module IN ('BUDGET_GENERATION','FORECAST_GENERATION')
                   --Bug 6722414 When called from ETC client extension, Dont null out revenue amounts.
                AND  NVL(g_from_etc_client_extn_flag,'N')='N' THEN
                       IF NVL(l_revenue_generation_method,'W') in ('C','E') Then
                        -- set all the revenue params to NULL
                        x_bill_rate                            := NULL;
                        x_raw_revenue                          := NULL;
                        x_bill_markup_percentage               := NULL;
                        x_rev_txn_curr_code                    := NULL;
                        x_revenue_rejection_code               := NULL;
                       End If;
                END IF;
                  END IF;

                  IF NVL(x_raw_cost,0) <> 0 Then
                            x_raw_cost := pa_currency.round_trans_currency_amt1(x_raw_cost,
                    NVL(l_Final_txn_currency_code,l_txn_currency_code));
                  End If;

                  IF NVL(x_burden_cost,0) <> 0 Then
                        x_burden_cost := pa_currency.round_trans_currency_amt1(x_burden_cost,
                                        NVL(l_Final_txn_currency_code,l_txn_currency_code));
                  End If;

                  If NVL(x_raw_revenue,0) <> 0 Then
                        x_raw_revenue :=  pa_currency.round_trans_currency_amt1(x_raw_revenue,
                                        NVL(l_Final_txn_currency_code,l_txn_currency_code));
                  End If;
        End If;  --}

                l_stage := 838;
		If P_PA_DEBUG_MODE = 'Y' Then
                print_msg(to_char(l_stage)||'Calling update_rollup_tmp with the following parameters:');
                print_msg(' p_budget_line_id         => '||to_char(l_budget_line_id));
        	print_msg('Qtuantity =>'||l_txn_plan_quantity||']');
                print_msg(' p_bill_rate              => '||to_char(x_bill_rate));
                print_msg(' p_bill_rate_override     => '||to_char(l_bill_rate_override));
                print_msg(' p_cost_rate              => '||to_char(x_cost_rate));
                print_msg(' p_rw_cost_rate_override  => '||to_char(l_rw_cost_rate_override));
                print_msg(' p_burden_cost_rate       => '||to_char(x_burden_cost_rate));
                print_msg(' p_burden_cost_rate_override => '||to_char(l_burden_cost_rate_override));
                print_msg(' p_raw_cost               => '||to_char(x_raw_cost));
                print_msg(' p_burden_cost            => '||to_char(x_burden_cost));
                print_msg(' p_raw_revenue            => '||to_char(x_raw_revenue));
                print_msg(' p_bill_markup_percentage => '||to_char(x_bill_markup_percentage));
                print_msg(' p_txn_curr_code          => '||l_txn_currency_code||'FinalTxnCur['||l_Final_Txn_Currency_Code||']');
                print_msg(' g_ra_bl_txn_currency_code => '||g_ra_bl_txn_currency_code);
                print_msg(' p_raw_cost_rejection_code => '||x_raw_cost_rejection_code);
                print_msg(' p_burden_cost_rejection_code=> '||x_burden_cost_rejection_code);
                print_msg(' p_revenue_rejection_code   => '||x_revenue_rejection_code);
                print_msg(' p_projfunc_rejection_code  => '||x_projfunc_rejection_code);
                print_msg(' p_project_rejection_code   => '||x_project_rejection_code);
                print_msg(' p_cost_ind_compiled_set_id => '||to_char(x_cost_ind_compiled_set_id));
		End if;

        /* recalculate markup percentage when bill rate or revenue is overriden */
        If x_raw_revenue is NOT NULL Then
           If l_bill_rate_override is NOT NULL Then
            If x_bill_markup_percentage is NULL AND l_bill_markup_percentage is NOT NULL Then
                x_bill_markup_percentage := (((x_raw_revenue - x_raw_cost )/x_raw_cost)*100)  ;
            End If;
           End If;
        End If;
        /* Now populate plsql tables for bulk update */
        l_rl_cntr := l_rl_cntr + 1;
        l_rlt_budget_line_id_tab(l_rl_cntr)            := l_budget_line_id;
                l_rlt_quantity_tab(l_rl_cntr)                  := l_txn_plan_quantity;
                l_rlt_bill_rate_tab(l_rl_cntr)                 := x_bill_rate;
                l_rlt_bill_rate_ovr_tab(l_rl_cntr)             := l_bill_rate_override;
                l_rlt_cost_rate_tab(l_rl_cntr)                 := x_cost_rate;
                l_rlt_rw_cost_rate_ovr_tab(l_rl_cntr)          := l_rw_cost_rate_override;
                l_rlt_burden_cost_rate_tab(l_rl_cntr)          := x_burden_cost_rate;
                l_rlt_burden_cost_rate_ovr_tab(l_rl_cntr)      := l_burden_cost_rate_override;
                l_rlt_raw_cost_tab(l_rl_cntr)                  := x_raw_cost;
                l_rlt_burden_cost_tab(l_rl_cntr)               := x_burden_cost;
                l_rlt_raw_revenue_tab(l_rl_cntr)               := x_raw_revenue;
                l_rlt_bill_markup_percent_tab(l_rl_cntr)       := x_bill_markup_percentage;
                l_rlt_txn_curr_code_tab(l_rl_cntr)             := NVL(l_Final_txn_currency_code,l_txn_currency_code);
                l_rlt_raw_cost_rejection_tab(l_rl_cntr)        := x_raw_cost_rejection_code;
                l_rlt_burden_rejection_tab(l_rl_cntr)     := x_burden_cost_rejection_code;
                l_rlt_revenue_rejection_tab(l_rl_cntr)         := x_revenue_rejection_code;
                l_rlt_projfunc_rejection_tab(l_rl_cntr)        := x_projfunc_rejection_code;
                l_rlt_project_rejection_tab(l_rl_cntr)         := x_project_rejection_code;
                l_rlt_ind_compiled_set_tab(l_rl_cntr)     := x_cost_ind_compiled_set_id;


        END LOOP;  --}

    -- main loooooooooop ends here
    END LOOP;  --}}

    /** Bug fix: 4207221 This condition is not updating the rollup tmp with rejections
     If NVL(l_return_status,'S') = 'S' Then
     **/
    IF l_rlt_budget_line_id_tab.COUNT > 0 Then
       FORALL i IN l_rlt_budget_line_id_tab.FIRST .. l_rlt_budget_line_id_tab.LAST
        UPDATE PA_FP_ROLLUP_TMP RL
        SET RL.QUANTITY = l_rlt_quantity_tab(i)
                  ,RL.BILL_RATE = l_rlt_bill_rate_tab(i)
                   ,RL.BILL_RATE_OVERRIDE = l_rlt_bill_rate_ovr_tab(i)
                   ,RL.COST_RATE = l_rlt_cost_rate_tab(i)
                   ,RL.RW_COST_RATE_OVERRIDE = l_rlt_rw_cost_rate_ovr_tab(i)
                   ,RL.BURDEN_COST_RATE = l_rlt_burden_cost_rate_tab(i)
                   ,RL.BURDEN_COST_RATE_OVERRIDE = l_rlt_burden_cost_rate_ovr_tab(i)
                   ,RL.TXN_RAW_COST = l_rlt_raw_cost_tab(i)
                   ,RL.TXN_BURDENED_COST = l_rlt_burden_cost_tab(i)
                   ,RL.TXN_REVENUE = l_rlt_raw_revenue_tab(i)
                   ,RL.BILL_MARKUP_PERCENTAGE = l_rlt_bill_markup_percent_tab(i)
                   ,RL.TXN_CURRENCY_CODE = l_rlt_txn_curr_code_tab(i)
                   ,RL.COST_REJECTION_CODE = l_rlt_raw_cost_rejection_tab(i)
                   ,RL.BURDEN_REJECTION_CODE = l_rlt_burden_rejection_tab(i)
                   ,RL.REVENUE_REJECTION_CODE = l_rlt_revenue_rejection_tab(i)
                   ,RL.PFC_CUR_CONV_REJECTION_CODE = l_rlt_projfunc_rejection_tab(i)
                   ,RL.PC_CUR_CONV_REJECTION_CODE = l_rlt_project_rejection_tab(i)
                   ,RL.COST_IND_COMPILED_SET_ID = l_rlt_ind_compiled_set_tab(i)
           ,RL.SYSTEM_REFERENCE5 = 'Y'
        WHERE RL.BUDGET_LINE_ID = l_rlt_budget_line_id_tab(i);
    END IF;
    x_return_status := NVL(l_return_status,'S');
    IF p_pa_debug_mode = 'Y' Then
    	   print_msg('Leaving Get_Res_Rates API sts['||x_return_status||']');
            pa_debug.reset_err_stack;
    End If;
EXCEPTION
    WHEN RATEAPI_UNEXPECTED_ERRORS THEN
                fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                ,p_procedure_name => 'Get_Res_Rates.pa_plan_revenue.Get_planning_Rates');
                print_msg(to_char(l_stage)||' substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
        IF p_pa_debug_mode = 'Y' Then
                    pa_debug.reset_err_stack;
        End If;
        x_return_status := 'U';
                RAISE;

    WHEN UNEXPECTED_ERRORS THEN
        fnd_msg_pub.add_exc_msg
                ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                ,p_procedure_name => 'Get_Res_Rates:Update_rollupTmp_OvrRates');
                print_msg(to_char(l_stage)||' substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
        IF p_pa_debug_mode = 'Y' Then
                    pa_debug.reset_err_stack;
        End If;
        x_return_status := 'U';
                RAISE;
    WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg
            ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                ,p_procedure_name => 'Get_Res_Rates');
            print_msg(to_char(l_stage)||' substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
        IF p_pa_debug_mode = 'Y' Then
                pa_debug.reset_err_stack;
        End If;
        x_return_status := 'U';
        RAISE;

END Get_Res_RATEs;

/* Compare the In params value with the existsing budget line values
* and populate the changed flags. Based on these flag apply the
* precedence and set the addl variables to pass it to spread api
*/
PROCEDURE Compare_With_BdgtLine_Values
         (p_resource_ass_id    IN Number
         ,p_txn_currency_code  IN Varchar2
         ,p_line_start_date    IN Date
         ,p_line_end_date      IN Date
     ,p_bdgt_version_type  IN Varchar2
     ,p_rate_based_flag    IN Varchar2
     ,p_apply_progress_flag IN Varchar2
     ,p_resAttribute_changed_flag IN Varchar2
     /* Bug fix:4263265 Added these param to avoid deriving rate overrides */
         ,p_qty_changed_flag        IN Varchar2
         ,p_raw_cost_changed_flag   IN Varchar2
         ,p_rw_cost_rate_changed_flag   IN Varchar2
         ,p_burden_cost_changed_flag    IN Varchar2
         ,p_b_cost_rate_changed_flag    IN Varchar2
         ,p_rev_changed_flag            IN Varchar2
         ,p_bill_rate_changed_flag      IN Varchar2
	 ,p_revenue_only_entry_flag  IN Varchar2
         ,p_txn_currency_code_ovr IN OUT NOCOPY Varchar2
         ,p_txn_plan_quantity     IN OUT NOCOPY Number
         ,p_txn_raw_cost          IN OUT NOCOPY Number
         ,p_txn_raw_cost_rate     IN OUT NOCOPY Number
         ,p_txn_rw_cost_rate_override IN OUT NOCOPY Number
         ,p_txn_burdened_cost         IN OUT NOCOPY Number
         ,p_txn_b_cost_rate           IN OUT NOCOPY Number
         ,p_txn_b_cost_rate_override  IN OUT NOCOPY Number
         ,p_txn_revenue         IN OUT NOCOPY Number
         ,p_txn_bill_rate       IN OUT NOCOPY Number
         ,p_txn_bill_rate_override  IN OUT NOCOPY Number
         ,x_qty_changed_flag        OUT NOCOPY Varchar2
         ,x_raw_cost_changed_flag   OUT NOCOPY Varchar2
         ,x_rw_cost_rate_changed_flag   OUT NOCOPY Varchar2
         ,x_burden_cost_changed_flag    OUT NOCOPY Varchar2
         ,x_b_cost_rate_changed_flag    OUT NOCOPY Varchar2
         ,x_rev_changed_flag            OUT NOCOPY Varchar2
         ,x_bill_rate_changed_flag      OUT NOCOPY Varchar2
         ,x_bill_rt_ovr_changed_flag    OUT NOCOPY Varchar2
     ,x_txn_revenue_addl            OUT NOCOPY Number
         ,x_txn_raw_cost_addl           OUT NOCOPY Number
         ,x_txn_plan_quantity_addl      OUT NOCOPY Number
         ,x_txn_burdened_cost_addl      OUT NOCOPY Number
     ,x_init_raw_cost               OUT NOCOPY Number
     ,x_init_burdened_cost          OUT NOCOPY Number
     ,x_init_revenue                OUT NOCOPY Number
     ,x_init_quantity               OUT NOCOPY Number
         ,x_bl_raw_cost                 OUT NOCOPY Number
         ,x_bl_burdened_cost            OUT NOCOPY Number
         ,x_bl_revenue                  OUT NOCOPY Number
         ,x_bl_quantity                 OUT NOCOPY Number
         ) IS

    i get_bl_date_csr%rowtype;
    l_actual_exists   varchar2(100);
        l_txn_raw_cost_rate         Number ;
        l_txn_rw_cost_rate_override Number ;
        l_txn_b_cost_rate           Number ;
        l_txn_b_cost_rate_override  Number ;
        l_txn_bill_rate             Number ;
        l_txn_bill_rate_override    Number ;

BEGIN
    -- check the budgetline amounts with the passes in values
    -- and assign the values if the params are null. based on this an additional varaibles needs to
    -- derived to call the spread api.
    x_qty_changed_flag  := 'N';
        x_raw_cost_changed_flag  := 'N';
        x_rw_cost_rate_changed_flag  := 'N';
        x_burden_cost_changed_flag  := 'N';
        x_b_cost_rate_changed_flag  := 'N';
        x_rev_changed_flag  := 'N';
        x_bill_rate_changed_flag  := 'N';
    x_txn_revenue_addl         := NULL;
        x_txn_raw_cost_addl          := NULL;
        x_txn_plan_quantity_addl    := NULL;
        x_txn_burdened_cost_addl:= NULL;
        l_txn_raw_cost_rate         := p_txn_raw_cost_rate;
        l_txn_rw_cost_rate_override := p_txn_rw_cost_rate_override;
        l_txn_b_cost_rate           := p_txn_b_cost_rate;
        l_txn_b_cost_rate_override  := p_txn_b_cost_rate_override;
        l_txn_bill_rate             := p_txn_bill_rate;
        l_txn_bill_rate_override    := p_txn_bill_rate_override;
	If P_PA_DEBUG_MODE = 'Y' Then
    print_msg('Entered Compare_With_BdgtLine_Values API');
	End if;
        i := NULL;
        AvgBlRec := NULL;
    IF g_source_context = 'RESOURCE_ASSIGNMENT' Then

                OPEN cur_ra_txn_rates(p_resource_ass_id
                                 ,p_txn_currency_code);
                FETCH cur_ra_txn_rates INTO i;
                IF cur_ra_txn_rates%NOTFOUND then
                        i := NULL;
			AvgBlRec := NULL;
                End If;
                CLOSE cur_ra_txn_rates;
        ELSE

                OPEN cur_avgBlrts(p_resource_ass_id
                                 ,p_txn_currency_code
                                 ,p_line_start_Date
                                 ,p_line_end_date
                                 );
                FETCH cur_avgBlrts INTO AvgBlRec;
                IF cur_avgBlrts%NOTFOUND then
                                AvgBlRec := NULL;
                End If;
                CLOSE cur_avgBlrts;
                OPEN get_bl_date_csr(p_resource_ass_id
                                 ,p_txn_currency_code
                                 ,p_line_start_Date
                                 ,p_line_end_date
                        ,AvgBlRec.avg_txn_cost_rate_override
                                 ,AvgBlRec.avg_burden_cost_rate_override
                                 ,AvgBlRec.avg_txn_bill_rate_override);
                --print_msg('Opened budgetline amts cursor');
            FETCH get_bl_date_csr INTO i;
            CLOSE get_bl_date_csr;
    END IF;

        /* Bug fix:4221022 The generation process is creating budget Lines with unrounded qty and amounts
                 * this causes the spread process to create -0.003 lines. In order to avoid this as a precautionary measure
                 * before comparing just round the amounts from budget lines also */
        If NVL(i.quantity,0) <> 0 Then
           If  p_rate_based_flag = 'Y' Then
            i.quantity := Round_quantity(i.quantity);
           Else
            i.quantity := pa_currency.round_trans_currency_amt1(i.quantity,p_txn_currency_code);
           End If;
        End If;
        If NVL(i.txn_raw_cost,0) <> 0 Then
            i.txn_raw_cost := pa_currency.round_trans_currency_amt1(i.txn_raw_cost,p_txn_currency_code);
        End If;
        If NVL(i.txn_burdened_cost,0) <> 0 Then
            i.txn_burdened_cost := pa_currency.round_trans_currency_amt1(i.txn_burdened_cost,p_txn_currency_code);
        End If;
        If NVL(i.txn_revenue,0) <> 0 Then
            i.txn_revenue := pa_currency.round_trans_currency_amt1(i.txn_revenue,p_txn_currency_code);
        End If;
        /* end of bug 4221022 */

                x_init_raw_cost              := i.init_raw_cost;
                x_init_burdened_cost         := i.init_burdened_cost;
                x_init_revenue               := i.init_revenue;
                x_init_quantity              := i.init_quantity;
                x_bl_raw_cost                := i.txn_raw_cost;
                x_bl_burdened_cost           := i.txn_burdened_cost;
                x_bl_revenue                 := i.txn_revenue;
                x_bl_quantity                := i.quantity;
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('bletcCstRtOvr['||i.etc_cost_rate_override||']EtcRt['||i.etc_cost_rate||']EtcBurdRtOvr['||i.etc_burden_rate_override||']EtcBdRt['||i.etc_burden_rate||']');
	End if;

    If (x_init_raw_cost is NULL
        and x_init_burdened_cost is NULL
        and x_init_revenue is NULL
        and x_init_quantity is NULL ) Then
        l_actual_exists := 'N';
    Else
        l_actual_exists := 'Y';
    End if;

    /* When calculate api is called in apply progress mode, just we need to correct the
    * budget line. so no need to apply any precedence rules. so derive all additionals
    */
     If NVL(p_apply_progress_flag,'N') <> 'Y' Then --{

        /*
             Bug 6429285
             Below if condition will handle a corner case
             If a rate based resource is added as non rate based resource assignment
             in pa_resource_asgn_curr and pa_budget_lines quantity will be populated
             as raw_cost and display_quantity will be null.Now if we want to enter
             the quantity same as raw cost (i.e existing quantity) the existing if condition will fail because
             the user entered quantity is same as what is alreay existing
             This check is already performed in Compare_bdgtLine_Values*/
        /*

        if NVL(p_txn_plan_quantity,0) <> Nvl(i.quantity,0) Then
            x_qty_changed_flag := 'Y';
        End If;*/

        if ((NVL(p_txn_plan_quantity,0) <> Nvl(i.quantity,0))
            or (p_txn_plan_quantity = 0 and i.bl_zero_null_quantity is null)
            or (p_txn_plan_quantity is not null and i.display_quantity is null))Then
            x_qty_changed_flag := 'Y';
        End If;

        If NVL(p_raw_cost_changed_flag,'N') = 'Y' then
           if ((NVL(p_txn_raw_cost,0) <> NVL(i.txn_raw_cost,0))
        OR (p_txn_raw_cost = 0 AND i.bl_zero_null_rawcost is NULL )) Then /*bug fix:4693839 */
            --print_msg('Cost changed ptxncost['||p_txn_raw_cost||']itxncost['||i.txn_raw_cost||']');
            x_raw_cost_changed_flag := 'Y';
           End If;
        End If;

        If NVL(p_rw_cost_rate_changed_flag,'N') = 'Y' Then --{
           /* Use actual exists flag to derive / assign the rates */
            IF p_txn_rw_cost_rate_override IS NULL Then
                If nvl(p_txn_raw_cost_rate,0) <> nvl(i.etc_cost_rate_override,nvl(i.etc_cost_rate,0)) Then
                                        p_txn_rw_cost_rate_override := p_txn_raw_cost_rate;
                                        x_rw_cost_rate_changed_flag := 'Y';
                                End If;
            Else
                If ((NVL(p_txn_rw_cost_rate_override,0) <>
                        nvl(i.etc_cost_rate_override,nvl(i.etc_cost_rate,0)))
            OR
            ( p_txn_rw_cost_rate_override = 0 AND AvgBlRec.avg_zero_null_cost_rate is NULL ))  Then /*bug fix:4693839 */
                        x_rw_cost_rate_changed_flag := 'Y';
                End If;
            End If;
            if p_txn_rw_cost_rate_override is NULL Then
           If ((NVL(p_txn_raw_cost_rate,0) <> nvl(i.etc_cost_rate_override,nvl(i.etc_cost_rate,0)))
                    OR ( p_txn_raw_cost_rate = 0 AND AvgBlRec.avg_zero_null_cost_rate is NULL))  Then /*bug fix:4693839 */
                     p_txn_rw_cost_rate_override  := NVL(p_txn_raw_cost_rate,i.etc_cost_rate_override);
                     x_rw_cost_rate_changed_flag := 'Y';
               End If;
        End If;
        End If; --}

        If NVL(p_burden_cost_changed_flag,'N') = 'Y' Then
           if ((NVL(p_txn_burdened_cost,0) <> NVL(i.txn_burdened_cost,0))
            OR ( p_txn_burdened_cost = 0 AND i.bl_zero_null_burdencost is NULL )) Then  /*bug fix:4693839 */
            x_burden_cost_changed_flag  := 'Y';
           End IF;
        End If;

        IF NVL(p_b_cost_rate_changed_flag,'N') = 'Y' Then --{
           /* start burden cost rate override comparision */
                    If p_txn_b_cost_rate_override  is NULL Then
                    if NVL(p_txn_b_cost_rate,0) <> NVL(i.etc_burden_rate_override,nvl(i.etc_burden_rate,0)) Then
                           p_txn_b_cost_rate_override := p_txn_b_cost_rate;
                           x_b_cost_rate_changed_flag := 'Y';
                        End If;
                    Else
                        if ((nvl(p_txn_b_cost_rate_override,0) <> nvl(i.etc_burden_rate_override,NVL(i.etc_burden_rate,0)))
                OR (p_txn_b_cost_rate_override = 0 AND AvgBlRec.avg_zero_null_burden_rate is NULL )) Then /*bug fix:4693839 */
                                 x_b_cost_rate_changed_flag := 'Y';
                        End If;
                    End If;
           /* start of burden cost rate comparision */
       IF p_txn_b_cost_rate_override is NULL Then
            if ( (NVL(p_txn_b_cost_rate,0) <> nvl(i.etc_burden_rate_override,NVL(i.etc_burden_rate,0)))
                       OR (p_txn_b_cost_rate = 0  AND AvgBlRec.avg_zero_null_burden_rate is NULL ))  Then /*bug fix:4693839 */
                        p_txn_b_cost_rate_override := p_txn_b_cost_rate;
                        x_b_cost_rate_changed_flag := 'Y';
                End If;
           End If;
	End If; --}

        IF NVL(p_rev_changed_flag,'N') = 'Y' Then
          if ((NVL(p_txn_revenue,0) <> NVL(i.txn_revenue,0))
          OR (p_txn_revenue = 0 AND i.bl_zero_null_revenue is NULL )) Then /*bug fix:4693839 */
            x_rev_changed_flag := 'Y';
          End IF;
        End IF;

        IF NVL(p_bill_rate_changed_flag,'N') = 'Y' Then --{
          /* start of bill rate override comparision*/
                    IF p_txn_bill_rate_override  is NULL Then
                    if NVL(p_txn_bill_rate,0) <> nvl(i.etc_bill_rate,0) Then
                                p_txn_bill_rate_override  := p_txn_bill_rate;
                                x_bill_rate_changed_flag := 'Y';
                        End If;
                    Else
                        If ((nvl(p_txn_bill_rate_override,0) <> nvl( i.etc_bill_rate_override,0))
                OR (p_txn_bill_rate_override = 0 AND AvgBlRec.avg_zero_null_bill_rate is NULL))  Then /*bug fix:4693839 */
                                x_bill_rate_changed_flag := 'Y';
                        End If;
                    End If;
       If p_txn_bill_rate_override is NULL Then
                   if ( (NVL(p_txn_bill_rate,0) <> nvl(i.etc_bill_rate_override,NVl(i.etc_bill_rate,0)))
                        OR (p_txn_bill_rate = 0 AND  AvgBlRec.avg_zero_null_bill_rate is NULL))  Then /*bug fix:4693839 */
                        p_txn_bill_rate_override  := p_txn_bill_rate;
                        x_bill_rate_changed_flag := 'Y';
                   End IF;
           End If;
         END IF; --}
       END IF ; --} end of apply progress is not Y

    IF (nvl(p_txn_revenue,0) - nvl(i.txn_revenue,0)) = 0 Then
        x_txn_revenue_addl := NULL;
    Else
        x_txn_revenue_addl :=  (nvl(p_txn_revenue,0) - nvl(i.txn_revenue,0));
    End If;

    IF (nvl(p_txn_raw_cost,0) - nvl(i.txn_raw_cost,0)) = 0 Then
        x_txn_raw_cost_addl := NULL;
    Else
        x_txn_raw_cost_addl := (nvl(p_txn_raw_cost,0) - nvl(i.txn_raw_cost,0));
    End If;

    IF (nvl(p_txn_plan_quantity,0) - nvl(i.quantity,0)) = 0 Then
        x_txn_plan_quantity_addl := NULL;
    Else
        x_txn_plan_quantity_addl := (nvl(p_txn_plan_quantity,0) - nvl(i.quantity,0));
    End If;

    IF (nvl(p_txn_burdened_cost,0) - nvl(i.txn_burdened_cost,0)) = 0 Then
        x_txn_burdened_cost_addl := NULL;
    Else
        x_txn_burdened_cost_addl := (nvl(p_txn_burdened_cost,0) - nvl(i.txn_burdened_cost,0));
    End If;

        /* bug fix: 4122263 retain the original rates and overrides */
        IF (NVL(p_apply_progress_flag,'N') = 'Y' OR NVL(p_resAttribute_changed_flag,'N') = 'Y' ) Then
                --retain only quantity and set all other flags to N
        IF NVL(x_txn_plan_quantity_addl,0) <> 0 Then
                    x_qty_changed_flag  := 'Y';
        End If;
                x_raw_cost_changed_flag  := 'N';
                x_rw_cost_rate_changed_flag  := 'N';
                x_burden_cost_changed_flag  := 'N';
                x_b_cost_rate_changed_flag  := 'N';
                x_rev_changed_flag  := 'N';
                x_bill_rate_changed_flag  := 'N';
                x_txn_revenue_addl         := NULL;
                x_txn_raw_cost_addl          := NULL;
                x_txn_burdened_cost_addl:= NULL;
                p_txn_raw_cost_rate         := l_txn_raw_cost_rate;
                p_txn_rw_cost_rate_override := l_txn_rw_cost_rate_override;
                p_txn_b_cost_rate           := l_txn_b_cost_rate;
                p_txn_b_cost_rate_override  := l_txn_b_cost_rate_override;
                p_txn_bill_rate             := l_txn_bill_rate;
                p_txn_bill_rate_override    := l_txn_bill_rate_override;
        END IF;
    IF p_bdgt_version_type in ('COST','ALL') Then
       IF p_rate_based_flag = 'N' Then
           x_rw_cost_rate_changed_flag := 'N';
	   If p_bdgt_version_type = 'ALL' Then
	     If p_revenue_only_entry_flag = 'Y' Then
		p_txn_rw_cost_rate_override := 0;
	     ElsIf p_txn_rw_cost_rate_override <> 0 Then
            	p_txn_rw_cost_rate_override := 1;
	     End If;
	   Else
		If p_txn_rw_cost_rate_override <> 0 Then
                   p_txn_rw_cost_rate_override := 1;
		End If;
           End If;
       End If;
    Elsif p_bdgt_version_type in ('REVENUE') Then
           IF p_rate_based_flag = 'N' Then
                x_bill_rate_changed_flag := 'N';
                p_txn_bill_rate_override := 1;
           End If;
    End If;
    If P_PA_DEBUG_MODE = 'Y' Then
    print_msg('Leaving Compare_With_BdgtLine_Values API');
    End if;
EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END Compare_With_BdgtLine_Values;
/* This API will apply the precedence rules on Non-Rate Based planning transactions */
PROCEDURE Apply_NON_RATE_BASE_precedence(
     p_txn_currency_code        IN Varchar2
    ,p_rate_based_flag          IN Varchar2
    ,p_budget_version_type      IN Varchar2
    ,p_qty_changed_flag         IN Varchar2
    ,p_raw_cost_changed_flag    IN Varchar2
    ,p_rw_cost_rate_changed_flag IN Varchar2
    ,p_burden_cost_changed_flag IN Varchar2
    ,p_b_cost_rate_changed_flag IN Varchar2
    ,p_rev_changed_flag         IN Varchar2
    ,p_bill_rate_changed_flag   IN Varchar2
    ,p_bill_rt_ovr_changed_flag IN Varchar2
    ,p_init_raw_cost            IN Number
    ,p_init_burdened_cost       IN Number
    ,p_init_revenue             IN Number
    ,p_init_quantity            IN Number
    ,p_bl_raw_cost              IN Number
    ,p_bl_burdened_cost         IN Number
    ,p_bl_revenue               IN Number
    ,p_bl_quantity              IN Number
    ,p_curr_cost_rate           IN Number
    ,p_curr_burden_rate         IN Number
    ,p_curr_bill_rate           IN Number
    ,p_revenue_only_entry_flag  IN Varchar2
    ,x_txn_plan_quantity        IN OUT NOCOPY Number
    ,x_txn_raw_cost             IN OUT NOCOPY Number
    ,x_txn_raw_cost_rate        IN OUT NOCOPY Number
    ,x_txn_rw_cost_rate_override IN OUT NOCOPY Number
    ,x_txn_burdened_cost        IN OUT NOCOPY Number
    ,x_txn_b_cost_rate          IN OUT NOCOPY Number
    ,x_txn_b_cost_rate_override IN OUT NOCOPY Number
    ,x_txn_revenue              IN OUT NOCOPY Number
    ,x_txn_bill_rate            IN OUT NOCOPY Number
    ,x_txn_bill_rate_override   IN OUT NOCOPY Number
    ,x_txn_revenue_addl         IN OUT NOCOPY Number
    ,x_txn_raw_cost_addl        IN OUT NOCOPY Number
    ,x_txn_plan_quantity_addl   IN OUT NOCOPY Number
    ,x_txn_burdened_cost_addl   IN OUT NOCOPY Number
    ) IS

    l_stage   varchar2(100);

BEGIN

    -- precedence rules
    -- For non-rate based transactions, the cost and rev rate is always 1,
    -- any change to rate is ignored
    -- if there is change in burden rate override, then burden override
    -- must be applied
    -- If qty and cost is changed then cost takes the precedence and
    -- qty := cost;
    -- if qty only changed then cost := qty, If cost only changed then
    -- qty := cost

        If p_budget_version_type in ('COST','ALL') THEN
            -- Start of Raw cost and qty calculation
            -- ignore the rate and rate override
            /* For Non rate based transactions ignore any change
             * to rate override and always set it to 1 */
	   If g_source_context = 'RESOURCE_ASSIGNMENT' Then
		If p_budget_version_type = 'ALL' then
            	   IF nvl(x_txn_rw_cost_rate_override, 1) <> 0 AND p_revenue_only_entry_flag = 'N' THEN
			If p_raw_cost_changed_flag = 'Y' then
               		   x_txn_rw_cost_rate_override := 1;
			end If;
	           Elsif p_revenue_only_entry_flag = 'Y' then
			x_txn_rw_cost_rate_override := 0;
		   Else
			If p_raw_cost_changed_flag = 'Y' Then
			  x_txn_rw_cost_rate_override := 1;
			End If;
            	   END IF;
		Else  -- for all other versions
		   IF nvl(x_txn_rw_cost_rate_override, 1) <> 0 THEN
                        x_txn_rw_cost_rate_override := 1;
                   END IF;
		End If;
	   Else
		If p_budget_version_type = 'ALL' then
			If x_txn_rw_cost_rate_override is NULL
			   and x_txn_raw_cost is NULL
			   and p_raw_cost_changed_flag = 'N' Then
			   x_txn_rw_cost_rate_override := 0;
			Else
			   IF nvl(x_txn_rw_cost_rate_override, 1) <> 0 and p_revenue_only_entry_flag = 'N' THEN
				If p_raw_cost_changed_flag = 'Y' then
				  x_txn_rw_cost_rate_override := 1;
				End If;
			   Elsif p_revenue_only_entry_flag = 'Y' Then
				x_txn_rw_cost_rate_override := 0;
			   End If;
			End If;
		Else
		  IF nvl(x_txn_rw_cost_rate_override, 1) <> 0 THEN
                        x_txn_rw_cost_rate_override := 1;
                  END IF;
		End If;
	   End If;


        /* Rules:
             * C1: when raw cost and quantity both change for the
             *     non-rate based resource then Raw cost takes the precedence
             *     over quantity and copy raw cost to quantity.
         * C2: If raw cost only changes then copy raw cost to quantity.
         * C3: If quantity only changes then copy quantity to raw cost.
         * C4: Change in raw cost should re-derive burden cost rate
         *     override only when the previous burden rate override exists.
         */

            /* The following is for the case C1 and C2 - copy raw cost to
             * quantity when raw cost changes */
            IF (p_qty_changed_flag = 'Y' AND p_raw_cost_changed_flag = 'Y') OR
               (p_qty_changed_flag = 'N' AND p_raw_cost_changed_flag = 'Y')
            THEN
               l_stage := 'NRB - C1 and C2 - raw cost changed';
               --print_msg(l_stage);
               x_txn_plan_quantity := x_txn_raw_cost; -- copy raw cost to quan
               		x_txn_plan_quantity_addl := nvl(x_txn_plan_quantity,0) -
                                           nvl(p_bl_quantity,0);
               x_txn_raw_cost_addl := nvl(x_txn_raw_cost,0) -
                                      nvl(p_bl_raw_cost,0);
            /* The following is for the case C3 - copy quantity to raw cost
             * when quantity only changes (raw cost is not changed) */
            ELSIF (p_qty_changed_flag = 'Y' AND p_raw_cost_changed_flag = 'N')
            THEN
               l_stage := 'NRB - C3 - quantity changes';
               --print_msg(l_stage);
               x_txn_raw_cost := x_txn_plan_quantity;-- copy quan to raw cost
               -- x_txn_rw_cost_rate_override is set above for all cases.
               x_txn_raw_cost_addl := nvl(x_txn_raw_cost,0) -
                                      nvl(p_bl_raw_cost,0);
               x_txn_plan_quantity_addl := nvl(x_txn_plan_quantity,0) -
                                           nvl(p_bl_quantity,0);
            END IF;

            /* start of burden cost calculation - change in the qty results
               in burden cost variation */
        /* When burden cost and burden cost rate both change, then
             * burden cost takes the precedence, so re-derive the burden cost
             * rate override
             * Note: Rates are always calculated as ETC rates i.e.
             *       ETC Rate = (burden cost - actual burden cost ) /
             *                  (quantity - actual quantity)                */

            IF ((p_qty_changed_flag = 'Y' AND
                 p_b_cost_rate_changed_flag = 'Y' AND
                 p_burden_cost_changed_flag = 'N') OR
                (p_qty_changed_flag = 'Y' AND
                 p_b_cost_rate_changed_flag = 'N' AND
                 p_burden_cost_changed_flag = 'N') OR
                (p_qty_changed_flag = 'N' AND
                 p_b_cost_rate_changed_flag = 'Y'))
            THEN
               l_stage := 'PRC:8';
               --print_msg(l_stage);
               -- No need to check for l_actual_exists
               IF (x_txn_plan_quantity IS NOT NULL OR
                   p_qty_changed_flag = 'Y')
               THEN
                   x_txn_burdened_cost := nvl(p_init_burdened_cost,0) +
                                          ((nvl(x_txn_plan_quantity ,0) -
                                            nvl(p_init_quantity,0)) *
                                            nvl(x_txn_b_cost_rate_override,
                                                x_txn_b_cost_rate));
                   x_txn_burdened_cost :=
                                   pa_currency.round_trans_currency_amt1(
                                      x_txn_burdened_cost,p_txn_currency_code);
                   x_txn_burdened_cost_addl := nvl(x_txn_burdened_cost,0) -
                                               nvl(p_init_burdened_cost,0);
               END IF;
        /* re-derive the burden cost rate override when burden cost
             * is changed */
            ELSIF (p_burden_cost_changed_flag = 'Y') THEN
		If p_budget_version_type = 'ALL' then
			iF x_txn_raw_cost = x_txn_plan_quantity then
			   --l_stage := 'PRC:9.1'; print_msg(l_stage);
			   If  (nvl(x_txn_plan_quantity,0) - nvl(p_init_quantity,0)) <> 0 THEN
                            x_txn_b_cost_rate_override := (nvl(x_txn_burdened_cost,0) -
                                                 nvl(p_init_burdened_cost,0)) /
                                                (nvl(x_txn_plan_quantity,0) -
                                                 nvl(p_init_quantity,0));
			   End If;
			Else
			   --l_stage := 'PRC:9.2'; print_msg(l_stage);
			   If (nvl(x_txn_raw_cost,0) - nvl(p_init_raw_cost,0)) <> 0 Then
			    x_txn_b_cost_rate_override := (nvl(x_txn_burdened_cost,0) -
                                                 nvl(p_init_burdened_cost,0)) /
                                                (nvl(x_txn_raw_cost,0) -
                                                 nvl(p_init_raw_cost,0));
			   End If;
                        END IF;
		Else
               		l_stage := 'PRC:9.3';
               		--print_msg(l_stage);
               		IF (nvl(x_txn_plan_quantity,0) - nvl(p_init_quantity,0)) <> 0 THEN
                  	    x_txn_b_cost_rate_override := (nvl(x_txn_burdened_cost,0) -
                                                 nvl(p_init_burdened_cost,0)) /
                                                (nvl(x_txn_plan_quantity,0) -
                                                 nvl(p_init_quantity,0));
               		END IF;
		End If;
               x_txn_burdened_cost_addl := nvl(x_txn_burdened_cost,0) -
                                           nvl(p_init_burdened_cost,0);
            END IF;

        /* When burden rate is previously overridden, change in the raw
             * cost should re-derive the burden cost rate override. This is
             * the new rule enforced.   */

       IF (p_raw_cost_changed_flag = 'Y') AND
        (p_burden_cost_changed_flag = 'N' AND p_b_cost_rate_changed_flag = 'N' ) THEN
              /* New Rule - see C4 above */
          /* IF old burden cost rate override IS NOT NULL THEN
           * New burden cost rate override =
           *  ((new raw cost - actual raw cost) *
           *   ((old burden cost - actual burden cost) /
           *    (old raw cost - actual raw cost))) /
           *  (quantity - actual quantity)                  */
              IF p_curr_burden_rate IS NOT NULL THEN
                 IF ((nvl(p_bl_raw_cost,0) - nvl(p_init_raw_cost,0)) <> 0) AND
                    ((nvl(x_txn_plan_quantity, 0) -
                      nvl(p_init_quantity, 0)) <> 0) THEN

		   If p_budget_version_type = 'ALL' then
                        iF x_txn_raw_cost = x_txn_plan_quantity then
                    	   x_txn_b_cost_rate_override:= ((nvl(x_txn_raw_cost,0) -
                                                   nvl(p_init_raw_cost,0)) *
                                                  ((nvl(p_bl_burdened_cost,0) -
                                                 nvl(p_init_burdened_cost,0))) /
                                                   (nvl(p_bl_raw_cost,0) -
                                                    nvl(p_init_raw_cost,0))) /
                                                 (nvl(x_txn_plan_quantity, 0) -
                                                  nvl(p_init_quantity, 0));
			Else
			   -- mixture of revenue only and cost and revenue together transactions
			   x_txn_b_cost_rate_override:= ((nvl(x_txn_raw_cost,0) -
                                                   nvl(p_init_raw_cost,0)) *
                                                  ((nvl(p_bl_burdened_cost,0) -
                                                 nvl(p_init_burdened_cost,0))) /
                                                   (nvl(p_bl_raw_cost,0) -
                                                    nvl(p_init_raw_cost,0))) /
                                                 (nvl(x_txn_raw_cost, 0) -
                                                  nvl(p_init_raw_cost, 0));
		        End If;
		   Else
                    	-- Cost only version, always raw cost and quantity exists
			x_txn_b_cost_rate_override:= ((nvl(x_txn_raw_cost,0) -
                                                   nvl(p_init_raw_cost,0)) *
                                                  ((nvl(p_bl_burdened_cost,0) -
                                                 nvl(p_init_burdened_cost,0))) /
                                                   (nvl(p_bl_raw_cost,0) -
                                                    nvl(p_init_raw_cost,0))) /
                                                 (nvl(x_txn_plan_quantity, 0) -
                                                  nvl(p_init_quantity, 0));
		   End If;
                 END IF;
          END IF;
           END IF;
        END IF;
        /* end of cost budget version */

    /* Start of Revenue calculation */
    /* R1: For revenue only version, change in revenue will be copied
         *     to quantity and
         * R2: change in quantity will be copied to revenue.
         * And bill rate is always 1.
         * R3: For cost and revenue together version, change in revenue
         *     will derive the bill rate override and change in the raw cost
         *     will re-derive the bill rate override provided the previous
         *     bill rate override exists.                                 */

        IF p_budget_version_type IN ('REVENUE') THEN
           IF ((p_rev_changed_flag = 'Y' AND p_qty_changed_flag = 'Y') OR
               (p_rev_changed_flag = 'Y' AND p_qty_changed_flag = 'N'))
           THEN
              x_txn_plan_quantity := x_txn_revenue; -- Case R1.
              IF nvl(x_txn_bill_rate_override, 1) <> 0 THEN
                 x_txn_bill_rate_override := 1;
              END IF;
              x_txn_revenue_addl := nvl(x_txn_revenue,0) -
                                    nvl(p_init_revenue,0);
              x_txn_plan_quantity_addl := nvl(x_txn_plan_quantity,0) -
                                          nvl(p_bl_quantity,0);
           ELSIF (p_rev_changed_flag = 'N' AND p_qty_changed_flag = 'Y') THEN
              x_txn_revenue := x_txn_plan_quantity; -- Case R2.
              IF nvl(x_txn_bill_rate_override, 1) <> 0 THEN
                 x_txn_bill_rate_override := 1;
              END IF;
              x_txn_revenue_addl := nvl(x_txn_revenue,0) -
                                    nvl(p_init_revenue,0);
              x_txn_plan_quantity_addl := nvl(x_txn_plan_quantity,0) -
                                          nvl(p_bl_quantity,0);
           END IF;
        END IF; -- REVENUE

        IF p_budget_version_type IN ('ALL') THEN
           -- Case R3
           IF ((p_rev_changed_flag = 'Y' AND p_qty_changed_flag = 'Y') OR
               (p_rev_changed_flag = 'Y' AND p_qty_changed_flag = 'N' AND
                p_bill_rate_changed_flag = 'N') OR
               (p_rev_changed_flag = 'Y' AND p_qty_changed_flag = 'N' AND
                p_bill_rate_changed_flag = 'Y'))
           THEN
              IF (nvl(x_txn_plan_quantity,0) -
                  nvl(p_init_quantity,0)) <> 0 THEN
              x_txn_bill_rate_override := (nvl(x_txn_revenue,0) -
                                               nvl(p_init_revenue ,0)) /
                                              (nvl(x_txn_plan_quantity,0) -
                                               nvl(p_init_quantity,0));
              x_txn_revenue_addl := nvl(x_txn_revenue,0) -
                                        nvl(p_init_revenue,0);
              -- Below not in TA ... Add in?
                  x_txn_plan_quantity_addl := nvl(x_txn_plan_quantity,0) -
                                              nvl(p_bl_quantity,0);
          END IF;

           ELSIF ((p_rev_changed_flag = 'N' AND p_qty_changed_flag = 'Y') OR
                  p_bill_rate_changed_flag = 'Y') THEN
              x_txn_revenue_addl := (nvl(x_txn_plan_quantity,0) -
                                     nvl(p_init_quantity,0)) *
                                     nvl(x_txn_bill_rate_override,
                                         x_txn_bill_rate);
          x_txn_revenue_addl := pa_currency.round_trans_currency_amt1(
                                      x_txn_revenue_addl, p_txn_currency_code);
          x_txn_revenue := x_txn_revenue_addl + nvl(p_init_revenue,0);
          x_txn_plan_quantity_addl := nvl(x_txn_plan_quantity,0) -
                                              nvl(p_bl_quantity,0);
           END IF;

        END IF; -- ALL

        IF (p_budget_version_type IN ('ALL') AND
            p_raw_cost_changed_flag = 'Y' and p_rev_changed_flag = 'N' AND p_bill_rate_changed_flag = 'N' ) THEN
        /* Change in the raw cost should re-derive the revenue by
             * calculating the bill rate markup percentage. This is done
             * based on the formula
         * IF old bill rate override is not null then
         * New bill rate override =
         * ((new raw cost - actual raw cost) *
         *  ((old revenue - actual revenue) /
         *   (old raw cost - actual raw cost)) /
         * (quantity - actual quatity)                             */

           IF p_curr_bill_rate IS NOT NULL THEN
              IF ((nvl(p_bl_raw_cost,0) - nvl(p_init_raw_cost,0)) <> 0) AND
                 ((nvl(x_txn_plan_quantity, 0) - nvl(p_init_quantity, 0)) <> 0)
              THEN
                 x_txn_bill_rate_override := ((nvl(x_txn_raw_cost,0) -
                                               nvl(p_init_raw_cost,0)) *
                                              ((nvl(p_bl_revenue,0) -
                                                nvl(p_init_revenue,0))) /
                                               (nvl(p_bl_raw_cost,0) -
                                                nvl(p_init_raw_cost,0))) /
                                             (nvl(x_txn_plan_quantity, 0) -
                                              nvl(p_init_quantity, 0));
              END IF;
           ELSE
              -- New bill rate override = Markup % + 1
              -- (ensure that it is applied on the new raw cost,
              -- which should be equaled to qty)
              -- TBD
              null;
           END IF;
        END IF;

        IF x_txn_plan_quantity_addl = 0 Then
           x_txn_plan_quantity_addl := NULL;
        End If;
        IF x_txn_raw_cost_addl = 0 then
            x_txn_raw_cost_addl := NULL;
        End If;
        IF x_txn_burdened_cost_addl = 0 then
            x_txn_burdened_cost_addl := NULL;
        End If;
        If x_txn_revenue_addl = 0 Then
            x_txn_revenue_addl := NULL;
        End If;
	If P_PA_DEBUG_MODE = 'Y' Then
        print_msg('Leaving pply_NON_RATE_BASE_precedence API with status [S]');
	End if;
EXCEPTION
    WHEN OTHERS THEN
        RAISE;


END Apply_NON_RATE_BASE_precedence;

/* This API will apply the precedence rules on Rate Based planning transactions */
PROCEDURE Apply_RATE_BASE_precedence(
     p_txn_currency_code        IN Varchar2
    ,p_rate_based_flag          IN Varchar2
    ,p_budget_version_type      IN Varchar2
    ,p_qty_changed_flag         IN Varchar2
    ,p_raw_cost_changed_flag    IN Varchar2
    ,p_rw_cost_rate_changed_flag IN Varchar2
    ,p_burden_cost_changed_flag IN Varchar2
    ,p_b_cost_rate_changed_flag IN Varchar2
    ,p_rev_changed_flag         IN Varchar2
    ,p_bill_rate_changed_flag   IN Varchar2
    ,p_bill_rt_ovr_changed_flag IN Varchar2
    ,p_init_raw_cost            IN Number
    ,p_init_burdened_cost       IN Number
    ,p_init_revenue             IN Number
    ,p_init_quantity            IN Number
    ,p_bl_raw_cost              IN Number
    ,p_bl_burdened_cost         IN Number
    ,p_bl_revenue               IN Number
    ,p_bl_quantity              IN Number
    ,p_curr_cost_rate           IN Number
    ,p_curr_burden_rate         IN Number
    ,p_curr_bill_rate           IN Number
    ,x_txn_plan_quantity        IN OUT NOCOPY Number
    ,x_txn_raw_cost             IN OUT NOCOPY Number
    ,x_txn_raw_cost_rate        IN OUT NOCOPY Number
    ,x_txn_rw_cost_rate_override IN OUT NOCOPY Number
    ,x_txn_burdened_cost        IN OUT NOCOPY Number
    ,x_txn_b_cost_rate          IN OUT NOCOPY Number
    ,x_txn_b_cost_rate_override IN OUT NOCOPY Number
    ,x_txn_revenue              IN OUT NOCOPY Number
    ,x_txn_bill_rate            IN OUT NOCOPY Number
    ,x_txn_bill_rate_override   IN OUT NOCOPY Number
    ,x_txn_revenue_addl         IN OUT NOCOPY Number
    ,x_txn_raw_cost_addl        IN OUT NOCOPY Number
    ,x_txn_plan_quantity_addl   IN OUT NOCOPY Number
    ,x_txn_burdened_cost_addl   IN OUT NOCOPY Number
    ) IS

    l_stage                    VARCHAR2(100);
BEGIN
--print_msg('p_curr_burden_rate IS : ' || p_curr_burden_rate||']p_curr_bill_rate  IS : ' || p_curr_bill_rate);
    /***
    -- precedence rules
    -- For rate based transactions,
    -- Quantity  Rate   Amount   Result
    ---------------------------------------------------------------------------
       X         X      X        All are changed: New Amt := New Qty * New Rate
       X         X      -        New Amt := newQty*newRate
       X         -      -        New Amt := newQty*oldRate
       X         -      X        newRt = NewAmt/NewQty
       -         X      -        NewAmt := oldqty * newRate
    ------- special case as per FD -------
    -- any change in rate and cost will result in change in qty
       -         X      X        Newqty := newAmt/newRate
       -         -      X        NewQty := NewAmt / oldRate
    Based on the above precedence rules re derive the cost,qty
    and populate the addl out params
    ***/
    IF p_budget_version_type IN ('COST','ALL') THEN
       -- Start of Raw cost and qty calculation
       IF (p_qty_changed_flag = 'Y' AND  -- Case C1, C2, C3, C7
           p_raw_cost_changed_flag = 'Y' AND
           p_rw_cost_rate_changed_flag = 'Y') THEN

           l_stage := 'PRC:1';
           --print_msg(l_stage);

           -- x_txn_raw_cost := NVL(x_txn_plan_quantity ,0) *
           --                   NVL(x_txn_rw_cost_rate_override,
           --                       x_txn_raw_cost_rate);
           -- x_txn_raw_cost := pa_currency.round_trans_currency_amt1(
           --                      x_txn_raw_cost, p_txn_currency_code);

           -- C1, C2 and C3: rederive cost rate override as raw cost / quantity
           IF (nvl(x_txn_plan_quantity, 0) - nvl(p_init_quantity,0)) <> 0 THEN
              x_txn_rw_cost_rate_override := (NVL(x_txn_raw_cost,0) - NVL(p_init_raw_cost,0)) /
                                             (nvl(x_txn_plan_quantity, 0) - nvl(p_init_quantity,0));
           END IF;

           x_txn_raw_cost_addl := nvl(x_txn_raw_cost,0) -
                                  nvl(p_bl_raw_cost,0);
           l_stage := 'PRC:2';
           --print_msg(l_stage);
       ELSIF (p_qty_changed_flag = 'Y' AND  -- Case C5
              p_raw_cost_changed_flag = 'N' AND
              p_rw_cost_rate_changed_flag = 'Y') OR
             (p_qty_changed_flag = 'Y' AND  -- Case C20
              p_raw_cost_changed_flag = 'N' AND
              p_rw_cost_rate_changed_flag = 'N') THEN
           l_stage := 'PRC:3';
           --print_msg(l_stage);

           -- C5 and C20: rederive cost as raw cost rate * quantity
	   /* bug fix:5463690:5553549
           x_txn_raw_cost := NVL(x_txn_plan_quantity ,0) *
                             NVL(x_txn_rw_cost_rate_override,
                                 x_txn_raw_cost_rate);
	   */
 	   -- Note: Raw cost = ETC raw cost + Actual RawCost
 	   x_txn_raw_cost :=(NVL(p_init_raw_cost,0) +
 	                     ((NVL(x_txn_plan_quantity ,0) - NVL(p_init_quantity,0)) *
 	                      NVL(x_txn_rw_cost_rate_override,x_txn_raw_cost_rate)));

           x_txn_raw_cost := pa_currency.round_trans_currency_amt1(
                                x_txn_raw_cost, p_txn_currency_code);
           x_txn_raw_cost_addl := nvl(x_txn_raw_cost,0) -
                                  nvl(p_bl_raw_cost,0);
       ELSIF (p_qty_changed_flag = 'Y' AND  -- Case C4, C8, C11, C17
              p_raw_cost_changed_flag = 'Y' AND
              p_rw_cost_rate_changed_flag = 'N') THEN

              l_stage := 'PRC:4';
              --print_msg(l_stage);

              -- C4, C8, C11, C17: rederive cost rate override as
              -- raw cost / quantity
              IF (nvl(x_txn_plan_quantity, 0) - nvl(p_init_quantity,0)) <> 0 THEN
        x_txn_rw_cost_rate_override := (NVL(x_txn_raw_cost,0) - NVL(p_init_raw_cost,0)) /
                                             (nvl(x_txn_plan_quantity, 0) - nvl(p_init_quantity,0));
              END IF;
              x_txn_plan_quantity_addl := Nvl(x_txn_plan_quantity,0) -
                                          nvl(p_bl_quantity,0);
              x_txn_raw_cost_addl := nvl(x_txn_raw_cost,0) -
                                     nvl(p_bl_raw_cost,0);
       ELSIF (p_qty_changed_flag = 'N' AND  -- Case C21, C24, C28
              p_raw_cost_changed_flag = 'Y' AND
              p_rw_cost_rate_changed_flag = 'N') THEN
              -- qty not changed, cost has changed, rate not changed
              -- C21, C24, C28: rederive cost rate override as
              -- raw cost / quantity
              -- Do not rederive quantity.

              l_stage := 'PRC:6';
              --print_msg(l_stage);
          IF (nvl(x_txn_plan_quantity, 0) - nvl(p_init_quantity,0)) <> 0 THEN
                x_txn_rw_cost_rate_override := (NVL(x_txn_raw_cost,0) - NVL(p_init_raw_cost,0)) /
                                             (nvl(x_txn_plan_quantity, 0) - nvl(p_init_quantity,0));
              END IF;
              x_txn_plan_quantity_addl := Nvl(x_txn_plan_quantity,0) -
                                          nvl(p_bl_quantity,0);
              x_txn_raw_cost_addl := nvl(x_txn_raw_cost,0) -
                                     nvl(p_bl_raw_cost,0);

       ELSIF (p_qty_changed_flag = 'N' AND  -- Case C6, C19
               p_raw_cost_changed_flag = 'Y' AND
               p_rw_cost_rate_changed_flag = 'Y') Then
               -- qty not changed, cost has changed, rate changed
               -- C6, C19: rederive quantity as raw cost / raw cost rate

              l_stage := 'PRC:6.5';
              --print_msg(l_stage);
               IF NVL(x_txn_rw_cost_rate_override,
                  nvl(x_txn_raw_cost_rate,0)) <> 0 THEN

                 /* bug fix:5726773 */
 	         x_txn_plan_quantity := ((NVL(x_txn_raw_cost,0) - NVL(p_init_raw_cost,0))/
                                         nvl(x_txn_rw_cost_rate_override,
                                             nvl(x_txn_raw_cost_rate,0))) + nvl(p_init_quantity,0);
                  x_txn_plan_quantity := round_quantity( x_txn_plan_quantity);
                  x_txn_plan_quantity_addl := nvl(x_txn_plan_quantity,0) -
                                              nvl(p_bl_quantity,0);

               ELSE /* **** NOT SURE **** */
                  /* Bug fix:4244118 derive rate override when qty
                   * and amts were given */
                  IF (NVL(x_txn_rw_cost_rate_override,
                      nvl(x_txn_raw_cost_rate,0)) = 0 AND
                      nvl(x_txn_plan_quantity,0) <> 0 AND
                      nvl(x_txn_raw_cost,0) <> 0) THEN

                      print_msg('4244118: Setting the rate override');
              IF (nvl(x_txn_plan_quantity, 0) - nvl(p_init_quantity,0)) <> 0 THEN
                        x_txn_rw_cost_rate_override := (NVL(x_txn_raw_cost,0) - NVL(p_init_raw_cost,0)) /
                                             (nvl(x_txn_plan_quantity, 0) - nvl(p_init_quantity,0));
                      END IF;
                  END IF;
               END IF;
       ELSIF (p_qty_changed_flag = 'N' AND  -- Case C16, C22, C25 and C29
              p_raw_cost_changed_flag = 'N' AND
              p_rw_cost_rate_changed_flag = 'Y') THEN

              l_stage := 'PRC:7';
              --print_msg(l_stage);
              -- C16, C22, C25 and C29: rederive raw cost as
              -- raw cost rate * quantity
              IF x_txn_plan_quantity IS NOT NULL THEN
                 /* bug fix:5463690:5553549
		 x_txn_raw_cost := NVL(x_txn_plan_quantity ,0) *
                                   NVL(x_txn_rw_cost_rate_override,
                                       x_txn_raw_cost_rate);
                 */
 	         -- Note: Raw cost = ETC raw cost + Actual RawCost
 	         x_txn_raw_cost :=(NVL(p_init_raw_cost,0) +
 	                               ((NVL(x_txn_plan_quantity ,0) - NVL(p_init_quantity,0)) *
 	                                NVL(x_txn_rw_cost_rate_override,x_txn_raw_cost_rate)));

		 x_txn_raw_cost := pa_currency.round_trans_currency_amt1(
                                       x_txn_raw_cost,p_txn_currency_code);
                 x_txn_raw_cost_addl := nvl(x_txn_raw_cost,0) -
                                        nvl(p_bl_raw_cost,0);
              END IF;
       END IF; -- End of qty changed checks

       /* start of burden cost calculation -
        * change in the qty results in burden cost variation */

       IF ((p_qty_changed_flag  = 'Y' AND  -- Case C1, C4, C5, C14
            p_burden_cost_changed_flag = 'Y' AND
            p_b_cost_rate_changed_flag = 'Y') OR
           (p_qty_changed_flag = 'Y' AND   -- Case C2, C8, C9, C20
            p_burden_cost_changed_flag = 'Y' AND
            p_b_cost_rate_changed_flag = 'N') OR
           (p_qty_changed_flag = 'N' AND   -- Case C6, C15, C16, C26
            p_burden_cost_changed_flag = 'Y' AND
            p_b_cost_rate_changed_flag = 'Y') OR
           (p_qty_changed_flag = 'N' AND   -- Case C10, C21, C22, C30
            p_burden_cost_changed_flag = 'Y' AND
            p_b_cost_rate_changed_flag = 'N')) THEN

            l_stage := 'PRC:8';
            --print_msg(l_stage);

            -- In all of these cases, rederive the burden cost rate as
            -- burden cost / quantity.
            IF (Nvl(x_txn_plan_quantity,0) - nvl(p_init_quantity,0)) <> 0 THEN
               x_txn_b_cost_rate_override := (x_txn_burdened_cost - nvl(p_init_burdened_cost,0)) /
                                             (Nvl(x_txn_plan_quantity,0) - nvl(p_init_quantity,0));
            END IF;

       ELSIF ((p_qty_changed_flag = 'Y' AND   -- Case C3, C11, C12, C23
               p_burden_cost_changed_flag = 'N' AND
               p_b_cost_rate_changed_flag = 'Y') OR
              (p_qty_changed_flag = 'N' AND   -- Case C13, C24, C25, C31
               p_burden_cost_changed_flag = 'N' AND
               p_b_cost_rate_changed_flag = 'Y')) THEN

            -- In all of these cases, rederive the burden cost as
            -- burden cost rate * quantity.

            l_stage := 'PRC:9';
            print_msg(l_stage);
            IF (x_txn_plan_quantity IS NOT NULL OR
                p_qty_changed_flag = 'Y') THEN
                x_txn_burdened_cost := x_txn_plan_quantity *
                                           NVL(x_txn_b_cost_rate_override,
                                               x_txn_b_cost_rate);
                x_txn_burdened_cost := pa_currency.round_trans_currency_amt1(
                                          x_txn_burdened_cost,
                                          p_txn_currency_code);
                x_txn_burdened_cost_addl := nvl(x_txn_burdened_cost,0) -
                                            nvl(p_bl_burdened_cost,0);
            END IF;

            /* When burden rate is previously overridden, change in the raw
             * cost should re-derive the burden cost rate override. This is
             * the new rule enforced.   */

       ELSIF ((p_qty_changed_flag = 'Y' AND   -- Case C7, C17, C18, C27
               p_burden_cost_changed_flag = 'N' AND
               p_b_cost_rate_changed_flag = 'N') OR
              (p_qty_changed_flag = 'N' AND   -- Case C19, C28, C29, C32
               p_burden_cost_changed_flag = 'N' AND
               p_b_cost_rate_changed_flag = 'N')) THEN
              /* IF old burden cost rate override IS NOT NULL THEN
               * New burden cost rate override =
               *  ((new raw cost - actual raw cost) *
               *   ((old burden cost - actual burden cost) /
               *    (old raw cost - actual raw cost))) /
               *  (quantity - actual quantity) */
		If p_pa_debug_mode = 'Y' Then
 	        print_msg('PRC:9.1:p_curr_burden_rate['||p_curr_burden_rate||']');
 	        End If;
           IF p_curr_burden_rate IS NOT NULL AND (p_raw_cost_changed_flag = 'Y' OR p_rw_cost_rate_changed_flag = 'Y')  THEN
              IF ((nvl(p_bl_raw_cost,0) - nvl(p_init_raw_cost,0)) <> 0) AND
                 ((nvl(x_txn_plan_quantity, 0) - nvl(p_init_quantity, 0)) <> 0)
              THEN
                 x_txn_b_cost_rate_override:= ((nvl(x_txn_raw_cost,0) -
                                                nvl(p_init_raw_cost,0)) *
                                               ((nvl(p_bl_burdened_cost,0) -
                                                 nvl(p_init_burdened_cost,0))) /
                                                (nvl(p_bl_raw_cost,0) -
                                                 nvl(p_init_raw_cost,0))) /
                                              (nvl(x_txn_plan_quantity, 0) -
                                               nvl(p_init_quantity, 0));

		/* bug fix:5726773 */
 	               ELSIF p_curr_cost_rate is NOT NULL and NVL(p_curr_cost_rate,0) <> 0 Then
 	                         x_txn_b_cost_rate_override:= x_txn_rw_cost_rate_override *
 	                                                     (p_curr_burden_rate / p_curr_cost_rate) ;
              END IF;
           END IF;
       END IF;
    END IF;  -- end of cost type calculation

    IF p_budget_version_type IN ('REVENUE') THEN
       -- Start of revenue calculation
       l_stage := 'PRC:10';
       --print_msg(l_stage);
       -- qty is already modified in COST calculation so
       -- derive revenue based that qty
       IF ((p_rev_changed_flag = 'Y' AND  -- R1, R2
            p_qty_changed_flag = 'Y') OR
           (p_rev_changed_flag = 'Y' AND  -- R6
            p_qty_changed_flag = 'N' AND
            p_bill_rate_changed_flag = 'N')) THEN

          -- R1, R2, R6: rederive bill rate as revenue / quantity
          IF (Nvl(x_txn_plan_quantity,0) - nvl(p_init_quantity,0)) <> 0 THEN
             x_txn_bill_rate_override := (x_txn_revenue - nvl(p_init_revenue,0)) /
                                         (Nvl(x_txn_plan_quantity,0) - nvl(p_init_quantity,0));
          END IF;

       ELSIF (p_rev_changed_flag = 'Y' AND  -- R4
              p_qty_changed_flag = 'N' AND
              p_bill_rate_changed_flag = 'Y') THEN
          -- R4: rederive quantity as revenue / bill rate
          IF NVL(x_txn_bill_rate_override, nvl(x_txn_bill_rate,0)) <> 0 THEN
            x_txn_plan_quantity := (nvl(x_txn_revenue,0)-nvl(p_init_revenue,0)) /
                                    (NVL(x_txn_bill_rate_override,
                                        nvl(x_txn_bill_rate,0)))+ nvl(p_init_quantity,0);
             x_txn_plan_quantity := round_quantity(x_txn_plan_quantity);
             x_txn_plan_quantity_addl := nvl(x_txn_plan_quantity,0) -
                                             nvl(p_bl_quantity,0);
          END IF;

       ELSIF p_rev_changed_flag = 'N' --  R3, R5, R7, R8
       THEN

          -- R8: if qyt is not null or 0:
          --     if rev is null, clear bill rate
          --     if rev is 0, bill rate is set to 0
          --     if bill rate is null, clear rev
          --     if bill rate is 0, rev is set to 0
          IF p_qty_changed_flag = 'N' AND p_bill_rate_changed_flag = 'N' THEN
             IF Nvl(x_txn_plan_quantity,0) <> 0 THEN
                IF x_txn_revenue IS NULL THEN
                   x_txn_bill_rate_override := NULL;
                END IF;
                IF x_txn_bill_rate_override IS NULL THEN
                   x_txn_revenue := NULL;
                END IF;

                IF x_txn_revenue = 0 THEN
                   x_txn_bill_rate_override := 0;
                END IF;
                IF x_txn_bill_rate_override = 0 THEN
                   x_txn_revenue := 0;
                END IF;
             END IF;
          END IF;

          -- R3, R5, R7: rederive revenue as quantity * bill rate
          IF (p_qty_changed_flag = 'Y' OR
              (Nvl(x_txn_plan_quantity,0) <> 0)) THEN

             x_txn_revenue := NVL(x_txn_plan_quantity ,0) *
                              NVL(x_txn_bill_rate_override, x_txn_bill_rate);
             x_txn_revenue := pa_currency.round_trans_currency_amt1(
                                   x_txn_revenue,p_txn_currency_code);
             x_txn_revenue_addl := nvl(x_txn_revenue,0) -
                                   nvl(p_bl_revenue,0);
          END IF;
       END IF; -- end of checks
    END IF; -- Revenue - this is case of revenue only budget type

    IF p_budget_version_type IN ('ALL') THEN

       l_stage := 'PRC:11';
       --print_msg(l_stage);
       IF (p_qty_changed_flag = 'Y' AND  -- CR1, CR4, CR5, CR14
           p_rev_changed_flag = 'Y' AND
           p_bill_rate_changed_flag = 'Y') OR
          (p_qty_changed_flag = 'Y' AND  -- CR2, CR8, CR9, CR20
           p_rev_changed_flag = 'Y' AND
           p_bill_rate_changed_flag = 'N') OR
          (p_qty_changed_flag = 'N' AND  -- CR6, CR15, CR16, CR26
           p_rev_changed_flag = 'Y' AND
           p_bill_rate_changed_flag = 'Y') OR
          (p_qty_changed_flag = 'Y' AND  -- CR7, CR17, CR18, CR27
           p_rev_changed_flag = 'N' AND
           p_bill_rate_changed_flag = 'N') OR
          (p_qty_changed_flag = 'N' AND  -- CR10, CR21, CR22, CR30
           p_rev_changed_flag = 'Y' AND
           p_bill_rate_changed_flag = 'N') OR
          (p_qty_changed_flag = 'N' AND  -- CR19, CR28, CR29, CR32
           p_rev_changed_flag = 'N' AND
           p_bill_rate_changed_flag = 'N')THEN

           l_stage := 'PRC:12';
           --print_msg(l_stage);

           IF p_qty_changed_flag = 'N' AND  -- CR32
              p_rev_changed_flag = 'N' AND
              p_bill_rate_changed_flag = 'N' AND
              p_raw_cost_changed_flag = 'N' AND
              p_rw_cost_rate_changed_flag = 'N' THEN
              -- CR32: if qyt is not null or 0:
              --       if rev is null, clear bill rate
              --       if rev is 0, bill rate is set to 0
              --       if bill rate is null, clear rev
              --       if bill rate is 0, rev is set to 0
        l_stage := 'PRC:12.1';
            --print_msg(l_stage);
              IF Nvl(x_txn_plan_quantity,0) <> 0 THEN
                 IF x_txn_revenue IS NULL THEN
                    x_txn_bill_rate_override := NULL;
                 END IF;
                 IF x_txn_bill_rate_override IS NULL THEN
                    x_txn_revenue := NULL;
                 END IF;

                 IF x_txn_revenue = 0 THEN
                    x_txn_bill_rate_override := 0;
                 END IF;
                 IF x_txn_bill_rate_override = 0 THEN
                    x_txn_revenue := 0;
                 END IF;
              END IF;

       ELSIF p_rev_changed_flag = 'Y' Then
        l_stage := 'PRC:12.2';
                --print_msg(l_stage);
        If (nvl(x_txn_plan_quantity,0) - nvl(p_init_quantity,0)) <> 0 Then
            x_txn_bill_rate_override := (x_txn_revenue - nvl(p_init_revenue,0))/
                       (nvl(x_txn_plan_quantity,0) - nvl(p_init_quantity,0));
        End If;
       ELSIF ( p_qty_changed_flag = 'Y' and p_rev_changed_flag = 'N'
                   and p_bill_rate_changed_flag = 'N') Then
            l_stage := 'PRC:12.3';
                    --print_msg(l_stage);

                        NULL;
	/*
       ELSE
              -- CR1, CR4, CR5, CR14: rederive bill rate as revenue / quantity
              -- CR2, CR8, CR9, CR20: rederive bill rate as revenue / quantity
              -- CR6, CR15, CR16, CR26: rederive bill rate as revenue / quantity
              -- CR7, CR17, CR18, CR27: rederive bill rate as revenue / quantity
              -- CR10, CR21, CR22,CR30: rederive bill rate as revenue / quantity
              -- CR19, CR28, CR29: rederive bill rate as revenue / quantity
        	l_stage := 'PRC:12.4';
                --print_msg(l_stage);
                If (nvl(x_txn_plan_quantity,0) - nvl(p_init_quantity,0)) <> 0 Then
                        x_txn_bill_rate_override := (x_txn_revenue - nvl(p_init_revenue,0))/
                                           (nvl(x_txn_plan_quantity,0) - nvl(p_init_quantity,0));
                End If;
	 */
        END IF;

       ELSIF (p_qty_changed_flag = 'Y' AND  -- CR3, CR11, CR12, CR23
              p_rev_changed_flag = 'N' AND
              p_bill_rate_changed_flag = 'Y') OR
             (p_qty_changed_flag = 'N' AND  -- CR13, CR24, CR25, CR31
              p_rev_changed_flag = 'N' AND
              p_bill_rate_changed_flag = 'Y') THEN

           l_stage := 'PRC:12.5';
           --print_msg(l_stage);

           -- CR3, CR11, CR12, CR23: rederive revenue as quantity * bill rate
           -- CR13, CR24, CR25, CR31: rederive revenue as quantity * bill rate
           x_txn_revenue := NVL(x_txn_plan_quantity ,0) *
                            NVL(x_txn_bill_rate_override, x_txn_bill_rate);
           x_txn_revenue := pa_currency.round_trans_currency_amt1(
                                 x_txn_revenue,p_txn_currency_code);
           x_txn_revenue_addl := nvl(x_txn_revenue,0) - nvl(p_bl_revenue,0);

       END IF; -- end of checks
    END IF; -- end of budget_version_type ALL

    IF (p_budget_version_type IN ('REVENUE', 'ALL')) THEN --{

      IF (p_rev_changed_flag = 'N' AND p_bill_rate_changed_flag = 'N' )
     AND (p_raw_cost_changed_flag = 'Y'    -- Case CR28
              OR p_rw_cost_rate_changed_flag = 'Y'  -- Case CR7, CR19, C29
         ) Then
    /* Change in the raw cost should re-derive the revenue by
         * calculating the bill rate markup percentage. This is done
         * based on the formula
     * IF old bill rate override is not null then
     * New bill rate override =
     * ((new raw cost - actual raw cost) *
     *  ((old revenue - actual revenue) /
     *   (old raw cost - actual raw cost)) /
     * (quantity - actual quatity)                             */

       IF p_curr_bill_rate IS NOT NULL THEN
          IF ((nvl(p_bl_raw_cost,0) - nvl(p_init_raw_cost,0)) <> 0) AND
             ((nvl(x_txn_plan_quantity, 0) - nvl(p_init_quantity, 0)) <> 0)
          THEN
      l_stage := 'PRC:12.6';
           --print_msg(l_stage);
          x_txn_bill_rate_override := ((nvl(x_txn_raw_cost,0) -
                                        nvl(p_init_raw_cost,0)) *
                                       ((nvl(p_bl_revenue,0) -
                                         nvl(p_init_revenue,0))) /
                                        (nvl(p_bl_raw_cost,0) -
                                         nvl(p_init_raw_cost,0))) /
                                      (nvl(x_txn_plan_quantity, 0) -
                                       nvl(p_init_quantity, 0));
          END IF;
       ELSE
          -- New bill rate override = Markup % + 1
          -- (ensure that it is applied on the new raw cost,
          -- which should be equaled to qty)
          -- TBD
          null;
       END IF;
      END IF;
    END IF; --}

    /* rederive the additionals*/
    x_txn_plan_quantity_addl := nvl(x_txn_plan_quantity,0) -
                                nvl(p_bl_quantity,0);
    x_txn_raw_cost_addl      := nvl(x_txn_raw_cost,0) -
                                nvl(p_bl_raw_cost,0);
    x_txn_burdened_cost_addl := nvl(x_txn_burdened_cost,0) -
                                nvl(p_bl_burdened_cost,0);
    x_txn_revenue_addl       := nvl(x_txn_revenue,0) -
                                nvl(p_bl_revenue,0);

    --print_msg('Finally set the addl columns to NULL if ithas zeros');
    /* set addl columns to NULL if it has zero */
    /* Performance bug fix: 4208217
     * avoid hitting dual wherever possible */

    IF x_txn_plan_quantity_addl = 0 Then
       x_txn_plan_quantity_addl := NULL;
    End If;
    IF x_txn_raw_cost_addl = 0 then
       x_txn_raw_cost_addl := NULL;
    End If;
    IF x_txn_burdened_cost_addl = 0 then
       x_txn_burdened_cost_addl := NULL;
    End If;
    If x_txn_revenue_addl = 0 Then
       x_txn_revenue_addl := NULL;
    End If;
     If P_PA_DEBUG_MODE = 'Y' Then
    print_msg('Leaving Apply_RATE_BASE_precedence API with status [S]');
	End if;
EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END Apply_RATE_BASE_precedence;

/* This API initializes the global variables  for the given budget version Id */
PROCEDURE Init_Globals(
        p_budget_version_id  IN NUMBER
        ,p_source_context    IN  VARCHAR2
        ,x_return_status     OUT NOCOPY VARCHAR2
        ) IS
    l_agreement_cur_code  Varchar2(100);
    l_return_status  Varchar2(100);
    l_msg_count Number;
    l_msg_data  Varchar2(100);
BEGIN
    x_return_status  := 'S';
    If P_PA_DEBUG_MODE = 'Y' Then
    print_msg('Entered Init_Globals API');
    End if;
    IF p_budget_version_id IS NOT NULL Then
                /*
                Select project option attibutes required for RATE API and assign to local variables
                This only needs to be done once during the procedure
                */
                ProjFpOptRec := NULL;
                OPEN  get_proj_fp_options_csr(p_budget_version_id);
                FETCH get_proj_fp_options_csr INTO ProjFpOptRec;
                CLOSE get_proj_fp_options_csr;
		If P_PA_DEBUG_MODE = 'Y' Then
                print_msg('Assigning project options cursorval to globla variables');
		End if;
                g_fp_budget_version_type           := ProjFpOptRec.version_type;
                g_bv_resource_list_id              := ProjFpOptRec.resource_list_id;
                g_bv_approved_rev_flag             := ProjFpOptRec.approved_rev_plan_type_flag;
                g_fp_multi_curr_enabled            := ProjFpOptRec.plan_in_multi_curr_flag;
                g_spread_from_date                 := ProjFpOptRec.etc_start_date;
                g_wp_version_flag                  := ProjFpOptRec.wp_version_flag;
                g_track_wp_costs_flag              := ProjFpOptRec.track_workplan_costs_flag;
                g_proj_structure_ver_id            := ProjFpOptRec.project_structure_version_id;
                g_budget_version_id                := p_budget_version_id;
                g_project_id                       := ProjFpOptRec.project_id;
                g_time_phased_code                 := ProjFpOptRec.time_phased_code;
                g_project_currency_code            := ProjFpOptRec.project_currency_code;
                g_projfunc_currency_code           := ProjFpOptRec.projfunc_currency_code;
                g_project_name                     := ProjFpOptRec.project_name;
                g_source_context                   := p_source_context;
                g_revenue_generation_method        := NVL(PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(g_project_id),'W');
            g_ciId                             := ProjFpOptRec.CiId;
            g_baseline_funding_flag            := ProjFpOptRec.baseline_funding_flag;
        g_Plan_Class_Type                  := ProjFpOptRec.Plan_Class_Type;

                /* Get the Agreement currency details if the budget is of Change Order*/
                --print_msg('Calling Get_Agreement_Details API');
                Get_Agreement_Details
                (p_budget_version_id  => p_budget_version_id
                ,x_agr_curr_code      => l_agreement_cur_code
                ,x_return_status      => l_return_status );

                /* Initialize the mrc check flag */
                CHECK_MRC_INSTALLED;

                --print_msg('End of calling Get_Agreement_Details retSts['||l_return_status||']AgrCur['||l_agreement_cur_code||']');
                IF l_return_status <> 'S' Then
                        x_return_status := l_return_status;
                END IF;

        /* mrc enhancements */
        /**MRC Elimination Changes:
        IF ( NVL(g_wp_version_flag,'N') = 'N'
                 AND NVL(g_mrc_installed_flag,'N') = 'Y'
                 AND PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A'
             AND NVL(g_conv_rates_required_flag,'Y') = 'Y' ) Then
            -- Initialize the populate mrc plsql tabs flag
            G_populate_mrc_tab_flag  := 'Y';
        Else
            G_populate_mrc_tab_flag  := 'N';
        End If;
	**/
	G_populate_mrc_tab_flag  := 'N';
	If P_PA_DEBUG_MODE = 'Y' Then
            print_msg('Calling pa_fp_gen_amount_utils.get_plan_version_dtls ');
	End If;
            pa_fp_gen_amount_utils.get_plan_version_dtls
                    (p_project_id         => g_project_id,
                    p_budget_version_id  => g_budget_version_id,
                    x_fp_cols_rec        => g_fp_cols_rec,
                    x_return_status      => l_return_status,
                    x_msg_count          => l_msg_count,
                    x_msg_data           => l_msg_data
                    );
	   If P_PA_DEBUG_MODE = 'Y' Then
            print_msg('Printing all global variables: g_bv_resource_list_id['||g_bv_resource_list_id||']g_bv_approved_rev_flag['||g_bv_approved_rev_flag||']');
            print_msg('TimePhas['||g_time_phased_code||']g_fp_multi_curr_enabled['||g_fp_multi_curr_enabled||']g_spread_from_date['||g_spread_from_date||']');
            print_msg('g_wp_version_flag['||g_wp_version_flag||']g_fp_budget_version_typei['||g_fp_budget_version_type||']');
            print_msg('g_track_wp_costs_flag['||g_track_wp_costs_flag||']G_AGR_CONV_REQD_FLAG['||G_AGR_CONV_REQD_FLAG||']');
            print_msg('MRCInstFlag['||g_mrc_installed_flag||']G_baseline_FundingFlg['||g_baseline_funding_flag||']');
            print_msg('g_rev_generation_method['||g_revenue_generation_method||']g_CiId['||g_CiId||']');
        print_msg('G_populate_mrc_tab_flag['||G_populate_mrc_tab_flag||']g_Plan_Class_Type['||g_Plan_Class_Type||']');
    	print_msg('ReturnStatus of Init_Globals ['||x_return_status||']');
	 End if;

        END IF;
EXCEPTION
    WHEN OTHERS THEN
        print_msg('ERROR FROM Init_Globals ['||SQLCODE||SQLERRM||']');
        RAISE;

END Init_Globals;


/* Added for bug 5028631 */
/* During calculation process, if nothing has changed, i.e quantity,rates and amounts
 * donot change. then calculate api skips / ignores these planning resource.
 * But there is a customer requirement to call the client extension api for skipped
 * records. This API copies the budget lines into fp rollup tmp table for the skipped
 * resources and calls client extension api
 */
PROCEDURE Process_skipped_records
    	( p_budget_version_id              IN  NUMBER
	,p_calling_mode               	   IN  VARCHAR2
        ,p_source_context             	   IN  VARCHAR2
        ,x_return_status                 OUT NOCOPY VARCHAR2
        ,x_msg_count                     OUT NOCOPY NUMBER
        ,x_msg_data                      OUT NOCOPY VARCHAR2) IS

    l_debug_mode        VARCHAR2(30);
    l_stage             NUMBER;
    l_count             NUMBER;
    l_msg_index_out     NUMBER;
BEGIN

        x_return_status := 'S';
    IF p_pa_debug_mode = 'Y' Then
        	print_msg(to_char(l_stage)||'Entered PA_FP_CALC_PLAN_PKG.Process_skipped_records');
            pa_debug.init_err_stack('PA_FP_CALC_PLAN_PKG.Process_skipped_records');
    End If;
	/***
    If P_PA_DEBUG_MODE = 'Y' Then
      for i in (select * from pa_fp_spread_calc_tmp ) LOOP
       print_msg('IN params ResId['||i.resource_assignment_id||']TxnCur['||i.txn_currency_code||']RefrFlag['||i.refresh_rates_flag||']');
       print_msg('RefrConvFlag['||i.refresh_conv_rates_flag||']gSprdFromDt['||g_spread_from_date||']gLnSD['||i.start_date||']');
       print_msg('gLineEnDate['||i.end_date||']massAdflag['||i.mass_adjust_flag||']mfcCstFlag['||i.mfc_cost_refresh_flag||']skipFlag['||i.skip_record_flag||']');
      end loop;
    END IF;
	**/


    g_stage := 'Process_skipped_records : populate_rollup_tmp';

       INSERT INTO pa_fp_rollup_tmp (
    budget_version_id
        ,resource_assignment_id
       ,start_date
       ,end_date
       ,period_name
       ,quantity
       ,projfunc_raw_cost
       ,projfunc_burdened_cost
       ,projfunc_revenue
       ,cost_rejection_code
       ,revenue_rejection_code
       ,burden_rejection_code
       ,projfunc_currency_code
       ,projfunc_cost_rate_type
       ,projfunc_cost_exchange_rate
       ,projfunc_cost_rate_date_type
       ,projfunc_cost_rate_date
       ,projfunc_rev_rate_type
       ,projfunc_rev_exchange_rate
       ,projfunc_rev_rate_date_type
       ,projfunc_rev_rate_date
       ,project_currency_code
       ,project_cost_rate_type
       ,project_cost_exchange_rate
       ,project_cost_rate_date_type
       ,project_cost_rate_date
       ,project_raw_cost
       ,project_burdened_cost
       ,project_rev_rate_type
       ,project_rev_exchange_rate
       ,project_rev_rate_date_type
       ,project_rev_rate_date
       ,project_revenue
       ,txn_currency_code
       ,txn_raw_cost
       ,txn_burdened_cost
       ,txn_revenue
       ,budget_line_id
       ,init_quantity
       ,txn_init_raw_cost
       ,txn_init_burdened_cost
       ,txn_init_revenue
       ,bill_markup_percentage
       ,bill_rate
       ,cost_rate
       ,rw_cost_rate_override
       ,burden_cost_rate
       ,bill_rate_override
       ,burden_cost_rate_override
       ,cost_ind_compiled_set_id
       ,init_raw_cost
       ,init_burdened_cost
       ,init_revenue
       ,project_init_raw_cost
       ,project_init_burdened_cost
       ,project_init_revenue
       ,billable_flag
       )
       ( SELECT /*+ INDEX(BL PA_BUDGET_LINES_U1) */
	bl.budget_version_id
       ,bl.resource_assignment_id
       ,bl.start_date
       ,bl.end_date
       ,bl.period_name
       ,bl.quantity
       ,bl.raw_cost
       ,bl.burdened_cost
       ,bl.revenue
       ,bl.cost_rejection_code
       ,bl.revenue_rejection_code
       ,bl.burden_rejection_code
       ,bl.projfunc_currency_code
       ,bl.projfunc_cost_rate_type
       ,bl.projfunc_cost_exchange_rate
       ,bl.projfunc_cost_rate_date_type
       ,bl.projfunc_cost_rate_date
       ,bl.projfunc_rev_rate_type
       ,bl.projfunc_rev_exchange_rate
       ,bl.projfunc_rev_rate_date_type
       ,bl.projfunc_rev_rate_date
       ,bl.project_currency_code
       ,bl.project_cost_rate_type
       ,bl.project_cost_exchange_rate
       ,bl.project_cost_rate_date_type
       ,bl.project_cost_rate_date
       ,bl.project_raw_cost
       ,bl.project_burdened_cost
       ,bl.project_rev_rate_type
       ,bl.project_rev_exchange_rate
       ,bl.project_rev_rate_date_type
       ,bl.project_rev_rate_date
       ,bl.project_revenue
       ,bl.txn_currency_code
       ,bl.txn_raw_cost
       ,bl.txn_burdened_cost
       ,bl.txn_revenue
       ,bl.budget_line_id
       ,bl.init_quantity
       ,bl.txn_init_raw_cost
       ,bl.txn_init_burdened_cost
       ,bl.txn_init_revenue
       ,bl.txn_markup_percent
       ,bl.txn_standard_bill_rate
       ,bl.txn_standard_cost_rate
       ,bl.txn_cost_rate_override
       ,bl.burden_cost_rate
       ,bl.txn_bill_rate_override
       ,bl.burden_cost_rate_override
       ,bl.cost_ind_compiled_set_id
       ,bl.init_raw_cost
       ,bl.init_burdened_cost
       ,bl.init_revenue
       ,bl.project_init_raw_cost
       ,bl.project_init_burdened_cost
       ,bl.project_init_revenue
       ,tmp.billable_flag
       FROM pa_budget_lines bl
           ,pa_resource_assignments ra
       ,pa_fp_spread_calc_tmp tmp
	,pa_fp_rollup_tmp rlp --Bug 5203868
       WHERE tmp.budget_version_id = p_budget_version_id
           AND tmp.resource_assignment_id = ra.resource_assignment_id
	   AND  bl.resource_assignment_id = tmp.resource_assignment_id
	   AND   bl.txn_currency_code = tmp.txn_currency_code
	   AND   NVL(tmp.skip_record_flag,'N') = 'Y'
	   AND   ((p_calling_mode = 'PROCESS_CST_REV_MIX'
		  and nvl(tmp.processed_flag,'N') = 'Y' )
		  OR
		  p_calling_mode <> 'PROCESS_CST_REV_MIX'
		 )
	   AND  ((p_source_context = 'BUDGET_LINE'
		 and bl.start_date BETWEEN tmp.start_date and tmp.end_date)
		 OR
		 p_source_context <> 'BUDGET_LINE'
		)
	   --Bug 5203868. Replaced the NOT EXISTS with the following
                AND   rlp.resource_assignment_id(+)=tmp.resource_assignment_id
                AND   rlp.txn_currency_code(+)=tmp.txn_currency_code
                AND   rlp.rowid IS NULL
             /* Commenting below code for bug 5203868
               AND   NOT EXISTS
                (select null
                 from pa_fp_rollup_tmp rl1
                 Where rl1.resource_assignment_id = tmp.resource_assignment_id
                 and rl1.txn_currency_code = tmp.txn_currency_code
                )
             */
    	);

      x_return_status := 'S';
    IF p_pa_debug_mode = 'Y' Then
	print_msg('Process_skipped_records :Number of records inserted['||sql%rowcount||']');
      print_msg('Process_skipped_records: x_return_status : '||x_return_status);
      print_msg('Process_skipped_records: Leaving Process_skipped_records');
            pa_debug.reset_err_stack;
    End If;
EXCEPTION
    WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data := sqlcode||sqlerrm;
            fnd_msg_pub.add_exc_msg
            ( p_pkg_name       => 'PA_FP_CALC_PLAN_PKG'
                ,p_procedure_name => 'Process_skipped_records' );
            l_stage := 2120;
            print_msg(to_char(l_stage)||' substr(SQLERRM,1,240) => '|| substr(SQLERRM,1,240));
        IF p_pa_debug_mode = 'Y' Then
                pa_debug.reset_err_stack;
        End If;
            RAISE;

END Process_skipped_records;
/* End for bug 5028631 */


END PA_FP_CALC_PLAN_PKG;

/
