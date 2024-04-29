--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_EXPRPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_EXPRPT_PKG" AS
/* $Header: apwdberb.pls 120.54.12010000.5 2010/04/05 12:40:01 meesubra ship $ */

----------------------------------------------------------------------------------------
-- Name: GetEmployeeIdFromBothPayParent
-- Desc: get employee_id from both pay parent report
-- Input:  p_bothpay_parent_id - parent report header id
-- Output: p_employee_id - employee_id from both pay parent report
---------------------------------------------------------------------------------------
PROCEDURE GetEmployeeIdFromBothPayParent(
                          p_bothpay_parent_id         IN      NUMBER,
                          p_employee_id               OUT NOCOPY     NUMBER)
IS
BEGIN
    SELECT employee_id
    INTO   p_employee_id
    FROM   AP_EXPENSE_REPORT_HEADERS
    WHERE report_header_id = p_bothpay_parent_id;

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetEmployeeIdFromBothPayParent');
    APP_EXCEPTION.RAISE_EXCEPTION;
END GetEmployeeIdFromBothPayParent;



----------------------------------------------------------------------
FUNCTION GetRestorableReportsCursor(P_WebUserID IN  AK_WEB_USER_SEC_ATTR_VALUES.web_user_id%TYPE,
				    p_cursor    OUT NOCOPY RestorableReportsCursor)
RETURN BOOLEAN IS
----------------------------------------------------------------------
BEGIN
  -- Returns reports which can be modified by the web user
  -- 3176205: hr_empcur includes all workers.
  -- Note: Instead of PER_WORKFORCE_X, PER_PEOPLE_X is used for the
  --       following reasons:
  --       o Query is driven off AP_EXPENSE_REPORT_HEADERS
  --       o Better performance using PER_PEOPLE_X
  --       o PER_WORKFORCE_X can return more than one row for a person
  --       o The only column selected from PER_PEOPLE_X is full_name
OPEN p_cursor FOR
    SELECT ap_erh.REPORT_HEADER_ID,
           ap_erh.INVOICE_NUM,
           hr_empcur.FULL_NAME,
           ap_erh.WEEK_END_DATE,
           ap_erh.DEFAULT_CURRENCY_CODE,
           ap_erh.DESCRIPTION,
           ap_erh.TOTAL,
           fndl.MEANING
    FROM   AP_EXPENSE_REPORT_HEADERS ap_erh,
           PER_PEOPLE_X hr_empcur,
           FND_LOOKUPS fndl
    WHERE (ap_erh.EMPLOYEE_ID IN
            (SELECT NUMBER_VALUE
              FROM AK_WEB_USER_SEC_ATTR_VALUES
              WHERE ATTRIBUTE_CODE = C_UserAttributeCode AND
                    WEB_USER_ID = P_WebUserID))
          AND ap_erh.SOURCE = C_RestorableReportSource
          AND ap_erh.WORKFLOW_APPROVED_FLAG IN
                   (C_WORKFLOW_APPROVED_SAVED, C_WORKFLOW_APPROVED_REJECTED,
                       --ER 1552747 - withdraw expense report
                    C_WORKFLOW_APPROVED_RETURNED, C_WORKFLOW_APPROVED_WITHDRAW)
          AND ap_erh.EMPLOYEE_ID = hr_empcur.PERSON_ID
          AND fndl.LOOKUP_TYPE = 'YES_NO'
          AND DECODE(WORKFLOW_APPROVED_FLAG, C_WORKFLOW_APPROVED_REJECTED, 'Y', 'N') = fndl.LOOKUP_CODE
    ORDER BY hr_empcur.FULL_NAME, ap_erh.REPORT_HEADER_ID;

  return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetRestorableReportsCursor');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetRestorableReportsCursor;


-------------------------------------------------------------------
FUNCTION GetExpWorkflowInfo(
		P_ReportID           	IN  expHdr_headerID,
		P_WorkflowRec	 OUT NOCOPY ExpWorkflowRec)
RETURN BOOLEAN IS
-------------------------------------------------------------------
l_debug_info 		VARCHAR2(1000);
l_curr_calling_sequence VARCHAR2(100) := 'GetExpWorkflowInfo';
BEGIN
      l_debug_info := 'Retrieve Invoice Number and Workflow Approved Flag for expense report';
      SELECT INVOICE_NUM,
	     WORKFLOW_APPROVED_FLAG
      INTO   P_WorkflowRec.doc_num,
	     P_WorkflowRec.workflow_flag
      FROM   AP_EXPENSE_REPORT_HEADERS
      WHERE  REPORT_HEADER_ID = P_ReportID;

      return TRUE;
EXCEPTION
  WHEN TOO_MANY_ROWS OR NO_DATA_FOUND THEN
        return FALSE;
  WHEN OTHERS THEN
        AP_WEB_DB_UTIL_PKG.RaiseException(l_curr_calling_sequence, l_debug_info);
    	APP_EXCEPTION.RAISE_EXCEPTION;
        return FALSE;

END GetExpWorkflowInfo;


