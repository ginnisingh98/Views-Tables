--------------------------------------------------------
--  DDL for Package Body AP_WEB_CREDIT_CARD_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_CREDIT_CARD_WF" AS
/* $Header: apwccwfb.pls 120.55.12010000.6 2009/10/09 07:36:06 sodash ship $ */

/**** TEMP ***/
th_bgcolor varchar2(9) := '"#cccc99"';
th_fontcolor varchar2(9) := '"#336699"';
th_fontface varchar2(80) := '"Arial, Helvetica, Geneva, sans-serif"';
td_bgcolor varchar2(9) := '"#f7f7e7"';
td_fontcolor varchar2(7) := '"black"';
td_fontface varchar2(80) := '"Arial, Helvetica, Geneva, sans-serif"';
/**** TEMP ***/


indent_start varchar2(200) := '<table style="{background-color:#ffffff}" width="100%" border="0" cellpadding="0" cellspacing="0"><tr><td width="20"></td><td>';
indent_end varchar2(200) := '</td></tr></table>';

----------------------------------
--.OraTableTitle {font-family:Arial,Helvetica,Geneva,sans-serif;font-size:13pt;background-color:#ffffff;color:#336699}
----------------------------------
table_title_start  varchar2(200) := '<br><font style="{font-family:Arial,Helvetica,Geneva,sans-serif;font-size:11pt;font-weight:bold;background-color:#ffffff;color:#336699}">';
table_title_end  varchar2(200) := '</font><br><table width="100%"><tr bgcolor="#cccc99"><td height="1"></td></tr><tr bgcolor="#ffffff"><td height="2"></td></tr></table>';

----------------------------------
--.OraTable {background-color:#999966}
----------------------------------
table_start varchar2(200) := '<table style="{background-color:#999966}" width="100%" border="0" cellpadding="3" cellspacing="1">';
table_end varchar2(15) := '</table>';

tr_start varchar2(80) := '<tr bgcolor="#cccc99">';
tr_end varchar2(15) := '</tr>';

----------------------------------
--.OraTableColumnHeaderIconButton {font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt;font-weight:bold;background-color:#cccc99;color:#336699;vertical-align:bottom;text-align:center}
----------------------------------
th_select varchar2(200) := '<td style="{font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt;font-weight:bold;background-color:#cccc99;color:#336699;vertical-align:bottom;text-align:center}">';

----------------------------------
-- .OraTableColumnHeader {font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt;font-weight:bold;text-align:left;background-color:#cccc99;color:#336699;vertical-align:bottom}
----------------------------------
th_text varchar2(200) := '<td style="{font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt;font-weight:bold;text-align:left;background-color:#cccc99;color:#336699;vertical-align:bottom}">';

----------------------------------
-- .OraTableColumnHeaderNumber {font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt;font-weight:bold;background-color:#cccc99;color:#336699;vertical-align:bottom;text-align:right}
----------------------------------
th_number varchar2(200) := '<td style="{font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt;font-weight:bold;background-color:#cccc99;color:#336699;vertical-align:bottom;text-align:right}">';

----------------------------------
-- .OraTableCellSelect {font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt;text-align:center;background-color:#f7f7e7;color:#000000;vertical-align:baseline}
----------------------------------
td_select varchar2(200) := '<td style="{font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt;text-align:center;background-color:#f7f7e7;color:#000000;vertical-align:baseline}">';

----------------------------------
-- .OraTableCellText {font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt;background-color:#f7f7e7;color:#000000;vertical-align:baseline}
----------------------------------
td_text varchar2(200) := '<td style="{font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt;background-color:#f7f7e7;color:#000000;vertical-align:baseline}">';

----------------------------------
-- .OraTableCellNumber {font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt;text-align:right;background-color:#f7f7e7;color:#000000;vertical-align:baseline}
----------------------------------
td_number varchar2(200) := '<td style="{font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt;text-align:right;background-color:#f7f7e7;color:#000000;vertical-align:baseline}">';

td_start varchar2(10) := '<td>';
td_end varchar2(10) := '</td>';

------------------------
-- Constants definition
------------------------


---------------------------------------------------------------------------
FUNCTION GetNextCardNotificationID RETURN VARCHAR2 IS
---------------------------------------------------------------------------
l_itemKey	VARCHAR2(100);
BEGIN
    SELECT to_char(ap_cCard_Notification_ID_s.nextval)
    INTO   l_itemKey
    FROM   sys.dual;
    return l_itemKey;
EXCEPTION
    WHEN OTHERS THEN
	AP_WEB_DB_UTIL_PKG.RaiseException('GetNextCardNotificationID');
END GetNextCardNotificationID;

---------------------------------------------------------------------------
PROCEDURE sendPaymentNotification(p_checkNumber	IN NUMBER,
			   	  p_employeeId        IN NUMBER,
                                  p_paymentCurrency   IN VARCHAR2,
                                  p_invoiceNumber     IN VARCHAR2,
       			          p_paidAmount	      IN NUMBER,
                                  p_paymentTo         IN VARCHAR2,
                                  p_paymentMethod     IN VARCHAR2,
                                  p_account           IN VARCHAR2,
                                  p_bankName          IN VARCHAR2,
                                  p_cardIssuer        IN VARCHAR2,
                                  p_paymentDate       IN VARCHAR2,
                                  p_deferred          IN BOOLEAN)
---------------------------------------------------------------------------
IS
  l_itemType	        VARCHAR2(100)	:= 'APCCARD';
  l_itemKey	        VARCHAR2(100);
  l_employeeName	wf_users.name%type;
  l_employeeDisplayName	wf_users.display_name%type;
  l_threshold           number := wf_engine.threshold;
  l_debugInfo		VARCHAR2(200);
  l_account             IBY_EXT_BANK_ACCOUNTS.BANK_ACCOUNT_NUM%TYPE := NULL;
  l_invoiceNum          AP_EXPENSE_REPORT_HEADERS_ALL.INVOICE_NUM%TYPE;
  l_process_created     VARCHAR2(1);

BEGIN

  ------------------------------------------------------------
  l_debugInfo := 'Set WF threshold to defer this WF process';
  ------------------------------------------------------------
  if (p_deferred) then
      wf_engine.threshold := -1;
  end if;

  l_itemKey := GetNextCardNotificationID;

  /* Bug 2301574: Need to mask the credit card number */
  l_account := '************' || substr(p_account,-4);

  ------------------------------------------------------------
  l_debugInfo := 'Get Name Info Associated With employee_Id';
  ------------------------------------------------------------
  WF_DIRECTORY.GetUserName('PER',
			   p_employeeId,
			   l_employeeName,
			   l_employeeDisplayName);

    --------------------------------------------------
    l_debugInfo := 'Calling WorkFlow Create Process';
    --------------------------------------------------

  l_process_created := 'N';
  if (p_paymentTo is not null AND p_paymentTo = c_paymentToCardIssuer) then
      WF_ENGINE.CreateProcess(l_itemType,  l_itemKey, 'PAYMENT_TO_CARD_ISSUER');
      l_process_created := 'Y';
  elsif (p_paymentTo is not null AND p_paymentTo = c_voidPayment) then
      WF_ENGINE.CreateProcess(l_itemType,  l_itemKey, 'VOID_PAYMENT_PROCESS');
      l_process_created := 'Y';
  elsif (p_paymentMethod = c_directDeposit and p_paidAmount<>0) then
      WF_ENGINE.CreateProcess(l_itemType,  l_itemKey, 'PAYMENT_TO_EMPLOYEE');
      l_process_created := 'Y';
  elsif(p_paidAmount<>0) then
      WF_ENGINE.CreateProcess(l_itemType,  l_itemKey, 'PAYMENT_TO_EMP_BY_CHECK');
      l_process_created := 'Y';
  end if;

  -- 8412820 : Attribute 'EXPENSE_REPORT_NUMBER' does not exist for item
  if nvl(l_process_created,'N') = 'Y' then
  ----------------------------------------------------------
  l_debugInfo := 'Set WF EXPENSE_REPORT_NUMBER Item Attribute';
  ----------------------------------------------------------
  /* Bug 4102991 : The notification of payment to the credit card
   * provider should not use the .1 invoice number.
   */

  IF (p_paymentTo is not null AND p_paymentTo = c_paymentToCardIssuer) then

     BEGIN
          SELECT aerh2.invoice_num
          INTO   l_invoiceNum
          FROM   ap_expense_report_headers_all aerh1,
                 ap_expense_report_headers_all aerh2
          WHERE  aerh1.bothpay_parent_id = aerh2.report_header_id
          AND    aerh1.invoice_num = p_invoiceNumber
          AND    aerh1.source = 'Both Pay';

     EXCEPTION WHEN NO_DATA_FOUND THEN
          l_invoiceNum := p_invoiceNumber;
     END;

   ELSE
          l_invoiceNum := p_invoiceNumber;

   END IF;

   WF_ENGINE.SetItemAttrText(l_itemType,
			     l_itemKey,
			     'EXPENSE_REPORT_NUMBER',
			     l_invoiceNum);
  ----------------------------------------------------------
  l_debugInfo := 'Set WF Amount Item Attribute';
  ----------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'AMOUNT',
			      to_char(p_paidAmount, FND_CURRENCY.Get_Format_Mask(p_paymentCurrency,22)) || ' ' || p_paymentCurrency);

  ----------------------------------------------------------
  l_debugInfo := 'Set CURRENCY Item Attribute';
  ----------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'CURRENCY',
			      p_paymentCurrency);

  ----------------------------------------------------------
  l_debugInfo := 'Set the Owner of Workflow Process.';
  ----------------------------------------------------------
  WF_ENGINE.SetItemOwner(l_itemType, l_itemKey, l_employeeName);

  ------------------------------------------------------
  l_debugInfo := 'Set WF EMPLOYEE_NAME Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'EMPLOYEE_NAME',
			      l_employeeName);

  --------------------------------------------------------------
  l_debugInfo := 'Set WF EMPLOYEE_DISPLAY_NAME Item Attribute';
  --------------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'EMP_DISPLAY_NAME',
			      l_employeeDisplayName);

  ------------------------------------------------------
  l_debugInfo := 'Set WF Employee_ID Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrNumber(l_itemType,
                              l_itemKey,
                              'EMPLOYEE_ID',
                              p_employeeId);
   ------------------------------------------------------
   l_debugInfo := 'Set WF CHECK_NUMBER Item Attribute';
   ------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'CHECK_NUMBER',
			      to_char(p_checkNumber));


  if (p_paymentTo is not null AND p_paymentTo = c_paymentToCardIssuer) then
       ------------------------------------------------------
      l_debugInfo := 'Set WF CREDIT_CARD_COMPANY Item Attribute';
       ------------------------------------------------------
      WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'CREDIT_CARD_COMPANY',
			      p_cardIssuer);
       ------------------------------------------------------
      l_debugInfo := 'Set WF PAYMENT_DATE Item Attribute';
       ------------------------------------------------------
      WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'PAYMENT_DATE',
			      p_paymentDate);
  else -- payment to employee
      if (p_paymentMethod = c_directDeposit) then
          ------------------------------------------------------
          l_debugInfo := 'Set WF BANK_ACCOUNT Item Attribute';
          ------------------------------------------------------
          WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'BANK_ACCOUNT',
			      l_account);

          ------------------------------------------------------
          l_debugInfo := 'Set WF BANK_NAME Item Attribute';
          ------------------------------------------------------
          WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'BANK_NAME',
			      p_bankName);
      end if; -- p_paymentMethod = c_directDeposit
  end if;


  BEGIN
    ------------------------------------------------------------
    l_debugInfo := 'Start the Expense Report Workflow Process';
    ------------------------------------------------------------
    WF_ENGINE.StartProcess(l_itemType,
			   l_itemKey);

  EXCEPTION
    WHEN OTHERS THEN
    wf_engine.threshold := l_threshold;
    Wf_Core.Context('AP_WEB_CREDIT_CARD_WF', 'sendNotification',
                     l_itemType, l_itemKey, to_char(0), l_debugInfo);
    raise;
  END;

  wf_engine.threshold := l_threshold;

  end if; -- nvl(l_process_created,'N') = 'Y'

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'sendPaymentNotification');
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'p_checkNumber = ' || to_char(p_checkNumber) ||
               ', p_employeeId = '|| to_char(p_employeeId) ||
               ', p_paymentCurrency = ' || p_paymentCurrency ||
               ', p_invoiceNumber = ' || p_invoiceNumber ||
               ', p_paymentTo = ' || p_paymentTo ||
               ', p_paymentMethod = ' || p_paymentMethod ||
               ', p_account = ' || l_account ||
               ', p_bankName = ' || p_bankName ||
               ', p_cardIssuer = ' || p_cardIssuer ||
               ', p_paymentDate = ' || p_paymentDate);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debugInfo);
      RAISE_APPLICATION_ERROR(-20010, fnd_message.get);
    ELSE
      -- Do not need to set the token since it has been done in the
      -- child process
      RAISE;
   END IF;
END sendPaymentNotification;


PROCEDURE sendUnsubmittedChargesNote(p_employeeId       IN NUMBER,
			   	  p_Amount	      IN NUMBER,
                           	  p_currency          IN VARCHAR2,
                                  p_cardIssuer        IN VARCHAR2,
                                  p_date1             IN VARCHAR2,
                           	  p_date2             IN VARCHAR2,
				  p_charge_type	      IN VARCHAR2,
				  p_send_notifications  IN VARCHAR2 DEFAULT 'EM',
				  p_min_amount    IN NUMBER DEFAULT null)   -- Bug 6886855 (sodash) setting the wf attribute MIN_AMOUNT

IS
  l_itemType		VARCHAR2(100)	:= 'APCCARD';
  l_itemKey		VARCHAR2(100);
  l_employeeName        wf_users.name%type;
  l_employeeID		NUMBER;
  l_employeeDisplayName	wf_users.display_name%type;
  l_managerId           NUMBER;
  l_managerName		wf_users.name%type;
  l_managerDisplayName	wf_users.display_name%type;
  l_currency    	AP_WEB_DB_EXPRPT_PKG.expHdr_defaultCurrCode;
  l_debugInfo		VARCHAR2(200);
  l_cardProgramID 	AP_WEB_DB_CCARD_PKG.cardProgs_cardProgID;
  l_orgId       	number;
  l_instructions		Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_mgr_instructions		Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;

BEGIN
  ------------------------------------------------------------
  l_debugInfo := 'Get Name Info Associated With employee_Id';
  ------------------------------------------------------------
  WF_DIRECTORY.GetUserName('PER', p_employeeId, l_employeeName, l_employeeDisplayName);

  /* Bug 3877939: If a record does not exist in WF_Directory, then
   *              the program should not error out.
   */
  IF l_employeeName IS NULL THEN
     RETURN;
  END IF;
  ------------------------------------------------------------
  l_debugInfo := 'Get manager_Id';
  ------------------------------------------------------------
  AP_WEB_EXPENSE_WF.GetManager(p_employeeId, l_managerId);

  ------------------------------------------------------------
  l_debugInfo := 'Get Name Info Associated With managerId';
  ------------------------------------------------------------
  WF_DIRECTORY.GetUserName('PER', l_managerId, l_managerName, l_managerDisplayName);

  ---------------------------------------------------------
  l_debugInfo := ' Generate new key';
  ---------------------------------------------------------
    l_itemKey := GetNextCardNotificationID;

    --------------------------------------------------
    l_debugInfo := 'Calling WorkFlow Create Process';
    --------------------------------------------------
   WF_ENGINE.CreateProcess(l_itemType,  l_itemKey, 'UNSUBMITTED_CHARGES');

  ----------------------------------------------------------
  l_debugInfo := 'Set WF Amount Item Attribute';
  ----------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'AMOUNT',
			    to_char(p_Amount, FND_CURRENCY.Get_Format_Mask(p_currency,22)) || ' ' || p_currency);

  ----------------------------------------------------------
  l_debugInfo := 'Set CURRENCY Item Attribute';
  ----------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'CURRENCY',p_currency);

  ----------------------------------------------------------
  l_debugInfo := 'Set the Owner of Workflow Process.';
  ----------------------------------------------------------
  WF_ENGINE.SetItemOwner(l_itemType, l_itemKey, l_employeeName);

  ------------------------------------------------------
  l_debugInfo := 'Set WF EMPLOYEE_ID Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrNumber(l_itemType, l_itemKey, 'EMPLOYEE_ID', p_employeeId);

  ------------------------------------------------------
  l_debugInfo := 'Set WF EMPLOYEE_NAME Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'EMPLOYEE_NAME', l_employeeName);

  --------------------------------------------------------------
  l_debugInfo := 'Set WF EMPLOYEE_DISPLAY_NAME Item Attribute';
  --------------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'EMP_DISPLAY_NAME', l_employeeDisplayName);

  ------------------------------------------------------
  l_debugInfo := 'Set WF MANAGER_NAME Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MANAGER_NAME', l_managerName);

  ------------------------------------------------------
   l_debugInfo := 'Set WF CREDIT_CARD_COMPANY Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'CREDIT_CARD_COMPANY', p_cardIssuer);

  --------------------------------------------------------------
  l_debugInfo := 'Set WF CREDIT_CARD_COMPANY Item Attribute';
  --------------------------------------------------------------
  IF (NOT AP_WEB_DB_CCARD_PKG.GetCardProgramID(p_cardIssuer,
						 l_cardProgramID ) ) THEN
	NULL;
  END IF;

  WF_ENGINE.SetItemAttrNumber(l_itemType, l_itemKey, 'CARD_PROG_ID', l_cardProgramID);

  --------------------------------------------------------------
  l_debugInfo := 'Get and Set ORG_ID attribute ';
  --------------------------------------------------------------
  --FND_PROFILE.GET('ORG_ID' , l_orgId );
  -- 8990469 : MOAC
  l_orgId := mo_global.get_current_org_id;
  if l_orgId is null then
    FND_PROFILE.GET('ORG_ID' , l_orgId );
  end if;

  WF_ENGINE.SetItemAttrNumber(l_itemType, l_itemKey, 'ORG_ID', l_orgId);

  ------------------------------------------------------
  l_debugInfo := 'Set WF DATE1 Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'DATE1', p_date1);

  ------------------------------------------------------
  l_debugInfo := 'Set WF DATE2 Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'DATE2', p_date2);

  ------------------------------------------------------
  l_debugInfo := 'Set Charge Type Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'CHARGE_TYPE', p_charge_type);

  -- Bug 6886855 (sodash) setting the attribute MIN_AMOUNT
    ------------------------------------------------------
  l_debugInfo := 'Set WF MIN_AMOUNT Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrNumber(l_itemType, l_itemKey, 'MIN_AMOUNT', p_min_amount);

  ------------------------------------------------------
  l_debugInfo := 'Set Send Notifications Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.setItemAttrText(l_itemType, l_itemKey, 'SEND_NOTIFICATIONS_PARAM',p_send_notifications);  -- Bug 6026927


  FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_FIRST_DUNNING');
  l_instructions := FND_MESSAGE.GET;

  FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_MGR_FIRST_INSTR');
  FND_MESSAGE.SET_TOKEN('EMPLOYEE_NAME', l_employeeDisplayName);
  l_mgr_instructions := FND_MESSAGE.GET;

  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'DUNNING_INSTR', l_instructions);
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MANAGER_INSTR', l_mgr_instructions);

  --------------------------------------------------------------
  l_debugInfo := 'Set NUM_RECORDS value ';
  --------------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType,
			    l_itemKey,
			    'RECORDS_INSTR',
                 'plsql:AP_WEB_CREDIT_CARD_WF.getNumofUnsubmittedRecords/'||l_itemType||':'||l_itemKey);


  --------------------------------------------------------------
  l_debugInfo := 'Set LIST value ';
  --------------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType,
                              l_itemKey,
                              'LIST',
                 'plsqlclob:AP_WEB_CREDIT_CARD_WF.genUnsubmittedClobList/'||l_itemType||':'||l_itemKey);

WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'OIE_LIST',
          'JSP:/OA_HTML/OA.jsp?akRegionCode=UnSubmittedChargesRN&akRegionApplicationId=200&itemKey='||l_itemKey||'&mgrList='||'N'||'&orgId='||l_orgId);

  WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'MGR_LIST',
          'JSP:/OA_HTML/OA.jsp?akRegionCode=UnSubmittedChargesRN&akRegionApplicationId=200&itemKey='||l_itemKey||'&mgrList='||'Y'||'&name='||l_employeeDisplayName||'&orgId='||l_orgId);

  BEGIN
    ------------------------------------------------------------
    l_debugInfo := 'Start the Expense Report Workflow Process';
    ------------------------------------------------------------
    WF_ENGINE.StartProcess(l_itemType, l_itemKey);

  EXCEPTION
    WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_CREDIT_CARD_WF', 'sendNotification',
                     l_itemType, l_itemKey, to_char(0), l_debugInfo);
    raise;
  END;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'sendUnsubmittedChargesNote');
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'p_employeeId  = ' || to_char(p_employeeId) ||
               ', p_Amount = ' || to_char(p_Amount) ||
               ', p_currency = ' || p_currency ||
               ', p_cardIssuer = ' || p_cardIssuer ||
               ', p_date1 = ' || p_date1 ||
               ', p_date2 = ' || p_date2);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debugInfo);
      RAISE_APPLICATION_ERROR(-20010, fnd_message.get);
    ELSE
      -- Do not need to set the token since it has been done in the
      -- child process
      RAISE;
   END IF;
END sendUnsubmittedChargesNote;

/* AMulya Mishra:Notification Escalation Project:
                 Passed 4 new parameters from report.
*/

PROCEDURE SendDunningNotifications(p_employeeId       	IN NUMBER,
                                  p_cardProgramId    	IN AP_CARD_PROGRAMS.card_program_id%TYPE,
			   	  p_Amount	      	IN NUMBER,
                           	  p_currency          	IN VARCHAR2,
			   	  p_min_bucket 		IN NUMBER,
			   	  p_max_bucket   	IN NUMBER,
				  p_dunning_number 	IN NUMBER,
			          p_send_notifications IN VARCHAR2,
			          p_esc_level          IN NUMBER,
				  p_grace_days         IN NUMBER,
				  p_manager_notified   IN VARCHAR2)
IS
  l_itemType			VARCHAR2(100)	:= 'APCCARD';
  l_itemKey			VARCHAR2(100);
  l_employeeId  		number;
  l_employeeName		wf_users.name%type;
  l_managerId           	NUMBER;
  l_managerName			wf_users.name%type;
  l_managerDisplayName		wf_users.display_name%type;
  l_employeeDisplayName		wf_users.display_name%type;
  l_currency    		AP_WEB_DB_EXPRPT_PKG.expHdr_defaultCurrCode;
  l_cardProgramName 		AP_WEB_DB_CCARD_PKG.cardProgs_cardProgName;
  l_orgId       		number;
  l_debugInfo			VARCHAR2(200);
  l_instructions		Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_mgr_instructions		Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_plus_sign			VARCHAR2(1) := '+';

--Amulya Mishra : Notification Esclation Project

  l_add_instructions  Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_mgmt_instructions Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_notes             Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_aging_oustanding  NUMBER;
  l_total_outstanding NUMBER;
  l_esc_managerName   wf_users.name%type;
  l_esc_managerId     NUMBER;
  l_total_amount      NUMBER;
  i                   NUMBER := 1;
  l_job_level         NUMBER;
  l_prev_job_level    NUMBER;
  l_sup1_manager_name wf_users.name%type;
  l_sup1_manager_displaye_name wf_users.name%type;
  l_sup2_manager_id   NUMBER;
  l_sup2_manager_name wf_users.name%type;
  l_sup2_manager_display_name wf_users.name%type;
  l_temp_employee_id  NUMBER;
  l_orig_manager_id   NUMBER;

  l_prev_manager_id   NUMBER;
  l_prev_manager_name wf_users.name%type;
  l_prev_manager_display_name wf_users.name%type;


  l_mgr_esc_instructions      Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_mgr_esc_mgmt_instructions Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_mgr_esc_add_instructions  Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;

  l_next_mgr_esc_instr VARCHAR2(2000);
  l_next_mgr_esc_mgmt_instr VARCHAR2(2000);
  l_next_mgr_esc_add_instr  VARCHAR2(2000);

  l_mgr_esc_amount       NUMBER;
  l_next_mgr_esc_amount  NUMBER;

  is_null_job_level       boolean := FALSE;

  l_next_manager_id      NUMBER;
  l_next_mgr_job_level   NUMBER;
  l_sup2_manager_job_level NUMBER;


--Amulya Mishra : Notification Esclation

BEGIN

  ------------------------------------------------------------
  l_debugInfo := 'Get Name Info Associated With employee_Id';
  ------------------------------------------------------------
  WF_DIRECTORY.GetUserName('PER', p_employeeId, l_employeeName, l_employeeDisplayName);

  /* Bug 3877939: If a record does not exist in WF_Directory, then
   *              the program should not error out.
   */
  IF l_employeeName IS NULL THEN
     RETURN;
  END IF;
  ------------------------------------------------------------
  l_debugInfo := 'Get manager_Id';
  ------------------------------------------------------------
  AP_WEB_EXPENSE_WF.GetManager(p_employeeId, l_managerId);

  ------------------------------------------------------------
  l_debugInfo := 'Get Name Info Associated With managerId';
  ------------------------------------------------------------
  WF_DIRECTORY.GetUserName('PER', l_managerId, l_managerName, l_managerDisplayName);

  ---------------------------------------------------------
  l_debugInfo := ' Generate new key';
  ---------------------------------------------------------
    l_itemKey := GetNextCardNotificationID;

  --------------------------------------------------
  l_debugInfo := 'Calling WorkFlow Create Process';
  --------------------------------------------------
  WF_ENGINE.CreateProcess(l_itemType,  l_itemKey, 'DUNNING_NOTIFICATIONS');

  ----------------------------------------------------------
  l_debugInfo := 'Set the Owner of Workflow Process.';
  ----------------------------------------------------------
  WF_ENGINE.SetItemOwner(l_itemType, l_itemKey, l_employeeName);

  ----------------------------------------------------------
  l_debugInfo := 'Set the Subject';
  ----------------------------------------------------------
  if(p_dunning_number = 1) then
      	FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_FIRST_DUNNING');
	l_instructions := FND_MESSAGE.GET;
      	FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_MGR_FIRST_INSTR');
	FND_MESSAGE.SET_TOKEN('EMPLOYEE_NAME', l_employeeDisplayName);
	l_mgr_instructions := FND_MESSAGE.GET;


      	FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_MGR_ESC_INSTR_DUNNING1');
        l_mgr_esc_instructions := FND_MESSAGE.GET;


  elsif(p_dunning_number = 2) then
      	FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_SECOND_DUNNING');
	l_instructions := FND_MESSAGE.GET;
      	FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_MGR_SECOND_INSTR');
	FND_MESSAGE.SET_TOKEN('EMPLOYEE_NAME', l_employeeDisplayName);
	l_mgr_instructions := FND_MESSAGE.GET;


       	FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_MGR_ESC_INSTR_DUNNING2');
	l_mgr_esc_instructions := FND_MESSAGE.GET;

  elsif(p_dunning_number = 3) then
      	FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_THIRD_DUNNING');
	l_instructions := FND_MESSAGE.GET;
      	FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_MGR_THIRD_INSTR');
	FND_MESSAGE.SET_TOKEN('EMPLOYEE_NAME', l_employeeDisplayName);
	l_mgr_instructions := FND_MESSAGE.GET;


       	FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_MGR_ESC_INSTR_DUNNING3');
        l_mgr_esc_instructions := FND_MESSAGE.GET;

  elsif(p_dunning_number = 4) then
      	FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_FOURTH_DUNNING');
	l_instructions := FND_MESSAGE.GET;
      	FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_MGR_FOURTH_INSTR');
	FND_MESSAGE.SET_TOKEN('EMPLOYEE_NAME', l_employeeDisplayName);
	l_mgr_instructions := FND_MESSAGE.GET;


       	FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_MGR_ESC_INSTR_DUNNING4');
        l_mgr_esc_instructions := FND_MESSAGE.GET;

  end if;

  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'DUNNING_INSTR', l_instructions);
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MANAGER_INSTR', l_mgr_instructions);

--Direct Report


  IF (p_dunning_number = 1 ) THEN
    WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'FIRST_DUNNING', 'Y');
  ELSE
    WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'FIRST_DUNNING', 'N');
  END IF;

  FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_MGR_ESC_ADD_INSTR');
  l_mgr_esc_add_instructions := FND_MESSAGE.GET;


  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MGR_ESC_INSTR', l_mgr_esc_instructions);
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MGR_ESC_ADD_INSTR', l_mgr_esc_add_instructions);


  FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_NEXT_MGR_ESC_INSTR');
  l_next_mgr_esc_instr := FND_MESSAGE.GET;
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MGR_NEXT_ESC_INSTR', l_next_mgr_esc_instr);

  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MGR_NEXT_ESC_ADD_INSTR', l_mgr_esc_add_instructions);


--Amulya Mishra : Notification Esc Project

  FND_MESSAGE.SET_NAME('SQLAP','OIE_ADD_INFO_DUNNING');
  FND_MESSAGE.SET_TOKEN('days', nvl(p_grace_days,0));
  l_add_instructions := FND_MESSAGE.GET;
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'ADD_INSTRUCTIONS', l_add_instructions);

  FND_MESSAGE.SET_NAME('SQLAP','OIE_NOTES_DUNNING');
  l_notes := FND_MESSAGE.GET;
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'NOTES', l_notes);

--determining SUP1 and SUP2


  IF (P_send_notifications = 'ES') THEN
     l_temp_employee_id := p_employeeId;
     l_orig_manager_id := l_managerId;
     l_next_manager_id := l_managerId;
     l_job_level := 0;


     WHILE i<=p_dunning_number LOOP

       AP_WEB_EXPENSE_WF.GetJobLevelAndSupervisor(l_managerId,l_job_level);
       IF l_job_level < nvl(p_esc_level,999999999) THEN

         AP_WEB_EXPENSE_WF.GetManager(l_temp_employee_id, l_managerId);
         IF (l_managerId IS NULL) THEN
           l_managerId := l_temp_employee_id;
           EXIT;
         END IF;


         AP_WEB_EXPENSE_WF.GetJobLevelAndSupervisor(l_managerId,l_job_level);

         AP_WEB_EXPENSE_WF.GetManager(l_managerId , l_next_manager_id);
         IF (l_next_manager_id IS NOT NULL) THEN
           AP_WEB_EXPENSE_WF.GetJobLevelAndSupervisor(l_next_manager_id , l_next_mgr_job_level);
           IF(l_next_mgr_job_level >  nvl(p_esc_level,999999999)) THEN
              l_temp_employee_id := l_managerId;
              EXIT;
           END IF;
         ELSE
           l_next_manager_id := l_managerId;
         END IF;

       END IF;
       l_temp_employee_id := l_managerId;
       i := i + 1;

     END LOOP;

     IF l_job_level = 0 AND p_esc_level IS NOT NULL  THEN --Bug 3337665
       l_managerId := l_next_manager_id;
       l_temp_employee_id := l_managerId;
     END IF;

     IF p_esc_level = 0 THEN
       l_temp_employee_id := l_managerId;
     END IF;

     WF_DIRECTORY.GetUserName('PER', l_managerId, l_managerName, l_managerDisplayName);
     AP_WEB_EXPENSE_WF.GetManager(l_temp_employee_id, l_sup2_manager_id);
     AP_WEB_EXPENSE_WF.GetJobLevelAndSupervisor(l_sup2_manager_id , l_sup2_manager_job_level);
     IF (l_sup2_manager_job_level > nvl(p_esc_level,999999999)) THEN
       l_sup2_manager_display_name := null;
     ELSE
       WF_DIRECTORY.GetUserName('PER', l_sup2_manager_id, l_sup2_manager_name, l_sup2_manager_display_name);
     END IF;



  END IF;

  IF (l_managerDisplayName IS NOT NULL) THEN

    IF(p_dunning_number < 4 AND l_sup2_manager_display_name IS NOT NULL) THEN


      FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_MGR_NTF_DUNNING');
      FND_MESSAGE.SET_TOKEN('SUP1', l_managerDisplayName);
      FND_MESSAGE.SET_TOKEN('SUP2', l_sup2_manager_display_name);
      l_mgmt_instructions := FND_MESSAGE.GET;
      WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MGMT_INSTR', l_mgmt_instructions);

      IF (p_dunning_number = 1) THEN

        FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_MGR_ESC_NTF_DUNNING1');
        FND_MESSAGE.SET_TOKEN('SUP2', l_sup2_manager_display_name);
        l_mgr_esc_mgmt_instructions := FND_MESSAGE.GET;

      ELSE

        FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_MGR_ESC_NTF_DUNNING');
        FND_MESSAGE.SET_TOKEN('SUP1', l_managerDisplayName);
        FND_MESSAGE.SET_TOKEN('SUP2', l_sup2_manager_display_name);
        l_mgr_esc_mgmt_instructions := FND_MESSAGE.GET;

      END IF;
        WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MGMT_ESC_INSTR', l_mgr_esc_mgmt_instructions);

      FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_NEXT_MGR_ESC_NTF');
      FND_MESSAGE.SET_TOKEN('SUP1', l_sup2_manager_display_name);
      l_next_mgr_esc_mgmt_instr := FND_MESSAGE.GET;
      WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MGMT_NEXT_ESC_INSTR', l_next_mgr_esc_mgmt_instr);


    ELSIF (p_dunning_number = 4 OR l_sup2_manager_display_name IS NULL OR l_managerDisplayName = l_sup2_manager_display_name) THEN

      FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_LAST_MGR_NTF_DUNNING');
      FND_MESSAGE.SET_TOKEN('SUP1', l_managerDisplayName);
      l_mgmt_instructions := FND_MESSAGE.GET;
      WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MGMT_INSTR', l_mgmt_instructions);

      FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_MGR_ESC_LAST_NTF_DUNN');
      FND_MESSAGE.SET_TOKEN('SUP2', l_managerDisplayName);
      l_mgr_esc_mgmt_instructions := FND_MESSAGE.GET;
      WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MGMT_ESC_INSTR', l_mgr_esc_mgmt_instructions);

      FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_NEXT_MGR_ESC_LAST_NTF');
      l_next_mgr_esc_mgmt_instr := FND_MESSAGE.GET;
      WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MGMT_NEXT_ESC_INSTR', l_next_mgr_esc_mgmt_instr);


    END IF;

  END IF;

  IF (NOT AP_WEB_DB_CCARD_PKG.GetTotalCreditCardAmount(p_cardProgramID,p_employeeId,
						 l_total_amount ) ) THEN
	NULL;
  END IF;

  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'TOTAL_OUTSTANDING',
        to_char(l_total_amount, FND_CURRENCY.Get_Format_Mask(p_currency,22)) || ' ' || p_currency);


  WF_ENGINE.setItemAttrText(l_itemType, l_itemKey, 'SEND_NOTIFICATIONS_PARAM',p_send_notifications);
  WF_ENGINE.setItemAttrText(l_itemType, l_itemKey, 'AGING_GRACE_DAYS',nvl(p_grace_days,0));

--AMulya Mishra : Notification Esc Project

  ------------------------------------------------------
  l_debugInfo := 'Set WF EMPLOYEE_NAME Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'EMPLOYEE_NAME', l_employeeName);

  --------------------------------------------------------------
  l_debugInfo := 'Set WF EMP_DISPLAY_NAME Item Attribute';
  --------------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'EMP_DISPLAY_NAME', l_employeeDisplayName);

  --------------------------------------------------------------
  l_debugInfo := 'Set WF EMPLOYEE_ID Item Attribute';
  --------------------------------------------------------------
  WF_ENGINE.SetItemAttrNumber(l_itemType, l_itemKey, 'EMPLOYEE_ID', p_employeeID);

  ------------------------------------------------------
  l_debugInfo := 'Set WF MANAGER_NAME Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MANAGER_NAME', l_managerName);

--Amulya Mishra : Notification Esc Project

  IF (P_send_notifications = 'ES') THEN

    WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MGR_ALREADY_NOTIFIED', p_manager_notified);
    WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'NEXT_MANAGER_NAME', l_managerName);
    WF_DIRECTORY.GetUserName('PER', l_orig_manager_id, l_managerName, l_managerDisplayName);
    WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MANAGER_NAME', l_managerName);

  ELSE

    WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MANAGER_NAME', l_managerName);

  END IF;
  --store latest manager id to workflow so that later it can be used.

  WF_ENGINE.SetItemAttrNumber(l_itemType, l_itemKey, 'AGING_MANAGER_ID', l_managerId);

  --Bug 3337388

  WF_ENGINE.SetItemAttrNumber(l_itemType, l_itemKey, 'DUNNING_NUMBER', p_dunning_number);

