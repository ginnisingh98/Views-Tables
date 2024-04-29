--------------------------------------------------------
--  DDL for Package Body PA_REP_UTIL_SCREEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_REP_UTIL_SCREEN" AS
/* $Header: PARRSCRB.pls 120.3.12010000.2 2009/05/29 12:53:00 nisinha ship $ */


  /*
   * Procedures.
   */

  PROCEDURE poplt_screen_tmp_table(
            p_Organization_ID           IN NUMBER
            , p_Manager_ID              IN NUMBER
            , p_Period_Type             IN VARCHAR2
            , p_Period_Year             IN NUMBER
            , p_Period_Quarter          IN NUMBER
            , p_Period_Name             IN VARCHAR2
            , p_Global_Week_End_Date    IN DATE
            , p_Assignment_Status       IN VARCHAR2
            , p_Show_Percentage_By      IN VARCHAR2
            , p_Utilization_Method      IN VARCHAR2
            , p_Utilization_Category_Id IN NUMBER
            , p_Calling_Mode            IN VARCHAR2
            )
  IS
  BEGIN

  delete from PA_REP_UTIL_SCREEN_TMP;


 /*
  * BEGINNING of Case 1 for U2
  * GE view
  */
     IF (p_Period_Type=PA_REP_UTIL_GLOB.GetPeriodTypeGe)  THEN

     INSERT INTO PA_REP_UTIL_SCREEN_TMP  (
        Organization_id
        , Person_id
        , Resource_id
        , Resource_Name
        , Resource_Type
        , Resource_Type_Code
        , Calling_Mode
        , Job_Level
        , Actuals_Capacity
        , Actuals_hours
        , Actuals_Weighted_hours
        , Actuals_Weighted_hours_P
        , Actuals_Cap_OR_Tot_Hrs
        , Forecast_Capacity
        , Forecast_hours
        , Forecast_Weighted_hours
        , Forecast_Weighted_hours_P
        , Forecast_Cap_OR_Tot_Hrs
        )
     SELECT
     DECODE(p_calling_mode
            , 'ORGMGR', paobj.expenditure_organization_id
            , 'RESMGR', NULL
            )                               AS ORGANIZATION_ID
     , resdnorm.person_id                   AS PERSON_ID
     , resdnorm.resource_id                 AS RESOURCE_ID
     , max(resdnorm.resource_name)          AS RESOURCE_NAME
     , max(lkup.meaning)                    AS RESOURCE_TYPE
     , max(resdnorm.resource_type)          AS RESOURCE_TYPE_CODE
     , p_Calling_Mode                       AS CALLING_MODE
     , max(resdnorm.resource_job_level)     AS JOB_LEVEL
 /*
  * Field below is for ACTUALS_CAPACITY
  */
     ,DECODE( p_Utilization_Category_ID, 0,(
      DECODE(
		  sign(
                   sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeActuals
                          , Decode(summbal.amount_type_id
                               , 9, NVL(summbal.period_balance,0)
                               , 0)
                      , 0))
                  -sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeActuals
                          , Decode(summbal.amount_type_id
                               , 10, NVL(summbal.period_balance,0)
                               , 0)
                      , 0)))
          , 1,
                  (sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeActuals
                          , Decode(summbal.amount_type_id
                               , 9, NVL(summbal.period_balance,0)
                               , 0)
                      , 0))
                  -sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeActuals
                          , Decode(summbal.amount_type_id
                               , 10, NVL(summbal.period_balance,0)
                               , 0)
                      , 0)))
          ,+0)),PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeActuals
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , max(summbal.period_type)
                   , max(summbal.period_set_name)
                   , max(summbal.period_name)
                   , max(summbal.global_exp_period_end_date)
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By
				   , p_organization_id)) AS ACTUALS_CAPACITY
  /*
  * Field below is for ACTUALS_HOURS
  */
     , sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeActuals
			  , Decode(summbal.amount_type_id
                   , 1, NVL(summbal.period_balance,0)
                   , 0)
          , 0))             AS ACTUALS_HOURS
 /*
  * Field below is for ACTUALS_WEIGHTED_HOURS
  */
     , sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeActuals
              , Decode(p_utilization_method
                   , 'ORGANIZATION'
                       , decode(summbal.amount_type_id
                            , 2, NVL(summbal.period_balance,0)
                            , 0)
                   , 'RESOURCE'
                       , decode(summbal.amount_type_id
                            , 3, NVL(summbal.period_balance,0)
                            , 0)
                   )
          , 0))                  AS ACTUALS_WEIGHTED_HOURS
 /*
  * Field below is for ACTUALS_WEIGHTED_HOURS_P
  */
     ,ROUND(NVL(sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeActuals
              , Decode(p_utilization_method
                   , 'ORGANIZATION'
                       , decode(summbal.amount_type_id
                            , 2, NVL(summbal.period_balance,0)
                            , 0)
                   , 'RESOURCE'
                       , decode(summbal.amount_type_id
                            , 3, NVL(summbal.period_balance,0)
                            , 0)
                   )
          , 0))*100/
       DECODE(p_Utilization_Category_Id
       ,0 , DECODE(p_Show_Percentage_By
            , 'CAPACITY'
              , DECODE(
                   sign(
                            sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   , 1,
                           (sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   ,1)
          , 'TOTAL_WORKED_HOURS'
              , DECODE(
                   sign(
                     sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeActuals
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0)))
                   , 1, sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeActuals
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0))
              , 1)
          )
       ,  PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeActuals
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , max(summbal.period_type)
                   , max(summbal.period_set_name)
                   , max(summbal.period_name)
                   , max(summbal.global_exp_period_end_date)
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By)
       )
        , -9999)    -- finished NVL
        , 0) AS ACTUALS_WEIGHTED_HOURS_P      -- finished rounding and concatenation
 /*
  * Field below is for ACTUALS_CAP_OR_TOT_HRS
  */
     , DECODE(p_Utilization_Category_Id
       ,0 , DECODE(p_Show_Percentage_By
            , 'CAPACITY'
              , DECODE(
                   sign(
                            sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   , 1,
                           (sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   ,1)
          , 'TOTAL_WORKED_HOURS'
              , DECODE(
                   sign(
                     sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeActuals
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0)))
                   , 1, sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeActuals
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0))
              , 1)
          )
       ,  PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeActuals
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , max(summbal.period_type)
                   , max(summbal.period_set_name)
                   , max(summbal.period_name)
                   , max(summbal.global_exp_period_end_date)
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By)
       )                           AS ACTUALS_CAP_OR_TOT_HRS
 /*
  * Field below is for FORECAST_CAPACITY
  */
     ,DECODE( p_Utilization_Category_ID, 0,(
      DECODE(
		  sign(
                   sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeForecast
                          , Decode(summbal.amount_type_id
                               , 9, NVL(summbal.period_balance,0)
                               , 0)
                      , 0))
                  -sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeForecast
                          , Decode(summbal.amount_type_id
                               , 10, NVL(summbal.period_balance,0)
                               , 0)
                      , 0)))
          , 1,
                  (sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeForecast
                          , Decode(summbal.amount_type_id
                               , 9, NVL(summbal.period_balance,0)
                               , 0)
                      , 0))
                  -sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeForecast
                          , Decode(summbal.amount_type_id
                               , 10, NVL(summbal.period_balance,0)
                               , 0)
                      , 0)))
          ,+0)),PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeForecast
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , max(summbal.period_type)
                   , max(summbal.period_set_name)
                   , max(summbal.period_name)
                   , max(summbal.global_exp_period_end_date)
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By
				   , p_organization_id)) AS FORECAST_CAPACITY
  /*
  * Field below is for FORECAST_HOURS
  */
     , sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , Decode(p_Assignment_Status
                   , 'ALL'
                       , decode(summbal.amount_type_id
                            , 1, NVL(summbal.period_balance,0)
                            , 0)
                   , 'PROVISIONAL'
                       , decode(summbal.amount_type_id
                            , 4, NVL(summbal.period_balance,0)
                            , 0)
                   , 'CONFIRMED'
                       , decode(summbal.amount_type_id
                            , 1, NVL(summbal.period_balance,0)
                            , 0)
              , 0)
          , 0))
      -sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , Decode(p_Assignment_Status
                   , 'CONFIRMED'
                       , decode(summbal.amount_type_id
                            , 4, NVL(summbal.period_balance,0)
                            , 0)
              , 0)
          , 0))             AS FORECAST_HOURS
 /*
  * Field below is for FORECAST_WEIGHTED_HOURS
  */
     , (sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , DecodE(p_Assignment_Status
                   , 'ALL'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 2, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 3, NVL(summbal.period_balance,0)
                                     , 0))
                   , 'PROVISIONAL'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 5, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 6, NVL(summbal.period_balance,0)
                                     , 0))
                   , 'CONFIRMED'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 2, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 3, NVL(summbal.period_balance,0)
                                     , 0))
                   )
          , 0))
      -sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , Decode(p_Assignment_Status
                   , 'CONFIRMED'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 5, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 6, NVL(summbal.period_balance,0)
                                     , 0))
                   , 0)
          , 0)))            AS FORECAST_WEIGHTED_HOURS
 /*
  * Field below is for FORECAST_WEIGHTED_HOURS_P
  */
     ,ROUND(NVL(
       (sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , DecodE(p_Assignment_Status
                   , 'ALL'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 2, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 3, NVL(summbal.period_balance,0)
                                     , 0))
                   , 'PROVISIONAL'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 5, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 6, NVL(summbal.period_balance,0)
                                     , 0))
                   , 'CONFIRMED'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 2, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 3, NVL(summbal.period_balance,0)
                                     , 0))
                   )
          , 0))
      -sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , Decode(p_Assignment_Status
                   , 'CONFIRMED'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 5, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 6, NVL(summbal.period_balance,0)
                                     , 0))
                   , 0)
          , 0)))
       *100/
       DECODE(p_Utilization_Category_Id
       ,0 , DECODE(p_Show_Percentage_By
            , 'CAPACITY'
              , DECODE(
                   sign(
                            sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   , 1,
                           (sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   ,1)
          , 'TOTAL_WORKED_HOURS'
              , DECODE(
                   sign(
                     sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeForecast
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0)))
                   , 1, sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeForecast
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0))
              , 1)
          )
       ,  PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeForecast
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , max(summbal.period_type)
                   , max(summbal.period_set_name)
                   , max(summbal.period_name)
                   , max(summbal.global_exp_period_end_date)
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By)
       )
        , -9999)    -- finished NVL
        , 0) AS FORECAST_WEIGHTED_HOURS_P      -- finished rounding
 /*
  * Field below is for FORECAST_CAP_OR_TOT_HRS
  */
     , DECODE(p_Utilization_Category_Id
       ,0 , DECODE(p_Show_Percentage_By
            , 'CAPACITY'
              , DECODE(
                   sign(
                            sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   , 1,
                           (sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   ,1)
          , 'TOTAL_WORKED_HOURS'
              , DECODE(
                   sign(
                     sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeForecast
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0)))
                   , 1, sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeForecast
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0))
              , 1)
          )
       ,  PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeForecast
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , max(summbal.period_type)
                   , max(summbal.period_set_name)
                   , max(summbal.period_name)
                   , max(summbal.global_exp_period_end_date)
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By)
       )                           AS FORECAST_CAP_OR_TOT_HRS
     from
         PA_Summ_Balances                 summbal
         , PA_Objects                     paobj
         , pa_resources_denorm            resdnorm
         , pa_lookups                     lkup
     where
		 lkup.lookup_type = 'PERSON_TYPE'
		 AND lkup.lookup_code = 'EMPLOYEE'
         AND NVL(resdnorm.manager_id,-1) = NVL(p_manager_id,NVL(resdnorm.manager_id,-1))
         AND (
			  (summbal.global_exp_period_end_date-6 between trunc(resdnorm.resource_effective_start_date) and trunc(NVL(resdnorm.resource_effective_end_date,summbal.global_exp_period_end_date-6))+0.99999
			  and p_calling_mode = 'ORGMGR')
            OR
/* Bug 2003821: start */
		  (
		   (
			  (trunc(SYSDATE) between trunc(resdnorm.resource_effective_start_date) and trunc(NVL(resdnorm.resource_effective_end_date,summbal.global_exp_period_end_date-6))+0.99999
                           and (summbal.global_exp_period_end_date-6) <= sysdate) /* Added for Bug 2325539 */
			  OR
			  (summbal.global_exp_period_end_date-6 between trunc(resdnorm.resource_effective_start_date) and trunc(NVL(resdnorm.resource_effective_end_date,summbal.global_exp_period_end_date-6))+0.99999
			  and (summbal.global_exp_period_end_date-6) > sysdate)
		   )
		   and p_calling_mode = 'RESMGR'
		  )
             )
