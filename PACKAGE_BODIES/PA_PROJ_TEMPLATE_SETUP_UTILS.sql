--------------------------------------------------------
--  DDL for Package Body PA_PROJ_TEMPLATE_SETUP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_TEMPLATE_SETUP_UTILS" AS
/* $Header: PATMSTUB.pls 120.2.12010000.5 2009/07/20 06:55:32 rmandali ship $ */

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
) AS

  CURSOR cur_pa_options
  IS
   SELECT option_name, option_function_name,sort_order, FFF.web_html_call
     FROM PA_OPTIONS PO, FND_FORM_FUNCTIONS FFF
    WHERE option_code = p_option_code
       AND PO.OPTION_FUNCTION_NAME = FFF.FUNCTION_NAME(+);
BEGIN
     OPEN cur_pa_options;
     FETCH cur_pa_options INTO x_option_name, x_function_name, x_sort_order,
                               x_web_html_call;
     CLOSE cur_pa_options;
END GET_OPTION_DETAILS;

-- API name                      : GET_PROJ_NUM_OPTION
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : 'AUTOMATIC', 'MANUAL'
--
-- Parameters
-- none

FUNCTION GET_PROJ_NUM_OPTION RETURN VARCHAR2 IS
   CURSOR cur_pa_imp
   IS
     SELECT user_defined_project_num_code
       FROM pa_implementations;

   l_return_value VARCHAR2(25);
BEGIN

    OPEN cur_pa_imp;
    FETCH cur_pa_imp INTO l_return_value;
    CLOSE cur_pa_imp;
    RETURN l_return_value;

END GET_PROJ_NUM_OPTION;

-- API name                      : Header_Option
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : 'Y', 'N'
--
-- Parameters
-- p_option_code    VARCHAR2;

FUNCTION Header_Option( p_option_code VARCHAR2 ) RETURN VARCHAR2 IS

   CURSOR cur_pa_options
   IS
    SELECT 'X'
      FROM pa_options
     WHERE parent_option_code = p_option_code;
   l_dummy_char VARCHAR2(1);
BEGIN
    OPEN cur_pa_options;
    FETCH cur_pa_options INTO l_dummy_char;
    IF cur_pa_options%FOUND
    THEN
       CLOSE cur_pa_options;
       RETURN 'Y';
    ELSE
       CLOSE cur_pa_options;
       RETURN 'N';
    END IF;
END Header_Option;

-- API name                      : get_limiting_value_meaning
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : the meaning in case of customer and key member and category code
--                                 in case of classification'Y', 'N'
--
-- Parameters
-- p_field_name    VARCHAR2;
-- p_limiting_value    VARCHAR2;

