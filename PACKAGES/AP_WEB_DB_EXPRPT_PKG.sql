--------------------------------------------------------
--  DDL for Package AP_WEB_DB_EXPRPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_EXPRPT_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdbers.pls 120.22.12010000.2 2010/02/03 17:59:14 stalasil ship $ */

------------------------
-- Types definition
------------------------

SUBTYPE expHdr_headerID			IS AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE;
SUBTYPE expHdr_employeeID		IS AP_EXPENSE_REPORT_HEADERS.employee_id%TYPE;
SUBTYPE expHdr_vouchno			IS AP_EXPENSE_REPORT_HEADERS.vouchno%TYPE;
SUBTYPE expHdr_total			IS AP_EXPENSE_REPORT_HEADERS.total%TYPE;
SUBTYPE expHdr_vendorID			IS AP_EXPENSE_REPORT_HEADERS.vendor_id%TYPE;
SUBTYPE expHdr_vendorSiteID		IS AP_EXPENSE_REPORT_HEADERS.vendor_site_id%TYPE;
SUBTYPE expHdr_expCheckAddrFlag		IS AP_EXPENSE_REPORT_HEADERS.expense_check_address_flag%TYPE;
SUBTYPE expHdr_invNum			IS AP_EXPENSE_REPORT_HEADERS.invoice_num%TYPE;
SUBTYPE expHdr_source			IS AP_EXPENSE_REPORT_HEADERS.source%TYPE;
SUBTYPE expHdr_expenseStatusCode	IS AP_EXPENSE_REPORT_HEADERS.expense_status_code%TYPE;
SUBTYPE expHdr_employeeCCID		IS AP_EXPENSE_REPORT_HEADERS.employee_ccid%TYPE;
SUBTYPE expHdr_description		IS AP_EXPENSE_REPORT_HEADERS.description%TYPE;
SUBTYPE expHdr_defaultCurrCode		IS AP_EXPENSE_REPORT_HEADERS.default_currency_code%TYPE;
SUBTYPE expHdr_defaultXchRateType	IS AP_EXPENSE_REPORT_HEADERS.default_exchange_rate_type%TYPE;
SUBTYPE expHdr_orgID			IS AP_EXPENSE_REPORT_HEADERS.org_id%TYPE;
SUBTYPE expHdr_wkflApprvdFlag		IS AP_EXPENSE_REPORT_HEADERS.workflow_approved_flag%TYPE;
SUBTYPE expHdr_flexConcat		IS AP_EXPENSE_REPORT_HEADERS.flex_concatenated%TYPE;
SUBTYPE expHdr_overrideApprID		IS AP_EXPENSE_REPORT_HEADERS.override_approver_id%TYPE;
SUBTYPE expHdr_overrideApprName		IS AP_EXPENSE_REPORT_HEADERS.override_approver_name%TYPE;
SUBTYPE expHdr_amtDueCCardCompany	IS AP_EXPENSE_REPORT_HEADERS.amt_due_ccard_company%TYPE;
SUBTYPE expHdr_amtDueEmployee		IS AP_EXPENSE_REPORT_HEADERS.amt_due_employee%TYPE;
SUBTYPE expHdr_bothpayParentId		IS AP_EXPENSE_REPORT_HEADERS.bothpay_parent_iD%TYPE;
SUBTYPE expHdr_shortpayParentId		IS AP_EXPENSE_REPORT_HEADERS.shortpay_parent_id%TYPE;
SUBTYPE expHdr_paidOnBehalfEmpID	IS AP_EXPENSE_REPORT_HEADERS.paid_on_behalf_employee_id%TYPE;
SUBTYPE expHdr_expRptID			IS AP_EXPENSE_REPORT_HEADERS.expense_report_id%TYPE;
SUBTYPE expHdr_weekEndDate		IS AP_EXPENSE_REPORT_HEADERS.week_end_date%TYPE;
SUBTYPE expHdr_createdBy		IS AP_EXPENSE_REPORT_HEADERS.created_by%TYPE;
SUBTYPE expHdr_lastUpdatedBy		IS AP_EXPENSE_REPORT_HEADERS.last_updated_by%TYPE;
SUBTYPE expHdr_lastUpdateDate		IS AP_EXPENSE_REPORT_HEADERS.last_update_date%TYPE;
SUBTYPE expHdr_setOfBooksID		IS AP_EXPENSE_REPORT_HEADERS.set_of_books_id%TYPE;
SUBTYPE expHdr_lastUpdateLogin		IS AP_EXPENSE_REPORT_HEADERS.last_update_login%TYPE;
SUBTYPE expHdr_applyAdvDefault		IS AP_EXPENSE_REPORT_HEADERS.apply_advances_default%TYPE;
SUBTYPE expHdr_awtGroupID		IS AP_EXPENSE_REPORT_HEADERS.awt_group_id%TYPE;
SUBTYPE expHdr_defaultExchDate		IS AP_EXPENSE_REPORT_HEADERS.default_exchange_date%TYPE;
SUBTYPE expHdr_defaultExchRate		IS AP_EXPENSE_REPORT_HEADERS.default_exchange_rate%TYPE;
SUBTYPE expHdr_acctsPayCodeCombID	IS AP_EXPENSE_REPORT_HEADERS.accts_pay_code_combination_id%TYPE;
SUBTYPE expHdr_attrCategory		IS AP_EXPENSE_REPORT_HEADERS.attribute_category%TYPE;
SUBTYPE expHdr_attr1			IS AP_EXPENSE_REPORT_HEADERS.attribute1%TYPE;
SUBTYPE expHdr_attr2			IS AP_EXPENSE_REPORT_HEADERS.attribute2%TYPE;
SUBTYPE expHdr_attr3			IS AP_EXPENSE_REPORT_HEADERS.attribute3%TYPE;
SUBTYPE expHdr_attr4			IS AP_EXPENSE_REPORT_HEADERS.attribute4%TYPE;
SUBTYPE expHdr_attr5			IS AP_EXPENSE_REPORT_HEADERS.attribute5%TYPE;
SUBTYPE expHdr_attr6			IS AP_EXPENSE_REPORT_HEADERS.attribute6%TYPE;
SUBTYPE expHdr_attr7			IS AP_EXPENSE_REPORT_HEADERS.attribute7%TYPE;
SUBTYPE expHdr_attr8			IS AP_EXPENSE_REPORT_HEADERS.attribute8%TYPE;
SUBTYPE expHdr_attr9			IS AP_EXPENSE_REPORT_HEADERS.attribute9%TYPE;
SUBTYPE expHdr_attr10			IS AP_EXPENSE_REPORT_HEADERS.attribute10%TYPE;
SUBTYPE expHdr_attr11			IS AP_EXPENSE_REPORT_HEADERS.attribute11%TYPE;
SUBTYPE expHdr_attr12			IS AP_EXPENSE_REPORT_HEADERS.attribute12%TYPE;
SUBTYPE expHdr_attr13			IS AP_EXPENSE_REPORT_HEADERS.attribute13%TYPE;
SUBTYPE expHdr_attr14			IS AP_EXPENSE_REPORT_HEADERS.attribute14%TYPE;
SUBTYPE expHdr_attr15			IS AP_EXPENSE_REPORT_HEADERS.attribute15%TYPE;
SUBTYPE expHdr_payemntCurrCode		IS AP_EXPENSE_REPORT_HEADERS.payment_currency_code%TYPE;
SUBTYPE expHdr_maxAmountApplied		IS AP_EXPENSE_REPORT_HEADERS.maximum_amount_to_apply%TYPE;

