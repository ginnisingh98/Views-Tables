--------------------------------------------------------
--  DDL for Package Body PA_BC_COSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BC_COSTING" AS
/* $Header: PABCCSTB.pls 120.5 2008/05/15 12:43:55 vchilla ship $ */

/*
 * Private Procedures.
 */
PROCEDURE process_rejected_exp_items( x_return_status  OUT NOCOPY NUMBER
                                     ,x_error_code     OUT NOCOPY VARCHAR2
                                     ,x_error_stage    OUT NOCOPY VARCHAR2
                                    );

PROCEDURE populate_pa_bc_packets( x_return_status  OUT NOCOPY NUMBER
                                 ,x_error_code     OUT NOCOPY VARCHAR2
                                 ,x_error_stage    OUT NOCOPY VARCHAR2
                                ) ;

PROCEDURE populate_pa_bc_packets_cwk( x_return_status  OUT NOCOPY NUMBER
                                     ,x_error_code     OUT NOCOPY VARCHAR2
                                     ,x_error_stage    OUT NOCOPY VARCHAR2
                                    ) ;


  /*
   * Package level variables.
   */
  g_created_by                 pa_cost_distribution_lines.created_by%TYPE := FND_GLOBAL.USER_ID;
  g_last_updated_by            pa_expenditure_items.last_updated_by%TYPE := FND_GLOBAL.USER_ID;
  g_last_update_login          pa_expenditure_items.last_update_login%TYPE := FND_GLOBAL.LOGIN_ID;
  g_request_id                 pa_cost_distribution_lines.request_id%TYPE ;
  g_program_application_id     pa_cost_distribution_lines.program_application_id%TYPE := FND_GLOBAL.PROG_APPL_ID;
  g_program_id                 pa_cost_distribution_lines.program_id%TYPE := FND_GLOBAL.CONC_PROGRAM_ID;
  g_packet_id                  pa_bc_packets.packet_id%TYPE;
  g_sob_id                     pa_implementations.set_of_books_id%TYPE;

  /*
   * Package level Pl/Sql Tables.
   */
  l_project_id_tab                          PA_PLSQL_DATATYPES.IdTabTyp;
  l_task_id_tab                             PA_PLSQL_DATATYPES.IdTabTyp;
  l_budget_version_id_tab                   PA_PLSQL_DATATYPES.IdTabTyp;
  l_expenditure_item_id_tab                 PA_PLSQL_DATATYPES.IdTabTyp;
  l_expenditure_type_tab                    PA_PLSQL_DATATYPES.Char30TabTyp;
  l_expenditure_item_date_tab               PA_PLSQL_DATATYPES.DateTabTyp;
  l_system_linkage_function_tab             PA_PLSQL_DATATYPES.Char30TabTyp;
  l_pa_date_tab                             PA_PLSQL_DATATYPES.DateTabTyp;
  l_gl_date_tab                             PA_PLSQL_DATATYPES.DateTabTyp;
  l_funds_process_mode_tab                  PA_PLSQL_DATATYPES.Char1TabTyp;
  l_bc_burden_cost_flag_tab                 PA_PLSQL_DATATYPES.Char1TabTyp;
  l_exp_organization_id_tab                 PA_PLSQL_DATATYPES.IdTabTyp;
  l_document_header_id_tab                  PA_PLSQL_DATATYPES.IdTabTyp;
  l_document_line_id_tab                    PA_PLSQL_DATATYPES.IdTabTyp;
  l_line_num_tab                            PA_PLSQL_DATATYPES.NumTabTyp;
  l_line_type_tab                           PA_PLSQL_DATATYPES.Char1TabTyp;
  l_line_num_reversed_tab                   PA_PLSQL_DATATYPES.NumTabTyp;
  l_acct_raw_cost_tab                       PA_PLSQL_DATATYPES.NumTabTyp;
  l_denom_raw_cost_tab                      PA_PLSQL_DATATYPES.NumTabTyp;
  l_acct_burdened_cost_tab                  PA_PLSQL_DATATYPES.NumTabTyp;
  l_denom_burdened_cost_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
  l_document_distribution_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;
  l_bc_packet_id_tab                        PA_PLSQL_DATATYPES.IdTabTyp;
  l_parent_bc_packet_id_tab                 PA_PLSQL_DATATYPES.IdTabTyp;
  l_org_id_tab                              PA_PLSQL_DATATYPES.IdTabTyp;
  l_burden_sum_rej_code_tab                 PA_PLSQL_DATATYPES.Char30TabTyp;
  l_burden_sum_source_run_id_tab            PA_PLSQL_DATATYPES.Char30TabTyp;
  l_ind_compiled_set_id_tab                 PA_PLSQL_DATATYPES.IdTabTyp;
  l_dr_code_combination_id_tab              PA_PLSQL_DATATYPES.IdTabTyp;
  l_gl_period_name_tab                      PA_PLSQL_DATATYPES.Char15TabTyp;
  l_burden_amt_disp_method_tab              PA_PLSQL_DATATYPES.Char1TabTyp;
  l_burden_cost_flag_tab                    PA_PLSQL_DATATYPES.Char1TabTyp;
  l_pa_bc_packet_id_tab                     PA_PLSQL_DATATYPES.IdTabTyp;
  l_rejn_code_tab                           PA_PLSQL_DATATYPES.Char30TabTyp;
  l_pkt_reference1_Tab                      PA_PLSQL_DATATYPES.Char80TabTyp;
  l_pkt_reference2_Tab                      PA_PLSQL_DATATYPES.Char80TabTyp;
  l_pkt_reference3_Tab                      PA_PLSQL_DATATYPES.Char80TabTyp;


P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE print_msg (l_debug_flag  varchar2 default 'N'
                        ,p_msg  varchar2) IS

BEGIN
        If l_debug_flag = 'Y' Then
                --dbms_output.put_line('LOG:'||p_msg);
                PA_DEBUG.write_file('LOG',p_msg);
                --r_debug.r_msg('LOG:'||p_msg);
        End If;
END print_msg;

/*
 * This procedure can be the same for both ER Distribution and VI Adjustment processes.
 * The following procedure,
 * 1. Sends Credit/Debit raw lines created during this run into pa_bc_packets.
 *   -- Credit lines in case of reversing CDLs
 *   -- Debit lines in case of new CDLs.
 * 2. Inserts Credit burden lines for reversing CDLs.
 *   -- FChecked burden amount is,
 *   ---- (cdl.burdened_amount - cdl.amount) for burden_amt_display_method = 'S'.
 *   ---- burden amount derived for burden_amt_display_method = 'D'.
 * 3. Calls FC API.
 * 4. Deletes CDLs that were created in this run and failed Funds Check .
 */


PROCEDURE costing_fc_proc ( p_calling_module IN  VARCHAR2
                           ,p_request_id     IN  NUMBER
                           ,x_return_status  OUT NOCOPY NUMBER
                           ,x_error_code     OUT NOCOPY VARCHAR2
                           ,x_error_stage    OUT NOCOPY NUMBER
                          )
IS


  /*
   * Processing related variables.
   */
  l_calling_module             VARCHAR2(20) ;
  l_records_affected           NUMBER := 0;
  l_return_status              VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
  l_error_code                 VARCHAR2(1000);
  l_error_stage                VARCHAR2(1000);
  l_debug_mode                 VARCHAR2(1);
  l_stage                      NUMBER ;
  l_bunch_size                 PLS_INTEGER := 100;
  l_this_fetch                 PLS_INTEGER := 0;
  l_totally_fetched            PLS_INTEGER := 0;
  l_totally_processed          PLS_INTEGER := 0;
  l_ei_to_process_from         pa_expenditure_items_all.expenditure_item_id%TYPE := 0;


  /*
   * Cursor Declaration.
   */

  /*=========================================================+
   | Burdening Enhancements                                  |
   | o Funds Check both R and I lines.                       |
   | o Transfer Status Code P for R lines and G for I lines. |
   | Contengent Worker Enhancement                           |
   | o Funds Check both R and I lines.                       |
   +=========================================================*/
  /*=============================+
   | Parent_bc_packet_id.        |
   | o -7777                     |
   | ---- 'BTC'                  |
   | o -1                        |
   | ---- Fresh CDLs.            |
   | o NULL                      |
   | ---- 'I' lines.             |
   | ---- All others             |
   +=============================*/
  CURSOR pa_bc_packet_cur
  IS
  SELECT cdl.expenditure_item_id
        ,cdl.line_num
        ,cdl.line_type
        ,cdl.line_num_reversed
     --   ,cdl.acct_raw_cost
        ,DECODE(ei.system_linkage_function ,'BTC' ,cdl.acct_burdened_cost
                       ,DECODE(cdl.line_type, 'R', cdl.acct_raw_cost, cdl.acct_burdened_cost ))
     --   ,cdl.denom_raw_cost
        ,DECODE(ei.system_linkage_function ,'BTC' ,cdl.denom_burdened_cost
                       ,DECODE(cdl.line_type, 'R', cdl.denom_raw_cost, cdl.denom_burdened_cost ))
        ,cdl.acct_burdened_cost
        ,cdl.denom_burdened_cost
        ,cdl.project_id
        ,cdl.pa_date
        ,cdl.gl_date
        ,cdl.burden_sum_rejection_code
        ,cdl.burden_sum_source_run_id
        ,cdl.ind_compiled_set_id
        ,cdl.dr_code_combination_id
        ,glp.period_name
        ,ei.expenditure_item_date
        ,ei.expenditure_type
        ,ei.task_id
        ,NVL(ei.override_to_organization_id, exp.incurred_by_organization_id)
        ,NVL(ei.org_id, -99)
        ,ei.system_linkage_function
        ,NVL(pt.burden_amt_display_method, 'S')
        ,NVL(pt.burden_cost_flag, 'N')
        ,bv.budget_version_id
        ,DECODE(ei.system_linkage_function, 'BTC', -7777, DECODE(cdl.line_type, 'I', NULL, DECODE(cdl.line_num_reversed, NULL, -1, NULL)))
        -- ,cdl.system_reference3   po_line_id -- R12 change
        ,ei.po_line_id po_line_id              -- R12 change
	,'EXP'                   pkt_reference1
        ,cdl.expenditure_item_id pkt_reference2
        ,cdl.line_num            pkt_reference3
    FROM pa_expenditure_items_all ei
        ,pa_cost_distribution_lines_all cdl
        ,pa_project_types_all     pt
        ,pa_projects_all          p
        ,pa_expenditures          exp
        ,pa_budget_versions       bv
        ,pa_budgetary_control_options pbct
        ,gl_period_statuses       glp
   WHERE ei.cost_distributed_flag = 'S'
     AND ei.request_id = g_request_id
     AND ei.cost_dist_rejection_code IS NULL
     AND (ei.system_linkage_function IN ('VI') OR
          (ei.system_linkage_function = 'BTC' AND ei.adjustment_type = 'BURDEN_RESUMMARIZE'))
     AND ei.expenditure_id = exp.expenditure_id
     AND ei.expenditure_item_id > l_ei_to_process_from
/*
 * With I lines, this check is no longer valid.
 * transfer_status_code check is not needed.
 *   AND cdl.transfer_status_code = DECODE(cdl.line_type, 'R', 'P', 'G')
 */
     AND cdl.request_id = g_request_id
     AND cdl.line_type in ('R', 'I')
     AND cdl.expenditure_item_id = ei.expenditure_item_id
     AND NVL(cdl.reversed_flag, 'N') <> 'Y'
     AND cdl.project_id = p.project_id
     AND p.project_type = pt.project_type
     --R12 AND NVL(pt.org_Id, -99) = NVL(p.org_Id, -99)
     AND pt.org_Id = p.org_Id
     AND glp.application_id = 101
     AND glp.set_of_books_id = g_sob_id
     /* AND TRUNC(glp.END_DATE) = TRUNC(cdl.gl_date) Commented for 2843753, 2961161*/
     /* Added for 2843753,2961161 */
     AND  TRUNC(cdl.gl_date) between TRUNC(glp.START_DATE)  and TRUNC(glp.END_DATE)
     AND pbct.project_id = bv.project_id
     AND pbct.BDGT_CNTRL_FLAG = 'Y'
     AND pbct.BUDGET_TYPE_CODE = bv.budget_type_code
     AND (pbct.EXTERNAL_BUDGET_CODE = 'GL'
          OR
          pbct.EXTERNAL_BUDGET_CODE is NULL)
     AND bv.project_id = cdl.project_id
     AND bv.current_flag = 'Y'
     AND bv.budget_status_code = 'B'
     --FP M changes
     And adjustment_period_flag = 'N'
  ORDER BY cdl.expenditure_item_id
          ,cdl.line_num
    ;


BEGIN
  pa_debug.init_err_stack('pa_bc_costing.costing_fc_proc');

  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
  l_debug_mode := NVL(l_debug_mode, 'Y');

  pa_debug.set_process('PLSQL','LOG',l_debug_mode);

  l_stage := 100;
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':From costing_fc_proc';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
  END IF;

  /*
   * Copy incoming parameters into Local variables.
   */
  l_calling_module := p_calling_module ;
  g_request_id     := p_request_id ;

  pa_debug.g_err_stage := 'Request Id is [' || to_char(g_request_id) || ']' ;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
  END IF;

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':ORACLE error occurred while selecting pa_implementations';
  /*
   * Get the sob_id.
   */
  SELECT set_of_books_id
    INTO g_sob_id
    FROM pa_implementations;

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':After selecting from pa_implementations. Sob_id is [' || TO_CHAR(g_sob_id) || ']' ;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
  END IF;

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':ORACLE error occurred Opening pa_bc_packet_cur.';

  /*
   * Select Expenditure_item_ids to process.
   *
   * We should get rid of this sql - because the columns selected here
   * can be received from the pro*C process as arrays.
   */
    l_stage := 200;
    OPEN pa_bc_packet_cur;
    /*
     * Resetting fetch-related variables.
     */
    l_this_fetch        := 0;
    l_totally_fetched   := 0;

    /*
     * Loop until all EIs are processed.
     */
    LOOP

    PA_DEBUG.g_err_stage := TO_CHAR(l_stage) || ':Fetching a Set of CDLs to Process.';
    IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_file('costing_fc_proc: ' || PA_DEBUG.g_err_stage);
    END IF;

      l_stage := 300;
      FETCH pa_bc_packet_cur
       BULK COLLECT
         INTO l_expenditure_item_id_tab
             ,l_line_num_tab
             ,l_line_type_tab
             ,l_line_num_reversed_tab
             ,l_acct_raw_cost_tab
             ,l_denom_raw_cost_tab
             ,l_acct_burdened_cost_tab
             ,l_denom_burdened_cost_tab
             ,l_project_id_tab
             ,l_pa_date_tab
             ,l_gl_date_tab
             ,l_burden_sum_rej_code_tab
             ,l_burden_sum_source_run_id_tab
             ,l_ind_compiled_set_id_tab
             ,l_dr_code_combination_id_tab
             ,l_gl_period_name_tab
             ,l_expenditure_item_date_tab
             ,l_expenditure_type_tab
             ,l_task_id_tab
             ,l_exp_organization_id_tab
             ,l_org_id_tab
             ,l_system_linkage_function_tab
             ,l_burden_amt_disp_method_tab
             ,l_burden_cost_flag_tab
             ,l_budget_version_id_tab
             ,l_parent_bc_packet_id_tab
             ,l_document_line_id_tab
	     ,l_pkt_reference1_Tab
	     ,l_pkt_reference2_Tab
	     ,l_pkt_reference3_Tab
       LIMIT l_bunch_size;

       /*==========================================+
        | Once fetched, reset l_ei_to_process_from |
        +==========================================*/
        l_ei_to_process_from := 0;

      l_this_fetch := pa_bc_packet_cur%ROWCOUNT - l_totally_fetched;
      l_totally_fetched := pa_bc_packet_cur%ROWCOUNT;
      l_totally_processed := l_totally_processed + l_this_fetch;

      PA_DEBUG.g_err_stage := TO_CHAR(l_stage) || ':Fetched [' || l_this_fetch || '] CDL(s) to process.';
      IF P_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.write_file('costing_fc_proc: ' || PA_DEBUG.g_err_stage);
      END IF;

      IF (l_this_fetch = 0) THEN
        PA_DEBUG.g_err_stage := TO_CHAR(l_stage) || ':No more CDL(s) to process. Exiting';
        IF P_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.write_file('costing_fc_proc: ' || PA_DEBUG.g_err_stage);
        END IF;
        x_return_status := 0;
        x_error_code := FND_API.G_RET_STS_SUCCESS;
        x_error_stage := l_stage;
        EXIT;
      END IF;
      /*
       * We got to ensure that all cdls of an ei end-up in the same packet.
       * For this, we are ordering the cursor by eiid and line_num.
       * Now we have fetched n number of CDLs.
       * -- If the nth CDL is a reversing one, (line_num_reversed <> NULL)
       *    then there should be a fresh CDL which we are missing. So,
       *    get that and append it to the current pl/sql table. And ensure
       *    that we dont get any cdl of this ei during the next fetch.
       * Assumption#1:- In-case of reversing CDL, Line_num for the fresh CDL
       *                is greater than the line_num of he reversing CDL.
       */
       IF (l_line_num_reversed_tab(l_this_fetch) IS NOT NULL )
       THEN
       /*
        * Get the Fresh line.
        */
       /*=========================================================+
        | Burdening Enhancements                                  |
        | o Funds Check both R and I lines.                       |
        | o Transfer Status Code P for R lines and G for I lines. |
        +=========================================================*/
         PA_DEBUG.g_err_stage := TO_CHAR(l_stage) || ':Fresh line Missing. Selecting Fresh line.';
         IF P_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.write_file('costing_fc_proc: ' || PA_DEBUG.g_err_stage);
         END IF;

         l_stage := 400;
         SELECT cdl.expenditure_item_id
               ,cdl.line_num
               ,cdl.line_type
               ,cdl.line_num_reversed
               --,cdl.acct_raw_cost
               ,DECODE(cdl.line_type, 'R', cdl.acct_raw_cost, cdl.acct_burdened_cost)
              --,cdl.denom_raw_cost
               ,DECODE(cdl.line_type, 'R', cdl.denom_raw_cost, cdl.denom_burdened_cost)
               ,cdl.acct_burdened_cost
               ,cdl.denom_burdened_cost
               ,cdl.project_id
               ,cdl.pa_date
               ,cdl.gl_date
               ,cdl.burden_sum_rejection_code
               ,cdl.burden_sum_source_run_id
               ,cdl.ind_compiled_set_id
               ,cdl.dr_code_combination_id
               ,glp.period_name
               ,l_expenditure_item_date_tab(l_this_fetch)
               ,l_expenditure_type_tab(l_this_fetch)
               ,l_task_id_tab(l_this_fetch)
               ,l_exp_organization_id_tab(l_this_fetch)
               ,l_org_id_tab(l_this_fetch)
               ,NVL(pt.burden_amt_display_method, 'S')
               ,NVL(pt.burden_cost_flag, 'N')
               ,bv.budget_version_id
               ,DECODE(l_system_linkage_function_tab(l_this_fetch), 'BTC', -7777, DECODE(cdl.line_type, 'I', NULL, DECODE(cdl.line_num_reversed, NULL, -1, NULL)))
            -- ,cdl.system_reference3   po_line_id -- R12 change
               ,(select ei.po_line_id
                 from   pa_expenditure_items_all ei
                 where  ei.expenditure_item_id = cdl.expenditure_item_id
                ) po_line_id              -- R12 change
		,'EXP'
		,cdl.expenditure_item_id
		,cdl.line_num
           INTO l_expenditure_item_id_tab(l_this_fetch+1)
               ,l_line_num_tab(l_this_fetch+1)
               ,l_line_type_tab(l_this_fetch+1)
               ,l_line_num_reversed_tab(l_this_fetch+1)
               ,l_acct_raw_cost_tab(l_this_fetch+1)
               ,l_denom_raw_cost_tab(l_this_fetch+1)
               ,l_acct_burdened_cost_tab(l_this_fetch+1)
               ,l_denom_burdened_cost_tab(l_this_fetch+1)
               ,l_project_id_tab(l_this_fetch+1)
               ,l_pa_date_tab(l_this_fetch+1)
               ,l_gl_date_tab(l_this_fetch+1)
               ,l_burden_sum_rej_code_tab(l_this_fetch+1)
               ,l_burden_sum_source_run_id_tab(l_this_fetch+1)
               ,l_ind_compiled_set_id_tab(l_this_fetch+1)
               ,l_dr_code_combination_id_tab(l_this_fetch+1)
               ,l_gl_period_name_tab(l_this_fetch+1)
               ,l_expenditure_item_date_tab(l_this_fetch+1)
               ,l_expenditure_type_tab(l_this_fetch+1)
               ,l_task_id_tab(l_this_fetch+1)
               ,l_exp_organization_id_tab(l_this_fetch+1)
               ,l_org_id_tab(l_this_fetch+1)
               ,l_burden_amt_disp_method_tab(l_this_fetch+1)
               ,l_burden_cost_flag_tab(l_this_fetch+1)
               ,l_budget_version_id_tab(l_this_fetch+1)
               ,l_parent_bc_packet_id_tab(l_this_fetch+1)
               ,l_document_line_id_tab(l_this_fetch+1)
	       ,l_pkt_reference1_tab(l_this_fetch+1)
	       ,l_pkt_reference2_tab(l_this_fetch+1)
	       ,l_pkt_reference3_tab(l_this_fetch+1)
           FROM pa_cost_distribution_lines_all cdl
               ,pa_project_types_all     pt
               ,pa_projects_all          p
               ,pa_budget_versions       bv
               ,pa_budgetary_control_options pbct
               ,gl_period_statuses       glp
          WHERE
