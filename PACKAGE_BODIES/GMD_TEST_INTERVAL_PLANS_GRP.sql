--------------------------------------------------------
--  DDL for Package Body GMD_TEST_INTERVAL_PLANS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_TEST_INTERVAL_PLANS_GRP" AS
/* $Header: GMDGTIPB.pls 115.1 2003/04/20 23:38:54 mchandak noship $ */

FUNCTION Test_Interval_Plan_Exist(p_test_interval_plan_name IN VARCHAR2 )
RETURN BOOLEAN IS
    CURSOR Cur_get_test_interval_plan IS
      SELECT '1'
      FROM  gmd_test_interval_plans_b
      WHERE name = p_test_interval_plan_name;
      l_temp	VARCHAR2(1);
  BEGIN
    IF (p_test_interval_plan_name IS NOT NULL) THEN
      OPEN Cur_get_test_interval_plan;
      FETCH Cur_get_test_interval_plan INTO l_temp;
      IF (Cur_get_test_interval_plan%FOUND) THEN
        CLOSE Cur_get_test_interval_plan;
        RETURN TRUE;
      ELSE
        CLOSE Cur_get_test_interval_plan;
        RETURN FALSE;
      END IF;
    ELSE
    	RETURN FALSE;
    END IF;
  END test_interval_plan_exist;

FUNCTION Test_Interval_Period_Exist
(
  p_period IN VARCHAR2,
  p_test_interval_plan_id  IN NUMBER ) RETURN BOOLEAN IS

  CURSOR Cur_test_interval_plan_period IS
      SELECT '1'
      FROM  gmd_test_interval_plan_periods
      WHERE name = p_period
      AND   test_interval_plan_id = p_test_interval_plan_id ;

      l_temp	VARCHAR2(1);
BEGIN
    IF (p_period IS NOT NULL AND p_test_interval_plan_id IS NOT NULL) THEN
      OPEN Cur_test_interval_plan_period;
      FETCH Cur_test_interval_plan_period INTO l_temp;
      IF (Cur_test_interval_plan_period%FOUND) THEN
        CLOSE Cur_test_interval_plan_period;
        RETURN TRUE;
      ELSE
        CLOSE Cur_test_interval_plan_period;
        RETURN FALSE;
      END IF;
    ELSE
    	RETURN FALSE;
    END IF;


END Test_Interval_Period_Exist ;

FUNCTION GET_TL_TEST_INT_PLAN_DURATION(p_test_interval_plan_id 	IN NUMBER,
				       p_year_desc		IN VARCHAR2	DEFAULT NULL,
				       p_month_desc		IN VARCHAR2	DEFAULT NULL,
				       p_week_desc		IN VARCHAR2	DEFAULT NULL,
				       p_day_desc		IN VARCHAR2	DEFAULT NULL,
				       p_hour_desc		IN VARCHAR2	DEFAULT NULL )
RETURN VARCHAR2  IS

CURSOR cr_get_max_simulated_date IS
SELECT  YEARS_FROM_START ,   MONTHS_FROM_START      ,WEEKS_FROM_START,
	DAYS_FROM_START  ,   HOURS_FROM_START
FROM    GMD_TEST_INTERVAL_PLAN_PERIODS A
WHERE   TEST_INTERVAL_PLAN_ID = p_test_interval_plan_id
ORDER BY SIMULATED_DATE DESC ;

CURSOR cr_get_period_unit_desc(l_lookup_code VARCHAR2) IS
SELECT meaning FROM GEM_LOOKUPS
WHERE  lookup_type = 'GMD_QC_FREQUENCY_PERIOD'
and    lookup_code = l_lookup_code ;

l_years_from_start 	GMD_TEST_INTERVAL_PLAN_PERIODS.years_from_start%TYPE;
l_months_from_start	GMD_TEST_INTERVAL_PLAN_PERIODS.months_from_start%TYPE;
l_weeks_from_start	GMD_TEST_INTERVAL_PLAN_PERIODS.weeks_from_start%TYPE;
l_days_from_start	GMD_TEST_INTERVAL_PLAN_PERIODS.days_from_start%TYPE;
l_hours_from_start	GMD_TEST_INTERVAL_PLAN_PERIODS.hours_from_start%TYPE;
l_lookup_code		VARCHAR2(5);

l_year_desc		VARCHAR2(25);
l_month_desc		VARCHAR2(25);
l_week_desc		VARCHAR2(25);
l_day_desc		VARCHAR2(25);
l_hour_desc		VARCHAR2(25);
l_string        	VARCHAR2(255);

BEGIN
      IF p_test_interval_plan_id IS NULL THEN
      	 RETURN NULL;
      END IF;

      l_year_desc	:= p_year_desc	;
      l_month_desc	:= p_month_desc	;
      l_week_desc	:= p_week_desc	;
      l_day_desc	:= p_day_desc	;
      l_hour_desc	:= p_hour_desc	;


      OPEN  cr_get_max_simulated_date ;
      FETCH cr_get_max_simulated_date INTO l_years_from_start , l_months_from_start      ,l_weeks_from_start,
	l_days_from_start  ,   l_hours_from_start   ;

      IF cr_get_max_simulated_date%NOTFOUND THEN
      	 CLOSE cr_get_max_simulated_date;
      	 RETURN NULL;
      END IF;

      CLOSE cr_get_max_simulated_date ;

      IF l_years_from_start IS NOT NULL AND l_year_desc IS NULL THEN
	   OPEN   cr_get_period_unit_desc('TY');
	   FETCH  cr_get_period_unit_desc  INTO l_year_desc ;
	   CLOSE  cr_get_period_unit_desc ;
      END IF;

      IF l_months_from_start IS NOT NULL AND l_month_desc IS NULL  THEN
	   OPEN   cr_get_period_unit_desc('TM');
	   FETCH  cr_get_period_unit_desc  INTO l_month_desc ;
	   CLOSE  cr_get_period_unit_desc ;
      END IF;

      IF l_weeks_from_start IS NOT NULL AND l_week_desc IS NULL  THEN
	   OPEN   cr_get_period_unit_desc('TW');
	   FETCH  cr_get_period_unit_desc  INTO l_week_desc ;
	   CLOSE  cr_get_period_unit_desc ;
      END IF;

      IF l_days_from_start IS NOT NULL AND l_day_desc IS NULL  THEN
	   OPEN   cr_get_period_unit_desc('TD');
	   FETCH  cr_get_period_unit_desc  INTO l_day_desc ;
	   CLOSE  cr_get_period_unit_desc ;
      END IF;

      IF l_hours_from_start IS NOT NULL AND l_hour_desc IS NULL  THEN
	   OPEN   cr_get_period_unit_desc('TH');
	   FETCH  cr_get_period_unit_desc  INTO l_hour_desc ;
	   CLOSE  cr_get_period_unit_desc ;
      END IF;

      SELECT DECODE(l_years_from_start,NULL,NULL,l_years_from_start||' '||l_year_desc||' ')||
      		DECODE(l_months_from_start,NULL,NULL,l_months_from_start||' '||l_month_desc||' ')||
      		DECODE(l_weeks_from_start,NULL,NULL,l_weeks_from_start||' '||l_week_desc||' ')||
      		DECODE(l_days_from_start,NULL,NULL,l_days_from_start||' '||l_day_desc||' ')||
      		DECODE(l_hours_from_start,NULL,NULL,l_hours_from_start||' '||l_hour_desc)
      INTO l_string FROM DUAL ;

      RETURN (l_string);


END GET_TL_TEST_INT_PLAN_DURATION ;

END GMD_TEST_INTERVAL_PLANS_GRP;

/
