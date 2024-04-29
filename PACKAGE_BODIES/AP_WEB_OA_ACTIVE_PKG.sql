--------------------------------------------------------
--  DDL for Package Body AP_WEB_OA_ACTIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_OA_ACTIVE_PKG" AS
/* $Header: apwoaacb.pls 120.17.12010000.3 2009/11/20 09:13:44 dsadipir ship $ */

-- Cache for AP Approver and Expenses Administrator
g_ApApprover    ap_lookup_codes.displayed_field%TYPE := NULL;
g_ExpensesAdmin ap_lookup_codes.displayed_field%TYPE := NULL;

-- Cache for GetReportStatusCode
grsc_old_report_header_id NUMBER := NULL;
grsc_old_status_code ap_lookup_codes.lookup_code%TYPE := NULL;

-- Cache for GetApproverName
gan_old_report_header_id NUMBER := NULL;
gan_old_approver_name  WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE := NULL;
gan_old_attribute_name WF_ITEM_ATTRIBUTE_VALUES.NAME%TYPE := NULL;

-- Global variable for session language code.
g_langCode language_code := NULL;

--
-- GetApproverName
-- Purpose: To get the approver name from the workflow
--
-- Input: p_report_header_id
--        p_attribute_name: to get either approver, preparer, or
--                          employee name
--
-- Output: The approver name for this report with this attribute
--         NULL, if no approver is found.
--

