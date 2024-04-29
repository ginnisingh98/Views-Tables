--------------------------------------------------------
--  DDL for Package AP_WEB_DB_EXPLINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_EXPLINE_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdbels.pls 120.34.12010000.3 2010/06/09 12:02:54 rveliche ship $ */

C_InitialDistLineNumber     CONSTANT NUMBER := 1000;
C_NumDaysRollForward     CONSTANT NUMBER := 7;
C_Unchanged              CONSTANT VARCHAR2(1) := 'U';
C_New			 CONSTANT VARCHAR2(1) := 'N';
C_Modified		 CONSTANT VARCHAR2(1) := 'M';
C_Split                  CONSTANT VARCHAR2(1) := 'S';

---------------------------------------------------------------------------------------------------
SUBTYPE expLines_headerID 		IS AP_EXPENSE_REPORT_LINES.report_header_id%TYPE;
SUBTYPE expLines_codeCombID		IS AP_EXPENSE_REPORT_LINES.code_combination_id%TYPE;
SUBTYPE expLines_setOfBooksID		IS AP_EXPENSE_REPORT_LINES.set_of_books_id%TYPE;
SUBTYPE expLines_amount			IS AP_EXPENSE_REPORT_LINES.amount%TYPE;
SUBTYPE expLines_currCode		IS AP_EXPENSE_REPORT_LINES.currency_code%TYPE;
SUBTYPE expLines_xchRateType		IS AP_EXPENSE_REPORT_LINES.exchange_rate_type%TYPE;
SUBTYPE expLines_xchRate		IS AP_EXPENSE_REPORT_LINES.exchange_rate%TYPE;
SUBTYPE expLines_vatCode		IS AP_EXPENSE_REPORT_LINES.vat_code%TYPE;
SUBTYPE expLines_lineTypeLookupCode	IS AP_EXPENSE_REPORT_LINES.line_type_lookup_code%TYPE;
SUBTYPE expLines_projID			IS AP_EXPENSE_REPORT_LINES.project_id%TYPE;
SUBTYPE expLines_projName		IS AP_EXPENSE_REPORT_LINES.project_name%TYPE;
SUBTYPE expLines_taskID			IS AP_EXPENSE_REPORT_LINES.task_id%TYPE;
SUBTYPE expLines_taskName		IS AP_EXPENSE_REPORT_LINES.task_name%TYPE;
SUBTYPE expLines_orgID			IS AP_EXPENSE_REPORT_LINES.org_id%TYPE;
SUBTYPE expLines_receiptVerifFlag	IS AP_EXPENSE_REPORT_LINES.receipt_verified_flag%TYPE;
SUBTYPE expLines_justifReqdFlag		IS AP_EXPENSE_REPORT_LINES.justification_required_flag%TYPE;
SUBTYPE expLines_receiptReqdFlag	IS AP_EXPENSE_REPORT_LINES.receipt_required_flag%TYPE;
SUBTYPE expLines_receiptMissingFlag	IS AP_EXPENSE_REPORT_LINES.receipt_missing_flag%TYPE;
SUBTYPE expLines_justification		IS AP_EXPENSE_REPORT_LINES.justification%TYPE;
SUBTYPE expLines_dailyAmount		IS AP_EXPENSE_REPORT_LINES.daily_amount%TYPE;
SUBTYPE expLines_webParamID		IS AP_EXPENSE_REPORT_LINES.web_parameter_id%TYPE;
SUBTYPE expLines_amtInclTaxFlag		IS AP_EXPENSE_REPORT_LINES.amount_includes_tax_flag%TYPE;
SUBTYPE expLines_adjReason		IS AP_EXPENSE_REPORT_LINES.adjustment_reason%TYPE;
SUBTYPE expLines_policyShortpayFlag	IS AP_EXPENSE_REPORT_LINES.policy_shortpay_flag%TYPE;
SUBTYPE expLines_countryOfSupply	IS AP_EXPENSE_REPORT_LINES.country_of_supply%TYPE;
SUBTYPE expLines_taxCodeID		IS AP_EXPENSE_REPORT_LINES.tax_code_id%TYPE;
SUBTYPE expLines_taxCodeOverrideFlag	IS AP_EXPENSE_REPORT_LINES.tax_code_override_flag%TYPE;
SUBTYPE expLines_crdCardTrxID		IS AP_EXPENSE_REPORT_LINES.credit_card_trx_id%TYPE;
SUBTYPE expLines_compPrepaidInvID	IS AP_EXPENSE_REPORT_LINES.company_prepaid_invoice_id%TYPE;
SUBTYPE expLines_itemizeID		IS AP_EXPENSE_REPORT_LINES.itemize_id%TYPE;
SUBTYPE expLines_itemDescription	IS AP_EXPENSE_REPORT_LINES.item_description%TYPE;
SUBTYPE expLines_startExpDate		IS AP_EXPENSE_REPORT_LINES.start_expense_date%TYPE;
SUBTYPE expLines_endExpDate		IS AP_EXPENSE_REPORT_LINES.end_expense_date%TYPE;
SUBTYPE expLines_receiptConvRate	IS AP_EXPENSE_REPORT_LINES.receipt_conversion_rate%TYPE;
SUBTYPE expLines_receiptCurrCode	IS AP_EXPENSE_REPORT_LINES.receipt_currency_code%TYPE;
SUBTYPE expLines_createdBy		IS AP_EXPENSE_REPORT_LINES.created_by%TYPE;
SUBTYPE expLines_projAcctContext	IS AP_EXPENSE_REPORT_LINES.project_accounting_context%TYPE;
SUBTYPE expLines_expOrgID		IS AP_EXPENSE_REPORT_LINES.expenditure_organization_id%TYPE;
SUBTYPE expLines_distLineNum		IS AP_EXPENSE_REPORT_LINES.distribution_line_number%TYPE;
SUBTYPE expLines_awtGroupID		IS AP_EXPENSE_REPORT_LINES.awt_group_id%TYPE;
SUBTYPE expLines_expendItemDate		IS AP_EXPENSE_REPORT_LINES.expenditure_item_date%TYPE;
SUBTYPE expLines_expendType		IS AP_EXPENSE_REPORT_LINES.expenditure_type%TYPE;
SUBTYPE expLines_paQuantity		IS AP_EXPENSE_REPORT_LINES.pa_quantity%TYPE;
SUBTYPE expLines_CategoryCode		IS AP_EXPENSE_REPORT_LINES.category_code%TYPE;
SUBTYPE expLines_attrCategory		IS AP_EXPENSE_REPORT_LINES.attribute_category%TYPE;
SUBTYPE expLines_attr1			IS AP_EXPENSE_REPORT_LINES.attribute1%TYPE;
SUBTYPE expLines_attr2			IS AP_EXPENSE_REPORT_LINES.attribute2%TYPE;
SUBTYPE expLines_attr3			IS AP_EXPENSE_REPORT_LINES.attribute3%TYPE;
SUBTYPE expLines_attr4			IS AP_EXPENSE_REPORT_LINES.attribute4%TYPE;
SUBTYPE expLines_attr5			IS AP_EXPENSE_REPORT_LINES.attribute5%TYPE;
SUBTYPE expLines_attr6			IS AP_EXPENSE_REPORT_LINES.attribute6%TYPE;
SUBTYPE expLines_attr7			IS AP_EXPENSE_REPORT_LINES.attribute7%TYPE;
SUBTYPE expLines_attr8			IS AP_EXPENSE_REPORT_LINES.attribute8%TYPE;
SUBTYPE expLines_attr9			IS AP_EXPENSE_REPORT_LINES.attribute9%TYPE;
SUBTYPE expLines_attr10			IS AP_EXPENSE_REPORT_LINES.attribute10%TYPE;
SUBTYPE expLines_attr11			IS AP_EXPENSE_REPORT_LINES.attribute11%TYPE;
SUBTYPE expLines_attr12			IS AP_EXPENSE_REPORT_LINES.attribute12%TYPE;
SUBTYPE expLines_attr13			IS AP_EXPENSE_REPORT_LINES.attribute13%TYPE;
SUBTYPE expLines_attr14			IS AP_EXPENSE_REPORT_LINES.attribute14%TYPE;
SUBTYPE expLines_attr15			IS AP_EXPENSE_REPORT_LINES.attribute15%TYPE;
SUBTYPE expLines_avg_mileage_rate	IS AP_EXPENSE_REPORT_LINES.avg_mileage_rate%TYPE;
SUBTYPE expLines_vehicle_category_code	IS AP_EXPENSE_REPORT_LINES.VEHICLE_CATEGORY_CODE%TYPE;
SUBTYPE expLines_vehicle_type		IS AP_EXPENSE_REPORT_LINES.VEHICLE_TYPE%TYPE;
SUBTYPE expLines_fuel_type		IS AP_EXPENSE_REPORT_LINES.FUEL_TYPE%TYPE;
SUBTYPE expLines_trip_distance		IS AP_EXPENSE_REPORT_LINES.TRIP_DISTANCE%TYPE;
SUBTYPE expLines_distance_unit_code	IS AP_EXPENSE_REPORT_LINES.DISTANCE_UNIT_CODE%TYPE;
SUBTYPE expLines_daily_distance		IS AP_EXPENSE_REPORT_LINES.DAILY_DISTANCE%TYPE;
SUBTYPE expLines_LineFlexConcat		IS AP_EXPENSE_REPORT_LINES.FLEX_CONCATENATED%TYPE;
SUBTYPE expLines_APValidationError	IS AP_EXPENSE_REPORT_LINES.AP_VALIDATION_ERROR%TYPE;
SUBTYPE expLines_mrate_adj_flag 	IS AP_EXPENSE_REPORT_LINES.MILEAGE_RATE_ADJUSTED_FLAG%TYPE;
SUBTYPE expLines_report_line_id 	IS AP_EXPENSE_REPORT_LINES.REPORT_LINE_ID%TYPE;
SUBTYPE expLines_number_people  	IS AP_EXPENSE_REPORT_LINES.NUMBER_PEOPLE%TYPE;
SUBTYPE expLines_rate_per_passenger  	IS AP_EXPENSE_REPORT_LINES.RATE_PER_PASSENGER%TYPE;
---------------------------------------------------------------------------------------------------


