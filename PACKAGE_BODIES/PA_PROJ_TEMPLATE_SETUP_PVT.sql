--------------------------------------------------------
--  DDL for Package Body PA_PROJ_TEMPLATE_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_TEMPLATE_SETUP_PVT" AS
/* $Header: PATMSTVB.pls 120.4.12010000.2 2008/10/27 17:03:36 atshukla ship $ */

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_PROJ_TEMPLATE_SETUP_PVT';

-- API name                      : Create_Project_Template
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
--p_project_number              IN VARCHAR2
--p_project_name                  IN VARCHAR2
--p_project_type                  IN VARCHAR2
--p_organization_id         IN NUMBER
--p_organization_name           IN VARCHAR2
--p_effective_from_date         IN DATE
--p_effective_to_date           IN DATE
--p_description               IN VARCHAR2

PROCEDURE Create_Project_Template(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_number       IN    VARCHAR2,
 p_project_name       IN    VARCHAR2,
 p_project_type       IN    VARCHAR2,
 p_organization_id  IN    NUMBER      := -9999,
 p_effective_from_date  IN    DATE        := TO_DATE( '01-01-1000', 'DD-MM-YYYY' ),
 p_effective_to_date    IN    DATE        := TO_DATE( '01-01-1000', 'DD-MM-YYYY' ),
 p_description        IN    VARCHAR2    := 'JUNK_CHARS',
 p_security_level     IN    NUMBER      := 0,
-- anlee
-- Project Long Name changes
 p_long_name          IN    VARCHAR2  DEFAULT NULL,
-- End of changes
 p_operating_unit_id  IN    NUMBER, -- 4363092 MOAC changes
 x_template_id        OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Create_Project_Template';
   l_api_version                   CONSTANT NUMBER      := 1.0;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);
   l_error_message_code            VARCHAR2(250);

   l_organization_id               NUMBER;
   l_template_id                   NUMBER;

   l_Status_code                      VARCHAR2(80);
   l_service_type_code                VARCHAR2(80);
   l_cost_ind_rate_sch_id             NUMBER;
   l_labor_sch_type                   VARCHAR2(80);
   l_labor_bill_rate_org_id           NUMBER;
   l_labor_std_bill_rate_schdl        VARCHAR2(80);
   l_non_labor_sch_type               VARCHAR2(80);
   l_non_labor_bill_rate_org_id       NUMBER;
   l_nl_std_bill_rate_schdl           VARCHAR2(80);
   l_rev_ind_rate_sch_id              NUMBER;
   l_inv_ind_rate_sch_id              NUMBER;
   l_labor_invoice_format_id          NUMBER;
   l_non_labor_invoice_format_id      NUMBER;
   l_Burden_cost_flag                 VARCHAR2(80);
   l_interface_asset_cost_code        VARCHAR2(80);
   l_cost_sch_override_flag           VARCHAR2(80);
   l_billing_offset                   NUMBER;
   l_billing_cycle_id                 NUMBER;
   l_cc_prvdr_flag                    VARCHAR2(80);
   l_bill_job_group_id                NUMBER;
   l_cost_job_group_id                NUMBER;
   l_work_type_id                     NUMBER;
   l_role_list_id                     NUMBER;
   l_unassigned_time                  VARCHAR2(1);
   l_emp_bill_rate_schedule_id        NUMBER;
   l_job_bill_rate_schedule_id        NUMBER;
   l_budgetary_override_flag          VARCHAR2(80);
   l_baseline_funding_flag            VARCHAR2(80);
   l_non_lab_std_bill_rt_sch_id       NUMBER;
   l_project_type_class_code          VARCHAR2(80);
   l_effective_from_date              DATE;
   l_effective_to_date                DATE;

-- anlee
-- patchset K changes
   l_revaluate_funding_flag           VARCHAR2(1);
   l_include_gains_losses_flag      VARCHAR2(1);
-- End of changes

   l_row_id                           VARCHAR2(18);
   l_task_id                          NUMBER;
   l_billable_flag                    VARCHAR2(1);

   CURSOR Cur_proj_id
   IS
     SELECT pa_projects_s.nextval
       FROM sys.dual;

   CURSOR cur_currency
   IS
    SELECT FC.Currency_Code, imp.org_id, imp.exp_start_org_id, imp.exp_org_structure_version_id
      FROM FND_CURRENCIES FC,
           GL_SETS_OF_BOOKS GB,
           PA_IMPLEMENTATIONS IMP
     WHERE FC.Currency_Code = DECODE(IMP.Set_Of_Books_ID, Null,
                                     Null,GB.CURRENCY_CODE)
       AND GB.Set_Of_Books_ID = IMP.Set_Of_Books_ID;

  l_cur_currency   cur_currency%ROWTYPE;

  --bug2319133
  CURSOR cur_dist_rule
  IS
/*    SELECT r.distribution_rule
      FROM pa_project_type_distributions d, pa_distribution_rules r
     WHERE d.distribution_rule = r.distribution_rule
       AND project_type = p_project_type
       AND default_flag = 'Y';
*/
--copied from project_folder1.project_type_mir1 when-validate-item validation trigger.

       select distribution_rule
         from pa_project_type_distributions
        where project_type = p_project_type
          and default_flag = 'Y';

  l_distribution_rule   VARCHAR2(20);
  --bug2319133

  cursor cur_impl
  is
    select adv_action_set_id, multi_currency_billing_flag, default_rate_type
           ,retn_accounting_flag, competence_match_wt, availability_match_wt, job_level_match_wt
      from pa_implementations;

  l_adv_action_set_id   NUMBER;
  l_rate_date_code      VARCHAR2(30);
  l_rate_type           VARCHAR2(30);
  l_mcb_flag            VARCHAR2(1);
  l_retn_accounting_flag VARCHAR2(1);
  l_competence_match_wt   NUMBER;
  l_availability_match_wt NUMBER;
  l_job_level_match_wt    NUMBER;
  l_public_sector_flag    VARCHAR2(1);
  l_rate_type2            VARCHAR2(30);

  l_location_id           NUMBER;
  x_rowid                 VARCHAR2(18);
  l_city_name             VARCHAR2(250);
  l_country_code          VARCHAR2(250);
  l_country_name          VARCHAR2(250);

/* Type of l_region_name has been changed to %TYPE from varchar2 for the UTF8 change */
  l_region_name         hr_locations_all.region_1%TYPE;

   x_err_code           Number := 0;
   x_err_stage          Varchar2(80);
   x_err_stack          Varchar2(630);

   t_project_type_class_code   VARCHAR2(30);
   l_calendar_id        NUMBER;
   l_calendar_name      VARCHAR2(250);

   Cursor Get_def_Res_List is
   Select Default_Resource_List_Id,
          pa_resource_list_assignments_s.nextval
     from pa_project_types
    where project_type = p_project_type;

    x_def_res_list_id     Number := 0;
    x_def_use_Code   Varchar2(30) := 'ACTUALS_ACCUM';
    x_def_flag       Varchar2(1)  := 'Y';
    x_user_id        Number := To_Number (FND_PROFILE.VALUE('USER_ID'));
    x_login_id       Number := To_Number (FND_PROFILE.VALUE('LOGIN_ID'));
    x_rl_asgmt_id    Number := 0;
    l_BTC_COST_BASE_REV_CODE       VARCHAR2(90);    --bug 2755727

--PA L 2872708
   l_asset_allocation_method      VARCHAR2(30);
   l_CAPITAL_EVENT_PROCESSING     VARCHAR2(30);
   l_CINT_RATE_SCH_ID             NUMBER;
--PA L 2872708


l_warnings_only_flag VARCHAR2(1) := 'N'; --bug3134205


--sunkalya:federal Bug#5511353

l_date_eff_funds_flag VARCHAR2(1);

--sunkalya:federal Bug#5511353

l_ar_rec_notify_flag   VARCHAR2(1) := 'N';   -- 7508661 : EnC
l_auto_release_pwp_inv VARCHAR2(1) := 'Y';   -- 7508661 : EnC

BEGIN
    pa_debug.init_err_stack ('PA_PROJ_TEMPLATE_SETUP_PVT.Create_Project_Template');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PVT.Create_Project_Template begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Create_Project_Template;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Check for not null
    PA_PROJ_TEMPLATE_SETUP_UTILS.Check_Template_attr_req(
                   p_project_number        => p_project_number
                  ,p_project_name          => p_project_name
                  ,p_project_type          => p_project_type
                  ,p_organization_id       => p_organization_id
                  ,x_return_status         => l_return_status
                  ,x_error_msg_code        => l_error_msg_code
               );

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => l_error_msg_code);
       x_msg_data := l_error_msg_code;
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    --check for project number uniqueness
    IF pa_project_utils.check_unique_project_number (x_project_number  => p_project_number
                                                     ,x_rowid           => null ) = 0
    THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_SETUP_TMPL_NUM_NOT_UNIQUE' );
       --x_msg_data := 'PA_PR_EPR_PROJ_NUM_NOT_UNIQUE';
       x_msg_data := 'PA_SETUP_TMPL_NUM_NOT_UNIQUE';
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    --check for project name uniqueness
    IF pa_project_utils.check_unique_project_name (x_project_name  => p_project_name
                                                   ,x_rowid           => null ) = 0
    THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_SETUP_TMPL_NAME_NOT_UNIQUE' );
       --x_msg_data := 'PA_PR_EPR_PROJ_NAME_NOT_UNIQUE';
       x_msg_data := 'PA_SETUP_TMPL_NAME_NOT_UNIQUE';
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    -- anlee
    -- Project Long Name changes
    -- check for long name uniqueness
    IF pa_project_utils.check_unique_long_name (p_long_name, null ) = 0
    THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_PR_EPR_LONG_NAME_NOT_UNIQUE' );
       --x_msg_data := 'PA_PR_EPR_LONG_NAME_NOT_UNIQUE';
       x_msg_data := 'PA_PR_EPR_LONG_NAME_NOT_UNIQUE';
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    -- End of changes

    IF p_effective_from_date = TO_DATE( '01-01-1000', 'DD-MM-YYYY' )
    THEN
       l_effective_from_date := null;
    ELSE
       l_effective_from_date := p_effective_from_date;
    END IF;

    IF p_effective_to_date = TO_DATE( '01-01-1000', 'DD-MM-YYYY' )
    THEN
       l_effective_to_date := null;
    ELSE
       l_effective_to_date := p_effective_to_date;
    END IF;

    IF  l_effective_from_date IS NOT NULL AND
        l_effective_to_date IS NOT NULL
    THEN
        --Check the start and end dates
        IF l_effective_from_date > l_effective_to_date
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_SETUP_CHK_ST_EN_DATE');
            x_msg_data := 'PA_SETUP_CHK_ST_EN_DATE';
            x_return_status := 'E';
            RAISE  FND_API.G_EXC_ERROR;
        END IF;
    ELSIF l_effective_from_date IS NULL AND
          l_effective_to_date IS NOT NULL
    THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_SETUP_ST_DT_WO_EN_DT');
       x_msg_data := 'PA_SETUP_ST_DT_WO_EN_DT';
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    PA_PROJ_TEMPLATE_SETUP_UTILS.Get_Project_Type_Defaults(
                 p_project_type                     => p_project_type
                ,x_Status_code                      => l_Status_code
                ,x_service_type_code                => l_service_type_code
                ,x_cost_ind_rate_sch_id             => l_cost_ind_rate_sch_id
                ,x_labor_sch_type                   => l_labor_sch_type
                ,x_labor_bill_rate_org_id           => l_labor_bill_rate_org_id
                ,x_labor_std_bill_rate_schdl        => l_labor_std_bill_rate_schdl
                ,x_non_labor_sch_type               => l_non_labor_sch_type
                ,x_non_labor_bill_rate_org_id       => l_non_labor_bill_rate_org_id
                ,x_nl_std_bill_rate_schdl           => l_nl_std_bill_rate_schdl
                ,x_rev_ind_rate_sch_id              => l_rev_ind_rate_sch_id
                ,x_inv_ind_rate_sch_id              => l_inv_ind_rate_sch_id
                ,x_labor_invoice_format_id          => l_labor_invoice_format_id
                ,x_non_labor_invoice_format_id      => l_non_labor_invoice_format_id
                ,x_Burden_cost_flag                 => l_Burden_cost_flag
                ,x_interface_asset_cost_code        => l_interface_asset_cost_code
                ,x_cost_sch_override_flag           => l_cost_sch_override_flag
                ,x_billing_offset                   => l_billing_offset
                ,x_billing_cycle_id                 => l_billing_cycle_id
                ,x_cc_prvdr_flag                    => l_cc_prvdr_flag
                ,x_bill_job_group_id                => l_bill_job_group_id
                ,x_cost_job_group_id                => l_cost_job_group_id
                ,x_work_type_id                     => l_work_type_id
                ,x_role_list_id                     => l_role_list_id
                ,x_unassigned_time                  => l_unassigned_time
                ,x_emp_bill_rate_schedule_id        => l_emp_bill_rate_schedule_id
                ,x_job_bill_rate_schedule_id        => l_job_bill_rate_schedule_id
                ,x_budgetary_override_flag          => l_budgetary_override_flag
                ,x_baseline_funding_flag            => l_baseline_funding_flag
                ,x_non_lab_std_bill_rt_sch_id       => l_non_lab_std_bill_rt_sch_id
                ,x_project_type_class_code          => l_project_type_class_code
-- anlee
-- Changes for patchset K
                ,x_revaluate_funding_flag           => l_revaluate_funding_flag
                ,x_include_gains_losses_flag      => l_include_gains_losses_flag
-- End of changes
--PA L Changes 2872708
                ,x_asset_allocation_method         => l_asset_allocation_method
                ,x_CAPITAL_EVENT_PROCESSING        => l_CAPITAL_EVENT_PROCESSING
                ,x_CINT_RATE_SCH_ID                => l_CINT_RATE_SCH_ID
--PA L Changes 2872708
--bug#5511353. Federal changes.
		,x_date_eff_funds_flag	            => l_date_eff_funds_flag
--bug#5511353. Federal changes.
                ,x_ar_rec_notify_flag               => l_ar_rec_notify_flag    -- 7508661 : EnC
                ,x_auto_release_pwp_inv             => l_auto_release_pwp_inv  -- 7508661 : EnC
                ,x_return_status                    => l_return_status
                ,x_error_msg_code                   => l_error_msg_code
           );

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => l_error_msg_code);
       x_msg_data := l_error_msg_code;
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    --Organization Location Validations
      pa_location_utils.Get_ORG_Location_Details
       (p_organization_id   => p_organization_id,
        x_country_name      => l_country_name,
        x_city              => l_city_name,
        x_region              => l_region_name,
        x_country_code      => l_country_code,
        x_return_status     => l_return_status,
        x_error_message_code    => l_error_message_code);

      IF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => l_error_message_code);
          x_msg_data := l_error_msg_code;
          x_return_status := 'E';
          RAISE  FND_API.G_EXC_ERROR;
      END IF;

      pa_location_utils.check_location_exists(
                  p_country_code  => l_country_code,
                  p_city          => l_city_name,
                  p_region        => l_region_name,
                  x_return_status => l_return_status,
                  x_location_id   => l_location_id);

      If l_location_id is null then

