--------------------------------------------------------
--  DDL for Package Body PA_REP_UTIL_GLOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_REP_UTIL_GLOB" AS
  /* $Header: PARRGLBB.pls 120.1 2005/07/04 03:14:12 appldev ship $ */

  /*
   * Procedure to cache the Organization ID for U1 screen
   */

l_debug varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

  PROCEDURE SetU1OrganizationID (
      p_organization_id IN NUMBER
								)
  IS
  BEGIN
    G_Organization_ID:=p_organization_id;
  END SetU1OrganizationID;

  /*
   * Procedure to return cached Organization ID
   */
  FUNCTION GetU1OrganizationID return NUMBER
  IS
  BEGIN
    return G_Organization_ID;
  END GetU1OrganizationID;

  /*
   * Procedure to cache the Organization ID, Period Information for U1 screen
   */
  PROCEDURE SetU1Params(p_organization_id IN NUMBER, p_period_type IN VARCHAR2, p_period_name IN VARCHAR2, p_period_year IN NUMBER)
  IS
  BEGIN
    G_Organization_ID:=p_organization_id;
    G_Period_Type:=p_period_type;
    G_Period_Name:=p_period_name;
    G_Period_Year:=p_period_year;
    IF G_Period_Type = GetPeriodTypeGe THEN
	 G_Global_Exp_Period_End_Date:=to_date(p_period_name,'MM/DD/YYYY');
    ELSIF G_Period_Type = GetPeriodTypeQr THEN
	 G_Period_Quarter:=p_period_name;
    END IF;
  END;

  /*
   * Procedure to return cached Period Type
   */
  FUNCTION GetU1PeriodType return VARCHAR2
  IS
  BEGIN
    return G_Period_Type;
  END GetU1PeriodType;

  /*
   * Procedure to return cached Period Name
   */
  FUNCTION GetU1PeriodName return VARCHAR2
  IS
  BEGIN
    return G_Period_Name;
  END GetU1PeriodName;

  /*
   * Procedure to return cached Period Year
   */
  FUNCTION GetU1PeriodYear return VARCHAR2
  IS
  BEGIN
    return G_Period_Year;
  END GetU1PeriodYear;

  /*
   * Procedure to return cached Period Quarter
   */
  FUNCTION GetU1PeriodQuarter return VARCHAR2
  IS
  BEGIN
    return G_Period_Quarter;
  END GetU1PeriodQuarter;

  /*
   * Procedure to return cached GE Date
   */
  FUNCTION GetU1GlobalExpPeriodEndDate return DATE
  IS
  BEGIN
    return G_Global_Exp_Period_End_Date;
  END GetU1GlobalExpPeriodEndDate;


  /*
   * Procedure to Call Actuals Summarization based on the PA Installation
   */
  PROCEDURE Get_Util_Ac_Parm(
     errbuf                OUT NOCOPY VARCHAR2
    ,retcode               OUT NOCOPY VARCHAR2
    ,p_ac_start_date       IN  VARCHAR2
    ,p_ac_end_date         IN  VARCHAR2
    ,p_fc_start_date       IN  VARCHAR2
    ,p_fc_end_date         IN  VARCHAR2
    ,p_org_rollup_method   IN  VARCHAR2
    ,p_debug_mode          IN  VARCHAR2
                            )
  IS
    l_prc_switch     VARCHAR2(1)    :=NULL;
    l_errbuf         VARCHAR2(2000) :=NULL;
    l_retcode        VARCHAR2(2000) :=NULL;
    l_return_status  VARCHAR2(2000) :=NULL;
    l_effect_start_period_num NUMBER;
    l_orghier_date_before  DATE;
    l_orghier_date_after   DATE;
    l_fnd_msg        VARCHAR2(1000):=NULL;
  BEGIN

    /*
     *  To Initialize the error stack
     */
    PA_DEBUG.Set_Curr_Function(
                                p_function   => 'Get_Util_Ac_Parm',
                                p_process    => 'PLSQL',
                                p_write_file => 'LOG',
                                p_debug_mode => p_debug_mode);

    PA_DEBUG.g_err_stage := 'Process : Actuals Summarization';
    PA_DEBUG.Log_Message(p_message    => PA_DEBUG.g_err_stage
                         , p_write_mode  => 1
                         , p_write_file => 'OUT');


    --Enable menu structure for Utilization
    --This will enable the correct menu structure
    --for Utilization based on whether PJI is installed
    --or not
    PA_PJI_MENU_UTIL.ENABLE_MENUS;

    /*
     * Assume Success
     */
    retcode := 0;
    /*
     * Populate Globals for Subsequent Concurrent Processes
     * Call PA_REP_UTIL_GLOB procedure ...
     * Depending on Products Installed, Run Actuals
     * Concurrent Processes
     */
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := 'Arguments';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := '---------';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    PA_DEBUG.g_err_stage := 'p_ac_start_date     : '||p_ac_start_date;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := 'p_ac_end_date       : '||p_ac_end_date;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := 'p_fc_start_date     : '||p_fc_start_date;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := 'p_fc_end_date       : '||p_fc_end_date;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := 'p_org_rollup_method : '||p_org_rollup_method;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := 'p_debug_mode        : '||p_debug_mode;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    /*
     *  Write messages to the concurrent OUT file
     */

      FND_MESSAGE.Set_Name('PA','PA_UTIL_ACT_FROM_DATE');
	  l_fnd_msg := p_ac_start_date||' : '||FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message       => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file  => 'OUT'
                          );
      FND_MESSAGE.Set_Name('PA','PA_UTIL_ACT_THRU_DATE');
	  l_fnd_msg := p_ac_end_date||' : '||FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message       => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file  => 'OUT'
                          );
      FND_MESSAGE.Set_Name('PA','PA_UTIL_ORGZ_ROLLUP_METHOD');
	  l_fnd_msg := p_org_rollup_method||'           : '||FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message       => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file  => 'OUT'
                          );
      FND_MESSAGE.Set_Name('PA','PA_UTIL_FETCH_SIZE');
	  l_fnd_msg := PA_REP_UTIL_GLOB.G_util_fetch_size||'        : '||FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message       => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file  => 'OUT'
                          );
      FND_MESSAGE.Set_Name('PA','PA_UTIL_SUCCESSFUL_RUN');
	  l_fnd_msg := FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message       => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file  => 'OUT'
                          );
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := 'Messages';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := '--------';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    PA_DEBUG.g_err_stage := '50 : Inside PA_REP_UTIL_GLOB.get_util_ac_parm';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    IF TRUNC(TO_DATE(p_ac_start_date,'YYYY/MM/DD HH24:MI:SS')) >
       TRUNC(TO_DATE(p_ac_end_date,  'YYYY/MM/DD HH24:MI:SS')) THEN
      retcode := 2;
      errbuf  := 'The Given Date Range is Invalid';
      IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '100 : The Given Date Range is Invalid';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;

      FND_MESSAGE.Set_Name('PA','PA_UTIL_INVALID_DATE_RANGE');
      l_fnd_msg := FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message    => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file => 'OUT');
      PA_Debug.Reset_Curr_Function;
      RETURN;
    END IF;
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '150 : Before Calling PA_REP_UTIL_GLOB.Get_Util_Prc_Switch';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    Get_Util_Prc_Switch (
       x_prc_switch       => l_prc_switch
      ,x_msg_data         => l_errbuf
      ,x_return_status    => l_retcode
                         );

    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '200 : After Calling PA_REP_UTIL_GLOB.Get_Util_Prc_Switch';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    IF ( l_prc_switch = 'A' OR  l_prc_switch = 'B') THEN
      IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '250 : Before calling PA_REP_UTIL_GLOB.initialize_util_cache';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;

      PA_REP_UTIL_GLOB.initialize_util_cache(
         p_ac_start_date       => TRUNC(TO_DATE(p_ac_start_date,'YYYY/MM/DD HH24:MI:SS'))
        ,p_ac_end_date         => TRUNC(TO_DATE(p_ac_end_date,'YYYY/MM/DD HH24:MI:SS'))
        ,p_fc_start_date       => TRUNC(TO_DATE(p_fc_start_date,'YYYY/MM/DD HH24:MI:SS'))
        ,p_fc_end_date         => TRUNC(TO_DATE(p_fc_end_date,'YYYY/MM/DD HH24:MI:SS'))
        ,p_org_rollup_method   => p_org_rollup_method
        ,p_debug_mode          => p_debug_mode
                                             );
      IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '300 : After  calling PA_REP_UTIL_GLOB.initialize_util_cache';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;
  /*
   *  Bug 1810528
   *  The checking of the last_update_date of pa_org_hierarchy_denorm is
   *  to find if the the organization hierarchy changed during the run.
   */
    SELECT max(LAST_UPDATE_DATE)
      INTO l_orghier_date_before
      FROM pa_org_hierarchy_denorm
     WHERE pa_org_use_type = 'REPORTING'
       AND NVL(org_id, -99) = pa_rep_util_glob.G_implementation_details.G_org_id
       AND ORG_HIERARCHY_VERSION_ID = pa_rep_util_glob.G_implementation_details.G_org_structure_version_id
     ;

      IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '310 : Max Last_Update_Date of pa_org_hierarchy_denorm before the run is <'||l_orghier_date_before||'>';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

      PA_DEBUG.g_err_stage := '350 : Before calling PA_REP_UTIL_GLOB.Get_Effective_Start_Period_Num';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;

    IF pa_rep_util_glob.G_input_parameters.G_org_rollup_method = 'R' THEN
      IF pa_rep_util_glob.G_util_option_details.G_pa_period_flag = 'Y' THEN
         l_errbuf := NULL;
         l_retcode := '0';
         pa_rep_util_glob.Get_Effective_Start_Period_Num(
                          errbuf                     => l_errbuf,
                          retcode                    => l_retcode,
                          effective_start_period_num => l_effect_start_period_num,
--                        p_period_set_name          => pa_rep_util_glob.G_implementation_details.G_period_set_name,
                          p_period_set_name          => pa_rep_util_glob.G_implementation_details.G_pa_period_set_name, -- bug 3434019
                          p_period_type              => pa_rep_util_glob.G_implementation_details.G_pa_period_type,
                          p_start_date               => TRUNC(TO_DATE(p_ac_start_date,'YYYY/MM/DD HH24:MI:SS'))
                                                       );
         IF l_retcode = '2' THEN
           retcode := '2';
           IF l_debug ='Y'THEN -- bug 2674619
           PA_DEBUG.g_err_stage := '400 : There is no matching PA period for the given Start Date';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
           END IF;
           FND_MESSAGE.Set_Name('PA','PA_UTIL_INVALID_START_DATE_PA');
           l_fnd_msg := FND_MESSAGE.Get;
           PA_DEBUG.Log_Message(p_message    => l_fnd_msg
                                , p_write_mode  => 1
                                , p_write_file => 'OUT');
           PA_Debug.Reset_Curr_Function;
           RETURN;
         ELSE
           IF l_debug ='Y'THEN -- bug 2674619
           PA_DEBUG.g_err_stage := '400 : Eff pd Num-PA '||to_char(l_effect_start_period_num);
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
           END IF;
           PA_REP_UTIL_GLOB.G_eff_ac_start_pa_period_num := l_effect_start_period_num;
         END IF;
      END IF;
      IF pa_rep_util_glob.G_util_option_details.G_gl_period_flag = 'Y' THEN
         l_errbuf := NULL;
         l_retcode := '0';
         pa_rep_util_glob.Get_Effective_Start_Period_Num(
                          errbuf                     => l_errbuf,
                          retcode                    => l_retcode,
                          effective_start_period_num => l_effect_start_period_num,
--                        p_period_set_name          => pa_rep_util_glob.G_implementation_details.G_period_set_name,
                          p_period_set_name          => pa_rep_util_glob.G_implementation_details.G_gl_period_set_name, -- bug 3434019
                          p_period_type              => pa_rep_util_glob.G_implementation_details.G_gl_period_type,
                          p_start_date               => TRUNC(TO_DATE(p_ac_start_date,'YYYY/MM/DD HH24:MI:SS'))
                                                       );
         IF l_retcode = '2' THEN
           retcode := '2';
           IF l_debug ='Y'THEN -- bug 2674619
           PA_DEBUG.g_err_stage := '450 : There is no matching GL period for the given Start Date';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
           END IF;
           FND_MESSAGE.Set_Name('PA','PA_UTIL_INVALID_START_DATE_GL');
           l_fnd_msg := FND_MESSAGE.Get;
           PA_DEBUG.Log_Message(p_message    => l_fnd_msg
                                , p_write_mode  => 1
                                , p_write_file => 'OUT');
           PA_Debug.Reset_Curr_Function;
           RETURN;
         ELSE
           IF l_debug ='Y'THEN -- bug 2674619
           PA_DEBUG.g_err_stage := '500 : Eff pd Num-GL '||to_char(l_effect_start_period_num);
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
           END IF;
           PA_REP_UTIL_GLOB.G_eff_ac_start_gl_period_num := l_effect_start_period_num;
         END IF;
      END IF;
    END IF;
      IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '550 : After calling PA_REP_UTIL_GLOB.Get_Effective_Start_Period_Num';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

      PA_DEBUG.g_err_stage := '600 : Before calling PA_SUMMARIZE_ACTUAL_UTIL_PVT.summarize_actual_util';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;

      PA_SUMMARIZE_ACTUAL_UTIL_PVT.summarize_actual_util;
      IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '650 : After calling PA_SUMMARIZE_ACTUAL_UTIL_PVT.summarize_actual_util';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;
    ELSE
      IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '700 : Oracle Projects Not Installed .. Not Running Acutals';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;
      FND_MESSAGE.Set_Name('PA','PA_UTIL_PA_NOT_INSTALLED');
      l_fnd_msg := FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message    => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file => 'OUT');
      PA_Debug.Reset_Curr_Function;
      RETURN;
    END IF;

  /*
   *  Continuation of the check for Bug 1810528
   */
    SELECT max(LAST_UPDATE_DATE)
      INTO l_orghier_date_after
      FROM pa_org_hierarchy_denorm
     WHERE pa_org_use_type = 'REPORTING'
       AND NVL(org_id, -99) = pa_rep_util_glob.G_implementation_details.G_org_id
       AND ORG_HIERARCHY_VERSION_ID = pa_rep_util_glob.G_implementation_details.G_org_structure_version_id
     ;

    IF ( l_orghier_date_after > l_orghier_date_before) then
      FND_MESSAGE.Set_Name('PA','PA_UTIL_ORGZ_HIER_CHANGE');
      l_fnd_msg := FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message    => l_fnd_msg);
      PA_DEBUG.Log_Message(p_message       => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file  => 'OUT'
                          );
    ELSE
      FND_MESSAGE.Set_Name('PA','PA_UTIL_SUCCESSFUL_RUN');
      l_fnd_msg := FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message    => l_fnd_msg);
      PA_DEBUG.Log_Message(p_message       => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file  => 'OUT'
                          );
    END IF;
      IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '310 : Max Last_Update_Date of pa_org_hierarchy_denorm after the run is <'||l_orghier_date_after||'>';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    PA_DEBUG.g_err_stage := '750 : Exiting PA_REP_UTIL_GLOB.get_util_ac_parm';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    PA_Debug.Reset_Curr_Function;
  EXCEPTION
    WHEN OTHERS THEN
      retcode := 2;
      errbuf  := SUBSTR(SQLERRM,1,240);
      PA_DEBUG.Log_Message( SQLERRM);
      PA_DEBUG.Log_Message(PA_DEBUG.g_err_stack);
      PA_DEBUG.Log_Message(p_message       => SQLERRM
                           , p_write_mode  => 1
                           , p_write_file  => 'OUT'
                          );
      /*
       * Set the excetption Message and the stack
       */
      FND_MSG_PUB.add_exc_msg ( p_pkg_name       => 'PA_REP_UTIL_GLOB.get_util_ac_parm'
                             ,p_procedure_name => PA_DEBUG.G_Err_Stack );
      RAISE;

  END Get_Util_Ac_Parm;
  /*
   * Procedure to Call Forecasting Summarization based on the  PRM Installation
   */
  PROCEDURE Get_Util_Fc_Parm(
    errbuf                OUT NOCOPY VARCHAR2
    ,retcode               OUT NOCOPY VARCHAR2
    ,p_ac_start_date       IN  VARCHAR2
    ,p_ac_end_date         IN  VARCHAR2
    ,p_fc_start_date       IN  VARCHAR2
    ,p_fc_end_date         IN  VARCHAR2
    ,p_org_rollup_method   IN  VARCHAR2
    ,p_debug_mode          IN  VARCHAR2
                            )
  IS
   l_prc_switch     VARCHAR2(1)    :=NULL;
   l_errbuf         VARCHAR2(2000) :=NULL;
   l_retcode        VARCHAR2(2000) :=NULL;
   l_return_status  VARCHAR2(2000) :=NULL;
   l_effect_start_period_num NUMBER;
    l_orghier_date_before  DATE;
    l_orghier_date_after   DATE;
   l_fnd_msg        VARCHAR2(1000):=NULL;
  BEGIN


    /*
     * Set the debug mode
     */

    PA_DEBUG.Set_Curr_Function(
                                p_function   => 'Get_Util_Fc_Parm',
                                p_process    => 'PLSQL',
                                p_write_file => 'LOG',
                                p_debug_mode => p_debug_mode);

    PA_DEBUG.g_err_stage := 'Process : Forecast Summarization';
    PA_DEBUG.Log_Message(p_message    => PA_DEBUG.g_err_stage
                         , p_write_mode  => 1
                         , p_write_file => 'OUT');


    --Enable menu structure for Utilization
    --This will enable the correct menu structure
    --for Utilization based on whether PJI is installed
    --or not
    PA_PJI_MENU_UTIL.ENABLE_MENUS;

    /*
     * Assume Success
     */
    retcode := 0;
    /* Populate Globals for Subsequent Concurrent Processes
     * Call PA_REP_UTIL_GLOB procedure ...
     * Depending on Products Installed, Run Forecasts
     * Concurrent Processes
     */
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := 'Arguments';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := '---------';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    PA_DEBUG.g_err_stage := 'p_ac_start_date     : '||p_ac_start_date;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := 'p_ac_end_date       : '||p_ac_end_date;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := 'p_fc_start_date     : '||p_fc_start_date;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := 'p_fc_end_date       : '||p_fc_end_date;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := 'p_org_rollup_method : '||p_org_rollup_method;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := 'p_debug_mode        : '||p_debug_mode;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    /*
     *  Write messages to the concurrent OUT file
     */

      FND_MESSAGE.Set_Name('PA','PA_UTIL_FCT_FROM_DATE');
	  l_fnd_msg := p_fc_start_date||' : '||FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message       => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file  => 'OUT'
                          );
      FND_MESSAGE.Set_Name('PA','PA_UTIL_FCT_THRU_DATE');
	  l_fnd_msg := p_fc_end_date||' : '||FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message       => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file  => 'OUT'
                          );
      FND_MESSAGE.Set_Name('PA','PA_UTIL_ORGZ_ROLLUP_METHOD');
	  l_fnd_msg := p_org_rollup_method||'           : '||FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message       => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file  => 'OUT'
                          );
      FND_MESSAGE.Set_Name('PA','PA_UTIL_FETCH_SIZE');
	  l_fnd_msg := PA_REP_UTIL_GLOB.G_util_fetch_size||'        : '||FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message       => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file  => 'OUT'
                          );
      FND_MESSAGE.Set_Name('PA','PA_UTIL_SUCCESSFUL_RUN');
	  l_fnd_msg := FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message       => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file  => 'OUT'
                          );

    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := 'Messages';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := '--------';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    PA_DEBUG.g_err_stage := '50 : Inside PA_REP_UTIL_GLOB.get_util_fc_parm';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    IF TRUNC(TO_DATE(p_fc_start_date,'YYYY/MM/DD HH24:MI:SS')) >
       TRUNC(TO_DATE(p_fc_end_date,  'YYYY/MM/DD HH24:MI:SS')) THEN
      retcode := 2;
      errbuf  := 'The Given Date Range is Invalid';
      IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '100 : The Given Date Range is Invalid';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;
      FND_MESSAGE.Set_Name('PA','PA_UTIL_INVALID_DATE_RANGE');
      l_fnd_msg := FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message    => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file => 'OUT');
      PA_Debug.Reset_Curr_Function;
      RETURN;
    END IF;
    IF l_debug ='Y'THEN -- bug 2674619

    PA_DEBUG.g_err_stage := '100 : Before Calling PA_REP_UTIL_GLOB.Get_Util_Prc_Switch';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
    Get_Util_Prc_Switch (
       x_prc_switch       => l_prc_switch
      ,x_msg_data         => l_errbuf
      ,x_return_status    => l_retcode
                         );
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '150 : After Calling PA_REP_UTIL_GLOB.Get_Util_Prc_Switch';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    IF ( l_prc_switch = 'F' OR  l_prc_switch = 'B') THEN
      IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '200 : Before calling PA_REP_UTIL_GLOB.initialize_util_cache';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;

      PA_REP_UTIL_GLOB.initialize_util_cache(
         p_ac_start_date       => TRUNC(TO_DATE(p_ac_start_date,'YYYY/MM/DD HH24:MI:SS'))
        ,p_ac_end_date         => TRUNC(TO_DATE(p_ac_end_date,'YYYY/MM/DD HH24:MI:SS'))
        ,p_fc_start_date       => TRUNC(TO_DATE(p_fc_start_date,'YYYY/MM/DD HH24:MI:SS'))
        ,p_fc_end_date         => TRUNC(TO_DATE(p_fc_end_date,'YYYY/MM/DD HH24:MI:SS'))
        ,p_org_rollup_method   => p_org_rollup_method
        ,p_debug_mode          => p_debug_mode
                                            );
      IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '250 : After  calling PA_REP_UTIL_GLOB.initialize_util_cache';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;

  /*
   *  Bug 1810528
   *  The checking of the last_update_date of pa_org_hierarchy_denorm is
   *  to find if the the organization hierarchy changed during the run.
   */
    SELECT max(LAST_UPDATE_DATE)
      INTO l_orghier_date_before
      FROM pa_org_hierarchy_denorm
     WHERE pa_org_use_type = 'REPORTING'
       AND NVL(org_id, -99) = pa_rep_util_glob.G_implementation_details.G_org_id
       AND ORG_HIERARCHY_VERSION_ID = pa_rep_util_glob.G_implementation_details.