--Amulya Mishra : Notification Esc project

  --------------------------------------------------------------
  l_debugInfo := 'Set WF CARD_PROG_ID Item Attribute';
  --------------------------------------------------------------
  WF_ENGINE.SetItemAttrNumber(l_itemType, l_itemKey, 'CARD_PROG_ID', p_cardProgramID);

  --------------------------------------------------------------
  l_debugInfo := 'Set WF CREDIT_CARD_COMPANY Item Attribute';
  --------------------------------------------------------------
  IF (NOT AP_WEB_DB_CCARD_PKG.GetCardProgramName(p_cardProgramID,
						 l_cardProgramName ) ) THEN
	NULL;
  END IF;

  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'CREDIT_CARD_COMPANY', l_cardProgramName);


  ----------------------------------------------------------
  l_debugInfo := 'Set CURRENCY Item Attribute';
  ----------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'CURRENCY',p_currency);

  ------------------------------------------------------
  l_debugInfo := 'Set Amount Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'AMOUNT',
			    to_char(p_Amount, FND_CURRENCY.Get_Format_Mask(p_currency,22)) || ' ' || p_currency);


  ------------------------------------------------------
  l_debugInfo := 'Set WF BUCKET1..2 Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'BUCKET1', to_char(p_min_bucket));
  if( p_max_bucket = 1000000) then
  	WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'BUCKET2', l_plus_sign);
  else
  	WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'BUCKET2', '- '||to_char(p_max_bucket));
  end if;



  --------------------------------------------------------------
  l_debugInfo := 'Get and Set ORG_ID attribute ';
  --------------------------------------------------------------
  -- FND_PROFILE.GET('ORG_ID' , l_orgId );
  -- 8990469 : MOAC
  l_orgId := mo_global.get_current_org_id;
  if l_orgId is null then
    FND_PROFILE.GET('ORG_ID' , l_orgId );
  end if;

  WF_ENGINE.SetItemAttrNumber(l_itemType, l_itemKey, 'ORG_ID', l_orgId);

  --------------------------------------------------------------
  l_debugInfo := 'Set NUM_RECORDS value ';
  --------------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType,
			    l_itemKey,
			    'RECORDS_INSTR',
                 'plsql:AP_WEB_CREDIT_CARD_WF.getNumofDunningRecords/'||l_itemType||':'||l_itemKey);

  --------------------------------------------------------------
  l_debugInfo := 'Set LIST value ';
  --------------------------------------------------------------

  WF_ENGINE.SetItemAttrText(l_itemType,
                              l_itemKey,
                              'LIST',
        'plsqlclob:AP_WEB_CREDIT_CARD_WF.generateDunningClobList/'||l_itemType||':'||l_itemKey);

  WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'OIE_LIST',
       'JSP:/OA_HTML/OA.jsp?akRegionCode=DunningRN&akRegionApplicationId=200&itemKey='||l_itemKey||'&graceDays='||p_grace_days||'&escNotif='||'N'||'&mgrList='||'N'||'&orgId='||l_orgId);

  --------------------------------------------------------------
  l_debugInfo := 'Set MGR_LIST value ';
  --------------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'MGR_LIST',
         'JSP:/OA_HTML/OA.jsp?akRegionCode=DunningRN&akRegionApplicationId=200&itemKey='||l_itemKey||'&graceDays='||p_grace_days||'&escNotif='||'N'||'&mgrList='||'Y'||'&name='||l_employeeName||'&orgId='||l_orgId);

--Amulya Mishra : Notification Esc Project

  IF (P_send_notifications = 'ES') THEN

  WF_ENGINE.SetItemAttrText(l_itemType,
                              l_itemKey,
                              'LIST',
        'plsqlclob:AP_WEB_CREDIT_CARD_WF.generateDunningClobList/'||l_itemType||':'||l_itemKey);

      WF_ENGINE.SetItemAttrText(l_itemType,
  			        l_itemKey,
			        'OIE_LIST',
       'JSP:/OA_HTML/OA.jsp?akRegionCode=DunningRN&akRegionApplicationId=200&itemKey='||l_itemKey||'&graceDays='||p_grace_days||'&escNotif='||'Y'||'&mgrList='||'N'||'&orgId='||l_orgId);

  --------------------------------------------------------------
  l_debugInfo := 'Set MGR_LIST value ';
  --------------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'MGR_LIST',
       'JSP:/OA_HTML/OA.jsp?akRegionCode=DunningRN&akRegionApplicationId=200&itemKey='||l_itemKey||'&graceDays='||p_grace_days||'&escNotif='||'Y'||'&mgrList='||'Y'||'&orgId='||l_orgId);


    GetTotalOutstandingAttribute(p_employeeId,
                                 p_cardProgramId,
                        	 p_min_bucket,
			   	 p_max_bucket,
                                 p_grace_days,
			   	 l_mgr_esc_amount);
    ------------------------------------------------------
    l_debugInfo := 'Set Amount Item Attribute';
    ------------------------------------------------------
    WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MGR_ESC_AMOUNT',
		    to_char(l_mgr_esc_amount, FND_CURRENCY.Get_Format_Mask(p_currency,22)) || ' ' || p_currency);

    WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'LIST_ESC',
      'plsqlclob:AP_WEB_CREDIT_CARD_WF.generateManagerDunningList/'||l_itemType||':'||l_itemKey);

  WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'OIE_LIST_ESC',
         'JSP:/OA_HTML/OA.jsp?akRegionCode=EscNotifMgrRN&akRegionApplicationId=200&itemKey='||l_itemKey||'&managerId='||l_orig_manager_id||'&orgId='||l_orgId);


    GetHierTotalOutstandingAttr(l_managerId,
                                 p_cardProgramId,
                        	 p_min_bucket,
			   	 p_max_bucket,
                                 p_grace_days,
                                 p_dunning_number,
			   	 l_next_mgr_esc_amount);


    ------------------------------------------------------
    l_debugInfo := 'Set Amount Item Attribute';
    ------------------------------------------------------
    WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MGR_NEXT_ESC_AMOUNT',
		    to_char(l_next_mgr_esc_amount, FND_CURRENCY.Get_Format_Mask(p_currency,22)) || ' ' || p_currency);


  WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'LIST_NEXT_ESC',
  'plsqlclob:AP_WEB_CREDIT_CARD_WF.generateNextManagerDunningList/'||l_itemType||':'||l_itemKey);

  WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'OIE_LIST_NEXT_ESC',
         'JSP:/OA_HTML/OA.jsp?akRegionCode=EscNotifNextMgrRN&akRegionApplicationId=200&itemKey='||l_itemKey||'&agingManager='||l_managerId||'&orgId='||l_orgId);

  END IF;

--Amulya Mishra : Notification Esc project

   BEGIN
    WF_ENGINE.SetItemAttrText(l_itemType,
                              l_itemKey,
                              '#FROM_ROLE',
                              WF_ENGINE.GetItemAttrText(l_itemType,
                                                        l_itemKey,
                                                        'WF_ADMINISTRATOR'));
   EXCEPTION
	WHEN OTHERS THEN
            NULL;
   END;


  BEGIN
    ------------------------------------------------------------
    l_debugInfo := 'Start the Expense Report Workflow Process';
    ------------------------------------------------------------
    WF_ENGINE.StartProcess(l_itemType, l_itemKey);

  EXCEPTION
    WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_CREDIT_CARD_WF', 'SendDunningNotifications',
                     l_itemType, l_itemKey, to_char(0), l_debugInfo);
    raise;
  END;
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'SendDunningNotifications');
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                            ' p_employeeId = ' || to_char(p_employeeId) ||
                            ', p_cardProgramId = ' || to_char(p_cardProgramId) ||
                            ', p_bucket1 = ' || to_char(p_min_bucket) ||
                            ', p_bucket2 = ' || to_char(p_max_bucket));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debugInfo);
      RAISE_APPLICATION_ERROR(-20010, fnd_message.get);
    ELSE
      -- Do not need to set the token since it has been done in the
      -- child process
      RAISE;
   END IF;
END SendDunningNotifications;


PROCEDURE sendUnapprovedExpReportNote(
	p_expenseReportId   IN AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
        p_current_approver  IN AP_EXPENSE_REPORT_HEADERS.expense_current_approver_id%TYPE)  --2628468

IS
  l_itemType	VARCHAR2(100)	:= 'APCCARD';
  l_itemKey	VARCHAR2(100);
  l_employeeName		wf_users.name%type;
  l_employeeDisplayName	wf_users.display_name%type;
  l_managerName		wf_users.name%type;
  l_managerDisplayName	wf_users.display_name%type;
  l_exp_info_rec AP_WEB_DB_EXPRPT_PKG.ExpInfoRec;
  l_debugInfo			VARCHAR2(200);

BEGIN
  ------------------------------------------------------------
  l_debugInfo := 'Get employee_Id';
  ------------------------------------------------------------

  IF (NOT AP_WEB_DB_EXPRPT_PKG.GetReportInfo(p_expenseReportId, l_exp_info_rec)) THEN
     NULL;
  END IF;


  --2628468, I removed the code that found the manager ID

  ------------------------------------------------------------
  l_debugInfo := 'Get Name Info Associated With employee_Id';
  ------------------------------------------------------------
  WF_DIRECTORY.GetUserName('PER', l_exp_info_rec.emp_id, l_employeeName, l_employeeDisplayName);

  /* Bug 3877939: If a record does not exist in WF_Directory, then
   *              the program should not error out.
   */
  IF l_employeeName IS NULL THEN
     RETURN;
  END IF;

  ------------------------------------------------------------
  l_debugInfo := 'Get Name Info Associated With managerId';
  ------------------------------------------------------------
  --2628468, instead of using the manager, use the current approver

  WF_DIRECTORY.GetUserName('PER', p_current_approver, l_managerName, l_managerDisplayName);

  ---------------------------------------------------------
  l_debugInfo := ' Generate new key';
  -- p_expenseReportId is not used since this notification could be sent nore than once
  ---------------------------------------------------------
    l_itemKey := GetNextCardNotificationID;

    --------------------------------------------------
    l_debugInfo := 'Calling WorkFlow Create Process';
    --------------------------------------------------
   WF_ENGINE.CreateProcess(l_itemType,  l_itemKey, 'UNAPPROVED_REPORT');

  ----------------------------------------------------------
  l_debugInfo := 'Set WF Amount Item Attribute';
  ----------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'AMOUNT',
			    to_char(l_exp_info_rec.total, FND_CURRENCY.Get_Format_Mask(l_exp_info_rec.default_curr_code,22)) || ' ' || l_exp_info_rec.default_curr_code);

  ----------------------------------------------------------
  l_debugInfo := 'Set the Owner of Workflow Process.';
  ----------------------------------------------------------
  WF_ENGINE.SetItemOwner(l_itemType, l_itemKey, l_employeeName);

  --------------------------------------------------------------
  l_debugInfo := 'Set WF EMP_DISPLAY_NAME Item Attribute';
  --------------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'EMP_DISPLAY_NAME', l_employeeDisplayName);

  ------------------------------------------------------
  l_debugInfo := 'Set WF MANAGER_NAME Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MANAGER_NAME', l_managerName);

  ----------------------------------------------------------
  l_debugInfo := 'Set WF EXPENSE_REPORT_NUMBER Item Attribute';
  ----------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'EXPENSE_REPORT_NUMBER', l_exp_info_rec.doc_num);

  BEGIN
    ------------------------------------------------------------
    l_debugInfo := 'Start the Expense Report Workflow Process';
    ------------------------------------------------------------
    WF_ENGINE.StartProcess(l_itemType, l_itemKey);

  EXCEPTION
    WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_CREDIT_CARD_WF', 'sendUnapprovedExpReportNote',
                     l_itemType, l_itemKey, to_char(0), l_debugInfo);
    raise;
  END;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'sendUnapprovedExpReportNote');
      FND_MESSAGE.SET_TOKEN('PARAMETERS', 'p_expenseReportId  = ' || to_char(p_expenseReportId));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debugInfo);
      RAISE_APPLICATION_ERROR(-20010, fnd_message.get);
    ELSE
      -- Do not need to set the token since it has been done in the
      -- child process
      RAISE;
   END IF;
END sendUnapprovedExpReportNote;



PROCEDURE sendDisputedChargesNote(p_employeeId       IN NUMBER,
                                  p_cardProgramId    IN AP_CARD_PROGRAMS.card_program_id%TYPE,
                                  p_billedStartDate  in date,
                                  p_billedEndDate    in date,
			   	  p_minimumAmount    IN NUMBER)
IS
  l_itemType	VARCHAR2(100)	:= 'APCCARD';
  l_itemKey	VARCHAR2(100);
  l_employeeId  number;
  l_employeeName		wf_users.name%type;
  l_employeeDisplayName	wf_users.display_name%type;
  l_currency    AP_WEB_DB_EXPRPT_PKG.expHdr_defaultCurrCode;
  l_cardProgramName AP_WEB_DB_CCARD_PKG.cardProgs_cardProgName;
  l_sysdate       VARCHAR2(30);
  l_today	DATE;
  l_orgId       number;
  l_days       number;
  l_debugInfo			VARCHAR2(200);

BEGIN
  ---------------------------------------------------------
  l_debugInfo := ' Generate new key';
  ---------------------------------------------------------
    l_itemKey := GetNextCardNotificationID;

  ------------------------------------------------------------
  l_debugInfo := 'Get Name Info Associated With employee_Id';
  ------------------------------------------------------------
  WF_DIRECTORY.GetUserName('PER', p_employeeId, l_employeeName, l_employeeDisplayName);

  /* Bug 3877939: If a record does not exist in WF_Directory, then
   *              the program should not error out.
   */
  IF l_employeeName IS NULL THEN
     RETURN;
  END IF;

    --------------------------------------------------
    l_debugInfo := 'Calling WorkFlow Create Process';
    --------------------------------------------------
   WF_ENGINE.CreateProcess(l_itemType,  l_itemKey, 'DISPUTED_CHARGES');

  ----------------------------------------------------------
  l_debugInfo := 'Set the Owner of Workflow Process.';
  ----------------------------------------------------------
  WF_ENGINE.SetItemOwner(l_itemType, l_itemKey, l_employeeName);

  ------------------------------------------------------
  l_debugInfo := 'Set WF EMPLOYEE_NAME Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'EMPLOYEE_NAME', l_employeeName);

  --------------------------------------------------------------
  l_debugInfo := 'Set WF EMP_DISPLAY_NAME Item Attribute';
  --------------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'EMP_DISPLAY_NAME', l_employeeDisplayName);

  --------------------------------------------------------------
  l_debugInfo := 'Set WF EMPLOYEE_ID Item Attribute';
  --------------------------------------------------------------
  WF_ENGINE.SetItemAttrNumber(l_itemType, l_itemKey, 'EMPLOYEE_ID', p_employeeID);

  --------------------------------------------------------------
  l_debugInfo := 'Set WF CARD_PROG_ID Item Attribute';
  --------------------------------------------------------------
  WF_ENGINE.SetItemAttrNumber(l_itemType, l_itemKey, 'CARD_PROG_ID', p_cardProgramID);

  --------------------------------------------------------------
  l_debugInfo := 'Set WF CREDIT_CARD_COMPANY Item Attribute';
  --------------------------------------------------------------
  IF (NOT AP_WEB_DB_CCARD_PKG.GetCardProgramName(p_cardProgramID,
						 l_cardProgramName ) ) THEN
	NULL;
  END IF;

  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'CREDIT_CARD_COMPANY', l_cardProgramName);

  ------------------------------------------------------
  l_debugInfo := 'Set WF MIN_AMOUNT Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrNumber(l_itemType, l_itemKey, 'MIN_AMOUNT', p_minimumAmount);

  ------------------------------------------------------
  l_debugInfo := 'Set WF DATE_OBJ1 Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrDate(l_itemType, l_itemKey, 'DATE_OBJ1', p_billedStartDate);

  ------------------------------------------------------
  l_debugInfo := 'Set WF DATE_OBJ2 Item Attribute';
  ------------------------------------------------------
  WF_ENGINE.SetItemAttrDate(l_itemType, l_itemKey, 'DATE_OBJ2', p_billedEndDate);

  ------------------------------------------------------
  l_debugInfo := 'Set WF NUMBER_OF_DAYS Item Attribute';
  ------------------------------------------------------
  IF (AP_WEB_DB_UTIL_PKG.GetSysDate(l_sysdate)) THEN
     l_today := to_date(l_sysdate,AP_WEB_INFRASTRUCTURE_PKG.getDateFormat);
  END IF;

  WF_ENGINE.SetItemAttrNumber(l_itemType, l_itemKey, 'NUMBER_OF_DAYS', round(l_today - p_billedStartDate));

  l_days := round(l_today - p_billedStartDate);
  --------------------------------------------------------------
  l_debugInfo := 'Get and Set ORG_ID attribute ';
  --------------------------------------------------------------
  --FND_PROFILE.GET('ORG_ID' , l_orgId );
  -- 8990469 : MOAC
  l_orgId := mo_global.get_current_org_id;
  if l_orgId is null then
    FND_PROFILE.GET('ORG_ID' , l_orgId );
  end if;

  WF_ENGINE.SetItemAttrNumber(l_itemType, l_itemKey, 'ORG_ID', l_orgId);

  --------------------------------------------------------------
  l_debugInfo := 'Set LIST value ';
  --------------------------------------------------------------
  WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'LIST',
                 'plsql:AP_WEB_CREDIT_CARD_WF.generateList/'||l_itemType||':'||l_itemKey);

  WF_ENGINE.SetItemAttrText(l_itemType,
			      l_itemKey,
			      'OIE_LIST',
         'JSP:/OA_HTML/OA.jsp?akRegionCode=DisputedChargesRN&akRegionApplicationId=200&itemKey='||l_itemKey||'&cardCompany='||l_cardProgramName||'&days='||l_days||'&orgId='||l_orgId);

  BEGIN
    ------------------------------------------------------------
    l_debugInfo := 'Start the Expense Report Workflow Process';
    ------------------------------------------------------------
    WF_ENGINE.StartProcess(l_itemType, l_itemKey);

  EXCEPTION
    WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_CREDIT_CARD_WF', 'sendDisputedChargesNote',
                     l_itemType, l_itemKey, to_char(0), l_debugInfo);
    raise;
  END;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'sendDisputedChargesNote');
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                            ' p_employeeId = ' || to_char(p_employeeId) ||
                            ', p_cardProgramId = ' || to_char(p_cardProgramId) ||
                            ', p_billedStartDate = ' || to_char(p_billedStartDate) ||
                            ', p_billedEndDate = ' || to_char(p_billedEndDate) ||
                            ', p_minimumAmount = ' || to_char(p_minimumAmount));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debugInfo);
      RAISE_APPLICATION_ERROR(-20010, fnd_message.get);
    ELSE
      -- Do not need to set the token since it has been done in the
      -- child process
      RAISE;
   END IF;
END sendDisputedChargesNote;

/*
Written by:
  Quan Le
Purpose:
  To generate the LIST document attribute of Credit Card Workflow. This procedure follows
predefined API.   See Workflow API documentation for more informfation.
Input:
  See Workflow API documentation.
Output:
    See Workflow API documentation.
Input Output:
    See Workflow API documentation.
Assumption:
  document_id is assumed to have the following format:
  <item_key>:<item_id>
Date:
  22/10/99
*/
PROCEDURE GenerateList(document_id		IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY VARCHAR2,
				document_type	IN OUT NOCOPY VARCHAR2) IS

  l_colon    NUMBER;
  l_itemtype VARCHAR2(7);
  l_itemkey  VARCHAR2(15);
  l_cardProgramId 		AP_WEB_DB_CCARD_PKG.ccTrxn_cardProgID;
  l_billedStartDate 		AP_WEB_DB_CCARD_PKG.ccTrxn_billedDate;
  l_billedEndDate 		AP_WEB_DB_CCARD_PKG.ccTrxn_billedDate;
  l_minimumAmount 		AP_WEB_DB_CCARD_PKG.ccTrxn_billedAmount;
  l_employeeId    		AP_WEB_DB_CCARD_PKG.cards_employeeID;
  l_dateFormat    varchar2(30);
  l_transaction_date		AP_WEB_DB_CCARD_PKG.ccTrxn_transDate;
  l_merchant_name1		AP_WEB_DB_CCARD_PKG.ccTrxn_merchantName1;
  l_billed_amount		AP_WEB_DB_CCARD_PKG.ccTrxn_billedAmount;
  l_billed_currency_code	AP_WEB_DB_CCARD_PKG.ccTrxn_billedCurrCode;
  l_lineInfo			VARCHAR2(2000);
  l_debugInfo                  VARCHAR2(1000);
  l_orgId    number;
  l_disputedCharges_cursor     AP_WEB_DB_CCARD_PKG.DisputedCCTrxnCursor;
  l_dispute_header_prompt      VARCHAR2(200);

