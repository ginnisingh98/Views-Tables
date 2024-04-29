--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_CORE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_CORE1" as
-- $Header: PAXPCO1B.pls 120.13.12010000.8 2009/07/16 22:44:50 snizam ship $

g_module_name   VARCHAR2(100) := 'PA_PROJECT_CORE1';
Invalid_Arg_Exc EXCEPTION;

--
--  PROCEDURE
--              get_project_number_by_numcode
--  PURPOSE
--              This procedure retrieves project number for a specified
--              project id according to the implementation-defined Project
--              number generation mode.  If mode is 'MANUAL', the
--      user-provided project number is used and stored in
--      x_resu_proj_num (note this is non-NULL);
--      otherwise, a system generated number will be used.
--
procedure get_project_number_by_numcode ( x_orig_proj_num     IN varchar2
                            , x_resu_proj_num     IN OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
                            , x_proj_number_gen_mode OUT NOCOPY varchar2 -- Added for Bug# 7445534
                            , x_err_code          IN OUT NOCOPY number --File.Sql.39 bug 4440895
                            , x_err_stage         IN OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
                            , x_err_stack         IN OUT NOCOPY varchar2) --File.Sql.39 bug 4440895
is
   old_stack varchar2(630);
   proj_number_gen_mode varchar2(30);
   proj_number_type     varchar2(30);
   l_proj_num_numeric   NUMBER;
   unique_id number;
   status number;



begin
   x_err_code := 0;
   old_stack := x_err_stack;
   x_err_stack := x_err_stack || '->get_project_number';

   x_resu_proj_num := NULL;

   x_err_stage := 'Generating project number...';

   -- Generate Project Number according to the implementation-defined Project
   -- number generation mode
   proj_number_gen_mode := PA_PROJECT_UTILS.GetProjNumMode;
   x_proj_number_gen_mode := proj_number_gen_mode; -- Added for Bug# 7445534

   if proj_number_gen_mode = 'MANUAL' then
    proj_number_type := PA_PROJECT_UTILS.GetProjNumType;
    begin
       if proj_number_type = 'NUMERIC' then
          l_proj_num_numeric := TO_NUMBER(x_orig_proj_num);
       end if;
    exception when value_error then
      x_err_code := 40;
      x_err_stage := 'PA_PR_NUMERIC_NUM_REG';
      return;
    end;
   end if;

   if proj_number_gen_mode is NULL then
      x_err_code := 10;
      x_err_stage := 'PA_NO_GEN_MODE';
      return;
   elsif proj_number_gen_mode = 'AUTOMATIC' then
      PA_UTILS_SQNUM_PKG.get_unique_proj_num('PA_PROJECTS',
                         FND_GLOBAL.USER_ID,
                         unique_id,
                         status);
      if status = 0 then
         x_resu_proj_num := to_char(unique_id);
      else
         x_err_code := 20;
         x_err_stage := 'PA_NO_UNIQUE_ID';
         return;
      end if;
   elsif x_orig_proj_num is NULL then
      x_err_code := 30;
      x_err_stage := 'PA_NO_ORIG_PROJNUM';
      return;
   else
      x_resu_proj_num := x_orig_proj_num;
   end if; -- Proj_Number_Gen_Mode

   x_err_stack := old_stack;

exception
   when others then
      x_err_code := SQLCODE;
      x_err_stage := 'PA_SQL_ERROR';
end get_project_number_by_numcode;

--
-- FUNCTION
--
--          Get_Message_from_stack
--          This function returns message from the stack and if does not
--          find one then returns whatever message passed to it.
-- HISTORY
--     12-DEC-01      MAansari    -Created

FUNCTION Get_Message_from_stack( p_err_stage IN VARCHAR2 ) RETURN VARCHAR2 IS
   x_msg_count  NUMBER;
   l_msg_count  NUMBER;
   l_msg_data   VARCHAR2(2000);
   l_data       VARCHAR2(2000);
   l_msg_index_out NUMBER;
   l_app_name   VARCHAR2(2000) := 'PA';
   l_temp_name  VARCHAR2(2000);
BEGIN
      x_msg_count := FND_MSG_PUB.count_msg;

      FND_MSG_PUB.get (
      p_msg_index      => 1,
      p_encoded        => FND_API.G_TRUE,
      p_data           => l_data,
      p_msg_index_out  => l_msg_index_out );

     if l_data is not null then
        FND_MESSAGE.PARSE_ENCODED(ENCODED_MESSAGE => l_data,
                                  APP_SHORT_NAME  => l_app_name,
                                  MESSAGE_NAME    => l_msg_data);

        FND_MSG_PUB.DELETE_MSG(p_msg_index => 1);
     else
        l_msg_data := p_err_stage;
     end if;

     return l_msg_data;

END Get_Message_from_stack;

-- Added for Bug# 7445534
PROCEDURE revert_proj_number(p_proj_number_gen_mode IN VARCHAR2,
                             p_project_number       IN VARCHAR2 ) IS
BEGIN
  IF p_proj_number_gen_mode = 'AUTOMATIC' THEN
    PA_UTILS_SQNUM_PKG.revert_unique_proj_num(p_table_name    => 'PA_PROJECTS',
                                              p_user_id       => FND_GLOBAL.USER_ID,
                                              p_unique_number => TO_NUMBER(p_project_number));
  END IF;
END revert_proj_number;

--
--  PROCEDURE
--              copy_project
--  PURPOSE
--
--              The objective of this procedure is to create a new
--              project and other project related information such
--              as wbs, project players, budget information, billing,
--              and costing information by copying from a specific project
--              and its related information.
--
--              Users can choose whether to copy budget, tasks, and task
--      related information by passing in 'Y' or 'N' for the
--      x_copy_task_flag and x_copy_budget_flag parameters.
--      Users can also choose whether to use copy override
--      associated with the original project by passing in
--      'Y' or 'N' for x_use_override_flag.  If 'Y' is passed
--      for x_use_override_flag, then project players with
--      project roles that are overrideable, project classes
--      with categories that are overrideable, and customers
--      with relationship role type that are overrideable will
--      not get copied from the original project to the new
--      project.  The overrideable information can be entered
--      via the Enter Project form in this case.
--
--      If no value is provided for any of these flag, the
--      default is 'Y'.
--
--              User can pass 'Y' or 'N' for x_template_flag to indicate
--              whether the resulting record is a template or not.  If
--              no value is passed, the default is 'N'.
--
-- HISTORY
--    Ri Singh 03/01/99 : added call to pa_budget_utils2.submit_budget to
--                        change status to submitted before baselining
--    tsaifee 01/24/97 -
--        The number returned by the get_project_number... proc is then
--        checked for being unique.
--
--  31-DEC-97   jwhite  - For the call to Check_Wf_Enabled,
--                 if x_err_code > 0, then assign
--                 zero to x_err_code.
-- 17-JUL-2000 Mohnish
--             added code for ROLE BASED SECURITY:
--             added the call to PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY
--  19-JUL-2000 Mohnish incorporated PA_PROJECT_PARTIES_PUB API changes
--  15-AUG-2000 Sakthi Modified 'PROJECTS' TO 'PA_PROJECTS' in PA_PROJECT_PARTIES_PUB API changes
--
--  24-Sep-02 msundare Added additional parameter x_security_level
--   18-DEC-02  gjain       For bug 2588244 Added logic in copy_project to copy the
--                          default calendar from the organization specified in quick entry
--
--   11-Feb-03 sacgupta    Bug2787577.
--                         Modified the call to  pa_accum_proj_list.Insert_Accum API.
--                         Now this API will be called for Projects only and not for
--                         Project Templates.
--
--  23-APR-09 jsundara     Bug8297384
--                         Added a parameter project currency code to the procedure
--                         copy_project

procedure copy_project (
           x_orig_project_id        IN   number
         , x_project_name           IN   varchar2
         , x_long_name              IN   VARCHAR2 default null
         , x_project_number         IN   varchar2
         , x_description            IN   varchar2
         , x_project_type           IN   varchar2
         , x_project_status_code    IN   varchar2
         , x_distribution_rule      IN   varchar2
         , x_public_sector_flag     IN   varchar2
         , x_organization_id        IN   number
         , x_start_date             IN   date
         , x_completion_date        IN   date
         , x_probability_member_id  IN   number
         , x_project_value          IN   number
         , x_expected_approval_date IN   date
--MCA Sakthi for MultiAgreementCurreny Project
         , x_agreement_currency     IN   VARCHAR2
         , x_agreement_amount       IN   NUMBER
         , x_agreement_org_id       IN   NUMBER
--MCA Sakthi for MultiAgreementCurreny Project
         , x_copy_task_flag         IN   varchar2
         , x_copy_budget_flag       IN   varchar2
         , x_use_override_flag      IN   varchar2
         , x_copy_assignment_flag   IN   varchar2 default 'N'
         , x_template_flag          IN   varchar2
         , x_project_id            OUT   NOCOPY number --File.Sql.39 bug 4440895
         , x_err_code           IN OUT   NOCOPY number --File.Sql.39 bug 4440895
         , x_err_stage          IN OUT   NOCOPY varchar2 --File.Sql.39 bug 4440895
         , x_err_stack          IN OUT   NOCOPY varchar2 --File.Sql.39 bug 4440895
         , x_customer_id            IN   number default NULL
         , x_new_project_number IN OUT   NOCOPY varchar2 --File.Sql.39 bug 4440895
         , x_pm_product_code        IN   varchar2 default NULL
         , x_pm_project_reference   IN   varchar2 default NULL
         , x_project_currency_code  IN     varchar2 default NULL /* 8297384 */
         , x_attribute_category     IN   varchar2 default NULL
         , x_attribute1             IN   varchar2 default NULL
         , x_attribute2             IN   varchar2 default NULL
         , x_attribute3             IN   varchar2 default NULL
         , x_attribute4             IN   varchar2 default NULL
         , x_attribute5             IN   varchar2 default NULL
         , x_attribute6             IN   varchar2 default NULL
         , x_attribute7             IN   varchar2 default NULL
         , x_attribute8             IN   varchar2 default NULL
         , x_attribute9             IN   varchar2 default NULL
         , x_attribute10            IN   varchar2 default NULL
         , x_actual_start_date      IN   DATE     default NULL
         , x_actual_finish_date     IN   DATE     default NULL
         , x_early_start_date       IN   DATE     default NULL
         , x_early_finish_date      IN   DATE     default NULL
         , x_late_start_date        IN   DATE     default NULL
         , x_late_finish_date       IN   DATE     default NULL
         , x_scheduled_start_date   IN   DATE     default NULL
         , x_scheduled_finish_date  IN   DATE     default NULL
         , x_team_template_id       IN   NUMBER
         , x_country_code           IN   VARCHAR2
         , x_region                 IN   VARCHAR2
         , x_city                   IN   VARCHAR2
-- for opportunity value changes
-- anlee
         , x_opp_value_currency_code IN  VARCHAR2
--for org forecasting maansari
         , x_org_project_copy_flag  IN   VARCHAR2 default 'N'
         , x_priority_code          IN   VARCHAR2 default null
-- For Project setup changes in FP.K
         , x_security_level         IN NUMBER default 1
         --Bug 3279981 For FP_M
         , p_en_top_task_cust_flag    IN VARCHAR2 default null
         , p_en_top_task_inv_mth_flag IN VARCHAR2 default null
         --Bug 3279981 For FP_M
	 --sunkalya:federal Bug#5511353
         , p_date_eff_funds_flag      IN VARCHAR2 default null
	 --sunkalya:federal Bug#5511353
         , p_ar_rec_notify_flag       IN VARCHAR2 default 'N'         -- 7508661 : EnC
         , p_auto_release_pwp_inv     IN VARCHAR2 default 'Y'         -- 7508661 : EnC
)
is
status_code     number;
x_new_project_id    number;
x_orig_start_date   date;
x_orig_template_flag    varchar2(2);
x_delta         number default NULL;
x_created_from_proj_id  Number ;
x_temp_project_id  Number ;
old_stack       varchar2(630);
x_res_list_assgmt_id    Number ;
p_project_status_code   varchar2(30);
p_closed_date           date;
l_project_type          VARCHAR2(30);
l_organization_id       NUMBER;
l_item_type             VARCHAR2(30);
l_wf_process            VARCHAR2(30);
l_wf_item_type          VARCHAR2(30);
l_wf_type               VARCHAR2(30);
l_wf_party_process      VARCHAR2(30);
l_wf_enabled_flag       VARCHAR2(1);
l_assignment_id         NUMBER;
l_err_code      NUMBER  := 0;
l_team_template_id      PA_TEAM_TEMPLATES.TEAM_TEMPLATE_ID%TYPE;
l_location_id           PA_LOCATIONS.LOCATION_ID%TYPE;
l_start_date            DATE;
l_return_status         VARCHAR2(1);
l_msg_data              VARCHAR2(2000);
l_msg_count             NUMBER;
l_rowid                 VARCHAR2(250);
l_baseline_funding_flag VARCHAR2(1);
l_long_name             VARCHAR2(255);            --long name changes
new_prj_end_date        DATE; -- Bug 7482391

     l_city               VARCHAR2(80);
   /*l_region              varchar2(240);
      UTF8 changes made for commented code and changed from varchar2 to
       hr_locations_all.region_1%type*/
     l_region             HR_LOCATIONS_ALL.REGION_1%TYPE;
     l_country_code       VARCHAR2(2);
     x_error_message_code VARCHAR2(240);
     l_country_name   VARCHAR2(2000);

--Project Structure Changes
    l_split_costing  VARCHAR2(1);
    l_split_billing  VARCHAR2(1);

l_org_func_security  VARCHAR2(1);  /* bug#1968394  */

l_warnings_only_flag VARCHAR2(1) := 'N'; --bug3134205

CURSOR l_get_details_for_wf_csr (l_project_id IN NUMBER ) IS
SELECT project_type,
       project_status_code
FROM pa_projects
WHERE project_id = l_project_id;

-- for opportunity value changes
-- anlee
l_expected_approval_date  DATE;
l_projfunc_currency_code  VARCHAR2(15);
l_project_currency_code   VARCHAR2(15);
l_opportunity_value       NUMBER;
l_opp_value_currency_code VARCHAR2(15);
l_cal_id          NUMBER default null; /* added for bug 2588244 */
l_flag            VARCHAR2(1) default null; /* added for bug 2588244 */

CURSOR l_get_details_for_opp_csr (c_project_id IN NUMBER) IS
SELECT expected_approval_date, projfunc_currency_code, project_currency_code
       ,target_start_date, target_finish_date, calendar_id    --bug 2805602
FROM   pa_projects
WHERE  project_id = c_project_id;

l_target_start_date  DATE;    --added for bug 2805602
l_target_finish_date DATE;    --added for bug 2805602


CURSOR l_get_details_for_opp_csr2 (c_project_id IN NUMBER) IS
SELECT opportunity_value, opp_value_currency_code
FROM   pa_project_opp_attrs
WHERE  project_id = c_project_id;

l_errorcode NUMBER;

-- Bug 7482391
cursor new_prj_end_date_csr(c_project_id IN NUMBER) IS
SELECT COMPLETION_DATE
FROM PA_PROJECTS_ALL
WHERE project_id=c_project_id;

-- anlee
/*
-- workplan attr changes
-- anlee
l_approval_reqd_flag   VARCHAR2(1);
l_auto_publish_flag    VARCHAR2(1);
l_approver_source_id   NUMBER;
l_approver_source_type NUMBER;
l_default_outline_lvl  NUMBER;

CURSOR l_get_workplan_attrs_csr(c_project_id IN NUMBER) IS
SELECT wp_approval_reqd_flag, wp_auto_publish_flag, wp_approver_source_id, wp_approver_source_type, wp_default_display_lvl
FROM pa_proj_workplan_attr
WHERE project_id = c_project_id;
*/

/* below cursor added for bug 2588244 */
-- Change for R12 Org Info Type changes
CURSOR l_get_default_calendar(p_org_id IN NUMBER) IS
select org_information1 --org_information2
  from hr_organization_information
 --where org_information_context = 'Exp Organization Defaults'
 where org_information_context = 'Resource Defaults'
   and organization_id = p_org_id;

--Following code added for selective copy project options. Tracking bug No 3464332
CURSOR cur_get_flag( p_flag_name IN VARCHAR2 ) IS
SELECT FLAG
FROM   PA_PROJECT_COPY_OPTIONS_TMP
WHERE  CONTEXT = p_flag_name ;

l_pr_team_members_flag     VARCHAR2(1);
l_pr_attachments_flag      VARCHAR2(1);
l_pr_frm_src_tmpl_flag     VARCHAR2(1);
l_pr_item_assoc_flag       VARCHAR2(1);
l_pr_dff_flag              VARCHAR2(1);
l_pr_user_defn_att_flag    VARCHAR2(1);

l_fin_txn_control_flag      VARCHAR2(1);
l_fn_cb_overrides_flag      VARCHAR2(1);
l_fn_assets_flag            VARCHAR2(1);
l_fn_asset_assignments_flag VARCHAR2(1);
l_is_fin_str_copied         VARCHAR2(1) := 'N'; -- Bug 4188514
----End selective copy project options. Tracking bug No 3464332
--Bug 3279981 FP_M Project Setup development
CURSOR cur_get_orig_bill_info IS
SELECT enable_top_task_inv_mth_flag, revenue_accrual_method, invoice_method
FROM   pa_projects_all
WHERE  project_id = x_orig_project_id;

-- 4055319 Added below cursor to retrieve source's funding approval status code

CURSOR cur_proj_fund_status IS
select
      ppa.funding_approval_status_code,
      pps.project_system_status_code
from
      pa_projects_all ppa,
      pa_project_statuses pps
where
      ppa.project_id = x_orig_project_id
  and ppa.funding_approval_status_code = pps.project_status_code;

-- added below local variables

l_fund_status               VARCHAR2(30);
l_org_fund_status           VARCHAR2(30);
l_org_fund_sys_status       VARCHAR2(30);

-- 4055319 end

l_hghst_ctr_cust_id        NUMBER := NULL;
l_orig_en_top_task_inv_mth VARCHAR2(1);
l_orig_en_top_task_cust    VARCHAR2(1);
l_orig_rev_acc_mth         VARCHAR2(30);
l_orig_inv_mth             VARCHAR2(30);
l_new_distribution_rule    VARCHAR2(30);
--Bug 3279981 FP_M Project Setup development
l_dup_name_flag VARCHAR2(1); --Bug 2450064

l_baseline_exists_in_src   VARCHAR2(1); --Bug 5378256/5137355
l_orig_date_eff_funds_flag VARCHAR2(1);			--sunkalya:federal. Bug#5511353
l_check_diff_flag          VARCHAR2(1) :=	NULL;	--sunkalya:federal  Bug#5511353

--bug#5859329
l_tmp_end_date_active	 DATE;
--bug#5859329

-- Bug 7482391
l_tmp_start_date_active  DATE;

-- Added for Bug# 7445534
x_proj_number_gen_mode VARCHAR2(30);

begin
        savepoint copy_project;
        x_err_code := 0;
        old_stack := x_err_stack;

        x_err_stack := x_err_stack || '->copy_project';

        -- Check original project id
        if (x_orig_project_id is null ) then
                x_err_code := 10;
                x_err_stage := 'PA_NO_ORIG_PROJ_ID';
                return;
        end if ;

        -- Check project name
        if (x_project_name is null ) then
                x_err_code := 20;
                x_err_stage := 'PA_PR_NO_PROJ_NAME';
                return;
        end if ;


    -- If the site implementation of USER_DEFINED_PROJECT_NUM_CODE
    -- is AUTOMATIC, store system generated number in SEGMENT1;

--EH Changes
    BEGIN
      if (x_template_flag = 'N') then
        get_project_number_by_numcode (x_project_number,
                       x_new_project_number,
                       x_proj_number_gen_mode, -- Added for Bug# 7445534
                       x_err_code,
                       x_err_stage,
                       x_err_stack);
      else
        x_new_project_number := x_project_number;
      end if;

        if x_err_code <> 0 then
           x_err_code := 765;
           IF x_err_stage IS NULL
           THEN
               x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_PRJ_COR1_GET_PRJ_NUM');
           END IF;
           x_err_stack := x_err_stack||'->pa_project_core1.get_project_number_by_numcode';
           rollback to copy_project;
           revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
       return;
        end if;
    EXCEPTION WHEN OTHERS THEN
        x_err_code := 765;
--        x_err_stage := pa_project_core1.get_message_from_stack( null );
--        IF x_err_stage IS NULL
--        THEN
           x_err_stage := 'API: '||'pa_project_core1.get_project_number_by_numcode'||
                            ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--        END IF;
        rollback to copy_project;
        revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
        return;
    END;

        -- Check project number
        -- Either x_project_number or x_new_project_number should have
        -- a valid value depending on whether the site implementatation
        -- for USER_DEFINED_PROJECT_NUM_CODE is AUTOMATIC or MANUAL
        if (x_project_number is null and x_new_project_number is null) then
                x_err_code := 30;
                x_err_stage := 'PA_PR_NO_PROJ_NUM';
                return;
        end if ;

    -- Check project start and completion date
    -- If start date is not null, then completion can be null or not null
    -- If completion date is not null, then start date must be provided.

    if (x_completion_date is not null and x_start_date is null) then
        x_err_code := 40;
        x_err_stage := 'PA_PR_START_DATE_NEEDED';
        return;
    end if;

        -- Uniqueness check for project name
        x_err_stage := 'check uniqueness for project name '|| x_project_name;
        status_code :=
             pa_project_utils.check_unique_project_name(x_project_name,
                                                       null);
        if ( status_code = 0 ) then
            x_err_code := 50;
            x_err_stage := 'PA_PR_EPR_PROJ_NAME_NOT_UNIQUE';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
       /*Added for bug 2450064*/
        elsif ( status_code = 1 ) then
      pjm_seiban_pkg.project_name_dup(x_project_name,l_dup_name_flag);
        if l_dup_name_flag = 'Y' then
        x_err_code := 61;
            x_err_stage := 'PA_SEIBAN_NAME_NOT_UNIQUE';
        return;
        end if;
         /*Added till here for bug 2450064*/
        end if;

/* Bug#2638968: Commented this as this check is already taken care in pa_project_pub.create-project API.
   This check was causing uniqueness problem in project connect as the MISS CHAR is not taken care. */
        -- Uniqueness check for long_name name Bug#2638968
  /*Uncommented the below code for bug 3268727 since unique long name is not taken care
    in Self Service as it is taken care in forms*/
      if (x_long_name is NOT NULL and x_long_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) then
        x_err_stage := 'check uniqueness for long name '|| x_long_name;
        status_code :=
             pa_project_utils.check_unique_long_name(x_long_name,
                                                     null);
        if ( status_code = 0 ) then
            x_err_code := 50;
            x_err_stage := 'PA_PR_EPR_LONG_NAME_NOT_UNIQUE';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;
      end if;

/*Adding the below code for bug 3268727.When the long name is null, we
copy the x_project_name into long_name.Hence, when the x_long_name is null, then we check uniqueness for
long_name with the parameter of x_long_name*/

   if (x_long_name is NULL or x_long_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) then
     x_err_stage := 'check uniqueness for long name '|| x_project_name;
        status_code :=
             pa_project_utils.check_unique_long_name(x_project_name,
                                                     null);
        if ( status_code = 0 ) then
            x_err_code := 50;
            x_err_stage := 'PA_PR_EPR_LONG_NAME_NOT_UNIQUE';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
        end if;
      end if;
/*End of code addition for the bug 3268727*/

        -- Uniqueness check for project number
        -- tsaifee 01/24/97- x_new_project_number used instead of
        -- x_project_number
        x_err_stage := 'check uniqueness for project number '||
            x_new_project_number;
        status_code :=
             pa_project_utils.check_unique_project_number(x_new_project_number,
                                                       null);
        if ( status_code = 0 ) then
            x_err_code := 60;
            x_err_stage := 'PA_PR_EPR_PROJ_NUM_NOT_UNIQUE';
            return;
        elsif ( status_code < 0 ) then
            x_err_code := status_code;
            return;
       /*Added for bug 2450064*/
        elsif ( status_code = 1 ) then
        pjm_seiban_pkg.project_number_dup(x_new_project_number,l_dup_name_flag);
        if l_dup_name_flag = 'Y' then
          x_err_code := 61;
              x_err_stage := 'PA_SEIBAN_NUM_NOT_UNIQUE';
        return;
        end if;
        /*Added till here for bug 2450064*/
        end if;


        -- verify date range
        if (x_start_date is not null  AND  x_completion_date is not null
                AND x_start_date > x_completion_date ) then
                -- invaid date range
                x_err_code := 80;
                x_err_stage := 'PA_SU_INVALID_DATES';
                                -- existing message name from PAXTKETK
                return;
    end if;

    -- get original project start and completion dates
    -- determine the shift days (delta).
    -- delta = new project start date - nvl(old project start date,
    --          earlist task start date)

   --        old project   new project
   --  case  start date    start date    new start date     new end date
   --  ----   -----------   -----------  -----------------  -----------------
   --   A     not null      not null     old start date     old end date
   --                        + delta        + delta
   --   B-1   null      not null     old start date     old end date
   --       (old task has start date)    + delta        + delta
   --   B-2   null      not null     new proj start     new proj completion
   --       (old task has no start date) date           date
   --   C     not null      null     old start date     old end date
   --   D     null      null     old start date     old end date

    declare
       cursor c1 is
        select start_date,
               template_flag,
             created_from_project_id,
             project_type,
             carrying_out_organization_id,
             initial_team_template_id,
             baseline_funding_flag
        from pa_projects
        where project_id = x_orig_project_id;

                 -- use min(start_date) as pseudo original project start
                 cursor c2 is
                        select min(start_date) min_start
                        from pa_tasks
                        where project_id = x_orig_project_id;

                 c2_rec  c2%rowtype;


    begin
        open c1;
        fetch c1 into
            x_orig_start_date,
            x_orig_template_flag,
                        x_created_from_proj_id,
                        l_project_type,
                        l_organization_id,
                        l_team_template_id,
                        l_baseline_funding_flag;
        close c1;

              -- If x_team_template is null, get from orig template/project
              l_team_template_id := nvl(x_team_template_id, l_team_template_id);
              -- created_from_project_id would be null, only for those
              -- templates which were created afresh through the form
              -- If the source project was a template,then created_from_proj_id
              -- would be the project_id of source project. Hence,in both these
              -- cases,we should populate created_from_project_id with the
              -- project_id of the source project.

                if (x_created_from_proj_id is null or
                    x_orig_template_flag = 'Y' )
                    Then
                   x_created_from_proj_id := x_orig_project_id;
                end if ;
/*
                if (x_created_from_proj_id is null or
                    x_orig_template_flag = 'Y' )
                    Then
                   x_created_from_proj_id := x_orig_project_id;
                   x_temp_project_id := NULL;
                else
                   x_temp_project_id := x_created_from_proj_id;
                end if ;
*/

        if (x_start_date is null) then
            -- case C or D
            x_delta := 0;
        elsif (x_orig_start_date is not null) then
            -- case A
            x_delta := x_start_date - x_orig_start_date;
        else
            -- case B
                        open c2;
                        fetch c2 into c2_rec;
                        if c2%found then
               -- case B-1:  x_delta is difference between
               --            new project start date and the
               --            start date of the earlist task
               --            of old project
               -- case B-2:  x_delta is NULL

                           -- 3874742 reverted back the changes , refer bug update "ADORAIRA  10/26/04 02:47 am"
                           -- 3874742 Added code to check c2_rec.min_start for NULL
                           -- if it is null, set x_delta to 0.
                           -- IF c2_rec.min_start IS NOT NULL THEN
                               x_delta := x_start_date - c2_rec.min_start;
                           -- ELSE
                           --    x_delta := 0;
                           -- END IF;
                        end if;
                        close c2;

        end if;

        -- 3874742 reverted back the changes , refer bug update "ADORAIRA  10/26/04 02:47 am"
        -- 3874742 Added code to check x_delta for NULL value
        -- if it is NULL, set x_delta to 0.

        -- IF x_delta IS NULL THEN
        --    x_delta := 0;
        -- END IF;
        -- 3874742 end

                --Organization Forecasting Changes
--                IF x_orig_template_flag = 'N' and x_template_flag = 'N'
--                THEN
                IF x_org_project_copy_flag  = 'N'
                THEN
                   DECLARE
                      CURSOR cur_pa_proj_type
                       IS
                        SELECT 'X'
                          FROM pa_project_types
                         WHERE project_type = l_project_type
                           AND org_project_flag = 'Y';

                      l_dummy_char VARCHAR2(1);
                   BEGIN
                        OPEN cur_pa_proj_type;
                        FETCH cur_pa_proj_type INTO l_dummy_char;
                        IF cur_pa_proj_type%FOUND
                        THEN
                           CLOSE cur_pa_proj_type;
                           x_err_code := 910;
                           x_err_stage := 'PA_ORG_FC_CANT_CR_PR';
                           return;
                        END IF;
                        CLOSE cur_pa_proj_type;
                   END;
                END IF;
    end;


declare
    cursor p1 is select project_system_status_code
                 from pa_project_statuses ps
                 where project_status_code = x_project_status_code;

    cursor p2 is select ps.project_system_status_code, ps.starting_status_flag, ps.project_status_code
                 from pa_project_statuses ps, pa_projects pp
                 where ps.project_status_code = pp.project_status_code
                 and   pp.project_id = x_orig_project_id;

    cursor p3 is select ps.project_system_status_code, ps.starting_status_flag, ps.project_status_code
                 from pa_project_statuses ps, pa_project_types pt, pa_projects pp
                 where ps.project_status_code = pt.def_start_proj_status_code
                 and   pt.project_type = pp.project_type
                 and   pp.project_id = x_orig_project_id;

    p1_rec  p1%rowtype;
    p2_rec  p2%rowtype;
    p3_rec  p3%rowtype;