G_org_structure_version_id
     ;
      IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '300 : Max Last_Update_Date of pa_org_hierarchy_denorm before the run is <'||l_orghier_date_before||'>';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      PA_DEBUG.g_err_stage := '330 : Before calling PA_REP_UTIL_GLOB.Get_Effective_Start_Period_Num';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;

    IF pa_rep_util_glob.G_input_parameters.G_org_rollup_method = 'R' THEN
      IF pa_rep_util_glob.G_util_option_details.G_pa_period_flag = 'Y' THEN
         l_errbuf := NULL;
         l_retcode := '0';
         pa_rep_util_glob.Get_Effective_Start_Period_Num(
                          errbuf                     => l_errbuf,
                          retcode                    => l_retcode,
                          effective_start_period_num => l_effect_start_period_num,
--                        p_period_set_name          => pa_rep_util_glob.G_implementation_details.G_period_set_name,
                          p_period_set_name          => pa_rep_util_glob.G_implementation_details.G_pa_period_set_name, -- bug 3434019
                          p_period_type              => pa_rep_util_glob.G_implementation_details.G_pa_period_type,
                          p_start_date               => TRUNC(TO_DATE(p_fc_start_date,'YYYY/MM/DD HH24:MI:SS'))
                                                       );
         IF l_retcode = '2' THEN
           retcode := '2';
           IF l_debug ='Y'THEN -- bug 2674619
           PA_DEBUG.g_err_stage := '350 : There is no matching PA period for the given Start Date';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
           END IF;
           FND_MESSAGE.Set_Name('PA','PA_UTIL_INVALID_START_DATE_PA');
           l_fnd_msg := FND_MESSAGE.Get;
           PA_DEBUG.Log_Message(p_message    => PA_DEBUG.g_err_stage
                                , p_write_mode  => 1
                                , p_write_file => 'OUT');
           PA_Debug.Reset_Curr_Function;
           RETURN;
         ELSE
           IF l_debug ='Y'THEN -- bug 2674619
           PA_DEBUG.g_err_stage := '350 : Eff pd Num-PA '||to_char(l_effect_start_period_num);
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
           END IF;
           PA_REP_UTIL_GLOB.G_eff_fc_start_pa_period_num := l_effect_start_period_num;
         END IF;
      END IF;
      IF pa_rep_util_glob.G_util_option_details.G_gl_period_flag = 'Y' THEN
         l_errbuf := NULL;
         l_retcode := '0';
         pa_rep_util_glob.Get_Effective_Start_Period_Num(
                          errbuf                     => l_errbuf,
                          retcode                    => l_retcode,
                          effective_start_period_num => l_effect_start_period_num,
--                        p_period_set_name          => pa_rep_util_glob.G_implementation_details.G_period_set_name,
                          p_period_set_name          => pa_rep_util_glob.G_implementation_details.G_gl_period_set_name, -- bug 3434019
                          p_period_type              => pa_rep_util_glob.G_implementation_details.G_gl_period_type,
                          p_start_date               => TRUNC(TO_DATE(p_fc_start_date,'YYYY/MM/DD HH24:MI:SS'))
                                                       );
         IF l_retcode = '2' THEN
           retcode := '2';
           IF l_debug ='Y'THEN -- bug 2674619
           PA_DEBUG.g_err_stage := '400 : There is no matching GL period for the given Start Date';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
           END IF;
           FND_MESSAGE.Set_Name('PA','PA_UTIL_INVALID_START_DATE_GL');
           l_fnd_msg := FND_MESSAGE.Get;
           PA_DEBUG.Log_Message(p_message    => PA_DEBUG.g_err_stage
                                , p_write_mode  => 1
                                , p_write_file => 'OUT');
           PA_Debug.Reset_Curr_Function;
           RETURN;
         ELSE
          IF l_debug ='Y'THEN -- bug 2674619

           PA_DEBUG.g_err_stage := '400 : Eff pd Num-GL '||to_char(l_effect_start_period_num);
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
          END IF;
           PA_REP_UTIL_GLOB.G_eff_fc_start_gl_period_num := l_effect_start_period_num;
         END IF;
      END IF;
    END IF;

      IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '450 : After calling PA_REP_UTIL_GLOB.Get_Effective_Start_Period_Num';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      PA_DEBUG.g_err_stage := '500 : Before calling PA_SUMMARIZE_FORECAST_UTIL_PVT.summarize_forecast_util';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;

      PA_SUMMARIZE_FORECAST_UTIL_PVT.summarize_forecast_util;
      IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '550 : After calling PA_SUMMARIZE_FORECAST_UTIL_PVT.summarize_forecast_util';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;
    ELSE
      IF l_debug ='Y'THEN -- bug 2674619

      PA_DEBUG.g_err_stage := '400 : Oracle PRM Not Installed ... Not Running Forecast';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;
      FND_MESSAGE.Set_Name('PA','PA_UTIL_PRM_NOT_INSTALLED');
      l_fnd_msg := FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message    => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file => 'OUT');
      PA_DEBUG.Reset_Curr_Function;
      RETURN;
    END IF;

  /*
   *  Continuation of the check for Bug 1810528
   */
    SELECT max(LAST_UPDATE_DATE)
      INTO l_orghier_date_after
      FROM pa_org_hierarchy_denorm
     WHERE pa_org_use_type = 'REPORTING'
       AND NVL(org_id, -99) = pa_rep_util_glob.G_implementation_details.G_org_id
       AND ORG_HIERARCHY_VERSION_ID = pa_rep_util_glob.G_implementation_details.G_org_structure_version_id
     ;

    IF ( l_orghier_date_after > l_orghier_date_before) then
      FND_MESSAGE.Set_Name('PA','PA_UTIL_ORGZ_HIER_CHANGE');
      l_fnd_msg := FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message    => l_fnd_msg);
      PA_DEBUG.Log_Message(p_message       => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file  => 'OUT'
                          );
    ELSE
      FND_MESSAGE.Set_Name('PA','PA_UTIL_SUCCESSFUL_RUN');
      l_fnd_msg := FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message    => l_fnd_msg);
      PA_DEBUG.Log_Message(p_message       => l_fnd_msg
                           , p_write_mode  => 1
                           , p_write_file  => 'OUT'
                          );
    END IF;
     IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '310 : Max Last_Update_Date of pa_org_hierarchy_denorm after the run is <'||l_orghier_date_after||'>';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    PA_DEBUG.g_err_stage := '650 : Exiting PA_REP_UTIL_GLOB.get_util_fc_parm';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
    PA_DEBUG.Reset_Curr_Function;
  EXCEPTION
    WHEN OTHERS THEN

      retcode := 2;
      errbuf  := SUBSTR(SQLERRM,1,240);
      PA_DEBUG.Log_Message( SQLERRM);
      PA_DEBUG.Log_Message(PA_DEBUG.g_err_stack);
      PA_DEBUG.Log_Message(p_message       => SQLERRM
                           , p_write_mode  => 1
                           , p_write_file  => 'OUT'
                          );
      /*
       * Set the excetption Message and the stack
       */
      FND_MSG_PUB.add_exc_msg (
         p_pkg_name       => 'PA_REP_UTIL_GLOB.get_util_fc_parm'
        ,p_procedure_name => PA_DEBUG.G_Err_Stack
                              );
      RAISE;

  END Get_Util_Fc_Parm;

  PROCEDURE Get_Util_Prc_Switch (
     x_prc_switch       OUT NOCOPY VARCHAR2
    ,x_msg_data         OUT NOCOPY VARCHAR2
    ,x_return_status    OUT NOCOPY VARCHAR2
                               )
  IS
    l_pa_installed  BOOLEAN;
    l_prm_installed VARCHAR2(2);
  BEGIN

    PA_DEBUG.Set_Curr_Function( p_function   => 'Get_Util_Prc_Switch');
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '50 : Entering PA_REP_UTIL_GLOB.Get_Util_Prc_Switch';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
    /*
     * assume success
     */

    x_return_status := 0;
    x_prc_switch    := NULL;
    l_pa_installed := pa_install.is_product_installed('PA');
    l_prm_installed := pa_install.is_prm_licensed();
    IF ((l_pa_installed = TRUE) AND (l_prm_installed = 'Y' ) ) THEN
      x_prc_switch := 'B';
    ELSIF (l_pa_installed = TRUE) THEN
      x_prc_switch := 'A';
    ELSIF (l_prm_installed = 'Y') THEN
      x_prc_switch := 'F';
    ELSE
      /*
       * Neither PA or PRM are installed
       */
      x_prc_switch := 'X';
    END IF;
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '100 : X_PRC_SWITCH Value : '||x_prc_switch;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    -- PA_DEBUG.init_err_stack('PA_REP_UTIL_GLOB.Get_Util_Prc_Switch');
    PA_DEBUG.g_err_stage := '150 : Exiting PA_REP_UTIL_GLOB.Get_Util_Prc_Switch';
    END IF;
    PA_DEBUG.Reset_Curr_Function;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 2;
      x_msg_data  := SUBSTR(SQLERRM,1,240);
      PA_DEBUG.Log_Message( SQLERRM);
      PA_DEBUG.Log_Message(PA_DEBUG.g_err_stack);
      RAISE;
  END Get_Util_Prc_Switch;

  PROCEDURE initialize_util_cache(
     p_ac_start_date       IN DATE
    ,p_ac_end_date         IN DATE
    ,p_fc_start_date       IN DATE
    ,p_fc_end_date         IN DATE
    ,p_org_rollup_method   IN VARCHAR2 DEFAULT 'I'
    ,p_debug_mode          IN VARCHAR2
                                 )
  IS
  BEGIN
    PA_DEBUG.Set_Curr_Function( p_function   => 'Initialize_Util_Cache');
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '50 : Entering PA_REP_UTIL_GLOB.initialize_util_cache';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
    /*
     * Initialize the Global variables with the user specified
     * input parameters.
     */

    /*
     * The end_dates should be >= the start_dates.
     * This check can be included in the SRS high-low edit.
     * If that's not possible, this check has to be done here
     * and an appropriate error message has to be displayed.
     */
    G_input_parameters.G_ac_start_date := NVL(p_ac_start_date,
                                          TO_DATE('01-01-1950','DD-MM-YYYY'));
    G_input_parameters.G_ac_end_date   := NVL(p_ac_end_date,
                                          TO_DATE('31-12-4712','DD-MM-YYYY'));
    G_input_parameters.G_fc_start_date := NVL(p_fc_start_date,
                                          TO_DATE('01-01-1950','DD-MM-YYYY'));
    G_input_parameters.G_fc_end_date   := NVL(p_fc_end_date,
                                          TO_DATE('31-12-4712','DD-MM-YYYY'));
    G_input_parameters.G_org_rollup_method := p_org_rollup_method;
    G_input_parameters.G_debug_mode    := p_debug_mode;
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '100 : Exiting PA_REP_UTIL_GLOB.initialize_util_cache';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.Reset_Curr_Function;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      PA_DEBUG.Log_Message( SQLERRM);
      PA_DEBUG.Log_Message(PA_DEBUG.g_err_stack);
      RAISE;
  END initialize_util_cache;

  PROCEDURE Get_Effective_Start_Period_Num(  errbuf                     OUT NOCOPY VARCHAR2
                                            ,retcode                    OUT NOCOPY VARCHAR2
                                            ,effective_start_period_num OUT NOCOPY NUMBER
                                            ,p_period_set_name          IN  VARCHAR2
                                            ,p_period_type              IN  VARCHAR2
                                            ,p_start_date               IN  DATE
                                           )
  IS
  BEGIN
    retcode := 0;

    PA_DEBUG.Set_Curr_Function( p_function   => 'Get_Effective_Start_Period_Num');
    IF l_debug ='Y'THEN -- bug 2674619

    PA_DEBUG.g_err_stage := '50 : Entering PA_REP_UTIL_GLOB.Get_Effective_Start_Period_Num';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    SELECT (g.period_year*10000) + g.period_num
      INTO effective_start_period_num
      FROM gl_date_period_map     map
          ,gl_periods             g
