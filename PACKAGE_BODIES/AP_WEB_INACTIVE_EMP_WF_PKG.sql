--------------------------------------------------------
--  DDL for Package Body AP_WEB_INACTIVE_EMP_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_INACTIVE_EMP_WF_PKG" AS
/* $Header: apwinacb.pls 120.23.12000000.3 2007/04/24 20:51:57 skoukunt ship $ */
--
-- Private Variables
--
-- copied from WF_NOTIFICATION package
-- /fnddev/fnd/11.5/patch/115/sql/wfntfb.pls
--
table_width  varchar2(6) := '"100%"';
table_border varchar2(3) := '"0"';
table_cellpadding varchar2(3) := '"3"';
table_cellspacing varchar2(3) := '"1"';
table_bgcolor varchar2(7) := '"white"';
th_bgcolor varchar2(9) := '"#cccc99"';
th_fontcolor varchar2(9) := '"#336699"';
th_fontface varchar2(80) := '"Arial, Helvetica, Geneva, sans-serif"';
td_bgcolor varchar2(9) := '"#f7f7e7"';
td_fontcolor varchar2(7) := '"black"';
td_fontface varchar2(80) := '"Arial, Helvetica, Geneva, sans-serif"';

PROCEDURE Start_inactive_emp_process(p_card_program_id       IN NUMBER,
                                     p_inact_employee_id     IN NUMBER,
                                     p_billed_currency_code  IN VARCHAR2,
                                     p_total_amt_posted      IN NUMBER,
                                     p_cc_billed_start_date  IN ccTrxn_billedDate,
                                     p_cc_billed_end_date    IN ccTrxn_billedDate,
                                     p_wf_item_type          IN wfItems_item_type,
                                     p_wf_item_key           IN wfItems_item_key)


-- Function Name: Start_inactive_emp_proces
-- Author:        Geetha Gurram
-- Purpose:       Assign all the attribute values for the WF Item type APCCARD and process
--                inform Inactive Employee Manager and initiates the Inactive Employee Workflow Process
-- Input:         p_card_program_id
--                p_inact_employee_id
--                p_billed_currency_code
--                p_total_amt_posted
--                p_cc_billed_start_date
--                p_cc_billed_end_date
--                p_wf_item_type
--                p_wf_item_key -> sequence ap_ccard_notification_id_s.nextval
--
-- Output:
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs
--

 IS
  l_process                 VARCHAR2(50)      :=  'INFORM_INACT_EMP_MANAGER';
  l_item_type               VARCHAR2(100)     :=  p_wf_item_type;
  l_Item_Key                VARCHAR2(50)      :=  p_wf_item_key;
  l_inact_employee_name	    VARCHAR2(30);
  l_inact_emp_display_name   Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_temp_inact_emp_disp_name Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_inact_emp_org_id        NUMBER;
  l_inact_emp_org_name      VARCHAR2(200);
  l_total_dsp			    VARCHAR2(50);
  l_special_instructions    Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_instructions            Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_note                    Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_resp_notes              Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_resp_instructions       Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
  l_orgId                   NUMBER;
  l_n_org_id                NUMBER;
  l_debug_info              VARCHAR2(200);
  l_err_name                VARCHAR2(200);

  l_textNameArr             Wf_Engine.NameTabTyp;
  l_textValArr              Wf_Engine.TextTabTyp;
  l_numNameArr              Wf_Engine.NameTabTyp;
  l_numValArr               Wf_Engine.NumTabTyp;
  l_dateNameArr             Wf_Engine.NameTabTyp;
  l_dateValArr              Wf_Engine.DateTabTyp;

  iNum  NUMBER :=0;
  iText NUMBER :=0;
  iDate NUMBER :=0;


BEGIN

 Begin

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG',  'start Start_inactive_emp_process');

  wf_engine.CreateProcess(ItemType => l_Item_Type,
                          ItemKey  => l_Item_Key,
                          process  => l_process);

 exception
    when others then
         l_err_name := wf_core.error_name;
          if (l_err_name = 'WFENG_ITEM_UNIQUE') then
           wf_core.clear;
          else
            raise;
          end if;
 end;

  --------------------------------------------------------------
  l_debug_info := 'Get Org_ID value ';
  --------------------------------------------------------------

  FND_PROFILE.GET('ORG_ID' , l_n_org_id );

  -- ORG_ID was added later; therefore, it needs to be tested for upgrade purpose, and
  -- is not included in the bulk update.
  begin

    WF_ENGINE.SetItemAttrNumber(l_item_type,
                              	l_item_key,
                              	'ORG_ID',
                              	l_n_Org_ID);
    exception
	when others then
	  if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
	    -- ORG_ID item attribute doesn't exist, need to add it
	    WF_ENGINE.AddItemAttr(l_item_type, l_item_key, 'ORG_ID');
    	    WF_ENGINE.SetItemAttrNumber(l_item_type,
                              	l_item_key,
                              	'ORG_ID',
                              	l_n_Org_ID);
	  else
	    raise;
	  end if;

  end;


  begin

    --------------------------------------------------------------
    l_debug_info := 'Set User_ID value ';
    --------------------------------------------------------------
    WF_ENGINE.SetItemAttrNumber(l_item_type,
                              	l_item_key,
                              	'USER_ID',
                              	FND_PROFILE.VALUE('USER_ID'));

    --------------------------------------------------------------
    l_debug_info := 'Set Resp_ID value ';
    --------------------------------------------------------------
    WF_ENGINE.SetItemAttrNumber(l_item_type,
                              	l_item_key,
                              	'RESPONSIBILITY_ID',
                              	FND_PROFILE.VALUE('RESP_ID'));

    --------------------------------------------------------------
    l_debug_info := 'Set Resp_Appl_ID value ';
    --------------------------------------------------------------
    WF_ENGINE.SetItemAttrNumber(l_item_type,
                              	l_item_key,
                              	'APPLICATION_ID',
                              	FND_PROFILE.VALUE('RESP_APPL_ID'));

  exception
	when others then
	  if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
	    null;
	  else
	    raise;
	  end if;
  end;

  Begin
  ------------------------------------------------------
  l_debug_info := 'Retrieve The Inactive Employee Info';
  ------------------------------------------------------

  select p.full_name, o.organization_id, o.name
  into l_inact_emp_display_name, l_inact_emp_org_id, l_inact_emp_org_name
  from per_people_f p,
       per_assignments_f a,
       per_assignment_status_types s,
       per_organization_units o
  where p.person_id = p_inact_employee_id
  and  p.person_id = a.person_id
  and  a.primary_flag = 'Y'
  and  a.assignment_status_type_id = s.assignment_status_type_id
  and  o.organization_id = a.organization_id
  and  o.business_group_id = a.business_group_id
  and  per_system_status in ('TERM_ASSIGN', 'SUSP_ASSIGN')
  and  a.assignment_type in ('E', 'C')
  and  trunc(sysdate) between p.effective_start_date and p.effective_end_date
  and  trunc(sysdate) between a.effective_start_date and a.effective_end_date;

 exception
  when others then
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'Start_Inactive_Emp_Process',
                     l_item_type, l_item_key, to_char(0), l_debug_info);
  raise;
  end;