/* Bug 2003821: end */
         AND summbal.object_id = paobj.object_id
         AND summbal.version_id = -1
         AND summbal.period_type = p_Period_Type
         AND summbal.period_set_name = PA_REP_UTIL_GLOB.GetDummy
         AND summbal.period_name = PA_REP_UTIL_GLOB.GetDummy
         AND summbal.global_exp_period_end_date = p_Global_Week_End_Date
         AND summbal.amount_type_id in (  1   /* G_RES_HRS_C              */
                                        , 2   /* G_RES_WTDHRS_ORG_C       */
                                        , 3   /* G_RES_WTDHRS_PEOPLE_C    */
                                        , 4   /* G_RES_PRVHRS_C           */
                                        , 5   /* G_RES_PRVWTDHRS_ORG_C    */
                                        , 6   /* G_RES_PRVWTDHRS_PEOPLE_C */
                                        , 9   /* G_RES_CAP_C              */
                                        ,10   /* G_RES_REDUCEDCAP_C       */
                                        )
         AND summbal.object_type_code = DECODE(p_Utilization_Category_Id
             , 0 , PA_REP_UTIL_GLOB.GetObjectTypeRes
             , Decode(p_Utilization_Method
                      , 'ORGANIZATION', PA_REP_UTIL_GLOB.GetObjectTypeResUco
                      , 'RESOURCE', PA_REP_UTIL_GLOB.GetObjectTypeResUcr))
         AND paobj.object_type_code = summbal.object_type_code
         AND paobj.expenditure_org_id = PA_REP_UTIL_GLOB.GetOrgId
         AND paobj.project_org_id              = -1
         AND paobj.expenditure_organization_id = NVL(p_organization_id,paobj.expenditure_organization_id)
         AND paobj.project_organization_id     = -1
         AND paobj.project_id                  = -1
         AND paobj.task_id                     = -1
         AND paobj.person_id = resdnorm.person_id
         AND resdnorm.utilization_flag = 'Y' /* Added for Bug#2765050 */
         AND paobj.assignment_id = -1
         AND paobj.work_type_id                = -1
         AND paobj.org_util_category_id    = DECODE(p_Utilization_Category_Id
             , 0, -1
             , Decode(p_Utilization_Method
                      , 'ORGANIZATION', p_Utilization_Category_Id
                      , 'RESOURCE', -1))
         AND paobj.res_util_category_id     = DECODE(p_Utilization_Category_Id
             , 0, -1
             , Decode(p_Utilization_Method
                      , 'ORGANIZATION', -1
                      , 'RESOURCE', p_Utilization_Category_Id))
         AND paobj.balance_type_code in (PA_REP_UTIL_GLOB.GetBalTypeActuals,PA_REP_UTIL_GLOB.GetBalTypeForecast)
   group by
     DECODE(p_calling_mode
            , 'ORGMGR', paobj.expenditure_organization_id
            , 'RESMGR', NULL
            )
           , resdnorm.person_id
           , resdnorm.resource_id
  ;
     END IF;
 /*
  * END of Case 1 for U2
  * p_Period_Type=PA_REP_UTIL_GLOB.GetPeriodTypeGe
  */
 /*
  * BEGINNING of Case 2 for U2
  * GL or PA view
  */
     IF (p_Period_Type=PA_REP_UTIL_GLOB.GetPeriodTypeGl   OR
         p_Period_Type=PA_REP_UTIL_GLOB.GetPeriodTypePa)  THEN

     INSERT INTO PA_REP_UTIL_SCREEN_TMP  (
        Organization_id
        , Person_id
        , Resource_id
        , Resource_Name
        , Resource_Type
        , Resource_Type_Code
        , Calling_Mode
        , Job_Level
        , Actuals_Capacity
        , Actuals_hours
        , Actuals_Weighted_hours
        , Actuals_Weighted_hours_P
        , Actuals_Cap_OR_Tot_Hrs
        , Forecast_Capacity
        , Forecast_hours
        , Forecast_Weighted_hours
        , Forecast_Weighted_hours_P
        , Forecast_Cap_OR_Tot_Hrs
        )
     SELECT
     DECODE(p_calling_mode
            , 'ORGMGR', paobj.expenditure_organization_id
            , 'RESMGR', NULL
            )                               AS ORGANIZATION_ID
     , resdnorm.person_id                   AS PERSON_ID
     , resdnorm.resource_id                 AS RESOURCE_ID
     , max(resdnorm.resource_name)          AS RESOURCE_NAME
     , max(lkup.meaning)                    AS RESOURCE_TYPE
     , max(resdnorm.resource_type)          AS RESOURCE_TYPE_CODE
     , p_Calling_Mode                       AS CALLING_MODE
     , max(resdnorm.resource_job_level)     AS JOB_LEVEL
 /*
  * Field below is for ACTUALS_CAPACITY
  */
     ,DECODE( p_Utilization_Category_ID, 0,(
      DECODE(
		  sign(
                   sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeActuals
                          , Decode(summbal.amount_type_id
                               , 9, NVL(summbal.period_balance,0)
                               , 0)
                      , 0))
                  -sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeActuals
                          , Decode(summbal.amount_type_id
                               , 10, NVL(summbal.period_balance,0)
                               , 0)
                      , 0)))
          , 1,
                  (sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeActuals
                          , Decode(summbal.amount_type_id
                               , 9, NVL(summbal.period_balance,0)
                               , 0)
                      , 0))
                  -sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeActuals
                          , Decode(summbal.amount_type_id
                               , 10, NVL(summbal.period_balance,0)
                               , 0)
                      , 0)))
          ,+0)),PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeActuals
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , max(summbal.period_type)
                   , max(summbal.period_set_name)
                   , max(summbal.period_name)
                   , max(summbal.global_exp_period_end_date)
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By
				   , p_organization_id)) AS ACTUALS_CAPACITY

 /*
  * Field below is for ACTUALS_HOURS
  */
     , sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeActuals
			  , Decode(summbal.amount_type_id
                   , 1, NVL(summbal.period_balance,0)
                   , 0)
          , 0))             AS ACTUALS_HOURS
 /*
  * Field below is for ACTUALS_WEIGHTED_HOURS
  */
     , sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeActuals
              , Decode(p_utilization_method
                   , 'ORGANIZATION'
                       , decode(summbal.amount_type_id
                            , 2, NVL(summbal.period_balance,0)
                            , 0)
                   , 'RESOURCE'
                       , decode(summbal.amount_type_id
                            , 3, NVL(summbal.period_balance,0)
                            , 0)
                   )
          , 0))                  AS ACTUALS_WEIGHTED_HOURS
 /*
  * Field below is for ACTUALS_WEIGHTED_HOURS_P
  */
     ,ROUND(NVL(sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeActuals
              , Decode(p_utilization_method
                   , 'ORGANIZATION'
                       , decode(summbal.amount_type_id
                            , 2, NVL(summbal.period_balance,0)
                            , 0)
                   , 'RESOURCE'
                       , decode(summbal.amount_type_id
                            , 3, NVL(summbal.period_balance,0)
                            , 0)
                   )
          , 0))*100/
       DECODE(p_Utilization_Category_Id
       ,0 , DECODE(p_Show_Percentage_By
            , 'CAPACITY'
              , DECODE(
                   sign(
                            sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   , 1,
                           (sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   ,1)
          , 'TOTAL_WORKED_HOURS'
              , DECODE(
                   sign(
                     sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeActuals
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0)))
                   , 1, sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeActuals
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0))
              , 1)
          )
       ,  PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeActuals
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , max(summbal.period_type)
                   , max(summbal.period_set_name)
                   , max(summbal.period_name)
                   , max(summbal.global_exp_period_end_date)
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By)
       )
        , -9999)    -- finished NVL
        , 0) AS ACTUALS_WEIGHTED_HOURS_P      -- finished rounding
 /*
  * Field below is for ACTUALS_CAP_OR_TOT_HRS
  */
     , DECODE(p_Utilization_Category_Id
       ,0 , DECODE(p_Show_Percentage_By
            , 'CAPACITY'
              , DECODE(
                   sign(
                            sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   , 1,
                           (sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   ,1)
          , 'TOTAL_WORKED_HOURS'
              , DECODE(
                   sign(
                     sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeActuals
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0)))
                   , 1, sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeActuals
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0))
              , 1)
          )
       ,  PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeActuals
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , max(summbal.period_type)
                   , max(summbal.period_set_name)
                   , max(summbal.period_name)
                   , max(summbal.global_exp_period_end_date)
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By)
       )                           AS ACTUALS_CAP_OR_TOT_HRS
 /*
  * Field below is for FORECAST_CAPACITY
  */
     ,DECODE( p_Utilization_Category_ID, 0,(
      DECODE(
		  sign(
                   sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeForecast
                          , Decode(summbal.amount_type_id
                               , 9, NVL(summbal.period_balance,0)
                               , 0)
                      , 0))
                  -sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeForecast
                          , Decode(summbal.amount_type_id
                               , 10, NVL(summbal.period_balance,0)
                               , 0)
                      , 0)))
          , 1,
                  (sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeForecast
                          , Decode(summbal.amount_type_id
                               , 9, NVL(summbal.period_balance,0)
                               , 0)
                      , 0))
                  -sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeForecast
                          , Decode(summbal.amount_type_id
                               , 10, NVL(summbal.period_balance,0)
                               , 0)
                      , 0)))
          ,+0)),PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeForecast
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , max(summbal.period_type)
                   , max(summbal.period_set_name)
                   , max(summbal.period_name)
                   , max(summbal.global_exp_period_end_date)
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By
				   , p_organization_id)) AS FORECAST_CAPACITY
 /*
  * Field below is for FORECAST_HOURS
  */
     , sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , Decode(p_Assignment_Status
                   , 'ALL'
                       , decode(summbal.amount_type_id
                            , 1, NVL(summbal.period_balance,0)
                            , 0)
                   , 'PROVISIONAL'
                       , decode(summbal.amount_type_id
                            , 4, NVL(summbal.period_balance,0)
                            , 0)
                   , 'CONFIRMED'
                       , decode(summbal.amount_type_id
                            , 1, NVL(summbal.period_balance,0)
                            , 0)
              , 0)
          , 0))
      -sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , Decode(p_Assignment_Status
                   , 'CONFIRMED'
                       , decode(summbal.amount_type_id
                            , 4, NVL(summbal.period_balance,0)
                            , 0)
              , 0)
          , 0))             AS FORECAST_HOURS
 /*
  * Field below is for FORECAST_WEIGHTED_HOURS
  */
     , (sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , DecodE(p_Assignment_Status
                   , 'ALL'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 2, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 3, NVL(summbal.period_balance,0)
                                     , 0))
                   , 'PROVISIONAL'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 5, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 6, NVL(summbal.period_balance,0)
                                     , 0))
                   , 'CONFIRMED'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 2, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 3, NVL(summbal.period_balance,0)
                                     , 0))
                   )
          , 0))
      -sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , Decode(p_Assignment_Status
                   , 'CONFIRMED'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 5, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 6, NVL(summbal.period_balance,0)
                                     , 0))
                   , 0)
          , 0)))            AS FORECAST_WEIGHTED_HOURS
 /*
  * Field below is for FORECAST_WEIGHTED_HOURS_P
  */
     ,ROUND(NVL(
       (sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , DecodE(p_Assignment_Status
                   , 'ALL'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 2, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 3, NVL(summbal.period_balance,0)
                                     , 0))
                   , 'PROVISIONAL'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 5, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 6, NVL(summbal.period_balance,0)
                                     , 0))
                   , 'CONFIRMED'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 2, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 3, NVL(summbal.period_balance,0)
                                     , 0))
                   )
          , 0))
      -sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , Decode(p_Assignment_Status
                   , 'CONFIRMED'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 5, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 6, NVL(summbal.period_balance,0)
                                     , 0))
                   , 0)
          , 0)))
       *100/
       DECODE(p_Utilization_Category_Id
       ,0 , DECODE(p_Show_Percentage_By
            , 'CAPACITY'
              , DECODE(
                   sign(
                            sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   , 1,
                           (sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   ,1)
          , 'TOTAL_WORKED_HOURS'
              , DECODE(
                   sign(
                     sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeForecast
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0)))
                   , 1, sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeForecast
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0))
              , 1)
          )
       ,  PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeForecast
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , max(summbal.period_type)
                   , max(summbal.period_set_name)
                   , max(summbal.period_name)
                   , max(summbal.global_exp_period_end_date)
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By)
       )
        , -9999)    -- finished NVL
        , 0) AS FORECAST_WEIGHTED_HOURS_P      -- finished rounding and concatenation
 /*
  * Field below is for FORECAST_CAP_OR_TOT_HRS
  */
     , DECODE(p_Utilization_Category_Id
       ,0 , DECODE(p_Show_Percentage_By
            , 'CAPACITY'
              , DECODE(
                   sign(
                            sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   , 1,
                           (sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   ,1)
          , 'TOTAL_WORKED_HOURS'
              , DECODE(
                   sign(
                     sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeForecast
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0)))
                   , 1, sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeForecast
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0))
              , 1)
          )
       ,  PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeForecast
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , max(summbal.period_type)
                   , max(summbal.period_set_name)
                   , max(summbal.period_name)
                   , max(summbal.global_exp_period_end_date)
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By)
       )                           AS FORECAST_CAP_OR_TOT_HRS
     from
         PA_Summ_Balances                 summbal
         , PA_Objects                     paobj
         , pa_resources_denorm            resdnorm
         , gl_periods                     glprd
         , pa_lookups                     lkup
     where
		 lkup.lookup_type = 'PERSON_TYPE'
		 AND lkup.lookup_code = 'EMPLOYEE'
         AND NVL(resdnorm.manager_id,-1) = NVL(p_manager_id,NVL(resdnorm.manager_id,-1))
         AND (
			  (glprd.start_date between trunc(resdnorm.resource_effective_start_date) and trunc(NVL(resdnorm.resource_effective_end_date,glprd.start_date))+0.99999
			  and p_calling_mode = 'ORGMGR')
            OR
/* Bug 2003821: start */
		  (
		   (
			  (trunc(SYSDATE) between trunc(resdnorm.resource_effective_start_date) and trunc(NVL(resdnorm.resource_effective_end_date,trunc(sysdate)))+0.99999
                           and glprd.start_date <=sysdate) /* Added for Bug 2325539 */
			  OR
			  (glprd.start_date between trunc(resdnorm.resource_effective_start_date) and trunc(NVL(resdnorm.resource_effective_end_date,glprd.start_date))+0.99999
			  and glprd.start_date > sysdate)
		   )
		   and p_calling_mode = 'RESMGR'
		  )
             )
