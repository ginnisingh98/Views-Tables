--------------------------------------------------------
--  DDL for Package Body AP_WEB_AUDIT_QUEUE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_AUDIT_QUEUE_UTILS" AS
/* $Header: apwaudqb.pls 120.7.12010000.2 2008/08/06 07:42:41 rveliche ship $ */

/*=======================================================================+
 |  Global Constants
 +=======================================================================*/

G_PKG_NAME      CONSTANT VARCHAR2(30)    := 'AP_WEB_AUDIT_QUEUE_UTILS';

------------------------------------------------------------------------
-- Local Procedure Signature
------------------------------------------------------------------------
PROCEDURE open_auditors_cur_w(p_report_header_id IN AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE,
                              p_auditor_info_cur OUT NOCOPY  GenRefCursor);

PROCEDURE open_load_cur(p_auditor_id IN AP_AUD_AUDITORS.AUDITOR_ID%TYPE,
                              p_open_load_cur OUT NOCOPY  GenRefCursor);

PROCEDURE validate_auditors;

PROCEDURE open_orphaned_reports_cursor(p_expense_report_cur OUT NOCOPY  GenRefCursor);

FUNCTION find_enqueue_auditor(p_report_header_id IN  AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE)
  RETURN AP_AUD_AUDITORS.AUDITOR_ID%TYPE;

FUNCTION report_last_audited(p_report_id	IN  AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE)
RETURN BOOLEAN;

FUNCTION auditor_has_access(
  p_auditor_id IN AP_AUD_AUDITORS.AUDITOR_ID%TYPE,
  p_report_header_id IN  AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE)
  RETURN BOOLEAN;

PROCEDURE transfer_report(p_auditor_id 		IN AP_AUD_AUDITORS.AUDITOR_ID%TYPE,
                          p_next_auditor_id 	IN AP_AUD_AUDITORS.AUDITOR_ID%TYPE,
                          p_expense_report_id 	IN AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE);

------------------------------------------------------------------------
-- Procedure Result Codes
------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Registration Status Constants
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Access Domain Type Constants
--------------------------------------------------------------------------

