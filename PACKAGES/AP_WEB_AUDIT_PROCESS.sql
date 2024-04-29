--------------------------------------------------------
--  DDL for Package AP_WEB_AUDIT_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_AUDIT_PROCESS" AUTHID CURRENT_USER AS
/* $Header: apwaudps.pls 120.3 2006/01/10 18:36:06 qle noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

/*========================================================================
 | PUBLIC FUNCTION process_expense_report
 |
 | DESCRIPTION
 |   This function does audit processing for a given expense report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Tag containing auditing information as VARCHAR2.
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION process_expense_report(p_report_header_id IN NUMBER) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC PROCEDURE add_to_audit_list
 |
 | DESCRIPTION
 |   This procedure inserts given employee to audit list.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_employee_id IN  Employee identifier
 |   p_reason_code IN  Reason code
 |   p_duration    IN  Duration
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-Oct-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE add_to_audit_list(p_employee_id  IN NUMBER,
                            p_duration     IN NUMBER,
                            p_reason_code  IN VARCHAR2);

/**
 * jrautiai ADJ Fix Start
 */
/*========================================================================
 | PUBLIC PROCEDURE process_audit_actions
 |
 | DESCRIPTION
 |   This procedure deals with auditor adjustments. This logic is called
 |   when audit is completed and it deals with adjustments in reimbursable
 |   amount and shortpayments.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from expense report form and HTML UI when auditor
 |   completes audit.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None
 |
 | PARAMETERS
 |   p_report_header_id       IN  Expense report to processed
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 15-Jul-2003           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE process_audit_actions(p_report_header_id IN  NUMBER);

/*========================================================================
 | PUBLIC PROCEDURE update_cc_transaction
 |
 | DESCRIPTION
 |   This procedure updates the CC transaction amounts to match the
 |   amounts on the expense line.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   process_audit_actions
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None
 | PARAMETERS
 |   Expense line record containing the data on the modified expense line
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Jul-2003           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE update_cc_transaction(expense_line_rec IN AP_EXPENSE_REPORT_LINES_ALL%ROWTYPE);


/*========================================================================
 | PUBLIC PROCEDURE process_shortpays
 |
 | DESCRIPTION
 |   This procedure processes shortpayments on a line, namely if one of
 |   itemized lines is shortpaid, then all the itemized lines are
 |   shortpaid as well.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   process_audit_actions
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None
 | PARAMETERS
 |   Expense line record containing the data on the modified expense line
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Jul-2003           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE process_shortpays(expense_line_rec IN AP_EXPENSE_REPORT_LINES_ALL%ROWTYPE);


/*========================================================================
 | PUBLIC PROCEDURE process_rate_rounding
 |
 | DESCRIPTION
 |   This procedure calculates and creates any rounding lines needed due
 |   to rounding issues.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   process_audit_actions
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   None
 |
 | PARAMETERS
 |   Expense report header identifier to be processed
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Jul-2003           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE process_rate_rounding(p_report_header_id IN  NUMBER);

/*========================================================================
 | PUBLIC FUNCTION bothpay_personal_cc_only
 |
 | DESCRIPTION
 |   This function checks if the report has only bothpay personal credit card expenses
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 | Called from function process_expense_report(p_report_header_id IN NUMBER
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   TRUE in case the report has only bothpay personal credit card expenses,
 |   otherwise FALSE
 |
 | PARAMETERS
 |   p_report_header_id IN  Expense Report identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Feb-2005           Maulik Vadera     Created
 |
 *=======================================================================*/

FUNCTION bothpay_personal_cc_only(p_report_header_id IN  NUMBER) RETURN BOOLEAN;

/**
 * jrautiai ADJ Fix end
 */
END AP_WEB_AUDIT_PROCESS;

 

/