/* From DB AP INTERFACE PACKAGE */
SUBTYPE finSysParams_checkAddrFlag	IS FINANCIALS_SYSTEM_PARAMETERS.expense_check_address_flag%TYPE;

SUBTYPE glsob_chartOfAccountsID 	IS GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE;

SUBTYPE apSetUp_defaultExchRateType 	IS AP_SYSTEM_PARAMETERS.default_exchange_rate_type%TYPE;
SUBTYPE apSetUp_applyAdvDefault       	IS AP_SYSTEM_PARAMETERS.apply_advances_default%TYPE;
SUBTYPE apSetUp_allowAWTFlag          	IS AP_SYSTEM_PARAMETERS.allow_awt_flag%TYPE;
SUBTYPE apSetUp_makeMandatoryFlag	IS AP_SYSTEM_PARAMETERS.make_rate_mandatory_flag%TYPE;


/* From DB CCard Package */
SUBTYPE cardProgs_vendorID			IS AP_CARD_PROGRAMS.vendor_id%TYPE;
SUBTYPE cardProgs_vendorSiteID			IS AP_CARD_PROGRAMS.vendor_site_id%TYPE;

------------------------
-- Constants definition
------------------------

-- Workflow status flags
C_WORKFLOW_APPROVED_SAVED     CONSTANT VARCHAR2(1) := 'S';
C_WORKFLOW_APPROVED_REJECTED  CONSTANT VARCHAR2(1) := 'R';
C_WORKFLOW_APPROVED_RETURNED  CONSTANT VARCHAR2(1) := 'T';
C_WORKFLOW_APPROVED_SUBMIT    CONSTANT VARCHAR2(1) := '';
  --ER 1552747 - withdraw expense report