BEGIN

  l_debugInfo := 'Decode document_id';
  l_colon    := instrb(document_id, ':');
  l_debugInfo := l_debugInfo || ' First index: ' || to_char(l_colon);
  l_itemtype := substrb(document_id, 1, l_colon - 1);
  l_itemkey  := substrb(document_id, l_colon  + 1);

  l_debugInfo := 'Get org_id';
  l_orgId := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemKey, 'ORG_ID');

  -- MOAC UPTAKE --
  -- Have new call back function defined for Item to set org context.
  --
  -- l_debugInfo := 'Set Org context';
  -- fnd_client_info.set_org_context(l_orgId);

  l_debugInfo := 'Generate header';
  if (display_type = 'text/plain') then
      document := '';
  else  -- html
       FND_MESSAGE.SET_NAME('SQLAP','OIE_DISPUTED_HEADER_DUNNING');
       l_dispute_header_prompt := FND_MESSAGE.GET;
       document := indent_start||table_title_start|| l_dispute_header_prompt||table_title_end;
       document := document|| table_start;
       document := document|| tr_start;

        document := document || th_text ||'Receipt Date' ||td_end;
        document := document || th_text ||'Merchant'||td_end;
        document := document || th_text ||'Billed Amount'||td_end||tr_end;

  end if;

  ------------------------------------------------------
  l_debugInfo := 'Get WF MIN_AMOUNT Item Attribute';
  ------------------------------------------------------
  l_minimumAmount := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'MIN_AMOUNT');

  ------------------------------------------------------
  l_debugInfo := 'Get WF DATE_OBJ1 Item Attribute';
  ------------------------------------------------------
  --l_billedStartDate := WF_ENGINE.GetItemAttrDate(l_itemType, l_itemKey, 'DATE_OBJ1');

  ------------------------------------------------------
  l_debugInfo := 'Get WF DATE_OBJ2 Item Attribute';
  ------------------------------------------------------
  l_billedEndDate := WF_ENGINE.GetItemAttrDate(l_itemType, l_itemKey, 'DATE_OBJ2');

  --------------------------------------------------------------
  l_debugInfo := 'Get WF CARD_PROG_ID Item Attribute';
  --------------------------------------------------------------
  l_cardProgramID := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'CARD_PROG_ID');

  --------------------------------------------------------------
  l_debugInfo := 'Get WF EMPLOYEE_ID Item Attribute';
  --------------------------------------------------------------
  l_employeeID := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'EMPLOYEE_ID');

  l_dateFormat := icx_sec.getID(icx_sec.PV_DATE_FORMAT);

  l_debugInfo := 'Loop over all the Disputed charges';

  IF (NOT AP_WEB_DB_CCARD_PKG.GetDisputedCcardTrxnCursor(l_cardProgramId,
			l_minimumAmount,  l_employeeId, l_billedStartDate,
			l_billedEndDate, l_DisputedCharges_cursor)) THEN
     NULL;
  END IF;

  LOOP
      FETCH l_DisputedCharges_cursor
      INTO  l_transaction_date,
	    l_merchant_name1,
	    l_billed_amount,
	    l_billed_currency_code;
      EXIT WHEN l_DisputedCharges_cursor%NOTFOUND;
      IF (display_type = 'text/plain') THEN
      	--------------------------------------------
      	l_debugInfo := 'Format Expense Line Info';
      	--------------------------------------------
      	l_lineInfo := to_char(l_transaction_date,l_dateFormat) || ' ' ||
                      l_merchant_name1 || ' ' || to_char(l_billed_amount, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22));
       	-- set a new line
       	document := document || ' ' || l_lineInfo;
       	l_lineInfo := '';
      ELSE  -- HTML type
        document := document || tr_start|| td_text||
                    to_char(l_transaction_date,l_dateFormat) || td_end;
        document := document || td_text|| WF_NOTIFICATION.SubstituteSpecialChars(l_merchant_name1) || td_end;
        document := document || td_number|| to_char(l_billed_amount, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22)) || td_end||tr_end;
      END IF;
  END LOOP;

  close l_DisputedCharges_cursor;

    if (display_type = 'text/html') then
        document := document || table_end ||indent_end;
    end if;

    document_type := display_type;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_EXPENSE_WF', 'GenerateList',
                    document_id, l_debugInfo);
    raise;
END GenerateList;

PROCEDURE GenerateUnsubmittedList(document_id		IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY VARCHAR2,
				document_type	IN OUT NOCOPY VARCHAR2) IS

  l_document_max                NUMBER := 25000; -- 27721 fails
  l_debug_info                  VARCHAR2(1000);
  l_message                     VARCHAR2(2000);
  l_temp_clob                   CLOB;
  l_colon                       NUMBER;

  BEGIN
  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_CREDIT_CARD_WF', 'start GenerateUnsubmittedList');

  WF_NOTIFICATION.NewClob(l_temp_clob,document);
  GenUnsubmittedClobList(document_id,
                         display_type,
                         l_temp_clob,
                         document_type);


  dbms_lob.read(l_temp_clob,l_document_max,1,document);

  if (dbms_lob.getlength(l_temp_clob) > l_document_max) then

        l_colon  := instr(document, '</tr>',-1);
        document := substr(document,1,l_colon+4);
        document := document || '</table><br>';

        FND_MESSAGE.SET_NAME('SQLAP','AP_WEB_EXP_UNABLE_TO_SHOWLINES');
        l_message := FND_MESSAGE.GET;
        document := document || '<table>';
        document := document || '<tr>' || '&' || 'nbsp;</tr>';
        document := document || '<tr>' || '&' || 'nbsp;</tr>';
        document := document || '<tr>' ||td_text|| l_message || '</td></tr>';
        document := document || '</table>';

  end if;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_CREDIT_CARD_WF', 'end GenerateUnsubmittedList');
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_CREDIT_CARD_WF', 'GenerateUnsubmittedList',
                    document_id, l_debug_info);
    raise;

END GenerateUnsubmittedList;

PROCEDURE GenUnsubmittedClobList(document_id	IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY CLOB,
				document_type	IN OUT NOCOPY VARCHAR2) IS

  l_colon    NUMBER;
  l_itemtype VARCHAR2(7);
  l_itemkey  VARCHAR2(15);
  l_cardProgramId 		AP_WEB_DB_CCARD_PKG.ccTrxn_cardProgID;
  l_billedStartDate 		AP_WEB_DB_CCARD_PKG.ccTrxn_billedDate;
  l_billedEndDate 		AP_WEB_DB_CCARD_PKG.ccTrxn_billedDate;
  l_minimumAmount 		AP_WEB_DB_CCARD_PKG.ccTrxn_billedAmount;
  l_employeeId    		AP_WEB_DB_CCARD_PKG.cards_employeeID;
  l_dateFormat    varchar2(30);
  l_transaction_date		AP_WEB_DB_CCARD_PKG.ccTrxn_transDate;
  l_merchant_name1		AP_WEB_DB_CCARD_PKG.ccTrxn_merchantName1;
  l_billed_amount		AP_WEB_DB_CCARD_PKG.ccTrxn_billedAmount;
  l_billed_currency_code	AP_WEB_DB_CCARD_PKG.ccTrxn_billedCurrCode;
  l_lineInfo			VARCHAR2(2000);
  l_debugInfo                  VARCHAR2(1000);
  l_orgId    number;
  l_UnsubmittedCharges_cursor    AP_WEB_DB_CCARD_PKG.UnsubmittedCCTrxnCursor;
  l_expense_report_number	VARCHAR2(60);
  l_expense_report_status	VARCHAR2(30);
  l_displayed_status	 	VARCHAR2(60);
  l_chargeType	 		VARCHAR2(60);
  l_prompts			AP_WEB_UTILITIES_PKG.prompts_table;
  l_title			AK_REGIONS_VL.name%TYPE;
  l_trxID                       AP_WEB_DB_CCARD_PKG.ccTrxn_trxID;
  l_detail_header_prompt        VARCHAR2(200);
  l_document                    long;
  l_document_max                NUMBER := 25000;


BEGIN


  l_debugInfo := 'Decode document_id';
  l_colon    := instrb(document_id, ':');
  l_debugInfo := l_debugInfo || ' First index: ' || to_char(l_colon);
  l_itemtype := substrb(document_id, 1, l_colon - 1);
  l_itemkey  := substrb(document_id, l_colon  + 1);

  l_debugInfo := 'Get org_id';
  l_orgId := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemKey, 'ORG_ID');

  -- MOAC UPTAKE --
  -- Have new call back function defined for Item to set org context.
  --
  -- l_debugInfo := 'Set Org context';
  -- fnd_client_info.set_org_context(l_orgId);


  ------------------------------------------------------------
  l_debugInfo := 'Get prompts';
  ------------------------------------------------------------
  AP_WEB_DISC_PKG.getPrompts(200,'AP_WEB_WF_CC_LINETABLE',l_title,l_prompts);


  l_debugInfo := 'Generate header';
  if (display_type = 'text/plain') then
      l_document := '';
  else  -- html
        FND_MESSAGE.SET_NAME('SQLAP','OIE_DETAIL_HEADER_DUNNING');
        l_detail_header_prompt := FND_MESSAGE.GET;

        l_document := indent_start||table_title_start|| l_detail_header_prompt||table_title_end;

        l_document := l_document||table_start;
        l_document := l_document||tr_start;

        -- 'Receipt Date'
        l_document := l_document || th_text || l_prompts(6) || td_end;
        -- 'Billed Amount'
        l_document := l_document || th_number || l_prompts(2) || td_end;
        -- 'Merchant Name'
        l_document := l_document || th_text || l_prompts(3) || td_end;
        -- 'Report Number'
        l_document := l_document || th_text || l_prompts(4) || td_end;
        -- 'Status'
        l_document := l_document || th_text || l_prompts(5) || td_end;
        l_document := l_document ||tr_end;
  end if;

  ------------------------------------------------------
  l_debugInfo := 'Get WF MIN_AMOUNT Item Attribute';
  ------------------------------------------------------
  l_minimumAmount := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'MIN_AMOUNT');

  ------------------------------------------------------
  l_debugInfo := 'Get WF DATE1 Item Attribute';
  ------------------------------------------------------
  l_billedStartDate := WF_ENGINE.GetItemAttrDate(l_itemType, l_itemKey, 'DATE1');

  ------------------------------------------------------
  l_debugInfo := 'Get WF DATE2 Item Attribute';
  ------------------------------------------------------
  l_billedEndDate := WF_ENGINE.GetItemAttrDate(l_itemType, l_itemKey, 'DATE2');

  --------------------------------------------------------------
  l_debugInfo := 'Get WF CARD_PROG_ID Item Attribute';
  --------------------------------------------------------------
  l_cardProgramId := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'CARD_PROG_ID');

  --------------------------------------------------------------
  l_debugInfo := 'Get WF EMPLOYEE_ID Item Attribute';
  --------------------------------------------------------------
  l_employeeId := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'EMPLOYEE_ID');

  --------------------------------------------------------------
  l_debugInfo := 'Get Charge Type Item Attribute';
  --------------------------------------------------------------
  l_chargeType := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'CHARGE_TYPE');


  l_dateFormat := icx_sec.getID(icx_sec.PV_DATE_FORMAT);

  l_debugInfo := 'Loop over all the Unsubmitted charges ';

  IF (NOT AP_WEB_DB_CCARD_PKG.GetUnsubmittedCcardTrxnCursor(l_cardProgramId,
			l_employeeId, l_billedStartDate,
			l_billedEndDate, l_minimumAmount, l_chargeType, l_UnsubmittedCharges_cursor)) THEN
     NULL;
  END IF;

  LOOP
      FETCH l_UnsubmittedCharges_cursor
      INTO  l_transaction_date,
	    l_merchant_name1,
	    l_billed_amount,
	    l_billed_currency_code,
	    l_expense_report_number,
	    l_expense_report_status,
	    l_trxID;                    -- Bug 3241358

      EXIT WHEN l_UnsubmittedCharges_cursor%NOTFOUND;

      IF lengthb(l_document) >= l_document_max THEN
         -- Appends document to end of document (CLOB object)
         WF_NOTIFICATION.WriteToClob(document,l_document);
         l_document := '';
      END IF;

	BEGIN
        select	displayed_field
	into	l_displayed_status
	from	ap_lookup_codes
	where	lookup_type = AP_WEB_OA_ACTIVE_PKG.C_EXPENSE_REPORT_STATUS
	and	lookup_code = l_expense_report_status;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN NULL;
	END;

      IF (display_type = 'text/plain') THEN
      	--------------------------------------------
      	l_debugInfo := 'Format Expense Line Info';
      	--------------------------------------------
      	l_lineInfo := to_char(l_transaction_date,l_dateFormat) || ' ' ||
		      to_char(l_billed_amount, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22)) || ' ' ||
                      l_merchant_name1 || ' ' ||
		      l_expense_report_number || ' ' ||
	              l_expense_report_status;

       	-- set a new line
       	l_document := l_document || ' ' || l_lineInfo;
       	l_lineInfo := '';
      ELSE  -- HTML type
	l_document := l_document || tr_start;
        l_document := l_document || td_text ||to_char(l_transaction_date,l_dateFormat)|| td_end;
        l_document := l_document || td_number||to_char(l_billed_amount, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22)) || td_end;
        l_document := l_document || td_text|| WF_NOTIFICATION.SubstituteSpecialChars(l_merchant_name1) || td_end;
	l_document := l_document || td_text|| l_expense_report_number ||td_end;
	l_document := l_document || td_text|| l_displayed_status ||td_end;
        l_document := l_document || tr_end;
      END IF;
  END LOOP;

  close l_UnsubmittedCharges_cursor;

    if (display_type = 'text/html') then
        l_document := l_document || table_end||indent_end;
    end if;

    WF_NOTIFICATION.WriteToClob(document,l_document);

    document_type := display_type;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_EXPENSE_WF', 'GenerateUnsubmittedList',
                    document_id, l_debugInfo);
    raise;
END GenUnsubmittedClobList;

/*Written By : Amulya Mishra
  Purpose: Notification Escalation project.
           Rewrote the existing procedure to call GenerateDunningClobList().
*/

PROCEDURE GenerateDunningList(document_id		IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY VARCHAR2,
				document_type	IN OUT NOCOPY VARCHAR2) IS

  l_document_max 	        NUMBER := 25000; -- 27721 fails
  l_debug_info                  VARCHAR2(1000);
  l_message                     VARCHAR2(2000);
  l_temp_clob                   CLOB;
  l_colon                       NUMBER;
BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_EXPENSE_WF', 'start GenerateDunningList');

  WF_NOTIFICATION.NewClob(l_temp_clob,document);
  GenerateDunningClobList(document_id,
		   display_type,
		   l_temp_clob,
		   document_type);
  dbms_lob.read(l_temp_clob,l_document_max,1,document);

  if (dbms_lob.getlength(l_temp_clob) > l_document_max) then

        l_colon  := instr(document, '</tr>',-1);
        document := substr(document,1,l_colon+4);
        document := document || '</table><br>';

        FND_MESSAGE.SET_NAME('SQLAP','AP_WEB_EXP_UNABLE_TO_SHOWLINES');
        l_message := FND_MESSAGE.GET;
        document := document || '<table>';
        document := document || '<tr>' || '&' || 'nbsp;</tr>';
        document := document || '<tr>' || '&' || 'nbsp;</tr>';
        document := document || '<tr>' ||td_text|| l_message || '</td></tr>';
        document := document || '</table>';

  end if;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_EXPENSE_WF', 'end GenerateDunningList');

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_EXPENSE_WF', 'GenerateDunningList',
                    document_id, l_debug_info);
    raise;
END GenerateDunningList;


/*Written By : Amulya Mishra
  Purpose: Notification Escalation project.
           New Procedure to display CLOB based document GenerateDunningClobList().
*/



PROCEDURE GenerateDunningClobList(document_id		IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY CLOB,--Notification Esc
				document_type	IN OUT NOCOPY VARCHAR2) IS

  l_colon    			NUMBER;
  l_itemtype 			VARCHAR2(7);
  l_itemkey  			VARCHAR2(15);
  l_cardProgramId 		AP_WEB_DB_CCARD_PKG.ccTrxn_cardProgID;
  l_employeeId    		AP_WEB_DB_CCARD_PKG.cards_employeeID;
  l_dateFormat    		VARCHAR2(30);
  l_transaction_date		AP_WEB_DB_CCARD_PKG.ccTrxn_transDate;
  l_merchant_name1		AP_WEB_DB_CCARD_PKG.ccTrxn_merchantName1;
  l_billed_amount		AP_WEB_DB_CCARD_PKG.ccTrxn_billedAmount;
  l_billed_date 		AP_WEB_DB_CCARD_PKG.ccTrxn_billedDate;
  l_billed_currency_code	AP_WEB_DB_CCARD_PKG.ccTrxn_billedCurrCode;
  l_lineInfo			VARCHAR2(2000);
  l_debugInfo                  	VARCHAR2(1000);
  l_orgId    			NUMBER;
  l_Dunning_cursor    		AP_WEB_DB_CCARD_PKG.DunningCCTrxnCursor;
  l_expense_report_number	VARCHAR2(60);
  l_expense_report_status	VARCHAR2(30);
  l_displayed_status		VARCHAR2(60);
  l_min_bucket			NUMBER;
  l_max_bucket 			NUMBER;
  l_min_bucket1			VARCHAR2(30);
  l_max_bucket1			VARCHAR2(30);
  l_instructions		VARCHAR2(200);
  l_prompts			AP_WEB_UTILITIES_PKG.prompts_table;
  l_title			AK_REGIONS_VL.name%TYPE;

--Notification Project
  l_document      		 long ;
  l_document_max  		 NUMBER := 25000;

  l_posted_date 		 AP_CREDIT_CARD_TRXNS_ALL.POSTED_DATE%TYPE; --Notification Esc
  l_posted_currency_code         AP_CREDIT_CARD_TRXNS_ALL.POSTED_CURRENCY_CODE%TYPE;--3339380
  l_transaction_amount  	 AP_CREDIT_CARD_TRXNS_ALL.TRANSACTION_AMOUNT%TYPE;--Notification Esc
  l_location 			 AP_EXPENSE_REPORT_LINES_ALL.LOCATION%TYPE;  --Notification Esc
  l_Dispute_cursor    		 AP_WEB_DB_CCARD_PKG.DisputeCCTrxnCursor;  --Notification Esc

  l_detail_header_prompt 	 VARCHAR2(2000);
  l_dispute_header_prompt 	 VARCHAR2(2000);
  l_grace_days            	 NUMBER;

  l_total_dispute                NUMBER; --Bug 3326035
  l_total_amt_dispute            NUMBER; --Bug 3326035



--Notification Project
  l_trxID                        AP_WEB_DB_CCARD_PKG.ccTrxn_trxID;

BEGIN


  l_debugInfo := 'Decode document_id';
  l_colon    := instrb(document_id, ':');
  l_debugInfo := l_debugInfo || ' First index: ' || to_char(l_colon);
  l_itemtype := substrb(document_id, 1, l_colon - 1);
  l_itemkey  := substrb(document_id, l_colon  + 1);

  l_debugInfo := 'Get org_id';
  l_orgId := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemKey, 'ORG_ID');

  -- MOAC UPTAKE --
  -- Have new call back function defined for Item to set org context.
  --
  -- l_debugInfo := 'Set Org context';
  -- fnd_client_info.set_org_context(l_orgId);

  ------------------------------------------------------------
  l_debugInfo := 'Get prompts';
  ------------------------------------------------------------
  AP_WEB_DISC_PKG.getPrompts(200,'AP_WEB_WF_CC_LINETABLE',l_title,l_prompts);


  l_debugInfo := 'Generate header';
  l_document := '';--Notification Esc :Change all document to l_document

