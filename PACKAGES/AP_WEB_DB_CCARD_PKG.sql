--------------------------------------------------------
--  DDL for Package AP_WEB_DB_CCARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_CCARD_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdbccs.pls 120.17 2006/05/04 07:21:44 sbalaji ship $ */

/*  Constant */
c_personal             CONSTANT varchar(8) := 'PERSONAL';
c_business             CONSTANT varchar(8) := 'BUSINESS';
c_disputed             CONSTANT varchar(8) := 'DISPUTED';
c_credit               CONSTANT varchar(8) := 'CREDIT';
c_matched              CONSTANT varchar(8) := 'MATCHED';
c_deactivated          CONSTANT varchar(12) := 'DEACTIVATED';

/* AP Credit Card Transactions */
---------------------------------------------------------------------------------------------------
SUBTYPE ccTrxn_trxID				IS AP_CREDIT_CARD_TRXNS.trx_id%TYPE;
SUBTYPE ccTrxn_validateCode			IS AP_CREDIT_CARD_TRXNS.validate_code%TYPE;
SUBTYPE ccTrxn_cardProgID			IS AP_CREDIT_CARD_TRXNS.card_program_id%TYPE;
SUBTYPE ccTrxn_expensedAmt			IS AP_CREDIT_CARD_TRXNS.expensed_amount%TYPE;
SUBTYPE ccTrxn_cardId				IS AP_CREDIT_CARD_TRXNS.card_id%TYPE;
SUBTYPE ccTrxn_refNum				IS AP_CREDIT_CARD_TRXNS.reference_number%TYPE;
SUBTYPE ccTrxn_folioType			IS AP_CREDIT_CARD_TRXNS.folio_type%TYPE;
SUBTYPE ccTrxn_category				IS AP_CREDIT_CARD_TRXNS.category%TYPE;
SUBTYPE ccTrxn_headerID				IS AP_CREDIT_CARD_TRXNS.report_header_id%TYPE;
SUBTYPE ccTrxn_expenseStatus			IS AP_CREDIT_CARD_TRXNS.expense_status%TYPE;
SUBTYPE ccTrxn_billedCurrCode			IS AP_CREDIT_CARD_TRXNS.billed_currency_code%TYPE;
SUBTYPE ccTrxn_billedDate			IS AP_CREDIT_CARD_TRXNS.billed_date%TYPE;
SUBTYPE ccTrxn_companyPrepaidInvID		IS AP_CREDIT_CARD_TRXNS.company_prepaid_invoice_id%TYPE;
SUBTYPE ccTrxn_merchantName1			IS AP_CREDIT_CARD_TRXNS.merchant_name1%TYPE;
SUBTYPE ccTrxn_merchantCity			IS AP_CREDIT_CARD_TRXNS.merchant_city%TYPE;
SUBTYPE ccTrxn_billedAmount			IS AP_CREDIT_CARD_TRXNS.billed_amount%TYPE;
SUBTYPE ccTrxn_postedCurrCode			IS AP_CREDIT_CARD_TRXNS.posted_currency_code%TYPE;
SUBTYPE ccTrxn_trxnAmount			IS AP_CREDIT_CARD_TRXNS.transaction_amount%TYPE;
SUBTYPE ccTrxn_merchantProv			IS AP_CREDIT_CARD_TRXNS.merchant_province_state%TYPE;
SUBTYPE ccTrxn_transDate			IS AP_CREDIT_CARD_TRXNS.transaction_date%TYPE;
SUBTYPE ccTrxn_paymentDueFromCode		IS AP_CREDIT_CARD_TRXNS.payment_due_from_code%TYPE;


---------------------------------------------------------------------------------------------------
/* AP Card Programs */
---------------------------------------------------------------------------------------------------
SUBTYPE cardProgs_cardProgID			IS AP_CARD_PROGRAMS.card_program_id%TYPE;
SUBTYPE cardProgs_cardProgName			IS AP_CARD_PROGRAMS.card_program_name%TYPE;
SUBTYPE cardProgs_cardProgCurrCode		IS AP_CARD_PROGRAMS.card_program_currency_code%TYPE;
SUBTYPE cardProgs_vendorID			IS AP_CARD_PROGRAMS.vendor_id%TYPE;
SUBTYPE cardProgs_vendorSiteID			IS AP_CARD_PROGRAMS.vendor_site_id%TYPE;
SUBTYPE cardProgs_cardTypeLookupCode		IS AP_CARD_PROGRAMS.card_type_lookup_code%TYPE;
---------------------------------------------------------------------------------------------------