FUNCTION GetApproverName (p_report_header_id IN NUMBER,
                          p_attribute_name IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
  -- Check cache first
  IF p_report_header_id = gan_old_report_header_id
     AND p_attribute_name = gan_old_attribute_name THEN
    RETURN gan_old_approver_name;
  END IF;

  -- update Cache
  gan_old_approver_name :=
    WF_ENGINE.GetItemAttrText(C_APEXP, TO_CHAR(p_report_header_id), p_attribute_name);
  gan_old_report_header_id := p_report_header_id;
  gan_old_attribute_name := p_attribute_name;

  RETURN gan_old_approver_name;
EXCEPTION
  WHEN OTHERS THEN
    -- This attribute was not found, return NULL
    gan_old_report_header_id := p_report_header_id;
    gan_old_attribute_name := p_attribute_name;
    gan_old_approver_name := NULL;
    RETURN NULL;
END GetApproverName;


--
-- GetApApprover
-- Purpose: To get the AP Approver string
--
-- Input: None. Assumes that the AP Approver has been
--        set up properly in AP Lookups
--
-- Output: The AP approver name
--         NULL, if the AP approver was not set up.
--

FUNCTION GetApApprover RETURN VARCHAR2
IS
  v_ApApprover ap_lookup_codes.displayed_field%TYPE := NULL;
  v_langCode language_code;
BEGIN
  v_langCode := userenv('LANG');

  -- Check cache first
  IF g_ApApprover IS NOT NULL AND g_langCode = v_langCode THEN
    RETURN g_ApApprover;
  ELSE
    g_langCode := v_langCode;

    SELECT DISPLAYED_FIELD
    INTO v_ApApprover
    FROM ap_lookup_codes
    WHERE LOOKUP_TYPE = C_EXPENSE_REPORT_APPROVER
    AND   LOOKUP_CODE = C_AP;

    -- Update cache
    g_ApApprover := v_ApApprover;

    RETURN v_ApApprover;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- Update cache. Not using NULL, so that cache will
    -- still be used.
    g_ApApprover := ' ';

    RETURN g_ApApprover;
END GetApApprover;


--
-- GetExpensesAdmin
-- Purpose: To get the Expenses Administrator string
--
-- Input: None. Assumes that the Expenses Admin has been
--        set up properly in AP Lookups
--
-- Output: The Expenses Administrator name
--         NULL, if the Expenses Administrator was not set up.
--

FUNCTION GetExpensesAdmin RETURN VARCHAR2
IS
  v_ExpensesAdmin ap_lookup_codes.displayed_field%TYPE := NULL;
  v_langCode language_code;
BEGIN
  v_langCode := userenv('LANG');

  -- Check cache first
  IF g_ExpensesAdmin IS NOT NULL AND g_langCode = v_langCode THEN
    RETURN g_ExpensesAdmin;
  ELSE
    g_langCode := v_langCode;

    SELECT DISPLAYED_FIELD
    INTO v_ExpensesAdmin
    FROM ap_lookup_codes
    WHERE LOOKUP_TYPE = C_EXPENSE_REPORT_APPROVER
    AND   LOOKUP_CODE = C_EXPADMIN;

    -- Update cache
    g_ExpensesAdmin := v_ExpensesAdmin;

    RETURN v_ExpensesAdmin;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- Update cache. Not using NULL, so that cache will
    -- still be used.
    g_ExpensesAdmin := ' ';

    RETURN g_ExpensesAdmin;
END GetExpensesAdmin;


--
-- GetWFLastNotificationActivity
-- Purpose: To get the activity label of the last notification
--          that was sent for this item
--
-- Input: p_report_header_id. Assumes that only 1 activity has status
--        'NOTIFIED' per process. (It would show COMPLETED otherwise)
--
-- Output: The last notification activity for this report's process
--         NULL, if no oustanding notifications are present for this report
--

FUNCTION GetWFLastNotificationActivity (p_report_header_id IN NUMBER) RETURN VARCHAR2
IS
  v_activity_label wf_item_activity_statuses_v.activity_label%TYPE := NULL;

BEGIN
  -- Find activity with last notification id
  /*Bug 2790208: Added rownum = 1 with an order by clause
		 to avoid any potential JBO error in Track
		 Expense Reports table.Now it ensures a single
		 row to be returned which is the latest notified.
  */
  SELECT INSTANCE_LABEL
  INTO v_activity_label
  FROM (
        SELECT PA.INSTANCE_LABEL
        FROM   WF_ITEM_ACTIVITY_STATUSES IAS,
               WF_PROCESS_ACTIVITIES PA
        WHERE
               IAS.ITEM_TYPE        = C_APEXP
               AND IAS.ACTIVITY_STATUS  = C_NOTIFIED
               AND IAS.ITEM_KEY         = TO_CHAR(p_report_header_id)
               AND IAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
               AND IAS.NOTIFICATION_ID IS NOT NULL
               ORDER BY IAS.BEGIN_DATE desc
        )
   WHERE ROWNUM =1;

  RETURN v_activity_label;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END GetWFLastNotificationActivity;


--
-- GetReportStatusCode
-- Purpose: To return the status code of an expense report
--
-- Input: p_source,
--        p_workflow_approved_flag,
--        p_report_header_id.
--
-- Output: The report status code which also matches with
--         the codes in the lookup type
--         EXPENSE REPORT STATUS.
--

FUNCTION GetReportStatusCode(p_source IN VARCHAR2,
                         p_workflow_approved_flag IN VARCHAR2,
                         p_report_header_id IN NUMBER,
                         p_cache IN VARCHAR2,
                         p_query_wf_activities IN VARCHAR2) RETURN VARCHAR2
IS
  v_status_code ap_lookup_codes.lookup_code%TYPE := NULL;
  v_expense_status_code ap_expense_report_headers_all.expense_status_code%TYPE := NULL;

  --Bug 3612002:Changed datatype of the variable so that length
  --            will become 4000.

  v_approver WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE := NULL;
  v_activity_label wf_item_activity_statuses_v.activity_label%TYPE := NULL;

BEGIN
  -- Check cache
  IF ((p_report_header_id = grsc_old_report_header_id) AND (p_cache = 'Y'))THEN
    RETURN grsc_old_status_code;
  END IF;

  -- Look at the source first

  -- Source = SelfService or CREDIT CARD
  IF p_source IN (C_SelfService, C_CREDIT_CARD, C_BOTH_PAY) THEN
    v_status_code := C_INVOICED;

  -- Source = XpenseXpress
  ELSIF p_source = C_XpenseXpress THEN
    IF p_workflow_approved_flag IN (C_WFAutoApproved, C_WFMgrPayablesApproved) THEN
      v_status_code := C_INVOICED;
    ELSE
      v_status_code := C_PENDMGR;
    END IF;

  -- Source = NonValidatedWebExpense
  ELSIF p_source = C_NonValidatedWebExpense THEN
    IF p_workflow_approved_flag = C_WFSaved THEN
      v_status_code := C_SAVED;
    ELSIF p_workflow_approved_flag = C_WFRejected THEN
      v_status_code := C_REJECTED;
    ELSIF p_workflow_approved_flag = C_WFReturned THEN
      v_status_code := C_RETURNED;
    -- ER 1552747 - withdraw expense report
    ELSIF p_workflow_approved_flag = C_WFWithdrawn THEN
      v_status_code := C_WITHDRAWN;
    ELSIF p_workflow_approved_flag = C_WFInProgress THEN
      v_status_code := C_INPROGRESS;
    ELSE
      v_status_code := C_ERROR;
    END IF;

  -- Source = WebExpense
  ELSIF p_source = C_WebExpense THEN

    -- Bug 3478073
    -- Conditionally query WF activities.

    IF p_query_wf_activities = 'Y' THEN
      -- Check last notification activity
      v_activity_label := GetWFLastNotificationActivity(p_report_header_id);

      IF p_workflow_approved_flag = C_WFManagerApproved THEN
--Bug 2315312:Check for SHORTPAY here as SHORTPAY receipt's
--      workflow_approved_flag is only Management Approval,
--      NOT Payables Approval.
--      Also moved GetWFLastNotificationActivity call to
--      above.

        IF(v_activity_label like '%SHORTPAY%') THEN
	  v_status_code := C_RESOLUTN;
	ELSE
          v_status_code := C_MGRAPPR;
        END IF;
      ELSIF p_workflow_approved_flag = C_WFPayablesApproved THEN
        v_status_code := C_PENDMGR;

      ELSIF p_workflow_approved_flag = 'Q' THEN  --To take care of the scenario where manager approved and auditor rejected  ( Bug 6628290)
        v_status_code := C_RESOLUTN;

      -- workflow approved flag is null or Not Approved
      ELSIF p_workflow_approved_flag IS NULL
        OR  p_workflow_approved_flag = C_WFMgrPayablesApproved
        OR  p_workflow_approved_flag = C_WFNotApproved THEN


        -- Check for third party notification
        IF v_activity_label = C_REQUEST_EMPLOYEE_APPROVAL THEN
          v_status_code := C_EMPAPPR;

        -- Check for no manager response or shortpay
        ELSIF v_activity_label = C_INFORM_PREP_NO_MANAGER_RESP
          OR  v_activity_label = C_INFORM_PREPARER_SHORTPAY
          OR  v_activity_label = C_POLICY_SHORTPAY_NOTICE
          OR  v_activity_label like '%SHORTPAY%' THEN
          v_status_code := C_RESOLUTN;

        -- Check for System administrator action
        ELSIF v_activity_label = C_INFORM_SYSADM_AP_VALID_FAIL
          OR  v_activity_label = C_INFORM_CUSTOM_VALIDATE_ERROR
	  OR  v_activity_label = C_INFORM_NO_APPROVER
          OR  v_activity_label = C_INFORM_SYSADM_NO_APPROVER THEN
          v_status_code := C_ERROR;

        -- Check if the report is ready for invoicing
        ELSIF p_workflow_approved_flag = C_WFMgrPayablesApproved THEN
          v_status_code := C_INVOICED;

        ELSE
          -- check approver name
          v_approver := GetApproverName(p_report_header_id, C_APPROVER_DISPLAY_NAME);
          IF v_approver IS NULL THEN
            -- Bug# 8937372: Report status should be shown correctly when the expense report is having multiple approvers.
	    SELECT expense_status_code INTO v_expense_status_code FROM ap_expense_report_headers_all
	    WHERE report_header_id = p_report_header_id;
	    IF v_expense_status_code = 'PENDMGR' THEN
	      v_status_code := C_PENDMGR;
	    ELSE
	      v_status_code := C_ERROR;
	    END IF;
          ELSE
            v_status_code := C_PENDMGR;
          END IF;
        END IF;
      END IF;
    END IF; -- Query wf activities
  END IF; -- Source

  -- Update cache
  grsc_old_status_code := v_status_code;
  grsc_old_report_header_id := p_report_header_id;

  RETURN v_status_code;
END GetReportStatusCode;


--
-- GetReportStatus
-- Purpose: To return the report status using the
--          the report status code
--
-- Input: p_source,
--        p_workflow_approved_flag,
--        p_report_header_id
--
-- Output: The report status according to EXPENSE REPORT STATUS
--         The report status CODE if the lookup value is not found.
--

FUNCTION GetReportStatus(p_source IN VARCHAR2,
                         p_workflow_approved_flag IN VARCHAR2,
                         p_report_header_id IN NUMBER
) RETURN VARCHAR2
IS
  v_status_code ap_lookup_codes.lookup_code%TYPE := NULL;
  v_status      ap_lookup_codes.displayed_field%TYPE := NULL;

BEGIN
  -- Determine the status code
  v_status_code := GetReportStatusCode(p_source,
                                       p_workflow_approved_flag,
                                       p_report_header_id);

  -- Using status code, retrieve displayed value.
  SELECT DISPLAYED_FIELD
  INTO v_status
  FROM ap_lookup_codes
  WHERE LOOKUP_TYPE = C_EXPENSE_REPORT_STATUS
  AND   LOOKUP_CODE = v_status_code;

  RETURN v_status;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN v_status_code;
END GetReportStatus;


--
-- Purpose: To get the current approver of the given expense report
--
-- Input: p_source,
--        p_workflow_approved_flag,
--        p_report_header_id
--        p_status_code
--
-- Output: The current approver
--

FUNCTION GetCurrentApprover(p_source IN VARCHAR2,
                            p_workflow_approved_flag IN VARCHAR2,
                            p_report_header_id IN NUMBER,
                            p_status_code IN VARCHAR2)
RETURN VARCHAR2
IS
  v_current_approver WF_ITEM_ATTRIBUTE_VALUES.TEXT_VALUE%TYPE := NULL;
  v_status_code ap_lookup_codes.lookup_code%TYPE := NULL;

BEGIN

  -- Use p_status_code if given.
  IF p_status_code IS NOT NULL THEN
    v_status_code := p_status_code;
  ELSE
    -- Otherwise, determine the status code
    -- This is needed for reports submitted before bug fix 2290269
    v_status_code := GetReportStatusCode(p_source,
                                       p_workflow_approved_flag,
                                       p_report_header_id,'Y','N');
  END IF;

  -- Using status code, determine Current Approver

  -- status code = Pending Payables Approval
  IF v_status_code = C_MGRAPPR THEN
    v_current_approver := getApApprover;

  -- status code = Pending Expenses Administrator resolution
  ELSIF v_status_code = C_ERROR THEN
    v_current_approver := getExpensesAdmin;

  -- status code = Pending Manager Approval
  ELSIF v_status_code = C_PENDMGR THEN
    v_current_approver := GetApproverName(p_report_header_id, C_APPROVER_DISPLAY_NAME);

  -- status code = Pending Employee approval
  ELSIF v_status_code = C_EMPAPPR THEN
    v_current_approver := GetApproverName(p_report_header_id, C_EMPLOYEE_DISPLAY_NAME);

  -- status code = Pending Your Resolution
  ELSIF v_status_code = C_RESOLUTN THEN
    v_current_approver := GetApproverName(p_report_header_id, C_PREPARER_DISPLAY_NAME);
  END IF; -- status code

  RETURN v_current_approver;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN v_current_approver;
END GetCurrentApprover;


FUNCTION GetIncludeNotification(p_category  IN VARCHAR2,
                         p_trx_id IN NUMBER)
RETURN VARCHAR2 IS
l_status ap_lookup_codes.lookup_code%TYPE ;
l_source ap_expense_report_headers.source%TYPE;
l_workflow_approved_flag ap_expense_report_headers.workflow_approved_flag%TYPE;
l_report_header_id ap_expense_report_headers.report_header_id%TYPE;

BEGIN

   IF p_category = 'PERSONAL' then

	SELECT erh.report_header_id, source, workflow_approved_flag
	INTO   l_report_header_id , l_source , l_workflow_approved_flaG
	FROM   ap_credit_card_trxns cct, ap_expense_report_headers erh
	WHERE trx_id = p_trx_id
	AND cct.report_header_id = erh.report_header_id;

	l_status := AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(l_source,
							l_workflow_approved_flag,
                                            		l_report_header_id);

	IF l_status not in ('UNUSED','SAVED', 'EMPAPPR', 'REJECTED', 'RESOLUTN','WITHDRAWN',
	                    'RETURNED')  THEN
	  RETURN 'FALSE';
	ELSE
	  RETURN 'TRUE';
	END IF;

    ELSE
	RETURN 'TRUE';
    END IF;

END GetIncludeNotification;

--
-- GetBothPayStatusCode
-- Purpose: To return the both report status code by considering
--          The status of original report and credit card invoice
--
-- Input: p_status_code,
--        p_report_header_id
--        p_amt_due_ccard_company
--        p_amt_due_employee

-- Output: The report status code
--

FUNCTION GetBothPayStatusCode(p_report_header_id IN NUMBER,
                              p_status_code IN VARCHAR2,
			      p_amt_due_ccard_company IN NUMBER,
			      p_amt_due_employee IN NUMBER) RETURN VARCHAR2
IS
  l_cc_report_status_code       VARCHAR2(30);
  l_org_cc_report_status_code   VARCHAR2(30);
  l_final_status_code           VARCHAR2(30);
  l_cc_vouch_no                 NUMBER(15);


BEGIN

   l_final_status_code := p_status_code;

   --Checked if status code is null
   IF l_final_status_code IS NULL THEN

      RETURN l_final_status_code;

   END IF;

    --If there are not any credit card transactions
    IF p_amt_due_ccard_company IS NULL  OR p_amt_due_ccard_company = 0 THEN

	RETURN l_final_status_code;

    END IF;


   --Check if report is split or not, if it is not split it will throw the exception
   SELECT AERH.VOUCHNO, AERH.EXPENSE_STATUS_CODE
   INTO l_cc_vouch_no, l_org_cc_report_status_code
   FROM AP_EXPENSE_REPORT_HEADERS_ALL AERH
   WHERE AERH.BOTHPAY_PARENT_ID=p_report_header_id;


   --Report is split

    --If there are only buisness credit card transactions
    IF p_amt_due_employee IS NULL  OR p_amt_due_employee = 0 THEN


       --Check if report is imported or not
        IF l_cc_vouch_no IS NULL OR l_cc_vouch_no = 0 THEN

	  --Report is not imported
	  RETURN l_org_cc_report_status_code;

        ELSE
	  --Report is imported

	   SELECT DECODE(AI.CANCELLED_DATE,NULL,
		      DECODE(APS.GROSS_AMOUNT ,0,'PAID',
		      DECODE(AI.PAYMENT_STATUS_FLAG,'Y','PAID',
		      'N','INVOICED',
		      'P','PARPAID',NULL)),
			 'CANCELLED')
	   INTO l_final_status_code
	   FROM
		AP_INVOICES_ALL AI,
		AP_EXPENSE_REPORT_HEADERS_ALL AERH,
		AP_PAYMENT_SCHEDULES_ALL APS
	   WHERE   AERH.VOUCHNO = AI.INVOICE_ID
		AND   AERH.BOTHPAY_PARENT_ID = p_report_header_id
		AND AI.INVOICE_TYPE_LOOKUP_CODE = 'MIXED'
		AND AI.INVOICE_ID= APS.INVOICE_ID
		AND AI.VENDOR_ID = AERH.VENDOR_ID;


           RETURN l_final_status_code;

	END IF;


    END IF;

    --There are both credit card exepnses and cash and other expenses

 SELECT DECODE(AI.CANCELLED_DATE,NULL,
	      DECODE(APS.GROSS_AMOUNT ,0,'PAID',
	      DECODE(AI.PAYMENT_STATUS_FLAG,'Y','PAID',
	      'N','INVOICED',
	      'P','PARPAID',NULL)),
		 'CANCELLED')
   INTO l_cc_report_status_code
   FROM
	AP_INVOICES_ALL AI,
	AP_EXPENSE_REPORT_HEADERS_ALL AERH,
	AP_PAYMENT_SCHEDULES_ALL APS
   WHERE   AERH.VOUCHNO = AI.INVOICE_ID
	AND   AERH.BOTHPAY_PARENT_ID = p_report_header_id
	AND AI.INVOICE_TYPE_LOOKUP_CODE = 'MIXED'
	AND AI.INVOICE_ID= APS.INVOICE_ID
	AND AI.VENDOR_ID = AERH.VENDOR_ID;


   IF l_cc_report_status_code IS NOT NULL
      AND p_status_code = 'PAID'
      AND l_cc_report_status_code = 'PAID' THEN

      l_final_status_code := 'PAID';

   ELSIF l_cc_report_status_code IS NOT NULL
         AND ((p_status_code = 'INVOICED' AND l_cc_report_status_code = 'PAID') OR
	      (p_status_code = 'PAID' AND l_cc_report_status_code = 'INVOICED')) THEN

       l_final_status_code := 'PARPAID';

   END IF;

RETURN l_final_status_code;

EXCEPTION
 WHEN OTHERS THEN

 RETURN l_final_status_code;

END GetBothPayStatusCode;

END AP_WEB_OA_ACTIVE_PKG;

/
