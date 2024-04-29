--------------------------------------------------------
--  DDL for Package Body AP_WEB_RECEIPTS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_RECEIPTS_WF" AS
/* $Header: apwrecptb.pls 120.6.12010000.11 2010/06/25 08:19:07 rveliche ship $ */

------------------------
-- Day to minutes conversion 24*60
------------------------
C_DAY_TO_MINUTES	NUMBER := 1440;

------------------------
-- Events
------------------------
-- Event key is used for item key and result code when aborting the track process
-- Event name is the true event name
-- Item/Event key is in the form of: '<Expense Report Id>:<Event key>:<DD-MON-RRRR HH:MI:SS>'
C_OVERDUE_EVENT_KEY	CONSTANT VARCHAR2(30) := 'receipts.overdue';
C_OVERDUE_EVENT_NAME	CONSTANT VARCHAR2(80) := 'oracle.apps.ap.oie.expenseReport.receipts.overdue';
C_MISSING_EVENT_KEY	CONSTANT VARCHAR2(30) := 'receipts.missing';
C_MISSING_EVENT_NAME	CONSTANT VARCHAR2(80) := 'oracle.apps.ap.oie.expenseReport.receipts.missing';
C_RECEIVED_EVENT_KEY	CONSTANT VARCHAR2(30) := 'receipts.received';
C_RECEIVED_EVENT_NAME	CONSTANT VARCHAR2(80) := 'oracle.apps.ap.oie.expenseReport.receipts.received';
C_ABORTED_EVENT_KEY	CONSTANT VARCHAR2(30) := 'receipts.aborted';
C_ABORTED_EVENT_NAME	CONSTANT VARCHAR2(80) := 'oracle.apps.ap.oie.expenseReport.receipts.aborted';

-- Item Key Delimeter
C_ITEM_KEY_DELIM	CONSTANT VARCHAR2(1) := ':';


------------------------------------------------------------------------
FUNCTION ParseItemKey(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2) RETURN VARCHAR2 IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_item_key		wf_items.item_key%TYPE;

BEGIN


  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start ParseItemKey');

  ----------------------------------------------------------
  l_debug_info := 'Parse the item key for the Expense Report Id';
  ----------------------------------------------------------
  return substrb(p_item_key, 1, instrb(p_item_key, C_ITEM_KEY_DELIM)-1);

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end ParseItemKey');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'ParseItemKey',
                     p_item_type, p_item_key, l_debug_info);
    raise;
END ParseItemKey;


------------------------------------------------------------------------
FUNCTION IsNotifRuleSetup(
                                 p_org_id                   IN NUMBER,
                                 p_report_submitted_date    IN DATE) RETURN VARCHAR2 IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_is_notif_rule_setup         varchar2(1);

BEGIN

    ------------------------------------------------------------
    l_debug_info := 'Check if Notif Rules Setup';
    ------------------------------------------------------------
    select 'Y'
    into   l_is_notif_rule_setup
    from   AP_AUD_RULE_SETS rs,
           AP_AUD_RULE_ASSIGNMENTS_ALL rsa
    where  rsa.org_id = p_org_id
    and    rsa.rule_set_id = rs.rule_set_id
    and    rs.rule_set_type = C_NOTIFY_RULE
    and    TRUNC(p_report_submitted_date)
           BETWEEN TRUNC(NVL(rsa.START_DATE, p_report_submitted_date))
           AND     TRUNC(NVL(rsa.END_DATE, p_report_submitted_date))
    and    rownum = 1;

    return 'Y';

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return 'N';
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'IsNotifRuleSetup',
                     to_char(p_org_id), to_char(p_report_submitted_date), l_debug_info);
    raise;
END IsNotifRuleSetup;


------------------------------------------------------------------------
PROCEDURE IsNotifRuleSetup(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_org_id                      number;
  l_expense_report_id           number;
  l_report_submitted_date       AP_EXPENSE_REPORT_HEADERS.report_submitted_date%type;

  l_is_notif_rule_setup		VARCHAR2(1);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start IsNotifRuleSetup');

  IF (p_funmode = 'RUN') THEN

    ----------------------------------------------------------
    l_debug_info := 'Parse the item key for the Expense Report Id';
    ----------------------------------------------------------
    l_expense_report_id := ParseItemKey(p_item_type, p_item_key);

    if (l_expense_report_id is null) then
      Wf_Core.Raise('InvalidExpenseReportId');
    end if;

    ----------------------------------------------------------
    l_debug_info := 'Get the Expense Report Org Id';
    ----------------------------------------------------------
    IF (AP_WEB_DB_EXPRPT_PKG.GetOrgIdByReportHeaderId(l_expense_report_id, l_org_id) <> TRUE) THEN
      l_org_id := NULL;
    END IF;

    ----------------------------------------------------------
    l_debug_info := 'Get Expense Report data';
    ----------------------------------------------------------
    select report_submitted_date
    into   l_report_submitted_date
    from   ap_expense_report_headers_all
    where  report_header_id = l_expense_report_id;

    ------------------------------------------------------------
    l_debug_info := 'Check if Notif Rules Setup';
    ------------------------------------------------------------
    l_is_notif_rule_setup := IsNotifRuleSetup(l_org_id, l_report_submitted_date);

    p_result := 'COMPLETE:'||l_is_notif_rule_setup;

  ELSIF (p_funmode = 'CANCEL') THEN

    p_result := 'COMPLETE';

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end IsNotifRuleSetup');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'IsNotifRuleSetup',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END IsNotifRuleSetup;


------------------------------------------------------------------------
FUNCTION GenerateEventKey(
                                 p_expense_report_id       IN NUMBER,
                                 p_event_key               IN VARCHAR2) RETURN VARCHAR2 IS
------------------------------------------------------------------------

  l_timestamp		varchar2(30);

BEGIN

  select to_char(sysdate, 'DD-MON-RRRR HH:MI:SS')
  into   l_timestamp
  from   dual;

  return p_expense_report_id||C_ITEM_KEY_DELIM||p_event_key||C_ITEM_KEY_DELIM||l_timestamp;

END GenerateEventKey;


------------------------------------------------------------------------
FUNCTION EventKeyExists(
                                 p_event_key               IN VARCHAR2) RETURN BOOLEAN IS
------------------------------------------------------------------------

  l_event_key_exists           varchar2(1) := 'N';

BEGIN

  select 'Y'
  into   l_event_key_exists
  from   wf_items
  where  item_type = C_APWRECPT
  and    item_key = p_event_key
  and    rownum = 1;

  return true;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return false;

END EventKeyExists;


------------------------------------------------------------------------
PROCEDURE RaiseOverdueEvent(
                                 p_expense_report_id    IN NUMBER) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_event_key                   wf_items.item_key%type;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start RaiseOverdueEvent');

  ----------------------------------------------------------
  l_debug_info := 'Generate Event Key';
  ----------------------------------------------------------
  l_event_key := GenerateEventKey(p_expense_report_id, C_OVERDUE_EVENT_KEY);

  ----------------------------------------------------------
  l_debug_info := 'Check Event Key';
  ----------------------------------------------------------
  if (NOT EventKeyExists(l_event_key)) then

    ----------------------------------------------------------
    l_debug_info := 'Raise Overdue Event';
    ----------------------------------------------------------
    wf_event.raise(p_event_name => C_OVERDUE_EVENT_NAME,
                   p_event_key => l_event_key);
                   --p_parameters => l_parameter_list);

  end if;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end RaiseOverdueEvent');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'RaiseOverdueEvent',
                     p_expense_report_id, l_debug_info);
    raise;
END RaiseOverdueEvent;


------------------------------------------------------------------------
PROCEDURE RaiseMissingEvent(
                                 p_expense_report_id    IN NUMBER) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_event_key                   wf_items.item_key%type;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start RaiseMissingEvent');

  ----------------------------------------------------------
  l_debug_info := 'Generate Event Key';
  ----------------------------------------------------------
  l_event_key := GenerateEventKey(p_expense_report_id, C_MISSING_EVENT_KEY);

  ----------------------------------------------------------
  l_debug_info := 'Check Event Key';
  ----------------------------------------------------------
  if (NOT EventKeyExists(l_event_key)) then

    ----------------------------------------------------------
    l_debug_info := 'Raise Missing Event';
    ----------------------------------------------------------
    wf_event.raise(p_event_name => C_MISSING_EVENT_NAME,
                   p_event_key => l_event_key);
                   --p_parameters => l_parameter_list);

  end if;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end RaiseMissingEvent');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'RaiseMissingEvent',
                     p_expense_report_id, l_debug_info);
    raise;
END RaiseMissingEvent;


------------------------------------------------------------------------
PROCEDURE RaiseReceivedEvent(
                                 p_expense_report_id    IN NUMBER) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_event_key                   wf_items.item_key%type;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start RaiseReceivedEvent');

  ----------------------------------------------------------
  l_debug_info := 'Generate Event Key';
  ----------------------------------------------------------
  l_event_key := GenerateEventKey(p_expense_report_id, C_RECEIVED_EVENT_KEY);

  ----------------------------------------------------------
  l_debug_info := 'Check Event Key';
  ----------------------------------------------------------
  if (NOT EventKeyExists(l_event_key)) then

    ----------------------------------------------------------
    l_debug_info := 'Raise Received Event';
    ----------------------------------------------------------
    wf_event.raise(p_event_name => C_RECEIVED_EVENT_NAME,
                   p_event_key => l_event_key);
                   --p_parameters => l_parameter_list);

  end if;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end RaiseReceivedEvent');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'RaiseReceivedEvent',
                     p_expense_report_id, l_debug_info);
    raise;
END RaiseReceivedEvent;


------------------------------------------------------------------------
PROCEDURE RaiseAbortedEvent(
                                 p_expense_report_id    IN NUMBER) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_event_key                   wf_items.item_key%type;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start RaiseAbortedEvent');

  ----------------------------------------------------------
  l_debug_info := 'Generate Event Key';
  ----------------------------------------------------------
  l_event_key := GenerateEventKey(p_expense_report_id, C_ABORTED_EVENT_KEY);

  ----------------------------------------------------------
  l_debug_info := 'Check Event Key';
  ----------------------------------------------------------
  if (NOT EventKeyExists(l_event_key)) then

  ----------------------------------------------------------
  l_debug_info := 'Update Receipts Status if not Received or Waived';
  ----------------------------------------------------------
  begin
    update ap_expense_report_headers_all
    set    receipts_status = ''
    where  report_header_id = p_expense_report_id
    and    nvl(receipts_status, AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED) not in (AP_WEB_RECEIPTS_WF.C_RECEIVED, AP_WEB_RECEIPTS_WF.C_RECEIVED_RESUBMITTED, AP_WEB_RECEIPTS_WF.C_WAIVED, AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED)
    and    receipts_received_date is null;

    update ap_expense_report_headers_all
    set    image_receipts_status = ''
    where  report_header_id = p_expense_report_id
    and    nvl(image_receipts_status, AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED) not in (AP_WEB_RECEIPTS_WF.C_RECEIVED, AP_WEB_RECEIPTS_WF.C_RECEIVED_RESUBMITTED, AP_WEB_RECEIPTS_WF.C_WAIVED, AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED)
    and    image_receipts_received_date is null;
  exception
    when others then null;
  end;

  ----------------------------------------------------------
  l_debug_info := 'Reset Held Reports';
  ----------------------------------------------------------
  -- Bug 4075804
  begin
    update ap_expense_report_headers_all
    set    expense_status_code = C_PENDING_HOLDS,
           holding_report_header_id = null,
           expense_last_status_date = sysdate
    where  holding_report_header_id = p_expense_report_id
    and    expense_status_code = C_PAYMENT_HELD;
  exception
    when others then null;
  end;

  ----------------------------------------------------------
  l_debug_info := 'Raise Aborted Event';
  ----------------------------------------------------------
  wf_event.raise(p_event_name => C_ABORTED_EVENT_NAME,
                 p_event_key => l_event_key);
                 --p_parameters => l_parameter_list);

  end if;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end RaiseAbortedEvent');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'RaiseAbortedEvent',
                     p_expense_report_id, l_debug_info);
    raise;
