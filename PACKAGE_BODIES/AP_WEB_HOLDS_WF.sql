--------------------------------------------------------
--  DDL for Package Body AP_WEB_HOLDS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_HOLDS_WF" AS
/* $Header: apwholdsb.pls 120.4.12010000.3 2010/05/24 15:55:37 dsadipir ship $ */

------------------------
-- Events
------------------------
-- Event key is used for item key and result code when aborting the track process
-- Event name is the true event name
-- Item/Event key is in the form of: '<Expense Report Id>:<Event key>:<DD-MON-RRRR HH:MI:SS>'
C_HELD_EVENT_KEY	CONSTANT VARCHAR2(30) := 'held';
C_HELD_EVENT_NAME	CONSTANT VARCHAR2(80) := 'oracle.apps.ap.oie.expenseReport.held';
C_RELEASED_EVENT_KEY	CONSTANT VARCHAR2(30) := 'released';
C_RELEASED_EVENT_NAME	CONSTANT VARCHAR2(80) := 'oracle.apps.ap.oie.expenseReport.released';

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

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'start ParseItemKey');

  ----------------------------------------------------------
  l_debug_info := 'Parse the item key for the Expense Report Id';
  ----------------------------------------------------------
  return substrb(p_item_key, 1, instrb(p_item_key, C_ITEM_KEY_DELIM)-1);

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'end ParseItemKey');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_HOLDS_WF', 'ParseItemKey',
                     p_item_type, p_item_key, l_debug_info);
    raise;
END ParseItemKey;


------------------------------------------------------------------------
FUNCTION IsHoldsRuleSetup(
                                 p_org_id                IN NUMBER,
                                 p_report_submitted_date IN DATE) RETURN VARCHAR2 IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_is_holds_rule_setup         VARCHAR2(1);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'start IsHoldsRuleSetup');

    ------------------------------------------------------------
    l_debug_info := 'Check if Holds Rule Setup';
    ------------------------------------------------------------
    select 'Y'
    into   l_is_holds_rule_setup
    from   AP_AUD_RULE_SETS rs,
           AP_AUD_RULE_ASSIGNMENTS_ALL rsa
    where  rsa.org_id = p_org_id
    and    rsa.rule_set_id = rs.rule_set_id
    and    rs.rule_set_type = C_HOLD_RULE
    and    TRUNC(p_report_submitted_date)
           BETWEEN TRUNC(NVL(rsa.START_DATE, p_report_submitted_date))
           AND     TRUNC(NVL(rsa.END_DATE, p_report_submitted_date))
    and    rownum = 1;

    return l_is_holds_rule_setup;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'end IsHoldsRuleSetup');

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return 'N';
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_HOLDS_WF', 'IsHoldsRuleSetup',
                     to_char(p_org_id), to_char(p_report_submitted_date), l_debug_info);
    raise;
END IsHoldsRuleSetup;


------------------------------------------------------------------------
PROCEDURE IsHoldsRuleSetup(
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

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'start IsHoldsRuleSetup');

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
    from   ap_expense_report_headers
    where  report_header_id = l_expense_report_id;

    ------------------------------------------------------------
    l_debug_info := 'Check if Holds Rule Setup';
    ------------------------------------------------------------
    l_is_notif_rule_setup := IsHoldsRuleSetup(l_org_id, l_report_submitted_date);

    p_result := 'COMPLETE:'||l_is_notif_rule_setup;

  ELSIF (p_funmode = 'CANCEL') THEN

    p_result := 'COMPLETE';

  END IF; -- p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'end IsHoldsRuleSetup');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_HOLDS_WF', 'IsHoldsRuleSetup',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END IsHoldsRuleSetup;


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
  where  item_type = C_APWHOLDS
  and    item_key = p_event_key
  and    rownum = 1;

  return true;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return false;

END EventKeyExists;


------------------------------------------------------------------------
PROCEDURE RaiseHeldEvent(
                                 p_expense_report_id    IN NUMBER) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_event_key			wf_items.item_key%type;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'start RaiseHeldEvent');

  ----------------------------------------------------------
  l_debug_info := 'Generate Event Key';
  ----------------------------------------------------------
  l_event_key := GenerateEventKey(p_expense_report_id, C_HELD_EVENT_KEY);

  ----------------------------------------------------------
  l_debug_info := 'Check Event Key';
  ----------------------------------------------------------
  if (NOT EventKeyExists(l_event_key)) then

    ----------------------------------------------------------
    l_debug_info := 'Raise Held Event';
    ----------------------------------------------------------
    wf_event.raise(p_event_name => C_HELD_EVENT_NAME,
                   p_event_key => l_event_key);
                   --p_parameters => l_parameter_list);

  end if;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'end RaiseHeldEvent');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_HOLDS_WF', 'RaiseHeldEvent',
                     p_expense_report_id, l_debug_info);
    raise;
END RaiseHeldEvent;


------------------------------------------------------------------------
PROCEDURE RaiseReleasedEvent(
                                 p_expense_report_id    IN NUMBER) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_event_key			wf_items.item_key%type;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'start RaiseReleasedEvent');

  ----------------------------------------------------------
  l_debug_info := 'Generate Event Key';
  ----------------------------------------------------------
  l_event_key := GenerateEventKey(p_expense_report_id, C_RELEASED_EVENT_KEY);

  ----------------------------------------------------------
  l_debug_info := 'Check Event Key';
  ----------------------------------------------------------
  if (NOT EventKeyExists(l_event_key)) then

    ----------------------------------------------------------
    l_debug_info := 'Raise Released Event';
    ----------------------------------------------------------
    wf_event.raise(p_event_name => C_RELEASED_EVENT_NAME,
                   p_event_key => l_event_key);
                   --p_parameters => l_parameter_list);

  end if;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'end RaiseReleasedEvent');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_HOLDS_WF', 'RaiseReleasedEvent',
                     p_expense_report_id, l_debug_info);
    raise;
END RaiseReleasedEvent;


------------------------------------------------------------------------
PROCEDURE RaiseReleasedEvent(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'start RaiseReleasedEvent');

  IF (p_funmode = 'RUN') THEN

  ----------------------------------------------------------
  l_debug_info := 'Raise Released event';
  ----------------------------------------------------------
  RaiseReleasedEvent(WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                p_item_key,
                                                'EXPENSE_REPORT_ID'));

  p_result := 'COMPLETE';

  END IF; --  p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'end RaiseReleasedEvent');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_HOLDS_WF', 'RaiseReleasedEvent',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END RaiseReleasedEvent;


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
  l_holding_report_header_id	AP_EXPENSE_REPORT_HEADERS.holding_report_header_id%type;
  l_holding_invoice_num		AP_EXPENSE_REPORT_HEADERS.invoice_num%type;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'start Init');

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
         report_submitted_date,
         holding_report_header_id
  into   l_created_by,
         l_employee_id,
         l_invoice_num,
         l_cost_center,
         l_total,
         l_purpose,
         l_report_submitted_date,
         l_holding_report_header_id
  from   ap_expense_report_headers
  where  report_header_id = l_expense_report_id;

  ----------------------------------------------------------
  l_debug_info := 'Get Holding Expense Report data';
  ----------------------------------------------------------
  if (l_holding_report_header_id is not null) then
    begin
      select invoice_num
      into   l_holding_invoice_num
      from   ap_expense_report_headers
      where  report_header_id = l_holding_report_header_id;

      exception
      when no_data_found then
        null;
    end;

    ----------------------------------------------------------
    l_debug_info := 'Set HOLDING_EXPENSE_REPORT_ID Item Attribute';
    ----------------------------------------------------------
    iNum := iNum + 1;
    l_numNameArr(iNum) := 'HOLDING_EXPENSE_REPORT_ID';
    l_numValArr(iNum) := l_holding_report_header_id;

    --------------------------------------------------------
    l_debug_info := 'Set HOLDING_EXPENSE_REPORT Item Attribute';
    --------------------------------------------------------
    iText := iText + 1;
    l_textNameArr(iText) := 'HOLDING_EXPENSE_REPORT';
    l_textValArr(iText) := l_holding_invoice_num;

  else

    --------------------------------------------------------
    l_debug_info := 'Unset HOLDING_REPORT_DETAILS_URL Item Attribute';
    --------------------------------------------------------
    iText := iText + 1;
    l_textNameArr(iText) := 'HOLDING_REPORT_DETAILS_URL';
    l_textValArr(iText) := '';


  end if;

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


  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'end Init');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_HOLDS_WF', 'Init',
                     p_item_type, p_item_key, l_expense_report_id, l_preparer_name, l_debug_info);
    raise;