TYPE CCTrxnCursor 		IS REF CURSOR;
TYPE ReportLinesCursor		IS REF CURSOR;
TYPE XpenseLinesCursor 		IS REF CURSOR;
TYPE DisplayXpenseLinesCursor 	IS REF CURSOR;
TYPE XpenseLineAcctCursor 	IS REF CURSOR;
TYPE ShortpayXpenseLineCursor	IS REF CURSOR;
TYPE CCardLinesCursor		IS REF CURSOR;
TYPE ExpLinesCursor		IS REF CURSOR;
TYPE ExpLineCCIDCursor		IS REF CURSOR;

-------------------------------------------------------------------
TYPE XpenseLineRec IS RECORD (
  new_report_header_id 		expLines_headerID,
  code_combination_id 		expLines_codeCombID,
  set_of_books_id		expLines_setOfBooksID,
  item_description		expLines_itemDescription,
  line_type_lookup_code		expLines_lineTypeLookupCode,
  reimbursement_currency_code	expLines_currCode,
  require_receipt_flag		expLines_receiptReqdFlag,
  date1_temp			expLines_startExpDate,
  date2_temp			expLines_endExpDate,
  rate				expLines_receiptConvRate,
  preparer_id			expLines_createdBy,			-- Bug 875565
  IsReceiptProjectEnabled	expLines_projAcctContext,
  expenditure_organization_id	expLines_expOrgID,
  company_prepaid_invoice_id	expLines_compPrepaidInvID
); /* end TYPE XpenseLineRec */
-------------------------------------------------------------------
TYPE Mileage_Line_Rec IS RECORD (
  orig_dist_line_number	        expLines_distLineNum,
  new_dist_line_number	        expLines_distLineNum,
  report_header_id		expLines_headerID,
  start_date			expLines_startExpDate,
  end_date			expLines_endExpDate,
  number_of_days		NUMBER,
  policy_id			AP_POL_LINES.policy_id%TYPE,
  avg_mileage_rate		expLines_avg_mileage_rate,
  trip_distance			expLines_trip_distance,
  daily_distance		expLines_daily_distance,
  distance_unit_code		expLines_distance_unit_code,
  amount			expLines_amount,
  status			VARCHAR2(1) := C_Unchanged,
  category_code			ap_expense_report_params.category_code%TYPE,
  copy_From			expLines_distLineNum,
  daily_amount			expLines_dailyAmount,
  receipt_currency_amount	ap_expense_report_lines.receipt_currency_amount%TYPE,
  reimbursement_currency_code	expLines_currCode,
  number_people                 expLines_number_people,
  web_parameter_id             expLines_webParamID,
  rate_per_passenger          expLines_rate_per_passenger,
  attribute1   expLines_attr1,
  attribute2   expLines_attr2,
  attribute3   expLines_attr3,
  attribute4   expLines_attr4,
  attribute5   expLines_attr5,
  attribute6   expLines_attr6,
  attribute7   expLines_attr7,
  attribute8   expLines_attr8,
  attribute9   expLines_attr9,
  attribute10   expLines_attr10,
  attribute11   expLines_attr11,
  attribute12   expLines_attr12,
  attribute13   expLines_attr13,
  attribute14   expLines_attr14,
  attribute15   expLines_attr15,
  report_line_id ap_expense_report_lines.report_line_id%type
); /* end TYPE Mileage_Line_Rec */