END RaiseAbortedEvent;


------------------------------------------------------------------------
PROCEDURE RaiseAbortedEvent(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);
  l_receipt_type		VARCHAR2(50);
  l_event_key                   wf_items.item_key%type;
  l_report_header_id		NUMBER;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start RaiseAbortedEvent');

  IF (p_funmode = 'RUN') THEN

  ----------------------------------------------------------
  l_debug_info := 'Raise Aborted event';
  ----------------------------------------------------------
  /*RaiseAbortedEvent(WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                p_item_key,
                                                'EXPENSE_REPORT_ID'));*/
  l_report_header_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                p_item_key,
                                                'EXPENSE_REPORT_ID');

  l_event_key := GenerateEventKey(l_report_header_id, C_ABORTED_EVENT_KEY);

  l_receipt_type := WF_ENGINE.GetActivityAttrText(p_item_type,
                                                   p_item_key,
                                                   p_actid,
                                                   'ABORT_RECEIPT_TYPE');
  IF (NOT EventKeyExists(l_event_key)) THEN
	  IF (l_receipt_type = 'ORIGINAL') THEN
		update ap_expense_report_headers_all
		set    receipts_status = ''
		where  report_header_id = l_report_header_id
		and    nvl(receipts_status, AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED) not in (AP_WEB_RECEIPTS_WF.C_RECEIVED, AP_WEB_RECEIPTS_WF.C_RECEIVED_RESUBMITTED, AP_WEB_RECEIPTS_WF.C_WAIVED)
		and    receipts_received_date is null;
          ELSE
		update ap_expense_report_headers_all
		set    image_receipts_status = ''
		where  report_header_id = l_report_header_id
		and    nvl(image_receipts_status, AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED) not in (AP_WEB_RECEIPTS_WF.C_RECEIVED, AP_WEB_RECEIPTS_WF.C_RECEIVED_RESUBMITTED, AP_WEB_RECEIPTS_WF.C_WAIVED)
		and    image_receipts_received_date is null;
	  END IF;

	  begin
	  update ap_expense_report_headers_all
	  set    expense_status_code = C_PENDING_HOLDS,
	  holding_report_header_id = null,
	  expense_last_status_date = sysdate
	  where  holding_report_header_id = l_report_header_id
	  and    expense_status_code = C_PAYMENT_HELD;
	  exception
	    when others then null;
	  end;

	  wf_event.raise(p_event_name => C_ABORTED_EVENT_NAME,
	  p_event_key => l_event_key);
	  --p_parameters => l_parameter_list);

  END IF;

  p_result := 'COMPLETE';

  END IF; --  p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end RaiseAbortedEvent');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'RaiseAbortedEvent',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END RaiseAbortedEvent;


------------------------------------------------------------------------
PROCEDURE Init(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_textNameArr		Wf_Engine.NameTabTyp;
  l_numNameArr		Wf_Engine.NameTabTyp;
  l_textValArr		Wf_Engine.TextTabTyp;
  l_numValArr		Wf_Engine.NumTabTyp;
  iText NUMBER :=0;
  iNum  NUMBER :=0;

  l_org_id	        	number;
  l_expense_report_id	        number;
  l_created_by                  number;
  l_preparer_id                 number;
  l_preparer_name               wf_users.name%type;
  l_preparer_display_name       wf_users.display_name%type;
  l_employee_id                 number;
  l_employee_name               wf_users.name%type;
  l_employee_display_name       wf_users.display_name%type;
  l_invoice_num			AP_EXPENSE_REPORT_HEADERS.invoice_num%type;
  l_cost_center			AP_EXPENSE_REPORT_HEADERS.flex_concatenated%type;
  l_total			varchar2(80);
  l_purpose			AP_EXPENSE_REPORT_HEADERS.description%type;
  l_report_submitted_date	AP_EXPENSE_REPORT_HEADERS.report_submitted_date%type;

  l_notif_rule			AP_AUD_RULE_SETS%ROWTYPE;
  l_is_notif_rule_setup		varchar2(1) := 'N';

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start Init');

  ----------------------------------------------------------
  l_debug_info := 'Parse the item key for the Expense Report Id';
  ----------------------------------------------------------
  l_expense_report_id := ParseItemKey(p_item_type, p_item_key);

  if (l_expense_report_id is null) then
    Wf_Core.Raise('InvalidExpenseReportId');
  end if;

  ----------------------------------------------------------
  l_debug_info := 'Get the Expense Report Org Id';
  ----------------------------------------------------------
  IF (AP_WEB_DB_EXPRPT_PKG.GetOrgIdByReportHeaderId(l_expense_report_id, l_org_id) <> TRUE) THEN
    l_org_id := NULL;
  END IF;


  ----------------------------------------------------------
  l_debug_info := 'Get Expense Report data';
  -- Note: was thinking of getting data from APEXP WF but we cannot
  --       assume that Expenses WF still exists (may be purged)
  ----------------------------------------------------------
  select created_by,
         employee_id,
         invoice_num,
         flex_concatenated,
         to_char(nvl(AMT_DUE_CCARD_COMPANY,0)+nvl(AMT_DUE_EMPLOYEE,0),
                         FND_CURRENCY.Get_Format_Mask(default_currency_code,22))||' '||default_currency_code,
         description,
         report_submitted_date
  into   l_created_by,
         l_employee_id,
         l_invoice_num,
         l_cost_center,
         l_total,
         l_purpose,
         l_report_submitted_date
  from   ap_expense_report_headers_all
  where  report_header_id = l_expense_report_id;

  ----------------------------------------------------------
  l_debug_info := 'Get Preparer Id using Created By';
  ----------------------------------------------------------
  if (AP_WEB_DB_HR_INT_PKG.GetEmpIdForUser(l_created_by, l_preparer_id)) then
    null;
  end if;

  ------------------------------------------------------------
  l_debug_info := 'Get Name Info Associated With Preparer Id';
  ------------------------------------------------------------
  WF_DIRECTORY.GetUserName('PER',
                           l_preparer_id,
                           l_preparer_name,
                           l_preparer_display_name);

  if (l_preparer_name is null) then
    Wf_Core.Raise('InvalidOwner');
  end if;

  ----------------------------------------------------------
  l_debug_info := 'Set the Preparer as the Owner of Receipts Mgmt Workflow Process.';
  ----------------------------------------------------------
  WF_ENGINE.SetItemOwner(p_item_type, p_item_key, l_preparer_name);

  ----------------------------------------------------------
  l_debug_info := 'Set Item User Key to Invoice Number for easier query ';
  ----------------------------------------------------------
  WF_ENGINE.SetItemUserKey(p_item_type,
                           p_item_key,
                           l_invoice_num);

  --------------------------------------------------------
  l_debug_info := 'Set EXPENSE_REPORT Item Attribute';
  --------------------------------------------------------
  iText := iText + 1;
  l_textNameArr(iText) := 'EXPENSE_REPORT';
  l_textValArr(iText) := l_invoice_num;

  ------------------------------------------------------------
  l_debug_info := 'Get Name Info Associated With Employee_Id';
  ------------------------------------------------------------
  WF_DIRECTORY.GetUserName('PER',
                           l_employee_id,
                           l_employee_name,
                           l_employee_display_name);

  ----------------------------------------------------------
  l_debug_info := 'Set ORG_ID Item Attribute';
  ----------------------------------------------------------
  iNum := iNum + 1;
  l_numNameArr(iNum) := 'ORG_ID';
  l_numValArr(iNum) := l_org_id;

  ----------------------------------------------------------
  l_debug_info := 'Set EXPENSE_REPORT_ID Item Attribute';
  ----------------------------------------------------------
  iNum := iNum + 1;
  l_numNameArr(iNum) := 'EXPENSE_REPORT_ID';
  l_numValArr(iNum) := l_expense_report_id;

  ----------------------------------------------------------
  l_debug_info := 'Set EXPENSE_REPORT_FOR Item Attribute';
  ----------------------------------------------------------
  iText := iText + 1;
  l_textNameArr(iText) := 'EXPENSE_REPORT_FOR';
  l_textValArr(iText) := l_employee_display_name;

  ----------------------------------------------------------
  l_debug_info := 'Set EXPENSE_REPORT_COST_CENTER Item Attribute';
  ----------------------------------------------------------
  iText := iText + 1;
  l_textNameArr(iText) := 'EXPENSE_REPORT_COST_CENTER';
  l_textValArr(iText) := l_cost_center;

  ----------------------------------------------------------
  l_debug_info := 'Set EXPENSE_REPORT_TOTAL Item Attribute';
  ----------------------------------------------------------
  iText := iText + 1;
  l_textNameArr(iText) := 'EXPENSE_REPORT_TOTAL';
  l_textValArr(iText) := l_total;

  ----------------------------------------------------------
  l_debug_info := 'Set EXPENSE_REPORT_PURPOSE Item Attribute';
  ----------------------------------------------------------
  iText := iText + 1;
  l_textNameArr(iText) := 'EXPENSE_REPORT_PURPOSE';
  l_textValArr(iText) := l_purpose;

  ----------------------------------------------------------
  l_debug_info := 'Set EXPENSE_REPORT_SUBMIT_DATE Item Attribute';
  ----------------------------------------------------------
  WF_ENGINE.SetItemAttrDate(p_item_type, p_item_key, 'EXPENSE_REPORT_SUBMIT_DATE', l_report_submitted_date);

  ----------------------------------------------------------
  l_debug_info := 'Check Notification Rule';
  ----------------------------------------------------------
  l_is_notif_rule_setup := IsNotifRuleSetup(l_org_id, l_report_submitted_date);

  if (l_is_notif_rule_setup = 'Y') then

    ----------------------------------------------------------
    l_debug_info := 'Get the Notification Rule';
    ----------------------------------------------------------
    AP_WEB_AUDIT_UTILS.get_rule(l_org_id, l_report_submitted_date, C_NOTIFY_RULE, l_notif_rule);

    ----------------------------------------------------------
    l_debug_info := 'Set NOTIF_RULE_DAYS_OVERDUE Item Attribute';
    ----------------------------------------------------------
    /*
      NOTIF_RULE_DAYS_OVERDUE is the rule for determining
      what's considered overdue
      process date - report submission date
    */
    iNum := iNum + 1;
    l_numNameArr(iNum) := 'NOTIF_RULE_DAYS_OVERDUE';
    l_numValArr(iNum) := l_notif_rule.NOTIFY_RCT_OVERDUE_DAYS; -- relative time in days
    --l_numValArr(iNum) := 60; -- relative time in days

    iNum := iNum + 1;
    l_numNameArr(iNum) := 'NOTIF_IMAGE_DAYS_OVERDUE';
    l_numValArr(iNum) := l_notif_rule.NOTIFY_IMG_RCT_OVERDUE_DAYS; -- relative time in days

    ----------------------------------------------------------
    l_debug_info := 'Set NOTIF_RULE_TIMEOUT Item Attribute';
    ----------------------------------------------------------
    /*
      NOTIF_RULE_TIMEOUT is the rule for determining
      how long to wait for a response from the preparer
    */
    iNum := iNum + 1;
    l_numNameArr(iNum) := 'NOTIF_RULE_TIMEOUT';
    l_numValArr(iNum) := l_notif_rule.NOTIFY_ACTION_REQUIRED_DAYS * C_DAY_TO_MINUTES; -- relative time in minutes
    --l_numValArr(iNum) := 1440; -- relative time in minutes

    iNum := iNum + 1;
    l_numNameArr(iNum) := 'NOTIF_IMAGE_TIMEOUT';
    l_numValArr(iNum) := l_notif_rule.NOTIFY_IMG_ACTION_REQ_DAYS * C_DAY_TO_MINUTES; -- relative time in minutes

    ----------------------------------------------------------
    l_debug_info := 'Set NOTIF_RULE_WAIT Item Attribute';
    ----------------------------------------------------------
    /*
      NOTIF_RULE_WAIT is the rule for determining
      how long to wait after a response from the preparer
    */
    iNum := iNum + 1;
    l_numNameArr(iNum) := 'NOTIF_RULE_WAIT';
    l_numValArr(iNum) := l_notif_rule.NOTIFY_RESPONSE_OVERDUE_DAYS; -- relative time in days
    --l_numValArr(iNum) := 0; -- relative time in days

    iNum := iNum + 1;
    l_numNameArr(iNum) := 'NOTIF_IMAGE_WAIT';
    l_numValArr(iNum) := l_notif_rule.NOTIFY_IMG_RESP_OVERDUE_DAYS; -- relative time in days

    ----------------------------------------------------------
    l_debug_info := 'Set NOTIF_RULE_MISSING_DECL_REQD Item Attribute';
    ----------------------------------------------------------
    /*
      NOTIF_RULE_MISSING_DECL_REQD is the rule for determining
      whether a missing receipt declaration is required or not
    */
    iText := iText + 1;
    l_textNameArr(iText) := 'NOTIF_RULE_MISSING_DECL_REQD';
    l_textValArr(iText) := l_notif_rule.NOTIFY_DOCUMENT_REQUIRED_CODE;
    --l_textValArr(iText) := C_REQUIRED;

    ----------------------------------------------------------
    l_debug_info := 'Set NOTIF_RULE_NOTIF_RECEIVED Item Attribute';
    ----------------------------------------------------------
    /*
      NOTIF_RULE_NOTIF_RECEIVED is the rule for determining
      whether to notify the preparer when the receipts pkg is received
    */
    iText := iText + 1;
    l_textNameArr(iText) := 'NOTIF_RULE_NOTIF_RECEIVED';
    l_textValArr(iText) := l_notif_rule.NOTIFY_RCT_RECEIVED_CODE;
    --l_textValArr(iText) := C_RECEIPTS_RECEIVED;

  end if; -- (l_is_notif_rule_setup = 'Y')

  ----------------------------------------------------------
  l_debug_info := 'Set PREPARER_ROLE Item Attribute';
  ----------------------------------------------------------
  iText := iText + 1;
  l_textNameArr(iText) := 'PREPARER_ROLE';
  l_textValArr(iText) := l_preparer_name;


  -----------------------------------------------------
  l_debug_info := 'Set all number item attributes';
  -----------------------------------------------------
  WF_ENGINE.SetItemAttrNumberArray(p_item_type, p_item_key, l_numNameArr, l_numValArr);

  -----------------------------------------------------
  l_debug_info := 'Set all text item attributes';
  -----------------------------------------------------
  WF_ENGINE.SetItemAttrTextArray(p_item_type, p_item_key, l_textNameArr, l_textValArr);


  if (l_is_notif_rule_setup = 'Y') then

    ----------------------------------------------------------
    l_debug_info := 'Set DAYS_OVERDUE Item Attribute';
    ----------------------------------------------------------
    /*
      DAYS_OVERDUE is the diff between notif sent date and date the
      the expense report receipts package became overdue
      notif sent date - (report submission date + NOTIF_RULE_DAYS_OVERDUE)
    iNum := iNum + 1;
    l_numNameArr(iNum) := 'DAYS_OVERDUE';
    l_numValArr(iNum) := 60; -- relative time in days
    */
    SetDaysOverdue(p_item_type, p_item_key);
    SetImageOverdueDays(p_item_type, p_item_key);

  end if; -- (l_is_notif_rule_setup = 'Y')


  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end Init');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'Init',
                     p_item_type, p_item_key, l_expense_report_id, l_preparer_name, l_debug_info);
    raise;
