--------------------------------------------------------
--  DDL for Package PA_PROJECTS_MAINT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECTS_MAINT_UTILS" AUTHID CURRENT_USER AS
/* $Header: PARMPRUS.pls 120.2 2005/08/19 16:57:11 mwasowic noship $ */
-- API name     : check_org_name_or_id
-- Type         : Public
-- Pre-reqs     : None.
-- Parameters           :
-- p_organization_id    IN hr_organization_units.organization_id%TYPE  Required
-- p_name               IN hr_organization_units.name%TYPE             Required
-- p_check_id_flag      IN VARCHAR2    Required
-- x_organization_id    OUT hr_organization_units.organization_id%TYPE Required
-- x_return_status      OUT VARCHAR2   Required
-- x_error_msg_code     OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
PROCEDURE CHECK_ORG_NAME_OR_ID
    (p_organization_id     IN hr_organization_units.organization_id%TYPE
    ,p_name                IN hr_organization_units.name%TYPE
    ,p_check_id_flag       IN VARCHAR2
    ,x_organization_id     OUT NOCOPY hr_organization_units.organization_id%TYPE --File.Sql.39 bug 4440895
    ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code      OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

-- API name             : check_check_project_status_or_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_status_code IN pa_project_statuses.project_status_code%TYPE      Required
-- p_project_status_name IN pa_project_statuses.project_status_name%TYPE     Required
-- p_check_id_flag       IN VARCHAR2    Required
-- x_project_status_code OUT pa_project_statuses.project_status_code%TYPE     Required
-- x_return_status       OUT VARCHAR2   Required
-- x_error_msg_code      OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CHECK_PROJECT_STATUS_OR_ID
    (p_project_status_code IN pa_project_statuses.project_status_code%TYPE
    ,p_project_status_name IN pa_project_statuses.project_status_name%TYPE
    ,p_check_id_flag       IN VARCHAR2
    ,x_project_status_code OUT NOCOPY pa_project_statuses.project_status_code%TYPE --File.Sql.39 bug 4440895
    ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code      OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

-- API name             : check_customer_name_or_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_customer_id         IN ra_customers.customer_id%TYPE      Required
-- p_customer_name       IN ra_customers.customer_name%TYPE    Required
-- p_check_id_flag       IN VARCHAR2    Required
-- x_return_status       OUT VARCHAR2   Required
-- x_error_msg_code      OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--           02-JUN-2005 --   dthakker 4363092 : TCA changes, replaced RA views with HZ tables
--
--
PROCEDURE CHECK_CUSTOMER_NAME_OR_ID
    (p_customer_id         IN hz_cust_accounts.cust_account_id%TYPE -- ra_customers.customer_id%TYPE -- for 4363092 TCA changes
    ,p_customer_name       IN hz_parties.party_name%TYPE -- ra_customers.customer_name%TYPE -- for 4363092 TCA changes
    ,p_check_id_flag       IN VARCHAR2
    ,x_customer_id         OUT NOCOPY hz_cust_accounts.cust_account_id%TYPE -- ra_customers.customer_id%TYPE -- for 4363092 TCA changes --File.Sql.39 bug 4440895
    ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code      OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

-- API name             : check_probability_code_or_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_probability_member_id  IN pa_probability_members.probability_member_id%TYPE   Required
-- p_probability_percentage IN pa_probability_members.probability_percentage%TYPE  Required
-- p_project_type           IN pa_projects_all.project_type%TYPE
-- p_probability_list_id    IN pa_probability_lists.probability_list_id%TYPE
-- p_check_id_flag      IN VARCHAR2    Required
-- x_probability_member_id  OUT pa_probability_members.probability_member_id%TYPE  Required
-- x_return_status      OUT VARCHAR2   Required
-- x_error_msg_code     OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--           18-MAR-2002 --   xxlu  Added IN parameter p_probability_list_id.
--
PROCEDURE CHECK_PROBABILITY_CODE_OR_ID
 (p_probability_member_id   IN pa_probability_members.probability_member_id%TYPE
,p_probability_percentage IN pa_probability_members.probability_percentage%TYPE
, p_project_type         IN pa_projects_all.project_type%TYPE
, p_probability_list_id  IN pa_probability_lists.probability_list_id%TYPE := NULL
  ,p_check_id_flag       IN VARCHAR2
  ,x_probability_member_id OUT NOCOPY pa_probability_members.probability_member_id%TYPE --File.Sql.39 bug 4440895
  ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code      OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

-- API name             : check_calendar_name__or_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_calendar_id        IN jtf_calendars_tl.calendar_id%TYPE    Required
-- p_calendar_name      IN jtf_calendars_tl.calendar_name%TYPE  Required
-- p_check_id_flag      IN VARCHAR2    Required
-- x_calendar_id        OUT jtf_calendars_tl.calendar_id%TYPE   Required
-- x_return_status      OUT VARCHAR2   Required
-- x_error_msg_code     OUT VARCHAR2   Required
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CHECK_CALENDAR_NAME_OR_ID
 (p_calendar_id     IN jtf_calendars_vl.calendar_id%TYPE
  ,p_calendar_name  IN jtf_calendars_vl.calendar_name%TYPE
  ,p_check_id_flag  IN VARCHAR2
  ,x_calendar_id    OUT NOCOPY jtf_calendars_vl.calendar_id%TYPE --File.Sql.39 bug 4440895
  ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code      OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

-- API name             : get_project_manager
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id         IN NUMBER
-- Return               : NUMBER
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
FUNCTION GET_PROJECT_MANAGER  ( p_project_id  IN NUMBER)
RETURN NUMBER;

-- API name             : get_project_manager_name
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id         IN NUMBER
-- Return               : VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
FUNCTION GET_PROJECT_MANAGER_NAME ( p_person_id  IN NUMBER)
RETURN VARCHAR2;

-- API name             : get_primary_customer
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_person_id         IN NUMBER
-- Return               : NUMBER
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
FUNCTION GET_PRIMARY_CUSTOMER  ( p_project_id  IN NUMBER)
RETURN NUMBER;

-- API name             : get_primary_customer_name
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id         IN NUMBER
-- Return               : VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
FUNCTION GET_PRIMARY_CUSTOMER_NAME ( p_project_id  IN NUMBER)
RETURN VARCHAR2;

-- API name             : class_check_trans
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id         IN NUMBER
-- Return               : VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
FUNCTION CLASS_CHECK_TRANS ( p_project_id  IN NUMBER)
RETURN VARCHAR2;

-- API name             : check_class_catg_can_delete
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_object_id          IN NUMBER
-- p_object_type        IN VARCHAR2
-- p_class_category     IN VARCHAR2
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CHECK_CLASS_CATG_CAN_DELETE (p_object_id     NUMBER,
                                       p_object_type   VARCHAR2,
                                       p_class_category VARCHAR2,
                                       x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_error_msg_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


-- API name             : check_duplicate_class_catg
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_object_id          IN NUMBER
-- p_object_type        IN VARCHAR2
-- p_class_category     IN VARCHAR2
-- p_class_code         IN VARCHAR2
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CHECK_DUPLICATE_CLASS_CATG  (p_object_id     NUMBER,
                                       p_object_type   VARCHAR2,
                                       p_class_category VARCHAR2,
                                       p_class_code     VARCHAR2,
                                       x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_error_msg_code      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


-- API name             : check_class_catg_one_only_code
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_object_id          IN NUMBER
-- p_object_type        IN VARCHAR2
-- p_class_category     IN VARCHAR2
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE   CHECK_CLASS_CATG_ONE_ONLY_CODE (
                                       p_object_id     NUMBER,
                                       p_object_type   VARCHAR2,
                                       p_class_category VARCHAR2,
                                       x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_error_msg_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- API name             : check_class_catg_can_override
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id         IN NUMBER
-- p_class_category     IN VARCHAR2
-- p_class_code         IN VARCHAR2
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CHECK_CLASS_CATG_CAN_OVERRIDE (
                                       p_project_id     NUMBER,
                                       p_class_category VARCHAR2,
                                       p_class_code     VARCHAR2,
                                       x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_error_msg_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- API name             : check_probability_can_change
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_status_code IN VARCHAR2
-- x_return_status       OUT VARCHAR2
-- x_error_msg_code      OUT VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CHECK_PROBABILITY_CAN_CHANGE (
                                       p_project_status_code VARCHAR2,
                                       x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_error_msg_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- API name             : check_bill_job_grp_req
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_type       IN VARCHAR2
-- p_bill_job_group     IN NUMBER
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
PROCEDURE CHECK_BILL_JOB_GRP_REQ     (p_project_type IN VARCHAR2,
                                     p_bill_job_group_id IN NUMBER,
                                     x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                     x_error_msg_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- API name             : get_cost_job_group_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           : None.
-- Return               : NUMBER
--
--  History
--
--           18-AUG-2000 --   Sakthi/William    - Created.
--
--
FUNCTION GET_COST_JOB_GROUP_ID RETURN NUMBER;

-- API name             : check_bill_rate_rate_schl_exists
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id          IN  NUMBER
--
--  History
--
--           08-SEP-2000 --   Sakthi/William    - Created.
--
FUNCTION CHECK_BILL_RATE_SCHL_EXISTS (p_project_id IN NUMBER)
RETURN VARCHAR2;

-- API name             : check_project_option_exists
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id         IN NUMBER
-- p_option_code        IN VARCHAR2
-- Return               : VARCHAR2
--
--  History
--
--           01-JUN-2001 --   Sakthi    - Created.
--
--
FUNCTION CHECK_PROJECT_OPTION_EXISTS  ( p_project_id  IN NUMBER, p_option_code IN VARCHAR2)
RETURN VARCHAR2;


-- API name             : check_category_total_valid
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_object_id          IN NUMBER
-- p_object_type        IN VARCHAR2
-- p_class_category     IN VARCHAR2
-- p_rowid              IN VARCHAR2 Optional Default = FND_API.G_MISS_CHAR
-- p_code_percentage    IN NUMBER
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           11-OCT-2001 --   anlee    created
--
--
PROCEDURE CHECK_CATEGORY_TOTAL_VALID  (p_object_id         NUMBER,
                                       p_object_type       VARCHAR2,
                                       p_class_category    VARCHAR2,
                                       p_rowid             VARCHAR2 := FND_API.G_MISS_CHAR,
                                       p_code_percentage   NUMBER,
                                       x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_error_msg_code    OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


-- API name             : check_category_valid
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_object_type_id     IN NUMBER
-- p_class_category     IN VARCHAR2
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           11-OCT-2001 --   anlee    created
--
--
PROCEDURE CHECK_CATEGORY_VALID        (p_object_type_id    NUMBER,
                                       p_class_category    VARCHAR2,
                                       x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_error_msg_code    OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


-- API name             : check_percentage_allowed
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_class_category     IN VARCHAR2
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           11-OCT-2001 --   anlee    created
--
--
PROCEDURE CHECK_PERCENTAGE_ALLOWED    (p_class_category VARCHAR2,
                                       x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_error_msg_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


-- API name             : check_mandatory_classes
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_class_category     IN VARCHAR2
-- x_return_status      OUT VARCHAR2
-- x_error_msg_code     OUT VARCHAR2
--
--  History
--
--           11-OCT-2001 --   anlee    created
--
--
PROCEDURE CHECK_MANDATORY_CLASSES            (p_object_id VARCHAR2,
                                              p_object_type VARCHAR2,
                                              x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                              x_error_msg_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


-- API name             : check_agreement_currency_name_or_code
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_agreement_currency            IN FND_CURRENCIES_VL.currency_code%TYPE      Required
-- p_agreement_currency_name       IN FND_CURRENCIES_VL.name%TYPE    Required
-- p_check_id_flag                 IN VARCHAR2    Required
-- x_agreement_currency            OUT VARCHAR2   Required
-- x_return_status                 OUT VARCHAR2   Required
-- x_error_msg_code                OUT VARCHAR2   Required
--
--
--  History
--
--           12-OCT-2001 --   anlee    created
--
--
procedure Check_currency_name_or_code
   ( p_agreement_currency      IN FND_CURRENCIES_VL.currency_code%TYPE
    ,p_agreement_currency_name IN FND_CURRENCIES_VL.name%TYPE
    ,p_check_id_flag           IN VARCHAR2
    ,x_agreement_currency      OUT NOCOPY FND_CURRENCIES_VL.currency_code%TYPE --File.Sql.39 bug 4440895
    ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code          OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


-- API name             : check_agreement_org_name_or_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_agreement_org_id            IN pa_organizations_project_v.organization_id%TYPE      Required
-- p_agreement_org_name          IN pa_organizations_project_v.name%TYPE    Required
-- p_check_id_flag               IN VARCHAR2      Required
-- x_agreement_org_id             OUT NUMBER      Required
-- x_return_status                 OUT VARCHAR2   Required
-- x_error_msg_code                OUT VARCHAR2   Required
--
--
--  History
--
--           12-OCT-2001 --   anlee    created
--
--
procedure Check_agreement_org_name_or_id
   ( p_agreement_org_id        IN pa_organizations_project_v.organization_id%TYPE
    ,p_agreement_org_name      IN pa_organizations_project_v.name%TYPE
    ,p_check_id_flag           IN VARCHAR2
    ,x_agreement_org_id        OUT NOCOPY pa_organizations_project_v.organization_id%TYPE --File.Sql.39 bug 4440895
    ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code          OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


-- API name             : get_class_codes
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_object_id         IN NUMBER
-- p_object_type       IN VARCHAR2
-- p_class_category    IN VARCHAR2
-- Return               : VARCHAR2
--
--  History
--
--           18-OCT-2001 --   anlee    - Created
--
--
FUNCTION GET_CLASS_CODES(p_object_id  IN NUMBER, p_object_type IN VARCHAR2, p_class_category IN VARCHAR2)
RETURN VARCHAR2;


-- API name             : get_class_exceptions
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_object_id          IN NUMBER
-- p_object_type        IN VARCHAR2
-- p_class_category     IN VARCHAR2
-- p_mandatory          IN VARCHAR2
-- Return               : VARCHAR2
--
--  History
--
--           18-OCT-2001 --   anlee    - Created
--
--
FUNCTION GET_CLASS_EXCEPTIONS(p_object_id IN NUMBER, p_object_type IN VARCHAR2, p_class_category IN VARCHAR2, p_mandatory IN VARCHAR2)
RETURN VARCHAR2;


-- API name             : get_object_type_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_object_id          IN NUMBER
-- p_object_type        IN VARCHAR2
-- Return               : NUMBER
--
--  History
--
--           18-OCT-2001 --   anlee    - Created
--
--
FUNCTION GET_OBJECT_TYPE_ID(p_object_id IN NUMBER, p_object_type IN VARCHAR2)
RETURN NUMBER;

-- API name             : populate_class_exception
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project            : IN NUMBER
-- Return               : NUMBER
--
--  History
--
--           16-NOV-2001 --   Sakthi/Ansari    - Created
--
--

procedure POPULATE_CLASS_EXCEPTION (p_project_id NUMBER);


-- API name             : check_proj_recalc
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id          IN NUMBER
-- p_organization_id     IN NUMBER
-- p_organization_name   IN VARCHAR2
-- Return               : VARCHAR2
--
--  History
--
--           22-MAY-2002 --   anlee    - Created
--
--
FUNCTION CHECK_PROJ_RECALC (p_project_id IN NUMBER,
                            p_organization_id IN NUMBER,
                            p_organization_name IN VARCHAR2)
RETURN VARCHAR2;


-- API name             : validate_pipeline_info
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id          IN NUMBER
-- Return               : VARCHAR2
--
--  History
--
--           26-JUN-2002 --   anlee    - Created
--
--
FUNCTION VALIDATE_PIPELINE_INFO (p_project_id IN NUMBER)
RETURN VARCHAR2;


-- API name             : check_classcategory_name_or_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Description          : It validates and returns the class category id
--                        from the class category name.
--  History
--
--       20-Nov-2002   -- adabdull     - Created

PROCEDURE Check_ClassCategory_Name_Or_Id(
        p_class_category_id      IN pa_class_categories.class_category_id%TYPE
       ,p_class_category_name    IN pa_class_categories.class_category%TYPE
       ,p_check_id_flag          IN VARCHAR2  DEFAULT 'A'
       ,x_class_category_id     OUT NOCOPY pa_class_categories.class_category_id%TYPE --File.Sql.39 bug 4440895
       ,x_return_status         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_error_message_code    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name             : check_classcode_name_or_id
-- Type                 : Public
-- Pre-reqs             : None.
-- Description          : It validates and returns the class code id
--                        from the class code and class category combination
--  History
--
--       20-Nov-2002   -- adabdull     - Created

PROCEDURE Check_ClassCode_Name_Or_Id(
        p_classcode_id           IN pa_class_codes.class_code_id%TYPE
       ,p_classcode_name         IN pa_class_codes.class_code%TYPE
       ,p_classcategory          IN pa_class_codes.class_category%TYPE
       ,p_check_id_flag          IN VARCHAR2 DEFAULT 'A'
       ,x_classcode_id          OUT NOCOPY pa_class_codes.class_code_id%TYPE --File.Sql.39 bug 4440895
       ,x_return_status         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_error_message_code    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name             : class_check_mandatory
-- Type                 : Public
-- Pre-reqs             : None.
-- Description          : Checks whether the class category is mandatory and returns 'Y' or 'N'
--  History
--
--       19-Jan-2003   -- vshastry     - Created
--

FUNCTION CLASS_CHECK_MANDATORY (p_class_category VARCHAR2, p_project_id NUMBER)
RETURN VARCHAR2;

END PA_PROJECTS_MAINT_UTILS;
 

/
