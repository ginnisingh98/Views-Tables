--------------------------------------------------------
--  DDL for Package Body PA_FP_ORG_FCST_GEN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_ORG_FCST_GEN_PUB" as
/* $Header: PAFPORGB.pls 120.3.12010000.2 2008/08/25 10:49:13 bifernan ship $ */
/**
-- Start of Comments
-- Package name     : PA_FP_ORG_FCST_GEN_PUB
-- Purpose          :
-- History          :
-- 27-SEP-2002          sdebroy       FPB2: Changes made due to addition of
--                                    budget_line_id into pa_budget_lines
--                                    table .
-- 26-NOV-02            ssarma        FPB4: Added txn_currency_code to
--                                    all inserts into budget_lines.
--                                    The value will be that of PFC.
--                                    This is done b'coz txn_currency_code
--                                    is a new not null column from
--                                    patchset K.
-- 10-JAN-03            ssarma        FPB7: Fix for 2744924. Look for seeded
--                                    row for amount sets.
-- 12-FEB-03            vejayara      Bug 2796261-Source_Txn_currency_code in
--                                    pa_fin_plan_lines_tmp was not populated.
--                                    Now it is populated.
-- 02-JUN-03            msoundra replaced the call to
--                               API pa_fp_org_fcst_utils.get_utilization_details
--              with pa_pji_util_pkg.get_utilization_dtls to get the numbers from
--              PJI data model if PJI is installed.
-- 21-AUG-03            dbora         Bug 3106741 Performance related changes
-- 25-AUG-08            bifernan      Bug 7309811 Use byte equivalent versions of
--                                    substr and length functions
-- NOTE             :
-- End of Comments
REM | 03-OCT-2005   Riyengar    MRC Elimination Changes:
**/

P_PA_DEBUG_MODE        varchar2(1)  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
g_module_name          VARCHAR2(100):= 'pa.plsql.pa_fp_org_fcst_gen_pub';
g_plsql_max_array_size NUMBER       := 200;

FUNCTION budget_version_in_error
  ( p_budget_version_id IN pa_budget_versions.budget_version_id%TYPE
  ) RETURN NUMBER IS

BEGIN

    UPDATE pa_budget_versions
       SET plan_processing_code = 'E'
     WHERE budget_version_id = p_budget_version_id;

    COMMIT;

    RETURN(1);

EXCEPTION
   WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg(
              p_pkg_name => 'PA_FP_ORG_FCST_GEN_PUB.budget_version_in_error'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);

              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('budget_version_in_error: ' || SQLERRM);
              END IF;
              pa_debug.reset_err_stack;
              RETURN(-1);
              RAISE;
END budget_version_in_error;

FUNCTION get_amttype_id
  ( p_amt_typ_code     IN pa_amount_types_b.amount_type_code%TYPE
                              := NULL
  ) RETURN NUMBER IS
    l_amount_type_id pa_amount_types_b.amount_type_id%TYPE;
    l_amt_code pa_fp_org_fcst_gen_pub.char240_data_type_table;
    l_amt_id   pa_fp_org_fcst_gen_pub.number_data_type_table;

    l_debug_mode VARCHAR2(30);

    CURSOR get_amt_det IS
    SELECT atb.amount_type_id
          ,atb.amount_type_code
      FROM pa_amount_types_b atb
     WHERE atb.amount_type_class = 'R';

    l_stage number := 0;

BEGIN
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('PA_FP_ORG_FCST_GEN_PUB.get_amttype_id');
     END IF;

     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_process('get_amttype_id: ' || 'PLSQL','LOG',l_debug_mode);
     END IF;

       l_amount_type_id := -99;

       IF l_amt_code.last IS NULL THEN
          OPEN get_amt_det;
          LOOP
              FETCH get_amt_det into l_amt_id(nvl(l_amt_id.last+1,1))
                                    ,l_amt_code(nvl(l_amt_code.last+1,1));
              EXIT WHEN get_amt_det%NOTFOUND;
          END LOOP;
       END IF;

       IF l_amt_code.last IS NOT NULL THEN
          FOR i in l_amt_id.first..l_amt_id.last LOOP
              IF l_amt_code(i) = p_amt_typ_code THEN
                 l_amount_type_id := l_amt_id(i);
              END IF;
          END LOOP;
       END IF;
       IF l_amount_type_id = -99 THEN
                 pa_debug.g_err_stage := 'p_amt_typ_code         ['||p_amt_typ_code          ||']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('get_amttype_id: ' || pa_debug.g_err_stage);
                 END IF;
       END IF;
       pa_debug.reset_err_stack;
       RETURN(l_amount_type_id);

EXCEPTION
     WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg(
              p_pkg_name => 'PA_FP_ORG_FCST_GEN_PUB.get_amttype_id'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);

              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('get_amttype_id: ' || SQLERRM);
              END IF;
              pa_debug.reset_err_stack;
              RAISE;
END get_amttype_id;

PROCEDURE gen_org_fcst
( errbuff                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,retcode                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_selection_criteria       IN VARCHAR2
                                := NULL
 ,p_is_org                   IN VARCHAR2
                                := NULL
 ,p_organization_id          IN hr_organization_units.organization_id%TYPE
                                := NULL
 ,p_is_start_org             IN VARCHAR2
                                := NULL
 ,p_starting_organization_id IN hr_organization_units.organization_id%TYPE
                                := NULL
 ,p_budget_version_id        IN pa_budget_versions.budget_version_id%TYPE
                                := NULL)
 IS

 /* Local Variables */

 /* Error handling local variables */
 l_msg_count number := 0;
 l_data VARCHAR2(2000);
 l_msg_data VARCHAR2(2000);
 l_err_code VARCHAR2(2000);
 l_msg_index_out NUMBER(20);
 l_return_status VARCHAR2(2000);
 l_budget_version_in_error NUMBER(5) := 0;

 l_row_id ROWID;

 l_err_stage varchar2(240);
 l_err_stack varchar2(240);
 l_debug_mode varchar2(30) := 'Y';
 l_bg_org varchar2(25);

 l_records_affected number(20);
 l_fe_ctr number(20);
 l_fe_new_seq number(20);
 l_fl_ctr number(20);
 l_fl_new_seq number(20);
 l_string_length number(20);
 l_stage number := 100;
 l_budget_ctr number;
 l_active_organization number;
 l_request_id number;

 l_fcst_start_date date;
 l_fcst_end_date date;
 l_ppp_start_date date;
 l_ppp_end_date date;

 l_project_action_allowed varchar2(1);

 l_proj_fp_options_id pa_proj_fp_options.proj_fp_options_id%TYPE;
 l_time_phased_code pa_proj_fp_options.all_time_phased_code%TYPE;
 l_fin_plan_amount_set_id pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
 l_budget_version_id pa_budget_versions.budget_version_id%TYPE;
 l_period_profile_id pa_budget_versions.period_profile_id%TYPE;
 l_resource_list_id pa_budget_versions.resource_list_id%TYPE;
 l_bv_rec_ver_num pa_budget_versions.record_version_number%TYPE;
 l_bv_version_number pa_budget_versions.version_number%TYPE;
 l_bv_version_name pa_budget_versions.version_name%TYPE;
 l_pfi_txn_project_id pa_budget_versions.project_id%TYPE;
 l_fin_plan_type_id pa_budget_versions.fin_plan_type_id%TYPE;
 l_current_working_flag pa_budget_versions.current_working_flag%TYPE;
 l_org_fcst_period_type pa_forecasting_options_all.org_fcst_period_type%TYPE;
 l_org_proj_template_id pa_forecasting_options_all.org_fcst_project_template_id%TYPE;
 l_number_of_periods pa_forecasting_options_all.number_of_periods%TYPE;
 l_weighted_or_full_code pa_forecasting_options_all.weighted_or_full_code%TYPE;
 l_org_id pa_implementations_all.org_id%TYPE;
 l_pfi_project_org_id pa_implementations_all.org_id%TYPE;
 l_pfi_exp_org_id pa_implementations_all.org_id%TYPE;
 l_pa_period_type pa_implementations_all.pa_period_type%TYPE;
 l_period_set_name pa_implementations_all.period_set_name%TYPE;
 l_org_structure_version_id pa_implementations_all.org_structure_version_id%TYPE;
 l_task_organization_id hr_organization_units.organization_id%TYPE;
 l_organization_id hr_organization_units.organization_id%TYPE;
 l_business_group_id hr_organization_units.business_group_id%TYPE;
 l_org_name hr_organization_units.name%TYPE;
 l_org_location_id hr_organization_units.location_id%TYPE;
 l_pfi_organization_id hr_organization_units.organization_id%TYPE;
 l_pfi_project_organization_id hr_organization_units.organization_id%TYPE;
 l_pfi_exp_organization_id hr_organization_units.organization_id%TYPE;
 l_project_id pa_projects_all.project_id%TYPE;
 l_project_name pa_projects_all.name%TYPE;
 l_project_number pa_projects_all.segment1%TYPE;
 l_new_project_number pa_projects_all.segment1%TYPE;
 l_org_projfunc_currency_code pa_projects_all.projfunc_currency_code%TYPE;
 l_own_task_id pa_tasks.task_id%TYPE;
 l_prob_percent pa_probability_members.probability_percentage%TYPE;
 l_period_profile_type pa_proj_period_profiles.period_profile_type%TYPE;
 l_pfi_assignment_id pa_forecast_items.assignment_id%TYPE;
 l_pfi_resource_id pa_forecast_items.resource_id%TYPE;
 l_own_resource_assignment_id pa_resource_assignments.resource_assignment_id%TYPE;
 l_proj_resource_assignment_id pa_resource_assignments.resource_assignment_id%TYPE;
 l_resource_list_member_id pa_resource_assignments.resource_list_member_id%TYPE;
 l_prv_forecast_element_id pa_org_fcst_elements.forecast_element_id%TYPE;
 l_utl_hours pa_budget_lines.utilization_hours%TYPE;
 l_utl_capacity pa_budget_lines.capacity%TYPE;
 l_set_of_books_id gl_sets_of_books.set_of_books_id%TYPE;
 l_act_period_type gl_periods.period_type%TYPE;


 CURSOR fl_lines_task IS
  SELECT
         fl.budget_version_id                /* FPB2: budget_version_id */
        ,l_own_resource_assignment_id
        ,fl.period_name
        ,fl.start_date
        ,fl.end_date
        ,nvl(sum(fl.quantity),0)
        ,nvl(sum(fl.raw_cost),0)
        ,nvl(sum(fl.burdened_cost),0)
        ,nvl(sum(fl.revenue),0)
        ,nvl(sum(fl.borrowed_revenue),0)
        ,nvl(sum(fl.tp_revenue_in),0)
        ,nvl(sum(fl.tp_revenue_out),0)
        ,nvl(sum(fl.lent_resource_cost),0)
        ,nvl(sum(fl.tp_cost_in),0)
        ,nvl(sum(fl.tp_cost_out),0)
        ,nvl(sum(fl.unassigned_time_cost),0)
   FROM pa_org_forecast_lines fl
  WHERE fl.budget_version_id = l_budget_version_id
    AND fl.project_id        = l_project_id
    AND fl.task_id           = l_own_task_id
  GROUP BY fl.period_name
          ,fl.start_date
          ,fl.end_date
          ,fl.budget_version_id; /* FPB2 */

