--------------------------------------------------------
--  DDL for Package Body AP_WEB_MANAGEMENT_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_MANAGEMENT_REPORTS_PKG" AS
/* $Header: apwmrptb.pls 120.5.12010000.7 2009/12/11 07:20:24 dsadipir ship $ */

   /*=========================================================================================
    | Procedure GetBaseCurrencyInfo
    |
    | Description: This procedure will retrieve the functional currency and the default
    |              exchange rate type for the currenct user.
    |
    | MODIFICATION HISTORY
    | Person      Date         Comments
    | krmenon     06-09-2002   Created
    *=========================================================================================*/
   PROCEDURE GetBaseCurrencyInfo ( P_BaseCurrencyCode   OUT NOCOPY VARCHAR2,
                                   P_ExchangeRateType   OUT NOCOPY VARCHAR2 ) IS
   BEGIN

      -- Bug# 8988384: Exchange rate type should be considered from OIE setup and then from Payables setup.
      SELECT base_currency_code, nvl((select exchange_rate_type from ap_pol_exrate_options where enabled = 'Y'), default_exchange_rate_type) exchange_rate_type
      INTO   P_BaseCurrencyCode, P_ExchangeRateType
      FROM   ap_system_parameters;

      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            AP_WEB_DB_UTIL_PKG.RaiseException ('AP_WEB_MANAGEMENT_REPORTS_PKG.GetBaseCurrencyInfo',
                                                SQLERRM);

            APP_EXCEPTION.RAISE_EXCEPTION;
         WHEN NO_DATA_FOUND THEN
            AP_WEB_DB_UTIL_PKG.RaiseException ('AP_WEB_MANAGEMENT_REPORTS_PKG.GetBaseCurrencyInfo',
                                                SQLERRM);
            APP_EXCEPTION.RAISE_EXCEPTION;
         WHEN OTHERS THEN
            AP_WEB_DB_UTIL_PKG.RaiseException ('AP_WEB_MANAGEMENT_REPORTS_PKG.GetBaseCurrencyInfo',
                                               SQLERRM);
            APP_EXCEPTION.RAISE_EXCEPTION;

   END GetBaseCurrencyInfo;


   /*=========================================================================================
    | Procedure GetPeriodDateRange
    |
    | Description: This procedure will retrieve the date range for a period type and a date
    |              falls in the date range of the period type.
    |
    | MODIFICATION HISTORY
    | Person      Date         Comments
    | krmenon     06-09-2002   Created
    *=========================================================================================*/
   PROCEDURE GetPeriodDateRange ( P_PeriodType   IN VARCHAR2 ,
                                  P_Date         IN VARCHAR2 ,
                                  P_StartDate   OUT NOCOPY DATE,
                                  P_EndDate     OUT NOCOPY DATE ) IS

      --
      -- Cursor to fetch the date range for a given period
      -- and a date.
      --
      CURSOR C_PeriodDateRange ( P_PeriodType VARCHAR2, P_Date VARCHAR2 ) IS
         SELECT glps.start_date, glps.end_date
         FROM   ap_system_parameters SP,
                gl_sets_of_books SOB,
                gl_date_period_map map,
                gl_periods glps
         WHERE SOB.set_of_books_id = SP.set_of_books_id
         AND   MAP.period_set_name = SOB.period_set_name
         AND   MAP.period_type = P_PeriodType
         AND   MAP.accounting_date = to_date(P_Date, icx_sec.getID(icx_sec.PV_DATE_FORMAT))
         AND   GLPS.period_name = MAP.period_name
         AND   GLPS.period_set_name = SOB.period_set_name;

   BEGIN
      FOR rec in C_PeriodDateRange ( P_PeriodType, P_Date )
      LOOP
         P_StartDate := rec.start_date;
         P_EndDate   := rec.end_date;
      END LOOP;

      IF ( P_StartDate IS NULL OR P_EndDate IS NULL ) THEN
         AP_WEB_DB_UTIL_PKG.RaiseException ('OIE_MANAGEMENT_REPORTS_PKG',
                                            'Date Range not defined.',
                                            'OIE_REPORTING_INVALID_DATE');
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
   END GetPeriodDateRange;



   /*=========================================================================================
    | Function
    |
    | Description: This function is a recursive function to find out if the user has acces to
    |              view the data. It will try to find out the supervisor for the user whos data
    |              is being queried and if a match is found for the effective dates then returns
    |              Y, else N.
    |
    |              NOTE:
    |              This is necessary because HR's security profile is based on access as of
    |              today and we need to have it as of the date range being queried for.
    |
    |
    | Parameters:
    |    P_SupervisorId    Employee Id of the supervisor
    |    P_PersionId       Employee Id of the user who's data is being queried
    |    P_StartDate       Start date of the date range in the query
    |    P_EndDate         End date of the date range in the query
    |
    | Returns:
    |    'Y' if supervisor match is found else 'N'
    |
    |
    | MODIFICATION HISTORY
    | Person      Date         Comments
    | krmenon     11-26-2004   Created
    | skoukunt    01-05-2007   bug 5534394: exit when L_ReturnValue is Y, otherwise it would
    |                          return N when multiple assignments exist and the last assignment
    |                          returned by the query does not satisfy the condition.
    *=========================================================================================*/
   FUNCTION IsSupervisor ( P_SupervisorId IN NUMBER,
                           P_PersonId     IN NUMBER,
                           P_StartDate    IN DATE,
                           P_EndDate      IN DATE
                         ) RETURN VARCHAR2 IS

      L_SupervisorId NUMBER(15);
      L_ReturnValue  VARCHAR2(1);

      -- Cursor to fetch supervisor
      CURSOR C_Supervisor (P_StartDate DATE, P_EndDate DATE) IS
         SELECT distinct supervisor_id
         FROM   per_all_assignments_f
         WHERE  person_id = P_PersonId
         AND    P_StartDate < effective_end_date
         AND    P_EndDate > effective_start_date
         AND    assignment_type in ('C','E');

   BEGIN

      -- The supervisor id and person id are the same
      -- data can be viewed
      IF ( P_SupervisorId = P_PersonId ) THEN
         RETURN 'Y';
      END IF;

      -- Find the supervisor for the person
      -- Must traverse all tree branches to determine correct
      -- supervisor
      FOR supervisor in C_Supervisor(P_StartDate, P_EndDate)
      LOOP

         L_SupervisorId := supervisor.supervisor_id;

         -- If the supervisor is null or same as person id
         -- then reached top of hierarchy hence return false
         -- If supervisor is same then return else recurse
         IF ( L_SupervisorId IS NULL ) THEN
            L_ReturnValue := 'N';
         ELSIF ( P_PersonId = L_SupervisorId ) THEN
            L_ReturnValue := 'N';
         ELSIF ( P_SupervisorId = L_SupervisorId ) THEN
            L_ReturnValue := 'Y';
            exit;
         ELSE
            RETURN IsSupervisor(P_SupervisorId, L_SupervisorId, P_StartDate, P_EndDate);
         END IF;

      END LOOP;

      -- Traversed all over and could not find matching record
      RETURN nvl(L_ReturnValue, 'N');

      EXCEPTION
         WHEN OTHERS THEN
            RETURN 'N';

   END IsSupervisor;


   /*=========================================================================================
    | Function
    |
    | Description: This function is a wrapper on the recursive function to find out if the user
    |              has acces to view the data based on the period specified.
    |              NOTE:
    |              This is necessary because HR's security profile is based on access as of
    |              today and we need to have it as of the date range being queried for.
    |
    | Parameters:
    |    P_SupervisorId    Fnd User Id of the supervisor
    |    P_PersionId       Employee Id of the user who's data is being queried
    |    P_PeriodType      The period type for the query (month/quarter ...)
    |    P_Date            The date which falls in the period type being queried
    |
    | Returns:
    |    'Y' if supervisor has permission else 'N'.
    |
    |
    | MODIFICATION HISTORY
    | Person      Date         Comments
    | krmenon     11-26-2004   Created
    *=========================================================================================*/
   FUNCTION HasPermission ( P_SupervisorId IN NUMBER,
                            P_PersonId     IN NUMBER,
                            P_PeriodType   IN VARCHAR2,
                            P_Date      IN DATE
                          ) RETURN VARCHAR2 IS

      L_StartDate       DATE;
      L_EndDate         DATE;
      L_SupervisorEmpId NUMBER(15);
   BEGIN

      -- In this call P_SupervisorId is the fnd user id
      -- So we must get the emp id for this user

      SELECT employee_id
      INTO   L_SupervisorEmpId
      FROM   fnd_user
      WHERE  user_id = P_SupervisorId;

      -- Get the date range for the period
      GetPeriodDateRange ( P_PeriodType   ,
                           P_Date         ,
                           L_StartDate   ,
                           L_EndDate );

      -- Call the recursive func. now
      RETURN IsSupervisor( L_SupervisorEmpId, P_PersonId, L_StartDate, L_EndDate);

      EXCEPTION
         WHEN OTHERS THEN
           IF ((L_StartDate IS NULL) OR (L_EndDate IS NULL)) THEN
             RETURN 'OIE_REPORTING_INVALID_DATE';
           END IF;
           RETURN 'N';

   END HasPermission;


   /*=========================================================================================
    | Function
    |
    | Description: This function is a wrapper on the recursive function to find out if the user
    |              has acces to view the data based on the fnd user and date range specified.
    |              NOTE:
    |              This is necessary because HR's security profile is based on access as of
    |              today and we need to have it as of the date range being queried for.
    |
    |
    | Parameters:
    |    P_SupervisorId    Fnd User Id of the supervisor
    |    P_PersionId       Employee Id of the user who's data is being queried
    |    P_StartDate       Start date of the date range in the query
    |    P_EndDate         End date of the date range in the query
    |
    | Returns:
    |    'Y' if supervisor has permission else 'N'
    |
    |
    | MODIFICATION HISTORY
    | Person      Date         Comments
    | krmenon     11-26-2004   Created
    *=========================================================================================*/
   FUNCTION HasPermission ( P_SupervisorId IN NUMBER,
                            P_PersonId     IN NUMBER,
                            P_StartDate    IN DATE,
                            P_EndDate      IN DATE
                          ) RETURN VARCHAR2 IS

      L_SupervisorEmpId NUMBER(15);

   BEGIN

      -- In this call P_SupervisorId is the fnd user id
      -- So we must get the emp id for this user

      SELECT employee_id
      INTO   L_SupervisorEmpId
      FROM   fnd_user
      WHERE  user_id = P_SupervisorId;

      -- Call the recursive func. now
      RETURN IsSupervisor( L_SupervisorEmpId, P_PersonId, P_StartDate, P_EndDate);

      EXCEPTION
         WHEN OTHERS THEN
            RETURN 'N';

   END HasPermission;


   /*=========================================================================================
    | Procedure
    |
    | Description: This procedure will take calculate the values for the manager expense report
    |              based on the input parameters and store the value into a global temporary
    |              table, which in turn will be used by the BC4J components for UI display.
    |
    | MODIFICATION HISTORY
    | Person      Date         Comments
    | krmenon     06-09-2002   Created
    *=========================================================================================*/
   PROCEDURE ManagerHierarchySearch ( P_EmployeeId         IN    VARCHAR2,
                                      P_ExpenseCategory    IN    VARCHAR2,
                                      P_ViolationType      IN    VARCHAR2,
                                      P_PeriodType         IN    VARCHAR2,
                                      P_Date               IN    VARCHAR2,
                                      P_UserCurrencyCode   IN    VARCHAR2,
                                      P_QryType            IN    VARCHAR2 ) AS

      -- Declare program variables
      TYPE ByManagerRecType IS RECORD (
          employee_id              ap_expense_report_headers.EMPLOYEE_ID%TYPE,
          full_name                per_workforce_x.FULL_NAME%TYPE,
          total_expenses           NUMBER,
          violation_line_amount    NUMBER,
          violation_amount         NUMBER,
          percent_violation        NUMBER,
          number_of_violations     NUMBER,
          most_violated_policy     ap_lookup_codes.DISPLAYED_FIELD%TYPE,
          supervisor_id            per_workforce_x.SUPERVISOR_ID%TYPE,
	  effective_start_date     DATE,   -- 4319234 the two date columns are added to the record
	  effective_end_date       DATE
          );


      TYPE ByManagerTabType IS TABLE OF ByManagerRecType
         INDEX BY BINARY_INTEGER;

      -- Local Variables
      L_ByManagerTab ByManagerTabType;

      L_TabIndex            BINARY_INTEGER := 0;
      L_EmployeeId          ap_expense_report_headers.EMPLOYEE_ID%TYPE;
      L_BaseCurrencyCode    ap_system_parameters.BASE_CURRENCY_CODE%TYPE;
      L_ExchangeRateType    ap_system_parameters.DEFAULT_EXCHANGE_RATE_TYPE%TYPE;
      L_ExpenseAmount       NUMBER := 0;
      L_ViolationLineAmount NUMBER;
      L_ViolationAmount     NUMBER;
      L_Convert             BOOLEAN := FALSE;
      L_StartDate           DATE;
      L_EndDate             DATE;
      L_EffectiveStartDate  DATE;
      L_EffectiveEndDate    DATE;
      L_PrevReportHeaderId  ap_expense_report_headers.REPORT_HEADER_ID%TYPE := 0;
      L_ReportHeaderId      ap_expense_report_headers.REPORT_HEADER_ID%TYPE := 0;
      L_PrevDistributionLineNumber ap_expense_report_lines.DISTRIBUTION_LINE_NUMBER%TYPE;
      L_DistributionLineNumber ap_expense_report_lines.DISTRIBUTION_LINE_NUMBER%TYPE;
      L_NumberOfViolations  NUMBER;

      --
      -- Cursor to fetch the line amounts for an employee for an expense category
      -- for a given period.
      --
      CURSOR C_ExpensesForCategory ( P_EmployeeId       VARCHAR2,
                                     P_ExpenseCategory  VARCHAR2,
                                     P_StartDate        DATE,
                                     P_EndDate          DATE,
                                     P_BaseCurrencyCode VARCHAR2,
                                     P_ExchangeRateType VARCHAR2
                                   ) IS
         SELECT sum(decode(aerl.currency_code, P_BaseCurrencyCode, aerl.amount,
                                               gl_currency_api.CONVERT_AMOUNT_SQL( aerl.currency_code,
                                                                                   P_BaseCurrencyCode,
                                                                                   sysdate,
                                                                                   P_ExchangeRateType,
                                                                                   aerl.amount
                                                                                 ))) as expense_amount
         FROM   ap_expense_report_lines_v aerl
         WHERE  aerl.employee_id = P_EmployeeId
         AND    aerl.week_end_date between P_StartDate and P_EndDate
         AND    nvl(aerl.category_code, 'ALL') = decode(P_ExpenseCategory, 'ALL', nvl(aerl.category_code, 'ALL'), P_ExpenseCategory);

      --
      -- Cursor to fetch lines with violation for an employee/direct report and expense category and violation type
      --
      CURSOR C_ViolationLinesForCategory ( P_EmployeeId       VARCHAR2,
                                           P_ExpenseCategory  VARCHAR2,
                                           P_ViolationType    VARCHAR2,
                                           P_StartDate        VARCHAR2,
                                           P_EndDate          VARCHAR2,
                                           P_BaseCurrencyCode VARCHAR2,
                                           P_ExchangeRateType VARCHAR2
                                         ) IS
        SELECT SUM(line_amount) AS violation_line_amount
        FROM
        (
            SELECT decode(aerl.currency_code, P_BaseCurrencyCode, aerl.amount,
                                               gl_currency_api.CONVERT_AMOUNT_SQL( aerl.currency_code,
                                                                                   P_BaseCurrencyCode,
                                                                                   sysdate,
                                                                                   P_ExchangeRateType,
                                                                                   aerl.amount
                                                                                 )) as line_amount
            FROM   ap_expense_report_lines_v aerl
            WHERE  EXISTS ( SELECT 'X'
                            FROM   ap_pol_violations_all apv
                            WHERE  apv.report_header_id = aerl.report_header_id
                            AND    apv.distribution_line_number = aerl.distribution_line_number
                            AND    apv.violation_type = decode(P_ViolationType, 'ALL', apv.violation_type, P_ViolationType) )
            AND    ( aerl.employee_id= P_EmployeeId or aerl.paid_on_behalf_employee_id = P_EmployeeId )
            AND    aerl.week_end_date BETWEEN P_StartDate AND P_EndDate
            AND    nvl(aerl.category_code, 'ALL') = decode (P_ExpenseCategory, 'ALL', nvl(aerl.category_code, 'ALL'), P_ExpenseCategory)
        );

      --
      -- Cursor to fetch the violation amounts for an employee for an expense category
      -- for a violation type and for a period.
      --
      CURSOR C_ViolationsForExpenseCategory ( P_EmployeeId       VARCHAR2,
                                              P_ExpenseCategory  VARCHAR2,
                                              P_ViolationType    VARCHAR2,
                                              P_StartDate        DATE,
                                              P_EndDate          DATE,
                                              P_BaseCurrencyCode VARCHAR2,
                                              P_ExchangeRateType VARCHAR2
                                            ) IS
         SELECT sum(violation_amount) as violation_amount,
                sum(number_of_violations) as number_of_violations
         FROM
         (  SELECT sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.violation_amount,
                                  gl_currency_api.CONVERT_AMOUNT_SQL( aerv.currency_code,
                                                                      P_BaseCurrencyCode,
                                                                      sysdate,
                                                                      P_ExchangeRateType,
                                                                      aerv.violation_amount
                                                                     ))) as violation_amount,
                   count(aerv.report_header_id) as number_of_violations
            FROM   ap_expense_report_violations_v aerv
            WHERE  ( (aerv.employee_id = P_EmployeeId) or (aerv.paid_on_behalf_employee_id = P_EmployeeId))
            AND    aerv.week_end_date between P_StartDate and P_EndDate
            AND    nvl(aerv.category_code, 'ALL') = decode(P_ExpenseCategory, 'ALL', nvl(aerv.category_code, 'ALL'), P_ExpenseCategory)
            AND    aerv.violation_type = decode(P_ViolationType, 'ALL', aerv.violation_type, P_ViolationType)
	    AND    aerv.violation_type NOT IN ( 'RECEIPT_MISSING', 'DAILY_SUM_LIMIT')
            UNION ALL
            /* The below query is to fetch the daily sum limit violations for MEALS category */
            SELECT decode(aerh.default_currency_code, P_BaseCurrencyCode, apv.exceeded_amount,
                                    GL_CURRENCY_API.convert_amount_sql( aerh.default_currency_code,
                                                                        P_BaseCurrencyCode,
                                                                        SYSDATE,
                                                                        P_ExchangeRateType,
                                                                        apv.exceeded_amount
                                                                       )) as violation_amount,
                   1 as number_of_violations
            FROM  ap_expense_report_headers_all aerh,
                  ap_pol_violations_all apv
            WHERE aerh.report_header_id = apv.report_header_id
            AND   apv.distribution_line_number = -1
            AND   (aerh.source <> 'NonValidatedWebExpense' OR aerh.workflow_approved_flag IS NULL)
            AND   aerh.source <> 'Both Pay'
            AND   NVL(aerh.expense_status_code,
                      AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(aerh.Source,
                                                               aerh.Workflow_approved_flag,
                                                               aerh.report_header_id,
                                                               'N'
                                                               )) IN ('MGRPAYAPPR','INVOICED','PAID')
            AND   ( (aerh.employee_id = P_EmployeeId) or (aerh.paid_on_behalf_employee_id = P_EmployeeId))
	    AND  ( (P_ViolationType = 'ALL') or (P_ViolationType = 'DAILY_SUM_LIMIT')) AND   apv.violation_type = 'DAILY_SUM_LIMIT'
	    AND   ( 'MEALS' = P_ExpenseCategory OR 'ALL' = P_ExpenseCategory)
	    AND   aerh.week_end_date BETWEEN P_StartDate AND P_EndDate
            UNION ALL
            /* The below query is to bundle up RECEIPT_MISSING violations per line */
            SELECT sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.violation_amount,
                                    GL_CURRENCY_API.convert_amount_sql( aerv.currency_code,
                                                                        P_BaseCurrencyCode,
                                                                        SYSDATE,
                                                                        P_ExchangeRateType,
                                                                        aerv.violation_amount
                                                                       ))) as violation_amount,
                   1 as number_of_violations
            FROM  ap_expense_report_violations_v aerv
            WHERE  ( (aerv.employee_id = P_EmployeeId) or (aerv.paid_on_behalf_employee_id = P_EmployeeId))
	    AND  ( (P_ViolationType = 'ALL') or (P_ViolationType = 'RECEIPT_MISSING')) AND   aerv.violation_type = 'RECEIPT_MISSING'
            AND    nvl(aerv.category_code, 'ALL') = decode(P_ExpenseCategory, 'ALL', nvl(aerv.category_code, 'ALL'), P_ExpenseCategory)
	    AND   aerv.week_end_date BETWEEN P_StartDate AND P_EndDate
	    group by nvl(aerv.itemization_parent_id, aerv.report_line_id)
        );


      --
      -- Cursor to fetch the violation type with max violations
      --
      CURSOR C_MaxViolationByType (  P_EmployeeId       VARCHAR2,
                                     P_ExpenseCategory  VARCHAR2,
                                     P_StartDate        DATE,
                                     P_EndDate          DATE
                                  ) IS
      SELECT count(number_of_violations),
   		  violation_type
	from
	(
	 SELECT 1 as number_of_violations,
            alc.displayed_field as violation_type
         FROM   ap_lookup_codes alc,
                ap_expense_report_violations_v aerv
         WHERE  alc.lookup_type    = 'OIE_POL_VIOLATION_TYPES'
         AND    alc.lookup_code    = aerv.violation_type
         AND    ( aerv.employee_id = P_EmployeeId OR aerv.paid_on_behalf_employee_id = P_EmployeeId)
         AND    aerv.week_end_date between P_StartDate and P_EndDate
         AND    nvl(aerv.category_code, 'ALL') = decode(P_ExpenseCategory, 'ALL', nvl(aerv.category_code, 'ALL'), P_ExpenseCategory)
         AND    aerv.violation_type NOT IN ( 'RECEIPT_MISSING', 'DAILY_SUM_LIMIT')
         UNION ALL
         /* Count all the violations for Daily Sum Limit */
         SELECT 1 as number_of_violations,
                alc.displayed_field as violation_type
         FROM  ap_expense_report_headers_all aerh,
               ap_pol_violations_all apv,
               ap_lookup_codes alc
         WHERE aerh.report_header_id = apv.report_header_id
         AND   apv.distribution_line_number = -1
         AND   (aerh.source <> 'NonValidatedWebExpense' OR aerh.workflow_approved_flag IS NULL)
         AND   aerh.source <> 'Both Pay'
         AND   NVL(aerh.expense_status_code,
                   AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(aerh.Source,
                                                            aerh.Workflow_approved_flag,
                                                            aerh.report_header_id,
                                                            'N'
                                                            )) IN ('MGRPAYAPPR','INVOICED','PAID')
         AND   apv.violation_type = 'DAILY_SUM_LIMIT'
         AND    ( aerh.employee_id = P_EmployeeId OR aerh.paid_on_behalf_employee_id = P_EmployeeId)
         AND   ( 'MEALS' = P_ExpenseCategory OR 'ALL' = P_ExpenseCategory)
         AND    aerh.week_end_date between P_StartDate and P_EndDate
         AND   apv.violation_type = alc.lookup_code
         AND   alc.lookup_type    = 'OIE_POL_VIOLATION_TYPES'
	 UNION ALL
         /* Count all the violations for Receipts missing */
	 SELECT 1 as number_of_violations,
                alc.displayed_field as violation_type
         FROM   ap_lookup_codes alc,
                ap_expense_report_violations_v aerv
         WHERE  alc.lookup_type    = 'OIE_POL_VIOLATION_TYPES'
         AND    alc.lookup_code    = aerv.violation_type
         AND    ( aerv.employee_id = P_EmployeeId OR aerv.paid_on_behalf_employee_id = P_EmployeeId)
         AND    aerv.week_end_date between P_StartDate and P_EndDate
         AND    nvl(aerv.category_code, 'ALL') = decode(P_ExpenseCategory, 'ALL', nvl(aerv.category_code, 'ALL'), P_ExpenseCategory)
         AND    aerv.violation_type = 'RECEIPT_MISSING'
	 group by nvl(aerv.itemization_parent_id, aerv.report_line_id), alc.displayed_field
	   )
       GROUP BY violation_type
       ORDER BY 1 desc;

      --
      -- Cursor to fetch all employee and direct reports
      --
      CURSOR C_Employees ( P_EmployeeId VARCHAR2,
                           P_QryType    VARCHAR2,
                           P_StartDate  DATE,
                           P_EndDate    DATE ) IS