Begin

 l_total_dsp := to_char(p_total_amt_posted,
			 FND_CURRENCY.Get_Format_Mask(p_billed_currency_code,22));

 l_total_dsp := l_total_dsp || ' ' || p_billed_currency_code;


  -------------------------------------------------------------
  l_debug_info := 'Set WF Inactive Employee_ID Item Attribute';
  -------------------------------------------------------------
    iNum := iNum + 1;
    l_numNameArr(iNum) := 'INACT_EMPLOYEE_ID';
    l_numValArr(iNum) :=  p_inact_employee_id;

  -------------------------------------------------------------
  l_debug_info := 'Set WF Inactive Employee_Org Item Attribute';
  -------------------------------------------------------------
    iNum := iNum + 1;
    l_numNameArr(iNum) := 'INACT_EMPLOYEE_ORG_ID';
    l_numValArr(iNum)  := l_inact_emp_org_id;

  --------------------------------------------------------------
  l_debug_info := 'Set WF Inactive Org Name Item Attribute';
  --------------------------------------------------------------
    iText := iText + 1;
    l_textNameArr(iText) := 'INACT_EMPLOYEE_ORG_NAME';
    l_textValArr(iText)  := l_inact_emp_org_name;

  -- 5921835: for inactive employee WF_DIRECTORY.GetUserName would
  -- return null as the entry in wf_users would be end dated
  --------------------------------------------------------------
  l_debug_info := 'Get Preparer Name Info For Inactive Employee';
   --------------------------------------------------------------
  WF_DIRECTORY.GetUserName('PER',
			                p_inact_employee_id,
			                l_inact_employee_name,
			                l_temp_inact_emp_disp_name);

  if l_temp_inact_emp_disp_name is not null then
     l_inact_emp_display_name := l_temp_inact_emp_disp_name;
  end if;

  --------------------------------------------------------------
  l_debug_info := 'Set WF Inactive Employee Name Item Attribute';
  --------------------------------------------------------------
    iText := iText + 1;
    l_textNameArr(iText) := 'INACT_EMP_NAME';
    l_textValArr(iText)  := l_inact_employee_name;

  ----------------------------------------------------------------------
  l_debug_info := 'Set WF Inactive Employee Display Name Item Attribute';
  ----------------------------------------------------------------------
    iText := iText + 1;
    l_textNameArr(iText) := 'INACT_EMPLOYEE_DISPLAY_NAME';
    l_textValArr(iText)  := l_inact_emp_display_name;

  ------------------------------------------------------
  l_debug_info := 'Set WF Credit_Card_ID Item Attribute';
  ------------------------------------------------------
    iNum := iNum + 1;
    l_numNameArr(iNum) := 'CARD_PROG_ID';
    l_numValArr(iNum) := p_card_program_id;


  -----------------------------------------------------------
  l_debug_info := 'Set WF CC Trx Begin Date Item Attribute';
  -----------------------------------------------------------
    iDate := iDate + 1;
    l_dateNameArr(iDate) := 'CC_TRX_BEGIN_DATE';
    l_dateValArr(iDate) := p_cc_billed_start_date;

  ------------------------------------------------------
  l_debug_info := 'Set WF CC Trx End Date Item Attribute';
  ------------------------------------------------------
    iDate := iDate + 1;
    l_dateNameArr(iDate) := 'CC_TRX_END_DATE';
    l_dateValArr(iDate) := p_cc_billed_end_date ;


 -------------------------------------------------------------
  l_debug_info := 'Set WF Total Amt Posted Item Attribute';
  -------------------------------------------------------------
    iNum := iNum + 1;
    l_numNameArr(iNum) := 'TOTAL_AMT_POSTED';
    l_numValArr(iNum)  := p_total_amt_posted;

  ------------------------------------------------------
  l_debug_info := 'Set WF Display Total Item Attribute';
  -------------------------------------------------------
    iText := iText + 1;
    l_textNameArr(iText) := 'DISPLAY_TOTAL';
    l_textValArr(iText)  := l_total_dsp;

  ---------------------------------------------------------------
  l_debug_info := 'Set WF Currency Item Attribute';
  ---------------------------------------------------------------
    iText := iText + 1;
    l_textNameArr(iText) := 'CURRENCY';
    l_textValArr(iText) := p_billed_currency_code;

  ------------------------------------------------------------
  l_debug_info := 'Get Special Instructions from FND_MESSAGE';
  ------------------------------------------------------------

   fnd_message.set_name('SQLAP','OIE_INACT_SPEC_INSTRUCTIONS');
   fnd_message.set_token('INACT_EMP_NAME', l_inact_emp_display_name);
   fnd_message.set_token('INACT_EMP_ORG_NAME', l_inact_emp_org_name);
   l_special_instructions := fnd_message.get;

 -------------------------------------------------------------
  l_debug_info := 'Set WF Special Instructions Item Attribute';
  -------------------------------------------------------------
    iText := iText + 1;
    l_textNameArr(iText) := 'SPECIAL_INSTRUCTIONS';
    l_textValArr(iText) := l_special_instructions;

  ------------------------------------------------------------
  l_debug_info := 'Get Instructions from FND_MESSAGE';
  ------------------------------------------------------------

   fnd_message.set_name('SQLAP','OIE_INACT_INSTRUCTIONS');
   l_instructions := fnd_message.get;


  -------------------------------------------------------------
  l_debug_info := 'Set WF Instructions Item Attribute';
  -------------------------------------------------------------
    iText := iText + 1;
    l_textNameArr(iText) := 'INSTRUCTIONS';
    l_textValArr(iText) := l_instructions;

 ------------------------------------------------------------
  l_debug_info := 'Get Note from FND_MESSAGE';
  ------------------------------------------------------------

   fnd_message.set_name('SQLAP','OIE_INACT_NOTE');
   l_note := fnd_message.get;

  -------------------------------------------------------------
  l_debug_info := 'Set WF Instructions Note Item Attribute';
  -------------------------------------------------------------
    iText := iText + 1;
    l_textNameArr(iText) := 'INSTRUCTION_NOTE';
    l_textValArr(iText) := l_note;

  -------------------------------------------------------------------
  l_debug_info := 'Get Responsibility Instructions from FND_MESSAGE';
  -------------------------------------------------------------------

   fnd_message.set_name('SQLAP','OIE_INACT_RESP_INSTRUCTIONS');
   l_resp_instructions := fnd_message.get;

  ---------------------------------------------------------------------
  l_debug_info := 'Set Responsibility Instructions Note Item Attribute';
  ---------------------------------------------------------------------
    iText := iText + 1;
    l_textNameArr(iText) := 'RESP_INSTRUCTIONS';
    l_textValArr(iText) := l_resp_instructions;

  -------------------------------------------------------------------
  l_debug_info := 'Get Responsibility Note from FND_MESSAGE';
  -------------------------------------------------------------------

   fnd_message.set_name('SQLAP','OIE_INACT_RESP_NOT_REASON');
   fnd_message.set_token('INACT_EMP_NAME', l_inact_emp_display_name);
   l_resp_notes := fnd_message.get;

  ---------------------------------------------------------------------
  l_debug_info := 'Set Responsibility Instructions Note Item Attribute';
  ---------------------------------------------------------------------
    iText := iText + 1;
    l_textNameArr(iText) := 'RESP_NOTES';
    l_textValArr(iText) := l_resp_notes;

 --------------------------------------------------------------
  l_debug_Info := 'Get ORG_ID from FND_PROFILE';
  --------------------------------------------------------------
  FND_PROFILE.GET('ORG_ID' , l_orgId);

  -------------------------------------------------------------
  l_debug_info := 'Set WF ORG_ID Item Attribute';
  -------------------------------------------------------------
    iNum := iNum + 1;
    l_numNameArr(iNum) := 'ORG_ID';
    l_numValArr(iNum)  := l_orgid;

 ------------------------------------------------------
  l_debug_info := 'Set CC_TRX_DETAILS_TABLE Item Attribute';
  ------------------------------------------------------
    iText := iText + 1;
    l_textNameArr(iText) := 'CC_TRX_DETAILS_TABLE';
    l_textValArr(iText) := 'plsql:AP_WEB_INACTIVE_EMP_WF_PKG.GenerateCCTrxList/'||l_item_type||':'||l_item_key;

 ------------------------------------------------------
  l_debug_info := 'Set OIE_CC_TRX_DETAILS_TABLE Item Attribute';
  ------------------------------------------------------
    iText := iText + 1;
    l_textNameArr(iText) := 'OIE_CC_TRX_DETAILS_TABLE';
    l_textValArr(iText) := 'JSP:/OA_HTML/OA.jsp?akRegionCode=InactiveEmpRN&akRegionApplicationId=200&itemKey='||l_item_key||'&orgId='||l_orgid;

  -----------------------------------------------------
  -----------------------------------------------------
  l_debug_info := 'Set all number Attributes';
  -----------------------------------------------------
  WF_ENGINE.SetItemAttrNumberArray(l_item_type, l_item_key, l_numNameArr, l_numValArr);

  -----------------------------------------------------
  l_debug_info := 'Set all text Attributes';
  -----------------------------------------------------
  WF_ENGINE.SetItemAttrTextArray(l_item_type, l_item_key, l_textNameArr, l_textValArr);

  -----------------------------------------------------
  l_debug_info := 'Set all Date Attributes';
  -----------------------------------------------------
 WF_ENGINE.SetItemAttrDateArray(l_item_type, l_item_key, l_dateNameArr, l_dateValArr);


exception
	when others then
	  if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
	    null;
	  else
	    raise;
	  end if;
end;

Begin
  wf_engine.StartProcess(ItemType => l_Item_Type,
                           ItemKey  => l_Item_Key);
exception
    when others then
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', ' Start_inactive_emp_process ',
                     l_item_type, l_item_key, to_char(0), l_debug_info);
    raise;
 end;

 AP_WEB_UTILITIES_PKG.logProcedure('AP_INACTIVE_EMP_WF_PKG',  'end Start_inactive_emp_process');

COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
     APP_EXCEPTION.RAISE_EXCEPTION;

END Start_inactive_emp_process;

FUNCTION GetInactEmpCcardTrxnCursor(
	 	p_cardProgramId		IN  	   ccTrxn_cardProgID,
		p_employeeId		IN  	   perEmp_employeeID,
		p_billedStartDate	IN  	   ccTrxn_billedDate,
		p_billedEndDate		IN  	   ccTrxn_billedDate,
       		p_itemkey           	IN  	   wfItems_item_key,
		p_Inact_Emp_trx_cursor	OUT NOCOPY InactEmpCCTrxnCursor
) RETURN BOOLEAN IS

-- Function Name: GetInactEmpCcardTrxnCursor
-- Author:        Geetha Gurram
-- Purpose:       Retrieves all the CC trx of the inactive employee which fall in the range
--                of billed start and end date
--
-- Input:         p_cardProgramId
--                p_employeeId
--                p_billedStartDate
--                p_billedEndDate
--
-- Output:        p_Inact_Emp_trx_cursor
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs
--
 l_debug_info              VARCHAR2(200);
BEGIN

OPEN p_Inact_Emp_trx_cursor FOR

     SELECT transaction_date,
		 merchant_name1,
         merchant_city,
		 billed_amount,
		 billed_currency_code,
		 null invoice_num
     FROM
       ap_credit_card_trxns 		cct,
       ap_cards 			        ac
     WHERE cct.card_program_id = p_cardProgramId
       and cct.validate_code = 'Y'
       and cct.payment_flag <> 'Y'
       and nvl(cct.expensed_amount,0) = 0
       and nvl(cct.category, 'BUSINESS') not in ( 'DISPUTED', 'DEACTIVATED')
       and ac.card_program_id = cct.card_program_id
       and ac.card_id = cct.card_id
       and nvl(cct.billed_date, cct.posted_date) between
           nvl(p_billedStartDate, nvl(cct.billed_date, cct.posted_date)-1) and
           nvl(p_billedEndDate, nvl(cct.billed_date, cct.posted_date)+1)
       and ac.employee_id = p_employeeId
       and cct.inactive_emp_wf_item_key  = p_itemkey
       and cct.report_header_id is NULL
    union all
    SELECT transaction_date,
		 merchant_name1,
         merchant_city,
		 billed_amount,
		 billed_currency_code,
		 erh.invoice_num
       FROM
       ap_credit_card_trxns 		cct,
       ap_cards 			        ac,
       ap_expense_report_headers 	erh
       WHERE
       cct.card_program_id = p_cardProgramId
       and cct.validate_code = 'Y'
       and cct.payment_flag <> 'Y'
       and cct.expensed_amount <> 0
       and nvl(cct.category, 'BUSINESS') not in ( 'DISPUTED','DEACTIVATED')
       and ac.card_program_id = cct.card_program_id
       and ac.card_id = cct.card_id
       and nvl(cct.billed_date, cct.posted_date) between
           nvl(p_billedStartDate, nvl(cct.billed_date, cct.posted_date)-1) and
           nvl(p_billedEndDate, nvl(cct.billed_date, cct.posted_date)+1)
       and erh.report_header_id  = cct.report_header_id
       and AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(erh.source,erh.workflow_approved_flag,erh.report_header_id) in ('EMPAPPR','RESOLUTN','RETURNED','REJECTED','WITHDRAWN', 'SAVED')
       and ac.employee_id = p_employeeId
       and cct.inactive_emp_wf_item_key  = p_itemkey
       and rownum < 41
       order by transaction_date;

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
         Wf_Core.Context('AP_WEB_EXPENSE_WF', 'GetInactEmpCcardTrxnCursor',
                      to_char(0), to_char(0), to_char(0), l_debug_info || FND_MESSAGE.GET);
		RETURN FALSE;

	WHEN OTHERS THEN

        Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'GetInactEmpCcardTrxnCursor',
                    to_char(0), to_char(0), to_char(0), l_debug_info || FND_MESSAGE.GET);
    	APP_EXCEPTION.RAISE_EXCEPTION;
    	RETURN FALSE;

END GetInactEmpCcardTrxnCursor;

PROCEDURE GenerateCCTrxList(document_id		IN VARCHAR2,
				            display_type	IN VARCHAR2,
				            document	    IN OUT NOCOPY VARCHAR2,
				            document_type	IN OUT NOCOPY VARCHAR2)IS

-- Function Name: GenerateCCTrxList
-- Author:        Geetha Gurram
-- Purpose:       Generates a CC trx list of text/HTML document type
--
-- Input:         document_id
--                display_type
--                document
--                document_type
--
-- Output:        document
--                document_type
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs
--

  l_colon                   NUMBER;
  l_itemtype                VARCHAR2(7);
  l_itemkey                 VARCHAR2(15);
  l_cardProgramId 		    AP_WEB_DB_CCARD_PKG.ccTrxn_cardProgID;
  l_billedStartDate 	    AP_WEB_DB_CCARD_PKG.ccTrxn_billedDate;
  l_billedEndDate 		    AP_WEB_DB_CCARD_PKG.ccTrxn_billedDate;
  l_minimumAmount 		    AP_WEB_DB_CCARD_PKG.ccTrxn_billedAmount;
  l_employeeId    		    AP_WEB_DB_CCARD_PKG.cards_employeeID;
  l_dateFormat              VARCHAR2(30);
  l_transaction_date	    AP_WEB_DB_CCARD_PKG.ccTrxn_transDate;
  l_merchant_name1		    AP_WEB_DB_CCARD_PKG.ccTrxn_merchantName1;
  l_merchant_City		    AP_WEB_DB_CCARD_PKG.ccTrxn_merchantCity;
  l_billed_amount           AP_WEB_DB_CCARD_PKG.ccTrxn_billedAmount;
  l_total_billed_amt        NUMBER := 0;
  l_billed_currency_code	AP_WEB_DB_CCARD_PKG.ccTrxn_billedCurrCode;
  l_lineInfo			    VARCHAR2(2000);
  l_debugInfo               VARCHAR2(1000);
  l_orgId                   NUMBER;
  l_InactEmpCCTrxn_cursor   InactEmpCCTrxnCursor;
  l_debug_info              VARCHAR2(1000);
  l_expense_report_number	VARCHAR2(60);
  l_prompts			        AP_WEB_UTILITIES_PKG.prompts_table;
  l_title			        AK_REGIONS_VL.name%TYPE;
  l_expense_report_status	VARCHAR2(30);
  l_displayed_status	 	VARCHAR2(60);
  l_total_dsp               VARCHAR2(50);