/* Bug 3106741 for performance improvement budget_version_id join has been added */

 CURSOR bl_lines_project IS
  SELECT
         bl.budget_version_id                /* FPB2: budget_version_id */
        ,l_proj_resource_assignment_id
        ,bl.period_name
        ,bl.start_date
        ,bl.end_date
        ,nvl(sum(bl.quantity),0)
        ,nvl(sum(bl.raw_cost),0)
        ,nvl(sum(bl.burdened_cost),0)
        ,nvl(sum(bl.revenue),0)
        ,nvl(sum(bl.borrowed_revenue),0)
        ,nvl(sum(bl.tp_revenue_in),0)
        ,nvl(sum(bl.tp_revenue_out),0)
        ,nvl(sum(bl.lent_resource_cost),0)
        ,nvl(sum(bl.tp_cost_in),0)
        ,nvl(sum(bl.tp_cost_out),0)
        ,nvl(sum(bl.unassigned_time_cost),0)
        ,nvl(sum(bl.utilization_percent),0)
        ,nvl(sum(bl.utilization_hours),0)
        ,nvl(sum(bl.capacity),0)
        ,nvl(sum(bl.head_count),0)
   FROM pa_budget_lines bl
        ,pa_resource_assignments ra
  WHERE bl.resource_assignment_id = ra.resource_assignment_id
    AND bl.budget_version_id = ra.budget_version_id
    AND ra.budget_version_id = l_budget_version_id
    AND ra.task_id <> 0
    AND bl.budget_version_id = l_budget_version_id   /* bug 3106741 */
  GROUP BY bl.period_name
          ,bl.start_date
          ,bl.end_date
          ,bl.budget_version_id; /* FPB2 */

   /* Only one can be passed at any given time -- that is if p_organization_id
      is passed then p_starting_organization_id will be null and vice-a-versa
      One of them is mandatory from the form, that is both cannot be passed as
      null. p_budget_version_id will only be passed from the OA pages */

    CURSOR org_hierarchy is
    SELECT child_organization_id
      FROM pa_org_hierarchy_denorm
     WHERE pa_org_use_type          = 'REPORTING'
       and parent_organization_id   = p_starting_organization_id
       and org_id                   = l_org_id
       and org_hierarchy_version_id = l_org_structure_version_id
       order by
              parent_level  DESC
             ,child_level   DESC
             ,child_organization_id;

   /*
    SELECT se.organization_id_child org_id
      FROM per_org_structure_elements se
     WHERE se.org_structure_version_id = l_org_structure_version_id
   CONNECT BY PRIOR se.organization_id_child = se.organization_id_parent
       AND se.org_structure_version_id = l_org_structure_version_id
     START WITH se.organization_id_parent = p_starting_organization_id
       AND se.org_structure_version_id = l_org_structure_version_id
     UNION
   SELECT p_starting_organization_id FROM DUAL;
   */

    CURSOR specific_org_only is
    SELECT hou.organization_id
          ,houtl.name
          ,hou.business_group_id
          ,hou.location_id
      FROM hr_all_organization_units hou,
           hr_all_organization_units_tl houtl
     WHERE hou.organization_id = p_organization_id
       AND houtl.organization_id = hou.organization_id
       AND houtl.language = USERENV('LANG');

    CURSOR sub_orgs IS
    SELECT pa.child_organization_id
      FROM pa_org_hierarchy_denorm pa
     WHERE pa.pa_org_use_type = 'REPORTING'
       AND   pa.parent_level-pa.child_level < 1
       AND   nvl(pa.org_id,-99)              = l_org_id
       AND   pa.org_hierarchy_version_id     = l_org_structure_version_id
       AND   pa.parent_organization_id       = l_organization_id
     ORDER BY parent_level  desc,
              parent_organization_id,
              child_level desc,
              child_organization_id;

     CURSOR sub_tasks IS
     SELECT carrying_out_organization_id,
            task_id
       FROM pa_tasks
      WHERE project_id = l_project_id;

          /* Transfer Price Logic as part of Select statement:

             Org Context  TP Amount Type    CC In  CC Out Rev In Rev Out
             -----------  ----------------  -----  ------ ------ -------
             Provider     COST_TRANSFER     0      Y      0       0
             Provider     REVENUE_TRANSFER  0      0      Y       0
             Receiver     COST_TRANSFER     Y      0      0       0
             Receiver     REVENUE_TRANSFER  0      0      0       Y
          */

     CURSOR forecast_items IS
     SELECT
       l_organization_id,
       pfi.project_organization_id,
       pfi.project_org_id,
       pfi.expenditure_organization_id,
       pfi.expenditure_org_id,
       pfi.project_id txn_project_id,
       nvl(pfi.assignment_id,-1),
       nvl(pfi.resource_id,-1),
       gp.period_name,
       gp.start_date,
       gp.end_date,
       nvl(sum(pfi.item_quantity),0),
       DECODE(pfi.forecast_item_type,'U',0,
         DECODE(pfi.expenditure_organization_id,pfi.project_organization_id,
           DECODE(pfi.expenditure_organization_id,l_organization_id,
             DECODE(pfi.expenditure_org_id,l_org_id,
               NVL(SUM(pfi.expfunc_raw_cost),0),0),0),0))              raw_cost,
       DECODE(pfi.forecast_item_type,'U',0,
         DECODE(pfi.expenditure_organization_id, pfi.project_organization_id,
           DECODE(pfi.expenditure_organization_id,l_organization_id,
             DECODE(pfi.expenditure_org_id,l_org_id,
               NVL(SUM(pfi.expfunc_burdened_cost),0),0),0),0))    burdened_cost,
       DECODE(pfi.forecast_item_type,'U',0,
         DECODE(pfi.expenditure_organization_id,pfi.project_organization_id,
           DECODE(pfi.expenditure_org_id,l_org_id,0,
             DECODE(pfi.expenditure_organization_id,l_organization_id,
               NVL(SUM(pfi.expfunc_burdened_cost),0),0)),
                 DECODE(pfi.expenditure_organization_id,l_organization_id,
                   DECODE(pfi.expenditure_org_id,l_org_id,
                     NVL(SUM(pfi.expfunc_burdened_cost),0),0),0))) lent_resource_cost,
       DECODE(pfi.forecast_item_type,'U',
           DECODE(pfi.expenditure_organization_id,l_organization_id,
             DECODE(pfi.expenditure_org_id,l_org_id,
               NVL(SUM(pfi.expfunc_burdened_cost),0),0),0),0) unassigned_time_cost,
       DECODE(pfi.project_organization_id,l_organization_id,
         DECODE(pfi.project_org_id,l_org_id,
           DECODE(pfi.tp_amount_type,'COST_TRANSFER',
             NVL(SUM(pfi.projfunc_transfer_price),0),0),0),0)        tp_cost_in,
       DECODE(pfi.expenditure_organization_id,l_organization_id,
         DECODE(pfi.expenditure_org_id,l_org_id,
           DECODE(pfi.tp_amount_type,'COST_TRANSFER',
             NVL(SUM(pfi.expfunc_transfer_price),0),0),0),0)        tp_cost_out,
       DECODE(pfi.project_organization_id,pfi.expenditure_organization_id,
         DECODE(pfi.project_organization_id,l_organization_id,
           DECODE(pfi.project_org_id,l_org_id,
             NVL(SUM(pfi.projfunc_revenue),0),0),0),0)                  revenue,
       DECODE(pfi.project_organization_id,pfi.expenditure_organization_id,
         DECODE(pfi.project_org_id,l_org_id,0,
           DECODE(pfi.project_organization_id,l_organization_id,
             NVL(SUM(pfi.projfunc_revenue),0),0)),
               DECODE(pfi.project_organization_id,l_organization_id,
                 DECODE(pfi.project_org_id,l_org_id,
                   NVL(SUM(pfi.projfunc_revenue),0),0),0))     borrowed_revenue,
       DECODE(pfi.expenditure_organization_id,l_organization_id,
         DECODE(pfi.expenditure_org_id,l_org_id,
           DECODE(pfi.tp_amount_type,'REVENUE_TRANSFER',
             NVL(SUM(pfi.expfunc_transfer_price),0),0),0),0)          tp_rev_in,
       DECODE(pfi.project_organization_id,l_organization_id,
         DECODE(pfi.project_org_id,l_org_id,
           DECODE(pfi.tp_amount_type,'REVENUE_TRANSFER',
             NVL(sum(pfi.projfunc_transfer_price),0),0),0),0)        tp_rev_out
       FROM pa_forecast_items pfi,
            gl_date_period_map dpm,
            gl_periods gp
      WHERE pfi.project_organization_id = l_organization_id
                     and nvl(pfi.project_org_id,-99) = l_org_id
        AND pfi.forecast_item_type in ('A','R','U')
        AND pfi.delete_flag     = 'N'
        AND pfi.error_flag      = 'N'
        AND pfi.item_date BETWEEN l_fcst_start_date
                              AND l_fcst_end_date
        AND pfi.forecast_amt_calc_flag||'' = 'Y'
        AND dpm.period_set_name = l_period_set_name
        AND dpm.period_type     = l_act_period_type
        AND pfi.item_date       = dpm.accounting_date
        AND dpm.period_set_name = gp.period_set_name
        AND dpm.period_type     = gp.period_type
        AND dpm.period_name     = gp.period_name
        AND gp.adjustment_period_flag = 'N'
        GROUP BY pfi.project_organization_id,
                 pfi.project_org_id,
                 pfi.expenditure_organization_id,
                 pfi.expenditure_org_id,
                 pfi.project_id,
                 nvl(pfi.assignment_id,-1),
                 nvl(pfi.resource_id,-1),
                 pfi.tp_amount_type,
                 pfi.forecast_item_type,
                 gp.start_date,
                 gp.end_date,
                 gp.period_name
    UNION  ALL -- bug 3106741  changed union to uinon all for performance benefit
     SELECT
       l_organization_id,
       pfi.project_organization_id,
       pfi.project_org_id,
       pfi.expenditure_organization_id,
       pfi.expenditure_org_id,
       pfi.project_id txn_project_id,
       nvl(pfi.assignment_id,-1),
       nvl(pfi.resource_id,-1),
       gp.period_name,
       gp.start_date,
       gp.end_date,
       nvl(sum(pfi.item_quantity),0),
       DECODE(pfi.forecast_item_type,'U',0,
         DECODE(pfi.expenditure_organization_id,pfi.project_organization_id,
           DECODE(pfi.expenditure_organization_id,l_organization_id,
             DECODE(pfi.expenditure_org_id,l_org_id,
               NVL(SUM(pfi.expfunc_raw_cost),0),0),0),0))              raw_cost,
       DECODE(pfi.forecast_item_type,'U',0,
         DECODE(pfi.expenditure_organization_id, pfi.project_organization_id,
           DECODE(pfi.expenditure_organization_id,l_organization_id,
             DECODE(pfi.expenditure_org_id,l_org_id,
               NVL(SUM(pfi.expfunc_burdened_cost),0),0),0),0))    burdened_cost,
       DECODE(pfi.forecast_item_type,'U',0,
         DECODE(pfi.expenditure_organization_id,pfi.project_organization_id,
           DECODE(pfi.expenditure_org_id,l_org_id,0,
             DECODE(pfi.expenditure_organization_id,l_organization_id,
               NVL(SUM(pfi.expfunc_burdened_cost),0),0)),
                 DECODE(pfi.expenditure_organization_id,l_organization_id,
                   DECODE(pfi.expenditure_org_id,l_org_id,
                     NVL(SUM(pfi.expfunc_burdened_cost),0),0),0))) lent_resource_cost,
       DECODE(pfi.forecast_item_type,'U',
           DECODE(pfi.expenditure_organization_id,l_organization_id,
             DECODE(pfi.expenditure_org_id,l_org_id,
               NVL(SUM(pfi.expfunc_burdened_cost),0),0),0),0) unassigned_time_cost,
       DECODE(pfi.project_organization_id,l_organization_id,
         DECODE(pfi.project_org_id,l_org_id,
           DECODE(pfi.tp_amount_type,'COST_TRANSFER',
             NVL(SUM(pfi.projfunc_transfer_price),0),0),0),0)        tp_cost_in,
       DECODE(pfi.expenditure_organization_id,l_organization_id,
         DECODE(pfi.expenditure_org_id,l_org_id,
           DECODE(pfi.tp_amount_type,'COST_TRANSFER',
             NVL(SUM(pfi.expfunc_transfer_price),0),0),0),0)        tp_cost_out,
       DECODE(pfi.project_organization_id,pfi.expenditure_organization_id,
         DECODE(pfi.project_organization_id,l_organization_id,
           DECODE(pfi.project_org_id,l_org_id,
             NVL(SUM(pfi.projfunc_revenue),0),0),0),0)                  revenue,
       DECODE(pfi.project_organization_id,pfi.expenditure_organization_id,
         DECODE(pfi.project_org_id,l_org_id,0,
           DECODE(pfi.project_organization_id,l_organization_id,
             NVL(SUM(pfi.projfunc_revenue),0),0)),
               DECODE(pfi.project_organization_id,l_organization_id,
                 DECODE(pfi.project_org_id,l_org_id,
                   NVL(SUM(pfi.projfunc_revenue),0),0),0))     borrowed_revenue,
       DECODE(pfi.expenditure_organization_id,l_organization_id,
         DECODE(pfi.expenditure_org_id,l_org_id,
           DECODE(pfi.tp_amount_type,'REVENUE_TRANSFER',
             NVL(SUM(pfi.expfunc_transfer_price),0),0),0),0)          tp_rev_in,
       DECODE(pfi.project_organization_id,l_organization_id,
         DECODE(pfi.project_org_id,l_org_id,
           DECODE(pfi.tp_amount_type,'REVENUE_TRANSFER',
             NVL(sum(pfi.projfunc_transfer_price),0),0),0),0)        tp_rev_out
       FROM pa_forecast_items pfi,
            gl_date_period_map dpm,
            gl_periods gp
      WHERE pfi.expenditure_organization_id = l_organization_id
                     and nvl(pfi.expenditure_org_id,-99) = l_org_id
        AND pfi.forecast_item_type in ('A','R','U')
        AND pfi.delete_flag     = 'N'
        AND pfi.error_flag      = 'N'
        AND pfi.item_date BETWEEN l_fcst_start_date
                              AND l_fcst_end_date
        AND pfi.forecast_amt_calc_flag||'' = 'Y'
        AND dpm.period_set_name = l_period_set_name
        AND dpm.period_type     = l_act_period_type
        AND pfi.item_date       = dpm.accounting_date
        AND dpm.period_set_name = gp.period_set_name
        AND dpm.period_type     = gp.period_type
        AND dpm.period_name     = gp.period_name
        AND gp.adjustment_period_flag = 'N'
        GROUP BY pfi.project_organization_id,
                 pfi.project_org_id,
                 pfi.expenditure_organization_id,
                 pfi.expenditure_org_id,
                 pfi.project_id,
                 nvl(pfi.assignment_id,-1),
                 nvl(pfi.resource_id,-1),
                 pfi.tp_amount_type,
                 pfi.forecast_item_type,
                 gp.start_date,
                 gp.end_date,
                 gp.period_name
        ORDER BY 1,6,7,8,10,11,2,3,4,5;

 /* Record Definitions */
    amt_rec pa_plan_matrix.amount_type_tabtyp;
    budget_lines_rec budget_lines_record_table_type;

 /* PLSQL Table Declarations */

 /* Forecast Item PL/SQL tables */
 l_fi_organization_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fi_proj_organization_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fi_proj_orgid_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fi_exp_organization_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fi_exp_orgid_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fi_txn_project_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fi_assignment_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fi_resource_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;

 l_fi_period_name_tab pa_fp_org_fcst_gen_pub.char240_data_type_table;
 l_fi_start_date_tab pa_fp_org_fcst_gen_pub.date_data_type_table;
 l_fi_end_date_tab pa_fp_org_fcst_gen_pub.date_data_type_table;
 l_fi_item_quantity_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fi_raw_cost_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fi_burdened_cost_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fi_tp_cost_in_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fi_tp_cost_out_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fi_revenue_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fi_tp_rev_in_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fi_tp_rev_out_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fi_borrowed_revenue_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fi_lent_resource_cost_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fi_unassigned_time_cost_tab pa_fp_org_fcst_gen_pub.number_data_type_table;

 /* Forecast Element PL/SQL Tables */
 l_fe_forecast_element_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fe_organization_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fe_org_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fe_budget_version_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fe_project_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fe_task_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fe_pvdr_rcvr_code_tab pa_fp_org_fcst_gen_pub.char240_data_type_table;
 l_fe_other_organization_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fe_other_org_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fe_txn_project_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fe_assignment_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fe_resource_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;

 /* Forecast Lines PL/SQL Tables */
 l_fl_forecast_line_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fl_forecast_element_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fl_budget_version_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fl_project_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fl_task_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fl_period_name_tab pa_fp_org_fcst_gen_pub.char240_data_type_table;
 l_fl_start_date_tab pa_fp_org_fcst_gen_pub.date_data_type_table;
 l_fl_end_date_tab pa_fp_org_fcst_gen_pub.date_data_type_table;
 l_fl_quantity_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fl_raw_cost_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fl_burdened_cost_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fl_tp_cost_in_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fl_tp_cost_out_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fl_revenue_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fl_tp_rev_in_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fl_tp_rev_out_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fl_borrowed_revenue_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fl_lent_resource_cost_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_fl_unassigned_time_cost_tab pa_fp_org_fcst_gen_pub.number_data_type_table;

 /* Budget Lines PL/SQL Tables */
 l_bl_budget_version_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table; /* FPB2: budget_version_id */

 l_bl_res_asg_id_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_bl_start_date_tab pa_fp_org_fcst_gen_pub.date_data_type_table;
 l_bl_end_date_tab pa_fp_org_fcst_gen_pub.date_data_type_table;
 l_bl_period_name_tab pa_fp_org_fcst_gen_pub.char240_data_type_table;
 l_bl_quantity_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_bl_raw_cost_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_bl_burdened_cost_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_bl_revenue_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_bl_borrowed_revenue_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_bl_tp_revenue_in_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_bl_tp_revenue_out_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_bl_lent_resource_cost_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_bl_tp_cost_in_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_bl_tp_cost_out_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_bl_unassigned_time_cost_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_bl_utilization_percent_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_bl_utilization_hours_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_bl_capacity_tab pa_fp_org_fcst_gen_pub.number_data_type_table;
 l_bl_head_count_tab pa_fp_org_fcst_gen_pub.number_data_type_table;

  BEGIN

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('PA_FP_ORG_FCST_GEN_PUB.gen_org_fcst');
     END IF;

     --fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_process('gen_org_fcst: ' || 'PLSQL','LOG',l_debug_mode);
     END IF;

                       l_stage := 100;
                       -- hr_utility.trace(to_char(l_stage));

     -- get information from pa_forecast_options_all
        pa_fp_org_fcst_utils.get_forecast_option_details
        (  x_fcst_period_type           => l_org_fcst_period_type
          ,x_period_set_name            => l_period_set_name
          ,x_act_period_type            => l_act_period_type
          ,x_org_projfunc_currency_code => l_org_projfunc_currency_code
          ,x_number_of_periods          => l_number_of_periods
          ,x_weighted_or_full_code      => l_weighted_or_full_code
          ,x_org_proj_template_id       => l_org_proj_template_id
          ,x_org_structure_version_id   => l_org_structure_version_id
          ,x_fcst_start_date            => l_fcst_start_date
          ,x_fcst_end_date              => l_fcst_end_date
          ,x_org_id                     => l_org_id
          ,x_return_status              => l_return_status
          ,x_err_code                   => l_err_code);

           pa_debug.g_err_stage := l_stage||': Forecast Options Data: ';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
           END IF;
           pa_debug.g_err_stage := 'l_org_fcst_period_type       ['||l_org_fcst_period_type||']';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
           END IF;
           pa_debug.g_err_stage := 'l_period_set_name            ['||l_period_set_name||']';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
           END IF;
           pa_debug.g_err_stage := 'l_act_period_type            ['||l_act_period_type||']';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
           END IF;
           pa_debug.g_err_stage := 'l_org_projfunc_currency_code ['||l_org_projfunc_currency_code||']';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
           END IF;
           pa_debug.g_err_stage := 'l_number_of_periods          ['||l_number_of_periods||']';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
           END IF;
           pa_debug.g_err_stage := 'l_weighted_or_full_code      ['||l_weighted_or_full_code||']';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
           END IF;
           pa_debug.g_err_stage := 'l_org_proj_template_id       ['||l_org_proj_template_id||']';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
           END IF;
           pa_debug.g_err_stage := 'l_org_structure_version_id   ['||l_org_structure_version_id||']';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
           END IF;
           pa_debug.g_err_stage := 'l_fcst_start_date            ['||l_fcst_start_date||']';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
           END IF;
           pa_debug.g_err_stage := 'l_fcst_end_date              ['||l_fcst_end_date||']';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
           END IF;
           pa_debug.g_err_stage := 'l_org_id                     ['||l_org_id||']';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
           END IF;

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
           THEN
           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                     ': Error occured while Getting forecast Options Det [' ||
                                     l_err_code|| ']';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
             END IF;
             retcode := FND_API.G_RET_STS_ERROR;
             PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_FCST_OPTION_ERR');
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;


     /* Get resource list information */
      BEGIN
                       l_stage := 200;
                       pa_debug.g_err_stage := l_stage||': Get resource list information';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                       -- hr_utility.trace(to_char(l_stage));

          l_resource_list_id := FND_PROFILE.VALUE('PA_FORECAST_RESOURCE_LIST');

          SELECT rlm.resource_list_member_id
            INTO l_resource_list_member_id
            FROM pa_resource_list_members rlm
           WHERE rlm.resource_list_id = l_resource_list_id
             AND rlm.resource_type_code = 'UNCATEGORIZED';
      EXCEPTION
          WHEN OTHERS THEN
                       -- hr_utility.trace(to_char(l_stage)||'-'||SQLERRM);
                       pa_debug.g_err_stage := TO_CHAR(l_stage)||'-'||SQLERRM;
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      BEGIN
                       l_stage := 300;
                       pa_debug.g_err_stage := l_stage||': Get Time Phased Code';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                       -- hr_utility.trace(to_char(l_stage));

        SELECT substr(l_org_fcst_period_type,1,1)
          INTO l_time_phased_code
          FROM sys.dual;

                       l_stage := 400;
                       pa_debug.g_err_stage := l_stage||': Get Plan Type Id';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                       -- hr_utility.trace(to_char(l_stage));

        SELECT fin_plan_type_id
          INTO l_fin_plan_type_id
          FROM pa_fin_plan_types_b
         WHERE fin_plan_type_code = 'ORG_FORECAST';

                       l_stage :=  500;
                       pa_debug.g_err_stage := l_stage||': Get Amount Set Id';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                       -- hr_utility.trace(to_char(l_stage));

        SELECT fin_plan_amount_set_id
          INTO l_fin_plan_amount_set_id
          FROM pa_fin_plan_amount_sets
         WHERE amount_set_type_code = 'ALL'
           AND fin_plan_amount_set_id = 1;  /* Fix for 2744924. */

                       l_stage :=  600;
                       pa_debug.g_err_stage := l_stage||': Derive BV Name';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                       -- hr_utility.trace(to_char(l_stage));

        SELECT meaning
          INTO l_bv_version_name
          FROM pa_lookups
         WHERE lookup_type = 'TRANSLATION'
           AND lookup_code = 'AUTO_GEN_PLAN_VERSION';

      EXCEPTION
          WHEN OTHERS THEN
                       -- hr_utility.trace(to_char(l_stage)||'-'||SQLERRM);
                       pa_debug.g_err_stage := TO_CHAR(l_stage)||'-'||SQLERRM;
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      BEGIN
       IF p_budget_version_id IS NULL THEN
                       l_stage :=  700;
                       pa_debug.g_err_stage := l_stage||': BudgetVersionId is NULL';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                       -- hr_utility.trace(to_char(l_stage));
          IF p_starting_organization_id IS NULL THEN
                       l_stage :=  800;
                       pa_debug.g_err_stage := l_stage||': Start Org is NULL';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                       -- hr_utility.trace(to_char(l_stage));
             OPEN specific_org_only;
          ELSE
                       l_stage :=  900;
                       pa_debug.g_err_stage := l_stage||': Start Org is Not NULL';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                       -- hr_utility.trace(to_char(l_stage));
             OPEN org_hierarchy;
          END IF;
       END IF;

      EXCEPTION
         WHEN OTHERS THEN
                       -- hr_utility.trace(to_char(l_stage)||'-'||SQLERRM);
                       pa_debug.g_err_stage := TO_CHAR(l_stage)||'-'||SQLERRM;
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

    l_budget_ctr := 0; /* This is required to let the loop run
                          only once if budget version id is passed*/
    LOOP
    BEGIN
      IF l_budget_ctr = 1 THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write_file('gen_org_fcst: ' || 'Exiting as Budget Version Process has failed');
         END IF;
         EXIT;
      END IF;
      savepoint org_project;
      IF  p_budget_version_id IS NULL THEN
                       l_stage := 1000;
                       -- hr_utility.trace(to_char(l_stage));
          IF p_starting_organization_id IS NULL THEN
                       l_stage :=  1100;
                       pa_debug.g_err_stage := l_stage||': Fetching from specific_org_only';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                       -- hr_utility.trace(to_char(l_stage));
                FETCH specific_org_only
                 INTO l_organization_id
                     ,l_org_name
                     ,l_business_group_id
                     ,l_org_location_id;

                IF specific_org_only%NOTFOUND THEN
                       pa_debug.g_err_stage := l_stage||': Exiting from specific_org_only FETCH';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                   EXIT;
                END IF;
                       l_stage :=  1200;
                       -- hr_utility.trace(to_char(l_stage));

                     IF l_org_location_id IS NULL THEN
                       l_stage :=  1300;
                       -- hr_utility.trace(to_char(l_stage));
                        pa_debug.g_err_stage := l_stage||': Organization Id ['
                                                     ||l_organization_id||
                                                     '] has no location';
                            IF P_PA_DEBUG_MODE = 'Y' THEN
                               pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                            END IF;
                            rollback to org_project;
                            RAISE pa_fp_org_fcst_gen_pub.error_reloop;
                     END IF;

                       l_stage :=  1400;

                     BEGIN
                         SELECT 1
                           INTO l_active_organization
                           FROM  pa_organizations_project_v
                          WHERE organization_id = l_organization_id
                            AND   active_flag = 'Y'
                            AND   TRUNC(SYSDATE) BETWEEN TRUNC(date_from)
                                                     AND NVL(date_to, TRUNC(SYSDATE));
                     EXCEPTION WHEN NO_DATA_FOUND THEN
                       -- hr_utility.trace(to_char(l_stage)||'-'||SQLERRM);
                       pa_debug.g_err_stage := l_stage||': Organization Id ['
                                                           ||l_organization_id||
                                                              '] is Not Active';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                       rollback to org_project;
                       RAISE pa_fp_org_fcst_gen_pub.error_reloop;
                     END;
          ELSE
                       l_stage :=  1500;
                       pa_debug.g_err_stage := l_stage||': Fetching from org_hierarchy';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                       -- hr_utility.trace(to_char(l_stage));
                FETCH org_hierarchy
                 INTO l_organization_id;
                IF org_hierarchy%NOTFOUND THEN
                       pa_debug.g_err_stage := l_stage||': Exiting from org_hierarchy FETCH';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                   EXIT;
                END IF;
                       l_stage :=  1600;
                       -- hr_utility.trace(to_char(l_stage));

                     BEGIN
                         SELECT 1
                           INTO l_active_organization
                           FROM  pa_organizations_project_v
                          WHERE organization_id = l_organization_id
                            AND   active_flag = 'Y'
                            AND   TRUNC(SYSDATE) BETWEEN TRUNC(date_from)
                                                     AND NVL(date_to, TRUNC(SYSDATE));
                     EXCEPTION WHEN NO_DATA_FOUND THEN
                       -- hr_utility.trace(to_char(l_stage)||'-'||SQLERRM);
                       pa_debug.g_err_stage := l_stage||': Organization Id ['
                                                           ||l_organization_id||
                                                              '] is Not Active';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                       rollback to org_project;
                       RAISE pa_fp_org_fcst_gen_pub.error_reloop;
                     END;

                       l_stage :=  1700;
                       -- hr_utility.trace(to_char(l_stage));

                SELECT  hou.name
                       ,hou.business_group_id
                       ,hou.location_id
                  INTO  l_org_name
                       ,l_business_group_id
                       ,l_org_location_id
                  FROM  hr_all_organization_units hou
                 WHERE  hou.organization_id = l_organization_id;

                     IF l_org_location_id IS NULL THEN
                        pa_debug.g_err_stage := l_stage||': Organization Id ['
                                                     ||l_organization_id||
                                                     '] has no location';
                            IF P_PA_DEBUG_MODE = 'Y' THEN
                               pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                            END IF;
                            rollback to org_project;
                            RAISE pa_fp_org_fcst_gen_pub.error_reloop;
                     END IF;
          END IF;

          SELECT '-'||decode(substr(to_char(l_org_id),1,1),'-',
                 substr(to_char(l_org_id),2),to_char(l_org_id))||
                 '-'||to_char(l_business_group_id)
            INTO l_bg_org
            FROM sys.dual;

                       l_stage :=  1800;
                       -- hr_utility.trace(to_char(l_stage));

          -- Bug 7309811 - Use byte equivalent versions of substr and length functions
          SELECT substrb(l_org_name,1,(30 - lengthb(l_bg_org)))||l_bg_org
                ,substrb(l_org_name,1,(25 - lengthb(l_bg_org)))||l_bg_org
            INTO l_project_name
                ,l_project_number
            FROM DUAL;

                       -- hr_utility.trace(to_char(l_stage));
                         pa_debug.g_err_stage := l_stage||': Project Name is '||l_project_name;
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                         END IF;

                       l_stage :=  1900;
                       pa_debug.g_err_stage := l_stage||': Get Org Project Info';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
          /* Get Project information if the project exists else create the
             project by copying the template as per forecasting options
             and then get the project info */

          pa_fp_org_fcst_utils.get_org_project_info
          ( p_organization_id            => l_organization_id
           ,x_org_project_id             => l_project_id
           ,x_return_status              => l_return_status
           ,x_err_code                   => l_err_code);

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
           THEN
             pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                     ': Error occured while Getting Project Info [' ||
                                     l_err_code|| ']';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
             END IF;
             pa_debug.g_err_stage := l_stage||': Organization Id = '||TO_CHAR(l_organization_id);
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
             END IF;
             rollback to org_project;
             RAISE pa_fp_org_fcst_gen_pub.error_reloop;
          END IF;
                       l_stage :=  2000;
                       -- hr_utility.trace(to_char(l_stage));
                         pa_debug.g_err_stage := l_stage||': Org Project ID is ['||l_project_id||']';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                         END IF;

          IF l_project_id > 0 THEN

                       l_stage :=  2100;
                       -- hr_utility.trace(to_char(l_stage));
                       pa_debug.g_err_stage := l_stage||': Get Org Task Info';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;

             pa_fp_org_fcst_utils.get_org_task_info
             ( p_project_id      => l_project_id
              ,x_organization_id => l_task_organization_id
              ,x_org_task_id     => l_own_task_id
              ,x_return_status   => l_return_status
              ,x_err_code        => l_err_code);

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                         ': Error getting Own Task';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 /*
                 pa_debug.g_err_stage :=
                                'l_project_id            ['||l_project_id             ||
                              '] l_organization_id       ['||l_organization_id        ||
                              '] l_org_id                ['||l_org_id                 ||
                              ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 */
                 rollback to org_project;
                 RAISE pa_fp_org_fcst_gen_pub.error_reloop;
              END IF;
                       l_stage :=  2200;
             -- hr_utility.trace('2200: Own Task Id = '||to_char(l_own_task_id));
                       pa_debug.g_err_stage := l_stage||': Own Task Id = '||l_own_task_id;
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;

             IF l_own_task_id < 0 THEN
                       l_stage :=  2300;
                       -- hr_utility.trace(to_char(l_stage));
                 pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                         ': Own Task Not Found';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 /*
                 pa_debug.g_err_stage :=
                                'l_project_id            ['||l_project_id             ||
                              '] l_organization_id       ['||l_organization_id        ||
                              '] l_org_id                ['||l_org_id                 ||
                              ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 */
                 PA_UTILS.ADD_MESSAGE( p_app_short_name       => 'PA'
                                      ,p_msg_name             => 'PA_FP_OWN_TASK_NOT_FOUND');
                 rollback to org_project;
                 RAISE pa_fp_org_fcst_gen_pub.error_reloop;
             END IF;

             IF l_task_organization_id <> l_organization_id THEN
                       l_stage :=  2400;
                       -- hr_utility.trace(to_char(l_stage));
                UPDATE pa_tasks
                   SET carrying_out_organization_id = l_organization_id
                 WHERE project_id = l_project_id
                   AND task_id    = l_own_task_id;
             END IF;
          END IF;

          IF l_project_id < 0 THEN /* Organization Project not found */
                       l_stage :=  2500;
                       -- hr_utility.trace(to_char(l_stage));
                         pa_debug.g_err_stage := l_stage||': Create New Org Project for '||TO_CHAR(l_organization_id);
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                         END IF;

             l_err_code := NULL;
             l_err_stage := NULL;
             l_err_stack := NULL;

             pa_project_core1.copy_project
             ( x_orig_project_id         => l_org_proj_template_id
              , x_project_name           => l_project_name
              , x_project_number         => l_project_number
              , x_description            => NULL
              , x_project_type           => NULL
              , x_project_status_code    => NULL
              , x_distribution_rule      => NULL
              , x_public_sector_flag     => 'N'
              , x_organization_id        => l_organization_id
              , x_start_date             => TRUNC(sysdate)
              , x_completion_date        => NULL
              , x_probability_member_id  => NULL
              , x_project_value          => NULL
              , x_expected_approval_date => NULL
              , x_agreement_currency     => NULL
              , x_agreement_amount       => NULL
              , x_agreement_org_id       => NULL
              , x_copy_task_flag         => 'Y'
              , x_copy_budget_flag       => 'N'
              , x_use_override_flag      => 'N'
              , x_copy_assignment_flag   => 'N'
              , x_template_flag          => 'N'
              , x_project_id             => l_project_id
              , x_err_code               => l_err_code
              , x_err_stage              => l_err_stage
              , x_err_stack              => l_err_stack
              , x_new_project_number     => l_new_project_number
              , x_team_template_id       => NULL
              , x_country_code           => NULL
              , x_region                 => NULL
              , x_city                   => NULL
              , x_opp_value_currency_code => NULL
              , x_org_project_copy_flag  => 'Y');

              IF l_err_code  > 0 THEN
                 pa_debug.g_err_stage := l_stage||': Error Creating Project [' || l_err_code || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := l_stage||': [' || l_err_stage|| ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := l_stage||': [' || l_err_stack|| ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := l_stage||': l_org_proj_template_id  ['||l_org_proj_template_id   || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := l_stage||': l_project_name          ['||l_project_name           || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := l_stage||': l_project_number        ['||l_project_number         || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := l_stage||': l_organization_id       ['||l_organization_id        || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := l_stage||': l_org_id                ['||l_org_id                 || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 rollback to org_project;
                 RAISE pa_fp_org_fcst_gen_pub.error_reloop;
              END IF;

                       l_stage :=  2600;
                       -- hr_utility.trace(to_char(l_stage));
                       pa_debug.g_err_stage := l_stage||': Get Org Task Info';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
             pa_fp_org_fcst_utils.get_org_task_info
             ( p_project_id      => l_project_id
              ,x_organization_id => l_task_organization_id
              ,x_org_task_id     => l_own_task_id
              ,x_return_status   => l_return_status
              ,x_err_code        => l_err_code);

             -- hr_utility.trace('Own Task Id = '||to_char(l_own_task_id));

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                         ': Error getting Own Task';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := 'l_project_id            ['||l_project_id             || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := 'l_organization_id       ['||l_organization_id        || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := 'l_org_id                ['||l_org_id                 || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 rollback to org_project;
                 RAISE pa_fp_org_fcst_gen_pub.error_reloop;
              END IF;

             IF l_own_task_id < 0 THEN
                       l_stage :=  2700;
                       -- hr_utility.trace(to_char(l_stage));
                 pa_debug.g_err_stage := TO_CHAR(l_stage) ||': Own Task Not Found';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := 'l_project_id            ['||l_project_id             || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := 'l_organization_id       ['||l_organization_id        || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := 'l_org_id                ['||l_org_id                 || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 PA_UTILS.ADD_MESSAGE( p_app_short_name       => 'PA'
                                      ,p_msg_name             => 'PA_FP_OWN_TASK_NOT_FOUND');
                 rollback to org_project;
                 RAISE pa_fp_org_fcst_gen_pub.error_reloop;
             END IF;

             IF l_task_organization_id <> l_organization_id THEN
                       l_stage :=  2800;
                       -- hr_utility.trace(to_char(l_stage));
                UPDATE pa_tasks
                   SET carrying_out_organization_id = l_organization_id
                 WHERE project_id = l_project_id
                   AND task_id    = l_own_task_id;
             END IF;

                       l_stage :=  2900;
                       -- hr_utility.trace(to_char(l_stage));
                 pa_debug.g_err_stage := TO_CHAR(l_stage) ||': Create Proj Fin Plan Options at Project Level';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;

              -- Create Proj Fin Plan Options at Project Level
                l_proj_fp_options_id := NULL;
              pa_proj_fp_options_pkg.Insert_Row
              ( px_proj_fp_options_id         => l_proj_fp_options_id
               ,p_project_id                  => l_project_id
               ,p_fin_plan_option_level_code  => 'PROJECT'
               ,p_fin_plan_type_id            => NULL
               ,p_fin_plan_start_date         => NULL
               ,p_fin_plan_end_date           => NULL
               ,p_fin_plan_preference_code    => 'COST_AND_REV_SAME'
               ,p_cost_amount_set_id          => NULL
               ,p_revenue_amount_set_id       => NULL
               ,p_all_amount_set_id           => 1
               ,p_cost_fin_plan_level_code    => NULL
               ,p_cost_time_phased_code       => NULL
               ,p_cost_resource_list_id       => NULL
               ,p_revenue_fin_plan_level_code => NULL
               ,p_revenue_time_phased_code    => NULL
               ,p_revenue_resource_list_id    => NULL
               ,p_all_fin_plan_level_code     => 'L'
               ,p_all_time_phased_code        => l_time_phased_code
               ,p_all_resource_list_id        => l_resource_list_id
               ,p_report_labor_hrs_from_code  => 'COST'
               ,p_fin_plan_version_id         => NULL
               ,x_row_id                      => l_row_id
               ,x_return_status               => l_return_status);

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                          ': Error creating Proj FP Options';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_project_id            ['||l_project_id             || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_fin_plan_type_id      ['||l_fin_plan_type_id       || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'option_level_code       ['||'PROJECT'                || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_org_id                ['||l_org_id                 || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  rollback to org_project;
                  RAISE pa_fp_org_fcst_gen_pub.error_reloop;
               END IF;

                       l_stage :=  3000;
                       -- hr_utility.trace(to_char(l_stage));
                 pa_debug.g_err_stage := TO_CHAR(l_stage) ||': Create Proj FP Options at Plan Type Level';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;

              -- Create Proj Fin Plan Options at Plan Type Level
              l_proj_fp_options_id := NULL;
              pa_proj_fp_options_pkg.Insert_Row
              ( px_proj_fp_options_id         => l_proj_fp_options_id
               ,p_project_id                  => l_project_id
               ,p_fin_plan_option_level_code  => 'PLAN_TYPE'
               ,p_fin_plan_type_id            => l_fin_plan_type_id
               ,p_fin_plan_start_date         => NULL
               ,p_fin_plan_end_date           => NULL
               ,p_fin_plan_preference_code    => 'COST_AND_REV_SAME'
               ,p_cost_amount_set_id          => NULL
               ,p_revenue_amount_set_id       => NULL
               ,p_all_amount_set_id           => 1
               ,p_cost_fin_plan_level_code    => NULL
               ,p_cost_time_phased_code       => NULL
               ,p_cost_resource_list_id       => NULL
               ,p_revenue_fin_plan_level_code => NULL
               ,p_revenue_time_phased_code    => NULL
               ,p_revenue_resource_list_id    => NULL
               ,p_all_fin_plan_level_code     => 'L'
               ,p_all_time_phased_code        => l_time_phased_code
               ,p_all_resource_list_id        => l_resource_list_id
               ,p_report_labor_hrs_from_code  => 'COST'
               ,p_fin_plan_version_id         => NULL
               ,x_row_id                      => l_row_id
               ,x_return_status               => l_return_status);

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                          ': Error creating Plan FP Options';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_project_id            ['||l_project_id             || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_fin_plan_type_id      ['||l_fin_plan_type_id       || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'option_level_code       ['||'PROJECT'                || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_org_id                ['||l_org_id                 || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  rollback to org_project;
                  RAISE pa_fp_org_fcst_gen_pub.error_reloop;
               END IF;

                       l_stage :=  3100;
                       -- hr_utility.trace(to_char(l_stage));

           END IF; /* End of Organization Project Creation */

                       l_stage :=  3200;
                       -- hr_utility.trace(to_char(l_stage));
                       pa_debug.g_err_stage := TO_CHAR(l_stage) ||': Check Existence of Period Profile for the following data: ';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;


           -- Get Period Profile Information if exists
            pa_debug.g_err_stage := l_stage||': l_project_id           ['||l_project_id          ||']';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                         END IF;
            pa_debug.g_err_stage := l_stage||': period_profile_type    ['||'FINANCIAL_PLANNING'  ||']';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                         END IF;
            pa_debug.g_err_stage := l_stage||': l_org_fcst_period_type ['||l_org_fcst_period_type||']';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                         END IF;
            pa_debug.g_err_stage := l_stage||': l_period_set_name      ['||l_period_set_name     ||']';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                         END IF;
            pa_debug.g_err_stage := l_stage||': l_act_period_type      ['||l_act_period_type     ||']';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                         END IF;
            pa_debug.g_err_stage := l_stage||': l_fcst_start_date      ['||l_fcst_start_date     ||']';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                         END IF;
            pa_debug.g_err_stage := l_stage||': l_number_of_periods    ['||l_number_of_periods   ||']';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                         END IF;


           pa_fp_org_fcst_utils.get_period_profile
           ( p_project_id          => l_project_id
            ,p_period_profile_type => 'FINANCIAL_PLANNING'
            ,p_plan_period_type    => l_org_fcst_period_type
            ,p_period_set_name     => l_period_set_name
            ,p_act_period_type     => l_act_period_type
            ,p_start_date          => l_fcst_start_date
            ,p_number_of_periods   => l_number_of_periods
            ,x_period_profile_id   => l_period_profile_id
            ,x_return_status       => l_return_status
            ,x_err_code            => l_err_code);

               IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                          ': Error in get_period_profile ';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  rollback to org_project;
                  RAISE pa_fp_org_fcst_gen_pub.error_reloop;
               END IF;

                       l_stage :=  3300;
                       -- hr_utility.trace(to_char(l_stage));

           IF l_period_profile_id < 0 THEN
                       l_period_profile_id := NULL;
                       l_stage :=  3400;
                       -- hr_utility.trace(to_char(l_stage));
                       pa_debug.g_err_stage := TO_CHAR(l_stage) ||': Creating Period Profile';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;

              IF l_org_fcst_period_type = 'PA' THEN
                 /* Denorm pkg requires this */
                 -- hr_utility.trace(to_char(l_stage));
                 l_pa_period_type := l_act_period_type;
              END IF;

              -- Create Period Profile
              Pa_Prj_Period_Profile_Utils.maintain_prj_period_profile
              ( p_project_id          => l_project_id
               ,p_period_profile_type => 'FINANCIAL_PLANNING'
               ,p_plan_period_type    => l_org_fcst_period_type
               ,p_period_set_name     => l_period_set_name
               ,p_gl_period_type      => l_act_period_type
               ,p_pa_period_type      => l_pa_period_type
               ,p_start_date          => l_fcst_start_date
               ,px_end_date           => l_fcst_end_date
               ,px_period_profile_id  => l_period_profile_id
               ,p_commit_flag         => 'N'
               ,px_number_of_periods  => l_number_of_periods
               ,x_plan_start_date     => l_ppp_start_date
               ,x_plan_end_date       => l_ppp_end_date
               ,x_return_status       => l_return_status
               ,x_msg_count           => l_msg_count
               ,x_msg_data            => errbuff   );

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                          ': Error creating period profile';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  rollback to org_project;
                  RAISE pa_fp_org_fcst_gen_pub.error_reloop;
               END IF;
           END IF;

                       l_stage :=  3500;
                       -- hr_utility.trace(to_char(l_stage));
                         pa_debug.g_err_stage := l_stage||': Period Profile Id ['||l_period_profile_id||']';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                         END IF;

           SELECT nvl(max(bv.version_number),0) + 1,
                  DECODE(nvl(max(bv.version_number),0) + 1,1,'Y','N')
             INTO l_bv_version_number
                 ,l_current_working_flag
             FROM pa_budget_versions bv
            WHERE bv.project_id = l_project_id
              AND bv.fin_plan_type_id = l_fin_plan_type_id
              AND bv.budget_status_code in ('W','S');

                       l_stage :=  3600;
                       -- hr_utility.trace(to_char(l_stage));
                         pa_debug.g_err_stage := l_stage||': BV Number    ['||l_bv_version_number   ||']';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                         END IF;
                         pa_debug.g_err_stage := l_stage||': Current Working Flag ['||l_current_working_flag||']';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                         END IF;

                       pa_debug.g_err_stage := TO_CHAR(l_stage) ||': Create Budget Version';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;

           -- Create Budget Version
                l_budget_version_id := NULL;
              pa_fp_budget_versions_pkg.Insert_Row
              ( px_budget_version_id           => l_budget_version_id
               ,p_project_id                   => l_project_id
               ,p_budget_type_code             => NULL
               ,p_version_number               => l_bv_version_number
               ,p_budget_status_code           => 'W'
               ,p_current_flag                 => 'N'
               ,p_original_flag                => 'N'
               ,p_current_original_flag        => 'N'
               ,p_resource_accumulated_flag    => 'N'
               ,p_resource_list_id             => l_resource_list_id
               ,p_version_name                 => l_bv_version_name
               ,p_plan_run_date                => sysdate
               ,p_plan_processing_code         => 'S'
               ,p_period_profile_id            => l_period_profile_id
               ,p_fin_plan_type_id             => l_fin_plan_type_id
               ,p_current_working_flag         => l_current_working_flag
               ,p_version_type                 => 'ORG_FORECAST'
               ,x_row_id                       => l_row_id
               ,x_return_status                => l_return_status);

                       l_stage :=  3700;
                       -- hr_utility.trace(to_char(l_stage));
                         pa_debug.g_err_stage := l_stage||': Budget Version Id    ['||l_budget_version_id   ||']';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                         END IF;
                         pa_debug.g_err_stage := l_stage||': Resource List Id ['||l_resource_list_id||']';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                         END IF;

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                          ': Error creating Budget version';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_project_id            ['||l_project_id             || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_bv_version_number     ['||l_bv_version_number      || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_resource_list_id      ['||l_resource_list_id       || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_period_profile_id     ['||l_period_profile_id      || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_fin_plan_type_id      ['||l_fin_plan_type_id       || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_current_working_flag  ['||l_current_working_flag   || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'version_type            ['||'ORG_FORECAST'           || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  rollback to org_project;
                  RAISE pa_fp_org_fcst_gen_pub.error_reloop;
               END IF;

                       l_stage :=  3750;
                       -- hr_utility.trace(to_char(l_stage));
                 pa_debug.g_err_stage := TO_CHAR(l_stage) ||': Create Proj Fin Plan Options at Plan Version Level';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;

              -- Create Proj Fin Plan Options at Plan Version Level
                l_proj_fp_options_id := NULL;
              pa_proj_fp_options_pkg.Insert_Row
              ( px_proj_fp_options_id         => l_proj_fp_options_id
               ,p_project_id                  => l_project_id
               ,p_fin_plan_option_level_code  => 'PLAN_VERSION'
               ,p_fin_plan_type_id            => l_fin_plan_type_id
               ,p_fin_plan_start_date         => l_fcst_start_date
               ,p_fin_plan_end_date           => l_fcst_end_date
               ,p_fin_plan_preference_code    => 'COST_AND_REV_SAME'
               ,p_cost_amount_set_id          => NULL
               ,p_revenue_amount_set_id       => NULL
               ,p_all_amount_set_id           => 1
               ,p_cost_fin_plan_level_code    => NULL
               ,p_cost_time_phased_code       => NULL
               ,p_cost_resource_list_id       => NULL
               ,p_revenue_fin_plan_level_code => NULL
               ,p_revenue_time_phased_code    => NULL
               ,p_revenue_resource_list_id    => NULL
               ,p_all_fin_plan_level_code     => 'L'
               ,p_all_time_phased_code        => l_time_phased_code
               ,p_all_resource_list_id        => l_resource_list_id
               ,p_report_labor_hrs_from_code  => 'COST'
               ,p_fin_plan_version_id         => l_budget_version_id
               ,x_row_id                      => l_row_id
               ,x_return_status               => l_return_status);

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                          ': Error creating Budget Version FP Options';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_project_id            ['||l_project_id             || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_fin_plan_type_id      ['||l_fin_plan_type_id       || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'option_level_code       ['||'PROJECT'                || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_org_id                ['||l_org_id                 || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  rollback to org_project;
                  RAISE pa_fp_org_fcst_gen_pub.error_reloop;
               END IF;
     ELSE  /* Budget version passed */
           l_budget_ctr := 1;
                       l_stage :=  3800;
                       -- hr_utility.trace(to_char(l_stage));
                       pa_debug.g_err_stage := TO_CHAR(l_stage) ||': Get BudgetVersion Details';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;

           SELECT bv.budget_version_id,
                  bv.project_id,
                  bv.record_version_number,
                  bv.period_profile_id,
                  pa.carrying_out_organization_id,
                  pa.projfunc_currency_code
             INTO l_budget_version_id,
                  l_project_id,
                  l_bv_rec_ver_num,
                  l_period_profile_id,
                  l_organization_id,
                  l_org_projfunc_currency_code
             FROM pa_budget_versions bv,
                  pa_projects pa
            WHERE bv.budget_version_id = p_budget_version_id
              AND pa.project_id = bv.project_id;

                       l_stage :=  3900;
                       -- hr_utility.trace(to_char(l_stage));

          IF l_project_id > 0 THEN

                       pa_debug.g_err_stage := TO_CHAR(l_stage) ||': Get Org Task Info';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;

             pa_fp_org_fcst_utils.get_org_task_info
             ( p_project_id      => l_project_id
              ,x_organization_id => l_task_organization_id
              ,x_org_task_id     => l_own_task_id
              ,x_return_status   => l_return_status
              ,x_err_code        => l_err_code);

             -- hr_utility.trace('Own Task Id = '||to_char(l_own_task_id));

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                         ': Error getting Own Task';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := 'l_project_id            ['||l_project_id             || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := 'l_organization_id       ['||l_organization_id        || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := 'l_org_id                ['||l_org_id                 || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 rollback to org_project;
                 RAISE pa_fp_org_fcst_gen_pub.error_reloop;
              END IF;

             IF l_own_task_id < 0 THEN
                       l_stage :=  4000;
                       -- hr_utility.trace(to_char(l_stage));
                 pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                         ': Own Task Not Found';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := 'l_project_id            ['||l_project_id             || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := 'l_organization_id       ['||l_organization_id        || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 pa_debug.g_err_stage := 'l_org_id                ['||l_org_id                 || ']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                 END IF;
                 PA_UTILS.ADD_MESSAGE( p_app_short_name       => 'PA'
                                      ,p_msg_name             => 'PA_FP_OWN_TASK_NOT_FOUND');
                 rollback to org_project;
                 RAISE pa_fp_org_fcst_gen_pub.error_reloop;
             END IF;

             IF l_task_organization_id <> l_organization_id THEN
                       l_stage :=  4100;
                       -- hr_utility.trace(to_char(l_stage));
                UPDATE pa_tasks
                   SET carrying_out_organization_id = l_organization_id
                 WHERE project_id = l_project_id
                   AND task_id    = l_own_task_id;
             END IF;
          END IF;

                       l_stage :=  4200;
                       -- hr_utility.trace(to_char(l_stage));
                     pa_debug.g_err_stage := l_stage||': Org Projfunc Currency Code ['||l_org_projfunc_currency_code||']';
                     IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                     END IF;

           pa_prj_period_profile_utils.get_prj_period_profile_dtls
           ( p_period_profile_id   => l_period_profile_id
            ,x_period_profile_type => l_period_profile_type
            ,x_plan_period_type    => l_org_fcst_period_type
            ,x_period_set_name     => l_period_set_name
            ,x_gl_period_type      => l_act_period_type
            ,x_plan_start_date     => l_fcst_start_date
            ,x_plan_end_date       => l_fcst_end_date
            ,x_number_of_periods   => l_number_of_periods
            ,x_return_status       => l_return_status
          --,x_msg_count           => x_msg_count
            ,x_msg_data            => errbuff   );

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                          ': Error getting period profile info';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage :=
                                 'l_period_profile_id     ['||l_period_profile_id      || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  rollback to org_project;
                  RAISE pa_fp_org_fcst_gen_pub.error_reloop;
               END IF;

            /* DELETE existing data for budget version */

                       l_stage :=  4300;
                       -- hr_utility.trace(to_char(l_stage));
                       pa_debug.g_err_stage := TO_CHAR(l_stage) ||': Deleting Existing Data';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;

               pa_fin_plan_pub.Delete_Version_Helper
               (p_budget_version_id    => p_budget_version_id,
                x_return_status        => l_return_status,
                x_msg_count            => l_msg_count,
                x_msg_data             => l_msg_data);

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
                  RAISE pa_fp_org_fcst_gen_pub.error_reloop;
              END IF;
                       l_stage :=  4900;
                       -- hr_utility.trace(to_char(l_stage));
            UPDATE pa_budget_versions
               SET
               version_name = DECODE(version_name,null,l_bv_version_name
                                     ||'-'||to_char(l_budget_version_id),
                                     version_name)
              ,last_update_date = sysdate
              ,last_updated_by = fnd_global.user_id
              ,last_update_login = fnd_global.login_id
              ,revenue = 0
              ,raw_cost = 0
              ,burdened_cost = 0
              ,labor_quantity = 0
              ,total_borrowed_revenue = 0
              ,total_tp_revenue_in = 0
              ,total_tp_revenue_out = 0
              ,total_lent_resource_cost = 0
              ,total_tp_cost_in = 0
              ,total_tp_cost_out = 0
              ,total_unassigned_time_cost = 0
              ,total_utilization_percent = 0
              ,total_utilization_hours = 0
              ,total_capacity = 0
              ,total_head_count = 0
              ,total_revenue_adj = 0
              ,total_cost_adj = 0
              ,total_utilization_adj = 0
              ,total_head_count_adj = 0
              WHERE budget_version_id = p_budget_version_id;

                       l_stage :=  5000;
                       -- hr_utility.trace(to_char(l_stage));
              COMMIT;
     END IF; /* Budget Version Check */

                       l_stage :=  5100;
                       -- hr_utility.trace(to_char(l_stage));
     IF l_org_fcst_period_type = 'PA' THEN /* Denorm pkg requires this */
                       l_stage :=  5200;
                       -- hr_utility.trace(to_char(l_stage));
        l_pa_period_type := l_act_period_type;
     END IF;

     /* Now we have the Organization Project and all the task for own
        and sub-tasks and period profile, budget version and plan
        options in place */

     /* The program flow from here is as follows:
      - Create Forecast Elements
      - Create Forecast Lines
      - Create Proj Denorm for forecast lines
      - Create Resource Assignments
      - Create Budget Lines
      - Update Resource Assignments
      - Update Budget Versions
      - Create Proj Denorm for budget lines
      */
                       l_stage :=  5300;
                       -- hr_utility.trace(to_char(l_stage));
                       pa_debug.g_err_stage := TO_CHAR(l_stage) ||': Populate amt_rec for Forecast Lines Denorm';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
      /* Populate amt_rec for Forecast Lines Denorm */
     amt_rec.delete;

     amt_rec(1).amount_type_code := 'QUANTITY';
     amt_rec(1).amount_subtype_code := 'QUANTITY';
     amt_rec(1).amount_type_id := get_amttype_id(p_amt_typ_code => 'QUANTITY');
     amt_rec(1).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'QUANTITY');

     amt_rec(2).amount_type_code := 'COST';
     amt_rec(2).amount_subtype_code := 'OWN_PROJECT_COST';
     amt_rec(2).amount_type_id := get_amttype_id(p_amt_typ_code => 'COST');
     amt_rec(2).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'OWN_PROJECT_COST');

     amt_rec(3).amount_type_code := 'COST';
     amt_rec(3).amount_subtype_code := 'TP_COST_IN';
     amt_rec(3).amount_type_id := get_amttype_id(p_amt_typ_code => 'COST');
     amt_rec(3).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'TP_COST_IN');

     amt_rec(4).amount_type_code := 'COST';
     amt_rec(4).amount_subtype_code := 'TP_COST_OUT';
     amt_rec(4).amount_type_id := get_amttype_id(p_amt_typ_code => 'COST');
     amt_rec(4).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'TP_COST_OUT');

     amt_rec(5).amount_type_code := 'COST';
     amt_rec(5).amount_subtype_code := 'LENT_RESOURCE_COST';
     amt_rec(5).amount_type_id := get_amttype_id(p_amt_typ_code => 'COST');
     amt_rec(5).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'LENT_RESOURCE_COST');

     amt_rec(6).amount_type_code := 'COST';
     amt_rec(6).amount_subtype_code := 'UNASSIGNED_TIME_COST';
     amt_rec(6).amount_type_id := get_amttype_id(p_amt_typ_code => 'COST');
     amt_rec(6).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'UNASSIGNED_TIME_COST');

     amt_rec(7).amount_type_code := 'REVENUE';
     amt_rec(7).amount_subtype_code := 'OWN_REVENUE';
     amt_rec(7).amount_type_id := get_amttype_id(p_amt_typ_code => 'REVENUE');
     amt_rec(7).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'OWN_REVENUE');

     amt_rec(8).amount_type_code := 'REVENUE';
     amt_rec(8).amount_subtype_code := 'BORROWED_REVENUE';
     amt_rec(8).amount_type_id := get_amttype_id(p_amt_typ_code => 'REVENUE');
     amt_rec(8).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'BORROWED_REVENUE');

     amt_rec(9).amount_type_code := 'REVENUE';
     amt_rec(9).amount_subtype_code := 'TP_REVENUE_IN';
     amt_rec(9).amount_type_id := get_amttype_id(p_amt_typ_code => 'REVENUE');
     amt_rec(9).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'TP_REVENUE_IN');

     amt_rec(10).amount_type_code := 'REVENUE';
     amt_rec(10).amount_subtype_code := 'TP_REVENUE_OUT';
     amt_rec(10).amount_type_id := get_amttype_id(p_amt_typ_code => 'REVENUE');
     amt_rec(10).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'TP_REVENUE_OUT');

         /* DELETE FROM ALL plsql tables */

         /* For forecast items */
         l_fi_organization_id_tab.delete;
         l_fi_proj_organization_tab.delete;
         l_fi_proj_orgid_tab.delete;
         l_fi_exp_organization_id_tab.delete;
         l_fi_exp_orgid_tab.delete;
         l_fi_txn_project_id_tab.delete;
         l_fi_assignment_id_tab.delete;
         l_fi_resource_id_tab.delete;
         l_fi_period_name_tab.delete;
         l_fi_start_date_tab.delete;
         l_fi_end_date_tab.delete;
         l_fi_item_quantity_tab.delete;
         l_fi_raw_cost_tab.delete;
         l_fi_burdened_cost_tab.delete;
         l_fi_tp_cost_in_tab.delete;
         l_fi_tp_cost_out_tab.delete;
         l_fi_revenue_tab.delete;
         l_fi_tp_rev_in_tab.delete;
         l_fi_tp_rev_out_tab.delete;
         l_fi_borrowed_revenue_tab.delete;
         l_fi_lent_resource_cost_tab.delete;
         l_fi_unassigned_time_cost_tab.delete;

         /* Forecast Element PL/SQL Tables */
         l_fe_forecast_element_id_tab.delete;
         l_fe_organization_id_tab.delete;
         l_fe_org_id_tab.delete;
         l_fe_budget_version_id_tab.delete;
         l_fe_project_id_tab.delete;
         l_fe_task_id_tab.delete;
         l_fe_pvdr_rcvr_code_tab.delete;
         l_fe_other_organization_id_tab.delete;
         l_fe_other_org_id_tab.delete;
         l_fe_txn_project_id_tab.delete;
         l_fe_assignment_id_tab.delete;
         l_fe_resource_id_tab.delete;

         /* Forecast Lines PL/SQL Tables */
         l_fl_forecast_line_id_tab.delete;
         l_fl_forecast_element_id_tab.delete;
         l_fl_budget_version_id_tab.delete;
         l_fl_project_id_tab.delete;
         l_fl_task_id_tab.delete;
         l_fl_period_name_tab.delete;
         l_fl_start_date_tab.delete;
         l_fl_end_date_tab.delete;
         l_fl_quantity_tab.delete;
         l_fl_raw_cost_tab.delete;
         l_fl_burdened_cost_tab.delete;
         l_fl_tp_cost_in_tab.delete;
         l_fl_tp_cost_out_tab.delete;
         l_fl_revenue_tab.delete;
         l_fl_tp_rev_in_tab.delete;
         l_fl_tp_rev_out_tab.delete;
         l_fl_borrowed_revenue_tab.delete;
         l_fl_lent_resource_cost_tab.delete;
         l_fl_unassigned_time_cost_tab.delete;

         /* Budget Lines PL/SQL Tables */

         l_bl_res_asg_id_tab.delete;
         l_bl_budget_version_id_tab.delete; /* FPB2 */
         l_bl_start_date_tab.delete;
         l_bl_end_date_tab.delete;
         l_bl_period_name_tab.delete;
         l_bl_quantity_tab.delete;
         l_bl_raw_cost_tab.delete;
         l_bl_burdened_cost_tab.delete;
         l_bl_revenue_tab.delete;
         l_bl_borrowed_revenue_tab.delete;
         l_bl_tp_revenue_in_tab.delete;
         l_bl_tp_revenue_out_tab.delete;
         l_bl_lent_resource_cost_tab.delete;
         l_bl_tp_cost_in_tab.delete;
         l_bl_tp_cost_out_tab.delete;
         l_bl_unassigned_time_cost_tab.delete;
         l_bl_utilization_percent_tab.delete;
         l_bl_utilization_hours_tab.delete;
         l_bl_capacity_tab.delete;
         l_bl_head_count_tab.delete;

         l_pfi_organization_id         := null;
         l_pfi_project_organization_id := null;
         l_pfi_project_org_id          := null;
         l_pfi_exp_organization_id     := null;
         l_pfi_exp_org_id              := null;
         l_pfi_txn_project_id          := null;
         l_pfi_assignment_id           := null;
         l_pfi_resource_id             := null;
         l_prv_forecast_element_id     := null;

       IF NOT forecast_items%ISOPEN THEN
         OPEN forecast_items;
       ELSE
         CLOSE forecast_items;
         OPEN forecast_items;
       END IF;
                       l_stage :=  5400;
                       -- hr_utility.trace(to_char(l_stage));
         LOOP
                 l_fi_organization_id_tab.delete;
                 l_fi_proj_organization_tab.delete;
                 l_fi_proj_orgid_tab.delete;
                 l_fi_exp_organization_id_tab.delete;
                 l_fi_exp_orgid_tab.delete;
                 l_fi_txn_project_id_tab.delete;
                 l_fi_assignment_id_tab.delete;
                 l_fi_resource_id_tab.delete;
                 l_fi_period_name_tab.delete;
                 l_fi_start_date_tab.delete;
                 l_fi_end_date_tab.delete;
                 l_fi_item_quantity_tab.delete;
                 l_fi_raw_cost_tab.delete;
                 l_fi_burdened_cost_tab.delete;
                 l_fi_tp_cost_in_tab.delete;
                 l_fi_tp_cost_out_tab.delete;
                 l_fi_revenue_tab.delete;
                 l_fi_tp_rev_in_tab.delete;
                 l_fi_tp_rev_out_tab.delete;
                 l_fi_borrowed_revenue_tab.delete;
                 l_fi_lent_resource_cost_tab.delete;
                 l_fi_unassigned_time_cost_tab.delete;

           FETCH forecast_items BULK COLLECT INTO
                 l_fi_organization_id_tab,
                 l_fi_proj_organization_tab,
                 l_fi_proj_orgid_tab,
                 l_fi_exp_organization_id_tab,
                 l_fi_exp_orgid_tab,
                 l_fi_txn_project_id_tab,
                 l_fi_assignment_id_tab,
                 l_fi_resource_id_tab,
                 l_fi_period_name_tab,
                 l_fi_start_date_tab,
                 l_fi_end_date_tab,
                 l_fi_item_quantity_tab,
                 l_fi_raw_cost_tab,
                 l_fi_burdened_cost_tab,
                 l_fi_lent_resource_cost_tab,
                 l_fi_unassigned_time_cost_tab,
                 l_fi_tp_cost_in_tab,
                 l_fi_tp_cost_out_tab,
                 l_fi_revenue_tab,
                 l_fi_borrowed_revenue_tab,
                 l_fi_tp_rev_in_tab,
                 l_fi_tp_rev_out_tab LIMIT 200;

                 IF NVL(l_fi_organization_id_tab.count,0) =0 THEN
                       l_stage :=  4200;
                       -- hr_utility.trace(to_char(l_stage));
                         pa_debug.g_err_stage := l_stage||': Exiting fi loop no rows to process';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                         END IF;
                       EXIT WHEN NVL(l_fi_organization_id_tab.count,0) =0;
                 END IF;


                       l_stage :=  5500;
                       -- hr_utility.trace(to_char(l_stage));
                       -- hr_utility.trace('Row fetched : '||to_char(l_fi_organization_id_tab.count));

          /* Transfer Price Logic as part of Select statement:

             Org Context  TP Amount Type  CC In  CC Out Rev In Rev Out
             -----------  --------------  -----  ------ ------ -------
             Provider     COST              0      Y      0       0
             Provider     REVENUE           0      0      Y       0
             Receiver     COST              Y      0      0       0
             Receiver     REVENUE           0      0      0       Y
          */

      FOR i in l_fi_organization_id_tab.first..l_fi_organization_id_tab.last LOOP
      BEGIN
                 -- hr_utility.trace('Orgn id=> '||to_char(l_fi_organization_id_tab(i)));
                 -- hr_utility.trace('Proj Orgn=> '||to_char(l_fi_proj_organization_tab(i)));
                 -- hr_utility.trace('Proj Orgid=> '||to_char(l_fi_proj_orgid_tab(i)));
                 -- hr_utility.trace('Exp Orgn=> '||to_char(l_fi_exp_organization_id_tab(i)));
                 -- hr_utility.trace('Exp Orgid=> '||to_char(l_fi_exp_orgid_tab(i)));
                 -- hr_utility.trace('Txn Proj=> '||to_char(l_fi_txn_project_id_tab(i)));
                 -- hr_utility.trace('Asg Id=> '||to_char(l_fi_assignment_id_tab(i)));
                 -- hr_utility.trace('Res Id=> '||to_char(l_fi_resource_id_tab(i)));
                 -- hr_utility.trace('Period=> '||l_fi_period_name_tab(i));
                 -- hr_utility.trace('Start Dt=> '||l_fi_start_date_tab(i));
                 -- hr_utility.trace('End Dt=> '||l_fi_end_date_tab(i));
                 -- hr_utility.trace('prv txn Id => '||to_char(l_pfi_txn_project_id));
                 -- hr_utility.trace('Weighted_full => '||l_weighted_or_full_code);
                 -- hr_utility.trace('End Dt=> '||l_fi_end_date_tab(i));

       IF (l_pfi_txn_project_id IS NULL OR
           l_pfi_txn_project_id <> l_fi_txn_project_id_tab(i)) THEN
           l_stage :=  5510;
           -- hr_utility.trace(to_char(l_stage));
                  pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                          ': Getting Project Action Allowed';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_project_id ['||l_fi_txn_project_id_tab(i)|| ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;

           l_project_action_allowed := pa_project_utils.check_project_action_allowed
                                    ( x_project_id => l_fi_txn_project_id_tab(i)
                                     ,x_action_code => 'PROJ_ORG_FORECASTING');
       END IF;

       IF l_project_action_allowed = 'N' THEN
          l_stage :=  5520;
           -- hr_utility.trace(to_char(l_stage));
          pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                          ': Project Action Not Allowed -- Skipping : '
                                          ||l_fi_txn_project_id_tab(i);

          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
          END IF;
          l_pfi_txn_project_id              := l_fi_txn_project_id_tab(i);

          RAISE pa_fp_org_fcst_gen_pub.proj_action_reloop;
       END IF;


       IF (l_pfi_txn_project_id IS NULL OR
           l_pfi_txn_project_id <> l_fi_txn_project_id_tab(i)) THEN
          IF l_weighted_or_full_code = 'W' THEN
             pa_fp_org_fcst_utils.get_probability_percent
             ( p_project_id    => l_fi_txn_project_id_tab(i)
              ,x_prob_percent  => l_prob_percent
              ,x_return_status => l_return_status
              ,x_err_code      => l_err_code);
                       l_stage :=  5600;
                       -- hr_utility.trace(to_char(l_stage));
                       -- hr_utility.trace('Probability => '||to_char(l_prob_percent));

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                          ': Error getting probability percent';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_project_id ['||l_project_id|| ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  rollback to org_project;
                  RAISE pa_fp_org_fcst_gen_pub.error_reloop;
               END IF;
          ELSE
             l_prob_percent := 100;
          END IF;
       END IF;

       IF (( l_pfi_organization_id IS NULL) /* First Iteration */         OR
           ( l_pfi_organization_id <>
                                     l_fi_organization_id_tab(i)          OR
             l_pfi_project_organization_id     <>
                                     l_fi_proj_organization_tab(i)        OR
             l_pfi_project_org_id              <>
                                     l_fi_proj_orgid_tab(i)               OR
             l_pfi_exp_organization_id <>
                                     l_fi_exp_organization_id_tab(i)      OR
             l_pfi_exp_org_id          <>
                                     l_fi_exp_orgid_tab(i)                OR
             l_pfi_txn_project_id              <>
                                     l_fi_txn_project_id_tab(i)           OR
             l_pfi_assignment_id               <>
                                     l_fi_assignment_id_tab(i)            OR
             l_pfi_resource_id                 <>
                                     l_fi_resource_id_tab(i))) THEN

                       l_stage :=  5700;
                       -- hr_utility.trace(to_char(l_stage));

           l_fe_ctr := nvl(l_fe_forecast_element_id_tab.last+1,1);
                       l_stage :=  5800;
                       -- hr_utility.trace(to_char(l_stage));

           SELECT pa_org_fcst_elements_s.NEXTVAL
             INTO l_fe_new_seq
             FROM dual;

                       l_stage :=  5900;
                       -- hr_utility.trace(to_char(l_stage));
           l_fe_forecast_element_id_tab(l_fe_ctr) := l_fe_new_seq;
           l_fe_organization_id_tab(l_fe_ctr)     := l_fi_organization_id_tab(i);
           l_fe_budget_version_id_tab(l_fe_ctr)   := l_budget_version_id;
           l_fe_project_id_tab(l_fe_ctr)          := l_project_id;
           l_fe_task_id_tab(l_fe_ctr)             := l_own_task_id;

           IF l_fi_exp_organization_id_tab(i) =
                                         l_fi_organization_id_tab(i) THEN
                       l_stage :=  6000;
                       -- hr_utility.trace(to_char(l_stage));
              l_fe_pvdr_rcvr_code_tab(l_fe_ctr) := 'P';
              l_fe_other_organization_id_tab(l_fe_ctr)
                                     := l_fi_proj_organization_tab(i);
              l_fe_other_org_id_tab(l_fe_ctr)
                                     := l_fi_proj_orgid_tab(i);
              l_fe_org_id_tab(l_fe_ctr)
                                     := l_fi_exp_orgid_tab(i);
           ELSE
                       l_stage :=  6100;
                       -- hr_utility.trace(to_char(l_stage));
              l_fe_pvdr_rcvr_code_tab(l_fe_ctr) := 'R';
              l_fe_other_organization_id_tab(l_fe_ctr)
                                 := l_fi_exp_organization_id_tab(i);
              l_fe_other_org_id_tab(l_fe_ctr)
                                     := l_fi_exp_orgid_tab(i);
              l_fe_org_id_tab(l_fe_ctr)
                                     := l_fi_proj_orgid_tab(i);
           END IF;
                       l_stage :=  6200;
                       -- hr_utility.trace(to_char(l_stage));
           l_fe_txn_project_id_tab(l_fe_ctr)  := l_fi_txn_project_id_tab(i);
           l_fe_assignment_id_tab(l_fe_ctr)   := l_fi_assignment_id_tab(i);
           l_fe_resource_id_tab(l_fe_ctr)     := l_fi_resource_id_tab(i);

           l_fl_ctr := nvl(l_fl_forecast_line_id_tab.last+1,1);
                       l_stage :=  6300;
                       -- hr_utility.trace(to_char(l_stage));
           SELECT pa_org_forecast_lines_s.NEXTVAL
             INTO l_fl_new_seq
             FROM DUAL;

                       l_stage :=  6400;
                       -- hr_utility.trace(to_char(l_stage));

           -- hr_utility.trace('FECounter=> '||l_fe_ctr);
           -- hr_utility.trace('FE ID => '||to_char(l_fe_forecast_element_id_tab(l_fe_ctr)));
           -- hr_utility.trace('Org Id => '||to_char(l_fe_organization_id_tab(l_fe_ctr)));
           -- hr_utility.trace('BV Id => '||to_char(l_fe_budget_version_id_tab(l_fe_ctr)));
           -- hr_utility.trace('Proj Id => '||to_char(l_fe_project_id_tab(l_fe_ctr)));
           -- hr_utility.trace('Task Id => '||to_char(l_fe_task_id_tab(l_fe_ctr)));
           -- hr_utility.trace('PR => '||l_fe_pvdr_rcvr_code_tab(l_fe_ctr));
           -- hr_utility.trace('OOrg => '||to_char(l_fe_other_organization_id_tab(l_fe_ctr)));
           -- hr_utility.trace('Txn Proj => '||to_char(l_fe_txn_project_id_tab(l_fe_ctr)));
           -- hr_utility.trace('Asg Id => '||to_char(l_fe_assignment_id_tab(l_fe_ctr)));
           -- hr_utility.trace('ResId => '||to_char(l_fe_resource_id_tab(l_fe_ctr)));

           l_fl_forecast_line_id_tab(l_fl_ctr) := l_fl_new_seq;
           l_fl_forecast_element_id_tab(l_fl_ctr) := l_fe_new_seq;
           l_fl_budget_version_id_tab(l_fl_ctr) := l_budget_version_id;
           l_fl_project_id_tab(l_fl_ctr) := l_project_id;
           l_fl_task_id_tab(l_fl_ctr) := l_own_task_id;
           l_fl_period_name_tab(l_fl_ctr) := l_fi_period_name_tab(i);
           l_fl_start_date_tab(l_fl_ctr) := l_fi_start_date_tab(i);
           l_fl_end_date_tab(l_fl_ctr) := l_fi_end_date_tab(i);
           l_fl_quantity_tab(l_fl_ctr) := l_fi_item_quantity_tab(i);
           l_fl_raw_cost_tab(l_fl_ctr) := (l_fi_raw_cost_tab(i)
                                           *l_prob_percent)/ 100;
           l_fl_burdened_cost_tab(l_fl_ctr) := (l_fi_burdened_cost_tab(i)
                                                *l_prob_percent)/ 100;
           l_fl_tp_cost_in_tab(l_fl_ctr) := (l_fi_tp_cost_in_tab(i)
                                             *l_prob_percent)/ 100;
           l_fl_tp_cost_out_tab(l_fl_ctr) := (l_fi_tp_cost_out_tab(i)
                                              *l_prob_percent)/ 100;
           l_fl_revenue_tab(l_fl_ctr) := (l_fi_revenue_tab(i)*l_prob_percent)/
                                           100;
           l_fl_tp_rev_in_tab(l_fl_ctr) := (l_fi_tp_rev_in_tab(i)
                                            *l_prob_percent)/ 100;
           l_fl_tp_rev_out_tab(l_fl_ctr) := (l_fi_tp_rev_out_tab(i)
                                             *l_prob_percent)/ 100;
           l_fl_borrowed_revenue_tab(l_fl_ctr) := (l_fi_borrowed_revenue_tab(i)
                                                   *l_prob_percent)/ 100;
           l_fl_lent_resource_cost_tab(l_fl_ctr)
                                             := (l_fi_lent_resource_cost_tab(i)
                                                 *l_prob_percent)/ 100;
           l_fl_unassigned_time_cost_tab(l_fl_ctr)
                                         := (l_fi_unassigned_time_cost_tab(i)
                                             *l_prob_percent)/ 100;

                       l_stage :=  6500;
                       -- hr_utility.trace(to_char(l_stage));
           -- hr_utility.trace('FLCounter=> '||l_fl_ctr);
           -- hr_utility.trace('FLId => '||to_char(l_fl_forecast_line_id_tab(l_fl_ctr)));
           -- hr_utility.trace('FEId => '||to_char(l_fl_forecast_element_id_tab(l_fl_ctr)));
           -- hr_utility.trace('BVId => '||to_char(l_fl_budget_version_id_tab(l_fl_ctr)));
           -- hr_utility.trace('ProjId => '||to_char(l_fl_project_id_tab(l_fl_ctr)));
           -- hr_utility.trace('TaskId => '||to_char(l_fl_task_id_tab(l_fl_ctr)));
           -- hr_utility.trace('Period => '||l_fl_period_name_tab(l_fl_ctr));
           -- hr_utility.trace('StartDt => '||l_fl_start_date_tab(l_fl_ctr));
           -- hr_utility.trace('EndDt => '||l_fl_end_date_tab(l_fl_ctr));
           -- hr_utility.trace('Qty => '||to_char(l_fl_quantity_tab(l_fl_ctr)));
           -- hr_utility.trace('Raw => '||to_char(l_fl_raw_cost_tab(l_fl_ctr)));
           -- hr_utility.trace('BurCost => '||to_char(l_fl_burdened_cost_tab(l_fl_ctr)));
           -- hr_utility.trace('CostIn => '||to_char(l_fl_tp_cost_in_tab(l_fl_ctr)));
           -- hr_utility.trace('CostOut => '||to_char(l_fl_tp_cost_out_tab(l_fl_ctr)));
           -- hr_utility.trace('Rev => '||to_char(l_fl_revenue_tab(l_fl_ctr)));
           -- hr_utility.trace('RevIn => '||to_char(l_fl_tp_rev_in_tab(l_fl_ctr)));
           -- hr_utility.trace('RevOut => '||to_char(l_fl_tp_rev_out_tab(l_fl_ctr)));
           -- hr_utility.trace('BorRev => '||to_char(l_fl_borrowed_revenue_tab(l_fl_ctr)));
           -- hr_utility.trace('LentCost => '||to_char(l_fl_lent_resource_cost_tab(l_fl_ctr)));
           -- hr_utility.trace('TimeCost => '||to_char(l_fl_unassigned_time_cost_tab(l_fl_ctr)));
       ELSE

                       l_stage :=  6600;
                       -- hr_utility.trace(to_char(l_stage));
           l_fl_ctr := nvl(l_fl_forecast_line_id_tab.last+1,1);
           SELECT pa_org_forecast_lines_s.NEXTVAL
             INTO l_fl_new_seq
             FROM DUAL;
                       l_stage :=  6700;
                       -- hr_utility.trace(to_char(l_stage));

           l_fl_forecast_line_id_tab(l_fl_ctr)  := l_fl_new_seq;
           l_fl_forecast_element_id_tab(l_fl_ctr) := l_fe_new_seq;
           l_fl_budget_version_id_tab(l_fl_ctr) := l_budget_version_id;
           l_fl_project_id_tab(l_fl_ctr)        := l_project_id;
           l_fl_task_id_tab(l_fl_ctr)           := l_own_task_id;
           l_fl_period_name_tab(l_fl_ctr)       := l_fi_period_name_tab(i);
           l_fl_start_date_tab(l_fl_ctr)        := l_fi_start_date_tab(i);
           l_fl_end_date_tab(l_fl_ctr)          := l_fi_end_date_tab(i);
           l_fl_quantity_tab(l_fl_ctr) := l_fi_item_quantity_tab(i);
           l_fl_raw_cost_tab(l_fl_ctr) := (l_fi_raw_cost_tab(i)
                                           *l_prob_percent)/ 100;
           l_fl_burdened_cost_tab(l_fl_ctr) := (l_fi_burdened_cost_tab(i)
                                                *l_prob_percent)/ 100;
           l_fl_tp_cost_in_tab(l_fl_ctr) := (l_fi_tp_cost_in_tab(i)
                                             *l_prob_percent)/ 100;
           l_fl_tp_cost_out_tab(l_fl_ctr) := (l_fi_tp_cost_out_tab(i)
                                              *l_prob_percent)/ 100;
           l_fl_revenue_tab(l_fl_ctr) := (l_fi_revenue_tab(i)*l_prob_percent)/
                                           100;
           l_fl_tp_rev_in_tab(l_fl_ctr) := (l_fi_tp_rev_in_tab(i)
                                            *l_prob_percent)/ 100;
           l_fl_tp_rev_out_tab(l_fl_ctr) := (l_fi_tp_rev_out_tab(i)
                                             *l_prob_percent)/ 100;
           l_fl_borrowed_revenue_tab(l_fl_ctr) := (l_fi_borrowed_revenue_tab(i)
                                                   *l_prob_percent)/ 100;
           l_fl_lent_resource_cost_tab(l_fl_ctr)
                                             := (l_fi_lent_resource_cost_tab(i)
                                                 *l_prob_percent)/ 100;
           l_fl_unassigned_time_cost_tab(l_fl_ctr)
                                         := (l_fi_unassigned_time_cost_tab(i)
                                             *l_prob_percent)/ 100;

                       l_stage :=  6800;
                       -- hr_utility.trace(to_char(l_stage));
           -- hr_utility.trace('FLCounter=> '||l_fl_ctr);
           -- hr_utility.trace('FLId => '||to_char(l_fl_forecast_line_id_tab(l_fl_ctr)));
           -- hr_utility.trace('FEId => '||to_char(l_fl_forecast_element_id_tab(l_fl_ctr)));
           -- hr_utility.trace('BVId => '||to_char(l_fl_budget_version_id_tab(l_fl_ctr)));
           -- hr_utility.trace('ProjId => '||to_char(l_fl_project_id_tab(l_fl_ctr)));
           -- hr_utility.trace('TaskId => '||to_char(l_fl_task_id_tab(l_fl_ctr)));
           -- hr_utility.trace('Period => '||l_fl_period_name_tab(l_fl_ctr));
           -- hr_utility.trace('StartDt => '||l_fl_start_date_tab(l_fl_ctr));
           -- hr_utility.trace('EndDt => '||l_fl_end_date_tab(l_fl_ctr));
           -- hr_utility.trace('Qty => '||to_char(l_fl_quantity_tab(l_fl_ctr)));
           -- hr_utility.trace('Raw => '||to_char(l_fl_raw_cost_tab(l_fl_ctr)));
           -- hr_utility.trace('BurCost => '||to_char(l_fl_burdened_cost_tab(l_fl_ctr)));
           -- hr_utility.trace('CostIn => '||to_char(l_fl_tp_cost_in_tab(l_fl_ctr)));
           -- hr_utility.trace('CostOut => '||to_char(l_fl_tp_cost_out_tab(l_fl_ctr)));
           -- hr_utility.trace('Rev => '||to_char(l_fl_revenue_tab(l_fl_ctr)));
           -- hr_utility.trace('RevIn => '||to_char(l_fl_tp_rev_in_tab(l_fl_ctr)));
           -- hr_utility.trace('RevOut => '||to_char(l_fl_tp_rev_out_tab(l_fl_ctr)));
           -- hr_utility.trace('BorRev => '||to_char(l_fl_borrowed_revenue_tab(l_fl_ctr)));
           -- hr_utility.trace('LentCost => '||to_char(l_fl_lent_resource_cost_tab(l_fl_ctr)));
           -- hr_utility.trace('TimeCost => '||to_char(l_fl_unassigned_time_cost_tab(l_fl_ctr)));
       END IF;

                       l_stage :=  6900;
                       -- hr_utility.trace(to_char(l_stage));

          l_pfi_organization_id             := l_fi_organization_id_tab(i);
          l_pfi_project_organization_id     :=
                                          l_fi_proj_organization_tab(i);
          l_pfi_project_org_id              :=
                                          l_fi_proj_orgid_tab(i);
          l_pfi_exp_organization_id :=
                                      l_fi_exp_organization_id_tab(i);
          l_pfi_exp_org_id          :=
                                      l_fi_exp_orgid_tab(i);
          l_pfi_txn_project_id              := l_fi_txn_project_id_tab(i);
          l_pfi_assignment_id               := l_fi_assignment_id_tab(i);
          l_pfi_resource_id                 := l_fi_resource_id_tab(i);

                       l_stage :=  7000;
                       -- hr_utility.trace(to_char(l_stage));

      EXCEPTION
        WHEN pa_fp_org_fcst_gen_pub.proj_action_reloop THEN
             -- hr_utility.trace('UserDefined Txn Project Skipping - '||to_char(l_stage)||'-'||SQLERRM);
             pa_debug.g_err_stage := l_stage||': UserDefined Txn Project Skipping - '||'['||SQLERRM||']';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
             END IF;
             NULL;
      END;
      END LOOP; -- l_fi_organization_id_tab


                       l_stage :=  7100;
                       -- hr_utility.trace(to_char(l_stage));

      /* Bulk Insert into Forecast Elements */
          pa_debug.g_err_stage := l_stage||': fe_count =  ['||l_fe_forecast_element_id_tab.count||']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;

          IF l_fe_forecast_element_id_tab.count > 0 THEN
                       l_stage :=  7200;
                       -- hr_utility.trace(to_char(l_stage));


          FORALL i in l_fe_forecast_element_id_tab.first..l_fe_forecast_element_id_tab.last
            INSERT INTO pa_org_fcst_elements
             ( forecast_element_id
              ,organization_id
              ,org_id
              ,budget_version_id
              ,project_id
              ,task_id
              ,provider_receiver_code
              ,other_organization_id
              ,other_org_id
              ,txn_project_id
              ,assignment_id
              ,resource_id
              ,record_version_number
              ,creation_date
              ,created_by
              ,last_update_login
              ,last_updated_by
              ,last_update_date
             ) VALUES (
               l_fe_forecast_element_id_tab(i)
              ,l_fe_organization_id_tab(i)
              ,l_fe_org_id_tab(i)
              ,l_fe_budget_version_id_tab(i)
              ,l_fe_project_id_tab(i)
              ,l_fe_task_id_tab(i)
              ,l_fe_pvdr_rcvr_code_tab(i)
              ,l_fe_other_organization_id_tab(i)
              ,l_fe_other_org_id_tab(i)
              ,l_fe_txn_project_id_tab(i)
              ,l_fe_assignment_id_tab(i)
              ,l_fe_resource_id_tab(i)
              ,1
              ,sysdate
              ,fnd_global.user_id
              ,fnd_global.login_id
              ,fnd_global.user_id
              ,sysdate);

              l_records_affected := SQL%ROWCOUNT;

              pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                             ': After Inserting Forecast Elements' ;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
              END IF;

              pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                    ': Inserted [' || TO_CHAR(l_records_affected) ||
                    '] Forecast Elements.';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
              END IF;
                       l_stage :=  7300;
                       -- hr_utility.trace(to_char(l_stage));
              END IF;

      /* Bulk Insert into Forecast Lines */
                       l_stage :=  7400;
                       -- hr_utility.trace(to_char(l_stage));

          pa_debug.g_err_stage := l_stage||': fl_count =  ['||l_fl_forecast_line_id_tab.count||']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;

          IF l_fl_forecast_line_id_tab.count > 0 THEN
          FORALL j in l_fl_forecast_line_id_tab.first..l_fl_forecast_line_id_tab.last
            INSERT INTO pa_org_forecast_lines
            ( forecast_line_id
             ,forecast_element_id
             ,budget_version_id
             ,project_id
             ,task_id
             ,period_name
             ,start_date
             ,end_date
             ,quantity
             ,raw_cost
             ,burdened_cost
             ,tp_cost_in
             ,tp_cost_out
             ,revenue
             ,tp_revenue_in
             ,tp_revenue_out
             ,borrowed_revenue
             ,lent_resource_cost
             ,unassigned_time_cost
             ,record_version_number
             ,creation_date
             ,created_by
             ,last_update_login
             ,last_updated_by
             ,last_update_date
            ) VALUES (
              l_fl_forecast_line_id_tab(j)
             ,l_fl_forecast_element_id_tab(j)
             ,l_fl_budget_version_id_tab(j)
             ,l_fl_project_id_tab(j)
             ,l_fl_task_id_tab(j)
             ,l_fl_period_name_tab(j)
             ,l_fl_start_date_tab(j)
             ,l_fl_end_date_tab(j)
             ,l_fl_quantity_tab(j)
             ,l_fl_raw_cost_tab(j)
             ,l_fl_burdened_cost_tab(j)
             ,l_fl_tp_cost_in_tab(j)
             ,l_fl_tp_cost_out_tab(j)
             ,l_fl_revenue_tab(j)
             ,l_fl_tp_rev_in_tab(j)
             ,l_fl_tp_rev_out_tab(j)
             ,l_fl_borrowed_revenue_tab(j)
             ,l_fl_lent_resource_cost_tab(j)
             ,l_fl_unassigned_time_cost_tab(j)
             ,1
             ,sysdate
             ,fnd_global.user_id
             ,fnd_global.login_id
             ,fnd_global.user_id
             ,sysdate);

              l_records_affected := SQL%ROWCOUNT;

                       l_stage :=  7500;
                       -- hr_utility.trace(to_char(l_stage));
              pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                             ': After Inserting Forecast Lines' ;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
              END IF;

              pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                    ': Inserted [' || TO_CHAR(l_records_affected) ||
                    '] Forecast Lines.';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
              END IF;

              END IF;

                       l_stage :=  7600;
                       -- hr_utility.trace(to_char(l_stage));

          DELETE FROM pa_fin_plan_lines_tmp;

                       l_stage :=  7700;
                       -- hr_utility.trace(to_char(l_stage));

                  pa_debug.g_err_stage := l_stage||': fl_count =  ['
                                                 ||l_fl_forecast_line_id_tab.count||']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;

        IF l_fl_forecast_line_id_tab.count > 0 THEN
          FORALL j in l_fl_forecast_line_id_tab.first..l_fl_forecast_line_id_tab.last
            INSERT INTO pa_fin_plan_lines_tmp
            ( resource_assignment_id
             ,object_id
             ,object_type_code
             ,period_name
             ,start_date
             ,end_date
             ,currency_type
             ,currency_code
             ,source_txn_currency_code /* Bug 2796261 */
             ,quantity
             ,raw_cost
             ,burdened_cost
             ,tp_cost_in
             ,tp_cost_out
             ,lent_resource_cost
             ,unassigned_time_cost
             ,cost_adj
             ,revenue
             ,borrowed_revenue
             ,tp_revenue_in
             ,tp_revenue_out
             ,revenue_adj
             ,utilization_percent
             ,utilization_adj
             ,utilization_hours
             ,capacity
             ,head_count
             ,head_count_adj
             ,margin
             ,margin_percentage)
            SELECT
              -1
             ,l_fl_forecast_element_id_tab(j)
             ,'FCST_ELEMENTS'
             ,l_fl_period_name_tab(j)
             ,l_fl_start_date_tab(j)
             ,l_fl_end_date_tab(j)
             ,'PROJ_FUNCTIONAL'
             ,l_org_projfunc_currency_code
             ,l_org_projfunc_currency_code  /* 2796261 */
             ,l_fl_quantity_tab(j)
             ,l_fl_raw_cost_tab(j)
             ,l_fl_burdened_cost_tab(j)
             ,l_fl_tp_cost_in_tab(j)
             ,l_fl_tp_cost_out_tab(j)
             ,l_fl_lent_resource_cost_tab(j)
             ,l_fl_unassigned_time_cost_tab(j)
             ,0
             ,l_fl_revenue_tab(j)
             ,l_fl_borrowed_revenue_tab(j)
             ,l_fl_tp_rev_in_tab(j)
             ,l_fl_tp_rev_out_tab(j)
             ,0
             ,0
             ,0
             ,0
             ,0
             ,0
             ,0
             ,DECODE(SIGN(
               l_fl_revenue_tab(j)+
               l_fl_borrowed_revenue_tab(j)+
               l_fl_tp_rev_in_tab(j)-
               l_fl_tp_rev_out_tab(j)),0,0,-1,0,
              (l_fl_revenue_tab(j)+
               l_fl_borrowed_revenue_tab(j)+
               l_fl_tp_rev_in_tab(j)-
               l_fl_tp_rev_out_tab(j)) -
              (l_fl_burdened_cost_tab(j)+
               l_fl_lent_resource_cost_tab(j)+
               l_fl_unassigned_time_cost_tab(j)+
               l_fl_tp_cost_in_tab(j)-
               l_fl_tp_cost_out_tab(j)))
             ,DECODE(SIGN(
               l_fl_revenue_tab(j)+
               l_fl_borrowed_revenue_tab(j)+
               l_fl_tp_rev_in_tab(j)-
               l_fl_tp_rev_out_tab(j)),0,0,-1,0,
              ((l_fl_revenue_tab(j)+
               l_fl_borrowed_revenue_tab(j)+
               l_fl_tp_rev_in_tab(j)-
               l_fl_tp_rev_out_tab(j)) -
              (l_fl_burdened_cost_tab(j)+
               l_fl_lent_resource_cost_tab(j)+
               l_fl_unassigned_time_cost_tab(j)+
               l_fl_tp_cost_in_tab(j)-
               l_fl_tp_cost_out_tab(j)))/
              (l_fl_revenue_tab(j)+
               l_fl_borrowed_revenue_tab(j)+
               l_fl_tp_rev_in_tab(j)-
               l_fl_tp_rev_out_tab(j)) * 100)
             FROM DUAL;

                       l_stage :=  7800;
                       -- hr_utility.trace(to_char(l_stage));
              l_records_affected := SQL%ROWCOUNT;

              pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                             ': After Inserting Fin Plan Lines Tmp' ;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
              END IF;

              pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                    ': Inserted [' || TO_CHAR(l_records_affected) ||
                    '] Fin Plan Lines Tmp.';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
              END IF;

          /* Populate Project Periods Denorm for Forecast Lines */

                       l_stage :=  7900;
                       -- hr_utility.trace(to_char(l_stage));
              Pa_Plan_Matrix.Maintain_Plan_Matrix
               ( p_amount_type_tab   => amt_rec
                ,p_period_profile_id => l_period_profile_id
                ,p_prior_period_flag => 'N'
                ,p_commit_Flag       => 'N'
                ,p_budget_version_id => l_budget_version_id
                ,p_project_id        => l_project_id
                ,p_debug_mode        => l_debug_mode
                ,p_add_msg_in_stack  => 'Y'
                ,x_return_status     => l_return_status
                ,x_msg_count         => l_msg_count
                ,x_msg_data          => errbuff   );

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                          ': Error creating Period Denorm';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_period_profile_id     ['||l_period_profile_id      || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_budget_version_id     ['||l_budget_version_id      || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_project_id            ['||l_project_id             || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  rollback to org_project;
                  RAISE pa_fp_org_fcst_gen_pub.error_reloop;
               END IF;

            END IF;

                       l_stage :=  8000;
                       -- hr_utility.trace(to_char(l_stage));

         /* For forecast items */
         l_fi_organization_id_tab.delete;
         l_fi_proj_organization_tab.delete;
         l_fi_proj_orgid_tab.delete;
         l_fi_exp_organization_id_tab.delete;
         l_fi_exp_orgid_tab.delete;
         l_fi_txn_project_id_tab.delete;
         l_fi_assignment_id_tab.delete;
         l_fi_resource_id_tab.delete;
         l_fi_period_name_tab.delete;
         l_fi_start_date_tab.delete;
         l_fi_end_date_tab.delete;
         l_fi_item_quantity_tab.delete;
         l_fi_raw_cost_tab.delete;
         l_fi_burdened_cost_tab.delete;
         l_fi_tp_cost_in_tab.delete;
         l_fi_tp_cost_out_tab.delete;
         l_fi_revenue_tab.delete;
         l_fi_tp_rev_in_tab.delete;
         l_fi_tp_rev_out_tab.delete;
         l_fi_borrowed_revenue_tab.delete;
         l_fi_lent_resource_cost_tab.delete;
         l_fi_unassigned_time_cost_tab.delete;

         /* Forecast Element PL/SQL Tables */
         l_fe_forecast_element_id_tab.delete;
         l_fe_organization_id_tab.delete;
         l_fe_org_id_tab.delete;
         l_fe_budget_version_id_tab.delete;
         l_fe_project_id_tab.delete;
         l_fe_task_id_tab.delete;
         l_fe_pvdr_rcvr_code_tab.delete;
         l_fe_other_organization_id_tab.delete;
         l_fe_other_org_id_tab.delete;
         l_fe_txn_project_id_tab.delete;
         l_fe_assignment_id_tab.delete;
         l_fe_resource_id_tab.delete;

         /* Forecast Lines PL/SQL Tables */
         l_fl_forecast_line_id_tab.delete;
         l_fl_forecast_element_id_tab.delete;
         l_fl_budget_version_id_tab.delete;
         l_fl_project_id_tab.delete;
         l_fl_task_id_tab.delete;
         l_fl_period_name_tab.delete;
         l_fl_start_date_tab.delete;
         l_fl_end_date_tab.delete;
         l_fl_quantity_tab.delete;
         l_fl_raw_cost_tab.delete;
         l_fl_burdened_cost_tab.delete;
         l_fl_tp_cost_in_tab.delete;
         l_fl_tp_cost_out_tab.delete;
         l_fl_revenue_tab.delete;
         l_fl_tp_rev_in_tab.delete;
         l_fl_tp_rev_out_tab.delete;
         l_fl_borrowed_revenue_tab.delete;
         l_fl_lent_resource_cost_tab.delete;
         l_fl_unassigned_time_cost_tab.delete;

     END LOOP; /*  BULK FETCH OF FORECAST ITEMS */
     CLOSE forecast_items;

                       l_stage :=  8100;
                       -- hr_utility.trace(to_char(l_stage));
                       pa_debug.g_err_stage := l_stage||': Populate amt_rec for Budget Lines Denorm';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
   /* Populate amt_rec for Budget Lines Denorm */
     amt_rec.delete;

     amt_rec(1).amount_type_code := 'QUANTITY';
     amt_rec(1).amount_subtype_code := 'QUANTITY';
     amt_rec(1).amount_type_id := get_amttype_id(p_amt_typ_code => 'QUANTITY');
     amt_rec(1).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'QUANTITY');

     amt_rec(2).amount_type_code := 'COST';
     amt_rec(2).amount_subtype_code := 'OWN_PROJECT_COST';
     amt_rec(2).amount_type_id := get_amttype_id(p_amt_typ_code => 'COST');
     amt_rec(2).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'OWN_PROJECT_COST');

     amt_rec(3).amount_type_code := 'COST';
     amt_rec(3).amount_subtype_code := 'TP_COST_IN';
     amt_rec(3).amount_type_id := get_amttype_id(p_amt_typ_code => 'COST');
     amt_rec(3).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'TP_COST_IN');

     amt_rec(4).amount_type_code := 'COST';
     amt_rec(4).amount_subtype_code := 'TP_COST_OUT';
     amt_rec(4).amount_type_id := get_amttype_id(p_amt_typ_code => 'COST');
     amt_rec(4).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'TP_COST_OUT');

     amt_rec(5).amount_type_code := 'COST';
     amt_rec(5).amount_subtype_code := 'LENT_RESOURCE_COST';
     amt_rec(5).amount_type_id := get_amttype_id(p_amt_typ_code => 'COST');
     amt_rec(5).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'LENT_RESOURCE_COST');

     amt_rec(6).amount_type_code := 'COST';
     amt_rec(6).amount_subtype_code := 'UNASSIGNED_TIME_COST';
     amt_rec(6).amount_type_id := get_amttype_id(p_amt_typ_code => 'COST');
     amt_rec(6).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'UNASSIGNED_TIME_COST');

     amt_rec(7).amount_type_code := 'REVENUE';
     amt_rec(7).amount_subtype_code := 'OWN_REVENUE';
     amt_rec(7).amount_type_id := get_amttype_id(p_amt_typ_code => 'REVENUE');
     amt_rec(7).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'OWN_REVENUE');

     amt_rec(8).amount_type_code := 'REVENUE';
     amt_rec(8).amount_subtype_code := 'BORROWED_REVENUE';
     amt_rec(8).amount_type_id := get_amttype_id(p_amt_typ_code => 'REVENUE');
     amt_rec(8).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'BORROWED_REVENUE');

     amt_rec(9).amount_type_code := 'REVENUE';
     amt_rec(9).amount_subtype_code := 'TP_REVENUE_IN';
     amt_rec(9).amount_type_id := get_amttype_id(p_amt_typ_code => 'REVENUE');
     amt_rec(9).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'TP_REVENUE_IN');

     amt_rec(10).amount_type_code := 'REVENUE';
     amt_rec(10).amount_subtype_code := 'TP_REVENUE_OUT';
     amt_rec(10).amount_type_id := get_amttype_id(p_amt_typ_code => 'REVENUE');
     amt_rec(10).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'TP_REVENUE_OUT');

     amt_rec(11).amount_type_code := 'MARGIN';
     amt_rec(11).amount_subtype_code := 'MARGIN';
     amt_rec(11).amount_type_id := get_amttype_id(p_amt_typ_code => 'MARGIN');
     amt_rec(11).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'MARGIN');

     amt_rec(12).amount_type_code := 'MARGIN_PERCENT';
     amt_rec(12).amount_subtype_code := 'MARGIN_PERCENT';
     amt_rec(12).amount_type_id := get_amttype_id(p_amt_typ_code => 'MARGIN_PERCENT');
     amt_rec(12).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'MARGIN_PERCENT');

     amt_rec(13).amount_type_code := 'UTILIZATION';
     amt_rec(13).amount_subtype_code := 'UTILIZATION_PERCENT';
     amt_rec(13).amount_type_id := get_amttype_id(p_amt_typ_code => 'UTILIZATION');
     amt_rec(13).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'UTILIZATION_PERCENT');

    /*
     amt_rec(14).amount_type_code := 'UTILIZATION';
     amt_rec(14).amount_subtype_code := 'UTILIZATION_HOURS';
     amt_rec(14).amount_type_id := get_amttype_id(p_amt_typ_code => 'UTILIZATION');
     amt_rec(14).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'UTILIZATION_HOURS');

     amt_rec(15).amount_type_code := 'UTILIZATION';
     amt_rec(15).amount_subtype_code := 'CAPACITY';
     amt_rec(15).amount_type_id := get_amttype_id(p_amt_typ_code => 'UTILIZATION');
     amt_rec(15).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'CAPACITY');
    */

     amt_rec(14).amount_type_code := 'HEADCOUNT';
     amt_rec(14).amount_subtype_code := 'BEGIN_HEADCOUNT';
     amt_rec(14).amount_type_id := get_amttype_id(p_amt_typ_code => 'HEADCOUNT');
     amt_rec(14).amount_subtype_id := get_amttype_id(p_amt_typ_code => 'BEGIN_HEADCOUNT');

                       l_stage :=  8200;
                       -- hr_utility.trace(to_char(l_stage));
                       pa_debug.g_err_stage := l_stage||': Create Resource Assignments for Own Task';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
     /* Create Resource Assignments for Own Task */

        l_own_resource_assignment_id := NULL;

        pa_fp_resource_assignments_pkg.Insert_Row
        ( px_resource_assignment_id      => l_own_resource_assignment_id
         ,p_budget_version_id            => l_budget_version_id
         ,p_project_id                   => l_project_id
         ,p_task_id                      => l_own_task_id
         ,p_resource_list_member_id      => l_resource_list_member_id
         ,p_unit_of_measure              => 'HOURS'
         ,p_track_as_labor_flag          => 'Y'
         ,p_standard_bill_rate           => Null
         ,p_average_bill_rate            => Null
         ,p_average_cost_rate            => Null
         ,p_project_assignment_id        => -1
         ,p_plan_error_code              => Null
         ,p_total_plan_revenue           => 0
         ,p_total_plan_raw_cost          => 0
         ,p_total_plan_burdened_cost     => 0
         ,p_total_plan_quantity          => 0
         ,p_average_discount_percentage  => Null
         ,p_total_borrowed_revenue       => 0
         ,p_total_tp_revenue_in          => 0
         ,p_total_tp_revenue_out         => 0
         ,p_total_revenue_adj            => 0
         ,p_total_lent_resource_cost     => 0
         ,p_total_tp_cost_in             => 0
         ,p_total_tp_cost_out            => 0
         ,p_total_cost_adj               => 0
         ,p_total_unassigned_time_cost   => 0
         ,p_total_utilization_percent    => 0
         ,p_total_utilization_hours      => 0
         ,p_total_utilization_adj        => 0
         ,p_total_capacity               => 0
         ,p_total_head_count             => 0
         ,p_total_head_count_adj         => 0
         ,p_resource_assignment_type     => 'OWN'
         ,x_row_id                       => l_row_id
         ,x_return_status                => l_return_status );

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                          ': Error creating Resource Assignment';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_budget_version_id      ['||l_budget_version_id      || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_project_id             ['||l_project_id             || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_own_task_id            ['||l_own_task_id            || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_resource_list_member_id['||l_resource_list_member_id|| ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  rollback to org_project;
                  RAISE pa_fp_org_fcst_gen_pub.error_reloop;
               END IF;

                       l_stage :=  8300;
                       -- hr_utility.trace(to_char(l_stage));

         l_bl_budget_version_id_tab.delete;     /* FPB2: budget_version_id */
         l_bl_res_asg_id_tab.delete;
         l_bl_start_date_tab.delete;
         l_bl_end_date_tab.delete;
         l_bl_period_name_tab.delete;
         l_bl_quantity_tab.delete;
         l_bl_raw_cost_tab.delete;
         l_bl_burdened_cost_tab.delete;
         l_bl_revenue_tab.delete;
         l_bl_borrowed_revenue_tab.delete;
         l_bl_tp_revenue_in_tab.delete;
         l_bl_tp_revenue_out_tab.delete;
         l_bl_lent_resource_cost_tab.delete;
         l_bl_tp_cost_in_tab.delete;
         l_bl_tp_cost_out_tab.delete;
         l_bl_unassigned_time_cost_tab.delete;
         l_bl_utilization_percent_tab.delete;
         l_bl_utilization_hours_tab.delete;
         l_bl_capacity_tab.delete;
         l_bl_head_count_tab.delete;

         IF NOT fl_lines_task%ISOPEN THEN
           OPEN fl_lines_task;
         ELSE
           CLOSE fl_lines_task;
           OPEN fl_lines_task;
         END IF;

                       l_stage :=  8400;
                       -- hr_utility.trace(to_char(l_stage));

         FETCH fl_lines_task BULK COLLECT INTO
           l_bl_budget_version_id_tab          /* FPB2: budget_version_id */
          ,l_bl_res_asg_id_tab
          ,l_bl_period_name_tab
          ,l_bl_start_date_tab
          ,l_bl_end_date_tab
          ,l_bl_quantity_tab
          ,l_bl_raw_cost_tab
          ,l_bl_burdened_cost_tab
          ,l_bl_revenue_tab
          ,l_bl_borrowed_revenue_tab
          ,l_bl_tp_revenue_in_tab
          ,l_bl_tp_revenue_out_tab
          ,l_bl_lent_resource_cost_tab
          ,l_bl_tp_cost_in_tab
          ,l_bl_tp_cost_out_tab
          ,l_bl_unassigned_time_cost_tab;


                       l_stage :=  8500;
                       -- hr_utility.trace(to_char(l_stage));

        IF NVL(l_bl_res_asg_id_tab.count,0) =0 THEN
                       l_stage :=  8600;
                       -- hr_utility.trace(to_char(l_stage));
                         pa_debug.g_err_stage := l_stage||': Exiting fl_lines_task loop no rows to process';
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                         END IF;
        ELSE

          FOR i in l_bl_res_asg_id_tab.first..l_bl_res_asg_id_tab.last LOOP
                       l_stage :=  8700;
                       -- hr_utility.trace(to_char(l_stage));

           /* API call changed from pa_fp_org_fcst_utils.get_utilization_details
              to pa_pji_util_pkg.get_utilization_dtls to get the Utilization
              numbers from PJI data model if PJI is installed. */

           pa_pji_util_pkg.get_utilization_dtls
           ( p_org_id                => l_org_id
            ,p_organization_id       => l_organization_id
            ,p_period_type           => l_org_fcst_period_type
            ,p_period_set_name       => l_period_set_name
            ,p_period_name           => l_bl_period_name_tab(i)
            ,x_utl_hours             => l_bl_utilization_hours_tab(i)
            ,x_utl_capacity          => l_bl_capacity_tab(i)
            ,x_utl_percent           => l_bl_utilization_percent_tab(i)
            ,x_return_status         => l_return_status
            ,x_err_code              => l_err_code);

               -- hr_utility.trace(l_err_code);

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                          ':Error getting utilization details'||'-'||l_err_code;
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_org_id                ['||l_org_id                 || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_organization_id       ['||l_organization_id        || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_org_fcst_period_type  ['||l_org_fcst_period_type   || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_period_set_name       ['||l_period_set_name        || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_bl_period_name_tab    ['||l_bl_period_name_tab(i)  || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  rollback to org_project;
                  RAISE pa_fp_org_fcst_gen_pub.error_reloop;
               END IF;

                       l_stage :=  8800;
                       -- hr_utility.trace(to_char(l_stage));

           pa_fp_org_fcst_utils.get_headcount
           ( p_organization_id       => l_organization_id
            ,p_effective_date        => l_bl_start_date_tab(i)
            ,x_headcount             => l_bl_head_count_tab(i)
            ,x_return_status         => l_return_status
            ,x_err_code              => l_err_code);

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                          ':Error getting Head Count';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage :=
                                 'l_organization_id       ['||l_organization_id        ||
                               '] l_bl_start_date_tab     ['||l_bl_start_date_tab(i)   ||
                               ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  rollback to org_project;
                  RAISE pa_fp_org_fcst_gen_pub.error_reloop;
               END IF;
                       l_stage :=  8900;
                       -- hr_utility.trace(to_char(l_stage));
          END LOOP;
          CLOSE fl_lines_task;

                       l_stage :=  9000;
                       -- hr_utility.trace(to_char(l_stage));
                       pa_debug.g_err_stage := l_stage||': Create Budget Lines for Own Task';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;

          /* Bulk insert into Budget Lines for Own Numbers Phase I */
        IF l_bl_res_asg_id_tab.count > 0 THEN
          FORALL i in l_bl_res_asg_id_tab.first..l_bl_res_asg_id_tab.last
            INSERT INTO pa_budget_lines
             ( budget_line_id                        /* FPB2 */
              ,budget_version_id                     /* FPB2  */
              ,txn_currency_code                     /* FPB4 */
	      ,resource_assignment_id
              ,period_name
              ,start_date
              ,end_date
              ,quantity
              ,raw_cost
              ,burdened_cost
              ,lent_resource_cost
              ,unassigned_time_cost
              ,tp_cost_in
              ,tp_cost_out
              ,revenue
              ,borrowed_revenue
              ,tp_revenue_in
              ,tp_revenue_out
              ,quantity_source
              ,raw_cost_source
              ,burdened_cost_source
              ,revenue_source
              ,utilization_percent
              ,utilization_hours
              ,capacity
              ,head_count
              ,creation_date
              ,created_by
              ,last_update_login
              ,last_updated_by
              ,last_update_date
             ) VALUES (
               pa_budget_lines_s.nextval     /* FPB2 */
              ,l_bl_budget_version_id_tab(i) /* FPB2 */
              ,l_org_projfunc_currency_code  /* FPB4 */
              ,l_bl_res_asg_id_tab(i)
              ,l_bl_period_name_tab(i)
              ,l_bl_start_date_tab(i)
              ,l_bl_end_date_tab(i)
              ,l_bl_quantity_tab(i)
              ,l_bl_raw_cost_tab(i)
              ,l_bl_burdened_cost_tab(i)
              ,l_bl_lent_resource_cost_tab(i)
              ,l_bl_unassigned_time_cost_tab(i)
              ,l_bl_tp_cost_in_tab(i)
              ,l_bl_tp_cost_out_tab(i)
              ,l_bl_revenue_tab(i)
              ,l_bl_borrowed_revenue_tab(i)
              ,l_bl_tp_revenue_in_tab(i)
              ,l_bl_tp_revenue_out_tab(i)
              ,'C'
              ,'C'
              ,'C'
              ,'C'
              ,l_bl_utilization_percent_tab(i)
              ,l_bl_utilization_hours_tab(i)
              ,l_bl_capacity_tab(i)
              ,l_bl_head_count_tab(i)
              ,sysdate
              ,fnd_global.user_id
              ,fnd_global.login_id
              ,fnd_global.user_id
              ,sysdate);

            END IF;
                       l_stage :=  9100;
                       -- hr_utility.trace(to_char(l_stage));

             /* Need to update Own Level Resource Assignment
                from budget Lines */

             SELECT nvl(sum(bl.quantity),0)
                   ,nvl(sum(bl.raw_cost),0)
                   ,nvl(sum(bl.burdened_cost),0)
                   ,nvl(sum(bl.lent_resource_cost),0)
                   ,nvl(sum(bl.unassigned_time_cost),0)
                   ,nvl(sum(bl.tp_cost_in),0)
                   ,nvl(sum(bl.tp_cost_out),0)
                   ,nvl(sum(bl.revenue),0)
                   ,nvl(sum(bl.borrowed_revenue),0)
                   ,nvl(sum(bl.tp_revenue_in),0)
                   ,nvl(sum(bl.tp_revenue_out),0)
                   ,nvl(round(avg(bl.utilization_percent)),0)
                   ,nvl(sum(bl.utilization_hours),0)
                   ,nvl(sum(bl.capacity),0)
                   ,nvl(round(avg(bl.head_count)),0)
               INTO budget_lines_rec(1).quantity
                   ,budget_lines_rec(1).raw_cost
                   ,budget_lines_rec(1).burdened_cost
                   ,budget_lines_rec(1).lent_resource_cost
                   ,budget_lines_rec(1).unassigned_time_cost
                   ,budget_lines_rec(1).tp_cost_in
                   ,budget_lines_rec(1).tp_cost_out
                   ,budget_lines_rec(1).revenue
                   ,budget_lines_rec(1).borrowed_revenue
                   ,budget_lines_rec(1).tp_revenue_in
                   ,budget_lines_rec(1).tp_revenue_out
                   ,budget_lines_rec(1).utilization_percent
                   ,budget_lines_rec(1).utilization_hours
                   ,budget_lines_rec(1).capacity
                   ,budget_lines_rec(1).head_count
              FROM pa_budget_lines bl
             WHERE bl.resource_assignment_id = l_own_resource_assignment_id;

                       l_stage :=  9200;
                       -- hr_utility.trace(to_char(l_stage));

             IF budget_lines_rec.COUNT = 1 THEN
                       l_stage :=  9300;
                       -- hr_utility.trace(to_char(l_stage));
                       pa_debug.g_err_stage := l_stage||': Update Resource Assignments for Own Task';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;

                UPDATE pa_resource_assignments
                   SET
                   last_update_date = sysdate
                  ,last_updated_by = fnd_global.user_id
                  ,last_update_login = fnd_global.login_id
                  ,total_plan_revenue = budget_lines_rec(1).revenue
                  ,total_plan_raw_cost = budget_lines_rec(1).raw_cost
                  ,total_plan_burdened_cost = budget_lines_rec(1).burdened_cost
                  ,total_plan_quantity = budget_lines_rec(1).quantity
                  ,total_borrowed_revenue = budget_lines_rec(1).borrowed_revenue
                  ,total_tp_revenue_in = budget_lines_rec(1).tp_revenue_in
                  ,total_tp_revenue_out = budget_lines_rec(1).tp_revenue_out
                  ,total_lent_resource_cost = budget_lines_rec(1).lent_resource_cost
                  ,total_tp_cost_in = budget_lines_rec(1).tp_cost_in
                  ,total_tp_cost_out = budget_lines_rec(1).tp_cost_out
                  ,total_unassigned_time_cost = budget_lines_rec(1).unassigned_time_cost
                  ,total_utilization_percent = budget_lines_rec(1).utilization_percent
                  ,total_utilization_hours = budget_lines_rec(1).utilization_hours
                  ,total_capacity = budget_lines_rec(1).capacity
                  ,total_head_count = budget_lines_rec(1).head_count
                WHERE resource_assignment_id = l_own_resource_assignment_id;

                       l_stage :=  9400;
                       -- hr_utility.trace(to_char(l_stage));
             END IF;
                       l_stage :=  9500;
                       -- hr_utility.trace(to_char(l_stage));

          budget_lines_rec.DELETE;
          DELETE FROM pa_fin_plan_lines_tmp;

                       l_stage :=  9600;
                       -- hr_utility.trace(to_char(l_stage));

          FORALL i in l_bl_res_asg_id_tab.first..l_bl_res_asg_id_tab.last
            INSERT INTO pa_fin_plan_lines_tmp
            ( resource_assignment_id
             ,object_id
             ,object_type_code
             ,period_name
             ,start_date
             ,end_date
             ,currency_type
             ,currency_code
             ,source_txn_currency_code /* Bug 2796261 */
             ,quantity
             ,raw_cost
             ,burdened_cost
             ,tp_cost_in
             ,tp_cost_out
             ,lent_resource_cost
             ,unassigned_time_cost
             ,cost_adj
             ,revenue
             ,borrowed_revenue
             ,tp_revenue_in
             ,tp_revenue_out
             ,revenue_adj
             ,utilization_percent
             ,utilization_adj
             ,utilization_hours
             ,capacity
             ,head_count
             ,head_count_adj
             ,margin
             ,margin_percentage)
            SELECT
              l_bl_res_asg_id_tab(i)
             ,l_bl_res_asg_id_tab(i)
             ,'RES_ASSIGNMENT'
             ,l_bl_period_name_tab(i)
             ,l_bl_start_date_tab(i)
             ,l_bl_end_date_tab(i)
             ,'PROJ_FUNCTIONAL'
             ,l_org_projfunc_currency_code
             ,l_org_projfunc_currency_code  /* 2796261 */
             ,l_bl_quantity_tab(i)
             ,l_bl_raw_cost_tab(i)
             ,l_bl_burdened_cost_tab(i)
             ,l_bl_tp_cost_in_tab(i)
             ,l_bl_tp_cost_out_tab(i)
             ,l_bl_lent_resource_cost_tab(i)
             ,l_bl_unassigned_time_cost_tab(i)
             ,0
             ,l_bl_revenue_tab(i)
             ,l_bl_borrowed_revenue_tab(i)
             ,l_bl_tp_revenue_in_tab(i)
             ,l_bl_tp_revenue_out_tab(i)
             ,0
             ,l_bl_utilization_percent_tab(i)
             ,0
             ,l_bl_utilization_hours_tab(i)
             ,l_bl_capacity_tab(i)
             ,l_bl_head_count_tab(i)
             ,0
             ,DECODE(SIGN(
               l_bl_revenue_tab(i)+
               l_bl_borrowed_revenue_tab(i)+
               l_bl_tp_revenue_in_tab(i)-
               l_bl_tp_revenue_out_tab(i)),0,0,-1,0,
              (l_bl_revenue_tab(i)+
               l_bl_borrowed_revenue_tab(i)+
               l_bl_tp_revenue_in_tab(i)-
               l_bl_tp_revenue_out_tab(i)) -
              (l_bl_burdened_cost_tab(i)+
               l_bl_lent_resource_cost_tab(i)+
               l_bl_unassigned_time_cost_tab(i)+
               l_bl_tp_cost_in_tab(i)-
               l_bl_tp_cost_out_tab(i)))
             ,DECODE(SIGN(
               l_bl_revenue_tab(i)+
               l_bl_borrowed_revenue_tab(i)+
               l_bl_tp_revenue_in_tab(i)-
               l_bl_tp_revenue_out_tab(i)),0,0,-1,0,
              ((l_bl_revenue_tab(i)+
               l_bl_borrowed_revenue_tab(i)+
               l_bl_tp_revenue_in_tab(i)-
               l_bl_tp_revenue_out_tab(i)) -
              (l_bl_burdened_cost_tab(i)+
               l_bl_lent_resource_cost_tab(i)+
               l_bl_unassigned_time_cost_tab(i)+
               l_bl_tp_cost_in_tab(i)-
               l_bl_tp_cost_out_tab(i)))/
              (l_bl_revenue_tab(i)+
               l_bl_borrowed_revenue_tab(i)+
               l_bl_tp_revenue_in_tab(i)-
               l_bl_tp_revenue_out_tab(i)) * 100)
             FROM DUAL;

                       l_stage :=  9700;
                       -- hr_utility.trace(to_char(l_stage));
              l_records_affected := SQL%ROWCOUNT;

              pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                             ': After Inserting Fin Plan Lines Tmp' ;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
              END IF;

              pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                    ': Inserted [' || TO_CHAR(l_records_affected) ||
                    '] Fin Plan Lines Tmp.';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
              END IF;

          /* Populate Project Periods Denorm for Budget Lines */

                       l_stage :=  9800;
                       -- hr_utility.trace(to_char(l_stage));
                       pa_debug.g_err_stage := l_stage||': Populate Project Periods Denorm for Budget Lines';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
              Pa_Plan_Matrix.Maintain_Plan_Matrix
               ( p_amount_type_tab   => amt_rec
                ,p_period_profile_id => l_period_profile_id
                ,p_prior_period_flag => 'N'
                ,p_commit_Flag       => 'N'
                ,p_budget_version_id => l_budget_version_id
                ,p_project_id        => l_project_id
                ,p_debug_mode        => l_debug_mode
                ,p_add_msg_in_stack  => 'Y'
                ,x_return_status     => l_return_status
                ,x_msg_count         => l_msg_count
                ,x_msg_data          => errbuff   );

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                          ':Error creating Period Denorm';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_period_profile_id     ['||l_period_profile_id      || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_budget_version_id     ['||l_budget_version_id      || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_project_id            ['||l_project_id             || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  rollback to org_project;
                  RAISE pa_fp_org_fcst_gen_pub.error_reloop;
               END IF;
       END IF; /* l_bl_res_asg_id_tab.count <> 0 */

                       l_stage :=  9900;
                       -- hr_utility.trace(to_char(l_stage));
                       pa_debug.g_err_stage := l_stage||': Create Resource Assignments for Project Task';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;

        /* Now one pass for Project level numbers */
        /* Create Resource assignment with task_id = 0 */

        l_proj_resource_assignment_id := NULL;

        pa_fp_resource_assignments_pkg.Insert_Row
        ( px_resource_assignment_id      => l_proj_resource_assignment_id
         ,p_budget_version_id            => l_budget_version_id
         ,p_project_id                   => l_project_id
         ,p_task_id                      => 0
         ,p_resource_list_member_id      => l_resource_list_member_id
         ,p_unit_of_measure              => 'HOURS'
         ,p_track_as_labor_flag          => 'Y'
         ,p_standard_bill_rate           => Null
         ,p_average_bill_rate            => Null
         ,p_average_cost_rate            => Null
         ,p_project_assignment_id        => -1
         ,p_plan_error_code              => Null
         ,p_total_plan_revenue           => 0
         ,p_total_plan_raw_cost          => 0
         ,p_total_plan_burdened_cost     => 0
         ,p_total_plan_quantity          => 0
         ,p_average_discount_percentage  => Null
         ,p_total_borrowed_revenue       => 0
         ,p_total_tp_revenue_in          => 0
         ,p_total_tp_revenue_out         => 0
         ,p_total_revenue_adj            => 0
         ,p_total_lent_resource_cost     => 0
         ,p_total_tp_cost_in             => 0
         ,p_total_tp_cost_out            => 0
         ,p_total_cost_adj               => 0
         ,p_total_unassigned_time_cost   => 0
         ,p_total_utilization_percent    => 0
         ,p_total_utilization_hours      => 0
         ,p_total_utilization_adj        => 0
         ,p_total_capacity               => 0
         ,p_total_head_count             => 0
         ,p_total_head_count_adj         => 0
         ,p_resource_assignment_type     => 'PROJECT'
         ,x_row_id                       => l_row_id
         ,x_return_status                => l_return_status );

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                          ': Error creating Proj Resource Assignment';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_budget_version_id      ['||l_budget_version_id      || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_project_id             ['||l_project_id             || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage := 'l_resource_list_member_id['||l_resource_list_member_id|| ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  rollback to org_project;
                  RAISE pa_fp_org_fcst_gen_pub.error_reloop;
               END IF;

                       l_stage := 10000;
                       -- hr_utility.trace(to_char(l_stage));

      /* Budget Lines for Project Level Task */

         IF NOT bl_lines_project%ISOPEN THEN
           OPEN bl_lines_project;
         ELSE
           CLOSE bl_lines_project;
           OPEN bl_lines_project;
         END IF;

                       l_stage := 10100;
                       -- hr_utility.trace(to_char(l_stage));

         l_bl_budget_version_id_tab.delete;       /* FPB2: budget_version_id */
         l_bl_res_asg_id_tab.delete;
         l_bl_start_date_tab.delete;
         l_bl_end_date_tab.delete;
         l_bl_period_name_tab.delete;
         l_bl_quantity_tab.delete;
         l_bl_raw_cost_tab.delete;
         l_bl_burdened_cost_tab.delete;
         l_bl_revenue_tab.delete;
         l_bl_borrowed_revenue_tab.delete;
         l_bl_tp_revenue_in_tab.delete;
         l_bl_tp_revenue_out_tab.delete;
         l_bl_lent_resource_cost_tab.delete;
         l_bl_tp_cost_in_tab.delete;
         l_bl_tp_cost_out_tab.delete;
         l_bl_unassigned_time_cost_tab.delete;
         l_bl_utilization_percent_tab.delete;
         l_bl_utilization_hours_tab.delete;
         l_bl_capacity_tab.delete;
         l_bl_head_count_tab.delete;

         FETCH bl_lines_project BULK COLLECT INTO
           l_bl_budget_version_id_tab  /* FPB2: budget_version_id */
          ,l_bl_res_asg_id_tab
          ,l_bl_period_name_tab
          ,l_bl_start_date_tab
          ,l_bl_end_date_tab
          ,l_bl_quantity_tab
          ,l_bl_raw_cost_tab
          ,l_bl_burdened_cost_tab
          ,l_bl_revenue_tab
          ,l_bl_borrowed_revenue_tab
          ,l_bl_tp_revenue_in_tab
          ,l_bl_tp_revenue_out_tab
          ,l_bl_lent_resource_cost_tab
          ,l_bl_tp_cost_in_tab
          ,l_bl_tp_cost_out_tab
          ,l_bl_unassigned_time_cost_tab
          ,l_bl_utilization_percent_tab
          ,l_bl_utilization_hours_tab
          ,l_bl_capacity_tab
          ,l_bl_head_count_tab;

                       l_stage := 10200;
                       -- hr_utility.trace(to_char(l_stage));
       IF NVL(l_bl_res_asg_id_tab.count,0) =0 THEN
                       l_stage := 10300;
                       -- hr_utility.trace(to_char(l_stage));
       ELSE
          /* Bulk insert into Budget Lines for Project Numbers */
                       pa_debug.g_err_stage := l_stage||': Create Budget Lines for Project Level Task';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
          FORALL i in l_bl_res_asg_id_tab.first..l_bl_res_asg_id_tab.last
            INSERT INTO pa_budget_lines
             ( budget_line_id                 /* FPB2 budget_line_id */
              ,budget_version_id              /* FPB2 */
              ,txn_currency_code              /* FPB4 */
	      ,resource_assignment_id
              ,period_name
              ,start_date
              ,end_date
              ,quantity
              ,raw_cost
              ,burdened_cost
              ,lent_resource_cost
              ,unassigned_time_cost
              ,tp_cost_in
              ,tp_cost_out
              ,revenue
              ,borrowed_revenue
              ,tp_revenue_in
              ,tp_revenue_out
              ,quantity_source
              ,raw_cost_source
              ,burdened_cost_source
              ,revenue_source
              ,utilization_percent
              ,utilization_hours
              ,capacity
              ,head_count
              ,creation_date
              ,created_by
              ,last_update_login
              ,last_updated_by
              ,last_update_date
             ) VALUES (
               pa_budget_lines_s.nextval          /* FPB2: budget_line_id */
              ,l_bl_budget_version_id_tab(i)      /* FPB2: budget_version_id */
              ,l_org_projfunc_currency_code       /* FPB4 */
              ,l_bl_res_asg_id_tab(i)
              ,l_bl_period_name_tab(i)
              ,l_bl_start_date_tab(i)
              ,l_bl_end_date_tab(i)
              ,l_bl_quantity_tab(i)
              ,l_bl_raw_cost_tab(i)
              ,l_bl_burdened_cost_tab(i)
              ,l_bl_lent_resource_cost_tab(i)
              ,l_bl_unassigned_time_cost_tab(i)
              ,l_bl_tp_cost_in_tab(i)
              ,l_bl_tp_cost_out_tab(i)
              ,l_bl_revenue_tab(i)
              ,l_bl_borrowed_revenue_tab(i)
              ,l_bl_tp_revenue_in_tab(i)
              ,l_bl_tp_revenue_out_tab(i)
              ,'C'
              ,'C'
              ,'C'
              ,'C'
              ,l_bl_utilization_percent_tab(i)
              ,l_bl_utilization_hours_tab(i)
              ,l_bl_capacity_tab(i)
              ,l_bl_head_count_tab(i)
              ,sysdate
              ,fnd_global.user_id
              ,fnd_global.login_id
              ,fnd_global.user_id
              ,sysdate);

                       l_stage := 10400;
                       -- hr_utility.trace(to_char(l_stage));

              /* Need to update Project Level Resource Assignment
                 from budget Lines */

              SELECT nvl(sum(bl.quantity),0)
                    ,nvl(sum(bl.raw_cost),0)
                    ,nvl(sum(bl.burdened_cost),0)
                    ,nvl(sum(bl.lent_resource_cost),0)
                    ,nvl(sum(bl.unassigned_time_cost),0)
                    ,nvl(sum(bl.tp_cost_in),0)
                    ,nvl(sum(bl.tp_cost_out),0)
                    ,nvl(sum(bl.revenue),0)
                    ,nvl(sum(bl.borrowed_revenue),0)
                    ,nvl(sum(bl.tp_revenue_in),0)
                    ,nvl(sum(bl.tp_revenue_out),0)
                    ,nvl(round(avg(bl.utilization_percent)),0)
                    ,nvl(sum(bl.utilization_hours),0)
                    ,nvl(sum(bl.capacity),0)
                    ,nvl(round(avg(bl.head_count)),0)
                INTO budget_lines_rec(1).quantity
                    ,budget_lines_rec(1).raw_cost
                    ,budget_lines_rec(1).burdened_cost
                    ,budget_lines_rec(1).lent_resource_cost
                    ,budget_lines_rec(1).unassigned_time_cost
                    ,budget_lines_rec(1).tp_cost_in
                    ,budget_lines_rec(1).tp_cost_out
                    ,budget_lines_rec(1).revenue
                    ,budget_lines_rec(1).borrowed_revenue
                    ,budget_lines_rec(1).tp_revenue_in
                    ,budget_lines_rec(1).tp_revenue_out
                    ,budget_lines_rec(1).utilization_percent
                    ,budget_lines_rec(1).utilization_hours
                    ,budget_lines_rec(1).capacity
                    ,budget_lines_rec(1).head_count
               FROM pa_budget_lines bl
              WHERE bl.resource_assignment_id = l_proj_resource_assignment_id;

                       l_stage := 10500;
                       -- hr_utility.trace(to_char(l_stage));

     IF budget_lines_rec.COUNT = 1 THEN
                       l_stage := 10600;
                       -- hr_utility.trace(to_char(l_stage));
                       pa_debug.g_err_stage := l_stage||': Update Resource Assignments for Project Task';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
     UPDATE pa_resource_assignments
        SET
        last_update_date = sysdate
       ,last_updated_by = fnd_global.user_id
       ,last_update_login = fnd_global.login_id
       ,total_plan_revenue = budget_lines_rec(1).revenue
       ,total_plan_raw_cost = budget_lines_rec(1).raw_cost
       ,total_plan_burdened_cost = budget_lines_rec(1).burdened_cost
       ,total_plan_quantity = budget_lines_rec(1).quantity
       ,total_borrowed_revenue = budget_lines_rec(1).borrowed_revenue
       ,total_tp_revenue_in = budget_lines_rec(1).tp_revenue_in
       ,total_tp_revenue_out = budget_lines_rec(1).tp_revenue_out
       ,total_lent_resource_cost = budget_lines_rec(1).lent_resource_cost
       ,total_tp_cost_in = budget_lines_rec(1).tp_cost_in
       ,total_tp_cost_out = budget_lines_rec(1).tp_cost_out
       ,total_unassigned_time_cost = budget_lines_rec(1).unassigned_time_cost
       ,total_utilization_percent = budget_lines_rec(1).utilization_percent
       ,total_utilization_hours = budget_lines_rec(1).utilization_hours
       ,total_capacity = budget_lines_rec(1).capacity
       ,total_head_count = budget_lines_rec(1).head_count
       WHERE resource_assignment_id = l_proj_resource_assignment_id;

                       l_stage := 10700;
                       -- hr_utility.trace(to_char(l_stage));
     END IF;

     IF budget_lines_rec.COUNT = 1 THEN
                       l_stage := 10800;
                       -- hr_utility.trace(to_char(l_stage));
                       pa_debug.g_err_stage := l_stage||': Update Budget Version for Project Level Numbers';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;

        UPDATE pa_budget_versions
           SET
           record_version_number = record_version_number+1
          ,version_name = DECODE(version_name,null,l_bv_version_name
                                 ||'-'||to_char(l_budget_version_id),
                                 version_name)
          ,last_update_date = sysdate
          ,last_updated_by = fnd_global.user_id
          ,last_update_login = fnd_global.login_id
          ,revenue = budget_lines_rec(1).revenue
          ,raw_cost = budget_lines_rec(1).raw_cost
          ,burdened_cost = budget_lines_rec(1).burdened_cost
          ,labor_quantity = budget_lines_rec(1).quantity
          ,total_borrowed_revenue = budget_lines_rec(1).borrowed_revenue
          ,total_tp_revenue_in = budget_lines_rec(1).tp_revenue_in
          ,total_tp_revenue_out = budget_lines_rec(1).tp_revenue_out
          ,total_lent_resource_cost = budget_lines_rec(1).lent_resource_cost
          ,total_tp_cost_in = budget_lines_rec(1).tp_cost_in
          ,total_tp_cost_out = budget_lines_rec(1).tp_cost_out
          ,total_unassigned_time_cost = budget_lines_rec(1).unassigned_time_cost
          ,total_utilization_percent = budget_lines_rec(1).utilization_percent
          ,total_utilization_hours = budget_lines_rec(1).utilization_hours
          ,total_capacity = budget_lines_rec(1).capacity
          ,total_head_count = budget_lines_rec(1).head_count
          ,plan_processing_code = 'G'
       WHERE budget_version_id = l_budget_version_id;

                       l_stage := 10900;
                       -- hr_utility.trace(to_char(l_stage));
     END IF;

                       l_stage := 11000;
                       -- hr_utility.trace(to_char(l_stage));
         budget_lines_rec.DELETE;

         DELETE FROM pa_fin_plan_lines_tmp;

                       l_stage := 11100;
                       -- hr_utility.trace(to_char(l_stage));

         FORALL i in l_bl_res_asg_id_tab.first..l_bl_res_asg_id_tab.last
           INSERT INTO pa_fin_plan_lines_tmp
            ( resource_assignment_id
             ,object_id
             ,object_type_code
             ,period_name
             ,start_date
             ,end_date
             ,currency_type
             ,currency_code
             ,source_txn_currency_code /* Bug 2796261 */
             ,quantity
             ,raw_cost
             ,burdened_cost
             ,tp_cost_in
             ,tp_cost_out
             ,lent_resource_cost
             ,unassigned_time_cost
             ,cost_adj
             ,revenue
             ,borrowed_revenue
             ,tp_revenue_in
             ,tp_revenue_out
             ,revenue_adj
             ,utilization_percent
             ,utilization_adj
             ,utilization_hours
             ,capacity
             ,head_count
             ,head_count_adj
             ,margin
             ,margin_percentage)
            SELECT
              l_bl_res_asg_id_tab(i)
             ,l_bl_res_asg_id_tab(i)
             ,'RES_ASSIGNMENT'
             ,l_bl_period_name_tab(i)
             ,l_bl_start_date_tab(i)
             ,l_bl_end_date_tab(i)
             ,'PROJ_FUNCTIONAL'
             ,l_org_projfunc_currency_code
             ,l_org_projfunc_currency_code  /* 2796261 */
             ,l_bl_quantity_tab(i)
             ,l_bl_raw_cost_tab(i)
             ,l_bl_burdened_cost_tab(i)
             ,l_bl_tp_cost_in_tab(i)
             ,l_bl_tp_cost_out_tab(i)
             ,l_bl_lent_resource_cost_tab(i)
             ,l_bl_unassigned_time_cost_tab(i)
             ,0
             ,l_bl_revenue_tab(i)
             ,l_bl_borrowed_revenue_tab(i)
             ,l_bl_tp_revenue_in_tab(i)
             ,l_bl_tp_revenue_out_tab(i)
             ,0
             ,l_bl_utilization_percent_tab(i)
             ,0
             ,l_bl_utilization_hours_tab(i)
             ,l_bl_capacity_tab(i)
             ,l_bl_head_count_tab(i)
             ,0
             ,DECODE(SIGN(
               l_bl_revenue_tab(i)+
               l_bl_borrowed_revenue_tab(i)+
               l_bl_tp_revenue_in_tab(i)-
               l_bl_tp_revenue_out_tab(i)),0,0,-1,0,
              (l_bl_revenue_tab(i)+
               l_bl_borrowed_revenue_tab(i)+
               l_bl_tp_revenue_in_tab(i)-
               l_bl_tp_revenue_out_tab(i)) -
              (l_bl_burdened_cost_tab(i)+
               l_bl_lent_resource_cost_tab(i)+
               l_bl_unassigned_time_cost_tab(i)+
               l_bl_tp_cost_in_tab(i)-
               l_bl_tp_cost_out_tab(i)))
             ,DECODE(SIGN(
               l_bl_revenue_tab(i)+
               l_bl_borrowed_revenue_tab(i)+
               l_bl_tp_revenue_in_tab(i)-
               l_bl_tp_revenue_out_tab(i)),0,0,-1,0,
              ((l_bl_revenue_tab(i)+
               l_bl_borrowed_revenue_tab(i)+
               l_bl_tp_revenue_in_tab(i)-
               l_bl_tp_revenue_out_tab(i)) -
              (l_bl_burdened_cost_tab(i)+
               l_bl_lent_resource_cost_tab(i)+
               l_bl_unassigned_time_cost_tab(i)+
               l_bl_tp_cost_in_tab(i)-
               l_bl_tp_cost_out_tab(i)))/
              (l_bl_revenue_tab(i)+
               l_bl_borrowed_revenue_tab(i)+
               l_bl_tp_revenue_in_tab(i)-
               l_bl_tp_revenue_out_tab(i)) * 100)
             FROM DUAL;

                       l_stage :=  11200;
                       -- hr_utility.trace(to_char(l_stage));

              l_records_affected := SQL%ROWCOUNT;

              pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                             ': After Inserting Fin Plan Lines Tmp' ;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
              END IF;

              pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                    ': Inserted [' || TO_CHAR(l_records_affected) ||
                    '] Fin Plan Lines Tmp.';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
              END IF;

                       l_stage :=  11300;
                       -- hr_utility.trace(to_char(l_stage));

          /* Populate Project Periods Denorm for budget lines for Project */
              Pa_Plan_Matrix.Maintain_Plan_Matrix
               ( p_amount_type_tab   => amt_rec
                ,p_period_profile_id => l_period_profile_id
                ,p_prior_period_flag => 'N'
                ,p_commit_Flag       => 'N'
                ,x_return_status     => l_return_status
                ,x_msg_count         => l_msg_count
                ,x_msg_data          => errbuff
                ,p_budget_version_id => l_budget_version_id
                ,p_project_id        => l_project_id);

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                          ':Error creating Period Denorm';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  pa_debug.g_err_stage :=
                                 'l_period_profile_id     ['||l_period_profile_id      ||
                               '] l_budget_version_id     ['||l_budget_version_id      ||
                               '] l_project_id            ['||l_project_id             ||
                               ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  rollback to org_project;
                  RAISE pa_fp_org_fcst_gen_pub.error_reloop;
               END IF;
        END IF;
                       l_stage :=  11400;
                       -- hr_utility.trace(to_char(l_stage));

        IF p_budget_version_id IS NOT NULL THEN
                       l_stage :=  11500;
                       -- hr_utility.trace(to_char(l_stage));
                       pa_debug.g_err_stage := l_stage||': Process Complete for budget version -- EXITING';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
           COMMIT;
           EXIT; -- need to force exit when generating for a budget version.
        END IF;
                       l_stage :=  11600;
                       -- hr_utility.trace(to_char(l_stage));
   EXCEPTION
        WHEN pa_fp_org_fcst_gen_pub.error_reloop THEN
             -- hr_utility.trace('UserDefined Skipping - '||to_char(l_stage)||'-'||SQLERRM);
             pa_debug.g_err_stage := l_stage||': UserDefined Skipping - '||'['||SQLERRM||']';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
             END IF;
             rollback to org_project;
                       IF l_budget_version_id > 0 THEN
                          l_budget_version_in_error := budget_version_in_error(l_budget_version_id);
                          pa_debug.g_err_stage := l_stage||': Budget Version has errored - '
                                                         ||'['||l_budget_version_id||']';
                          IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                          END IF;
                       END IF;
        WHEN OTHERS THEN
             -- hr_utility.trace('UnExpected Skipping - '||to_char(l_stage)||'-'||SQLERRM);
             pa_debug.g_err_stage := l_stage||': UnExpected Skipping - '||'['||SQLERRM||']';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
             END IF;
             pa_debug.g_err_stage := 'l_organization_id       ['||l_organization_id        || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
             pa_debug.g_err_stage := 'l_budget_version_id     ['||l_budget_version_id      || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
             pa_debug.g_err_stage := 'l_project_id            ['||l_project_id             || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
             pa_debug.g_err_stage := 'l_period_profile_id     ['||l_period_profile_id      || ']';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                  END IF;
                  rollback to org_project;
                       IF l_budget_version_id > 0 THEN
                          l_budget_version_in_error := budget_version_in_error(l_budget_version_id);
                          pa_debug.g_err_stage := l_stage||': Budget Version has errored - '
                                                         ||'['||l_budget_version_id||']';
                          IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                          END IF;
                       END IF;
   END;
   COMMIT;
   END LOOP; /* Org Loop */

    IF p_budget_version_id IS NULL THEN
                       l_stage :=  11700;
                       -- hr_utility.trace(to_char(l_stage));
      IF p_starting_organization_id IS NULL THEN
            CLOSE specific_org_only;
                       l_stage :=  11800;
                       -- hr_utility.trace(to_char(l_stage));

	       -- R12 MOAC 4447573
	       If P_PA_DEBUG_MODE = 'Y' THEN
        	   PA_DEBUG.Log_Message(p_message => 'Calling FND_REQUEST.set_org_id{'||l_org_id||'}');
     	       End If;
	       FND_REQUEST.set_org_id(l_org_id);
	       -- end of  R12 MOAC 4447573

               l_request_id := FND_REQUEST.submit_request
               (application                =>   'PA',
                program                    =>   'PAFPEXRP',
                description                =>   'PRC: List Organization Forecast Exceptions',
                start_time                 =>   NULL,
                sub_request                =>   false,
                argument1                  =>   l_org_id,             -- P_ORG_ID
                argument2                  =>   '02',                 -- P_SELECT_CRITERIA
                argument3                  =>   NULL,                 -- P_PROJECT_FLAG
                argument4                  =>   NULL,                 -- P_PROJECT_ID
                argument5                  =>   NULL,                 -- P_ASSIGNMENT_ID
                argument6                  =>   1,                    -- P_ORGANIZATION_FLAG
                argument7                  =>   l_organization_id,    -- P_ORGANIZATION_ID
                argument8                  =>   NULL,                 -- P_START_ORGANIZATION_FLAG
                argument9                  =>   NULL);                -- P_START_ORGANIZATION_ID
            IF l_request_id = 0 then
                l_return_status := FND_API.G_RET_STS_ERROR;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write_file('gen_org_fcst: ' || 'Report not successful [PAFPEXRP] l_request_id=0; ERROR');
                END IF;
            ELSE
               pa_debug.g_err_stage := 'Exception Report Request Id is '||TO_CHAR(l_request_id);
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
               END IF;
            END IF;
      ELSE
            CLOSE org_hierarchy;
                       l_stage :=  11900;
                       -- hr_utility.trace(to_char(l_stage));

	       -- R12 MOAC 4447573
	       If P_PA_DEBUG_MODE = 'Y' THEN
        	   PA_DEBUG.Log_Message(p_message => 'Calling FND_REQUEST.set_org_id{'||l_org_id||'}');
     	       End If;
	       FND_REQUEST.set_org_id(l_org_id);
	       -- end of  R12 MOAC 4447573

               l_request_id := FND_REQUEST.submit_request
               (application                =>   'PA',
                program                    =>   'PAFPEXRP',
                description                =>   'PRC: List Organization Forecast Exceptions',
                start_time                 =>   NULL,
                sub_request                =>   false,
                argument1                  =>   l_org_id,                     -- P_ORG_ID
                argument2                  =>   '03',                         -- P_SELECT_CRITERIA
                argument3                  =>   NULL,                         -- P_PROJECT_FLAG
                argument4                  =>   NULL,                         -- P_PROJECT_ID
                argument5                  =>   NULL,                         -- P_ASSIGNMENT_ID
                argument6                  =>   NULL,                         -- P_ORGANIZATION_FLAG
                argument7                  =>   NULL,                         -- P_ORGANIZATION_ID
                argument8                  =>   1,                            -- P_START_ORGANIZATION_FLAG
                argument9                  =>   p_starting_organization_id);  -- P_START_ORGANIZATION_ID
            IF l_request_id = 0 then
                l_return_status := FND_API.G_RET_STS_ERROR;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write_file('gen_org_fcst: ' || 'Report not successful [PAFPEXRP] l_request_id=0; ERROR');
                END IF;
            ELSE
               pa_debug.g_err_stage := 'Exception Report Request Id is '||TO_CHAR(l_request_id);
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
               END IF;
            END IF;
      END IF;
    ELSE
                       l_stage :=  12000;
                       -- hr_utility.trace(to_char(l_stage));

	       -- R12 MOAC 4447573
	       If P_PA_DEBUG_MODE = 'Y' THEN
        	   PA_DEBUG.Log_Message(p_message => 'Calling FND_REQUEST.set_org_id{'||l_org_id||'}');
     	       End If;
	       FND_REQUEST.set_org_id(l_org_id);
	       -- end of  R12 MOAC 4447573

               l_request_id := FND_REQUEST.submit_request
               (application                =>   'PA',
                program                    =>   'PAFPEXRP',
                description                =>   'PRC: List Organization Forecast Exceptions',
                start_time                 =>   NULL,
                sub_request                =>   false,
                argument1                  =>   l_org_id,             -- P_ORG_ID
                argument2                  =>   '02',                 -- P_SELECT_CRITERIA
                argument3                  =>   NULL,                 -- P_PROJECT_FLAG
                argument4                  =>   NULL,                 -- P_PROJECT_ID
                argument5                  =>   NULL,                 -- P_ASSIGNMENT_ID
                argument6                  =>   1,                    -- P_ORGANIZATION_FLAG
                argument7                  =>   l_organization_id,    -- P_ORGANIZATION_ID
                argument8                  =>   NULL,                 -- P_START_ORGANIZATION_FLAG
                argument9                  =>   NULL);                -- P_START_ORGANIZATION_ID

            IF l_request_id = 0 then
                l_return_status := FND_API.G_RET_STS_ERROR;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write_file('gen_org_fcst: ' || 'Report not successful [PAFPEXRP] l_request_id=0; ERROR');
                END IF;
            ELSE
               pa_debug.g_err_stage := 'Exception Report Request Id is '||TO_CHAR(l_request_id);
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
               END IF;
            END IF;


    END IF; -- p_budget_version_id IS NULL

    pa_debug.g_err_stage := TO_CHAR(l_stage)||': End of Generation Process';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
    END IF;
    pa_debug.reset_err_stack;

 EXCEPTION
   WHEN OTHERS THEN
	   FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ORG_FCST_GEN_PKG.gen_org_fcst'
            ,p_procedure_name => PA_DEBUG.G_Err_Stack);

           retcode         := FND_API.G_RET_STS_UNEXP_ERROR;
           errbuff         := TO_CHAR(l_stage)||'['||SQLERRM||']';

                       -- hr_utility.trace(to_char(l_stage)||'-'||SQLERRM);
                       pa_debug.g_err_stage := TO_CHAR(l_stage)||'['||SQLERRM||']';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                       END IF;
                       IF l_budget_version_id > 0 THEN
                          l_budget_version_in_error := budget_version_in_error(l_budget_version_id);
                          pa_debug.g_err_stage := l_stage||': Budget Version has errored - '
                                                         ||'['||l_budget_version_id||']';
                          IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.write_file('gen_org_fcst: ' || pa_debug.g_err_stage);
                          END IF;
                       END IF;
                       pa_debug.reset_err_stack;
                       RAISE;
 END gen_org_fcst;


/*************************************************************************
sgoteti 03/03/2005.This API was previously in PAFPCPFB.pls, Copied it here as this will be used
only in Org Forecasting Context. The code is copied without any change from the version
115.196 of PAFPCPFB.pls
**************************************************************************/
PROCEDURE create_res_task_maps(
          p_source_project_id         IN      NUMBER
         ,p_target_project_id         IN      NUMBER
         ,p_source_plan_version_id    IN      NUMBER
         ,p_adj_percentage            IN      NUMBER
         ,p_copy_mode                 IN      VARCHAR2 /* Bug 2920954 */
         ,p_calling_module            IN      VARCHAR2 /* Bug 2920954 */
         ,p_shift_days                IN      NUMBER  -- 3/28/2004 FP M Dev Phase II Effort
         ,x_return_status             OUT     NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
         ,x_msg_count                 OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                  OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

AS

   l_msg_count       NUMBER := 0;
   l_data            VARCHAR2(2000);
   l_msg_data        VARCHAR2(2000);
   l_error_msg_code  VARCHAR2(2000);
   l_msg_index_out   NUMBER;
   l_return_status   VARCHAR2(2000);
   l_debug_mode      VARCHAR2(30);
   l_adj_percentage  NUMBER;
   l_shift_days      NUMBER;

   l_periods         NUMBER := 0;
   l_start_date      DATE;
   l_err_code        NUMBER;
   l_err_stage       VARCHAR2(2000);
   l_err_stack       VARCHAR2(2000);

   TYPE ra_map_tmp_tbl1_type IS TABLE OF
      pa_fp_ra_map_tmp.source_res_assignment_id%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE ra_map_tmp_tbl2_type IS TABLE OF
      pa_fp_ra_map_tmp.target_res_assignment_id%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE ra_map_tmp_tbl3_type IS TABLE OF
      pa_fp_ra_map_tmp.resource_assignment_id%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE ra_map_tmp_tbl4_type IS TABLE OF
      pa_fp_ra_map_tmp.source_task_id%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE ra_map_tmp_tbl5_type IS TABLE OF
         pa_fp_ra_map_tmp.target_task_id%TYPE
   INDEX BY BINARY_INTEGER;

--Added the following table types for bug 3354518

   TYPE ra_map_tmp_tbl6_type IS TABLE OF
      pa_fp_ra_map_tmp.system_reference1%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE ra_map_tmp_tbl7_type IS TABLE OF
      pa_fp_ra_map_tmp.system_reference2%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE ra_map_tmp_tbl8_type IS TABLE OF
      pa_fp_ra_map_tmp.system_reference3%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE ra_map_tmp_tbl9_type IS TABLE OF
      pa_fp_ra_map_tmp.planning_start_date%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE ra_map_tmp_tbl10_type IS TABLE OF
         pa_fp_ra_map_tmp.planning_end_date%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE ra_map_tmp_tbl11_type IS TABLE OF
      pa_fp_ra_map_tmp.schedule_start_date%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE ra_map_tmp_tbl12_type IS TABLE OF
         pa_fp_ra_map_tmp.schedule_end_date%TYPE
   INDEX BY BINARY_INTEGER;

  -- Declared for bug 3615617
   TYPE ra_map_tmp_tbl13_type IS TABLE OF
         pa_fp_ra_map_tmp.system_reference4%TYPE
   INDEX BY BINARY_INTEGER;

   l_ra_map_tmp_tbl1 ra_map_tmp_tbl1_type;
   l_ra_map_tmp_tbl2 ra_map_tmp_tbl2_type;
   l_ra_map_tmp_tbl3 ra_map_tmp_tbl3_type;
   l_ra_map_tmp_tbl4 ra_map_tmp_tbl4_type;
   l_ra_map_tmp_tbl5 ra_map_tmp_tbl5_type;

--Declared the following pl/sql tbls for bug 3354518
   l_ra_map_tmp_tbl6  ra_map_tmp_tbl6_type;
   l_ra_map_tmp_tbl7  ra_map_tmp_tbl7_type;
   l_ra_map_tmp_tbl8  ra_map_tmp_tbl8_type;
   l_ra_map_tmp_tbl9  ra_map_tmp_tbl9_type;
   l_ra_map_tmp_tbl10 ra_map_tmp_tbl10_type;
   l_ra_map_tmp_tbl11 ra_map_tmp_tbl11_type;
   l_ra_map_tmp_tbl12 ra_map_tmp_tbl12_type;
  -- Declared for bug 3615617
   l_ra_map_tmp_tbl13 ra_map_tmp_tbl13_type;

   l_source_project_id          pa_projects.project_id%TYPE;
   l_target_project_id          pa_projects.project_id%TYPE;
   l_source_plan_level_code     pa_proj_fp_options.all_fin_plan_level_code%TYPE ;
   l_target_struct_version_id   pa_proj_element_versions.element_version_id%TYPE;
   l_source_struct_version_id   pa_proj_element_versions.element_version_id%TYPE;
   l_target_time_phased_code    pa_proj_fp_options.all_time_phased_code%TYPE; -- bug 3841942


   -- cursor same_projects_cur is going to be used when the source and target projects are same

  CURSOR same_projects_cur IS
      SELECT resource_assignment_id
             ,pa_resource_assignments_s.nextval
             ,parent_assignment_id
             ,task_id
             ,task_id
             --Start of Changes for bug 3354518
             ,NULL
             ,NULL
             ,project_assignment_id
             ,planning_start_date
             ,planning_end_date
             ,schedule_start_date
             ,schedule_end_date
             --End of Changes for bug 3354518
             ,resource_list_member_id  -- bug 3615617  TARGET_RLM_ID
      FROM   pa_resource_assignments
      WHERE  budget_version_id = p_source_plan_version_id;


  /* Bug 2920954 - This cursor is used for FINPLAN when copy mode is B.
     In this case, we copy only the ras with amounts. Since this cursor
     is used only for baselie case, we dont have to check adj percentage
     during copying. In pa_resource_assignments, the amount columns
     would be Null if no budget lines "ever" existed. */

 /*  06-Jul-2004 Bug 3729657 Raja FP M Dev changes
     Resource assignments with no amounts also should be copied
  */

  CURSOR baseline_budgt_res_cur IS
      SELECT  pra.resource_assignment_id
             ,pa_resource_assignments_s.NEXTVAL
             ,pra.parent_assignment_id
             ,pra.task_id
             ,pra.task_id
             --Start of Changes for bug 3354518
             ,NULL
             ,NULL
             ,pra.project_assignment_id
             ,pra.planning_start_date
             ,pra.planning_end_date
             ,pra.schedule_start_date
             ,pra.schedule_end_date
             --End of Changes for bug 3354518
             ,resource_list_member_id  -- bug 3615617   TARGET_RLM_ID
      FROM   pa_resource_assignments pra
      WHERE  pra.budget_version_id = p_source_plan_version_id;
      /*** Bug 3729657
      AND    (pra.total_plan_quantity IS NOT NULL
                   OR pra.total_plan_raw_cost IS NOT NULL
                   OR pra.total_plan_burdened_cost IS NOT NULL
                   OR pra.total_plan_revenue  IS NOT NULL);
      ***/
   -- cursor diferent_projects_cur is going to be used when the source and target projects are different
   -- Reference to pa_tasks is changed to pa_struct_task_wbs_v (bug 3354518)

 CURSOR different_projects_task_cur IS
      SELECT pra.resource_assignment_id                    -- SOURCE_RES_ASSIGNMENT_ID
             ,pa_resource_assignments_s.nextval            -- TARGET_RES_ASSIGNMENT_ID
             ,pra.parent_assignment_id                     -- PARENT_ASSIGNMENT_ID
             ,pra.task_id                                  -- SOURCE_TASK_ID
             ,target_tasks.task_id                         -- TARGET_TASK_ID
             ,NULL                                         -- SOURCE ELEMENT_VERSION_ID
             ,NULL                                         -- TARGET ELEMENT_VERSION_ID
             ,-1                                           -- PROJECT_ASSIGNMENT_ID
             ,pra.planning_start_date + l_shift_days       -- PLANNING_START_DATE
             ,pra.planning_end_date   + l_shift_days       -- PLANNING_END_DATE
             /* It is assumed that this api and this cursor would not be called for TA/WP flow!
                So, the schedule dates are stamped as planning start dates itself */
             ,pra.planning_start_date + l_shift_days       -- SCHEDULE_START_DATE
             ,pra.planning_end_date   + l_shift_days       -- SCHEDULE_END_DATE
             ,target_rlm.resource_list_member_id -- bug 3615617 TARGET_RLM_ID
      FROM   pa_resource_assignments pra
            ,pa_tasks    source_tasks
            ,pa_tasks    target_tasks
            ,pa_resource_list_members source_rlm   -- bug 3615617
            ,pa_resource_list_members  target_rlm   -- bug 3615617
      WHERE  pra.budget_version_id = p_source_plan_version_id
      AND    pra.project_id = p_source_project_id  --bug#2708524
      AND    source_tasks.task_id = pra.task_id
      AND    source_tasks.task_number = target_tasks.task_number
      AND    target_tasks.project_id = l_target_project_id
      AND    source_rlm.resource_list_member_id = pra.resource_list_member_id   -- bug 3615617
      AND    target_rlm.resource_list_id  = source_rlm.resource_list_id         -- bug 3615617
      AND    target_rlm.alias  = source_rlm.alias                               -- bug 3615617
      AND    target_rlm.object_type = source_rlm.object_type                    -- bug 3615617
      AND    target_rlm.object_id = Decode(target_rlm.object_type,              -- bug 3615617
                                             'RESOURCE_LIST', target_rlm.resource_list_id,
                                             'PROJECT',       l_target_project_id)
      AND    pra.task_id <> 0; -- bug 3615617 this is redundant but put for clarity


  --bug#2684748
  --This cursor is added to resolve the issue of resource
  --assignments being not populated when planning level
  --is PROJECT and source and target project id is different.

  CURSOR proj_plan_lev_diff_proj_cur IS
       SELECT resource_assignment_id                   -- SOURCE_RES_ASSIGNMENT_ID
             ,pa_resource_assignments_s.nextval        -- TARGET_RES_ASSIGNMENT_ID
             ,NULL                                     -- PARENT_ASSIGNMENT_ID
             ,0                                        -- SOURCE_TASK_ID
             ,0                                        -- TARGET_TASK_ID
           --Start of Changes for bug 3354518
             ,NULL                                     -- SOURCE ELEMENT_VERSION_ID
             ,NULL                                     -- TARGET ELEMENT_VERSION_ID
             ,-1                                       -- PROJECT_ASSIGNMENT_ID
             ,planning_start_date + l_shift_days       -- PLANNING_START_DATE
             ,planning_end_date + l_shift_days         -- PLANNING_END_DATE
             /* It is assumed that this api and this cursor would not be called for TA/WP flow!
                So, the schedule dates are stamped as planning start dates itself */
             ,planning_start_date + l_shift_days       -- SCHEDULE_START_DATE
             ,planning_end_date + l_shift_days         -- SCHEDULE_END_DATE
           --End of Changes for bug 3354518
            ,target_rlm.resource_list_member_id  -- bug 3615617 TARGET_RLM_ID
      FROM   pa_resource_assignments pra
            ,pa_resource_list_members source_rlm   -- bug 3615617
            ,pa_resource_list_members  target_rlm   -- bug 3615617
      WHERE  pra.budget_version_id = p_source_plan_version_id
      AND    pra.task_id = 0
      AND    source_rlm.resource_list_member_id = pra.resource_list_member_id   -- bug 3615617
      AND    target_rlm.resource_list_id  = source_rlm.resource_list_id         -- bug 3615617
      AND    target_rlm.alias  = source_rlm.alias                               -- bug 3615617
      AND    target_rlm.object_type = source_rlm.object_type                    -- bug 3615617
      AND    target_rlm.object_id = Decode(target_rlm.object_type,              -- bug 3615617
                                             'RESOURCE_LIST', target_rlm.resource_list_id,
                                             'PROJECT',       l_target_project_id) ;
BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    pa_debug.set_err_stack('pa_fp_org_fcst_gen_pub.Create_Res_Task_Maps');
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    pa_debug.set_process('PLSQL','LOG',l_debug_mode);

    -- Check for business rules violations

    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.g_err_stage:='Validating input parameters';
       pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    -- Check for null source_plan__version_id

    IF (p_source_plan_version_id IS NULL) THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='Source fin plan version id'||p_source_plan_version_id;
            pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Parameter validation complete';
        pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    -- If adjustment percentage is null make it zero.
    -- Similarly, if shift days is null make it zero

    l_adj_percentage := NVL(p_adj_percentage,0);
    l_shift_days     := NVL(p_shift_days,0);

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Source fin plan version id'||p_source_plan_version_id;
        pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage:='Adj_percentage = '||l_adj_percentage;
        pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Fetch source project id

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Fetching source project id ';
        pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    SELECT  project_id
    INTO   l_source_project_id
    FROM   pa_budget_versions
    WHERE  budget_version_id = p_source_plan_version_id;

    --IF target project id isn't passed, copy source projecct to target project

    l_target_project_id := NVL(p_target_project_id,l_source_project_id);

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Source_project_id = '||l_source_project_id;
        pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage:='Target_project_id = '||l_target_project_id;
        pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;


    -- Remove the old records, if any,from pa_fp_ra_map_tmp

    DELETE FROM pa_fp_ra_map_tmp;

    --Using bulk insert logic here

    IF (l_source_project_id = l_target_project_id) THEN

        /* Included conditional opening of cursor for bug# 2920954 */

        IF p_calling_module = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN AND
           p_copy_mode = PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_BASELINED THEN

            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:='opening baseline_budgt_res_cur';
                pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;

            OPEN baseline_budgt_res_cur;

        ELSE

            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:='opening same_projects_cur';
                pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;

            OPEN same_projects_cur;

        END IF;

        /* Bug 3067254  The fetch statement should be inside the loop to avoid infinite loop*/
        LOOP

            --Doing the bulk fetch

            IF p_calling_module = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN AND
               p_copy_mode = PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_BASELINED THEN

              IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage:='fetching from cursor baseline_budgt_res_cur';
                  pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);
              END IF;

              FETCH baseline_budgt_res_cur BULK COLLECT INTO
                         l_ra_map_tmp_tbl1
                        ,l_ra_map_tmp_tbl2
                        ,l_ra_map_tmp_tbl3
                        ,l_ra_map_tmp_tbl4
                        ,l_ra_map_tmp_tbl5
                        --Added for bug 3354518
                        ,l_ra_map_tmp_tbl6
                        ,l_ra_map_tmp_tbl7
                        ,l_ra_map_tmp_tbl8
                        ,l_ra_map_tmp_tbl9
                        ,l_ra_map_tmp_tbl10
                        ,l_ra_map_tmp_tbl11
                        ,l_ra_map_tmp_tbl12
                        --Added for bug 3615617
                        ,l_ra_map_tmp_tbl13
              LIMIT g_plsql_max_array_size;

            ELSE

              IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage:='fetching from same_projects_cur';
                  pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);
              END IF;

              FETCH same_projects_cur BULK COLLECT INTO
                        l_ra_map_tmp_tbl1
                        ,l_ra_map_tmp_tbl2
                        ,l_ra_map_tmp_tbl3
                        ,l_ra_map_tmp_tbl4
                        ,l_ra_map_tmp_tbl5
                        --Added for bug 3354518
                        ,l_ra_map_tmp_tbl6
                        ,l_ra_map_tmp_tbl7
                        ,l_ra_map_tmp_tbl8
                        ,l_ra_map_tmp_tbl9
                        ,l_ra_map_tmp_tbl10
                        ,l_ra_map_tmp_tbl11
                        ,l_ra_map_tmp_tbl12
                        --Added for bug 3615617
                        ,l_ra_map_tmp_tbl13
              LIMIT g_plsql_max_array_size;

            END IF;

            /* Bug 3067254  LOOP  */

            IF NVL(l_ra_map_tmp_tbl1.last,0) >= 1 THEN

             --Only if something is fetched

                  FORALL i in l_ra_map_tmp_tbl1.first..l_ra_map_tmp_tbl1.last

                  INSERT INTO pa_fp_ra_map_tmp
                            (source_res_assignment_id
                            ,target_res_assignment_id
                            ,resource_assignment_id --parent of source res_assignment_id
                            ,source_task_id
                            ,target_task_id
                            --Added for bug 3354518
                            ,system_reference1
                            ,system_reference2
                            ,system_reference3
                            ,planning_start_date
                            ,planning_end_date
                            ,schedule_start_date
                            ,schedule_end_date
                            ,system_reference4)   -- Bug 3615617
                  VALUES  (  l_ra_map_tmp_tbl1(i)
                            ,l_ra_map_tmp_tbl2(i)
                            ,l_ra_map_tmp_tbl3(i)
                            ,l_ra_map_tmp_tbl4(i)
                            ,l_ra_map_tmp_tbl5(i)
                            --Added for bug 3354518
                            ,l_ra_map_tmp_tbl6(i)
                            ,l_ra_map_tmp_tbl7(i)
                            ,l_ra_map_tmp_tbl8(i)
                            ,l_ra_map_tmp_tbl9(i)
                            ,l_ra_map_tmp_tbl10(i)
                            ,l_ra_map_tmp_tbl11(i)
                            ,l_ra_map_tmp_tbl12(i)
                            ,l_ra_map_tmp_tbl13(i));   -- Bug 3615617

            END IF;

            --exit loop if the recent fetch size is less than 200

            EXIT WHEN NVL(l_ra_map_tmp_tbl1.last,0)<g_plsql_max_array_size;

        END LOOP;


        IF p_calling_module = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN AND
           p_copy_mode = PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_BASELINED THEN

          CLOSE baseline_budgt_res_cur;

          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage:='cursor baseline_budgt_res_cur is closed';
              pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;

        ELSE

          CLOSE same_projects_cur;

          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage:='cursor same_projects_cur is closed';
              pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;

        END IF;

    ELSE  -- if projects are different

        -- bug 3841942 for periodic time phased versions check if the shift days i/p
        -- is large enough to cause a shift in the periodic data

        l_target_time_phased_code :=
              PA_FIN_PLAN_UTILS.get_time_phased_code(p_source_plan_version_id);

        IF l_shift_days  <> 0
        AND l_target_time_phased_code IN (PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G,
                                          PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P)
        THEN
            BEGIN

                 IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.g_err_stage := 'Selecting project start date';
                      pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 SELECT p.start_date
                 INTO   l_start_date
                 FROM   pa_projects p
                 WHERE  p.project_id = l_source_project_id;

                 IF l_start_date IS NULL THEN

                      IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.g_err_stage := 'Selecting task mininum start date';
                           pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);
                      END IF;

                      SELECt min(t.start_date)
                      INTO   l_start_date
                      FROM   pa_tasks t
                      WHERE  t.project_id = l_source_project_id;

                      IF l_start_date is NULL THEN

                           IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.g_err_stage := 'Selecting budget lines minimum start date';
                                pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);
                           END IF;

                           SELECT min(bl.start_date)
                           INTO   l_start_Date
                           FROM   pa_budget_lines bl
                           WHERE  bl.budget_version_id = p_source_plan_version_id;

                      END IF;  /* Mininum Task start date is null */

                 END IF; /* Minimum Project start date is null */
            EXCEPTION
               WHEN OTHERS THEN
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.g_err_stage := 'Error while fetching start date ' || sqlerrm;
                        pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,5);
                   END IF;
                   RAISE;
            END;

            -- If l_start_date is null then that implies there are no budget lines
            IF l_start_date IS NOT NULL THEN
                -- Based on the shift_days check how much shift is required period wise
                pa_budget_core.get_periods(
                              x_start_date1 => l_start_date,
                              x_start_date2 => l_start_date + l_shift_days,
                              x_period_type => l_target_time_phased_code,
                              x_periods     => l_periods,
                              x_err_code    => l_err_code,
                              x_err_stage   => l_err_stage,
                              x_err_stack   => l_err_stack);
                IF l_err_code <> 0 THEN
                     IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.g_err_stage := 'Exception raised by pa_budget_core.get_periods...';
                          pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,5);
                     END IF;

                     PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                          p_msg_name      => l_err_stage);
                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

                -- If l_periods is 0 then budget line data does not require a shift so no
                -- shift is required in the planning start and end dates as well
                IF l_periods = 0 THEN
                    l_shift_days := 0;
                END IF;
            END IF;
        END IF; -- IF l_shift_days  <> 0 AND l_target_time_phased_code IN ('G','P')

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='opening different_projects_task_cur ';
            pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

        OPEN proj_plan_lev_diff_proj_cur ;
        LOOP
            --Doing the bulk fetch
            FETCH proj_plan_lev_diff_proj_cur BULK COLLECT INTO
                   l_ra_map_tmp_tbl1
                  ,l_ra_map_tmp_tbl2
                  ,l_ra_map_tmp_tbl3
                  ,l_ra_map_tmp_tbl4
                  ,l_ra_map_tmp_tbl5
                  --Added for bug 3354518
                  ,l_ra_map_tmp_tbl6
                  ,l_ra_map_tmp_tbl7
                  ,l_ra_map_tmp_tbl8
                  ,l_ra_map_tmp_tbl9
                  ,l_ra_map_tmp_tbl10
                  ,l_ra_map_tmp_tbl11
                  ,l_ra_map_tmp_tbl12
                  --Added for bug 3615617
                  ,l_ra_map_tmp_tbl13
            LIMIT g_plsql_max_array_size;

            IF NVL(l_ra_map_tmp_tbl1.last,0) >= 1 THEN

               /* only if something is fetched */

                FORALL i IN l_ra_map_tmp_tbl1.first..l_ra_map_tmp_tbl1.last

                    INSERT INTO pa_fp_ra_map_tmp
                            (source_res_assignment_id
                             ,target_res_assignment_id
                             ,resource_assignment_id --parent of source res_assignment_id
                             ,source_task_id
                             ,target_task_id
                             --Added for bug 3354518
                             ,system_reference1
                             ,system_reference2
                             ,system_reference3
                             ,planning_start_date
                             ,planning_end_date
                             ,schedule_start_date
                             ,schedule_end_date
                            -- Added for bug 3615617
                             ,system_reference4
                             )
                    VALUES  (l_ra_map_tmp_tbl1(i)
                             ,l_ra_map_tmp_tbl2(i)
                             ,l_ra_map_tmp_tbl3(i)
                             ,l_ra_map_tmp_tbl4(i)
                             ,l_ra_map_tmp_tbl5(i)
                             --Added for bug 3354518
                             ,l_ra_map_tmp_tbl6(i)
                             ,l_ra_map_tmp_tbl7(i)
                             ,l_ra_map_tmp_tbl8(i)
                             ,l_ra_map_tmp_tbl9(i)
                             ,l_ra_map_tmp_tbl10(i)
                             ,l_ra_map_tmp_tbl11(i)
                             ,l_ra_map_tmp_tbl12(i)
                            -- Added for bug 3615617
                             ,l_ra_map_tmp_tbl13(i));
            END IF;

            --Exit loop if the recent fetch size is less than 200

            EXIT WHEN NVL(l_ra_map_tmp_tbl1.last,0) < g_plsql_max_array_size;
        END LOOP;
        CLOSE proj_plan_lev_diff_proj_cur ;

        -- If planning level is not project, task level resource assignments also should be copied
        l_source_plan_level_code := PA_FIN_PLAN_UTILS.Get_Fin_Plan_Level_Code(p_source_plan_version_id);

        IF l_source_plan_level_code <> 'P' THEN
            OPEN different_projects_task_cur;
            LOOP
                --Doing the bulk fetch
                FETCH different_projects_task_cur BULK COLLECT INTO
                     l_ra_map_tmp_tbl1
                    ,l_ra_map_tmp_tbl2
                    ,l_ra_map_tmp_tbl3
                    ,l_ra_map_tmp_tbl4
                    ,l_ra_map_tmp_tbl5
                    --Added for bug 3354518
                    ,l_ra_map_tmp_tbl6
                    ,l_ra_map_tmp_tbl7
                    ,l_ra_map_tmp_tbl8
                    ,l_ra_map_tmp_tbl9
                    ,l_ra_map_tmp_tbl10
                    ,l_ra_map_tmp_tbl11
                    ,l_ra_map_tmp_tbl12
                    --Added for bug 3615617
                    ,l_ra_map_tmp_tbl13
                LIMIT g_plsql_max_array_size;

                IF NVL(l_ra_map_tmp_tbl1.last,0) >= 1 THEN

                    /* only if something is fetched */

                    FORALL i IN l_ra_map_tmp_tbl1.first..l_ra_map_tmp_tbl1.last

                        INSERT INTO pa_fp_ra_map_tmp
                                (source_res_assignment_id
                                 ,target_res_assignment_id
                                 ,resource_assignment_id --parent of source res_assignment_id
                                 ,source_task_id
                                 ,target_task_id
                                 --Added for bug 3354518
                                 ,system_reference1
                                 ,system_reference2
                                 ,system_reference3
                                 ,planning_start_date
                                 ,planning_end_date
                                 ,schedule_start_date
                                 ,schedule_end_date
                                -- Added for bug 3615617
                                 ,system_reference4
                                 )
                        VALUES  (l_ra_map_tmp_tbl1(i)
                                 ,l_ra_map_tmp_tbl2(i)
                                 ,l_ra_map_tmp_tbl3(i)
                                 ,l_ra_map_tmp_tbl4(i)
                                 ,l_ra_map_tmp_tbl5(i)
                                 --Added for bug 3354518
                                 ,l_ra_map_tmp_tbl6(i)
                                 ,l_ra_map_tmp_tbl7(i)
                                 ,l_ra_map_tmp_tbl8(i)
                                 ,l_ra_map_tmp_tbl9(i)
                                 ,l_ra_map_tmp_tbl10(i)
                                 ,l_ra_map_tmp_tbl11(i)
                                 ,l_ra_map_tmp_tbl12(i)
                                -- Added for bug 3615617
                                 ,l_ra_map_tmp_tbl13(i));
                END IF;

                --Exit loop if the recent fetch size is less than 200

                EXIT WHEN NVL(l_ra_map_tmp_tbl1.last,0) < g_plsql_max_array_size;
            END LOOP;
            CLOSE different_projects_task_cur ;
            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:='cursor different_projects_task_cur is closed';
                pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);
            END IF;
        END IF;  -- task level planning
    END IF; -- same/different projects

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Exiting Create_Res_Task_Maps';
        pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    pa_debug.reset_err_stack;