FUNCTION get_limiting_value_meaning( p_field_name VARCHAR2, p_limiting_value VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR cur_key_member
   IS
     SELECT roles.meaning
       FROM pa_project_role_types_vl roles
      WHERE trunc(sysdate) between start_date_active and nvl(end_date_active, sysdate)
        AND roles.project_role_type = p_limiting_value;

   CURSOR cur_customer_name
   IS
     SELECT meaning
       FROM pa_lookups
      WHERE lookup_type = 'CUSTOMER PROJECT RELATIONSHIP'
        AND enabled_flag = 'Y'
        AND trunc(sysdate) between start_date_active and nvl(end_date_active, sysdate)
        AND lookup_code = p_limiting_value;

   l_return_value   VARCHAR2(240);

BEGIN
    IF p_field_name in( 'KEY_MEMBER', 'ORG_ROLE' )
    THEN
        OPEN cur_key_member;
        FETCH cur_key_member INTO l_return_value;
        CLOSE cur_key_member;
    ELSIF p_field_name = 'CUSTOMER_NAME'
    THEN
        OPEN cur_customer_name;
        FETCH cur_customer_name INTO l_return_value;
        CLOSE cur_customer_name;
    ELSIF p_field_name = 'CLASSIFICATION'
    THEN
       --In case of classification the category code is limiting value and specification as well.
       l_return_value := p_limiting_value;
    END IF;

    RETURN l_return_value;
END get_limiting_value_meaning;

-- API name                      : get_limiting_value_meaning
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : None
--
-- Parameters
-- p_option_code    VARCHAR2;

PROCEDURE Check_Template_attr_req(
  p_project_number        VARCHAR2,
  p_project_name        VARCHAR2,
  p_project_type          VARCHAR2,
  p_organization_id       NUMBER,
  x_return_status	    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_error_msg_code    OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
 ) IS
BEGIN
  x_return_status:= FND_API.G_RET_STS_SUCCESS;

  IF p_project_number IS NULL
  THEN
      x_error_msg_code := 'PA_SETUP_PROJ_NUM_REQ';
      x_return_status:= FND_API.G_RET_STS_ERROR;
      RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF p_project_name IS NULL
  THEN
      x_error_msg_code := 'PA_SETUP_PROJ_NAME_REQ';
      x_return_status:= FND_API.G_RET_STS_ERROR;
      RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF p_project_type IS NULL
  THEN
      x_error_msg_code := 'PA_SETUP_PROJ_TYPE_REQ';
      x_return_status:= FND_API.G_RET_STS_ERROR;
      RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF p_organization_id IS NULL
  THEN
      x_error_msg_code := 'PA_SETUP_ORG_ID_REQ';
      x_return_status:= FND_API.G_RET_STS_ERROR;
      RAISE  FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
END Check_Template_attr_req;
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
--  x_revaluate_funding_flag           OUT VARCHAR2
--  x_include_gains_losses_flag        OUT VARCHAR2
--  x_return_status                    OUT VARCHAR2
--  x_error_msg_code                   OUT VARCHAR2
--  x_date_eff_funds_flag	       OUT VARCHAR2

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
  ,x_asset_allocation_method        OUT NOCOPY VARCHAR2   --File.Sql.39 bug 4440895
  ,x_CAPITAL_EVENT_PROCESSING       OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
  ,x_CINT_RATE_SCH_ID               OUT NOCOPY VARCHAR2   --File.Sql.39 bug 4440895
--End PA L Changes 2872708
--Federal.Bug#5511353
  ,x_date_eff_funds_flag	      OUT NOCOPY VARCHAR2
--Federal.Bug#5511353
  ,x_ar_rec_notify_flag               OUT NOCOPY VARCHAR2  -- 7508661 : EnC
  ,x_auto_release_pwp_inv             OUT NOCOPY VARCHAR2  -- 7508661 : EnC
  ,x_return_status                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                   OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
) IS
    CURSOR cur_project_types
    IS
      SELECT def_start_proj_Status_code
             ,service_type_code
             ,cost_ind_rate_sch_id
             ,labor_sch_type
             ,labor_bill_rate_org_id
             ,labor_std_bill_rate_schdl
             ,non_labor_sch_type
             ,non_labor_bill_rate_org_id
             ,non_labor_std_bill_rate_schdl
             ,rev_ind_rate_sch_id
             ,inv_ind_rate_sch_id
             ,labor_invoice_format_id
             ,non_labor_invoice_format_id
             ,Burden_cost_flag
             ,interface_asset_cost_code
             ,cost_sch_override_flag
             ,billing_offset
             ,billing_cycle_id
             ,cc_prvdr_flag
             ,bill_job_group_id
             ,cost_job_group_id
             ,work_type_id
             ,role_list_id
             ,unassigned_time
             ,emp_bill_rate_schedule_id
             ,job_bill_rate_schedule_id
             ,budgetary_override_flag
             ,baseline_funding_flag
             ,non_lab_std_bill_rt_sch_id
             ,project_type_class_code
-- anlee
-- patchset K changes
             ,revaluate_funding_flag
             ,include_gains_losses_flag
-- End of changes
--PA L Changes 2872708
            ,asset_allocation_method
            ,CAPITAL_EVENT_PROCESSING
            ,CINT_RATE_SCH_ID
--End PA L Changes 2872708
	    ,nvl(date_eff_funds_consumption,'N') --bug#5511353
            ,ar_rec_notify_flag     -- 7508661 : EnC
            ,auto_release_pwp_inv   -- 7508661 : EnC
        FROM pa_project_types
       WHERE project_type = p_project_type;