BEGIN

  l_debugInfo := 'Decode document_id';
  l_colon    := instrb(document_id, ':');
  l_debugInfo := l_debugInfo || ' First index: ' || to_char(l_colon);
  l_itemtype := substrb(document_id, 1, l_colon - 1);
  l_itemkey  := substrb(document_id, l_colon  + 1);

  l_debugInfo := 'Get org_id';
  l_orgId := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemKey, 'ORG_ID');

  -- MOAC UPTAKE --
  -- Should not have to initialize the org context
  -- This is done via callbackfunction()
  -- l_debugInfo := 'Set Org context';
  -- fnd_client_info.set_org_context(l_orgId);

  ------------------------------------------------------------
  l_debugInfo := 'Get prompts';
  ------------------------------------------------------------
  AP_WEB_DISC_PKG.getPrompts(200,'AP_WEB_WF_INAC_CC_LINETABLE',l_title,l_prompts);

  l_debugInfo := 'Generate header';
  if (display_type = 'text/plain') then
      document := '';
  else  -- html
        document := '<table border=0 cellpadding=2>';
        document := document || '<tr bgcolor='||th_bgcolor||'>';
        document := document || '<th><font color='||th_fontcolor||' face='||th_fontface||'><b>' || l_prompts(1) || '</b></th>';
        document := document || '<th><font color='||th_fontcolor||' face='||th_fontface||'><b>' || l_prompts(2) || '</b></th>';
        document := document || '<th><font color='||th_fontcolor||' face='||th_fontface||'><b>' || l_prompts(3) || '</b></th>';
        document := document || '<th><font color='||th_fontcolor||' face='||th_fontface||'><b>' || l_prompts(4) || '</b></th>';
        document := document || '<th><font color='||th_fontcolor||' face='||th_fontface||'><b>' || l_prompts(5) || '</b></th></tr>';
  end if;


  ------------------------------------------------------
  l_debugInfo := 'Get WF CC_TRX_BEGIN_DATE Item Attribute';
  ------------------------------------------------------
  l_billedStartDate := WF_ENGINE.GetItemAttrDate(l_itemType, l_itemKey, 'CC_TRX_BEGIN_DATE');

  ------------------------------------------------------
  l_debugInfo := 'Get WF CC_TRX_END_DATE Item Attribute';
  ------------------------------------------------------
  l_billedEndDate := WF_ENGINE.GetItemAttrDate(l_itemType, l_itemKey, 'CC_TRX_END_DATE');

  --------------------------------------------------------------
  l_debugInfo := 'Get WF CARD_PROG_ID Item Attribute';
  --------------------------------------------------------------
  l_cardProgramID := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'CARD_PROG_ID');

  --------------------------------------------------------------
  l_debugInfo := 'Get WF INACT_EMPLOYEE_ID Item Attribute';
  --------------------------------------------------------------
  l_employeeID := WF_ENGINE.GetItemAttrNumber(l_itemType, l_itemKey, 'INACT_EMPLOYEE_ID');

  l_dateFormat := icx_sec.getID(icx_sec.PV_DATE_FORMAT);

  l_debugInfo := 'Loop over all the disputed charges';

  --------------------------------------------
    l_debug_info := 'Open Expense Lines Cursor';
    --------------------------------------------
    IF (GetInactEmpCcardTrxnCursor(l_cardProgramId,
			l_employeeId, l_billedStartDate,
			l_billedEndDate, l_itemKey , l_InactEmpCCTrxn_cursor)) THEN

    LOOP
      FETCH l_InactEmpCCTrxn_cursor
      INTO  l_transaction_date,
	    l_merchant_name1,
        l_merchant_city,
	    l_billed_amount,
	    l_billed_currency_code,
        l_expense_report_number;
      EXIT WHEN l_InactEmpCCTrxn_cursor%NOTFOUND;


      l_total_billed_amt := l_total_billed_amt + l_billed_amount;
      l_total_dsp := to_char(l_total_billed_amt, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22));
      l_total_dsp := l_total_dsp || ' ' || l_billed_currency_code;

      WF_ENGINE.SetItemAttrText(l_itemtype,
                              	l_itemkey,
                                'DISPLAY_TOTAL',
                                l_total_dsp);


      IF (display_type = 'text/plain') THEN
      	--------------------------------------------
      	l_debugInfo := 'Format Line Info';
      	--------------------------------------------
      	l_lineInfo := to_char(l_transaction_date,l_dateFormat) || ' ' ||
                      l_merchant_name1 || ' ' || to_char(l_billed_amount, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22));
       	-- set a new line
       	document := document || '' || l_lineInfo;
       	l_lineInfo := '';
      ELSE  -- HTML type
        document := document || '<tr bgcolor='||th_bgcolor||'>';
        document := document || '<td bgcolor='||td_bgcolor||' align="left"><font color='||td_fontcolor||' face='||td_fontface||'>'|| to_char(l_transaction_date,l_dateFormat) || '</td>';
        document := document || '<td bgcolor='||td_bgcolor||' align="left"><font color='||td_fontcolor||' face='||td_fontface||'>'|| to_char(l_billed_amount, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22)) || '</td>';
        document := document || '<td bgcolor='||td_bgcolor||' align="left"><font color='||td_fontcolor||' face='||td_fontface||'>'|| l_merchant_name1 || '</td>';
        document := document || '<td bgcolor='||td_bgcolor||' align="left"><font color='||td_fontcolor||' face='||td_fontface||'>'|| l_merchant_city || '</td>';
        document := document || '<td bgcolor='||td_bgcolor||' align="left"><font color='||td_fontcolor||' face='||td_fontface||'>'|| l_expense_report_number || '</td>';
      END IF;


  END LOOP;
         --------------------------------------------
         l_debug_info := 'Generate Total Row';
         --------------------------------------------
         document := document || '<tr bgcolor='||th_bgcolor||'>';
         document := document || '<td align="right"><font color='||th_fontcolor||' face='||th_fontface||'><b>' || 'Total' || '</b></td>';
         document := document || '<td bgcolor='||td_bgcolor||' align="left"><font color='||td_fontcolor||' face='||td_fontface||'>'|| LPAD(to_char(l_total_billed_amt, FND_CURRENCY.Get_Format_Mask(l_billed_currency_code,22)),14) || '</td>';
         document := document || '</tr>';
         document := document || '</table><br>';
 END iF;

  close l_InactEmpCCTrxn_cursor;

    if (display_type = 'text/html') then
        document := document || '</table>';
    end if;

    document_type := display_type;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'GenerateCCTrxList',
                    document_id, l_debugInfo);
    raise;
END GenerateCCTrxList;

PROCEDURE FindActiveMAnager(p_item_type		IN VARCHAR2,
			     	        p_item_key		IN VARCHAR2,
			     	        p_actid		    IN NUMBER,
			     	        p_funmode		IN VARCHAR2,
			     	        p_result		OUT NOCOPY VARCHAR2) IS

-- Function Name: FindActiveMAnager
-- Author:        Geetha Gurram
-- Purpose:       Finds the Active Supervisor of the Inactive Employee
--
-- Input:         p_item_type
--                p_item_key
--                p_actid
--                p_funmode
--
-- Output:        p_result
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs
--

l_dummy_inact_emp_mang_name		    VARCHAR2(240);
l_inact_emp_mang_num			    VARCHAR2(30);
l_inact_emp_mang_cost_center		VARCHAR2(240);
l_inact_employee_id                 NUMBER;
l_supervisor_id                     NUMBER;
l_inact_emp_manager_id              NUMBER;
l_inact_emp_cost_center             VARCHAR2(30);
l_preparer_name		                VARCHAR2(30);
l_preparer_display_name	            VARCHAR2(80);
l_preparer_empl_id			        NUMBER;
l_forward_from_id                   NUMBER;
l_debug_info                        VARCHAR2(200);
l_employee_id                       NUMBER;
l_preparer_org_id                   NUMBER;
l_dummy_var                         BOOLEAN;
l_forward_from_name                 VARCHAR2(50);
l_manager_name                      VARCHAR2(240);

Begin


AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'start FindActiveMAnager');

  IF (p_funmode = 'RUN') THEN

   ------------------------------------------------------------
    l_debug_info := 'Retrieve INACT_EMPLOYEE_ID Item Attribute';
    ------------------------------------------------------------
    l_inact_employee_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                       p_item_key,
                                                       'INACT_EMPLOYEE_ID');

    -----------------------------------------------------
    l_debug_info := 'Get FORWARD_FROM_ID Item Attribute';
    -----------------------------------------------------
    l_forward_from_id := WF_ENGINE.GetItemAttrNUMBER(p_item_type,
			                                         p_item_key,
			                                         'FORWARD_FROM_ID');

    -----------------------------------------------------
    l_debug_info := 'Get PREPARER_EMPL_ID Item Attribute';
    -----------------------------------------------------
    l_preparer_empl_id := WF_ENGINE.GetItemAttrNUMBER(p_item_type,
			                                     p_item_key,
			                                     'PREPARER_EMPL_ID');


    -----------------------------------------------------
    l_debug_info := 'Get FORWARD_FROM_NAME Item Attribute';
    -----------------------------------------------------

   l_forward_from_name := WF_ENGINE.GetItemAttrText(p_item_type,
                                                 p_item_key,
                                                 'FORWARD_FROM_NAME');
    IF l_forward_from_name is null then
        l_preparer_empl_id := NULL;
    end if;


    l_employee_id := NVL(l_preparer_empl_id, l_inact_employee_id);

  -----------------------------------------------------------------------------------
  l_debug_info := 'Get the Manager Information Associated With Inactive Employee Id';
  -----------------------------------------------------------------------------------


  IF ((AP_WEB_DB_HR_INT_PKG.GetSupervisorInfo( l_employee_id ,l_supervisor_id, l_manager_name, l_preparer_org_id)= FALSE) OR l_supervisor_id is NULL) THEN
         p_result := 'COMPLETE:N';
      l_supervisor_id := NULL;
  ELSE

     WHILE (l_supervisor_id  IS NOT NULL) LOOP

         l_inact_emp_manager_id  := l_supervisor_id;

  -----------------------------------------------------------------------------------
  l_debug_info := 'Get the Manager Cost Center Associated With Inactive Employee Id';
  -----------------------------------------------------------------------------------

        AP_WEB_UTILITIES_PKG.GetEmployeeInfo(l_dummy_inact_emp_mang_name,
				                             l_inact_emp_mang_num,
				                             l_inact_emp_cost_center,
				                             l_inact_emp_manager_id);

         IF  l_dummy_inact_emp_mang_name  IS NULL THEN
                      IF ((AP_WEB_DB_HR_INT_PKG.GetSupervisorInfo( l_employee_id ,l_supervisor_id, l_manager_name, l_preparer_org_id)= FALSE) OR l_supervisor_id is NULL) THEN
                          p_result := 'COMPLETE:N';
                          l_supervisor_id := NULL;
                       ELSE
                          l_inact_emp_manager_id := l_supervisor_id;
                       END IF;
          ELSE
               l_preparer_empl_id := l_inact_emp_manager_id;
               l_supervisor_id := NULL;


                   ---------------------------------------------------------
                    l_debug_info := 'Set Item Attribute Preparer Org ID';
                    ---------------------------------------------------------
                        WF_ENGINE.SetItemAttrNumber(p_item_type,
	 		                                        p_item_key,
			                                        'PREPARER_ORG_ID',
			                                        l_preparer_org_id);

                      ---------------------------------------------------------
                    l_debug_info := 'Set Item Attribute Preparer EMPL ID';
                    ---------------------------------------------------------
                        WF_ENGINE.SetItemAttrNumber(p_item_type,
	 		                                     p_item_key,
			                                     'PREPARER_EMPL_ID',
			                                     l_PREPARER_EMPL_ID);
                     ----------------------------------------------------------
                     l_debug_info := 'Get Preparer Name Info For PREPARER_EMPL_ID';
                     ----------------------------------------------------------
                        WF_DIRECTORY.GetUserName('PER',
			                                     l_PREPARER_EMPL_ID,
			                                     l_preparer_name,
			                                     l_preparer_display_name);
                     ----------------------------------------------------------
                     l_debug_info := 'Set Preparer Name Info Item Attributes';
                     ----------------------------------------------------------
                        WF_ENGINE.SetItemAttrText(p_item_type,
			                                      p_item_key,
			                                      'PREPARER_NAME',
			                                      l_preparer_name);

                     ----------------------------------------------------------
                     l_debug_info := 'Set Preparer Display Name Item Attributes';
                     ----------------------------------------------------------

                        WF_ENGINE.SetItemAttrText(p_item_type,
			                                      p_item_key,
			                                      'PREPARER_DISPLAY_NAME',
			                                       l_preparer_display_name);

                     p_result := 'COMPLETE:Y';

                END IF;

           End Loop;

        END IF;


 ELSIF (p_funmode = 'CANCEL') THEN

    p_result := 'COMPLETE';

  END IF;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'end FindActiveMAnager');

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_EXPENSE_WF', 'FindActiveMAnager',
                     p_item_type, p_item_key, to_char(0), l_debug_info || FND_MESSAGE.GET);
    raise;
