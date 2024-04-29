--------------------------------------------------------
--  DDL for Package PA_PROJ_TEMPLATE_SETUP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_TEMPLATE_SETUP_UTILS" AUTHID CURRENT_USER AS
/* $Header: PATMSTUS.pls 120.2.12010000.5 2009/07/20 06:53:41 rmandali ship $ */

-- API name                      : GET_OPTION_DETAILS
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- p_option_code       IN VARCHAR2
-- x_option_name       OUT VARCHAR2
-- x_function_name     OUT VARCHAR2
-- x_sort_order        OUT NUMBER

PROCEDURE GET_OPTION_DETAILS(
  p_option_code IN VARCHAR2
 ,x_option_name       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_function_name     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_sort_order        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_web_html_call     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name                      : GET_PROJ_NUM_OPTION
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : 'AUTOMATIC', 'MANUAL'
--
-- Parameters
-- none

FUNCTION GET_PROJ_NUM_OPTION RETURN VARCHAR2;


-- API name                      : Header_Option
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : 'Y', 'N'
--
-- Parameters
-- p_option_code    VARCHAR2;

FUNCTION Header_Option( p_option_code VARCHAR2 ) RETURN VARCHAR2;

-- API name                      : get_limiting_value_meaning
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : the meaning in case of customer and key member and category code in case of classification'Y', 'N'
--
-- Parameters
-- p_option_code    VARCHAR2;

FUNCTION get_limiting_value_meaning( p_field_name VARCHAR2, p_limiting_value VARCHAR2 ) RETURN VARCHAR2;

-- API name                      : Check_Template_attr_req
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : None
--
-- Parameters
-- p_option_code    VARCHAR2;

PROCEDURE Check_Template_attr_req(
  p_project_number VARCHAR2,
  p_project_name VARCHAR2,
  p_project_type   VARCHAR2,
  p_organization_id NUMBER,
  x_return_status	    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_error_msg_code    OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
 );

-- API name                      : Get_Project_Type_Defaults
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : None
--
-- Parameters
--  p_project_type                         VARCHAR2
--  x_Status_code                      OUT VARCHAR2
--  x_service_type_code                OUT VARCHAR2
--  x_cost_ind_rate_sch_id             OUT NUMBER
--  x_labor_sch_type                   OUT VARCHAR2
--  x_labor_bill_rate_org_id           OUT NUMBER
--  x_labor_std_bill_rate_schdl        OUT VARCHAR2
--  x_non_labor_sch_type               OUT VARCHAR2
--  x_non_labor_bill_rate_org_id       OUT NUMBER
--  x_non_labor_std_bill_rate_schdl    OUT VARCHAR2
--  x_rev_ind_rate_sch_id              OUT NUMBER
--  x_inv_ind_rate_sch_id              OUT NUMBER
--  x_labor_invoice_format_id          OUT NUMBER
--  x_non_labor_invoice_format_id      OUT NUMBER
--  x_Burden_cost_flag                 OUT VARCHAR2
--  x_interface_asset_cost_code        OUT VARCHAR2
--  x_cost_sch_override_flag           OUT VARCHAR2
--  x_billing_offset                   OUT NUMBER
--  x_billing_cycle_id                 OUT NUMBER
--  x_cc_prvdr_flag                    OUT VARCHAR2
--  x_bill_job_group_id                OUT NUMBER
--  x_cost_job_group_id                OUT NUMBER
--  x_work_type_id                     OUT NUMBER
--  x_role_list_id                     OUT NUMBER
--  x_unassigned_time                  OUT NUMBER
--  x_emp_bill_rate_schedule_id        OUT NUMBER
--  x_job_bill_rate_schedule_id        OUT NUMBER
--  x_budgetary_override_flag          OUT VARCHAR2
--  x_baseline_funding_flag            OUT VARCHAR2
--  x_non_lab_std_bill_rt_sch_id       OUT NUMBER
-- x_revaluate_funding_flag           OUT VARCHAR2
-- x_include_gains_losses_flag      OUT VARCHAR2
--  x_return_status                    OUT VARCHAR2
--  x_error_msg_code                   OUT VARCHAR2
-- x_date_eff_funds_flag	      OUT NOCOPY VARCHAR2

PROCEDURE Get_Project_Type_Defaults(
   p_project_type                         VARCHAR2
  ,x_Status_code                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_service_type_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_cost_ind_rate_sch_id             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_labor_sch_type                   OUT NOCOPY VARCHAR2   --File.Sql.39 bug 4440895
  ,x_labor_bill_rate_org_id           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_labor_std_bill_rate_schdl        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_non_labor_sch_type               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_non_labor_bill_rate_org_id       OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_nl_std_bill_rate_schdl           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_ind_rate_sch_id              OUT NOCOPY NUMBER  --File.Sql.39 bug 4440895
  ,x_inv_ind_rate_sch_id              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_labor_invoice_format_id          OUT NOCOPY NUMBER  --File.Sql.39 bug 4440895
  ,x_non_labor_invoice_format_id      OUT NOCOPY NUMBER  --File.Sql.39 bug 4440895
  ,x_Burden_cost_flag                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_interface_asset_cost_code        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_cost_sch_override_flag           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_billing_offset                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_billing_cycle_id                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_cc_prvdr_flag                    OUT NOCOPY VARCHAR2   --File.Sql.39 bug 4440895
  ,x_bill_job_group_id                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_cost_job_group_id                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_work_type_id                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_role_list_id                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_unassigned_time                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_emp_bill_rate_schedule_id        OUT NOCOPY NUMBER  --File.Sql.39 bug 4440895
  ,x_job_bill_rate_schedule_id        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_budgetary_override_flag          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_baseline_funding_flag            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_non_lab_std_bill_rt_sch_id       OUT NOCOPY NUMBER  --File.Sql.39 bug 4440895
  ,x_project_type_class_code          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
-- anlee
-- patchset K changes
  ,x_revaluate_funding_flag           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_include_gains_losses_flag      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
-- End of changes
--PA L Changes 2872708
  ,x_asset_allocation_method        OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
  ,x_CAPITAL_EVENT_PROCESSING       OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
  ,x_CINT_RATE_SCH_ID               OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
--End PA L Changes 2872708
  ,x_date_eff_funds_flag	      OUT NOCOPY VARCHAR2 --sunkalya federal. Bug#5511353
  ,x_ar_rec_notify_flag               OUT NOCOPY VARCHAR2  -- 7508661 : EnC
  ,x_auto_release_pwp_inv             OUT NOCOPY VARCHAR2  -- 7508661 : EnC
  ,x_return_status                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                   OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);


-- API name                      : Get_Field_name
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : None
--
-- Parameters
-- p_field_name_meaning     VARCHAR2
-- x_field_name         OUT VARCHAR2
-- x_return_status	OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2

PROCEDURE Get_Field_name(
  p_field_name_meaning VARCHAR2,
  x_field_name         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_return_status	     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_error_msg_code     OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
 );

-- API name                      : Get_limiting_value
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : None
--
-- Parameters
-- p_field_name         VARCHAR2
-- p_specification      VARCHAR2
-- x_limiting_value     OUT VARCHAR2
-- x_return_status	OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2

PROCEDURE Get_limiting_value(
  p_field_name         VARCHAR2,
  p_specification      VARCHAR2,
  x_limiting_value     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_return_status	     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_error_msg_code     OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
 );

-- API name                      : CHECK_TEMPLATE_NAME_OR_ID
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : None
--
-- Parameters
-- p_template_name              IN  VARCHAR2    := 'JUNK_CHARS'
-- p_template_id                IN  NUMBER      := -9999
-- p_check_id_flag              IN  VARCHAR2    := 'A'
-- x_template_id                OUT NUMBER
-- x_return_status              OUT VARCHAR2
-- x_error_msg_code             OUT VARCHAR2

  procedure CHECK_TEMPLATE_NAME_OR_ID
  (
     p_template_name              IN  VARCHAR2    := 'JUNK_CHARS'
    ,p_template_id                IN  NUMBER      := -9999
    ,p_check_id_flag              IN  VARCHAR2    := 'A'
    ,x_template_id                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- API name                      : CHECK_PROJECT_NAME_OR_ID
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : None
--
-- Parameters
--    p_project_name              IN  VARCHAR2    := 'JUNK_CHARS'
--    p_project_id                IN  NUMBER      := -9999
--    p_check_id_flag             IN  VARCHAR2    := 'A'
--    x_project_id                OUT NUMBER
--    x_return_status             OUT VARCHAR2
--    x_error_msg_code            OUT VARCHAR2

  procedure CHECK_PROJECT_NAME_OR_ID
  (
     p_project_name              IN  VARCHAR2    := 'JUNK_CHARS'
    ,p_project_id                IN  NUMBER      := -9999
    ,p_check_id_flag             IN  VARCHAR2    := 'A'
    ,x_project_id                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- API name                      : CHECK_PROJ_TMPL_NAME_OR_ID
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : None
--
-- Parameters
-- p_proj_tmpl_name              IN  VARCHAR2    := 'JUNK_CHARS'
-- p_proj_tmpl_id                IN  NUMBER      := -9999
-- p_check_id_flag               IN  VARCHAR2    := 'A'
-- p_template_flag               IN  VARCHAR2    := 'Y'
-- x_proj_tmpl_id                OUT NUMBER
-- x_return_status               OUT VARCHAR2
-- x_error_msg_code              OUT VARCHAR2

  procedure CHECK_PROJ_TMPL_NAME_OR_ID
  (
     p_proj_tmpl_name              IN  VARCHAR2    := 'JUNK_CHARS'
    ,p_proj_tmpl_id                IN  NUMBER      := -9999
    ,p_check_id_flag               IN  VARCHAR2    := 'A'
    ,p_template_flag               IN  VARCHAR2    := 'Y'
    ,x_proj_tmpl_id                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status	           OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count	                 OUT 	NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data	                 OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- API name                      : GET_OPTION_ENABLED
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- p_option_code       IN VARCHAR2
-- p_project_id        IN NUMBER
-- x_option_enabled OUT VARCHAR2

PROCEDURE GET_OPTION_ENABLED(
  p_option_code IN VARCHAR2
 ,p_project_id IN NUMBER
 ,x_option_enabled OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name                      : GET_PROJ_NUM_TYPE
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : 'NUMERIC' or 'ALPHANUMERIC'
--
-- Parameters
-- none

FUNCTION GET_PROJ_NUM_TYPE RETURN VARCHAR2;

/* Added for Bug 8492552 Start */
-- API name                      : GET_TOTAL_PERCENT
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- P_CATEGORY       IN VARCHAR2
-- X_TOTAL_PERCENT_FLAG    OUT VARCHAR2

PROCEDURE GET_TOTAL_PERCENT(
  P_CATEGORY IN VARCHAR2
 ,X_TOTAL_PERCENT_FLAG OUT NOCOPY VARCHAR2
);
/* Added for Bug 8492552 End */

END PA_PROJ_TEMPLATE_SETUP_UTILS;

/