/* AP Card Profiles */
---------------------------------------------------------------------------------------------------
SUBTYPE cardProf_profileName			IS AP_CARD_PROFILES.profile_name%TYPE;
SUBTYPE cardProf_directAcctEntryFlag		IS AP_CARD_PROFILES.direct_acct_entry_flag%TYPE;
SUBTYPE cardProf_cardGLSetID			IS AP_CARD_PROFILES.card_gl_set_id%TYPE;
SUBTYPE cardProf_empNotifLookupCode		IS AP_CARD_PROFILES.emp_notification_lookup_code%TYPE;
SUBTYPE cardProf_mgrApprvlLookupCode		IS AP_CARD_PROFILES.mgr_approval_lookup_code%TYPE;
---------------------------------------------------------------------------------------------------

/* AP Cards */
---------------------------------------------------------------------------------------------------
SUBTYPE cards_employeeID			IS AP_CARDS.employee_id%TYPE;
SUBTYPE cards_cardId				IS AP_CARDS.card_id%TYPE;

TYPE CreditCardCategoryCursor 		IS REF CURSOR;
TYPE CreditCardTrxnCursor 		IS REF CURSOR;
TYPE CreditCardInfoCursor		IS REF CURSOR;
TYPE UnpaidCreditCardTrxnCursor 	IS REF CURSOR;
TYPE DisputedCCTrxnCursor		IS REF CURSOR;
TYPE UnsubmittedCCTrxnCursor		IS REF CURSOR;
TYPE DunningCCTrxnCursor		IS REF CURSOR;
TYPE DisputeCCTrxnCursor		IS REF CURSOR;--Notification Esc Prj
TYPE TotalCCTrxnCursor				IS REF CURSOR;

TYPE 	CCardTrxnInfoRec	IS RECORD (
	trxn_id			ccTrxn_trxID,
	trxn_date		ccTrxn_transDate,
	folio_type		ccTrxn_folioType,
	merchant_name		ccTrxn_merchantName1,
	merchant_city		ccTrxn_merchantCity,
	merchant_prov		ccTrxn_merchantProv,
	billed_amount		ccTrxn_billedAmount,
	posted_curr_code	ccTrxn_postedCurrCode,
	trxn_amount		ccTrxn_trxnAmount,
	card_id			ccTrxn_cardId,
	category		ccTrxn_category,
	card_prog_id		ccTrxn_cardProgID
);

--------------------------------------------------------------------------
FUNCTION GetCCardTrxnInfoForTrxnId(
		p_trxn_id	IN 	ccTrxn_trxID,
		p_trxn_info_rec OUT NOCOPY CCardTrxnInfoRec
) RETURN BOOLEAN;

------------------------------------------------------
-- Name: GetExpRptCCTrxnCategoryCursor
-- Desc: get the cursor of the credit card categories for the given expense report
-- Params: 	p_ReportHeaderID - the given report header id
--		p_category - the returned cursor
-- Returns:	true - succeeded
--		false - failed
-------------------------------------------------------
FUNCTION GetExpRptCCTrxnCategoryCursor(
	P_ReportHeaderID 	IN  	AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
	p_category	 OUT NOCOPY CreditCardCategoryCursor
) RETURN  BOOLEAN;
-------------------------------------------------------

-------------------------------------------------------
FUNCTION GetCreditCardTrxnCursor(
	p_user_id		IN	cards_employeeID,
	p_reimb_curr_code	IN	ccTrxn_billedCurrCode,
	p_card_prog_id		IN	cardProgs_cardProgID,
	p_card_id		IN	cards_cardId,
        p_paymentDueFrom        IN      varchar2,
	p_cc_trxn_cursor OUT NOCOPY CreditCardTrxnCursor
) RETURN BOOLEAN;
--------------------------------------------------------