--    WHERE g.period_set_name   = G_implementation_details.G_period_set_name
      WHERE g.period_set_name   = p_period_set_name   --bug 3434019
        AND g.period_name       = map.period_name
        AND map.accounting_date = p_start_date
        AND map.period_type     = p_period_type
--        AND map.period_set_name = G_implementation_details.G_period_set_name;
        AND map.period_set_name = p_period_set_name;  --bug 3434019

    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '100 : Exiting PA_REP_UTIL_GLOB.Get_Effective_Start_Period_Num';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    retcode := 2;
    errbuf  := 'The Given Start Date does not map to ';
  WHEN OTHERS        THEN
    retcode := 2;
    errbuf  := SQLERRM;
    RAISE;
  END Get_Effective_Start_Period_Num;

  /*
   * This Procedure populates the Amount type ids Cache.
   * Its called from, PA_REP_UTIL_GLOB.auto_util_cache.
   */
  PROCEDURE initialize_amt_type_id_cache
  IS
  BEGIN
    PA_DEBUG.Set_Curr_Function( p_function   => 'Initialize_Amt_Type_Id_Cache');
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '50 : Entering PA_REP_UTIL_GLOB.initialize_amt_type_id_cache';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
    /*
     * Initialize the amount type_id variables with their
     * corresponding values.
     */

    G_amt_type_details.G_res_hrs_id                   := 1;
    G_amt_type_details.G_res_wtdhrs_org_id            := 2;
    G_amt_type_details.G_res_wtdhrs_people_id         := 3;
    G_amt_type_details.G_res_prvhrs_id                := 4;
    G_amt_type_details.G_res_prvwtdhrs_org_id         := 5;
    G_amt_type_details.G_res_prvwtdhrs_people_id      := 6;
    G_amt_type_details.G_res_utilprctghrs_id          := 7;
    G_amt_type_details.G_res_utilprctgcap_id          := 8;
    G_amt_type_details.G_res_cap_id                   := 9;
    G_amt_type_details.G_res_reducedcap_id            := 10;

    G_amt_type_details.G_org_sub_hrs_id               := 11;
    G_amt_type_details.G_org_sub_wtdhrs_org_id        := 12;
    G_amt_type_details.G_org_sub_prvhrs_id            := 13;
    G_amt_type_details.G_org_sub_prvwtdhrs_org_id     := 14;
    G_amt_type_details.G_org_sub_utilprctghrs_id      := 15;
    G_amt_type_details.G_org_sub_utilprctgcap_id      := 16;
    G_amt_type_details.G_org_sub_cap_id               := 17;
    G_amt_type_details.G_org_sub_reducedcap_id        := 18;
    G_amt_type_details.G_org_sub_headcount_id         := 19;
    G_amt_type_details.G_org_sub_empheadcount_id      := 20;

    G_amt_type_details.G_org_dir_hrs_id               := 21;
    G_amt_type_details.G_org_dir_wtdhrs_org_id        := 22;
    G_amt_type_details.G_org_dir_prvhrs_id            := 23;
    G_amt_type_details.G_org_dir_prvwtdhrs_org_id     := 24;
    G_amt_type_details.G_org_dir_utilprctghrs_id      := 25;
    G_amt_type_details.G_org_dir_utilprctgcap_id      := 26;
    G_amt_type_details.G_org_dir_cap_id               := 27;
    G_amt_type_details.G_org_dir_reducedcap_id        := 28;
    G_amt_type_details.G_org_dir_headcount_id         := 29;
    G_amt_type_details.G_org_dir_empheadcount_id      := 30;

    G_amt_type_details.G_org_tot_hrs_id               := 31;
    G_amt_type_details.G_org_tot_wtdhrs_org_id        := 32;
    G_amt_type_details.G_org_tot_prvhrs_id            := 33;
    G_amt_type_details.G_org_tot_prvwtdhrs_org_id     := 34;
    G_amt_type_details.G_org_tot_utilprctghrs_id      := 35;
    G_amt_type_details.G_org_tot_utilprctgcap_id      := 36;
    G_amt_type_details.G_org_tot_cap_id               := 37;
    G_amt_type_details.G_org_tot_reducedcap_id        := 38;
    G_amt_type_details.G_org_tot_headcount_id         := 39;
    G_amt_type_details.G_org_tot_empheadcount_id      := 40;
    G_amt_type_details.G_quantity_id                  := 41;
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '100 : Exiting PA_REP_UTIL_GLOB.initialize_amt_type_id_cache';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
    PA_DEBUG.Reset_Curr_Function;

  EXCEPTION
    WHEN OTHERS THEN
      PA_DEBUG.Log_Message( SQLERRM);
      PA_DEBUG.Log_Message(PA_DEBUG.g_err_stack);
      RAISE;
  END initialize_amt_type_id_cache;

  PROCEDURE SetU3PeriodType(p_period_type IN pa_implementations.pa_period_type%TYPE)
  IS
  BEGIN
    G_u3_parameters.G_period_type := p_period_type;
  END SetU3PeriodType;

  PROCEDURE SetU3PeriodName(p_period_name IN gl_periods.period_name%TYPE)
  IS
  BEGIN
    G_u3_parameters.G_period_name := p_period_name;
  END SetU3PeriodName;

  PROCEDURE SetU3QtrOrMonNum(p_qtr_or_mon_num IN VARCHAR2)
  IS
  BEGIN
    G_u3_parameters.G_qtr_or_mon_num := p_qtr_or_mon_num;
  END SetU3QtrOrMonNum;

  PROCEDURE SetU3YearNum(p_year_num IN VARCHAR2)
  IS
  BEGIN
    G_u3_parameters.G_year_num := p_year_num;
  END SetU3YearNum;

  PROCEDURE SetU3PersonId(p_person_id IN VARCHAR2)
  IS
  BEGIN
    G_u3_parameters.G_person_id := p_person_id;
  END SetU3PersonId;
  PROCEDURE SetU3GeEndDate(p_ge_end_date IN VARCHAR2)
  IS
  BEGIN
    G_u3_parameters.G_ge_end_date := p_ge_end_date;
  END SetU3GeEndDate;
  PROCEDURE SetU3EffPeriodNum(p_eff_period_num IN VARCHAR2)
  IS
  BEGIN
    G_u3_parameters.G_eff_period_num := p_eff_period_num;
  END SetU3EffPeriodNum;

  PROCEDURE SetU1ShowPrctgBy(p_showprctgby IN VARCHAR2)
  IS
  BEGIN
     G_u1_show_prctg_by := p_showprctgby;
  END SetU1ShowPrctgBy;

  /*
   * This procedure initializes Global variables.
   */
  /*
   * This procedure initializes Global variables.
   */
  PROCEDURE auto_util_cache
  IS
  BEGIN
    PA_DEBUG.Set_Curr_Function( p_function   => 'Auto_Util_Cache');
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '50 : Entering PA_REP_UTIL_GLOB.auto_util_cache';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    /*
     * Assigning Constant values for variables supposed to
     * to act as constants.
     * The values assigned are NOT to be changed anywhere.
     */

    /*
     * Constants - Amount Types.
     */
    G_BAL_TYPE_C.G_ACTUALS_C  := 'ACTUALS';
    G_BAL_TYPE_C.G_FORECAST_C := 'FORECAST';

    /*
     * Constants - Object Types.
     */
    G_OBJ_TYPE_C.G_ORG_C      := 'ORG';
    G_OBJ_TYPE_C.G_ORGUC_C    := 'ORGUC';
    G_OBJ_TYPE_C.G_ORGWT_C    := 'ORGWT';
    G_OBJ_TYPE_C.G_RES_C      := 'RES';
    G_OBJ_TYPE_C.G_RESUCO_C   := 'RESUCO';
    G_OBJ_TYPE_C.G_RESUCR_C   := 'RESUCR';
    G_OBJ_TYPE_C.G_RESWT_C    := 'RESWT';
    G_OBJ_TYPE_C.G_UTILDET_C  := 'UTILDET';

    /*
     * Constants - Period Types.
     */
    G_PERIOD_TYPE_C.G_GL_C    := 'GL';
    G_PERIOD_TYPE_C.G_PA_C    := 'PA';
    G_PERIOD_TYPE_C.G_GE_C    := 'GE';

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

    /*
     * Populate the Global variable for the Fetch Size.
     */
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '100 : Before Accessing FND_PROFILE values';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    --IF (FND_PROFILE.VALUE('PA_NUM_TXN_SUMM_PER_SET')) IS NOT NULL THEN
    --  G_util_fetch_size := FND_PROFILE.VALUE('PA_NUM_TXN_SUMM_PER_SET');
    --  /*
    --   * If a fetch size is NOT specified, G_DEFAULT_FETCH_SIZE is used.
    --   */
    --END IF;

    G_global_week_start_day := FND_PROFILE.VALUE('PA_GLOBAL_WEEK_START_DAY');

    /*
     * To get the Global variable for Utilization Calculation Method from FND Profile
     */

    G_util_option_details.G_util_calc_method := FND_PROFILE.VALUE('PA_RES_UTIL_DEF_CALC_METHOD');

    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '150 : After Accessing FND_PROFILE values';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    /*
     * Populate the Global record for the Implementation Details.
     */
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '200 : Before Selecting Implementation Details';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    SELECT NVL(imp.org_id,-99)
          ,imp.org_structure_version_id
          ,imp.start_organization_id
          ,imp.pa_period_type
          ,sob.accounted_period_type
          ,sob.period_set_name
          ,imp.period_set_name                 --bug 3434019
      INTO G_implementation_details.G_org_id
          ,G_implementation_details.G_org_structure_version_id
          ,G_implementation_details.G_start_organization_id
          ,G_implementation_details.G_pa_period_type
          ,G_implementation_details.G_gl_period_type
          ,G_implementation_details.G_gl_period_set_name   --bug 3434019
          ,G_implementation_details.G_pa_period_set_name   --bug 3434019
    FROM pa_implementations imp
          ,gl_sets_of_books sob
    WHERE sob.set_of_books_id = imp.set_of_books_id ;

    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '250 : After Selecting Implementation Details';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    /*
     * Populate the Global record for the Utilization Options
     * details.
     * pa_utilization_options is assumed to have ONLY ONE record.
     */
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '300 : Before Setting the Global variables for all Period flags';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    SELECT pa_period_flag
          ,gl_period_flag
          ,global_exp_period_flag
          ,forecast_thru_date
          ,actuals_thru_date
      INTO G_util_option_details.G_pa_period_flag
          ,G_util_option_details.G_gl_period_flag
          ,G_util_option_details.G_ge_period_flag
          ,G_util_option_details.G_forecast_thru_date
          ,G_util_option_details.G_actuals_thru_date
    FROM pa_utilization_options;

    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '350 : After Setting the Global variables for all Period flags';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    /*
     * Populate the Global record for the last run details
     * pa_utilization_options is assumed to have ONLY ONE record.
     */
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '360 : Before Setting the Global variables for last run details';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    SELECT actuals_last_run_date
          ,forecast_last_run_date
      INTO G_last_run_when.G_ac_last_run_date
          ,G_last_run_when.G_fc_last_run_date
    FROM pa_utilization_options;
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '370 : After Setting the Global variables for last run details';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;



    /*
     * Call the Procedure to initialize amount_type_ids.
     */
   IF l_debug ='Y'THEN -- bug 2674619
   PA_DEBUG.g_err_stage := '400 : Before calling initialize_amt_type_id_cache';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
   END IF;

   PA_REP_UTIL_GLOB.initialize_amt_type_id_cache;
   IF l_debug ='Y'THEN -- bug 2674619
   PA_DEBUG.g_err_stage := '450 : After calling initialize_amt_type_id_cache';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

   PA_DEBUG.g_err_stage := '500 : Exiting PA_REP_UTIL_GLOB.auto_util_cache';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
   END IF;
   PA_DEBUG.Reset_Curr_Function;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END auto_util_cache;

  /*
   * Functions.
   */

  /*
   * Functions to return Period_types.
   */

  FUNCTION GetPeriodTypeGl  RETURN VARCHAR2
    IS
  BEGIN
    RETURN G_PERIOD_TYPE_C.G_GL_C;
  END GetPeriodTypeGl;

  FUNCTION GetPeriodTypePa  RETURN VARCHAR2
    IS
    BEGIN
      RETURN G_PERIOD_TYPE_C.G_PA_C;
  END GetPeriodTypePa;

  FUNCTION GetPeriodTypeGe  RETURN VARCHAR2
    IS
    BEGIN
      RETURN G_PERIOD_TYPE_C.G_GE_C;
  END GetPeriodTypeGe;

  /*
   * Functions to return Balance_types..
   */

  FUNCTION GetBalTypeActuals  RETURN VARCHAR2
    IS
    BEGIN
      RETURN G_BAL_TYPE_C.G_ACTUALS_C;
  END GetBalTypeActuals;

  FUNCTION GetBalTypeForecast RETURN VARCHAR2
    IS
    BEGIN
      RETURN G_BAL_TYPE_C.G_FORECAST_C;
    END GetBalTypeForecast;

  /*
   * Functions to return Object_types
   */

  FUNCTION GetObjectTypeOrg RETURN VARCHAR2
  IS
  BEGIN
    RETURN G_OBJ_TYPE_C.G_ORG_C;
  END GetObjectTypeOrg;

  FUNCTION GetObjectTypeOrgUc RETURN VARCHAR2
  IS
  BEGIN
    RETURN G_OBJ_TYPE_C.G_ORGUC_C;
  END GetObjectTypeOrgUc ;

  FUNCTION GetObjectTypeOrgWt RETURN VARCHAR2
  IS
  BEGIN
    RETURN G_OBJ_TYPE_C.G_ORGWT_C;
  END GetObjectTypeOrgWt ;

  FUNCTION GetObjectTypeRes RETURN VARCHAR2
  IS
  BEGIN
    RETURN G_OBJ_TYPE_C.G_RES_C;
  END GetObjectTypeRes ;

  FUNCTION GetObjectTypeResUco RETURN VARCHAR2
  IS
  BEGIN
    RETURN G_OBJ_TYPE_C.G_RESUCO_C;
  END GetObjectTypeResUco ;

  FUNCTION GetObjectTypeResUcr RETURN VARCHAR2
  IS
  BEGIN
    RETURN G_OBJ_TYPE_C.G_RESUCR_C;
  END GetObjectTypeResUcr ;

  FUNCTION GetObjectTypeResWt RETURN VARCHAR2
  IS
  BEGIN
    RETURN G_OBJ_TYPE_C.G_RESWT_C;
  END GetObjectTypeResWt ;

  FUNCTION GetObjectTypeUtilDet RETURN VARCHAR2
  IS
  BEGIN
    RETURN G_OBJ_TYPE_C.G_UTILDET_C;
  END GetObjectTypeUtilDet ;

    /*
     * Function to return Fetch Size.
     */
  FUNCTION GetFetchSize RETURN NUMBER
  IS
  BEGIN
    RETURN G_DEFAULT_FETCH_SIZE_C;
  END GetFetchSize;

    /*
     * Function to return Period Set name.
     */
  FUNCTION GetPeriodSetName RETURN gl_sets_of_books.period_set_name%TYPE
  IS
  BEGIN
    RETURN G_implementation_details.G_gl_period_set_name;
  END GetPeriodSetName;

    /*
     * Functions to return dummy values.
     */
  FUNCTION GetDummy RETURN VARCHAR2
  IS
  BEGIN
    RETURN PA_REP_UTIL_GLOB.G_DUMMY_C;
  END GetDummy;

  FUNCTION GetDummyDate RETURN DATE
  IS
  BEGIN
    RETURN PA_REP_UTIL_GLOB.G_DUMMY_DATE_C;
  END GetDummyDate;

    /*
     * Function to return org_id
     */
  FUNCTION GetOrgId RETURN pa_implementations.org_id%TYPE
  IS
  BEGIN
    RETURN G_implementation_details.G_org_id;
  END GetOrgId;

  FUNCTION GetOrgStructureVersionId RETURN pa_implementations.org_structure_version_id%TYPE
  IS
  BEGIN
    RETURN G_implementation_details.G_org_structure_version_id;
  END GetOrgStructureVersionId;

    /*
     * Functions to get parameters from the U3 screen
     */

  FUNCTION GetU3PeriodType RETURN pa_implementations.pa_period_type%TYPE
  IS
  BEGIN
    RETURN G_u3_parameters.G_period_type;
  END GetU3PeriodType;

  FUNCTION GetU3PeriodName RETURN gl_periods.period_name%TYPE
  IS
  BEGIN
    RETURN G_u3_parameters.G_period_name;
  END GetU3PeriodName;

  FUNCTION GetU3QtrOrMonNum RETURN NUMBER
  IS
  BEGIN
    RETURN G_u3_parameters.G_qtr_or_mon_num;
  END GetU3QtrOrMonNum;

  FUNCTION GetU3YearNum RETURN NUMBER
  IS
  BEGIN
    RETURN G_u3_parameters.G_year_num;
  END GetU3YearNum;

  FUNCTION GetU3PersonId RETURN NUMBER
  IS
  BEGIN
    RETURN G_u3_parameters.G_person_id;
  END GetU3PersonId;

  FUNCTION GetU3GeEndDate RETURN VARCHAR2
  IS
  BEGIN
    RETURN G_u3_parameters.G_ge_end_date;
  END GetU3GeEndDate;
  FUNCTION GetU3EffPeriodNum RETURN NUMBER
  IS
  BEGIN
    RETURN G_u3_parameters.G_eff_period_num;
  END GetU3EffPeriodNum;

  FUNCTION GetU1ShowPrctgBy RETURN VARCHAR2
  IS
  BEGIN
    RETURN G_u1_show_prctg_by;
  END GetU1ShowPrctgBy;



  FUNCTION GetPeriodTypeQr RETURN VARCHAR2
  IS
  BEGIN
    RETURN G_period_type_qtr_c;
  END GetPeriodTypeQr;

  FUNCTION GetPeriodTypeYr RETURN VARCHAR2
  IS
  BEGIN
    RETURN G_period_type_year_c;
  END GetPeriodTypeYr;

  FUNCTION GetUtilCalcMethod RETURN VARCHAR2
  IS
  BEGIN
     RETURN G_util_option_details.G_util_calc_method;
  END GetUtilCalcMethod;

  /*
   *  The following Functions are for getting the last run details
   */

  FUNCTION GetActualsLastRunDate RETURN DATE
  IS
  BEGIN
     RETURN G_last_run_when.G_ac_last_run_date;
  END GetActualsLastRunDate;

  FUNCTION GetForecastLastRunDate RETURN DATE
  IS
  BEGIN
     RETURN G_last_run_when.G_fc_last_run_date;
  END GetForecastLastRunDate;

   /*
   * This procedure initializes Global variables.
   * This is created for Bug 2447797. Note that do
   * not stub out the code in auto_util_cache.
   */
  PROCEDURE update_util_cache
  IS
      l_global_week_start_day PLS_INTEGER;
      l_util_calc_method  VARCHAR2(30);
      l_org_id  pa_implementations.org_id%TYPE;
      l_org_structure_version_id pa_implementations.org_structure_version_id%TYPE;
      l_start_organization_id pa_implementations.start_organization_id%TYPE;
      l_pa_period_type pa_implementations.pa_period_type%TYPE;
      l_gl_period_type gl_sets_of_books.accounted_period_type%TYPE;
