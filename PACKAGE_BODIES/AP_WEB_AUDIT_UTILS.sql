--------------------------------------------------------
--  DDL for Package Body AP_WEB_AUDIT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_AUDIT_UTILS" AS
/* $Header: apwaudub.pls 120.42.12010000.8 2010/06/09 12:01:53 rveliche ship $ */

  pg_personal_parameter_id number := to_number(null);
  pg_rounding_parameter_id number := to_number(null);

 -- Cache for get_report_status_code
 grsc_old_report_header_id NUMBER := NULL;
 grsc_old_invoice_id NUMBER := NULL;
 grsc_old_status_code ap_lookup_codes.lookup_code%TYPE := NULL;

FUNCTION get_attribute_value(p_report_header_id         IN NUMBER,
                             p_distribution_line_number IN NUMBER,
                             p_column                   IN VARCHAR2) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION get_employee_info
 |
 | DESCRIPTION
 |   This function returns the employee info for a employee.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Employee info for the given user as VARCHAR2.
 |
 | PARAMETERS
 |   p_employee_id IN  Employee identifier
 |   p_column      IN  Column from which the data is retrieved
 |   p_data_type   IN  Data type of the column from which the data is retrieved.
 |                     Supported values: NUMBER, VARCHAR2, DATE
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 25-May-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_employee_info(p_employee_id     IN NUMBER,
                           p_column          IN VARCHAR2,
                           p_data_type       IN VARCHAR2) RETURN VARCHAR2 IS

  l_query_stmt	   VARCHAR2(4000);
  l_result_number  NUMBER;
  l_result_varchar VARCHAR2(4000);
  l_result_date    DATE;
  l_column1         VARCHAR2(4000);
  l_column2         VARCHAR2(4000);

  TYPE CurType IS REF CURSOR;
  cur  CurType;

BEGIN
  IF p_employee_id is null or p_column is null THEN
    return null;
  END IF;

  IF p_data_type not in ('NUMBER', 'VARCHAR2', 'DATE') THEN
    return null;
  END IF;

 /* 2-Oct-2003 J Rautiainen Contingent project changes
  * This function is used to fetch information of a employee, regardless of
  * the status of the employee. Eg. auditor might be viewing a expense report
  * of a terminated or suspended employee, so this method should still return
  * the info on the employee. Also since the contingent worker can enter
  * expense reports, the function needs to query also on those.
  */
  IF INSTR(UPPER(p_column),'EMPLOYEE_NUMBER') > 0 THEN
    l_column1 := 'EMPLOYEE_NUM';
    l_column2 := 'NPW_NUMBER';
  ELSE
    l_column1 := p_column;
    l_column2 := p_column;
  END IF;


      l_query_stmt :=   'select ' || p_column || ' ' ||
                          'from ' ||
                          '(SELECT ' || l_column1 || ' ' || p_column || ' ' ||
                           'FROM  PER_EMPLOYEES_X EMP ' ||
                           'WHERE NOT AP_WEB_DB_HR_INT_PKG.ISPERSONCWK(EMP.EMPLOYEE_ID)=''Y'' ' ||
                                 'AND EMP.EMPLOYEE_ID = :b1 ' ||
                           'UNION ALL ' ||
                           'SELECT ' || l_column2 || ' ' || p_column || ' ' ||
                           'FROM  PER_CONT_WORKERS_CURRENT_X CWK ' ||
                           'WHERE CWK.PERSON_ID = :b2) wf';

  OPEN cur FOR l_query_stmt USING p_employee_id, p_employee_id;

  IF p_data_type = 'VARCHAR2' THEN
    FETCH cur INTO l_result_varchar;
  ELSIF p_data_type = 'NUMBER' THEN
    FETCH cur INTO l_result_number;
    l_result_varchar := to_char(l_result_number);
  ELSIF p_data_type = 'DATE' THEN
    FETCH cur INTO l_result_date;
    l_result_varchar := to_char(l_result_date,'DD-MON-RRRR');
  ELSE
    CLOSE cur;
    return null;
  END IF;

  CLOSE cur;

  return l_result_varchar;

END get_employee_info;

/*========================================================================
 | PUBLIC FUNCTION get_task_info
 |
 | DESCRIPTION
 |   This function returns the task info for a given task.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Task info for the given user as VARCHAR2.
 |
 | PARAMETERS
 |   p_task_id     IN  Task identifier
 |   p_column      IN  Column from which the data is retrieved
 |   p_data_type   IN  Data type of the column from which the data is retrieved.
 |                     Supported values: NUMBER, VARCHAR2, DATE
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-Aug-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_task_info(p_task_id     IN NUMBER,
                       p_column      IN VARCHAR2,
                       p_data_type   IN VARCHAR2) RETURN VARCHAR2 IS

BEGIN

  return get_object_info(to_char(p_task_id),
                         p_column,
                         p_data_type,
                        'PA_TASKS',
                        'task_id');

END get_task_info;

/*========================================================================
 | PUBLIC FUNCTION get_project_info
 |
 | DESCRIPTION
 |   This function returns the project info for a given project.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Project info for the given user as VARCHAR2.
 |
 | PARAMETERS
 |   p_project_id  IN  Project identifier
 |   p_column      IN  Column from which the data is retrieved
 |   p_data_type   IN  Data type of the column from which the data is retrieved.
 |                     Supported values: NUMBER, VARCHAR2, DATE
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-Aug-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_project_info(p_project_id     IN NUMBER,
                          p_column          IN VARCHAR2,
                          p_data_type       IN VARCHAR2) RETURN VARCHAR2 IS

BEGIN

  return get_object_info(to_char(p_project_id),
                         p_column,
                         p_data_type,
                        'pa_projects_all',
                        'project_id');

END get_project_info;

/*========================================================================
 | PUBLIC FUNCTION get_award_info
 |
 | DESCRIPTION
 |   This function returns the award info for a given award.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Project info for the given user as VARCHAR2.
 |
 | PARAMETERS
 |   p_award_id  IN  Award identifier
 |   p_column      IN  Column from which the data is retrieved
 |   p_data_type   IN  Data type of the column from which the data is retrieved.
 |                     Supported values: NUMBER, VARCHAR2, DATE
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-Aug-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_award_info(p_award_id        IN NUMBER,
                        p_column          IN VARCHAR2,
                        p_data_type       IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN

  return get_object_info(to_char(p_award_id),
                         p_column,
                         p_data_type,
                        'GMS_AWARDS_ALL',
                        'award_id');

END get_award_info;

/*========================================================================
 | PUBLIC FUNCTION get_awt_group_info
 |
 | DESCRIPTION
 |   This function returns the awt group info for a given awt group.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Awt Group info as VARCHAR2.
 |
 | PARAMETERS
 |   p_awt_group_id IN  Awt group identifier
 |   p_column       IN  Column from which the data is retrieved
 |   p_data_type    IN  Data type of the column from which the data is retrieved.
 |                      Supported values: NUMBER, VARCHAR2, DATE
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-Aug-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_awt_group_info(p_awt_group_id    IN NUMBER,
                            p_column          IN VARCHAR2,
                            p_data_type       IN VARCHAR2) RETURN VARCHAR2 IS

BEGIN

  return get_object_info(to_char(p_awt_group_id),
                         p_column,
                         p_data_type,
                        'ap_awt_groups',
                        'group_id');

END get_awt_group_info;

/*========================================================================
 | PUBLIC FUNCTION get_tax_code_info
 |
 | DESCRIPTION
 |   This function returns the tax code info for a given tax code based.
 |   on either tax code id or tax code name.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Tax code info as VARCHAR2.
 |
 | PARAMETERS
 |   p_tax_id       IN  Tax code identifier
 |   p_name         IN  Tax code name
 |   p_column       IN  Column from which the data is retrieved
 |   p_data_type    IN  Data type of the column from which the data is retrieved.
 |                      Supported values: NUMBER, VARCHAR2, DATE
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-Aug-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_tax_code_info(p_tax_id    IN NUMBER,
                           p_name      IN VARCHAR2,
                           p_column    IN VARCHAR2,
                           p_data_type IN VARCHAR2) RETURN VARCHAR2 IS

BEGIN
  IF p_tax_id is not null THEN
    return get_object_info(to_char(p_tax_id),
                           p_column,
                           p_data_type,
                          'ap_tax_codes_all',
                          'tax_id');

  ELSIF p_name is not null THEN

    return get_object_info(p_name,
                           p_column,
                           p_data_type,
                          'ap_tax_codes_all',
                          'name');
  ELSE
    return null;
  END IF;

END get_tax_code_info;

/*========================================================================
 | PUBLIC FUNCTION get_line_status
 |
 | DESCRIPTION
 |   This function returns the expense report line status for auditor. Line
 |   status consists either of "OK" or of the list of policy violations if
 |   violations exist.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Expense line status as VARCHAR2.
 |
 | PARAMETERS
 |   p_report_header_id         IN  Expense report header identifier
 |   p_distribution_line_number IN  Expense report line identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-Aug-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_line_status(p_report_header_id         IN NUMBER,
                         p_distribution_line_number IN NUMBER) RETURN VARCHAR2 IS
  CURSOR violation_cur IS
    select violation_type,
           AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_POL_VIOLATION_TYPES',violation_type) violation
    from AP_POL_VIOLATIONS_ALL
    where report_header_id = p_report_header_id
    and   distribution_line_number = p_distribution_line_number
    AND   violation_type <> 'DUPLICATE_DETECTION'
    order by violation_number;

  CURSOR dup_violation_cur IS
    SELECT violation_type, 'Duplicate Detection' violation,
           dup_report_header_id, To_Char(dup_report_line_id) dup_report_line_id, dup_dist_line_number
    FROM ap_pol_violations_all
    WHERE report_header_id = p_report_header_id
    AND   distribution_line_number = p_distribution_line_number
    AND   violation_type = 'DUPLICATE_DETECTION'
    ORDER BY violation_number;

  violation_rec violation_cur%ROWTYPE;
  dup_violation_rec dup_violation_cur%ROWTYPE;
  l_counter NUMBER := 0;
  l_dup_counter NUMBER := 0;
  l_result  VARCHAR2(4000);
  l_dup_result VARCHAR2(4000) := NULL;

BEGIN
  IF p_report_header_id is null or p_distribution_line_number is null THEN
    return null;
  END IF;

  FOR violation_rec IN violation_cur LOOP
    l_counter := l_counter + 1;
    IF l_counter = 1 THEN
      l_result := violation_rec.violation;
    ELSE
      l_result := l_result || ', '||violation_rec.violation;
    END IF;
  END LOOP;

  FOR dup_violation_rec IN dup_violation_cur LOOP
    l_dup_counter := l_dup_counter + 1;
    IF l_dup_counter = 1 THEN
      l_dup_result := dup_violation_rec.violation || ' (' || dup_violation_rec.dup_report_header_id || ' - Line ' || dup_violation_rec.dup_dist_line_number;
    ELSE
      l_dup_result := l_dup_result || ', ' || dup_violation_rec.dup_report_header_id || ' - Line ' || dup_violation_rec.dup_dist_line_number;
    END IF;
  END LOOP;

  IF l_dup_result IS NOT NULL THEN
    l_dup_result := l_dup_result || ')';
    IF l_counter > 0 THEN
      l_result := l_result || ', ' || l_dup_result;
    ELSE
      l_result := l_dup_result;
    END IF;
  END IF;

  l_counter := l_counter + l_dup_counter;

  IF l_counter > 0 THEN
    return l_result;
  ELSE
    return fnd_message.GET_STRING('SQLAP','OIE_AUD_NO_VIOLATIONS');
  END IF;

END get_line_status;

/*========================================================================
 | PUBLIC FUNCTION get_expense_type
 |
 | DESCRIPTION
 |   This function returns the expense line type.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Expense line type as VARCHAR2.
 |
 | PARAMETERS
 |   p_parameter_id  IN  Expense type identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-Aug-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_expense_type(p_parameter_id IN NUMBER) RETURN VARCHAR2 IS

 CURSOR expense_type_cur IS
   SELECT nvl(WEB_FRIENDLY_PROMPT, PROMPT) expense_type_prompt
   FROM AP_EXPENSE_REPORT_PARAMS_ALL
   WHERE PARAMETER_ID = p_parameter_id;

  expense_type_rec expense_type_cur%ROWTYPE;
BEGIN
  IF p_parameter_id is null THEN
    return null;
  END IF;

  OPEN expense_type_cur;
  FETCH expense_type_cur INTO expense_type_rec;

  IF expense_type_cur%NOTFOUND THEN
    CLOSE expense_type_cur;
    return null;
  END IF;

  CLOSE expense_type_cur;
  return expense_type_rec.expense_type_prompt;

END get_expense_type;

/*========================================================================
 | PUBLIC FUNCTION get_allowable_amount
 |
 | DESCRIPTION
 |   This function returns the allowable amount on an line with policy violation.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Expense line allowable amount as NUMBER.
 |
 | PARAMETERS
 |   p_report_header_id         IN  Expense report header identifier
 |   p_distribution_line_number IN  Expense report line identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-Aug-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_allowable_amount(p_report_header_id         IN NUMBER,
                              p_distribution_line_number IN NUMBER) RETURN NUMBER IS
  CURSOR amount_cur IS
    select min(allowable_amount) allowable_amount
    from ap_pol_violations_all
    where report_header_id = p_report_header_id
    and   distribution_line_number = p_distribution_line_number
    and   violation_type in ('DAILY_LIMIT','INDIVIDUAL_LIMIT');

  amount_rec amount_cur%ROWTYPE;
BEGIN
  IF p_report_header_id is null or p_distribution_line_number is null THEN
    return null;
  END IF;

  OPEN amount_cur;
  FETCH amount_cur INTO amount_rec;

  IF amount_cur%NOTFOUND THEN
    CLOSE amount_cur;
    return null;
  END IF;

  CLOSE amount_cur;
  return amount_rec.allowable_amount;

END get_allowable_amount;

/*========================================================================
 | PUBLIC FUNCTION get_allowable_cc_amount
 |
 | DESCRIPTION
 |   This function returns the allowable credit card amount on a line with credit card violation.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Expense line credit card allowable amount as NUMBER.
 |
 | PARAMETERS
 |   p_report_header_id         IN  Expense report header identifier
 |   p_distribution_line_number IN  Expense report line identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Jul-2004           R Langi           Copied
 |
 *=======================================================================*/