--------------------------------------------------------
-- Name: GetCreditCardInfoCursor
-- Desc: get the cursor of the misc. credit card info for the given employee id and card type
-- Params: 	p_user_id - the given card user id
-- 		p_card_type - the given card type
-- 		p_cc_info_cursor - the returned ccard info cursor
-- Returns:	true - succeeded
--		false - failed
-------------------------------------------------------
FUNCTION GetCreditCardInfoCursor(
	p_user_id		IN	cards_employeeID,
	p_card_type		IN	cardProgs_cardTypeLookupCode DEFAULT 'TRAVEL',
	p_cc_info_cursor OUT NOCOPY CreditCardInfoCursor
)
RETURN BOOLEAN;
--------------------------------------------------------

--------------------------------------------------------------------------------
-- Name: GetUnpaidCreditCardTrxnCursor
-- Desc: get the cursor of the un-paid credit card trxns for the given card id, payment due code, trxn start date and end date
-- Params:	p_card_prog_id - the given card program id
--		p_payment_due_code -
FUNCTION GetUnpaidCreditCardTrxnCursor(
	p_unpaid_cctrxn_cursor OUT NOCOPY UnpaidCreditCardTrxnCursor,
	p_card_prog_id		IN	ccTrxn_cardProgID,
	p_payment_due_code	IN	VARCHAR2,
	p_start_date		IN	DATE DEFAULT NULL,
	p_end_date		IN	DATE DEFAULT NULL

) RETURN BOOLEAN;


--------------------------------------------------------------------------------
FUNCTION GetDisputedCcardTrxnCursor(
	 	p_cardProgramId		IN  ccTrxn_cardProgID,
		p_minimumAmount		IN  ccTrxn_billedAmount,
		p_employeeId		IN  cards_employeeID,
		p_billedStartDate	IN  ccTrxn_billedDate,
		p_billedEndDate		IN  ccTrxn_billedDate,
		p_disputed_cursor OUT NOCOPY DisputedCCTrxnCursor
) RETURN BOOLEAN;
---------------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION GetUnsubmittedCcardTrxnCursor(
	 	p_cardProgramId		IN  ccTrxn_cardProgID,
		p_employeeId		IN  cards_employeeID,
		p_billedStartDate	IN  ccTrxn_billedDate,
		p_billedEndDate		IN  ccTrxn_billedDate,
		p_minimumAmount		IN  ccTrxn_billedAmount,
		p_chargeType		IN  VARCHAR2,
		p_unsubmitted_cursor OUT NOCOPY UnsubmittedCCTrxnCursor
) RETURN BOOLEAN;
---------------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION GetTotalUnsubmittedCCCursor(
	 	p_cardProgramId		IN  ccTrxn_cardProgID,
		p_employeeId		IN  cards_employeeID,
		p_billedStartDate	IN  ccTrxn_billedDate,
		p_billedEndDate		IN  ccTrxn_billedDate,
		p_minimumAmount		IN  ccTrxn_billedAmount,
		p_chargeType		IN  VARCHAR2,
		p_total_cursor	 OUT NOCOPY UnsubmittedCCTrxnCursor
) RETURN BOOLEAN;
---------------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION GetDunningCcardTrxnCursor(
	 	p_cardProgramId		IN  ccTrxn_cardProgID,
		p_employeeId		IN  cards_employeeID,
		p_min_bucket		IN  NUMBER,
		p_max_bucket		IN  NUMBER,
		p_dunning_cursor OUT NOCOPY DunningCCTrxnCursor
) RETURN BOOLEAN;
---------------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION GetTotalCcardTrxnCursor(
	 	p_cardProgramId		IN  ccTrxn_cardProgID,
		p_employeeId		IN  cards_employeeID,
		p_min_bucket		IN  NUMBER,
		p_max_bucket		IN  NUMBER,
		p_total_cursor	 OUT NOCOPY TotalCCTrxnCursor
) RETURN BOOLEAN;
---------------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetCardProgramCurrencyCode(
	p_card_prog_id	IN	cardProgs_cardProgID,
	p_curr_code OUT NOCOPY cardProgs_cardProgCurrCode
) RETURN BOOLEAN;
-------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetCCTrxnCategory(
	p_trx_id 	IN 	ccTrxn_trxID,
	p_category OUT NOCOPY ccTrxn_category
) RETURN BOOLEAN;
-------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetCompPrepaidInvID(
	p_trx_id 		IN	ccTrxn_trxID,
	p_prepaid_invoice_id OUT NOCOPY AP_EXPENSE_REPORT_LINES.company_prepaid_invoice_id%TYPE)
	RETURN BOOLEAN;