BEGIN
     x_return_status:= FND_API.G_RET_STS_SUCCESS;

     OPEN cur_project_types;
     FETCH cur_project_types INTO x_Status_code
             ,x_service_type_code
             ,x_cost_ind_rate_sch_id
             ,x_labor_sch_type
             ,x_labor_bill_rate_org_id
             ,x_labor_std_bill_rate_schdl
             ,x_non_labor_sch_type
             ,x_non_labor_bill_rate_org_id
             ,x_nl_std_bill_rate_schdl
             ,x_rev_ind_rate_sch_id
             ,x_inv_ind_rate_sch_id
             ,x_labor_invoice_format_id
             ,x_non_labor_invoice_format_id
             ,x_Burden_cost_flag
             ,x_interface_asset_cost_code
             ,x_cost_sch_override_flag
             ,x_billing_offset
             ,x_billing_cycle_id
             ,x_cc_prvdr_flag
             ,x_bill_job_group_id
             ,x_cost_job_group_id
             ,x_work_type_id
             ,x_role_list_id
             ,x_unassigned_time
             ,x_emp_bill_rate_schedule_id
             ,x_job_bill_rate_schedule_id
             ,x_budgetary_override_flag
             ,x_baseline_funding_flag
             ,x_non_lab_std_bill_rt_sch_id
             ,x_project_type_class_code
-- anlee
-- patchset K changes
             ,x_revaluate_funding_flag
             ,x_include_gains_losses_flag
-- End of changes
--PA L Changes 2872708
             ,x_asset_allocation_method
             ,x_CAPITAL_EVENT_PROCESSING
             ,x_CINT_RATE_SCH_ID
--End PA L Changes 2872708
	     ,x_date_eff_funds_flag
             ,x_ar_rec_notify_flag     -- 7508661 : EnC
             ,x_auto_release_pwp_inv   -- 7508661 : EnC
             ;

     IF cur_project_types%NOTFOUND
     THEN
        x_error_msg_code := 'PA_SETUP_INV_PROJ_TYPE';
        x_return_status:= FND_API.G_RET_STS_ERROR;
        CLOSE cur_project_types;
        RAISE  FND_API.G_EXC_ERROR;
     ELSE
        CLOSE cur_project_types;
     END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;

END Get_Project_Type_Defaults;

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
 ) AS
    CURSOR cur_field_name
    IS
      SELECT lookup_code
        FROM pa_lookups
       WHERE meaning = p_field_name_meaning
         AND lookup_type = 'OVERRIDE FIELD';

BEGIN
    x_return_status:= FND_API.G_RET_STS_SUCCESS;

    OPEN cur_field_name;
    FETCH cur_field_name INTO x_field_name;
    IF cur_field_name%NOTFOUND
    THEN
       x_return_status:= FND_API.G_RET_STS_ERROR;
       CLOSE cur_field_name;
       x_error_msg_code := 'PA_SETUP_INV_FIELD_MEANG';
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE cur_field_name;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;