/* Commented the below line for bug 2688170 */
        /* If l_city_name is not null
            and l_region_name is not null */
            If l_country_code is not null then

             pa_locations_pkg.INSERT_ROW(
                p_CITY              => l_city_name,
                p_REGION        => l_region_name,
                p_COUNTRY_CODE          => l_country_code,
                p_CREATION_DATE         => SYSDATE,
                p_CREATED_BY        => FND_GLOBAL.USER_ID,
                p_LAST_UPDATE_DATE  => SYSDATE,
                p_LAST_UPDATED_BY   => FND_GLOBAL.USER_ID,
                p_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID,
                X_ROWID             => x_rowid,
                X_LOCATION_ID           => l_location_id);

         end if;

    end if;

    pa_schedule_pub.GET_PROJ_CALENDAR_DEFAULT
     ( p_proj_organization    => p_organization_id,
       p_project_id             => null,
       x_calendar_id            => l_calendar_id,
       x_calendar_name        => l_calendar_name,
       x_return_status        => l_return_status,
       x_msg_count        => l_msg_count,
       x_msg_data               => l_msg_data);

      IF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => l_msg_data);
          x_msg_data := l_msg_data;
          x_return_status := 'E';
          RAISE  FND_API.G_EXC_ERROR;
      END IF;


    --default public sector flag from profile options.
    l_public_sector_flag :=  fnd_profile.value ('PA_DEFAULT_PUBLIC_SECTOR');

    --Call table handler for pa_projects_all
    OPEN Cur_proj_id;
    FETCH Cur_proj_id INTO l_template_id;
    CLOSE Cur_proj_id;
    x_template_id := l_template_id;

    OPEN cur_currency;
    FETCH cur_currency INTO l_cur_currency;
    CLOSE cur_currency;

    OPEN cur_dist_rule;
    FETCH cur_dist_rule INTO l_distribution_rule;
    CLOSE cur_dist_rule;

    OPEN cur_impl;
    FETCH cur_impl INTO l_adv_action_set_id, l_mcb_flag, l_rate_type
           ,l_retn_accounting_flag, l_competence_match_wt, l_availability_match_wt, l_job_level_match_wt;
    CLOSE cur_impl;

    l_rate_type2 := l_rate_type;

    IF l_cc_prvdr_flag = 'Y'
    THEN
        l_mcb_flag := 'N';
    END IF;

    IF l_mcb_flag = 'N'
    THEN
       l_rate_date_code := null;
       l_rate_type := null;
       l_BTC_COST_BASE_REV_CODE := NULL;                  --bug 2755727
    ELSE
       l_rate_date_code := 'PA_INVOICE_DATE';
       l_BTC_COST_BASE_REV_CODE := 'EXP_TRANS_CURR';      --bug 2755727
    END IF;

--Validdate attribute change from WHEN-VALIDATE-RECORD projects form
--The following validation is done in forms when a template is created.

        pa_project_utils2.validate_attribute_change
           ('ORGANIZATION_VALIDATION'           -- X_context
           , 'INSERT'                                           -- X_insert_update_mode
           , 'SELF_SERVICE'                              -- X_calling_module
           , null                                                  -- X_project_id
           , NULL                                               -- X_task_id
           /*, p_organization_id                              -- X_old_value     --no change  Commented for bug 2981386 */
       , NULL                                        /* Added for bug 2981386 */
           , p_organization_id                              -- X_new_value
           , p_project_type                                  -- X_project_type
           , null                                                  --
           , null
           , l_public_sector_flag                           -- X_public_sector_flag
           , NULL                                               -- X_task_manager_person_id
           , NULL                                               -- X_service_type
           , NULL                                               -- X_task_start_date
           , NULL                                               -- X_task_end_date
           , FND_GLOBAL.USER_ID                   -- X_entered_by_user_id
           , null                                                  -- X_attribute_category
           , null                                                  -- X_attribute1
           , null                                                  -- X_attribute2
           , null                                                  -- X_attribute3
           , null                                                  -- X_attribute4
           , null                                                  -- X_attribute5
           , null                                                 -- X_attribute6
           , null                                                 -- X_attribute7
           , null                                                 -- X_attribute8
           , null                                                 -- X_attribute9
           , null                                                 -- X_attribute10
           , null                                                 -- X_pm_project_code
           , null                                                 -- X_pm_project_reference
           , NULL                                              -- X_pm_task_reference
           , 'Y'                                                  -- X_functional_security_flag
           , l_warnings_only_flag --bug3134205
           , x_err_code                                     -- X_err_code
           , x_err_stage                                    -- X_err_stage
           , x_err_stack);                                  -- X_err_stack


        if x_err_code <> 0 /* and x_err_code <> 15 */ Then   /* Commented for bug 2393975 */

           if x_err_stage = 'PA_INVALID_PT_CLASS_ORG' then

              select    meaning
                into    t_project_type_class_code
                from    pa_project_types pt ,pa_lookups lps
               where    pt.project_type  = p_project_type
                 and    lps.lookup_type(+) = 'PROJECT TYPE CLASS'
                 and    lps.lookup_code(+) = pt.project_type_class_code;

    /* Code addition for bug 2393975 begins */
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                p_msg_name       => 'PA_INVALID_PT_CLASS_ORG',
                p_token1         => 'PT_CLASS',
                p_value1         => t_project_type_class_code);
       else
                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => x_err_stage);
           end if;
    /* Code addition for bug 2393975 ends */

/* Commented for bug 2393975
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                p_msg_name       => x_err_stage,
                p_token1         => 'PT_CLASS',
                p_value1         => t_project_type_class_code);
*/
           x_msg_data := x_err_stage;
           x_return_status := 'E';
           RAISE  FND_API.G_EXC_ERROR;

        End If;

    IF t_project_type_class_code <> 'CONTRACT'
    THEN
       l_labor_sch_type := null;
       l_non_labor_sch_type := null;
    END IF;

    IF t_project_type_class_code = 'CONTRACT'
    THEN
       IF l_non_labor_sch_type = 'B'
       THEN
          IF l_labor_sch_type = 'B'
          THEN
             l_rev_ind_rate_sch_id := null;
             l_inv_ind_rate_sch_id := null;
          END IF;
       ELSIF l_non_labor_sch_type = 'I'
       THEN
          l_nl_std_bill_rate_schdl := null;
          l_non_labor_bill_rate_org_id := null;
       END IF;

       IF l_labor_sch_type = 'I'
       THEN
           l_emp_bill_rate_Schedule_id := null;
           l_job_bill_rate_Schedule_id := null;
       END IF;
    END IF;


    PA_PROJECTS_PKG.INSERT_ROW(
                        X_Rowid                              => l_row_id
                       ,X_Project_Id                         => l_template_id
                       ,X_Name                               => p_project_name
                       ,X_Segment1                           => p_project_number
                       ,X_Last_Update_Date                   => SYSDATE
                       ,X_Last_Updated_By                    => FND_GLOBAL.USER_ID
                       ,X_Creation_Date                      => SYSDATE
                       ,X_Created_By                         => FND_GLOBAL.USER_ID
                       ,X_Last_Update_Login                  => FND_GLOBAL.LOGIN_ID
                       ,X_Project_Type                       => p_project_type
                       ,X_Carrying_Out_Organization_Id       => p_organization_id
                       ,X_Public_Sector_Flag                 => NVL( l_public_sector_flag, 'N' )
                       ,X_Project_Status_Code                => l_Status_code
                       ,X_Description                        => p_description
                       ,X_Start_Date                         => null
                       ,X_Completion_Date                    => null
                       ,X_Closed_Date                        => null
                       ,X_Distribution_Rule                  => l_distribution_rule
                       ,X_Labor_Invoice_Format_Id            => l_labor_invoice_format_id
                       ,X_NL_Invoice_Format_Id           => l_non_labor_invoice_format_id
                       ,X_Retention_Invoice_Format_Id        => null
                       ,X_Retention_Percentage               => null
                       ,X_Billing_Offset                     => l_billing_offset
                       ,X_Billing_Cycle_Id                   => l_billing_cycle_id
                       ,X_Labor_Std_Bill_Rate_Schdl          => l_labor_std_bill_rate_schdl
                       ,X_Labor_Bill_Rate_Org_Id             => l_labor_bill_rate_org_id
                       ,X_Labor_Schedule_Fixed_Date          => null
                       ,X_Labor_Schedule_Discount            => null
                       ,X_NL_Std_Bill_Rate_Schdl         => l_nl_std_bill_rate_schdl
                       ,X_NL_Bill_Rate_Org_Id            => l_non_labor_bill_rate_org_id
                       ,X_NL_Schedule_Fixed_Date         => null
                       ,X_NL_Schedule_Discount           => null
                       ,X_Limit_To_Txn_Controls_Flag         => 'N'
                       ,X_Project_Level_Funding_Flag         => null --as in forms
                       ,X_Invoice_Comment                    => null
                       ,X_Unbilled_Receivable_Dr             => null
                       ,X_Unearned_Revenue_Cr                => null
                       ,X_Summary_Flag                       => 'N'
                       ,X_Enabled_Flag                       => 'Y'
                       ,X_Segment2                           => null
                       ,X_Segment3                           => null
                       ,X_Segment4                           => null
                       ,X_Segment5                           => null
                       ,X_Segment6                           => null
                       ,X_Segment7                           => null
                       ,X_Segment8                           => null
                       ,X_Segment9                           => null
                       ,X_Segment10                          => null
                       ,X_Attribute_Category                 => null
                       ,X_Attribute1                         => null
                       ,X_Attribute2                         => null
                       ,X_Attribute3                         => null
                       ,X_Attribute4                         => null
                       ,X_Attribute5                         => null
                       ,X_Attribute6                         => null
                       ,X_Attribute7                         => null
                       ,X_Attribute8                         => null
                       ,X_Attribute9                         => null
                       ,X_Attribute10                        => null
                       ,X_Cost_Ind_Rate_Sch_Id               => l_cost_ind_rate_sch_id
                       ,X_Rev_Ind_Rate_Sch_Id                => l_rev_ind_rate_sch_id
                       ,X_Inv_Ind_Rate_Sch_Id                => l_inv_ind_rate_sch_id
                       ,X_Cost_Ind_Sch_Fixed_Date            => null
                       ,X_Rev_Ind_Sch_Fixed_Date             => null
                       ,X_Inv_Ind_Sch_Fixed_Date             => null
                       ,X_Labor_Sch_Type                     => l_labor_sch_type
                       ,X_Non_Labor_Sch_Type                 => l_non_labor_sch_type
                       ,X_Template_Flag                      => 'Y'
                       ,X_Verification_Date                  => null
                       ,X_Created_From_Project_Id            => null  --l_template_id
                       ,X_Template_Start_Date                => l_effective_from_date
                       ,X_Template_End_Date              => l_effective_to_date
                       ,X_Project_Currency_Code              => l_cur_currency.currency_code
                       ,X_Allow_Cross_Charge_Flag            => 'N'
                       ,X_Project_Rate_Date                  => null
                       ,X_Project_Rate_Type                  => l_rate_type2
                       ,X_Output_Tax_Code                    => null
                       ,X_Retention_Tax_Code                 => null
                       ,X_CC_Process_Labor_Flag              => 'N'
                       ,X_Labor_Tp_Schedule_Id               => null
                       ,X_Labor_Tp_Fixed_Date                => null
                       ,X_CC_Process_NL_Flag                 => 'N'
                       ,X_Nl_Tp_Schedule_Id                  => null
                       ,X_Nl_Tp_Fixed_Date                   => null
                       ,X_CC_Tax_Task_Id                     => null
                       ,x_bill_job_group_id                  => l_bill_job_group_id
                       ,x_cost_job_group_id                  => l_cost_job_group_id
                       ,x_role_list_id                       => l_role_list_id
                       ,x_work_type_id                       => l_work_type_id
                       ,x_calendar_id                        => l_calendar_id
                       ,x_location_id                        => l_location_id
                       ,x_probability_member_id              => null
                       ,x_project_value                      => null
                       ,x_expected_approval_date             => null
                       ,x_team_template_id                   => null
                       ,x_job_bill_rate_schedule_id          => l_job_bill_rate_schedule_id
                       ,x_emp_bill_rate_schedule_id          => l_emp_bill_rate_schedule_id
                       ,x_competence_match_wt                => l_competence_match_wt
                       ,x_availability_match_wt              => l_availability_match_wt
                       ,x_job_level_match_wt                 => l_job_level_match_wt
                       ,x_enable_automated_search            => 'N'
                       ,x_search_min_availability            => 100
                       ,x_search_org_hier_id                 => l_cur_currency.exp_org_structure_version_id
                       ,x_search_starting_org_id             => l_cur_currency.exp_start_org_id
                       ,x_search_country_code                => null
                       ,x_min_cand_score_reqd_for_nom        => 100
                       ,x_non_lab_std_bill_rt_sch_id         => l_non_lab_std_bill_rt_sch_id
                       ,x_invproc_currency_type              => 'PROJFUNC_CURRENCY'
                       ,x_revproc_currency_code              => l_cur_currency.currency_code
                       ,x_project_bil_rate_date_code         => l_rate_date_code
                       ,x_project_bil_rate_type              => l_rate_type
                       ,x_project_bil_rate_date              => null
                       ,x_project_bil_exchange_rate          => null
                       ,x_projfunc_currency_code             => l_cur_currency.currency_code
                       ,x_projfunc_bil_rate_date_code        => l_rate_date_code
                       ,x_projfunc_bil_rate_type             => l_rate_type
                       ,x_projfunc_bil_rate_date             => null
                       ,x_projfunc_bil_exchange_rate         => null
                       ,x_funding_rate_date_code             => l_rate_date_code
                       ,x_funding_rate_type                  => l_rate_type
                       ,x_funding_rate_date                  => null
                       ,x_funding_exchange_rate              => null
                       ,x_baseline_funding_flag              => l_baseline_funding_flag
                       ,x_projfunc_cost_rate_type            => l_rate_type2
                       ,x_projfunc_cost_rate_date            => null
                       ,x_multi_currency_billing_flag        => l_mcb_flag
                       ,x_inv_by_bill_trans_curr_flag        => 'N'
                       ,x_assign_precedes_task               => 'N'
                       ,x_split_cost_from_wokplan_flag       => 'Y'  --Default the workplan str is split from costing
                       ,x_split_cost_from_bill_flag          => 'N'
                       ,x_adv_action_set_id                  => l_adv_action_set_id
                       ,x_start_adv_action_set_flag          => 'Y'
                       ,x_priority_code                      => null
                       ,x_retn_billing_inv_format_id         => null
                       ,x_retn_accounting_flag               => l_retn_accounting_flag
                       -- anlee
                       -- patchset K changes
                       ,x_revaluate_funding_flag             => l_revaluate_funding_flag
                       ,x_include_gains_losses_flag        => l_include_gains_losses_flag
                       -- msundare
                       , x_security_level                   => p_security_level
                       , x_labor_disc_reason_code           => null
                       , x_non_labor_disc_reason_code        => null
                       -- End of changes
                       -- anlee
                       -- Project Long Name changes
                       , x_long_name                          => p_long_name
                        -- End of changes
                        --PA L changes 2872708
                       ,x_asset_allocation_method        => l_asset_allocation_method
                       ,x_capital_event_processing       => l_capital_event_processing
                       ,x_cint_rate_sch_id               => l_cint_rate_sch_id
                       ,x_cint_eligible_flag             => 'Y'
                       ,x_cint_stop_date                 => null
                       --End PA L changes 2872708
                       ,x_record_version_number              => 1
                       , X_BTC_COST_BASE_REV_CODE             => l_BTC_COST_BASE_REV_CODE  --bug 2755727
                       --FP_M Changes. Tracking Bug 3279981
                       , x_revtrans_currency_type => null           -- 4363092 for MOAC changes
                       ,x_en_top_task_customer_flag     => 'N'
                       ,x_en_top_task_inv_mth_flag      => 'N'
                       ,x_revenue_accrual_method        =>
                                       substr(l_distribution_rule, 1, instr(l_distribution_rule,'/')-1)
                       ,x_invoice_method                =>
                                       substr(l_distribution_rule, instr(l_distribution_rule,'/')+1)
                       ,x_projfunc_attr_for_ar_flag     => 'N'
                       ,x_sys_program_flag              => 'N'
                       ,x_allow_multi_program_rollup    => 'N'
                       ,x_proj_req_res_format_id        =>NULL
                       ,x_proj_asgmt_res_format_id      =>NULL
                       ,x_org_id                        => p_operating_unit_id -- 4363092 MOAC changes
		       ,x_date_eff_funds_flag		=>nvl(l_date_eff_funds_flag,'N') --sunkalya:federal changes Bug#5511353
                       ,x_ar_rec_notify_flag            => l_ar_rec_notify_flag    -- 7508661 : EnC
                       ,x_auto_release_pwp_inv          => l_auto_release_pwp_inv  -- 7508661 : EnC
                    );

    --Call Add options api to add options in pa_project_options with the created template.
    DECLARE
       CURSOR cur_template_options
       IS
         SELECT option_code
           FROM pa_options;
    BEGIN
         FOR cur_template_options_rec IN cur_template_options LOOP