/*         SELECT distinct
                pap.full_name,
                pap.person_id,
                paa.supervisor_id,
                greatest(paa.effective_start_date, P_StartDate) as Start_Date,
                least(paa.effective_end_date, P_EndDate) as End_Date
         FROM   per_all_people_f pap,
                per_all_assignments_f paa
         WHERE  pap.person_id = paa.person_id
         AND    pap.person_id = P_EmployeeId
         AND    P_StartDate < paa.effective_end_date
         AND    P_EndDate   > paa.effective_start_date
         AND    (paa.assignment_type = 'E' OR paa.assignment_type = 'C')
         AND    P_StartDate < pap.effective_end_date
         AND    P_EndDate   > pap.effective_start_date
         UNION ALL
         SELECT distinct
                pap.full_name,
                pap.person_id,
                paa.supervisor_id,
                greatest(paa.effective_start_date, P_StartDate) as Start_Date,
                least(paa.effective_end_date, P_EndDate) as End_Date
         FROM   per_all_people_f pap,
                per_all_assignments_f paa
         WHERE  pap.person_id = paa.person_id
         AND    paa.supervisor_id = P_EmployeeId
         AND    'MANAGER'     = P_QryType
         AND    P_StartDate < paa.effective_end_date
         AND    P_EndDate   > paa.effective_start_date
         AND    (paa.assignment_type = 'E' OR paa.assignment_type = 'C')
         AND    P_StartDate < pap.effective_end_date
         AND    P_EndDate   > pap.effective_start_date;
*/
-- 4319234: Query changed to produce only a coalesce assignmetns separated by 1 day
SELECT  FULL_NAME,
        PERSON_ID,
        SUPERVISOR_ID,
        GREATEST( P_StartDate,  MIN( effective_start_date ) )  as Start_Date,
        MAX_END_DATE  as End_Date