/*========================================================================
 | PUBLIC FUNCTION report_weight
 |
 | DESCRIPTION
 |   This function return high threshold for a given low value. Currently
 | this is simply a function of the number of lines in the report.
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
                       AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE) RETURN NUMBER
IS
  l_report_weight NUMBER := 0;
BEGIN
  SELECT count(1) INTO l_report_weight FROM ap_expense_report_lines_all
  WHERE report_header_id = p_report_header_id
    AND (itemization_parent_id is null OR itemization_parent_id <> -1);

  RETURN(l_report_weight);
END report_weight;

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
	p_retcode OUT NOCOPY VARCHAR2)
IS
  l_auditor_id AP_AUD_AUDITORS.AUDITOR_ID%TYPE;
  l_aud_queue_cur GenRefCursor;
  l_scratch NUMBER := 0;
BEGIN
  AP_WEB_UTILITIES_PKG.LogProcedure(G_PKG_NAME, 'start assign_report_to_auditor');
  IF (p_report_header_id IS NOT NULL) AND (p_auditor_id IS NOT NULL) THEN
    OPEN l_aud_queue_cur FOR
      SELECT auditor_id FROM ap_aud_queues WHERE expense_report_id = p_report_header_id;
    FETCH l_aud_queue_cur INTO l_auditor_id;

-- is p_auditor_id the creator or employee for p_report_header_id; if yes then we should
-- return with INVALID_ASSIGNMENT; else proceed normally.
    SELECT count(1) INTO l_scratch
    FROM fnd_user u,
         ap_expense_report_headers_all exp
    WHERE u.user_id <> -1
    AND   u.user_id = p_auditor_id
-- making sure auditor does not audit expense report owned by her OR filed by her
    AND   exp.report_header_id = p_report_header_id
    AND  (nvl(u.employee_id , -1) = nvl(exp.employee_id , -2) OR nvl(u.user_id , -1) = nvl(exp.created_by , -2));

    IF (l_scratch > 0) THEN
      p_retcode := G_OIE_AUD_INVALID_ASSIGNMENT;
      return;
    END IF;

    IF l_aud_queue_cur%NOTFOUND THEN
-- report not in queue
--------------------------------------------------------------------------
      INSERT INTO ap_aud_queues(expense_report_id,
				auditor_id,
  				report_weight,
  				creation_date,
  				created_by,
  				last_update_login,
  				last_update_date,
  				last_updated_by)
      VALUES (			p_report_header_id,
				p_auditor_id,
  				report_weight(p_report_header_id),
  				sysdate,
  				FND_GLOBAL.USER_ID,
  				null,
  				sysdate,
				FND_GLOBAL.USER_ID);
--------------------------------------------------------------------------
    ELSIF (l_auditor_id <> p_auditor_id) THEN
-- report in queue but needs to be reassigned to p_auditor_id
      transfer_report(l_auditor_id, p_auditor_id, p_report_header_id);
--------------------------------------------------------------------------
--------------------------------------------------------------------------
    END IF;
  END IF;

  p_retcode := G_OIE_AUD_SUCCESS;
  AP_WEB_UTILITIES_PKG.LogProcedure(G_PKG_NAME, 'end assign_report_to_auditor');
END assign_report_to_auditor;

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
                           AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE)
IS
  l_assignee         		NUMBER;
  l_retcode             VARCHAR2(200);
  invalid_assig_to_audit_q EXCEPTION;
BEGIN
  AP_WEB_UTILITIES_PKG.LogProcedure(G_PKG_NAME, 'start assign_to_last_auditor');

  l_assignee := NULL;
  IF report_last_audited(p_report_id => p_report_header_id) THEN
    SELECT h.last_audited_by INTO l_assignee
    FROM AP_EXPENSE_REPORT_HEADERS_ALL h
    WHERE h.report_header_id = p_report_header_id;

    IF( nvl(l_assignee,-1) <> -1 AND
            auditor_has_access(p_auditor_id => l_assignee,
                             p_report_header_id => p_report_header_id) ) THEN
      assign_report_to_auditor(p_report_header_id, l_assignee, l_retcode);
      IF (G_OIE_AUD_INVALID_ASSIGNMENT = l_retcode) THEN
        raise invalid_assig_to_audit_q;
      END IF;
    END IF;
  END IF;

  AP_WEB_UTILITIES_PKG.LogProcedure(G_PKG_NAME, 'end assign_to_last_auditor');

END assign_to_last_auditor;


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
                            AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE)
IS
  l_assignee         		NUMBER;
  l_retcode                    	VARCHAR2(200);
  invalid_assig_to_audit_q EXCEPTION;
BEGIN
  AP_WEB_UTILITIES_PKG.LogProcedure(G_PKG_NAME, 'start enqueue_for_audit');
  l_assignee := find_enqueue_auditor(p_report_header_id);
  assign_report_to_auditor(p_report_header_id, l_assignee, l_retcode);
  IF (G_OIE_AUD_INVALID_ASSIGNMENT = l_retcode) THEN
    raise invalid_assig_to_audit_q;
  END IF;
  AP_WEB_UTILITIES_PKG.LogProcedure(G_PKG_NAME, 'end enqueue_for_audit');

END enqueue_for_audit;

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
                           AP_AUD_AUDITORS.AUDITOR_ID%TYPE)
IS
  l_next_auditor_id AP_AUD_AUDITORS.AUDITOR_ID%TYPE;
  l_expense_report_id NUMBER;
  CURSOR c1 IS SELECT expense_report_id
    FROM ap_aud_queues
    WHERE auditor_id = p_auditor_id order by last_update_date desc;
BEGIN
  AP_WEB_UTILITIES_PKG.LogProcedure(G_PKG_NAME, 'start rebalance_queue');
  FOR rec IN c1 LOOP
    l_expense_report_id := rec.expense_report_id;
    EXIT WHEN l_expense_report_id IS NULL;
    l_next_auditor_id := find_enqueue_auditor(l_expense_report_id);
    -- If the report has not been audited previously, exit when the next
    -- auditor found is the same as the current auditor we are rebalancing for.
    IF NOT report_last_audited(p_report_id => l_expense_report_id) THEN
      EXIT WHEN l_next_auditor_id = p_auditor_id;
    END IF;
    transfer_report(p_auditor_id, l_next_auditor_id, l_expense_report_id);

  END LOOP;
  AP_WEB_UTILITIES_PKG.LogProcedure(G_PKG_NAME, 'end rebalance_queue');
END rebalance_queue;


/*========================================================================
 | PUBLIC PROCEDURE open_load_cur
 |
 | DESCRIPTION
 |   This procedure opens cursor containing the open cursor for the
 |   current entry in ap_aud_workloads for auditor_id. It should
 |   return at most 1 row.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_auditor_id	IN      AP_AUD_AUDITORS.AUDITOR_ID%TYPE
 |   p_open_load_cur   	IN      GenRefCursor
 |
 | MODIFICATION HISTORY
 | Date                  Author            		Description of Changes
 | 05-Sep-2002           Mohammad Shoaib Jamall       	Created
 |
 *=======================================================================*/