--    l_period_set_name gl_sets_of_books.period_set_name%TYPE;
      l_gl_period_set_name gl_sets_of_books.period_set_name%TYPE;  -- bug 3434019
      l_pa_period_set_name gl_sets_of_books.period_set_name%TYPE;  -- bug 3434019
  BEGIN

    PA_DEBUG.Set_Curr_Function( p_function   => 'Update_Util_Cache');
    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '50 : Entering PA_REP_UTIL_GLOB.update_util_cache';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    PA_DEBUG.g_err_stage := '100 : Before Accessing FND_PROFILE values';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    l_global_week_start_day := FND_PROFILE.VALUE('PA_GLOBAL_WEEK_START_DAY');
    l_util_calc_method := FND_PROFILE.VALUE('PA_RES_UTIL_DEF_CALC_METHOD');

    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '150 : After Accessing FND_PROFILE values';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    PA_DEBUG.g_err_stage := '200 : Before Selecting Implementation Details';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    SELECT NVL(imp.org_id,-99)
          ,imp.org_structure_version_id
          ,imp.start_organization_id
          ,imp.pa_period_type
          ,sob.accounted_period_type
          ,sob.period_set_name
          ,imp.period_set_name
    INTO   l_org_id
          ,l_org_structure_version_id
          ,l_start_organization_id
          ,l_pa_period_type
          ,l_gl_period_type