-------------------------------------------------------------------

-------------------------------------------------------------------------------
FUNCTION GetExpensedAmt(
	p_id 	IN 	ccTrxn_trxID,
	p_amt OUT NOCOPY ccTrxn_expensedAmt
) RETURN  BOOLEAN;
--------------------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION SetCCTrxnReportHeaderID(
	p_report_header_id 	IN NUMBER,
	p_new_report_id	  	IN NUMBER
)  RETURN BOOLEAN;
-------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION GetCardProgramInfo(
	p_card_prog_id		IN	cardProgs_cardProgID,
	p_vendor_id	 OUT NOCOPY cardProgs_vendorID,
	p_vendor_site_id OUT NOCOPY cardProgs_vendorSiteID,
	p_invoice_curr_code OUT NOCOPY cardProgs_cardProgCurrCode
) RETURN BOOLEAN;
--------------------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetVendorIDs(
	p_report_header_id 	IN  ccTrxn_headerID,
	p_vendor_id 	 OUT NOCOPY cardProgs_vendorID,
	p_vendor_site_id OUT NOCOPY cardProgs_vendorSiteID )
RETURN BOOLEAN;
-------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetCardProgramName(
	p_cardProgramID 	IN	cardProgs_cardProgID,
	p_cardProgramName OUT NOCOPY cardProgs_cardProgName)
RETURN BOOLEAN;
-------------------------------------------------------------------


-------------------------------------------------------------------
FUNCTION GetCardProgramId(
	p_cardProgramName 	IN	cardProgs_cardProgName,
	p_cardProgramID OUT NOCOPY cardProgs_cardProgID)
RETURN BOOLEAN;
-------------------------------------------------------------------


--------------------------------------------------------------------------------
FUNCTION CompanyHasTravelCardProgram(
	p_companyHasCardProgram OUT NOCOPY VARCHAR2 )