/* Bug 2003821: end */
         AND glprd.period_set_name = summbal.period_set_name
         AND glprd.period_name = summbal.period_name
         AND summbal.object_id = paobj.object_id
         AND summbal.version_id = -1
         AND summbal.period_type = p_Period_Type
         AND summbal.period_set_name = PA_REP_UTIL_GLOB.GetPeriodSetName
         AND summbal.period_name = p_Period_Name
         AND summbal.amount_type_id in (  1   /* G_RES_HRS_C              */
                                        , 2   /* G_RES_WTDHRS_ORG_C       */
                                        , 3   /* G_RES_WTDHRS_PEOPLE_C    */
                                        , 4   /* G_RES_PRVHRS_C           */
                                        , 5   /* G_RES_PRVWTDHRS_ORG_C    */
                                        , 6   /* G_RES_PRVWTDHRS_PEOPLE_C */
                                        , 9   /* G_RES_CAP_C              */
                                        ,10   /* G_RES_REDUCEDCAP_C       */
                                        )
         AND summbal.object_type_code = DECODE(p_Utilization_Category_Id
             , 0, PA_REP_UTIL_GLOB.GetObjectTypeRes
             , Decode(p_Utilization_Method
                      , 'ORGANIZATION', PA_REP_UTIL_GLOB.GetObjectTypeResUco
                      , 'RESOURCE', PA_REP_UTIL_GLOB.GetObjectTypeResUcr))
         AND paobj.object_type_code = summbal.object_type_code
         AND paobj.expenditure_org_id = PA_REP_UTIL_GLOB.GetOrgId
         AND paobj.project_org_id              = -1
         AND paobj.expenditure_organization_id = NVL(p_organization_id,paobj.expenditure_organization_id)
         AND paobj.project_organization_id     = -1
         AND paobj.project_id                  = -1
         AND paobj.task_id                     = -1
         AND paobj.person_id = resdnorm.person_id
         AND resdnorm.utilization_flag = 'Y' /* Added for Bug#2765050 */
         AND paobj.assignment_id = -1
         AND paobj.work_type_id                = -1
         AND paobj.org_util_category_id     = DECODE(p_Utilization_Category_Id
             , 0, -1
             , Decode(p_Utilization_Method
                      , 'ORGANIZATION', p_Utilization_Category_Id
                      , 'RESOURCE', -1))
         AND paobj.res_util_category_id     = DECODE(p_Utilization_Category_Id
             , 0, -1
             , Decode(p_Utilization_Method
                      , 'ORGANIZATION', -1
                      , 'RESOURCE', p_Utilization_Category_Id))
         AND paobj.balance_type_code in (PA_REP_UTIL_GLOB.GetBalTypeActuals,PA_REP_UTIL_GLOB.GetBalTypeForecast)
   group by
     DECODE(p_calling_mode
            , 'ORGMGR', paobj.expenditure_organization_id
            , 'RESMGR', NULL
            )
           , resdnorm.person_id
           , resdnorm.resource_id
  ;
     END IF;
 /*
  * END of Case 2 for U2
  * p_Period_Type=PA_REP_UTIL_GLOB.GetPeriodTypeGl or Pa
  */
 /*
  * BEGINNING of Case 3 for U2
  * QR view
  */
      IF (p_Period_Type=PA_REP_UTIL_GLOB.GetPeriodTypeQr)  THEN

     INSERT INTO PA_REP_UTIL_SCREEN_TMP  (
        Organization_id
        , Person_id
        , Resource_id
        , Resource_Name
        , Resource_Type
        , Resource_Type_Code
        , Calling_Mode
        , Job_Level
        , Actuals_Capacity
        , Actuals_hours
        , Actuals_Weighted_hours
        , Actuals_Weighted_hours_P
        , Actuals_Cap_OR_Tot_Hrs
        , Forecast_Capacity
        , Forecast_hours
        , Forecast_Weighted_hours
        , Forecast_Weighted_hours_P
        , Forecast_Cap_OR_Tot_Hrs
        )
     SELECT
     DECODE(p_calling_mode
            , 'ORGMGR', paobj.expenditure_organization_id
            , 'RESMGR', NULL
            )                               AS ORGANIZATION_ID
     , resdnorm.person_id                   AS PERSON_ID
     , resdnorm.resource_id                 AS RESOURCE_ID
     , max(resdnorm.resource_name)          AS RESOURCE_NAME
     , max(lkup.meaning)                    AS RESOURCE_TYPE
     , max(resdnorm.resource_type)          AS RESOURCE_TYPE_CODE
     , p_Calling_Mode                       AS CALLING_MODE
     , max(resdnorm.resource_job_level)     AS JOB_LEVEL
 /*
  * Field below is for ACTUALS_CAPACITY
  */
     ,DECODE( p_Utilization_Category_ID, 0,(
      DECODE(
		  sign(
                   sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeActuals
                          , Decode(summbal.amount_type_id
                               , 9, NVL(summbal.period_balance,0)
                               , 0)
                      , 0))
                  -sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeActuals
                          , Decode(summbal.amount_type_id
                               , 10, NVL(summbal.period_balance,0)
                               , 0)
                      , 0)))
          , 1,
                  (sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeActuals
                          , Decode(summbal.amount_type_id
                               , 9, NVL(summbal.period_balance,0)
                               , 0)
                      , 0))
                  -sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeActuals
                          , Decode(summbal.amount_type_id
                               , 10, NVL(summbal.period_balance,0)
                               , 0)
                      , 0)))
          ,+0)),PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeActuals
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , PA_REP_UTIL_GLOB.GetPeriodTypeQr
                   , null
                   , null
                   , null
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By
				   , p_organization_id
				   , max(summbal.period_year)
				   , max(quarter_or_month_number))) AS ACTUALS_CAPACITY
 /*
  * Field below is for ACTUALS_HOURS
  */
     , sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeActuals
			  , Decode(summbal.amount_type_id
                   , 1, NVL(summbal.period_balance,0)
                   , 0)
          , 0))             AS ACTUALS_HOURS
 /*
  * Field below is for ACTUALS_WEIGHTED_HOURS
  */
     , sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeActuals
              , Decode(p_utilization_method
                   , 'ORGANIZATION'
                       , decode(summbal.amount_type_id
                            , 2, NVL(summbal.period_balance,0)
                            , 0)
                   , 'RESOURCE'
                       , decode(summbal.amount_type_id
                            , 3, NVL(summbal.period_balance,0)
                            , 0)
                   )
          , 0))                  AS ACTUALS_WEIGHTED_HOURS
 /*
  * Field below is for ACTUALS_WEIGHTED_HOURS_P
  */
     ,ROUND(NVL(sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeActuals
              , Decode(p_utilization_method
                   , 'ORGANIZATION'
                       , decode(summbal.amount_type_id
                            , 2, NVL(summbal.period_balance,0)
                            , 0)
                   , 'RESOURCE'
                       , decode(summbal.amount_type_id
                            , 3, NVL(summbal.period_balance,0)
                            , 0)
                   )
          , 0))*100/
       DECODE(p_Utilization_Category_Id
       ,0 , DECODE(p_Show_Percentage_By
            , 'CAPACITY'
              , DECODE(
                   sign(
                            sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   , 1,
                           (sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   ,1)
          , 'TOTAL_WORKED_HOURS'
              , DECODE(
                   sign(
                     sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeActuals
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0)))
                   , 1, sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeActuals
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0))
              , 1)
          )
       ,  PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeActuals
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , PA_REP_UTIL_GLOB.GetPeriodTypeQr --Bug 8528649 Start changes for Quarter
                   , null
                   , null
                   , null
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By
                   , p_Organization_ID
                   , p_Period_Year
                   , p_Period_Quarter)  --Bug 8528649 End changes for Quarter
       )
        , -9999)    -- finished NVL
        , 0)  AS ACTUALS_WEIGHTED_HOURS_P      -- finished rounding and concatenation
 /*
  * Field below is for ACTUALS_CAP_OR_TOT_HRS
  */
     , DECODE(p_Utilization_Category_Id
       ,0 , DECODE(p_Show_Percentage_By
            , 'CAPACITY'
              , DECODE(
                   sign(
                            sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   , 1,
                           (sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   ,1)
          , 'TOTAL_WORKED_HOURS'
              , DECODE(
                   sign(
                     sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeActuals
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0)))
                   , 1, sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeActuals
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0))
              , 1)
          )
       ,  PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeActuals
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , PA_REP_UTIL_GLOB.GetPeriodTypeQr --Bug 8528649 Start changes for Quarter
                   , null
                   , null
                   , null
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By
                   , p_Organization_ID
                   , p_Period_Year
                   , p_Period_Quarter) --Bug 8528649 End changes for Quarter
       )                           AS ACTUALS_CAP_OR_TOT_HRS
 /*
  * Field below is for FORECAST_CAPACITY
  */
     ,DECODE( p_Utilization_Category_ID, 0,(
      DECODE(
		  sign(
                   sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeForecast
                          , Decode(summbal.amount_type_id
                               , 9, NVL(summbal.period_balance,0)
                               , 0)
                      , 0))
                  -sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeForecast
                          , Decode(summbal.amount_type_id
                               , 10, NVL(summbal.period_balance,0)
                               , 0)
                      , 0)))
          , 1,
                  (sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeForecast
                          , Decode(summbal.amount_type_id
                               , 9, NVL(summbal.period_balance,0)
                               , 0)
                      , 0))
                  -sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeForecast
                          , Decode(summbal.amount_type_id
                               , 10, NVL(summbal.period_balance,0)
                               , 0)
                      , 0)))
          ,+0)),PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeForecast
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , PA_REP_UTIL_GLOB.GetPeriodTypeQr
                   , null
                   , null
                   , null
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By
				   , p_organization_id
				   , max(summbal.period_year)
				   , max(quarter_or_month_number))) AS FORECAST_CAPACITY
 /*
  * Field below is for FORECAST_HOURS
  */
     , sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , Decode(p_Assignment_Status
                   , 'ALL'
                       , decode(summbal.amount_type_id
                            , 1, NVL(summbal.period_balance,0)
                            , 0)
                   , 'PROVISIONAL'
                       , decode(summbal.amount_type_id
                            , 4, NVL(summbal.period_balance,0)
                            , 0)
                   , 'CONFIRMED'
                       , decode(summbal.amount_type_id
                            , 1, NVL(summbal.period_balance,0)
                            , 0)
              , 0)
          , 0))
      -sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , Decode(p_Assignment_Status
                   , 'CONFIRMED'
                       , decode(summbal.amount_type_id
                            , 4, NVL(summbal.period_balance,0)
                            , 0)
              , 0)
          , 0))             AS FORECAST_HOURS
 /*
  * Field below is for FORECAST_WEIGHTED_HOURS
  */
     , (sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , DecodE(p_Assignment_Status
                   , 'ALL'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 2, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 3, NVL(summbal.period_balance,0)
                                     , 0))
                   , 'PROVISIONAL'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 5, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 6, NVL(summbal.period_balance,0)
                                     , 0))
                   , 'CONFIRMED'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 2, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 3, NVL(summbal.period_balance,0)
                                     , 0))
                   )
          , 0))
      -sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , Decode(p_Assignment_Status
                   , 'CONFIRMED'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 5, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 6, NVL(summbal.period_balance,0)
                                     , 0))
                   , 0)
          , 0)))            AS FORECAST_WEIGHTED_HOURS
 /*
  * Field below is for FORECAST_WEIGHTED_HOURS_P
  */
     ,ROUND(NVL(
       (sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , DecodE(p_Assignment_Status
                   , 'ALL'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 2, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 3, NVL(summbal.period_balance,0)
                                     , 0))
                   , 'PROVISIONAL'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 5, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 6, NVL(summbal.period_balance,0)
                                     , 0))
                   , 'CONFIRMED'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 2, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 3, NVL(summbal.period_balance,0)
                                     , 0))
                   )
          , 0))
      -sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , Decode(p_Assignment_Status
                   , 'CONFIRMED'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 5, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 6, NVL(summbal.period_balance,0)
                                     , 0))
                   , 0)
          , 0)))
       *100/
       DECODE(p_Utilization_Category_Id
       ,0 , DECODE(p_Show_Percentage_By
            , 'CAPACITY'
              , DECODE(
                   sign(
                            sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   , 1,
                           (sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   ,1)
          , 'TOTAL_WORKED_HOURS'
              , DECODE(
                   sign(
                     sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeForecast
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0)))
                   , 1, sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeForecast
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0))
              , 1)
          )
       ,  PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeForecast
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , PA_REP_UTIL_GLOB.GetPeriodTypeQr  --Bug 8528649 Start changes for Quarter
                   , null
                   , null
                   , null
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By
                   , p_Organization_ID
                   , p_Period_Year
                   , p_Period_Quarter)  --Bug 8528649 End changes for Quarter
       )
        , -9999)    -- finished NVL
        , 0) AS FORECAST_WEIGHTED_HOURS_P      -- finished rounding and concatenation
 /*
  * Field below is for FORECAST_CAP_OR_TOT_HRS
  */
     , DECODE(p_Utilization_Category_Id
       ,0 , DECODE(p_Show_Percentage_By
            , 'CAPACITY'
              , DECODE(
                   sign(
                            sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   , 1,
                           (sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   ,1)
          , 'TOTAL_WORKED_HOURS'
              , DECODE(
                   sign(
                     sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeForecast
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0)))
                   , 1, sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeForecast
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0))
              , 1)
          )
       ,  PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeForecast
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , PA_REP_UTIL_GLOB.GetPeriodTypeQr  --Bug 8528649 Start changes for Quarter
                   , null
                   , null
                   , null
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By
                   , p_Organization_ID
                   , p_Period_Year
                   , p_Period_Quarter)  --Bug 8528649 End changes for Quarter
       )                           AS FORECAST_CAP_OR_TOT_HRS
     from
         PA_Summ_Balances                 summbal
         , PA_Objects                     paobj
         , pa_resources_denorm            resdnorm
         , gl_periods                     glprd
         , pa_lookups                     lkup
     where
		 lkup.lookup_type = 'PERSON_TYPE'
		 AND lkup.lookup_code = 'EMPLOYEE'
         AND NVL(resdnorm.manager_id,-1) = NVL(p_manager_id,NVL(resdnorm.manager_id,-1))
         AND (
			  (glprd.start_date between trunc(resdnorm.resource_effective_start_date) and trunc(NVL(resdnorm.resource_effective_end_date,glprd.end_date))+0.99999
			  and p_calling_mode = 'ORGMGR')
            OR
/* Bug 2003821: start */
		  (
		   (
			  (trunc(SYSDATE) between trunc(resdnorm.resource_effective_start_date) and trunc(NVL(resdnorm.resource_effective_end_date,trunc(sysdate)))+0.99999
                            and glprd.start_date <=sysdate)  /* Added for Bug 2325539 */
			  OR
			  (glprd.start_date between trunc(resdnorm.resource_effective_start_date) and trunc(NVL(resdnorm.resource_effective_end_date,glprd.end_date))+0.99999
			  and glprd.start_date > sysdate)
		   )
		   and p_calling_mode = 'RESMGR'
		  )
             )