--Notification esc :  moved code to top..

  l_grace_days := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'AGING_GRACE_DAYS');
  --------------------------------------------------------------
  l_debugInfo := 'Get WF BUCKET1..4 Item Attribute';
  --------------------------------------------------------------
  l_min_bucket1 := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'BUCKET1');
  l_max_bucket1 := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'BUCKET2');

  l_min_bucket := to_number(l_min_bucket1);
  if(l_max_bucket1 = '+' ) then
	l_max_bucket := 1000000;
  else
	l_max_bucket := to_number(substr(l_max_bucket1,3));
  end if;

  if (display_type = 'text/plain') then
      l_document := '';
  else  -- html
--Notification Esc :      SET HEADER
        FND_MESSAGE.SET_NAME('SQLAP','OIE_DETAIL_HEADER_DUNNING');
        l_detail_header_prompt := FND_MESSAGE.GET;

        l_document := indent_start||table_title_start || l_detail_header_prompt || table_title_end;

       	l_document := l_document||table_start;
       	l_document := l_document||tr_start;
        -- 'Transaction date'
        l_document := l_document || th_text || l_prompts(8) || td_end;
        -- 'Posted Date'
        l_document := l_document || th_text || l_prompts(9) || td_end;
        -- 'Transaction Amount'
        l_document := l_document || th_number || l_prompts(7) || td_end;
        -- 'Billed Amount'
        l_document := l_document || th_number || l_prompts(2) || td_end;
--Notification Esc :
        -- 'Merchant Name'
        l_document := l_document || th_text || l_prompts(3) || td_end;
        -- 'Location'
        l_document := l_document || th_text || l_prompts(10) || td_end;
        -- 'Report Number'
        l_document := l_document || th_text || l_prompts(4) || td_end;
        -- 'Status'
        l_document := l_document || th_text || l_prompts(5) || td_end;
        l_document := l_document || tr_end;
  end if;

  --------------------------------------------------------------
  l_debugInfo := 'Get WF CARD_PROG_ID Item Attribute';
  --------------------------------------------------------------
  l_cardProgramId := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'CARD_PROG_ID');
  --------------------------------------------------------------
  l_debugInfo := 'Get WF EMPLOYEE_ID Item Attribute';
  --------------------------------------------------------------
  l_employeeId := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'EMPLOYEE_ID');
  l_dateFormat := icx_sec.getID(icx_sec.PV_DATE_FORMAT);

  l_debugInfo := 'Loop over all the Dunning Charges ';

  IF (NOT AP_WEB_DB_CCARD_PKG.GetDunningCcardTrxnCursor(l_cardProgramId,
			l_employeeId, l_min_bucket, l_max_bucket,
			l_Dunning_cursor)) THEN
     NULL;
  END IF;
  LOOP
      FETCH l_Dunning_cursor
      INTO  l_transaction_date,
	    l_merchant_name1,
	    l_billed_amount,
	    l_billed_currency_code,
            l_posted_currency_code, --bug 3339380
	    l_expense_report_number,
	    l_expense_report_status,
	    l_billed_date,
      l_posted_date, --Notification Esc
      l_transaction_amount,--Notification Esc
      l_location,  --Notification Esc
      l_trxID;			-- Bug 3241358


      EXIT WHEN l_Dunning_cursor%NOTFOUND;
--Notification Esc
      IF lengthb(l_document) >= l_document_max THEN
         -- Appends document to end of document (CLOB object)
         WF_NOTIFICATION.WriteToClob(document,l_document);
         l_document := '';
      END IF;
--Notification Esc

	BEGIN
	select 	displayed_field
	into	l_displayed_status
	from 	ap_lookup_codes
	where	lookup_type = AP_WEB_OA_ACTIVE_PKG.C_EXPENSE_REPORT_STATUS
	and	lookup_code = l_expense_report_status;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN NULL;
	END;
     IF (display_type = 'text/plain') THEN
      	--------------------------------------------
      	l_debugInfo := 'Format Expense Line Info';
      	--------------------------------------------
        --Bug 3339380 : Added posted currency code to Transaction Amount
        l_lineInfo := to_char(l_transaction_date,l_dateFormat) || ' ' ||  to_char(l_posted_date,l_dateFormat) || ' ' ||
                      to_char(l_transaction_amount, FND_CURRENCY.Get_Format_Mask(l_posted_currency_code,22)) || '   ' || l_posted_currency_code|| ' ' ||
                      to_char(l_billed_amount, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22)) || ' ' ||
                      l_merchant_name1 || ' ' || l_location || ' ' ||
                      l_expense_report_number || ' ' ||
                      l_displayed_status;

       	-- set a new line
       	l_document := l_document || '
 ' ;
        l_document := l_document || l_lineInfo;
       	l_lineInfo := '';
      ELSE  -- HTML type
      	l_document := l_document || tr_start;

--Amulya Mishra Notification Esc:

     	 l_document := l_document ||td_text || to_char(l_transaction_date,l_dateFormat) ||td_end;
     	 l_document := l_document ||td_text || to_char(l_posted_date,l_dateFormat) ||td_end;
          --Bug 3339380 : Added posted currency code to Transaction Amount
     	  l_document := l_document || td_number || to_char(l_transaction_amount, FND_CURRENCY.Get_Format_Mask(l_posted_currency_code,22));

          l_document := l_document ||  '  ' || l_posted_currency_code || td_end;


          l_document := l_document || td_number || to_char(l_billed_amount, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22)) || td_end;
          l_document := l_document || td_text || WF_NOTIFICATION.SubstituteSpecialChars(l_merchant_name1) || td_end;
     	  l_document := l_document || td_text || l_location ||td_end;
       	  l_document := l_document || td_text || l_expense_report_number || td_end;
     	  l_document := l_document || td_text || l_displayed_status || td_end;
          l_document := l_document || tr_end;

      END IF;

  END LOOP;

  close l_Dunning_cursor;

--AMulya Mishra : Notification Esc:

    if (display_type = 'text/html') then
        l_document := l_document||table_end|| indent_end;
        l_document := l_document || '<br><br>';
    end if;
    WF_NOTIFICATION.WriteToClob(document,l_document); --Notification Esc

    l_document := '';


--Amulya Mishra : Notification Esc Project:   Disputed Trxns

    IF (AP_WEB_DB_CCARD_PKG.GetTotalNumberDispute(l_cardProgramId,l_employeeId,
                       l_min_bucket, l_max_bucket ,
                       l_grace_days,l_total_dispute,
                       l_total_amt_dispute)) THEN
        NULL;
    END IF;

   IF l_total_dispute > 0 THEN  --Bug 3326035
    if (display_type = 'text/plain') then
      l_document := '';
    else  -- html
       FND_MESSAGE.SET_NAME('SQLAP','OIE_DISPUTED_HEADER_DUNNING');
       l_dispute_header_prompt := FND_MESSAGE.GET;
       l_document := indent_start||table_title_start|| l_dispute_header_prompt ||table_title_end;
       l_document := l_document|| table_start;
       l_document := l_document|| tr_start;

       -- 'Transaction Date'
       l_document := l_document || th_text|| l_prompts(8) || td_end;
       -- 'Posted Date'
       l_document := l_document || th_text|| l_prompts(9) || td_end;
       -- 'Transaction Amount'
       l_document := l_document || th_number|| l_prompts(7) || td_end;
       -- 'Billed Amount'
       l_document := l_document || th_number|| l_prompts(2) || td_end;
       -- 'Merchant Name'
       l_document := l_document || th_text|| l_prompts(3) || td_end;
       -- 'Location'
       l_document := l_document || th_text|| l_prompts(10) ||td_end;
       l_document := l_document || tr_end;

    end if;

    l_debugInfo := 'Loop over all the Disputed Charges ';

    IF (NOT AP_WEB_DB_CCARD_PKG.GetDisputeCcardTrxnCursor(l_cardProgramId,
			l_employeeId, l_min_bucket, l_max_bucket,l_grace_days,
			l_Dispute_cursor)) THEN
       NULL;
    END IF;

    LOOP
      FETCH l_Dispute_cursor
      INTO  l_transaction_date,
	    l_merchant_name1,
	    l_billed_amount,
	    l_billed_currency_code,
            l_posted_currency_code,--3339380
	    l_billed_date,
      l_posted_date, --Notification Esc
      l_transaction_amount,--Notification Esc
      l_location;  --Notification Esc


      EXIT WHEN l_Dispute_cursor%NOTFOUND;

--Amulya Mishra : Notification Esc Project

      IF lengthb(l_document) >= l_document_max THEN
         -- Appends document to end of document (CLOB object)
         WF_NOTIFICATION.WriteToClob(document,l_document);
         l_document := '';
      END IF;
--Amulya Mishra : Notification Esc Project

      IF (display_type = 'text/plain') THEN
      	--------------------------------------------
      	l_debugInfo := 'Format Expense Line Info';
      	--------------------------------------------
        --Bug 3339380 : Added posted currency code to Transaction Amount
        l_lineInfo := to_char(l_transaction_date,l_dateFormat) || ' ' ||  to_char(l_posted_date,l_dateFormat) || ' ' ||
                      to_char(l_transaction_amount, FND_CURRENCY.Get_Format_Mask(l_posted_currency_code,22)) || '  ' ||  l_posted_currency_code || ' ' ||
                      to_char(l_billed_amount, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22)) || ' ' ||
                      l_merchant_name1 || ' ' || l_location;

       	-- set a new line

 -- set a new line
        l_document := l_document || '
 ' ;
        l_document := l_document || l_lineInfo;

       	l_lineInfo := '';

      ELSE  -- HTML type

      	l_document := l_document || tr_start;
     	l_document := l_document || td_text|| to_char(l_transaction_date,l_dateFormat) ||td_end;
     	l_document := l_document || td_text|| to_char(l_posted_date,l_dateFormat) ||td_end;
        --Bug 3339380 : Added posted currency code to Transaction Amount
     	l_document := l_document || td_number|| to_char(l_transaction_amount, FND_CURRENCY.Get_Format_Mask(l_posted_currency_code,22));

        l_document := l_document ||  '  ' || l_posted_currency_code ||td_end;

        l_document := l_document || td_number|| to_char(l_billed_amount, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22)) || td_end;
        l_document := l_document || td_text || WF_NOTIFICATION.SubstituteSpecialChars(l_merchant_name1) || td_end;
     	l_document := l_document || td_text|| l_location ||td_end;
        l_document := l_document || tr_end;


      END IF;
    END LOOP;

    close l_Dispute_cursor;
 END IF; --End of IF l_total_dispute > 0 - bug 3326035
    if (display_type = 'text/html') then
        l_document := l_document || table_end||indent_end;
    end if;
    WF_NOTIFICATION.WriteToClob(document,l_document); --Notification Esc
    document_type := display_type;

--Amulya Mishra : Notification esc project :

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_EXPENSE_WF', 'GenerateDunningClobList',
                    document_id, l_debugInfo);
    raise;
END GenerateDunningClobList;



PROCEDURE getNumofUnsubmittedrecords(document_id IN VARCHAR2,
				display_type	 IN VARCHAR2,
				document	 IN OUT NOCOPY VARCHAR2,
				document_type	 IN OUT NOCOPY VARCHAR2) IS

  l_colon    			NUMBER;
  l_itemtype 			VARCHAR2(7);
  l_itemkey  			VARCHAR2(15);
  l_cardProgramId 		AP_WEB_DB_CCARD_PKG.ccTrxn_cardProgID;
  l_employeeId    		AP_WEB_DB_CCARD_PKG.cards_employeeID;
  l_dateFormat    		VARCHAR2(30);
  l_transaction_date		AP_WEB_DB_CCARD_PKG.ccTrxn_transDate;
  l_merchant_name1		AP_WEB_DB_CCARD_PKG.ccTrxn_merchantName1;
  l_billed_amount		AP_WEB_DB_CCARD_PKG.ccTrxn_billedAmount;
  l_billed_date 		AP_WEB_DB_CCARD_PKG.ccTrxn_billedDate;
  l_billed_currency_code	AP_WEB_DB_CCARD_PKG.ccTrxn_billedCurrCode;
  l_lineInfo			VARCHAR2(2000);
  l_debugInfo                  	VARCHAR2(1000);
  l_orgId    			NUMBER;
  l_Total_cursor    		AP_WEB_DB_CCARD_PKG.UnsubmittedCCTrxnCursor;
  l_expense_report_number	VARCHAR2(60);
  l_expense_report_status	VARCHAR2(30);
  l_displayed_status		VARCHAR2(60);
  l_instructions		VARCHAR2(2000);

  l_billedStartDate 		AP_WEB_DB_CCARD_PKG.ccTrxn_billedDate;
  l_billedEndDate 		AP_WEB_DB_CCARD_PKG.ccTrxn_billedDate;
  l_minimumAmount 		AP_WEB_DB_CCARD_PKG.ccTrxn_billedAmount;
  l_chargeType	 		VARCHAR2(60);
  l_trxID                       AP_WEB_DB_CCARD_PKG.ccTrxn_trxID;

BEGIN


  l_debugInfo := 'Decode document_id';
  l_colon    := instrb(document_id, ':');
  l_debugInfo := l_debugInfo || ' First index: ' || to_char(l_colon);
  l_itemtype := substrb(document_id, 1, l_colon - 1);
  l_itemkey  := substrb(document_id, l_colon  + 1);

  l_debugInfo := 'Get org_id';
  l_orgId := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemKey, 'ORG_ID');

  -- MOAC UPTAKE --
  -- Have new call back function defined for Item to set org context.
  --
  -- l_debugInfo := 'Set Org context';
  -- fnd_client_info.set_org_context(l_orgId);

  --------------------------------------------------------------
  l_debugInfo := 'Get WF CARD_PROG_ID Item Attribute';
  --------------------------------------------------------------
  l_cardProgramId := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'CARD_PROG_ID');

  --------------------------------------------------------------
  l_debugInfo := 'Get WF EMPLOYEE_ID Item Attribute';
  --------------------------------------------------------------
  l_employeeId := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'EMPLOYEE_ID');

  ------------------------------------------------------
  l_debugInfo := 'Get WF MIN_AMOUNT Item Attribute';
  ------------------------------------------------------
  l_minimumAmount := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'MIN_AMOUNT');

  ------------------------------------------------------
  l_debugInfo := 'Get WF DATE1 Item Attribute';
  ------------------------------------------------------
  l_billedStartDate := WF_ENGINE.GetItemAttrDate(l_itemType, l_itemKey, 'DATE1');

  ------------------------------------------------------
  l_debugInfo := 'Get WF DATE2 Item Attribute';
  ------------------------------------------------------
  l_billedEndDate := WF_ENGINE.GetItemAttrDate(l_itemType, l_itemKey, 'DATE2');

  --------------------------------------------------------------
  l_debugInfo := 'Get Charge Type Item Attribute';
  --------------------------------------------------------------
  l_chargeType := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'CHARGE_TYPE');

  l_dateFormat := icx_sec.getID(icx_sec.PV_DATE_FORMAT);

  IF (NOT AP_WEB_DB_CCARD_PKG.GetTotalUnsubmittedCCCursor(l_cardProgramId,
			l_employeeId, l_billedStartDate,
			l_billedEndDate, l_minimumAmount, l_chargeType, l_Total_cursor)) THEN
     NULL;
  END IF;

  LOOP
      FETCH l_Total_cursor
      INTO  l_transaction_date,
	    l_merchant_name1,
	    l_billed_amount,
	    l_billed_currency_code,
	    l_expense_report_number,
	    l_expense_report_status,
	    l_trxID;                    -- Bug 3241358

      EXIT WHEN l_Total_cursor%NOTFOUND;
  END LOOP;
	if(l_Total_cursor%ROWCOUNT>= 40) then
  		FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_NUM_RECORDS');
		FND_MESSAGE.SET_TOKEN('NUMBER_OF_TRANS', l_Total_cursor%ROWCOUNT);
      	 	l_instructions := FND_MESSAGE.GET;
                document := document || '<table>';
                document := document || '<tr>' || '&' || 'nbsp;</tr>';
                document := document || '<tr>' || '&' || 'nbsp;</tr>';
                document := document || '<tr>' ||td_text|| l_instructions || '</td></tr>';
                document := document || '</table>';

       end if;

  close l_Total_cursor;

    if (display_type = 'text/html') then
        document := document || '</table>';
    end if;

    document_type := display_type;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_EXPENSE_WF', 'getNumofUnsubmittedrecords',
                    document_id, l_debugInfo);
    raise;
END getNumofUnsubmittedrecords;


PROCEDURE getNumofDunningrecords(document_id		IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY VARCHAR2,
				document_type	IN OUT NOCOPY VARCHAR2) IS

  l_colon    			NUMBER;
  l_itemtype 			VARCHAR2(7);
  l_itemkey  			VARCHAR2(15);
  l_cardProgramId 		AP_WEB_DB_CCARD_PKG.ccTrxn_cardProgID;
  l_employeeId    		AP_WEB_DB_CCARD_PKG.cards_employeeID;
  l_dateFormat    		VARCHAR2(30);
  l_transaction_date		AP_WEB_DB_CCARD_PKG.ccTrxn_transDate;
  l_merchant_name1		AP_WEB_DB_CCARD_PKG.ccTrxn_merchantName1;
  l_billed_amount		AP_WEB_DB_CCARD_PKG.ccTrxn_billedAmount;
  l_billed_date 		AP_WEB_DB_CCARD_PKG.ccTrxn_billedDate;
  l_billed_currency_code	AP_WEB_DB_CCARD_PKG.ccTrxn_billedCurrCode;
  l_lineInfo			VARCHAR2(2000);
  l_debugInfo                  	VARCHAR2(1000);
  l_orgId    			NUMBER;
  l_Total_cursor    		AP_WEB_DB_CCARD_PKG.TotalCCTrxnCursor;
  l_expense_report_number	VARCHAR2(60);
  l_expense_report_status	VARCHAR2(30);
  l_displayed_status		VARCHAR2(60);
  l_min_bucket			NUMBER;
  l_max_bucket 			NUMBER;
  l_min_bucket1			VARCHAR2(30);
  l_max_bucket1			VARCHAR2(30);
  l_instructions		VARCHAR2(2000);
  l_trxID                       AP_WEB_DB_CCARD_PKG.ccTrxn_trxID;