EXCEPTION

 WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE
                  ,p_msg_index      => 1
                  ,p_msg_count      => l_msg_count
                  ,p_msg_data       => l_msg_data
                  ,p_data           => l_data
                  ,p_msg_index_out  => l_msg_index_out);
           x_msg_data := l_data;
           x_msg_count := l_msg_count;
      ELSE
          x_msg_count := l_msg_count;
      END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage:='Invalid Arguments Passed';
          pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,5);
       END IF;
       pa_debug.reset_err_stack;
       RAISE;

 WHEN Others THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'pa_fp_org_fcst_gen_pub'
                              ,p_procedure_name  => 'CREATE_RES_TASK_MAPS');
      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          pa_debug.write('create_res_task_maps: ' || g_module_name,pa_debug.g_err_stage,5);
      END IF;
      pa_debug.reset_err_stack;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CREATE_RES_TASK_MAPS;


/*************************************************************************
sgoteti 03/03/2005.This API was previously in PAFPCPFB.pls, Copied it here as this will be used
only in Org Forecasting Context. (Note: copy_resource_assignments in latest PAFPCPFB.pls will not
go thru pa_fp_ra_map_tmp). The code is copied without any change from the version 115.196 of
PAFPCPFB.pls to reduce the impact. The parameter p_rbs_map_diff_flag can be considered as an
obsolete parameter in org forecasting flow.
**************************************************************************/

  PROCEDURE Copy_Resource_Assignments(
           p_source_plan_version_id    IN     NUMBER
          ,p_target_plan_version_id   IN     NUMBER
          ,p_adj_percentage           IN     NUMBER
          ,p_rbs_map_diff_flag        IN     VARCHAR2 DEFAULT 'N'
          ,p_calling_context          IN     VARCHAR2 DEFAULT NULL -- Bug 4065314
          ,x_return_status            OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                 OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  AS
       l_msg_count          NUMBER :=0;
       l_data               VARCHAR2(2000);
       l_msg_data           VARCHAR2(2000);
       l_error_msg_code     VARCHAR2(2000);
       l_msg_index_out      NUMBER;
       l_return_status      VARCHAR2(2000);
       l_debug_mode         VARCHAR2(30);

       l_adj_percentage     NUMBER ;
       l_target_project_id  pa_projects.project_id%TYPE;
       l_cost_flag      pa_fin_plan_amount_sets.raw_cost_flag%TYPE;
       l_revenue_flag       pa_fin_plan_amount_sets.revenue_flag%TYPE;

       l_tmp                NUMBER;


  BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     pa_debug.set_err_stack('pa_fp_org_fcst_gen_pub.Copy_Resource_Assignments');
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
     pa_debug.set_process('PLSQL','LOG',l_debug_mode);

     /*
      * Check if  source_verion_id, target_version_id are NULL, if so throw
      * an error message
      */

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Checking for valid parameters:';
        pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_source_plan_version_id IS NULL) OR
       (p_target_plan_version_id IS NULL)
    THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'Source_plan='||p_source_plan_version_id;
             pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,5);

             pa_debug.g_err_stage := 'Target_plan'||p_target_plan_version_id;
             pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,5);
         END IF;

         PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Parameter validation complete';
        pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    --If adj_percentage is zero make it null

    l_adj_percentage := NVL(p_adj_percentage,0);

     --Fetching the flags of target version using fin_plan_prefernce_code

     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Fetching the raw_cost,burdened_cost and revenue flags of target_version';
         pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     SELECT DECODE(fin_plan_preference_code
                   ,PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY ,'Y'
                   ,PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME , 'Y','N') --cost_flag
            ,DECODE(fin_plan_preference_code
                     ,PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY ,'Y'
                     ,PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME ,'Y','N')--revenue_flag
            ,project_id
     INTO   l_cost_flag
           ,l_revenue_flag
           ,l_target_project_id
     FROM   pa_proj_fp_options
     WHERE  fin_plan_version_id=p_target_plan_version_id;