END Init;


------------------------------------------------------------------------
PROCEDURE InitHeld(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'start InitHeld');

  IF (p_funmode = 'RUN') THEN

  ----------------------------------------------------------
  l_debug_info := 'Initialize common event data';
  ----------------------------------------------------------
  Init(p_item_type, p_item_key);

  p_result := 'COMPLETE';

  END IF; --  p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'end InitHeld');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_HOLDS_WF', 'InitHeld',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END InitHeld;


------------------------------------------------------------------------
PROCEDURE InitReleased(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'start InitReleased');

  IF (p_funmode = 'RUN') THEN

  ----------------------------------------------------------
  l_debug_info := 'Initialize common event data';
  ----------------------------------------------------------
  Init(p_item_type, p_item_key);

  p_result := 'COMPLETE';

  END IF; --  p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'end InitReleased');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_HOLDS_WF', 'InitReleased',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END InitReleased;


------------------------------------------------------------------------
PROCEDURE AnyHoldsPending(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_report_header_id            number;
  l_any_holds_pending           varchar2(1) := 'N';

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'start AnyHoldsPending');

  IF (p_funmode = 'RUN') THEN

    ------------------------------------------------------------
    l_debug_info := 'Retrieve Expense_Report_ID Item Attribute';
    ------------------------------------------------------------
    l_report_header_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                      p_item_key,
                                                      'EXPENSE_REPORT_ID');

    ----------------------------------------------------------
    l_debug_info := 'Any Holds Pending?';
    ----------------------------------------------------------
    select 'Y'
    into   l_any_holds_pending
    from   ap_expense_report_headers
    where  report_header_id <> holding_report_header_id
    and    holding_report_header_id = l_report_header_id
    and    rownum = 1;

    p_result := 'COMPLETE:'||l_any_holds_pending;

  END IF; --  p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'end AnyHoldsPending');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_HOLDS_WF', 'AnyHoldsPending',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END AnyHoldsPending;


------------------------------------------------------------------------
FUNCTION GetHoldsScenario(
                                 p_org_id                IN NUMBER,
                                 p_report_submitted_date IN DATE) RETURN VARCHAR2 IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_is_holds_rule_setup         VARCHAR2(1);
  l_hold_code			AP_AUD_RULE_SETS.hold_code%type;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'start GetHoldsScenario');

    ------------------------------------------------------------
    l_debug_info := 'Check if Holds Rule Setup';
    ------------------------------------------------------------
    select rs.hold_code
    into   l_hold_code
    from   AP_AUD_RULE_SETS rs,
           AP_AUD_RULE_ASSIGNMENTS_ALL rsa
    where  rsa.org_id = p_org_id
    and    rsa.rule_set_id = rs.rule_set_id
    and    rs.rule_set_type = C_HOLD_RULE
    and    TRUNC(p_report_submitted_date)
           BETWEEN TRUNC(NVL(rsa.START_DATE, p_report_submitted_date))
           AND     TRUNC(NVL(rsa.END_DATE, p_report_submitted_date))
    and    rownum = 1;

    if (l_hold_code = C_HOLD_ALL_CODE) then
      return C_HOLD_ALL;
    elsif (l_hold_code = C_HOLD_EACH_CODE) then
      return C_HOLD_EACH;
    end if;

  return null;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'end GetHoldsScenario');

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return null;
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_HOLDS_WF', 'GetHoldsScenario',
                     to_char(p_org_id), to_char(p_report_submitted_date), l_debug_info);
    raise;
END GetHoldsScenario;


------------------------------------------------------------------------
PROCEDURE GetHoldsScenario(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_org_id			number;
  l_report_submitted_date	date;

  l_holds_scenario		AP_AUD_RULE_SETS.hold_code%type;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'start GetHoldsScenario');

  IF (p_funmode = 'RUN') THEN

    ------------------------------------------------------------
    l_debug_info := 'Retrieve ORG_ID Item Attribute';
    ------------------------------------------------------------
    l_org_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                            p_item_key,
                                            'ORG_ID');

    ------------------------------------------------------------
    l_debug_info := 'Retrieve EXPENSE_REPORT_SUBMIT_DATE Item Attribute';
    ------------------------------------------------------------
    l_report_submitted_date := WF_ENGINE.GetItemAttrDate(p_item_type,
                                                         p_item_key,
                                                         'EXPENSE_REPORT_SUBMIT_DATE');

    ----------------------------------------------------------
    l_debug_info := 'Get Holds Scenario';
    ----------------------------------------------------------
    l_holds_scenario := GetHoldsScenario(l_org_id, l_report_submitted_date);

    p_result := 'COMPLETE:'||l_holds_scenario;

  END IF; --  p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'end GetHoldsScenario');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_HOLDS_WF', 'GetHoldsScenario',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END GetHoldsScenario;


------------------------------------------------------------------------
PROCEDURE ReleaseHold(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'start ReleaseHold');

  IF (p_funmode = 'RUN') THEN

  ----------------------------------------------------------
  l_debug_info := 'Release Hold';
  ----------------------------------------------------------

  p_result := 'COMPLETE';

  END IF; --  p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'end ReleaseHold');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_HOLDS_WF', 'ReleaseHold',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END ReleaseHold;


------------------------------------------------------------------------
PROCEDURE StoreNote(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------
  l_report_header_id            number;
  l_debug_info                  VARCHAR2(200);

  l_fnd_message fnd_new_messages.message_name%type;
  l_note_text varchar2(2000);
  l_holding_invoice_num ap_expense_report_headers.invoice_num%type;

  l_orig_language_code ap_expense_params.note_language_code%type := null;
  l_orig_language fnd_languages.nls_language%type := null;
  l_new_language_code ap_expense_params.note_language_code%type := null;
  l_new_language fnd_languages.nls_language%type := null;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'start StoreNote');

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
    begin
      select note_language_code
      into   l_new_language_code
      from   ap_expense_params;

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
    l_debug_info := 'Retrieve Activity Attr FND Message';
    -------------------------------------------------------------------
    l_fnd_message := WF_ENGINE.GetActivityAttrText(p_item_type,
                                                   p_item_key,
                                                   p_actid,
                                                   'FND_MESSAGE');

    if (l_fnd_message is not null) then

      FND_MESSAGE.SET_NAME('SQLAP', l_fnd_message);

      if (l_fnd_message = 'APWRECPT_HELD_ALL_NOTE') then

        l_holding_invoice_num := WF_ENGINE.GetItemAttrText(p_item_type,
                                                           p_item_key,
                                                           'HOLDING_EXPENSE_REPORT');

        FND_MESSAGE.SET_TOKEN('HOLDING_EXPENSE_REPORT', l_holding_invoice_num);

      end if; -- l_fnd_message is not null

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

    -------------------------------------------------------------------
    l_debug_info := 'Restore nls context to original language';
    -------------------------------------------------------------------
    fnd_global.set_nls_context(p_nls_language => l_orig_language);

  p_result := 'COMPLETE';

  END IF; --  p_funmode = 'RUN'

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'end StoreNote');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_HOLDS_WF', 'StoreNote',
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

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'start CallbackFunction');

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

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_HOLDS_WF', 'end CallbackFunction');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_HOLDS_WF', 'CallbackFunction',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END CallbackFunction;


------------------------------------------------------------------------
PROCEDURE ExpenseHolds IS
------------------------------------------------------------------------

  l_debug_info                  VARCHAR2(200);