begin

   If x_project_status_code is not null then
      p_project_status_code := x_project_status_code;
      open p1;
      fetch p1 into p1_rec;
      close p1;

      /*  If p1_rec.project_system_status_code = 'CLOSED' then  */
      If pa_utils2.IsProjectClosed(p1_rec.project_system_status_code) = 'Y' then
         p_closed_date := sysdate;
      Else
         p_closed_date := null;
      End If;
   Else
      open p2;
      fetch p2 into p2_rec;
      close p2;
      If p2_rec.starting_status_flag = 'Y' then
         p_project_status_code := p2_rec.project_status_code;

         /*  If p2_rec.project_system_status_code = 'CLOSED' then  */
         If pa_utils2.IsProjectClosed(p2_rec.project_system_status_code)= 'Y' then
            p_closed_date := sysdate;
         Else
            p_closed_date := null;
         End If;
      Else
         open p3;
         fetch p3 into p3_rec;
         close p3;
         p_project_status_code := p3_rec.project_status_code;

         /*  If p3_rec.project_system_status_code = 'CLOSED' then   */
         If pa_utils2.IsProjectClosed(p3_rec.project_system_status_code) = 'Y' then
            p_closed_date := sysdate;
         Else
            p_closed_date := null;
         End If;
      End If;

   End If;
end;

-- Check for org validation starts here.

   if x_project_type is not null then
        l_project_type := x_project_type;
   end if;

   if x_organization_id is not null then
      l_organization_id := x_organization_id;
   end if;

   x_err_stage := 'Check valid Organization ... ';

   if pa_project_pvt.check_valid_org(l_organization_id) = 'Y' then

      x_err_stage := 'Validate Attribute Change ... ';

      --  Code Added for the bug#1968394
      -- Test the function security for Org changes
      --
      IF (fnd_function.test('PA_PAXPREPR_UPDATE_ORG') = TRUE) THEN
        l_org_func_security := 'Y';
      ELSE
        l_org_func_security := 'N';
      END IF;

--EH Changes
      BEGIN
         x_err_stage := 'Validate Attribute Change';
         pa_project_utils2.validate_attribute_change
                     (X_Context                  => 'ORGANIZATION_VALIDATION',
                      X_insert_update_mode       => 'INSERT',
                      X_calling_module           => 'PAXPREPR',
                      X_project_id               => NULL,
                      X_task_id                  => NULL,
                      X_old_value                => NULL,
                      X_new_value                => l_organization_id,
                      X_project_type             => l_project_type,
                      X_project_start_date       => x_start_date,
                      X_project_end_date         => x_completion_date,
                      X_public_sector_flag       => x_public_sector_flag,
                      X_task_manager_person_id   => NULL,
                      X_Service_type             => NULL,
                      X_task_start_date          => NULL,
                      X_task_end_date            => NULL,
                      X_entered_by_user_id       => FND_GLOBAL.USER_ID,
                      X_attribute_category       => x_attribute_category,
                      X_attribute1               => x_attribute1,
                      X_attribute2               => x_attribute2,
                      X_attribute3               => x_attribute3,
                      X_attribute4               => x_attribute4,
                      X_attribute5               => x_attribute5,
                      X_attribute6               => x_attribute6,
                      X_attribute7               => x_attribute7,
                      X_attribute8               => x_attribute8,
                      X_attribute9               => x_attribute9,
                      X_attribute10              => x_attribute10,
                      X_pm_product_code          => x_pm_product_code,
                      X_pm_project_reference     => x_pm_project_reference,
                      X_pm_task_reference        => NULL,
--                      X_functional_security_flag => 'N',  /* Bug#1968394  */
                      X_functional_security_flag => l_org_func_security, /* Bug#1968394  */
                     x_warnings_only_flag     => l_warnings_only_flag, --bug3134205
                      X_err_code                 => x_err_code,
                      X_err_stage                => x_err_stage,
                      X_err_stack                => x_err_stack);

             IF l_err_code <>0
             THEN
                  x_err_code := 740;
                  IF x_err_stage IS NULL
                  THEN
                     x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_VAL_ATTR_CHANGE');
                  END IF;
                  x_err_stack := x_err_stack||'->pa_project_utils2.validate_attribute_change';
                  rollback to copy_project;
                  revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                  return;
             END IF;

      EXCEPTION WHEN OTHERS THEN
             x_err_code := 740;
--           x_err_stage := pa_project_core1.get_message_from_stack( null );
--             IF x_err_stage IS NULL
--             THEN
                x_err_stage := 'API: '||'pa_project_utils2.validate_attribute_change'||' SQL error message: '
                                 ||SUBSTR( SQLERRM,1,1900);
--             END IF;
             rollback to copy_project;
             revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
             return;
      END ;
     else
      x_err_code := 440;
      x_err_stage := 'PA_PROJ_ORG_NOT_ACTIVE';
      return;
   end if;

-- Return if err code <>0,since Org validation has failed.
   IF x_err_code <> 0 THEN
      return;
   END IF;

-- Check for org validation ends here.

/* code addition for bug 2588244 starts */
   If x_organization_id is not null then
    l_flag := 'N';
    OPEN l_get_default_calendar(x_organization_id);
    FETCH l_get_default_calendar into l_cal_id;
    CLOSE l_get_default_calendar;
   else
    l_flag := 'Y';
   end if;
/* code addition for bug 2588244 ends */

-- Location validation
   if x_country_code is not null then
--EH changes
    BEGIN
      pa_location_utils.check_location_exists
      ( p_country_code  => x_country_code,
        p_city          => x_city,
        p_region        => x_region,
        x_return_status => l_return_status,
        x_location_id   => l_location_id);
      IF l_return_status <> 'S'
      THEN
          x_err_code := 770;
          x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_CHK_LOC_EXISTS');
          x_err_stack := x_err_stack||'->pa_location_utils.check_location_exists';
          rollback to copy_project;
          revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
          return;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      x_err_code := 770;
--      x_err_stage := pa_project_core1.get_message_from_stack( null );
--      IF x_err_stage IS NULL
--      THEN
         x_err_stage := 'API: '||'pa_location_utils.check_location_exists'||
                          ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--      END IF;
      rollback to copy_project;
      revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
      return;
    END;

      if l_location_id is null then

         pa_locations_pkg.INSERT_ROW
         ( p_CITY              => x_city,
           p_REGION            => x_region,
           p_COUNTRY_CODE      => x_country_code,
           p_CREATION_DATE     => sysdate,
           p_CREATED_BY        => FND_GLOBAL.USER_ID,
           p_LAST_UPDATE_DATE  => sysdate,
           p_LAST_UPDATED_BY   => FND_GLOBAL.USER_ID,
           p_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID,
           X_ROWID             => l_rowid,
           X_LOCATION_ID       => l_location_id);

      end if;

   --Bug#1947235 Updated by MAansari
   elsif x_organization_id IS NOT NULL AND x_country_code IS NULL then

    --Bug#1947235 Updated by MAansari
    -- The following local variables are added
    -- l_city           VARCHAR2(80);
    -- l_region         hr_locations_all.region_1%type;
    -- l_country_code   VARCHAR2(2);
    -- x_error_msg_code VARCHAR2(240);
    -- l_country_name   VARCHAR2(2000);

--EH Changes
   BEGIN
     pa_location_utils.Get_ORG_Location_Details
            (p_organization_id     => x_organization_id,
             x_country_name        => l_country_name,
             x_city                => l_city,
             x_region              => l_region,
             x_country_code        => l_country_code,
             x_return_status       => l_return_status,
             x_error_message_code  => x_error_message_code);
      IF l_return_status <> 'S'
      THEN
          x_err_code := 780;
          IF x_error_message_code IS NULL
          THEN
              x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_GET_ORG_LOC_DTLS');
          ELSE
              x_err_stage := x_error_message_code;   --bug fix 2680591
          END IF;
          x_err_stack := x_err_stack||'->pa_location_utils.Get_ORG_Location_Details';
          rollback to copy_project;
          revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
          return;
      END IF;
   EXCEPTION WHEN OTHERS THEN
      x_err_code := 780;
--      x_err_stage := pa_project_core1.get_message_from_stack( null );
--      IF x_error_message_code IS NULL
--      THEN
         x_err_stage := 'API: '||'pa_location_utils.Get_ORG_Location_Details'||
                          ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--      END IF;
      rollback to copy_project;
      revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
      return;
   END;

--EH Changes
  BEGIN
     pa_location_utils.check_location_exists(
                    p_country_code  => l_country_code,
                    p_city          => l_city,
                    p_region        => l_region,
                    x_return_status => l_return_status,
                    x_location_id   => l_location_id);
      IF l_return_status <> 'S'
      THEN
          x_err_code := 775;
          x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_CHK_LOC_EXISTS');
          x_err_stack := x_err_stack||'->pa_location_utils.check_location_exists';
          rollback to copy_project;
          revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
          return;
      END IF;
  EXCEPTION WHEN OTHERS THEN
      x_err_code := 775;
--      x_err_stage := pa_project_core1.get_message_from_stack( null );
--      IF x_err_stage IS NULL
--      THEN
         x_err_stage := 'API: '||'pa_location_utils.check_location_exists'||
                          ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--      END IF;
      rollback to copy_project;
      revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
      return;
  END;

    If l_location_id is null then
      /* Commented the below line for bug 2688170 */
      /* If l_city is not null and l_region is not null and */
         If  l_country_code is not null then
            pa_locations_pkg.INSERT_ROW(
                 p_CITY              => l_city,
                 p_REGION            => l_region,
                 p_COUNTRY_CODE      => l_country_code,
                 p_CREATION_DATE     => sysdate,
                 p_CREATED_BY        => FND_GLOBAL.USER_ID,
                 p_LAST_UPDATE_DATE  => sysdate,
                 p_LAST_UPDATED_BY   => FND_GLOBAL.USER_ID,
                 p_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID,
                 X_ROWID             => l_rowid,
                 X_LOCATION_ID       => l_location_id);
         end if;
     end if;
    --end Bug#1947235
   end if;

    -- copy project
    declare
        cursor c1 is
              select pa_projects_s.nextval from sys.dual;

                --bug 2434241
                cursor c2 is
                      select retn_accounting_flag from pa_implementations;
                l_retn_accounting_flag    VARCHAR2(1);
                --bug 2434241

                -- Bug 2900258
                Cursor c3 is
                        SELECT 'YES' FROM DUAL
                        WHERE EXISTS ( SELECT 1 FROM FND_DESCRIPTIVE_FLEXS
                                        WHERE APPLICATION_ID=275
                                        AND APPLICATION_TABLE_NAME='PA_PROJECTS_ALL'
                                        AND DESCRIPTIVE_FLEXFIELD_NAME = 'PA_PROJECTS_DESC_FLEX'
                                        AND CONTEXT_COLUMN_NAME = 'ATTRIBUTE_CATEGORY'
                                        AND DEFAULT_CONTEXT_FIELD_NAME = 'TEMPLATE_FLAG' );

                l_is_dff_reference_temp_flag VARCHAR2(3) :='NO'; -- Bug 2900258

    begin
        x_err_stage := 'get project id from sequence';
        open c1;
        fetch c1 into x_new_project_id;
        close c1;

                --bug 2434241
                x_err_stage := 'get retention accounting flag from implementations';
                open c2;
                fetch c2 into l_retn_accounting_flag;
                close c2;
                --bug 2434241

                -- Bug 2900258

                IF x_template_flag = 'N' THEN
                    Open c3;
                    Fetch c3 into l_is_dff_reference_temp_flag;
                    close c3;
                END IF;

            x_err_stage := 'creating project with project id of '||
            x_new_project_id || ' by copying original project '||
            x_orig_project_id;

--Following code added for selective copy project changes. Tracking Bug no. 3464332
        PA_PROJECT_CORE1.populate_default_copy_options( p_src_project_id     => x_orig_project_id
                                                       ,p_src_template_flag  => x_orig_template_flag
                                                       ,p_dest_template_flag => x_template_flag
                                                       ,x_return_status     => l_return_status
                                                       ,x_msg_count         => l_msg_count
                                                       ,x_msg_data          => l_msg_data
                                                      );
        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            ROLLBACK TO copy_project;
            revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
            x_err_code := 199;
            x_err_stage := 'API: '||'PA_PROJECT_CORE1.POPULATE_DEFAULT_COPY_OPTIONS'||
                           ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
            x_err_stack   := x_err_stack||'->PA_PROJECT_CORE1.POPULATE_DEFAULT_COPY_OPTIONS';
            RETURN;
        END IF;
--Following code added for selective copy project changes. Tracking Bug no. 3464332
        OPEN  cur_get_flag('PR_DFF_FLAG');
        FETCH cur_get_flag INTO l_pr_dff_flag;
        CLOSE cur_get_flag;
--Bug 3279981 Review :
--IF the invoice method at top task flag has been changed as compared to original project, accordingly we need
--to remove/populate 'WORK' in the distribution rule's invoice method for the new project
--IF the top task inv method flag has been checked for the new project, we need to populate distr. rule's invoice
--method internally as 'WORK', if the distr. rule has been passed
        OPEN  cur_get_orig_bill_info;
        FETCH cur_get_orig_bill_info INTO l_orig_en_top_task_inv_mth, l_orig_rev_acc_mth, l_orig_inv_mth;
        CLOSE cur_get_orig_bill_info;

        IF    'Y' = l_orig_en_top_task_inv_mth AND 'N' = p_en_top_task_inv_mth_flag AND x_distribution_rule IS NULL THEN
               l_new_distribution_rule := upper(l_orig_rev_acc_mth)||'/'||upper(l_orig_inv_mth);
        ELSIF 'N' = l_orig_en_top_task_inv_mth AND 'Y' = p_en_top_task_inv_mth_flag AND x_distribution_rule IS NULL THEN
               l_new_distribution_rule := upper(l_orig_rev_acc_mth)||'/'||'WORK';
        ELSIF 'Y' = p_en_top_task_inv_mth_flag AND x_distribution_rule IS NOT NULL THEN
               l_new_distribution_rule := substr(x_distribution_rule, 1, instr(x_distribution_rule,'/')-1)||'/'||'WORK';
        ELSE
               l_new_distribution_rule := x_distribution_rule;
        END IF;
--Bug 3279981 Review

        -- 4055319 funding_approval_status changes
        -- If destination type is project ( i.e project is getting created ) from template/project
        -- retrieve source's funding_approval_status_code
        -- if it is mapped to system status FUNDING_PROPOSED , copy source's funding_approval_status_code in the destination
        -- else copy it as null

        -- below code is to derive default value mentioned above
        l_fund_status := NULL;

        IF x_template_flag = 'N' THEN
            OPEN  cur_proj_fund_status;
            FETCH cur_proj_fund_status INTO l_org_fund_status, l_org_fund_sys_status;
            CLOSE cur_proj_fund_status;

            IF l_org_fund_sys_status = 'FUNDING_PROPOSED' THEN
                l_fund_status := l_org_fund_status;
            END IF;
        END IF;

        -- 4055319 end

        insert into pa_projects (
                  project_id,
                  name,
                  long_name,           --long name changes
                  segment1,
                  org_id,   -- Bug 4363092: MOAC Changes
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by,
                  last_update_login,
                  project_type,
                  carrying_out_organization_id,
                  public_sector_flag,
                  project_status_code,
                  description,
                  start_date,
                  completion_date,
                  closed_date,
                  distribution_rule,
                  labor_invoice_format_id,
                  non_labor_invoice_format_id,
                  retention_invoice_format_id,
                  retention_percentage,
                  billing_offset,
                  billing_cycle_id,
                  labor_std_bill_rate_schdl,
                  labor_bill_rate_org_id,
                  labor_schedule_fixed_date,
                  labor_schedule_discount,
                  non_labor_std_bill_rate_schdl,
                  non_labor_bill_rate_org_id,
                  non_labor_schedule_fixed_date,
                  non_labor_schedule_discount,
                  limit_to_txn_controls_flag,
                  project_level_funding_flag,
                  invoice_comment,
                  unbilled_receivable_dr,
                  unearned_revenue_cr,
                  summary_flag,
                  enabled_flag,
                  segment2,
                  segment3,
                  segment4,
                  segment5,
                  segment6,
                  segment7,
                  segment8,
                  segment9,
                  segment10,
                  attribute_category,
                  attribute1,
                  attribute2,
                  attribute3,
                  attribute4,
                  attribute5,
                  attribute6,
                  attribute7,
                  attribute8,
                  attribute9,
                  attribute10,
                  cost_ind_rate_sch_id,
                  rev_ind_rate_sch_id,
                  inv_ind_rate_sch_id,
                  cost_ind_sch_fixed_date,
                  rev_ind_sch_fixed_date,
                  inv_ind_sch_fixed_date,
                  labor_sch_type,
                  non_labor_sch_type,
                  template_flag,
                  verification_date,
                  created_from_project_id,
                  template_start_date_active,
                  template_end_date_active,
                  pm_product_code,
                  pm_project_reference,
                  actual_start_date,
                  actual_finish_date,
                  early_start_date,
                  early_finish_date,
                  late_start_date,
                  late_finish_date,
                  scheduled_start_date,
                  scheduled_finish_date,
                  project_currency_code,
                  allow_cross_charge_flag,
                  project_rate_date,
                  project_rate_type,
                  output_tax_code,
                  retention_tax_code,
                  cc_process_labor_flag,
                  labor_tp_schedule_id,
                  labor_tp_fixed_date,
                  cc_process_nl_flag,
                  nl_tp_schedule_id,
                  nl_tp_fixed_date,
                  cc_tax_task_id,
                  bill_job_group_id,
                  cost_job_group_id,
                  role_list_id,
                  work_type_id,
                  calendar_id,
                  initial_team_template_id,
                  location_id,
                  probability_member_id,
                  project_value,
                  expected_approval_date,
                  job_bill_rate_schedule_id,
                  emp_bill_rate_schedule_id,
--MCA Sakthi for MultiAgreementCurreny Project
                 competence_match_wt,
                 availability_match_wt,
                 job_level_match_wt,
                 enable_automated_search,
                 search_min_availability,
                 search_org_hier_id,
                 search_starting_org_id,
                 search_country_code,
                 min_cand_score_reqd_for_nom,
                 non_lab_std_bill_rt_sch_id,
                 invproc_currency_type,
                 revproc_currency_code,
                 project_bil_rate_date_code,
                 project_bil_rate_type,
                 project_bil_rate_date,
                 project_bil_exchange_rate,
                 projfunc_currency_code,
                 projfunc_bil_rate_date_code,
                 projfunc_bil_rate_type,
                 projfunc_bil_rate_date,
                 projfunc_bil_exchange_rate,
                 funding_rate_date_code,
                 funding_rate_type,
                 funding_rate_date,
                 funding_exchange_rate,
                 baseline_funding_flag,
                 projfunc_cost_rate_type,
                 projfunc_cost_rate_date,
                 multi_currency_billing_flag,
                 inv_by_bill_trans_curr_flag,
--MCA Sakthi for MultiAgreementCurreny Project
--MCA1
                 assign_precedes_task,
--MCA1
--Structure
                 split_cost_from_workplan_flag,
                 split_cost_from_bill_flag,
--Structure
--Advertisement, Project Setup and Retention changes

                 priority_code,
                 retn_billing_inv_format_id,
                 retn_accounting_flag,
                 adv_action_set_id,
                 start_adv_action_set_flag,

--Advertisement, Project Setup and Retention changes

-- anlee
-- Dates changes
                 target_start_date,
                 target_finish_date,
-- End of changes
-- anlee
-- patchset K changes
                 revaluate_funding_flag,
                 include_gains_losses_flag,
-- msundare
                 security_level,
                 labor_disc_reason_code,
                 non_labor_disc_reason_code,
-- End of changes
                 record_version_number,
                 btc_cost_base_rev_code, /* Bug#2638968 */
--PA L bug 2872708
                 asset_allocation_method,
                 capital_event_processing,
                 cint_rate_sch_id,
                 cint_eligible_flag,
--End PA L 2872708
                 structure_sharing_code ,   --FPM bug 3301192
/* Added for FPM development -Project Setup Changes */
                 enable_top_task_customer_flag,
                 enable_top_task_inv_mth_flag,
                 revenue_accrual_method,
                 invoice_method,
                 projfunc_attr_for_ar_flag,
                 sys_program_flag,
                 allow_multi_program_rollup,
                 proj_req_res_format_id,
                 proj_asgmt_res_format_id,
                 funding_approval_status_code,  -- added for 4055319
                 revtrans_currency_type,  -- Added for Bug 4757022

/* Added for FPM development -Project Setup Changes ends*/
		--sunkalya:federal Bug#5511353
		 DATE_EFF_FUNDS_CONSUMPTION
		--sunkalya:federal Bug#5511353
                ,ar_rec_notify_flag     -- 7508661 : EnC
                ,auto_release_pwp_inv   -- 7508661 : EnC
            ) select
                  x_new_project_id,
                  x_project_name,
                      NVL( x_long_name, x_project_name ),    --long name changes
                  x_new_project_number,
                  t.org_id,   -- Bug 4363092: MOAC Changes
                  sysdate,
                  FND_GLOBAL.USER_ID,
                  sysdate,
                  FND_GLOBAL.USER_ID,
                  FND_GLOBAL.LOGIN_ID,
                  t.project_type,
                  nvl(x_organization_id, t.carrying_out_organization_id),
                    nvl(x_public_sector_flag, t.public_sector_flag),
                  p_project_status_code,
                  nvl(x_description, t.description),
                  nvl(x_start_date, t.start_date),
                  nvl(x_completion_date, t.completion_date + x_delta),
                    p_closed_date,
                  --nvl(x_distribution_rule, t.distribution_rule),
                   nvl(l_new_distribution_rule, t.distribution_rule),     --Bug 3279981 Review
                  t.labor_invoice_format_id,
                  t.non_labor_invoice_format_id,
                  t.retention_invoice_format_id,
                  t.retention_percentage,
                  t.billing_offset,
                  t.billing_cycle_id,
                  t.labor_std_bill_rate_schdl,
                  t.labor_bill_rate_org_id,
                  t.labor_schedule_fixed_date,
                  t.labor_schedule_discount,
                  t.non_labor_std_bill_rate_schdl,
                  t.non_labor_bill_rate_org_id,
                  t.non_labor_schedule_fixed_date,
                  t.non_labor_schedule_discount,
                  t.limit_to_txn_controls_flag,
             --   t.project_level_funding_flag,
              -- this values should not get copyied as no funding
              -- information is getting copyied.
                   '',
                  t.invoice_comment,
                      -- Commented following two lines and replaced with NULL
                      -- for bug # 822580 fix
                      -- t.unbilled_receivable_dr,
                      -- t.unearned_revenue_cr,
                 NULL,
                 NULL,
                  t.summary_flag,
                  t.enabled_flag,
                  t.segment2,
                  t.segment3,
                  t.segment4,
                  t.segment5,
                  t.segment6,
                  t.segment7,
                  t.segment8,
                  t.segment9,
                  t.segment10,
             -- Bug 2900258
                  /*    decode(x_attribute_category, null,
                                t.attribute_category, x_attribute_category), */
/*                      decode(x_attribute_category, null,
                                decode(l_is_dff_reference_temp_flag,'YES','N',t.attribute_category), x_attribute_category),
                  decode(x_attribute_category, null, t.attribute1, x_attribute1),
                  decode(x_attribute_category, null, t.attribute2, x_attribute2),
                  decode(x_attribute_category, null, t.attribute3, x_attribute3),
                  decode(x_attribute_category, null, t.attribute4, x_attribute4),
                  decode(x_attribute_category, null, t.attribute5, x_attribute5),
                  decode(x_attribute_category, null, t.attribute6, x_attribute6),
                  decode(x_attribute_category, null, t.attribute7, x_attribute7),
                  decode(x_attribute_category, null, t.attribute8, x_attribute8),
                  decode(x_attribute_category, null, t.attribute9, x_attribute9),
                  decode(x_attribute_category, null, t.attribute10, x_attribute10),*/
   /*Decode for l_pr_dff_flag added for selective copy project options. Tracking bug No 3464332*/
                  decode(l_pr_dff_flag,'Y',
                                       decode(x_attribute_category, null,
                                              decode(l_is_dff_reference_temp_flag,'YES',
					      DECODE(t.attribute_category,NULL,NULL,'N'),-- Added for Bug 5757594
					      t.attribute_category),
                                              x_attribute_category),
                                       null),
                  decode(l_pr_dff_flag,'Y', decode(x_attribute_category, null, t.attribute1, x_attribute1) ,null),
                  decode(l_pr_dff_flag,'Y', decode(x_attribute_category, null, t.attribute2, x_attribute2) ,null),
                  decode(l_pr_dff_flag,'Y', decode(x_attribute_category, null, t.attribute3, x_attribute3) ,null),
                  decode(l_pr_dff_flag,'Y', decode(x_attribute_category, null, t.attribute4, x_attribute4) ,null),
                  decode(l_pr_dff_flag,'Y', decode(x_attribute_category, null, t.attribute5, x_attribute5) ,null),
                  decode(l_pr_dff_flag,'Y', decode(x_attribute_category, null, t.attribute6, x_attribute6) ,null),
                  decode(l_pr_dff_flag,'Y', decode(x_attribute_category, null, t.attribute7, x_attribute7) ,null),
                  decode(l_pr_dff_flag,'Y', decode(x_attribute_category, null, t.attribute8, x_attribute8) ,null),
                  decode(l_pr_dff_flag,'Y', decode(x_attribute_category, null, t.attribute9, x_attribute9) ,null),
                  decode(l_pr_dff_flag,'Y', decode(x_attribute_category, null, t.attribute10, x_attribute10),null),
                  t.cost_ind_rate_sch_id,
                  t.rev_ind_rate_sch_id,
                  t.inv_ind_rate_sch_id,
                  t.cost_ind_sch_fixed_date,
                  t.rev_ind_sch_fixed_date,
                  t.inv_ind_sch_fixed_date,
                  t.labor_sch_type,
                  t.non_labor_sch_type,
                  decode(x_template_flag, 'Y', 'Y', 'N'),
                  null,
                  decode(x_template_flag,'Y',null,x_created_from_proj_id), --Bug:4709791
                  decode(x_template_flag,'Y', x_start_date, null),
                  decode(x_template_flag,'Y', x_completion_date, null),
                   x_pm_product_code,
                   x_pm_project_reference,
                 x_actual_start_date,
                 x_actual_finish_date,
                 x_early_start_date,
                 x_early_finish_date,
                 x_late_start_date,
                 x_late_finish_date,
-- anlee
-- Dates changes
                 x_scheduled_start_date,
                 x_scheduled_finish_date,
-- End of changes
                 NVL(x_project_currency_code,t.project_currency_code), /* 8297384 */
                 t.allow_cross_charge_flag,
                 t.project_rate_date,
                 t.project_rate_type,
                 t.output_tax_code,
                 t.retention_tax_code,
                 t.cc_process_labor_flag,
                 t.labor_tp_schedule_id,
                 t.labor_tp_fixed_date,
                 t.cc_process_nl_flag,
                 t.nl_tp_schedule_id,
                 t.nl_tp_fixed_date,
                 /* Bug # 2093089 : replaced cc_tax_task_id with NULL. */
         /* Reverted the chages of 2093089 for bug # 2185521   */
                 /* Added decode for Bug 6248841 */
                 decode(nvl(x_copy_task_flag,'N'),'Y',t.cc_tax_task_id,NULL),
                 -- NULL,
                 t.bill_job_group_id,
                 t.cost_job_group_id,
                 t.role_list_id,
                 t.work_type_id,
                 /* t.calendar_id,  commented for bug 2588244 */
                 /* Added nvl for bug 3185851 */
                 decode(l_flag, 'Y', t.calendar_id, 'N', nvl(l_cal_id, t.calendar_id)),  /* decode added for bug 2588244 */
                 l_team_template_id,
                 nvl(l_location_id, t.location_id),
                 nvl(x_probability_member_id,  t.probability_member_id),
                 nvl(x_project_value,          t.project_value),
                 nvl(x_expected_approval_date, t.expected_approval_date),
                 t.job_bill_rate_schedule_id,
                 t.emp_bill_rate_schedule_id,
--MCA Sakthi for MultiAgreementCurreny Project
                 t.competence_match_wt,
                 t.availability_match_wt,
                 t.job_level_match_wt,
                 t.enable_automated_search,
                 t.search_min_availability,
                 t.search_org_hier_id,
                 t.search_starting_org_id,
                 t.search_country_code,
                 t.min_cand_score_reqd_for_nom,
                 t.non_lab_std_bill_rt_sch_id,
                 t.invproc_currency_type,
                 t.revproc_currency_code,
                 t.project_bil_rate_date_code,
                 t.project_bil_rate_type,
                 t.project_bil_rate_date,
                 t.project_bil_exchange_rate,
                 t.projfunc_currency_code,
                 t.projfunc_bil_rate_date_code,
                 t.projfunc_bil_rate_type,
                 t.projfunc_bil_rate_date,
                 t.projfunc_bil_exchange_rate,
                 t.funding_rate_date_code,
                 t.funding_rate_type,
                 t.funding_rate_date,
                 t.funding_exchange_rate,
                 t.baseline_funding_flag,
                 t.projfunc_cost_rate_type,
                 t.projfunc_cost_rate_date,
--MCA Sakthi for MultiAgreementCurreny Project
                 t.multi_currency_billing_flag,
                 t.inv_by_bill_trans_curr_flag,
--MCA
                 t.assign_precedes_task,
                 t.split_cost_from_workplan_flag,
                 t.split_cost_from_bill_flag,
--MCA
--Advertisement, Project Setup and Retention changes

                 nvl( x_priority_code, t.priority_code ),
                 t.retn_billing_inv_format_id,
                 l_retn_accounting_flag,    --bugfix 2434241
                 t.adv_action_set_id,
                 t.start_adv_action_set_flag,
--Advertisement, Project Setup and Retention changes

-- anlee
-- Dates changes
                 nvl(x_start_date, t.target_start_date),
                 nvl(x_completion_date, t.target_finish_date + x_delta),