END Get_Field_name;

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
 ) AS

   CURSOR cur_key_member
   IS
     SELECT roles.project_role_type
       FROM pa_project_role_types_vl roles
      WHERE trunc(sysdate) between start_date_active and nvl(end_date_active, sysdate)
        AND roles.meaning = p_specification;

   CURSOR cur_customer_name
   IS
     SELECT lookup_code
       FROM pa_lookups
      WHERE lookup_type = 'CUSTOMER PROJECT RELATIONSHIP'
        AND enabled_flag = 'Y'
        AND trunc(sysdate) between start_date_active and nvl(end_date_active, sysdate)
        AND meaning = p_specification;


 BEGIN
    x_return_status:= FND_API.G_RET_STS_SUCCESS;
    IF p_field_name = 'CLASSIFICATION'
    THEN
        x_limiting_value := p_specification;
    ELSIF p_field_name = 'KEY_MEMBER'
    THEN
        OPEN cur_key_member;
        FETCH cur_key_member INTO x_limiting_value;
        IF cur_key_member%NOTFOUND
        THEN
           x_return_status:= FND_API.G_RET_STS_ERROR;
           CLOSE cur_key_member;
           x_error_msg_code := 'PA_SETUP_INV_KM_MEANG';
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE cur_key_member;
    ELSIF p_field_name = 'ORG_ROLE'
    THEN
        OPEN cur_key_member;
        FETCH cur_key_member INTO x_limiting_value;
        IF cur_key_member%NOTFOUND
        THEN
           x_return_status:= FND_API.G_RET_STS_ERROR;
           CLOSE cur_key_member;
           x_error_msg_code := 'PA_SETUP_INV_ORG_ROL_MEANG';
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE cur_key_member;
    ELSIF p_field_name = 'CUSTOMER_NAME'
    THEN
        OPEN cur_customer_name;
        FETCH cur_customer_name INTO x_limiting_value;
        IF cur_customer_name%NOTFOUND
        THEN
           x_return_status:= FND_API.G_RET_STS_ERROR;
           CLOSE cur_customer_name;
           x_error_msg_code := 'PA_SETUP_INV_CUST_MEANG';
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE cur_customer_name;
    END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;

 END Get_limiting_value;


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
  ) AS
    l_current_id      NUMBER := NULL;
    l_rows            NUMBER := 0;
    l_id_found_flag   VARCHAR2(1) := 'N';

    cursor c IS
      select project_id
      from pa_projects
      where UPPER(name) = UPPER(p_template_name);

  BEGIN
    IF (p_template_id IS NULL) OR (p_template_id = -9999 ) THEN
      -- ID is empty
      IF (p_template_name IS NOT NULL ) THEN
        OPEN c;
        LOOP
          FETCH c INTO l_current_id;
          EXIT WHEN c%NOTFOUND;
          IF (l_current_id = p_template_id) THEN
            l_id_found_flag := 'Y';
            x_template_id := l_current_id;
          END IF;
        END LOOP;
        l_rows := c%ROWCOUNT;
        CLOSE c;
        If (l_rows = 0) THEN
          RAISE NO_DATA_FOUND;
        ELSIF (l_rows = 1) THEN
          x_template_id := l_current_id;
        ELSIF (l_id_found_flag = 'N') THEN
          RAISE TOO_MANY_ROWS;
        END IF;
      END IF;
    ELSE
      --dbms_output.put_line( 'In else part ' );

      -- ID is not empty;
      IF (p_check_id_flag = 'Y') THEN
        SELECT project_id
        INTO   x_template_id
        FROM   pa_projects
        WHERE  project_id = p_template_id;
      ELSIF (p_check_id_flag = 'N') THEN
        x_template_id := p_template_id;
      ELSIF (p_check_id_flag = 'A') THEN
        OPEN c;
        LOOP
          --dbms_output.put_line( 'Before fetch ' );
          FETCH c INTO l_current_id;
          EXIT WHEN c%NOTFOUND;
          IF (l_current_id = p_template_id) THEN
            l_id_found_flag := 'Y';
            x_template_id := l_current_id;
          END IF;
        END LOOP;
        l_rows := c%ROWCOUNT;
        CLOSE c;
        If (l_rows = 0) THEN
          --dbms_output.put_line( 'Before no data found cond ' );
          RAISE NO_DATA_FOUND;
        ELSIF (l_rows = 1) THEN
          x_template_id := l_current_id;
        ELSIF (l_id_found_flag = 'N') THEN
          RAISE TOO_MANY_ROWS;
        END IF;
      END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --dbms_output.put_line( 'In no data found exception ' );
      x_template_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_SETUP_INV_TMPL_ID';
    WHEN TOO_MANY_ROWS THEN
      x_template_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_SETUP_TMPL_ID_NOT_UNIQ';
    WHEN OTHERS THEN
      x_template_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_PROJ_TEMPLATE_SETUP_UTILS',
                              p_procedure_name => 'CHECK_TEMPLATE_NAME_OR_ID');
      RAISE;
  END CHECK_TEMPLATE_NAME_OR_ID;