/*
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='l_cost_flag ='||l_cost_flag;
        pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
        pa_debug.g_err_stage:='l_revenue_flag ='||l_revenue_flag;
        pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
        pa_debug.g_err_stage:='l_target_project_id ='||l_target_project_id;
        pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;
*/
    --Inserting records into pa_resource_assignments using pa_fp_ra_map_tmp

     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Copying the source version records as target version records';
         pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     -- Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

     --Bug 3974569. Need not have pa_rbs_plans_out_tmp in the FROM clause if the parameter is N
     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='p_rbs_map_diff_flag '||p_rbs_map_diff_flag;
         pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF p_rbs_map_diff_flag ='N' THEN

         INSERT INTO PA_RESOURCE_ASSIGNMENTS(
                  resource_assignment_id
                  ,budget_version_id
                  ,project_id
                  ,task_id
                  ,resource_list_member_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,unit_of_measure
                  ,track_as_labor_flag
                  ,total_plan_revenue
                  ,total_plan_raw_cost
                  ,total_plan_burdened_cost
                  ,total_plan_quantity
                  ,resource_assignment_type
                  ,total_project_raw_cost
                  ,total_project_burdened_cost
                  ,total_project_revenue
                  ,standard_bill_rate
                  ,average_bill_rate
                  ,average_cost_rate
                  ,project_assignment_id
                  ,plan_error_code
                  ,average_discount_percentage
                  ,total_borrowed_revenue
                  ,total_revenue_adj
                  ,total_lent_resource_cost
                  ,total_cost_adj
                  ,total_unassigned_time_cost
                  ,total_utilization_percent
                  ,total_utilization_hours
                  ,total_utilization_adj
                  ,total_capacity
                  ,total_head_count
                  ,total_head_count_adj
                  ,total_tp_revenue_in
                  ,total_tp_revenue_out
                  ,total_tp_cost_in
                  ,total_tp_cost_out
                  ,parent_assignment_id
                  ,wbs_element_version_id
                  ,rbs_element_id
                  ,planning_start_date
                  ,planning_end_date
                  ,schedule_start_date
                  ,schedule_end_date
                  ,spread_curve_id
                  ,etc_method_code
                  ,res_type_code
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
                  ,attribute11
                  ,attribute12
                  ,attribute13
                  ,attribute14
                  ,attribute15
                  ,attribute16
                  ,attribute17
                  ,attribute18
                  ,attribute19
                  ,attribute20
                  ,attribute21
                  ,attribute22
                  ,attribute23
                  ,attribute24
                  ,attribute25
                  ,attribute26
                  ,attribute27
                  ,attribute28
                  ,attribute29
                  ,attribute30
                  ,fc_res_type_code
                  ,resource_class_code
                  ,organization_id
                  ,job_id
                  ,person_id
                  ,expenditure_type
                  ,expenditure_category
                  ,revenue_category_code
                  ,event_type
                  ,supplier_id
                  ,non_labor_resource
                  ,bom_resource_id
                  ,inventory_item_id
                  ,item_category_id
                  ,record_version_number
                  ,transaction_source_code
                  ,mfc_cost_type_id
                  ,procure_resource_flag
                  ,assignment_description
                  ,incurred_by_res_flag
                  ,rate_job_id
                  ,rate_expenditure_type
                  ,ta_display_flag
                  ,sp_fixed_date
                  ,person_type_code
                  ,rate_based_flag
                  ,use_task_schedule_flag
                  ,rate_exp_func_curr_code
                  ,rate_expenditure_org_id
                  ,incur_by_res_class_code
                  ,incur_by_role_id
                  ,project_role_id
                  ,resource_class_flag
                  ,named_role
                  ,txn_accum_header_id
                  ,scheduled_delay --For Bug 3948128
                  )
         SELECT   /*+ ORDERED USE_NL(PFRMT,PRA) INDEX(PRA PA_RESOURCE_ASSIGNMENTS_U1)*/ pfrmt.target_res_assignment_id  --Bug 2814165
                  ,p_target_plan_version_id
                  ,l_target_project_id
                  ,pfrmt.target_task_id
                  ,pfrmt.system_reference4 -- Bug 3615617 resource_list_member_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,fnd_global.login_id
                  ,pra.unit_of_measure
                  ,pra.track_as_labor_flag
                  ,DECODE(l_adj_percentage,0,DECODE(l_revenue_flag,'Y',total_plan_revenue,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_plan_raw_cost,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_plan_burdened_cost,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,total_plan_quantity,NULL)
                  ,pra.resource_assignment_type
                  ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_project_raw_cost,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_project_burdened_cost,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,DECODE(l_revenue_flag,'Y',total_project_revenue,NULL),NULL)
                  ,standard_bill_rate
                  ,average_bill_rate
                  ,average_cost_rate
                  ,pfrmt.system_reference3 -- Project assignment id of the target (Bug 3354518)
                  ,plan_error_code
                  ,average_discount_percentage
                  ,total_borrowed_revenue
                  ,total_revenue_adj
                  ,total_lent_resource_cost
                  ,total_cost_adj
                  ,total_unassigned_time_cost
                  ,total_utilization_percent
                  ,total_utilization_hours
                  ,total_utilization_adj
                  ,total_capacity
                  ,total_head_count
                  ,total_head_count_adj
                  ,total_tp_revenue_in
                  ,total_tp_revenue_out
                  ,total_tp_cost_in
                  ,total_tp_cost_out
                  ,pfrmt.parent_assignment_id
                  ,pfrmt.system_reference2 -- element version id of the target. (Bug 3354518)
                  ,pra.rbs_element_id
                  ,pfrmt.planning_start_date -- Planning start date of the target (Bug 3354518)
                  ,pfrmt.planning_end_date   -- Planning end date of the target  (Bug 3354518)
                  ,pfrmt.schedule_start_date
                  ,pfrmt.schedule_end_date
                  ,pra.spread_curve_id
                  ,pra.etc_method_code
                  ,pra.res_type_code
                  ,pra.attribute_category
                  ,pra.attribute1
                  ,pra.attribute2
                  ,pra.attribute3
                  ,pra.attribute4
                  ,pra.attribute5
                  ,pra.attribute6
                  ,pra.attribute7
                  ,pra.attribute8
                  ,pra.attribute9
                  ,pra.attribute10
                  ,pra.attribute11
                  ,pra.attribute12
                  ,pra.attribute13
                  ,pra.attribute14
                  ,pra.attribute15
                  ,pra.attribute16
                  ,pra.attribute17
                  ,pra.attribute18
                  ,pra.attribute19
                  ,pra.attribute20
                  ,pra.attribute21
                  ,pra.attribute22
                  ,pra.attribute23
                  ,pra.attribute24
                  ,pra.attribute25
                  ,pra.attribute26
                  ,pra.attribute27
                  ,pra.attribute28
                  ,pra.attribute29
                  ,pra.attribute30
                  ,pra.fc_res_type_code
                  ,pra.resource_class_code
                  ,pra.organization_id
                  ,pra.job_id
                  ,pra.person_id
                  ,pra.expenditure_type
                  ,pra.expenditure_category
                  ,pra.revenue_category_code
                  ,pra.event_type
                  ,pra.supplier_id
                  ,pra.non_labor_resource
                  ,pra.bom_resource_id
                  ,pra.inventory_item_id
                  ,pra.item_category_id
                  ,1    -- should be 1 in the target version being created
                  ,decode(p_calling_context, 'CREATE_VERSION', NULL, pra.transaction_source_code)
                  ,pra.mfc_cost_type_id
                  ,pra.procure_resource_flag
                  ,pra.assignment_description
                  ,pra.incurred_by_res_flag
                  ,pra.rate_job_id
                  ,pra.rate_expenditure_type
                  ,pra.ta_display_flag
                  -- Bug 3820625 sp_fixed_date should also move as per planning_start_date
                  -- Least and greatest are used to make sure that sp_fixed_date is with in planning start and end dates
                  ,greatest(least(pra.sp_fixed_date + (pfrmt.planning_start_date - pra.planning_start_date),
                                  pfrmt.planning_end_date),
                            pfrmt.planning_start_date)
                  ,pra.person_type_code
                  ,pra.rate_based_flag
                  ,pra.use_task_schedule_flag
                  ,pra.rate_exp_func_curr_code
                  ,pra.rate_expenditure_org_id
                  ,pra.incur_by_res_class_code
                  ,pra.incur_by_role_id
                  ,pra.project_role_id
                  ,pra.resource_class_flag
                  ,pra.named_role
                  ,pra.txn_accum_header_id
                  ,scheduled_delay --For Bug 3948128
         FROM     PA_FP_RA_MAP_TMP pfrmt          --Bug 2814165
                 ,PA_RESOURCE_ASSIGNMENTS pra
         WHERE    pra.resource_assignment_id = pfrmt.source_res_assignment_id
         AND      pra.budget_version_id      = p_source_plan_version_id ;

     --For Bug 3974569. Take rbs_element_id and txn_accum_header_id from pa_rbs_plans_out_tmp
     ELSIF p_rbs_map_diff_flag ='Y' THEN --IF p_rbs_map_diff_flag ='N' THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN

             SELECT COUNT(*)
             INTO   l_tmp
             FROM   PA_FP_RA_MAP_TMP;

             pa_debug.g_err_stage:='PA_FP_RA_MAP_TMP count '||l_tmp;
             pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);

             SELECT COUNT(*)
             INTO   l_tmp
             FROM   pa_rbs_plans_out_tmp;

             pa_debug.g_err_stage:='pa_rbs_plans_out_tmp count '||l_tmp;
             pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);

         END IF;

         INSERT INTO PA_RESOURCE_ASSIGNMENTS(
                  resource_assignment_id
                  ,budget_version_id
                  ,project_id
                  ,task_id
                  ,resource_list_member_id
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  ,unit_of_measure
                  ,track_as_labor_flag
                  ,total_plan_revenue
                  ,total_plan_raw_cost
                  ,total_plan_burdened_cost
                  ,total_plan_quantity
                  ,resource_assignment_type
                  ,total_project_raw_cost
                  ,total_project_burdened_cost
                  ,total_project_revenue
                  ,standard_bill_rate
                  ,average_bill_rate
                  ,average_cost_rate
                  ,project_assignment_id
                  ,plan_error_code
                  ,average_discount_percentage
                  ,total_borrowed_revenue
                  ,total_revenue_adj
                  ,total_lent_resource_cost
                  ,total_cost_adj
                  ,total_unassigned_time_cost
                  ,total_utilization_percent
                  ,total_utilization_hours
                  ,total_utilization_adj
                  ,total_capacity
                  ,total_head_count
                  ,total_head_count_adj
                  ,total_tp_revenue_in
                  ,total_tp_revenue_out
                  ,total_tp_cost_in
                  ,total_tp_cost_out
                  ,parent_assignment_id
                  ,wbs_element_version_id
                  ,rbs_element_id
                  ,planning_start_date
                  ,planning_end_date
                  ,schedule_start_date
                  ,schedule_end_date
                  ,spread_curve_id
                  ,etc_method_code
                  ,res_type_code
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
                  ,attribute11
                  ,attribute12
                  ,attribute13
                  ,attribute14
                  ,attribute15
                  ,attribute16
                  ,attribute17
                  ,attribute18
                  ,attribute19
                  ,attribute20
                  ,attribute21
                  ,attribute22
                  ,attribute23
                  ,attribute24
                  ,attribute25
                  ,attribute26
                  ,attribute27
                  ,attribute28
                  ,attribute29
                  ,attribute30
                  ,fc_res_type_code
                  ,resource_class_code
                  ,organization_id
                  ,job_id
                  ,person_id
                  ,expenditure_type
                  ,expenditure_category
                  ,revenue_category_code
                  ,event_type
                  ,supplier_id
                  ,non_labor_resource
                  ,bom_resource_id
                  ,inventory_item_id
                  ,item_category_id
                  ,record_version_number
                  ,transaction_source_code
                  ,mfc_cost_type_id
                  ,procure_resource_flag
                  ,assignment_description
                  ,incurred_by_res_flag
                  ,rate_job_id
                  ,rate_expenditure_type
                  ,ta_display_flag
                  ,sp_fixed_date
                  ,person_type_code
                  ,rate_based_flag
                  ,use_task_schedule_flag
                  ,rate_exp_func_curr_code
                  ,rate_expenditure_org_id
                  ,incur_by_res_class_code
                  ,incur_by_role_id
                  ,project_role_id
                  ,resource_class_flag
                  ,named_role
                  ,txn_accum_header_id
                  ,scheduled_delay --For Bug 3948128
                  )
         SELECT   /*+ ORDERED USE_NL(PFRMT,PRA,RMAP) INDEX(PRA PA_RESOURCE_ASSIGNMENTS_U1)*/ pfrmt.target_res_assignment_id  --Bug 2814165
                  ,p_target_plan_version_id
                  ,l_target_project_id
                  ,pfrmt.target_task_id
                  ,pfrmt.system_reference4 -- Bug 3615617 resource_list_member_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,fnd_global.login_id
                  ,pra.unit_of_measure
                  ,pra.track_as_labor_flag
                  ,DECODE(l_adj_percentage,0,DECODE(l_revenue_flag,'Y',total_plan_revenue,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_plan_raw_cost,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_plan_burdened_cost,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,total_plan_quantity,NULL)
                  ,pra.resource_assignment_type
                  ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_project_raw_cost,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,DECODE(l_cost_flag,'Y',total_project_burdened_cost,NULL),NULL)
                  ,DECODE(l_adj_percentage,0,DECODE(l_revenue_flag,'Y',total_project_revenue,NULL),NULL)
                  ,standard_bill_rate
                  ,average_bill_rate
                  ,average_cost_rate
                  ,pfrmt.system_reference3 -- Project assignment id of the target (Bug 3354518)
                  ,plan_error_code
                  ,average_discount_percentage
                  ,total_borrowed_revenue
                  ,total_revenue_adj
                  ,total_lent_resource_cost
                  ,total_cost_adj
                  ,total_unassigned_time_cost
                  ,total_utilization_percent
                  ,total_utilization_hours
                  ,total_utilization_adj
                  ,total_capacity
                  ,total_head_count
                  ,total_head_count_adj
                  ,total_tp_revenue_in
                  ,total_tp_revenue_out
                  ,total_tp_cost_in
                  ,total_tp_cost_out
                  ,pfrmt.parent_assignment_id
                  ,pfrmt.system_reference2 -- element version id of the target. (Bug 3354518)
                  ,rmap.rbs_element_id
                  ,pfrmt.planning_start_date -- Planning start date of the target (Bug 3354518)
                  ,pfrmt.planning_end_date   -- Planning end date of the target  (Bug 3354518)
                  ,pfrmt.schedule_start_date
                  ,pfrmt.schedule_end_date
                  ,pra.spread_curve_id
                  ,pra.etc_method_code
                  ,pra.res_type_code
                  ,pra.attribute_category
                  ,pra.attribute1
                  ,pra.attribute2
                  ,pra.attribute3
                  ,pra.attribute4
                  ,pra.attribute5
                  ,pra.attribute6
                  ,pra.attribute7
                  ,pra.attribute8
                  ,pra.attribute9
                  ,pra.attribute10
                  ,pra.attribute11
                  ,pra.attribute12
                  ,pra.attribute13
                  ,pra.attribute14
                  ,pra.attribute15
                  ,pra.attribute16
                  ,pra.attribute17
                  ,pra.attribute18
                  ,pra.attribute19
                  ,pra.attribute20
                  ,pra.attribute21
                  ,pra.attribute22
                  ,pra.attribute23
                  ,pra.attribute24
                  ,pra.attribute25
                  ,pra.attribute26
                  ,pra.attribute27
                  ,pra.attribute28
                  ,pra.attribute29
                  ,pra.attribute30
                  ,pra.fc_res_type_code
                  ,pra.resource_class_code
                  ,pra.organization_id
                  ,pra.job_id
                  ,pra.person_id
                  ,pra.expenditure_type
                  ,pra.expenditure_category
                  ,pra.revenue_category_code
                  ,pra.event_type
                  ,pra.supplier_id
                  ,pra.non_labor_resource
                  ,pra.bom_resource_id
                  ,pra.inventory_item_id
                  ,pra.item_category_id
                  ,1    -- should be 1 in the target version being created
                  ,decode(p_calling_context, 'CREATE_VERSION', NULL, pra.transaction_source_code)
                  ,pra.mfc_cost_type_id
                  ,pra.procure_resource_flag
                  ,pra.assignment_description
                  ,pra.incurred_by_res_flag
                  ,pra.rate_job_id
                  ,pra.rate_expenditure_type
                  ,pra.ta_display_flag
                  -- Bug 3820625 sp_fixed_date should also move as per planning_start_date
                  -- Least and greatest are used to make sure that sp_fixed_date is with in planning start and end dates
                  ,greatest(least(pra.sp_fixed_date + (pfrmt.planning_start_date - pra.planning_start_date),
                                  pfrmt.planning_end_date),
                            pfrmt.planning_start_date)
                  ,pra.person_type_code
                  ,pra.rate_based_flag
                  ,pra.use_task_schedule_flag
                  ,pra.rate_exp_func_curr_code
                  ,pra.rate_expenditure_org_id
                  ,pra.incur_by_res_class_code
                  ,pra.incur_by_role_id
                  ,pra.project_role_id
                  ,pra.resource_class_flag
                  ,pra.named_role
                  ,rmap.txn_accum_header_id
                  ,scheduled_delay --For Bug 3948128
         FROM     PA_FP_RA_MAP_TMP pfrmt          --Bug 2814165
                 ,PA_RESOURCE_ASSIGNMENTS pra
                 ,pa_rbs_plans_out_tmp rmap
         WHERE    pra.resource_assignment_id = pfrmt.source_res_assignment_id
         AND      pra.budget_version_id      = p_source_plan_version_id
         AND      rmap.source_id = pra.resource_assignment_id;


     END IF;--IF p_rbs_map_diff_flag ='N' THEN

     l_tmp := SQL%ROWCOUNT;
     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='No. of records inserted into PRA '||l_tmp;
         pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     -- Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------
     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Exiting Copy_Resource_Assignments';
         pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;
     pa_debug.reset_err_stack;  -- bug:- 2815593
 EXCEPTION

    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count = 1 THEN
              PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded         => FND_API.G_TRUE
                    ,p_msg_index      => 1
                    ,p_msg_count      => l_msg_count
                    ,p_msg_data       => l_msg_data
                    ,p_data           => l_data
                    ,p_msg_index_out  => l_msg_index_out);
               x_msg_data := l_data;
               x_msg_count := l_msg_count;
          ELSE
               x_msg_count := l_msg_count;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;

          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage:='Invalid Arguments Passed';
              pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,5);
          END IF;
          pa_debug.reset_err_stack;
          RAISE;

   WHEN Others THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count     := 1;
         x_msg_data      := SQLERRM;
         FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'pa_fp_org_fcst_gen_pub'
                          ,p_procedure_name  => 'COPY_RESOURCE_ASSIGNMENTS');

         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write('Copy_Resource_Assignments: ' || g_module_name,pa_debug.g_err_stage,5);
         END IF;
         pa_debug.reset_err_stack;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END Copy_Resource_Assignments;