--        ,l_period_set_name
          ,l_gl_period_set_name   -- bug 3434019
          ,l_pa_period_set_name   -- bug 3434019
    FROM pa_implementations imp
          ,gl_sets_of_books sob
    WHERE sob.set_of_books_id = imp.set_of_books_id ;

    IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := '250 : After Selecting Implementation Details';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    /* This condition is made so that unnecessary processing is avoided. As
       the global variables are already initialzed through the procedure
       auto_util_cache.
    */
    IF ( l_global_week_start_day <> G_global_week_start_day OR
         l_util_calc_method <> G_util_option_details.G_util_calc_method OR
         l_org_id <> G_implementation_details.G_org_id)
    THEN


	    /*
	     * Assigning Constant values for variables supposed to
	     * to act as constants.
	     * The values assigned are NOT to be changed anywhere.
	     */

	    /*
	     * Constants - Amount Types.
	     */
	    G_BAL_TYPE_C.G_ACTUALS_C  := 'ACTUALS';
	    G_BAL_TYPE_C.G_FORECAST_C := 'FORECAST';

	    /*
	     * Constants - Object Types.
	     */
	    G_OBJ_TYPE_C.G_ORG_C      := 'ORG';
	    G_OBJ_TYPE_C.G_ORGUC_C    := 'ORGUC';
	    G_OBJ_TYPE_C.G_ORGWT_C    := 'ORGWT';
	    G_OBJ_TYPE_C.G_RES_C      := 'RES';
	    G_OBJ_TYPE_C.G_RESUCO_C   := 'RESUCO';
	    G_OBJ_TYPE_C.G_RESUCR_C   := 'RESUCR';
	    G_OBJ_TYPE_C.G_RESWT_C    := 'RESWT';
	    G_OBJ_TYPE_C.G_UTILDET_C  := 'UTILDET';

	    /*
	     * Constants - Period Types.
	     */
	    G_PERIOD_TYPE_C.G_GL_C    := 'GL';
	    G_PERIOD_TYPE_C.G_PA_C    := 'PA';
	    G_PERIOD_TYPE_C.G_GE_C    := 'GE';

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


	    G_global_week_start_day := l_global_week_start_day;

	    /*
	     * To get the Global variable for Utilization Calculation Method from FND Profile
	     */

	    G_util_option_details.G_util_calc_method := l_util_calc_method ;


	    /*
	     * Populate the Global record for the Implementation Details.
	     */

	    G_implementation_details.G_org_id := l_org_id;
	    G_implementation_details.G_org_structure_version_id := l_org_structure_version_id;
	    G_implementation_details.G_start_organization_id := l_start_organization_id;
	    G_implementation_details.G_pa_period_type := l_pa_period_type;
	    G_implementation_details.G_gl_period_type := l_gl_period_type;
