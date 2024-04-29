--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_CCARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_CCARD_PKG" AS
/* $Header: apwdbccb.pls 120.58.12010000.2 2010/05/28 07:53:30 rveliche ship $ */
/* Credit Cards */

--------------------------------------------------------------------------------
FUNCTION GetExpRptCCTrxnCategoryCursor(
	P_ReportHeaderID 	IN  	AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
	p_category	 OUT NOCOPY CreditCardCategoryCursor
) RETURN  BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
OPEN p_category FOR
    SELECT ACCT.CATEGORY
    FROM AP_CREDIT_CARD_TRXNS ACCT,
	 AP_EXPENSE_REPORT_LINES AERL
    WHERE AERL.REPORT_HEADER_ID = P_ReportHeaderID
    AND ACCT.TRX_ID = AERL.CREDIT_CARD_TRX_ID;

    RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         RETURN FALSE;

    WHEN OTHERS THEN
	AP_WEB_DB_UTIL_PKG.RaiseException( 'GetExpRptCCTrxnCategoryCursor' );
    	APP_EXCEPTION.RAISE_EXCEPTION;
    	return FALSE;

END GetExpRptCCTrxnCategoryCursor;

--------------------------------------------------------------------------------
FUNCTION GetCreditCardTrxnCursor(
	p_user_id		IN	cards_employeeID,
	p_reimb_curr_code	IN	ccTrxn_billedCurrCode,
	p_card_prog_id		IN	cardProgs_cardProgID,
	p_card_id		IN	cards_cardId,
        p_paymentDueFrom        IN      varchar2,
	p_cc_trxn_cursor OUT NOCOPY CreditCardTrxnCursor
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
-- Added condition for paymentDueFrom so that Corresponsding TRXNS
-- will be fetched if by any chance multiple payments exists.

 OPEN p_cc_trxn_cursor FOR
    Select trx_id,
           transaction_date,
	   folio_type,  --shuh
           merchant_name1,
           merchant_city,
           merchant_province_state,
           billed_amount,
           posted_currency_code,
           transaction_amount,
           cc.card_id,
           nvl(cc.category, c_business)
    FROM ap_credit_card_trxns cc,
         ap_cards card
    WHERE cc.validate_code = 'Y'
      AND cc.payment_flag <> 'Y'
      AND cc.billed_amount is not null
      AND nvl(cc.expensed_amount,0) = 0
      AND nvl(cc.category,'BUSINESS') <> 'DEACTIVATED'
      AND cc.billed_currency_code = p_reimb_curr_code
      AND cc.card_id = card.card_id
      AND cc.card_program_id = card.card_program_id
      AND card.employee_id = p_user_id
      AND card.card_program_id = p_card_prog_id
      AND card.card_id = p_card_id
      AND cc.payment_due_from_code = p_paymentDueFrom
    ORDER BY cc.transaction_date;

 	RETURN TRUE;

EXCEPTION
      	WHEN NO_DATA_FOUND THEN
        	RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException(	'GetCreditCardTrxnCursor' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetCreditCardTrxnCursor;

-------------------------------------------------------------------------------
FUNCTION GetCreditCardInfoCursor(
	p_user_id		IN	cards_employeeID,
	p_card_type		IN	cardProgs_cardTypeLookupCode,
	p_cc_info_cursor OUT NOCOPY CreditCardInfoCursor
)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
            OPEN p_cc_info_cursor FOR
                SELECT  DISTINCT
                    cp.card_program_id,
                    cp.card_program_name,
                    card.card_id,
                    trxn.payment_due_from_code
                FROM    ap_card_programs cp,
                        ap_cards card,
                        ap_credit_card_trxns trxn
                WHERE   card.employee_id = p_user_id
                AND     card.card_program_id = cp.card_program_id
                AND     cp.card_type_lookup_code = p_card_type
                AND     trxn.CARD_PROGRAM_ID = card.CARD_PROGRAM_ID
                AND     trxn.CARD_ID = card.CARD_ID
             UNION
                SELECT  cp.card_program_id,
                        cp.card_program_name,
                        card.card_id,
                        cp.payment_due_from_code
                FROM    ap_card_programs cp,
                        ap_cards card
                WHERE   card.employee_id = p_user_id
                AND     card.card_program_id = cp.card_program_id
                AND     cp.card_type_lookup_code = p_card_type;

    	RETURN TRUE;

EXCEPTION
      	WHEN NO_DATA_FOUND THEN
        	RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCreditCardInfoCursor' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetCreditCardInfoCursor;

--------------------------------------------------------------------------------
FUNCTION GetUnpaidCreditCardTrxnCursor(
	p_unpaid_ccTrxn_cursor OUT NOCOPY UnpaidCreditCardTrxnCursor,
	p_card_prog_id		IN	ccTrxn_cardProgID,
	p_payment_due_code	IN	VARCHAR2,
	p_start_date		IN	DATE,
	p_end_date		IN	DATE
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
	OPEN p_unpaid_ccTrxn_cursor FOR
	SELECT  DISTINCT
		TRX_ID,
		TRANSACTION_DATE,    --3028505
		BILLED_AMOUNT,
		cc.CARD_ID THE_CARD_ID,
                emp.full_name,
                emp.person_id
	FROM	AP_CREDIT_CARD_TRXNS cc,
		AP_CARDS card,
                per_people_x emp
	WHERE   cc.CARD_PROGRAM_ID = p_card_prog_id
	  AND   cc.VALIDATE_CODE = 'Y'
          AND   cc.payment_flag <> 'Y'
	  AND	cc.COMPANY_PREPAID_INVOICE_ID IS NULL
	  AND	cc.BILLED_AMOUNT IS NOT NULL
	  AND	cc.CARD_ID = card.CARD_ID
	  AND	(nvl(cc.billed_date, cc.posted_date) BETWEEN
				nvl(p_start_date, nvl(cc.billed_date, cc.posted_date) - 1) AND
				nvl(p_end_date, nvl(cc.billed_date, cc.posted_date) + 1)
			)
	  AND	cc.payment_due_from_code='COMPANY'
          AND   card.employee_id = emp.person_id
          AND nvl(cc.category,'BUSINESS') <> 'DEACTIVATED'
     ORDER BY
		cc.transaction_date; 	--3028505

     RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
 		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetUnpaidCreditCardTrxnCursor' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;
END GetUnpaidCreditCardTrxnCursor;

---------------------------------------------------------------------------
FUNCTION GetDisputedCcardTrxnCursor(
	 	p_cardProgramId		IN  ccTrxn_cardProgID,
		p_minimumAmount		IN  ccTrxn_billedAmount,
		p_employeeId		IN  cards_employeeID,
		p_billedStartDate	IN  ccTrxn_billedDate,
		p_billedEndDate		IN  ccTrxn_billedDate,
		p_disputed_cursor OUT NOCOPY DisputedCCTrxnCursor
) RETURN BOOLEAN IS
---------------------------------------------------------------------------
BEGIN
OPEN p_disputed_cursor FOR
       SELECT transaction_date, merchant_name1, billed_amount, billed_currency_code
       FROM
       ap_credit_card_trxns cct,
       ap_cards_all ac
       WHERE
       cct.card_program_id = p_cardProgramId
       and cct.validate_code = 'Y'
       and cct.payment_flag <> 'Y'
       and nvl(cct.expensed_amount,0) = 0
       and nvl(cct.category,c_business) = 'DISPUTED'
       and ac.card_program_id = cct.card_program_id
       and ac.card_id = cct.card_id
       and nvl(cct.billed_date, cct.posted_date) between
           nvl(p_billedStartDate, nvl(cct.billed_date, cct.posted_date)-1) and
           nvl(p_billedEndDate, nvl(cct.billed_date, cct.posted_date)+1)
       and cct.billed_amount > p_minimumAmount
       and ac.employee_id = p_employeeId
       order by cct.transaction_date;

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetDisputedCcardTrxnCursor' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetDisputedCcardTrxnCursor;

---------------------------------------------------------------------------
FUNCTION GetUnsubmittedCcardTrxnCursor(
	 	p_cardProgramId		IN  ccTrxn_cardProgID,
		p_employeeId		IN  cards_employeeID,
		p_billedStartDate	IN  ccTrxn_billedDate,
		p_billedEndDate		IN  ccTrxn_billedDate,
		p_minimumAmount		IN  ccTrxn_billedAmount,
		p_chargeType		IN  VARCHAR2,
		p_unsubmitted_cursor OUT NOCOPY UnsubmittedCCTrxnCursor
) RETURN BOOLEAN IS
---------------------------------------------------------------------------
BEGIN
-- 3130923 remove ap_expense_report_lines from the 1st select
-- join erh.report_header_id = cct.report_header_id
OPEN p_unsubmitted_cursor FOR
       SELECT 	distinct transaction_date,
		merchant_name1,
		billed_amount,
		billed_currency_code,
		erh.invoice_num,
		AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode
                                       (erh.source,erh.workflow_approved_flag,
                                        erh.report_header_id), --2615448
		cct.trx_id              -- Bug 3241358
       FROM
       ap_credit_card_trxns 	cct,
       ap_cards 		ac,
       ap_expense_report_headers erh
       WHERE
       cct.card_program_id = p_cardProgramId
       and cct.validate_code = 'Y'
       and cct.payment_flag <> 'Y'
       and cct.expensed_amount <> 0
       and nvl(cct.category,c_business) NOT IN
              ( 'DISPUTED', 'PERSONAL' , 'MATCHED' ,'CREDIT','DEACTIVATED') -- 3234232 , --3307864
       and ac.card_program_id = cct.card_program_id
       and ac.card_id = cct.card_id
       and nvl(cct.billed_date, cct.posted_date) between
           nvl(p_billedStartDate, nvl(cct.billed_date, cct.posted_date)-1) and
           nvl(p_billedEndDate, nvl(cct.billed_date, cct.posted_date)+1)
       and abs(cct.billed_amount) > nvl(p_minimumAmount,0)
       and erh.report_header_id = cct.report_header_id --3130923
       and ac.employee_id = erh.employee_id --3130923
       and AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode
                                 (erh.source,erh.workflow_approved_flag,
                                  erh.report_header_id) in
          ('EMPAPPR', 'RESOLUTN','RETURNED','REJECTED','WITHDRAWN', 'SAVED') --2615448
       and ac.employee_id = p_employeeId
       and rownum < 41
     UNION ALL
       SELECT 	transaction_date,
		merchant_name1,
		billed_amount,
		billed_currency_code,
		null,
		'UNUSED',
		cct.trx_id              -- Bug 3241358
       FROM
       ap_credit_card_trxns 	cct,
       ap_cards 		ac
       WHERE
       cct.card_program_id = p_cardProgramId
       and cct.validate_code = 'Y'
       and cct.payment_flag <> 'Y'
       and nvl(cct.expensed_amount,0) = 0
       and nvl(cct.category,c_business) NOT IN ('DISPUTED','MATCHED','CREDIT','DEACTIVATED') --Bug 3307864
       and cct.report_header_id is NULL
       and ac.card_program_id = cct.card_program_id
       and ac.card_id = cct.card_id
       and nvl(cct.billed_date, cct.posted_date) between
           nvl(p_billedStartDate, nvl(cct.billed_date, cct.posted_date)-1) and
           nvl(p_billedEndDate, nvl(cct.billed_date, cct.posted_date)+1)
       and abs(cct.billed_amount) > nvl(p_minimumAmount,0)
       and ac.employee_id = p_employeeId
       and rownum < 41
       and p_chargeType = 'UNUSED'
     UNION ALL
       SELECT 	distinct transaction_date,
		merchant_name1,
		billed_amount,
		billed_currency_code,
		erh.invoice_num,
		AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode
                                       (erh.source,erh.workflow_approved_flag,
                                        erh.report_header_id), --2615448
		cct.trx_id              -- Bug 3241358
       FROM
       ap_credit_card_trxns 	cct,
       ap_cards 		ac,
       ap_expense_report_headers erh
       WHERE
       cct.card_program_id = p_cardProgramId
       and cct.validate_code = 'Y'
       and cct.payment_flag <> 'Y'
       and cct.expensed_amount <> 0
       and nvl(cct.category,c_business) = 'PERSONAL'
       and ac.card_program_id = cct.card_program_id
       and ac.card_id = cct.card_id
       and nvl(cct.billed_date, cct.posted_date) between
           nvl(p_billedStartDate, nvl(cct.billed_date, cct.posted_date)-1) and
           nvl(p_billedEndDate, nvl(cct.billed_date, cct.posted_date)+1)
       and abs(cct.billed_amount) > nvl(p_minimumAmount,0)
       and erh.report_header_id = cct.report_header_id
       and ac.employee_id = erh.employee_id --3130923
       and AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode
                                 (erh.source,erh.workflow_approved_flag,
                                  erh.report_header_id) in
          ('EMPAPPR', 'RESOLUTN','RETURNED','REJECTED','WITHDRAWN', 'SAVED') --2615448
       and ac.employee_id = p_employeeId
       and rownum < 41;
       --order by cct.transaction_date;

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetUnsubmittedCcardTrxnCursor' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetUnsubmittedCcardTrxnCursor;

---------------------------------------------------------------------------
FUNCTION GetTotalUnsubmittedCCCursor(
	 	p_cardProgramId		IN  ccTrxn_cardProgID,
		p_employeeId		IN  cards_employeeID,
		p_billedStartDate	IN  ccTrxn_billedDate,
		p_billedEndDate		IN  ccTrxn_billedDate,
		p_minimumAmount		IN  ccTrxn_billedAmount,
		p_chargeType		IN  VARCHAR2,
		p_total_cursor	 OUT NOCOPY UnsubmittedCCTrxnCursor
) RETURN BOOLEAN IS
---------------------------------------------------------------------------
BEGIN
-- 3130923 remove ap_expense_report_lines from the 1st select
-- join erh.report_header_id = cct.report_header_id
OPEN p_total_cursor FOR
       SELECT distinct 	transaction_date,
		merchant_name1,
		billed_amount,
		billed_currency_code,
		erh.invoice_num,
                AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode
                               (erh.source,erh.workflow_approved_flag,
                                erh.report_header_id), --2615448
		cct.trx_id              -- Bug 3241358
       FROM
       ap_credit_card_trxns 	cct,
       ap_cards 		ac,
       ap_expense_report_headers erh
       WHERE
       cct.card_program_id = p_cardProgramId
       and cct.validate_code = 'Y'
       and cct.payment_flag <> 'Y'
       and cct.expensed_amount <> 0
       and nvl(cct.category,c_business) NOT IN
                    ('DISPUTED','CREDIT', 'MATCHED','PERSONAL','DEACTIVATED') --Bug 3307864
       and ac.card_program_id = cct.card_program_id
       and ac.card_id = cct.card_id
       and nvl(cct.billed_date, cct.posted_date) between
           nvl(p_billedStartDate, nvl(cct.billed_date, cct.posted_date)-1) and
           nvl(p_billedEndDate, nvl(cct.billed_date, cct.posted_date)+1)
       and abs(cct.billed_amount) > nvl(p_minimumAmount,0)
       and erh.report_header_id = cct.report_header_id --3130923
       and ac.employee_id = erh.employee_id --3130923
       and AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(erh.source,erh.workflow_approved_flag,
                                                    erh.report_header_id) in
          ('EMPAPPR', 'RESOLUTN','RETURNED','REJECTED','WITHDRAWN', 'SAVED')  --2615448
       and ac.employee_id = p_employeeId
     UNION ALL
       SELECT 	transaction_date,
		merchant_name1,
		billed_amount,
		billed_currency_code,
		null,
		'UNUSED',
		cct.trx_id              -- Bug 3241358
       FROM
       ap_credit_card_trxns 	cct,
       ap_cards 		ac
       WHERE
       cct.card_program_id = p_cardProgramId
       and cct.validate_code = 'Y'
       and cct.payment_flag <> 'Y'
       and nvl(cct.expensed_amount,0) = 0
       and nvl(cct.category,c_business) NOT IN ( 'DISPUTED','CREDIT','MATCHED','DEACTIVATED') --Bug 3307864
       and cct.report_header_id is NULL
       and ac.card_program_id = cct.card_program_id
       and ac.card_id = cct.card_id
       and nvl(cct.billed_date, cct.posted_date) between
           nvl(p_billedStartDate, nvl(cct.billed_date, cct.posted_date)-1) and
           nvl(p_billedEndDate, nvl(cct.billed_date, cct.posted_date)+1)
       and abs(cct.billed_amount) > nvl(p_minimumAmount,0)
       and ac.employee_id = p_employeeId
       and p_chargeType = 'UNUSED'
     UNION ALL
       SELECT distinct 	transaction_date,
		merchant_name1,
		billed_amount,
		billed_currency_code,
		erh.invoice_num,
                AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode
                               (erh.source,erh.workflow_approved_flag,
                                erh.report_header_id), --2615448
		cct.trx_id              -- Bug 3241358
       FROM
       ap_credit_card_trxns 	cct,
       ap_cards 		ac,
       ap_expense_report_headers erh
       WHERE
       cct.card_program_id = p_cardProgramId
       and cct.validate_code = 'Y'
       and cct.payment_flag <> 'Y'
       and cct.expensed_amount <> 0
       and nvl(cct.category,c_business) = 'PERSONAL'
       and ac.card_program_id = cct.card_program_id
       and ac.card_id = cct.card_id
       and nvl(cct.billed_date, cct.posted_date) between
           nvl(p_billedStartDate, nvl(cct.billed_date, cct.posted_date)-1) and
           nvl(p_billedEndDate, nvl(cct.billed_date, cct.posted_date)+1)
       and abs(cct.billed_amount) > nvl(p_minimumAmount,0)
       and erh.report_header_id = cct.report_header_id
       and ac.employee_id = erh.employee_id --3130923
       and AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(erh.source,erh.workflow_approved_flag,
                                                    erh.report_header_id) in
          ('EMPAPPR', 'RESOLUTN','RETURNED','REJECTED','WITHDRAWN', 'SAVED')  --2615448
       and ac.employee_id = p_employeeId;
       --order by cct.transaction_date;

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetTotalUnsubmittedCCCursor' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetTotalUnsubmittedCCCursor;


---------------------------------------------------------------------------
FUNCTION GetDunningCcardTrxnCursor(
	 	p_cardProgramId		IN  ccTrxn_cardProgID,
		p_employeeId		IN  cards_employeeID,
		p_min_bucket		IN  NUMBER,
		p_max_bucket		IN  NUMBER,
		p_dunning_cursor OUT NOCOPY DunningCCTrxnCursor
) RETURN BOOLEAN IS
---------------------------------------------------------------------------
BEGIN
/*Bug 2625495: Added the second UNION for personal Credit Card
		Expenses.For testing we need to comment out
		row num checking.
*/
OPEN p_dunning_cursor FOR
       SELECT distinct 	transaction_date,
		merchant_name1,
		billed_amount,
		billed_currency_code,
                cct.posted_currency_code, --3339380
		erh.invoice_num,
                NVL(AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode
                                           (erh.source,erh.workflow_approved_flag,
                                            erh.report_header_id),'UNUSED'), --2615505
		nvl(cct.billed_date, cct.posted_date) billed_date,
	        cct.posted_date, --Notification Esc
	        cct.transaction_amount,--Notification Esc
	        AP_WEB_DB_CCARD_PKG.GETLOCATION(cct.merchant_city , cct.merchant_province_state),  --Notification Esc
		cct.trx_id              -- Bug 3241358
       FROM
       ap_credit_card_trxns 		cct,
       ap_cards 			ac,
       ap_expense_report_headers 	erh
       WHERE
       cct.card_program_id = p_cardProgramId
       and cct.validate_code = 'Y'
       and cct.payment_flag <> 'Y'
       and nvl(cct.category,c_business) NOT IN ( 'DISPUTED','PERSONAL' ,'MATCHED','CREDIT','DEACTIVATED')
       and cct.expensed_amount <> 0
       and ac.card_program_id = cct.card_program_id
       and ac.card_id = cct.card_id
       and trunc(sysdate) - cct.posted_date between p_min_bucket and p_max_bucket
       and erh.report_header_id = cct.report_header_id
       and AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(erh.source,erh.workflow_approved_flag,
                                            erh.report_header_id)
		in ('SAVED','REJECTED', 'RESOLUTN','EMPAPPR','RETURNED','WITHDRAWN')
       and ac.employee_id = p_employeeId
       and rownum < 41
       --order by cct.transaction_date;
   UNION ALL
       SELECT distinct  transaction_date,
                merchant_name1,
                billed_amount,
                billed_currency_code,
                cct.posted_currency_code, --3339380
                erh.invoice_num,
                AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode
                                           (erh.source,erh.workflow_approved_flag,
                                            erh.report_header_id),
                nvl(cct.billed_date, cct.posted_date) billed_date,
                cct.posted_date, --Notification Esc
                cct.transaction_amount,--Notification Esc
                AP_WEB_DB_CCARD_PKG.GETLOCATION(cct.merchant_city , cct.merchant_province_state),   --Notification Esc
		cct.trx_id              -- Bug 3241358
       FROM
       ap_credit_card_trxns             cct,
       ap_cards                         ac,
       ap_expense_report_headers        erh
       WHERE
       cct.card_program_id = p_cardProgramId
       and cct.validate_code = 'Y'
       and cct.payment_flag <> 'Y'
       and nvl(cct.category,c_business) = 'PERSONAL'
       and cct.expensed_amount <> 0
       and ac.card_program_id = cct.card_program_id
       and ac.card_id = cct.card_id
       and trunc(sysdate) - cct.posted_date between p_min_bucket and p_max_bucket
       and erh.report_header_id = cct.report_header_id
       and NVL(AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(erh.source,erh.workflow_approved_flag,
                                            erh.report_header_id),'UNUSED')
                in ('SAVED','REJECTED', 'RESOLUTN','EMPAPPR','RETURNED','WITHDRAWN')
       and ac.employee_id = p_employeeId
       and rownum < 41
     UNION ALL
       SELECT   distinct transaction_date,
                merchant_name1,
                billed_amount,
                billed_currency_code,
                cct.posted_currency_code, --3339380
                null,
                'UNUSED',
                nvl(cct.billed_date, cct.posted_date) billed_date,
	        cct.posted_date, --Notification Esc
	        cct.transaction_amount,--Notification Esc
	        AP_WEB_DB_CCARD_PKG.GETLOCATION(cct.merchant_city , cct.merchant_province_state),  --Notification Esc
                cct.trx_id              -- Bug 3241358
       FROM
       ap_credit_card_trxns     cct,
       ap_cards                 ac
       WHERE
       cct.card_program_id = p_cardProgramId
       and cct.validate_code = 'Y'
       and cct.payment_flag <> 'Y'
       and nvl(cct.expensed_amount,0) = 0
       and nvl(cct.category,'BUSINESS') <> 'DEACTIVATED'
       and cct.report_header_id is null
       and ac.card_program_id = cct.card_program_id
       and ac.card_id = cct.card_id
       and trunc(sysdate) - nvl(cct.billed_date, cct.posted_date) between p_min_bucket and p_max_bucket
       and ac.employee_id = p_employeeId
       and rownum < 41;


	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetDunningCcardTrxnCursor' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetDunningCcardTrxnCursor;


---------------------------------------------------------------------------
FUNCTION GetTotalCcardTrxnCursor(
	 	p_cardProgramId		IN  ccTrxn_cardProgID,
		p_employeeId		IN  cards_employeeID,
		p_min_bucket		IN  NUMBER,
		p_max_bucket		IN  NUMBER,
		p_total_cursor	 OUT NOCOPY TotalCCTrxnCursor
) RETURN BOOLEAN IS
---------------------------------------------------------------------------
BEGIN

OPEN p_total_cursor FOR
       SELECT distinct 	transaction_date,
		merchant_name1,
		billed_amount,
		billed_currency_code,
		erh.invoice_num,
                NVL(AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode
                                           (erh.source,erh.workflow_approved_flag,
                                            erh.report_header_id),'UNUSED'), --2615505
		nvl(cct.billed_date, cct.posted_date) billed_date,
		cct.trx_id              -- Bug 3241358
       FROM
       ap_credit_card_trxns 		cct,
       ap_cards 			ac,
       ap_expense_report_headers 	erh
       WHERE
       cct.card_program_id = p_cardProgramId
       and cct.validate_code = 'Y'
       and cct.payment_flag <> 'Y'
       and nvl(cct.category,c_business) NOT IN
              ('DISPUTED' , 'CREDIT' , 'MATCHED','PERSONAL','DEACTIVATED') --Bug 3307864
       and ac.card_program_id = cct.card_program_id
       and ac.card_id = cct.card_id
       and trunc(sysdate) - nvl(cct.billed_date, cct.posted_date) between p_min_bucket and p_max_bucket
       and erh.report_header_id = cct.report_header_id
       and cct.expensed_amount <> 0
       and erh.report_header_id = cct.report_header_id
       and AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(erh.source,erh.workflow_approved_flag,
                                            erh.report_header_id)
		in ('SAVED','REJECTED', 'RESOLUTN','EMPAPPR','RETURNED','WITHDRAWN')
       and ac.employee_id = p_employeeId
   UNION ALL
       SELECT  DISTINCT  transaction_date,
                merchant_name1,
                billed_amount,
                billed_currency_code,
                erh.invoice_num,
                AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode
                                           (erh.source,erh.workflow_approved_flag,
                                            erh.report_header_id),
                nvl(cct.billed_date, cct.posted_date) billed_date,
                cct.trx_id
       FROM
       ap_credit_card_trxns             cct,
       ap_cards                         ac,
       ap_expense_report_headers        erh
       WHERE
       cct.card_program_id = p_cardProgramId
       and cct.validate_code = 'Y'
       and cct.payment_flag <> 'Y'
       and nvl(cct.category,c_business) = 'PERSONAL'
       and cct.expensed_amount <> 0
       and ac.card_program_id = cct.card_program_id
       and ac.card_id = cct.card_id
       and trunc(sysdate) - nvl(cct.billed_date, cct.posted_date) between p_min_bucket and p_max_bucket
       and erh.report_header_id = cct.report_header_id
       and NVL(AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(erh.source,erh.workflow_approved_flag,
                                            erh.report_header_id),'UNUSED')
                in ('SAVED','REJECTED', 'RESOLUTN','EMPAPPR','RETURNED','WITHDRAWN')
       and ac.employee_id = p_employeeId
     UNION ALL
       SELECT   distinct transaction_date,
                merchant_name1,
                billed_amount,
                billed_currency_code,
                null,
                'UNUSED',
                nvl(cct.billed_date, cct.posted_date) billed_date,
                cct.trx_id              -- Bug 3241358
       FROM
       ap_credit_card_trxns     cct,
       ap_cards                 ac
       WHERE
       cct.card_program_id = p_cardProgramId
       and cct.validate_code = 'Y'
       and cct.payment_flag <> 'Y'
       and nvl(cct.expensed_amount,0) = 0
       and nvl(cct.category,'BUSINESS') <> 'DEACTIVATED'
       and cct.report_header_id is null
       and ac.card_program_id = cct.card_program_id
       and ac.card_id = cct.card_id
       and trunc(sysdate) - nvl(cct.billed_date, cct.posted_date) between p_min_bucket and p_max_bucket
       and ac.employee_id = p_employeeId;

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetTotalCcardTrxnCursor' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetTotalCcardTrxnCursor;


-------------------------------------------------------------------
FUNCTION GetCardProgramCurrencyCode(
	p_card_prog_id	IN	cardProgs_cardProgID,
	p_curr_code OUT NOCOPY cardProgs_cardProgCurrCode
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN

    SELECT	card_program_currency_code
    INTO 	p_curr_code
    FROM 	ap_card_programs
    WHERE 	card_program_id = p_card_prog_id;

    RETURN TRUE;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCardProgramCurrencyCode' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetCardProgramCurrencyCode;


-------------------------------------------------------------------
FUNCTION GetCCTrxnCategory(
	p_trx_id 	IN	ccTrxn_trxID,
	p_category OUT NOCOPY ccTrxn_category )
	RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  	SELECT category
  	INTO   p_category
  	FROM   ap_credit_card_trxns
  	WHERE  trx_id = p_trx_id;

  	RETURN TRUE;

EXCEPTION
  	WHEN NO_DATA_FOUND THEN
    		RETURN FALSE;
	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCCTrxnCategory' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;


END GetCCTrxnCategory;


-------------------------------------------------------------------
FUNCTION GetCompPrepaidInvID(
	p_trx_id 		IN	ccTrxn_trxID,
	p_prepaid_invoice_id OUT NOCOPY AP_EXPENSE_REPORT_LINES.company_prepaid_invoice_id%TYPE)
	RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  p_prepaid_invoice_id := NULL;

  IF (p_trx_id IS NOT NULL) THEN
  	SELECT company_prepaid_invoice_id
  	INTO   p_prepaid_invoice_id
  	FROM   ap_credit_card_trxns
  	WHERE  trx_id = p_trx_id;
  END IF;

  RETURN TRUE;

EXCEPTION
  	WHEN NO_DATA_FOUND THEN
    		RETURN FALSE;
	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCompPrepaidInvID' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;


END GetCompPrepaidInvID;


-------------------------------------------------------------------------------
FUNCTION GetExpensedAmt(
	p_id 	IN 	ccTrxn_trxID,
	p_amt OUT NOCOPY ccTrxn_expensedAmt )
	RETURN  BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
    	select 	expensed_amount
	into 	p_amt
	from 	ap_credit_card_trxns
    	where 	trx_id = p_id;

    	return TRUE;

EXCEPTION
  	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetExpensedAmt' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetExpensedAmt;


--------------------------------------------------------------------------------
FUNCTION GetCardProgramInfo(
	p_card_prog_id		IN	cardProgs_cardProgID,
	p_vendor_id	 OUT NOCOPY cardProgs_vendorID,
	p_vendor_site_id OUT NOCOPY cardProgs_vendorSiteID,
	p_invoice_curr_code OUT NOCOPY cardProgs_cardProgCurrCode
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
	SELECT  VENDOR_ID,
		VENDOR_SITE_ID,
		CARD_PROGRAM_CURRENCY_CODE
	INTO	p_vendor_id,
		p_vendor_site_id,
		p_invoice_curr_code
	FROM 	AP_CARD_PROGRAMS
	WHERE	CARD_PROGRAM_ID = p_card_prog_id;

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;
	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCardProgramInfo' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;
END GetCardProgramInfo;


-------------------------------------------------------------------
FUNCTION GetVendorIDs(
	p_report_header_id 	IN  ccTrxn_headerID,
	p_vendor_id 	 OUT NOCOPY cardProgs_vendorID,
	p_vendor_site_id OUT NOCOPY cardProgs_vendorSiteID
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  	SELECT 	distinct acp.vendor_id,
  	 	acp.vendor_site_id
  	INTO   	p_vendor_id,
  	 	p_vendor_site_id
  	FROM   	ap_credit_card_trxns cc,
  	 	ap_card_programs acp
  	WHERE  	cc.report_header_id = p_report_header_id
  	AND    	cc.card_program_id = acp.card_program_id;

  	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetVendorIDs' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetVendorIDs;

-------------------------------------------------------------------
FUNCTION GetCardProgramName(
	p_cardProgramID 	IN 	cardProgs_cardProgID,
	p_cardProgramName OUT NOCOPY cardProgs_cardProgName)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  	select card_program_name
  	into   p_cardProgramName
  	from   ap_card_programs
  	where  card_program_id = p_cardProgramID;

  	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCardProgramName' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetCardProgramName;


-------------------------------------------------------------------
FUNCTION GetCardProgramID(
	p_cardProgramName 	IN 	cardProgs_cardProgName,
	p_cardProgramID OUT NOCOPY cardProgs_cardProgID)
RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  	select card_program_id
  	into   p_cardProgramID
  	from   ap_card_programs
  	where  card_program_name = p_cardProgramName;

  	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCardProgramID' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetCardProgramID;



--------------------------------------------------------------------------------
FUNCTION CompanyHasTravelCardProgram(
	p_companyHasCardProgram OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN

 -- Determine if company has Card Program
    	select 'Y'
    	into 	p_companyHasCardProgram
	from 	ap_card_programs
        where 	card_type_lookup_code = 'TRAVEL';

    	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'CompanyHasTravelCardProgram' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END CompanyHasTravelCardProgram;


--------------------------------------------------------------------------------
FUNCTION UserHasCreditCard(
	p_userId 		IN	cards_employeeID,
	p_userHasCreditCard OUT NOCOPY VARCHAR2
 ) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN

 -- Determine if the user has Credit Card
                 SELECT 'Y'
                 INTO p_userHasCreditCard
                 FROM AP_CARD_PROGRAMS_all CP ,
                             AP_CARDS_all CARD ,
                            AP_LOOKUP_CODES ALC,
                            ( SELECT CARD_PROGRAM_ID,CARD_ID, PAYMENT_DUE_FROM_CODE
                              FROM  AP_CREDIT_CARD_TRXNS_all
	                      WHERE VALIDATE_CODE = 'Y'
                              AND PAYMENT_FLAG <> 'Y'
                              AND BILLED_AMOUNT IS NOT NULL
                              AND NVL ( CATEGORY , 'BUSINESS' ) <> 'DEACTIVATED' )  TRXN
                 WHERE  CARD.EMPLOYEE_ID =  p_userId
                 AND CARD.CARD_PROGRAM_ID = CP.CARD_PROGRAM_ID
                 AND CP.CARD_TYPE_LOOKUP_CODE = 'TRAVEL'
                 AND ALC.LOOKUP_TYPE = 'PAYMENT_DUE_FROM'
                 AND ( ALC.LOOKUP_CODE = CP.PAYMENT_DUE_FROM_CODE
                          OR ALC.LOOKUP_CODE = TRXN.PAYMENT_DUE_FROM_CODE)
                 AND TRUNC ( SYSDATE ) BETWEEN TRUNC ( NVL  (ALC.START_DATE_ACTIVE , SYSDATE ) )
                                                                               AND TRUNC ( NVL ( ALC.INACTIVE_DATE , SYSDATE ) )
                 AND TRXN.CARD_PROGRAM_ID(+) = CARD.CARD_PROGRAM_ID
                 AND TRXN.CARD_ID(+) = CARD.CARD_ID
                 AND ROWNUM = 1;

    	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'UserHasCreditCard' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END UserHasCreditCard;

-------------------------------------------------------------------
FUNCTION SetCCTrxnReportHeaderID(
	p_report_header_id 	IN NUMBER,
	p_new_report_id	  	IN NUMBER
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
        UPDATE ap_credit_card_trxns
        SET    report_header_id = p_new_report_id
        WHERE  report_header_id = p_report_header_id;
-- Bug 2178676
--           AND category <> c_personal;

	return TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'SetCCTrxnReportHeaderID' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END SetCCTrxnReportHeaderID;

--------------------------------------------------------------------------------
FUNCTION SetCCPolicyShortpaidReportID(
	p_orig_expense_report_id	IN 	AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
        p_new_expense_report_id  	IN 	ccTrxn_headerID )
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
      UPDATE ap_credit_card_trxns
      SET    report_header_id = p_new_expense_report_id
      WHERE  trx_id IN  (SELECT credit_card_trx_id
			FROM   ap_expense_report_lines
			WHERE  report_header_id = p_new_expense_report_id
      			AND    nvl(policy_shortpay_flag,'N') = 'Y');

 	RETURN TRUE;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'SetCCPolicyShortPaidReportID' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END SetCCPolicyShortpaidReportID;


--------------------------------------------------------------------------------
FUNCTION SetCCReceiptShortpaidReportID(
	p_orig_expense_report_id IN AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
        p_new_expense_report_id  IN ccTrxn_headerID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
	UPDATE ap_credit_card_trxns
      	SET    report_header_id = p_new_expense_report_id
      	WHERE  trx_id IN  (SELECT credit_card_trx_id
			FROM   ap_expense_report_lines
			WHERE  report_header_id = p_new_expense_report_id
      			AND    (receipt_required_flag = 'Y' OR image_receipt_required_flag = 'Y')
      			AND    nvl(receipt_verified_flag,'N') = 'N'
      			AND    nvl(policy_shortpay_flag, 'N') = 'N');

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'SetCCReceiptShortpaidReportID' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END SetCCReceiptShortpaidReportID;



-------------------------------------------------------------------------------
FUNCTION UpdateExpensedAmount(
	p_trxn_id		IN	ccTrxn_trxID,
	p_report_id		IN	ccTrxn_headerID,
	p_expensed_amount	IN	ccTrxn_expensedAmt
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
	UPDATE	ap_credit_card_trxns
	SET	expensed_amount = p_expensed_amount,
		report_header_id = p_report_id,
		category = null
	WHERE	trx_id = p_trxn_id;

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'UpdateExpensedAmount' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END UpdateExpensedAmount;

--------------------------------------------------------------------------------
FUNCTION ResetCCLines(
	p_report_header_id	IN AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE)
RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
       UPDATE ap_credit_card_trxns cc
       SET    expensed_amount = 0,
              report_header_id = null,
              category = null
       WHERE  report_header_id = p_report_header_id;
	RETURN TRUE;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'ResetCCLines' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END ResetCCLines;


--------------------------------------------------------------------------------
FUNCTION SetStatus(
	p_report_header_id 	IN ccTrxn_headerID,
        p_status 		IN ccTrxn_expenseStatus
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
       	UPDATE ap_credit_card_trxns
       	SET    expense_status = p_status
       	where  report_header_id = p_report_header_id;

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'SetStatus' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END SetStatus;



--------------------------------------------------------------------------------
FUNCTION ResetCCMgrRejectedCCLines(
	p_report_header_id	IN AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
	UPDATE 	ap_credit_card_trxns
	SET     expensed_amount = 0,
		report_header_id = NULL
	WHERE 	report_header_id IN (SELECT report_header_id
				     FROM ap_expense_report_headers
				     WHERE report_header_id = p_report_header_id
				     AND workflow_approved_flag in
                  (AP_WEB_DB_EXPRPT_PKG.C_WORKFLOW_APPROVED_REJECTED,
                   AP_WEB_DB_EXPRPT_PKG.C_WORKFLOW_APPROVED_RETURNED,
                     --ER 1552747 - withdraw expense report
                   AP_WEB_DB_EXPRPT_PKG.C_WORKFLOW_APPROVED_WITHDRAW));

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'ResetCCMgrRejectedCCLines' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END ResetCCMgrRejectedCCLines;


--------------------------------------------------------------------------------
FUNCTION ResetPersonalTrxns(
	p_reportID	IN ccTrxn_headerID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
      	update	ap_credit_card_trxns
      	set 	expensed_amount = 0,
		report_header_id = null
      	where 	(report_header_id = p_reportID)
	and     (category = c_personal);

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'ResetPersonalTrxns' );

    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;
END ResetPersonalTrxns;

--------------------------------------------------------------------------------
FUNCTION ResetMgrRejectPersonalTrxns(
	p_report_header_id	IN AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN

        UPDATE ap_credit_card_trxns cc
	SET    expensed_amount = 0,
	       report_header_id = null
        WHERE  cc.report_header_id IN  (SELECT report_header_id erh_headerID
                                        FROM   ap_expense_report_headers
                                        WHERE  report_header_id = p_report_header_id
				        AND workflow_approved_flag in
                    (AP_WEB_DB_EXPRPT_PKG.C_WORKFLOW_APPROVED_REJECTED,
                     AP_WEB_DB_EXPRPT_PKG.C_WORKFLOW_APPROVED_RETURNED,
                       --ER 1552747 - withdraw expense report
                     AP_WEB_DB_EXPRPT_PKG.C_WORKFLOW_APPROVED_WITHDRAW))
        AND    category = c_personal;

	RETURN TRUE;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'ResetMgrRejectedPersonalTrxns' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END ResetMgrRejectPersonalTrxns;


--------------------------------------------------------------------------------
FUNCTION SetCCTrxnInvoiceId(
	p_card_trxn_id	IN ccTrxn_trxID,
	p_invoice_id	IN ccTrxn_companyPrepaidInvID
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
	UPDATE	ap_credit_card_trxns_all
	SET	company_prepaid_invoice_id = p_invoice_id
	WHERE	trx_id = p_card_trxn_id;

	RETURN TRUE;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'UpdateInvoiceId' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END SetCCTrxnInvoiceId;

--------------------------------------------------------------------------
FUNCTION GetCCardTrxnInfoForTrxnId(
		p_trxn_id	IN	ccTrxn_trxID,
		p_trxn_info_rec OUT NOCOPY CCardTrxnInfoRec
) RETURN BOOLEAN IS
---------------------------------------------------------------------------
BEGIN
    SELECT trx_id,
           transaction_date,
	   folio_type,   	--shuh
           merchant_name1,
           merchant_city,
           merchant_province_state,
           billed_amount,
           posted_currency_code,
           transaction_amount,
           cc.card_id,
           nvl(cc.category, c_business),
           cc.card_program_id
    INTO   p_trxn_info_rec.trxn_id, p_trxn_info_rec.trxn_date,
	   p_trxn_info_rec.folio_type, p_trxn_info_rec.merchant_name,
	   p_trxn_info_rec.merchant_city, p_trxn_info_rec.merchant_prov,
	   p_trxn_info_rec.billed_amount, p_trxn_info_rec.posted_curr_code,
	   p_trxn_info_rec.trxn_amount, p_trxn_info_rec.card_id,
	   p_trxn_info_rec.category, p_trxn_info_rec.card_prog_id
    FROM ap_credit_card_trxns cc
    WHERE trx_id = p_trxn_id;

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCCardTrxnInfoForTrxnId' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetCCardTrxnInfoForTrxnId;

------------------------------------------------------------------------------
FUNCTION UpdateCCardCategory(
	p_trxn_id	IN	ccTrxn_trxID,
	p_category	IN	ccTrxn_category
) RETURN BOOLEAN IS
------------------------------------------------------------------------------
BEGIN
      	UPDATE	ap_credit_card_trxns
      	SET 	category = p_category
      	WHERE 	trx_id = p_trxn_id;

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;
	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'UpdateCCardCategory' );

    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;
END UpdateCCardCategory;

------------------------------------------------------------------------------
FUNCTION GetExpensedAmountForTrxnId(
		p_trxn_id	IN	ccTrxn_trxID,
		p_exp_amount OUT NOCOPY ccTrxn_expensedAmt
) RETURN BOOLEAN IS
------------------------------------------------------------------------------
BEGIN
	SELECT	expensed_amount
	INTO	p_exp_amount
	FROM 	ap_credit_card_trxns
    	WHERE 	trx_id = p_trxn_id;

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;
	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetExpensedAmountForTrxnId' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;
END GetExpensedAmountForTrxnId;

------------------------------------------------------------------------------
/*Written By :Amulya Mishra
  Purpose    :To check if a card program has multiple payment Methods.
*/
------------------------------------------------------------------------------
FUNCTION isMultPayments(
        p_cardProgramID IN  cardProgs_cardProgID,
        p_card_id              IN      cards_cardId
) RETURN BOOLEAN IS

paymentMethodCount  NUMBER;
------------------------------------------------------------------------------
BEGIN
        AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_DB_CCARD_PKG', 'start isMultPayments');
        select count(distinct payment_due_from_code)
        into  paymentMethodCount
        from ap_credit_card_trxns
        where card_program_id = p_cardProgramID
        and   card_id = p_card_id;

        IF (paymentMethodCount > 1) THEN
                RETURN TRUE;
        ELSE
                RETURN FALSE;
        END IF;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN FALSE;
        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'isMultPayments');
                APP_EXCEPTION.RAISE_EXCEPTION;
                return FALSE;
END isMultPayments;
-------------------------------------------------------------------------------
/*Written By :Amulya Mishra
  Purpose    :Returns the UNIQUE PAYMENT_DUE_FROM_CODE from
              AP_CREDIT_CARD_TRXNS_ALL table.
*/

FUNCTION getPaymentDueCodeFromTrxn(
        p_trxn_id       IN      ccTrxn_trxID)
RETURN VARCHAR2  IS

p_paymentDueCode  VARCHAR2(30);
-----------------------------------------------------------------------------
BEGIN

       AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_DB_CCARD_PKG', 'start getPaymentDueCodeFromTrxn');

       SELECT DISTINCT payment_due_from_code
       INTO   p_paymentDueCode
       FROM   ap_credit_card_trxns trx
       WHERE  trx.trx_id  = p_trxn_id;

       RETURN p_paymentDueCode;


EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN  null;

        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'getPaymentDueCodeFromTrxn' );
                APP_EXCEPTION.RAISE_EXCEPTION;

END getPaymentDueCodeFromTrxn;
-----------------------------------------------------------------------------
/*Written By :Amulya Mishra
  Purpose    :Returns the INDEX of ExpLines array for which
              Credit Card Trxn Id is Not Null.
*/

-----------------------------------------------------------------------------
FUNCTION getFirstLineWithCCTrxId(
        p_expLines  IN AP_WEB_DFLEX_PKG.ExpReportLines_A,
        p_personalReceipts  IN AP_WEB_DFLEX_PKG.ExpReportLines_A)
RETURN NUMBER IS

-----------------------------------------------------------------------------
BEGIN

       AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_DB_CCARD_PKG', 'start getFirstLineWithCCTrxId');

       FOR i IN 1..p_expLines.Count LOOP
         IF p_expLines(i).cCardTrxnId  IS NOT NULL THEN
           RETURN p_expLines(i).cCardTrxnId;
         END IF;
       END LOOP;

      FOR i IN 1..p_personalReceipts.Count LOOP
         IF p_personalReceipts(i).cCardTrxnId  IS NOT NULL THEN
           RETURN p_personalReceipts(i).cCardTrxnId;
         END IF;
       END LOOP;

     RETURN 0;

END getFirstLineWithCCTrxId;
-----------------------------------------------------------------------------

/*Written By : Ron Langi
  Purpose    : To check if credit card is enabled for a user.
  Modified By: Amulya Mishra(Bug 3618604)
               To reuse the same function , if its called from BC4J
               then p_user_id will not be passed and will be determined
               locally.
*/
------------------------------------------------------------------------------
FUNCTION isCreditCardEnabled(
      p_employee_id       IN 	cards_employeeID,
      p_user_id           IN 	NUMBER DEFAULT NULL)
RETURN VARCHAR2 IS
------------------------------------------------------------------------------

  l_debug_info		VARCHAR2(1000);
  l_has VARCHAR2(1);
  l_cCardEnabled VARCHAR2(1);
  p_userId       VARCHAR2(100);
  l_userId       NUMBER;


BEGIN


  IF p_user_id IS NULL THEN
    AP_WEB_OA_MAINFLOW_PKG.GetUserID(p_employee_id, p_userId);
    l_userId := to_number(p_userId);
  END IF;


  -------------------------------------------
  l_debug_info := 'Check if user is credit card enabled';
  -------------------------------------------
  l_cCardEnabled := AP_WEB_UTILITIES_PKG.VALUE_SPECIFIC(
					  p_name    => 'SSE_ENABLE_CREDIT_CARD',
					  p_user_id => nvl(p_user_id,l_userId),
					  p_resp_id => null,
					  p_apps_id => null);

  IF (AP_WEB_DB_CCARD_PKG.UserHasCreditCard(p_employee_id, l_has)) THEN
    if (AP_WEB_DB_HR_INT_PKG.IsPersonCwk(p_employee_id) = 'N' AND
        l_has = 'Y' AND l_cCardEnabled = 'Y') THEN
      return 'Y';
    end if;
  END IF;
  return 'N';

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN  'N';

        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'isCreditCardEnabled', l_debug_info );
                APP_EXCEPTION.RAISE_EXCEPTION;

END isCreditCardEnabled;

/*Written By : Ron Langi
  Purpose    : To get the prevent Cash CC Age Limit setting
*/
------------------------------------------------------------------------------
FUNCTION getPreventCashCCAgeLimit
RETURN NUMBER IS
------------------------------------------------------------------------------

  l_debug_info		VARCHAR2(1000);
  l_prevent_cash_cc_age_limit NUMBER;

BEGIN

  -------------------------------------------
  l_debug_info := 'Get Prevent Cash CC Age Limit';
  -------------------------------------------
  select prevent_cash_cc_age_limit
  into   l_prevent_cash_cc_age_limit
  from   ap_expense_params;

  return l_prevent_cash_cc_age_limit;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN  null;

        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'getPreventCashCCAgeLimit', l_debug_info );
                APP_EXCEPTION.RAISE_EXCEPTION;

END getPreventCashCCAgeLimit;

/*Written By : Ron Langi
  Purpose    : To check if prevent Cash CC Age Limit is set
*/
------------------------------------------------------------------------------
FUNCTION isPreventCashCCAgeLimitSet
RETURN BOOLEAN IS
------------------------------------------------------------------------------

  l_debug_info          VARCHAR2(1000);

BEGIN

  -------------------------------------------
  l_debug_info := 'Check if Prevent Cash CC Age Limit is set';
  -------------------------------------------
  if (getPreventCashCCAgeLimit is null) then
    return false;
  end if;

  return true;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN false;

        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'isPreventCashCCAgeLimitSet', l_debug_info );
                APP_EXCEPTION.RAISE_EXCEPTION;

END isPreventCashCCAgeLimitSet;

/*Written By : Ron Langi
  Purpose    : To get the number of old transactions
*/
------------------------------------------------------------------------------
PROCEDURE getNumOldTrxns(
      p_employee_id       IN 	cards_employeeID,
      p_num_old           OUT NOCOPY     NUMBER) IS
------------------------------------------------------------------------------

  l_debug_info		VARCHAR2(1000);
  l_prevent_cash_cc_age_limit NUMBER;

BEGIN

  if (not isPreventCashCCAgeLimitSet) then
    p_num_old := 0;
  else

    l_prevent_cash_cc_age_limit := getPreventCashCCAgeLimit;

    -------------------------------------------
    l_debug_info := 'Get number of Outstanding Trxns';
    -------------------------------------------
    select count(1)
    into   p_num_old
    from   ap_card_programs cp,
           ap_cards card,
           ap_credit_card_trxns trxns
    where  card.employee_id = p_employee_id
    and    card.card_program_id = cp.card_program_id
    and    cp.card_type_lookup_code = 'TRAVEL'
    and    trxns.card_program_id = card.card_program_id
    and    trxns.card_id = card.card_id
    and    trxns.validate_code = 'Y'
    and    trxns.payment_flag <> 'Y'
    and    trxns.billed_amount is not null
    and    trxns.report_header_id is null
    and    (nvl(trxns.category, 'BUSINESS') not in ('DISPUTED', 'CREDIT', 'MATCHED','DEACTIVATED'))
    and    sysdate - trxns.posted_date > l_prevent_cash_cc_age_limit;

  end if;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                p_num_old := 0;

        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'getNumOldTrxns', l_debug_info );
                APP_EXCEPTION.RAISE_EXCEPTION;

END getNumOldTrxns;

/*Written By : Ron Langi
  Purpose    : To get the number of disputed transactions
*/
------------------------------------------------------------------------------
PROCEDURE getNumDisputedTrxns(
      p_employee_id       IN 	cards_employeeID,
      p_num_disputed      OUT NOCOPY     NUMBER) IS
------------------------------------------------------------------------------
  l_debug_info		VARCHAR2(1000);
BEGIN
  -------------------------------------------
  l_debug_info := 'Get number of Disputed';
  -------------------------------------------
  select count(1)
  into   p_num_disputed
  from   ap_card_programs cp,
         ap_cards card,
         ap_credit_card_trxns trxns
  where  card.employee_id = p_employee_id
  and    card.card_program_id = cp.card_program_id
  and    cp.card_type_lookup_code = 'TRAVEL'
  and    trxns.card_program_id = card.card_program_id
  and    trxns.card_id = card.card_id
  and    trxns.validate_code = 'Y'
  and    trxns.payment_flag <> 'Y'
  and    trxns.billed_amount is not null
  and    trxns.report_header_id is null
  and    nvl(trxns.category,c_business) = 'DISPUTED';

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                p_num_disputed := 0;

        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'getNumDisputedTrxns', l_debug_info );
                APP_EXCEPTION.RAISE_EXCEPTION;

END getNumDisputedTrxns;

/*Written By : Ron Langi
  Purpose    : To get the number of credits transactions
*/
------------------------------------------------------------------------------
PROCEDURE getNumCredits(
      p_employee_id       IN 	cards_employeeID,
      p_num_credits           OUT NOCOPY     NUMBER) IS
------------------------------------------------------------------------------
  l_debug_info		VARCHAR2(1000);
BEGIN
  -------------------------------------------
  l_debug_info := 'Get number of Credits';
  -------------------------------------------
  select count(1)
  into   p_num_credits
  from   ap_card_programs cp,
         ap_cards card,
         ap_credit_card_trxns trxns
  where  card.employee_id = p_employee_id
  and    card.card_program_id = cp.card_program_id
  and    cp.card_type_lookup_code = 'TRAVEL'
  and    trxns.card_program_id = card.card_program_id
  and    trxns.card_id = card.card_id
  and    trxns.validate_code = 'Y'
  and    trxns.payment_flag <> 'Y'
  and    trxns.billed_amount < 0
  and    trxns.report_header_id is null
  and    nvl(trxns.category, 'BUSINESS') not in ('DISPUTED', 'CREDIT', 'MATCHED','DEACTIVATED');

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                p_num_credits := 0;

        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'getNumCredits', l_debug_info );
                APP_EXCEPTION.RAISE_EXCEPTION;

END getNumCredits;

/*Written By : Ron Langi
  Purpose    : To check delegates for Homepage CC Alerts
*/
------------------------------------------------------------------------------
PROCEDURE checkDelegatesForAlerts(
      p_employee_id       IN 	cards_employeeID,
      p_user_id           IN  NUMBER,
      p_delegate_flag     OUT NOCOPY     VARCHAR2) IS
------------------------------------------------------------------------------
  l_debug_info		VARCHAR2(1000);
  l_num_emps NUMBER := 0;
  l_employee_id NUMBER := 0;
  l_user_id NUMBER := 0;
  l_num_old NUMBER := 0;
  l_num_disputed NUMBER := 0;
  l_num_credits NUMBER := 0;

  CURSOR delegates IS
    SELECT h.employee_id
    FROM   per_employees_x h, ak_web_user_sec_attr_values a
    WHERE  a.attribute_code = 'ICX_HR_PERSON_ID'
      AND  a.web_user_id = p_user_id
      AND  h.employee_id = a.number_value
      AND NOT AP_WEB_DB_HR_INT_PKG.isPersonCwk(h.employee_id)='Y'
    UNION ALL
    SELECT h.person_id employee_id
    FROM   per_cont_workers_current_x h, ak_web_user_sec_attr_values a
    WHERE  a.attribute_code = 'ICX_HR_PERSON_ID'
      AND  a.web_user_id = p_user_id
      AND  h.person_id = a.number_value;

BEGIN

  -------------------------------------------
  l_debug_info := 'Check Delegates for any CC Alerts';
  -------------------------------------------
  p_delegate_flag := 'N';

  open delegates;
  loop
    fetch delegates into l_employee_id;
    exit when delegates%notfound;

    l_num_emps := l_num_emps + 1;

    AP_WEB_OA_MAINFLOW_PKG.GetUserID(l_employee_id, l_user_id);
    if (isCreditCardEnabled(l_employee_id, l_user_id) = 'Y') then

      getNumOldTrxns(l_employee_id, l_num_old);
      getNumDisputedTrxns(l_employee_id, l_num_disputed);
      getNumCredits(l_employee_id, l_num_credits);

      if (p_employee_id <> l_employee_id and
          (l_num_old > 0 or l_num_disputed > 0 or l_num_credits > 0)) then
        p_delegate_flag := 'Y';
        exit;
      end if;

    end if;

  end loop;
  close delegates;

EXCEPTION
        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'checkDelegatesForAlerts', l_debug_info );
                APP_EXCEPTION.RAISE_EXCEPTION;

END checkDelegatesForAlerts;


/*Written By : Ron Langi
  Purpose    : To get Homepage CC Alerts
*/
------------------------------------------------------------------------------
PROCEDURE getAlertsForHomepage(
        p_employee_id       IN 	cards_employeeID,
        p_cc_flag           OUT NOCOPY     VARCHAR2,
        p_num_days          OUT NOCOPY     NUMBER,
        p_num_old           OUT NOCOPY     NUMBER,
        p_num_disputed      OUT NOCOPY     NUMBER,
        p_num_credits       OUT NOCOPY     NUMBER,
        p_delegate_flag     OUT NOCOPY     VARCHAR2) IS
------------------------------------------------------------------------------

  l_debug_info		VARCHAR2(1000);
  l_user_id NUMBER;

BEGIN
  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_CCARD_PKG', 'start getAlertsForHomepage');

  p_cc_flag := 'N';
  p_num_days := 0;
  p_num_old := 0;
  p_num_disputed := 0;
  p_num_credits := 0;
  p_delegate_flag := 'N';

  -------------------------------------------
  l_debug_info := 'Getting employee user ID';
  -------------------------------------------
  AP_WEB_OA_MAINFLOW_PKG.GetUserID(p_employee_id, l_user_id);

  -- check if user is credit card enabled
  p_cc_flag := isCreditCardEnabled(p_employee_id, l_user_id);

  if (p_cc_flag = 'Y') then
    -- get Prevent Cash CC Age Limit
    p_num_days := getPreventCashCCAgeLimit;
    -- get Outstanding
    getNumOldTrxns(p_employee_id, p_num_old);
    -- get Disputed
    getNumDisputedTrxns(p_employee_id, p_num_disputed);
    -- get Credits
    getNumCredits(p_employee_id, p_num_credits);
  end if;

  -- check if delegates have CC Alerts
  checkDelegatesForAlerts(p_employee_id, l_user_id, p_delegate_flag);

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_DB_CCARD_PKG', 'end getAlertsForHomepage');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('getAlertsForHomepage', l_debug_info);

END getAlertsForHomepage;

---------------------------------------------------------------------------
/*Written By : Amulya Mishra
  Purpose    : Gets the Cusrsor for DISPUTED Credit card trxns for an employee.
*/


FUNCTION GetDisputeCcardTrxnCursor(
	 	p_cardProgramId		IN  ccTrxn_cardProgID,
		p_employeeId		IN  cards_employeeID,
		p_min_bucket		IN  NUMBER,
		p_max_bucket		IN  NUMBER,
    p_grace_days    IN NUMBER,
		p_dispute_cursor OUT NOCOPY DisputeCCTrxnCursor
) RETURN BOOLEAN IS
---------------------------------------------------------------------------


BEGIN

OPEN p_dispute_cursor FOR
          SELECT distinct  transaction_date,
                merchant_name1,
                billed_amount,
                billed_currency_code,
                cct.posted_currency_code, --3339380
                nvl(cct.billed_date, cct.posted_date) billed_date,
                cct.posted_date, --Notification Esc
                cct.transaction_amount,--Notification Esc
                AP_WEB_DB_CCARD_PKG.GETLOCATION(cct.merchant_city , cct.merchant_province_state)  --Notification Esc
          from
          ap_credit_card_trxns cct,
          ap_cards_all ac
          where
          cct.card_program_id = p_cardProgramId
          and cct.validate_code = 'Y'
          and cct.payment_flag <> 'Y'
          and nvl(cct.expensed_amount , 0) = 0
          and nvl(cct.category,'BUSINESS') = 'DISPUTED'
          and ac.card_program_id = cct.card_program_id
          and ac.card_id = cct.card_id
          and trunc(sysdate) - (cct.posted_date+nvl(p_grace_days,0)) between p_min_bucket and p_max_bucket
          and ac.employee_id = p_employeeId
          and rownum < 41;


	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetDisputeCcardTrxnCursor' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetDisputeCcardTrxnCursor;

-------------------------------------------------------------------------------
/*Written By : Amulya Mishra
  Purpose    : Gets the total OUTSTANDING Amount for an employee.
*/

FUNCTION GetTotalCreditCardAmount(
	 	p_cardProgramId		IN  ccTrxn_cardProgID,
		p_employeeId		IN  cards_employeeID,
    p_totalAmount   OUT NOCOPY NUMBER
) RETURN BOOLEAN IS
---------------------------------------------------------------------------
BEGIN
/* Bug 3356703: Only employee pending transactions should be
 *  summed up */
   SELECT sum(amount)
   INTO   p_totalAmount
   FROM
        (
          SELECT DISTINCT cct.trx_id, cct.billed_amount amount
          FROM
              ap_credit_card_trxns_all cct,
              ap_cards_all ac,
              ap_expense_report_headers_all erh
          WHERE
              cct.card_program_id = p_cardProgramId
          and cct.validate_code = 'Y'
          and cct.payment_flag <> 'Y'
          and AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(
                                erh.source,erh.workflow_approved_flag,
                                erh.report_header_id)
             in
          ('EMPAPPR', 'RESOLUTN','RETURNED',
           'REJECTED','SAVED','WITHDRAWN','UNUSED')
          and erh.report_header_id = cct.report_header_id
          and  NVL(erh.vouchno, 0) = 0
          and ac.card_program_id = cct.card_program_id
          and ac.card_id = cct.card_id
          and ac.employee_id = p_employeeId
          UNION ALL
          SELECT DISTINCT cct.trx_id, cct.billed_amount amount
          FROM
              ap_credit_card_trxns_all cct,
              ap_cards_all ac
          WHERE
              cct.card_program_id = p_cardProgramId
          and cct.validate_code = 'Y'
          and cct.payment_flag <> 'Y'
          and nvl(cct.expensed_amount , 0) =0
          and nvl(cct.category,'BUSINESS') <> 'DEACTIVATED'
          and ac.card_program_id = cct.card_program_id
          and ac.card_id = cct.card_id
          and ac.employee_id = p_employeeId
         );
	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetTotalCreditCardAmount' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetTotalCreditCardAmount;


---------------------------------------------------------------------------
/*Written By : Amulya Mishra
  Purpose    : Gets the total Number of NON DISPUTED OUTSTANDING Transactions
               and Total Amount.
*/


FUNCTION GetTotalNumberOutstanding(
                p_cardProgramId         IN  ccTrxn_cardProgID,
                p_employeeId            IN  cards_employeeID,
                p_min_bucket            IN  NUMBER,
                p_max_bucket            IN  NUMBER,
                p_total_outstanding   OUT NOCOPY NUMBER,
                p_total_amt_outstanding   OUT NOCOPY NUMBER
) RETURN BOOLEAN IS
---------------------------------------------------------------------------
BEGIN

       SELECT   count(1), sum(amount)
       INTO p_total_outstanding,
            p_total_amt_outstanding
       FROM
           ( SELECT DISTINCT trx_id, cct.billed_amount amount
             FROM
                    ap_credit_card_trxns             cct,
                    ap_cards                         ac,
                    ap_expense_report_headers        erh
             WHERE
                    cct.card_program_id = p_cardProgramId
             and cct.validate_code = 'Y'
             and cct.payment_flag <> 'Y'
             and nvl(cct.category,c_business) NOT IN
                    ('DISPUTED','CREDIT','MATCHED','DEACTIVATED')--Bug 3307864
             and ac.card_program_id = cct.card_program_id
             and ac.card_id = cct.card_id
             and trunc(sysdate) - cct.posted_date between p_min_bucket and p_max_bucket
             and erh.report_header_id = cct.report_header_id
             and AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(erh.source,
                                                              erh.workflow_approved_flag,
                                                              erh.report_header_id) --2615505
                in ('SAVED','UNUSED','REJECTED',
                    'RESOLUTN','EMPAPPR','RETURNED','WITHDRAWN')
             and ac.employee_id = p_employeeId
             UNION ALL
             SELECT DISTINCT trx_id, cct.billed_amount amount
             FROM
                    ap_credit_card_trxns             cct,
                    ap_cards                         ac
             WHERE
                    cct.card_program_id = p_cardProgramId
             and cct.validate_code = 'Y'
             and cct.payment_flag <> 'Y'
             and nvl(cct.expensed_amount , 0) = 0
             and nvl(cct.category,c_business) NOT IN
                    ('DISPUTED','CREDIT','MATCHED','DEACTIVATED')--Bug 3307864
             and cct.report_header_id is null
             and ac.card_program_id = cct.card_program_id
             and ac.card_id = cct.card_id
             and trunc(sysdate) - cct.posted_date between p_min_bucket and p_max_bucket
             and ac.employee_id = p_employeeId
             );


       RETURN TRUE;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN FALSE;

        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'GetTotalNumberOutstanding' );
                APP_EXCEPTION.RAISE_EXCEPTION;
                return FALSE;

END GetTotalNumberOutstanding;


-----------------------------------------------------------------------
/*Written By : Amulya Mishra
  Purpose    : Gets the total Number of DISPUTED Transactions and Total Amount.
*/

FUNCTION GetTotalNumberDispute(
                p_cardProgramId         IN  ccTrxn_cardProgID,
                p_employeeId            IN  cards_employeeID,
                p_min_bucket            IN  NUMBER,
                p_max_bucket            IN  NUMBER,
                p_grace_days            IN  NUMBER,
                p_total_dispute   OUT NOCOPY NUMBER,
                p_total_amt_dispute  OUT NOCOPY NUMBER
) RETURN BOOLEAN IS
---------------------------------------------------------------------------
BEGIN

       SELECT   count(1), sum(amount)
       INTO p_total_dispute,
            p_total_amt_dispute
       FROM
           ( SELECT DISTINCT trx_id, cct.billed_amount amount
             FROM
                    ap_credit_card_trxns             cct,
                    ap_cards                         ac,
                    ap_expense_report_headers        erh
             WHERE
                 cct.card_program_id = p_cardProgramId
             and cct.validate_code = 'Y'
             and cct.payment_flag <> 'Y'
             and nvl(cct.category,c_business) = 'DISPUTED'
             and ac.card_program_id = cct.card_program_id
             and ac.card_id = cct.card_id
             and trunc(sysdate) - (cct.posted_date+nvl(p_grace_days,0))
                 between p_min_bucket and p_max_bucket
             and erh.report_header_id(+) = cct.report_header_id
             and NVL(AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode(erh.source,
                                                              erh.workflow_approved_flag,
                                                              erh.report_header_id),
                                                              'UNUSED') --2615505
                in ('SAVED','UNUSED','REJECTED',
                    'RESOLUTN','EMPAPPR','RETURNED','WITHDRAWN')
             and ac.employee_id = p_employeeId);


        RETURN TRUE;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN FALSE;

        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'GetTotalNumberOutstanding' );
                APP_EXCEPTION.RAISE_EXCEPTION;
                return FALSE;

END GetTotalNumberDispute;

--------------------------------------------------------------------------------------

-----------------------------------------------------------------------
/*
  Written By : Ron Langi
  Purpose    : Gets Posted Date for the Oldest Available Transaction
*/

FUNCTION GetOldestAvailPostedDate(
                p_cardProgramId         IN  ccTrxn_cardProgID,
                p_cardId                IN  cards_cardId,
                p_paymentDueFromCode    IN  ccTrxn_paymentDueFromCode,
                p_reimb_curr_code       IN  ccTrxn_billedCurrCode,
                p_report_header_id      IN  ccTrxn_headerID
) RETURN DATE IS
-----------------------------------------------------------------------

l_oldest_posted_date DATE := sysdate;

BEGIN

  select nvl(min(posted_date), sysdate)
  into   l_oldest_posted_date
  from   ap_credit_card_trxns cct
  where  cct.card_program_id = p_cardProgramId
  and    cct.card_id = p_cardId
  and    cct.payment_due_from_code = p_paymentDueFromCode
  and    cct.billed_currency_code = p_reimb_curr_code
  and    cct.validate_code = 'Y'
  and    cct.payment_flag <> 'Y'
  and    nvl(cct.category, c_business) not in (c_disputed, c_credit, c_matched, c_deactivated)
  and    (cct.report_header_id is null or cct.report_header_id = p_report_header_id)
  and    cct.billed_amount is not null;

  return l_oldest_posted_date;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN sysdate;

  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException( 'GetOldestAvailPostedDate' );
    APP_EXCEPTION.RAISE_EXCEPTION;
    return sysdate;

END GetOldestAvailPostedDate;

-----------------------------------------------------------------------

/*
  Written By : Amulya Mishra
  Bug        : 3562287
  Purpose    : Reurn location field using merchant_city and
               merchant_province_state.
*/

-----------------------------------------------------------------------
FUNCTION GetLocation(
               merchant_city            IN  VARCHAR2,
               merchant_province_state  IN  VARCHAR2
) RETURN VARCHAR2  IS
-----------------------------------------------------------------------
BEGIN
  IF merchant_city IS NOT NULL and merchant_province_state IS NOT NULL THEN
     RETURN merchant_city || ', ' || merchant_province_state;
  ELSIF merchant_city IS NULL and merchant_province_state IS NOT NULL THEN
     RETURN merchant_province_state;
  ELSIF merchant_city IS NOT NULL and merchant_province_state IS NULL THEN
     RETURN merchant_city;
  ELSIF merchant_city IS NULL and   merchant_province_state IS NULL THEN
     RETURN NULL;
  END IF;
END GetLocation;
-----------------------------------------------------------------------

END AP_WEB_DB_CCARD_PKG;

/