C_WORKFLOW_APPROVED_WITHDRAW  CONSTANT VARCHAR2(1) := 'W';
-- Auditor Requesting More Info
C_WORKFLOW_APPROVED_REQUEST   CONSTANT VARCHAR2(1) := 'Q';
 -- Used in query of header and lines
C_UserAttributeCode      CONSTANT VARCHAR2(50) := 'ICX_HR_PERSON_ID';
C_RestorableReportSource CONSTANT VARCHAR2(50) := 'NonValidatedWebExpense';



--------------------------------
-- Cursor Reference definition
--------------------------------

TYPE RestorableReportsCursor IS REF CURSOR;

TYPE ExpWorkflowRec IS RECORD (
  doc_num		expHdr_invNum,
  workflow_flag 	expHdr_wkflApprvdFlag
); /* end TYPE WorkflowRec */


TYPE ExpInfoRec IS RECORD (
  emp_id		expHdr_employeeID,
  default_curr_code	expHdr_defaultCurrCode,
  doc_num		expHdr_invNum,
  total			expHdr_total,
  payment_curr_code 	expHdr_payemntCurrCode,
  week_end_date 	expHdr_weekEndDate
); /* end TYPE ExpInfoRec */

TYPE ExpHeaderRec IS RECORD (
  template_id		VARCHAR2(20),
  last_receipt_date	VARCHAR2(25),
  description		expHdr_description,
  default_curr_code     expHdr_defaultCurrCode,
  flex_concat           expHdr_flexConcat,
  override_appr_id	VARCHAR2(15),
  override_appr_name	expHdr_overrideApprName,
  emp_id		expHdr_employeeID,
  last_update_date	VARCHAR2(25)
); /* end TYPE ExpHeaderRec */

TYPE XpenseInfoRec IS RECORD (
  report_header_id		expHdr_headerID,
  document_number		expHdr_invNum,
  employee_id			expHdr_employeeID,
  org_id			expHdr_orgID,
  vouchno			expHdr_vouchno,
  total				expHdr_total,
  vendor_id			expHdr_vendorID,
  vendor_site_id		expHdr_vendorSiteID,
  amt_due_employee		expHdr_amtDueEmployee,
  amt_due_ccard			expHdr_amtDueCCardCompany,
  description 			expHdr_description,
  preparer_id			expHdr_createdBy,
  last_update_login		expHdr_lastUpdateLogin,
  last_updated_by		expHdr_lastUpdatedBy,
  workflow_flag			VARCHAR2(20),
  expense_check_address_flag	expHdr_expCheckAddrFlag,
  bothpay_report_header_id	expHdr_bothpayParentID,
  shortpay_parent_id		expHdr_shortpayParentID,
  behalf_employee_id		expHdr_paidOnBehalfEmpID, --end of one function
  approver_id			expHdr_overrideApprID,
  week_end_date			expHdr_weekEndDate,
  set_of_books_id		expHdr_setOfBooksID,
  source			expHdr_source,
  accts_pay_comb_id		expHdr_acctsPayCodeCombID,
  expense_status_code		expHdr_expenseStatusCode
); /* end TYPE XpenseInfoRec */