PROCEDURE open_load_cur(p_auditor_id IN AP_AUD_AUDITORS.AUDITOR_ID%TYPE,
                        p_open_load_cur OUT NOCOPY  GenRefCursor)
IS

BEGIN
  AP_WEB_UTILITIES_PKG.LogProcedure(G_PKG_NAME, 'start open_load_cur:' || p_auditor_id);
  OPEN p_open_load_cur FOR
    SELECT s.current_total_workload,
           w.workload_percent
    FROM
           ap_aud_auditors a,
           ap_aud_queue_summaries_v s,
           ap_aud_workloads w
    WHERE  a.auditor_id = p_auditor_id
    AND    a.auditor_id = s.auditor_id(+)
    AND    a.auditor_id = w.auditor_id
    AND    w.start_date <= sysdate
    AND    sysdate < nvl(w.end_date,sysdate+1);


END open_load_cur;

/*========================================================================
 | PUBLIC PROCEDURE open_auditors_cur_w
 |
 | DESCRIPTION
 |   This procedure opens cursor containing auditor info for auditors
 |   who can audit for the report header id
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_report_header_id	IN      AP_EXPENSE_REPORT_HEADERS_ALL.ORG_ID%TYPE
 |   p_cust_acct_cur   	IN      GenRefCursor
 |
 | MODIFICATION HISTORY
 | Date                  Author            		Description of Changes
 | 05-Sep-2002           Mohammad Shoaib Jamall       	Created
 |
 *=======================================================================*/
PROCEDURE open_auditors_cur_w(p_report_header_id IN AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE,
                              p_auditor_info_cur OUT NOCOPY  GenRefCursor)
IS
  l_org_id 			AP_EXPENSE_REPORT_HEADERS_ALL.ORG_ID%TYPE;
BEGIN
  SELECT ORG_ID INTO l_org_id FROM ap_expense_report_headers_all
  WHERE report_header_id = p_report_header_id;
  open_auditors_info_cursor(p_report_header_id => p_report_header_id, p_org_id => l_org_id, p_auditor_info_cur => p_auditor_info_cur);
END open_auditors_cur_w;

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
 |   p_report_header_id	IN      AP_EXPENSE_REPORT_HEADERS_ALL.ORG_ID%TYPE
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
                                    p_auditor_info_cur OUT NOCOPY  GenRefCursor)
IS

BEGIN
  AP_WEB_UTILITIES_PKG.LogProcedure(G_PKG_NAME, 'start open_auditors_info_cursor:' || p_report_header_id || ' p_org_id:' || p_org_id);
  OPEN p_auditor_info_cur FOR
    SELECT a.auditor_id
    FROM ap_aud_auditors a,
         per_organization_list per,
         hr_organization_information oi,
         fnd_user u,
         ap_expense_report_headers_all exp
    WHERE a.security_profile_id = per.security_profile_id
    AND   a.auditor_id <> -1
    AND   per.organization_id = oi.organization_id
    AND   oi.org_information_context = 'CLASS'
    AND   oi.org_information1 = 'OPERATING_UNIT'
    AND   oi.organization_id = p_org_id
