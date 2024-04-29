--------------------------------------------------------
--  DDL for Package AP_WEB_PROJECT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_PROJECT_PKG" AUTHID CURRENT_USER AS
/* $Header: apwprojs.pls 120.4 2006/02/24 10:20:19 sbalaji ship $ */

PROCEDURE IsSessionProjectEnabled(
                          P_EmployeeID IN    FND_USER.employee_id%TYPE,
                          P_FNDUserID  IN    FND_USER.user_id%TYPE,
                          P_Result     OUT NOCOPY   VARCHAR2);

PROCEDURE DerivePAInfoFromDatabase(
  P_IsProjectEnabled   IN 	VARCHAR2,
  P_PAProjectNumber    IN OUT NOCOPY 	PA_PROJECTS_EXPEND_V.project_number%TYPE,
  P_PAProjectID        IN OUT NOCOPY 	PA_PROJECTS_EXPEND_V.project_id%TYPE,
  P_PATaskNumber       IN OUT NOCOPY 	PA_TASKS_EXPEND_V.task_number%TYPE,
  P_PATaskID           IN OUT NOCOPY 	PA_TASKS_EXPEND_V.task_id%TYPE,
  P_PAExpenditureType  IN OUT NOCOPY 	AP_EXPENSE_REPORT_PARAMS.pa_expenditure_type%TYPE );


PROCEDURE DerivePAInfoFromUserInput(
  P_IsProjectEnabled   IN     VARCHAR2,
  P_PAProjectNumber    IN OUT NOCOPY PA_PROJECTS_EXPEND_V.project_number%TYPE,
  P_PAProjectID        OUT NOCOPY    PA_PROJECTS_EXPEND_V.project_id%TYPE,
  P_PAProjectName      OUT NOCOPY    PA_PROJECTS_EXPEND_V.project_name%TYPE,
  P_PATaskNumber       IN OUT NOCOPY PA_TASKS_EXPEND_V.task_number%TYPE,
  P_PATaskID           OUT NOCOPY    PA_TASKS_EXPEND_V.task_id%TYPE,
  P_PATaskName	       OUT NOCOPY    PA_TASKS_EXPEND_V.task_name%TYPE,
  P_PAExpenditureType  OUT NOCOPY    AP_EXPENSE_REPORT_PARAMS.pa_expenditure_type%TYPE,
  P_ExpenseType        IN     AP_EXPENSE_REPORT_PARAMS.parameter_id%TYPE
);

PROCEDURE ValidatePATransaction(
            P_project_id             IN NUMBER,
            P_task_id                IN NUMBER,
            P_ei_date                IN DATE,
            P_expenditure_type       IN VARCHAR2,
            P_non_labor_resource     IN VARCHAR2,
            P_person_id              IN NUMBER,
            P_quantity               IN NUMBER DEFAULT NULL,
            P_denom_currency_code    IN VARCHAR2 DEFAULT NULL,
            P_acct_currency_code     IN VARCHAR2 DEFAULT NULL,
            P_denom_raw_cost         IN NUMBER DEFAULT NULL,
            P_acct_raw_cost          IN NUMBER DEFAULT NULL,
            P_acct_rate_type         IN VARCHAR2 DEFAULT NULL,
            P_acct_rate_date         IN DATE DEFAULT NULL,
            P_acct_exchange_rate     IN NUMBER DEFAULT NULL ,
            P_transfer_ei            IN NUMBER DEFAULT NULL,
            P_incurred_by_org_id     IN NUMBER DEFAULT NULL,
            P_nl_resource_org_id     IN NUMBER DEFAULT NULL,
            P_transaction_source     IN VARCHAR2 DEFAULT NULL ,
            P_calling_module         IN VARCHAR2 DEFAULT NULL,
            P_vendor_id              IN NUMBER DEFAULT NULL,
            P_entered_by_user_id     IN NUMBER DEFAULT NULL,
            P_attribute_category     IN VARCHAR2 DEFAULT NULL,
            P_attribute1             IN VARCHAR2 DEFAULT NULL,
            P_attribute2             IN VARCHAR2 DEFAULT NULL,
            P_attribute3             IN VARCHAR2 DEFAULT NULL,
            P_attribute4             IN VARCHAR2 DEFAULT NULL,
            P_attribute5             IN VARCHAR2 DEFAULT NULL,
            P_attribute6             IN VARCHAR2 DEFAULT NULL,
            P_attribute7             IN VARCHAR2 DEFAULT NULL,
            P_attribute8             IN VARCHAR2 DEFAULT NULL,
            P_attribute9             IN VARCHAR2 DEFAULT NULL,
            P_attribute10            IN VARCHAR2 DEFAULT NULL,
            P_attribute11            IN VARCHAR2 DEFAULT NULL,
            P_attribute12            IN VARCHAR2 DEFAULT NULL,
            P_attribute13            IN VARCHAR2 DEFAULT NULL,
            P_attribute14            IN VARCHAR2 DEFAULT NULL,
            P_attribute15            IN VARCHAR2 DEFAULT NULL,
            P_msg_type               OUT NOCOPY VARCHAR2,
            P_msg_data               OUT NOCOPY VARCHAR2,
            P_billable_flag          OUT NOCOPY VARCHAR2);

PROCEDURE GetExpenditureTypeMapping(
  P_ExpenseType       IN        AP_EXPENSE_REPORT_PARAMS.parameter_id%TYPE,
  P_PAExpenditureType OUT NOCOPY       AP_EXPENSE_REPORT_PARAMS.pa_expenditure_type%TYPE);

----------------------------------------------------------------------
FUNCTION IsGrantsEnabled RETURN VARCHAR2;

END AP_WEB_PROJECT_PKG;

 

/