END FindActiveMAnager;

PROCEDURE SetAPRolePreparer(p_item_type		IN VARCHAR2,
			     	        p_item_key		IN VARCHAR2,
			     	        p_actid		    IN NUMBER,
			     	        p_funmode		IN VARCHAR2,
			     	        p_result		OUT NOCOPY VARCHAR2)
IS
-- Function Name: SetAPRolePreparer
-- Author:        Geetha Gurram
-- Purpose:       Sets exception AP Role Preparer Attribute
--
-- Input:         p_item_type
--                p_item_key
--                p_actid
--                p_funmode
--
-- Output:        p_result
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs
--

l_set_preparer_to_role  VARCHAR2(30);
l_role_display_name     VARCHAR2(100);
l_debug_info            VARCHAR2(200);
l_role_org_id           NUMBER;

BEGIN
AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'start SetAPRolePreparer');

  IF (p_funmode = 'RUN') THEN

   ------------------------------------------------------------
    l_debug_info := 'Retrieve AP_EXCEPTION_ROLE Item Attribute';
   ------------------------------------------------------------

    l_set_preparer_to_role := WF_ENGINE.GetItemAttrText(p_item_type, p_item_key, 'AP_EXCEPTION_ROLE');

   ------------------------------------------------------------------
    l_debug_info := 'Set Role Name to Preparer Name Item Attributes';
   ------------------------------------------------------------------

    WF_ENGINE.SetItemAttrText(p_item_type,
			                  p_item_key,
			                  'PREPARER_NAME',
			                  l_set_preparer_to_role);

   ---------------------------------------------------------------------------------
    l_debug_info := 'Get Role Display Name to Preparer Display Name Item Attributes';
   ---------------------------------------------------------------------------------

    l_role_display_name := WF_DIRECTORY.GetRoleDisplayName(l_set_preparer_to_role);

    -------------------------------------------------------------------------
    l_debug_info := 'Set Role Name to Preparer Display Name Item Attributes';
    -------------------------------------------------------------------------

    WF_ENGINE.SetItemAttrText(p_item_type,
			                  p_item_key,
			                  'PREPARER_DISPLAY_NAME',
			                  l_role_display_name);

    --------------------------------------------------------------
    l_debug_info := 'Get Org_Id for Role ';
    --------------------------------------------------------------

    /* Setting the Inactive Employee Org ID to be the Org ID of the Exception role Org ID */

    l_role_org_id  :=  WF_ENGINE.GetItemAttrNumber(p_item_type,
					           p_item_key,
					           'INACT_EMPLOYEE_ORG_ID');

    -------------------------------------------------------------------------
    l_debug_info := 'Set PREPARER_ORG_ID Item Attribute';
    -------------------------------------------------------------------------

     WF_ENGINE.SetItemAttrNumber(p_item_type,
			          p_item_key,
			          'PREPARER_ORG_ID',
			          l_role_org_id);


    p_result := 'COMPLETE:Y';

  ELSIF (p_funmode = 'CANCEL') THEN
    p_result := 'COMPLETE';
  END IF;

AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'end SetAPRolePreparer');

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'SetAPRolePreparer',
                     p_item_type, p_item_key, to_char(0), l_debug_info || FND_MESSAGE.GET);
    raise;
END SetAPRolePreparer;

PROCEDURE SetFromRoleForwardFrom(p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2) IS

-- Function Name: SetFromRoleForwardFrom
-- Author:        Geetha Gurram
-- Purpose:       Sets Attribute value for "From Role" Forward from
--
-- Input:         p_item_type
--                p_item_key
--                p_actid
--                p_funmode
--
-- Output:        p_result
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs

  l_debug_info                  VARCHAR2(200);
BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'start SetFromRoleForwardFrom');

  IF (p_funmode = 'RUN') THEN
    ----------------------------------------------------------------
    l_debug_info := 'Set #FROM_ROLE to Forward From';
    ----------------------------------------------------------------
    WF_ENGINE.SetItemAttrText(p_item_type,
                              p_item_key,
                              '#FROM_ROLE',
                              WF_ENGINE.GetItemAttrText(p_item_type,
                                                        p_item_key,
                                                        'FORWARD_FROM_NAME'));
    p_result := 'COMPLETE:Y';

  ELSIF (p_funmode = 'CANCEL') THEN
    p_result := 'COMPLETE';
  END IF;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'end SetFromRoleForwardFrom');

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'SetFromRoleForwardFrom',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END SetFromRoleForwardFrom;

PROCEDURE RecordForwardFromInfo(p_item_type	    IN VARCHAR2,
		     	  	            p_item_key		IN VARCHAR2,
		     	  	            p_actid		    IN NUMBER,
		     	  	            p_funmode		IN VARCHAR2,
		     	  	            p_result		OUT NOCOPY VARCHAR2) IS

-- Function Name: RecordForwardFromInfo
-- Author:        Geetha Gurram
-- Purpose:       Sets Attribute value for "From Role" Forward from
--
-- Input:         p_item_type
--                p_item_key
--                p_actid
--                p_funmode
--
-- Output:        p_result
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs

  l_PREPARER_EMPL_ID			    NUMBER;
  l_preparer_name		    VARCHAR2(30);
  l_preparer_display_name  	VARCHAR2(80);
  l_debug_info			    VARCHAR2(200);
BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'start RecordForwardFromInfo');

  IF (p_funmode = 'RUN') THEN

    ------------------------------------------------------------
    l_debug_info := 'Retrieve Preparer_Info Item Attributes';
    ------------------------------------------------------------
    l_PREPARER_EMPL_ID := WF_ENGINE.GetItemAttrNumber(p_item_type,
					         p_item_key,
					         'PREPARER_EMPL_ID');

    l_preparer_name := WF_ENGINE.GetItemAttrText(p_item_type,
					        p_item_key,
					        'PREPARER_NAME');

    l_preparer_display_name := WF_ENGINE.GetItemAttrText(p_item_type,
					        	p_item_key,
					        'PREPARER_DISPLAY_NAME');

    ----------------------------------------------------------------------
    l_debug_info := 'Set Forward_From Item Attributes With Approver Info';
    ----------------------------------------------------------------------
    WF_ENGINE.SetItemAttrNUMBER(p_item_type,
			        p_item_key,
			        'FORWARD_FROM_ID',
			        l_PREPARER_EMPL_ID);

    WF_ENGINE.SetItemAttrText(p_item_type,
			      p_item_key,
			      'FORWARD_FROM_NAME',
			      l_preparer_name);

    WF_ENGINE.SetItemAttrText(p_item_type,
			      p_item_key,
			      'FORWARD_FROM_DISPLAY_NAME',
			      l_preparer_display_name);

    p_result := 'COMPLETE:Y';

  ELSIF (p_funmode = 'CANCEL') THEN

    p_result := 'COMPLETE';

  END IF;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'end RecordForwardFromInfo');

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'RecordForwardFromInfo',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    raise;
END RecordForwardFromInfo;

PROCEDURE SetMangInfoPrepNoResp(itemtype  in varchar2,
                                itemkey   in varchar2,
                                actid     in number,
                                funcmode  in varchar2,
                                resultout    in out NOCOPY varchar2)IS

-- Function Name: SetMangInfoPrepNoResp
-- Author:        Geetha Gurram
-- Purpose:       Sets Attribute value : Note for the preparer that the notification is forwarded from preparer,
--                who failed to respond
--
-- Input:         p_item_type
--                p_item_key
--                p_actid
--                p_funmode
--
-- Output:        p_result
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs

l_preparer_display_name     VARCHAR2(100);
l_note_mang_prep_no_resp    VARCHAR2(2000);
l_debug_info                VARCHAR2(200);

BEGIN

AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'start SetMangInfoPrepNoResp');


  if (funcmode = 'RUN') then

  l_preparer_display_name := WF_ENGINE.GetItemAttrText(itemtype,
					        	                       itemkey,
					                                   'PREPARER_DISPLAY_NAME');

  --------------------------------------------------------------------
  l_debug_info := 'Get No Response from the Preparer from FND_MESSAGE';
  ---------------------------------------------------------------------

   fnd_message.set_name('SQLAP','OIE_INACT_PREPARER_NO_RESP');
   fnd_message.set_token('PREPARER_NAME', l_preparer_display_name);
   l_note_mang_prep_no_resp := fnd_message.get;

   WF_ENGINE.SetItemAttrText(itemtype,
			                 itemkey,
			                 'NOTE_MANG_PREP_NO_RESPONSE',
			                 l_note_mang_prep_no_resp);

    resultout := 'COMPLETE:Y';

  ELSIF (funcmode = 'CANCEL') THEN

    resultout := 'COMPLETE';

  END IF;

AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'end SetMangInfoPrepNoResp');

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'SetMangInfoPrepNoResp',
                     itemtype, itemkey, to_char(actid), l_debug_info);
    raise;
end SetMangInfoPrepNoResp;

PROCEDURE CheckMangSecAttr(itemtype    in varchar2,
                           itemkey     in varchar2,
                           actid       in number,
                           funcmode    in varchar2,
                           resultout   in out NOCOPY varchar2)
IS

-- Function Name: CheckMangSecAttr
-- Author:        Geetha Gurram
-- Purpose:       Checks Managers has securing Attribute to create inactive employees expense report
--
-- Input:         itemtype
--                itemkey
--                actid
--                funmode
--
-- Output:        resultout Yes/No
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs

l_preparer_Userid                   AP_WEB_DB_HR_INT_PKG.fndUser_userID;
l_preparer_userIdCursor             AP_WEB_DB_HR_INT_PKG.UserIdRefCursor;
l_number_of_emp_user                NUMBER;
l_check_mang_sec_attribute          BOOLEAN := FALSE;
l_emplist_for_webuser               AP_WEB_DB_HR_INT_PKG.EmpNameCursor;
l_temp_emplist_for_webuser          AP_WEB_DB_HR_INT_PKG.EmpNameCursor;
l_preparer_emp_id                   NUMBER;
l_debug_info                        VARCHAR2(200);
l_inactive_employee_id              NUMBER;
l_employee_id                       AP_WEB_DB_HR_INT_PKG.usrSecAttr_webUserID;
l_employee_name                     AP_WEB_DB_HR_INT_PKG.empCurrent_fullName;
l_preparer_web_user_id              NUMBER;
l_preparer_name                     VARCHAR2(30);


BEGIN

AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'start CheckMangSecAttr');


 IF (funcmode = 'RUN') then

 ------------------------------------------------------------------
    l_debug_info := 'Retrieve PREPARER_EMPL_ID Item Attributes';
 ------------------------------------------------------------------
    l_preparer_emp_id := WF_ENGINE.GetItemAttrNumber(itemtype,
					         itemkey,
					         'PREPARER_EMPL_ID');

 -------------------------------------------------------------------
    l_debug_info := 'Retrieve PREPARER_NAME Item Attributes';
 -------------------------------------------------------------------
   l_preparer_name := WF_ENGINE.GetItemAttrText(itemtype,
					        itemkey,
					        'PREPARER_NAME');


 -------------------------------------------------------------------
    l_debug_info := 'Retrieve INACT_EMPLOYEE_ID Item Attributes';
 -------------------------------------------------------------------


    l_inactive_employee_id := WF_ENGINE.GetItemAttrNumber(itemtype,
					                   itemkey,
					                   'INACT_EMPLOYEE_ID');


 ---------------------------------------------
    l_debug_info := 'Getting Preparer UserId';
 ---------------------------------------------

begin

 IF (GetUserIdForEmp(l_preparer_name, l_preparer_web_user_id)
      = FALSE) THEN
   l_check_mang_sec_attribute := False;
   resultout := 'COMPLETE:N';
 END IF;

 EXCEPTION
 WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'CheckMangSecAttr',
                     itemtype, itemkey, to_char(actid), l_debug_info);
    raise;
 end;

   ------------------------------------------------------------
    l_debug_info := 'Getting WebUser for preparer employee ID';
   ------------------------------------------------------------

   IF ( AP_WEB_DB_HR_INT_PKG.GetAllEmpListForWebUserCursor(
                l_preparer_web_user_id,
				l_emplist_for_webuser) = TRUE ) THEN
    	LOOP
      		FETCH l_emplist_for_webuser INTO l_employee_id, l_employee_name;
                If l_employee_id = l_inactive_employee_id then
                   l_check_mang_sec_attribute  := True;
                end if;
            EXIT WHEN l_emplist_for_webuser%NOTFOUND;
        END LOOP;
            CLOSE  l_emplist_for_webuser;

    END IF;

    IF l_check_mang_sec_attribute = True THEN
        resultout := 'COMPLETE:Y';
    ELSE
        resultout := 'COMPLETE:N';
    END IF;


 ELSIF (funcmode = 'CANCEL') THEN

    resultout := 'COMPLETE';

 END IF;


AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'end CheckMangSecAttr');

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'CheckMangSecAttr',
                     itemtype, itemkey, to_char(actid), l_debug_info);
    raise;
END CheckMangSecAttr;

PROCEDURE AddSecAttrPreparer(itemtype    in varchar2,
                             itemkey     in varchar2,
                             actid       in number,
                             funcmode    in varchar2,
                             resultout   in out NOCOPY varchar2)
IS

-- Function Name: AddSecAttrPreparer
-- Author:        Geetha Gurram
-- Purpose:       Add securing Attribute to create inactive employees expense report
--
-- Input:         itemtype
--                itemkey
--                actid
--                funmode
--
-- Output:        resultout
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs

   l_return_status                  VARCHAR2(2000);
   l_msg_count                      NUMBER;
   l_msg_data                       VARCHAR2(2000);
   l_preparer_emp_id                NUMBER;
   l_inact_employee_id              NUMBER;
   l_error                          VARCHAR2(2000);
   l_debug_info                     VARCHAR2(200);
   l_preparer_userIdCursor          AP_WEB_DB_HR_INT_PKG.UserIdRefCursor;
   l_preparer_web_user_id           NUMBER;
   l_inact_employee_display_name    VARCHAR2(100);
   l_preparer_display_name          VARCHAR2(100);
   l_preparer_name                  VARCHAR2(100);
   l_error_preparer_name            VARCHAR2(150);
   l_error_inact_empl_name          VARCHAR2(150);
   l_error_instructions             Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;
   l_error_note                     Wf_Item_Attribute_Values.TEXT_VALUE%TYPE;


BEGIN
   AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'start AddSecuringAttributePreparer');

 IF (funcmode = 'RUN') then

    ---------------------------------------------------------------
    l_debug_info := 'Retrieve Preparer Employee ID Item Attributes';
    ---------------------------------------------------------------
    l_preparer_emp_id := WF_ENGINE.GetItemAttrNumber(itemtype,
					         itemkey,
					         'PREPARER_EMPL_ID');

     ------------------------------------------------------------------------
    l_debug_info := 'Retrieve Preparer Employee Display Name Item Attributes';
    --------------------------------------------------------------------------
    l_preparer_display_name := WF_ENGINE.GetItemAttrText(itemtype,
					                                       itemkey,
					                                       'PREPARER_DISPLAY_NAME');

     --------------------------------------------------------------------
    l_debug_info := 'Retrieve Preparer Employee Name Item Attributes';
    ----------------------------------------------------------------------
    l_preparer_name := WF_ENGINE.GetItemAttrText(itemtype,
					                               itemkey,
					                               'PREPARER_NAME');


    -------------------------------------------------------------------
    l_debug_info := 'Retrieve INACT_EMPLOYEE_ID Item Attributes';
    -------------------------------------------------------------------

    l_inact_employee_id := WF_ENGINE.GetItemAttrNumber(itemtype,
					                   itemkey,
					                   'INACT_EMPLOYEE_ID');

    -----------------------------------------------------------------------
    l_debug_info := 'Retrieve INACT_EMPLOYEE_DISPLAY_NAME Item Attributes';
    -----------------------------------------------------------------------

    l_inact_employee_display_name := WF_ENGINE.GetItemAttrText(itemtype,
					                                             itemkey,
					                                              'INACT_EMPLOYEE_DISPLAY_NAME');
  begin

     IF ( GetUserIdForEmp(l_preparer_name, l_preparer_web_user_id)
           = FALSE) THEN
           resultout := 'COMPLETE:N';
            ------------------------------------------------------------------
            l_debug_info := 'No Preparer WEB UserId';
            ------------------------------------------------------------------
           Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'AddSecAttrPreparer',
                      itemtype, itemkey, to_char(actid), l_debug_info);
     ELSE

           ---------------------------------------------------
           l_debug_info := 'Inserting Securing Attribute';
            --------------------------------------------------

          ICX_User_Sec_Attr_PUB.Create_User_Sec_Attr (
          p_api_version_number    => c_api_version_num,
          p_commit                => c_commit,
          p_return_status         => l_return_status,
          p_msg_count             => l_msg_count,
          p_msg_data              => l_msg_data,
          p_web_user_id           => l_preparer_web_user_id,
          p_attribute_code        => c_sec_attribute,
          p_attribute_appl_id     => c_attribute_appl_id,
          p_varchar2_value        => NULL,
          p_date_value            => NULL,
          p_number_value          => l_inact_employee_id,
          p_created_by            => fnd_global.user_id,
          p_creation_date         => SYSDATE,
          p_last_updated_by       => fnd_global.user_id,
          p_last_update_date      => SYSDATE,
          p_last_UPDATE_login     => c_last_update_login);

          IF l_return_status  <> Fnd_Api.G_RET_STS_SUCCESS THEN
               format_message(l_return_status, l_msg_count, l_msg_data, l_error);

               l_error_preparer_name := l_preparer_display_name || ' (' || l_preparer_name || ')';
               l_error_inact_empl_name := l_inact_employee_display_name || ' (' ||to_char(l_inact_employee_id)|| ')';


                WF_ENGINE.SetItemAttrText(itemtype,
			                              itemkey,
			                              'ERROR_MESSAGE',
			                              l_error);

                WF_ENGINE.SetItemAttrText(itemtype,
			                              itemkey,
			                              'ERROR_ITEM_KEY',
			                              itemkey);

                WF_ENGINE.SetItemAttrText(itemtype,
			                              itemkey,
			                              'ERROR_ITEM_TYPE',
			                               itemtype);

                WF_ENGINE.SetItemAttrText(itemtype,
			                              itemkey,
			                              'ERROR_ACTIVITY_ID',
			                               actid);

                WF_ENGINE.SetItemAttrText(itemtype,
			                              itemkey,
			                              'ERROR_INACT_EMPL_NAME',
			                              l_error_inact_empl_name);

                WF_ENGINE.SetItemAttrText(itemtype,
			                              itemkey,
			                              'ERROR_PREPARER_NAME',
			                               l_error_preparer_name);

                ------------------------------------------------------------
                l_debug_info := 'Get Error Instructions from FND_MESSAGE';
                ------------------------------------------------------------

                fnd_message.set_name('SQLAP','OIE_INACT_ERROR_INSTRUCTIONS');
                l_error_instructions := fnd_message.get;

                -------------------------------------------------------------
                l_debug_info := 'Set WF Error Instructions Item Attribute';
                -------------------------------------------------------------

                WF_ENGINE.SetItemAttrText(itemtype,
			                              itemkey,
			                              'ERROR_INSTRUCTIONS',
			                              l_error_instructions);

                ------------------------------------------------------------
                l_debug_info := 'Get Error Note from FND_MESSAGE';
                ------------------------------------------------------------

                fnd_message.set_name('SQLAP','OIE_INACT_ERROR_NOTE');
                l_error_note := fnd_message.get;

                -------------------------------------------------------------
                l_debug_info := 'Set WF Error Note Item Attribute';
                -------------------------------------------------------------

                WF_ENGINE.SetItemAttrText(itemtype,
			                              itemkey,
			                              'ERROR_NOTE',
			                              l_error_note);

               resultout := 'COMPLETE:AP_FAIL';

          ELSE
                    resultout := 'COMPLETE:AP_PASS';

          END IF;


       END IF;
END;


 ELSIF (funcmode = 'CANCEL') THEN

   resultout := 'COMPLETE';

 END IF;

AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'end AddSecAttrPreparer');

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'AddSecAttrPreparer',
                     itemtype, itemkey, to_char(actid), l_debug_info||l_error);
    raise;
END AddSecAttrPreparer;

PROCEDURE RemoveSecAttrPreparer(itemtype    in varchar2,
                                itemkey     in varchar2,
                                actid       in number,
                                funcmode    in varchar2,
                                resultout   in out NOCOPY varchar2)
IS