-- anlee
-- Enable Advanced Structures
-- Don't want to add structure or workplan related options by default
--FP_M Changes. Tracking Bug 3279978
           IF cur_template_options_rec.option_code NOT IN ('STRUCTURES', 'STRUCTURES_SS','DELIVERABLES_SS') THEN
             PA_PROJ_TEMPLATE_SETUP_PUB.Add_Project_Options(
                        p_api_version         => p_api_version
                       ,p_init_msg_list       => p_init_msg_list
                       ,p_commit                => p_commit
                       ,p_validate_only       => p_validate_only
                       ,p_validation_level  => p_validation_level
                       ,p_calling_module          => p_calling_module
                       ,p_debug_mode          => p_debug_mode
                       ,p_max_msg_count       => p_max_msg_count
                       ,p_project_id            => l_template_id
                       ,p_option_code           => cur_template_options_rec.option_code
                       ,p_action                => 'INSERT'
                       ,x_return_status       => l_return_status
                       ,x_msg_count             => l_msg_count
                       ,x_msg_data              => l_msg_data
                     );
           END IF;
-- End of changes
         END LOOP;
    END;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    --Call Add quick entry api to add two default quick  entries( SEGMENT1 and NAME ) in
    --pa_project_copy_overrides with the created template.
    DECLARE
       CURSOR cur_copy_overrides
       IS
         SELECT lookup_code, meaning
           FROM pa_lookups
          WHERE lookup_type = 'OVERRIDE FIELD'
            AND lookup_code = 'SEGMENT1'
          UNION
         SELECT lookup_code, meaning
           FROM pa_lookups
          WHERE lookup_type = 'OVERRIDE FIELD'
            AND lookup_code = 'NAME'
          ORDER BY 1 DESC;

        l_rownum  NUMBER := 0;
    BEGIN
         FOR cur_copy_overrides_rec IN cur_copy_overrides LOOP
             l_rownum := l_rownum + 1;
             PA_PROJ_TEMPLATE_SETUP_PUB.Add_Quick_Entry_Field(
                       p_api_version          => p_api_version
                       ,p_init_msg_list       => p_init_msg_list
                       ,p_commit                => p_commit
                       ,p_validate_only       => p_validate_only
                       ,p_validation_level  => p_validation_level
                       ,p_calling_module          => p_calling_module
                       ,p_debug_mode          => p_debug_mode
                       ,p_max_msg_count       => p_max_msg_count
                       ,p_project_id            => l_template_id
                       ,p_sort_order          => l_rownum * 10
                       ,p_field_name          => cur_copy_overrides_rec.lookup_code
                       ,p_limiting_value          => null
                       ,p_prompt                => cur_copy_overrides_rec.meaning
                       ,p_required_flag       => 'Y'
                       ,x_return_status       => l_return_status
                       ,x_msg_count             => l_msg_count
                       ,x_msg_data              => l_msg_data
                     );

         END LOOP;
    END;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    --Insert default resource list
   Open Get_def_Res_List;
   Fetch Get_def_Res_List Into x_def_res_list_id, x_rl_asgmt_id;
   If Get_def_Res_list%NOTFOUND Then
      x_def_res_list_id := NULL;
   end if;
   Close Get_def_Res_List;
   IF x_def_res_list_id is not null Then
      INSERT INTO pa_resource_list_assignments (
        resource_list_assignment_id,
        resource_list_id,
        project_id,
        resource_list_changed_flag,
        resource_list_accumulated_flag,
        last_updated_by,
        last_update_date,
        creation_date,
        created_by,
        last_update_login )
      Values (
         x_rl_asgmt_id,
         x_def_res_list_id,
         l_template_id,
         'N',
         'N',
         nvl(x_user_id,-1),
         trunc(sysdate),
         trunc(sysdate),
         nvl(x_user_id,-1),
         nvl(x_login_id,-1));
      Insert into pa_resource_list_uses (
         resource_list_assignment_id,
         use_code,
         default_flag,
         last_updated_by,
         last_update_date,
         creation_date,
         created_by,
         last_update_login )
      values (
           x_rl_asgmt_id,
           x_def_use_code,
           x_def_flag,
           nvl(x_user_id,-1),
           trunc(sysdate),
           trunc(sysdate),
           nvl(x_user_id,-1),
           nvl(x_login_id ,-1));
     END IF;


    --Create a default task

    IF l_project_type_class_code = 'INDIRECT'
    THEN
       l_billable_flag := 'N';
    ELSE
       l_billable_flag := 'Y';
    END IF;

/* From FPM we will not be creating any default task or structure at the time of template creation
   Please refer Financial structures in HTML Technical Architecture on files online
--bug 3301192
    PA_TASKS_PKG.Insert_Row(
        X_Rowid                              => l_row_id,
        X_task_id                            => l_task_id,
        X_Project_id                         => l_template_id,
        X_Task_Number                        => '1',
          X_Creation_Date                      => sysdate,
          X_Created_By                         => FND_GLOBAL.USER_ID,
          X_Last_Update_Date                   => sysdate,
          X_last_Updated_By                    => FND_GLOBAL.USER_ID,
          X_Last_Update_login                  => FND_GLOBAL.LOGIN_ID,
          X_Task_Name                          => 'Task 1',
              X_Long_Task_Name                     => 'Task 1',
          X_Top_Task_Id                        => null,
          X_Wbs_level                          => 1,
          X_ready_to_Bill_flag                 => 'Y',
          X_Ready_To_Distribute_Flag           => 'Y',
          X_parent_task_id                     => null,
          X_Description                        => 'Task 1',
          X_carrying_out_organization_id       => p_organization_id,
          X_Service_Type_code                  => l_service_type_code,
          X_Task_Manager_Person_id             => null,
          X_chargeable_Flag                    => 'Y',
          X_Billable_flag                      => l_billable_flag,
          X_limit_to_Txn_controls_flag         => 'N',
        X_Start_Date                         => null,
        X_Completion_Date                    => null,
        X_Address_Id                         => null,  --w_address_id, -Since no customer is created so far
        X_Labor_Bill_Rate_org_id             => l_labor_bill_rate_org_id,    -- :project_folder.Labor_Bill_Rate_Org_Id,
        X_Labor_Std_Bill_Rate_Schdl          => l_labor_std_bill_rate_schdl, --:project_folder.Labor_Std_Bill_Rate_Schdl,
        X_Labor_Schedule_Fixed_Date          => null,
        X_Labor_Schedule_Discount            => null,
        X_Non_Labor_Bill_Rate_Org_Id         => l_non_labor_bill_rate_org_id, --:project_folder.Non_Labor_Bill_Rate_Org_Id,
        X_NL_Std_Bill_Rate_Schdl             => l_nl_std_bill_rate_schdl,     --:project_folder.Non_Labor_Std_Bill_Rate_Schdl,
        X_Nl_Schedule_Fixed_Date             => null,
        X_Non_Labor_Schedule_Discount        => null,
        X_Labor_Cost_Multiplier_Name         => null,
        X_Attribute_Category                 => null,
        X_Attribute1                         => null,
        X_Attribute2                         => null,
        X_Attribute3                         => null,
        X_Attribute4                         => null,
        X_Attribute5                         => null,
        X_Attribute6                         => null,
        X_Attribute7                         => null,
        X_Attribute8                         => null,
        X_Attribute9                         => null,
        X_Attribute10                        => null,
        X_Cost_Ind_Rate_Sch_Id               => l_Cost_Ind_Rate_Sch_Id,
        X_Rev_ind_rate_sch_id                => l_Rev_Ind_Rate_Sch_Id,
        X_Inv_Ind_rate_sch_id                => l_Inv_Ind_Rate_Sch_Id,
        X_Cost_ind_sch_fixed_date            => null,
        X_Rev_Ind_sch_fixed_date             => null,
        X_Inv_Ind_sch_fixed_date             => null,
        X_Labor_Sch_Type                     => l_Labor_Sch_Type,
        X_Non_Labor_Sch_Type                 => l_Non_Labor_Sch_Type,
            X_Allow_Cross_Charge_Flag            => 'N',
            X_Project_Rate_Date                  => null,
            X_Project_Rate_Type                  => l_rate_type2,
        X_cc_process_labor_flag              => 'N',
        X_Labor_tp_schedule_id               => null,
        X_Labor_tp_fixed_date                => null,
        X_cc_process_nl_flag                 => 'N',
        X_nl_tp_schedule_id              => null,
        X_nl_tp_fixed_date               => null,
        X_receive_project_invoice_flag   => 'N',
        X_work_type_id                   => l_work_type_id,
            X_TASKFUNC_COST_RATE_TYPE            => l_rate_type2,
            X_TASKFUNC_COST_RATE_DATE            => null,
            X_NON_LAB_STD_BILL_RT_SCH_ID         => l_non_lab_std_bill_rt_sch_id,
            X_job_bill_rate_schedule_id          => l_job_bill_rate_schedule_id,
            X_emp_bill_rate_schedule_id          => l_emp_bill_rate_schedule_id,
            X_labor_disc_reason_code             => null,
            X_non_labor_disc_reason_code         => null,
--PA L 2872708
            x_retirement_cost_flag           => 'N',
            x_cint_eligible_flag             => 'Y',
            x_cint_stop_date                 => null
--PA L 2872708
          );
*/ --bug 3301192

   --Opportunity Management changes.
   PA_OPPORTUNITY_MGT_PVT.CREATE_PROJECT_ATTRIBUTES(
             p_project_id    => l_template_id
            ,x_return_status => l_return_status
            ,x_msg_count     => l_msg_count
            ,x_msg_data      => l_msg_data );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

