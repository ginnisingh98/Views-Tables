--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_USER_PREF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_USER_PREF_PKG" AS
/* $Header: apwdbupb.pls 120.7 2006/02/24 07:33:48 sbalaji noship $ */

-------------------------------------------------------------------
FUNCTION GetUserPrefs(p_employee_id   IN HR_EMPLOYEES_CURRENT_V.employee_id%TYPE,
                      p_userPrefs_rec OUT NOCOPY UserPrefsInfoRec)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN

  SELECT default_approver_id,
         default_expense_template_id,
         default_purpose,
         NVL(validate_details_flag,'N'), -- should this be N by default?
         NVL(default_foreign_curr_flag,'N'), -- should this be N by default?
         NVL(default_exchange_rate_flag,'N')
  INTO   p_userPrefs_rec.default_approver_id,
	 p_userPrefs_rec.default_expense_template_id,
         p_userPrefs_rec.default_purpose,
         p_userPrefs_rec.validate_details_flag,
         p_userPrefs_rec.default_foreign_curr_flag,
         p_userPrefs_rec.default_exchange_rate_flag
  FROM   ap_web_preferences
  WHERE  employee_id = p_employee_id;

  RETURN TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- Initialize preferences values
    p_userPrefs_rec.default_approver_id := NULL;
    p_userPrefs_rec.default_expense_template_id := NULL;
    p_userPrefs_rec.default_purpose := NULL;
    p_userPrefs_rec.validate_details_flag := 'N';
    p_userPrefs_rec.default_exchange_rate_flag := 'N';

    RETURN FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetUserPrefs');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetUserPrefs;


PROCEDURE getCumulativeMileage(
	p_policy_id		IN AP_POL_LINES.POLICY_ID%TYPE,
	p_start_date		IN AP_EXPENSE_REPORT_LINES.start_expense_date%TYPE,
	p_end_date		IN AP_EXPENSE_REPORT_LINES.end_expense_date%TYPE,
	p_employee_id		IN AP_WEB_EMPLOYEE_INFO.EMPLOYEE_ID%TYPE,
	p_cumulative_mileage OUT NOCOPY AP_WEB_EMPLOYEE_INFO.NUMERIC_VALUE%TYPE,
	p_period_id	 OUT NOCOPY AP_WEB_EMPLOYEE_INFO.PERIOD_ID%TYPE
)IS
--------------------------------------------------------------------------------
  l_period_id	AP_WEB_EMPLOYEE_INFO.PERIOD_ID%TYPE;

BEGIN

  SELECT ai.numeric_value, ai.period_id
  INTO   p_cumulative_mileage, p_period_id
  FROM   ap_web_employee_info_all ai,
	 ap_pol_schedule_periods ap
  WHERE  ap.policy_id = p_policy_id
  AND    ap.start_date <= p_start_date
  AND    nvl(ap.end_date, p_end_date + 1) >= p_end_date
  AND    ap.schedule_period_id = ai.period_id
  AND    value_type = 'CUM_REIMB_DISTANCE'
  AND    employee_id = p_employee_id;



EXCEPTION
  WHEN NO_DATA_FOUND THEN

    SELECT ap.schedule_period_id
    INTO   l_period_id
    FROM   ap_pol_schedule_periods ap
    WHERE  ap.start_date <= p_start_date
    AND    nvl(ap.end_date, p_end_date + 1) >= p_end_date
    AND	   policy_id = p_policy_id;

    p_cumulative_mileage := 0;
    p_period_id := l_period_id;

  WHEN OTHERS THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('getCumulativeMileage');
      APP_EXCEPTION.RAISE_EXCEPTION;
END getCumulativeMileage;
--------------------------------------------------------------------------------

END AP_WEB_DB_USER_PREF_PKG;

/
