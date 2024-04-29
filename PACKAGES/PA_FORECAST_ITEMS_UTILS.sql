--------------------------------------------------------
--  DDL for Package PA_FORECAST_ITEMS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FORECAST_ITEMS_UTILS" AUTHID CURRENT_USER AS
/* $Header: PARFIUTS.pls 120.2 2005/10/27 06:14:34 nkumbi noship $ */

FUNCTION  Get_Next_ForeCast_Item_ID  RETURN NUMBER;


--
-- Function             : Get_Next_ForeCast_Item_ID
-- Purpose              : This function gets the unique identifier for the forecast item.
-- Parameters           :
--



FUNCTION Set_User_Lock ( p_source_id         IN  NUMBER,
                         p_lock_for          IN VARCHAR2) RETURN NUMBER;

--
-- Function             : Set_User_Lock
-- Purpose              : This function will set and acquire the user lock.
-- Parameters           :
--

FUNCTION Release_User_Lock (p_source_id   IN  NUMBER,
                            p_lock_for  IN VARCHAR2) RETURN NUMBER;

--
-- Function             : Release_User_Lock
-- Purpose              : This procedure will release user lock.
-- Parameters           :
--

PROCEDURE allocate_unique(p_lock_name  IN VARCHAR2,
                          p_lock_handle OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE log_message (p_log_msg IN VARCHAR2) ;

--
-- Procedure            : log_message
-- Purpose              : This procedure prints the text which is being passed as the input.
-- Parameters           :
--


PROCEDURE Get_Resource_Asgn_Schedules (
                                        p_resource_id           IN      NUMBER,
                                        p_start_date            IN      DATE,
                                        p_end_date              IN      DATE,
                                        x_ScheduleTab           OUT     NOCOPY PA_FORECAST_GLOB.ScheduleTabTyp, /* 2674619 - Nocopy change */
                                        x_return_status         OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count             OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_msg_data              OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895



--
-- Procedure            : Get_Resource_Asgn_Schedules
-- Purpose              : This procedure gets the schedule related to the resource assignment.
-- Parameters           :
--


PROCEDURE Get_Assignment_Schedule(p_assignment_id       IN      NUMBER,
                                  p_start_date          IN      DATE ,
                                  p_end_date            IN      DATE,
                                  p_process_mode        IN      VARCHAR2,
                                  X_ScheduleTab         OUT     NOCOPY PA_FORECAST_GLOB.ScheduleTabTyp,  /* 2674619 - Nocopy change */
                                  x_return_status       OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count           OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data            OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895



--
-- Procedure            : Get_Assignment_Schedule
-- Purpose              : This procedure will get all the schedule for the given assignment id.
-- Parameters           :
--



FUNCTION Get_Period_Set_Name(p_org_id NUMBER) RETURN VARCHAR2;

--
-- Function             : Get_Period_Set_Name
-- Purpose              : To get the Period name for OU.
-- Parameters           :
--


PROCEDURE Get_Work_Type_Details(p_work_type_id          IN       NUMBER,
                                x_BillableFlag          OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_ResUtilPercentage     OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_OrgUtilPercentage     OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_ResUtilCategoryID     OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_OrgUtilCategoryID     OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_ReduceCapacityFlag    OUT      NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--
--  Procedure           Get_Work_Type_Details
--  Purpose             To get detail for the passed work type
--  Parameters
--


PROCEDURE Get_PA_Period_Name(p_org_id           IN NUMBER,
                             p_start_date       IN DATE,
                             p_end_date         IN DATE,
                             x_StartDateTab     OUT NOCOPY PA_FORECAST_GLOB.DateTabTyp,   /* 2674619 - Nocopy change */
                             x_EndDateTab       OUT NOCOPY PA_FORECAST_GLOB.DateTabTyp,   /* 2674619 - Nocopy change */
                             x_PAPeriodNameTab  OUT NOCOPY PA_FORECAST_GLOB.PeriodNameTabTyp) ;  /* 2674619 - Nocopy change */


--
--  Procedure           Get_PA_Period_Name
--  Purpose             To get the PA Period name for OU
--  Parameters
--


PROCEDURE Get_GL_Period_Name(p_org_id           IN NUMBER,
                             p_start_date       IN DATE,
                             p_end_date         IN DATE,
                             x_StartDateTab     OUT NOCOPY PA_FORECAST_GLOB.DateTabTyp, /* 2674619 - Nocopy change */
                             x_EndDateTab       OUT NOCOPY PA_FORECAST_GLOB.DateTabTyp, /* 2674619 - Nocopy change */
                             x_PAPeriodNameTab  OUT NOCOPY PA_FORECAST_GLOB.PeriodNameTabTyp); /* 2674619 - Nocopy change */

--
--  Procedure           Get_GL_Period_Name
--  Purpose             To get the GL Period name for OU
--  Parameters
--


PROCEDURE Get_Resource_OU(p_resource_id      IN NUMBER,
                          p_start_date       IN DATE,
                          p_end_date         IN DATE,
                          x_StartDateTab     OUT NOCOPY PA_FORECAST_GLOB.DateTabTyp, /* 2674619 - Nocopy change */
                          x_EndDateTab       OUT NOCOPY PA_FORECAST_GLOB.DateTabTyp, /* 2674619 - Nocopy change */
                          x_ResourceOUTab    OUT NOcopy PA_FORECAST_GLOB.NumberTabTyp); /* 2674619 - Nocopy change */

--
--  Procedure           Get_Resource_OU
--  Purpose             To get the Resource OU for a Period
--  Parameters
--


PROCEDURE Get_Res_Org_And_Job(p_person_id                 IN NUMBER,
                                    p_start_date                IN DATE,
                                    p_end_date                  IN DATE,
                                    x_StartDateTab              OUT NOCOPY PA_FORECAST_GLOB.DateTabTyp, /* 2674619 - Nocopy change */
                                    x_EndDateTab                OUT NOCOPY PA_FORECAST_GLOB.DateTabTyp, /* 2674619 - Nocopy change */
                                    x_ResourceOrganizationIDTab OUT NOCOPY PA_FORECAST_GLOB.NumberTabTyp, /* 2674619 - Nocopy change */
                                    x_ResourceJobIDTab          OUT NOCOPY PA_FORECAST_GLOB.NumberTabTyp); /* 2674619 - Nocopy change */

--
--  Procedure           Get_Res_Org_And_Job
--  Purpose             To get the Resource Organization for Period
--  Input parameters
--


FUNCTION Get_Person_Id(p_resource_id NUMBER) RETURN NUMBER;

--
--  Function            Get_Person_Id
--  Purpose             To get the Person ID for resource Id
--  Parameters
--

FUNCTION Get_resource_Id(p_person_id NUMBER) RETURN NUMBER;

--
--  Function            Get_resource_Id
--  Purpose             To get the Person ID for resource Id
--  Parameters
--

FUNCTION Get_Resource_Type(p_resource_id NUMBER) RETURN VARCHAR2;

--
--  Function            Get_Resource_Type
--  Purpose             To get the Resource Type for resource Id
--  Parameters
--


PROCEDURE Get_ForecastOptions(  p_org_id                        IN       NUMBER,
                               -- x_include_admin_proj_flag       OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895, Bug 4576715
                                x_util_cal_method               OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_bill_unassign_proj_id         OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_bill_unassign_exp_type_class  OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_bill_unassign_exp_type        OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_nonbill_unassign_proj_id      OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_nonbill_unassign_exp_typ_cls  OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_nonbill_unassign_exp_type     OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_default_tp_amount_type        OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                  x_msg_data       OUT NOCOPY VARCHAR2  ); --File.Sql.39 bug 4440895

--
--  Procedure           Get_ForecastOptions
--  Purpose             To get the all forecast options from pa_forecasting_options_all table
--  Parameters
--


PROCEDURE Get_Week_Dates_Range_Fc( p_start_date            IN DATE,
                                   p_end_date              IN DATE,
                                   x_week_date_range_tab   OUT NOCOPY PA_FORECAST_GLOB.WeekDatesRangeFcTabTyp , /* 2674619 - Nocopy change */
                                   x_return_status         OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_msg_count             OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                   x_msg_data              OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


--
--  Procedure           Get_Week_Dates_Range_Fc
--  Purpose             To get the global week end date
--  Parameters
--
PROCEDURE    Check_TPAmountType(
                     p_tp_amount_type_code    IN VARCHAR2,
                     p_tp_amount_type_desc    IN VARCHAR2,
                     p_check_id_flag          IN VARCHAR2,
                     x_tp_amount_type_code    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_tp_amount_type_desc    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                     x_msg_data               OUT NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895


PROCEDURE Get_Assignment_Default (p_assignment_type                     IN              VARCHAR2,
                                  p_project_id                          IN              NUMBER,
                                  p_project_role_id                     IN              NUMBER,
                                  p_work_type_id                        IN              NUMBER,
                                  x_work_type_id                        OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_default_tp_amount_type              OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_default_job_group_id                OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_default_job_id                      OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_org_id                              OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_carrying_out_organization_id        OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_default_assign_exp_type             OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_default_assign_exp_type_cls         OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_return_status                       OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count                           OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data                            OUT             NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                  );


--
--  Procedure           Get_Assignment_Default
--  Purpose             This procedure will get the defautl values for the Assignment
--  Parameters
--

PROCEDURE Get_Project_Default (   p_assignment_type                     IN              VARCHAR2,
                                  p_project_id                          IN              NUMBER,
                                  x_work_type_id                        OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_default_tp_amount_type              OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_org_id                              OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_carrying_out_organization_id        OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_default_assign_exp_type             OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_default_assign_exp_type_cls         OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_return_status                       OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count                           OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data                            OUT             NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                  );

PROCEDURE Get_Project_Role_Default (p_assignment_type                     IN              VARCHAR2,
                                    p_project_role_id                     IN              NUMBER,
                                    x_default_job_group_id                OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_default_job_id                      OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_return_status                       OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                    x_msg_count                           OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_msg_data                            OUT             NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                  );

END PA_FORECAST_ITEMS_UTILS;
 

/
