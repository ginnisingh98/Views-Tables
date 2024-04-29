--------------------------------------------------------
--  DDL for Package Body PA_DATE_RANGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DATE_RANGE_PKG" AS
/* $Header: PADTRNGB.pls 120.2 2006/01/19 03:27:23 nkumbi noship $ */

procedure DATE_RANGE_UPGRD(
  P_BUDGET_VERSIONS         IN SYSTEM.PA_NUM_TBL_TYPE,
  X_RETURN_STATUS             OUT  NOCOPY VARCHAR2,
  X_MSG_COUNT                 OUT  NOCOPY NUMBER,
  X_MSG_DATA                  OUT  NOCOPY VARCHAR2) IS

     --Bug 4185180.Given a budget version id as parameter the cursor should bring the PLAN_VERSION, PLAN_TYPE level records for that
     -- project and budget version.
     cursor get_elig_bud_ver_csr(c_project_id pa_budget_versions.project_id%TYPE,
                                 c_budget_ver_id pa_budget_versions.budget_version_id%type) is
     select fp.fin_plan_version_id budget_version_id
     , fp.project_id
     , fp.proj_fp_options_id
     , nvl(pa.org_id,-99) org_id
     , fp.fin_plan_type_id               /* bug 3804286: added fin_plan_type_id */
     , fp.fin_plan_preference_code       /* bug 3804286: added fin_plan_preference_code  */
     , pa.start_date                     /* bug 3804286: added start_date */
     , fp.fin_plan_option_level_code
     --Bug 4046524
     , pa.project_currency_code
     , pa.projfunc_currency_code
     from pa_proj_fp_options fp, pa_projects_all pa,
            pa_budget_versions pbv
     where fp.project_id = pa.project_id
      and  fp.project_id = c_project_id
      and   pbv.budget_version_id=c_budget_ver_id
      and  (fp.fin_plan_version_id = c_budget_ver_id OR
               (fin_plan_option_level_code <> 'PLAN_VERSION' AND nvl(fp.fin_plan_type_id,-99)=nvl(pbv.fin_plan_type_id,-99)) )
     and decode(fp.fin_plan_preference_code,
                   'COST_ONLY',cost_time_phased_code,
                   'REVENUE_ONLY',revenue_time_phased_code,
                   'COST_AND_REV_SAME',all_time_phased_code,
                   'COST_AND_REV_SEP',decode(cost_time_phased_code,
                                                'R',cost_time_phased_code,
                                                revenue_time_phased_code)) = 'R';

    cursor chk_plan_ver_csr(c_budget_ver_id pa_budget_versions.budget_version_id%type) is
     select project_id,'Y' from pa_proj_fp_options fp
     where fin_plan_version_id = c_budget_ver_id   and
     fin_plan_option_level_code like 'PLAN_VERSION';

    --Bug 4919018. SQL Repository Performance Activity
    cursor ftch_period_details_csr(c_org_id pa_projects_all.org_id%type) is
     select pi.pa_period_type,sob.accounted_period_type, sob.period_set_name from
     pa_implementations_all pi,
     gl_sets_of_books sob
     where nvl(pi.org_id,-99) = c_org_id
     and sob.set_of_books_id = pi.set_of_books_id;

     --Bug 4176129. Removed the UNION clause as at any point only one of the 2 SQLs would get executed
     cursor chk_ra_exists_csr(c_budget_version_id    pa_budget_versions.budget_version_id%type,
                              c_period_type          gl_date_period_map.period_type%type,
			      c_period_set_name      gl_sets_of_books.period_set_name%type) is
     select 'Y' from dual
     where exists (select 'Y' from pa_resource_assignments ra
     where budget_version_id = c_budget_version_id
     and ra.planning_start_date is NOT NULL   /* bug 3673111 */
     and ra.planning_end_date is NOT NULL     /* bug 3673111 */
     and not exists
     ((
      select 'Y' from
     gl_date_period_map g
     where trunc(g.accounting_date) between ra.planning_start_date and ra.planning_end_date
     and g.period_set_name = c_period_set_name
     and g.period_type = c_period_type
     )));



     cursor chk_ra_for_bl_exists_csr(c_budget_version_id pa_budget_versions.budget_version_id%type) is
     select 'Y' from dual
     where exists (select 'Y' from pa_budget_lines bl
     where bl.budget_version_id = c_budget_version_id
     group by resource_assignment_id
     having count(*) > 1);

     --Bug 4176129
     cursor get_per_type_csr(c_org_id pa_projects_all.org_id%type,
			     c_period_set_name gl_sets_of_books.period_set_name%type) is
     select pi.pa_period_type,sob.accounted_period_type
     from pa_implementations_all pi,
     gl_sets_of_books sob
     where nvl(pi.org_id,-99) = c_org_id
     and sob.set_of_books_id = pi.set_of_books_id
     and exists
     (select 1
      from   gl_date_period_map g
      where  g.period_set_name=c_period_set_name);



     -- Begin Bug 3890562, 17-SEP-2004, jwhite ---------------------------------
     -- Make query similar to get_budget_lines_csr, which explodes date-range into PA/GL periodic data.


     cursor chk_pa_gl_per_exists_csr(c_period_type pa_implementations_all.pa_period_type%type
                                ,c_budget_version_id pa_budget_versions.budget_version_id%type
				,c_period_set_name gl_sets_of_books.period_set_name%type) is
     select 'Y' from dual
     where exists ( select 'Y'
     from pa_budget_lines bl
          ,gl_periods gl
     where bl.budget_version_id = c_budget_version_id
     and gl.period_type = c_period_type
     and gl.period_set_name = c_period_set_name
     and gl.ADJUSTMENT_PERIOD_FLAG = 'N'
     and (bl.start_date between gl.start_date and gl.end_date
     or bl.end_date between gl.start_date and gl.end_date
     or (gl.start_date > bl.start_date and gl.end_date < bl.end_date)));

     --Bug 3988010. Removed the NVL so as not to upgrade NULL to 0

     cursor get_non_time_multi_csr(c_budget_version_id pa_budget_versions.budget_version_id%type) is
     select min(start_date) min_date ,max(end_date) max_date,
     sum(quantity) sum_quantity,
     sum(raw_cost) sum_raw_cost,
     sum(burdened_cost) sum_burdened_cost,
     sum(revenue) sum_revenue,
     sum(project_raw_cost) sum_project_raw_cost,
     sum(project_burdened_cost) sum_project_burdened_cost,
     sum(project_revenue) sum_project_revenue,
     sum(txn_raw_cost) sum_txn_raw_cost,
     sum(txn_burdened_cost) sum_txn_burdened_cost,
     sum(txn_revenue) sum_txn_revenue,
     resource_assignment_id,txn_currency_code
     from pa_budget_lines
     where budget_version_id = c_budget_version_id
     group by resource_assignment_id, txn_currency_code ;

     cursor get_res_assign_id_csr(c_budget_version_id pa_budget_lines.budget_version_id%type) is
     select resource_assignment_id,planning_start_date from pa_resource_assignments
     where budget_version_id = c_budget_version_id;

     -- bug 3673111, 14-JUL-04, jwhite --------------------------------------------------------
     -- Added the following to select and group-by: gl.start_date,gl.end_date, gl.PERIOD_NAME
     -- Rearragned group-by to group primary by period and then by txn currency code
     -- Removed the following from select and group-by: bl.start_date,bl.end_date
     -- Reversed the IN-parameter dates for spread_amount function call.

     -- Bug 3807889, 04-AUG-04, jwhite
     -- Added filter to EXCLUDE adjustment periods.
     --

     -- Bug  3988010. Removed the Calls to pa_misc.spread_amount function as that function
     -- rounds the amounts. The amounts will be upgraded without applying the round function.

     -- Bug 4215637. Used ratio_to_report Function to address the fractions of the date range falling into
     -- individual periods not summing upto 1

     -- Bug 4299635. The amounts are rounded to atmost 5 digits. This is done to make sure that the amounts
     -- for date range budgets are correctly upgraded to periodic budgets. PC/PFC amounts need not be rounded
     -- since they will re-derived by MC api which is called in PAFPUPGB.pls
     cursor get_budget_lines_csr(l_budget_version_id pa_budget_lines.budget_version_id%type,l_res_assign_id pa_resource_assignments.resource_assignment_id%type
,l_org_id pa_projects_all.org_id%type,l_per_type  pa_implementations_all.pa_period_type%type,l_period_set_name gl_sets_of_books.period_set_name%type) is
     select
     rs.resource_assignment_id resource_assignment_id,
     rs.txn_currency_code txn_currency_code,
     rs.gl_start_date gl_start_date,
     rs.gl_end_date gl_end_date,
     rs.PERIOD_NAME period_name,
     rs.rate_based_flag rate_based_flag,
     round(sum(rs.spr_quantity * factor),5) spr_quantity,
     sum(rs.spr_raw_cost * factor) spr_raw_cost,
     sum(rs.spr_burdened_cost * factor) spr_burdened_cost,
     sum(rs.spr_revenue * factor) spr_revenue,
     sum(rs.spr_project_raw_cost * factor) spr_project_raw_cost,
     sum(rs.spr_project_burdened_cost * factor) spr_project_burdened_cost,
     sum(rs.spr_project_revenue * factor) spr_project_revenue,
     round(sum(rs.spr_txn_raw_cost * factor),5) spr_txn_raw_cost,
     round(sum(rs.spr_txn_burdened_cost * factor),5) spr_txn_burdened_cost,
     round(sum(rs.spr_txn_revenue * factor),5) spr_txn_revenue,
     --Bug 4299635. The below columns will have the total amounts for the budget line accumulated into the first
     --PA/GL period into which the budget line falls. These amounts will be used later in comparing the actual
     --amounts that should get upgraded and the amounts that got upgraded
     sum(rs.spr_quantity * tot_amt_factor) total_qty,
     sum(rs.spr_txn_raw_cost * tot_amt_factor) total_txn_raw_cost,
     sum(rs.spr_txn_burdened_cost * tot_amt_factor) total_txn_burd_cost,
     sum(rs.spr_txn_revenue * tot_amt_factor) total_txn_revenue
     from(
         select
         bl.resource_assignment_id resource_assignment_id,
         ra.rate_based_flag rate_based_flag,
         bl.txn_currency_code txn_currency_code,
         gl.start_date gl_start_date,
         gl.end_date gl_end_date,
         gl.PERIOD_NAME period_name,
         bl.quantity spr_quantity,
         bl.raw_cost spr_raw_cost,
         bl.burdened_cost spr_burdened_cost,
         bl.revenue spr_revenue,
         bl.project_raw_cost spr_project_raw_cost,
         bl.project_burdened_cost spr_project_burdened_cost,
         bl.project_revenue spr_project_revenue,
         bl.txn_raw_cost spr_txn_raw_cost,
         bl.txn_burdened_cost spr_txn_burdened_cost,
         bl.txn_revenue spr_txn_revenue,
         ratio_to_report((decode(least(bl.start_date, gl.start_date),
                                 bl.start_date,decode(least(bl.end_date,gl.end_date),
                                                      gl.end_date,gl.end_date-gl.start_date+1,
                                                      bl.end_date,bl.end_date-gl.start_date+1),
                                 gl.start_date,decode(least(bl.end_date,gl.end_date),
                                                      gl.end_date,gl.end_date-bl.start_date+1,
                                                      bl.end_date,bl.end_date-bl.start_date+1))
                         )) OVER (PARTITION BY bl.budget_line_id) factor,
         --Bug 4299635. This factor will be used to derive the total amount that should get upgraded
         --for a planning txn
         DECODE(least(bl.start_date, gl.start_date),
                gl.start_date,1,
                0) tot_amt_factor
         from pa_budget_lines bl,gl_periods gl, pa_resource_assignments ra
         where bl.budget_version_id = l_budget_version_id
         and  ra.resource_assignment_id = l_res_assign_id
         and bl.resource_assignment_id = l_res_assign_id
         and gl.period_type = l_per_type
         and gl.period_set_name = l_period_set_name
         and gl.ADJUSTMENT_PERIOD_FLAG = 'N'                /*   Bug 3807889: Added this filter */
         and (bl.start_date between gl.start_date and gl.end_date
         or bl.end_date between gl.start_date and gl.end_date
         or (gl.start_date > bl.start_date and gl.end_date < bl.end_date)))rs
         group by resource_assignment_id, gl_start_date, PERIOD_NAME, txn_currency_code, gl_end_date,rate_based_flag;


     -- End bug 3673111, 14-JUL-04, jwhite --------------------------------------------------------


     -- Bug 3804286, 12-AUG-03, jwhite ---------------------------------------------------------

     cursor get_period_mask_id_csr(c_time_phased_code pa_period_masks_b.time_phase_code%TYPE)
     is
     select period_mask_id
     from pa_period_masks_b
     where pre_defined_flag='Y'
     and   time_phase_code = c_time_phased_code;

     -- End Bug 3804286, 12-AUG-03, jwhite ------------------------------------------------------


     TYPE budget_lines_tbl is table of get_budget_lines_csr%ROWTYPE
     index by binary_integer;
     l_get_budget_lines_tbl budget_lines_tbl;

     l_project_id pa_budget_versions.project_id%TYPE;
     l_one_ra_exists varchar2(1) := 'N';
     l_one_ra_for_bl_exists varchar2(1) := 'N';
     l_pa_per_exists varchar2(1) := 'N';
     l_gl_per_exists varchar2(1) := 'N';
     l_budget_version_id pa_budget_versions.budget_version_id%type;
     l_time_phased_mode varchar2(1) := null;
     l_pa_period_type pa_implementations_all.pa_period_type%type;
     l_per_type pa_implementations_all.pa_period_type%type;
     l_accounted_per_type pa_implementations_all.pa_period_type%type;
     l_min_date date;
     g_upgrade_mode varchar2(100);
     l_counter number := 0;
     l_attribute_category pa_budget_lines.attribute_category%type;
     l_attribute1 pa_budget_lines.attribute1%type;
     l_attribute2 pa_budget_lines.attribute2 %type;
     l_attribute3 pa_budget_lines.attribute3%type;
     l_attribute4 pa_budget_lines.attribute4%type;
     l_attribute5 pa_budget_lines.attribute5%type;
     l_attribute6 pa_budget_lines.attribute6%type;
     l_attribute7 pa_budget_lines.attribute7%type;
     l_attribute8 pa_budget_lines.attribute8%type;
     l_attribute9 pa_budget_lines.attribute9%type;
     l_attribute10 pa_budget_lines.attribute10%type;
     l_attribute11 pa_budget_lines.attribute11%type;
     l_attribute12 pa_budget_lines.attribute12 %type;
     l_attribute13 pa_budget_lines.attribute13%type;
     l_attribute14 pa_budget_lines.attribute14%type;
     l_attribute15 pa_budget_lines.attribute15%type ;
     l_plan_ver_exists varchar2(1) := 'Y';
     l_debug_mode varchar2(30);
     l_module_name VARCHAR2(100):= 'pa.plsql.PA_DATE_RANGE_PKG';
     l_msg_index_out                 NUMBER;
     l_data                          VARCHAR2(2000);
     l_msg_data                      VARCHAR2(2000);
     l_msg_count    number;



     -- Bug 3804286, 12-AUG-04, jwhite -----------------------------------------------

     l_project_start_date    pa_projects_all.start_date%TYPE := NULL;
     l_org_id                pa_projects_all.org_id%TYPE := NULL;

     l_period_mask_id               pa_period_masks_b.period_mask_id%type;
     l_curr_plan_period             pa_budget_versions.current_planning_period%type;
     l_cost_current_planning_period pa_proj_fp_options.cost_current_planning_period%type;
     l_cost_period_mask_id          pa_proj_fp_options.cost_period_mask_id%type;
     l_rev_current_planning_period  pa_proj_fp_options.rev_current_planning_period%type;
     l_rev_period_mask_id           pa_proj_fp_options.rev_period_mask_id%type;
     l_all_current_planning_period  pa_proj_fp_options.all_current_planning_period%type;
     l_all_period_mask_id           pa_proj_fp_options.all_period_mask_id%type;

     -- End Bug 3804286, 12-AUG-04, jwhite --------------------------------------------

    --Bug 4299635. These tbls given below will use txn currency code as index.
    TYPE varchar2_indexed_num_tbl_type IS TABLE OF NUMBER INDEX BY VARCHAR2(15);
    TYPE varchar2_indexed_date_tbl_type IS TABLE OF DATE INDEX BY VARCHAR2(15);

    l_plan_txn_post_upg_qty_tbl     varchar2_indexed_num_tbl_type;
    l_plan_txn_act_qty_tbl          varchar2_indexed_num_tbl_type;
    l_plan_txn_post_upg_rc_tbl      varchar2_indexed_num_tbl_type;
    l_plan_txn_act_rc_tbl           varchar2_indexed_num_tbl_type;
    l_plan_txn_post_upg_bc_tbl      varchar2_indexed_num_tbl_type;
    l_plan_txn_act_bc_tbl           varchar2_indexed_num_tbl_type;
    l_plan_txn_post_upg_rev_tbl     varchar2_indexed_num_tbl_type;
    l_plan_txn_act_rev_tbl          varchar2_indexed_num_tbl_type;
    l_last_bl_indx_in_plan_txn_tbl  varchar2_indexed_num_tbl_type;
    l_max_st_dt_in_plan_txn_tbl     varchar2_indexed_date_tbl_type;
    l_txn_curr_index                pa_fp_txn_currencies.txn_currency_code%TYPE;
    l_last_bl_index                 NUMBER;
    --Bug 4919018
    l_pi_pa_period_type			pa_implementations_all.pa_period_type%type;
    l_sob_accounted_period_type         gl_sets_of_books.accounted_period_type%type;
    l_sob_period_set_name		gl_sets_of_books.period_set_name%type;