----------------------------------------------------------------------------------------
-- Name: GetEmployeeIdFromBothPayParent
-- Desc: get employee_id from both pay parent report
-- Input:  p_bothpay_parent_id - parent report header id
-- Output: p_employee_id - employee_id from both pay parent report
---------------------------------------------------------------------------------------
PROCEDURE GetEmployeeIdFromBothPayParent(
                          p_bothpay_parent_id          IN      NUMBER,
                          p_employee_id               OUT NOCOPY     NUMBER);

----------------------------------------------------------------------------------------
-- Name: GetRestorableReportsCursor
-- Desc: get invoice_num, employee full name, total, etc. for restorable expense reports
--       that employee with P_WebUserID has access to
-- Input:  P_WebUserID - securing attribute's web_user_id
-- Output: p_cursor - cursor reference for RestorableReportsCursor
--      		that stores information about the selected expense reports
-- Returns: 	true - succeeded
--	    	false - failed
---------------------------------------------------------------------------------------
FUNCTION GetRestorableReportsCursor(P_WebUserID IN  AK_WEB_USER_SEC_ATTR_VALUES.web_user_id%TYPE,
				    p_cursor    OUT NOCOPY RestorableReportsCursor)
RETURN BOOLEAN;


---------------------------------------------------------------------------
-- Name: GetExpWorkflowInfo
-- Desc: get invoice_num and workflow_approved_flag for a particular
--	expense report
-- Input:   P_ReportID - report_header_id for the expense report
-- Output:  P_WorkflowRec - stores information about the selected expense report in
--      		ExpWorkflowRec
-- Returns: 	true - succeeded
--	    	false - failed
---------------------------------------------------------------------------
FUNCTION GetExpWorkflowInfo(
		P_ReportID           	IN  expHdr_headerID,
		P_WorkflowRec	 OUT NOCOPY ExpWorkflowRec)
RETURN BOOLEAN;


-------------------------------------------------------------------
-- Name: GetReportInfo
-- Desc: get employee_id, default_currency_code, invoice_num, and total
--	 for a particular expense report
-- Input:   p_expenseReportId - report_header_id for the expense report
-- Output:  p_exp_info_rec - stores information about the selected expense report in
--      		ExpInfoRec
-- Returns: 	true - succeeded
--	    	false - failed
-------------------------------------------------------------------
FUNCTION GetReportInfo(
	p_expenseReportId IN  expHdr_headerID,
	p_exp_info_rec	  OUT NOCOPY ExpInfoRec
) RETURN BOOLEAN;


-------------------------------------------------------------------------------------
-- Name: GetOverrideApproverID
-- Desc: get override_approver_id of a particular expense report
-- Input:   p_report_header_id - report_header_id for the expense report
-- Output:  p_id	- stores override_approver_id of expense report
-- Returns: 	true - succeeded
--	    	false - failed
-------------------------------------------------------------------------------------
FUNCTION GetOverrideApproverID(p_report_header_id IN  expHdr_headerID,
			       p_id		  OUT NOCOPY expHdr_overrideApprID)
RETURN BOOLEAN;


----------------------------------------------------------------------------------
-- Name: GetOrgIdByReportHeaderId
-- Desc: get org_id of a particular expense report
-- Input:   p_header_id - report_header_id for the expense report
-- Output:  p_org_id - stores org_id of expense report
-- Returns: 	true - succeeded
--	    	false - failed
----------------------------------------------------------------------------------
FUNCTION GetOrgIdByReportHeaderId(
	p_header_id	IN	expHdr_headerID,
	p_org_id OUT NOCOPY 	expHdr_orgID) RETURN BOOLEAN;