BEGIN

  ------------------------------------------------------------
  l_debug_info := 'Process Hold Each Scenario';
  fnd_file.put_line(fnd_file.log, l_debug_info);
  ------------------------------------------------------------
  HoldEach;

  ------------------------------------------------------------
  l_debug_info := 'Process Hold All Scenario';
  fnd_file.put_line(fnd_file.log, l_debug_info);
  ------------------------------------------------------------
  HoldAll;

  ------------------------------------------------------------
  l_debug_info := 'Process Hold BothPay Scenario';
  fnd_file.put_line(fnd_file.log, l_debug_info);
  ------------------------------------------------------------
  HoldBothPay;

  ------------------------------------------------------------
  l_debug_info := 'Process Obsolete Holds';
  fnd_file.put_line(fnd_file.log, l_debug_info);
  ------------------------------------------------------------
  ObsoleteHold;

  EXCEPTION
    WHEN OTHERS THEN
    BEGIN
            IF ( SQLCODE <> -20001 )
            THEN
                    FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_DEBUG' );
                    FND_MESSAGE.SET_TOKEN( 'ERROR', SQLERRM );
                    FND_MESSAGE.SET_TOKEN( 'CALLING_SEQUENCE', 'ExpenseHolds' );
                    FND_MESSAGE.SET_TOKEN( 'DEBUG_INFO', l_debug_info );
                    APP_EXCEPTION.RAISE_EXCEPTION;
            ELSE
                    -- Do not need to set the token since it has been done in the
                    -- child process
                    RAISE;
            END IF;
    END;

END ExpenseHolds;


------------------------------------------------------------------------
PROCEDURE UpdateExpenseStatus(
                                 p_report_header_id         IN NUMBER,
                                 p_expense_status_code      IN VARCHAR2,
                                 p_holding_report_header_id IN NUMBER) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_expense_status_code		ap_expense_report_headers.expense_status_code%type;

BEGIN

    ------------------------------------------------------------
    l_debug_info := 'Lock current Expense Status for: '||p_report_header_id;
    fnd_file.put_line(fnd_file.log, l_debug_info);
    ------------------------------------------------------------
    select expense_status_code
    into   l_expense_status_code
    from   ap_expense_report_headers
    where  report_header_id = p_report_header_id
    for update of expense_status_code nowait;

    ------------------------------------------------------------
    l_debug_info := 'Update current Expense Status to: '||p_expense_status_code||' for: '||p_report_header_id;
    fnd_file.put_line(fnd_file.log, l_debug_info);
    ------------------------------------------------------------
    update ap_expense_report_headers
    set    expense_status_code = p_expense_status_code,
           holding_report_header_id = p_holding_report_header_id,
           expense_last_status_date = sysdate,
           request_id = fnd_global.conc_request_id
    where  report_header_id = p_report_header_id;

  EXCEPTION
  WHEN OTHERS THEN
    BEGIN
            IF ( SQLCODE <> -20001 )
            THEN
                    FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_DEBUG' );
                    FND_MESSAGE.SET_TOKEN( 'ERROR', SQLERRM );
                    FND_MESSAGE.SET_TOKEN( 'CALLING_SEQUENCE', 'UpdateExpenseStatus' );
                    FND_MESSAGE.SET_TOKEN( 'DEBUG_INFO', l_debug_info );
                    APP_EXCEPTION.RAISE_EXCEPTION;
            ELSE
                    -- Do not need to set the token since it has been done in the
                    -- child process
                    RAISE;
            END IF;
    END;

END UpdateExpenseStatus;


------------------------------------------------------------------------
PROCEDURE ReleaseHold(
                                 p_report_header_id         IN NUMBER) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

BEGIN

    ------------------------------------------------------------
    l_debug_info := 'Release Hold for: '||p_report_header_id;
    fnd_file.put_line(fnd_file.log, l_debug_info);
    ------------------------------------------------------------
    UpdateExpenseStatus(p_report_header_id, AP_WEB_RECEIPTS_WF.C_PENDING_HOLDS, null);

  EXCEPTION
  WHEN OTHERS THEN
    BEGIN
            IF ( SQLCODE <> -20001 )
            THEN
                    FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_DEBUG' );
                    FND_MESSAGE.SET_TOKEN( 'ERROR', SQLERRM );
                    FND_MESSAGE.SET_TOKEN( 'CALLING_SEQUENCE', 'ReleaseHold' );
                    FND_MESSAGE.SET_TOKEN( 'DEBUG_INFO', l_debug_info );
                    APP_EXCEPTION.RAISE_EXCEPTION;
            ELSE
                    -- Do not need to set the token since it has been done in the
                    -- child process
                    RAISE;
            END IF;
    END;

END ReleaseHold;


------------------------------------------------------------------------
PROCEDURE PlaceHold(
                                 p_report_header_id         IN NUMBER,
                                 p_holding_report_header_id IN NUMBER) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

BEGIN

    ------------------------------------------------------------
    l_debug_info := 'Place Hold on: '||p_report_header_id||' because of: '||p_holding_report_header_id;
    fnd_file.put_line(fnd_file.log, l_debug_info);
    ------------------------------------------------------------
    UpdateExpenseStatus(p_report_header_id, AP_WEB_RECEIPTS_WF.C_PAYMENT_HELD, p_holding_report_header_id);

  EXCEPTION
    WHEN OTHERS THEN
    BEGIN
            IF ( SQLCODE <> -20001 )
            THEN
                    FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_DEBUG' );
                    FND_MESSAGE.SET_TOKEN( 'ERROR', SQLERRM );
                    FND_MESSAGE.SET_TOKEN( 'CALLING_SEQUENCE', 'PlaceHold' );
                    FND_MESSAGE.SET_TOKEN( 'DEBUG_INFO', l_debug_info );
                    APP_EXCEPTION.RAISE_EXCEPTION;
            ELSE
                    -- Do not need to set the token since it has been done in the
                    -- child process
                    RAISE;
            END IF;
    END;

END PlaceHold;


------------------------------------------------------------------------
PROCEDURE ReadyForPayment(
                                 p_report_header_id         IN NUMBER) IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

BEGIN

    ------------------------------------------------------------
    l_debug_info := 'Ready for Payment for: '||p_report_header_id;
    fnd_file.put_line(fnd_file.log, l_debug_info);
    ------------------------------------------------------------
    UpdateExpenseStatus(p_report_header_id, AP_WEB_RECEIPTS_WF.C_INVOICED, null);

  EXCEPTION
    WHEN OTHERS THEN
    BEGIN
            IF ( SQLCODE <> -20001 )
            THEN
                    FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_DEBUG' );
                    FND_MESSAGE.SET_TOKEN( 'ERROR', SQLERRM );
                    FND_MESSAGE.SET_TOKEN( 'CALLING_SEQUENCE', 'ReadyForPayment' );
                    FND_MESSAGE.SET_TOKEN( 'DEBUG_INFO', l_debug_info );
                    APP_EXCEPTION.RAISE_EXCEPTION;
            ELSE
                    -- Do not need to set the token since it has been done in the
                    -- child process
                    RAISE;
            END IF;
    END;

END ReadyForPayment;


/*
  Written by:
    Ron Langi

  Purpose:
    The purpose of this is to hold the current expense report until the receipt package is received for required receipts.

    The following is the PL/SQL logic invoked by the Invoice Import program for the Hold Each scenario:

    1. For each expense report that is 'Payment Held' or 'Pending Holds Clearance':

         If the receipts are not required or have been received/waived:
           a. Mark as 'Ready for Payment'
           b. Clear the HOLDING_REPORT_HEADER_ID

         If it is pending holds or it has been held for another report (scenario change):
           a. Mark as 'Payment Held'
           b. Set the HOLDING_REPORT_HEADER_ID to the current expense report


  Input:

  Output:

  Input/Output:

  Assumption:

*/
----------------------------------------------------------------------
PROCEDURE HoldEach IS
----------------------------------------------------------------------

  l_debug_info                  VARCHAR2(200);

  l_report_header_id		ap_expense_report_headers.report_header_id%TYPE;
  l_receipts_status		ap_expense_report_headers.receipts_status%TYPE;
  l_image_receipts_status	ap_expense_report_headers.image_receipts_status%TYPE;
  l_source			ap_expense_report_headers.source%TYPE;
  l_expense_status_code		ap_expense_report_headers.expense_status_code%TYPE;
  l_holding_report_header_id	ap_expense_report_headers.holding_report_header_id%TYPE;