/* Bug 2003821: end */
         AND glprd.period_set_name = summbal.period_set_name
         AND glprd.period_name = summbal.period_name
         AND summbal.object_id = paobj.object_id
         AND summbal.version_id = -1
         AND summbal.period_type = PA_REP_UTIL_GLOB.GetPeriodTypeGl
         AND summbal.period_set_name = PA_REP_UTIL_GLOB.GetPeriodSetName
         AND summbal.period_year = p_Period_Year
         AND summbal.quarter_or_month_number = p_Period_Quarter
         AND summbal.amount_type_id in (  1   /* G_RES_HRS_C              */
                                        , 2   /* G_RES_WTDHRS_ORG_C       */
                                        , 3   /* G_RES_WTDHRS_PEOPLE_C    */
                                        , 4   /* G_RES_PRVHRS_C           */
                                        , 5   /* G_RES_PRVWTDHRS_ORG_C    */
                                        , 6   /* G_RES_PRVWTDHRS_PEOPLE_C */
                                        , 9   /* G_RES_CAP_C              */
                                        ,10   /* G_RES_REDUCEDCAP_C       */
                                        )
         AND summbal.object_type_code = DECODE(p_Utilization_Category_Id
             , 0, PA_REP_UTIL_GLOB.GetObjectTypeRes
             , Decode(p_Utilization_Method
                      , 'ORGANIZATION', PA_REP_UTIL_GLOB.GetObjectTypeResUco
                      , 'RESOURCE', PA_REP_UTIL_GLOB.GetObjectTypeResUcr))
         AND paobj.object_type_code = summbal.object_type_code
         AND paobj.expenditure_org_id = PA_REP_UTIL_GLOB.GetOrgId
         AND paobj.project_org_id              = -1
         AND paobj.expenditure_organization_id = NVL(p_organization_id,paobj.expenditure_organization_id)
         AND paobj.project_organization_id     = -1
         AND paobj.project_id                  = -1
         AND paobj.task_id                     = -1
         AND paobj.person_id = resdnorm.person_id
         AND resdnorm.utilization_flag = 'Y' /* Added for Bug#2765050 */
         AND paobj.assignment_id = -1
         AND paobj.work_type_id                = -1
         AND paobj.org_util_category_id     = DECODE(p_Utilization_Category_Id
             , 0, -1
             , Decode(p_Utilization_Method
                      , 'ORGANIZATION', p_Utilization_Category_Id
                      , 'RESOURCE', -1))
         AND paobj.res_util_category_id     = DECODE(p_Utilization_Category_Id
             , 0, -1
             , Decode(p_Utilization_Method
                      , 'ORGANIZATION', -1
                      , 'RESOURCE', p_Utilization_Category_Id))
         AND paobj.balance_type_code in (PA_REP_UTIL_GLOB.GetBalTypeActuals,PA_REP_UTIL_GLOB.GetBalTypeForecast)
   group by
     DECODE(p_calling_mode
            , 'ORGMGR', paobj.expenditure_organization_id
            , 'RESMGR', NULL
            )
           , resdnorm.person_id
           , resdnorm.resource_id
  ;
     END IF;

 /*
  * END of Case 3 for U2
  * p_Period_Type=PA_REP_UTIL_GLOB.GetPeriodTypeQr
  */
 /*
  * BEGINNING of Case 4 for U2
  * YR view
  */
     IF (p_Period_Type=PA_REP_UTIL_GLOB.GetPeriodTypeYr)  THEN

     INSERT INTO PA_REP_UTIL_SCREEN_TMP  (
        Organization_id
        , Person_id
        , Resource_id
        , Resource_Name
        , Resource_Type
        , Resource_Type_Code
        , Calling_Mode
        , Job_Level
        , Actuals_Capacity
        , Actuals_hours
        , Actuals_Weighted_hours
        , Actuals_Weighted_hours_P
        , Actuals_Cap_OR_Tot_Hrs
        , Forecast_Capacity
        , Forecast_hours
        , Forecast_Weighted_hours
        , Forecast_Weighted_hours_P
        , Forecast_Cap_OR_Tot_Hrs
        )
     SELECT
     DECODE(p_calling_mode
            , 'ORGMGR', paobj.expenditure_organization_id
            , 'RESMGR', NULL
            )                               AS ORGANIZATION_ID
     , resdnorm.person_id                   AS PERSON_ID
     , resdnorm.resource_id                 AS RESOURCE_ID
     , max(resdnorm.resource_name)          AS RESOURCE_NAME
     , max(lkup.meaning)                    AS RESOURCE_TYPE
     , max(resdnorm.resource_type)          AS RESOURCE_TYPE_CODE
     , p_Calling_Mode                       AS CALLING_MODE
     , max(resdnorm.resource_job_level)     AS JOB_LEVEL
 /*
  * Field below is for ACTUALS_CAPACITY
  */
     ,DECODE( p_Utilization_Category_ID, 0,(
      DECODE(
		  sign(
                   sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeActuals
                          , Decode(summbal.amount_type_id
                               , 9, NVL(summbal.period_balance,0)
                               , 0)
                      , 0))
                  -sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeActuals
                          , Decode(summbal.amount_type_id
                               , 10, NVL(summbal.period_balance,0)
                               , 0)
                      , 0)))
          , 1,
                  (sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeActuals
                          , Decode(summbal.amount_type_id
                               , 9, NVL(summbal.period_balance,0)
                               , 0)
                      , 0))
                  -sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeActuals
                          , Decode(summbal.amount_type_id
                               , 10, NVL(summbal.period_balance,0)
                               , 0)
                      , 0)))
          ,+0)),PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeActuals
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , PA_REP_UTIL_GLOB.GetPeriodTypeYr
                   , null
                   , null
                   , null
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By
				   , p_organization_id
				   , max(summbal.period_year))) AS ACTUALS_CAPACITY
 /*
  * Field below is for ACTUALS_HOURS
  */
     , sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeActuals
			  , Decode(summbal.amount_type_id
                   , 1, NVL(summbal.period_balance,0)
                   , 0)
          , 0))             AS ACTUALS_HOURS
 /*
  * Field below is for ACTUALS_WEIGHTED_HOURS
  */
     , sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeActuals
              , Decode(p_utilization_method
                   , 'ORGANIZATION'
                       , decode(summbal.amount_type_id
                            , 2, NVL(summbal.period_balance,0)
                            , 0)
                   , 'RESOURCE'
                       , decode(summbal.amount_type_id
                            , 3, NVL(summbal.period_balance,0)
                            , 0)
                   )
          , 0))                  AS ACTUALS_WEIGHTED_HOURS
 /*
  * Field below is for ACTUALS_WEIGHTED_HOURS_P
  */
     ,ROUND(NVL(sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeActuals
              , Decode(p_utilization_method
                   , 'ORGANIZATION'
                       , decode(summbal.amount_type_id
                            , 2, NVL(summbal.period_balance,0)
                            , 0)
                   , 'RESOURCE'
                       , decode(summbal.amount_type_id
                            , 3, NVL(summbal.period_balance,0)
                            , 0)
                   )
          , 0))*100/
       DECODE(p_Utilization_Category_Id
       ,0 , DECODE(p_Show_Percentage_By
            , 'CAPACITY'
              , DECODE(
                   sign(
                            sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   , 1,
                           (sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   ,1)
          , 'TOTAL_WORKED_HOURS'
              , DECODE(
                   sign(
                     sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeActuals
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0)))
                   , 1, sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeActuals
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0))
              , 1)
          )
       ,  PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeActuals
                   , max(paobj.person_id)
                   , max(summbal.version_id)   /*8528649 changes for actuals_weighted_hours_p*/
                   , PA_REP_UTIL_GLOB.GetPeriodTypeYr
                   , NULL
                   , NULL
                   , NULL
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By
                   , p_organization_id
                   , p_period_year)
       )
        , -9999)    -- finished NVL
        , 0) AS ACTUALS_WEIGHTED_HOURS_P      -- finished rounding and concatenation
 /*
  * Field below is for ACTUALS_CAP_OR_TOT_HRS
  */
     , DECODE(p_Utilization_Category_Id
       ,0 , DECODE(p_Show_Percentage_By
            , 'CAPACITY'
              , DECODE(
                   sign(
                            sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   , 1,
                           (sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeActuals
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   ,1)
          , 'TOTAL_WORKED_HOURS'
              , DECODE(
                   sign(
                     sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeActuals
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0)))
                   , 1, sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeActuals
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0))
              , 1)
          )
       ,  PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeActuals
                   , max(paobj.person_id)
                   , max(summbal.version_id)  /*8528649 changes for ACTUALS_CAP_OR_TOT_HRS*/
                   , PA_REP_UTIL_GLOB.GetPeriodTypeYr
                   , NULL
                   , NULL
                   , NULL
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By
                   , p_organization_id
                   ,p_period_year)
       )                           AS ACTUALS_CAP_OR_TOT_HRS
 /*
  * Field below is for FORECAST_CAPACITY
  */
     ,DECODE( p_Utilization_Category_ID, 0,(
      DECODE(
		  sign(
                   sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeForecast
                          , Decode(summbal.amount_type_id
                               , 9, NVL(summbal.period_balance,0)
                               , 0)
                      , 0))
                  -sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeForecast
                          , Decode(summbal.amount_type_id
                               , 10, NVL(summbal.period_balance,0)
                               , 0)
                      , 0)))
          , 1,
                  (sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeForecast
                          , Decode(summbal.amount_type_id
                               , 9, NVL(summbal.period_balance,0)
                               , 0)
                      , 0))
                  -sum(
                   DecodE(paobj.balance_type_code
                      , PA_REP_UTIL_GLOB.GetBalTypeForecast
                          , Decode(summbal.amount_type_id
                               , 10, NVL(summbal.period_balance,0)
                               , 0)
                      , 0)))
          ,+0)),PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeForecast
                   , max(paobj.person_id)
                   , max(summbal.version_id)
                   , PA_REP_UTIL_GLOB.GetPeriodTypeYr
                   , null
                   , null
                   , null
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By
				   , p_organization_id
				   , max(summbal.period_year))) AS FORECAST_CAPACITY
 /*
  * Field below is for FORECAST_HOURS
  */
     , sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , Decode(p_Assignment_Status
                   , 'ALL'
                       , decode(summbal.amount_type_id
                            , 1, NVL(summbal.period_balance,0)
                            , 0)
                   , 'PROVISIONAL'
                       , decode(summbal.amount_type_id
                            , 4, NVL(summbal.period_balance,0)
                            , 0)
                   , 'CONFIRMED'
                       , decode(summbal.amount_type_id
                            , 1, NVL(summbal.period_balance,0)
                            , 0)
              , 0)
          , 0))
      -sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , Decode(p_Assignment_Status
                   , 'CONFIRMED'
                       , decode(summbal.amount_type_id
                            , 4, NVL(summbal.period_balance,0)
                            , 0)
              , 0)
          , 0))             AS FORECAST_HOURS
 /*
  * Field below is for FORECAST_WEIGHTED_HOURS
  */
     , (sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , DecodE(p_Assignment_Status
                   , 'ALL'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 2, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 3, NVL(summbal.period_balance,0)
                                     , 0))
                   , 'PROVISIONAL'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 5, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 6, NVL(summbal.period_balance,0)
                                     , 0))
                   , 'CONFIRMED'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 2, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 3, NVL(summbal.period_balance,0)
                                     , 0))
                   )
          , 0))
      -sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , Decode(p_Assignment_Status
                   , 'CONFIRMED'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 5, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 6, NVL(summbal.period_balance,0)
                                     , 0))
                   , 0)
          , 0)))            AS FORECAST_WEIGHTED_HOURS
 /*
  * Field below is for FORECAST_WEIGHTED_HOURS_P
  */
     ,ROUND(NVL(
       (sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , DecodE(p_Assignment_Status
                   , 'ALL'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 2, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 3, NVL(summbal.period_balance,0)
                                     , 0))
                   , 'PROVISIONAL'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 5, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 6, NVL(summbal.period_balance,0)
                                     , 0))
                   , 'CONFIRMED'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 2, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 3, NVL(summbal.period_balance,0)
                                     , 0))
                   )
          , 0))
      -sum(
       DECODE(paobj.balance_type_code
          , PA_REP_UTIL_GLOB.GetBalTypeForecast
              , Decode(p_Assignment_Status
                   , 'CONFIRMED'
                       , Decode(p_Utilization_Method
                            , 'ORGANIZATION'
                                , decode(summbal.amount_type_id
                                     , 5, NVL(summbal.period_balance,0)
                                     , 0)
                            , 'RESOURCE'
                                , decode(summbal.amount_type_id
                                     , 6, NVL(summbal.period_balance,0)
                                     , 0))
                   , 0)
          , 0)))
       *100/
       DECODE(p_Utilization_Category_Id
       ,0 , DECODE(p_Show_Percentage_By
            , 'CAPACITY'
              , DECODE(
                   sign(
                            sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   , 1,
                           (sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   ,1)
          , 'TOTAL_WORKED_HOURS'
              , DECODE(
                   sign(
                     sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeForecast
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0)))
                   , 1, sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeForecast
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0))
              , 1)
          )
       ,  PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeForecast
                   , max(paobj.person_id)
                   , max(summbal.version_id)     /*8528649 changes for FORECAST_WEIGHTED_HOURS_P*/
                   , PA_REP_UTIL_GLOB.GetPeriodTypeYr
                   , NULL
                   , NULL
                   , NULL
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By
                   , p_organization_id
                   , p_period_year)
       )
        , -9999)    -- finished NVL
        , 0) AS FORECAST_WEIGHTED_HOURS_P      -- finished rounding and concatenation
 /*
  * Field below is for FORECAST_CAP_OR_TOT_HRS
  */
     , DECODE(p_Utilization_Category_Id
       ,0 , DECODE(p_Show_Percentage_By
            , 'CAPACITY'
              , DECODE(
                   sign(
                            sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   , 1,
                           (sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 9, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0))
                           -sum(
                            DecodE(paobj.balance_type_code
                               , PA_REP_UTIL_GLOB.GetBalTypeForecast
                                   , Decode(summbal.amount_type_id
                                        , 10, NVL(summbal.period_balance,0)
                                        , 0)
                               , 0)))
                   ,1)
          , 'TOTAL_WORKED_HOURS'
              , DECODE(
                   sign(
                     sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeForecast
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0)))
                   , 1, sum(
                     DecodE(paobj.balance_type_code
                        , PA_REP_UTIL_GLOB.GetBalTypeForecast
                            , Decode(summbal.amount_type_id
                                 , 1, NVL(summbal.period_balance,0)
                                 , 0)
                        , 0))
              , 1)
          )
       ,  PA_REP_UTIL_SCREEN.calculate_capacity(
                   PA_REP_UTIL_GLOB.GetOrgId
                   , PA_REP_UTIL_GLOB.GetBalTypeForecast
                   , max(paobj.person_id)
                   , max(summbal.version_id)  /*8528649 changes for forecast_cap_or_tot_hrs*/
                   , PA_REP_UTIL_GLOB.GetPeriodTypeYr
                   , NULL
                   , NULL
                   , NULL
                   , 1
                   , 9
                   , 10
                   , p_Show_Percentage_By
                   , p_organization_id
                   , p_period_year)
       )                           AS FORECAST_CAP_OR_TOT_HRS
     from
         PA_Summ_Balances                 summbal
         , PA_Objects                     paobj
         , pa_resources_denorm            resdnorm
         , gl_periods                     glprd
         , pa_lookups                     lkup
     where
		 lkup.lookup_type = 'PERSON_TYPE'
		 AND lkup.lookup_code = 'EMPLOYEE'
         AND NVL(resdnorm.manager_id,-1) = NVL(p_manager_id,NVL(resdnorm.manager_id,-1))
         AND (
			  (glprd.start_date between trunc(resdnorm.resource_effective_start_date) and trunc(NVL(resdnorm.resource_effective_end_date,glprd.end_date))+0.99999
			  and p_calling_mode = 'ORGMGR')
            OR
/* Bug 2003821: start */
		  (
		   (
			  (trunc(SYSDATE) between trunc(resdnorm.resource_effective_start_date) and trunc(NVL(resdnorm.resource_effective_end_date,trunc(sysdate)))+0.99999
                            and glprd.start_date <=sysdate)  /* Added for Bug 2325539 */
			  OR
			  (glprd.start_date between trunc(resdnorm.resource_effective_start_date) and trunc(NVL(resdnorm.resource_effective_end_date,glprd.end_date))+0.99999
			  and glprd.start_date > sysdate)
		   )
		   and p_calling_mode = 'RESMGR'
		  )
             )