END Init;


------------------------------------------------------------------------
PROCEDURE InitOverdue(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start InitOverdue');

  IF (p_funmode = 'RUN') THEN

  ----------------------------------------------------------
  l_debug_info := 'Initialize common event data';
  ----------------------------------------------------------
  Init(p_item_type, p_item_key);

  p_result := 'COMPLETE';

  END IF; --  p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end InitOverdue');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'InitOverdue',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END InitOverdue;


------------------------------------------------------------------------
PROCEDURE InitMissing(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start InitMissing');

  IF (p_funmode = 'RUN') THEN

  ----------------------------------------------------------
  l_debug_info := 'Initialize common event data';
  ----------------------------------------------------------
  Init(p_item_type, p_item_key);

  p_result := 'COMPLETE';

  END IF; --  p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end InitMissing');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'InitMissing',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END InitMissing;


------------------------------------------------------------------------
PROCEDURE CheckOverdueExists(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_status		wf_item_activity_statuses.ACTIVITY_STATUS%TYPE;
  l_result		wf_item_activity_statuses.ACTIVITY_RESULT_CODE%TYPE;

  l_item_key		wf_items.item_key%TYPE;
  l_found_item_key	wf_items.item_key%TYPE;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start CheckOverdueExists');

  IF (p_funmode = 'RUN') THEN

    begin

      ----------------------------------------------------------
      l_debug_info := 'Getting item key of current process';
      ----------------------------------------------------------
      l_item_key := ParseItemKey(p_item_type, p_item_key);

      ----------------------------------------------------------
      l_debug_info := 'Encode item key for Overdue process';
      ----------------------------------------------------------
      l_item_key := l_item_key||C_ITEM_KEY_DELIM||C_OVERDUE_EVENT_KEY||'%';

      ----------------------------------------------------------
      l_debug_info := 'Check for at least one Overdue process';
      ----------------------------------------------------------
      select item_key
      into   l_found_item_key
      from   wf_items
      where  item_type = p_item_type
      and    item_key like l_item_key
      and    end_date is null
      and    rownum = 1;

      p_result := 'COMPLETE:Y';

      exception
        when no_data_found then
          p_result := 'COMPLETE:N';
        when others then
          p_result := 'COMPLETE:N';

    end;

  ELSIF (p_funmode = 'CANCEL') THEN
    p_result := 'COMPLETE';
  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end CheckOverdueExists');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'CheckOverdueExists',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END CheckOverdueExists;


------------------------------------------------------------------------
PROCEDURE CheckMissingExists(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_status		wf_item_activity_statuses.ACTIVITY_STATUS%TYPE;
  l_result		wf_item_activity_statuses.ACTIVITY_RESULT_CODE%TYPE;

  l_item_key		wf_items.item_key%TYPE;
  l_found_item_key	wf_items.item_key%TYPE;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start CheckMissingExists');

  IF (p_funmode = 'RUN') THEN

    begin

      ----------------------------------------------------------
      l_debug_info := 'Getting item key of current process';
      ----------------------------------------------------------
      l_item_key := ParseItemKey(p_item_type, p_item_key);

      ----------------------------------------------------------
      l_debug_info := 'Encode item key for Missing process';
      ----------------------------------------------------------
      l_item_key := l_item_key||C_ITEM_KEY_DELIM||C_MISSING_EVENT_KEY||'%';

      ----------------------------------------------------------
      l_debug_info := 'Check for at least one Missing process';
      ----------------------------------------------------------
      select item_key
      into   l_found_item_key
      from   wf_items
      where  item_type = p_item_type
      and    item_key like l_item_key
      and    end_date is null
      and    rownum = 1;

      p_result := 'COMPLETE:Y';

      exception
        when no_data_found then
          p_result := 'COMPLETE:N';
        when others then
          p_result := 'COMPLETE:N';

    end;

  ELSIF (p_funmode = 'CANCEL') THEN
    p_result := 'COMPLETE';
  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end CheckMissingExists');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'CheckMissingExists',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END CheckMissingExists;


------------------------------------------------------------------------
PROCEDURE AbortOverdue(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start AbortOverdue');

  IF (p_funmode = 'RUN') THEN

    AbortProcess(p_item_type, p_item_key, C_OVERDUE_EVENT_KEY);

  p_result := 'COMPLETE';

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end AbortOverdue');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'AbortOverdue',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END AbortOverdue;


------------------------------------------------------------------------
PROCEDURE AbortMissing(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_item_key		wf_items.item_key%type;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start AbortMissing');

  IF (p_funmode = 'RUN') THEN

    AbortProcess(p_item_type, p_item_key, C_MISSING_EVENT_KEY);

  p_result := 'COMPLETE';

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end AbortMissing');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'AbortMissing',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END AbortMissing;


------------------------------------------------------------------------
PROCEDURE AbortProcess(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_event_key    IN VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_item_key		wf_items.item_key%type;
  l_found_item_key	wf_items.item_key%type;

  l_status		wf_item_activity_statuses.ACTIVITY_STATUS%TYPE;
  l_result		wf_item_activity_statuses.ACTIVITY_RESULT_CODE%TYPE;

-- cursor for receipt events
CURSOR c_receipt_events is
  select item_key
  from   wf_items
  where  item_type = p_item_type
  and    item_key like l_item_key
  and    end_date is null;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start AbortProcess');

    ----------------------------------------------------------
    l_debug_info := 'Getting item key of current process';
    ----------------------------------------------------------
    l_item_key := ParseItemKey(p_item_type, p_item_key);

    ----------------------------------------------------------
    l_debug_info := 'Encode item key for event process';
    ----------------------------------------------------------
    l_item_key := l_item_key||C_ITEM_KEY_DELIM||p_event_key||'%';

    open c_receipt_events;
    loop

      fetch c_receipt_events into l_found_item_key;
      exit when c_receipt_events%NOTFOUND;

      ----------------------------------------------------------
      l_debug_info := 'Abort event process and use the item key as the result';
      ----------------------------------------------------------
      begin

        WF_ENGINE.AbortProcess(p_item_type,
                               l_found_item_key,
                               null,
                               wf_engine.eng_force);

      exception
        when others then null;
      end;

    end loop;
    close c_receipt_events;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end AbortProcess');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'AbortProcess',
                     p_item_type, p_item_key, p_event_key, l_debug_info);
    raise;
END AbortProcess;


------------------------------------------------------------------------
PROCEDURE InitReceived(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start InitReceived');

  IF (p_funmode = 'RUN') THEN

  ----------------------------------------------------------
  l_debug_info := 'Initialize common event data';
  ----------------------------------------------------------
  Init(p_item_type, p_item_key);

  p_result := 'COMPLETE';

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end InitReceived');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'InitReceived',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END InitReceived;


------------------------------------------------------------------------
PROCEDURE InitAborted(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start InitAborted');

  IF (p_funmode = 'RUN') THEN

  ----------------------------------------------------------
  l_debug_info := 'Initialize common event data';
  ----------------------------------------------------------
  Init(p_item_type, p_item_key);

  p_result := 'COMPLETE';

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end InitAborted');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'InitAborted',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END InitAborted;

------------------------------------------------------------------------
FUNCTION GetReceiptsStatus(
                                 p_report_header_id    IN NUMBER) RETURN VARCHAR2 IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_receipts_status		varchar2(30);

BEGIN

    ------------------------------------------------------------
    l_debug_info := 'Retrieve current Receipt Status';
    ------------------------------------------------------------
    select receipts_status
    into   l_receipts_status
    from   ap_expense_report_headers_all
    where  report_header_id = p_report_header_id;

    return l_receipts_status;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return null;
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'GetReceiptsStatus',
                     to_char(p_report_header_id), l_debug_info);
    raise;
END GetReceiptsStatus;


------------------------------------------------------------------------
PROCEDURE GetReceiptsStatus(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_receipts_status		varchar2(30);
  l_report_header_id            number;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start GetReceiptsStatus');

  IF (p_funmode = 'RUN') THEN

    ------------------------------------------------------------
    l_debug_info := 'Retrieve Expense_Report_ID Item Attribute';
    ------------------------------------------------------------
    l_report_header_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                      p_item_key,
                                                      'EXPENSE_REPORT_ID');

    ------------------------------------------------------------
    l_debug_info := 'Retrieve current Receipt Status';
    ------------------------------------------------------------
    l_receipts_status := GetReceiptsStatus(l_report_header_id);

  p_result := 'COMPLETE:'||l_receipts_status;

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end GetReceiptsStatus');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'GetReceiptsStatus',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END GetReceiptsStatus;


------------------------------------------------------------------------
PROCEDURE SetReceiptsStatus(
                                 p_report_header_id    IN NUMBER,
                                 p_receipts_status     IN VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_orig_receipts_status	varchar2(30);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start SetReceiptsStatus');

    ------------------------------------------------------------
    l_debug_info := 'Lock current Receipt Status';
    ------------------------------------------------------------
    select receipts_status
    into   l_orig_receipts_status
    from   ap_expense_report_headers_all
    where  report_header_id = p_report_header_id
    for update of receipts_status nowait;

    ------------------------------------------------------------
    l_debug_info := 'Update current Receipt Status';
    ------------------------------------------------------------
    update ap_expense_report_headers_all
    set    receipts_status = p_receipts_status
    where  report_header_id = p_report_header_id;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end SetReceiptsStatus');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'SetReceiptsStatus',
                     to_char(p_report_header_id), p_receipts_status, l_debug_info);
    raise;
END SetReceiptsStatus;


------------------------------------------------------------------------
PROCEDURE SetReceiptsStatus(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_orig_receipts_status	varchar2(30);
  l_receipts_status		varchar2(30);
  l_report_header_id            number;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start SetReceiptsStatus');

  IF (p_funmode = 'RUN') THEN

    -------------------------------------------------------------------
    l_debug_info := 'Retrieve Activity Attr Receipts Status';
    -------------------------------------------------------------------
    l_receipts_status := WF_ENGINE.GetActivityAttrText(p_item_type,
                                                   p_item_key,
                                                   p_actid,
                                                   'RECEIPTS_STATUS');

    ------------------------------------------------------------
    l_debug_info := 'Retrieve Expense_Report_ID Item Attribute';
    ------------------------------------------------------------
    l_report_header_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                      p_item_key,
                                                      'EXPENSE_REPORT_ID');

    ------------------------------------------------------------
    l_debug_info := 'Update current Receipt Status';
    ------------------------------------------------------------
    SetReceiptsStatus(l_report_header_id, l_receipts_status);

  p_result := 'COMPLETE';

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end SetReceiptsStatus');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'SetReceiptsStatus',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END SetReceiptsStatus;


------------------------------------------------------------------------
PROCEDURE SetDaysOverdue(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_days_overdue number;
  l_report_submitted_date date;
  l_notif_rule_days_overdue number;
  l_receipts_status             varchar2(30);
  l_report_header_id            number;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start SetDaysOverdue');

    /*
      DAYS_OVERDUE is the diff between notif sent date and date the
      the expense report receipts package became overdue
      notif sent date - (report submission date + NOTIF_RULE_DAYS_OVERDUE)
    */
    l_report_submitted_date := WF_ENGINE.GetItemAttrDate(p_item_type,
                                                         p_item_key,
                                                         'EXPENSE_REPORT_SUBMIT_DATE');

    l_notif_rule_days_overdue := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                             p_item_key,
                                                             'NOTIF_RULE_DAYS_OVERDUE');

    l_days_overdue := trunc(sysdate) - (trunc(l_report_submitted_date) + l_notif_rule_days_overdue);

    ----------------------------------------------------------
    l_debug_info := 'Set DAYS_OVERDUE Item Attribute';
    ----------------------------------------------------------
    WF_ENGINE.SetItemAttrNumber(p_item_type, p_item_key, 'DAYS_OVERDUE', l_days_overdue);

    ------------------------------------------------------------
    l_debug_info := 'Retrieve Expense_Report_ID Item Attribute';
    ------------------------------------------------------------
    l_report_header_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                      p_item_key,
                                                      'EXPENSE_REPORT_ID');

    ------------------------------------------------------------
    l_debug_info := 'Retrieve current Receipt Status';
    ------------------------------------------------------------
    l_receipts_status := GetReceiptsStatus(l_report_header_id);

    if (l_receipts_status = C_IN_TRANSIT) then
      ------------------------------------------------------------
      l_debug_info := 'Update current Receipt Status to Overdue if In Transit';
      ------------------------------------------------------------
      SetReceiptsStatus(l_report_header_id, C_OVERDUE);
    end if;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end SetDaysOverdue');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'SetDaysOverdue',
                     p_item_type, p_item_key, l_debug_info);
    raise;
END SetDaysOverdue;



------------------------------------------------------------------------
PROCEDURE SetDaysOverdue(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_days_overdue number;
  l_report_submitted_date date;
  l_notif_rule_days_overdue number;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start SetDaysOverdue');

  IF (p_funmode = 'RUN') THEN

    SetDaysOverdue(p_item_type, p_item_key);

  p_result := 'COMPLETE';

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end SetDaysOverdue');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'SetDaysOverdue',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END SetDaysOverdue;


------------------------------------------------------------------------
PROCEDURE CheckMissingDeclRequired(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_missing_decl_reqd	fnd_lookups.lookup_code%TYPE;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start CheckMissingDeclRequired');

  IF (p_funmode = 'RUN') THEN

  ----------------------------------------------------------
  l_debug_info := 'Check if Missing Declaration is required';
  ----------------------------------------------------------
  l_missing_decl_reqd := WF_ENGINE.GetItemAttrText(p_item_type,
                                               p_item_key,
                                               'NOTIF_RULE_MISSING_DECL_REQD');

  if (nvl(l_missing_decl_reqd, C_NOT_REQUIRED) = C_REQUIRED) then
    p_result := 'COMPLETE:Y';
  else
    p_result := 'COMPLETE:N';
  end if;

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end CheckMissingDeclRequired');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'CheckMissingDeclRequired',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END CheckMissingDeclRequired;



------------------------------------------------------------------------
PROCEDURE CheckNotifyReceived(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_notif_received	fnd_lookups.lookup_code%TYPE;
  l_days_overdue	number := 0;
  l_report_header_id	number;
  l_receipts_status	varchar2(30);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start CheckNotifyReceived');

  IF (p_funmode = 'RUN') THEN

  l_report_header_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                      p_item_key,
                                                      'EXPENSE_REPORT_ID');

    ------------------------------------------------------------
    l_debug_info := 'Retrieve current Receipt Status';
    ------------------------------------------------------------
    l_receipts_status := GetReceiptsStatus(l_report_header_id);

  ----------------------------------------------------------
  l_debug_info := 'Check if Notify Receipts Received is enabled';
  ----------------------------------------------------------
  l_notif_received := WF_ENGINE.GetItemAttrText(p_item_type,
                                               p_item_key,
                                               'NOTIF_RULE_NOTIF_RECEIVED');

  ----------------------------------------------------------
  l_debug_info := 'Check if Days Overdue';
  ----------------------------------------------------------
  l_days_overdue := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                p_item_key,
                                                'DAYS_OVERDUE');


  if ((l_receipts_status = C_RECEIVED) AND ((nvl(l_notif_received, C_NEVER) = C_RECEIPTS_RECEIVED) or
      (nvl(l_notif_received, C_NEVER) = C_RECEIPTS_OVERDUE and nvl(l_days_overdue, 0) > 0))) then
    p_result := 'COMPLETE:Y';
  else
    p_result := 'COMPLETE:N';
  end if;

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end CheckNotifyReceived');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'CheckNotifyReceived',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END CheckNotifyReceived;


------------------------------------------------------------------------
PROCEDURE IsReceivedWaived(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_receipts_status             varchar2(30);
  l_report_header_id            number;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start IsReceivedWaived');

  IF (p_funmode = 'RUN') THEN

    ------------------------------------------------------------
    l_debug_info := 'Retrieve Expense_Report_ID Item Attribute';
    ------------------------------------------------------------
    l_report_header_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                      p_item_key,
                                                      'EXPENSE_REPORT_ID');

    ------------------------------------------------------------
    l_debug_info := 'Retrieve current Receipt Status';
    ------------------------------------------------------------
    l_receipts_status := GetReceiptsStatus(l_report_header_id);

    if (l_receipts_status in (C_RECEIVED, C_RECEIVED_RESUBMITTED, C_WAIVED)) then
      p_result := 'COMPLETE:Y';
    else
      p_result := 'COMPLETE:N';
    end if;

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end IsReceivedWaived');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'IsReceivedWaived',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END IsReceivedWaived;


------------------------------------------------------------------------
FUNCTION IsShortpay(
                                 p_item_type         IN VARCHAR2,
                                 p_item_key          IN VARCHAR2,
                                 p_shortpay_type     IN VARCHAR2) RETURN VARCHAR2 IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_report_header_id            number;
  l_is_shortpay                 varchar2(1) := 'N';

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start IsShortpay');

    ------------------------------------------------------------
    l_debug_info := 'Retrieve Expense_Report_ID Item Attribute';
    ------------------------------------------------------------
    l_report_header_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                      p_item_key,
                                                      'EXPENSE_REPORT_ID');

    ------------------------------------------------------------
    l_debug_info := 'Check if Missing or Policy Shortpay';
    ------------------------------------------------------------
    select 'Y'
    into   l_is_shortpay
    from   ap_expense_report_headers_all aerh,
           wf_items wf
    where  aerh.report_header_id = l_report_header_id
    and    aerh.shortpay_parent_id is not null
    and    wf.item_type = C_APEXP
    and    wf.item_key = to_char(aerh.report_header_id)     -- Bug 6841589 (sodash) to solve the invalid number exception
    and    wf.end_date is null
    and    wf.root_activity = p_shortpay_type
    and    rownum = 1;

    return l_is_shortpay;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end IsShortpay');

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return 'N';
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'IsShortpay',
                     p_item_type, p_item_key, l_debug_info);
    raise;
END IsShortpay;


------------------------------------------------------------------------
PROCEDURE IsMissingShortpay(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_is_shortpay			VARCHAR2(1) := 'N';

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start IsMissingShortpay');

  IF (p_funmode = 'RUN') THEN

    ------------------------------------------------------------
    l_debug_info := 'Check if Missing Receipts Shortpay';
    ------------------------------------------------------------
    l_is_shortpay := IsShortpay(p_item_type,
                                p_item_key,
                                C_NO_RECEIPTS_SHORTPAY_PROCESS);

    p_result := 'COMPLETE:'||l_is_shortpay;

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end IsMissingShortpay');

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_result := 'COMPLETE:N';
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'IsMissingShortpay',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END IsMissingShortpay;


------------------------------------------------------------------------
PROCEDURE IsPolicyShortpay(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_is_shortpay                 VARCHAR2(1) := 'N';

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start IsPolicyShortpay');

  IF (p_funmode = 'RUN') THEN

    ------------------------------------------------------------
    l_debug_info := 'Check if Policy Violation Shortpay';
    ------------------------------------------------------------
    l_is_shortpay := IsShortpay(p_item_type,
                                p_item_key,
                                C_POLICY_VIOLATION_PROCESS);

    p_result := 'COMPLETE:'||l_is_shortpay;

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end IsPolicyShortpay');

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_result := 'COMPLETE:N';
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'IsPolicyShortpay',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END IsPolicyShortpay;


------------------------------------------------------------------------
PROCEDURE CompleteShortpay(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_activity     IN VARCHAR2,
                                 p_result       IN VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_report_header_id		number;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start CompleteShortpay');

    ------------------------------------------------------------
    l_debug_info := 'Retrieve Expense_Report_ID Item Attribute';
    ------------------------------------------------------------
    l_report_header_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                      p_item_key,
                                                      'EXPENSE_REPORT_ID');

    ----------------------------------------------------------
    l_debug_info := 'Complete Missing or Policy Shortpay Process';
    ----------------------------------------------------------
    begin

      WF_ENGINE.CompleteActivityInternalName(C_APEXP,
                                             l_report_header_id,
                                             p_activity,
                                             p_result);

    exception
      when others then null;
    end;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end CompleteShortpay');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'CompleteShortpay',
                     p_item_type, p_item_key, p_activity, p_result, l_debug_info);
    raise;
END CompleteShortpay;


------------------------------------------------------------------------
PROCEDURE CompleteMissingShortpay(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start CompleteMissingShortpay');

  IF (p_funmode = 'RUN') THEN

    ----------------------------------------------------------
    l_debug_info := 'Complete Missing Shortpay Process';
    ----------------------------------------------------------
    begin

      CompleteShortpay(p_item_type,
                       p_item_key,
                       C_INFORM_PREPARER_SHORTPAY,
                       C_AP_WILL_SUBMIT);

    exception
      when others then null;
    end;

  end if;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end CompleteMissingShortpay');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'CompleteMissingShortpay',
                     p_item_type, p_item_key, to_char(p_actid), p_result, l_debug_info);
    raise;
END CompleteMissingShortpay;


------------------------------------------------------------------------
PROCEDURE CompletePolicyShortpay(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start CompletePolicyShortpay');

  IF (p_funmode = 'RUN') THEN

    ----------------------------------------------------------
    l_debug_info := 'Complete Policy Shortpay Process';
    ----------------------------------------------------------
    begin

      CompleteShortpay(p_item_type,
                       p_item_key,
                       C_POLICY_SHORTPAY_NOTICE,
                       C_AP_PROVIDE_MISSING_INFO);

    exception
      when others then null;
    end;

  end if;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end CompletePolicyShortpay');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'CompletePolicyShortpay',
                     p_item_type, p_item_key, to_char(p_actid), p_result, l_debug_info);
    raise;
END CompletePolicyShortpay;


/*
Written by:
  Ron Langi
Purpose:
  This stores a Preparer-Auditor note based on the Preparer
  action/response from a notification activity.

  The following is gathered from the WF:
  - RESULT_TYPE contains the lookup type for the result of the Notification.
  - RESULT_CODE contains the lookup code for the result of the Notification.
  - RESPONSE contains the respond attr for the Notification.
  - FND_MESSAGE contains the specific FND message to store

  The Preparer-Auditor note is stored in the form of:
  <Preparer Action>: <Preparer Response>
*/
----------------------------------------------------------------------
PROCEDURE StoreNote(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
----------------------------------------------------------------------
  l_report_header_id            number;
  l_debug_info                  VARCHAR2(200);

  l_fnd_message fnd_new_messages.message_name%type;
  l_note_text varchar2(2000);
  l_days_overdue number;

  l_message_name fnd_new_messages.message_name%type;
  l_result_type Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_result_code Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_response Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_type_display_name varchar2(240);
  l_code_display_name varchar2(240);
  l_note_prefix varchar2(2000);

  l_orig_language_code ap_expense_params.note_language_code%type := null;
  l_orig_language fnd_languages.nls_language%type := null;
  l_new_language_code ap_expense_params.note_language_code%type := null;
  l_new_language fnd_languages.nls_language%type := null;

  l_created_by                  number;
  l_preparer_id                 number;

  l_org_id                        ap_expense_params_all.org_id%type;
BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start StoreNote');

  IF (p_funmode = 'RUN') THEN

    -------------------------------------------------------------------
    l_debug_info := 'Need to generate Note based on language setup';
    -------------------------------------------------------------------

    -------------------------------------------------------------------
    l_debug_info := 'Save original language';
    -------------------------------------------------------------------
    l_orig_language_code := userenv('LANG');
    select nls_language
    into   l_orig_language
    from   fnd_languages
    where  language_code = l_orig_language_code;

    -------------------------------------------------------------------
    l_debug_info := 'Check AP_EXPENSE_PARAMS.NOTE_LANGUAGE_CODE';
    -------------------------------------------------------------------
    l_org_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                           p_item_key,
                                           'ORG_ID');
    begin
      select note_language_code
      into   l_new_language_code
      from   ap_expense_params_all
      where org_id = l_org_id;

      exception
        when no_data_found then
          null;
    end;

    -------------------------------------------------------------------
    l_debug_info := 'Else use instance base language';
    -------------------------------------------------------------------
    if (l_new_language_code is null) then
      select language_code
      into   l_new_language_code
      from   fnd_languages
      where  installed_flag in ('B');
    end if;

    -------------------------------------------------------------------
    l_debug_info := 'Set nls context to new language';
    -------------------------------------------------------------------
    select nls_language
    into   l_new_language
    from   fnd_languages
    where  language_code = l_new_language_code;

    fnd_global.set_nls_context(p_nls_language => l_new_language);

    ------------------------------------------------------------
    l_debug_info := 'Retrieve Expense_Report_ID Item Attribute';
    ------------------------------------------------------------
    l_report_header_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                      p_item_key,
                                                      'EXPENSE_REPORT_ID');

    -------------------------------------------------------------------
    l_debug_info := 'Retrieve Activity Attr Result Type';
    -------------------------------------------------------------------
    l_result_type := WF_ENGINE.GetActivityAttrText(p_item_type,
                                                   p_item_key,
                                                   p_actid,
                                                   'RESULT_TYPE');
    -- bug 6361555
    begin
      select created_by
      into   l_created_by
      from   ap_expense_report_headers_all
      where  report_header_id = l_report_header_id;
    exception
      when others then
        null;
    end;

    ----------------------------------------------------------
    l_debug_info := 'Get Preparer Id using Created By';
    ----------------------------------------------------------
    if (AP_WEB_DB_HR_INT_PKG.GetEmpIdForUser(l_created_by, l_preparer_id)) then
      null;
    end if;

    if (l_result_type is not null) then

      -------------------------------------------------------------------
      l_debug_info := 'Retrieve Note prefix';
      -------------------------------------------------------------------
      l_message_name := 'OIE_NOTES_PREPARER_RESPONSE';

      begin
        -------------------------------------------------------------------
        -- fnd_global.set_nls_context() seems to work for WF but not FND_MESSAGES
        -------------------------------------------------------------------
        select message_text
        into   l_note_prefix
        from   fnd_new_messages
        where  application_id = 200
        and    message_name = l_message_name
        and    language_code = l_new_language_code;

        exception
          when no_data_found then
            FND_MESSAGE.SET_NAME('SQLAP', l_message_name);
            l_note_prefix := FND_MESSAGE.GET;
      end;

      -------------------------------------------------------------------
      l_debug_info := 'Retrieve Activity Attr Result Code';
      -------------------------------------------------------------------
      l_result_code := WF_ENGINE.GetActivityAttrText(p_item_type,
                                                     p_item_key,
                                                     p_actid,
                                                     'RESULT_CODE');

      -------------------------------------------------------------------
      l_debug_info := 'Retrieve Activity Attr Response';
      -------------------------------------------------------------------
      l_response := WF_ENGINE.GetActivityAttrText(p_item_type,
                                                     p_item_key,
                                                     p_actid,
                                                     'RESPONSE');

      ------------------------------------------------------------
      l_debug_info := 'Retrieve lookup display name';
      ------------------------------------------------------------
      WF_LOOKUP_TYPES_PUB.fetch_lookup_display(l_result_type,
                                               l_result_code,
                                               l_type_display_name,
                                               l_code_display_name);

      ------------------------------------------------------------
      l_debug_info := 'store the result and response as a note';
      ------------------------------------------------------------
      AP_WEB_NOTES_PKG.CreateERPrepToAudNote (
        p_report_header_id       => l_report_header_id,
        p_note                   => l_note_prefix||' '||l_code_display_name||'
  '||l_response,
        p_lang                   => l_new_language_code,
	p_entered_by             => nvl(l_preparer_id,fnd_global.user_id)           -- bug 6361555
      );

        ----------------------------------------------------------
        l_debug_info := 'clear Item Attribute PREPARER_RESPONSE';
        -- this assumes preparer response, if we need to change this
        -- later then change Activity Attr RESPONSE to pass item attr
        ---------------------------------------------------------
        WF_ENGINE.SetItemAttrText(p_item_type,
                                  p_item_key,
                                  'PREPARER_RESPONSE',
                                  '');

    else

      -------------------------------------------------------------------
      l_debug_info := 'Retrieve Activity Attr FND Message';
      -------------------------------------------------------------------
      l_fnd_message := WF_ENGINE.GetActivityAttrText(p_item_type,
                                                     p_item_key,
                                                     p_actid,
                                                     'FND_MESSAGE');

      if (l_fnd_message in ('APWRECPT_OVERDUE_SENT','APWRECPT_MISSING_SENT')) then

        l_days_overdue := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                      p_item_key,
                                                      'DAYS_OVERDUE');

        FND_MESSAGE.SET_NAME('SQLAP', l_fnd_message);
        FND_MESSAGE.SET_TOKEN('DAYS_OVERDUE', to_char(l_days_overdue));
        l_note_text := FND_MESSAGE.GET;

        ------------------------------------------------------------
        l_debug_info := 'store the fnd message as a note';
        ------------------------------------------------------------
        AP_WEB_NOTES_PKG.CreateERPrepToAudNote (
          p_report_header_id       => l_report_header_id,
          p_note                   => l_note_text,
          p_lang                   => l_new_language_code
        );

      end if; -- l_fnd_message is not null

    end if; -- l_result_type is not null

    -------------------------------------------------------------------
    l_debug_info := 'Restore nls context to original language';
    -------------------------------------------------------------------
    fnd_global.set_nls_context(p_nls_language => l_orig_language);

    p_result := 'COMPLETE:Y';

  END IF;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end StoreNote');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'StoreNote',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END StoreNote;


----------------------------------------------------------------------
PROCEDURE CallbackFunction(     p_item_type      IN VARCHAR2,
                                p_item_key       IN VARCHAR2,
                                p_actid          IN NUMBER,
                                p_funmode        IN VARCHAR2,
                                p_result         OUT NOCOPY VARCHAR2) IS
----------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_org_id		number;
  l_expense_report_id	number;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start CallbackFunction');

    l_org_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                            p_item_key,
                                            'ORG_ID');

    if (l_org_id is null) then
      -- EXPENSE_REPORT_ID item attribute should exist
      l_expense_report_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                         p_item_key,
                                                         'EXPENSE_REPORT_ID');

      IF (AP_WEB_DB_EXPRPT_PKG.GetOrgIdByReportHeaderId(l_expense_report_id, l_org_id) <> TRUE) THEN
        l_org_id := NULL;
      END IF;

      WF_ENGINE.SetItemAttrNumber(p_item_type,
                                  p_item_key,
                                  'ORG_ID',
                                  l_org_id);
    end if;

  /*
  if ( p_funmode = 'RUN' ) then
    --<your RUN executable statements>

    p_result := 'TRUE';

    return;
  end if;
  */

  if ( p_funmode = 'SET_CTX' ) then
    --<your executable statements for establishing context information>

    if (l_org_id is not null) then
      mo_global.set_policy_context(p_access_mode => 'S',
                                   p_org_id      => l_org_id);
    end if;

    p_result := 'TRUE';

    return;
  end if;

  if ( p_funmode = 'TEST_CTX' and l_org_id is not null) then
    --<your executable statements for testing the validity of the current context information>

    IF ((nvl(mo_global.get_access_mode, 'NULL') <> 'S') OR
        (nvl(mo_global.get_current_org_id, -99) <> nvl(l_org_id, -99)) ) THEN
       p_result := 'FALSE';
    ELSE
       p_result := 'TRUE';
    END IF;

    return;
  end if;

  /*
  if ( p_funmode = '<other command>' ) then
    p_result := ' ';

    return;
  end if;
  */

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end CallbackFunction');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'CallbackFunction',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END CallbackFunction;


/*
  Written by:
    Ron Langi

  Purpose:
    Tracks Overdue Receipt Packages

  Input:
    p_org_id - Org Id (optional)

  Output:
    errbuf - contains error message; required by Concurrent Manager
    retcode - contains return code; required by Concurrent Manager

  Input/Output:

  Assumption:

*/
----------------------------------------------------------------------
PROCEDURE TrackOverdue(
                                errbuf out nocopy varchar2,
                                retcode out nocopy number,
                                p_org_id in number) IS
----------------------------------------------------------------------

  l_debug_info                  VARCHAR2(200);

  l_report_header_id		ap_expense_report_headers.report_header_id%TYPE;
  l_receipts_status		ap_expense_report_headers.receipts_status%TYPE;
  l_orig_receipts_status	ap_expense_report_headers.receipts_status%TYPE;

  l_employee_id			ap_expense_report_headers.employee_id%TYPE;
  l_business_group_id		hr_organization_units.business_group_id%TYPE;
  l_duration			AP_AUD_RULE_SETS.audit_term_duration_days%TYPE;
  l_emp_rec			AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type;
  l_audit_rec			AP_WEB_AUDIT_LIST_PUB.Audit_Rec_Type;
  l_auto_audit_id		NUMBER;
  l_x_return_status		VARCHAR2(1);
  l_x_msg_count			NUMBER;
  l_x_msg_data			VARCHAR2(2000);
  l_event_raised		VARCHAR2(1) := 'N';
  l_receipt_type		VARCHAR2(10);
  l_image_receipt_status	ap_expense_report_headers.receipts_status%TYPE;



/*
  Criteria for this cursor is:
  - receipts status is REQUIRED or MISSING
  - original reports (excludes bothpay child reports)
  - reports that have effective notification rules
  - no Overdue/Missing Receipts WF exists
  - REQUIRED receipts are overdue
    or
    MISSING receipts are overdue and phys doc is reqd
*/
-- cursor for overdue required/missing receipts
CURSOR c_overdue_receipts IS
select aerh.report_header_id,
         aerh.receipts_status,
	 aerh.image_receipts_status
  from   AP_EXPENSE_REPORT_HEADERS aerh,
         AP_AUD_RULE_SETS rs,
         AP_AUD_RULE_ASSIGNMENTS rsa
  where  (aerh.receipts_status in (C_REQUIRED, C_MISSING)
          OR decode(aerh.image_receipts_status, 'PENDING_IMAGE_SUBMISSION', C_REQUIRED, aerh.image_receipts_status) in (C_REQUIRED, C_MISSING))
  and    aerh.bothpay_parent_id is null
  and    rsa.org_id = nvl(p_org_id, rsa.org_id)
  and    rsa.org_id = aerh.org_id
  and    rsa.rule_set_id = rs.rule_set_id
  and    rs.rule_set_type = C_NOTIFY_RULE
  and    TRUNC(aerh.report_submitted_date)
         BETWEEN TRUNC(NVL(rsa.START_DATE, aerh.report_submitted_date))
         AND     TRUNC(NVL(rsa.END_DATE, aerh.report_submitted_date))
  and
  (
  (aerh.RECEIPTS_STATUS = C_REQUIRED and trunc(sysdate) - (trunc(aerh.report_submitted_date) + rs.NOTIFY_RCT_OVERDUE_DAYS) > 0)
  or
  (aerh.RECEIPTS_STATUS = C_MISSING and trunc(sysdate) - (trunc(aerh.report_submitted_date) + rs.NOTIFY_RCT_OVERDUE_DAYS) > 0)
  or
  (decode(aerh.IMAGE_RECEIPTS_STATUS, 'PENDING_IMAGE_SUBMISSION', C_REQUIRED, aerh.IMAGE_RECEIPTS_STATUS) = C_REQUIRED
                          and trunc(sysdate) - (trunc(aerh.report_submitted_date) + rs.NOTIFY_IMG_RCT_OVERDUE_DAYS) > 0)
  or
  (aerh.IMAGE_RECEIPTS_STATUS = C_MISSING and trunc(sysdate) - (trunc(aerh.report_submitted_date) + rs.NOTIFY_IMG_RCT_OVERDUE_DAYS) > 0)
  )
  and    not exists
  ((select 1 from wf_items where aerh.RECEIPTS_STATUS = C_REQUIRED and item_type = 'APWRECPT'
                          and item_key like to_char(aerh.report_header_id)||':receipts.overdue%' and end_date is null and rownum=1)
   union
   (select 1
    from wf_items
    where decode(aerh.IMAGE_RECEIPTS_STATUS, 'PENDING_IMAGE_SUBMISSION', C_REQUIRED, aerh.IMAGE_RECEIPTS_STATUS) = C_REQUIRED
    and item_type = 'APWRECPT'
    and item_key like to_char(aerh.report_header_id)||':receipts.overdue%'
    and end_date is null
    and rownum=1)
  )
  and    not exists
  (
  (select 1 from wf_items where aerh.RECEIPTS_STATUS = C_MISSING and item_type = 'APWRECPT' and item_key like to_char(aerh.report_header_id)||':receipts.missing%'  and end_date is null and rownum=1)
  union
  (select 1
   from wf_items
   where aerh.IMAGE_RECEIPTS_STATUS = C_MISSING and item_type = 'APWRECPT'
   and item_key like to_char(aerh.report_header_id)||':receipts.missing%'
   and end_date is null
   and rownum=1)
  );
/*
  select aerh.report_header_id,
         aerh.receipts_status,
	 'ORIGINAL'
  from   AP_EXPENSE_REPORT_HEADERS aerh,
         AP_AUD_RULE_SETS rs,
         AP_AUD_RULE_ASSIGNMENTS rsa
  where  aerh.receipts_status in (C_REQUIRED, C_MISSING)
  and    aerh.bothpay_parent_id is null
  and    rsa.org_id = nvl(p_org_id, rsa.org_id)
  and    rsa.org_id = aerh.org_id
  and    rsa.rule_set_id = rs.rule_set_id
  and    rs.rule_set_type = C_NOTIFY_RULE
  and    TRUNC(aerh.report_submitted_date)
         BETWEEN TRUNC(NVL(rsa.START_DATE, aerh.report_submitted_date))
         AND     TRUNC(NVL(rsa.END_DATE, aerh.report_submitted_date))
  and
  (
  (aerh.RECEIPTS_STATUS = C_REQUIRED and trunc(sysdate) - (trunc(aerh.report_submitted_date) + rs.NOTIFY_RCT_OVERDUE_DAYS) > 0)
  or
  (aerh.RECEIPTS_STATUS = C_MISSING and rs.NOTIFY_DOCUMENT_REQUIRED_CODE = C_REQUIRED and trunc(sysdate) - (trunc(aerh.report_submitted_date) + rs.NOTIFY_RCT_OVERDUE_DAYS) > 0)
  )
  and    not exists
  (select 1 from wf_items where aerh.RECEIPTS_STATUS = C_REQUIRED and item_type = 'APWRECPT' and item_key like to_char(aerh.report_header_id)||':receipts.overdue%' and end_date is null and rownum=1)
  and    not exists
  (select 1 from wf_items where aerh.RECEIPTS_STATUS = C_MISSING and item_type = 'APWRECPT' and item_key like to_char(aerh.report_header_id)||':receipts.missing%'  and end_date is null and rownum=1)

  UNION

  select aerh.report_header_id,
	 aerh.image_receipts_status,
	 'IMAGE'
  from   AP_EXPENSE_REPORT_HEADERS aerh,
         AP_AUD_RULE_SETS rs,
         AP_AUD_RULE_ASSIGNMENTS rsa
  where  aerh.image_receipts_status in (C_REQUIRED, C_MISSING)
  and    aerh.bothpay_parent_id is null
  and    rsa.org_id = nvl(p_org_id, rsa.org_id)
  and    rsa.org_id = aerh.org_id
  and    rsa.rule_set_id = rs.rule_set_id
  and    rs.rule_set_type = C_NOTIFY_RULE
  and    TRUNC(aerh.report_submitted_date)
         BETWEEN TRUNC(NVL(rsa.START_DATE, aerh.report_submitted_date))
         AND     TRUNC(NVL(rsa.END_DATE, aerh.report_submitted_date))
  and
  (
  (aerh.IMAGE_RECEIPTS_STATUS = C_REQUIRED and trunc(sysdate) - (trunc(aerh.report_submitted_date) + rs.NOTIFY_IMG_RCT_OVERDUE_DAYS) > 0)
  or
  (aerh.IMAGE_RECEIPTS_STATUS = C_MISSING and rs.NOTIFY_DOCUMENT_REQUIRED_CODE = C_REQUIRED and trunc(sysdate) - (trunc(aerh.report_submitted_date) + rs.NOTIFY_IMG_RCT_OVERDUE_DAYS) > 0)
  )
  and    not exists
  (select 1 from wf_items where aerh.IMAGE_RECEIPTS_STATUS = C_REQUIRED and item_type = 'APWRECPT' and item_key like to_char(aerh.report_header_id)||':receipts.overdue%' and end_date is null and rownum=1)
  and    not exists
  (select 1 from wf_items where aerh.IMAGE_RECEIPTS_STATUS = C_MISSING and item_type = 'APWRECPT' and item_key like to_char(aerh.report_header_id)||':receipts.missing%'  and end_date is null and rownum=1);

*/
/*
  Criteria for this cursor is:
  - list employee's with late receipts who are not on the audit list yet
  - late receipts are required and overdue
*/
-- cursor for employees to be audited
CURSOR c_audit_list_receipts IS
  select aerh.employee_id,
         hr.business_group_id,
         max(rs.audit_term_duration_days)
  from   AP_EXPENSE_REPORT_HEADERS aerh,
         hr_organization_units hr,
         AP_AUD_RULE_SETS rs,
         AP_AUD_RULE_ASSIGNMENTS rsa
  where  aerh.org_id = nvl(p_org_id, aerh.org_id)
  and    aerh.bothpay_parent_id is null
  and    aerh.report_submitted_date is not null
  and    hr.organization_id = aerh.org_id
  and    rsa.org_id = aerh.org_id
  and    rsa.rule_set_id = rs.rule_set_id
  and    rs.rule_set_type = 'AUDIT_LIST'
  and    rs.receipt_delay_rule_flag = 'Y'
  and    TRUNC(aerh.report_submitted_date)
         BETWEEN TRUNC(NVL(rsa.START_DATE, aerh.report_submitted_date))
         AND     TRUNC(NVL(rsa.END_DATE, aerh.report_submitted_date))
  and    aerh.receipts_status in ('REQUIRED', 'MISSING', 'OVERDUE', 'IN_TRANSIT', 'RESOLUTN')
  and    trunc(sysdate) - (trunc(aerh.report_submitted_date) + rs.receipt_delay_days) > 0
  group by employee_id, business_group_id;




BEGIN

  fnd_file.put_line(fnd_file.log, 'p_org_id = '|| p_org_id);

  ------------------------------------------------------------
  l_debug_info := 'Process Overdue/Missing Receipts';
  ------------------------------------------------------------
  fnd_file.put_line(fnd_file.log, l_debug_info);
  open c_overdue_receipts;
  loop

    fetch c_overdue_receipts into l_report_header_id, l_receipts_status,l_image_receipt_status;--, l_receipt_type;
    exit when c_overdue_receipts%NOTFOUND;

    if (l_receipts_status = C_REQUIRED OR l_image_receipt_status = C_REQUIRED) then

      ------------------------------------------------------------
      l_debug_info := 'Update current Receipt Status';
      ------------------------------------------------------------
      IF (l_receipts_status = 'REQUIRED') THEN
	      SetReceiptsStatus(l_report_header_id, C_OVERDUE);
      END IF;

      IF (l_image_receipt_status = 'REQUIRED') THEN
	      SetImageReceiptsStatus(l_report_header_id, C_OVERDUE);
      END IF;
      ------------------------------------------------------------
      l_debug_info := 'Raise Overdue Event: '||l_report_header_id;
      ------------------------------------------------------------
      fnd_file.put_line(fnd_file.log, l_debug_info);
      l_event_raised := 'Y';
      RaiseOverdueEvent(l_report_header_id);

    elsif (l_receipts_status = C_MISSING) then

      ------------------------------------------------------------
      l_debug_info := 'Raise Missing Event: '||l_report_header_id;
      ------------------------------------------------------------
      fnd_file.put_line(fnd_file.log, l_debug_info);
      l_event_raised := 'Y';
      RaiseMissingEvent(l_report_header_id);

    end if;

  end loop;
  close c_overdue_receipts;

  ------------------------------------------------------------
  l_debug_info := 'Commit Events for Overdue/Missing Receipts';
  ------------------------------------------------------------
  fnd_file.put_line(fnd_file.log, l_debug_info);
  COMMIT;

  ------------------------------------------------------------
  l_debug_info := 'Audit Overdue/Missing Receipts';
  ------------------------------------------------------------
  fnd_file.put_line(fnd_file.log, l_debug_info);

  open c_audit_list_receipts;
  loop

    fetch c_audit_list_receipts into l_employee_id, l_business_group_id, l_duration;
    exit when c_audit_list_receipts%NOTFOUND;

    ------------------------------------------------------------
    l_debug_info := 'Adding to Audit List employee: '||l_employee_id||' business group id: '||l_business_group_id||' duration: '||l_duration;
    ------------------------------------------------------------
    fnd_file.put_line(fnd_file.log, l_debug_info);

    l_emp_rec.business_group_id  := l_business_group_id;
    l_emp_rec.person_id          := l_employee_id;
    l_audit_rec.audit_reason_code := 'RECEIPTS_LATE';
    l_audit_rec.start_date        := sysdate;
    l_audit_rec.end_date        := sysdate + l_duration;

    AP_WEB_AUDIT_LIST_PUB.Audit_Employee(1.0,
                                         FND_API.G_FALSE, --p_init_msg_list
                                         FND_API.G_FALSE, --p_commit
                                         FND_API.G_VALID_LEVEL_FULL, --p_validation_level
                                         l_x_return_status,
                                         l_x_msg_count,
                                         l_x_msg_data,
                                         l_emp_rec,
                                         l_audit_rec,
                                         l_auto_audit_id);

  end loop;
  close c_audit_list_receipts;

  ------------------------------------------------------------
  l_debug_info := 'Commit Audit for Overdue/Missing Receipts';
  ------------------------------------------------------------
  fnd_file.put_line(fnd_file.log, l_debug_info);
  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      raise;

END TrackOverdue;

FUNCTION WFExistsForReport(p_report_header_id in varchar2) RETURN BOOLEAN IS
l_event_key_exists	varchar2(1);
BEGIN
  select 'Y'
  into   l_event_key_exists
  from   wf_items
  where  item_type = C_APWRECPT
  and    item_key like p_report_header_id||'%'
  and    rownum = 1;

  IF(l_event_key_exists = 'Y') THEN
	return true;
  ELSE
        return false;
  END IF;
END WFExistsForReport;

------------------------------------------------------------------------
PROCEDURE CheckReceiptType(      p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
l_org_id	        	number;
l_expense_report_id	        number;
l_receipt_rule			AP_AUD_RULE_SETS%ROWTYPE;
l_report_submitted_date		date;
l_receipts_status		VARCHAR2(50) := 'N';
l_image_receipts_status		VARCHAR2(50) := 'N';
l_img_missing_event		VARCHAR2(1) := 'N';
BEGIN
IF (p_funmode = 'RUN') THEN

  l_expense_report_id := ParseItemKey(p_item_type, p_item_key);

  if (l_expense_report_id is null) then
     Wf_Core.Raise('InvalidExpenseReportId');
  end if;

  select nvl(receipts_status,'N'), nvl(image_receipts_status,'N') into l_receipts_status, l_image_receipts_status
  from ap_expense_report_headers_all where report_header_id = l_expense_report_id;

  IF (l_receipts_status = 'RECEIVED') THEN
	l_receipts_status := 'Y';
  ELSE
	l_receipts_status := 'N';
  END IF;

  IF (l_image_receipts_status = 'RECEIVED') THEN
	l_image_receipts_status := 'Y';
  ELSIF (l_image_receipts_status = 'MISSING') THEN
        l_image_receipts_status := 'M';
  ELSE
	l_image_receipts_status := 'N';
  END IF;


  IF (AP_WEB_DB_EXPRPT_PKG.GetOrgIdByReportHeaderId(l_expense_report_id, l_org_id) <> TRUE) THEN
    l_org_id := NULL;
  END IF;

  l_report_submitted_date := WF_ENGINE.GetItemAttrDate(p_item_type,
                                                         p_item_key,
                                                         'EXPENSE_REPORT_SUBMIT_DATE');

  AP_WEB_AUDIT_UTILS.get_rule(l_org_id, l_report_submitted_date, C_RECEIPT_RULE, l_receipt_rule);

  BEGIN
  l_img_missing_event := WF_ENGINE.GetActivityAttrText(p_item_type,
                                                   p_item_key,
                                                   p_actid,
                                                   'IMAGE_MISSING_EVENT');
  EXCEPTION
	WHEN OTHERS THEN
            l_img_missing_event := 'N';
  END;
  IF(l_image_receipts_status = 'M' AND WFExistsForReport(l_expense_report_id)) THEN
     p_result := 'COMPLETE:ORIGINAL';
  ELSIF(l_receipt_rule.ORIG_RECEIPT_REQ = 'Y' AND l_receipt_rule.IMAGE_RECEIPT_REQ = 'Y'
     AND l_image_receipts_status = 'N' AND l_receipts_status = 'N') THEN
     p_result := 'COMPLETE:BOTH';
  ELSIF (l_receipt_rule.ORIG_RECEIPT_REQ = 'Y' AND l_receipts_status = 'N') THEN
     p_result := 'COMPLETE:ORIGINAL';
  ELSIF (l_receipt_rule.IMAGE_RECEIPT_REQ = 'Y' AND l_image_receipts_status = 'N') THEN
	IF (l_img_missing_event = 'Y') THEN
	   IF(l_receipts_status = 'N') THEN
	     p_result := 'COMPLETE:IMAGE';
	   ELSE
	     p_result := 'COMPLETE';
	   END IF;
        ELSE
	     p_result := 'COMPLETE:IMAGE';
	END IF;
  ELSE
     p_result := 'COMPLETE:ORIGINAL';
  END IF;

END IF;
END CheckReceiptType;


------------------------------------------------------------------------
FUNCTION GetImageReceiptsStatus(
                                 p_report_header_id    IN NUMBER) RETURN VARCHAR2 IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_receipts_status		varchar2(30);

BEGIN

    ------------------------------------------------------------
    l_debug_info := 'Retrieve current Receipt Status';
    ------------------------------------------------------------
    select image_receipts_status
    into   l_receipts_status
    from   ap_expense_report_headers_all
    where  report_header_id = p_report_header_id;

    return l_receipts_status;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return null;
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'GetImageReceiptsStatus',
                     to_char(p_report_header_id), l_debug_info);
    raise;
END GetImageReceiptsStatus;


------------------------------------------------------------------------
PROCEDURE SetImageReceiptsStatus(
                                 p_report_header_id    IN NUMBER,
                                 p_receipts_status     IN VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_image_receipts_status	varchar2(30);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start SetImageReceiptsStatus');

    ------------------------------------------------------------
    l_debug_info := 'Lock current Receipt Status';
    ------------------------------------------------------------
    select image_receipts_status
    into   l_image_receipts_status
    from   ap_expense_report_headers_all
    where  report_header_id = p_report_header_id
    for update of receipts_status nowait;

    ------------------------------------------------------------
    l_debug_info := 'Update current Receipt Status';
    ------------------------------------------------------------
    update ap_expense_report_headers_all
    set    image_receipts_status = p_receipts_status
    where  report_header_id = p_report_header_id;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end SetImageReceiptsStatus');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'SetImageReceiptsStatus',
                     to_char(p_report_header_id), p_receipts_status, l_debug_info);
    raise;
END SetImageReceiptsStatus;


------------------------------------------------------------------------
PROCEDURE CheckNotifyImageReceived(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_notif_received	fnd_lookups.lookup_code%TYPE;
  l_days_overdue	number := 0;

  l_report_header_id    number;
  l_image_receipts_status     varchar2(30);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start CheckNotifyImageReceived');

  IF (p_funmode = 'RUN') THEN

    l_report_header_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                      p_item_key,
                                                      'EXPENSE_REPORT_ID');

    ------------------------------------------------------------
    l_debug_info := 'Retrieve current Image Receipt Status';
    ------------------------------------------------------------
    l_image_receipts_status := GetImageReceiptsStatus(l_report_header_id);

  ----------------------------------------------------------
  l_debug_info := 'Check if Notify Receipts Received is enabled';
  ----------------------------------------------------------
  l_notif_received := WF_ENGINE.GetItemAttrText(p_item_type,
                                               p_item_key,
                                               'NOTIF_RULE_NOTIF_RECEIVED');

  ----------------------------------------------------------
  l_debug_info := 'Check if Days Overdue';
  ----------------------------------------------------------
  l_days_overdue := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                p_item_key,
                                                'IMAGE_DAYS_OVERDUE');


  if ((l_image_receipts_status = C_RECEIVED) AND ((nvl(l_notif_received, C_NEVER) = C_RECEIPTS_RECEIVED) or
      (nvl(l_notif_received, C_NEVER) = C_RECEIPTS_OVERDUE and nvl(l_days_overdue, 0) > 0))) then
    p_result := 'COMPLETE:Y';
  else
    p_result := 'COMPLETE:N';
  end if;

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end CheckNotifyImageReceived');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'CheckNotifyImageReceived',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END CheckNotifyImageReceived;