/*
  Criteria for this cursor is:
  - all payment held or pending holds clearance
  - excludes bothpay child reports
  - submitted within Hold Each scenario
*/
------------------------------------------------------------
-- cursor for Hold Each scenario
------------------------------------------------------------
CURSOR c_hold_each IS
  select aerh.report_header_id,
         aerh.receipts_status,
	 aerh.image_receipts_status,
         aerh.source,
         aerh.expense_status_code,
         aerh.holding_report_header_id
  from   AP_EXPENSE_REPORT_HEADERS aerh,
         AP_AUD_RULE_SETS rs,
         AP_AUD_RULE_ASSIGNMENTS_ALL rsa
  where  aerh.source = AP_WEB_RECEIPTS_WF.C_SELF_SERVICE_SOURCE
  and    aerh.expense_status_code in (AP_WEB_RECEIPTS_WF.C_PAYMENT_HELD, AP_WEB_RECEIPTS_WF.C_PENDING_HOLDS)
  and    aerh.bothpay_parent_id is null
  and    rsa.org_id = aerh.org_id
  and    rsa.rule_set_id = rs.rule_set_id
  and    rs.rule_set_type = C_HOLD_RULE
  and    TRUNC(aerh.report_submitted_date)
         BETWEEN TRUNC(NVL(rsa.START_DATE, aerh.report_submitted_date))
         AND     TRUNC(NVL(rsa.END_DATE, aerh.report_submitted_date))
  and    rs.HOLD_CODE = C_HOLD_EACH_CODE;


BEGIN

  ------------------------------------------------------------
  l_debug_info := 'Determine whether to place Holds';
  fnd_file.put_line(fnd_file.log, l_debug_info);
  ------------------------------------------------------------
  open c_hold_each;
  loop

    fetch c_hold_each into l_report_header_id,
                           l_receipts_status,
		           l_image_receipts_status,
                           l_source,
                           l_expense_status_code,
                           l_holding_report_header_id;
    exit when c_hold_each%NOTFOUND;

      if (nvl(l_receipts_status, AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED) in (AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED, AP_WEB_RECEIPTS_WF.C_RECEIVED, AP_WEB_RECEIPTS_WF.C_RECEIVED_RESUBMITTED, AP_WEB_RECEIPTS_WF.C_WAIVED)) then

        ------------------------------------------------------------
        l_debug_info := 'Receipts not required or have been received/waived';
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------
        ------------------------------------------------------------
        l_debug_info := 'Set status Ready for Payment for: '||l_report_header_id;
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------
        ReadyForPayment(l_report_header_id);

      elsif (nvl(l_image_receipts_status, AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED) in (AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED, AP_WEB_RECEIPTS_WF.C_RECEIVED, AP_WEB_RECEIPTS_WF.C_RECEIVED_RESUBMITTED, AP_WEB_RECEIPTS_WF.C_WAIVED)) then

	------------------------------------------------------------
        l_debug_info := 'Image Receipts not required or have been received/waived';
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------
        ------------------------------------------------------------
        l_debug_info := 'Set status Ready for Payment for: '||l_report_header_id;
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------
        ReadyForPayment(l_report_header_id);

      elsif (l_expense_status_code = AP_WEB_RECEIPTS_WF.C_PENDING_HOLDS or
             (l_expense_status_code = AP_WEB_RECEIPTS_WF.C_PAYMENT_HELD and l_holding_report_header_id <> l_report_header_id)) then

        ------------------------------------------------------------
        l_debug_info := 'Set status Payment Held and set holding_report_header_id to current report_header_id for: '||l_report_header_id;
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------
        PlaceHold(l_report_header_id, l_report_header_id);

      elsif (l_expense_status_code = AP_WEB_RECEIPTS_WF.C_PAYMENT_HELD and
             nvl(l_receipts_status, AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED) not in (AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED, AP_WEB_RECEIPTS_WF.C_RECEIVED, AP_WEB_RECEIPTS_WF.C_RECEIVED_RESUBMITTED, AP_WEB_RECEIPTS_WF.C_WAIVED)) then

        ------------------------------------------------------------
        l_debug_info := 'Payment Held status untouched for: '||l_report_header_id;
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------

      else

        ------------------------------------------------------------
        l_debug_info := 'Set status Ready for Payment for: '||l_report_header_id;
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------
        ReadyForPayment(l_report_header_id);

     end if;

  end loop;
  close c_hold_each;

  EXCEPTION
    WHEN OTHERS THEN
    BEGIN
            IF ( SQLCODE <> -20001 )
            THEN
                    FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_DEBUG' );
                    FND_MESSAGE.SET_TOKEN( 'ERROR', SQLERRM );
                    FND_MESSAGE.SET_TOKEN( 'CALLING_SEQUENCE', 'HoldEach' );
                    FND_MESSAGE.SET_TOKEN( 'DEBUG_INFO', l_debug_info );
                    APP_EXCEPTION.RAISE_EXCEPTION;
            ELSE
                    -- Do not need to set the token since it has been done in the
                    -- child process
                    RAISE;
            END IF;
    END;

END HoldEach;


------------------------------------------------------------------------
FUNCTION GetOldestOverdueReceipts(
                                 p_employee_id           IN NUMBER,
                                 p_hold_rct_overdue_days IN NUMBER) RETURN NUMBER IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_overdue_report_header_id             number;

/*
  Criteria for this cursor is:
  - all submitted reports
  - excludes bothpay child reports
  - receipts are grossly overdue
*/
------------------------------------------------------------
-- cursor for oldest overdue receipts
-- NOTE: need index on aerh.receipts_status/employee_id
------------------------------------------------------------
CURSOR c_oldest_overdue_receipts IS
  select aerh.report_header_id
  from   AP_EXPENSE_REPORT_HEADERS aerh
  where  (aerh.source <> 'NonValidatedWebExpense' or aerh.workflow_approved_flag is null)
  and    aerh.receipts_status is not null
  and    aerh.receipts_status in (AP_WEB_RECEIPTS_WF.C_REQUIRED, AP_WEB_RECEIPTS_WF.C_MISSING, AP_WEB_RECEIPTS_WF.C_OVERDUE, AP_WEB_RECEIPTS_WF.C_IN_TRANSIT, AP_WEB_RECEIPTS_WF.C_RESOLUTN)
  and    aerh.bothpay_parent_id is null
  and    trunc(sysdate) - (trunc(aerh.report_submitted_date) + p_hold_rct_overdue_days) > 0
  and    aerh.employee_id = p_employee_id
  order  by aerh.report_submitted_date asc;

BEGIN

    ------------------------------------------------------------
    l_debug_info := 'Get Oldest Overdue Receipts';
    fnd_file.put_line(fnd_file.log, l_debug_info);
    ------------------------------------------------------------
    open c_oldest_overdue_receipts;
    fetch c_oldest_overdue_receipts into l_overdue_report_header_id;
    close c_oldest_overdue_receipts;

    return l_overdue_report_header_id;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return null;
  WHEN OTHERS THEN
    BEGIN
            IF ( SQLCODE <> -20001 )
            THEN
                    FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_DEBUG' );
                    FND_MESSAGE.SET_TOKEN( 'ERROR', SQLERRM );
                    FND_MESSAGE.SET_TOKEN( 'CALLING_SEQUENCE', 'GetOldestOverdueReceipts' );
                    FND_MESSAGE.SET_TOKEN( 'DEBUG_INFO', l_debug_info );
                    APP_EXCEPTION.RAISE_EXCEPTION;
            ELSE
                    -- Do not need to set the token since it has been done in the
                    -- child process
                    RAISE;
            END IF;
    END;

END GetOldestOverdueReceipts;


------------------------------------------------------------------------
FUNCTION GetOldestImgOverdueReceipts(
                                 p_employee_id           IN NUMBER,
                                 p_hold_rct_overdue_days IN NUMBER) RETURN NUMBER IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_overdue_report_header_id             number;