/* From FPM we will not be creating any default structure at the time of template creation
   Please refer Financial structures in HTML Technical Architecture on files online
--bug 3301192
    --Create a Structure Workplan and Financial structures separately

    PA_PROJ_TASK_STRUC_PUB.create_default_structure(
             p_dest_project_id            => l_template_id
            ,p_dest_project_name          => p_project_name
            ,p_dest_project_number        => p_project_number
            ,p_dest_description           => p_description
            ,p_struc_type                 => 'FINANCIAL'
            ,x_msg_count                  => l_msg_count
            ,x_msg_data                   => l_msg_data
            ,x_return_status              => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

  --Project Structures Changes
  --Creating tasks in pa_proj_elements from pa_tasks
    PA_PROJ_TASK_STRUC_PUB.CREATE_DEFAULT_TASK_STRUCTURE(
             p_project_id         => l_template_id
            ,p_struc_type         => 'FINANCIAL'
            ,x_msg_count          => l_msg_count
            ,x_msg_data           => l_msg_data
            ,x_return_status      => l_return_status  );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;
*/  --bug 3301192

-- anlee
-- Advanced Project Structures
-- Comment out creation of workplan structure
-- New templates will only have financial structure
/*
    --Create a Structure Workplan and Financial structures separately

    PA_PROJ_TASK_STRUC_PUB.create_default_structure(
             p_dest_project_id            => l_template_id
            ,p_dest_project_name          => p_project_name
            ,p_dest_project_number        => p_project_number
            ,p_dest_description           => p_description
            ,p_struc_type                 => 'WORKPLAN'
            ,x_msg_count                  => l_msg_count
            ,x_msg_data                   => l_msg_data
            ,x_return_status              => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;
*/
-- End of changes

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PVT.Create_Project_Template END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Create_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Create_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PVT',
                              p_procedure_name => 'Create_Project_Template',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Create_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PVT',
                              p_procedure_name => 'Create_Project_Template',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Create_Project_Template;

-- API name                      : Update_Project_Template
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
--p_project_number              IN VARCHAR2
--p_project_name                  IN VARCHAR2
--p_project_type                  IN VARCHAR2
--p_organization_id         IN NUMBER
--p_organization_name           IN VARCHAR2
--p_effective_from_date         IN DATE
--p_effective_to_date           IN DATE
--p_description               IN VARCHAR2

PROCEDURE Update_Project_Template(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id           IN    NUMBER,
 p_project_number       IN    VARCHAR2    := 'JUNK_CHARS',
 p_project_name       IN    VARCHAR2    := 'JUNK_CHARS',
 p_project_type       IN    VARCHAR2    := 'JUNK_CHARS',
 p_organization_id  IN    NUMBER      := -9999,
 p_effective_from_date  IN    DATE        := TO_DATE( '01-01-1000', 'DD-MM-YYYY' ),
 p_effective_to_date    IN    DATE        := TO_DATE( '01-01-1000', 'DD-MM-YYYY' ),
 p_description        IN    VARCHAR2    := 'JUNK_CHARS',
 p_security_level     IN    NUMBER      := 0,
-- anlee
-- Project Long Name changes
 p_long_name             IN VARCHAR2 DEFAULT NULL,
-- End of changes
 p_record_version_number IN   NUMBER,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Update_Project_Template';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);

   l_organization_id               NUMBER;

   l_Status_code                      VARCHAR2(80);
   l_service_type_code                VARCHAR2(80);
   l_cost_ind_rate_sch_id             NUMBER;
   l_labor_sch_type                   VARCHAR2(80);
   l_labor_bill_rate_org_id           NUMBER;
   l_labor_std_bill_rate_schdl        VARCHAR2(80);
   l_non_labor_sch_type               VARCHAR2(80);
   l_non_labor_bill_rate_org_id       NUMBER;
   l_nl_std_bill_rate_schdl           VARCHAR2(80);
   l_rev_ind_rate_sch_id              NUMBER;
   l_inv_ind_rate_sch_id              NUMBER;
   l_labor_invoice_format_id          NUMBER;
   l_non_labor_invoice_format_id      NUMBER;
   l_Burden_cost_flag                 VARCHAR2(80);
   l_interface_asset_cost_code        VARCHAR2(80);
   l_cost_sch_override_flag           VARCHAR2(80);
   l_billing_offset                   NUMBER;
   l_billing_cycle_id                 NUMBER;
   l_cc_prvdr_flag                    VARCHAR2(80);
   l_bill_job_group_id                NUMBER;
   l_cost_job_group_id                NUMBER;
   l_work_type_id                     NUMBER;
   l_role_list_id                     NUMBER;
   l_unassigned_time                  VARCHAR2(1);
   l_emp_bill_rate_schedule_id        NUMBER;
   l_job_bill_rate_schedule_id        NUMBER;
   l_budgetary_override_flag          VARCHAR2(80);
   l_baseline_funding_flag            VARCHAR2(80);
   l_non_lab_std_bill_rt_sch_id       NUMBER;
   l_project_type_class_code          VARCHAR2(80);
   l_effective_from_date              DATE;
   l_effective_to_date                DATE;

   l_old_project_type                 VARCHAR2(80);

-- anlee
-- patchset K changes
   l_revaluate_funding_flag           VARCHAR2(1);
   l_include_gains_losses_flag      VARCHAR2(1);
-- End of changes

   l_err_code                         NUMBER;
   l_err_stage                        VARCHAR2(2000);
   l_err_stack                        VARCHAR2(2000);

   x_err_code                         NUMBER;
   x_err_stage                        VARCHAR2(2000);
   x_err_stack                        VARCHAR2(2000);


   CURSOR cur_project
   IS
     SELECT rowid, project_type, carrying_out_organization_id, public_sector_flag, segment1, location_id,
            Rev_ind_sch_fixed_date, Inv_ind_sch_fixed_date, distribution_rule,
            --bug 3068781
            multi_currency_billing_flag,projfunc_currency_code,
            PROJFUNC_BIL_RATE_TYPE, PROJECT_BIL_RATE_TYPE, FUNDING_RATE_TYPE,
            PROJFUNC_BIL_RATE_DATE_CODE, PROJECT_BIL_RATE_DATE_CODE, FUNDING_RATE_DATE_CODE,
            BTC_COST_BASE_REV_CODE
            --bug 3068781
           --bug 4308335
           ,cc_process_labor_flag
           ,cc_process_nl_flag
           ,labor_tp_schedule_id
           ,nl_tp_schedule_id
           ,labor_tp_fixed_date
           ,nl_tp_fixed_date
           --bug 4308335
	   ,nvl(date_eff_funds_consumption,'N')     --federal bug#5511353
	   ,enable_top_task_customer_flag  --federal bug#5511353
           ,ar_rec_notify_flag    -- 7508661 : EnC
           ,auto_release_pwp_inv  -- 7508661 : EnC
       FROM pa_projects_all
      WHERE project_id = p_project_id;

   CURSOR cur_pa_tasks IS
   SELECT Rev_ind_sch_fixed_date, Inv_ind_sch_fixed_date
     FROM pa_tasks
    WHERE project_id = p_project_id;

   CURSOR cur_project_type_class
   IS
     SELECT project_type_class_code
       FROM pa_project_types_all
      WHERE project_type = p_project_type;

  CURSOR cur_bill_flag( c_work_type_id NUMBER )
  IS
    SELECT billable_capitalizable_flag
      FROM pa_work_types_vl
     WHERE work_type_id = c_work_type_id;

  CURSOR cur_dist_rule
  IS
/*    SELECT r.distribution_rule
      FROM pa_project_type_distributions d, pa_distribution_rules r
     WHERE d.distribution_rule = r.distribution_rule
       AND project_type = p_project_type
       AND default_flag = 'Y';
*/
--copied from project_folder1.project_type_mir1 when-validate-item validation trigger.

       select distribution_rule
         from pa_project_type_distributions
        where project_type = p_project_type
          and default_flag = 'Y';


  l_Inv_ind_sch_fixed_date1  DATE;
  l_Rev_ind_sch_fixed_date1  DATE;

  l_Inv_ind_sch_fixed_date2  DATE;
  l_Rev_ind_sch_fixed_date2  DATE;

  l_distribution_rule   VARCHAR2(20);
  l_old_distribution_rule VARCHAR2(20);

l_row_id VARCHAR2(18);
l_proj_number VARCHAR2(80);

l_cc_process_labor_flag      VARCHAR2(1);
l_cc_process_nl_flag         VARCHAR2(1);
l_labor_tp_schedule_id       NUMBER;
l_nl_tp_schedule_id          NUMBER;
l_labor_tp_fixed_date        DATE;
l_nl_tp_fixed_date           DATE;

l_location_id           NUMBER;
x_rowid                 VARCHAR2(18);
l_city_name             VARCHAR2(250);
l_country_code          VARCHAR2(250);
l_country_name          VARCHAR2(250);

/* Type of l_region_name has been changed to %TYPE from varchar2 for the UTF8 change */
l_region_name           hr_locations_all.region_1%TYPE;
l_error_message_code            VARCHAR2(250);
l_old_organization_id               NUMBER;
l_billable_flag                 VARCHAR2(1);
l_public_sector_flag            VARCHAR2(1);

--PA L 2872708
   l_asset_allocation_method      VARCHAR2(30);
   l_CAPITAL_EVENT_PROCESSING     VARCHAR2(30);
   l_CINT_RATE_SCH_ID             NUMBER;
--PA L 2872708

--federal.Bug#5511353
l_date_eff_funds_consumption      VARCHAR2(1);
--federal.Bug#5511353

l_ar_rec_notify_flag              VARCHAR2(1);   -- 7508661 : EnC
l_auto_release_pwp_inv            VARCHAR2(1);   -- 7508661 : EnC

--bug 3068781 maansari
l_multi_currency_billing_flag      VARCHAR2(1);    --derived value
l_multi_currency_billing_flag2      VARCHAR2(1);   --old value from database
l_PROJFUNC_BIL_RATE_DATE_CODE      VARCHAR2(30);
l_PROJECT_BIL_RATE_DATE_CODE       VARCHAR2(30);
l_FUNDING_RATE_DATE_CODE           VARCHAR2(30);
l_PROJFUNC_BIL_RATE_TYPE           VARCHAR2(30);
l_PROJECT_BIL_RATE_TYPE            VARCHAR2(30);
l_FUNDING_RATE_TYPE                VARCHAR2(30);
l_BTC_COST_BASE_REV_CODE           VARCHAR2(90);
l_projfunc_currency_code           VARCHAR2(15);
--end bug 3068781
l_warnings_only_flag VARCHAR2(1) := 'N'; --bug3134205

--sunkalya federal

	    L_old_TOP_TASK_FLAG     VARCHAR2(1) := 'N';
	    l_old_funds_flag        VARCHAR2(1) := 'N';
--sunkalya federal

BEGIN
    pa_debug.init_err_stack ('PA_PROJ_TEMPLATE_SETUP_PVT.Update_Project_Template');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PVT.Update_Project_Template begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Update_Project_Template;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --check project type change
    OPEN cur_project;
    FETCH cur_project INTO l_row_id, l_old_project_type, l_old_organization_id, l_public_sector_flag, l_proj_number, l_location_id , l_Rev_ind_sch_fixed_date1, l_Inv_ind_sch_fixed_date1, l_old_distribution_rule,
           --bug 3068781
            l_multi_currency_billing_flag2,l_projfunc_currency_code,
            l_PROJFUNC_BIL_RATE_TYPE, l_PROJECT_BIL_RATE_TYPE, l_FUNDING_RATE_TYPE,
            l_PROJFUNC_BIL_RATE_DATE_CODE, l_PROJECT_BIL_RATE_DATE_CODE, l_FUNDING_RATE_DATE_CODE,
            l_BTC_COST_BASE_REV_CODE
           --bug 3068781
  --bug4308335
           ,l_cc_process_labor_flag
           ,l_cc_process_nl_flag
           ,l_labor_tp_schedule_id
           ,l_nl_tp_schedule_id
           ,l_labor_tp_fixed_date
           ,l_nl_tp_fixed_date
  --end bug4308335
	   ,l_old_funds_flag    --federal bug#5511353
	   ,L_old_TOP_TASK_FLAG --federal bug#5511353
           ,l_ar_rec_notify_flag    -- 7508661 : EnC
           ,l_auto_release_pwp_inv  -- 7508661 : EnC
        ;

    CLOSE cur_project;

    OPEN cur_pa_tasks;
    FETCH cur_pa_tasks INTO l_Rev_ind_sch_fixed_date2, l_Inv_ind_sch_fixed_date2;
    CLOSE cur_pa_tasks;

    --Check for not null
    PA_PROJ_TEMPLATE_SETUP_UTILS.Check_Template_attr_req(
                   p_project_number        => p_project_number
                  ,p_project_name          => p_project_name
                  ,p_project_type          => p_project_type
                  ,p_organization_id       => p_organization_id
                  ,x_return_status         => l_return_status
                  ,x_error_msg_code        => l_error_msg_code
               );

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => l_error_msg_code);
       x_msg_data := l_error_msg_code;
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    --Check proj number change
    IF l_proj_number <> p_project_number
    THEN
        pa_project_utils.change_proj_num_ok (
                                           p_project_id,
                                           l_err_code,
                                           l_err_stage,
                                           l_err_stack);
        if l_err_code <> 0 Then
           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => l_err_stage );
           x_msg_data := x_err_stage;
           x_return_status := 'E';
           RAISE  FND_API.G_EXC_ERROR;
        end If;
    END IF;

    --check for project number uniqueness
    IF pa_project_utils.check_unique_project_number (x_project_number  => p_project_number
                                                     ,x_rowid           => l_row_id ) = 0
    THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_SETUP_TMPL_NUM_NOT_UNIQUE' );
       x_msg_data := 'PA_SETUP_TMPL_NUM_NOT_UNIQUE';
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    --check for project name uniqueness
    IF pa_project_utils.check_unique_project_name (x_project_name  => p_project_name
                                                   ,x_rowid           => l_row_id ) = 0
    THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_SETUP_TMPL_NAME_NOT_UNIQUE' );
       x_msg_data := 'PA_SETUP_TMPL_NAME_NOT_UNIQUE';
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    -- anlee
    -- Project Long Name changes
    IF pa_project_utils.check_unique_long_name (p_long_name, l_row_id ) = 0
    THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_PR_EPR_LONG_NAME_NOT_UNIQUE' );
       x_msg_data := 'PA_PR_EPR_LONG_NAME_NOT_UNIQUE';
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    -- End of changes

    IF p_effective_from_date = TO_DATE( '01-01-1000', 'DD-MM-YYYY' )
    THEN
       l_effective_from_date := null;
    ELSE
       l_effective_from_date := p_effective_from_date;
    END IF;

    IF p_effective_to_date = TO_DATE( '01-01-1000', 'DD-MM-YYYY' )
    THEN
       l_effective_to_date := null;
    ELSE
       l_effective_to_date := p_effective_to_date;
    END IF;

    IF  l_effective_from_date IS NOT NULL AND
        l_effective_to_date IS NOT NULL
    THEN
        --Check the start and end dates
        IF l_effective_from_date > l_effective_to_date
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_SETUP_CHK_ST_EN_DATE');
            x_msg_data := 'PA_SETUP_CHK_ST_EN_DATE';
            x_return_status := 'E';
            RAISE  FND_API.G_EXC_ERROR;
        END IF;
    ELSIF l_effective_from_date IS NULL AND
          l_effective_to_date IS NOT NULL
    THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_SETUP_ST_DT_WO_EN_DT');
       x_msg_data := 'PA_SETUP_ST_DT_WO_EN_DT';
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    PA_PROJ_TEMPLATE_SETUP_UTILS.Get_Project_Type_Defaults(
                 p_project_type                     => p_project_type
                ,x_Status_code                      => l_Status_code
                ,x_service_type_code                => l_service_type_code
                ,x_cost_ind_rate_sch_id             => l_cost_ind_rate_sch_id
                ,x_labor_sch_type                   => l_labor_sch_type
                ,x_labor_bill_rate_org_id           => l_labor_bill_rate_org_id
                ,x_labor_std_bill_rate_schdl        => l_labor_std_bill_rate_schdl
                ,x_non_labor_sch_type               => l_non_labor_sch_type
                ,x_non_labor_bill_rate_org_id       => l_non_labor_bill_rate_org_id
                ,x_nl_std_bill_rate_schdl           => l_nl_std_bill_rate_schdl
                ,x_rev_ind_rate_sch_id              => l_rev_ind_rate_sch_id
                ,x_inv_ind_rate_sch_id              => l_inv_ind_rate_sch_id
                ,x_labor_invoice_format_id          => l_labor_invoice_format_id
                ,x_non_labor_invoice_format_id      => l_non_labor_invoice_format_id
                ,x_Burden_cost_flag                 => l_Burden_cost_flag
                ,x_interface_asset_cost_code        => l_interface_asset_cost_code
                ,x_cost_sch_override_flag           => l_cost_sch_override_flag
                ,x_billing_offset                   => l_billing_offset
                ,x_billing_cycle_id                 => l_billing_cycle_id
                ,x_cc_prvdr_flag                    => l_cc_prvdr_flag
                ,x_bill_job_group_id                => l_bill_job_group_id
                ,x_cost_job_group_id                => l_cost_job_group_id
                ,x_work_type_id                     => l_work_type_id
                ,x_role_list_id                     => l_role_list_id
                ,x_unassigned_time                  => l_unassigned_time
                ,x_emp_bill_rate_schedule_id        => l_emp_bill_rate_schedule_id
                ,x_job_bill_rate_schedule_id        => l_job_bill_rate_schedule_id
                ,x_budgetary_override_flag          => l_budgetary_override_flag
                ,x_baseline_funding_flag            => l_baseline_funding_flag
                ,x_non_lab_std_bill_rt_sch_id       => l_non_lab_std_bill_rt_sch_id
                ,x_project_type_class_code          => l_project_type_class_code
-- anlee
-- Changes for patchset K
                ,x_revaluate_funding_flag           => l_revaluate_funding_flag
                ,x_include_gains_losses_flag      => l_include_gains_losses_flag
-- End of changes
--PA L Changes 2872708
                ,x_asset_allocation_method         => l_asset_allocation_method
                ,x_CAPITAL_EVENT_PROCESSING        => l_CAPITAL_EVENT_PROCESSING
                ,x_CINT_RATE_SCH_ID                => l_CINT_RATE_SCH_ID
--PA L Changes 2872708
--sunkalya.federal.Bug# Bug#5511353
		,x_date_eff_funds_flag		    => l_date_eff_funds_consumption
                ,x_ar_rec_notify_flag               => l_ar_rec_notify_flag    -- 7508661 : EnC
                ,x_auto_release_pwp_inv             => l_auto_release_pwp_inv  -- 7508661 : EnC
                ,x_return_status                    => l_return_status
                ,x_error_msg_code                   => l_error_msg_code
    );

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => l_error_msg_code);
       x_msg_data := l_error_msg_code;
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    --Validation from Projects form
    IF l_unassigned_time = 'N'
    THEN
        l_cc_process_labor_flag := 'N';
        l_cc_process_nl_flag    := 'N';
        l_labor_tp_schedule_id := null;
        l_nl_tp_schedule_id   := null;
        l_labor_tp_fixed_date := null;
        l_nl_tp_fixed_date    := null;
    END IF;

    IF l_project_type_class_code = 'CONTRACT'
    THEN
        OPEN cur_dist_rule;
        FETCH cur_dist_rule INTO l_distribution_rule;
        CLOSE cur_dist_rule;
       /* Pa_project_utils.check_dist_rule_chg_ok( p_project_id,
                                                 l_old_distribution_rule,
                                                 l_distribution_rule,
                                                 x_err_code,
                                                 x_err_stage,
                                                 x_err_stack );
        IF If x_err_code != 0 Then
        THEN
           l_distribution_rule := l_old_distribution_rule;
        END IF;
        */ -- no need here it should done when the user changes distribution rule on UI.
    END IF;

    IF l_old_project_type <> p_project_type AND p_project_type IS NOT NULL
    THEN
        /*OPEN cur_project_type_class;
        FETCH cur_project_type_class INTO l_project_type_class_code;
        CLOSE cur_project_type_class;*/

        DELETE FROM PA_BUDGETARY_CONTROL_OPTIONS
            WHERE PROJECT_ID = P_PROJECT_ID;

        IF l_project_type_class_code IS NOT NULL AND l_project_type_class_code <> 'CONTRACT'
        THEN
            IF pa_project_utils.check_proj_funding ( p_project_id ) <> 0
            THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_PR_CANT_CHG_DIR_TO_INDIR' );
                x_msg_data := 'PA_PR_CANT_CHG_DIR_TO_INDIR';
                x_return_status := 'E';
                RAISE  FND_API.G_EXC_ERROR;
            END IF;
            l_labor_sch_type := null;
            l_non_labor_sch_type := null;
        END IF;

        IF l_non_labor_sch_type = 'B' AND l_labor_sch_type = 'B'
        THEN
            l_rev_ind_rate_sch_id := null;
            l_inv_ind_rate_sch_id := null;
            l_Rev_ind_sch_fixed_date1 := null;
            l_Rev_ind_sch_fixed_date2 := null;
            l_Inv_ind_sch_fixed_date1 := null;
            l_Inv_ind_sch_fixed_date2 := null;
        END IF;

        IF l_non_labor_sch_type = 'I'
        THEN
           l_nl_std_bill_rate_schdl := null;
           l_non_labor_bill_rate_org_id := null;
        END IF;

       IF l_labor_sch_type = 'I'
       THEN
           l_emp_bill_rate_Schedule_id := null;
           l_job_bill_rate_Schedule_id := null;
       END IF;