------------------------------------------------------------------------
PROCEDURE SetImageReceiptsStatus(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_orig_receipts_status	varchar2(30);
  l_receipts_status		varchar2(30);
  l_report_header_id            number;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start SetImageReceiptsStatus');

  IF (p_funmode = 'RUN') THEN

    -------------------------------------------------------------------
    l_debug_info := 'Retrieve Activity Attr Receipts Status';
    -------------------------------------------------------------------
    l_receipts_status := WF_ENGINE.GetActivityAttrText(p_item_type,
                                                   p_item_key,
                                                   p_actid,
                                                   'IMAGE_RECEIPTS_STATUS');

    ------------------------------------------------------------
    l_debug_info := 'Retrieve Expense_Report_ID Item Attribute';
    ------------------------------------------------------------
    l_report_header_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                      p_item_key,
                                                      'EXPENSE_REPORT_ID');

    ------------------------------------------------------------
    l_debug_info := 'Update current Receipt Status';
    ------------------------------------------------------------
    SetImageReceiptsStatus(l_report_header_id, l_receipts_status);

  p_result := 'COMPLETE';

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end SetImageReceiptsStatus');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'SetImageReceiptsStatus',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END SetImageReceiptsStatus;

------------------------------------------------------------------------
PROCEDURE SetImageOverdueDays(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_days_overdue number;
  l_report_submitted_date date;
  l_notif_rule_days_overdue number;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start SetDaysOverdue');

  IF (p_funmode = 'RUN') THEN

    SetImageOverdueDays(p_item_type, p_item_key);

  p_result := 'COMPLETE';

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end SetDaysOverdue');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'SetDaysOverdue',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END SetImageOverdueDays;

------------------------------------------------------------------------
PROCEDURE SetImageOverdueDays(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_img_days_overdue	number;
  l_report_submitted_date date;
  l_notif_rule_days_overdue number;
  l_notif_image_days_overdue	number;
  l_receipts_status             varchar2(30);
  l_report_header_id            number;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start SetDaysOverdue');

    /*
      DAYS_OVERDUE is the diff between notif sent date and date the
      the expense report receipts package became overdue
      notif sent date - (report submission date + NOTIF_RULE_DAYS_OVERDUE)
    */
    l_report_submitted_date := WF_ENGINE.GetItemAttrDate(p_item_type,
                                                         p_item_key,
                                                         'EXPENSE_REPORT_SUBMIT_DATE');


    l_notif_image_days_overdue := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                             p_item_key,
                                                             'NOTIF_IMAGE_DAYS_OVERDUE');

    l_img_days_overdue := trunc(sysdate) - (trunc(l_report_submitted_date) + l_notif_image_days_overdue);

    ----------------------------------------------------------
    l_debug_info := 'Set IMAGE_DAYS_OVERDUE Item Attribute';
    ----------------------------------------------------------

    WF_ENGINE.SetItemAttrNumber(p_item_type, p_item_key, 'IMAGE_DAYS_OVERDUE', l_img_days_overdue);

    ------------------------------------------------------------
    l_debug_info := 'Retrieve Expense_Report_ID Item Attribute';
    ------------------------------------------------------------
    l_report_header_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                      p_item_key,
                                                      'EXPENSE_REPORT_ID');

    l_receipts_status := GetImageReceiptsStatus(l_report_header_id);

    if (l_receipts_status = C_IN_TRANSIT) then
      ------------------------------------------------------------
      l_debug_info := 'Update current Receipt Status to Overdue if In Transit';
      ------------------------------------------------------------
      SetImageReceiptsStatus(l_report_header_id, C_OVERDUE);
    end if;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end SetDaysOverdue');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'SetDaysOverdue',
                     p_item_type, p_item_key, l_debug_info);
    raise;