-- Function Name: RemoveSecAttrPreparer
-- Author:        Geetha Gurram
-- Purpose:       Remove securing Attribute from the Preparer
--
-- Input:         itemtype
--                itemkey
--                actid
--                funmode
--
-- Output:        resultout
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs

   l_return_status                    VARCHAR2(2000);
   l_msg_count                      NUMBER;
   l_msg_data                       VARCHAR2(2000);
   l_preparer_emp_id                NUMBER;
   l_inact_employee_id              NUMBER;
   l_error                          VARCHAR2(2000);
   l_debug_info                     VARCHAR2(200);
   l_preparer_Userid                AP_WEB_DB_HR_INT_PKG.fndUser_userID;
   l_preparer_userIdCursor          AP_WEB_DB_HR_INT_PKG.UserIdRefCursor;
   l_preparer_web_user_id           NUMBER;
   l_inact_emp_web_user_id          NUMBER;
   l_preparer_name                  VARCHAR2(50);
   l_inact_employee_name            VARCHAR2(50);


  Cursor emp_sec_attr_cur(p_inact_employee_id      in number,
                          p_preparer_web_user_id  in number)
  IS
        select web_user_id
        from ak_web_user_sec_attr_values
        where web_user_id = p_preparer_web_user_id
        and attribute_code = 'ICX_HR_PERSON_ID'
        and number_value = to_char(p_inact_employee_id);


BEGIN

AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'start RemoveSecAttrPreparer');

 IF (funcmode = 'RUN') then
 ------------------------------------------------------------------
    l_debug_info := 'Retrieve Preparer Employee ID Item Attributes';
 ------------------------------------------------------------------
    l_preparer_emp_id := WF_ENGINE.GetItemAttrNumber(itemtype,
					         itemkey,
					         'PREPARER_EMPL_ID');

 -------------------------------------------------------------------
 l_debug_info := 'Retrieve Inactive Employee Name Item Attributes';
 -------------------------------------------------------------------
   l_inact_employee_name := WF_ENGINE.GetItemAttrText(itemtype,
					                                  itemkey,
					                                  'INACT_EMP_NAME');

 -------------------------------------------------------------------
    l_debug_info := 'Retrieve Inactive Employee ID Item Attributes';
 -------------------------------------------------------------------
   l_preparer_name := WF_ENGINE.GetItemAttrText(itemtype,
					        itemkey,
					        'PREPARER_NAME');

 -------------------------------------------------------------------
    l_debug_info := 'Retrieve Inactive Employee ID Item Attributes';
 -------------------------------------------------------------------

    l_inact_employee_id := WF_ENGINE.GetItemAttrNumber(itemtype,
					                   itemkey,
					                   'INACT_EMPLOYEE_ID');

 -------------------------------------------------
    l_debug_info := 'Getting Preparer WEB UserId';
 -------------------------------------------------

begin

 IF (GetUserIdForEmp(l_preparer_name, l_preparer_web_user_id)
      = FALSE) THEN
   resultout := 'COMPLETE:N';
   ----------------------------------------------------
    l_debug_info := 'No Inact Empl WEB UserId';
   -----------------------------------------------------
   Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'RemoveSecAttrPreparer',
                     itemtype, itemkey, to_char(actid), l_debug_info);
 ELSE

  open emp_sec_attr_cur(l_inact_employee_id,
                        l_preparer_web_user_id);
  Loop
    fetch emp_sec_attr_cur into l_preparer_web_user_id;
    exit when emp_sec_attr_cur%notfound;

    begin
    ---------------------------------------------------
    l_debug_info := 'Deleting Securing Attribute';
    --------------------------------------------------

    ICX_User_Sec_Attr_PUB.Delete_User_Sec_Attr (
          p_api_version_number    => c_api_version_num,
          p_commit                => c_commit,
          p_return_status         => l_return_status,
          p_msg_count             => l_msg_count,
          p_msg_data              => l_msg_data,
          p_web_user_id           => l_preparer_web_user_id,
          p_attribute_code        => c_sec_attribute,
          p_attribute_appl_id     => c_attribute_appl_id,
          p_varchar2_value        => NULL,
          p_date_value            => NULL,
          p_number_value          => l_inact_employee_id);

    -- Bug 3320047 resultout was not set
    resultout := 'COMPLETE:Y';

    IF l_return_status  <> Fnd_Api.G_RET_STS_SUCCESS THEN
          format_message(l_return_status, l_msg_count, l_msg_data, l_error);
             Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'RemoveSecAttrPreparer',
                     itemtype, itemkey, to_char(actid), l_error);

      -- Bug 3320047 resultout was not set
      resultout := 'COMPLETE:N';
    ELSE
     resultout := 'COMPLETE:Y';
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
           Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'RemoveSecAttrPreparer',
                     itemtype, itemkey, to_char(actid), l_debug_info);
            raise;
    end;

    end loop;

    close emp_sec_attr_cur;

END IF;
END;

 ELSIF (funcmode = 'CANCEL') THEN

   resultout := 'COMPLETE';

 END IF;

AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'end RemoveSecAttrPreparer');

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'RemoveSecAttrPreparer',
                     itemtype, itemkey, to_char(actid), l_debug_info);
    raise;
END RemoveSecAttrPreparer;

PROCEDURE Format_message(p_status 	IN  		VARCHAR2,
                         p_msg_count 	IN  		NUMBER,
                         p_msg_data 	IN  		VARCHAR2,
                         p_error 	OUT NOCOPY      VARCHAR2)
IS

-- Function Name: Format_message
-- Author:        Geetha Gurram
-- Purpose:       Format error message
--
-- Input:         p_status
--                p_msg_count
--                p_msg_data
--                p_error
--
-- Output:        resultout
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs

l_error        VARCHAR2(2000);
l_debug_info   VARCHAR2(200);
BEGIN

AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'start format_message');

   IF p_status = Fnd_Api.G_RET_STS_SUCCESS THEN
       p_error:= 'Status: Successful!';
   ELSIF p_status = Fnd_Api.G_RET_STS_ERROR THEN
       l_error := 'Status: Error!   ';
       IF  p_msg_count = 1 THEN
          l_error:= l_error || '   There is ' || p_msg_count || ' error:';
       ELSIF  p_msg_count > 1 THEN
          l_error:= l_error || '   There are ' || p_msg_count || ' errors:';
       ELSE
          l_error:= l_error || ' error message:';
       END IF;
       p_error:= l_error || p_msg_data;
   END IF;

AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'end format_message');

END Format_message;

PROCEDURE  CheckCCTransactionExists (itemtype  in varchar2,
                                     itemkey   in varchar2,
                                     actid     in number,
                                     funcmode  in varchar2,
                                     resultout in out NOCOPY varchar2)
IS

-- Function Name: CheckCCTransactionExists
-- Author:        Geetha Gurram
-- Purpose:       Check if there are any more CC Transactions still exists for the inactive employee
--                which have not been captured on expense report
--
-- Input:         itemtype
--                itemkey
--                actid
--                funmode
--
-- Output:        resultout
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs

   l_cc_trx_exists                  NUMBER := 0;
   l_debug_info                     VARCHAR2(200);
   l_inact_employee_id              NUMBER;
   l_credit_card_program_id         NUMBER;
   l_cc_billed_start_date           DATE;
   l_cc_billed_end_date             DATE;
   l_itemkey                        VARCHAR2(30):= '';


   Cursor trx_exists_cur(p_credit_card_program_id in number,
                         p_inact_employee_id      in number,
                         p_itemkey   in varchar2,
                         p_cc_billed_start_date  in date,
                         p_cc_billed_end_date in date) is
        select 1
          from dual
         where exists (select cct.trx_id
                      from ap_cards_all   ac,
                           ap_credit_card_trxns cct
                     where ac.card_program_id = p_credit_card_program_id
                       and ac.employee_id = p_inact_employee_id
                       and ac.card_program_id = cct.card_program_id
                       and ac.card_id     = cct.card_id
                       and cct.validate_code  = 'Y'
                       and cct.payment_flag  <> 'Y'
                       and nvl(cct.category, 'BUSINESS') not in ( 'DISPUTED', 'DEACTIVATED')
                       and cct.inactive_emp_wf_item_key  = p_itemkey
                      -- group by cct.trx_id
                    minus
                        (select cct.trx_id
                    from ap_cards_all   ac,
                         ap_credit_card_trxns cct,
                         ap_expense_report_headers erh
                   where ac.card_program_id = p_credit_card_program_id
                     and ac.card_program_id = cct.card_program_id
                     and ac.card_id     = cct.card_id
                     and cct.validate_code  = 'Y'
                     and cct.payment_flag  <> 'Y'
                     and nvl(cct.category, 'BUSINESS') not in ( 'DISPUTED', 'DEACTIVATED')
                     and cct.report_header_id = erh.report_header_id
                     and erh.source <> 'NonValidatedWebExpense'
                     and nvl(cct.billed_date, cct.posted_date) between p_cc_billed_start_date and  p_cc_billed_end_date
                     and ac.employee_id = p_inact_employee_id
                     and cct.inactive_emp_wf_item_key  = p_itemkey
                     -- group by cct.trx_id
                     ));

BEGIN

AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'start CheckCCTransactionExists');

l_itemkey := itemkey;

 IF (funcmode = 'RUN') THEN


 -------------------------------------------------------------------
    l_debug_info := 'Retrieve Inactive Employee ID Item Attributes';
 -------------------------------------------------------------------

    l_inact_employee_id := WF_ENGINE.GetItemAttrNumber(itemtype,
					                                   itemkey,
					                                   'INACT_EMPLOYEE_ID');

 -------------------------------------------------------------------
    l_debug_info := 'Retrieve Credit Card Program ID Item Attributes';
 -------------------------------------------------------------------

    l_credit_card_program_id := WF_ENGINE.GetItemAttrNumber(itemtype,
					                                        itemkey,
					                                        'CARD_PROG_ID');

  ------------------------------------------------------------
  l_debug_info := 'Retreive CC_TRX_BEGIN_DATE Item Attribute';
  ------------------------------------------------------------

    l_cc_billed_start_date := WF_ENGINE.GetItemAttrDate(itemtype,
					                                    itemkey,
					                                    'CC_TRX_BEGIN_DATE');

  ----------------------------------------------------------
  l_debug_info := 'Retreive Credit_END_DATE Item Attribute';
  ----------------------------------------------------------

    l_cc_billed_end_date := WF_ENGINE.GetItemAttrDate(itemtype,
					                                  itemkey,
     				                                  'CC_TRX_END_DATE');

  Begin
  ----------------------------------------------------------
  l_debug_info := 'Is Credit Card Transactions exists ';
  ----------------------------------------------------------
      open trx_exists_cur( l_credit_card_program_id,
                           l_inact_employee_id,
                           l_itemkey,
                           l_cc_billed_start_date,
                           l_cc_billed_end_date);
      fetch trx_exists_cur into l_cc_trx_exists;
      close trx_exists_cur;

  exception
  when others then
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'CheckCCTransactionExists',
                     itemtype, itemkey, to_char(actid), l_debug_info);
  raise;
  end;

  IF l_cc_trx_exists > 0 THEN
     resultout := 'COMPLETE:Y';
  ELSE
     resultout := 'COMPLETE:N';
  END IF;

 ELSIF (funcmode = 'CANCEL') THEN

  resultout := 'COMPLETE';

 END IF;

AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'end CheckCCTransactionExists');

exception
when others then
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'CheckCCTransactionExists',
               itemtype, itemkey, to_char(actid), l_debug_info);
  raise;

END CheckCCTransactionExists;

PROCEDURE  CheckWfExistsEmpl(itemtype  in varchar2,
                             itemkey   in varchar2,
                             actid     in number,
                             funcmode  in varchar2,
                             resultout in out NOCOPY varchar2)