--	    G_implementation_details.G_period_set_name := l_period_set_name;
	    G_implementation_details.G_gl_period_set_name := l_gl_period_set_name;   -- bug 3434019
	    G_implementation_details.G_pa_period_set_name := l_pa_period_set_name;   -- bug 3434019


	    /*
	     * Populate the Global record for the Utilization Options
	     * details. Populate the Global record for the last run details
	     * pa_utilization_options is assumed to have ONLY ONE record.
	     */
            IF l_debug ='Y'THEN -- bug 2674619
	    PA_DEBUG.g_err_stage := '300 : Before Setting the Global variables for all Period flags and for last run details';
	    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            END IF;

	    SELECT pa_period_flag
	          ,gl_period_flag
	          ,global_exp_period_flag
	          ,forecast_thru_date
	          ,actuals_thru_date
		  ,actuals_last_run_date
		  ,forecast_last_run_date
	      INTO G_util_option_details.G_pa_period_flag
	          ,G_util_option_details.G_gl_period_flag
	          ,G_util_option_details.G_ge_period_flag
	          ,G_util_option_details.G_forecast_thru_date
	          ,G_util_option_details.G_actuals_thru_date
		  ,G_last_run_when.G_ac_last_run_date
	          ,G_last_run_when.G_fc_last_run_date
	    FROM pa_utilization_options;
            IF l_debug ='Y'THEN -- bug 2674619
	    PA_DEBUG.g_err_stage := '350 : After Setting the Global variables for all Period flags and for last run details';
	    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            END IF;



	    /*
	     * Call the Procedure to initialize amount_type_ids.
	     */
          IF l_debug ='Y'THEN -- bug 2674619
	   PA_DEBUG.g_err_stage := '400 : Before calling initialize_amt_type_id_cache';
	   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         END IF;

	   PA_REP_UTIL_GLOB.initialize_amt_type_id_cache;
         IF l_debug ='Y'THEN -- bug 2674619
	   PA_DEBUG.g_err_stage := '450 : After calling initialize_amt_type_id_cache';
	   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
          END IF;
   END IF;

   IF l_debug ='Y'THEN -- bug 2674619
   PA_DEBUG.g_err_stage := '500 : Exiting PA_REP_UTIL_GLOB.update_util_cache';
   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
   END IF;
   PA_DEBUG.Reset_Curr_Function;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END update_util_cache;

BEGIN
  /*
   * The following procedure gets executed the first time the
   * Package is loaded.
   */
    auto_util_cache;

END PA_REP_UTIL_GLOB;

/