END SetImageOverdueDays;

------------------------------------------------------------------------
PROCEDURE GetImageReceiptsStatus(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_receipts_status		varchar2(30);
  l_report_header_id            number;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'start GetImageReceiptsStatus');

  IF (p_funmode = 'RUN') THEN

    ------------------------------------------------------------
    l_debug_info := 'Retrieve Expense_Report_ID Item Attribute';
    ------------------------------------------------------------
    l_report_header_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                      p_item_key,
                                                      'EXPENSE_REPORT_ID');

    ------------------------------------------------------------
    l_debug_info := 'Retrieve current Receipt Status';
    ------------------------------------------------------------
    l_receipts_status := GetImageReceiptsStatus(l_report_header_id);

  p_result := 'COMPLETE:'||l_receipts_status;

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_RECEIPTS_WF', 'end GetImageReceiptsStatus');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_RECEIPTS_WF', 'GetReceiptsStatus',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END GetImageReceiptsStatus;

------------------------------------------------------------------------
PROCEDURE UpdateOriginalInTransit(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
l_org_id	        	number;
l_expense_report_id	        number;
l_receipt_rule			AP_AUD_RULE_SETS%ROWTYPE;
l_report_submitted_date		date;
l_receipts_status		varchar2(30);

BEGIN
  IF (p_funmode = 'RUN') THEN
	  l_expense_report_id := ParseItemKey(p_item_type, p_item_key);

	  if (l_expense_report_id is null) then
	     Wf_Core.Raise('InvalidExpenseReportId');
	  end if;

          l_receipts_status := GetReceiptsStatus(l_expense_report_id);

          IF (nvl(l_receipts_status, AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED) <> AP_WEB_RECEIPTS_WF.C_RECEIVED) THEN
		SetReceiptsStatus(l_expense_report_id, C_IN_TRANSIT);
          END IF;
	  p_result := 'COMPLETE';
  END IF;


END UpdateOriginalInTransit;

------------------------------------------------------------------------
PROCEDURE RaiseMissingEvent(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
l_expense_report_id	        number;
BEGIN
	IF (p_funmode = 'RUN') THEN
		l_expense_report_id := ParseItemKey(p_item_type, p_item_key);

		if (l_expense_report_id is null) then
			Wf_Core.Raise('InvalidExpenseReportId');
		end if;
		RaiseMissingEvent(l_expense_report_id);
		p_result := 'COMPLETE';
	END IF;

END RaiseMissingEvent;

------------------------------------------------------------------------
PROCEDURE AcceptMissingReceiptDecl(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
l_org_id	        	number;
l_expense_report_id	        number;
l_receipt_rule			AP_AUD_RULE_SETS%ROWTYPE;
l_report_submitted_date		date;
BEGIN
	IF (p_funmode = 'RUN') THEN

	  l_expense_report_id := ParseItemKey(p_item_type, p_item_key);

	  if (l_expense_report_id is null) then
	     Wf_Core.Raise('InvalidExpenseReportId');
	  end if;

	  IF (AP_WEB_DB_EXPRPT_PKG.GetOrgIdByReportHeaderId(l_expense_report_id, l_org_id) <> TRUE) THEN
	    l_org_id := NULL;
	  END IF;

	  l_report_submitted_date := WF_ENGINE.GetItemAttrDate(p_item_type,
								 p_item_key,
								 'EXPENSE_REPORT_SUBMIT_DATE');

	  AP_WEB_AUDIT_UTILS.get_rule(l_org_id, l_report_submitted_date, C_RECEIPT_RULE, l_receipt_rule);

	  IF (l_receipt_rule.rule_set_id is null OR nvl(l_receipt_rule.allow_recpt_decl,'N') = 'Y') THEN
	    p_result := 'COMPLETE:Y';
	  ELSE
	    update ap_expense_report_headers_all set workflow_approved_flag = null,
	    expense_status_code = 'SAVED' where report_header_id = l_expense_report_id;

	    p_result := 'COMPLETE:N';
	  END IF;
	END IF;

END AcceptMissingReceiptDecl;


------------------------------------------------------------------------
PROCEDURE InitOriginalRecptTrack(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
l_org_id	        	number;
l_expense_report_id	        number;
l_receipt_rule			AP_AUD_RULE_SETS%ROWTYPE;
l_report_submitted_date		date;
BEGIN
  IF (p_funmode = 'RUN') THEN
	l_expense_report_id := ParseItemKey(p_item_type, p_item_key);

	if (l_expense_report_id is null) then
	   Wf_Core.Raise('InvalidExpenseReportId');
	end if;

	IF (AP_WEB_DB_EXPRPT_PKG.GetOrgIdByReportHeaderId(l_expense_report_id, l_org_id) <> TRUE) THEN
	  l_org_id := NULL;
	END IF;

	l_report_submitted_date := WF_ENGINE.GetItemAttrDate(p_item_type,
						 p_item_key,
						 'EXPENSE_REPORT_SUBMIT_DATE');

	AP_WEB_AUDIT_UTILS.get_rule(l_org_id, l_report_submitted_date, C_RECEIPT_RULE, l_receipt_rule);
	IF(l_receipt_rule.IMAGE_RECEIPT_REQ = 'Y' AND l_receipt_rule.ORIG_RECEIPT_REQ = 'N') THEN
	 RaiseOverdueEvent(l_expense_report_id);
	END IF;
  END IF;


END InitOriginalRecptTrack;


------------------------------------------------------------------------
PROCEDURE CheckRecvdRecptType(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
l_expense_report_id		NUMBER;
l_receipts_status		VARCHAR2(30);
l_image_receipts_status		VARCHAR2(30);
l_result			VARCHAR2(30);

BEGIN
IF (p_funmode = 'RUN') THEN
	l_expense_report_id := ParseItemKey(p_item_type, p_item_key);
	SELECT receipts_status, image_receipts_status INTO l_receipts_status, l_image_receipts_status
	FROM ap_expense_report_headers_all WHERE report_header_id = l_expense_report_id;

	IF (l_receipts_status = 'RECEIVED' AND l_image_receipts_status = 'RECEIVED') THEN
		p_result := 'COMPLETE:BOTH';
	ELSIF(l_receipts_status = 'RECEIVED') THEN
		p_result := 'COMPLETE:ORIGINAL';
        ELSIF(l_image_receipts_status = 'RECEIVED') THEN
		p_result := 'COMPLETE:IMAGE';
	END IF;

END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	p_result := 'COMPLETE:NONE';

END CheckRecvdRecptType;

------------------------------------------------------------------------
PROCEDURE Check_Both_Required(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
l_result_type			VARCHAR2(50);
l_process_type			VARCHAR2(30);
l_result                        VARCHAR2(30);

BEGIN
IF (p_funmode = 'RUN') THEN
	l_process_type := WF_ENGINE.GetActivityAttrText(p_item_type,
                                                   p_item_key,
                                                   p_actid,
                                                   'PROCESS_TYPE');

        IF (l_process_type = 'RECEIVED') THEN
		CheckRecvdRecptType(p_item_type,
                 p_item_key,
                 p_actid,
                 p_funmode,
		 l_result_type);
        ELSIF(l_process_type = 'OVERDUE' OR l_process_type = 'MISSING') THEN
                CheckReceiptType(p_item_type,
                 p_item_key,
                 p_actid,
                 p_funmode,
		 l_result_type);
        END IF;

        IF(l_result_type = 'COMPLETE:BOTH') THEN
		p_result := 'COMPLETE:Y';
	ELSE
		p_result := 'COMPLETE:N';
	END IF;


END IF;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
        p_result := 'COMPLETE:N';

END Check_Both_Required;


END AP_WEB_RECEIPTS_WF;

/