IS
-- Function Name: CheckWfExistsEmpl
-- Author:        Geetha Gurram
-- Purpose:       Check if there are any Workflow Process in active mode for the inactive employee
--
-- Input:         itemtype
--                itemkey
--                actid
--                funmode
--
-- Output:        resultout
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs

  -- 3319945: Initialize l_wf_exists_status
  l_wf_exists_status               NUMBER :=0;
  l_debug_info                     VARCHAR2(200);
  l_inact_employee_id              NUMBER;
  l_credit_card_program_id         NUMBER;
  l_itemkey                        VARCHAR2(30);

  Cursor wf_exists_cur(p_credit_card_program_id in number,
                       p_inact_employee_id      in number,
                       p_itemkey                in varchar2)
  IS
     select 1
       from  dual
      where exists  (select cct.trx_id
                        from ap_credit_card_trxns cct,
                             ap_cards_all 	ac,
                             --ap_card_programs_all cp,
                             ap_expense_report_lines erl,
                             ap_expense_report_headers erh
                       where ac.card_program_id = p_credit_card_program_id
                         and cct.validate_code  = 'Y'
                         and cct.payment_flag  <> 'Y'
                         and cct.inactive_emp_wf_item_key  is not null
                         and cct.inactive_emp_wf_item_key  <> p_itemkey
                         and nvl(cct.category, 'BUSINESS') not in ( 'DISPUTED', 'DEACTIVATED')
                         and ac.card_program_id = cct.card_program_id
                         and ac.card_id     = cct.card_id
                         and cct.report_header_id = erh.report_header_id(+)
                     --and cct.trx_id = erl.credit_card_trx_id(+)
                         and erh.report_header_id = erl.report_header_id(+)
                       --and decode(erh.expense_status_code, null, decode(erh.workflow_approved_flag, 'S','SAVED',null, decode(erh.source, null,'UNSUBMITTED')), erh.expense_status_code)
                         and ac.employee_id = p_inact_employee_id
                         group by cct.trx_id);

BEGIN

 AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'start CheckWfExistsEmpl');

  -- 3319945: Initialize l_itemkey
  l_itemkey := itemkey;

 IF (funcmode = 'RUN') THEN


 -------------------------------------------------------------------
    l_debug_info := 'Retrieve Inactive Employee ID Item Attributes';
 -------------------------------------------------------------------

    l_inact_employee_id := WF_ENGINE.GetItemAttrNumber(itemtype,
					                                   itemkey,
					                                   'INACT_EMPLOYEE_ID');

    -------------------------------------------------------------------
    l_debug_info := 'Retrieve Credit Card Program ID Item Attributes';
    -------------------------------------------------------------------

    l_credit_card_program_id := WF_ENGINE.GetItemAttrNumber(itemtype,
					                                        itemkey,
					                                        'CARD_PROG_ID');


 Begin

  ----------------------------------------------------------
  l_debug_info := 'Is Workflow exists ';
  ----------------------------------------------------------

   open wf_exists_cur(l_credit_card_program_id,
                  l_inact_employee_id,
                  l_itemkey);
      fetch wf_exists_cur into l_wf_exists_status;
      close wf_exists_cur;


  exception
  when others then
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'CheckWfExistsEmpl',
                     itemtype, itemkey, to_char(actid), l_debug_info);
  raise;
  end;

  IF l_wf_exists_status  > 0 THEN
     resultout := 'COMPLETE:Y';
  ELSE
     resultout := 'COMPLETE:N';
  END IF;

 ELSIF (funcmode = 'CANCEL') THEN

   resultout := 'COMPLETE';

 END IF;

AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'end CheckWfExistsEmpl');

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'CheckWfExistsEmpl',
                     itemtype, itemkey, to_char(actid), l_debug_info);
    raise;

END  CheckWfExistsEmpl;
----------------------------------------------------------------------
PROCEDURE CallbackFunction(	p_s_item_type      IN VARCHAR2,
                          	p_s_item_key       IN VARCHAR2,
                          	p_n_actid          IN NUMBER,
                          	p_s_command        IN VARCHAR2,
                          	p_s_result         OUT NOCOPY VARCHAR2)
IS

-- Function Name: CallbackFunction
-- Author:        Geetha Gurram
-- Purpose:       Sets the session context(userid, org_id etc.,) when workflow is started or restarted
--
-- Input:         p_s_item_type
--                p_s_item_key
--                actid
--                funmode
--
-- Output:        resultout
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs

  l_n_org_id 			Number;
  l_n_user_id 			Number;
  l_n_resp_id 			Number;
  l_n_resp_appl_id 		Number;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('P_WEB_INACTIVE_EMP_WF_PKG', 'start CallbackFunction');

  begin

    l_n_org_id := WF_ENGINE.GetItemAttrNumber(p_s_item_type,
  					        p_s_item_key,
  					        'ORG_ID');
  exception
  	when others then
  	  if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
  	    -- ORG_ID item attribute doesn't exist, need to add it
  	    wf_engine.AddItemAttr(p_s_item_type, p_s_item_key, 'ORG_ID');
  	    -- get the org_id from header for old reports
  	    IF (AP_WEB_DB_EXPRPT_PKG.GetOrgIdByReportHeaderId(
  				to_number(p_s_item_key),
  				l_n_org_id) <> TRUE ) THEN
  	    	l_n_org_id := NULL;
  	    END IF;
	    WF_ENGINE.SetItemAttrNumber(p_s_item_type,
  					p_s_item_key,
  					'ORG_ID',
					l_n_org_id);
  	  else
  	    raise;
  	  end if;

  end;



  IF (p_s_command = 'SET_CTX') THEN

    begin
      l_n_user_id := WF_ENGINE.GetItemAttrNumber(p_s_item_type,
  						   p_s_item_key,
  						   'USER_ID');
      l_n_resp_id := WF_ENGINE.GetItemAttrNumber(p_s_item_type,
  						   p_s_item_key,
  						   'RESPONSIBILITY_ID');
      l_n_resp_appl_id := WF_ENGINE.GetItemAttrNumber(p_s_item_type,
  				      		    p_s_item_key,
  						    'APPLICATION_ID');
      -- Set the context
      FND_GLOBAL.APPS_INITIALIZE(  USER_ID => l_n_user_id,
				 RESP_ID => l_n_resp_id,
				 RESP_APPL_ID => l_n_resp_appl_id
				 );
    exception
	when others then
	  if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
	    null;
	  else
	    raise;
	  end if;
    end;

    -- Set Org context
    -- Needs to be after FND_GLOBAL.APPS_INITIALIZE because
    -- user_id, resp_id, and appl_id may be null because
    -- the attributes don't exist or because they are not set
    if (l_n_org_id is not null) then
            mo_global.set_policy_context(p_access_mode => 'S',
                                   p_org_id      => l_n_org_id);
    end if;

  ELSIF (p_s_command = 'TEST_CTX') THEN
     IF ((nvl(mo_global.get_access_mode, 'NULL') <> 'S') OR
        (nvl(mo_global.get_current_org_id, -99) <> nvl(l_n_org_id, -99)) ) THEN
         p_s_result := 'FALSE';
     ELSE
         p_s_result := 'TRUE';
     END IF;

  END IF;

  AP_WEB_UTILITIES_PKG.logProcedure('P_WEB_INACTIVE_EMP_WF_PKG', 'end CallbackFunction');

END CallbackFunction;

PROCEDURE IsNotifTransferred( p_item_type      IN VARCHAR2,
                              p_item_key       IN VARCHAR2,
                              p_actid          IN NUMBER,
                              p_funmode        IN VARCHAR2,
                              p_result         OUT NOCOPY VARCHAR2)
IS
-- Function Name: IsNotifTransferred
-- Author:        Geetha Gurram
-- Purpose:       Check if Notification transfered from one preparer to another
--
-- Input:         p_itemtype
--                p_itemkey
--                p_actid
--                p_funmode
--
-- Output:        p_result
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs

  l_debug_info         VARCHAR2(1000);
  l_notificationID     NUMBER;
  l_TransferNotificationID     NUMBER;
  l_TransferToID       NUMBER;
  l_Transferee         VARCHAR2(80);
  l_TransferToName     VARCHAR2(30);
  l_preparer_id        NUMBER;
  l_preparer_name      VARCHAR2(30);
  l_preparer_display_name      VARCHAR2(80);

  CURSOR c_person_id IS
    SELECT orig_system_id
    FROM   wf_roles
    WHERE  orig_system = 'PER'
    AND    name = l_TransferToName;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'start IsNotifTransferred');

  if (p_funmode IN ('TRANSFER', 'FORWARD')) then
    -----------------------------------------
    l_debug_info := 'Get the Notification ID';
    -----------------------------------------
    l_notificationID := wf_engine.context_nid;

    -----------------------------------------
    l_debug_info := 'Get information on the transfer to';
    -----------------------------------------
    -- wf_engine.context_text = new responder
    l_Transferee := wf_engine.context_text;

    -----------------------------------------
    l_debug_info := 'check for transferee received through email/web';
    -----------------------------------------
    IF (substrb(l_Transferee,1,6) = 'email:') THEN
        l_TransferToName := substrb(l_Transferee,7);
    ELSE
        -- response received through web or form
        l_TransferToName := l_Transferee;
    END IF;

    -----------------------------------------
    l_debug_info := 'Get the transferee id';
    -----------------------------------------
    OPEN c_person_id;
      FETCH c_person_id into l_TransferToID;
      IF c_person_id%NOTFOUND THEN
        p_result := wf_engine.eng_completed||':'||wf_engine.eng_null;
      	Wf_Core.Raise(wf_core.translate('NO_ROLE_FOUND'));
      	RETURN;
      ELSE
        IF l_TransferToID IS NULL THEN
          p_result := wf_engine.eng_completed||':'||wf_engine.eng_null;
          Wf_Core.Raise(wf_core.translate('PERSON_ID_NULL'));
          RETURN;
      	END IF;
      END IF;
      CLOSE c_person_id;

    ---------------------------------------------------------------------
    l_debug_info := 'set the transferring Preparer info to the Preparer';
    ---------------------------------------------------------------------
   WF_ENGINE.SetItemAttrText(p_item_type,
                             p_item_key,
                            'PREPARER_DISPLAY_NAME',
                              WF_ENGINE.GetItemAttrText(p_item_type,
                                                        p_item_key,
                                                        'PREPARER_DISPLAY_NAME'));

    ---------------------------------------------------------------------------
    l_debug_info := 'set the transferring Preparer Name to the Forwarded Info';
    ---------------------------------------------------------------------------
       WF_ENGINE.SetItemAttrText(p_item_type,
                             p_item_key,
                            'FORWARD_FROM_NAME',
                              WF_ENGINE.GetItemAttrText(p_item_type,
                                                        p_item_key,
                                                        'PREPARER_NAME'));
    -----------------------------------------------------------------------------------
    l_debug_info := 'set the transferring Preparer Display Name to the Forwarded Info';
    -----------------------------------------------------------------------------------

             WF_ENGINE.SetItemAttrText(p_item_type,
                             p_item_key,
                            'FORWARD_FROM_DISPLAY_NAME',
                              WF_ENGINE.GetItemAttrText(p_item_type,
                                                        p_item_key,
                                                        'PREPARER_DISPLAY_NAME'));

    ----------------------------------------------------------------------
    l_debug_info := 'set the current Preparer info to the Transferee';
    ---------------------------------------------------------------------
    SetPersonAs(l_TransferToID,
                p_item_type,
                p_item_key,
                'PREPARER');

    -----------------------------------------
    l_debug_info := 'set the current Preparer info in the Notification';
    -----------------------------------------
    WF_NOTIFICATION.SetAttrText(l_notificationID,
                                'PREPARER_DISPLAY_NAME',
                                WF_ENGINE.GetItemAttrText(p_item_type,
                                                          p_item_key,
                                                          'PREPARER_DISPLAY_NAME'));

   end if;


  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'end IsNotifTransferred');

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'IsNotifTransferred',
                     p_item_type, p_item_key, to_char(0), l_debug_info);
    RAISE;

