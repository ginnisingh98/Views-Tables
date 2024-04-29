--------------------------------------------------------
--  DDL for Package AP_WEB_AUDIT_QUEUE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_AUDIT_QUEUE_UTILS" AUTHID CURRENT_USER AS
/* $Header: apwaudqs.pls 120.3.12010000.2 2008/08/06 07:43:46 rveliche ship $ */

/*=======================================================================+
 |  Constants
 +=======================================================================*/
G_OIE_AUD_INVALID_ASSIGNMENT      CONSTANT VARCHAR2(30)    := 'INVALID_ASSIGNMENT';
G_OIE_AUD_SUCCESS      CONSTANT VARCHAR2(30)    := 'SUCCESS';

/*=======================================================================+
 |  Types
 +=======================================================================*/
TYPE GenRefCursor IS REF CURSOR;

/*=======================================================================+
 |  Procedures and Functions
 +=======================================================================*/

/*========================================================================
 | PUBLIC FUNCTION report_weight
 |
 | DESCRIPTION
 |   This function return high threshold for a given low value.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_report_header_id   IN      AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE
 |
 | MODIFICATION HISTORY
 | Date                  Author            		Description of Changes
 | 04-Sep-2002           Mohammad Shoaib Jamall       	Created
 |
 *=======================================================================*/
FUNCTION report_weight(p_report_header_id IN
                       AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE) RETURN NUMBER;

/*========================================================================
 | PUBLIC PROCEDURE assign_to_last_auditor
 |
 | DESCRIPTION
 |   This procedure assigns a returned Report back to the same Auditor
 |   who last Audited the report. Does not consider the Auditor Load
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (workflow/local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_report_header_id   IN      AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE
 |
 | MODIFICATION HISTORY
 | Date                  Author            		Description of Changes
 | 22-Feb-2008           SaiKumar Talasila       	Created
 |
 *=======================================================================*/
PROCEDURE assign_to_last_auditor(p_report_header_id IN
                           AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE);

/*========================================================================
 | PUBLIC PROCEDURE enqueue_for_audit
 |
 | DESCRIPTION
 |   This procedure enqueus a report_header_id for audit
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (workflow/local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_report_header_id   IN      AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE
 |
 | MODIFICATION HISTORY
 | Date                  Author            		Description of Changes
 | 05-Sep-2002           Mohammad Shoaib Jamall       	Created
 |
 *=======================================================================*/
PROCEDURE enqueue_for_audit(p_report_header_id IN
                           AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE);

/*========================================================================
 | PUBLIC PROCEDURE assign_report_to_auditor
 |
 | DESCRIPTION
 |   This procedure enqueus a report_header_id for audit:
 |     - Takes in report_header_id and auditor_id
 |     - If report already in the queue under this auditor do nothing
 |     - If report not in the queue, enqueue it for this auditor if this
 |       auditor is not owner of report.
 |     - If report already in the queue under another auditor transfer
 |       the report under this auditor if auditor is not owner of report.
 |     - p_retcode is returned with:
 |      'INVALID_ASSIGNMENT' -> if the auditor is the owner of report and
 |                              cannot be assigned the report.
 | 	'SUCCESS' -> if everything went ok.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (workflow/local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_report_header_id   IN      AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE
 |   p_auditor_id   IN      AP_AUD_AUDITORS.AUDITOR_ID%TYPE
 |
 | MODIFICATION HISTORY
 | Date                  Author            		Description of Changes
 | 05-Sep-2002           Mohammad Shoaib Jamall       	Created
 |
 *=======================================================================*/
PROCEDURE assign_report_to_auditor(
	p_report_header_id IN  AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE,
	p_auditor_id IN	AP_AUD_AUDITORS.AUDITOR_ID%TYPE,
	p_retcode OUT NOCOPY VARCHAR2);

/*========================================================================
 | PUBLIC PROCEDURE rebalance_queue
 |
 | DESCRIPTION
 |   This procedure enqueus a report_header_id for audit
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (workflow/local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_auditor_id   IN      AP_AUD_AUDITORS.AUDITOR_ID%TYPE
 |
 | MODIFICATION HISTORY
 | Date                  Author            		Description of Changes
 | 05-Sep-2002           Mohammad Shoaib Jamall       	Created
 |
 *=======================================================================*/
PROCEDURE rebalance_queue(p_auditor_id IN
                           AP_AUD_AUDITORS.AUDITOR_ID%TYPE);


