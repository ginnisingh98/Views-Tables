--------------------------------------------------------
--  DDL for Package Body AP_WEB_RECEIPT_MANAGEMENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_RECEIPT_MANAGEMENT_UTIL" AS
/* $Header: apwrmutb.pls 120.2.12010000.7 2010/06/17 10:38:52 dsadipir ship $ */

FUNCTION get_line_receipt_status(p_report_header_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_image_receipt_status(p_report_header_id IN NUMBER,
				  p_event            IN VARCHAR2 DEFAULT C_EVENT_NONE) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION get_receipt_status
 |
 | DESCRIPTION
 |   This function returns the receipt status for a expense report. If no
 |   event is passed in as parameter, then the status deducted from the
 |   current status and values on line columns. If an event is passed in
 |   then it is also taken into consideration when deducting the receipt
 |   status.
 |
 |   Note if this logic is called from BC4J, then the changes on the page
 |   need to be posted in order for this function to be able to see them.
 |   To do that, call this function from the OAViewObjectImpl.beforeCommit.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J and workflow logic.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Receipt status as VARCHAR2.
 |
 | PARAMETERS
 |  p_report_header_id IN Expense report identifier
 |  p_event           IN event taken on the report one of the following:
 |                         C_EVENT_WAIVE_RECEIPTS
 |                         C_EVENT_WAIVE_COMPLETE
 |                         C_EVENT_RECEIVE_RECEIPTS
 |                         C_EVENT_RECEIPTS_NOT_RECEIVED
 |                         C_EVENT_RECEIPTS_IN_TRANSIT
 |                         C_EVENT_MR_SHORTPAY
 |                         C_EVENT_PV_SHORTPAY
 |                         C_EVENT_SHORTPAY
 |                         C_EVENT_NONE
 |                         C_EVENT_REJECT
 |                         C_EVENT_REQUEST_INFO
 |                         C_EVENT_RELEASE_HOLD
 |                         C_EVENT_COMPLETE_AUDIT
 |                        The value is defaulted to C_EVENT_NONE
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-Aug-2004           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_receipt_status(p_report_header_id IN NUMBER,
                            p_event           IN VARCHAR2 DEFAULT C_EVENT_NONE) RETURN VARCHAR2 IS

  CURSOR header_cur IS
    select aerh.receipts_status,
           aerh.receipts_received_date,
           aerh2.receipts_status parent_receipts_status
    from AP_EXPENSE_REPORT_HEADERS_ALL aerh,
         AP_EXPENSE_REPORT_HEADERS_ALL aerh2
    where aerh.report_header_id = p_report_header_id
    and   aerh2.report_header_id(+) = aerh.shortpay_parent_id;

  header_rec    header_cur%ROWTYPE;
  l_rm_id       NUMBER;
  l_pv_id       NUMBER;
  l_line_status VARCHAR2(30);
BEGIN
  IF (   p_report_header_id IS NULL
      OR p_event NOT IN ( C_EVENT_WAIVE_RECEIPTS,
                           C_EVENT_WAIVE_COMPLETE,
                           C_EVENT_RECEIVE_RECEIPTS,
                           C_EVENT_RECEIPTS_NOT_RECEIVED,
                           C_EVENT_RECEIPTS_IN_TRANSIT,
                           C_EVENT_MR_SHORTPAY,
			   C_EVENT_MIR_SHORTPAY,
			   C_EVENT_MBR_SHORTPAY,
                           C_EVENT_PV_SHORTPAY,
                           C_EVENT_SHORTPAY,
                           C_EVENT_NONE,
                           C_EVENT_REJECT,
                           C_EVENT_REQUEST_INFO,
                           C_EVENT_RELEASE_HOLD,
                           C_EVENT_COMPLETE_AUDIT)
     ) THEN
   return null;
  END IF;

  OPEN header_cur;
  FETCH  header_cur INTO header_rec;
  IF header_cur%NOTFOUND THEN
    CLOSE header_cur;
    return null;
  END IF;
  CLOSE header_cur;

  IF header_rec.receipts_status = C_STATUS_NOT_REQUIRED THEN
    return C_STATUS_NOT_REQUIRED;
  END IF;

  IF p_event = C_EVENT_RECEIPTS_IN_TRANSIT THEN
    return C_STATUS_IN_TRANSIT;
  ELSIF p_event = C_EVENT_WAIVE_RECEIPTS OR p_event = C_EVENT_WAIVE_COMPLETE THEN
    return C_STATUS_WAIVED;
  ELSIF p_event = C_EVENT_RECEIVE_RECEIPTS THEN
    return C_STATUS_RECEIVED;
  ELSIF p_event = C_EVENT_REJECT THEN
    IF  header_rec.receipts_received_date IS NULL THEN
      return null;
    ELSE
      return header_rec.receipts_status;
    END IF;
  ELSIF p_event in (C_EVENT_REQUEST_INFO, C_EVENT_RELEASE_HOLD, C_EVENT_COMPLETE_AUDIT) THEN
    return header_rec.receipts_status;
  END IF;

  l_line_status := get_line_receipt_status(p_report_header_id);

  IF p_event = C_EVENT_MR_SHORTPAY THEN
    return C_STATUS_RESOLUTN;
  ELSIF p_event = C_EVENT_MIR_SHORTPAY THEN
    return C_STATUS_RESOLUTN;
  ELSIF p_event = C_EVENT_MBR_SHORTPAY THEN
    return C_STATUS_RESOLUTN;
  ELSIF p_event = C_EVENT_PV_SHORTPAY THEN
    IF header_rec.parent_receipts_status = C_STATUS_WAIVED THEN
      return C_STATUS_WAIVED;
    END IF;
  ELSIF p_event = C_EVENT_SHORTPAY THEN
    IF l_line_status = C_STATUS_NOT_REQUIRED THEN
      return C_STATUS_NOT_REQUIRED;
    END IF;
  END IF;

  IF header_rec.receipts_received_date IS NOT NULL THEN
    return C_STATUS_RECEIVED;
  ELSIF header_rec.receipts_status = C_STATUS_WAIVED THEN
    return C_STATUS_WAIVED;
  ELSE
    return l_line_status;
  END IF;

END get_receipt_status;

/*========================================================================
 | PUBLIC FUNCTION get_line_receipt_status
 |
 | DESCRIPTION
 |   This function returns the receipt status for a expense report
 |   deducted from the values on line columns. This does NOT necessarily
 |   represent the correct value for the whole expense report, rather
 |   indicates what the status would be if only lines are evaluated.
 |
 |   Note if this logic is called from BC4J, then the changes on the page
 |   need to be posted in order for this function to be able to see them.
 |   To do that, call this function from the OAViewObjectImpl.beforeCommit.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   PLSQL logic.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Receipt status as VARCHAR2.
 |
 | PARAMETERS
 |  p_report_header_id IN Expense report identifier
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-Aug-2004           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION get_line_receipt_status(p_report_header_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR line_cur IS
    select aerl.receipt_required_flag,
           aerl.receipt_missing_flag
    from AP_EXPENSE_REPORT_LINES_ALL aerl,
         AP_EXPENSE_REPORT_PARAMS_ALL erp
    where aerl.report_header_id = p_report_header_id
    and   erp.parameter_id      = aerl.web_parameter_id
    and   NVL(erp.expense_type_code,'NOT_DEFINED') not in ('PERSONAL','ROUNDING');

  line_rec line_cur%ROWTYPE;

  required_count NUMBER := 0;
  missing_count  NUMBER := 0;

BEGIN

  FOR line_rec IN line_cur LOOP

    IF NVL(line_rec.receipt_required_flag,'N') = 'Y' THEN
      IF NVL(line_rec.receipt_missing_flag,'N') = 'Y' THEN
        missing_count := missing_count + 1;
      ELSE
        required_count := required_count + 1;
      END IF;
    END IF;

  END LOOP;

  IF required_count > 0 THEN
    return C_STATUS_REQUIRED;
  ELSIF missing_count > 0 THEN
    return C_STATUS_MISSING;
  ELSE
    return C_STATUS_NOT_REQUIRED;
  END IF;

END get_line_receipt_status;

/*========================================================================
 | PUBLIC PROCEDURE handle_event
 |
 | DESCRIPTION
 |   This procedure handles a receipt management related event.
 |
 |   Note if this logic is called from BC4J, then the changes on the page
 |   need to be posted in order for this function to be able to see them.
 |   To do that, call this function from the OAViewObjectImpl.beforeCommit.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J and workflow logic.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Receipt status as VARCHAR2.
 |
 | PARAMETERS
 |  p_report_header_id IN Expense report identifier
 |  p_event           IN event taken on the report one of the following:
 |                         C_EVENT_WAIVE_RECEIPTS
 |                         C_EVENT_WAIVE_COMPLETE
 |                         C_EVENT_RECEIVE_RECEIPTS
 |                         C_EVENT_RECEIPTS_NOT_RECEIVED
 |                         C_EVENT_MR_SHORTPAY
 |                         C_EVENT_PV_SHORTPAY
 |                         C_EVENT_SHORTPAY
 |                         C_EVENT_REJECT
 |                         C_EVENT_REQUEST_INFO
 |                         C_EVENT_RELEASE_HOLD
 |                         C_EVENT_COMPLETE_AUDIT
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 16-Aug-2004           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE handle_event(p_report_header_id IN NUMBER,
                       p_event           IN VARCHAR2) IS

  CURSOR header_cur IS
    select aerh.*
    from AP_EXPENSE_REPORT_HEADERS_ALL aerh
    where aerh.report_header_id = p_report_header_id
    FOR UPDATE OF REPORT_HEADER_ID NOWAIT;

  CURSOR split_cc_cur IS
    select aerh.report_header_id
    from AP_EXPENSE_REPORT_HEADERS_ALL aerh
    where aerh.BOTHPAY_PARENT_ID = p_report_header_id
    and holding_report_header_id is not null;

  CURSOR orig_cc_cur(l_report_header_id IN NUMBER) IS
    select aerh.report_header_id
    from AP_EXPENSE_REPORT_HEADERS_ALL aerh
    where aerh.report_header_id = l_report_header_id
    and holding_report_header_id is not null
    and NOT EXISTS (select 1
                    from ap_expense_report_lines_all aerl
                    where aerl.report_header_id = aerh.report_header_id
                    and aerl.credit_card_trx_id IS NULL);

  header_rec          header_cur%ROWTYPE;
  split_cc_rec        split_cc_cur%ROWTYPE;
  l_new_status        VARCHAR2(30);
  l_line_status	      VARCHAR2(30);
BEGIN
  IF (   p_report_header_id IS NULL
      OR p_event IS NULL
      OR p_event NOT IN (C_EVENT_WAIVE_RECEIPTS,
                          C_EVENT_WAIVE_COMPLETE,
                          C_EVENT_RECEIVE_RECEIPTS,
                          C_EVENT_RECEIPTS_NOT_RECEIVED,
                          C_EVENT_MR_SHORTPAY,
			  C_EVENT_MIR_SHORTPAY,
			  C_EVENT_MBR_SHORTPAY,
                          C_EVENT_PV_SHORTPAY,
                          C_EVENT_SHORTPAY,
                          C_EVENT_REJECT,
                          C_EVENT_REQUEST_INFO,
                          C_EVENT_RELEASE_HOLD,
                          C_EVENT_COMPLETE_AUDIT  )
     ) THEN
    return;
  END IF;

  OPEN header_cur;
  FETCH  header_cur INTO header_rec;

  l_new_status :=  get_receipt_status(p_report_header_id, p_event);

  IF (header_rec.report_header_id IS NOT NULL) THEN
    IF (p_event = C_EVENT_MIR_SHORTPAY) THEN
            l_line_status := get_line_receipt_status(p_report_header_id);
	    UPDATE ap_expense_report_headers_all
	    SET image_receipts_status = l_new_status,
	    receipts_status = l_line_status
	    WHERE CURRENT OF header_cur;
    ELSIF (p_event = C_EVENT_MBR_SHORTPAY) THEN
            UPDATE ap_expense_report_headers_all
	    SET image_receipts_status = l_new_status,
	    receipts_status = l_new_status
	    WHERE CURRENT OF header_cur;
    ELSE
            l_line_status := get_image_receipt_status(p_report_header_id, p_event);
	    UPDATE ap_expense_report_headers_all
	    SET receipts_status = l_new_status,
	    image_receipts_status = l_line_status
	    WHERE CURRENT OF header_cur;
    END IF;
  END IF;

  IF    (l_new_status IS NOT NULL AND header_rec.receipts_status IS NOT NULL)
    AND (l_new_status = C_STATUS_NOT_REQUIRED AND header_rec.receipts_status <> C_STATUS_NOT_REQUIRED) THEN
    AP_WEB_RECEIPTS_WF.RaiseAbortedEvent(p_report_header_id);
  END IF;

  IF (p_event = C_EVENT_WAIVE_RECEIPTS OR p_event = C_EVENT_WAIVE_COMPLETE) THEN
    AP_WEB_RECEIPTS_WF.RaiseAbortedEvent(p_report_header_id);
  ELSIF (p_event = C_EVENT_RECEIVE_RECEIPTS) THEN
    AP_WEB_RECEIPTS_WF.RaiseReceivedEvent(p_report_header_id);
  ELSIF (p_event = C_EVENT_RECEIPTS_NOT_RECEIVED) THEN
    -- currently no additional processing for this event
    null;
  ELSIF (p_event = C_EVENT_REJECT) THEN
    /* Aborted event is raised in  Expenses WF SetRejectStatusAndResetAttr(),
     * which is shared by manager rejection. However since the auditor can
     * reject prior to manager approval, raising the event here */
    AP_WEB_RECEIPTS_WF.RaiseAbortedEvent(p_report_header_id);

  ELSIF (p_event = C_EVENT_REQUEST_INFO) THEN
    -- currently no additional processing for this event
    null;
  ELSIF (p_event = C_EVENT_RELEASE_HOLD) THEN
     AP_WEB_HOLDS_WF.ReadyForPayment(p_report_header_id);

     IF header_rec.source = 'Both Pay' THEN
      /* For both pay reports the status is reset on the header only if the original report contains only
       * credit card transaction lines */
       FOR orig_cc_rec IN orig_cc_cur(header_rec.BOTHPAY_PARENT_ID) LOOP
         AP_WEB_HOLDS_WF.ReadyForPayment(orig_cc_rec.report_header_id);
         AP_WEB_HOLDS_WF.RaiseReleasedEvent(orig_cc_rec.report_header_id);
       END LOOP;
     ELSE
       AP_WEB_HOLDS_WF.RaiseReleasedEvent(p_report_header_id);

      /* For reports from which cc transactions were split into separate .1 report, release hold also releases
       * the hold on the split report */
       FOR split_cc_rec IN split_cc_cur LOOP
         AP_WEB_HOLDS_WF.ReadyForPayment(split_cc_rec.report_header_id);
       END LOOP;
     END IF;
  ELSIF (p_event = C_EVENT_SHORTPAY) THEN
    IF l_new_status = C_STATUS_NOT_REQUIRED THEN
      UPDATE AP_EXPENSE_REPORT_HEADERS_ALL
      SET    receipts_received_date = null
      WHERE CURRENT OF header_cur;
    END IF;

  ELSIF (p_event = C_EVENT_MR_SHORTPAY) THEN

    UPDATE AP_EXPENSE_REPORT_HEADERS_ALL
    SET    receipts_received_date = null, report_filing_number = null
    WHERE CURRENT OF header_cur;

  ELSIF (p_event = C_EVENT_MIR_SHORTPAY) THEN

    UPDATE AP_EXPENSE_REPORT_HEADERS_ALL
    SET    image_receipts_received_date = null
    WHERE CURRENT OF header_cur;

  ELSIF (p_event = C_EVENT_MBR_SHORTPAY) THEN

    UPDATE AP_EXPENSE_REPORT_HEADERS_ALL
    SET image_receipts_received_date = null, receipts_received_date = null, report_filing_number = null
    WHERE CURRENT OF header_cur;

  ELSIF (p_event = C_EVENT_PV_SHORTPAY) THEN
    -- currently no additional processing for this event
    null;
  ELSIF (p_event = C_EVENT_COMPLETE_AUDIT) THEN
    IF     header_rec.shortpay_parent_id is not null
       AND header_rec.receipts_status = C_STATUS_RECEIVED
       AND 'Y' = AP_WEB_RECEIPT_MANAGEMENT_UTIL.is_shortpaid_report(p_report_header_id, AP_WEB_RECEIPTS_WF.C_POLICY_VIOLATION_PROCESS) THEN
      AP_WEB_RECEIPTS_WF.RaiseAbortedEvent(p_report_header_id);
    END IF;
  END IF;

  CLOSE header_cur;
END handle_event;

/*========================================================================
 | PUBLIC FUNCTION is_shortpaid_report
 |
 | DESCRIPTION
 |   This function detects whether a report is a shortpaid report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J and workflow logic.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Y or N depending whether the report is shortpaid of the particualr type.
 |
 | PARAMETERS
 |  p_report_header_id IN Expense report identifier
 |  p_shortpay_type    IN type of the shortpay:
 |                         AP_WEB_RECEIPTS_WF.C_NO_RECEIPTS_SHORTPAY_PROCESS
 |                         AP_WEB_RECEIPTS_WF.C_POLICY_VIOLATION_PROCESS
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 31-Dec-2004           J Rautiainen      Created
 |
 *=======================================================================*/
FUNCTION is_shortpaid_report(p_report_header_id IN NUMBER,
                             p_shortpay_type    IN VARCHAR2) RETURN VARCHAR2 IS

  CURSOR wf_cur IS
    select 1
    from   wf_items wf
    where  wf.item_type = 'APEXP'
    and    wf.item_key = to_char(p_report_header_id)    -- Bug 6841589 (sodash) to solve the invalid number exception
    and    wf.end_date is null
    and    wf.root_activity = p_shortpay_type
    and    rownum = 1;

  wf_rec wf_cur%ROWTYPE;
BEGIN
  IF    p_report_header_id IS NULL
     OR p_shortpay_type IS NULL
     OR p_shortpay_type not in (AP_WEB_RECEIPTS_WF.C_NO_RECEIPTS_SHORTPAY_PROCESS,
                                AP_WEB_RECEIPTS_WF.C_POLICY_VIOLATION_PROCESS) THEN
    return 'N';
  END IF;

  OPEN wf_cur;
  FETCH  wf_cur INTO wf_rec;
  IF wf_cur%FOUND THEN
    CLOSE wf_cur;
    return 'Y';
  ELSE
    CLOSE wf_cur;
    return 'N';
  END IF;

END is_shortpaid_report;


FUNCTION get_image_receipt_status(p_report_header_id IN NUMBER,
				  p_event            IN VARCHAR2 DEFAULT C_EVENT_NONE) RETURN VARCHAR2 IS

  l_line_status	      VARCHAR2(30);
  l_header_status     VARCHAR2(30);

BEGIN

  SELECT image_receipts_status INTO l_header_status FROM ap_expense_report_headers_all
  WHERE report_header_id = p_report_header_id;

  IF l_header_status = C_STATUS_NOT_REQUIRED THEN
    return C_STATUS_NOT_REQUIRED;
  END IF;

  l_line_status := AP_WEB_UTILITIES_PKG.GetImageAttachmentStatus(p_report_header_id);

  IF l_line_status = C_STATUS_NOT_REQUIRED THEN
    return C_STATUS_NOT_REQUIRED;
  END IF;

  IF p_event = C_EVENT_RECEIPTS_IN_TRANSIT THEN
    return C_STATUS_IN_TRANSIT;
  ELSIF p_event = C_EVENT_WAIVE_RECEIPTS OR p_event = C_EVENT_WAIVE_COMPLETE THEN
    return C_STATUS_WAIVED;
  ELSIF l_header_status = C_STATUS_MISSING OR l_header_status = C_STATUS_RECEIVED
        OR l_header_status = C_STATUS_WAIVED or l_header_status = C_STATUS_IN_TRANSIT THEN
    return l_header_status;
  ELSE
    return l_line_status;
  END IF;

END get_image_receipt_status;


END AP_WEB_RECEIPT_MANAGEMENT_UTIL;

/