/*
 * With I lines, this check is no longer valid.
 * transfer_status_code check is not needed.
 *              cdl.transfer_status_code = decode(cdl.line_type, 'R', 'P', 'G')
 */
                cdl.line_num_reversed IS NULL                               -- ensures fresh line.
            AND cdl.reversed_flag IS NULL                                   -- ensures fresh line.
            AND cdl.request_id = g_request_id
            AND cdl.line_type in ('R', 'I')
            AND cdl.expenditure_item_id = l_expenditure_item_id_tab(l_this_fetch)
            AND p.project_id = cdl.project_id
            AND p.project_type = pt.project_type
            -- R12 AND NVL(pt.org_Id, -99) = NVL(p.org_Id, -99)
            AND pt.org_Id = p.org_Id
            AND glp.application_id = 101
            AND glp.set_of_books_id = g_sob_id
            /* AND TRUNC(glp.END_DATE) = TRUNC(cdl.gl_date) Commented for 2843753, 2961161*/
            /* Added for 2843753,2961161 */
            AND  TRUNC(cdl.gl_date) between TRUNC(glp.START_DATE)  and TRUNC(glp.END_DATE)
            AND pbct.project_id = bv.project_id
            AND pbct.BDGT_CNTRL_FLAG = 'Y'
            AND pbct.BUDGET_TYPE_CODE = bv.budget_type_code
            AND (pbct.EXTERNAL_BUDGET_CODE = 'GL'
                 OR
                 pbct.EXTERNAL_BUDGET_CODE is NULL)
            AND bv.project_id = cdl.project_id
            AND bv.current_flag = 'Y'
            AND bv.budget_status_code = 'B'
            --FP M changes
            And adjustment_period_flag = 'N'
       ;

         l_totally_processed := l_totally_processed + 1;
         l_ei_to_process_from := l_expenditure_item_id_tab(l_this_fetch);

         IF (l_debug_mode = 'Y')
         THEN
                pa_debug.g_err_stage := ' l_ei_to_process_from is [' || to_char(l_ei_to_process_from) || ']';
                pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
         END IF;

         IF (l_debug_mode = 'Y')
         THEN
             pa_debug.g_err_stage := 'Fresh cdl [' || l_expenditure_item_id_tab(l_this_fetch+1) ||
                                   '] line_num [' || l_line_num_tab(l_this_fetch+1) ||
                                   '] line_type [' || l_line_type_tab(l_this_fetch+1) ||
                                   '] line_num_reversed [' || l_line_num_reversed_tab(l_this_fetch+1) ||
                                   '] p_id [' || l_project_id_tab(l_this_fetch+1) ||
                                   '] pa_date [' || l_pa_date_tab(l_this_fetch+1) ||
                                   '] gl_date [' || l_gl_date_tab(l_this_fetch+1) ||
                                   '] acct_rc [' || l_acct_raw_cost_tab(l_this_fetch+1) ||
                                   '] denom_rc [' || l_denom_raw_cost_tab(l_this_fetch+1) ||
                                   '] acct_bc [' || l_acct_burdened_cost_tab(l_this_fetch+1) ||
                                   '] burden_sum_rej_code [' || l_burden_sum_rej_code_tab(l_this_fetch+1) ||
                                   '] bssrid [' || l_burden_sum_source_run_id_tab(l_this_fetch+1) ||
                                   '] comp_set_id [' || l_ind_compiled_set_id_tab(l_this_fetch+1) ||
                                   '] parent [' || l_parent_bc_packet_id_tab(l_this_fetch+1) ||
                                   ']';
             IF P_DEBUG_MODE = 'Y' THEN
                pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
             END IF;
             pa_debug.g_err_stage := 'dr_ccid [' || l_dr_code_combination_id_tab(l_this_fetch+1) ||
                                   '] gl_p_name [' || l_gl_period_name_tab(l_this_fetch+1) ||
                                   '] etype [' || l_expenditure_type_tab(l_this_fetch+1) ||
                                   '] task_id [' || l_task_id_tab(l_this_fetch+1) ||
                                   '] eorg_id [' || l_exp_organization_id_tab(l_this_fetch+1) ||
                                   '] org_id [' || l_org_id_tab(l_this_fetch+1) ||
                                   '] b_dsp_meth [' || l_burden_amt_disp_method_tab(l_this_fetch+1) ||
                                   '] b_version_id [' || l_budget_version_id_tab(l_this_fetch+1) ||
                                   '] burdened [' || l_burden_cost_flag_tab(l_this_fetch+1) ||
                                   '] doc_line_id [' || to_char(l_document_line_id_tab(l_this_fetch+1)) ||
                                   ']';
             IF P_DEBUG_MODE = 'Y' THEN
                pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
             END IF;
         END IF; -- debug mode?


       END IF; -- is the nth cdl a reversing one?

  /*
   * Printing fetched values.
   */
  IF (l_debug_mode = 'Y')
  THEN
    FOR i IN l_expenditure_item_id_tab.FIRST .. l_expenditure_item_id_tab.LAST
    LOOP
      pa_debug.g_err_stage := 'eiid [' || l_expenditure_item_id_tab(i) ||
                            '] sys_link [' || l_system_linkage_function_tab(i) ||
                            '] line_num [' || l_line_num_tab(i) ||
                            '] line_type [' || l_line_type_tab(i) ||
                            '] line_num_reversed [' || l_line_num_reversed_tab(i) ||
                            '] p_id [' || l_project_id_tab(i) ||
                            '] pa_date [' || l_pa_date_tab(i) ||
                            '] gl_date [' || l_gl_date_tab(i) ||
                            '] acct_rc [' || l_acct_raw_cost_tab(i) ||
                            '] denom_rc [' || l_denom_raw_cost_tab(i) ||
                            '] acct_bc [' || l_acct_burdened_cost_tab(i) ||
                            '] burden_sum_rej_code [' || l_burden_sum_rej_code_tab(i) ||
                            '] bssrid [' || l_burden_sum_source_run_id_tab(i) ||
                            '] comp_set_id [' || l_ind_compiled_set_id_tab(i) ||
                            '] dr_ccid [' || l_dr_code_combination_id_tab(i) ||
                            '] gl_p_name [' || l_gl_period_name_tab(i) ||
                            '] etype [' || l_expenditure_type_tab(i) ||
                            '] task_id [' || l_task_id_tab(i) ||
                            '] eorg_id [' || l_exp_organization_id_tab(i) ||
                            '] org_id [' || l_org_id_tab(i) ||
                            '] sys_link [' || l_system_linkage_function_tab(i) ||
                            '] b_dsp_meth [' || l_burden_amt_disp_method_tab(i) ||
                            '] b_version_id [' || l_budget_version_id_tab(i) ||
                            '] parent_pkt_id [' || l_parent_bc_packet_id_tab(i) ||
                            '] doc_line_id [' || to_char(l_document_line_id_tab(i)) ||
                            '] burdened [' || l_burden_cost_flag_tab(i) || ']';
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
      END IF;
  END LOOP;
  END IF; -- debug mode?

      /*
       * Get the Packet_id
       */
        PA_DEBUG.g_err_stage := TO_CHAR(l_stage) || ': Getting the packet_id.';
        IF P_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.write_file('costing_fc_proc: ' || PA_DEBUG.g_err_stage);
        END IF;

      l_stage := 500;
      SELECT gl_bc_packets_s.NEXTVAL
        INTO g_packet_id
        FROM dual;

      pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Packet_id is [' || TO_CHAR(g_packet_id) || ']' ;
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
      END IF;

  /*
   * Call Autonomous Procedure to insert the pl/sql tables into pa_bc_packets.
   */
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Before Calling populate_pa_bc_packets.';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
  END IF;

  l_stage := 600;
  populate_pa_bc_packets( l_return_status
                         ,l_error_code
                         ,l_error_stage
                        );


  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':After calling populate_pa_bc_packets l_return_status = [' ||
                                                l_return_status || '] l_error_stage = [' || l_error_stage ||
                                               '] l_error_code = [' || l_error_code || ']' ;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
  END IF;

  /*
   * Check l_return_status,l_error_code,l_error_stage and take appropriate action.
   */
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    pa_debug.g_err_stage := 'Error occurred while call to populate_pa_bc_packets. x_return_status [' ||
                            l_return_status || ']';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':After Inserting Records into PA_BC_PACKETS.';
  IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
  END IF;

  /*
   * Call FC API here.
   */
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Calling FC API';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
  END IF;

  pa_debug.g_err_stage := 'Error Occurred during call to pa_funds_check.';
  /*
   * Call the FC API.
   */
  l_stage := 700;
  IF( NOT pa_funds_control_pkg.pa_funds_check( l_calling_module    -- p_calling_module
                                              ,'Y'                 -- p_conc_flag
                                              ,g_sob_id            -- p_set_of_book_id
                                              ,g_packet_id         -- p_packet_id
                                              ,'R'                 -- p_mode
                                              ,'Y'                 -- p_partial_flag
                                              ,NULL                -- p_reference1
                                              ,NULL                -- p_reference2
                                              ,NULL                -- p_reference3
                                              ,l_return_status     -- x_return_status
                                              ,l_error_stage       -- x_error_stage
                                              ,l_error_code        -- x_error_msg
                                            ) )
  THEN
    pa_debug.g_err_stage := 'pa_funds_check returned FALSE.';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':After calling FC API l_return_status =[' || l_return_status ||
                                               '] l_error_stage = [' || l_error_stage ||
                                               '] l_error_code = [' || l_error_code || ']' ;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
  END IF;

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':After calling FC API' ;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
  END IF;


  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Calling process_rejected_exp_items' ;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
  END IF;

  l_stage := 800;
  process_rejected_exp_items ( x_return_status   => l_return_status
                              ,x_error_code      => l_error_code
                              ,x_error_stage     => l_error_stage
                             );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Error occurred while call to process_rejected_exp_items. x_return_status [' || l_return_status || ']';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':After calling process_rejected_exp_items l_return_status =[' ||
                                                  l_return_status ||
                                               '] l_error_stage = [' || l_error_stage ||
                                               '] l_error_code = [' || l_error_code || ']' ;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
  END IF;

  /*
   * Calling FC ends here.
   */
      IF (l_this_fetch < l_bunch_size) THEN
        /*
         * Indicates last fetch.
         */
        pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Finished Processing Last Fetch.';
        IF P_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
        END IF;
        EXIT;
      END IF;
      /** deleting plsql tables **/

      pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Deleting Pl/Sql tables......';
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
      END IF;

      l_stage := 900;
      l_expenditure_item_id_tab.DELETE;
      l_line_num_tab.DELETE;
      l_line_type_tab.DELETE;
      l_line_num_reversed_tab.DELETE;
      l_acct_raw_cost_tab.DELETE;
      l_denom_raw_cost_tab.DELETE;
      l_acct_burdened_cost_tab.DELETE;
      l_denom_burdened_cost_tab.DELETE;
      l_project_id_tab.DELETE;
      l_pa_date_tab.DELETE;
      l_gl_date_tab.DELETE;
      l_burden_sum_rej_code_tab.DELETE;
      l_burden_sum_source_run_id_tab.DELETE;
      l_ind_compiled_set_id_tab.DELETE;
      l_dr_code_combination_id_tab.DELETE;
      l_gl_period_name_tab.DELETE;
      l_expenditure_item_date_tab.DELETE;
      l_expenditure_type_tab.DELETE;
      l_task_id_tab.DELETE;
      l_exp_organization_id_tab.DELETE;
      l_org_id_tab.DELETE;
      l_burden_amt_disp_method_tab.DELETE;
      l_burden_cost_flag_tab.DELETE;
      l_budget_version_id_tab.DELETE;
      l_pkt_reference1_Tab.DELETE;
      l_pkt_reference2_Tab.DELETE;
      l_pkt_reference3_Tab.DELETE;

      pa_debug.g_err_stage := TO_CHAR(l_stage) || ':After Deleting Pl/Sql tables......';
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
      END IF;

      /** deleting plsql tables **/
      /*=================================================================+
       | If earlier fetch had a spill-over, close and reopen the cursor. |
       +=================================================================*/

      IF (l_ei_to_process_from > 0)
      THEN
           IF P_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage) || 'closing cursor';
                  pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
           END if;
           CLOSE pa_bc_packet_cur;

           l_this_fetch        := 0;
           l_totally_fetched   := 0;
           IF P_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage) || 'opening cursor - to process from [' || to_char(l_ei_to_process_from) || ']';
                  pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
           END IF;
           OPEN pa_bc_packet_cur;
      END IF;

    END LOOP; -- End of loop to insert total number records.

 pa_debug.g_err_stage := TO_CHAR(l_stage) || ': No. Of CDLs Totally fetched [' || TO_CHAR(l_totally_fetched) || ']' ;
 IF P_DEBUG_MODE = 'Y' THEN
    pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
 END IF;

       IF ( l_calling_module = 'DISTBTC')
       THEN
           pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Calling map_btc_items' ;
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
           END IF;
               pa_bc_costing.map_btc_items ( p_request_id     => g_request_id
                                            ,x_return_status  => l_return_status
                                            ,x_error_code     => l_error_code
                                            ,x_error_stage    => l_error_stage
                                           );

           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
           THEN
              pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Error occurred while call to map_btc_items. x_return_status [' || l_return_status || ']';
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
              END IF;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

           pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                ':After calling map_btc_items l_return_status =[' ||
                                                  l_return_status ||
                                '] l_error_stage = [' || l_error_stage ||
                                '] l_error_code = [' || l_error_code || ']' ;
           IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
           END IF;
       END IF; -- DISTBTC

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Leaving costing_fc_proc' ;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
  END IF;

  x_return_status := 0;
  pa_debug.reset_err_stack;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
    END IF;
    x_return_status := -1;
    x_error_code    := pa_debug.g_err_stage ;
    x_error_stage   := to_char(l_stage) ;
  WHEN OTHERS
    THEN
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('costing_fc_proc: EXCEPTION  ' || pa_debug.g_err_stage);
      END IF;

      pa_debug.g_err_stage := TO_CHAR(SQLCODE) || SQLERRM ;
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('costing_fc_proc: EXCEPTION ' || pa_debug.g_err_stage);
      END IF;

      x_return_status := -1;
      x_error_code    := TO_CHAR(SQLCODE) || SQLERRM ;
      x_error_stage   := l_stage ;
      --RAISE;
END costing_fc_proc;

--------------------------------------------------------------------------------------

/*
 * The following procedure resource-maps the BTC items and stamps the
 * budget_ccid and other FC related columns in CDL.
 */
PROCEDURE map_btc_items ( p_request_id      IN NUMBER
                         ,x_return_status  OUT NOCOPY NUMBER
                         ,x_error_code     OUT NOCOPY VARCHAR2
                         ,x_error_stage    OUT NOCOPY VARCHAR2
                        )
IS
  /*
   * Table to store the rejection code - if mapping fails.
   * Value will be NULL if the CDL was successfully mapped.
   */
  l_expenditure_item_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;
  l_budget_ccid_tab              PA_PLSQL_DATATYPES.IdTabTyp;
  l_cost_dist_rejection_code_tab PA_PLSQL_DATATYPES.Char30TabTyp;
  l_line_num_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
  l_cdl_rowid_tab                PA_PLSQL_DATATYPES.RowidTabTyp;
  l_encum_type_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;
  --r12
  l_budget_line_id_tab              PA_PLSQL_DATATYPES.IdTabTyp;
  l_budget_ver_id_tab              PA_PLSQL_DATATYPES.IdTabTyp;

  /* declare set of plsql tables required for New Resource Map api*/
   l_resmap_exp_item_id          PA_PLSQL_DATATYPES.IdTabTyp;
   l_resmap_request_id           PA_PLSQL_DATATYPES.IdTabTyp;
   l_resmap_project_id           PA_PLSQL_DATATYPES.IdTabTyp;
   l_resmap_line_num             PA_PLSQL_DATATYPES.IdTabTyp;
   l_resmap_cdl_rowid            PA_PLSQL_DATATYPES.RowidTabTyp;
   l_resmap_task_id              PA_PLSQL_DATATYPES.IdTabTyp;
   l_resmap_top_task_id          PA_PLSQL_DATATYPES.IdTabTyp;
   l_resmap_person_id            PA_PLSQL_DATATYPES.IdTabTyp;
   l_resmap_organization_id      PA_PLSQL_DATATYPES.IdTabTyp;
   l_resmap_job_id               PA_PLSQL_DATATYPES.IdTabTyp;
   l_resmap_exp_type             PA_PLSQL_DATATYPES.Char150TabTyp;
   l_resmap_exp_category         PA_PLSQL_DATATYPES.Char150TabTyp;
   l_resmap_sys_link_func        PA_PLSQL_DATATYPES.Char150TabTyp;
   l_resmap_gl_start_date        PA_PLSQL_DATATYPES.DateTabTyp;
   l_resmap_encum_type_id        PA_PLSQL_DATATYPES.IdTabTyp;
   l_resmap_vendor_id            PA_PLSQL_DATATYPES.IdTabTyp;
   l_resmap_budget_version_id    PA_PLSQL_DATATYPES.IdTabTyp;
   l_resmap_resource_list_id     PA_PLSQL_DATATYPES.IdTabTyp;
   l_resmap_entry_level_code     PA_PLSQL_DATATYPES.Char30TabTyp;

   l_bdgt_resource_list_id       PA_PLSQL_DATATYPES.IdTabTyp;

  l_counter                    NUMBER := 0;
  l_debug_mode                 VARCHAR2(1) := 'N';
  l_records_processed          NUMBER := 0;
  g_request_id                 NUMBER := 0;
  l_debug_stage                VARCHAR2(2000);

  l_prev_project_id            pa_cost_distribution_lines.project_id%TYPE;
  l_prev_flag                  VARCHAR2(1);
  l_budget_version_id          pa_bc_packets.budget_version_id%TYPE;
  l_resource_list_id           pa_budget_versions.resource_list_id%TYPE;
  l_entry_level_code           pa_budget_versions.budget_entry_method_code%TYPE;
  l_resource_list_member_id    pa_bc_packets.resource_list_member_id%TYPE;
  l_budget_ccid                pa_cost_distribution_lines.budget_ccid%TYPE;
  l_budget_line_id             pa_cost_distribution_lines.budget_line_id%TYPE;
  l_prev_reslist_id            Number;
  l_fnd_reqd_flag              VARCHAR2(1);

  l_return_status              VARCHAR2(1);
  l_stage                      NUMBER;
  l_error_code                 VARCHAR2(1000);
  l_error_stage                VARCHAR2(1000);
  l_resRecCount                NUMBER := 0;
  l_reslistCount	       NUMBER := 0;


  CURSOR btc_cdl_cur IS
  SELECT btc_cdl.expenditure_item_id               expenditure_item_id
        ,btc_cdl.project_id                        project_id
        ,btc_cdl.line_num                          line_num
        ,btc_cdl.cdl_rowid                         cdl_rowid
        ,btc_cdl.task_id                           task_id
        ,btc_cdl.top_task_id                       top_task_id
        ,btc_cdl.person_id                         person_id
        ,btc_cdl.organization_id                   organization_id
        ,btc_cdl.job_id                            job_id
        ,btc_cdl.expenditure_type                  expenditure_type
        ,btc_cdl.expenditure_category              expenditure_category
        ,btc_cdl.system_linkage_function           system_linkage_function
        ,btc_cdl.gl_start_date                     gl_start_date
        ,btc_cdl.encum_type_id                     encum_type_id
        ,btc_cdl.vendor_id                         vendor_id
	,resmap.system_reference4                  budget_version_id
        ,resmap.resource_list_id                   resource_list_id
        ,resmap.resource_list_member_id            resource_list_member_id
        ,btc_cdl.entry_level_code                  entry_level_code
	,btc_cdl.po_line_id                        po_line_id
        ,btc_cdl.system_reference2                 po_header_id
	,decode(btc_cdl.burden_amt_disp_method,'D','BURDEN','RAW') pkt_line_type
        --FP M changes
        ,btc_cdl.dr_code_combination_id            dr_ccid
   FROM pa_res_map_btc_v                 btc_cdl
	,pa_mappable_txns_tmp             resmap
   WHERE btc_cdl.request_id = g_request_id
   AND  resmap.system_reference3 = btc_cdl.request_id
   AND  resmap.system_reference2 = btc_cdl.line_num
   AND  resmap.system_reference1 = btc_cdl.expenditure_item_id
   ORDER BY btc_cdl.resource_list_id
           ,btc_cdl.project_id
           ,btc_cdl.budget_version_id;

  CURSOR reslist_cur IS
  SELECT distinct btc_rl.resource_list_id
  FROM pa_res_map_btc_v btc_rl
  WHERE btc_rl.request_id = g_request_id;

  CURSOR btc_resList_cur
  IS
  SELECT btc_cdl.expenditure_item_id               expenditure_item_id
        ,btc_cdl.project_id                        project_id
 	,btc_cdl.line_num                          line_num
 	,btc_cdl.cdl_rowid                         cdl_rowid
        ,btc_cdl.task_id                           task_id
        ,btc_cdl.top_task_id                       top_task_id
        ,btc_cdl.person_id                         person_id
        ,btc_cdl.organization_id                   organization_id
        ,btc_cdl.job_id                            job_id
        ,btc_cdl.expenditure_type                  expenditure_type
        ,btc_cdl.expenditure_category              expenditure_category
        ,btc_cdl.system_linkage_function           system_linkage_function
        ,btc_cdl.gl_start_date                     gl_start_date
        ,btc_cdl.encum_type_id                     encum_type_id
        ,btc_cdl.vendor_id                         vendor_id
	/* added for Cwk changes */
	,btc_cdl.budget_version_id                 budget_version_id
	,btc_cdl.resource_list_id                  resource_list_id
	,btc_cdl.entry_level_code                  entry_level_code
	,g_request_id			           request_id
    FROM pa_res_map_btc_v                 btc_cdl
   WHERE btc_cdl.request_id = g_request_id
   ORDER BY NVL(btc_cdl.resource_list_id,0)
	   ,btc_cdl.project_id
	   ,btc_cdl.budget_version_id