-- End of changes
-- anlee
-- patchset K changes
                 t.revaluate_funding_flag,
                 t.include_gains_losses_flag,
-- msundare
                 NVL( x_security_level, t.security_level ),
                 t.labor_disc_reason_code,
                 t.non_labor_disc_reason_code,
-- End of changes
                 1,
                 t.btc_cost_base_rev_code, /* bug#2638968 */
--PA L bug 2872708
                 t.asset_allocation_method,
                 t.capital_event_processing,
                 t.cint_rate_sch_id,
                 t.cint_eligible_flag,
--End PA L 2872708
                 t.structure_sharing_code,     --FPM bug 3301192
/* Added for FPM development -Project Setup Changes Bug 3279981*/
                 decode(p_en_top_task_cust_flag, null, t.enable_top_task_customer_flag,
                                                 p_en_top_task_cust_flag) ,
                 decode(p_en_top_task_inv_mth_flag, null, t.enable_top_task_inv_mth_flag,
                                                    p_en_top_task_inv_mth_flag) ,
                 nvl(substr(x_distribution_rule, 1, instr(x_distribution_rule,'/')-1),t.revenue_accrual_method),
                 nvl(substr(x_distribution_rule, instr(x_distribution_rule,'/')+1),t.invoice_method),
                 t.projfunc_attr_for_ar_flag,
                 t.sys_program_flag,
                 t.allow_multi_program_rollup,
                 t.proj_req_res_format_id,
                 t.proj_asgmt_res_format_id,
                 l_fund_status,                  -- added for 4055319
                 t.revtrans_currency_type,  -- Added for Bug 4757022
		 --sunkalya:federal Bug#5511353
                 decode(p_date_eff_funds_flag, null, nvl(t.DATE_EFF_FUNDS_CONSUMPTION,'N'), p_date_eff_funds_flag)
		 --sunkalya:federal Bug#5511353
                ,t.ar_rec_notify_flag     -- 7508661 : EnC
                ,t.auto_release_pwp_inv   -- 7508661 : EnC
        from pa_projects t
        where t.project_id = x_orig_project_id;

        if (SQL%NOTFOUND) then
           x_err_code := 90;
           x_err_stage := 'PA_NO_PROJ_CREATED';
           rollback to copy_project;
           revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
           return;
        end if;
    end;

    -- 4199336 commented below code because of pjp depandancy issue

    -- 4055319 : When ever a project is created or updated in PJT, it may be considered for funding approval,
    -- i.e. Submitted to PJP. below API from PJP is called to achieve this.

    BEGIN

      IF x_template_flag = 'N' THEN

          PA_PJP_PVT.Submit_Project_Aw -- Changed from FPA_PROCESS_PVT to PA_PJP_PVT package
          (
             p_api_version          => 1.0
            ,p_init_msg_list        => FND_API.G_FALSE
            ,p_commit               => FND_API.G_FALSE
            ,p_project_id           => x_new_project_id
            ,x_return_status        => l_return_status
            ,x_msg_count            => l_msg_count
            ,x_msg_data             => l_msg_data
          );

      END IF;

    EXCEPTION WHEN OTHERS THEN
         x_err_code := 114;
         x_err_stage := 'API: '||'FPA_PROCESS_PVT.Submit_Project_Aw'||
                                ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
         rollback to copy_project;
         revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
         return;
    END;
    -- 4055319 end

    -- 4199336 end

    -- anlee
    -- Added for intermedia search
    x_err_stage := 'Calling PA_PROJECT_CTX_SEARCH_PVT.Insert_Row API ...';
    DECLARE
      l_return_status VARCHAR2(1);
      CURSOR get_proj_attr
      IS
      SELECT name, long_name, segment1, description, template_flag
      FROM PA_PROJECTS_ALL
      WHERE project_id = x_new_project_id;

      l_name VARCHAR2(30);
      l_long_name VARCHAR2(240);
      l_number VARCHAR2(25);
      l_description VARCHAR2(250);
      l_template_flag VARCHAR2(1);
    BEGIN
      OPEN get_proj_attr;
      FETCH get_proj_attr INTO l_name, l_long_name, l_number, l_description, l_template_flag;
      CLOSE get_proj_attr;

      PA_PROJECT_CTX_SEARCH_PVT.INSERT_ROW (
       p_project_id           => x_new_project_id
      ,p_template_flag        => l_template_flag
      ,p_project_name         => l_name
      ,p_project_number       => l_number
      ,p_project_long_name    => l_long_name
      ,p_project_description  => l_description
      ,x_return_status        => l_return_status );

   EXCEPTION WHEN OTHERS THEN
     x_err_code := 114;
     x_err_stage := 'API: '||'PA_PROJECT_CTX_SEARCH_PVT.INSERT_ROW'||
                            ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
     rollback to copy_project;
     revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
     return;
   END;
   -- anlee end of changes

        x_err_stage := 'copying project options ';

        -- Copy all options relevant to the created_from_project_id

    if (x_template_flag = 'Y') then
        insert into pa_project_options (
                      project_id,
                      option_code,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login
             ) select
              x_new_project_id,
              o.option_code,
              sysdate,
                      FND_GLOBAL.USER_ID,
                      sysdate,
                      FND_GLOBAL.USER_ID,
                      FND_GLOBAL.LOGIN_ID
        from pa_project_options o
        where o.project_id = x_created_from_proj_id;

        x_err_stage := 'copying project copy overrides ';

                insert into pa_project_copy_overrides (
                      project_id,
                      field_name,
              display_name,
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
              limiting_value,
              sort_order,
              mandatory_flag,
                      record_version_number
                     ) select
                      x_new_project_id,
                      c.field_name,
                      c.display_name,
                      sysdate,
                      FND_GLOBAL.USER_ID,
                      sysdate,
                      FND_GLOBAL.USER_ID,
                      FND_GLOBAL.LOGIN_ID,
                      c.limiting_value,
                      c.sort_order,
                      c.mandatory_flag,
                      1
        from pa_project_copy_overrides c
        where c.project_id = x_created_from_proj_id;
    end if;

-- anlee
-- Copying Subteams
   x_err_stage := 'Calling PA_PROJECT_SUBTEAMS_PUB.Create_Subteam API ...';

   DECLARE
     CURSOR get_subteams_csr(c_project_id NUMBER) IS
     SELECT name, description
     FROM   pa_project_subteams
     WHERE  object_type = 'PA_PROJECTS'
     AND    object_id = c_project_id;

     l_name             PA_PROJECT_SUBTEAMS.name%TYPE;
     l_description      PA_PROJECT_SUBTEAMS.description%TYPE;
     l_new_subteam_id   NUMBER;
     l_subteam_row_id   ROWID;
     l_return_status    VARCHAR2(1);
     l_msg_count        NUMBER;
     l_msg_data         VARCHAR2(2000);

   BEGIN
     OPEN get_subteams_csr(x_orig_project_id);
     LOOP
       FETCH get_subteams_csr INTO l_name, l_description;
       EXIT WHEN get_subteams_csr%NOTFOUND;

       PA_PROJECT_SUBTEAMS_PUB.Create_Subteam(
        p_subteam_name            =>  l_name
       ,p_object_type             =>  'PA_PROJECTS'
       ,p_object_id               =>  x_new_project_id
       ,p_description             =>  l_description
       ,p_record_version_number   =>  1
       ,p_calling_module          =>  'PROJECT_SUBTEAMS'
       ,p_init_msg_list           =>  FND_API.G_TRUE
       ,p_validate_only           =>  FND_API.G_FALSE
       ,x_new_subteam_id          =>  l_new_subteam_id
       ,x_subteam_row_id          =>  l_subteam_row_id
       ,x_return_status           =>  l_return_status
       ,x_msg_count               =>  l_msg_count
       ,x_msg_data                =>  l_msg_data);

       IF (l_return_status <> 'S') Then
         rollback to copy_project;
         revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
         x_err_code := 102;
         x_err_stage   := pa_project_core1.get_message_from_stack( 'PA_ERR_CR_PROJ_SUBTEAM');
         x_err_stack   := x_err_stack||'->PA_PROJECT_PARTIES_PUB.CREATE_SUBTEAM';
         return;
       END IF;
     END LOOP;
     CLOSE get_subteams_csr;  --Bug 3905797

   EXCEPTION WHEN OTHERS THEN
     x_err_code := 102;
--     x_err_stage := pa_project_core1.get_message_from_stack( null );
--     IF x_err_stage IS NULL
--     THEN
       x_err_stage := 'API: '||'PA_PROJECT_SUBTEAMS_PUB.CREATE_SUBTEAM'||
                            ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--     END IF;
     rollback to copy_project;
     revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
     return;
   END;

-- anlee
-- Copying opportunity value attributes

   x_err_stage := 'Calling PA_OPPORTUNITY_MGT_PVT.COPY_PROJECT_ATTRIBUTES API ...';

   BEGIN
     PA_OPPORTUNITY_MGT_PVT.COPY_PROJECT_ATTRIBUTES
     ( p_source_project_id   => x_orig_project_id
      ,p_dest_project_id     => x_new_project_id
      ,x_return_status       => l_return_status
      ,x_msg_count           => l_msg_count
      ,x_msg_data            => l_msg_data);

     if l_return_status <> 'S' then
       x_err_code := 128;
       x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_COPY_PROJ_OPP_ATTR');
       x_err_stack := x_err_stack||'->PA_OPPORTUNITY_MGT_PVT.COPY_PROJECT_ATTRIBUTES';
       rollback to copy_project;
       revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
       return;
     end if;
   EXCEPTION WHEN OTHERS THEN
     x_err_code := 128;
--     x_err_stage := pa_project_core1.get_message_from_stack( null );
--     IF x_err_stage IS NULL
--       THEN
         x_err_stage := 'API: '||'PA_OPPORTUNITY_MGT_PVT.COPY_PROJECT_ATTRIBUTES'||
                        ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--     END IF;
     rollback to copy_project;
     revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
     return;
   END;

   OPEN l_get_details_for_opp_csr(x_new_project_id);
   FETCH l_get_details_for_opp_csr INTO l_expected_approval_date, l_projfunc_currency_code, l_project_currency_code
         ,l_target_start_date, l_target_finish_date , l_cal_id;    --bug 2805602
   CLOSE l_get_details_for_opp_csr;

   OPEN l_get_details_for_opp_csr2(x_new_project_id);
   FETCH l_get_details_for_opp_csr2 INTO l_opportunity_value, l_opp_value_currency_code;
   CLOSE l_get_details_for_opp_csr2;

-- Modify opportunity value attributes with values entered in quick entry

   x_err_stage := 'Calling PA_OPPORTUNITY_MGT_PVT.MODIFY_PROJECT_ATTRIBUTES API ...';

   BEGIN
     PA_OPPORTUNITY_MGT_PVT.MODIFY_PROJECT_ATTRIBUTES
     ( p_project_id              => x_new_project_id
      ,p_opportunity_value       => nvl(x_project_value, l_opportunity_value)
      ,p_opp_value_currency_code => nvl(x_opp_value_currency_code, l_opp_value_currency_code)
      ,p_expected_approval_date  => l_expected_approval_date
      ,x_return_status           => l_return_status
      ,x_msg_count               => l_msg_count
      ,x_msg_data                => l_msg_data);

     if l_return_status <> 'S' then
       x_err_code := 130;
       x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_MOD_PROJ_OPP_ATTR');
       x_err_stack := x_err_stack||'->PA_OPPORTUNITY_MGT_PVT.MODIFY_PROJECT_ATTRIBUTES';
       rollback to copy_project;
       revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
       return;
     end if;
   EXCEPTION WHEN OTHERS THEN
     x_err_code := 130;
--     x_err_stage := pa_project_core1.get_message_from_stack( null );
--     IF x_err_stage IS NULL
--       THEN
         x_err_stage := 'API: '||'PA_OPPORTUNITY_MGT_PVT.MODIFY_PROJECT_ATTRIBUTES'||
                        ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--     END IF;
     rollback to copy_project;
     revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
     return;
   END;

-- anlee
-- Copying workplan attributes
/*
   x_err_stage := 'Calling PA_WORKPLAN_ATTR_PUB.CREATE_PROJ_WORKPLAN_ATTRS API ...';

   OPEN l_get_workplan_attrs_csr(x_orig_project_id);
   FETCH l_get_workplan_attrs_csr
   INTO l_approval_reqd_flag, l_auto_publish_flag, l_approver_source_id, l_approver_source_type, l_default_outline_lvl;
   CLOSE l_get_workplan_attrs_csr;

   BEGIN
     PA_WORKPLAN_ATTR_PUB.CREATE_PROJ_WORKPLAN_ATTRS
     ( p_validate_only             => FND_API.G_FALSE
      ,p_project_id                => x_new_project_id
      ,p_approval_reqd_flag        => l_approval_reqd_flag
      ,p_auto_publish_flag         => l_auto_publish_flag
      ,p_approver_source_id        => l_approver_source_id
      ,p_approver_source_type      => l_approver_source_type
      ,p_default_outline_lvl       => l_default_outline_lvl
      ,x_return_status             => l_return_status
      ,x_msg_count                 => l_msg_count
      ,x_msg_data                  => l_msg_data );

     if l_return_status <> 'S' then
       x_err_code := 710;
       x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_COPY_WRKPLN_ATTR');
       x_err_stack := x_err_stack||'->PA_WORKPLAN_ATTR_PUB.CREATE_PROJ_WORKPLAN_ATTRS';
       rollback to copy_project;
       return;
     end if;
   EXCEPTION WHEN OTHERS THEN
     x_err_code := 710;
--     x_err_stage := pa_project_core1.get_message_from_stack( null );
--     IF x_err_stage IS NULL
--       THEN
         x_err_stage := 'API: '||'PA_WORKPLAN_ATTR_PUB.CREATE_PROJ_WORKPLAN_ATTRS'||
                        ' SQL error message: '||SUBSTR( SQLERRM,1,1900);

--     END IF;
     rollback to copy_project;
     return;
   END;
*/

-- Creating assignments
   l_start_date := nvl(x_start_date, x_orig_start_date);
   l_start_date := nvl(l_start_date, sysdate);

   x_err_stage := 'Calling Team_Template.Execute_apply_Team_template API ...';

  /* Bug 4092701 - Commented the prm_licensed check   */
/*   if((l_team_template_id is not null) AND (pa_install.is_prm_licensed() = 'Y')) then */
  if l_team_template_id is not null then
--EH Changes
    BEGIN

      PA_TEAM_TEMPLATES_PUB.EXECUTE_APPLY_TEAM_TEMPLATE
      ( p_team_template_id    => l_team_template_id
       ,p_project_id          => x_new_project_id
       ,p_project_start_date  => l_start_date
       ,x_return_status       => l_return_status
       ,x_msg_count           => l_msg_count
       ,x_msg_data            => l_msg_data);

      if l_return_status <> 'S' then
         x_err_code := 256;
--       x_err_stage := 'PA_NO_PROJ_CREATED';
         x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_EXEC_APPLY_TEAM_TMP');
         x_err_stack := x_err_stack||'->PA_TEAM_TEMPLATES_PUB.EXECUTE_APPLY_TEAM_TEMPLATE';
         rollback to copy_project;
         revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
         return;
      end if;
    EXCEPTION WHEN OTHERS THEN
        x_err_code := 256;
--        x_err_stage := pa_project_core1.get_message_from_stack( null );
--        IF x_err_stage IS NULL
--        THEN
           x_err_stage := 'API: '||'PA_TEAM_TEMPLATES_PUB.EXECUTE_APPLY_TEAM_TEMPLATE'||
                            ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--        END IF;
        rollback to copy_project;
        revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
        return;
    END;
  end if;

   /* Declare    -- FOR ROLE BASED CHANGES
  Commented the below code for the bug 2719670
    cursor c_role_based_loop_csr_1(r_project_id IN NUMBER, r_delta IN NUMBER) is
        SELECT DISTINCT
          p.resource_source_id   resource_source_id
          , p.project_role_type   project_role_type
          , p.resource_type_id resource_type_id
          , decode(r_delta, null, x_start_date,  -- case B-2
            start_date_active + r_delta)  start_date_active -- A,C,D,B-1
          , decode(r_delta, null, x_completion_date,  -- case B-2
            end_date_active + r_delta) end_date_active  -- A,C,D,B-1
        FROM pa_project_parties_v p
        WHERE p.project_id = r_project_id
        AND   p.party_type not in ('ORGANIZATION');
     Corrected the spelling of organization in the above csr for bug 2689578

    cursor c_role_based_loop_csr_2(r_project_id IN NUMBER, r_delta IN NUMBER) is
        SELECT DISTINCT
          p.resource_source_id   resource_source_id
          , p.project_role_type   project_role_type
          , p.resource_type_id   resource_type_id
          , decode(r_delta, null, x_start_date,
            start_date_active + r_delta)  start_date_active
          , decode(r_delta, null, x_completion_date,
            end_date_active + r_delta) end_date_active
        FROM  pa_project_parties_v p
        WHERE p.project_id = r_project_id
        AND   p.party_type not in ('ORGANIZATION')
        AND   p.project_role_type not in
                   (select distinct
                    limiting_value
                    from pa_project_copy_overrides
                    where project_id = x_created_from_proj_id
                    and field_name = 'KEY_MEMBER');*/

  /* Added the below code for  bug 2719670, for performance improvement*/
 Declare    -- FOR ROLE BASED CHANGES
 cursor c_role_based_loop_csr_1(r_project_id IN NUMBER, r_delta IN NUMBER) is
   SELECT
          p.resource_source_id   resource_source_id
          , r.project_role_type   project_role_type
          , p.resource_type_id resource_type_id
          , decode(r_delta, null, x_start_date,  -- case B-2
            p.start_date_active + r_delta)  start_date_active -- A,C,D,B-1
          , decode(r_delta, null, x_completion_date,  -- case B-2
            p.end_date_active + r_delta) end_date_active  -- A,C,D,B-1
        FROM pa_project_parties p,PA_PROJECT_ROLE_TYPES_B R
        WHERE p.project_id = r_project_id
         AND p.project_role_id = r.project_role_id
     AND r.role_party_class = 'PERSON';
     /*Corrected the spelling of organization in the above csr for bug 2689578*/

     cursor c_role_based_loop_csr_2(r_project_id IN NUMBER, r_delta IN NUMBER) is
        SELECT
           p.project_party_id     project_party_id   -- Bug 7482391
          ,p.resource_source_id   resource_source_id
          , r.project_role_type   project_role_type
          , p.resource_type_id   resource_type_id
          , decode(r_delta, null, x_start_date,
            p.start_date_active + r_delta)  start_date_active
          , decode(r_delta, null, x_completion_date,
            p.end_date_active + r_delta) end_date_active
        FROM  pa_project_parties p,PA_PROJECT_ROLE_TYPES_B R
        WHERE p.project_id = r_project_id
        AND p.project_role_id = r.project_role_id
        AND r.role_party_class = 'PERSON'
        AND   r.project_role_type not in
                   (select distinct
                    limiting_value
                    from pa_project_copy_overrides
                    where project_id = x_created_from_proj_id
                    and field_name = 'KEY_MEMBER');
   /*Code addition for  bug 2719670 ends*/

   /* Bug 3022296 : Added new cursor for checking ext. customer member existance */
   CURSOR chk_for_hz_parties(p_person_id NUMBER) IS
       SELECT 'Y'
       FROM   hz_parties h
       WHERE  h.party_id = p_person_id
       AND    h.party_type = 'PERSON';
  /* End 3022296 */

   c_role_based_loop_rec_1   c_role_based_loop_csr_1%ROWTYPE ;
   c_role_based_loop_rec_2   c_role_based_loop_csr_2%ROWTYPE ;
   v_null_number        NUMBER;
   v_null_char          VARCHAR2(255);
   v_null_date          DATE;
   x_return_status      VARCHAR2(255);
   x_msg_count          NUMBER;
   x_msg_data           VARCHAR2(2000);
   x_project_party_id   NUMBER;
   x_resource_id        NUMBER;
   l_hz_parties        VARCHAR(1) := 'N'; --Bug 3022296

   /* Added for Bug 7482391 */
   role_end_date       date;
   x_delta_1           number;
   tmp_min_strt_dt     date;
   f_flag varchar2(1) := 'Y';

  Begin      -- FOR ROLE BASED CHANGES

-- begin NEW code for ROLE BASED SECURITY

   x_err_stage := 'Calling CREATE_PROJECT_PARTY API ...';

    if (x_use_override_flag = 'N') then
       FOR c_role_based_loop_rec_1
        IN c_role_based_loop_csr_1(x_orig_project_id,x_delta)  LOOP

--EH Changes
        BEGIN
           /* Bug 3022296 : Open cursor */
           OPEN chk_for_hz_parties(c_role_based_loop_rec_1.resource_source_id);
           fetch chk_for_hz_parties into l_hz_parties;
           close chk_for_hz_parties;

           --bug 2778730 and modified if through bug 3022296 Start
           IF ( ( c_role_based_loop_rec_1.resource_type_id = 101
                   AND PA_RESOURCE_UTILS.check_res_not_terminated(
                                          p_object_type             => 'PERSON',
                                          p_object_id               => c_role_based_loop_rec_1.resource_source_id ,
                                          p_effective_start_date    => c_role_based_loop_rec_1.start_date_active)
                )
           OR ( c_role_based_loop_rec_1.resource_type_id = 112
                 AND nvl(l_hz_parties,'N') = 'Y')
              )THEN  -- Bug 3022296 End
           --bug 2778730
        /* Bug 3022296 : End */
                PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
                        p_api_version => 1.0                 -- p_api_version
                       , p_init_msg_list => FND_API.G_TRUE  -- p_init_msg_list
                       , p_commit => FND_API.G_FALSE        -- p_commit
                       , p_validate_only => FND_API.G_FALSE -- p_validate_only
                       , p_validation_level => FND_API.G_VALID_LEVEL_FULL -- p_validation_level
                       , p_debug_mode => 'N'                -- p_debug_mode
                       , p_object_id => x_new_project_id    -- p_object_id
                       , p_OBJECT_TYPE => 'PA_PROJECTS'        -- p_OBJECT_TYPE
                       , p_project_role_id => v_null_number -- p_project_role_id
                       , p_project_role_type => c_role_based_loop_rec_1.project_role_type  -- p_project_role_type
                       , p_RESOURCE_TYPE_ID => c_role_based_loop_rec_1.resource_type_id         -- p_RESOURCE_TYPE_ID
                       , p_resource_source_id => c_role_based_loop_rec_1.resource_source_id  -- p_resource_source_id
                       , p_resource_name => v_null_char     -- p_resource_name
                       , p_start_date_active => c_role_based_loop_rec_1.start_date_active  -- p_start_date_active
                       , p_scheduled_flag => 'N'            -- p_scheduled_flag
                       --          , p_record_version_number => 1     -- p_record_version_number
                       , p_calling_module => 'FORM'         -- p_calling_module
                       , p_project_id => x_new_project_id   -- p_project_id
                       , p_project_end_date => v_null_date  -- p_project_end_date
                       , p_end_date_active => c_role_based_loop_rec_1.end_date_active  -- p_end_date_active
                       , x_project_party_id => x_project_party_id -- x_project_party_id
                       , x_resource_id => x_resource_id     -- x_resource_id
                       , x_wf_item_type     =>l_wf_item_type
                       , x_wf_type          => l_wf_type
                       , x_wf_process       => l_wf_party_process
                       , x_assignment_id    => l_assignment_id
                       , x_return_status => x_return_status -- x_return_status
                       , x_msg_count => x_msg_count         -- x_msg_count
                       , x_msg_data => x_msg_data           -- x_msg_data
                             );
               IF    (x_return_status <> 'S') Then
                   --                p_return_status := x_return_status;
                   --                p_msg_count     := x_msg_count;
                   --                p_msg_data      := SUBSTR(p_msg_data||x_msg_data,1,2000);
                   /* Bug no 1990875 added rollback statement as no project should be created
                  if copying of key member fails */
                  rollback to copy_project;
                  revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                  x_err_code := 125;
                   --                  x_err_stage := 'PA_NO_PROJ_CREATED';  --commented by ansari
                  x_err_stage   := pa_project_core1.get_message_from_stack( 'PA_ERR_CR_PROJ_PARTY_PUB');
                  x_err_stack   := x_err_stack||'->PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY';
                  return;
               END IF;
           END IF;   --bug 2778730
        EXCEPTION WHEN OTHERS THEN
             x_err_code := 125;
--             x_err_stage := pa_project_core1.get_message_from_stack( null );
--             IF x_err_stage IS NULL
--             THEN
                x_err_stage := 'API: '||'PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY'||
                                 ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--             END IF;
             rollback to copy_project;
             revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
             return;
        END;
       END LOOP;
    else
   /*Following code added for selective copy project options. Tracking bug No 3464332*/
    OPEN  cur_get_flag('PR_TEAM_MEMBERS_FLAG');
    FETCH cur_get_flag INTO l_pr_team_members_flag;
    CLOSE cur_get_flag;

    IF 'Y' = l_pr_team_members_flag THEN
/* Bug 2009240 Uncommenting the code in ELSE part */
--EH Changes
       FOR c_role_based_loop_rec_2
        IN c_role_based_loop_csr_2(x_orig_project_id,x_delta)  LOOP

        BEGIN
             /* Bug 3022296 : Open cursor */
           OPEN chk_for_hz_parties(c_role_based_loop_rec_2.resource_source_id);
           fetch chk_for_hz_parties into l_hz_parties;
           close chk_for_hz_parties;

           -- Bug 7482391
           open new_prj_end_date_csr(x_new_project_id);
           fetch new_prj_end_date_csr into new_prj_end_date;
           close new_prj_end_date_csr;

           --bug 2778730 and modified the if condition through bug 3022296
           IF ( ( c_role_based_loop_rec_2.resource_type_id = 101
                   AND PA_RESOURCE_UTILS.check_res_not_terminated(
                                          p_object_type             => 'PERSON',
                                          p_object_id               => c_role_based_loop_rec_2.resource_source_id ,
                                          p_effective_start_date    => c_role_based_loop_rec_2.start_date_active)
                )
           OR ( c_role_based_loop_rec_2.resource_type_id = 112
                 AND nvl(l_hz_parties,'N') = 'Y')
              )THEN  -- Bug 3022296
           /* Bug 3022296 : End */
           --bug 2778730

	   -- Start bug#5859329

--                      IF c_role_based_loop_rec_2.project_role_type = 'PROJECT MANAGER' THEN  --changed for bug 6780448

/* Bug 7482391 changes start here*/
l_tmp_start_date_active := c_role_based_loop_rec_2.start_date_active;

               if ((c_role_based_loop_rec_2.start_date_active <= x_completion_date) OR (x_completion_date is null))then   --Bug 8645109

                        if ( x_completion_date is not null and c_role_based_loop_rec_2.end_date_active >= x_completion_date ) then  --Bug 8645109
                                l_tmp_end_date_active := x_completion_date;

                        elsif (x_completion_date is null and new_prj_end_date is not null and c_role_based_loop_rec_2.end_date_active > new_prj_end_date ) then
                                l_tmp_end_date_active        :=        new_prj_end_date;

                        elsif (x_start_date is not null and x_orig_start_date is null) then

                                if (x_delta is null) then
                                        select min(start_date_active) into tmp_min_strt_dt from pa_project_parties where project_id = x_orig_project_id;
                                        x_delta_1 := x_start_date - tmp_min_strt_dt;
                                        select p.start_date_active + x_delta_1 into l_tmp_start_date_active from pa_project_parties p where p.project_party_id=c_role_based_loop_rec_2.project_party_id;

                                end if;

                                if(l_tmp_start_date_active < x_start_date or l_tmp_start_date_active > x_completion_date) then
                                f_flag:='N';
                                end if;

                                SELECT p.end_date_active + x_delta_1
                                INTO role_end_date
                                FROM pa_project_parties p,
                                  pa_project_role_types_b r
                                WHERE p.project_id = x_orig_project_id
                                 AND p.project_role_id = r.project_role_id
                                 AND r.role_party_class = 'PERSON'
                                 AND p.project_party_id = c_role_based_loop_rec_2.project_party_id
                                 AND p.resource_source_id = c_role_based_loop_rec_2.resource_source_id
                                 AND p.resource_type_id = c_role_based_loop_rec_2.resource_type_id
                                 AND r.project_role_type = c_role_based_loop_rec_2.project_role_type
                                 AND r.project_role_type NOT IN
                                  (SELECT DISTINCT limiting_value
                                   FROM pa_project_copy_overrides
                                   WHERE project_id = x_created_from_proj_id
                                   AND field_name = 'KEY_MEMBER');

                                if (new_prj_end_date is not null and role_end_date is not null and role_end_date > new_prj_end_date) then
                                        l_tmp_end_date_active   :=     new_prj_end_date;

                                else
                                        l_tmp_end_date_active   :=     role_end_date;
                                end if;

                        else
                                l_tmp_end_date_active        :=        c_role_based_loop_rec_2.end_date_active;
/*                      ELSE        --changed for 6780448

                                l_tmp_end_date_active        :=        v_null_date;  --changed for 6780448
*/                      END IF;

	   -- End   bug#5859329
