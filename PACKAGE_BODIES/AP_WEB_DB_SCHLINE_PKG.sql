--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_SCHLINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_SCHLINE_PKG" AS
/* $Header: apwdbscb.pls 120.4.12010000.4 2009/12/18 12:47:16 meesubra ship $ */

--------------------------------------------------------------------------------
FUNCTION GetScheduleLinesCursor(
	 p_policy_id		IN	NUMBER,
	p_vehicle_category_code	IN	VARCHAR2,
	p_vehicle_type		IN	VARCHAR2,
	p_fuel_type		IN	VARCHAR2,
	p_currency_code		IN	VARCHAR2,
	p_employee_id		IN	NUMBER,
	p_start_expense_date	IN	DATE,
	p_schedule_lines_cursor OUT NOCOPY ScheduleLinesCursor)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
  -- 3176205: This query includes all workers except for
  -- terminated contingent workers and terminated employees who
  -- are now active contingent workers.
  -- Bug: 6448540, from OIE.K a schedule can have multiple passenger rates.
  -- passenger_flag cannot be Y.
  OPEN p_schedule_lines_cursor FOR
  SELECT /*+ ordered */
         SL.RANGE_HIGH,
	 nvl(SL.RANGE_LOW, 0),
	 SP.START_DATE,
	 SP.END_DATE,
         SL.rate,
         decode(SH.passengers_flag,null,0,decode(calculation_method, 'AMOUNT', NVL(SL.rate_per_passenger,0), 'PERCENT', NVL(SL.rate_per_passenger,0)/100* SL.rate, 0)) rate_per_passenger
  FROM   AP_POL_HEADERS SH,
	 AP_POL_SCHEDULE_PERIODS SP,
         AP_POL_LINES SL
  WHERE  SH.POLICY_ID = p_policy_id
  AND	 SH.POLICY_ID = SL.POLICY_ID
  AND	 nvl(SL.ROLE_ID,0) = getRoleId(p_policy_id,p_employee_id,p_start_expense_date)
  AND    nvl(SL.VEHICLE_CATEGORY,0) = decode(
	    SH.VEHICLE_CATEGORY_FLAG,'Y', p_vehicle_category_code, nvl(SL.VEHICLE_CATEGORY,0))
  AND    nvl(SL.VEHICLE_TYPE,0) = decode(
            SH.VEHICLE_TYPE_FLAG, 'Y', p_vehicle_type, nvl(SL.VEHICLE_TYPE,0))
  AND	 nvl(SL.FUEL_TYPE,0) = decode(
	    SH.FUEL_TYPE_FLAG, 'Y', p_fuel_type, nvl(SL.FUEL_TYPE,0))
  AND	 SL.CURRENCY_CODE = decode(
	    SH.CURRENCY_PREFERENCE, 'MRC', p_currency_code, SL.CURRENCY_CODE)
  AND	 SL.STATUS = 'ACTIVE'
  AND    SL.SCHEDULE_PERIOD_ID = SP.SCHEDULE_PERIOD_ID
  AND    SP.POLICY_ID = SH.POLICY_ID
  AND    SP.START_DATE <= p_start_expense_date
  AND    nvl(SP.END_DATE, p_start_expense_date) >= p_start_expense_date
  AND    SL.ADDON_MILEAGE_RATE_CODE is null
  AND	 SL.PARENT_LINE_ID is null
  ORDER BY SL.RANGE_LOW;

   return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetScheduleLinesCursor');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetScheduleLinesCursor;


--------------------------------------------------------------------------------
PROCEDURE getSchHeaderInfo(
	p_policy_id	   IN  ap_pol_headers.policy_id%TYPE,
	p_sh_distance_uom  OUT NOCOPY ap_pol_headers.distance_uom%TYPE,
	p_sh_currency_code OUT NOCOPY ap_pol_headers.currency_code%TYPE,
        p_sh_distance_thresholds_flag OUT NOCOPY ap_pol_headers.distance_thresholds_flag%TYPE) IS
--------------------------------------------------------------------------------
BEGIN

  SELECT distance_uom,
	 currency_code,
	 distance_thresholds_flag
  INTO	 p_sh_distance_uom,
	 p_sh_currency_code,
	 p_sh_distance_thresholds_flag
  FROM	 AP_POL_HEADERS
  WHERE	 policy_id = p_policy_id;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('No data found: getSchHeaderInfo' );
    APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('getSchHeaderInfo');
    APP_EXCEPTION.RAISE_EXCEPTION;
END getSchHeaderInfo;

--------------------------------------------------------------------------------

FUNCTION GetRoleId(
	p_policy_id		IN	NUMBER,
	p_employee_id		IN	NUMBER,
	p_start_expense_date	IN	DATE)
RETURN NUMBER IS
--------------------------------------------------------------------------------
l_role_code NUMBER := 0;

BEGIN

  SELECT decode(SH.EMPLOYEE_ROLE_FLAG,'Y',
		(decode(SH.ROLE_CODE,'JOB_GROUP', PF.job_id,'POSITION',PF.position_id,'GRADE',PF.grade_id,0)),0) INTO l_role_code
  FROM
    AP_POL_HEADERS SH,
    (SELECT EMP.ASSIGNMENT_ID ,EMP.EMPLOYEE_ID
      FROM PER_EMPLOYEES_X EMP
      WHERE NOT AP_WEB_DB_HR_INT_PKG.ISPERSONCWK(EMP.EMPLOYEE_ID)= 'Y'
      AND EMP.EMPLOYEE_ID = p_employee_id
    UNION
      SELECT  PCW.ASSIGNMENT_ID , PCW.PERSON_ID
      FROM  PER_CONT_WORKERS_CURRENT_X PCW
      WHERE PCW.PERSON_ID = p_employee_id)  EMPLOYEE,
    PER_ALL_ASSIGNMENTS_F PF
  WHERE
    PF.ASSIGNMENT_ID = EMPLOYEE.ASSIGNMENT_ID
    AND    PF.EFFECTIVE_START_DATE <=  p_start_expense_date
    AND    PF.EFFECTIVE_END_DATE >= p_start_expense_date
    AND    EMPLOYEE.EMPLOYEE_ID = p_employee_id
    AND    SH.POLICY_ID = p_policy_id
    AND    ROWNUM = 1;

  IF(l_role_code > 0) THEN
  BEGIN
	  SELECT ROLE_ID INTO l_role_code FROM AP_POL_LINES WHERE POLICY_ID = p_policy_id and ROLE_ID = l_role_code and rownum = 1;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN -1;
  END;
  END IF;

RETURN l_role_code;

END GetRoleId;

--------------------------------------------------------------------------------

END AP_WEB_DB_SCHLINE_PKG;

/