BEGIN


  l_debugInfo := 'Decode document_id';
  l_colon    := instrb(document_id, ':');
  l_debugInfo := l_debugInfo || ' First index: ' || to_char(l_colon);
  l_itemtype := substrb(document_id, 1, l_colon - 1);
  l_itemkey  := substrb(document_id, l_colon  + 1);

  l_debugInfo := 'Get org_id';
  l_orgId := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemKey, 'ORG_ID');

  -- MOAC UPTAKE --
  -- Have new call back function defined for Item to set org context.
  --
  -- l_debugInfo := 'Set Org context';
  -- fnd_client_info.set_org_context(l_orgId);

  --------------------------------------------------------------
  l_debugInfo := 'Get WF CARD_PROG_ID Item Attribute';
  --------------------------------------------------------------
  l_cardProgramId := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'CARD_PROG_ID');

  --------------------------------------------------------------
  l_debugInfo := 'Get WF EMPLOYEE_ID Item Attribute';
  --------------------------------------------------------------
  l_employeeId := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'EMPLOYEE_ID');

  --------------------------------------------------------------
  l_debugInfo := 'Get WF BUCKET1..4 Item Attribute';
  --------------------------------------------------------------
  l_min_bucket1 := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'BUCKET1');
  l_max_bucket1 := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'BUCKET2');


  l_min_bucket := to_number(l_min_bucket1);
  if(l_max_bucket1 = '+' ) then
	l_max_bucket := 1000000;
  else
	l_max_bucket := to_number(substr(l_max_bucket1,3));
  end if;

  l_dateFormat := icx_sec.getID(icx_sec.PV_DATE_FORMAT);

  IF (NOT AP_WEB_DB_CCARD_PKG.GetTotalCcardTrxnCursor(l_cardProgramId,
			l_employeeId, l_min_bucket, l_max_bucket,
			l_Total_cursor)) THEN
     NULL;
  END IF;

  LOOP
      FETCH l_Total_cursor
      INTO  l_transaction_date,
	    l_merchant_name1,
	    l_billed_amount,
	    l_billed_currency_code,
	    l_expense_report_number,
	    l_expense_report_status,
	    l_billed_date,
	    l_trxID;                    -- Bug 3241358

      EXIT WHEN l_Total_cursor%NOTFOUND;
  END LOOP;
	if(l_Total_cursor%ROWCOUNT>= 40) then
  		FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_NUM_RECORDS');
		FND_MESSAGE.SET_TOKEN('NUMBER_OF_TRANS', l_Total_cursor%ROWCOUNT);
      	 	l_instructions := FND_MESSAGE.GET;
                document := document || '<table>';
                document := document || '<tr>' || '&' || 'nbsp;</tr>';
                document := document || '<tr>' || '&' || 'nbsp;</tr>';
                document := document || '<tr>' ||td_text|| l_instructions || '</td></tr>';
                document := document || '</table>';

       end if;

  close l_Total_cursor;

    if (display_type = 'text/html') then
        document := document || '</table>';
    end if;

    document_type := display_type;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_EXPENSE_WF', 'getNumofDunningrecords',
                    document_id, l_debugInfo);
    raise;
END getNumofDunningrecords;


/*Written By: Amulya Mishra
  Purpose :   Notification Escalation project.
              Procedure that prints the body of manager's notification
              Body.
*/

PROCEDURE GenerateManagerDunningList(document_id IN VARCHAR2,
				display_type	 IN VARCHAR2,
				document	 IN OUT NOCOPY CLOB,
				document_type	 IN OUT NOCOPY VARCHAR2) IS

  l_colon    			NUMBER;
  l_itemtype 			VARCHAR2(7);
  l_itemkey  			VARCHAR2(15);
  l_cardProgramId 		AP_WEB_DB_CCARD_PKG.ccTrxn_cardProgID;
  l_employeeId    		AP_WEB_DB_CCARD_PKG.cards_employeeID;
  l_dateFormat    		VARCHAR2(30);
  l_billed_currency_code	AP_WEB_DB_CCARD_PKG.ccTrxn_billedCurrCode;
  l_lineInfo			VARCHAR2(2000);
  l_debugInfo                  	VARCHAR2(1000);
  l_orgId    			NUMBER;
  l_min_bucket			NUMBER;
  l_max_bucket 			NUMBER;
  l_min_bucket1			VARCHAR2(30);
  l_max_bucket1			VARCHAR2(30);
  l_prompts			AP_WEB_UTILITIES_PKG.prompts_table;
  l_title			AK_REGIONS_VL.name%TYPE;

  l_document      		 long ;
  l_document_max  		 NUMBER := 25000;

  l_detail_header_prompt 	 VARCHAR2(2000);
  l_grace_days            	 NUMBER;

  l_employee_cursor   EmployeeCursor;
  l_supervisor_id     NUMBER;

  l_employee_name 		 PER_PEOPLE_F.FULL_NAME%TYPE;

  l_total_outstanding   NUMBER;
  l_total_amt_outstanding  NUMBER;
  l_total_dispute  NUMBER;
  l_total_amt_dispute  NUMBER;
  l_total_amount   NUMBER;

  l_total_num_outstanding        NUMBER := 0; --Bug 3310243

  l_gross_outstanding NUMBER := 0;
  l_gross_amount     NUMBER := 0;

  l_count     NUMBER := 0; --Direct Report


BEGIN


  l_debugInfo := 'Decode document_id';
  l_colon    := instrb(document_id, ':');
  l_debugInfo := l_debugInfo || ' First index: ' || to_char(l_colon);
  l_itemtype := substrb(document_id, 1, l_colon - 1);
  l_itemkey  := substrb(document_id, l_colon  + 1);

  l_debugInfo := 'Get org_id';
  l_orgId := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemKey, 'ORG_ID');

  -- MOAC UPTAKE --
  -- Have new call back function defined for Item to set org context.
  --
  -- l_debugInfo := 'Set Org context';
  -- fnd_client_info.set_org_context(l_orgId);
  ------------------------------------------------------------
  l_debugInfo := 'Get prompts';
  ------------------------------------------------------------
  AP_WEB_DISC_PKG.getPrompts(200,'AP_WEB_WF_CC_LINETABLE',l_title,l_prompts);



  l_debugInfo := 'Generate header';
  l_document := '';

  l_grace_days := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'AGING_GRACE_DAYS');

  l_billed_currency_code := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'CURRENCY');
  --------------------------------------------------------------
  l_debugInfo := 'Get WF BUCKET1..4 Item Attribute';
  --------------------------------------------------------------
  l_min_bucket1 := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'BUCKET1');
  l_max_bucket1 := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'BUCKET2');

  l_min_bucket := to_number(l_min_bucket1);
  if(l_max_bucket1 = '+' ) then
	l_max_bucket := 1000000;
  else
	l_max_bucket := to_number(substr(l_max_bucket1,3));
  end if;

  if (display_type = 'text/plain') then
      l_document := '';
  else  -- html

        FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_SUMMARY_OUTSTANDING_MSG');
       l_detail_header_prompt := FND_MESSAGE.GET;

       l_document := indent_start||table_title_start || l_detail_header_prompt ||table_title_end;

       	l_document := l_document || table_start||tr_start;
        -- 'Employee'
        l_document := l_document || th_text|| l_prompts(11) || td_end;
        -- 'Number Outstanding'
        l_document := l_document || th_number || l_prompts(12) || td_end;
        -- 'Disputes Outstanding'
        l_document := l_document || th_number || l_prompts(13) || td_end;
        -- 'Aging Period Outstanding'
        l_document := l_document || th_number || l_prompts(14) ||td_end;
        -- 'Total Outstanding'
        l_document := l_document || th_number || l_prompts(15) || td_end;
        l_document := l_document || tr_end;
  end if;


  --------------------------------------------------------------
  l_debugInfo := 'Get WF CARD_PROG_ID Item Attribute';
  --------------------------------------------------------------
  l_cardProgramId := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'CARD_PROG_ID');
  --------------------------------------------------------------
  l_debugInfo := 'Get WF EMPLOYEE_ID Item Attribute';
  --------------------------------------------------------------
  l_employeeId := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'EMPLOYEE_ID');
  l_dateFormat := icx_sec.getID(icx_sec.PV_DATE_FORMAT);

  l_debugInfo := 'Loop over all the Dunning Charges ';

  AP_WEB_EXPENSE_WF.GetManager(l_employeeId, l_supervisor_id);

  IF (NOT GetEmployeeCursor(l_supervisor_id,l_employee_cursor)) THEN
    NULL;
  END IF;

  LOOP
      FETCH l_employee_cursor
      INTO  l_employeeId,l_employee_name;


      EXIT WHEN l_employee_cursor%NOTFOUND;

      IF (AP_WEB_DB_CCARD_PKG.GetTotalNumberOutstanding(l_cardProgramId,l_employeeId,
                       l_min_bucket, l_max_bucket , l_total_outstanding,
                       l_total_amt_outstanding)) THEN
        NULL;
      END IF;



      IF (AP_WEB_DB_CCARD_PKG.GetTotalNumberDispute(l_cardProgramId,l_employeeId,
                       l_min_bucket, l_max_bucket ,
                       l_grace_days,l_total_dispute,
                       l_total_amt_dispute)) THEN
        NULL;
      END IF;



      IF (NOT AP_WEB_DB_CCARD_PKG.GetTotalCreditCardAmount(l_cardProgramId,l_employeeId,
                                                 l_total_amount ) ) THEN
        NULL;
      END IF;



      IF lengthb(l_document) >= l_document_max THEN
         -- Appends document to end of document (CLOB object)
         WF_NOTIFICATION.WriteToClob(document,l_document);
         l_document := '';
      END IF;

      IF ((nvl(l_total_outstanding,0) <> 0 OR nvl(l_total_dispute,0) <> 0) AND l_count <= 100) THEN  --Direct Report

        l_total_amt_outstanding := nvl(l_total_amt_outstanding,0) +  nvl(l_total_amt_dispute,0);

        --Bug 3310243
        l_total_num_outstanding := nvl(l_total_outstanding,0) + nvl(l_total_dispute,0);

        IF (display_type = 'text/plain') THEN

        	--------------------------------------------
        	-- 'Format Expense Line Info';
        	--------------------------------------------

        	l_lineInfo := l_employee_name || ' ' || l_total_num_outstanding || ' ' || l_total_dispute
    			       || ' ' || l_total_amt_outstanding ||' '|| l_total_amount ;
        	-- set a new line
       		 l_document := l_document || ' ' || l_lineInfo;
	       	l_lineInfo := '';
        ELSE  -- HTML type

          l_document := l_document || tr_start;

     	  l_document := l_document || td_text|| l_employee_name ||td_end;
     	  l_document := l_document || td_number|| l_total_num_outstanding ||td_end;
     	  l_document := l_document || td_number ||l_total_dispute||td_end;
          l_document := l_document || td_number||  LPAD(to_char(l_total_amt_outstanding, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22)),14) || td_end;
          l_document := l_document || td_number || LPAD(to_char(l_total_amount, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22)),14) || td_end;

          l_document := l_document || tr_end;

         END IF;

         l_count := l_count + 1;

   END IF;

   IF (l_count > 100) THEN
     l_total_amt_outstanding := nvl(l_total_amt_outstanding,0) +  nvl(l_total_amt_dispute,0);
   END IF;

   l_gross_outstanding := l_gross_outstanding + nvl(l_total_amt_outstanding,0);
   l_gross_amount := l_gross_amount + nvl(l_total_amount,0);

  END LOOP;
  close l_employee_cursor;


  --------------------------------------------
      l_debugInfo := 'Generate Total Row';
  --------------------------------------------

  l_document := l_document || tr_start;
  l_document := l_document || '<td colspan=3 style="{font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt;font-weight:bold;background-color:#cccc99;color:#336699;vertical-align:bottom;text-align:right}">' || l_prompts(17) || td_end;

  l_document := l_document || td_number|| LPAD(to_char(l_gross_outstanding, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22)),14)  || td_end;
  l_document := l_document || td_number || LPAD(to_char(l_gross_amount, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22)),14)  || td_end;

  l_document := l_document || tr_end;

    if (display_type = 'text/html') then
        l_document := l_document||table_end|| indent_end;
        l_document := l_document || '<br><br>';
    end if;
    WF_NOTIFICATION.WriteToClob(document,l_document); --Notification Esc
    document_type := display_type;


EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_EXPENSE_WF', 'GenerateManagerDunningList',
                    document_id, l_debugInfo);
    raise;
END GenerateManagerDunningList;

-------------------------------------------------------------------------

/*Written By: Amulya Mishra
  Purpose :   Notification Escalation project.
              Procedure that prints the body of next manager's notification
              Body.
*/

PROCEDURE GenerateNextManagerDunningList(document_id	IN VARCHAR2,
					display_type	IN VARCHAR2,
					document	IN OUT NOCOPY CLOB,
					document_type	IN OUT NOCOPY VARCHAR2) IS

  l_colon    			NUMBER;
  l_itemtype 			VARCHAR2(7);
  l_itemkey  			VARCHAR2(15);
  l_cardProgramId 		AP_WEB_DB_CCARD_PKG.ccTrxn_cardProgID;
  l_employeeId    		AP_WEB_DB_CCARD_PKG.cards_employeeID;
  l_dateFormat    		VARCHAR2(30);
  l_billed_currency_code	AP_WEB_DB_CCARD_PKG.ccTrxn_billedCurrCode;
  l_lineInfo			VARCHAR2(2000);
  l_debugInfo                  	VARCHAR2(1000);
  l_orgId    			NUMBER;
  l_min_bucket			NUMBER;
  l_max_bucket 			NUMBER;
  l_min_bucket1			VARCHAR2(30);
  l_max_bucket1			VARCHAR2(30);
  l_prompts			AP_WEB_UTILITIES_PKG.prompts_table;
  l_title			AK_REGIONS_VL.name%TYPE;

  l_document      		 long ;
  l_document_max  		 NUMBER := 25000;

  l_detail_header_prompt 	 VARCHAR2(2000);
  l_grace_days            	 NUMBER;

  l_employee_cursor              EmployeeCursor;
  l_supervisor_id                NUMBER;

  l_supervisor_name              PER_PEOPLE_F.FULL_NAME%TYPE;
  l_supervisor_display_name      PER_PEOPLE_F.FULL_NAME%TYPE;

  l_direct_manager_name          PER_PEOPLE_F.FULL_NAME%TYPE;  --Direct Report
  l_count                        NUMBER := 0; --Direct Report

  l_employee_name 		 PER_PEOPLE_F.FULL_NAME%TYPE;
  l_employee_display_name        PER_PEOPLE_F.FULL_NAME%TYPE;

  l_total_outstanding            NUMBER;
  l_total_amt_outstanding        NUMBER;
  l_total_dispute                NUMBER;
  l_total_amt_dispute            NUMBER;
  l_total_amount                 NUMBER;

  l_gross_outstanding            NUMBER := 0;
  l_gross_amount                 NUMBER := 0;


  l_final_manager_id             NUMBER; --bug 3337443
  l_direct_report_name           PER_PEOPLE_F.FULL_NAME%TYPE; --Bug 3337443

  l_level                        NUMBER := 0;  --Bug 3337388
  l_dunning_number               NUMBER;       --Bug 3337388

  l_total_num_outstanding        NUMBER := 0; --bug 3310243




BEGIN

  l_debugInfo := 'Decode document_id';
  l_colon    := instrb(document_id, ':');
  l_debugInfo := l_debugInfo || ' First index: ' || to_char(l_colon);
  l_itemtype := substrb(document_id, 1, l_colon - 1);
  l_itemkey  := substrb(document_id, l_colon  + 1);

  l_debugInfo := 'Get org_id';
  l_orgId := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemKey, 'ORG_ID');

  l_supervisor_id := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemKey, 'AGING_MANAGER_ID');
  l_final_manager_id := l_supervisor_id; --Bug 3337443

  -- MOAC UPTAKE --
  -- Have new call back function defined for Item to set org context.
  --
  -- l_debugInfo := 'Set Org context';
  -- fnd_client_info.set_org_context(l_orgId);
  ------------------------------------------------------------
  l_debugInfo := 'Get prompts';
  ------------------------------------------------------------
  AP_WEB_DISC_PKG.getPrompts(200,'AP_WEB_WF_CC_LINETABLE',l_title,l_prompts);


  l_debugInfo := 'Generate header';
  l_document := '';

  l_grace_days := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'AGING_GRACE_DAYS');

  l_billed_currency_code := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'CURRENCY');
  --------------------------------------------------------------
  l_debugInfo := 'Get WF BUCKET1..4 Item Attribute';
  --------------------------------------------------------------
  l_min_bucket1 := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'BUCKET1');
  l_max_bucket1 := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'BUCKET2');

  l_min_bucket := to_number(l_min_bucket1);
  if(l_max_bucket1 = '+' ) then
	l_max_bucket := 1000000;
  else
	l_max_bucket := to_number(substr(l_max_bucket1,3));
  end if;

  if (display_type = 'text/plain') then
      l_document := '';
  else  -- html

        FND_MESSAGE.SET_NAME('SQLAP','OIE_CC_SUMMARY_BY_EMPLOYEE');  --Direct Reports
        l_detail_header_prompt := FND_MESSAGE.GET;

        l_document := indent_start||table_title_start || l_detail_header_prompt || table_title_end;

        l_document := l_document||table_start;
        l_document := l_document||tr_start;

        -- 'Employee'
        l_document := l_document || th_text || l_prompts(11) || td_end;
        -- 'Employee's Supervisor'
        l_document := l_document || th_text || l_prompts(16) || td_end;
        -- 'Direct Report'
        l_document := l_document || th_text || l_prompts(18) || td_end; --Direct Reports
        -- 'Number Outstanding'
        l_document := l_document || th_number || l_prompts(12) || td_end;
        -- 'Disputes Outstanding'
        l_document := l_document || th_number || l_prompts(13) || td_end;
        -- 'Aging Period Outstanding'
        l_document := l_document || th_number || l_prompts(14) || td_end;
        -- 'Total Outstanding'
        l_document := l_document || th_number || l_prompts(15) || td_end;

        l_document := l_document || tr_end;
  end if;

  --------------------------------------------------------------
  l_debugInfo := 'Get WF CARD_PROG_ID Item Attribute';
  --------------------------------------------------------------
  l_cardProgramId := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'CARD_PROG_ID');
  --------------------------------------------------------------
  l_debugInfo := 'Get WF EMPLOYEE_ID Item Attribute';
  --------------------------------------------------------------
  l_employeeId := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'EMPLOYEE_ID');
  l_dateFormat := icx_sec.getID(icx_sec.PV_DATE_FORMAT);

  l_debugInfo := 'Loop over all the Dunning Charges ';

  l_dunning_number := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'DUNNING_NUMBER'); --Bug 3337388