/* Bug 7482391 changes end here*/
        if (f_flag = 'Y') then  -- Bug 7482391
                PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
                            p_api_version => 1.0                -- p_api_version
                           , p_init_msg_list => FND_API.G_TRUE -- p_init_msg_list
                           , p_commit => FND_API.G_FALSE       -- p_commit
                           , p_validate_only => FND_API.G_FALSE -- p_validate_only
                           , p_validation_level => FND_API.G_VALID_LEVEL_FULL  -- p_validation_level
                           , p_debug_mode => 'N'               -- p_debug_mode
                           , p_object_id => x_new_project_id   -- p_object_id
                           , p_OBJECT_TYPE => 'PA_PROJECTS'       -- p_OBJECT_TYPE
                           , p_project_role_id => v_null_number -- p_project_role_id
                           , p_project_role_type => c_role_based_loop_rec_2.project_role_type  -- p_project_role_type
                           , p_RESOURCE_TYPE_ID => c_role_based_loop_rec_2.resource_type_id    -- p_RESOURCE_TYPE_ID
                           , p_resource_source_id => c_role_based_loop_rec_2.resource_source_id  -- p_resource_source_id
                           , p_resource_name => v_null_char    -- p_resource_name
                           , p_start_date_active => l_tmp_start_date_active  -- p_start_date_active
                           , p_scheduled_flag => 'N'           -- p_scheduled_flag
                            --          , p_record_version_number => 1    -- p_record_version_number
                           , p_calling_module => 'FORM'        -- p_calling_module
                           , p_project_id => x_new_project_id  -- p_project_id
                           , p_project_end_date => v_null_date -- p_project_end_date
                           , p_end_date_active => l_tmp_end_date_active  -- bug#5859329 replaced v_null_date with l_tmp_end_date_active
                           , x_project_party_id => x_project_party_id -- x_project_party_id
                           , x_resource_id => x_resource_id     -- x_resource_id
                           , x_wf_item_type     =>l_wf_item_type
                           , x_wf_type          => l_wf_type
                           , x_wf_process       => l_wf_party_process
                           , x_assignment_id    => l_assignment_id
                           , x_return_status => x_return_status -- x_return_status
                           , x_msg_count => x_msg_count         -- x_msg_count
                           , x_msg_data => x_msg_data           -- x_msg_data
                             );
        end if;  -- Bug 7482391
                 IF    (x_return_status <> 'S') Then
                        --                p_return_status := x_return_status;
                        --                p_msg_count     := x_msg_count;
                        --                p_msg_data      := SUBSTR(p_msg_data||x_msg_data,1,2000);
                       /* Bug no 1990875 added rollback statement as no project should be created
                        if copying of key member fails */
                       rollback to copy_project;
                       revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534

                       x_err_code := 125;
                       --                  x_err_stage := 'PA_NO_PROJ_CREATED';
                       x_err_stage   := pa_project_core1.get_message_from_stack( 'PA_ERR_CR_PROJ_PARTY_PUB');
                       x_err_stack   := x_err_stack||'->PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY';
                       return;
                 END IF;
              END IF; -- Bug 7482391
           END IF; --bug 2778730
        EXCEPTION WHEN OTHERS THEN
            x_err_code := 125;
--             x_err_stage := pa_project_core1.get_message_from_stack( null );
--             IF x_err_stage IS NULL
--             THEN
                x_err_stage := 'API: '||'PA_PROJECT_PARTIES_PUB.CREATE_PROJECT _PARTY'||' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--             END IF;
             rollback to copy_project;
             revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
             return;
        END;
       END LOOP;
/*  Bug 2009240 End of uncommenting   */
      END IF; --'Y' = l_pr_team_members_flag
    end if;
  End;       -- FOR ROLE BASED CHANGES
-- end NEW code for ROLE BASED SECURITY


-- anlee
-- For Org Role changes
-- Copy over organizations from the source template/project
   /*Declare
   Commented the below code for the bug 2719670
    cursor c_role_based_loop_csr_1(r_project_id IN NUMBER, r_delta IN NUMBER) is
        SELECT
            p.resource_source_id   resource_source_id
          , p.project_party_id    project_party_id
          , p.project_role_type   project_role_type
          , decode(r_delta, null, x_start_date,  -- case B-2
            start_date_active + r_delta)  start_date_active -- A,C,D,B-1
          , decode(r_delta, null, x_completion_date,  -- case B-2
            end_date_active + r_delta) end_date_active  -- A,C,D,B-1
        FROM pa_project_parties_v p
        WHERE p.project_id = r_project_id
        AND   p.party_type = 'ORGANIZATION';

    cursor c_role_based_loop_csr_2(r_project_id IN NUMBER, r_delta IN NUMBER) is
        SELECT
            p.resource_source_id   resource_source_id
          , p.project_party_id    project_party_id
          , p.project_role_type   project_role_type
          , decode(r_delta, null, x_start_date,
            start_date_active + r_delta)  start_date_active
          , decode(r_delta, null, x_completion_date,
            end_date_active + r_delta) end_date_active
        FROM  pa_project_parties_v p
        WHERE p.project_id = r_project_id
        AND   p.party_type = 'ORGANIZATION'
        AND   p.project_role_type not in
                   (select distinct
                    limiting_value
                    from pa_project_copy_overrides
                    where project_id = x_created_from_proj_id
                    and field_name = 'ORG_ROLE');*/

 /* Added the below code for bug 2719670*/
Declare
  cursor c_role_based_loop_csr_1(r_project_id IN NUMBER, r_delta IN NUMBER) is
        SELECT
            p.resource_source_id   resource_source_id
          , P.project_party_id    project_party_id
          , r.project_role_type   project_role_type
          , decode(r_delta, null, x_start_date,  -- case B-2
            p.start_date_active + r_delta)  start_date_active -- A,C,D,B-1
          , decode(r_delta, null, x_completion_date,  -- case B-2
            p.end_date_active + r_delta) end_date_active  -- A,C,D,B-1
        FROM pa_project_parties p,PA_PROJECT_ROLE_TYPES_B R
        WHERE p.project_id = r_project_id
    AND p.project_role_id = r.project_role_id
    AND r.role_party_class <> 'PERSON';

    cursor c_role_based_loop_csr_2(r_project_id IN NUMBER, r_delta IN NUMBER) is
        SELECT
            p.resource_source_id   resource_source_id
          , p.project_party_id    project_party_id
          , r.project_role_type   project_role_type
          , decode(r_delta, null, x_start_date,
            p.start_date_active + r_delta)  start_date_active
          , decode(r_delta, null, x_completion_date,
            p.end_date_active + r_delta) end_date_active
        FROM  pa_project_parties p, PA_PROJECT_ROLE_TYPES_B R
        WHERE p.project_id = r_project_id
        AND p.project_role_id = r.project_role_id
    AND r.role_party_class <> 'PERSON'
        AND   r.project_role_type not in
                   (select distinct
                    limiting_value
                    from pa_project_copy_overrides
                    where project_id = x_created_from_proj_id
                    and field_name = 'ORG_ROLE');
   /*Code addition for bug 2719670 ends*/

   cursor c_cust_created_org_csr(c_project_id IN NUMBER, c_project_party_id IN NUMBER) is
       SELECT 'Y'
       FROM   DUAL
       WHERE  EXISTS
              (SELECT customer_id
               FROM   pa_project_customers
               WHERE  project_id = c_project_id
               AND    project_party_id = c_project_party_id);

   c_role_based_loop_rec_1   c_role_based_loop_csr_1%ROWTYPE ;
   c_role_based_loop_rec_2   c_role_based_loop_csr_2%ROWTYPE ;
   l_temp               VARCHAR2(1);
   v_null_number        NUMBER;
   v_null_char          VARCHAR2(255);
   v_null_date          DATE;
   x_return_status      VARCHAR2(255);
   x_msg_count          NUMBER;
   x_msg_data           VARCHAR2(2000);
   x_project_party_id   NUMBER;
   x_resource_id        NUMBER;

   Begin

   x_err_stage := 'Calling CREATE_PROJECT_PARTY API ...';

    if (x_use_override_flag = 'N') then
      FOR c_role_based_loop_rec_1
        IN c_role_based_loop_csr_1(x_orig_project_id, x_delta)  LOOP

        BEGIN

          OPEN c_cust_created_org_csr(x_orig_project_id, c_role_based_loop_rec_1.project_party_id);
          FETCH c_cust_created_org_csr INTO l_temp;

          -- Don't want to copy over those project organizations that were created along with
          -- a customer billing account
          if c_cust_created_org_csr%NOTFOUND then
            PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
              p_api_version                => 1.0
            , p_init_msg_list              => FND_API.G_TRUE
            , p_commit                     => FND_API.G_FALSE
            , p_validate_only              => FND_API.G_FALSE
            , p_validation_level           => FND_API.G_VALID_LEVEL_FULL
            , p_debug_mode                 => 'N'
            , p_object_id                  => x_new_project_id
            , p_OBJECT_TYPE                => 'PA_PROJECTS'
            , p_project_role_id            => v_null_number
            , p_project_role_type          => c_role_based_loop_rec_1.project_role_type
            , p_RESOURCE_TYPE_ID           => 112
            , p_resource_source_id         => c_role_based_loop_rec_1.resource_source_id
            , p_resource_name              => v_null_char
            , p_start_date_active          => c_role_based_loop_rec_1.start_date_active
            , p_scheduled_flag             => 'N'
            , p_calling_module             => 'FORM'
            , p_project_id                 => x_new_project_id
            , p_project_end_date           => v_null_date
            , p_end_date_active            => c_role_based_loop_rec_1.end_date_active
            , x_project_party_id           => x_project_party_id
            , x_resource_id                => x_resource_id
            , x_wf_item_type               => l_wf_item_type
            , x_wf_type                    => l_wf_type
            , x_wf_process                 => l_wf_party_process
            , x_assignment_id              => l_assignment_id
            , x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data );
            IF (x_return_status <> 'S') Then
              CLOSE c_cust_created_org_csr;
              rollback to copy_project;
              revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
              x_err_code := 125;
              x_err_stage   := pa_project_core1.get_message_from_stack( 'PA_ERR_CR_PROJ_PARTY_PUB');
              x_err_stack   := x_err_stack||'->PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY';
              return;
            END IF;
          END IF;

          CLOSE c_cust_created_org_csr;
        EXCEPTION WHEN OTHERS THEN
          x_err_code := 125;
--          x_err_stage := pa_project_core1.get_message_from_stack( null );
--          IF x_err_stage IS NULL
--          THEN
            x_err_stage := 'API: '||'PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY'||
                                 ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--          END IF;
          rollback to copy_project;
          revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
          return;
        END;
      END LOOP;
    else

      FOR c_role_based_loop_rec_2
        IN c_role_based_loop_csr_2(x_orig_project_id, x_delta)  LOOP

        BEGIN
          OPEN c_cust_created_org_csr(x_orig_project_id, c_role_based_loop_rec_2.project_party_id);
          FETCH c_cust_created_org_csr INTO l_temp;

          -- Don't want to copy over those project organizations that were created along with
          -- a customer billing account
          if c_cust_created_org_csr%NOTFOUND then
            PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
              p_api_version                => 1.0
            , p_init_msg_list              => FND_API.G_TRUE
            , p_commit                     => FND_API.G_FALSE
            , p_validate_only              => FND_API.G_FALSE
            , p_validation_level           => FND_API.G_VALID_LEVEL_FULL
            , p_debug_mode                 => 'N'
            , p_object_id                  => x_new_project_id
            , p_OBJECT_TYPE                => 'PA_PROJECTS'
            , p_project_role_id            => v_null_number
            , p_project_role_type          => c_role_based_loop_rec_2.project_role_type
            , p_RESOURCE_TYPE_ID           => 112
            , p_resource_source_id         => c_role_based_loop_rec_2.resource_source_id
            , p_resource_name              => v_null_char
            , p_start_date_active          => c_role_based_loop_rec_2.start_date_active
            , p_scheduled_flag             => 'N'
            , p_calling_module             => 'FORM'
            , p_project_id                 => x_new_project_id
            , p_project_end_date           => v_null_date
            , p_end_date_active            => c_role_based_loop_rec_2.end_date_active
            , x_project_party_id           => x_project_party_id
            , x_resource_id                => x_resource_id
            , x_wf_item_type               => l_wf_item_type
            , x_wf_type                    => l_wf_type
            , x_wf_process                 => l_wf_party_process
            , x_assignment_id              => l_assignment_id
            , x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data );

            IF (x_return_status <> 'S') Then
              CLOSE c_cust_created_org_csr;

              rollback to copy_project;
              revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
              x_err_code := 125;
              x_err_stage   := pa_project_core1.get_message_from_stack( 'PA_ERR_CR_PROJ_PARTY_PUB');
              x_err_stack   := x_err_stack||'->PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY';
              return;
            END IF;
          END IF;

          CLOSE c_cust_created_org_csr;
        EXCEPTION WHEN OTHERS THEN
            x_err_code := 125;
--             x_err_stage := pa_project_core1.get_message_from_stack( null );
--             IF x_err_stage IS NULL
--             THEN
                x_err_stage := 'API: '||'PA_PROJECT_PARTIES_PUB.CREATE_PROJECT _PARTY'||' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--             END IF;
             rollback to copy_project;
             revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
             return;
        END;
      END LOOP;
    end if;
  End;


    if ( x_use_override_flag = 'N' ) then

                -- Copy all project classes from original project
                x_err_stage := 'copying project classes not using override ';

                -- anlee
                -- Classification enhancements
                INSERT INTO pa_project_classes (
                       project_id
                ,      class_code
                ,      class_category
                ,      code_percentage
                ,      object_id
                ,      object_type
                ,      last_update_date
                ,      last_updated_by
                ,      creation_date
                ,      created_by
                ,      last_update_login
                ,      attribute_category
                ,      attribute1
                ,      attribute2
                ,      attribute3
                ,      attribute4
                ,      attribute5
                ,      attribute6
                ,      attribute7
                ,      attribute8
                ,      attribute9
                ,      attribute10
                ,      attribute11
                ,      attribute12
                ,      attribute13
                ,      attribute14
                ,      attribute15
        --below column added for bug2244929
        ,      record_version_number)
                SELECT
                       x_new_project_id
                ,      pc.class_code
        ,      pc.class_category
                ,      pc.code_percentage
                ,      x_new_project_id
                ,      'PA_PROJECTS'
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      FND_GLOBAL.LOGIN_ID
                ,      pc.attribute_category
                ,      pc.attribute1
                ,      pc.attribute2
                ,      pc.attribute3
                ,      pc.attribute4
                ,      pc.attribute5
                ,      pc.attribute6
                ,      pc.attribute7
                ,      pc.attribute8
                ,      pc.attribute9
                ,      pc.attribute10
                ,      pc.attribute11
                ,      pc.attribute12
                ,      pc.attribute13
                ,      pc.attribute14
                ,      pc.attribute15
        --below column added for bug 2244929
        ,      pc.record_version_number
                  FROM
                       pa_project_classes pc
                 WHERE pc.project_id = x_orig_project_id;
    else

            -- Copy only project classes with categories that are not
            -- overrideable.  The other project classes can be entered
            -- using Enter Project form.

                x_err_stage := 'copying project classes using override ';

                INSERT INTO pa_project_classes (
                       project_id
                ,      class_code
                ,      class_category
                ,      code_percentage
                ,      object_id
                ,      object_type
                ,      last_update_date
                ,      last_updated_by
                ,      creation_date
                ,      created_by
                ,      last_update_login
                ,      attribute_category
                ,      attribute1
                ,      attribute2
                ,      attribute3
                ,      attribute4
                ,      attribute5
                ,      attribute6
                ,      attribute7
                ,      attribute8
                ,      attribute9
                ,      attribute10
                ,      attribute11
                ,      attribute12
                ,      attribute13
                ,      attribute14
                ,      attribute15
    -- below column added for bug 2244929
        ,      record_version_number)
                SELECT
                       x_new_project_id
                ,      pc.class_code
                ,      pc.class_category
                ,      pc.code_percentage
                ,      x_new_project_id
                ,      'PA_PROJECTS'
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      FND_GLOBAL.LOGIN_ID
                ,      pc.attribute_category
                ,      pc.attribute1
                ,      pc.attribute2
                ,      pc.attribute3
                ,      pc.attribute4
                ,      pc.attribute5
                ,      pc.attribute6
                ,      pc.attribute7
                ,      pc.attribute8
                ,      pc.attribute9
                ,      pc.attribute10
                ,      pc.attribute11
                ,      pc.attribute12
                ,      pc.attribute13
                ,      pc.attribute14
                ,      pc.attribute15
        --below column added for bug 2244929
        ,      pc.record_version_number
                  FROM
                       pa_project_classes pc
                 WHERE pc.project_id = x_orig_project_id
                   and pc.class_category not in (select distinct
                                      limiting_value
                                      from pa_project_copy_overrides
                                      where project_id = x_created_from_proj_id
                                      and field_name = 'CLASSIFICATION');
    end if;
         -- anlee
         -- End changes

     --Bug 3279981
     --If the customer at top task flag has been enabled/diabled (NOT SAME AS SOURCE PROJECT VALUE)
     --then we need to set a default top task customer / customer with 100 % contribution
     --This customer id is retrieved in the code below
     IF x_use_override_flag = 'N' OR x_customer_id is null THEN
          DECLARE

                CURSOR cur_get_orig_tt_cust_flag IS
                SELECT enable_top_task_customer_flag
                FROM   pa_projects_all
                WHERE  project_id = x_orig_project_id;

	        --sunkalya:federal Bug#5511353

		CURSOR get_date_eff_funds_flag
		IS
		SELECT
		nvl(DATE_EFF_FUNDS_CONSUMPTION,'N')
		FROM
		pa_projects_all
		WHERE project_id = x_orig_project_id ;
		--sunkalya:federal Bug#5511353

               l_exclude_cust_id_tbl   PA_PLSQL_DATATYPES.NumTabTyp;
               l_hghst_ctr_cust_name   VARCHAR2(50);
               l_hghst_ctr_cust_num    VARCHAR2(30);
               l_return_status         VARCHAR2(10);
               l_msg_count             NUMBER;
               l_msg_data              VARCHAR2(2000);


          BEGIN

               OPEN  cur_get_orig_tt_cust_flag;
               FETCH cur_get_orig_tt_cust_flag INTO l_orig_en_top_task_cust;
               CLOSE cur_get_orig_tt_cust_flag;

	       OPEN  get_date_eff_funds_flag;
	       FETCH get_date_eff_funds_flag INTO l_orig_date_eff_funds_flag;
	       CLOSE get_date_eff_funds_flag;

               l_exclude_cust_id_tbl(1) := 0;
               IF ('Y' = p_en_top_task_cust_flag AND 'N' = l_orig_en_top_task_cust )
               OR ('N' = p_en_top_task_cust_flag AND 'Y' = l_orig_en_top_task_cust )
	       OR ('N' = p_date_eff_funds_flag   AND 'Y' = l_orig_date_eff_funds_flag) --sunkalya:federal Bug#5511353
	       OR ('Y' = p_date_eff_funds_flag   AND 'N' = l_orig_date_eff_funds_flag) --sunkalya:federal Bug#5511353
	       THEN	--sunkalya:federal	 Bug#5511353

			IF p_en_top_task_cust_flag ='Y' OR  p_date_eff_funds_flag ='Y'       THEN

				l_check_diff_flag :=	'Y';

			ELSIF  p_en_top_task_cust_flag = 'N' AND p_date_eff_funds_flag = 'N' THEN

				l_check_diff_flag :=	'N';

			ELSIF p_en_top_task_cust_flag ='N' OR p_date_eff_funds_flag ='N'     THEN

			      IF p_en_top_task_cust_flag = 'N' THEN
					IF l_orig_date_eff_funds_flag ='Y' THEN

						l_check_diff_flag :=	'Y';
					ELSE
						l_check_diff_flag :=	'N';
					END IF;
			      ELSIF p_date_eff_funds_flag ='N' THEN
					IF l_orig_en_top_task_cust ='Y' THEN

						l_check_diff_flag :=	'Y';
					ELSE
						l_check_diff_flag :=	'N';
					END IF;
			      END IF;

			END IF;
			--sunkalya:federal	 Bug#5511353

			IF (p_en_top_task_cust_flag ='N' AND l_orig_en_top_task_cust ='Y') OR
			   (p_en_top_task_cust_flag ='Y' AND l_orig_en_top_task_cust ='N')
			THEN

				pa_top_task_cust_invoice_pvt.Get_Highest_Contr_Cust(
							P_API_VERSION            => 1.0
						      , P_INIT_MSG_LIST          => 'T'
						      , P_COMMIT                 => 'F'
						      , P_VALIDATE_ONLY          => 'F'
						      , P_VALIDATION_LEVEL       => 100
						      , P_DEBUG_MODE             => 'N'
						      , p_calling_module         => 'AMG'
						      , p_project_id             => x_orig_project_id
						      , p_exclude_cust_id_tbl    => l_exclude_cust_id_tbl
						      , x_highst_contr_cust_id   => l_hghst_ctr_cust_id
						      , x_highst_contr_cust_name => l_hghst_ctr_cust_name
						      , x_highst_contr_cust_num  => l_hghst_ctr_cust_num
						      , x_return_status          => l_return_status
						      , x_msg_count              => l_msg_count
						      , x_msg_data               => l_msg_data );

			ElSIF p_date_eff_funds_flag ='N' AND l_orig_date_eff_funds_flag ='Y' THEN

				PA_CUSTOMERS_CONTACTS_UTILS.Get_Highest_Contr_Fed_Cust(
							P_API_VERSION            => 1.0
						      , P_INIT_MSG_LIST          => 'T'
						      , P_COMMIT                 => 'F'
						      , P_VALIDATE_ONLY          => 'F'
						      , P_VALIDATION_LEVEL       => 100
						      , P_DEBUG_MODE             => 'N'
						      , p_calling_module         => 'AMG'
						      , p_project_id             => x_orig_project_id
						      , x_highst_contr_cust_id   => l_hghst_ctr_cust_id
						      , x_return_status          => l_return_status
						      , x_msg_count              => l_msg_count
						      , x_msg_data               => l_msg_data );
			END IF;

			--Sunkalya:federal	Bug#5511353

                         IF  l_return_status <> 'S' THEN
                              x_err_code := 930;
                              x_err_stack   := x_err_stack||'->PA_TOP_TASK_CUST_INVOICE_PVT.GET_HIGHEST_CONTR_CUST';
                              ROLLBACK TO copy_project;
                              revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                              RETURN;
                         END IF;
               END IF;
          EXCEPTION
          WHEN OTHERS THEN
               x_err_code := 930;
               x_err_stage := 'API: '||'PA_TOP_TASK_CUST_INVOICE_PVT.GET_HIGHEST_CONTR_CUST'||
                              ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
               ROLLBACK TO copy_project;
               revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
               RETURN;
          END;
     END IF;-- IF x_use_override_flag = 'N' OR x_customer_id is null
     --Bug 3279981
     --If the customer at top task flag has been changed, the customer bill split and default top task
     --customer values need to be taken care of in the insert for pa_project_customers

    if ( x_use_override_flag = 'N' ) then

             -- Copy all project customers from original project
            x_err_stage := 'copying project customers not using override';

                INSERT INTO pa_project_customers (
                       project_id
                ,      customer_id
                ,      last_update_date
                ,      last_updated_by
                ,      creation_date
                ,      created_by
                ,      last_update_login
        ,      project_relationship_code
        ,      customer_bill_split
        ,      bill_to_address_id
        ,      ship_to_address_id
                ,      inv_currency_code
                ,      inv_rate_type
                ,      inv_rate_date
                ,      inv_exchange_rate
                ,      allow_inv_user_rate_type_flag
                ,      bill_another_project_flag
                ,      receiver_task_id
                ,      retention_level_code
                ,      record_version_number
     -- Customer Account Relationships changes
                ,      bill_to_customer_id
                ,      ship_to_customer_id
     -- Customer Account Relationships  changes
                --Added for bug 3279981
                ,      default_top_task_cust_flag )
                SELECT
                       x_new_project_id
                ,      cust.customer_id
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      FND_GLOBAL.LOGIN_ID
        ,      cust.project_relationship_code
        --Bug 3279981
          --,      cust.customer_bill_split
          ,      decode(l_check_diff_flag,						--sunkalya:federal Bug#5511353
                        NULL , cust.customer_bill_split ,
                        'Y', null ,
                        'N', decode(l_hghst_ctr_cust_id, cust.customer_id, 100, 0),
                        cust.customer_bill_split )
        ,      cust.bill_to_address_id
        ,      cust.ship_to_address_id
                ,      cust.inv_currency_code
                ,      cust.inv_rate_type
                ,      cust.inv_rate_date
                ,      cust.inv_exchange_rate
                ,      cust.allow_inv_user_rate_type_flag
                ,      cust.bill_another_project_flag
                ,      cust.receiver_task_id
                ,      cust.retention_level_code
                ,      1
 -- Customer Account Relationships changes
                ,      bill_to_customer_id
                ,      ship_to_customer_id
 -- Customer Account Relationships  changes
                --Added for bug 3279981
                ,      decode(p_en_top_task_cust_flag,
                              l_orig_en_top_task_cust, cust.default_top_task_cust_flag,
                              'Y', decode(l_hghst_ctr_cust_id, cust.customer_id, 'Y', 'N'),
                              'N','N',
                              cust.default_top_task_cust_flag
                             )
                  FROM
                       pa_project_customers cust
                 WHERE cust.project_id = x_orig_project_id;

           -- anlee org role changes
           -- create a project party if the added customer is an organization
           DECLARE
              l_party_id                      NUMBER;
              l_project_party_id              NUMBER;
              l_resource_id                   NUMBER;
              l_wf_item_type                  VARCHAR2(30);
              l_wf_type                       VARCHAR2(30);
              l_wf_party_process              VARCHAR2(30);
              l_assignment_id                 NUMBER;
              l_return_status                 VARCHAR2(1);
              l_msg_data                      VARCHAR2(2000);
              l_msg_count                     NUMBER;
              l_end_date_active               DATE;
              l_customer_id                   NUMBER;

              CURSOR l_customers_csr (c_project_id IN NUMBER) IS
              SELECT customer_id
              FROM   PA_PROJECT_CUSTOMERS
              WHERE  project_id = c_project_id;

              CURSOR l_check_org_csr (c_customer_id IN NUMBER) IS
              SELECT PARTY_ID
              FROM PA_CUSTOMERS_V
              WHERE CUSTOMER_ID = c_customer_id
              AND   PARTY_TYPE = 'ORGANIZATION';
           BEGIN

              OPEN l_customers_csr(x_orig_project_id);
              LOOP
                FETCH l_customers_csr INTO l_customer_id;
                EXIT WHEN l_customers_csr%NOTFOUND;

                l_party_id := null;
                l_project_party_id := null;
                OPEN l_check_org_csr(l_customer_id);
                FETCH l_check_org_csr INTO l_party_id;
                IF l_check_org_csr%NOTFOUND then
                  l_party_id := null;
                END IF;
                CLOSE l_check_org_csr;

                if l_party_id is not null then

                  PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
                    p_validate_only              => FND_API.G_FALSE
                  , p_object_id                  => x_new_project_id
                  , p_OBJECT_TYPE                => 'PA_PROJECTS'
                  , p_project_role_id            => 100
                  , p_project_role_type          => 'CUSTOMER_ORG'
                  , p_RESOURCE_TYPE_ID           => 112
                  , p_resource_source_id         => l_party_id
                  , p_start_date_active          => null
                  , p_calling_module             => 'FORM'
                  , p_project_id                 => x_new_project_id
                  , p_project_end_date           => null
                  , p_end_date_active            => l_end_date_active
                  , x_project_party_id           => l_project_party_id
                  , x_resource_id                => l_resource_id
                  , x_wf_item_type               => l_wf_item_type
                  , x_wf_type                    => l_wf_type
                  , x_wf_process                 => l_wf_party_process
                  , x_assignment_id              => l_assignment_id
                  , x_return_status              => l_return_status
                  , x_msg_count                  => l_msg_count
                  , x_msg_data                   => l_msg_data );

                  IF (l_return_status <> 'S') Then

                    rollback to copy_project;
                    revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                    x_err_code := 167;
                    x_err_stage   := pa_project_core1.get_message_from_stack( 'PA_ERR_CR_PROJ_PARTY_PUB');
                    x_err_stack   := x_err_stack||'->PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY';
                    return;
                  END IF;

                  -- Add the new project party ID to the customers row
                  UPDATE PA_PROJECT_CUSTOMERS
                  SET project_party_id = l_project_party_id
                  WHERE project_id = x_new_project_id
                  AND customer_id = l_customer_id;
                end if;
              end loop;
              CLOSE l_customers_csr;  --Bug 3905797

            EXCEPTION WHEN OTHERS THEN
              x_err_code := 167;
--              x_err_stage := pa_project_core1.get_message_from_stack( null );
--              IF x_err_stage IS NULL
--              THEN
                x_err_stage := 'API: '||'PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY'||' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--              END IF;
              rollback to copy_project;
              revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
              return;
            END;

    elsif x_customer_id is null then --Bug 2984536. This api is except in case of org forecast project copy is always
                                      -- called with the x_use_override_flag as Y. Now we will do different processing
                                      -- depending on if customer has passed the customer id thru quick entry.

            -- Copy only project customers with relationship code that
            -- are not overrideable.  The other customers can be entered
            -- using Enter Project form.
            x_err_stage := 'copying project customers using override';