;

 BEGIN

  	pa_debug.init_err_stack('pa_bc_costing.map_btc_items');

  	fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
  	l_debug_mode := NVL(l_debug_mode, 'N');

  	pa_debug.set_process('PLSQL','LOG',l_debug_mode);

  	l_stage := 100;
  	l_debug_stage := TO_CHAR(l_stage) || ':From map_btc_items';
        print_msg(l_debug_mode,l_debug_stage);

  	g_request_id := p_request_id;
  	l_debug_stage := TO_CHAR(l_stage) || ':Request_id is [' || TO_CHAR(g_request_id) || ']';
        print_msg(l_debug_mode,l_debug_stage);

  /* Resource Mapping Changes Starts Here */
   	l_stage := 150;
	l_debug_stage := l_stage||':'||'Initialize plsql tables';
	print_msg(l_debug_mode,l_debug_stage);
		--Initialize the plsql tables
		l_resmap_exp_item_id.delete;
   		l_resmap_project_id.delete;
   		l_resmap_line_num.delete;
   		l_resmap_cdl_rowid.delete;
   		l_resmap_task_id.delete;
   		l_resmap_top_task_id.delete;
   		l_resmap_person_id.delete;
   		l_resmap_organization_id.delete;
   		l_resmap_job_id.delete;
   		l_resmap_exp_type.delete;
   		l_resmap_exp_category.delete;
   		l_resmap_sys_link_func.delete;
   		l_resmap_gl_start_date.delete;
   		l_resmap_encum_type_id.delete;
   		l_resmap_vendor_id.delete;
   		l_resmap_budget_version_id.delete;
   		l_resmap_resource_list_id.delete;
   		l_resmap_entry_level_code.delete;

		OPEN btc_ResList_cur;
		FETCH btc_ResList_cur BULK COLLECT INTO
		l_resmap_exp_item_id
                ,l_resmap_project_id
                ,l_resmap_line_num
                ,l_resmap_cdl_rowid
                ,l_resmap_task_id
                ,l_resmap_top_task_id
                ,l_resmap_person_id
                ,l_resmap_organization_id
                ,l_resmap_job_id
                ,l_resmap_exp_type
                ,l_resmap_exp_category
                ,l_resmap_sys_link_func
                ,l_resmap_gl_start_date
                ,l_resmap_encum_type_id
                ,l_resmap_vendor_id
                ,l_resmap_budget_version_id
                ,l_resmap_resource_list_id
                ,l_resmap_entry_level_code
		,l_resmap_request_id
		;
		CLOSE btc_ResList_cur;

  		l_stage := 160;
		l_resRecCount := l_resmap_exp_item_id.count;
		l_debug_stage := l_stage||':'||'Num of Rows Fetched into PlsqlBlocks['||l_resRecCount||']' ;
		print_msg(l_debug_mode,l_debug_stage);

		If l_resRecCount > 0 Then
		   FORALL i IN l_resmap_exp_item_id.FIRST .. l_resmap_exp_item_id.LAST
 			Insert into PA_MAPPABLE_TXNS_TMP
    				(txn_id,
             			person_id,
             			job_id,
             			organization_id,
             			vendor_id,
             			expenditure_type,
             			event_type,
             			non_labor_resource,
             			expenditure_category,
             			revenue_category,
             			non_labor_resource_org_id,
             			event_type_classification,
             			system_linkage_function,
             			project_role_id,
             			resource_list_id,
             			system_reference1,
             			system_reference2,
				system_reference3,
				system_reference4,
				system_reference5
             			)
          		SELECT
             			pa_mappable_txns_tmp_s.NEXTVAL
             			,l_resmap_person_id(i)
             			,l_resmap_job_id(i)
             			,l_resmap_organization_id(i)
             			,l_resmap_vendor_id(i)
             			,l_resmap_exp_type(i)
             			,NULL
             			,NULL
             			,l_resmap_exp_category(i)
             			,NULL
             			,NULL
             			,NULL
             			,l_resmap_sys_link_func(i)
             			,NULL
             			,l_resmap_resource_list_id(i)
             			,l_resmap_exp_item_id(i)
             			,l_resmap_line_num(i)
				,l_resmap_request_id(i)
				,l_resmap_budget_version_id(i)
				,NULL
			FROM DUAL ;
			l_stage := 170;
			l_debug_stage := l_stage||':'||'Num of Rows Inserted into ResTmpTable['||sql%Rowcount||']';
			print_msg(l_debug_mode,l_debug_stage);

		    --get the distinct resource list Ids to call the resource mapping api
		   l_debug_stage := l_stage||':'||'Fetching distinct resource List ids to call Resource map Api';
		   print_msg(l_debug_mode,l_debug_stage);
		   OPEN reslist_cur ;
		   FETCH reslist_cur BULK COLLECT INTO
			l_bdgt_resource_list_id;
		   CLOSE reslist_cur;

		    -- Call resource mapping API only once for each resource list id
		    l_reslistCount := l_bdgt_resource_list_id.count;
		    l_debug_stage := l_stage||':'||'Numof Distinct Resource ListIdCount['||l_reslistCount||']';
                    print_msg(l_debug_mode,l_debug_stage);
		    l_prev_reslist_id := NULL;
		    IF l_reslistCount > 0 Then
		      FOR i IN l_bdgt_resource_list_id.FIRST .. l_bdgt_resource_list_id.LAST LOOP
	                If l_bdgt_resource_list_id(i) is NOT NULL Then
		         	-- Call the resource map api.
				l_stage := 180;
				l_debug_stage := l_stage||':'||'Calling Resource new_map_txns API For['
						||l_resmap_resource_list_id(i)||']';
				print_msg(l_debug_mode,l_debug_stage);
				l_error_code := null;
				l_error_stage := null;
         		    	PA_RES_ACCUMS.new_map_txns
         		    	(x_resource_list_id   => l_resmap_resource_list_id(i)
          		     	,x_error_stage        => l_error_stage
          		     	,x_error_code         => l_error_code ) ;
		            	l_prev_reslist_id := NVL(l_resmap_resource_list_id(i),0);
				l_debug_stage := l_stage||':'||'End of new_map_txns ErrStage['
						||l_error_stage||']ErrCode['||l_error_code||']' ;
				print_msg(l_debug_mode,l_debug_stage);
		      	End if;
		      END LOOP;
		   END IF;

		End If;  -- end of resRecCount > zero

  		l_stage := 200;
  		--Reset the counter
  		l_counter := 0;
  		l_expenditure_item_id_tab.delete;
  		l_budget_ccid_tab.delete;
  		l_cost_dist_rejection_code_tab.delete;
  		l_line_num_tab.delete;
  		l_cdl_rowid_tab.delete;
  		l_encum_type_id_tab.delete;
                --r12
                l_budget_line_id_tab.delete;
                l_budget_ver_id_tab.delete;

  		FOR c1_rec IN btc_cdl_cur LOOP

    			l_debug_stage := 'Processing Eiid [' || c1_rec.expenditure_item_id ||
                                 '] line_num [' || c1_rec.line_num ||']BdgtVer['||c1_rec.budget_version_id||
                                 '] project_id [' || c1_rec.project_id ||']PoHead['||c1_rec.po_header_id||
                                 '] cdl_rowid [' || c1_rec.cdl_rowid ||']EntryLevlCode['||c1_rec.entry_level_code||
                                 '] task_id [' || c1_rec.task_id ||'] gl_start_date [' || c1_rec.gl_start_date ||
                                 '] top_task_id [' || c1_rec.top_task_id ||
                                 '] person_id [' || c1_rec.person_id ||
                                 '] organization_id [' || c1_rec.organization_id ||
                                 '] job_id [' || c1_rec.job_id ||']ResList['||c1_rec.resource_list_id||
                                 '] expenditure_type [' || c1_rec.expenditure_type ||
                                 '] expenditure_category [' || c1_rec.expenditure_category ||
                                 '] system_linkage_function [' || c1_rec.system_linkage_function ||
                                 '] encum_type_id [' || c1_rec.encum_type_id ||
                                 ']Rlmi ['||c1_rec.resource_list_member_id ||']Poline['||c1_rec.po_line_id||
				 ']pktLineType['||c1_rec.pkt_line_type||
                                 ']dr_ccid['||c1_rec.dr_ccid||']' ;

			print_msg(l_debug_mode,l_debug_stage);
			l_resource_list_member_id := c1_rec.resource_list_member_id;
			/* derive the resource List memberId for Cwk records */
			If c1_rec.po_line_id is NOT NULL Then
				l_stage := 210;
				l_debug_stage := l_stage||':'||'Contingent Worker EI';
				If c1_rec.budget_version_id is NOT NULL
				  and c1_rec.po_header_id is NOT NULL Then
					l_debug_stage := l_stage||':'||'Calling Get_CWK_RLMI API';
					print_msg(l_debug_mode,l_debug_stage);
					l_resource_list_member_id := pa_funds_control_utils2.get_Cwk_rlmi
							(p_project_id        => c1_rec.project_id
                     					,p_task_id           => c1_rec.task_id
                     					,p_budget_version_id => c1_rec.budget_version_id
                     					,p_document_header_id => c1_rec.po_header_id
                     					,p_document_dist_id   => null
                     					,p_document_line_id  => c1_rec.po_line_id
                     					,p_document_type     => 'EXP'
                     					,p_expenditure_type  => c1_rec.expenditure_type
							,p_line_type         => c1_rec.pkt_line_type
                     					,p_calling_module    => 'FUNDS_CHECK' );
                                        If l_resource_list_member_id is Null Then
                                           l_resource_list_member_id := c1_rec.resource_list_member_id;
                                        End If;
					l_debug_stage := l_stage||':'||'CWK RLMI['||l_resource_list_member_id||']' ;
					print_msg(l_debug_mode,l_debug_stage);
				End If;
			End If;
    			/*
     			* Caching.
     			*/

      			l_counter := l_counter + 1;
      			/*
       			* The following tables will be used for BULK update later.
       			*/
      			l_expenditure_item_id_tab(l_counter)      := c1_rec.expenditure_item_id;
      			l_line_num_tab(l_counter)                 := c1_rec.line_num;
      			l_cdl_rowid_tab(l_counter)                := c1_rec.cdl_rowid;
      			l_encum_type_id_tab(l_counter)            := c1_rec.encum_type_id;
      			l_cost_dist_rejection_code_tab(l_counter) := NULL;
      			l_budget_ccid_tab(l_counter)              := NULL;

			IF c1_rec.resource_list_id is NOT NULL Then
			    IF l_resource_list_member_id is NOT NULL Then
          			l_debug_stage := TO_CHAR(l_stage) || ':Calling get_budget_ccid.' ;
				print_msg(l_debug_mode,l_debug_stage);
          			/*
           			* Get budget_ccid
           			*/

          			l_stage := 500;
          			pa_funds_control_utils.get_budget_ccid
          			( p_project_id          => c1_rec.project_id
           			,p_task_id              => c1_rec.task_id
           			,p_top_task_id          => c1_rec.top_task_id
           			,p_res_list_mem_id      => l_resource_list_member_id
           			,p_start_date           => c1_rec.gl_start_date
           			,p_budget_version_id    => c1_rec.budget_version_id
           			,p_entry_level_code     => c1_rec.entry_level_code
           			,x_budget_ccid          => l_budget_ccid
                                --r12
                                ,x_budget_line_id       => l_budget_line_id
           			,x_return_status        => l_return_status
           			,x_error_message_code   => l_error_code
          			);

          			l_debug_stage := TO_CHAR(l_stage) || ':l_budget_ccid is [' || l_budget_ccid || ']';
				print_msg(l_debug_mode,l_debug_stage);
          			IF (l_budget_ccid IS NOT NULL)
                                   --FP M changes
                                   --R12 - commented the (l_budget_ccid = c1_rec.dr_ccid)
                                   --AND
                                   --(l_budget_ccid = c1_rec.dr_ccid)
                                THEN
            				l_budget_ccid_tab(l_counter) := l_budget_ccid;
                                        --r12
            				l_budget_line_id_tab(l_counter) := l_budget_line_id;
            				l_budget_ver_id_tab(l_counter) := c1_rec.budget_version_id;
          			ELSE -- l_budget_ccid IS NULL
                                     If (l_budget_ccid is NULL) Then
            				l_cost_dist_rejection_code_tab(l_counter) := 'F132';
            				l_budget_ccid_tab(l_counter) := NULL;
                                        l_budget_line_id_tab(l_counter) := NULL;
                                        l_budget_ver_id_tab(l_counter) := NULL;
                                     --FP M changes
                                     --R12 - commented the (l_budget_ccid <> c1_rec.dr_ccid)
                                     --ElsIf (l_budget_ccid <> c1_rec.dr_ccid) Then
                                        --l_cost_dist_rejection_code_tab(l_counter) := 'F107';
                                        --l_budget_ccid_tab(l_counter) := NULL;
                                     End If;
          			END IF; -- l_budget_ccid IS NOT NULL.
        		   ELSE  --l_resource_list_member_id IS NULL
          			l_cost_dist_rejection_code_tab(l_counter) := 'F128';
          			l_budget_ccid_tab(l_counter) := NULL;
                                --r12
          			l_budget_line_id_tab(l_counter) := NULL;
          			l_budget_ver_id_tab(l_counter) := NULL;
        		   END IF; -- l_resource_list_member_id NULL check.
            		ELSE -- resource_list_id is NULL.
        			l_cost_dist_rejection_code_tab(l_counter) := 'F121';
        			l_budget_ccid_tab(l_counter) := NULL;
                                --r12
          			l_budget_line_id_tab(l_counter) := NULL;
          			l_budget_ver_id_tab(l_counter) := NULL;
            		END IF;  -- resource_list_id NULL check.
       		END LOOP; --end of btc_cdl_cur

                l_records_processed := l_counter;

		l_debug_stage := l_stage||':'||'NumOfRecords Processed['||l_records_processed||']' ;
		print_msg(l_debug_mode,l_debug_stage);
  		l_debug_stage := TO_CHAR(l_stage)||':No.of CDLs processed for mapping['||TO_CHAR(l_records_processed)||']' ;
     		print_msg(l_debug_mode,l_debug_stage);

  		/*
   		* Update the FC related columns in the CDL.
   		* If Mapping was successful.
   		*
   		* Should modify this update rowid based for performance.
   		*/
  		l_debug_stage := TO_CHAR(l_stage) || ':ORACLE error occurred while Bulk updating BC columns in CDL.' ;

  		l_stage := 600;
  		FORALL l_counter IN 1 .. l_records_processed
    			UPDATE pa_cost_distribution_lines_all cdl
       			SET cdl.budget_ccid = l_budget_ccid_tab(l_counter)
                            --r12
                                ,cdl.budget_version_id = l_budget_ver_id_tab(l_counter)
                                ,cdl.budget_line_id    = l_budget_line_id_tab(l_counter)
          			,cdl.encumbrance_amount = cdl.acct_burdened_cost
          			,cdl.liquidate_encum_flag = 'Y'
          			,cdl.ENCUMBRANCE_TYPE_ID = l_encum_type_id_tab(l_counter)
     			WHERE cdl.rowid = l_cdl_rowid_tab(l_counter)
       			AND l_budget_ccid_tab(l_counter) IS NOT NULL
  			;

  		l_debug_stage := TO_CHAR(l_stage) || ':No.of CDLs updated with FC columns['||TO_CHAR(SQL%ROWCOUNT)||']';
     		print_msg(l_debug_mode,l_debug_stage);

  		/*
   		* Update ei.cost_dist_rejection_code if Mapping
   		* Failed.
   		*/
  		l_stage := 700;
  		FORALL l_counter IN 1 .. l_records_processed
    			UPDATE pa_expenditure_items ei
       			SET ei.cost_dist_rejection_code = l_cost_dist_rejection_code_tab(l_counter)
     			WHERE ei.expenditure_item_id = l_expenditure_item_id_tab(l_counter)
       			AND l_budget_ccid_tab(l_counter) IS NULL
    			;

  		l_debug_stage := TO_CHAR(l_stage)||':No.of CDLs updated with rej_code['||TO_CHAR(SQL%ROWCOUNT)||']';
     		print_msg(l_debug_mode,l_debug_stage);

  		l_debug_stage := TO_CHAR(l_stage) || ':Deleting CDLs which failed mapping.' ;
     		print_msg(l_debug_mode,l_debug_stage);

  		/*
   		* Delete the CDLs which failed resource-mapping.
   		*/
  		l_stage := 800;
  		FORALL l_counter IN 1 .. l_records_processed
    			DELETE FROM pa_cost_distribution_lines cdl
     			WHERE cdl.rowid = l_cdl_rowid_tab(l_counter)
       			AND l_budget_ccid_tab(l_counter) IS NULL
   			;

  		l_debug_stage := TO_CHAR(l_stage)||':No.of CDLs deleted for Mapping failure['||TO_CHAR(SQL%ROWCOUNT)||']';
     		print_msg(l_debug_mode,l_debug_stage);

	--reset the error stack
       	pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS
  THEN
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('ErrStage['||l_stage||']map_btc_items:'||l_debug_stage);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_error_code    := TO_CHAR(SQLCODE) || SQLERRM ;
    x_error_stage   := l_stage ;
    RAISE;
END map_btc_items;

----------------------------------------------------------------------------
/*
 * This procedure deletes the CDLs that failed Funds-Check.
 */

PROCEDURE process_rejected_exp_items ( x_return_status  OUT NOCOPY NUMBER
                                      ,x_error_code     OUT NOCOPY VARCHAR2
                                      ,x_error_stage    OUT NOCOPY VARCHAR2
                                     )
IS
  l_rejected_eiid_tab          PA_PLSQL_DATATYPES.IdTabTyp;
  l_debug_mode                 VARCHAR2(1);
  l_records_affected           NUMBER := 0;
  l_records_deleted            NUMBER := 0; /* Added for bug#3094341 */
  l_stage                      NUMBER ;
  l_del_cdl_eiid_tab           PA_PLSQL_DATATYPES.IdTabTyp;
  l_del_cdl_line_num_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_del_cdl_line_type_tab      PA_PLSQL_DATATYPES.Char1TabTyp;
  l_del_cdl_parent_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_del_cdl_dbc_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_del_cdl_abc_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_del_cdl_pfbc_tab           PA_PLSQL_DATATYPES.NumTabTyp;
  l_del_cdl_pbc_tab            PA_PLSQL_DATATYPES.NumTabTyp;