RETURN boolean;
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
FUNCTION UserHasCreditCard(
	p_userId 		IN	cards_employeeID,
	p_userHasCreditCard OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION SetCCPolicyShortpaidReportID(
	p_orig_expense_report_id	IN 	AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
        p_new_expense_report_id  	IN 	ccTrxn_headerID )
RETURN BOOLEAN;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION SetCCReceiptShortpaidReportID(p_orig_expense_report_id IN AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
                                     p_new_expense_report_id  	IN ccTrxn_headerID)
RETURN BOOLEAN;
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
FUNCTION UpdateExpensedAmount(
	p_trxn_id		IN	ccTrxn_trxID,
	p_report_id		IN	ccTrxn_headerID,
	p_expensed_amount	IN	ccTrxn_expensedAmt
) RETURN BOOLEAN;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION ResetCCLines(
	p_report_header_id	IN AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE)
RETURN BOOLEAN;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION SetStatus(
	p_report_header_id 	IN ccTrxn_headerID,
        p_status 		IN ccTrxn_expenseStatus
) RETURN BOOLEAN;
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
FUNCTION ResetCCMgrRejectedCCLines(
	p_report_header_id	IN AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE
) RETURN BOOLEAN;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION ResetPersonalTrxns(
	p_reportID	IN ccTrxn_headerID
) RETURN BOOLEAN;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
FUNCTION ResetMgrRejectPersonalTrxns(
	p_report_header_id	IN AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE
) RETURN BOOLEAN;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION SetCCTrxnInvoiceId(
	p_card_trxn_id	IN ccTrxn_trxID,
	p_invoice_id	IN ccTrxn_companyPrepaidInvID
) RETURN BOOLEAN;


--------------------------------------------------------------------------------
FUNCTION UpdateCCardCategory(
	p_trxn_id	IN	ccTrxn_trxID,
	p_category	IN	ccTrxn_category
) RETURN BOOLEAN;

------------------------------------------------------------------------------
FUNCTION GetExpensedAmountForTrxnId(
		p_trxn_id	IN	ccTrxn_trxID,
		p_exp_amount OUT NOCOPY ccTrxn_expensedAmt
) RETURN BOOLEAN;

------------------------------------------------------------------------------
FUNCTION isMultPayments(
        p_cardProgramID 	IN  	cardProgs_cardProgID,
        p_card_id               IN      cards_cardId
) RETURN BOOLEAN;

------------------------------------------------------------------------------
FUNCTION getPaymentDueCodeFromTrxn(
        p_trxn_id       	IN      ccTrxn_trxID)
RETURN  VARCHAR2;
------------------------------------------------------------------------------

FUNCTION getFirstLineWithCCTrxId(
        p_expLines  		IN 	AP_WEB_DFLEX_PKG.ExpReportLines_A,
        p_personalReceipts  	IN 	AP_WEB_DFLEX_PKG.ExpReportLines_A)
RETURN  NUMBER;
------------------------------------------------------------------------------

------------------------------------------------------------------------------
PROCEDURE getAlertsForHomepage(
        p_employee_id        IN 	cards_employeeID,
        p_cc_flag           OUT NOCOPY     VARCHAR2,
        p_num_days          OUT NOCOPY     NUMBER,
        p_num_old           OUT NOCOPY     NUMBER,
        p_num_disputed      OUT NOCOPY     NUMBER,
        p_num_credits       OUT NOCOPY     NUMBER,
        p_delegate_flag     OUT NOCOPY     VARCHAR2);
------------------------------------------------------------------------------

--Amulya Mishra : Notification Esc Project

FUNCTION GetDisputeCcardTrxnCursor(
	 	p_cardProgramId		IN  ccTrxn_cardProgID,
		p_employeeId		IN  cards_employeeID,
		p_min_bucket		IN  NUMBER,
		p_max_bucket		IN  NUMBER,
    p_grace_days    IN NUMBER,
		p_dispute_cursor OUT NOCOPY DisputeCCTrxnCursor
) RETURN BOOLEAN;
------------------------------------------------------------------------------

--Amulya Mishra : Notification Esc Project

FUNCTION GetTotalCreditCardAmount(
	 	p_cardProgramId		IN  ccTrxn_cardProgID,
		p_employeeId		IN  cards_employeeID,
    p_totalAmount   OUT NOCOPY NUMBER
) RETURN BOOLEAN;
---------------------------------------------------------------------------

--Amulya Mishra : Notification Esc Project

FUNCTION GetTotalNumberOutstanding(
                p_cardProgramId         IN  ccTrxn_cardProgID,
                p_employeeId            IN  cards_employeeID,
                p_min_bucket            IN  NUMBER,
                p_max_bucket            IN  NUMBER,
                p_total_outstanding   OUT NOCOPY NUMBER,
                p_total_amt_outstanding   OUT NOCOPY NUMBER
) RETURN BOOLEAN ;
-----------------------------------------------------------------------------

--Amulya Mishra : Notification Esc Project

FUNCTION GetTotalNumberDispute(
                p_cardProgramId         IN  ccTrxn_cardProgID,
                p_employeeId            IN  cards_employeeID,
                p_min_bucket            IN  NUMBER,
                p_max_bucket            IN  NUMBER,
                p_grace_days            IN  NUMBER,
                p_total_dispute   OUT NOCOPY NUMBER,
                p_total_amt_dispute OUT NOCOPY NUMBER
) RETURN BOOLEAN ;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
FUNCTION GetOldestAvailPostedDate(
                p_cardProgramId         IN  ccTrxn_cardProgID,
                p_cardId                IN  cards_cardId,
                p_paymentDueFromCode    IN  ccTrxn_paymentDueFromCode,
                p_reimb_curr_code	IN  ccTrxn_billedCurrCode,
                p_report_header_id	IN  ccTrxn_headerID
) RETURN DATE ;
-----------------------------------------------------------------------------


--AMulya Mishra : Bug 3562287
----------------------------------------------------------------------------
FUNCTION GetLocation(
               merchant_city            IN  VARCHAR2,
               merchant_province_state  IN  VARCHAR2
) RETURN VARCHAR2;
----------------------------------------------------------------------------

---------------------------------------------------------------------------
FUNCTION isCreditCardEnabled(
      p_employee_id       IN    cards_employeeID,
      p_user_id           IN    NUMBER  DEFAULT NULL)
RETURN VARCHAR2;
----------------------------------------------------------------------------

END AP_WEB_DB_CCARD_PKG;

 

/