/* Commented for bug 2984536. Need to do processing for each of the customer before copying
   into the target project.
                INSERT INTO pa_project_customers (
                       project_id
                ,      customer_id
                ,      last_update_date
                ,      last_updated_by
                ,      creation_date
                ,      created_by
                ,      last_update_login
                ,      project_relationship_code
                ,      customer_bill_split
                ,      bill_to_address_id
                ,      ship_to_address_id
                ,      inv_currency_code
                ,      inv_rate_type
                ,      inv_rate_date
                ,      inv_exchange_rate
                ,      allow_inv_user_rate_type_flag
                ,      bill_another_project_flag
                ,      receiver_task_id
                ,      record_version_number
    ---Customer Account Relationship
                ,      bill_to_customer_id
                ,      ship_to_customer_id)
    ---Customer Account Relationship

                SELECT
                       x_new_project_id
                ,      cust.customer_id
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      FND_GLOBAL.LOGIN_ID
                ,      cust.project_relationship_code
                ,      cust.customer_bill_split
                ,      cust.bill_to_address_id
                ,      cust.ship_to_address_id
                ,      cust.inv_currency_code
                ,      cust.inv_rate_type
                ,      cust.inv_rate_date
                ,      cust.inv_exchange_rate
                ,      cust.allow_inv_user_rate_type_flag
                ,      cust.bill_another_project_flag
                ,      cust.receiver_task_id
                ,      1
 ---Customer Account Relationship
                ,      cust.bill_to_customer_id
                ,      cust.ship_to_customer_id
 ---Customer Account Relationship
                  FROM
                       pa_project_customers cust
                 WHERE cust.project_id = x_orig_project_id
                   and not exists
                                (select null
                                      from pa_project_copy_overrides
                                      where project_id = x_created_from_proj_id
                                      and field_name = 'CUSTOMER_NAME');
*/

          -- Bug  2984536. This processing is done only if no customer id is passed as input.
          -- Fetch all the customers for the source project. Call get_customer_info to obtain the
          -- Valid customer details. Use this info thus obtained to insert a customer record.
          DECLARE
               -- Define the cursor to fetch the customer details from the source.
                CURSOR cur_cust_info(c_project_id pa_projects_all.project_id%TYPE,
                             c_created_from_proj_id pa_projects_all.project_id%TYPE ) IS -- Added the parameter for bug 3726109
                SELECT
                       cust.customer_id
                ,      cust.project_relationship_code
                ,      cust.customer_bill_split
                ,      cust.bill_to_address_id
                ,      cust.ship_to_address_id
                ,      cust.inv_currency_code
                ,      cust.inv_rate_type
                ,      cust.inv_rate_date
                ,      cust.inv_exchange_rate
                ,      cust.allow_inv_user_rate_type_flag
                ,      cust.bill_another_project_flag
                ,      cust.receiver_task_id
                ,      cust.bill_to_customer_id
                ,      cust.ship_to_customer_id
                ,      cust.default_top_task_cust_flag
                  FROM
                       pa_project_customers cust
                 WHERE cust.project_id = c_project_id
                 and not exists                       -- Added the and condition for bug 3726109
                              (select null
                                    from pa_project_copy_overrides
                                    where project_id = c_created_from_proj_id
                                    and field_name = 'CUSTOMER_NAME');
--CURSORS BELOW ADDED BY ADITI for Bug 3110489 Code Change Begins
                CURSOR cur_contact_info(c_project_id pa_projects_all.project_id%TYPE,
                             c_created_from_proj_id pa_projects_all.project_id%TYPE,
                 c_customer_id  pa_project_customers.customer_id%TYPE)
        IS
        select contact.customer_id,
                       contact.contact_id,
                   contact.project_contact_type_code,
                   contact.bill_ship_customer_id
           from pa_project_contacts contact
               where contact.project_id = c_project_id
               and not exists
                              (select null
                                    from pa_project_copy_overrides
                                    where project_id = c_created_from_proj_id
                                    and field_name = 'CUSTOMER_NAME')
                 and contact.customer_id = c_customer_id;

         CURSOR cur_cust_override_exists (c_created_from_proj_id pa_projects_all.project_id%TYPE )
         IS
          select 'Y'
                                    from pa_project_copy_overrides
                                    where project_id = c_created_from_proj_id
                                    and field_name = 'CUSTOMER_NAME';
   /** Code Change for Bug 3110489 ends **/
                 l_cur_cust_info           cur_cust_info%rowtype;
		 l_cur_contact_info        cur_contact_info%rowtype;
                 l_bill_to_contact_id      pa_project_contacts.contact_id%TYPE;
                 l_ship_to_contact_id      pa_project_contacts.contact_id%TYPE;
		 l_copy_bill_to_contact_id      pa_project_contacts.contact_id%TYPE; --Added for BUg 3110489
                 l_copy_ship_to_contact_id      pa_project_contacts.contact_id%TYPE; --Added for BUg 3110489
                 l_dummy       VARCHAR2(1); --Added for BUg 3110489


		 /*The following parameter is_contact_present_flag is added for Bug#4770535 for get_customer_info not
		 getting called unnecessarily second time when contact exist for the customer. */
			is_contact_present_flag VARCHAR2(1):= 'N';
		 -- End of change For Bug#4770535

          BEGIN

               -- obtain the customer info from the source.
           /* Addded one more parameter x_created_from_proj_id to the cursor for bug 3726109 */
               OPEN cur_cust_info(x_orig_project_id, x_created_from_proj_id);
               Loop
			--Bug#4770535 The following two parameters are initialized to null
				l_copy_bill_to_contact_id := NULL;
				l_copy_ship_to_contact_id := NULL;
			--End of Change for Bug#4770535

                    Fetch cur_cust_info into l_cur_cust_info;

                    EXIT WHEN cur_cust_info%NOTFOUND;
		    -- Made the flag is_contact_present_flag 'N' so that it gets set evertime the cur_cust_info loop runs for Bug#4770535
		    is_contact_present_flag := 'N';
		    -- End of change done for Bug#4770535

            /** CODE ADDED BY ADITI for BUg 3110489 This code is added to cppy the contacts from
            the source project to target project **/
            OPEN cur_contact_info(x_orig_project_id, x_created_from_proj_id,l_cur_cust_info.customer_id);
            Loop
            /** Variables are initialised to null at the beginning of the loop
               so that only one record gets inserted at a time and primary
               key violations do not occur **/

	     /*Bug#4770535. parameters to l_bill_to_contact_id ,l_ship_to_contact_id ,l_copy_bill_to_contact_id,
	     l_copy_ship_to_contact_idare  set to NULL so that no primary key violations occur */
		l_bill_to_contact_id   :=    NULL;
		l_ship_to_contact_id   :=    NULL;
		l_copy_bill_to_contact_id := NULL;
		l_copy_ship_to_contact_id := NULL;

	     --End of changes for Bug#4770535

            FETCH cur_contact_info INTO l_cur_contact_info;
            EXIT when  cur_contact_info%NOTFOUND;

	    --Set the is_contact_present_flag to Y as the contact exists for this customer.Bug#4770535
		is_contact_present_flag := 'Y';
	    --End of change for Bug#4770535

             IF l_cur_contact_info.project_contact_type_code = 'BILLING' THEN

	             -- Bug#4770535. Added l_bill_to_contact_id also which will be used below in get_customer_info
				l_bill_to_contact_id      := l_cur_contact_info.CONTACT_ID;
				l_copy_bill_to_contact_id := l_cur_contact_info.CONTACT_ID;
		     -- End of change for Bug#4770535



             ELSIF l_cur_contact_info.project_contact_type_code = 'SHIPPING' THEN

		      --Bug#4770535.Added l_ship_to_contact_id also which will be used below in get_customer_info
				l_ship_to_contact_id      := l_cur_contact_info.CONTACT_ID;
				l_copy_ship_to_contact_id := l_cur_contact_info.CONTACT_ID;
		      --End of change for Bug#4770535


             END if;

              /** CODE changes END for Bug 3110489 **/


		/*Bug#4770535.Instead of passing l_copy_bill_to_contact_id and l_copy_ship_to_contact_id, now
		l_bill_to_contact_id and l_ship_to_contact_id are being passed.*/
                    pa_customer_info.Get_Customer_Info
                     ( X_project_ID                        => x_new_project_id,
                       X_Customer_Id                       => l_cur_cust_info.customer_id,
                       p_quick_entry_flag                  => 'N',
                       X_Bill_To_Customer_Id               => l_cur_cust_info.bill_to_customer_id,
                       X_Ship_To_Customer_Id               => l_cur_cust_info.ship_to_customer_id,
                       X_Bill_To_Address_Id                => l_cur_cust_info.bill_to_address_id,
                       X_Ship_To_Address_Id                => l_cur_cust_info.ship_to_address_id,
                       X_Bill_To_Contact_Id                => l_bill_to_contact_id,
                       X_Ship_To_Contact_Id                => l_ship_to_contact_id,
                       X_Err_Code                          => x_err_code,
                       X_Err_Stage                         => x_err_stage,
                       X_Err_Stack                         => x_err_stack
                     );
                    IF x_err_code <> 0
                    THEN
                        rollback to copy_project;
                        revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534

                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                            IF NOT pa_project_pvt.check_valid_message(x_err_stage)
                            THEN
                                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                     p_msg_name       =>
                                                     'PA_GET_CUSTOMER_INFO_FAILED');
                             ELSE
                                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                    p_msg_name       => x_err_stage);
                             END IF;
                        END IF;
                        return;
                    END IF;

                    --Added for bug 3279981
                    --If the default top task customer flag is NOT THE SAME AS IN THE SOURCE PROJECT,
                    --the customer bill split and default top task customer flag values need to be taken care of
			--sunkalya:federal changes****** Bug#5511353

			IF		  ('Y' = p_en_top_task_cust_flag AND 'N' = l_orig_en_top_task_cust )
				       OR ('N' = p_en_top_task_cust_flag AND 'Y' = l_orig_en_top_task_cust )
				       OR ('N' = p_date_eff_funds_flag   AND 'Y' = l_orig_date_eff_funds_flag)
				       OR ('Y' = p_date_eff_funds_flag   AND 'N' = l_orig_date_eff_funds_flag)
			THEN

						IF p_en_top_task_cust_flag ='Y' OR  p_date_eff_funds_flag ='Y'       THEN   --case #1


							l_cur_cust_info.customer_bill_split := NULL;

							IF ( 'Y' = p_en_top_task_cust_flag ) THEN

								IF l_hghst_ctr_cust_id = l_cur_cust_info.customer_id THEN

									l_cur_cust_info.default_top_task_cust_flag := 'Y';

								ELSE

									l_cur_cust_info.default_top_task_cust_flag := 'N';

								END IF;

							END IF;

						ELSIF  p_en_top_task_cust_flag = 'N' AND p_date_eff_funds_flag = 'N' THEN    --case #2

							IF l_hghst_ctr_cust_id = l_cur_cust_info.customer_id THEN

								l_cur_cust_info.customer_bill_split := 100;

							ELSE

								l_cur_cust_info.customer_bill_split := 0;

							END IF;

							l_cur_cust_info.default_top_task_cust_flag := 'N';


						ELSIF p_en_top_task_cust_flag ='N' OR p_date_eff_funds_flag ='N'     THEN    --case #3.When one of the flag
															     --Is Only passed and the other as null.

							IF p_en_top_task_cust_flag = 'N' THEN

								IF l_orig_date_eff_funds_flag ='Y' THEN

									l_cur_cust_info.default_top_task_cust_flag := 'N';

								ELSE

									IF l_hghst_ctr_cust_id = l_cur_cust_info.customer_id THEN

										l_cur_cust_info.customer_bill_split := 100;

									ELSE

										l_cur_cust_info.customer_bill_split := 0;

									END IF;
									l_cur_cust_info.default_top_task_cust_flag := 'N';

								END IF;

							ELSIF p_date_eff_funds_flag ='N' THEN

								IF l_orig_en_top_task_cust ='N' THEN

									IF l_hghst_ctr_cust_id = l_cur_cust_info.customer_id THEN

										l_cur_cust_info.customer_bill_split := 100;

									ELSE

										l_cur_cust_info.customer_bill_split := 0;

									END IF;
									l_cur_cust_info.default_top_task_cust_flag := 'N';

								END IF;
							END IF;

						END IF;
			END IF;
			--sunkalya:federal changes*****

--   insert the project customer record.

--Added the following if conditions for Bug#4770535.If there is no billing or shipping contact for this customer,
--we should not copy the values returned from get_customer_info by mistake as it gives the contact at primary site.


		IF (l_copy_bill_to_contact_id IS NULL OR l_copy_bill_to_contact_id= FND_API.G_MISS_NUM) THEN
		    l_bill_to_contact_id := NULL;
		END IF;

                IF (l_copy_ship_to_contact_id IS NULL OR l_copy_ship_to_contact_id = FND_API.G_MISS_NUM) THEN
		    l_ship_to_contact_id := NULL;
		END IF;


/*Bug#4770535 changed the variables l_copy_bill_to_contact_id and l_copy_ship_to_contact_id to l_bill_to_contact_id and
 l_ship_to_contact_id respectively which are passed below into Create_Customer_Contacts. */


                    pa_customer_info.Create_Customer_Contacts
                       ( X_Project_Id                  => x_new_project_id,
                         X_Customer_Id                 => l_cur_cust_info.customer_id,
                         X_Project_Relation_Code       => l_cur_cust_info.project_relationship_code,
                         X_Customer_Bill_Split         => l_cur_cust_info.customer_bill_split,
                         X_Bill_To_Customer_Id         => l_cur_cust_info.bill_to_customer_id,
                         X_Ship_To_Customer_Id         => l_cur_cust_info.ship_to_customer_id,
                         X_Bill_To_Address_Id          => l_cur_cust_info.bill_to_address_id,
                         X_Ship_To_Address_Id          => l_cur_cust_info.ship_to_address_id,
                         X_Bill_To_Contact_Id          => l_bill_to_contact_id, --Bug#4770535
                         X_Ship_To_Contact_Id          => l_ship_to_contact_id, --Bug#4770535
                         X_Inv_Currency_Code           => l_cur_cust_info.inv_currency_code,
                         X_Inv_Rate_Type               => l_cur_cust_info.inv_rate_type,
                         X_Inv_Rate_Date               => l_cur_cust_info.inv_rate_date,
                         X_Inv_Exchange_Rate           => l_cur_cust_info.inv_exchange_rate,
                         X_Allow_Inv_Rate_Type_Fg      => l_cur_cust_info.allow_inv_user_rate_type_flag,
                         X_Bill_Another_Project_Fg     => l_cur_cust_info.bill_another_project_flag,
                         X_Receiver_Task_Id            => l_cur_cust_info.receiver_task_id,
                         P_default_top_task_customer   => l_cur_cust_info.default_top_task_cust_flag,
                         X_User                        => FND_GLOBAL.USER_ID,
                         X_Login                       => FND_GLOBAL.LOGIN_ID,
                         X_Err_Code                    => x_err_code,
                         X_Err_Stage                   => x_err_stage,
                         X_Err_Stack                   => x_err_stack
                       );
                     IF x_err_code > 0
                     THEN
                         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                         THEN
                             IF NOT pa_project_pvt.check_valid_message(x_err_stage)
                             THEN
                                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name      => 'PA_PROJ_CR_CONTACTS_FAILED');
                             ELSE
                                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => x_err_stage);
                             END IF;
                             rollback to copy_project;
                             revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                             return;
                          END IF;

                     ELSIF x_err_code < 0
                     THEN
                           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                p_msg_name       => 'PA_PROJ_CR_CONTACTS_FAILED');
                           rollback to copy_project;
                           revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                           return;
                       END IF;


            End Loop; -- End of Loop for cur_contact_info Bug 3110489
           CLOSE cur_contact_info; --Added for Bug 3110489

  /** The code written above is copied below. This is to facilitate the case when the source
   project has a customer, but no contacts. Added for Bug 3110489 **/

  /* Added the below IF condition for Bug#4770535. The call to get_customer_info API below should be executed only when
   there are no contact to the customer. The IF condition added below checks for this condition and eliminates unconditional call to
   get_customer_info. */

IF( is_contact_present_flag = 'N') THEN


	/*Bug#4770535. Always pass null in place of X_Bill_To_Contact_Id and X_Ship_To_Contact_Id below
	 as in this case no contact exists for this customer. Also as they are IN OUT parameters inside get_customer_info,
	 we need to reset them*/

	l_bill_to_contact_id := null;
	l_ship_to_contact_id := null;
                     pa_customer_info.Get_Customer_Info
                     ( X_project_ID                        => x_new_project_id,
                       X_Customer_Id                       => l_cur_cust_info.customer_id,
                       p_quick_entry_flag                  => 'N',
                       X_Bill_To_Customer_Id               => l_cur_cust_info.bill_to_customer_id,
                       X_Ship_To_Customer_Id               => l_cur_cust_info.ship_to_customer_id,
                       X_Bill_To_Address_Id                => l_cur_cust_info.bill_to_address_id,
                       X_Ship_To_Address_Id                => l_cur_cust_info.ship_to_address_id,
                       X_Bill_To_Contact_Id                => l_bill_to_contact_id,
                       X_Ship_To_Contact_Id                => l_ship_to_contact_id,
                       X_Err_Code                          => x_err_code,
                       X_Err_Stage                         => x_err_stage,
                       X_Err_Stack                         => x_err_stack
                     );

                    IF x_err_code <> 0
                    THEN
                        rollback to copy_project;
                        revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534

                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                            IF NOT pa_project_pvt.check_valid_message(x_err_stage)
                            THEN
                                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                     p_msg_name       =>
                                                     'PA_GET_CUSTOMER_INFO_FAILED');
                             ELSE
                                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                    p_msg_name       => x_err_stage);
                             END IF;
                        END IF;
                        return;
                    END IF;


                    --Added for bug 3279981
                    --If the default top task customer flag is NOT THE SAME AS IN THE SOURCE PROJECT,
                    --the customer bill split and default top task customer flag values need to be taken care of
                   --sunkalya:federal changes****** Bug#5511353

			IF		  ('Y' = p_en_top_task_cust_flag AND 'N' = l_orig_en_top_task_cust )
				       OR ('N' = p_en_top_task_cust_flag AND 'Y' = l_orig_en_top_task_cust )
				       OR ('N' = p_date_eff_funds_flag   AND 'Y' = l_orig_date_eff_funds_flag)
				       OR ('Y' = p_date_eff_funds_flag   AND 'N' = l_orig_date_eff_funds_flag)
			THEN

						IF p_en_top_task_cust_flag ='Y' OR  p_date_eff_funds_flag ='Y'       THEN   --case #1


							l_cur_cust_info.customer_bill_split := NULL;

							IF ( 'Y' = p_en_top_task_cust_flag ) THEN

								IF l_hghst_ctr_cust_id = l_cur_cust_info.customer_id THEN

									l_cur_cust_info.default_top_task_cust_flag := 'Y';

								ELSE

									l_cur_cust_info.default_top_task_cust_flag := 'N';

								END IF;

							END IF;

						ELSIF  p_en_top_task_cust_flag = 'N' AND p_date_eff_funds_flag = 'N' THEN    --case #2

							IF l_hghst_ctr_cust_id = l_cur_cust_info.customer_id THEN

								l_cur_cust_info.customer_bill_split := 100;

							ELSE

								l_cur_cust_info.customer_bill_split := 0;

							END IF;

							l_cur_cust_info.default_top_task_cust_flag := 'N';


						ELSIF p_en_top_task_cust_flag ='N' OR p_date_eff_funds_flag ='N'     THEN    --case #3.When one of the flag
															     --Is Only passed and the other as null.

							IF p_en_top_task_cust_flag = 'N' THEN

								IF l_orig_date_eff_funds_flag ='Y' THEN

									l_cur_cust_info.default_top_task_cust_flag := 'N';

								ELSE

									IF l_hghst_ctr_cust_id = l_cur_cust_info.customer_id THEN

										l_cur_cust_info.customer_bill_split := 100;

									ELSE

										l_cur_cust_info.customer_bill_split := 0;

									END IF;
									l_cur_cust_info.default_top_task_cust_flag := 'N';

								END IF;

							ELSIF p_date_eff_funds_flag ='N' THEN

								IF l_orig_en_top_task_cust ='N' THEN

									IF l_hghst_ctr_cust_id = l_cur_cust_info.customer_id THEN

										l_cur_cust_info.customer_bill_split := 100;

									ELSE

										l_cur_cust_info.customer_bill_split := 0;

									END IF;
									l_cur_cust_info.default_top_task_cust_flag := 'N';

								END IF;
							END IF;

						END IF;
			END IF;
			--sunkalya:federal changes*****



--   insert the project customer record.

l_bill_to_contact_id := null;  --Bug#4770535 always pass NULL for bill to and ship to contact ids as
			       --there are no contacts for the customer and by mistake we should not copy the
			       --contact returned by get_customer_info aboove as it will return contact at primary site.
l_ship_to_contact_id := null;

                    pa_customer_info.Create_Customer_Contacts
                       ( X_Project_Id                  => x_new_project_id,
                         X_Customer_Id                 => l_cur_cust_info.customer_id,
                         X_Project_Relation_Code       => l_cur_cust_info.project_relationship_code,
                         X_Customer_Bill_Split         => l_cur_cust_info.customer_bill_split,
                         X_Bill_To_Customer_Id         => l_cur_cust_info.bill_to_customer_id,
                         X_Ship_To_Customer_Id         => l_cur_cust_info.ship_to_customer_id,
                         X_Bill_To_Address_Id          => l_cur_cust_info.bill_to_address_id,
                         X_Ship_To_Address_Id          => l_cur_cust_info.ship_to_address_id,
                         X_Bill_To_Contact_Id          => l_bill_to_contact_id,
                         X_Ship_To_Contact_Id          => l_ship_to_contact_id,
                         X_Inv_Currency_Code           => l_cur_cust_info.inv_currency_code,
                         X_Inv_Rate_Type               => l_cur_cust_info.inv_rate_type,
                         X_Inv_Rate_Date               => l_cur_cust_info.inv_rate_date,
                         X_Inv_Exchange_Rate           => l_cur_cust_info.inv_exchange_rate,
                         X_Allow_Inv_Rate_Type_Fg      => l_cur_cust_info.allow_inv_user_rate_type_flag,
                         X_Bill_Another_Project_Fg     => l_cur_cust_info.bill_another_project_flag,
                         X_Receiver_Task_Id            => l_cur_cust_info.receiver_task_id,
                         P_default_top_task_customer   => l_cur_cust_info.default_top_task_cust_flag,
                         X_User                        => FND_GLOBAL.USER_ID,
                         X_Login                       => FND_GLOBAL.LOGIN_ID,
                         X_Err_Code                    => x_err_code,
                         X_Err_Stage                   => x_err_stage,
                         X_Err_Stack                   => x_err_stack
                       );
                     IF x_err_code > 0
                     THEN
                         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                         THEN
                             IF NOT pa_project_pvt.check_valid_message(x_err_stage)
                             THEN
                                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name      => 'PA_PROJ_CR_CONTACTS_FAILED');
                             ELSE
                                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => x_err_stage);
                             END IF;
                             rollback to copy_project;
                             revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                             return;
                          END IF;

                     ELSIF x_err_code < 0
                     THEN
                           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                                p_msg_name       => 'PA_PROJ_CR_CONTACTS_FAILED');
                           rollback to copy_project;
                           revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                           return;
                       END IF;
/** End of code change for Bug 3110489 **/

END IF; -- if is_contact_present_flag = 'N'
               END Loop;
               CLOSE cur_cust_info;  --Bug 3905797
          END;

            -- anlee org role changes
           -- create a project party if the added customer is an organization
           DECLARE
              l_party_id                      NUMBER;
              l_project_party_id              NUMBER;
              l_resource_id                   NUMBER;
              l_wf_item_type                  VARCHAR2(30);
              l_wf_type                       VARCHAR2(30);
              l_wf_party_process              VARCHAR2(30);
              l_assignment_id                 NUMBER;
              l_return_status                 VARCHAR2(1);
              l_msg_data                      VARCHAR2(2000);
              l_msg_count                     NUMBER;
              l_end_date_active               DATE;
              l_customer_id                   NUMBER;

              CURSOR l_customers_csr (c_project_id IN NUMBER) IS
              SELECT customer_id
              FROM   PA_PROJECT_CUSTOMERS
              WHERE  project_id = c_project_id
              AND not exists
                      (select null
                       from pa_project_copy_overrides
                       where project_id = x_created_from_proj_id
                       and field_name = 'CUSTOMER_NAME');

              CURSOR l_check_org_csr (c_customer_id IN NUMBER) IS
              SELECT PARTY_ID
              FROM PA_CUSTOMERS_V
              WHERE CUSTOMER_ID = c_customer_id
              AND   PARTY_TYPE = 'ORGANIZATION';
           BEGIN
              -- Bug 2984536. The customer records are created only if x_customer_id is null. Dont do processing
              -- for project parties if x_customer_id is not null. Included this condition as the cursor doesnot take
              -- care of this.
              If x_customer_id is null THEN
              OPEN l_customers_csr(x_orig_project_id);
              LOOP
                FETCH l_customers_csr INTO l_customer_id;
                EXIT WHEN l_customers_csr%NOTFOUND;

                l_party_id := null;
                l_project_party_id := null;
                OPEN l_check_org_csr(l_customer_id);
                FETCH l_check_org_csr INTO l_party_id;
                IF l_check_org_csr%NOTFOUND then
                  l_party_id := null;
                END IF;
                CLOSE l_check_org_csr;

                if l_party_id is not null then

                  PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
                    p_validate_only              => FND_API.G_FALSE
                  , p_object_id                  => x_new_project_id
                  , p_OBJECT_TYPE                => 'PA_PROJECTS'
                  , p_project_role_id            => 100
                  , p_project_role_type          => 'CUSTOMER_ORG'
                  , p_RESOURCE_TYPE_ID           => 112
                  , p_resource_source_id         => l_party_id
                  , p_start_date_active          => null
                  , p_calling_module             => 'FORM'
                  , p_project_id                 => x_new_project_id
                  , p_project_end_date           => null
                  , p_end_date_active            => l_end_date_active
                  , x_project_party_id           => l_project_party_id
                  , x_resource_id                => l_resource_id
                  , x_wf_item_type               => l_wf_item_type
                  , x_wf_type                    => l_wf_type
                  , x_wf_process                 => l_wf_party_process
                  , x_assignment_id              => l_assignment_id
                  , x_return_status              => l_return_status
                  , x_msg_count                  => l_msg_count
                  , x_msg_data                   => l_msg_data );

                  IF (l_return_status <> 'S') Then

                    rollback to copy_project;
                    revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                    x_err_code := 168;
                    x_err_stage   := pa_project_core1.get_message_from_stack( 'PA_ERR_CR_PROJ_PARTY_PUB');
                    x_err_stack   := x_err_stack||'->PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY';
                    return;
                  END IF;

                  -- Add the new project party ID to the customers row
                  UPDATE PA_PROJECT_CUSTOMERS
                  SET project_party_id = l_project_party_id
                  WHERE project_id = x_new_project_id
                  AND customer_id = l_customer_id;
                end if;
              end loop;
              CLOSE l_customers_csr;  --Bug 3905797
              End if; -- -- Bug 2984536.

            EXCEPTION WHEN OTHERS THEN
              x_err_code := 168;
--              x_err_stage := pa_project_core1.get_message_from_stack( null );
--              IF x_err_stage IS NULL
--              THEN
                x_err_stage := 'API: '||'PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY'||' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--              END IF;
              rollback to copy_project;
              revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
              return;
            END;

    end if;

    if ( x_use_override_flag = 'N' ) then

                x_err_stage := 'copying all billing contacts ';

                INSERT INTO pa_project_contacts (
                       project_id
                ,      customer_id
                ,      contact_id
        ,      project_contact_type_code
                ,      last_update_date
                ,      last_updated_by
                ,      creation_date
                ,      created_by
                ,      last_update_login
                ,      record_version_number
-- Customer Account relationships
                ,      bill_ship_customer_id)
                SELECT
                       x_new_project_id
                ,      c.customer_id
                ,      c.contact_id
        ,      c.project_contact_type_code
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      FND_GLOBAL.LOGIN_ID
                ,      1
-- Customer Account relationships
                ,      c.bill_ship_customer_id
                  FROM
                       pa_project_contacts c
                 WHERE c.project_id = x_orig_project_id
           and c.customer_id in
            (select customer_id from pa_project_customers
             where project_id = x_new_project_id);
    else

                x_err_stage := 'copying billing contacts using overrides';
      -- Bug 2984536 - Commenting the following piece of code. The billing contacts are
      -- copied along with the creation of the project customers. This is commented here
      -- so as not to copy wrong contact details, if the bill to customer gets changed due to the
      -- relationship code.

      -- Bug 8415966 - skkoppul uncommented the insert statement below to create
      --               customer contacts of types other than predefined types
      --               (BILLING, SHIPPING) while creating a project using 'Copy To' option.
               INSERT INTO pa_project_contacts (
                       project_id
                ,      customer_id
                ,      contact_id
                ,      project_contact_type_code
                ,      last_update_date
                ,      last_updated_by
                ,      creation_date
                ,      created_by
                ,      last_update_login
                ,      record_version_number
                     -- Customer Account relationships
                ,      bill_ship_customer_id)

                SELECT
                       x_new_project_id
                ,      c.customer_id
                ,      c.contact_id
                ,      c.project_contact_type_code
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      FND_GLOBAL.LOGIN_ID
                ,      1
                    -- Customer Account relationships
                ,      c.bill_ship_customer_id

                  FROM
                       pa_project_customers cust,
                       pa_project_contacts c
                 WHERE c.project_id = x_orig_project_id
                   and c.project_contact_type_code NOT IN ('BILLING','SHIPPING') -- added for bug 8415966
                   and c.customer_id in
                           (select customer_id from pa_project_customers
                            where project_id = x_new_project_id)
                   and c.project_id = cust.project_id
                   and c.customer_id = cust.customer_id
                   and not exists
                                (select null
                                    from pa_project_copy_overrides
                                    where project_id = x_created_from_proj_id
                                    and field_name = 'CUSTOMER_NAME');

    end if;


        x_err_stage := 'copying cost distribution override ';