FUNCTION get_allowable_cc_amount(p_report_header_id         IN NUMBER,
                                 p_distribution_line_number IN NUMBER) RETURN NUMBER IS
  CURSOR amount_cur IS
    select min(allowable_amount) allowable_cc_amount
    from ap_pol_violations_all
    where report_header_id = p_report_header_id
    and   distribution_line_number = p_distribution_line_number
    and   violation_type in ('CC_REQUIRED');

  amount_rec amount_cur%ROWTYPE;
BEGIN
  IF p_report_header_id is null or p_distribution_line_number is null THEN
    return null;
  END IF;

  OPEN amount_cur;
  FETCH amount_cur INTO amount_rec;

  IF amount_cur%NOTFOUND THEN
    CLOSE amount_cur;
    return null;
  END IF;

  CLOSE amount_cur;
  return amount_rec.allowable_cc_amount;

END get_allowable_cc_amount;

/*========================================================================
 | PUBLIC FUNCTION get_allowable_daily_sum
 |
 | DESCRIPTION
 |   This function returns the allowable daily sum on an line with policy violation.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Expense line allowable daily sum as NUMBER.
 |
 | PARAMETERS
 |   p_report_header_id         IN  Expense report header identifier
 |   p_distribution_line_number IN  Expense report line identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 04-Apr-2003           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_allowable_daily_sum(p_report_header_id         IN NUMBER,
                                 p_distribution_line_number IN NUMBER) RETURN NUMBER IS
  CURSOR amount_cur IS
    select min(allowable_amount) allowable_amount
    from ap_pol_violations_all
    where report_header_id = p_report_header_id
    and   distribution_line_number = p_distribution_line_number
    and   violation_type in ('DAILY_SUM_LIMIT');

  amount_rec amount_cur%ROWTYPE;
BEGIN
  IF p_report_header_id is null or p_distribution_line_number is null THEN
    return null;
  END IF;

  OPEN amount_cur;
  FETCH amount_cur INTO amount_rec;

  IF amount_cur%NOTFOUND THEN
    CLOSE amount_cur;
    return null;
  END IF;

  CLOSE amount_cur;
  return amount_rec.allowable_amount;

END get_allowable_daily_sum;

/*========================================================================
 | PUBLIC FUNCTION get_allowable_rate
 |
 | DESCRIPTION
 |   This function returns the allowable rate on an line with policy violation.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Expense line allowable amount as NUMBER.
 |
 | PARAMETERS
 |   p_report_header_id         IN  Expense report header identifier
 |   p_distribution_line_number IN  Expense report line identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-Aug-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_allowable_rate(p_report_header_id         IN NUMBER,
                            p_distribution_line_number IN NUMBER) RETURN NUMBER IS
  CURSOR allowance_cur IS
    select aerh.payment_currency_code reimbursement_currency_code,
           aerl.start_expense_date,
           aerl.receipt_currency_code,
           eo.exchange_rate_id,
           eo.exchange_rate_type,
           eo.exchange_rate_allowance,
           eo.overall_tolerance,
           eo.org_id
    from AP_POL_EXRATE_OPTIONS_ALL eo,
         AP_EXPENSE_REPORT_LINES_ALL aerl,
         AP_EXPENSE_REPORT_HEADERS_ALL aerh,
         AP_POL_VIOLATIONS_ALL pv
    where aerl.report_header_id = pv.report_header_id
    and aerl.distribution_line_number = pv.distribution_line_number
    and aerl.credit_card_trx_id is null
    and aerh.report_header_id = aerl.report_header_id
    and aerh.org_id = aerl.org_id
    and eo.org_id = aerl.org_id
    and eo.enabled = 'Y'
    and pv.report_header_id = p_report_header_id
    and pv.distribution_line_number = p_distribution_line_number
    and pv.violation_type in ('EXCHANGE_RATE_LIMIT');

  allowance_rec      allowance_cur%ROWTYPE;
  x_converted_amount NUMBER;
  x_denominator      NUMBER;
  x_numerator        NUMBER;
  x_rate             NUMBER;
  ln_max_rate        NUMBER := to_number(null);
  lv_inverse_rate    VARCHAR2(100) := 'N';
BEGIN
  IF p_report_header_id is null or p_distribution_line_number is null THEN
    return to_number(null);
  END IF;

  OPEN allowance_cur;
  FETCH allowance_cur INTO allowance_rec;

  IF allowance_cur%NOTFOUND THEN
    CLOSE allowance_cur;
    return to_number(null);
  END IF;

  CLOSE allowance_cur;

  GL_CURRENCY_API.convert_closest_amount(allowance_rec.receipt_currency_code,       -- x_from_currency
                                         allowance_rec.reimbursement_currency_code, -- x_to_currency
                                         allowance_rec.start_expense_date,          -- x_conversion_date,
                                         allowance_rec.exchange_rate_type,          -- x_conversion_type,
                                         0,   -- x_user_rate
                                         100, -- x_amount
                                         0,   -- x_max_roll_days
                                         x_converted_amount,
                                         x_denominator,
                                         x_numerator,
                                         x_rate);
  IF x_rate is NULL THEN
    return to_number(null);
  END IF;

  /* Bug 3966257. Removed tolerance calculations. */

  ln_max_rate := x_rate * (1 + NVL(allowance_rec.exchange_rate_allowance,0)/100);
  lv_inverse_rate := fnd_profile.VALUE('DISPLAY_INVERSE_RATE');

  IF ln_max_rate is null OR ln_max_rate = 0 THEN
    return to_number(null);
  ELSIF lv_inverse_rate = 'Y' THEN
    return ROUND(1/ln_max_rate,6);
  ELSE
    return ROUND(ln_max_rate,6);
  END IF;

  -- Bug# 8988226 - Exception should be handled and a null value should be returned
  -- when the package GL_CURRENCY_API throws an user-defined exception
  EXCEPTION
  WHEN OTHERS THEN
    return to_number(null);

END get_allowable_rate;

FUNCTION get_object_info(p_key             IN VARCHAR2,
                         p_column          IN VARCHAR2,
                         p_result_type     IN VARCHAR2,
                         p_table           IN VARCHAR2,
                         p_key_column      IN VARCHAR2,
                         p_order_by_clause IN VARCHAR2) RETURN VARCHAR2 IS

  l_query_stmt	   VARCHAR2(4000);
  l_result_number  NUMBER;
  l_result_varchar VARCHAR2(4000);
  l_result_date    DATE;

  TYPE CurType IS REF CURSOR;
  cur  CurType;

BEGIN
  IF p_key is null or p_column is null THEN
    return null;
  END IF;

  IF p_result_type not in ('NUMBER', 'VARCHAR2', 'DATE') THEN
    return null;
  END IF;

  l_query_stmt := 'select '||p_column||' result from '||p_table||' where '||p_key_column||' = :b1 '||p_order_by_clause;

  OPEN cur FOR l_query_stmt USING p_key;

  IF p_result_type = 'VARCHAR2' THEN
    FETCH cur INTO l_result_varchar;
  ELSIF p_result_type = 'NUMBER' THEN
    FETCH cur INTO l_result_number;
    l_result_varchar := to_char(l_result_number);
  ELSIF p_result_type = 'DATE' THEN
    FETCH cur INTO l_result_date;
    l_result_varchar := to_char(l_result_date,'DD-MON-RRRR');
  ELSE
    CLOSE cur;
    return null;
  END IF;

  CLOSE cur;

  return l_result_varchar;

END get_object_info;

/*========================================================================
 | PUBLIC FUNCTION get_concat_desc_flex
 |
 | DESCRIPTION
 |   This function returns the descriptive flexfield definition related to a row.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   CCID.
 |
 | PARAMETERS
 |   p_report_header_id         IN  Expense report header identifier
 |   p_distribution_line_number IN  Expense report line identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-Aug-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_concat_desc_flex(p_report_header_id         IN NUMBER,
                              p_distribution_line_number IN NUMBER) RETURN VARCHAR2 IS
  CURSOR template_cur IS
   select prompt web_prompt
   from ap_expense_report_lines_all aerl,
        ap_expense_report_params_all aerp
   where aerl.report_header_id = p_report_header_id
   and aerl.distribution_line_number = p_distribution_line_number
   and aerp.parameter_id = aerl.web_parameter_id;

  v_result        VARCHAR2(4000);
  v_value         VARCHAR2(4000);
  template_rec    template_cur%ROWTYPE;
  flexfield       fnd_dflex.dflex_r;
  flexinfo        fnd_dflex.dflex_dr;
  contexts        fnd_dflex.contexts_dr;
  i               BINARY_INTEGER;
  segments        fnd_dflex.segments_dr;
  first_component boolean := TRUE;

BEGIN
  IF p_report_header_id is null OR p_distribution_line_number is null THEN
    return null;
  END IF;

  fnd_dflex.get_flexfield('SQLAP', 'AP_EXPENSE_REPORT_LINES', flexfield, flexinfo);
  fnd_dflex.get_contexts(flexfield, contexts);

  fnd_dflex.get_segments(fnd_dflex.make_context(flexfield, contexts.context_code(contexts.global_context)),segments,TRUE);

  FOR i IN 1 .. segments.nsegments LOOP

    v_value := AP_WEB_AUDIT_UTILS.get_attribute_value(p_report_header_id, p_distribution_line_number, segments.application_column_name(i));

    IF v_value is not null THEN

      IF not first_component THEN
        v_result := v_result||', ';
      ELSE
        first_component := FALSE;
      END IF;

      v_result := v_result || segments.segment_name(i) || ': ' ||v_value;
    END IF;

    v_value := NULL;

  END LOOP;

  OPEN template_cur;
  FETCH template_cur INTO template_rec;
  IF template_cur%NOTFOUND OR template_rec.web_prompt is null THEN
    CLOSE template_cur;
    RETURN v_result;
  END IF;
  CLOSE template_cur;

  /* Doing substrb since OIE uses expense type name as the context value. However the context value code
   * definition only accepts 30 characters, but the expense type name can be 80. This was discussed with
   * OIE team and their suggested resolution was to substr the value.  */
  fnd_dflex.get_segments(fnd_dflex.make_context(flexfield, SUBSTRB(template_rec.web_prompt,0,30)),segments,TRUE);


  FOR i IN 1 .. segments.nsegments LOOP

    v_value := AP_WEB_AUDIT_UTILS.get_attribute_value(p_report_header_id, p_distribution_line_number, segments.application_column_name(i));

    IF v_value is not null THEN

      IF not first_component THEN
        v_result := v_result||', ';
      ELSE
        first_component := FALSE;
      END IF;

      v_result := v_result || segments.segment_name(i) || ': ' ||v_value;
    END IF;

    v_value := NULL;

  END LOOP;

  RETURN v_result;