BEGIN
  pa_debug.init_err_stack('pa_bc_costing.process_rejected_exp_items');

  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
  l_debug_mode := NVL(l_debug_mode, 'Y');

  pa_debug.set_process('PLSQL','LOG',l_debug_mode);

  l_stage := 100;
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':From process_rejected_exp_items';
  pa_debug.write_file(pa_debug.g_err_stage);

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':ORACLE error occurred while selecting rejected EIs.';

  /*
   * Bulk collect the expenditure Items that were
   * rejected during Funds Check.
   */
  /*
   | Modified to handle contingent labor straight time transactions.
   | Bug 4103495: Modified to handle BTC transactions with adjustment_type = 'BURDEN_RESUMMARIZE'.
   +===============================================*/
  l_stage := 200;
  SELECT ei.expenditure_item_id
    BULK COLLECT
    INTO l_rejected_eiid_tab
    FROM pa_expenditure_items ei
   WHERE ei.cost_dist_rejection_code IS NOT NULL
     AND ei.cost_distributed_flag = 'S'
     AND ei.request_id = g_request_id
     AND (ei.system_linkage_function IN ('VI')
          OR (ei.system_linkage_function in ('ST','OT') AND ei.po_line_id IS NOT NULL)
          OR (ei.system_linkage_function = 'BTC' AND ei.adjustment_type = 'BURDEN_RESUMMARIZE')
         );

  l_records_affected := SQL%ROWCOUNT;

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':No. of EIs failed Funds-Check : [' ||
                          TO_CHAR(l_records_affected) || ']';
  pa_debug.write_file(pa_debug.g_err_stage);

  /*
   * Process rejected EIs if there are any.
   * May be we can put the rejected EI process in a seperate
   * procedure
   */
  IF ( l_records_affected > 0 )
  THEN

    pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Deleting CDLs rejected during FC.' ;
    pa_debug.write_file(pa_debug.g_err_stage);

    pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Some rejected CDLs with req_id [' ||
                            TO_CHAR(g_request_id) || '] are being deleted';
    pa_debug.write_file(pa_debug.g_err_stage);

    pa_debug.g_err_stage := TO_CHAR(l_stage) || ':ORACLE error occurred while Deleting CDLs.' ;

    /*
     * Delete CDLs that were rejected during FC.
     * These records will be marked with a NOT NULL value for ei.cost_dist_rejection_code.
     *
     * I think its enough to check for eiid and request_id to identify CDLs
     * that were created during this run. But if its needed to check against line_num
     * also, then line_num also has to be selected above from pa_bc_packets.
     */
    l_stage := 300;
    FORALL i IN l_rejected_eiid_tab.FIRST .. l_rejected_eiid_tab.LAST
    DELETE
      FROM pa_cost_distribution_lines cdl
     WHERE cdl.request_id = g_request_id
       AND cdl.expenditure_item_id = l_rejected_eiid_tab(i)
       AND NVL(cdl.reversed_flag, 'N') <> 'Y'
       AND cdl.transfer_status_code <> 'V'
     RETURNING cdl.expenditure_item_id, cdl.line_num, cdl.line_type, cdl.parent_line_num
              ,nvl(cdl.denom_burdened_cost,0), nvl(cdl.acct_burdened_cost,0), nvl(cdl.burdened_cost,0), nvl(cdl.project_burdened_cost,0)
     BULK COLLECT INTO l_del_cdl_eiid_tab, l_del_cdl_line_num_tab, l_del_cdl_line_type_tab, l_del_cdl_parent_tab
                      ,l_del_cdl_dbc_tab, l_del_cdl_abc_tab, l_del_cdl_pfbc_tab, l_del_cdl_pbc_tab
    ;
   /* Added for Bug fix to get the no of rec's deleted. Bug 3094341 */
    l_records_deleted := SQL%ROWCOUNT;

    pa_debug.g_err_stage := TO_CHAR(l_stage) || ':No. of CDLs deleted [' || TO_CHAR(SQL%ROWCOUNT) || ']';
    pa_debug.write_file(pa_debug.g_err_stage);

   /* Check added to check if no of rec's deleted > 0 then go to the updates.
      Added for Bug 3094341
    */

  IF l_records_deleted > 0 THEN   -----------------------------------------{
    IF (l_debug_mode = 'Y')
    THEN
      /*
       * Modified the Looping to go by l_del_cdl_eiid_tab instead of l_expenditure_item_id_tab.
       */
      FOR i IN l_del_cdl_eiid_tab.FIRST .. l_del_cdl_eiid_tab.LAST
      LOOP
        pa_debug.g_err_stage := 'deleted eiid [' || l_del_cdl_eiid_tab(i) ||
                              '] line_num [' || l_del_cdl_line_num_tab(i) ||
                              '] line_type [' || l_del_cdl_line_type_tab(i) ||
                              '] parent line [' || l_del_cdl_parent_tab(i) ||
                              '] dbc [' || l_del_cdl_dbc_tab(i) ||
                              '] abc [' || l_del_cdl_abc_tab(i) ||
                              '] pfbc [' || l_del_cdl_pfbc_tab(i) ||
                              '] pbc [' || l_del_cdl_pbc_tab(i) ||
                              ']';
           pa_debug.write_file('process_rejected_exp_items: ' || pa_debug.g_err_stage);
    END LOOP;
    END IF; -- debug mode?

    pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Updating reversed_flag in CDLs.' ;
    pa_debug.write_file(pa_debug.g_err_stage);

    pa_debug.g_err_stage := TO_CHAR(l_stage) || ':ORACLE error occurred while Updating CDLs.' ;

    /*
     * Update the reversed_flag of the original CDLs, the reversing and new
     * CDLs of whom where deleted above because of failed FC.
     * Because, since the reversing and new are deleted, the original's
     * reversing flag should be brought back to NULL.
     * The request_id of the original is updated with the current request_id
     * when setting reversed_flag to 'Y'. So, we can make use of that.
     */
    l_stage := 400;
    FORALL i IN l_rejected_eiid_tab.FIRST .. l_rejected_eiid_tab.LAST
    UPDATE pa_cost_distribution_lines cdl
       SET cdl.reversed_flag = NULL
     WHERE NVL(cdl.reversed_flag, 'N') = 'Y'
       AND cdl.request_id = g_request_id
       AND cdl.expenditure_item_id = l_rejected_eiid_tab(i)
    ;

    pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Reversed Flag updated for [' || TO_CHAR(SQL%ROWCOUNT) || '] CDLs';
    pa_debug.write_file(pa_debug.g_err_stage);

    pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Updating burden change buckets on the raw CDLs.' ;
    pa_debug.write_file(pa_debug.g_err_stage);

    pa_debug.g_err_stage := TO_CHAR(l_stage) || ':ORACLE error occurred while Updating Raw CDLs.' ;

    /*=======================================================================+
     | For failed transactions, if the CDL being deleted is of line type I,  |
     | then the corresponding burden change amount has to be deducted from   |
     | the parent raw line.                                                  |
     +=======================================================================*/
    l_stage := 500;
    FORALL i IN l_del_cdl_eiid_tab.FIRST .. l_del_cdl_eiid_tab.LAST
    UPDATE pa_cost_distribution_lines cdl
       SET cdl.denom_burdened_change = cdl.denom_burdened_change - l_del_cdl_dbc_tab(i)
          ,cdl.acct_burdened_change = cdl.acct_burdened_change - l_del_cdl_abc_tab(i)
          ,cdl.projfunc_burdened_change = cdl.projfunc_burdened_change - l_del_cdl_pfbc_tab(i)
          ,cdl.project_burdened_change = cdl.project_burdened_change - l_del_cdl_pbc_tab(i)
     WHERE cdl.expenditure_item_id = l_del_cdl_eiid_tab(i)
       and cdl.line_num = l_del_cdl_parent_tab(i)
       and l_del_cdl_line_type_tab(i) = 'I'
    ;
    pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Burden Change Bucket updated for [' || TO_CHAR(SQL%ROWCOUNT) || '] CDLs';
    pa_debug.write_file(pa_debug.g_err_stage);

  END IF;     -------------------------------------------------------------} /*  l_records_deleted? */


    pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Leaving process_rejected_exp_items.';
    pa_debug.write_file(pa_debug.g_err_stage);

  END IF; -- Were any EI got rejected?

   pa_debug.reset_err_stack;

  EXCEPTION
    WHEN OTHERS
    THEN
      pa_debug.write_file('EXCEPTION:' ||  pa_debug.g_err_stage);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_error_code    := TO_CHAR(SQLCODE) || SQLERRM ;
      x_error_stage   := l_stage ;
      RAISE;
  END; -- process_rejected_exp_items

------------------------------------------------------------------------
  PROCEDURE populate_pa_bc_packets( x_return_status  OUT NOCOPY NUMBER
                                   ,x_error_code     OUT NOCOPY VARCHAR2
                                   ,x_error_stage    OUT NOCOPY VARCHAR2
                                  )
  IS
      PRAGMA AUTONOMOUS_TRANSACTION;

    l_debug_mode                 VARCHAR2(1);
    l_records_affected           NUMBER := 0;
    l_stage                      NUMBER ;

  BEGIN

  pa_debug.init_err_stack('pa_bc_costing.populate_pa_bc_packets');

  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
  l_debug_mode := NVL(l_debug_mode, 'Y');

  pa_debug.set_process('PLSQL','LOG',l_debug_mode);

  l_stage := 100;
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':From populate_pa_bc_packets';
  pa_debug.write_file(pa_debug.g_err_stage);

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Before Inserting Raw lines into pa_bc_packets.' ;
  pa_debug.write_file(pa_debug.g_err_stage);

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':ORACLE error occurred while Bulk inserting into pa_bc_packets.' ;

  /*
   * Insert Raw lines.
   *
   * For New lines, the FC process will insert the debit burden lines.
   * To distinguish a new line from a reversal line, the parent_bc_packet_id
   * is inserted as -1 for a new line.
   * For a reversal line, the value will be NULL.
   *
   * The transfer_status_code Join is used to make use of PA_COST_DISTRIBUTION_LINES_N2
   * index.
   *
   * burden_cost_flag is populated 'N' for Raw line.
   */
    l_stage := 200;
    FORALL i IN l_expenditure_item_id_tab.FIRST .. l_expenditure_item_id_tab.LAST
    INSERT
      INTO pa_bc_packets( packet_id
                         ,project_id
                         ,task_id
                         ,budget_version_id
                         ,expenditure_type
                         ,expenditure_item_date
                         ,period_name
                         ,pa_date
                         ,gl_date
                         ,set_of_books_id
                         ,je_category_name
                         ,je_source_name
                         ,status_code
                         ,document_type
                         ,funds_process_mode
                         ,burden_cost_flag
                         ,expenditure_organization_id
                         ,document_header_id
                         ,document_distribution_id
                         ,document_line_id
                         ,txn_ccid
                         ,accounted_dr
                         ,entered_dr
                         ,bc_packet_id
                         ,parent_bc_packet_id
                         ,org_id
                         ,balance_posted_flag
                         ,program_id
                         ,program_application_id
                         ,program_update_date
                         ,last_update_date
                         ,last_updated_by
                         ,created_by
                         ,creation_date
                         ,last_update_login
                         ,request_id
			 ,reference1
			 ,reference2
			 ,reference3
                        )
    SELECT g_packet_id                                                            -- packet_id
          ,l_project_id_tab(i)                                                    -- project_id
          ,l_task_id_tab(i)                                                       -- task_id
          ,l_budget_version_id_tab(i)                                             -- budget_version_id
          ,l_expenditure_type_tab(i)                                              -- expenditure_type
          ,l_expenditure_item_date_tab(i)                                         -- expenditure_item_date
          ,l_gl_period_name_tab(i)                                                -- period_name
          ,l_pa_date_tab(i)                                                       -- pa_date
          ,l_gl_date_tab(i)                                                       -- gl_date
          ,g_sob_id                                                               -- set_of_book_id
          ,'Project Accounting'                                                   -- je_category_name
          ,'Expenditures'                                                          -- je_source_name
          ,'P'                                                                    -- status_code
          ,'EXP'                                                                  -- document_type
          ,'T'                                                                    -- funds_process_mode
          ,'N'                                                                    -- burden_cost_flag
          ,l_exp_organization_id_tab(i)                                           -- expenditure_organization_id
          ,l_expenditure_item_id_tab(i)                                                -- document_header_id
          ,l_line_num_tab(i)                                                           -- document_distribution_id
          ,l_document_line_id_tab(i)                                              -- document_line_id
          ,l_dr_code_combination_id_tab(i)                                            -- txn_ccid
          ,l_acct_raw_cost_tab(i)                                                -- accounted_dr
          ,l_acct_raw_cost_tab(i)                                                 -- entered_dr
          ,pa_bc_packets_s.NEXTVAL                                                -- bc_packet_id
          ,l_parent_bc_packet_id_tab(i)                                           -- parent_bc_packet_id
          ,l_org_id_tab(i)                                                        -- org_id
          ,'N'                                                                    -- balance_posted_flag
          ,g_program_id                                                           -- program_id
          ,g_program_application_id                                               -- program_application_id
          ,SYSDATE                                                                -- program_update_date
          ,SYSDATE                                                                -- last_update_date
          ,g_last_updated_by                                                      -- last_updated_by
          ,g_created_by                                                           -- created_by
          ,SYSDATE                                                                -- creation_date
          ,g_last_update_login                                                    -- last_update_login
          ,g_request_id
	  ,l_pkt_reference1_Tab(i)
	  ,l_pkt_reference2_Tab(i)
	  ,l_pkt_reference3_Tab(i)
      FROM DUAL
   ;

    l_records_affected := SQL%ROWCOUNT;

    pa_debug.g_err_stage := TO_CHAR(l_stage) || ':After Inserting Raw lines into pa_bc_packets.' ;
    pa_debug.write_file(pa_debug.g_err_stage);

    pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Inserted [' || TO_CHAR(l_records_affected) ||
                                                '] Raw lines into pa_bc_packets.';
    pa_debug.write_file(pa_debug.g_err_stage);

    /*
     * Insert Burden lines - if the project is burdened.
     * For burden_amt_display_method = 'S', Burdened amount is stored in the raw
     * cdl itself.
     * Entered_dr = Burdened_amount - raw_cost
     *
     * Since, both the reversed and the reversing lines have the same request_id
     * (though the reversed line could have been created in a previous run),
     * to identify CDLs that were created in this run, we select those records
     * with cdl.reversed_flag <> 'Y'.
     *
     * Burden lines are inserted in this level - only if this is a reversing line.
     * For NEW lines, the FC process creates the Burden lines.
     * For this, we go by the cdl.line_num_reversed.
     *
     * Identifying the raw line in bc_packets corresponding to the burden line
     * that we are inserting.
     *
     * cdl.eiid = bcpk.eiid
     * bcpk.parent_bc_packet_id is null
     * because, if parent_bc_packet_id is NOT NULL, it means its a fresh raw line.
     * for fresh line, we wouldnt' be inserting burden lines in the first place.
     * if its just another burden line, the parent_bc_packet_id will have the
     * bc_packet_id of the raw line.
     *
     * burden_cost_flag is populated 'O' for Burden lines.
     */

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Inserting Burden lines into pa_bc_packets (display_method = S).' ;
  pa_debug.write_file(pa_debug.g_err_stage);

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':ORACLE error occurred while inserting into pa_bc_packets' ;

  l_stage := 300;
  FORALL i IN l_expenditure_item_id_tab.FIRST .. l_expenditure_item_id_tab.LAST
    INSERT
      INTO pa_bc_packets( packet_id
                         ,project_id
                         ,task_id
                         ,budget_version_id
                         ,expenditure_type
                         ,expenditure_item_date
                         ,period_name
                         ,pa_date
                         ,gl_date
                         ,set_of_books_id
                         ,je_category_name
                         ,je_source_name
                         ,status_code
                         ,document_type
                         ,funds_process_mode
                         ,burden_cost_flag
                         ,expenditure_organization_id
                         ,document_header_id
                         ,document_distribution_id
                         ,document_line_id
                         ,txn_ccid
                         ,accounted_dr
                         ,entered_dr
                         ,bc_packet_id
                         ,parent_bc_packet_id
                         ,org_id
                         ,balance_posted_flag
                         ,program_id
                         ,program_application_id
                         ,program_update_date
                         ,last_update_date
                         ,last_updated_by
                         ,created_by
                         ,creation_date
                         ,last_update_login
                         ,request_id
			 ,reference1
			 ,reference2
			 ,reference3
                        )
    SELECT g_packet_id                                                  -- packet_id
          ,l_project_id_tab(i)                                               -- project_id
          ,l_task_id_tab(i)                                             -- task_id
          ,l_budget_version_id_tab(i)                                   -- budget_version_id
          ,l_expenditure_type_tab(i)                                    -- expenditure_type
          ,l_expenditure_item_date_tab(i)                               -- expenditure_item_date
          ,l_gl_period_name_tab(i)                                                -- period_name
          ,l_pa_date_tab(i)                                                       -- pa_date
          ,l_gl_date_tab(i)                                                       -- gl_date
          ,g_sob_id                                                     -- set_of_books_id
          ,'Project Accounting'                                         -- je_category_name
          ,'Expendiures'                                                -- je_source_name
          ,'P'                                                          -- status_code
          ,'EXP'                                                        -- document_type
          ,'T'                                                          -- funds_process_mode
          ,'O'                                                          -- funds_process_mode
          ,l_exp_organization_id_tab(i)                                 -- expenditure_organization_id
          ,l_expenditure_item_id_tab(i)                                      -- document_header_id
          ,l_line_num_tab(i)                                                 -- document_distribution_id
          ,l_document_line_id_tab(i)                                    -- document_line_id
          ,l_dr_code_combination_id_tab(i)                              -- txn_ccid
          ,(l_acct_burdened_cost_tab(i) - l_acct_raw_cost_tab(i))             -- accounted_dr
          ,(l_acct_burdened_cost_tab(i) - l_acct_raw_cost_tab(i))           -- entered_dr
          ,pa_bc_packets_s.NEXTVAL                                      -- pa_bc_packet_id
          --,DECODE(l_line_num_reversed_tab(i), NULL, NULL, bcpk.bc_packet_id) -- parent_bc_packet_id
          ,DECODE(l_line_type_tab(i), 'I', NULL, DECODE(l_line_num_reversed_tab(i), NULL, NULL, bcpk.bc_packet_id)) -- parent_bc_packet_id
          ,l_org_id_tab(i)                                              -- org_id
          ,'N'                                                          -- balance_posted_flag
          ,g_program_id                                                 -- program_id
          ,g_program_application_id                                     -- program_application_id
          ,SYSDATE                                                      -- program_update_date
          ,SYSDATE                                                      -- last_update_date
          ,g_last_updated_by                                            -- last_updated_by
          ,g_created_by                                                 -- created_by
--        ,100                                                 -- created_by
          ,SYSDATE                                                      -- creation_date
          ,g_last_update_login                                          -- last_update_login
          ,g_request_id
	  ,l_pkt_reference1_Tab(i)
	  ,l_pkt_reference2_Tab(i)
	  ,l_pkt_reference3_Tab(i)
      FROM pa_bc_packets              bcpk       -- to get the raw line in bc_packets
     WHERE l_line_num_reversed_tab(i) IS NOT NULL
       AND l_burden_amt_disp_method_tab(i) = 'S'
       AND l_burden_cost_flag_tab(i) = 'Y'
       AND bcpk.document_header_id = l_expenditure_item_id_tab(i)
       AND bcpk.parent_bc_packet_id IS NULL
       AND bcpk.packet_id = g_packet_id
    ;

  l_records_affected := TO_CHAR(SQL%ROWCOUNT) ;

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':After Inserting Burden lines into pa_bc_packets (display_method = S).' ;
  pa_debug.write_file(pa_debug.g_err_stage);

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Inserted [' || TO_CHAR(l_records_affected) ||
                                              '] Burden lines into pa_bc_packets';
  pa_debug.write_file(pa_debug.g_err_stage);

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Inserting Burden lines into pa_bc_packets (disp_method = D).' ;
  pa_debug.write_file(pa_debug.g_err_stage);

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':ORACLE error occurred while inserting Burden lines into bc_pk dis_meth = D' ;
    /*
     * For burden_amt_display_method = D, Burdened amount has to be derived.
     * The bc_packet_id in pa_bc_packets for the *R* line for this EI is populated as
     * parent_bc_packet_id in the burden line in pa_bc_packets.
     * *R* line in pa_bc_packets will be identified by a NULL in the parent_bc_packet_id
     * column.
     */
  l_stage := 400;
  FORALL i IN l_expenditure_item_id_tab.FIRST .. l_expenditure_item_id_tab.LAST
    INSERT
      INTO pa_bc_packets( packet_id
                         ,project_id
                         ,task_id
                         ,budget_version_id
                         ,expenditure_type
                         ,expenditure_item_date
                         ,period_name
                         ,pa_date
                         ,gl_date
                         ,set_of_books_id
                         ,je_category_name
                         ,je_source_name
                         ,status_code
                         ,document_type
                         ,funds_process_mode
                         ,burden_cost_flag
                         ,expenditure_organization_id
                         ,document_header_id
                         ,document_distribution_id
                         ,document_line_id
                         ,txn_ccid
                         ,accounted_dr
                         ,entered_dr
                         ,bc_packet_id
                         ,parent_bc_packet_id
                         ,org_id
                         ,balance_posted_flag
                         ,program_id
                         ,program_application_id
                         ,program_update_date
                         ,last_update_date
                         ,last_updated_by
                         ,created_by
                         ,creation_date
                         ,last_update_login
                         ,request_id
			 ,reference1
			 ,reference2
			 ,reference3
                        )
  SELECT g_packet_id                                                    -- packet_id
        ,l_project_id_tab(i)                                                 -- project_id
        ,l_task_id_tab(i)                                               -- task_id
        ,l_budget_version_id_tab(i)                                     -- budget_version_id
        ,icc.expenditure_type                                           -- expenditure_type
        ,l_expenditure_item_date_tab(i)                                 -- expenditure_item_date
        ,l_gl_period_name_tab(i)                                                -- period_name
        ,l_pa_date_tab(i)                                                       -- pa_date
        ,l_gl_date_tab(i)                                                       -- gl_date
        ,g_sob_id                                                       -- set_of_book_id
        ,'Project Accounting'                                           -- je_category_name
        ,'Expenditures'                                                 -- je_source_name
        ,'P'                                                            -- status_code
        ,'EXP'                                                          -- document_type
        ,'T'                                                            -- funds_process_mode
        ,'O'                                                            -- funds_process_mode
        ,l_exp_organization_id_tab(i)                                   -- expenditure_organization_id
        ,l_expenditure_item_id_tab(i)                                   -- document_header_id
        ,l_line_num_tab(i)                                                   -- document_distribution_id
        ,l_document_line_id_tab(i)                                      -- document_line_id
        ,l_dr_code_combination_id_tab(i)                                -- txn_ccid
        ,ROUND(l_acct_raw_cost_tab(i) * cm.compiled_multiplier,2)       -- accounted_dr
        ,ROUND(l_acct_raw_cost_tab(i) * cm.compiled_multiplier,2)       -- entered_dr
        ,pa_bc_packets_s.NEXTVAL                                        -- bc_packet_id
        --,DECODE(l_line_num_reversed_tab(i), NULL, NULL, bcpk.bc_packet_id)   -- parent_bc_packet_id
        ,DECODE(l_line_type_tab(i), 'I', NULL, DECODE(l_line_num_reversed_tab(i), NULL, NULL, bcpk.bc_packet_id))   -- parent_bc_packet_id
        ,l_org_id_tab(i)                                                -- org_id
        ,'N'                                                            -- balance_posted_flag
        ,g_program_id                                                   -- program_id
        ,g_program_application_id                                       -- program_application_id
        ,SYSDATE                                                        -- program_update_date
        ,SYSDATE                                                        -- last_update_date
        ,g_last_updated_by                                              -- last_updated_by
        ,g_created_by                                                   -- created_by
        ,SYSDATE                                                        -- creation_date
        ,g_last_update_login                                            -- last_update_login
        ,g_request_id
	,l_pkt_reference1_tab(i)
	,l_pkt_reference2_tab(i)
	,l_pkt_reference3_tab(i)
  FROM   PA_IND_COST_CODES ICC,
         PA_COMPILED_MULTIPLIERS CM,
         PA_IND_COMPILED_SETS ICS,
         PA_COST_BASE_EXP_TYPES CBET,
         PA_COST_BASES CB,
         PA_IND_RATE_SCH_REVISIONS IRSR,
         PA_IND_RATE_SCHEDULES_ALL_BG IRS
        ,PA_BC_PACKETS bcpk
  WHERE ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id
    AND irs.ind_rate_sch_id          = irsr.ind_rate_sch_id
    AND irsr.cost_plus_structure     = cbet.cost_plus_structure
    AND cbet.cost_base               = cm.cost_base
    AND cb.cost_base                 = cbet.cost_base
    AND cb.cost_base_type            = cbet.cost_base_type
    AND cbet.cost_base_type          = 'INDIRECT COST'
    AND cbet.expenditure_type        = l_expenditure_type_tab(i)
    AND ics.organization_id          = l_exp_organization_id_tab(i)
    AND ics.cost_base                = cbet.cost_base
    AND ics.ind_compiled_set_id      = l_ind_compiled_set_id_tab(i)
    AND icc.ind_cost_code            = cm.ind_cost_code
    AND cm.ind_compiled_set_id       = l_ind_compiled_set_id_tab(i)
    AND l_burden_sum_rej_code_tab(i)  IS NULL
    AND l_burden_sum_source_run_id_tab(i) = -9999
    AND l_burden_amt_disp_method_tab(i)  = 'D'
    AND l_burden_cost_flag_tab(i)        = 'Y'
    AND l_line_num_reversed_tab(i) IS NOT NULL                                -- reversing line
    AND bcpk.document_header_id = l_expenditure_item_id_tab(i)
    AND bcpk.parent_bc_packet_id IS NULL
    AND bcpk.packet_id = g_packet_id
 ;

  l_records_affected := SQL%ROWCOUNT ;

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Inserted [' || TO_CHAR(l_records_affected) || '] Burden lines into pa_bc_packets';
  pa_debug.write_file(pa_debug.g_err_stage);

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':After Inserting Burden lines into pa_bc_packets (disp_method = D).' ;
  pa_debug.write_file(pa_debug.g_err_stage);

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Committing work!!' ;
  pa_debug.write_file(pa_debug.g_err_stage);

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Leaving populate_pa_bc_packets.' ;
  pa_debug.write_file(pa_debug.g_err_stage);

  l_stage := 500;
  COMMIT;
     pa_debug.reset_err_stack;
  EXCEPTION
    WHEN OTHERS
    THEN
      pa_debug.write_file(pa_debug.g_err_stage);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_error_code    := TO_CHAR(SQLCODE) || SQLERRM ;
      x_error_stage   := l_stage ;
      RAISE;
  END; -- populate_pa_bc_packets

--------------------------------------------------------------------------------------
  /*
   *
   *
   */
  PROCEDURE validate_debit_lines ( p_request_id     IN  NUMBER
                                  ,x_return_status  OUT NOCOPY NUMBER
                                  ,x_error_code     OUT NOCOPY VARCHAR2
                                  ,x_error_stage    OUT NOCOPY NUMBER
                                 )
  IS
  /*
   * Table to store the rejection code - if mapping fails.
   * Value will be NULL if the CDL was successfully mapped.
   */
  l_expenditure_item_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;
  l_budget_ccid_tab              PA_PLSQL_DATATYPES.IdTabTyp;
  l_cost_dist_rejection_code_tab PA_PLSQL_DATATYPES.Char30TabTyp;
  l_line_num_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
  l_cdl_rowid_tab                PA_PLSQL_DATATYPES.RowidTabTyp;
  l_encum_type_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;
  l_deleted_eiids_tab            PA_PLSQL_DATATYPES.IdTabTyp;

  l_counter                    NUMBER := 0;
  l_debug_mode                 VARCHAR2(1) := 'N';
  l_records_processed          NUMBER := 0;
  l_cdls_deleted               NUMBER := 0;

  l_prev_project_id            pa_cost_distribution_lines.project_id%TYPE;
  l_prev_flag                  VARCHAR2(1);
  l_budget_version_id          pa_bc_packets.budget_version_id%TYPE;
  l_resource_list_id           pa_budget_versions.resource_list_id%TYPE;
  l_entry_level_code           pa_budget_versions.budget_entry_method_code%TYPE;  --???
  l_resource_list_member_id    pa_bc_packets.resource_list_member_id%TYPE;
  l_budget_ccid                pa_cost_distribution_lines.budget_ccid%TYPE;

  l_fnd_reqd_flag              VARCHAR2(1);

  g_request_id                 NUMBER;
  l_return_status              VARCHAR2(1);
  l_stage                      NUMBER;
  l_error_code                 VARCHAR2(30);

  /*
   * The line_num_reversed and reversed_flag combination will get us
   * the latest 'R' CDL.
   */
  CURSOR c1
  IS
  SELECT cdl.expenditure_item_id    expenditure_item_id
        ,cdl.budget_ccid            budget_ccid
        ,cdl.line_num               line_num
    FROM pa_cost_distribution_lines cdl
        ,pa_expenditure_items ei
   WHERE (ei.system_linkage_function IN ('VI')
         --FP M changes
         OR (ei.system_linkage_function in ('ST','OT') AND ei.po_line_id IS NOT NULL))
     AND ei.expenditure_item_id = cdl.expenditure_item_id
     AND ei.cost_burden_distributed_flag  = 'S'
     AND ei.cost_distributed_flag = 'Y'
     AND ei.ind_cost_dist_rejection_code IS NULL
     AND cdl.line_type ='R'
     AND cdl.line_num_reversed IS NULL
     AND cdl.reversed_flag IS NULL
     AND pa_funds_control_utils.get_bdgt_link(NVL( cdl.project_id, -99)
                                                  ,'STD'
                                                 ) = 'Y'
   ;

  /*
   * The following cursor will fetch the 'D' lines created in this
   * run for a given eiid.
   */

  CURSOR c2( p_cur_eiid IN NUMBER
            ,p_cur_request_id IN NUMBER)
  IS
  SELECT cdl.dr_code_combination_id
    FROM pa_cost_distribution_lines cdl
   WHERE cdl.expenditure_item_id = p_cur_eiid
     AND cdl.request_id = p_cur_request_id
     AND cdl.line_type = 'D'
   ;

  BEGIN
    /*
     * For a cursor of 'R' lines of the EIs fetched for distribution
     * map one-by-one and match it with its corresponding 'D' line
     * and accordingly upate the dist_rejection_code.
     * finally delete 'D' and 'C' lines which have ei.dist_rejection_code
     * as not null.
     */
  pa_debug.init_err_stack('pa_bc_costing.validate_debit_lines');

  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
  l_debug_mode := NVL(l_debug_mode, 'N');

  pa_debug.set_process('PLSQL','LOG',l_debug_mode);

  l_stage := 100;
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':From validate_debit_lines';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('validate_debit_lines: ' || pa_debug.g_err_stage);
  END IF;

  g_request_id := p_request_id;
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Request_id is [' || TO_CHAR(g_request_id) || ']';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('validate_debit_lines: ' || pa_debug.g_err_stage);
  END IF;

    FOR c1_rec IN c1
    LOOP
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Processing cdl [' || c1_rec.expenditure_item_id ||
                                 '] line_num [' || c1_rec.line_num ||
                                 '] bccid [' || c1_rec.budget_ccid ||
                                 ']' ;
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('validate_debit_lines: ' || pa_debug.g_err_stage);
      END IF;

      l_stage := 1000;
      l_counter := l_counter + 1;
      l_expenditure_item_id_tab(l_counter) := c1_rec.expenditure_item_id;
      l_cost_dist_rejection_code_tab(l_counter) := NULL;

      FOR c2_rec IN c2( l_expenditure_item_id_tab(l_counter)
                       ,g_request_id)
      LOOP
        IF (l_cost_dist_rejection_code_tab(l_counter) IS NULL)
        THEN
          IF (c1_rec.budget_ccid IS NOT NULL)
          THEN
            pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Comparing dccid [' || TO_CHAR(c2_rec.dr_code_combination_id) ||
                                    '] and bccid [' || TO_CHAR(c1_rec.budget_ccid) || ']';
            IF P_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('validate_debit_lines: ' || pa_debug.g_err_stage);
            END IF;

            --R12 - commented the budget ccid validation and moved the cost dist rejection code assignment to NULL here
            l_cost_dist_rejection_code_tab(l_counter) := NULL;

            /* R12
            IF (c2_rec.dr_code_combination_id <> c1_rec.budget_ccid)
            THEN
              pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Decided to reject the EI.';
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('validate_debit_lines: ' || pa_debug.g_err_stage);
              END IF;
              l_cost_dist_rejection_code_tab(l_counter) := 'F107';
            ELSE
              pa_debug.g_err_stage := TO_CHAR(l_stage) || ':EI validation passed.';
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('validate_debit_lines: ' || pa_debug.g_err_stage);
              END IF;
              l_cost_dist_rejection_code_tab(l_counter) := NULL;
            END IF;
            */

          ELSE
            pa_debug.g_err_stage := TO_CHAR(l_stage) || ':B_ccid in the raw line is null';
            IF P_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('validate_debit_lines: ' || pa_debug.g_err_stage);
            END IF;
            l_cost_dist_rejection_code_tab(l_counter) := 'F165';
          END IF;
        END IF;
      END LOOP; -- c2_rec
    END LOOP; -- c1_rec

    l_records_processed := l_counter;
    pa_debug.g_err_stage := TO_CHAR(l_stage) || ':No. of EIs validated [' || TO_CHAR(l_records_processed) || ']';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('validate_debit_lines: ' || pa_debug.g_err_stage);
    END IF;

    IF (l_expenditure_item_id_tab.COUNT > 0)
    THEN
      FOR i IN 1 .. l_expenditure_item_id_tab.LAST
      LOOP
          pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Eiid [' ||
                                  TO_CHAR(l_expenditure_item_id_tab(i)) ||
                                  '] rej_code [' || l_cost_dist_rejection_code_tab(i) || ']';
          IF P_DEBUG_MODE = 'Y' THEN
             pa_debug.write_file('validate_debit_lines: ' || pa_debug.g_err_stage);
          END IF;
      END LOOP;
    END IF;

    IF (l_expenditure_item_id_tab.COUNT > 0)
    THEN
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Updating cost_dist_rejection_code in EIs.';
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('validate_debit_lines: ' || pa_debug.g_err_stage);
      END IF;
      /*
       * Update cost_dist_rejection_code.
       */
      FORALL i IN 1 .. l_expenditure_item_id_tab.LAST
      UPDATE pa_expenditure_items ei
         SET ei.ind_cost_dist_rejection_code = l_cost_dist_rejection_code_tab(i)
       WHERE ei.expenditure_item_id = l_expenditure_item_id_tab(i)
         AND l_cost_dist_rejection_code_tab(i) IS NOT NULL
         AND ei.ind_cost_dist_rejection_code IS NULL
      ;

      l_stage := 1000;
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ':No. of EIs updated with cost_dist_rejection_code [' ||
                              TO_CHAR(SQL%ROWCOUNT) || ']' ;
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('validate_debit_lines: ' || pa_debug.g_err_stage);
      END IF;

      pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Deleting C and D lines for rejected EIs.';
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('validate_debit_lines: ' || pa_debug.g_err_stage);
      END IF;

      /*
       * Delete errored CDLs.
       */
      FORALL i IN 1 .. l_expenditure_item_id_tab.LAST
      DELETE
        FROM pa_cost_distribution_lines cdl
       WHERE cdl.line_type IN ('C', 'D')
         AND cdl.request_id = g_request_id
         AND cdl.expenditure_item_id = l_expenditure_item_id_tab(i)
         AND l_cost_dist_rejection_code_tab(i) IS NOT NULL
      ;

      l_stage := 1100;
      l_cdls_deleted := SQL%ROWCOUNT;
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ':No. of CDLs deleted should be an even number.';
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('validate_debit_lines: ' || pa_debug.g_err_stage);
      END IF;

      pa_debug.g_err_stage := TO_CHAR(l_stage) || ':No. of CDLs deleted [' || TO_CHAR(l_cdls_deleted) || ']' ;
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('validate_debit_lines: ' || pa_debug.g_err_stage);
      END IF;
    END IF; -- anything got mapped??

    x_return_status := 0;
    pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Leaving validate_debit_lines.';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('validate_debit_lines: ' || pa_debug.g_err_stage);
    END IF;

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS
  THEN
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('validate_debit_lines: ' || pa_debug.g_err_stage);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_error_code    := TO_CHAR(SQLCODE) || SQLERRM ;
    x_error_stage   := l_stage ;
    RAISE;

  END validate_debit_lines;
--------------------------------------------------------------------------------------
/*=============================================================================+
 | CWK: This API does the funds-checking for Contingent Worker transactions.   |
 +=============================================================================*/
PROCEDURE costing_fc_proc_cwk ( p_calling_module IN  VARCHAR2
                               ,p_request_id     IN  NUMBER
                               ,x_return_status  OUT NOCOPY NUMBER
                               ,x_error_code     OUT NOCOPY VARCHAR2
                               ,x_error_stage    OUT NOCOPY NUMBER
                              )
IS

  /*
   * Processing related variables.
   */
  l_calling_module             VARCHAR2(20) ;
  l_debug_mode                 VARCHAR2(1);
  l_return_status              VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
  l_error_code                 VARCHAR2(30);
  l_error_stage                VARCHAR2(30);
  l_proc_name                  VARCHAR2(50) := 'costing_fc_proc_cwk';
  l_records_affected           NUMBER := 0;
  l_stage                      NUMBER ;
  l_bunch_size                 PLS_INTEGER := 100;
  l_this_fetch                 PLS_INTEGER := 0;
  l_totally_fetched            PLS_INTEGER := 0;
  l_totally_processed          PLS_INTEGER := 0;
  l_ei_to_process_from         pa_expenditure_items_all.expenditure_item_id%TYPE := 0;

  /*
   * Cursor Declaration.
   */

  CURSOR pa_bc_packet_cwk_cur
  IS
  SELECT cdl.expenditure_item_id
        ,cdl.line_num
        ,cdl.line_type
        ,cdl.line_num_reversed
        ,decode(cdl.line_type, 'I', ei.acct_raw_cost, cdl.acct_raw_cost)
        ,decode(cdl.line_type, 'I', ei.denom_raw_cost, cdl.denom_raw_cost)
        ,cdl.acct_burdened_cost
        ,cdl.denom_burdened_cost
        ,cdl.project_id
        ,cdl.pa_date
        ,cdl.gl_date
        ,cdl.burden_sum_rejection_code
        ,cdl.burden_sum_source_run_id
        ,cdl.ind_compiled_set_id
        ,cdl.dr_code_combination_id
        ,TO_NUMBER(cdl.system_reference2)    po_header_id
        ,glp.period_name
        ,ei.expenditure_item_date
        ,ei.expenditure_type
        ,cdl.task_id
        ,ei.po_line_id
        ,NVL(ei.override_to_organization_id, exp.incurred_by_organization_id)
        ,NVL(ei.org_id, -99)
        ,NVL(pt.burden_amt_display_method, 'S')
        ,NVL(pt.burden_cost_flag, 'N')
        ,bv.budget_version_id
	,'EXP'                   reference1
	,cdl.expenditure_item_id reference2
        ,cdl.line_num            reference3
    FROM pa_expenditure_items_all ei
        ,pa_cost_distribution_lines_all cdl
        ,pa_project_types_all     pt
        ,pa_projects_all          p
        ,pa_expenditures          exp
        ,pa_budget_versions       bv
        ,pa_budgetary_control_options pbct
        ,gl_period_statuses       glp
        ,po_distributions_all     pod  /* 6989758 */
   WHERE ei.cost_distributed_flag = 'S'
     AND ei.request_id = g_request_id
     AND ei.cost_dist_rejection_code IS NULL
     AND ei.denom_raw_cost IS NOT NULL
     AND ei.system_linkage_function IN ('ST')
     AND ei.expenditure_id = exp.expenditure_id
     AND ei.expenditure_item_id > l_ei_to_process_from
     AND cdl.request_id = g_request_id
     AND cdl.line_type in ('R', 'I')
     AND cdl.expenditure_item_id = ei.expenditure_item_id
     AND NVL(cdl.reversed_flag, 'N') <> 'Y'
     AND cdl.project_id = p.project_id
     AND p.project_type = pt.project_type
     -- R12 AND NVL(pt.org_Id, -99) = NVL(p.org_Id, -99)
     AND pt.org_Id = p.org_Id
     AND glp.application_id = 101
     AND glp.set_of_books_id = g_sob_id
     AND TRUNC(cdl.gl_date) BETWEEN TRUNC(glp.START_DATE) AND TRUNC(glp.END_DATE)
     AND pbct.project_id = bv.project_id
     AND pbct.BDGT_CNTRL_FLAG = 'Y'
     AND pbct.BUDGET_TYPE_CODE = bv.budget_type_code
     AND (pbct.EXTERNAL_BUDGET_CODE = 'GL'
          OR
          pbct.EXTERNAL_BUDGET_CODE IS NULL)
     AND bv.project_id = cdl.project_id
     AND bv.current_flag = 'Y'
     AND bv.budget_status_code = 'B'
     AND ei.po_line_id IS NOT NULL
     --FP M changes
     And adjustment_period_flag = 'N'
     AND to_char(pod.po_header_id) = cdl.system_reference2 /* 6989758 */
     AND ei.po_line_id  = pod.po_line_id /* 6989758 */
     AND cdl.project_id = pod.project_id /* 6989758 */
     AND cdl.task_id = pod.task_id /* 6989758 */
  ORDER BY cdl.expenditure_item_id
          ,cdl.line_num
    ;


BEGIN
  pa_debug.init_err_stack('pa_bc_costing.costing_fc_proc_cwk');

  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
  l_debug_mode := NVL(l_debug_mode, 'Y');

  pa_debug.set_process('PLSQL','LOG',l_debug_mode);

  l_stage := 100;
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ': From costing_fc_proc_cwk R112';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file(l_proc_name || ': ' || pa_debug.g_err_stage);
  END IF;

  /*
   * Copy incoming parameters into Local variables.
   */
  l_calling_module := p_calling_module ;
  g_request_id     := p_request_id ;

  pa_debug.g_err_stage := to_char(l_stage) || ': Request Id is [' || to_char(g_request_id) || ']' ;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file(l_proc_name || ': ' || pa_debug.g_err_stage);
  END IF;

  /*
   * Get the sob_id.
   */
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':ORACLE error occurred while selecting pa_implementations';
  SELECT set_of_books_id
    INTO g_sob_id
    FROM pa_implementations;

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Sob_id is [' || TO_CHAR(g_sob_id) || ']' ;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file(l_proc_name|| ': ' || pa_debug.g_err_stage);
  END IF;

    /*
     * Select Expenditure_item_ids to process.
     *
     * We should get rid of this sql - because the columns selected here
     * can be received from the pro*C process as arrays.
     */
    l_stage := 200;
    pa_debug.g_err_stage := TO_CHAR(l_stage) || ': ORACLE error occurred Opening pa_bc_packet_cwk_cur.';
    OPEN pa_bc_packet_cwk_cur;
    /*
     * Resetting fetch-related variables.
     */
    l_this_fetch        := 0;
    l_totally_fetched   := 0;

    /*
     * Loop until all EIs are processed.
     */
    LOOP

    PA_DEBUG.g_err_stage := TO_CHAR(l_stage) || ': Fetching a Set of CDLs to Process.';
    IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_file(l_proc_name || ': ' || PA_DEBUG.g_err_stage);
    END IF;

      l_stage := 300;
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': ORACLE error occurred Fetching pa_bc_packet_cwk_cur.';
      FETCH pa_bc_packet_cwk_cur
       BULK COLLECT
         INTO l_expenditure_item_id_tab
             ,l_line_num_tab
             ,l_line_type_tab
             ,l_line_num_reversed_tab
             ,l_acct_raw_cost_tab
             ,l_denom_raw_cost_tab
             ,l_acct_burdened_cost_tab
             ,l_denom_burdened_cost_tab
             ,l_project_id_tab
             ,l_pa_date_tab
             ,l_gl_date_tab
             ,l_burden_sum_rej_code_tab
             ,l_burden_sum_source_run_id_tab
             ,l_ind_compiled_set_id_tab
             ,l_dr_code_combination_id_tab
             ,l_document_header_id_tab
             ,l_gl_period_name_tab
             ,l_expenditure_item_date_tab
             ,l_expenditure_type_tab
             ,l_task_id_tab
             ,l_document_line_id_tab
             ,l_exp_organization_id_tab
             ,l_org_id_tab
             ,l_burden_amt_disp_method_tab
             ,l_burden_cost_flag_tab
             ,l_budget_version_id_tab
	     ,l_pkt_reference1_Tab
	     ,l_pkt_reference2_Tab
	     ,l_pkt_reference3_Tab
       LIMIT l_bunch_size;

       /*==========================================+
        | Once fetched, reset l_ei_to_process_from |
        +==========================================*/
        l_ei_to_process_from := 0;

      l_this_fetch := pa_bc_packet_cwk_cur%ROWCOUNT - l_totally_fetched;
      l_totally_fetched := pa_bc_packet_cwk_cur%ROWCOUNT;
      l_totally_processed := l_totally_processed + l_this_fetch;

      PA_DEBUG.g_err_stage := TO_CHAR(l_stage) || ': Fetched [' || l_this_fetch || '] CDLs to process.';
      IF P_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.write_file(l_proc_name || ': ' || PA_DEBUG.g_err_stage);
      END IF;

      IF (l_this_fetch = 0) THEN
        PA_DEBUG.g_err_stage := TO_CHAR(l_stage) || ': No more CDLs to process. Exiting';
        IF P_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.write_file(l_proc_name || ': ' || PA_DEBUG.g_err_stage);
        END IF;
        x_return_status := 0;
        x_error_code := FND_API.G_RET_STS_SUCCESS;
        x_error_stage := l_stage;
        EXIT;
      END IF;
      /*
       * We got to ensure that all cdls of an ei end-up in the same packet.
       * For this, we are ordering the cursor by eiid and line_num.
       * Now we have fetched n number of CDLs.
       * -- If the nth CDL is a reversing one, (line_num_reversed <> NULL)
       *    then there should be a fresh CDL which we are missing. So,
       *    get that and append it to the current pl/sql table. And ensure
       *    that we dont get any cdl of this ei during the next fetch.
       * Assumption#1:- In-case of reversing CDL, Line_num for the fresh CDL
       *                is greater than the line_num of he reversing CDL.
       */
       IF (l_line_num_reversed_tab(l_this_fetch) IS NOT NULL )
       THEN
       /*
        * Get the Fresh line.
        */
       /*=========================================================+
        | Burdening Enhancements                                  |
        | o Funds Check both R and I lines.                       |
        | o Transfer Status Code P for R lines and G for I lines. |
        +=========================================================*/
         PA_DEBUG.g_err_stage := TO_CHAR(l_stage) || ': Fresh line Missing. Selecting Fresh line.';
         IF P_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.write_file(l_proc_name || ': ' || PA_DEBUG.g_err_stage);
         END IF;

         l_stage := 400;
         SELECT cdl.expenditure_item_id
               ,cdl.line_num
               ,cdl.line_type
               ,cdl.line_num_reversed
               ,DECODE(cdl.line_type, 'R', cdl.acct_raw_cost, cdl.acct_burdened_cost)
               ,DECODE(cdl.line_type, 'R', cdl.denom_raw_cost, cdl.denom_burdened_cost)
               ,cdl.acct_burdened_cost
               ,cdl.denom_burdened_cost
               ,cdl.project_id
               ,cdl.pa_date
               ,cdl.gl_date
               ,cdl.burden_sum_rejection_code
               ,cdl.burden_sum_source_run_id
               ,cdl.ind_compiled_set_id
               ,cdl.dr_code_combination_id
               ,TO_NUMBER(cdl.system_reference2)
               ,glp.period_name
               ,l_expenditure_item_date_tab(l_this_fetch)
               ,l_expenditure_type_tab(l_this_fetch)
               ,l_task_id_tab(l_this_fetch)
               ,l_document_line_id_tab(l_this_fetch)
               ,l_exp_organization_id_tab(l_this_fetch)
               ,l_org_id_tab(l_this_fetch)
               ,NVL(pt.burden_amt_display_method, 'S')
               ,NVL(pt.burden_cost_flag, 'N')
               ,bv.budget_version_id
		,'EXP'
		,cdl.expenditure_item_id
		,cdl.line_num
           INTO l_expenditure_item_id_tab(l_this_fetch+1)
               ,l_line_num_tab(l_this_fetch+1)
               ,l_line_type_tab(l_this_fetch+1)
               ,l_line_num_reversed_tab(l_this_fetch+1)
               ,l_acct_raw_cost_tab(l_this_fetch+1)
               ,l_denom_raw_cost_tab(l_this_fetch+1)
               ,l_acct_burdened_cost_tab(l_this_fetch+1)
               ,l_denom_burdened_cost_tab(l_this_fetch+1)
               ,l_project_id_tab(l_this_fetch+1)
               ,l_pa_date_tab(l_this_fetch+1)
               ,l_gl_date_tab(l_this_fetch+1)
               ,l_burden_sum_rej_code_tab(l_this_fetch+1)
               ,l_burden_sum_source_run_id_tab(l_this_fetch+1)
               ,l_ind_compiled_set_id_tab(l_this_fetch+1)
               ,l_dr_code_combination_id_tab(l_this_fetch+1)
               ,l_document_header_id_tab(l_this_fetch+1)
               ,l_gl_period_name_tab(l_this_fetch+1)
               ,l_expenditure_item_date_tab(l_this_fetch+1)
               ,l_expenditure_type_tab(l_this_fetch+1)
               ,l_task_id_tab(l_this_fetch+1)
               ,l_document_line_id_tab(l_this_fetch+1)
               ,l_exp_organization_id_tab(l_this_fetch+1)
               ,l_org_id_tab(l_this_fetch+1)
               ,l_burden_amt_disp_method_tab(l_this_fetch+1)
               ,l_burden_cost_flag_tab(l_this_fetch+1)
               ,l_budget_version_id_tab(l_this_fetch+1)
		,l_pkt_reference1_Tab(l_this_fetch+1)
		,l_pkt_reference2_Tab(l_this_fetch+1)
		,l_pkt_reference3_Tab(l_this_fetch+1)
           FROM pa_cost_distribution_lines_all cdl
               ,pa_project_types_all     pt
               ,pa_projects_all          p
               ,pa_budget_versions       bv
               ,pa_budgetary_control_options pbct
               ,gl_period_statuses       glp
          WHERE cdl.line_num_reversed IS NULL
            AND cdl.reversed_flag IS NULL
            AND cdl.request_id = g_request_id
            AND cdl.line_type in ('R', 'I')
            AND cdl.expenditure_item_id = l_expenditure_item_id_tab(l_this_fetch)
            AND p.project_id = cdl.project_id
            AND p.project_type = pt.project_type
            -- R12 AND NVL(pt.org_Id, -99) = NVL(p.org_Id, -99)
            AND pt.org_Id = p.org_Id
            AND glp.application_id = 101
            AND glp.set_of_books_id = g_sob_id
            AND  TRUNC(cdl.gl_date) between TRUNC(glp.START_DATE)  and TRUNC(glp.END_DATE)
            AND pbct.project_id = bv.project_id
            AND pbct.BDGT_CNTRL_FLAG = 'Y'
            AND pbct.BUDGET_TYPE_CODE = bv.budget_type_code
            AND (pbct.EXTERNAL_BUDGET_CODE = 'GL'
                 OR
                 pbct.EXTERNAL_BUDGET_CODE is NULL)
            AND bv.project_id = cdl.project_id
            AND bv.current_flag = 'Y'
            AND bv.budget_status_code = 'B'
            --FP M changes
            And adjustment_period_flag = 'N'   ;

         l_totally_processed := l_totally_processed + 1;
         /*================================================================+
          | l_ei_to_process_from is maintained to avoid fetching this EI   |
          | again during the next fetch.                                   |
          +================================================================*/
         l_ei_to_process_from := l_expenditure_item_id_tab(l_this_fetch);

         IF (l_debug_mode = 'Y')
         THEN
                pa_debug.g_err_stage := ' l_ei_to_process_from is [' || to_char(l_ei_to_process_from) || ']';
                pa_debug.write_file(l_proc_name || ': ' || pa_debug.g_err_stage);
         END IF;

         IF (l_debug_mode = 'Y')
         THEN
             pa_debug.g_err_stage := 'Fresh cdl [' || l_expenditure_item_id_tab(l_this_fetch+1) ||
                                   '] line_num [' || l_line_num_tab(l_this_fetch+1) ||
                                   '] line_type [' || l_line_type_tab(l_this_fetch+1) ||
                                   '] line_num_reversed [' || l_line_num_reversed_tab(l_this_fetch+1) ||
                                   '] p_id [' || l_project_id_tab(l_this_fetch+1) ||
                                   '] pa_date [' || l_pa_date_tab(l_this_fetch+1) ||
                                   '] gl_date [' || l_gl_date_tab(l_this_fetch+1) ||
                                   '] acct_rc [' || l_acct_raw_cost_tab(l_this_fetch+1) ||
                                   '] denom_rc [' || l_denom_raw_cost_tab(l_this_fetch+1) ||
                                   '] acct_bc [' || l_acct_burdened_cost_tab(l_this_fetch+1) ||
                                   '] burden_sum_rej_code [' || l_burden_sum_rej_code_tab(l_this_fetch+1) ||
                                   '] bssrid [' || l_burden_sum_source_run_id_tab(l_this_fetch+1) ||
                                   '] comp_set_id [' || l_ind_compiled_set_id_tab(l_this_fetch+1) ||
                                   ']';
             IF P_DEBUG_MODE = 'Y' THEN
                pa_debug.write_file(l_proc_name || ': ' || pa_debug.g_err_stage);
             END IF;
             pa_debug.g_err_stage := 'dr_ccid [' || l_dr_code_combination_id_tab(l_this_fetch+1) ||
                                   '] gl_p_name [' || l_gl_period_name_tab(l_this_fetch+1) ||
                                   '] etype [' || l_expenditure_type_tab(l_this_fetch+1) ||
                                   '] task_id [' || l_task_id_tab(l_this_fetch+1) ||
                                   '] po_line_id [' || l_document_line_id_tab(l_this_fetch+1) ||
                                   '] eorg_id [' || l_exp_organization_id_tab(l_this_fetch+1) ||
                                   '] org_id [' || l_org_id_tab(l_this_fetch+1) ||
                                   '] b_dsp_meth [' || l_burden_amt_disp_method_tab(l_this_fetch+1) ||
                                   '] b_version_id [' || l_budget_version_id_tab(l_this_fetch+1) ||
                                   '] burdened [' || l_burden_cost_flag_tab(l_this_fetch+1) ||
                                   ']';
             IF P_DEBUG_MODE = 'Y' THEN
                pa_debug.write_file(l_proc_name || ': ' || pa_debug.g_err_stage);
             END IF;
         END IF; -- debug mode?


       END IF; -- is the nth cdl a reversing one?

  /*
   * Printing fetched values.
   */
  IF (l_debug_mode = 'Y')
  THEN
    FOR i IN l_expenditure_item_id_tab.FIRST .. l_expenditure_item_id_tab.LAST
    LOOP
      pa_debug.g_err_stage := 'eiid [' || l_expenditure_item_id_tab(i) ||
                            '] line_num [' || l_line_num_tab(i) ||
                            '] line_type [' || l_line_type_tab(i) ||
                            '] line_num_reversed [' || l_line_num_reversed_tab(i) ||
                            '] p_id [' || l_project_id_tab(i) ||
                            '] pa_date [' || l_pa_date_tab(i) ||
                            '] gl_date [' || l_gl_date_tab(i) ||
                            '] acct_rc [' || l_acct_raw_cost_tab(i) ||
                            '] denom_rc [' || l_denom_raw_cost_tab(i) ||
                            '] acct_bc [' || l_acct_burdened_cost_tab(i) ||
                            '] burden_sum_rej_code [' || l_burden_sum_rej_code_tab(i) ||
                            '] bssrid [' || l_burden_sum_source_run_id_tab(i) ||
                            '] comp_set_id [' || l_ind_compiled_set_id_tab(i) ||
                            '] dr_ccid [' || l_dr_code_combination_id_tab(i) ||
                            '] gl_p_name [' || l_gl_period_name_tab(i) ||
                            '] etype [' || l_expenditure_type_tab(i) ||
                            '] task_id [' || l_task_id_tab(i) ||
                            '] po_line_id [' || l_document_line_id_tab(i) ||
                            '] eorg_id [' || l_exp_organization_id_tab(i) ||
                            '] org_id [' || l_org_id_tab(i) ||
                            '] b_dsp_meth [' || l_burden_amt_disp_method_tab(i) ||
                            '] b_version_id [' || l_budget_version_id_tab(i) ||
                            '] burdened [' || l_burden_cost_flag_tab(i) ||
                            '] header_id [' || l_document_header_id_tab(i) ||
                            '] line_id [' || l_document_line_id_tab(i) ||
                            ']';
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file(l_proc_name || ': ' || pa_debug.g_err_stage);
      END IF;

END LOOP;
  END IF; -- debug mode?

      /*
       * Get the Packet_id
       */
       PA_DEBUG.g_err_stage := TO_CHAR(l_stage) || ':Getting the packet_id.';
       IF P_DEBUG_MODE = 'Y' THEN
            pa_debug.write_file(l_proc_name || ': ' || pa_debug.g_err_stage);
       END IF;

      l_stage := 500;
      SELECT gl_bc_packets_s.NEXTVAL
        INTO g_packet_id
        FROM dual;

      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Packet_id is [' || TO_CHAR(g_packet_id) || ']' ;
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file(l_proc_name || ': ' || pa_debug.g_err_stage);
      END IF;

  /*==========================================================================+
   | Call Autonomous Procedure to insert the pl/sql tables into pa_bc_packets.|
   +==========================================================================*/
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Before Calling populate_pa_bc_packets.';
  IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file(l_proc_name || ': ' || pa_debug.g_err_stage);
  END IF;

  l_stage := 600;
  populate_pa_bc_packets_cwk( l_return_status
                             ,l_error_code
                             ,l_error_stage
                            );

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ': After calling populate_pa_bc_packets l_return_status = [' ||
                                                l_return_status || '] l_error_stage = [' || l_error_stage ||
                                               '] l_error_code = [' || l_error_code || ']' ;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file(l_proc_name || ':' || pa_debug.g_err_stage);
  END IF;

  /*========================+
   | Exception Processing.  |
   +========================*/
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    pa_debug.g_err_stage := 'Error occurred while call to populate_pa_bc_packets. x_return_status [' ||
                                                           l_return_status || ']';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file(l_proc_name || ':' || pa_debug.g_err_stage);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':After Inserting Records into PA_BC_PACKETS.';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file(l_proc_name || ':' || pa_debug.g_err_stage);
  END IF;

  /*=================================+
   | Reject EIs that have rejections |
   +=================================*/
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Rejecting EIs.' ;
  pa_debug.write_file(pa_debug.g_err_stage);

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':ORACLE error while rejecting EIs.' ;
  FORALL i IN l_expenditure_item_id_tab.FIRST .. l_expenditure_item_id_tab.LAST
  UPDATE pa_expenditure_items ei
     SET ei.cost_dist_rejection_code = l_rejn_code_tab(i)
   WHERE ei.expenditure_item_id = l_expenditure_item_id_tab(i)
     AND l_rejn_code_tab(i) IS NOT NULL;

  /*
   * This count does not represent the number of EIs updated because,
   * this table is for CDLs and can have more than one record for the same EI.
   */
  l_records_affected := SQL%ROWCOUNT ;

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Updated [' ||
                               TO_CHAR(l_records_affected) ||
                             '] records - this count is not right.';
           pa_debug.write_file(pa_debug.g_err_stage);
  /*===================+
   | Call FC API here. |
   +===================*/
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Calling FC API';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file(l_proc_name || ':' || pa_debug.g_err_stage);
  END IF;

  l_stage := 700;
  pa_debug.g_err_stage := 'Error Occurred during call to pa_funds_check.';
  IF( NOT pa_funds_control_pkg.pa_funds_check( l_calling_module    -- p_calling_module
                                              ,'Y'                 -- p_conc_flag
                                              ,g_sob_id            -- p_set_of_book_id
                                              ,g_packet_id         -- p_packet_id
                                              ,'R'                 -- p_mode
                                              ,'Y'                 -- p_partial_flag
                                              ,NULL                -- p_reference1
                                              ,NULL                -- p_reference2
                                              ,NULL                -- p_reference3
                                              ,l_return_status     -- x_return_status
                                              ,l_error_stage       -- x_error_stage
                                              ,l_error_code        -- x_error_msg
                                            ) )
  THEN
    pa_debug.g_err_stage := 'pa_funds_check returned FALSE.';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('costing_fc_proc: ' || pa_debug.g_err_stage);
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':After calling FC API l_return_status =[' || l_return_status ||
                                               '] l_error_stage = [' || l_error_stage ||
                                               '] l_error_code = [' || l_error_code || ']' ;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file(l_proc_name || ':' || pa_debug.g_err_stage);
  END IF;

  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Calling process_rejected_exp_items' ;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file(l_proc_name || ':' || pa_debug.g_err_stage);
  END IF;

  l_stage := 800;
  process_rejected_exp_items ( x_return_status   => l_return_status
                              ,x_error_code      => l_error_code
                              ,x_error_stage     => l_error_stage
                             );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Error while call to process_rejected_exp_items. x_return_status ['
                    || l_return_status || ']';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file(l_proc_name || ':' || pa_debug.g_err_stage);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  pa_debug.g_err_stage := 'After calling process_rejected_exp_items l_return_status =[' ||
                                                  l_return_status ||
                                               '] l_error_stage = [' || l_error_stage ||
                                               '] l_error_code = [' || l_error_code || ']' ;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file(l_proc_name || ': ' || TO_CHAR(l_stage) || ': ' || pa_debug.g_err_stage);
  END IF;

      /*
       * Calling FC ends here.
       */
      IF (l_this_fetch < l_bunch_size) THEN
        /*
         * Indicates last fetch.
         */
        pa_debug.g_err_stage := 'Finished Processing Last Fetch.';
        IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file(l_proc_name || ': ' || TO_CHAR(l_stage) || ': ' || pa_debug.g_err_stage);
        END IF;
        EXIT;
      END IF;
      /*========================+
       | Deleting plsql tables. |
       +========================*/

      pa_debug.g_err_stage := 'Deleting Pl/Sql tables......';
      IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file(l_proc_name || ': ' || TO_CHAR(l_stage) || ': ' || pa_debug.g_err_stage);
      END IF;

      l_stage := 900;
      l_expenditure_item_id_tab.DELETE;
      l_line_num_tab.DELETE;
      l_line_type_tab.DELETE;
      l_line_num_reversed_tab.DELETE;
      l_acct_raw_cost_tab.DELETE;
      l_denom_raw_cost_tab.DELETE;
      l_acct_burdened_cost_tab.DELETE;
      l_denom_burdened_cost_tab.DELETE;
      l_project_id_tab.DELETE;
      l_pa_date_tab.DELETE;
      l_gl_date_tab.DELETE;
      l_burden_sum_rej_code_tab.DELETE;
      l_burden_sum_source_run_id_tab.DELETE;
      l_ind_compiled_set_id_tab.DELETE;
      l_dr_code_combination_id_tab.DELETE;
      l_gl_period_name_tab.DELETE;
      l_expenditure_item_date_tab.DELETE;
      l_expenditure_type_tab.DELETE;
      l_task_id_tab.DELETE;
      l_exp_organization_id_tab.DELETE;
      l_org_id_tab.DELETE;
      l_burden_amt_disp_method_tab.DELETE;
      l_burden_cost_flag_tab.DELETE;
      l_budget_version_id_tab.DELETE;
      l_pkt_reference1_Tab.DELETE;
      l_pkt_reference2_Tab.DELETE;
      l_pkt_reference3_Tab.DELETE;

      pa_debug.g_err_stage := 'After Deleting Pl/Sql tables......';
      IF P_DEBUG_MODE = 'Y' THEN
             pa_debug.write_file(l_proc_name || ': ' || TO_CHAR(l_stage) || ': ' || pa_debug.g_err_stage);
      END IF;

      /*=================================================================+
       | If earlier fetch had a spill-over, close and reopen the cursor. |
       +=================================================================*/

      IF (l_ei_to_process_from > 0)
      THEN
           pa_debug.g_err_stage := TO_CHAR(l_stage) || 'closing cursor';
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file(l_proc_name || ': ' || TO_CHAR(l_stage) || ': ' || pa_debug.g_err_stage);
           END if;
           CLOSE pa_bc_packet_cwk_cur;

           l_this_fetch        := 0;
           l_totally_fetched   := 0;
           pa_debug.g_err_stage := 'Opening cursor - to process from [' ||
                                               to_char(l_ei_to_process_from) || ']';
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file(l_proc_name || ': ' || TO_CHAR(l_stage) || ': ' || pa_debug.g_err_stage);
           END IF;
           OPEN pa_bc_packet_cwk_cur;
      END IF;

    END LOOP; -- End of loop to insert total number records.

 pa_debug.g_err_stage := 'No. Of CDLs Totally fetched [' || TO_CHAR(l_totally_fetched) ||']';
 IF P_DEBUG_MODE = 'Y' THEN
    pa_debug.write_file(l_proc_name || ': ' || TO_CHAR(l_stage) || ': ' || pa_debug.g_err_stage);
 END IF;

  pa_debug.g_err_stage := 'Leaving costing_fc_proc_cwk';
  IF P_DEBUG_MODE = 'Y' THEN
    pa_debug.write_file(l_proc_name || ': ' || TO_CHAR(l_stage) || ': ' || pa_debug.g_err_stage);
  END IF;

  x_return_status := 0;
  pa_debug.reset_err_stack;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    IF P_DEBUG_MODE = 'Y' THEN
        pa_debug.write_file(l_proc_name || ': ' || TO_CHAR(l_stage) || ': ' || pa_debug.g_err_stage);
    END IF;
    x_return_status := -1;
    x_error_code    := pa_debug.g_err_stage ;
    x_error_stage   := to_char(l_stage) ;
  WHEN OTHERS
    THEN
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file(l_proc_name || ': EXCEPTION  ' || pa_debug.g_err_stage);
      END IF;

      pa_debug.g_err_stage := TO_CHAR(SQLCODE) || SQLERRM ;
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file(l_proc_name || ': EXCEPTION ' || pa_debug.g_err_stage);
      END IF;

      x_return_status := -1;
      x_error_code    := TO_CHAR(SQLCODE) || SQLERRM ;
      x_error_stage   := l_stage ;
END costing_fc_proc_cwk;
--------------------------------------------------------------------------------------
  PROCEDURE populate_pa_bc_packets_cwk( x_return_status  OUT NOCOPY NUMBER
                                       ,x_error_code     OUT NOCOPY VARCHAR2
                                       ,x_error_stage    OUT NOCOPY VARCHAR2
                                      )
  IS
      PRAGMA AUTONOMOUS_TRANSACTION;

     /*=============================+
      | PLSQL Table definitions     |
      +=============================*/
      l_ins_packet_id_tab                    PA_PLSQL_DATATYPES.IdTabTyp;
      l_ins_project_id_tab                   PA_PLSQL_DATATYPES.IdTabTyp;
      l_ins_task_id_tab                      PA_PLSQL_DATATYPES.IdTabTyp;
      l_ins_budget_version_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;
      l_ins_expenditure_type_tab             PA_PLSQL_DATATYPES.Char30TabTyp;
      l_ins_ei_date_tab                      PA_PLSQL_DATATYPES.DateTabTyp;
      l_ins_period_name_tab                  PA_PLSQL_DATATYPES.Char15TabTyp;
      l_ins_pa_date_tab                      PA_PLSQL_DATATYPES.DateTabTyp;
      l_ins_gl_date_tab                      PA_PLSQL_DATATYPES.DateTabTyp;
      l_ins_set_of_books_id_tab              PA_PLSQL_DATATYPES.IdTabTyp;
      l_ins_je_category_name_tab             PA_PLSQL_DATATYPES.Char80TabTyp;
      l_ins_je_source_name_tab               PA_PLSQL_DATATYPES.Char80TabTyp;
      l_ins_status_code_tab                  PA_PLSQL_DATATYPES.Char1TabTyp;
      l_ins_funds_process_mode_tab           PA_PLSQL_DATATYPES.Char1TabTyp;
      l_ins_burden_cost_flag_tab             PA_PLSQL_DATATYPES.Char1TabTyp;
      l_ins_expenditure_orgn_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
      l_ins_document_dist_id_tab             PA_PLSQL_DATATYPES.IdTabTyp;
      l_ins_txn_ccid_tab                     PA_PLSQL_DATATYPES.IdTabTyp;
      l_ins_bc_packet_id_tab                 PA_PLSQL_DATATYPES.IdTabTyp;
      l_ins_org_id_tab                       PA_PLSQL_DATATYPES.IdTabTyp;
      l_ins_balance_posted_flag_tab          PA_PLSQL_DATATYPES.Char1TabTyp;
      l_ins_document_type_tab                PA_PLSQL_DATATYPES.Char30TabTyp;
      l_ins_parent_bc_packet_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
      l_ins_document_header_id_tab           PA_PLSQL_DATATYPES.IdTabTyp;
      l_ins_document_line_id_tab             PA_PLSQL_DATATYPES.IdTabTyp;
      l_ins_entered_dr_tab                   PA_PLSQL_DATATYPES.NumTabTyp;
      l_ins_accounted_dr_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
      l_ins_exp_item_id_tab                  PA_PLSQL_DATATYPES.IdTabTyp;
      l_ins_rejn_code_tab                    PA_PLSQL_DATATYPES.Char80TabTyp;

      l_temp_Tot_Raw_Amt_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
      l_temp_Tot_Bd_Amt_tab                  PA_PLSQL_DATATYPES.NumTabTyp;
      l_temp_Raw_Amt_Relieved_tab            PA_PLSQL_DATATYPES.NumTabTyp;
      l_temp_Bd_Amt_Relieved_tab             PA_PLSQL_DATATYPES.NumTabTyp;
      l_temp_compiled_multiplier_tab         PA_PLSQL_DATATYPES.NumTabTyp;
      l_temp_parent_bc_packet_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
      l_temp_expenditure_type_tab            PA_PLSQL_DATATYPES.Char30TabTyp;
      l_temp_comm_source_tab                 PA_PLSQL_DATATYPES.Char30TabTyp;

      l_summ_project_id_tab                  PA_PLSQL_DATATYPES.IdTabTyp;
      l_summ_task_id_tab                     PA_PLSQL_DATATYPES.IdTabTyp;
      l_summ_document_header_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
      l_summ_document_line_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;
      l_summ_tot_raw_amt_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
      l_summ_tot_bd_amt_tab                  PA_PLSQL_DATATYPES.NumTabTyp;
      l_summ_raw_amt_relieved_tab            PA_PLSQL_DATATYPES.NumTabTyp;
      l_summ_bd_amt_relieved_tab             PA_PLSQL_DATATYPES.NumTabTyp;
      l_summ_compiled_multiplier_tab         PA_PLSQL_DATATYPES.NumTabTyp;
      l_summ_parent_bc_packet_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
      l_summ_expenditure_type_tab            PA_PLSQL_DATATYPES.Char30TabTyp;
      l_summ_source_tab                      PA_PLSQL_DATATYPES.Char30TabTyp;

      l_txn_burden_exp_type_tab              PA_PLSQL_DATATYPES.Char30TabTyp;
      l_txn_burden_comp_mult_tab             PA_PLSQL_DATATYPES.NumTabTyp;

      /*==================+
       | Scalar variables |
       +==================*/

       l_po_raw_bc_packet_id        pa_bc_packets.bc_packet_id%TYPE;
       l_exp_raw_bc_packet_id       pa_bc_packets.bc_packet_id%TYPE;
       l_cur_new_raw_amt_relieved   pa_bc_packets.entered_dr%TYPE;
       l_cur_new_bd_amt_relieved    pa_bc_packets.entered_dr%TYPE;
       l_debug_mode                 VARCHAR2(1);
       l_proc_name                  VARCHAR2(50) := 'populate_pa_bc_packets_cwk';
       l_i_raw_po_rec               NUMBER;
       l_records_affected           NUMBER := 0;
       l_stage                      VARCHAR2(300) ;
       i                            NUMBER := 0;
       j                            NUMBER := 0;
       ins_rec                      NUMBER := 0;
       i_summary                    NUMBER := 0;
       temp_rec                     NUMBER := 0;
       l_found                      BOOLEAN;

    /* Exceptions */

    USER_EXCEPTION         EXCEPTION;


        /*=============================================+
         | This routine is private for this procedure. |
         +=============================================*/
        PROCEDURE copy_common_attributes( i_source IN NUMBER
                                         ,i_dest   IN NUMBER
                                        )
        IS
        BEGIN
          l_ins_packet_id_tab(i_dest)             := g_packet_id;
          l_ins_project_id_tab(i_dest)            := l_project_id_tab(i_source);
          l_ins_task_id_tab(i_dest)               := l_task_id_tab(i_source);
          l_ins_budget_version_id_tab(i_dest)     := l_budget_version_id_tab(i_source);
          l_ins_expenditure_type_tab(i_dest)      := l_expenditure_type_tab(i_source);
          l_ins_ei_date_tab(i_dest)               := l_expenditure_item_date_tab(i_source);
          l_ins_period_name_tab(i_dest)           := l_gl_period_name_tab(i_source);
          l_ins_pa_date_tab(i_dest)               := l_pa_date_tab(i_source);
          l_ins_gl_date_tab(i_dest)               := l_gl_date_tab(i_source);
          l_ins_set_of_books_id_tab(i_dest)       := g_sob_id;
          l_ins_je_category_name_tab(i_dest)      := 'Project Accounting';
          l_ins_je_source_name_tab(i_dest)        := 'Expenditures';
          l_ins_status_code_tab(i_dest)           := 'P';
          l_ins_funds_process_mode_tab(i_dest)    := 'T' ;
          l_ins_burden_cost_flag_tab(i_dest)      := 'R';
          l_ins_expenditure_orgn_id_tab(i_dest)   := l_exp_organization_id_tab(i_source);
          l_ins_document_dist_id_tab(i_dest)      := l_line_num_tab(i_source);
          l_ins_txn_ccid_tab(i_dest)              := l_dr_code_combination_id_tab(i_source);
          l_ins_org_id_tab(i_dest)                := l_org_id_tab(i_source);
          l_ins_balance_posted_flag_tab(i_dest)   := 'N';

          l_ins_document_header_id_tab(i_dest) := l_document_header_id_tab(i_source);
          l_ins_document_line_id_tab(i_dest) := l_document_line_id_tab(i_source);
          l_ins_accounted_dr_tab(i_dest) := NULL;
          l_ins_entered_dr_tab(i_dest) := NULL;
          l_ins_parent_bc_packet_id_tab(i_dest) := NULL;
          l_ins_bc_packet_id_tab(i_dest) := NULL;
          l_ins_rejn_code_tab(i_dest) := NULL;
          l_ins_exp_item_id_tab(i_dest) := l_expenditure_item_id_tab(i_source) ;

        END ;

  BEGIN

  pa_debug.init_err_stack('pa_bc_costing.populate_pa_bc_packets_cwk');

  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
  l_debug_mode := NVL(l_debug_mode, 'Y');

  pa_debug.set_process('PLSQL','LOG',l_debug_mode);

  l_stage := l_proc_name || ': ' || to_char(100) || ': ';
  pa_debug.g_err_stage := 'From ' || l_proc_name ;
  pa_debug.write_file(l_stage || pa_debug.g_err_stage);

    /*==============================================================+
     | Summary records are cached incrementally for a batch of EIs. |
     | j - is the index for the summary tables.                     |
     +==============================================================*/
    j := 0;

    FOR i IN l_expenditure_item_id_tab.FIRST .. l_expenditure_item_id_tab.LAST
    LOOP

      pa_debug.g_err_stage := 'Processing EI [' || to_char(l_expenditure_item_id_tab(i)) ||
                             '] line [' || to_char(l_line_num_tab(i)) || ']';
      pa_debug.write_file(l_stage || pa_debug.g_err_stage);
      l_rejn_code_tab(i) := NULL;
      BEGIN
        /*========================================================+
         | Commitment amounts to be relieved only for first time  |
         | distribution.                                          |
         +========================================================*/
        IF ( l_line_num_tab(i) = 1 )
        THEN
             /*====================================================================+
              | Select summary information from either pa_bc_packets or            |
              | pa_bc_commitments_all. Populate the summary information into       |
              | host plsql tables.                                                 |
              | If the summary information of the current txn already exist in the |
              | plsql table, proceed with further processing. Otherwise get the    |
              | summary record from db and populate the plsql table.               |
              | o j holds the number of summary records in the plsql table.        |
              +====================================================================*/
             l_found := FALSE;
             FOR k IN 1 .. j
             LOOP
                  IF ( l_summ_project_id_tab(k) = l_project_id_tab(i) AND
                       l_summ_task_id_tab(k) = l_task_id_tab(i) AND
                       l_summ_document_header_id_tab(k) = l_document_header_id_tab(i) AND
                       l_summ_document_line_id_tab(k) = l_document_line_id_tab(i)
                     )
                  THEN
                         pa_debug.g_err_stage := 'Summary record found in Summary Cache';
                         pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                         i_summary := k;
                         l_found := TRUE;
                         EXIT;
                  END IF;
             END LOOP;
             /*============================================+
              | If the summary record is not available in  |
              | the plsql table, hit the db.               |
              +============================================*/
             IF (NOT l_found)
             THEN
                   pa_debug.g_err_stage := 'Hitting PA_BC_COMMITMENTS for Summary record R12';
                   pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                   BEGIN
                        SELECT pabcc.Comm_Tot_Raw_Amt
                              ,pabcc.Comm_Tot_Bd_Amt
                              ,pabcc.Comm_Raw_Amt_Relieved
                              ,pabcc.Comm_Bd_Amt_Relieved
                              ,pabcc.compiled_multiplier
                              ,pabcc.parent_bc_packet_id
                              ,pabcc.expenditure_type
                              ,'PA_BC_COMMITMENTS'
                          BULK COLLECT
                          INTO l_temp_Tot_Raw_Amt_tab
                              ,l_temp_Tot_Bd_Amt_tab
                              ,l_temp_Raw_Amt_Relieved_tab
                              ,l_temp_Bd_Amt_Relieved_tab
                              ,l_temp_compiled_multiplier_tab
                              ,l_temp_parent_bc_packet_id_tab
                              ,l_temp_expenditure_type_tab
                              ,l_temp_comm_source_tab
                          FROM pa_bc_commitments pabcc
                         WHERE pabcc.document_header_id = l_document_header_id_tab(i)
                           AND pabcc.document_line_id = l_document_line_id_tab(i)
                           AND pabcc.project_id = l_project_id_tab(i)
                           AND pabcc.task_id = l_task_id_tab(i)
                           AND ( (pabcc.parent_bc_packet_id IS NOT NULL AND pabcc.Comm_Tot_Bd_Amt <> 0)
                                 OR pabcc.parent_bc_packet_id IS NULL)
                           AND pabcc.summary_record_flag = 'Y';
                   EXCEPTION
                   WHEN OTHERS
                   THEN
                      RAISE;
                   END; -- anonymous block
                   /*=================================================+
                    | If a record is not found in pa_bc_commitments,  |
                    | try pa_bc_packets.                              |
                    +=================================================*/
                   /*=========================================+
                    | Bug 4230083 : Added 'C' to status_code. |
                    +=========================================*/
                   IF ( l_temp_Tot_Raw_Amt_tab.COUNT = 0 )
                   THEN
                        pa_debug.g_err_stage := 'Hitting PA_BC_PACKETS for Summary record';
                        pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                        BEGIN
                              SELECT pabc.Comm_Tot_Raw_Amt
                                    ,pabc.Comm_Tot_Bd_Amt
                                    ,pabc.Comm_Raw_Amt_Relieved
                                    ,pabc.Comm_Bd_Amt_Relieved
                                    ,pabc.compiled_multiplier
                                    ,pabc.parent_bc_packet_id
                                    ,pabc.expenditure_type
                                    ,'PA_BC_PACKETS'
                                BULK COLLECT
                                INTO l_temp_Tot_Raw_Amt_tab
                                    ,l_temp_Tot_Bd_Amt_tab
                                    ,l_temp_Raw_Amt_Relieved_tab
                                    ,l_temp_Bd_Amt_Relieved_tab
                                    ,l_temp_compiled_multiplier_tab
                                    ,l_temp_parent_bc_packet_id_tab
                                    ,l_temp_expenditure_type_tab
                                    ,l_temp_comm_source_tab
                                FROM pa_bc_packets pabc
                               WHERE pabc.document_header_id = l_document_header_id_tab(i)
                                 AND pabc.document_line_id = l_document_line_id_tab(i)
                                 AND pabc.project_id = l_project_id_tab(i)
                                 AND pabc.task_id = l_task_id_tab(i)
                                 AND ( (pabc.parent_bc_packet_id IS NOT NULL AND pabc.Comm_Tot_Bd_Amt <> 0)
                                       OR pabc.parent_bc_packet_id IS NULL)
                                 AND pabc.funds_process_mode = 'T'
                                 AND pabc.summary_record_flag = 'Y'
                                 AND pabc.status_code IN ('A', 'C');
                        EXCEPTION
                        WHEN OTHERS
                        THEN
                               RAISE;
                        END; -- anonymous block
                   END IF; -- record not found in pa_bc_commitments

             IF ( l_temp_Tot_Raw_Amt_tab.COUNT = 0 )
             THEN
                 pa_debug.g_err_stage := 'Summary record NOT found. Rejecting Transaction.';
                 pa_debug.log_message(p_message => PA_DEBUG.g_err_stage);
                 l_rejn_code_tab(i) := 'PA_FC_NDF';
                 pa_debug.g_err_stage := 'B4 raising exception' ;
                 pa_debug.log_message(p_message => PA_DEBUG.g_err_stage);
                 RAISE USER_EXCEPTION;
            END IF;

             FOR jj IN l_temp_Tot_Raw_Amt_tab.FIRST .. l_temp_Tot_Raw_Amt_tab.LAST
             LOOP
                 pa_debug.g_err_stage := 'no [' || to_char(jj) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_temp_Tot_Raw_Amt_tab [' || l_temp_Tot_Raw_Amt_tab(jj) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_temp_Tot_Bd_Amt_tab [' || to_char(l_temp_Tot_Bd_Amt_tab(jj)) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_temp_Raw_Amt_Relieved_tab [' || to_char(l_temp_Raw_Amt_Relieved_tab(jj)) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_temp_Bd_Amt_Relieved_tab [' || to_char(l_temp_Bd_Amt_Relieved_tab(jj)) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_temp_compiled_multiplier_tab [' || to_char(l_temp_compiled_multiplier_tab(jj)) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_temp_parent_bc_packet_id_tab [' || to_char(l_temp_parent_bc_packet_id_tab(jj)) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_temp_expenditure_type_tab [' || l_temp_expenditure_type_tab(jj) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_temp_comm_source_tab [' || l_temp_comm_source_tab(jj) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
             END LOOP;

             /*=======================================+
              | Append the contents of l_temp_ to the |
              | main table l_summ_                    |
              +=======================================*/
             FOR temp_rec IN l_temp_Tot_Raw_Amt_tab.FIRST .. l_temp_Tot_Raw_Amt_tab.LAST
             LOOP

                    /*======================================================+
                     | Insert the new summary record at the end of the main |
                     | summary plsql table                                  |
                     +======================================================*/
                    j := j + 1;

                    l_summ_project_id_tab(j)          := l_project_id_tab(i);
                    l_summ_task_id_tab(j)             := l_task_id_tab(i);
                    l_summ_document_header_id_tab(j)  := l_document_header_id_tab(i);
                    l_summ_document_line_id_tab(j)    := l_document_line_id_tab(i);

                    l_summ_tot_raw_amt_tab(j)         := l_temp_Tot_Raw_Amt_tab(temp_rec);
                    l_summ_tot_bd_amt_tab(j)          := l_temp_Tot_Bd_Amt_tab(temp_rec);
                    l_summ_raw_amt_relieved_tab(j)    := l_temp_Raw_Amt_Relieved_tab(temp_rec);
                    l_summ_bd_amt_relieved_tab(j)     := l_temp_Bd_Amt_Relieved_tab(temp_rec);
                    l_summ_compiled_multiplier_tab(j) := l_temp_compiled_multiplier_tab(temp_rec);
                    l_summ_parent_bc_packet_id_tab(j) := l_temp_parent_bc_packet_id_tab(temp_rec);
                    l_summ_expenditure_type_tab(j)    := l_temp_expenditure_type_tab(temp_rec);
                    l_summ_source_tab(j)              := l_temp_comm_source_tab(temp_rec);
             END LOOP; -- temp records
             FOR jj IN l_summ_project_id_tab.FIRST .. l_summ_project_id_tab.LAST
             LOOP
                 pa_debug.g_err_stage := 'no [' || to_char(jj) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);

                 pa_debug.g_err_stage := 'l_summ_project_id_tab [' || to_char(l_summ_project_id_tab(jj)) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_summ_task_id_tab [' || to_char(l_summ_task_id_tab(jj)) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_summ_document_header_id_tab [' || to_char(l_summ_document_header_id_tab(jj)) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_summ_document_line_id_tab [' || l_summ_document_line_id_tab(jj) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);

---------
                 pa_debug.g_err_stage := 'l_summ_tot_raw_amt_tab [' || to_char(l_summ_tot_raw_amt_tab(jj)) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_summ_tot_bd_amt_tab [' || to_char(l_summ_tot_bd_amt_tab(jj)) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_summ_raw_amt_relieved_tab [' || to_char(l_summ_raw_amt_relieved_tab(jj)) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_summ_bd_amt_relieved_tab [' || to_char(l_summ_bd_amt_relieved_tab(jj)) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_summ_compiled_multiplier_tab [' || to_char(l_summ_compiled_multiplier_tab(jj)) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_summ_parent_bc_packet_id_tab [' || to_char(l_summ_parent_bc_packet_id_tab(jj)) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_summ_expenditure_type_tab [' || l_summ_expenditure_type_tab(jj) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 pa_debug.g_err_stage := 'l_summ_source_tab [' || l_summ_source_tab(jj) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
             END LOOP;
             /*======================================================+
              | Note :- At this point all the needed summary records |
              | needed to process this transaction will be available |
              | in the l_summ_ group of tables.                      |
              | o l_summ_ is a repository of summary records.        |
              +======================================================*/

             /*=============================================+
              | Get the corresponding Raw summary record.   |
              +=============================================*/
             /**??????????see how we can avoid hitting the cache if the summary record is available in the l_temp_.........*/
             pa_debug.write_file('Probing Summary Cache.');
             l_found := FALSE;
             FOR summ_rec IN l_summ_project_id_tab.FIRST .. l_summ_project_id_tab.LAST
             LOOP
                        IF ( l_summ_project_id_tab(summ_rec) = l_project_id_tab(i) AND
                             l_summ_task_id_tab(summ_rec) = l_task_id_tab(i) AND
                             l_summ_document_header_id_tab(summ_rec) = l_document_header_id_tab(i) AND
                             l_summ_document_line_id_tab(summ_rec) = l_document_line_id_tab(i) AND
                             l_summ_parent_bc_packet_id_tab(summ_rec) IS NULL
                           )
                        THEN
                               pa_debug.write_file('Found record in Summary Cache.');
                               l_found := TRUE;
                               i_summary := summ_rec;
                               EXIT;
                        END IF;
             END LOOP;

             IF ( NOT l_found )
             THEN
                 pa_debug.g_err_stage := 'I just copied the summ records from DB to the cache. But now they are missing.. WIERD !!';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 l_rejn_code_tab(i) := 'PA_FC_NDF';
                 RAISE USER_EXCEPTION;
             END IF;
             END IF; -- summary record not found in cache.

             /*=========================================================+
              | Step 1 : Populate Raw PO relieving record.              |
              |                                                         |
              | Note :- ins_rec is the index for the plsql tables to be |
              |         inserted into pa_bc_packets.                    |
              +=========================================================*/
             pa_debug.g_err_stage := 'Inserting Raw PO relieving record.';
             pa_debug.write_file(l_stage || pa_debug.g_err_stage);
             ins_rec := ins_rec + 1;
             copy_common_attributes( i ,ins_rec );
             /*===========================================================+
              | Overriding what copy_common_attributes sets the value to. |
              | on Prithi's advice.                                       |
              +===========================================================*/
             l_ins_document_dist_id_tab(ins_rec)      := -9999;

             BEGIN
             pa_debug.g_err_stage := 'ORACLE error selecting sequence';
             SELECT pa_bc_packets_s.NEXTVAL
               INTO l_ins_bc_packet_id_tab(ins_rec)
               FROM DUAL;
             EXCEPTION
                WHEN OTHERS THEN
                       RAISE;
             END;

             l_ins_document_type_tab(ins_rec)       := 'PO';
             l_ins_expenditure_type_tab(ins_rec)    := l_expenditure_type_tab(i);
             l_ins_document_header_id_tab(ins_rec)  := l_document_header_id_tab(i);

             /*=====================================================================+
              | Store the bc_packet_id of this raw record so that it can be         |
              | populated to the parent_bc_packet_id column of the burden records.  |
              +=====================================================================*/
             l_po_raw_bc_packet_id := l_ins_bc_packet_id_tab(ins_rec);
             /*===============================================================+
              | l_i_raw_po_rec retains the position of the raw PO record.     |
              | This is used to reject the raw record - if the burden record  |
              | is not getting inserted for some rejection.                   |
              +===============================================================*/
             l_i_raw_po_rec := ins_rec;

             /*==============================================+
              | Calculate the effective relieval amounts.    |
              +==============================================*/
             l_cur_new_raw_amt_relieved := l_summ_raw_amt_relieved_tab(i_summary) +
                                                                l_acct_raw_cost_tab(i);
             pa_debug.g_err_stage := 'commited raw [' ||
                         to_char(l_summ_tot_raw_amt_tab(i_summary)) || '] old rlvd [' ||
                         to_char(l_summ_raw_amt_relieved_tab(i_summary)) || '] arc [' ||
                         to_char(l_acct_raw_cost_tab(i)) || '] new rlvd [' ||
                         to_char(l_cur_new_raw_amt_relieved) ||  ']';
             pa_debug.write_file(l_stage || pa_debug.g_err_stage);
             /*====================================+
              | Do not relieve more than commited. |
              +====================================*/
             /*============================================================================+
              | Bug 3826077 : Adding the ABS() check. Please refer the bug for more info.  |
              +============================================================================*/
             IF ( ABS(l_cur_new_raw_amt_relieved) > ABS(l_summ_tot_raw_amt_tab(i_summary)) )
             THEN
                 l_ins_entered_dr_tab(ins_rec) := (l_summ_tot_raw_amt_tab(i_summary) -
                                                                 l_summ_raw_amt_relieved_tab(i_summary)) * -1;
                 l_ins_accounted_dr_tab(ins_rec) := l_ins_entered_dr_tab(ins_rec);
                 l_summ_raw_amt_relieved_tab(i_summary) := l_summ_tot_raw_amt_tab(i_summary);
                 pa_debug.g_err_stage := 'amt being relieved [' ||
                         to_char(l_ins_entered_dr_tab(ins_rec)) || ']';
             ELSE
                 l_ins_entered_dr_tab(ins_rec) := l_acct_raw_cost_tab(i) * -1;
                 l_ins_accounted_dr_tab(ins_rec) := l_ins_entered_dr_tab(ins_rec);
                 l_summ_raw_amt_relieved_tab(i_summary) := l_cur_new_raw_amt_relieved;
                 pa_debug.g_err_stage := 'amt being relieved [' ||
                         to_char(l_ins_entered_dr_tab(ins_rec)) || ']';
             END IF;

             /*===============================================================+
              | Step 2a : Populate Burden PO record. (Same line burdening)    |
              |                                                               |
              | Note :- The burden records for PO type should be will always  |
              |         be inserted by the distribution process.              |
              +===============================================================*/
             IF ( l_burden_cost_flag_tab(i) = 'Y' AND
                  l_burden_amt_disp_method_tab(i) = 'S' AND
                  l_line_type_tab(i) <> 'I'
                )
             THEN
                 ins_rec := ins_rec + 1;
                 pa_debug.g_err_stage := 'Inserting Burd PO rec. Same line burd. ins_rec is [' || to_char(ins_rec) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 copy_common_attributes( i ,ins_rec );
                 /*===========================================================+
                  | Overriding what copy_common_attributes sets the value to. |
                  | on Prithi's advice.                                       |
                  +===========================================================*/
                 l_ins_document_dist_id_tab(ins_rec)      := -9999;

                 BEGIN
                      SELECT pa_bc_packets_s.NEXTVAL
                        INTO l_ins_bc_packet_id_tab(ins_rec)
                        FROM DUAL;
                 EXCEPTION
                          WHEN OTHERS THEN RAISE;
                 END;

                 l_ins_document_type_tab(ins_rec)       := 'PO';
                 l_ins_expenditure_type_tab(ins_rec)    := l_expenditure_type_tab(i_summary);
                 l_ins_parent_bc_packet_id_tab(ins_rec) := l_po_raw_bc_packet_id;

                 /*===========================================================+
                  | Calculate the amount to be relieved and the amount used   |
                  | to updated on the column Comm_Raw_Amt_Relieved.           |
                  +===========================================================*/
                 l_cur_new_bd_amt_relieved := l_summ_bd_amt_relieved_tab(i_summary) +
                                               (l_acct_raw_cost_tab(i) * l_summ_compiled_multiplier_tab(i_summary));
                 pa_debug.g_err_stage := 'commited bd [' ||
                    to_char(l_summ_tot_bd_amt_tab(i_summary)) || '] old rlvd [' ||
                    to_char(l_summ_bd_amt_relieved_tab(i_summary)) || '] bc [' ||
                    to_char(l_acct_raw_cost_tab(i) * l_summ_compiled_multiplier_tab(i_summary))
                    || '] new rlvd [' || to_char(l_cur_new_bd_amt_relieved) || ']';
                 pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 /*====================================+
                  | Do not relieve more than commited. |
                  +====================================*/
                /*============================================================================+
                 | Bug 3826077 : Adding the ABS() check. Please refer the bug for more info.  |
                 +============================================================================*/
                 IF ( ABS(l_cur_new_bd_amt_relieved) > ABS(l_summ_tot_bd_amt_tab(i_summary)) )
                 THEN
                     l_ins_entered_dr_tab(ins_rec) := (l_summ_tot_bd_amt_tab(i_summary) -
                                                                   l_summ_bd_amt_relieved_tab(i_summary)) * -1;
                     l_ins_accounted_dr_tab(ins_rec) := l_ins_entered_dr_tab(ins_rec);
                     l_summ_bd_amt_relieved_tab(i_summary) := l_summ_tot_bd_amt_tab(i_summary);
                     pa_debug.g_err_stage := 'amt rlvd [' ||
                           to_char(l_ins_entered_dr_tab(ins_rec)) || ']';
                     pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 ELSE
                     l_ins_entered_dr_tab(ins_rec) := (l_acct_raw_cost_tab(i) *
                                                                  l_summ_compiled_multiplier_tab(i_summary)) * -1;
                     l_ins_accounted_dr_tab(ins_rec) := l_ins_entered_dr_tab(ins_rec);
                     l_summ_bd_amt_relieved_tab(i_summary) := l_cur_new_bd_amt_relieved;
                     pa_debug.g_err_stage := 'amt rlvd [' ||
                           to_char(l_ins_entered_dr_tab(ins_rec)) || ']';
                     pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                 END IF;
             END IF; -- Same line burdening
         END IF; -- line num 1

         /*=====================================================================+
          | If Separate line burdening, get the burden cost codes.              |
          | This segment of code has to be executed - irrespective relieving PO |
          | lines getting inserted. This is because, the burden expenditure     |
          | types and multipliers are needed to insert funds-check lines.       |
          +=====================================================================*/
         IF ( l_burden_cost_flag_tab(i) = 'Y' AND
              l_burden_amt_disp_method_tab(i) = 'D' AND
              l_line_type_tab(i) <> 'I'
            )
         THEN
             pa_debug.g_err_stage := 'Separate line burdening - hitting burdening datamodel';
             pa_debug.write_file(l_stage || pa_debug.g_err_stage);
             SELECT icc.expenditure_type
                   ,cm.compiled_multiplier
                    BULK COLLECT INTO
                    l_txn_burden_exp_type_tab
                   ,l_txn_burden_comp_mult_tab
               FROM PA_IND_COST_CODES ICC
                   ,PA_COMPILED_MULTIPLIERS CM
                   ,PA_IND_COMPILED_SETS ICS
                   ,PA_COST_BASE_EXP_TYPES CBET
                   ,PA_COST_BASES CB
                   ,PA_IND_RATE_SCH_REVISIONS IRSR
                   ,PA_IND_RATE_SCHEDULES_ALL_BG IRS
               WHERE ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id
                 AND irs.ind_rate_sch_id          = irsr.ind_rate_sch_id
                 AND irsr.cost_plus_structure     = cbet.cost_plus_structure
                 AND cbet.cost_base               = cm.cost_base
                 AND cb.cost_base                 = cbet.cost_base
                 AND cb.cost_base_type            = cbet.cost_base_type
                 AND cbet.cost_base_type          = 'INDIRECT COST'
                 AND cbet.expenditure_type        = l_expenditure_type_tab(i)
                 AND ics.organization_id          = l_exp_organization_id_tab(i)
                 AND ics.cost_base                = cbet.cost_base
                 AND ics.ind_compiled_set_id      = l_ind_compiled_set_id_tab(i)
                 AND icc.ind_cost_code            = cm.ind_cost_code
                 AND cm.ind_compiled_set_id       = l_ind_compiled_set_id_tab(i)
                 AND l_burden_sum_rej_code_tab(i)  IS NULL
                 AND l_burden_sum_source_run_id_tab(i) = -9999
                 AND l_burden_amt_disp_method_tab(i)  = 'D'
                 AND l_burden_cost_flag_tab(i)        = 'Y'
              ;
             pa_debug.g_err_stage := 'This txn has [' || TO_CHAR(SQL%ROWCOUNT) || '] Burden Cost Code(s).';
             pa_debug.write_file(l_stage || pa_debug.g_err_stage);
       END IF; -- Separate line burdening

       /*=========================================================+
        | Relieve the PO commitment if first time distribution.   |
        +=========================================================*/
       IF (l_line_num_tab(i) = 1)
       THEN
         IF ( l_burden_cost_flag_tab(i) = 'Y' AND
              l_burden_amt_disp_method_tab(i) = 'D'
            )
         THEN
             /*==============================================================+
              | Make sure there are matching PA burden cost code records for |
              | all commitment summary lines.                                |
              +==============================================================*/
              FOR summ_line IN l_summ_project_id_tab.FIRST .. l_summ_project_id_tab.LAST
              LOOP

		IF  l_txn_burden_exp_type_tab.COUNT <> 0 THEN  /* Bug 3974799 */

                  FOR sep_burden IN l_txn_burden_exp_type_tab.FIRST .. l_txn_burden_exp_type_tab.LAST
                  LOOP
                      pa_debug.g_err_stage := 'et [' || l_txn_burden_exp_type_tab(sep_burden) || ']';
                      pa_debug.write_file(pa_debug.g_err_stage);
                  END LOOP;

                END IF; /* Bug 3974799 */

                /*========================================+
                 | Bug 3801932 : Check only burden lines. |
                 +========================================*/
                IF ( l_summ_parent_bc_packet_id_tab(summ_line) IS NOT NULL )
                THEN
                  l_found := FALSE;

 		  IF  l_txn_burden_exp_type_tab.COUNT <> 0 THEN /* Bug 3974799 */
		    FOR sep_burden IN l_txn_burden_exp_type_tab.FIRST .. l_txn_burden_exp_type_tab.LAST
                    LOOP
                        pa_debug.g_err_stage := 'comparing summ et ['
                                   || l_summ_expenditure_type_tab(summ_line) || '] with txn et ['
                                   || l_txn_burden_exp_type_tab(sep_burden) || ']';
                        pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                        IF ( l_summ_project_id_tab(summ_line) = l_project_id_tab(i) AND
                             l_summ_task_id_tab(summ_line) = l_task_id_tab(i) AND
                             l_summ_document_header_id_tab(summ_line) = l_document_header_id_tab(i) AND
                             l_summ_document_line_id_tab(summ_line) = l_document_line_id_tab(i) AND
                             l_summ_expenditure_type_tab(summ_line) = l_txn_burden_exp_type_tab(sep_burden) AND
                             l_summ_tot_bd_amt_tab(summ_line) <> 0
                           )
                        THEN
                             pa_debug.g_err_stage := 'match';
                             pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                             l_found := TRUE;
                             EXIT; -- PA Burden cost codes loop
                        ELSE
                             pa_debug.g_err_stage := 'no match';
                             pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                             l_found := FALSE;
                        END IF;
                    END LOOP; --  PA burden cost code records
                  END IF; -- l_summ_parent_bc_packet_id_tab(summ_line) IS NOT NULL
                END IF;  /* Bug 3974799 */
              END LOOP; -- commitment summary lines
              /*==========================================================================+
               | At this point, if l_found is FALSE, then, one of the summary records     |
               | does not have a matching PA record. Reject the transaction.              |
               +==========================================================================*/

	      IF ( NOT l_found )
              THEN
                  l_rejn_code_tab(i) := 'PA_TXN_COMM_BCC_NO_MATCH';
                  /*stop the raw relieving line getting inserted*/
                  l_ins_rejn_code_tab(l_i_raw_po_rec) := 'PA_TXN_COMM_BCC_NO_MATCH';
                  pa_debug.g_err_stage := 'Matching BCC record missing. Rejecting';
                  pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                  RAISE USER_EXCEPTION;
              END IF;
              /*=============================================+
               | Inserting Funds PO relieving Burden Record. |
               +=============================================*/
              FOR summ_line IN l_summ_project_id_tab.FIRST .. l_summ_project_id_tab.LAST
              LOOP
                IF ( l_summ_project_id_tab(summ_line) = l_project_id_tab(i) AND
                     l_summ_task_id_tab(summ_line) = l_task_id_tab(i) AND
                     l_summ_document_header_id_tab(summ_line) = l_document_header_id_tab(i) AND
                     l_summ_document_line_id_tab(summ_line) = l_document_line_id_tab(i) AND
                     l_summ_parent_bc_packet_id_tab(summ_line) IS NOT NULL AND
                     l_summ_tot_bd_amt_tab(summ_line) <> 0
                   )
                THEN
                  ins_rec := ins_rec + 1;
                  pa_debug.g_err_stage := 'Inserting sep line PO relieving. ins_rec is [' || to_char(ins_rec) || ']';
                  pa_debug.write_file(l_stage || pa_debug.g_err_stage);
                  copy_common_attributes( i ,ins_rec );
                  /*===========================================================+
                   | Overriding what copy_common_attributes sets the value to. |
                   | on Prithi's advice.                                       |
                   +===========================================================*/
                  l_ins_document_dist_id_tab(ins_rec)      := -9999;
                  BEGIN
                       SELECT pa_bc_packets_s.NEXTVAL
                         INTO l_ins_bc_packet_id_tab(ins_rec)
                         FROM DUAL;
                  EXCEPTION
                         WHEN OTHERS THEN RAISE;
                  END;
                  l_ins_document_type_tab(ins_rec)       := 'PO';
                  l_ins_expenditure_type_tab(ins_rec)    := l_summ_expenditure_type_tab(summ_line);
                  l_ins_parent_bc_packet_id_tab(ins_rec) := l_po_raw_bc_packet_id;

                  l_cur_new_bd_amt_relieved := l_summ_bd_amt_relieved_tab(summ_line) +
                                                 ( l_acct_raw_cost_tab(i) *
                                                 l_summ_compiled_multiplier_tab(summ_line) );

                  /*====================================+
                   | Do not relieve more than commited. |
                   +====================================*/
                 /*============================================================================+
                  | Bug 3826077 : Adding the ABS() check. Please refer the bug for more info.  |
                  +============================================================================*/
                  IF ( ABS(l_cur_new_bd_amt_relieved) > ABS(l_summ_tot_bd_amt_tab(summ_line)) )
                  THEN
                       l_ins_entered_dr_tab(ins_rec) := ( l_summ_tot_bd_amt_tab(summ_line) -
                                                       l_temp_Bd_Amt_Relieved_tab(summ_line) ) * -1;
                       l_ins_accounted_dr_tab(ins_rec) := l_ins_entered_dr_tab(ins_rec);
                       l_summ_bd_amt_relieved_tab(i_summary) := l_summ_tot_bd_amt_tab(summ_line);
                  ELSE
                       l_ins_entered_dr_tab(ins_rec) := ( l_acct_raw_cost_tab(i) *
                                                     l_summ_compiled_multiplier_tab(summ_line) ) * -1;
                       l_ins_accounted_dr_tab(ins_rec) := l_ins_entered_dr_tab(ins_rec);
                       l_summ_bd_amt_relieved_tab(i_summary) := l_cur_new_bd_amt_relieved;
                  END IF; -- Do not relieve more than commited.
                END IF; -- check if the summary belongs to this txn.
              END LOOP; -- summary lines
           END IF; -- separate line burdening
      END IF; -- line_num = 1

      /*==============================+
       | Populate Raw EXP record.     |
       +==============================*/
      IF( l_line_type_tab(i) <> 'I')
      THEN
          ins_rec := ins_rec + 1;
          pa_debug.g_err_stage := 'Inserting raw EXP record ins_rec is [' || to_char(ins_rec) || ']';
          pa_debug.write_file(l_stage || pa_debug.g_err_stage);
          copy_common_attributes( i ,ins_rec );
          BEGIN
                 SELECT pa_bc_packets_s.NEXTVAL
                   INTO l_ins_bc_packet_id_tab(ins_rec)
                   FROM DUAL;
          EXCEPTION
                WHEN OTHERS THEN RAISE;
          END;
          l_ins_document_type_tab(ins_rec)       := 'EXP';
          IF ( l_line_num_reversed_tab(i) IS NOT NULL )
          THEN
                l_ins_parent_bc_packet_id_tab(ins_rec) := NULL;
          ELSE
                l_ins_parent_bc_packet_id_tab(ins_rec) := -1;
          END IF;
          l_ins_document_header_id_tab(ins_rec)  := l_expenditure_item_id_tab(i);

          l_exp_raw_bc_packet_id := l_ins_bc_packet_id_tab(ins_rec);

          l_ins_entered_dr_tab(ins_rec)   := l_acct_raw_cost_tab(i);
          l_ins_accounted_dr_tab(ins_rec) := l_ins_entered_dr_tab(ins_rec);
      END IF;  -- line type I check

      /*==========================================+
       | Populate Same line burden record. (EXP)  |
       +==========================================*/
      IF ( l_burden_cost_flag_tab(i) = 'Y' AND
           l_burden_amt_disp_method_tab(i) = 'S' AND
           (l_line_num_reversed_tab(i) IS NOT NULL OR l_line_type_tab(i) = 'I')
         )
      THEN
          ins_rec := ins_rec + 1;
          pa_debug.g_err_stage := 'inserting burden same line exp record ins_rec is [' || to_char(ins_rec) || ']';
          pa_debug.write_file(l_stage || pa_debug.g_err_stage);
          copy_common_attributes( i ,ins_rec );
          BEGIN
                SELECT pa_bc_packets_s.NEXTVAL
                  INTO l_ins_bc_packet_id_tab(ins_rec)
                  FROM DUAL;
          EXCEPTION
               WHEN OTHERS THEN RAISE;
          END;

          l_ins_document_type_tab(ins_rec)       := 'EXP';
          IF ( l_line_type_tab(i) = 'I' )
          THEN
             l_ins_parent_bc_packet_id_tab(ins_rec) := NULL;
             l_ins_entered_dr_tab(ins_rec) := l_acct_burdened_cost_tab(i);
          ELSE
             l_ins_parent_bc_packet_id_tab(ins_rec) := l_exp_raw_bc_packet_id;
             l_ins_entered_dr_tab(ins_rec) := (l_acct_burdened_cost_tab(i) - l_acct_raw_cost_tab(i));
          END IF;
          l_ins_document_header_id_tab(ins_rec)  := l_expenditure_item_id_tab(i);

          l_ins_accounted_dr_tab(ins_rec) := l_ins_entered_dr_tab(ins_rec);
      END IF; -- Same line Burdening

      /*==============================================+
       | Populate Separate line burden record. (EXP)  |
       +==============================================*/
      IF ( l_burden_cost_flag_tab(i) = 'Y' AND
           l_burden_amt_disp_method_tab(i) = 'D' AND
           l_line_num_reversed_tab(i) IS NOT NULL
         )
      THEN
	IF  l_txn_burden_exp_type_tab.COUNT <> 0 THEN  /* Bug 3974799 */

          FOR sep_burden IN l_txn_burden_exp_type_tab.FIRST .. l_txn_burden_exp_type_tab.LAST
          LOOP
              ins_rec := ins_rec + 1;
              pa_debug.write_file('inserting burden sep line exp record ins_rec is [' || to_char(ins_rec) || ']');
              copy_common_attributes( i ,ins_rec );
              BEGIN
                      SELECT pa_bc_packets_s.NEXTVAL
                        INTO l_ins_bc_packet_id_tab(ins_rec)
                        FROM DUAL;
              EXCEPTION
                     WHEN OTHERS THEN RAISE;
              END;
              l_ins_expenditure_type_tab(ins_rec) := l_txn_burden_exp_type_tab(sep_burden);
              l_ins_document_type_tab(ins_rec) := 'EXP';
              l_ins_parent_bc_packet_id_tab(ins_rec) := l_exp_raw_bc_packet_id;
              l_ins_document_header_id_tab(ins_rec) := l_expenditure_item_id_tab(i);

              l_ins_entered_dr_tab(ins_rec) := l_acct_raw_cost_tab(i) *
                                                             l_txn_burden_comp_mult_tab(sep_burden);
              l_ins_accounted_dr_tab(ins_rec) := l_ins_entered_dr_tab(ins_rec);
          END LOOP; -- sep_burden
	END IF; /* Bug 3974799 */
      END IF; -- separate line burdening
     /*==================================================+
      | Delete all plsql tables that are used per loop.  |
      +==================================================*/
     l_temp_Tot_Raw_Amt_tab.DELETE;
     l_temp_Tot_Bd_Amt_tab.DELETE;
     l_temp_Raw_Amt_Relieved_tab.DELETE;
     l_temp_Bd_Amt_Relieved_tab.DELETE;
     l_temp_compiled_multiplier_tab.DELETE;
     l_temp_parent_bc_packet_id_tab.DELETE;
     l_temp_expenditure_type_tab.DELETE;
     l_temp_comm_source_tab.DELETE;
     l_txn_burden_exp_type_tab.DELETE;
     l_txn_burden_comp_mult_tab.DELETE;

       EXCEPTION
         WHEN USER_EXCEPTION
               THEN
                      pa_debug.g_err_stage := 'From User Exception handler' ;
                      pa_debug.log_message(p_message => PA_DEBUG.g_err_stage);
                      NULL;
         WHEN OTHERS
               THEN
                      RAISE;
       END; -- anonymous block
    END LOOP; -- for all records

    pa_debug.g_err_stage := 'Before debug for loop ' ;
    pa_debug.log_message(p_message => PA_DEBUG.g_err_stage);

    IF ( l_ins_packet_id_tab.COUNT > 0 )
    THEN

    FOR ins_rec IN l_ins_packet_id_tab.FIRST .. l_ins_packet_id_tab.LAST
    LOOP
                pa_debug.g_err_stage := 'Before inserting record [' || to_char(ins_rec)
                || '] l_ins_packet_id_tab [' || to_char(l_ins_packet_id_tab(ins_rec))
                || '] l_ins_project_id_tab [' || to_char(l_ins_project_id_tab(ins_rec))
                || '] l_ins_task_id_tab [' || to_char(l_ins_task_id_tab(ins_rec))
                || '] l_ins_budget_version_id_tab [' || to_char(l_ins_budget_version_id_tab(ins_rec))
                || '] l_ins_expenditure_type_tab [' || l_ins_expenditure_type_tab(ins_rec)
                || '] l_ins_ei_date_tab [' || to_char(l_ins_ei_date_tab(ins_rec))
                || '] l_ins_period_name_tab [' || l_ins_period_name_tab(ins_rec)
                || '] l_ins_pa_date_tab [' || to_char(l_ins_pa_date_tab(ins_rec))
                || '] l_ins_gl_date_tab [' || to_char(l_ins_gl_date_tab(ins_rec))
                || '] l_ins_set_of_books_id_tab [' || to_char(l_ins_set_of_books_id_tab(ins_rec))
                || '] l_ins_je_category_name_tab [' || l_ins_je_category_name_tab(ins_rec)
                || '] l_ins_je_source_name_tab [' || l_ins_je_source_name_tab(ins_rec)
                || '] l_ins_status_code_tab [' || l_ins_status_code_tab(ins_rec)
                || '] l_ins_document_type_tab [' || l_ins_document_type_tab(ins_rec)
                || ']';
                    pa_debug.write_file(pa_debug.g_err_stage);
                pa_debug.g_err_stage := 'Before inserting record [' || to_char(ins_rec)
                || '] l_ins_funds_process_mode_tab [' || l_ins_funds_process_mode_tab(ins_rec)
                || '] l_ins_burden_cost_flag_tab [' || l_ins_burden_cost_flag_tab(ins_rec)
                || '] l_ins_expenditure_orgn_id_tab [' || to_char(l_ins_expenditure_orgn_id_tab(ins_rec))
                || '] l_ins_document_header_id_tab [' || to_char(l_ins_document_header_id_tab(ins_rec))
                || '] l_ins_document_line_id_tab [' || to_char(l_ins_document_line_id_tab(ins_rec))
                || '] l_ins_document_dist_id_tab [' || to_char(l_ins_document_dist_id_tab(ins_rec))
                || '] l_ins_txn_ccid_tab [' || to_char(l_ins_txn_ccid_tab(ins_rec))
                || '] l_ins_burden_cost_flag_tab [' || l_ins_burden_cost_flag_tab(ins_rec)
                || '] l_ins_balance_posted_flag_tab [' || l_ins_balance_posted_flag_tab(ins_rec)
                || ']';
                    pa_debug.write_file(pa_debug.g_err_stage);

                pa_debug.g_err_stage := 'l_ins_accounted_dr_tab [' || to_char(l_ins_accounted_dr_tab(ins_rec)) || ']';
                    pa_debug.write_file(pa_debug.g_err_stage);
                pa_debug.g_err_stage := 'l_ins_entered_dr_tab [' || to_char(l_ins_entered_dr_tab(ins_rec)) || ']';
                    pa_debug.write_file(pa_debug.g_err_stage);
                pa_debug.g_err_stage := 'l_ins_bc_packet_id_tab [' || to_char(l_ins_bc_packet_id_tab(ins_rec)) || ']';
                    pa_debug.write_file(pa_debug.g_err_stage);
                pa_debug.g_err_stage := 'l_ins_parent_bc_packet_id_tab [' || to_char(l_ins_parent_bc_packet_id_tab(ins_rec)) || ']';
                    pa_debug.write_file(pa_debug.g_err_stage);
                pa_debug.g_err_stage := 'l_ins_org_id_tab [' || to_char(l_ins_org_id_tab(ins_rec)) || ']';
                    pa_debug.write_file(pa_debug.g_err_stage);
                pa_debug.g_err_stage := 'l_ins_exp_item_id_tab [' || to_char(l_ins_exp_item_id_tab(ins_rec)) || ']';
                    pa_debug.write_file(pa_debug.g_err_stage);
 END LOOP;
         END IF;
    /*==================================+
     | Insert into pa_bc_packets.       |
     +==================================*/
       /* ?????????? This IF is added because the update gives numeric/value error
        * when there are no records to insert. Ideally this should not happen. This
        * has to be figured out. ??????????????????
        */
      IF ( l_ins_packet_id_tab.COUNT > 0)
      THEN
    pa_debug.g_err_stage := 'Before inserting into pa_bc_pacets';
    pa_debug.write_file(l_stage || pa_debug.g_err_stage);

    pa_debug.g_err_stage := 'ORACLE error while Inserting PA_BC_PACKETS.' ;
    FORALL ins_rec IN l_ins_packet_id_tab.FIRST .. l_ins_packet_id_tab.LAST
    INSERT
      INTO pa_bc_packets( packet_id
                         ,project_id
                         ,task_id
                         ,budget_version_id
                         ,expenditure_type
                         ,expenditure_item_date
                         ,period_name
                         ,pa_date
                         ,gl_date
                         ,set_of_books_id
                         ,je_category_name
                         ,je_source_name
                         ,status_code
                         ,document_type
                         ,funds_process_mode
                         ,burden_cost_flag
                         ,expenditure_organization_id
                         ,document_header_id
                         ,document_line_id
                         ,document_distribution_id
                         ,txn_ccid
                         ,accounted_dr
                         ,entered_dr
                         ,bc_packet_id
                         ,parent_bc_packet_id
                         ,org_id
                         ,balance_posted_flag
                         ,exp_item_id
                         ,program_id
                         ,program_application_id
                         ,program_update_date
                         ,last_update_date
                         ,last_updated_by
                         ,created_by
                         ,creation_date
                         ,last_update_login
                         ,request_id
			 ,reference1
			 ,reference2
			 ,reference3
			 ,actual_flag -- Bug 5494476
                        )
    SELECT l_ins_packet_id_tab(ins_rec)
          ,l_ins_project_id_tab(ins_rec)
          ,l_ins_task_id_tab(ins_rec)
          ,l_ins_budget_version_id_tab(ins_rec)
          ,l_ins_expenditure_type_tab(ins_rec)
          ,l_ins_ei_date_tab(ins_rec)
          ,l_ins_period_name_tab(ins_rec)
          ,l_ins_pa_date_tab(ins_rec)
          ,l_ins_gl_date_tab(ins_rec)
          ,l_ins_set_of_books_id_tab(ins_rec)
          ,l_ins_je_category_name_tab(ins_rec)
          ,l_ins_je_source_name_tab(ins_rec)
          ,l_ins_status_code_tab(ins_rec)
          ,l_ins_document_type_tab(ins_rec)
          ,l_ins_funds_process_mode_tab(ins_rec)
          ,l_ins_burden_cost_flag_tab(ins_rec)
          ,l_ins_expenditure_orgn_id_tab(ins_rec)
          ,l_ins_document_header_id_tab(ins_rec)
          ,l_ins_document_line_id_tab(ins_rec)
          ,l_ins_document_dist_id_tab(ins_rec)
          ,l_ins_txn_ccid_tab(ins_rec)
          ,l_ins_accounted_dr_tab(ins_rec)
          ,l_ins_entered_dr_tab(ins_rec)
          ,l_ins_bc_packet_id_tab(ins_rec)
          ,l_ins_parent_bc_packet_id_tab(ins_rec)
          ,l_ins_org_id_tab(ins_rec)
          ,l_ins_balance_posted_flag_tab(ins_rec)
          ,l_ins_exp_item_id_tab(ins_rec)
          ,g_program_id                                    -- program_id
          ,g_program_application_id                        -- program_application_id
          ,SYSDATE                                         -- program_update_date
          ,SYSDATE                                         -- last_update_date
          ,-99                                             -- last_updated_by
          ,-99                                             -- created_by
          ,SYSDATE                                         -- creation_date
          ,g_last_update_login                             -- last_update_login
          ,g_request_id
	  ,'EXP'
	  ,l_ins_exp_item_id_tab(ins_rec)
	  ,l_ins_document_dist_id_tab(ins_rec)
	  -- Bug 5494476 : Actual flag should be 'A' for expenditures and 'E' for PO commitment relieving records.
	  ,decode (l_ins_document_type_tab(ins_rec),'EXP','A','E')
      FROM DUAL
     WHERE l_ins_rejn_code_tab(ins_rec) IS NULL
   ;
      END IF; --l_ins_packet_id_tab.COUNT > 0

      l_records_affected := SQL%ROWCOUNT;

      pa_debug.g_err_stage := 'Inserted [' || TO_CHAR(l_records_affected) ||
                                                '] Records into pa_bc_packets.';
      pa_debug.write_file(l_stage || pa_debug.g_err_stage);

      /*==========================+
       | Deleting plsql tables.   |
       +==========================*/
      pa_debug.g_err_stage := 'Deleting ins plsql tables' ;
      pa_debug.write_file(l_stage || pa_debug.g_err_stage);

      l_ins_packet_id_tab.DELETE;
      l_ins_project_id_tab.DELETE;
      l_ins_task_id_tab.DELETE;
      l_ins_budget_version_id_tab.DELETE;
      l_ins_expenditure_type_tab.DELETE;
      l_ins_ei_date_tab.DELETE;
      l_ins_period_name_tab.DELETE;
      l_ins_pa_date_tab.DELETE;
      l_ins_gl_date_tab.DELETE;
      l_ins_set_of_books_id_tab.DELETE;
      l_ins_je_category_name_tab.DELETE;
      l_ins_je_source_name_tab.DELETE;
      l_ins_status_code_tab.DELETE;
      l_ins_funds_process_mode_tab.DELETE;
      l_ins_burden_cost_flag_tab.DELETE;
      l_ins_expenditure_orgn_id_tab.DELETE;
      l_ins_document_dist_id_tab.DELETE;
      l_ins_txn_ccid_tab.DELETE;
      l_ins_bc_packet_id_tab.DELETE;
      l_ins_org_id_tab.DELETE;
      l_ins_balance_posted_flag_tab.DELETE;
      l_ins_document_type_tab.DELETE;
      l_ins_parent_bc_packet_id_tab.DELETE;
      l_ins_document_header_id_tab.DELETE;
      l_ins_document_line_id_tab.DELETE;
      l_ins_entered_dr_tab.DELETE;
      l_ins_accounted_dr_tab.DELETE;

      /*=========================+
       | Deleting Summary Cache. |
       +=========================*/
      pa_debug.g_err_stage := 'Deleting summary cache plsql tables' ;
      pa_debug.write_file(l_stage || pa_debug.g_err_stage);

      l_summ_project_id_tab.DELETE;
      l_summ_task_id_tab.DELETE;
      l_summ_document_header_id_tab.DELETE;
      l_summ_document_line_id_tab.DELETE;
      l_summ_tot_raw_amt_tab.DELETE;
      l_summ_tot_bd_amt_tab.DELETE;
      l_summ_raw_amt_relieved_tab.DELETE;
      l_summ_bd_amt_relieved_tab.DELETE;
      l_summ_compiled_multiplier_tab.DELETE;
      l_summ_parent_bc_packet_id_tab.DELETE;
      l_summ_expenditure_type_tab.DELETE;
      l_summ_source_tab.DELETE;

      l_stage := l_proc_name || ': ' || to_char(500) || ': ';
      pa_debug.g_err_stage := 'Committing work!!' ;
      pa_debug.write_file(l_stage || pa_debug.g_err_stage);

      COMMIT;

      pa_debug.g_err_stage := 'Leaving populate_pa_bc_packets_cwk.' ;
      pa_debug.write_file(l_stage || pa_debug.g_err_stage);

      pa_debug.reset_err_stack;
  EXCEPTION
    WHEN OTHERS
    THEN
      pa_debug.write_file(l_stage || pa_debug.g_err_stage);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_error_code    := TO_CHAR(SQLCODE) || SQLERRM ;
      x_error_stage   := l_stage ;
      RAISE;
  END; -- populate_pa_bc_packets_cwk
--------------------------------------------------------------------------------------


END pa_bc_costing;

/
