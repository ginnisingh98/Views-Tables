--------------------------------------------------------
--  DDL for Package Body AP_WEB_OA_REPORTING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_OA_REPORTING_UTIL" AS
/* $Header: apwrputb.pls 120.8 2005/09/07 21:55:55 rlangi noship $ */

   -- Cache for Segment Name which implements the Cost Center
   g_CostCenterSegmentName   FND_SEGMENT_ATTRIBUTE_VALUES.application_column_name%TYPE := NULL;

   -- Cache for GetCostCenter
   gcc_old_code_combination_id    NUMBER := NULL;
   gcc_cost_center                VARCHAR2(30) := NULL;

  /*========================================================================
   | PUBLIC function GetCostCenterSegmentName
   |
   | DESCRIPTION
   |    Returns the name of the segment that implements the Cost Center in
   |    the accounting key flex field for the current user.
   |
   | PSEUDO CODE/LOGIC
   |
   | PARAMETERS
   |
   | RETURNS
   |    Cost Center Segment Name
   |
   | KNOWN ISSUES
   |
   | NOTES
   |
   | MODIFICATION HISTORY
   | Date                  Author            Description of Changes
   | 13-MAR-2002           krmenon           Created
   *=======================================================================*/
   FUNCTION GetCostCenterSegmentName RETURN VARCHAR2
   IS
      l_chart_of_accounts_id    AP_WEB_DB_AP_INT_PKG.glsob_chartOfAccountsID;
   BEGIN
      -- Check if cached, and return cached value
      IF g_CostCenterSegmentName IS NOT NULL THEN
         RETURN g_CostCenterSegmentName;
      END IF;

      AP_WEB_ACCTG_PKG.GetCostCenterSegmentName(
        p_cost_center_segment_name => g_CostCenterSegmentName);

      RETURN g_CostCenterSegmentName;

   END GetCostCenterSegmentName;

  /*========================================================================
   | PUBLIC function GetCostCenter
   |
   | DESCRIPTION
   |    Returns the cost center for a given code combination id.
   |
   | PSEUDO CODE/LOGIC
   |
   | PARAMETERS
   |
   | RETURNS
   |    Cost Center
   |
   | KNOWN ISSUES
   |
   | NOTES
   |
   | MODIFICATION HISTORY
   | Date                  Author            Description of Changes
   | 13-MAR-2002           krmenon           Created
   *=======================================================================*/
   FUNCTION GetCostCenter (p_code_combination_id IN NUMBER) RETURN VARCHAR2
   IS
      l_CostCenterSegmentName    FND_SEGMENT_ATTRIBUTE_VALUES.application_column_name%TYPE;
      l_SqlQry                   VARCHAR2(300);
   BEGIN
      -- Check if cached, and return cached value
      IF ( p_code_combination_id = gcc_old_code_combination_id ) THEN
         RETURN gcc_cost_center;
      END IF;

      -- Get the Cost Center Segment Name
      l_CostCenterSegmentName := GetCostCenterSegmentName();

      IF l_CostCenterSegmentName IS NULL THEN
         -- Set the Cache for the Code Combination Id and Return Cost Center Value
         gcc_old_code_combination_id := p_code_combination_id;
         RETURN 'SEGMENTNOTFOUND';
      END IF;

      -- Generate the SQL Statement to get the Cost Center for the Code Combination Id
      -- and execute it.
      l_SqlQry := 'SELECT '||l_CostCenterSegmentName||' FROM GL_CODE_COMBINATIONS '||
                  'WHERE CODE_COMBINATION_ID = :CodeCombinationId';
      EXECUTE IMMEDIATE l_SqlQry INTO gcc_cost_center USING p_code_combination_id;


      -- Set the Cache for the Code Combination Id and Return Cost Center Value
      gcc_old_code_combination_id := p_code_combination_id;
      RETURN gcc_cost_center;

   END GetCostCenter;


  /*========================================================================
   | PUBLIC procedure GetUserAcctInfo
   |
   | DESCRIPTION
   |    Retrieves the Cost Center Segment Name and the Chart Of Accounst Id
   |    for the current user.
   |
   | PSEUDO CODE/LOGIC
   |
   | PARAMETERS
   |
   |    p_cost_center_segment_name    OUT NOCOPY    Cost Center Segment Name
   |    p_chart_of_accounts_id        OUT NOCOPY    Chart Of accounts Id
   |    p_base_currency_code          OUT NOCOPY    Base Currency Code ( Functional Currency )
   |    p_exchange_rate_type          OUT NOCOPY    Exchange Rate Type
   |
   | RETURNS
   |
   | KNOWN ISSUES
   |
   | NOTES
   |
   | MODIFICATION HISTORY
   | Date                  Author            Description of Changes
   | 13-MAR-2002           krmenon           Created
   *=======================================================================*/
   PROCEDURE GetUserAcctInfo ( p_cost_center_segment_name OUT NOCOPY VARCHAR2,
                               p_chart_of_accounts_id     OUT NOCOPY NUMBER,
                               p_base_currency_code       OUT NOCOPY VARCHAR2,
                               p_exchange_rate_type       OUT NOCOPY VARCHAR2)
   IS
      l_chart_of_accounts_id    AP_WEB_DB_AP_INT_PKG.glsob_chartOfAccountsID;
      l_base_currency_code      AP_SYSTEM_PARAMETERS.base_currency_code%Type;
      l_exchange_rate_type      AP_SYSTEM_PARAMETERS.default_exchange_rate_type%Type;
   BEGIN

      -- Query up the Chart of Accounts Id for the Employee
      SELECT GS.chart_of_accounts_id, S.base_currency_code, S.default_exchange_rate_type
      INTO   l_chart_of_accounts_id, l_base_currency_code, l_exchange_rate_type
      FROM   ap_system_parameters S,
             gl_sets_of_books GS
      WHERE  GS.set_of_books_id = S.set_of_books_id
      AND    rownum = 1;

      p_chart_of_accounts_id := l_chart_of_accounts_id;

      p_cost_center_segment_name := GetCostCenterSegmentName();

      p_base_currency_code := l_base_currency_code;

      p_exchange_rate_type := l_exchange_rate_type;

   END GetUserAcctInfo;


   /*=========================================================================================
    | Procedure GetBaseCurrencyInfo
    |
    | Description: This procedure will retrieve the functional currency and the default
    |              exchange rate type for the currenct user.
    |
    | MODIFICATION HISTORY
    | Person      Date         Comments
    | krmenon     29-10-2002   Created
    *=========================================================================================*/
   PROCEDURE GetBaseCurrencyInfo ( P_BaseCurrencyCode   OUT NOCOPY VARCHAR2,
                                   P_ExchangeRateType   OUT NOCOPY VARCHAR2 ) IS
   BEGIN

      SELECT base_currency_code, default_exchange_rate_type
      INTO   P_BaseCurrencyCode, P_ExchangeRateType
      FROM   ap_system_parameters;

      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            AP_WEB_DB_UTIL_PKG.RaiseException ('AP_WEB_OA_REPORTING_UTIL',
                                               'Too many rows found in ap_system_parameters');
            APP_EXCEPTION.RAISE_EXCEPTION;
         WHEN NO_DATA_FOUND THEN
            AP_WEB_DB_UTIL_PKG.RaiseException ('AP_WEB_OA_REPORTING_UTIL',
                                               'No Data Found in ap_system_parameters');
            APP_EXCEPTION.RAISE_EXCEPTION;
         WHEN OTHERS THEN
            AP_WEB_DB_UTIL_PKG.RaiseException ('AP_WEB_OA_REPORTING_UTIL',
                                               SQLERRM);
            APP_EXCEPTION.RAISE_EXCEPTION;

   END GetBaseCurrencyInfo;

   /*=========================================================================================
    | Function MENU_ENTRY_EXISTS
    |
    | Description: This function is wrapper to FND_FUNCTION_SECURITY.MENU_ENTRY_EXISTS
    |              Function call needs to be be used in sql and henceforth should
    |              return a varchar.
    |
    |
    | MODIFICATION HISTORY
    | Person      Date         Comments
    | abordia     22-12-2004   Created
    *=========================================================================================*/
   FUNCTION MENU_ENTRY_EXISTS(
       p_menu_name IN VARCHAR2,
       p_function_name IN VARCHAR2
   ) RETURN VARCHAR2
   IS

   BEGIN
      -- call fnd function which returns boolean, return 'Y' for true else return 'N'
      IF FND_FUNCTION_SECURITY.MENU_ENTRY_EXISTS(p_menu_name, '', p_function_name) THEN
          RETURN 'Y';
      ELSE
          RETURN 'N';
      END IF;
   EXCEPTION WHEN OTHERS THEN
            AP_WEB_DB_UTIL_PKG.RaiseException ('AP_WEB_OA_REPORTING_UTIL',
                                               SQLERRM);
            APP_EXCEPTION.RAISE_EXCEPTION;
   END MENU_ENTRY_EXISTS;


END AP_WEB_OA_REPORTING_UTIL;

/