/*        pa_project_utils.change_pt_org_ok( x_project_id => p_project_id,
                                           x_err_code   => l_err_code,
                                           x_err_stage  => l_err_stage,
                                           x_err_stack  => l_err_stack );
        IF l_err_code <> 0
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_PR_CANT_CHG_PROJ_TYPE' );
            x_msg_data := 'PA_PR_CANT_CHG_DIR_TO_INDIR';
            x_return_status := 'E';
            RAISE  FND_API.G_EXC_ERROR;
        END IF;
*/ --this code is commented in forms PAXPREPR.fmb
    END IF;

  --Location validation should be done if organization is changed.
/* The following validation is not performed in forms during a project/template update
   So we dont need to do this here
  IF p_organization_id <> l_old_organization_id
  THEN
      --Organization Location Validations
      pa_location_utils.Get_ORG_Location_Details
       (p_organization_id   => p_organization_id,
        x_country_name      => l_country_name,
        x_city              => l_city_name,
        x_region              => l_region_name,
        x_country_code      => l_country_code,
        x_return_status     => l_return_status,
        x_error_message_code    => l_error_message_code);

      IF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => l_error_message_code);
          x_msg_data := l_error_msg_code;
          x_return_status := 'E';
          RAISE  FND_API.G_EXC_ERROR;
      END IF;

      pa_location_utils.check_location_exists(
                  p_country_code  => l_country_code,
                  p_city          => l_city_name,
                  p_region        => l_region_name,
                  x_return_status => l_return_status,
                  x_location_id   => l_location_id);

      If l_location_id is null then

         If l_city_name is not null
            and l_region_name is not null
            If l_country_code is not null then

             pa_locations_pkg.INSERT_ROW(
                p_CITY              => l_city_name,
                p_REGION        => l_region_name,
                p_COUNTRY_CODE          => l_country_code,
                p_CREATION_DATE         => SYSDATE,
                p_CREATED_BY        => FND_GLOBAL.USER_ID,
                p_LAST_UPDATE_DATE  => SYSDATE,
                p_LAST_UPDATED_BY   => FND_GLOBAL.USER_ID,
                p_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID,
                X_ROWID             => x_rowid,
                X_LOCATION_ID           => l_location_id);

         end if;
    end if;
  END IF;
 */


--Validdate attribute change from WHEN-VALIDATE-RECORD projects form
--The following validation is done in forms when a template is created.

  IF ( p_organization_id <> l_old_organization_id OR l_old_project_type <> p_project_type )
  THEN
        pa_project_utils2.validate_attribute_change
           ('ORGANIZATION_VALIDATION'           -- X_context
           , 'INSERT'                                           -- X_insert_update_mode
           , 'SELF_SERVICE'                              -- X_calling_module
           , p_project_id                                                  -- X_project_id
           , NULL                                               -- X_task_id
           , l_old_organization_id                         -- X_old_value
           , p_organization_id                              -- X_new_value
           , p_project_type                                  -- X_project_type
           , null                                                  -- x_start_date
           , null
           , l_public_sector_flag                           -- X_public_sector_flag
           , NULL                                               -- X_task_manager_person_id
           , NULL                                               -- X_service_type
           , NULL                                               -- X_task_start_date
           , NULL                                               -- X_task_end_date
           , FND_GLOBAL.USER_ID                   -- X_entered_by_user_id
           , null                                                  -- X_attribute_category
           , null                                                  -- X_attribute1
           , null                                                  -- X_attribute2
           , null                                                  -- X_attribute3
           , null                                                  -- X_attribute4
           , null                                                  -- X_attribute5
           , null                                                 -- X_attribute6
           , null                                                 -- X_attribute7
           , null                                                 -- X_attribute8
           , null                                                 -- X_attribute9
           , null                                                 -- X_attribute10
           , null                                                 -- X_pm_project_code
           , null                                                 -- X_pm_project_reference
           , NULL                                              -- X_pm_task_reference
           , 'Y'                                                  -- X_functional_security_flag
           , l_warnings_only_flag --bug3134205
           , x_err_code                                     -- X_err_code
           , x_err_stage                                    -- X_err_stage
           , x_err_stack);                                  -- X_err_stack

     /* Commented the <> 15 condition for bug 2981386 */
     if x_err_code <> 0 /* and x_err_code <> 15 */ Then  --modified for bug 2393975

    if l_err_stage = 'PA_INVALID_PT_CLASS_ORG' then

        select  meaning
        into    l_project_type_class_code
        from    pa_project_types pt
          , pa_lookups lps
       where  pt.project_type    = p_project_type
         and  lps.lookup_type(+) = 'PROJECT TYPE CLASS'
         and  lps.lookup_code(+) = pt.project_type_class_code;

/* Code addition for bug 2981386 starts */
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                p_msg_name       => 'PA_INVALID_PT_CLASS_ORG',
                p_token1         => 'PT_CLASS',
                p_value1         => l_project_type_class_code);
     else
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
              p_msg_name       => x_err_stage);

     end if;
/* Code addition for bug 2981386 ends */

/* Commented for bug 2981386
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => x_err_stage,
                             p_token1         => 'PT_CLASS',
                             p_value1         => l_project_type_class_code );
*/
        x_msg_data := x_err_stage;
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
     End If;
  END IF;  --validate attribute change

--maansari bug 3068806
          IF p_project_type IS NOT NULL AND
            p_project_type <> l_old_project_type AND
            l_cc_prvdr_flag = 'Y' AND
            l_multi_currency_billing_flag2 = 'Y'
          THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_PR_CANT_CHG_IC_BIL_PT');
                x_msg_data := 'PA_PR_CANT_CHG_IC_BIL_PT';
                x_return_status := 'E';
                RAISE  FND_API.G_EXC_ERROR;
          END IF;