--  IF (NOT GetHierarchialEmployeeCursor(l_supervisor_id,l_employee_cursor)) THEN
--   5049215 -- Added the dunning number to the function level as only records of this dunning level are processed later.
  IF (NOT GetHierarchialEmployeeCursor(l_supervisor_id,l_employee_cursor, l_dunning_number)) THEN
    NULL;
  END IF;

  LOOP
      FETCH l_employee_cursor
      INTO  l_employeeId,l_supervisor_id,l_level;  --Direct Report --Bug 3337388


      EXIT WHEN l_employee_cursor%NOTFOUND;


      IF (AP_WEB_DB_CCARD_PKG.GetTotalNumberOutstanding(l_cardProgramId,l_employeeId,
                       l_min_bucket, l_max_bucket , l_total_outstanding,
                       l_total_amt_outstanding)) THEN
        NULL;
      END IF;

      IF (AP_WEB_DB_CCARD_PKG.GetTotalNumberDispute(l_cardProgramId,l_employeeId,
                       l_min_bucket, l_max_bucket ,
                       l_grace_days,l_total_dispute,
                       l_total_amt_dispute)) THEN
        NULL;
      END IF;

      IF (NOT AP_WEB_DB_CCARD_PKG.GetTotalCreditCardAmount(l_cardProgramId,l_employeeId,
                                                 l_total_amount ) ) THEN
        NULL;
      END IF;


      IF lengthb(l_document) >= l_document_max THEN
         -- Appends document to end of document (CLOB object)
         WF_NOTIFICATION.WriteToClob(document,l_document);
         l_document := '';
      END IF;

    --Bug 3337388: If l_level is not as dunning number then dont disply thoese employee's records.

    IF ((nvl(l_total_outstanding,0) <> 0 OR nvl(l_total_dispute,0) <> 0)
                   AND l_count <= 100 AND l_level = l_dunning_number) THEN  --Direct Report

      l_total_amt_outstanding := nvl(l_total_amt_outstanding,0) + nvl(l_total_amt_dispute,0);

      --Bug 3310243
      l_total_num_outstanding := nvl(l_total_outstanding,0) + nvl(l_total_dispute,0);

      WF_DIRECTORY.GetUserName('PER', l_supervisor_id, l_supervisor_name, l_supervisor_display_name);
      WF_DIRECTORY.GetUserName('PER', l_employeeId, l_employee_name, l_employee_display_name);
--Bug 3337443
      l_direct_report_name :=  GetDirectReport(l_employeeId , l_final_manager_id );

      IF (display_type = 'text/plain') THEN
      	--------------------------------------------
      	-- 'Format Expense Line Info';
      	--------------------------------------------

      	l_lineInfo := l_employee_display_name || ' ' || l_supervisor_display_name || ' ' || l_direct_report_name || ' '||
                      l_total_num_outstanding || ' ' || l_total_dispute || ' ' || l_total_amt_outstanding ||' '|| l_total_amount ;--Direct Report
       	-- set a new line
       	l_document := l_document || ' ' || l_lineInfo;
       	l_lineInfo := '';
      ELSE  -- HTML type

          l_document := l_document || tr_start;

     	  l_document := l_document || td_text ||l_employee_display_name ||td_end;
     	  l_document := l_document || td_text||l_supervisor_display_name ||td_end;
          l_document := l_document || td_text ||l_direct_report_name ||td_end; --Direct Report
     	  l_document := l_document || td_number|| l_total_num_outstanding ||td_end;
     	  l_document := l_document || td_number|| l_total_dispute ||td_end;
          l_document := l_document || td_number||  LPAD(to_char(l_total_amt_outstanding, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22)),14) || td_end;
          l_document := l_document || td_number|| LPAD(to_char(l_total_amount, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22)),14) || td_end;

      END IF;

      l_count := l_count + 1; --Direct Report

   END IF;

   IF (l_count > 100) THEN
     l_total_amt_outstanding := nvl(l_total_amt_outstanding,0) +  nvl(l_total_amt_dispute,0);
   END IF;

  /* Bug 3386832: The totalling should be done only for that level */
   IF l_level = l_dunning_number THEN
      l_gross_outstanding := l_gross_outstanding + nvl(l_total_amt_outstanding,0);
      l_gross_amount := l_gross_amount + nvl(l_total_amount,0);
   END IF;

  END LOOP;
  close l_employee_cursor;

  --Set Outstanding total amount attribute.
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MGR_ESC_AMOUNT', l_employee_name);

  --------------------------------------------
      l_debugInfo := 'Generate Total Row';
  --------------------------------------------

  l_document := l_document || tr_start;
  l_document := l_document ||
  '<td colspan=5 style="{font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt;font-weight:bold;background-color:#cccc99;color:#336699;vertical-align:bottom;text-align:right}">' ||l_prompts(17) ||
  td_end; --Direct Report changed colspan to 5.

  l_document := l_document || td_number|| LPAD(to_char(l_gross_outstanding, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22)),14)  || td_end;
  l_document := l_document || td_number|| LPAD(to_char(l_gross_amount, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22)),14)  || td_end;

  l_document := l_document || tr_end;

    if (display_type = 'text/html') then
        l_document := l_document||table_end|| indent_end;
        l_document := l_document || '<br><br>';
    end if;
    WF_NOTIFICATION.WriteToClob(document,l_document); --Notification Esc
    document_type := display_type;


EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_EXPENSE_WF', 'GenerateNextManagerDunningList',
                    document_id, l_debugInfo);
    raise;
END GenerateNextManagerDunningList;

---------------------------------------------------------------

/*Written By: Amulya Mishra
  Purpose :   Notification Escalation project.
              Procedure that gives the employees who are reporting
              to a manager with superisor id p_supervisor_id.
*/

FUNCTION GetEmployeeCursor(
	        p_supervisor_id		IN  NUMBER,
      		p_employee_cursor OUT NOCOPY EmployeeCursor)
RETURN BOOLEAN IS
-------------------------------------

BEGIN

IF p_supervisor_id IS NULL THEN
   return FALSE;
END IF;

OPEN p_employee_cursor FOR

  SELECT emp.employee_id,emp.full_name
  FROM   per_employees_x    emp
  WHERE  emp.supervisor_id = p_supervisor_id
  AND    NOT AP_WEB_DB_HR_INT_PKG.ispersoncwk(emp.employee_id)='Y';

  return TRUE;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
     return FALSE;
     RAISE;

END GetEmployeeCursor;

-------------------------------------------------------------------

/*Written By: Amulya Mishra
  Purpose :   Notification Escalation project.
	      Gets the total outstanding amount of a bucket for employees
              directly reporting a manager.
              Sets the WF attribute MGR_ESC_AMOUNT to be shown in notification
	      Subject.
*/

PROCEDURE GetTotalOutstandingAttribute(
                 p_employee_id  IN NUMBER,
		 p_cardProgramId         IN  NUMBER,
                 p_min_bucket            IN  NUMBER,
                 p_max_bucket            IN  NUMBER,
                 p_grace_days            IN  NUMBER,
                 p_total_amount   OUT NOCOPY NUMBER) IS
-----------------------------------------------
l_supervisor_id         NUMBER;
l_employee_cursor       EmployeeCursor;
l_employee_name         per_employees_x.FULL_NAME%TYPE;
l_total_amount          NUMBER := 0;
l_total_outstanding     NUMBER;
l_total_amt_outstanding NUMBER;
l_total_dispute         NUMBER;
l_total_amt_dispute     NUMBER;
l_employee_id           NUMBER;


BEGIN
  AP_WEB_EXPENSE_WF.GetManager(p_employee_id, l_supervisor_id);

  IF (NOT GetEmployeeCursor(l_supervisor_id,l_employee_cursor)) THEN
    NULL;
  END IF;

  LOOP
      FETCH l_employee_cursor
      INTO  l_employee_id,l_employee_name;

      EXIT WHEN l_employee_cursor%NOTFOUND;

      IF (NOT AP_WEB_DB_CCARD_PKG.GetTotalNumberOutstanding(p_cardProgramId,l_employee_id,
                       p_min_bucket, p_max_bucket , l_total_outstanding,
                       l_total_amt_outstanding)) THEN
        NULL;
      END IF;

      IF (AP_WEB_DB_CCARD_PKG.GetTotalNumberDispute(p_cardProgramId,l_employee_id,
                       p_min_bucket, p_max_bucket ,
                       p_grace_days,l_total_dispute,
                       l_total_amt_dispute)) THEN
        NULL;
      END IF;


      l_total_amount := l_total_amount + nvl(l_total_amt_outstanding,0) + nvl(l_total_amt_dispute,0);

 END LOOP;

 close l_employee_cursor;

 p_total_amount := l_total_amount ;


EXCEPTION
  WHEN OTHERS THEN
     p_total_amount :=0;

END  GetTotalOutstandingAttribute;

-------------------------------------------------------------------------------

/*Written By: Amulya Mishra
  Purpose :   Notification Escalation project.
              Procedure that gives the employees info ina heirarchy.
			Casey Brown(Emp Id 31)
			      |
			      |
			      |
			Horton Ms Conner Esq(Emp Id 29)
			      |
			      |
			      |
			Johnson Ms Alex(Emp Id 27)
			      /\
			     /  \
			    /    \
		Green Terry(24)	 Kerry Jones(33)
		                    /\
		                   /  \
		                  /    \
		      Jammie Frost(32) Elizabeth Smith(280)

         For Emp Id 31 passed it gives info all the employees shown above
	 with their corresponding immediate manager.

  Assumption : If There exists a LOOP Oracle Connect BY gives Error.

*/
/*

  Bug : 5049215
  Modified by : Sankar Balaji S
  Change: Added a new parameter p_level_id to the function that will scope the level that should be retrieved.
          If no level is specified, then all employees upto 6 levels gets retrieved.
*/

-------------------------------------------
FUNCTION GetHierarchialEmployeeCursor(
	        p_supervisor_id		IN  NUMBER,
      		p_employee_cursor OUT NOCOPY EmployeeCursor,
		p_level_id		IN NUMBER DEFAULT NULL)
RETURN BOOLEAN IS
-------------------------------------------

BEGIN

IF p_supervisor_id IS NULL THEN
   return FALSE;
END IF;

/*
OPEN p_employee_cursor FOR

  SELECT  employee_id,supervisor_id,level-1
      FROM per_employees_x emp
       WHERE NOT AP_WEB_DB_HR_INT_PKG.ispersoncwk(emp.employee_id)='Y'
      CONNECT BY prior employee_id = supervisor_id
      and level < 6
  START WITH employee_id = p_supervisor_id  order by 2;
*/

  IF ( p_level_id IS NOT NULL )
  THEN
     OPEN p_employee_cursor FOR
	SELECT P.PERSON_ID, H.SUPERVISOR_ID, H.LVL
	FROM PER_PEOPLE_F P,
	( SELECT UNIQUE ass.PERSON_ID,ass.SUPERVISOR_ID, LEVEL -1 LVL
	  FROM PER_ALL_ASSIGNMENTS_F ASS,
	       PER_PERIODS_OF_SERVICE B2
	  WHERE ASS.PRIMARY_FLAG = 'Y' AND ASS.ASSIGNMENT_TYPE = 'E' AND
	        B2.period_of_service_id = Ass.period_of_service_id AND
                B2.DATE_START <= TRUNC(SYSDATE) AND
	        greatest( NVL(B2.ACTUAL_TERMINATION_DATE, TRUNC(SYSDATE) ) ) between Ass.EFFECTIVE_START_DATE and Ass.EFFECTIVE_END_DATE
	        AND LEVEL <= ( p_level_id + 1 )
	  CONNECT BY
            PRIOR ass.PERSON_ID = SUPERVISOR_ID AND
            level <= (p_level_id + 1) and
            greatest( NVL(B2.ACTUAL_TERMINATION_DATE, TRUNC(SYSDATE) ) ) between Ass.EFFECTIVE_START_DATE and Ass.EFFECTIVE_END_DATE
      START WITH ass.pERSON_ID = p_supervisor_id
      ) H
	WHERE H.PERSON_ID = P.PERSON_ID AND
	      TRUNC(SYSDATE) BETWEEN P.EFFECTIVE_START_DATE AND P.EFFECTIVE_END_DATE AND
	      NOT Ap_Web_Db_Hr_Int_Pkg.ispersoncwk(P.PERSON_ID)='Y' AND
	      P.EMPLOYEE_NUMBER IS NOT NULL
	ORDER BY 2;


   ELSE

      OPEN p_employee_cursor FOR
	SELECT P.PERSON_ID, H.SUPERVISOR_ID, H.LVL
	FROM PER_PEOPLE_F P,
	( SELECT UNIQUE ass.PERSON_ID,ass.SUPERVISOR_ID, LEVEL -1 LVL
	  FROM PER_ALL_ASSIGNMENTS_F ASS,
	       PER_PERIODS_OF_SERVICE B2
	  WHERE ASS.PRIMARY_FLAG = 'Y' AND ASS.ASSIGNMENT_TYPE = 'E' AND
	        B2.period_of_service_id = Ass.period_of_service_id AND
                B2.DATE_START <= TRUNC(SYSDATE) AND
	        greatest( NVL(B2.ACTUAL_TERMINATION_DATE, TRUNC(SYSDATE) ) ) between Ass.EFFECTIVE_START_DATE and Ass.EFFECTIVE_END_DATE
	  CONNECT BY
            PRIOR ass.PERSON_ID = SUPERVISOR_ID AND
            level < 6 and
            greatest( NVL(B2.ACTUAL_TERMINATION_DATE, TRUNC(SYSDATE) ) ) between Ass.EFFECTIVE_START_DATE and Ass.EFFECTIVE_END_DATE
      START WITH ass.pERSON_ID = p_supervisor_id
      ) H
	WHERE H.PERSON_ID = P.PERSON_ID AND
	      TRUNC(SYSDATE) BETWEEN P.EFFECTIVE_START_DATE AND P.EFFECTIVE_END_DATE AND
	      NOT Ap_Web_Db_Hr_Int_Pkg.ispersoncwk(P.PERSON_ID)='Y' AND
	      P.EMPLOYEE_NUMBER IS NOT NULL
	ORDER BY 2;

   END IF;

  return TRUE;

EXCEPTION

  WHEN OTHERS THEN
    BEGIN
    	  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_CREDIT_CARD_WF', 'start GetHierarchialEmployeeCursor Exception p_supervisor_id='||to_char(p_supervisor_id));

          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'GetHierarchialEmployeeCursor');
          FND_MESSAGE.SET_TOKEN('PARAMETERS','');
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',' ');
          AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
    END;
END GetHierarchialEmployeeCursor;
-----------------------------------------------


/*Written By: Amulya Mishra
  Purpose :   Notification Escalation project.
              Gets the total outstanding amount of a bucket for employees
	      in a hierarchial manner.
              Sets the WF attribute MGR_NEXT_ESC_AMOUNT to be shown in notification
              Subject.
*/

------------------------------------------------
PROCEDURE GetHierTotalOutstandingAttr(
                 p_supervisor_id  IN NUMBER,
		 p_cardProgramId         IN  NUMBER,
                 p_min_bucket            IN  NUMBER,
                 p_max_bucket            IN  NUMBER,
                 p_grace_days            IN  NUMBER,
                 p_dunning_number        IN  NUMBER,
                 p_total_amount   OUT NOCOPY NUMBER) IS
-----------------------------------------------
l_supervisor_id         NUMBER;
l_employee_cursor       EmployeeCursor;
l_employee_name         per_employees_x.full_name%TYPE;
l_direct_manager_name   per_employees_x.full_name%TYPE; --Direct Report
l_total_amount          NUMBER := 0;
l_total_outstanding     NUMBER;
l_total_amt_outstanding NUMBER;
l_total_dispute         NUMBER;
l_total_amt_dispute     NUMBER;
l_employee_id           NUMBER;
l_level                 NUMBER := 0; --Bug 3337388

BEGIN

--  IF (NOT GetHierarchialEmployeeCursor(l_supervisor_id,l_employee_cursor)) THEN
--   5049215 -- Added the dunning number to the function level as only records of this dunning level are processed later.
  IF (NOT GetHierarchialEmployeeCursor(l_supervisor_id,l_employee_cursor, p_dunning_number)) THEN
    NULL;
  END IF;

  LOOP
      FETCH l_employee_cursor
      INTO  l_employee_id,l_supervisor_id,l_level; --Direct Manager --Bug 3337388

      EXIT WHEN l_employee_cursor%NOTFOUND;

      IF (NOT AP_WEB_DB_CCARD_PKG.GetTotalNumberOutstanding(p_cardProgramId,l_employee_id,
                       p_min_bucket, p_max_bucket , l_total_outstanding,
                       l_total_amt_outstanding)) THEN
        NULL;
      END IF;

      IF (AP_WEB_DB_CCARD_PKG.GetTotalNumberDispute(p_cardProgramId,l_employee_id,
                       p_min_bucket, p_max_bucket ,
                       p_grace_days,l_total_dispute,
                       l_total_amt_dispute)) THEN
        NULL;
      END IF;


   IF l_level = p_dunning_number THEN --Bug 3849357
      l_total_amount := l_total_amount + nvl(l_total_amt_outstanding,0) + nvl(l_total_amt_dispute , 0);
   END IF;

 END LOOP;


 close l_employee_cursor;
 p_total_amount := l_total_amount ;


EXCEPTION
  WHEN OTHERS THEN
	p_total_amount := 0;

END  GetHierTotalOutstandingAttr;
--------------------------------------------------



/*Written By: Amulya Mishra
  Purpose :   Notification Escalation project.
              Gets the value of WF attribute 'MGR_ALREADY_NOTIFIED'
              and sends notifications accordingly.
*/

----------------------------------------------------------------------
PROCEDURE IsNotificationRepeated(p_item_type      IN VARCHAR2,
                            p_item_key       IN VARCHAR2,
                            p_actid          IN NUMBER,
                            p_funmode        IN VARCHAR2,
                            p_result         OUT NOCOPY VARCHAR2) IS
----------------------------------------------------------------------

BEGIN
   AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_CREDIT_CARD_WF', 'start IsNotificationRepeated');
   p_result :=  WF_ENGINE.GetItemAttrText(p_item_type,
                                          p_item_key,
                                          'MGR_ALREADY_NOTIFIED');
   AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_CREDIT_CARD_WF', 'end IsNotificationRepeated');

END IsNotificationRepeated;

--------------------------------------------------------------------

/*Written By: Amulya Mishra
  Purpose :   Notification Escalation project.
              Gets the value of WF attribute 'SEND_NOTIFICATIONS_PARAM'
	      and sends notifications accordingly.
*/
----------------------------------------------------------------------
PROCEDURE SendNotifications(p_item_type      IN VARCHAR2,
                            p_item_key       IN VARCHAR2,
                            p_actid          IN NUMBER,
                            p_funmode        IN VARCHAR2,
                            p_result         OUT NOCOPY VARCHAR2) IS
----------------------------------------------------------------------

BEGIN
   AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_CREDIT_CARD_WF', 'start SendNotifications');
   p_result :=  WF_ENGINE.GetItemAttrText(p_item_type,
                                          p_item_key,
                                          'SEND_NOTIFICATIONS_PARAM');
   AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_CREDIT_CARD_WF', 'end SendNotifications');
END SendNotifications;

---------------------------------------------------------------------


/*Written By: Amulya Mishra
  Purpose :   Notification Escalation project.
              Gets the value of WF attribute 'FIRST_DUNNING'
              and sends notifications accordingly.
*/

----------------------------------------------------------------------
PROCEDURE IsFirstDunning(p_item_type      IN VARCHAR2,
                            p_item_key       IN VARCHAR2,
                            p_actid          IN NUMBER,
                            p_funmode        IN VARCHAR2,
                            p_result         OUT NOCOPY VARCHAR2) IS
----------------------------------------------------------------------

BEGIN
   AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_CREDIT_CARD_WF', 'start IsFirstDunning');
   p_result :=  WF_ENGINE.GetItemAttrText(p_item_type,
                                          p_item_key,
                                          'FIRST_DUNNING');
   AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_CREDIT_CARD_WF', 'end IsFirstDunning');

END IsFirstDunning;

--------------------------------------------------------------------

/*Written By: Amulya Mishra
  Purpose :   Notification Escalation project.
              Gets the value of WF attribute 'FIRST_DUNNING'
              and sends notifications accordingly.
*/

