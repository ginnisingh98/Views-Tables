--------------------------------------------------------
--  DDL for Package Body PA_FUNDS_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FUNDS_CONTROL_PKG" as
-- $Header: PABCFCKB.pls 120.43.12010000.7 2010/06/18 10:23:40 prabsing ship $

/**-----------------------------------------------------------------------
--- Declare Global Variables
----------------------------------------------------------------------***/
	--g_debug_mode            VARCHAR2(10); -- Moved to Spec ..
	g_mode			VARCHAR2(100);
	g_calling_module	VARCHAR2(100);
	g_partial_flag		VARCHAR2(100);
	g_return_status         VARCHAR2(1000);
	g_pa_gl_return_status   VARCHAR2(1000);
	g_pa_cbc_return_status  VARCHAR2(1000);
	g_doc_type		VARCHAR2(1000);
	g_error_stage		VARCHAR2(1000);
	g_error_msg		VARCHAR2(2000);
	g_packet_id		PA_BC_PACKETS.PACKET_ID%TYPE;
	g_cbc_packet_id		PA_BC_PACKETS.PACKET_ID%TYPE;
        g_project_id    	PA_BC_PACKETS.PROJECT_ID%TYPE := null;
        g_task_id       	PA_BC_PACKETS.TASK_ID%type := null;
	g_top_task_id		PA_BC_PACKETS.TOP_TASK_ID%type := null;
        g_bdgt_version_id       PA_BC_PACKETS.budget_version_id%type := null;
        g_bud_task_id           PA_BC_PACKETS.TASK_ID%type := null;
        g_rlmi                  PA_BC_PACKETS.resource_list_member_id%type := null;
        g_bud_rlmi              PA_BC_PACKETS.resource_list_member_id%type := null;
        g_prlmi                 PA_BC_PACKETS.resource_list_member_id%type := null;
        g_entry_level_code      VARCHAR2(200) := null;
        g_start_date            DATE := null;
        g_end_date              DATE := null;
        g_time_phase_code       VARCHAR2(20) := null;
        g_pre_project_id        PA_BC_PACKETS.PROJECT_ID%TYPE := null;
        g_pre_task_id           PA_BC_PACKETS.TASK_ID%type := null;
        g_pre_top_task_id       PA_BC_PACKETS.TOP_TASK_ID%type := null;
        g_pre_bdgt_version_id   PA_BC_PACKETS.budget_version_id%type := null;
        g_pre_bud_task_id       PA_BC_PACKETS.TASK_ID%type := null;
        g_pre_rlmi              PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pre_bud_rlmi          PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pre_prlmi             PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pre_entry_level_code  VARCHAR2(200) := null;
        g_pre_start_date        DATE := null;
        g_pre_end_date          DATE := null;
        g_pre_time_phase_code   VARCHAR2(20) := null;
	g_bdgt_ccid		PA_BC_PACKETS.budget_ccid%type := null;
	g_pre_bdgt_ccid		PA_BC_PACKETS.budget_ccid%type := null;
        g_r_budget_posted       PA_BC_PACKETS.res_budget_posted%type := null;
        g_r_actual_posted 	PA_BC_PACKETS.res_budget_posted%type := null;
        g_r_enc_posted          PA_BC_PACKETS.res_budget_posted%type := null;
        g_r_enc_approved 	PA_BC_PACKETS.res_budget_posted%type := null;
        g_r_enc_pending 	PA_BC_PACKETS.res_budget_posted%type := null;
        g_r_actual_approved 	PA_BC_PACKETS.res_budget_posted%type := null;
        g_r_actual_pending 	PA_BC_PACKETS.res_budget_posted%type := null;
        g_rg_budget_posted      PA_BC_PACKETS.res_budget_posted%type := null;
        g_rg_actual_posted      PA_BC_PACKETS.res_budget_posted%type := null;
        g_rg_enc_posted         PA_BC_PACKETS.res_budget_posted%type := null;
        g_rg_enc_approved       PA_BC_PACKETS.res_budget_posted%type := null;
        g_rg_enc_pending        PA_BC_PACKETS.res_budget_posted%type := null;
        g_rg_actual_approved    PA_BC_PACKETS.res_budget_posted%type := null;
        g_rg_actual_pending     PA_BC_PACKETS.res_budget_posted%type := null;
        g_t_budget_posted       PA_BC_PACKETS.res_budget_posted%type := null;
        g_t_actual_posted       PA_BC_PACKETS.res_budget_posted%type := null;
        g_t_enc_posted          PA_BC_PACKETS.res_budget_posted%type := null;
        g_t_enc_approved        PA_BC_PACKETS.res_budget_posted%type := null;
        g_t_enc_pending         PA_BC_PACKETS.res_budget_posted%type := null;
        g_t_actual_approved     PA_BC_PACKETS.res_budget_posted%type := null;
        g_t_actual_pending      PA_BC_PACKETS.res_budget_posted%type := null;
        g_tt_budget_posted      PA_BC_PACKETS.res_budget_posted%type := null;
        g_tt_actual_posted      PA_BC_PACKETS.res_budget_posted%type := null;
        g_tt_enc_posted         PA_BC_PACKETS.res_budget_posted%type := null;
        g_tt_enc_approved       PA_BC_PACKETS.res_budget_posted%type := null;
        g_tt_enc_pending        PA_BC_PACKETS.res_budget_posted%type := null;
        g_tt_actual_approved    PA_BC_PACKETS.res_budget_posted%type := null;
        g_tt_actual_pending     PA_BC_PACKETS.res_budget_posted%type := null;
        g_p_budget_posted       PA_BC_PACKETS.res_budget_posted%type := null;
        g_p_actual_posted       PA_BC_PACKETS.res_budget_posted%type := null;
        g_p_enc_posted          PA_BC_PACKETS.res_budget_posted%type := null;
        g_p_enc_approved        PA_BC_PACKETS.res_budget_posted%type := null;
        g_p_enc_pending         PA_BC_PACKETS.res_budget_posted%type := null;
        g_p_actual_approved     PA_BC_PACKETS.res_budget_posted%type := null;
        g_p_actual_pending      PA_BC_PACKETS.res_budget_posted%type := null;
	g_r_pkt_amt		PA_BC_PACKETS.res_budget_posted%type := null;
	g_rg_pkt_amt            PA_BC_PACKETS.res_budget_posted%type := null;
	g_t_pkt_amt             PA_BC_PACKETS.res_budget_posted%type := null;
	g_tt_pkt_amt            PA_BC_PACKETS.res_budget_posted%type := null;
	g_p_pkt_amt             PA_BC_PACKETS.res_budget_posted%type := null;
	g_p_acct_pkt_amt        PA_BC_PACKETS.res_budget_posted%type := null;
	g_r_base_amt		PA_BC_PACKETS.res_budget_posted%type := null;
	g_rg_base_amt		PA_BC_PACKETS.res_budget_posted%type := null;
	g_t_base_amt		PA_BC_PACKETS.res_budget_posted%type := null;
	g_tt_base_amt		PA_BC_PACKETS.res_budget_posted%type := null;
	g_p_base_amt		PA_BC_PACKETS.res_budget_posted%type := null;
	g_p_acct_base_amt	PA_BC_PACKETS.res_budget_posted%type := null;
	g_p_acct_enc_approved	PA_BC_PACKETS.res_budget_posted%type := null;
	g_p_acct_actual_approved PA_BC_PACKETS.res_budget_posted%type := null;
	g_exp_project_id	pa_bc_packets.project_id%type := null;
	g_exp_burden_method     pa_bc_packets.expenditure_type%type := null;

	-----These variables are added for performance testing
        g_bal_r_project_id            PA_BC_PACKETS.PROJECT_ID%TYPE := null;
        g_bal_r_task_id               PA_BC_PACKETS.TASK_ID%type := null;
        g_bal_r_top_task_id           PA_BC_PACKETS.TOP_TASK_ID%type := null;
        g_bal_r_bdgt_version_id       PA_BC_PACKETS.budget_version_id%type := null;
        g_bal_r_bud_task_id           PA_BC_PACKETS.TASK_ID%type := null;
        g_bal_r_rlmi                  PA_BC_PACKETS.resource_list_member_id%type := null;
        g_bal_r_bud_rlmi              PA_BC_PACKETS.resource_list_member_id%type := null;
        g_bal_r_prlmi                 PA_BC_PACKETS.resource_list_member_id%type := null;
        g_bal_r_entry_level_code      VARCHAR2(200) := null;
        g_bal_r_start_date            DATE := null;
        g_bal_r_end_date              DATE := null;
        g_bal_r_time_phase_code       VARCHAR2(20) := null;

        g_pkt_r_project_id            PA_BC_PACKETS.PROJECT_ID%TYPE := null;
        g_pkt_r_task_id               PA_BC_PACKETS.TASK_ID%type := null;
        g_pkt_r_top_task_id           PA_BC_PACKETS.TOP_TASK_ID%type := null;
        g_pkt_r_bdgt_version_id       PA_BC_PACKETS.budget_version_id%type := null;
        g_pkt_r_bud_task_id           PA_BC_PACKETS.TASK_ID%type := null;
        g_pkt_r_rlmi                  PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_r_bud_rlmi              PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_r_prlmi                 PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_r_entry_level_code      VARCHAR2(200) := null;
        g_pkt_r_start_date            DATE := null;
        g_pkt_r_end_date              DATE := null;
        g_pkt_r_time_phase_code       VARCHAR2(20) := null;

        g_bal_rg_project_id            PA_BC_PACKETS.PROJECT_ID%TYPE := null;
        g_bal_rg_task_id               PA_BC_PACKETS.TASK_ID%type := null;
        g_bal_rg_top_task_id           PA_BC_PACKETS.TOP_TASK_ID%type := null;
        g_bal_rg_bdgt_version_id       PA_BC_PACKETS.budget_version_id%type := null;
        g_bal_rg_bud_task_id           PA_BC_PACKETS.TASK_ID%type := null;
        g_bal_rg_rlmi                  PA_BC_PACKETS.resource_list_member_id%type := null;
        g_bal_rg_bud_rlmi              PA_BC_PACKETS.resource_list_member_id%type := null;
        g_bal_rg_prlmi                 PA_BC_PACKETS.resource_list_member_id%type := null;
        g_bal_rg_entry_level_code      VARCHAR2(200) := null;
        g_bal_rg_start_date            DATE := null;
        g_bal_rg_end_date              DATE := null;
        g_bal_rg_time_phase_code       VARCHAR2(20) := null;

        g_pkt_rg_project_id            PA_BC_PACKETS.PROJECT_ID%TYPE := null;
        g_pkt_rg_task_id               PA_BC_PACKETS.TASK_ID%type := null;
        g_pkt_rg_top_task_id           PA_BC_PACKETS.TOP_TASK_ID%type := null;
        g_pkt_rg_bdgt_version_id       PA_BC_PACKETS.budget_version_id%type := null;
        g_pkt_rg_bud_task_id           PA_BC_PACKETS.TASK_ID%type := null;
        g_pkt_rg_rlmi                  PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_rg_bud_rlmi              PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_rg_prlmi                 PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_rg_entry_level_code      VARCHAR2(200) := null;
        g_pkt_rg_start_date            DATE := null;
        g_pkt_rg_end_date              DATE := null;
        g_pkt_rg_time_phase_code       VARCHAR2(20) := null;

        g_bal_t_project_id            PA_BC_PACKETS.PROJECT_ID%TYPE := null;
        g_bal_t_task_id               PA_BC_PACKETS.TASK_ID%type := null;
        g_bal_t_top_task_id           PA_BC_PACKETS.TOP_TASK_ID%type := null;
        g_bal_t_bdgt_version_id       PA_BC_PACKETS.budget_version_id%type := null;
        g_bal_t_bud_task_id           PA_BC_PACKETS.TASK_ID%type := null;
        g_bal_t_rlmi                  PA_BC_PACKETS.resource_list_member_id%type := null;
        g_bal_t_bud_rlmi              PA_BC_PACKETS.resource_list_member_id%type := null;
        g_bal_t_prlmi                 PA_BC_PACKETS.resource_list_member_id%type := null;
        g_bal_t_entry_level_code      VARCHAR2(200) := null;
        g_bal_t_start_date            DATE := null;
        g_bal_t_end_date              DATE := null;
        g_bal_t_time_phase_code       VARCHAR2(20) := null;

        g_pkt_t_project_id            PA_BC_PACKETS.PROJECT_ID%TYPE := null;
        g_pkt_t_task_id               PA_BC_PACKETS.TASK_ID%type := null;
        g_pkt_t_top_task_id           PA_BC_PACKETS.TOP_TASK_ID%type := null;
        g_pkt_t_bdgt_version_id       PA_BC_PACKETS.budget_version_id%type := null;
        g_pkt_t_bud_task_id           PA_BC_PACKETS.TASK_ID%type := null;
        g_pkt_t_rlmi                  PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_t_bud_rlmi              PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_t_prlmi                 PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_t_entry_level_code      VARCHAR2(200) := null;
        g_pkt_t_start_date            DATE := null;
        g_pkt_t_end_date              DATE := null;
        g_pkt_t_time_phase_code       VARCHAR2(20) := null;

        g_bal_tt_project_id            PA_BC_PACKETS.PROJECT_ID%TYPE := null;
        g_bal_tt_task_id               PA_BC_PACKETS.TASK_ID%type := null;
        g_bal_tt_top_task_id           PA_BC_PACKETS.TOP_TASK_ID%type := null;
        g_bal_tt_bdgt_version_id       PA_BC_PACKETS.budget_version_id%type := null;
        g_bal_tt_bud_task_id           PA_BC_PACKETS.TASK_ID%type := null;
        g_bal_tt_rlmi                  PA_BC_PACKETS.resource_list_member_id%type := null;
        g_bal_tt_bud_rlmi              PA_BC_PACKETS.resource_list_member_id%type := null;
        g_bal_tt_prlmi                 PA_BC_PACKETS.resource_list_member_id%type := null;
        g_bal_tt_entry_level_code      VARCHAR2(200) := null;
        g_bal_tt_start_date            DATE := null;
        g_bal_tt_end_date              DATE := null;
        g_bal_tt_time_phase_code       VARCHAR2(20) := null;

        g_pkt_tt_project_id            PA_BC_PACKETS.PROJECT_ID%TYPE := null;
        g_pkt_tt_task_id               PA_BC_PACKETS.TASK_ID%type := null;
        g_pkt_tt_top_task_id           PA_BC_PACKETS.TOP_TASK_ID%type := null;
        g_pkt_tt_bdgt_version_id       PA_BC_PACKETS.budget_version_id%type := null;
        g_pkt_tt_bud_task_id           PA_BC_PACKETS.TASK_ID%type := null;
        g_pkt_tt_rlmi                  PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_tt_bud_rlmi              PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_tt_prlmi                 PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_tt_entry_level_code      VARCHAR2(200) := null;
        g_pkt_tt_start_date            DATE := null;
        g_pkt_tt_end_date              DATE := null;
        g_pkt_tt_time_phase_code       VARCHAR2(20) := null;

        g_bal_p_project_id            PA_BC_PACKETS.PROJECT_ID%TYPE := null;
        g_bal_p_task_id               PA_BC_PACKETS.TASK_ID%type := null;
        g_bal_p_top_task_id           PA_BC_PACKETS.TOP_TASK_ID%type := null;
        g_bal_p_bdgt_version_id       PA_BC_PACKETS.budget_version_id%type := null;
        g_bal_p_bud_task_id           PA_BC_PACKETS.TASK_ID%type := null;
        g_bal_p_rlmi                  PA_BC_PACKETS.resource_list_member_id%type := null;
        g_bal_p_bud_rlmi              PA_BC_PACKETS.resource_list_member_id%type := null;
        g_bal_p_prlmi                 PA_BC_PACKETS.resource_list_member_id%type := null;
        g_bal_p_entry_level_code      VARCHAR2(200) := null;
        g_bal_p_start_date            DATE := null;
        g_bal_p_end_date              DATE := null;
        g_bal_p_time_phase_code       VARCHAR2(20) := null;

        g_pkt_p_project_id            PA_BC_PACKETS.PROJECT_ID%TYPE := null;
        g_pkt_p_task_id               PA_BC_PACKETS.TASK_ID%type := null;
        g_pkt_p_top_task_id           PA_BC_PACKETS.TOP_TASK_ID%type := null;
        g_pkt_p_bdgt_version_id       PA_BC_PACKETS.budget_version_id%type := null;
        g_pkt_p_bud_task_id           PA_BC_PACKETS.TASK_ID%type := null;
        g_pkt_p_rlmi                  PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_p_bud_rlmi              PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_p_prlmi                 PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_p_entry_level_code      VARCHAR2(200) := null;
        g_pkt_p_start_date            DATE := null;
        g_pkt_p_end_date              DATE := null;
        g_pkt_p_time_phase_code       VARCHAR2(20) := null;


        g_pkt_p_acct_project_id            PA_BC_PACKETS.PROJECT_ID%TYPE := null;
        g_pkt_p_acct_task_id               PA_BC_PACKETS.TASK_ID%type := null;
        g_pkt_p_acct_top_task_id           PA_BC_PACKETS.TOP_TASK_ID%type := null;
        g_pkt_p_acct_bdgt_version_id       PA_BC_PACKETS.budget_version_id%type := null;
        g_pkt_p_acct_bdgt_ccid             PA_BC_PACKETS.budget_ccid%type := null;
        g_pkt_p_acct_rlmi                  PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_p_acct_bud_rlmi              PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_p_acct_prlmi                 PA_BC_PACKETS.resource_list_member_id%type := null;
        g_pkt_p_acct_entry_level_code      VARCHAR2(200) := null;
        g_pkt_p_acct_start_date            DATE := null;
        g_pkt_p_acct_end_date              DATE := null;
        g_pkt_p_acct_time_phase_code       VARCHAR2(20) := null;
	------- end of performance varibales declrartions

	--Bug 5964934
        g_fclc_budget_version_id           pa_budget_versions.budget_version_id%type := null;
        g_fclc_project_id                  pa_budgetary_controls.project_id%type := null;
        g_fclc_top_task_id                 pa_budgetary_controls.top_task_id%type := null;
        g_fclc_task_id                     pa_budgetary_controls.task_id%type := null;
        g_fclc_parent_member_id            pa_budgetary_controls.parent_member_id%type := null;
        g_fclc_resource_list_member_id     pa_budgetary_controls.resource_list_member_id%type := null;
        g_p_funds_control_level_code  varchar2(1) := null;
        g_tt_funds_control_level_code varchar2(1) := null;
        g_t_funds_control_level_code  varchar2(1) := null;
        g_rg_funds_control_level_code varchar2(1) := null;
        g_r_funds_control_level_code  varchar2(1) := null;

/**---------------------------------------------------------------------------------
-- declare plsql tables to hold values during the funds check process
--------------------------------------------------------------------- **/
        type rowidtabtyp is table of urowid index by binary_integer;
        g_tab_rowid                             rowidtabtyp;
	g_tab_bc_packet_id			pa_plsql_datatypes.IdTabTyp;
	g_tab_p_bc_packet_id			pa_plsql_datatypes.IdTabTyp;
        g_tab_budget_version_id                 pa_plsql_datatypes.IdTabTyp;
        g_tab_project_id                        pa_plsql_datatypes.IdTabTyp;
        g_tab_task_id                           pa_plsql_datatypes.IdTabTyp;
        g_tab_doc_type                          pa_plsql_datatypes.Char50TabTyp;
        g_tab_doc_header_id                     pa_plsql_datatypes.IdTabTyp;
        g_tab_doc_distribution_id               pa_plsql_datatypes.IdTabTyp;
        g_tab_exp_item_date                     pa_plsql_datatypes.DateTabTyp;
        g_tab_exp_org_id                        pa_plsql_datatypes.IdTabTyp;
	g_tab_OU                                pa_plsql_datatypes.IdTabTyp;
        g_tab_actual_flag                       pa_plsql_datatypes.char50TabTyp;
        g_tab_period_name                       pa_plsql_datatypes.char50TabTyp;
        g_tab_time_phase_type_code              pa_plsql_datatypes.char50TabTyp;
        g_tab_amount_type                       pa_plsql_datatypes.char50TabTyp;
        g_tab_boundary_code                     pa_plsql_datatypes.char50TabTyp;
        g_tab_entry_level_code                  pa_plsql_datatypes.char50TabTyp;
        g_tab_category_code                     pa_plsql_datatypes.char50TabTyp;
        g_tab_rlmi                              pa_plsql_datatypes.IdTabTyp;
        g_tab_p_resource_id                     pa_plsql_datatypes.IdTabTyp;
        g_tab_r_list_id                         pa_plsql_datatypes.IdTabTyp;
        g_tab_p_member_id                       pa_plsql_datatypes.IdTabTyp;
        g_tab_bud_task_id                       pa_plsql_datatypes.IdTabTyp;
        g_tab_bud_rlmi                          pa_plsql_datatypes.IdTabTyp;
        g_tab_tt_task_id                        pa_plsql_datatypes.IdTabTyp;
        g_tab_r_fclevel_code                    pa_plsql_datatypes.char50TabTyp;
        g_tab_rg_fclevel_code                   pa_plsql_datatypes.char50TabTyp;
        g_tab_t_fclevel_code                    pa_plsql_datatypes.char50TabTyp;
        g_tab_tt_fclevel_code                   pa_plsql_datatypes.char50TabTyp;
        g_tab_p_fclevel_code                    pa_plsql_datatypes.char50TabTyp;
        g_tab_p_acct_fclevel_code               pa_plsql_datatypes.char50TabTyp;
        g_tab_burd_cost_flag                    pa_plsql_datatypes.char50TabTyp;
        g_tab_pkt_trx_amt                       pa_plsql_datatypes.NumTabTyp;
        g_tab_accounted_dr                      pa_plsql_datatypes.NumTabTyp;
        g_tab_accounted_cr                      pa_plsql_datatypes.NumTabTyp;
        g_tab_PA_amt                            pa_plsql_datatypes.NumTabTyp;
        g_tab_PE_amt                            pa_plsql_datatypes.NumTabTyp;
        g_tab_status_code                       pa_plsql_datatypes.char50TabTyp;
        g_tab_effect_on_funds_code              pa_plsql_datatypes.char50TabTyp;
        g_tab_result_code                       pa_plsql_datatypes.char50TabTyp;
        g_tab_r_result_code                     pa_plsql_datatypes.char50TabTyp;
        g_tab_rg_result_code                    pa_plsql_datatypes.char50TabTyp;
        g_tab_t_result_code                     pa_plsql_datatypes.char50TabTyp;
        g_tab_tt_result_code                    pa_plsql_datatypes.char50TabTyp;
        g_tab_p_result_code                     pa_plsql_datatypes.char50TabTyp;
        g_tab_p_acct_result_code                pa_plsql_datatypes.char50TabTyp;
        g_tab_r_budget_posted                   pa_plsql_datatypes.NumTabTyp;
        g_tab_rg_budget_posted                  pa_plsql_datatypes.NumTabTyp;
        g_tab_t_budget_posted                   pa_plsql_datatypes.NumTabTyp;
        g_tab_tt_budget_posted                  pa_plsql_datatypes.NumTabTyp;
        g_tab_p_budget_posted                   pa_plsql_datatypes.NumTabTyp;
        g_tab_r_actual_posted                   pa_plsql_datatypes.NumTabTyp;
        g_tab_rg_actual_posted                  pa_plsql_datatypes.NumTabTyp;
        g_tab_t_actual_posted                   pa_plsql_datatypes.NumTabTyp;
        g_tab_tt_actual_posted                  pa_plsql_datatypes.NumTabTyp;
        g_tab_p_actual_posted                   pa_plsql_datatypes.NumTabTyp;
        g_tab_r_enc_posted                      pa_plsql_datatypes.NumTabTyp;
        g_tab_rg_enc_posted                     pa_plsql_datatypes.NumTabTyp;
        g_tab_t_enc_posted                      pa_plsql_datatypes.NumTabTyp;
        g_tab_tt_enc_posted                     pa_plsql_datatypes.NumTabTyp;
        g_tab_p_enc_posted                      pa_plsql_datatypes.NumTabTyp;
        g_tab_r_budget_bal                      pa_plsql_datatypes.NumTabTyp;
        g_tab_rg_budget_bal                     pa_plsql_datatypes.NumTabTyp;
        g_tab_t_budget_bal                      pa_plsql_datatypes.NumTabTyp;
        g_tab_tt_budget_bal                     pa_plsql_datatypes.NumTabTyp;
        g_tab_p_budget_bal                      pa_plsql_datatypes.NumTabTyp;
        g_tab_r_actual_approved                 pa_plsql_datatypes.NumTabTyp;
        g_tab_rg_actual_approved                pa_plsql_datatypes.NumTabTyp;
        g_tab_t_actual_approved                 pa_plsql_datatypes.NumTabTyp;
        g_tab_tt_actual_approved                pa_plsql_datatypes.NumTabTyp;
        g_tab_p_actual_approved                 pa_plsql_datatypes.NumTabTyp;
        g_tab_r_enc_approved                    pa_plsql_datatypes.NumTabTyp;
        g_tab_rg_enc_approved                   pa_plsql_datatypes.NumTabTyp;
        g_tab_t_enc_approved                    pa_plsql_datatypes.NumTabTyp;
        g_tab_tt_enc_approved                   pa_plsql_datatypes.NumTabTyp;
        g_tab_p_enc_approved                    pa_plsql_datatypes.NumTabTyp;
	g_tab_trxn_ccid				pa_plsql_datatypes.Idtabtyp;
	g_tab_budget_ccid			pa_plsql_datatypes.Idtabtyp;
	g_tab_old_budget_ccid			pa_plsql_datatypes.Idtabtyp;
	g_tab_effect_fclevel			pa_plsql_datatypes.char50TabTyp;
        g_tab_exp_category                      pa_plsql_datatypes.char50TabTyp;
        g_tab_rev_category                      pa_plsql_datatypes.char50TabTyp;
        g_tab_sys_link_func                     pa_plsql_datatypes.char50TabTyp;
        g_tab_exp_type                          pa_plsql_datatypes.char50TabTyp;
        g_tab_gl_date                           pa_plsql_datatypes.Datetabtyp;
        g_tab_pa_date                           pa_plsql_datatypes.Datetabtyp;
        g_tab_start_date                        pa_plsql_datatypes.Datetabtyp;
        g_tab_end_date                          pa_plsql_datatypes.Datetabtyp;
        g_tab_encum_type_id                     pa_plsql_datatypes.Idtabtyp;
	g_tab_process_funds_level 		pa_plsql_datatypes.char50TabTyp;
	g_tab_res_level_cache_amt               pa_plsql_datatypes.NumTabTyp;
	g_tab_res_grp_level_cache_amt           pa_plsql_datatypes.NumTabTyp;
	g_tab_task_level_cache_amt              pa_plsql_datatypes.NumTabTyp;
	g_tab_top_task_level_cache_amt          pa_plsql_datatypes.NumTabTyp;
	g_tab_proj_level_cache_amt              pa_plsql_datatypes.NumTabTyp;
	g_tab_prj_acct_level_cache_amt          pa_plsql_datatypes.NumTabTyp;
/* Bug 9750534: Modified the below cache global variables from Char50TabTyp to Char100TabTyp */
	g_tab_res_level_cache			pa_plsql_datatypes.char100TabTyp;
	g_tab_res_grp_level_cache		pa_plsql_datatypes.char100TabTyp;
	g_tab_task_level_cache			pa_plsql_datatypes.char100TabTyp;
	g_tab_top_task_level_cache		pa_plsql_datatypes.char100TabTyp;
	g_tab_proj_level_cache			pa_plsql_datatypes.char100TabTyp;
	g_tab_proj_acct_level_cache		pa_plsql_datatypes.char100TabTyp;
	g_tab_tieback_id                 	pa_plsql_datatypes.char250TabTyp;
	g_tab_group_resource_type_id            pa_plsql_datatypes.NumTabTyp; /* bug fix 2658952 */
        g_tab_person_id                         pa_plsql_datatypes.Idtabtyp;
        g_tab_job_id                            pa_plsql_datatypes.Idtabtyp;
        g_tab_vendor_id                         pa_plsql_datatypes.Idtabtyp;
        g_tab_non_lab_res                       pa_plsql_datatypes.char250TabTyp;
        g_tab_non_lab_res_org                   pa_plsql_datatypes.Idtabtyp;
	g_tab_non_cat_rlmi			pa_plsql_datatypes.Idtabtyp;
	g_tab_proj_OU                           pa_plsql_datatypes.Idtabtyp;
	g_tab_exp_OU                            pa_plsql_datatypes.Idtabtyp;
	g_tab_doc_line_id                       pa_plsql_datatypes.Idtabtyp;
	g_tab_ext_bdgt_link                     pa_plsql_datatypes.char50TabTyp;
	g_tab_sob_id                            pa_plsql_datatypes.Idtabtyp;
	g_tab_exp_gl_date                       pa_plsql_datatypes.DateTabTyp;
	g_tab_exp_item_id                       pa_plsql_datatypes.Idtabtyp;

        /* Bug 5631763 */
	g_Tfund_control_level         pa_budgetary_control_options.fund_control_level_task%type;
        g_Pfund_control_level         pa_budgetary_control_options.fund_control_level_project%type;
	g_RGfund_control_level        pa_budgetary_control_options.fund_control_level_res_grp%type;
	g_Rfund_control_level         pa_budgetary_control_options.fund_control_level_res%type;
	/* Bug 5631763 */

        -- Added for R12 ...
        g_tab_burden_method_code                pa_plsql_datatypes.char50TabTyp;
        g_tab_budget_line_id                    pa_plsql_datatypes.IdTabTyp;
	g_tab_src_dist_id_num_1                 pa_plsql_datatypes.Idtabtyp;
        g_tab_gl_bc_event_id                    pa_plsql_datatypes.Idtabtyp;
        g_tab_src_dist_type                     pa_plsql_datatypes.char50TabTyp;
        g_tab_allow_flag                        pa_plsql_datatypes.Char1TabTyp;
        g_packet_credit_processed               Varchar2(1);
        g_packet_debit_processed                Varchar2(1);


/**---------------------------------------------------------------------------------
-- declare a plsql record to hold values during the funds check process
---------------------------------------------------------------------------------**/
	TYPE PA_FC_RECORD is RECORD (
        packet_id                         pa_bc_packets.packet_id%type,
        bc_packet_id                      pa_bc_packets.bc_packet_id%type,
        set_of_books_id                   pa_bc_packets.set_of_books_id%type,
        budget_version_id                 pa_bc_packets.budget_version_id%type,
        project_id                        pa_bc_packets.project_id%type,
        task_id                           pa_bc_packets.task_id%type,
	document_type			  pa_bc_packets.document_type%type,
        document_header_id                pa_bc_packets.document_header_id%type,
        document_distribution_id          pa_bc_packets.document_distribution_id%type,
        expenditure_item_date             pa_bc_packets.expenditure_item_date%type,
        expenditure_organization_id       pa_bc_packets.expenditure_organization_id%type,
	exp_type			  pa_bc_packets.expenditure_type%type,
        actual_flag                       pa_bc_packets.actual_flag%type,
        period_name                       pa_bc_packets.period_name%type,
        time_phased_type_code             VARCHAR2(30),
        amount_type                       VARCHAR2(15),
        boundary_code                     VARCHAR2(15),
        entry_level_code                  VARCHAR2(10),
        categorization_code               VARCHAR2(10),
        resource_list_member_id           pa_bc_packets.resource_list_member_id%TYPE,
        parent_resource_id                pa_bc_packets.parent_resource_id%type,
        resource_list_id                  NUMBER,
        parent_member_id                  NUMBER,
        bud_task_id                       pa_bc_packets.bud_task_id%type,
        bud_resource_list_member_id       pa_bc_packets.bud_resource_list_member_id%type,
        top_task_id                       pa_bc_packets.top_task_id%type,
        r_funds_control_level_code        pa_bc_packets.r_funds_control_level_code%type,
        rg_funds_control_level_code       pa_bc_packets.rg_funds_control_level_code%type,
        t_funds_control_level_code        pa_bc_packets.t_funds_control_level_code%type,
       	tt_funds_control_level_code       pa_bc_packets.tt_funds_control_level_code%type,
        p_funds_control_level_code        pa_bc_packets.p_funds_control_level_code%type,
        burdened_cost_flag                VARCHAR2(10),
        accounted_dr                      pa_bc_packets.accounted_dr%type,
        accounted_cr                      pa_bc_packets.accounted_dr%type,
        status_code                       pa_bc_packets.status_code%type,
        r_budget_posted                   pa_bc_packets.res_budget_posted%type,
        rg_budget_posted                  pa_bc_packets.res_budget_posted%type,
        t_budget_posted                   pa_bc_packets.res_budget_posted%type,
        tt_budget_posted                  pa_bc_packets.res_budget_posted%type,
        p_budget_posted                   pa_bc_packets.res_budget_posted%type,
        r_actual_posted                   pa_bc_packets.res_budget_posted%type,
        rg_actual_posted                  pa_bc_packets.res_budget_posted%type,
        t_actual_posted                   pa_bc_packets.res_budget_posted%type,
        tt_actual_posted                  pa_bc_packets.res_budget_posted%type,
        p_actual_posted                   pa_bc_packets.res_budget_posted%type,
        r_enc_posted                      pa_bc_packets.res_budget_posted%type,
        rg_enc_posted                     pa_bc_packets.res_budget_posted%type,
        t_enc_posted                      pa_bc_packets.res_budget_posted%type,
        tt_enc_posted                     pa_bc_packets.res_budget_posted%type,
        p_enc_posted                      pa_bc_packets.res_budget_posted%type,
        r_budget_bal                      pa_bc_packets.res_budget_posted%type,
        rg_budget_bal                     pa_bc_packets.res_budget_posted%type,
        t_budget_bal                      pa_bc_packets.res_budget_posted%type,
        tt_budget_bal                     pa_bc_packets.res_budget_posted%type,
        p_budget_bal                      pa_bc_packets.res_budget_posted%type,
        r_actual_approved                 pa_bc_packets.res_budget_posted%type,
        rg_actual_approved                pa_bc_packets.res_budget_posted%type,
        t_actual_approved                 pa_bc_packets.res_budget_posted%type,
        tt_actual_approved                pa_bc_packets.res_budget_posted%type,
        p_actual_approved                 pa_bc_packets.res_budget_posted%type,
        r_enc_approved                    pa_bc_packets.res_budget_posted%type,
        rg_enc_approved                   pa_bc_packets.res_budget_posted%type,
        t_enc_approved                    pa_bc_packets.res_budget_posted%type,
        tt_enc_approved                   pa_bc_packets.res_budget_posted%type,
        p_enc_approved                    pa_bc_packets.res_budget_posted%type,
        result_code                       pa_bc_packets.result_code%type,
        r_result_code                     pa_bc_packets.res_result_code%type,
        rg_result_code                    pa_bc_packets.res_grp_result_code%type,
        t_result_code                     pa_bc_packets.task_result_code%type,
        tt_result_code                    pa_bc_packets.top_task_result_code%type,
        p_result_code                     pa_bc_packets.project_result_code%type,
	p_acct_result_code		  pa_bc_packets.project_result_code%type,
        trxn_ccid                         pa_bc_packets.txn_ccid%type,
        budget_ccid                       pa_bc_packets.budget_ccid%type,
        effect_on_funds_code              pa_bc_packets.effect_on_funds_code%type,
	gl_date				  pa_bc_packets.expenditure_item_date%type,
	pa_date				  pa_bc_packets.expenditure_item_date%type,
	parent_bc_packet_id               pa_bc_packets.bc_packet_id%type,
	group_resource_type_id            Number
        );

-- -------------------------- R12 Changes Start -------------------------------------+

 Type TypeNum      is table of number index by binary_integer;
 Type TypeVarChar  is table of varchar2(50) index by binary_integer;
 Type TypeDate     is table of date index by binary_integer;
 l_limit           NUMBER(4);
 l_program_name    VARCHAR2(30);
 g_event_id        TypeNum;
 g_doc_dist_id     TypeNum;
 g_document_type    TypeVarChar;
 g_ap_matched_case  Varchar2(1);

 -- This procedure will execute the budget account validation, account level FC
 -- and update budget lines with the new derived accounts, call PROCEDURE
 -- Build_account_summary to build pa_budget_acct_lines

 PROCEDURE DO_BUDGET_BASELINE_TIEBACK(p_packet_id     IN NUMBER,
                                     p_return_status OUT NOCOPY VARCHAR2);

 -- This procedure will build pa_budget_acct_lines
 -- Called from DO_BUDGET_BASELINE_TIEBACK

 PROCEDURE Build_account_summary(P_budget_version_id      IN NUMBER,
                                 P_balance_type           IN VARCHAR2,
                                 P_budget_amount_code     IN VARCHAR2,
                                 P_prev_budget_version_id IN NUMBER);

 -- This procedure is an autonomus procedure that calls Build_account_summary
 -- Called from DO_BUDGET_BASELINE_TIEBACK

 PROCEDURE Build_account_summary_auto(X_budget_version_id      IN NUMBER,
                                      X_balance_type           IN VARCHAR2,
                                      X_budget_amount_code     IN VARCHAR2,
                                      X_prev_budget_version_id IN NUMBER,
                                      X_mode                   IN VARCHAR2);

 -- This procedure will update pa_bc_packets records with a failure status.
 -- This procedure is an AUTONOMOUS procedure
 -- This procedure will be called from do_budget_baseline_tieback

 PROCEDURE Fail_bc_pkt_during_baseline(P_budget_version_id     IN NUMBER,
                                       P_period_name           IN g_tab_period_name%TYPE,
                                       P_budget_ccid           IN g_tab_budget_ccid%TYPE,
                                       P_allow_flag            IN g_tab_allow_flag%TYPE,
                                       P_result_code           IN VARCHAR2);

 -- This procedure will update pa_budget_acct_lines with a failure status.
 -- This procedure is an AUTONOMOUS procedure
 -- This procedure will be called from do_budget_baseline_tieback

 PROCEDURE Update_failure_in_acct_summary(P_budget_version_id     IN NUMBER,
                                          P_period_name           IN g_tab_period_name%TYPE,
                                          P_budget_ccid           IN g_tab_budget_ccid%TYPE,
                                          P_allow_flag            IN g_tab_allow_flag%TYPE,
                                          P_result_code           IN VARCHAR2);

 -- Procedure Update_budget_ccid updated budget_ccid on the pa_bc_packet records
 -- for this baseline, its an AUTONOMOUS procedure ..

 PROCEDURE Update_budget_ccid(P_budget_version_id      IN NUMBER,
                             P_budget_ccid             IN g_tab_budget_ccid%TYPE,
                             P_budget_line_id          IN g_tab_budget_line_id%TYPE,
                             P_budget_entry_level_code IN VARCHAR2,
                             P_period_name             IN g_tab_period_name%TYPE,
                             P_rlmi                    IN g_tab_rlmi%TYPE,
                             P_task_id                 IN g_tab_task_id%TYPE,
                             P_derived_ccid            IN g_tab_budget_ccid%TYPE,
                             P_allowed_flag            IN g_tab_allow_flag%TYPE,
                             P_result_code             IN OUT NOCOPY VARCHAR2);

-- --------------------------------------------------------------------------------+
-- This procedure will mark gl_bc_packets  records to a status such that GL does
-- not execute funds available validation. Previously we used to create liquidation
-- entries. Instead of that, we're executing the following procedure.
-- This is for NO/SEPARATE LINE BURDENING only.
-- This procedure is called from function pa_funds_check
-- --------------------------------------------------------------------------------+
-- PROCEDURE Mark_gl_bc_packets_for_no_fc (p_packet_id IN Number);

-- --------------------------------------------------------------------------------+
-- This procedure will determine whether funds check/ funds check tieback
-- has been called for non-project related/project related txn. or budget
-- funds check.
-- p_return_code: 'NO_FC', For non-project related FC
-- p_return_code: 'TXN_FC',For project related txn. (including 'RESERVE_BASELINE')
-- p_return_code: 'BUD_FC',For SLA-BC budget baseline integration (GL FC)
-- --------------------------------------------------------------------------------+
   PROCEDURE Check_txn_or_budget_fc(p_packet_id   in number,
                                 p_return_code out NOCOPY varchar2);

-- --------------------------------------------------------------------------------+
-- This procedure will update the following columns in pa_bc_packets: serial_id,
-- session_id,actual_flag,packet_id and status. Status will be upated from I to P.
-- Called from pa_funds_check
-- This procedure will also check if the extracts were successful, meaning that:
-- A. pa_bc_packet records have been extracted into gl_bc_packets
-- B. core records have been extracted into gl_bc_packets
-- C. project relieveing entries are created in gl_bc_packets
-- --------------------------------------------------------------------------------+
   PROCEDURE Synch_pa_gl_packets(x_packet_id    IN Number,
                                 x_partial_flag IN VARCHAR2,
                                 x_mode         IN VARCHAR2,
                                 x_result_code  OUT NOCOPY  Varchar2);

-- --------------------------------------------------------------------------------+
-- Following procedure resets funds_check_status_code and result code on
-- pa_budget_acct_lines for the draft version ..
-- --------------------------------------------------------------------------------+
   PROCEDURE Reset_status_code_on_summary(p_budget_version_id IN Number);

-- --------------------------------------------------------------------------------+
-- This procedure is called from Synch_pa_gl_packets to AUTONOMOUSLY update
-- pa_bc_packets with failure....in case of extract failing ..
-- -------------------------------------------------------------------------------+
   PROCEDURE Missing_records_failure(p_pa_packet_id IN NUMBER,
                                     p_gl_packet_id IN NUMBER,
                                     p_partial_flag IN VARCHAR2,
                                     p_mode         IN VARCHAR2);

-- --------------------------------------------------------------------------------+
-- This procedure is called from Synch_pa_gl_packets to update: serial_id,
-- session_id, actual_flag,packet_id and status ..
-- --------------------------------------------------------------------------------+
   PROCEDURE Synch_data(p_pa_packet_id IN NUMBER,
                        p_gl_packet_id IN NUMBER);

-- --------------------------------------------------------------------------------+
-- This procedure will be called from do_budget_baseline to update pa_bc_packet
-- project_acct_result_code and result_code to 'P101' after account level funds
-- check is successful. Procedure is AUTONOMOUS
-- --------------------------------------------------------------------------------+
   PROCEDURE Upd_bc_pkt_acct_result_code(P_budget_version_id     IN NUMBER);

-- --------------------------------------------------------------------------------+
-- This procedure will check if there exists any txn. against the project
-- It will return 'Y' if any txn exists
-- --------------------------------------------------------------------------------+
   Procedure Any_txns_against_project(p_project_id           IN NUMBER,
                                      p_txn_exists_in_bc_pkt OUT NOCOPY VARCHAR2,
                                      p_txn_exists_in_bc_cmt OUT NOCOPY VARCHAR2);

-- --------------------------------------------------------------------------------+
-- This procedure has been created to handle FULL MODE failure during check funds
-- action of an invoice that is matched to PO .. bug 5253309
-- p_case added to handle future scenarios..
-- This is reqd. especially for scenarios where AP has multiple distributions and
-- some are matched to PO, in such cases the doc. is in 'PARTIAL MODE' but matched
-- dist. is treated in FULL MODE.
-- --------------------------------------------------------------------------------+
   Procedure Full_mode_failure(p_packet_id IN NUMBER,
                               p_case      IN VARCHAR2);

-- --------------------------------------------------------------------------------+
-- This autonomous procedure is called to update the newly derived account info.
-- back onto the draft budget lines during baseline/yearend ..
-- --------------------------------------------------------------------------------+
PROCEDURE Upd_new_acct_on_draft_budget(p_budget_line_rowid       IN g_tab_rowid%TYPE,
                                       p_budget_ccid             IN g_tab_budget_ccid%TYPE,
                                       p_new_ccid                IN g_tab_budget_ccid%TYPE,
                                       p_change_allowed          IN g_tab_allow_flag%TYPE,
                                       p_record_updated          OUT NOCOPY Varchar2);

-- --------------------------------------------------------------------------------+
-- This procedure will fail data in the other packet .. i.e. the credit packet ..
-- --------------------------------------------------------------------------------+
PROCEDURE Fail_credit_packet(p_input_packet IN Varchar2,
                             p_return_status_code OUT NOCOPY varchar2);

-- -------------------------- R12 Changes End -------------------------------------+

/**-------------------------------------------------------------------------------
-- Procedure to Initialize the  global variables
-------------------------------------------------------------------------------**/
PROCEDURE Initialize_globals IS

BEGIN


        g_error_stage           := null;
        g_error_msg             := null;
        g_project_id            := null;
        g_task_id               := null;
        g_top_task_id           := null;
        g_bdgt_version_id       := null;
        g_bud_task_id           := null;
        g_rlmi                  := null;
        g_bud_rlmi              := null;
        g_prlmi                 := null;
        g_entry_level_code      := null;
        g_start_date            := null;
        g_end_date              := null;
        g_time_phase_code       := null;
        g_pre_project_id        := null;
        g_pre_task_id           := null;
        g_pre_top_task_id       := null;
        g_pre_bdgt_version_id   := null;
        g_pre_bud_task_id       := null;
        g_pre_rlmi              := null;
        g_pre_bud_rlmi          := null;
        g_pre_prlmi             := null;
        g_pre_entry_level_code  := null;
        g_pre_start_date        := null;
        g_pre_end_date          := null;
        g_pre_time_phase_code   := null;
        g_r_budget_posted       := null;
        g_r_actual_posted       := null;
        g_r_enc_posted          := null;
        g_r_enc_approved        := null;
        g_r_enc_pending         := null;
        g_r_actual_approved     := null;
        g_r_budget_posted       := null;
        g_r_actual_posted       := null;
        g_r_enc_posted          := null;
        g_r_enc_approved        := null;
        g_r_enc_pending         := null;
        g_r_actual_approved     := null;
        g_r_actual_pending      := null;
        g_rg_budget_posted      := null;
        g_rg_actual_posted      := null;
        g_rg_enc_posted         := null;
        g_rg_enc_approved       := null;
        g_rg_enc_pending        := null;
        g_rg_actual_approved    := null;
        g_rg_actual_pending     := null;
        g_t_budget_posted       := null;
        g_t_actual_posted       := null;
        g_t_enc_posted          := null;
        g_t_enc_approved        := null;
        g_t_enc_pending         := null;
        g_t_actual_approved     := null;
        g_t_actual_pending      := null;
        g_tt_budget_posted      := null;
        g_tt_actual_posted      := null;
        g_tt_enc_posted         := null;
        g_tt_enc_approved       := null;
        g_tt_enc_pending        := null;
        g_tt_actual_approved    := null;
        g_tt_actual_pending     := null;
        g_p_budget_posted       := null;
        g_p_actual_posted       := null;
        g_p_enc_posted          := null;
        g_p_enc_approved        := null;
        g_p_enc_pending         := null;
        g_p_actual_approved     := null;
        g_p_actual_pending      := null;
        g_r_pkt_amt             := null;
        g_rg_pkt_amt            := null;
        g_t_pkt_amt             := null;
        g_tt_pkt_amt            := null;
        g_p_pkt_amt             := null;
        g_p_acct_pkt_amt        := null;
        g_r_base_amt            := null;
        g_rg_base_amt           := null;
        g_t_base_amt            := null;
        g_tt_base_amt           := null;
        g_p_base_amt            := null;
        g_p_acct_base_amt       := null;
	g_bdgt_ccid		:= null;
	g_pre_bdgt_ccid		:= null;
	g_p_acct_enc_approved	:= null;
	g_p_acct_actual_approved := null;
	g_exp_burden_method     := null;
	g_exp_project_id        := null;

	-----for performance testing these variables added
        g_bal_r_project_id            := null;
        g_bal_r_task_id               := null;
        g_bal_r_top_task_id           := null;
        g_bal_r_bdgt_version_id       := null;
        g_bal_r_bud_task_id           := null;
        g_bal_r_rlmi                  := null;
        g_bal_r_bud_rlmi              := null;
        g_bal_r_prlmi                 := null;
        g_bal_r_entry_level_code      := null;
        g_bal_r_start_date            := null;
        g_bal_r_end_date              := null;
        g_bal_r_time_phase_code       := null;

        g_pkt_r_project_id            := null;
        g_pkt_r_task_id               := null;
        g_pkt_r_top_task_id           := null;
        g_pkt_r_bdgt_version_id       := null;
        g_pkt_r_bud_task_id           := null;
        g_pkt_r_rlmi                  := null;
        g_pkt_r_bud_rlmi              := null;
        g_pkt_r_prlmi                 := null;
        g_pkt_r_entry_level_code      := null;
        g_pkt_r_start_date            := null;
        g_pkt_r_end_date              := null;
        g_pkt_r_time_phase_code       := null;

        g_bal_rg_project_id            := null;
        g_bal_rg_task_id               := null;
        g_bal_rg_top_task_id           := null;
        g_bal_rg_bdgt_version_id       := null;
        g_bal_rg_bud_task_id           := null;
        g_bal_rg_rlmi                  := null;
        g_bal_rg_bud_rlmi              := null;
        g_bal_rg_prlmi                 := null;
        g_bal_rg_entry_level_code      := null;
        g_bal_rg_start_date            := null;
        g_bal_rg_end_date              := null;
        g_bal_rg_time_phase_code       := null;

        g_pkt_rg_project_id            := null;
        g_pkt_rg_task_id               := null;
        g_pkt_rg_top_task_id           := null;
        g_pkt_rg_bdgt_version_id       := null;
        g_pkt_rg_bud_task_id           := null;
        g_pkt_rg_rlmi                  := null;
        g_pkt_rg_bud_rlmi              := null;
        g_pkt_rg_prlmi                 := null;
        g_pkt_rg_entry_level_code      := null;
        g_pkt_rg_start_date            := null;
        g_pkt_rg_end_date              := null;
        g_pkt_rg_time_phase_code       := null;

        g_bal_t_project_id            := null;
        g_bal_t_task_id               := null;
        g_bal_t_top_task_id           := null;
        g_bal_t_bdgt_version_id       := null;
        g_bal_t_bud_task_id           := null;
        g_bal_t_rlmi                  := null;
        g_bal_t_bud_rlmi              := null;
        g_bal_t_prlmi                 := null;
        g_bal_t_entry_level_code      := null;
        g_bal_t_start_date            := null;
        g_bal_t_end_date              := null;
        g_bal_t_time_phase_code       := null;

        g_pkt_t_project_id            := null;
        g_pkt_t_task_id               := null;
        g_pkt_t_top_task_id           := null;
        g_pkt_t_bdgt_version_id       := null;
        g_pkt_t_bud_task_id           := null;
        g_pkt_t_rlmi                  := null;
        g_pkt_t_bud_rlmi              := null;
        g_pkt_t_prlmi                 := null;
        g_pkt_t_entry_level_code      := null;
        g_pkt_t_start_date            := null;
        g_pkt_t_end_date              := null;
        g_pkt_t_time_phase_code       := null;

        g_bal_tt_project_id            := null;
        g_bal_tt_task_id               := null;
        g_bal_tt_top_task_id           := null;
        g_bal_tt_bdgt_version_id       := null;
        g_bal_tt_bud_task_id           := null;
        g_bal_tt_rlmi                  := null;
        g_bal_tt_bud_rlmi              := null;
        g_bal_tt_prlmi                 := null;
        g_bal_tt_entry_level_code      := null;
        g_bal_tt_start_date            := null;
        g_bal_tt_end_date              := null;
        g_bal_tt_time_phase_code       := null;

        g_pkt_tt_project_id            := null;
        g_pkt_tt_task_id               := null;
        g_pkt_tt_top_task_id           := null;
        g_pkt_tt_bdgt_version_id       := null;
        g_pkt_tt_bud_task_id           := null;
        g_pkt_tt_rlmi                  := null;
        g_pkt_tt_bud_rlmi              := null;
        g_pkt_tt_prlmi                 := null;
        g_pkt_tt_entry_level_code      := null;
        g_pkt_tt_start_date            := null;
        g_pkt_tt_end_date              := null;
        g_pkt_tt_time_phase_code       := null;

        g_bal_p_project_id            := null;
        g_bal_p_task_id               := null;
        g_bal_p_top_task_id           := null;
        g_bal_p_bdgt_version_id       := null;
        g_bal_p_bud_task_id           := null;
        g_bal_p_rlmi                  := null;
        g_bal_p_bud_rlmi              := null;
        g_bal_p_prlmi                 := null;
        g_bal_p_entry_level_code      := null;
        g_bal_p_start_date            := null;
        g_bal_p_end_date              := null;
        g_bal_p_time_phase_code       := null;

        g_pkt_p_project_id            := null;
        g_pkt_p_task_id               := null;
        g_pkt_p_top_task_id           := null;
        g_pkt_p_bdgt_version_id       := null;
        g_pkt_p_bud_task_id           := null;
        g_pkt_p_rlmi                  := null;
        g_pkt_p_bud_rlmi              := null;
        g_pkt_p_prlmi                 := null;
        g_pkt_p_entry_level_code      := null;
        g_pkt_p_start_date            := null;
        g_pkt_p_end_date              := null;
        g_pkt_p_time_phase_code       := null;


        g_pkt_p_acct_project_id            := null;
        g_pkt_p_acct_task_id               := null;
        g_pkt_p_acct_bdgt_ccid		   := null;
        g_pkt_p_acct_bdgt_version_id       := null;
        --g_pkt_p_acct_bud_task_id           := null;
        g_pkt_p_acct_rlmi                  := null;
        g_pkt_p_acct_bud_rlmi              := null;
        g_pkt_p_acct_prlmi                 := null;
        g_pkt_p_acct_entry_level_code      := null;
        g_pkt_p_acct_start_date            := null;
        g_pkt_p_acct_end_date              := null;
        g_pkt_p_acct_time_phase_code       := null;
	--- end of cache variables for resource level bal and pkt


	-- clear plsql tabs
        g_tab_res_level_cache_amt.delete;
        g_tab_res_grp_level_cache_amt.delete;
        g_tab_task_level_cache_amt.delete;
        g_tab_top_task_level_cache_amt.delete;
        g_tab_proj_level_cache_amt.delete;
        g_tab_prj_acct_level_cache_amt.delete;
        g_tab_res_level_cache.delete;
        g_tab_res_grp_level_cache.delete;
        g_tab_task_level_cache.delete;
        g_tab_top_task_level_cache.delete;
        g_tab_proj_level_cache.delete;
        g_tab_proj_acct_level_cache.delete;

END Initialize_globals;
/**-----------------------------------------------------------------------------
--Procedure to initialize the value of the record to zero after every loop.
------------------------------------------------------------------------------**/
PROCEDURE initialize_record (
       	pa_bc_rec_ini  IN OUT NOCOPY   pa_fc_record ) IS
      	x_err_code   NUMBER;
      	x_err_buff   VARCHAR2 ( 2000 );
BEGIN
      	pa_bc_rec_ini.packet_id 			:= 0;
        pa_bc_rec_ini.bc_packet_id                      := 0;
        pa_bc_rec_ini.set_of_books_id                   := 0;
        pa_bc_rec_ini.budget_version_id                 := 0;
      	pa_bc_rec_ini.project_id 			:= 0;
        pa_bc_rec_ini.task_id                           := 0;
	pa_bc_rec_ini.document_type			:= null;
      	pa_bc_rec_ini.document_header_id 		:= 0;
	pa_bc_rec_ini.document_distribution_id 		:= 0;
      	pa_bc_rec_ini.expenditure_item_date 		:= NULL;
        pa_bc_rec_ini.expenditure_organization_id       := 0;
	pa_bc_rec_ini.exp_type				:= null;
      	pa_bc_rec_ini.actual_flag 			:= NULL;
      	pa_bc_rec_ini.period_name 			:= NULL;
        pa_bc_rec_ini.time_phased_type_code             := NULL;
        pa_bc_rec_ini.amount_type                       := NULL;
        pa_bc_rec_ini.boundary_code                     := NULL;
        pa_bc_rec_ini.entry_level_code                  := NULL;
        pa_bc_rec_ini.categorization_code               := NULL;
      	pa_bc_rec_ini.resource_list_member_id 		:= 0;
      	pa_bc_rec_ini.parent_resource_id 		:= 0;
        pa_bc_rec_ini.resource_list_id                  := 0;
        pa_bc_rec_ini.parent_member_id                  := 0;
      	pa_bc_rec_ini.bud_task_id 			:= 0;
      	pa_bc_rec_ini.bud_resource_list_member_id 	:= 0;
        pa_bc_rec_ini.top_task_id                       := 0;
      	pa_bc_rec_ini.r_funds_control_level_code 	:= NULL;
      	pa_bc_rec_ini.rg_funds_control_level_code 	:= NULL;
      	pa_bc_rec_ini.t_funds_control_level_code 	:= NULL;
      	pa_bc_rec_ini.tt_funds_control_level_code 	:= NULL;
      	pa_bc_rec_ini.p_funds_control_level_code 	:= NULL;
        pa_bc_rec_ini.burdened_cost_flag                := NULL;
      	pa_bc_rec_ini.accounted_dr 			:= 0;
      	pa_bc_rec_ini.accounted_cr 			:= 0;
      	pa_bc_rec_ini.status_code 			:= 0;
        pa_bc_rec_ini.r_budget_posted  			:= 0;
        pa_bc_rec_ini.rg_budget_posted                	:= 0;
        pa_bc_rec_ini.t_budget_posted                  	:= 0;
        pa_bc_rec_ini.tt_budget_posted               	:= 0;
        pa_bc_rec_ini.p_budget_posted               	:= 0;
        pa_bc_rec_ini.r_actual_posted              	:= 0;
        pa_bc_rec_ini.rg_actual_posted            	:= 0;
        pa_bc_rec_ini.t_actual_posted            	:= 0;
        pa_bc_rec_ini.tt_actual_posted          	:= 0;
        pa_bc_rec_ini.p_actual_posted          		:= 0;
        pa_bc_rec_ini.r_enc_posted            		:= 0;
        pa_bc_rec_ini.rg_enc_posted          		:= 0;
        pa_bc_rec_ini.t_enc_posted          		:= 0;
        pa_bc_rec_ini.tt_enc_posted        		:= 0;
        pa_bc_rec_ini.p_enc_posted        		:= 0;
        pa_bc_rec_ini.r_budget_bal       		:= 0;
        pa_bc_rec_ini.rg_budget_bal                   	:= 0;
        pa_bc_rec_ini.t_budget_bal                   	:= 0;
        pa_bc_rec_ini.tt_budget_bal                 	:= 0;
        pa_bc_rec_ini.p_budget_bal                 	:= 0;
        pa_bc_rec_ini.r_actual_approved           	:= 0;
        pa_bc_rec_ini.rg_actual_approved         	:= 0;
        pa_bc_rec_ini.t_actual_approved                	:= 0;
        pa_bc_rec_ini.tt_actual_approved              	:= 0;
        pa_bc_rec_ini.p_actual_approved              	:= 0;
        pa_bc_rec_ini.r_enc_approved                	:= 0;
        pa_bc_rec_ini.rg_enc_approved              	:= 0;
        pa_bc_rec_ini.t_enc_approved              	:= 0;
        pa_bc_rec_ini.tt_enc_approved            	:= 0;
        pa_bc_rec_ini.p_enc_approved            	:= 0;
        pa_bc_rec_ini.result_code              		:= NULL;
        pa_bc_rec_ini.r_result_code           		:= NULL;
        pa_bc_rec_ini.rg_result_code         		:= NULL;
        pa_bc_rec_ini.t_result_code         		:= NULL;
        pa_bc_rec_ini.tt_result_code       		:= NULL;
        pa_bc_rec_ini.p_result_code       		:= NULL;
	pa_bc_rec_ini.p_acct_result_code		:= NULL;
	pa_bc_rec_ini.trxn_ccid				:= NULL;
	pa_bc_rec_ini.budget_ccid			:= NULL;
	pa_bc_rec_ini.effect_on_funds_code		:= NULL;
	pa_bc_rec_ini.gl_date				:= NULL;
	pa_bc_rec_ini.pa_date				:= NULL;
	pa_bc_rec_ini.parent_bc_packet_id               := 0;
	pa_bc_rec_ini.group_resource_type_id            := null;


EXCEPTION
      	WHEN OTHERS THEN
		Commit;
         	RAISE;
END initialize_record;


/**--------------------------------------------------------------------------
-- This api initializes the pl/sql tables
-------------------------------------------------------------------------- **/
PROCEDURE init_plsql_tabs  IS

BEGIN
        g_tab_rowid.delete;
	g_tab_bc_packet_id.delete;
	g_tab_p_bc_packet_id.delete;
        g_tab_budget_version_id.delete;
        g_tab_project_id.delete;
        g_tab_task_id.delete;
        g_tab_doc_type.delete;
        g_tab_doc_header_id.delete;
        g_tab_doc_distribution_id.delete;
        g_tab_exp_item_date.delete;
        g_tab_exp_org_id.delete;
	g_tab_OU.delete;
        g_tab_actual_flag.delete;
        g_tab_period_name.delete;
        g_tab_time_phase_type_code.delete;
        g_tab_amount_type.delete;
        g_tab_boundary_code.delete;
        g_tab_entry_level_code.delete;
        g_tab_category_code.delete;
        g_tab_rlmi.delete;
        g_tab_p_resource_id.delete;
        g_tab_r_list_id.delete;
        g_tab_p_member_id.delete;
        g_tab_bud_task_id.delete;
        g_tab_bud_rlmi.delete;
        g_tab_tt_task_id.delete;
        g_tab_r_fclevel_code.delete;
        g_tab_rg_fclevel_code.delete;
        g_tab_t_fclevel_code.delete;
        g_tab_tt_fclevel_code.delete;
        g_tab_p_fclevel_code.delete;
        g_tab_p_acct_fclevel_code.delete;
        g_tab_burd_cost_flag.delete;
        g_tab_pkt_trx_amt.delete;
        g_tab_accounted_dr.delete;
        g_tab_accounted_cr.delete;
        g_tab_PA_amt.delete;
        g_tab_PE_amt.delete;
        g_tab_status_code.delete;
        g_tab_effect_on_funds_code.delete;
        g_tab_result_code.delete;
        g_tab_r_result_code.delete;
        g_tab_rg_result_code.delete;
        g_tab_t_result_code.delete;
        g_tab_tt_result_code.delete;
        g_tab_p_result_code.delete;
        g_tab_r_budget_posted.delete;
        g_tab_rg_budget_posted.delete;
        g_tab_t_budget_posted.delete;
        g_tab_tt_budget_posted.delete;
        g_tab_p_budget_posted.delete;
        g_tab_r_actual_posted.delete;
        g_tab_rg_actual_posted.delete;
        g_tab_t_actual_posted.delete;
        g_tab_tt_actual_posted.delete;
        g_tab_p_actual_posted.delete;
        g_tab_r_enc_posted.delete;
        g_tab_rg_enc_posted.delete;
        g_tab_t_enc_posted.delete;
        g_tab_tt_enc_posted.delete;
        g_tab_p_enc_posted.delete;
        g_tab_r_budget_bal.delete;
        g_tab_rg_budget_bal.delete;
        g_tab_t_budget_bal.delete;
        g_tab_tt_budget_bal.delete;
        g_tab_p_budget_bal.delete;
        g_tab_r_actual_approved.delete;
        g_tab_rg_actual_approved.delete;
        g_tab_t_actual_approved.delete;
        g_tab_tt_actual_approved.delete;
        g_tab_p_actual_approved.delete;
        g_tab_r_enc_approved.delete;
        g_tab_rg_enc_approved.delete;
        g_tab_t_enc_approved.delete;
        g_tab_tt_enc_approved.delete;
        g_tab_p_enc_approved.delete;
	g_tab_effect_fclevel.delete;
	g_tab_trxn_ccid.delete;
	g_tab_budget_ccid.delete;
	g_tab_p_acct_result_code.delete;
        g_tab_exp_category.delete;
        g_tab_rev_category.delete;
        g_tab_sys_link_func.delete;
        g_tab_exp_type.delete;
        g_tab_gl_date.delete;
        g_tab_pa_date.delete;
        g_tab_start_date.delete;
        g_tab_end_date.delete;
        g_tab_encum_type_id.delete;
	g_tab_process_funds_level.delete;
	g_tab_old_budget_ccid.delete;
	g_tab_group_resource_type_id.delete;
	g_tab_person_id.delete;
        g_tab_job_id.delete;
        g_tab_vendor_id.delete;
        g_tab_non_lab_res.delete;
        g_tab_non_lab_res_org.delete;
        g_tab_non_cat_rlmi.delete;
        g_tab_proj_OU.delete;
        g_tab_exp_OU.delete;
	g_tab_doc_line_id.delete;
	g_tab_ext_bdgt_link.delete;
	g_tab_sob_id.delete;
	g_tab_exp_gl_date.delete;
	g_tab_exp_item_id.delete;
        g_tab_burden_method_code.delete; -- for r12
        g_tab_budget_line_id.delete; -- for r12

EXCEPTION

        WHEN OTHERS THEN
		--commit;
                RAISE;


END init_plsql_tabs;

-------->6599207 ------As part of CC Enhancements
--Forward declarations
PROCEDURE  Post_Bdn_Lines_To_GL_CBC (
   	p_Packet_ID		IN	Number,
	p_calling_module	IN      VARCHAR2,
	p_packet_status		IN 	VARCHAR2,
	p_reference1		IN 	VARCHAR2,
	p_reference2		IN 	VARCHAR2,
   	x_return_status		OUT NOCOPY	VARCHAR2
   	);
-------->6599207 ------END

---Forward declarations
PROCEDURE update_EIS (p_packet_id       IN NUMBER,
                     p_calling_module   IN VARCHAR2,
                     p_mode             IN VARCHAR2,
                     x_return_status    OUT NOCOPY VARCHAR2);

---Forward declarations
PROCEDURE update_GL_CBC_result_code(
        p_packet_id       IN  number,
        p_calling_module  IN  varchar2,
        p_mode            IN  varchar2,
        p_partial_flag    IN  varchar2,
        p_reference1      IN  varchar2 default null,
        p_reference2      IN  varchar2 default null,
        p_packet_status   IN  varchar2,
        x_return_status   OUT NOCOPY varchar2);
-- Forward declarations
FUNCTION  pa_fck_process
        (p_sob                  IN  NUMBER
        ,p_packet_id            IN  pa_bc_packets.packet_id%type
        ,p_mode                 IN   varchar2
        ,p_partial_flag         IN   varchar2
        ,p_arrival_seq          IN   NUMBER
        ,p_reference1           IN   varchar2
        ,p_reference2           IN   varchar2
        --,p_reference3           IN   varchar2
        ,p_calling_module       IN   varchar2
         )   return BOOLEAN;

/** This API derives the return code for GL / CBC
 *  based on partial reserve flag, If the funds check is called
 *  in partial mode GL /CBC expects the return status as P if
 *  the records are partially passed
 */
FUNCTION  get_gl_cbc_return_status(
		 p_packet_id    NUMBER) return varchar2 IS

	CURSOR pkt_status is
	SELECT decode(count(*),count(decode(substr(nvl(pbc.result_code,'P'),1,1),'P',1)),'S','P')
	FROM   pa_bc_packets pbc
	WHERE  pbc.packet_id = p_packet_id;

	l_pkt_status  varchar2(10);
BEGIN
	OPEN pkt_status;
	FETCH pkt_status INTO l_pkt_status;
	CLOSE pkt_status;

	return nvl(l_pkt_status,'P');

EXCEPTION
	WHEN OTHERS THEN
		IF pkt_status%isopen then
			close pkt_status;
		END IF;
		return nvl(l_pkt_status,'P');

END get_gl_cbc_return_status;

/**----------------------------------------------------------------------------
-- This api checks whether the project is of burden on same or different
-- expenditure items
-- returns 'S' (SAME) 'D'(SEPARATE) 'N' (NO BURDEN)
--------------------------------------------------------------------------- **/
FUNCTION check_bdn_on_sep_item(p_project_id  In number) return varchar2 IS
	l_burden_method   VARCHAR2(20);
BEGIN

	If g_exp_project_id is null or g_exp_project_id <> p_project_id then
		SELECT decode(NVL(ppt.burden_cost_flag, 'N'),'Y',
                       NVL(ppt.burden_amt_display_method,'S'),'N')
                        -- decode(NVL(ppt.burden_amt_display_method,'S'), 'S','SAME','D','DIFFERENT'),'NONE')
		INTO    l_burden_method
        	FROM    pa_project_types  ppt,
                	pa_projects_all  pp
        	WHERE
                	ppt.project_type = pp.project_type
        	AND     pp.project_id  = p_project_id;

		g_exp_burden_method := l_burden_method;
		g_exp_project_id := p_project_id;

		RETURN l_burden_method;

	Else   -- retrive from cache

		RETURN g_exp_burden_method;
	End if;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		g_exp_burden_method := 'N';
	 	-- g_exp_burden_method := 'NONE';
		RETURN g_exp_burden_method;
	WHEN OTHERS THEN
		RAISE;

END check_bdn_on_sep_item;
/**------------------------------------------------------------------
-- This api updates the result and status code in pa bc packets
-- whenever there is error while  processing
----------------------------------------------------------------- **/
PROCEDURE result_status_code_update
	  ( p_status_code		IN VARCHAR2 default null
            ,p_result_code              IN VARCHAR2 default null
            ,p_res_result_code          IN VARCHAR2 default null
            ,p_res_grp_result_code      IN VARCHAR2 default null
            ,p_task_result_code         IN VARCHAR2 default null
            ,p_top_task_result_code     IN VARCHAR2 default null
	    ,p_project_result_code      IN VARCHAR2 default null
	    ,p_proj_acct_result_code    IN VARCHAR2 default null
	    ,p_bc_packet_id		IN NUMBER   default null
            ,p_packet_id                IN NUMBER ) IS

	cursor cur_pkts is
	SELECT packet_id,
	       bc_packet_id
	FROM   pa_bc_packets
	WHERE  packet_id = p_packet_id;

	l_tab_packet_id    	pa_plsql_datatypes.idtabtyp;
	l_tab_bc_packet_id    	pa_plsql_datatypes.idtabtyp;

	PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
	pa_debug.init_err_stack('PA_FUNDS_CONTROL_PKG.result_status_code_update');
	/******
	-- Added if else condition to avoid full table scan on pa_bc_packets
	--EXPLAIN PLAN IS:
	--1:UPDATE STATEMENT   :(cost=2,rows=1)
  	--2:UPDATE  PA_BC_PACKETS :(cost=,rows=)
    	--3:TABLE ACCESS BY INDEX ROWID PA_BC_PACKETS :(cost=2,rows=1)
      	--4:INDEX UNIQUE SCAN PA_BC_PACKETS_U1 :(cost=1,rows=1)
	*******/

	If p_status_code = 'T' then

	        OPEN cur_pkts;
		LOOP
			l_tab_packet_id.delete;
			l_tab_bc_packet_id.delete;
			FETCH cur_pkts BULK COLLECT INTO
				l_tab_packet_id
			        ,l_tab_bc_packet_id LIMIT 500;
			IF NOT l_tab_packet_id.EXISTS(1) then
				EXIT;
			END if;
			FORALL i IN l_tab_packet_id.first .. l_tab_packet_id.last
				UPDATE pa_bc_packets
				SET  status_code = 'T',
		     		result_code = decode(substr(nvl(result_code,'P'),1,1)
						      ,'P', decode(substr(nvl(p_result_code,'P'),1,1)
					                    ,'F', p_result_code,'F142')
						      ,result_code),
                                res_result_code = nvl(res_result_code,p_res_result_code),
                                res_grp_result_code = nvl(res_grp_result_code,p_res_grp_result_code),
                                task_result_code  = nvl(task_result_code,p_task_result_code),
                                top_task_result_code = nvl(top_task_result_code,p_top_task_result_code),
                                project_result_code = nvl(project_result_code,p_project_result_code),
                                project_acct_result_code =nvl(project_acct_result_code,p_proj_acct_result_code)
				WHERE packet_id = l_tab_packet_id(i);

			Exit when cur_pkts%NOTFOUND;
			commit;
		END LOOP;
		CLOSE cur_pkts;


	ELSIf p_bc_packet_id is NOT NULL and p_status_code <> 'T' then

                OPEN cur_pkts;
                LOOP
                        l_tab_packet_id.delete;
			l_tab_bc_packet_id.delete;
                        FETCH cur_pkts BULK COLLECT INTO
				l_tab_packet_id,
				l_tab_bc_packet_id  LIMIT 500;
                        IF NOT l_tab_packet_id.EXISTS(1) then
                                EXIT;
                        END if;
                        FORALL i IN l_tab_packet_id.first .. l_tab_packet_id.last

				UPDATE pa_bc_packets
				SET  	status_code  = nvl(p_status_code,status_code),
	     			result_code  = nvl(p_result_code ,result_code),
				res_result_code = nvl(p_res_result_code,res_result_code),
				res_grp_result_code = nvl(p_res_grp_result_code,res_grp_result_code),
				task_result_code  = nvl(p_task_result_code,task_result_code),
				top_task_result_code = nvl(p_top_task_result_code,top_task_result_code),
				project_result_code = nvl(p_project_result_code,project_result_code),
				project_acct_result_code =nvl(p_proj_acct_result_code,project_acct_result_code)
				WHERE   packet_id = l_tab_packet_id(i)
				AND     bc_packet_id = p_bc_packet_id
				AND     substr(nvl(result_code,'P'),1,1) <> 'F';

                        Exit when cur_pkts%NOTFOUND;
                        commit;
                END LOOP;
                CLOSE cur_pkts;
	Else

                OPEN cur_pkts;
                LOOP
                        l_tab_packet_id.delete;
                        l_tab_bc_packet_id.delete;
                        FETCH cur_pkts BULK COLLECT INTO
				l_tab_packet_id,
				l_tab_bc_packet_id LIMIT 500;
                        IF NOT l_tab_packet_id.EXISTS(1) then
                                EXIT;
                        END if;
                        FORALL i IN l_tab_packet_id.first .. l_tab_packet_id.last
                		UPDATE pa_bc_packets
                		SET     status_code  = nvl(p_status_code,status_code),
                        		result_code  = nvl(p_result_code ,result_code),
                        		res_result_code = nvl(p_res_result_code,res_result_code),
                        		res_grp_result_code = nvl(p_res_grp_result_code,res_grp_result_code),
                        		task_result_code  = nvl(p_task_result_code,task_result_code),
                        		top_task_result_code = nvl(p_top_task_result_code,top_task_result_code),
                        		project_result_code = nvl(p_project_result_code,project_result_code),
                        		project_acct_result_code =nvl(p_proj_acct_result_code,project_acct_result_code)
                		WHERE   packet_id = l_tab_packet_id(i)
                		AND     substr(nvl(result_code,'P'),1,1) <> 'F';
                        Exit when cur_pkts%NOTFOUND;
                        commit;
                END LOOP;
                CLOSE cur_pkts;
	End if;
        IF cur_pkts%isopen then
              close cur_pkts;
        END IF;
	commit; -- to end an active autonmous transaction
	PA_DEBUG.reset_err_stack;
	return;
EXCEPTION
	WHEN OTHERS THEN
		IF cur_pkts%isopen then
			close cur_pkts;
		END IF;
		RAISE;

END result_status_code_update;


procedure log_message_imp(p_msg_token1 in varchar2 default null) is
begin

	--r_debug.r_msg(p_msg =>'LOG : '||p_msg_token1,p_packet_id => g_packet_id);
	--pa_fck_util.debug_msg_imp('LOG : '||p_msg_token1);
	return;
End;

----------------------------------------------------------------
-- This api writes message to log file / buffer / dummy table
-- and initalizes the final out NOCOPY params with values
----------------------------------------------------------------
PROCEDURE log_message(
	  p_stage         IN VARCHAR2 default null,
	  p_error_msg     IN VARCHAR2 default null,
	  p_return_status IN varchar2 default null,
	  p_msg_token1    IN VARCHAR2 default null,
	  p_msg_token2    IN VARCHAR2 default null ) IS

BEGIN

     IF p_error_msg is NOT NULL then
        g_error_msg := p_error_msg;
     END IF;
     IF p_return_status is NOT null then
	g_return_status := p_return_status;
     End if;

    /* write the debug log only if debug is enabled */
     IF g_debug_mode = 'Y' THEN

	IF p_stage is NOT null then
		pa_debug.g_err_stage := 'Stage :'|| substr(p_stage,1,250);
		pa_debug.write_file('LOG: '||pa_debug.g_err_stage);
		pa_debug.write('pa.plsql.PA_FUNDS_CONTROL_PKG','LOG: '||pa_debug.g_err_stage,3);
		g_error_stage := substr(p_stage,1,10);
	END IF;

	IF p_error_msg is NOT NULL then
		pa_debug.g_err_stage := 'Error Msg :'||substr(p_error_msg,1,250);
		pa_debug.write_file('LOG: '||pa_debug.g_err_stage);
		PA_DEBUG.write
                (x_Module       => 'pa.plsql.PA_FUNDS_CONTROL_PKG'
                ,x_Msg          => substr('LOG:'||p_error_msg,1,240)
                ,x_Log_Level    => 3);
		g_error_msg := p_error_msg;
	END IF;

	IF p_msg_token1 is NOT NULL or p_msg_token2 is NOT NULL then
	      IF p_msg_token2 is not null then
		 pa_debug.g_err_stage := substr(p_msg_token2,1,250);
		 pa_debug.write_file('LOG: '||pa_debug.g_err_stage);
		 pa_debug.write('pa.plsql.PA_FUNDS_CONTROL_PKG','LOG: '||pa_debug.g_err_stage,3);
	      END IF;
	      IF p_msg_token1 is NOT NULL then
		pa_debug.g_err_stage := substr(p_msg_token1,1,250);
		pa_debug.write_file('LOG: '||pa_debug.g_err_stage);
		PA_DEBUG.write
                (x_Module       => 'pa.plsql.PA_FUNDS_CONTROL_PKG'
                ,x_Msg          => substr('LOG:'||p_msg_token1,1,240)
                ,x_Log_Level    => 3);

	      END IF ;
	END IF;

     END IF; -- end of g_debug_mode
     return;

END log_message;

/** Bug fix:2302945  check whether the project is installed in this OU
 ** This api checks the records in pa_implementaions for the given OU if
 ** no records exits , it assumes that project is not installed in this OU
 **/
FUNCTION IS_PA_INSTALL_IN_OU RETURN VARCHAR2 is

	l_return_var    varchar2(10) := 'Y';

BEGIN
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'Inside IS_PA_INSTALL_IN_OU api');
	End If;
	SELECT 'Y'
	INTO   l_return_var
	FROM  pa_implementations;
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'End of IS_PA_INSTALL_IN_OU api return var:'||l_return_var);
	End If;
	Return l_return_var ;

EXCEPTION
	when NO_data_found then
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'End of IS_PA_INSTALL_IN_OU api return var:N');
	End If;
		return 'N';
	when Too_many_rows then
		return 'Y';
	When others then
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'Failed in IS_PA_INSTALL_IN_OU'||SQLERRM);
	End If;
		Raise;

END IS_PA_INSTALL_IN_OU;

-------------------------------------------------------------------------
-- This api checks  whether the Invoice is coming after the
-- interface from projects if the invoice is already interfaced
-- from projects then donot derive burden components
-- if the invoice system_linkage function is 'VI' then
-- derive budget ccid, encum type id, etc and DONOT do funds check
-- mark the invoice as approved and donot create encum liqd
-- if the invoice system linkage func is 'ER' then
-- derive budget ccid, encum type id, etc and DONOT funds check
-- mark the invoice as approved and create encum liqd for raw only
-- NOTE : IF THE PROJECT IS BURDEN ON SAME EI THEN DO NOTHING
-- ELSE DERIVE budget,encum type id,create encum liqd AND mark the
-- invoice as approved
-- R12 Note: This procedure is not longer used ... as the check for
--           expense report is carried out upfront and also from r12 on
--           VI txn. will no longer be interfaced back to AP ...
-- Not removing procedure as it can be used (if reqd..)
-------------------------------------------------------------------------
PROCEDURE is_ap_from_project
	(p_packet_id        IN  NUMBER,
	 p_calling_module   IN  VARCHAR2,
	 x_return_status    OUT NOCOPY VARCHAR2) IS

	PRAGMA AUTONOMOUS_TRANSACTION;

	--EXPLAIN PLAN IS:
	--1:SELECT STATEMENT   :(cost=269,rows=2)
  	--2:SORT UNIQUE  :(cost=269,rows=2)
    	--3:UNION-ALL   :(cost=,rows=)
      	--4:NESTED LOOPS   :(cost=137,rows=1)
       	--5:NESTED LOOPS   :(cost=122,rows=1)
        --6:TABLE ACCESS BY INDEX ROWID PA_BC_PACKETS :(cost=120,rows=1)
        --7:INDEX RANGE SCAN PA_BC_PACKETS_U1 :(cost=5,rows=1)
        --6:TABLE ACCESS BY INDEX ROWID PA_EXPENDITURE_ITEMS_ALL :(cost=2,rows=2345)
        --7:INDEX RANGE SCAN PA_EXPENDITURE_ITEMS_N9 :(cost=1,rows=2345)
        --5:TABLE ACCESS BY INDEX ROWID PA_COST_DISTRIBUTION_LINES_ALL :(cost=15,rows=47647)
        --6:INDEX RANGE SCAN PA_COST_DISTRIBUTION_LINES_U1 :(cost=1,rows=47647)
      	--4:NESTED LOOPS   :(cost=128,rows=1)
        --5:NESTED LOOPS   :(cost=121,rows=1)
        --6:TABLE ACCESS BY INDEX ROWID PA_BC_PACKETS :(cost=120,rows=1)
        --7:INDEX RANGE SCAN PA_BC_PACKETS_U1 :(cost=5,rows=1)
        --6:TABLE ACCESS BY INDEX ROWID AP_EXPENSE_REPORT_HEADERS_ALL :(cost=1,rows=290)
        --7:INDEX RANGE SCAN AP_EXPENSE_REPORT_HEADERS_N1 :(cost=,rows=290)
        --5:TABLE ACCESS FULL AP_EXPENSE_REPORT_LINES_ALL :(cost=7,rows=1260)

	CURSOR invoice_cdls is
	SELECT pbc.bc_packet_id,
	       pbc.project_id,
	       nvl(exp.system_linkage_function,'VI') system_linkage_function,
               pbc.burden_method_code
	FROM  pa_bc_packets pbc
	      ,pa_cost_distribution_lines_all cdl
	      ,pa_expenditure_items_all exp
	WHERE pbc.packet_id = p_packet_id
	AND   pbc.document_header_id = cdl.system_reference2
	AND   pbc.document_distribution_id = cdl.system_reference3
	AND   pbc.document_type = 'AP'
	AND   cdl.line_type = 'R'
	AND   cdl.expenditure_item_id = exp.expenditure_item_id
	AND   pbc.task_id = exp.task_id                            -- added to use index N9
	AND   pbc.expenditure_item_date = exp.expenditure_item_date --added to use index N9
	AND   exp.system_linkage_function in ('VI','ER')
	UNION
        SELECT pbc.bc_packet_id,
	       pbc.project_id,
               'ER' system_linkage_function,
               pbc.burden_method_code
        FROM  pa_bc_packets pbc
	      ,ap_expense_report_headers_all exphead
	      ,ap_expense_report_lines_all expline
	WHERE pbc.packet_id = p_packet_id
	AND   pbc.document_header_id = exphead.vouchno
	AND   pbc.set_of_books_id  = exphead.set_of_books_id
        AND   exphead.report_header_id = expline.report_header_id  /* added for bug#2634995 */
	AND   pbc.document_distribution_id = expline.distribution_line_number
	AND   pbc.document_type = 'AP'
	AND   pbc.project_id = expline.project_id
	AND   pbc.task_id    = expline.task_id
	AND   pbc.expenditure_type = expline.expenditure_type
	AND   pbc.set_of_books_id = expline.set_of_books_id;

	l_num_rows   NUMBER := 100;
	l_pre_project_id   NUMBER := NULL;
	l_burden_method    VARCHAR2(50);
	l_pre_burden_method  varchar2(50);

BEGIN
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'Inside the is_ap_from project api');
	End If;

	--Initialize the error stack
	PA_DEBUG.init_err_stack('PA_FUNDS_CONTROL_PKG.is_ap_from_project');

	x_return_status := 'S';

	IF p_calling_module = 'GL' then
		OPEN invoice_cdls;
		LOOP
			--Initialize the plsql tables
			Init_plsql_tabs;

			FETCH invoice_cdls BULK COLLECT INTO
				g_tab_bc_packet_id,
				g_tab_project_id,
				g_tab_sys_link_func,
                                g_tab_burden_method_code  LIMIT l_num_rows;

			If NOT g_tab_bc_packet_id.EXISTS(1) then
				IF g_debug_mode = 'Y' THEN
				    log_message(p_msg_token1 => 'this Invoice is Not interfaced from Project');
				End If;
				EXIT;
			else
				IF g_debug_mode = 'Y' THEN
				   log_message(p_msg_token1 => 'this Invoice is interfaced from projects');
				End If;
				null;
			End if;
			FOR i IN g_tab_bc_packet_id.FIRST .. g_tab_bc_packet_id.LAST LOOP

			 	IF g_tab_bc_packet_id(i) is NOT NULL then

                                   If g_tab_burden_method_code(i) is NULL then

				  	IF g_tab_project_id(i) <> l_pre_project_id
						or l_pre_project_id is NULL then

				   		l_burden_method :=check_bdn_on_sep_item (g_tab_project_id(i));
						l_pre_burden_method := l_burden_method;
				  	Else
						l_burden_method := l_pre_burden_method;
				  	End if;

                                     Else
                                         l_burden_method := g_tab_burden_method_code(i);
                                         l_pre_burden_method := l_burden_method;

                                     End If; -- If g_tab_burden_method_code(i) is NULL then

					IF g_debug_mode = 'Y' THEN
					   log_message(p_msg_token1 => 'burden method ['||l_burden_method||
						  ']g_tab_sys_link_func['||g_tab_sys_link_func(i)||']' );
					End If;


			    		IF g_tab_sys_link_func(i) = 'VI' then
						--If l_burden_method = 'SAME' then
						If l_burden_method = 'S' then
							g_tab_status_code(i) := 'V';
						Else
							g_tab_status_code(i) := 'L';
						End if;
						g_tab_result_code(i) := 'P114';
						g_tab_r_result_code(i) := 'P114';
						g_tab_rg_result_code(i) := 'P114';
						g_tab_t_result_code(i) := 'P114';
						g_tab_tt_result_code(i) := 'P114';
						g_tab_p_result_code(i) := 'P114';
						g_tab_p_acct_result_code(i) := 'P114';
			    		Elsif g_tab_sys_link_func(i) = 'ER' then
                                                --If l_burden_method = 'SAME' then
                                                If l_burden_method = 'S' then
                                                        g_tab_status_code(i) := 'V';
                                                Else
                                                        g_tab_status_code(i) := 'L';
                                                End if;
                                		g_tab_result_code(i) := 'P115';
                                		g_tab_r_result_code(i) := 'P115';
                                		g_tab_rg_result_code(i) := 'P115';
                                		g_tab_t_result_code(i) := 'P115';
                                		g_tab_tt_result_code(i) := 'P115';
                                		g_tab_p_result_code(i) := 'P115';
                                		g_tab_p_acct_result_code(i) := 'P115';
			    		End if;
					l_pre_project_id := g_tab_project_id(i);
				End if;
			END LOOP;

			--update the result and status code in pa bc packets
			FORALL i IN g_tab_bc_packet_id.FIRST .. g_tab_bc_packet_id.LAST
				UPDATE pa_bc_packets
				SET status_code = g_tab_status_code(i),
                                    result_code =    g_tab_result_code(i),
                                    res_result_code =   g_tab_r_result_code(i),
                                    res_grp_result_code = g_tab_rg_result_code(i),
                                    task_result_code =     g_tab_t_result_code(i),
                                    top_task_result_code = g_tab_tt_result_code(i),
                                    project_result_code =   g_tab_p_result_code(i),
                                    project_acct_result_code = g_tab_p_acct_result_code(i)
				WHERE bc_packet_id = g_tab_bc_packet_id(i)
				AND   packet_id    = p_packet_id;
			EXIT WHEN invoice_cdls%NOTFOUND;
		END LOOP;
		CLOSE invoice_cdls;

	End IF;
	IF g_debug_mode = 'Y' THEN
	    log_message(p_msg_token1 => 'End of is_ap_from_project api');
	End If;
	PA_DEBUG.reset_err_stack;
	commit; -- to end an active autonmous transaction
	return;

EXCEPTION
	when others then
		x_return_status := 'T';
		IF g_debug_mode = 'Y' THEN
		   log_message(p_msg_token1 => 'failed in is_ap_from_project api SQLERR ['||sqlcode||sqlerrm||']');
		End If;
		--commit;

		--Raise;
END is_ap_from_project;


--------------------------------------------------------------------------------------------------------
--Procedure to be called inside check_funds_available to generate result code and status for each record.
-------------------------------------------------------------------------------------------------------
PROCEDURE generate_result_code(
      	p_fclevel_code 		IN   	 VARCHAR2 DEFAULT 'B',
      	p_available_amt       	IN       NUMBER DEFAULT 0,
      	p_stage                	IN       VARCHAR2 DEFAULT 0,
      	p_budget_posted_amt    	IN       NUMBER DEFAULT 0,
      	x_result_code      	IN OUT NOCOPY   VARCHAR2,
      	x_r_result_code      	IN OUT NOCOPY   VARCHAR2,
      	x_rg_result_code      	IN OUT NOCOPY   VARCHAR2,
      	x_t_result_code      	IN OUT NOCOPY   VARCHAR2,
      	x_tt_result_code     	IN OUT NOCOPY   VARCHAR2,
      	x_p_result_code     	IN OUT NOCOPY   VARCHAR2,
	x_p_acct_result_code    IN OUT NOCOPY   VARCHAR2,
	x_return_status         IN OUT NOCOPY   VARCHAR2
      ) IS
BEGIN
	IF g_debug_mode = 'Y' THEN
	   log_message(p_msg_token1 => 'p_fclevel_code ['||p_fclevel_code||']p_available_amt['||p_available_amt||
		    ']p_stage ['||p_stage||']p_budget_posted_amt ['||p_budget_posted_amt||']' );
	End If;

	-- p_stage
	--      100 Resource Level
	--      200 Resource Group Level
	--      300 Task Level
	--      400 Top Task Level
	--      500 Project Level
	--      600 Project Account Level
	/*** Bug Fix :1892535 if the budget amount is zero and
         *   available amount(transaction amount) is zero then transaction should pass
	 *   funds check
	 *   Example   budget for project p1  = 500 task t1 = 500 resource r1 = 0 for period jan-01
	 *             Transactions  project  task resource  period  acct_dr  acct_cr
	 *                   1         p1      t1    r1      jan-01    -       1000
         *                   2         p1      t1    r1      jan-01   1000       -
	 *   	       ideally the net effect of the both transactions are zero so they must pass
	 *             funds check

      	IF     NVL ( p_budget_posted_amt, 0 ) = 0
         	AND NVL ( p_available_amt, 0 ) = 0
         	AND p_fclevel_code = 'B' THEN

         	IF p_stage = 100 THEN
			-- msg : F101 = No budget at resource level
			x_result_code  := 'F101';
            		x_r_result_code := 'F101';
            		x_rg_result_code := 'F101';
            		x_t_result_code := 'F101';
            		x_tt_result_code := 'F101';
            		x_p_result_code := 'F101';
                        x_p_acct_result_code := 'F101';
         	ELSIF p_stage = 200 THEN
			-- msg : F102 = No budget at resource Group level
			x_result_code  := 'F102';
            		x_rg_result_code := 'F102';
            		x_t_result_code := 'F102';
            		x_tt_result_code := 'F102';
            		x_p_result_code := 'F102';
                        x_p_acct_result_code := 'F102';
         	ELSIF p_stage = 300 THEN
			-- msg : F103 = No budget at task level
			x_result_code  := 'F103';
            		x_t_result_code := 'F103';
            		x_tt_result_code := 'F103';
            		x_p_result_code := 'F103';
                        x_p_acct_result_code := 'F103';
         	ELSIF p_stage = 400 THEN
			-- msg : F104 = No budget at top task level
			x_result_code  := 'F104';
            		x_tt_result_code := 'F104';
            		x_p_result_code := 'F104';
                        x_p_acct_result_code := 'F104';
         	ELSIF p_stage = 500 THEN
			-- msg : F105 = No budget at Project level
			x_result_code  := 'F105';
            		x_p_result_code := 'F105';
                        x_p_acct_result_code := 'F105';
		ELSIF p_stage = 600 THEN
			-- msg : F106 = No budget at project acct level
			x_result_code  := 'F106';
			x_p_acct_result_code := 'F106';

         	END IF;
		x_return_status := 'F';
         	RETURN;
      	END IF;

	********end of bug fix:1892535 ***/

	-- check if the funds control level code is none then
	-- pass the transaction
      	IF p_fclevel_code = 'N' THEN

         	IF p_stage = 100 THEN
			x_result_code  := 'P111';
            		x_r_result_code := 'P111';
         	ELSIF p_stage = 200 THEN
			x_result_code  := 'P109';
            		x_rg_result_code := 'P109';
         	ELSIF p_stage = 300 THEN
			x_result_code  := 'P107';
            		x_t_result_code := 'P107';
         	ELSIF p_stage = 400 THEN
			x_result_code  := 'P105';
            		x_tt_result_code := 'P105';
         	ELSIF p_stage = 500 THEN
			x_result_code  := 'P103';
            		x_p_result_code := 'P103';
		ELSIF p_stage = 600 THEN
			x_result_code  := 'P101';
			x_p_acct_result_code := 'P101';
         	END IF;

         	x_return_status := 'P';
      	END IF;

	-- check if teh funds control level code is Absolute or Advisory
	-- if absolute then check whether the funds avaiabl with in the limit
	-- if so pass the transaction otherwise fail the transaction
	-- if the control level code is advisory then pass the transaction with
	-- warning if exceeds the available amount
	/** Bug fix : 1975786 p_fclevel_code D - advisory is changed to A
         *  since the lookup code is changed from D - A
	 *  initial lookup codes B - Absolute,  D - Advisory N - None
	 *  changed lookup codes B - Absolute, A - Advisory N - None
	 **/
        IF  p_fclevel_code IN ( 'B', 'A' )  and  p_available_amt  >= 0  then
            	IF p_stage = 100 THEN
			x_result_code  := 'P111';
               		x_r_result_code := 'P111';
            	ELSIF p_stage = 200 THEN
			x_result_code  := 'P109';
               		x_rg_result_code := 'P109';
            	ELSIF p_stage = 300 THEN
			x_result_code  := 'P107';
               		x_t_result_code := 'P107';
            	ELSIF p_stage = 400 THEN
			x_result_code  := 'P105';
               		x_tt_result_code := 'P105';
            	ELSIF p_stage = 500 THEN
			x_result_code  := 'P103';
               		x_p_result_code := 'P103';
		ELSIF  p_stage = 600 THEN
			x_result_code  := 'P101';
			x_p_acct_result_code := 'P101';
            	END IF;

            	x_return_status := 'P';

   	ELSIF    p_fclevel_code = 'A' and  p_available_amt  < 0  then
            	IF p_stage = 100 THEN
			x_result_code  := 'P112';
               		x_r_result_code := 'P112';
            	ELSIF p_stage = 200 THEN
			x_result_code  := 'P110';
               		x_rg_result_code := 'P110';
            	ELSIF p_stage = 300 THEN
			x_result_code  := 'P108';
               		x_t_result_code := 'P108';
            	ELSIF p_stage = 400 THEN
			x_result_code  := 'P106';
               		x_tt_result_code := 'P106';
            	ELSIF p_stage = 500 THEN
			x_result_code  := 'P104';
               		x_p_result_code := 'P104';
		ELSIF p_stage = 600 THEN
			x_result_code  := 'P102';
			x_p_acct_result_code := 'P102';
            	END IF;

            	x_return_status := 'P';

       	ELSIF   p_fclevel_code = 'B' AND  p_available_amt < 0  then
		/** Bug :1969608 fix added If conditions, if the budget amount is zero
		 * to display the proper error message
		 **/
            	IF p_stage = 100 THEN

			If  NVL ( p_budget_posted_amt, 0 ) = 0  then
	                        -- msg : F101 = No budget at resource level
                        	x_result_code  := 'F101';
                        	x_r_result_code := 'F101';
                        	x_rg_result_code := 'F101';
                        	x_t_result_code := 'F101';
                        	x_tt_result_code := 'F101';
                        	x_p_result_code := 'F101';
                        	x_p_acct_result_code := 'F101';

			Else
				-- msg : F108 Failed at resource level
				x_result_code  := 'F108';
               			x_r_result_code := 'F108';
               			x_rg_result_code := 'F108';
               			x_t_result_code := 'F108';
               			x_tt_result_code := 'F108';
               			x_p_result_code := 'F108';
                        	x_p_acct_result_code := 'F108';
			End if;
            	ELSIF p_stage = 200 THEN

			If NVL ( p_budget_posted_amt, 0 ) = 0  then
                        	-- msg : F102 = No budget at resource Group level
                        	x_result_code  := 'F102';
                        	x_rg_result_code := 'F102';
                        	x_t_result_code := 'F102';
                        	x_tt_result_code := 'F102';
                        	x_p_result_code := 'F102';
                        	x_p_acct_result_code := 'F102';

			Else
				-- msg : F109 Failed at resource group level
				x_result_code  := 'F109';
               			x_rg_result_code := 'F109';
               			x_t_result_code := 'F109';
               			x_tt_result_code := 'F109';
               			x_p_result_code := 'F109';
                        	x_p_acct_result_code := 'F109';
			End if;
            	ELSIF p_stage = 300 THEN

			If  NVL ( p_budget_posted_amt, 0 ) = 0  then
                        	-- msg : F103 = No budget at task level
                        	x_result_code  := 'F103';
                        	x_t_result_code := 'F103';
                        	x_tt_result_code := 'F103';
                        	x_p_result_code := 'F103';
                        	x_p_acct_result_code := 'F103';

			Else
				-- msg : F110 failed at task level
				x_result_code  := 'F110';
               			x_t_result_code := 'F110';
               			x_tt_result_code := 'F110';
               			x_p_result_code := 'F110';
                        	x_p_acct_result_code := 'F110';
			End if;
            	ELSIF p_stage = 400 THEN

			If  NVL ( p_budget_posted_amt, 0 ) = 0  then

                        	-- msg : F104 = No budget at top task level
                        	x_result_code  := 'F104';
                        	x_tt_result_code := 'F104';
                        	x_p_result_code := 'F104';
                        	x_p_acct_result_code := 'F104';

			Else
				-- msg : F111 Failed at top task level
				x_result_code  := 'F111';
               			x_tt_result_code := 'F111';
               			x_p_result_code := 'F111';
                        	x_p_acct_result_code := 'F111';
			End if;
            	ELSIF p_stage = 500 THEN

			If  NVL ( p_budget_posted_amt, 0 ) = 0 then
                        	-- msg : F105 = No budget at Project level
                        	x_result_code  := 'F105';
                        	x_p_result_code := 'F105';
                        	x_p_acct_result_code := 'F105';

			Else
				-- msg : F112 Failed at the project level
				x_result_code  := 'F112';
               			x_p_result_code := 'F112';
                        	x_p_acct_result_code := 'F112';
			End if;
		ELSIF p_stage = 600 THEN

			If  NVL ( p_budget_posted_amt, 0 ) = 0  then
                        	-- msg : F106 = No budget at project acct level
                        	x_result_code  := 'F106';
                        	x_p_acct_result_code := 'F106';

			Else
				-- msg : F113 failed at the project acct level
				x_result_code  := 'F113';
				x_p_acct_result_code := 'F113';
			End if;
            	END IF;

            	x_return_status := 'F';
        END IF;
	IF g_debug_mode = 'Y' THEN
	  log_message(p_msg_token1 => 'x_result_code ='||x_result_code||']x_r_result_code['||x_r_result_code||
          ']x_rg_result_code ['||x_rg_result_code||']x_t_result_code ['||x_t_result_code||
	  ']x_tt_result_code ['||x_tt_result_code||']x_p_result_code ['||x_p_result_code||
	  ']x_p_acct_rresult_code ['||x_p_acct_result_code||']' );
	End If;


EXCEPTION
      	WHEN OTHERS THEN
		IF g_debug_mode = 'Y' THEN
                   log_message(p_msg_token1 => 'failed in generate result code api SQLERR :'||sqlcode||sqlerrm);
		End If;
                --commit;
         	RAISE;
END generate_result_code;
----------------------------------------------------------------------------------------
-- This Api caches the pa bc packets amounts based on the
-- same resource resource grp , project , task etc,
-----------------------------------------------------------------------------------------
PROCEDURE   CACHE_PKT_AMOUNTS(
                p_project_id          	in pa_bc_packets.project_id%type
                ,p_bdgt_version 	in pa_bc_packets.budget_version_id%type
                ,p_top_task_id  	in pa_bc_packets.top_task_id%type
                ,p_task_id      	in pa_bc_packets.task_id%type
                ,p_bud_task_id  	in pa_bc_packets.bud_task_id%type
                ,p_start_date   	in  DATE
                ,p_end_date     	in  DATE
                ,p_rlmi         	in pa_bc_packets.resource_list_member_id%type
                ,p_bud_rlmi     	in pa_bc_packets.bud_resource_list_member_id%type
                ,p_prlmi        	in pa_bc_packets.parent_resource_id%type
		,p_bdgt_ccid		in pa_bc_packets.budget_ccid%type
		,p_accounted_dr		in number
		,p_accounted_cr		in number
		,p_calling_module	in varchar2
                ,p_partial_flag         in varchar2
		,p_function		in varchar2  -- add or deduct amts from cache
		,p_bc_packet_id		in number
		,p_doc_type		in varchar2
		,p_doc_header_id        in number
		,p_doc_distribution_id  in number
		,x_cached_status        out NOCOPY varchar2
		,x_result_code          in out NOCOPY varchar2
                ,p_counter      	in number
                ) IS
	l_res_level_cache    	VARCHAR2(100);
	l_res_grp_level_cache   VARCHAR2(100);
	l_task_level_cache    	VARCHAR2(100);
	l_top_task_level_cache 	VARCHAR2(100);
	l_proj_level_cache	VARCHAR2(100);
	l_proj_acct_level_cache	VARCHAR2(100);
	l_res_level_count	NUMBER;
	l_res_grp_level_count	NUMBER;
	l_task_level_count	NUMBER;
	l_top_task_level_count	NUMBER;
	l_proj_level_count	NUMBER;
	l_proj_acct_level_count	NUMBER;
	l_new_resource          VARCHAR2(1);
	l_new_resource_group    VARCHAR2(1);
	l_new_task		VARCHAR2(1);
	l_new_top_task		VARCHAR2(1);
	l_new_proj		VARCHAR2(1);
	l_new_proj_acct		VARCHAR2(1);
	l_cache_amt_minus       number;
	l_result_code 		VARCHAR2(100);
	l_res_level_cache_minus  VARCHAR2(100);
	l_rg_level_cache_minus  VARCHAR2(100);
	l_task_level_cache_minus  VARCHAR2(100);
	l_tt_level_cache_minus  VARCHAR2(100);
	l_proj_level_cache_minus VARCHAR2(100);
	l_p_acct_level_cache_minus  VARCHAR2(100);
	l_number  number;
BEGIN

	IF p_partial_flag  = 'Y' then
	 IF g_debug_mode = 'Y' THEN
	     log_message(p_msg_token1 => 'assiging the amts to cache');
	 End If;

	-- Resource level cache
        l_res_level_cache := p_project_id||p_bdgt_version||p_bud_task_id||p_prlmi||
                                p_rlmi||trunc(p_start_date)||trunc(p_end_date);
        l_res_level_count := nvl(g_tab_res_level_cache.count,0);

	-- Resource Group level cache
        l_res_grp_level_cache := p_project_id||p_bdgt_version||p_bud_task_id||p_prlmi||
                                trunc(p_start_date)||trunc(p_end_date);
        l_res_grp_level_count := nvl(g_tab_res_grp_level_cache.count,0);

	-- Task level cache
        l_task_level_cache := p_project_id||p_bdgt_version||p_top_task_id||p_task_id||
                                trunc(p_start_date)||trunc(p_end_date);
        l_task_level_count := nvl(g_tab_task_level_cache.count,0);

	-- Top level cache
        l_top_task_level_cache := p_project_id||p_bdgt_version||p_top_task_id||
                                trunc(p_start_date)||trunc(p_end_date);
        l_top_task_level_count := nvl(g_tab_top_task_level_cache.count,0);

	-- Project level cache
        l_proj_level_cache := p_project_id||p_bdgt_version||trunc(p_start_date)||trunc(p_end_date);
        l_proj_level_count := nvl(g_tab_proj_level_cache.count,0);

	--project account level cache
        l_proj_acct_level_cache := p_project_id||p_bdgt_version||p_bdgt_ccid||
				   trunc(p_start_date)||trunc(p_end_date);
        l_proj_acct_level_count := nvl(g_tab_proj_acct_level_cache.count,0);
	IF g_debug_mode = 'Y' THEN
	   log_message(p_msg_token1 => 'end of assiging the amts to cache');
	End If;

	End if;

	-- check if the same header_id is already failed then donot cache and donot
	-- funds check just update the status and result code to failed
	IF p_function = 'ADD' then
		IF g_debug_mode = 'Y' THEN
		   log_message(p_msg_token1 => 'inside ADD function');
		End If;
		x_result_code := null;
		x_cached_status := 'Y';
		--IF  g_tab_doc_header_id.count > 0 then
		IF   nvl(p_counter,0) > 1 then
		    --FOR i in 1 .. g_tab_doc_header_id.count LOOP
		    FOR i in 1 .. p_counter -1  LOOP
			 /* FOR DISTERADJ and CBC process check at document header level
			  * even if single transaction found error then
                          * mark the current transaction as failed
			  * FOR GL,BASELINE process check at the document distribution
			  * level
			  */
			   IF  (p_doc_header_id =  g_tab_doc_header_id(i) and
		   		p_doc_type = g_tab_doc_type(i)  and
				p_calling_module in ('DISTBTC','DISTERADJ','CBC','EXPENDITURE','DISTCWKST','DISTVIADJ'
						    ,'TRXIMPORT','RESERVE_BASELINE') and
		   		p_bc_packet_id <> g_tab_bc_packet_id(i) )
			     OR
			       (p_doc_header_id =  g_tab_doc_header_id(i) and
                                p_doc_type = g_tab_doc_type(i)  and
				p_doc_distribution_id  = g_tab_doc_distribution_id(i) and
                                p_calling_module  IN ('GL') and
                                p_bc_packet_id <> g_tab_bc_packet_id(i) ) Then

				If substr(g_tab_result_code(i),1,1) = 'F' then
					x_result_code := g_tab_result_code(i);
					IF g_debug_mode = 'Y' THEN
					  log_message(p_msg_token1 => 'failed documnet header found');
					End If;
				End If;
			End if;
		   END LOOP;
	        End if;
		IF g_debug_mode = 'Y' THEN
		   log_message(p_msg_token1 => 'end of  ADD function');
		End If;
		If substr(x_result_code,1,1) = 'F' then
			x_cached_status := 'N';
			return;
		End if;
	End if;


	IF p_function = 'MINUS' then
		IF g_debug_mode = 'Y' THEN
		    log_message(p_msg_token1 => 'Inside MINUS if condition');
		End If;

	     IF p_partial_flag <> 'Y' then
                g_r_pkt_amt  := NVL(g_r_pkt_amt,0)
                                - (NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0));
                g_rg_pkt_amt  := NVL(g_rg_pkt_amt,0)
                                - (NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0));
                g_t_pkt_amt  := NVL(g_t_pkt_amt,0)
                                - (NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0));
                g_tt_pkt_amt  := NVL(g_tt_pkt_amt,0)
                                - (NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0));
                g_p_pkt_amt  := NVL(g_p_pkt_amt,0)
                                - (NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0));
                g_p_acct_pkt_amt  := NVL(g_p_acct_pkt_amt,0)
                                - (NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0));

	    END IF;

	    IF p_partial_flag = 'Y' then
        	-- check if the same header id is already passed but this raw / burden line fails
        	-- then deduct that amount from the passed line and synchonize the status and result
        	-- codes for minus
        	l_result_code := x_result_code;
        	l_cache_amt_minus := 0;
		IF g_debug_mode = 'Y' THEN
		   log_message(p_msg_token1 => 'check g_tab_doc_header_id.count ');
		End If;
		--IF g_tab_doc_header_id.count > 0 then
		IF nvl(p_counter,0) > 1 then
		  IF g_debug_mode = 'Y' THEN
		    log_message(p_msg_token1 => 'opening cursor  num = '||g_tab_doc_header_id.count );
		  End If;
        	  FOR i in 1 .. p_counter - 1 LOOP
                	If (p_doc_header_id =  g_tab_doc_header_id(i) and
                   		p_doc_type = g_tab_doc_type(i)  and
                                p_calling_module in ('DISTBTC','DISTERADJ','CBC','EXPENDITURE','DISTCWKST','DISTVIADJ'
                                                    ,'TRXIMPORT','RESERVE_BASELINE') and
                                p_bc_packet_id <> g_tab_bc_packet_id(i) )
                             OR
                               (p_doc_header_id =  g_tab_doc_header_id(i) and
                                p_doc_type = g_tab_doc_type(i)  and
                                p_doc_distribution_id  = g_tab_doc_distribution_id(i) and
                                p_calling_module  IN ('GL') and
                                p_bc_packet_id <> g_tab_bc_packet_id(i) ) then

                        	If substr(g_tab_result_code(i),1,2) = 'P1'
				   and g_tab_start_date.EXISTS(i) and g_tab_end_date.EXISTS(i)  then

                                	l_cache_amt_minus := nvl(g_tab_accounted_dr(i),0)
							    - nvl(g_tab_accounted_cr(i),0);
					IF g_debug_mode = 'Y' THEN
					   log_message(p_msg_token1 => 'l_res_level_cache_minus, bc_packet_id ['
								  ||p_bc_packet_id||']g_tab_proj count['||
						                  g_tab_project_id(i)||']');
					End IF;

				        l_res_level_cache_minus :=
					g_tab_project_id(i)||g_tab_budget_version_id(i)||g_tab_bud_task_id(i)
					||g_tab_p_resource_id(i)||g_tab_rlmi(i)||trunc(g_tab_start_date(i))||
					trunc(g_tab_end_date(i));
					IF g_debug_mode = 'Y' THEN
						log_message(p_msg_token1 => 'l_rg_level_cache_minus');
					End If;

					l_rg_level_cache_minus :=
                                        g_tab_project_id(i)||g_tab_budget_version_id(i)||g_tab_bud_task_id(i)
                                        ||g_tab_p_resource_id(i)||trunc(g_tab_start_date(i))||trunc(g_tab_end_date(i));
			                IF g_debug_mode = 'Y' THEN
					      log_message(p_msg_token1 => 'l_task_level_cache_minus');
					End If;
					l_task_level_cache_minus :=
                                        g_tab_project_id(i)||g_tab_budget_version_id(i)||g_tab_tt_task_id(i)
                                        ||g_tab_task_id(i)||trunc(g_tab_start_date(i))||trunc(g_tab_end_date(i));

					IF g_debug_mode = 'Y' THEN
					     log_message(p_msg_token1 =>'l_tt_level_cache_minus');
					End If;
					l_tt_level_cache_minus :=
                                        g_tab_project_id(i)||g_tab_budget_version_id(i)||g_tab_tt_task_id(i)
                                        ||trunc(g_tab_start_date(i))||trunc(g_tab_end_date(i));
					IF g_debug_mode = 'Y' THEN
						log_message(p_msg_token1 =>'l_proj_level_cache_minus');
					End If;

                                        l_proj_level_cache_minus :=
                                        g_tab_project_id(i)||g_tab_budget_version_id(i)
                                        ||trunc(g_tab_start_date(i))||trunc(g_tab_end_date(i));
					IF g_debug_mode = 'Y' THEN
						log_message(p_msg_token1 =>'l_p_acct_level_cache_minus');
					End if;

                                        l_p_acct_level_cache_minus :=
                                        g_tab_project_id(i)||g_tab_budget_version_id(i)||g_tab_budget_ccid(i)
                                        ||trunc(g_tab_start_date(i))||trunc(g_tab_end_date(i));

                        	     -- Resource level
				IF g_debug_mode = 'Y' THEN
				  log_message(p_msg_token1 =>'check l_res_level_count > 0');
				End If;
				   IF l_res_level_count > 0 then
					IF g_debug_mode = 'Y' THEN
						log_message(p_msg_token1 =>'count = '||l_res_level_count);
					End if;
                        	     FOR  j IN 1 .. l_res_level_count LOOP
					IF g_debug_mode = 'Y' THEN
                                		log_message(p_msg_token1 => 'Iside for loop Resource level ');
					End IF;
                                	If g_tab_res_level_cache(j) = l_res_level_cache_minus then
						IF g_debug_mode = 'Y' THEN
                                        		log_message(p_msg_token1 =>'minus cache found');
						End If;
                                        	g_tab_res_level_cache_amt(j) :=
                                          	NVL(g_tab_res_level_cache_amt(j),0) -
                                          	 nvl(l_cache_amt_minus,0);
                                             EXIT;
                                	END IF;
                        	     END LOOP;
				   End if;

                        	     -- Resource Group level
				   IF l_res_grp_level_count > 0 then
                        	     FOR  j IN 1 .. l_res_grp_level_count LOOP
					IF g_debug_mode = 'Y' THEN
                                	   log_message(p_msg_token1 => 'Inside for loop Resource Group level');
					End If;
                                	If g_tab_res_grp_level_cache(j) = l_rg_level_cache_minus then
					    IF g_debug_mode = 'Y' THEN
                                               log_message(p_msg_token1 =>'minus cahce found at res grp');
					    End If;
                                        	g_tab_res_grp_level_cache_amt(j) :=
                                          	NVL(g_tab_res_grp_level_cache_amt(j),0) -
                                          	nvl(l_cache_amt_minus,0);
                                        	EXIT;
                                	END IF;
                        	     END LOOP;
				   End if;
                        	     -- Task level
				   IF l_task_level_count > 0 then
                        	     FOR  j IN 1 .. l_task_level_count LOOP
					IF g_debug_mode = 'Y' THEN
                                	    log_message(p_msg_token1 => 'Inside for loop minus Task level');
					End IF;
                                	If g_tab_task_level_cache(j) = l_task_level_cache_minus then
						IF g_debug_mode = 'Y' THEN
                                        		log_message(p_msg_token1 =>'minus cahce found at task level');
						End If;
                                        	g_tab_task_level_cache_amt(j) :=
                                          	NVL(g_tab_task_level_cache_amt(j),0) -
						nvl(l_cache_amt_minus,0);
                                        	EXIT;
                                	END IF;
                        	     END LOOP;
				   End if;

                        	     -- Top task level
				   IF l_top_task_level_count > 0 then
                        	     FOR  j IN 1 .. l_top_task_level_count LOOP
					IF g_debug_mode = 'Y' THEN
                                		log_message(p_msg_token1 => 'Inside for loop minus Top task level');
					End If;
                                	If g_tab_top_task_level_cache(j) = l_tt_level_cache_minus then
						IF g_debug_mode = 'Y' THEN
                                        		log_message(p_msg_token1 =>'minus cahce found at tt');
						End If;
                                        	g_tab_top_task_level_cache_amt(j) :=
                                          	NVL(g_tab_top_task_level_cache_amt(j),0) -
                                          	nvl(l_cache_amt_minus,0);
                                        	EXIT;
                                	END IF;
                        	     END LOOP;
				   End if;
                        	     -- Project level
				   IF l_proj_level_count > 0 then
                        	     FOR  j IN 1 .. l_proj_level_count LOOP
					IF g_debug_mode = 'Y' THEN
                                		log_message(p_msg_token1 => 'Inside for loop at Project level');
					End If;
                                	If g_tab_proj_level_cache(j) = l_proj_level_cache_minus then
						IF g_debug_mode = 'Y' THEN
                                         		log_message(p_msg_token1 =>'minus cahce found at proj');
						End If;
                                        	g_tab_proj_level_cache_amt(j) :=
                                          	NVL(g_tab_proj_level_cache_amt(j),0) -
                                                nvl(l_cache_amt_minus,0);
                                        	EXIT;
                                	END IF;
                        	     END LOOP;
				   End if;
                        	     -- Project account level
				   IF l_proj_acct_level_count > 0 then
                        	     FOR  j IN 1 .. l_proj_acct_level_count LOOP
					IF g_debug_mode = 'Y' THEN
                                		log_message(p_msg_token1 => 'inside for loop minus Project account level');
					End If;
                                	If g_tab_proj_acct_level_cache(j) = l_p_acct_level_cache_minus then
						IF g_debug_mode = 'Y' THEN
                                        		log_message(p_msg_token1 =>'minus cahce found at p acct');
						End if;
                                        	g_tab_prj_acct_level_cache_amt(j) :=
                                          	NVL(g_tab_prj_acct_level_cache_amt(j),0) -
						nvl(l_cache_amt_minus,0);
                                        	EXIT;
                                	END IF;
                        	     END LOOP;
				   End if;
					IF g_debug_mode = 'Y' THEN
						log_message(p_msg_token1 => 'passed documnet header found['||l_result_code||']' );
					End IF;
                                	g_tab_result_code(i) := l_result_code ;
                        	End If;
                	End if;
        	   END LOOP;
		End if;

		---Deduct the amount from present failed document
			-- Resource level
		  IF l_res_level_count > 0 then
                        FOR  I IN 1 .. l_res_level_count LOOP
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Iside for loop Resource level');
				End If;
                                If g_tab_res_level_cache(I) = l_res_level_cache then
					IF g_debug_mode = 'Y' THEN
                                        	log_message(p_msg_token1 =>'same cahce found');
					End If;
                                        g_tab_res_level_cache_amt(I) :=
                                          NVL(g_tab_res_level_cache_amt(I),0) -
                                          (NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0));

                                        g_r_pkt_amt  := g_tab_res_level_cache_amt(I);
                                        EXIT;
                                END IF;
                        END LOOP;
		 End if;
			-- Resource Group level
		 If l_res_grp_level_count > 0 then
                        FOR  I IN 1 .. l_res_grp_level_count LOOP
				IF g_debug_mode = 'Y' THEN
                                    log_message(p_msg_token1 => 'Iside for loop Resource Group level');
				End if;
                                If g_tab_res_grp_level_cache(I) = l_res_grp_level_cache then
					IF g_debug_mode = 'Y' THEN
                                        	log_message(p_msg_token1 =>'same cahce found');
					End if;
                                        g_tab_res_grp_level_cache_amt(I) :=
                                          NVL(g_tab_res_grp_level_cache_amt(I),0) -
                                          (NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0));

                                        g_rg_pkt_amt  := g_tab_res_grp_level_cache_amt(I);
                                        EXIT;
                                END IF;
                        END LOOP;
		 End if ;
			-- Task level
		 If l_task_level_count > 0 then
                        FOR  I IN 1 .. l_task_level_count LOOP
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Iside for loop Task level');
				End IF;
                                If g_tab_task_level_cache(I) = l_task_level_cache then
					IF g_debug_mode = 'Y' THEN
                                        	log_message(p_msg_token1 =>'same cahce found');
					End IF;
                                        g_tab_task_level_cache_amt(I) :=
                                          NVL(g_tab_task_level_cache_amt(I),0) -
                                          (NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0));
                                        g_t_pkt_amt  := g_tab_task_level_cache_amt(I);
                                        EXIT;
                                END IF;
                        END LOOP;
		End if;
			-- Top task level
		IF l_top_task_level_count > 0 then
                        FOR  I IN 1 .. l_top_task_level_count LOOP
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Iside for loop Top task level');
				End IF;
                                If g_tab_top_task_level_cache(I) = l_top_task_level_cache then
					IF g_debug_mode = 'Y' THEN
                                        	log_message(p_msg_token1 =>'same cahce found');
					End IF;
                                        g_tab_top_task_level_cache_amt(I) :=
                                          NVL(g_tab_top_task_level_cache_amt(I),0) -
                                          (NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0));
                                        g_tt_pkt_amt  := g_tab_top_task_level_cache_amt(I);
                                        EXIT;
                                END IF;
                        END LOOP;
		End if;
			-- Project level
		IF l_proj_level_count > 0 then
                        FOR  I IN 1 .. l_proj_level_count LOOP
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Iside for loop Project level ');
				End if;
                                If g_tab_proj_level_cache(I) = l_proj_level_cache then
					IF g_debug_mode = 'Y' THEN
                                        	log_message(p_msg_token1 =>'same cahce found');
					End IF;
                                        g_tab_proj_level_cache_amt(I) :=
                                          NVL(g_tab_proj_level_cache_amt(I),0) -
                                          (NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0));
                                        g_p_pkt_amt  := g_tab_proj_level_cache_amt(I);
                                        EXIT;
                                END IF;
                        END LOOP;
		 End if;
			-- Project account level
		 IF l_proj_acct_level_count > 0 then
                        FOR  I IN 1 .. l_proj_acct_level_count LOOP
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Iside for loop Project account level');
				End If;
                                If g_tab_proj_acct_level_cache(I) = l_proj_acct_level_cache then
					IF g_debug_mode = 'Y' THEN
                                        	log_message(p_msg_token1 =>'same cahce found');
					End IF;
                                        g_tab_prj_acct_level_cache_amt(I) :=
                                          NVL(g_tab_prj_acct_level_cache_amt(I),0) -
                                          (NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0));
                                        g_p_acct_pkt_amt  := g_tab_prj_acct_level_cache_amt(I);
                                        EXIT;
                                END IF;
                        END LOOP;
		 End if;

	    END IF; -- end if for partial flag
		IF g_debug_mode = 'Y' THEN
		    log_message(p_msg_token1 =>'g_r_pkt_amt ['||g_r_pkt_amt||']g_rg_pkt_amt['||
                            g_rg_pkt_amt||']g_t_pkt_amt ['||g_t_pkt_amt||']g_tt_pkt_amt ['||
                            g_tt_pkt_amt||']g_p_pkt_amt ['||g_p_pkt_amt||']g_p_acct_pkt_amt ['||
			    g_p_acct_pkt_amt||']' );
		End IF;
		RETURN;

	END IF; -- end if for minus function

--------------------------------------------------------------------------------------
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'Inside the CACHE_PKT_AMOUNT api');
	End IF;
	-- Resource level Balances
	IF  (p_project_id = g_pre_project_id) AND
	    (p_bdgt_version = g_pre_bdgt_version_id) AND
	    (p_bud_task_id  = g_pre_bud_task_id) AND
	    (p_prlmi   = g_pre_prlmi) AND
	    (p_rlmi    = g_pre_rlmi) AND
	    (trunc(p_start_date) = trunc(g_pre_start_date) ) /*AND
	    (trunc(p_end_date) = trunc(g_pre_end_date) ) */ THEN /* bug 8635962*/
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => ' same  resource ');
		End IF;

	    IF p_partial_flag <> 'Y' then

		g_r_pkt_amt  := NVL(g_r_pkt_amt,0)
				+ NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
	    ELse
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'res level count ='||l_res_level_count);
		End IF;
                IF l_res_level_count > 0 then
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'l_res_level_count > 0');
			End IF;
                        FOR  I IN 1 .. l_res_level_count LOOP
				IF g_debug_mode = 'Y' THEN
				    log_message(p_msg_token1 => 'Iside for loop');
				End IF;
                                If g_tab_res_level_cache(I) = l_res_level_cache then
					IF g_debug_mode = 'Y' THEN
						log_message(p_msg_token1 =>'same cahce found');
					End IF;
                                        g_tab_res_level_cache_amt(I) :=
                                          NVL(g_tab_res_level_cache_amt(I),0)+
                                          NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);

					g_r_pkt_amt  := g_tab_res_level_cache_amt(I);
                                        EXIT;
                                END IF;
                        END LOOP;
		END IF ;
	    END IF;

	ELSE
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => ' new resource');
		End if;
	    IF p_partial_flag <> 'Y'  then
		g_r_pkt_amt  := NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
            Else
		l_new_resource := 'N';
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'res level count ='||l_res_level_count);
		End IF;
		IF l_res_level_count > 0 then
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'l_res_level_count > 0');
			End IF;
			FOR  I IN 1 .. l_res_level_count LOOP
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1 => 'Iside for loop');
				End If;
				If g_tab_res_level_cache(I) = l_res_level_cache then
					IF g_debug_mode = 'Y' THEN
						log_message(p_msg_token1 =>'same cahce found');
					End IF;
					g_tab_res_level_cache_amt(I) :=
					  NVL(g_tab_res_level_cache_amt(I),0)+
					  NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
					g_r_pkt_amt  := g_tab_res_level_cache_amt(I);
					l_new_resource := 'N';
					EXIT;
				END IF;
				l_new_resource := 'Y';
			END LOOP;
		END IF;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>' l_new_resource = '||l_new_resource);
		End IF;
		IF l_new_resource = 'Y' or l_res_level_count <= 0 then
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'adding to cache');
			End IF;
			g_tab_res_level_cache(l_res_level_count+1) := l_res_level_cache;
                       	g_tab_res_level_cache_amt(l_res_level_count+1) :=
                                  NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);

			g_r_pkt_amt  := g_tab_res_level_cache_amt(l_res_level_count+1);
		END IF;

	    END IF;
	END IF;
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'res amount ='||g_r_pkt_amt);
	End If;
-------------------------------------------------------------------------------------------
	-- Resource Group level Balances

        IF  (p_project_id = g_pre_project_id) AND
            (p_bdgt_version = g_pre_bdgt_version_id) AND
            (p_bud_task_id  = g_pre_bud_task_id) AND
            (p_prlmi   = g_pre_prlmi) AND
            --(p_rlmi    = g_pre_rlmi) AND
            (trunc(p_start_date) = trunc(g_pre_start_date) ) /* AND
            (trunc(p_end_date) = trunc(g_pre_end_date) ) */ THEN /* bug 8635962*/
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => ' same  res grp ');
		End If;

	    IF p_partial_flag <> 'Y'  then
                g_rg_pkt_amt  := NVL(g_rg_pkt_amt,0)
                                + NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
            Else
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>'res grp level count ='||l_res_grp_level_count);
		End IF;
                IF l_res_grp_level_count > 0 then
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'l_res_grp_level_count > 0');
			End If;
                        FOR  I IN 1 .. l_res_grp_level_count LOOP
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Iside for loop');
				End If;
                                If g_tab_res_grp_level_cache(I) = l_res_grp_level_cache then
					IF g_debug_mode = 'Y' THEN
                                        	log_message(p_msg_token1 =>'same cahce found');
					End IF;
                                        g_tab_res_grp_level_cache_amt(I) :=
                                          NVL(g_tab_res_grp_level_cache_amt(I),0)+
                                          NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);

					g_rg_pkt_amt  := g_tab_res_grp_level_cache_amt(I);
                                        EXIT;
                                END IF;
                        END LOOP;
                END IF ;
	    END IF;

        ELSE
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => ' new res grp');
		End IF;

	     IF p_partial_flag <> 'Y'  then
                g_rg_pkt_amt  := NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
             Else

                l_new_resource_group := 'N';
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>'res grp level count ='||l_res_grp_level_count);
		End IF;
                IF l_res_grp_level_count > 0 then
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'l_res_grp_level_count > 0');
			End IF;
                        FOR  I IN 1 .. l_res_grp_level_count LOOP
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Iside for loop');
				End IF;
                                If g_tab_res_grp_level_cache(I) = l_res_grp_level_cache then
					IF g_debug_mode = 'Y' THEN
                                        	log_message(p_msg_token1 =>'same cahce found');
					End If;
                                        g_tab_res_grp_level_cache_amt(I) :=
                                          NVL(g_tab_res_grp_level_cache_amt(I),0)+
                                          NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
					g_rg_pkt_amt  := g_tab_res_grp_level_cache_amt(I);
                                        l_new_resource_group := 'N';
                                        EXIT;
                                END IF;
                                l_new_resource_group := 'Y';
                        END LOOP;
                END IF;
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>' l_new_resource_group = '||l_new_resource_group);
		End If;
                IF l_new_resource_group = 'Y' or l_res_grp_level_count <= 0 then
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'adding to cache');
			End IF;
                        g_tab_res_grp_level_cache(l_res_grp_level_count+1) := l_res_grp_level_cache;
                        g_tab_res_grp_level_cache_amt(l_res_grp_level_count+1) :=
                                  NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);

			g_rg_pkt_amt  := g_tab_res_grp_level_cache_amt(l_res_grp_level_count+1);
                END IF;
	     END IF;
        END IF;
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => ' res grp bal  ='||g_rg_pkt_amt);
	End IF;
-------------------------------------------------------------------------------------
	-- Task level balances

        IF  (p_project_id = g_pre_project_id) AND
            (p_bdgt_version = g_pre_bdgt_version_id) AND
            (p_task_id  = g_pre_task_id) AND
	    (p_top_task_id  = g_pre_top_task_id) AND
            --(p_prlmi   = g_pre_prlmi) AND
            --(p_rlmi    = g_pre_rlmi) AND
            (trunc(p_start_date) = trunc(g_pre_start_date) )  /* AND
            (trunc(p_end_date) = trunc(g_pre_end_date) ) */  THEN /* bug 8635962*/
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => ' same task level ');
		End IF;

	    IF p_partial_flag <> 'Y'  then
                g_t_pkt_amt  := NVL(g_t_pkt_amt,0)
                                + NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);

            Else
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>'task level count ='||l_task_level_count);
		end IF;
                IF l_task_level_count > 0 then
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'l_task_level_count > 0');
			end if;
                        FOR  I IN 1 .. l_task_level_count LOOP
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Iside for loop');
				End if;
                                If g_tab_task_level_cache(I) = l_task_level_cache then
					IF g_debug_mode = 'Y' THEN
                                        	log_message(p_msg_token1 =>'same cahce found');
					End if;
                                        g_tab_task_level_cache_amt(I) :=
                                          NVL(g_tab_task_level_cache_amt(I),0)+
                                          NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
					g_t_pkt_amt  := g_tab_task_level_cache_amt(I);
                                        EXIT;
                                END IF;
                        END LOOP;
                END IF ;
	    END IF;

        ELSE
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => ' new task level ');
		End If;
	    IF p_partial_flag <> 'Y'  then
                g_t_pkt_amt  := NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);

            Else
                l_new_task := 'N';
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>'task level count ='||l_task_level_count);
		end IF;
                IF l_task_level_count > 0 then
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'l_task_level_count > 0');
			end if;
                        FOR  I IN 1 .. l_task_level_count LOOP
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Iside for loop');
				End If;
                                If g_tab_task_level_cache(I) = l_task_level_cache then
					IF g_debug_mode = 'Y' THEN
                                        	log_message(p_msg_token1 =>'same cahce found');
					end If;
                                        g_tab_task_level_cache_amt(I) :=
                                          NVL(g_tab_task_level_cache_amt(I),0)+
                                          NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
					g_t_pkt_amt  := g_tab_task_level_cache_amt(I);
                                        l_new_task := 'N';
                                        EXIT;
                                END IF;
                                l_new_task := 'Y';
                        END LOOP;
                END IF;
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>' l_new_task= '||l_new_task);
		end if;
                IF l_new_task = 'Y' or l_task_level_count <= 0 then
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'adding to cache');
			End IF;
                        g_tab_task_level_cache(l_task_level_count+1) := l_task_level_cache;
                        g_tab_task_level_cache_amt(l_task_level_count+1) :=
                                  NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
			g_t_pkt_amt  := g_tab_task_level_cache_amt(l_task_level_count+1);
                END IF;
	    END IF;
        END IF;
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => ' task level bal ='||g_t_pkt_amt);
	End IF;
----------------------------------------------------------------------------------------------
	--Top Task level Balances

        IF  (p_project_id = g_pre_project_id) AND
            (p_bdgt_version = g_pre_bdgt_version_id) AND
            --(p_task_id  = g_pre_task_id) AND
            (p_top_task_id  = g_pre_top_task_id) AND
            --(p_prlmi   = g_pre_prlmi) AND
            --(p_rlmi    = g_pre_rlmi) AND
            (trunc(p_start_date) = trunc(g_pre_start_date) ) /* AND
            (trunc(p_end_date) = trunc(g_pre_end_date) ) */ THEN /* bug 8635962*/
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => ' same top task ');
		end If;

	    IF p_partial_flag <> 'Y'  then

                g_tt_pkt_amt  := NVL(g_tt_pkt_amt,0)
                                + NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);

            Else
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>'top task level count ='||l_top_task_level_count);
		End if;
                IF l_top_task_level_count > 0 then
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'l_top_task_level_count > 0');
			End If;
                        FOR  I IN 1 .. l_top_task_level_count LOOP
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Iside for loop');
				end if;
                                If g_tab_top_task_level_cache(I) = l_top_task_level_cache then
					IF g_debug_mode = 'Y' THEN
                                        	log_message(p_msg_token1 =>'same cahce found');
					end if;
                                        g_tab_top_task_level_cache_amt(I) :=
                                          NVL(g_tab_top_task_level_cache_amt(I),0)+
                                          NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
					g_tt_pkt_amt  := g_tab_top_task_level_cache_amt(I);
                                        EXIT;
                                END IF;
                        END LOOP;
                END IF ;
	     END IF;

        ELSE
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => ' new top task level');
		End IF;
	     IF p_partial_flag <> 'Y'  then
                g_tt_pkt_amt  := NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);

             Else
                l_new_top_task := 'N';
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>' top task level count ='||l_top_task_level_count);
		end if;
                IF l_top_task_level_count > 0 then
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'l_top_task_level_count > 0');
			end if;
                        FOR  I IN 1 .. l_top_task_level_count LOOP
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Iside for loop');
				end if;
                                If g_tab_top_task_level_cache(I) = l_top_task_level_cache then
					IF g_debug_mode = 'Y' THEN
                                        	log_message(p_msg_token1 =>'same cahce found');
					end if;
                                        g_tab_top_task_level_cache_amt(I) :=
                                          NVL(g_tab_top_task_level_cache_amt(I),0)+
                                          NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
					g_tt_pkt_amt  := g_tab_top_task_level_cache_amt(I);
                                        l_new_top_task := 'N';
                                        EXIT;
                                END IF;
                                l_new_top_task := 'Y';
                        END LOOP;
                END IF;
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>' l_new_top_task= '||l_new_top_task);
		end if;
                IF l_new_top_task = 'Y' or l_top_task_level_count <= 0 then
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'adding to cache');
			end if;
                        g_tab_top_task_level_cache(l_top_task_level_count+1) := l_top_task_level_cache;
                        g_tab_top_task_level_cache_amt(l_top_task_level_count+1) :=
                                  NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
			g_tt_pkt_amt  := g_tab_top_task_level_cache_amt(l_top_task_level_count+1);
                END IF;
	   END IF;
        END IF;
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'top task level bal ='||g_tt_pkt_amt);
	end if;

--------------------------------------------------------------------------------------------------------
	-- Project level Balances

        IF  (p_project_id = g_pre_project_id) AND
            (p_bdgt_version = g_pre_bdgt_version_id) AND
            --(p_task_id  = g_pre_task_id) AND
            --(p_top_task_id  = g_pre_top_task_id) AND
            --(p_prlmi   = g_pre_prlmi) AND
            --(p_rlmi    = g_pre_rlmi) AND
            (trunc(p_start_date) = trunc(g_pre_start_date) ) /* AND
            (trunc(p_end_date) = trunc(g_pre_end_date) )*/  THEN /* bug 8635962*/
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => ' same project ');
		end if;

	    IF p_partial_flag <> 'Y'  then
                g_p_pkt_amt  := NVL(g_p_pkt_amt,0)
                                + NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);

            Else
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>'project level count ='||l_proj_level_count);
		end if;
                IF l_proj_level_count > 0 then
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'l_proj_level_count > 0');
			end if;
                        FOR  I IN 1 .. l_proj_level_count LOOP
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Iside for loop');
				end if;
                                If g_tab_proj_level_cache(I) = l_proj_level_cache then
					IF g_debug_mode = 'Y' THEN
                                        	log_message(p_msg_token1 =>'same cahce found');
					end if;
                                        g_tab_proj_level_cache_amt(I) :=
                                          NVL(g_tab_proj_level_cache_amt(I),0)+
                                          NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
					g_p_pkt_amt  :=  g_tab_proj_level_cache_amt(I);
                                        EXIT;
                                END IF;
                        END LOOP;
                END IF ;

	    END IF;

        ELSE
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => ' new project');
		end if;

	    IF p_partial_flag <> 'Y'  then
                g_p_pkt_amt  := NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);

            Else
                l_new_proj := 'N';
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>' proj level count ='||l_proj_level_count);
		end if;
                IF l_proj_level_count > 0 then
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'l_proj_level_count > 0');
			end if;
                        FOR  I IN 1 .. l_proj_level_count LOOP
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Iside for loop');
				end if;
                                If g_tab_proj_level_cache(I) = l_proj_level_cache then
					IF g_debug_mode = 'Y' THEN
                                        	log_message(p_msg_token1 =>'same cahce found');
					end if;
                                        g_tab_proj_level_cache_amt(I) :=
                                          NVL(g_tab_proj_level_cache_amt(I),0)+
                                          NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
					 g_p_pkt_amt  :=  g_tab_proj_level_cache_amt(I);
                                        l_new_proj := 'N';
                                        EXIT;
                                END IF;
                                l_new_proj := 'Y';
                        END LOOP;
                END IF;
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>' l_new_proj= '||l_new_proj);
		end if;
                IF l_new_proj = 'Y' or l_proj_level_count <= 0 then
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'adding to cache');
			end if;
                        g_tab_proj_level_cache(l_proj_level_count+1) := l_proj_level_cache;
                        g_tab_proj_level_cache_amt(l_proj_level_count+1) :=
                                  NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
			g_p_pkt_amt  := g_tab_proj_level_cache_amt(l_proj_level_count+1);
                END IF;
	    END IF;
        END IF;
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'project bal ='||g_p_pkt_amt);
	end if;
------------------------------------------------------------------------------------------------
	-- project account level Balances

        IF  (p_project_id = g_pre_project_id) AND
            (p_bdgt_version = g_pre_bdgt_version_id) AND
	    (p_bdgt_ccid  = g_pre_bdgt_ccid ) AND
            --(p_task_id  = g_pre_task_id) AND
            --(p_top_task_id  = g_pre_top_task_id) AND
            --(p_prlmi   = g_pre_prlmi) AND
            --(p_rlmi    = g_pre_rlmi) AND
            (trunc(p_start_date) = trunc(g_pre_start_date) ) /* AND
            (trunc(p_end_date) = trunc(g_pre_end_date) )  */ THEN /* bug 8635962*/
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 => ' same project  account');
		end if;

	    IF p_partial_flag <> 'Y'  then
                g_p_acct_pkt_amt  := NVL(g_p_acct_pkt_amt,0)
                                + NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);

            Else
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>'project acct level count ='||l_proj_acct_level_count);
		end if;
                IF l_proj_acct_level_count > 0 then
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'l_proj_acct_level_count > 0');
			end if;
                        FOR  I IN 1 .. l_proj_acct_level_count LOOP
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Iside for loop');
				end if;
                                If g_tab_proj_acct_level_cache(I) = l_proj_acct_level_cache then
					IF g_debug_mode = 'Y' THEN
                                        	log_message(p_msg_token1 =>'same cahce found');
					end if;
                                        g_tab_prj_acct_level_cache_amt(I) :=
                                          NVL(g_tab_prj_acct_level_cache_amt(I),0)+
                                          NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
					g_p_acct_pkt_amt  := g_tab_prj_acct_level_cache_amt(I);
                                        EXIT;
                                END IF;
                        END LOOP;
                END IF ;
	    END IF;

        ELSE
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 => ' new project account');
		end if;

	    IF p_partial_flag <> 'Y'  then
                g_p_acct_pkt_amt  := NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);

            Else
                l_new_proj_acct := 'N';
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>' proj acct level count ='||l_proj_acct_level_count);
		end if;
                IF l_proj_acct_level_count > 0 then
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'l_proj_acct_level_count > 0');
			end if;
                        FOR  I IN 1 .. l_proj_acct_level_count LOOP
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Iside for loop');
				end if;
                                If g_tab_proj_acct_level_cache(I) = l_proj_acct_level_cache then
					IF g_debug_mode = 'Y' THEN
                                        	log_message(p_msg_token1 =>'same cahce found');
					end if;
                                        g_tab_prj_acct_level_cache_amt(I) :=
                                          NVL(g_tab_prj_acct_level_cache_amt(I),0)+
                                          NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
					g_p_acct_pkt_amt  := g_tab_prj_acct_level_cache_amt(I);
                                        l_new_proj_acct := 'N';
                                        EXIT;
                                END IF;
                                l_new_proj_acct := 'Y';
                        END LOOP;
                END IF;
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>' l_new_proj acct = '||l_new_proj_acct);
		end if;
                IF l_new_proj_acct = 'Y' or l_proj_acct_level_count <= 0 then
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'adding to cache');
			end if;
                        g_tab_proj_acct_level_cache(l_proj_acct_level_count+1) := l_proj_acct_level_cache;
                        g_tab_prj_acct_level_cache_amt(l_proj_acct_level_count+1) :=
                                  NVL(p_accounted_dr,0) - NVL(p_accounted_cr,0);
			g_p_acct_pkt_amt  := g_tab_prj_acct_level_cache_amt(l_proj_acct_level_count+1);
                END IF;

	    END IF;
        END IF;
	IF g_debug_mode = 'Y' THEN
        	log_message(p_msg_token1 => 'project acct bal ='||g_p_acct_pkt_amt);
	end if;

	REturn;

EXCEPTION
	WHEN OTHERS THEN
		IF g_debug_mode = 'Y' THEN
		   log_message_imp(p_msg_token1 => 'failed in cache amt pkts apiSQLERR'|| sqlerrm||sqlcode);
		end if;
		   raise;
END CACHE_PKT_AMOUNTS;

 -----------------------------------------------------------------------------------------------------------
 --- This Api checks the funds available for the record in pa bc packets. The following logic is used.
 --- funds check will be carried out NOCOPY at five levels, RESOURCE, RESOURCE GROUP, TOP TASK, TASK AND
 --- PROJECT level. depending on  upon the budget entry method  AND budgetory controls used
 --- if the budgetory control setup  is N - None   then funds check will not be done
 --- if the budgetory control setup  is  B - Absolute  , D - Advisory then funds check will be done
 --- funds check will be done based on roll up process.
 ---
 ---	BUDGET LEVEL 					BUDGETORY CONTROL
 ---    --------------					-------------------
 ---
 ---	RESOURCE					ABSOLUTE /ADVISORY/ NONE
 ---
 ---		RESOURCE GROUP				ABSOLUTE /ADVISORY/ NONE
 ---
 ---			TASK				ABSOLUTE /ADVISORY/ NONE
 ---
 ---				TOP TASK		ABSOLUTE /ADVISORY/ NONE
 ---
 ---					PROJECT		ABSOLUTE /ADVISORY/ NONE
 -------------------------------------------------------------------------------------------------------------

PROCEDURE  check_funds_available (
		p_sob           IN 	pa_bc_packets.set_of_books_id%type,
       		p_mode    	IN 	VARCHAR2,
     		p_packet_id  	IN 	NUMBER,
   		p_record   	IN  OUT NOCOPY pa_fc_record,
    		p_arrival_seq  	IN 	NUMBER,
  		p_status_code  	IN 	VARCHAR2,
   		p_ext_bdgt_link IN 	VARCHAR2,
   		p_ext_bdgt_type IN 	VARCHAR2,
		p_start_date    IN 	DATE,
		p_end_date	IN 	DATE,
		p_calling_module IN     VARCHAR2,
		p_partial_flag   IN     VARCHAR2,
		p_counter       IN      number
           	) IS

            p_start_date_1 DATE;  -- 7531681
            p_end_date_1 DATE;    -- 7531681



        -----------------------------------------------------------------------------------------------------
        -- This CURSOR selects AND sums up all the balances for a particular resource FROM pa_bc_balances table
        -- between the start date AND end date  RESOURCE CURSOR
        -----------------------------------------------------------------------------------------------------
       	CURSOR  res_level_bal (l_rlmi number) is
    /*          	SELECT  nvl(sum(BUDGET_PERIOD_TO_DATE * decode(balance_type,'BGT',1,0)) ,0),
                  	nvl(sum(ACTUAL_PERIOD_TO_DATE * decode(balance_type,'EXP',1,0)) ,0),
                  	nvl(sum(ENCUMB_PERIOD_TO_DATE * decode(balance_type,'REQ',1,
									'PO',1,
									'AP',1,
									'ENC',1,
									'CC_C_PAY',1,
									'CC_C_CO',1,
									'CC_P_PAY',1,
									'CC_P_CO',1,
									0)),0)               7531681 */
                SELECT NVL(SUM(BUDGET_PERIOD_TO_DATE ),0),
                       NVL(SUM(ACTUAL_PERIOD_TO_DATE ),0),
                       NVL(SUM(ENCUMB_PERIOD_TO_DATE ),0)
        	FROM   pa_bc_balances pb
        	WHERE pb.project_id = p_record.project_id
		/* Bug fix: 3450756 Start  */
		---AND pb.task_id = p_record.bud_task_id
         	AND ( (pb.task_id = p_record.bud_task_id and pb.balance_type in ('BGT'))
                       OR
		      (pb.balance_type NOT IN ('BGT','REV')
			AND
		       ((p_record.entry_level_code = 'L' and p_record.bud_task_id = pb.task_id)
			OR
		       (p_record.entry_level_code = 'P' and p_record.bud_task_id = 0)
		        OR
		       (p_record.entry_level_code = 'T'
                        and p_record.bud_task_id =  pb.top_task_id /* (select t.top_task_id
						    From pa_tasks t
						    Where t.task_id = pb.task_id) 7531681 */
		       )
		        OR
		       (p_record.entry_level_code = 'M'
			and ( p_record.bud_task_id = pb.task_id
                              OR
			      p_record.bud_task_id = pb.top_task_id /* (select t.top_task_id
                                                    From pa_tasks t
                                                    Where t.task_id = pb.task_id) 7531681 */
			    )
		      )))
		    )
		/* Bug fix: 3450756 End  */
         	AND ((pb.resource_list_member_id = l_rlmi AND pb.balance_type not in ('BGT','REV'))
         	     OR  (pb.resource_list_member_id = l_rlmi AND pb.balance_type ='BGT')
		    )
          	AND pb.budget_version_id = p_record.budget_version_id
          	AND pb.start_date between
             		decode(p_record.time_phased_type_code,'N', pb.start_date, p_start_date_1 ) AND  -- 7531681
                	decode(p_record.time_phased_type_code,'N', pb.start_date, p_end_date_1)    -- 7531681
           	AND pb.end_date between
                	decode(p_record.time_phased_type_code,'N', pb.end_date,  p_start_date_1 ) AND   -- 7531681
              		decode(p_record.time_phased_type_code,'N', pb.end_date, p_end_date_1)   -- 7531681
			;
        -----------------------------------------------------------------------------------------------------
        -- This CURSOR selects AND sums all the entedr - entecr columns FROM pa_bc_packets table
        --     for one resource between the start date AND end date
        -----------------------------------------------------------------------------------------------------
        CURSOR res_tot_bc_pkt(l_rlmi number,l_parent_res_id number) IS
        SELECT  nvl(sum(decode(pbc.status_code,'P',nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0)
                +nvl(sum(decode(pbc.status_code||substr(pbc.result_code,1,1)||pbc.effect_on_funds_code,'ZPI',
            nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0),
        nvl(sum(decode(pbc.status_code||pbc.actual_flag, 'AE',nvl(accounted_dr,0)-nvl(accounted_cr,0),0)),0),
        nvl(sum(decode(pbc.status_code||pbc.actual_flag, 'AA',nvl(accounted_dr,0)-nvl(accounted_cr,0),0)),0)
        FROM pa_bc_packets pbc
           --     pa_bc_packet_arrival_order ao   --7531681
        WHERE pbc.project_id = p_record.project_id
        AND (
              (nvl(pbc.top_task_id,0) =  p_record.bud_task_id)
                or (nvl(pbc.task_id,0) =  p_record.bud_task_id)
                or p_record.entry_level_code = 'P'
             )
        AND pbc.resource_list_member_id = l_rlmi
        AND NVL(pbc.parent_resource_id,0) = nvl(l_parent_res_id,0) /* Added nvl for bug fix 2658952 */
        AND pbc.budget_version_id = p_record.budget_version_id
        AND pbc.set_of_books_id =   p_sob
	AND ((p_record.time_phased_type_code = 'G' and pbc.gl_date
		between p_start_date_1 and p_end_date_1) OR   -- 7531681
	     (p_record.time_phased_type_code = 'P' and pbc.pa_date
		between p_start_date_1 and p_end_date_1) OR   -- 7531681
	     (p_record.time_phased_type_code = 'N' and pbc.expenditure_item_date
		between p_start_date_1 and p_end_date_1)   -- 7531681
	    )
--        AND pbc.packet_id = ao.packet_id  /* 7531681 */
        and substr(nvl(pbc.result_code,'P'),1,1)= 'P'
        AND pbc.balance_posted_flag = 'N'
        AND exists
           ( select 1 from  pa_bc_packet_arrival_order ao
	         where ao.packet_id = pbc.packet_id
            AND (
	-- This condition is added to avoid the concurrency issues like when two packets arrive for funds check
	-- one is funds check completed but not updated the status to Aprroved as the final status is updated
        -- after getting the status from gl tie back.mean time antother packet which arrives has to consider
	-- the amount which already consumeed in previous packet.
	-- the status code takes care of the following
	-- A -- Approved but not yet posted to balances / not yet swept
  	-- P -- Pending packet which is funds checked not yet approved / when two packets arrives in queue
	     -- has to consider the amounts in previous packet
     	-- C -- packets arrives during baseline process will be updated with intermedidate status after FC
	-- B -- the approved the transaction will be updated to B during CHECK_BASELINE mode these transaction
	     -- must be considered during RESERVE_BASELINE mode
        -- R12 note: all code related to status code 'C' and 'B' being deleted ..
                (    ao.arrival_seq <  p_arrival_seq
                --AND ao.affect_funds_flag = 'Y'
                AND ao.set_of_books_id = p_sob
                AND pbc.status_code in ( 'A','P')
	--	and substr(nvl(pbc.result_code,'P'),1,1)= 'P'  -- 7531681
        --        AND pbc.balance_posted_flag = 'N'            -- 7531681
                  )
              OR(pbc.packet_id = p_packet_id
                and pbc.status_code = 'Z'
                and pbc.effect_on_funds_code = 'I'
                and p_partial_flag <> 'Y'
         --       and pbc.balance_posted_flag = 'N'              -- 7531681
         --       and substr(nvl(pbc.result_code,'P'),1,1)= 'P'  -- 7531681
                )
           ) );


		--------------------------------------------------------------------------------------
		-- This CURSOR select the sum of amount from pa bc balances for the given parent
		-- resource id between the start and end date  - RESOURCE GROUP CURSOR
		--------------------------------------------------------------------------------------
        	CURSOR  res_grp_level_bal (l_parent_member_id number,l_bud_rlmi number) is
             /*   SELECT  nvl(sum(BUDGET_PERIOD_TO_DATE *decode(balance_type,'BGT',1,0)) ,0),
                        nvl(sum(ACTUAL_PERIOD_TO_DATE *decode(balance_type,'EXP',1,0)) ,0),
                        nvl(sum(ENCUMB_PERIOD_TO_DATE *decode(balance_type,'REQ',1,
                                                                        'PO',1,
                                                                        'AP',1,
                                                                        'ENC',1,
                                                                        'CC_C_PAY',1,
                                                                        'CC_C_CO',1,
                                                                        'CC_P_PAY',1,
                                                                        'CC_P_CO',1,
                                                                        0)),0)   7531681*/

                SELECT NVL(SUM(BUDGET_PERIOD_TO_DATE ),0),
                       NVL(SUM(ACTUAL_PERIOD_TO_DATE  ),0),
                       NVL(SUM(ENCUMB_PERIOD_TO_DATE ),0)
                FROM   pa_bc_balances pb
                WHERE pb.project_id = p_record.project_id
                /* Bug fix: 3450756 Start  */
                ---AND pb.task_id = p_record.bud_task_id
                AND ( (pb.task_id = p_record.bud_task_id and pb.balance_type in ('BGT'))
                       OR
                      (pb.balance_type NOT IN ('BGT','REV')
                        AND
                       ((p_record.entry_level_code = 'L' and p_record.bud_task_id = pb.task_id)
                        OR
                       (p_record.entry_level_code = 'P' and p_record.bud_task_id = 0)
                        OR
                       (p_record.entry_level_code = 'T'
                        and p_record.bud_task_id = pb.top_task_id /*(select t.top_task_id
                                                    From pa_tasks t
                                                    Where t.task_id = pb.task_id)   7531681 */
                       )
                        OR
                       (p_record.entry_level_code = 'M'
                        and (p_record.bud_task_id = pb.task_id
                             OR
                             p_record.bud_task_id = pb.top_task_id  /* (select t.top_task_id
                                                    From pa_tasks t
                                                    Where t.task_id = pb.task_id)   7531681 */
                            )
                      )))
                    )
                /* Bug fix: 3450756 End  */
            	AND (( NVL(pb.parent_member_id,0) = NVL(l_parent_member_id,0) /* Added NVL for bug fix 2658952 */
                       and pb.balance_type not in ('BGT','REV')
                       and pb.parent_member_id is NOT NULL)
                     OR (pb.resource_list_member_id = l_bud_rlmi  AND
                         pb.balance_type not in ('BGT','REV') AND
                         pb.parent_member_id is NULL )
            	     OR  (pb.resource_list_member_id = l_bud_rlmi  AND pb.balance_type ='BGT'
            		  AND pb.parent_member_id is null)
	        	)
                AND pb.budget_version_id = p_record.budget_version_id
                AND pb.start_date between
                        decode(p_record.time_phased_type_code,'N', pb.start_date, p_start_date_1) AND -- 7531681
                        decode(p_record.time_phased_type_code,'N', pb.start_date, p_end_date_1)  -- 7531681
                AND pb.end_date between
                        decode(p_record.time_phased_type_code,'N', pb.end_date, p_start_date_1) AND  -- 7531681
                        decode(p_record.time_phased_type_code,'N', pb.end_date, p_end_date_1);       -- 7531681

		-----------------------------------------------------------------------------------------
		-- this cursor selects the sum of amounts and rolls up the resource group level
		--  RESOURCE ROLLUP
		----------------------------------------------------------------------------------------
        	CURSOR res_rollup_bal (l_parent_member_id number) is
               /*  SELECT  nvl(sum(BUDGET_PERIOD_TO_DATE *decode(balance_type,'BGT',1,0)) ,0),
                        nvl(sum(ACTUAL_PERIOD_TO_DATE *decode(balance_type,'EXP',1,0)) ,0),
                        nvl(sum(ENCUMB_PERIOD_TO_DATE *decode(balance_type,'REQ',1,
                                                                        'PO',1,
                                                                        'AP',1,
                                                                        'ENC',1,
                                                                        'CC_C_PAY',1,
                                                                        'CC_C_CO',1,
                                                                        'CC_P_PAY',1,
                                                                        'CC_P_CO',1,
                                                                        0)),0)    7531681 */
                SELECT NVL(SUM(BUDGET_PERIOD_TO_DATE ),0),
                         NVL(SUM(ACTUAL_PERIOD_TO_DATE ),0),
                         NVL(SUM(ENCUMB_PERIOD_TO_DATE ),0)
                FROM   pa_bc_balances pb
                WHERE pb.project_id = p_record.project_id
                /* Bug fix: 3450756 Start  */
                ---AND pb.task_id = p_record.bud_task_id
                AND ( (pb.task_id = p_record.bud_task_id and pb.balance_type in ('BGT'))
                       OR
                      (pb.balance_type NOT IN ('BGT','REV')
                        AND
                       ((p_record.entry_level_code = 'L' and p_record.bud_task_id = pb.task_id)
                        OR
                       (p_record.entry_level_code = 'P' and p_record.bud_task_id = 0)
                        OR
                       (p_record.entry_level_code = 'T'
                        and p_record.bud_task_id = pb.top_task_id  /* (select t.top_task_id
                                                    From pa_tasks t
                                                    Where t.task_id = pb.task_id) 7531681  */
                       )
                        OR
                       (p_record.entry_level_code = 'M'
                        and ( p_record.bud_task_id = pb.task_id
                              OR
                              p_record.bud_task_id = pb.top_task_id /* (select t.top_task_id
                                                    From pa_tasks t
                                                    Where t.task_id = pb.task_id)  7531681 */
                            )
                      )))
                    )
                /* Bug fix: 3450756 End  */
            	AND ((NVL(pb.parent_member_id,0) = nvl(l_parent_member_id,0) /*Added NVL for bug fix 2658952 */
                         and pb.balance_type not in ('BGT','REV')
                         and pb.parent_member_id is NOT NULL )
            	      OR  (NVL(pb.parent_member_id,0) = nvl(l_parent_member_id,0) /*Added NVL for bug fix 2658952 */
                           AND pb.balance_type ='BGT'
                           AND pb.parent_member_id is NOT NULL)
			)
                AND pb.budget_version_id = p_record.budget_version_id
                AND pb.start_date between
                        decode(p_record.time_phased_type_code,'N', pb.start_date, p_start_date_1) AND  -- 7531681
                        decode(p_record.time_phased_type_code,'N', pb.start_date, p_end_date_1)        -- 7531681
                AND pb.end_date between
                        decode(p_record.time_phased_type_code,'N', pb.end_date, p_start_date_1) AND    -- 7531681
                        decode(p_record.time_phased_type_code,'N', pb.end_date, p_end_date_1);        -- 7531681


        -----------------------------------------------------------------------------------------------------
        -- This CURSOR selects AND sums all the entedr - entecr columns FROM pa_bc_packets table
        --     for one resource group  between the start date AND end date
        -- R12 note: all code related to status code 'C' and 'B' being deleted ..
        -----------------------------------------------------------------------------------------------------
        CURSOR res_grp_tot_bc_pkt(l_parent_res_id number,l_rlmi number) IS
        SELECT   nvl(sum(decode(pbc.status_code,'P',nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0)
                +nvl(sum(decode(pbc.status_code||substr(pbc.result_code,1,1)||pbc.effect_on_funds_code,'ZPI',
            nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0),
        nvl(sum(decode(pbc.status_code||pbc.actual_flag, 'AE',nvl(accounted_dr,0)-nvl(accounted_cr,0),0)),0),
        nvl(sum(decode(pbc.status_code||pbc.actual_flag, 'AA',nvl(accounted_dr,0)-nvl(accounted_cr,0),0)),0)
        FROM pa_bc_packets pbc
            -- 	pa_bc_packet_arrival_order ao  --7531681
        WHERE pbc.project_id = p_record.project_id
        AND (
              (nvl(pbc.top_task_id,0) =  p_record.bud_task_id)
                or (nvl(pbc.task_id,0) =  p_record.bud_task_id)
                or p_record.entry_level_code = 'P'
             )
        AND ( (NVL(pbc.parent_resource_id,0) = NVl(l_parent_res_id,0) /*Added NVL for bug fix 2658952 */
               and NVl(l_parent_res_id,0) <> 0 )
               OR ( pbc.resource_list_member_id = l_rlmi
                    and NVl(l_parent_res_id,0) = 0)
            )
        AND pbc.budget_version_id = p_record.budget_version_id
        AND pbc.set_of_books_id =   p_sob
        AND ((p_record.time_phased_type_code = 'G' and pbc.gl_date
                between p_start_date_1 and p_end_date_1) OR   -- 7531681
             (p_record.time_phased_type_code = 'P' and pbc.pa_date
                between p_start_date_1 and p_end_date_1) OR     -- 7531681
             (p_record.time_phased_type_code = 'N' and pbc.expenditure_item_date
                between p_start_date_1 and p_end_date_1)        -- 7531681
            )
   --   AND pbc.packet_id = ao.packet_id  -- 7531681
          and substr(nvl(pbc.result_code,'P'),1,1)= 'P'
          AND pbc.balance_posted_flag = 'N'
          AND exists
            ( select 1 from pa_bc_packet_arrival_order ao      /* 7531681 */
              where pbc.packet_id = ao.packet_id
              AND (
                (    ao.arrival_seq <  p_arrival_seq
                --AND ao.affect_funds_flag = 'Y'
                AND ao.set_of_books_id = p_sob
                AND pbc.status_code in ( 'A','P')
	--	and substr(nvl(pbc.result_code,'P'),1,1)= 'P'  -- 7531681
         --       AND pbc.balance_posted_flag = 'N'            -- 7531681
                  )
              OR(pbc.packet_id = p_packet_id
                and pbc.status_code = 'Z'
                and pbc.effect_on_funds_code = 'I'
                and p_partial_flag <> 'Y'
              --  and pbc.balance_posted_flag = 'N'            -- 7531681
              --  and substr(nvl(pbc.result_code,'P'),1,1)= 'P'   -- 7531681
                )
                ));

        -----------------------------------------------------------------------------------------------------
        -- This CURSOR selects AND sums up all the balances for a particular task  FROM pa_bc_balances table
        -- between the start date AND end date and this CURSOR is opened when funds checking rolls up to
        -- task level  FROM resource level
        -----------------------------------------------------------------------------------------------------
        CURSOR task_level_bal (l_task_id number)is
            /*    SELECT  nvl(sum(BUDGET_PERIOD_TO_DATE *decode(balance_type,'BGT',1,0)) ,0),
                        nvl(sum(ACTUAL_PERIOD_TO_DATE *decode(balance_type,'EXP',1,0)) ,0),
                        nvl(sum(ENCUMB_PERIOD_TO_DATE *decode(balance_type,'REQ',1,
                                                                        'PO',1,
                                                                        'AP',1,
                                                                        'ENC',1,
                                                                        'CC_C_PAY',1,
                                                                        'CC_C_CO',1,
                                                                        'CC_P_PAY',1,
                                                                        'CC_P_CO',1,
                                                                        0)),0)  7531681  */
                SELECT NVL(SUM(BUDGET_PERIOD_TO_DATE ),0),
                     NVL(SUM(ACTUAL_PERIOD_TO_DATE ),0),
                     NVL(SUM(ENCUMB_PERIOD_TO_DATE ),0)
                FROM   pa_bc_balances pb
                WHERE pb.project_id = p_record.project_id
		AND pb.budget_version_id     = p_record.budget_version_id
                /* Bug fix: 3450756 Start  */
            	--- AND ( ( pb.task_id = l_task_id  AND   pb.balance_type='BGT')
               	---	OR (pb.task_id = l_task_id AND pb.balance_type not in ('REV','BGT'))
		---    )
                AND ( (pb.task_id = l_task_id and pb.balance_type in ('BGT'))
                       OR
                      (pb.balance_type NOT IN ('BGT','REV')
                        AND
                       ((p_record.entry_level_code = 'L' and pb.task_id = l_task_id )
                        OR
                       (p_record.entry_level_code = 'P' and p_record.bud_task_id = 0)
                        OR
                       (p_record.entry_level_code = 'T'
                        and l_task_id = pb.top_task_id /* (select t.top_task_id
                                         From pa_tasks t
                                         Where t.task_id = pb.task_id)  7531681 */
                       )
                        OR
                       (p_record.entry_level_code = 'M'
                        and ( pb.task_id = l_task_id
                             OR
                              l_task_id = pb.top_task_id /* (select t.top_task_id
                                          From pa_tasks t
                                          Where t.task_id = pb.task_id)  7531681 */
                            )
                      )))
                    )
                /* Bug fix: 3450756 End  */
                AND pb.start_date between
                        decode(p_record.time_phased_type_code,'N', pb.start_date, p_start_date_1) AND   -- 7531681
                        decode(p_record.time_phased_type_code,'N', pb.start_date, p_end_date_1)         -- 7531681
                AND pb.end_date between
                        decode(p_record.time_phased_type_code,'N', pb.end_date, p_start_date_1) AND     -- 7531681
                        decode(p_record.time_phased_type_code,'N', pb.end_date, p_end_date_1);          -- 7531681

        -----------------------------------------------------------------------------------------------------
        --This CURSOR selects AND sums all the entedr columns FROM pa_bc_packets table for all the resources
        --falling under one lowest task between the start date AND end date
        -- R12 note: all code related to status code 'C' and 'B' being deleted ..
        -----------------------------------------------------------------------------------------------------
        CURSOR task_tot_bc_pkt  (l_task_id number,l_top_task_id number) is
        SELECT  nvl(sum(decode(pbc.status_code,'P',nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0)
                +nvl(sum(decode(pbc.status_code||substr(pbc.result_code,1,1)||pbc.effect_on_funds_code,'ZPI',
            nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0),
        nvl(sum(decode(pbc.status_code||pbc.actual_flag, 'AE',nvl(accounted_dr,0)-nvl(accounted_cr,0),0)),0),
        nvl(sum(decode(pbc.status_code||pbc.actual_flag, 'AA',nvl(accounted_dr,0)-nvl(accounted_cr,0),0)),0)
        FROM pa_bc_packets pbc
           --     pa_bc_packet_arrival_order ao   -- 7531681
        WHERE pbc.project_id = p_record.project_id
        AND pbc.top_task_id                 =  l_top_task_id
        AND pbc.task_id                     = l_task_id
        AND pbc.budget_version_id           = p_record.budget_version_id
        AND pbc.set_of_books_id             =   p_sob
        AND ((p_record.time_phased_type_code = 'G' and pbc.gl_date
                between p_start_date_1 and p_end_date_1) OR         -- 7531681
             (p_record.time_phased_type_code = 'P' and pbc.pa_date
                between p_start_date_1 and p_end_date_1) OR          -- 7531681
             (p_record.time_phased_type_code = 'N' and pbc.expenditure_item_date
                between p_start_date_1 and p_end_date_1)            -- 7531681
            )
--        AND pbc.packet_id = ao.packet_id   -- 7531681
          and substr(nvl(pbc.result_code,'P'),1,1)= 'P'      /* 7531681 */
          AND pbc.balance_posted_flag = 'N'
          and exists
             (select 1 from pa_bc_packet_arrival_order ao
              where ao.packet_id = pbc.packet_id
             AND (
                (    ao.arrival_seq <  p_arrival_seq
                --AND ao.affect_funds_flag = 'Y'
                AND ao.set_of_books_id = p_sob
                AND pbc.status_code in ( 'A','P')
	--	and substr(nvl(pbc.result_code,'P'),1,1)= 'P'   -- 7531681
         --       AND pbc.balance_posted_flag = 'N'             -- 7531681
                  )
              OR(pbc.packet_id = p_packet_id
                and pbc.status_code = 'Z'
                and pbc.effect_on_funds_code = 'I'
                and p_partial_flag <> 'Y'
          --      and pbc.balance_posted_flag = 'N'             -- 7531681
           --     and substr(nvl(pbc.result_code,'P'),1,1)= 'P'  -- 7531681
                )
               ) );


        -----------------------------------------------------------------------------------------------------
        -- This CURSOR selects AND sums up all the balances for a particular top task  FROM pa_bc_balances table
        -- between the start date AND end date
        -----------------------------------------------------------------------------------------------------
        CURSOR top_task_level_bal (l_bud_task_id number,l_top_task_id number) is
                /*SELECT  nvl(sum(BUDGET_PERIOD_TO_DATE *decode(balance_type,'BGT',1,0)) ,0),
                        nvl(sum(ACTUAL_PERIOD_TO_DATE *decode(balance_type,'EXP',1,0)) ,0),
                        nvl(sum(ENCUMB_PERIOD_TO_DATE *decode(balance_type,'REQ',1,
                                                                        'PO',1,
                                                                        'AP',1,
                                                                        'ENC',1,
                                                                        'CC_C_PAY',1,
                                                                        'CC_C_CO',1,
                                                                        'CC_P_PAY',1,
                                                                        'CC_P_CO',1,
                                                                         0)),0)   7531681  */
                SELECT NVL(SUM(BUDGET_PERIOD_TO_DATE ),0),
                      NVL(SUM(ACTUAL_PERIOD_TO_DATE),0),
                      NVL(SUM(ENCUMB_PERIOD_TO_DATE),0)
                FROM   pa_bc_balances pb
                WHERE pb.project_id = p_record.project_id
            	AND ((pb.task_id = l_bud_task_id AND   pb.balance_type='BGT' AND pb.task_id = l_top_task_id)
               	    OR (pb.top_task_id = l_top_task_id AND pb.balance_type not in ('REV','BGT'))
		    )
                AND pb.budget_version_id     = p_record.budget_version_id
                AND pb.start_date between
                        decode(p_record.time_phased_type_code,'N', pb.start_date, p_start_date_1) AND  -- 7531681
                        decode(p_record.time_phased_type_code,'N', pb.start_date, p_end_date_1)        -- 7531681
                AND pb.end_date between
                        decode(p_record.time_phased_type_code,'N', pb.end_date, p_start_date_1) AND    -- 7531681
                        decode(p_record.time_phased_type_code,'N', pb.end_date, p_end_date_1);         -- 7531681


        -----------------------------------------------------------------------------------------------------
        -- This CURSOR selects AND sums up all the balances for a particular task  FROM pa_bc_balances table
        -- between the start date AND end date and rollup  TASKROLLUP CURSOR
        -----------------------------------------------------------------------------------------------------
        CURSOR task_rollup_bal (l_top_task_id number) is
                /* SELECT  nvl(sum(BUDGET_PERIOD_TO_DATE *decode(balance_type,'BGT',1,0)) ,0),
                        nvl(sum(ACTUAL_PERIOD_TO_DATE *decode(balance_type,'EXP',1,0)) ,0),
                        nvl(sum(ENCUMB_PERIOD_TO_DATE *decode(balance_type,'REQ',1,
                                                                        'PO',1,
                                                                        'AP',1,
                                                                        'ENC',1,
                                                                        'CC_C_PAY',1,
                                                                        'CC_C_CO',1,
                                                                        'CC_P_PAY',1,
                                                                        'CC_P_CO',1,
                                                                         0)),0)   7531681 */
                SELECT NVL(SUM(BUDGET_PERIOD_TO_DATE ),0),
                        NVL(SUM(ACTUAL_PERIOD_TO_DATE),0),
                        NVL(SUM(ENCUMB_PERIOD_TO_DATE ),0)
                FROM   pa_bc_balances pb
                WHERE pb.project_id = p_record.project_id
            	AND ((pb.top_task_id = l_top_task_id and   pb.balance_type not in ('REV','BGT'))
               	    OR (pb.top_task_id = l_top_task_id AND pb.balance_type='BGT'))
                AND pb.budget_version_id     = p_record.budget_version_id
                AND pb.start_date between
                        decode(p_record.time_phased_type_code,'N', pb.start_date, p_start_date_1)AND  -- 7531681
                        decode(p_record.time_phased_type_code,'N', pb.start_date, p_end_date_1)       -- 7531681
                AND pb.end_date between
                        decode(p_record.time_phased_type_code,'N', pb.end_date, p_start_date_1) AND   -- 7531681
                        decode(p_record.time_phased_type_code,'N', pb.end_date, p_end_date_1);        -- 7531681

        -----------------------------------------------------------------------------------------------------
        --This CURSOR selects AND sums all the entedr columns FROM pa_bc_packets table for all the resources
        --falling under one top task between the start date AND end date
        -- R12 note: all code related to status code 'C' and 'B' being deleted ..
        -----------------------------------------------------------------------------------------------------
        CURSOR top_task_tot_bc_pkt  (l_top_task_id number) is
        SELECT  nvl(sum(decode(pbc.status_code,'P',nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0)
                +nvl(sum(decode(pbc.status_code||substr(pbc.result_code,1,1)||pbc.effect_on_funds_code,'ZPI',
            nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0),
        nvl(sum(decode(pbc.status_code||pbc.actual_flag, 'AE',nvl(accounted_dr,0)-nvl(accounted_cr,0),0)),0),
        nvl(sum(decode(pbc.status_code||pbc.actual_flag, 'AA',nvl(accounted_dr,0)-nvl(accounted_cr,0),0)),0)
        FROM pa_bc_packets pbc
         --       pa_bc_packet_arrival_order ao  -- 7531681
        WHERE pbc.project_id = p_record.project_id
        AND pbc.top_task_id                 =  l_top_task_id
        AND pbc.budget_version_id           = p_record.budget_version_id
        AND pbc.set_of_books_id             =   p_sob
        AND ((p_record.time_phased_type_code = 'G' and pbc.gl_date
                between p_start_date_1 and p_end_date_1) OR   -- 7531681
             (p_record.time_phased_type_code = 'P' and pbc.pa_date
                between p_start_date_1 and p_end_date_1) OR     -- 7531681
             (p_record.time_phased_type_code = 'N' and pbc.expenditure_item_date
                between p_start_date_1 and p_end_date_1)       -- 7531681
            )
   --     AND pbc.packet_id = ao.packet_id
        and pbc.balance_posted_flag = 'N'       /* 7531681 */
        and substr(nvl(pbc.result_code,'P'),1,1)= 'P'
        AND exists
		  ( select 1 from pa_bc_packet_arrival_order ao
		    where ao.packet_id = pbc.packet_id
           AND (
                (    ao.arrival_seq <  p_arrival_seq
                --AND ao.affect_funds_flag = 'Y'
                AND ao.set_of_books_id = p_sob
                AND pbc.status_code in ( 'A','P')
	--	and substr(nvl(pbc.result_code,'P'),1,1)= 'P'  -- 7531681
         --       AND pbc.balance_posted_flag = 'N'            -- 7531681
                  )
              OR(pbc.packet_id = p_packet_id
                and pbc.status_code = 'Z'
                and pbc.effect_on_funds_code = 'I'
                and p_partial_flag <> 'Y'
          --      and pbc.balance_posted_flag = 'N'            -- 7531681
           --     and substr(nvl(pbc.result_code,'P'),1,1)= 'P'  -- 7531681
                )
               ) );
        -----------------------------------------------------------------------------------------------------
        --This CURSOR selects AND sums up all the balances for a particular project  FROM pa_bc_balances table
        --between the start date AND end date and this CURSOR is opened when funds checking rolles up to
        --the project level FROM task level
        -----------------------------------------------------------------------------------------------------
        CURSOR project_level_bal is
               /*  SELECT  nvl(sum(BUDGET_PERIOD_TO_DATE *decode(balance_type,'BGT',1,0)) ,0),
                        nvl(sum(ACTUAL_PERIOD_TO_DATE *decode(balance_type,'EXP',1,0)) ,0),
                        nvl(sum(ENCUMB_PERIOD_TO_DATE *decode(balance_type,'REQ',1,
                                                                        'PO',1,
                                                                        'AP',1,
                                                                        'ENC',1,
                                                                        'CC_C_PAY',1,
                                                                        'CC_C_CO',1,
                                                                        'CC_P_PAY',1,
                                                                        'CC_P_CO',1,
                                                                        0)),0)   7531681  */
                SELECT NVL(SUM(BUDGET_PERIOD_TO_DATE),0),
                        NVL(SUM(ACTUAL_PERIOD_TO_DATE ),0),
                        NVL(SUM(ENCUMB_PERIOD_TO_DATE),0)
                FROM   pa_bc_balances pb
                WHERE pb.project_id = p_record.project_id
                AND pb.budget_version_id     = p_record.budget_version_id
                AND pb.start_date between
                        decode(p_record.time_phased_type_code,'N', pb.start_date, p_start_date_1) AND  -- 7531681
                        decode(p_record.time_phased_type_code,'N', pb.start_date, p_end_date_1)        -- 7531681
                AND pb.end_date between
                        decode(p_record.time_phased_type_code,'N', pb.end_date, p_start_date_1) AND    -- 7531681
                        decode(p_record.time_phased_type_code,'N', pb.end_date, p_end_date_1);         -- 7531681
        -----------------------------------------------------------------------------------------------------
        --This CURSOR selects AND sums all the entedr columns FROM pa_bc_packets table for all the resources
        --falling under one project between the start date AND end date
        -- R12 note: all code related to status code 'C' and 'B' being deleted ..
        -----------------------------------------------------------------------------------------------------
        CURSOR project_tot_bc_pkt is
        SELECT   nvl(sum(decode(pbc.status_code,'P',nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0)
                +nvl(sum(decode(pbc.status_code||substr(pbc.result_code,1,1)||pbc.effect_on_funds_code,'ZPI',
            nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0),
        nvl(sum(decode(pbc.status_code||pbc.actual_flag, 'AE',nvl(accounted_dr,0)-nvl(accounted_cr,0),0)),0),
        nvl(sum(decode(pbc.status_code||pbc.actual_flag, 'AA',nvl(accounted_dr,0)-nvl(accounted_cr,0),0)),0)
        FROM pa_bc_packets pbc
             --   pa_bc_packet_arrival_order ao  -- 7531681
        WHERE pbc.project_id = p_record.project_id
        AND pbc.budget_version_id           = p_record.budget_version_id
        AND pbc.set_of_books_id             =   p_sob
        AND ((p_record.time_phased_type_code = 'G' and pbc.gl_date
                between p_start_date_1 and p_end_date_1) OR    -- 7531681
             (p_record.time_phased_type_code = 'P' and pbc.pa_date
                between p_start_date_1 and p_end_date_1) OR    -- 7531681
             (p_record.time_phased_type_code = 'N' and pbc.expenditure_item_date
                between p_start_date_1 and p_end_date_1)       -- 7531681
            )
       -- AND pbc.packet_id = ao.packet_id                          -- 7531681
        and pbc.balance_posted_flag = 'N'
        and substr(nvl(pbc.result_code,'P'),1,1)= 'P'
		AND exists
		   ( select 1 from pa_bc_packet_arrival_order ao
		     where pbc.packet_id = ao.packet_id
            AND (
                (    ao.arrival_seq <  p_arrival_seq
                --AND ao.affect_funds_flag = 'Y'
                AND ao.set_of_books_id = p_sob
                AND pbc.status_code in ( 'A','P')
	--	and substr(nvl(pbc.result_code,'P'),1,1)= 'P'    -- 7531681
         --       AND pbc.balance_posted_flag = 'N'              -- 7531681
                  )
              OR(pbc.packet_id = p_packet_id
                and pbc.status_code = 'Z'
                and pbc.effect_on_funds_code = 'I'
                and p_partial_flag <> 'Y'
          --      and pbc.balance_posted_flag = 'N'             -- 7531681
           --     and substr(nvl(pbc.result_code,'P'),1,1)= 'P'  -- 7531681
                )
               ) );

	--------------------------------------------------------------------------------------------------
	-- This CURSOR select and sums all the entered dr and entered cr columns from pa_bc_packets table
	-- for the given budget code combination id falling under the start and end date
        -- R12 note: all code related to status code 'C' and 'B' being deleted ..
	-------------------------------------------------------------------------------------------------
	CURSOR project_acct_tot_bc_pkt(l_bdgt_ccid  NUMBER) is
	SELECT   nvl(sum(decode(pbc.status_code,'P',nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0)
                +nvl(sum(decode(pbc.status_code||substr(pbc.result_code,1,1)||pbc.effect_on_funds_code,'ZPI',
            nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0),
	nvl(sum(decode(pbc.status_code||pbc.actual_flag, 'AE',nvl(accounted_dr,0)-nvl(accounted_cr,0),0)),0),
        nvl(sum(decode(pbc.status_code||pbc.actual_flag, 'AA',nvl(accounted_dr,0)-nvl(accounted_cr,0),0)),0)
	FROM pa_bc_packets pbc
         --       pa_bc_packet_arrival_order ao  -- 7531681
        WHERE pbc.project_id = p_record.project_id
        AND pbc.budget_version_id           = p_record.budget_version_id
        AND pbc.set_of_books_id             =   p_sob
	ANd pbc.budget_ccid		    = l_bdgt_ccid
        AND ((p_record.time_phased_type_code = 'G' and pbc.gl_date
                between p_start_date_1 and p_end_date_1) OR   -- 7531681
             (p_record.time_phased_type_code = 'P' and pbc.pa_date
                between p_start_date_1 and p_end_date_1) OR   -- 7531681
             (p_record.time_phased_type_code = 'N' and pbc.expenditure_item_date
                between p_start_date_1 and p_end_date_1)     -- 7531681
            )
      --  AND pbc.packet_id = ao.packet_id  -- 7531681
        and pbc.balance_posted_flag = 'N'
        and substr(nvl(pbc.result_code,'P'),1,1)= 'P'
        AND exists
		   (select 1 from pa_bc_packet_arrival_order ao
		    where pbc.packet_id = ao.packet_id
            AND (
                (    ao.arrival_seq <  p_arrival_seq
                --AND ao.affect_funds_flag = 'Y'
                AND ao.set_of_books_id = p_sob
                AND pbc.status_code in ( 'A','P')
        --	and substr(nvl(pbc.result_code,'P'),1,1)= 'P'  -- 7531681
        --      AND pbc.balance_posted_flag = 'N'              -- 7531681
                  )
              OR(pbc.packet_id = p_packet_id
                and pbc.status_code = 'Z'
                and pbc.effect_on_funds_code = 'I'
                and p_partial_flag <> 'Y'
         --     and pbc.balance_posted_flag = 'N'             -- 7531681
         --     and substr(nvl(pbc.result_code,'P'),1,1)= 'P'  -- 7531681
                )
                ));



        -----------------------------------------------------------------------------------------------------
	-- declare required  local variables
	l_stage			    	    VARCHAR2(10);
        l_r_budget_posted                   pa_bc_packets.res_budget_posted%type;
        l_rg_budget_posted                  pa_bc_packets.res_budget_posted%type;
        l_t_budget_posted                   pa_bc_packets.res_budget_posted%type;
        l_tt_budget_posted                  pa_bc_packets.res_budget_posted%type;
        l_p_budget_posted                   pa_bc_packets.res_budget_posted%type;
        l_r_actual_posted                   pa_bc_packets.res_budget_posted%type;
        l_rg_actual_posted                  pa_bc_packets.res_budget_posted%type;
        l_t_actual_posted                   pa_bc_packets.res_budget_posted%type;
        l_tt_actual_posted                  pa_bc_packets.res_budget_posted%type;
        l_p_actual_posted                   pa_bc_packets.res_budget_posted%type;
        l_r_enc_posted                      pa_bc_packets.res_budget_posted%type;
        l_rg_enc_posted                     pa_bc_packets.res_budget_posted%type;
        l_t_enc_posted                      pa_bc_packets.res_budget_posted%type;
        l_tt_enc_posted                     pa_bc_packets.res_budget_posted%type;
        l_p_enc_posted                      pa_bc_packets.res_budget_posted%type;
        l_r_budget_bal                      pa_bc_packets.res_budget_posted%type;
        l_rg_budget_bal                     pa_bc_packets.res_budget_posted%type;
        l_t_budget_bal                      pa_bc_packets.res_budget_posted%type;
        l_tt_budget_bal                     pa_bc_packets.res_budget_posted%type;
        l_p_budget_bal                      pa_bc_packets.res_budget_posted%type;
        l_r_actual_approved                 pa_bc_packets.res_budget_posted%type;
        l_rg_actual_approved                pa_bc_packets.res_budget_posted%type;
        l_t_actual_approved                 pa_bc_packets.res_budget_posted%type;
        l_tt_actual_approved                pa_bc_packets.res_budget_posted%type;
        l_p_actual_approved                 pa_bc_packets.res_budget_posted%type;
        l_r_enc_approved                    pa_bc_packets.res_budget_posted%type;
        l_rg_enc_approved                   pa_bc_packets.res_budget_posted%type;
        l_t_enc_approved                    pa_bc_packets.res_budget_posted%type;
        l_tt_enc_approved                   pa_bc_packets.res_budget_posted%type;
        l_p_enc_approved                    pa_bc_packets.res_budget_posted%type;
        l_result_code                       pa_bc_packets.result_code%type;
        l_r_result_code                     pa_bc_packets.res_result_code%type;
        l_rg_result_code                    pa_bc_packets.res_grp_result_code%type;
        l_t_result_code                     pa_bc_packets.task_result_code%type;
        l_tt_result_code                    pa_bc_packets.top_task_result_code%type;
        l_p_result_code                     pa_bc_packets.project_result_code%type;
	l_p_acct_result_code		    pa_bc_packets.project_result_code%type;
	l_status_code			    pa_bc_packets.status_code%type;
	l_available_amt			    pa_bc_packets.accounted_dr%type;
	l_return_status			    VARCHAR2(200);
	l_r_enc_pending			    NUMBER;
	l_rg_enc_pending		    NUMBER;
	l_t_enc_pending			    NUMBER;
	l_tt_enc_pending		    NUMBER;
	l_p_enc_pending			    NUMBER;
	l_r_actual_pending		    NUMBER;
        l_rg_actual_pending                 NUMBER;
        l_t_actual_pending                  NUMBER;
        l_tt_actual_pending                 NUMBER;
        l_p_actual_pending                  NUMBER;
	l_pkt_amt			    NUMBER;
	l_acct_level_bal		    NUMBER;
	l_p_acct_pkt_amt		    NUMBER;
	l_p_acct_enc_approved		    NUMBER;
	l_p_acct_actual_approved	    NUMBER;
	l_cached_satus			    varchar2(100);


BEGIN
	-- use one level cache for storing the balances
    p_start_date_1 := TRUNC(p_start_date);    -- 7531681
    p_end_date_1 := TRUNC(p_end_date);

	CACHE_PKT_AMOUNTS(
		p_project_id	=> 	p_record.project_id
		,p_bdgt_version =>	p_record.budget_version_id
		,p_top_task_id	=>	p_record.top_task_id
		,p_task_id	=>	p_record.task_id
		,p_bud_task_id	=>	p_record.bud_task_id
		,p_start_date	=>	p_start_date
		,p_end_date	=>	p_end_date
		,p_rlmi		=>	p_record.resource_list_member_id
		,p_bud_rlmi	=>	p_record.bud_resource_list_member_id
		,p_prlmi	=>	p_record.parent_resource_id
		,p_bdgt_ccid	=>	p_record.budget_ccid
		,p_accounted_dr =>	p_record.accounted_dr
		,p_accounted_cr	=>	p_record.accounted_cr
                ,p_calling_module =>    p_calling_module
		,p_partial_flag   =>    p_partial_flag
                ,p_function     =>	'ADD'
                ,p_bc_packet_id =>      p_record.bc_packet_id
                ,p_doc_type      =>     p_record.document_type
                ,p_doc_header_id =>     p_record.document_header_id
		,p_doc_distribution_id =>p_record.document_distribution_id
                ,x_result_code   =>     l_result_code
		,x_cached_status =>     l_cached_satus
		,p_counter       =>     p_counter
		);

	IF substr(l_result_code ,1,1) = 'F' then
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>'l_result_code from cache ='||l_result_code);
		end if;
                        -- msg : Raw line is failed so donot funds check for burden
                        l_r_result_code := l_result_code;
                        l_rg_result_code :=l_result_code;
                        l_t_result_code := l_result_code;
                        l_tt_result_code :=l_result_code;
                        l_p_result_code  := l_result_code;
                        l_p_acct_result_code  := l_result_code;
                      GOTO END_PROCESS;

	End if;


	-- check whether the effect on funds  is Increase then it doesnot require
	-- funds check so pass the transaction
	If p_record.effect_on_funds_code = 'I' then
		IF g_debug_mode = 'Y' THEN
		   log_message(p_msg_token1 =>'Effect on funds code ='||p_record.effect_on_funds_code);
		end if;
			-- msg : P113 = Increase in funds doest not require FC
                        l_r_result_code := 'P113';
                        l_rg_result_code := 'P113';
                        l_t_result_code := 'P113';
                        l_tt_result_code := 'P113';
                        l_p_result_code  := 'P113';
                        l_p_acct_result_code  := 'P113';
                        l_result_code    := 'P113';
                      GOTO END_PROCESS;
        End if;

	-- check if teh budget version id or rlmi is null in pa bc packets then
	-- mark it as invalid parameters  for the funds check process
	If p_record.budget_version_id is NULL or p_record.resource_list_member_id is NULL
		or p_record.expenditure_item_date is NULL or p_record.pa_date is null or
	        p_record.gl_date is null  then
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'invalid params in check avaiable ');
		end if;
			l_status_code   := 'F';
			l_r_result_code := 'F118';
                        l_rg_result_code := 'F118';
                        l_t_result_code := 'F118';
                        l_tt_result_code := 'F118';
                        l_p_result_code  := 'F118';
			l_p_acct_result_code  := 'F118';
                        l_result_code    := 'F118';
                      GOTO END_PROCESS;
	End if;

	--check whether the burdened cost flag is Y or N  if the burden_cost_flag = 'N'
	-- mark the transaction with failure status for Invalid budget entry methods
	-- funds check will be done only for burdened cost
	If nvl(p_record.burdened_cost_flag,'N')   <> 'Y' then
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'burden cost flag ='||p_record.burdened_cost_flag);
		End if;
                        l_status_code   := 'F';
                        l_r_result_code := 'F131';
                        l_rg_result_code := 'F131';
                        l_t_result_code := 'F131';
                        l_tt_result_code := 'F131';
                        l_p_result_code  := 'F131';
			l_p_acct_result_code  := 'F131';
                        l_result_code    := 'F131';
                      GOTO END_PROCESS;
	End if;

	/*****************************************************************************/
		--  START OF FUNDS CHECK AT RESOURCE LEVEL -------
	/****************************************************************************/
	IF g_debug_mode = 'Y' THEN
	   log_message(p_msg_token1 => 'category code ['||p_record.categorization_code||
		']start date ['||p_start_date||'] end date['|| p_end_date||
		']rlmi ['||p_record.resource_list_member_id||']bud_rlmi['||p_record.bud_resource_list_member_id||
		']prlmi ['||p_record.parent_resource_id||']bud task id['||p_record.bud_task_id||
		']time phase code ['||p_record.time_phased_type_code||
                ']budget verson id ['||p_record.budget_version_id||
		']project id ['||p_record.project_id||']top task id ['||p_record.top_task_id||
		']arrival seq [ '||p_arrival_seq||']resource_group_type_id['||p_record.group_resource_type_id||']');
	End if;

	-- check funds at resource level if the budget is categorized by resource
	-- otherwise go the task level and check funds
	IF nvl(p_record.categorization_code,'N')  = 'R' then
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'Categorization code ='||p_record.categorization_code);
		End if;
		l_stage := 100;

           IF (p_record.project_id <> g_bal_r_project_id OR g_bal_r_project_id is NULL ) OR
              (p_record.budget_version_id <> g_bal_r_bdgt_version_id  or g_bal_r_bdgt_version_id is NULL ) OR
              (p_record.time_phased_type_code  <> g_bal_r_time_phase_code  or g_bal_r_time_phase_code is NULL ) OR
              (p_start_date_1 <> trunc(g_bal_r_start_date) or g_bal_r_start_date is NULL ) OR   -- 7531681
              (p_end_date_1  <> trunc(g_bal_r_end_date )  or g_bal_r_end_date is NULL) OR        -- 7531681
              (p_record.bud_task_id <> g_bal_r_bud_task_id  OR g_bal_r_bud_task_id is NULL ) OR
              (p_record.resource_list_member_id <> g_bal_r_rlmi or g_bal_r_rlmi is NULL ) Then


		OPEN res_level_bal (p_record.resource_list_member_id);
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'opened the cursor res_level_bal');
		end if;
		FETCH res_level_bal INTO l_r_budget_posted,
					 l_r_actual_posted,
					 l_r_enc_posted;
		-- store the values in global variables
		g_r_budget_posted := l_r_budget_posted;
		g_r_actual_posted := l_r_actual_posted;
		g_r_enc_posted    := l_r_enc_posted;

		--- added for performance testing to use as onelevel cache
        	g_bal_r_project_id            := p_record.project_id;
        	g_bal_r_bdgt_version_id       := p_record.budget_version_id;
        	g_bal_r_bud_task_id           := p_record.bud_task_id;
        	g_bal_r_rlmi                  := p_record.resource_list_member_id;
        	g_bal_r_start_date            := p_start_date_1;     -- 7531681
        	g_bal_r_end_date              := p_end_date_1;         -- 7531681
        	g_bal_r_time_phase_code       := p_record.time_phased_type_code;

		CLOSE res_level_bal;
	  ELSE
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'Same combination for res level bal cur ');
		end if;
                l_r_budget_posted := g_r_budget_posted;
                l_r_actual_posted := g_r_actual_posted;
                l_r_enc_posted  := g_r_enc_posted;

	  END IF;  -- end of onelevel cache
		IF g_debug_mode = 'Y' THEN
                  log_message(p_msg_token1 => 'r_bud_posted ['||l_r_budget_posted||
                        ']r_actual_posted ['||l_r_actual_posted||']r_enc posted ['||l_r_enc_posted|| ']' );
		End if;

	 -- open the cursor for packet amounts at resource level
           IF (p_record.project_id <> g_pkt_r_project_id OR g_pkt_r_project_id is NULL ) OR
              (p_record.budget_version_id <> g_pkt_r_bdgt_version_id  or g_pkt_r_bdgt_version_id is NULL ) OR
              --(p_record.time_phased_type_code  <> g_pkt_r_time_phase_code  or g_pkt_r_time_phase_code is NULL ) OR
              (p_record.entry_level_code <> g_pkt_r_entry_level_code or g_pkt_r_entry_level_code is  NULL ) OR
              (p_start_date_1 <> trunc(g_pkt_r_start_date) or g_pkt_r_start_date is NULL ) OR  -- 7531681
              (p_end_date_1  <> trunc(g_pkt_r_end_date )  or g_pkt_r_end_date is NULL) OR      -- 7531681
              (p_record.bud_task_id <> g_pkt_r_bud_task_id  OR g_pkt_r_bud_task_id is NULL ) OR
              (p_record.Parent_resource_id  <> g_pkt_r_prlmi or g_pkt_r_prlmi is NULL ) OR
              (p_record.resource_list_member_id <> g_pkt_r_rlmi or g_pkt_r_rlmi is NULL ) Then

		OPEN res_tot_bc_pkt(p_record.resource_list_member_id,p_record.Parent_resource_id);
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'opened the cursor res_tot_bc_pkt');
		End if;
		FETCH res_tot_bc_pkt INTO l_pkt_amt
					,l_r_enc_approved
				        ,l_r_actual_approved ;
		-- assign the values to global variables to use as onelevel cache
		g_r_base_amt	 := l_pkt_amt;
		g_r_enc_approved := l_r_enc_approved;
		g_r_enc_pending  := l_r_enc_pending;
		g_r_actual_approved := l_r_actual_approved;
		g_r_actual_pending := l_r_actual_pending;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'fetch cursor res_tot_bc_pkt');
		End if;
		CLOSE res_tot_bc_pkt;

		--added for performance test to use as one level cache
        	g_pkt_r_project_id            := p_record.project_id;
        	g_pkt_r_bdgt_version_id       := p_record.budget_version_id;
        	g_pkt_r_bud_task_id           := p_record.bud_task_id;
        	g_pkt_r_rlmi                  := p_record.resource_list_member_id;
        	g_pkt_r_prlmi                 := p_record.Parent_resource_id;
        	g_pkt_r_entry_level_code      := p_record.entry_level_code;
        	g_pkt_r_start_date            := p_start_date_1;   -- 7531681
        	g_pkt_r_end_date              := p_end_date_1;      -- 7531681
        	g_pkt_r_time_phase_code       := p_record.time_phased_type_code;
		---------------------end of performance test --------------

	   ELSE

		l_pkt_amt	 := g_r_base_amt;
                l_r_enc_approved := g_r_enc_approved;
                l_r_enc_pending  := g_r_enc_pending;
                l_r_actual_approved := g_r_actual_approved;
                l_r_actual_pending := g_r_actual_pending;
	   END IF;  -- end of onelevel cache
		IF g_debug_mode = 'Y' THEN
		   log_message(p_msg_token1 => 'l_pkt_amount ['||l_pkt_amt||
		      ']l_r_enc_approved ['||l_r_enc_approved||']l_r_enc_pending ['||l_r_enc_pending||
		      ']l_r_actual_approved ['||l_r_actual_approved||']l_r_actual_pending ['||l_r_actual_pending||']');
		End if;

		l_available_amt := nvl(l_r_budget_posted,0) -
					(nvl(l_r_actual_posted,0) +
					nvl(l_r_enc_posted,0) +
				   	nvl(l_pkt_amt,0) +
					nvl(l_r_actual_approved,0) +
					nvl(l_r_enc_approved,0) +
					NVL(g_r_pkt_amt,0)
					);
		IF g_debug_mode = 'Y' THEN
		     log_message(p_msg_token1 =>'avaialbe amt ='||l_available_amt);
		End if;
		IF  p_record.status_code||p_record.actual_flag = 'AE' then
			l_r_enc_approved := nvl(l_r_enc_approved,0) +
					 	p_record.accounted_dr
						- p_record.accounted_cr;
			IF g_debug_mode = 'Y' THEN
		        	log_message(p_msg_token1 =>'r_enc_approv ='||l_r_enc_approved);
			End if;
		ELSIF p_record.status_code||p_record.actual_flag = 'PE' then
			l_r_enc_pending := nvl(l_r_enc_pending,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'r enc pend ='||l_r_enc_pending);
			end if;

                ELSIF p_record.status_code||p_record.actual_flag = 'AA' then
                        l_r_actual_approved := nvl(l_r_actual_approved,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'r actual approv ='||l_r_actual_approved);
			end if;

                ELSIF p_record.status_code||p_record.actual_flag = 'PA' then
                        l_r_actual_pending := nvl(l_r_actual_pending,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'r_actual pending ='||l_r_actual_pending);
			end if;

		END IF;
		l_r_budget_bal := l_available_amt;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'calling generate result code api ');
			end if;
                        generate_result_code(
                        p_fclevel_code         => p_record.r_funds_control_level_code,
                        p_available_amt        => l_available_amt,
                        p_stage                => l_stage,
                        p_budget_posted_amt    => l_r_budget_posted,
                        x_result_code          => l_result_code,
                        x_r_result_code        => l_r_result_code,
                        x_rg_result_code       => l_rg_result_code,
                        x_t_result_code        => l_t_result_code,
                        x_tt_result_code       => l_tt_result_code,
                        x_p_result_code        => l_p_result_code,
                        x_p_acct_result_code   => l_p_acct_result_code,
                        x_return_status        => l_return_status
                                ) ;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'end of generate result code api '
				||'l_r_result_code ['||l_r_result_code||']l_result_code['||l_result_code||']' );
			End if;

		IF l_return_status  = 'F' THEN
		 	GOTO END_PROCESS;
		ELSE
			-- PROCEED TO NEXT STAGE ie RESOURCE GROUP LEVEL
			NULL;
		END IF;


		--********************************************************************
			-- RESOURCE GROUP LEVEL ------
		--*******************************************************************
               l_stage := 200;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'Stage 200');
		end if;

	/* Bug fix 2658952 : If the Budget is by resource only with no resource group then
         * donot check the balances at the resource group level
	 * group_resoruce_type_id = 0 indicates resource group by is NONE in resource list */

	IF NVL(p_record.group_resource_type_id,0) <> 0 Then

         -- open the cursor for packet amounts at resource  group level
           IF (p_record.project_id <> g_bal_rg_project_id OR g_bal_rg_project_id is NULL ) OR
              (p_record.budget_version_id <> g_bal_rg_bdgt_version_id  or g_bal_rg_bdgt_version_id is NULL ) OR
              (p_record.time_phased_type_code  <> g_bal_rg_time_phase_code  or g_bal_rg_time_phase_code is NULL ) OR
              --(p_record.entry_level_code <> g_bal_rg_entry_level_code or g_bal_rg_entry_level_code is  NULL ) OR
              (p_start_date_1 <> trunc(g_bal_rg_start_date) or g_bal_rg_start_date is NULL ) OR  -- 7531681
              (p_end_date_1  <> trunc(g_bal_rg_end_date )  or g_bal_rg_end_date is NULL) OR      -- 7531681
              (p_record.bud_task_id <> g_bal_rg_bud_task_id  OR g_bal_rg_bud_task_id is NULL ) OR
              (p_record.Parent_resource_id  <> g_bal_rg_prlmi or g_bal_rg_prlmi is NULL ) OR
              (p_record.bud_resource_list_member_id <> g_bal_rg_bud_rlmi or g_bal_rg_bud_rlmi is NULL ) Then

                OPEN res_grp_level_bal (p_record.parent_resource_id,p_record.bud_resource_list_member_id);
		IF g_debug_mode = 'Y' THEN
		 	log_message(p_msg_token1 =>'opened res_grp_level_bal cursor ');
		End if;
                FETCH res_grp_level_bal INTO l_rg_budget_posted,
                                         l_rg_actual_posted,
                                         l_rg_enc_posted;
                CLOSE res_grp_level_bal;
                -- check whether the resource level budget balance is zero and control level
                -- is Absolute then check the budget by rolling up the balances from  resource
                IF l_rg_budget_posted = 0  then
			OPEN res_rollup_bal (p_record.parent_resource_id);
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'rg budget posted is zero so open rollup cursor ');
			end if;
                	FETCH res_rollup_bal INTO l_rg_budget_posted,
                                         l_rg_actual_posted,
                                         l_rg_enc_posted;
                	CLOSE res_rollup_bal;
		END IF;
		g_rg_budget_posted := l_rg_budget_posted;
		g_rg_actual_posted := l_rg_actual_posted;
		g_rg_enc_posted    := l_rg_enc_posted;

                --- added for performance testing
        	g_bal_rg_project_id            := p_record.project_id;
        	g_bal_rg_bdgt_version_id       := p_record.budget_version_id;
        	g_bal_rg_bud_task_id           := p_record.bud_task_id;
        	g_bal_rg_bud_rlmi              := p_record.bud_resource_list_member_id;
        	g_bal_rg_prlmi                 := p_record.parent_resource_id;
        	g_bal_rg_entry_level_code      := p_record.entry_level_code;
        	g_bal_rg_start_date            := p_start_date_1;                        -- 7531681
        	g_bal_rg_end_date              := p_end_date_1;                            -- 7531681
        	g_bal_rg_time_phase_code       := p_record.time_phased_type_code;
       		------------------ end of perfromance test ----

	    ELSE
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'same comination for res_grp bal cur');
		end if;
                l_rg_budget_posted := g_rg_budget_posted;
                l_rg_actual_posted := g_rg_actual_posted;
                l_rg_enc_posted    := g_rg_enc_posted;
	    END IF;  -- end for one level cache
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>'rg budget posted ['||l_rg_budget_posted||
                	']rg actual_posted [ '||l_rg_actual_posted||']rg enc_posted ['||l_rg_enc_posted ||']');
		end if;

         -- open the cursor for packet amounts at resource  group level
           IF (p_record.project_id <> g_pkt_rg_project_id OR g_pkt_rg_project_id is NULL ) OR
              (p_record.budget_version_id <> g_pkt_rg_bdgt_version_id  or g_pkt_rg_bdgt_version_id is NULL ) OR
              --(p_record.time_phased_type_code  <> g_pkt_rg_time_phase_code  or g_pkt_rg_time_phase_code is NULL ) OR
              (p_record.entry_level_code <> g_pkt_rg_entry_level_code or g_pkt_rg_entry_level_code is  NULL ) OR
              (p_start_date_1 <> trunc(g_pkt_rg_start_date) or g_pkt_rg_start_date is NULL ) OR   -- 7531681
              (p_end_date_1  <> trunc(g_pkt_rg_end_date )  or g_pkt_rg_end_date is NULL) OR       -- 7531681
              (p_record.bud_task_id <> g_pkt_rg_bud_task_id  OR g_pkt_rg_bud_task_id is NULL ) OR
              (p_record.Parent_resource_id  <> g_pkt_rg_prlmi or g_pkt_rg_prlmi is NULL) OR
		/* added for bug fix: 2658952 */
              (((p_record.Parent_resource_id = 0 and g_pkt_rg_rlmi <> p_record.resource_list_member_id)
                 or (g_pkt_rg_rlmi is NULL and p_record.Parent_resource_id = 0 )) /* endof bug fix 2658952 */
              ) Then

                OPEN res_grp_tot_bc_pkt(p_record.Parent_resource_id,p_record.resource_list_member_id);
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'opened the res_grp_tot_bc_pkt cursor ');
		end if;
                FETCH res_grp_tot_bc_pkt INTO l_pkt_amt
                                        ,l_rg_enc_approved
                                        ,l_rg_actual_approved ;

		--store the values in global to use as one level cache
		g_rg_base_amt     := l_pkt_amt;
		g_rg_enc_approved   := l_rg_enc_approved;
		g_rg_enc_pending    := l_rg_enc_pending;
		g_rg_actual_approved := l_rg_actual_approved;
		g_rg_actual_pending  := l_rg_actual_pending;
                CLOSE res_grp_tot_bc_pkt;

        	--added for performance test to use as one level cache
        	g_pkt_rg_project_id            := p_record.project_id;
        	g_pkt_rg_bdgt_version_id       := p_record.budget_version_id;
        	g_pkt_rg_bud_task_id           := p_record.bud_task_id;
        	g_pkt_rg_rlmi                  := p_record.resource_list_member_id;
        	--g_pkt_rg_bud_rlmi              := null;
        	g_pkt_rg_prlmi                 := p_record.Parent_resource_id;
        	g_pkt_rg_entry_level_code      := p_record.entry_level_code;
        	g_pkt_rg_start_date            := p_start_date_1;           -- 7531681
        	g_pkt_rg_end_date              := p_end_date_1;             -- 7531681
        	g_pkt_rg_time_phase_code       := p_record.time_phased_type_code;
        	------------end of performance test --------------

	    ELSE
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'Same combination found at resgrppkt cursor');
		end if;
		l_pkt_amt  	    := g_rg_base_amt ;
                l_rg_enc_approved   := g_rg_enc_approved;
                l_rg_enc_pending    := g_rg_enc_pending;
                l_rg_actual_approved := g_rg_actual_approved;
                l_rg_actual_pending  := g_rg_actual_pending;

	    END IF ; -- end of one level cache
	    IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'rg_l_pkt_amt ['||l_pkt_amt||
                ']rg_enc_approved ['||l_rg_enc_approved||']rg_rg_enc_pending ['||l_rg_enc_pending||
                ']rg_actual_approved [ '||l_rg_actual_approved||']rg_actual_pending ['||l_rg_actual_pending||']');
	    End if;

                l_available_amt := nvl(l_rg_budget_posted,0) -
                                        (nvl(l_rg_actual_posted,0) +
                                        nvl(l_rg_enc_posted,0) +
                                        nvl(l_pkt_amt,0) +
                                        nvl(l_rg_actual_approved,0) +
                                        nvl(l_rg_enc_approved,0) +
					nvl(g_rg_pkt_amt ,0)
                                        );
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'available_amt = '|| l_available_amt);
		End if;
                IF  p_record.status_code||p_record.actual_flag = 'AE' then
                        l_rg_enc_approved := nvl(l_rg_enc_approved,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
			IF g_debug_mode = 'Y' THEN
		   		log_message(p_msg_token1 =>'rg_enc_approved ='||l_rg_enc_approved);
			end if;
                ELSIF p_record.status_code||p_record.actual_flag = 'PE' then
                        l_rg_enc_pending := nvl(l_rg_enc_pending,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'rg_rg_enc_pending ='||l_rg_enc_pending);
			end if;

                ELSIF p_record.status_code||p_record.actual_flag = 'AA' then
                        l_rg_actual_approved := nvl(l_rg_actual_approved,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'rg_actual_approved = '||l_rg_actual_approved);
			end if;

                ELSIF p_record.status_code||p_record.actual_flag = 'PA' then
                        l_rg_actual_pending := nvl(l_rg_actual_pending,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'rg_actual_pending ='||l_rg_actual_pending);
			end if;

                END IF;
                l_rg_budget_bal := l_available_amt;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'calling generate_result_code at res rgp ');
			end if;
                        generate_result_code(
                        p_fclevel_code         => p_record.rg_funds_control_level_code,
                        p_available_amt        => l_available_amt,
                        p_stage                => l_stage,
                        p_budget_posted_amt    => l_rg_budget_posted,
                        x_result_code          => l_result_code,
                        x_r_result_code        => l_r_result_code,
                        x_rg_result_code       => l_rg_result_code,
                        x_t_result_code        => l_t_result_code,
                        x_tt_result_code       => l_tt_result_code,
                        x_p_result_code        => l_p_result_code,
                        x_p_acct_result_code   => l_p_acct_result_code,
                        x_return_status        => l_return_status
                                ) ;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'end of generate_result_code api'||
                        	'l_rg_result_code [ '||l_rg_result_code||'l_result_code ['||l_result_code||']' );
			end if;

                IF l_return_status  = 'F' THEN
                        GOTO END_PROCESS;
                ELSE
                        -- PROCEED TO NEXT STAGE ie TASK LEVEL
                        NULL;
                END IF;

	   ELSE
		  -- Pass the transaction at resource group level if the resoource is not grouped
                  -- by resource group
		  l_rg_result_code := 'P109';

	   END IF ; -- end of group_resource_type_id /* bug fix 2658952 */

	END IF;  -- end if for budget categorization of resource

	--******************************************************************************
			-- TASK LEVEL BALANCE ------
	--******************************************************************************

	-- check whether the budget is by task  if so then check the funds available at task level
	IF p_record.bud_task_id <> 0  then
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'Stage = 300');
		End if;
               	l_stage := 300;
         -- open the cursor for packet amounts at task level
           IF (p_record.project_id <> g_bal_t_project_id OR g_bal_t_project_id is NULL ) OR
              (p_record.budget_version_id <> g_bal_t_bdgt_version_id  or g_bal_t_bdgt_version_id is NULL ) OR
              (p_record.time_phased_type_code  <> g_bal_t_time_phase_code  or g_bal_t_time_phase_code is NULL ) OR
              --(p_record.entry_level_code <> g_bal_t_entry_level_code or g_bal_t_entry_level_code is  NULL ) OR
              (p_start_date_1 <> trunc(g_bal_t_start_date) or g_bal_t_start_date is NULL ) OR  -- 7531681
              (p_end_date_1  <> trunc(g_bal_t_end_date )  or g_bal_t_end_date is NULL) OR      -- 7531681
              (p_record.task_id <> g_bal_t_task_id  OR g_bal_t_task_id is NULL ) THEN


		OPEN  task_level_bal (p_record.bud_task_id);
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'opened the cursor task_level_bal');
		end if;
                FETCH task_level_bal INTO l_t_budget_posted,
                                         l_t_actual_posted,
                                         l_t_enc_posted;

		-- assign the fetched values to globals and use it as cache
		g_t_budget_posted := l_t_budget_posted;
		g_t_actual_posted := l_t_actual_posted;
		g_t_enc_posted    := l_t_enc_posted;

                CLOSE task_level_bal;

                --- added for performance testing
        	g_bal_t_project_id            := p_record.project_id;
        	g_bal_t_task_id               := p_record.task_id;
        	g_bal_t_bdgt_version_id       := p_record.budget_version_id;
        	g_bal_t_bud_task_id           := p_record.bud_task_id;
        	g_bal_t_bud_rlmi              := p_record.bud_resource_list_member_id;
        	g_bal_t_prlmi                 := p_record.parent_resource_id;
        	g_bal_t_entry_level_code      := p_record.entry_level_code;
        	g_bal_t_start_date            := p_start_date_1;           -- 7531681
        	g_bal_t_end_date              := p_end_date_1;             -- 7531681
        	g_bal_t_time_phase_code       := p_record.time_phased_type_code;
       		-------------------- end of perfromance test ----
            ELSE
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 => 'same combination found for task level bal');
		end if;
                l_t_budget_posted := g_t_budget_posted;
                l_t_actual_posted := g_t_actual_posted;
                l_t_enc_posted    := g_t_enc_posted;
            END IF;
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>'t_budget_posted ['||l_t_budget_posted||
                	']t_actual_posted ['||l_t_actual_posted||']tenc_posted ['||l_t_enc_posted||']');
		end if;

           IF (p_record.project_id <> g_pkt_t_project_id OR g_pkt_t_project_id is NULL ) OR
              (p_record.budget_version_id <> g_pkt_t_bdgt_version_id  or g_pkt_t_bdgt_version_id is NULL ) OR
              --(p_record.time_phased_type_code  <> g_pkt_t_time_phase_code  or g_pkt_t_time_phase_code is NULL ) OR
              (p_record.entry_level_code <> g_pkt_t_entry_level_code or g_pkt_t_entry_level_code is  NULL ) OR
              (p_start_date_1 <> trunc(g_pkt_t_start_date) or g_pkt_t_start_date is NULL ) OR     -- 7531681
              (p_end_date_1  <> trunc(g_pkt_t_end_date )  or g_pkt_t_end_date is NULL) OR          -- 7531681
              (p_record.top_task_id <> g_pkt_t_top_task_id  OR g_pkt_t_top_task_id is NULL ) OR
              (p_record.task_id <> g_pkt_t_task_id  OR g_pkt_t_task_id is NULL ) THEN

                OPEN task_tot_bc_pkt  (p_record.task_id ,p_record.top_task_id );
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'opened task_tot_bc_pkt cursor ');
		end if;
                FETCH task_tot_bc_pkt INTO l_pkt_amt
                                        ,l_t_enc_approved
                                        ,l_t_actual_approved ;
		g_t_base_amt	    := l_pkt_amt;
		g_t_enc_approved    := l_t_enc_approved;
		g_t_enc_pending     := l_t_enc_pending;
		g_t_actual_approved := l_t_actual_approved;
		g_t_actual_pending  := l_t_actual_pending;

                CLOSE task_tot_bc_pkt;


        	-- added for performance test
        	g_pkt_t_project_id            := p_record.project_id;
        	g_pkt_t_task_id               := p_record.task_id;
        	g_pkt_t_top_task_id           := p_record.top_task_id;
        	g_pkt_t_bdgt_version_id       := p_record.budget_version_id;
        	g_pkt_t_prlmi                 := p_record.Parent_resource_id;
        	g_pkt_t_entry_level_code      := p_record.entry_level_code;
        	g_pkt_t_start_date            := p_start_date_1;           -- 7531681
        	g_pkt_t_end_date              := p_end_date_1;              -- 7531681
        	g_pkt_t_time_phase_code       := p_record.time_phased_type_code;
        	----------end of performance test --------------

	    ELSE
		--assign the values to global variables to use one level cache
		l_pkt_amt	    := g_t_base_amt;
                l_t_enc_approved    := g_t_enc_approved;
                l_t_enc_pending     := g_t_enc_pending;
                l_t_actual_approved := g_t_actual_approved;
                l_t_actual_pending  := g_t_actual_pending;
	    END IF;
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>'pkt_amt ['||l_pkt_amt||
                	']t_enc_approved ['||l_t_enc_approved||']t_enc_pending [ '||l_t_enc_pending||
                	']t_actual_approved ['||l_t_actual_approved||']t_actual_pending ['||l_t_actual_pending||']');
		End if;

                l_available_amt := nvl(l_t_budget_posted,0) -
                                        (nvl(l_t_actual_posted,0) +
                                        nvl(l_t_enc_posted,0) +
                                        nvl(l_pkt_amt,0) +
                                        nvl(l_t_actual_approved,0) +
                                        nvl(l_t_enc_approved,0) +
					nvl(g_t_pkt_amt,0)
                                        );
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'available_amt ='||l_available_amt);
		end if;
                IF  p_record.status_code||p_record.actual_flag = 'AE' then
                        l_t_enc_approved := nvl(l_t_enc_approved,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
		IF g_debug_mode = 'Y' THEN
		 	log_message(p_msg_token1 =>'t_enc_approved ='||l_t_enc_approved);
		end if;
                ELSIF p_record.status_code||p_record.actual_flag = 'PE' then
                        l_t_enc_pending := nvl(l_t_enc_pending,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'t_enc_pending = '||l_t_enc_pending);
		end if;

                ELSIF p_record.status_code||p_record.actual_flag = 'AA' then
                        l_t_actual_approved := nvl(l_t_actual_approved,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'t_actual_approved ='||l_t_actual_approved);
		end if;

                ELSIF p_record.status_code||p_record.actual_flag = 'PA' then
                        l_t_actual_pending := nvl(l_t_actual_pending,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'t_actual_pending ='||l_t_actual_pending);
		end if;

                END IF;
                l_t_budget_bal := l_available_amt;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'calling generate_result_code api ');
		end if;
                        generate_result_code(
                        p_fclevel_code         => p_record.t_funds_control_level_code,
                        p_available_amt        => l_available_amt,
                        p_stage                => l_stage,
                        p_budget_posted_amt    => l_t_budget_posted,
                        x_result_code          => l_result_code,
                        x_r_result_code        => l_r_result_code,
                        x_rg_result_code       => l_rg_result_code,
                        x_t_result_code        => l_t_result_code,
                        x_tt_result_code       => l_tt_result_code,
                        x_p_result_code        => l_p_result_code,
                        x_p_acct_result_code   => l_p_acct_result_code,
                        x_return_status        => l_return_status
                                ) ;
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 =>'l_t_result_code = '||l_t_result_code||
                                                   'l_result_code ='||l_result_code);
			end if;
                IF l_return_status  = 'F' THEN
                        GOTO END_PROCESS;
                ELSE
                        -- PROCEED TO NEXT STAGE ie TOP TASK LEVEL
                        NULL;
                END IF;

        END IF;
	--*****************************************************************************
			--- TOP TASK LEVEL ------
	--******************************************************************************
        -- check whether the budget is by top task  if so then check the funds available
	-- at top task level
        IF p_record.bud_task_id <> 0  then

                l_stage := 400;
         -- open the cursor for packet amounts at top task level
           IF (p_record.project_id <> g_bal_tt_project_id OR g_bal_tt_project_id is NULL ) OR
              (p_record.budget_version_id <> g_bal_tt_bdgt_version_id  or g_bal_tt_bdgt_version_id is NULL ) OR
              (p_record.time_phased_type_code  <> g_bal_tt_time_phase_code  or g_bal_tt_time_phase_code is NULL ) OR
              --(p_record.entry_level_code <> g_bal_tt_entry_level_code or g_bal_tt_entry_level_code is  NULL ) OR
              (trunc(p_start_date) <> trunc(g_bal_tt_start_date) or g_bal_tt_start_date is NULL ) OR
              (trunc(p_end_date)  <> trunc(g_bal_tt_end_date )  or g_bal_tt_end_date is NULL) OR
              (p_record.top_task_id <> g_bal_tt_top_task_id  OR g_bal_tt_top_task_id is NULL ) OR
              (p_record.bud_task_id <> g_bal_tt_bud_task_id  OR g_bal_tt_bud_task_id is NULL ) THEN

                OPEN  top_task_level_bal (p_record.bud_task_id ,p_record.top_task_id );
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'opened top_task_level_bal cursor ');
		end if;
                FETCH top_task_level_bal INTO l_tt_budget_posted,
                                         l_tt_actual_posted,
                                         l_tt_enc_posted;
                CLOSE top_task_level_bal;

		If  l_tt_budget_posted = 0 then
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'l_tt_budget_posted = 0 and opend roll up cursor');
			end if;
			-- rollup the task balance and check the funds avialable
			OPEN task_rollup_bal (p_record.top_task_id );
                	FETCH task_rollup_bal  INTO l_tt_budget_posted,
                                         l_tt_actual_posted,
                                         l_tt_enc_posted;
			CLOSE task_rollup_bal;
		End if;
                -- assign the values to globals to use as cache
                g_tt_budget_posted := l_tt_budget_posted;
                g_tt_actual_posted := l_tt_actual_posted;
                g_tt_enc_posted    := l_tt_enc_posted;

                --- added for performance testing to use as one level cache
        	g_bal_tt_project_id            := p_record.project_id;
        	g_bal_tt_task_id               := p_record.task_id;
        	g_bal_tt_top_task_id           := p_record.top_task_id;
        	g_bal_tt_bdgt_version_id       := p_record.budget_version_id;
        	g_bal_tt_bud_task_id           := p_record.bud_task_id;
        	g_bal_tt_bud_rlmi              := p_record.bud_resource_list_member_id;
        	g_bal_tt_prlmi                 := p_record.parent_resource_id;
        	g_bal_tt_entry_level_code      := p_record.entry_level_code;
        	g_bal_tt_start_date            := trunc(p_start_date);
        	g_bal_tt_end_date              := trunc(p_end_date);
        	g_bal_tt_time_phase_code       := p_record.time_phased_type_code;
       		-------------- end of perfromance test ----

           ELSE
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 => 'Same combination found at top task cursor');
		end if;

                l_tt_budget_posted := g_tt_budget_posted;
                l_tt_actual_posted := g_tt_actual_posted;
                l_tt_enc_posted    := g_tt_enc_posted;
           END IF;
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>'tt_budget_posted ['||l_tt_budget_posted||
                	']tt_actual_posted ['||l_tt_actual_posted||']_tt_enc_posted ['||l_tt_enc_posted||']');
		end if;

           IF (p_record.project_id <> g_pkt_tt_project_id OR g_pkt_tt_project_id is NULL ) OR
              (p_record.budget_version_id <> g_pkt_tt_bdgt_version_id  or g_pkt_tt_bdgt_version_id is NULL ) OR
              --(p_record.time_phased_type_code  <> g_pkt_tt_time_phase_code  or g_pkt_tt_time_phase_code is NULL ) OR
              (p_record.entry_level_code <> g_pkt_tt_entry_level_code or g_pkt_tt_entry_level_code is  NULL ) OR
              (trunc(p_start_date) <> trunc(g_pkt_tt_start_date) or g_pkt_tt_start_date is NULL ) OR
              (trunc(p_end_date)  <> trunc(g_pkt_tt_end_date )  or g_pkt_tt_end_date is NULL) OR
              (p_record.top_task_id <> g_pkt_tt_top_task_id  OR g_pkt_tt_top_task_id is NULL ) THEN


                OPEN top_task_tot_bc_pkt  (p_record.top_task_id );
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'opend top_task_tot_bc_pkt cursor');
		end if;
                FETCH top_task_tot_bc_pkt INTO l_pkt_amt
                                        ,l_tt_enc_approved
                                        ,l_tt_actual_approved;
		g_tt_base_amt	  := l_pkt_amt;
		g_tt_enc_approved := l_tt_enc_approved;
		g_tt_enc_pending  := l_tt_enc_pending;
		g_tt_actual_approved := l_tt_actual_approved;
		g_tt_actual_pending  := l_tt_actual_pending;
                CLOSE top_task_tot_bc_pkt;

        	-- added for performance test
        	g_pkt_tt_project_id            := p_record.project_id;
        	g_pkt_tt_task_id               := p_record.task_id;
        	g_pkt_tt_top_task_id           := p_record.top_task_id;
        	g_pkt_tt_bdgt_version_id       := p_record.budget_version_id;
        	--g_pkt_tt_bud_task_id           := p_record.bud_task_id;
        	--g_pkt_tt_rlmi                  := p_record.resource_list_member_id;
        	--g_pkt_tt_bud_rlmi              := null;
        	g_pkt_tt_prlmi                 := p_record.Parent_resource_id;
        	g_pkt_tt_entry_level_code      := p_record.entry_level_code;
        	g_pkt_tt_start_date            := trunc(p_start_date);
        	g_pkt_tt_end_date              := trunc(p_end_date);
        	g_pkt_tt_time_phase_code       := p_record.time_phased_type_code;
        	---------end of performance test --------------

	   ELSE
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'same combination for top task pkt cursor');
		end if;
		l_pkt_amt	  := g_tt_base_amt;
                l_tt_enc_approved := g_tt_enc_approved;
                l_tt_enc_pending  := g_tt_enc_pending;
                l_tt_actual_approved := g_tt_actual_approved;
                l_tt_actual_pending  := g_tt_actual_pending;
	   END IF;  -- end of one level cache
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>'pkt_amt ['||l_pkt_amt||
                	']tt_enc_approved ['||l_tt_enc_approved||']tt_enc_pending [ '||l_tt_enc_pending||
                	']tt_actual_approved ['||l_tt_actual_approved||']tt_actual_pending ['||l_tt_actual_pending|| ']' );
		end if;

                l_available_amt := nvl(l_tt_budget_posted,0) -
                                        (nvl(l_tt_actual_posted,0) +
                                        nvl(l_tt_enc_posted,0) +
                                        nvl(l_pkt_amt,0) +
                                        nvl(l_tt_actual_approved,0) +
                                        nvl(l_tt_enc_approved,0) +
					nvl(g_tt_pkt_amt ,0)
                                        );
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'available_amt ='||l_available_amt);
		end if;
                IF  p_record.status_code||p_record.actual_flag = 'AE' then
                        l_tt_enc_approved := nvl(l_tt_enc_approved,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'tt_enc_approved ='||l_tt_enc_approved);
		end if;
                ELSIF p_record.status_code||p_record.actual_flag = 'PE' then
                        l_tt_enc_pending := nvl(l_tt_enc_pending,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'tt_enc_pending = '||l_tt_enc_pending);
		end if;

                ELSIF p_record.status_code||p_record.actual_flag = 'AA' then
                        l_tt_actual_approved := nvl(l_tt_actual_approved,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'tt_actual_approved ='||l_tt_actual_approved);
			end if;

                ELSIF p_record.status_code||p_record.actual_flag = 'PA' then
                        l_tt_actual_pending := nvl(l_tt_actual_pending,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'tt_actual_pending ='||l_tt_actual_pending);
			end if;

                END IF;
                l_tt_budget_bal := l_available_amt;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'calling generate_result_code at tt level ');
		end if;
                        generate_result_code(
                        p_fclevel_code         => p_record.tt_funds_control_level_code,
                        p_available_amt        => l_available_amt,
                        p_stage                => l_stage,
                        p_budget_posted_amt    => l_tt_budget_posted,
                        x_result_code          => l_result_code,
                        x_r_result_code        => l_r_result_code,
                        x_rg_result_code       => l_rg_result_code,
                        x_t_result_code        => l_t_result_code,
                        x_tt_result_code       => l_tt_result_code,
                        x_p_result_code        => l_p_result_code,
                        x_p_acct_result_code   => l_p_acct_result_code,
                        x_return_status        => l_return_status
                                ) ;
			IF g_debug_mode = 'Y' THEN
                        log_message(p_msg_token1 =>'l_tt_result_code = '||l_tt_result_code||
                                                   'l_result_code ='||l_result_code);
			end if;

                IF l_return_status  = 'F' THEN
                        GOTO END_PROCESS;
                ELSE
                        -- PROCEED TO NEXT STAGE ie  PROJECT LEVEL
                        NULL;
                END IF;
	END IF ;  -- end if for top task level
	--*******************************************************************************
				-- FUNDS CHECK AT PROJECT LEVEL --------
	--******************************************************************************
		l_stage := 500;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'stage = 500');
		end if;

           IF (p_record.project_id <> g_bal_p_project_id OR g_bal_p_project_id is NULL ) OR
              (p_record.budget_version_id <> g_bal_p_bdgt_version_id  or g_bal_p_bdgt_version_id is NULL ) OR
              (p_record.time_phased_type_code  <> g_bal_p_time_phase_code  or g_bal_p_time_phase_code is NULL ) OR
              --(p_record.entry_level_code <> g_bal_p_entry_level_code or g_bal_p_entry_level_code is  NULL ) OR
              (trunc(p_start_date) <> trunc(g_bal_p_start_date) or g_bal_p_start_date is NULL ) OR
              (trunc(p_end_date)  <> trunc(g_bal_p_end_date )  or g_bal_p_end_date is NULL) THEN

		OPEN project_level_bal;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'opened project level bal cursor ');
		end if;
                FETCH project_level_bal INTO l_p_budget_posted,
                                         l_p_actual_posted,
                                         l_p_enc_posted;

		g_p_budget_posted  := l_p_budget_posted;
		g_p_actual_posted  := l_p_actual_posted;
		g_p_enc_posted     := l_p_enc_posted;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'p_budget_posted ['||l_p_budget_posted||
			']p_actual_posted ['||l_p_actual_posted||']p_enc_posted ['||l_p_enc_posted||']' );
		end if;

                CLOSE project_level_bal;

                --- added for performance testing
        	g_bal_p_project_id            := p_record.project_id;
        	g_bal_p_task_id               := p_record.task_id;
        	g_bal_p_top_task_id           := p_record.top_task_id;
        	g_bal_p_bdgt_version_id       := p_record.budget_version_id;
        	g_bal_p_bud_task_id           := p_record.bud_task_id;
        	g_bal_p_bud_rlmi              := p_record.bud_resource_list_member_id;
        	g_bal_p_prlmi                 := p_record.parent_resource_id;
        	g_bal_p_entry_level_code      := p_record.entry_level_code;
        	g_bal_p_start_date            := trunc(p_start_date);
        	g_bal_p_end_date              := trunc(p_end_date);
        	g_bal_p_time_phase_code       := p_record.time_phased_type_code;
       		-------------- end of perfromance test ----

	   ELSE
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'Same combination for project cur ');
		end if;
                l_p_budget_posted  := g_p_budget_posted;
                l_p_actual_posted  := g_p_actual_posted;
                l_p_enc_posted     := g_p_enc_posted;
	   END IF;
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 =>'p_budget_posted ['||l_p_budget_posted||
                	']p_actual_posted ['||l_p_actual_posted||']p_enc_posted ['||l_p_enc_posted||']' );
		end if;

           IF (p_record.project_id <> g_pkt_p_project_id OR g_pkt_p_project_id is NULL ) OR
              (p_record.budget_version_id <> g_pkt_p_bdgt_version_id  or g_pkt_p_bdgt_version_id is NULL ) OR
              --(p_record.time_phased_type_code  <> g_pkt_p_time_phase_code  or g_pkt_p_time_phase_code is NULL ) OR
              (p_record.entry_level_code <> g_pkt_p_entry_level_code or g_pkt_p_entry_level_code is  NULL ) OR
              (trunc(p_start_date) <> trunc(g_pkt_p_start_date) or g_pkt_p_start_date is NULL ) OR
              (trunc(p_end_date)  <> trunc(g_pkt_p_end_date )  or g_pkt_p_end_date is NULL) THEN

                OPEN project_tot_bc_pkt  ;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'opened project_tot_bc_pkt cursor ');
		end if;
                FETCH project_tot_bc_pkt INTO l_pkt_amt
                                        ,l_p_enc_approved
                                        ,l_p_actual_approved ;
		g_p_base_amt	   := l_pkt_amt;
		g_p_enc_approved   := l_p_enc_approved;
		g_p_enc_pending    := l_p_enc_pending;
		g_p_actual_approved:= l_p_actual_approved;
		g_p_actual_pending  := l_p_actual_pending;

                CLOSE project_tot_bc_pkt;

        	-- added for performance test
        	g_pkt_p_project_id            := p_record.project_id;
        	g_pkt_p_bdgt_version_id       := p_record.budget_version_id;
        	g_pkt_p_entry_level_code      := p_record.entry_level_code;
        	g_pkt_p_start_date            := trunc(p_start_date);
        	g_pkt_p_end_date              := trunc(p_end_date);
        	g_pkt_p_time_phase_code       := p_record.time_phased_type_code;
        	-------end of performance test --------------

	    ELSE
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'Same combination for project acct cursor');
		end if;
		l_pkt_amt	   := g_p_base_amt;
                l_p_enc_approved   := g_p_enc_approved;
                l_p_enc_pending    := g_p_enc_pending;
                l_p_actual_approved:= g_p_actual_approved;
                l_p_actual_pending  := g_p_actual_pending;

	    END IF;
		IF g_debug_mode = 'Y' THEN
                log_message(p_msg_token1 =>'pkt_amt ['||l_pkt_amt||']p_enc_approved ='||l_p_enc_approved||
		']p_enc_pending = '||l_p_enc_pending||']p_actual_approved ='||l_p_actual_approved||
		']p_actual_pending ='||l_p_actual_pending||']' );
		end if;

                l_available_amt := nvl(l_p_budget_posted,0) -
                                        (nvl(l_p_actual_posted,0) +
                                        nvl(l_p_enc_posted ,0)+
                                        nvl(l_pkt_amt,0) +
                                        nvl(l_p_actual_approved,0) +
                                        nvl(l_p_enc_approved,0) +
					nvl(g_p_pkt_amt ,0)
                                        );
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'available_amt ='||l_available_amt);
		end if;
                IF  p_record.status_code||p_record.actual_flag = 'AE' then
                        l_p_enc_approved := nvl(l_p_enc_approved,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'p_enc_approved ='||l_p_enc_approved);
			end if;
                ELSIF p_record.status_code||p_record.actual_flag = 'PE' then
                        l_p_enc_pending := nvl(l_p_enc_pending,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'p_enc_pending = '||l_p_enc_pending);
			end if;

                ELSIF p_record.status_code||p_record.actual_flag = 'AA' then
                        l_p_actual_approved := nvl(l_p_actual_approved,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
			IF g_debug_mode = 'Y' THEN
		 		log_message(p_msg_token1 =>'p_actual_approved ='||l_p_actual_approved);
			end if;

                ELSIF p_record.status_code||p_record.actual_flag = 'PA' then
                        l_p_actual_pending := nvl(l_p_actual_pending,0) +
                                                p_record.accounted_dr
                                                - p_record.accounted_cr;
			IF g_debug_mode = 'Y' THEN
		 		log_message(p_msg_token1 =>'p_actual_pending ='||l_p_actual_pending);
			end if;

                END IF;
                l_p_budget_bal := l_available_amt;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'calling generate_result_code at p level ');
			end if;
                        generate_result_code(
                        p_fclevel_code         => p_record.p_funds_control_level_code,
                        p_available_amt        => l_available_amt,
                        p_stage                => l_stage,
                        p_budget_posted_amt    => l_p_budget_posted,
                        x_result_code          => l_result_code,
                        x_r_result_code        => l_r_result_code,
                        x_rg_result_code       => l_rg_result_code,
                        x_t_result_code        => l_t_result_code,
                        x_tt_result_code       => l_tt_result_code,
                        x_p_result_code        => l_p_result_code,
                        x_p_acct_result_code   => l_p_acct_result_code,
                        x_return_status        => l_return_status
                                ) ;
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 =>'l_p_result_code = '||l_p_result_code||
                                                   'l_result_code ='||l_result_code);
                		log_message(p_msg_token1 =>'end of generate_result_code api ');
			end if;

                IF l_return_status  = 'F' THEN
                        GOTO END_PROCESS;
                ELSE
                        -- PROCEED TO NEXT STAGE ie  PROJECT ACCOUNT LEVEL BAL
                        NULL;
                END IF;
	--***************************************************************************
		-- FUNDS CHECK AT PROJECT ACCOUNT LEVEL BALANCE--
	--*************************************************************************

     -- R12 change: Account level funds check should not be carried out here for re-baseline
     IF P_MODE NOT IN ('S','B') THEN

	-- if the budget linked with Standard GL / External Budget then
	-- check the funds avaiable at account level for each transaction
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'funds check at project account level');
	End if;
	IF p_ext_bdgt_link  =  'Y' then
		l_stage := 600;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'Stage 600 calling Get_Acct_Line_Balance api'||
			'in parameters are budget_version_id ['||p_record.budget_version_id||
			']p_start_date ['||p_start_date||']p_end_date ['||p_end_date||
			']budget_ccid [ '||p_record.budget_ccid||']' );
		End if;

		l_acct_level_bal := pa_funds_control_utils.Get_Acct_Line_Balance(
            			p_budget_version_id  => p_record.budget_version_id,
            			p_start_date  => p_start_date,
            			p_end_date  => p_end_date,
            			p_budget_ccid => p_record.budget_ccid);
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'acct_level_bal ='||l_acct_level_bal);
		end if;

           IF (p_record.project_id <> g_pkt_p_acct_project_id OR g_pkt_p_acct_project_id is NULL ) OR
              (p_record.budget_version_id <> g_pkt_p_acct_bdgt_version_id  or g_pkt_p_acct_bdgt_version_id is NULL ) OR
              (p_record.budget_ccid  <> g_pkt_p_acct_bdgt_ccid or g_pkt_p_acct_bdgt_ccid is NULL ) OR
              (trunc(p_start_date) <> trunc(g_pkt_p_acct_start_date) or g_pkt_p_acct_start_date is NULL ) OR
              (trunc(p_end_date)  <> trunc(g_pkt_p_acct_end_date )  or g_pkt_p_acct_end_date is NULL) THEN

		--r_msg('NEW PROJECT ACCT FOR PKT');
		OPEN project_acct_tot_bc_pkt(p_record.budget_ccid);
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'opened project_acct_tot_bc_pkt cursor ');
		end if;
		FETCH project_acct_tot_bc_pkt INTO l_pkt_amt,
						   l_p_acct_enc_approved,
						   l_p_acct_actual_approved;

		g_p_acct_base_amt	:= l_pkt_amt;
		g_p_acct_enc_approved 	:= l_p_acct_enc_approved;
		g_p_acct_actual_approved := l_p_acct_actual_approved;
		CLOSE project_acct_tot_bc_pkt;

        	-- added for performance test
        	g_pkt_p_acct_project_id            := p_record.project_id;
        	g_pkt_p_acct_bdgt_version_id       := p_record.budget_version_id;
        	g_pkt_p_acct_bdgt_ccid             := p_record.budget_ccid;
        	g_pkt_p_acct_start_date            := trunc(p_start_date);
        	g_pkt_p_acct_end_date              := trunc(p_end_date);
        	g_pkt_p_acct_time_phase_code       := p_record.time_phased_type_code;
        	-----end of performance test --------------

	   ELSE
		l_pkt_amt 		:= g_p_acct_base_amt;
		l_p_acct_enc_approved	:= g_p_acct_enc_approved;
		l_p_acct_actual_approved:= g_p_acct_actual_approved;

	   END IF;
	   IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 =>'l_p_acct_enc_approved ['||l_p_acct_enc_approved||
		']l_p_acct_actual_approved ['||l_p_acct_actual_approved||
		']l_p_acct_pkt_amt ['||l_pkt_amt||']g_p_acct_pkt_amt ['||g_p_acct_pkt_amt||']' );
	   End if;

		l_available_amt := nvl(l_acct_level_bal,0) -
					(  --nvl(l_p_acct_enc_approved,0) +
					-- nvl(l_p_acct_actual_approved,0) +
					nvl(l_pkt_amt,0) +
					nvl(g_p_acct_pkt_amt,0)
					);
		IF g_debug_mode = 'Y' THEN
		   log_message(p_msg_token1 => 'available_amt ['||l_available_amt||']' );
		end if;
                        generate_result_code(
                        p_fclevel_code         => p_record.p_funds_control_level_code,
                        p_available_amt        => l_available_amt,
                        p_stage                => l_stage,
                        p_budget_posted_amt    => l_acct_level_bal,
                        x_result_code          => l_result_code,
                        x_r_result_code        => l_r_result_code,
                        x_rg_result_code       => l_rg_result_code,
                        x_t_result_code        => l_t_result_code,
                        x_tt_result_code       => l_tt_result_code,
                        x_p_result_code        => l_p_result_code,
                        x_p_acct_result_code   => l_p_acct_result_code,
                        x_return_status        => l_return_status
                                ) ;
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 =>'End of generate result l_p_acct_result_code = '||
					l_p_acct_result_code||']l_result_code ['||l_result_code||']');
			End if;

	END IF; -- external link check

     END IF; --IF P_MODE NOT IN ('S','B') THEN

	--Store the local values in global variables  to use as one level cache
	g_project_id  		:= p_record.project_id;
	g_top_task_id		:= p_record.top_task_id;
	g_task_id		:= p_record.task_id;
	g_bdgt_version_id	:= p_record.budget_version_id;
	g_bud_task_id		:= p_record.bud_task_id;
	g_rlmi                  := p_record.resource_list_member_id;
	g_bud_rlmi		:= p_record.bud_resource_list_member_id;
	g_prlmi			:= p_record.parent_resource_id;
	g_entry_level_code	:= p_record.entry_level_code;
	g_start_date		:= p_start_date;
	g_end_date		:= p_end_date;
	g_time_phase_code	:= p_record.time_phased_type_code;
	g_bdgt_ccid		:= p_record.budget_ccid;



	<<END_PROCESS>>
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'End of process assiging out NOCOPY parameters with funds checked results');
	end if;
	-- Assign all out NOCOPY parameters with funds checked results
        p_record.r_budget_posted                   := l_r_budget_posted ;
        p_record.rg_budget_posted                  := l_rg_budget_posted;
        p_record.t_budget_posted                   := l_t_budget_posted;
        p_record.tt_budget_posted                  := l_tt_budget_posted ;
        p_record.p_budget_posted                   := l_p_budget_posted;
        p_record.r_actual_posted                   := l_r_actual_posted;
        p_record.rg_actual_posted                  := l_rg_actual_posted;
        p_record.t_actual_posted                   := l_t_actual_posted;
        p_record.tt_actual_posted                  := l_tt_actual_posted;
        p_record.p_actual_posted                   := l_p_actual_posted;
        p_record.r_enc_posted                      := l_r_enc_posted;
        p_record.rg_enc_posted                     := l_rg_enc_posted ;
        p_record.t_enc_posted                      := l_t_enc_posted ;
        p_record.tt_enc_posted                     := l_tt_enc_posted ;
        p_record.p_enc_posted                      := l_p_enc_posted;
        p_record.r_budget_bal                      := l_r_budget_bal;
        p_record.rg_budget_bal                     := l_rg_budget_bal ;
        p_record.t_budget_bal                      := l_t_budget_bal;
        p_record.tt_budget_bal                     := l_tt_budget_bal;
        p_record.p_budget_bal                      := l_p_budget_bal;
        p_record.r_actual_approved                 := l_r_actual_approved;
        p_record.rg_actual_approved                := l_rg_actual_approved;
        p_record.t_actual_approved                 := l_t_actual_approved ;
        p_record.tt_actual_approved                := l_tt_actual_approved;
        p_record.p_actual_approved                 := l_p_actual_approved ;
        p_record.r_enc_approved                    := l_r_enc_approved;
        p_record.rg_enc_approved                   := l_rg_enc_approved;
        p_record.t_enc_approved                    := l_t_enc_approved ;
        p_record.tt_enc_approved                   := l_tt_enc_approved;
        p_record.p_enc_approved                    := l_p_enc_approved;
        p_record.result_code                       := l_result_code;
        p_record.r_result_code                     := l_r_result_code;
        p_record.rg_result_code                    := l_rg_result_code;
        p_record.t_result_code                     := l_t_result_code;
        p_record.tt_result_code                    := l_tt_result_code;
        p_record.p_result_code                     := l_p_result_code;
        p_record.p_acct_result_code                := l_p_acct_result_code;

        g_pre_project_id            := p_record.project_id;
        g_pre_top_task_id           := p_record.top_task_id;
        g_pre_task_id               := p_record.task_id;
        g_pre_bdgt_version_id       := p_record.budget_version_id;
        g_pre_bud_task_id           := p_record.bud_task_id;
        g_pre_rlmi                  := p_record.resource_list_member_id;
        g_pre_bud_rlmi              := p_record.bud_resource_list_member_id;
        g_pre_prlmi                 := p_record.parent_resource_id;
        g_pre_entry_level_code      := p_record.entry_level_code;
        g_pre_start_date            := p_start_date;
        g_pre_end_date              := p_end_date;
        g_pre_time_phase_code       := p_record.time_phased_type_code;
	g_pre_bdgt_ccid		    := p_record.budget_ccid;
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'end of assignments sub string l_result_code ['||l_result_code||']' );
	end if;

	IF substr(l_result_code,1,1) = 'F' and l_cached_satus = 'Y' then
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'calling cache pkt amounts to minus');
		end if;
        	-- deduct this amount from the cache
        	CACHE_PKT_AMOUNTS(
                p_project_id    =>      p_record.project_id
                ,p_bdgt_version =>      p_record.budget_version_id
                ,p_top_task_id  =>      p_record.top_task_id
                ,p_task_id      =>      p_record.task_id
                ,p_bud_task_id  =>      p_record.bud_task_id
                ,p_start_date   =>      p_start_date
                ,p_end_date     =>      p_end_date
                ,p_rlmi         =>      p_record.resource_list_member_id
                ,p_bud_rlmi     =>      p_record.bud_resource_list_member_id
                ,p_prlmi        =>      p_record.parent_resource_id
                ,p_bdgt_ccid    =>      p_record.budget_ccid
                ,p_accounted_dr =>      p_record.accounted_dr
                ,p_accounted_cr =>      p_record.accounted_cr
                ,p_calling_module =>    p_calling_module
                ,p_partial_flag   =>    p_partial_flag
                ,p_function     =>      'MINUS'
                ,p_bc_packet_id =>      p_record.bc_packet_id
                ,p_doc_type      =>     p_record.document_type
                ,p_doc_header_id =>     p_record.document_header_id
                ,p_doc_distribution_id =>p_record.document_distribution_id
                ,x_result_code   =>     l_result_code
                ,x_cached_status =>     l_cached_satus
                ,p_counter       =>     p_counter
                );
	END IF;


	IF res_level_bal%ISOPEN  then
		CLOSE res_level_bal;
	END IF;

	IF res_tot_bc_pkt%ISOPEN  then
		CLOSE res_tot_bc_pkt;
	END IF;

	IF res_grp_level_bal%ISOPEN THEN
		CLOSE res_grp_level_bal;
	END IF;

	IF res_rollup_bal%ISOPEN THEN
		CLOSE res_rollup_bal;
	END IF;
	IF res_grp_tot_bc_pkt%ISOPEN THEN
		CLOSE res_grp_tot_bc_pkt;
	END IF;
	IF task_level_bal%ISOPEN THEN
		CLOSE task_level_bal;
	END IF;
	IF task_tot_bc_pkt%ISOPEN THEN
		CLOSE task_tot_bc_pkt;
	END IF;
	IF top_task_level_bal%ISOPEN THEN
		CLOSE top_task_level_bal;
	END IF;
	IF task_rollup_bal%ISOPEN THEN
		CLOSE task_rollup_bal;
	END IF;
	IF top_task_tot_bc_pkt%ISOPEN THEN
		CLOSE top_task_tot_bc_pkt;
	END IF;
	IF project_level_bal%ISOPEN THEN
		CLOSE project_level_bal;
	END IF;
	IF project_tot_bc_pkt%ISOPEN THEN
		CLOSE project_tot_bc_pkt;
	END IF;
	IF project_acct_tot_bc_pkt%ISOPEN THEN
		CLOSE project_acct_tot_bc_pkt;
	END IF;
	RETURN;

EXCEPTION
	WHEN OTHERS THEN
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'funds check failed due to unexpected error');
	end if;
        IF res_level_bal%ISOPEN  then
                CLOSE res_level_bal;
        END IF;

        IF res_tot_bc_pkt%ISOPEN  then
                CLOSE res_tot_bc_pkt;
        END IF;

        IF res_grp_level_bal%ISOPEN THEN
                CLOSE res_grp_level_bal;
        END IF;

        IF res_rollup_bal%ISOPEN THEN
                CLOSE res_rollup_bal;
        END IF;
        IF res_grp_tot_bc_pkt%ISOPEN THEN
                CLOSE res_grp_tot_bc_pkt;
        END IF;
        IF task_level_bal%ISOPEN THEN
                CLOSE task_level_bal;
        END IF;
        IF task_tot_bc_pkt%ISOPEN THEN
                CLOSE task_tot_bc_pkt;
        END IF;
        IF top_task_level_bal%ISOPEN THEN
                CLOSE top_task_level_bal;
        END IF;
        IF task_rollup_bal%ISOPEN THEN
                CLOSE task_rollup_bal;
        END IF;
        IF top_task_tot_bc_pkt%ISOPEN THEN
                CLOSE top_task_tot_bc_pkt;
        END IF;
        IF project_level_bal%ISOPEN THEN
                CLOSE project_level_bal;
        END IF;
        IF project_tot_bc_pkt%ISOPEN THEN
                CLOSE project_tot_bc_pkt;
        END IF;
        IF project_acct_tot_bc_pkt%ISOPEN THEN
                CLOSE project_acct_tot_bc_pkt;
        END IF;
		IF g_debug_mode = 'Y' THEN
		   log_message(p_msg_token1 => 'Exception in check_eunds_available SQLERR :'||sqlcode||sqlerrm);
		end if;
                --commit;
		Raise;
END check_funds_available ;
---------------------------------------------------------------------------------
-- This Api updates the pa_bc_packets with fundscheck amounts and result code
-- after doing the fundscheck this api is in autonomous transaction
---------------------------------------------------------------------------------
PROCEDURE update_pkt_amts(p_packet_id  IN number) IS
	        PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'before update of pa bc packets ');
	End if;
        FORALL i IN g_tab_rowid.FIRST .. g_tab_rowid.LAST
           UPDATE pa_bc_packets
           SET     result_code = nvl(g_tab_result_code(i),result_code),
                   res_result_code =nvl( g_tab_r_result_code(i),res_result_code),
                   res_grp_result_code = nvl(g_tab_rg_result_code(i),res_grp_result_code),
                   task_result_code   = nvl(g_tab_t_result_code(i),task_result_code),
                   top_task_result_code = nvl(g_tab_tt_result_code(i),top_task_result_code),
                   project_result_code  = nvl(g_tab_p_result_code(i),project_result_code),
                   project_acct_result_code = nvl(g_tab_p_acct_result_code(i),project_acct_result_code),
                   status_code          = decode(nvl(g_tab_status_code(i),status_code),'Z','P',
							nvl(g_tab_status_code(i),status_code)),
                   res_budget_posted =nvl( g_tab_r_budget_posted(i),res_budget_posted),
                   res_grp_budget_posted = nvl(g_tab_rg_budget_posted(i),res_grp_budget_posted),
                   task_budget_posted = nvl(g_tab_t_budget_posted(i),task_budget_posted),
                   top_task_budget_posted = nvl(g_tab_tt_budget_posted(i),top_task_budget_posted),
                   project_budget_posted = nvl(g_tab_p_budget_posted(i),project_budget_posted),
                   res_actual_posted  = nvl(g_tab_r_actual_posted(i),res_actual_posted ),
                   res_grp_actual_posted = nvl(g_tab_rg_actual_posted(i),res_grp_actual_posted),
                   task_actual_posted   = nvl(g_tab_t_actual_posted(i),task_actual_posted),
                   top_task_actual_posted = nvl(g_tab_tt_actual_posted(i),top_task_actual_posted),
                   project_actual_posted  = nvl(g_tab_p_actual_posted(i),project_actual_posted),
                   res_enc_posted      = nvl(g_tab_r_enc_posted(i),res_enc_posted),
                   res_grp_enc_posted  = nvl(g_tab_rg_enc_posted(i),res_grp_enc_posted),
                   task_enc_posted     = nvl(g_tab_t_enc_posted(i),task_enc_posted ),
                   top_task_enc_posted = nvl(g_tab_tt_enc_posted(i),top_task_enc_posted),
                   project_enc_posted  = nvl(g_tab_p_enc_posted(i),project_enc_posted),
                   res_budget_bal      = nvl(g_tab_r_budget_bal(i),res_budget_bal),
                   res_grp_budget_bal  = nvl(g_tab_rg_budget_bal(i),res_grp_budget_bal),
                   task_budget_bal     = nvl(g_tab_t_budget_bal(i),task_budget_bal),
                   top_task_budget_bal = nvl(g_tab_tt_budget_bal(i),top_task_budget_bal),
                   project_budget_bal  = nvl(g_tab_p_budget_bal(i),project_budget_bal),
                   res_actual_approved = nvl(g_tab_r_actual_approved(i),res_actual_approved),
                   res_grp_actual_approved = nvl(g_tab_rg_actual_approved(i),res_grp_actual_approved),
                   task_actual_approved =nvl( g_tab_t_actual_approved(i),task_actual_approved),
                   top_task_actual_approved  = nvl(g_tab_tt_actual_approved(i),top_task_actual_approved),
                   project_actual_approved   = nvl(g_tab_p_actual_approved(i),project_actual_approved),
                   res_enc_approved          = nvl(g_tab_r_enc_approved(i),res_enc_approved),
                   res_grp_enc_approved      = nvl(g_tab_rg_enc_approved(i),res_grp_enc_approved),
                   task_enc_approved         = nvl(g_tab_t_enc_approved(i),task_enc_approved),
                   top_task_enc_approved     = nvl(g_tab_tt_enc_approved(i),top_task_enc_approved),
                   project_enc_approved      = nvl(g_tab_p_enc_approved(i),project_enc_approved)
            WHERE packet_id = p_packet_id
            AND   rowid = g_tab_rowid(i);
	    IF g_debug_mode = 'Y' THEN
            	log_message(p_msg_token1 => 'End of FORALL update statement');
	    End If;

            commit;
       	    return;

EXCEPTION
	when others then
		raise;
END update_pkt_amts;
/** This api updates the Encumbrance approved bal for the packets
 *  which contains transaction PO,AP,CC_P_PAY,CC_C_PAY
 *  This API is primarily intended to update the encumbrance_approved_bal
 *  to display in the funds check view form refer to Bug:2021199
 **/
PROCEDURE update_enc_approvl_bal(p_packet_id       IN  pa_bc_packets.packet_id%type
                                ,p_mode            IN   varchar2
                                ,p_calling_module  IN   varchar2
				) IS
	PRAGMA AUTONOMOUS_TRANSACTION;

	/* Bug fix: 2658952  Transaction funds chekc screen not showing proper balances
         * If the inner sub query in update statement returns no rows then all the
         * enc approved columns are updated to zero
         * So moving the subquery into cursor and updating the bc_packets enc_approved
         * columns in a loop
         */

        /** Bug fix : if Invoice has Tax lines then api fails with sql error
         ** ORA-01427: single-row subquery returns more than one row to avoid this
         ** sum() function has been used. For proper fix we need to add few columns to
         ** pa_bc_packets and pa_bc_commitments to distiguish the lines as ITEM / TAX
         ** the fix required here to add one more condition a.line_type = b.line_type
         **/

	 CURSOR updEnc(p_bc_pkt_id  Number
                       ,p_res_enc_approved Number
		       ,p_res_grp_enc_approved Number
		       ,p_task_enc_approved Number
		       ,p_top_task_enc_approved Number
		       ,p_project_enc_approved Number
		       ) IS
		select decode(nvl(p_res_enc_approved,0),0,0,p_res_enc_approved -
                              sum(nvl(nvl(a.accounted_dr,0) - nvl(a.accounted_cr,0),0))),
                   decode(nvl(p_res_grp_enc_approved,0),0,0,p_res_grp_enc_approved -
                              sum(nvl(nvl(a.accounted_dr,0) - nvl(a.accounted_cr,0),0))),
                   decode(nvl(p_task_enc_approved,0),0,0,p_task_enc_approved -
                              sum(nvl(nvl(a.accounted_dr,0) - nvl(a.accounted_cr,0),0))),
                   decode(nvl(p_top_task_enc_approved,0),0,0,p_top_task_enc_approved -
                              sum(nvl(nvl(a.accounted_dr,0) - nvl(a.accounted_cr,0),0))),
                   decode(nvl(p_project_enc_approved,0),0,0,p_project_enc_approved -
                              sum(nvl(nvl(a.accounted_dr,0) - nvl(a.accounted_cr,0),0)))
                from pa_bc_packets  a
                        ,pa_bc_packets b
                where
                    a.packet_id = p_packet_id
                and a.bc_packet_id = p_bc_pkt_id
                and a.packet_id = b.packet_id
                and b.result_code like 'P%'
                and abs((nvl(a.accounted_dr,0) - nvl(a.accounted_cr,0))) -
                abs((nvl(b.accounted_dr,0)-nvl(b.accounted_cr,0))) < .1
                and ( (a.parent_bc_packet_id is null and b.parent_bc_packet_id is null)
                        or (a.parent_bc_packet_id is not null and b.parent_bc_packet_id is not null)
                        )
                and ((( a.document_type = 'PO' and b.document_type = 'REQ')
                        and exists ( select  'Y'
                                        from po_distributions_all po
                                        ,po_req_distributions_all req
                                        where req.distribution_id = b.document_distribution_id
                                        and   po.po_distribution_id = a.document_distribution_id
                                        and   po.req_distribution_id = req.distribution_id
                                        and   a.packet_id = b.packet_id
                                        and   a.bc_packet_id = p_bc_pkt_id
                                        and   b.packet_id = p_packet_id
                                        )
                        )
                        OR (( a.document_type = 'AP' and b.document_type = 'PO' )
                                and exists ( select  'Y'
                                        from po_distributions_all po
                                                ,ap_invoice_distributions_all ap
                                        where po.po_distribution_id = b.document_distribution_id
                                        and   ap.invoice_id  = a.document_header_id
                                        and   ap.distribution_line_number = a.document_distribution_id
                                        and   ap.po_distribution_id = po.po_distribution_id
                                        and   a.packet_id = b.packet_id
                                        and   a.bc_packet_id = p_bc_pkt_id
                                        and   b.packet_id = p_packet_id
                                        )
                           )
                        OR (( a.document_type = 'AP' and b.document_type in ( 'CC_P_PAY','CC_C_PAY' ))
                                and exists ( select  'Y'
                                        from po_distributions_all po
                                                ,ap_invoice_distributions_all ap
                                        where po.po_distribution_id = ap.po_distribution_id
                                        and   ap.invoice_id  = a.document_header_id
                                        and   ap.distribution_line_number = a.document_distribution_id
                                        and   po.req_header_reference_num = b.document_header_id
                                        and   po.req_line_reference_num = b.document_distribution_id
                                        and   a.packet_id = b.packet_id
                                        and   a.bc_packet_id = p_bc_pkt_id
                                        and   b.packet_id = p_packet_id
                                        )
                                )
                        OR (( a.document_type = 'EXP' and b.document_type = 'AP' )
                                and (abs(nvl(a.accounted_dr,0) - nvl(a.accounted_cr,0)) =
                                abs(nvl(b.accounted_dr,0) - nvl(b.accounted_cr,0)))
                                and exists (select  'Y'
                                        from ap_invoice_distributions_all ap
                                                ,pa_bc_packets  pbc
                                        where ap.invoice_id  = b.document_header_id
                                        and   ap.distribution_line_number = b.document_distribution_id
                                        /** and   pbc.packet_id = 4003 commented out NOCOPY the hardcoded **/
                                        and   pbc.packet_id =  p_packet_id
                                        and   pbc.document_distribution_id = a.document_distribution_id
                                        and   pbc.document_header_id  = a.document_header_id
                                        and   pbc.document_type = 'EXP'
                                        and   pbc.result_code like 'P%'
                                        and   a.packet_id = b.packet_id
                                        and   a.bc_packet_id = p_bc_pkt_id
                                        and   b.packet_id = p_packet_id
                                        )
                                )
                        );


		CURSOR selEncDetails IS
		SELECT pkts.bc_packet_id,
			pkts.res_enc_approved,
                	pkts.res_grp_enc_approved,
                	pkts.task_enc_approved,
                	pkts.top_task_enc_approved,
                	pkts.project_enc_approved
		FROM pa_bc_packets pkts
                WHERE pkts.packet_id = p_packet_id
                AND   nvl(pkts.accounted_dr,0) - nvl(pkts.accounted_cr,0) > 0
                AND   substr(pkts.result_code ,1,1) = 'P';

		l_num_rows  Number := 200;
                l_r_enc_approved Number := Null;
                l_rg_enc_approved Number := Null;
                l_t_enc_approved  Number := Null;
                l_tt_enc_approved Number := Null;
                l_p_enc_approved  Number := Null;


BEGIN

      IF p_calling_module in ('GL','CBC') and p_mode in ('R','U','C') then
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'Inside update_enc_apprvoled_bal api');
	End If;

        OPEN  selEncDetails;
	IF g_debug_mode = 'Y' THEN
        	log_message(p_msg_token1 => 'opened the selEncDetails cursor');
	End If;
        LOOP

                init_plsql_tabs;

                FETCH selEncDetails BULK COLLECT INTO
                        g_tab_bc_packet_id,
                        g_tab_r_enc_approved,
                        g_tab_rg_enc_approved,
                        g_tab_t_enc_approved,
                        g_tab_tt_enc_approved,
                        g_tab_p_enc_approved  LIMIT l_num_rows;

                IF NOT g_tab_bc_packet_id.EXISTS(1) then
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'Fetch rows is zero ');
			End if;
                        EXIT;
                END IF;

                FOR  i IN g_tab_bc_packet_id.FIRST .. g_tab_bc_packet_id.LAST LOOP

                	l_r_enc_approved := Null;
                	l_rg_enc_approved := Null;
                	l_t_enc_approved  := Null;
                	l_tt_enc_approved := Null;
                	l_p_enc_approved := Null;

		    IF ( nvl(g_tab_r_enc_approved(i),0) <> 0 OR
			nvl(g_tab_rg_enc_approved(i),0) <> 0 OR
			nvl(g_tab_t_enc_approved(i),0) <> 0 OR
			nvl(g_tab_tt_enc_approved(i),0) <> 0 OR
			nvl(g_tab_p_enc_approved(i),0) <> 0 ) THEN

		        OPEN updEnc(g_tab_bc_packet_id(i)
				    ,g_tab_r_enc_approved(i)
				    ,g_tab_rg_enc_approved(i)
				    ,g_tab_t_enc_approved(i)
				    ,g_tab_tt_enc_approved(i)
				    ,g_tab_p_enc_approved(i));

			FETCH updEnc INTO l_r_enc_approved
                        	,l_rg_enc_approved
                        	,l_t_enc_approved
                        	,l_tt_enc_approved
                        	,l_p_enc_approved ;

			CLOSE updEnc;

			If nvl(l_r_enc_approved,0) <> 0 Then
                        	g_tab_r_enc_approved(i) := l_r_enc_approved;
			End If;
			If nvl(l_rg_enc_approved,0) <> 0 Then
                        	g_tab_rg_enc_approved(i) := l_rg_enc_approved;
			End If;
			If nvl(l_t_enc_approved,0) <> 0 Then
                        	g_tab_t_enc_approved(i) := l_t_enc_approved;
			End If;
			If nvl(l_tt_enc_approved,0) <> 0 Then
                        	g_tab_tt_enc_approved(i) := l_tt_enc_approved ;
			End If;
			If nvl(l_p_enc_approved,0) <> 0  Then
                        	g_tab_p_enc_approved(i) := l_p_enc_approved;
			End If;

		   END If;

                END LOOP;

		FORALL i IN g_tab_bc_packet_id.FIRST .. g_tab_bc_packet_id.LAST
		UPDATE pa_bc_packets
		SET
                   res_enc_approved          = nvl(g_tab_r_enc_approved(i),res_enc_approved),
                   res_grp_enc_approved      = nvl(g_tab_rg_enc_approved(i),res_grp_enc_approved),
                   task_enc_approved         = nvl(g_tab_t_enc_approved(i),task_enc_approved),
                   top_task_enc_approved     = nvl(g_tab_tt_enc_approved(i),top_task_enc_approved),
                   project_enc_approved      = nvl(g_tab_p_enc_approved(i),project_enc_approved)
            	WHERE packet_id = p_packet_id
            	AND   bc_packet_id = g_tab_bc_packet_id(i);

                EXIT WHEN selEncDetails%NOTFOUND;

        END LOOP;
        CLOSE selEncDetails;

      END If;
      IF g_debug_mode = 'Y' THEN
      	log_message(p_msg_token1 =>'End of update_enc_approved_bal api');
      End if;

      COMMIT;  -- to end an active autonomous transaction

EXCEPTION

	when others then
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'Failed in update_enc_approval_bal api SQLERR:'||SQLCODE||SQLERRM);
		End if;
		Raise;

END update_enc_approvl_bal;

--------------------------------------------------------------------------------------------------------
-- This api is called in partial mode, when funds check is called in partial mode
-- funds check will be done on the basis of document_type and document_header_id for
-- batch of 100 EI at a time this api is created to fix the bug :
--------------------------------------------------------------------------------------------------------
FUNCTION pa_fcp_process
        (p_sob                  IN  NUMBER
        ,p_packet_id            IN  pa_bc_packets.packet_id%type
        ,p_mode                 IN   varchar2
        ,p_partial_flag         IN   varchar2
        ,p_arrival_seq          IN   NUMBER
        ,p_reference1           IN   varchar2
        ,p_reference2           IN   varchar2
        ,p_calling_module       IN   varchar2
          ) return boolean  IS

        -- funds check will be done based on document_type and
        -- document_header_id. hence a batch of 100 EIS will be processed
        -- once.( if burden on diff item leades to 300 eis approximatly).
        l_tab_doc_type        pa_plsql_datatypes.char50tabtyp;
        l_tab_effect_fc_level pa_plsql_datatypes.char50tabtyp;
        l_tab_doc_header_id   pa_plsql_datatypes.idtabtyp;
        l_tab_bc_packet_id    pa_plsql_datatypes.idtabtyp;
	l_num_rows            NUMBER := 200;
        cursor cur_docs is
        SELECT document_type,
                document_header_id
        FROM pa_bc_packets
        WHERE packet_id = p_packet_id
        AND   status_code = 'P'
        AND   NVL(substr(result_code,1,1),'P') <> 'F'
        ORDER BY document_type,
                 document_header_id;

	-- this cursor picks all the transactions which are marked to
	-- intermediate status
	cursor cur_reset_doc_sts is
	SELECT bc_packet_id
	FROM pa_bc_packets
	WHERE packet_id = p_packet_id
	AND   status_code = 'Z';

	-- cursor to pick all the transaction which doesnot require funds check
	-- ie fc results in increase
	cursor cur_get_fc_incr_trxn is
	SELECT bc_packet_id,
	       effect_on_funds_code
	FROM   pa_bc_packets
	WHERE  packet_id = p_packet_id
	AND    status_code = 'P'
	AND    nvl(substr(result_code,1,1),'P') <> 'F'
	AND    effect_on_funds_code = 'I';

	PROCEDURE update_docs_status
        	(p_packet_id in number
		 ,p_status_code  in varchar2 ) IS
        	PRAGMA AUTONOMOUS_TRANSACTION;
	BEGIN

	      IF p_status_code = 'Z' then

			FORALL i IN l_tab_doc_header_id.FIRST .. l_tab_doc_header_id.LAST
                        /* 4141729 - Added INDEX hint */
        		UPDATE  /*+ INDEX (pbp PA_BC_PACKETS_U1) */ pa_bc_packets
       			SET status_code = p_status_code
        		WHERE packet_id = p_packet_id
        		AND document_type = l_tab_doc_type(i)
        		AND document_header_id = l_tab_doc_header_id(i)
        		AND status_code = 'P'
        		AND nvl(substr(result_code,1,1),'P') <> 'F';

	      Elsif p_status_code = 'P' then

			-- Reset the status code after processing
                	FORALL i IN l_tab_bc_packet_id.FIRST .. l_tab_bc_packet_id.LAST
                	UPDATE  pa_bc_packets
                	SET  status_code = p_status_code
                	WHERE packet_id = p_packet_id
                	AND  bc_packet_id = l_tab_bc_packet_id(i);
	      Elsif p_status_code = 'I' then
		-- update the result codes to pass as the funds check result in
		-- increase in amounts
		FORALL i IN l_tab_bc_packet_id.FIRST .. l_tab_bc_packet_id.LAST
			UPDATE pa_bc_packets
			SET status_code = 'Z',
			    result_code = 'P113',
			    res_result_code = 'P113',
			    res_grp_result_code = 'P113',
			    task_result_code = 'P113',
			    top_task_result_code = 'P113',
			    project_result_code = 'P113',
			    Project_acct_result_code = 'P113'
			WHERE packet_id = p_packet_id
			AND bc_packet_id = l_tab_bc_packet_id(i);

	      END IF;

        	commit;
        	return;
	EXCEPTION
		when others then
			raise;
	END update_docs_status;


BEGIN
	IF g_debug_mode = 'Y' THEN
	  	log_message(p_msg_token1 => 'partial flag  = '||p_partial_flag);
	End if;

	Initialize_globals;
	init_plsql_tabs;
        IF p_partial_flag = 'Y' then
                OPEN cur_docs;
		LOOP
		  	l_tab_doc_type.delete;
		  	l_tab_doc_header_id.delete;
                	FETCH cur_docs BULK COLLECT INTO
                        	l_tab_doc_type,
                        	l_tab_doc_header_id  LIMIT 100;
			IF NOT l_tab_doc_header_id.EXISTS(1) then
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1 => 'no recs found');
				End if;
				EXIT;
			END IF;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'calling update_docs_status api');
			End if;
			-- update the status_code to intermediate state
			update_docs_status(p_packet_id, 'Z');
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'count of tab header id ='||l_tab_doc_header_id.count);
			End if;

                       /* Moved this here for bug 6378539*/
			exit when cur_docs%notfound;
 		END LOOP;
		CLOSE cur_docs;
                      /* End Bug 6378539 */

		      -- Call funds check pa_fck_process for batch of 100 eis
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'pa fck process in partial flag modepartial flag['||p_partial_flag);
			End if;
            		IF NOT  pa_fck_process
                		(p_sob                  => p_sob
                		,p_packet_id            => p_packet_id
                		,p_mode                 => p_mode
                		,p_partial_flag         => p_partial_flag
                		,p_arrival_seq          => p_arrival_seq
                		,p_reference1           => p_reference1
                		,p_reference2           => p_reference2
                		--,p_reference3           => p_reference3
                		,p_calling_module       => p_calling_module
                		) then
				IF g_debug_mode = 'Y' THEN
                			log_message(p_msg_token1 =>
					'funds check failed during pa_fck_process api');
				End if;
				g_return_status := 'T';
                		--log_message(p_return_status => 'T');
            		END IF;

/*             Commented this code for the bug 6378539
			exit when cur_docs%notfound;

		END LOOP;
		CLOSE cur_docs;
*/
	Elsif  p_partial_flag <> 'Y' then  -- full mode

		-- update the result codes of the all the transactions which
		-- donot require funds check
		OPEN cur_get_fc_incr_trxn;
		LOOP
			l_tab_bc_packet_id.delete;
			l_tab_effect_fc_level.delete;
			FETCH cur_get_fc_incr_trxn BULK COLLECT INTO
				l_tab_bc_packet_id,
				l_tab_effect_fc_level  LIMIT l_num_rows;

			IF not l_tab_bc_packet_id.EXISTS(1) then
				EXIT;
			END IF;
                        -- update the result codes to pass
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'calling update_docs_status for Increase funds trxn');
			End if;
                        update_docs_status(p_packet_id, 'I');

			exit when cur_get_fc_incr_trxn%notfound;

		END LOOP;
		CLOSE cur_get_fc_incr_trxn;

			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'calling pa fck process in full modepartial flag['||p_partial_flag);
			End if;
                        -- Call funds check pa_fck_process for batch of 100 eis
                        IF NOT  pa_fck_process
                                (p_sob                  => p_sob
                                ,p_packet_id            => p_packet_id
                                ,p_mode                 => p_mode
                                ,p_partial_flag         => p_partial_flag
                                ,p_arrival_seq          => p_arrival_seq
                                ,p_reference1           => p_reference1
                                ,p_reference2           => p_reference2
                                --,p_reference3           => p_reference3
                                ,p_calling_module       => p_calling_module
                                ) then
				g_return_status := 'T';
                                --log_message(p_return_status => 'T');
                        END IF;

	END IF;
        -- reset the status code back to earlier stage
        OPEN cur_reset_doc_sts;
        LOOP
              FETCH cur_reset_doc_sts BULK COLLECT INTO
                     l_tab_bc_packet_id  LIMIT 200;

              IF not l_tab_bc_packet_id.EXISTS(1) then
                     EXIT;
              END IF;
	      IF g_debug_mode = 'Y' THEN
              	log_message(p_msg_token1 => 'calling update_docs_status api to reset the status ');
	      End if;
               -- update the status_code to intermediate state
              update_docs_status(p_packet_id, 'P');

              EXIT when cur_reset_doc_sts%notfound;
        END LOOP;
	IF g_debug_mode = 'Y' THEN
        	log_message(p_msg_token1 => 'end of cur_reset_doc_sts cursor');
	End if;
        CLOSE cur_reset_doc_sts;

	IF cur_docs%isopen then
		close  cur_docs;
	End if;
	IF cur_reset_doc_sts%isopen then
		close cur_reset_doc_sts;
	End if;

	IF cur_get_fc_incr_trxn%isopen then
		close cur_get_fc_incr_trxn;
	End if;

        /** Bug fix : 2021199 Transaction funds check form is not showing the
         *  correct available balance when requision becomes Purchase order
         */
	/* bug fix : 2658952 moved this logic to form to derive encumbrance pending amount
	update_enc_approvl_bal(p_packet_id  => p_packet_id
                              ,p_calling_module => p_calling_module
                              ,p_mode  => p_mode);
	**/
	Return true;

EXCEPTION

	when OTHERS then
		-- if there is any error then update the transaction
		-- back to earlier status from intermediate status
                -- reset the status code back to earlier stage
                OPEN cur_reset_doc_sts;
                LOOP
                        FETCH cur_reset_doc_sts BULK COLLECT INTO
                                l_tab_bc_packet_id  LIMIT 200;

                        IF not l_tab_bc_packet_id.EXISTS(1) then
                                EXIT;
                        END IF;
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'calling update_docs_status api to reset the status ');
			End if;
                        -- update the status_code to intermediate state
                        update_docs_status(p_packet_id, 'P');

                        EXIT when cur_reset_doc_sts%notfound;
                END LOOP;
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 => 'end of cur_reset_doc_sts cursor');
		End if;
                CLOSE cur_reset_doc_sts;

                if cur_docs%isopen then
                        close cur_docs;
                ENd if;
                IF cur_reset_doc_sts%isopen then
                        close cur_reset_doc_sts;
                End if;
	        IF cur_get_fc_incr_trxn%isopen then
               		 close cur_get_fc_incr_trxn;
        	End if;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'Failed in pa_fcp_process');
		End if;
		Raise;
END pa_fcp_process;
--------------------------------------------------------------------------------------------------------------
 -- This is an wrapper api for main funds check process where it make calls to CHECK_FUNDS_AVAILABLE api
 -- in a loop and updates the pa bc packets in batch of 200 records
-------------------------------------------------------------------------------------------------------------
FUNCTION  pa_fck_process
 	(p_sob			IN  NUMBER
  	,p_packet_id 		IN  pa_bc_packets.packet_id%type
        ,p_mode			IN   varchar2
        ,p_partial_flag 	IN   varchar2
        ,p_arrival_seq		IN   NUMBER
	,p_reference1		IN   varchar2
	,p_reference2   	IN   varchar2
	--,p_reference3		IN   varchar2
	,p_calling_module	IN   varchar2
         )   return BOOLEAN  is

	-- this cursor picks all the details for a particular transaction whcih requires
	-- funds check
 	CURSOR  trxn_details   IS
	SELECT  pbc.rowid,
		pbc.bc_packet_id,
        	pbv.budget_version_id ,
        	pbc.project_id ,
        	pbc.task_id ,
		pbc.document_type,
        	pbc.document_header_id ,
        	pbc.document_distribution_id,
        	pbc.expenditure_item_date ,
        	pbc.expenditure_organization_id  ,
        	pbc.actual_flag ,
        	pbc.period_name  ,
        	pm.time_phased_type_code,
        	pb.amount_type ,
        	pb.boundary_code ,
        	pm.entry_level_code,
        	pm.categorization_code ,
        	pbc.resource_list_member_id ,
        	NVL(pbc.parent_resource_id,0) , /* Added for Bug fix: 2658952 */
        	pbv.resource_list_id ,
        	NVL(rlm.parent_member_id,0) , /* Added for Bug fix: 2658952 */
        	pbc.bud_task_id ,
        	pbc.bud_resource_list_member_id ,
        	pbc.top_task_id ,
        	pbc.r_funds_control_level_code ,
        	pbc.rg_funds_control_level_code ,
        	pbc.t_funds_control_level_code ,
        	pbc.tt_funds_control_level_code ,
        	pbc.p_funds_control_level_code ,
        	pm.burdened_cost_flag ,
		nvl(pbc.accounted_dr,0) accounted_dr,
		nvl(pbc.accounted_cr,0) accounted_cr,
        	nvl(pbc.accounted_dr ,0) - nvl(pbc.accounted_cr,0) pkt_trx_amt,
        	decode(pbc.status_code||actual_flag,'PE',
			nvl(pbc.accounted_dr ,0)-nvl(pbc.accounted_cr,0)*1,0) PE_amt,
	 	decode(pbc.status_code||actual_flag,'PA',
			nvl(pbc.accounted_dr ,0)-nvl(pbc.accounted_cr,0)*1,0) PA_amt,
        	pbc.status_code,
		pbc.effect_on_funds_code,
	        pbc.result_code ,
                pbc.res_result_code ,
                pbc.res_grp_result_code ,
                pbc.task_result_code ,
                pbc.top_task_result_code ,
                pbc.project_result_code ,
		pbc.res_budget_posted,
		pbc.res_grp_budget_posted,
		pbc.task_budget_posted,
		pbc.top_task_budget_posted,
		pbc.project_budget_posted,
		pbc.res_actual_posted,
		pbc.res_grp_actual_posted,
		pbc.task_actual_posted,
		pbc.top_task_actual_posted,
		pbc.project_actual_posted,
		pbc.res_enc_posted,
		pbc.res_grp_enc_posted,
		pbc.task_enc_posted,
		pbc.top_task_enc_posted,
		pbc.project_enc_posted,
		pbc.res_budget_bal,
		pbc.res_grp_budget_bal,
		pbc.task_budget_bal,
		pbc.top_task_budget_bal,
		pbc.project_budget_bal,
		pbc.res_actual_approved,
		pbc.res_grp_actual_approved,
		pbc.task_actual_approved,
		pbc.top_task_actual_approved,
		pbc.project_actual_approved,
		pbc.res_enc_approved,
		pbc.res_grp_enc_approved,
		pbc.task_enc_approved,
		pbc.top_task_enc_approved,
		pbc.project_enc_approved ,
		pbc.effect_on_funds_code,
		pbc.txn_ccid,
		pbc.budget_ccid,
		pbc.gl_date,
		pbc.pa_date,
		pbc.parent_bc_packet_id,
		/** added for bug fix : 1992734 **/
		pbc.fc_start_date, /* PAM changes */
		pbc.fc_end_date,
		nvl(list.GROUP_RESOURCE_TYPE_ID,0) GROUP_RESOURCE_TYPE_ID,  /* added for bug fix2658952 */
		pbc.ext_bdgt_flag
 	FROM
 		pa_bc_packets pbc,
		pa_budget_versions pbv,
		pa_budget_entry_methods pm,
		pa_budgetary_control_options pb,
		pa_projects_all pp,
		pa_resource_list_members rlm,
		PA_RESOURCE_LISTS_ALL_BG list
 	WHERE  pbc.packet_id = p_packet_id
	AND    pbc.budget_version_id = pbv.budget_version_id
	AND    pbv.budget_entry_method_code = pm.budget_entry_method_code
	AND    pbc.resource_list_member_id = rlm.resource_list_member_id
	AND    pp.project_id = pbc.project_id
	AND    pbc.project_id = pb.project_id
	AND    nvl(substr(pbc.result_code,1,1),'P') NOT IN ( 'F','R')
	AND    ( (pbc.status_code = 'P'
		  and p_partial_flag <> 'Y'
		  )
		 OR
		 (pbc.status_code = 'Z'
		  and p_partial_flag = 'Y')
	       )
        AND    pb.BDGT_CNTRL_FLAG = 'Y'
        AND    pb.BUDGET_TYPE_CODE = pbv.budget_type_code
        AND   ((pbc.document_type in ('AP','PO','REQ','EXP','CC_P_PAY','CC_C_PAY')
		and pb.EXTERNAL_BUDGET_CODE = 'GL')
                        OR
		(pbc.document_type in ('AP','PO','REQ','EXP','CC_P_PAY','CC_C_PAY')
                  and pb.EXTERNAL_BUDGET_CODE is NULL)
			OR
		(pbc.document_type in ('CC_P_CO','CC_C_CO')
	          and pb.EXTERNAL_BUDGET_CODE = 'CC' )
               )
	/* added for bug fix 2658952 */
	AND  list.RESOURCE_LIST_ID = rlm.RESOURCE_LIST_ID
	ORDER BY
		 pbc.project_id,
		 pbc.budget_version_id,
		 pbc.fc_start_date , /** added for bug fix : 1992734 **/
		 pbc.fc_end_date , /* bug 8635962  */
		 decode(p_partial_flag,'Y',pbc.effect_on_funds_code,0) desc,
		 decode(p_calling_module,'DISTERADJ',pbc.document_header_id,0),
		 pbc.task_id,
		 pbc.bud_task_id,
		 NVL(pbc.parent_resource_id,0) , /* Added for Bug fix: 2658952 */
		 pbc.resource_list_member_id,
		 pbc.bud_resource_list_member_id,
		 nvl(pbc.accounted_dr,0) - nvl(pbc.accounted_cr,0)
		 ;
	l_previous_bdgt_version_id    NUMBER;
	l_num_rows 		NUMBER := 200;
	l_status_code 		VARCHAR2(1) := 'P';
	l_return_status		VARCHAR2(1) := 'S';
	l_prv_project_id        NUMBER := null;
	l_ext_bdgt_type         VARCHAR2(10);
	l_ext_bdgt_link         VARCHAR2(1);
	l_prv_ext_bdgt_type     VARCHAR2(10) := null;
	l_fc_record		pa_fc_record;
	l_start_date		DATE;
	l_end_date		DATE;
	l_result_code		VARCHAR2(20);
	l_error_stage		VARCHAR2(20);
	l_error_msg		VARCHAR2(2000);
	l_error_code		number;
	l_date_for_calc         Date;

        l_prv_time_phase	VARCHAR2(20):= null;
        l_prv_exp_item_date     DATE := null;
        l_prv_amount_type       VARCHAR2(20):= null;
        l_prv_boundary_code     VARCHAR2(20):= null;
        l_prv_sob		NUMBER := null;
	l_prv_bdgt_version_id   NUMBER := null;
	l_prv_gl_date		DATE := null;
	l_prv_pa_date		DATE := null;

	l_counter               number := 0;

 BEGIN

	IF p_partial_flag = 'Y' then
		l_num_rows := 100000;
	Else
		l_num_rows  := 200;
	ENd IF;
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'Inside the pa_fck_process');
	End if;
	OPEN  trxn_details;
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'opened the trxn details cursor');
	End if;
	LOOP  -- start of the batch process
		-- initialize the pl/sql tables fecth the values into tables
		init_plsql_tabs;
		FETCH trxn_details BULK COLLECT INTO
          		g_tab_rowid,
			g_tab_bc_packet_id,
                	g_tab_budget_version_id ,
                	g_tab_project_id ,
                	g_tab_task_id ,
                	g_tab_doc_type,
                	g_tab_doc_header_id ,
                	g_tab_doc_distribution_id,
                	g_tab_exp_item_date ,
                	g_tab_exp_org_id  ,
                	g_tab_actual_flag ,
                	g_tab_period_name  ,
                	g_tab_time_phase_type_code,
                	g_tab_amount_type ,
                	g_tab_boundary_code ,
                	g_tab_entry_level_code,
                	g_tab_category_code ,
                	g_tab_rlmi ,
                	g_tab_p_resource_id ,
                	g_tab_r_list_id ,
                	g_tab_p_member_id  ,
                	g_tab_bud_task_id ,
                	g_tab_bud_rlmi ,
                	g_tab_tt_task_id ,
                	g_tab_r_fclevel_code ,
                	g_tab_rg_fclevel_code ,
                	g_tab_t_fclevel_code ,
                	g_tab_tt_fclevel_code ,
                	g_tab_p_fclevel_code ,
                	g_tab_burd_cost_flag ,
			g_tab_accounted_dr,
			g_tab_accounted_cr,
                	g_tab_pkt_trx_amt,
			g_tab_PE_amt,
			g_tab_PA_amt,
                	g_tab_status_code,
                	g_tab_effect_on_funds_code,
                	g_tab_result_code ,
                	g_tab_r_result_code ,
                	g_tab_rg_result_code ,
                	g_tab_t_result_code ,
                	g_tab_tt_result_code ,
                	g_tab_p_result_code ,
			g_tab_r_budget_posted,
			g_tab_rg_budget_posted,
			g_tab_t_budget_posted,
			g_tab_tt_budget_posted,
			g_tab_p_budget_posted,
			g_tab_r_actual_posted,
			g_tab_rg_actual_posted,
			g_tab_t_actual_posted,
			g_tab_tt_actual_posted,
			g_tab_p_actual_posted,
			g_tab_r_enc_posted,
			g_tab_rg_enc_posted,
			g_tab_t_enc_posted,
			g_tab_tt_enc_posted,
			g_tab_p_enc_posted,
			g_tab_r_budget_bal,
			g_tab_rg_budget_bal,
			g_tab_t_budget_bal,
			g_tab_tt_budget_bal,
			g_tab_p_budget_bal,
			g_tab_r_actual_approved,
			g_tab_rg_actual_approved,
			g_tab_t_actual_approved,
			g_tab_tt_actual_approved,
			g_tab_p_actual_approved,
			g_tab_r_enc_approved,
			g_tab_rg_enc_approved,
			g_tab_t_enc_approved,
			g_tab_tt_enc_approved,
			g_tab_p_enc_approved,
			g_tab_effect_fclevel,
			g_tab_trxn_ccid,
			g_tab_budget_ccid,
			g_tab_gl_date,
			g_tab_pa_date,
			g_tab_p_bc_packet_id,
			g_tab_start_date,
			g_tab_end_date,
			g_tab_group_resource_type_id,
			g_tab_ext_bdgt_link    LIMIT l_num_rows;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'after fectch num rows'||g_tab_doc_header_id.count);
		End if;

		IF NOT g_tab_rowid.EXISTS(1) then
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'Fetch rows is zero ');
			END IF;
			EXIT;
		END IF;



	-- For each record in table loop through derive start and end dates
	-- check the availability of funds
		l_counter := 0;
		FOR  i IN g_tab_rowid.FIRST .. g_tab_rowid.LAST LOOP
			l_counter := l_counter + 1;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'Initizaling the record with in FOR loop');
			End if;
			-- Initialize the funds check record
               		initialize_record(l_fc_record);

        		l_fc_record.packet_id                         := p_packet_id;
        		l_fc_record.bc_packet_id                      := g_tab_bc_packet_id(i);
        		l_fc_record.set_of_books_id                   := p_sob;
        		l_fc_record.budget_version_id                 := g_tab_budget_version_id(i);
        		l_fc_record.project_id                        := g_tab_project_id(i);
        		l_fc_record.task_id                           := g_tab_task_id(i);
        		l_fc_record.document_type                     := g_tab_doc_type(i);
        		l_fc_record.document_header_id                := g_tab_doc_header_id(i);
        		l_fc_record.document_distribution_id          := g_tab_doc_distribution_id(i);
        		l_fc_record.expenditure_item_date             := g_tab_exp_item_date(i);
        		l_fc_record.expenditure_organization_id       := g_tab_exp_org_id(i);
        		l_fc_record.actual_flag                       := g_tab_actual_flag(i);
        		l_fc_record.period_name                       := g_tab_period_name(i);
        		l_fc_record.time_phased_type_code             := g_tab_time_phase_type_code(i);
        		l_fc_record.amount_type                       := g_tab_amount_type(i);
        		l_fc_record.boundary_code                     := g_tab_boundary_code(i);
        		l_fc_record.entry_level_code                  := g_tab_entry_level_code(i);
        		l_fc_record.categorization_code               := g_tab_category_code(i);
        		l_fc_record.resource_list_member_id           := g_tab_rlmi(i);
        		l_fc_record.parent_resource_id                := g_tab_p_resource_id(i);
        		l_fc_record.resource_list_id                  := g_tab_r_list_id(i);
        		l_fc_record.parent_member_id                  := g_tab_p_member_id(i);
        		l_fc_record.bud_task_id                       := g_tab_bud_task_id(i);
        		l_fc_record.bud_resource_list_member_id       := g_tab_bud_rlmi(i);
        		l_fc_record.top_task_id                       := g_tab_tt_task_id(i);
        		l_fc_record.r_funds_control_level_code        := g_tab_r_fclevel_code(i);
        		l_fc_record.rg_funds_control_level_code       := g_tab_rg_fclevel_code(i);
        		l_fc_record.t_funds_control_level_code        := g_tab_t_fclevel_code(i);
        		l_fc_record.tt_funds_control_level_code       := g_tab_tt_fclevel_code(i);
        		l_fc_record.p_funds_control_level_code        := g_tab_p_fclevel_code(i);
        		l_fc_record.burdened_cost_flag                := g_tab_burd_cost_flag(i);
        		l_fc_record.accounted_dr                      := g_tab_accounted_dr(i);
        		l_fc_record.accounted_cr                      := g_tab_accounted_cr(i);
        		l_fc_record.status_code                       := l_status_code;
			l_fc_record.r_budget_posted		      := g_tab_r_budget_posted(i);
			l_fc_record.rg_budget_posted		      := g_tab_rg_budget_posted(i);
			l_fc_record.t_budget_posted		      := g_tab_t_budget_posted(i);
			l_fc_record.tt_budget_posted	              := g_tab_tt_budget_posted(i);
			l_fc_record.p_budget_posted		      := g_tab_p_budget_posted(i);
			l_fc_record.r_actual_posted		      := g_tab_r_actual_posted(i);
			l_fc_record.rg_actual_posted                  := g_tab_rg_actual_posted(i);
			l_fc_record.t_actual_posted		      := g_tab_t_actual_posted(i);
			l_fc_record.tt_actual_posted	              := g_tab_tt_actual_posted(i);
			l_fc_record.p_actual_posted		      := g_tab_p_actual_posted(i);
			l_fc_record.r_enc_posted		      := g_tab_r_enc_posted(i);
			l_fc_record.rg_enc_posted		      := g_tab_rg_enc_posted(i);
			l_fc_record.t_enc_posted		      := g_tab_t_enc_posted(i);
			l_fc_record.tt_enc_posted	              := g_tab_tt_enc_posted(i);
			l_fc_record.p_enc_posted		      := g_tab_p_enc_posted(i);
			l_fc_record.r_budget_bal		      := g_tab_r_budget_bal(i);
			l_fc_record.rg_budget_bal		      := g_tab_rg_budget_bal(i);
			l_fc_record.t_budget_bal		      := g_tab_t_budget_bal(i);
			l_fc_record.tt_budget_bal	              := g_tab_tt_budget_bal(i);
			l_fc_record.p_budget_bal		      := g_tab_p_budget_bal(i);
			l_fc_record.r_actual_approved		      := g_tab_r_actual_approved(i);
			l_fc_record.rg_actual_approved                := g_tab_rg_actual_approved(i);
			l_fc_record.t_actual_approved		      := g_tab_t_actual_approved(i);
			l_fc_record.tt_actual_approved	              := g_tab_tt_actual_approved(i);
			l_fc_record.p_actual_approved		      := g_tab_p_actual_approved(i);
			l_fc_record.r_enc_approved		      := g_tab_r_enc_approved(i);
			l_fc_record.rg_enc_approved                   := g_tab_rg_enc_approved(i);
			l_fc_record.t_enc_approved		      := g_tab_t_enc_approved(i);
			l_fc_record.tt_enc_approved	              := g_tab_tt_enc_approved(i);
			l_fc_record.p_enc_approved		      := g_tab_p_enc_approved(i);
			l_fc_record.result_code			      := g_tab_result_code(i);
		 	l_fc_record.r_result_code		      := g_tab_r_result_code(i);
			l_fc_record.rg_result_code                    := g_tab_rg_result_code(i);
			l_fc_record.t_result_code                     := g_tab_t_result_code(i);
			l_fc_record.tt_result_code                    := g_tab_tt_result_code(i);
			l_fc_record.p_result_code                     := g_tab_p_result_code(i);
			l_fc_record.effect_on_funds_code	      := g_tab_effect_fclevel(i);
			l_fc_record.trxn_ccid			      := g_tab_trxn_ccid(i);
			l_fc_record.budget_ccid			      := g_tab_budget_ccid(i);
			l_fc_record.gl_date			      := g_tab_gl_date(i);
			l_fc_record.pa_date			      := g_tab_pa_date(i);
			l_fc_record.parent_bc_packet_id		      := g_tab_p_bc_packet_id(i);
			l_fc_record.group_resource_type_id            := g_tab_group_resource_type_id(i);
			-- check whether the budget type is STD or CBC  and budget is Linked with GL
			If l_fc_record.document_type in ('AP','PO','REQ','EXP','CC_C_PAY','CC_P_PAY' ) THEN
				l_ext_bdgt_type := 'STD';
			Else
				l_ext_bdgt_type := 'CBC';
			End if;

			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'start date['||g_tab_start_date(i)||']end date['||g_tab_end_date(i)||']');
			End if;
			l_start_date := g_tab_start_date(i);
			l_end_date   := g_tab_end_date(i);
			l_ext_bdgt_link := g_tab_ext_bdgt_link(i);

			If g_tab_start_date(i) is not null and g_tab_end_date(i) is not null then

 				check_funds_available (
					p_sob			=> p_sob,
					p_mode			=> p_mode,
 					p_packet_id 		=> p_packet_id,
 					p_record		=> l_fc_record,  -- IN OUT NOCOPY param
					p_arrival_seq		=> p_arrival_seq,
					p_status_code		=> l_status_code,
					p_ext_bdgt_link		=> l_ext_bdgt_link,
					p_ext_bdgt_type         => l_ext_bdgt_type,
					p_start_date		=> l_start_date,
					p_end_date		=> l_end_date,
					p_calling_module	=> p_calling_module,
					p_partial_flag		=> p_partial_flag,
					p_counter	        => l_counter
						);
				If g_debug_mode = 'Y' Then
					log_message(p_msg_token1 => 'after the check funds available api');
				End if;
			Else  -- assign the result code derived during the start date and end date
			      -- proceed to next record for funds check
				/** commented for bug fix : 1992734  **/
                        	--l_fc_record.result_code := l_result_code;
                        	l_fc_record.result_code := 'F136';

			End if;



			 --- Assign the OUT NOCOPY parameter values to pl / sql tables
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'Assiginig out NOCOPY params to global variables');
			End if;
                        g_tab_r_budget_posted(i) := l_fc_record.r_budget_posted;
                        g_tab_rg_budget_posted(i) := l_fc_record.rg_budget_posted;
                        g_tab_t_budget_posted(i) := l_fc_record.t_budget_posted;
                        g_tab_tt_budget_posted(i) := l_fc_record.tt_budget_posted;
                        g_tab_p_budget_posted(i) := l_fc_record.p_budget_posted;
                        g_tab_r_actual_posted(i) := l_fc_record.r_actual_posted;
                        g_tab_rg_actual_posted(i) := l_fc_record.rg_actual_posted;
                        g_tab_t_actual_posted(i) := l_fc_record.t_actual_posted;
                        g_tab_tt_actual_posted(i) := l_fc_record.tt_actual_posted;
                        g_tab_p_actual_posted(i) := l_fc_record.p_actual_posted;
                        g_tab_r_enc_posted(i) := l_fc_record.r_enc_posted;
                        g_tab_rg_enc_posted(i) := l_fc_record.rg_enc_posted;
                        g_tab_t_enc_posted(i) := l_fc_record.t_enc_posted;
                        g_tab_tt_enc_posted(i) := l_fc_record.tt_enc_posted;
                        g_tab_p_enc_posted(i) := l_fc_record.p_enc_posted;
                        g_tab_r_budget_bal(i) := l_fc_record.r_budget_bal;
                        g_tab_rg_budget_bal(i):= l_fc_record.rg_budget_bal;
                        g_tab_t_budget_bal(i) := l_fc_record.t_budget_bal;
                        g_tab_tt_budget_bal(i) := l_fc_record.tt_budget_bal;
                        g_tab_p_budget_bal(i) := l_fc_record.p_budget_bal;
                        g_tab_r_actual_approved(i):= l_fc_record.r_actual_approved;
                        g_tab_rg_actual_approved(i) := l_fc_record.rg_actual_approved;
                        g_tab_t_actual_approved(i) := l_fc_record.t_actual_approved;
                        g_tab_tt_actual_approved(i) := l_fc_record.tt_actual_approved;
                        g_tab_p_actual_approved(i) := l_fc_record.p_actual_approved;
                        g_tab_r_enc_approved(i) := l_fc_record.r_enc_approved;
                        g_tab_rg_enc_approved(i) := l_fc_record.rg_enc_approved;
                        g_tab_t_enc_approved(i) := l_fc_record.t_enc_approved;
                        g_tab_tt_enc_approved(i) := l_fc_record.tt_enc_approved ;
                        g_tab_p_enc_approved(i) := l_fc_record.p_enc_approved;
                        g_tab_result_code(i) := l_fc_record.result_code;
                        g_tab_r_result_code(i) := l_fc_record.r_result_code;
                        g_tab_rg_result_code(i) := l_fc_record.rg_result_code;
                        g_tab_t_result_code(i) := l_fc_record.t_result_code;
                        g_tab_tt_result_code(i) := l_fc_record.tt_result_code;
                        g_tab_p_result_code(i) := l_fc_record.p_result_code;
			g_tab_p_acct_result_code(i) := l_fc_record.p_acct_result_code;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'end of assignments');
			End if;


		END LOOP;

		-- update the bc_packets with result and status codes in batch
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'Calling update pkt amts autonomous transaction statement');
		End if;
		update_pkt_amts(p_packet_id);
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'after the autonomous call');
		End if;
		EXIT WHEN trxn_details%NOTFOUND;
	END LOOP;  -- end of the batch process
	CLOSE trxn_details;
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'end of trxn_details cursor ');
	End if;
	RETURN true;

EXCEPTION

	when others then
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'failed due to un expected error during funds check');
		End if;
		If trxn_details%ISOPEN then
			close trxn_details;
		End if;
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 => 'failed in pa_fc_process api SQLERR :'||sqlcode||sqlerrm);
		End if;
		Raise;


END pa_fck_process;

---------------------------------------------------------------------------------------------------------------
--This  API  inserts the packet id  into the gl_bc_arrival_packet_order , derives the arrival  sequence
--and ensures the data consistency for funds check process
---------------------------------------------------------------------------------------------------------------

FUNCTION   get_arrival_seq
	(p_calling_module       IN      VARCHAR2
	,p_packet_id		IN  	NUMBER
	,p_sobid		IN	NUMBER
	,p_mode			IN 	VARCHAR2
	) RETURN NUMBER IS

	PRAGMA AUTONOMOUS_TRANSACTION;

	v_arrival_seq	NUMBER;
	l_number        NUMBER;

BEGIN
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'Inside the get arrival seq api');
	End if;

 	-------  Acquire a lock before processing ----------------
	PA_DEBUG.Set_User_Lock_Mode
				( x_Lock_Mode   => 6
				,x_Commit_Mode => FALSE
				,x_TimeOut   => 30);

	l_number := pa_debug.acquire_user_lock('PAFUNDSCHECKLOCKER');
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'the value of lock handler = '||l_number);
	End if;
  	If l_number  = 0 then

		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'Acquired the lock for funds check');
		End if;
       		INSERT INTO pa_bc_packet_arrival_order
       		( packet_id
		, set_of_books_id
		, arrival_seq
		, affect_funds_flag
		, last_update_date
		, last_updated_by
		)
        	VALUES (
           	p_packet_id
            	,p_sobid
               	,pa_bc_packet_arrival_order_s.nextval
		,DECODE ( p_mode, 'B', 'N', 'Y' )
		--For budget submit and baselining(S and   B) it does not affect the funds.
		--For Encumbrances (E) it afffects funds.
               	,SYSDATE
               	,fnd_global.user_id
		);
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'No of records inserted into pa_bc_packet_arrival_order ='||sql%rowcount);
		End if;

		BEGIN
			SELECT arrival_seq
	        	INTO v_arrival_seq
	        	FROM pa_bc_packet_arrival_order ao
	        	WHERE ao.packet_id = p_packet_id;

		EXCEPTION
			WHEN OTHERS THEN
		 		result_status_code_update(p_packet_id => p_packet_id,
                                p_status_code => 'R',
                                p_result_code => 'F141',
                                p_res_result_code => 'F141',
                                p_res_grp_result_code => 'F141',
                                p_task_result_code => 'F141',
                                p_project_result_code => 'F141',
                                p_proj_acct_result_code => 'F141');
				v_arrival_seq := 0;
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1=>'Failed to acquire lock - Exception portion');
				End if;
				log_message(p_error_msg =>sqlcode||sqlerrm);
		END;
     		------------- Release the Lock --------------
       		If (pa_debug.release_user_lock('PAFUNDSCHECKLOCKER') = 0) then
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'Released the Lock');
			End if;
		END If;

	ELSE
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'Failed to Acquire lock ');
		End if;
		-- Error msg : 'F141 = Funds check failed to acquire lock';
		result_status_code_update(p_packet_id => p_packet_id,
				p_status_code => 'R',
				p_result_code => 'F141',
				p_res_result_code => 'F141',
				p_res_grp_result_code => 'F141',
				p_task_result_code => 'F141',
				p_project_result_code => 'F141',
				p_proj_acct_result_code => 'F141');
			commit;
		null;
	END IF;

	commit;
	RETURN  nvl(v_arrival_seq,0);

EXCEPTION
	when others then
		If (pa_debug.release_user_lock('PAFUNDSCHECKLOCKER') = 0) then
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'Released the Lock');
			End if;
                        null;
                END If;
		result_status_code_update(p_packet_id => p_packet_id,
                                p_status_code => 'T',
                                p_result_code => 'F141',
                                p_res_result_code => 'F141',
                                p_res_grp_result_code => 'F141',
                                p_task_result_code => 'F141',
                                p_project_result_code => 'F141',
                                p_proj_acct_result_code => 'F141');
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 => 'failed in get arrival seq apiSQLERR :'||sqlcode||sqlerrm);
		End if;
                --commit;
		return 0;
		Raise;
END get_arrival_seq;

---------------------------------------------------------------------------------------
 -- api  to calulate budgeted resource list id in packet for a budget version,
 -- entry level code and budget entry method and update pa_bc_packets for the
 -- set of records having the same combinations.The bud_res_list_id is required
 -- to get the resource group level balances from the  pa_bc_balances
---------------------------------------------------------------------------------------
FUNCTION  bud_res_list_id_update
  	( p_project_id  		IN NUMBER,
	  p_budget_version_id 		IN NUMBER,
	  p_resource_list_member_id  	IN NUMBER,
	  p_categorization_code         IN VARCHAR2,
	  x_bud_resource_list_member_id  OUT NOCOPY NUMBER,
	  x_parent_resource_id		 OUT NOCOPY NUMBER
	  ) return BOOLEAN IS

	----------------------------------------------------------------------------
 	-- find the correct resource list id for funds checking.
 	-- if no budget at the resource level then check the budget at the parent
	---level and get the resource list id from pa_bc_balances
	---------------------------------------------------------------------------
      	CURSOR cur_bud_res_list_id IS
        SELECT pr.resource_list_id,
               pr.parent_member_id
       	FROM   pa_resource_list_members pr
       	WHERE  pr.resource_list_member_id = p_resource_list_member_id;

	--This cursor picks up the resource list member id at the resource level
	-- if the budget is defined at the resource level
	CURSOR cur_res_member(v_project_id  NUMBER,
			      v_bdgt_version_id  NUMBER,
			      v_res_list_mem_id  NUMBER) IS
        	SELECT resource_list_member_id
           	FROM pa_bc_balances
          	WHERE budget_version_id = v_bdgt_version_id
		AND project_id = v_project_id
           	AND resource_list_member_id = v_res_list_mem_id
          	AND balance_type = 'BGT';

	--This cursor picks up the resource list member id at the parent resource level
	-- if the budget at the resource level is not defined and defined at the resource
	-- group level
	CURSOR cur_parent_res_member(v_project_id  NUMBER,
                              v_bdgt_version_id  NUMBER,
                              v_parent_res_list_mem_id  NUMBER) IS
            	SELECT resource_list_member_id
              	FROM pa_bc_balances
           	WHERE budget_version_id = v_bdgt_version_id
		ANd project_id = v_project_id
            	AND resource_list_member_id = v_parent_res_list_mem_id
            	AND balance_type = 'BGT';


      	l_budget_version_id         pa_bc_packets.budget_version_id%TYPE;
      	l_project_id                pa_bc_packets.project_id%TYPE;
      	l_task_id                   pa_bc_packets.bud_task_id%TYPE;
      	l_resource_list_member_id   pa_bc_packets.resource_list_member_id%TYPE;
      	l_resource_list_id          pa_resource_list_members.resource_list_id%TYPE;
      	l_parent_member_id          pa_resource_list_members.parent_member_id%TYPE;
      	l_level                     pa_resource_list_members.member_level%TYPE;
      	l_categorization_code       pa_budget_entry_methods.categorization_code%TYPE;
      	l_bud_res_list_member_id    pa_bc_packets.bud_resource_list_member_id%TYPE;
      	l_parent_resource_id        pa_resource_list_members.parent_member_id%TYPE;
BEGIN

	OPEN cur_bud_res_list_id;
      	LOOP
         	FETCH cur_bud_res_list_id
		INTO 	l_resource_list_id,
                    	l_parent_member_id;
         	EXIT WHEN cur_bud_res_list_id%NOTFOUND;

         	IF p_categorization_code = 'R' THEN
            	-- find the correct resource list id for funds checking.
			OPEN cur_res_member(p_project_id,
                              	p_budget_version_id,
                              	p_resource_list_member_id);
			FETCH cur_res_member INTO l_bud_res_list_member_id;
			-- if the resource is not found then check at the parent level
			IF cur_res_member%notfound THEN
				OPEN cur_parent_res_member
					(p_project_id,
                                	p_budget_version_id,
                                	l_parent_member_id);
				FETCH cur_parent_res_member INTO l_bud_res_list_member_id;
				IF cur_parent_res_member%notfound THEN
					l_bud_res_list_member_id := l_resource_list_member_id;
				END IF;
				CLOSE cur_parent_res_member;
			END IF;
			CLOSE cur_res_member;

		ELSE -- Not categorized by resource

		      BEGIN

            		SELECT pb.resource_list_member_id
              		INTO l_bud_res_list_member_id
              		FROM pa_bc_balances pb
             		WHERE pb.budget_version_id = p_budget_version_id
			AND pb.project_id = p_project_id
               		AND balance_type = 'BGT'
               		AND ROWNUM = 1;

		      EXCEPTION
			when no_data_found then
				null;
		      END;
         	END IF;

		x_bud_resource_list_member_id := l_bud_res_list_member_id;
		x_parent_resource_id  := l_parent_member_id;

      	END LOOP;
	CLOSE cur_bud_res_list_id;

	RETURN true;

EXCEPTION
      	WHEN OTHERS THEN

		if cur_bud_res_list_id%ISOPEN then
			close cur_bud_res_list_id;
		end if;

		If cur_parent_res_member%ISOPEN then
			close cur_parent_res_member;
		End if;

                If cur_res_member%ISOPEN then
                        close cur_res_member;
                End if;
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 => 'failed in bud res list id api SQLERR :'||sqlcode||sqlerrm);
		End if;
         	RAISE;

END bud_res_list_id_update;
--------------------------------------------------------------------------------------------
 ---Procedure to calulate budgeted task id in packet for a budget version, entry level code
 --- and budget entry method and  update pa_bc_packets for the same set of records having
 --- the same combinations. Update the pa bc pakcets based on the budget entry methods
 --- L -- Enter budget at low task
 --- M --  Enter budget at Top task or Low task
 --- P --  Enter budget at Project level
 --- T --  Enter budget at Top task level
-----------------------------------------------------------------------------------------------------
FUNCTION  budget_task_id_update
 	( p_project_id   	IN NUMBER,
	  p_task_id     	IN NUMBER,
	  p_budget_version_id  	IN NUMBER,
	  p_entry_level_code   	IN VARCHAR2,
	  x_bud_task_id        	OUT NOCOPY NUMBER,
	  x_top_task_id        	OUT NOCOPY NUMBER
	) RETURN BOOLEAN IS

	-- This cursor picks the LOW_TASK_ID from pa_balances
	CURSOR cur_low_task_id(	l_project_id  NUMBER,
				l_task_id  NUMBER,
				l_bdgt_version_id  NUMBER) IS
             	SELECT task_id
             	FROM pa_bc_balances
             	WHERE budget_version_id = l_bdgt_version_id
             	AND project_id = l_project_id
             	AND task_id = l_task_id
             	AND balance_type = 'BGT';

	--This cursor picks the TOP_TASK_ID from pa_balances
	CURSOR cur_top_task_id(	l_project_id  NUMBER,
                                l_task_id  NUMBER,
                                l_bdgt_version_id  NUMBER) IS
 		SELECT task_id
        	FROM pa_bc_balances
       		WHERE budget_version_id = l_bdgt_version_id
       		AND project_id = l_project_id
       		AND balance_type = 'BGT'
                AND task_id = (SELECT top_task_id
                                FROM pa_tasks
                                WHERE task_id = l_task_id
                                );


      	l_bud_task_id      pa_bc_packets.bud_task_id%TYPE;
      	l_top_task_id      pa_bc_packets.bud_task_id%TYPE;


BEGIN

	------------------------------------------------------------------------------------
 	-- if the budget entry level in 'L','T','P' -- update directly.
 	-------------------------------------------------------------------------------------------
	SELECT top_task_id
	INTO  l_top_task_id
	FROM  pa_tasks
	WHERE task_id = p_task_id;

	If p_entry_level_code in ('P', 'L', 'T' ) then
		If p_entry_level_code = 'P' then
			x_bud_task_id := 0;
			x_top_task_id := 0;
		Elsif p_entry_level_code = 'L' then
			x_bud_task_id := p_task_id ;
			x_top_task_id := l_top_task_id;
		Elsif p_entry_level_code = 'T' then
			x_bud_task_id := l_top_task_id;
			x_top_task_id := l_top_task_id;
		End if;

	Elsif p_entry_level_code = 'M' then

	---------------------------------------------------------------------------------
      	-- if the budget entry level = 'M' update by record.first select the budget task id
	-- (LOW TASK)based on the project,task,budget version from pa_bc_balances if not found then
	-- select the budget task id(TOP TASK)  based on the project,task,budget version from
	-- pa_bc_balacnes for the toptask in pa_tasks
	-------------------------------------------------------------------------------------
		OPEN cur_low_task_id( p_project_id,
                                      p_task_id,
                                      p_budget_version_id);

		FETCH cur_low_task_id INTO x_bud_task_id;
		IF cur_low_task_id%NOTFOUND THEN

			OPEN cur_top_task_id( p_project_id,
                                      	p_task_id,
                                      	p_budget_version_id);
			FETCH cur_top_task_id INTO x_bud_task_id;
			IF cur_top_task_id%NOTFOUND THEN
				x_bud_task_id := p_task_id;
			END IF;
			CLOSE cur_top_task_id;


		END IF;
		CLOSE cur_low_task_id;
		x_top_task_id := l_top_task_id;

	End IF;


	RETURN TRUE;
EXCEPTION
	WHEN OTHERS THEN
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 => 'failed in budget task id update api SQLERR :'||sqlcode||sqlerrm);
		End if;
        	RAISE;

END  budget_task_id_update;

-- This api derives the effect on funds control level code based on
-- amount the valid return values are I - Increase D - Decrease
FUNCTION get_fclevel_code(p_accounted_dr IN NUMBER,
			  p_accounted_cr IN NUMBER,
			  x_effect_on_funds_code OUT NOCOPY VARCHAR2)
		return boolean IS
BEGIN
        -- Update the pa_bc_packets set the effect on funds level code I - Increase , D - Decrease
        -- based on the amount entered_dr and entered_cr
        IF SIGN (NVL(p_accounted_dr,0)-NVL(p_accounted_cr,0)) = 1 then
                x_effect_on_funds_code := 'D';
        Else
                x_effect_on_funds_code := 'I';
        End if;

        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 => 'failed in get fclevel code apiSQLERR :'||sqlcode||sqlerrm);
		End if;
                RAISE;

END get_fclevel_code;

-----------------------------------------------------------------------------------------------
--Procedure to update the funds control level code in a packet for a project, budget version,
--budget entry method.update pa_bc_packets for the set of records having the same combinations.
------------------------------------------------------------------------------------------------
FUNCTION  funds_ctrl_level_code (
               	p_project_id			IN NUMBER,
               	p_task_id			IN NUMBER,
               	p_top_task_id			IN NUMBER,
               	p_parent_member_id		IN NUMBER,
               	p_resource_list_member_id 	IN NUMBER,
               	p_budget_version_id 		IN NUMBER,
               	p_bud_task_id			IN NUMBER,
               	p_categorization_code		IN VARCHAR2,
       		x_r_funds_control_level_code   	OUT NOCOPY VARCHAR2,
        	x_rg_funds_control_level_code   OUT NOCOPY VARCHAR2,
        	x_t_funds_control_level_code    OUT NOCOPY VARCHAR2,
        	x_tt_funds_control_level_code   OUT NOCOPY VARCHAR2,
        	x_p_funds_control_level_code    OUT NOCOPY VARCHAR2
       		)
		return BOOLEAN is

      	l_r_funds_control_level_code     VARCHAR2 ( 1 );
      	l_rg_funds_control_level_code    VARCHAR2 ( 1 );
      	l_t_funds_control_level_code     VARCHAR2 ( 1 );
      	l_tt_funds_control_level_code    VARCHAR2 ( 1 );
      	l_p_funds_control_level_code     VARCHAR2 ( 1 );

      	CURSOR res_fcl IS
         	SELECT funds_control_level_code
           	FROM pa_budgetary_controls pbc
		     ,pa_budget_versions  bv
          	WHERE bv.budget_version_id = p_budget_version_id
		AND   bv.project_id = pbc.project_id
		AND   bv.budget_type_code = pbc.budget_type_code
		AND   pbc.project_id = p_project_id
            	AND (    pbc.task_id = 0
                 	OR pbc.task_id = p_task_id )
            	AND ((pbc.resource_list_member_id = p_resource_list_member_id
			AND pbc.parent_member_id = p_parent_member_id) OR
		     (pbc.resource_list_member_id = p_resource_list_member_id
		      AND decode(pbc.parent_member_id,0,-1,NVL(pbc.parent_member_id,-1)) = -1 )
                    ) ;
		     /* Bug fix: 2658952 AND NVL(pbc.parent_member_id,0) = 0 ))	; */


      	CURSOR res_grp_fcl IS
         	SELECT funds_control_level_code
           	FROM pa_budgetary_controls pbc
                     ,pa_budget_versions  bv
                WHERE bv.budget_version_id = p_budget_version_id
                AND   bv.project_id = pbc.project_id
                AND   bv.budget_type_code = pbc.budget_type_code
          	AND   pbc.project_id = p_project_id
            	AND (    pbc.task_id = 0
                 	OR pbc.task_id = p_task_id )
            	AND pbc.resource_list_member_id = p_parent_member_id
		AND decode(pbc.parent_member_id,0,-1,NVL(pbc.parent_member_id,-1)) = -1;
		/* Bug fix: 2658952 AND NVL(pbc.parent_member_id,0) = 0; */

      	CURSOR task_fcl IS
         	SELECT funds_control_level_code
           	FROM pa_budgetary_controls pbc
                     ,pa_budget_versions  bv
                WHERE bv.budget_version_id = p_budget_version_id
                AND   bv.project_id = pbc.project_id
                AND   bv.budget_type_code = pbc.budget_type_code
                AND   pbc.project_id = p_project_id
            	AND pbc.task_id = p_task_id
            	/* Bug fix: 2658952 AND NVL(pbc.parent_member_id,0) = 0 */
		AND decode(pbc.parent_member_id,0,-1,NVL(pbc.parent_member_id,-1)) = -1
            	AND NVL(pbc.resource_list_member_id,0) = 0;

      	CURSOR top_task_fcl IS
         	SELECT funds_control_level_code
           	FROM pa_budgetary_controls pbc
                     ,pa_budget_versions  bv
                WHERE bv.budget_version_id = p_budget_version_id
                AND   bv.project_id = pbc.project_id
                AND   bv.budget_type_code = pbc.budget_type_code
                AND   pbc.project_id = p_project_id
            	AND pbc.task_id = p_top_task_id
            	/* Bug fix: 2658952 AND NVL(pbc.parent_member_id,0) = 0 */
		AND decode(pbc.parent_member_id,0,-1,NVL(pbc.parent_member_id,-1)) = -1
            	AND NVL(pbc.resource_list_member_id,0) = 0;

      	CURSOR project_fcl IS
         	SELECT funds_control_level_code
           	FROM pa_budgetary_controls pbc
                     ,pa_budget_versions  bv
                WHERE bv.budget_version_id = p_budget_version_id
                AND   bv.project_id = pbc.project_id
                AND   bv.budget_type_code = pbc.budget_type_code
                AND   pbc.project_id = p_project_id
            	AND NVL(pbc.task_id,0) = 0
            	/* Bug fix: 2658952 AND NVL(pbc.parent_member_id,0) = 0 */
		AND decode(pbc.parent_member_id,0,-1,NVL(pbc.parent_member_id,-1)) = -1
            	AND NVL(pbc.resource_list_member_id,0) = 0;

	/* Bug 5631763 : If there exists no BC records for the resource group/resource then the funds control levels
	                 are defaulted from those defined in pa_budgetary_control_options. If the funds control defined
			 in pa_budgetary_control_options for the resource group/resource is "Default from Resource List"
			 then the funds control levels are derived appropriately from the resource list. */
        CURSOR  c_res_resgrp_no_bc (c_resource_list_member_id NUMBER) IS
	        select nvl(rlm.funds_control_level_code,'N')
                from  PA_RESOURCE_LIST_MEMBERS rlm
                where rlm.resource_list_member_id = c_resource_list_member_id
                and   rlm.ENABLED_FLAG = 'Y'
                and   DECODE(rlm.RESOURCE_TYPE_CODE, 'UNCLASSIFIED', 'Y', DISPLAY_FLAG) = 'Y'
                and   nvl(rlm.migration_code, 'M') = 'M';


BEGIN
	IF g_debug_mode = 'Y' THEN
          log_message(p_msg_token1 => 'funds_ctrl_level_code - in params are'||
         	'Budget version ['||p_budget_version_id||
         	']p_resource_list_member_id ['||p_resource_list_member_id||
         	']project_id['||p_project_id||']p_task_id ['||p_task_id||
         	']p_top_task_id['||p_top_task_id||']p_bud_task_id['||p_bud_task_id||
         	']p_categorization_code['||p_categorization_code||']' );
	End if;

	 --Bug 5964934
        if p_budget_version_id = g_fclc_budget_version_id and
           p_project_id        = g_fclc_project_id and
           g_p_funds_control_level_code is not null then
          l_p_funds_control_level_code :=  g_p_funds_control_level_code;
        else
	-- check the project funds control level code
      	OPEN project_fcl;
       	FETCH project_fcl INTO l_p_funds_control_level_code;
    	IF project_fcl%NOTFOUND then
		l_p_funds_control_level_code := g_Pfund_control_level; -- Bug 5631763
        END IF;
        CLOSE project_fcl;

	 --Bug 5964934
          g_fclc_budget_version_id          := p_budget_version_id;
          g_fclc_project_id                 := p_project_id;
          g_p_funds_control_level_code      := nvl(l_p_funds_control_level_code,'N');
        end if;

	-- task level funds control level codes
	IF NVL(p_bud_task_id,0) <> 0 THEN
	 --Bug 5964934
	  if p_budget_version_id = g_fclc_budget_version_id and
             p_project_id        = g_fclc_project_id and
             p_top_task_id       = g_fclc_top_task_id and
             g_tt_funds_control_level_code is not null then
            l_tt_funds_control_level_code := g_tt_funds_control_level_code;
          else

            	OPEN top_task_fcl;
            	FETCH top_task_fcl INTO l_tt_funds_control_level_code;
	    	IF top_task_fcl%NOTFOUND then
               		l_tt_funds_control_level_code := g_Tfund_control_level; -- Bug 5631763
            	END IF;

            	CLOSE top_task_fcl;

	   --Bug 5964934
            g_fclc_budget_version_id           := p_budget_version_id;
            g_fclc_project_id                  := p_project_id;
            g_fclc_top_task_id                 := p_top_task_id;
            g_tt_funds_control_level_code      := nvl(l_tt_funds_control_level_code,'N');
          end if;

          --Bug 5964934
          if p_budget_version_id = g_fclc_budget_version_id and
             p_project_id        = g_fclc_project_id and
             p_task_id           = g_fclc_task_id and
             g_t_funds_control_level_code is not null then
             l_t_funds_control_level_code := g_t_funds_control_level_code;
          else
		OPEN task_fcl;
            	FETCH task_fcl INTO l_t_funds_control_level_code;
	    	IF task_fcl%NOTFOUND then
               		l_t_funds_control_level_code := g_Tfund_control_level; -- Bug 5631763
            	END IF;

            	CLOSE task_fcl;
	    --Bug 5964934
            g_fclc_budget_version_id          := p_budget_version_id;
            g_fclc_project_id                 := p_project_id;
            g_fclc_task_id                    := p_task_id;
            g_t_funds_control_level_code      := nvl(l_t_funds_control_level_code,'N');
          end if;

	END IF;

	-- Resource level and resource group level funds control level codes
	IF p_categorization_code = 'R' THEN

	--Bug 5964934
          if p_budget_version_id       = g_fclc_budget_version_id and
             p_project_id              = g_fclc_project_id and
             p_task_id                 = g_fclc_task_id and
             p_parent_member_id        = g_fclc_parent_member_id and
             p_resource_list_member_id = g_fclc_resource_list_member_id and
             g_r_funds_control_level_code is not null then
            l_r_funds_control_level_code := g_r_funds_control_level_code;
          else
         	OPEN res_fcl;
         	FETCH res_fcl INTO l_r_funds_control_level_code;
	 	IF res_fcl%NOTFOUND then
		        /* Bug 5631763 */
		      If g_Rfund_control_level = 'D' then
		        OPEN c_res_resgrp_no_bc (p_resource_list_member_id) ;
			FETCH c_res_resgrp_no_bc INTO l_r_funds_control_level_code;
			CLOSE c_res_resgrp_no_bc;
                      else
		        l_r_funds_control_level_code := g_Rfund_control_level;
                      end if;
               	      /* Bug 5631763 */
         	END IF;

         	CLOSE res_fcl;
		--Bug 5964934
            g_fclc_budget_version_id           := p_budget_version_id;
            g_fclc_project_id                  := p_project_id;
            g_fclc_task_id                     := p_task_id;
            g_fclc_parent_member_id            := p_parent_member_id;
            g_fclc_resource_list_member_id     := p_resource_list_member_id;
            g_r_funds_control_level_code       := nvl(l_r_funds_control_level_code,'N');
          end if;
          --Bug 5964934
          if p_budget_version_id = g_fclc_budget_version_id and
             p_project_id        = g_fclc_project_id and
             p_task_id           = g_fclc_task_id and
             p_parent_member_id  = g_fclc_parent_member_id and
             g_rg_funds_control_level_code is not null then
            l_rg_funds_control_level_code := g_rg_funds_control_level_code;
          else

            	OPEN res_grp_fcl;
            	FETCH res_grp_fcl INTO l_rg_funds_control_level_code;
	    	IF res_grp_fcl%NOTFOUND then
		      /* Bug 5631763 */
		      If g_RGfund_control_level = 'D' then
		         If p_parent_member_id IS NOT NULL then
		           OPEN c_res_resgrp_no_bc (p_parent_member_id);
			   FETCH c_res_resgrp_no_bc INTO l_rg_funds_control_level_code;
			   CLOSE c_res_resgrp_no_bc;
                         else
		           l_rg_funds_control_level_code := l_r_funds_control_level_code;
		         end if;
                      else
		        l_rg_funds_control_level_code := g_RGfund_control_level;
                      end if;
		      /* Bug 5631763 */
            	END IF;
            	CLOSE res_grp_fcl;

	 --Bug 5964934
            g_fclc_budget_version_id           := p_budget_version_id;
            g_fclc_project_id                  := p_project_id;
            g_fclc_task_id                     := p_task_id;
            g_fclc_parent_member_id            := p_parent_member_id;
            g_rg_funds_control_level_code      := nvl(l_rg_funds_control_level_code,'N');
          end if;

	END IF;

		x_r_funds_control_level_code  :=  nvl(l_r_funds_control_level_code,'N');
		x_rg_funds_control_level_code :=  nvl(l_rg_funds_control_level_code,'N');
		x_t_funds_control_level_code :=   nvl(l_t_funds_control_level_code,'N');
		x_tt_funds_control_level_code :=  nvl(l_tt_funds_control_level_code,'N');
		x_p_funds_control_level_code :=   nvl(l_p_funds_control_level_code,'N');

		Return True;

EXCEPTION
      	WHEN OTHERS THEN
		if project_fcl%ISOPEN then
			close project_fcl;
		end if;
		if top_task_fcl%ISOPEN then
			close top_task_fcl;
		end if;
		if task_fcl%ISOPEN then
			close task_fcl;
		end if;
		if res_grp_fcl%ISOPEN then
			close res_grp_fcl;
		end if;
		if res_fcl%ISOPEN then
			close res_fcl;
		end if;
         	IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 => 'failed in funds ctrl level codeapi SQLERR :'||sqlcode||sqlerrm);
		End if;
		raise;
END funds_ctrl_level_code;

 ----------------------------------------------------------------------------------------------
 -- This api Updates pa_bc_packets with , all the details required for creating
 -- encumbrance liquidation entries and to update budget  account balances .
 -- get the following parameters budget_cc_id, encum_type_id, gl_date, gl_period etc.
 -----------------------------------------------------------------------------------------------
FUNCTION encum_detail_update
 	(p_mode          		IN    	VARCHAR2,
	 p_project_id   		IN 	NUMBER,
	 p_Task_id      		IN 	NUMBER,
	 p_Budget_version_id  		IN 	NUMBER,
	 p_Resource_list_member_id  	IN 	NUMBER,
	 p_sob_id        		IN 	NUMBER,
	 p_Period_name   		IN 	varchar2,
	 p_Expenditure_item_date  	IN 	date,
	 p_document_type  		IN 	VARCHAR2,
 	 p_ext_bdgt_type 		IN    	VARCHAR2,
	 p_ext_bdgt_link  		IN 	VARCHAR2,
	 p_bdgt_entry_level		IN      VARCHAR2,
	 p_top_task_id			IN      NUMBER,
         p_OU                           IN      NUMBER,
         p_calling_module               IN      VARCHAR2,
	 x_budget_ccid    		IN OUT NOCOPY NUMBER,
         x_budget_line_id               IN OUT NOCOPY  NUMBER,
	 x_gl_date	  		 OUT NOCOPY 	date,
	 x_pa_date	  		 OUT NOCOPY 	date,
	 x_result_code			 OUT NOCOPY    varchar2,
	 x_r_result_code  		 OUT NOCOPY 	varchar2,
	 x_rg_result_code 		 OUT NOCOPY 	varchar2,
	 x_t_result_code  		 OUT NOCOPY 	varchar2,
         x_tt_result_code  		 OUT NOCOPY 	varchar2,
	 x_p_result_code  		 OUT NOCOPY 	varchar2,
	 x_p_acct_result_code 		 OUT NOCOPY 	varchar2
	 ) return BOOLEAN IS


	l_pa_date	pa_bc_packets.pa_date%type := null;
	l_gl_date	pa_bc_packets.gl_date%type := null;
	l_budget_ccid	pa_bc_packets.budget_ccid%type := null;
	l_budget_line_id pa_bc_packets.budget_line_id%type := null;
	l_error_message_code varchar2(200) := null;
	l_return_status  varchar2(10) := 'S';
	l_gl_start_date date;


BEGIN

	-- Initialize the out NOCOPY params with null values
         --x_budget_ccid                  := null;
         x_gl_date                      := null;
         x_pa_date                      := null;
         x_result_code                  := null;
         x_r_result_code                := null;
         x_rg_result_code               := null;
         x_t_result_code                := null;
         x_tt_result_code               := null;
         x_p_result_code                := null;
         x_p_acct_result_code		:= null;
 	--- document type in AP, PO, REQ, Contract Commitments and Contract Payements
 	--- GL_DATE  is derived  from gl_period_statuses for the given period_name and period_year
 	--- get  end_date from gl_period_statuses based on period_name and period_num and period_year
 	--- for document type in Expenditures
 	--- when there is budget linked   derive GL_DATE  based on the  Expenditure Item Date
 	--- When there is No link then derive gl date based on the pa_periods
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 =>'ext bdgt link ['||p_ext_bdgt_link||']document type['||p_document_type||']');
	End if;
        If p_mode NOT in ('B','S')  then  -- and p_ext_bdgt_link = 'Y'  then
	      BEGIN

		    If  p_document_type <> 'EXP' THEN
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'selecting gl date');
			End if;
			SELECT gl.end_date,
				gl.start_date
			INTO  l_gl_date,l_gl_start_date
			FROM  gl_period_statuses gl
			WHERE gl.application_id = 101
			AND   gl.set_of_books_id = p_sob_id
			AND   gl.period_name  = p_period_name
			AND   gl.closing_status in ('O','F');
			IF g_debug_mode = 'Y' THEN
		        	log_message(p_msg_token1 =>'gl_end date = '||l_gl_date||' gl start date ='||l_gl_start_date);
			End if;
                        /** pagl date derivation logic for the Funds check process
                         *  get the pa date for the expenditure item date. expenditure item date is treated
                         *  as transaction date even though we have accounting date entered in invoice.
                         *  so that the transaction date as close as to the accounting date
                         *  If ei_date is between gl.start and gl.end dates then
                         *     gl_date := ei_date
                         *  elsif ei_date > gl.end_date then
                         *     gl_date := gl.end_date
                         *  elsif ei_date < gl.start_date then
                         *     gl_date := gl.start_date
                         *  end if;
                         **/
                        If trunc(p_Expenditure_item_date) >=  trunc(l_gl_start_date) and
                           trunc(p_Expenditure_item_date) <=  trunc(l_gl_date) then
			    /** if the profile option is set then transaction date is gl date otherwise
                             *  gl end date is the gl date
                             **/
			     IF nvl(fnd_profile.value_specific('PA_EN_NEW_GLDATE_DERIVATION'),'N') = 'Y' THEN
                                l_gl_date := p_Expenditure_item_date;
                             ELSE
				l_gl_date := l_gl_date;
			     END IF;
                        Elsif trunc(p_Expenditure_item_date) > trunc(l_gl_date) then
                                l_gl_date := l_gl_date;
                        Elsif trunc(p_Expenditure_item_date) < trunc(l_gl_start_date)  then
                                l_gl_date := l_gl_start_date;
                        End if;
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 =>'after pagl derivation gl_end date = '
                                             ||l_gl_date||' gl start date ='||l_gl_start_date);
			End if;

			--for document type EXP gl date and pa date are derived while
			-- inserting records into pa_bc_packets
			-- get the gl start date from gl_period_status for getting the budget ccid

		    Elsif p_document_type = 'EXP' THEN
                        SELECT gl.start_date
                        INTO  l_gl_start_date
                        FROM  gl_period_statuses gl
			WHERE gl.application_id = 101
                        AND   gl.set_of_books_id = p_sob_id
                        AND   gl.period_name  = p_period_name;
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 =>'gl start date['||l_gl_start_date||']gl_date['||l_gl_date||']' );
			End if;

		    End if;
		    	x_gl_date := l_gl_date;
	      EXCEPTION
	  	    WHEN NO_DATA_FOUND THEN
		  	IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'GL date not found ');
			End if;
			-- Error msg : 'F134 = Start or End date is null for GL period
                        x_result_code := 'F134';
                        x_r_result_code := 'F134';
                        x_rg_result_code := 'F134';
                        x_t_result_code := 'F134';
                        x_tt_result_code := 'F134';
                        x_p_result_code  := 'F134';
                        x_p_acct_result_code := 'F134';
			 RETURN false;
		    WHEN OTHERS THEN
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'exeption in GL date finding'||sqlcode||sqlerrm);
			End if;
			--raise;
	      END ;

	Elsif p_mode in ('B', 'S') and p_ext_bdgt_link = 'Y'  then
                /** get the gl_start_date to get the budget_ccid**/
		BEGIN
                        SELECT gl.end_date,
                                gl.start_date
                        INTO  l_gl_date,l_gl_start_date
                        FROM  gl_period_statuses gl
                        WHERE gl.application_id = 101
                        AND   gl.set_of_books_id = p_sob_id
                        AND   gl.period_name  = p_period_name;
                        x_gl_date := l_gl_start_date;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				IF g_debug_mode = 'Y' THEN
                        		log_message(p_msg_token1 =>'GL date not found ');
				End if;
                        -- Error msg : 'F134 = Start or End date is null for GL period
                        x_result_code := 'F134';
                        x_r_result_code := 'F134';
                        x_rg_result_code := 'F134';
                        x_t_result_code := 'F134';
                        x_tt_result_code := 'F134';
                        x_p_result_code  := 'F134';
                        x_p_acct_result_code := 'F134';
                         RETURN false;
			WHEN OTHERS THEN
				raise;
		END;

	End if;

        -- If the budget is not linked and document type is exp then
        -- derive the pa_date based on the gl date
        If p_mode not IN ('B','S')  then  --and p_ext_bdgt_link <> 'Y' and
	      --p_document_type in ( 'EXP','AP','REQ','PO','CC_C_PAY','CC_P_PAY') then
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'Selecting pa date');
		End if;

	     IF p_document_type <> 'EXP' then

               	BEGIN
                        /** pa_gl_date derivation logic
                         *  for deriving the pa date call the
                         *  centralized api pa_utils.get_pa_date by passing
                         *  expenditure_item_date as the transaction date
                         * the below lines are commented out NOCOPY
                        SELECT end_date
                        INTO  l_pa_date
                        FROM pa_periods
                        WHERE --(gl_period_name = p_period_name
                                --OR
                                trunc(l_gl_date)  between start_date and end_date
                                --)
                        AND status in ('O','F') ;
                        **/

                        l_pa_date := pa_utils2.get_pa_date
                                     (p_Expenditure_item_date,NULL,p_OU);

                        If l_pa_date is null then
                                x_result_code := 'F130';
                        End if;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'pa_date = '||l_pa_date);
			End if;
			x_pa_date := l_pa_date;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1 =>'pa date not found ');
				End if;
				--Error msg : 'F130 = Start or End Date is null for PA periods';
                                x_result_code := 'F130';
                                x_r_result_code := 'F130';
                                x_rg_result_code := 'F130';
                                x_t_result_code := 'F130';
                                x_tt_result_code := 'F130';
                                x_p_result_code  := 'F130';
                                x_p_acct_result_code := 'F130';
			     RETURN false;

			WHEN OTHERS THEN
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1 =>'exception in pa date finding');
				End if;
				Raise;

                END;
             Elsif p_document_type = 'EXP' then				/* Changes Start for Bug 6042137 */
 	         BEGIN
			 l_pa_date := pa_utils2.get_pa_date
                                       (p_Expenditure_item_date,NULL,p_OU);
                          If l_pa_date is null then
                                 x_result_code := 'F130';
                         End if;
                         IF g_debug_mode = 'Y' THEN
                                 log_message(p_msg_token1 =>'pa_dater = '||l_pa_date);
                         End if;
                         x_pa_date := l_pa_date;
                 EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                                 IF g_debug_mode = 'Y' THEN
                                         log_message(p_msg_token1 =>'pa date not found ');
                                 End if;
                                 --Error msg : 'F130 = Start or End Date is null for PA periods';
                                 x_result_code := 'F130';
                                 x_r_result_code := 'F130';
                                 x_rg_result_code := 'F130';
                                 x_t_result_code := 'F130';
                                 x_tt_result_code := 'F130';
                                 x_p_result_code  := 'F130';
                                 x_p_acct_result_code := 'F130';
                              RETURN false;
                          WHEN OTHERS THEN
                                 IF g_debug_mode = 'Y' THEN
                                         log_message(p_msg_token1 =>'exception in pa date finding');
                                 End if;
                                 Raise;
                  END;							/* Changes End for Bug 6042137 */
	    End if;

        End if;

      -- Derive budget ccid in all other modes except budget baseline and commitment fund check
      -- During budget baseline: account level FC is executed during FC tieback ..
      -- Budget_ccid for txn. will be derived in tieback as budget lines are not visible here ...
      -- During commitment fund scheck, budget ccid and line id is derived upfront ..

      --If p_mode <> 'B' then
      If p_calling_module in ('DISTBTC','DISTERADJ','CBC','EXPENDITURE','DISTCWKST','DISTVIADJ' ,'TRXIMPORT') then

        -- get budget_code_combination_id from pa_budget_lines
        -- for the given budget_version_id,project_id,task_id and resource list member id
        -- get the resource assignment_id from pa_resource_assignments
        -- get the budget_code_combination_id from  pa_budget_lines  for the
        -- given resource assignment id and start date of the gl period
	IF p_ext_bdgt_link = 'Y' then
	     IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 =>'Calling Budget ccid api In parameters are'||
		']p_project_id ['||p_project_id||']p_task_id ['||p_task_id||'p_start date['||l_gl_start_date||
		']p_top_task_id ['||p_top_task_id||'budgt by ['||p_bdgt_entry_level||
		']rlmi ['||p_resource_list_member_id||']p_budget_version_id ['||p_budget_version_id ||']' );
	     End if;

	   	PA_FUNDS_CONTROL_UTILS.Get_Budget_CCID (
                 p_project_id 		=> p_project_id,
                 p_task_id    		=> p_task_id,
                 p_res_list_mem_id 	=> p_resource_list_member_id,
                 --p_period_name  	=> p_period_name,
		 p_start_date		=> l_gl_start_date,
                 p_budget_version_id 	=> p_budget_version_id,
		 p_top_task_id		=> p_top_task_id,
		 p_entry_level_code     => p_bdgt_entry_level,
                 x_budget_ccid  	=> l_budget_ccid,
                 x_budget_line_id       => l_budget_line_id,
                 x_return_status 	=> l_return_status,
                 x_error_message_code 	=> l_error_message_code);
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'After Budget ccid apiBudget ccid ['||l_budget_ccid||']' );
		End if;

	   	If  l_budget_ccid is NULL then
			--Error msg : 'F132 = Transaction Failed at Budget CCID setup';
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'Assigning F132 for the result code');
			End if;
                    	x_result_code := 'F132';
                    	x_r_result_code := 'F132';
                    	x_rg_result_code := 'F132';
                    	x_t_result_code := 'F132';
                    	x_tt_result_code := 'F132';
		    	x_p_result_code  := 'F132';
		    	x_p_acct_result_code := 'F132';
			return false;
	   	End if;

		x_budget_ccid := l_budget_ccid;
                x_budget_line_id := l_budget_line_id;

	End if; -- IF p_ext_bdgt_link = 'Y' then
      End If; -- If p_mode <> 'B' then


	RETURN TRUE;
EXCEPTION
	WHEN OTHERS THEN
		 --x_status_code := 'T';
		  --Return False;
		Raise;

END encum_detail_update;

-----------------------------------------------------------------------------
-- This Api updates the pa_bc_packets with funds check setup parameters
-- like resource list member id, top task id,and encumbrance details
----------------------------------------------------------------------------
PROCEDURE update_pkts(p_packet_id  number) IS

        PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
              FORALL i IN g_tab_rowid.FIRST .. g_tab_rowid.LAST
                        UPDATE pa_bc_packets
                        SET parent_resource_id = nvl(g_tab_p_resource_id(i),parent_resource_id),
                        bud_task_id = nvl(g_tab_bud_task_id(i) ,bud_task_id) ,
                        bud_resource_list_member_id = nvl(g_tab_bud_rlmi(i) ,bud_resource_list_member_id),
                        top_task_id  = nvl(g_tab_tt_task_id(i) ,top_task_id),
                        r_funds_control_level_code = nvl(g_tab_r_fclevel_code(i),r_funds_control_level_code),
                        rg_funds_control_level_code =nvl( g_tab_rg_fclevel_code(i),rg_funds_control_level_code),
                        t_funds_control_level_code = nvl(g_tab_t_fclevel_code(i), t_funds_control_level_code),
                        tt_funds_control_level_code = nvl(g_tab_tt_fclevel_code(i),tt_funds_control_level_code),
                        p_funds_control_level_code = nvl(g_tab_p_fclevel_code(i),p_funds_control_level_code),
                        result_code = nvl(g_tab_result_code(i)  ,result_code),
                        res_result_code = nvl(g_tab_r_result_code(i) ,res_result_code),
                        res_grp_result_code = nvl(g_tab_rg_result_code(i),res_grp_result_code) ,
                        task_result_code = nvl(g_tab_t_result_code(i),task_result_code),
                        top_task_result_code = nvl(g_tab_tt_result_code(i), top_task_result_code),
                        project_result_code = nvl(g_tab_p_result_code(i),project_result_code),
                        project_acct_result_code = nvl(g_tab_p_acct_result_code(i),project_acct_result_code),
                        budget_ccid = nvl(budget_ccid,g_tab_budget_ccid(i)),
			budget_line_id = nvl(budget_line_id,g_tab_budget_line_id(i)),
		        burden_method_code = nvl(burden_method_code,g_tab_burden_method_code(i)),
			txn_ccid    = nvl(g_tab_trxn_ccid(i),txn_ccid),
                        effect_on_funds_code = nvl(g_tab_effect_fclevel(i), effect_on_funds_code),
                        proj_encumbrance_type_id = nvl(g_tab_encum_type_id(i) ,proj_encumbrance_type_id),
                        gl_date = nvl(g_tab_gl_date(i),gl_date),
                        pa_date =nvl( g_tab_pa_date(i),pa_date),
			ext_bdgt_flag = nvl(g_tab_ext_bdgt_link(i),ext_bdgt_flag),
			fc_start_date = nvl(g_tab_start_date(i),fc_start_date),
			fc_end_date = nvl(g_tab_end_date(i),fc_end_date)
                        WHERE packet_id = p_packet_id
                        AND  rowid  = g_tab_rowid(i);

		commit; -- to end an autonomous transaction
		return;

EXCEPTION
	WHEN OTHERS THEN
		g_return_status := 'T';
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 => 'Failed in update_pkts api SQLERR'||sqlerrm||sqlcode);
		End if;
		RAISE;
END  update_pkts;
------------------------------------------------------------------------------------
/* PAM Changes: calling new resource mapping api for performance improvement*/
------------------------------------------------------------------------------------
PROCEDURE DERIVE_RLMI
	( p_packet_id   IN pa_bc_packets.packet_id%type,
          p_mode        IN  varchar2,
          p_sob         IN NUMBER,
          p_reference1  IN varchar2 default null,
          p_reference2  IN varchar2 default null,
	  p_calling_module IN varchar2 default 'GL'
        ) IS

	PRAGMA AUTONOMOUS_TRANSACTION;

	Cursor cur_rlmi_details IS
                        SELECT  pbc.rowid,
                                pbc.budget_version_id,
                                pbc.project_id,
                                pbc.task_id,
                                pbc.document_type,
                                pbc.document_header_id,
                                pbc.expenditure_organization_id,
                                pbc.expenditure_type,
                                TYPE.expenditure_category,
                                TYPE.revenue_category_code,
				/* bug fix: 3700261 NVL ( ei.system_linkage_function, 'VI' ) */
                                decode(pbc.document_type,'EXP',NVL ( ei.system_linkage_function, 'VI' ),'VI')
                                        system_linkage_function,
                                pm.categorization_code resource_category_code,
                                pbc.parent_bc_packet_id,
                                pm.entry_level_code ,
				pbc.period_name,
				pbc.expenditure_item_date,
				pbc.bc_packet_id,
                                pbc.org_id exp_org_id,
				pp.org_id  proj_org_id,
				pbc.document_line_id,
				bv.resource_list_id,
				pbc.vendor_id
                        FROM    pa_bc_packets  pbc,
				pa_projects_all pp,
                                pa_budget_versions bv,
                                pa_budget_entry_methods pm,
                                pa_expenditure_types type,
                                pa_expenditure_items_all ei
                        WHERE pbc.packet_id = p_packet_id
			AND pp.project_id = pbc.project_id
			AND bv.project_id = pp.project_id
                        AND pbc.budget_version_id = bv.budget_version_id
                        AND bv.budget_entry_method_code = pm.budget_entry_method_code
                        AND pbc.expenditure_type = TYPE.expenditure_type(+)
                        AND pbc.document_header_id = ei.expenditure_item_id(+)
			AND pbc.status_code in ('P','L','I')
			AND substr(nvl(pbc.result_code,'P'),1,1) not in ('R','F')
                        ORDER BY  /** Bug fix :2004139 order by clause is changed to column names **/
                            pbc.project_id,
                            pbc.budget_version_id,
                            pm.entry_level_code ,
                            pm.categorization_code,
                            pbc.task_id,
                            pbc.expenditure_type,
                            pbc.document_type,
                            pbc.document_header_id,
                            ei.system_linkage_function ;
                                        --1,2,3,4,5,10,6,8,7;

	-- Declare local variables to hold values and use one level cache
	l_counter                               NUMBER := 0;
	l_return_status				VARCHAR2(10);
 	l_status_code    			VARCHAR2(10);
        l_result_code          			VARCHAR2(10);
	l_cache_project_id			NUMBER;
        l_cache_task_id                         NUMBER;
	l_cache_bdgt_version_id		        NUMBER;
        l_res_list_id                          	NUMBER;
	l_cache_res_list_id			NUMBER;
	l_cache_exp_org_id			NUMBER;
        l_job_id                               	NUMBER;
        l_cache_job_id                         	NUMBER;
        l_vendor_id                             NUMBER;
        l_cache_vendor_id                       NUMBER;
	l_cache_exp_type			VARCHAR2 ( 30 );
        l_non_labor_resource            	VARCHAR2 ( 80 );
        l_non_labor_resource_org_id     	NUMBER;
	l_cache_non_lab_res_org                 NUMBER;
	l_cache_non_lab_res                     VARCHAR2 ( 80 );
        l_cache_sys_link_func               	VARCHAR2 ( 30 );
        l_cache_doc_type                 	VARCHAR2 ( 10 );
        l_cache_doc_header_id			NUMBER;
	l_non_cat_rlmi                          NUMBER;
	l_cache_non_cat_rlmi                    NUMBER;
	l_person_id                             NUMBER;
	l_cache_person_id                       NUMBER;
        l_error_stage                           VARCHAR2 ( 2000 ):= NULL;
        l_error_code                            NUMBER;
	l_cache_category_code			VARCHAR2(30);
	l_cache_entry_level_code                VARCHAR2(10);
	l_error_msg				VARCHAR2(2000);
	l_cache_res_list_result_code            VARCHAR2(10);
	l_cache_non_cat_bdgt_ver_id             Number;
	l_cache_non_cat_result_code             VARCHAR2(30);
	l_fc_utils2_cwk_rlmi                    NUMBER;

	l_tab_resmap_list_id                    PA_PLSQL_DATATYPES.IDTABTYP;
	l_tab_resmap_project_id                 PA_PLSQL_DATATYPES.IDTABTYP;
	l_tab_resmap_pkt_line_type              PA_PLSQL_DATATYPES.CHAR50TABTYP;
	----------------------------------------------------------------------------------------
	--       If resource list is setup without resource groups and the
	--       resources are setup as expenditure categories, Funds check
	--       fail due to a resource mapping error.
	-------------------------------------------------------------------------------------
	CURSOR get_non_cat_rlmi(v_bdgt_ver_id NUMBER) IS
 		SELECT resource_list_member_id
		FROM pa_bc_balances gb
		WHERE gb.budget_version_id = v_bdgt_ver_id
		AND balance_type = 'BGT'
		AND ROWNUM = 1;

        CURSOR get_req_vend(v_doc_header_id  NUMBER) IS
		SELECT line.vendor_id
		FROM po_requisition_lines line,
			po_requisition_headers req
		WHERE line.requisition_header_id = req.requisition_header_id
		AND  req.requisition_header_id = v_doc_header_id ;


	CURSOR get_po_vend(v_doc_header_id  NUMBER) IS
		SELECT head.vendor_id
		FROM po_headers_all head
		WHERE head.po_header_id =  v_doc_header_id;


	CURSOR get_ap_vend(v_doc_header_id  NUMBER)  IS
		SELECT head.vendor_id
		FROM ap_invoices_all head
		WHERE  head.invoice_id = v_doc_header_id;

	CURSOR get_igc_vend(v_doc_header_id  NUMBER) IS
		SELECT head.vendor_id
		FROM igc_cc_headers_all head
		WHERE  head.cc_header_id = v_doc_header_id;

	CURSOR get_exp_details(v_doc_header_id  NUMBER) IS
		SELECT  EXP.incurred_by_person_id,
			item.job_id
		FROM pa_expenditures_all exp,
			pa_expenditure_items_all item
		WHERE  item.expenditure_item_id = v_doc_header_id
		AND item.expenditure_id = EXP.expenditure_id;

	CURSOR get_non_usg_exp_details(v_doc_exp_type VARCHAR2) IS
		SELECT tp.attribute2,
			tp.attribute3
		FROM pa_expenditure_types tp
		WHERE  tp.expenditure_type = v_doc_exp_type;

	CURSOR get_usg_exp_details(v_doc_header_id  NUMBER) IS
		SELECT  EXP.incurred_by_person_id,
			item.job_id,
			item.non_labor_resource,
			item.organization_id
		FROM pa_expenditures_all exp,
			pa_expenditure_items_all item
		WHERE  item.expenditure_item_id = v_doc_header_id
		AND item.expenditure_id = EXP.expenditure_id;

	CURSOR cur_resList IS
		SELECT distinct bv.resource_list_id
         		,bv.budget_version_id
			,bv.project_id
			,NVL(pm.categorization_code,'N') resource_category_code
		FROM pa_budget_versions bv
			,pa_budget_entry_methods pm
			,pa_bc_packets pkt
		WHERE pkt.packet_id = p_packet_id
		AND  bv.budget_version_id = pkt.budget_version_id
		AND  substr(nvl(pkt.result_code,'P'),1,1) <> ('F')
		AND  pkt.status_code in ('P','L','I')
		AND  bv.budget_entry_method_code = pm.budget_entry_method_code
		;

	CURSOR cur_cwkRlmi IS
                SELECT  pkt.bc_packet_id
			 ,pkt.project_id
			,pkt.task_id
			,pkt.budget_version_id
			,pkt.document_type
			,pkt.document_header_id
			,pkt.document_distribution_id
			,pkt.document_line_id
                        ,pkt.expenditure_type
			,pkt.resource_list_member_id
			,decode(NVL(pt.burden_amt_display_method,'N'),'D'
				,decode(parent_bc_packet_id,NULL,'RAW','BURDEN'),'RAW') pkt_line_type
		FROM pa_bc_packets pkt
		     ,pa_project_types_all pt
		     ,pa_projects_all pp
		WHERE pkt.packet_id = p_packet_id
                AND   pkt.document_line_id is not null
                AND   pkt.document_type in ('PO','EXP')
                ANd   NVL(pkt.summary_record_flag,'N') <> 'Y'
                AND   substr(nvl(pkt.result_code,'P'),1,1) <> 'F'
		ANd   pkt.status_code in ('P','L','I')
		AND   pp.project_id = pkt.project_id
		AND   pp.project_type = pt.project_type
		and   pt.org_id = pp.org_id ;


BEGIN

        -- Initialize the error stack
        PA_DEBUG.init_err_stack('PA_FUNDS_CONTROL_PKG.Derive_rlmi');
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'inside the fundscheck derive rlmi');
	End if;
	-- initialize the pl/sql talbes
	Init_plsql_tabs;

	l_counter := 0;

	FOR i IN cur_rlmi_details LOOP
		l_counter := l_counter + 1;

		<<START_OF_RLMI>>
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'category['||i.resource_category_code ||
					']bc packet id['||i.bc_packet_id||']resList['||i.resource_list_id||']' );
		End if;
               	IF i.resource_category_code  = 'R' THEN
			-- use one level cache to derive the values and then store in plsql tabls
			-- derive all other input params required for rlmi api.
			IF i.resource_list_id  is NOT NULL Then

                                ---USE one level cache for storing the values and if values are same the
                                -- skip the process continue to process the next set of records
                                  If (l_cache_sys_link_func is NULL OR
                                        i.system_linkage_function  <> l_cache_sys_link_func)OR
                                     (l_cache_doc_header_id is NULL OR
                                        i.document_header_id <> l_cache_doc_header_id)  OR
                                     (l_cache_doc_type is NULL OR
                                        i.document_type <> l_cache_doc_type)OR
                                     (l_cache_exp_type  is NULL OR
                                        i.expenditure_type  <> l_cache_exp_type)OR
                                     (l_cache_task_id  is NULL OR
                                        i.task_id  <> l_cache_task_id) OR
                                     (l_cache_exp_org_id  is NULL OR
                                        i.expenditure_organization_id <> l_cache_exp_org_id) THEN

                                        l_job_id                := NULL;
                                        l_non_labor_resource    := NULL;
                                        l_non_labor_resource_org_id := NULL;
                                        l_person_id             := NULL;
                                        l_vendor_id             := i.vendor_id;

					IF g_debug_mode = 'Y' THEN
						log_message(p_msg_token1 => 'deriving INPUT PARAMETERS FOR RESOURCE MAPPING');
					End if;

					-- -----------------VENDOR ID--------------------------+
                                        IF l_vendor_id is null THEN -- it will not be null for AP/PO/REQ FC

                                          IF ( i.system_linkage_function  = 'VI' AND i.document_type = 'REQ' ) THEN

						OPEN get_req_vend(i.document_header_id);
						FETCH get_req_vend INTO l_vendor_id;
						CLOSE get_req_vend;

                                          ELSIF ( i.system_linkage_function  = 'VI' AND i.document_type = 'PO' ) THEN

                                                OPEN get_po_vend(i.document_header_id);
                                                FETCH get_po_vend INTO l_vendor_id;
                                                CLOSE get_po_vend;

                                          ELSIF ( i.system_linkage_function  = 'VI' AND i.document_type = 'AP' ) THEN

                                                OPEN get_ap_vend(i.document_header_id);
                                                FETCH get_ap_vend INTO l_vendor_id;
                                                CLOSE get_ap_vend;

                                          ELSIF   ( i.system_linkage_function  = 'VI' AND i.document_type IN
                                                  ( 'CC_C_PAY','CC_P_PAY','CC_C_CO','CC_P_CO','CC','CP'))  THEN

                                                OPEN get_igc_vend(i.document_header_id);
                                                FETCH get_igc_vend INTO l_vendor_id;
                                                CLOSE get_igc_vend;
					  END IF;

				        END IF; ---IF l_vendor_id is null THEN
					-- -----------------VENDOR ID--------------------------+

                                          IF (  i.system_linkage_function IN ('ER','ST','OT') AND
                                                 i.document_type  = 'EXP' )THEN
							OPEN get_exp_details(i.document_header_id);
							FETCH get_exp_details INTO
								l_person_id
								,l_job_id;
							CLOSE get_exp_details;
                                          ELSIF ( i.system_linkage_function  = 'USG' ) THEN
						IF i.document_type <> 'EXP' Then
							OPEN get_non_usg_exp_details(i.expenditure_type);
							FETCH get_non_usg_exp_details INTO
                                                            l_non_labor_resource,
                                                            l_non_labor_resource_org_id;
							CLOSE get_non_usg_exp_details;

                                          ELSIF  i.document_type  = 'EXP' THEN
                                                        OPEN get_usg_exp_details(i.document_header_id);
							FETCH get_usg_exp_details INTO
                                                        	l_person_id,
                                                                l_job_id,
                                                                l_non_labor_resource,
                                                                l_non_labor_resource_org_id;
                                                        CLOSE get_usg_exp_details;

                                                END IF;
                                        END IF; -- end of INPUT PARAMETERS

					l_cache_sys_link_func := i.system_linkage_function;
                                        l_cache_doc_header_id := i.document_header_id;
                                     	l_cache_doc_type      := i.document_type;
                                     	l_cache_exp_type      := i.expenditure_type;
                                        l_cache_task_id       := i.task_id;
                                     	l_cache_exp_org_id    := i.expenditure_organization_id;
					l_cache_person_id     := l_person_id;
					l_cache_job_id        := l_job_id;
					l_cache_non_lab_res   :=l_non_labor_resource;
					l_cache_non_lab_res_org := l_non_labor_resource_org_id;
					l_cache_vendor_id     := l_vendor_id;
				ELSE
					--retrive from cache
					l_person_id := l_cache_person_id;
					l_job_id    := l_cache_job_id;
					l_non_labor_resource := l_cache_non_lab_res;
					l_non_labor_resource_org_id := l_cache_non_lab_res_org;
					l_vendor_id := l_cache_vendor_id;


				END IF;
			END IF ; -- end of resouce list is not null

                 ELSE  -- budget is not categorized by resource
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'Not Categorized by resouce ');
			End if;
			l_result_code := NULL;
			IF (l_cache_non_cat_bdgt_ver_id is null or i.budget_version_id <> l_cache_non_cat_bdgt_ver_id ) then
				OPEN get_non_cat_rlmi(i.budget_version_id);
				FETCH get_non_cat_rlmi INTO l_non_cat_rlmi;
				IF get_non_cat_rlmi%NOTFOUND OR l_non_cat_rlmi IS NULL THEN
                                      	l_result_code           := 'F128';
				END IF;
				CLOSE get_non_cat_rlmi;
				l_cache_non_cat_bdgt_ver_id := i.budget_version_id;
				l_cache_non_cat_rlmi := l_non_cat_rlmi ;
				l_cache_non_cat_result_code := l_result_code;
			ELSE -- retriev from cache
				l_non_cat_rlmi := l_cache_non_cat_rlmi;
				l_result_code := l_cache_non_cat_result_code;
			END IF;

       		END IF; -- end if for category

		-- Assign all the local values to plsql tables
                g_tab_budget_version_id(l_counter) := i.budget_version_id;
                g_tab_project_id(l_counter) 	:= i.project_id;
                g_tab_task_id(l_counter) 	:= i.task_id;
                g_tab_doc_type(l_counter) 	:= i.document_type;
                g_tab_doc_header_id(l_counter) 	:= i.document_header_id;
		g_tab_doc_line_id(l_counter)    := i.document_line_id;
                g_tab_exp_org_id(l_counter) 	:= i.expenditure_organization_id;
                g_tab_exp_type(l_counter) 	:= i.expenditure_type;
                g_tab_exp_category(l_counter) 	:= i.expenditure_category;
                g_tab_rev_category(l_counter) 	:= i.revenue_category_code;
                g_tab_sys_link_func(l_counter) 	:= i.system_linkage_function;
                g_tab_category_code(l_counter) 	:= i.resource_category_code;
                g_tab_p_bc_packet_id(l_counter) :=i.parent_bc_packet_id;
                g_tab_entry_level_code(l_counter):= i.entry_level_code;
                g_tab_period_name(l_counter) 	:= i.period_name;
                g_tab_exp_item_date(l_counter) 	:= i.expenditure_item_date;
                g_tab_bc_packet_id(l_counter) 	:= i.bc_packet_id;
                g_tab_exp_OU(l_counter) 	:= i.exp_org_id;
                g_tab_proj_OU(l_counter) 	:= i.proj_org_id;
                g_tab_rlmi(l_counter) 		:= NULL;
                g_tab_non_cat_rlmi(l_counter) 	:= l_non_cat_rlmi;
                g_tab_r_list_id(l_counter) 	:= i.resource_list_id;
                g_tab_result_code(l_counter) 	:= l_result_code;
                g_tab_result_code(l_counter) 	:= l_result_code;
                g_tab_r_result_code(l_counter) 	:= l_result_code;
                g_tab_rg_result_code(l_counter) := l_result_code;
                g_tab_t_result_code(l_counter) 	:= l_result_code;
                g_tab_tt_result_code(l_counter) := l_result_code;
                g_tab_p_result_code(l_counter) 	:= l_result_code;
                g_tab_person_id(l_counter) 	:= l_person_id;
                g_tab_job_id(l_counter) 	:= l_job_id;
                g_tab_vendor_id(l_counter) 	:= l_vendor_id;
                g_tab_non_lab_res(l_counter) 	:= l_non_labor_resource;
                g_tab_non_lab_res_org(l_counter) := l_non_labor_resource_org_id;

	END LOOP;

	--insert the records into tmp table
	IF g_tab_bc_packet_id.EXISTS(1) THEN

	    BEGIN


		FOR resList in cur_resList LOOP

			IF resList.resource_category_code = 'R' Then
				-- call resource mapping api if the budget is categorized by resource
 				-- Insert the plsql values into a temp tables
   				FORALL i IN  g_tab_bc_packet_id.First ..g_tab_bc_packet_id.Last
   					Insert into PA_MAPPABLE_TXNS_TMP
    					(txn_id
             				,person_id
             				,job_id
             				,organization_id
             				,vendor_id
             				,expenditure_type
             				,event_type
             				,non_labor_resource
		             		,expenditure_category
		             		,revenue_category
		             		,non_labor_resource_org_id
		             		,event_type_classification
		             		,system_linkage_function
		             		,project_role_id
		             		,resource_list_id
		             		,system_reference1
		             		,system_reference2
					,system_reference3
             				)
		          	SELECT
		             		pa_mappable_txns_tmp_s.NEXTVAL
		             		,g_tab_person_id(i)
		             		,g_tab_job_id(i)
		             		,g_tab_exp_org_id(i)
		             		,g_tab_vendor_id(i)
		             		,g_tab_exp_type(i)
		             		,null
             				,g_tab_non_lab_res(i)
		             		,g_tab_exp_category(i)
		             		,g_tab_rev_category(i)
		             		,g_tab_non_lab_res_org(i)
		             		,null
		             		,g_tab_sys_link_func(i)
		             		,null
		             		,g_tab_r_list_id(i)
		             		,p_packet_id
		             		,g_tab_bc_packet_id(i)
					,g_tab_project_id(i)
         			FROM DUAL
		         	WHERE substr(nvl(g_tab_result_code(i),'P'),1,1) not in ('R','F')
         			AND  g_tab_r_list_id(i) = resList.resource_list_id
				AND  g_tab_budget_version_id(i) = resList.budget_version_id
			        AND  g_tab_category_code(i) = 'R' ;

			       IF sql%ROWCOUNT > 0 Then
				    COMMIT; -- so that the transactions are available in other sessions for res map
				     log_message(p_msg_token1 => 'Calling Resource mapping API for ResList['
								    ||resList.resource_list_id||']');
					-- Call the resource map api.
	        			PA_RES_ACCUMS.new_map_txns
       		  			(x_resource_list_id   => resList.resource_list_id
       		   			,x_error_stage        => l_error_stage
       		   			,x_error_code         => l_error_msg ) ;

       		/* 7531681			Update PA_BC_PACKETS pkt
       					SET (pkt.resource_list_member_id
       		     		    		,pkt.result_code
					        ,pkt.res_result_code
                                                ,pkt.res_grp_result_code
                                                ,pkt.task_result_code
                                                ,pkt.top_task_result_code
                                                ,pkt.project_result_code
                                                ,pkt.project_acct_result_code) =
							(select tmp.resource_list_member_id
       	                            		          ,decode(tmp.resource_list_member_id,NULL
							    ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
							      ,pkt.result_code)
							  ,decode(tmp.resource_list_member_id,NULL
                                                            ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                              ,pkt.result_code)
                                                          ,decode(tmp.resource_list_member_id,NULL
                                                            ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                              ,pkt.result_code)
                                                          ,decode(tmp.resource_list_member_id,NULL
                                                            ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                              ,pkt.result_code)
                                                          ,decode(tmp.resource_list_member_id,NULL
                                                            ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                              ,pkt.result_code)
                                                          ,decode(tmp.resource_list_member_id,NULL
                                                            ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                              ,pkt.result_code)
                                                          ,decode(tmp.resource_list_member_id,NULL
                                                            ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                              ,pkt.result_code)
				      		from PA_MAPPABLE_TXNS_TMP tmp
				      		where tmp.system_reference1 = pkt.packet_id
       	                               		and   tmp.system_reference2 = pkt.bc_packet_id)
       					WHERE pkt.packet_id = p_packet_id
                                        AND  EXISTS ( SELECT 'Y'
                      				FROM PA_MAPPABLE_TXNS_TMP tmp
		      				WHERE tmp.system_reference1 = pkt.packet_id
                      				AND   tmp.system_reference2 = pkt.bc_packet_id);
            7531681 */
/* 7531681 start **/
       FORALL i in g_tab_bc_packet_id.FIRST .. g_tab_bc_packet_id.LAST
       UPDATE PA_BC_PACKETS PKT SET (PKT.RESOURCE_LIST_MEMBER_ID) =
       (select TMP.RESOURCE_LIST_MEMBER_ID
        FROM
        PA_MAPPABLE_TXNS_TMP TMP
        WHERE
        TMP.SYSTEM_REFERENCE1 = p_packet_id AND
        TMP.SYSTEM_REFERENCE2 = g_tab_bc_packet_id(i))
       WHERE
         PKT.PACKET_ID = p_packet_id and
         pkt.bc_packet_id = g_tab_bc_packet_id(i)
                 AND   pkt.budget_version_id = resList.budget_version_id
                 AND   pkt.budget_version_id = g_tab_budget_version_id(i)
                 AND   g_tab_r_list_id(i) = resList.resource_list_id ;

/*  7531681 end */


				END IF;


		    END IF;

		log_message(p_msg_token1 =>'Finally one Update for Non Categoriztion Resource as wells as Failed transactions');
		FORALL i in g_tab_bc_packet_id.FIRST .. g_tab_bc_packet_id.LAST
		UPDATE pa_bc_packets pkt
		SET pkt.resource_list_member_id = decode(g_tab_category_code(i),'R',pkt.resource_list_member_id
						 ,g_tab_non_cat_rlmi(i))
		   ,pkt.result_code = decode(g_tab_category_code(i),'R'
							,decode(pkt.resource_list_member_id,NULL
					 		    ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
							       ,pkt.result_code)
					                ,decode(g_tab_non_cat_rlmi(i),NULL
					                    ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
					                       ,pkt.result_code)
                                           )
		   ,pkt.res_result_code = decode(g_tab_category_code(i),'R'
                                                       ,decode(pkt.resource_list_member_id,NULL
                                                            ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                              ,pkt.result_code)
                                                       ,decode(g_tab_non_cat_rlmi(i),NULL
                                                            ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                              ,pkt.result_code)
					  )
                  ,pkt.res_grp_result_code = decode(g_tab_category_code(i),'R'
                                                      ,decode(pkt.resource_list_member_id,NULL
                                                           ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                             ,pkt.result_code)
                                                      ,decode(g_tab_non_cat_rlmi(i),NULL
                                                          ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                            ,pkt.result_code)
                                          )
                 ,pkt.task_result_code = decode(g_tab_category_code(i),'R'
                                                      ,decode(pkt.resource_list_member_id,NULL
                                                          ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                            ,pkt.result_code)
                                                     ,decode(g_tab_non_cat_rlmi(i),NULL
                                                         ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                           ,pkt.result_code)
                                          )
                ,pkt.top_task_result_code = decode(g_tab_category_code(i),'R'
                                                     ,decode(pkt.resource_list_member_id,NULL
                                                         ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                           ,pkt.result_code)
                                                     ,decode(g_tab_non_cat_rlmi(i),NULL
                                                         ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                           ,pkt.result_code)
                                          )
                ,pkt.project_result_code = decode(g_tab_category_code(i),'R'
                                                     ,decode(pkt.resource_list_member_id,NULL
                                                        ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                          ,pkt.result_code)
                                                     ,decode(g_tab_non_cat_rlmi(i),NULL
                                                        ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                          ,pkt.result_code)
                                          )
                ,pkt.project_acct_result_code = decode(g_tab_category_code(i),'R'
                                                     ,decode(pkt.resource_list_member_id,NULL
                                                        ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                          ,pkt.result_code)
                                                     ,decode(g_tab_non_cat_rlmi(i),NULL
                                                        ,decode(substr(nvl(pkt.result_code,'P'),1,1),'P','F128',pkt.result_code)
                                                          ,pkt.result_code)
                                          )
		WHERE pkt.packet_id = p_packet_id
	        AND   pkt.bc_packet_id = g_tab_bc_packet_id(i)
		AND   pkt.budget_version_id = resList.budget_version_id
		AND   pkt.budget_version_id = g_tab_budget_version_id(i)
		AND   g_tab_r_list_id(i) = resList.resource_list_id
		 ;
	       END LOOP;

		/* delete the records from tmp table */
		DELETE FROM PA_MAPPABLE_TXNS_TMP tmp
		WHERE tmp.system_reference1 = p_packet_id;

		/* CWK labor changes update the pkts with reosurce list member ids of the summary records
		 * information on the transactions */
	       IF p_calling_module NOT IN ('CBC') Then

		     log_message(p_msg_token1 => 'Updating rlmi with summary record rlmi for Contigent Wkr transactions');
		     OPEN cur_cwkRlmi ;
		     LOOP
			-- Initialize the plsql tables
	                g_tab_bc_packet_id.delete;
                        g_tab_project_id.delete;
                        g_tab_task_id.delete;
                        g_tab_budget_version_id.delete;
                        g_tab_doc_type.delete;
                        g_tab_doc_header_id.delete;
                        g_tab_doc_distribution_id.delete;
                        g_tab_doc_line_id.delete;
                        g_tab_exp_type.delete;
                        g_tab_rlmi.delete;
			l_tab_resmap_pkt_line_type.delete;
                     FETCH cur_cwkRlmi BULK COLLECT INTO
			g_tab_bc_packet_id
                        ,g_tab_project_id
                        ,g_tab_task_id
                        ,g_tab_budget_version_id
                        ,g_tab_doc_type
                        ,g_tab_doc_header_id
                        ,g_tab_doc_distribution_id
                        ,g_tab_doc_line_id
                        ,g_tab_exp_type
                        ,g_tab_rlmi
			,l_tab_resmap_pkt_line_type  LIMIT 500;
		     pa_funds_control_pkg.log_message(p_msg_token1=>'NumOfCwkRecs['||g_tab_bc_packet_id.count||']');
		     IF NOT g_tab_bc_packet_id.EXISTS(1) THEN
			EXIT;
		     END IF;

		     FOR i IN g_tab_bc_packet_id.FIRST .. g_tab_bc_packet_id.LAST LOOP
			l_fc_utils2_cwk_rlmi := NULL;
			l_fc_utils2_cwk_rlmi := pa_funds_control_utils2.get_CWK_RLMI
                                                        (g_tab_project_id(i)
                                                        ,g_tab_task_id(i)
                                                        ,g_tab_budget_version_id(i)
                                                        ,g_tab_doc_header_id(i)
                                                        ,g_tab_doc_distribution_id(i)
                                                        ,g_tab_doc_line_id(i)
                                                        ,g_tab_doc_type(i)
                                                        ,g_tab_exp_type(i)
                                                        ,l_tab_resmap_pkt_line_type(i)
                                                        ,'FUNDS_CHECK');

			pa_funds_control_pkg.log_message(p_msg_token1=>'bcPktId['||g_tab_bc_packet_id(i)||
                                                ']pktrlmi['||g_tab_rlmi(i)||']cwkRlmi['||l_fc_utils2_cwk_rlmi||
						']pktLineType['||l_tab_resmap_pkt_line_type(i)||']');
			g_tab_rlmi(i) := NVL(l_fc_utils2_cwk_rlmi,g_tab_rlmi(i));
		    END LOOP;
		    -- Bulk update the cwkRlmi
		    FORALL i IN g_tab_bc_packet_id.FIRST .. g_tab_bc_packet_id.LAST
			UPDATE pa_bc_packets pkt
			SET   pkt.resource_list_member_id = NVL(g_tab_rlmi(i),pkt.resource_list_member_id)
			WHERE pkt.packet_id = p_packet_id
			AND   pkt.bc_packet_id = g_tab_bc_packet_id(i)
			AND   pkt.document_type in ('PO','EXP')
			ANd   NVL(pkt.summary_record_flag,'N') <> 'Y'
	        	AND   substr(nvl(pkt.result_code,'P'),1,1) <> 'F' ;
			log_message(p_msg_token1 => 'No of rows updated['||sql%rowcount||']');
		    IF cur_cwkRlmi%NOTFOUND THEN
			EXIT;
		    END IF;
	         END LOOP;
		 CLOSE cur_cwkRlmi;

	      END IF;

	     EXCEPTION
		WHEN NO_DATA_FOUND Then
			Null;
		WHEN OTHERS THEN
			RAISE;
	     END ;

	END IF;

	COMMIT;
	PA_DEBUG.reset_err_stack;

EXCEPTION
	WHEN OTHERS THEN
		RAISE;

END DERIVE_RLMI;




---------------------------------------------------------------------------------------------------
--- This api set up the resource list member id ,parent_resource_id,parent_member_id,top task id
--  bud_task_id ,funds control level codes and pa date gl date budget ccid and encumbrance type id
--  for for each record in the packet.
-----------------------------------------------------------------------------------------------------
FUNCTION  funds_check_setup
	( p_packet_id  	IN pa_bc_packets.packet_id%type,
          p_mode       	IN  varchar2,
	  p_sob 	IN NUMBER,
	  p_reference1  IN varchar2 default null,
	  p_reference2  IN varchar2 default null,
	  p_calling_module IN varchar2

    	) return boolean IS

        -- This cursor picks all the details required for resource list member id  mapping
        -- one level cache logic is used to update the pa_bc_packet table
                CURSOR   setup_details IS
                        SELECT  pbc.rowid,
                                pbc.budget_version_id,
                                pbc.project_id,
                                pbc.task_id,
                                pbc.document_type,
                                pbc.document_header_id,
                                pbc.expenditure_organization_id,
                                pbc.expenditure_type,
                                pm.categorization_code,
                                pbc.parent_bc_packet_id,
                                pm.entry_level_code ,
                                pbc.accounted_dr,
                                pbc.accounted_cr,
				pbc.period_name,
				pbc.expenditure_item_date,
				pbc.bc_packet_id,
				pbc.txn_ccid,
				pbc.old_budget_ccid,
                                pbc.org_id,
				pbc.resource_list_member_id,
				bv.resource_list_id,
				pm.time_phased_type_code,
				pb.amount_type,
				pb.boundary_code,
				pbc.set_of_books_id,
				pbc.gl_date,
                                pbc.burden_method_code,
			        --decode(pbc.burden_method_code,'S','SAME',
                                --                              'D','DIFFERENT',
                                --                              'N','NONE',
                                --                              pbc.burden_method_code) burden_method_code,
			        pbc.budget_line_id,
				pbc.budget_ccid
                        FROM    pa_bc_packets  pbc,
                                pa_budget_versions bv,
                                pa_budget_entry_methods pm,
				pa_budgetary_control_options pb
                        WHERE pbc.packet_id = p_packet_id
                        AND pbc.budget_version_id = bv.budget_version_id
                        AND bv.budget_entry_method_code = pm.budget_entry_method_code
			AND pbc.status_code in ('P','L')
			AND substr(nvl(pbc.result_code,'P'),1,1) not in ('R','F')
			AND pb.project_id = pbc.project_id
			AND pb.BDGT_CNTRL_FLAG = 'Y'
        		AND pb.BUDGET_TYPE_CODE = bv.budget_type_code
        		AND ((pbc.document_type in ('AP','PO','REQ','EXP','CC_P_PAY','CC_C_PAY')
                		and pb.EXTERNAL_BUDGET_CODE = 'GL')
                        	OR
                		(pbc.document_type in ('AP','PO','REQ','EXP','CC_P_PAY','CC_C_PAY')
                  		and pb.EXTERNAL_BUDGET_CODE is NULL)
                        	OR
                		(pbc.document_type in ('CC_P_CO','CC_C_CO')
                  		and pb.EXTERNAL_BUDGET_CODE = 'CC' )
               		    )
                        ORDER BY  /** Bug fix :2004139 order by clause is changed to column names **/
                            pbc.project_id,
                            pbc.budget_version_id,
                            pm.entry_level_code ,
                            pm.categorization_code,
                            pbc.task_id,
                            pbc.expenditure_type,
                            pbc.document_type,
                            pbc.document_header_id
				;

                /* Bug 5631763 */
                cursor c_funds_control_level(bud_version_id NUMBER) is
		    select  fund_control_level_project,
                   	    fund_control_level_task ,
                            fund_control_level_res_grp,
                            fund_control_level_res
			    from pa_budgetary_control_options pb,
			         pa_budget_versions pv
			    where  pv.project_id = pb.project_id
 			    AND    pb.BDGT_CNTRL_FLAG = 'Y'
        		    AND    pb.BUDGET_TYPE_CODE = pv.budget_type_code
			    AND    pv.budget_version_id = bud_version_id;
		/* Bug 5631763 */

	-- Declare local variables to hold values and use one level cache
	l_return_status				VARCHAR2(10);
 	l_status_code    			VARCHAR2(10);
        l_result_code          			VARCHAR2(10);
        l_r_result_code       			VARCHAR2(10);
        l_rg_result_code     			VARCHAR2(10);
        l_t_result_code     			VARCHAR2(10);
        l_tt_result_code   			VARCHAR2(10);
        l_p_result_code   			VARCHAR2(10);
        l_p_acct_result_code    		VARCHAR2(10);
	l_pre_rlmi				NUMBER;
        l_project_id                            NUMBER;
	l_pre_project_id			NUMBER;
        l_task_id                               NUMBER;
        l_pre_task_id                           NUMBER;
        l_budget_version_id             	NUMBER;
	l_pre_budget_version_id			NUMBER;
	l_pre_res_list_id			NUMBER;
        l_exp_org_id           			NUMBER;
	l_pre_exp_org_id			NUMBER;
        l_exp_type              		VARCHAR2 ( 30 );
	l_pre_exp_type				VARCHAR2 ( 30 );
        l_expenditure_type              	VARCHAR2 ( 30 );
        l_doc_type                 		VARCHAR2 ( 10 );
        l_pre_doc_type                 		VARCHAR2 ( 10 );
        l_doc_header_id				NUMBER;
        l_pre_doc_header_id			NUMBER;
        l_parent_id                            	NUMBER;
        l_error_stage                           VARCHAR2 ( 2000 ):= NULL;
        l_error_code                            NUMBER;
        l_group_by_none                 	VARCHAR2 ( 60 );
	l_num_rows				NUMBER := 200;
	l_parent_member_id			NUMBER;
	l_parent_resource_id			NUMBER;
	l_bud_rlmi				NUMBER;
	l_bud_task_id				NUMBER;
	l_top_task_id				NUMBER;
	l_trxn_ccid				NUMBER;
	l_budget_ccid				NUMBER;
        l_budget_line_id                        pa_budget_lines.budget_line_id%type;
	l_r_fclevel_code			VARCHAR2(10);
	l_rg_fclevel_code			VARCHAR2(10);
	l_t_fclevel_code			VARCHAR2(10);
	l_tt_fclevel_code			VARCHAR2(10);
	l_p_fclevel_code			VARCHAR2(10);
	l_p_acct_fclevel_code			VARCHAR2(10);
	l_effect_on_funds_code			VARCHAR2(10);
	l_pre_category_code			VARCHAR2(30);
	l_category_code				VARCHAR2(30);
	l_entry_level_code                  	VARCHAR2(10);
	l_pre_entry_level_code                  VARCHAR2(10);
	l_ext_bdgt_type				VARCHAR2(10);
 	l_ext_bdgt_link				VARCHAR2(10);
	l_encum_type_id                         NUMBER;
 	l_gl_date				DATE;
 	l_pa_date				DATE;
	l_error_msg				VARCHAR2(2000);
	l_prv_burden_method			VARCHAR2(20);
	l_burden_method				VARCHAR2(20);
	l_pre_ext_bdgt_link			VARCHAR2(20);
        l_pre_time_phase_code   		varchar2(80);
        l_pre_amount_type       		varchar2(80);
        l_pre_boundary_code     		varchar2(80);
        l_pre_fc_sdate          		Date := Null;
        l_pre_fc_edate          		Date := Null;
        l_pre_ei_date          		Date := Null; /*Bug 8562406 */
	l_trx_item_date         		Date := Null;
	l_fc_start_date                         Date := Null;
	l_fc_end_date                           Date := Null;
	l_err_buff                              VARCHAR2(2000);

	l_imp_count 			Number := 0;

BEGIN
        -- Initialize the error stack
        PA_DEBUG.init_err_stack('PA_FUNDS_CONTROL_PKG.setup');

       If p_calling_module in ('DISTBTC','DISTERADJ','CBC','EXPENDITURE','DISTCWKST','DISTVIADJ'
						    ,'TRXIMPORT','RESERVE_BASELINE') then

          -- Note: For commitment Funds check, derive_rlmi is called in pa_funds_control_pkg1
          --       R12: BC-SLA Integration ..

	  IF g_debug_mode = 'Y' THEN
             log_message(p_msg_token1 => 'inside the fundscheck setup api Calling Derive_rlmi ');
	  End if;

	  DERIVE_RLMI
          ( p_packet_id   => p_packet_id
          ,p_mode        => p_mode
          ,p_sob         => p_sob
          ,p_reference1  => p_reference1
          ,p_reference2  => p_reference2
	  ,p_calling_module => p_calling_module
          );

       End If;

	-- open cursor and fetch 200 rows at a time
	OPEN setup_details;
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'opened the cursor for setup details');
	End if;
	LOOP
		-- initialize the pl/sql talbes
		Init_plsql_tabs;

		FETCH setup_details BULK COLLECT INTO
				g_tab_rowid,
                                g_tab_budget_version_id,
                                g_tab_project_id,
                                g_tab_task_id,
                                g_tab_doc_type,
                                g_tab_doc_header_id,
                                g_tab_exp_org_id,
                                g_tab_exp_type,
                                g_tab_category_code,
                                g_tab_p_bc_packet_id,
                                g_tab_entry_level_code ,
                                g_tab_accounted_dr,
                                g_tab_accounted_cr,
				g_tab_period_name,
				g_tab_exp_item_date,
				g_tab_bc_packet_id,
				g_tab_trxn_ccid,
				g_tab_old_budget_ccid,
				g_tab_OU,
				g_tab_rlmi,
				g_tab_r_list_id,
 				g_tab_time_phase_type_code,
                                g_tab_amount_type,
                                g_tab_boundary_code,
                                g_tab_sob_id,
				g_tab_exp_gl_date,
                                g_tab_burden_method_code,
			        g_tab_budget_line_id,
				g_tab_budget_ccid
					LIMIT l_num_rows;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'Afeter fetch statements');
		End if;

		If NOT g_tab_rowid.EXISTS(1) then
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'Fetched the NO ROWS ');
			End if;
			exit;
		Else
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'Fetched the rows into plsql tables');
			End if;
			null;
		End if;

		-- for each record in derive the resource list member id, parent resource id ,
		-- bud task id , top taskid funds control level codes, budget ccid, gl date ,
		-- pa date, encumbrance type id etc.
		--
		FOR i IN g_tab_rowid.FIRST .. g_tab_rowid.LAST LOOP

                                g_tab_p_resource_id(i) := null;
                                g_tab_p_member_id(i) := null;
                                g_tab_bud_task_id(i) := null;
                                g_tab_bud_rlmi(i) := null;
                                g_tab_tt_task_id(i) := null;
                                g_tab_r_fclevel_code(i) := null;
                                g_tab_rg_fclevel_code(i) := null;
                                g_tab_t_fclevel_code(i) := null;
                                g_tab_tt_fclevel_code(i) := null;
                                g_tab_p_fclevel_code(i) := null;
                                g_tab_p_acct_fclevel_code(i) := null;
                                g_tab_status_code(i) := null;
                                g_tab_result_code(i) := null;
                                g_tab_r_result_code(i) := null;
                                g_tab_rg_result_code(i) := null;
                                g_tab_t_result_code(i) := null;
                                g_tab_tt_result_code(i) := null;
                                g_tab_p_result_code(i) := null;
				g_tab_p_acct_result_code(i) := null;
                                --g_tab_budget_ccid(i) := null;
                                g_tab_effect_fclevel(i) := null;
                                g_tab_encum_type_id(i) := null;
                                g_tab_gl_date(i) := null;
                                g_tab_pa_date(i) := null;
				g_tab_start_date(i) := null;
				g_tab_end_date(i) := null;
				g_tab_ext_bdgt_link(i) := null;

                       /* Bug 5631763 */

			g_Tfund_control_level  := NULL;
			g_Pfund_control_level  := NULL;
			g_RGfund_control_level := NULL;
			g_Rfund_control_level  := NULL;


                       OPEN c_funds_control_level(g_tab_budget_version_id(i));
		       FETCH c_funds_control_level INTO
				g_Pfund_control_level ,
				g_Tfund_control_level ,
				g_RGfund_control_level,
				g_Rfund_control_level;
		       CLOSE c_funds_control_level;

		       /* Bug 5631763 */

			<<START_OF_RLMI>>
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'category['||g_tab_category_code(i)||
					']bc packet id['||g_tab_bc_packet_id(i)||']' );
			End if;

			-- derive the budget resouce list member id , parent resource
			-- id based the resource list member id and use one level cache

			IF (l_pre_rlmi is NULL or g_tab_rlmi(i) <> l_pre_rlmi )OR
			   (l_pre_project_id is NULL or l_pre_project_id <> g_tab_project_id(i))OR
			   (l_pre_budget_version_id is NULL or l_pre_budget_version_id <>
				g_tab_budget_version_id(i) )OR
			   (l_pre_category_code is NULL or l_pre_category_code <>  g_tab_category_code(i))
				Then
				IF g_debug_mode = 'Y' THEN
				 	log_message(p_msg_token1 => 'Calling bud_res_list_id_update api ');
				End if;
			 	IF NOT bud_res_list_id_update
        			     ( p_project_id                => g_tab_project_id(i),
          			     p_budget_version_id           => g_tab_budget_version_id(i),
          			     p_resource_list_member_id     => g_tab_rlmi(i),
          			     p_categorization_code         => g_tab_category_code(i),
          			     x_bud_resource_list_member_id => l_bud_rlmi,
          			     x_parent_resource_id          => l_parent_resource_id
          			     ) Then
					IF g_debug_mode = 'Y' THEN
						log_message(p_msg_token1 =>
					  	'Failed to derive bud_rlmi and parent resource id');
					End if;
				    l_error_msg   := 'Failed to derive bud_rlmi and parent resource id';
			        END IF;
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1 => 'bud rlmi ['||l_bud_rlmi||']parent res ['||
						l_parent_resource_id||']');
				End if;

			END IF;


			-- derive the budgeted task and top task id
                        IF (l_pre_task_id is NULL or l_pre_task_id <>  g_tab_task_id(i) )OR
                           (l_pre_project_id is NULL or l_pre_project_id <> g_tab_project_id(i))OR
                           (l_pre_budget_version_id is NULL or l_pre_budget_version_id <>
                                g_tab_budget_version_id(i) )OR
                           (l_pre_entry_level_code is NULL or l_pre_entry_level_code
					 <>  g_tab_entry_level_code(i) ) Then
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1 => 'Calling bud task id  update api ');
				End if;
 				IF NOT budget_task_id_update
        				( p_project_id          => g_tab_project_id(i),
          				p_task_id               => g_tab_task_id(i),
          				p_budget_version_id     => g_tab_budget_version_id(i),
          				p_entry_level_code      => g_tab_entry_level_code(i),
          				x_bud_task_id           => l_bud_task_id,
          				x_top_task_id           => l_top_task_id
        				 )  then
					IF g_debug_mode = 'Y' THEN
						log_message(p_msg_token1 => 'Failed to derive top task and bud task ids');
					End if;
				     l_error_msg   := 'Failed to derive top task and bud task ids';
				END IF;
			END IF;


			-- Derive the effect on funds control based on the accounted dr
			-- and accounted cr
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'Calling get_fclevel_code api ');
			End if;
			IF NOT get_fclevel_code
				(p_accounted_dr  => g_tab_accounted_dr(i),
                          	p_accounted_cr   =>  g_tab_accounted_cr(i),
                          	x_effect_on_funds_code => l_effect_on_funds_code) Then
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1 => 'Failed to derive Effect on Funds control level code');
				End if;
			      l_error_msg   := 'Failed to derive Effect on Funds control level code';
			END IF;

			-- Derive the funds control level codes for each level ie resource
			-- resource group, task, top task and project level
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'Calling  funds_ctrl_level_code api ');
			End if;
			IF NOT funds_ctrl_level_code (
                		p_project_id                    => g_tab_project_id(i),
                		p_task_id                       => g_tab_task_id(i),
                		p_top_task_id                   => l_top_task_id,
                		p_parent_member_id              => l_parent_resource_id,
                		p_resource_list_member_id       => g_tab_rlmi(i),
                		p_budget_version_id             => g_tab_budget_version_id(i),
                		p_bud_task_id                   => l_bud_task_id,
                		p_categorization_code           => g_tab_category_code(i),
                		x_r_funds_control_level_code    => l_r_fclevel_code,
                		x_rg_funds_control_level_code   => l_rg_fclevel_code,
                		x_t_funds_control_level_code    => l_t_fclevel_code,
                		x_tt_funds_control_level_code   => l_tt_fclevel_code,
                		x_p_funds_control_level_code    => l_p_fclevel_code
                			) then
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1 => 'Failed to derive Funds control level codes');
				End if;
				l_error_msg   := 'Failed to derive Funds control level codes';
			END IF;

			-- check whether the budget type is STD or CBC
			IF g_tab_doc_type(i) in ('PO','REQ','AP','EXP','CC_P_PAY','CC_C_PAY') then
                                l_ext_bdgt_type := 'STD';
			ELSIF g_tab_doc_type(i) in ('CC_C_CO','CC_P_CO') then
                                l_ext_bdgt_type := 'CBC';
                        End IF;


			--check whether the project is linked or not if linked with std
			-- budget then derive all the encumbrance details
			l_ext_bdgt_link := 'N';
			IF l_pre_project_id is NULL or l_pre_project_id <> g_tab_project_id(i) then
				l_ext_bdgt_link := pa_funds_control_utils.get_bdgt_link
							( p_project_id =>g_tab_project_id(i),
                             				  p_calling_mode => l_ext_bdgt_type);
				l_pre_ext_bdgt_link := l_ext_bdgt_link;
			Else
				l_ext_bdgt_link := l_pre_ext_bdgt_link;
			End IF;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'l_ext_bdgt_link ['||l_ext_bdgt_link||']');
			End if;

			-- Dervie the encumbrance details such as gl date / pa date,
			-- budget ccid etc,
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'Period name ['||g_tab_period_name(i)||
				']exp item date ['||g_tab_exp_item_date(i)||']doc type ['|| g_tab_doc_type(i)||']');
			End if;


			   l_budget_ccid  := null;
                           l_budget_line_id := null;
			   l_gl_date      := null;
			   l_pa_date      := null;

			IF NOT encum_detail_update
        			(p_mode                         => p_mode,
         			p_project_id                    => g_tab_project_id(i),
         			p_Task_id                       => g_tab_task_id(i),
         			p_Budget_version_id             => g_tab_budget_version_id(i),
         			p_Resource_list_member_id       => g_tab_rlmi(i),
         			p_sob_id                        => p_sob,
         			p_Period_name                   => g_tab_period_name(i),
         			p_Expenditure_item_date         => g_tab_exp_item_date(i),
         			p_document_type                 => g_tab_doc_type(i),
         			p_ext_bdgt_type                 => l_ext_bdgt_type,
         			p_ext_bdgt_link                 => l_ext_bdgt_link,
				p_bdgt_entry_level              => g_tab_entry_level_code(i),
				p_top_task_id			=> l_top_task_id,
                                p_OU                            => g_tab_OU(i),
			        p_calling_module                => p_calling_module,
         			x_budget_ccid                   => l_budget_ccid,
			        x_budget_line_id                => l_budget_line_id,
         			x_gl_date                       => l_gl_date,
         			x_pa_date                       => l_pa_date,
         			x_result_code                   => l_result_code,
         			x_r_result_code                 => l_r_result_code,
         			x_rg_result_code                => l_rg_result_code,
         			x_t_result_code                 => l_t_result_code,
         			x_tt_result_code                => l_tt_result_code,
         			x_p_result_code                 => l_p_result_code,
         			x_p_acct_result_code            => l_p_acct_result_code
         			) then
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1 => 'Failed to derive Encumbrance Details ');
				End if;
				l_error_msg   := 'Failed to derive Encumbrance Details ';
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1 => 'l_budget_ccid ['||l_budget_ccid||']l_gl_date['
							||l_gl_date||']l_pa_date['||l_pa_date||']');
				End if;
				GOTO END_OF_FC_SETUP_PROCESS;

			END IF;

			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'After Encumbrance Details api');
			End if;

                        If p_calling_module not in
                           ('DISTBTC','DISTERADJ','CBC','EXPENDITURE','DISTCWKST','DISTVIADJ' ,'TRXIMPORT','RESERVE_BASELINE') then

                           l_budget_ccid    := g_tab_budget_ccid(i);
                           l_budget_line_id := g_tab_budget_line_id(i);

                        End If;

			-- check if the project type is burden on different seperate ei
			-- then update the burden line tranaction ccid with budget ccid
			log_message(p_msg_token1 => 'Update the trxn ccid for bdn lines ');

			l_trxn_ccid := g_tab_trxn_ccid(i);

                        l_burden_method := g_tab_burden_method_code(i);

                        If l_burden_method is NULL then

			  IF l_pre_project_id is NULL or l_pre_project_id <> g_tab_project_id(i) then

		             l_burden_method := check_bdn_on_sep_item (g_tab_project_id(i));
		       	     l_prv_burden_method := l_burden_method;
			  Else
		       	     l_burden_method := l_prv_burden_method;
			  End if;

                        Else

                          l_prv_burden_method := l_burden_method;

                        End If;

			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'l_burden_method ='||l_burden_method);
			End if;
			If g_tab_p_bc_packet_id(i) is NOT NULL and l_ext_bdgt_link = 'Y' then
				--IF l_burden_method  in ( 'DIFFERENT','SAME') then
				IF l_burden_method  in ( 'D','S') then
					IF g_debug_mode = 'Y' THEN
						log_message(p_msg_token1 =>'g_tab_trxn_ccid(i) ='||l_budget_ccid);
					End if;
					l_trxn_ccid := l_budget_ccid;
				End if;
			End if;

        		-- check if the budget is linked to external budget GL then
        		-- transaction ccid must equal to budget ccid  otherwise error out NOCOPY
			-- differenct cases: Burden on same ei - donot check for raw line
			-- Burden on sep ei - check trxn ccid = bdgt_ccid
			-- NO burden for ei - check trxn ccid = bdgt_ccid for raw line
			IF g_debug_mode = 'Y' THEN
        			log_message(p_msg_token1 =>'ext budget link ['||l_ext_bdgt_link||
        			']txn ccid ['||l_trxn_ccid ||']budget ccid ['||l_budget_ccid || ']' );
			End if;

        		---- If the calling mode  NOT IN  Base line  then derive encum type id
        		---  get the encum_type_id from  api get_budget_control_options for
			--- the given project_id
                        IF l_pre_project_id is NULL or l_pre_project_id <> g_tab_project_id(i) then
        			If P_mode NOT IN ('B','S') then
                			l_encum_type_id  := pa_funds_control_utils.Get_encum_type_id
                                			( p_project_id => g_tab_project_id(i),
                                 			  p_calling_mode => l_ext_bdgt_type);
					if l_encum_type_id is null and l_ext_bdgt_link = 'Y' then
					--Error msg : 'F135 = Transaction failed due to Encumbrance type is null';
                                                --l_status_code           := 'R';
                                                l_result_code           := 'F135';
                                                l_r_result_code         := 'F135';
                                                l_rg_result_code        := 'F135';
                                                l_t_result_code         := 'F135';
                                                l_tt_result_code        := 'F135';
                                                l_p_result_code         := 'F135';
                                                l_p_acct_result_code    := 'F135';
					End if;
				End if;
        		End if;

			IF substr(nvl(l_result_code,'P'),1,1) <> 'F' Then  -- result_code check

				If g_tab_time_phase_type_code(i) = 'G' Then
				      -- for document type exp pass the gl date derived by the cdls for all others
				      -- derive gl date as the end of the period name
				      If g_tab_doc_type(i) = 'EXP' Then
					l_trx_item_date := g_tab_exp_gl_date(i);
				      Else
					l_trx_item_date := nvl(l_gl_date,g_tab_exp_gl_date(i)); --Bug 5495666
				      End If;
				Elsif g_tab_time_phase_type_code(i) = 'P' Then
                                        l_trx_item_date :=  nvl(l_pa_date,g_tab_exp_item_date(i)); --Bug 5495666
				Else
                                        l_trx_item_date := g_tab_exp_item_date(i);
				End if;

           /* ========================================================================================+
              Following code is incorrect ..not required.
           -- If p_mode is 'B' and 'S', use the period_name stamped on the txn. being funds checked
           -- to get the start and end date
           -- In normal FC mode, call pa_funds_control_pkg1.setup_start_end_date to derive dates
              log_message(p_msg_token1 =>'Mode ['||p_mode||'] Period name['||g_tab_period_name(i)||']');

              If p_mode in ('B','S') then   -- Mode check
                 Begin
                   SELECT gl.start_date,gl.end_date
                   INTO   l_fc_start_date,l_fc_end_date
                   FROM  gl_period_statuses gl
                   WHERE gl.application_id  = 101
                   AND   gl.set_of_books_id = p_sob
                   AND   gl.period_name     = g_tab_period_name(i);
                  Exception
                   When no_data_found then
                       l_result_code := 'F136';
                       IF g_debug_mode = 'Y' THEN
                          log_message(p_msg_token1 =>'Mode ['||p_mode||'] Exception: No Data Found - F136');
                       END IF;
                   When too_many_rows then
                       l_result_code := 'F136';
                       IF g_debug_mode = 'Y' THEN
                          log_message(p_msg_token1 =>'Mode ['||p_mode||'] Exception: Too Many Rows - F136');
                       END IF;
                   End;

              Else  -- Mode check
             ===============================================================================================+ */

				If (l_pre_project_id is NULL or l_pre_project_id <> g_tab_project_id(i)) OR
				   (l_pre_budget_version_id is NULL or l_pre_budget_version_id <> g_tab_budget_version_id(i) ) OR
				   (l_pre_time_phase_code is NULL or l_pre_time_phase_code <> g_tab_time_phase_type_code(i)) OR
				   (l_pre_amount_type is NULL or l_pre_amount_type <> g_tab_amount_type(i)) OR
				   (l_pre_boundary_code is NULL or l_pre_boundary_code <> g_tab_boundary_code(i)) OR
				   (l_pre_fc_sdate is NULL or l_pre_fc_edate is NULL OR
				     trunc(l_trx_item_date) NOT BETWEEN l_pre_fc_sdate AND l_pre_fc_edate) OR
				     (to_char(nvl(l_pre_ei_date,g_tab_exp_item_date(i)),'YYYY')<>to_char(g_tab_exp_item_date(i),'YYYY') AND g_tab_exp_item_date(i) is not NULL ) /*Bug 8562406 */
				      THEN -- call date API
				        If g_debug_mode = 'Y' THEN
						log_message(p_msg_token1 => 'Calling pa_funds_control_pkg1.setup_start_end_date API');
					End if;

					/*PAM changes derive start and end dates */
					pa_funds_control_pkg1.setup_start_end_date (
        				p_packet_id                 => p_packet_id
        				,p_bc_packet_id             => g_tab_bc_packet_id(i)
        				,p_project_id               => g_tab_project_id(i)
        				,p_budget_version_id        => g_tab_budget_version_id(i)
        				,p_time_phase_type_code     => g_tab_time_phase_type_code(i)
        				,p_expenditure_item_date    => l_trx_item_date
        				,p_amount_type              => g_tab_amount_type(i)
        				,p_boundary_code            => g_tab_boundary_code(i)
        				,p_set_of_books_id          => g_tab_sob_id(i)
        				,x_start_date               => l_fc_start_date
	        			,x_end_date                 => l_fc_end_date
	        			,x_error_code               => l_error_code
	        			,x_err_buff                 => l_err_buff
	        			,x_return_status            => l_return_status
	        			,x_result_code              => l_result_code
					);
					If g_debug_mode = 'Y' THEN
                                           log_message(p_msg_token1 => 'End of setup_start_end_date Resultcode['||l_result_code||']');
                                        End if;

				Else --retrieve fro cache
					l_fc_start_date := l_pre_fc_sdate;
					l_fc_end_date   := l_pre_fc_edate ;
				End If; -- call date API

             --End If;  -- Mode check


			END If; -- result_code check

			IF g_debug_mode = 'Y' THEN
              log_message(p_msg_token1 =>'l_fc_start_date ['||l_fc_start_date||'] l_fc_end_date ['||l_fc_end_date||']');
			  log_message(p_msg_token1 => 'storing values in local variables');
			End if;

			---------------------------------------------------------------
                        -- store the values in local variables
                        l_pre_doc_header_id     := g_tab_doc_header_id(i) ;
                        l_pre_doc_type          := g_tab_doc_type(i) ;
                        l_pre_exp_type          := g_tab_exp_type(i) ;
                        l_pre_project_id        := g_tab_project_id(i) ;
                        l_pre_budget_version_id := g_tab_budget_version_id(i) ;
                        l_pre_task_id           := g_tab_task_id(i)  ;
                        l_pre_exp_org_id        := g_tab_exp_org_id(i) ;
                        l_pre_res_list_id       := g_tab_r_list_id(i);
                        l_pre_rlmi              := g_tab_rlmi(i);
			l_pre_entry_level_code  := g_tab_entry_level_code(i);
			l_pre_category_code     := g_tab_category_code(i);
			l_pre_time_phase_code   := g_tab_time_phase_type_code(i);
			l_pre_amount_type       := g_tab_amount_type(i);
			l_pre_boundary_code     := g_tab_boundary_code(i);
			l_pre_fc_sdate          := l_fc_start_date;
			l_pre_fc_edate          := l_fc_end_date;
			l_pre_ei_date           := g_tab_exp_item_date(i)  ; /*Bug 8562406 */
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 =>'end of storing values in local variables');
			End if;

			<< END_OF_FC_SETUP_PROCESS>>
			----------------------------------------------------------------
			-- Assign the out NOCOPY parameters to pl/sql tables
			----------------------------------------------------------------
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'assiging out NOCOPY param values to plsql tables');
			End if;
			--if the funds check is called in Forcepass mode, then after deriving
			-- all the setup parameters if there is no error then update the result code
			-- to success and donot call pa_fcp_process
			If p_mode in ('F') and substr(nvl(l_result_code,'P'),1,1) = 'P' then
				l_result_code 	 := 'P116'; -- Transaction passed funds check in forcepass mode
				l_r_result_code  := 'P116';
				l_rg_result_code := 'P116';
				l_t_result_code  := 'P116';
				l_tt_result_code := 'P116';
				l_p_result_code  := 'P116';
				l_p_acct_result_code := 'P116';
			End if;

			g_tab_p_resource_id(i)    	:= l_parent_resource_id;
        		g_tab_p_member_id(i)       	:= l_parent_member_id;
        		g_tab_bud_task_id(i)       	:= l_bud_task_id;
        		g_tab_bud_rlmi(i)          	:= l_bud_rlmi;
        		g_tab_tt_task_id(i)        	:= l_top_task_id;
        		g_tab_r_fclevel_code(i)    	:= l_r_fclevel_code;
        		g_tab_rg_fclevel_code(i)   	:= l_rg_fclevel_code;
        		g_tab_t_fclevel_code(i)    	:= l_t_fclevel_code;
        		g_tab_tt_fclevel_code(i)   	:= l_tt_fclevel_code;
        		g_tab_p_fclevel_code(i)    	:= l_p_fclevel_code;
        		g_tab_p_acct_fclevel_code(i) 	:= l_p_acct_fclevel_code;
        		g_tab_result_code(i)         	:= l_result_code;
        		g_tab_r_result_code(i)      	:= l_r_result_code;
        		g_tab_rg_result_code(i)     	:= l_rg_result_code;
        		g_tab_t_result_code(i)      	:= l_t_result_code;
        		g_tab_tt_result_code(i)     	:= l_tt_result_code;
        		g_tab_p_result_code(i)      	:= l_p_result_code;
			g_tab_p_acct_result_code(i) 	:= l_p_acct_result_code;
        		g_tab_trxn_ccid(i)          	:= l_trxn_ccid;
        		g_tab_budget_ccid(i)        	:= l_budget_ccid;
		        g_tab_burden_method_code(i)     := l_burden_method;
		        g_tab_budget_line_id(i)         := l_budget_line_id;
        		g_tab_effect_fclevel(i)     	:= l_effect_on_funds_code;
			g_tab_encum_type_id(i)		:= l_encum_type_id;
			g_tab_gl_date(i)		:= l_gl_date;
			g_tab_pa_date(i)		:= l_pa_date;
			g_tab_ext_bdgt_link(i)          := l_ext_bdgt_link;
			g_tab_start_date(i)             := l_fc_start_date;
			g_tab_end_date(i)               := l_fc_end_date;

			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'End of Assignments');
			End if;


		END LOOP;  -- end of forloop
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'After loop calling FORALL update statement');
		End if;

		-- update the pa bc pakcets in a batch of 200 records after dering the setup
		-- param values
              /*****
		log_message(p_msg_token1 => 'update bc packets for batch of 200 record ');
		for i in g_tab_rowid.FIRST .. g_tab_rowid.LAST loop
		log_message(p_msg_token1 => 'g_tab_bc_packet_id ='||g_tab_bc_packet_id(i));
		log_message(p_msg_token1 => 'g_tab_p_resource_id(i) ='||g_tab_p_resource_id(i));
		log_message(p_msg_token1 => 'g_tab_bud_task_id(i) ='||g_tab_bud_task_id(i));
		log_message(p_msg_token1 => 'g_tab_bud_rlmi(i) ='||g_tab_bud_rlmi(i));
		log_message(p_msg_token1 => 'g_tab_r_fclevel_code(i) ='||g_tab_r_fclevel_code(i));
		log_message(p_msg_token1 => 'g_tab_rg_fclevel_code(i) ='||g_tab_rg_fclevel_code(i));
		log_message(p_msg_token1 => 'g_tab_t_fclevel_code(i) ='||g_tab_t_fclevel_code(i));
		log_message(p_msg_token1 =>'g_tab_tt_fclevel_code(i) ='||g_tab_tt_fclevel_code(i));
		log_message(p_msg_token1 =>' g_tab_p_fclevel_code(i) ='||g_tab_p_fclevel_code(i));
		log_message(p_msg_token1 =>'g_tab_result_code(i) ='||g_tab_result_code(i) );
		log_message(p_msg_token1 =>'g_tab_r_result_code(i)='||g_tab_r_result_code(i));
		log_message(p_msg_token1 =>'g_tab_rg_result_code(i)='||g_tab_rg_result_code(i));
		log_message(p_msg_token1 =>'g_tab_p_result_code(i) ='||g_tab_p_result_code(i));
		log_message(p_msg_token1 =>'g_tab_p_acct_result_code(i) ='||g_tab_p_acct_result_code(i));
		log_message(p_msg_token1 =>'g_tab_effect_fclevel(i) ='||g_tab_effect_fclevel(i));
		log_message(p_msg_token1 =>'g_tab_budget_ccid(i) ='||g_tab_budget_ccid(i));
		log_message(p_msg_token1 =>'g_tab_encum_type_id(i) ='||g_tab_encum_type_id(i));
		log_message(p_msg_token1 =>'g_tab_gl_date(i)='||g_tab_gl_date(i));
		log_message(p_msg_token1 =>'g_tab_pa_date(i) ='||g_tab_pa_date(i));
		log_message(p_msg_token1 =>'g_tab_ext_bdgt_link(i)='||g_tab_ext_bdgt_link(i));
		log_message(p_msg_token1 =>'g_tab_start_date(i) = '||g_tab_start_date(i));
		log_message(p_msg_token1 =>'g_tab_end_date(i) = '||g_tab_end_date(i));
		 end loop;
              *****/

		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'calling update pkt autonomous transaction api');
		End if;
		update_pkts(p_packet_id => p_packet_id);
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'after the pkt autonomous transaction api');
		End if;


		EXIT when setup_details%NOTFOUND;

	END LOOP; -- end of setup details cursor;
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 =>'End of setup_details cursor');
	End if;
	CLOSE setup_details;
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'End of fundscheck  setup api');
	End if;
        If setup_details%ISOPEN THEN
                 close setup_details;
        End if;

	return true;

EXCEPTION

	WHEN OTHERS THEN
		If setup_details%ISOPEN THEN
			close setup_details;
		End if;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'Unexpected Error during Funds check setup Params SQLERROR '||sqlcode||sqlerrm);
		End if;
		-- Error Msg : 'F120 = Funds check failed during Setup and Summerization';
		result_status_code_update(
		p_status_code => 'T',
		p_result_code => 'F120',
		p_res_result_code => 'F120',
		p_res_grp_result_code => 'F120',
		p_task_result_code => 'F120',
		p_top_task_result_code => 'F120',
		p_project_result_code => 'F120',
		p_proj_acct_result_code => 'F120',
		p_packet_id => p_packet_id);
		log_message(p_error_msg => sqlcode||sqlerrm);
		--commit;
		Raise;

END funds_check_setup;
---------------------------------------------------------------------------------------
-- This api syncronizes the  burden lines with raw line
-- if the burden line pass but raw line fails then burden transaction
-- will be marked as failed
-------------------------------------------------------------------------------------
PROCEDURE result_code_update_burden
                (p_packet_id    IN NUMBER,
                 x_return_status  OUT NOCOPY VARCHAR2 )IS
        PRAGMA AUTONOMOUS_TRANSACTION;

      	CURSOR update_burden_rows IS
         	SELECT bc_packet_id,
			result_code,
			res_result_code,
			res_grp_result_code,
			task_result_code,
			top_task_result_code,
			project_result_code,
			project_acct_result_code
           	FROM pa_bc_packets
          	WHERE packet_id = p_packet_id
            	AND parent_bc_packet_id IS NULL
            	AND nvl(SUBSTR ( result_code,1,1),'P') IN ('F','R');

	l_num_rows		NUMBER:= 200;


BEGIN
      	OPEN update_burden_rows; LOOP
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'opened the update_burden_rows cursor ');
	End if;
	g_tab_bc_packet_id.delete;
	g_tab_r_result_code.delete;
	g_tab_rg_result_code.delete;
	g_tab_t_result_code.delete;
	g_tab_tt_result_code.delete;
	g_tab_p_result_code.delete;
	g_tab_p_acct_result_code.delete;
        FETCH update_burden_rows BULK COLLECT INTO
				g_tab_bc_packet_id,
                        	g_tab_result_code,
                        	g_tab_r_result_code,
                        	g_tab_rg_result_code,
                        	g_tab_t_result_code,
                        	g_tab_tt_result_code,
                        	g_tab_p_result_code,
                        	g_tab_p_acct_result_code
						 LIMIT l_num_rows;
		IF NOT g_tab_bc_packet_id.EXISTS(1) then
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'no rows found ');
			End if;
			EXIT;
		END IF;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'calling FORALL stagtment');
		End if;
        	FORALL i IN  g_tab_bc_packet_id.FIRST .. g_tab_bc_packet_id.LAST
			-- error msg : 'F116 = Transaction failed funds check because of Raw';
			UPDATE pa_bc_packets
            		--SET result_code = 'F116' the line is commented out NOCOPY as the user need not be shown
					       -- difference between raw and burden
			SET result_code = g_tab_result_code(i),
                            res_result_code = g_tab_r_result_code(i),
                            res_grp_result_code =  g_tab_rg_result_code(i),
                            task_result_code =   g_tab_t_result_code(i),
                            top_task_result_code =    g_tab_tt_result_code(i),
                            project_result_code =    g_tab_p_result_code(i),
                            project_acct_result_code =     g_tab_p_acct_result_code(i)
          		WHERE packet_id = p_packet_id
            		AND parent_bc_packet_id = g_tab_bc_packet_id(i)
			AND nvl(substr(result_code,1,1),'P') in ('P','A');
		-- end of for all
		COMMIT;

	EXIT when update_burden_rows%NOTFOUND ;

	END LOOP;
      	CLOSE update_burden_rows;
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'end of update_burden_rows cursor');
	End if;
	commit;

EXCEPTION

	WHEN OTHERS THEN
		if update_burden_rows%ISOPEN THEN
			close update_burden_rows ;
		End if;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'Exception portion in result_code_update_burden api');
		End if;
                x_return_status := 'T';
                RETURN;

END result_code_update_burden;

-- This api synchronizes the raw lines with burden lines
-- if the raw transaction passes but the burden transaction fails
-- the update the bc_packet set the staus of raw transaction as failed

PROCEDURE result_code_update_raw
                (p_packet_id    IN NUMBER,
                 x_return_status  OUT NOCOPY VARCHAR2 )IS
              PRAGMA AUTONOMOUS_TRANSACTION;
	CURSOR update_raw_rows IS
         	SELECT a.parent_bc_packet_id,
                       a.result_code,
                       a.res_result_code,
                       a.res_grp_result_code,
                       a.task_result_code,
                       a.top_task_result_code,
                       a.project_result_code,
                       a.project_acct_result_code
           	FROM pa_bc_packets  a,
		     pa_bc_packets  b
          	WHERE a.packet_id = p_packet_id
            	AND nvl(SUBSTR ( a.result_code,1,1),'P')  in ('R','F')
            	AND a.parent_bc_packet_id IS NOT NULL
		ANd a.packet_id = b.packet_id
		AND b.bc_packet_id = a.parent_bc_packet_id
		AND nvl(substr(b.result_code,1,1),'P') in ('A','P');
	l_num_rows		NUMBER:=200;


BEGIN
      	OPEN update_raw_rows; LOOP
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'opened the cursor update_raw_rows cursor');
	End if;
	g_tab_p_bc_packet_id.delete;
        g_tab_r_result_code.delete;
        g_tab_rg_result_code.delete;
        g_tab_t_result_code.delete;
        g_tab_tt_result_code.delete;
        g_tab_p_result_code.delete;
        g_tab_p_acct_result_code.delete;
        FETCH update_raw_rows BULK COLLECT INTO
				g_tab_p_bc_packet_id,
                                g_tab_result_code,
                                g_tab_r_result_code,
                                g_tab_rg_result_code,
                                g_tab_t_result_code,
                                g_tab_tt_result_code,
                                g_tab_p_result_code,
                                g_tab_p_acct_result_code
							LIMIT l_num_rows;
		IF NOT g_tab_p_bc_packet_id.EXISTS(1)  then
			IF g_debug_mode = 'Y' THEN
			 	log_message(p_msg_token1 => 'no rows found ');
			End if;
			EXIT;
		END IF;
		IF g_debug_mode = 'Y' THEN
		 	log_message(p_msg_token1 => 'calling FORALL statment');
		End if;
                FORALL i IN  g_tab_p_bc_packet_id.FIRST .. g_tab_p_bc_packet_id.LAST
			-- Error msg : 'F115 = Transaction failed funds check because of Burden';
			UPDATE pa_bc_packets
            		--SET result_code = 'F115'
                        SET result_code = g_tab_result_code(i),
                            res_result_code = g_tab_r_result_code(i),
                            res_grp_result_code =  g_tab_rg_result_code(i),
                            task_result_code =   g_tab_t_result_code(i),
                            top_task_result_code =    g_tab_tt_result_code(i),
                            project_result_code =    g_tab_p_result_code(i),
                            project_acct_result_code =     g_tab_p_acct_result_code(i)
          		WHERE packet_id = p_packet_id
            		AND bc_packet_id = g_tab_p_bc_packet_id(i)
            		AND nvl(substr(result_code,1,1),'P')  in ('A','P');
		-- end of forall loop
		COMMIT;

        EXIT WHEN update_raw_rows%NOTFOUND;
	END LOOP;
      	CLOSE update_raw_rows;
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'end of update_raw_rows api ');
	End if;

	commit;
EXCEPTION

        WHEN OTHERS THEN
                if update_raw_rows%ISOPEN THEN
                        close update_raw_rows ;
                End if;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'exception in result_code_update_raw api ');
		End if;
                x_return_status := 'T';
                RETURN;


END result_code_update_raw;

-- This api ensures that all the transactions are passed at documnet header
-- level whether it is full mode or partial mode
PROCEDURE update_trxn_doc_levl
                (p_packet_id            IN  NUMBER,
                 p_mode                 IN  VARCHAR2,
		 p_calling_module 	IN  VARCHAR2,
                 x_return_status        OUT NOCOPY VARCHAR2) IS
        PRAGMA AUTONOMOUS_TRANSACTION;

	CURSOR update_headers IS
		SELECT document_header_id,
		       document_line_id,
		       exp_item_id,
		       result_code
		FROM   pa_bc_packets
		WHERE  packet_id = p_packet_id
		AND    nvl(substr(result_code,1,1),'P') in ('F','R');

	l_num_rows   NUMBER := 200;
BEGIN
	-- Initialize the error stack
	PA_DEBUG.init_err_stack('PA_FUNDS_CONTROL_PKG.update_trxn_doc_levl');

	--reset the return status
	x_return_status := 'S';
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'inside the update_trxn_doc_levl api');
	End if;
	IF p_calling_module in ('DISTBTC','CBC','TRXNIMPORT','DISTVIADJ','DISTERADJ','EXPENDITURE','TRXIMPORT','DISTCWKST') then

		OPEN update_headers; LOOP
		IF g_debug_mode = 'Y' THEN
		  	log_message(p_msg_token1 => 'opened the update_headers cursor ');
		End if;
		g_tab_doc_header_id.delete;
		g_tab_doc_line_id.delete;
		g_tab_exp_item_id.delete;
		g_tab_result_code.delete;
		FETCH update_headers BULK COLLECT INTO
			g_tab_doc_header_id,
			g_tab_doc_line_id,
			g_tab_exp_item_id,
			g_tab_result_code  LIMIT l_num_rows;
			IF NOT g_tab_doc_header_id.EXISTS(1)  then
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1 => 'no rows found ');
				End if;
				EXIT;
			END IF;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'calling FORALL statement count['||g_tab_doc_header_id.count||']');
			End if;
			FORALL  i IN g_tab_doc_header_id.FIRST .. g_tab_doc_header_id.LAST
			-- Error msg : F117 = Transaction failed due to adjusted cdls
			UPDATE pa_bc_packets
			SET result_code = decode(substr(nvl(result_code,'P'),1,1),'P',
						  decode(p_calling_module,'CBC',g_tab_result_code(i),'F117'),result_code)
			WHERE packet_id = p_packet_id
			AND  ( (document_header_id = g_tab_doc_header_id(i)
				and document_type in ('EXP','AP','CC_P_PAY','CC_C_PAY','CC_C_CO','CC_P_CO')
				and p_calling_module in ('DISTBTC','CBC','DISTVIADJ','TRXIMPORT','DISTERADJ')
				)
			      OR
			        (p_calling_module = 'DISTCWKST'
				 and document_line_id = g_tab_doc_line_id(i)
				 and exp_item_id = g_tab_exp_item_id(i)
				 and document_type in ('PO','EXP')
				 )
			     )
			AND  nvl(substr(result_code,1,1),'P') in ('P','A');

			IF g_debug_mode = 'Y' THEN
                                log_message(p_msg_token1 => 'Num of Rows updated['||sql%rowcount||']');
                        End if;
		EXIT WHEN update_headers%NOTFOUND ;
		END LOOP;
		CLOSE update_headers;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'end of update_headers cursor');
		End if;
		COMMIT;
	END IF;
	COMMIT;
EXCEPTION
	when others then
		IF update_headers%ISOPEN THEN
			close update_headers;
		End IF;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'exception in update_trxn_doc_levl api ');
		End if;
                log_message(p_error_msg => sqlcode||sqlerrm);
		x_return_status := 'T';
		RETURN;

END update_trxn_doc_levl;
-- This api syncronizes the  raw and burden lines
-- if the burden line pass but raw line fails then burden transaction
-- will be marked as failed
PROCEDURE  sync_raw_burden
                (p_packet_id            IN  NUMBER,
                 p_mode                 IN  VARCHAR2,
		 p_calling_module	IN  VARCHAR2,
                 x_return_status        OUT NOCOPY VARCHAR2) IS

BEGIN
	-- call for update the burden transaction with failure status
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'Calling result_code_update_burden api ');
	End if;
	result_code_update_burden
                (p_packet_id    => p_packet_id,
                 x_return_status  => x_return_status);
	-- call for update of the raw transaction with the failure status
	IF g_debug_mode = 'Y' THEN
	 	log_message(p_msg_token1 => 'Calling result_code_update_raw api ');
	End if;
        result_code_update_raw
                (p_packet_id    => p_packet_id,
                 x_return_status  => x_return_status);


	--call for update at the ei level if ei is a adjusted cdls
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'Calling update_trxn_doc_levl api ');
	End if;

	update_trxn_doc_levl
                (p_packet_id             => p_packet_id,
                 p_mode                  => p_mode,
                 p_calling_module        => p_calling_module,
                 x_return_status         => x_return_status);

EXCEPTION
	when others then
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 => 'failed in sync raw burden api SQLERROR:'||sqlcode||sqlerrm);
		End if;
                --commit;
		RAISE;

END sync_raw_burden;
--------------------------------------------------------------------
-- This api check whether the base line is progress for the given
-- project
--------------------------------------------------------------------
FUNCTION is_baseline_progress(p_project_id  number)
  return varchar2 IS

	l_status_flag varchar2(1) := 'N';
	l_wf_status   varchar2(25) := null;

	cursor check_bdgt_baseline is
	SELECT wf_status_code
	FROM pa_budget_versions
	WHERE project_id = p_project_id
	AND wf_status_code is NOT NULL;



BEGIN
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 =>' Inside the is_baselinei_progress api');
	End if;
	OPEN check_bdgt_baseline;
	LOOP
		FETCH check_bdgt_baseline INTO l_wf_status;
		EXIT WHEN check_bdgt_baseline%NOTFOUND;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'WF_STATUS_CODE ='||l_wf_status);
		End if;
		IF l_wf_status = 'IN_ROUTE' then
			-- ie the budget is under baselineing for this project
			l_status_flag := 'Y';
			EXIT;
		END IF;
	END LOOP;
	CLOSE check_bdgt_baseline;

	If check_bdgt_baseline%ISOPEN then
		close check_bdgt_baseline;
	End if;


	RETURN l_status_flag;
EXCEPTION
	WHEN OTHERS THEN
	        If check_bdgt_baseline%ISOPEN then
                	close check_bdgt_baseline;
        	End if;
		RAISE;

END is_baseline_progress;

-----------------------------------------------------------------------------------------------+
-- This procedure is the autonomous version of status_code_udpate. Basically, this procedure
-- will call status_code_update
-- main procedure status_code_update is being made non-autonomous
-----------------------------------------------------------------------------------------------+
PROCEDURE status_code_update_autonomous (
        p_calling_module        IN VARCHAR2,
        p_packet_id             IN NUMBER,
        p_mode                  IN VARCHAR2,
        p_partial               IN VARCHAR2 DEFAULT 'N',
        p_packet_status         IN VARCHAR2 DEFAULT 'S',
        x_return_status         OUT NOCOPY varchar2 )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

   status_code_update (
        p_calling_module        => p_calling_module,
        p_packet_id             => p_packet_id,
        p_mode                  => p_mode,
        p_partial               => p_partial,
        p_packet_status         => p_packet_status,
        x_return_status         => x_return_status);
   COMMIT;

End status_code_update_autonomous;

--------------------------------------------------------------------------------------------
-- This api updates the status of bc packets based on the result code
--  and calling mode and partial flag
-- The valid status code values are
-- A - Approved
-- B - Base lined -- Intermediate status (r12 on - not used)
-- R - Rejected
-- C - Checked   -- Intermediate status  (r12 on - not used)
-- F - Failed Check
-- S - Passed Check
-- E - Error
-- T - Fatal
-- V - Vendor Invoice - Intermediate status to avoid sweeper to pick
-- L - Intermediate status for Expense report to liquidate but avoid sweeper to pick
-- I - Intermedidate status in which commitment records will be created, this will be synched
--     as the first step in pa_funds_check (Added in R12)
-- if the calling module is BASELINE  then use BULK FETCH AND BULK
-- update logic since the volume of records is more.
-----------------------------------------------------------------------------------------------
PROCEDURE status_code_update (
        p_calling_module        IN VARCHAR2,
        p_packet_id             IN NUMBER,
        p_mode                  IN VARCHAR2,
        p_partial               IN VARCHAR2 DEFAULT 'N',
	p_packet_status         IN VARCHAR2 DEFAULT 'S',
        x_return_status         OUT NOCOPY varchar2 ) IS

	-- PRAGMA AUTONOMOUS_TRANSACTION;

	CURSOR baseline_error_status IS
	SELECT rowid,
		bc_packet_id
	FROM pa_bc_packets
	WHERE packet_id = p_packet_id
	AND  EXISTS(
			SELECT 'x'
                         FROM pa_bc_packets
                         WHERE packet_id = p_packet_id
                         AND SUBSTR ( nvl(result_code,'P'), 1, 1 ) = 'F'
                    );

        CURSOR baseline_success_status IS
        SELECT rowid,
                bc_packet_id
        FROM pa_bc_packets
        WHERE packet_id = p_packet_id
	AND status_code = 'P'
	AND SUBSTR ( nvl(result_code,'P'), 1, 1 ) = 'P';

	CURSOR cur_projects IS
	SELECT distinct project_id
	FROM pa_bc_packets
	WHERE packet_id = p_packet_id;

	CURSOR cur_fatal_error IS
	SELECT bc_packet_id
	FROM   pa_bc_packets
	WHERE  packet_id = p_packet_id;

	l_project_id		NUMBER;
	l_base_line_project	NUMBER;
	l_base_line_flag	VARCHAR2(10):= 'N';
	l_num_rows		NUMBER := 200;
	l_rowcount		NUMBER ;


BEGIN
        -- initialize the return status to success
        x_return_status := 'S';

        --Initialize the err stack
        PA_DEBUG.init_err_stack('PA_FUNDS_CONTROL_PKG.status_code_update');

	IF g_debug_mode = 'Y' THEN
        	log_message(p_msg_token1 =>'Inside the status code update api p_calling_module['
                     ||p_calling_module||']packet_id['||p_packet_id||']mode['
                     ||p_mode||']partial flag['||p_partial||']packet_status['
                     ||p_packet_status||']');
	End if;

	/** Incase of fatal error from distribute expenses report or transaction import programs
	 *  update the status code of the packets to fatal so that it will not pickup
	 *  for updating the balances
	 */
	IF p_packet_status = 'T' then

		OPEN cur_fatal_error;
		LOOP
			g_tab_bc_packet_id.delete;
			FETCH cur_fatal_error BULK COLLECT
				INTO g_tab_bc_packet_id LIMIT 300;
			IF NOT g_tab_bc_packet_id.EXISTS(1)  then
				exit;
			END IF;

			FORALL i IN g_tab_bc_packet_id.first .. g_tab_bc_packet_id.last
				UPDATE pa_bc_packets
				SET status_code = 'T'
				WHERE packet_id = p_packet_id
				AND   bc_packet_id = g_tab_bc_packet_id(i);

			Exit when cur_fatal_error%NOTFOUND;

		END LOOP;

		CLOSE cur_fatal_error;
		--commit; -- to end an active autonomous transaction
		pa_debug.reset_err_stack;
		RETURN;

	END IF;


	IF p_calling_module in ('RESERVE_BASELINE') and p_mode = 'S' THEN
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 =>'stage : STATUS_CODE:SUBMIT');
		End if;
		-- if the calling mode is submit and if there is any failed transaction
		-- the whole package is marked as E - Error other wise it is Passed check
         	g_error_stage := 'STATUS_CODE:SUBMIT';
		OPEN baseline_error_status;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'opened cursor baseline_error_status ');
		End if;
		LOOP
			g_tab_bc_packet_id.delete;
			FETCH baseline_error_status BULK COLLECT INTO
				g_tab_rowid,g_tab_bc_packet_id LIMIT l_num_rows;
				If NOT g_tab_rowid.EXISTS(1) then
					IF g_debug_mode = 'Y' THEN
				     		log_message(p_msg_token1 => 'no records fetched exiting');
					End if;
				    EXIT;
				End if;
			FORALL i IN g_tab_rowid.FIRST .. g_tab_rowid.LAST
         			UPDATE pa_bc_packets
            			SET status_code = 'E'
          			WHERE packet_id = p_packet_id
				AND bc_packet_id = g_tab_bc_packet_id(i);
			--COMMIT;
			EXIT when baseline_error_status%NOTFOUND;
		END LOOP;
		CLOSE baseline_error_status;

                OPEN baseline_success_status;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'opened baseline_success_status cursor ');
			End if;
                LOOP
                        g_tab_bc_packet_id.delete;
                        FETCH baseline_success_status BULK COLLECT INTO
                                g_tab_rowid,g_tab_bc_packet_id LIMIT l_num_rows;
			IF NOT g_tab_rowid.EXISTS(1) then
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1 => 'no records fetched exiting');
				End if;
				EXIT;
			END IF;
                        FORALL i IN g_tab_rowid.FIRST .. g_tab_rowid.LAST
                                UPDATE pa_bc_packets
                                SET status_code = 'S'
                                WHERE packet_id = p_packet_id
                                AND bc_packet_id = g_tab_bc_packet_id(i);
                        --COMMIT;
                        EXIT when baseline_success_status%NOTFOUND;
                END LOOP;
                CLOSE baseline_success_status;

      	ELSIF p_calling_module in ('RESERVE_BASELINE')  and p_mode = 'B' THEN
		-- if the calling mode is Base line and if there is any failed transaction
		-- the whole package is marked as R - Rejected other wise it is Approved
		-- update the status to intermediate status of B - baseline finally the
		-- the base line process will udate the status to A and sweeper programm
		-- picks all the records
         	g_error_stage := 'STATUS_CODE: BASELINE';
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'stage : STATUS_CODE: BASELINE');
		End if;
                OPEN baseline_error_status;
		IF g_debug_mode = 'Y' THEN
		 	log_message(p_msg_token1 => 'opened baseline_error_status cursor ');
		End if;
                LOOP
                        g_tab_bc_packet_id.delete;
                        FETCH baseline_error_status BULK COLLECT INTO
                                g_tab_rowid,g_tab_bc_packet_id LIMIT l_num_rows;
			IF NOT g_tab_rowid.EXISTS(1) then
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1 => 'no recrods found');
				End if;
				EXIT;
			END IF;
                        FORALL i IN g_tab_rowid.FIRST .. g_tab_rowid.LAST
                                UPDATE pa_bc_packets
                                SET status_code = 'R'  -- rejected
                                WHERE packet_id = p_packet_id
                                AND bc_packet_id = g_tab_bc_packet_id(i);

			log_message(p_msg_token1 => 're-baseline fails [ '||sql%rowcount||' ] records updated to R');
                        --COMMIT;
                        EXIT when baseline_error_status%NOTFOUND;
                END LOOP;
                CLOSE baseline_error_status;

                /* =====================================================================+
                || Pass code will be handled in PABBFNDB.pls
                || ---------------------------------------------------------------------+
                OPEN baseline_success_status;
		IF g_debug_mode = 'Y' THEN
		  	log_message(p_msg_token1 => 'opened  baseline_success_status cursor ');
		End if;
                LOOP
                        g_tab_bc_packet_id.delete;
                        FETCH baseline_success_status BULK COLLECT INTO
                                g_tab_rowid,g_tab_bc_packet_id LIMIT l_num_rows;
			IF NOT g_tab_rowid.EXISTS(1) then
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1 => 'no recrods found');
				End if;
                                EXIT;
                        END IF;
                        FORALL i IN g_tab_rowid.FIRST .. g_tab_rowid.LAST
                                UPDATE pa_bc_packets
                                SET status_code = 'A'
                                WHERE packet_id = p_packet_id
                                AND bc_packet_id = g_tab_bc_packet_id(i);

			log_message(p_msg_token1 => 're-baseline passed [ '||sql%rowcount||' ] records updated to R');
                        --COMMIT;
                        EXIT when baseline_success_status%NOTFOUND;
                END LOOP;
                CLOSE baseline_success_status;
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'end of baseline update staus');
		End if;
                ==========================================================================+ */

      	ELSIF p_mode = 'C' THEN
                -- if the calling mode is Check Funds  and if there is any failed transaction
                -- the whole package is marked as F - Failed Check other wise it is Checked - C
         	g_error_stage := 'STATUS_CODE: CHECK FUNDS';
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'stage : STATUS_CODE: CHECK FUNDS');
		End if;
                IF p_partial = 'Y' THEN
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'p_partial = Y');
			End if;
                        -- If the calling mode is Reserve and Partial flag is 'Y' then
                        -- if there is any failed transaction then update the bc packet with
                        -- each record as  Rejected.
                        g_error_stage := 'STATUS_CODE:RESERVE - Partial';
			IF g_debug_mode = 'Y' THEN
                        	log_message(p_msg_token1 => 'STATUS_CODE:RESERVE - Partial');
			End if;
                        UPDATE pa_bc_packets
                        SET status_code = DECODE ( SUBSTR (
                                               nvl(result_code,'P'), 1, 1 )
                                                 , 'P', decode(status_code,'P','S',status_code)
                                                 , 'F' )
                        WHERE packet_id = p_packet_id
                        AND status_code in ('P','L','S');
			l_rowcount := sql%rowcount;
		Elsif p_partial <> 'Y' then

         		UPDATE pa_bc_packets
            		SET status_code = 'F'
			WHERE packet_id = p_packet_id
            		AND EXISTS (SELECT 'x'
                        FROM pa_bc_packets
                        WHERE packet_id = p_packet_id
                        AND ( SUBSTR ( nvl(result_code,'P'), 1, 1 ) = 'F'
				OR p_packet_status in ('F','R','T')
                            ));
			l_rowcount := sql%rowcount;

			If l_rowcount <= 0 then
                               UPDATE pa_bc_packets
                               SET status_code = 'S'
                               WHERE packet_id = p_packet_id
                               AND status_code in ('P','L','S')
                               AND SUBSTR ( nvl(result_code,'P'),1,1 ) = 'P';

			End if;
		End if;

      	ELSIF p_mode = 'U' THEN
                -- if the calling mode is Un Reserve  and if there is any failed transaction
                -- the whole package is marked as R - Rejected other wise it is  Approved
		-- *** The transaction which comes during baseline process to maintain data
		-- concurrancy the following logic is used
		-- check if the budget is being baseline for the project then mark the
		-- status of the transaction belong the particular project which is being baselined
		-- to intermediate status so that the baseline process picks all theses records
		-- and calls agian funds check process . and finally the base line process
		-- marks the status to approved
         	g_error_stage := 'STATUS_CODE: UNRESERVE';
		IF g_debug_mode = 'Y' THEN
			log_message(p_msg_token1 => 'Stage : STATUS_CODE: UNRESERVE');
		End if;

         	UPDATE pa_bc_packets
            	SET status_code = 'R'
	    	WHERE packet_id = p_packet_id
            	AND EXISTS (SELECT 'x'
                         FROM pa_bc_packets
                         WHERE packet_id = p_packet_id
                         AND ( SUBSTR ( nvl(result_code,'P'), 1, 1 ) = 'F'
				OR p_packet_status in ('F','R','T')
			     ));
		 l_rowcount := sql%rowcount;
		IF g_debug_mode = 'Y' THEN
		 	log_message(p_msg_token1 => 'no rows updated = '||l_rowcount);
		End if;

         	IF l_rowcount <= 0 THEN
			--- check the transaction is arrived during the base line process
			--- if so the mark the status to intermediate status
			OPEN cur_projects;
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'opened cur_project cursor');
			End if;
                        LOOP
                               	FETCH cur_projects INTO l_project_id;
				IF g_debug_mode = 'Y' THEN
				 	log_message(p_msg_token1 => 'project id ='||l_project_id);
				End if;
                               	EXIT WHEN cur_projects%NOTFOUND;

            				UPDATE pa_bc_packets
               				SET status_code = 'A'
             				WHERE packet_id = p_packet_id
					AND project_id = l_project_id
					AND status_code in ('P')
               				AND SUBSTR ( nvl(result_code,'P'), 1, 1 ) = 'P';
			END LOOP;
			CLOSE cur_projects;
			IF g_debug_mode = 'Y' THEN
			 	log_message(p_msg_token1 => 'end of cur_projects cursor ');
			End if;

         	END IF;

      	ELSIF p_mode in ('F','R') THEN
		IF g_debug_mode = 'Y' THEN
		 	log_message(p_msg_token1 => 'Stage : STATUSCODE : RESERVE');
		End if;

             	OPEN cur_projects;
             	LOOP
                  	FETCH cur_projects INTO l_project_id;
                  	EXIT WHEN cur_projects%NOTFOUND;

			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'base_line_flag ='||l_base_line_flag);
			End if;

         		IF p_partial = 'Y' THEN
				-- If the calling mode is Reserve and Partial flag is 'Y' then
				-- if there is any failed transaction then update the bc packet with
				-- each record as  Rejected.
            			g_error_stage := 'STATUS_CODE:RESERVE - Partial';
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1 => 'STATUS_CODE:RESERVE - Partial');
				End if;

            				UPDATE pa_bc_packets
               				SET status_code = DECODE ( SUBSTR (
							      nvl(result_code,'P'), 1, 1 )
							          , 'P', decode(status_code,'P','A',status_code)
								  , 'R' )
             				WHERE packet_id = p_packet_id
					AND  project_id = l_project_id
					AND status_code in ('P','L');
					IF g_debug_mode = 'Y' THEN
						log_message(p_msg_token1 => 'no of rows updated ='||sql%rowcount);
					end if;

            				IF SQL%NOTFOUND THEN
					   log_message (p_msg_token1 =>'Updated the status code for Partial Mode');
            				END IF;

         		ELSE  --  p_partial <> 'Y' then
                		-- If the calling mode is Reserve and Partial flag is 'N'ie full mode then
                		-- if there is any failed transaction then update the whole packet with Rejected
            			g_error_stage := 'STATUS_CODE:RESERVE - Full';
				IF g_debug_mode = 'Y' THEN
				 	log_message(p_msg_token1 =>'STATUS_CODE:RESERVE - Full');
				End if;

            			UPDATE pa_bc_packets
               			SET status_code = 'R'
             			WHERE packet_id = p_packet_id
				AND project_id = l_project_id
               			AND EXISTS (SELECT 'x'
                             		FROM pa_bc_packets
                            		WHERE packet_id = p_packet_id
                              		AND ( SUBSTR ( nvl(result_code,'P'), 1, 1 ) = 'F'
						OR p_packet_status in ('F','R','T')
					    ));
				l_rowcount := sql%rowcount;
				IF g_debug_mode = 'Y' THEN
				 	log_message(p_msg_token1 =>'no of rows rejected ='||l_rowcount);
				End if;

            			IF l_rowcount <= 0 THEN
                        		--- check the transaction is arrived during the base line process
                        		--- if so the mark the status to intermediate status

                                		UPDATE pa_bc_packets
                                		SET status_code = 'A'
                                		WHERE packet_id = p_packet_id
						AND project_id = l_project_id
                                		AND SUBSTR ( nvl(result_code,'P'), 1, 1 ) = 'P'
						AND status_code in ('P');

						IF g_debug_mode = 'Y' THEN
							log_message(p_msg_token1 =>'no of rows approved ='||sql%rowcount);
						End if;
				END IF;

         		END IF; -- end if for partial flag
		END LOOP;
       		CLOSE cur_projects;
		IF g_debug_mode = 'Y' THEN
		 	log_message(p_msg_token1 =>'end of cur project cursor ');
		End if;
      	END IF; -- end if for calling mode


	--reset the error stack
	pa_debug.reset_err_stack;
	--commit; -- to end an active autonmous transaction
	IF cur_projects%isopen then
		close cur_projects;
	End if;
	IF baseline_success_status%isopen then
		close baseline_success_status;
	End if;
	IF baseline_error_status%isopen then
		close baseline_error_status;
	End if;
	return;

EXCEPTION
 	WHEN OTHERS THEN
        	IF cur_projects%isopen then
                	close cur_projects;
        	End if;
        	IF baseline_success_status%isopen then
                	close baseline_success_status;
        	End if;
        	IF baseline_error_status%isopen then
                	close baseline_error_status;
        	End if;
		IF cur_fatal_error%isopen then
			close cur_fatal_error;
		End if;
		x_return_status := 'T';
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 => 'failed in status code update api SQLERR :'||sqlcode||sqlerrm);
		End if;
   		RAISE;
END status_code_update;

--------------------------------------------------------------------------------------
-- this api updates the Expenditure items with status code
-- if the transaction passes the funds check the gl date
-- will be stampled on cdl otherwise the ei is updated with
-- rejection code
--------------------------------------------------------------------------
PROCEDURE update_EIS (p_packet_id       IN NUMBER,
                     p_calling_module   IN VARCHAR2,
                     p_mode             IN VARCHAR2,
                     x_return_status    OUT NOCOPY VARCHAR2) IS
        CURSOR ei_details is
                SELECT  project_id,
			document_type,
			document_header_id,
                        document_distribution_id,
                        GL_DATE  ,
                        budget_ccid,
                        proj_encumbrance_type_id,
                        status_code,
                        result_code,
                        bc_packet_id,
                        parent_bc_packet_id,
                        res_result_code,
                        res_grp_result_code,
                        task_result_code,
                        top_task_result_code,
                        project_result_code,
                        project_acct_result_code,
                        accounted_dr,
                        accounted_cr,
		        budget_version_id,
		        budget_line_id
                FROM pa_bc_packets
                WHERE packet_id = p_packet_id
                ORDER BY document_header_id,document_distribution_id,bc_packet_id;

        l_pre_exp_item_id       NUMBER := null;
        l_num_rows      NUMBER := 200;
        l_tab_dist_warn_code    pa_plsql_datatypes.char25tabtyp;
        l_warn_code             varchar2(30);
        l_tab_warning_code      pa_plsql_datatypes.char25tabtyp;
	l_tab_ext_bdgt_flag     pa_plsql_datatypes.char25tabtyp;
        j                       NUMBER;
        l_doc_header_id         pa_bc_packets.document_header_id%type;
	l_pre_project_id        pa_bc_packets.project_id%type := null;
        l_count                 NUMBER;
	l_ext_bdgt_type		VARCHAR2(25) := null;
	l_ext_bdgt_link		VARCHAR2(25) := null;
	L_PRE_EXT_BDGT_TYPE     VARCHAR2(25) := null;

BEGIN

        --Initialize the error stack
        pa_debug.init_err_stack('PA_FUNDS_CONTROL_PKG.update_EIS');

        -- initialize the return status
        x_return_status := 'S';

        -- update the ei with rejection code if the transaction fails during funds check
        -- else stamp GL_DATE on the cdl for all funds check passed transaction
        IF p_calling_module in ('DISTBTC','EXPENDITURE','DISTVIADJ','DISTERADJ','INTERFACVI','INTERFACER','DISTCWKST') then
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 => 'Inside the Update EIS api');
		End if;
                IF p_mode in ('R','U','C') then
                        OPEN ei_details;
                        LOOP
				g_tab_project_id.delete;
				g_tab_doc_type.delete;
                                g_tab_doc_header_id.delete;
                                g_tab_doc_distribution_id.delete;
                                g_tab_gl_date.delete;
                                g_tab_budget_ccid.delete;
                                g_tab_encum_type_id.delete;
                                g_tab_status_code.delete;
                                g_tab_result_code.delete;
                                g_tab_bc_packet_id.delete;
                                g_tab_p_bc_packet_id.delete;
                                g_tab_r_result_code.delete;
                                g_tab_rg_result_code.delete;
                                g_tab_t_result_code.delete;
                                g_tab_tt_result_code.delete;
                                g_tab_p_result_code.delete;
                                g_tab_p_acct_result_code.delete;
                                l_tab_dist_warn_code.delete;
                                l_tab_warning_code.delete;
                                g_tab_accounted_dr.delete;
                                g_tab_accounted_cr.delete;
				l_tab_ext_bdgt_flag.delete;
				g_tab_budget_version_id.delete;
				g_tab_budget_line_id.delete;
                                FETCH ei_details BULK COLLECT INTO
					g_tab_project_id,
					g_tab_doc_type,
                                        g_tab_doc_header_id,
                                        g_tab_doc_distribution_id,
                                        g_tab_gl_date,
                                        g_tab_budget_ccid,
                                        g_tab_encum_type_id,
                                        g_tab_status_code,
                                        g_tab_result_code,
                                        g_tab_bc_packet_id,
                                        g_tab_p_bc_packet_id,
                                        g_tab_r_result_code,
                                        g_tab_rg_result_code,
                                        g_tab_t_result_code,
                                        g_tab_tt_result_code,
                                        g_tab_p_result_code,
                                        g_tab_p_acct_result_code,
                                        g_tab_accounted_dr,
                                        g_tab_accounted_cr,
					g_tab_budget_version_id,
					g_tab_budget_line_id   LIMIT l_num_rows;
                                IF NOT g_tab_doc_header_id.EXISTS(1) then
                                        EXIT;
                                END IF;

				FOR i IN g_tab_doc_type.FIRST .. g_tab_doc_type.LAST LOOP

                        		If g_tab_doc_type(i) in ('CC_C_PAY','CC_P_PAY','AP'
								,'PO','REQ','EXP') THEN
                                		l_ext_bdgt_type := 'STD';
                        		Elsif g_tab_doc_type(i) in ('CC_C_CO','CC_P_CO') then
                                		l_ext_bdgt_type := 'CBC';
                        		End if;

                        		If (l_pre_project_id is NULL or l_pre_project_id
                                		<> g_tab_project_id(i)) OR
                           			(l_pre_ext_bdgt_type is NULL or l_pre_ext_bdgt_type <>
                                		l_ext_bdgt_type )  then

                                		l_ext_bdgt_link := PA_FUNDS_CONTROL_UTILS.get_bdgt_link(
                                        		p_project_id => g_tab_project_id(i),
                                        		p_calling_mode => l_ext_bdgt_type );


                        		END IF;

					l_tab_ext_bdgt_flag(i) := l_ext_bdgt_link;

					l_pre_project_id := g_tab_project_id(i);
					l_pre_ext_bdgt_type := l_ext_bdgt_type;

				END LOOP;
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Check for the Advisory Warnings ');
				End if;

                                FOR i IN g_tab_doc_header_id.FIRST .. g_tab_doc_header_id.LAST  LOOP
                                        l_tab_dist_warn_code(i) := 'P';

                                        If substr(g_tab_result_code(i),1,1) =  'P' then
                                            IF g_tab_r_result_code(i) = 'P112' then
                                                l_tab_dist_warn_code(i) := 'P112';
                                            Elsif g_tab_rg_result_code(i) = 'P110' and
                                                  l_tab_dist_warn_code(i) <> 'P112' then
                                                  l_tab_dist_warn_code(i) := 'P110';
                                            Elsif g_tab_t_result_code(i) = 'P108' and
                                                  l_tab_dist_warn_code(i) NOT IN ('P112','P110') then
                                                  l_tab_dist_warn_code(i) := 'P108';
                                            Elsif g_tab_tt_result_code(i) = 'P106' and
                                                  l_tab_dist_warn_code(i) NOT IN ('P112','P110','P108') then
                                                  l_tab_dist_warn_code(i) := 'P106';
                                            Elsif g_tab_p_result_code(i) = 'P104' and
                                                  l_tab_dist_warn_code(i) NOT IN ('P112','P110','P108','P106') then
                                                  l_tab_dist_warn_code(i) := 'P104';
                                            End if;
                                        Else
                                                  l_tab_dist_warn_code(i) := null;
                                        End if;
                                        If l_tab_dist_warn_code(i) NOT IN
                                                  ('P112','P110','P108','P106','P104') then
                                                  l_tab_dist_warn_code(i) := null;
                                        End if;

                                END LOOP;


                                l_count := 0;

                                FOR i IN g_tab_doc_header_id.FIRST .. g_tab_doc_header_id.LAST  LOOP
                                        l_count := l_count + 1;
                                    If substr(g_tab_result_code(i),1,1) =  'P' then
                                        If g_tab_doc_header_id(i) <> l_doc_header_id  OR
                                                l_doc_header_id is NULL then
                                                j := l_count;
                                                l_warn_code := 'P';
                                                LOOP -- through all cdls lines
                                                        If NOT g_tab_doc_header_id.exists(j) then
                                                                Exit;
                                                        End if;
                                                        If g_tab_doc_header_id(i) = g_tab_doc_header_id(j) then
                                                                If substr(g_tab_result_code(i),1,1) =  'P' then
                                                                  IF l_tab_dist_warn_code(j)  = 'P112' then
                                                                        l_warn_code := 'P112';
                                                                        Exit;
                                                                  Elsif l_tab_dist_warn_code(j)  = 'P110' and
                                                                        l_warn_code <> 'P112' then
                                                                        l_warn_code := 'P110';
                                                                  Elsif l_tab_dist_warn_code(j)  = 'P108' and
                                                                        l_warn_code NOT IN ('P112','P110') then
                                                                        l_warn_code := 'P108';
                                                                  Elsif l_tab_dist_warn_code(j)  = 'P106' and
                                                                        l_warn_code NOT IN
                                                                        ('P112','P110','P108') then
                                                                        l_warn_code := 'P106';
                                                                  Elsif l_tab_dist_warn_code(j)  = 'P104' and
                                                                        l_warn_code NOT IN
                                                                          ('P112','P110','P108','P106') then
                                                                        l_warn_code := 'P104';
                                                                  End if;
                                                                End if;
                                                        Else
                                                                exit;
                                                        End if;
                                                        j := j + 1;

                                                END LOOP;
                                                l_tab_warning_code(i) := l_warn_code;
                                                If l_tab_warning_code(i) NOT IN
                                                        ('P112','P110','P108','P106','P104') then
                                                        l_tab_warning_code(i) := null;
                                                End if;
                                                l_doc_header_id := g_tab_doc_header_id(i);

                                        Else
                                                l_tab_warning_code(i) := l_warn_code;
                                                If l_tab_warning_code(i) NOT IN
                                                        ('P112','P110','P108','P106','P104') then
                                                        l_tab_warning_code(i) := null;
                                                End if;
                                        End If;
                                   Else  -- for result code fail
                                        l_tab_warning_code(i) := null;
                                   End if;

                                END LOOP;
                                -- update ei with cost dist rejection code if there is failed funds check
                                -- and update ei with cost dist warning code for transaction with
                                -- advisory warnings.
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Calling FORALL update for EI');
				End if;
                                /*=========================================================+
                                 | Bug 3565708: Added g_tab_p_bc_packet_id(i) = -7777 ; so |
                                 | rejection would include BTC txns also.                  |
                                 +=========================================================*/
                                FORALL i IN g_tab_doc_header_id.FIRST .. g_tab_doc_header_id.LAST
                                        UPDATE pa_expenditure_items_all
                                        SET  cost_dist_rejection_code =
                                                decode(substr(g_tab_result_code(i),1,1),'F',
                                                                g_tab_result_code(i),null)
                                             ,cost_dist_warning_code  = l_tab_warning_code(i)
                                        WHERE expenditure_item_id = g_tab_doc_header_id(i)
                                        AND (g_tab_p_bc_packet_id(i) is NULL OR g_tab_p_bc_packet_id(i) = -7777 );
				IF g_debug_mode = 'Y' THEN
                                	log_message(p_msg_token1 => 'Calling FORALL update for CDL');
				End if;
                                -- If the transaction passes the fundscheck then update the
                                -- cdls with gl_date,encumbrance type id, budget ccid and
                                -- encumbrance amount for the R line .updating C and D lines
                                -- will be done in Distribute Burden transaction process
                                FORALL i IN g_tab_doc_header_id.FIRST .. g_tab_doc_header_id.LAST
                                        UPDATE pa_cost_distribution_lines_all
                                        SET --gl_date = g_tab_gl_date(i)
                                         budget_ccid = g_tab_budget_ccid(i)
					 ,budget_version_id = g_tab_budget_version_id(i)
					 ,budget_line_id = g_tab_budget_line_id(i)
					 ,liquidate_encum_flag = 'Y'
                                         ,encumbrance_type_id = g_tab_encum_type_id(i)
                                         ,encumbrance_amount = nvl(g_tab_accounted_dr(i),0) -
                                                              nvl(g_tab_accounted_cr(i),0)
                                        WHERE expenditure_item_id = g_tab_doc_header_id(i)
                                        AND   line_num  = g_tab_doc_distribution_id(i)
                                        AND   line_type = 'R'
                                        AND   g_tab_p_bc_packet_id(i) is null
					AND   l_tab_ext_bdgt_flag(i) = 'Y'
                                        AND   substr(nvl(g_tab_result_code(i),'P'),1,1) = 'P';

                                EXIT WHEN ei_details%NOTFOUND;
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1 => 'end of FORALL update for CDL');
				End if;
                        END LOOP;
                END IF;

        END IF;
        pa_debug.reset_err_stack;

	Return;
EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'T';
		IF g_debug_mode = 'Y' THEN
                	log_message(p_msg_token1 => 'SQLERR :'||sqlcode||sqlerrm|| 'failed in update_EIS api');
		End if;
                log_message(p_error_msg => sqlcode||sqlerrm);
                Raise;
END update_EIS;
------------------------------------------------------------
-- This api  posts the encumbrance liqudation entries and
-- updates the budget account balances when there is
-- link with the std budget
-----------------------------------------------------------
PROCEDURE upd_bdgt_encum_bal(
	  	p_packet_id  		IN NUMBER,
		p_calling_module  	IN VARCHAR2,
		p_mode			IN VARCHAR2,
		p_packet_status         IN VARCHAR2,
		x_return_status	 	OUT NOCOPY VARCHAR2) IS

	CURSOR bdgt_encum_details is
	SELECT project_id,
		budget_version_id,
		budget_ccid,
		period_name,
		sum(nvl(accounted_dr,0)),
		sum(nvl(accounted_cr,0))
	FROM pa_bc_packets
	WHERE packet_id = p_packet_id
	AND   substr(nvl(result_code,'P'),1,1)  =  'P'
	AND  status_code = 'A'
	AND  NVL(ext_bdgt_flag,'N') = 'Y'  /*PAM changes */
	GROUP BY  project_id,
		  budget_version_id,
		  budget_ccid,
		  period_name
	ORDER BY  project_id,
		  budget_version_id,
		  budget_ccid,
		  period_name;

	l_num_rows	NUMBER := 200;
	l_error_msg_code  VARCHAR2(1000);
	l_return_status   VARCHAR2(100);
	l_msg_count       NUMBER;
	l_debug_stage    varchar2(10000);
	l_bdgt_acct_amt  Number;

BEGIN
	g_debug_mode := 'Y';
	--Initialize the error stack
	PA_DEBUG.init_err_stack('PA_FUNDS_CONTROL_PKG.upd_bdgt_encum_bal');
	IF g_debug_mode = 'Y' THEN
		log_message(p_msg_token1 => 'inside the  update budget acct api'||
	 	'calling module ['||p_calling_module||']p_mode ['||p_mode||
	 	']p_packet_status ['||p_packet_status ||']' );
	End if;

	x_return_status := 'S';

	IF p_packet_status = 'S' and p_mode in ('R','U','F') then

	    OPEN bdgt_encum_details;
	    LOOP
		g_tab_project_id.delete;
		g_tab_budget_version_id.delete;
		g_tab_budget_ccid.delete;
		g_tab_period_name.delete;
		g_tab_accounted_dr.delete;
		g_tab_accounted_cr.delete;
		g_tab_encum_type_id.delete;
		g_tab_gl_date.delete;
		g_tab_doc_type.delete;

		FETCH bdgt_encum_details BULK COLLECT INTO
			g_tab_project_id,
                	g_tab_budget_version_id,
                	g_tab_budget_ccid,
                	g_tab_period_name,
                	g_tab_accounted_dr,
                	g_tab_accounted_cr  LIMIT l_num_rows;
		IF g_debug_mode = 'Y' THEN
	 		log_message(p_msg_token1 => 'fetched rows['||g_tab_project_id.count||']into plsql tables ');
		End if;
		IF NOT g_tab_project_id.EXISTS(1) then
			IF g_debug_mode = 'Y' THEN
				log_message(p_msg_token1 => 'No rows found exit ');
			End if;
			EXIT;
		END IF;
		log_message(p_msg_token1 => 'Calling UPD_BDGT_ACCT_BAL api in Loop');
		FOR i IN g_tab_budget_ccid.FIRST .. g_tab_budget_ccid.LAST LOOP
				l_bdgt_acct_amt := (nvl(g_tab_accounted_dr(i),0) - nvl(g_tab_accounted_cr(i),0));
				IF g_debug_mode = 'Y' THEN
					log_message(p_msg_token1 => 'calling pa_budget_fund_pkg.UPD_BDGT_ACCT_BAL api ');
					l_debug_stage := 'p_gl_period_name ['||g_tab_period_name(i)||']p_budget_version_id [';
					l_debug_stage := l_debug_stage||g_tab_budget_version_id(i)||']p_ccid [';
					l_debug_stage := l_debug_stage||g_tab_budget_ccid(i)||']p_amount [';
					l_debug_stage := l_debug_stage||l_bdgt_acct_amt||']' ;
					log_message(p_msg_token1 => l_debug_stage);
				End if;
				If NVL(l_bdgt_acct_amt,0) <> 0 Then
					pa_budget_fund_pkg.UPD_BDGT_ACCT_BAL
				 	(p_gl_period_name 	=> g_tab_period_name(i),
				  	p_budget_version_id 	=> g_tab_budget_version_id(i),
				  	p_ccid			=> g_tab_budget_ccid(i),
				  	p_amount  		=> l_bdgt_acct_amt,
				  	x_msg_data   		=> l_error_msg_code,
				  	x_msg_count  		=> l_msg_count,
				  	x_return_status  	=> l_return_status
					);
				End if;
				IF g_debug_mode = 'Y' THEN
			 		log_message(p_msg_token1 => 'end of UPD_BDGT_ACCT_BAL apirestun status ='||l_return_status);
				End if;

		END LOOP;
		--COMMIT;
		EXIT WHEN bdgt_encum_details%NOTFOUND;
	    END LOOP;
	    CLOSE bdgt_encum_details;

	END IF; -- end if for packet status

	pa_debug.reset_err_stack;

	RETURN;

EXCEPTION
	when others then
		IF bdgt_encum_details%isopen then
			close bdgt_encum_details;
		END IF;
		x_return_status := 'T';
		result_status_code_update
			(p_packet_id => p_packet_id,
			 p_result_code => 'F162',
			 p_res_result_code => 'F162',
			 p_res_grp_result_code => 'F162',
			 p_task_result_code => 'F162',
			 p_top_task_result_code => 'F162',
			 p_project_result_code => 'F162',
			 p_proj_acct_result_code => 'F162',
			 p_status_code => 'T');
		If g_debug_mode = 'Y' Then
                	log_message(p_msg_token1 => 'failed in upd bdgt encum bal api SQLERR :'||sqlcode||sqlerrm);
		End if;
		Raise;
END upd_bdgt_encum_bal;

-------->6599207 ------As part of CC Enhancements
PROCEDURE create_liqd_entry
	(p_packet_id 		IN NUMBER,
	 p_calling_module  	IN varchar2,
	 p_reference2           IN varchar2,
	 p_reference1           IN varchar2,
	 p_mode           	IN varchar2,
	 p_packet_status  	IN varchar2,
	 x_return_status  	OUT NOCOPY varchar2) IS

	l_max_batch_line_id    number(10);

BEGIN
        --Initialize the error stack
        PA_DEBUG.init_err_stack('PA_FUNDS_CONTROL_PKG.create_liqd_entry');

        x_return_status := 'S';
	If g_debug_mode = 'Y' Then
		log_message(p_msg_token1 => 'Inside the create_liqd_entry api ');
	End if;
	/** Bug fix : 1900229 During Check mode also insert liquidation and burden transaction
         *  to gl_bc_packets and igc_cc_interface tables
         */

        IF p_calling_module = 'CBC' and p_mode in ('R','U','C','F') then

		SELECT nvl(MAX(batch_line_num),0)
		INTO l_max_batch_line_id
		FROM igc_cc_interface
		WHERE document_type = 'CC'
		AND   cc_header_id = p_reference2;


		INSERT INTO igc_cc_interface(
		CC_HEADER_ID,
 		CC_VERSION_NUM,
 		CC_ACCT_LINE_ID,
 		CC_DET_PF_LINE_ID ,
 		CODE_COMBINATION_ID,
 		BATCH_LINE_NUM ,
 		CC_TRANSACTION_DATE ,
 		CC_FUNC_DR_AMT ,
 		CC_FUNC_CR_AMT ,
 		JE_SOURCE_NAME ,
 		JE_CATEGORY_NAME,
 		PERIOD_SET_NAME ,
 		PERIOD_NAME ,
 		ACTUAL_FLAG ,
 		BUDGET_DEST_FLAG ,
 		SET_OF_BOOKS_ID  ,
 		ENCUMBRANCE_TYPE_ID ,
 		CBC_RESULT_CODE ,
 		STATUS_CODE ,
 		BUDGET_VERSION_ID ,
 		BUDGET_AMT ,
 		COMMITMENT_ENCMBRNC_AMT ,
 		OBLIGATION_ENCMBRNC_AMT  ,
 		CC_ENCMBRNC_DATE ,
 		FUNDS_AVAILABLE_AMT ,
 		CURRENCY_CODE ,
 		TRANSACTION_DESCRIPTION  ,
 		REFERENCE_1 ,
 		REFERENCE_2 ,
 		REFERENCE_3 ,
 		REFERENCE_4 ,
 		REFERENCE_5 ,
 		REFERENCE_6 ,
 		REFERENCE_7 ,
 		REFERENCE_8 ,
 		REFERENCE_9 ,
 		REFERENCE_10,
 		LAST_UPDATE_DATE ,
 		LAST_UPDATED_BY  ,
 		LAST_UPDATE_LOGIN ,
 		CREATION_DATE ,
 		CREATED_BY  ,
 		DOCUMENT_TYPE,
		Project_line
 		--BATCH_ID  ,
 		--PA_FLAG ,
 		--RESULT_CODE_LEVEL ,
 		--RESULT_CODE_SOURCE
		)
	       SELECT
                igc.CC_HEADER_ID,
                igc.CC_VERSION_NUM,
                igc.CC_ACCT_LINE_ID,
                igc.CC_DET_PF_LINE_ID ,
                pbc.txn_ccid,
                l_max_batch_line_id + to_number(rownum), --igc.BATCH_LINE_NUM ,
                igc.CC_TRANSACTION_DATE ,
                decode(nvl(pbc.accounted_cr,0),0,NULL,pbc.accounted_cr),
                decode(nvl(pbc.accounted_dr,0),0,NULL,pbc.accounted_dr),
                igc.JE_SOURCE_NAME ,
                igc.JE_CATEGORY_NAME,
                igc.PERIOD_SET_NAME ,
                igc.PERIOD_NAME ,
                'E',
                igc.BUDGET_DEST_FLAG ,
                igc.SET_OF_BOOKS_ID  ,
                pbc.proj_encumbrance_type_id,
                igc.CBC_RESULT_CODE ,
                igc.STATUS_CODE ,
                igc.BUDGET_VERSION_ID ,
                igc.BUDGET_AMT ,
                igc.COMMITMENT_ENCMBRNC_AMT ,
                igc.OBLIGATION_ENCMBRNC_AMT  ,
                igc.CC_ENCMBRNC_DATE ,
                igc.FUNDS_AVAILABLE_AMT ,
                igc.CURRENCY_CODE ,
                igc.TRANSACTION_DESCRIPTION  ,
                igc.REFERENCE_1 ,
                igc.REFERENCE_2 ,
                igc.REFERENCE_3 ,
                igc.REFERENCE_4 ,
                igc.REFERENCE_5 ,
                igc.REFERENCE_6 ,
                igc.REFERENCE_7 ,
                'PKT_ID:'||pbc.packet_id,  --igc.REFERENCE_8 ,
                'BC_PKT_ID:'||pbc.bc_packet_id, --igc.REFERENCE_9 ,
                igc.REFERENCE_10,
                --igc.REFERENCE_10,
                igc.LAST_UPDATE_DATE ,
                igc.LAST_UPDATED_BY  ,
                igc.LAST_UPDATE_LOGIN ,
                igc.CREATION_DATE ,
                igc.CREATED_BY  ,
                igc.DOCUMENT_TYPE ,
		'Y'
                --igc.BATCH_ID  ,
                --igc.PA_FLAG ,
                --igc.RESULT_CODE_LEVEL ,
                --igc.RESULT_CODE_SOURCE
		FROM  igc_cc_interface igc,
	      		pa_bc_packets pbc
		WHERE pbc.packet_id = p_packet_id
		AND   pbc.document_header_id = igc.cc_header_id
		AND   pbc.document_distribution_id = igc.cc_acct_line_id
		AND   pbc.document_type in ('CC_C_CO','CC_P_CO')
                AND  pa_funds_control_utils.get_bdgt_link(
                     pbc.project_id,decode(pbc.document_type,'CC_C_CO','CBC',
                                                                'CC_P_CO','CBC',
                                                                'STD')) = 'Y'
		AND  pbc.status_code NOT IN ('Z','T','V','B')
		AND   substr(nvl(pbc.result_code,'P'),1,1) = 'P'
		AND   ( pbc.gl_row_number = igc.rowid
			OR
			(to_char(pbc.bc_packet_id) = substr(igc.reference_9,
                                                 length('BC_PKT_ID:')+1)
			)
		      );
		If g_debug_mode = 'Y' Then
			log_message(p_msg_token1 => 'No of rows inserted into CBC = '||sql%rowcount);
		End if;

        END IF;

	pa_debug.reset_err_stack;
	return;
EXCEPTION
        when others then
                result_status_code_update
                        (p_packet_id => p_packet_id,
                         p_result_code => 'F161',
                         p_res_result_code => 'F161',
                         p_res_grp_result_code => 'F161',
                         p_task_result_code => 'F161',
                         p_top_task_result_code => 'F161',
                         p_project_result_code => 'F161',
                         p_proj_acct_result_code => 'F161',
                         p_status_code => 'T');
                x_return_status := 'T';
		If g_debug_mode = 'Y' Then
                	log_message(p_msg_token1 => 'failed in create liqd entry apiSQLERR :'||sqlcode||sqlerrm);
		End if;
                Raise;

END create_liqd_entry;
-------->6599207 ------END


--------------------------------------------------------------
-- Determine the return code sent to GL / CBC /BASELINE etc
-- based on the full mode or partial mode  the return status
-- declared as success or failure. In partial mode even if there
-- are failed transaction exist in packet, the return status
-- is success since the packet is partially cleared
-- for the full mode even if there exist single failed transaction
-- the whole packet is marked as rejected / failed
--------------------------------------------------------------
PROCEDURE gen_return_code(p_packet_id	IN NUMBER,
			p_partial_flag	IN VARCHAR2,
			p_calling_mode	IN VARCHAR2,
			x_return_status	OUT NOCOPY VARCHAR2) IS

	l_err_code    NUMBER := 0;
	l_return_code varchar2(1):= 'S';
	CURSOR cur_fatal_error IS
                SELECT 1
		FROM DUAL
                WHERE EXISTS (SELECT null
				FROM pa_bc_packets
                		WHERE packet_id = p_packet_id
                		AND status_code = 'T'
			     );

	CURSOR cur_normal_error IS
                SELECT 1
		FROM DUAL
		WHERE EXISTS (SELECT null
                		FROM pa_bc_packets
                		WHERE packet_id = p_packet_id
                		AND SUBSTR ( nvl(result_code,'P'), 1, 1 ) = 'F'
			     );

	/* To check at least one transaction is passed in partial mode */
        CURSOR cur_success_recs IS
                SELECT 1
                FROM DUAL
                WHERE EXISTS (SELECT null
                                FROM pa_bc_packets
                                WHERE packet_id = p_packet_id
                                AND SUBSTR ( nvl(result_code,'P'), 1, 1 ) = 'P'
                             );

BEGIN

	-- Initialize the error stack
	PA_DEBUG.init_err_stack('PA_FUNDS_CONTROL_PKG.gen_return_code');

	-- Initialize the return status to success
	x_return_status := l_return_code;

	-- check for fatal error in the packet
	OPEN cur_fatal_error;
	FETCH cur_fatal_error INTO l_err_code;
	IF cur_fatal_error%notfound then
		-- check for normal error
		OPEN cur_normal_error;
		FETCH cur_normal_error INTO l_err_code;
		IF cur_normal_error%notfound then
			l_err_code := 0;
			l_return_code := 'S';
		ELSE
			IF p_partial_flag <> 'Y' then -- full mode
				l_err_code := 1;
				l_return_code := 'F';
			ELSE  -- partial mode
				-- check for any of the transaction passes the funds check
				OPEN cur_success_recs;
				FETCH cur_success_recs INTO l_err_code;
				IF cur_success_recs%notfound then
					l_err_code := 1;
					l_return_code := 'F';
				Else
					l_err_code := 0;
					l_return_code := 'S';
				End If;
				CLOSE cur_success_recs;
			END IF;
		END IF;
		CLOSE cur_normal_error;
	ELSE
		l_return_code := 'T';
		l_err_code := 1;

	END IF;
	CLOSE cur_fatal_error;

	IF l_err_code <> 0 and l_return_code <> 'S' then
		x_return_status := l_return_code;
	END IF;

	-- reset the error stack
	PA_DEBUG.reset_err_stack;

	return;

EXCEPTION
	when others then
		If cur_normal_error%ISOPEN THEN
			CLOSE cur_normal_error;
		END IF;
		IF cur_fatal_error%ISOPEN THEN
			CLOSE cur_fatal_error;
		END IF;
		IF cur_success_recs%ISOPEN THEN
                        CLOSE cur_success_recs;
                END IF;
                result_status_code_update(p_packet_id => p_packet_id,
                       p_result_code => 'F160',
                        p_status_code => 'T',
                        p_res_result_code => 'F160',
                        p_res_grp_result_code => 'F160',
                        p_task_result_code => 'F160',
                        p_top_task_result_code => 'F160',
                        p_project_result_code => 'F160',
                        p_proj_acct_result_code => 'F160');
		If g_debug_mode = 'Y' Then
			log_message(p_msg_token1 => 'Failed in gen_return_code api unexpected Error '|| sqlcode||sqlerrm);
		End if;
		log_message(p_error_msg => sqlcode||sqlerrm);

		x_return_status := 'T';
		return;
END gen_return_code;

-------->6599207 ------As part of CC Enhancements
PROCEDURE Post_Bdn_Lines_To_GL_CBC (
   	p_Packet_ID		IN	Number,
	p_calling_module	IN      VARCHAR2,
	p_packet_status		IN 	VARCHAR2,
	p_reference1		IN 	VARCHAR2,
	p_reference2		IN 	VARCHAR2,
   	x_return_status		OUT NOCOPY	VARCHAR2
   	) IS

   	l_BCPacketID		Number(15);
   	l_GLRowNumber	GL_BC_Packets.Originating_RowID%Type;
	l_cbcrownumber  urowid;
	l_max_batch_line_id   number(15);

	--This cursor is defined to pick up all the burden cost lines
	--from the PA_BC_Packets table among other transactions.

   	CURSOR c_Burden_Costs IS
      	SELECT BC_Packet_ID
        FROM PA_BC_Packets
        WHERE Packet_ID=p_Packet_ID AND
        Parent_BC_Packet_ID IS NOT NULL;

	-- This cursor is defined to pick up the Row Number in the GL_BC_Packets
	-- table that corresponds to the BCPacket ID stored in PA_BC_Packets table.

   	CURSOR c_Row_Number(
      		l_BCPacketID	IN	Number) IS
      	SELECT RowID
        FROM GL_BC_Packets
        WHERE Template_ID=l_BCPacketID;

	l_rowcount	NUMBER := 0;

BEGIN

   	x_return_status := FND_API.G_RET_STS_SUCCESS;

   	pa_debug.init_err_stack ('PA_Funds_Control_Pkg.Post_Burden_Lines_To_GL');

	If g_debug_mode = 'Y' Then
		log_message(p_msg_token1 => 'Inside the Post_Burden_Lines_To_GL api');
	End if;

	IF p_calling_module = 'CBC'  then
		SELECT nvl(MAX(batch_line_num),0)
                INTO l_max_batch_line_id
                FROM igc_cc_interface
                WHERE document_type = 'CC'
                AND   cc_header_id = p_reference2;

		INSERT INTO igc_cc_interface(
		CC_HEADER_ID,
 		CC_VERSION_NUM,
 		CC_ACCT_LINE_ID,
 		CC_DET_PF_LINE_ID ,
 		CODE_COMBINATION_ID,
 		BATCH_LINE_NUM ,
 		CC_TRANSACTION_DATE ,
 		CC_FUNC_DR_AMT ,
 		CC_FUNC_CR_AMT ,
 		JE_SOURCE_NAME ,
 		JE_CATEGORY_NAME,
 		PERIOD_SET_NAME ,
 		PERIOD_NAME ,
 		ACTUAL_FLAG ,
 		BUDGET_DEST_FLAG ,
 		SET_OF_BOOKS_ID  ,
 		ENCUMBRANCE_TYPE_ID ,
 		CBC_RESULT_CODE ,
 		STATUS_CODE ,
 		BUDGET_VERSION_ID ,
 		BUDGET_AMT ,
 		COMMITMENT_ENCMBRNC_AMT ,
 		OBLIGATION_ENCMBRNC_AMT  ,
 		CC_ENCMBRNC_DATE ,
 		FUNDS_AVAILABLE_AMT ,
 		CURRENCY_CODE ,
 		TRANSACTION_DESCRIPTION  ,
 		REFERENCE_1 ,
 		REFERENCE_2 ,
 		REFERENCE_3 ,
 		REFERENCE_4 ,
 		REFERENCE_5 ,
 		REFERENCE_6 ,
 		REFERENCE_7 ,
 		REFERENCE_8 ,
 		REFERENCE_9 ,
 		REFERENCE_10,
 		LAST_UPDATE_DATE ,
 		LAST_UPDATED_BY  ,
 		LAST_UPDATE_LOGIN ,
 		CREATION_DATE ,
 		CREATED_BY  ,
 		DOCUMENT_TYPE    ,
		Project_Line
 		--BATCH_ID  ,
 		--PA_FLAG ,
 		--RESULT_CODE_LEVEL ,
 		--RESULT_CODE_SOURCE
		)
	       SELECT
                igc.CC_HEADER_ID,
                igc.CC_VERSION_NUM,
                igc.CC_ACCT_LINE_ID,
                igc.CC_DET_PF_LINE_ID ,
                pbc.txn_ccid,
                l_max_batch_line_id + to_number(rownum), -- igc.BATCH_LINE_NUM ,
                igc.CC_TRANSACTION_DATE ,
                decode(nvl(pbc.accounted_dr,0),0,NULL,pbc.accounted_dr),
		decode(nvl(pbc.accounted_cr,0),0,NULL,pbc.accounted_cr),
                igc.JE_SOURCE_NAME ,
                igc.JE_CATEGORY_NAME,
                igc.PERIOD_SET_NAME ,
                igc.PERIOD_NAME ,
                igc.actual_flag,
                igc.BUDGET_DEST_FLAG ,
                igc.SET_OF_BOOKS_ID  ,
                pbc.encumbrance_type_id,
                igc.CBC_RESULT_CODE ,
                igc.STATUS_CODE ,
                igc.BUDGET_VERSION_ID ,
                igc.BUDGET_AMT ,
                igc.COMMITMENT_ENCMBRNC_AMT ,
                igc.OBLIGATION_ENCMBRNC_AMT  ,
                igc.CC_ENCMBRNC_DATE ,
                igc.FUNDS_AVAILABLE_AMT ,
                igc.CURRENCY_CODE ,
                igc.TRANSACTION_DESCRIPTION  ,
                igc.REFERENCE_1 ,
                igc.REFERENCE_2 ,
                igc.REFERENCE_3 ,
                igc.REFERENCE_4 ,
                igc.REFERENCE_5 ,
                igc.REFERENCE_6 ,
                igc.REFERENCE_7 ,
                'PKT_ID:'||pbc.packet_id,  --igc.REFERENCE_8 , /** checked with Arkadi cbc team **/
                'BC_PKT_ID:'||pbc.bc_packet_id, --igc.REFERENCE_9 , /** to use these two columns **/
                igc.REFERENCE_10,
                igc.LAST_UPDATE_DATE ,
                igc.LAST_UPDATED_BY  ,
                igc.LAST_UPDATE_LOGIN ,
                igc.CREATION_DATE ,
                igc.CREATED_BY  ,
                igc.DOCUMENT_TYPE ,
		'Y'
                --igc.BATCH_ID  ,
                --igc.PA_FLAG ,
                --igc.RESULT_CODE_LEVEL ,
                --igc.RESULT_CODE_SOURCE
		FROM  igc_cc_interface igc,
	      		pa_bc_packets pbc
		WHERE pbc.packet_id = p_packet_id
		AND   pbc.document_type in ('CC_C_CO','CC_P_CO')
		/*** bug fix : 1883119
		   AND   ( pbc.status_code = 'P'
                         OR (pbc.status_code in ('P','S') and g_mode = 'C')
                       )
		**/
		AND  pbc.status_code NOT IN ('Z','T','V','B','L')
		AND   substr(nvl(pbc.result_code,'P'),1,1) = 'P'
		AND   pbc.document_header_id = igc.cc_header_id
		AND   pbc.document_distribution_id = igc.cc_acct_line_id
                AND  (  ( pbc.parent_bc_packet_id is NOT NULL)
                        or (pbc.parent_bc_packet_id is NULL
                            and check_bdn_on_sep_item (pbc.project_id) = 'S')
                      )
		ANd   igc.document_type = 'CC';
		l_rowcount := sql%rowcount;
		If g_debug_mode = 'Y' Then
			log_message(p_msg_token1 => 'No of rows inseted to IGC = '||l_rowcount);
		End if;

	END IF;
   	pa_debug.reset_err_stack ;

EXCEPTION

   WHEN OTHERS THEN

      	x_return_status := 'T';
	If p_calling_module = 'GL' then
		result_status_code_update(p_packet_id => p_packet_id,
			p_result_code => 'F163',
			p_status_code => 'T',
			p_res_result_code => 'F163',
			p_res_grp_result_code => 'F163',
			p_task_result_code => 'F163',
			p_top_task_result_code => 'F163',
			p_project_result_code => 'F163',
			p_proj_acct_result_code => 'F163');
	Elsif p_calling_module = 'CBC' then
                result_status_code_update(p_packet_id => p_packet_id,
                        p_result_code => 'F164',
                        p_status_code => 'T',
                        p_res_result_code => 'F164',
                        p_res_grp_result_code => 'F164',
                        p_task_result_code => 'F164',
                        p_top_task_result_code => 'F164',
                        p_project_result_code => 'F164',
                        p_proj_acct_result_code => 'F164');
	End if;
	If g_debug_mode = 'Y' Then
                log_message(p_msg_token1 => 'failed in post_bdn_lines_gl_cbc apiSQLERR :'||sqlcode||sqlerrm);
	End if;
                --commit;
   	Raise;
END Post_Bdn_Lines_To_GL_CBC;
-------->6599207 ------END

----------------------------------------------------------------
--This procedure updates the result and status code in GL /CBc
-- packets when the project funds check process fails
----------------------------------------------------------------
PROCEDURE update_GL_CBC_result_code(
	p_packet_id    	  IN  number,
	p_calling_module  IN  varchar2,
	p_mode            IN  varchar2,
        p_partial_flag    IN  varchar2,
	p_reference1      IN  varchar2 default null,
	p_reference2      IN  varchar2 default null,
	p_packet_status   IN  varchar2,
	x_return_status   OUT NOCOPY varchar2) IS

	l_igc_status      varchar2(100);
	l_pkt_fatal_error_flag      varchar2(100):= 'N';

	CURSOR  pkt_status  IS
	SELECT  'Y'
	FROM    pa_bc_packets
	WHERE   status_code = 'T'
	AND     packet_id = p_packet_id
	AND     rownum = 1;

	CURSOR  igc_status(l_cc_header_id number
                          ,l_cc_type varchar2) is
       	SELECT  decode(count(*), count(decode(substr(nvl
			(igc.cbc_result_code,'P'),1,1),'P',1)),'P','F')
        FROM igc_cc_interface igc
        WHERE  igc.cc_header_id = l_cc_header_id;


        CURSOR  gl_status is
        SELECT  decode(count(*), count(decode(substr(nvl
                        (gl.result_code,'P'),1,1),'P',1)),'P','F')
        FROM  gl_bc_packets gl
        WHERE  gl.packet_id = p_packet_id;
BEGIN

	--Initialize the err stack
	PA_DEBUG.init_err_stack('PA_FUNDS_CONTROL_PKG.update_GL_CBC_result_code');

	-- initialize the return status to success
	x_return_status := 'S';
	l_pkt_fatal_error_flag := 'N';
	If g_debug_mode = 'Y' Then
		log_message(p_msg_token1 => 'Inside the update_GL_CBC_result_code api');
	End if;


	IF p_packet_status  in ( 'S','F','T') or g_partial_flag = 'Y'  then

	        OPEN pkt_status;
		FETCH pkt_status INTO l_pkt_fatal_error_flag;
		CLOSE pkt_status;

		IF p_calling_module in ('GL','GL_TIEBACK') and p_mode in ('R','U','C','F') then
			If g_debug_mode = 'Y' Then
				log_message(p_msg_token1 =>' update gl bc packet with result code ');
			End if;
                        UPDATE gl_bc_packets gl
                        SET 	gl.result_code =
				(select MAX(
				   decode(substr(nvl(gl.result_code,'P'),1,1),'P',
				      decode( pbc.result_code,'F100','X00',
					'F101','X59',
					'F102','X60',
					'F103','X61',
					'F104','X62',
					'F105','X63',
					'F106','X64',
					'F107','X29',
					'F108','X30',
					'F109','X31',
					'F110','X32',
					'F111','X33',
					'F112','X34',
					'F113','X35',
					'F114','X36',
					'F115','X36',
					'F116','X36',
					'F117','X36',
					'F118','X38',
					'F119','X37',
					'F120','X36',
					'F121','X40',
					'F122','X41',
					'F123','X42',
					'F124','X43',
					'F125','X44',
					'F127','X45',
					'F128','X46',
					'F129','X47',
					'F130','X48',
					'F131','X49',
					'F132','X50',
					'F134','X51',
					'F135','X52',
					'F136','X36',
					'F137','X54',
					'F138','X55',
					'F140','X36',
					'F141','X56',
					'F142','X36',
					'F143','X53',
					'F144','X36',
					'F145','X36',
					'F146','X36',
					'F160','X36',
					'F161','X36',
					'F162','X36',
					'F163','X36',
					'F164','X36',
					'F165','X39',
					'F166','X38', -- added during CC import testing 2891273
                                        'F168','X36', -- added fo r12 ..
					/** added decodes for stamping advisory warnings bug :1975786 **/
					'P101',decode(pbc.res_result_code,'P112','P35',
						 decode(pbc.res_grp_result_code,'P110','P36',
						  decode(pbc.task_result_code,'P108','P37',
					           decode(pbc.top_task_result_code,'P106','P38',
						    decode(pbc.project_result_code,'P104','P31',
						     decode(pbc.project_acct_result_code,'P102','P29',
							'P28')))))),
					'P102',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P29')))))),
					'P103',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P30')))))),
					'P104',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P31')))))),
					'P105',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P30')))))),
					'P106',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P38')))))),
					'P107',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P30')))))),
					'P108',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P37')))))),
					'P109',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P30')))))),
					'P110',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P36')))))),
					'P111',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P30')))))),
					'P112',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P35')))))),
					'P113','P32',
					'P114','P33',
					'P115','P34',
					'P116','P05',
                                        'F150','F58',
                                        'F151','F58',
                                        'F155','F58',
                                        'F156','F58',
                                        'F152','F57',
                                        'F153','F57',
                                        'F157','F57',
                                        'F158','F57',
                                        'F169','F35',
                                        'F170','F36',
                                        'F171','F36',
                                        'F172','F36',
                                        'F173','F36',
                                        gl.result_code )
					, gl.result_code ))
				from  pa_bc_packets pbc
				where pbc.packet_id                = p_packet_id
                                and   pbc.document_distribution_id = gl.source_distribution_id_num_1
				and   ((pbc.source_event_id        = gl.event_id
                                        and (pbc.document_type     = decode(gl.source_distribution_type,'AP_INV_DIST','AP','AP_PREPAY','AP','X')
                                        OR
                                        pbc.document_type          = decode(gl.source_distribution_type,'PO_DISTRIBUTIONS_ALL','PO','X')
                                        OR
                                        pbc.document_type          = decode(gl.source_distribution_type,'PO_REQ_DISTRIBUTIONS_ALL','REQ','X')
					OR
                                        pbc.document_type          = decode(gl.source_distribution_type,'CC','CC_C_PAY')
					OR
                                        pbc.document_type          = decode(gl.source_distribution_type,'CC','CC_P_PAY')
					)
                                       )
                                       OR
                                       (pbc.bc_event_id          = gl.event_id
                                        and (pbc.document_type   = decode(gl.source_distribution_type,'PA_AP_BURDEN','AP','X')
                                        OR
                                        pbc.document_type        = decode(gl.source_distribution_type,'PA_PO_BURDEN','PO','X')
                                        OR
                                        pbc.document_type         = decode(gl.source_distribution_type,'PA_REQ_BURDEN','REQ','X')
					OR
                                        pbc.document_type          = decode(gl.source_distribution_type,'CC','CC_C_PAY')
					OR
                                        pbc.document_type          = decode(gl.source_distribution_type,'CC','CC_P_PAY')
                                        )
                                       )
                                      )
				)
                        WHERE  gl.packet_id = p_packet_id
                        -- Bug 5352185 : Added the nvl to the following AND condition.
                        AND    nvl(substr(gl.result_code,1,1),'P') not in ('X') -- In AP matched case if PO fails, the PO rec. already failed
                        AND    (gl.event_id, gl.source_distribution_id_num_1
                                --,source_distribution_type
                                ) in
                                (Select  pb.bc_event_id,
                                        pb.document_distribution_id
                                        --,decode(pb.document_type,
                                        --       'AP','AP_INV_DIST',
                                        --       'AP','PA_AP_BURDEN',
                                        --       'PO','PO_DISTRIBUTIONS_ALL',
                                        --       'PO','PA_PO_BURDEN',
                                        --       'REQ','PA_REQ_BURDEN',
                                        --       'REQ','PO_REQ_DISTRIBUTIONS_ALL') source_distribution_type
                                 from   pa_bc_packets pb
                                 where  pb.packet_id = p_packet_id
                                 UNION ALL
                                 Select  pb.source_event_id,
                                        pb.document_distribution_id
                                        --,decode(pb.document_type,
                                        --       'AP','AP_INV_DIST',
                                        --       'AP','PA_AP_BURDEN',
                                        --       'PO','PO_DISTRIBUTIONS_ALL',
                                        --       'PO','PA_PO_BURDEN',
                                        --       'REQ','PA_REQ_BURDEN',
                                        --       'REQ','PO_REQ_DISTRIBUTIONS_ALL') source_distribution_type
                                 from   pa_bc_packets pb
                                 where  pb.packet_id = p_packet_id);

			If g_debug_mode = 'Y' Then
		    		log_message(p_msg_token1 =>'no of rows result code updated after= '||sql%rowcount);
			End if;

            -- Following code is being added as in case of AP-PO matched case, in gl_bc_packets
            -- source_distribution_id_num_1 points to AP
            -- this is only reqd. in case of non-integrated budgets as for non-integrated budgets we do
            -- not create "PA_PO_BURDEN" records so no records in gl_bc_packets gets updated ..

            If nvl(g_ap_matched_case,'N') = 'Y' then
     			If g_debug_mode = 'Y' Then
    				log_message(p_msg_token1 =>' update gl bc packet with result code for PO for AP matched');
	    		End if;

               UPDATE gl_bc_packets gl
                 SET 	gl.result_code =
				(select MAX(
				   decode(substr(nvl(gl.result_code,'P'),1,1),'P',
				      decode( pbc.result_code,'F100','X00',
					'F101','X59',
					'F102','X60',
					'F103','X61',
					'F104','X62',
					'F105','X63',
					'F106','X64',
					'F107','X29',
					'F108','X30',
					'F109','X31',
					'F110','X32',
					'F111','X33',
					'F112','X34',
					'F113','X35',
					'F114','X36',
					'F115','X36',
					'F116','X36',
					'F117','X36',
					'F118','X38',
					'F119','X37',
					'F120','X36',
					'F121','X40',
					'F122','X41',
					'F123','X42',
					'F124','X43',
					'F125','X44',
					'F127','X45',
					'F128','X46',
					'F129','X47',
					'F130','X48',
					'F131','X49',
					'F132','X50',
					'F134','X51',
					'F135','X52',
					'F136','X36',
					'F137','X54',
					'F138','X55',
					'F140','X36',
					'F141','X56',
					'F142','X36',
					'F143','X53',
					'F144','X36',
					'F145','X36',
					'F146','X36',
					'F160','X36',
					'F161','X36',
					'F162','X36',
					'F163','X36',
					'F164','X36',
					'F165','X39',
					'F166','X38', -- added during CC import testing 2891273
                                        'F168','X36', -- added fo r12 ..
					/** added decodes for stamping advisory warnings bug :1975786 **/
					'P101',decode(pbc.res_result_code,'P112','P35',
						 decode(pbc.res_grp_result_code,'P110','P36',
						  decode(pbc.task_result_code,'P108','P37',
					           decode(pbc.top_task_result_code,'P106','P38',
						    decode(pbc.project_result_code,'P104','P31',
						     decode(pbc.project_acct_result_code,'P102','P29',
							'P28')))))),
					'P102',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P29')))))),
					'P103',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P30')))))),
					'P104',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P31')))))),
					'P105',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P30')))))),
					'P106',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P38')))))),
					'P107',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P30')))))),
					'P108',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P37')))))),
					'P109',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P30')))))),
					'P110',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P36')))))),
					'P111',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P30')))))),
					'P112',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P35')))))),
					'P113','P32',
					'P114','P33',
					'P115','P34',
					'P116','P05',
                                        'F150','F58',
                                        'F151','F58',
                                        'F155','F58',
                                        'F156','F58',
                                        'F152','F57',
                                        'F153','F57',
                                        'F157','F57',
                                        'F158','F57',
                                        'F169','F35',
                                        'F170','F36',
                                        'F171','F36',
                                        'F172','F36',
                                        'F173','F36',
                                        gl.result_code )
					, gl.result_code ))
				from  pa_bc_packets pbc
				where pbc.packet_id                = p_packet_id
				and   pbc.document_type            = 'PO'
                and   pbc.bc_event_id is null
                and   pbc.reference3               = gl.source_distribution_id_num_1
                and   (nvl(pbc.accounted_dr,0) - nvl(pbc.accounted_cr,0)) =
                      -1* (nvl(gl.accounted_dr,0) - nvl(gl.accounted_cr,0))
		)
          WHERE  gl.packet_id = p_packet_id
          AND    gl.source_distribution_type = 'AP_INV_DIST'
          AND    substr(gl.result_code,1,1) not in ('X','F')
          AND exists
             (	select 1
                from  pa_bc_packets pbc1
				where pbc1.packet_id                = p_packet_id
				and   pbc1.document_type            = 'PO'
				and   pbc1.bc_event_id is null
                and   pbc1.reference3               = gl.source_distribution_id_num_1
                and   (nvl(pbc1.accounted_dr,0) - nvl(pbc1.accounted_cr,0)) =
                       -1* (nvl(gl.accounted_dr,0) - nvl(gl.accounted_cr,0))
	    );

    	  If g_debug_mode = 'Y' Then
    		log_message(p_msg_token1 =>'(AP match,non int) no of rows,result code updated= '||sql%rowcount);
	  End if;

       End If;


		    IF p_calling_module in ('GL_TIEBACK') then

			open  gl_status;
        		fetch gl_status into l_igc_status;
        		close gl_status;

			If g_debug_mode = 'Y' Then
				log_message(p_msg_token1 =>'p_calling_module ['||p_calling_module||']l_gl_status ['||l_igc_status||']');
			End if;

			UPDATE gl_bc_packets gl
			SET     gl.result_code  = decode(substr(gl.result_code,1,1),'P',
                                                    decode(sign(nvl(gl.accounted_dr,0)  - nvl(gl.accounted_cr,0)),
                                                         -1, 'P32',
							  gl.result_code),gl.result_code),
				gl.status_code = decode(nvl(l_pkt_fatal_error_flag,'N'),'Y','T',
                                decode(p_partial_flag
                                        ,'Y', decode(substr(nvl(gl.result_code,'P'),1,1) ,
                                                'P',gl.status_code,
                                                'F',decode(p_mode,'C','F','R'),
                                                'X',decode(p_mode,'C','F','R'),
                                                 gl.status_code)
                                        ,'N',decode(p_packet_status,
                                                'S',decode(l_igc_status,'P', decode(p_mode,'C','S','A'),
                                                                        'F', decode(p_mode,'C','F','R')),
                                                'F',decode(p_mode,'C','F','R'),
                                                'T',decode(p_mode,'C','F','R'),'R')))
                        WHERE  gl.packet_id = p_packet_id
                        AND    (gl.event_id, gl.source_distribution_id_num_1
                                --,source_distribution_type
                                ) in
                                (Select  pb.bc_event_id,
                                        pb.document_distribution_id
                                        --,decode(pb.document_type,
                                        --       'AP','AP_INV_DIST',
                                        --       'AP','PA_AP_BURDEN',
                                        --       'PO','PO_DISTRIBUTIONS_ALL',
                                        --       'PO','PA_PO_BURDEN',
                                        --       'REQ','PA_REQ_BURDEN',
                                        --       'REQ','PO_REQ_DISTRIBUTIONS_ALL') source_distribution_type
                                 from   pa_bc_packets pb
                                 where  pb.packet_id = p_packet_id
                                 UNION ALL
                                 Select  pb.source_event_id,
                                        pb.document_distribution_id
                                        --,decode(pb.document_type,
                                        --       'AP','AP_INV_DIST',
                                        --       'AP','PA_AP_BURDEN',
                                        --       'PO','PO_DISTRIBUTIONS_ALL',
                                        --       'PO','PA_PO_BURDEN',
                                        --       'REQ','PA_REQ_BURDEN',
                                        --       'REQ','PO_REQ_DISTRIBUTIONS_ALL') source_distribution_type
                                 from   pa_bc_packets pb
                                 where  pb.packet_id = p_packet_id);


			If g_debug_mode = 'Y' Then
				log_message(p_msg_token1 =>'no of rows status code updated after= '||sql%rowcount);
			End if;
		   END IF;

		ELSIF p_calling_module in('CBC','CBC_TIEBACK') and p_mode in ('R','U','C','F') then
			If g_debug_mode = 'Y' Then
				log_message(p_msg_token1 =>' update CBC packet with result code ');
			End if;

                        UPDATE igc_cc_interface igc
                        SET     igc.cbc_result_code =
                                (select MAX(
                                   decode(substr(nvl(igc.cbc_result_code,'P'),1,1),'P',
                                      decode( pbc.result_code,'F100','F00',
					'F101','F59',
					'F102','F60',
					'F103','F61',
					'F104','F62',
					'F105','F63',
					'F106','F64',
					'F107','F29',
					'F108','F30',
					'F109','F31',
					'F110','F32',
					'F111','F33',
					'F112','F34',
					'F113','F35',
					'F114','F36',
					'F115','F36',
					'F116','F36',
					'F117','F36',
					'F118','F38',
					'F119','F37',
					'F120','F36',
					'F121','F40',
					'F122','F41',
					'F123','F42',
					'F124','F43',
					'F125','F44',
					'F127','F45',
					'F128','F46',
					'F129','F47',
					'F130','F48',
					'F131','F49',
					'F132','F50',
					'F134','F51',
					'F135','F52',
					'F136','F36',
					'F137','F54',
					'F138','F55',
					'F140','F36',
					'F141','F56',
					'F142','F36',
					'F143','F53',
					'F144','F36',
					'F145','F36',
					'F146','F36',
					'F160','F36',
					'F161','F36',
					'F162','F36',
					'F163','F36',
					'F164','F36',
					'F165','F39',
                                        'F166','F38', -- added during CC import testing 2891273
					-- added decodes for stamping advisory warnings bug :1975786
					'P101',decode(pbc.res_result_code,'P112','P35',
						 decode(pbc.res_grp_result_code,'P110','P36',
						  decode(pbc.task_result_code,'P108','P37',
					           decode(pbc.top_task_result_code,'P106','P38',
						    decode(pbc.project_result_code,'P104','P31',
						     decode(pbc.project_acct_result_code,'P102','P29',
							'P28')))))),
					'P102',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P29')))))),
					'P103',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P30')))))),
					'P104',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P31')))))),
					'P105',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P30')))))),
					'P106',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P38')))))),
					'P107',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P30')))))),
					'P108',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P37')))))),
					'P109',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P30')))))),
					'P110',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P36')))))),
					'P111',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P30')))))),
					'P112',decode(pbc.res_result_code,'P112','P35',
                                                 decode(pbc.res_grp_result_code,'P110','P36',
                                                  decode(pbc.task_result_code,'P108','P37',
                                                   decode(pbc.top_task_result_code,'P106','P38',
                                                    decode(pbc.project_result_code,'P104','P31',
                                                     decode(pbc.project_acct_result_code,'P102','P29',
							'P35')))))),
					'P113','P32',
					'P114','P33',
					'P115','P34',
					'P116','P05',
                                        'F150','F58',
                                        'F151','F58',
                                        'F155','F58',
                                        'F156','F58',
                                        'F152','F57',
                                        'F153','F57',
                                        'F157','F57',
                                        'F158','F57', igc.cbc_result_code )
                                        , igc.cbc_result_code))
                                from pa_bc_packets pbc
                                where pbc.packet_id = p_packet_id
                                and   (pbc.gl_row_number = igc.rowid
                                        or
                                       ( substr(igc.reference_9,length('BC_PKT_ID:')+1) in
					  ( pbc.bc_packet_id)
                                        )
                                      )
                                )
                        WHERE   igc.rowid  in (SELECT pkt.gl_row_number
                                          FROM pa_bc_packets pkt
                                          WHERE pkt.packet_id = p_packet_id
                                          AND  pkt.gl_row_number = igc.rowid
                                          )
                                 OR
                                 ( substr(igc.reference_9,length('BC_PKT_ID:')+1) in
                                   ( SELECT pbc.bc_packet_id
                                     FROM   pa_bc_packets pbc
                                     WHERE  pbc.packet_id = substr(reference_8,length('PKT_ID:')+1)
                                     AND    pbc.bc_packet_id = substr(reference_9,length('BC_PKT_ID:')+1)
                                   )
                                 );


		    IF p_calling_module in('CBC','CBC_TIEBACK') then

			  /** the calling module CBC_TIEBACK is used to update the
                            * status code in igc_cc_interface table if pa pass and
                            * cbc fc fails, if pa fails then cbc doesnot call tie back
                            * since payment forcast lines are not funds checked we
                            * should not update  the status code of payment forcast line
                            */

        		open igc_status(p_reference2,p_reference1);
        		fetch igc_status into l_igc_status;
        		close igc_status;

                        UPDATE igc_cc_interface igc
                        SET     igc.cbc_result_code  = decode(substr(cbc_result_code,1,1),'P',
							decode(sign(nvl(igc.cc_func_dr_amt,0)
								  - nvl(igc.cc_func_cr_amt,0)),
							   -1, 'P32',
							-- 	--1,'P28', commented for bug :1975786
								cbc_result_code),cbc_result_code),
				igc.status_code  = decode(nvl(l_pkt_fatal_error_flag,'N'),'Y','T',
                                decode(p_partial_flag
                                        ,'Y', decode(substr(nvl(igc.cbc_result_code,'P'),1,1) ,
                                                'P',igc.status_code,
                                                'F',decode(p_mode,'C','F','R'),
                                                'X',decode(p_mode,'C','F','R'),
                                                 igc.status_code)
                                        ,'N',decode(p_packet_status,
                                                'S',decode(l_igc_status,'P', decode(p_mode,'C','S','A'),
                                                                        'F', decode(p_mode,'C','F','R')),
                                                'F',decode(p_mode,'C','F','R'),
                                                'T',decode(p_mode,'C','F','R'),'R')))
			WHERE  ((p_calling_module = 'CBC_TIEBACK'
				and igc.cc_header_id = p_reference2)
			        OR
                               ( p_calling_module = 'CBC' and
				(igc.cc_header_id,igc.cc_acct_line_id) in
                               (SELECT pkt.document_header_id,pkt.document_distribution_id
                                FROM pa_bc_packets pkt
                                WHERE pkt.packet_id = p_packet_id
                                AND   pkt.document_header_id = igc.cc_header_id
                                AND   pkt.document_distribution_id = igc.cc_acct_line_id
                                AND   pkt.document_type in ('CC_C_CO','CC_P_CO')
                                )));


		   END IF;
		   If g_debug_mode = 'Y' Then
		   	log_message(p_msg_token1 =>'no of rows updated = '||sql%rowcount);
		   End if;

	     END IF;

	END IF;
        If gl_status%isopen then
                close gl_status;
        End if;
        If igc_status%isopen then
                close igc_status;
        End if;
	If pkt_status%isopen then
		close pkt_status;
	End if;

	-- reset the error stack
	PA_DEBUG.reset_err_stack;

	Return;

EXCEPTION
	WHEN OTHERS THEN
		If gl_status%isopen then
			close gl_status;
		End if;
		If igc_status%isopen then
			close igc_status;
		End if;
        	If pkt_status%isopen then
                	close pkt_status;
        	End if;
		--log_message(p_return_status => 'T');
		g_return_status := 'T';
		x_return_status := 'T';
		If g_debug_mode = 'Y' Then
                	log_message(p_msg_token1 => 'failed in update gl cbc result code apiSQLERR :'||sqlcode||sqlerrm);
		End if;
		Raise;
END update_GL_CBC_result_code;
---------------------------------------------------------------------
-- This APi checks whether the project is under base line process
-- if so updates the bc packets with rejection status and returns
---------------------------------------------------------------------
FUNCTION is_project_baseline
                (p_calling_module  IN varchar2,
                p_packet_id  IN number) RETURN BOOLEAN is
        PRAGMA AUTONOMOUS_TRANSACTION;
	l_status_flag  BOOLEAN := true;
	l_num_rows	NUMBER := 100;
	l_lck_number    NUMBER;
	l_bdgt_type     varchar2(30);
	l_yr_end_rollover_flag   varchar2(10);
	l_pre_project_id    pa_bc_packets.project_id%type :=  NULL;
	CURSOR cur_projects IS
	SELECT project_id
	FROM pa_bc_packets
	WHERE packet_id = p_packet_id;

BEGIN
	/* Intialize the default values for flag variables */
	l_yr_end_rollover_flag := 'N';
	l_status_flag := true;

	IF p_calling_module not in ( 'RESERVE_BASELINE')  then

		OPEN cur_projects;
		LOOP
			g_tab_project_id.delete;
			If NOT l_status_flag then
				EXIT;
			END IF;
			FETCH cur_projects BULK COLLECT INTO
				g_tab_project_id LIMIT l_num_rows;
			If NOT g_tab_project_id.EXISTS(1) then
				EXIT;
			End if;
			FOR i IN g_tab_project_id.FIRST .. g_tab_project_id.LAST LOOP
				IF l_pre_project_id is NULL or
				    l_pre_project_id  <> g_tab_project_id(i) then

				        /** Added the Phase II changes Yr end rollover **/
					If p_calling_module = 'CBC' then
					      l_bdgt_type := 'CBC';
				        Else
					      l_bdgt_type := 'STD';
					End if;
					l_yr_end_rollover_flag := PA_FUNDS_CONTROL_UTILS.
								  get_fnd_reqd_flag(g_tab_project_id(i),
									            l_bdgt_type);
					IF l_yr_end_rollover_flag = 'R' then
					   /** Year End Rollover process is in progress
					    * so mark the transaction as failes
					    */
						l_status_flag := FALSE;
						If g_debug_mode = 'Y' Then
                                                	log_message(p_msg_token1 => 'Yr End Rollover is in progress');
						End if;
                                                EXIT;
                                        END IF;

					IF (pa_debug.acquire_user_lock('BSLNFCHKLOCK:'||
						g_tab_project_id(i))) = 0 then
					    -- if the lock is acquired for  project
					    -- indicates the budget is not under baseline
					    -- for this project so release the lock
					     IF (pa_debug.release_user_lock('BSLNFCHKLOCK:'||
						 g_tab_project_id(i))) = 0 then
						  null;
					     END IF;

				        ELSE  -- this project is  under baseline lock
						l_status_flag := FALSE;
						If g_debug_mode = 'Y' Then
							log_message(p_msg_token1 => 'Budget Baseline is under progress');
						End if;
						EXIT;
					END IF;
				END IF;
				l_pre_project_id  := g_tab_project_id(i);

			END LOOP;

			EXIT when cur_projects%NOTFOUND;

		END LOOP;
		CLOSE cur_projects;

		IF l_status_flag = FALSE and l_yr_end_rollover_flag = 'N' then
			-- Error F143 = 'Funds check failed as Budget Baseline is under progress'
			result_status_code_update(
				p_status_code => 'R',
				p_result_code => 'F143',
				p_res_result_code => 'F143',
				p_res_grp_result_code => 'F143',
				p_task_result_code => 'F143',
				p_top_task_result_code => 'F143',
				p_project_result_code => 'F143',
				p_proj_acct_result_code => 'F143',
				p_packet_id  => p_packet_id);

		Elsif l_status_flag = FALSE and l_yr_end_rollover_flag = 'R' then
                        -- Error F119 = 'Failed due to Year end rollover process is in progress'
                        result_status_code_update(
                                p_status_code => 'R',
                                p_result_code => 'F119',
                                p_res_result_code => 'F119',
                                p_res_grp_result_code => 'F119',
                                p_task_result_code => 'F119',
                                p_top_task_result_code => 'F119',
                                p_project_result_code => 'F119',
                                p_proj_acct_result_code => 'F119',
                                p_packet_id  => p_packet_id);
		End IF;
	END IF;
	If cur_projects%isopen then
		close cur_projects;
	End if;
	COMMIT ; -- to end an active autonomous transaction
	REturn l_status_flag;

EXCEPTION
	WHEN OTHERS THEN
        	If cur_projects%isopen then
                	close cur_projects;
        	End if;
		l_lck_number := pa_debug.release_user_lock('BSLNFCHKLOCK:'|| l_pre_project_id);
		result_status_code_update
		(p_status_code => 'T',
		 p_packet_id  => p_packet_id);
		If g_debug_mode = 'Y' Then
                	log_message(p_msg_token1 => 'failed in is_project_baseline apSQLERR :'||sqlcode||sqlerrm);
		End if;
                --commit;
		Raise;


END is_project_baseline;
/*****************************************************************************************************
*This is the Main funds check function which calls all the other functions and procedures.
*This API is called from the following places
* 	 GL - Funds check process
*	 CBC - Funds check process
*	 Costing - During Expenditure Cost Distribution process
*	 Transaction Import Process
*	 Baseline of Budget
*
*  Parameters :
*      p_set_of_books_id    	: Set of Books ID   in GL accounts for the packet to funds checked.
*      p_calling_module          : Identifier of the module from which the funds checker will be invoked
*				  The valid values are
* 					GL  - General ledger
* 					CBC  - Contract Conmmitment
*- 					CHECK_BASELINE  -  Budget Baselining (from r12 .. no such mode)
*-					RESERVE_BASELINE  - for delta protion ( conccurance issue)
* 					TRXIMPORT  -  Transaction Import
* 					DISTVIADJ      -  Invoice Adjustments
* 					DISTERADJ    -  Expense Report Adjustments
* 					INTERFACVI    -  Interface VI to payables
* 					INTERFACER      -  Interface ER to payables
*					EXPENDITURE   - For actuals entering through Projects
*                                       DISTCWKST -- for Distribute labor process for cwk transactions only
*                                       DISTBTC -- create and distribute burden process (burden recompile process)
*
*      P_packet_id  		: Packet ID of the packet to be funds checked.
*      P_mode                  	: Funds Checker Operation Mode.
*              				C  - Check funds
*                    				R  - Reserve funds.
*               				U  - Un-reserve  (only for REQ,PO and AP)
*              				B  - Called from budget baseline process  (Processed like check funds)
*                    				S  - Called from Budget submission     (Processed like check funds)
*						     (From r12 on - not used)
*						A  - Adjustment same as Reserve funds (called from PO,REQ)
*					        F  - Force Pass mode (called from Contract Commitments)
*      P_partial_flag     	: Indicates the packet can be fundschecked/reserverd partially or not
*               				Y  - Partial
*               				N  - Full mode, default is N
*      P_reference1		If the p_mode  is  'R',U,C,F' and p_calling_module = 'CBC'or 'EXP' then
*    					this parameter holds the document type info Document Type
*  					EXP  - Expenditures originating from project
*  					CC    -   Contract Commitments
*              			Elsif  p_mode is  B, S and p_calling_module = 'BASELINE' then
*    					this parameter holds the ext_bdgt_link_flag
*   				End if;
*                             	*  This param is not null for EXP , CC  document type and Base line mode
*      P_reference2 		If the p_mode is  'R',U,C,F' and p_calling_module = 'CBC'   then
*    					this parameter holds the document header info for Contract Commitment
*					document  Header Id  from Contract Commitments
*   					IGC_CC_INTERFACE.CC_HEADER_ID
*              			Elsif  p_mode is  B, S and p_calling_module = 'BASELINE' then
*    					this parameter holds the project_id
*				End if;
*				*  This param is not null for CC   document type   and Base line mode
*      P_reference3            	If p_mode is  B, S and p_calling_module = 'BASELINE' then
*    					this parameter holds the budget_version_id
*				End if;
*				*  This param is not null for  Base line mode and Contract commitments
*
*      p_conc_flag		: identifies when funds check is invoked from concurrent program.
*				The valid values are
*					'N'  default
*					'Y'  - concurrent programm
*
*      x_return_status  		: Fudscheck return status
* 				Valid Status are
*					S  -  Success
*					F  -  Failure
*					T  -  Fatal
*      x_error_stage		:Identifies the place where funds check process failed
*
*      x_error_messagee		:defines the type of error : SQLerror||sqlcode
*
*
*NOTE : p_packet_id will be null for Contract commitments so the packet id to be generated
* if the p_calling_module  is 'CBC'.
* if the p_calling_module is  TRXIMPORT then set_of_books_id to be generated
****************************************************************************************************************/
FUNCTION pa_funds_check
       (p_calling_module		IN      VARCHAR2
       ,p_conc_flag			IN      VARCHAR2 DEFAULT 'N'
       ,p_set_of_book_id                IN      NUMBER
       ,p_packet_id                     IN      NUMBER
       ,p_mode                          IN      VARCHAR2 DEFAULT 'C'
       ,p_partial_flag                  IN      VARCHAR2 DEFAULT 'N'
       ,p_reference1                    IN      VARCHAR2  DEFAULT NULL
       ,p_reference2                    IN      VARCHAR2  DEFAULT NULL
       ,p_reference3                    IN      VARCHAR2 DEFAULT NULL
       ,x_return_status			OUT NOCOPY  	VARCHAR2
       ,x_error_msg			OUT NOCOPY  	VARCHAR2
       ,x_error_stage                   OUT NOCOPY     VARCHAR2
         )   RETURN BOOLEAN IS


        x_e_code        VARCHAR2(10);
        x_e_stage       VARCHAR2(2000);

	CURSOR cur_packets  IS
	SELECT gl_bc_packets_s.nextval
	FROM dual;

	CURSOR cur_sob(v_packet_id  number) IS
	SELECT set_of_books_id
	FROM pa_bc_packets
	WHERE packet_id = v_packet_id;

        l_arrival_seq           NUMBER;
	l_packet_id		pa_bc_packets.packet_id%type;
	l_set_of_books_id	pa_bc_packets.set_of_books_id%type;
        l_err_code              NUMBER                  := 0;
        l_err_buff              VARCHAR2 ( 2000 )       := NULL;
        l_return_code           VARCHAR2 ( 1 );
        l_result_code           VARCHAR2 ( 1 )          := 'P';
        l_status                VARCHAR2 ( 1 );
        l_doc_type              VARCHAR2(30);
        l_return_status         VARCHAR2(30);
	l_packet_status		VARCHAR2(30);
        l_error_stage           VARCHAR2(20);
        l_err_msg_code          VARCHAR2(30);
        l_E_CODE                NUMBER;
	l_num_rows              number;
	l_mode                  varchar2(10);
	l_debug_mode 		varchar2(10);
        l_calling_code          varchar2(10);

	l_fc_final_exit_flag 	VARCHAR2(100) := 'NORMAL_EXIT';

	               x_resource_list_member_id  number;
               x_resource_id  number;
  -------------------------------------------------------------------------------------------------------
    -- This is local procedure used as  lock  mechanism  After inserting Commit to release the lock
    -- When a lock on  pa_concurrency_control is not available if Funds Checker is invoked from a
    -- Concurrent Process, it waits  if Funds Checker is invoked from an Online Process,
    -- it exits with  an error
 --------------------------------------------------------------------------------------------------------------
BEGIN

        --- Initialize the error statck
        PA_DEBUG.init_err_stack ('PA_FUNDS_CONTROL_PKG.pa_funds_check');

        fnd_profile.get('PA_DEBUG_MODE',g_debug_mode);
        g_debug_mode := NVL(g_debug_mode, 'N');

        PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                      ,x_write_file     => 'LOG'
                      ,x_debug_mode      => g_debug_mode
                          );
	If g_debug_mode = 'Y' then
        	log_message(p_msg_token1 => 'Start Of project Funds check Calling module['
		    || p_calling_module||']calling mode['||p_mode||']reference1['
                    ||p_reference1||']reference2['||p_reference2||']partial flag['
		    ||p_partial_flag||']conc flag['||p_conc_flag||']packet_id['
		    ||p_packet_id||']'  );
	End if;

	/** Bug fix :2302945 If PA is NOT installed in OU then we should return as success
	 ** without proceeding further . This api checks whether the In given operating unit
         ** project is installed or not, if not installed return with success
         **/
	IF IS_PA_INSTALL_IN_OU = 'N' then
 		x_return_status := 'S';
        	g_return_status := 'S';
		If g_debug_mode = 'Y' then
			log_message(p_msg_token1=>'PA NOT INSTALLED IN THIS OU.return status='||
					x_return_status);
		End if;
		PA_DEBUG.Reset_err_stack;
		Return True;
	END IF;
	/** End of Bug fix **/

        -------->6599207 ------As part of CC Enhancements
	/* COMMENTING THIS CODE FOR CC ENHANCEMENTS
        ------------------------------------------------------------------------------------------+
        ----For CBC following procedure creates pa_bc_packet from ICG_CC_INTERFACE for Fundscheck.
        ----If the calling mode is  Reserve, unreserve , Force pass and check then  copy
        ----all the ICG_CC_INTERFACE to pa_bc_packets
        ------------------------------------------------------------------------------------------+

        --IF l_mode IN ( 'R','C','F' ) AND p_calling_module = 'CBC' THEN
        IF p_calling_module = 'CBC' THEN

        --  ------------------------------------------------------------------------------------------+
        --  :( AS CBC IS NOT SUPPORTED, IF CBC CALLS PA, RETURN 'T' BACK TO CALLING PGM ..
        --  ------------------------------------------------------------------------------------------+

		If g_debug_mode = 'Y' then
	   		log_message(p_stage => 10,p_msg_token1 => 'For CBC calling copy_gl_pkt_to_pa_pkt in mode ='||l_mode);
		end if;

		-- PA_FUNDS_CONTROL_PKG1.copy_gl_pkt_to_pa_pkt
                -- 		(p_packet_id  		=> l_packet_id
                -- 		,p_calling_module  	=> p_calling_module
	        --			,p_return_code          => l_return_status
                -- 		,p_reference1  		=> p_reference1
                -- 		,p_reference2 		=> p_reference2);

                --IF    l_return_status  <> 'S' then
	  		If g_debug_mode = 'Y' then
                        	log_message (p_msg_token1 => 'Error while create records in pa_bc_packets');
			end if;
			g_return_status := 'T';
                        x_return_status := g_return_status;
                	l_fc_final_exit_flag := 'NORMAL_ERROR';
                	GOTO END_PROCESS;
                --END IF;
		--If g_debug_mode = 'Y' then
                -- 	log_message(p_msg_token1 => 'Populating records in pa_bc_packets is successful');
		--end if;
        END IF;
	*/
	-------->6599207 ------END

       -- -----------------------------------------------------------------------------------+
       -- This procedure will synch packet_id, serial_id, session_id, actual_flag,status_code
       -- from gl_bc_packets to pa_bc_packets ..
       -- Synch up only required for Commitment Funds check ..
       -- -----------------------------------------------------------------------------------+

       If p_calling_module not in
          ('DISTBTC','DISTERADJ','CBC','EXPENDITURE','DISTCWKST','DISTVIADJ','TRXIMPORT','RESERVE_BASELINE','CDL') then

          SYNCH_PA_GL_PACKETS(x_packet_id    => p_packet_id,
                              x_partial_flag => p_partial_flag,
                              x_mode         => p_mode,
                              x_result_code  => x_return_status);

          If nvl(x_return_status,'S') = 'F' then -- Bug 5557520

              If g_debug_mode = 'Y' then
                 log_message(p_msg_token1 => 'Synch_pa_gl_packets failed .. extracts failed .. full mode');
              End If;

              l_fc_final_exit_flag := 'NORMAL_ERROR';
              g_return_status := 'F';
              GOTO END_PROCESS;

          End If;

       End If;

       -------->6599207 ------As part of CC Enhancements
       If p_calling_module <> 'CBC' Then

       -- -----------------------------------------------------------------------------------+
       -- Check if PA FC called for project related txn. or budget or its called for non-FC
       -- NO_FC: non-project related FC, exit with 'S' status
       -- BUD_FC: BC FC called projects (SLA-BC Integration for budget baseline) - exit with
       --         'S' status
       -- TXN_FC: PA FC called for txn. or budget baseline 'RESERVE_BASELINE' mode - existing
       -- -----------------------------------------------------------------------------------+
          CHECK_TXN_OR_BUDGET_FC (p_packet_id,l_calling_code);

          If g_debug_mode = 'Y' then
              log_message(p_msg_token1=>'FC called mode:'||l_calling_code);
          End If;


          If l_calling_code in ('NO_FC','BUD_FC') THEN  -- II

             x_return_status := 'S';
             g_return_status := 'S';

             If g_debug_mode = 'Y' then
                If l_calling_code = 'NO_FC' then
                   log_message(p_msg_token1=>'PA FC called for non-project transactions');
                Else
                   log_message(p_msg_token1=>'PA FC called by BC FC API during budget funds check by GL');
                End If;

             End If;

      	     PA_DEBUG.Reset_err_stack;
	     Return TRUE;

          End If; -- II

       -- -----------------------------------------------------------------------------------+
       End If;
       -------->6599207 ------END


	l_fc_final_exit_flag := 'NORMAL_EXIT';
	-- Assign the In params to Global varialbes
	g_mode               := p_mode;
        g_calling_module     := p_calling_module;
        g_partial_flag       := p_partial_flag;
	g_packet_id	     := p_packet_id;
	l_mode		     := p_mode;

	If l_mode = 'A' then  -- Adjustments same as Reserve funds
		l_mode := 'R';
	End if;
	g_mode               := l_mode;

	If g_debug_mode = 'Y' then
		log_message(p_msg_token1 => 'initialize l_fc_final_exit_flag = '||l_fc_final_exit_flag);
	End if;

	-- Initialize the Out variable with success
	x_return_status := 'S';
	g_return_status := 'S';


	--Initialize the  funds control util package global variables
	PA_FUNDS_CONTROL_UTILS.init_util_variables;

	--Inialize the the local global variables
	 Initialize_globals;

	-- generete packet id if the calling module is contract commitments
	-- and store it in the global variable, use the glboal variable in
	-- tie back api for status confirmation for CBC.
	If p_calling_module = 'CBC' and l_mode not in('U') then
		OPEN cur_packets;
		FETCH cur_packets INTO l_packet_id;
		CLOSE cur_packets;
		g_cbc_packet_id  := l_packet_id;
		g_packet_id  := l_packet_id;
	Else
		If g_debug_mode = 'Y' then
			log_message(p_msg_token1 => ' assiging the packet id to global variable p_packet_id = '
			  ||p_packet_id);
		End if;
		l_packet_id := p_packet_id;
		g_packet_id := l_packet_id;
	End If;

        -- get the set of books id from the pa bc packets for the given packet id
        If p_calling_module in ('TRXIMPORT', 'TRXNIMPORT') then
                OPEN cur_sob(l_packet_id);
                FETCH cur_sob INTO l_set_of_books_id;
                CLOSE cur_sob;

        Else
                l_set_of_books_id := p_set_of_book_id;
        END IF;
	If g_debug_mode = 'Y' then
		log_message(p_msg_token1 => ' the value of l_packet_id ='||l_packet_id||' - g packet_id ='||g_packet_id);
	End if;

	-- if the calling mode is unreserved then copy all the rows into
	-- unreserved packet update the status and return, in tie back process
	-- update the budget_acct_balances
	If l_mode in ('U') and p_calling_module in ('GL','CBC') then
		If g_debug_mode = 'Y' then
			log_message(p_msg_token1 => ' calling create_unrsvd_lines api');
		end if;
		If NOT PA_FUNDS_CONTROL_PKG1.create_unrsvd_lines
        		( x_packet_id       => l_packet_id
        		 ,p_mode            => l_mode
        		 ,p_calling_module  => p_calling_module
        		 ,p_reference1      => p_reference1
        		 ,p_reference2      => p_reference2
        		) then
			If g_debug_mode = 'Y' then
				log_message(p_msg_token1 => 'Failed to create unreserved packet lines');
			end if;
			g_return_status := 'F';
			--log_message(p_return_status => 'F');
			x_return_status := g_return_status;
			l_fc_final_exit_flag := 'NORMAL_ERROR';
			If g_debug_mode = 'Y' then
				log_message(p_msg_token1 => 'Return status :'||x_return_status);
			end if;
			pa_debug.reset_err_stack;
			return FALSE;

		End if;
		g_packet_id := l_packet_id;

		--generate return code for the packet and return
		If g_debug_mode = 'Y' then
	        	log_message(p_msg_token1 => 'Calling gen_return_code API');
		end if;
        	gen_return_code(p_packet_id     => l_packet_id
                        ,p_partial_flag => p_partial_flag
                        ,p_calling_mode => p_calling_module
                        ,x_return_status => l_packet_status);

		-- if the pa_funds check fails then in tie back process
		-- just return with out proceeding further else check
		-- the return status of gl and cbc update the status code
		-- of packets
		If p_calling_module = 'GL'  then
			g_pa_gl_return_status  := l_packet_status;
		Elsif p_calling_module = 'CBC' then
			g_pa_cbc_return_status   := l_packet_status;
		End if;
		g_return_status := l_packet_status;
		If g_debug_mode = 'Y' then
                	log_message(p_msg_token1 => 'The return code of the FC process :'||l_packet_status);
		end if;
		--log_message(p_return_status => l_packet_status);

		x_return_status := l_packet_status;
		If g_debug_mode = 'Y' then
			log_message(p_msg_token1 => 'Return status :'||x_return_status);
		end if;
		pa_debug.reset_err_stack;
		return true;

	End IF;  -- end of Unreserve mode

        -------->6599207 ------As part of CC Enhancements
	IF l_mode IN ( 'R','C','F' ) THEN
		If g_debug_mode = 'Y' then
	   		log_message(p_stage => 10,p_msg_token1 => 'inside the if condition mode ='||l_mode);
		end if;


		IF p_calling_module ='CBC' then
			If g_debug_mode = 'Y' then
				log_message(p_msg_token1 => 'calling populate plsql tabs api');
			end if;

			PA_FUNDS_CONTROL_PKG1.populate_plsql_tabs_CBC
                		(p_packet_id  		=> l_packet_id
                		,p_calling_module  	=> p_calling_module
                		,p_reference1  		=> p_reference1
                		,p_reference2 		=> p_reference2
				,p_mode                 => l_mode);

		End if;
		If g_debug_mode = 'Y' then
			log_message(p_msg_token1 => 'End of create_bc_pkt_lines api');
		end if;
        END IF;
	-------->6599207 ------END


	------------------------------------------------------------------------
	-- check whether the budget baseline is going on if so return and
	-- update the result code in pa bc packets with error code
	------------------------------------------------------------------------
	If g_debug_mode = 'Y' then
		log_message( p_stage => 30, p_msg_token1 => 'Check whether the project is under Baseline process');
	end if;
	IF NOT is_project_baseline
		(p_calling_module => p_calling_module,
		p_packet_id  => l_packet_id ) then
		If g_debug_mode = 'Y' then
			log_message( p_msg_token1 => 'BASELINE / YEAR END ROLLOVER  is Under progress');
		end if;
		--log_message(p_return_status => 'F');
		g_return_status := 'F';
                x_return_status := g_return_status;
		l_fc_final_exit_flag := 'NORMAL_ERROR';
		GOTO END_PROCESS;
	END IF;
        -------------------------------------------------------------------------------------------------------
        ---  Check if the mode is in B,S,R,U,C,F then  Insert Arrival Sequence for the Packet.
        --  The Row  Share Lock ensures that packets are assigned sequences strictly in order of arrival
        ------------------------------------------------------------------------------------------------------
        IF l_mode IN ( 'B', 'S','R','C','F' ) THEN
		If g_debug_mode = 'Y' then
                	log_message(p_stage => 40,p_msg_token1 => 'Calling get_arrival_seq API');
		end if;


                l_arrival_seq := get_arrival_seq
                (p_calling_module => p_calling_module
		,p_packet_id      => l_packet_id
                ,p_sobid          => l_set_of_books_id
                ,p_mode           => l_mode
                );

                IF l_arrival_seq = 0 then
                        log_message(p_error_msg => 'F141');
		        If g_debug_mode = 'Y' then
				log_message(p_msg_token1 => 'Failed to acquire lock');
			end if;
                	l_fc_final_exit_flag := 'NORMAL_ERROR';
                	GOTO END_PROCESS;
		End IF;
		If g_debug_mode = 'Y' then
                	log_message(p_msg_token1 => 'End of get_arrival_seq API');
		end if;

        END IF;

       If p_calling_module in ('DISTBTC','DISTERADJ','CBC','EXPENDITURE','DISTCWKST','DISTVIADJ','TRXIMPORT') then

          -- Note: For commitment Funds check, populate_burden_cost is called in pa_funds_control_pkg1
          --       R12: BC-SLA Integration ..

        -----------------------------------------------------------------------------------------------------
        -- Populate the Burden cost for each record in packet if project type is of burden on same EI
        -- otherwise create separate bc packet lines if the project type is of burden as separate EI
        --Lock the arrival order sequence table
        ------------------------------------------------------------------------------------------------------
        --IF l_mode IN ( 'R', 'C','F' ) and p_calling_module not in ( 'RESERVE_BASELINE') THEN
		If g_debug_mode = 'Y' then
		    log_message(p_stage => 50,p_msg_token1 => p_calling_module||':Calling Populate_burden_cost API');
		end if;

                PA_FUNDS_CONTROL_PKG1.Populate_burden_cost
                (p_packet_id            => l_packet_id
		,p_calling_module	=> p_calling_module
                ,x_return_status        => l_return_status
                ,x_err_msg_code         => l_err_msg_code);

                IF    l_return_status  <> 'S' then
			If g_debug_mode = 'Y' then
                        	log_message (p_msg_token1 => 'Error while populating Burden Cost for');
			end if;
			--log_message(p_return_status => 'T');
			g_return_status := 'T';
                        x_return_status := g_return_status;
                	l_fc_final_exit_flag := 'NORMAL_ERROR';
                	GOTO END_PROCESS;
                END IF;
		If g_debug_mode = 'Y' then
                	log_message(p_msg_token1 => 'Populating burden cost is successful');
		end if;
        --END IF;

       End if; -- If p_calling_module in ('DISTBTC','DISTERADJ','CBC','EXPENDITURE','DISTCWKST','DISTVIADJ'

        -------------------------------------------------------------------------------------------
        -- This Api setup the required funds check parameters such as resource list member id,
        -- funds control level code, budget resource list id, budget task id etc.
        -------------------------------------------------------------------------------------------
	If g_debug_mode = 'Y' then
		log_message(p_stage => 60,p_msg_token1 => 'Calling funds_check_setup API');
	end if;
	If l_mode not in ('U')  then
             IF NOT funds_check_setup
                (p_packet_id            => l_packet_id
                  ,p_mode               => l_mode
		  ,p_sob                => l_set_of_books_id
		  ,p_reference1  	=> p_reference1
          	  ,p_reference2  	=> p_reference2
		  ,p_calling_module     => p_calling_module

                   )  THEN
		If g_debug_mode = 'Y' then
                	log_message(p_msg_token1 =>'funds check failed at setup and summerization');
		end if;
		--log_message(p_return_status => 'T');
		g_return_status := 'T';
                x_return_status := g_return_status;
                l_fc_final_exit_flag := 'NORMAL_ERROR';
                GOTO END_PROCESS;
             END IF;
	End if;
	If g_debug_mode = 'Y' then
		log_message(p_msg_token1 => 'End of funds_check_setup API');
	end if;

 -----------------------------------------------------------------------------------------------------------
 -- Main Funds Check Processor  Calling  pa_fck_process . In this process it derives start date and end date
 -- based on amount type and boundary code and checks funds available against the budget from the bottom up
 -- ie, checks at the Resource level  resource group level  task level  top task level  project level .
 -- If all the level funds check passes then it sets the status as S for each bc_packet_record
 --------------------------------------------------------------------------------------------------------
	If g_debug_mode = 'Y' then
		log_message(p_stage => 70,p_msg_token1 => 'Calling pa_fck_process API');
	end if;
	IF l_mode NOT in ('F','U') then
	    IF NOT  pa_fcp_process
        	(p_sob                  => l_set_of_books_id
        	,p_packet_id            => l_packet_id
        	,p_mode                 => l_mode
        	,p_partial_flag         => p_partial_flag
        	,p_arrival_seq          => l_arrival_seq
        	,p_reference1           => p_reference1
        	,p_reference2           => p_reference2
        	--,p_reference3           => p_reference3
		,p_calling_module	=> p_calling_module

         	) then
		If g_debug_mode = 'Y' then
                	log_message(p_msg_token1 => 'funds check failed during pa_fck_process api');
		end if;
		--log_message(p_return_status => 'T');
		g_return_status := 'T';
                x_return_status := g_return_status;
                l_fc_final_exit_flag := 'NORMAL_ERROR';
                GOTO END_PROCESS;
            END IF;
	END IF;
	If g_debug_mode = 'Y' then
		log_message(p_msg_token1 => 'end of pa_fck_process  complete');
	end if;

	-----------------------------------------------------------------------
	-- synchronize the raw and burden lines if there is a  failure
	------------------------------------------------------------------------
	If g_debug_mode = 'Y' then
		log_message(p_stage => 80,p_msg_token1 => 'Calling sync_raw_burden API');
	end if;
	If l_mode not in ('U') then
		sync_raw_burden
                (p_packet_id             => l_packet_id
                 ,p_mode                 => l_mode
                 ,p_calling_module       => p_calling_module
                 ,x_return_status        => l_return_status
		);
		IF l_return_status <> 'S' then
			log_message(p_msg_token1 => 'Failed to synchronize the raw and burden lines');
		End if;
		log_message(p_msg_token1 => 'End of sync_raw_burden API');
	End if;
	-------------------------------------------------------------------------
	-- Update ei and cdls with gl date, encum type id, budget ccid etc if the
	-- funds check pass else update ei with cost dist reject code
        --------------------------------------------------------------------------
	If g_debug_mode = 'Y' then
		log_message(p_stage => 90 ,p_msg_token1 => 'Calling update_EIS API');
	end if;
	If l_mode not in ('U') and p_calling_module in ('DISTBTC','DISTERADJ','EXPENDITURE','DISTVIADJ','DISTCWKST'
							,'INTERFACER','INTERFACVI') then
		update_EIS (p_packet_id   	=> l_packet_id
                    ,p_calling_module   => p_calling_module
                    ,p_mode             => l_mode
		    ,x_return_status    => l_return_status);
        	IF l_return_status <> 'S' then
			If g_debug_mode = 'Y' then
                		log_message(p_msg_token1 => 'Failed to update EI and CDLs with status');
			end if;
			--log_message(p_return_status => l_return_status);
			g_return_status := l_return_status;
        	End if;
		If g_debug_mode = 'Y' then
			log_message(p_msg_token1 => 'End of update_EIS API');
		end if;
	End if;

	---------------------------------------------------------------------------
        -- Determine the return code sent to GL /CBC
	-- the out NOCOPY parameter l_return_status is the status of the
	-- packet which is funds checked
        ----------------------------------------------------------------------------
	If g_debug_mode = 'Y' then
		log_message(p_stage => 100, p_msg_token1 => 'Calling gen_return_code API');
	end if;
	gen_return_code(p_packet_id   	=> l_packet_id
                        ,p_partial_flag => p_partial_flag
                        ,p_calling_mode => p_calling_module
                        ,x_return_status => l_packet_status);

                -- if the pa_funds check fails then in tie back process
                -- just return with out proceeding further else check
                -- the return status of gl and cbc update the status code
                -- of packets
                If p_calling_module = 'GL'  then
                        g_pa_gl_return_status  := l_packet_status;
                Elsif p_calling_module = 'CBC' then
                        g_pa_cbc_return_status   := l_packet_status;
                End if;
		If g_debug_mode = 'Y' then
			log_message(p_msg_token1 => 'The return code of the FC process :'||l_packet_status);
		end if;

	 -- --------------------------------------------------------------------------+
         -- Update gl_bc_packets status such that GL FC will not execute funds
         -- avaialble validation ... This is for no/separate line burdening
	 -- --------------------------------------------------------------------------+
	 --IF  p_calling_module in ('GL','CBC') and l_mode IN ('R','C','F')  then

         --   MARK_GL_BC_PACKETS_FOR_NO_FC(p_packet_id => l_packet_id);

	 --End if;

        -------->6599207 ------As part of CC Enhancements
	IF  p_calling_module in ('CBC') and l_mode IN ('R','C','F')  then
		-- funds check resutl is success
		If g_debug_mode = 'Y' then
			log_message(p_stage => 110, p_msg_token1 => 'Calling Post_Bdn_Lines_To_GL_CBC API');
		end if;
		Post_Bdn_Lines_To_GL_CBC (
        	p_Packet_ID             => l_packet_id
        	,p_calling_module       => p_calling_module
        	,p_packet_status        => l_packet_status
		,p_reference1		=> p_reference1
		,p_reference2		=> p_reference2
        	,x_return_status        => l_return_status
        	);
        	IF l_return_status <> 'S' then
			If g_debug_mode = 'Y' then
                		log_message(p_msg_token1 => 'Failed to post burden lines to GL / CBC');
			end if;
			--log_message(p_return_status => l_return_status);
			g_return_status := l_return_status;
        	End if;
		If g_debug_mode = 'Y' then
			log_message(p_msg_token1 =>'End of Post_Bdn_Lines_To_GL_CBC API');
		end if;

		----------------------------------------------------------------------------------
		-- if the project funds check is success full then call encumbrance liquidation
		-- entries in gl bc packets and igc cc interface tables
		----------------------------------------------------------------------------------
		If g_debug_mode = 'Y' then
			log_message(p_stage => 120, p_msg_token1 => 'Calling create_liqd_entry API');
		end if;
                create_liqd_entry(
                p_Packet_ID             => l_packet_id
                ,p_calling_module       => p_calling_module
		,P_mode			=> l_mode
                ,p_reference1           => p_reference1
                ,p_reference2           => p_reference2
                ,p_packet_status        => l_packet_status
                ,x_return_status        => l_return_status
                );
                IF l_return_status <> 'S' then
			If g_debug_mode = 'Y' then
                        	log_message(p_msg_token1 => 'Failed to create liquidation entries in  GL / CBC');
			end if;
			--log_message(p_return_status => l_return_status);
			g_return_status := l_return_status;
                End if;
		If g_debug_mode = 'Y' then
			log_message(p_msg_token1 => 'End of create_liqd_entry API');
		end if;

	End if;
	-------->6599207 ------END


	-----------------------------------------------------------------------------------
        -- if the packet status is failed then update the status code of the pa bc packets
        -- for gl, cbc, trxn imports as failed otherwise the status code is updated in
        -- the tie back process
        -----------------------------------------------------------------------------------
        If ( (p_calling_module IN ( 'DISTBTC','GL','CBC','DISTERADJ','TRXIMPORT','DISTVIADJ','DISTCWKST')
		and l_mode not in ('U') and l_packet_status <> 'S' )
             OR ( p_calling_module IN  ('RESERVE_BASELINE'))
	     -- OR   l_mode = 'C' , 'C' should behave like 'R' mode ..
	   )  then
		If g_debug_mode = 'Y' then
			log_message(p_stage => 130, p_msg_token1 => 'calling update status code for failed packet');
		end if;
                status_code_update (
                p_calling_module        => p_calling_module
                ,p_packet_id             => l_packet_id
                ,p_mode                  => l_mode
                ,p_partial               =>p_partial_flag
		,p_packet_status         => l_packet_status
                ,x_return_status         => l_return_status
                        );
		If g_debug_mode = 'Y' then
		 	log_message(p_msg_token1 => 'end of status code for failed packet');
		end if;
                IF l_return_status <> 'S' then
			If g_debug_mode = 'Y' then
                        	log_message(p_msg_token1 => 'Failed to update status codes');
			end if;
			--log_message(p_return_status => l_return_status);
			g_return_status := l_return_status;
                End if;
        End if;

	If p_calling_module IN ( 'GL','CBC') AND l_mode not in ('U') and
           (l_packet_status <> 'S' OR p_partial_flag = 'Y')  then
		If g_debug_mode = 'Y' then
			log_message(p_stage => 140, p_msg_token1 =>'Calling update_GL_CBC_result_code API');
		end if;

 		update_GL_CBC_result_code(
        		p_packet_id        => l_packet_id
        		,p_calling_module  => p_calling_module
        		,p_mode            => l_mode
        	        ,p_partial_flag    => p_partial_flag
        		,p_reference1      => p_reference1
        		,p_reference2      => p_reference2
        		,p_packet_status   => l_packet_status
        		,x_return_status   => l_return_status
			);
                IF l_return_status <> 'S' then
			If g_debug_mode = 'Y' then
                        	log_message(p_msg_token1 => 'Failed to update result_code in GL /CBC ');
			end if;
			--log_message(p_return_status => l_return_status);
			g_return_status := l_return_status;
                End if;
		If g_debug_mode = 'Y' then
			log_message(p_msg_token1 =>'End of update_GL_CBC_result_code APIl_packet_status['||l_packet_status);
		end if;
	End IF;
	x_return_status := l_packet_status;
	If x_return_status = 'S' then
		/** added if condition if the funds check is called from GL /CBC
                 *  and partial_flag = 'Y' then GL /CBC funds check expects return
		 *  as 'P' instead of 'S' so set the return code for GL /CBC for
                 *  partial mode as P
                 */
		If p_partial_flag = 'Y' and p_calling_module in ('GL','CBC') then
			If g_debug_mode = 'Y' then
		        	log_message(p_stage => 150, p_msg_token1 => 'Calling get_gl_cbc_return_status api');
			end if;
			x_return_status := get_gl_cbc_return_status
					   (p_packet_id => l_packet_id);

		End if;
		x_error_stage := 0;
		x_error_msg  := null;
	Else                                                   -- was causing plsql value error
		x_error_stage := substr(g_error_stage,1,100);  -- CBC funds check defined length as 100
		x_error_msg   := substr(g_error_msg,1,100);    -- so substr func added to reduce the length
	End if;

        <<END_PROCESS>>
	If g_debug_mode = 'Y' then
		log_message(p_msg_token1 => 'End of Funds check Process l_fc_final_exit_flag['||
				   l_fc_final_exit_flag);
	end if;

	IF l_fc_final_exit_flag = 'NORMAL_ERROR' then
			x_return_status := 'F';
                     -- update the gl / cbc result code with failure status
                     If p_calling_module in ('GL','CBC') then
                        update_GL_CBC_result_code(
                        p_packet_id       => l_packet_id
                        ,p_calling_module  => p_calling_module
                        ,p_mode            => l_mode
                        ,p_partial_flag    => p_partial_flag
                        ,p_reference1      => p_reference1
                        ,p_reference2      => p_reference2
                        ,p_packet_status   => 'F' -- failure
                        ,x_return_status   => l_return_status);

                     Elsif p_calling_module in ('DISTBTC','DISTERADJ','DISTVIADJ','INTERFACER','INTERFACVI','DISTCWKST') THEN
                        update_EIS (p_packet_id         => l_packet_id
                        ,p_calling_module   => p_calling_module
                        ,p_mode             => l_mode
                        ,x_return_status    => l_return_status);
                     End if;
                     If p_calling_module = 'GL'  then
                        g_pa_gl_return_status  := 'F';
                     Elsif p_calling_module = 'CBC' then
                        g_pa_cbc_return_status   := 'F';
                     End if;

	END IF;
	-- Reset the error stack
        PA_DEBUG.reset_err_stack;
	If g_debug_mode = 'Y' then
		log_message(p_msg_token1 => 'Return status :'||x_return_status);
	end if;
        RETURN ( TRUE );
EXCEPTION
        WHEN OTHERS THEN
            	x_error_stage := g_error_stage;
		x_error_msg   := SQLCODE||SQLERRM;
		x_return_status := 'T';
        	--log_message(p_return_status => x_return_status );
		g_return_status := 'T' ;
              result_status_code_update
                ( p_packet_id  		   => l_packet_id,
                p_status_code              => 'T',
                p_result_code              => 'F142',
                p_res_result_code          => 'F142',
                p_res_grp_result_code      => 'F142',
                p_task_result_code         => 'F142',
                p_top_task_result_code     => 'F142',
		p_proj_acct_result_code    => 'F142');

                IF p_calling_module in ('DISTBTC','DISTVIADJ','DISTERADJ','EXPENDITURE','INTERFACER','INTERFACVI','DISTCWKST') then
                         update_EIS(p_packet_id => l_packet_id
                            ,p_calling_module 	=> p_calling_module
                            ,p_mode      	=> l_mode
                            ,x_return_status  	=> l_return_status);
				If g_debug_mode = 'Y' then
                             	  log_message(p_msg_token1 =>
                                   'Updateing EIS with rejection_code');
				end if;
                ELSIF p_calling_module in ('GL','CBC') then
                         update_GL_CBC_result_code(
                             p_packet_id       =>l_packet_id
                            ,p_calling_module  =>p_calling_module
                            ,p_partial_flag    => p_partial_flag
                            ,p_reference1      => p_reference1
                            ,p_reference2      => p_reference2
                            ,p_mode            =>l_mode
                            ,p_packet_status   => 'T'
                            ,x_return_status   => l_return_status);
                END IF;
                If p_calling_module = 'GL'  then
                      g_pa_gl_return_status  := 'T';
                Elsif p_calling_module = 'CBC' then
                      g_pa_cbc_return_status   := 'T';
                End if;

		If cur_sob%ISOPEN then
			close cur_sob;
		End if;

		If cur_packets%ISOPEN then
			close cur_packets;
		End if;
		If g_debug_mode = 'Y' then
                	log_message(p_msg_token1 => 'failed in pa_funds_check apiSQLERR :'||sqlcode||sqlerrm);
		end if;
		-- Reset the error stack
        	PA_DEBUG.reset_err_stack;
		RETURN ( false );

END pa_funds_check;

-----------------------------------------------------------
-- This API returns the GL return code based on the full or
-- partial modes in the case of RESERVE,CHECK FUNDS
----------------------------------------------------------
FUNCTION get_gl_return_code(p_packet_id      in number,
			    p_partial_flag   in  varchar2 default 'N')
	return varchar2 IS

	-- check for fatal error for the transactions in full mode
	cursor gl_status_fatal_error  is
	SELECT 1
	FROM gl_bc_packets a
	WHERE a.packet_id = p_packet_id
	AND   EXISTS (
			SELECT 'Y'
			FROM  gl_bc_packets b
			WHERE b.status_code = 'T'
			AND   b.packet_id = a.packet_id
		);

	-- check for normal error for the transaction in full mode
        cursor gl_status_normal_error  is
        SELECT 1
        FROM gl_bc_packets a
        WHERE a.packet_id = p_packet_id
        AND   EXISTS (
                        SELECT 'Y'
                        FROM  gl_bc_packets b
                        WHERE b.packet_id = a.packet_id
			AND   ((b.status_code in ('R','F','T')
                                AND   substr(b.result_code,1,1) = ('F')
			        ) OR
			       ( b.status_code = 'T' )
			      )
                );

	-- Check for at least on passed transaction in gl in partial mode
	-- if not found then all transactions are rejected
	cursor gl_status_partial is
	SELECT 1
	FROM gl_bc_packets a
	WHERE a.packet_id = p_packet_id
	AND EXISTS
		(SELECT 'Y'
		 FROM gl_bc_packets b
		 WHERE b.status_code in ('S','A','P')
		 AND   substr(b.result_code,1,1) IN ('P','A')
		 AND   b.packet_id = a.packet_id
		);



	l_return_code  varchar2(10) := 'S';
        l_status_code   number := 0;
BEGIN

	l_return_code := 'S';
	l_status_code := 0;
	IF p_partial_flag  <> 'Y' then -- full mode
		If g_debug_mode = 'Y' Then
			log_message(p_msg_token1 => 'opening cur to check fatal error');
		End if;
		OPEN gl_status_fatal_error;
		FETCH gl_status_fatal_error INTO l_status_code;
		IF gl_status_fatal_error%NOTFOUND THEN
			OPEN gl_status_normal_error;
			If g_debug_mode = 'Y' Then
				log_message(p_msg_token1 => 'opening cur to check normal error');
			End if;
			FETCH gl_status_normal_error INTO l_status_code;
			IF gl_status_normal_error%NOTFOUND THEN
				If g_debug_mode = 'Y' Then
					log_message(p_msg_token1 => 'cur not found');
				End if;
				l_return_code := 'S';
			END IF;
			CLOSE gl_status_normal_error;
		END IF;
		CLOSE gl_status_fatal_error;

		IF gl_status_fatal_error%isopen then
			close gl_status_fatal_error;
		End if;
		IF gl_status_normal_error%isopen then
			close gl_status_normal_error;
		End if;

		IF nvl(l_status_code,0) > 0 then
			l_return_code := 'F';
		Else
			l_return_code := 'S';
		End if;
		If g_debug_mode = 'Y' Then
			log_message(p_msg_token1 => 'gl return code ='||l_return_code);
		End if;
		return l_return_code;

	ELSE -- partial mode

		OPEN gl_status_partial;
		If g_debug_mode = 'Y' Then
			log_message(p_msg_token1 => 'opening cur to check gl return code ');
		End if;
		FETCH gl_status_partial INTO l_status_code;
		IF gl_status_partial%NOTFOUND then
			If g_debug_mode = 'Y' Then
				log_message(p_msg_token1 => 'cur not found');
			End if;
			l_return_code := 'F';
		Else
			l_return_code := 'S';
		End if;
		CLOSE gl_status_partial;

		IF gl_status_partial%isopen then
			close gl_status_partial;
		End if;
		If g_debug_mode = 'Y' Then
			log_message(p_msg_token1 => 'gl return code ='||l_return_code);
		End if;
		return l_return_code;
	END IF;

EXCEPTION
	when others then
		If g_debug_mode = 'Y' Then
			log_message(p_msg_token1 => 'Failed in get_gl_return_code api');
		End if;
		raise;
END get_gl_return_code;

/** If the calling module is partial then
 *  status and return code should be updated in
 *  pa_bc_packets using autonmous transaction other wise
 *  it causes a deadlock while calling sync_raw_burden from tie back api
 **/
PROCEDURE tie_back_status(p_calling_module     in varchar2,
			  p_packet_id          in number,
			  p_partial_flag       in varchar2,
			  p_mode               in varchar2,
			  p_glcbc_return_code  in varchar2) IS

	PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

 If g_debug_mode = 'Y' Then
  log_message(p_msg_token1 => 'In tie_back_status,p_calling_module,p_packet_id,p_partial_flag:'
                              ||p_calling_module||','||p_packet_id||','||p_partial_flag);
  log_message(p_msg_token1 => 'In tie_back_status,p_mode,p_glcbc_return_code:'
                              ||p_mode||','||p_glcbc_return_code);
 End if;

         If p_calling_module in('GL','CBC') and p_mode in ('C','R','A','F') then
                 FORALL i IN g_tab_src_dist_id_num_1.FIRST .. g_tab_src_dist_id_num_1.LAST
                        UPDATE pa_bc_packets
                        SET result_code =
				 decode(p_calling_module,
				  'GL',
				     decode(p_partial_flag,
                                           'Y',decode(p_mode,'C','F150','F156'),
					   'N',decode(p_mode,'C',decode(p_glcbc_return_code,'F','F150',
                                                                                       'R','F151',
                                                                                       'T','F151')
                                                       ,'R',decode(p_glcbc_return_code,'F','F155',
                                                                                       'R','F155',
                                                                                       'T','F155')
                                                       ,'A',decode(p_glcbc_return_code,'F','F155',
                                                                                       'R','F155',
                                                                                       'T','F155')
                                                       ,'F',decode(p_glcbc_return_code,'F','F155',
                                                                                       'R','F155',
                                                                                       'T','F155'))),
			        'CBC',
				      decode(p_partial_flag,
                                           'Y',decode(p_mode,'C','F152','F158'),
                                           'N',decode(p_mode,'C',decode(p_glcbc_return_code,'F','F152',
                                                                                        'R','F153',
                                                                                        'T','F153')
                                                        ,'R',decode(p_glcbc_return_code,'F','F157',
                                                                                        'R','F157',
                                                                                        'T','F157')
                                                        ,'A',decode(p_glcbc_return_code,'F','F157',
                                                                                        'R','F157',
                                                                                        'T','F157')
                                                        ,'F',decode(p_glcbc_return_code,'F','F157',
                                                                                        'R','F157',
                                                                                        'T','F157'))))
                        WHERE packet_id                        = p_packet_id
                        AND   substr(nvl(result_code,'P'),1,1) = 'P'
                        AND   document_distribution_id         = g_tab_src_dist_id_num_1(i)
                        AND   (source_event_id                 = g_tab_gl_bc_event_id(i)
                               OR
                               bc_event_id                     = g_tab_gl_bc_event_id(i))
                        AND   document_type                    = g_tab_src_dist_type(i);

          If g_debug_mode = 'Y' Then
             log_message(p_msg_token1 => 'In tie_back_status, pa_bc_pkt records updated:'||SQL%ROWCOUNT);
          End if;

	Elsif (p_calling_module in('DISTBTC','DISTVIADJ','DISTCWKST')and p_glcbc_return_code = 'T')  Then
		/* mark the transaction result code as rejected if the return code of the distribute
                 * vendor invoice adjustment process raises unexpected error
                 */
		UPDATE pa_bc_packets
                SET result_code = decode(substr(nvl(result_code,'P'),1,1),'P','F151',result_code)
		WHERE packet_id = p_packet_id;

	End if;
	commit; -- to end an active autonomous transaction

        If g_debug_mode = 'Y' Then
            log_message(p_msg_token1 => 'In tie_back_status: End');
      End if;

	return;

EXCEPTION
	WHEN OTHERS THEN
		If g_debug_mode = 'Y' Then
			pa_funds_control_pkg.log_message(p_msg_token1 => 'Failed in tie_back_status apiSQLERR:'||
					sqlcode||sqlerrm);
		End if;
		RAISE;

END tie_back_status;

/********************************************************************************************************
* This is the Tie back api which updates the status  of pa_bc_packets table   after
* confirming the funds checking status of  GL / Contract Commitments
*Parameters:
*        P_packet_id             :  Packet Identifier of the funds check process
*        P_mode                  :Funds Checker Operation Mode
*                                        R  -   Reserve  Default
*                                        B  -    Base line
*					  C  -    Check
*        P_calling_module         :This holds  the info of  budget type
*                                        GL  --- Standard   Default
*                                        CBC  --- Contract Commitments
*        P_reference1            :This Param is not null in case of  Contract Commitment
*                                If  P_ext_bdgt_type   = CBC
*                                        This param holds the information of document type
*                                        P_reference2 = Igc_cc_interface.document_type
*                                elsif  p_mode  = B then
*                                        P_reference1 =  project_id
*                                Else
*                                        P_reference1  = NULL;
*                                End if;
*        P_reference2            :This Param is not null in case of  Contract Commitment
*                                If  P_ext_bdgt_type   = CBC
*                                        This param holds the information of document Header Id
*                                        P_reference2 = Igc_cc_interface.CC_HEADER_ID
*                                elsif  p_mode  = B then
*                                        P_reference2 =  budget_version_id
*                                Else
*                                        P_reference2  = NULL;
*                                End if;
*        p_partial_flag          :Partial reservation flag
*                                        Y  -   partial mode
*                                        N   -   full Mode  default
*        P_gl_cbc_return_code    :The return status of the GL /CBC funds check process
*************************************************************************************************************/

PROCEDURE   PA_GL_CBC_CONFIRMATION
        (p_calling_module       IN      VARCHAR2
        ,p_packet_id            IN      NUMBER
        ,p_mode                 IN      VARCHAR2        DEFAULT 'C'
        ,p_partial_flag         IN      VARCHAR2        DEFAULT 'N'
        ,p_reference1           IN      VARCHAR2        DEFAULT  NULL  ----- doc type  'CC'
        ,p_reference2           IN      VARCHAR2        DEFAULT  NULL  ---- CC_HEADER_ID
        ,p_gl_cbc_return_code   IN OUT NOCOPY  VARCHAR2
	,x_return_status        OUT NOCOPY     VARCHAR2
        ) IS

	l_packet_id	NUMBER;

        CURSOR gl_cur(v_packet_id  NUMBER) is
        SELECT DISTINCT gl.source_distribution_id_num_1 distribution_id,
               gl.event_id,
               decode(gl.source_distribution_type,
                     'AP_INV_DIST','AP',
                     'AP_PREPAY','AP',
                     'PA_AP_BURDEN','AP',
                     'PO_DISTRIBUTIONS_ALL','PO',
                     'PA_PO_BURDEN','PO',
                     'PA_REQ_BURDEN','REQ',
                     'PO_REQ_DISTRIBUTIONS_ALL','REQ') source_distribution_type
        FROM gl_bc_packets gl
        WHERE gl.packet_id = v_packet_id
        AND ( (nvl(substr(gl.result_code,1,1),'P') = 'F'
	      AND gl.status_code in ('F','R'))
	      OR (gl.status_code = 'T')
	    );

        -- Cursor to check the number of failed/passed records in gl and accordingly pass return status back to PSA.
	-- Note : No need to have partial flag logic here as procedure update_GL_CBC_result_code has already stamped
	--  gl bc packets status code based on partial flag.
	-- Output values :
        -- return 'F' if all have failed --fail
        -- return 'P' if some of the records have failed --partial
        -- return 'S' if all have success --success

        CURSOR gl_return_code IS
        SELECT decode(count(*)
                       ,count(decode(substr(nvl(gl.result_code,'P'),1,1),'P',1)),'S'
                       ,count(decode(substr(nvl(gl.result_code,'P'),1,1),'F',1,'X',1)),'F'
                       ,decode(p_partial_flag,'N','F','P')) -- Bug 5522810 : p_partial_flag is also checked before returning partial mode
         FROM  gl_bc_packets gl
        WHERE  gl.packet_id = p_packet_id;

        -------->6599207 ------As part of CC Enhancements
	CURSOR cbc_cur IS
        SELECT igc.rowid,igc.reference_9
        FROM igc_cc_interface igc
        WHERE igc.document_type = p_reference1
        AND   igc.cc_header_id  = p_reference2
	AND  ((nvl(substr(igc.cbc_result_code,1,1),'P') = 'F'
	       AND igc.status_code in ('F','R'))
		OR (igc.status_code = 'T')
	     );
       	-------->6599207 ------END


	l_num_rows  NUMBER := 100;
	l_return_status  VARCHAR2(1);
	l_gl_cbc_return_code  VARCHAR2(10);
	l_pa_return_code      VARCHAR2(10);
	l_mode                VARCHAR2(10);
	l_debug_mode          VARCHAR2(10);
	l_calling_module      VARCHAR2(30);
        l_calling_code        VARCHAR2(10);
        l_event_result_status VARCHAR2(15);

BEGIN
        --Initialize the error stack
        PA_DEBUG.init_err_stack('PA_FUNDS_CONTROL_PKG.PA_GL_CBC_CONFIRMATION');

        fnd_profile.get('PA_DEBUG_MODE',g_debug_mode );
        g_debug_mode := NVL(g_debug_mode, 'N');

        PA_DEBUG.SET_PROCESS( x_process         => 'PLSQL'
                             ,x_write_file      => 'LOG'
                             ,x_debug_mode      => g_debug_mode
                             );

        /** Bug fix :2302945 If PA is NOT installed in OU then we should return as success
         ** without proceeding further . This api checks whether the In given operating unit
         ** project is installed or not, if not installed return with success
         **/
        IF IS_PA_INSTALL_IN_OU = 'N' then
                x_return_status := 'S';
                g_return_status := 'S';

		If g_debug_mode = 'Y' then
			log_message(p_msg_token1=>'PA NOT INSTALLED IN THIS OU.return status='
				||x_return_status);
		end if;
                PA_DEBUG.Reset_err_stack;
		Return;
        END IF;
        /** End of Bug fix **/

	l_mode := p_mode;
	If l_mode = 'A' then  -- A  Adjustment called from PO and REQ only
		l_mode := 'R';
	End if;

	If g_debug_mode = 'Y' Then
		log_message(p_msg_token1 =>'INSIDE PA_GL_CBC_CONFIRMATION'||
        	'calling module ['||p_calling_module|| ']mode ['||l_mode||
        	']p_reference1['|| p_reference1||']p_reference2[ '||p_reference2||
        	']p_packet_id ['||p_packet_id||']p_partial_flag[ '||p_partial_flag||
        	']p_gl_cbc_return_code [ '||p_gl_cbc_return_code||']g_ap_matched_case['||g_ap_matched_case||']');
	End if;

        -------->6599207 ------As part of CC Enhancements
	/* COMMENTED THIS CODE
	--  ------------------------------------------------------------------------------------------+
        --  :( AS CBC IS NOT SUPPORTED, IF CBC CALLS PA, RETURN 'T' BACK TO CALLING PGM ..
        --  ------------------------------------------------------------------------------------------+
       --IF l_mode IN ( 'R','C','F' ) AND p_calling_module = 'CBC' THEN
       IF p_calling_module = 'CBC' THEN
	  If g_debug_mode = 'Y' then
   		log_message(p_msg_token1 => 'PA FC Called for CBC .. FAIL Process');
	  End if;

  	  p_gl_cbc_return_code := 'T';
          x_return_status := 'T';
 	  g_return_status := 'T';

 	  PA_DEBUG.Reset_err_stack;

	  RETURN;
        END IF;
        --  ------------------------------------------------------------------------------------------+
        --  CBC Check Ends here ....
        --  ------------------------------------------------------------------------------------------+
	*/
	-------->6599207 ------END

       -------->6599207 ------As part of CC Enhancements -- Added IF condition alone
       IF p_calling_module <> 'CBC'  THEN

       -- -----------------------------------------------------------------------------------+
       -- Check if PA FC called for project related txn. or budget or its called for non-FC
       -- NO_FC: non-projcet related FC, exit with 'S' status
       -- BUD_FC: BC FC called projects (SLA-BC Integration for budget baseline) - new
       -- TXN_FC: PA FC called for txn. mode - existing
       -- -----------------------------------------------------------------------------------+
          CHECK_TXN_OR_BUDGET_FC (p_packet_id,l_calling_code);

             If g_debug_mode = 'Y' then
                   log_message(p_msg_token1=>'FC called mode:'||l_calling_code);
             End If;


       -- -----------------------------------------------------------------------------------+
       -- If NOT PA FC, exit program ..
       -- -----------------------------------------------------------------------------------+
          If l_calling_code = 'NO_FC' then

             x_return_status := 'S';
             g_return_status := 'S';
	     -- Bug 5140510 : p_gl_cbc_return_code should not be overwritten.
             --  p_gl_cbc_return_code  := 'S';

             If g_debug_mode = 'Y' then
                   log_message(p_msg_token1=>'PA FC called for non-project transactions: EXIT FC program');
             End If;

      	     PA_DEBUG.Reset_err_stack;
	     RETURN;

          End If;


       -- -------------------------------------------------------------------------------------+
       -- SLA-BC Integration: GL FC for budget calls PA tieback, here we execute account level
       -- funds check for the baseline mode .. and also build account summary ...
       -- -------------------------------------------------------------------------------------+

          If l_calling_code = 'BUD_FC' then

             If g_debug_mode = 'Y' then
                   log_message(p_msg_token1=>'Before calling DO_BUDGET_BASELINE_TIEBACK');
             End If;

             DO_BUDGET_BASELINE_TIEBACK(p_packet_id,x_return_status);

             If g_debug_mode = 'Y' then
                   log_message(p_msg_token1=>'After calling DO_BUDGET_BASELINE_TIEBACK, return status:'||x_return_status);
             End If;

             If x_return_status <> 'S' then

                p_gl_cbc_return_code  := 'F';

             Else

               p_gl_cbc_return_code  := 'S';

             End If;

             RETURN;

          End if;
       -- -----------------------------------------------------------------------------------+

       END IF;
       -------->6599207 ------END


	-- Intitalize the out NOCOPY parameter
	x_return_status  := 'S';
	If g_debug_mode = 'Y' Then
		log_message(p_msg_token1 =>' g_pa_gl_return_status ['||g_pa_gl_return_status||
		']g_pa_cbc_return_status ['||g_pa_cbc_return_status||']');
	End if;

	-- Assign the status codes of GL / CBC to local varialbes
	-- if gl return code is null then derive return code
        IF p_gl_cbc_return_code is null and  p_calling_module = 'GL' then
		 l_gl_cbc_return_code := get_gl_return_code
				   (p_packet_id  	=> p_packet_id
                            	   ,p_partial_flag    	=> p_partial_flag);
	Elsif p_gl_cbc_return_code  in ('P','S','A') then

		l_gl_cbc_return_code := 'S';
	Else
		l_gl_cbc_return_code := nvl(p_gl_cbc_return_code,'S') ;
	End if;
	If g_debug_mode = 'Y' Then
		log_message(p_msg_token1 =>'l_gl_cbc_return_code = '||l_gl_cbc_return_code);
	End if;

	If p_calling_module = 'CBC' and p_packet_id is NULL then
		l_packet_id := g_cbc_packet_id;
	Elsif p_calling_module = 'GL' and l_mode not in ('U') then
		l_packet_id  := p_packet_id;
	Elsif l_mode in ('U') then
		l_packet_id := g_packet_id;
	End if;
	If g_debug_mode = 'Y' Then
		log_message(p_msg_token1 => 'packet_id ['||l_packet_id||']g_packet_id = '||g_packet_id||
			']g_cbc_packet_id ['||g_cbc_packet_id||']');

        	log_message(p_stage => 10 ,p_msg_token1 => 'Start Of PA_GL_CBC_CONFIRMATION  ');
	End if;

        IF p_calling_module = 'GL' and l_mode in ('C','R','F')  and g_pa_gl_return_status = 'S' then

                 OPEN gl_cur(l_packet_id);
                 LOOP
			g_tab_src_dist_id_num_1.delete;
                        g_tab_gl_bc_event_id.delete;
                        g_tab_src_dist_type.delete;

                        FETCH gl_cur BULK COLLECT INTO
                        g_tab_src_dist_id_num_1,g_tab_gl_bc_event_id,g_tab_src_dist_type LIMIT l_num_rows;

                        If g_debug_mode = 'Y' Then
                           log_message(p_msg_token1 => ' GL Failed distinct (event/distr/dist type) record count:'
                                                         ||g_tab_src_dist_id_num_1.COUNT);
                       	End if;

                        IF NOT g_tab_src_dist_id_num_1.EXISTS(1) then
                                 EXIT;
                        END IF;

			tie_back_status
		        (p_calling_module     => p_calling_module
       		        ,p_packet_id         => l_packet_id
       			,p_partial_flag      => p_partial_flag
			,p_mode              => l_mode
                         ,p_glcbc_return_code => l_gl_cbc_return_code);

                        EXIT WHEN gl_cur%notfound;

               END LOOP;
               CLOSE gl_cur;

        -------->6599207 ------As part of CC Enhancements
        ---- Uncommented this ELSIF condition
	ELSIF p_calling_module = 'CBC' and l_mode in ('C','R','F')  and g_pa_cbc_return_status = 'S' then

                OPEN cbc_cur;
                LOOP
                        g_tab_rowid.delete;
			g_tab_tieback_id.delete;
                        FETCH cbc_cur BULK COLLECT INTO
                        g_tab_rowid,g_tab_tieback_id LIMIT l_num_rows;
                        IF NOT g_tab_rowid.EXISTS(1)  then
                                  EXIT;
                        END IF;

               		tie_back_status
			(p_calling_module     => p_calling_module
                        ,p_packet_id         => l_packet_id
                        ,p_partial_flag      => p_partial_flag
                        ,p_mode              => l_mode
                        ,p_glcbc_return_code => l_gl_cbc_return_code);

                        EXIT WHEN cbc_cur%notfound;

                END LOOP;
                CLOSE cbc_cur;

        END IF;
	-------->6599207 ------END

	-- After update of packet status based on GL return code if there are
	-- any transactions failed in GL for raw line if not integrated
	-- then we have to tie up raw and burden lines in partial mode
        If p_calling_module in ('GL','CBC') and
	   ( g_pa_gl_return_status = 'S' OR g_pa_cbc_return_status = 'S' )then
		If g_debug_mode = 'Y' Then
			log_message(p_msg_token1 => 'calling sync_raw_burden api in tie back');
		End if;
		sync_raw_burden
                (p_packet_id            =>l_packet_id,
                 p_mode                 =>l_mode,
                 p_calling_module       =>p_calling_module,
                 x_return_status        =>l_return_status);
		If g_debug_mode = 'Y' Then
               		log_message(p_msg_token1 => 'calling status_code_update api in tie back');
		End if;

		If g_debug_mode = 'Y' Then
			log_message(p_msg_token1 => 'Calling procedure full_mode_failure ..');
		End if;

                FULL_MODE_FAILURE(p_packet_id => l_packet_id, p_case => 'AP_FULL_MODE_FAILURE');

		If g_debug_mode = 'Y' Then
			log_message(p_msg_token1 => 'After Calling procedure full_mode_failure ..');
		End if;


               status_code_update (
                p_calling_module         => p_calling_module
                ,p_packet_id             => l_packet_id
                ,p_mode                  => l_mode
                ,p_partial               => p_partial_flag
		,p_packet_status         => l_gl_cbc_return_code
                ,x_return_status         => l_return_status
                        );
		If g_debug_mode = 'Y' Then
                	log_message(p_msg_token1 => 'return status = '||l_return_status);
		End if;
                IF l_return_status <> 'S' then
                        log_message(p_msg_token1 => 'Failed to update status codes');
                End if;
	End if;


	-- if the return status from gl/ cbc is success then update the budget
	-- account balances
	IF l_gl_cbc_return_code = 'S' and  p_calling_module in ('GL','CBC')
	   and (g_pa_gl_return_status = 'S' OR g_pa_cbc_return_status = 'S' )
	   and l_mode in ('R','U','F')  then
		If g_debug_mode = 'Y' Then
			log_message(p_msg_token1 => 'calling upd_bdgt_encum_bal api from tieback');
		End if;
                upd_bdgt_encum_bal(
                p_packet_id              => l_packet_id
                ,p_calling_module        => p_calling_module
                ,p_mode                  => l_mode
                ,p_packet_status         => l_gl_cbc_return_code
                ,x_return_status         => l_return_status
                        );
		If g_debug_mode = 'Y' Then
			log_message(p_msg_token1 => 'after upd_bdgt_encum_bal api return status ='||l_return_status);
		End if;
                IF l_return_status <> 'S' then
			If g_debug_mode = 'Y' Then
                        	log_message(p_msg_token1 => 'Calling upd_cwk_attributes API');
			End if;
                End if;

		/* PAM changes */
		If p_calling_module = 'GL' Then
			-- update the cwk attributes for the passed transactions
			pa_funds_control_pkg1.upd_cwk_attributes
			(p_calling_module  => p_calling_module
                        ,p_packet_id       => l_packet_id
                        ,p_mode            => l_mode
                        ,p_reference       => 'UPD_AMTS'
                        ,x_return_status   => l_return_status
                        );

			-- update the cwk compiled_multiplier
                	pa_funds_control_pkg1.upd_cwk_attributes(
                        p_calling_module  => p_calling_module
                        ,p_packet_id      => l_packet_id
                        ,p_mode           => l_mode
                        ,p_reference      => 'UPD_MULTIPLIER'
                        ,x_return_status  => l_return_status
                        );

			If g_debug_mode = 'Y' Then
                                log_message(p_msg_token1 => 'End of upd_cwk_attributes API return status ['||l_return_status||']');
                        End if;

		End If;

	END IF;

	IF p_calling_module in ('GL','CBC') then

		If p_calling_module = 'GL' then
		    l_calling_module := 'GL_TIEBACK';
		Elsif p_calling_module = 'CBC' then
		    l_calling_module := 'CBC_TIEBACK';
		Else
		    l_calling_module := p_calling_module;
		End if;
		update_GL_CBC_result_code(
        	p_packet_id       => l_packet_id,
        	p_calling_module  => l_calling_module,
                p_partial_flag    => p_partial_flag,
                p_reference1      => p_reference1,
                p_reference2      => p_reference2,
        	p_mode            => l_mode,
        	p_packet_status   => l_gl_cbc_return_code,
        	x_return_status   => l_return_status
			);

		/** commit is used here since in check mode GL does not commit  or it may be calling in auto
	         *  nomous mode when called from PO, REQ. so
                 *  even though pa funds check updates the result code and status codes in gl
		 *  it is being setting to null after funds check call
		 */
		--If p_calling_module = 'GL' and p_partial_flag = 'Y' and l_mode = 'C' then
	        --	commit;
		--End if;
                -- This COMMIT has been removed as tieback is in the main sesion and by issuing
                -- commit, global tables can get wiped out .. R12 change

                -- Logic to check the number of failed/passed records in gl and accordingly pass return status back to PSA.
                -- return 'F' if all have failed --fail
                -- return 'P' if some of the records have failed --partial
                -- return 'S' if all have success --success

                OPEN  gl_return_code ;
                FETCH gl_return_code  INTO p_gl_cbc_return_code;
                CLOSE gl_return_code;

    	        If g_debug_mode = 'Y' Then
                   log_message(p_msg_token1 => 'Final return value for PSA  p_gl_cbc_return_code '||p_gl_cbc_return_code);
                End if;

	End if;


        -- Reset the error stack
        PA_DEBUG.reset_err_stack;

        RETURN;
EXCEPTION
        WHEN OTHERS THEN
		IF gl_cur%ISOPEN then
			close gl_cur;
		END IF;
                --IF cbc_cur%ISOPEN then
                --        close cbc_cur;
                --END IF;

             result_status_code_update(p_status_code => 'T',
                                       p_packet_id   => l_packet_id);

		p_gl_cbc_return_code := 'T';
		x_return_status := 'T';

		If g_debug_mode = 'Y' Then
                	log_message(p_msg_token1 => 'Un handled Exception  Error  in PA_GL_CBC_CONFIRMATION');
		End if;
		log_message(p_error_msg => sqlcode||sqlerrm);
		-- Reset the error stack
                PA_DEBUG.reset_err_stack;

END PA_GL_CBC_CONFIRMATION;

/* The following API is added to tie back the status code of the
 * bc packets during the distribute vendor invoice adjustments
 * This API will be called from PABCCSTB.pls package
 */
/*
 * Moved the API from main fc process to tieback process to update the bdgt acct balance and status code
 * Added for bug : 2961161 to update the status of packet if
 * called in DISTVIADJ mode and packet status is success
 */
PROCEDURE tieback_pkt_status
                          (p_calling_module     in varchar2
                          ,p_packet_id          in number
                          ,p_partial_flag       in varchar2 default 'N'
                          ,p_mode               in varchar2 default 'R'
                          ,p_tieback_status     in varchar2 default 'T' --'S' for Success, 'T' -- fatal Error
                          ,p_request_id         in number
                          ,x_return_status      OUT NOCOPY varchar2) IS

	cursor curViPkts IS
	SELECT distinct packet_id
	FROM   pa_bc_packets
	WHERE  request_id = p_request_id;

	l_tieback_status   varchar2(100);
	l_packet_id     Number;
	l_mode          Varchar2(100);
	l_partial_flag  Varchar2(100);

BEGIN
	-- Initialize the Variables
	x_return_status := 'S';
	l_tieback_status := NVl(p_tieback_status,'T');
	l_packet_id := p_packet_id;
	l_mode := p_mode;
	l_partial_flag := NVl(p_partial_flag,'N');

        --Initialize the error stack
        PA_DEBUG.init_err_stack('PA_FUNDS_CONTROL_PKG.tieback_pkt_status');

        fnd_profile.get('PA_DEBUG_MODE',g_debug_mode );
        g_debug_mode := NVL(g_debug_mode, 'N');

        PA_DEBUG.SET_PROCESS( x_process         => 'PLSQL'
                             ,x_write_file      => 'LOG'
                             ,x_debug_mode      => g_debug_mode
                             );

	IF g_debug_mode = 'Y' Then
		log_message(p_msg_token1=>'Inside tieback_pkt_status l_packet_id['||l_packet_id||']l_mode['||
			l_mode||']l_partial_flag['||l_partial_flag||']p_calling_module['||
			p_calling_module||']p_tieback_status['||p_tieback_status||']p_request_id['||
			p_request_id||']' );

	End If;

        IF IS_PA_INSTALL_IN_OU = 'N' then
                x_return_status := 'S';
                g_return_status := 'S';

                If g_debug_mode = 'Y' then
                        log_message(p_msg_token1=>'PA NOT INSTALLED IN THIS OU.return status='||x_return_status);
                end if;
                PA_DEBUG.Reset_err_stack;
                Return;
        END IF;

	IF p_calling_module in ('DISTBTC','DISTVIADJ','DISTCWKST' ) Then
		log_message(p_msg_token1 =>'Looping through each packet for the requestId to update the status');

		FOR i IN curViPkts LOOP

			l_packet_id := i.packet_id;

			If l_tieback_status = 'T' Then
				If g_debug_mode = 'Y' Then
					log_message(p_msg_token1 =>'Calling ResultCode Tieback['||l_packet_id||']');
				End If;
                        	tie_back_status
                        	(p_calling_module    => p_calling_module
                        	,p_packet_id         => l_packet_id
                        	,p_partial_flag      => l_partial_flag
                        	,p_mode              => l_mode
                        	,p_glcbc_return_code => l_tieback_status
				);
			ELSE

                		If g_debug_mode = 'Y' Then
                       	    		log_message(p_msg_token1 => 'calling status_code_update in tie back['||l_packet_id||']');
                		End if;

               			status_code_update (
                		p_calling_module         => p_calling_module
                		,p_packet_id             => l_packet_id
                		,p_mode                  => l_mode
                		,p_partial               => l_partial_flag
                		,p_packet_status         => l_tieback_status
                		,x_return_status         => x_return_status
                        	);
                		If g_debug_mode = 'Y' Then
                       	    		log_message(p_msg_token1 => 'After StatuscodeUpdate return status['||x_return_status);
                		End if;

				IF ( x_return_status = 'S' AND l_tieback_status = 'S' AND l_mode in ('R','U','F') ) Then

                	     		upd_bdgt_encum_bal(
                			p_packet_id              => l_packet_id
                			,p_calling_module        => p_calling_module
                			,p_mode                  => l_mode
                			,p_packet_status         => l_tieback_status
                			,x_return_status         => x_return_status
                        		);

                			/* PAM changes */
                			If p_calling_module in ('DISTCWKST') Then
				    		log_message(p_msg_token1 => 'Calling upd_cwk_attributes API');
                        			-- update the cwk attributes for the passed transactions
                        			pa_funds_control_pkg1.upd_cwk_attributes
                        			(p_calling_module  => p_calling_module
                        			,p_packet_id       => l_packet_id
                        			,p_mode            => l_mode
                        			,p_reference       => 'UPD_AMTS'
                        			,x_return_status   => x_return_status
                        			);
                			End If;

				End If;
		   	End If; -- l_pkt_status <> 'T'

		END LOOP;

	END IF;

	IF g_debug_mode = 'Y' Then
                log_message(p_msg_token1=>'End of tieback_pkt_status API');
        End If;

        -- Reset the error stack
        PA_DEBUG.reset_err_stack;

        RETURN;
EXCEPTION
        WHEN OTHERS THEN
		x_return_status := 'U';
		PA_DEBUG.reset_err_stack;
		Raise;

END tieback_pkt_status;

-------------------------------------------------------------------------------------
-- This is an overloaded procedure inturn make calls to main funds check function
-- this api is called from GL_funds checker from PO / REQ approval process
-------------------------------------------------------------------------------------
PROCEDURE  pa_funds_check
       (p_calling_module                IN      VARCHAR2
       ,p_set_of_book_id                IN      NUMBER
       ,p_packet_id                     IN      NUMBER
       ,p_mode                          IN      VARCHAR2 DEFAULT 'C'
       ,p_partial_flag                  IN      VARCHAR2 DEFAULT 'N'
       ,p_reference1                    IN      VARCHAR2  DEFAULT NULL
       ,p_reference2                    IN      VARCHAR2  DEFAULT NULL
       ,x_return_status                 OUT NOCOPY     VARCHAR2
       ,x_error_msg                     OUT NOCOPY     VARCHAR2
       ,x_error_stage                   OUT NOCOPY     VARCHAR2
         ) IS

	l_return_status    varchar2(100);
	l_error_msg	   varchar2(100);
	l_error_stage      varchar2(100);

BEGIN



  IF NOT pa_funds_check
       (p_calling_module               => p_calling_module
       ,p_conc_flag                    => 'N'
       ,p_set_of_book_id               =>p_set_of_book_id
       ,p_packet_id                    => p_packet_id
       ,p_mode                         =>p_mode
       ,p_partial_flag                 =>p_partial_flag
       ,p_reference1                   =>p_reference1
       ,p_reference2                   => p_reference2
       ,p_reference3                   => null
       ,x_return_status                => x_return_status
       ,x_error_msg                    => x_error_msg
       ,x_error_stage                  => x_error_stage
         ) then
	If g_debug_mode = 'Y' Then
		log_message(p_msg_token1 => 'Error during funds check process');
	End if;

  End if;
END;

-- ------------------------------------ R12 Start ------------------------------------------------+
-- R12 Changes: New procedure/functions that were added

-- --------------------------------------------------------------------------------+
-- This procedure has been created to handle FULL MODE failure during check funds
-- action of an invoice that is matched to PO .. bug 5253309
-- p_case added to handle future scenarios..
-- This is reqd. especially for scenarios where AP has multiple distributions and
-- some are matched to PO, in such cases the doc. is in 'PARTIAL MODE' but matched
-- dist. is treated in FULL MODE.
-- This procedure will also handle the scenario where var. record failed but original
-- record passed and vice versa ..basically related events failure ..
-- --------------------------------------------------------------------------------+
PROCEDURE Full_mode_failure(p_packet_id IN NUMBER,
                            p_case      IN VARCHAR2)
is
     TYPE t_reference1 is table of pa_bc_packets.reference1%type;
     TYPE t_reference3 is table of pa_bc_packets.reference3%type;
     tt_reference1 t_reference1;
     tt_reference3 t_reference3;
Begin
      If nvl(p_case,'NO_AP') = 'AP_FULL_MODE_FAILURE' then

            -- --------------------------------------------------------------------------------------+
            -- Scenario:
            -- Document_type  doc_dist_id  reference1 reference3 doc_dist_type
            -- AP             101            PO         2          ITEM
            -- AP             102            PO         2          IPV
            -- PO             2              AP         101        STANDARD
            --
            -- First update takes care of the scenario where 101 failed then fail 102
            -- 2nd update will take care of the scenario where either 101 or 102 failed, fail PO or
            -- PO failed, fail AP.
            -- K.Biju June6th,2006
            -- --------------------------------------------------------------------------------------+


       	If g_debug_mode = 'Y' Then
           log_message(p_msg_token1 => 'Full_mode_failure: Check AP matched failure case exists');
       	End if;

	/* Bug 5589452 : Update to fail all AP/PO records in packet which are associated with related invoice distributions */
        Update pa_bc_packets pbc
           set pbc.result_code = 'F170'
         where pbc.packet_id   = p_packet_id
     	   and substr(pbc.result_code,1,1)  = 'P'
           and pbc.document_type in ('PO','AP')
	   and ( decode (pbc.document_type , 'PO' , to_number(pbc.reference2) , 'AP' , pbc.document_header_id),
                 decode (pbc.document_type , 'PO' , to_number(pbc.reference3) , 'AP' , pbc.document_distribution_id)) IN
                /** Select to fetch all related invoice distributions associated with a failed record in packet.
                    This sql fetches all invoice distributions linked to each other with charge_applicable_to_dist_id and related id**/
                (  select distinct b.invoice_id,b.invoice_distribution_id
                     from ap_invoice_distributions_all  a
                          ,ap_invoice_distributions_all  b
                    where (a.invoice_id,a.invoice_distribution_id) in
                           /**select to fetch Invoice id and Inv distribution id associated with failed AP/PO records in a packet**/
                          (select DECODE(pbc1.document_type,'PO',to_number(pbc1.reference2),pbc1.document_header_id),
                                  DECODE(pbc1.document_type,'PO',to_number(pbc1.reference3),pbc1.document_distribution_id)
                             from pa_bc_packets pbc1
                            where pbc1.packet_id = p_packet_id
                              and substr(pbc1.result_code,1,1) = 'F'
                              and pbc1.document_type in ('AP','PO')
                              and pbc1.parent_bc_packet_id is null)
                      and  b.invoice_id = a.invoice_id
                      and  COALESCE(b.charge_applicable_to_dist_id,b.related_id,b.invoice_distribution_id) =
                           COALESCE(a.charge_applicable_to_dist_id,a.related_id,a.invoice_distribution_id));


        select pbc.reference1,pbc.reference3
        BULK COLLECT into tt_reference1,tt_reference3
        from   pa_bc_packets pbc
        where  pbc.packet_id = p_packet_id
        and    pbc.parent_bc_packet_id is null -- this is ok. as this proc. is fired after raw/burden synch
        and    ((pbc.document_type = 'PO' and
                 pbc.reference1 = 'AP' and
                 substr(pbc.result_code,1,1) = 'F')
                 OR
                (pbc.document_type = 'AP' and
                 pbc.reference1 = 'PO' and
                 substr(pbc.result_code,1,1) = 'F')
                );

        If tt_reference1.exists(1) then

       	   If g_debug_mode = 'Y' Then
              log_message(p_msg_token1 => 'Full_mode_failure: Yes!! AP matched failure case exists');
              log_message(p_msg_token1 => 'Full_mode_failure: Fail related AP distributions,viceversa');
           End if;

            -- Fail other related AP distributions
            -- e.g.: If variance failed then failed original distribution and vice versa
            forall x in tt_reference1.FIRST..tt_reference1.LAST
            Update pa_bc_packets pbc
            set    pbc.result_code = 'F170'
            where  pbc.packet_id   = p_packet_id
            and    pbc.reference3  = tt_reference3(x) -- All rel matched AP dist. has same PO as ref3
            and    pbc.document_type = 'AP'
            and    substr(pbc.result_code,1,1)  = 'P'
            and    tt_reference1(x) = 'PO'; -- AP record has PO as reference1

            If g_debug_mode = 'Y' Then
               log_message(p_msg_token1 => 'Full_mode_failure: Rel. dist. fail, records updated:'||SQL%ROWCOUNT);
               log_message(p_msg_token1 => 'Full_mode_failure: Fail PO if AP failed,viceversa');
            End if;

            -- Fail other records with F170 (full mode failure)
            -- basically fail those records with result_code P%%%
            forall x in tt_reference1.FIRST..tt_reference1.LAST
            Update pa_bc_packets pbc
            set    pbc.result_code = 'F170'
            where  pbc.packet_id   = p_packet_id
            and    pbc.document_distribution_id = tt_reference3(x)
            and    pbc.document_type            = tt_reference1(x)
            and    substr(pbc.result_code,1,1)  = 'P';

            If g_debug_mode = 'Y' Then
               log_message(p_msg_token1 => 'Full_mode_failure: PO-AP full mode, records updated:'||SQL%ROWCOUNT);
            End if;

            tt_reference1.delete;
            tt_reference3.delete;

        End if;

      End If; --If nvl(p_case,'NO_FAILURE') = 'AP_FULL_MODE_FAILURE' then

End Full_mode_failure;

-- --------------------------------------------------------------------------------+
-- This procedure is called from Synch_pa_gl_packets to AUTONOMOUSLY update
-- pa_bc_packets with failure....in case of extract failing ..
-- -------------------------------------------------------------------------------+
PROCEDURE Missing_records_failure(p_pa_packet_id IN NUMBER,
                                  p_gl_packet_id IN NUMBER,
                                  p_partial_flag IN VARCHAR2,
                                  p_mode         IN VARCHAR2) IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
 l_program_name := 'Missing_records_failure:';
 If g_debug_mode = 'Y' then
    log_message(p_msg_token1=>l_program_name||':Start:p_partial_flag:'|| p_partial_flag );
 End If;

     forall i in g_event_id.FIRST..g_event_id.LAST
     Update pa_bc_packets pbc
     set    pbc.result_code     = 'F173',
            pbc.status_code     = decode(p_mode,'C','F','R'),
            pbc.packet_id       =  p_gl_packet_id
     where  pbc.packet_id       =  p_pa_packet_id
     and    pbc.bc_event_id     =  g_event_id(i)
     and    pbc.document_distribution_id = g_doc_dist_id(i)
     and    pbc.document_type   = g_document_type(i);

     -- Bug 5557520 : if F173 is encountered, we should be failing the complete packet
     -- without cheking for p_partial_flag as it will result into data corruption.
     --If p_partial_flag = 'N' then
          -- Full mode failure ...
          Update pa_bc_packets pbc
          set    pbc.result_code     = 'F170',
                 pbc.status_code     = decode(p_mode,'C','F','R'),
                 pbc.packet_id       =  p_gl_packet_id
          where  pbc.packet_id       =  p_pa_packet_id
          and    substr(nvl(pbc.result_code,'P'),1,1) = 'P';

      --End If;

 COMMIT;

 If g_debug_mode = 'Y' then
    log_message(p_msg_token1=>l_program_name||':End');
 End If;

End Missing_records_failure;

-- --------------------------------------------------------------------------------+
-- This procedure is called from Synch_pa_gl_packets to update: serial_id,
-- session_id, actual_flag,packet_id and status ..
-- --------------------------------------------------------------------------------+
PROCEDURE Synch_data(p_pa_packet_id IN NUMBER,
                     p_gl_packet_id IN NUMBER) IS

  CURSOR cur_get_gl_data IS
  SELECT session_id,
         serial_id
    FROM gl_bc_packets
   WHERE packet_id = p_gl_packet_id
     AND ROWNUM =1 ;

-- Note: bc_event_id is null being used as for integrated case, the balancing
-- entries by PA (PA_PO_BURDEN) are present and that will synch the records
-- so, the issue is only for non-integrated budgets ..
Cursor cur_ap_matched_case is
SELECT 'Y'
 FROM  dual
WHERE  EXISTS(
       select 1
       from pa_bc_packets pbc1
       where  pbc1.packet_id = p_pa_packet_id
       and    pbc1.bc_event_id is null
       and    pbc1.document_type = 'PO'
       and exists (select 1
                  from   pa_bc_packets pbc2
                  where  pbc2.packet_id = p_gl_packet_id
                  and    pbc2.bc_event_id is null
                  and    pbc2.document_type = 'AP'));

   l_session_id     pa_bc_packets.session_id%TYPE;
   l_serial_id      pa_bc_packets.serial_id%TYPE;

PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  l_program_name := 'Synch_data:';
  If g_debug_mode = 'Y' then
    log_message(p_msg_token1=>l_program_name||'Start');
  End If;

  OPEN cur_get_gl_data;
  FETCH cur_get_gl_data INTO l_session_id,l_serial_id;
  CLOSE cur_get_gl_data;

 -- ------------------------------------------------------+
 -- Need to change this code .. all we need is one update
 -- and set g_ap_matched_case flag...
 -- ------------------------------------------------------+

  Update pa_bc_packets pb
     set pb.packet_id             = p_gl_packet_id,
         pb.status_code           = decode(pb.status_code,'I','P',pb.status_code),
         pb.session_id            = DECODE(pb.session_id,NULL,l_session_id,pb.session_id),
         pb.serial_id             = DECODE(pb.serial_id,NULL,l_serial_id,pb.serial_id)
  where  pb.packet_id             = p_pa_packet_id ;

  -- ------------------------------------------------------------------------------ +
  -- In case of non-integrated records, we do not have the budget relieving entries
  -- meaning that there are no PO records, so the above update fails to update info.
  -- on the PO records, thats why we have the following code ...
  -- Why did we go with this "work around" code
  -- For Auto-create case, REQ record.document_distribution_id_num_1 pointed to REQ
  -- but for matched case, po's dist. num is pointing to AP.
  -- For more info. check bug 5206285 ..
  -- ------------------------------------------------------------------------------ +
  g_ap_matched_case := 'N';

  Open cur_ap_matched_case;
  fetch cur_ap_matched_case into   g_ap_matched_case;
  close cur_ap_matched_case;

  COMMIT;

  If g_debug_mode = 'Y' then
    log_message(p_msg_token1=>l_program_name||'End');
  End If;

END Synch_data;



-- --------------------------------------------------------------------------------+
-- This procedure will update the following columns in pa_bc_packets: serial_id,
-- session_id,actual_flag,packet_id and status. Status will be upated from I to P.
-- Called from pa_funds_check
-- This procedure will also check if the extracts were successful, meaning that:
-- A. pa_bc_packet records have been extracted into gl_bc_packets
-- B. core records have been extracted into gl_bc_packets
-- C. project relieveing entries are created in gl_bc_packets
-- --------------------------------------------------------------------------------+
PROCEDURE Synch_pa_gl_packets(x_packet_id    IN Number,
                              x_partial_flag IN VARCHAR2,
                              x_mode         IN VARCHAR2,
                              x_result_code  OUT NOCOPY  Varchar2)
IS
 l_pa_packet_id pa_bc_packets.packet_id%type;

 Cursor c_old_packet is
 Select pb.packet_id
 from   pa_bc_packets pb
 where  pb.bc_event_id in
        (select glbc.event_id
         from   gl_bc_packets glbc
         where  glbc.packet_id = x_packet_id)
 union all
 Select pb.packet_id
 from   pa_bc_packets pb
 where  pb.source_event_id in
        (select glbc.event_id
         from   gl_bc_packets glbc
         where  glbc.packet_id = x_packet_id);

 -- 1st select reqd. in the case where core distribution not in gl_bc_packets
 -- 2nd select reqd. in the case where PA   distribution not in gl_bc_packets

BEGIN

 l_program_name := 'Synch_pa_gl_packets:';
 If g_debug_mode = 'Y' then
    log_message(p_msg_token1=>l_program_name||'Start:x_packet_id,x_partial_flag:'||
                              x_packet_id||','||x_partial_flag );
 End If;

 -- Get the packet_id that was established earlier ..
 Open c_old_packet;
 fetch c_old_packet into l_pa_packet_id;
 Close c_old_packet;

 If g_debug_mode = 'Y' then
    log_message(p_msg_token1=>l_program_name||' Previously establised packet is:'||l_pa_packet_id);
 End If;

 If l_pa_packet_id is not null then

    -- ---------------------------------------------------------------------------------------------- +
    -- A. Check if there is any extract failure ... for PA records
    If g_debug_mode = 'Y' then
       log_message(p_msg_token1=>l_program_name||' Previously establised packet is:'||l_pa_packet_id);
    End If;
    -- ---------------------------------------------------------------------------------------------- +

	-------->6599207 ------As part of CC Enhancements
	-- modified doctype checking. Added CC_C_PAY also.

       Select pbc.bc_event_id,pbc.document_distribution_id,pbc.document_type
       BULK COLLECT into g_event_id,g_doc_dist_id,g_document_type
       from   pa_bc_packets pbc
       where  packet_id = l_pa_packet_id
       and    pbc.bc_event_id is not null -- to filter out non-integrated budgets ...
       group by pbc.bc_event_id,pbc.document_distribution_id,pbc.document_type
       having count(pbc.bc_event_id) > (select count(glbc.event_id)
                                         from  gl_bc_packets glbc--,
                                               --xla_distribution_links xlad
                                         where glbc.packet_id = x_packet_id
                                         and   glbc.event_id  = pbc.bc_event_id
                                         and   glbc.source_distribution_id_num_1 = pbc.document_distribution_id
                                         and   decode(glbc.source_distribution_type,
                                                     'PA_AP_BURDEN','AP',
                                                     'PA_PO_BURDEN','PO',
                                                     'PA_REQ_BURDEN','REQ','CC','CC_')||
						     decode(glbc.source_distribution_type,'CC',substr(pbc.document_type,4),'')
						     = pbc.document_type);
                                         --and   xlad.event_id     = glbc.event_id
                                         --and   xlad.ae_header_id = glbc.ae_header_id
                                         --and   xlad.ae_line_num  = glbc.ae_line_num
                                         --and   xlad.applied_to_entity_code <> 'BUDGETS');
                                        -- cannot use xla_distribution_links as FC is AUTONOMOUS
	-------->6599207 ------END

    If g_debug_mode = 'Y' then
       log_message(p_msg_token1=>l_program_name||':'||g_event_id.COUNT||' PA event(s) did not have corr. gl_bc_packet records');
    End If;

    If g_event_id.COUNT > 0 then -- COUNT

       If g_debug_mode = 'Y' then
          log_message(p_msg_token1=>l_program_name||' Calling missing_records_failure');
       End If;

       MISSING_RECORDS_FAILURE(p_pa_packet_id => l_pa_packet_id,
                               p_gl_packet_id => x_packet_id,
                               p_partial_flag => x_partial_flag,
                               p_mode         => x_mode);

       g_event_id.DELETE;
       g_doc_dist_id.DELETE;
       g_document_type.DELETE;


       -- Bug 5557520 : If F173 failure then return fatal error irrespective of partial flag
       -- If all records have failed, set result code to 'F' so that
       -- FC will not proceed further .. (meaning after synch, it exists) ..
         Begin

           select null   -- null is ok ..
           into   x_result_code
           from   dual
           where  exists
                   (Select 1
                    from   pa_bc_packets
                    where  packet_id   = l_pa_packet_id
                    and    status_code = 'I');
         Exception
            when no_data_found then
                 x_result_code := 'F';
         End;


    End If; -- COUNT

   -- ---------------------------------------------------------------------------------------------------------+
   If g_debug_mode = 'Y' then
      log_message(p_msg_token1=>l_program_name||':result code:'||x_result_code);
      log_message(p_msg_token1=>l_program_name||':If resultcode <> F then check if core records are missing');
   End If;
   -- ---------------------------------------------------------------------------------------------------------+

/* ===============================================================================================================+
   THIS IS NO LONGER REQUIRED .. SA PSA ENSURES THAT ALL RECORDS ARE COPIED OVER .....

   If nvl(x_result_code,'P') <> 'F' then

            Select pbc.bc_event_id,pbc.document_distribution_id,pbc.document_type
            BULK COLLECT into g_event_id,g_doc_dist_id,g_document_type
            from   pa_bc_packets pbc
            where  pbc.packet_id   = l_pa_packet_id
            and    pbc.status_code = 'I'
            and    pbc.source_event_id is not null
            and not exists (select 1
                            from   gl_bc_packets glbc
                            where  glbc.packet_id    = x_packet_id
                            and    glbc.event_id     = pbc.source_event_id
                            and    glbc.source_distribution_id_num_1 = pbc.document_distribution_id);

          If g_debug_mode = 'Y' then
             log_message(p_msg_token1=>l_program_name||':'||g_event_id.COUNT||
                                       ' BC events did not have corr. gl_bc_packet records');
          End If;

          If g_event_id.COUNT > 0 then -- COUNT

             If g_debug_mode = 'Y' then
                log_message(p_msg_token1=>l_program_name||' Calling missing_records_failure');
             End If;

             MISSING_RECORDS_FAILURE(p_pa_packet_id => l_pa_packet_id,
                                     p_gl_packet_id => x_packet_id,
                                     p_partial_flag => x_partial_flag,
                                     p_mode         => x_mode);

              g_event_id.DELETE;
              g_doc_dist_id.DELETE;
              g_document_type.DELETE;


              If x_partial_flag = 'N' then  -- PARTIAL FLAG CHECK

                 -- Full mode failure ...
                 x_result_code := 'F';

               Elsif x_partial_flag = 'Y' then

                -- Partial mode failure ..
                -- If all records have failed, set result code to 'F' so that
                -- FC will not proceed further .. (meaning after synch, it exists) ..
                 Begin

                   select null   -- null is ok ..
                   into   x_result_code
                   from   dual
                   where  exists
                    (Select 1
                     from   pa_bc_packets
                     where  packet_id   = l_pa_packet_id
                     and    status_code = 'I');
                 Exception
                    when no_data_found then
                         x_result_code := 'F';
                 End;

               End If; -- PARTIAL FLAG CHECK

          End if; --If g_event_id.COUNT > 0 then -- COUNT

      End If; --       If nvl(x_result_code,'P') = 'F' then

   -- ---------------------------------------------------------------------------------------------------------+
   If g_debug_mode = 'Y' then
      log_message(p_msg_token1=>l_program_name||':result code:'||x_result_code);
      log_message(p_msg_token1=>l_program_name||':If resultcode <> F then check if PA relieving created');
   End If;
   -- ---------------------------------------------------------------------------------------------------------+
  =============================================================================================================== */

 If nvl(x_result_code,'P') <> 'F' then

        Select DISTINCT pbc.bc_event_id,pbc.document_distribution_id,pbc.document_type
        BULK COLLECT into g_event_id,g_doc_dist_id,g_document_type
        from   pa_bc_packets pbc
        where  pbc.packet_id   = l_pa_packet_id
        and    pbc.status_code = 'I'
        and    pbc.bc_event_id is not null
        and not exists (select glbc.source_distribution_id_num_1
                        from   gl_bc_packets glbc
                        where  glbc.packet_id    = x_packet_id
                        and    (glbc.event_id     = pbc.bc_event_id
                                OR
                                glbc.event_id     = pbc.source_event_id)
                                -- 2nd clause to take care of sep. line burdening
                        and    glbc.source_distribution_id_num_1 = pbc.document_distribution_id
                        and    (nvl(glbc.accounted_dr,0) - nvl(glbc.accounted_cr,0)) = -1 * (pbc.accounted_dr - pbc.accounted_cr)
                        );

          If g_debug_mode = 'Y' then
             log_message(p_msg_token1=>l_program_name||':'||g_event_id.COUNT||
                                       '  Distribution(s) missing PA relieving records');
          End If;

          If g_event_id.COUNT > 0 then -- COUNT

             If g_debug_mode = 'Y' then
                log_message(p_msg_token1=>l_program_name||' Calling missing_records_failure');
             End If;

             MISSING_RECORDS_FAILURE(p_pa_packet_id => l_pa_packet_id,
                                     p_gl_packet_id => x_packet_id,
                                     p_partial_flag => x_partial_flag,
                                     p_mode         => x_mode);

              g_event_id.DELETE;
              g_doc_dist_id.DELETE;
              g_document_type.DELETE;

               If x_partial_flag = 'N' then  -- PARTIAL FLAG CHECK

                 -- Full mode failure ...
                 x_result_code := 'F';

               Elsif x_partial_flag = 'Y' then

                -- Partial mode failure ..
                -- If all records have failed, set result code to 'F' so that
                -- FC will not proceed further .. (meaning after synch, it exists) ..
                 Begin

                   select null   -- null is ok ..
                   into   x_result_code
                   from   dual
                   where  exists
                    (Select 1
                     from   pa_bc_packets
                     where  packet_id   = l_pa_packet_id
                     and    status_code = 'I');
                 Exception
                    when no_data_found then
                         x_result_code := 'F';
                 End;

               End If; -- PARTIAL FLAG CHECK

          End if; --If g_event_id.COUNT > 0 then -- COUNT

      End If; --       If nvl(x_result_code,'P') = 'F' then
   -- ---------------------------------------------------------------------------------------------------------+

   -- B. Update pa_bc_packet data

   SYNCH_DATA(p_pa_packet_id => l_pa_packet_id,
              p_gl_packet_id => x_packet_id);

 End If;

 If g_debug_mode = 'Y' then
    log_message(p_msg_token1=>l_program_name||'End:x_result_code:'||x_result_code);
 End If;

End Synch_pa_gl_packets;

-- --------------------------------------------------------------------------------+
-- This procedure will mark gl_bc_packets  records to a status such that GL does
-- not execute funds available validation. Previously we used to create liquidation
-- entries. Instead of that, we're executing the following procedure.
-- This is for NO/SEPARATE LINE BURDENING only.
-- This procedure is called from function pa_funds_check
-- --------------------------------------------------------------------------------+
/*
PROCEDURE Mark_gl_bc_packets_for_no_fc (p_packet_id IN Number)
IS
  -- At this point we should not check for result code ...
  Cursor c_bc_packet_id is
         select distinct pabc.project_id
         from    pa_bc_packets pabc
         where   pabc.packet_id = p_packet_id;

  l_project_burden_method VARCHAR2(15);

Begin
  If g_debug_mode = 'Y' Then
     log_message(p_msg_token1 =>'In Mark_gl_bc_packets_for_no_fc - Start');
  End if;

  for x in c_bc_packet_id loop

      l_project_burden_method := pa_funds_control_pkg.check_bdn_on_sep_item(x.project_id);

      If (l_project_burden_method   <> 'DIFFERENT') then

        Update gl_bc_packets glbc
        set    status_code = 'P' -- Open Issue no 4 in DLD: Check if this is final ?????
        where  glbc.rowid in
                   (select pabc.gl_row_number
                    from   pa_bc_packets pabc
                    where  pabc.packet_id  = p_packet_id
                    and    pabc.project_id = x.project_id
                    and    pabc.parent_bc_packet_id is null
                  );
      End If;
  end loop;

  If g_debug_mode = 'Y' Then
     log_message(p_msg_token1 =>'In Mark_gl_bc_packets_for_no_fc - End');
  End if;

End Mark_gl_bc_packets_for_no_fc;
*/
-- --------------------------------------------------------------------------------+
-- This procedure will determine whether funds check/ funds check tieback
-- has been called for non-project related/project related txn. or budget
-- funds check.
-- p_return_code: 'NO_FC', For non-project related FC
-- p_return_code: 'TXN_FC',For project related txn. (including 'RESERVE_BASELINE')
-- p_return_code: 'BUD_FC',For SLA-BC budget baseline integration (GL FC)
-- --------------------------------------------------------------------------------+
PROCEDURE Check_txn_or_budget_fc(p_packet_id   in number,
                                 p_return_code out NOCOPY varchar2)
IS
BEGIN

  If g_debug_mode = 'Y' Then
     log_message(p_msg_token1 =>'In Check_txn_or_budget_fc - Start');
  End if;

  -- Code should first check txns. and then the global variables
  -- Reason: As during budget abseline, PA FC will be called 2 times,
  -- 1st time for txn. FC and the 2nd time for Account FC (by PSA)
  -- so, the 1st time , output should be 'TXN_FC' and the 2nd time 'BUD/REV_FC'

  -- Check if its a "projects transaction" related FC

     Select 'TXN_FC'
     into   p_return_code
     from   dual
     where exists
          (select 1 from pa_bc_packets
           where packet_id = p_packet_id);

  If g_debug_mode = 'Y' Then
     log_message(p_msg_token1 =>'In Check_txn_or_budget_fc:p_return_code'||p_return_code);
     log_message(p_msg_token1 =>'In Check_txn_or_budget_fc - End');
  End If;

EXCEPTION

 When no_data_found then

    -- Is it a budget baseline /year-end/budget check funds related FC call ..

    If nvl(pa_budget_fund_pkg.g_processing_mode,'FC') in ('YEAR_END','BASELINE','CHECK_FUNDS') then

          p_return_code := 'BUD_FC';

   Else
       -- This PA FC call is for "non-project" related txn.
          p_return_code := 'NO_FC';

   End If;

  If g_debug_mode = 'Y' Then
     log_message(p_msg_token1 =>'In Check_txn_or_budget_fc:p_return_code'||p_return_code);
     log_message(p_msg_token1 =>'In Check_txn_or_budget_fc - End');
  End if;

END Check_txn_or_budget_fc;

-- --------------------------------------------------------------------------------+
-- This procedure will be called from do_budget_baseline to fail pa_bc_packet
-- records (by account and period) that fails account level validation or
-- account level funds check. Procedure is AUTONOMOUS.
-- --------------------------------------------------------------------------------+
PROCEDURE Fail_bc_pkt_during_baseline(P_budget_version_id     IN NUMBER,
                                      P_period_name           IN g_tab_period_name%TYPE,
                                      P_budget_ccid           IN g_tab_budget_ccid%TYPE,
                                      P_allow_flag            IN g_tab_allow_flag%TYPE,
                                      P_result_code           IN VARCHAR2)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
Begin

  If P_result_code <> 'F170' then

   Forall i in P_budget_ccid.FIRST..P_budget_ccid.LAST
   Update pa_bc_packets
   set    status_code       = 'R',
          result_code       = P_result_code
   where  budget_version_id = P_budget_version_id
   and    budget_ccid       = P_budget_ccid(i)
   and    period_name       = P_period_name(i)
   and    P_allow_flag(i)   = 'N';

  Elsif P_result_code = 'F170' then

   Update pa_bc_packets
   set    status_code       = 'R',
          result_code       = 'F170'
   where  budget_version_id = P_budget_version_id
   and    status_code in ('P','A');

  End If;

 COMMIT;

End Fail_bc_pkt_during_baseline;

-- --------------------------------------------------------------------------------+
-- This procedure will be called from do_budget_baseline to fail pa_budget_acct_lines
-- pa_budget_acct_lines (by account and period) that fails account level validation
-- or account level funds check. Procedure is AUTONOMOUS.
-- --------------------------------------------------------------------------------+
 PROCEDURE Update_failure_in_acct_summary(P_budget_version_id     IN NUMBER,
                                          P_period_name           IN g_tab_period_name%TYPE,
                                          P_budget_ccid           IN g_tab_budget_ccid%TYPE,
                                          P_allow_flag            IN g_tab_allow_flag%TYPE,
                                          P_result_code           IN VARCHAR2)
 IS
   PRAGMA AUTONOMOUS_TRANSACTION;
 Begin

   If g_debug_mode = 'Y' then
      log_message(p_msg_token1=>'Update_failure_in_acct_summary:P_budget_version_id['||P_budget_version_id
                                 ||'], P_result_code['||P_result_code||']' );
      log_message(p_msg_token1=>'Update_failure_in_acct_summary: No of records to fail:'||P_budget_ccid.COUNT);
   End If;

   Forall i in P_budget_ccid.FIRST..P_budget_ccid.LAST
   Update pa_budget_acct_lines
   set    funds_check_status_code = 'R',
          funds_check_result_code = P_result_code
   where  budget_version_id       = P_budget_version_id
   and    code_combination_id     = P_budget_ccid(i)
   and    gl_period_name          = P_period_name(i)
   and    P_allow_flag(i)         = 'N'
   and    P_budget_ccid(i) is not null;
   -- last condition is reqd. as zero$ lines will not be existing in draft ..

   If g_debug_mode = 'Y' then
      log_message(p_msg_token1=>'Update_failure_in_acct_summary: Records Updated:'||SQL%ROWCOUNT);
      log_message(p_msg_token1=>'Update_failure_in_acct_summary: Fail other records with F170');
   End If;

  Update pa_budget_acct_lines
   set    funds_check_status_code = 'R',
          funds_check_result_code = 'F170'
   where  budget_version_id       = P_budget_version_id
   and    nvl(funds_check_status_code,'P')     <> 'R';

   If g_debug_mode = 'Y' then
      log_message(p_msg_token1=>'Update_failure_in_acct_summary: Records Updated:'||SQL%ROWCOUNT);
   End If;

 COMMIT;

 End Update_failure_in_acct_summary;

-- --------------------------------------------------------------------------------+
-- This procedure will be called from do_budget_baseline to update pa_bc_packet
-- project_acct_result_code and result_code to 'P101' after account level funds
-- check is successful. Procedure is AUTONOMOUS
-- --------------------------------------------------------------------------------+
PROCEDURE Upd_bc_pkt_acct_result_code(P_budget_version_id     IN NUMBER)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
Begin
   Update pa_bc_packets
    set    project_acct_result_code = 'P101',
           result_code = 'P101'
    where  budget_version_id       = P_budget_version_id;

    If g_debug_mode = 'Y' then
        log_message(p_msg_token1=>l_program_name||'Upd_bc_pkt_acct_result_code records updated:'||SQL%ROWCOUNT);
    End If;

COMMIT;
End Upd_bc_pkt_acct_result_code;

-- --------------------------------------------------------------------------------+
-- Procedure Update_budget_ccid updates budget_ccid on the pa_bc_packet records
-- for this baseline, its an AUTONOMOUS procedure ..
-- --------------------------------------------------------------------------------+
PROCEDURE Update_budget_ccid(P_budget_version_id       IN NUMBER,
                             P_budget_ccid             IN g_tab_budget_ccid%TYPE,
			     P_budget_line_id          IN g_tab_budget_line_id%TYPE,
                             P_budget_entry_level_code IN VARCHAR2,
                             P_period_name             IN g_tab_period_name%TYPE,
                             P_rlmi                    IN g_tab_rlmi%TYPE,
                             P_task_id                 IN g_tab_task_id%TYPE,
                             P_derived_ccid            IN g_tab_budget_ccid%TYPE,
                             P_allowed_flag            IN g_tab_allow_flag%TYPE,
                             P_result_code             IN OUT NOCOPY VARCHAR2)

IS
   PRAGMA AUTONOMOUS_TRANSACTION;
Begin

  -- ------------------------------------------------------------------------------------+
  If g_debug_mode = 'Y' then
      log_message(p_msg_token1=>'Update_budget_ccid: p_budget_entry_level_code['
                  ||p_budget_entry_level_code||'] Null->Update new CCID else Synch' );
   End If;
  -- ------------------------------------------------------------------------------------+

 p_result_code := 'F';

 If p_budget_entry_level_code is NULL then


    Forall x in p_derived_ccid.FIRST..p_derived_ccid.LAST
    Update pa_bc_packets pbc
    set    pbc.budget_ccid = p_derived_ccid(x)
    where  pbc.budget_ccid = p_budget_ccid(x)
    and    pbc.period_name = p_period_name(x)
    and    p_allowed_flag(x) = 'Y';

 Else

   If p_budget_entry_level_code = 'P' then

    Forall i in p_budget_ccid.FIRST..p_budget_ccid.LAST
        Update pa_bc_packets pbc
        set    pbc.budget_ccid             = p_budget_ccid(i),
               pbc.budget_line_id          = p_budget_line_id(i)
        where  pbc.budget_version_id       = p_budget_version_id
        and    pbc.bud_resource_list_member_id = p_rlmi(i)
        and    pbc.period_name             = p_period_name(i);

   ElsIf p_budget_entry_level_code in ('L','T','M') then

    Forall i in p_budget_ccid.FIRST..p_budget_ccid.LAST
        Update pa_bc_packets pbc
        set    pbc.budget_ccid               = p_budget_ccid(i),
               pbc.budget_line_id            = p_budget_line_id(i)
        where  pbc.budget_version_id         = p_budget_version_id
        and    pbc.bud_task_id               = p_task_id(i)
        and    pbc.bud_resource_list_member_id   = p_rlmi(i)
        and    pbc.period_name               = p_period_name(i);
   End If;

 End If;

  -- ------------------------------------------------------------------------------------+
    If g_debug_mode = 'Y' then
      log_message(p_msg_token1=>'Update_budget_ccid on pa_bc_packets:Budget_ccid updated on:'
                  || SQL%ROWCOUNT||' records');
   End If;
  -- ------------------------------------------------------------------------------------+

    Update pa_bc_packets pbc
    set    pbc.result_code      = 'F132',
           pbc.status_code      = 'R'
    where  pbc.budget_version_id = p_budget_version_id
    and    pbc.budget_ccid is null;

  -- ------------------------------------------------------------------------------------+
   If g_debug_mode = 'Y' then
      log_message(p_msg_token1=>'Update_budget_ccid on pa_bc_packets:'
                  ||' Records with null ccid'||SQL%ROWCOUNT||' If >0 then F132');
   End If;
  -- ------------------------------------------------------------------------------------+

    If SQL%ROWCOUNT > 0 then
       p_result_code := 'F';
    End if;

 COMMIT;
 p_result_code := 'S';

Exception

   When others then
        COMMIT;
        p_result_code := 'F';
End Update_budget_ccid;

-- --------------------------------------------------------------------------------+
-- This procedure will check if there exists any txn. against the project
-- It will return 'Y' if any txn exists
-- --------------------------------------------------------------------------------+
Procedure Any_txns_against_project(p_project_id           IN NUMBER,
                                   p_txn_exists_in_bc_pkt OUT NOCOPY VARCHAR2,
                                   p_txn_exists_in_bc_cmt OUT NOCOPY VARCHAR2)
IS
Begin
    If g_debug_mode = 'Y' then
       log_message(p_msg_token1=>'Any_txns_against_project:p_project_id:'||p_project_id);
    End If;

      If (pa_budget_fund_pkg.g_processing_mode in ('BASELINE','CHECK_FUNDS') and pa_budget_fund_pkg.g_cost_rebaseline_flag = 'Y') then

          If g_debug_mode = 'Y' then
             log_message(p_msg_token1=>'Any_txns_against_project:Baseline/CF Mode-Check if txns. exists in pa_bc_packets');
          End If;

          Begin
              Select 'Y' into p_txn_exists_in_bc_pkt from dual where exists
                        (select 1 from pa_bc_packets where project_id = p_project_id and status_code in ('A','P','I'));
           Exception
               When no_data_found then
                     p_txn_exists_in_bc_pkt := 'N';
           End;

          If g_debug_mode = 'Y' then
             log_message(p_msg_token1=>'Any_txns_against_project:Baseline/CF Mode-Check if txns. exists in pa_bc_commitments');
          End If;

          Begin
              Select 'Y' into p_txn_exists_in_bc_cmt from dual where exists
                        (select 1 from pa_bc_commitments where project_id = p_project_id);
           Exception
               When no_data_found then
                     p_txn_exists_in_bc_cmt := 'N';
           End;

        Else
             p_txn_exists_in_bc_pkt := 'N';
             p_txn_exists_in_bc_cmt := 'N';
        End if;

End Any_txns_against_project;

-- --------------------------------------------------------------------------------+
-- This procedure will execute the budget account validation, account level FC
-- and update budget lines with the new derived accounts, call PROCEDURE
-- Build_account_summary to build pa_budget_acct_lines
-- Parameters:
-- p_packet_id     : packet being funds checked
-- p_return_status : 'S' for success and 'F' for failure
-- --------------------------------------------------------------------------------+
PROCEDURE Do_budget_baseline_tieback(p_packet_id     IN NUMBER,
                                     p_return_status OUT NOCOPY VARCHAR2)
IS
 t_ccid		     pa_plsql_datatypes.Idtabtyp;
 t_bud_ccid	     pa_plsql_datatypes.Idtabtyp;
 t_budget_line_id    pa_plsql_datatypes.Idtabtyp;
 t_rlmi              pa_plsql_datatypes.Idtabtyp;
 t_parent_rlmi       pa_plsql_datatypes.Idtabtyp;
 t_project_id        pa_plsql_datatypes.Idtabtyp;
 t_task_id           pa_plsql_datatypes.Idtabtyp;
 t_top_task_id       pa_plsql_datatypes.Idtabtyp;
 t_prev_ver_ccid     pa_plsql_datatypes.Idtabtyp;
 t_start_date        pa_plsql_datatypes.Datetabtyp;
 t_txn_currency_code pa_plsql_datatypes.char50TabTyp;
 t_draft_needs_update pa_plsql_datatypes.char50TabTyp;
 t_draft_budget_rowid rowidtabtyp;
 t_draft_ccid        pa_plsql_datatypes.Idtabtyp;
 t_raid              TypeNum;
 t_gl_rowid          rowidtabtyp;
 t_budget_rowid      rowidtabtyp;
 t_budget_start_date TypeDate;
 l_bvid_for_acct_changed_API pa_budget_versions.budget_Version_id%type;

 l_count             NUMBER(4);
 l_validation_failed VARCHAR2(1);
 l_set_of_books_id   pa_implementations_all.set_of_books_id%type;
 l_budget_entry_level_code   pa_budget_entry_methods.entry_level_code%TYPE;
 l_current_budget_version_id pa_budget_versions.budget_version_id%TYPE;
 l_draft_budget_version_id   pa_budget_versions.budget_version_id%TYPE;
 l_result_code               pa_bc_packets.result_code%TYPE;
 l_acct_changed              VARCHAR2(1);
 l_draft_acct_changed_flag   VARCHAR2(1);
 l_record_updated_flag       VARCHAR2(1);
 l_project_id                pa_budget_versions.project_id%type;
 l_txn_exists_bc_pkt_flag    VARCHAR2(1);
 l_txn_exists_bc_cmt_flag    VARCHAR2(1);
 l_gl_failure_flag           VARCHAR2(1);
 l_derive_draft_values       VARCHAR2(1);

 -- Step 2.0: Synch budget lines and pa_bc_packets ....
 Cursor c_acct_sync_bud_line_pa_bc_pkt(p_budget_version_id in NUMBER,
                                       p_set_of_books_id IN NUMBER,
                                       p_project_id      IN NUMBER) is
 select pbl.code_combination_id,
            pbl.budget_line_id,
            pra.resource_list_member_id,
            pra.task_id,
            pbl.period_name --glps.period_name
     from   pa_budget_lines         pbl,
            pa_resource_assignments pra--,
            --gl_period_statuses      glps
     where  pra.budget_version_id       = p_budget_version_id
     and    pra.project_id              = p_project_id -- added to improve performance ..
     and    pra.budget_version_id       = pbl.budget_version_id
     and    pra.resource_assignment_id  = pbl.resource_assignment_id;
     --and    glps.application_id         = 101
     --and    glps.set_of_books_id        = p_set_of_books_id
     --and    trunc(pbl.start_date)       = trunc(glps.start_date)
     --and    exists (select 1
     --               from   pa_bc_packets pbc
     --               where  pbc.budget_version_id       = pbl.budget_version_id
     --               and    pbc.resource_list_member_id = pra.resource_list_member_id
     --               and    (pra.task_id                = pbc.task_id      OR
     --                       pra.task_id                = pbc.top_task_id  OR
     --                       pra.task_id                = 0)
     --               and    glps.period_name            = pbc.period_name
     --              );

  -- Step 3.0: Identify records that have failed in gl_bc_packets ..
  Cursor c_gl_failure(p_budget_version_id in number) is
  select pbl.code_combination_id           budget_ccid,
         pbl.period_name                   period_name,
         'N'                               allow_flag ,
         pra.project_id,
         pra.task_id,
         pra.resource_list_member_id       rlmi,
         pbl.start_date,
         pbl.txn_currency_code
  from   gl_bc_packets glbc,
         pa_budget_lines pbl,
         pa_resource_assignments pra
  where  glbc.packet_id          = p_packet_id
  and    pbl.budget_version_id   = p_budget_version_id
  and    pbl.budget_line_id      = glbc.source_distribution_id_num_1
  and    substr(nvl(glbc.result_code,'P'),1,1)  = 'F'
  and    pra.resource_assignment_id = pbl.resource_assignment_id
  and    pra.budget_version_id      = pbl.budget_version_id;
  --and    nvl(glbc.result_code,'P) <> 'F35';

  -- Step 4.0: This cursor is used to synch account data between gl_bc_packets and the budget ..
  Cursor c_budget_lines_synch(p_budget_version_id in number) is
  select glbc.code_combination_id          sla_ccid,
         glbc.rowid                        gl_rowid,
         pbl.code_combination_id           budget_ccid,
         pbl.resource_assignment_id        budget_raid,
         pbl.rowid                         budget_rowid,
         pbl.start_date                    start_date,
         pbl.period_name                   period_name,
         'Y'                               allow_flag,
         pbl.budget_line_id                budget_line_id,
         pbl.txn_currency_code             txn_currency_code,
         'N'                               draft_needs_update,
         pra.project_id,
         pra.task_id,
         pra.resource_list_member_id,
         nvl(prlm.parent_member_id,-99)  parent_rlmi
  from   gl_bc_packets glbc,
         pa_budget_lines pbl,
         pa_resource_assignments pra,
         pa_resource_list_members prlm
  where  glbc.packet_id          = p_packet_id
  and    pbl.budget_version_id   = p_budget_version_id
  and    pbl.budget_line_id      = glbc.source_distribution_id_num_1
  and    pra.resource_assignment_id = pbl.resource_assignment_id
  and    pra.budget_version_id      = pbl.budget_version_id
  and    prlm.resource_list_member_id = pra.resource_list_member_id;
  --and    nvl(pbl.code_combination_id,-1) <> glbc.code_combination_id;

  -- Above commented as user could have changed draft account and then modified
  -- SLA setup to derive the same account ..meaning..we need to compare ccids across version ..

 -- Step 7.0: Cursor used for account level funds check
 -- Logic:
 -- Get the distinct ccid/start/end date combo from pa_bc_packets and for that check if there
 -- are any combo having sum(available amount) < 0

 Cursor c_acct_lines(p_current_bvid IN NUMBER) is
 select pbl.gl_period_name, pbl.code_combination_id ,'N' allow_flag
 from   pa_budget_acct_lines pbl
 where  (pbl.budget_version_id,pbl.code_combination_id,pbl.start_date,pbl.end_date) in
        (select pbl.budget_version_id,pbl.code_combination_id,pbl.start_date,pbl.end_date
           from pa_budget_acct_lines pbl
          where (pbl.budget_version_id,pbl.code_combination_id,pbl.start_date,pbl.end_date) in
                 (select distinct a.budget_version_id,a.budget_ccid,a.fc_start_date,a.fc_end_date
                    from pa_bc_packets a
                    where a.budget_version_id = p_current_bvid)
          group by pbl.budget_version_id,pbl.code_combination_id,pbl.start_date,pbl.end_date
          having sum(nvl(pbl.Curr_Ver_Available_Amount,0)) < 0
         )
 UNION
 -- Bug 5206341 : Cursor to validate account level balances for Open and Closed periods
 select pbl.gl_period_name, pbl.code_combination_id ,'N' allow_flag
 from   pa_budget_acct_lines pbl
 where  (pbl.budget_version_id,pbl.code_combination_id) in
        (select pbl.budget_version_id,pbl.code_combination_id
           from pa_budget_acct_lines pbl
          where pbl.budget_version_id = p_current_bvid
          group by pbl.budget_version_id,pbl.code_combination_id
          having sum(nvl(pbl.Curr_Ver_Available_Amount,0)) < 0
         )
   AND PA_FUNDS_CONTROL_UTILS.CLOSED_PERIODS_EXISTS_IN_BUDG(p_current_bvid) ='Y' ;

 --and    pbl.Curr_Ver_Available_Amount < 0;
 -- Draft has Jan and txn for Dec.. YTD/Y, in that case, Jan should have failure too

 -- 10.0: Cursor used to select records to fail all records ....
 -- As data split between packet, records were not being failed in the credit packet ..
 Cursor c_gl_records is
        select glbc.rowid,glbc.ae_header_id,glbc.ledger_id
        from   gl_bc_packets glbc
        where  glbc.event_id in
                          (select event_id from psa_bc_xla_events_gt);

l_dummy_value            number(1);

Begin

 l_program_name := 'Do_Budget_baseline_tieback:';
 If g_debug_mode = 'Y' then
    log_message(p_msg_token1=>l_program_name||'Start');
 End If;

 /*  If CC Logic needs to be added then we will need to have some sort of outer
     loop which will exeute for Cost and CC budget
 */
 -- ---------------------------------------------------------------------------+
 -- 0.0: Is the call for the current version?? if not exit
 --      Reason: BC calls PAFC 2 times as the packets are created per entity_id
 --      So: During a CF after baseline or re-baseline, 2 packets will be
 --      created, for the reversing packet, we should not do any processing
 --      Account check etc. is not reqd. for the reversing as we use
 --      'LINE REVERSALS'
 -- ---------------------------------------------------------------------------+
 log_message(p_msg_token1=>l_program_name||'Check if PAFC called for current version');

 l_dummy_value := 0;

  Begin

    Select 1 into l_dummy_value from dual
    where exists (Select 1
                  from   gl_bc_packets glbc,
                         pa_budget_lines pbl
                  where  glbc.packet_id          = p_packet_id
                  and    pbl.budget_version_id   = pa_budget_fund_pkg.g_cost_current_bvid
                  and    pbl.budget_line_id      = glbc.source_distribution_id_num_1);

  Exception
    When no_data_found then
        null;
  End;

  If l_dummy_value = 0 then
      If g_debug_mode = 'Y' then
         log_message(p_msg_token1=>l_program_name||'PA FC called for prev. baselined version');
      End If;

      g_packet_credit_processed := 'Y';

      If g_packet_debit_processed = 'Y' then
        log_message(p_msg_token1=>l_program_name||': As debit already processed Calling Fail_credit_packet');
         FAIL_CREDIT_PACKET(p_input_packet       => 'CREDIT',
                            p_return_status_code => p_return_status);
      End if;

     RETURN;
  End If;

      If g_debug_mode = 'Y' then
         l_program_name := 'Do_budget_baseline_tieback';
         log_message(p_msg_token1=>l_program_name||'PA FC called for latest version - Draft/Baselined');
      End If;

 -- ---------------------------------------------------------------------------+
 -- 1.0: Initalize variables ..
 -- ---------------------------------------------------------------------------+
    -- 1.1: Return Status:   If all steps pass, send 'S', else send 'F'
    p_return_status := 'S';

    -- 1.2: initalize limit var. used for bulk ..
    l_limit := 500;

     -- 1.3:  Get latest budget version being baselined
     l_current_budget_version_id := pa_budget_fund_pkg.g_cost_current_bvid;

     -- 1.4: Get draft version ...
     -- This is required to udpate the account summary table (we will be updating acct.
     -- summary table for the draft version, except for 'Year end' where we will be updating
     -- the working budget created ..

     If g_debug_mode = 'Y' then
        log_message(p_msg_token1=>l_program_name||'Get Draft Budget');
     End If;

     --If (pa_budget_fund_pkg.g_cost_rebaseline_flag = 'Y') then
         If pa_budget_fund_pkg.g_processing_mode in ('YEAR_END','BASELINE') then

              -- Get the draft or working budget ..

                 Select pbv.budget_version_id
                 into   l_draft_budget_version_id
                 from   pa_budget_versions pbv
                 where  (pbv.project_id,pbv.budget_type_code) in
                         (select project_id,budget_type_code
                          from   pa_budget_versions
                          where  budget_version_id = l_current_budget_version_id)
                 and    pbv.budget_status_code = decode(pa_budget_fund_pkg.g_processing_mode,
                                             'YEAR_END','W','S');

                 If g_debug_mode = 'Y' then
                    log_message(p_msg_token1=>l_program_name||'Yr End/Base Draft Budget:'||l_draft_budget_version_id);
                 End If;

           End If;

     -- End If;


     If pa_budget_fund_pkg.g_processing_mode = 'CHECK_FUNDS' then

        l_draft_budget_version_id := l_current_budget_version_id;

        If g_debug_mode = 'Y' then
           log_message(p_msg_token1=>l_program_name||'CF Draft Budget:'||l_draft_budget_version_id);
        End If;

     End If;

     -- 1.5: Derive budget entry level code
        If (pa_budget_fund_pkg.g_balance_type = 'E' /*Top Down*/ and
            pa_budget_fund_pkg.g_cost_rebaseline_flag = 'Y'      ) then

         If g_debug_mode = 'Y' then
            log_message(p_msg_token1=>l_program_name||'Get Budget Entry Method');
         End If;

           select pbem.entry_level_code
           into   l_budget_entry_level_code
           from   pa_budget_entry_methods pbem,
                  pa_budget_versions pbv
           where  pbv.budget_version_id         = l_current_budget_version_id
           and    pbem.budget_entry_method_code = pbv.budget_entry_method_code;

       End If;

     If g_debug_mode = 'Y' then
        log_message(p_msg_token1=>l_program_name||':g_processing_mode:'||pa_budget_fund_pkg.g_processing_mode||
                   ':Balance type:'||pa_budget_fund_pkg.g_balance_type||
                   ':Budget Amount Code:'||pa_budget_fund_pkg.g_budget_amount_code||
                   ':Rebaseline Flag:'||pa_budget_fund_pkg.g_cost_rebaseline_flag);

        log_message(p_msg_token1=>l_program_name||':Current budget version:'||l_current_budget_version_id||
                    ':Draft version:'||l_draft_budget_version_id||':budget entry level code:' || l_budget_entry_level_code);
     End If;

     -- 1.6: Reset funds_check_status_code and funds_check_result_code for the draft version
     --      in check funds mode.
     --      Reason: if the last check funds had failed then the failure codes should be nullified
     --      1/14/06: this is reqd. for baseline too..so that it can override the
     --      existing status ... if there is any failure ..
     --      8/22/06: This step should be carried out for CF/baseline/rebaseline for E/B balance_type
     --               Failures can happen for first time baseline and also for bottom up budgets too

     --If ((pa_budget_fund_pkg.g_processing_mode = 'CHECK_FUNDS') or
        --(pa_budget_fund_pkg.g_balance_type = 'E'            and     -- Top Down
        -- pa_budget_fund_pkg.g_cost_rebaseline_flag = 'Y'    and     -- Re-costing
        -- pa_budget_fund_pkg.g_processing_mode = 'BASELINE')
     --then

     If (pa_budget_fund_pkg.g_processing_mode in ('CHECK_FUNDS','BASELINE')) then

        If g_debug_mode = 'Y' then
           --log_message(p_msg_token1=>l_program_name||'Nullify failure status from draft version - Check funds');
           log_message(p_msg_token1=>l_program_name||' Rebuild Draft summary');
           -- this is reqd. for the scenario where the user has modified the draft version budget line and after that we
           -- the user had created txn. for the baseline version which has a diff acct.
           -- In this case, draft. budget line can have acct. A2 and summary will have A1 ..
        End If;

        --RESET_STATUS_CODE_ON_SUMMARY(l_draft_budget_version_id);
        BUILD_ACCOUNT_SUMMARY_AUTO(x_budget_version_id => l_draft_budget_version_id,
                                     x_balance_type =>pa_budget_fund_pkg.g_balance_type,
                                     x_budget_amount_code=> pa_budget_fund_pkg.g_budget_amount_code,
                                     x_prev_budget_version_id=>pa_budget_fund_pkg.g_cost_prev_bvid,
                                     x_mode=>'PASS');

        -- Autonomous used as we're updating pa_budget_acct_lines in AUTONOMOUS
        -- mode for failures later ..
     End If;

   -- 1.7: Initalize l_acct_changed
           l_acct_changed := 'N';
           l_draft_acct_changed_flag := 'N';
           l_record_updated_flag := 'N';

   -- 1.8: Get project_id
           If g_debug_mode = 'Y' then
              l_program_name := 'Do_budget_baseline_tieback';
              log_message(p_msg_token1=>l_program_name||'Get Project Id');
           End If;

           select project_id into l_project_id from pa_budget_versions
           where  budget_version_id = l_current_budget_version_id;

   -- 1.9: If processing mode is BASELINE (and its a rebaseline, check if there are
   --      txns. against the project, if yes, set flag to 'Y' else 'N')
   --      This flag will be used further in the code to minimize code being
   --      executed ..this will improve performance ..
   --      Note: project_id being used as there is an index on project_id alone ..

            l_txn_exists_bc_pkt_flag := 'N';
            l_txn_exists_bc_cmt_flag := 'N';

            -- 8/22: This should fire for re-baseline/top-down only ..
            If (pa_budget_fund_pkg.g_balance_type = 'E'            and     -- Top Down
                pa_budget_fund_pkg.g_cost_rebaseline_flag = 'Y')    --and     -- Re-costing
                 --pa_budget_fund_pkg.g_processing_mode = 'BASELINE')
            then

              ANY_TXNS_AGAINST_PROJECT(p_project_id           => l_project_id,
                                       p_txn_exists_in_bc_pkt => l_txn_exists_bc_pkt_flag,
                                       p_txn_exists_in_bc_cmt => l_txn_exists_bc_cmt_flag);

            End If;

            If g_debug_mode = 'Y' then
               l_program_name := 'Do_budget_baseline_tieback';
               log_message(p_msg_token1=>l_program_name||'l_txn_exists_bc_pkt_flag ['||l_txn_exists_bc_pkt_flag||
                                       '] l_txn_exists_bc_cmt_flag ['||l_txn_exists_bc_cmt_flag||']');
            End If;

 -- ------------------------- END STEP 1 --------------------------------------+

 -- ---------------------------------------------------------------------------+
 -- 2.0 : Update budget_ccid and budget_line_id on pa_bc_packets . Ccid being
 --       calculated here as during the regular flow the zero $ lines created
 --       during baseline are not visible ...
 --       Call procedure update_budget_ccid, this has to be autonomous ...
 -- ---------------------------------------------------------------------------+
 If (pa_budget_fund_pkg.g_balance_type = 'E'            and     -- Top Down
     pa_budget_fund_pkg.g_cost_rebaseline_flag = 'Y'    and     -- Re-costing
     pa_budget_fund_pkg.g_processing_mode = 'BASELINE'  and     -- Baseline
     l_txn_exists_bc_pkt_flag = 'Y')                                   -- Txn. exists against the project
 then -- (2.0 Main If)

    -- Get set of books
     If g_debug_mode = 'Y' then
        log_message(p_msg_token1=>l_program_name||'Get Set of Books');
     End If;

    select set_of_books_id into l_set_of_books_id from pa_implementations;

    -- Update budget lines on pa_bc_packets ..
     If g_debug_mode = 'Y' then
        log_message(p_msg_token1=>l_program_name||'Update budget info. on pa_bc_packets');
     End If;

    open c_acct_sync_bud_line_pa_bc_pkt(l_current_budget_version_id, l_set_of_books_id,l_project_id);
    loop
    fetch c_acct_sync_bud_line_pa_bc_pkt BULK COLLECT into g_tab_budget_ccid,
                                           g_tab_budget_line_id,
                                           g_tab_rlmi,
                                           g_tab_task_id,
                                           g_tab_period_name
                                           LIMIT l_limit;

       If g_tab_budget_ccid.exists(1) then

          -- Update Budget ccid and budget line id on pa_bc_packets .. AUTONOMOUS

          Update_budget_ccid(P_budget_version_id       => l_current_budget_version_id,
                             P_budget_ccid             => g_tab_budget_ccid,
                             P_budget_line_id          => g_tab_budget_line_id,
                             P_budget_entry_level_code => l_budget_entry_level_code,
                             P_period_name             => g_tab_period_name,
                             P_rlmi                    => g_tab_rlmi,
                             P_task_id                 => g_tab_task_id,
                             P_derived_ccid            => t_ccid,
                             P_allowed_flag            => g_tab_allow_flag,
                             P_result_code             => P_return_status);

                             -- Note: Above t_ccid and g_tab_allow_flag are null pl/sql tables ..

           -- Initalize variables ..
           g_tab_budget_ccid.DELETE;
           g_tab_budget_line_id.DELETE;
           g_tab_rlmi.DELETE;
           g_tab_task_id.DELETE;
           g_tab_period_name.DELETE;

       Else
         EXIT; -- Exit Loop
       End If;

    End Loop; -- c_acct_sync_bud_line_pa_bc_pkt

    Close c_acct_sync_bud_line_pa_bc_pkt;

     If g_debug_mode = 'Y' then
        l_program_name := 'Do_budget_baseline_tieback';
        log_message(p_msg_token1=>l_program_name||'Update_budget_ccid complete, status is:'||p_return_status);
     End If;

 End If; -- (2.0 Main If)
 -- ------------------------- END STEP 2  --------------------------------------+

 -- -------------------------- STEP 3  -----------------------------------------+
 -- If GL failed, fail pa_bc_packets and Summary acct (draft version)
 -- pa_bc_packets failed for Top-Down/Re-Baseline ..
 -- Acct. summary failed for all ...
 -- ----------------------------------------------------------------------------+
 If g_debug_mode = 'Y' then
    log_message(p_msg_token1=>l_program_name||':Check if any GL records failed');
 End If;

 Begin

   Select 'Y' into l_gl_failure_flag from dual where exists
              (select 1 from gl_bc_packets
               where packet_id = p_packet_id
               and   substr(nvl(result_code,'P'),1,1)  = 'F');
 Exception
    When no_data_found then
         l_gl_failure_flag := 'N';
 End;

 If g_debug_mode = 'Y' then
    log_message(p_msg_token1=>l_program_name||':l_gl_failure_flag:'||l_gl_failure_flag);
 End If;

 If (P_return_status = 'S' and l_gl_failure_flag = 'Y') then

    If g_debug_mode = 'Y' then
      log_message(p_msg_token1=>l_program_name||':Inside GL failure if condition');
    End If;

     -- ##  Get the budget lines where account has changed
    Open c_gl_failure(l_current_budget_version_id);
    loop
    fetch c_gl_failure BULK COLLECT into t_bud_ccid,
	                                 g_tab_period_name,
                                         g_tab_allow_flag,
                                         t_project_id,
                                         t_task_id,
                                         t_rlmi,
                                         t_start_date,
                                         t_txn_currency_code
                                         LIMIT l_limit;


      If t_bud_ccid.exists(1) then

           -- ----------------------------------------------------------------------------------+
           -- ##  There are records to process ..
           If g_debug_mode = 'Y' then
              log_message(p_msg_token1=>l_program_name||': GL failed case exists');
           End If;
           -- ----------------------------------------------------------------------------------+

           If (pa_budget_fund_pkg.g_balance_type    = 'E'           and
               pa_budget_fund_pkg.g_processing_mode = 'BASELINE'    and
               pa_budget_fund_pkg.g_cost_rebaseline_flag = 'Y'      and
               l_txn_exists_bc_pkt_flag = 'Y') then
              -- ----------------------------------------------------------------------------------+
              -- ##  Fail pa_bc_packets:
              If g_debug_mode = 'Y' then
                 log_message(p_msg_token1=>l_program_name||': GL failed - Fail pa_bc_packets');
              End If;
              -- ----------------------------------------------------------------------------------+

              -- Autonomous procedure called for update ...these are the records that
              -- has already passed PA FC but now needs to be failed ...

                FAIL_BC_PKT_DURING_BASELINE(P_budget_version_id => l_current_budget_version_id,
                                            P_period_name       => g_tab_period_name,
                                            P_budget_ccid       => t_bud_ccid,
                                            P_allow_flag        => g_tab_allow_flag,
                                            P_result_code       => 'F155');
            End If;

            -- ----------------------------------------------------------------------------------+
            -- ##  Fail draft account summary ..
            If g_debug_mode = 'Y' then
               l_program_name := 'Do_budget_baseline_tieback';
               log_message(p_msg_token1=>l_program_name||': GL failed - Fail account summary');
            End If;
            -- ----------------------------------------------------------------------------------+
              --  Update Draft version (account summary table) to failure ..
              --  Note: in case of 'Year End' the working budget will be updated ..

            If pa_budget_fund_pkg.g_processing_mode = 'CHECK_FUNDS' then
               l_result_code := 'F150';
            Else
               l_result_code := 'F155';
           End If;

           -- If the mode is not CF then the account derived may be different than that on CF
           -- so, we need to derive the account that exists on the draft version ..
           -- else issue was that baseline had acct A2 and draft had A1 and then the call
           -- to UPDATE_FAILURE_IN_ACCT_SUMMARY would not udpate any records ...

           If pa_budget_fund_pkg.g_processing_mode <> 'CHECK_FUNDS' then

              If g_debug_mode = 'Y' then
                 log_message(p_msg_token1=>l_program_name||': Derive draft ccid');
              End If;

                 for x in t_project_id.FIRST..t_project_id.LAST loop
                     Begin
                         select code_combination_id draft_ccid
                         into   t_draft_ccid(x)
                         from   pa_budget_lines bl,
                                pa_resource_assignments pra
                         where  pra.budget_version_id       = l_draft_budget_version_id
                         and    pra.project_id              = t_project_id(x)
                         and    pra.task_id                 = t_task_id(x)
                         and    pra.resource_list_member_id = t_rlmi(x)
                         and    bl.resource_assignment_id   = pra.resource_assignment_id
                         and    bl.start_date               = t_start_date(x)
                         and    bl.txn_currency_code        = t_txn_currency_code(x);


                     Exception
                        When no_data_found then
                              t_draft_ccid(x) := null;
                     End;
                 end loop;

           End If;

              If g_debug_mode = 'Y' then
                 log_message(p_msg_token1=>l_program_name||': Update failure in draft acct. summary');
              End If;

              -- ----------------------------------------------------------------------------------+
              -- Following if condition is required as t_draft_ccid is calcualted for non-CF mode only ...
              -- as for CF mode, t_bud_ccid is the draft ccid ...
              -- ----------------------------------------------------------------------------------+
              If pa_budget_fund_pkg.g_processing_mode <> 'CHECK_FUNDS' then

                 If g_debug_mode = 'Y' then
                    log_message(p_msg_token1=>l_program_name||': <> CF, Calling Update_failure_in_acct_summary');
                 End If;

              -- Autonomous call to update pa_budget_acct_lines for the draft version ...
                 UPDATE_FAILURE_IN_ACCT_SUMMARY(P_budget_version_id => l_draft_budget_version_id,
                                                P_period_name       => g_tab_period_name,
                                                P_budget_ccid       => t_draft_ccid,
                                                P_allow_flag        => g_tab_allow_flag,
                                                P_result_code       => l_result_code);
              Else

                 If g_debug_mode = 'Y' then
                    log_message(p_msg_token1=>l_program_name||': = CF, Calling Update_failure_in_acct_summary');
                 End If;

              -- Autonomous call to update pa_budget_acct_lines for the draft version ...
                 UPDATE_FAILURE_IN_ACCT_SUMMARY(P_budget_version_id => l_draft_budget_version_id,
                                                P_period_name       => g_tab_period_name,
                                                P_budget_ccid       => t_bud_ccid,
                                                P_allow_flag        => g_tab_allow_flag,
                                                P_result_code       => l_result_code);
              End If;



           -- ----------------------------------------------------------------------------------+
           -- ##  Set failure status ..
           -- ----------------------------------------------------------------------------------+
               p_return_status := 'F';

      Else
       EXIT; -- Exit Loop
      End If; -- If t_bud_ccid(1).exists

       -- ## Initialize ..
       t_bud_ccid.DELETE;
       g_tab_period_name.DELETE;
       g_tab_allow_flag.DELETE;
       t_project_id.DELETE;
       t_task_id.DELETE;
       t_rlmi.DELETE;
       t_start_date.DELETE;
       t_txn_currency_code.DELETE;

      if t_draft_ccid.exists(1) then  t_draft_ccid.DELETE; end if;

    End Loop;

    close c_gl_failure;
 -- -------------------------------------------------------------------------------------------------------+
 If (pa_budget_fund_pkg.g_balance_type = 'E'           and
     pa_budget_fund_pkg.g_processing_mode = 'BASELINE' and
     pa_budget_fund_pkg.g_cost_rebaseline_flag = 'Y'   and
     p_return_status = 'F'                             and
     l_txn_exists_bc_pkt_flag = 'Y') then

     If g_debug_mode = 'Y' then
        log_message(p_msg_token1=>l_program_name||':Fail pa_bc_packets as GL Failed - F170 update');
     End If;

    -- Autonomous procedure called for update ...these are the records that
    -- has already passed PA FC but now needs to be failed ... as some records have failed with F169 above

       FAIL_BC_PKT_DURING_BASELINE(P_budget_version_id => l_current_budget_version_id,
                                   P_period_name       => g_tab_period_name,
                                   P_budget_ccid       => g_tab_budget_ccid,
                                   P_allow_flag        => g_tab_allow_flag,
                                   P_result_code       => 'F170');

                                   -- Note: All the pl/sql tables being passed are nulls

 End If;

  If g_debug_mode = 'Y' then
     log_message(p_msg_token1=>l_program_name||':Executing gl failure check end .., status:'||p_return_status);
  End If;

 End If; --If P_return_status = 'S' then
 -- -------------------------- END STEP 3 -------------------------------------+

 -- -------------------------- STEP 4 -----------------------------------------+
 -- If (Top-Down and re-baseline and "reserve"/"check funds"/"year end")
 -- execute "budget account validation" (for the latest budget
 -- version only). i.e. account change not allowed on a budget line
 -- that has txn.s against it. If any found, fail gl_bc_packets with F35
 --
 -- IF ACCOUNT CHANGE ALLOWED, then update the account information on
 --  pa_budget_lines
 --  Note: We however have to synch data for all modes and all budget types ..
 -- ---------------------------------------------------------------------------+


 If (--pa_budget_fund_pkg.g_balance_type = 'E' /*Top Down*/ and
     --pa_budget_fund_pkg.g_cost_rebaseline_flag = 'Y'      and
     p_return_status = 'S' ) then  -- I

     If g_debug_mode = 'Y' then
       log_message(p_msg_token1=>l_program_name||':Executing account validation');
     End If;

    -- ##  Get the budget lines where account has changed
    Open c_budget_lines_synch(l_current_budget_version_id);
    loop
    fetch c_budget_lines_synch BULK COLLECT into t_ccid,
                                           t_gl_rowid,
			                   t_bud_ccid,
                                           t_raid,
                                           t_budget_rowid,
                                           t_budget_start_date,
	                                   g_tab_period_name,
                                           g_tab_allow_flag,
                                           g_tab_budget_line_id,
                                           t_txn_currency_code,
                                           t_draft_needs_update,
                                           t_project_id,
                                           t_task_id,
                                           t_rlmi,
                                           t_parent_rlmi
                                           LIMIT l_limit;

      If t_ccid.exists(1) then -- II

           l_count := 0;
           l_count := t_ccid.COUNT;
           l_validation_failed := 'N';
           l_derive_draft_values   := 'N';

           -- ----------------------------------------------------------------------------------+
           -- ##  A. Check if SLA has derived an account diff. than that on the budget line ...
           If g_debug_mode = 'Y' then
              log_message(p_msg_token1=>l_program_name||':Check if SLA derived diff. account');
           End If;
           -- ----------------------------------------------------------------------------------+
         for x in t_ccid.FIRST..t_ccid.LAST loop

             If t_ccid(x) <> t_bud_ccid(x) then
                t_draft_needs_update(x) := 'Y';
                l_derive_draft_values   := 'Y';
                l_acct_changed          := 'Y';
             End If;

         end loop;
           If g_debug_mode = 'Y' then
              log_message(p_msg_token1=>l_program_name||':l_derive_draft_values['||l_derive_draft_values||']');
           End If;

           -- ----------------------------------------------------------------------------------+
           -- ##  B. Get prev. version budget ccid
           -- ----------------------------------------------------------------------------------+
           If (pa_budget_fund_pkg.g_balance_type = 'E' and
               pa_budget_fund_pkg.g_cost_rebaseline_flag = 'Y' and
               (l_txn_exists_bc_pkt_flag ='Y' OR l_txn_exists_bc_cmt_flag = 'Y'))
           then -- B

              If g_debug_mode = 'Y' then
                 log_message(p_msg_token1=>l_program_name||':Derive Top task id');
              End If;

              If l_budget_entry_level_code = 'P' then
                 for x in t_Task_id.FIRST..t_task_id.LAST loop
                     t_top_task_id(x) := 0;
                 end loop;
              Else
                  for x in t_Task_id.FIRST..t_task_id.LAST loop
                      select top_task_id into t_top_task_id(x)
                      from pa_tasks
                      where task_id = t_task_id(x);
                  end loop;
              End If;

              If g_debug_mode = 'Y' then
                 log_message(p_msg_token1=>l_program_name||':Derive prev. ver ccid');
              End If;

              for x in t_ccid.FIRST..t_ccid.LAST loop

                  Begin
                    select pbl.code_combination_id into
                           t_prev_ver_ccid(x)
                    from   pa_budget_lines pbl,
                           pa_resource_assignments pra
                    where  pbl.start_date             = t_budget_start_date(x)
                    and    pbl.txn_currency_code      = t_txn_currency_code(x)
                    and    pbl.budget_version_id      = pa_budget_fund_pkg.g_cost_prev_bvid
                    and    pbl.budget_version_id      = pra.budget_version_id
                    and    pbl.resource_assignment_id = pra.resource_assignment_id
                    and    pra.project_id             = t_project_id(x)
                    and    (pra.task_id               = t_task_id(x) OR
                            pra.task_id               = t_top_task_id(x))
                    and    (pra.resource_list_member_id= t_rlmi(x) OR
                            pra.resource_list_member_id= t_parent_rlmi(x));
                  Exception
                    when no_data_found then
                          t_prev_ver_ccid(x) := -1;
                  End;

                 -- note: if ct. changes budget from lowest to top task or
                 -- moves resource group to group then there can be an issue ..
                 -- product management said that should not happen .. so not handling that for
                 -- the time being ..
                 -- Issue: lets say task11 had A1 and task 12 had A2 but now ct. moves budget to task1 (top level)
                 --        then which budget account to consider ..it gets kinds complicated then ..
              end loop;

           End If; --B

              If g_debug_mode = 'Y' then
                 log_message(p_msg_token1=>l_program_name||':After derive prev. ver ccid');
              End If;

           -- ----------------------------------------------------------------------------------+
           -- ##  C. Call API for validation (if account change allowed)
           -- ----------------------------------------------------------------------------------+
           If (pa_budget_fund_pkg.g_balance_type = 'E'            and
               pa_budget_fund_pkg.g_cost_rebaseline_flag = 'Y'    and
               (l_txn_exists_bc_pkt_flag ='Y' OR l_txn_exists_bc_cmt_flag = 'Y')
               )
          then -- API If
              -- ----------------------------------------------------------------------------------------------------+
              If g_debug_mode = 'Y' then
                 log_message(p_msg_token1=>l_program_name||': Account change allowed-Inside main if condition');
                 for x in t_project_id.FIRST..t_project_id.LAST loop
                 log_message(p_msg_token1=>l_program_name||':t_top_task_id['||t_task_id(x)
                                           ||'] t_task_id['||t_task_id(x)
                                           ||'] t_parent_rlmi['||t_parent_rlmi(x)
                                           ||'] t_rlmi['||t_rlmi(x)
                                           ||'] t_budget_start_date['||t_budget_start_date(x)
                                           ||'] g_tab_period_name['||g_tab_period_name(x)
                                           ||'] t_prev_ver_ccid['||t_prev_ver_ccid(x)
                                           ||'] t_ccid['||t_ccid(x)||']');
               end loop;
              End If;
              -- ----------------------------------------------------------------------------------------------------+

             If pa_budget_fund_pkg.g_processing_mode <> 'CHECK_FUNDS' then
               l_bvid_for_acct_changed_API := l_current_budget_version_id;
             Else
               l_bvid_for_acct_changed_API := pa_budget_fund_pkg.g_cost_prev_bvid;
             End if;

              If g_debug_mode = 'Y' then
                 log_message(p_msg_token1=>l_program_name||': For acct. change API, bvid being used:'
                              ||l_bvid_for_acct_changed_API);
              End If;

              for x in t_project_id.FIRST..t_project_id.LAST loop

                If (t_prev_ver_ccid(x) <> t_ccid(x))
                then
                  If g_debug_mode = 'Y' then
                     log_message(p_msg_token1=>l_program_name||': Calling pa_funds_control_utils.is_Account_change_allowed2');
                  End If;

                   IF pa_funds_control_utils.is_Account_change_allowed2
                      (p_budget_version_id       => l_bvid_for_acct_changed_API,
                       p_project_id              => t_project_id(x),
                       p_top_task_id             => t_top_task_id(x),
                       p_task_id                 => t_task_id(x),
                       p_parent_resource_id      => t_parent_rlmi(x),
                       p_resource_list_member_id => t_rlmi(x),
                       p_start_date              => t_budget_start_date(x),
                       p_period_name             => g_tab_period_name(x),
                       p_entry_level_code        => l_budget_entry_level_code,
                       p_mode                    => 'FORM') = 'N'
                     THEN -- III

                         g_tab_allow_flag(x) := 'N'; -- Account Change not allowed ...
                         l_validation_failed := 'Y';
                         l_derive_draft_values   := 'Y';

                         If g_debug_mode = 'Y' then
                           log_message(p_msg_token1=>l_program_name||':Acct change failed for raid['||t_raid(x)||']period['||
                                                     g_tab_period_name(x)||']');
                         End If;

                     END IF; -- III

               End If; -- Current to prev. budget ccid check ..

              end loop;

           End If; --API If

           -- ----------------------------------------------------------------------------------+
           If g_debug_mode = 'Y' then

              log_message(p_msg_token1=>l_program_name||':l_validation_failed ['||l_validation_failed||']');

              For x in t_bud_ccid.FIRST..t_bud_ccid.LAST loop
                 log_message(p_msg_token1=>l_program_name||':source_distribution_id_num_1/g_tab_budget_line_id ['
                 ||g_tab_budget_line_id(x)||']g_tab_allow_flag['||g_tab_allow_flag(x)
                 ||']g_tab_period_name['||g_tab_period_name(x)||']t_raid'||t_raid(x)||']');
               end loop;
           End If;
           -- ----------------------------------------------------------------------------------+

           -- ----------------------------------------------------------------------------------+
           -- C2. Get the draft information for update ...
           -- ----------------------------------------------------------------------------------+
               If g_debug_mode = 'Y' then
                  log_message(p_msg_token1=>l_program_name||': l_derive_draft_values['||l_derive_draft_values||']');
               End If;

               If l_derive_draft_values = 'Y' then

                  If g_debug_mode = 'Y' then
                     log_message(p_msg_token1=>l_program_name||': Derive draft rowid and draft ccid');
                  End If;

                  If pa_budget_fund_pkg.g_processing_mode <> 'CHECK_FUNDS' then -- CF
                   for x in t_project_id.FIRST..t_project_id.LAST
                   loop

                          -- If draft needs update then we need to get the draft rowid for updating
                          -- the account change and draft ccid for the below API ..
                          -- And the below begin..end block is reqd. as the baseline budget can have zero $ lines ..

                          Begin
                              select pbl.rowid,pbl.code_combination_id into
                                     t_draft_budget_rowid(x),t_draft_ccid(x)
                              from   pa_budget_lines pbl,
                                     pa_resource_assignments pra
                              where  pbl.start_date             = t_budget_start_date(x)
                              and    pbl.txn_currency_code      = t_txn_currency_code(x)
                              and    pbl.budget_version_id      = pra.budget_version_id
                              and    pbl.resource_assignment_id = pra.resource_assignment_id
                              and    pra.budget_version_id      = l_draft_budget_version_id
                              and    pra.project_id             = t_project_id(x)
                              and    pra.task_id                = t_task_id(x)
                              and    pra.resource_list_member_id= t_rlmi(x);
                          Exception
                              when no_data_found then
                                 If g_debug_mode = 'Y' then
                                  log_message(p_msg_token1=>l_program_name||'Derive drafr budget ccid:No Data Found');
                                  log_message(p_msg_token1=>l_program_name||': t_budget_start_date(x):'||t_budget_start_date(x)
                                              ||' t_txn_currency_code(x):'||t_txn_currency_code(x)
                                              ||' t_project_id(x):'||t_project_id(x)
                                              ||' t_task_id(x):'||t_task_id(x)
                                              ||' t_rlmi(x): '||t_rlmi(x));
                                 End if;

                                 t_draft_budget_rowid(x) := null;
                                 t_draft_ccid(x) := -1;
                          End;

                          If t_draft_needs_update(x) = 'N' then
                             t_draft_budget_rowid(x) := null;
                          End If; --If t_draft_needs_update(x) = 'Y' then

                          -- Above is reqd. as only those rowid with <> 'NO DATA FOUND' is used for updating account change ..

                   end loop;
                 End If; -- CF ..
               End if; --If l_derive_draft_values = 'Y' then

               If g_debug_mode = 'Y' then
                  log_message(p_msg_token1=>l_program_name||': After derive draft rowid and draft ccid');
               End If;


           -- ----------------------------------------------------------------------------------+
           -- ##  D. If any budget acccount failed validation then ..
           -- ----------------------------------------------------------------------------------+

           If l_validation_failed = 'Y' then

              -- ----------------------------------------------------------------------------------+
              -- ##  Fail gl_bc_packets ..
              If g_debug_mode = 'Y' then
                log_message(p_msg_token1=>l_program_name||': Acct. val. failed - Fail gl_bc_packets');
              End If;
              -- ----------------------------------------------------------------------------------+

              Forall x in t_bud_ccid.FIRST..t_bud_ccid.LAST
                  Update gl_bc_packets glbc
                  set    glbc.result_code         = 'F35'
                  where  glbc.packet_id           = p_packet_id
                  and    glbc.source_distribution_id_num_1  = g_tab_budget_line_id(x)
                  and    g_tab_allow_flag(x)      = 'N';

              If g_debug_mode = 'Y' then
                 log_message(p_msg_token1=>l_program_name||SQL%ROWCOUNT||' GL line updated');
              End If;

              If (pa_budget_fund_pkg.g_balance_type = 'E'            and
                  pa_budget_fund_pkg.g_processing_mode = 'BASELINE'  and
                  pa_budget_fund_pkg.g_cost_rebaseline_flag = 'Y'    and
                  l_txn_exists_bc_pkt_flag = 'Y')   then

                -- ----------------------------------------------------------------------------------+
                -- ##  Fail pa_bc_packets:
                If g_debug_mode = 'Y' then
                   log_message(p_msg_token1=>l_program_name||': Acct. val. failed [F169] - Fail pa_bc_packets');
                End If;
                -- ----------------------------------------------------------------------------------+

                -- Autonomous procedure called for update ...these are the records that
                -- has already passed PA FC but now needs to be failed ...

                FAIL_BC_PKT_DURING_BASELINE(P_budget_version_id => l_current_budget_version_id,
                                            P_period_name       => g_tab_period_name,
                                            P_budget_ccid       => t_bud_ccid,
                                            P_allow_flag        => g_tab_allow_flag,
                                            P_result_code       => 'F169');

              End If;

              -- ----------------------------------------------------------------------------------+
              -- ##  Fail draft account summary ..
              If g_debug_mode = 'Y' then
                 log_message(p_msg_token1=>l_program_name||': Acct. change. val. failed(F169) - Update draft account summary');
              End If;
              --  Update Draft version (account summary table) to failure ..
              --    Note: in case of 'Year End' the working budget will be updated ..
              -- ----------------------------------------------------------------------------------+
              -- Following if condition being used as for = 'CF' ..t_draft_ccid is not calculated ..

              If pa_budget_fund_pkg.g_processing_mode <> 'CHECK_FUNDS' then

              -- -------------------------------------------------------------------------------------------------+
                If g_debug_mode = 'Y' then
                   log_message(p_msg_token1=>l_program_name||': Upd acct. summ - <> CF:l_draft_budget_version_id['
                                              ||l_draft_budget_version_id||']');
                   for x in g_tab_period_name.FIRST..g_tab_period_name.LAST loop
                    log_message(p_msg_token1=>l_program_name||': g_tab_period_name['||g_tab_period_name(x)
                                              ||'] t_draft_ccid ['||t_draft_ccid(x)
                                              ||']');
                   end loop;
                End If;
              -- -------------------------------------------------------------------------------------------------+

              -- Autonomous call to update pa_budget_acct_lines for the draft version ...
                 UPDATE_FAILURE_IN_ACCT_SUMMARY(P_budget_version_id => l_draft_budget_version_id,
                                                P_period_name       => g_tab_period_name,
                                                P_budget_ccid       => t_draft_ccid,
                                                P_allow_flag        => g_tab_allow_flag,
                                                P_result_code       => 'F169');

              Else

              -- -------------------------------------------------------------------------------------------------+
               If g_debug_mode = 'Y' then
                   log_message(p_msg_token1=>l_program_name||': Upd acct. summ,mode = CF:l_draft_budget_version_id['
                                              ||l_draft_budget_version_id||']');
                   for x in g_tab_period_name.FIRST..g_tab_period_name.LAST loop
                    log_message(p_msg_token1=>l_program_name||': g_tab_period_name['||g_tab_period_name(x)
                                              ||'] t_bud_ccid ['||t_bud_ccid(x)
                                              ||']');
                   end loop;

                End If;
              -- -------------------------------------------------------------------------------------------------+

              -- Autonomous call to update pa_budget_acct_lines for the draft version ...
                 UPDATE_FAILURE_IN_ACCT_SUMMARY(P_budget_version_id => l_draft_budget_version_id,
                                                P_period_name       => g_tab_period_name,
                                                P_budget_ccid       => t_bud_ccid,
                                                P_allow_flag        => g_tab_allow_flag,
                                                P_result_code       => 'F169');

              End If;
              -- ----------------------------------------------------------------------------------+
              -- ##  Set failure status ..
              -- ----------------------------------------------------------------------------------+
                 p_return_status := 'F';


           End If; -- If l_validation_failed = 'Y' then (Acct. validation failed)


           -- --------------------------------------------------------------------------------+
           -- ##  E. Update those budget lines where account info. can change ....
              If g_debug_mode = 'Y' then
                 log_message(p_msg_token1=>l_program_name||': Update changed account info on budget lines'
                             ||'l_acct_changed['||l_acct_changed||'] l_validation_failed['
                             ||l_validation_failed||']'  );
              End If;
           -- --------------------------------------------------------------------------------+
              If l_acct_changed = 'Y' then

                 If (l_validation_failed = 'N'  or pa_budget_fund_pkg.g_processing_mode = 'CHECK_FUNDS') then
                    -- update budget lines only if there is no failure
                    -- reason: because if there is any failure, baseline/yearend/checkfunds fails ..
                    --         and a rollback is issued for the 1st 2 ..
                    -- However for CF, we will update the account change for the records
                    -- that did not fail FC .. till the point the loop exits ..

              If g_debug_mode = 'Y' then
                 log_message(p_msg_token1=>l_program_name||': Updating budget line on current version'  );
              End If;

                    forall x in t_ccid.FIRST..t_ccid.LAST
                    Update pa_budget_lines pbl
                    set    pbl.code_combination_id = t_ccid(x)
                    where  pbl.rowid               = t_budget_rowid(x)
                    and    t_bud_ccid(x)           <> t_ccid(x)
                    and    g_tab_allow_flag(x)     = 'Y';

                    If (sql%rowcount > 0 and  pa_budget_fund_pkg.g_processing_mode = 'CHECK_FUNDS') then
                        l_draft_acct_changed_flag := 'Y';
                    End If;

                    If g_debug_mode = 'Y' then
                       log_message(p_msg_token1=>l_program_name||':'||sql%rowcount
                                   ||'  budget lines updated for current version'  );
                    End If;

                End If; -- If l_validation_failed = 'N' then

                If (pa_budget_fund_pkg.g_processing_mode <> 'CHECK_FUNDS') then

                   -- We also need to update the draft version account information ..atleast for the ones
                   -- where account change is allowed .. AUTONOMOUS Update ..

                  If g_debug_mode = 'Y' then
                     log_message(p_msg_token1=>l_program_name||': Update new account on draft summary'
                                 ||': l_record_updated_flag:'||l_record_updated_flag);

                     for x in t_draft_budget_rowid.FIRST..t_draft_budget_rowid.LAST loop
                      log_message(p_msg_token1=>l_program_name||':t_bud_ccid:'||t_bud_ccid(x)
                                  ||':t_ccid:'||t_ccid(x)
                                  ||':g_tab_allow_flag:'||g_tab_allow_flag(x)
                                  ||':t_draft_budget_rowid:'||t_draft_budget_rowid(x));
                      end loop;
                  End If;

                   UPD_NEW_ACCT_ON_DRAFT_BUDGET(p_budget_line_rowid => t_draft_budget_rowid,
                                                p_budget_ccid       => t_bud_ccid,
                                                p_new_ccid          => t_ccid,
                                                p_change_allowed    => g_tab_allow_flag,
                                                p_record_updated    => l_record_updated_flag);

                   If l_record_updated_flag = 'Y' then
                      l_draft_acct_changed_flag := 'Y';
                   End if;

                End If;

                -- Initialized variable to 'N' for the next run ..
                l_acct_changed := 'N';

           End If; -- If l_acct_changed = 'Y' then

           -- ---------------------------------------------------------------------------------------+
              If g_debug_mode = 'Y' then
                 log_message(p_msg_token1=>l_program_name||SQL%ROWCOUNT||' budget line records updated');
              End If;
           -- ---------------------------------------------------------------------------------------+

      Else
       EXIT; -- Exit Loop
      End If; -- If t_ccid(1).exists -- II

      -- ----------------------------------------------------------------------------------+
      -- ## F. Initalize variables
              If g_debug_mode = 'Y' then
                 log_message(p_msg_token1=>l_program_name||': initalize variables');
              End If;
      -- ----------------------------------------------------------------------------------+
       t_ccid.DELETE;
       t_bud_ccid.DELETE;
       t_gl_rowid.DELETE;
       t_budget_rowid.DELETE;
       t_raid.DELETE;
       t_budget_start_date.DELETE;
       g_tab_period_name.DELETE;
       g_tab_allow_flag.DELETE;
       g_tab_budget_line_id.DELETE;
       t_txn_currency_code.DELETE;
       t_project_id.DELETE;
       t_task_id.DELETE;
       t_rlmi.DELETE;
       t_parent_rlmi.DELETE;

       -- Following tables are conditioanlly build ..
       if t_top_task_id.exists(1)        then t_top_task_id.DELETE;        end if;
       if t_prev_ver_ccid.exists(1)      then t_prev_ver_ccid.DELETE;      end if;
       if t_draft_needs_update.exists(1) then t_draft_needs_update.DELETE; end if;
       if t_draft_ccid.exists(1)         then t_draft_ccid.DELETE;         end if;
       if t_draft_budget_rowid.exists(1) then t_draft_budget_rowid.DELETE; end if;
    End Loop;

    close c_budget_lines_synch;

    If g_debug_mode = 'Y' then
       log_message(p_msg_token1=>l_program_name||':After account validation, return status:'||p_return_status);
    End If;

 End If; -- I , Top-Down Check, re-baseline

 -- --------------------------------------------------------------------------+
 If (pa_budget_fund_pkg.g_balance_type = 'E'           and
     pa_budget_fund_pkg.g_processing_mode = 'BASELINE' and
     p_return_status = 'F'                             and
     l_txn_exists_bc_pkt_flag = 'Y') then

     If g_debug_mode = 'Y' then
        log_message(p_msg_token1=>l_program_name||':Fail pa_bc_packets as account info. changed - F170 update');
     End If;

    -- Autonomous procedure called for update ...these are the records that
    -- has already passed PA FC but now needs to be failed ... as some records have failed with F169 above

       FAIL_BC_PKT_DURING_BASELINE(P_budget_version_id => l_current_budget_version_id,
                                   P_period_name       => g_tab_period_name,
                                   P_budget_ccid       => g_tab_budget_ccid,
                                   P_allow_flag        => g_tab_allow_flag,
                                   P_result_code       => 'F170');

                                   -- Note: All the pl/sql tables being passed are nulls

 End If;

 -- ---------------------------------------------------------------------------+
 -- If the status is 'Failed' but there was an account changed that was updated
 -- on budget lines, then we will need to rebuild the draft version summary and
 -- that too in AUTONOMUS mode ...
 -- What we're talking here is the draft budget data that gets updated above
 -- during baseline/yearend and CF ..
 -- ---------------------------------------------------------------------------+

    If (l_draft_acct_changed_flag = 'Y' and
        p_return_status     = 'F' )
    then
       If g_debug_mode = 'Y' then
          log_message(p_msg_token1=>l_program_name||': Failure case - Rebuild draft acct. sumamry');
       End If;

      BUILD_ACCOUNT_SUMMARY_AUTO(x_budget_version_id => l_draft_budget_version_id,
                                 x_balance_type =>pa_budget_fund_pkg.g_balance_type,
                                 x_budget_amount_code=> pa_budget_fund_pkg.g_budget_amount_code,
                                 x_prev_budget_version_id=>pa_budget_fund_pkg.g_cost_prev_bvid,
                                 x_mode=>'FAIL');
    End If;
 -- ------------------------- END STEP 4 --------------------------------------+

 If p_return_status = 'S' then -- II
    -- ------------------------------------------------------------------------+
    --  5.0: Build account summary for the current version ..
    -- ------------------------------------------------------------------------+
    If g_debug_mode = 'Y' then
       log_message(p_msg_token1=>l_program_name||':Processing Mode:'||pa_budget_fund_pkg.g_processing_mode);
       log_message(p_msg_token1=>l_program_name||':Build account summary for the current version');
    End If;

       -- ACCOUNT SUMMARY SHOULD ALWAYS BE GENERATED .. CASE WHERE USER MANUALLY UPDATED
       -- ACCOUNT, IN THIS CASE, ACCT. SUMMARY IS DIFF. THAN ACTUAL SUMMARY

         BUILD_ACCOUNT_SUMMARY(p_budget_version_id => l_current_budget_version_id,
                             p_balance_type =>pa_budget_fund_pkg.g_balance_type,
                             p_budget_amount_code=> pa_budget_fund_pkg.g_budget_amount_code,
                             p_prev_budget_version_id=>pa_budget_fund_pkg.g_cost_prev_bvid);

    If g_debug_mode = 'Y' then
       log_message(p_msg_token1=>l_program_name||': Done building account summary for the current version');
    End If;
    -- ------------------------- END STEP 5 -----------------------------------+
    --  6.0: Build account summary for the draf version .. <> CF mode ..
    --       'Cause in CF mode, we build for the draft version :)
    -- ------------------------------------------------------------------------+
       If (pa_budget_fund_pkg.g_processing_mode <> 'CHECK_FUNDS' and l_draft_acct_changed_flag = 'Y')
       then

          If g_debug_mode = 'Y' then
             log_message(p_msg_token1=>l_program_name||':Build account summary for the draft version');
          End If;

          BUILD_ACCOUNT_SUMMARY_AUTO(x_budget_version_id => l_draft_budget_version_id,
                                     x_balance_type =>pa_budget_fund_pkg.g_balance_type,
                                     x_budget_amount_code=> pa_budget_fund_pkg.g_budget_amount_code,
                                     x_prev_budget_version_id=>pa_budget_fund_pkg.g_cost_prev_bvid,
                                     x_mode=>'PASS');

          If g_debug_mode = 'Y' then
             log_message(p_msg_token1=>l_program_name||': Done building account summary for the draft version');
          End If;

       End If; -- Step 6.0 main If ..

    -- ------------------------- END STEP 6 -----------------------------------+
    -- 7.0: Top Down (but not "Year-End") and re-baseline, carry out
    --      "Account level" FC
    -- ------------------------------------------------------------------------+

    If (pa_budget_fund_pkg.g_balance_type         = 'E' and
        pa_budget_fund_pkg.g_cost_rebaseline_flag = 'Y' and
        pa_budget_fund_pkg.g_processing_mode      = 'BASELINE') then
        --l_txn_exists_bc_pkt_flag = 'Y') then

           -- Account level FC .. ONLY for BASELINE mode

         If g_debug_mode = 'Y' then
            l_program_name := 'Do_Budget_baseline_tieback';
            log_message(p_msg_token1=>l_program_name||':Account Level Funds Check');
         End If;


        Open c_acct_lines(l_current_budget_version_id);
        loop
        fetch c_acct_lines BULK COLLECT into g_tab_period_name,
                                             g_tab_budget_ccid,
                                             g_tab_allow_flag
                                             LIMIT l_limit;
        l_count := 0;
        l_count := g_tab_budget_ccid.COUNT;


        If l_count > 0 then

           -- ----------------------------------------------------------------------------------+
           If g_debug_mode = 'Y' then
            log_message(p_msg_token1=>l_program_name||':Account Level Funds Check failed - Fail gl_bc_packets');

             For x in g_tab_budget_ccid.FIRST..g_tab_budget_ccid.LAST loop
                log_message(p_msg_token1=>l_program_name||':g_tab_budget_ccid'||g_tab_budget_ccid(x)
                            ||'g_tab_period_name'||  g_tab_period_name(x));
             end loop;
           End If;
           -- ----------------------------------------------------------------------------------+

          -- A. Fail gl_bc_packets:
           Forall x in g_tab_budget_ccid.FIRST..g_tab_budget_ccid.LAST
               Update gl_bc_packets glbc
               set    glbc.result_code         = 'F35'
               where  glbc.packet_id           = p_packet_id
               and    glbc.code_combination_id = g_tab_budget_ccid(x)
               and    glbc.period_name         = g_tab_period_name(x);

              If g_debug_mode = 'Y' then
                 log_message(p_msg_token1=>l_program_name||SQL%ROWCOUNT||' GL line updated');
              End If;

         -- B. Fail pa_bc_packets:

            -- Autonomous procedure called for update ...these are the records that
            -- has already passed PA FC but now needs to be failed ...

                FAIL_BC_PKT_DURING_BASELINE(P_budget_version_id => l_current_budget_version_id,
                                            P_period_name       => g_tab_period_name,
                                            P_budget_ccid       => g_tab_budget_ccid,
                                            P_allow_flag        => g_tab_allow_flag,
                                            P_result_code       => 'F113');

         If g_debug_mode = 'Y' then
            log_message(p_msg_token1=>l_program_name||':Account Level Funds Check failed - Fail draft account summary');
         End If;

         -- C. Update Draft version (account summary table) to failure ..

            -- Autonomous call to update pa_budget_acct_lines for the draft version ...

                 UPDATE_FAILURE_IN_ACCT_SUMMARY(P_budget_version_id => l_draft_budget_version_id,
                                                P_period_name       => g_tab_period_name,
                                                P_budget_ccid       => g_tab_budget_ccid,
                                                P_allow_flag        => g_tab_allow_flag,
                                                P_result_code       => 'F113');

            -- D. Set Failure status

               p_return_status := 'F';


          -- E. Initalize variables..

          g_tab_budget_ccid.DELETE;
          g_tab_period_name.DELETE;
          g_tab_allow_flag.DELETE;

        End If; --If l_count > 0 then


      If l_count < l_limit then
         exit;
      End If;

     end loop; -- Main cursor c_acct_lines;

     Close c_acct_lines;


       If (p_return_status = 'F') then

           If g_debug_mode = 'Y' then
              log_message(p_msg_token1=>l_program_name||':Account level failure ...');
           End If;

           -- Autonomous procedure called for update ...these are the records that
           -- has already passed PA FC but now needs to be failed ... as some records have failed with F113 above

           FAIL_BC_PKT_DURING_BASELINE(P_budget_version_id => l_current_budget_version_id,
                                   P_period_name       => g_tab_period_name,
                                   P_budget_ccid       => g_tab_budget_ccid,
                                   P_allow_flag        => g_tab_allow_flag,
                                   P_result_code       => 'F170');

                                   -- Note: All the pl/sql tables being passed are nulls

       End If;

  End If; -- account level FC complete ...

    -- ------------------------- END STEP 7 -----------------------------------+

 End If; -- II  If p_return_status = 'S' then (step 5..7)

  -- -------------------------  STEP 8 -----------------------------------+
  -- Step 8.0: Update Pass status/result code on pa_budget_acct_lines
  -- Step 8.1: Update Pass status/result code on current version (CF/Baseline/Yearend)
/* ==============================================================================================+
   -- STEP NOT REQUIRED AS acct. summary initialized/build with 'P101' and 'A' ...

 If ((pa_budget_fund_pkg.g_processing_mode = 'CHECK_FUNDS') OR
     (pa_budget_fund_pkg.g_processing_mode <> 'CHECK_FUNDS' and p_return_status = 'S')
    ) then

    If g_debug_mode = 'Y' then
       log_message(p_msg_token1=>'End:'||l_program_name||'Update Pass status/result code on pa_budget_acct_lines - Current');
    End If;

    Update pa_budget_acct_lines
    set    funds_check_status_code = 'A',
           funds_check_result_code = 'P101'
    where  budget_version_id       = l_current_budget_version_id
    and    nvl(funds_check_status_code,'A') <> 'R';

     If g_debug_mode = 'Y' then
        log_message(p_msg_token1=>l_program_name||'Current Acct Summary-P101 update:'||SQL%ROWCOUNT);
     End If;

 End If;

  -- Step 8.2: Update Pass status/result code on draft version for Baseline/year End mode

 If (pa_budget_fund_pkg.g_processing_mode <> 'CHECK_FUNDS' and p_return_status = 'S')
     then

    If g_debug_mode = 'Y' then
       log_message(p_msg_token1=>'End:'||l_program_name||'Update Pass status/result code on pa_budget_acct_lines - Draft');
    End If;

    Update pa_budget_acct_lines
    set    funds_check_status_code = 'A',
           funds_check_result_code = 'P101'
    where  budget_version_id       = l_draft_budget_version_id;

     If g_debug_mode = 'Y' then
        log_message(p_msg_token1=>l_program_name||'Draft Acct Summary-P101 update:'||SQL%ROWCOUNT);
     End If;

 End If;
 ============================================================================================== */

 -- ------------------------- END STEP 8 -----------------------------------+

 -- -------------------------  STEP 9 -----------------------------------+
 -- Step 9.0: Update project_acct_result_code/result_code on pa_bc_packets

  If (pa_budget_fund_pkg.g_processing_mode = 'BASELINE'     and
      p_return_status = 'S'                                 and
      l_txn_exists_bc_pkt_flag = 'Y') then

      If g_debug_mode = 'Y' then
         log_message(p_msg_token1=>l_program_name||'Update acct level result code on pa_bc_packets');
      End If;

      UPD_BC_PKT_ACCT_RESULT_CODE(P_budget_version_id => l_current_budget_version_id);

  End if;
 -- ------------------------- END STEP 9 -----------------------------------+

 -- -------------------------- STEP 10 --------------------------------------+
 -- Step 10.0: We need to fail all records in case of Check funds/reserve ..

  If (p_return_status = 'F' and pa_budget_fund_pkg.g_processing_mode = 'CHECK_FUNDS') then
     -- Filtering reserve_baseline as during baseline if there is a failure everything rolls back ..

      g_packet_debit_processed := 'Y';

      If g_packet_credit_processed = 'Y' then
        log_message(p_msg_token1=>l_program_name||': As credit already processed Calling Fail_credit_packet');
         FAIL_CREDIT_PACKET(p_input_packet       => 'DEBIT',
                            p_return_status_code => p_return_status);
      End if;

  End If;
 -- ------------------------- END STEP 10 -----------------------------------+


 If g_debug_mode = 'Y' then
    l_program_name := 'Do_budget_baseline_tieback';
    log_message(p_msg_token1=>'End:'||l_program_name||'return status:'||p_return_status);
 End If;

EXCEPTION
 When others then
   If g_debug_mode = 'Y' then
    l_program_name := 'Do_budget_baseline_tieback';
    log_message(p_msg_token1=>l_program_name||':When Others:'||SQLERRM);
   End If;

   p_return_status := 'F';

END DO_BUDGET_BASELINE_TIEBACK;

-- --------------------------------------------------------------------------------+
-- This procedure will build pa_budget_acct_lines
-- Called from DO_BUDGET_BASELINE_TIEBACK and PA_GL_CBC_CONFIRMATION (for revenue)
-- Parameters:
-- p_budget_version_id    : Current budget version being funds checked
-- p_balance_type         : E (For Top Down) and B (Bottom Up)
-- p_budget_amount_code   : 'C' for cost and 'R' for revenue
-- p_prev_budget_version_id: Budget version being reversed (for re-baseline
--                          and year-end case)
-- --------------------------------------------------------------------------------+
PROCEDURE Build_account_summary(P_budget_version_id     IN NUMBER,
                                P_balance_type          IN VARCHAR2,
                                P_budget_amount_code    IN VARCHAR2,
                                P_prev_budget_version_id IN NUMBER)
IS

 t_period_name TypeVarChar;
 t_start_date  TypeDate;
 t_end_date    TypeDate;
 t_ccid        TypeNum;
 t_amt         TypeNum;

 l_date        Date;
 l_login       Number;
 l_request     Number;
 l_count       Number;

  Cursor c_acct_lines is
  select pbl.period_name,
         pbl.start_date,
         pbl.end_date,
         pbl.code_combination_id,
         sum(decode(nvl(p_balance_type,'X'),
                'E', decode(NVL(pbl.Burdened_Cost,0),
                            0,nvl(pbl.raw_cost,0),
                            pbl.burdened_cost ) ,
                'B',decode(p_budget_amount_code,
                           'R',nvl(pbl.revenue,0) ,
                           'C', decode(NVL(pbl.Burdened_Cost,0),
                                       0,nvl(pbl.raw_cost,0),
                                       pbl.burdened_cost ),
                            0 ),
                 0 )) total_amount
    from  pa_budget_lines pbl
    where budget_version_id = p_budget_version_id
    group by pbl.period_name,
             pbl.start_date,
             pbl.end_date,
             pbl.code_combination_id;

BEGIN
 l_program_name := 'Build_account_summary:';
 If g_debug_mode = 'Y' then
    log_message(p_msg_token1=>l_program_name||'Start');
 End If;

 l_date    := sysdate;
 l_login   := fnd_global.login_id;
 l_request := fnd_global.conc_request_id;
 l_limit   := 500;
 -- ------------------------------------------------------------------------+
 -- 1.0: Creating PA_Budget_Acct_Lines record for the current budget version
 -- ------------------------------------------------------------------------+

  -- To make sure that there is no budget acct. line .. acct. gen. seems to be creating summary ..
  Delete from PA_Budget_Acct_Lines
  where budget_version_id = P_budget_version_id;

  If g_debug_mode = 'Y' then
    log_message(p_msg_token1=>l_program_name||'Deleted '||SQL%ROWCOUNT||' PA_Budget_Acct_Lines records');
  End If;

 If g_debug_mode = 'Y' then
    log_message(p_msg_token1=>l_program_name||':Creating records');
 End If;

   Open c_acct_lines;
   loop
   fetch c_acct_lines
         BULK COLLECT into t_period_name,
                           t_start_date,
                           t_end_date,
                           t_ccid,
                           t_amt
                           LIMIT l_limit;
      l_count := t_ccid.COUNT;

      If g_debug_mode = 'Y' then
         log_message(p_msg_token1=>l_program_name||'Fetched '||l_count||' budget records');
      End If;

      If l_count > 0 then

         If g_debug_mode = 'Y' then
            for i in 1..l_count loop
               log_message(p_msg_token1=>l_program_name||'P_budget_version_id,start_date,t_ccid'
                             ||P_budget_version_id||';'||t_start_date(i)||';'||t_ccid(i));
            end loop;
         End If;

         forall i in 1..l_count
           INSERT INTO PA_Budget_Acct_Lines (
           Budget_Acct_Line_ID,
           Budget_version_ID,
           GL_Period_Name,
           Start_Date,
           End_Date,
           Code_Combination_ID,
           Prev_Ver_Budget_Amount,
           Prev_Ver_Available_Amount,
           Curr_Ver_Budget_Amount,
           Curr_Ver_Available_Amount,
           Accounted_Amount,
           Last_Update_Date,
           Last_Updated_By,
           Creation_Date,
           Created_By,
           Last_Update_Login,
           Request_ID,
           funds_check_status_code,
           funds_check_result_code)
           VALUES(PA_Budget_Acct_Lines_S.NEXTVAL,  -- Budget acct line id
                  P_budget_version_id,             -- Budget version id
                  t_period_name(i),                -- Period name
                  t_start_date(i),                 -- Start date
                  t_end_date(i),                   -- End date
                  t_ccid(i),                       -- CCID
                  0,                               -- Prev. version bud.  amt
                  0,                               -- Prev. version avail.amt
                  t_amt(i),                        -- Curr. version bud.  amt
                  0,                               -- Curr. version avail.amt
                  0,                               -- Accounted amount
                  l_date,                          -- Last update date
                  l_login,                         -- Last update by
                  l_date,                          -- Created date
                  l_login,                         -- Created by
                  l_login,                         -- Last update login
                  l_request,                       -- Request
                  'A',                             -- funds_check_status_code
                  'P101');                         -- funds_check_result_code


        t_period_name.DELETE;
        t_start_date.DELETE;
        t_end_date.DELETE;
        t_ccid.DELETE;
        t_amt.DELETE;

     End If;

     If l_count < l_limit then
        exit;
     end if;

   end loop;
   close c_acct_lines;

   If g_debug_mode = 'Y' then
      log_message(p_msg_token1=>l_program_name||' After PA_Budget_Acct_Lines Insert DML');
   End If;
 -- -------------------------------------------------------------------+
 -- 2.0: Update previous amounts (budget and available)
 -- -------------------------------------------------------------------+
 If p_prev_budget_version_id is not null then  -- re-baseline -- I
   If g_debug_mode = 'Y' then
      log_message(p_msg_token1=>l_program_name||':Updating previous amounts');
   End If;

   Update PA_Budget_Acct_Lines pbl
   set    (pbl.Prev_Ver_Budget_Amount,pbl.Prev_Ver_Available_Amount) =
           (select pbl1.Curr_Ver_Budget_Amount,
                   pbl1.Curr_Ver_Available_Amount
            from   PA_Budget_Acct_Lines pbl1
            where  pbl1.budget_version_id   = P_prev_budget_version_id
            and    pbl1.code_combination_id = pbl.code_combination_id
            and    pbl1.start_date          = pbl.start_date)
   where   pbl.budget_version_id = p_budget_version_id
   and exists
         (select 1
          from   PA_Budget_Acct_Lines pbl2
          where  pbl2.budget_version_id   = P_prev_budget_version_id
          and    pbl2.code_combination_id = pbl.code_combination_id
          and    pbl2.start_date          = pbl.start_date);
   -- Bottom "exists clause" reqd, else if there is no record then the
   -- previous budget amounts may get updated to null and its a not null field
 End If;  -- I

 -- -------------------------------------------------------------------+
 -- 3.0: Update available and accounted amounts for the current version
 -- -------------------------------------------------------------------+
   If g_debug_mode = 'Y' then
      log_message(p_msg_token1=>l_program_name||':Updating avail. bal and accounted amt.');
   End If;

   -- e.g. Prev.Budget = 100, Current Budget = 50, Prev. available = 90
   --      That means there were txn. for 10 against prev. budget (100-90)
   --      Current available = 50 - (100-90) = 40
   --      Accounted = 100-50 = 50

   Update PA_Budget_Acct_Lines
   set    Curr_Ver_Available_Amount = Curr_Ver_Budget_Amount -
                                      (Prev_Ver_Budget_Amount - Prev_Ver_Available_Amount),
          Accounted_Amount  = Curr_Ver_Budget_Amount - Prev_Ver_Budget_Amount
          -- Accounted_Amount  = Prev_Ver_Budget_Amount - Curr_Ver_Budget_Amount
   where  budget_version_id = p_budget_version_id;


 -- -------------------------------------------------------------------+
 -- 4.0: Build account lines that are missing with respect to previous
 --      version. e.g.: Budget line deleted, acct/period changed on
 --      the old budget
 -- -------------------------------------------------------------------+
 If p_prev_budget_version_id is not null then  -- re-baseline -- II
  If g_debug_mode = 'Y' then
     log_message(p_msg_token1=>l_program_name||':Creating missing records');
  End If;

  If (pa_budget_fund_pkg.g_processing_mode <> 'CHECK_FUNDS' and
      P_budget_version_id = pa_budget_fund_pkg.g_cost_current_bvid )then

      -- This IF..END IF ..is reqd. as this procedure is called for the draft version
      -- during <> 'CF' mode ..to rebuild the acct. sumamry for the draft version
      -- In this case, the else part should fire ..

   INSERT INTO PA_BUDGET_ACCT_LINES (
          Budget_Acct_Line_ID,
          Budget_Version_ID,
          GL_Period_Name,
          Start_Date,
          End_Date,
          Code_Combination_ID,
          Prev_Ver_Budget_Amount,
          Prev_Ver_Available_Amount,
          Curr_Ver_Budget_Amount,
          Curr_Ver_Available_Amount,
          accounted_amount,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          CREATION_DATE,
          CREATED_BY,
          REQUEST_ID,
          funds_check_status_code,
          funds_check_result_code
         )
         SELECT
  	       PA_BUDGET_ACCT_LINES_S.nextval,
   	       P_Budget_Version_ID, -- current version
	       BL1.GL_Period_Name,
	       BL1.Start_Date,
	       BL1.End_Date,
	       BL1.Code_Combination_ID,
	       BL1.Curr_Ver_Budget_Amount,
	       BL1.Curr_Ver_Available_Amount,
	       0,
  	       0,
               0 - BL1.Curr_Ver_Budget_Amount,
	       l_date,
	       l_login,
	       l_login,
	       l_date,
	       l_login,
               l_request,
               'A',
               'P101'
         FROM  PA_BUDGET_ACCT_LINES BL1
         WHERE BL1.Budget_Version_ID = P_prev_budget_version_id
	 AND NOT EXISTS
		  ( SELECT 'x'
		    FROM   PA_BUDGET_ACCT_LINES BL2
		    WHERE  BL2.Budget_Version_ID   = P_budget_version_id
		    AND    BL2.Code_Combination_ID = BL1.Code_Combination_ID
		    AND    BL2.Start_Date          = BL1.Start_Date ) ;

   -- In the above select, cannot use code combination filter
   -- scenario: CCID for JAN-05 was 101 but now it changed to 102 ..
   -- in this case, we can create record for 101 (as FC can have issue)
   -- If reqd. we can create 101  for the draft version by using a decode

   -- 8/22: Code combination filter is fine .. as accounts cannot change on budget lines with txn.
   -- And also, the missing lines are created with current amount = 0

   Else

   INSERT INTO PA_BUDGET_ACCT_LINES (
          Budget_Acct_Line_ID,
          Budget_Version_ID,
          GL_Period_Name,
          Start_Date,
          End_Date,
          Code_Combination_ID,
          Prev_Ver_Budget_Amount,
          Prev_Ver_Available_Amount,
          Curr_Ver_Budget_Amount,
          Curr_Ver_Available_Amount,
          accounted_amount,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          CREATION_DATE,
          CREATED_BY,
          REQUEST_ID,
          funds_check_status_code,
          funds_check_result_code
         )
         SELECT
  	       PA_BUDGET_ACCT_LINES_S.nextval,
   	       P_Budget_Version_ID, -- current version
	       BL1.GL_Period_Name,
	       BL1.Start_Date,
	       BL1.End_Date,
	       BL1.Code_Combination_ID,
	       BL1.Curr_Ver_Budget_Amount,
	       BL1.Curr_Ver_Available_Amount,
	       0,
  	       0,
               0 - BL1.Curr_Ver_Budget_Amount,
	       l_date,
	       l_login,
	       l_login,
	       l_date,
	       l_login,
               l_request,
               'A',
               'P101'
         FROM  PA_BUDGET_ACCT_LINES BL1
         WHERE BL1.Budget_Version_ID = P_prev_budget_version_id
         AND   (BL1.Curr_Ver_Budget_Amount <> 0   OR
                BL1.Prev_Ver_Budget_Amount <> 0)
         -- this is to filter the zero $ lines ...
	 AND NOT EXISTS
		  ( SELECT 'x'
		    FROM   PA_BUDGET_ACCT_LINES BL2
		    WHERE  BL2.Budget_Version_ID   = P_budget_version_id
		    AND    BL2.Code_Combination_ID = BL1.Code_Combination_ID
		    AND    BL2.Start_Date          = BL1.Start_Date ) ;
     End If;


 End If; -- re-baseline check -- II

 If g_debug_mode = 'Y' then
    log_message(p_msg_token1=>'End:'||l_program_name);
 End If;

Exception
 When Others then
    If g_debug_mode = 'Y' then
       log_message(p_msg_token1=>'End:'||l_program_name||SQLERRM);
    End If;
    RAISE;

END Build_account_summary;

-- --------------------------------------------------------------------------------+
-- This program is called to build the draft summary from Step 4 in do_budget_baseline
-- It calls build_account_summary ..
-- --------------------------------------------------------------------------------+
PROCEDURE Build_account_summary_auto(X_budget_version_id     IN NUMBER,
                                     X_balance_type          IN VARCHAR2,
                                     X_budget_amount_code    IN VARCHAR2,
                                     X_prev_budget_version_id IN NUMBER,
                                     X_mode                   IN VARCHAR2)
IS
 tt_gl_period_name        pa_plsql_datatypes.char50TabTyp;
 tt_code_combination_id   pa_plsql_datatypes.IdTabTyp;
 tt_result_code           pa_plsql_datatypes.char50TabTyp;
PRAGMA AUTONOMOUS_TRANSACTION;
Begin
    If g_debug_mode = 'Y' then
       log_message(p_msg_token1=>'Build_account_summary_auto:Start:X_mode:'||X_mode);
    End If;

   If X_mode = 'FAIL' then
      Begin
        Select gl_period_name,
               code_combination_id,
               funds_check_result_code
       BULK COLLECT
       into tt_gl_period_name,
            tt_code_combination_id,
            tt_result_code
       from pa_budget_acct_lines
      where budget_version_id = X_budget_version_id
      and   funds_check_result_code like 'F%';
     Exception
      When no_data_found then
           null;
     End;
   End If; --If X_mode = 'FAIL' then


    BUILD_ACCOUNT_SUMMARY(p_budget_version_id      => X_budget_version_id,
                          p_balance_type           => X_balance_type,
                          p_budget_amount_code     => X_budget_amount_code,
                          p_prev_budget_version_id => X_prev_budget_version_id);


   If X_mode = 'FAIL' then
    If tt_code_combination_id.exists(1) then
       forall x in tt_result_code.FIRST..tt_result_code.LAST
       update pa_budget_acct_lines
       set    funds_check_result_code = tt_result_code(x)
       where  budget_version_id       = X_budget_version_id
       and    code_combination_id     = tt_code_combination_id(x)
       and    gl_period_name          = tt_gl_period_name(x);


       tt_gl_period_name.DELETE;
       tt_code_combination_id.DELETE;
       tt_result_code.DELETE;

    End If;
   End If; --If X_mode = 'FAIL' then

COMMIT;

    If g_debug_mode = 'Y' then
       log_message(p_msg_token1=>'Build_account_summary_auto:End');
    End If;

End Build_account_summary_auto;

-- --------------------------------------------------------------------------------+
-- Following procedure resets funds_check_status_code and result code on
-- pa_budget_acct_lines for the draft version ..
-- 8/22: Initalizing to pass status ..
-- --------------------------------------------------------------------------------+
PROCEDURE Reset_status_code_on_summary(p_budget_version_id IN Number)
IS
 PRAGMA AUTONOMOUS_TRANSACTION;
Begin

   Update pa_budget_acct_lines
   set    funds_check_status_code = 'A', --null,
          funds_check_result_code = 'P101' --null
   where  budget_version_id       = p_budget_version_id;
   --and    (funds_check_status_code is not null or funds_check_result_code is not null);

   If g_debug_mode = 'Y' then
      log_message(p_msg_token1=>'Reset_status_code_on_summary:Status nullified on:'||SQL%ROWCOUNT || ' records');
   End If;

COMMIT;

End Reset_status_code_on_summary;

-- --------------------------------------------------------------------------------+
-- This autonomous procedure is called to update the newly derived account info.
-- back onto the draft budget lines during baseline/yearend ..
-- --------------------------------------------------------------------------------+
PROCEDURE Upd_new_acct_on_draft_budget(p_budget_line_rowid       IN g_tab_rowid%TYPE,
                                       p_budget_ccid             IN g_tab_budget_ccid%TYPE,
                                       p_new_ccid                IN g_tab_budget_ccid%TYPE,
                                       p_change_allowed          IN g_tab_allow_flag%TYPE,
                                       p_record_updated          OUT NOCOPY Varchar2)

IS
 l_count number;
 PRAGMA AUTONOMOUS_TRANSACTION;
Begin
   forall x in p_new_ccid.FIRST..p_new_ccid.LAST
   Update pa_budget_lines pbl
   set    pbl.code_combination_id = p_new_ccid(x)
   where  pbl.rowid               = p_budget_line_rowid(x)
   and    p_budget_ccid(x)       <> p_new_ccid(x)
   and    p_change_allowed(x)     = 'Y'
   and    p_budget_line_rowid(x) is not null;

   -- p_change_allowed is used to restrict the budget lines where acct. valdiation failed, F169 issue
   -- p_budget_line_rowid is not null, is used to restrict update, this is for the zero $ budget
   -- lines that will not be existant in the draft budget

   l_count := SQL%ROWCOUNT;

   If g_debug_mode = 'Y' then
      log_message(p_msg_token1=>'Upd_new_acct_on_draft_budget:Acct. updated on:'||l_count || ' records');
   End If;

   If l_count > 0 then
      p_record_updated := 'Y';
   Else
     p_record_updated := 'N';
   End if;

COMMIT;

End Upd_new_acct_on_draft_budget;

-- --------------------------------------------------------------------------------+
-- This procedure will fail data in the other packet .. i.e. the credit packet ..
-- --------------------------------------------------------------------------------+
PROCEDURE Fail_credit_packet(p_input_packet IN Varchar2,
                             p_return_status_code OUT NOCOPY varchar2)
IS
 -- Cursor used to select records to fail all records ....
 -- As data split between packet, records were not being failed in the credit packet ..
 Cursor c_gl_records is
        select glbc.rowid,glbc.ae_header_id,glbc.ledger_id
        from   gl_bc_packets glbc
        where  glbc.event_id in
                          (select event_id from psa_bc_xla_events_gt);

 l_baseline_failed Varchar2(1);
 t_ae_header_id    TypeNum;
 t_ledger_id       TypeNum;
 t_glrowid         TypeVarChar;

BEGIN
      l_program_name := 'Fail_credit_packet';

      If p_input_packet = 'DEBIT' then

         l_baseline_failed := 'Y';

      Elsif p_input_packet = 'CREDIT' then

            Begin
                  select 'Y'
                  into    l_baseline_failed
                  from dual
                  where   exists
                          (select packet_id
                           from   gl_bc_packets glbc
                           where  glbc.event_id in
                          (select event_id from psa_bc_xla_events_gt)
                           and  glbc.result_code like 'F%');
            Exception
                when no_data_found then
                     l_baseline_failed := 'N';
            End;

      End If;

      If l_baseline_failed = 'N' then
         p_return_status_code := 'S';
         RETURN;
      Else
         p_return_status_code := 'F';
      End If;

      If g_debug_mode = 'Y' then
         log_message(p_msg_token1=>l_program_name||'Fail all records for the session');
      End If;

      Open c_gl_records;
      loop
      Fetch c_gl_records BULK COLLECT into t_glrowid,
                                           t_ae_header_id,
                                           t_ledger_id
                                           LIMIT l_limit;


        If g_debug_mode = 'Y' then
           log_message(p_msg_token1=>l_program_name||'No. of records in pl/sql table['||t_glrowid.count||']');
        End If;

        If t_glrowid.exists(1) then

             -- -------------------------------------------------------------------------- +
             -- Fail gl_bc_packet records ...
             -- -------------------------------------------------------------------------- +
             forall i in t_glrowid.FIRST..t_glrowid.LAST
             Update gl_bc_packets glbc
             set    glbc.result_code   = decode(substr(glbc.result_code,1,1),'F',glbc.result_code,'F35'),
                    glbc.status_code   = decode(pa_budget_fund_pkg.g_processing_mode,
                                        'CHECK_FUNDS','F','R')
             where  rowid = t_glrowid(i);

             If g_debug_mode = 'Y' then
               log_message(p_msg_token1=>l_program_name||'GL packets, records updated['||sql%rowcount||']');
             End If;

             -- -------------------------------------------------------------------------- +
             -- Fail xla_ae_headers_gt records ...
             -- -------------------------------------------------------------------------- +
             forall i in t_ae_header_id.FIRST..t_ae_header_id.LAST
             UPDATE xla_ae_headers_gt
             SET funds_status_code = decode(pa_budget_fund_pkg.g_processing_mode,
                                            'CHECK_FUNDS','F','R')
             WHERE ae_header_id    = t_ae_header_id(i)
             AND   ledger_id       = t_ledger_id(i);

             If g_debug_mode = 'Y' then
               log_message(p_msg_token1=>l_program_name||'xla_ae_headers_gt, records updated['||sql%rowcount||']');
             End If;
             -- -------------------------------------------------------------------------- +
             -- Fail gl_bc_packet records ...
             -- -------------------------------------------------------------------------- +
             forall i in t_ae_header_id.FIRST..t_ae_header_id.LAST
             UPDATE xla_validation_lines_gt
             SET    funds_status_code = 'F77'
             WHERE  ae_header_id    = t_ae_header_id(i);

             If g_debug_mode = 'Y' then
               log_message(p_msg_token1=>l_program_name||'xla_validation_lines_gt, records updated['||sql%rowcount||']');
             End If;

             -- -------------------------------------------------------------------------- +
             -- Initalize records ...
             -- -------------------------------------------------------------------------- +

             t_glrowid.delete;
             t_ae_header_id.delete;
             t_ledger_id.delete;

             If t_glrowid.COUNT < l_limit then
                exit;
             End if;

        Else -- if t_gl_rowid.exists(1)
          exit;
        End if;

      end loop;


End Fail_credit_packet;


-- ------------------------------------ R12 End  ------------------------------------------------+

END PA_FUNDS_CONTROL_PKG;

/