--end maansari bug 3068806

            --bug 3068781

            DECLARE
                 CURSOR cur_job_cur IS SELECT rate_sch_currency_code FROM pa_std_bill_rate_schedules_all
                               WHERE bill_rate_sch_id = l_job_bill_rate_schedule_id ;

                 CURSOR cur_emp_cur IS SELECT rate_sch_currency_code FROM pa_std_bill_rate_schedules_all
                               WHERE bill_rate_sch_id = l_emp_bill_rate_schedule_id ;

                 CURSOR cur_nl_cur IS SELECT rate_sch_currency_code FROM pa_std_bill_rate_schedules_all
                               WHERE bill_rate_sch_id = l_non_lab_std_bill_rt_sch_id ;

                 CURSOR cur_impl IS SELECT default_rate_type FROM pa_implementations;

                 x_job_rate_sch_currency  VARCHAR2(30);
                 x_emp_rate_sch_currency  VARCHAR2(30);
                 x_nl_rate_sch_currency   VARCHAR2(30);
                 x_default_rate_type      VARCHAR2(30);

            BEGIN

                IF l_cc_prvdr_flag = 'N'  --This is not required if the project type is IC billing.  bug 2179904
                THEN
                    OPEN cur_job_cur;
                    FETCH cur_job_cur INTO x_job_rate_sch_currency ;
                    CLOSE cur_job_cur;

                    OPEN cur_emp_cur;
                    FETCH cur_emp_cur INTO x_emp_rate_sch_currency ;
                    CLOSE cur_emp_cur;

                    OPEN cur_nl_cur;
                    FETCH cur_nl_cur INTO x_nl_rate_sch_currency ;
                    CLOSE cur_nl_cur;

                IF x_job_rate_sch_currency is not Null and
                       x_job_rate_sch_currency <> l_projfunc_currency_code
                    THEN
                       l_multi_currency_billing_flag := 'Y';
                    ELSIF x_emp_rate_sch_currency is not Null and
                       x_emp_rate_sch_currency <> l_projfunc_currency_code
                    THEN
                       l_multi_currency_billing_flag := 'Y';
                    ELSIF x_nl_rate_sch_currency is not Null and
                       x_nl_rate_sch_currency <> l_projfunc_currency_code
                    THEN
                       l_multi_currency_billing_flag := 'Y';
                    END IF;

                END IF;

                IF l_cc_prvdr_flag = 'N' AND
                   l_multi_currency_billing_flag2 = 'N' AND
                   NVL( l_multi_currency_billing_flag, 'N') = 'Y'
                THEN
                       OPEN cur_impl;
                       FETCH cur_impl INTO x_default_rate_type ;
                       CLOSE cur_impl;

                       l_PROJFUNC_BIL_RATE_TYPE      := x_default_rate_type;
                       l_PROJECT_BIL_RATE_TYPE       := x_default_rate_type;
                       l_FUNDING_RATE_TYPE           := x_default_rate_type;

                       l_PROJFUNC_BIL_RATE_DATE_CODE := 'PA_INVOICE_DATE';
                       l_PROJECT_BIL_RATE_DATE_CODE  := 'PA_INVOICE_DATE';
                       l_FUNDING_RATE_DATE_CODE      := 'PA_INVOICE_DATE';
                       l_BTC_COST_BASE_REV_CODE      := 'EXP_TRANS_CURR';

                       UPDATE pa_project_customers
                          SET inv_rate_type = x_default_rate_type
                        WHERE project_id = p_project_id;
                ELSE
                       l_PROJFUNC_BIL_RATE_TYPE      := l_PROJFUNC_BIL_RATE_TYPE;
                       l_PROJECT_BIL_RATE_TYPE       := l_PROJECT_BIL_RATE_TYPE;
                       l_FUNDING_RATE_TYPE           := l_FUNDING_RATE_TYPE;

                       l_PROJFUNC_BIL_RATE_DATE_CODE := l_PROJFUNC_BIL_RATE_DATE_CODE;
                       l_PROJECT_BIL_RATE_DATE_CODE  := l_PROJECT_BIL_RATE_DATE_CODE;
                       l_FUNDING_RATE_DATE_CODE      := l_FUNDING_RATE_DATE_CODE;
                       l_BTC_COST_BASE_REV_CODE      := l_BTC_COST_BASE_REV_CODE;

                END IF;
            END;
            --end bug 3068781



    --I cant use table handler for update; It may update the unwanted columns as well wih null
    UPDATE pa_projects_all
       SET SEGMENT1                       = p_project_number,
           NAME                           = p_project_name,
           description                    = p_description,
           PROJECT_TYPE                   = p_project_type,
           carrying_out_organization_id   = p_organization_id,
           TEMPLATE_START_DATE_ACTIVE     = l_effective_from_date,
           TEMPLATE_END_DATE_ACTIVE       = l_effective_to_date,
-- not done in project forms          PROJECT_STATUS_CODE            = l_Status_code,
           LABOR_INVOICE_FORMAT_ID        = l_labor_invoice_format_id,
           NON_LABOR_INVOICE_FORMAT_ID    = l_non_labor_invoice_format_id,
           BILLING_OFFSET                 = l_billing_offset,
           NON_LABOR_STD_BILL_RATE_SCHDL  = l_nl_std_bill_rate_schdl,
           NON_LABOR_BILL_RATE_ORG_ID     = l_non_labor_bill_rate_org_id,
           Non_Labor_Schedule_Fixed_Date  = DECODE( l_non_labor_sch_type, 'I', null, Non_Labor_Schedule_Fixed_Date ),
           Non_Labor_Schedule_Discount    = DECODE( l_non_labor_sch_type, 'I', null, Non_Labor_Schedule_Discount ),
           COST_IND_RATE_SCH_ID           = l_cost_ind_rate_sch_id,
           REV_IND_RATE_SCH_ID            = l_rev_ind_rate_sch_id,
           REV_IND_SCH_FIXED_DATE         = l_REV_IND_SCH_fixed_date1,
           INV_IND_RATE_SCH_ID            = l_inv_ind_rate_sch_id,
           INV_IND_SCH_FIXED_DATE         = l_INV_IND_SCH_FIXED_date1,
           LABOR_SCH_TYPE                 = l_labor_sch_type,
           NON_LABOR_SCH_TYPE             = l_non_labor_sch_type,
           BILLING_CYCLE_ID               = l_billing_cycle_id,
           BILL_JOB_GROUP_ID              = l_bill_job_group_id,
           COST_JOB_GROUP_ID              = l_cost_job_group_id,
           ROLE_LIST_ID                   = l_role_list_id,
           WORK_TYPE_ID                   = l_work_type_id,
           JOB_BILL_RATE_SCHEDULE_ID      = l_job_bill_rate_schedule_id,
           EMP_BILL_RATE_SCHEDULE_ID      = l_emp_bill_rate_schedule_id,
           labor_schedule_fixed_date      = DECODE( l_labor_sch_type, 'I', null, labor_schedule_fixed_date ),
           labor_schedule_discount        = DECODE( l_labor_sch_type, 'I', null, labor_schedule_discount ),
           non_lab_std_bill_rt_sch_id     = l_non_lab_std_bill_rt_sch_id,

           labor_std_bill_rate_schdl      = l_labor_std_bill_rate_schdl,
           labor_bill_rate_org_id         = l_labor_bill_rate_org_id,
           cc_process_labor_flag          = l_cc_process_labor_flag,
           cc_process_nl_flag             = l_cc_process_nl_flag,
           labor_tp_schedule_id           = l_labor_tp_schedule_id ,
           nl_tp_schedule_id              = l_nl_tp_schedule_id   ,
           labor_tp_fixed_date            = l_labor_tp_fixed_date ,
           nl_tp_fixed_date               = l_nl_tp_fixed_date    ,
           location_id                    = l_location_id,
           distribution_rule              = l_distribution_rule,
-- anlee
-- patchset K changes
           revaluate_funding_flag         = l_revaluate_funding_flag,
           include_gains_losses_flag    = l_include_gains_losses_flag,
-- End of changes
--PA K Project Access Changes
           security_level                 = p_security_level,
-- anlee
-- Project Long Name changes
           long_name                      = p_long_name,
-- End of changes
--bug 3068781
           multi_currency_billing_flag   = NVL( l_multi_currency_billing_flag,l_multi_currency_billing_flag2 ),
            PROJFUNC_BIL_RATE_TYPE       = l_PROJFUNC_BIL_RATE_TYPE,
            PROJECT_BIL_RATE_TYPE        = l_PROJECT_BIL_RATE_TYPE,
            FUNDING_RATE_TYPE            = l_FUNDING_RATE_TYPE,
            PROJFUNC_BIL_RATE_DATE_CODE  = l_PROJFUNC_BIL_RATE_DATE_CODE,
            PROJECT_BIL_RATE_DATE_CODE   = l_PROJECT_BIL_RATE_DATE_CODE,
            FUNDING_RATE_DATE_CODE       = l_FUNDING_RATE_DATE_CODE,
              BTC_COST_BASE_REV_CODE     = l_BTC_COST_BASE_REV_CODE,
--bug 3068781
--
--PA L 2872708
           asset_allocation_method       = l_asset_allocation_method,
           CAPITAL_EVENT_PROCESSING      = l_CAPITAL_EVENT_PROCESSING,
           CINT_RATE_SCH_ID              = l_CINT_RATE_SCH_ID,
--PA L 2872708
           record_version_number          = NVL( record_version_number, 1 ) + 1,
--sunkalya.federal changes. Bug#5511353
	   date_eff_funds_consumption    = nvl(l_date_eff_funds_consumption,'N')
--sunkalya.federal changes. Bug#5511353

     WHERE project_id = p_project_id;

--Sunkalya federal changes. Bug#5511353

IF ( l_old_project_type <> p_project_type ) THEN

    DECLARE

	    hghst_ctr_cust_id   NUMBER;
	    l_return_status	VARCHAR2(10);
            l_msg_count		NUMBER := 0;
            l_msg_data		VARCHAR2(2000);

	    BEGIN

		IF    l_date_eff_funds_consumption ='Y' THEN

			UPDATE pa_project_customers
			SET
			CUSTOMER_BILL_SPLIT = NULL
			WHERE
			PROJECT_ID = p_project_id;


		ELSIF l_old_funds_flag = 'Y' AND l_old_top_task_flag = 'N' THEN


			--This api will determine which customer to be made as 100% contributor.
			PA_CUSTOMERS_CONTACTS_UTILS.Get_Highest_Contr_Fed_Cust(
						   P_API_VERSION            => 1.0
						 , P_INIT_MSG_LIST          => 'T'
						 , P_COMMIT                 => 'F'
						 , P_VALIDATE_ONLY          => 'F'
						 , P_VALIDATION_LEVEL       => 100
						 , P_DEBUG_MODE             => 'N'
						 , p_calling_module         => 'AMG'
						 , p_project_id             => p_project_id
						 , x_highst_contr_cust_id   => hghst_ctr_cust_id
						 , x_return_status          => l_return_status
						 , x_msg_count              => l_msg_count
						 , x_msg_data               => l_msg_data );

			IF hghst_ctr_cust_id IS NOT NULL AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN

					UPDATE pa_project_customers SET customer_bill_split = 100
					WHERE customer_id = hghst_ctr_cust_id AND project_id = p_project_id;

					UPDATE pa_project_customers SET customer_bill_split = 0
					WHERE customer_id <> hghst_ctr_cust_id AND project_id = p_project_id;
			END IF;
		END IF;


    END;

END IF;

    --Federal changes by sunkalya.Bug#5511353.

    IF ( l_old_project_type <> p_project_type )
    THEN

       OPEN cur_bill_flag( l_work_type_id );
       FETCH cur_bill_flag INTO l_billable_flag;
       CLOSE cur_bill_flag;

       UPDATE pa_tasks
          SET work_type_id                    = l_work_type_id,
              billable_flag                   = l_billable_flag,
              emp_bill_rate_schedule_id       = l_emp_bill_rate_schedule_id,
              job_bill_rate_schedule_id       = l_job_bill_rate_schedule_id,
              labor_schedule_fixed_date      = DECODE( l_labor_sch_type, 'I', null, labor_schedule_fixed_date ),
              labor_schedule_discount        = DECODE( l_labor_sch_type, 'I', null, labor_schedule_discount ),

           --bug 2101726
              labor_sch_type                  = l_labor_sch_type,
              service_type_code               = l_service_type_code,
              cost_ind_rate_sch_id            = l_cost_ind_rate_sch_id,
              non_labor_sch_type              = l_non_labor_sch_type,
              non_labor_bill_rate_org_id      = l_non_labor_bill_rate_org_id,
              non_labor_std_bill_rate_schdl   = l_nl_std_bill_rate_schdl,
              Non_Labor_Schedule_Fixed_Date  = DECODE( l_non_labor_sch_type, 'I', null, Non_Labor_Schedule_Fixed_Date ),
              Non_Labor_Schedule_Discount    = DECODE( l_non_labor_sch_type, 'I', null, Non_Labor_Schedule_Discount ),
              rev_ind_rate_sch_id             = l_rev_ind_rate_sch_id,
              REV_IND_SCH_FIXED_DATE         = l_REV_IND_SCH_fixed_date2,
              INV_IND_SCH_FIXED_DATE         = l_INV_IND_SCH_FIXED_date2,
              inv_ind_rate_sch_id             = l_inv_ind_rate_sch_id,
              labor_bill_rate_org_id          = l_labor_bill_rate_org_id,
              labor_std_bill_rate_schdl       = l_labor_std_bill_rate_schdl,
              non_lab_std_bill_rt_sch_id      = l_non_lab_std_bill_rt_sch_id

        WHERE project_id                      = p_project_id;

    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PVT.Update_Project_Template END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Update_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Update_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PVT',
                              p_procedure_name => 'Update_Project_Template',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Update_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PVT',
                              p_procedure_name => 'Update_Project_Template',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Update_Project_Template;