-- API name                      : CHECK_PROJECT_NAME_OR_ID
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : None
--
-- Parameters
-- Parameters
-- p_project_name              IN  VARCHAR2    := 'JUNK_CHARS'
-- p_project_id                IN  NUMBER      := -9999
-- p_check_id_flag             IN  VARCHAR2    := 'A'
-- x_project_id                OUT NUMBER
-- x_return_status             OUT VARCHAR2
-- x_error_msg_code            OUT VARCHAR2


  procedure CHECK_PROJECT_NAME_OR_ID
  (
     p_project_name              IN  VARCHAR2    := 'JUNK_CHARS'
    ,p_project_id                IN  NUMBER      := -9999
    ,p_check_id_flag             IN  VARCHAR2    := 'A'
    ,x_project_id                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) AS
    l_current_id      NUMBER := NULL;
    l_rows            NUMBER := 0;
    l_id_found_flag   VARCHAR2(1) := 'N';
    l_ndf_exception   NUMBER; --to indicate which part of the code raised no_data_found exception

    cursor c IS
      select project_id
      from pa_projects_v      --cannot replace with project_all bcoz project name user enters must be validated with secuured view.
      where name = p_project_name; -- removed the UPPER function for perf. bug 2786121

  BEGIN

    --Initialize  error stack
    FND_MSG_PUB.initialize;

    IF (p_project_id IS NULL) OR (p_project_id = -9999) THEN
      -- ID is empty
      IF (p_project_name IS NOT NULL ) THEN
        OPEN c;
        LOOP
          FETCH c INTO l_current_id;
          EXIT WHEN c%NOTFOUND;
          IF (l_current_id = p_project_id) THEN
            l_id_found_flag := 'Y';
            x_project_id := l_current_id;
          END IF;
        END LOOP;
        l_rows := c%ROWCOUNT;
        CLOSE c;
        If (l_rows = 0) THEN
          l_ndf_exception := 1;
          RAISE NO_DATA_FOUND;
        ELSIF (l_rows = 1) THEN
          x_project_id := l_current_id;
        ELSIF (l_id_found_flag = 'N') THEN
          RAISE TOO_MANY_ROWS;
        END IF;
      END IF;
    ELSE
      -- ID is not empty;
      IF (p_check_id_flag = 'Y') THEN
        SELECT project_id
        INTO   x_project_id
        FROM   pa_projects_all               --replaced pa_projects_v with pa_projects_all for perf. bug 2786121
        WHERE  project_id = p_project_id;
      ELSIF (p_check_id_flag = 'N') THEN
        x_project_id := p_project_id;
      ELSIF (p_check_id_flag = 'A') THEN
        OPEN c;
        LOOP
          FETCH c INTO l_current_id;
          EXIT WHEN c%NOTFOUND;
          IF (l_current_id = p_project_id) THEN
            l_id_found_flag := 'Y';
            x_project_id := l_current_id;
          END IF;
        END LOOP;
        l_rows := c%ROWCOUNT;
        CLOSE c;
        If (l_rows = 0) THEN
          l_ndf_exception := 2;
          RAISE NO_DATA_FOUND;
        ELSIF (l_rows = 1) THEN
          x_project_id := l_current_id;
        ELSIF (l_id_found_flag = 'N') THEN
          RAISE TOO_MANY_ROWS;
        END IF;
      END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_project_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF l_ndf_exception = 2 THEN
         x_error_msg_code := 'PA_TASK_INV_PRJ_ID';
      ELSE
         x_error_msg_code := 'PA_SETUP_INV_PROJ_NAME';
      END IF;
    WHEN TOO_MANY_ROWS THEN
      x_project_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_TASK_PRJ_ID_NOT_UNIQ';
    WHEN OTHERS THEN
      x_project_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_PROJ_TEMPLATE_SETUP_UTILS',
                              p_procedure_name => 'CHECK_PROJECT_NAME_OR_ID');
      RAISE;
  END CHECK_PROJECT_NAME_OR_ID;

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
    ,x_msg_data	                 OUT 	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
  ) AS
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(250);
   l_data                          VARCHAR2(250);
   l_msg_index_out                 NUMBER;
   l_error_msg_code                VARCHAR2(250);
  begin
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_template_flag = 'Y'
    THEN
        PA_PROJ_TEMPLATE_SETUP_UTILS.CHECK_TEMPLATE_NAME_OR_ID(
                 p_template_name              => p_proj_tmpl_name
                ,p_template_id                => p_proj_tmpl_id
                ,p_check_id_flag              => p_check_id_flag
                ,x_template_id                => x_proj_tmpl_id
                ,x_return_status              => l_return_status
                ,x_error_msg_code             => l_error_msg_code
              );
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => l_error_msg_code);
        END IF;
    ELSE
        PA_PROJ_TEMPLATE_SETUP_UTILS.CHECK_PROJECT_NAME_OR_ID(
                 p_project_name               => p_proj_tmpl_name
                ,p_project_id                 => p_proj_tmpl_id
                ,p_check_id_flag              => p_check_id_flag
                ,x_project_id                 => x_proj_tmpl_id
                ,x_return_status              => l_return_status
                ,x_error_msg_code             => l_error_msg_code
              );
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => l_error_msg_code);
        END IF;
    END IF;
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
  exception
    when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      x_proj_tmpl_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_PROJ_TEMPLATE_SETUP_UTILS',
                              p_procedure_name => 'CHECK_PROJ_TEMPL_NAME_OR_ID');
      RAISE;

  end CHECK_PROJ_TMPL_NAME_OR_ID;