BEGIN



       x_msg_count := 0;
       x_msg_data  := NULL;
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       pa_debug.init_err_stack('PA_DATE_RANGE_PKG.DATE_RANGE_UPGRD');
       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
       l_debug_mode := NVL(l_debug_mode, 'Y');
       pa_debug.set_process('PLSQL','LOG',l_debug_mode);
       IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Entered Date Range Upgrade';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

         pa_debug.g_err_stage := 'Checking for valid parameters';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;



    if (p_budget_versions.count <= 0 ) then
        IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'Budget Versions Not Passed as Input';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;
          PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                               p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    end if;




  for j in p_budget_versions.first .. p_budget_versions.last

  loop

    l_plan_ver_exists   := 'N'; -- No rows found by chk_plan_ver_csr
    l_budget_version_id := p_budget_versions(j);


    open chk_plan_ver_csr(p_budget_versions(j));
    fetch chk_plan_ver_csr into l_project_id, l_plan_ver_exists;
    close chk_plan_ver_csr;



    -- Bug 3673111, 07-JUN-04, jwhite ------------------------------------------



    if ( nvl(l_plan_ver_exists, 'N') = 'N' ) then


       --NOT Plan-Version: SKIP to the Next Budget Version
       IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'SKIPPED NON-Plan-Version Budget Version='||to_char(l_budget_version_id);
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
       END IF;

       GOTO skip_version;   -- goto end of budget version loop

    end if;

    -- End Bug 3673111, 07-JUN-04, jwhite ----------------------------------------

    -- Loop for each eligible Budget Version
    for l_get_elig_bud_ver_csr in get_elig_bud_ver_csr(l_project_id,p_budget_versions(j))
    loop

        l_one_ra_exists := 'N';
        l_one_ra_for_bl_exists := 'N';
        l_pa_per_exists := 'N';
        l_gl_per_exists := 'N';
        l_pa_period_type := NULL;
        l_accounted_per_type := NULL;
        l_time_phased_mode := 'N';
        l_per_type := NULL;
        g_upgrade_mode := 'Non_Time_Phase';
        -- Bug 3804286, 12-AUG-04, jwhite -----------------------------------------------

        l_period_mask_id               := NULL;
        l_curr_plan_period             := NULL;
        l_cost_current_planning_period := NULL;
        l_cost_period_mask_id          := NULL;
        l_rev_current_planning_period  := NULL;
        l_rev_period_mask_id           := NULL;
        l_all_current_planning_period  := NULL;
        l_all_period_mask_id           := NULL;

        l_project_start_date := NULL;
        l_org_id             := NULL;

        select trunc(sysdate) into l_min_date from dual;

	--Bug 4919018
	open ftch_period_details_csr(l_get_elig_bud_ver_csr.org_id);
	fetch ftch_period_details_csr into l_pi_pa_period_type, l_sob_accounted_period_type, l_sob_period_set_name;
	close ftch_period_details_csr;

        -- End Bug 3804286, 12-AUG-04, jwhite -----------------------------------------------


       /* project/plan type level records would have version id as null and hence
          l_one_ra_for_bl_exists would be N */

        -- Check ifbudget line exists for RAId then upgrade_mode = non_time_phase
        open chk_ra_for_bl_exists_csr(l_get_elig_bud_ver_csr.budget_version_id);
        fetch chk_ra_for_bl_exists_csr into l_one_ra_for_bl_exists;
        close chk_ra_for_bl_exists_csr;


       -- Bug 3673111, 07-JUN-04, jwhite ------------------------------------------
       -- if (l_one_ra_for_bl_exists = 'Y'), then multiple budget lines exist for a given resource assignment.
       -- Multiple budget lines must have different start dates and, therefore, different date ranges.
       -- Effectively, multiple budget lines per resource assignment implies periodic budget line defintion.
       --
       -- Therefore, this if/end if must test for "l_one_ra_for_bl_exists = 'Y'"
       -- for PERIODIC processing.
       --

       /* From this point in code, the local variables would be N for project/plan type level records,
          and this takes care of no extra processing happening wrto reading budget version related data.
          Also, for this case (project/plan type level record), the time phased code local variable
          initailization ensures that the time phased code is set to N. */

       if (l_one_ra_for_bl_exists = 'Y')   /* bug 3673111: Changed 'N' to 'Y'   */
             then


        -- Check if PA Period exists
        open get_per_type_csr(l_get_elig_bud_ver_csr.org_id, l_sob_period_set_name);
        fetch get_per_type_csr into l_pa_period_type,l_accounted_per_type;
        close get_per_type_csr;

        --Bug 4046492.Call the function to derive the Time Phase to which the budget version should be upgraded
        l_time_phased_mode := PA_DATE_RANGE_PKG.get_time_phase_mode(p_budget_version_id =>l_get_elig_bud_ver_csr.budget_version_id
                                                                   ,p_pa_period_type    =>l_pa_period_type
                                                                   ,p_gl_period_type    =>l_accounted_per_type
                                                                   ,p_org_id            =>l_get_elig_bud_ver_csr.org_id);
        IF l_time_phased_mode='P' THEN

            l_pa_per_exists:='Y';

        ELSIF l_time_phased_mode='G' THEN

            l_gl_per_exists:='Y';

        END IF;

       end if;  -- l_one_ra_for_bl_exists = 'Y'

       -- End Bug 3673111, 07-JUN-04, jwhite ------------------------------------------



        -- Check if atleast one RA exists where there are no PA / GL Period defined between start , end date of the pa_res_assignment then upgrade_mode = non_time_phase
        if (l_pa_per_exists = 'Y') or (l_gl_per_exists = 'Y') then

            --Bug 4176129. The fact that either l_pa_per_exists or l_gl_per_exists is Y indicates that  l_pa_period_type and
            --l_accounted_per_type used below are not null and initialized in the above loop.
            if (l_pa_per_exists ='Y') then
                open chk_ra_exists_csr(l_get_elig_bud_ver_csr.budget_version_id,l_pa_period_type,l_sob_period_set_name);
                fetch chk_ra_exists_csr into l_one_ra_exists;
                close chk_ra_exists_csr;
            else
                open chk_ra_exists_csr(l_get_elig_bud_ver_csr.budget_version_id,l_accounted_per_type,l_sob_period_set_name);
                fetch chk_ra_exists_csr into l_one_ra_exists;
                close chk_ra_exists_csr;
            end if;

        end if;



       -- Bug 3673111, 07-JUN-04, jwhite ------------------------------------------

       -- if (l_one_ra_for_bl_exists = 'Y'), the multiple budget lines exist for a given resource assignment.
       -- Multiple budget lines must have different start dates and, therefore, different date ranges.
       -- Effectively, multiple budget lines per resource assignment implies periodic budget line defintion.
       --
       -- Therefore, this if/end if must test for "l_one_ra_for_bl_exists = 'N'" to identifY
       -- NON-TIME-PHASE processing.
       --




        if ((l_one_ra_for_bl_exists = 'N') or (l_one_ra_exists = 'Y')) then /* Bug 3673111 */
            g_upgrade_mode := 'Non_Time_Phase';
            l_time_phased_mode := 'N';
        elsif (l_pa_per_exists = 'Y') then
            g_upgrade_mode := 'PA_Period_Upgrade';
            l_time_phased_mode := 'P';
        elsif (l_gl_per_exists = 'Y') then
            g_upgrade_mode := 'GL_Period_Upgrade';
            l_time_phased_mode := 'G';
        else
            g_upgrade_mode := 'Non_Time_Phase_Multi_Line';
            l_time_phased_mode := 'N';
        end if;

      -- End Bug 3673111, 07-JUN-04, jwhite ------------------------------------------------------

       IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Mode of the upgrade';
         pa_debug.write(l_module_name,'Upgrade Mode is' || g_upgrade_mode,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       end if;


       IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Updating pa_proj_fp_options table';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       end if;

       -- Bug 3804286, 12-AUG-03, jwhite -------------------------------------------------------------

       -- Update the PLAN_VERSION Options Record with the Various Derived Values

       -- For Periodic Budget Versions, Get the Start Date for
       -- Subseqeunt Derivation of the Current Planning Period Name.


        IF ( l_time_phased_mode IN ('G','P' ) )
           THEN

            l_project_start_date := l_get_elig_bud_ver_csr.start_date;
            l_org_id             := l_get_elig_bud_ver_csr.org_id;


             -- If Project Start is Still NUll,
             --   then Find Minimum Budget Line Start Date, If Any.
             IF ( l_project_start_date IS NULL)
               THEN

                 begin

                   SELECT min(start_date)
                   INTO   l_project_start_date
                   FROM   pa_budget_lines
                   WHERE  budget_version_id = l_get_elig_bud_ver_csr.budget_version_id;

                   /* Following "if" takes care of case when there no budget lines for the budget verison
                      or
                      the record that is processed is a project/plan type level record. */

                   IF l_project_start_date IS NULL THEN
                         select trunc(sysdate) into l_project_start_date from dual;
                   END IF;

                 end;

             END IF; -- l_project_start_date IS NULL)


             -- IF Start Date FOUND,
             --    THEN Derive GL/PA Period Name to Populate the Current Planning Period

             IF ( l_project_start_date IS NULL)
               THEN

                l_curr_plan_period := NULL;

               ELSE

                IF (l_time_phased_mode = 'G')
                    THEN
                    -- Get GL Period Name

                    begin

                      SELECT gl.PERIOD_NAME
                      INTO   l_curr_plan_period
                      FROM   gl_periods gl
                      WHERE  gl.period_type = l_accounted_per_type
                      and    l_project_start_date between gl.START_DATE and gl.END_DATE
                      AND    gl.period_set_name = l_sob_period_set_name
                      AND    gl.ADJUSTMENT_PERIOD_FLAG = 'N';

                      exception
                        WHEN NO_DATA_FOUND THEN
                          l_curr_plan_period := NULL;

                    end;

                    -- Get GL Period Mask Id. This Must Exist.
                    Open  get_period_mask_id_csr('G');
                    Fetch get_period_mask_id_csr INTO l_period_mask_id;
                    Close get_period_mask_id_csr;


                 End IF; -- GL Period Type

                 IF (l_time_phased_mode = 'P')
                    THEN
                    -- Get PA Period Name

                    begin

                      SELECT gl.PERIOD_NAME
                      INTO   l_curr_plan_period
                      FROM   gl_periods gl
                      WHERE  gl.period_type = l_PA_period_type
                      and    l_project_start_date between gl.START_DATE and gl.END_DATE
                      AND    gl.period_set_name = l_sob_period_set_name
                      AND    gl.ADJUSTMENT_PERIOD_FLAG = 'N';

                      exception
                        WHEN NO_DATA_FOUND THEN
                          l_curr_plan_period := NULL;

                    end;

                    -- Get PA Period Mask Id. This Must Exist.
                    Open  get_period_mask_id_csr('P');
                    Fetch get_period_mask_id_csr INTO l_period_mask_id;
                    Close get_period_mask_id_csr;


                 End IF; -- PA Period Type

             End if; --l_project_start_date IS NULL

        Else
              -- Catch All Conditon (l_time_phased_mode s/b 'N')

                 l_curr_plan_period := NULL;
                 l_period_mask_id   := NULL;
        End IF; -- l_time_phased_mode


        IF (l_get_elig_bud_ver_csr.fin_plan_preference_code = 'COST_ONLY')
           then

            l_cost_current_planning_period := l_curr_plan_period;
            l_cost_period_mask_id := l_period_mask_id;
        elsif (l_get_elig_bud_ver_csr.fin_plan_preference_code = 'REVENUE_ONLY')
           then

            l_rev_current_planning_period := l_curr_plan_period;
            l_rev_period_mask_id := l_period_mask_id;
        elsif (l_get_elig_bud_ver_csr.fin_plan_preference_code = 'COST_AND_REV_SEP')
           then

            l_cost_current_planning_period := l_curr_plan_period;
            l_cost_period_mask_id := l_period_mask_id;
            l_rev_current_planning_period := l_curr_plan_period;
            l_rev_period_mask_id := l_period_mask_id;
        else

            l_all_current_planning_period := l_curr_plan_period;
            l_all_period_mask_id := l_period_mask_id;
        End IF;

        -- Update Values that Have Changed Because of this Date-Range Conversion
        -- Time phased code is updated based on whether it is 'R' or not instead of using
        -- fin plan pref code since the options selected would surely have either cost/rev/all or
        -- both cost and rev (in case of cost-and-rev-sep pref code) as 'R'. 'COST AND REV SEP'
        -- is not budget version level but for project/plan type level record of fp opt.

        UPDATE pa_proj_fp_options
        SET    cost_time_phased_code     = decode(cost_time_phased_code,'R',l_time_phased_mode,cost_time_phased_code),        /* Bug 3792821 */
               revenue_time_phased_code  = decode(revenue_time_phased_code,'R',l_time_phased_mode,revenue_time_phased_code), /* Bug 3792821 */
               all_time_phased_code      = decode(all_time_phased_code,'R',l_time_phased_mode,all_time_phased_code),        /* Bug 3792821 */
               cost_current_planning_period = l_cost_current_planning_period,
               cost_period_mask_id          = l_cost_period_mask_id,
               rev_current_planning_period  = l_rev_current_planning_period,
               rev_period_mask_id           = l_rev_period_mask_id,
               all_current_planning_period  = l_all_current_planning_period ,
               all_period_mask_id           = l_all_period_mask_id
        WHERE proj_fp_options_id  = l_get_elig_bud_ver_csr.proj_fp_options_id;

       /* Including this IF so that we can avoid an update (though it would do nothing) in case
          of project/plan type level record */
       IF l_get_elig_bud_ver_csr.fin_plan_option_level_code = 'PLAN_VERSION' THEN

            update pa_budget_versions
            SET current_planning_period      =     l_curr_plan_period,
                period_mask_id               =     l_period_mask_id
            where budget_version_id          =     l_get_elig_bud_ver_csr.budget_version_id;

       END IF;

       -- End Bug 3804286, 12-AUG-03, jwhite ---------------------------------------------------------
       /* g_upgrade_mode would be 'Non_Time_Phase' for project/plan type level record and hence
          none of the below processing would be done for them */

        if g_upgrade_mode = 'Non_Time_Phase_Multi_Line' then
         IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Entered Non Time Phase Multi Line';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         end if;
              -- Loop for each budget line for the given version
              for l_get_non_time_multi_csr in get_non_time_multi_csr(l_get_elig_bud_ver_csr.budget_version_id)
              loop
                  insert into  pa_budget_lines_m_upg_dtrange
                  (
                  resource_assignment_id,
                  start_date,
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by  ,
                  last_update_login,
                  end_date,
                  period_name,
                  quantity,
                  raw_cost,
                  burdened_cost  ,
                  revenue  ,
                  change_reason_code,
                  description ,
                  attribute_category ,
                  attribute1,
                  attribute2  ,
                  attribute3 ,
                  attribute4,
                  attribute5,
                  attribute6,
                  attribute7  ,
                  attribute8 ,
                  attribute9,
                  attribute10,
                  attribute11,
                  attribute12,
                  attribute13  ,
                  attribute14 ,
                  attribute15,
                  raw_cost_source,
                  burdened_cost_source,
                  quantity_source  ,
                  revenue_source  ,
                  pm_product_code,
                  pm_budget_line_reference  ,
                  cost_rejection_code ,
                  revenue_rejection_code  ,
                  burden_rejection_code  ,
                  other_rejection_code  ,
                  code_combination_id  ,
                  ccid_gen_status_code,
                  ccid_gen_rej_message  ,
                  request_id ,
                  borrowed_revenue ,
                  tp_revenue_in,
                  tp_revenue_out ,
                  revenue_adj,
                  lent_resource_cost,
                  tp_cost_in  ,
                  tp_cost_out,
                  cost_adj  ,
                  unassigned_time_cost,
                  utilization_percent,
                  utilization_hours ,
                  utilization_adj  ,
                  capacity,
                  head_count  ,
                  head_count_adj,
                  projfunc_currency_code,
                  projfunc_cost_rate_type ,
                  projfunc_cost_exchange_rate,
                  projfunc_cost_rate_date_type  ,
                  projfunc_cost_rate_date ,
                  projfunc_rev_rate_type ,
                  projfunc_rev_exchange_rate ,
                  projfunc_rev_rate_date_type  ,
                  projfunc_rev_rate_date ,
                  project_currency_code ,
                  project_cost_rate_type ,
                  project_cost_exchange_rate ,
                  project_cost_rate_date_type  ,
                  project_cost_rate_date,
                  project_raw_cost ,
                  project_burdened_cost  ,
                  project_rev_rate_type ,
                  project_rev_exchange_rate,
                  project_rev_rate_date_type  ,
                  project_rev_rate_date ,
                  project_revenue,
                  txn_currency_code,
                  txn_raw_cost,
                  txn_burdened_cost ,
                  txn_revenue,
                  bucketing_period_code,
                  budget_line_id ,
                  budget_version_id)
                 ( select
                  resource_assignment_id,
                  start_date,
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by  ,
                  last_update_login,
                  end_date,
                  period_name,
                  quantity,
                  raw_cost,
                  burdened_cost  ,
                  revenue  ,
                  change_reason_code,
                  description ,
                  attribute_category ,
                  attribute1,
                  attribute2  ,
                  attribute3 ,
                  attribute4,
                  attribute5,
                  attribute6,
                  attribute7  ,
                  attribute8 ,
                  attribute9,
                  attribute10,
                  attribute11,
                  attribute12,
                  attribute13  ,
                  attribute14 ,
                  attribute15,
                  raw_cost_source,
                  burdened_cost_source,
                  quantity_source  ,
                  revenue_source  ,
                  pm_product_code,
                  pm_budget_line_reference  ,
                  cost_rejection_code ,
                  revenue_rejection_code  ,
                  burden_rejection_code  ,
                  other_rejection_code  ,
                  code_combination_id  ,
                  ccid_gen_status_code,
                  ccid_gen_rej_message  ,
                  request_id ,
                  borrowed_revenue ,
                  tp_revenue_in,
                  tp_revenue_out ,
                  revenue_adj,
                  lent_resource_cost,
                  tp_cost_in  ,
                  tp_cost_out,
                  cost_adj  ,
                  unassigned_time_cost,
                  utilization_percent,
                  utilization_hours ,
                  utilization_adj  ,
                  capacity,
                  head_count  ,
                  head_count_adj,
                  projfunc_currency_code,
                  projfunc_cost_rate_type ,
                  projfunc_cost_exchange_rate,
                  projfunc_cost_rate_date_type  ,
                  projfunc_cost_rate_date ,
                  projfunc_rev_rate_type ,
                  projfunc_rev_exchange_rate ,
                  projfunc_rev_rate_date_type  ,
                  projfunc_rev_rate_date ,
                  project_currency_code ,
                  project_cost_rate_type ,
                  project_cost_exchange_rate ,
                  project_cost_rate_date_type  ,
                  project_cost_rate_date,
                  project_raw_cost ,
                  project_burdened_cost  ,
                  project_rev_rate_type ,
                  project_rev_exchange_rate,
                  project_rev_rate_date_type  ,
                  project_rev_rate_date ,
                  project_revenue,
                  txn_currency_code,
                  txn_raw_cost,
                  txn_burdened_cost ,
                  txn_revenue,
                  bucketing_period_code,
                  budget_line_id ,
                  budget_version_id from pa_budget_lines where
                  resource_assignment_id =  l_get_non_time_multi_csr.resource_assignment_id
                  and txn_currency_code = l_get_non_time_multi_csr.txn_currency_code
                  and budget_version_id = l_get_elig_bud_ver_csr.budget_version_id);

                  delete from pa_budget_lines
                  where resource_assignment_id = l_get_non_time_multi_csr.resource_assignment_id
                  and txn_currency_code = l_get_non_time_multi_csr.txn_currency_code
                  and start_date <> l_get_non_time_multi_csr.min_date
                  and budget_version_id = l_get_elig_bud_ver_csr.budget_version_id;

                  update pa_budget_lines
                  set start_date = l_get_non_time_multi_csr.min_date,
                      end_date   = l_get_non_time_multi_csr.max_date,
                      quantity   = l_get_non_time_multi_csr.sum_quantity,
                      raw_cost   = l_get_non_time_multi_csr.sum_raw_cost,
                      burdened_cost = l_get_non_time_multi_csr.sum_burdened_cost,
                      revenue    = l_get_non_time_multi_csr.sum_revenue,
                      project_raw_cost = l_get_non_time_multi_csr.sum_project_raw_cost,
                      project_burdened_cost = l_get_non_time_multi_csr.sum_project_burdened_cost,
                      project_revenue  = l_get_non_time_multi_csr.sum_project_revenue,
                      txn_raw_cost = l_get_non_time_multi_csr.sum_txn_raw_cost,
                      txn_burdened_cost = l_get_non_time_multi_csr.sum_txn_burdened_cost,
                      txn_revenue = l_get_non_time_multi_csr.sum_txn_revenue
                  where resource_assignment_id = l_get_non_time_multi_csr.resource_assignment_id
                  and txn_currency_code = l_get_non_time_multi_csr.txn_currency_code
                  and start_date = l_get_non_time_multi_csr.min_date
                  and budget_version_id = l_get_elig_bud_ver_csr.budget_version_id;

              end loop;
              -- Loop for each budget line for the given version ends here
	end if;
        if (g_upgrade_mode = 'PA_Period_Upgrade')  or (g_upgrade_mode = 'GL_Period_Upgrade') then

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Entered PA/GL Period Upgrade';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         end if;

           -- Loop for Resource Assignment Id for given Budget Version
           select decode(g_upgrade_mode,'PA_Period_Upgrade',l_pa_period_type,l_accounted_per_type) into l_per_type from dual;
           for l_get_res_assign_id_csr in get_res_assign_id_csr(l_get_elig_bud_ver_csr.budget_version_id)
           loop


            -- Bug 3673111, 07-JUN-04, jwhite ------------------------------------------
            -- Added begin/end block to catch no_data_found ORA errors.

            begin
                 select
                 attribute_category ,
                 attribute1  ,
                 attribute2 ,
                 attribute3,
                 attribute4,
                 attribute5 ,
                 attribute6,
                 attribute7  ,
                 attribute8 ,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12 ,
                 attribute13,
                 attribute14  ,
                 attribute15
                 into
                 l_attribute_category ,
                 l_attribute1  ,
                 l_attribute2 ,
                 l_attribute3,
                 l_attribute4,
                 l_attribute5 ,
                 l_attribute6,
                 l_attribute7  ,
                 l_attribute8 ,
                 l_attribute9,
                 l_attribute10,
                 l_attribute11,
                 l_attribute12 ,
                 l_attribute13,
                 l_attribute14  ,
                 l_attribute15
                 from pa_budget_lines where
                 start_date = l_get_res_assign_id_csr.planning_start_date
                 and resource_assignment_id = l_get_res_assign_id_csr.resource_assignment_id;

                exception
                    when no_data_found then
                 l_attribute_category := Null;
                 l_attribute1         := Null;
                 l_attribute2         := Null;
                 l_attribute3         := Null;
                 l_attribute4         := Null;
                 l_attribute5         := Null;
                 l_attribute6         := Null;
                 l_attribute7         := Null;
                 l_attribute8         := Null;
                 l_attribute9         := Null;
                 l_attribute10        := Null;
                 l_attribute11        := Null;
                 l_attribute12        := Null;
                 l_attribute13        := Null;
                 l_attribute14        := Null;
                 l_attribute15        := Null;
             end;


            -- End Bug 3673111, 07-JUN-04, jwhite ------------------------------------------




                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Inserting into Backup Table';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                 end if;

                  insert into  pa_budget_lines_m_upg_dtrange
                  (
                  resource_assignment_id,
                  start_date,
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by  ,
                  last_update_login,
                  end_date,
                  period_name,
                  quantity,
                  raw_cost,
                  burdened_cost  ,
                  revenue  ,
                  change_reason_code,
                  description ,
                  attribute_category ,
                  attribute1,
                  attribute2  ,
                  attribute3 ,
                  attribute4,
                  attribute5,
                  attribute6,
                  attribute7  ,
                  attribute8 ,
                  attribute9,
                  attribute10,
                  attribute11,
                  attribute12,
                  attribute13  ,
                  attribute14 ,
                  attribute15,
                  raw_cost_source,
                  burdened_cost_source,
                  quantity_source  ,
                  revenue_source  ,
                  pm_product_code,
                  pm_budget_line_reference  ,
                  cost_rejection_code ,
                  revenue_rejection_code  ,
                  burden_rejection_code  ,
                  other_rejection_code  ,
                  code_combination_id  ,
                  ccid_gen_status_code,
                  ccid_gen_rej_message  ,
                  request_id ,
                  borrowed_revenue ,
                  tp_revenue_in,
                  tp_revenue_out ,
                  revenue_adj,
                  lent_resource_cost,
                  tp_cost_in  ,
                  tp_cost_out,
                  cost_adj  ,
                  unassigned_time_cost,
                  utilization_percent,
                  utilization_hours ,
                  utilization_adj  ,
                  capacity,
                  head_count  ,
                  head_count_adj,
                  projfunc_currency_code,
                  projfunc_cost_rate_type ,
                  projfunc_cost_exchange_rate,
                  projfunc_cost_rate_date_type  ,
                  projfunc_cost_rate_date ,
                  projfunc_rev_rate_type ,
                  projfunc_rev_exchange_rate ,
                  projfunc_rev_rate_date_type  ,
                  projfunc_rev_rate_date ,
                  project_currency_code ,
                  project_cost_rate_type ,
                  project_cost_exchange_rate ,
                  project_cost_rate_date_type  ,
                  project_cost_rate_date,
                  project_raw_cost ,
                  project_burdened_cost  ,
                  project_rev_rate_type ,
                  project_rev_exchange_rate,
                  project_rev_rate_date_type  ,
                  project_rev_rate_date ,
                  project_revenue,
                  txn_currency_code,
                  txn_raw_cost,
                  txn_burdened_cost ,
                  txn_revenue,
                  bucketing_period_code,
                  budget_line_id ,
                  budget_version_id)
                  select
                  resource_assignment_id,
                  start_date,
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by  ,
                  last_update_login,
                  end_date,
                  period_name,
                  quantity,
                  raw_cost,
                  burdened_cost  ,
                  revenue  ,
                  change_reason_code,
                  description ,
                  attribute_category ,
                  attribute1,
                  attribute2  ,
                  attribute3 ,
                  attribute4,
                  attribute5,
                  attribute6,
                  attribute7  ,
                  attribute8 ,
                  attribute9,
                  attribute10,
                  attribute11,
                  attribute12,
                  attribute13  ,
                  attribute14 ,
                  attribute15,
                  raw_cost_source,
                  burdened_cost_source,
                  quantity_source  ,
                  revenue_source  ,
                  pm_product_code,
                  pm_budget_line_reference  ,
                  cost_rejection_code ,
                  revenue_rejection_code  ,
                  burden_rejection_code  ,
                  other_rejection_code  ,
                  code_combination_id  ,
                  ccid_gen_status_code,
                  ccid_gen_rej_message  ,
                  request_id ,
                  borrowed_revenue ,
                  tp_revenue_in,
                  tp_revenue_out ,
                  revenue_adj,
                  lent_resource_cost,
                  tp_cost_in  ,
                  tp_cost_out,
                  cost_adj  ,
                  unassigned_time_cost,
                  utilization_percent,
                  utilization_hours ,
                  utilization_adj  ,
                  capacity,
                  head_count  ,
                  head_count_adj,
                  projfunc_currency_code,
                  projfunc_cost_rate_type ,
                  projfunc_cost_exchange_rate,
                  projfunc_cost_rate_date_type  ,
                  projfunc_cost_rate_date ,
                  projfunc_rev_rate_type ,
                  projfunc_rev_exchange_rate ,
                  projfunc_rev_rate_date_type  ,
                  projfunc_rev_rate_date ,
                  project_currency_code ,
                  project_cost_rate_type ,
                  project_cost_exchange_rate ,
                  project_cost_rate_date_type  ,
                  project_cost_rate_date,
                  project_raw_cost ,
                  project_burdened_cost  ,
                  project_rev_rate_type ,
                  project_rev_exchange_rate,
                  project_rev_rate_date_type  ,
                  project_rev_rate_date ,
                  project_revenue,
                  txn_currency_code,
                  txn_raw_cost,
                  txn_burdened_cost ,
                  txn_revenue,
                  bucketing_period_code,
                  budget_line_id ,
                  budget_version_id from pa_budget_lines where
                  budget_version_id = l_get_elig_bud_ver_csr.budget_version_id
                  and resource_assignment_id = l_get_res_assign_id_csr.resource_assignment_id;

                 l_counter := 0;
                 l_get_budget_lines_tbl.delete; /* bug 3673111: moved here from loop below */

                 --Bug 4299635
                 l_plan_txn_post_upg_qty_tbl.delete;
                 l_plan_txn_act_qty_tbl.delete;
                 l_plan_txn_post_upg_rc_tbl.delete;
                 l_plan_txn_act_rc_tbl.delete;
                 l_plan_txn_post_upg_bc_tbl.delete;
                 l_plan_txn_act_bc_tbl.delete;
                 l_plan_txn_post_upg_rev_tbl.delete;
                 l_plan_txn_act_rev_tbl.delete;
                 l_last_bl_indx_in_plan_txn_tbl.delete;
                 l_max_st_dt_in_plan_txn_tbl.delete;

                 -- Loop for Budget Lines for each Resource Assignment Id
           	 for l_get_budget_lines_csr in  get_budget_lines_csr(l_get_elig_bud_ver_csr.budget_version_id,l_get_res_assign_id_csr.resource_assignment_id,l_get_elig_bud_ver_csr.org_id,l_per_type, l_sob_period_set_name)
                 loop


                 -- bug 3673111, 14-JUL-04, jwhite --------------------------------------------------------
                 -- Purpose of the l_min_date is to find the earliest date for the budgets lines being processed.
                 --
                 -- For the original logic, With the l_min_date initialized to sysdate, the logic would not
                 -- work when all budget lines are created with dates beyond the current sysdate.

                 -- Therefore, added the following conditional initialization:

                 IF ( l_counter = 0 )
                    then

                        l_min_date :=  l_get_budget_lines_csr.gl_start_date;

                 End IF;

                 -- End Bug 3673111, 14-JUL-04, jwhite ---------------------------------------------------


                 l_counter := l_counter + 1;
                 if (l_min_date > l_get_budget_lines_csr.gl_start_date) then
                     l_min_date :=  l_get_budget_lines_csr.gl_start_date;
                 end if;

                 -- bug 3673111, 14-JUL-04, jwhite --------------------------------------------------------
                 --

                 -- 1) Moved statement "l_get_budget_lines_tbl.delete;" out of loop so ALL records could be stored
                 --    for subsequent processing. If inside loop, then only last record stored.
                 --
                 -- 2) For the start/end dates, changed the source to the GL start/end dates. This is necessary
                 --    to store the period start and end dates corresponding to the Period_Name on the pa_budget_lines.
                 --
                 -- 3) Added PERIOD_NAME to table array for the subsequent insert statement
                 --

                 -- 4) Added conditional testing for table array record count to prevent ORA errors.
                 --


                 l_get_budget_lines_tbl(l_counter).gl_start_date := l_get_budget_lines_csr.gl_start_date ;
                 l_get_budget_lines_tbl(l_counter).gl_end_date := l_get_budget_lines_csr.gl_end_date;
                 l_get_budget_lines_tbl(l_counter).resource_assignment_id := l_get_budget_lines_csr.resource_assignment_id;
                 l_get_budget_lines_tbl(l_counter).txn_currency_code := l_get_budget_lines_csr.txn_currency_code;
                 l_get_budget_lines_tbl(l_counter).spr_quantity := l_get_budget_lines_csr.spr_quantity;
                 l_get_budget_lines_tbl(l_counter).spr_raw_cost := l_get_budget_lines_csr.spr_raw_cost;
                 l_get_budget_lines_tbl(l_counter).spr_burdened_cost := l_get_budget_lines_csr.spr_burdened_cost;
                 l_get_budget_lines_tbl(l_counter).spr_revenue := l_get_budget_lines_csr.spr_revenue;
                 l_get_budget_lines_tbl(l_counter).spr_project_raw_cost := l_get_budget_lines_csr.spr_project_raw_cost;
                 l_get_budget_lines_tbl(l_counter).spr_project_burdened_cost := l_get_budget_lines_csr.spr_project_burdened_cost;
                 l_get_budget_lines_tbl(l_counter).spr_project_revenue := l_get_budget_lines_csr.spr_project_revenue;
                 l_get_budget_lines_tbl(l_counter).spr_txn_raw_cost := l_get_budget_lines_csr.spr_txn_raw_cost;
                 l_get_budget_lines_tbl(l_counter).spr_txn_burdened_cost := l_get_budget_lines_csr.spr_txn_burdened_cost;
                 l_get_budget_lines_tbl(l_counter).spr_txn_revenue := l_get_budget_lines_csr.spr_txn_revenue;
                 l_get_budget_lines_tbl(l_counter).PERIOD_NAME := l_get_budget_lines_csr.PERIOD_NAME;

                 --Bug 4299635
                 l_txn_curr_index:=l_get_budget_lines_csr.txn_currency_code;

                 --Derive the Quantity that should get upgraded (l_plan_txn_act_qty_tbl) and the quantity
                 --derived for upgrade (l_plan_txn_post_upg_qty_tbl).Bug 4299635
                 IF l_plan_txn_act_qty_tbl.EXISTS(l_txn_curr_index) THEN
                     l_plan_txn_act_qty_tbl(l_txn_curr_index) := nvl(l_plan_txn_act_qty_tbl(l_txn_curr_index),0) + nvl(l_get_budget_lines_csr.total_qty,0);
                 ELSE
                     l_plan_txn_act_qty_tbl(l_txn_curr_index) := nvl(l_get_budget_lines_csr.total_qty,0);
                 END IF;

                 IF l_plan_txn_post_upg_qty_tbl.EXISTS(l_txn_curr_index) THEN
                     l_plan_txn_post_upg_qty_tbl(l_txn_curr_index) := NVL(l_plan_txn_post_upg_qty_tbl(l_txn_curr_index),0) + nvl(l_get_budget_lines_csr.spr_quantity,0);
                 ELSE
                     l_plan_txn_post_upg_qty_tbl(l_txn_curr_index):=nvl(l_get_budget_lines_csr.spr_quantity,0);
                 END IF;

                 --Derive the txn raw cost that should get upgraded (l_plan_txn_act_rc_tbl) and the txn raw cost
                 --derived for upgrade (l_plan_txn_post_upg_rc_tbl).Bug 4299635
                 IF l_plan_txn_act_rc_tbl.EXISTS(l_txn_curr_index) THEN
                     l_plan_txn_act_rc_tbl(l_txn_curr_index) := nvl(l_plan_txn_act_rc_tbl(l_txn_curr_index),0) + nvl(l_get_budget_lines_csr.total_txn_raw_cost,0);
                 ELSE
                     l_plan_txn_act_rc_tbl(l_txn_curr_index) := nvl(l_get_budget_lines_csr.total_txn_raw_cost,0);
                 END IF;

                 IF l_plan_txn_post_upg_rc_tbl.EXISTS(l_txn_curr_index) THEN
                     l_plan_txn_post_upg_rc_tbl(l_txn_curr_index) := NVL(l_plan_txn_post_upg_rc_tbl(l_txn_curr_index),0) + nvl(l_get_budget_lines_csr.spr_txn_raw_cost,0);
                 ELSE
                     l_plan_txn_post_upg_rc_tbl(l_txn_curr_index):=nvl(l_get_budget_lines_csr.spr_txn_raw_cost,0);
                 END IF;

                 --Derive the txn burdened cost that should get upgraded (l_plan_txn_act_bc_tbl) and the txn burdened cost
                 --derived for upgrade (l_plan_txn_post_upg_bc_tbl).Bug 4299635
                 IF l_plan_txn_act_bc_tbl.EXISTS(l_txn_curr_index) THEN
                     l_plan_txn_act_bc_tbl(l_txn_curr_index) := nvl(l_plan_txn_act_bc_tbl(l_txn_curr_index),0) + nvl(l_get_budget_lines_csr.total_txn_burd_cost,0);
                 ELSE
                     l_plan_txn_act_bc_tbl(l_txn_curr_index) := nvl(l_get_budget_lines_csr.total_txn_burd_cost,0);
                 END IF;

                 IF l_plan_txn_post_upg_bc_tbl.EXISTS(l_txn_curr_index) THEN
                     l_plan_txn_post_upg_bc_tbl(l_txn_curr_index) := NVL(l_plan_txn_post_upg_bc_tbl(l_txn_curr_index),0) + nvl(l_get_budget_lines_csr.spr_txn_burdened_cost,0);
                 ELSE
                     l_plan_txn_post_upg_bc_tbl(l_txn_curr_index):=nvl(l_get_budget_lines_csr.spr_txn_burdened_cost,0);
                 END IF;

                 --Derive the txn revenue that should get upgraded (l_plan_txn_act_rev_tbl) and the txn revenue
                 --derived for upgrade (l_plan_txn_post_upg_rev_tbl).Bug 4299635
                 IF l_plan_txn_act_rev_tbl.EXISTS(l_txn_curr_index) THEN
                     l_plan_txn_act_rev_tbl(l_txn_curr_index) := nvl(l_plan_txn_act_rev_tbl(l_txn_curr_index),0) + nvl(l_get_budget_lines_csr.total_txn_revenue,0);
                 ELSE
                     l_plan_txn_act_rev_tbl(l_txn_curr_index) := nvl(l_get_budget_lines_csr.total_txn_revenue,0);
                 END IF;

                 IF l_plan_txn_post_upg_rev_tbl.EXISTS(l_txn_curr_index) THEN
                     l_plan_txn_post_upg_rev_tbl(l_txn_curr_index) := NVL(l_plan_txn_post_upg_rev_tbl(l_txn_curr_index),0) + nvl(l_get_budget_lines_csr.spr_txn_revenue,0);
                 ELSE
                     l_plan_txn_post_upg_rev_tbl(l_txn_curr_index):=nvl(l_get_budget_lines_csr.spr_txn_revenue,0);
                 END IF;

                 IF l_max_st_dt_in_plan_txn_tbl.EXISTS(l_txn_curr_index) THEN
                     IF l_max_st_dt_in_plan_txn_tbl(l_txn_curr_index) < l_get_budget_lines_csr.gl_start_date THEN
                         l_max_st_dt_in_plan_txn_tbl(l_txn_curr_index):=l_get_budget_lines_csr.gl_start_date;
                         l_last_bl_indx_in_plan_txn_tbl(l_txn_curr_index):=l_counter;
                     END IF;
                 ELSE
                     l_max_st_dt_in_plan_txn_tbl(l_txn_curr_index):=l_get_budget_lines_csr.gl_start_date;
                     l_last_bl_indx_in_plan_txn_tbl(l_txn_curr_index):=l_counter;
                 END IF;


                 end loop;
                 -- Loop for Budget Lines for each Resource Assignment Id




           IF (l_get_budget_lines_tbl.count > 0)   /* bug 3673111 */
               THEN

                 --Bug 4299635. If the amounts before and after upgrade do not tally then adjust the difference
                 -- in the last budget line of each palnning transaction
                 l_txn_curr_index := NULL;
                 FOR i IN 1..l_plan_txn_act_qty_tbl.COUNT LOOP

                     IF l_txn_curr_index IS NULL THEN

                         l_txn_curr_index := l_plan_txn_act_qty_tbl.FIRST;

                     ELSE

                         l_txn_curr_index := l_plan_txn_act_qty_tbl.NEXT(l_txn_curr_index);

                     END IF;
                     l_last_bl_index := l_last_bl_indx_in_plan_txn_tbl(l_txn_curr_index);

                     IF NVL(l_plan_txn_act_qty_tbl(l_txn_curr_index),0) <> NVL(l_plan_txn_post_upg_qty_tbl(l_txn_curr_index),0) THEN

                         l_get_budget_lines_tbl(l_last_bl_index).spr_quantity := nvl(l_get_budget_lines_tbl(l_last_bl_index).spr_quantity,0) +
                                                                                 NVL(l_plan_txn_act_qty_tbl(l_txn_curr_index),0) -
                                                                                 NVL(l_plan_txn_post_upg_qty_tbl(l_txn_curr_index),0);

                     END IF;

                     IF NVL(l_plan_txn_act_rc_tbl(l_txn_curr_index),0) <> NVL(l_plan_txn_post_upg_rc_tbl(l_txn_curr_index),0) THEN

                         l_get_budget_lines_tbl(l_last_bl_index).spr_txn_raw_cost := nvl(l_get_budget_lines_tbl(l_last_bl_index).spr_txn_raw_cost,0) +
                                                                                     NVL(l_plan_txn_act_rc_tbl(l_txn_curr_index),0) -
                                                                                     NVL(l_plan_txn_post_upg_rc_tbl(l_txn_curr_index),0);

                     END IF;

                     IF NVL(l_plan_txn_act_bc_tbl(l_txn_curr_index),0) <> NVL(l_plan_txn_post_upg_bc_tbl(l_txn_curr_index),0) THEN

                         l_get_budget_lines_tbl(l_last_bl_index).spr_txn_burdened_cost := nvl(l_get_budget_lines_tbl(l_last_bl_index).spr_txn_burdened_cost,0) +
                                                                                          NVL(l_plan_txn_act_bc_tbl(l_txn_curr_index),0) -
                                                                                          NVL(l_plan_txn_post_upg_bc_tbl(l_txn_curr_index),0);

                     END IF;

                     IF NVL(l_plan_txn_act_rev_tbl(l_txn_curr_index),0) <> NVL(l_plan_txn_post_upg_rev_tbl(l_txn_curr_index),0) THEN

                         l_get_budget_lines_tbl(l_last_bl_index).spr_txn_revenue := nvl(l_get_budget_lines_tbl(l_last_bl_index).spr_txn_revenue,0) +
                                                                                    NVL(l_plan_txn_act_rev_tbl(l_txn_curr_index),0) -
                                                                                    NVL(l_plan_txn_post_upg_rev_tbl(l_txn_curr_index),0);

                     END IF;

                 END LOOP;


                 -- Loop to traverse through the array or records.
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Deleting from pa_budget_lines table';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                 end if;
                 for i in l_get_budget_lines_tbl.first .. l_get_budget_lines_tbl.last
                 loop
                    delete pa_budget_lines
                    where resource_assignment_id = l_get_res_assign_id_csr.resource_assignment_id   and
                    budget_version_id = l_get_elig_bud_ver_csr.budget_version_id                    and
                    txn_currency_code = l_get_budget_lines_tbl(i).txn_currency_code;
                 end loop;
                 -- Loop to traverse through the array or records ends here.

                 -- Loop to traverse through the array or records for insertion.
                 for i in l_get_budget_lines_tbl.first .. l_get_budget_lines_tbl.last
                 loop

                 insert into pa_budget_lines(
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 start_date,
                 end_date,
                 resource_assignment_id,
                 txn_currency_code,
                 quantity,
                 raw_cost,
                 burdened_cost,
                 revenue,
                 project_raw_cost,
                 project_burdened_cost,
                 project_revenue,
                 txn_raw_cost,
                 txn_burdened_cost,
                 txn_revenue,
                 budget_line_id,
                 budget_version_id,
                 PERIOD_NAME,           /* bug 3673111 */
                 --Bug 4046524.Columns included for this bug start here
                 project_currency_code,
                 projfunc_currency_code,
                 projfunc_cost_rate_type ,
                 projfunc_cost_exchange_rate,
                 projfunc_cost_rate_date_type,
                 projfunc_cost_rate_date,
                 projfunc_rev_rate_type,
                 projfunc_rev_exchange_rate,
                 projfunc_rev_rate_date_type,
                 projfunc_rev_rate_date,
                 project_cost_rate_type ,
                 project_cost_exchange_rate ,
                 project_cost_rate_date_type  ,
                 project_cost_rate_date,
                 project_rev_rate_type,
                 project_rev_exchange_rate,
                 project_rev_rate_date_type,
                 project_rev_rate_date
                 --Bug 4046524.Columns included for this bug end here
                 )
                 select
                 sysdate,
                 -1,
                 sysdate,
                 -1,
                 -1,
                 l_get_budget_lines_tbl(i).gl_start_date,
                 l_get_budget_lines_tbl(i).gl_end_date,
                 l_get_budget_lines_tbl(i).resource_assignment_id,   /* bug 3673111 */
                 l_get_budget_lines_tbl(i).txn_currency_code,
                 l_get_budget_lines_tbl(i).spr_quantity,
                 l_get_budget_lines_tbl(i).spr_raw_cost,
                 l_get_budget_lines_tbl(i).spr_burdened_cost,
                 l_get_budget_lines_tbl(i).spr_revenue,
                 l_get_budget_lines_tbl(i).spr_project_raw_cost,
                 l_get_budget_lines_tbl(i).spr_project_burdened_cost,
                 l_get_budget_lines_tbl(i).spr_project_revenue,
                 l_get_budget_lines_tbl(i).spr_txn_raw_cost,
                 l_get_budget_lines_tbl(i).spr_txn_burdened_cost,
                 l_get_budget_lines_tbl(i).spr_txn_revenue,
                 pa_budget_lines_s.nextval,
                 l_get_elig_bud_ver_csr.budget_version_id,
                 l_get_budget_lines_tbl(i).PERIOD_NAME,               /* bug 3673111 */
                 --Bug 4046524.Columns included for this bug start here
                 l_get_elig_bud_ver_csr.project_currency_code,
                 l_get_elig_bud_ver_csr.projfunc_currency_code,
                 'User',                                                      --projfunc_cost_rate_type
                 DECODE(NVL(l_get_budget_lines_tbl(i).spr_txn_raw_cost,0),    --projfunc_cost_exchange_rate
                        0,0,
                        l_get_budget_lines_tbl(i).spr_raw_cost/l_get_budget_lines_tbl(i).spr_txn_raw_cost),
                 NULL,                                                        --projfunc_cost_rate_date_type
                 NULL,                                                        --projfunc_cost_rate_date
                 'User',                                                      --projfunc_rev_rate_type
                 DECODE(NVL(l_get_budget_lines_tbl(i).spr_txn_revenue,0),     --projfunc_rev_exchange_rate
                        0,0,
                        l_get_budget_lines_tbl(i).spr_revenue/l_get_budget_lines_tbl(i).spr_txn_revenue),
                 NULL,                                                        --projfunc_rev_rate_date_type
                 NULL,                                                        --projfunc_rev_rate_date
                 'User',                                                      --project_cost_rate_type
                 DECODE(NVL(l_get_budget_lines_tbl(i).spr_txn_raw_cost,0),    --project_cost_exchange_rate
                        0,0,
                        l_get_budget_lines_tbl(i).spr_project_raw_cost/l_get_budget_lines_tbl(i).spr_txn_raw_cost),
                 NULL,                                                        --project_cost_rate_date_type
                 NULL,                                                        --project_cost_rate_date
                 'User',                                                      --project_rev_rate_type
                 DECODE(NVL(l_get_budget_lines_tbl(i).spr_txn_revenue,0),     --project_rev_exchange_rate
                        0,0,
                        l_get_budget_lines_tbl(i).spr_project_revenue/l_get_budget_lines_tbl(i).spr_txn_revenue),
                 NULL,                                                        --project_rev_rate_date_type
                 NULL                                                         --project_rev_rate_date
                 --Bug 4046524.Columns included for this bug end here
                 from dual;
                 null;

                 end loop;

                 -- Loop to traverse through the array or records for insertion ends.
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Updating pa_budget_lines table';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                 end if;
                update pa_budget_lines
                set
                attribute_category = l_attribute_category ,
                attribute1 = l_attribute1  ,
                attribute2 = l_attribute2 ,
                attribute3 = l_attribute3,
                attribute4 = l_attribute4,
                attribute5 = l_attribute5 ,
                attribute6 = l_attribute6,
                attribute7 = l_attribute7  ,
                attribute8 = l_attribute8 ,
                attribute9 = l_attribute9,
                attribute10 = l_attribute10,
                attribute11 = l_attribute11,
                attribute12 = l_attribute12 ,
                attribute13 = l_attribute13,
                attribute14 = l_attribute14  ,
                attribute15 = l_attribute15
                where start_date = l_min_date
                and resource_assignment_id = l_get_res_assign_id_csr.resource_assignment_id;

           End If; --   IF (l_get_budget_lines_tbl.count > 0)

          end loop;
          -- Loop for Resource Assignment Id for given Budget Version Ends here.
        end if;


      END LOOP; -- Budget Version cursor