-------------------------------------------------------------------
FUNCTION GetReportInfo(
	p_expenseReportId IN  expHdr_headerID,
	p_exp_info_rec	  OUT NOCOPY ExpInfoRec
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  SELECT employee_id,
	 default_currency_code,
	 invoice_num,
	 total,
	 payment_currency_code,
	 week_end_date
  INTO   p_exp_info_rec.emp_id,
 	 p_exp_info_rec.default_curr_code,
	 p_exp_info_rec.doc_num,
	 p_exp_info_rec.total,
	 p_exp_info_rec.payment_curr_code,
	 p_exp_info_rec.week_end_date
  FROM   ap_expense_report_headers
  WHERE  report_header_id = p_expenseReportId;

  return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetReportInfo');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;

END GetReportInfo;

-------------------------------------------------------------------
FUNCTION GetOverrideApproverID(p_report_header_id IN expHdr_headerID,
			       p_id		  OUT NOCOPY expHdr_overrideApprID)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
    SELECT override_approver_id
    INTO   p_id
    FROM   ap_expense_report_headers
    WHERE  report_header_id = p_report_header_id;

    return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetOverrideApproverID');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;

END GetOverrideApproverID;


--------------------------------------------------------------------------------
FUNCTION GetOrgIdByReportHeaderId(
	p_header_id	IN	expHdr_headerID,
	p_org_id OUT NOCOPY 	expHdr_orgID) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
	SELECT	org_id
	INTO	p_org_id
	FROM	ap_expense_report_headers_all
	WHERE	report_header_id = p_header_id;

	return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetOrgIdByReportHeaderId');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetOrgIdByReportHeaderId;

-------------------------------------------------------------------
FUNCTION GetReportHeaderAttributes(p_report_header_id   IN expHdr_headerID,
  p_default_comb_id OUT NOCOPY HR_EMPLOYEES_CURRENT_V.default_code_combination_id%TYPE,
  p_emp_id	 OUT NOCOPY expHdr_employeeID,
  p_flex_concat	 OUT NOCOPY expHdr_flexConcat,
  p_attr_category OUT NOCOPY expHdr_attrCategory,
  p_attr1	 OUT NOCOPY expHdr_attr1,
  p_attr2	 OUT NOCOPY expHdr_attr2,
  p_attr3	 OUT NOCOPY expHdr_attr3,
  p_attr4	 OUT NOCOPY expHdr_attr4,
  p_attr5	 OUT NOCOPY expHdr_attr5,
  p_attr6	 OUT NOCOPY expHdr_attr6,
  p_attr7	 OUT NOCOPY expHdr_attr7,
  p_attr8	 OUT NOCOPY expHdr_attr8,
  p_attr9	 OUT NOCOPY expHdr_attr9,
  p_attr10	 OUT NOCOPY expHdr_attr10,
  p_attr11	 OUT NOCOPY expHdr_attr11,
  p_attr12	 OUT NOCOPY expHdr_attr12,
  p_attr13	 OUT NOCOPY expHdr_attr13,
  p_attr14	 OUT NOCOPY expHdr_attr14,
  p_attr15	 OUT NOCOPY expHdr_attr15)
RETURN BOOLEAN IS
-------------------------------------------------------------------
  l_default_emp_ccid       expHdr_employeeCCID;
BEGIN
    -- 3176205: This query includes all workers except for terminated
    -- contingent workers and terminated employees who are active contingent
    -- workers.
    -- Note: PER_PEOPLE_X would make more sense than PER_WORKFORCE_X
    --       but we cannot use that because default_code_combination_id
    --       is selected.
    --       Therefore we need to limit the query so that at most one
    --       row will be returned.
    SELECT exp.employee_id,
           exp.flex_concatenated,
           exp.attribute_category,
           exp.attribute1,
           exp.attribute2,
           exp.attribute3,
           exp.attribute4,
           exp.attribute5,
           exp.attribute6,
           exp.attribute7,
           exp.attribute8,
           exp.attribute9,
           exp.attribute10,
           exp.attribute11,
           exp.attribute12,
           exp.attribute13,
           exp.attribute14,
           exp.attribute15
    INTO   p_emp_id,
	   p_flex_concat,
	   p_attr_category,
	   p_attr1,
	   p_attr2,
	   p_attr3,
	   p_attr4,
	   p_attr5,
	   p_attr6,
	   p_attr7,
	   p_attr8,
	   p_attr9,
	   p_attr10,
	   p_attr11,
	   p_attr12,
	   p_attr13,
	   p_attr14,
	   p_attr15
    FROM   ap_expense_report_headers exp
    WHERE  exp.report_header_id = p_report_header_id;

    IF GetDefaultEmpCCID(p_emp_id, l_default_emp_ccid) THEN
      p_default_comb_id := l_default_emp_ccid;
    END IF;

    return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetReportHeaderAttributes');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetReportHeaderAttributes;


-------------------------------------------------------------------
FUNCTION GetReportHeaderInfo(P_ReportID		IN  expHdr_headerID,
			      P_ExpHdrRec OUT NOCOPY ExpHeaderRec)
RETURN BOOLEAN IS
-------------------------------------------------------------------

  l_debugInfo    	     VARCHAR2(240);
  l_DCDName                  VARCHAR2(240);
  l_HeaderText               VARCHAR2(240);
  l_MessageText              VARCHAR2(240);
  l_LinkText                 VARCHAR2(240);
BEGIN

 -------------------------------------------------------
  l_debugInfo := 'GetReportHeaderInfo';
 -------------------------------------------------------
    SELECT TO_CHAR(expense_report_id),
	   TO_CHAR(week_end_date),
           description,
	   default_currency_code,
           flex_concatenated,
	   TO_CHAR(override_approver_id),
	   override_approver_name,
	   employee_id,
           TO_CHAR(last_update_date,AP_WEB_DB_UTIL_PKG.C_DetailedDateFormat)
    INTO   P_ExpHdrRec.template_id,
	   P_ExpHdrRec.last_receipt_date,
	   P_ExpHdrRec.description,
	   P_ExpHdrRec.default_curr_code,
	   P_ExpHdrRec.flex_concat,
	   P_ExpHdrRec.override_appr_id,
	   P_ExpHdrRec.override_appr_name,
	   P_ExpHdrRec.emp_id,
	   P_ExpHdrRec.last_update_date
    FROM   AP_EXPENSE_REPORT_HEADERS
    WHERE  REPORT_HEADER_ID = P_ReportID
           AND SOURCE = C_RestorableReportSource;

    return TRUE;

  EXCEPTION
  WHEN TOO_MANY_ROWS OR NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetReportHeaderInfo');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetReportHeaderInfo;


-------------------------------------------------------------------
FUNCTION GetExpReportExchCurrInfo(p_report_id           IN  expHdr_headerID,
                                p_exch_rate             OUT NOCOPY expHdr_defaultExchRate,
                                p_reimb_precision       OUT NOCOPY FND_CURRENCIES_VL.PRECISION%TYPE
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
    SELECT nvl(default_exchange_rate,1),
           nvl(precision,0)
    INTO   p_exch_rate,
           p_reimb_precision
    FROM   fnd_currencies_vl,
           ap_expense_report_headers
    WHERE  report_header_id = p_report_id
    AND    currency_code = default_currency_code;

    return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetExpReportExchCurrInfo');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetExpReportExchCurrInfo;


-------------------------------------------------------------------
FUNCTION GetNextExpReportID(p_new_report_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
-------------------------------------------------------------------
l_debug_info		VARCHAR2(1000);
BEGIN
    l_debug_info := 'Getting the next report header id';

    SELECT ap_expense_report_headers_s.nextval
    INTO   p_new_report_id
    FROM   sys.dual;

    return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNextExpReportID', l_debug_info);
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetNextExpReportID;

-------------------------------------------------------------------
FUNCTION GetNextRptHdrID(p_new_report_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
-------------------------------------------------------------------
l_debug_info		VARCHAR2(1000);
BEGIN
    l_debug_info := 'Getting the next report header id';

    SELECT ap_expense_report_headers_s.nextval
    INTO   p_new_report_id
    FROM   dual;

    return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNextRptHdrID', l_debug_info);
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetNextRptHdrID;

-------------------------------------------------------------------
FUNCTION GetAccountingInfo(
        p_report_header_id              IN  expHdr_headerID,
        p_sys_apply_advances_default  OUT NOCOPY apSetUp_applyAdvDefault,
        p_sys_allow_awt_flag     OUT NOCOPY apSetUp_allowAWTFlag,
        p_sys_default_xrate_type  OUT NOCOPY apSetUp_defaultExchRateType,
        p_sys_make_rate_mandatory  OUT NOCOPY apSetUp_makeMandatoryFlag,
        p_exp_check_address_flag  OUT NOCOPY finSysParams_checkAddrFlag,
        p_default_currency_code  OUT NOCOPY expHdr_defaultCurrCode,
        p_week_end_date          OUT NOCOPY expHdr_weekEndDate,
        p_flex_concatenated      OUT NOCOPY expHdr_flexConcat,
        p_employee_id            OUT NOCOPY expHdr_employeeID)
RETURN BOOLEAN IS
-------------------------------------------------------------------

/*Bug 2699333:Removed FIN table since expense_check_address_flag can
	      be got from hr_employees_current_v view and there is no
	      join with FIN table.

	      Added GS.set_of_books_id=nvl(HR.set_of_books_id,
				GS.set_of_books_id)
	      to avoid Merge join cartesians.
*/
l_emp_set_of_books_id   gl_sets_of_books.set_of_books_id%type;
l_chart_of_accounts_id  gl_sets_of_books.chart_of_accounts_id%type;
l_exp_check_address_flag  per_employees_x.expense_check_address_flag%type;
l_fin_exp_check_address_flag  financials_system_parameters.expense_check_address_flag%type;
l_default_exch_rate_type      apSetUp_defaultExchRateType;
BEGIN
   -- 3176205: This query includes all workers except for terminated
   -- contingent workers and terminated employees who are active contingent
   -- workers.
   AP_WEB_DB_AP_INT_PKG.GetDefaultExchange(l_default_exch_rate_type);
   SELECT nvl(S.apply_advances_default, 'N'),
         nvl(S.allow_awt_flag, 'N'),
         decode(S.base_currency_code, RH.default_currency_code, null,
                l_default_exch_rate_type),
         nvl(S.make_rate_mandatory_flag, 'N'),
	 RH.default_currency_code,
 	 week_end_date,
         flex_concatenated,
         RH.employee_id
  INTO   p_sys_apply_advances_default,
         p_sys_allow_awt_flag,
         p_sys_default_xrate_type,
         p_sys_make_rate_mandatory,
 	 p_default_currency_code,
	 p_week_end_date,
	 p_flex_concatenated,
         p_employee_id
  FROM   ap_system_parameters S,
         ap_expense_report_headers RH
  WHERE  RH.report_header_id = p_report_header_id;

  SELECT expense_check_address_flag
  INTO   l_exp_check_address_flag
  FROM (
    SELECT emp.expense_check_address_flag
    FROM  per_employees_x emp
    WHERE  emp.employee_id = p_employee_id
    AND NOT AP_WEB_DB_HR_INT_PKG.ispersoncwk(emp.employee_id)='Y'
      UNION ALL
    SELECT emp.expense_check_address_flag
    FROM  per_cont_workers_current_x emp
    WHERE  emp.person_id = p_employee_id
  );

  SELECT expense_check_address_flag
  INTO l_fin_exp_check_address_flag
  FROM financials_system_parameters;

  p_exp_check_address_flag := nvl(l_exp_check_address_flag, l_fin_exp_check_address_flag);

  return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetAccountingInfo');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetAccountingInfo;


-------------------------------------------------------------------
FUNCTION GetExpReportInfo(
	p_report_header_id 	IN  expHdr_headerID,
	p_description 	 OUT NOCOPY VARCHAR2,
	p_ccard_amt 	 OUT NOCOPY expHdr_amtDueCCardCompany,
	p_total 	 OUT NOCOPY expHdr_total
) RETURN BOOLEAN IS
-------------------------------------------------------------------
l_exp_rpt_purpose VARCHAR2(240);
l_emp_masked_cc_number VARCHAR2(320);
l_emp_full_name   VARCHAR2(240);
l_description     VARCHAR2(1000); -- bug3303390
BEGIN

         SELECT DISTINCT icc.masked_cc_number || '/' || emp.full_name,
		erh.description,
                emp.full_name,
    		erh.amt_due_ccard_company,
    		erh.total
    	 INTO   l_emp_masked_cc_number,
		l_exp_rpt_purpose,
                l_emp_full_name,
		p_ccard_amt,
		p_total
       	 FROM   ap_expense_report_headers erh,
       		ap_credit_card_trxns cc,
       		/*  hr_employees emp Bug 3006221 */
       		per_people_f emp,
        	ap_cards aca,
       		iby_creditcard icc
       	 WHERE  cc.card_id = aca.card_id
       	 AND    aca.card_reference_id = icc.instrid
         AND    erh.report_header_id = p_report_header_id
       	 AND    cc.report_header_id = p_report_header_id
       	 AND    erh.employee_id = emp.person_id
	 AND    TRUNC(sysdate) BETWEEN emp.effective_start_date
                                   AND emp.effective_end_date /* Bug 3111161 */
         AND    cc.category='BUSINESS';

         -- Bug 2786500:By default message will have 'EMP_CARD_NUM - EXP_RPT_PURPOSE'
         -- Message can be modified to have one or combination of the following
         -- EMP_CARD_NUM,  EXP_RPT_PURPOSE, EMP_FULL_NAME
         FND_MESSAGE.SET_NAME('SQLAP','OIE_INVOICE_DESC');
         l_description := FND_MESSAGE.GET;
         l_description := replace(l_description,'EMP_FULL_NAME',l_emp_full_name);
	 l_description := replace(l_description,'EMP_CARD_NUM',l_emp_masked_cc_number);
	 l_description := replace(l_description,'EXP_RPT_PURPOSE',l_exp_rpt_purpose);
	 p_description := substrb(l_description,1,240); --2227571
         p_description := rtrim(p_description);  --2227571
         IF substr(p_description, -1) = '-' THEN
            p_description := substr(p_description,1, length(p_description) -2);
         END IF;

	 return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetExpReportInfo');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetExpReportInfo;


-------------------------------------------------------------------
FUNCTION ExpReportShortpaid(P_ReportID		IN  expHdr_headerID,
			    P_Shortpaid	 OUT NOCOPY BOOLEAN)
RETURN BOOLEAN IS
-------------------------------------------------------------------
l_shortpay_id		expHdr_shortpayParentID := NULL;
BEGIN
  SELECT shortpay_parent_id
  INTO   l_shortpay_id
  FROM   ap_expense_report_headers
  WHERE  report_header_id = P_ReportID;

  IF (l_shortpay_id IS NULL) THEN
     P_Shortpaid := FALSE;
  ELSE
     P_Shortpaid := TRUE;
  END IF;

  return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('ExpReportShortpaid');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END ExpReportShortpaid;

-------------------------------------------------------------------
FUNCTION InsertReportHeader(p_xpense_rec		IN XpenseInfoRec,
			    p_ExpReportHeaderInfo	IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec
) RETURN BOOLEAN IS
-------------------------------------------------------------------
l_curr_calling_sequence VARCHAR2(100) := 'AddReportHeader';
l_debug_info VARCHAR2(100);
BEGIN

     l_debug_info := 'Add Report Header';

     INSERT INTO AP_EXPENSE_REPORT_HEADERS
     (report_header_id,
      employee_id,
      override_approver_id,
      override_approver_name,
      week_end_date,
      vouchno,
      total,
      invoice_num,
      expense_report_id,
      set_of_books_id,
      source,
      description,
      flex_concatenated,
      default_currency_code,
      payment_currency_code, --1396360
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      workflow_approved_flag,
      amt_due_employee,
      amt_due_ccard_company,
      org_id)
    VALUES
      (p_xpense_rec.report_header_id,
       p_ExpReportHeaderInfo.employee_id,
       p_xpense_rec.approver_id,
       p_ExpReportHeaderInfo.override_approver_name,
       p_xpense_rec.week_end_date,
       p_xpense_rec.vouchno,
       p_xpense_rec.total,
       p_xpense_rec.document_number,
       to_number(p_ExpReportHeaderInfo.template_id),
       p_xpense_rec.set_of_books_id,
       p_xpense_rec.source,
       AP_WEB_UTILITIES_PKG.RtrimMultiByteSpaces(p_ExpReportHeaderInfo.purpose),
       p_ExpReportHeaderInfo.cost_center,
       p_ExpReportHeaderInfo.reimbursement_currency_code,
       p_ExpReportHeaderInfo.reimbursement_currency_code,
       sysdate,
       icx_sec.getID(icx_sec.PV_USER_ID),		-- Bug 1733370
       sysdate,
       icx_sec.getID(icx_sec.PV_USER_ID),		-- Bug 1733370
       p_xpense_rec.workflow_flag,
       p_ExpReportHeaderInfo.amt_due_employee,
       p_ExpReportHeaderInfo.amt_due_ccCompany,
       nvl( p_xpense_rec.org_id, mo_global.get_current_org_id() ) );

	return TRUE;
EXCEPTION -- Block which encapsulates the delete and insert code
  WHEN TOO_MANY_ROWS OR NO_DATA_FOUND THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('InsertReportHeader',l_debug_info,
				  'AP_WEB_SAVESUB_DELETE_FAILED',
                    'V_ReportHeaderID = ' || p_xpense_rec.report_header_id
                     ||', Invoice Num = '|| p_xpense_rec.document_number);
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
  WHEN OTHERS THEN
      IF (SQLCODE = -00054) THEN
        -- Tried to obtain lock when deleting on an already locked row
        -- Get invoice prefix profile option, and trim if it is too long
        -- Get message stating delete failed
    	AP_WEB_DB_UTIL_PKG.RaiseException('InsertReportHeader',l_debug_info,
				'AP_WEB_SAVESUB_LOCK_FAILED',
                    		'V_ReportHeaderID = ' || p_xpense_rec.report_header_id
				);
    	APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      return FALSE;
END InsertReportHeader; -- Block which encapsulates the delete and insert code

-------------------------------------------------------------------
FUNCTION InsertReportHeaderLikeExisting(p_orig_report_header_id 	IN expHdr_headerID,
					 p_xpense_rec 			IN XpenseInfoRec
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
           INSERT INTO ap_expense_report_headers
     	      (report_header_id,
     	       employee_id,
     	       week_end_date,
     	       creation_date,
     	       created_by,
     	       last_update_date,
     	       last_updated_by,
      	       vouchno,
      	       total,
      	       vendor_id,
      	       vendor_site_id,
      	       expense_check_address_flag,
      	       reference_1,
      	       reference_2,
      	       invoice_num,
      	       expense_report_id,
      	       accts_pay_code_combination_id,
      	       set_of_books_id,
      	       source,
      	       expense_status_code,
      	       purgeable_flag,
      	       accounting_date,
      	       maximum_amount_to_apply,
      	       advance_invoice_to_apply,
      	       apply_advances_default,
      	       employee_ccid,
      	       reject_code,
      	       hold_lookup_code,
      	       attribute_category,
      	       attribute1,
      	       attribute2,
      	       attribute3,
      	       attribute4,
      	       attribute5,
      	       attribute6,
      	       attribute7,
      	       attribute8,
      	       attribute9,
      	       attribute10,
      	       attribute11,
      	       attribute12,
      	       attribute13,
      	       attribute14,
      	       attribute15,
      	       default_currency_code,
      	       default_exchange_rate_type,
      	       default_exchange_rate,
      	       default_exchange_date,
      	       last_update_login,
      	       voucher_num,
      	       doc_category_code,
      	       awt_group_id,
      	       org_id,
      	       workflow_approved_flag,
      	       flex_concatenated,
	       global_attribute_category,
	       global_attribute1,
	       global_attribute2,
	       global_attribute3,
	       global_attribute4,
	       global_attribute5,
	       global_attribute6,
	       global_attribute7,
	       global_attribute8,
	       global_attribute9,
	       global_attribute10,
	       global_attribute11,
	       global_attribute12,
	       global_attribute13,
	       global_attribute14,
	       global_attribute15,
	       global_attribute16,
	       global_attribute17,
	       global_attribute18,
	       global_attribute19,
	       global_attribute20,
      	       override_approver_id,
	       payment_cross_rate_type,
	       payment_cross_rate_date,
	       payment_cross_rate,
	       payment_currency_code,
	       core_wf_status_flag,
     	       amt_due_employee,
      	       amt_due_ccard_company,
      	       description,
      	       bothpay_parent_id,
               shortpay_parent_id,
      	       paid_on_behalf_employee_id,
               report_submitted_date, -- 2646985
               receipts_received_date, -- jrautiai 3008468
               last_audited_by, -- jrautiai 2987037
               audit_code, -- jrautiai 3255738
               report_filing_number
      	       )
      	       SELECT p_xpense_rec.report_header_id,
                      erh.employee_id,   --2446559
		      week_end_date,
		      sysdate,
-- Bug 2473070	      NVL(icx_sec.getID(icx_sec.PV_USER_ID), erh.created_by),
		      NVL(p_xpense_rec.preparer_id, erh.created_by),
		      sysdate,
-- Bug 2473070	      NVL(icx_sec.getID(icx_sec.PV_USER_ID), erh.last_updated_by),
      		      NVL(p_xpense_rec.last_updated_by, erh.last_updated_by),
      		      p_xpense_rec.vouchno,
      		      decode(p_xpense_rec.total,-1,erh.amt_due_ccard_company, p_xpense_rec.total), --result of combining the apis
		      NVL(p_xpense_rec.vendor_id, erh.vendor_id),
      		      NVL(p_xpense_rec.vendor_site_id, erh.vendor_site_id),
      		      NVL(p_xpense_rec.expense_check_address_flag, erh.expense_check_address_flag),
		      reference_1,
		      reference_2,
		      p_xpense_rec.document_number, --invoice_num
		      expense_report_id,
		      NVL(p_xpense_rec.accts_pay_comb_id,erh.accts_pay_code_combination_id),
		      set_of_books_id,
		      NVL(p_xpense_rec.source,erh.source),
		      p_xpense_rec.expense_status_code,
		      purgeable_flag,
		      accounting_date,
		      '', -- Bug 3654956
		      '', -- 4001778 advance_invoice_to_apply,
		      '', -- 4001778 apply_advances_default,
		      employee_ccid,
		      reject_code,
		      hold_lookup_code,
		      attribute_category,
		      attribute1,
		      attribute2,
		      attribute3,
		      attribute4,
		      attribute5,
		      attribute6,
		      attribute7,
		      attribute8,
		      attribute9,
		      attribute10,
		      attribute11,
		      attribute12,
		      attribute13,
		      attribute14,
		      attribute15,
		      default_currency_code,
		      default_exchange_rate_type,
		      default_exchange_rate,
		      default_exchange_date,
		      NVL(p_xpense_rec.last_update_login, erh.last_update_login),
		      voucher_num,
		      doc_category_code,
		      awt_group_id,
		      NVL(p_xpense_rec.org_id, erh.org_id),
		      decode(p_xpense_rec.workflow_flag, NULL,erh.workflow_approved_flag, decode(p_xpense_rec.workflow_flag,'POLICY','M',null)),
		      flex_concatenated,
	              global_attribute_category,
		      global_attribute1,
		      global_attribute2,
		      global_attribute3,
		      global_attribute4,
		      global_attribute5,
		      global_attribute6,
		      global_attribute7,
		      global_attribute8,
		      global_attribute9,
		      global_attribute10,
		      global_attribute11,
		      global_attribute12,
		      global_attribute13,
		      global_attribute14,
		      global_attribute15,
		      global_attribute16,
		      global_attribute17,
		      global_attribute18,
		      global_attribute19,
		      global_attribute20,
      		      override_approver_id,
	       	      payment_cross_rate_type,
	       	      payment_cross_rate_date,
	       	      payment_cross_rate,
	       	      payment_currency_code,
	       	      core_wf_status_flag,
	       	      nvl(p_xpense_rec.amt_due_employee,0), --amt_due_employee
               	      decode(p_xpense_rec.amt_due_ccard, NULL, nvl(erh.amt_due_ccard_company,0), p_xpense_rec.amt_due_ccard), --amt_due_ccard_company
               	      NVL(p_xpense_rec.description,erh.description),  --description
               	      p_xpense_rec.bothpay_report_header_id, --bothpay_parent_id
                      NVL(p_xpense_rec.shortpay_parent_id, erh.shortpay_parent_id),
               	      decode(p_xpense_rec.behalf_employee_id, -1, erh.employee_id, erh.paid_on_behalf_employee_id), --paid_on_behalf_employee_id
                      report_submitted_date, -- 2646985
                      receipts_received_date, -- jrautiai 3008468
                      last_audited_by, -- jrautiai 2987037
                      audit_code, -- jrautiai 3255738
                      report_filing_number
      	       FROM   ap_expense_report_headers erh
      	       WHERE  report_header_id = p_orig_report_header_id;

	return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('InsertReportHeaderLikeExisting');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END InsertReportHeaderLikeExisting;

FUNCTION SetDefaultExchRateType(p_report_header_id	IN expHdr_headerID,
				p_xrate_type		IN expHdr_defaultXchRateType)
RETURN BOOLEAN IS
BEGIN
  UPDATE ap_expense_report_headers
  SET    default_exchange_rate_type = p_xrate_type
  WHERE  report_header_id = p_report_header_id;

  return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('SetDefaultExchRateType');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END SetDefaultExchRateType;

------------------------------------------------------------------
FUNCTION SetExpenseHeaderInfo(
		p_report_header_id		IN expHdr_headerID,
                p_exp_check_address_flag        IN expHdr_expCheckAddrFlag,
	       	p_source			IN expHdr_source,
	       	p_workflow_approve_flag		IN expHdr_wkflApprvdFlag,
	       	p_sys_apply_advances_default	IN expHdr_applyAdvDefault,
	       	p_available_prepays		IN NUMBER,
	       	p_sys_allow_awt_flag		IN AP_SYSTEM_PARAMETERS.allow_awt_flag%TYPE,
	       	p_ven_allow_awt_flag		IN AP_SUPPLIERS.allow_awt_flag%TYPE,
	       	p_ven_awt_group_id		IN expHdr_awtGroupID,
	       	p_sys_default_xrate_type	IN expHdr_defaultXchRateType,
	       	p_week_end_date			IN expHdr_defaultExchDate,
	       	p_default_exchange_rate		IN expHdr_defaultExchRate,
	       	p_employee_ccid			IN expHdr_employeeCCID
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  UPDATE ap_expense_report_headers RH
  SET    expense_check_address_flag = p_exp_check_address_flag,
         source = p_source,
         workflow_approved_flag = p_workflow_approve_flag,
	 apply_advances_default =  decode(apply_advances_default,'Y','Y',decode(p_sys_apply_advances_default, 'Y',
                     decode(sign(p_available_prepays), 1, 'Y', 'N'), 'N')),
         awt_group_id = decode(p_sys_allow_awt_flag, 'Y',
                          decode(p_ven_allow_awt_flag, 'Y', p_ven_awt_group_id,
                                 null), null),
         default_exchange_rate_type = p_sys_default_xrate_type,
         default_exchange_date = decode(p_sys_default_xrate_type, null, null,
					p_week_end_date),
         default_exchange_rate = p_default_exchange_rate,
         employee_ccid = p_employee_ccid
  WHERE  report_header_id = p_report_header_id;

  return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('SetExpenseHeaderInfo');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END SetExpenseHeaderInfo;


-------------------------------------------------------------------
FUNCTION SetAmtDuesAndTotal(
	p_report_header_id 	IN expHdr_headerID,
	p_amt_due_ccard_company IN expHdr_amtDueCCardCompany,
	p_amt_due_employee 	IN expHdr_amtDueEmployee,
	p_total 		IN expHdr_total
)  RETURN BOOLEAN IS
-------------------------------------------------------------------
l_max_amt_to_apply expHdr_maxAmountApplied := NULL;--Bug#6400678
l_amt_due_employee expHdr_amtDueEmployee := 0;--Bug#6400678
BEGIN
      l_amt_due_employee := p_amt_due_employee;

      SELECT decode (maximum_amount_to_apply, NULL, NULL,least( p_total, maximum_amount_to_apply))-- Bug 3654956
      INTO l_max_amt_to_apply
      from ap_expense_report_headers
      where report_header_id = p_report_header_id;

      --Bug#6400678 : Calculate amount due to employee taking advance applied into consideration

      IF(l_max_amt_to_apply IS NOT NULL AND l_max_amt_to_apply <> 0) THEN
	l_amt_due_employee := l_amt_due_employee - l_max_amt_to_apply;
      END IF;

      UPDATE ap_expense_report_headers
      SET    amt_due_ccard_company = p_amt_due_ccard_company,
             amt_due_employee = l_amt_due_employee,
             total = p_total,
             maximum_amount_to_apply = l_max_amt_to_apply
      WHERE  report_header_id = p_report_header_id;

      return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('SetAmtDuesAndTotal');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END SetAmtDuesAndTotal;


-------------------------------------------------------------------
FUNCTION SetBothpayReportHeader(
	p_report_header_id	IN expHdr_headerID,
	p_sub_total 		IN NUMBER,
	p_vendor_id 		IN expHdr_vendorID,
	p_vendor_site_id 	IN expHdr_vendorSiteID,
	p_bothpay_id 		IN expHdr_bothpayParentID,
	p_paid_on_behalf_id 	IN expHdr_paidOnBehalfEmpID,
	p_total 		IN expHdr_total,
	p_amt_due_ccard_company IN expHdr_amtDueCCardCompany,
	p_employee_id 		IN expHdr_employeeID,
	p_description 		IN expHdr_description,
	p_source		IN expHdr_source,
	p_accts_comb_id		IN expHdr_acctsPayCodeCombID
 )  RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
/* Bug 3654956 : Seeting the value of maximum_amount_to_apply*/
      	UPDATE ap_expense_report_headers
      	SET    total = decode(p_total, NULL, total, total - p_sub_total),
               vendor_id = p_vendor_id,
               vendor_site_id = p_vendor_site_id,
	       amt_due_ccard_company = NVL(p_amt_due_ccard_company, amt_due_ccard_company),
               bothpay_parent_id = p_bothpay_id,
               paid_on_behalf_employee_id = DECODE(p_paid_on_behalf_id, -1, employee_id, p_paid_on_behalf_id),
	       employee_id = NVL(p_employee_id, employee_id),
	       description = NVL(p_description, description),
	       source = NVL(p_source, source),
	       accts_pay_code_combination_id = NVL(p_accts_comb_id, accts_pay_code_combination_id),
               maximum_amount_to_apply = decode (maximum_amount_to_apply, NULL, NULL,
                                          decode(p_total, NULL,NULL,
                                           least( total - p_sub_total, maximum_amount_to_apply)))
      	WHERE  report_header_id = p_report_header_id;

  	return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('SetBothpayReportHeader');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END SetBothpayReportHeader;

-------------------------------------------------------------------
FUNCTION SetWkflApprvdFlagAndSource(
	p_report_header_id 	IN expHdr_headerID,
 	p_flag			IN expHdr_wkflApprvdFlag,
	p_source 		IN expHdr_source
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN

    UPDATE ap_expense_report_headers erh
    SET    workflow_approved_flag = NVL(p_flag, decode(erh.workflow_approved_flag, 'M', 'A', erh.workflow_approved_flag)),
	   source = NVL(p_source, erh.source),
           last_update_date = SYSDATE,
           last_updated_by = Decode(Nvl(fnd_global.user_id,-1),-1,last_updated_by,fnd_global.user_id)
    WHERE  report_header_id = p_report_header_id;

    return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('SetWkflApprvdFlagAndSource');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END SetWkflApprvdFlagAndSource;


/* This is a combination of two FUNCTIONs.  The other one is
   commented out nocopy below */
-------------------------------------------------------------------
FUNCTION SetWkflApprvdFlag(p_report_header_id IN expHdr_headerID)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN

    UPDATE ap_expense_report_headers
    SET    workflow_approved_flag = decode(workflow_approved_flag,
		'P','Y',
		C_WORKFLOW_APPROVED_REQUEST, C_WORKFLOW_APPROVED_REQUEST, -- AP already rejected
		C_WORKFLOW_APPROVED_REJECTED, C_WORKFLOW_APPROVED_REJECTED, -- AP already requests more info
		'M')
    WHERE  report_header_id = p_report_header_id;

    return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('SetWkflApprvdFlag');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END SetWkflApprvdFlag;

-------------------------------------------------------------------
FUNCTION SetWkflApprvdFlag2(p_report_header_id IN expHdr_headerID)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN

    UPDATE ap_expense_report_headers
    SET    workflow_approved_flag = decode(workflow_approved_flag,
           'P', 'Y',
           'Y', 'Y',
           'M')
    WHERE  report_header_id = p_report_header_id;

    return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('SetWkflApprvdFlag2');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END SetWkflApprvdFlag2;

-------------------------------------------------------------------
FUNCTION DeleteReportHeaderAtDate(
  P_ReportID             IN expHdr_headerID,
  P_LastUpdateDate       IN expHdr_lastUpdateDate)
RETURN BOOLEAN IS
-------------------------------------------------------------------
  l_TempReportHeaderID   NUMBER;

BEGIN

  -- Selects report headers to delete.  The actual value being selected does
  -- not matter.  For some reason the compiler complains when the OF
  -- column-name in the FOR UPDATE is missing and NOWAIT is used, so the OF
  -- REPORT_HEADER_ID is used as a place holder.
  SELECT REPORT_HEADER_ID
  INTO   l_TempReportHeaderID
  FROM   AP_EXPENSE_REPORT_HEADERS
  WHERE  REPORT_HEADER_ID = P_ReportID
         AND SOURCE = C_RestorableReportSource
         AND LAST_UPDATE_DATE = NVL(P_LastUpdateDate, LAST_UPDATE_DATE)
  FOR UPDATE OF REPORT_HEADER_ID NOWAIT;

  -- Delete matching line
  if (DeleteExpenseReport(P_ReportID)) then null; end if;

  return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('DeleteReportHeaderAtDate');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END DeleteReportHeaderAtDate;


-------------------------------------------------------------------
FUNCTION DeleteExpenseReport(p_report_header_id IN expHdr_headerID)
RETURN BOOLEAN IS
-------------------------------------------------------------------
l_curr_calling_sequence 	VARCHAR2(100) := 'DeleteExpenseReport';

BEGIN
  DELETE FROM ap_expense_report_headers
  WHERE  report_header_id = p_report_header_id;

  /* Delete All Notes associated with Expense Report */
  AP_WEB_NOTES_PKG.DeleteERNotes (
    p_src_report_header_id       => p_report_header_id
  );

  /* Delete attachments assocated with the header */
  fnd_attached_documents2_pkg.delete_attachments(
    X_entity_name => 'OIE_HEADER_ATTACHMENTS',
    X_pk1_value => p_report_header_id,
    X_delete_document_flag => 'Y'
  );

  return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('DeleteExpenseReport');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END DeleteExpenseReport;

-------------------------------------------------------------------
FUNCTION ResubmitExpenseReport(p_workflow_approved_flag IN VARCHAR2)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  /* Bug 2636718 - Please note that this piece of the code does not
     have C_WORKFLOW_WITHDRAWN because this API is used to determine
     if its going to create a new workflow process or re start from
     a block activity.  This API will return if workflow is restarted
     from a blocked activity.  Withdraw needs to create a new workflow
     process
  */
  if ((p_workflow_approved_flag IS NOT NULL) AND (p_workflow_approved_flag = C_WORKFLOW_APPROVED_REJECTED OR p_workflow_approved_flag = C_WORKFLOW_APPROVED_RETURNED)) then
    return TRUE;
  else
    return FALSE;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('ResubmitExpenseReport');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END ResubmitExpenseReport;



-------------------------------------------------------------------
-- Name: DuplicateHeader
-- Desc: duplicates an Expense Report Header
-- Input:   p_source_report_header_id - source expense report header id
-- Returns: p_target_report_header_id - target expense report header id
-------------------------------------------------------------------
PROCEDURE DuplicateHeader(
  p_user_id     IN NUMBER,
  p_source_report_header_id     IN expHdr_headerID,
  p_target_report_header_id     IN OUT NOCOPY expHdr_headerID) IS

  l_invoice_num varchar2(50);
  l_employee_id number;

BEGIN

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPRPT_PKG',
                                   'start DuplicateHeader');

  select EMPLOYEE_ID into l_employee_id
  from AP_EXPENSE_REPORT_HEADERS
  where REPORT_HEADER_ID = p_source_report_header_id;
  l_invoice_num := AP_WEB_OA_CUSTOM_PKG.GetNewExpenseReportInvoice(l_employee_id, p_user_id, p_target_report_header_id);

  insert into AP_EXPENSE_REPORT_HEADERS
        (
         REPORT_HEADER_ID,
         WEEK_END_DATE,
         EMPLOYEE_ID,
         VOUCHNO,
         TOTAL,
         EXPENSE_REPORT_ID,
         SET_OF_BOOKS_ID,
         SOURCE,
         DESCRIPTION,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         DEFAULT_CURRENCY_CODE,
         DEFAULT_EXCHANGE_RATE_TYPE,
         DEFAULT_EXCHANGE_RATE,
         DEFAULT_EXCHANGE_DATE,
         ORG_ID,
         GLOBAL_ATTRIBUTE_CATEGORY,
         GLOBAL_ATTRIBUTE1,
         GLOBAL_ATTRIBUTE2,
         GLOBAL_ATTRIBUTE3,
         GLOBAL_ATTRIBUTE4,
         GLOBAL_ATTRIBUTE5,
         GLOBAL_ATTRIBUTE6,
         GLOBAL_ATTRIBUTE7,
         GLOBAL_ATTRIBUTE8,
         GLOBAL_ATTRIBUTE9,
         GLOBAL_ATTRIBUTE10,
         GLOBAL_ATTRIBUTE11,
         GLOBAL_ATTRIBUTE12,
         GLOBAL_ATTRIBUTE13,
         GLOBAL_ATTRIBUTE14,
         GLOBAL_ATTRIBUTE15,
         GLOBAL_ATTRIBUTE16,
         GLOBAL_ATTRIBUTE17,
         GLOBAL_ATTRIBUTE18,
         GLOBAL_ATTRIBUTE19,
         GLOBAL_ATTRIBUTE20,
         FLEX_CONCATENATED,
         OVERRIDE_APPROVER_ID,
         PAYMENT_CURRENCY_CODE,
         OVERRIDE_APPROVER_NAME,
         DEFAULT_RECEIPT_CURRENCY_CODE,
         MULTIPLE_CURRENCIES_FLAG,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         INVOICE_NUM
        )
  select
         p_target_report_header_id AS REPORT_HEADER_ID,
         WEEK_END_DATE,
         EMPLOYEE_ID,
         0 AS VOUCHNO,
         0 AS TOTAL,
         EXPENSE_REPORT_ID,
         SET_OF_BOOKS_ID,
         C_RestorableReportSource AS SOURCE,
         DESCRIPTION,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         DEFAULT_CURRENCY_CODE,
         DEFAULT_EXCHANGE_RATE_TYPE,
         DEFAULT_EXCHANGE_RATE,
         DEFAULT_EXCHANGE_DATE,
         ORG_ID,
         GLOBAL_ATTRIBUTE_CATEGORY,
         GLOBAL_ATTRIBUTE1,
         GLOBAL_ATTRIBUTE2,
         GLOBAL_ATTRIBUTE3,
         GLOBAL_ATTRIBUTE4,
         GLOBAL_ATTRIBUTE5,
         GLOBAL_ATTRIBUTE6,
         GLOBAL_ATTRIBUTE7,
         GLOBAL_ATTRIBUTE8,
         GLOBAL_ATTRIBUTE9,
         GLOBAL_ATTRIBUTE10,
         GLOBAL_ATTRIBUTE11,
         GLOBAL_ATTRIBUTE12,
         GLOBAL_ATTRIBUTE13,
         GLOBAL_ATTRIBUTE14,
         GLOBAL_ATTRIBUTE15,
         GLOBAL_ATTRIBUTE16,
         GLOBAL_ATTRIBUTE17,
         GLOBAL_ATTRIBUTE18,
         GLOBAL_ATTRIBUTE19,
         GLOBAL_ATTRIBUTE20,
         FLEX_CONCATENATED,
         OVERRIDE_APPROVER_ID,
         PAYMENT_CURRENCY_CODE,
         OVERRIDE_APPROVER_NAME,
         DEFAULT_RECEIPT_CURRENCY_CODE,
         MULTIPLE_CURRENCIES_FLAG,
         sysdate AS CREATION_DATE,
         p_user_id AS CREATED_BY,
         sysdate AS LAST_UPDATE_DATE,
         p_user_id AS LAST_UPDATED_BY,
	 l_invoice_num as INVOICE_NUM
  from   AP_EXPENSE_REPORT_HEADERS
  where  REPORT_HEADER_ID = p_source_report_header_id;

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_EXPRPT_PKG',
                                   'end DuplicateHeader');

END DuplicateHeader;
--------------------------------------------------------------------------------

FUNCTION UpdateHeaderTotal(
p_report_header_id 	IN expHdr_headerID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
  l_total	number;
  l_diff	number;
BEGIN

  -- Bug 9286884 - Itemized Parents shouldn't be included in total calc.
  select sum(amount)
  into l_total
  from ap_expense_report_lines
  where report_header_id = p_report_header_id
  and Nvl(itemization_parent_id,-200) <> -1;

  select(l_total - total)
  into l_diff
  from ap_expense_report_headers
  where report_header_id = p_report_header_id;

  update ap_expense_report_headers
  set total = l_total,
      amt_due_employee = amt_due_employee + l_diff
  where report_header_id = p_report_header_id;

  return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('UpdateHeaderTotal');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END UpdateHeaderTotal;

--------------------------------------------------------------------------------


FUNCTION GetReimbCurr(
	p_expenseReportId	IN  expHdr_headerID,
	p_payment_curr_code	OUT NOCOPY expHdr_payemntCurrCode
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  SELECT payment_currency_code
  INTO   p_payment_curr_code
  FROM   ap_expense_report_headers
  WHERE  report_header_id = p_expenseReportId;

  return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetReimbCurr');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;

END GetReimbCurr;
-------------------------------------------------------------------
FUNCTION GetHeaderTotal(p_report_header_id 	IN  expHdr_headerID,
			p_total			OUT NOCOPY NUMBER)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
      SELECT total
      INTO   p_total
      FROM   ap_expense_report_headers
      WHERE  report_header_id = p_report_header_id;

      RETURN true;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetHeaderTotal');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetHeaderTotal ;
-------------------------------------------------------------------

/*Written By :Amulya Mishra
  Purpose    :Returns the PAYMENT_DUE_FROM_CODE from
              AP_CREDIT_CARD_TRXNS_ALL table based upon
              report_header_id.
*/
FUNCTION getPaymentDueFromReport(
        p_report_header_id IN expHdr_headerID,
        p_paymentDueFromCode OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS

p_payment_due_from_code VARCHAR2(30);
-----------------------------------------------------------------------------
BEGIN
       p_paymentDueFromCode := NULL;
       AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_DB_CCARD_PKG', 'start getPaymentDueFromReport');

       SELECT payment_due_from_code
       INTO   p_paymentDueFromCode
       FROM   ap_credit_card_trxns_all trx
       WHERE  trx.report_header_id = p_report_header_id
       AND    rownum = 1; --Data Corruption might give two Distinct Pay Methods.

       return TRUE;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
               RETURN FALSE;

        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'getPaymentDueFromReport');
                APP_EXCEPTION.RAISE_EXCEPTION;

END getPaymentDueFromReport;
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
/*Written By :Ron Langi
  Purpose    :Returns the Audit Return Reason and Instruction
              using the report_header_id.
*/
-----------------------------------------------------------------------------
FUNCTION getAuditReturnReasonInstr(
                                   p_report_header_id IN expHdr_headerID,
                                   p_return_reason OUT NOCOPY VARCHAR2,
                                   p_return_instruction OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS

BEGIN
       AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_DB_EXPRPT_PKG', 'start getAuditReturnReasonInstr');

       SELECT AP_WEB_POLICY_UTILS.get_lookup_meaning('OIE_AUD_RETURN_REASONS',aerh.return_reason_code),
              AP_WEB_POLICY_UTILS.get_lookup_description('OIE_AUD_RETURN_REASONS',aerh.return_reason_code)||' '||aerh.return_instruction
       INTO   p_return_reason,
              p_return_instruction
       FROM   ap_expense_report_headers aerh
       WHERE  aerh.report_header_id = p_report_header_id;

       return true;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
               RETURN false;
        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException('getAuditReturnReasonInstr');
                APP_EXCEPTION.RAISE_EXCEPTION;
END getAuditReturnReasonInstr;

-----------------------------------------------------------------------------
/*Written By :Ron Langi
  Purpose    :Clears the Audit Return Reason and Instruction
              using the report_header_id.
*/
-----------------------------------------------------------------------------
PROCEDURE clearAuditReturnReasonInstr(
                                   p_report_header_id IN expHdr_headerID)
IS

BEGIN
       AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_DB_EXPRPT_PKG', 'start clearAuditReturnReasonInstr');

       UPDATE ap_expense_report_headers aerh
       SET    aerh.return_reason_code = '',
              aerh.return_instruction = ''
       WHERE  aerh.report_header_id = p_report_header_id;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
               RETURN ;
        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException('clearAuditReturnReasonInstr');
                APP_EXCEPTION.RAISE_EXCEPTION;
END clearAuditReturnReasonInstr;

--------------------------------------------------------------------------------
FUNCTION GetDefaultEmpCCID(
           p_employee_id            IN  NUMBER,
           p_default_emp_ccid       OUT NOCOPY expHdr_employeeCCID)

RETURN BOOLEAN IS

--------------------------------------------------------------------------------
  l_debugInfo   varchar2(240);
BEGIN
  l_debugInfo := 'Get default employee CCID';

  SELECT default_code_combination_id
  INTO   p_default_emp_ccid
  FROM (
    SELECT emp.default_code_combination_id
    FROM  per_employees_x emp
    WHERE  emp.employee_id = p_employee_id
    AND NOT AP_WEB_DB_HR_INT_PKG.ispersoncwk(emp.employee_id)='Y'
      UNION ALL
    SELECT emp.default_code_combination_id
    FROM  per_cont_workers_current_x emp
    WHERE  emp.person_id = p_employee_id
  );


    RETURN TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('GetDefaultEmpCCID',
                                    l_debugInfo);
      APP_EXCEPTION.RAISE_EXCEPTION;
      return FALSE;
END GetDefaultEmpCCID;

--------------------------------------------------------------------------------
FUNCTION GetChartOfAccountsID(
           p_employee_id            IN  NUMBER,
           p_chart_of_accounts_id   OUT NOCOPY glsob_chartOfAccountsID)

RETURN BOOLEAN IS

--------------------------------------------------------------------------------
  l_debugInfo   varchar2(240);
  l_emp_set_of_books_id   gl_sets_of_books.set_of_books_id%type;
BEGIN
  l_debugInfo := 'Get Chart of Accounts ID';

  SELECT set_of_books_id
  INTO l_emp_set_of_books_id
  FROM (
    SELECT emp.set_of_books_id
    FROM  per_employees_x emp
    WHERE  emp.employee_id = p_employee_id
    AND NOT AP_WEB_DB_HR_INT_PKG.ispersoncwk(emp.employee_id)='Y'
      UNION ALL
    SELECT emp.set_of_books_id
    FROM  per_cont_workers_current_x emp
    WHERE  emp.person_id = p_employee_id
  );

  IF (l_emp_set_of_books_id IS NOT NULL) THEN
    SELECT GS.chart_of_accounts_id
    INTO   p_chart_of_accounts_id
    FROM   gl_sets_of_books GS
    WHERE  GS.set_of_books_id=l_emp_set_of_books_id;
  ELSE
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('GetChartOfAccountsID',
                                    l_debugInfo);
      APP_EXCEPTION.RAISE_EXCEPTION;
      return FALSE;
END GetChartOfAccountsID;


--------------------------------------------------------------------------------
FUNCTION GetFlexConcactenated(p_parameter_id      IN  ap_expense_report_params.parameter_id%TYPE,
                              p_FlexConcactenated OUT NOCOPY ap_expense_report_params.FLEX_CONCACTENATED%TYPE)
RETURN BOOLEAN IS

--------------------------------------------------------------------------------
  l_debugInfo   varchar2(240);
BEGIN
  l_debugInfo := 'Get FlexConcactenated';

    SELECT Flex_Concactenated
      INTO p_FlexConcactenated
      FROM AP_EXPENSE_REPORT_PARAMS
      WHERE parameter_id = p_parameter_id;


    RETURN TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
      AP_WEB_DB_UTIL_PKG.RaiseException('GetFlexConcactenated',
                                    l_debugInfo);
      APP_EXCEPTION.RAISE_EXCEPTION;
      return FALSE;
END GetFlexConcactenated;

/*Written By :Maulik Vadera
  Purpose    :Wrapper function over getPaymentDueFromReport(p_report_header_id,p_paymentDueFromCode)
*/
--------------------------------------------------------------------------------
FUNCTION getPaymentDueFromReport(p_report_header_id IN expHdr_headerID)
RETURN VARCHAR2 IS
--------------------------------------------------------------------------------
l_payment_due_from_code VARCHAR2(30);
l_temp_bool BOOLEAN;

BEGIN

   l_temp_bool := getPaymentDueFromReport(p_report_header_id,l_payment_due_from_code);

   RETURN l_payment_due_from_code;

END getPaymentDueFromReport;

------------------------------------------------------------------------
-- FUNCTION GetERInvoiceNumber
-- Returns the invoice number of an expense report
-- 03/22/2005 - Kristian Widjaja
------------------------------------------------------------------------
FUNCTION GetERInvoiceNumber(p_report_header_id IN NUMBER)
RETURN VARCHAR2 IS

 l_invoice_num AP_EXPENSE_REPORT_HEADERS_ALL.INVOICE_NUM%TYPE;

BEGIN
  SELECT invoice_num
  INTO l_invoice_num
  FROM ap_expense_report_headers_all
  WHERE report_header_id = p_report_header_id;

  return l_invoice_num;
EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetERInvoiceNumber');
    APP_EXCEPTION.RAISE_EXCEPTION;
END GetERInvoiceNumber;

------------------------------------------------------------------------
-- FUNCTION GetERWorkflowApproved
-- Returns the workflow approved flag of an expense report
-- 03/22/2005 - Kristian Widjaja
------------------------------------------------------------------------
FUNCTION GetERWorkflowApprovedFlag(p_report_header_id IN NUMBER)
RETURN VARCHAR2 IS
 l_workflow_approved_flag AP_EXPENSE_REPORT_HEADERS_ALL.WORKFLOW_APPROVED_FLAG%TYPE;

BEGIN
  SELECT workflow_approved_flag
  INTO l_workflow_approved_flag
  FROM ap_expense_report_headers_all
  WHERE report_header_id = p_report_header_id;

  return l_workflow_approved_flag;
EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetERWorkflowApprovedFlag');
    APP_EXCEPTION.RAISE_EXCEPTION;
END GetERWorkflowApprovedFlag;

FUNCTION GetERLastUpdateDate(p_report_header_id IN NUMBER)
   RETURN VARCHAR2 IS
    l_last_update_date VARCHAR2(30);

   BEGIN
     SELECT to_char(last_update_date, 'DD-MON-RRRR HH:MI:SS', 'NLS_DATE_LANGUAGE = ENGLISH')
     INTO l_last_update_date
     FROM ap_expense_report_headers_all
     WHERE report_header_id = p_report_header_id;

     return l_last_update_date;
   EXCEPTION
     WHEN OTHERS THEN
       AP_WEB_DB_UTIL_PKG.RaiseException('GetERLastUpdateDate');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END GetERLastUpdateDate;

------------------------------------------------------------------------
-- FUNCTION CopyAttachments
-- API to create the reference for the Attachments from source
-- to target depending on the entity name
-- Entity Name=OIE_HEADER_ATTACHMENTS - Header Level Attachments
-- Entity Name=OIE_LINE_ATTACHMENTS - Line Level Attachments
-- 10th Dec, 2009 - SaiKumar Talasila.
------------------------------------------------------------------------
PROCEDURE CopyAttachments(p_source_id   IN NUMBER,
			  p_target_id   IN NUMBER,
                          p_entity_name IN VARCHAR2)
IS

  CURSOR expense_attachments_cur(l_report_header_id IN NUMBER) IS
  SELECT *
    FROM (   SELECT *
               FROM fnd_attached_documents
              WHERE entity_name = p_entity_name
                AND pk1_value = To_Char(l_report_header_id)
         );

  CURSOR expense_documents_cur(l_document_id IN NUMBER) IS
  SELECT *
    FROM fnd_documents
   WHERE document_id = l_document_id;

  CURSOR expense_documents_tl_cur(l_document_id IN NUMBER) IS
  SELECT *
    FROM fnd_documents_tl
   WHERE document_id = l_document_id
     AND rownum = 1;

  AttachedDocTabRec expense_attachments_cur%ROWTYPE;

  DocumentTabRec expense_documents_cur%ROWTYPE;

  DocumentTLTabRec expense_documents_tl_cur%ROWTYPE;

  l_rowid     VARCHAR2(60) := null;
  l_media_id  NUMBER := null;

BEGIN

  IF(p_source_id IS NULL OR p_target_id IS NULL) THEN
    RETURN;
  END IF;


  OPEN expense_attachments_cur(p_source_id);

    LOOP

      FETCH expense_attachments_cur
        INTO AttachedDocTabRec;

      EXIT WHEN expense_attachments_cur%NOTFOUND;

      BEGIN

        SELECT fnd_attached_documents_s.nextval
          INTO AttachedDocTabRec.attached_document_id
          FROM dual;

        FND_ATTACHED_DOCUMENTS_PKG.INSERT_ROW
                (x_rowid                        => l_rowid
                , x_attached_document_id        => AttachedDocTabRec.attached_document_id
                , x_document_id                 => AttachedDocTabRec.document_id
                , x_seq_num                     => AttachedDocTabRec.seq_num
                , x_entity_name                 => AttachedDocTabRec.entity_name
                , x_pk1_value                   => To_Char(p_target_id)
                , x_pk2_value                   => null
                , x_pk3_value                   => null
                , x_pk4_value                   => null
                , x_pk5_value                   => null
                , x_automatically_added_flag    => 'Y'
                , x_creation_date               => sysdate
                , x_created_by                  => AttachedDocTabRec.created_by
                , x_last_update_date            => sysdate
                , x_last_updated_by             => to_number(fnd_global.user_id)
                , x_last_update_login           => to_number(FND_GLOBAL.LOGIN_ID)
                , x_column1                     => AttachedDocTabRec.column1
                , x_datatype_id                 => null
                , x_category_id                 => AttachedDocTabRec.category_id
                , x_security_type               => null
                , X_security_id                 => null
                , X_publish_flag                => null
                , X_image_type                  => null
                , X_storage_type                => null
                , X_usage_type                  => null
                , X_language                    => null
                , X_description                 => null
                , X_file_name                   => null
                , X_media_id                    => l_media_id
                , X_doc_attribute_Category      => null
                , X_doc_attribute1              => null
                , X_doc_attribute2              => null
                , X_doc_attribute3              => null
                , X_doc_attribute4              => null
                , X_doc_attribute5              => null
                , X_doc_attribute6              => null
                , X_doc_attribute7              => null
                , X_doc_attribute8              => null
                , X_doc_attribute9              => null
                , X_doc_attribute10             => null
                , X_doc_attribute11             => null
                , X_doc_attribute12             => null
                , X_doc_attribute13             => null
                , X_doc_attribute14             => null
                , X_doc_attribute15             => null
                );

        /* Logic to update the document usage_type to "S" */

        OPEN expense_documents_cur(AttachedDocTabRec.document_id);

        FETCH expense_documents_cur
        INTO DocumentTabRec;

        CLOSE expense_documents_cur;

        OPEN expense_documents_tl_cur(AttachedDocTabRec.document_id);

        FETCH expense_documents_tl_cur
        INTO DocumentTLTabRec;

        CLOSE expense_documents_tl_cur;

        FND_DOCUMENTS_PKG.Update_Row
                (X_document_id                      => DocumentTabRec.document_id
                ,X_last_update_date                 => sysdate
                ,X_last_updated_by                  => to_number(fnd_global.user_id)
                ,X_last_update_login                => to_number(FND_GLOBAL.LOGIN_ID)
                ,X_datatype_id                      => DocumentTabRec.datatype_id
                ,X_category_id                      => DocumentTabRec.category_id
                ,X_security_type                    => DocumentTabRec.security_type
                ,X_security_id                      => DocumentTabRec.security_id
                ,X_publish_flag                     => DocumentTabRec.publish_flag
                ,X_image_type                       => DocumentTabRec.image_type
                ,X_storage_type                     => DocumentTabRec.storage_type
                ,X_usage_type                       => 'S'
                ,X_start_date_active                => DocumentTabRec.start_date_active
                ,X_end_date_active                  => DocumentTabRec.end_date_active
                ,X_language                         => DocumentTLTabRec.language
                ,X_description                      => DocumentTLTabRec.description
                ,X_file_name                        => DocumentTabRec.file_name
                ,X_media_id                         => DocumentTabRec.media_id
                ,X_Attribute_Category               => DocumentTLTabRec.doc_attribute_category
                ,X_Attribute1                       => DocumentTLTabRec.doc_attribute1
                ,X_Attribute2                       => DocumentTLTabRec.doc_attribute2
                ,X_Attribute3                       => DocumentTLTabRec.doc_attribute3
                ,X_Attribute4                       => DocumentTLTabRec.doc_attribute4
                ,X_Attribute5                       => DocumentTLTabRec.doc_attribute5
                ,X_Attribute6                       => DocumentTLTabRec.doc_attribute6
                ,X_Attribute7                       => DocumentTLTabRec.doc_attribute7
                ,X_Attribute8                       => DocumentTLTabRec.doc_attribute8
                ,X_Attribute9                       => DocumentTLTabRec.doc_attribute9
                ,X_Attribute10                      => DocumentTLTabRec.doc_attribute10
                ,X_Attribute11                      => DocumentTLTabRec.doc_attribute11
                ,X_Attribute12                      => DocumentTLTabRec.doc_attribute12
                ,X_Attribute13                      => DocumentTLTabRec.doc_attribute13
                ,X_Attribute14                      => DocumentTLTabRec.doc_attribute14
                ,X_Attribute15                      => DocumentTLTabRec.doc_attribute15
                ,X_url                              => DocumentTabRec.url
                ,X_title                            => DocumentTLTabRec.title);

        EXCEPTION
          WHEN OTHERS THEN
            --Error raised and ignored while Transferring the attachments.
            NULL;
        END;

      END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('CopyAttachments');
    APP_EXCEPTION.RAISE_EXCEPTION;
END CopyAttachments;

END AP_WEB_DB_EXPRPT_PKG;

/