-- API name                      : GET_OPTION_ENABLED
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
-- p_option_code       IN VARCHAR2
-- p_project_id        IN NUMBER
-- x_option_enabled    OUT VARCHAR2

PROCEDURE GET_OPTION_ENABLED(
  p_option_code IN VARCHAR2
 ,p_project_id IN NUMBER
 ,x_option_enabled OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) AS

  l_template_id NUMBER;
  l_option_enabled VARCHAR2(1);
  l_check_template VARCHAR2(1);

  CURSOR get_template_id
  IS
  SELECT created_from_project_id
    FROM PA_PROJECTS_ALL
   WHERE project_id = p_project_id;

  CURSOR cur_pa_proj_options(c_project_id NUMBER)
  IS
   SELECT 'Y'
     FROM PA_PROJECT_OPTIONS PPO
     WHERE option_code = p_option_code
     AND   project_id = c_project_id;

  CURSOR check_template
  IS
  SELECT 'Y'
  FROM PA_PROJECTS_ALL
  WHERE project_id = p_project_id
  AND template_flag = 'Y';

BEGIN

  OPEN check_template;
  FETCH check_template INTO l_check_template;

  if check_template%FOUND then
    OPEN cur_pa_proj_options(p_project_id);
    FETCH cur_pa_proj_options INTO l_option_enabled;
    if cur_pa_proj_options%NOTFOUND then
      x_option_enabled := 'N';
    else
      x_option_enabled :=  l_option_enabled;
    end if;

    CLOSE cur_pa_proj_options;

  else
    OPEN get_template_id;
    FETCH get_template_id INTO l_template_id;
    CLOSE get_template_id;

    OPEN cur_pa_proj_options(l_template_id);
    FETCH cur_pa_proj_options INTO l_option_enabled;
    if cur_pa_proj_options%NOTFOUND then
      x_option_enabled := 'N';
    else
      x_option_enabled :=  l_option_enabled;
    end if;

    CLOSE cur_pa_proj_options;
  end if;

  --bug 3905802, close the cursor
  CLOSE check_template;

END GET_OPTION_ENABLED;

-- API name                      : GET_PROJ_NUM_TYPE
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : 'NUMERIC' or 'ALPHANUMERIC'
--
-- Parameters
-- none

FUNCTION GET_PROJ_NUM_TYPE RETURN VARCHAR2 IS
   CURSOR cur_pa_imp
   IS
     SELECT Manual_Project_Num_Type
       FROM pa_implementations;

   l_return_value VARCHAR2(25);
BEGIN

    OPEN cur_pa_imp;
    FETCH cur_pa_imp INTO l_return_value;
    CLOSE cur_pa_imp;
    RETURN l_return_value;

END GET_PROJ_NUM_TYPE;

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
) AS

  l_temp_flag VARCHAR2(1);

  CURSOR get_total_percent_flag
  IS
  select total_100_percent_flag
  from pa_class_categories
  where class_category = P_CATEGORY ;

BEGIN

  OPEN get_total_percent_flag;
  FETCH get_total_percent_flag INTO l_temp_flag;


    if get_total_percent_flag%NOTFOUND then
      X_TOTAL_PERCENT_FLAG := 'N';
    else
      X_TOTAL_PERCENT_FLAG :=  l_temp_flag;
    end if;

    CLOSE get_total_percent_flag;

END GET_TOTAL_PERCENT;
/* Added for Bug 8492552 End */

END PA_PROJ_TEMPLATE_SETUP_UTILS;

/