/*
  Criteria for this cursor is:
  - all submitted reports
  - excludes bothpay child reports
  - receipts are grossly overdue
*/
------------------------------------------------------------
-- cursor for oldest overdue receipts
-- NOTE: need index on aerh.receipts_status/employee_id
------------------------------------------------------------
CURSOR c_oldest_overdue_receipts IS
  select aerh.report_header_id
  from   AP_EXPENSE_REPORT_HEADERS aerh
  where  (aerh.source <> 'NonValidatedWebExpense' or aerh.workflow_approved_flag is null)
  and    aerh.image_receipts_status is not null
  and    aerh.image_receipts_status in (AP_WEB_RECEIPTS_WF.C_REQUIRED, AP_WEB_RECEIPTS_WF.C_MISSING, AP_WEB_RECEIPTS_WF.C_OVERDUE, AP_WEB_RECEIPTS_WF.C_IN_TRANSIT, AP_WEB_RECEIPTS_WF.C_RESOLUTN)
  and    aerh.bothpay_parent_id is null
  and    trunc(sysdate) - (trunc(aerh.report_submitted_date) + p_hold_rct_overdue_days) > 0
  and    aerh.employee_id = p_employee_id
  order  by aerh.report_submitted_date asc;

BEGIN

    ------------------------------------------------------------
    l_debug_info := 'Get Oldest Overdue Receipts';
    fnd_file.put_line(fnd_file.log, l_debug_info);
    ------------------------------------------------------------
    open c_oldest_overdue_receipts;
    fetch c_oldest_overdue_receipts into l_overdue_report_header_id;
    close c_oldest_overdue_receipts;

    return l_overdue_report_header_id;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return null;
  WHEN OTHERS THEN
    BEGIN
            IF ( SQLCODE <> -20001 )
            THEN
                    FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_DEBUG' );
                    FND_MESSAGE.SET_TOKEN( 'ERROR', SQLERRM );
                    FND_MESSAGE.SET_TOKEN( 'CALLING_SEQUENCE', 'GetOldestImgOverdueReceipts' );
                    FND_MESSAGE.SET_TOKEN( 'DEBUG_INFO', l_debug_info );
                    APP_EXCEPTION.RAISE_EXCEPTION;
            ELSE
                    -- Do not need to set the token since it has been done in the
                    -- child process
                    RAISE;
            END IF;
    END;

END GetOldestImgOverdueReceipts;



/*
  Written by:
    Ron Langi

  Purpose:
    The purpose of this is to hold the current expense report if the employee has any grossly overdue receipts

    The following is the PL/SQL logic invoked by the Invoice Import program for the Hold All scenario:

    1. For each expense report that is 'Payment Held' or 'Pending Holds Clearance':

       If there is an expense report with grossly overdue receipts and it is currently not being held for it:
         a. Mark as 'Payment Held'
         b. Set the HOLDING_REPORT_HEADER_ID to the expense report with grossly overdue receipts
         c. Raise the Expense Held event

       If there is no expense report with grossly overdue receipts:
         a. Mark as 'Ready for Payment'
         b. Raise the Expense Released event if previously held


  Input:

  Output:

  Input/Output:

  Assumption:

*/
----------------------------------------------------------------------
PROCEDURE HoldAll IS
----------------------------------------------------------------------

  l_debug_info                  VARCHAR2(200);

  l_overdue_report_header_id	ap_expense_report_headers.report_header_id%TYPE;
  l_overdue_img_report_hdr_id	ap_expense_report_headers.report_header_id%TYPE;
  l_report_header_id		ap_expense_report_headers.report_header_id%TYPE;
  l_receipts_status		ap_expense_report_headers.receipts_status%TYPE;
  l_source			ap_expense_report_headers.source%TYPE;
  l_expense_status_code		ap_expense_report_headers.expense_status_code%TYPE;
  l_holding_report_header_id	ap_expense_report_headers.holding_report_header_id%TYPE;
  l_employee_id                 ap_expense_report_headers.employee_id%TYPE;
  l_hold_rct_overdue_days       ap_aud_rule_sets.hold_rct_overdue_days%TYPE;


/*
  Criteria for this cursor is:
  - all payment held or pending holds clearance
  - excludes bothpay child reports
  - submitted within Hold All scenario
*/
------------------------------------------------------------
-- cursor for Hold All scenario
------------------------------------------------------------
CURSOR c_hold_all IS
  select aerh.report_header_id,
         aerh.receipts_status,
         aerh.source,
         aerh.expense_status_code,
         aerh.holding_report_header_id,
         aerh.employee_id,
         rs.hold_rct_overdue_days
  from   AP_EXPENSE_REPORT_HEADERS aerh,
         AP_AUD_RULE_SETS rs,
         AP_AUD_RULE_ASSIGNMENTS_ALL rsa
  where  aerh.source = AP_WEB_RECEIPTS_WF.C_SELF_SERVICE_SOURCE
  and    aerh.expense_status_code in (AP_WEB_RECEIPTS_WF.C_PAYMENT_HELD, AP_WEB_RECEIPTS_WF.C_PENDING_HOLDS)
  and    aerh.bothpay_parent_id is null
  and    rsa.org_id = aerh.org_id
  and    rsa.rule_set_id = rs.rule_set_id
  and    rs.rule_set_type = C_HOLD_RULE
  and    TRUNC(aerh.report_submitted_date)
         BETWEEN TRUNC(NVL(rsa.START_DATE, aerh.report_submitted_date))
         AND     TRUNC(NVL(rsa.END_DATE, aerh.report_submitted_date))
  and    rs.HOLD_CODE = C_HOLD_ALL_CODE;

BEGIN

  ------------------------------------------------------------
  l_debug_info := 'Determine whether to place Holds';
  fnd_file.put_line(fnd_file.log, l_debug_info);
  ------------------------------------------------------------
  open c_hold_all;
  loop

    fetch c_hold_all into l_report_header_id,
                          l_receipts_status,
                          l_source,
                          l_expense_status_code,
                          l_holding_report_header_id,
                          l_employee_id,
                          l_hold_rct_overdue_days;
    exit when c_hold_all%NOTFOUND;

      ------------------------------------------------------------
      l_debug_info := 'Get oldest overdue receipts for employee: '||to_char(l_employee_id);
      fnd_file.put_line(fnd_file.log, l_debug_info);
      ------------------------------------------------------------
      l_overdue_report_header_id := GetOldestOverdueReceipts(l_employee_id, l_hold_rct_overdue_days);

      l_overdue_img_report_hdr_id := GetOldestImgOverdueReceipts(l_employee_id, l_hold_rct_overdue_days);

      ------------------------------------------------------------
      l_debug_info := 'Oldest overdue receipts is: '||to_char(l_overdue_report_header_id);
      fnd_file.put_line(fnd_file.log, l_debug_info);
      ------------------------------------------------------------

      ------------------------------------------------------------
      l_debug_info := 'Oldest overdue image receipts is: '||to_char(l_overdue_img_report_hdr_id);
      fnd_file.put_line(fnd_file.log, l_debug_info);
      ------------------------------------------------------------

      if (l_overdue_report_header_id is not null) then

        ------------------------------------------------------------
        l_debug_info := 'Current holding report is: '||to_char(l_holding_report_header_id);
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------

        if (l_overdue_report_header_id <> nvl(l_holding_report_header_id, 0)) then

          ------------------------------------------------------------
          l_debug_info := 'Place Hold';
          fnd_file.put_line(fnd_file.log, l_debug_info);
          ------------------------------------------------------------

          ------------------------------------------------------------
          l_debug_info := 'Set status Payment Held for: '||l_report_header_id||' and set holding_report_header_id to overdue report_header_id: '||l_overdue_report_header_id;
          fnd_file.put_line(fnd_file.log, l_debug_info);
          ------------------------------------------------------------
          PlaceHold(l_report_header_id, l_overdue_report_header_id);

          ------------------------------------------------------------
          l_debug_info := 'Raise hold placed event for: '||l_report_header_id;
          fnd_file.put_line(fnd_file.log, l_debug_info);
          ------------------------------------------------------------
          RaiseHeldEvent(l_report_header_id);

        end if;
      elsif (l_overdue_img_report_hdr_id is not null) then

        ------------------------------------------------------------
        l_debug_info := 'Current holding report is: '||to_char(l_holding_report_header_id);
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------

        if (l_overdue_img_report_hdr_id <> nvl(l_holding_report_header_id, 0)) then

          ------------------------------------------------------------
          l_debug_info := 'Place Hold';
          fnd_file.put_line(fnd_file.log, l_debug_info);
          ------------------------------------------------------------

          ------------------------------------------------------------
          l_debug_info := 'Set status Payment Held for: '||l_report_header_id||' and set holding_report_header_id to overdue report_header_id: '|| l_overdue_img_report_hdr_id;
          fnd_file.put_line(fnd_file.log, l_debug_info);
          ------------------------------------------------------------
          PlaceHold(l_report_header_id, l_overdue_img_report_hdr_id);

          ------------------------------------------------------------
          l_debug_info := 'Raise hold placed event for: '||l_report_header_id;
          fnd_file.put_line(fnd_file.log, l_debug_info);
          ------------------------------------------------------------
          RaiseHeldEvent(l_report_header_id);

        end if;

      else

        ------------------------------------------------------------
        l_debug_info := 'Mark Ready for Payment';
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------

        ------------------------------------------------------------
        l_debug_info := 'Set status Ready for Payment and clear holding_report_header_id for: '||l_report_header_id;
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------
        ReadyForPayment(l_report_header_id);

        ------------------------------------------------------------
        l_debug_info := 'If previously Held, then raise Released event';
        ------------------------------------------------------------
        if (l_expense_status_code = AP_WEB_RECEIPTS_WF.C_PAYMENT_HELD) then

          ------------------------------------------------------------
          l_debug_info := 'Raise hold released event for: '||l_report_header_id;
          fnd_file.put_line(fnd_file.log, l_debug_info);
          ------------------------------------------------------------
          RaiseReleasedEvent(l_report_header_id);

        end if;

      end if;

  end loop;
  close c_hold_all;

  EXCEPTION
    WHEN OTHERS THEN
    BEGIN
            IF ( SQLCODE <> -20001 )
            THEN
                    FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_DEBUG' );
                    FND_MESSAGE.SET_TOKEN( 'ERROR', SQLERRM );
                    FND_MESSAGE.SET_TOKEN( 'CALLING_SEQUENCE', 'HoldAll' );
                    FND_MESSAGE.SET_TOKEN( 'DEBUG_INFO', l_debug_info );
                    APP_EXCEPTION.RAISE_EXCEPTION;
            ELSE
                    -- Do not need to set the token since it has been done in the
                    -- child process
                    RAISE;
            END IF;
    END;