END get_concat_desc_flex;

FUNCTION get_attribute_value(p_report_header_id         IN NUMBER,
                             p_distribution_line_number IN NUMBER,
                             p_column                   IN VARCHAR2) RETURN VARCHAR2 IS

  l_query_stmt	   VARCHAR2(4000);
  l_result_varchar VARCHAR2(4000);

  TYPE CurType IS REF CURSOR;
  cur  CurType;

BEGIN
  IF p_report_header_id is null OR p_distribution_line_number is null OR p_column is null THEN
    return null;
  END IF;

  l_query_stmt := 'select '||p_column||' result from ap_expense_report_lines_all where report_header_id = :b1 and distribution_line_number = :b2';

  OPEN cur FOR l_query_stmt USING p_report_header_id, p_distribution_line_number;
  FETCH cur INTO l_result_varchar;
  CLOSE cur;

  return l_result_varchar;

END get_attribute_value;

/*========================================================================
 | PUBLIC FUNCTION get_flex_structure_code
 |
 | DESCRIPTION
 |   This function returns the flex structure code for a given org.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Flex structure code.
 |
 | PARAMETERS
 |   p_org_id              IN  Organization identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 26-Aug-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_flex_structure_code(p_org_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR structure_cur IS
    select fs.id_flex_structure_code
    from ap_system_parameters_all so, gl_sets_of_books sb, FND_ID_FLEX_STRUCTURES fs
    where so.org_id = p_org_id
    and sb.set_of_books_id = so.set_of_books_id
    and application_id = 101
    and id_flex_code = 'GL#'
    and id_flex_num = sb.chart_of_accounts_id;

  structure_rec structure_cur%ROWTYPE;

BEGIN
  IF p_org_id is null THEN
    return null;
  END IF;

  OPEN structure_cur;
  FETCH structure_cur INTO structure_rec;

  IF structure_cur%NOTFOUND THEN
    CLOSE structure_cur;
    return null;
  END IF;

  CLOSE structure_cur;
  return structure_rec.id_flex_structure_code;

END get_flex_structure_code;

/*========================================================================
 | PUBLIC PROCEDURE set_show_audit_header_flag
 |
 | DESCRIPTION
 |   This procedure auto sets the preference controlling whether the header
 |   information is shown or not on the audit page.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_show_header         IN  Whether the header should be shown
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 30-Aug-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE set_show_audit_header_flag(p_show_header IN VARCHAR2) IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  CURSOR emp_cur IS
    select employee_id
    from fnd_user
    where user_id = FND_GLOBAL.USER_ID;

  CURSOR pref_cur(p_employee_id IN ap_web_preferences.employee_id%TYPE) IS
    select employee_id, show_audit_header_flag
    from ap_web_preferences
    where employee_id = p_employee_id
    FOR UPDATE OF show_audit_header_flag NOWAIT;

  pref_rec pref_cur%ROWTYPE;
  emp_rec emp_cur%ROWTYPE;

BEGIN

  OPEN emp_cur;
  FETCH emp_cur INTO emp_rec;
  CLOSE emp_cur;

  IF (emp_rec.employee_id is not null) THEN

    OPEN pref_cur(emp_rec.employee_id);
    FETCH pref_cur INTO pref_rec;

    IF pref_cur%NOTFOUND THEN
      INSERT INTO ap_web_preferences(
        employee_id,
        show_audit_header_flag,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login
      ) VALUES (
        emp_rec.employee_id,
        NVL(p_show_header,'Y'),
        sysdate,                     /* last_update_date */
        nvl(fnd_global.user_id, -1), /* last_updated_by*/
        sysdate,                     /* creation_date */
        nvl(fnd_global.user_id, -1), /* created_by */
        fnd_global.conc_login_id     /* last_update_login */
      );
      CLOSE pref_cur;
    ELSE
      UPDATE ap_web_preferences
      SET    show_audit_header_flag = NVL(p_show_header,'Y')
      WHERE CURRENT OF pref_cur;
      CLOSE pref_cur;
    END IF;

    COMMIT;

  END IF;

END set_show_audit_header_flag;

/*========================================================================
 | PUBLIC FUNCTION get_show_audit_header_flag
 |
 | DESCRIPTION
 |   This function gets the preference controlling whether the header
 |   information is shown or not on the audit page.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Y / N depending whether the header should be shown
 |
 | PARAMETERS
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 30-Aug-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_show_audit_header_flag RETURN VARCHAR2 IS

  CURSOR pref_cur IS
    select pref.employee_id, NVL(pref.show_audit_header_flag, 'Y') show_header_flag
    from ap_web_preferences pref, fnd_user usr
    where usr.user_id = FND_GLOBAL.USER_ID
    and pref.employee_id = usr.employee_id;

  pref_rec pref_cur%ROWTYPE;

BEGIN

  OPEN pref_cur;
  FETCH pref_cur INTO pref_rec;
  IF pref_cur%NOTFOUND THEN
    CLOSE pref_cur;
    RETURN 'Y';
  END IF;

  CLOSE pref_cur;
  RETURN pref_rec.show_header_flag;

END get_show_audit_header_flag;

/*========================================================================
 | PUBLIC FUNCTION get_rule_set_assignment_exists
 |
 | DESCRIPTION
 |   This function checks whether assignments exist for a given audit rule set.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Y / N depending whether assignment exists for the rule set
 |
 | PARAMETERS
 |   p_rule_set_id IN  Rule Set Id
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 30-Aug-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_rule_set_assignment_exists(p_rule_set_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR assignment_cur IS
    select count(rule_assignment_id) assignment_count
    from ap_aud_rule_assignments_all
    where rule_set_id = p_rule_set_id;

  assignment_rec assignment_cur%ROWTYPE;

BEGIN

  IF p_rule_set_id is null THEN
    return 'N';
  END IF;

  OPEN assignment_cur;
  FETCH assignment_cur INTO assignment_rec;
  CLOSE assignment_cur;

  IF (assignment_rec.assignment_count > 0) THEN
    return 'Y';
  ELSE
    return 'N';
  END IF;

END get_rule_set_assignment_exists;

/*========================================================================
 | PUBLIC FUNCTION get_workload_info
 |
 | DESCRIPTION
 |   This function returns the user workload info.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   User queue info
 |
 | PARAMETERS
 |   p_user_id     IN  User Id
 |   p_column      IN  Column from which the data is retrieved
 |   p_data_type   IN  Data type of the column from which the data is retrieved.
 |                     Supported values: NUMBER, VARCHAR2, DATE
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-Sep-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_workload_info(p_user_id    IN NUMBER,
                           p_column     IN VARCHAR2,
                           p_data_type  IN VARCHAR2) RETURN VARCHAR2 IS

  l_query_stmt	   VARCHAR2(4000);
  l_result_number  NUMBER;
  l_result_varchar VARCHAR2(4000);
  l_result_date    DATE;

  TYPE CurType IS REF CURSOR;
  cur  CurType;

BEGIN
  IF p_user_id is null or p_column is null THEN
    return null;
  END IF;

  IF p_data_type not in ('NUMBER', 'VARCHAR2', 'DATE') THEN
    return null;
  END IF;

  l_query_stmt := 'select '||p_column||' result from AP_AUD_WORKLOADS where auditor_id = :b1 and sysdate between start_date and NVL(end_date,sysdate+1)';

  OPEN cur FOR l_query_stmt USING to_char(p_user_id);

  IF p_data_type = 'VARCHAR2' THEN
    FETCH cur INTO l_result_varchar;
  ELSIF p_data_type = 'NUMBER' THEN
    FETCH cur INTO l_result_number;
    l_result_varchar := to_char(l_result_number);
  ELSIF p_data_type = 'DATE' THEN
    FETCH cur INTO l_result_date;
    l_result_varchar := to_char(l_result_date,'DD-MON-RRRR');
  ELSE
    CLOSE cur;
    return null;
  END IF;

  CLOSE cur;

  return l_result_varchar;
END get_workload_info;

/*========================================================================
 | PUBLIC FUNCTION get_user_queue_info
 |
 | DESCRIPTION
 |   This function returns the user queue info.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   User queue info
 |
 | PARAMETERS
 |   p_user_id IN  User Id
 |   p_column      IN  Column from which the data is retrieved
 |   p_data_type   IN  Data type of the column from which the data is retrieved.
 |                     Supported values: NUMBER, VARCHAR2, DATE
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-Sep-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_user_queue_info(p_user_id    IN NUMBER,
                             p_column     IN VARCHAR2,
                             p_data_type  IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  return get_object_info(to_char(p_user_id),
                         p_column,
                         p_data_type,
                        'AP_AUD_QUEUE_SUMMARIES_V',
                        'auditor_id');
END get_user_queue_info;

/*========================================================================
 | PUBLIC FUNCTION get_audit_reason
 |
 | DESCRIPTION
 |   This function returns the reason(s) why expense report line status
 |   is audited .
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Expense report audit reason as VARCHAR2.
 |
 | PARAMETERS
 |   p_report_header_id         IN  Expense report header identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-Aug-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_audit_reason(p_report_header_id  IN NUMBER) RETURN VARCHAR2 IS

  CURSOR audit_cur IS
    select audit_reason_code,
           AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_AUDIT_REASONS',audit_reason_code) audit_reason
    from AP_AUD_AUDIT_REASONS
    where report_header_id = p_report_header_id
    order by audit_reason_id;

  audit_rec audit_cur%ROWTYPE;
  l_counter NUMBER := 0;
  l_result  VARCHAR2(4000);

BEGIN
  IF p_report_header_id is null  THEN
    return null;
  END IF;

  FOR audit_rec IN audit_cur LOOP
    l_counter := l_counter + 1;
    IF l_counter = 1 THEN
      l_result := audit_rec.audit_reason;
    ELSE
      l_result := l_result || ', '||audit_rec.audit_reason;
    END IF;
  END LOOP;

  return l_result;

END get_audit_reason;

/*========================================================================
 | PUBLIC FUNCTION get_person_org_id
 |
 | DESCRIPTION
 |   This function returns the organization id associated to a person.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Organization Id as NUMBER.
 |
 | PARAMETERS
 |   p_person_id         IN  Person identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-Aug-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_person_org_id(p_person_id IN NUMBER) RETURN NUMBER IS

 /* 2-Oct-2003 J Rautiainen Contingent project changes
  * This function is used to fetch organization of a employee, regardless of
  * the status of the employee. Eg. auditor might be viewing a expense report
  * of a terminated or suspended employee, so this method should still return
  * the info on the employee. Also since the contingent worker can enter
  * expense reports, the function needs to query also on those.
  */
  CURSOR person_cur IS
    SELECT WF.ORGANIZATION_ID
    FROM
        (SELECT EMP.ORGANIZATION_ID  ORGANIZATION_ID,
                EMP.EMPLOYEE_ID PERSON_ID
         FROM  PER_EMPLOYEES_X EMP
         WHERE NOT AP_WEB_DB_HR_INT_PKG.ISPERSONCWK(EMP.EMPLOYEE_ID)='Y'
	       AND EMP.EMPLOYEE_ID = p_person_id
         UNION ALL
         SELECT CWK.ORGANIZATION_ID  ORGANIZATION_ID,
                CWK.PERSON_ID
         FROM  PER_CONT_WORKERS_CURRENT_X CWK
	 WHERE CWK.PERSON_ID = p_person_id) WF;

  person_rec person_cur%ROWTYPE;