-- Bug 3673111, 07-JUN-04, jwhite ---------------------------------
-- Place GOTO LABEL here SKIP Invalid Budget Version


       <<skip_version>>
                NULL ;


end loop;

    EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc then
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
            x_msg_data := l_msg_data;
        END IF;

        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        END IF;
        x_return_status:= FND_API.G_RET_STS_ERROR;
        pa_debug.reset_err_stack;
        -- ROLLBACK;  /* Commented-out to maintain the savepoint for the concurrent program. */
        RAISE;

      WHEN OTHERS THEN
        if (get_elig_bud_ver_csr%ISOPEN) then
            close get_elig_bud_ver_csr;
        end if;

        if (chk_plan_ver_csr%ISOPEN) then
            close chk_plan_ver_csr;
        end if;

        if (chk_ra_exists_csr%ISOPEN) then
           close chk_ra_exists_csr;
        end if;

        if (chk_ra_for_bl_exists_csr%ISOPEN) then
           close chk_ra_for_bl_exists_csr;
        end if;

        if (get_per_type_csr%ISOPEN) then
           close get_per_type_csr;
        end if;

        if (chk_pa_gl_per_exists_csr%ISOPEN) then
            close chk_pa_gl_per_exists_csr;
         end if;

         if (get_non_time_multi_csr%ISOPEN) then
             close get_non_time_multi_csr;
         end if;

         if (get_res_assign_id_csr%ISOPEN) then
             close get_res_assign_id_csr;
         end if;

	 if (ftch_period_details_csr%ISOPEN) then
	     close ftch_period_details_csr;
	 end if;

         if (get_budget_lines_csr%ISOPEN) then
             close get_budget_lines_csr;
         end if;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_DATE_RANGE_PKG',p_procedure_name  => 'DATE_RANGE_UPGRD');
        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        END IF;

        pa_debug.write_file('DATE_RANGE_UPGRD: Upgrade has failed for the budget version '||l_budget_version_id,5);
        pa_debug.write_file('DATE_RANGE_UPGRD: Failure Reason:'||pa_debug.G_Err_Stack,5);
        pa_debug.reset_err_stack;
        --ROLLBACK; /* Commented-out to maintain the savepoint for the concurrent program. */
        RAISE;