-- making sure auditor does not audit expense report owned by her
    AND   exp.report_header_id = p_report_header_id
    AND   a.auditor_id = u.user_id
    AND  nvl(u.employee_id , -1) <> nvl(exp.employee_id , -2)
-- making sure auditor does not audit expense report filed by her
    AND  nvl(u.user_id , -1) <> nvl(exp.created_by , -2);

END open_auditors_info_cursor;

/*========================================================================
 | PUBLIC PROCEDURE open_orphaned_reports_cursor
 |
 | DESCRIPTION
 |   This procedure opens cursor containing (expense report ids, auditor ids) in
 |   AP_AUD_QUEUES that have been orphaned. Meaning they belong to an auditor
 |   who is not going to be able to view them because of his security_profile
 |   setting.
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
PROCEDURE open_orphaned_reports_cursor(p_expense_report_cur OUT NOCOPY  GenRefCursor)
IS
BEGIN

  OPEN p_expense_report_cur FOR
    SELECT expense_report_id, auditor_id
    FROM ap_aud_queues WHERE
    expense_report_id NOT IN
    ( SELECT q.expense_report_id
      FROM ap_aud_queues q,
           ap_expense_report_headers_all e,
           ap_aud_auditors a,
           per_organization_list per,
           hr_organization_information oi
      WHERE q.auditor_id = a.auditor_id
      AND   q.expense_report_id = e.report_header_id
      AND   a.security_profile_id = per.security_profile_id
      AND   per.organization_id = oi.organization_id
      AND   oi.org_information_context = 'CLASS'
      AND   oi.org_information1 = 'OPERATING_UNIT'
      AND   e.org_id = oi.organization_id);

END open_orphaned_reports_cursor;

/*========================================================================
 | PUBLIC PROCEDURE find_enqueue_auditor
 |
 | DESCRIPTION
 |   This function finds an auditor to enqueue an expense report
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
 | 05-Sep-2002           Mohammad Shoaib Jamall       	Created
 |
 *=======================================================================*/
FUNCTION find_enqueue_auditor(p_report_header_id IN  AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE)
  RETURN AP_AUD_AUDITORS.AUDITOR_ID%TYPE
IS
-- preseeded auditor with no association with FND_USER
  l_assignee         		NUMBER := -1;
-- an extremely large number
  l_assignee_adjusted_workload 	NUMBER := 10E124;
  l_auditor_info_cur 		GenRefCursor;
  l_open_load_cur 		GenRefCursor;

  l_current_auditor_id          AP_AUD_AUDITORS.AUDITOR_ID%TYPE;
  l_current_workload            NUMBER;
  l_current_adjusted_workload   NUMBER;
  l_current_workload_percent	AP_AUD_WORKLOADS.WORKLOAD_PERCENT%TYPE;
-- temporary scratchpad variable
  l_num           		NUMBER;
  l_parent_auditor_id      	NUMBER;
BEGIN
  AP_WEB_UTILITIES_PKG.LogProcedure(G_PKG_NAME, 'start find_enqueue_auditor');
  l_parent_auditor_id := NULL;