/*========================================================================
 | PUBLIC PROCEDURE open_auditors_info_cursor
 |
 | DESCRIPTION
 |   This procedure opens cursor containing auditor info for auditors
 |   who can audit for the org_id. Customers can customize this for
 |   their own business logic.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_org_id   	IN      AP_EXPENSE_REPORT_HEADERS_ALL.ORG_ID%TYPE
 |   p_cust_acct_cur   	IN      GenRefCursor
 |
 | MODIFICATION HISTORY
 | Date                  Author            		Description of Changes
 | 05-Sep-2002           Mohammad Shoaib Jamall       	Created
 |
 *=======================================================================*/
PROCEDURE open_auditors_info_cursor(p_report_header_id IN AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE,
				    p_org_id        IN AP_EXPENSE_REPORT_HEADERS_ALL.ORG_ID%TYPE,
                                    p_auditor_info_cur OUT NOCOPY  GenRefCursor);

/*========================================================================
 | PUBLIC FUNCTION is_function_on_menu
 |
 | DESCRIPTION
 |   Wrapper around FND_FUNCTION.IS_FUNCTION_ON_MENU() which returns 'Y' or
 | 'N' instead of true/false
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_menu_id     - menu to check
 |   p_function_id - function to look for
 |   p_check_grant_flag - if TRUE, then we won't return TRUE unless
 |                        GRANT_FLAG = 'Y'.  Generally pass FALSE
 |                        for Data Security and TRUE for Func Sec.
 |
 | MODIFICATION HISTORY
 | Date                  Author            		Description of Changes
 | 04-Sep-2002           Mohammad Shoaib Jamall       	Created
 |
 *=======================================================================*/
FUNCTION is_function_on_menu(p_menu_id     IN NUMBER,
                             p_function_id IN NUMBER,
                             p_check_grant_flag IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC PROCEDURE report_shortpaid
 |
 | DESCRIPTION
 |   is report shorpaid
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_report_id   IN      AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE
 |
 | MODIFICATION HISTORY
 | Date                  Author            		Description of Changes
 | 05-Sep-2002           Mohammad Shoaib Jamall       	Created
 |
 *=======================================================================*/

FUNCTION report_shortpaid(p_report_id		IN  AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE)
RETURN BOOLEAN;


/*========================================================================
 | PUBLIC PROCEDURE remove_from_queue
 |
 | DESCRIPTION
 |   removes expense report from audit queues if it is in the queue.
 |   if it isn't in the queue then simply return.
 |
 |
 | CALLED FROM PROCEDURES/FUNCTIONS - Concurrent Program
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_report_header_id	- report to remove
 |
 | MODIFICATION HISTORY
 | Date                  Author            		Description of Changes
 | 16-Oct-2002           Mohammad Shoaib Jamall       	Created
 |
 *=======================================================================*/
PROCEDURE remove_from_queue(
	p_report_header_id IN  AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE);

/*========================================================================
 | PUBLIC PROCEDURE auditor_for_report
 |
 | DESCRIPTION
 |   returns auditor_id to which report is assigned as p_auditor_id.
 |   if report is assigned to the fallback auditor returns -1.
 |   if it isn't in the queue then returns null.
 |
 |
 | CALLED FROM PROCEDURES/FUNCTIONS - Concurrent Program
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_report_header_id	- report to remove
 |   p_auditor_id       - auditor id returned
 |
 | MODIFICATION HISTORY
 | Date                  Author            		Description of Changes
 | 16-Oct-2002           Mohammad Shoaib Jamall       	Created
 |
 *=======================================================================*/
PROCEDURE auditor_for_report(
	p_report_header_id IN  AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE,
	p_auditor_id OUT NOCOPY AP_AUD_AUDITORS.AUDITOR_ID%TYPE);

/*========================================================================
 | PUBLIC PROCEDURE reassign_orphaned_reports
 |
 | DESCRIPTION
 |   the security_profile_id assigned to an auditor_id can be changed
 |   OR orgs may be removed from the security_profile_id. In these
 |   cases reports may be assigned to an auditor and whereas she doesn't have
 |   access to the org_id to view the report. This procedure runs in a
 |   concurrent program and reassigns orphaned reports.
 |
 |
 | CALLED FROM PROCEDURES/FUNCTIONS - Concurrent Program
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   errbug        - standard Concurrent Program error output param
 |   retcode       - standard Concurrent Program return code output param
 |
 | MODIFICATION HISTORY
 | Date                  Author            		Description of Changes
 | 10-Oct-2002           Mohammad Shoaib Jamall       	Created
 |
 *=======================================================================*/
PROCEDURE reassign_orphaned_reports(errbuf    OUT NOCOPY VARCHAR2,
                                    retcode   OUT NOCOPY VARCHAR2);


END AP_WEB_AUDIT_QUEUE_UTILS;

/