end DATE_RANGE_UPGRD;

--Bug 4046492. This API returns the Time Phase into which a budget version should be upgraded. The values
--that can be returned are
--'P' if the budget version has to upgraded to PA Time Phase
--'G' if the budget version has to upgraded to GL Time Phase
--'N' if the budget version has to upgraded to None Time Phase
--This function will be called from the upgrade script paupg102.sql and PADTRNGB.DATE_RANGE_UPGRD.No validations are done
--in this API and the calling APIs should take care of passing correct values.
FUNCTION get_time_phase_mode
(p_budget_version_id  IN pa_budget_versions.budget_version_id%TYPE
,p_pa_period_type     IN pa_implementations_all.pa_period_type%TYPE
,p_gl_period_type     IN gl_sets_of_books.accounted_period_type%TYPE
,p_org_id             IN pa_projects_all.org_id%TYPE) RETURN VARCHAR2
IS
--Bug 4174789. In the expression to derive factor, replaced the division with substraction to nullify
--errors because of infinite digits after decimal point
CURSOR c_derive_time_phase_csr(c_period_type   gl_periods.period_type%TYPE)
IS
SELECT 1
FROM dual
WHERE EXISTS
    (SELECT 1
     FROM   (SELECT  to_number(NVL(SUM(
                     (decode(least(bl.start_date, gl.start_date),
                             bl.start_date,decode(least(bl.end_date,gl.end_date),
                                                  gl.end_date,gl.end_date-gl.start_date+1,
                                                  bl.end_date,bl.end_date-gl.start_date+1),
                             gl.start_date,decode(least(bl.end_date,gl.end_date),
                                                  gl.end_date,gl.end_date-bl.start_date+1,
                                                  bl.end_date,bl.end_date-bl.start_date+1))
                     )),0)-(bl.end_date-bl.start_date+1)) factor
                     FROM pa_budget_lines bl,
                         (SELECT gl.start_date start_date,
                                 gl.end_date end_date,
                                 gl.period_name period_name
                          FROM   gl_periods gl, pa_implementations_all pi, gl_sets_of_books sob
                          WHERE  gl.period_type=c_period_type
                          AND    sob.set_of_books_id=pi.set_of_books_id
                          AND    nvl(pi.org_id,-99)=nvl(p_org_id,-99)
                          AND    gl.adjustment_period_flag='N'
                          AND    gl.period_set_name=sob.period_set_name
                          UNION ALL
                          SELECT to_date(NULL) start_date,
                                 to_date(NULL) end_date,
                                 to_char(NULL) period_name
                          FROM   dual) gl
                     WHERE bl.budget_version_id = p_budget_version_id
                     AND( (bl.start_date BETWEEN gl.start_date AND gl.end_date
                     OR bl.end_date BETWEEN gl.start_date AND gl.end_date
                     OR (gl.start_date > bl.start_date AND gl.end_date < bl.end_date))
                     OR gl.start_date IS NULL)
                     GROUP BY bl.budget_line_id,bl.start_date,bl.end_date) pbl
    WHERE pbl.factor<>0);

    l_exists         NUMBER;

BEGIN

    OPEN c_derive_time_phase_csr(p_pa_period_type);
    FETCH c_derive_time_phase_csr INTO l_exists;
    CLOSE c_derive_time_phase_csr;

    IF l_exists IS NULL THEN

       --PA periods are defined in the system. The budget version can be upgraded succesfully to PA
       RETURN 'P';

    END IF;

    IF l_exists =1 THEN

        l_exists:=NULL;
        OPEN c_derive_time_phase_csr(p_gl_period_type);
        FETCH c_derive_time_phase_csr INTO l_exists;
        CLOSE c_derive_time_phase_csr;

    END IF;

    IF l_exists IS NULL THEN

       --GL periods are defined in the system. The budget version can be upgraded succesfully to GL
       RETURN 'G';

    ELSE

       --GL/PA period setup would not help in the correct upgrade of the budget version. Hence it has
       --to be upgraded to None Time Phase.
       RETURN 'N';

    END IF;

END get_time_phase_mode;

end PA_DATE_RANGE_PKG;

/