-- API name                      : Delete_Project_Template
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- p_project_id           IN    NUMBER,
-- p_record_version_number IN   NUMBER,
--

PROCEDURE Delete_Project_Template(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id           IN    NUMBER,
 p_record_version_number IN   NUMBER,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Delete_Project_Template';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);

   l_err_code                         NUMBER;
   l_err_stage                        VARCHAR2(250);
   l_err_stack                        VARCHAR2(250);


BEGIN
    pa_debug.init_err_stack ('PA_PROJ_TEMPLATE_SETUP_PVT.Delete_Project_Template');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PVT.Delete_Project_Template begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Delete_Project_Template;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Bug 2947492: The following api call is modified to pass parameters by notation.
    Pa_Project_Core.Delete_Project (
                   x_project_id    =>  p_Project_id,
                   x_err_code      =>  l_err_code ,
                   x_err_stage     =>  l_err_stage,
                   x_err_stack     =>  l_err_stack);

    IF l_err_code <> 0
    THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => l_err_stage);
       x_msg_data := l_err_stage;
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PVT.Delete_Project_Template END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PVT',
                              p_procedure_name => 'Delete_Project_Template',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Project_Template;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PVT',
                              p_procedure_name => 'Delete_Project_Template',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Delete_Project_Template;

-- API name                      : Add_Project_Options
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- p_project_id           IN    NUMBER,
-- p_option_copde         IN    VARCHAR2,
--

PROCEDURE Add_Project_Options(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id           IN    NUMBER,
 p_option_code          IN    VARCHAR2,
 p_action               IN    VARCHAR2 := 'ENABLE',
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Add_Project_Options';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);

   l_err_code                      NUMBER;
   l_err_stage                     VARCHAR2(250);
   l_err_stack                     VARCHAR2(250);
   l_dummy_char                    VARCHAR2(1);


   CURSOR cur_chk_options
   IS
     SELECT 'x'
       FROM pa_project_options
      WHERE project_id = p_project_id
        AND option_code = p_option_code;
BEGIN
    pa_debug.init_err_stack ('PA_PROJ_TEMPLATE_SETUP_PVT.Add_Project_Options');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PVT.Add_Project_Options begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Add_Project_Options;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    OPEN cur_chk_options;
    FETCH cur_chk_options INTO l_dummy_char;
    IF cur_chk_options%NOTFOUND
    THEN
       INSERT INTO pa_project_options
                  (
                    project_id,
                    option_code,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login,
                    record_version_number
                   )
         VALUES   ( p_project_id,
                    p_option_code,
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    FND_GLOBAL.LOGIN_ID ,
                    1
                   );
    END IF;
    CLOSE cur_chk_options;

    IF p_action = 'ENABLE'
    THEN
        enable_disbale_proj_opt( p_project_id, p_option_code, p_action );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PVT.Add_Project_Options END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Add_Project_Options;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Add_Project_Options;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PVT',
                              p_procedure_name => 'Add_Project_Options',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Add_Project_Options;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PVT',
                              p_procedure_name => 'Add_Project_Options',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Add_Project_Options;


-- API name                      : Delete_Project_Options
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- p_project_id           IN    NUMBER,
-- p_option_copde         IN    VARCHAR2,
--

PROCEDURE Delete_Project_Options(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id           IN    NUMBER,
 p_option_code          IN    VARCHAR2,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Delete_Project_Options';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);

   l_err_code                      NUMBER;
   l_err_stage                     VARCHAR2(250);
   l_err_stack                     VARCHAR2(250);

   l_option_name                   VARCHAR2(80);

   CURSOR cur_option_name
   IS
     SELECT meaning
       FROM fnd_lookup_values
      WHERE lookup_type = 'PA_OPTIONS_SS'
        AND lookup_code = p_option_code
	AND language = userenv('LANG'); -- Bug 5643345: Added the environment language condition.
-- anlee
-- Added for PA_OPTIONS enhancements
   CURSOR get_allow_ovr_enabled
   IS
   SELECT allow_override_enabled_flag
   FROM PA_OPTIONS
   WHERE option_code = p_option_code;

   l_allow_ovr_enabled VARCHAR2(1);
-- End of changes
BEGIN
    pa_debug.init_err_stack ('PA_PROJ_TEMPLATE_SETUP_PVT.Delete_Project_Options');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PVT.Delete_Project_Options begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Delete_Project_Options;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --bug

-- anlee
-- Changes for PA_OPTIONS enhancements

    OPEN get_allow_ovr_enabled;
    FETCH get_allow_ovr_enabled INTO l_allow_ovr_enabled;
    CLOSE get_allow_ovr_enabled;

--    IF PA_PROJ_TEMPLATE_SETUP_UTILS.Header_Option( p_option_code ) = 'Y' OR
--       p_option_code = 'BASIC_INFO_SS'    --only mandatory option

      IF l_allow_ovr_enabled <> 'Y'
-- End of changes
    THEN
-- Changes for Bug 5643345

        OPEN cur_option_name;
        FETCH cur_option_name INTO l_option_name;
        CLOSE cur_option_name;


        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_PROJ_CANT_DISBL_OPTN',
                             p_token1         => 'OPTION_NAME',
                             p_value1         => l_option_name
                            );

        /*PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_ALL_NO_UPDATE_RECORD');*/
        x_msg_data := 'PA_PROJ_CANT_DISBL_OPTN';
	-- End of changes for Bug 5643345
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    DELETE FROM pa_project_options WHERE project_id = p_project_id AND option_code = p_option_code;

    enable_disbale_proj_opt( p_project_id, p_option_code, 'DISABLE' );

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PVT.Delete_Project_Options END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Project_Options;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Project_Options;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PVT',
                              p_procedure_name => 'Delete_Project_Options',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Project_Options;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PVT',
                              p_procedure_name => 'Delete_Project_Options',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Delete_Project_Options;


-- API name                      : Add_Quick_Entry_Field
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- p_project_id       IN    NUMBER  ,
-- p_sort_order       IN    NUMBER  ,
-- p_field_name       IN    VARCHAR2    := 'ABCD',
-- p_limiting_value       IN    VARCHAR2    := 'ABCD',
-- p_prompt             IN  VARCHAR2    ,
-- p_required_flag        IN    VARCHAR2    := 'N',--

PROCEDURE Add_Quick_Entry_Field(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id         IN    NUMBER  ,
 p_sort_order         IN    NUMBER  ,
 p_field_name         IN    VARCHAR2    := 'JUNK_CHARS',
 p_limiting_value         IN    VARCHAR2    := 'JUNK_CHARS',
 p_prompt               IN  VARCHAR2    ,
 p_required_flag          IN    VARCHAR2    := 'N',
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Add_Quick_Entry_Field';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);

   l_err_code                      NUMBER;
   l_err_stage                     VARCHAR2(250);
   l_err_stack                     VARCHAR2(250);
   l_dummy_char                    VARCHAR2(1);
   l_field_name_meaning            VARCHAR2(250);

   CURSOR cur_overrides
   IS
     SELECT 'x'
       FROM pa_project_copy_overrides
      WHERE project_id = p_project_id
        AND field_name = p_field_name
        AND sort_order = p_sort_order;

   CURSOR cur_chk_sort_order
   IS
     SELECT 'x'
       FROM pa_project_copy_overrides
      WHERE project_id = p_project_id
        AND sort_order = p_sort_order;

  CURSOR cur_dup_quick_entry
  IS
    SELECT 'X'
      FROM pa_project_copy_overrides
     WHERE project_id = p_project_id
       AND field_name = p_field_name;


BEGIN
    pa_debug.init_err_stack ('PA_PROJ_TEMPLATE_SETUP_PVT.Add_Quick_Entry_Field');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PVT.Add_Quick_Entry_Field begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Add_Quick_Entry_Field;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --check sort order unique
    OPEN cur_chk_sort_order;
    FETCH cur_chk_sort_order INTO l_dummy_char;
    IF cur_chk_sort_order%FOUND
    THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_SETUP_SORT_ORDER_NOT_UNIQ' );
        x_msg_data := 'PA_SETUP_SORT_ORDER_NOT_UNIQ';
        x_return_status := 'E';
        CLOSE cur_chk_sort_order;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
        CLOSE cur_chk_sort_order;
    END IF;

    --Duplicate quick entry check.
    --Removed the CUSTOMER_NAME from the below if for bug 3619423
    IF p_field_name NOT IN ( 'KEY_MEMBER', 'CLASSIFICATION', 'ORG_ROLE' )
    THEN
       --check duplicate quick entry.
       OPEN cur_dup_quick_entry;
       FETCH cur_dup_quick_entry INTO l_dummy_char;
       IF cur_dup_quick_entry%FOUND
       THEN
           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_SETUP_DUP_QUICK_ENTRY' );
           x_msg_data := 'PA_SETUP_DUP_QUICK_ENTRY';
           x_return_status := 'E';
           CLOSE cur_dup_quick_entry;
           RAISE  FND_API.G_EXC_ERROR;
       ELSE
           CLOSE cur_dup_quick_entry;
       END IF;
  /* Bug 4139681 - Replaced the ELSE with the new IF condition so that checks for specifications are done for
                   field CUSTOMER_NAME as well.
  */
  --ELSE
    END IF; --Bug 4139681
    IF p_field_name IN ( 'KEY_MEMBER', 'CLASSIFICATION', 'ORG_ROLE', 'CUSTOMER_NAME' ) THEN--Bug 4139681

       IF p_limiting_value IS NULL OR p_limiting_value = 'JUNK_CHARS'
       THEN
           BEGIN
                SELECT meaning
                  INTO l_field_name_meaning
                  FROM fnd_lookup_values
                 WHERE lookup_type = 'OVERRIDE FIELD'
                   AND lookup_code = p_field_name;
           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   x_msg_data := 'PA_SETUP_INV_FIELD_NAME';
                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_SETUP_INV_FIELD_NAME');
                   x_return_status := 'E';
                   RAISE  FND_API.G_EXC_ERROR;
              WHEN OTHERS THEN
                  null;
           END;

           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_SETUP_SPEC_REQ',
                                p_token1         => 'FIELD_NAME',
                                p_value1         => l_field_name_meaning );
           x_msg_data := 'PA_SETUP_SPEC_REQ';
           x_return_status := 'E';
           RAISE  FND_API.G_EXC_ERROR;
       ELSE
           IF  p_field_name <> 'CLASSIFICATION'
           THEN
               BEGIN
                    SELECT 'x'
                      INTO l_dummy_char
                      FROM PA_QUICK_ENTRY_SPECS_SS_V
                     WHERE FIELD_NAME = p_field_name
                       AND LIMITING_VALUE = p_limiting_value;
               EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    x_msg_data := 'PA_SETUP_INV_SPEC';
                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                         p_msg_name       => 'PA_SETUP_INV_SPEC',
                                         p_token1         => 'SPECIFICATION',
                                         p_value1         => p_limiting_value );
                    x_return_status := 'E';
                    RAISE  FND_API.G_EXC_ERROR;
                   WHEN OTHERS THEN
                        null;
               END;
            ELSE
                DECLARE
                    CURSOR cur_pa_proj_type
                    IS
                      SELECT project_type_id
                        FROM pa_project_types ppt, pa_projects pp
                       WHERE project_id = p_project_id
                         AND pp.project_type = ppt.project_type;
                    l_project_type_id  NUMBER;
                BEGIN
                    OPEN cur_pa_proj_type;
                    FETCH cur_pa_proj_type INTO l_project_type_id;
                    CLOSE cur_pa_proj_type;
                    IF l_project_type_id IS NOT NULL
                    THEN
                        -- Bug#3693202
                        -- Commented the existing select which looks into
                        -- PA_QUICK_ENTRY_SPECS_SS_V view , instead accessed
                        -- PA_VALID_CATEGORIES_V directly fr performance .

                            -- SELECT 'x'
                            --   INTO l_dummy_char
                            --   FROM PA_QUICK_ENTRY_SPECS_SS_V
                            --  WHERE FIELD_NAME = p_field_name
                            --    AND object_type_id = l_project_type_id
                            --    AND LIMITING_VALUE = p_limiting_value;


                        SELECT 'X'
                          INTO l_dummy_char
                         FROM  pa_valid_categories_v pvc ,
                               pa_lookups pl
                         WHERE pvc.object_type = 'PA_PROJECTS'
                           AND pvc.object_type_id = l_project_type_id
                           AND 'CLASSIFICATION' = pl.lookup_code
                           AND pl.lookup_type = 'OVERRIDE FIELD'
                           AND pvc.class_category = p_limiting_value ;
                    END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    x_msg_data := 'PA_SETUP_INV_SPEC';
                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                         p_msg_name       => 'PA_SETUP_INV_SPEC',
                                         p_token1         => 'SPECIFICATION',
                                         p_value1         => p_limiting_value );
                    x_return_status := 'E';
                    RAISE  FND_API.G_EXC_ERROR;
                   WHEN OTHERS THEN
                        null;
                END;
            END IF;  --<< field_name <> 'CLASSIFICATION' >>
       END IF;
    END IF;

    OPEN cur_overrides;
    FETCH cur_overrides INTO l_dummy_char;
    IF cur_overrides%NOTFOUND
    THEN
       INSERT INTO pa_project_copy_overrides
                 (  PROJECT_ID                      ,
                    FIELD_NAME                      ,
                    DISPLAY_NAME                    ,
                    LAST_UPDATE_DATE                ,
                    LAST_UPDATED_BY                 ,
                    CREATION_DATE                   ,
                    CREATED_BY                      ,
                    LAST_UPDATE_LOGIN               ,
                    LIMITING_VALUE                  ,
                    SORT_ORDER                      ,
                    MANDATORY_FLAG                  ,
                    RECORD_VERSION_NUMBER
                 )
          VALUES (  p_project_id                    ,
                    p_field_name                    ,
                    p_prompt                        ,
                    SYSDATE                         ,
                    FND_GLOBAL.USER_ID              ,
                    SYSDATE                         ,
                    FND_GLOBAL.USER_ID              ,
                    FND_GLOBAL.LOGIN_ID             ,
                    p_limiting_value                ,
                    p_sort_order                    ,
                    p_required_flag                ,
                    1
                 );
    END IF;
    CLOSE cur_overrides;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PVT.Add_Quick_Entry_Field END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Add_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Add_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PVT',
                              p_procedure_name => 'Add_Quick_Entry_Field',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Add_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PVT',
                              p_procedure_name => 'Add_Quick_Entry_Field',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Add_Quick_Entry_Field;