--Below code added for selective copy project. Tracking Bug No. 3464332
            OPEN  cur_get_flag('FN_COST_BILL_OVERRIDES_FLAG');
            FETCH cur_get_flag INTO l_fn_cb_overrides_flag;
            CLOSE cur_get_flag;

            IF 'Y' = l_fn_cb_overrides_flag THEN
               INSERT INTO pa_cost_dist_overrides (
               COST_DISTRIBUTION_OVERRIDE_ID
        ,      project_id
        ,      OVERRIDE_TO_ORGANIZATION_ID
                ,      start_date_active
                ,      last_update_date
                ,      last_updated_by
                ,      creation_date
                ,      created_by
                ,      last_update_login
        ,      person_id
        ,      EXPENDITURE_CATEGORY
        ,      OVERRIDE_FROM_ORGANIZATION_ID
        ,      END_DATE_ACTIVE)
                SELECT
               pa_cost_dist_overrides_s.nextval
                ,      x_new_project_id
                ,      OVERRIDE_TO_ORGANIZATION_ID
                ,      decode(x_delta, null, x_start_date,
                                        start_date_active + x_delta)
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      FND_GLOBAL.LOGIN_ID
                ,      person_id
                ,      EXPENDITURE_CATEGORY
                ,      OVERRIDE_FROM_ORGANIZATION_ID
                ,      decode(x_delta, null, x_completion_date,
                                        end_date_active + x_delta)
                  FROM
                       pa_cost_dist_overrides
                 WHERE project_id = x_orig_project_id;
            END IF;

        x_err_stage := 'copying credit receivers ';

                INSERT INTO pa_credit_receivers (
                       PERSON_ID
        ,      CREDIT_TYPE_CODE
                ,      project_id
                ,      last_update_date
                ,      last_updated_by
                ,      creation_date
                ,      created_by
                ,      last_update_login
        ,      START_DATE_ACTIVE
        ,      CREDIT_PERCENTAGE
                ,      END_DATE_ACTIVE
        ,      TRANSFER_TO_AR_FLAG
                ,      CREDIT_RECEIVER_ID
                ,      RECORD_VERSION_NUMBER
        ,      SALESREP_ID)
                SELECT
                       PERSON_ID
                ,      CREDIT_TYPE_CODE
                ,      x_new_project_id
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      FND_GLOBAL.LOGIN_ID
                ,      decode(x_delta, null, x_start_date,
                                        start_date_active + x_delta)
        ,      CREDIT_PERCENTAGE
                ,      decode(x_delta, null, x_completion_date,
                                        end_date_active + x_delta)
                ,      TRANSFER_TO_AR_FLAG
                ,      pa_credit_receivers_s.NEXTVAL
                ,      RECORD_VERSION_NUMBER
                ,      SALESREP_ID
                  FROM
            pa_credit_receivers
                 WHERE project_id = x_orig_project_id
           and task_id is null;


    -- copy project level billing assignment
        x_err_stage := 'copying project billing assignment ';

                INSERT INTO pa_billing_assignments (
            BILLING_ASSIGNMENT_ID,
            BILLING_EXTENSION_ID,
            PROJECT_TYPE,
            PROJECT_ID,
            TOP_TASK_ID,
            AMOUNT,
            PERCENTAGE,
            ACTIVE_FLAG,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
                        RECORD_VERSION_NUMBER,
            DISTRIBUTION_RULE,
/* Added columns for bug#2658340 */
                        ORG_ID,
                        RATE_OVERRIDE_CURRENCY_CODE,
                        PROJECT_CURRENCY_CODE,
                        PROJECT_RATE_TYPE,
                        PROJECT_RATE_DATE,
                        PROJECT_EXCHANGE_RATE,
                        PROJFUNC_CURRENCY_CODE,
                        PROJFUNC_RATE_TYPE,
                        PROJFUNC_RATE_DATE,
                        PROJFUNC_EXCHANGE_RATE,
                        FUNDING_RATE_TYPE,
                        FUNDING_RATE_DATE,
                        FUNDING_EXCHANGE_RATE)
        select
            pa_billing_assignments_s.nextval,
            BILLING_EXTENSION_ID,
            project_type,
            x_new_project_id,
            null,
            AMOUNT,
            PERCENTAGE,
            ACTIVE_FLAG,
            sysdate,
            FND_GLOBAL.USER_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.LOGIN_ID,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
                        RECORD_VERSION_NUMBER,
                        null, /* Bug#2663786 - Distribution should be inserted as null, commented line below.
            nvl(x_DISTRIBUTION_RULE, DISTRIBUTION_RULE), */
/* Added columns for bug#2658340 */
                        ORG_ID,
                        RATE_OVERRIDE_CURRENCY_CODE,
                        PROJECT_CURRENCY_CODE,
                        PROJECT_RATE_TYPE,
                        PROJECT_RATE_DATE,
                        PROJECT_EXCHANGE_RATE,
                        PROJFUNC_CURRENCY_CODE,
                        PROJFUNC_RATE_TYPE,
                        PROJFUNC_RATE_DATE,
                        PROJFUNC_EXCHANGE_RATE,
                        FUNDING_RATE_TYPE,
                        FUNDING_RATE_DATE,
                        FUNDING_EXCHANGE_RATE
        from pa_billing_assignments
        where project_id = x_orig_project_id
          and top_task_id is null;


    -- copying burden schedule for project:

        x_err_stage := 'copying project level burden schedules ';

        INSERT INTO pa_ind_rate_schedules (
             IND_RATE_SCH_ID,
             IND_RATE_SCH_NAME,
             BUSINESS_GROUP_ID,
                         DESCRIPTION,
             START_DATE_ACTIVE,
             END_DATE_ACTIVE,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATE_LOGIN,
             COST_PLUS_STRUCTURE,
             IND_RATE_SCHEDULE_TYPE,
             PROJECT_ID,
             TASK_ID,
             COST_OVR_SCH_FLAG,
             REV_OVR_SCH_FLAG,
             INV_OVR_SCH_FLAG,
             ORGANIZATION_STRUCTURE_ID,
             ORG_STRUCTURE_VERSION_ID,
             START_ORGANIZATION_ID,  --Added these three columns for bug 2581491
                         IND_RATE_SCH_USAGE     --bug 3053508
                         )
          select
             pa_ind_rate_schedules_s.nextval,
--             to_char(x_new_project_id) ||
--                   substr(s.ind_rate_sch_name,
--                  instr(s.ind_rate_sch_name, '-', -1)),
             SUBSTR((TO_CHAR(x_new_project_id) ||
         DECODE(INSTR(s.ind_rate_sch_name, '-', -1),'0','-') ||
                   SUBSTR(s.ind_rate_sch_name,
                   INSTR(s.ind_rate_sch_name, '-', -1))),1,30),  -- Added for bug 3911182.
             s.business_group_id,
                         s.DESCRIPTION,
                         decode(x_delta, null, x_start_date,
                                        s.start_date_active + x_delta),
                         decode(x_delta, null, x_completion_date,
                                        s.end_date_active + x_delta),
             sysdate,
                         FND_GLOBAL.USER_ID,
                         FND_GLOBAL.USER_ID,
                         sysdate,
                         FND_GLOBAL.LOGIN_ID,
             s.COST_PLUS_STRUCTURE,
             s.IND_RATE_SCHEDULE_TYPE,
             x_new_project_id,
             null,
             s.COST_OVR_SCH_FLAG,
             s.REV_OVR_SCH_FLAG,
             s.INV_OVR_SCH_FLAG,
             s.ORGANIZATION_STRUCTURE_ID,
             s.ORG_STRUCTURE_VERSION_ID,
             s.START_ORGANIZATION_ID , --Added these three columns for bug 2581491
                         s.IND_RATE_SCH_USAGE       --bug 3053508
                  FROM
                       pa_ind_rate_schedules s
                 WHERE s.project_id = x_orig_project_id
           and s.task_id is null;


                 x_err_stage := 'copying burden schedule revisions ';

             insert into pa_ind_rate_sch_revisions (
             IND_RATE_SCH_REVISION_ID,
             IND_RATE_SCH_ID,
             IND_RATE_SCH_REVISION,
             IND_RATE_SCH_REVISION_TYPE,
             COMPILED_FLAG,
             COST_PLUS_STRUCTURE,
             START_DATE_ACTIVE,
             END_DATE_ACTIVE,
             COMPILED_DATE,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATE_LOGIN,
             REQUEST_ID,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_UPDATE_DATE,
             READY_TO_COMPILE_FLAG,
             ACTUAL_SCH_REVISION_ID,
             ORGANIZATION_STRUCTURE_ID,
             ORG_STRUCTURE_VERSION_ID,
             START_ORGANIZATION_ID)  --Added these three columns for bug 2581491
             select
                         pa_ind_rate_sch_revisions_s.nextval,
                         new_sch.ind_rate_sch_id,
                         rev.IND_RATE_SCH_REVISION,
                         rev.IND_RATE_SCH_REVISION_TYPE,
                         'N',
                         rev.COST_PLUS_STRUCTURE,
                         decode(x_delta, null, x_start_date,
                                        rev.start_date_active + x_delta),
                         decode(x_delta, null, x_completion_date,
                                        rev.end_date_active + x_delta),
                         null,
                         sysdate,
                         FND_GLOBAL.USER_ID,
                         FND_GLOBAL.USER_ID,
                         sysdate,
                         FND_GLOBAL.LOGIN_ID,
                         rev.REQUEST_ID,
                         NULL,
                         NULL,
                         NULL,
                         'Y',
                         NULL,
             rev.ORGANIZATION_STRUCTURE_ID,
             rev.ORG_STRUCTURE_VERSION_ID,
             rev.START_ORGANIZATION_ID  --Added these three columns for bug 2581491
             from pa_ind_rate_sch_revisions rev,
              pa_ind_rate_schedules old_sch,
              pa_ind_rate_schedules new_sch
                where old_sch.project_id = x_orig_project_id
              and old_sch.ind_rate_sch_id = rev.IND_RATE_SCH_ID
              and old_sch.task_id is null
              and new_sch.project_id = x_new_project_id
              and new_sch.task_id is null
              and substr(new_sch.ind_rate_sch_name,                    -- added for bug 4213251
                  decode(instr(new_sch.ind_rate_sch_name, '-', -1), 0 , 0,
	                  instr(new_sch.ind_rate_sch_name, '-', -1)+1))
                = substr(old_sch.ind_rate_sch_name,
                  decode(instr(old_sch.ind_rate_sch_name, '-', -1), 0 , 0,
				    instr(old_sch.ind_rate_sch_name, '-', -1)+1));

/* Commented the following code for bug 4213251
	    and substr(new_sch.ind_rate_sch_name,
                  instr(new_sch.ind_rate_sch_name, '-', -1))
                = substr(old_sch.ind_rate_sch_name,
                  instr(old_sch.ind_rate_sch_name, '-', -1)); */

            insert into pa_ind_cost_multipliers (
                 IND_RATE_SCH_REVISION_ID,
                 ORGANIZATION_ID,
                 IND_COST_CODE,
                 MULTIPLIER,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATED_BY,
                 CREATION_DATE,
                 LAST_UPDATE_LOGIN )
            select
                     new_rev.IND_RATE_SCH_REVISION_ID,
                 mult.ORGANIZATION_ID,
                 mult.IND_COST_CODE,
                 mult.MULTIPLIER,
                             sysdate,
                             FND_GLOBAL.USER_ID,
                             FND_GLOBAL.USER_ID,
                             sysdate,
                             FND_GLOBAL.LOGIN_ID
            from pa_ind_cost_multipliers mult,
                 pa_ind_rate_sch_revisions old_rev,
                 pa_ind_rate_sch_revisions new_rev,
                             pa_ind_rate_schedules old_sch,
                             pa_ind_rate_schedules new_sch
               where old_rev.IND_RATE_SCH_REVISION_ID =
                 mult.IND_RATE_SCH_REVISION_ID
             and old_rev.IND_RATE_SCH_REVISION =
                 new_rev.IND_RATE_SCH_REVISION
                         and old_sch.ind_rate_sch_id = old_rev.IND_RATE_SCH_ID
                         and new_sch.ind_rate_sch_id = new_rev.IND_RATE_SCH_ID
                         and old_sch.project_id = x_orig_project_id
             and old_sch.task_id is null
                         and new_sch.project_id = x_new_project_id
             and new_sch.task_id is null
                 and substr(new_sch.ind_rate_sch_name,               -- added for bug 4213251
                  decode(instr(new_sch.ind_rate_sch_name, '-', -1), 0 , 0,
	                  instr(new_sch.ind_rate_sch_name, '-', -1)+1))
                  = substr(old_sch.ind_rate_sch_name,
                  decode(instr(old_sch.ind_rate_sch_name, '-', -1), 0 , 0,
				    instr(old_sch.ind_rate_sch_name, '-', -1)+1));

/* Commented the following code for bug 4213251
	    and substr(new_sch.ind_rate_sch_name,
                  instr(new_sch.ind_rate_sch_name, '-', -1))
                = substr(old_sch.ind_rate_sch_name,
                  instr(old_sch.ind_rate_sch_name, '-', -1)); */


        x_err_stage := 'copying project level transaction control';
--Below code added for selective copy project. Tracking Bug No. 3464332
        --Check whether the Transaction Controls flag is checked or not
        OPEN  cur_get_flag('FN_TXN_CONTROL_FLAG');
        FETCH cur_get_flag INTO l_fin_txn_control_flag;
        CLOSE cur_get_flag;

        IF 'Y' = l_fin_txn_control_flag THEN
            INSERT INTO pa_transaction_controls (
                       project_id
                ,      start_date_active
                ,      chargeable_flag
                ,      billable_indicator
                ,      creation_date
                ,      created_by
                ,      last_update_date
                ,      last_updated_by
                ,      last_update_login
                ,      person_id
                ,      expenditure_category
                ,      expenditure_type
                ,      non_labor_resource
                    ,      scheduled_exp_only
                ,      end_date_active
    /*Added for FPM Changes for Project Setup */
                    ,      workplan_res_only_flag
                    ,      employees_only_flag)
                SELECT
                       x_new_project_id
                    ,      decode(x_delta, null, x_start_date,
                                            tc.start_date_active + x_delta)
                ,      tc.chargeable_flag
                ,      tc.billable_indicator
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      sysdate
                ,      FND_GLOBAL.USER_ID
                ,      FND_GLOBAL.LOGIN_ID
                ,      tc.person_id
                ,      tc.expenditure_category
                ,      tc.expenditure_type
                ,      tc.non_labor_resource
                    ,      tc.scheduled_exp_only
                    ,      decode(x_delta, null, x_completion_date,
                                            tc.end_date_active + x_delta)
    /*Added for FPM Changes for Project Setup */
                    ,      tc.workplan_res_only_flag
                    ,      tc.employees_only_flag
                  FROM
                       pa_transaction_controls tc
                 WHERE
                       tc.project_id = x_orig_project_id
                   AND tc.task_id  IS NULL;
        END IF;--IF 'Y' = l_fin_txn_control_flag

        x_err_stage := 'copying project assets';

--Below code added for selective copy project. Tracking Bug No. 3464332
            OPEN  cur_get_flag('FN_ASSETS_FLAG');
            FETCH cur_get_flag INTO l_fn_assets_flag;
            CLOSE cur_get_flag;

            IF 'Y' = l_fn_assets_flag THEN
                INSERT INTO pa_project_assets (
                PROJECT_ASSET_ID,
                PROJECT_ID,
                    ASSET_NUMBER,
                ASSET_NAME,
                ASSET_DESCRIPTION,
                LOCATION_ID,
                ASSIGNED_TO_PERSON_ID,
                DATE_PLACED_IN_SERVICE,
                ASSET_CATEGORY_ID,
               ASSET_KEY_CCID,
             BOOK_TYPE_CODE,
                ASSET_UNITS,
                DEPRECIATE_FLAG,
                DEPRECIATION_EXPENSE_CCID,
                CAPITALIZED_FLAG,
                ESTIMATED_IN_SERVICE_DATE,
                CAPITALIZED_COST,
                GROUPED_CIP_COST,
                            AMORTIZE_FLAG,
                            COST_ADJUSTMENT_FLAG,
                            CAPITALIZED_DATE,
                            REVERSE_FLAG,
                            REVERSAL_DATE,
                            NEW_MASTER_FLAG,
                            CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15,
    --PA L Changes 2872708
                            --CAPITAL_EVENT_ID,  --do not copy capital event bug 2946015
                            --FA_PERIOD_NAME,
                            --PM_PRODUCT_CODE,
                            --PM_ASSET_REFERENCE,
                            ESTIMATED_COST,
                            ESTIMATED_ASSET_UNITS,
                            MANUFACTURER_NAME,
                            MODEL_NUMBER,
                            --TAG_NUMBER,
                            --SERIAL_NUMBER,
                            RET_TARGET_ASSET_ID,
                            PROJECT_ASSET_TYPE,
                            PARENT_ASSET_ID,
                            --FA_ASSET_ID,
                            CAPITAL_HOLD_FLAG,
    --end PA L Changes 2872708
                            ORG_ID  --R12: MOAC changes: Bug 4363092
    )
            select
                pa_project_assets_s.nextval,
                x_new_PROJECT_ID,
                    NULL,
                ASSET_NAME,
                ASSET_DESCRIPTION,
                decode(x_orig_template_flag, 'Y', LOCATION_ID, NULL), -- NULL,  bug 3433295
                NULL,
                NULL,
                ASSET_CATEGORY_ID,
               ASSET_KEY_CCID,
             BOOK_TYPE_CODE,
                ASSET_UNITS,
                DEPRECIATE_FLAG,
                DEPRECIATION_EXPENSE_CCID,
                'N',
                decode(ESTIMATED_IN_SERVICE_DATE, null, null,
                    decode(x_delta, null, x_start_date,
                                            ESTIMATED_IN_SERVICE_DATE + x_delta)),
                0,
                0,
                            AMORTIZE_FLAG,
                            'N',
                             NULL,
                            'N',
                             NULL,
                             'N',
                            sysdate,
                            FND_GLOBAL.USER_ID,
                            sysdate,
                            FND_GLOBAL.USER_ID,
                            FND_GLOBAL.LOGIN_ID,
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15,
    --PA L chanegs 2872708
                            --CAPITAL_EVENT_ID,   --do not copy capital event bug 2946015
                            --FA_PERIOD_NAME,     --do not copy. please refer bug 2948307
                            --PM_PRODUCT_CODE,
                            --PM_ASSET_REFERENCE,
                            ESTIMATED_COST,
                            ESTIMATED_ASSET_UNITS,
                            MANUFACTURER_NAME,
                            MODEL_NUMBER,
                            --TAG_NUMBER,
                            --SERIAL_NUMBER,
                            RET_TARGET_ASSET_ID,
                            DECODE( PROJECT_ASSET_TYPE, 'AS-BUILT', 'ESTIMATED', PROJECT_ASSET_TYPE ),
                             --bug 2872708 refer *** MAANSARI  04/17/03 11:19 am ***
                            PARENT_ASSET_ID,
                            --FA_ASSET_ID,
                            decode( x_orig_template_flag, 'Y', CAPITAL_HOLD_FLAG, 'N', 'N' ),
        --end PA L chanegs 2872708
                            org_id  --R12: MOAC changes: Bug 4363092
                from pa_project_assets
                where project_id = x_orig_project_id;
            END IF;--IF 'Y' = l_fn_assets_flag THEN

             --  This block copies the attachments for a
             --  perticular asset

             Begin
             Declare
                  cursor c_attach_assets is
                      select orig.project_asset_id orig_project_asset_id,
                             new.project_asset_id new_project_asset_id
                        from pa_project_assets orig, pa_project_assets new
                       where orig.project_id = x_orig_project_id
                         and new.asset_name = orig.asset_name
                         and new.project_id = x_new_project_id  ;

                   c_atch   c_attach_assets%rowtype ;

             begin
                 open c_attach_assets;
                 loop
                     fetch c_attach_assets
                      into c_atch ;
                      if c_attach_assets%notfound then
                         exit ;
                      end if;
                      fnd_attached_documents2_pkg.copy_attachments
                                            ('PA_PROJECT_ASSETS',
                                             c_atch.orig_project_asset_id,
                                             null, null, null, null,
                                             'PA_PROJECT_ASSETS',
                                             c_atch.new_project_asset_id,
                                             null, null, null, null,
                                             FND_GLOBAL.USER_ID,
                                             FND_GLOBAL.LOGIN_ID,
                                             275, null, null);

                 end loop ;
                 close c_attach_assets;
             exception
                 when NO_DATA_FOUND then
                      null;
                 when others then
                      null ;
             end ;
             end ;

            -- End copy attachments

            x_err_stage := 'copying project level project asset assignment';
--Below code added for selective copy project. Tracking Bug No. 3464332
            OPEN  cur_get_flag('FN_ASSET_ASSIGNMENTS_FLAG');
            FETCH cur_get_flag INTO l_fn_asset_assignments_flag;
            CLOSE cur_get_flag;

            IF 'Y' = l_fn_asset_assignments_flag THEN
                INSERT INTO pa_project_asset_assignments (
                    PROJECT_ASSET_ID,
                    TASK_ID,
                    PROJECT_ID,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN)
    -- changed to remove bug#604496 :ashia bagai 30-dec-97
    -- added UNION to remove bug#604496 : ashia bagai 30-dec-97
    --       Common Cost asset assignments would have an asset id = 0
    --  and hence would not have a relevant record in pa_project_assets
    /*          select
                    new_asset.PROJECT_ASSET_ID,
                    0,
                    new_asset.PROJECT_ID,
                                sysdate,
                                FND_GLOBAL.USER_ID,
                                sysdate,
                                FND_GLOBAL.USER_ID,
                                FND_GLOBAL.LOGIN_ID
                from pa_project_asset_assignments assign,
                     pa_project_assets  old_asset,
                     pa_project_assets  new_asset
                where old_asset.project_id = x_orig_project_id
                  and old_asset.project_asset_id =
                        assign.project_asset_id
                  and assign.task_id = 0
                  and old_asset.asset_name = new_asset.asset_name
                  and new_asset.project_id = x_new_project_id;
    */
                select
                    new_asset.PROJECT_ASSET_ID,
                                    0,
                                    new_asset.PROJECT_ID,
                                    sysdate,
                                    FND_GLOBAL.USER_ID,
                                    sysdate,
                                    FND_GLOBAL.USER_ID,
                                    FND_GLOBAL.LOGIN_ID
                            from pa_project_asset_assignments assign,
                                 pa_project_assets  old_asset,
                                 pa_project_assets  new_asset
                            where old_asset.project_id = x_orig_project_id
                              and old_asset.project_asset_id =
                                            assign.project_asset_id
                              and assign.task_id = 0
                              and old_asset.asset_name = new_asset.asset_name
                              and new_asset.project_id = x_new_project_id
                             UNION
                            select
                                    PROJECT_ASSET_ID,
                                    0,
                                    x_new_project_id,
                                    sysdate,
                                    FND_GLOBAL.USER_ID,
                                    sysdate,
                                    FND_GLOBAL.USER_ID,
                                    FND_GLOBAL.LOGIN_ID
                            from pa_project_asset_assignments
                            where project_id = x_orig_project_id
                                and task_id = 0
                                and project_asset_id = 0;
            END IF;--IF 'Y' = l_fn_asset_assignments_flag THEN
--end of change for bug#604496

        -- end of copy project asset assignments
        x_err_stage := 'copying project resource list assignments';

                INSERT INTO pa_resource_list_assignments (
            RESOURCE_LIST_ASSIGNMENT_ID,
            RESOURCE_LIST_ID,
            PROJECT_ID,
            RESOURCE_LIST_CHANGED_FLAG,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN )
        select
            pa_resource_list_assignments_s.nextval,
            RESOURCE_LIST_ID,
            x_new_project_id,
            'N',
                        FND_GLOBAL.USER_ID,
            sysdate,
                        sysdate,
                        FND_GLOBAL.USER_ID,
                        FND_GLOBAL.LOGIN_ID
        from    pa_resource_list_assignments a,
                pa_resource_list_uses u
        where   a.project_id = x_orig_project_id
        and     a.resource_list_assignment_id =
                u.resource_list_assignment_id
        and     u.use_code = 'ACTUALS_ACCUM';


                x_err_stage := 'copying project resource list uses';

                    INSERT INTO pa_resource_list_uses (
                RESOURCE_LIST_ASSIGNMENT_ID,
                USE_CODE,
                DEFAULT_FLAG,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN )
            select
                new_list.RESOURCE_LIST_ASSIGNMENT_ID,
                use.USE_CODE,
                use.Default_Flag,
                            FND_GLOBAL.USER_ID,
                sysdate,
                            sysdate,
                            FND_GLOBAL.USER_ID,
                            FND_GLOBAL.LOGIN_ID
            from    pa_resource_list_uses use,
                pa_resource_list_assignments old_list,
                pa_resource_list_assignments new_list
            where   old_list.project_id = x_orig_project_id
              and   old_list.RESOURCE_LIST_ASSIGNMENT_ID =
                use.RESOURCE_LIST_ASSIGNMENT_ID
              and   use.use_code = 'ACTUALS_ACCUM'
              and   old_list.resource_list_id =
                new_list.resource_list_id
              and   new_list.project_id = x_new_project_id;

                x_err_stage := 'copying project level job bill rate overrides';

                --Below condition added for selective copy project. Tracking Bug No. 3464332
                IF 'Y' = l_fn_cb_overrides_flag THEN
                    INSERT INTO pa_job_bill_rate_overrides (
                            JOB_ID
                    ,       START_DATE_ACTIVE
                    ,       LAST_UPDATE_DATE
                    ,       LAST_UPDATED_BY
                    ,       CREATION_DATE
                    ,       CREATED_BY
                    ,       LAST_UPDATE_LOGIN
                    ,       RATE
                    ,       BILL_RATE_UNIT
                    ,       PROJECT_ID
                    ,       TASK_ID
       --MCB Chanes
                    ,       RATE_CURRENCY_CODE
                    ,       JOB_BILL_RATE_OVERRIDE_ID
                    ,       RECORD_VERSION_NUMBER
       --MCB Chanes
                    ,       END_DATE_ACTIVE
                    ,       DISCOUNT_PERCENTAGE
                    ,       RATE_DISC_REASON_CODE )
                    SELECT
                            JOB_ID
                    ,       decode(x_delta, null, x_start_date,
                                            start_date_active + x_delta)
                    ,       sysdate
                    ,       FND_GLOBAL.USER_ID
                    ,       sysdate
                    ,       FND_GLOBAL.USER_ID
                    ,       FND_GLOBAL.LOGIN_ID
                    ,       RATE
                    ,       BILL_RATE_UNIT
                    ,       x_new_project_id
                    ,       null
       --MCB Chanes
                    ,       RATE_CURRENCY_CODE
                    ,       pa_job_bill_rate_overrides_s.NEXTVAL
                    ,       RECORD_VERSION_NUMBER
       --MCB Chanes
                    ,       decode(x_delta, null, x_completion_date,
                                            end_date_active + x_delta)
                    ,       DISCOUNT_PERCENTAGE
                    ,       RATE_DISC_REASON_CODE
                      FROM
                            pa_job_bill_rate_overrides
                      WHERE project_id = x_orig_project_id
                      and task_id is null;
                END IF;


                x_err_stage := 'copying project level job bill title overrides';

                --Below condition added for selective copy project. Tracking Bug No. 3464332
                IF 'Y' = l_fn_cb_overrides_flag THEN
                    INSERT INTO pa_job_bill_title_overrides (
                            JOB_ID
                    ,       LAST_UPDATE_DATE
                    ,       LAST_UPDATED_BY
                    ,       CREATION_DATE
                    ,       CREATED_BY
                    ,       LAST_UPDATE_LOGIN
                    ,       START_DATE_ACTIVE
                    ,       BILLING_TITLE
                    ,       PROJECT_ID
                    ,       TASK_ID
                    ,       JOB_BILL_TITLE_OVERRIDE_ID
                    ,       RECORD_VERSION_NUMBER
                    ,       END_DATE_ACTIVE )
                    SELECT
                            JOB_ID
                    ,       sysdate
                    ,       FND_GLOBAL.USER_ID
            ,   sysdate
                    ,       FND_GLOBAL.USER_ID
                    ,       FND_GLOBAL.LOGIN_ID
                    ,       decode(x_delta, null, x_start_date,
                                            start_date_active + x_delta)
                    ,       BILLING_TITLE
                    ,       x_new_project_id
                    ,       null
                    ,       pa_job_bill_title_overrides_s.NEXTVAL
                    ,       RECORD_VERSION_NUMBER
                    ,       decode(x_delta, null, x_completion_date,
                                            end_date_active + x_delta)
                      FROM
                           pa_job_bill_title_overrides
                      WHERE project_id = x_orig_project_id
                      and task_id is null;
                END IF;

                x_err_stage := 'copying project level job assignment overrides';

                --Below condition added for selective copy project. Tracking Bug No. 3464332
                IF 'Y' = l_fn_cb_overrides_flag THEN
                    INSERT INTO pa_job_assignment_overrides (
                            PERSON_ID
                    ,       LAST_UPDATE_DATE
                    ,       LAST_UPDATED_BY
                    ,       CREATION_DATE
                    ,       CREATED_BY
                    ,       LAST_UPDATE_LOGIN
                    ,       START_DATE_ACTIVE
                    ,       PROJECT_ID
                    ,       TASK_ID
                    ,       JOB_ID
                    ,       BILLING_TITLE
                    ,       JOB_ASSIGNMENT_OVERRIDE_ID
                    ,       RECORD_VERSION_NUMBER
                    ,       END_DATE_ACTIVE )
                    SELECT
                            PERSON_ID
                    ,       sysdate
                    ,       FND_GLOBAL.USER_ID
                    ,       sysdate
                    ,       FND_GLOBAL.USER_ID
                    ,       FND_GLOBAL.LOGIN_ID
                    ,       decode(x_delta, null, x_start_date,
                                            start_date_active + x_delta)
                    ,       x_new_project_id
                    ,       null
                    ,       JOB_ID
                    ,       BILLING_TITLE
                    ,       pa_job_assignment_overrides_s.NEXTVAL
                    ,       RECORD_VERSION_NUMBER
                    ,       decode(x_delta, null, x_completion_date,
                                            end_date_active + x_delta)
                      FROM
                           pa_job_assignment_overrides
                      WHERE project_id = x_orig_project_id
                      and task_id is null;
                END IF;

                x_err_stage := 'copying project level emp bill rate overrides';

                --Below condition added for selective copy project. Tracking Bug No. 3464332
                IF 'Y' = l_fn_cb_overrides_flag THEN
                    INSERT INTO pa_emp_bill_rate_overrides (
                            PERSON_ID
                    ,       LAST_UPDATE_DATE
                    ,       LAST_UPDATED_BY
                    ,       CREATION_DATE
                    ,       CREATED_BY
                    ,       LAST_UPDATE_LOGIN
                    ,       RATE
                    ,       BILL_RATE_UNIT
                    ,       START_DATE_ACTIVE
                    ,       PROJECT_ID
                    ,       TASK_ID
       --MCB Chanes
                    ,       RATE_CURRENCY_CODE
                    ,       EMP_BILL_RATE_OVERRIDE_ID
                    ,       RECORD_VERSION_NUMBER
       --MCB Chanes
                    ,       END_DATE_ACTIVE
                    ,       DISCOUNT_PERCENTAGE
                    ,       RATE_DISC_REASON_CODE)
                    SELECT
                            PERSON_ID
                    ,       sysdate
                    ,       FND_GLOBAL.USER_ID
                    ,       sysdate
                    ,       FND_GLOBAL.USER_ID
                    ,       FND_GLOBAL.LOGIN_ID
                    ,       RATE
                    ,       BILL_RATE_UNIT
                    ,       decode(x_delta, null, x_start_date,
                                            start_date_active + x_delta)
                    ,   x_new_project_id
                    ,   null
       --MCB Chanes
                    ,       RATE_CURRENCY_CODE
                    ,       pa_emp_bill_rate_overrides_s.NEXTVAL
                    ,       RECORD_VERSION_NUMBER
       --MCB Chanes
                    ,       decode(x_delta, null, x_completion_date,
                                            end_date_active + x_delta)
                    ,       DISCOUNT_PERCENTAGE
                    ,       RATE_DISC_REASON_CODE
                      FROM
                           pa_emp_bill_rate_overrides
                      WHERE project_id = x_orig_project_id
                      and task_id is null;
                END IF;

                x_err_stage := 'copying project level nl bill rate overrides';

                --Below condition added for selective copy project. Tracking Bug No. 3464332
                IF 'Y' = l_fn_cb_overrides_flag THEN
                    INSERT INTO pa_nl_bill_rate_overrides (
                            EXPENDITURE_TYPE
                    ,       LAST_UPDATE_DATE
                    ,       LAST_UPDATED_BY
                    ,       CREATION_DATE
                    ,       CREATED_BY
                    ,       LAST_UPDATE_LOGIN
                    ,       START_DATE_ACTIVE
                    ,       NON_LABOR_RESOURCE
                    ,       MARKUP_PERCENTAGE
                    ,       BILL_RATE
                    ,       PROJECT_ID
                    ,       TASK_ID
       --MCB Chanes
                    ,       RATE_CURRENCY_CODE
                    ,       NL_BILL_RATE_OVERRIDE_ID
                    ,       RECORD_VERSION_NUMBER
       --MCB Chanes
                    ,       END_DATE_ACTIVE
                    ,       DISCOUNT_PERCENTAGE
                    ,       RATE_DISC_REASON_CODE )
                    SELECT
                            EXPENDITURE_TYPE
                    ,       sysdate
                    ,       FND_GLOBAL.USER_ID
                    ,       sysdate
                    ,       FND_GLOBAL.USER_ID
                    ,       FND_GLOBAL.LOGIN_ID
                    ,       decode(x_delta, null, x_start_date,
                                            start_date_active + x_delta)
                    ,       NON_LABOR_RESOURCE
                    ,       MARKUP_PERCENTAGE
                    ,       BILL_RATE
                    ,       x_new_project_id
                    ,       null
       --MCB Chanes
                    ,       RATE_CURRENCY_CODE
                    ,       pa_nl_bill_rate_overrides_s.NEXTVAL
                    ,       RECORD_VERSION_NUMBER
       --MCB Chanes
                    ,       decode(x_delta, null, x_completion_date,
                                            end_date_active + x_delta)
                    ,       DISCOUNT_PERCENTAGE
                    ,       RATE_DISC_REASON_CODE
                      FROM
                           pa_nl_bill_rate_overrides
                      WHERE project_id = x_orig_project_id
                      and task_id is null;
                END IF;

                x_err_stage := 'copying project level labor multipliers ';

                INSERT INTO pa_labor_multipliers (
                        PROJECT_ID
                ,       TASK_ID
                ,       LABOR_MULTIPLIER
                ,       START_DATE_ACTIVE
                ,       END_DATE_ACTIVE
                ,       LAST_UPDATE_DATE
                ,       LAST_UPDATED_BY
                ,       CREATION_DATE
                ,       CREATED_BY
                ,       LABOR_MULTIPLIER_ID
                ,       RECORD_VERSION_NUMBER
                ,       LAST_UPDATE_LOGIN )

                SELECT
                        x_new_project_id
                ,       null
                ,       labor_multiplier
                ,       decode(x_delta, null, x_start_date,
                                        start_date_active + x_delta)
                ,       decode(x_delta, null, x_completion_date,
                                        end_date_active + x_delta)
                ,       sysdate
                ,       FND_GLOBAL.USER_ID
                ,       sysdate
                ,       FND_GLOBAL.USER_ID
                ,       pa_labor_multipliers_s.NEXTVAL
                ,       RECORD_VERSION_NUMBER
                ,       FND_GLOBAL.LOGIN_ID
                  FROM  pa_labor_multipliers
                  WHERE project_id = x_orig_project_id
            and task_id is null;

        -- added the following call to copy the attachments to
        -- a perticular project to the newly created project