/*===================================================================
sgoteti 03/03/2005.This API was previously in PAFPCPFB.pls, Copied it here as this will be used
only in Org Forecasting Context. (Note: Copy_Budget_Lines in latest PAFPCPFB.pls will not
go thru pa_fp_ra_map_tmp). The code is copied without any change from the version 115.196 of P
PAFPCPFB.pls to reduce the impact.
===================================================================*/

  PROCEDURE Copy_Budget_Lines(
             p_source_plan_version_id     IN  NUMBER
             ,p_target_plan_version_id   IN  NUMBER
             ,p_adj_percentage           IN  NUMBER
             ,x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_msg_count                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
             ,x_msg_data                 OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
   AS

         l_msg_count          NUMBER :=0;
         l_data               VARCHAR2(2000);
         l_msg_data           VARCHAR2(2000);
         l_error_msg_code     VARCHAR2(2000);
         l_msg_index_out      NUMBER;
         l_return_status      VARCHAR2(2000);
         l_debug_mode         VARCHAR2(30);

         l_source_period_profile_id  pa_budget_versions.period_profile_id%TYPE;
         l_target_period_profile_id  pa_budget_versions.period_profile_id%TYPE;

         l_revenue_flag       pa_fin_plan_amount_sets.revenue_flag%type;
         l_cost_flag          pa_fin_plan_amount_sets.raw_cost_flag%type;

         l_adj_percentage            NUMBER ;
         l_period_profiles_same_flag VARCHAR2(1);

         -- Bug 3927244
         l_copy_actuals_flag    VARCHAR2(1) := 'Y';
         l_src_plan_class_code      pa_fin_plan_types_b.plan_class_code%TYPE;
         l_trg_plan_class_code      pa_fin_plan_types_b.plan_class_code%TYPE;
         l_wp_version_flag      pa_budget_versions.wp_version_flag%TYPE;

         l_etc_start_date       pa_budget_versions.etc_start_date%TYPE;

         CURSOR get_plan_class_code_csr(c_budget_version_id pa_budget_versions.budget_version_id%TYPE) IS
         SELECT pfb.plan_class_code,nvl(pbv.wp_version_flag,'N'),etc_start_date
         FROM   pa_fin_plan_types_b pfb,
                pa_budget_versions  pbv
         WHERE  pbv.budget_version_id = c_budget_version_id
         AND    pbv.fin_plan_type_id  = pfb.fin_plan_type_id;
         -- Bug 3927244

   BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      pa_debug.set_err_stack('pa_fp_org_fcst_gen_pub.Copy_Budget_Lines');
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);

      -- Checking for all valid input parametrs

      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage := 'Checking for valid parameters:';
          pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      IF (p_source_plan_version_id IS NULL) OR
         (p_target_plan_version_id IS NULL)
      THEN

           IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage := 'Source_plan='||p_source_plan_version_id;
               pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
               pa_debug.g_err_stage := 'Target_plan'||p_target_plan_version_id;
               pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
           END IF;

           PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage := 'Parameter validation complete';
          pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;