----------------------------------------------------------------------
FUNCTION GetDirectReport(
                p_employee_id         IN  NUMBER,
                p_final_manager_id    IN  NUMBER) RETURN VARCHAR2 IS

l_temp_manager_id  NUMBER;
l_employee_id      NUMBER := p_employee_id;
l_manager_name     wf_users.display_name%type;
l_direct_report_name     wf_users.display_name%type;

----------------------------------------------------------------------
BEGIN
  IF p_employee_id IS NULL OR p_final_manager_id IS NULL THEN
    RETURN null;
  END IF;

  WHILE TRUE LOOP

    AP_WEB_EXPENSE_WF.GetManager(l_employee_id, l_temp_manager_id );
    IF l_temp_manager_id = p_final_manager_id THEN
      EXIT;
    ELSE
      l_employee_id := l_temp_manager_id ;
    END IF;

  END LOOP;

  WF_DIRECTORY.GetUserName('PER', l_employee_id, l_manager_name, l_direct_report_name);
  return l_direct_report_name;

EXCEPTION
  WHEN OTHERS THEN
    return null;

END GetDirectReport;
--------------------------------------------------------------------

PROCEDURE GetWebNextEscManager(p_itemType 	IN VARCHAR2,
	       p_itemKey 	IN VARCHAR2) IS

  l_itemtype 			VARCHAR2(7);
  l_itemkey  			VARCHAR2(15);
  l_cardProgramId 		AP_WEB_DB_CCARD_PKG.ccTrxn_cardProgID;
  l_employeeId    		AP_WEB_DB_CCARD_PKG.cards_employeeID;
  l_dateFormat    		VARCHAR2(30);
  l_billed_currency_code	AP_WEB_DB_CCARD_PKG.ccTrxn_billedCurrCode;
  l_lineInfo			VARCHAR2(2000);
  l_debugInfo                  	VARCHAR2(1000);
  l_orgId    			NUMBER;
  l_min_bucket			NUMBER;
  l_max_bucket 			NUMBER;
  l_min_bucket1			VARCHAR2(30);
  l_max_bucket1			VARCHAR2(30);
  l_grace_days            	 NUMBER;

  l_employee_cursor              EmployeeCursor;
  l_supervisor_id                NUMBER;

  l_supervisor_name              PER_PEOPLE_F.FULL_NAME%TYPE;
  l_supervisor_display_name      PER_PEOPLE_F.FULL_NAME%TYPE;

  l_direct_manager_name          PER_PEOPLE_F.FULL_NAME%TYPE;  --Direct Report

  l_employee_name 		 PER_PEOPLE_F.FULL_NAME%TYPE;
  l_employee_display_name        PER_PEOPLE_F.FULL_NAME%TYPE;

  l_total_outstanding            NUMBER;
  l_total_amt_outstanding        NUMBER;
  l_total_dispute                NUMBER;
  l_total_amt_dispute            NUMBER;
  l_total_amount                 NUMBER;

  l_gross_outstanding            NUMBER := 0;
  l_gross_amount                 NUMBER := 0;


  l_final_manager_id             NUMBER;
  l_direct_report_name           PER_PEOPLE_F.FULL_NAME%TYPE;

  l_level                        NUMBER := 0;
  l_dunning_number               NUMBER;

  l_total_num_outstanding        NUMBER := 0;




BEGIN

  l_debugInfo := 'Decode document_id';

  l_itemType := p_itemType;
  l_itemKey :=  p_itemKey;

  l_debugInfo := 'Get org_id';
  l_orgId := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemKey, 'ORG_ID');

  l_supervisor_id := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemKey, 'AGING_MANAGER_ID');
  l_final_manager_id := l_supervisor_id;

  -- MOAC UPTAKE --
  -- Have new call back function defined for Item to set org context.
  --
  -- l_debugInfo := 'Set Org context';
  -- fnd_client_info.set_org_context(l_orgId);

  l_grace_days := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'AGING_GRACE_DAYS');

  l_billed_currency_code := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'CURRENCY');
  --------------------------------------------------------------
  l_debugInfo := 'Get WF BUCKET1..4 Item Attribute';
  --------------------------------------------------------------
  l_min_bucket1 := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'BUCKET1');
  l_max_bucket1 := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'BUCKET2');

  l_min_bucket := to_number(l_min_bucket1);
  if(l_max_bucket1 = '+' ) then
	l_max_bucket := 1000000;
  else
	l_max_bucket := to_number(substr(l_max_bucket1,3));
  end if;


  --------------------------------------------------------------
  l_debugInfo := 'Get WF CARD_PROG_ID Item Attribute';
  --------------------------------------------------------------
  l_cardProgramId := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'CARD_PROG_ID');
  --------------------------------------------------------------
  l_debugInfo := 'Get WF EMPLOYEE_ID Item Attribute';
  --------------------------------------------------------------
  l_employeeId := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'EMPLOYEE_ID');
  l_dateFormat := icx_sec.getID(icx_sec.PV_DATE_FORMAT);

  l_debugInfo := 'Loop over all the Dunning Charges ';

  l_dunning_number := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'DUNNING_NUMBER');

   DELETE FROM ap_ccard_esc_next_gt;

--  IF (NOT GetHierarchialEmployeeCursor(l_supervisor_id,l_employee_cursor)) THEN
--   5049215 -- Added the dunning number to the function level as only records of this dunning level are processed later.
  IF (NOT GetHierarchialEmployeeCursor(l_supervisor_id,l_employee_cursor, l_dunning_number)) THEN
    NULL;
  END IF;

  LOOP
      FETCH l_employee_cursor
      INTO  l_employeeId,l_supervisor_id,l_level;

      EXIT WHEN l_employee_cursor%NOTFOUND;


      IF (AP_WEB_DB_CCARD_PKG.GetTotalNumberOutstanding(l_cardProgramId,l_employeeId,
                       l_min_bucket, l_max_bucket , l_total_outstanding,
                       l_total_amt_outstanding)) THEN
        NULL;
      END IF;

      IF (AP_WEB_DB_CCARD_PKG.GetTotalNumberDispute(l_cardProgramId,l_employeeId,
                       l_min_bucket, l_max_bucket ,
                       l_grace_days,l_total_dispute,
                       l_total_amt_dispute)) THEN
        NULL;
      END IF;

      IF (NOT AP_WEB_DB_CCARD_PKG.GetTotalCreditCardAmount(l_cardProgramId,l_employeeId,
                                                 l_total_amount ) ) THEN
        NULL;
      END IF;



    IF ((nvl(l_total_outstanding,0) <> 0 OR nvl(l_total_dispute,0) <> 0)
                   AND l_level = l_dunning_number) THEN  --Direct Report

      l_total_amt_outstanding := nvl(l_total_amt_outstanding,0) + nvl(l_total_amt_dispute,0);

      l_total_num_outstanding := nvl(l_total_outstanding,0) + nvl(l_total_dispute,0);

      WF_DIRECTORY.GetUserName('PER', l_supervisor_id, l_supervisor_name, l_supervisor_display_name);
      WF_DIRECTORY.GetUserName('PER', l_employeeId, l_employee_name, l_employee_display_name);
      l_direct_report_name :=  GetDirectReport(l_employeeId , l_final_manager_id );



   IF l_level = l_dunning_number THEN
      l_gross_outstanding := l_gross_outstanding + nvl(l_total_amt_outstanding,0);
      l_gross_amount := l_gross_amount + nvl(l_total_amount,0);
   END IF;

   INSERT INTO ap_ccard_esc_next_gt
               (aging_manager_id,
                employee_display_name,
                supervisor_display_name,
                direct_report_name,
                total_num_outstanding,
                total_dispute,
                total_amt_outstanding,
                total_amount           )
   VALUES       (l_final_manager_id,
                 l_employee_display_name,
                 l_supervisor_display_name,
                 l_direct_report_name,
                 l_total_num_outstanding,
                 l_total_dispute,
                 l_total_amt_outstanding,
                 l_total_amount
                 );
   END IF;

  END LOOP;
  close l_employee_cursor;
 commit;
  --Set Outstanding total amount attribute.
  WF_ENGINE.SetItemAttrText(l_itemType, l_itemKey, 'MGR_ESC_AMOUNT', l_employee_name);

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_EXPENSE_WF', 'GetWebNextEscManager',
                    l_itemKey, l_debugInfo);
    raise;
END GetWebNextEscManager;


--------------------------------------------------------------------

PROCEDURE GetWebEscManager(p_itemType       IN VARCHAR2,
                           p_itemKey        IN VARCHAR2) IS

  l_colon                       NUMBER;
  l_itemtype                    VARCHAR2(7);
  l_itemkey                     VARCHAR2(15);
  l_cardProgramId               AP_WEB_DB_CCARD_PKG.ccTrxn_cardProgID;
  l_employeeId                  AP_WEB_DB_CCARD_PKG.cards_employeeID;
  l_dateFormat                  VARCHAR2(30);
  l_billed_currency_code        AP_WEB_DB_CCARD_PKG.ccTrxn_billedCurrCode;
  l_lineInfo                    VARCHAR2(2000);
  l_debugInfo                   VARCHAR2(1000);
  l_orgId                       NUMBER;
  l_min_bucket                  NUMBER;
  l_max_bucket                  NUMBER;
  l_min_bucket1                 VARCHAR2(30);
  l_max_bucket1                 VARCHAR2(30);
  l_prompts                     AP_WEB_UTILITIES_PKG.prompts_table;
  l_title                       AK_REGIONS_VL.name%TYPE;

  l_document                     long ;
  l_document_max                 NUMBER := 25000;

  l_detail_header_prompt         VARCHAR2(2000);
  l_grace_days                   NUMBER;

  l_employee_cursor   EmployeeCursor;
  l_supervisor_id     NUMBER;

  l_employee_name                PER_PEOPLE_F.FULL_NAME%TYPE;

  l_total_outstanding   NUMBER;
  l_total_amt_outstanding  NUMBER;
  l_total_dispute  NUMBER;
  l_total_amt_dispute  NUMBER;
  l_total_amount   NUMBER;

  l_total_num_outstanding        NUMBER := 0; --Bug 3310243

  l_gross_outstanding NUMBER := 0;
  l_gross_amount     NUMBER := 0;

  l_count     NUMBER := 0; --Direct Report

BEGIN



  l_itemType := p_itemType;
  l_itemKey :=  p_itemKey;

  l_debugInfo := 'Get org_id';
  l_orgId := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemKey, 'ORG_ID');

  -- MOAC UPTAKE --
  -- Have new call back function defined for Item to set org context.
  --
  -- l_debugInfo := 'Set Org context';
  -- fnd_client_info.set_org_context(l_orgId);

  l_grace_days := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'AGING_GRACE_DAYS');


  l_billed_currency_code := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'CURRENCY');
  --------------------------------------------------------------
  l_debugInfo := 'Get WF BUCKET1..4 Item Attribute';
  --------------------------------------------------------------
  l_min_bucket1 := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'BUCKET1');
  l_max_bucket1 := WF_ENGINE.GetItemAttrText(l_itemType, l_itemKey, 'BUCKET2');

  l_min_bucket := to_number(l_min_bucket1);
  if(l_max_bucket1 = '+' ) then
        l_max_bucket := 1000000;
  else
        l_max_bucket := to_number(substr(l_max_bucket1,3));
  end if;

  --------------------------------------------------------------
  l_debugInfo := 'Get WF CARD_PROG_ID Item Attribute';
  --------------------------------------------------------------
  l_cardProgramId := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'CARD_PROG_ID');

  --------------------------------------------------------------
  l_debugInfo := 'Get WF EMPLOYEE_ID Item Attribute';
  --------------------------------------------------------------
  l_employeeId := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'EMPLOYEE_ID');
  l_dateFormat := icx_sec.getID(icx_sec.PV_DATE_FORMAT);

  l_debugInfo := 'Loop over all the Dunning Charges ';

  AP_WEB_EXPENSE_WF.GetManager(l_employeeId, l_supervisor_id);

  DELETE FROM ap_ccard_esc_next_gt;

  IF (NOT GetEmployeeCursor(l_supervisor_id,l_employee_cursor)) THEN
    NULL;
  END IF;

  LOOP
      FETCH l_employee_cursor
      INTO  l_employeeId,l_employee_name;


      EXIT WHEN l_employee_cursor%NOTFOUND;

      IF (AP_WEB_DB_CCARD_PKG.GetTotalNumberOutstanding(l_cardProgramId,l_employeeId,
                       l_min_bucket, l_max_bucket , l_total_outstanding,
                       l_total_amt_outstanding)) THEN
        NULL;
      END IF;



      IF (AP_WEB_DB_CCARD_PKG.GetTotalNumberDispute(l_cardProgramId,l_employeeId,
                       l_min_bucket, l_max_bucket ,
                       l_grace_days,l_total_dispute,
                       l_total_amt_dispute)) THEN
        NULL;
      END IF;



      IF (NOT AP_WEB_DB_CCARD_PKG.GetTotalCreditCardAmount(l_cardProgramId,l_employeeId,
                                                 l_total_amount ) ) THEN
        NULL;
      END IF;


      IF ((nvl(l_total_outstanding,0) <> 0 OR nvl(l_total_dispute,0) <> 0) ) THEN  --Direct Report

        l_total_amt_outstanding := nvl(l_total_amt_outstanding,0) +  nvl(l_total_amt_dispute,0);

        l_total_num_outstanding := nvl(l_total_outstanding,0) + nvl(l_total_dispute,0);

        INSERT INTO ap_ccard_esc_next_gt
                (
                  aging_manager_id,
                  employee_display_name,
                  total_num_outstanding,
                  total_dispute,
                  total_amt_outstanding,
                  total_amount
                )
       VALUES       (
                 l_supervisor_id,
                 l_employee_name,
                 l_total_num_outstanding,
                 l_total_dispute,
                 l_total_amt_outstanding,
                 l_total_amount
                 );

     END IF;

  END LOOP;
  close l_employee_cursor;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_EXPENSE_WF', 'GetWebEscManager',
                    null, l_debugInfo);
    raise;
END GetWebEscManager;

---------------------------------------------------------------
PROCEDURE SendDeactivatedNotif(p_employeeId     IN NUMBER,
                               p_cardProgramId  IN NUMBER,
                               p_endDate        IN VARCHAR2)
IS
  l_itemType		VARCHAR2(100)	:= 'APCCARD';
  l_itemKey		VARCHAR2(100);
  l_employeeName        wf_users.name%type;
  l_employeeID		NUMBER;
  l_employeeDisplayName	wf_users.display_name%type;
  l_debugInfo		VARCHAR2(200);
  l_cardProgramName     AP_WEB_DB_CCARD_PKG.cardProgs_cardProgName;
  l_orgId       	number;
BEGIN

  WF_DIRECTORY.GetUserName('PER',
                           p_employeeId,
                           l_employeeName,
                           l_employeeDisplayName);

  IF l_employeeName IS NULL THEN
     RETURN;
  END IF;

  ---------------------------------------------------------
  l_debugInfo := ' Generate new key';
  ---------------------------------------------------------
  l_itemKey := GetNextCardNotificationID;

  --------------------------------------------------
  l_debugInfo := 'Calling WorkFlow Create Process';
  --------------------------------------------------
  WF_ENGINE.CreateProcess(l_itemType,  l_itemKey, 'DEACTIVATED_TRXNS');

  ----------------------------------------------------------
  l_debugInfo := 'Set DATE2 Item Attribute';
  ----------------------------------------------------------
  --
  -- Set the date in canonical format so that the web pages
  -- can convert this into appropriate user preference format.
  --
  WF_ENGINE.SetItemAttrText(  l_itemType,
                              l_itemKey,
                              'DATE2',
                              FND_DATE.date_to_canonical(to_date(p_endDate,
                                                                 nvl(icx_sec.g_date_format,
                                                                     icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT')
                                                                    )
                                                                )
                                                        )
                            );

  ----------------------------------------------------------
  l_debugInfo := 'Set EMPLOYEE_NAME Item Attribute';
  ----------------------------------------------------------
  WF_ENGINE.SetItemAttrText(  l_itemType,
			      l_itemKey,
			      'EMPLOYEE_NAME',
			      l_employeeName);

  ----------------------------------------------------------
  l_debugInfo := 'Set EMPLOYEE_NAME Item Attribute';
  ----------------------------------------------------------
  WF_ENGINE.SetItemAttrText(  l_itemType,
			      l_itemKey,
			      'EMP_DISPLAY_NAME',
			      l_employeeDisplayName);

  ------------------------------------------------------
  l_debugInfo := 'Set WF CREDIT_CARD_COMPANY Item Attribute';
  ------------------------------------------------------
  IF (NOT AP_WEB_DB_CCARD_PKG.GetCardProgramName(p_cardProgramID,
						 l_cardProgramName ) ) THEN
	NULL;
  END IF;

  WF_ENGINE.SetItemAttrText(  l_itemType,
			      l_itemKey,
			      'CREDIT_CARD_COMPANY',
			      l_cardProgramName);

  WF_ENGINE.StartProcess(l_itemType, l_itemKey);

END SendDeactivatedNotif;
---------------------------------------------------------------



----------------------------------------------------------------------
PROCEDURE CallbackFunction(     p_item_type      IN VARCHAR2,
                                p_item_key       IN VARCHAR2,
                                p_actid          IN NUMBER,
                                p_funmode        IN VARCHAR2,
                                p_result         OUT NOCOPY VARCHAR2) IS
----------------------------------------------------------------------
  l_debug_info                  VARCHAR2(200);

  l_org_id              number;
  l_expense_report_id   number;
  l_card_prog_id        Number;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_CREDIT_CARD_WF', 'start CallbackFunction');

  begin
    l_org_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                            p_item_key,
                                            'ORG_ID');
  exception
  	when others then
          -- This wf is called by multiple conc programs and some set
          -- CARD_PROG_ID and others set CARD_PROGRAM_ID
          -- p_s_item_key is a sequence value and not report_header_id
          -- hence remove the call GetOrgIdByReportHeaderId and instead
          -- get the org_id from card program(ap_card_programs).
  	  if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
            begin
              l_card_prog_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
  					        p_item_key,
  					        'CARD_PROG_ID');

            exception
              when others then
                null;
            end;
            if l_card_prog_id is null then
              begin
              l_card_prog_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
  					        p_item_key,
  					        'CARD_PROGRAM_ID');
              exception
                when others then
                   null;
              end;
            end if;

            if l_card_prog_id is not null then
               begin
                 select org_id into l_org_id
                 from ap_card_programs_all
                 where card_program_id = l_card_prog_id;
               exception
                 when others then
  	           l_org_id := NULL;
               end;
            else
  	       l_org_id := NULL;
            end if;

  	    -- ORG_ID item attribute doesn't exist, need to add it
  	    wf_engine.AddItemAttr(p_item_type, p_item_key, 'ORG_ID');
	    WF_ENGINE.SetItemAttrNumber(p_item_type,
  					p_item_key,
  					'ORG_ID',
					l_org_id);
  	  else
  	    raise;
  	  end if;

  end;

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

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_CREDIT_CARD_WF', 'end CallbackFunction');

  EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_CREDIT_CARD_WF', 'CallbackFunction',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END CallbackFunction;


END AP_WEB_CREDIT_CARD_WF;

/