/*Following code added for selective copy project options. Tracking bug No 3464332*/
OPEN  cur_get_flag('PR_ATTACHMENTS_FLAG');
FETCH cur_get_flag INTO l_pr_attachments_flag;
CLOSE cur_get_flag;

OPEN  cur_get_flag('PR_FRM_SRC_TMPL_FLAG');
FETCH cur_get_flag INTO l_pr_frm_src_tmpl_flag;
CLOSE cur_get_flag;
--Following two IF conditions added for selective copy project
IF 'Y' = l_pr_attachments_flag THEN
    IF 'Y' = l_pr_frm_src_tmpl_flag THEN
       fnd_attached_documents2_pkg.copy_attachments('PA_PROJECTS',
                                    --x_orig_project_id,  Bug 3694616
                                    x_created_from_proj_id,
                                    null,
                                    null,
                                    null,
                                    null,
                                    'PA_PROJECTS',
                                    --x_created_from_proj_id,  Bug 3694616
                                    x_new_project_id,
                                    null,
                                    null,
                                    null,
                                    null,
                                    FND_GLOBAL.USER_ID,
                                    FND_GLOBAL.LOGIN_ID,
                                    275, null, null);
    ELSE
        fnd_attached_documents2_pkg.copy_attachments('PA_PROJECTS',
                                    x_orig_project_id,
                                    null,
                                    null,
                                    null,
                                    null,
                                    'PA_PROJECTS',
                                    x_new_project_id,
                                    null,
                                    null,
                                    null,
                                    null,
                                    FND_GLOBAL.USER_ID,
                                    FND_GLOBAL.LOGIN_ID,
                                    275, null, null);
    END IF; -- 'Y' = l_pr_frm_src_tmpl_flag
END IF; --'Y' = l_pr_attachments_flag

-------
--EH changes
    DECLARE
    --Added for Selective Copy Project. Tracking Bug No. 3464332
    --This cursor determines if atleast one WP version has been selected by the user
    CURSOR min_one_wp_version_sel IS
    SELECT distinct 'Y'
    FROM  PA_PROJECT_COPY_OPTIONS_TMP
    WHERE CONTEXT = 'WORKPLAN'
      AND VERSION_ID IS NOT NULL;

    l_workplan_enabled      VARCHAR2(1) := 'N';
    l_shared                VARCHAR2(1);
    l_min_one_wp_ver_sel    VARCHAR2(1) := 'N';
    l_fin_tasks_flag        VARCHAR2(1) := 'Y';
     BEGIN
    --Check whether WP structure is enabled for the source project
    l_workplan_enabled := PA_PROJ_TASK_STRUC_PUB.WP_STR_EXISTS( x_orig_project_id );

    IF NVL( l_workplan_enabled, 'N' ) = 'Y' THEN
        --Check whether the structures are shared or not in the source project
        l_shared := PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled( x_orig_project_id );
    ELSE
        l_shared := 'N';
    END IF;

    --Check whether atleast one WP version has been selected by the user or not
    OPEN  min_one_wp_version_sel;
    FETCH min_one_wp_version_sel INTO l_min_one_wp_ver_sel;
    CLOSE min_one_wp_version_sel;

    --Check whether the financial tasks flag is checked or not
    OPEN  cur_get_flag('FN_FIN_TASKS_FLAG');
    FETCH cur_get_flag INTO l_fin_tasks_flag;
    CLOSE cur_get_flag;

    IF 'Y' = l_fin_tasks_flag OR ('Y' = l_shared AND 'Y' = l_min_one_wp_ver_sel) THEN
    --End selective copy project. Tracking Bug No. 3464332
        if (x_copy_task_flag = 'Y' ) then
                    x_err_stage := 'call copy_task';
            pa_project_core2.copy_task ( x_orig_project_id,
                   x_new_project_id,
                   x_err_code,
                   x_err_stage,
                   x_err_stack);

            -- if application or oracle error return
            if ( x_err_code > 0 or x_err_code < 0 ) then
                       x_err_code := 800;
                       IF x_err_stage IS NULL
                       THEN
                           x_err_stage   := pa_project_core1.get_message_from_stack( 'PA_ERR_COPY_TASK');
                       END IF;
                       x_err_stack   := x_err_stack||'->pa_project_core2.copy_task';
               rollback to copy_project;
               revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
               return;
            end if;
    end if;
         -- Bug 4221196 - Moved l_is_fin_str_copied := 'Y' out of x_copy_task_flag check
         /* Bug 4188514 - If financial tasks are copied then only copy in budget versions  */
        l_is_fin_str_copied := 'Y';
    END IF;
    EXCEPTION WHEN OTHERS THEN
             x_err_code := 800;
--             x_err_stage := pa_project_core1.get_message_from_stack( null );
--             IF x_err_stage IS NULL
--             THEN
                x_err_stage := 'API: '||'pa_project_core2.copy_task'||' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--             END IF;
             rollback to copy_project;
             revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
             return;
    END;

/*FPM Changes for Project Setp- Customer and Invoice Method at Top task */

/* if customer at top task is enabled for project and customer is present in quick entry, copy the same customer to all top tasks.
   otherwsie copy the source task customers */

DECLARE

   l_enable_top_task_cust_flag     varchar2(1);
   l_enable_top_task_inv_mth_flag  varchar2(1);

Begin
  select enable_top_task_customer_flag ,
         enable_top_task_inv_mth_flag
    Into l_enable_top_task_cust_flag,
         l_enable_top_task_inv_mth_flag
         from pa_projects
  where  project_id = x_new_project_id;

  IF nvl(l_enable_top_task_cust_flag,'N') ='Y' Then
     If x_customer_id is not null then
       Update pa_tasks
       set customer_id =x_customer_id
       where project_id=x_new_project_id;
     Else
      Update pa_tasks t
      Set t.customer_id = (select old.customer_id from pa_tasks old
                           where  old.project_id = x_orig_project_id
                           and    old.task_number = t.task_number
                           and    old.customer_id is not null)
      where t.project_id = x_new_project_id;
    End if;
   END IF;

  If x_distribution_rule is not null then
     Update pa_tasks t
     set t.revenue_accrual_method =substr(x_distribution_rule, 1, instr(x_distribution_rule,'/')-1),
         t.invoice_method =  substr(x_distribution_rule, instr(x_distribution_rule,'/')+1)
     where t.project_id=x_new_project_id;
  Else
     Update pa_tasks t
     set t.revenue_accrual_method =(select old.revenue_accrual_method
                                                  from  pa_tasks old
                                                  where  old.project_id = x_orig_project_id
                                                  and    old.task_number = t.task_number
                                                  and    old.revenue_accrual_method is not null),
         t.invoice_method = (select old.invoice_method
                                                  from  pa_tasks old
                                                  where  old.project_id = x_orig_project_id
                                                  and    old.task_number = t.task_number
                                                  and    old.invoice_method is not null)
    where t.project_id = x_new_project_id;
 End if;

End ;

/*FPM Changes for Project Setp- Customer and Invoice Method at Top task ends */

    --Bug 3847507 : Shifted the following two calls to before copy_structure as the copy_wp_budget_versions
    --              call requires the resource list/ RBS information to have been copied
    --Copy resource lists from source to destination project
    BEGIN
        PA_CREATE_RESOURCE.Copy_Resource_Lists( p_source_project_id      => x_orig_project_id
                                               ,p_destination_project_id => x_new_project_id
                                               ,x_return_status          => l_return_status ) ;
        IF l_return_status <> 'S' THEN
            x_err_code := 905;
            x_err_stack := x_err_stack||'->PA_CREATE_RESOURCE.Copy_Resource_Lists';
            ROLLBACK TO copy_project;
            revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
            RETURN;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_err_code := 905;
            x_err_stage := 'API: '||'PA_CREATE_RESOURCE.Copy_Resource_Lists'||
                           ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
            ROLLBACK TO copy_project;
            revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
            RETURN;
    END ;
    --Copy RBS associations from source to destination project
    BEGIN
        PA_RBS_ASGMT_PVT.Copy_Project_Assignment( p_rbs_src_project_id      => x_orig_project_id
                                                 ,p_rbs_dest_project_id     => x_new_project_id
                                                 ,x_return_status           => l_return_status ) ;
        IF l_return_status <> 'S' THEN
            x_err_code := 920;
            x_err_stack := x_err_stack||'->PA_RBS_ASGMT_PUB.Copy_Project_Assignment';
            ROLLBACK TO copy_project;
            revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
            RETURN;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_err_code := 920;
            x_err_stage := 'API: '||'PA_RBS_ASGMT_PUB.Copy_Project_Assignment'||
                           ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
            ROLLBACK TO copy_project;
            revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
            RETURN;
    END ;
    --Bug 3847507 : End shift of above two calls
--Project Structure changes
--EH Changes
        BEGIN
        --This condition is checked here to make sure that the tasks
        --have already been created.
--  if (x_copy_task_flag = 'Y' ) then
            /*PA_PROJ_TASK_STRUC_PUB.COPY_STRUCTURE(
                   p_dest_project_id         => x_new_project_id
                  ,p_src_project_id          => x_orig_project_id
-- anlee
-- Dates changes
                  ,p_delta                   => x_delta
-- End of changes
                  ,x_msg_count               => l_msg_count
                  ,x_msg_data                => l_msg_data
                  ,x_return_status           => l_return_status  );
*/ --bug 2805602   --commented out the previous call and added the following.

              --bug 3991169
              IF (x_start_date IS NULL) THEN
                l_target_start_date := NULL;
                l_target_finish_date := NULL;
              END IF;
              --end bug 3991169

              PA_PROJ_TASK_STRUC_PUB.COPY_STRUCTURE(
                   p_dest_project_id         => x_new_project_id
                  ,p_src_project_id          => x_orig_project_id
                  ,p_delta                   => x_delta
                  ,p_dest_template_flag   => x_template_flag
                  ,p_src_template_flag    => x_orig_template_flag
                  ,p_dest_project_name    => x_project_name
                  ,p_target_start_date    => l_target_start_date
                  ,p_target_finish_date   => l_target_finish_date
                  ,p_calendar_id          => l_cal_id
                  ,p_copy_task_flag       => x_copy_task_flag
                  ,x_msg_count               => l_msg_count
                  ,x_msg_data                => l_msg_data
                  ,x_return_status           => l_return_status  );

            IF l_return_status <> 'S'
            THEN
                x_err_code := 805;
                x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_DFLT_STRUCTURE');
                x_err_stack := x_err_stack||'->PA_PROJ_TASK_STRUC_PUB.COPY_STRUCTURE';
                rollback to copy_project;
                revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                return;
            END IF;
--        end if;
        EXCEPTION WHEN OTHERS THEN
            x_err_code := 805;
--            x_err_stage := pa_project_core1.get_message_from_stack( null );
--            IF x_err_stage IS NULL
--            THEN
               x_err_stage := 'API: '||'PA_PROJ_TASK_STRUC_PUB.COPY_STRUCTURE'||

                              ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--            END IF;
            rollback to copy_project;
            revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
            return;
        END;
--Project Structure changes end

--EH Changes
        BEGIN
             x_err_stage := 'Copy Object Page Layouts';
             PA_Page_layout_Utils.copy_object_page_layouts(
                           p_object_type      => 'PA_PROJECTS',
                           P_object_id_from   => x_orig_project_id ,
                           P_object_id_to     => x_new_project_id,
                           x_return_status    => l_return_status,
                           x_msg_count        => l_msg_count,
                           x_msg_data         => l_msg_data   );
             IF l_return_status <> fnd_api.g_ret_sts_success
             THEN
                  x_err_code := 730;
                  x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_COPY_OBJ_PG_LAY');
                  x_err_stack := x_err_stack||'->PA_Page_layout_Utils.copy_object_page_layouts';
                  rollback to copy_project;
                  revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                  return;
             END IF;
        EXCEPTION WHEN OTHERS THEN
             x_err_code := 730;
--             x_err_stage := pa_project_core1.get_message_from_stack( null );
--             IF x_err_stage IS NULL
--             THEN
                x_err_stage := 'API: '||'PA_Page_layout_Utils.copy_object_page_layouts'||' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--             END IF;
             rollback to copy_project;
             revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
             return;
        END;

--MW Changes need to be executed AFTER copying the layouts above, do not move
--this code. Bug 2246601, Action Sets.
        BEGIN
             x_err_stage := 'Copy Project Status Action Sets';
             PA_PROJ_STAT_ACTSET.copy_action_sets(
                           p_project_id_from   => x_orig_project_id ,
                           p_project_id_to     => x_new_project_id,
                           x_return_status     => l_return_status,
                           x_msg_count         => l_msg_count,
                           x_msg_data          => l_msg_data   );
             IF l_return_status <> fnd_api.g_ret_sts_success
             THEN
                  x_err_code := 844;
                  x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_COPY_PROJ_ACTSET');
                  x_err_stack := x_err_stack||'->PA_PROJ_STAT_ACTSET.copy_action_sets';
                  rollback to copy_project;
                  revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                  return;
             END IF;
        EXCEPTION WHEN OTHERS THEN
             x_err_code := 844;
--             x_err_stage := pa_project_core1.get_message_from_stack( null );
--             IF x_err_stage IS NULL
--             THEN
  x_err_stage := 'API: '||'PA_PROJ_STAT_ACTSET.copy_action_sets'||' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--             END IF;
             rollback to copy_project;
             revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
             return;
        END;

        BEGIN
             x_err_stage := 'Copy Task Progress Action Set';
             PA_TASK_PROG_ACTSET.copy_action_sets(
                           p_project_id_from   => x_orig_project_id ,
                           p_project_id_to     => x_new_project_id,
                           x_return_status     => l_return_status,
                           x_msg_count         => l_msg_count,
                           x_msg_data          => l_msg_data   );
             IF l_return_status <> fnd_api.g_ret_sts_success
             THEN
                  x_err_code := 866;
                  x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_COPY_TASK_ACTSET');
                  x_err_stack := x_err_stack||'->PA_TASK_PROG_ACTSET.copy_action_sets';
                  rollback to copy_project;
                  revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                  return;
             END IF;
        EXCEPTION WHEN OTHERS THEN
             x_err_code := 866;
--             x_err_stage := pa_project_core1.get_message_from_stack( null );
--             IF x_err_stage IS NULL
--             THEN
x_err_stage := 'API: '||'PA_TASK_PROG_ACTSET.copy_action_sets'||' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--             END IF;
             rollback to copy_project;
             revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
             return;
        END;

--END MW CHanges


   /* Bug#3480409 : FP.M Changes: Added code for copying Perf/Score rules, starts here  */
        BEGIN
             x_err_stage := 'Copy object Perf/Score rules';
             PA_PERF_EXCP_UTILS.copy_object_rule_assoc
                         ( p_from_object_type => 'PA_PROJECTS'
                          ,p_from_object_id   => x_orig_project_id
                          ,p_to_object_type   => 'PA_PROJECTS'
                          ,p_to_object_id     => x_new_project_id
                          ,x_return_status    => l_return_status
                          ,x_msg_count        => l_msg_count
                          ,x_msg_data         => l_msg_data   );

             IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                  x_err_code := 880;
                  x_err_stage := pa_project_core1.get_message_from_stack('PA_PERF_COPY_RULES_ERR');
                  x_err_stack := x_err_stack||'->PA_PERF_EXCP_UTILS.copy_object_rule_assoc';
                  rollback to copy_project;
                  revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                  return;
             END IF;
        EXCEPTION WHEN OTHERS THEN
             x_err_code  := 880;
             x_err_stage := 'API: '||'PA_Page_layout_Utils.copy_object_page_layouts'||' SQL error message: '||SUBSTR( SQLERRM,1,1900);
             rollback to copy_project;
             revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
             return;
        END;
   /* Bug#3480409 : FP.M Changes: Added code for copying Perf/Score rules, ends here  */

-- anlee
-- Copying item associations

   x_err_stage := 'Calling PA_EGO_WRAPPER_PUB.COPY_ITEM_ASSOCS API ...';

   BEGIN
   /*Following code added for selective copy project options. Tracking bug No 3464332*/
   OPEN  cur_get_flag('PR_ITEM_ASSOC_FLAG');
   FETCH cur_get_flag INTO l_pr_item_assoc_flag;
   CLOSE cur_get_flag;

   IF 'Y' = l_pr_item_assoc_flag THEN
     PA_EGO_WRAPPER_PUB.COPY_ITEM_ASSOCS
     ( p_project_id_from     => x_orig_project_id
      ,p_project_id_to       => x_new_project_id
      ,p_init_msg_list       => fnd_api.g_FALSE
      ,p_commit              => fnd_api.g_FALSE
      ,x_return_status       => l_return_status
      ,x_errorcode           => l_errorcode
      ,x_msg_count           => l_msg_count
      ,x_msg_data            => l_msg_data);

     if l_return_status <> 'S' then
       x_err_code := 710;
       x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_COPY_ITEM_ASSOCS');
       x_err_stack := x_err_stack||'->PA_EGO_WRAPPER_PUB.COPY_ITEM_ASSOCS';
       rollback to copy_project;
       revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
       return;
     end if;
    END IF; --for 'Y' = l_pr_item_assoc_flag
   EXCEPTION WHEN OTHERS THEN
     x_err_code := 710;
--     x_err_stage := pa_project_core1.get_message_from_stack( null );
--     IF x_err_stage IS NULL
--       THEN
         x_err_stage := 'API: '||'PA_EGO_WRAPPER_PUB.COPY_ITEM_ASSOCS'||
                        ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--     END IF;
     rollback to copy_project;
     revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
     return;
   END;
-- anlee end of changes

-- anlee
-- Ext Attribute changes
-- Bug 2904327
   x_err_stage := 'Calling PA_USER_ATTR_PUB.COPY_USER_ATTRS_DATA API ...';

   BEGIN
   /*Following code and IF condition added for selective copy project options. Tracking bug No 3464332*/
   OPEN  cur_get_flag('PR_USER_DEFN_ATT_FLAG');
   FETCH cur_get_flag INTO l_pr_user_defn_att_flag;
   CLOSE cur_get_flag;

   IF 'Y' = l_pr_user_defn_att_flag THEN
     PA_USER_ATTR_PUB.COPY_USER_ATTRS_DATA
     ( p_object_id_from      => x_orig_project_id
      ,p_object_id_to        => x_new_project_id
      ,p_object_type         => 'PA_PROJECTS'
      ,x_return_status       => l_return_status
      ,x_errorcode           => l_errorcode
      ,x_msg_count           => l_msg_count
      ,x_msg_data            => l_msg_data);

     if l_return_status <> 'S' then
       x_err_code := 16384;
       x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_COPY_PROJ_EXT_ATTR');
       x_err_stack := x_err_stack||'->PA_USER_ATTR_PUB.COPY_USER_ATTRS_DATA';
       rollback to copy_project;
       revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
       return;
     end if;
    END IF; --for 'Y' = l_pr_user_defn_att_flag
   EXCEPTION WHEN OTHERS THEN
     x_err_code := 16384;
     x_err_stage := 'API: '||'PA_USER_ATTR_PUB.COPY_USER_ATTRS_DATA'||
                    ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
     rollback to copy_project;
     revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
     return;
   END;
-- anlee end of changes

--EH Changes
--
-- Bug2787577. If x_template_flag = 'Y', do not call API pa_accum_proj_list.Insert_accum.
-- Encapsulated the EH changes inside the IF - END IF
--
     IF x_template_flag = 'N' THEN
        BEGIN
             x_err_stage := 'PSI Project List-Insert Accum';
             pa_accum_proj_list.Insert_Accum
                     ( p_project_id       => x_new_project_id
                      ,x_return_status    => l_return_status
                      ,x_msg_count        => l_msg_count
                      ,x_msg_data         => l_msg_data
                      );
             IF l_return_status <> fnd_api.g_ret_sts_success
             THEN
                  x_err_code := 735;
                  x_err_stage := pa_project_core1.get_message_from_stack('PA_ERR_INSERT_ACCUM');
                  x_err_stack   := x_err_stack||'->pa_accum_proj_list.Insert_Accum';
                  rollback to copy_project;
                  revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                  return;
             END IF;
        EXCEPTION WHEN OTHERS THEN
             x_err_code := 735;
--             x_err_stage := pa_project_core1.get_message_from_stack( null );
--             IF x_err_stage IS NULL
--             THEN
                x_err_stage := 'API: '||'pa_accum_proj_list.Insert_Accum'||' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--             END IF;
             rollback to copy_project;
             revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
             return;
        END;
      END IF;
-- Bug 2787577 Changes ends


        -- Call Agreement API to copy an agreement/fundings if exists.
        x_err_stage := 'copying agreement and funding ';

        if x_orig_template_flag = 'Y' then

       declare
          cursor cust is
        select 1
        from pa_project_copy_overrides
                where project_id = x_created_from_proj_id
                and field_name = 'CUSTOMER_NAME';

          ovr_cust  number;

       begin

        open cust;
        fetch cust into ovr_cust;

        -- If there is a customer option in Quick Entry and no
        -- override customer is entered, create no agreement since
        -- there is no project customer for the new project.
        if (cust%notfound or x_customer_id is not null) then

--EH Changes

                  BEGIN
                    pa_billing_core.copy_agreement(
                                x_orig_project_id,
                                x_new_project_id,
                            x_customer_id,
--MCA Sakthi for MultiAgreementCurreny Project
                                x_agreement_org_id,
                                x_agreement_currency,
                                x_agreement_amount,
--MCA Sakthi for MultiAgreementCurreny Project
                                x_template_flag,
                            x_delta,
                                x_err_code,
                                x_err_stage,
                                x_err_stack);

            if x_err_code <> 0 then
                        x_err_code := 745;
                        IF x_err_stage IS NULL
                        THEN
                            x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_COPY_AGREEMENT');
                        END IF;
                        x_err_stack := x_err_stack||'->pa_billing_core.copy_agreement';
                rollback to copy_project;
                revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
            return;
            end if;
                  EXCEPTION WHEN OTHERS THEN
                   x_err_code := 745;
--                   x_err_stage := pa_project_core1.get_message_from_stack( null );
--                   IF x_err_stage IS NULL
--                   THEN
                      x_err_stage := 'API: '||'pa_billing_core.copy_agreement'||
                                       ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
--                   END IF;
                   rollback to copy_project;
                   revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                   return;
                  END;
        end if;

       end;

        end if;  -- end of copy agreement

--commented out for bug 2981655 if (x_copy_budget_flag = 'Y') then
        --PA K Changes. As per request from Ramesh team we are removing all
        --the calls for budgets and calling one wrapper API instead.

     /* Bug 4188514 - If financial tasks are copied then only copy the budget versions  */
   IF l_is_fin_str_copied = 'Y' THEN
          BEGIN
           PA_FP_COPY_FROM_PKG.copy_finplans_from_project
                         ( p_source_project_id    => x_orig_project_id
                          ,p_target_project_id    => x_new_project_id
                          ,p_shift_days           => NVL(x_delta,0) -- 3874742 passing p_shift_days as 0 if x_delta is NULL
                          ,p_copy_version_and_elements => NVL(x_copy_budget_flag,'Y')    --bug 2981655. Default is always 'Y'. spoke to Ramesh
              ,p_agreement_amount     => x_agreement_amount  --2986930
                          ,x_return_status        => l_return_status
                          ,x_msg_count            => l_msg_count
                          ,x_msg_data             => l_msg_data
                         );
             IF l_return_status <> fnd_api.g_ret_sts_success
             THEN
                  IF l_msg_data IS NULL THEN
                      l_msg_data := 'PA_ERR_COPY_FINPLANS';
                  END IF ;
                  x_err_code := 750;
                  x_err_stage := pa_project_core1.get_message_from_stack(l_msg_data);
                  x_err_stack   := x_err_stack||'->PA_FP_COPY_FROM_PKG.copy_finplans_from_project';
                  rollback to copy_project;
                  revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                  return;
             END IF;
          EXCEPTION WHEN OTHERS THEN
             x_err_code := 750;
--             x_err_stage := pa_project_core1.get_message_from_stack( null );
--             IF x_err_stage IS NULL
--             THEN
                x_err_stage := 'API: '||'PA_FP_COPY_FROM_PKG.copy_finplans_from_project'||' SQL error message: '||
                                      SUBSTR( SQLERRM,1,1900);
--             END IF;
             rollback to copy_project;
             revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
             return;
          END;
       END IF; -- Bug 4188514

--commented out for bug 2981655 end if;  -- end of copy budget

--bug 3301192

-- Commented out for bug # 3620190.
/*
        BEGIN
                 PA_PROGRESS_REPORT_UTILS.copy_project_tab_menu(
                 p_src_project_id => x_orig_project_id,
                 p_dest_project_id => x_new_project_id,
                 x_msg_count => l_msg_count,
                 x_msg_data => l_msg_data,
                 x_return_status => l_return_status);
        EXCEPTION WHEN OTHERS THEN
             x_err_code := 755;
             x_err_stage := 'API: '||'PA_PROGRESS_REPORT_UTILS.copy_project_tab_menu'||' SQL error message: '||
                                      SUBSTR( SQLERRM,1,1900);
             rollback to copy_project;
             return;
        END;
*/
-- Commented out for bug # 3620190.