BEGIN

  IF p_person_id is null THEN
    return null;
  END IF;

  OPEN person_cur;
  FETCH person_cur INTO person_rec;

  IF person_cur%NOTFOUND THEN
    CLOSE person_cur;
    return null;
  END IF;

  CLOSE person_cur;
  return person_rec.organization_id;

END get_person_org_id;

/*========================================================================
 | PUBLIC PROCEDURE set_audit_list_member
 |
 | DESCRIPTION
 |   This procedure auto sets the given user to the audit list.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_report_header_id         IN  Expense report Identifier
 |   p_reason_code              IN  Reason person is being added to the list
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 18-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE set_audit_list_member(p_report_header_id IN NUMBER, p_reason_code  IN VARCHAR2) IS

  CURSOR report_cur IS
    select aerh.employee_id, aerh.org_id
    from AP_EXPENSE_REPORT_HEADERS_ALL aerh
    where aerh.report_header_id = p_report_header_id;

  CURSOR required_cur IS
    select count(1) required_count
    from AP_EXPENSE_REPORT_LINES_ALL aerl
    where aerl.report_header_id = p_report_header_id
    and nvl(aerl.receipt_required_flag, 'N') = 'Y';

  CURSOR rule_cur (p_org_id IN NUMBER) IS
    select rs.audit_term_duration_days
    from AP_AUD_RULE_SETS rs,
         AP_AUD_RULE_ASSIGNMENTS_ALL rsa
    where rsa.org_id = p_org_id
    and   rsa.rule_set_id = rs.rule_set_id
    and   rs.rule_set_type = 'AUDIT_LIST'
    and   TRUNC(SYSDATE)
            BETWEEN TRUNC(NVL(rsa.START_DATE,SYSDATE))
            AND     TRUNC(NVL(rsa.END_DATE,SYSDATE));

  rule_rec rule_cur%ROWTYPE;
  report_rec report_cur%ROWTYPE;
  required_rec required_cur%ROWTYPE;
  create_record boolean := true;
BEGIN
  IF p_report_header_id is not null THEN
    OPEN report_cur;
    FETCH report_cur INTO report_rec;
    CLOSE report_cur;

    OPEN rule_cur(report_rec.org_id);
    FETCH rule_cur INTO rule_rec;
    CLOSE rule_cur;

    IF (p_reason_code = 'RECEIPTS_LATE') THEN
      OPEN required_cur;
      FETCH required_cur INTO required_rec;
      CLOSE required_cur;
      IF (required_rec.required_count = 0) THEN
        create_record := false;
      END IF;
    END IF;
    IF (create_record) THEN
      AP_WEB_AUDIT_PROCESS.add_to_audit_list(report_rec.employee_id, rule_rec.audit_term_duration_days, NVL(p_reason_code,'AUDITOR_ADDED'));
    END IF;

  END IF;
END set_audit_list_member;

/*========================================================================
 | PUBLIC FUNCTION get_audit_list_member
 |
 | DESCRIPTION
 |   This procedure returns whether user is on audit list.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Y / N depending whether user is on audit list
 |
 | PARAMETERS
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 18-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_audit_list_member(p_employee_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR audit_cur IS
    SELECT auto_audit_id
    FROM ap_aud_auto_audits
    WHERE employee_id = p_employee_id
    AND   trunc(sysdate) between trunc(start_date) and trunc(NVL(end_date, sysdate));

  audit_rec audit_cur%ROWTYPE;
BEGIN
  IF p_employee_id is null THEN
    return 'N';
  END IF;

  OPEN audit_cur;
  FETCH audit_cur INTO audit_rec;

  IF audit_cur%NOTFOUND THEN
    CLOSE audit_cur;
    return 'N';
  END IF;

  CLOSE audit_cur;
  return 'Y';

END get_audit_list_member;

/*========================================================================
 | PUBLIC FUNCTION get_auditor_name
 |
 | DESCRIPTION
 |   This function returns the auditor name for a auditor.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Auditor name for the given auditor as VARCHAR2.
 |
 | PARAMETERS
 |   p_auditor_id IN  Auditor identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 19-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_auditor_name(p_auditor_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR auditor_cur IS
    select DECODE(usr.user_id,
                  -1, fnd_message.GET_STRING('SQLAP','OIE_AUD_FALLBACK_AUDITOR'),
                  NVL(AP_WEB_AUDIT_UTILS.get_employee_info(usr.employee_id,'full_name','VARCHAR2'),
                      usr.user_name)) auditor_name
    from fnd_user usr
    where usr.user_id = p_auditor_id;

  auditor_rec auditor_cur%ROWTYPE;
BEGIN

 IF p_auditor_id is null THEN
    return null;
  END IF;

  OPEN auditor_cur;
  FETCH auditor_cur INTO auditor_rec;

  IF auditor_cur%NOTFOUND THEN
    CLOSE auditor_cur;
    return null;
  END IF;

  CLOSE auditor_cur;
  return auditor_rec.auditor_name;

END get_auditor_name;

/*========================================================================
 | PUBLIC FUNCTION get_audit_rule_info
 |
 | DESCRIPTION
 |   This function returns the audit rule info.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Audit rule info
 |
 | PARAMETERS
 |   p_org_id      IN  Organization Id
 |   p_column      IN  Column from which the data is retrieved
 |   p_data_type   IN  Data type of the column from which the data is retrieved.
 |                     Supported values: NUMBER, VARCHAR2, DATE
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 02-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_audit_rule_info(p_org_id     IN NUMBER,
                             p_rule_type  IN VARCHAR2,
                             p_column     IN VARCHAR2,
                             p_data_type  IN VARCHAR2) RETURN VARCHAR2 IS

  CURSOR rule_cur IS
    select rs.rule_set_id
    from AP_AUD_RULE_SETS rs,
         AP_AUD_RULE_ASSIGNMENTS_ALL rsa
    where rsa.org_id = p_org_id
    and   rsa.rule_set_id = rs.rule_set_id
    and   rs.rule_set_type = p_rule_type
    and   TRUNC(SYSDATE)
            BETWEEN TRUNC(NVL(rsa.START_DATE,SYSDATE))
            AND     TRUNC(NVL(rsa.END_DATE,SYSDATE));

  rule_rec rule_cur%ROWTYPE;
BEGIN

  IF p_org_id is null OR p_rule_type is null THEN
    return null;
  END IF;

  OPEN rule_cur;
  FETCH rule_cur INTO rule_rec;

  IF rule_cur%NOTFOUND THEN
    CLOSE rule_cur;
    return null;
  END IF;

  CLOSE rule_cur;

  return get_object_info(to_char(rule_rec.rule_set_id),
                         p_column,
                         p_data_type,
                        'AP_AUD_RULE_SETS',
                        'rule_set_id');

END get_audit_rule_info;

/*========================================================================
 | PUBLIC FUNCTION get_security_profile_info
 |
 | DESCRIPTION
 |   This function returns the security profile info.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Security Profile info
 |
 | PARAMETERS
 |   p_security_profile_id IN  Security Profile Id
 |   p_column              IN  Column from which the data is retrieved
 |   p_data_type           IN  Data type of the column from which the data is retrieved.
 |                             Supported values: NUMBER, VARCHAR2, DATE
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 02-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_security_profile_info(p_security_profile_id     IN NUMBER,
                                   p_column                  IN VARCHAR2,
                                   p_data_type               IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN

  return get_object_info(to_char(p_security_profile_id),
                         p_column,
                         p_data_type,
                        'per_security_profiles',
                        'security_profile_id');

END get_security_profile_info;

/*========================================================================
 | PUBLIC FUNCTION get_security_profile_org_list
 |
 | DESCRIPTION
 |   This function returns the security profile organization list.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Security Profile organization list
 |
 | PARAMETERS
 |   p_security_profile_id IN  Security Profile Id
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 02-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_security_profile_org_list(p_security_profile_id     IN NUMBER) RETURN VARCHAR2 IS

  CURSOR org_cur IS
   SELECT hou.name org_name
   FROM per_organization_list per,
       HR_ORGANIZATION_UNITS hou
   WHERE per.organization_id = hou.organization_id
   AND   per.security_profile_id = p_security_profile_id;

  l_counter NUMBER := 0;
  l_result  VARCHAR2(4000);

BEGIN

  IF p_security_profile_id is null  THEN
    return null;
  END IF;

  FOR org_rec IN org_cur LOOP
    l_counter := l_counter + 1;
    IF l_counter = 1 THEN
      l_result := org_rec.org_name;
    ELSIF ((length(l_result)+length(org_rec.org_name))<3995) THEN
      l_result := l_result || ', '||org_rec.org_name;
    ELSE
      l_result := l_result || '...';
      EXIT;
    END IF;
  END LOOP;

  return l_result;

END get_security_profile_org_list;

/*========================================================================
 | PUBLIC FUNCTION get_default_security_profile
 |
 | DESCRIPTION
 |   This function returns the default security profile for user.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Default Security Profile
 |
 | PARAMETERS
 |   p_user_id IN  User Id
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 02-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_default_security_profile(p_user_id     IN NUMBER) RETURN NUMBER IS

  CURSOR profile_cur IS
    SELECT FND_PROFILE.VALUE_SPECIFIC('XLA_MO_SECURITY_PROFILE_LEVEL', u.user_id, r.responsibility_id, 200/*SQLAP*/) security_profile_id
    FROM FND_USER u,
         FND_USER_RESP_GROUPS g,
         FND_RESPONSIBILITY r,
         FND_FORM_FUNCTIONS f
    WHERE u.user_id = g.user_id
    AND u.user_id   = p_user_id
    AND g.responsibility_id = r.responsibility_id
    AND AP_WEB_AUDIT_QUEUE_UTILS.IS_FUNCTION_ON_MENU(r.menu_id, f.function_id, 'Y') = 'Y'
    AND f.function_name = 'OIE_AUD_AUDIT';

  profile_rec profile_cur%ROWTYPE;

BEGIN

  IF p_user_id is null  THEN
    return to_number(null);
  END IF;

  OPEN profile_cur;
  FETCH profile_cur INTO profile_rec;

  IF profile_cur%NOTFOUND THEN
    CLOSE profile_cur;
    return to_number(null);
  END IF;

  IF profile_cur%ROWCOUNT > 1 THEN
    CLOSE profile_cur;
    return to_number(null);
  END IF;

  CLOSE profile_cur;
  return profile_rec.security_profile_id;

END get_default_security_profile;

