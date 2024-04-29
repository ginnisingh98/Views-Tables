--------------------------------------------------------
--  DDL for Package PA_FORECAST_GRC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FORECAST_GRC_PVT" AUTHID CURRENT_USER AS
/* $Header: PARFGRCS.pls 120.1 2005/08/19 16:51:44 mwasowic noship $ */
PROCEDURE Get_Resource_Capacity (p_org_id               IN      NUMBER,
                                 p_person_id            IN      NUMBER,
                                 p_start_date           IN      DATE,
                                 p_end_date             IN      DATE,
                                 x_resource_capacity    OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_return_status        OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_msg_count            OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                );

--
--  Procedure           Get_Resource_Capacity
--  Purpose             This procedure will calculate the total possible
--                      working hours of a person between the input start
--                      date and end date.
--  Parameters
--




PROCEDURE Get_Capacity_Vector(p_OU_id                 IN    NUMBER,
                              p_exp_org_id_tab        IN    PA_PLSQL_DATATYPES.IdTabTyp,
                              p_person_id_tab         IN    PA_PLSQL_DATATYPES.IdTabTyp,
                              p_resource_id_tab       IN    PA_PLSQL_DATATYPES.IdTabTyp,
                              p_in_res_eff_s_date_tab IN    PA_PLSQL_DATATYPES.DateTabTyp,
                              p_in_res_eff_e_date_tab IN    PA_PLSQL_DATATYPES.DateTabTyp,
                              p_balance_type_code     IN    VARCHAR2,
                              p_run_start_date        IN    DATE,
                              p_run_end_date          IN    DATE,
                              x_resource_capacity_tab OUT   NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
                              x_exp_orgz_id_tab       OUT   NOCOPY PA_PLSQL_DATATYPES.IdTabTyp, --File.Sql.39 bug 4440895
                              x_person_id_tab         OUT   NOCOPY PA_PLSQL_DATATYPES.IdTabTyp, --File.Sql.39 bug 4440895
                              x_period_type_tab       OUT   NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp, --File.Sql.39 bug 4440895
                              x_period_name_tab       OUT   NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp, --File.Sql.39 bug 4440895
                              x_global_exp_date_tab   OUT   NOCOPY PA_PLSQL_DATATYPES.DateTabTyp, --File.Sql.39 bug 4440895
                              x_period_year_tab       OUT   NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
                              x_qm_number_tab         OUT   NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
                              x_period_num_tab        OUT   NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
                              x_return_status         OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_msg_count             OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_msg_data              OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              );

END PA_FORECAST_GRC_PVT;
 

/