-- if report is shortpaid(or has been last audited) and there is a last auditor -> if last
-- auditor of parent  isn't 0 workload and auditor still has access to the org for this auditor,
-- then assign to that auditor; else assign to fallback auditor
  IF report_last_audited(p_report_id => p_report_header_id) THEN
    SELECT h.last_audited_by INTO l_parent_auditor_id
    FROM AP_EXPENSE_REPORT_HEADERS_ALL h
    WHERE h.report_header_id = p_report_header_id;
    IF l_parent_auditor_id IS NOT NULL THEN
      open_load_cur(p_auditor_id => l_parent_auditor_id,
                    p_open_load_cur => l_open_load_cur);
      FETCH l_open_load_cur INTO l_current_workload, l_current_workload_percent;
      IF (auditor_has_access(p_auditor_id => l_parent_auditor_id,
                             p_report_header_id => p_report_header_id) AND
          l_current_workload_percent > 0) THEN
        l_assignee := l_parent_auditor_id;
      END IF;
      IF (l_assignee <> -1) THEN
        RETURN l_assignee;
      END IF;
    END IF;
  END IF;


  open_auditors_cur_w(	p_report_header_id => p_report_header_id,
			p_auditor_info_cur => l_auditor_info_cur);
  LOOP
    FETCH l_auditor_info_cur INTO l_current_auditor_id;
    EXIT WHEN l_auditor_info_cur%NOTFOUND;

    IF (l_current_auditor_id <> -1) THEN

      open_load_cur(p_auditor_id => l_current_auditor_id,
                    p_open_load_cur => l_open_load_cur);

      FETCH l_open_load_cur INTO l_current_workload, l_current_workload_percent;
      IF l_open_load_cur%FOUND THEN
        EXIT WHEN l_assignee_adjusted_workload = 0;
        IF (l_current_workload_percent IS NOT NULL) AND (l_current_workload_percent <> 0) THEN

          IF (l_current_workload IS NULL) THEN
            l_current_workload := 0;
          ELSE
-- if current auditor is already assigned this report then subtract report weight from l_current_workload
         	  SELECT count(1) INTO l_num FROM ap_aud_queues WHERE expense_report_id = p_report_header_id AND auditor_id = l_current_auditor_id;
            IF (l_num > 0) THEN
              SELECT report_weight INTO l_num FROM ap_aud_queues WHERE expense_report_id = p_report_header_id;
              l_current_workload := l_current_workload - l_num;
            END IF;
          END IF;
          l_current_adjusted_workload := l_current_workload / l_current_workload_percent;
          IF (l_current_adjusted_workload < l_assignee_adjusted_workload) THEN
            l_assignee := l_current_auditor_id;
            l_assignee_adjusted_workload := l_current_adjusted_workload;
          END IF;

        END IF;
      END IF;

    END IF;

  END LOOP;

  AP_WEB_UTILITIES_PKG.LogProcedure(G_PKG_NAME, 'end find_enqueue_auditor');

  RETURN l_assignee;

END find_enqueue_auditor;

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
RETURN BOOLEAN IS
l_shortpay_id		AP_EXPENSE_REPORT_HEADERS_ALL.SHORTPAY_PARENT_ID%TYPE := NULL;
BEGIN
  SELECT shortpay_parent_id
  INTO   l_shortpay_id
  FROM   ap_expense_report_headers_all
  WHERE  report_header_id = p_report_id;
  IF (l_shortpay_id IS NULL) THEN
    return FALSE;
  ELSE
    return TRUE;
  END IF;
END report_shortpaid;

/*========================================================================
 | PUBLIC PROCEDURE report_last_audited
 |
 | DESCRIPTION
 |   has report been last audited by someone
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
FUNCTION report_last_audited(p_report_id		IN  AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE)
RETURN BOOLEAN IS
l_last_audited_by	AP_EXPENSE_REPORT_HEADERS_ALL.LAST_AUDITED_BY%TYPE := NULL;
BEGIN
  SELECT last_audited_by
  INTO   l_last_audited_by
  FROM   ap_expense_report_headers_all
  WHERE  report_header_id = p_report_id;
  IF (l_last_audited_by IS NULL) THEN
    return FALSE;
  ELSE
    return TRUE;
  END IF;
END report_last_audited;

/*========================================================================
 | PUBLIC PROCEDURE auditor_has_access
 |
 | DESCRIPTION
 |   This function finds if an auditor can access a report
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_auditor_id   IN      	  AP_AUD_AUDITORS.AUDITOR_ID%TYPE
 |   p_report_header_id   IN      AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE
 |
 | MODIFICATION HISTORY
 | Date                  Author            		Description of Changes
 | 05-Sep-2002           Mohammad Shoaib Jamall       	Created
 |
 *=======================================================================*/
FUNCTION auditor_has_access(
  p_auditor_id IN AP_AUD_AUDITORS.AUDITOR_ID%TYPE,
  p_report_header_id IN  AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE)
  RETURN BOOLEAN