TYPE Mileage_Line_Array IS TABLE OF Mileage_Line_Rec
        INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------
FUNCTION GetTrxIdsAndAmtsCursor(p_reportId 	IN  expLines_headerID,
				p_cc_cursor  OUT NOCOPY CCTrxnCursor)
RETURN BOOLEAN;
-------------------------------------------------------------------

PROCEDURE FetchReportLineCursor(p_ReportLinesCursor IN OUT NOCOPY ReportLinesCursor,
  p_expLines            IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportLines_A,
  Attribute_Array       IN OUT NOCOPY AP_WEB_PARENT_PKG.BigString_Array,
  p_ReceiptIndex        IN OUT NOCOPY NUMBER,
  p_Rate                OUT NOCOPY expLines_receiptConvRate,
  p_AmtInclTax          OUT NOCOPY expLines_amtInclTaxFlag,
  p_TaxName             OUT NOCOPY expLines_vatCode,
  p_ExpenditureType     OUT NOCOPY expLines_expendType);

--------------------------------------------------------------------------------
FUNCTION GetReportLineCursor(p_reportId 	IN  expLines_headerID,
			     p_line_cursor  OUT NOCOPY ReportLinesCursor)
RETURN BOOLEAN;
--------------------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetDisplayXpenseLinesCursor(
	p_report_header_id	IN	expLines_headerID,
	p_xpense_lines_cursor OUT NOCOPY DisplayXpenseLinesCursor)