/*========================================================================
 | PUBLIC FUNCTION get_advance_exists
 |
 | DESCRIPTION
 |   This function returns whether advance exists for a given employee.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Y / N whether advance exists
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense report header Id
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 15-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_advance_exists(p_report_header_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR site_cur IS
    SELECT site.invoice_currency_code default_currency_code
    FROM ap_suppliers vdr,
         ap_supplier_sites_all site,
         ap_expense_report_headers_all aerh,
         financials_system_params_all fp
    WHERE aerh.report_header_id = p_report_header_id
    AND aerh.org_id = site.org_id
    AND aerh.org_id = fp.org_id
    AND site.vendor_id = vdr.vendor_id
    AND vdr.employee_id = aerh.employee_id
    AND upper(site.vendor_site_code) = UPPER(AP_WEB_POLICY_UTILS.get_lookup_meaning('HOME_OFFICE', fp.expense_check_address_flag));

  CURSOR vendor_cur IS
    SELECT nvl(vdr.invoice_currency_code,sp.base_currency_code) default_currency_code
    FROM ap_suppliers vdr,
         ap_expense_report_headers_all aerh,
         ap_system_parameters_all sp
    WHERE vdr.employee_id       = aerh.employee_id
    AND   aerh.report_header_id = p_report_header_id
    AND   aerh.org_id = sp.org_id;

  CURSOR advance_cur(p_default_currency_code IN VARCHAR2) IS
    SELECT get_available_prepays(vdr.vendor_id) advance_count,
           aerh.employee_id
     FROM ap_invoices_all i,
          ap_expense_report_headers_all aerh,
          ap_suppliers vdr
    WHERE i.vendor_id = vdr.vendor_id
      AND aerh.report_header_id = p_report_header_id
      AND vdr.employee_id = aerh.employee_id
      AND i.org_id = aerh.org_id
      AND i.invoice_type_lookup_code||'' = 'PREPAYMENT'
      AND i.earliest_settlement_date IS NOT NULL
      AND i.invoice_currency_code = p_default_currency_code
      AND ROWNUM = 1;

  CURSOR applied_cur(p_employee_id NUMBER, p_default_currency_code IN VARCHAR2) IS
    SELECT nvl(sum(maximum_amount_to_apply),0) applied_prepayment
    FROM   ap_expense_report_headers_all aerh
    WHERE  aerh.employee_id = p_employee_id
    AND    aerh.vouchno = 0
    AND    aerh.default_currency_code = p_default_currency_code
    GROUP BY aerh.employee_id;

  CURSOR remaining_cur(p_employee_id NUMBER, p_default_currency_code IN VARCHAR2) IS
    SELECT nvl(sum( get_prepay_amount_remaining(i.invoice_id) ), 0) remaining_prepayment
    FROM   ap_invoices_all i, ap_suppliers vdr
    WHERE  i.vendor_id = vdr.vendor_id
    AND    vdr.employee_id = p_employee_id
    AND    i.invoice_type_lookup_code||'' = 'PREPAYMENT'
    AND    i.earliest_settlement_date IS NOT NULL
    AND    i.payment_status_flag||'' = 'Y'
    AND    i.invoice_currency_code = p_default_currency_code
    GROUP BY vdr.employee_id;

  site_rec                 site_cur%ROWTYPE;
  vendor_rec               vendor_cur%ROWTYPE;
  advance_rec              advance_cur%ROWTYPE;
  applied_rec              applied_cur%ROWTYPE;
  remaining_rec            remaining_cur%ROWTYPE;
  lv_default_currency_code VARCHAR2(15) := NULL;

BEGIN

  IF p_report_header_id is null  THEN
    return 'N';
  END IF;

  OPEN site_cur;
  FETCH site_cur INTO site_rec;

  IF site_cur%FOUND THEN
    CLOSE site_cur;
    lv_default_currency_code := site_rec.default_currency_code;
  ELSE
    CLOSE site_cur;

    OPEN vendor_cur;
    FETCH vendor_cur INTO vendor_rec;
    CLOSE vendor_cur;

    lv_default_currency_code := vendor_rec.default_currency_code;
  END IF;

  IF lv_default_currency_code IS NULL THEN
    RETURN 'N';
  ELSE

    OPEN advance_cur(lv_default_currency_code);
    FETCH advance_cur INTO advance_rec;
    CLOSE advance_cur;

    IF (advance_rec.advance_count > 0)  THEN
      OPEN applied_cur(advance_rec.employee_id, lv_default_currency_code);
      FETCH applied_cur INTO applied_rec;
      CLOSE applied_cur;

      OPEN remaining_cur(advance_rec.employee_id, lv_default_currency_code);
      FETCH remaining_cur INTO remaining_rec;
      CLOSE remaining_cur;

      IF (remaining_rec.remaining_prepayment > applied_rec.applied_prepayment) THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
    ELSE
      RETURN 'N';
    END IF;

  END IF;

END get_advance_exists;

/*========================================================================
 | PUBLIC PROCEDURE is_gl_date_valid
 |
 | DESCRIPTION
 |   This procedure returns whether give date is a valid GL date in AP periods.
 |   Note this is not generic validation, since we have specific requirement
 |   of only "Never Opened" and null to be flagged as invalid.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   p_date_valid         IN  Y / N
 |   p_default_date       IN  if given date is invalid, try to find default GL date
 |
 | PARAMETERS
 |   p_gl_date         IN  GL Date
 |   p_set_of_books_id IN  Set of books identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE is_gl_date_valid(p_gl_date         IN DATE,
                           p_set_of_books_id IN NUMBER,
                           p_date_valid      OUT NOCOPY VARCHAR2,
                           p_default_date    OUT NOCOPY DATE) IS

  CURSOR period_cur IS
    SELECT closing_status
    FROM   gl_period_statuses_v
    WHERE  application_id         = 200
    and    set_of_books_id        = p_set_of_books_id
    and    adjustment_period_flag = 'N'
    and    p_gl_date between start_date and end_date;

  CURSOR default_cur IS
    SELECT max(end_date) default_date
    FROM   gl_period_statuses_v
    WHERE  application_id         = 200
    and    set_of_books_id        = p_set_of_books_id
    and    adjustment_period_flag = 'N'
    and    start_date < p_gl_date
    and    closing_status in ('O', 'F');

  period_rec  period_cur%ROWTYPE;
  default_rec default_cur%ROWTYPE;

BEGIN

  IF p_gl_date is null OR p_set_of_books_id is null THEN
    p_date_valid   := 'N';
    p_default_date := to_date(null);

  ELSE
    OPEN period_cur;
    FETCH period_cur INTO period_rec;

    IF period_cur%NOTFOUND OR period_rec.closing_status = 'N' THEN
      p_date_valid := 'N';
    ELSE
      p_date_valid := 'Y';
    END IF;

    CLOSE period_cur;

    IF p_date_valid = 'N' THEN
      OPEN default_cur;
      FETCH default_cur INTO default_rec;

      IF default_cur%FOUND THEN
        p_default_date := default_rec.default_date;
      END IF;

      CLOSE default_cur;
    END IF;

  END IF;
END is_gl_date_valid;

/*========================================================================
 | PUBLIC FUNCTION get_expense_item_info
 |
 | DESCRIPTION
 |   This function returns the expense item info.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Expense item info
 |
 | PARAMETERS
 |   p_parameter_id IN  Expense item Id
 |   p_column       IN  Column from which the data is retrieved
 |   p_data_type    IN  Data type of the column from which the data is retrieved.
 |                      Supported values: NUMBER, VARCHAR2, DATE
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-Sep-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_expense_item_info(p_parameter_id IN NUMBER,
                               p_column       IN VARCHAR2,
                               p_data_type    IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  return get_object_info(to_char(p_parameter_id),
                         p_column,
                         p_data_type,
                        'AP_EXPENSE_REPORT_PARAMS_ALL',
                        'parameter_id');
END get_expense_item_info;

/*==================== ====================================================
 | PUBLIC FUNCTION is_employee_active
 |
 | DESCRIPTION
 |   This function returns whether the employee is active for a given org.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Y / N depending whether employee is active
 |
 | PARAMETERS
 |   p_employee_id IN  Employee identifier
 |   p_org_id      IN  Organization Id
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 20-Nov-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION is_employee_active(p_employee_id IN NUMBER,
                            p_org_id      IN NUMBER) RETURN VARCHAR2 IS

BEGIN

  RETURN AP_WEB_DB_HR_INT_PKG.IsPersonActive(p_employee_id);

EXCEPTION
  WHEN OTHERS THEN
    /* Even when exception is thrown we do not want to propagate it upwards
     * since this method is used in SQL queries. */
    RETURN 'N';

END is_employee_active;

/*========================================================================
 | PUBLIC FUNCTION is_personal_expense
 |
 | DESCRIPTION
 |   This function returns whether given expense is a personal expense or not.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Y / N Depending whether expense is personal or not
 |
 | PARAMETERS
 |   p_parameter_id       IN  Expense type to check for personal expense
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 04-Feb-2003           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION is_personal_expense(p_parameter_id IN NUMBER) RETURN VARCHAR2 IS
  ln_personal_expense_id NUMBER;
BEGIN

  IF p_parameter_id is null THEN
    return 'N';
  ELSE
   /**
    * Get the expense type parameter id for personal expense.
    */
    ln_personal_expense_id := get_personal_expense_id();

    IF p_parameter_id = ln_personal_expense_id THEN
      return 'Y';
    ELSE
      return 'N';
    END IF;
  END IF;

  return 'N';

END is_personal_expense;

/**
 * jrautiai ADJ Fix start
 */

/*========================================================================
 | PUBLIC FUNCTION is_rounding_line
 |
 | DESCRIPTION
 |   This function returns whether given line is a rounding line or not.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Y / N Depending whether line is a rounding line.
 |
 | PARAMETERS
 |   p_parameter_id       IN  Expense type to check for rounding
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 04-Feb-2003           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION is_rounding_line(p_parameter_id IN NUMBER) RETURN VARCHAR2 IS
  ln_rounding_expense_id NUMBER;
BEGIN

  IF p_parameter_id is null THEN
    return 'N';
  ELSE
   /**
    * Get the expense type parameter id for rounding.
    */
    ln_rounding_expense_id := AP_WEB_AUDIT_UTILS.get_seeded_expense_id('ROUNDING');

    IF p_parameter_id = ln_rounding_expense_id THEN
      return 'Y';
    ELSE
      return 'N';
    END IF;
  END IF;

  return 'N';

END is_rounding_line;