---------------------------------------------------------------------------------------------
-- Name: GetReportHeaderAttributes
-- Desc: get hr_employee's default_code_combination_id, employee_id, expense report's
--	 flex_concatenated, attribute_category, and attributes 1 thru 15
-- Input:   p_report_header_id - report_header_id for the expense report
-- Output:
-- Returns: 	true - succeeded
--	    	false - failed
---------------------------------------------------------------------------------------------
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
RETURN BOOLEAN;
-------------------------------------------------------------------

-------------------------------------------------------------------
-- Name: GetReportHeaderInfo
-- Desc: get expense_report_id, description, default_currency_code,
--	 flex_concatenated, employee_id, override_approver_name, etc.
--	 for a particular expense report
-- Input:   P_ReportID	- report_header_id for the expense report
-- Output:  P_ExpHdrRec - stores information about the selected expense report in
--      		ExpHeaderRec
-- Returns: 	true - succeeded
--	    	false - failed
-------------------------------------------------------------------
FUNCTION GetReportHeaderInfo(P_ReportID		IN  expHdr_headerID,
			      P_ExpHdrRec OUT NOCOPY ExpHeaderRec)
RETURN BOOLEAN;

-------------------------------------------------------------------
-- Name: GetExpReportExchCurrInfo
-- Desc: get default_exchange_rate, precision of the expense report
--       and of the default currency
-- Input:   p_report_id - report_header_id for the expense report
-- Output:  p_exch_rate - the selected expense report's default exchange rate
--          p_reimb_precision - default currency's precision
-- Returns:     true - succeeded
--              false - failed
-------------------------------------------------------------------
FUNCTION GetExpReportExchCurrInfo(p_report_id           IN  expHdr_headerID,
                                p_exch_rate             OUT NOCOPY expHdr_defaultExchRate,
                                p_reimb_precision       OUT NOCOPY FND_CURRENCIES_VL.PRECISION%TYPE
) RETURN BOOLEAN;

-------------------------------------------------------------------
-- Name: GetNextExpReportID
-- Desc: get the next sequence for expense report's report_header_id
--	 column
-- Output:  p_new_report_id - new report_header_id for expense report
-- Returns: 	true - succeeded
--	    	false - failed
-------------------------------------------------------------------
FUNCTION GetNextExpReportID(p_new_report_id OUT NOCOPY NUMBER) RETURN BOOLEAN;

-------------------------------------------------------------------
FUNCTION GetNextRptHdrID(p_new_report_id OUT NOCOPY NUMBER) RETURN BOOLEAN;
-------------------------------------------------------------------

-------------------------------------------------------------------
-- Name: GetAccountingInfo
-- Desc: get some system accounting parameters, chart_of_accounts_id,
--	 and employee information from the HR tables
-- Input:   p_report_header_id - report_header_id for a given expense report
-- Output:  p_sys_apply_advances_default - ap system parameter's apply_advances_default
--          p_sys_allow_awt_flag 	-  ap system parameter's allow_awt_flag
--          p_sys_default_xrate_type 	- ap system parameter's default_exchange_rate_type
--          p_sys_make_rate_mandatory 	- ap system parameter's make_rate_mandatory_flag
--          p_exp_check_address_flag  - HR's or financial system parameter's expense_check_address_flag
--  	    p_default_currency_code 	- expense report's default_currency_code
-- 	    p_week_end_date 		- expense report's week_end_date
-- 	    p_flex_concatenated  	- expense report's flex_concatenated
--          p_employee_id 		- expense report's employee_id
-- Returns: 	true - succeeded
--	    	false - failed
-------------------------------------------------------------------
FUNCTION GetAccountingInfo(
	p_report_header_id 		IN  expHdr_headerID,
	p_sys_apply_advances_default  OUT NOCOPY apSetUp_applyAdvDefault,
        p_sys_allow_awt_flag 	 OUT NOCOPY apSetUp_allowAWTFlag,
        p_sys_default_xrate_type  OUT NOCOPY apSetUp_defaultExchRateType,
        p_sys_make_rate_mandatory  OUT NOCOPY apSetUp_makeMandatoryFlag,
        p_exp_check_address_flag  OUT NOCOPY finSysParams_checkAddrFlag,
 	p_default_currency_code  OUT NOCOPY expHdr_defaultCurrCode,
	p_week_end_date 	 OUT NOCOPY expHdr_weekEndDate,
	p_flex_concatenated 	 OUT NOCOPY expHdr_flexConcat,
        p_employee_id 		 OUT NOCOPY expHdr_employeeID)