FROM
(         SELECT distinct
                pap.full_name,
                pap.person_id,
                paa.supervisor_id,
                pap.effective_start_date,
                paa.effective_end_date,
                ( select least( P_EndDate , max(effective_end_date) )
                  from per_all_assignments_f
                  where person_id = pap.person_id
                    and supervisor_id = paa.supervisor_id
                    and ( assignment_type = 'E' OR assignment_type = 'C')
                  start with effective_start_date = paa.effective_start_date
                  connect by person_id = pap.person_id
                         and supervisor_id = paa.supervisor_id
                         AND ( assignment_type = 'E' OR assignment_type = 'C')
                         and prior effective_end_date =  ( effective_start_date - 1 )
                ) max_end_date
         FROM   per_all_people_f pap,
                per_all_assignments_f paa,
		per_assignment_status_types past
         WHERE  pap.person_id = paa.person_id
         AND    ( pap.person_id = P_EmployeeId or ( P_QryType = 'MANAGER' AND paa.supervisor_id = P_EmployeeId ) )
         AND    P_StartDate <= paa.effective_end_date
         AND    P_EndDate  >= paa.effective_start_date
         AND    (paa.assignment_type = 'E' OR paa.assignment_type = 'C')
         AND    P_StartDate <= pap.effective_end_date
         AND    P_EndDate  >= pap.effective_start_date
	 AND	past.assignment_status_type_id = paa.assignment_status_type_id
	 AND	past.per_system_status in ('ACTIVE_ASSIGN','ACTIVE_CWK')
) V1
WHERE max_end_date is not null
GROUP BY FULL_NAME, PERSON_ID, SUPERVISOR_ID, MAX_END_DATE;

   BEGIN


      -- Get the period date range
      GetPeriodDateRange(P_PeriodType, P_Date, L_StartDate, L_EndDate);


      -- Get the Base Currency Code
      GetBaseCurrencyInfo(L_BaseCurrencyCode, L_ExchangeRateType);

      -- If the base currency is not same as user preference currency the
      -- set the conversion flag to true
      IF ( L_BaseCurrencyCode <> NVL(P_UserCurrencyCode, L_BaseCurrencyCode) ) THEN
         L_Convert := TRUE;
      END IF;

      --
      -- Begin the loop to fetch data
      --
      FOR emprec in C_Employees( P_EmployeeId, P_QryType, L_StartDate, L_EndDate )
      LOOP
         -- Increment Table Index
         L_TabIndex := L_TabIndex + 1;

         L_ByManagerTab( L_TabIndex ).employee_id   := emprec.person_id;
         L_ByManagerTab( L_TabIndex ).full_name     := emprec.full_name;
         L_ByManagerTab( L_TabIndex ).supervisor_id := emprec.supervisor_id;

         -- Initialize all amounts fields as 0
         L_ByManagerTab( L_TabIndex ).total_expenses         := 0;
         L_ByManagerTab( L_TabIndex ).violation_line_amount  := 0;
         L_ByManagerTab( L_TabIndex ).violation_amount       := 0;
         L_ByManagerTab( L_TabIndex ).percent_violation      := 0;
         L_ByManagerTab( L_TabIndex ).number_of_violations   := 0;
         L_ByManagerTab( L_TabIndex ).most_violated_policy   := NULL;

         L_EmployeeId := emprec.person_id;
         L_EffectiveStartDate := emprec.start_date;
         L_EffectiveEndDate := emprec.end_date;
         L_ExpenseAmount := 0;
         L_PrevReportHeaderId := 0;
         L_PrevDistributionLineNumber := 0;
         L_ReportHeaderId := 0;
         L_DistributionLineNumber := 0;

 	 -- Change for 4319234 as it is necessary to store every assignment's start date and end date
         L_ByManagerTab( L_TabIndex ).effective_start_date   := L_EffectiveStartDate;
         L_ByManagerTab( L_TabIndex ).effective_end_date   := L_EffectiveEndDate;

	 -- Get total expenses for a category
         FOR exprec in C_ExpensesForCategory ( L_EmployeeId,
                                               P_ExpenseCategory,
                                               L_EffectiveStartDate,
                                               L_EffectiveEndDate,
                                               L_BaseCurrencyCode,
                                               L_ExchangeRateType
                                               )
         LOOP
            L_ExpenseAmount := L_ExpenseAmount + NVL(exprec.expense_amount,0);
         END LOOP;


         -- Get total violations for a category and violation type
         L_ViolationLineAmount := 0;
         L_ViolationAmount := 0;
         L_NumberOfViolations := 0;
         L_PrevReportHeaderId := 0;
         L_PrevDistributionLineNumber := 0;
         L_ReportHeaderId := 0;
         L_DistributionLineNumber := 0;

         -- Get the total for the lines which have violations
         FOR violline in C_ViolationLinesForCategory ( L_EmployeeId,
                                                       P_ExpenseCategory,
                                                       P_ViolationType,
                                                       L_EffectiveStartDate,
                                                       L_EffectiveEndDate,
                                                       L_BaseCurrencyCode,
                                                       L_ExchangeRateType
                                                     )
         LOOP
            L_ViolationLineAmount := L_ViolationLineAmount + NVL(violline.violation_line_amount,0);
         END LOOP;

         -- Get the violaiton totals
         FOR violrec in C_ViolationsForExpenseCategory ( L_EmployeeId,
                                                         P_ExpenseCategory,
                                                         P_ViolationType,
                                                         L_EffectiveStartDate,
                                                         L_EffectiveEndDate,
                                                         L_BaseCurrencyCode,
                                                         L_ExchangeRateType
                                                       )
         LOOP
            L_ViolationAmount := L_ViolationAmount + NVL(violrec.violation_amount,0);

            -- Get number of violations
            L_NumberOfViolations   := L_NumberOfViolations + violrec.number_of_violations;
         END LOOP;

         -- Calculate % of violation
         -- Bug 2925136: Round the value for percentage calculation to 2 decimal places
         IF ( L_ViolationLineAmount > 0 ) THEN
            L_ByManagerTab( L_TabIndex ).percent_violation   := round((L_ViolationAmount * 100) /
                                                                 L_ViolationLineAmount , 2 );
         END IF;

         L_ByManagerTab( L_TabIndex ).number_of_violations   := L_NumberOfViolations;

         -- If amount needs to be converted to user preference currency
         -- convert the amounts
         IF ( L_Convert ) THEN
            L_ByManagerTab( L_TabIndex ).total_expenses := gl_currency_api.CONVERT_AMOUNT_SQL(
                                                              L_BaseCurrencyCode,
                                                              P_UserCurrencyCode,
                                                              sysdate,
                                                              L_ExchangeRateType,
                                                              L_ExpenseAmount
                                                           );

            L_ByManagerTab( L_TabIndex ).violation_line_amount := gl_currency_api.CONVERT_AMOUNT_SQL(
                                                              L_BaseCurrencyCode,
                                                              P_UserCurrencyCode,
                                                              sysdate,
                                                              L_ExchangeRateType,
                                                              L_ViolationLineAmount
                                                           );
            L_ByManagerTab( L_TabIndex ).violation_amount := gl_currency_api.CONVERT_AMOUNT_SQL(
                                                              L_BaseCurrencyCode,
                                                              P_UserCurrencyCode,
                                                              sysdate,
                                                              L_ExchangeRateType,
                                                              L_ViolationAmount
                                                           );
         ELSE
            L_ByManagerTab( L_TabIndex ).total_expenses        := round(L_ExpenseAmount, 2);
            L_ByManagerTab( L_TabIndex ).violation_line_amount := round(L_ViolationLineAmount, 2);
            L_ByManagerTab( L_TabIndex ).violation_amount      := round(L_ViolationAmount, 2);
         END IF;

         -- Fetch the most violated violation type
         FOR maxviolrec in C_MaxViolationByType (  L_EmployeeId,
                                                   P_ExpenseCategory,
                                                   L_EffectiveStartDate,
                                                   L_EffectiveEndDate
                                                )
         LOOP
            L_ByManagerTab( L_TabIndex ).most_violated_policy   := maxviolrec.violation_type;
            -- akita/krmenon 27 Jul 2004
            -- need to exit after fetch of first row as that has the max.
            exit;
         END LOOP;

      END LOOP;

      -- Clear previous query results
      DELETE FROM AP_WEB_MANAGEMENT_REPORTS_GT;

      FOR i in 1..L_TabIndex
      LOOP
         -- Insert search results into global temporary table
         INSERT INTO AP_WEB_MANAGEMENT_REPORTS_GT (
            EMPLOYEE_ID,
            SUPERVISOR_ID,
            TOTAL_EXPENSES,
            VIOLATION_LINE_AMOUNT,
            VIOLATION_AMOUNT,
            PERCENT_VIOLATION,
            NUMBER_OF_VIOLATIONS,
            MOST_VIOLATED_POLICY,
            FULL_NAME,
            EXPENSE_CATEGORY,
            VIOLATION_TYPE,
            PERIOD_TYPE,
            PERIOD_DATE,
            START_DATE_RANGE,
            END_DATE_RANGE,
            ROLLUP_TYPE,
            REPORTING_CURRENCY_CODE
         )
         VALUES (
            L_ByManagerTab( i ).employee_id,
            L_ByManagerTab( i ).supervisor_id,
            L_ByManagerTab( i ).total_expenses,
            L_ByManagerTab( i ).violation_line_amount,
            L_ByManagerTab( i ).violation_amount,
            L_ByManagerTab( i ).percent_violation,
            L_ByManagerTab( i ).number_of_violations,
            L_ByManagerTab( i ).most_violated_policy,
            L_ByManagerTab( i ).full_name,
            P_ExpenseCategory,
            P_ViolationType,
            P_PeriodType,
            P_Date,
            L_ByManagerTab( i ).effective_start_date,
            L_ByManagerTab( i ).effective_end_date,
            P_QryType,
            NVL(P_UserCurrencyCode, L_BaseCurrencyCode)
         );

      END LOOP;

      -- Commit all the inserts
      COMMIT;

      EXCEPTION
         WHEN OTHERS THEN
             AP_WEB_DB_UTIL_PKG.RaiseException ('AP_WEB_MANAGEMENT_REPORTING_PKG.ManagerHierarchySearch',
                                               SQLERRM);
             APP_EXCEPTION.RAISE_EXCEPTION;
             -- dbms_output.put_line('EXCEPTION: '||SQLERRM)  ;


   END ManagerHierarchySearch;


   /*=========================================================================================
    | Procedure
    |
    | Description: This procedure will take calculate the values for the expense category
    |              report based on the input parameters and store the value into a global
    |              temporary table, which in turn will be used by the BC4J components for
    |              UI display.
    |
    | MODIFICATION HISTORY
    | Person      Date         Comments
    | krmenon     06-09-2002   Created
    *=========================================================================================*/
   PROCEDURE ExpenseCategorySearch ( P_EmployeeId         IN    VARCHAR2 ,
                                     P_ExpenseCategory    IN    VARCHAR2 ,
                                     P_ViolationType      IN    VARCHAR2 ,
                                     P_PeriodType         IN    VARCHAR2 ,
                                     P_Date               IN    VARCHAR2 ,
                                     P_UserCurrencyCode   IN    VARCHAR2 ,
                                     P_QryType            IN    VARCHAR2 ) IS

      -- Declare program variables
      TYPE ByExpenseCategoryRecType IS RECORD (
            employee_id              ap_expense_report_headers.EMPLOYEE_ID%TYPE,
            total_expenses           NUMBER,
            violation_line_amount    NUMBER,
            violation_amount         NUMBER,
            allowable_amount         NUMBER,
            percent_violation        NUMBER,
            percent_allowable        NUMBER,
            number_of_violations     NUMBER,
            expense_category         ap_lookup_codes.LOOKUP_CODE%TYPE,
            expense_category_desc    ap_lookup_codes.DISPLAYED_FIELD%TYPE
         );


      TYPE ByExpenseCategoryTabType IS TABLE OF ByExpenseCategoryRecType
         INDEX BY BINARY_INTEGER;

      -- Local Variables
      L_ByExpCatTab ByExpenseCategoryTabType;

      L_TabIndex            BINARY_INTEGER := 0;
      L_EmployeeId          ap_expense_report_headers.EMPLOYEE_ID%TYPE;
      L_BaseCurrencyCode    ap_system_parameters.BASE_CURRENCY_CODE%TYPE;
      L_ExchangeRateType    ap_system_parameters.DEFAULT_EXCHANGE_RATE_TYPE%TYPE;
      L_ExpenseCategory     ap_lookup_codes.LOOKUP_CODE%TYPE;
      L_ExpenseAmount       NUMBER := 0;
      L_ViolationLineAmount NUMBER;
      L_ViolationAmount     NUMBER;
      L_AllowableAmount     NUMBER;
      L_Convert             BOOLEAN := FALSE;
      L_StartDate           DATE;
      L_EndDate             DATE;
      L_PrevReportHeaderId  ap_expense_report_headers.REPORT_HEADER_ID%TYPE := 0;
      L_ReportHeaderId      ap_expense_report_headers.REPORT_HEADER_ID%TYPE := 0;
      L_PrevDistributionLineNumber ap_expense_report_lines.DISTRIBUTION_LINE_NUMBER%TYPE;
      L_DistributionLineNumber ap_expense_report_lines.DISTRIBUTION_LINE_NUMBER%TYPE;
      L_NumberOfViolations  NUMBER;


      --
      -- Cursor to fetch all expense categories
      --
      CURSOR C_ExpenseCategories ( P_ExpenseCategory VARCHAR2 )IS
         SELECT lookup_code,
                displayed_field
         FROM   ap_lookup_codes
         WHERE  lookup_type = 'OIE_EXPENSE_CATEGORY'
         AND    lookup_code = decode (P_ExpenseCategory, 'ALL', lookup_code, P_ExpenseCategory);

      --
      -- Cursor to fetch expense amount for an employee/direct report and expense category
      --
      CURSOR C_ExpenseAmountForCategory ( P_EmployeeId      VARCHAR2,
                                          P_StartDate       DATE,
                                          P_EndDate         DATE,
                                          P_ExpenseCategory VARCHAR2,
                                          P_QryType         VARCHAR2,
                                          P_BaseCurrencyCode VARCHAR2,
                                          P_ExchangeRateType VARCHAR2
                                         ) IS
         SELECT sum(NVL(expense_amount,0)) as expense_amount
         FROM
         (  SELECT decode(aerl.currency_code, P_BaseCurrencyCode, aerl.amount,
                                               gl_currency_api.CONVERT_AMOUNT_SQL( aerl.currency_code,
                                                                                   P_BaseCurrencyCode,
                                                                                   sysdate,
                                                                                   P_ExchangeRateType,
                                                                                   aerl.amount
                                                                                 )) as expense_amount
            FROM   ap_expense_report_lines_v aerl
            WHERE  ((aerl.employee_id= P_EmployeeId) or (aerl.paid_on_behalf_employee_id = P_EmployeeId))
            AND    aerl.week_end_date BETWEEN P_StartDate AND P_EndDate
            AND    nvl(aerl.category_code, 'ALL') = decode (P_ExpenseCategory, 'ALL', nvl(aerl.category_code, 'ALL'), P_ExpenseCategory)
            UNION ALL
            SELECT decode(aerl.currency_code, P_BaseCurrencyCode, aerl.amount,
                                               gl_currency_api.CONVERT_AMOUNT_SQL( aerl.currency_code,
                                                                                   P_BaseCurrencyCode,
                                                                                   sysdate,
                                                                                   P_ExchangeRateType,
                                                                                   aerl.amount
                                                                                 )) as expense_amount
            FROM   per_all_assignments_f paf,
                   ap_expense_report_lines_v aerl
            WHERE  paf.supervisor_id = P_EmployeeId
            AND    paf.effective_start_date < P_EndDate
            AND    paf.effective_end_date > P_StartDate
            AND    (paf.assignment_type = 'E' OR paf.assignment_type = 'C')
            AND    (( aerl.employee_id = paf.person_id) or (aerl.paid_on_behalf_employee_id = paf.person_id))
            AND    aerl.week_end_date BETWEEN greatest(paf.effective_start_date,P_StartDate) AND least(paf.effective_end_date,P_EndDate)
            AND    nvl(aerl.category_code, 'ALL') = decode (P_ExpenseCategory, 'ALL', nvl(aerl.category_code, 'ALL'), P_ExpenseCategory)
            AND    'MANAGER' = P_QryType
         );

      --
      -- Cursor to fetch lines with violation for an employee/direct report and expense category and violation type
      --
      CURSOR C_ViolationLinesForCategory ( P_EmployeeId       VARCHAR2,
                                           P_ExpenseCategory  VARCHAR2,
                                           P_ViolationType    VARCHAR2,
                                           P_StartDate        VARCHAR2,
                                           P_EndDate          VARCHAR2,
                                           P_BaseCurrencyCode VARCHAR2,
                                           P_ExchangeRateType VARCHAR2
                                         ) IS
        SELECT SUM(line_amount) AS violation_line_amount
        FROM
        (
            SELECT decode(aerl.currency_code, P_BaseCurrencyCode, aerl.amount,
                                               gl_currency_api.CONVERT_AMOUNT_SQL( aerl.currency_code,
                                                                                   P_BaseCurrencyCode,
                                                                                   sysdate,
                                                                                   P_ExchangeRateType,
                                                                                   aerl.amount
                                                                                 )) as line_amount
            FROM   ap_expense_report_lines_v aerl
            WHERE  EXISTS ( SELECT 'X'
                            FROM   ap_pol_violations_all apv
                            WHERE  apv.report_header_id = aerl.report_header_id
                            AND    apv.distribution_line_number = aerl.distribution_line_number
                            AND    apv.violation_type = decode(P_ViolationType, 'ALL', apv.violation_type, P_ViolationType) )
            AND    ((aerl.employee_id= P_EmployeeId) or (aerl.paid_on_behalf_employee_id = P_EmployeeId))
            AND    aerl.week_end_date BETWEEN P_StartDate AND P_EndDate
            AND    nvl(aerl.category_code, 'ALL') = decode (P_ExpenseCategory, 'ALL', nvl(aerl.category_code, 'ALL'), P_ExpenseCategory)
            UNION ALL
            SELECT decode(aerl.currency_code, P_BaseCurrencyCode, aerl.amount,
                                               gl_currency_api.CONVERT_AMOUNT_SQL( aerl.currency_code,
                                                                                   P_BaseCurrencyCode,
                                                                                   sysdate,
                                                                                   P_ExchangeRateType,
                                                                                   aerl.amount
                                                                                 )) as line_amount
            FROM   ap_expense_report_lines_v aerl,
                   per_all_assignments_f paf
            WHERE  EXISTS ( SELECT 'X'
                            FROM   ap_pol_violations_all apv
                            WHERE  apv.report_header_id = aerl.report_header_id
                            AND    apv.distribution_line_number = aerl.distribution_line_number
                            AND    apv.violation_type = decode(P_ViolationType, 'ALL', apv.violation_type, P_ViolationType) )
            AND    paf.supervisor_id = P_EmployeeId
            AND    paf.effective_start_date < P_EndDate
            AND    paf.effective_end_date > P_StartDate
            AND    (paf.assignment_type = 'E' OR paf.assignment_type = 'C')
            AND    ((aerl.employee_id = paf.person_id) or (aerl.paid_on_behalf_employee_id = paf.person_id))
            AND    aerl.week_end_date BETWEEN greatest(paf.effective_start_date,P_StartDate) AND least(paf.effective_end_date,P_EndDate)
            AND    nvl(aerl.category_code, 'ALL') = decode (P_ExpenseCategory, 'ALL', nvl(aerl.category_code, 'ALL'), P_ExpenseCategory)
            AND    'MANAGER' = P_QryType
        );

      --
      -- Cursor to fetch violation amounts for an employee/direct report and expense category and violation type
      --
      CURSOR C_ViolationsForCategory ( P_EmployeeId       VARCHAR2,
                                       P_ExpenseCategory  VARCHAR2,
                                       P_ViolationType    VARCHAR2,
                                       P_StartDate        VARCHAR2,
                                       P_EndDate          VARCHAR2,
                                       P_BaseCurrencyCode VARCHAR2,
                                       P_ExchangeRateType VARCHAR2
                                     ) IS
         SELECT sum(nvl(violation_amount,0)) as violation_amount,
                sum(nvl(allowable_amount,0)) as allowable_amount,
                sum(nvl(number_of_violations,0)) as number_of_violations
         FROM
         (
            SELECT sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.violation_amount,
                                  gl_currency_api.CONVERT_AMOUNT_SQL( aerv.currency_code,
                                                                      P_BaseCurrencyCode,
                                                                      sysdate,
                                                                      P_ExchangeRateType,
                                                                      aerv.violation_amount
                                                                     ))) as violation_amount,
                   sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.allowable_amount,
                                  gl_currency_api.CONVERT_AMOUNT_SQL( aerv.currency_code,
                                                                      P_BaseCurrencyCode,
                                                                      sysdate,
                                                                      P_ExchangeRateType,
                                                                      aerv.allowable_amount
                                                                     ))) as allowable_amount,
                   count(aerv.report_header_id) as number_of_violations
            FROM   ap_expense_report_violations_v aerv
            WHERE  ((aerv.employee_id = P_EmployeeId) or (aerv.paid_on_behalf_employee_id = P_EmployeeId))
            AND    aerv.week_end_date between P_StartDate and P_EndDate
            AND    nvl(aerv.category_code, 'ALL') = decode(P_ExpenseCategory, 'ALL', nvl(aerv.category_code, 'ALL'), P_ExpenseCategory)
            AND    aerv.violation_type = decode(P_ViolationType, 'ALL', aerv.violation_type, P_ViolationType)
		    AND    aerv.violation_type NOT IN ( 'RECEIPT_MISSING', 'DAILY_SUM_LIMIT')
            UNION ALL
            SELECT sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.violation_amount,
                                  gl_currency_api.CONVERT_AMOUNT_SQL( aerv.currency_code,
                                                                      P_BaseCurrencyCode,
                                                                      sysdate,
                                                                      P_ExchangeRateType,
                                                                      aerv.violation_amount
                                                                     ))) as violation_amount,
                   sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.allowable_amount,
                                  gl_currency_api.CONVERT_AMOUNT_SQL( aerv.currency_code,
                                                                      P_BaseCurrencyCode,
                                                                      sysdate,
                                                                      P_ExchangeRateType,
                                                                      aerv.allowable_amount
                                                                     ))) as allowable_amount,
                   count(aerv.report_header_id) as number_of_violations
            FROM   per_all_assignments_f paf,
                   ap_expense_report_violations_v aerv
            WHERE  paf.supervisor_id = P_EmployeeId
            AND    paf.effective_start_date < P_EndDate
            AND    paf.effective_end_date > P_StartDate
            AND    (paf.assignment_type = 'E' OR paf.assignment_type = 'C')
            AND    ((aerv.employee_id = paf.person_id) or (aerv.paid_on_behalf_employee_id = paf.person_id))
            AND    aerv.week_end_date BETWEEN greatest(paf.effective_start_date, P_StartDate) AND least(paf.effective_end_date, P_EndDate)
            AND    nvl(aerv.category_code, 'ALL') = decode(P_ExpenseCategory, 'ALL', nvl(aerv.category_code, 'ALL'), P_ExpenseCategory)
            AND    aerv.violation_type = decode(P_ViolationType, 'ALL', aerv.violation_type, P_ViolationType)
            AND    'MANAGER' = P_QryType
	    	AND    aerv.violation_type NOT IN ( 'RECEIPT_MISSING', 'DAILY_SUM_LIMIT')
            UNION ALL
            /* The below two queries are to fetch the daily sum limit violations for MEALS category */
            SELECT decode(aerh.default_currency_code, P_BaseCurrencyCode, apv.exceeded_amount,
                                    GL_CURRENCY_API.convert_amount_sql( aerh.default_currency_code,
                                                                        P_BaseCurrencyCode,
                                                                        SYSDATE,
                                                                        P_ExchangeRateType,
                                                                        apv.exceeded_amount
                                                                       )) as violation_amount,
                   decode(aerh.default_currency_code, P_BaseCurrencyCode, apv.allowable_amount,
                                    GL_CURRENCY_API.convert_amount_sql( aerh.default_currency_code,
                                                                        P_BaseCurrencyCode,
                                                                        SYSDATE,
                                                                        P_ExchangeRateType,
                                                                        apv.allowable_amount
                                                                       )) as allowable_amount,
                   1 as number_of_violations
            FROM  ap_expense_report_headers_all aerh,
                  ap_pol_violations_all apv
            WHERE aerh.report_header_id = apv.report_header_id
            AND   aerh.org_id = apv.org_id
            AND   apv.distribution_line_number = -1
            AND   (aerh.source <> 'NonValidatedWebExpense' OR aerh.workflow_approved_flag IS NULL)
            AND   aerh.source <> 'Both Pay'
            AND   NVL(aerh.expense_status_code,
                      AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(aerh.Source,
                                                               aerh.Workflow_approved_flag,
                                                               aerh.report_header_id,
                                                               'N'
                                                               )) IN ('MGRPAYAPPR','INVOICED','PAID')
	    AND  ( (P_ViolationType = 'ALL') or (P_ViolationType = 'DAILY_SUM_LIMIT')) AND   apv.violation_type = 'DAILY_SUM_LIMIT'
	    AND   ( 'MEALS' = P_ExpenseCategory OR 'ALL' = P_ExpenseCategory)
            AND   (aerh.employee_id = P_EmployeeId OR aerh.paid_on_behalf_employee_id = P_EmployeeId)
            AND   aerh.week_end_date BETWEEN P_StartDate AND P_EndDate
            UNION ALL
            SELECT decode(aerh.default_currency_code, P_BaseCurrencyCode, apv.exceeded_amount,
                                    GL_CURRENCY_API.convert_amount_sql( aerh.default_currency_code,
                                                                        P_BaseCurrencyCode,
                                                                        SYSDATE,
                                                                        P_ExchangeRateType,
                                                                        apv.exceeded_amount
                                                                       )) as violation_amount,
                   decode(aerh.default_currency_code, P_BaseCurrencyCode, apv.allowable_amount,
                                    GL_CURRENCY_API.convert_amount_sql( aerh.default_currency_code,
                                                                        P_BaseCurrencyCode,
                                                                        SYSDATE,
                                                                        P_ExchangeRateType,
                                                                        apv.allowable_amount
                                                                       )) as allowable_amount,
                   1 as number_of_violations
            FROM  ap_expense_report_headers_all aerh,
                  ap_pol_violations_all apv,
                  per_all_assignments_f paf
            WHERE aerh.report_header_id = apv.report_header_id
            AND   aerh.org_id = apv.org_id
            AND   apv.distribution_line_number = -1
            AND   (aerh.source <> 'NonValidatedWebExpense' OR aerh.workflow_approved_flag IS NULL)
            AND   aerh.source <> 'Both Pay'
            AND   NVL(aerh.expense_status_code,
                      AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(aerh.source,
                                                               aerh.workflow_approved_flag,
                                                               aerh.report_header_id,
                                                               'N'
                                                               )) IN ('MGRPAYAPPR','INVOICED','PAID')
            AND   paf.supervisor_id = P_EmployeeId
            AND   paf.effective_start_date < P_EndDate
            AND   paf.effective_end_date > P_StartDate
            AND    (paf.assignment_type = 'E' OR paf.assignment_type = 'C')
            AND   ( aerh.employee_id = paf.person_id OR aerh.paid_on_behalf_employee_id = paf.person_id )
	    AND  ( (P_ViolationType = 'ALL') or (P_ViolationType = 'DAILY_SUM_LIMIT')) AND   apv.violation_type = 'DAILY_SUM_LIMIT'
	    AND   ( 'MEALS' = P_ExpenseCategory OR 'ALL' = P_ExpenseCategory)
            AND   aerh.week_end_date between P_StartDate and P_EndDate
            AND    'MANAGER' = P_QryType
            /* The below query is to bundle up RECEIPT_MISSING violations per line */
	   UNION ALL
	    SELECT sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.violation_amount,
                                  gl_currency_api.CONVERT_AMOUNT_SQL( aerv.currency_code,
                                                                      P_BaseCurrencyCode,
                                                                      sysdate,
                                                                      P_ExchangeRateType,
                                                                      aerv.violation_amount
                                                                     ))) as violation_amount,
                   sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.allowable_amount,
                                  gl_currency_api.CONVERT_AMOUNT_SQL( aerv.currency_code,
                                                                      P_BaseCurrencyCode,
                                                                      sysdate,
                                                                      P_ExchangeRateType,
                                                                      aerv.allowable_amount
                                                                     ))) as allowable_amount,
                   count(aerv.report_header_id) as number_of_violations
            FROM   ap_expense_report_violations_v aerv
            WHERE  ((aerv.employee_id = P_EmployeeId) or (aerv.paid_on_behalf_employee_id = P_EmployeeId))
            AND    aerv.week_end_date between P_StartDate and P_EndDate
            AND    nvl(aerv.category_code, 'ALL') = decode(P_ExpenseCategory, 'ALL', nvl(aerv.category_code, 'ALL'), P_ExpenseCategory)
            AND    ((P_ViolationType = 'ALL') or (P_ViolationType = 'RECEIPT_MISSING')) AND   aerv.violation_type = 'RECEIPT_MISSING'
        	group by nvl(aerv.itemization_parent_id, aerv.report_line_id)
			UNION ALL
            SELECT sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.violation_amount,
                                  gl_currency_api.CONVERT_AMOUNT_SQL( aerv.currency_code,
                                                                      P_BaseCurrencyCode,
                                                                      sysdate,
                                                                      P_ExchangeRateType,
                                                                      aerv.violation_amount
                                                                     ))) as violation_amount,
                   sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.allowable_amount,
                                  gl_currency_api.CONVERT_AMOUNT_SQL( aerv.currency_code,
                                                                      P_BaseCurrencyCode,
                                                                      sysdate,
                                                                      P_ExchangeRateType,
                                                                      aerv.allowable_amount
                                                                     ))) as allowable_amount,
                   count(aerv.report_header_id) as number_of_violations
            FROM   per_all_assignments_f paf,
                   ap_expense_report_violations_v aerv
            WHERE  paf.supervisor_id = P_EmployeeId
            AND    paf.effective_start_date < P_EndDate
            AND    paf.effective_end_date > P_StartDate
            AND    (paf.assignment_type = 'E' OR paf.assignment_type = 'C')
            AND    ((aerv.employee_id = paf.person_id) or (aerv.paid_on_behalf_employee_id = paf.person_id))
            AND    aerv.week_end_date BETWEEN greatest(paf.effective_start_date, P_StartDate) AND least(paf.effective_end_date, P_EndDate)
            AND    nvl(aerv.category_code, 'ALL') = decode(P_ExpenseCategory, 'ALL', nvl(aerv.category_code, 'ALL'), P_ExpenseCategory)
            AND    ((P_ViolationType = 'ALL') or (P_ViolationType = 'RECEIPT_MISSING')) AND   aerv.violation_type = 'RECEIPT_MISSING'
            AND    'MANAGER' = P_QryType
       	   group by nvl(aerv.itemization_parent_id, aerv.report_line_id)
         );


   BEGIN

      -- Get the period date range
      GetPeriodDateRange(P_PeriodType, P_Date, L_StartDate, L_EndDate);


      -- Get the Base Currency Code
      GetBaseCurrencyInfo(L_BaseCurrencyCode, L_ExchangeRateType);

      -- If the base currency is not same as user preference currency the
      -- set the conversion flag to true
      IF ( L_BaseCurrencyCode <> NVL(P_UserCurrencyCode,L_BaseCurrencyCode) ) THEN
         L_Convert := TRUE;
      END IF;

      -- Fetch data for all expense categories
      FOR expcatrec in C_ExpenseCategories ( P_ExpenseCategory )
      LOOP
         -- Increment Table Index
         L_TabIndex := L_TabIndex + 1;

         L_ExpenseCategory := expcatrec.lookup_code;
         L_ByExpCatTab( L_TabIndex ).expense_category       := expcatrec.lookup_code;
         L_ByExpCatTab( L_TabIndex ).expense_category_desc  := expcatrec.displayed_field;

         -- Initialize all amounts fields as 0
         L_ByExpCatTab( L_TabIndex ).total_expenses         := 0;
         L_ByExpCatTab( L_TabIndex ).violation_line_amount  := 0;
         L_ByExpCatTab( L_TabIndex ).violation_amount       := 0;
         L_ByExpCatTab( L_TabIndex ).allowable_amount       := 0;
         L_ByExpCatTab( L_TabIndex ).percent_violation      := 0;
         L_ByExpCatTab( L_TabIndex ).percent_allowable      := 0;
         L_ByExpCatTab( L_TabIndex ).number_of_violations   := 0;

         L_ExpenseAmount := 0;
         L_PrevReportHeaderId := 0;
         L_PrevDistributionLineNumber := 0;
         L_ReportHeaderId := 0;
         L_DistributionLineNumber := 0;

         -- Fetch expenses for the category
         FOR exprec in C_ExpenseAmountForCategory(P_EmployeeId,
                                                  L_StartDate,
                                                  L_EndDate,
                                                  L_ExpenseCategory,
                                                  P_QryType,
                                                  L_BaseCurrencyCode,
                                                  L_ExchangeRateType
                                                  )
         LOOP
            L_ExpenseAmount := L_ExpenseAmount + NVL(exprec.expense_amount,0);
         END LOOP;


         -- Fetch violations for the category
         L_ViolationLineAmount := 0;
         L_ViolationAmount := 0;
         L_AllowableAmount := 0;
         L_NumberOfViolations := 0;
         L_PrevReportHeaderId := 0;
         L_PrevDistributionLineNumber := 0;
         L_ReportHeaderId := 0;
         L_DistributionLineNumber := 0;

         -- Get the total for the lines which have violations
         FOR violline in C_ViolationLinesForCategory ( P_EmployeeId,
                                                       L_ExpenseCategory,
                                                       P_ViolationType,
                                                       L_StartDate,
                                                       L_EndDate,
                                                       L_BaseCurrencyCode,
                                                       L_ExchangeRateType
                                                     )
         LOOP
            L_ViolationLineAmount := L_ViolationLineAmount + NVL(violline.violation_line_amount,0);
         END LOOP;

         -- Get the total of violations and allowable amounts
         FOR violrec in C_ViolationsForCategory ( P_EmployeeId,
                                                  L_ExpenseCategory,
                                                  P_ViolationType,
                                                  L_StartDate,
                                                  L_EndDate,
                                                  L_BaseCurrencyCode,
                                                  L_ExchangeRateType
                                                )
         LOOP

            L_ViolationAmount := L_ViolationAmount + NVL(violrec.violation_amount,0);
            L_AllowableAmount := L_AllowableAmount + NVL(violrec.allowable_amount,0);

            -- Get number of violations
            L_NumberOfViolations   := L_NumberOfViolations + violrec.number_of_violations;

         END LOOP;

         -- Calculate % of violation
         -- Bug 2925136: Round the value for percentage calculation to 2 decimal places
         IF ( L_ExpenseAmount > 0 ) THEN
            L_ByExpCatTab( L_TabIndex ).percent_violation   := round((L_ViolationAmount * 100) /
                                                                 L_ExpenseAmount , 2 );
         END IF;

         -- Calculate % of allowable amount
         -- Bug 2925136: Round the value for percentage calculation to 2 decimal places
         IF ( L_AllowableAmount > 0 ) THEN
            L_ByExpCatTab( L_TabIndex ).percent_allowable   := round((L_ViolationAmount * 100) /
                                                                 L_AllowableAmount , 2 );
         END IF;

         -- Get number of violations
         L_ByExpCatTab( L_TabIndex ).number_of_violations   := L_NumberOfViolations;

         -- If amount needs to be converted to user preference currency
         -- convert the amounts
         IF ( L_Convert ) THEN
            L_ByExpCatTab( L_TabIndex ).total_expenses := gl_currency_api.CONVERT_AMOUNT_SQL(
                                                              L_BaseCurrencyCode,
                                                              P_UserCurrencyCode,
                                                              sysdate,
                                                              L_ExchangeRateType,
                                                              L_ExpenseAmount
                                                           );
            L_ByExpCatTab( L_TabIndex ).violation_line_amount := gl_currency_api.CONVERT_AMOUNT_SQL(
                                                              L_BaseCurrencyCode,
                                                              P_UserCurrencyCode,
                                                              sysdate,
                                                              L_ExchangeRateType,
                                                              L_ViolationLineAmount
                                                           );
            L_ByExpCatTab( L_TabIndex ).violation_amount := gl_currency_api.CONVERT_AMOUNT_SQL(
                                                              L_BaseCurrencyCode,
                                                              P_UserCurrencyCode,
                                                              sysdate,
                                                              L_ExchangeRateType,
                                                              L_ViolationAmount
                                                           );
            L_ByExpCatTab( L_TabIndex ).allowable_amount := gl_currency_api.CONVERT_AMOUNT_SQL(
                                                              L_BaseCurrencyCode,
                                                              P_UserCurrencyCode,
                                                              sysdate,
                                                              L_ExchangeRateType,
                                                              L_AllowableAmount
                                                           );
         ELSE
            L_ByExpCatTab( L_TabIndex ).total_expenses        := round(L_ExpenseAmount, 2);
            L_ByExpCatTab( L_TabIndex ).violation_line_amount := round(L_ViolationLineAmount, 2);
            L_ByExpCatTab( L_TabIndex ).violation_amount      := round(L_ViolationAmount, 2);
            L_ByExpCatTab( L_TabIndex ).allowable_amount      := round(L_AllowableAmount, 2);
         END IF;

      END LOOP;

      -- Clear previous query results
      DELETE FROM AP_WEB_MANAGEMENT_REPORTS_GT;

      FOR i in 1..L_TabIndex
      LOOP
         -- Insert search results into global temporary table
         INSERT INTO AP_WEB_MANAGEMENT_REPORTS_GT (
            EMPLOYEE_ID,
            TOTAL_EXPENSES,
            VIOLATION_LINE_AMOUNT,
            VIOLATION_AMOUNT,
            ALLOWABLE_AMOUNT,
            PERCENT_VIOLATION,
            PERCENT_ALLOWABLE,
            NUMBER_OF_VIOLATIONS,
            EXPENSE_CATEGORY,
            EXPENSE_CATEGORY_DESC,
            VIOLATION_TYPE,
            PERIOD_TYPE,
            PERIOD_DATE,
            ROLLUP_TYPE,
            REPORTING_CURRENCY_CODE
         )
         VALUES (
            P_EmployeeId,
            L_ByExpCatTab( i ).total_expenses,
            L_ByExpCatTab( i ).violation_line_amount,
            L_ByExpCatTab( i ).violation_amount,
            L_ByExpCatTab( i ).allowable_amount,
            L_ByExpCatTab( i ).percent_violation,
            L_ByExpCatTab( i ).percent_allowable,
            L_ByExpCatTab( i ).number_of_violations,
            L_ByExpCatTab( i ).expense_category,
            L_ByExpCatTab( i ).expense_category_desc,
            P_ViolationType,
            P_PeriodType,
            P_Date,
            P_QryType,
            NVL(P_UserCurrencyCode, L_BaseCurrencyCode)
         );

      END LOOP;

      -- Commit all the inserts
      COMMIT;

      EXCEPTION
         WHEN OTHERS THEN
           AP_WEB_DB_UTIL_PKG.RaiseException ('AP_WEB_MANAGEMENT_REPORTING_PKG.ExpenseCategorySearch',
                                               SQLERRM);
           APP_EXCEPTION.RAISE_EXCEPTION;
           -- dbms_output.put_line('EXCEPTION: '||SQLERRM)  ;

   END ExpenseCategorySearch;


   /*=========================================================================================
    | Procedure
    |
    | Description: This procedure will take calculate the values for the violation type
    |              report based on the input parameters and store the value into a global
    |              temporary table, which in turn will be used by the BC4J components for
    |              UI display.
    |
    | MODIFICATION HISTORY
    | Person      Date         Comments
    | krmenon     06-09-2002   Created
    *=========================================================================================*/
   PROCEDURE ViolationTypeSearch ( P_EmployeeId         IN    VARCHAR2 ,
                                   P_ExpenseCategory    IN    VARCHAR2 ,
                                   P_ViolationType      IN    VARCHAR2 ,
                                   P_PeriodType         IN    VARCHAR2 ,
                                   P_Date               IN    VARCHAR2 ,
                                   P_UserCurrencyCode   IN    VARCHAR2 ,
                                   P_QryType            IN    VARCHAR2 ) IS

      -- Declare program variables
      TYPE ByViolationTypeRecType IS RECORD (
            employee_id              ap_expense_report_headers.EMPLOYEE_ID%TYPE,
            violation_line_amount    NUMBER,
            violation_amount         NUMBER,
            allowable_amount         NUMBER,
            percent_violation        NUMBER,
            percent_allowable        NUMBER,
            number_of_violations     NUMBER,
            violation_type           ap_lookup_codes.LOOKUP_CODE%TYPE,
            violation_type_desc      ap_lookup_codes.DISPLAYED_FIELD%TYPE
         );


      TYPE ByViolationTypeTabType IS TABLE OF ByViolationTypeRecType
         INDEX BY BINARY_INTEGER;

      -- Local Variables
      L_ByViolTypeTab ByViolationTypeTabType;

      L_TabIndex            BINARY_INTEGER := 0;
      L_EmployeeId          ap_expense_report_headers.EMPLOYEE_ID%TYPE;
      L_BaseCurrencyCode    ap_system_parameters.BASE_CURRENCY_CODE%TYPE;
      L_ExchangeRateType    ap_system_parameters.DEFAULT_EXCHANGE_RATE_TYPE%TYPE;
      L_ViolationType       ap_lookup_codes.LOOKUP_CODE%TYPE;
      L_ViolationLineAmount NUMBER;
      L_ViolationAmount     NUMBER;
      L_AllowableAmount     NUMBER;
      L_Convert             BOOLEAN := FALSE;
      L_StartDate           DATE;
      L_EndDate             DATE;
      L_PrevReportHeaderId  ap_expense_report_headers.REPORT_HEADER_ID%TYPE := 0;
      L_ReportHeaderId      ap_expense_report_headers.REPORT_HEADER_ID%TYPE := 0;
      L_PrevDistributionLineNumber ap_expense_report_lines.DISTRIBUTION_LINE_NUMBER%TYPE;
      L_DistributionLineNumber ap_expense_report_lines.DISTRIBUTION_LINE_NUMBER%TYPE;
      L_NumberOfViolations  NUMBER;


      --
      -- Cursor to fetch all violation types
      --
      CURSOR C_ViolationTypes ( P_ViolationType VARCHAR2 )IS
         SELECT lookup_code,
                displayed_field
         FROM   ap_lookup_codes
         WHERE  lookup_type = 'OIE_POL_VIOLATION_TYPES'
         AND    lookup_code = decode (P_ViolationType, 'ALL', lookup_code, P_ViolationType);

      --
      -- Cursor to fetch lines with violation for an employee/direct report and expense category and violation type
      --
      CURSOR C_ViolationLinesForCategory ( P_EmployeeId       VARCHAR2,
                                           P_ExpenseCategory  VARCHAR2,
                                           P_ViolationType    VARCHAR2,
                                           P_StartDate        VARCHAR2,
                                           P_EndDate          VARCHAR2,
                                           P_BaseCurrencyCode VARCHAR2,
                                           P_ExchangeRateType VARCHAR2
                                         ) IS
        SELECT SUM(line_amount) AS violation_line_amount
        FROM
        (
            SELECT decode(aerl.currency_code, P_BaseCurrencyCode, aerl.amount,
                                               gl_currency_api.CONVERT_AMOUNT_SQL( aerl.currency_code,
                                                                                   P_BaseCurrencyCode,
                                                                                   sysdate,
                                                                                   P_ExchangeRateType,
                                                                                   aerl.amount
                                                                                 )) as line_amount
            FROM   ap_expense_report_lines_v aerl
            WHERE  EXISTS ( SELECT 'X'
                            FROM   ap_pol_violations_all apv
                            WHERE  apv.report_header_id = aerl.report_header_id
                            AND    apv.distribution_line_number = aerl.distribution_line_number
                            AND    apv.violation_type = decode(P_ViolationType, 'ALL', apv.violation_type, P_ViolationType))
            AND    ((aerl.employee_id= P_EmployeeId) or (aerl.paid_on_behalf_employee_id = P_EmployeeId))
            AND    aerl.week_end_date BETWEEN P_StartDate AND P_EndDate
            AND    nvl(aerl.category_code, 'ALL') = decode (P_ExpenseCategory, 'ALL', nvl(aerl.category_code, 'ALL'), P_ExpenseCategory)
            UNION ALL
            SELECT decode(aerl.currency_code, P_BaseCurrencyCode, aerl.amount,
                                               gl_currency_api.CONVERT_AMOUNT_SQL( aerl.currency_code,
                                                                                   P_BaseCurrencyCode,
                                                                                   sysdate,
                                                                                   P_ExchangeRateType,
                                                                                   aerl.amount
                                                                                 )) as line_amount
            FROM   ap_expense_report_lines_v aerl,
                   per_all_assignments_f paf
            WHERE  EXISTS ( SELECT 'X'
                            FROM   ap_pol_violations_all apv
                            WHERE  apv.report_header_id = aerl.report_header_id
                            AND    apv.distribution_line_number = aerl.distribution_line_number
                            AND    apv.violation_type = decode(P_ViolationType, 'ALL', apv.violation_type, P_ViolationType) )
            AND    paf.supervisor_id = P_EmployeeId
            AND    paf.effective_start_date < P_EndDate
            AND    paf.effective_end_date > P_StartDate
            AND    (paf.assignment_type = 'E' OR paf.assignment_type = 'C')
            AND    ((aerl.employee_id = paf.person_id) or (aerl.paid_on_behalf_employee_id = paf.person_id))
            AND    aerl.week_end_date BETWEEN greatest(paf.effective_start_date,P_StartDate) AND least(paf.effective_end_date,P_EndDate)
            AND    nvl(aerl.category_code, 'ALL') = decode (P_ExpenseCategory, 'ALL', nvl(aerl.category_code, 'ALL'), P_ExpenseCategory)
            AND    'MANAGER' = P_QryType
            AND    aerl.paid_on_behalf_employee_id IS NULL
        );

      --
      -- Cursor to fetch violation amount for an employee/direct report and expense category and violation type
      --
      CURSOR C_ViolationsForCategory ( P_EmployeeId       VARCHAR2,
                                       P_ExpenseCategory  VARCHAR2,
                                       P_ViolationType    VARCHAR2,
                                       P_StartDate        VARCHAR2,
                                       P_EndDate          VARCHAR2,
                                       P_BaseCurrencyCode VARCHAR2,
                                       P_ExchangeRateType VARCHAR2
                                     ) IS
         SELECT sum(nvl(violation_amount,0)) as violation_amount,
                sum(nvl(allowable_amount,0)) as allowable_amount,
                sum(nvl(number_of_violations,0)) as number_of_violations
         FROM
         (
            SELECT sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.violation_amount,
                                  gl_currency_api.CONVERT_AMOUNT_SQL( aerv.currency_code,
                                                                      P_BaseCurrencyCode,
                                                                      sysdate,
                                                                      P_ExchangeRateType,
                                                                      aerv.violation_amount
                                                                     ))) as violation_amount,
                   sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.allowable_amount,
                                  gl_currency_api.CONVERT_AMOUNT_SQL( aerv.currency_code,
                                                                      P_BaseCurrencyCode,
                                                                      sysdate,
                                                                      P_ExchangeRateType,
                                                                      aerv.allowable_amount
                                                                     ))) as allowable_amount,
                   count(aerv.report_header_id) as number_of_violations
            FROM   ap_expense_report_violations_v aerv
            WHERE  ((aerv.employee_id = P_EmployeeId) or (aerv.paid_on_behalf_employee_id = P_EmployeeId))
            AND    aerv.week_end_date between P_StartDate and P_EndDate
            AND    nvl(aerv.category_code, 'ALL') = decode(P_ExpenseCategory, 'ALL', nvl(aerv.category_code, 'ALL'), P_ExpenseCategory)
            AND    aerv.violation_type = decode(P_ViolationType, 'ALL', aerv.violation_type, P_ViolationType)
		    AND    aerv.violation_type NOT IN ( 'RECEIPT_MISSING', 'DAILY_SUM_LIMIT')
            UNION ALL
            SELECT sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.violation_amount,
                                  gl_currency_api.CONVERT_AMOUNT_SQL( aerv.currency_code,
                                                                      P_BaseCurrencyCode,
                                                                      sysdate,
                                                                      P_ExchangeRateType,
                                                                      aerv.violation_amount
                                                                     ))) as violation_amount,
                   sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.allowable_amount,
                                  gl_currency_api.CONVERT_AMOUNT_SQL( aerv.currency_code,
                                                                      P_BaseCurrencyCode,
                                                                      sysdate,
                                                                      P_ExchangeRateType,
                                                                      aerv.allowable_amount
                                                                     ))) as allowable_amount,
                   count(aerv.report_header_id) as number_of_violations
            FROM   per_all_assignments_f paf,
                   ap_expense_report_violations_v aerv
            WHERE  paf.supervisor_id = P_EmployeeId
            AND    paf.effective_start_date < P_EndDate
            AND    paf.effective_end_date > P_StartDate
            AND    (paf.assignment_type = 'E' OR paf.assignment_type = 'C')
            AND    ((aerv.employee_id = paf.person_id) or (aerv.paid_on_behalf_employee_id = paf.person_id))
            AND    aerv.week_end_date BETWEEN greatest(paf.effective_start_date, P_StartDate) AND least(paf.effective_end_date, P_EndDate)
            AND    nvl(aerv.category_code, 'ALL') = decode(P_ExpenseCategory, 'ALL', nvl(aerv.category_code, 'ALL'), P_ExpenseCategory)
            AND    aerv.violation_type = decode(P_ViolationType, 'ALL', aerv.violation_type, P_ViolationType)
            AND    'MANAGER' = P_QryType
	    AND    aerv.violation_type NOT IN ( 'RECEIPT_MISSING', 'DAILY_SUM_LIMIT')
            UNION ALL
            /* The below two queries are to fetch the daily sum limit violations for MEALS category */
            SELECT decode(aerh.default_currency_code, P_BaseCurrencyCode, apv.exceeded_amount,
                                    GL_CURRENCY_API.convert_amount_sql( aerh.default_currency_code,
                                                                        P_BaseCurrencyCode,
                                                                        SYSDATE,
                                                                        P_ExchangeRateType,
                                                                        apv.exceeded_amount
                                                                       )) as violation_amount,
                   decode(aerh.default_currency_code, P_BaseCurrencyCode, apv.allowable_amount,
                                    GL_CURRENCY_API.convert_amount_sql( aerh.default_currency_code,
                                                                        P_BaseCurrencyCode,
                                                                        SYSDATE,
                                                                        P_ExchangeRateType,
                                                                        apv.allowable_amount
                                                                       )) as allowable_amount,
                   1 as number_of_violations
            FROM  ap_expense_report_headers_all aerh,
                  ap_pol_violations_all apv
            WHERE aerh.report_header_id = apv.report_header_id
            AND   aerh.org_id = apv.org_id
            AND   apv.distribution_line_number = -1
            AND   (aerh.source <> 'NonValidatedWebExpense' OR aerh.workflow_approved_flag IS NULL)
            AND   aerh.source <> 'Both Pay'
            AND   NVL(aerh.expense_status_code,
                      AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(aerh.Source,
                                                               aerh.Workflow_approved_flag,
                                                               aerh.report_header_id,
                                                               'N'
                                                               )) IN ('MGRPAYAPPR','INVOICED','PAID')
	    AND  ( (P_ViolationType = 'ALL') or (P_ViolationType = 'DAILY_SUM_LIMIT')) AND   apv.violation_type = 'DAILY_SUM_LIMIT'
	    AND   ( 'MEALS' = P_ExpenseCategory OR 'ALL' = P_ExpenseCategory)
            AND   (aerh.employee_id = P_EmployeeId OR aerh.paid_on_behalf_employee_id = P_EmployeeId)
            AND   aerh.week_end_date BETWEEN P_StartDate AND P_EndDate
            UNION ALL
            SELECT decode(aerh.default_currency_code, P_BaseCurrencyCode, apv.exceeded_amount,
                                    GL_CURRENCY_API.convert_amount_sql( aerh.default_currency_code,
                                                                        P_BaseCurrencyCode,
                                                                        SYSDATE,
                                                                        P_ExchangeRateType,
                                                                        apv.exceeded_amount
                                                                       )) as violation_amount,
                   decode(aerh.default_currency_code, P_BaseCurrencyCode, apv.allowable_amount,
                                    GL_CURRENCY_API.convert_amount_sql( aerh.default_currency_code,
                                                                        P_BaseCurrencyCode,
                                                                        SYSDATE,
                                                                        P_ExchangeRateType,
                                                                        apv.allowable_amount
                                                                       )) as allowable_amount,
                   1 as number_of_violations
            FROM  ap_expense_report_headers_all aerh,
                  ap_pol_violations_all apv,
                  per_all_assignments_f paf
            WHERE aerh.report_header_id = apv.report_header_id
            AND   aerh.org_id = apv.org_id
            AND   apv.distribution_line_number = -1
            AND   (aerh.source <> 'NonValidatedWebExpense' OR aerh.workflow_approved_flag IS NULL)
            AND   aerh.source <> 'Both Pay'
            AND   NVL(aerh.expense_status_code,
                      AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(aerh.source,
                                                               aerh.workflow_approved_flag,
                                                               aerh.report_header_id,
                                                               'N'
                                                               )) IN ('MGRPAYAPPR','INVOICED','PAID')
            AND   paf.supervisor_id = P_EmployeeId
            AND   paf.effective_start_date < P_EndDate
            AND   paf.effective_end_date > P_StartDate
            AND    (paf.assignment_type = 'E' OR paf.assignment_type = 'C')
            AND   ( aerh.employee_id = paf.person_id OR aerh.paid_on_behalf_employee_id = paf.person_id )
	    AND  ( (P_ViolationType = 'ALL') or (P_ViolationType = 'DAILY_SUM_LIMIT')) AND   apv.violation_type = 'DAILY_SUM_LIMIT'
	    AND   ( 'MEALS' = P_ExpenseCategory OR 'ALL' = P_ExpenseCategory)
            AND   aerh.week_end_date between P_StartDate and P_EndDate
            AND    'MANAGER' = P_QryType
            /* The below query is to bundle up RECEIPT_MISSING violations per line */
			UNION ALL
			SELECT sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.violation_amount,
                                  gl_currency_api.CONVERT_AMOUNT_SQL( aerv.currency_code,
                                                                      P_BaseCurrencyCode,
                                                                      sysdate,
                                                                      P_ExchangeRateType,
                                                                      aerv.violation_amount
                                                                     ))) as violation_amount,
                   sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.allowable_amount,
                                  gl_currency_api.CONVERT_AMOUNT_SQL( aerv.currency_code,
                                                                      P_BaseCurrencyCode,
                                                                      sysdate,
                                                                      P_ExchangeRateType,
                                                                      aerv.allowable_amount
                                                                     ))) as allowable_amount,
                   count(aerv.report_header_id) as number_of_violations
            FROM   ap_expense_report_violations_v aerv
            WHERE  ((aerv.employee_id = P_EmployeeId) or (aerv.paid_on_behalf_employee_id = P_EmployeeId))
            AND    aerv.week_end_date between P_StartDate and P_EndDate
            AND    nvl(aerv.category_code, 'ALL') = decode(P_ExpenseCategory, 'ALL', nvl(aerv.category_code, 'ALL'), P_ExpenseCategory)
            AND    ((P_ViolationType = 'ALL') or (P_ViolationType = 'RECEIPT_MISSING')) AND   aerv.violation_type = 'RECEIPT_MISSING'
            group by nvl(aerv.itemization_parent_id, aerv.report_line_id)
	    UNION ALL
            SELECT sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.violation_amount,
                                  gl_currency_api.CONVERT_AMOUNT_SQL( aerv.currency_code,
                                                                      P_BaseCurrencyCode,
                                                                      sysdate,
                                                                      P_ExchangeRateType,
                                                                      aerv.violation_amount
                                                                     ))) as violation_amount,
                   sum(decode(aerv.currency_code, P_BaseCurrencyCode, aerv.allowable_amount,
                                  gl_currency_api.CONVERT_AMOUNT_SQL( aerv.currency_code,
                                                                      P_BaseCurrencyCode,
                                                                      sysdate,
                                                                      P_ExchangeRateType,
                                                                      aerv.allowable_amount
                                                                     ))) as allowable_amount,
                   count(aerv.report_header_id) as number_of_violations
            FROM   per_all_assignments_f paf,
                   ap_expense_report_violations_v aerv
            WHERE  paf.supervisor_id = P_EmployeeId
            AND    paf.effective_start_date < P_EndDate
            AND    paf.effective_end_date > P_StartDate
            AND    (paf.assignment_type = 'E' OR paf.assignment_type = 'C')
            AND    ((aerv.employee_id = paf.person_id) or (aerv.paid_on_behalf_employee_id = paf.person_id))
            AND    aerv.week_end_date BETWEEN greatest(paf.effective_start_date, P_StartDate) AND least(paf.effective_end_date, P_EndDate)
            AND    nvl(aerv.category_code, 'ALL') = decode(P_ExpenseCategory, 'ALL', nvl(aerv.category_code, 'ALL'), P_ExpenseCategory)
            AND    ((P_ViolationType = 'ALL') or (P_ViolationType = 'RECEIPT_MISSING')) AND   aerv.violation_type = 'RECEIPT_MISSING'
            AND    'MANAGER' = P_QryType
            group by nvl(aerv.itemization_parent_id, aerv.report_line_id)
         );

   BEGIN

      -- Get the period date range
      GetPeriodDateRange(P_PeriodType, P_Date, L_StartDate, L_EndDate);


      -- Get the Base Currency Code
      GetBaseCurrencyInfo(L_BaseCurrencyCode, L_ExchangeRateType);

      -- If the base currency is not same as user preference currency the
      -- set the conversion flag to true
      IF ( L_BaseCurrencyCode <> NVL(P_UserCurrencyCode, L_BaseCurrencyCode) ) THEN
         L_Convert := TRUE;
      END IF;


      -- Fetch data for all expense categories
      FOR violtyperec in C_ViolationTypes ( P_ViolationType )
      LOOP
         -- Increment Table Index
         L_TabIndex := L_TabIndex + 1;

         L_ViolationType := violtyperec.lookup_code;

         L_ByViolTypeTab( L_TabIndex ).violation_type       := violtyperec.lookup_code;
         L_ByViolTypeTab( L_TabIndex ).violation_type_desc  := violtyperec.displayed_field;

         -- Initialize all amounts fields as 0
         L_ByViolTypeTab( L_TabIndex ).violation_line_amount  := 0;
         L_ByViolTypeTab( L_TabIndex ).violation_amount       := 0;
         L_ByViolTypeTab( L_TabIndex ).allowable_amount       := 0;
         L_ByViolTypeTab( L_TabIndex ).percent_violation      := 0;
         L_ByViolTypeTab( L_TabIndex ).percent_allowable      := 0;
         L_ByViolTypeTab( L_TabIndex ).number_of_violations   := 0;

         -- Fetch violations for the category
         L_ViolationLineAmount := 0;
         L_ViolationAmount := 0;
         L_AllowableAmount := 0;
         L_NumberOfViolations := 0;
         L_PrevReportHeaderId := 0;
         L_PrevDistributionLineNumber := 0;
         L_ReportHeaderId := 0;
         L_DistributionLineNumber := 0;

         -- Get the total for the lines which have violations
         FOR violline in C_ViolationLinesForCategory ( P_EmployeeId,
                                                       P_ExpenseCategory,
                                                       L_ViolationType,
                                                       L_StartDate,
                                                       L_EndDate,
                                                       L_BaseCurrencyCode,
                                                       L_ExchangeRateType
                                                       )
         LOOP
            L_ViolationLineAmount := L_ViolationLineAmount + NVL(violline.violation_line_amount,0);
         END LOOP;

         -- Get the total of violations and allowable amounts
         FOR violrec in C_ViolationsForCategory ( P_EmployeeId,
                                                  P_ExpenseCategory,
                                                  L_ViolationType,
                                                  L_StartDate,
                                                  L_EndDate,
                                                  L_BaseCurrencyCode,
                                                  L_ExchangeRateType
                                                )
         LOOP

            L_ViolationAmount := L_ViolationAmount + NVL(violrec.violation_amount,0);
            L_AllowableAmount := L_AllowableAmount + NVL(violrec.allowable_amount,0);

            -- Get number of violations
            L_NumberOfViolations   := L_NumberOfViolations + violrec.number_of_violations;

         END LOOP;


         -- Calculate % of violation
         -- Bug 2925136: Round the value for percentage calculation to 2 decimal places
         IF ( L_ViolationLineAmount > 0 ) THEN
           L_ByViolTypeTab( L_TabIndex ).percent_violation   := round((L_ViolationAmount * 100) /
                                                                    L_ViolationLineAmount , 2 );
         END IF;

         -- Calculate % of allowable amount
         -- Bug 2925136: Round the value for percentage calculation to 2 decimal places
         IF ( L_AllowableAmount > 0 ) THEN
           L_ByViolTypeTab( L_TabIndex ).percent_allowable   := round((L_ViolationAmount * 100) /
                                                                    L_AllowableAmount , 2 );
         END IF;

         -- Get number of violations
         L_ByViolTypeTab( L_TabIndex ).number_of_violations   := L_NumberOfViolations;

         -- If amount needs to be converted to user preference currency
         -- convert the amounts
         IF ( L_Convert ) THEN
            L_ByViolTypeTab( L_TabIndex ).violation_line_amount := gl_currency_api.CONVERT_AMOUNT_SQL(
                                                              L_BaseCurrencyCode,
                                                              P_UserCurrencyCode,
                                                              sysdate,
                                                              L_ExchangeRateType,
                                                              L_ViolationLineAmount
                                                           );
            L_ByViolTypeTab( L_TabIndex ).violation_amount := gl_currency_api.CONVERT_AMOUNT_SQL(
                                                              L_BaseCurrencyCode,
                                                              P_UserCurrencyCode,
                                                              sysdate,
                                                              L_ExchangeRateType,
                                                              L_ViolationAmount
                                                           );
            L_ByViolTypeTab( L_TabIndex ).allowable_amount := gl_currency_api.CONVERT_AMOUNT_SQL(
                                                              L_BaseCurrencyCode,
                                                              P_UserCurrencyCode,
                                                              sysdate,
                                                              L_ExchangeRateType,
                                                              L_AllowableAmount
                                                           );
         ELSE
            L_ByViolTypeTab( L_TabIndex ).violation_line_amount := round(L_ViolationLineAmount, 2);
            L_ByViolTypeTab( L_TabIndex ).violation_amount      := round(L_ViolationAmount, 2);
            L_ByViolTypeTab( L_TabIndex ).allowable_amount      := round(L_AllowableAmount, 2);
         END IF;

      END LOOP;

      -- Clear previous query results
      DELETE FROM AP_WEB_MANAGEMENT_REPORTS_GT;

      FOR i in 1..L_TabIndex
      LOOP
         -- Insert search results into global temporary table
         INSERT INTO AP_WEB_MANAGEMENT_REPORTS_GT (
            EMPLOYEE_ID,
            VIOLATION_LINE_AMOUNT,
            VIOLATION_AMOUNT,
            ALLOWABLE_AMOUNT,
            PERCENT_VIOLATION,
            PERCENT_ALLOWABLE,
            NUMBER_OF_VIOLATIONS,
            EXPENSE_CATEGORY,
            VIOLATION_TYPE,
            VIOLATION_TYPE_DESC,
            PERIOD_TYPE,
            PERIOD_DATE,
            ROLLUP_TYPE,
            REPORTING_CURRENCY_CODE
         )
         VALUES (
            P_EmployeeId,
            L_ByViolTypeTab( i ).violation_line_amount,
            L_ByViolTypeTab( i ).violation_amount,
            L_ByViolTypeTab( i ).allowable_amount,
            L_ByViolTypeTab( i ).percent_violation,
            L_ByViolTypeTab( i ).percent_allowable,
            L_ByViolTypeTab( i ).number_of_violations,
            P_ExpenseCategory,
            L_ByViolTypeTab( i ).violation_type,
            L_ByViolTypeTab( i ).violation_type_desc,
            P_PeriodType,
            P_Date,
            P_QryType,
            NVL(P_UserCurrencyCode, L_BaseCurrencyCode)
         );

      END LOOP;

      -- Commit all the inserts
      COMMIT;

   EXCEPTION
       WHEN OTHERS THEN
           AP_WEB_DB_UTIL_PKG.RaiseException ('AP_WEB_MANAGEMENT_REPORTING_PKG.ViolationTypeSearch',
                                               SQLERRM);
           APP_EXCEPTION.RAISE_EXCEPTION;
           -- dbms_output.put_line('EXCEPTION: '||SQLERRM)  ;

   END ViolationTypeSearch;

END AP_WEB_MANAGEMENT_REPORTS_PKG;

/
