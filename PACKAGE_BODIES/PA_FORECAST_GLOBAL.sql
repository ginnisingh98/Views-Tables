--------------------------------------------------------
--  DDL for Package Body PA_FORECAST_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FORECAST_GLOBAL" AS
/* $Header: PARFGGBB.pls 120.1 2005/08/19 16:51:30 mwasowic noship $ */

  P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE Initialize_Global(
                                x_msg_count     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_ret_status IN OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  IS
    l_temp_str     VARCHAR2(100);
    l_msg_count    NUMBER := 0;
  BEGIN
    PA_DEBUG.Set_Curr_Function( p_function   => 'Initialize Global');
    IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.g_err_stage := '50 : Entering PA_FORECAST_GLOBAL.Initialize_Global';
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

 /* Initialize the error stack */
    FND_MSG_PUB.initialize;
    /*
     * Populate the Global record for the WHO columns.
     */

    G_who_columns.G_last_updated_by   := FND_GLOBAL.USER_ID;
    G_who_columns.G_created_by        := FND_GLOBAL.USER_ID;
    G_who_columns.G_creation_date     := SYSDATE;
    G_who_columns.G_last_update_date  := G_who_columns.G_creation_date;
    G_who_columns.G_last_update_login      := FND_GLOBAL.LOGIN_ID;
    G_who_columns.G_program_application_id := FND_GLOBAL.PROG_APPL_ID;
    G_who_columns.G_request_id := FND_GLOBAL.CONC_REQUEST_ID;
    G_who_columns.G_program_id := FND_GLOBAL.CONC_PROGRAM_ID;

    IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.g_err_stage := '100 : Before Accessing FND_PROFILE values';
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
    x_msg_count  := 0;
    x_ret_status := FND_API.G_RET_STS_SUCCESS;
    IF  PA_FORECAST_GLOBAL.G_fcst_global_flag = 'Y' THEN
      PA_DEBUG.Reset_Curr_Function;
      RETURN;
    END IF;

    PA_FORECAST_GLOBAL.G_fcst_proceed_flag := 'Y';


    IF (FND_PROFILE.VALUE('PA_FORECAST_RESOURCE_LIST')) IS NOT NULL THEN
      G_implementation_details.G_fcst_res_list := FND_PROFILE.VALUE('PA_FORECAST_RESOURCE_LIST');
    ELSE
      x_ret_status := FND_API.G_RET_STS_ERROR;
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FCST_NO_RES_LIST');
      PA_FORECAST_GLOBAL.G_fcst_proceed_flag := 'N';
      x_msg_count := x_msg_count + 1;
    END IF;

    IF (FND_PROFILE.VALUE('PA_FORECASTING_PERIOD_TYPE')) IS NOT NULL THEN
      G_implementation_details.G_fcst_period_type := FND_PROFILE.VALUE('PA_FORECASTING_PERIOD_TYPE');
    ELSE
      x_ret_status := FND_API.G_RET_STS_ERROR;
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FCST_NO_PD_TYPE');
      PA_FORECAST_GLOBAL.G_fcst_proceed_flag := 'N';
      x_msg_count := x_msg_count + 1;
    END IF;

    IF G_implementation_details.G_fcst_period_type = 'PA' THEN
       l_temp_str :=  'PA_FORECAST_DEF_BEM_PA';
    ELSIF G_implementation_details.G_fcst_period_type = 'GL' THEN
       l_temp_str :=  'PA_FORECAST_DEF_BEM_GL';
    END IF;

      IF FND_PROFILE.VALUE(l_temp_str) IS NOT NULL THEN
        G_implementation_details.G_fcst_def_bem := FND_PROFILE.VALUE(l_temp_str);
      ELSE
        x_ret_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FCST_NO_BEM');
        PA_FORECAST_GLOBAL.G_fcst_proceed_flag := 'N';
        x_msg_count := x_msg_count + 1;
      END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.g_err_stage := '150 : After Accessing FND_PROFILE values';
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;


    BEGIN
      SELECT JOB_COST_RATE_SCHEDULE_ID INTO  G_implementation_details.G_fcst_cost_rate_sch_id
                 FROM PA_FORECASTING_OPTIONS
        WHERE JOB_COST_RATE_SCHEDULE_ID IS NOT NULL;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      x_ret_status := FND_API.G_RET_STS_ERROR;
      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FCST_NO_JOB_SCH_ID');
      PA_FORECAST_GLOBAL.G_fcst_proceed_flag := 'N';
      x_msg_count := x_msg_count + 1;
      PA_DEBUG.Reset_Curr_Function;
      RETURN;
    END;

    IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.g_err_stage := '250 : After Selecting from PA_FORECASTING_OPTIONS';
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    IF x_msg_count = 0 THEN
      PA_FORECAST_GLOBAL.G_fcst_global_flag  := 'Y';
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.g_err_stage := '300 : Exiting PA_FORECAST_GLOBAL';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
    PA_DEBUG.Reset_Curr_Function;
  EXCEPTION
    WHEN OTHERS THEN
      x_ret_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE;
  END Initialize_Global;

END PA_FORECAST_GLOBAL;

/