RETURN BOOLEAN;
-------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetDisplayXpenseLinesCursor(
	p_report_header_id	IN	expLines_headerID,
	p_is_cc_lines		IN	BOOLEAN,
	p_xpense_lines_cursor OUT NOCOPY DisplayXpenseLinesCursor)
RETURN BOOLEAN;
-------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetDisplayPersonalLinesCursor(
	p_report_header_id	IN	expLines_headerID,
	p_personal_lines_cursor OUT NOCOPY DisplayXpenseLinesCursor)
RETURN BOOLEAN;
-------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetExpDistAcctCursor(p_exp_report_id   IN  expLines_headerID,
                              p_cursor   OUT NOCOPY XpenseLineAcctCursor)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------
FUNCTION CalcNoReceiptsShortpayAmts(
				p_report_header_id 	IN  expLines_headerID,
				p_no_receipts_ccard_amt OUT NOCOPY NUMBER,
				p_no_receipts_emp_amt  OUT NOCOPY NUMBER
) RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION CalcNoReceiptsPersonalTotal(p_report_header_id IN expLines_headerID,
				     p_personal_total   OUT NOCOPY NUMBER
) RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION CalculatePolicyShortpayAmts(
		p_report_header_id 	IN  expLines_headerID,
		p_policy_ccard_amt OUT NOCOPY NUMBER,
		p_policy_emp_amt  OUT NOCOPY NUMBER,
		p_policy_shortpay_total OUT NOCOPY NUMBER
) RETURN BOOLEAN;
--------------------------------------------------------------------------------------------
FUNCTION GetReceiptMissingTotal(p_report_header_id 	IN  expLines_headerID,
				p_sum_missing_receipts OUT NOCOPY NUMBER)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------
