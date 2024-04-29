--------------------------------------------------------
--  DDL for Package AP_WEB_AUDIT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_AUDIT_UTILS" AUTHID CURRENT_USER AS
/* $Header: apwaudus.pls 120.19 2006/08/14 22:02:38 qle noship $ */
/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

G_EXC_ERROR             EXCEPTION;
G_EXC_UNEXPECTED_ERROR  EXCEPTION;

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
 | 16-Aug-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_employee_info(p_employee_id     IN NUMBER,
                           p_column          IN VARCHAR2,
                           p_data_type       IN VARCHAR2) RETURN VARCHAR2;

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
 |   Task info as VARCHAR2.
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
                       p_column          IN VARCHAR2,
                       p_data_type       IN VARCHAR2) RETURN VARCHAR2;

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
 |   Project info as VARCHAR2.
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
                          p_data_type       IN VARCHAR2) RETURN VARCHAR2;

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
 |   Project info as VARCHAR2.
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
                        p_data_type       IN VARCHAR2) RETURN VARCHAR2;

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
                            p_data_type       IN VARCHAR2) RETURN VARCHAR2;

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
                           p_data_type IN VARCHAR2) RETURN VARCHAR2;

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
                         p_distribution_line_number IN NUMBER) RETURN VARCHAR2;

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
FUNCTION get_expense_type(p_parameter_id IN NUMBER) RETURN VARCHAR2;

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
                              p_distribution_line_number IN NUMBER) RETURN NUMBER;

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
                                 p_distribution_line_number IN NUMBER) RETURN NUMBER;

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
                                 p_distribution_line_number IN NUMBER) RETURN NUMBER;

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
                            p_distribution_line_number IN NUMBER) RETURN NUMBER;

FUNCTION get_object_info(p_key             IN VARCHAR2,
                         p_column          IN VARCHAR2,
                         p_result_type     IN VARCHAR2,
                         p_table           IN VARCHAR2,
                         p_key_column      IN VARCHAR2,
                         p_order_by_clause IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

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
                              p_distribution_line_number IN NUMBER) RETURN VARCHAR2;

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
FUNCTION get_flex_structure_code(p_org_id IN NUMBER) RETURN VARCHAR2;

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
PROCEDURE set_show_audit_header_flag(p_show_header IN VARCHAR2);

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
FUNCTION get_show_audit_header_flag RETURN VARCHAR2;

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
FUNCTION get_rule_set_assignment_exists(p_rule_set_id IN NUMBER) RETURN VARCHAR2;

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
                           p_data_type  IN VARCHAR2) RETURN VARCHAR2;

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
                             p_data_type  IN VARCHAR2) RETURN VARCHAR2;

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
FUNCTION get_audit_reason(p_report_header_id  IN NUMBER) RETURN VARCHAR2;

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
FUNCTION get_person_org_id(p_person_id IN NUMBER) RETURN NUMBER;

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
 |   p_report_header_id         IN  Expense report identier
 |   p_reason_code              IN  Reason person is being added to the list
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 18-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE set_audit_list_member(p_report_header_id IN NUMBER, p_reason_code  IN VARCHAR2);

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
FUNCTION get_audit_list_member(p_employee_id IN NUMBER) RETURN VARCHAR2;


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
FUNCTION get_auditor_name(p_auditor_id     IN NUMBER) RETURN VARCHAR2;


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
 |   p_rule_type   IN  Rule Set type
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
                             p_data_type  IN VARCHAR2) RETURN VARCHAR2;

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
                                   p_data_type               IN VARCHAR2) RETURN VARCHAR2;

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
FUNCTION get_security_profile_org_list(p_security_profile_id     IN NUMBER) RETURN VARCHAR2;

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
FUNCTION get_default_security_profile(p_user_id     IN NUMBER) RETURN NUMBER;


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
FUNCTION get_advance_exists(p_report_header_id IN NUMBER) RETURN VARCHAR2;

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
                           p_default_date    OUT NOCOPY DATE);

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
                               p_data_type    IN VARCHAR2) RETURN VARCHAR2;