RETURN BOOLEAN;

-------------------------------------------------------------------
-- Name: GetExpReportInfo
-- Desc: get concatenation of card_number/full_name, vendor_id's,
--	 amt_due_ccard_company, and total for the credit card
--	 expense report in both pay
-- Input:   p_report_header_id - report_header_id for the expense report
-- Output:  p_description - stores concatenation of credit card_number/employee full_name
-- 	    p_ccard_amt - expense report's amt_due_ccard_company
-- 	    p_total - expense report's total
-- Returns: 	true - succeeded
--	    	false - failed
-------------------------------------------------------------------
FUNCTION GetExpReportInfo(
	p_report_header_id 	IN  expHdr_headerID,
	p_description 	 OUT NOCOPY VARCHAR2,
	p_ccard_amt 	 OUT NOCOPY expHdr_amtDueCCardCompany,
	p_total 	 OUT NOCOPY expHdr_total
) RETURN BOOLEAN;


FUNCTION ExpReportShortpaid(P_ReportID		IN  expHdr_headerID,
			    P_Shortpaid	 OUT NOCOPY BOOLEAN)
RETURN BOOLEAN;


-------------------------------------------------------------------
-- Name: InsertReportHeader
-- Desc: get
-- Input:   p_report_header_id - report_header_id for the expense report
--	    p_ExpReportHeaderInfo -
-- Returns: 	true - succeeded
--	    	false - failed
-------------------------------------------------------------------
FUNCTION InsertReportHeader(p_xpense_rec		IN XpenseInfoRec,
			    p_ExpReportHeaderInfo	IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec
) RETURN BOOLEAN;

-------------------------------------------------------------------
-- Name: InsertReportHeaderLikeExisting
-- Desc: get
-- Input:   p_orig_report_header_id - report_header_id for the expense report
--    	    p_xpense_rec
-- Returns: 	true - succeeded
--	    	false - failed
-------------------------------------------------------------------
FUNCTION InsertReportHeaderLikeExisting(p_orig_report_header_id 	IN expHdr_headerID,
					p_xpense_rec 			IN XpenseInfoRec
) RETURN BOOLEAN;


-------------------------------------------------------------------
-- Name: SetDefaultExchRateType
-- Desc: Updates ap_expense_report_headers with a new default_exchange_rate_type
-- Input:   p_report_header_id - report_header_id for the expense report
--    	    p_xrate_type - default_exchange_rate_type
-- Returns: 	true - succeeded
--	    	false - failed
-------------------------------------------------------------------
FUNCTION SetDefaultExchRateType(p_report_header_id	IN expHdr_headerID,
				p_xrate_type		IN expHdr_defaultXchRateType)
RETURN BOOLEAN;