FUNCTION GetReceiptViolationsTotal(p_report_header_id 	IN  expLines_headerID,
				p_sum_violations OUT NOCOPY NUMBER)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetPersonalTotalOfExpRpt(p_report_header_id 	IN  AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
				  p_personal_total OUT NOCOPY NUMBER)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetNumReceiptRequiredLines(p_report_header_id IN  expLines_headerID,
				    p_num_req_receipts OUT NOCOPY NUMBER)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetNumReceiptShortpaidLines(p_report_header_id 		IN expLines_headerID,
				     p_num_req_receipt_not_verified  OUT NOCOPY NUMBER)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetNumShortpaidLines(p_report_header_id IN  expLines_headerID,
			      p_count		 OUT NOCOPY NUMBER)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetNumJustReqdLines(p_report_header_id IN  expLines_headerID,
			p_num_req_receipts  OUT NOCOPY NUMBER)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetNumberOfExpLines(p_report_header_id IN  AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
 			     p_count	 OUT NOCOPY NUMBER)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetNumCCLinesIncluded(p_report_header_id IN  expLines_headerID,
				p_crd_card_count  OUT NOCOPY NUMBER)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetNumberOfPersonalLines(p_report_header_id IN  expLines_headerID,
				p_personal_count  OUT NOCOPY NUMBER)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------
FUNCTION ContainsProjectRelatedLine(
	p_ReportHeaderID 	IN  expLines_headerID
) RETURN BOOLEAN;


--------------------------------------------------------------------------------
FUNCTION ContainsNonProjectRelatedLine(
	p_ReportHeaderID 	IN  expLines_headerID
) RETURN BOOLEAN;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION AddReportLines(
	p_xpense_lines			IN XpenseLineRec,
        p_expLines 			IN AP_WEB_DFLEX_PKG.ExpReportLineRec,
	P_AttributeCol 			IN AP_WEB_PARENT_PKG.BigString_Array,
	i				IN NUMBER
) RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION AddPolicyShortPaidExpLines(
p_new_expense_report_id 	IN expLines_headerID,
p_orig_expense_report_id 	IN expLines_headerID
) RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION AddUnverifiedShortpaidLines(
p_new_expense_report_id 	IN expLines_headerID,
p_orig_expense_report_id 	IN expLines_headerID
) RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION AddCCReportLines(p_report_header_id 	IN expLines_headerID,
			  p_new_report_id 	IN expLines_headerID
) RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION DeleteReportLines(P_ReportID             IN expLines_headerID)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION DeletePersonalLines(p_report_header_id IN expLines_headerID
) RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION DeleteCreditReportLines(p_report_header_id IN expLines_headerID)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION SetAWTGroupIDAndJustif(p_report_header_id 	IN expLines_headerID,
			p_sys_allow_awt_flag 	IN VARCHAR2,
			p_ven_allow_awt_flag 	IN VARCHAR2,
			p_ven_awt_group_id 	IN expLines_awtGroupID
) RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION SetReceiptMissing(p_report_header_id 	IN expLines_headerID,
			p_flag	   		IN expLines_receiptMissingFlag)
RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION SetReceiptRequired(	p_report_header_id 	IN expLines_headerID,
				p_required_flag 	IN expLines_receiptReqdFlag
) RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION GetCCardLineCursor(p_expReportHeaderId IN  expLines_headerID,
			    p_cCardLineCursor OUT NOCOPY CCardLinesCursor)
RETURN BOOLEAN;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
PROCEDURE GetCCPrepaidAdjustedInvAmt(p_expReportHeaderId IN     NUMBER,
			            p_invAmt 	        IN OUT NOCOPY VARCHAR2);