/* Bug 2003821: end */
         AND glprd.period_set_name = summbal.period_set_name
         AND glprd.period_name = summbal.period_name
         AND summbal.object_id = paobj.object_id
         AND summbal.version_id = -1
         AND summbal.period_type = PA_REP_UTIL_GLOB.GetPeriodTypeGl
         AND summbal.period_set_name = PA_REP_UTIL_GLOB.GetPeriodSetName
         AND summbal.period_year = p_Period_Year
         AND summbal.amount_type_id in (  1   /* G_RES_HRS_C              */
                                        , 2   /* G_RES_WTDHRS_ORG_C       */
                                        , 3   /* G_RES_WTDHRS_PEOPLE_C    */
                                        , 4   /* G_RES_PRVHRS_C           */
                                        , 5   /* G_RES_PRVWTDHRS_ORG_C    */
                                        , 6   /* G_RES_PRVWTDHRS_PEOPLE_C */
                                        , 9   /* G_RES_CAP_C              */
                                        ,10   /* G_RES_REDUCEDCAP_C       */
                                        )
         AND summbal.object_type_code = DECODE(p_Utilization_Category_Id
             , 0, PA_REP_UTIL_GLOB.GetObjectTypeRes
             , Decode(p_Utilization_Method
                      , 'ORGANIZATION', PA_REP_UTIL_GLOB.GetObjectTypeResUco
                      , 'RESOURCE', PA_REP_UTIL_GLOB.GetObjectTypeResUcr))
         AND paobj.object_type_code = summbal.object_type_code
         AND paobj.expenditure_org_id = PA_REP_UTIL_GLOB.GetOrgId
         AND paobj.project_org_id              = -1
         AND paobj.expenditure_organization_id = NVL(p_organization_id,paobj.expenditure_organization_id)
         AND paobj.project_organization_id     = -1
         AND paobj.project_id                  = -1
         AND paobj.task_id                     = -1
         AND paobj.person_id = resdnorm.person_id
         AND resdnorm.utilization_flag = 'Y' /* Added for Bug#2765050 */
         AND paobj.assignment_id = -1
         AND paobj.work_type_id                = -1
         AND paobj.org_util_category_id     = DECODE(p_Utilization_Category_Id
             , 0, -1
             , Decode(p_Utilization_Method
                      , 'ORGANIZATION', p_Utilization_Category_Id
                      , 'RESOURCE', -1))
         AND paobj.res_util_category_id     = DECODE(p_Utilization_Category_Id
             , 0, -1
             , Decode(p_Utilization_Method
                      , 'ORGANIZATION', -1
                      , 'RESOURCE', p_Utilization_Category_Id))
         AND paobj.balance_type_code in (PA_REP_UTIL_GLOB.GetBalTypeActuals,PA_REP_UTIL_GLOB.GetBalTypeForecast)
   group by
     DECODE(p_calling_mode
            , 'ORGMGR', paobj.expenditure_organization_id
            , 'RESMGR', NULL
            )
           , resdnorm.person_id
           , resdnorm.resource_id
  ;
     END IF;


 /*
  * END of Case 4 for U2
  * p_Period_Type=PA_REP_UTIL_GLOB.GetPeriodTypeYr
  */


 /*
  * Bug 1633069
  * Now to update the resource_type_code, added through bug 1633069,
  * to identify the resources reporting to the select manager who are also
  * in turn managers of other resources.  The above select put the value of
  * of EMPLOYEE for all the records now check against pa_resources_denorm
  * to update the resource_type_code to MANAGERS appropriately.
  */

  Update PA_REP_UTIL_SCREEN_TMP  tmp
  Set (resource_type,resource_type_code) = (select lkup2.meaning,lkup2.lookup_code
							  from pa_lookups lkup2
							  where lkup2.lookup_type='PERSON_TYPE'
							  and   lkup2.lookup_code = 'MANAGER')
  Where exists (select prd.Person_id
				from   pa_resources_denorm  prd
				where  prd.manager_id = tmp.person_id)
  ;


  EXCEPTION

    WHEN OTHERS THEN
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_REP_UTIL_SCREEN.poplt_screen_tmp_table'
                            , p_procedure_name => PA_DEBUG.G_Err_Stack);
    RAISE;


  END poplt_screen_tmp_table;  /* End of Procedure poplt_screen_tmp_table */

  /*
   * Functions.
   */

  /*
   * The function calculate_capacity is needed for the cases when
   * p_Utilization_Category_Id <> 0, ie the object_type_code is not RES.  In
   * such cases the select will calculate the capacity from the current record
   * which is incorrect since capacity should ALWAYS be calculated using the
   * RES record. Thus for cases when the object_type_code <> RES the decode
   * has been coded such that the function calculate_capacity would be called.
   */

  FUNCTION calculate_capacity(
            p_ORG_ID                        IN NUMBER
            , p_Balance_Type_Code           IN VARCHAR2
            , p_Entity_ID                   IN NUMBER
            , p_Version_ID                  IN NUMBER
            , p_Period_Type                 IN VARCHAR2
            , p_Period_Set_Name             IN VARCHAR2
            , p_Period_Name                 IN VARCHAR2
            , p_Global_Exp_Period_End_Date  IN DATE
            , p_Amount_ID_Resource_Hours    IN NUMBER
            , p_Amount_ID_Capacity          IN NUMBER
            , p_Amount_ID_Reduced_Capacity  IN NUMBER
            , p_Show_Percentage_By          IN VARCHAR2
			, p_Organization_Id				IN NUMBER DEFAULT NULL
			, p_Period_Year					IN NUMBER DEFAULT NULL
			, p_Quarter_Or_Month_Number		IN NUMBER DEFAULT NULL
            )
            RETURN NUMBER
  IS
    v_total_hours      NUMBER := 0;
    v_derived_cap      NUMBER := 0;
    v_raw_cap          NUMBER := 0;
    v_raw_reduced_cap  NUMBER := 0;
	v_amount_type_id   NUMBER := 0;
	v_period_balance   NUMBER := 0;
    TYPE t_cap_rec IS REF CURSOR;
    c_cap_rec   t_cap_rec;
  BEGIN
  	   	 IF p_Period_Type = PA_REP_UTIL_GLOB.GetPeriodTypeQr THEN
		 	 open c_cap_rec for
		     select
		          summbal2.amount_type_id           AS amount_type_id
		         , sum(summbal2.period_balance)    AS period_balance
             from
		     		 PA_Summ_Balances  summbal2
		              , PA_Objects      paobj2
             where
			         paobj2.Balance_Type_Code = p_Balance_Type_Code
			         AND paobj2.expenditure_org_id = p_ORG_ID
			         AND summbal2.version_id = p_Version_ID
			         AND (( summbal2.object_type_code =
					 PA_REP_UTIL_GLOB.GetObjectTypeRes
			         AND paobj2.person_id = p_Entity_ID
					 AND paobj2.expenditure_organization_id =
					 nvl(p_organization_id,paobj2.expenditure_organization_id))
			         OR
			         ( summbal2.object_type_code = PA_REP_UTIL_GLOB.GetObjectTypeOrg
			         AND paobj2.expenditure_organization_id = p_Entity_ID)
			         )
			         AND summbal2.object_id = paobj2.object_id
			         AND summbal2.period_type = PA_REP_UTIL_GLOB.GetPeriodTypeGl
			         AND period_year = p_Period_Year
					 AND quarter_or_month_number = p_Quarter_Or_Month_Number
			         AND summbal2.amount_type_id in (p_Amount_ID_Resource_Hours,p_Amount_ID_Capacity,p_Amount_ID_Reduced_Capacity)
             group by
			         summbal2.amount_type_id;

		 ELSIF p_Period_Type = PA_REP_UTIL_GLOB.GetPeriodTypeYr THEN
		 	 open c_cap_rec for
		     select
		          summbal2.amount_type_id           AS amount_type_id
		         , sum(summbal2.period_balance)    AS period_balance
             from
		     		 PA_Summ_Balances  summbal2
		              , PA_Objects      paobj2
             where
			         paobj2.Balance_Type_Code = p_Balance_Type_Code
			         AND paobj2.expenditure_org_id = p_ORG_ID
			         AND summbal2.version_id = p_Version_ID
			         AND (( summbal2.object_type_code =
					 PA_REP_UTIL_GLOB.GetObjectTypeRes
			         AND paobj2.person_id = p_Entity_ID
					 AND paobj2.expenditure_organization_id =
					 nvl(p_organization_id,paobj2.expenditure_organization_id))
			         OR
			         ( summbal2.object_type_code =
					 PA_REP_UTIL_GLOB.GetObjectTypeOrg
			         AND paobj2.expenditure_organization_id = p_Entity_ID)
			         )
			         AND summbal2.object_id = paobj2.object_id
			         AND summbal2.period_type = PA_REP_UTIL_GLOB.GetPeriodTypeGl
			         AND period_year = p_Period_Year
			         AND summbal2.amount_type_id in (p_Amount_ID_Resource_Hours,p_Amount_ID_Capacity,p_Amount_ID_Reduced_Capacity)
             group by
			         summbal2.amount_type_id;
		 ELSE
		 	 open c_cap_rec for
		     select
			 		 summbal2.amount_type_id           AS amount_type_id
					 , sum(summbal2.period_balance)    AS period_balance
			 from
					 PA_Summ_Balances  summbal2
			         , PA_Objects      paobj2
             where
			         paobj2.Balance_Type_Code = p_Balance_Type_Code
			         AND paobj2.expenditure_org_id = p_ORG_ID
			         AND summbal2.version_id = p_Version_ID
			         AND (( summbal2.object_type_code =
					 PA_REP_UTIL_GLOB.GetObjectTypeRes
			         AND paobj2.person_id = p_Entity_ID
					 AND paobj2.expenditure_organization_id =
					 nvl(p_organization_id,paobj2.expenditure_organization_id))
					 OR
             		 ( summbal2.object_type_code =
					 PA_REP_UTIL_GLOB.GetObjectTypeOrg
					   AND paobj2.expenditure_organization_id = p_Entity_ID)
					 )
			         AND summbal2.object_id = paobj2.object_id
			         AND summbal2.period_type = p_Period_Type
			         AND summbal2.period_set_name = p_Period_Set_Name
			         AND summbal2.period_name = p_Period_Name
			         AND summbal2.global_exp_period_end_date =
					 p_Global_Exp_Period_End_Date
			         AND summbal2.amount_type_id in (p_Amount_ID_Resource_Hours,p_Amount_ID_Capacity,p_Amount_ID_Reduced_Capacity)
			 group by
			         summbal2.amount_type_id;

		 END IF;
         LOOP
		 	 fetch c_cap_rec into v_amount_type_id,v_period_balance;
             IF    (v_amount_type_id=p_Amount_ID_Capacity) THEN
                    v_raw_cap := v_period_balance;
             ELSIF (v_amount_type_id=p_Amount_ID_Reduced_Capacity) THEN
                    v_raw_reduced_cap := v_period_balance;
             ELSIF (v_amount_type_id=p_Amount_ID_Resource_Hours) THEN
                    v_total_hours := v_period_balance;
             END IF;
			 EXIT WHEN c_cap_rec%NOTFOUND;
         END LOOP;

             v_derived_cap := NVL(v_raw_cap,0) - NVL(v_raw_reduced_cap,0);

             IF      NVL(v_derived_cap,-1) <= 0  THEN
                     v_derived_cap := 1;
             END IF;

             IF      NVL(v_total_hours,-1) <= 0  THEN
                     v_total_hours := 1;
             END IF;

         IF     (p_Show_Percentage_By='CAPACITY')  THEN
                 return v_derived_cap;
         ELSE
                 return v_total_hours;
         END IF;

  END calculate_capacity;

 PROCEDURE poplt_u1_screen_tmp_table(
            p_Organization_ID           IN NUMBER
            , p_Period_Type             IN VARCHAR2
            , p_Period_Year             IN VARCHAR2
            , p_Period_Quarter          IN VARCHAR2
            , p_Period_Name             IN VARCHAR2
            , p_Global_Week_End_Date    IN VARCHAR2
            , p_Show_Percentage_By      IN VARCHAR2
						)
  IS
  BEGIN

    delete from PA_REP_UTIL_SCR_U1_TMP;

  	/*                    */
      /* Case 1 for GE view */
  	/*                    */
    PA_REP_UTIL_GLOB.SetU1Params(p_organization_id,p_period_type,p_period_name,to_number(p_period_year));
    IF (p_Period_Type=PA_REP_UTIL_GLOB.GetPeriodTypeGe)  THEN
	INSERT INTO PA_REP_UTIL_SCR_U1_TMP
	(
	 title_name
	 , title_code
	 , exp_organization_id
	 , exp_sub_organization_id
	 , exp_sub_organization_name
	 , emp_head_count
	 , others_head_count
	 , actuals_capacity
	 , actuals_hours
	 , actuals_weighted_hours
	 , actuals_utilization
	 , forecast_capacity
	 , forecast_hours
	 , forecast_weighted_hours
	 , forecast_utilization
	 , period_year
	 , period_month
	 , exp_end_date )
	 SELECT
	 title_name
	 , title_code
	 , exp_organization_id
	 , exp_sub_organization_id
	 , exp_sub_organization_name
	 , emp_head_count
	 , others_head_count
	 , actuals_capacity
	 , actuals_hours
	 , actuals_weighted_hours
	 , actuals_utilization
	 , forecast_capacity
	 , forecast_hours
	 , forecast_weighted_hours
	 , forecast_utilization
	 , period_year
	 , period_month
	 , exp_end_date from PA_REP_UTIL_ORG_GE_V;

       PA_RESOURCE_UTILS.SET_PERIOD_DATE(
                       p_period_type
                       , p_Global_Week_End_Date -- in lieu of p_period_name
                       , to_date(p_Global_Week_End_Date,'MM/DD/YYYY')
                       , p_period_year
                       );
  	/*                    */
      /* Case 2 for GL view */
  	/*                    */
    ELSIF (p_Period_Type=PA_REP_UTIL_GLOB.GetPeriodTypeGl) THEN
	INSERT INTO PA_REP_UTIL_SCR_U1_TMP
	(
	 title_name
	 , title_code
	 , exp_organization_id
	 , exp_sub_organization_id
	 , exp_sub_organization_name
	 , emp_head_count
	 , others_head_count
	 , actuals_capacity
	 , actuals_hours
	 , actuals_weighted_hours
	 , actuals_utilization
	 , forecast_capacity
	 , forecast_hours
	 , forecast_weighted_hours
	 , forecast_utilization
	 , period_set_name
	 , period_year
	 , period_quarter
	 , period_name
	 , period_num)
 	 SELECT
	 title_name
	 , title_code
	 , exp_organization_id
	 , exp_sub_organization_id
	 , exp_sub_organization_name
	 , emp_head_count
	 , others_head_count
	 , actuals_capacity
	 , actuals_hours
	 , actuals_weighted_hours
	 , actuals_utilization
	 , forecast_capacity
	 , forecast_hours
	 , forecast_weighted_hours
	 , forecast_utilization
	 , period_set_name
	 , period_year
	 , period_quarter
	 , period_name
	 , period_num
	 from PA_REP_UTIL_ORG_GL_V;

       PA_RESOURCE_UTILS.SET_PERIOD_DATE(
                       p_period_type
                       , p_period_name
                       , to_date(p_Global_Week_End_Date,'MM/DD/YYYY')
                       , p_period_year
                       );
	 ELSIF (p_Period_Type=PA_REP_UTIL_GLOB.GetPeriodTypePa) THEN
  	/*                    */
      /* Case 3 for PA view */
  	/*                    */
 	 INSERT INTO PA_REP_UTIL_SCR_U1_TMP
	 (
	 title_name
	 , title_code
	 , exp_organization_id
	 , exp_sub_organization_id
	 , exp_sub_organization_name
	 , emp_head_count
	 , others_head_count
	 , actuals_capacity
	 , actuals_hours
	 , actuals_weighted_hours
	 , actuals_utilization
	 , forecast_capacity
	 , forecast_hours
	 , forecast_weighted_hours
	 , forecast_utilization
	 , period_set_name
	 , period_year
	 , period_quarter
	 , period_name
	 , period_num)
 	 SELECT
	 title_name
	 , title_code
	 , exp_organization_id
	 , exp_sub_organization_id
	 , exp_sub_organization_name
	 , emp_head_count
	 , others_head_count
	 , actuals_capacity
	 , actuals_hours
	 , actuals_weighted_hours
	 , actuals_utilization
	 , forecast_capacity
	 , forecast_hours
	 , forecast_weighted_hours
	 , forecast_utilization
	 , period_set_name
	 , period_year
	 , period_quarter
	 , period_name
	 , period_num
	 from PA_REP_UTIL_ORG_PA_V;

       PA_RESOURCE_UTILS.SET_PERIOD_DATE(
                       p_period_type
                       , p_period_name
                       , null
                       , p_period_year
                       );
  	/*                    */
      /* Case 4 for YR view */
  	/*                    */
    ELSIF (p_Period_Type=PA_REP_UTIL_GLOB.GetPeriodTypeYr)  THEN
	INSERT INTO PA_REP_UTIL_SCR_U1_TMP
	(
	 title_name
	 , title_code
	 , exp_organization_id
	 , exp_sub_organization_id
	 , exp_sub_organization_name
	 , emp_head_count
	 , others_head_count
	 , actuals_capacity
	 , actuals_hours
	 , actuals_weighted_hours
	 , actuals_utilization
	 , forecast_capacity
	 , forecast_hours
	 , forecast_weighted_hours
	 , forecast_utilization
	 , period_set_name
	 , period_year)
	 SELECT
	 title_name
	 , title_code
	 , exp_organization_id
	 , exp_sub_organization_id
	 , exp_sub_organization_name
	 , emp_head_count
	 , others_head_count
	 , actuals_capacity
	 , actuals_hours
	 , actuals_weighted_hours
	 , actuals_utilization
	 , forecast_capacity
	 , forecast_hours
	 , forecast_weighted_hours
	 , forecast_utilization
	 , period_set_name
	 , period_year from PA_REP_UTIL_ORG_YR_V;

       PA_RESOURCE_UTILS.SET_PERIOD_DATE(
                       p_period_type
                       , p_period_name
                       , to_date(p_Global_Week_End_Date,'MM/DD/YYYY')
                       , p_period_year
                       );
  	/*                    */
      /* Case 5 for QR view */
  	/*                    */
    ELSIF (p_Period_Type=PA_REP_UTIL_GLOB.GetPeriodTypeQr)  THEN
	INSERT INTO PA_REP_UTIL_SCR_U1_TMP
	(
	 title_name
	 , title_code
	 , exp_organization_id
	 , exp_sub_organization_id
	 , exp_sub_organization_name
	 , emp_head_count
	 , others_head_count
	 , actuals_capacity
	 , actuals_hours
	 , actuals_weighted_hours
	 , actuals_utilization
	 , forecast_capacity
	 , forecast_hours
	 , forecast_weighted_hours
	 , forecast_utilization
	 , period_set_name
	 , period_year
	 , period_quarter )
	 SELECT
	 title_name
	 , title_code
	 , exp_organization_id
	 , exp_sub_organization_id
	 , exp_sub_organization_name
	 , emp_head_count
	 , others_head_count
	 , actuals_capacity
	 , actuals_hours
	 , actuals_weighted_hours
	 , actuals_utilization
	 , forecast_capacity
	 , forecast_hours
	 , forecast_weighted_hours
	 , forecast_utilization
	 , period_set_name
	 , period_year
	 , period_quarter from PA_REP_UTIL_ORG_QR_V
	 WHERE
	 period_quarter = p_period_quarter;

       PA_RESOURCE_UTILS.SET_PERIOD_DATE(
                       p_period_type
                       , p_period_quarter   --  in lieu of p_period_name
                       , to_date(p_Global_Week_End_Date,'MM/DD/YYYY')
                       , p_period_year
                       );
    END IF;

/* Commented for bug 5680366
    UPDATE PA_REP_UTIL_SCR_U1_TMP U1
	Set (emp_head_count, others_head_count) =
	    (Select HC.emp_headcount,0
        From   PA_RES_EMP_HCOUNT_V  HC
        Where  U1.exp_sub_organization_id = HC.organization_id
        And    DECODE(U1.exp_sub_organization_id
					  , p_organization_id, U1.title_code
					  , HC.headcount_code)
					  = HC.headcount_code
        );
*/
  COMMIT;
  END poplt_u1_screen_tmp_table;
END PA_REP_UTIL_SCREEN;

/
