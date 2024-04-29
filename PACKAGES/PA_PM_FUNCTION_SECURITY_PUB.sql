--------------------------------------------------------
--  DDL for Package PA_PM_FUNCTION_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PM_FUNCTION_SECURITY_PUB" AUTHID DEFINER AS
/*$Header: PAPMFSPS.pls 120.2 2005/08/19 16:42:43 mwasowic ship $*/

G_PKG_NAME              VARCHAR2(80)    := 'PA_PM_FUNCTION_SECURITY_PUB';
-- Global variables to be used to avoid repeated calls to
-- PA_PM_FUNCTION_SECURITY_PUB.check_function_security,
-- thus improving the performance.

    G_Create_Project          VARCHAR2(1)     := NULL;
    G_Update_Project          VARCHAR2(1)     := NULL;
    G_Delete_Project          VARCHAR2(1)     := NULL;

    G_Update_Proj_Progress    VARCHAR2(1)     := NULL;

    G_Add_Task                VARCHAR2(1)     := NULL;
    G_Update_Task             VARCHAR2(1)     := NULL;
    G_Modify_Top_Task         VARCHAR2(1)     := NULL;
    G_Delete_Task             VARCHAR2(1)     := NULL;

    G_Create_Draft_Budget     VARCHAR2(1)     := NULL;
    G_Update_Budget           VARCHAR2(1)     := NULL;
    G_Baseline_Budget         VARCHAR2(1)     := NULL;
    G_Delete_Draft_Budget     VARCHAR2(1)     := NULL;

    G_Add_Budget_Line         VARCHAR2(1)     := NULL;
    G_Update_Budget_Line      VARCHAR2(1)     := NULL;
    G_Delete_Budget_Line      VARCHAR2(1)     := NULL;

    G_Update_Earned_Value     VARCHAR2(1)     := NULL;

    G_Create_Res_List         VARCHAR2(1)     := NULL;
    G_Update_Res_List         VARCHAR2(1)     := NULL;
    G_Delete_Res_List         VARCHAR2(1)     := NULL;

    G_Add_Res_List_Member     VARCHAR2(1)     := NULL;
    G_Update_Res_List_Member  VARCHAR2(1)     := NULL;
    G_Delete_Res_List_Member  VARCHAR2(1)     := NULL;

    G_Create_Agreement        VARCHAR2(1)     := NULL;
    G_Delete_Agreement        VARCHAR2(1)     := NULL;
    G_Update_Agreement        VARCHAR2(1)     := NULL;
    G_Add_Funding             VARCHAR2(1)     := NULL;
    G_Delete_Funding          VARCHAR2(1)     := NULL;
    G_Update_Funding          VARCHAR2(1)     := NULL;
    G_Init_Agreement          VARCHAR2(1)     := NULL;
    G_Load_Agreement          VARCHAR2(1)     := NULL;
    G_Load_Funding            VARCHAR2(1)     := NULL;
    G_Exe_Cre_Agmt            VARCHAR2(1)     := NULL;
    G_Exe_Upd_Agmt            VARCHAR2(1)     := NULL;
    G_Fetch_Funding           VARCHAR2(1)     := NULL;
    G_Clear_Agreement         VARCHAR2(1)     := NULL;
    G_Check_Del_Agmt_Ok       VARCHAR2(1)     := NULL;
    G_Check_Add_Fund_Ok       VARCHAR2(1)     := NULL;
    G_Check_Del_Fund_Ok       VARCHAR2(1)     := NULL;
    G_Check_Upd_Fund_Ok       VARCHAR2(1)     := NULL;

    G_found_or_not            VARCHAR2(1)     := 'N';

    /* Start of code for bug #4317792 */
    G_FP_Maintain_AC_Plan		VARCHAR2(1)     := NULL;
    G_FP_Maintain_C_Plan		VARCHAR2(1)     := NULL;
    G_FP_Maintain_FC_Plan		VARCHAR2(1)     := NULL;
    G_FP_Maintain_AR_Plan		VARCHAR2(1)     := NULL;
    G_FP_Maintain_R_Plan		VARCHAR2(1)     := NULL;
    G_FP_Maintain_FR_Plan		VARCHAR2(1)     := NULL;
    G_FP_Baseline_AC_Plan		VARCHAR2(1)     := NULL;
    G_FP_Baseline_C_Plan		VARCHAR2(1)     := NULL;
    G_FP_Baseline_FC_Plan		VARCHAR2(1)     := NULL;
    G_FP_Baseline_AR_Plan		VARCHAR2(1)     := NULL;
    G_FP_Baseline_R_Plan		VARCHAR2(1)     := NULL;
    G_FP_Baseline_FR_Plan		VARCHAR2(1)     := NULL;
    G_FP_Maintain_AC_AR_Plan_Lines	VARCHAR2(1)     := NULL;
    G_FP_Maintain_Plan_Lines		VARCHAR2(1)     := NULL;
    G_FP_Maintain_FC_FR_Plan_Lines	VARCHAR2(1)     := NULL;
    /* End of code for bug #4317792 */

    Procedure check_function_security
     (p_api_version_number  IN NUMBER,
      p_responsibility_id  IN NUMBER,
      p_function_name      IN VARCHAR2,
      p_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
      p_msg_data           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      p_return_status     OUT NOCOPY VARCHAR2 ,      --File.Sql.39 bug 4440895
      p_function_allowed  OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

  -- Included Procedure Check_Global_Vars, to check for global variables and
  -- see if check_function_security function has already been called once.
  -- This way, we are avoiding multiple calls to this function
  -- check_function_security         S Sanckar 09-Jul-99

    Procedure Check_Global_Vars
     (p_function_name     IN VARCHAR2,
      p_function_allowed  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      p_found_or_not      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  -- Included call to Set_Global_Vars, to set the global variables
  -- which are used in checking if check_function_security function has
  -- already been called. This way, we are avoiding multiple calls to
  -- this function check_function_security         S Sanckar 09-Jul-99

    Procedure Set_Global_Vars
     (p_function_name    IN VARCHAR2,
      p_function_allowed IN VARCHAR2);

--This method is called to check whether the user has
--privileges to call various  public apis in pa_budget_pub

PROCEDURE CHECK_BUDGET_SECURITY (
p_api_version_number IN  NUMBER,
p_project_id         IN  PA_PROJECTS_ALL.PROJECT_ID%TYPE,
p_fin_plan_type_id   IN  PA_FIN_PLAN_TYPES_B.FIN_PLAN_TYPE_ID%TYPE DEFAULT NULL, /* Bug 3139924 */
p_calling_context    IN  VARCHAR2,
p_function_name      IN  VARCHAR2,
p_version_type       IN  VARCHAR2,
x_return_status      OUT NOCOPY VARCHAR2,
x_ret_code           OUT NOCOPY VARCHAR2 );
END PA_PM_FUNCTION_SECURITY_PUB;

 

/
