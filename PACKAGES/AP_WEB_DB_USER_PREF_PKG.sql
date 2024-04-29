--------------------------------------------------------
--  DDL for Package AP_WEB_DB_USER_PREF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_USER_PREF_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdbups.pls 120.7 2006/02/24 07:30:35 sbalaji noship $ */

SUBTYPE pref_DefaultApproverID        IS AP_WEB_PREFERENCES.DEFAULT_APPROVER_ID%TYPE;
SUBTYPE pref_DefaultExpenseTemplateID IS AP_WEB_PREFERENCES.DEFAULT_EXPENSE_TEMPLATE_ID%TYPE;
SUBTYPE pref_DefaultPurpose           IS AP_WEB_PREFERENCES.DEFAULT_PURPOSE%TYPE;
SUBTYPE pref_ValidateDetailsFlag      IS AP_WEB_PREFERENCES.VALIDATE_DETAILS_FLAG%TYPE;
SUBTYPE pref_DefaultForeignCurrFlag   IS AP_WEB_PREFERENCES.DEFAULT_FOREIGN_CURR_FLAG%TYPE;
SUBTYPE pref_DefaultExchangeRateFlag   IS AP_WEB_PREFERENCES.DEFAULT_EXCHANGE_RATE_FLAG%TYPE;

TYPE UserPrefsInfoRec	IS RECORD (
  default_approver_id         pref_DefaultApproverID,
  default_expense_template_id pref_DefaultExpenseTemplateID,
  default_purpose             pref_DefaultPurpose,
  validate_details_flag       pref_ValidateDetailsFlag,
  default_foreign_curr_flag   pref_DefaultForeignCurrFlag,
  default_exchange_rate_flag  pref_DefaultExchangeRateFlag
);

FUNCTION GetUserPrefs(p_employee_id   IN HR_EMPLOYEES_CURRENT_V.employee_id%TYPE,
                      p_userPrefs_rec OUT NOCOPY UserPrefsInfoRec)
RETURN BOOLEAN;

--------------------------------------------------------------------------------
PROCEDURE getCumulativeMileage(
	p_policy_id		IN AP_POL_LINES.POLICY_ID%TYPE,
	p_start_date		IN AP_EXPENSE_REPORT_LINES.start_expense_date%TYPE,
	p_end_date		IN AP_EXPENSE_REPORT_LINES.end_expense_date%TYPE,
	p_employee_id		IN AP_WEB_EMPLOYEE_INFO.EMPLOYEE_ID%TYPE,
	p_cumulative_mileage OUT NOCOPY AP_WEB_EMPLOYEE_INFO.NUMERIC_VALUE%TYPE,
	p_period_id	 OUT NOCOPY AP_WEB_EMPLOYEE_INFO.PERIOD_ID%TYPE
);

END AP_WEB_DB_USER_PREF_PKG;

 

/