/*========================================================================
 | PUBLIC FUNCTION get_personal_expense_id
 |
 | DESCRIPTION
 |   This function returns personal expense parameter id.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   process_audit_actions
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Expense type parameter if for a personal expense
 |
 | PARAMETERS
 |   None
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Jul-2003           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_personal_expense_id RETURN NUMBER IS

BEGIN

  RETURN get_seeded_expense_id('PERSONAL');

END get_personal_expense_id;

/*========================================================================
 | PUBLIC FUNCTION is_cc_expense_adjusted
 |
 | DESCRIPTION
 |   This function returns whether CC expense has been adjusted.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Y / N Depending whether CC expense has been adjusted
 |
 | PARAMETERS
 |   p_report_header_id       IN  Expense report to be checked
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 15-Jul-2003           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION is_cc_expense_adjusted(p_report_header_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR cc_cur IS
    SELECT erl.report_header_id
    FROM ap_expense_report_lines_all erl
    WHERE erl.report_header_id = p_report_header_id
    AND   erl.credit_card_trx_id is not null
    AND   erl.amount <> NVL(erl.submitted_amount,erl.amount);

  cc_rec  cc_cur%ROWTYPE;

BEGIN

  IF p_report_header_id is null THEN
    return 'N';
  ELSE
    OPEN cc_cur;
    FETCH cc_cur INTO cc_rec;
    IF cc_cur%FOUND THEN
      CLOSE cc_cur;
      return 'Y';
    ELSE
      CLOSE cc_cur;
      return 'N';
    END IF;
  END IF;

  return 'N';

END is_cc_expense_adjusted;

/*========================================================================
 | PUBLIC FUNCTION is_itemized_expense_shortpaid
 |
 | DESCRIPTION
 |   This function returns whether itemized expense has been shortpaid.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Y / N Depending whether itemized expense has been shortpaid
 |
 | PARAMETERS
 |   p_report_header_id       IN  Expense report to be checked
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 15-Jul-2003           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION is_itemized_expense_shortpaid(p_report_header_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR itemized_cur IS
    SELECT erl.report_header_id
    FROM ap_expense_report_lines_all erl
    WHERE erl.report_header_id = p_report_header_id
    AND   erl.itemization_parent_id is not null
    AND   erl.itemization_parent_id <> -1
    AND   NVL(erl.policy_shortpay_flag,'N') = 'Y';

  itemized_rec  itemized_cur%ROWTYPE;

BEGIN

  IF p_report_header_id is null THEN
    return 'N';
  ELSE
    OPEN itemized_cur;
    FETCH itemized_cur INTO itemized_rec;
    IF itemized_cur%FOUND THEN
      CLOSE itemized_cur;
      return 'Y';
    ELSE
      CLOSE itemized_cur;
      return 'N';
    END IF;
  END IF;

  return 'N';

END is_itemized_expense_shortpaid;


/*========================================================================
 | PUBLIC FUNCTION get_expense_clearing_ccid
 |
 | DESCRIPTION
 |   This function returns the expense clearing account for a given transaction.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   process_audit_actions
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Expense clearing account for a given transaction
 |
 | PARAMETERS
 |   Transaction id to fetch the expense clearing account for.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Jul-2003           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_expense_clearing_ccid(p_trx_id IN NUMBER) RETURN NUMBER IS

  CURSOR program_c IS
    SELECT cp.org_id, cp.expense_clearing_ccid
    FROM ap_card_programs_all cp,
         ap_credit_card_trxns_all cct
    WHERE cp.card_program_id = cct.card_program_id
    AND   cct.trx_id = p_trx_id;

  CURSOR ccid_c(p_org_id IN NUMBER) IS
    SELECT EXPENSE_CLEARING_CCID
    FROM   FINANCIALS_SYSTEM_PARAMS_ALL
    WHERE  org_id = p_org_id;

  ln_ccid   NUMBER;
  ln_org_id NUMBER;
BEGIN
  IF p_trx_id IS NULL THEN
    RETURN -1;
  END IF;

  OPEN program_c;
  FETCH program_c into ln_org_id, ln_ccid;
  CLOSE program_c;

  IF (ln_ccid IS NULL) THEN
    OPEN ccid_c(ln_org_id);
    FETCH ccid_c into ln_ccid;
    CLOSE ccid_c;
  END IF;

  IF (ln_ccid IS NULL) THEN
    RETURN -1;
  ELSE
    RETURN ln_ccid;
  END IF;

END get_expense_clearing_ccid;

/*========================================================================
 | PUBLIC FUNCTION get_payment_due_from
 |
 | DESCRIPTION
 |   This function returns the payment due from for a given transaction.
 |   If the payment due from column is not populated on the cc transaction,
 |   then the value of the related profile option is returned.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   process_audit_actions
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Payment due from for a given transaction
 |
 | PARAMETERS
 |   Transaction id for which to fetch the payment due from.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Jul-2003           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_payment_due_from(p_trx_id IN NUMBER) RETURN VARCHAR2 IS
  CURSOR trx_c IS
    SELECT cct.payment_due_from_code
    FROM   ap_credit_card_trxns_all cct
    WHERE  cct.trx_id = p_trx_id;

  lv_payment_due_from_prof VARCHAR2(100);
  lv_payment_due_from      VARCHAR2(100);

BEGIN
  lv_payment_due_from_prof := FND_PROFILE.VALUE('SSE_CC_PAYMENT_DUE_FROM');

  IF p_trx_id IS NULL THEN
    RETURN lv_payment_due_from_prof;
  END IF;

  OPEN trx_c;
  FETCH trx_c into lv_payment_due_from;
  CLOSE trx_c;

  RETURN NVL(lv_payment_due_from,lv_payment_due_from_prof);
END get_payment_due_from;

/*========================================================================
 | PUBLIC FUNCTION get_seeded_expense_id
 |
 | DESCRIPTION
 |   This function returns a seeded expense type id. It is used to get the ID
 |   for personal and rounding expense types.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Expense type parameter id for the seeded expense
 |
 | PARAMETERS
 |   Expense type code for the seeded expense type.
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Jul-2003           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_seeded_expense_id(p_expense_type_code IN VARCHAR2) RETURN NUMBER IS

  CURSOR seeded_expense_cur IS
    SELECT parameter_id
    FROM ap_expense_report_params erp
    WHERE erp.expense_type_code = p_expense_type_code;

  seeded_expense_rec  seeded_expense_cur%ROWTYPE;

BEGIN
  IF     (p_expense_type_code = 'PERSONAL' AND pg_personal_parameter_id is null)
      OR (p_expense_type_code = 'ROUNDING' AND pg_rounding_parameter_id is null) THEN
    OPEN seeded_expense_cur;
    FETCH seeded_expense_cur INTO seeded_expense_rec;
    CLOSE seeded_expense_cur;

    IF p_expense_type_code = 'PERSONAL' THEN
      pg_personal_parameter_id := seeded_expense_rec.parameter_id;
    ELSIF p_expense_type_code = 'ROUNDING' THEN
      pg_rounding_parameter_id := seeded_expense_rec.parameter_id;
    END IF;
  END IF;

  IF p_expense_type_code = 'PERSONAL' THEN
    RETURN pg_personal_parameter_id;
  ELSIF p_expense_type_code = 'ROUNDING' THEN
    RETURN pg_rounding_parameter_id;
  ELSE
    RETURN to_number(null);
  END IF;

END get_seeded_expense_id;


/*========================================================================
 | PUBLIC FUNCTION get_next_distribution_line_id
 |
 | DESCRIPTION
 |   This function returns a the next distribution number for the report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   The next distribution line number for the expense report.
 |
 | PARAMETERS
 |   Expense report identifier.
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Jul-2003           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_next_distribution_line_id(p_report_header_id IN NUMBER) RETURN NUMBER IS

  CURSOR next_distribution_line_c(p_report_header_id NUMBER) IS
    SELECT max(distribution_line_number) + 1
    FROM   AP_EXPENSE_REPORT_LINES_ALL
    WHERE  report_header_id = p_report_header_id;

  ln_next_dist_line_number NUMBER;

BEGIN
  IF p_report_header_id IS NULL THEN
    RETURN to_number(NULL);
  ELSE
    OPEN next_distribution_line_c(p_report_header_id);
    FETCH next_distribution_line_c into ln_next_dist_line_number;
    CLOSE next_distribution_line_c;

    RETURN ln_next_dist_line_number;
  END IF;

END get_next_distribution_line_id;

/*========================================================================
 | PUBLIC FUNCTION get_rounding_error_ccid
 |
 | DESCRIPTION
 |   This function returns the rounding error account for a given org.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   process_audit_actions
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Rounding error account for a given org
 |
 | PARAMETERS
 |   Organization id to fetch the rounding error account for.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Jul-2003           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_rounding_error_ccid(p_org_id IN NUMBER) RETURN NUMBER IS

  CURSOR ccid_c IS
    SELECT ROUNDING_ERROR_CCID
    FROM   ap_system_parameters_all
    WHERE  org_id = p_org_id;

  ln_ccid NUMBER;
BEGIN
  IF p_org_id IS NULL THEN
    RETURN -1;
  END IF;

  OPEN ccid_c;
  FETCH ccid_c into ln_ccid;
  CLOSE ccid_c;

  IF (ln_ccid IS NULL) THEN
    RETURN -1;
  ELSE
    RETURN ln_ccid;
  END IF;

END get_rounding_error_ccid;

/**
 * jrautiai ADJ Fix end
 */

 /*========================================================================
 | PUBLIC FUNCTION get_user_name
 |
 | DESCRIPTION
 |   This function returns the name for a given FND user.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Name for a given FND user
 |
 | PARAMETERS
 |   FND user ID.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 18-Aug-2003           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_user_name(p_user_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR user_c IS
    SELECT DECODE(usr.employee_id,
                  null, usr.user_name,
                  AP_WEB_AUDIT_UTILS.get_employee_info(usr.employee_id,'full_name','VARCHAR2')) last_audited_by_name
    FROM   fnd_user usr
    WHERE  usr.user_id = p_user_id;

  user_rec user_c%ROWTYPE;
BEGIN
  IF p_user_id IS NULL THEN
    return null;
  END IF;

  OPEN user_c;
  FETCH user_c into user_rec;
  CLOSE user_c;

  RETURN user_rec.last_audited_by_name;

END get_user_name;

/*========================================================================
 | PUBLIC FUNCTION get_lookup_description
 |
 | DESCRIPTION
 |   This function returns the description of a lookup code.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Description of a lookup code
 |
 | PARAMETERS
 |   Lookup type and lookup code
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 24-Oct-2003           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_lookup_description(p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2) RETURN VARCHAR2 IS
  l_meaning fnd_lookup_values_vl.description%TYPE;
BEGIN

  IF p_lookup_code IS NOT NULL AND
     p_lookup_type IS NOT NULL THEN

      SELECT description
      INTO   l_meaning
      FROM   fnd_lookup_values_vl
      WHERE  lookup_type = p_lookup_type
        AND  lookup_code = p_lookup_code;

      return l_meaning;
  END IF;

  return to_char(null);

EXCEPTION
 WHEN no_data_found  THEN
  return(null);
 WHEN OTHERS THEN
  raise;
END get_lookup_description;

/*========================================================================
 | PUBLIC FUNCTION get_non_project_ccid
 |
 | DESCRIPTION
 |   This function returns a CCID with segments overridden by the expense
 |   type definitions.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   CCID with segments overridden by the expense type definitions
 |
 | PARAMETERS
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 07-Nov-2003           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_non_project_ccid(p_report_header_id         IN NUMBER,
                              p_report_distribution_id   IN NUMBER,
                              p_parameter_id             IN NUMBER,
                              p_ccid                     IN NUMBER) RETURN NUMBER IS

  l_new_segments AP_OIE_KFF_SEGMENTS_T;
  l_new_ccid NUMBER := to_number(null);
  -- Bug: 7039477, sync error message length with fnd_flex_keyval.err_text
  l_return_error_message VARCHAR2(2000);

  CURSOR expense_c IS
    SELECT
           aerh.employee_id employee_id,
           aerh.flex_concatenated header_cost_center,
           aerd.report_line_id report_line_id,
           aerd.cost_center line_cost_center
    FROM
         ap_expense_report_headers_all aerh,
         ap_exp_report_dists_all aerd
    WHERE aerh.report_header_id = p_report_header_id
    AND   aerd.report_header_id = aerh.report_header_id
    AND   aerd.report_distribution_id = p_report_distribution_id;

  expense_rec expense_c%ROWTYPE;
BEGIN

  /* All the parameters are required, if any is missing return null */
  IF (p_report_header_id IS NULL OR p_report_distribution_id IS NULL OR p_parameter_id IS NULL OR p_ccid IS NULL) THEN
    RETURN l_new_ccid;
  END IF;

  OPEN expense_c;
  FETCH expense_c into expense_rec;
  IF expense_c%NOTFOUND THEN
    CLOSE expense_c;
    RETURN l_new_ccid;
  END IF;
  CLOSE expense_c;

  AP_WEB_ACCTG_PKG.BuildAccount(
        p_report_header_id => p_report_header_id,
        p_report_line_id => expense_rec.report_line_id,
        p_employee_id => expense_rec.employee_id,
        p_cost_center => expense_rec.header_cost_center,
        p_line_cost_center => expense_rec.line_cost_center,
        p_exp_type_parameter_id => p_parameter_id,
        p_segments => null,
        p_ccid => p_ccid,
        p_build_mode => AP_WEB_ACCTG_PKG.C_BUILD_VALIDATE,
        p_new_segments => l_new_segments,
        p_new_ccid => l_new_ccid,
        p_return_error_message => l_return_error_message);

  if (l_return_error_message is not null) then
    return to_number(null);
  else
    return l_new_ccid;
  end if;