-------------------------------------------------------------------
-- Name: SetExpenseHeaderInfo
-- Desc: get
-- Input:   p_report_header_id - report_header_id for the expense report
--	    p_exp_check_address_flag
--	    p_source
--	    p_workflow_approve_flag
--	    p_sys_apply_advances_default
--	    p_available_prepays
--	    p_sys_allow_awt_flag
--	    p_ven_allow_awt_flag
--	    p_ven_awt_group_id
--	    p_sys_default_xrate_type
--	    p_week_end_date
--	    p_default_exchange_rate
--	    p_employee_ccid
-- Returns: 	true - succeeded
--	    	false - failed
-------------------------------------------------------------------
FUNCTION SetExpenseHeaderInfo(
		p_report_header_id		IN expHdr_headerID,
	       	p_exp_check_address_flag	IN expHdr_expCheckAddrFlag,
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
) RETURN BOOLEAN;


-------------------------------------------------------------------
-- Name: SetAmtDuesAndTotal
-- Desc: get
-- Input:   p_report_header_id - report_header_id for the expense report
-- Returns: 	true - succeeded
--	    	false - failed
-------------------------------------------------------------------
FUNCTION SetAmtDuesAndTotal(
	p_report_header_id 	IN expHdr_headerID,
	p_amt_due_ccard_company IN expHdr_amtDueCCardCompany,
	p_amt_due_employee 	IN expHdr_amtDueEmployee,
	p_total 		IN expHdr_total
)  RETURN BOOLEAN;

-------------------------------------------------------------------
-- Name: SetBothpayReportHeader
-- Desc: get
-- Input:   p_report_header_id - report_header_id for the expense report
-- Returns: 	true - succeeded
--	    	false - failed
-------------------------------------------------------------------
FUNCTION SetBothpayReportHeader(
	p_report_header_id	IN expHdr_headerID,
	p_sub_total 		IN NUMBER,
	p_vendor_id 		IN expHdr_vendorID,
	p_vendor_site_id 	IN expHdr_vendorSiteID,
	p_bothpay_id 		IN expHdr_bothpayParentID,
	p_paid_on_behalf_id 	IN expHdr_paidOnBehalfEmpID,
	p_total 		IN expHdr_total 		DEFAULT NULL,
	p_amt_due_ccard_company IN expHdr_amtDueCCardCompany 	DEFAULT NULL,
	p_employee_id 		IN expHdr_employeeID		DEFAULT NULL,
	p_description 		IN expHdr_description		DEFAULT NULL,
	p_source		IN expHdr_source		DEFAULT NULL,
	p_accts_comb_id		IN expHdr_acctsPayCodeCombID    DEFAULT NULL
 )  RETURN BOOLEAN;


-------------------------------------------------------------------
FUNCTION SetWkflApprvdFlag(p_report_header_id IN expHdr_headerID)
RETURN BOOLEAN;
-------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION SetWkflApprvdFlag2(p_report_header_id IN expHdr_headerID)
RETURN BOOLEAN;
-------------------------------------------------------------------

-------------------------------------------------------------------
-- Name: SetWkflApprvdFlagAndSource
-- Desc: get
-- Input:   p_report_header_id - report_header_id for the expense report
-- Returns: 	true - succeeded
--	    	false - failed
-------------------------------------------------------------------
FUNCTION SetWkflApprvdFlagAndSource(
	p_report_header_id 	IN expHdr_headerID,
 	p_flag			IN expHdr_wkflApprvdFlag,
	p_source 		IN expHdr_source
) RETURN BOOLEAN;

-------------------------------------------------------------------
-- Name: DeleteReportHeaderAtDate
-- Desc: get
-- Input:    P_ReportID - report_header_id for the expense report
-- Returns: 	true - succeeded
--	    	false - failed
-------------------------------------------------------------------
FUNCTION DeleteReportHeaderAtDate(
  P_ReportID             IN expHdr_headerID,
  P_LastUpdateDate       IN expHdr_lastUpdateDate DEFAULT NULL)
RETURN BOOLEAN;

-------------------------------------------------------------------
-- Name: DeleteExpenseReport
-- Desc: get
-- Input:   p_report_header_id - report_header_id for the expense report
-- Returns: 	true - succeeded
--	    	false - failed
-------------------------------------------------------------------
FUNCTION DeleteExpenseReport(p_report_header_id IN expHdr_headerID)
RETURN BOOLEAN;