END HoldAll;


------------------------------------------------------------------------
FUNCTION IsCCReceiptsRequired(
                                 p_report_header_id           IN NUMBER) RETURN VARCHAR2 IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_is_cc_receipts_required     VARCHAR2(1);

BEGIN

    ------------------------------------------------------------
    l_debug_info := 'Check if Credit Card Receipts are required for: '||p_report_header_id;
    fnd_file.put_line(fnd_file.log, l_debug_info);
    ------------------------------------------------------------
    select 'Y'
    into   l_is_cc_receipts_required
    from   AP_EXPENSE_REPORT_HEADERS aerh
    where  aerh.report_header_id = p_report_header_id
    and
    exists
    (select 1
     from   ap_expense_report_lines aerl
     where  aerl.report_header_id = aerh.report_header_id
     and    aerl.credit_card_trx_id is not null
     and    nvl(aerl.receipt_required_flag, 'N') = 'Y'
     and    rownum = 1
    )
    and    rownum = 1;

    return l_is_cc_receipts_required;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return 'N';
  WHEN OTHERS THEN
    BEGIN
            IF ( SQLCODE <> -20001 )
            THEN
                    FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_DEBUG' );
                    FND_MESSAGE.SET_TOKEN( 'ERROR', SQLERRM );
                    FND_MESSAGE.SET_TOKEN( 'CALLING_SEQUENCE', 'IsCCReceiptsRequired' );
                    FND_MESSAGE.SET_TOKEN( 'DEBUG_INFO', l_debug_info );
                    APP_EXCEPTION.RAISE_EXCEPTION;
            ELSE
                    -- Do not need to set the token since it has been done in the
                    -- child process
                    RAISE;
            END IF;
    END;

END IsCCReceiptsRequired;


------------------------------------------------------------------------
FUNCTION IsCCImgReceiptsRequired(
                                 p_report_header_id           IN NUMBER) RETURN VARCHAR2 IS
------------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_is_cc_receipts_required     VARCHAR2(1);

BEGIN

    ------------------------------------------------------------
    l_debug_info := 'Check if Credit Card Receipts are required for: '||p_report_header_id;
    fnd_file.put_line(fnd_file.log, l_debug_info);
    ------------------------------------------------------------
    select 'Y'
    into   l_is_cc_receipts_required
    from   AP_EXPENSE_REPORT_HEADERS aerh
    where  aerh.report_header_id = p_report_header_id
    and
    exists
    (select 1
     from   ap_expense_report_lines aerl
     where  aerl.report_header_id = aerh.report_header_id
     and    aerl.credit_card_trx_id is not null
     and    nvl(aerl.image_receipt_required_flag, 'N') = 'Y'
     and    rownum = 1
    )
    and    rownum = 1;

    return l_is_cc_receipts_required;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return 'N';
  WHEN OTHERS THEN
    BEGIN
            IF ( SQLCODE <> -20001 )
            THEN
                    FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_DEBUG' );
                    FND_MESSAGE.SET_TOKEN( 'ERROR', SQLERRM );
                    FND_MESSAGE.SET_TOKEN( 'CALLING_SEQUENCE', 'IsCCReceiptsRequired' );
                    FND_MESSAGE.SET_TOKEN( 'DEBUG_INFO', l_debug_info );
                    APP_EXCEPTION.RAISE_EXCEPTION;
            ELSE
                    -- Do not need to set the token since it has been done in the
                    -- child process
                    RAISE;
            END IF;
    END;

END IsCCImgReceiptsRequired;


/*
  Written by:
    Ron Langi

  Purpose:
    The purpose of this is to hold the Both Pay Credit Card Expenses, if setup that way.

    The following shows the PL/SQL logic invoked by the Invoice Import program for the Both Pay Credit Card Expenses.

    1. For each expense report that is 'Payment Held' or 'Pending Holds Clearance':

       If the receipts are not required or have been received/waived and rule is not set to 'Always'
         a. Mark as 'Ready for Payment'

       If the rule is set to 'Never':
         a. Mark as 'Ready for Payment'

       If the rule is set to 'If Receipts Required' and the credit card receipts are not required or have been received/waived:
         a. Mark as 'Ready for Payment'

       If the rule is set to 'If Receipts Required' and the credit card receipts are required and have not been received/waived and the report is not already held:
         a. Mark as 'Payment Held'
         b. Set the HOLDING_REPORT_HEADER_ID to the parent expense report

       If the rule is set to 'Always' and the parent expense report's status is invoiced
         a. Mark as 'Ready for Payment'

       If the rule is set to 'Always' and the parent expense report's status is payment held
         a. Mark as 'Payment Held'
         b. Set the HOLDING_REPORT_HEADER_ID to the parent expense report


  Input:

  Output:

  Input/Output:

  Assumption:

*/
------------------------------------------------------------------------
PROCEDURE HoldBothPay IS
------------------------------------------------------------------------

  l_debug_info                  VARCHAR2(200);

  l_report_header_id		ap_expense_report_headers.report_header_id%TYPE;
  l_bothpay_parent_id		ap_expense_report_headers.bothpay_parent_id%TYPE;
  l_receipts_status		ap_expense_report_headers.receipts_status%TYPE;
  l_image_receipts_status	ap_expense_report_headers.receipts_status%TYPE;
  l_parent_status		ap_expense_report_headers.expense_status_code%TYPE;
  l_source			ap_expense_report_headers.source%TYPE;
  l_expense_status_code		ap_expense_report_headers.expense_status_code%TYPE;
  l_holding_report_header_id	ap_expense_report_headers.holding_report_header_id%TYPE;
  l_hold_rct_overdue_bp_cc_code	ap_aud_rule_sets.hold_rct_overdue_bp_cc_code%TYPE;

