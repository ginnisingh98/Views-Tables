--------------------------------------------------------
--  DDL for Package PA_FCST_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FCST_GLOBAL" AUTHID CURRENT_USER as
/* $Header: PARFSGLS.pls 120.1 2005/08/19 16:52:37 mwasowic noship $ */

    Global_Page_First_Flag            VARCHAR2(30) :='Y';
    Global_Project_Number             VARCHAR2(30) :='ALL';
    Global_Project_Name               VARCHAR2(30) :='XXXXXXXXXXXXXXX';
    Global_project_type               VARCHAR2(30) := 'ALL';
    Global_Orgnization_Id             NUMBER := -99;
    Global_Orgnization_Name           VARCHAR2(30) := 'ALL';
    Global_project_status             VARCHAR2(30) := 'ALL';
    Global_Project_Start_Date	      DATE :=to_date('01-01-1900','DD-MM-YYYY');
    Global_Project_Start_Date_Opt     VARCHAR2(30) := 'is';
    Global_Project_Comp_Date          DATE :=to_date('01-01-1900','DD-MM-YYYY');
    Global_Project_Comp_Date_Opt      VARCHAR2(30) := 'is';
    Global_Project_Manager_Id         NUMBER := NULL;
    GLobal_Project_Manager_Name       VARCHAR2(30) :='XXXXXXXXXXXXXXX';
    GLobal_Project_Customer_Name      VARCHAR2(30) :='XXXXXXXXXXXXXXX';
    Global_proj_fcst_show_amt 	      VARCHAR2(20) :='REVENUE';
    Global_view_type                  VARCHAR2(30) := 'PERIODIC';
    Global_ProbabilityPerFlag	      VARCHAR2(1):='N';
    Global_proj_fcst_start_date       DATE :=to_date('01-04-1950','DD-MM-YYYY');
    Global_proj_fcst_end_date         DATE := SYSDATE;
    Global_ProbabilityPer 	      NUMBER := 1;
    Global_PeriodName                 VARCHAR2(30) := NULL;
    Global_period_type                VARCHAR2(30):=  fnd_profile.value('PA_FORECASTING_PERIOD_TYPE');
    Global_ProjectId                  NUMBER;
    Global_pl_start_date              DATE := to_date('01-04-1999','DD-MM-YYYY');
    Global_pl_end_date                DATE := SYSDATE;
    Global_Period_Set_Name            VARCHAR2(15) := NULL;
    Global_project_type_class         VARCHAR2(30) := 'CONTRACT';
    Global_Class_category             VARCHAR(30):=null;
    Global_key_member_id              NUMBER;

PROCEDURE GetDefaultValue(x_start_period    OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_Show_amount     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_project_type    OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_project_status  OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_view_type       OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_apply_prob_flag OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_class_display   OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_prj_owner_display OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_return_status   OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count       OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         );


PROCEDURE pa_fcst_proj_get_default(p_project_id          IN   NUMBER,
                                   x_show_amount_type    OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_start_period_name   OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_apply_prob_per_flag OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                   x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   );



PROCEDURE Set_CrossProject_GlobalValue(p_start_period    IN  VARCHAR2,
                                       p_Show_amount     IN  VARCHAR2,
                                       p_apply_prob_flag IN  VARCHAR2,
                                       p_page_first_flag IN  VARCHAR2,
				       p_project_number  IN  VARCHAR2,
                                       p_project_name    IN  VARCHAR2,
                                       p_project_type    IN  VARCHAR2,
                                       p_organization_name     IN  VARCHAR2,
                                       p_project_status        IN  VARCHAR2,
                                       p_project_manager_name  IN  VARCHAR2,
                                       p_project_customer_name IN  VARCHAR2,
                                       x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                       x_msg_data        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                      );



PROCEDURE Set_Project_GlobalValue(p_project_id      IN  NUMBER,
                                  p_start_period    IN  VARCHAR2,
                                  p_Show_amount     IN  VARCHAR2,
                                  p_apply_prob_flag IN  VARCHAR2,
                                  p_apply_prob_per  IN  NUMBER,
                                  x_project_type_class OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_project_TM_flag OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                  );

PROCEDURE Set_Global_Project_Id(p_project_id IN NUMBER,
                                x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                );
PROCEDURE Get_Project_Info(p_project_id      IN  NUMBER,
                           x_project_name    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_project_number  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_FI_Date         OUT NOCOPY Date, --File.Sql.39 bug 4440895
                           x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           x_msg_data        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                );



PROCEDURE SetPeriodSetName;



FUNCTION GetProjFcstShowAmount  RETURN VARCHAR2;
FUNCTION GetProjectId           RETURN NUMBER;
FUNCTION GetProjFcstStartDate 	RETURN DATE;
FUNCTION GetProjFcstEndDate 	RETURN DATE;
FUNCTION GetProbabilityPerFlag 	RETURN VARCHAR2;
FUNCTION GetProbabilityPer 	RETURN NUMBER;
FUNCTION GetPeriodType          RETURN VARCHAR2;
FUNCTION GetPageFirstFlag       RETURN VARCHAR2;
FUNCTION GetProjectNumber       RETURN VARCHAR2;
FUNCTION GetProjectName         RETURN VARCHAR2;
FUNCTION GetProjType            RETURN VARCHAR2;
FUNCTION GetProjectOrgId        RETURN NUMBER;
FUNCTION GetProjectOrgName      RETURN VARCHAR2;
FUNCTION GetProjStatusCode      RETURN VARCHAR2;
FUNCTION GetProjectStartDate    RETURN DATE;
FUNCTION GetProjectStartDateOpt RETURN VARCHAR2;
FUNCTION GetProjectCompDate     RETURN DATE;
FUNCTION GetProjectCompDateOpt  RETURN VARCHAR2;
FUNCTION GetProjectMangerName   RETURN VARCHAR2;
FUNCTION GetProjectMangerId     RETURN NUMBER;
FUNCTION GetProjectCustomerName RETURN VARCHAR2;
FUNCTION GetClassCatgory        RETURN VARCHAR2;
FUNCTION GetKeyMemberId         RETURN VARCHAR2;

FUNCTION GetPlStartDate         RETURN DATE;
FUNCTION GetPlEndDate           RETURN DATE;
FUNCTION GetPeriodSetName       RETURN VARCHAR2;
FUNCTION GetProjectTypeClass    RETURN VARCHAR2;

FUNCTION find_project_owner(
                            p_project_id   IN NUMBER,
                            p_proj_start_date   IN  DATE,
                            p_proj_end_date     IN  DATE
                           )
RETURN VARCHAR2;
FUNCTION find_project_fixed_price(p_project_id IN NUMBER)
RETURN VARCHAR2;

/* Newly added for performance Issue  */

   Global_CrossProjectViewUser       VARCHAR2(1):='N';

   Function  SetCrossProjectViewUser RETURN VARCHAR2;
   Function  IsCrossProjectViewUser  RETURN VARCHAR2;
   Procedure Populate_Fcst_Periods;

END pa_fcst_global;

 

/