/*========================================================================
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
                            p_org_id      IN NUMBER) RETURN VARCHAR2;


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
FUNCTION is_personal_expense(p_parameter_id IN NUMBER) RETURN VARCHAR2;

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
FUNCTION is_rounding_line(p_parameter_id IN NUMBER) RETURN VARCHAR2;

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
FUNCTION is_cc_expense_adjusted(p_report_header_id IN NUMBER) RETURN VARCHAR2;

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
FUNCTION is_itemized_expense_shortpaid(p_report_header_id IN NUMBER) RETURN VARCHAR2;


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
FUNCTION get_personal_expense_id
RETURN NUMBER;

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
FUNCTION get_expense_clearing_ccid(p_trx_id IN NUMBER) RETURN NUMBER;

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
FUNCTION get_payment_due_from(p_trx_id IN NUMBER) RETURN VARCHAR2;

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
FUNCTION get_seeded_expense_id(p_expense_type_code IN VARCHAR2) RETURN NUMBER;

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
FUNCTION get_next_distribution_line_id(p_report_header_id IN NUMBER) RETURN NUMBER;

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
FUNCTION get_rounding_error_ccid(p_org_id IN NUMBER) RETURN NUMBER;
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
FUNCTION get_user_name(p_user_id IN NUMBER) RETURN VARCHAR2;

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
FUNCTION get_lookup_description(p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2) RETURN VARCHAR2;

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
                              p_ccid                     IN NUMBER) RETURN NUMBER;

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
                                  p_profile_name     IN VARCHAR2) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION get_average_pdm_rate
 |
 | DESCRIPTION
 |   This function returns the average pdm rate on an line.
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
                              p_distribution_line_number IN NUMBER) RETURN NUMBER;

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
FUNCTION get_audit_indicator(p_report_header_id IN NUMBER) RETURN VARCHAR2;

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
                                p_cache IN VARCHAR2 DEFAULT 'N' ) RETURN VARCHAR2;

FUNCTION get_prepay_amount_remaining (P_invoice_id IN NUMBER) RETURN NUMBER;
FUNCTION get_available_prepays(l_vendor_id IN NUMBER) RETURN NUMBER;

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
PROCEDURE get_rule(p_org_id IN NUMBER, p_date IN DATE, p_rule_type IN VARCHAR2, p_rule OUT NOCOPY AP_AUD_RULE_SETS%ROWTYPE);


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
FUNCTION has_default_cc_itemization(p_cc_trx_id IN NUMBER) RETURN VARCHAR2;


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
FUNCTION isAttendeeAvailable(p_reportLineId IN NUMBER) RETURN VARCHAR2;

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
FUNCTION getAttendeeType(p_attendeeCode IN VARCHAR2) RETURN VARCHAR2;

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
PROCEDURE clear_audit_reason_codes(p_report_header_id IN NUMBER);


/*========================================================================
 | PUBLIC PROCEDURE get_dist_project_ccid
 |
 | DESCRIPTION
 |   This function returns a CCID generated by projects accounting from distribution.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   CCID generated by projects accounting
 |
 | PARAMETERS
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 07-Nov-2003           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE get_dist_project_ccid(p_parameter_id             IN NUMBER,
                           p_report_distribution_id         IN NUMBER,
                           p_new_ccid                 OUT NOCOPY NUMBER,
                           p_return_status            OUT NOCOPY VARCHAR2);


/*========================================================================
 | PUBLIC PROCEDURE GetDefaultAcctgSegValues
 |
 | DESCRIPTION
 |   This procedure returns the defaulted CCID and segments based on expense type (parameter_id).
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   CCID generated by projects accounting
 |
 | PARAMETERS
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 14-Aug-2006           Quan Le      Created
 |
 *=======================================================================*/
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
             X_RETURN_STATUS       OUT NOCOPY VARCHAR2);

END AP_WEB_AUDIT_UTILS;

 

/