/*
  Criteria for this cursor is:
  - source is 'SelfService' or 'Both Pay'
  - all payment held or pending holds clearance
  - only bothpay child reports
  - submitted within Hold Each or All scenario
*/
------------------------------------------------------------
-- cursor for holds in Both Pay scenario
------------------------------------------------------------
CURSOR c_hold_bothpay IS
  select aerh.report_header_id,
         aerh.bothpay_parent_id,
         aerh2.receipts_status,
	 aerh2.image_receipts_status,
         aerh2.expense_status_code,
         aerh.source,
         aerh.expense_status_code,
         aerh.holding_report_header_id,
         rs.hold_rct_overdue_bp_cc_code
  from   AP_EXPENSE_REPORT_HEADERS aerh,
         AP_EXPENSE_REPORT_HEADERS aerh2,
         AP_AUD_RULE_SETS rs,
         AP_AUD_RULE_ASSIGNMENTS_ALL rsa
  where  aerh.source in (AP_WEB_RECEIPTS_WF.C_SELF_SERVICE_SOURCE, AP_WEB_RECEIPTS_WF.C_BOTHPAY)
  and    aerh.expense_status_code in (AP_WEB_RECEIPTS_WF.C_PAYMENT_HELD, AP_WEB_RECEIPTS_WF.C_PENDING_HOLDS)
  and    aerh.bothpay_parent_id is not null
  and    aerh2.report_header_id = aerh.bothpay_parent_id
  and    rsa.org_id = aerh2.org_id
  and    rsa.rule_set_id = rs.rule_set_id
  and    rs.rule_set_type = C_HOLD_RULE
  and    TRUNC(aerh2.report_submitted_date)
         BETWEEN TRUNC(NVL(rsa.START_DATE, aerh2.report_submitted_date))
         AND     TRUNC(NVL(rsa.END_DATE, aerh2.report_submitted_date))
  and    rs.HOLD_CODE in (C_HOLD_EACH_CODE, C_HOLD_ALL_CODE);


BEGIN

  ------------------------------------------------------------
  l_debug_info := 'Determine whether to place Holds';
  fnd_file.put_line(fnd_file.log, l_debug_info);
  ------------------------------------------------------------
  open c_hold_bothpay;
  loop

    fetch c_hold_bothpay into l_report_header_id,
                              l_bothpay_parent_id,
                              l_receipts_status,
			      l_image_receipts_status,
                              l_parent_status,
                              l_source,
                              l_expense_status_code,
                              l_holding_report_header_id,
                              l_hold_rct_overdue_bp_cc_code;
    exit when c_hold_bothpay%NOTFOUND;

      if (nvl(l_receipts_status, AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED) in (AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED, AP_WEB_RECEIPTS_WF.C_RECEIVED, AP_WEB_RECEIPTS_WF.C_RECEIVED_RESUBMITTED, AP_WEB_RECEIPTS_WF.C_WAIVED) and
          l_hold_rct_overdue_bp_cc_code <> C_HOLD_BP_ALWAYS) then
        ------------------------------------------------------------
        l_debug_info := 'Receipts not required or have been received/waived and not Hold Always';
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------

        ------------------------------------------------------------
        l_debug_info := 'Set status Ready for Payment for: '||l_report_header_id;
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------
        ReadyForPayment(l_report_header_id);

      elsif (nvl(l_image_receipts_status, AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED) in (AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED, AP_WEB_RECEIPTS_WF.C_RECEIVED, AP_WEB_RECEIPTS_WF.C_RECEIVED_RESUBMITTED, AP_WEB_RECEIPTS_WF.C_WAIVED) and
          l_hold_rct_overdue_bp_cc_code <> C_HOLD_BP_ALWAYS) then
        ------------------------------------------------------------
        l_debug_info := 'Receipts not required or have been received/waived and not Hold Always';
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------

        ------------------------------------------------------------
        l_debug_info := 'Set status Ready for Payment for: '||l_report_header_id;
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------
        ReadyForPayment(l_report_header_id);

      elsif (l_hold_rct_overdue_bp_cc_code = C_HOLD_BP_NEVER) then
        ------------------------------------------------------------
        l_debug_info := 'Never Hold BothPay';
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------

        ------------------------------------------------------------
        l_debug_info := 'Set status Ready for Payment for: '||l_report_header_id;
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------
        ReadyForPayment(l_report_header_id);

      elsif (l_hold_rct_overdue_bp_cc_code = C_HOLD_BP_REQUIRED) then
        ------------------------------------------------------------
        l_debug_info := 'Hold BothPay If Required';
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------

        if (IsCCReceiptsRequired(l_bothpay_parent_id) = 'Y' and
            nvl(l_receipts_status, AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED) not in (AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED, AP_WEB_RECEIPTS_WF.C_RECEIVED, AP_WEB_RECEIPTS_WF.C_RECEIVED_RESUBMITTED, AP_WEB_RECEIPTS_WF.C_WAIVED)) then

          if (l_expense_status_code <> AP_WEB_RECEIPTS_WF.C_PAYMENT_HELD) then

            ------------------------------------------------------------
            l_debug_info := 'Set status Payment Held for: '||l_report_header_id||' and set holding_report_header_id to parent report_header_id: '||l_bothpay_parent_id;
            fnd_file.put_line(fnd_file.log, l_debug_info);
            ------------------------------------------------------------
            PlaceHold(l_report_header_id, l_bothpay_parent_id);

          end if;

	elsif (IsCCImgReceiptsRequired(l_bothpay_parent_id) = 'Y' and
            nvl(l_image_receipts_status, AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED) not in (AP_WEB_RECEIPTS_WF.C_NOT_REQUIRED, AP_WEB_RECEIPTS_WF.C_RECEIVED, AP_WEB_RECEIPTS_WF.C_RECEIVED_RESUBMITTED, AP_WEB_RECEIPTS_WF.C_WAIVED)) then

          if (l_expense_status_code <> AP_WEB_RECEIPTS_WF.C_PAYMENT_HELD) then

            ------------------------------------------------------------
            l_debug_info := 'Set status Payment Held for: '||l_report_header_id||' and set holding_report_header_id to parent report_header_id: '||l_bothpay_parent_id;
            fnd_file.put_line(fnd_file.log, l_debug_info);
            ------------------------------------------------------------
            PlaceHold(l_report_header_id, l_bothpay_parent_id);

          end if;

        else

          ------------------------------------------------------------
          l_debug_info := 'Set status Ready for Payment Held for: '||l_report_header_id;
          fnd_file.put_line(fnd_file.log, l_debug_info);
          ------------------------------------------------------------
          ReadyForPayment(l_report_header_id);

        end if; -- Hold BothPay If Required

      elsif (l_hold_rct_overdue_bp_cc_code = C_HOLD_BP_ALWAYS) then
        ------------------------------------------------------------
        l_debug_info := 'Hold BothPay Always';
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------

        if (l_parent_status = AP_WEB_RECEIPTS_WF.C_PAYMENT_HELD) then

          ------------------------------------------------------------
          l_debug_info := 'Set status Payment Held for: '||l_report_header_id||' and set holding_report_header_id to parent report_header_id: '||l_bothpay_parent_id;
          fnd_file.put_line(fnd_file.log, l_debug_info);
          ------------------------------------------------------------
          PlaceHold(l_report_header_id, l_bothpay_parent_id);

        else

          ------------------------------------------------------------
          l_debug_info := 'Set status Ready for Payment Held for: '||l_report_header_id;
          fnd_file.put_line(fnd_file.log, l_debug_info);
          ------------------------------------------------------------
          ReadyForPayment(l_report_header_id);

        end if; -- Hold BothPay Always

      else

        ------------------------------------------------------------
        l_debug_info := 'I do not understand hold scenario: '||l_hold_rct_overdue_bp_cc_code;
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------

      end if;

  end loop;
  close c_hold_bothpay;


  EXCEPTION
    WHEN OTHERS THEN
    BEGIN
            IF ( SQLCODE <> -20001 )
            THEN
                    FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_DEBUG' );
                    FND_MESSAGE.SET_TOKEN( 'ERROR', SQLERRM );
                    FND_MESSAGE.SET_TOKEN( 'CALLING_SEQUENCE', 'HoldBothPay' );
                    FND_MESSAGE.SET_TOKEN( 'DEBUG_INFO', l_debug_info );
                    APP_EXCEPTION.RAISE_EXCEPTION;
            ELSE
                    -- Do not need to set the token since it has been done in the
                    -- child process
                    RAISE;
            END IF;
    END;