/*
      pa_debug.g_err_stage:='Source fin plan version id'||p_source_plan_version_id;
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;
      pa_debug.g_err_stage:='Target fin plan version id'||p_target_plan_version_id;
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;
*/
      --make adj percentage zero if passed as null

      l_adj_percentage := NVL(p_adj_percentage,0);
/*
       pa_debug.g_err_stage:='Adj_percentage'||l_adj_percentage;
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;
*/
       -- Fetching the flags of target version using fin_plan_prefernce_code


       IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Fetching the raw_cost,burdened_cost and revenue flags of target_version';
           pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;

       SELECT DECODE(fin_plan_preference_code          -- l_revenue_flag
                       ,PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY ,'Y'
                       ,PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME ,'Y','N')
              ,DECODE(fin_plan_preference_code          -- l_cost_flag
                      ,PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY ,'Y'
                      ,PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME , 'Y','N')
       INTO   l_revenue_flag
              ,l_cost_flag
       FROM   pa_proj_fp_options
       WHERE  fin_plan_version_id=p_target_plan_version_id;
/*
       pa_debug.g_err_stage:='l_revenue_flag ='||l_revenue_flag;
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;
       pa_debug.g_err_stage:='l_cost_flag ='||l_cost_flag;
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;
*/
       -- Checking if source and target version period profiles match

       /* FPB2: REVIEW */

       /** MRC Elimination changes: PA_MRC_FINPLAN.populate_bl_map_tmp */
       PA_FIN_PLAN_UTILS2.populate_bl_map_tmp
				(p_source_fin_plan_version_id  => p_source_plan_version_id,
                                 x_return_status      => x_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data);

       IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Inserting  budget_lines';
           pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;

       -- Bug 3927244: Actuals need to be copied from forecast to forecast within the same project for FINPLAN versions

       OPEN  get_plan_class_code_csr(p_source_plan_version_id);
       FETCH get_plan_class_code_csr
       INTO  l_src_plan_class_code,l_wp_version_flag,l_etc_start_date;
       CLOSE get_plan_class_code_csr;

       OPEN  get_plan_class_code_csr(p_target_plan_version_id);
       FETCH get_plan_class_code_csr
       INTO  l_trg_plan_class_code,l_wp_version_flag,l_etc_start_date;
       CLOSE get_plan_class_code_csr;

       IF l_wp_version_flag='Y' OR l_src_plan_class_code <> PA_FP_CONSTANTS_PKG.G_PLAN_CLASS_FORECAST OR
          l_trg_plan_class_code <> PA_FP_CONSTANTS_PKG.G_PLAN_CLASS_FORECAST THEN
            l_copy_actuals_flag := 'N';
       END IF;

          -- End: Bug 3927244

       -- Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------
       --Bug 4052403. For non rate-based transactions quantity should be same as raw cost if the version type is COST/ALL or
       --it should be revenue if the version type is REVENUE. This business rule will be taken care by the API
       --PA_FP_MULTI_CURRENCY_PKG.Round_Budget_Line_Amounts which is called after this INSERT. Note that this has to be done only
       --when adjustment% is not null since the amounts in the source will be altered only when the user enters some adj %
       --Bug 4188225. PC/PFC buckets will be copied unconditionally (Removed the condition that checks for l_adj_percentage
       --being greater than 0 in order to copy)
       INSERT INTO PA_BUDGET_LINES(
                budget_line_id             /* FPB2 */
               ,budget_version_id          /* FPB2 */
               ,resource_assignment_id
               ,start_date
               ,last_update_date
               ,last_updated_by
               ,creation_date
               ,created_by
               ,last_update_login
               ,end_date
               ,period_name
               ,quantity
               ,raw_cost
               ,burdened_cost
               ,revenue
               ,change_reason_code
               ,description
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
               ,attribute11
               ,attribute12
               ,attribute13
               ,attribute14
               ,attribute15
               ,raw_cost_source
               ,burdened_cost_source
               ,quantity_source
               ,revenue_source
               ,pm_product_code
               ,pm_budget_line_reference
               ,cost_rejection_code
               ,revenue_rejection_code
               ,burden_rejection_code
               ,other_rejection_code
               ,code_combination_id
               ,ccid_gen_status_code
               ,ccid_gen_rej_message
               ,request_id
               ,borrowed_revenue
               ,tp_revenue_in
               ,tp_revenue_out
               ,revenue_adj
               ,lent_resource_cost
               ,tp_cost_in
               ,tp_cost_out
               ,cost_adj
               ,unassigned_time_cost
               ,utilization_percent
               ,utilization_hours
               ,utilization_adj
               ,capacity
               ,head_count
               ,head_count_adj
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
               ,txn_raw_cost
               ,txn_burdened_cost
               ,txn_currency_code
               ,txn_revenue
               ,bucketing_period_code
               ,transfer_price_rate
               ,init_quantity
               ,init_quantity_source
               ,init_raw_cost
               ,init_burdened_cost
               ,init_revenue
               ,init_raw_cost_source
               ,init_burdened_cost_source
               ,init_revenue_source
               ,project_init_raw_cost
               ,project_init_burdened_cost
               ,project_init_revenue
               ,txn_init_raw_cost
               ,txn_init_burdened_cost
               ,txn_init_revenue
               ,txn_markup_percent
               ,txn_markup_percent_override
               ,txn_discount_percentage
               ,txn_standard_bill_rate
               ,txn_standard_cost_rate
               ,txn_cost_rate_override
               ,burden_cost_rate
               ,txn_bill_rate_override
               ,burden_cost_rate_override
               ,cost_ind_compiled_set_id
               ,pc_cur_conv_rejection_code
               ,pfc_cur_conv_rejection_code
)
     SELECT     bmt.target_budget_line_id      /* FPB2 */
               ,p_target_plan_version_id     /* FPB2 */
               ,pfrmt.target_res_assignment_id
               ,pbl.start_date
               ,sysdate
               ,fnd_global.user_id
               ,sysdate
               ,fnd_global.user_id
               ,fnd_global.login_id
               ,pbl.end_date
               ,pbl.period_name
               ,pbl.quantity
               ,DECODE(l_cost_flag,'Y', raw_cost,NULL)
               ,DECODE(l_cost_flag,'Y', burdened_cost,NULL)
               ,DECODE(l_revenue_flag,'Y', revenue,NULL)
               ,pbl.change_reason_code
               ,description
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
               ,attribute11
               ,attribute12
               ,attribute13
               ,attribute14
               ,attribute15
               ,DECODE(l_cost_flag,'Y',PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_COPY_P,NULL) --raw_cost_souce
               ,DECODE(l_cost_flag,'Y',PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_COPY_P,NULL) --burdened_cost_source
               ,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_COPY_P  --quantity_source
               ,DECODE(l_revenue_flag,'Y',PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_COPY_P,NULL) --revenue source
               ,pm_product_code
               ,pm_budget_line_reference
               ,DECODE(l_cost_flag, 'Y',cost_rejection_code, NULL)
               ,DECODE(l_revenue_flag, 'Y',revenue_rejection_code, NULL)
               ,DECODE(l_cost_flag,'Y',burden_rejection_code, NULL)
               ,other_rejection_code
               ,code_combination_id
               ,ccid_gen_status_code
               ,ccid_gen_rej_message
               ,fnd_global.conc_request_id
               ,borrowed_revenue
               ,tp_revenue_in
               ,tp_revenue_out
               ,revenue_adj
               ,lent_resource_cost
               ,tp_cost_in
               ,tp_cost_out
               ,cost_adj
               ,unassigned_time_cost
               ,utilization_percent
               ,utilization_hours
               ,utilization_adj
               ,capacity
               ,head_count
               ,head_count_adj
               ,projfunc_currency_code
               ,DECODE(l_cost_flag,'Y',projfunc_cost_rate_type,NULL)
               ,DECODE(l_cost_flag,'Y',projfunc_cost_exchange_rate,NULL)
               ,DECODE(l_cost_flag,'Y',projfunc_cost_rate_date_type,NULL)
               ,DECODE(l_cost_flag,'Y',projfunc_cost_rate_date,NULL)
               ,DECODE(l_revenue_flag,'Y',projfunc_rev_rate_type,NULL)
               ,DECODE(l_revenue_flag,'Y',projfunc_rev_exchange_rate,NULL)
               ,DECODE(l_revenue_flag,'Y',projfunc_rev_rate_date_type,NULL)
               ,DECODE(l_revenue_flag,'Y',projfunc_rev_rate_date,NULL)
               ,project_currency_code
               ,DECODE(l_cost_flag,'Y',project_cost_rate_type,NULL)
               ,DECODE(l_cost_flag,'Y',project_cost_exchange_rate,NULL)
               ,DECODE(l_cost_flag,'Y',project_cost_rate_date_type,NULL)
               ,DECODE(l_cost_flag,'Y',project_cost_rate_date,NULL)
               ,DECODE(l_cost_flag,'Y', project_raw_cost,NULL)
               ,DECODE(l_cost_flag,'Y', project_burdened_cost,NULL)
               ,DECODE(l_revenue_flag,'Y',project_rev_rate_type,NULL)
               ,DECODE(l_revenue_flag,'Y',project_rev_exchange_rate,NULL)
               ,DECODE(l_revenue_flag,'Y',project_rev_rate_date_type,NULL)
               ,DECODE(l_revenue_flag,'Y',project_rev_rate_date,NULL)
               ,DECODE(l_revenue_flag,'Y', project_revenue,NULL)
               ,DECODE(l_cost_flag,'Y',
                       decode(GREATEST(pbl.start_date,NVL(l_etc_start_date,pbl.start_date)),pbl.start_date,txn_raw_cost*(1+l_adj_percentage),txn_raw_cost),NULL)
               ,DECODE(l_cost_flag,'Y',
                       decode(GREATEST(pbl.start_date,NVL(l_etc_start_date,pbl.start_date)),pbl.start_date,txn_burdened_cost*(1+l_adj_percentage),txn_burdened_cost),NULL)
               ,txn_currency_code
               ,DECODE(l_revenue_flag,'Y',
                        decode(GREATEST(pbl.start_date,NVL(l_etc_start_date,pbl.start_date)),pbl.start_date,txn_revenue*(1+l_adj_percentage),txn_revenue),NULL)
               ,DECODE(l_period_profiles_same_flag,'Y',bucketing_period_code,NULL)
               ,transfer_price_rate
               ,decode(l_copy_actuals_flag,'N',NULL,pbl.init_quantity)              --init_quantity
               ,decode(l_copy_actuals_flag,'N',NULL,pbl.init_quantity_source)       --init_quantity_source
               ,DECODE(l_cost_flag,'Y',decode(l_copy_actuals_flag,'N',NULL,pbl.init_raw_cost),NULL)                   --init_raw_cost
               ,DECODE(l_cost_flag,'Y',decode(l_copy_actuals_flag,'N',NULL,pbl.init_burdened_cost),NULL)         --init_burdened_cost
               ,DECODE(l_revenue_flag,'Y',decode(l_copy_actuals_flag,'N',NULL,pbl.init_revenue),NULL)                     --init_revenue
               ,DECODE(l_cost_flag,'Y',decode(l_copy_actuals_flag,'N',NULL,pbl.init_raw_cost_source),NULL)            --init_raw_cost_source
               ,DECODE(l_cost_flag,'Y',decode(l_copy_actuals_flag,'N',NULL,pbl.init_burdened_cost_source),NULL)  --init_burdened_cost_source
               ,DECODE(l_revenue_flag,'Y',decode(l_copy_actuals_flag,'N',NULL,pbl.init_revenue_source),NULL)              --init_revenue_source
               ,DECODE(l_cost_flag,'Y',decode(l_copy_actuals_flag,'N',NULL,pbl.project_init_raw_cost),NULL)           --project_init_raw_cost
               ,DECODE(l_cost_flag,'Y',decode(l_copy_actuals_flag,'N',NULL,pbl.project_init_burdened_cost),NULL) --project_init_burdened_cost
               ,DECODE(l_revenue_flag,'Y',decode(l_copy_actuals_flag,'N',NULL,pbl.project_init_revenue),NULL)             --project_init_revenue
               ,DECODE(l_cost_flag,'Y',decode(l_copy_actuals_flag,'N',NULL,pbl.txn_init_raw_cost),NULL)               --txn_init_raw_cost
               ,DECODE(l_cost_flag,'Y',decode(l_copy_actuals_flag,'N',NULL,pbl.txn_init_burdened_cost),NULL)     --txn_init_burdened_cost
               ,DECODE(l_revenue_flag,'Y',decode(l_copy_actuals_flag,'N',NULL,pbl.txn_init_revenue),NULL)                 --txn_init_revenue
               ,txn_markup_percent
               ,txn_markup_percent_override
               ,txn_discount_percentage
               ,Decode(l_revenue_flag,'Y',txn_standard_bill_rate,null) --txn_standard_bill_rate
               ,Decode(l_cost_flag,'Y',txn_standard_cost_rate,null) --txn_standard_cost_rate
               ,Decode(l_cost_flag,'Y',txn_cost_rate_override,null) --txn_cost_rate_override
               ,Decode(l_cost_flag,'Y',burden_cost_rate,null)       --burden_cost_rate
               ,Decode(l_revenue_flag,'Y',txn_bill_rate_override,null) --txn_bill_rate_override
               ,Decode(l_cost_flag,'Y',burden_cost_rate_override,null) --burden_cost_rate_override
               ,cost_ind_compiled_set_id
               ,Decode(l_adj_percentage,0,pc_cur_conv_rejection_code,null)
               ,Decode(l_adj_percentage,0,pfc_cur_conv_rejection_code,null)
       FROM PA_BUDGET_LINES  pbl
            ,PA_FP_RA_MAP_TMP pfrmt
            ,pa_fp_bl_map_tmp bmt       /* FPB2 */
       WHERE pbl.resource_assignment_id = pfrmt.source_res_assignment_id
         AND bmt.source_budget_line_id = pbl.budget_line_id    /* FPB2 */
         AND pbl.budget_version_id = p_source_plan_version_id;

       -- End, Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

       -- Bug 4035856 Call rounding api if l_adj_percentage is not zero
       IF l_adj_percentage <> 0 THEN
            PA_FP_MULTI_CURRENCY_PKG.Round_Budget_Line_Amounts
                   (  p_budget_version_id     => p_target_plan_version_id
                     ,p_calling_context       => 'COPY_VERSION'
                     ,x_return_status         => l_return_status
                     ,x_msg_count             => l_msg_count
                     ,x_msg_data              => l_msg_data);

             IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                 IF P_PA_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Error in PA_FP_MULTI_CURRENCY_PKG.Round_Budget_Line_Amounts';
                      pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
                 END IF;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END IF;
       END IF;

       IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Exiting Copy_Budget_Lines';
           pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;
       pa_debug.reset_err_stack;    -- bug:- 2815593
  EXCEPTION

      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
             l_msg_count := FND_MSG_PUB.count_msg;
             IF l_msg_count = 1 THEN
               PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded        => FND_API.G_TRUE
                    ,p_msg_index      => 1
                    ,p_msg_count      => l_msg_count
                    ,p_msg_data       => l_msg_data
                    ,p_data           => l_data
                    ,p_msg_index_out  => l_msg_index_out);
               x_msg_data := l_data;
               x_msg_count := l_msg_count;
           ELSE
               x_msg_count := l_msg_count;
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;

           IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='Invalid arguments passed';
               pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,5);
           END IF;
           pa_debug.reset_err_stack;
           RAISE;

    WHEN Others THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'pa_fp_org_fcst_gen_pub'
                            ,p_procedure_name  => 'COPY_BUDGET_LINES');

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='Unexpected error'||SQLERRM;
            pa_debug.write('Copy_Budget_Lines: ' || g_module_name,pa_debug.g_err_stage,6);
        END IF;
        pa_debug.reset_err_stack;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END Copy_Budget_Lines;


END pa_fp_org_fcst_gen_pub;

/