-------------------------------------------------------------------
-- Name: ResubmitExpenseReport
-- Desc: checks to see if report needs to be resubmitted
-- Input:   p_workflow_approved_flag - workflow_approved_flag for the expense report
-- Returns: 	true - needs to be resubmitted
--	    	false - does not need to be resubmitted
-------------------------------------------------------------------
FUNCTION ResubmitExpenseReport(p_workflow_approved_flag IN VARCHAR2)
RETURN BOOLEAN;

-------------------------------------------------------------------
-- Name: DuplicateHeader
-- Desc: duplicates an Expense Report Header
-- Input:   p_source_report_header_id - source expense report header id
-- Returns: p_target_report_header_id - target expense report header id
-------------------------------------------------------------------
PROCEDURE DuplicateHeader(
  p_user_id     IN NUMBER,
  p_source_report_header_id     IN expHdr_headerID,
  p_target_report_header_id     IN OUT NOCOPY expHdr_headerID);

--------------------------------------------------------------------------------

FUNCTION UpdateHeaderTotal(
p_report_header_id      IN expHdr_headerID
) RETURN BOOLEAN;
--------------------------------------------------------------------------------
FUNCTION GetReimbCurr(
	p_expenseReportId	IN  expHdr_headerID,
	p_payment_curr_code	OUT NOCOPY expHdr_payemntCurrCode
) RETURN BOOLEAN;
--------------------------------------------------------------------------------
FUNCTION GetHeaderTotal(p_report_header_id 	IN  expHdr_headerID,
			p_total			OUT NOCOPY NUMBER)
RETURN BOOLEAN;

-------------------------------------------------------------------
FUNCTION getPaymentDueFromReport(
        p_report_header_id IN expHdr_headerID,
        p_paymentDueFromCode OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN;
------------------------------------------------------------------------------

FUNCTION getPaymentDueFromReport(p_report_header_id IN expHdr_headerID)
RETURN VARCHAR2;
-------------------------------------------------------------------
FUNCTION getAuditReturnReasonInstr(
                                   p_report_header_id IN expHdr_headerID,
                                   p_return_reason OUT NOCOPY VARCHAR2,
                                   P_return_instruction OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN;
------------------------------------------------------------------------------

-------------------------------------------------------------------
PROCEDURE clearAuditReturnReasonInstr(
                                   p_report_header_id IN expHdr_headerID);
------------------------------------------------------------------------------

FUNCTION GetDefaultEmpCCID(
           p_employee_id            IN  NUMBER,
           p_default_emp_ccid       OUT NOCOPY expHdr_employeeCCID)
RETURN BOOLEAN;

--------------------------------------------------------------------------------
FUNCTION GetChartOfAccountsID(
           p_employee_id            IN  NUMBER,
           p_chart_of_accounts_id   OUT NOCOPY glsob_chartOfAccountsID)
RETURN BOOLEAN;

--------------------------------------------------------------------------------
FUNCTION GetFlexConcactenated(p_parameter_id      IN  ap_expense_report_params.parameter_id%TYPE,
                              p_FlexConcactenated OUT NOCOPY ap_expense_report_params.FLEX_CONCACTENATED%TYPE)
RETURN BOOLEAN;

--------------------------------------------------------------------------------
FUNCTION GetERInvoiceNumber(p_report_header_id IN NUMBER)
RETURN VARCHAR2;

--------------------------------------------------------------------------------
FUNCTION GetERWorkflowApprovedFlag(p_report_header_id IN NUMBER)
RETURN VARCHAR2;

--------------------------------------------------------------------------------
FUNCTION GetERLastUpdateDate(p_report_header_id IN NUMBER)
RETURN VARCHAR2;

--------------------------------------------------------------------------------
PROCEDURE CopyAttachments(p_source_id   IN NUMBER,
			  p_target_id   IN NUMBER,
                          p_entity_name IN VARCHAR2);

--------------------------------------------------------------------------------


END AP_WEB_DB_EXPRPT_PKG;

/