IS
  l_ret_val 		      	BOOLEAN := FALSE;
  l_auditor_info_cur 		GenRefCursor;
  l_current_auditor_id          AP_AUD_AUDITORS.AUDITOR_ID%TYPE;
BEGIN
  AP_WEB_UTILITIES_PKG.LogProcedure(G_PKG_NAME, 'start auditor_has_access');
  open_auditors_cur_w(	p_report_header_id => p_report_header_id,
			p_auditor_info_cur => l_auditor_info_cur);

  LOOP
    FETCH l_auditor_info_cur INTO l_current_auditor_id;
    EXIT WHEN l_auditor_info_cur%NOTFOUND;
    IF l_current_auditor_id = p_auditor_id THEN
      l_ret_val := TRUE;
      EXIT;
    END IF;
  END LOOP;

  AP_WEB_UTILITIES_PKG.LogProcedure(G_PKG_NAME, 'end auditor_has_access');
  RETURN l_ret_val;

END auditor_has_access;

/*========================================================================
 | PUBLIC PROCEDURE transfer_report
 |
 | DESCRIPTION
 |   This procedure transfers between auditors.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 | p_auditor_id 	IN AP_AUD_AUDITORS.AUDITOR_ID%TYPE,
 | p_next_auditor_id 	IN AP_AUD_AUDITORS.AUDITOR_ID%TYPE,
 | p_expense_report_id 	IN AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE
 |
 | MODIFICATION HISTORY
 | Date                  Author            		Description of Changes
 | 05-Sep-2002           Mohammad Shoaib Jamall       	Created
 |
 *=======================================================================*/