EXCEPTION
 WHEN OTHERS THEN
   return to_number(null);

END get_non_project_ccid;


/*========================================================================
 | PUBLIC FUNCTION get_report_profile_value
 |
 | DESCRIPTION
 |   This function returns profile option value for a submitted report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Profile option value.
 |
 | PARAMETERS
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-Dec-2003           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_report_profile_value(p_report_header_id IN NUMBER,
                                  p_profile_name     IN VARCHAR2) RETURN VARCHAR2 IS

  l_item_type VARCHAR2(100) := 'APEXP';
  l_item_key  VARCHAR2(100) := to_char(p_report_header_id);

  l_n_org_id       NUMBER;
  l_n_user_id      NUMBER;
  l_n_resp_id      NUMBER;
  l_n_resp_appl_id NUMBER;
  lv_return_value  VARCHAR2(255);
BEGIN
  IF p_report_header_id IS NULL OR p_profile_name IS NULL THEN
    return NULL;
  END IF;

  l_n_org_id := WF_ENGINE.GetItemAttrNumber(l_item_type,
                                            l_item_key,
                                            'ORG_ID');

  l_n_user_id := WF_ENGINE.GetItemAttrNumber(l_item_type,
                                             l_item_key,
                                             'USER_ID');

  l_n_resp_id := WF_ENGINE.GetItemAttrNumber(l_item_type,
                                             l_item_key,
                                             'RESPONSIBILITY_ID');

  l_n_resp_appl_id := WF_ENGINE.GetItemAttrNumber(l_item_type,
                                                  l_item_key,
                                                  'APPLICATION_ID');

  lv_return_value := fnd_profile.VALUE_SPECIFIC(p_profile_name,
                                                l_n_user_id,
                                                l_n_resp_id,
                                                l_n_resp_appl_id,
                                                l_n_org_id);
  RETURN lv_return_value;

EXCEPTION
  WHEN OTHERS THEN
    /* Something threw an exception, we cannot fix the issue so return null
     * to indicate that value could not be fetched. */
    RETURN NULL;
END get_report_profile_value;

/*========================================================================
 | PUBLIC FUNCTION get_average_pdm_rate
 |
 | DESCRIPTION
 |   This function returns the average pdm rate on an line.
 |   The logic has been copied from BC4J VO method:
 |     PerDiemLinesVORowImpl.calculateTransientValues
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Average PDM rate as NUMBER.
 |
 | PARAMETERS
 |   p_report_header_id         IN  Expense report header identifier
 |   p_distribution_line_number IN  Expense report line identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Jan-2004           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_average_pdm_rate(p_report_header_id         IN NUMBER,
                              p_distribution_line_number IN NUMBER) RETURN NUMBER IS
  CURSOR pdm_cur IS
    select NVL(aerl.NUM_PDM_DAYS1,0) NUM_PDM_DAYS1,
           NVL(aerl.NUM_PDM_DAYS2,0) NUM_PDM_DAYS2,
           NVL(aerl.NUM_PDM_DAYS3,0) NUM_PDM_DAYS3,
           NVL(aerl.PER_DIEM_RATE1,0) PER_DIEM_RATE1,
           NVL(aerl.PER_DIEM_RATE2,0) PER_DIEM_RATE2,
           NVL(aerl.PER_DIEM_RATE3,0) PER_DIEM_RATE3,
           NVL(end_expense_date - start_expense_date,0)+1 number_of_days,
           ph.day_period_code
    from ap_expense_report_lines_all aerl,
         ap_pol_headers ph,
         ap_expense_report_params_all erp
    where aerl.report_header_id = p_report_header_id
    and   aerl.distribution_line_number = p_distribution_line_number
    and   aerl.category_code = AP_WEB_POLICY_UTILS.c_PER_DIEM
    and   erp.parameter_id = aerl.web_parameter_id
    and   ph.policy_id = erp.company_policy_id;

  pdm_rec pdm_cur%ROWTYPE;
  l_average NUMBER := 0;
  l_total   NUMBER := 0;
  l_days    NUMBER := 1;
BEGIN
  IF p_report_header_id is null or p_distribution_line_number is null THEN
    return to_number(null);
  END IF;

  OPEN pdm_cur;
  FETCH pdm_cur INTO pdm_rec;

  IF pdm_cur%NOTFOUND THEN
    CLOSE pdm_cur;
    return to_number(null);
  END IF;

  CLOSE pdm_cur;

  IF pdm_rec.day_period_code is NULL THEN
    l_total := pdm_rec.NUM_PDM_DAYS1 * pdm_rec.PER_DIEM_RATE1;
    l_days  := pdm_rec.NUM_PDM_DAYS1;
  ELSIF pdm_rec.day_period_code = 'START_TIME' THEN
    l_total := (pdm_rec.NUM_PDM_DAYS1 * pdm_rec.PER_DIEM_RATE1) + pdm_rec.PER_DIEM_RATE2;
    l_days  := pdm_rec.NUM_PDM_DAYS1 + pdm_rec.NUM_PDM_DAYS2;
  ELSIF pdm_rec.day_period_code = 'MIDNIGHT' THEN
    l_total := pdm_rec.PER_DIEM_RATE1 + (pdm_rec.NUM_PDM_DAYS2 * pdm_rec.PER_DIEM_RATE2) + pdm_rec.PER_DIEM_RATE3;
    l_days  := pdm_rec.NUM_PDM_DAYS1 + pdm_rec.NUM_PDM_DAYS2 + pdm_rec.NUM_PDM_DAYS3;
  ELSE
    return to_number(null);
  END IF;

  IF l_days = 0 OR l_days IS NULL THEN
    l_days := 1;
  END IF;

  l_average := l_total / l_days;

  return l_average;

EXCEPTION
 WHEN OTHERS THEN
  /* If an unhandled exception occurs we do not want to propagate the exception
   * upwards, since this is display data only. */
  return to_number(null);

END get_average_pdm_rate;

/*========================================================================
 | PUBLIC FUNCTION get_audit_indicator
 |
 | DESCRIPTION
 |   This function returns audit indicator displayed on the confirmation page.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Audit indicator as VARCHAR2.
 |
 | PARAMETERS
 |   p_report_header_id         IN  Expense report header identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 26-Apr-2004           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_audit_indicator(p_report_header_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR rule_cur IS
    select rs.auto_approval_tag,
           rs.requires_audit_tag,
           rs.paperless_audit_tag,
           aerh.audit_code,
	   rs.image_audit_tag,
	   nvl(rs.aud_img_receipt_required,'X') aud_img_receipt_required,
	   nvl(rs.aud_paper_receipt_required, 'X') aud_paper_receipt_required,
	   nvl(aerh.image_receipts_status,'NOT_REQUIRED') hdr_img_receipt_required,
	   nvl(aerh.receipts_status,'NOT_REQUIRED') hdr_paper_receipt_required
    from AP_EXPENSE_REPORT_HEADERS_ALL aerh,
         AP_AUD_RULE_SETS rs,
         AP_AUD_RULE_ASSIGNMENTS_ALL rsa
    where aerh.report_header_id = p_report_header_id
    and   aerh.org_id = rsa.org_id
    and   rsa.rule_set_id = rs.rule_set_id
    and   rs.rule_set_type = 'RULE'
    and   TRUNC(SYSDATE)
            BETWEEN TRUNC(NVL(rsa.START_DATE,SYSDATE))
            AND     TRUNC(NVL(rsa.END_DATE,SYSDATE));

  rule_rec rule_cur%ROWTYPE;
BEGIN

  IF p_report_header_id is null  THEN
    return null;
  END IF;

  OPEN rule_cur;
  FETCH rule_cur INTO rule_rec;

  IF rule_cur%NOTFOUND THEN
    CLOSE rule_cur;
    return null;
  END IF;

  CLOSE rule_cur;

  IF rule_rec.audit_code = 'PAPERLESS_AUDIT' THEN
    RETURN rule_rec.paperless_audit_tag;
  ELSIF rule_rec.audit_code = 'AUTO_APPROVE' THEN
    RETURN rule_rec.auto_approval_tag;
  ELSIF rule_rec.audit_code = 'RECEIPT_BASED' THEN
    RETURN rule_rec.image_audit_tag;
  ELSE
    RETURN rule_rec.requires_audit_tag;
  END IF;

END get_audit_indicator;

/*========================================================================
 | PUBLIC FUNCTION get_report_status_code
 |
 | DESCRIPTION
 |   This function returns expense report status code.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Expense report status code as VARCHAR2.
 |
 | PARAMETERS
 |   p_report_header_id         IN  Expense report header identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-May-2004           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_report_status_code(p_report_header_id IN NUMBER,
				p_invoice_id IN NUMBER DEFAULT NULL,
                                p_cache IN VARCHAR2 DEFAULT 'N') RETURN VARCHAR2 IS
  CURSOR status_cur IS
    select aerh.source,
           AERH.Expense_Status_Code,
           AERH.Workflow_approved_flag,
	   AERH.AMT_DUE_CCARD_COMPANY,
	   AERH.AMT_DUE_EMPLOYEE,
           AI.Payment_status_flag,
           APS.GROSS_AMOUNT,
           AI.CANCELLED_DATE
    from ap_expense_report_headers_all aerh,
         AP_INVOICES_ALL AI,
         AP_PAYMENT_SCHEDULES_ALL APS
    where AI.INVOICE_ID(+)  = AERH.VOUCHNO
    and   APS.INVOICE_ID(+) = AI.INVOICE_ID
    and   aerh.report_header_id = p_report_header_id;

CURSOR invoice_cur IS
    SELECT AI.Payment_status_flag,
           APS.GROSS_AMOUNT,
           AI.CANCELLED_DATE
    from AP_INVOICES_ALL AI,
         AP_PAYMENT_SCHEDULES_ALL APS
    where AI.INVOICE_ID= APS.INVOICE_ID
    AND AI.INVOICE_ID = p_invoice_id;

  status_rec status_cur%ROWTYPE;
  invoice_rec invoice_cur%ROWTYPE;

  l_status_code               VARCHAR(30);
  l_payment_due_from_report   VARCHAR(30);
BEGIN

 -- Check cache
  IF ((p_report_header_id = grsc_old_report_header_id) AND (p_invoice_id = grsc_old_invoice_id) AND (p_cache = 'Y'))THEN
    RETURN grsc_old_status_code;
  END IF;

  l_status_code := null;

  IF p_report_header_id is null  THEN

    IF  p_invoice_id is null THEN

      return null;

    ELSE

	OPEN invoice_cur;
	FETCH invoice_cur INTO invoice_rec;

	IF invoice_cur%NOTFOUND THEN
	CLOSE invoice_cur;
	return null;
	END IF;

	IF invoice_rec.cancelled_date is not null THEN
	l_status_code := 'CANCELLED';
	END IF;

	IF invoice_rec.GROSS_AMOUNT = 0 OR invoice_rec.Payment_status_flag = 'Y' THEN
	l_status_code := 'PAID';
	END IF;


	IF invoice_rec.Payment_status_flag = 'P' THEN
	l_status_code := 'PARPAID';
	END IF;


	IF invoice_rec.Payment_status_flag = 'N' THEN
	l_status_code := 'INVOICED';
	END IF;

	-- Update cache
	grsc_old_status_code := l_status_code;
	grsc_old_report_header_id := p_report_header_id;
	grsc_old_invoice_id := p_invoice_id;

	RETURN l_status_code;

    END IF;

  END IF;

  OPEN status_cur;
  FETCH status_cur INTO status_rec;

  IF status_cur%NOTFOUND THEN
    CLOSE status_cur;
    return null;
  END IF;

  CLOSE status_cur;

  IF status_rec.cancelled_date is not null THEN
    l_status_code := 'CANCELLED';
  END IF;

  IF status_rec.GROSS_AMOUNT = 0 OR status_rec.Payment_status_flag = 'Y' THEN
    l_status_code := 'PAID';
  END IF;


  IF status_rec.Payment_status_flag = 'P' THEN
    l_status_code := 'PARPAID';
  END IF;


  IF status_rec.Payment_status_flag = 'N' THEN
    l_status_code := 'INVOICED';
  END IF;


  IF  l_status_code IS NULL THEN

	  IF status_rec.expense_status_code is not null THEN
	    l_status_code := status_rec.expense_status_code;
	  ELSE
	    l_status_code :=  AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(status_rec.Source,
							    status_rec.Workflow_approved_flag,
							    p_report_header_id,
							    'N');
	  END IF;

  END IF;


  --Checked if report is both pay, then get the both pay status code
   l_payment_due_from_report := AP_WEB_DB_EXPRPT_PKG.getPaymentDueFromReport(p_report_header_id);

   IF l_payment_due_from_report IS NOT NULL AND l_payment_due_from_report = 'BOTH' THEN

     l_status_code := AP_WEB_OA_ACTIVE_PKG.GetBothPayStatusCode(p_report_header_id, l_status_code,
                                                                status_rec.AMT_DUE_CCARD_COMPANY,
				                                status_rec.AMT_DUE_EMPLOYEE);

   END IF;

  -- Update cache
  grsc_old_status_code := l_status_code;
  grsc_old_report_header_id := p_report_header_id;
  grsc_old_invoice_id := p_invoice_id;

   RETURN l_status_code;

END get_report_status_code;

FUNCTION get_prepay_amount_remaining (P_invoice_id IN NUMBER) RETURN NUMBER IS

	l_prepay_amount_remaining NUMBER := 0;

        CURSOR c_prepay_amount_remaining IS
          SELECT SUM(nvl(aid.prepay_amount_remaining,ail.amount))
          FROM  ap_invoice_lines_all ail,
                ap_invoice_distributions aid
          WHERE ail.invoice_id =  P_invoice_id
          AND   aid.invoice_id = ail.invoice_id
          AND   aid.invoice_line_number = ail.line_number
          AND   ail.line_type_lookup_code IN ('ITEM','TAX')
          AND   nvl(aid.reversal_flag,'N') <> 'Y';

BEGIN

	OPEN c_prepay_amount_remaining;
	FETCH c_prepay_amount_remaining INTO l_prepay_amount_remaining;
	CLOSE c_prepay_amount_remaining;

	RETURN(l_prepay_amount_remaining);

END get_prepay_amount_remaining;

FUNCTION get_available_prepays(l_vendor_id IN NUMBER) RETURN NUMBER IS
  prepay_count           NUMBER := 0;
BEGIN

  SELECT SUM(DECODE(payment_status_flag,
                    'Y', DECODE(SIGN(earliest_settlement_date - SYSDATE),
                                1,0,
                                1),
                     0))
  INTO prepay_count
  FROM   ap_invoices_all ai
  WHERE  vendor_id = l_vendor_id
  AND    invoice_type_lookup_code = 'PREPAYMENT'
  AND    earliest_settlement_date IS NOT NULL
  AND    get_prepay_amount_remaining(ai.invoice_id) > 0;

  return(prepay_count);

END get_available_prepays;

/*========================================================================
 | PUBLIC PROCEDURE get_rule
 |
 | DESCRIPTION
 |   This procedures finds a audit rule matching the criteria provided.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from WF.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None
 |
 | PARAMETERS
 |   p_org_id         IN  organization identifier
 |   p_date           IN  date that the rule is effective
 |   p_rule_type      IN  rule type; 'RULE', 'AUDIT_LIST, 'NOTIFY' or 'HOLD'
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-Oct-2004           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE get_rule(p_org_id IN NUMBER, p_date IN DATE, p_rule_type IN VARCHAR2, p_rule OUT NOCOPY AP_AUD_RULE_SETS%ROWTYPE) IS

  CURSOR rule_cur IS
    select rs.*
    from AP_AUD_RULE_SETS rs,
         AP_AUD_RULE_ASSIGNMENTS_ALL rsa
    where rsa.org_id = p_org_id
    and   rsa.rule_set_id = rs.rule_set_id
    and   rs.rule_set_type = p_rule_type
    and   TRUNC(p_date)
            BETWEEN TRUNC(NVL(rsa.START_DATE,p_date))
            AND     TRUNC(NVL(rsa.END_DATE,p_date));

  rule_rec AP_AUD_RULE_SETS%ROWTYPE;
BEGIN
  IF (p_org_id is null OR p_date IS NULL OR p_rule_type IS NULL ) THEN
   return;
  END IF;

	OPEN rule_cur;
	FETCH rule_cur INTO rule_rec;
  IF rule_cur%FOUND THEN
    p_rule := rule_rec;
  END IF;
	CLOSE rule_cur;

END get_rule;


/*========================================================================
 | PUBLIC FUNCTION has_default_cc_itemization
 |
 | DESCRIPTION
 |   This function finds if the credit card transaction has level3 data
 |   from the card provider.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from AuditReportLinesVO.xml.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   VARCHAR2 (Y/N)
 |
 | PARAMETERS
 |   p_cc_trx_id      IN  credit card transaction id
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 02-Dec-2004           Krish Menon       Created
 |
 *=======================================================================*/