--------------------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetReceiptsMissingFlag( p_report_header_id 	IN  expLines_headerID,
				p_missing_receipts_flag OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

--------------------------------------------------------------------------------
FUNCTION GetExpMileageLinesCursor(
	p_report_header_id	IN	expLines_headerID,
	p_mileage_lines_cursor OUT NOCOPY ExpLinesCursor)
RETURN BOOLEAN;
--------------------------------------------------------------------------------
PROCEDURE updateMileageExpLine(
	p_avg_mileage_rate	   IN expLines_avg_mileage_rate,
	p_report_header_id	   IN expLines_headerID,
	p_distribution_line_number IN expLines_distLineNum,
	p_new_dist_line_number	   IN expLines_distLineNum,
	p_amount		   IN expLines_amount,
	p_trip_distance		   IN expLines_trip_distance,
	p_daily_distance	   IN NUMBER,
	p_daily_amount		   IN expLines_dailyAmount,
	p_receipt_currency_amount  IN NUMBER,
	p_status_code		   IN expLines_mrate_adj_flag);
--------------------------------------------------------------------------------
PROCEDURE updateExpenseMileageLines(
	p_mileage_line_array		IN Mileage_Line_Array,
	p_bUpdatedHeader		OUT NOCOPY BOOLEAN
);
--------------------------------------------------------------------------------
PROCEDURE AddMileageExpLine(
	p_new_distribution_line_number	IN NUMBER,
	p_new_trip_distance		IN NUMBER,
	p_new_daily_distance		IN NUMBER,
	p_new_amount			IN NUMBER,
	p_new_avg_mileage_rate		IN NUMBER,
	p_orig_expense_report_id 	IN expLines_headerID,
	p_orig_dist_line_number		IN expLines_distLineNum,
	p_daily_amount			IN NUMBER,
	p_receipt_currency_amount	IN NUMBER,
        x_report_line_id                OUT NOCOPY NUMBER

);

-------------------------------------------------------------------
-- Name: DuplicateLines
-- Desc: duplicates Expense Report Lines
-- Input:   p_source_report_header_id - source expense report header id
-- Returns: p_target_report_header_id - target expense report header id
-------------------------------------------------------------------
PROCEDURE DuplicateLines(
  p_user_id     IN NUMBER,
  p_source_report_header_id     IN expLines_headerID,
  p_target_report_header_id     IN OUT NOCOPY expLines_headerID);

-------------------------------------------------------------------
PROCEDURE ResetAPValidationErrors(
  p_report_header_id     IN expLines_headerID);
-------------------------------------------------------------------

-------------------------------------------------------------------
PROCEDURE UpdateAPValidationError(
  p_report_header_id     IN expLines_headerID,
  p_dist_line_number     IN expLines_distLineNum,
  p_ap_validation_error  IN expLines_APValidationError);
-------------------------------------------------------------------
PROCEDURE resetAPflags(
  p_report_header_id     IN expLines_headerID);
-------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION GetNumCashLinesWOMerch(p_report_header_id IN  expLines_headerID,
				      p_count  OUT NOCOPY NUMBER)
RETURN BOOLEAN;
--------------------------------------------------------------------------------

/**
 * jrautiai ADJ Fix start
 */

/**
 * jrautiai ADJ Fix
 * Modified GetAdjustmentsCursor to fetch the cursor for both adjustments and
 * shortpays, this was done to group the logic together and to simplify it.
 * To do this new cursors and record introduced to store the adjustment
 * information.
 */
TYPE AdjustmentCursor IS REF CURSOR;
TYPE AdjustmentRecordType IS RECORD (
  report_header_id              AP_EXPENSE_REPORT_LINES.report_header_id%TYPE,
  start_expense_date            AP_EXPENSE_REPORT_LINES.start_expense_date%TYPE,
  amount                        AP_EXPENSE_REPORT_LINES.amount%TYPE,
  submitted_amount              AP_EXPENSE_REPORT_LINES.submitted_amount%TYPE,
  adjusted_amount               NUMBER,
  web_parameter_id              AP_EXPENSE_REPORT_LINES.web_parameter_id%TYPE,
  expense_type_disp             VARCHAR2(80),
  justification                 AP_EXPENSE_REPORT_LINES.justification%TYPE,
  adjustment_reason_code        AP_EXPENSE_REPORT_LINES.adjustment_reason_code%TYPE,
  adjustment_reason_code_disp   VARCHAR2(80),
  adjustment_reason_description AP_EXPENSE_REPORT_LINES.adjustment_reason%TYPE,
  adjustment_reason             AP_EXPENSE_REPORT_LINES.adjustment_reason%TYPE,
  credit_card_expense_disp      VARCHAR2(80),
  itemized_expense_disp         VARCHAR2(80)
); /* end TYPE AdjustmentRecordType */

TYPE AdjustmentCursorType IS REF CURSOR RETURN AdjustmentRecordType;

/**
 * jrautiai ADJ Fix
 * Need the ability to insert a single row, this procedure inserts a row in the
 * database, using the data provided in the record given as parameter.
 */
PROCEDURE InsertLine(expense_line_rec     in AP_EXPENSE_REPORT_LINES_ALL%ROWTYPE);

/**
 * rlangi AUDIT
 * Check to see if there are any line level audit issue
 */
FUNCTION AnyAuditIssue(p_report_header_id IN  expLines_headerID)
RETURN BOOLEAN;

/**
 * jrautiai ADJ Fix
 * Modified GetAdjustmentsCursor to fetch the cursor for both adjustments and
 * shortpays, this was done to group the logic together and to simplify it.
 */
FUNCTION GetAdjustmentsCursor(p_report_header_id IN  expLines_headerID,
                              p_adjustment_type  IN  VARCHAR2,
			      p_cursor 		 OUT NOCOPY AdjustmentCursorType)
RETURN BOOLEAN;

/**
 * jrautiai ADJ Fix
 * Modified the amount calculating routine to centralize the different payment scenario
 * calcualations in one place.
 */
FUNCTION CalculateAmtsDue(p_report_header_id   IN  expLines_headerID,
                          p_payment_due_from   IN  VARCHAR2,
                          p_emp_amt            OUT NOCOPY NUMBER,
                          p_ccard_amt          OUT NOCOPY NUMBER,
                          p_total_amt          OUT NOCOPY NUMBER
) RETURN BOOLEAN;

/**
 * jrautiai ADJ Fix
 * Check whether a report has been shortpaid, used in the workflow logic to display messages.
 */
FUNCTION GetShortpaidFlag( p_report_header_id 	IN  expLines_headerID,
                           p_shortpaid_flag     OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

FUNCTION GetNumPolicyShortpaidLines(p_report_header_id IN expLines_headerID,
				    p_count            OUT NOCOPY NUMBER)
RETURN BOOLEAN;

FUNCTION GetAdjustedLineExists(p_report_header_id IN  expLines_headerID)
RETURN BOOLEAN;

PROCEDURE ResetShortpayAdjustmentInfo(p_report_header_id IN expLines_headerID);

/**
 * jrautiai ADJ Fix end
 */

--------------------------------------------------------------------------------
FUNCTION GetCountyProvince(p_addressstyle IN per_addresses.style%TYPE,
                           p_region       IN per_addresses.region_1%TYPE)
RETURN VARCHAR2;
--------------------------------------------------------------------------------

--Bug 2944363:Defined two new functions for Personal CC trxn in Both Pay.
--AMMISHRA - Both Pay Personal Only Lines project.
-------------------------------------------------------------------
FUNCTION GetBothPayPersonalLinesCursor(
        p_report_header_id      IN      expLines_headerID,
        p_personal_lines_cursor OUT NOCOPY DisplayXpenseLinesCursor)
RETURN BOOLEAN;
-------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetNoOfBothPayPersonalLines(p_report_header_id IN  expLines_headerID,
                             p_personal_count            OUT NOCOPY NUMBER)
RETURN BOOLEAN;
-------------------------------------------------------------------

PROCEDURE clearAuditReturnReasonInstr(
                                   p_report_header_id IN expLines_headerID);
-------------------------------------------------------------------
/**
 * aling
 * Check to see if there are any policy violation
 */
FUNCTION AnyPolicyViolation(p_report_header_id IN  expLines_headerID)
RETURN BOOLEAN;
------------------------------------------------------------------------------
FUNCTION GetLineCCIDCursor(p_reportId         IN  expLines_headerID,
                           p_line_cursor      OUT NOCOPY ExpLineCCIDCursor)
RETURN BOOLEAN;

-------------------------------------------------------------------
PROCEDURE resetApplyAdvances(
  p_report_header_id     IN expLines_headerID);
-------------------------------------------------------------------

FUNCTION ReportInclsCCardLines(p_report_header_id IN NUMBER) RETURN VARCHAR2;  -- 5666256:  fp of 5464957 when accessing confirmation page from e-mail or comming from DBI

--------------------------------------------------------------------------------------------
FUNCTION GetNumImageShortpaidLines(p_report_header_id 		IN expLines_headerID,
				   p_count            OUT NOCOPY NUMBER) RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetNumBothShortpaidLines(p_report_header_id 		IN expLines_headerID,
				   p_count            OUT NOCOPY NUMBER) RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION AddUnverifiedImgShortpaidLines(
p_new_expense_report_id         IN expLines_headerID,
p_orig_expense_report_id        IN expLines_headerID
) RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION AddUnverifiedBtShortpaidLines(
p_new_expense_report_id         IN expLines_headerID,
p_orig_expense_report_id        IN expLines_headerID
) RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
FUNCTION GetNumOriginalShortpaidLines(p_report_header_id           IN expLines_headerID,
                                   p_count            OUT NOCOPY NUMBER) RETURN BOOLEAN;
--------------------------------------------------------------------------------------------

END AP_WEB_DB_EXPLINE_PKG;

/