END HoldBothPay;


/*
  Written by:
    Ron Langi

  Purpose:
    The purpose of this is to release any holds on expense reports where:
    1. hold rules no longer apply
    2. hold was performed on an original report containing only Both Pay credit card trxns whose
       Both Pay report is invoiced.

    The following is the PL/SQL logic invoked by the Invoice Import program for non-existent holds :
       a. Mark as 'Ready for Payment'
       b. Clear the HOLDING_REPORT_HEADER_ID
       c. Raise the Expense Released event if previously held



  Input:

  Output:

  Input/Output:

  Assumption:

*/
------------------------------------------------------------------------
PROCEDURE ObsoleteHold IS
------------------------------------------------------------------------

  l_debug_info                  VARCHAR2(200);

  l_report_header_id		ap_expense_report_headers.report_header_id%TYPE;
  l_receipts_status		ap_expense_report_headers.receipts_status%TYPE;
  l_holding_report_header_id	ap_expense_report_headers.holding_report_header_id%TYPE;
  l_source			ap_expense_report_headers.source%TYPE;
  l_expense_status_code		ap_expense_report_headers.expense_status_code%TYPE;


/*
  Criteria for this cursor is:
  - source is 'SelfService' or 'Both Pay'
  - all payment held or pending holds clearance
  - not submitted within Hold Each or All scenario
*/
------------------------------------------------------------
-- cursor for obsolete Holds
------------------------------------------------------------
CURSOR c_obsolete_holds IS
  select aerh.report_header_id,
         aerh.source,
         aerh.expense_status_code
  from   AP_EXPENSE_REPORT_HEADERS aerh
  where  aerh.source in (AP_WEB_RECEIPTS_WF.C_SELF_SERVICE_SOURCE, AP_WEB_RECEIPTS_WF.C_BOTHPAY)
  and    aerh.expense_status_code in (AP_WEB_RECEIPTS_WF.C_PAYMENT_HELD, AP_WEB_RECEIPTS_WF.C_PENDING_HOLDS)
  and
  not exists
  (select 1
   from  AP_AUD_RULE_SETS rs,
         AP_AUD_RULE_ASSIGNMENTS_ALL rsa
   where rsa.org_id = aerh.org_id
   and   rsa.rule_set_id = rs.rule_set_id
   and   rs.rule_set_type = C_HOLD_RULE
   and   TRUNC(aerh.report_submitted_date)
         BETWEEN TRUNC(NVL(rsa.START_DATE, aerh.report_submitted_date))
         AND     TRUNC(NVL(rsa.END_DATE, aerh.report_submitted_date))
   and   rownum = 1
  );

/*
  Criteria for this cursor is:
  - source is 'SelfService'
  - all payment held or pending holds clearance
  - original reports containing only Both Pay credit card trxns
*/
------------------------------------------------------------
-- cursor for obsolete Both Pay Holds
------------------------------------------------------------
CURSOR c_obsolete_bothpay_holds IS
  select aerh.report_header_id,
         aerh.expense_status_code
  from   AP_EXPENSE_REPORT_HEADERS aerh
  where  aerh.source = AP_WEB_RECEIPTS_WF.C_SELF_SERVICE_SOURCE
  and    aerh.expense_status_code in (AP_WEB_RECEIPTS_WF.C_PAYMENT_HELD, AP_WEB_RECEIPTS_WF.C_PENDING_HOLDS)
  and    aerh.bothpay_parent_id is null
  and
  not exists
  (select 1
   from   ap_expense_report_lines aerl
   where  aerl.report_header_id = aerh.report_header_id
   and    aerl.credit_card_trx_id IS NULL
   and    rownum = 1)
  and
  exists
  (select 1
   from   ap_expense_report_headers aerh2
   where  aerh2.bothpay_parent_id = aerh.report_header_id
   and    aerh2.expense_status_code = AP_WEB_RECEIPTS_WF.C_INVOICED
   and    rownum = 1);


BEGIN

  ------------------------------------------------------------
  l_debug_info := 'Obsolete Holds';
  fnd_file.put_line(fnd_file.log, l_debug_info);
  ------------------------------------------------------------
  open c_obsolete_holds;
  loop

    fetch c_obsolete_holds into l_report_header_id,
                                l_source,
                                l_expense_status_code;
    exit when c_obsolete_holds%NOTFOUND;

      ------------------------------------------------------------
      l_debug_info := 'Mark Ready for Payment';
      fnd_file.put_line(fnd_file.log, l_debug_info);
      ------------------------------------------------------------

      ------------------------------------------------------------
      l_debug_info := 'Set status Ready for Payment and clear holding_report_header_id for: '||l_report_header_id;
      fnd_file.put_line(fnd_file.log, l_debug_info);
      ------------------------------------------------------------
      ReadyForPayment(l_report_header_id);

      ------------------------------------------------------------
      l_debug_info := 'If not Both Pay child and previously Held, then raise Released event';
      ------------------------------------------------------------
      if (l_source <> AP_WEB_RECEIPTS_WF.C_BOTHPAY and
          l_expense_status_code = AP_WEB_RECEIPTS_WF.C_PAYMENT_HELD) then

        ------------------------------------------------------------
        l_debug_info := 'Raise hold released event for: '||l_report_header_id;
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------
        RaiseReleasedEvent(l_report_header_id);

      end if;

  end loop;
  close c_obsolete_holds;


  ------------------------------------------------------------
  l_debug_info := 'Obsolete Both Pay Holds';
  fnd_file.put_line(fnd_file.log, l_debug_info);
  ------------------------------------------------------------
  open c_obsolete_bothpay_holds;
  loop

    fetch c_obsolete_bothpay_holds into l_report_header_id,
                                        l_expense_status_code;
    exit when c_obsolete_bothpay_holds%NOTFOUND;

      ------------------------------------------------------------
      l_debug_info := 'Mark Ready for Payment';
      fnd_file.put_line(fnd_file.log, l_debug_info);
      ------------------------------------------------------------

      ------------------------------------------------------------
      l_debug_info := 'Set status Ready for Payment and clear holding_report_header_id for: '||l_report_header_id;
      fnd_file.put_line(fnd_file.log, l_debug_info);
      ------------------------------------------------------------
      ReadyForPayment(l_report_header_id);

      ------------------------------------------------------------
      l_debug_info := 'If previously Held, then raise Released event';
      ------------------------------------------------------------
      if (l_expense_status_code = AP_WEB_RECEIPTS_WF.C_PAYMENT_HELD) then

        ------------------------------------------------------------
        l_debug_info := 'Raise hold released event for: '||l_report_header_id;
        fnd_file.put_line(fnd_file.log, l_debug_info);
        ------------------------------------------------------------
        RaiseReleasedEvent(l_report_header_id);

      end if;

  end loop;
  close c_obsolete_bothpay_holds;


  EXCEPTION
    WHEN OTHERS THEN
    BEGIN
            IF ( SQLCODE <> -20001 )
            THEN
                    FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_DEBUG' );
                    FND_MESSAGE.SET_TOKEN( 'ERROR', SQLERRM );
                    FND_MESSAGE.SET_TOKEN( 'CALLING_SEQUENCE', 'ObsoleteHold' );
                    FND_MESSAGE.SET_TOKEN( 'DEBUG_INFO', l_debug_info );
                    APP_EXCEPTION.RAISE_EXCEPTION;
            ELSE
                    -- Do not need to set the token since it has been done in the
                    -- child process
                    RAISE;
            END IF;
    END;

END ObsoleteHold;





END AP_WEB_HOLDS_WF;

/