-- API name                      : Update_Quick_Entry_Field
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- p_project_id       IN    NUMBER  ,
-- p_sort_order       IN    NUMBER  ,
-- p_field_name       IN    VARCHAR2    := 'ABCD',
-- p_limiting_value       IN    VARCHAR2    := 'ABCD',
-- p_prompt             IN  VARCHAR2    ,
-- p_required_flag        IN    VARCHAR2    := 'N',--

PROCEDURE Update_Quick_Entry_Field(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id         IN    NUMBER  ,
 p_row_id               IN    VARCHAR2,
 p_sort_order         IN    NUMBER  ,
 p_field_name         IN    VARCHAR2    := 'JUNK_CHARS',
 p_limiting_value         IN    VARCHAR2    := 'JUNK_CHARS',
 p_prompt               IN  VARCHAR2    ,
 p_required_flag          IN    VARCHAR2    := 'N',
 p_record_version_number IN   NUMBER,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Update_Quick_Entry_Field';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);

   l_err_code                      NUMBER;
   l_err_stage                     VARCHAR2(250);
   l_err_stack                     VARCHAR2(250);
   l_dummy_char                    VARCHAR2(1);
   l_field_name_meaning            VARCHAR2(250);

   CURSOR cur_chk_sort_order
   IS
     SELECT 'x'
       FROM pa_project_copy_overrides
      WHERE rowid <> p_row_id
        AND project_id = p_project_id
        AND sort_order = p_sort_order;

  CURSOR cur_dup_quick_entry
  IS
    SELECT 'X'
      FROM pa_project_copy_overrides
     WHERE rowid <> p_row_id
       AND project_id = p_project_id
       AND field_name = p_field_name;
BEGIN
    pa_debug.init_err_stack ('PA_PROJ_TEMPLATE_SETUP_PVT.Update_Quick_Entry_Field');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PVT.Update_Quick_Entry_Field begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Update_Quick_Entry_Field;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --cant update Project Number or Proejct Name
    IF ( p_FIELD_NAME = 'SEGMENT1' OR p_FIELD_NAME = 'NAME' ) AND
       p_required_flag = 'N'
    THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_SETUP_CANT_MODFY_OVER' );
        x_msg_data := 'PA_SETUP_CANT_MODFY_OVER';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    --check sort order unique
    OPEN cur_chk_sort_order;
    FETCH cur_chk_sort_order INTO l_dummy_char;
    IF cur_chk_sort_order%FOUND
    THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_SETUP_SORT_ORDER_NOT_UNIQ' );
        x_msg_data := 'PA_SETUP_SORT_ORDER_NOT_UNIQ';
        x_return_status := 'E';
        CLOSE cur_chk_sort_order;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
        CLOSE cur_chk_sort_order;
    END IF;

    IF p_field_name NOT IN ( 'KEY_MEMBER', 'CLASSIFICATION', 'CUSTOMER_NAME' ,'ORG_ROLE')
    THEN
       --check duplicate quick entry.
       OPEN cur_dup_quick_entry;
       FETCH cur_dup_quick_entry INTO l_dummy_char;
       IF cur_dup_quick_entry%FOUND
       THEN
           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_SETUP_DUP_QUICK_ENTRY' );
           x_msg_data := 'PA_SETUP_DUP_QUICK_ENTRY';
           x_return_status := 'E';
           CLOSE cur_dup_quick_entry;
           RAISE  FND_API.G_EXC_ERROR;
       ELSE
           CLOSE cur_dup_quick_entry;
       END IF;
    ELSE
       IF p_limiting_value IS NULL OR p_limiting_value = 'JUNK_CHARS'
       THEN
           BEGIN
                SELECT meaning
                  INTO l_field_name_meaning
                  FROM fnd_lookup_values
                 WHERE lookup_type = 'OVERRIDE FIELD'
                   AND lookup_code = p_field_name;
           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   x_msg_data := 'PA_SETUP_INV_FIELD_NAME';
                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_SETUP_INV_FIELD_NAME');
                   x_return_status := 'E';
                   RAISE  FND_API.G_EXC_ERROR;
              WHEN OTHERS THEN
                   null;
           END;

           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_SETUP_SPEC_REQ',
                                p_token1         => 'FIELD_NAME',
                                p_value1         => l_field_name_meaning );
           x_msg_data := 'PA_SETUP_SPEC_REQ';
           x_return_status := 'E';
           RAISE  FND_API.G_EXC_ERROR;
       ELSE
           IF  p_field_name <> 'CLASSIFICATION'
           THEN
               BEGIN
                   SELECT 'x'
                     INTO l_dummy_char
                     FROM PA_QUICK_ENTRY_SPECS_SS_V
                    WHERE FIELD_NAME = p_field_name
                      AND LIMITING_VALUE = p_limiting_value;
               EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        x_msg_data := 'PA_SETUP_INV_SPEC';
                        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_SETUP_INV_SPEC',
                                   p_token1         => 'SPECIFICATION',
                                   p_value1         => p_limiting_value );
                        x_return_status := 'E';
                        RAISE  FND_API.G_EXC_ERROR;
                   WHEN OTHERS THEN
                        null;
               END;
            ELSE
                DECLARE
                    CURSOR cur_pa_proj_type
                    IS
                      SELECT project_type_id
                        FROM pa_project_types ppt, pa_projects pp
                       WHERE project_id = p_project_id
                         AND pp.project_type = ppt.project_type;
                    l_project_type_id  NUMBER;
                BEGIN
                    OPEN cur_pa_proj_type;
                    FETCH cur_pa_proj_type INTO l_project_type_id;
                    CLOSE cur_pa_proj_type;
                    IF l_project_type_id IS NOT NULL
                    THEN

                        -- Bug#3693202
                        -- Commented the existing select which looks into
                        -- PA_QUICK_ENTRY_SPECS_SS_V view , instead accessed
                        -- PA_VALID_CATEGORIES_V directly fr performance .

                       -- SELECT 'x'
                       --   INTO l_dummy_char
                       --   FROM PA_QUICK_ENTRY_SPECS_SS_V
                       --  WHERE FIELD_NAME = p_field_name
                       --    AND object_type_id = l_project_type_id
                       --    AND LIMITING_VALUE = p_limiting_value;

                       SELECT 'X'
                         INTO  l_dummy_char
                         FROM  pa_valid_categories_v pvc ,
                               pa_lookups pl
                         WHERE pvc.object_type = 'PA_PROJECTS'
                           AND pvc.object_type_id = l_project_type_id
                           AND 'CLASSIFICATION' = pl.lookup_code
                           AND pl.lookup_type = 'OVERRIDE FIELD'
                           AND pvc.class_category = p_limiting_value ;
                    END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         x_msg_data := 'PA_SETUP_INV_SPEC';
                         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                         p_msg_name       => 'PA_SETUP_INV_SPEC',
                                         p_token1         => 'SPECIFICATION',
                                         p_value1         => p_limiting_value );
                         x_return_status := 'E';
                         RAISE  FND_API.G_EXC_ERROR;
                    WHEN OTHERS THEN
                         null;
                END;
            END IF;
       END IF;
    END IF;

    UPDATE pa_project_copy_overrides
       SET FIELD_NAME             = p_field_name   ,
           DISPLAY_NAME           = p_prompt ,
           LAST_UPDATE_DATE       = SYSDATE        ,
           LAST_UPDATED_BY        = FND_GLOBAL.USER_ID        ,
           LAST_UPDATE_LOGIN      = FND_GLOBAL.LOGIN_ID        ,
           LIMITING_VALUE         = p_limiting_value        ,
           SORT_ORDER             = p_sort_order        ,
           MANDATORY_FLAG         = p_required_flag        ,
           RECORD_VERSION_NUMBER  = NVL( RECORD_VERSION_NUMBER, 1 ) + 1
     WHERE rowid = p_row_id;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PVT.Update_Quick_Entry_Field END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Update_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Update_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PVT',
                              p_procedure_name => 'Update_Quick_Entry_Field',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Update_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PVT',
                              p_procedure_name => 'Update_Quick_Entry_Field',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Update_Quick_Entry_Field;

-- API name                      : DELETE_Quick_Entry_Field
-- Type                          : Public API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- p_project_id       IN    NUMBER  ,
-- p_sort_order       IN    NUMBER  ,
-- p_field_name       IN    VARCHAR2    := 'ABCD',
-- p_limiting_value       IN    VARCHAR2    := 'ABCD',
-- p_prompt             IN  VARCHAR2    ,
-- p_required_flag        IN    VARCHAR2    := 'N',--

PROCEDURE Delete_Quick_Entry_Field(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id         IN    NUMBER  ,
 p_row_id               IN    VARCHAR2,
 p_record_version_number IN   NUMBER,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_api_name                      CONSTANT VARCHAR(30) := 'Delete_Quick_Entry_Field';
   l_api_version                   CONSTANT NUMBER      := 1.0;

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);

   l_err_code                      NUMBER;
   l_err_stage                     VARCHAR2(250);
   l_err_stack                     VARCHAR2(250);
   l_dummy_char                    VARCHAR2(1);

   CURSOR cur_chk_dflt_qe
   IS
     SELECT field_name
       FROM pa_project_copy_overrides
      WHERE rowid = p_row_id;

   l_field_name   VARCHAR2(80);

BEGIN
    pa_debug.init_err_stack ('PA_PROJ_TEMPLATE_SETUP_PVT.Delete_Quick_Entry_Field');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PVT.Delete_Quick_Entry_Field begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Delete_Quick_Entry_Field;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
    END IF;

    OPEN cur_chk_dflt_qe;
    FETCH cur_chk_dflt_qe INTO l_field_name;
    CLOSE cur_chk_dflt_qe;

    --cant update Project Number or Proejct Name
    IF l_FIELD_NAME = 'SEGMENT1' OR l_FIELD_NAME = 'NAME'
    THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_SETUP_CANT_MODFY_OVER' );
        x_msg_data := 'PA_SETUP_CANT_MODFY_OVER';
        x_return_status := 'E';
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    DELETE FROM pa_project_copy_overrides
     WHERE rowid = p_row_id;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJ_TEMPLATE_SETUP_PVT.Delete_Quick_Entry_Field END');
    END IF;
EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PVT',
                              p_procedure_name => 'Delete_Quick_Entry_Field',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to Delete_Quick_Entry_Field;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_TEMPLATE_SETUP_PVT',
                              p_procedure_name => 'Delete_Quick_Entry_Field',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END Delete_Quick_Entry_Field;

PROCEDURE enable_disbale_proj_opt(
   p_project_id               NUMBER,
   p_option_code              VARCHAR2,
   p_action                   VARCHAR2
) IS

   CURSOR cur_pa_lkups
   IS
     SELECT lk1.lookup_code forms_opt_code, lk2.lookup_code ss_opt_code, lk1.meaning
       FROM fnd_lookup_values lk1, fnd_lookup_values lk2
      WHERE lk1.lookup_type = 'PA_OPTIONS'
        AND lk2.lookup_type = 'PA_OPTIONS_SS'
        AND lk1.meaning = lk2.meaning
      ;

   CURSOR cur_chk_options( c_option_code VARCHAR2 )
   IS
     SELECT 'x'
       FROM pa_project_options
      WHERE project_id = p_project_id
        AND option_code = c_option_code;

   l_option_code  VARCHAR2(30);
   l_found_flag    VARCHAR2(1) := 'N';
   l_dummy_char     VARCHAR2(1);

BEGIN
     FOR cur_pa_lkups_rec in cur_pa_lkups LOOP
         IF cur_pa_lkups_rec.forms_opt_code = p_option_code
         THEN
               l_option_code := cur_pa_lkups_rec.ss_opt_code;
               l_found_flag := 'Y';
         ELSIF cur_pa_lkups_rec.ss_opt_code = p_option_code
         THEN
               l_option_code := cur_pa_lkups_rec.forms_opt_code;
               l_found_flag := 'Y';
         ELSE
             l_found_flag := 'N';
         END IF;

         IF l_found_flag = 'Y' AND l_option_code IS NOT NULL AND p_action = 'ENABLE'
         THEN
              OPEN cur_chk_options( l_option_code );
              FETCH cur_chk_options INTO l_dummy_char;
              IF cur_chk_options%NOTFOUND
              THEN
                  INSERT INTO pa_project_options
                      (
                    project_id,
                    option_code,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login,
                    record_version_number
                   )
                   VALUES   ( p_project_id,
                    l_option_code,
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    FND_GLOBAL.LOGIN_ID ,
                    1
                   );
              END IF;
              CLOSE cur_chk_options;
         ELSIF l_found_flag = 'Y' AND l_option_code IS NOT NULL AND p_action = 'DISABLE'
         THEN
              DELETE FROM pa_project_options WHERE project_id = p_project_id and option_code = l_option_code ;
         END IF; --<< l_insert_flag >>
     END LOOP;
END enable_disbale_proj_opt;

END PA_PROJ_TEMPLATE_SETUP_PVT;

/