--bug 3301192
        --Bug 5378256/5137355 : Baseline budget should be created in the target only if src has one.
        --Bug 6857315 Modified the cursor to check if the self service approved revenue budget exists in
        --source or not. Earlier code used to check for old model budget only
        -- This code will check for both SS and old model.
        BEGIN
            select 'Y' into l_baseline_exists_in_src
            from pa_budget_versions pbv
            where pbv.project_id = x_orig_project_id
            and pbv.budget_status_code = 'B'
            and (budget_type_code='AR'
            	 or APPROVED_REV_PLAN_TYPE_FLAG = 'Y') -- Added for bug 6857315
            and rownum <=1;
        EXCEPTION
            When no_data_found then
            l_baseline_exists_in_src := 'N';
        END;


--EH Changes
--bug 2621734
        DECLARE

        BEGIN
              IF NVL( l_baseline_funding_flag, 'N' ) = 'Y'
                  and PA_BILLING_CORE.check_funding_exists(x_project_id =>  x_new_project_id) = 'Y'
                  and nvl(l_baseline_exists_in_src,'N') = 'Y'  --Bug 5378256/5137355
              THEN
                  PA_BASELINE_FUNDING_PKG.create_budget_baseline (
                     p_project_id          =>  x_new_project_id,
                     x_err_code            =>  x_err_code,
                     x_status              =>  x_err_stage );

                  IF x_err_code <> 0
                  THEN
                      x_err_code := 755;
                      x_err_stage := pa_project_core1.get_message_from_stack('PA_ERR_BUDGT_BASLINE');
                      x_err_stack   := x_err_stack||'->PA_BASELINE_FUNDING_PKG.create_budget_baseline';
                      rollback to copy_project;
                      revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
                      return;
                  END IF;
              END IF;
        EXCEPTION WHEN OTHERS THEN
             x_err_code := 755;
             x_err_stage := 'API: '||'PA_BASELINE_FUNDING_PKG.create_budget_baseline'||' SQL error message: '||
                                      SUBSTR( SQLERRM,1,1900);
             rollback to copy_project;
             revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
             return;
        END;
--bug 2621734

-- maansari
-- Task Association changes
-- Bug 3024607
/*  commenting out as the decision to include this is in b3 not yet made
   x_err_stage := 'Calling PA_TASK_PUB1.Copy_Task_Associations API ...';

   BEGIN
     PA_TASK_PUB1.Copy_Task_Associations
     ( p_project_id_from      => x_orig_project_id
      ,p_project_id_to        => x_new_project_id
      ,x_return_status       => l_return_status
      ,x_msg_count           => l_msg_count
      ,x_msg_data            => l_msg_data);

     if l_return_status <> 'S' then
       x_err_code := 760;
       x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_COPY_PROJ_TASK_ASSN');
       x_err_stack := x_err_stack||'->PA_TASK_PUB1.COPY_TASK_ASSOCIATIONS';
       rollback to copy_project;
       return;
     end if;
   EXCEPTION WHEN OTHERS THEN
     x_err_code := 760;
     x_err_stage := 'API: '||'PA_TASK_PUB1.COPY_TASK_ASSOCIATIONS'||
                    ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
     rollback to copy_project;
     return;
   END;
*/
-- 3024607 maansari end of changes
--bug 3068506 maansari Copy Task Attachments ( moved from PA_PROJECT_CORE2.copy_task )
/* Bug 3140032. It needs to be moved to PA_PROJ_TASK_STRUC_PUB.copy_structures_tasks_bulk api.
   x_err_stage := 'Copying task attachments..';
           Begin
             Declare
                  cursor c_attach_tasks is
                      select orig.proj_element_id orig_task_id,
                             new.proj_element_id new_task_id
                        from pa_proj_elements orig, pa_proj_elements new
                       where orig.project_id = x_orig_project_id
                         and new.element_number = orig.element_number
                         and new.project_id = x_new_project_id
                         and new.object_type = 'PA_TASKS'
                         and orig.object_type = 'PA_TASKS';

                   c_atch   c_attach_tasks%rowtype ;

             begin
                 open c_attach_tasks;
                 loop
                     fetch c_attach_tasks
                      into c_atch ;
                      if c_attach_tasks%notfound then
                         exit ;
                      end if;
                      fnd_attached_documents2_pkg.copy_attachments('PA_TASKS',
                                             c_atch.orig_task_id,
                                             null, null, null, null,
                                             'PA_TASKS',
                                             c_atch.new_task_id,
                                             null, null, null, null,
                                             FND_GLOBAL.USER_ID,
                                             FND_GLOBAL.LOGIN_ID,
                                             275, null, null);

                 end loop ;
                 close c_attach_tasks;
             exception
                 when NO_DATA_FOUND then
                      --rollback to copy_project;
                      --return;
                      null;
                 when others then
                     null;
             end ;
           end ;

       -- End of the attachment call
--end bug 3068506 maansari Copy Task Attachements
3140032  Moved to PA_PROJ_TASK_STRUC_PUB.copy_structures_tasks_bulk api*/

    x_project_id := x_new_project_id;
    x_err_stack := old_stack;
-- Check if WF is enabled for the new project status

        l_project_type := NULL;
        p_project_status_code := NULL;

        OPEN l_get_details_for_wf_csr (x_new_project_id);
        FETCH l_get_details_for_wf_csr INTO
          l_project_type,
              p_project_status_code;
        CLOSE l_get_details_for_wf_csr;
   IF (l_project_type IS NOT NULL AND p_project_status_code IS NOT NULL)
          THEN

        pa_project_stus_utils.check_wf_enabled
                           (x_project_status_code => p_project_status_code,
                            x_project_type        => l_project_type,
                            x_project_id          => x_new_project_id,
                            x_wf_item_type        => l_item_type,
                x_wf_process          => l_wf_process,
                            x_wf_enabled_flag     => l_wf_enabled_flag,
                            x_err_code            => l_err_code
                            );


-- 31-DEC-97, jwhite -----------------------------------------
-- Workflow is NOT coupled to changing statues.
-- So, the x_err_code for the aforementioned Check_Wf_Enabled
--- is IGNORED if x_err_code > 0.
--

    IF (l_err_code > 0)
     THEN
        x_err_code := 0;
    END IF;
-- ------------------------------------------------------------------

IF x_err_code = 0 THEN
             IF l_wf_enabled_flag = 'Y' THEN   -- start the project workflow
                UPDATE pa_projects
                SET wf_status_code = 'IN_ROUTE'
                WHERE project_id = x_new_project_id;
                Pa_project_wf.Start_Project_Wf
                           (p_project_id    => x_new_project_id,
                            p_err_stack     => x_err_stack,
                            p_err_stage     => x_err_stage,
                            p_err_code      => x_err_code );
             END IF;
       END IF;
   END IF;
  --SMukka Added this plsql block of code
/*    BEGIN
        PA_PERF_EXCP_UTILS.copy_object_rule_assoc
             (
                p_from_object_type =>'PA_PROJECTS'
               ,p_from_object_id   =>x_orig_project_id
               ,p_to_object_type   =>'PA_PROJECTS'
               ,p_to_object_id     =>x_project_id
               ,x_msg_count        =>l_msg_count
               ,x_msg_data         =>l_msg_data
               ,x_return_status    =>l_return_status
              );
        IF l_return_status <> 'S' THEN
            x_err_code := 905;
            x_err_stack := x_err_stack||'->PA_PERF_EXCP_UTILS.copy_object_rule_assoc';
            ROLLBACK TO copy_project;
            RETURN;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
             x_err_code  := SQLCODE;
             x_err_stage := 'PA_PERF_EXCP_UTILS.copy_object_rule_assoc: '||SUBSTRB(SQLERRM,1,240);
            ROLLBACK TO copy_project;
    END;*/

   /* Bug 3847507 : Shifted the foll. two calls to copy resource lists/rbs information to before
                   the call for copy_structure
    --Copy resource lists from source to destination project
    BEGIN
        PA_CREATE_RESOURCE.Copy_Resource_Lists( p_source_project_id      => x_orig_project_id
                                               ,p_destination_project_id => x_new_project_id
                                               ,x_return_status          => l_return_status ) ;
        IF l_return_status <> 'S' THEN
            x_err_code := 905;
            x_err_stack := x_err_stack||'->PA_CREATE_RESOURCE.Copy_Resource_Lists';
            ROLLBACK TO copy_project;
            RETURN;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_err_code := 905;
            x_err_stage := 'API: '||'PA_CREATE_RESOURCE.Copy_Resource_Lists'||
                           ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
            ROLLBACK TO copy_project;
            RETURN;
    END ;
    --Copy RBS associations from source to destination project
    BEGIN
        PA_RBS_ASGMT_PVT.Copy_Project_Assignment( p_rbs_src_project_id      => x_orig_project_id
                                                 ,p_rbs_dest_project_id     => x_new_project_id
                                                 ,x_return_status           => l_return_status ) ;
        IF l_return_status <> 'S' THEN
            x_err_code := 920;
            x_err_stack := x_err_stack||'->PA_RBS_ASGMT_PUB.Copy_Project_Assignment';
            ROLLBACK TO copy_project;
            RETURN;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_err_code := 920;
            x_err_stage := 'API: '||'PA_RBS_ASGMT_PUB.Copy_Project_Assignment'||
                           ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
            ROLLBACK TO copy_project;
            RETURN;
    END ; */

/* This code is moved to Copy_Project API for bug 4200168 so that BF can use attribute15 to access source task id in copy finplan API*/

 /* Now update back the attributes column in pa_proj_elements and pa_proj_element_versions with actual data from source project */
    UPDATE pa_proj_elements ppe1
    SET attribute15 = ( SELECT attribute15 FROM pa_proj_elements ppe2
                         WHERE ppe2.project_id = x_orig_project_id
                           AND ppe2.proj_element_id = ppe1.attribute15 )
    WHERE project_id = x_new_project_id ;

    UPDATE pa_proj_element_versions ppevs1
    SET attribute15 = ( SELECT attribute15 FROM pa_proj_element_versions ppevs2
                         WHERE ppevs2.project_id = x_orig_project_id
                         AND ppevs2.element_version_id = ppevs1.attribute15 )
    WHERE project_id = x_new_project_id ;

--Following code added for selective copy project changes. Tracking Bug no. 3464332
    --Delete all records from the global temporary table, used to store copy options in copy project
    DELETE FROM PA_PROJECT_COPY_OPTIONS_TMP;

--********************************************************
--DO NOT ADD ANY CODE AFTER THIS CALL. bug 3163280
--********************************************************
--Call the process updates WBS api to kick-off concurrent program or online processing.
   x_err_stage := 'Calling PA_PROJ_TASK_STRUC_PUB.CALL_PROCESS_WBS_UPDATES API ...';

if (x_copy_task_flag = 'Y' ) then   --no need to call for AMG. AMG has its own call.

   BEGIN
     PA_PROJ_TASK_STRUC_PUB.CALL_PROCESS_WBS_UPDATES
     ( p_dest_project_id     => x_new_project_id
      ,x_return_status       => l_return_status
      ,x_msg_count           => l_msg_count
      ,x_msg_data            => l_msg_data);

     if l_return_status <> 'S' then
       x_err_code := 1010;
       x_err_stage := pa_project_core1.get_message_from_stack( 'PA_ERR_PROCESS_WBS');
       x_err_stack := x_err_stack||'->PA_PROJ_TASK_STRUC_PUB.CALL_PROCESS_WBS_UPDATES';
       rollback to copy_project;
       revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
       return;
     end if;
   EXCEPTION WHEN OTHERS THEN
     x_err_code := 1010;
     x_err_stage := 'API: '||'PA_PROJ_TASK_STRUC_PUB.CALL_PROCESS_WBS_UPDATES'||
                    ' SQL error message: '||SUBSTR( SQLERRM,1,1900);
     rollback to copy_project;
     revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534
     return;
   END;
end if;
--********************************************************
--DO NOT ADD ANY CODE AFTER THIS CALL. bug 3163280
--********************************************************


exception
       when others then
           x_err_code := SQLCODE;
           x_err_stage := SUBSTRB(SQLERRM,1,240);
       rollback to copy_project;
       revert_proj_number(x_proj_number_gen_mode,x_new_project_number); -- Added for Bug# 7445534

end copy_project;

/*********************************************************************
** Get_Next_Avail_Proj_Num
**          Procedure to return the next available
**     Project number for automatic project numbering.
**
** Called when the new automatic project number generated is not unique.
**
** Parameters :
**    Start_proj_num - Project number(segment1) which was found to be
**                     non-unique. It starts from the next number.
**    No_tries       - The no of times it should loop around for checking
**                     the uniqueness of the project number.
**    Next_proj_num  - Next Project number
**    x_error_code   - 0 if unique number found in the tries specified
**                     1 if unique number not found
**                     SQLCODE (< 0) if exception raised.
**    x_err_stage  - Message
**    x_error_stack  - The Satck of procedures.
**
** Author - tsaifee
**
*********************************************************************/
Procedure Get_Next_Avail_Proj_Num (
                            Start_proj_num IN Number,
                             No_tries IN Number,
                             Next_proj_num IN OUT NOCOPY Number, --File.Sql.39 bug 4440895
                             x_error_code IN OUT NOCOPY Number, --File.Sql.39 bug 4440895
                             x_error_stack IN OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                             x_error_stage IN OUT NOCOPY Varchar2 ) --File.Sql.39 bug 4440895

IS
      Cursor C1(param_1 Number) IS
                   select project_id
                   from pa_projects_all
                   where segment1 = to_char(param_1);
      loop_cnt number := 0;
      x_id number;
      old_stack varchar2(630);

BEGIN

      old_stack := x_error_stack;
      x_error_code := 0;
      x_error_stack := x_error_stack || '->Get_Next_Avail_Num';
      next_proj_num := start_proj_num ;

      LOOP
         next_proj_num := next_proj_num + 1;
         loop_cnt := loop_cnt + 1;
         Open C1(next_proj_num);
         Fetch C1 into x_id;

         if (C1%NOTFOUND) then
            Close C1;
           /* Update the table with new-proj_num, because the unique
              Proj number proc will then return uniq identifier
              as the new proj number.                                */

            UPDATE PA_UNIQUE_IDENTIFIER_CONTROL
               Set Next_Unique_Identifier = next_proj_num
               Where Table_Name = 'PA_PROJECTS';
            x_error_stack := old_stack;
            Return ;
         end if;

         Close C1;
         if (loop_cnt = No_tries) then
            x_error_stage := 'PA_PR_EPR_PROJ_NAME_NOT_UNIQUE';
            x_error_code := 1;
            x_error_stack := old_stack;
            Return ;
         end if;
      END LOOP;

EXCEPTION
      When OTHERS then
         x_error_code := SQLCODE;
         Return ;

END  Get_Next_Avail_Proj_Num;

-------------------------------------------------------------
-- PROCEDURE            : populate_copy_options
-- PURPOSE              : This API should be called to populate values for copy options into the global
--                        temporary table PA_PROJECT_COPY_OPTIONS_TMP
-- PARAMETERS                         Type                 Required  Description and Purpose
-- ----------------------  -----------------------------   --------  ---------------------------------------------------
-- p_context_tbl           SYSTEM.PA_VARCHAR2_30_TBL_TYPE     Y      The context of the record
-- p_flag_tbl              SYSTEM.PA_VARCHAR2_1_TBL_TYPE      Y      Value would be 'Y' or 'N'
--                                                                   Context is a flag - Whether flag is selected or not
--                                                                   Context is 'WOKPLAN' - Publish upon creation flag
-- p_version_id_tbl        SYSTEM.PA_NUM_TBL_TYP              Y      Context is a flag - NULL
--                                                                   Context is 'WORKPLAN' - WP version id
--  +------------------------------------------------+
--   CONTEXT           FLAG          VERSION_ID
--  +------------------------------------------------+
--  <some flag>  whether selected    NULL
--  WORKPLAN     Pub upon creation   WP version id
--  WORKPLAN     NULL                NULL
--Context = WORKPLAN and Version_id as NULL indicates that no workplan versions are selected
--
-- HISTORY
-- 11-MAR-2004  sabansal  Created
PROCEDURE populate_copy_options( p_api_version      IN  NUMBER   := 1.0
                                ,p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE
                                ,p_commit           IN  VARCHAR2 := FND_API.G_FALSE
                                ,p_validate_only    IN  VARCHAR2 := FND_API.G_TRUE
                                ,p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
                                ,p_calling_module   IN  VARCHAR2 := 'SELF_SERVICE'
                                ,p_debug_mode       IN  VARCHAR2 := 'N'
                                ,p_context_tbl      IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
                                ,p_flag_tbl         IN SYSTEM.PA_VARCHAR2_1_TBL_TYPE  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE()
                                ,p_version_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE()
                                ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                ,x_msg_count      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                ,x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                ) IS
l_debug_mode                     VARCHAR2(1);
l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;
BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
        FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
        SAVEPOINT pop_copy_options;
     END IF;

     IF l_debug_mode = 'Y' THEN
        PA_DEBUG.set_curr_function( p_function   => 'populate_copy_options',
                                    p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
        Pa_Debug.g_err_stage:= 'Printing Input parameters';
        IF nvl(p_context_tbl.LAST,0) > 0 THEN
            Pa_Debug.WRITE(g_module_name, Pa_Debug.g_err_stage, l_debug_level3);
            FOR i IN p_context_tbl.FIRST..p_context_tbl.LAST LOOP
                Pa_Debug.WRITE(g_module_name,'p_context_tbl('||i||')'||':'||p_context_tbl(i),
                                       l_debug_level3);

                Pa_Debug.WRITE(g_module_name,'p_flag_tbl('||i||')'||':'||p_flag_tbl(i),
                                           l_debug_level3);

                Pa_Debug.WRITE(g_module_name,'p_version_id_tbl('||i||')'||':'||p_version_id_tbl(i),
                                           l_debug_level3);
            END LOOP;
        ELSE
            Pa_Debug.WRITE(g_module_name,'## Context table doesnot contain any values! ##',
                                       l_debug_level3);
        END IF;
     END IF;

    --First truncate the global temporary table
    DELETE FROM PA_PROJECT_COPY_OPTIONS_TMP;

    --If the table passed is not NULL
    IF nvl(p_context_tbl.LAST,0) > 0 THEN
        --Populate the records in the global temporary table
        FOR i IN p_context_tbl.FIRST..p_context_tbl.LAST LOOP
            INSERT INTO PA_PROJECT_COPY_OPTIONS_TMP(
                                     CONTEXT
                                    ,FLAG
                                    ,VERSION_ID
                                    )
                                    VALUES(
                                     p_context_tbl(i)
                                    ,p_flag_tbl(i)
                                    ,p_version_id_tbl(i)
                                    );
        END LOOP;
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

EXCEPTION
WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO pop_copy_options;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
       (  p_pkg_name        => 'PA_PROJECT_CORE1'
        , p_procedure_name  => 'populate_copy_options'
        , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                         l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;

END populate_copy_options;
----------------------------------------





-- PROCEDURE            : populate_default_copy_options
-- PURPOSE              : This API should be called to populate default values for copy options into the global
--                        temporary table PA_PROJECT_COPY_OPTIONS_TMP
-- PARAMETERS               Type    Required  Description and Purpose
-- ----------------------  ------   --------  ---------------------------------------------------
-- p_src_project_id        NUMBER     Y       The source project id from which the default copy
--                                            options would be populated
-- p_src_template_flag     VARCHAR2   Y       Whether the source is a project or a template
-- p_dest_template_flag    VARCHAR2   Y       Whether creating a project or a template
PROCEDURE populate_default_copy_options( p_api_version      IN  NUMBER := 1.0
                                        ,p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE
                                        ,p_commit           IN   VARCHAR2 := FND_API.G_FALSE
                                        ,p_validate_only    IN   VARCHAR2 := FND_API.G_TRUE
                                        ,p_validation_level IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
                                        ,p_calling_module   IN  VARCHAR2 := 'SELF_SERVICE'
                                        ,p_debug_mode       IN  VARCHAR2 := 'N'
                                        ,p_src_project_id     IN  NUMBER
                                        ,p_src_template_flag  IN VARCHAR2
                                        ,p_dest_template_flag IN VARCHAR2
                                        ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                        ,x_msg_count      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                        ,x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                        ) IS
CURSOR cur_wp_record_present IS
SELECT version_id
FROM   PA_PROJECT_COPY_OPTIONS_TMP ppcot
WHERE context = 'WORKPLAN';

CURSOR cur_get_wp_attr IS
SELECT ppwa.*
FROM   pa_proj_workplan_attr   ppwa
      ,pa_proj_structure_types ppst
      ,pa_structure_types      pst
WHERE  ppwa.project_id = p_src_project_id
AND    ppwa.proj_element_id = ppst.proj_element_id
AND    ppst.structure_type_id = pst.structure_type_id
AND    pst.structure_type = 'WORKPLAN' ;

--Cursor to retrieve all workplan versions from the source project
CURSOR cur_get_wp_versions IS
SELECT ppev.element_version_id, ppevs.status_code,
       ppevs.latest_eff_published_flag, ppevs.current_flag, ppevs.current_working_flag
FROM  pa_proj_element_versions   ppev,
      pa_proj_structure_types ppst,
      pa_structure_types         pst,
      pa_proj_elem_ver_structure ppevs
WHERE ppev.project_id = p_src_project_id
AND   ppev.object_type = 'PA_STRUCTURES'
AND   ppev.element_version_id = ppevs.element_version_id
AND   ppevs.project_id = p_src_project_id
AND   ppev.proj_element_id = ppst.proj_element_id
AND   ppst.structure_type_id = pst.structure_type_id
AND   pst.structure_type = 'WORKPLAN' ;

l_debug_mode                     VARCHAR2(1);
l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

l_workplan_enabled      VARCHAR2(1) := 'N';
l_wp_record_present     NUMBER(15);
l_shared                VARCHAR2(1);
l_versioning_enabled    VARCHAR2(1);
l_auto_pub_enabled      VARCHAR2(1);

l_wp_attr_rec            cur_get_wp_attr%ROWTYPE;
rec_wp_versions          cur_get_wp_versions%ROWTYPE;
l_src_ltspub_or_cw_version NUMBER(15);

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
        FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
        SAVEPOINT def_copy_options;
     END IF;

     IF l_debug_mode = 'Y' THEN
        PA_DEBUG.set_curr_function( p_function   => 'populate_default_copy_options',
                                    p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
        Pa_Debug.g_err_stage:= 'Printing Input parameters';
        Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                   l_debug_level3);

        Pa_Debug.WRITE(g_module_name,'p_src_project_id'||':'||p_src_project_id,
                                   l_debug_level3);

        Pa_Debug.WRITE(g_module_name,'p_src_template_flag'||':'||p_src_template_flag,
                                   l_debug_level3);

        Pa_Debug.WRITE(g_module_name,'p_dest_template_flag'||':'||p_dest_template_flag,
                                   l_debug_level3);
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Validating Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF ( ( p_src_project_id    IS NULL OR p_src_project_id    = FND_API.G_MISS_NUM  ) AND
          ( p_src_template_flag IS NULL OR p_src_template_flag = FND_API.G_MISS_CHAR )
        )
     THEN
           IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_PROJECT_CORE1 : populate_default_copy_options :
                                      p_src_project_id, p_src_template_flag are NULL';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
           END IF;
          RAISE Invalid_Arg_Exc;
     END IF;

    --First, insert default values for flags, in case they are not there
    INSERT INTO PA_PROJECT_COPY_OPTIONS_TMP(
     CONTEXT
    ,FLAG
    ,VERSION_ID
    )
    SELECT
     lookup_code
    ,decode(lookup_code,'WP_INTER_PROJ_DEPEND_FLAG','N',decode(lookup_code,'PR_FRM_SRC_TMPL_FLAG','N','Y') )
    ,null
    FROM pa_lookups
    WHERE lookup_type = 'PA_COPY_OPTIONS'
    AND   lookup_code NOT IN
          ( SELECT context
            FROM pa_project_copy_options_tmp
            WHERE context <> 'WORKPLAN'
          );

     IF l_debug_mode = 'Y' THEN
        Pa_Debug.WRITE(g_module_name, 'Inserted default flag values', l_debug_level3);
     END IF;

    l_workplan_enabled := PA_PROJECT_STRUCTURE_UTILS.check_workplan_enabled( p_src_project_id );

    IF NVL( l_workplan_enabled, 'N' ) = 'Y' THEN
        l_shared := PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled(p_src_project_id);
        --Get workplan attributes
        OPEN cur_get_wp_attr;
        FETCH cur_get_wp_attr INTO l_wp_attr_rec;
        CLOSE cur_get_wp_attr;

        l_versioning_enabled := l_wp_attr_rec.WP_ENABLE_VERSION_FLAG;
        l_auto_pub_enabled   := l_wp_attr_rec.AUTO_PUB_UPON_CREATION_FLAG;
    ELSE
        l_shared := 'N';
    END IF;

    OPEN cur_wp_record_present;
    FETCH cur_wp_record_present INTO l_wp_record_present;

    --If workplan is enabled and there is no record for workplan in global temporary table, then populate
    --values for default workplan versions to be copied
    IF 'Y' = l_workplan_enabled AND cur_wp_record_present%NOTFOUND THEN

        IF l_debug_mode = 'Y' THEN
            Pa_Debug.WRITE(g_module_name, 'Populating default workplan record(s)', l_debug_level3);
        END IF;

        --If creating a PROJECT
        IF 'N' = p_dest_template_flag THEN
            --IF source is PROJECT with VERSIONING ENABLED
            --   Select LATEST PUBLISHED, else the CURRENT WORKING version from the source project
            --   Flag = 'N'
            --END IF;
            --IF source is TEMPLATE WITH VERSIONING ENABLED or TEMPLATE/PROJECT WITH VERSIONING DISABLED
            --   Select single WP version in the source.
            --   Flag = 'Y' if VERSIONING IS DISABLED or Flag = Auto Pub Upon Creation if TEMPLATE WITH
            --   VERSIONING ENABLED
            --END IF;

            IF 'N' = p_src_template_flag AND 'Y' = l_versioning_enabled THEN
                 FOR rec_wp_versions IN cur_get_wp_versions LOOP
                    IF 'Y' = rec_wp_versions.latest_eff_published_flag THEN
                        l_src_ltspub_or_cw_version := rec_wp_versions.element_version_id ;
                        EXIT;
                    END IF;
                 END LOOP;
                 IF l_src_ltspub_or_cw_version IS NULL THEN
                    FOR rec_wp_versions IN cur_get_wp_versions LOOP
                        IF 'Y' = rec_wp_versions.current_working_flag THEN
                            l_src_ltspub_or_cw_version := rec_wp_versions.element_version_id;
                            EXIT;
                        END IF;
                    END LOOP;
                 END IF;

                 INSERT INTO PA_PROJECT_COPY_OPTIONS_TMP(
                  CONTEXT
                 ,FLAG
                 ,VERSION_ID )
                 VALUES(
                  'WORKPLAN'
                 ,'N'           --Publish Upon Creation should be unchecked by default
                 ,l_src_ltspub_or_cw_version );
            END IF;

            --If source is TEMPLATE WITH VERSIONING ENABLED or TEMPLATE/PROJECT WITH VERSIONING DISABLED
            IF 'Y' = p_src_template_flag OR 'N' = l_versioning_enabled THEN
                --In this case, there would be only a SINGLE WP version in the source project
                --So, the following loop will execute only ONCE
                FOR rec_wp_versions IN cur_get_wp_versions LOOP
                    INSERT INTO PA_PROJECT_COPY_OPTIONS_TMP(
                     CONTEXT
                    ,FLAG
                    ,VERSION_ID )
                    VALUES(
                     'WORKPLAN'
                    ,decode(l_versioning_enabled,'N','Y',l_auto_pub_enabled)
                    ,rec_wp_versions.element_version_id ) ;
                END LOOP;
                --Note: In case of versioning disabled for source project, always populate flag as 'Y'
            END IF;

        ELSE
        --IF creating a TEMPLATE

            FOR rec_wp_versions IN cur_get_wp_versions LOOP
                IF 'Y' = rec_wp_versions.latest_eff_published_flag THEN
                    l_src_ltspub_or_cw_version := rec_wp_versions.element_version_id ;
                    EXIT;
                END IF;
             END LOOP;
             IF l_src_ltspub_or_cw_version IS NULL THEN
                FOR rec_wp_versions IN cur_get_wp_versions LOOP
                    IF 'Y' = rec_wp_versions.current_working_flag THEN
                        l_src_ltspub_or_cw_version := rec_wp_versions.element_version_id;
                        EXIT;
                    END IF;
                END LOOP;
             END IF;

             INSERT INTO PA_PROJECT_COPY_OPTIONS_TMP(
              CONTEXT
             ,FLAG
             ,VERSION_ID )
             VALUES(
              'WORKPLAN'
             ,'N'           --Publish Upon Creation should be unchecked by default
             ,l_src_ltspub_or_cw_version );

        END IF;--IF destination is a project
    END IF;--IF 'Y' = l_workplan_enabled AND cur_wp_record_present%NOTFOUND

    CLOSE cur_wp_record_present;

    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;

EXCEPTION
WHEN Invalid_Arg_Exc THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := ' PA_PROJECT_CORE1 : populate_default_copy_options : NULL parameters passed';

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO def_copy_options;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   (  p_pkg_name         => 'PA_PROJECT_CORE1'
                    , p_procedure_name   => 'populate_default_copy_options'
                    , p_error_text       => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO def_copy_options;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
       ( p_pkg_name         => 'PA_PROJECT_CORE1'
        , p_procedure_name  => 'populate_default_copy_options'
        , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

END populate_default_copy_options;

END PA_PROJECT_CORE1 ;

/