FUNCTION has_default_cc_itemization(p_cc_trx_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR cc_trx IS
    select nvl(trxn_detail_flag, 'N') as trxn_detail_flag
    from   ap_credit_card_trxns_all
    where  trx_id = p_cc_trx_id;

  l_trx_detail_flag VARCHAR2(1);

BEGIN
   l_trx_detail_flag := 'N';

   IF ( p_cc_trx_id IS NULL ) THEN
     RETURN l_trx_detail_flag;
   END IF;

   FOR cc_rec IN cc_trx
   LOOP
     l_trx_detail_flag := cc_rec.trxn_detail_flag;
   END LOOP;

   RETURN l_trx_detail_flag;

END has_default_cc_itemization;


/*========================================================================
 |
 | DESCRIPTION
 |   This function returns 'Y' if there is capture rule and 'N' otherwise.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   'Y' or 'N' as VARCHAR2.
 |
 | PARAMETERS
 |   p_reportLineId  IN  report line identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 31-01-2005            Quan Le      Created
 |
 *=======================================================================*/
FUNCTION isAttendeeAvailable(p_reportLineId IN NUMBER) RETURN VARCHAR2 IS
  l_return VARCHAR2(1);
BEGIN

    select 'Y'
    into   l_return
    from   OIE_ATTENDEES_ALL
    where  p_reportLineId = report_line_id
    and    rownum = 1;

    return 'Y';

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return 'N';
  WHEN OTHERS THEN
    return 'N';

END isAttendeeAvailable;


/*========================================================================
 |
 | DESCRIPTION
 |   This function returns attendee type from lookup code
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Attendee type as VARCHAR2.
 |
 | PARAMETERS
 |   p_attendeeCode  IN  attendee type code
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 31-01-2005            Quan Le      Created
 |
 *=======================================================================*/
FUNCTION getAttendeeType(p_attendeeCode IN VARCHAR2) RETURN VARCHAR2 IS
  l_return AP_LOOKUP_CODES.displayed_field%type := null;
BEGIN

    select displayed_field
    into   l_return
    from   AP_LOOKUP_CODES
    where  lookup_type = 'OIE_ATTENDEE_TYPE'
    and  lookup_code = p_attendeeCode;

    return l_return;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return null;
  WHEN OTHERS THEN
    return null;

END getAttendeeType;

/*========================================================================
 | PUBLIC PROCEDURE clear_audit_reason_codes
 |
 | DESCRIPTION
 |   This procedures clears the data from AP_AUD_AUDIT_REASONS table
 |   for specified expense report.
 |
 | RETURNS
 |
 | PARAMETERS
 |    p_report_header_id : report header id of the expense report
 |
 | MODIFICATION HISTORY
 |
 *=======================================================================*/
PROCEDURE clear_audit_reason_codes(p_report_header_id IN NUMBER) IS
BEGIN

    delete
    from ap_aud_audit_reasons
    where report_header_id = p_report_header_id
    and audit_reason_code <> 'RANDOM';

EXCEPTION
    when others then null;

END clear_audit_reason_codes;

PROCEDURE get_dist_project_ccid( p_parameter_id             IN NUMBER,
                           p_report_distribution_id   IN NUMBER,
                           p_new_ccid                 OUT NOCOPY NUMBER,
                           p_return_status            OUT NOCOPY VARCHAR2) is

 l_new_segments         AP_OIE_KFF_SEGMENTS_T;
 l_return_error_message varchar2(2000);

 l_report_header_id     NUMBER;
 l_report_line_id       NUMBER;

BEGIN

  SELECT
    report_header_id,
    report_line_id
  INTO
    l_report_header_id,
    l_report_line_id
  FROM
    ap_exp_report_dists_all
  WHERE
    report_distribution_id = p_report_distribution_id;

  AP_WEB_ACCTG_PKG.BuildDistProjectAccount(
        p_report_header_id => l_report_header_id,
        p_report_line_id => l_report_line_id,
        p_report_distribution_id => p_report_distribution_id,
        p_exp_type_parameter_id => p_parameter_id,
        p_new_segments => l_new_segments,
        p_new_ccid => p_new_ccid,
        p_return_error_message => l_return_error_message,
        p_return_status => p_return_status);

EXCEPTION
  WHEN OTHERS THEN
    /* could not generate the projects CCID */
    p_new_ccid := to_number(null);
    p_return_status := 'ERROR';

END get_dist_project_ccid;


PROCEDURE GetDefaultAcctgSegValues(
             P_REPORT_HEADER_ID    IN  NUMBER,
             P_REPORT_LINE_ID      IN  NUMBER,
             P_EMPLOYEE_ID         IN  NUMBER,
	     P_HEADER_COST_CENTER  IN  AP_EXPENSE_REPORT_HEADERS.flex_concatenated%TYPE,
	     P_PARAMETER_ID        IN  NUMBER,
             P_SEGMENTS            IN  AP_OIE_KFF_SEGMENTS_T,
             X_SEGMENTS            OUT NOCOPY AP_OIE_KFF_SEGMENTS_T,
             x_combination_id      OUT NOCOPY HR_EMPLOYEES_CURRENT_V.default_code_combination_id%TYPE,
             X_MSG_COUNT           OUT NOCOPY NUMBER,
             X_MSG_DATA            OUT NOCOPY VARCHAR2,
             X_RETURN_STATUS       OUT NOCOPY VARCHAR2) IS
----------------------------------------------------------------------
  -- Bug: 7039477, sync error message length with fnd_flex_keyval.err_text
  l_return_error_message               VARCHAR2(2000);
  l_debug_info                         varchar2(200);
  l_ccid                               NUMBER;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_AUDIT_UTILS', 'Start GetDefaultAcctgSegValues');

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;



  l_debug_info := 'Call build account to get new segments';
  AP_WEB_ACCTG_PKG.BuildAccount(
        p_report_header_id => p_report_header_id,
        p_report_line_id => p_report_line_id,
        p_employee_id => p_employee_id,
        p_cost_center => p_header_cost_center,
        p_line_cost_center => null,
        p_exp_type_parameter_id => p_parameter_id,
        p_segments => p_segments,
        p_ccid => null,
        p_build_mode => AP_WEB_ACCTG_PKG.C_DEFAULT_VALIDATE,
        p_new_segments => x_segments,
        p_new_ccid => x_combination_id,
        p_return_error_message => l_return_error_message);


  if (l_return_error_message is not null) then
    raise G_EXC_ERROR;
  end if;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_AUDIT_UTILS', 'end GetDefaultAcctgSegValues');

EXCEPTION
  WHEN G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END GetDefaultAcctgSegValues;


END AP_WEB_AUDIT_UTILS;

/