END IsNotifTransferred;


PROCEDURE SetPersonAs(p_preparer_id 	  IN NUMBER,
                      p_item_type	      IN VARCHAR2,
		              p_item_key	      IN VARCHAR2,
		              p_preparer_target	  IN VARCHAR2)
IS

-- Function Name: SetPersonAs
-- Author:        Geetha Gurram
-- Purpose:       Set Preparer information Attributes
--
-- Input:         p_preparer_id
--                p_itemtype
--                p_itemkey
--                p_preparer_targe
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs

  l_preparer_name		     VARCHAR2(30);
  l_preparer_display_name	 VARCHAR2(150);
  l_debug_info			     VARCHAR2(200);
  l_preparer_org_id          NUMBER;

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'start SetPersonAs');

  ------------------------------------------------------------
  l_debug_info := 'Retrieve Preparer_Name Info for Preparer_Id';
  ------------------------------------------------------------
  WF_DIRECTORY.GetUserName('PER',
			   p_preparer_id,
			   l_preparer_name,
			   l_preparer_display_name);

  IF (p_preparer_target = 'PREPARER') THEN

    WF_ENGINE.SetItemAttrNumber(p_item_type,
			      p_item_key,
			      'PREPARER_EMPL_ID',
			      p_preparer_id);

    --------------------------------------------------------
    l_debug_info := 'Set Preparer_Name Info Item Attribute';
    --------------------------------------------------------
    WF_ENGINE.SetItemAttrText(p_item_type,
			                  p_item_key,
			                  'PREPARER_NAME',
			                  l_preparer_name);

    ---------------------------------------------------------------
    l_debug_info := 'Set Preparer_Display_Name Info Item Attribute';
    ---------------------------------------------------------------
    WF_ENGINE.SetItemAttrText(p_item_type,
			                  p_item_key,
			                  'PREPARER_DISPLAY_NAME',
			                   l_preparer_display_name);

    --------------------------------------------------------
    l_debug_info := 'Get Preperer Org Info Item Attribute';
    --------------------------------------------------------
    if (AP_WEB_DB_HR_INT_PKG.GetEmpOrgId(p_preparer_id,l_preparer_org_id) = TRUE ) then

    --------------------------------------------------------
    l_debug_info := 'Set Preperer Org Info Item Attribute';
    --------------------------------------------------------
      WF_ENGINE.SetItemAttrNumber(p_item_type,
			                      p_item_key,
			                      'PREPARER_ORG_ID',
			                      l_preparer_org_id);
     end if;

ELSE

    --------------------------------------------------------
    l_debug_info := 'Set Supervisor_ID Info Item Attribute';
    --------------------------------------------------------
    WF_ENGINE.SetItemAttrNumber(p_item_type,
			                    p_item_key,
			                    'PREPARER_EMPL_ID',
			                     p_preparer_id);

    --------------------------------------------------------
    l_debug_info := 'Set Approver_Name Info Item Attribute';
    --------------------------------------------------------
    WF_ENGINE.SetItemAttrText(p_item_type,
			      p_item_key,
			      'PREPARER_NAME',
			      l_preparer_name);

    ----------------------------------------------------------------
    l_debug_info := 'Set Approver_Display_Name Info Item Attribute';
    ----------------------------------------------------------------
    WF_ENGINE.SetItemAttrText(p_item_type,
			      p_item_key,
			      'PREPARER_DISPLAY_NAME',
			      l_preparer_display_name);



  END IF;

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'end SetPersonAs');

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'SetPersonAs',
                     p_item_type, p_item_key, null, l_debug_info);
    raise;
END SetPersonAs;

PROCEDURE CheckAPApproved(itemtype  in varchar2,
                          itemkey   in varchar2,
                          actid     in number,
                          funcmode  in varchar2,
                          resultout in out NOCOPY varchar2)
IS

-- Function Name: CheckAPApproved
-- Author:        Geetha Gurram
-- Purpose:       Check if the expense report submitted by the preparer is AP approved
--
-- Input:         itemtype
--                itemkey
--                actid
--                funcmode
--
-- Output:        resultout
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs

  l_ap_approved_status               VARCHAR2(50);
  l_debug_info                       VARCHAR2(2000);
  l_inact_employee_id                NUMBER;
  l_credit_card_program_id           NUMBER;
  l_ap_unapprove_exsists             NUMBER := 0;

  Cursor ap_unappr_exists_cur(p_credit_card_program_id in number,
                              p_inact_employee_id      in number,
                              p_itemkey                in varchar2)
  IS
        select erh.source
        from  ap_expense_report_headers   erh,
              ap_credit_card_trxns        cct,
              ap_cards_all 	              ac
        where ac.card_program_id = p_credit_card_program_id
          and cct.validate_code  = 'Y'
          and cct.inactive_emp_wf_item_key  is not null
          and cct.inactive_emp_wf_item_key  = p_itemkey
          and nvl(cct.category, 'BUSINESS') not in ( 'DISPUTED', 'DEACTIVATED')
          and ac.card_program_id = cct.card_program_id
          and ac.card_id     = cct.card_id
          and cct.report_header_id = erh.report_header_id
          and ac.employee_id = p_inact_employee_id;

BEGIN

 AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'start CheckAPApproved');


 IF (funcmode = 'RUN') THEN


 -------------------------------------------------------------------
    l_debug_info := 'Retrieve Inactive Employee ID Item Attributes';
 -------------------------------------------------------------------

    l_inact_employee_id := WF_ENGINE.GetItemAttrNumber(itemtype,
					                                   itemkey,
					                                   'INACT_EMPLOYEE_ID');

    -------------------------------------------------------------------
    l_debug_info := 'Retrieve Credit Card Program ID Item Attributes';
    -------------------------------------------------------------------

    l_credit_card_program_id := WF_ENGINE.GetItemAttrNumber(itemtype,
					                                        itemkey,
					                                        'CARD_PROG_ID');


  ----------------------------------------------------------
  l_debug_info := 'Is Unapproved CC exists ';
  ----------------------------------------------------------

   open ap_unappr_exists_cur(l_credit_card_program_id,
                             l_inact_employee_id,
                             itemkey);
    Loop
      fetch ap_unappr_exists_cur into l_ap_approved_status;
      exit when ap_unappr_exists_cur%notfound;

        if l_ap_approved_status NOT IN ( 'CREDIT CARD', 'Both Pay') then
           l_ap_unapprove_exsists := l_ap_unapprove_exsists + 1;
        end if;

    end loop;
    close ap_unappr_exists_cur;

  IF l_ap_unapprove_exsists  > 0 THEN
     resultout := 'COMPLETE:Y';
  ELSE
     resultout := 'COMPLETE:N';
  END IF;

 ELSIF (funcmode = 'CANCEL') THEN

      resultout := 'COMPLETE';

 END IF;

AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'end CheckAPApproved');

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'CheckAPApproved',
                     itemtype, itemkey, to_char(actid), l_debug_info);
    raise;

END CheckAPApproved;

FUNCTION GetUserIdForEmp(
	    p_emp_user_name		IN	VARCHAR2,
	    p_user_id	        OUT NOCOPY	NUMBER
) RETURN BOOLEAN

IS
-- Function Name: GetUserIdForEmp
-- Author:        Geetha Gurram
-- Purpose:       Returns userid for the username
--
-- Input:         p_emp_user_name
--
-- Output:        p_user_id
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs

 l_debug_info              VARCHAR2(200);

BEGIN

       SELECT	user_id
        INTO    p_user_id
		FROM	fnd_user
		WHERE	user_name  = p_emp_user_name;


	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
         Wf_Core.Context('AP_WEB_EXPENSE_WF', 'GetUserIdForEmp',
                      to_char(0), to_char(0), to_char(0), l_debug_info || FND_MESSAGE.GET);
		RETURN FALSE;

	WHEN OTHERS THEN

        Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'GetUserIdForEmp',
                    to_char(0), to_char(0), to_char(0), l_debug_info || FND_MESSAGE.GET);
    	APP_EXCEPTION.RAISE_EXCEPTION;
    	RETURN FALSE;

END GetUserIdForEmp;

PROCEDURE ClearItemkeyCCTrx(itemtype  in varchar2,
                            itemkey   in varchar2,
                            actid     in number,
                            funcmode  in varchar2,
                            resultout in out NOCOPY varchar2)
IS

-- Function Name: ClearItemkeyCCTrx
-- Author:        Geetha Gurram
-- Purpose:       Clear all the WF item key for all the Credit Card Transactions which selected when the workflow
--                got initiated
--
-- Input:         itemtype
--                itemkey
--                actid
--                funcmode
--
-- Output:        resultout
--
-- Assumptions:
--
-- Notes:         Inactive Employee Workflow Processs

  l_debug_info                       VARCHAR2(2000);
  l_inact_employee_id                NUMBER;
  l_credit_card_program_id           NUMBER;
  l_trx_id                           NUMBER;
  l_expense_status_code              VARCHAR2(50);

  Cursor cc_trx_cur(p_credit_card_program_id in number,
                    p_inact_employee_id      in number,
                    p_itemkey                in varchar2)
  IS
        select cct.trx_id
        from  ap_credit_card_trxns        cct,
              ap_cards_all 	              ac
        where ac.card_program_id = p_credit_card_program_id
          and cct.validate_code  = 'Y'
          and cct.inactive_emp_wf_item_key  is not null
          and cct.inactive_emp_wf_item_key  = p_itemkey
          and nvl(cct.category, 'BUSINESS') not in ( 'DISPUTED', 'DEACTIVATED')
          and ac.card_program_id = cct.card_program_id
          and ac.card_id     = cct.card_id
          and ac.employee_id = p_inact_employee_id;

BEGIN

 AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'start ClearItemkeyCCTrx');


 IF (funcmode = 'RUN') THEN


 -------------------------------------------------------------------
    l_debug_info := 'Retrieve Inactive Employee ID Item Attributes';
 -------------------------------------------------------------------

    l_inact_employee_id := WF_ENGINE.GetItemAttrNumber(itemtype,
					                                   itemkey,
					                                   'INACT_EMPLOYEE_ID');

    -------------------------------------------------------------------
    l_debug_info := 'Retrieve Credit Card Program ID Item Attributes';
    -------------------------------------------------------------------

    l_credit_card_program_id := WF_ENGINE.GetItemAttrNumber(itemtype,
					                                        itemkey,
					                                        'CARD_PROG_ID');


  ----------------------------------------------------------
  l_debug_info := 'Is Unapproved CC exists ';
  ----------------------------------------------------------

   open cc_trx_cur(l_credit_card_program_id,
                   l_inact_employee_id,
                   itemkey);
    Loop
      fetch cc_trx_cur into l_trx_id;
      exit when cc_trx_cur%notfound;

     --   if l_expense_status_code in( 'WITHDRAWN', 'RETURNED', 'REJECTED', 'ERROR') then
           update ap_credit_card_trxns
           set inactive_emp_wf_item_key = NULL
           where trx_id = l_trx_id;
      --  end if;

    end loop;

    commit;
    close cc_trx_cur;

    resultout := 'COMPLETE:Y';


 ELSIF (funcmode = 'CANCEL') THEN

      resultout := 'COMPLETE';

 END IF;

AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_INACTIVE_EMP_WF_PKG', 'end ClearItemkeyCCTrx');

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('AP_WEB_INACTIVE_EMP_WF_PKG', 'ClearItemkeyCCTrx',
                     itemtype, itemkey, to_char(actid), l_debug_info);
    raise;

END ClearItemkeyCCTrx;

END AP_WEB_INACTIVE_EMP_WF_PKG;

/