PROCEDURE transfer_report(p_auditor_id 		IN AP_AUD_AUDITORS.AUDITOR_ID%TYPE,
                          p_next_auditor_id 	IN AP_AUD_AUDITORS.AUDITOR_ID%TYPE,
                          p_expense_report_id 	IN AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  AP_WEB_UTILITIES_PKG.LogProcedure(G_PKG_NAME, 'start transfer_report');

  IF (p_auditor_id <> p_next_auditor_id) THEN

    UPDATE ap_aud_queues SET 	auditor_id = p_next_auditor_id,
   				last_update_login = null,
    				last_update_date = sysdate,
    				last_updated_by = FND_GLOBAL.USER_ID
    WHERE auditor_id = p_auditor_id AND expense_report_id = p_expense_report_id;
    COMMIT;

  END IF;

  AP_WEB_UTILITIES_PKG.LogProcedure(G_PKG_NAME, 'start transfer_report');

END transfer_report;

/*========================================================================
 | PUBLIC FUNCTION report_weight
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
                             p_check_grant_flag IN VARCHAR2) RETURN VARCHAR2
IS
  l_ret_val BOOLEAN;
  l_check_grant_flag BOOLEAN;
BEGIN
  IF p_check_grant_flag IS NULL THEN
    l_ret_val := fnd_function.is_function_on_menu(p_menu_id, p_function_id);
  ELSE
    IF p_check_grant_flag = 'Y' THEN
      l_check_grant_flag := true;
    ELSE
      l_check_grant_flag := false;
    END IF;
    l_ret_val := fnd_function.is_function_on_menu(p_menu_id, p_function_id, l_check_grant_flag);
  END IF;
  IF l_ret_val THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;
END is_function_on_menu;

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
	p_report_header_id IN  AP_EXPENSE_REPORT_HEADERS_ALL.REPORT_HEADER_ID%TYPE)
IS
BEGIN
  DELETE FROM ap_aud_queues WHERE expense_report_id = p_report_header_id;
END remove_from_queue;

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
	p_auditor_id OUT NOCOPY AP_AUD_AUDITORS.AUDITOR_ID%TYPE)
IS
BEGIN
  p_auditor_id := null;
  SELECT auditor_id INTO p_auditor_id FROM ap_aud_queues WHERE expense_report_id = p_report_header_id;
EXCEPTION
  WHEN OTHERS THEN
    p_auditor_id := null;
END auditor_for_report;

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
                                    retcode   OUT NOCOPY VARCHAR2)
IS
  l_expense_report_cur 		GenRefCursor;
  l_expense_report_id 		NUMBER;
  l_auditor_id 			AP_AUD_AUDITORS.AUDITOR_ID%TYPE;
  l_next_auditor_id 		AP_AUD_AUDITORS.AUDITOR_ID%TYPE;

  l_sqlerrm		VARCHAR2(2000);
  l_subject		VARCHAR2(200);
BEGIN
  fnd_file.put_line(fnd_file.log, 'starting AP_WEB_AUDIT_QUEUE_UTILS.reassign_orphaned_reports()');

  validate_auditors();

  open_orphaned_reports_cursor(p_expense_report_cur => l_expense_report_cur);
  LOOP
    FETCH l_expense_report_cur INTO l_expense_report_id, l_auditor_id;
    EXIT WHEN l_expense_report_cur%NOTFOUND;

    l_next_auditor_id := find_enqueue_auditor(l_expense_report_id);
    transfer_report(l_auditor_id, l_next_auditor_id, l_expense_report_id);

  END LOOP;
  retcode := 0;    -- SUCCESS
  fnd_file.put_line(fnd_file.log, 'ending AP_WEB_AUDIT_QUEUE_UTILS.reassign_orphaned_reports()');

  EXCEPTION
    WHEN OTHERS THEN
      l_sqlerrm := sqlerrm(sqlcode) || fnd_global.newline ||
                   'Location: AP_WEB_AUDIT_QUEUE_UTILS.reassign_orphaned_reports()'||fnd_global.newline||
                   'Time: '||to_char(sysdate, 'DD-MON-RRRR HH:MI:SS');
      retcode := 2; -- ERROR
      fnd_message.set_name('SQLAP','OIE_AUD_REASSIGN_ORPH_ERROR');
      fnd_message.set_token('REQUEST_ID', fnd_global.conc_request_id);
      l_subject := fnd_message.get;
      fnd_file.put_line(fnd_file.log, 'AP_WEB_AUDIT_QUEUE_UTILS.reassign_orphaned_reports()EXCEPTION:'||l_sqlerrm);

END reassign_orphaned_reports;

PROCEDURE validate_auditors IS
  l_auditor_id AP_AUD_AUDITORS.AUDITOR_ID%TYPE;
  l_security_profile_id AP_AUD_AUDITORS.SECURITY_PROFILE_ID%TYPE;
-- scratch variable
  l_num NUMBER;
  CURSOR c1 IS SELECT auditor_id, security_profile_id
    FROM ap_aud_auditors
    WHERE auditor_id <> -1 AND security_profile_id IS NOT NULL;
BEGIN

  FOR rec IN c1 LOOP
    l_auditor_id := rec.auditor_id;
    l_security_profile_id := rec.security_profile_id;

    SELECT count(1) INTO l_num FROM
    (SELECT
    		u.user_id,
    		FND_PROFILE.VALUE_SPECIFIC('XLA_MO_SECURITY_PROFILE_LEVEL', u.user_id, r.responsibility_id, 200/*SQLAP*/) security_profile_id
    	FROM
    		FND_USER u,
    		FND_USER_RESP_GROUPS g,
    		FND_RESPONSIBILITY r,
    		FND_FORM_FUNCTIONS f
    	WHERE
		u.user_id = l_auditor_id
    		AND u.user_id = g.user_id
    		AND g.responsibility_id = r.responsibility_id
    		AND AP_WEB_AUDIT_QUEUE_UTILS.IS_FUNCTION_ON_MENU(r.menu_id, f.function_id, 'Y') = 'Y'
    		AND f.function_name = 'OIE_AUD_AUDIT') sp
    WHERE sp.security_profile_id = l_security_profile_id;

    IF (l_num = 0) THEN
      UPDATE ap_aud_auditors SET security_profile_id = null WHERE auditor_id = l_auditor_id;
    END IF;

  END LOOP;

END validate_auditors;


END AP_WEB_AUDIT_QUEUE_UTILS;

/
