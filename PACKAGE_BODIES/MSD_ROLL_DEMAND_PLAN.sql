--------------------------------------------------------
--  DDL for Package Body MSD_ROLL_DEMAND_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_ROLL_DEMAND_PLAN" AS
/* $Header: msddprlb.pls 120.0.12010000.2 2009/08/21 04:13:31 vrepaka ship $ */


   v_errtxt            VARCHAR2(300);

  -- declaring the private procedures
  PROCEDURE update_parameters ( p_demand_plan_id IN NUMBER, lv_parameter_id IN NUMBER,lv_parameter_type IN VARCHAR2,
                                lv_parameter_name IN VARCHAR2,lv_forecast_date_used IN VARCHAR2,lv_input_demand_plan_id IN NUMBER,
                                lv_input_scenario_id IN NUMBER,p_period_type IN NUMBER,p_number_of_periods IN NUMBER );
  PROCEDURE update_scenarios  (p_demand_plan_id IN NUMBER,lv_scenario_id IN NUMBER,lv_scenario_name VARCHAR2,
                               lv_exclude_flag IN VARCHAR2 ,p_period_type IN NUMBER, p_number_of_periods IN NUMBER);


  /*========================================================================================+
  | DESCRIPTION  : This procedure is called to roll forward the start and end dates of      |
  |                parameters and to attach the latest forecast version.                    |
  |                It also changes the parameter_name in msd_dp_scenarios table for latest  |
  |                forecasts versions attached.                                             |
  +========================================================================================*/

  PROCEDURE update_parameters ( p_demand_plan_id        IN   NUMBER,
                                lv_parameter_id         IN   NUMBER,
                                lv_parameter_type       IN  VARCHAR2,
                                lv_parameter_name       IN  VARCHAR2,
                                lv_forecast_date_used   IN  VARCHAR2,
                                lv_input_demand_plan_id IN   NUMBER,
                                lv_input_scenario_id    IN   NUMBER,
                                p_period_type           IN   NUMBER,
                                p_number_of_periods     IN   NUMBER ) AS

   lv_forecast_name         MSD_DP_SCENARIO_REVISIONS.REVISION_NAME%TYPE;

   -- This cursor is used to select the latest forecast version for the dynamic parameter of type input scenario.
   CURSOR latest_forecast_version IS
    SELECT revision_name
    FROM   msd_dp_scenario_revisions
    WHERE  scenario_id    =   lv_input_scenario_id
    AND demand_plan_id    =   lv_input_demand_plan_id
    AND revision          = (SELECT MAX (TO_NUMBER(revision))
                             FROM msd_dp_scenario_revisions
                             WHERE scenario_id   =  lv_input_scenario_id
                             AND demand_plan_id  =  lv_input_demand_plan_id)
    FOR UPDATE;

   BEGIN

     OPEN latest_forecast_version;
       FETCH latest_forecast_version into lv_forecast_name;

        UPDATE msd_dp_parameters
        SET    start_date       =  decode(p_period_type,G_DAY,(start_date + p_number_of_periods),G_WEEK,(start_date + p_number_of_periods*7),ADD_MONTHS(start_date,p_number_of_periods)),
               end_date         =  decode(p_period_type,G_DAY,(end_date + p_number_of_periods), G_WEEK, (end_date + p_number_of_periods*7), ADD_MONTHS(end_date,p_number_of_periods)) ,
               parameter_name   =  decode(lv_parameter_type,G_TYPE_INPUT_SCENARIO,(substr(parameter_name,1,instr( parameter_name,':',instr(parameter_name,':')+1))||lv_forecast_name),parameter_name)
        WHERE  parameter_id     =  lv_parameter_id;


        IF    ( lv_parameter_type= G_TYPE_INPUT_SCENARIO ) THEN
                   msc_st_util.log_message ('Rolled the parameter dates and attached the latest forecast for the parameter with parameter_id - '||lv_parameter_id||' and parameter_name - '||lv_parameter_name);
        ELSE
                  msc_st_util.log_message ('Rolled the parameter dates for the parameter with parameter_id - '||lv_parameter_id||' and parameter_name - '||lv_parameter_name);
        END IF;





        UPDATE  msd_dp_scenarios
        SET     parameter_name                    =  decode(lv_parameter_type,G_TYPE_INPUT_SCENARIO,(substr(parameter_name,1,instr( parameter_name,':',instr(parameter_name,':')+1))||lv_forecast_name),parameter_name)
        WHERE   nvl(parameter_name, NULL_CHAR )   =  nvl(lv_parameter_name, NULL_CHAR )
        AND     nvl(forecast_based_on,NULL_CHAR)  =  nvl(lv_parameter_type,NULL_CHAR)
        AND     nvl(forecast_date_used,NULL_CHAR) =  nvl(lv_forecast_date_used,NULL_CHAR)
        AND     demand_plan_id                    =  p_demand_plan_id;

        IF    ( SQL%NOTFOUND AND lv_parameter_type= G_TYPE_INPUT_SCENARIO ) THEN
                  msc_st_util.log_message ('No Change for the parameter_name for latest forecast version in msd_dp_scenarios table');
        ELSIF (   lv_parameter_type= G_TYPE_INPUT_SCENARIO ) THEN
                  msc_st_util.log_message ('Changed the parameter_name for latest forecast version in msd_dp_scenarios table');
        END IF;


     CLOSE latest_forecast_version;

    END update_parameters;

  /*========================================================================================+
  | DESCRIPTION  : This procedure is called to roll forward the scenario horizon periods    |
  |                (horizon start and end dates) and the scenario history periods(horizon   |
  |                start and end dates).                                                    |
  +========================================================================================*/

  PROCEDURE update_scenarios (p_demand_plan_id IN NUMBER,lv_scenario_id IN NUMBER,lv_scenario_name VARCHAR2,lv_exclude_flag IN VARCHAR2,p_period_type IN NUMBER, p_number_of_periods IN NUMBER) AS

  BEGIN


    UPDATE  msd_dp_scenarios
    SET     horizon_start_date   =   decode(nvl(lv_exclude_flag,'N'),'N',decode(p_period_type,G_DAY,(horizon_start_date +
    p_number_of_periods), G_WEEK, (horizon_start_date + p_number_of_periods*7), ADD_MONTHS(horizon_start_date,p_number_of_periods)),horizon_start_date),
            horizon_end_date     =   decode(nvl(lv_exclude_flag,'N'),'N',decode(p_period_type,G_DAY,(horizon_end_date + p_number_of_periods),
	    G_WEEK, (horizon_end_date + p_number_of_periods*7), ADD_MONTHS(horizon_end_date,p_number_of_periods)),horizon_end_date),
            history_start_date   =   decode(nvl(lv_exclude_flag,'N'),'N',decode(p_period_type,G_DAY,(history_start_date +
	    p_number_of_periods), G_WEEK, ( history_start_date + p_number_of_periods*7), ADD_MONTHS(history_start_date,p_number_of_periods)),history_start_date),
            history_end_date     =   decode(nvl(lv_exclude_flag,'N'),'N',decode(p_period_type,G_DAY,(history_end_date + p_number_of_periods),
	    G_WEEK, (history_end_date + p_number_of_periods*7), ADD_MONTHS(history_end_date,p_number_of_periods)),history_end_date)
    WHERE   scenario_id=lv_scenario_id;

    IF (( nvl(lv_exclude_flag,'N') = 'N') AND ( p_period_type = G_GREGORIAN_MONTH )) THEN
        UPDATE  msd_dp_scenarios
        SET  horizon_start_date = decode(trunc(horizon_start_date),trunc(history_end_date),horizon_start_date+1,horizon_start_date)
        WHERE   scenario_id=lv_scenario_id;
    END IF;


        IF ( nvl(lv_exclude_flag,'N')= 'N' ) THEN
                   msc_st_util.log_message ('Rolled the scenario history and horizon dates for the scenario with scenario_id - '||lv_scenario_id||' and scenario_name - '||lv_scenario_name);
        ELSE
                  msc_st_util.log_message ('Not Rolled the scenario history and horizon dates for the scenario with scenario_id - '||lv_scenario_id||' and scenario_name - '||lv_scenario_name);
        END IF;



  END update_scenarios;


  /*=============================================================================================+
  | DESCRIPTION  : This is the main program that calls the procedures to do the following:       |
  |                1. Roll forwards the parameter start and end dates.                           |
  |                2. Roll forwards the scenario horizon dates.                                  |
  |                3. Roll forwards the scenario history dates.                                  |
  |                4. Attaches the latest forecast Versions.                                     |
  |                   The procedure starts with invalidating the plan status                     |
  +=============================================================================================*/

  /*=============================================================================================+
  | The input parameters of the main procedure are:                                              |
  |                1. p_demand_plan_id      - Demand Plan ID for the plan to roll forward.       |
  |                2. p_period_type         - Period type to roll with(Day/Gregorian Month)      |
  |                3. p_number_of_periods   - Number of periods to roll with.                    |
  +=============================================================================================*/


  PROCEDURE launching_roll ( ERRBUF              OUT NOCOPY  VARCHAR2,
                             RETCODE             OUT NOCOPY  NUMBER,
                             p_demand_plan_id    IN     NUMBER,
                             p_period_type       IN     NUMBER,
                             p_number_of_periods IN     NUMBER ) AS


  lv_scenario_id            MSD_DP_SCENARIOS.SCENARIO_ID%TYPE;
  lv_scenario_name          MSD_DP_SCENARIOS.SCENARIO_NAME%TYPE;

  lv_parameter_type         MSD_DP_PARAMETERS.PARAMETER_TYPE%TYPE;
  lv_exclude_flag           MSD_DP_PARAMETERS.EXCLUDE_FROM_ROLLING_CYCLE%TYPE;
  lv_parameter_id           MSD_DP_PARAMETERS.PARAMETER_ID%TYPE;
  lv_parameter_name         MSD_DP_PARAMETERS.PARAMETER_NAME%TYPE;
  lv_input_demand_plan_id   MSD_DP_PARAMETERS.INPUT_DEMAND_PLAN_ID%TYPE;
  lv_input_scenario_id      MSD_DP_PARAMETERS.INPUT_SCENARIO_ID%TYPE;
  lv_forecast_date_used     MSD_DP_PARAMETERS.FORECAST_DATE_USED%TYPE;

 -- This cursor is used to select all the dynamic parameters.
  CURSOR parameters IS
    SELECT parameter_id,parameter_type,parameter_name,forecast_date_used,input_demand_plan_id,input_scenario_id
    FROM   msd_dp_parameters
    WHERE demand_plan_id= p_demand_plan_id
    AND nvl(exclude_from_rolling_cycle,'N') = 'N'
    FOR UPDATE ;

 -- This cursor is used to select all the scenarios that are attached to the demand plan.
  CURSOR scenarios IS
    SELECT s.scenario_id,s.scenario_name,p.exclude_from_rolling_cycle
    FROM   msd_dp_scenarios s, msd_dp_parameters p
    WHERE  s.demand_plan_id                   =   p_demand_plan_id
    AND    p.demand_plan_id                   =   p_demand_plan_id
    AND    nvl(s.parameter_name,NULL_CHAR)    =   nvl(p.parameter_name,NULL_CHAR)
    AND    nvl(s.forecast_based_on,NULL_CHAR) =   p.parameter_type
    AND nvl(s.forecast_date_used,NULL_CHAR)   =   nvl(p.forecast_date_used,NULL_CHAR)
    UNION ALL
    SELECT  s.scenario_id,s.scenario_name,'N'
    FROM    msd_dp_scenarios s
    WHERE   s.demand_plan_id          =    p_demand_plan_id
    AND     s.parameter_name         IS    NULL
    AND     s.forecast_based_on      IS    NULL
    AND s.forecast_date_used         IS    NULL;


 BEGIN


     -- invalidating the demand plan status
    UPDATE msd_demand_plans
    SET valid_flag= G_INVALID_PLAN
    WHERE demand_plan_id=p_demand_plan_id;
    COMMIT;

    -- rolling forward parameter start and end dates and attaching latest forecat version
    OPEN parameters;
       LOOP
        FETCH parameters INTO lv_parameter_id,lv_parameter_type,lv_parameter_name,lv_forecast_date_used,lv_input_demand_plan_id,lv_input_scenario_id ;
        EXIT WHEN parameters%NOTFOUND;
        update_parameters( p_demand_plan_id, lv_parameter_id,lv_parameter_type,lv_parameter_name,lv_forecast_date_used,lv_input_demand_plan_id,lv_input_scenario_id ,p_period_type, p_number_of_periods);
       END LOOP;
           msc_st_util.log_message ('************************Total number of parameters for which definition is modified ='||parameters%ROWCOUNT||'***********************');
    CLOSE parameters;

    --  rolling forward scenario history and horizon periods
    OPEN scenarios;
       LOOP
       FETCH scenarios INTO lv_scenario_id,lv_scenario_name,lv_exclude_flag;
       EXIT WHEN scenarios%NOTFOUND;
       update_scenarios( p_demand_plan_id, lv_scenario_id,lv_scenario_name,lv_exclude_flag, p_period_type,p_number_of_periods );
      END LOOP;
            msc_st_util.log_message ('************************Total number of scenarios for which definition is modified ='||scenarios%ROWCOUNT||'***********************');
    CLOSE scenarios;

    -- commiting all the changes
    COMMIT;
    msc_st_util.log_message ('Commiting all changes');


  EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK;
       ERRBUF  := SQLERRM;
       RETCODE := SQLCODE;
       v_errtxt := substr(SQLERRM,1,240) ;
       msc_st_util.log_message(v_errtxt);

  END launching_roll;

END msd_roll_demand_plan;

/
