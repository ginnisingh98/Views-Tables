--------------------------------------------------------
--  DDL for Package Body AP_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APPROVAL_PKG" AS
/* $Header: apaprvlb.pls 120.140.12010000.82 2010/07/20 19:45:21 anarun ship $ */

  G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_APPROVAL_PKG';
  G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
  G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
  G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
  G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
  G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
  G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
  G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

  G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_APPROVAL_PKG.';

/*===========================================================================
 | Private Global Variable specification
 *==========================================================================*/
   g_org_id            NUMBER(15); /* Bug 3700128. MOAC Project */

/*============================================================================
 | Private (Non Public) Procedure Specifications
 *===========================================================================*/
FUNCTION Inv_Needs_Approving(
             p_invoice_id        IN NUMBER,
             p_run_option        IN VARCHAR2,
             p_calling_sequence  IN VARCHAR2) RETURN BOOLEAN;

FUNCTION Get_Inv_Matched_Status(
             p_invoice_id        IN NUMBER,
             p_calling_sequence  IN VARCHAR2) RETURN BOOLEAN;

PROCEDURE Get_Invoice_Statuses(
              p_invoice_id       IN            NUMBER,
              p_holds_count      IN OUT NOCOPY NUMBER,
              p_approval_status  IN OUT NOCOPY VARCHAR2,
              p_calling_sequence IN            VARCHAR2);

PROCEDURE Update_Inv_Dists_To_Approved(
              p_invoice_id       IN            NUMBER,
              p_user_id          IN            NUMBER,
              p_calling_sequence IN            VARCHAR2);

PROCEDURE Update_Inv_Dists_To_Selected(
              p_invoice_id       IN            NUMBER,
              P_line_number      IN            NUMBER,
              p_run_option       IN            VARCHAR2,
              p_calling_sequence IN            VARCHAR2);

PROCEDURE Approval_Init(
	      p_org_id			     IN            NUMBER,
	      p_invoice_id		     IN 	   NUMBER,
              p_invoice_type                 IN            VARCHAR2 DEFAULT NULL,
              p_tolerance_id                 IN            NUMBER,
              p_services_tolerance_id        IN            NUMBER,
	      p_conc_flag		     IN		   VARCHAR2,
              p_set_of_books_id              IN OUT NOCOPY NUMBER,
              p_recalc_pay_sched_flag        IN OUT NOCOPY VARCHAR2,
              p_sys_xrate_gain_ccid          IN OUT NOCOPY NUMBER,
              p_sys_xrate_loss_ccid          IN OUT NOCOPY NUMBER,
              p_base_currency_code           IN OUT NOCOPY VARCHAR2,
              p_inv_enc_type_id              IN OUT NOCOPY NUMBER,
              p_purch_enc_type_id            IN OUT NOCOPY NUMBER,
              p_gl_date_from_receipt_flag    IN OUT NOCOPY VARCHAR2,
              p_receipt_acc_days             IN OUT NOCOPY NUMBER,
              p_system_user                  IN OUT NOCOPY NUMBER,
              p_user_id                      IN OUT NOCOPY NUMBER,
              p_goods_ship_amt_tolerance     IN OUT NOCOPY NUMBER,
              p_goods_rate_amt_tolerance     IN OUT NOCOPY NUMBER,
              p_goods_total_amt_tolerance    IN OUT NOCOPY NUMBER,
	      p_services_ship_amt_tolerance  IN OUT NOCOPY NUMBER,
	      p_services_rate_amt_tolerance  IN OUT NOCOPY NUMBER,
	      p_services_total_amt_tolerance IN OUT NOCOPY NUMBER,
              p_price_tolerance              IN OUT NOCOPY NUMBER,
              p_qty_tolerance                IN OUT NOCOPY NUMBER,
              p_qty_rec_tolerance            IN OUT NOCOPY NUMBER,
	      p_amt_tolerance                IN OUT NOCOPY NUMBER,
	      p_amt_rec_tolerance            IN OUT NOCOPY NUMBER,
              p_max_qty_ord_tolerance        IN OUT NOCOPY NUMBER,
              p_max_qty_rec_tolerance        IN OUT NOCOPY NUMBER,
	      p_max_amt_ord_tolerance	     IN OUT NOCOPY NUMBER,
	      p_max_amt_rec_tolerance        IN OUT NOCOPY NUMBER,
              p_invoice_line_count           OUT NOCOPY NUMBER,   --Bug 6684139
              p_calling_sequence             IN            VARCHAR2);

PROCEDURE Set_Hold(
              p_invoice_id          IN            NUMBER,
              p_line_location_id    IN            NUMBER,
              p_rcv_transaction_id  IN            NUMBER,
              p_hold_lookup_code    IN            VARCHAR2,
              p_hold_reason         IN            VARCHAR2,
              p_holds               IN OUT NOCOPY HOLDSARRAY,
              p_holds_count         IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence    IN            VARCHAR2);

PROCEDURE Count_Hold(
              p_hold_lookup_code    IN            VARCHAR2,
              p_holds               IN OUT NOCOPY HOLDSARRAY,
              p_count               IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence    IN            VARCHAR2);

PROCEDURE Get_Release_Lookup_For_Hold(
              p_hold_lookup_code    IN            VARCHAR2,
              p_release_lookup_code IN OUT NOCOPY VARCHAR2,
              p_calling_sequence    IN            VARCHAR2);

PROCEDURE Withhold_Tax_On(
              p_invoice_id              IN NUMBER,
              p_gl_date_from_receipt    IN VARCHAR2,
              p_last_updated_by         IN NUMBER,
              p_last_update_login       IN NUMBER,
              p_program_application_id  IN NUMBER,
              p_program_id              IN NUMBER,
              p_request_id              IN NUMBER,
              p_system_user             IN NUMBER,
              p_holds                   IN OUT NOCOPY HOLDSARRAY,
              p_holds_count             IN OUT NOCOPY COUNTARRAY,
              p_release_count           IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence        IN VARCHAR2);

PROCEDURE Line_Base_Amount_Calculation(
              p_invoice_id              IN            NUMBER,
              p_invoice_currency_code   IN            VARCHAR2,
              p_base_currency_code      IN            VARCHAR2,
              p_exchange_rate           IN            NUMBER,
              p_need_to_round_flag      IN            VARCHAR2 DEFAULT 'N',
              p_calling_sequence        IN            VARCHAR2);

PROCEDURE Dist_Base_Amount_Calculation(
              p_invoice_id              IN            NUMBER,
              p_invoice_line_number     IN            NUMBER,
              p_invoice_currency_code   IN            VARCHAR2,
              p_base_currency_code      IN            VARCHAR2,
              p_invoice_exchange_rate   IN            NUMBER,
              p_need_to_round_flag      IN            VARCHAR2 DEFAULT 'N',
              p_calling_sequence        IN            VARCHAR2);

PROCEDURE Execute_General_Checks(
              p_invoice_id                IN            NUMBER,
              p_set_of_books_id           IN            NUMBER,
              p_base_currency_code        IN            VARCHAR2,
              p_invoice_amount            IN            NUMBER,
              p_base_amount               IN            NUMBER,
              p_invoice_currency_code     IN            VARCHAR2,
              p_invoice_amount_limit      IN            NUMBER,
              p_hold_future_payments_flag IN            VARCHAR2,
              p_system_user               IN            NUMBER,
              p_holds                     IN OUT NOCOPY HOLDSARRAY,
              p_holds_count               IN OUT NOCOPY COUNTARRAY,
              p_release_count             IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence          IN            VARCHAR2);

PROCEDURE Check_Dist_Variance(
              p_invoice_id                  IN            NUMBER,
              p_invoice_line_number         IN            NUMBER,
              p_system_user                 IN            NUMBER,
              p_holds                       IN OUT NOCOPY HOLDSARRAY,
              p_holds_count                 IN OUT NOCOPY COUNTARRAY,
              p_release_count               IN OUT NOCOPY COUNTARRAY,
              p_distribution_variance_exist    OUT NOCOPY BOOLEAN,
              p_calling_sequence            IN            VARCHAR2);

PROCEDURE Check_Line_Variance(
              p_invoice_id                  IN            NUMBER,
              p_system_user                 IN            NUMBER,
              p_holds                       IN OUT NOCOPY HOLDSARRAY,
              p_holds_count                 IN OUT NOCOPY COUNTARRAY,
              p_release_count               IN OUT NOCOPY COUNTARRAY,
              p_line_variance_hold_exist       OUT NOCOPY BOOLEAN,
              p_calling_sequence            IN            VARCHAR2,
	      p_base_currency_code          IN            VARCHAR2);   --bug7271262

PROCEDURE Check_Prepaid_Amount(
              p_invoice_id                IN            NUMBER,
              p_system_user               IN            NUMBER,
              p_holds                     IN OUT NOCOPY HOLDSARRAY,
              p_holds_count               IN OUT NOCOPY COUNTARRAY,
              p_release_count             IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence          IN            VARCHAR2);

PROCEDURE Check_No_Rate(
              p_invoice_id                IN            NUMBER,
              p_base_currency_code        IN            VARCHAR2,
              p_system_user               IN            NUMBER,
              p_holds                     IN OUT NOCOPY HOLDSARRAY,
              p_holds_count               IN OUT NOCOPY COUNTARRAY,
              p_release_count             IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence          IN            VARCHAR2);

	      --bug9296410
PROCEDURE CHECK_PROJECT_COMMITMENTS(
              p_invoice_id                IN           NUMBER,
              p_system_user               IN            NUMBER,
              p_holds                     IN OUT NOCOPY HOLDSARRAY,
              p_holds_count               IN OUT NOCOPY COUNTARRAY,
              p_release_count             IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence          IN            VARCHAR2);

PROCEDURE Check_invoice_vendor(
              p_invoice_id                IN            NUMBER,
              p_base_currency_code        IN            VARCHAR2,
              p_invoice_amount            IN            NUMBER,
              p_base_amount               IN            NUMBER,
              p_invoice_currency_code     IN            VARCHAR2,
              p_invoice_amount_limit      IN            NUMBER,
              p_hold_future_payments_flag IN            VARCHAR2,
              p_system_user               IN            NUMBER,
              p_holds                     IN OUT NOCOPY HOLDSARRAY,
              p_holds_count               IN OUT NOCOPY COUNTARRAY,
              p_release_count             IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence          IN            VARCHAR2);

PROCEDURE  Check_Manual_AWT_Segments(
              p_invoice_id                IN            NUMBER,
              p_system_user               IN            NUMBER,
              p_holds                     IN OUT NOCOPY HOLDSARRAY,
              p_holds_count               IN OUT NOCOPY COUNTARRAY,
              p_release_count             IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence          IN            VARCHAR2);

PROCEDURE Check_PO_Required(
              p_invoice_id                IN            NUMBER,
              p_system_user               IN            NUMBER,
              p_holds                     IN OUT NOCOPY HOLDSARRAY,
              p_holds_count               IN OUT NOCOPY COUNTARRAY,
              p_release_count             IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence          IN            VARCHAR2);

PROCEDURE Check_Invalid_Dist_Acct(
              p_invoice_id                IN            NUMBER,
              p_system_user               IN            NUMBER,
              p_holds                     IN OUT NOCOPY HOLDSARRAY,
              p_holds_count               IN OUT NOCOPY COUNTARRAY,
              p_release_count             IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence          IN            VARCHAR2);

FUNCTION Check_hold_batch_releaseable(
             p_hold_name               IN            VARCHAR2,
             p_calling_sequence        IN            VARCHAR2) RETURN VARCHAR2;

PROCEDURE Generate_Account_Event(
              p_invoice_id             IN            NUMBER,
              p_calling_sequence       IN            VARCHAR2);

PROCEDURE Update_Total_Dist_Amount(
              p_invoice_id             IN            NUMBER,
              p_calling_sequence       IN            VARCHAR2);

PROCEDURE Exclude_Tax_Freight_From_Disc(
			p_invoice_id IN NUMBER,
                        p_exclude_tax_from_discount 	IN VARCHAR2,
			p_exclude_freight_from_disc 	IN VARCHAR2,
			p_net_of_retainage_flag         IN VARCHAR2, --9356460
                        p_invoice_type_lookup_code 	IN VARCHAR2,
                        p_curr_calling_sequence		IN VARCHAR2) ;

PROCEDURE update_payment_schedule_prepay(
                p_invoice_id                    IN      NUMBER,
                p_apply_amount                  IN      NUMBER,
                p_amount_positive               IN      VARCHAR2,
                p_payment_currency_code         IN      VARCHAR2,
                p_user_id                       IN      NUMBER,
                p_last_update_login             IN      NUMBER,
                p_calling_sequence              IN      VARCHAR2);

FUNCTION validate_period (p_invoice_id IN NUMBER) RETURN BOOLEAN;

PROCEDURE Manual_Withhold_Tax(
		p_invoice_id              IN NUMBER,
		p_last_updated_by         IN NUMBER,
		p_last_update_login       IN NUMBER,
		p_calling_sequence        IN VARCHAR2);

/* Bug 7393338 added this procedure*/
PROCEDURE Update_Pay_Sched_For_Awt(p_invoice_id         IN NUMBER,
                        p_last_updated_by               IN NUMBER,
                        p_last_update_login             IN NUMBER,
                        p_calling_sequence              IN VARCHAR2);

PROCEDURE createPaymentSchedules(
		p_invoice_id		IN NUMBER,
		p_calling_sequence	IN VARCHAR2);

Procedure Print_Debug(
		p_api_name		IN VARCHAR2,
		p_debug_info		IN VARCHAR2);

CURSOR invoice_line_cur (c_invoice_id NUMBER) IS
  SELECT  INVOICE_ID,
          LINE_NUMBER,
          LINE_TYPE_LOOKUP_CODE,
          REQUESTER_ID,
          DESCRIPTION,
          LINE_SOURCE,
          ORG_ID,
          LINE_GROUP_NUMBER,
          INVENTORY_ITEM_ID,
          ITEM_DESCRIPTION,
          SERIAL_NUMBER,
          MANUFACTURER,
          MODEL_NUMBER,
          WARRANTY_NUMBER,
          GENERATE_DISTS,
          MATCH_TYPE,
          DISTRIBUTION_SET_ID,
          ACCOUNT_SEGMENT,
          BALANCING_SEGMENT,
          COST_CENTER_SEGMENT,
          OVERLAY_DIST_CODE_CONCAT,
          DEFAULT_DIST_CCID,
          PRORATE_ACROSS_ALL_ITEMS,
          ACCOUNTING_DATE,
          PERIOD_NAME ,
          DEFERRED_ACCTG_FLAG ,
          DEF_ACCTG_START_DATE ,
          DEF_ACCTG_END_DATE,
          DEF_ACCTG_NUMBER_OF_PERIODS,
          DEF_ACCTG_PERIOD_TYPE ,
          SET_OF_BOOKS_ID,
          AMOUNT,
          BASE_AMOUNT,
          ROUNDING_AMT,
          QUANTITY_INVOICED,
          UNIT_MEAS_LOOKUP_CODE ,
          UNIT_PRICE,
          WFAPPROVAL_STATUS,
          DISCARDED_FLAG,
          ORIGINAL_AMOUNT,
          ORIGINAL_BASE_AMOUNT ,
          ORIGINAL_ROUNDING_AMT ,
          CANCELLED_FLAG ,
          INCOME_TAX_REGION,
          TYPE_1099   ,
          STAT_AMOUNT  ,
          PREPAY_INVOICE_ID ,
          PREPAY_LINE_NUMBER  ,
          INVOICE_INCLUDES_PREPAY_FLAG ,
          CORRECTED_INV_ID ,
          CORRECTED_LINE_NUMBER ,
          PO_HEADER_ID,
          PO_LINE_ID  ,
          PO_RELEASE_ID ,
          PO_LINE_LOCATION_ID ,
          PO_DISTRIBUTION_ID,
          RCV_TRANSACTION_ID,
          FINAL_MATCH_FLAG,
          ASSETS_TRACKING_FLAG ,
          ASSET_BOOK_TYPE_CODE ,
          ASSET_CATEGORY_ID ,
          PROJECT_ID ,
          TASK_ID ,
          EXPENDITURE_TYPE ,
          EXPENDITURE_ITEM_DATE ,
          EXPENDITURE_ORGANIZATION_ID ,
          PA_QUANTITY,
          PA_CC_AR_INVOICE_ID ,
          PA_CC_AR_INVOICE_LINE_NUM ,
          PA_CC_PROCESSED_CODE ,
          AWARD_ID,
          AWT_GROUP_ID ,
          REFERENCE_1 ,
          REFERENCE_2 ,
          RECEIPT_VERIFIED_FLAG  ,
          RECEIPT_REQUIRED_FLAG ,
          RECEIPT_MISSING_FLAG ,
          JUSTIFICATION  ,
          EXPENSE_GROUP ,
          START_EXPENSE_DATE ,
          END_EXPENSE_DATE ,
          RECEIPT_CURRENCY_CODE  ,
          RECEIPT_CONVERSION_RATE,
          RECEIPT_CURRENCY_AMOUNT ,
          DAILY_AMOUNT ,
          WEB_PARAMETER_ID ,
          ADJUSTMENT_REASON ,
          MERCHANT_DOCUMENT_NUMBER ,
          MERCHANT_NAME ,
          MERCHANT_REFERENCE ,
          MERCHANT_TAX_REG_NUMBER,
          MERCHANT_TAXPAYER_ID  ,
          COUNTRY_OF_SUPPLY,
          CREDIT_CARD_TRX_ID ,
          COMPANY_PREPAID_INVOICE_ID,
          CC_REVERSAL_FLAG ,
          CREATION_DATE ,
          CREATED_BY,
          LAST_UPDATED_BY ,
          LAST_UPDATE_DATE ,
          LAST_UPDATE_LOGIN ,
          PROGRAM_APPLICATION_ID ,
          PROGRAM_ID ,
          PROGRAM_UPDATE_DATE,
          REQUEST_ID ,
          ATTRIBUTE_CATEGORY,
          ATTRIBUTE1,
          ATTRIBUTE2 ,
          ATTRIBUTE3 ,
          ATTRIBUTE4 ,
          ATTRIBUTE5 ,
          ATTRIBUTE6 ,
          ATTRIBUTE7 ,
          ATTRIBUTE8,
          ATTRIBUTE9 ,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13 ,
          ATTRIBUTE14,
          ATTRIBUTE15,
          GLOBAL_ATTRIBUTE_CATEGORY,
          GLOBAL_ATTRIBUTE1,
          GLOBAL_ATTRIBUTE2,
          GLOBAL_ATTRIBUTE3,
          GLOBAL_ATTRIBUTE4 ,
          GLOBAL_ATTRIBUTE5 ,
          GLOBAL_ATTRIBUTE6 ,
          GLOBAL_ATTRIBUTE7 ,
          GLOBAL_ATTRIBUTE8 ,
          GLOBAL_ATTRIBUTE9 ,
          GLOBAL_ATTRIBUTE10,
          GLOBAL_ATTRIBUTE11,
          GLOBAL_ATTRIBUTE12 ,
          GLOBAL_ATTRIBUTE13 ,
          GLOBAL_ATTRIBUTE14 ,
          GLOBAL_ATTRIBUTE15 ,
          GLOBAL_ATTRIBUTE16 ,
          GLOBAL_ATTRIBUTE17 ,
          GLOBAL_ATTRIBUTE18 ,
          GLOBAL_ATTRIBUTE19 ,
          GLOBAL_ATTRIBUTE20 ,
          INCLUDED_TAX_AMOUNT,
          PRIMARY_INTENDED_USE,
          APPLICATION_ID,
          PRODUCT_TABLE,
          REFERENCE_KEY1,
          REFERENCE_KEY2,
          REFERENCE_KEY3,
          REFERENCE_KEY4,
          REFERENCE_KEY5,
          SHIP_TO_LOCATION_ID,
         PAY_AWT_GROUP_ID     --bug 7022001
    FROM ap_invoice_lines_all
   WHERE invoice_id = c_invoice_id
   ORDER BY decode(line_type_lookup_code,'ITEM',1,2), line_number;

--Bug 8346277
CURSOR invoice_line_mawt_cur(c_invoice_id NUMBER)
IS
  SELECT INVOICE_ID
       , LINE_NUMBER
       , LINE_TYPE_LOOKUP_CODE
       , REQUESTER_ID
       , DESCRIPTION
       , LINE_SOURCE
       , ORG_ID
       , LINE_GROUP_NUMBER
       , INVENTORY_ITEM_ID
       , ITEM_DESCRIPTION
       , SERIAL_NUMBER
       , MANUFACTURER
       , MODEL_NUMBER
       , WARRANTY_NUMBER
       , GENERATE_DISTS
       , MATCH_TYPE
       , DISTRIBUTION_SET_ID
       , ACCOUNT_SEGMENT
       , BALANCING_SEGMENT
       , COST_CENTER_SEGMENT
       , OVERLAY_DIST_CODE_CONCAT
       , DEFAULT_DIST_CCID
       , PRORATE_ACROSS_ALL_ITEMS
       , ACCOUNTING_DATE
       , PERIOD_NAME
       , DEFERRED_ACCTG_FLAG
       , DEF_ACCTG_START_DATE
       , DEF_ACCTG_END_DATE
       , DEF_ACCTG_NUMBER_OF_PERIODS
       , DEF_ACCTG_PERIOD_TYPE
       , SET_OF_BOOKS_ID
       , AMOUNT
       , BASE_AMOUNT
       , ROUNDING_AMT
       , QUANTITY_INVOICED
       , UNIT_MEAS_LOOKUP_CODE
       , UNIT_PRICE
       , WFAPPROVAL_STATUS
       , DISCARDED_FLAG
       , ORIGINAL_AMOUNT
       , ORIGINAL_BASE_AMOUNT
       , ORIGINAL_ROUNDING_AMT
       , CANCELLED_FLAG
       , INCOME_TAX_REGION
       , TYPE_1099
       , STAT_AMOUNT
       , PREPAY_INVOICE_ID
       , PREPAY_LINE_NUMBER
       , INVOICE_INCLUDES_PREPAY_FLAG
       , CORRECTED_INV_ID
       , CORRECTED_LINE_NUMBER
       , PO_HEADER_ID
       , PO_LINE_ID
       , PO_RELEASE_ID
       , PO_LINE_LOCATION_ID
       , PO_DISTRIBUTION_ID
       , RCV_TRANSACTION_ID
       , FINAL_MATCH_FLAG
       , ASSETS_TRACKING_FLAG
       , ASSET_BOOK_TYPE_CODE
       , ASSET_CATEGORY_ID
       , PROJECT_ID
       , TASK_ID
       , EXPENDITURE_TYPE
       , EXPENDITURE_ITEM_DATE
       , EXPENDITURE_ORGANIZATION_ID
       , PA_QUANTITY
       , PA_CC_AR_INVOICE_ID
       , PA_CC_AR_INVOICE_LINE_NUM
       , PA_CC_PROCESSED_CODE
       , AWARD_ID
       , AWT_GROUP_ID
       , REFERENCE_1
       , REFERENCE_2
       , RECEIPT_VERIFIED_FLAG
       , RECEIPT_REQUIRED_FLAG
       , RECEIPT_MISSING_FLAG
       , JUSTIFICATION
       , EXPENSE_GROUP
       , START_EXPENSE_DATE
       , END_EXPENSE_DATE
       , RECEIPT_CURRENCY_CODE
       , RECEIPT_CONVERSION_RATE
       , RECEIPT_CURRENCY_AMOUNT
       , DAILY_AMOUNT
       , WEB_PARAMETER_ID
       , ADJUSTMENT_REASON
       , MERCHANT_DOCUMENT_NUMBER
       , MERCHANT_NAME
       , MERCHANT_REFERENCE
       , MERCHANT_TAX_REG_NUMBER
       , MERCHANT_TAXPAYER_ID
       , COUNTRY_OF_SUPPLY
       , CREDIT_CARD_TRX_ID
       , COMPANY_PREPAID_INVOICE_ID
       , CC_REVERSAL_FLAG
       , CREATION_DATE
       , CREATED_BY
       , LAST_UPDATED_BY
       , LAST_UPDATE_DATE
       , LAST_UPDATE_LOGIN
       , PROGRAM_APPLICATION_ID
       , PROGRAM_ID
       , PROGRAM_UPDATE_DATE
       , REQUEST_ID
       , ATTRIBUTE_CATEGORY
       , ATTRIBUTE1
       , ATTRIBUTE2
       , ATTRIBUTE3
       , ATTRIBUTE4
       , ATTRIBUTE5
       , ATTRIBUTE6
       , ATTRIBUTE7
       , ATTRIBUTE8
       , ATTRIBUTE9
       , ATTRIBUTE10
       , ATTRIBUTE11
       , ATTRIBUTE12
       , ATTRIBUTE13
       , ATTRIBUTE14
       , ATTRIBUTE15
       , GLOBAL_ATTRIBUTE_CATEGORY
       , GLOBAL_ATTRIBUTE1
       , GLOBAL_ATTRIBUTE2
       , GLOBAL_ATTRIBUTE3
       , GLOBAL_ATTRIBUTE4
       , GLOBAL_ATTRIBUTE5
       , GLOBAL_ATTRIBUTE6
       , GLOBAL_ATTRIBUTE7
       , GLOBAL_ATTRIBUTE8
       , GLOBAL_ATTRIBUTE9
       , GLOBAL_ATTRIBUTE10
       , GLOBAL_ATTRIBUTE11
       , GLOBAL_ATTRIBUTE12
       , GLOBAL_ATTRIBUTE13
       , GLOBAL_ATTRIBUTE14
       , GLOBAL_ATTRIBUTE15
       , GLOBAL_ATTRIBUTE16
       , GLOBAL_ATTRIBUTE17
       , GLOBAL_ATTRIBUTE18
       , GLOBAL_ATTRIBUTE19
       , GLOBAL_ATTRIBUTE20
       , INCLUDED_TAX_AMOUNT
       , PRIMARY_INTENDED_USE
       , APPLICATION_ID
       , PRODUCT_TABLE
       , REFERENCE_KEY1
       , REFERENCE_KEY2
       , REFERENCE_KEY3
       , REFERENCE_KEY4
       , REFERENCE_KEY5
       , SHIP_TO_LOCATION_ID
       , PAY_AWT_GROUP_ID
    FROM ap_invoice_lines_all
   WHERE invoice_id            = c_invoice_id
     AND line_type_lookup_code = 'AWT'
     AND line_source           = 'MANUAL LINE ENTRY'
ORDER BY line_number;


PROCEDURE initialize_invoice_holds(
			p_invoice_id       IN NUMBER,
			p_calling_sequence IN VARCHAR2);

TYPE holds_rec_type IS RECORD (
		hold_lookup_code	ap_holds_all.hold_lookup_code%type,
		hold_status		varchar2(30),
		invoice_id		ap_holds_all.invoice_id%type,
		hold_reason		ap_holds_all.hold_reason%type,
		release_lookup_code	ap_holds_all.release_lookup_code%type,
		line_location_id	ap_holds_all.line_location_id%type,
		rcv_transaction_id	ap_holds_all.rcv_transaction_id%type,
		last_updated_by		ap_holds_all.last_updated_by%type,
		responsibility_id	ap_holds_all.responsibility_id%type);

TYPE holds_tab_type IS TABLE OF holds_rec_type INDEX BY BINARY_INTEGER;

g_holds_tab holds_tab_type;

Procedure Count_Org_Hold(
              p_org_id              IN NUMBER,
              p_hold_lookup_code    IN VARCHAR2,
              p_place_or_release    IN VARCHAR2,
              p_calling_sequence    IN VARCHAR2);


/*============================================================================
 | Procedure Definitions
 *===========================================================================*/

/*=============================================================================
 |  PUBLIC PROCEDURE  APPROVE
 |
 |  Description
 |      Online Approval and later batch approval
 |
 |  PARAMETERS
 |      p_run_option              Run Option to indicate whether to approve
 |                                only invoices with unapproved distributions
 |                                or all invoices ('New' or 'All)
 |      p_invoice_batch_id        Invoice Batch Id (For Batch Approval)
 |      p_begin_invoice_date      Begin Invoice Date (Selection criteria)
 |      p_end_invoice_date        End of Invoice Date (Selection criteria)
 |      p_pay_group               Pay Group(Select criteria for Batch Approval)
 |      p_invoice_id              Invoice_id
 |      p_entered_by              Entered_by User id
 |      p_set_of_books_id         Set of books id
 |                                (Selection criteria for Batch Approval)
 |      p_trace_option
 |      p_conc_flag               Indicate whether the approval process is a
 |                                concurrent process or not or if it is online
 |      p_holds_count             Return Hold Count of invoice (For Online
 |                                 Approval called by invoice workbench)
 |      p_approval_status         Return Approval Status of invoice
 |                                (For Online Approval called by form)
 |      p_calling_sequence        Debugging string to indicate path of module
 |                                calls to be printed out upon error.
 |      p_debug_switch            Debug switch to be turned on or off
 |
 |   PROGRAM FLOW
 |
 |     Retrieve system variables to be used by Approval Program
 |     For each invoice
 |     IF invoice needs approving (i.e. not the case where run_option is 'New'
 |         and the invoice doesn't have any unapproved distributions)
 |       IF Accrual Basis is being used
 |         IF automatic offsets is enabled
 |       Populate Invoice Dist liability account
 |     Calculate Tax (Etax API) which will determine the tax amt and
 |        whether it is inclusive or exclusive...
 |     Check Line Variance
 |     Calculate Base Amount and round at Line level
 |     Call Etax api to 'Calculate Tax', which might return exclusive tax lines
 |       and/or inclusive tax amount.
 |     Open a Lines Cursor - loop for each Line
 |        If inclusive tax is returned by tax calculation api, then create taxable
 |	    distributions for (line_amount - inclusive tax amount).
 |        If Line need to generate distributions
 |           check sufficient line data
 |           Generate distributions
 |        end if
 |        Update Invoice Distributions as selected for approval
 |        Execute Distribution variance check
 |        IPV/ERV creation and valid ERV ccid check
 |     Close Line Cursor if no more line to check
 |     Call Etax api 'Determine Recovery' to create Tax Distributions for the invoice.
 |     Open a Lines Cursor - loop for each Line
 |        Base amount calculation and rounding at Distribution Level for line
 |     Close Line Cursor if no more line to check
 |     Execute General Invoice Checks
 |     Get invoice matched status
 |     IF invoice is matched
 |       Execute Quantity Variance Check
 |       Execute Matched Checks
 |       Execute PO Final Close Check
 |     Validate Invoice for Tax (etax api), which will validate
 |       the document for tax information.
 |     IF invoice is not a matched prepayment
 |       Execute Funds Control (Funds Reservation)
 |       Execute Withholding Tax
 |       Update Invoice Dists to Appropriate Approval Status
 |   End Loop
 |   Accounting Event Generation
 |   IF Recalculate Payment Schedule Option is enabled
 |     Execute Due Date Sweeper
 |   If online approval then
 |     Calculate Invoice Hold Count and Release Count
 |     Print out appropriate Return Message
 |   End If
 |
 |   KNOWN ISSUES:
 |     p_begin_invoice_date,
 |     p_end_invoice_date,
 |     p_pay_group,
 |     p_entered_by,
 |     p_set_of_books_id,
 |     p_trace_option
 |     are not needed here in this
 |     procedure. The logic of selecting all invoices included in a batch
 |     is in Invoice Validation Report. Code clean up should be done when
 |     invoice work bench form is being modified. Now is modified to have
 |     default value so that these two parameters can be omitted.
 *============================================================================*/

PROCEDURE Approve(
              p_run_option          IN            VARCHAR2,
              p_invoice_batch_id    IN            NUMBER,
              p_begin_invoice_date  IN            DATE DEFAULT NULL,
              p_end_invoice_date    IN            DATE DEFAULT NULL,
              p_vendor_id           IN            NUMBER,
              p_pay_group           IN            VARCHAR2,
              p_invoice_id          IN            NUMBER,
              p_entered_by          IN            NUMBER,
              p_set_of_books_id     IN            NUMBER,
              p_trace_option        IN            VARCHAR2,
              p_conc_flag           IN            VARCHAR2,
              p_holds_count         IN OUT NOCOPY NUMBER,
              p_approval_status     IN OUT NOCOPY VARCHAR2,
              p_funds_return_code   OUT    NOCOPY VARCHAR2,
	      p_calling_mode	    IN		  VARCHAR2 DEFAULT 'APPROVE',
              p_calling_sequence    IN            VARCHAR2,
              p_debug_switch        IN            VARCHAR2 DEFAULT 'N',
              p_budget_control      IN            VARCHAR2 DEFAULT 'Y',
              p_commit              IN            VARCHAR2 DEFAULT 'Y') IS

  CURSOR approve_invoice_cur IS
  SELECT AI.invoice_id,
         AI.invoice_num,
         AI.invoice_amount,
         AI.base_amount,
         AI.exchange_rate,
         AI.invoice_currency_code,
         PVS.invoice_amount_limit,
         nvl(PVS.hold_future_payments_flag,'N'),
         AI.invoice_type_lookup_code,
         AI.exchange_date,
         AI.exchange_rate_type,
         AI.vendor_id,
         AI.invoice_date,
	 AI.org_id,
         nvl(AI.disc_is_inv_less_tax_flag,'N'),
         nvl(AI.exclude_freight_from_discount,'N'),
         nvl(AI.net_of_retainage_flag,'N'),  --9356460
         nvl(pvs.tolerance_id,ASP.tolerance_id),			--added nvl for bug 8425996
         nvl(pvs.services_tolerance_id,ASP.services_tolerance_id)	--added nvl for bug 8425996
  FROM   ap_invoices_all AI,
         ap_suppliers PV,
         ap_supplier_sites_all PVS,
	 ap_system_parameters_all ASP					--added table for bug 8425996
  WHERE  AI.invoice_id = p_invoice_id
  AND    AI.vendor_id = PV.vendor_id
  AND    AI.vendor_site_id = PVS.vendor_site_id
  AND    ASP.org_id = AI.org_id;


  -- Payment Requests: Cursor for payment request type of invoices
  CURSOR approve_pay_request_cur IS
  SELECT AI.invoice_id,
         AI.invoice_num,
         AI.invoice_amount,
         AI.base_amount,
         AI.exchange_rate,
         AI.invoice_currency_code,
         NULL, -- invoice_amount_limit,
         'N',  -- hold_future_payments_flag
         AI.invoice_type_lookup_code,
         AI.exchange_date,
         AI.exchange_rate_type,
         AI.vendor_id,
         AI.invoice_date,
         AI.org_id,
         nvl(AI.disc_is_inv_less_tax_flag,'N'),
         nvl(AI.exclude_freight_from_discount,'N'),
	 nvl(AI.net_of_retainage_flag,'N')  --9356460
  FROM   ap_invoices_all AI
  WHERE  AI.invoice_id = p_invoice_id;

  CURSOR invoice_type_cur IS
  SELECT invoice_type_lookup_code
  FROM   ap_invoices_all
  WHERE  invoice_id = p_invoice_id;

  l_unfreeze_count              NUMBER:= 0; --Bug9021265
  TAX_UNFREEZE_EXCEPTION        EXCEPTION;  --Bug9021265

  l_chart_of_accounts_id        NUMBER;
  l_recalc_pay_schedule_flag    VARCHAR2(1);
  l_gl_date_from_receipt        VARCHAR2(1);
  l_cash_only                   BOOLEAN;
  l_system_user                 NUMBER;

  -- Tolerance Related Variables
  l_goods_ship_amt_tolerance		NUMBER;
  l_goods_rate_amt_tolerance		NUMBER;
  l_goods_total_amt_tolerance		NUMBER;
  l_services_ship_amt_tolerance		NUMBER;
  l_services_rate_amt_tolerance		NUMBER;
  l_services_total_amt_tolerance	NUMBER;
  l_price_tol				NUMBER;
  l_qty_tol				NUMBER;
  l_qty_rec_tol                 	NUMBER;
  l_amt_tol				NUMBER;
  l_amt_rec_tol				NUMBER;
  l_max_qty_ord_tol             	NUMBER;
  l_max_qty_rec_tol             	NUMBER;
  l_max_amt_ord_tol			NUMBER;
  l_max_amt_rec_tol			NUMBER;

  l_flex_method                 VARCHAR2(25);
  l_sys_xrate_gain_ccid         NUMBER;
  l_sys_xrate_loss_ccid         NUMBER;
  l_base_currency_code          VARCHAR2(15);
  l_inv_enc_type_id             NUMBER;
  l_purch_enc_type_id           NUMBER;
  l_user_id                     NUMBER;
  l_invoice_id                  NUMBER;
  l_invoice_num                 VARCHAR2(50);
  l_holds                       HOLDSARRAY;
  l_hold_count                  COUNTARRAY;
  l_release_count               COUNTARRAY;
  l_total_hold_count            NUMBER;
  l_total_release_count         NUMBER;
  l_set_of_books_id             NUMBER;
  l_matched                     BOOLEAN;
  l_receipt_acc_days            NUMBER;
  l_return_message_name         VARCHAR2(100);
  l_any_records_flag            VARCHAR2(1)  := 'N';
  l_set_tokens                  VARCHAR2(1)  := 'N';
  num                           BINARY_INTEGER   := 1;

  l_debug_loc                   VARCHAR2(30) := 'Approval';
  l_curr_calling_sequence       VARCHAR2(2000);
  l_debug_info                  VARCHAR2(2000);

  l_exchange_rate              AP_INVOICES.exchange_rate%TYPE;
  l_exchange_rate_type         AP_INVOICES.exchange_rate_type%TYPE;
  l_exchange_date              AP_INVOICES.exchange_date%TYPE;
  l_invoice_amount             AP_INVOICES.invoice_amount%TYPE;
  l_invoice_base_amount        AP_INVOICES.base_amount%TYPE;
  l_vendor_id                  AP_INVOICES.vendor_id%TYPE;
  l_invoice_date               AP_INVOICES.invoice_date%TYPE;
  l_invoice_currency_code      AP_INVOICES.invoice_currency_code%TYPE;
  l_invoice_type               AP_INVOICES.invoice_type_lookup_code%TYPE;

  t_inv_lines_table            AP_INVOICES_PKG.t_invoice_lines_table;

  l_insufficient_data_exist     BOOLEAN := FALSE;
  l_line_variance_hold_exist    BOOLEAN := FALSE;
  l_need_to_round_flag          VARCHAR2(1) := 'Y';
  l_distribution_variance_exist BOOLEAN;
  l_result                      BOOLEAN;
  l_org_id			NUMBER;

  /* Introduced to handle Consumption Tax */
  l_invoice_amount_limit        NUMBER;
  l_hold_future_payments_flag   VARCHAR2(1);
  l_diff_flag                   VARCHAR2(1);
  l_success			BOOLEAN;
  l_error_code			VARCHAR2(4000);

  Tax_Exception			EXCEPTION;
  Global_Exception		EXCEPTION;
  LCM_Exception         EXCEPTION; --Bug 7718385
  --Retropricing
  l_invoice_type_lookup_code    AP_INVOICES_ALL.invoice_type_lookup_code%TYPE;

  l_invoice_type_pr             AP_INVOICES_ALL.invoice_type_lookup_code%TYPE;
  l_exclude_tax_from_discount   VARCHAR2(1);
  l_exclude_freight_from_disc   VARCHAR2(1);
  l_net_of_retainage_flag       VARCHAR2(1);  --9356460
  l_cur_count                   NUMBER := 0;
  l_prorate_across_all_items    VARCHAR2(1);
  l_debug_context               VARCHAR2(2000);

  l_prepay_dist_count           NUMBER;
  l_retained_amount		NUMBER;
  l_recouped_amount		NUMBER;
  l_tolerance_id		NUMBER;
  l_service_tolerance_id	NUMBER;

  l_invoice_rec			AP_APPROVAL_PKG.Invoice_Rec;

  l_api_name                  	CONSTANT VARCHAR2(200) := 'Approve';

  -- Bug 6648094
  l_dist_total      NUMBER;
  l_base_dist_total NUMBER;
  l_inv_amount      NUMBER;
  l_inv_base_amount NUMBER;
  l_item_count      NUMBER;
  l_row_count       NUMBER:=0;
  -- Bug 6648094
  l_invoice_line_count NUMBER :=0; --Bug 6684139
  l_encumbrance_exists NUMBER := 0; -- Bug 6681580

  l_inv_header_rec     ap_invoices_all%rowtype;
  l_event_class_code   zx_trx_headers_gt.event_class_code%TYPE;

    -- Project LCM 7588322
  l_lcm_return_status VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
  l_lcm_msg_count     NUMBER;
  l_lcm_msg_data      VARCHAR2(2000);
  l_lcm_used          VARCHAR2(1) := 'N';
  l_unpostable_holds_exist      VARCHAR2(1) := 'N';
  l_manual_awt_exist  number :=0; --Bug 8346277

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||p_calling_sequence;

  IF (p_debug_switch = 'Y') THEN
     g_debug_mode := 'Y';
  END IF;

  --  Print_Debug (l_api_name, 'AP_APPROVAL_PKG.APPROVE.BEGIN');
  IF g_debug_mode = 'Y' THEN
    AP_Debug_Pkg.Print(g_debug_mode, 'AP_APPROVAL_PKG.APPROVE.BEGIN' );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'AP_APPROVAL_PKG.APPROVE.BEGIN');
  END IF;


  ----------------------------------------------------------------
  l_debug_info := 'Approving INVOICE_ID: '|| p_invoice_id;
  --  Print_Debug (l_api_name, l_debug_info);
  IF g_debug_mode = 'Y' THEN
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  ----------------------------------------------------------------

  IF nvl(p_conc_flag,'N') <> 'Y' THEN
     g_org_holds.delete;
  END IF;

  IF p_calling_mode = 'CANCEL' THEN
     ----------------------------------------------------------------
     l_debug_info := 'Open Invoice_Type_Cur';
     --  Print_Debug(l_api_name, l_debug_info);
     IF g_debug_mode = 'Y' THEN
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
     END IF;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;
     ----------------------------------------------------------------
     OPEN  Invoice_Type_Cur;
     FETCH Invoice_Type_Cur
      INTO l_invoice_type_pr;
     CLOSE Invoice_Type_Cur;
  END IF;


  IF (p_calling_mode = 'PAYMENT REQUEST') OR
     (p_calling_mode = 'CANCEL' and l_invoice_type_pr = 'PAYMENT REQUEST')  THEN

     ----------------------------------------------------------------
     l_debug_info := 'Open Approve_Pay_Request_Cur';
     --  Print_Debug(l_api_name, l_debug_info);
     IF g_debug_mode = 'Y' THEN
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
     END IF;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;
     ----------------------------------------------------------------
     OPEN Approve_Pay_Request_Cur;
     FETCH Approve_Pay_Request_Cur
     INTO l_invoice_id,
          l_invoice_num,
          l_invoice_amount,
          l_invoice_base_amount,
          l_exchange_rate,
          l_invoice_currency_code,
          l_invoice_amount_limit,
          l_hold_future_payments_flag,
          l_invoice_type,
          l_exchange_date,
          l_exchange_rate_type,
          l_vendor_id,
          l_invoice_date,
          g_org_id,
          l_exclude_tax_from_discount,
          l_exclude_freight_from_disc,
	  l_net_of_retainage_flag;   --9356460

  ELSE
     ----------------------------------------------------------------
     l_debug_info := 'Open Approve_Invoice_Cur';
     --  Print_Debug(l_api_name, l_debug_info);
     IF g_debug_mode = 'Y' THEN
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
     END IF;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;
     ----------------------------------------------------------------
     OPEN Approve_Invoice_Cur;
     FETCH Approve_Invoice_Cur
     INTO l_invoice_id,
          l_invoice_num,
          l_invoice_amount,
          l_invoice_base_amount,
          l_exchange_rate,
          l_invoice_currency_code,
          l_invoice_amount_limit,
          l_hold_future_payments_flag,
          l_invoice_type,
          l_exchange_date,
          l_exchange_rate_type,
          l_vendor_id,
          l_invoice_date,
          g_org_id,
          l_exclude_tax_from_discount,
          l_exclude_freight_from_disc,
	  l_net_of_retainage_flag,   --9356460
	  l_tolerance_id,
	  l_service_tolerance_id;

     IF nvl(p_conc_flag,'N') <> 'Y' THEN
        ----------------------------------------------------------------
        l_debug_info := 'Cache Tolerance Templates';
        --  Print_Debug(l_api_name, l_debug_info);
        IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ----------------------------------------------------------------
        Cache_Tolerance_Templates(
                        l_tolerance_id,
                        l_service_tolerance_id,
                        l_curr_calling_sequence);
     END IF;

  END IF;

  ----------------------------------------------------------------
  l_debug_info := 'Retrieve System Options';
  --  Print_Debug(l_api_name, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  ----------------------------------------------------------------
  Approval_Init(
      g_org_id,
      l_invoice_id,
      l_invoice_type,
      l_tolerance_id,
      l_service_tolerance_id,
      p_conc_flag,
      l_set_of_books_id,
      l_recalc_pay_schedule_flag,
      l_sys_xrate_gain_ccid,
      l_sys_xrate_loss_ccid,
      l_base_currency_code,
      l_inv_enc_type_id,
      l_purch_enc_type_id,
      l_gl_date_from_receipt,
      l_receipt_acc_days,
      l_system_user,
      l_user_id,
      l_goods_ship_amt_tolerance,
      l_goods_rate_amt_tolerance,
      l_goods_total_amt_tolerance,
      l_services_ship_amt_tolerance,
      l_services_rate_amt_tolerance,
      l_services_total_amt_tolerance,
      l_price_tol,
      l_qty_tol,
      l_qty_rec_tol,
      l_amt_tol,
      l_amt_rec_tol,
      l_max_qty_ord_tol,
      l_max_qty_rec_tol,
      l_max_amt_ord_tol,
      l_max_amt_rec_tol,
      l_invoice_line_count,   --Bug 6684139
      l_curr_calling_sequence);

  ----------------------------------------------------------------
  l_debug_info := 'Initialize Invoice Holds Array';
  --  Print_Debug(l_api_name, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  ----------------------------------------------------------------
  Initialize_Invoice_Holds(
                p_invoice_id       => p_invoice_id,
                p_calling_sequence => l_curr_calling_sequence);


  IF (p_calling_mode = 'PAYMENT REQUEST') OR
     (p_calling_mode = 'CANCEL' and l_invoice_type_pr = 'PAYMENT REQUEST') THEN
     l_cur_count := Approve_Pay_Request_Cur%ROWCOUNT;
  ELSE
     l_cur_count := Approve_Invoice_Cur%ROWCOUNT;
  END IF;

  IF (l_cur_count <> 0 ) THEN

    l_any_records_flag := 'Y';

    -----------------------------------------------------------------------
    l_debug_info := 'Check run option, to determine whether ok to approve';
    --  Print_Debug(l_api_name, l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -----------------------------------------------------------------------

    IF Inv_Needs_Approving(
	            p_invoice_id,
	            p_run_option,
	            l_curr_calling_sequence) THEN

      l_matched := Get_Inv_Matched_Status(
	                     l_invoice_id,
	                     l_curr_calling_sequence);

      IF (p_calling_mode = 'APPROVE'
	  and nvl(p_conc_flag,'N') <> 'Y'
          and l_invoice_line_count >0 ) THEN   --Bug 6684139

         ----------------------------------------------------------------
         l_debug_info := 'Calculate Tax on the Invoice';
         --  Print_Debug(l_api_name, l_debug_info);
         IF g_debug_mode = 'Y' THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
         END IF;
         ----------------------------------------------------------------
         l_success := ap_etax_pkg.calling_etax(
                           p_invoice_id		=> l_invoice_id,
                           p_calling_mode 	=> 'CALCULATE',
                           p_all_error_messages	=> 'N',
                           p_error_code		=> l_error_code,
                           p_calling_sequence	=> l_curr_calling_sequence);

         IF (NOT l_success) THEN
             RAISE Tax_Exception;
         END IF;
      END IF;

      ----------------------------------------------------------------
      l_debug_info := 'Fetch Invoice Lines';
      --  Print_Debug(l_api_name, l_debug_info);
      IF g_debug_mode = 'Y' THEN
         AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      ----------------------------------------------------------------
      OPEN  Invoice_Line_Cur(p_invoice_id);
      FETCH Invoice_Line_Cur
      BULK  COLLECT INTO t_inv_lines_table;
      CLOSE Invoice_Line_Cur;

      IF nvl(p_conc_flag, 'N') <> 'Y' THEN

         l_invoice_rec.invoice_id 		:= l_invoice_id;
         l_invoice_rec.invoice_date 		:= l_invoice_date;
         l_invoice_rec.invoice_currency_code 	:= l_invoice_currency_code;
         l_invoice_rec.exchange_rate 	   	:= l_exchange_rate;
         l_invoice_rec.exchange_rate_type	:= l_exchange_rate_type;
         l_invoice_rec.exchange_date 		:= l_exchange_date;
         l_invoice_rec.vendor_id		:= l_vendor_id;
         l_invoice_rec.org_id			:= l_org_id;

        ----------------------------------------------------------------
        l_debug_info := 'Generate Distributions. Variance Checks';
        --  Print_Debug(l_api_name, l_debug_info);
        IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ----------------------------------------------------------------

	--bugfix:6684139/6699825
	IF (l_invoice_line_count > 0) THEN
            AP_APPROVAL_PKG.Generate_Distributions
                                (p_invoice_rec        => l_invoice_rec,
				 p_base_currency_code => l_base_currency_code,
                                 p_inv_batch_id       => p_invoice_batch_id, /*Bug#7036685 : Passed p_invoice_batch_id to
				                                               p_inv_batch_id parameter instead of NULL*/
                                 p_run_option         => NULL,
                                 p_calling_sequence   => l_curr_calling_sequence,
                                 x_error_code         => l_error_code,
				 p_calling_mode       => p_calling_mode);   /*bug6833543 added p_calling_mode*/
        END IF;

        IF (p_calling_mode = 'APPROVE' and l_invoice_line_count >0 ) THEN   --Bug 6684139

            ----------------------------------------------------------------
  	    l_debug_info := 'Generate Tax Distributions';
            --  Print_Debug(l_api_name, l_debug_info);
            IF g_debug_mode = 'Y' THEN
               AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;
       	    ----------------------------------------------------------------
	    l_success := ap_etax_pkg.calling_etax(
	                           p_invoice_id		=> p_invoice_id,
	                           p_calling_mode	=> 'DISTRIBUTE',
	                           p_all_error_messages => 'N',
	                           p_error_code 	=>  l_error_code,
	                           p_calling_sequence 	=> l_curr_calling_sequence);

            IF (NOT l_success) THEN
                Raise Tax_Exception;
            END IF;
        END IF;
-- Bug 8346277 start
	l_manual_awt_exist:=0;
         SELECT COUNT(*)
           INTO l_manual_awt_exist
           FROM ap_invoice_lines_all ail
          WHERE ail.invoice_id            = l_invoice_rec.invoice_id
            AND ail.line_type_lookup_code = 'AWT'
            AND ail.line_source           = 'MANUAL LINE ENTRY';

	     IF (l_manual_awt_exist > 0) THEN
            AP_APPROVAL_PKG.Generate_Manual_Awt_Dist
                            (p_invoice_rec        => l_invoice_rec,
                             p_base_currency_code => l_base_currency_code,
                             p_inv_batch_id       => p_invoice_batch_id,
                             p_run_option         => NULL,
                             p_calling_sequence   => l_curr_calling_sequence,
                             x_error_code         => l_error_code,
			  p_calling_mode       => p_calling_mode);
         END IF;
-- Bug 8346277 end
      END IF; /* nvl(p_conc_flag, 'N')... */

      IF (nvl(t_inv_lines_table.count,0) <> 0 ) THEN

  -- Perf 6759699
  -- if p_run_option is not new then we can call this function
  -- for a invoice id
       IF (nvl(p_run_option,'Yes') <> 'New') THEN
          Update_Inv_Dists_To_Selected(     l_invoice_id,
                                            null ,
                                            p_run_option,
                                            l_curr_calling_sequence);
        ELSE
             FOR i IN NVL(t_inv_lines_table.first,0)..NVL(t_inv_lines_table.last,0)
          LOOP
              ----------------------------------------------------------------
              l_debug_info := 'Update Invoice Distributions to SELECTED';
              --  Print_Debug(l_api_name, l_debug_info);
              IF g_debug_mode = 'Y' THEN
                 AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
              END IF;

              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
              END IF;
              ----------------------------------------------------------------
              -- Update distributions to SELECTED as new inclusive/exclusive
              -- tax distributions could have been created.

              Update_Inv_Dists_To_Selected(
                                    l_invoice_id,
                                    t_inv_lines_table(i).line_number,
                                    p_run_option,
                                    l_curr_calling_sequence);
          END LOOP;      --bug6661773
       END IF; --p_run_option

              ----------------------------------------------------------------
  	      l_debug_info := 'Check Distribution Variance';
              --  Print_Debug(l_api_name, l_debug_info);
              IF g_debug_mode = 'Y' THEN
                 AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
              END IF;

              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
              END IF;
       	      ----------------------------------------------------------------

              Check_Dist_Variance(
	            l_invoice_id,
	            null,          --bug6661773
	            l_system_user,
	            l_holds,
	            l_hold_count,
	            l_release_count,
	            l_distribution_variance_exist,
	            l_curr_calling_sequence);
          --END LOOP;
      END IF;

   ----------------------------------------------------------------
   l_debug_info := 'Create payment schedule for invoice request';
   --  Print_Debug(l_api_name, l_debug_info);
   IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;
   ----------------------------------------------------------------
   createPaymentSchedules(l_invoice_id, l_curr_calling_sequence);


   FOR i IN nvl(t_inv_lines_table.first,0)..nvl(t_inv_lines_table.last,0) LOOP

      IF (t_inv_lines_table.exists(i)) THEN

        IF (l_base_currency_code <> l_invoice_currency_code) AND
           (t_inv_lines_table(i).match_type <> 'ADJUSTMENT_CORRECTION') AND
           (p_calling_mode <> 'CANCEL') THEN -- Bug 9178329.

           ----------------------------------------------------------------
           l_debug_info := 'Distributions: Calculate Base Amount and Round';
           --  Print_Debug(l_api_name, l_debug_info);
	   IF g_debug_mode = 'Y' THEN
              AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
           END IF;

           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
           END IF;
           ----------------------------------------------------------------

           IF ( l_line_variance_hold_exist = TRUE  OR
                l_distribution_variance_exist = TRUE ) THEN
             l_need_to_round_flag := 'N';
           END IF;

           IF (t_inv_lines_table(i).line_type_lookup_code <> 'TAX') THEN -- bug 9582952
              Dist_Base_Amount_Calculation(
	              p_invoice_id            => l_invoice_id,
	              p_invoice_line_number   => t_inv_lines_table(i).line_number,
	              p_invoice_currency_code => l_invoice_currency_code,
	              p_base_currency_code    => l_base_currency_code,
	              p_invoice_exchange_rate => l_exchange_rate,
	              p_need_to_round_flag    => l_need_to_round_flag,
	              p_calling_sequence      => l_curr_calling_sequence );
           END IF ;

        END IF;

	DECLARE
	   l_awt_success   Varchar2(1000);
	BEGIN
           ----------------------------------------------------------------
           l_debug_info := 'Call Extended Withholding Routine';
           --  Print_Debug(l_api_name, l_debug_info);
	   IF g_debug_mode = 'Y' THEN
	     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
	   END IF;

	   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	   END IF;
           ----------------------------------------------------------------
	   Ap_Extended_Withholding_Pkg.Ap_Ext_Withholding_Default
		                    (p_invoice_id 	=> p_invoice_id,
		                     p_inv_line_num 	=> t_inv_lines_table(i).line_number,
				     p_inv_dist_id  	=> NULL,
		                     p_calling_module 	=> l_curr_calling_sequence,
				     p_parent_dist_id 	=> NULL,
		                     p_awt_success 	=> l_awt_success);

	   IF (l_awt_success <> 'SUCCESS') THEN
	       RAISE Global_Exception;
	   END IF;
	END;

      END IF; /* t_inv_lines_table.exists ...*/
   END LOOP;

   t_inv_lines_table.DELETE;

   -- Bug 6648094
   -- Adjust distribution base amount if dist variance does not exist.
   -- Needed only for foreign currency invoices which have an exchange
   -- rate and the distribution base amts do not add up to invoice
   -- base amt.
   ---------------------------------------------------------------
   l_debug_info := 'Adjust Dists Base Amount for foreign currency rounding';
   --  Print_Debug(l_api_name, l_debug_info);
   IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;
   ---------------------------------------------------------------

   IF ( l_line_variance_hold_exist = FALSE AND
        l_distribution_variance_exist = FALSE ) THEN

      IF (l_base_currency_code <> l_invoice_currency_code) THEN

        SELECT SUM(amount)
        INTO   l_dist_total
        FROM   ap_invoice_distributions
        WHERE  invoice_id = l_invoice_id
        AND    (  (line_type_lookup_code NOT IN ('PREPAY','AWT') AND
                   prepay_tax_parent_id IS NULL)                 OR
                  (line_type_lookup_code = 'PREPAY'              AND
                   nvl(invoice_includes_prepay_flag,'N') = 'Y')  OR
                  (line_type_lookup_code IN ('REC_TAX', 'NONREC_TAX',
                                             'TERV','TIPV','TRV') AND
                   nvl(invoice_includes_prepay_flag,'N') = 'Y'   AND
                   prepay_tax_parent_id IS NOT NULL)
                );
        ---------------------------------------------------------------
        l_debug_info := 'Sum of Distributions Amounts: '|| l_dist_total;
        -- Print_Debug(l_api_name, l_debug_info);
	IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ---------------------------------------------------------------

        SELECT invoice_amount, base_amount
        INTO   l_inv_amount  , l_inv_base_amount
        FROM   ap_invoices
        WHERE  invoice_id = l_invoice_id;

        ---------------------------------------------------------------
        l_debug_info := 'Invoice amount: '|| l_inv_amount ||
                        ' Invoice base amount: '||l_inv_base_amount;
        --  Print_Debug(l_api_name, l_debug_info);
	IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ---------------------------------------------------------------

        SELECT COUNT('X')
        INTO   l_item_count
        FROM   ap_invoice_distributions
        WHERE  invoice_id = l_invoice_id AND
               line_type_lookup_code = 'ITEM';

        IF (l_dist_total = l_inv_amount) THEN

           SELECT SUM(base_amount)
           INTO   l_base_dist_total
           FROM   ap_invoice_distributions
           WHERE  invoice_id = l_invoice_id
           AND    (
                  (line_type_lookup_code NOT IN ('PREPAY','AWT') AND
                   prepay_tax_parent_id IS NULL)                     OR
                  (line_type_lookup_code = 'PREPAY' AND
                   nvl(invoice_includes_prepay_flag,'N') = 'Y')      OR
                  (line_type_lookup_code IN ('REC_TAX', 'NONREC_TAX',
                                             'TERV','TIPV','TRV') AND
                   nvl(invoice_includes_prepay_flag,'N') = 'Y'   AND
                   prepay_tax_parent_id IS NOT NULL)
                  );
           ---------------------------------------------------------------
           l_debug_info := 'Sum of Distributions Base Amounts: '||
                           l_base_dist_total;
           --  Print_Debug(l_api_name, l_debug_info);
	   IF g_debug_mode = 'Y' THEN
              AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
           END IF;

           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
           END IF;
           ---------------------------------------------------------------

           IF (l_inv_base_amount <> l_base_dist_total) THEN

           ---------------------------------------------------------------
           l_debug_info := 'Adjust for rounding';
           ---------------------------------------------------------------
           IF (l_item_count > 0) THEN
              --Update ITEM Dists
              UPDATE ap_invoice_distributions
              SET    base_amount = base_amount - (l_base_dist_total - l_inv_base_amount)
              WHERE  invoice_id = l_invoice_id
              AND    invoice_distribution_id = (
                           SELECT MAX(AID1.invoice_distribution_id)
                           FROM ap_invoice_distributions AID1
                           WHERE AID1.invoice_id = l_invoice_id
                           AND   AID1.line_type_lookup_code = 'ITEM'
                          /* Bug 3784909. Folowing two lines Added */
                           AND NVL(AID1.reversal_flag, 'N') <> 'Y'
                           AND NVL(AID1.posted_flag, 'N') = 'N'
                           AND ABS(AID1.amount) = (
                                 SELECT MAX(ABS(AID2.amount))
                                 FROM ap_invoice_distributions AID2
                                 WHERE AID2.invoice_id = l_invoice_id
                                 AND AID2.line_type_lookup_code = 'ITEM'
                                 -- Bug 3784909. Folowing two lines Added
                                 AND NVL(AID2.reversal_flag, 'N') <> 'Y'
                                 AND NVL(AID2.posted_flag, 'N') = 'N'));
           ELSE
              -- Update FREIGHT or MISC Dists
              UPDATE ap_invoice_distributions
              SET    base_amount = base_amount - (l_base_dist_total - l_inv_base_amount)
              WHERE  invoice_id = l_invoice_id
              AND    invoice_distribution_id = (
                           SELECT MAX(AID3.invoice_distribution_id)
                           FROM   ap_invoice_distributions AID3
                           WHERE  AID3.invoice_id = l_invoice_id
                           AND    AID3.line_type_lookup_code
                                  IN ('FREIGHT','MISCELLANEOUS')
                           AND
                           /* Bug 3784909. Folowing two lines Added */
                                  NVL(AID3.reversal_flag, 'N') = 'N'
                           AND    NVL(AID3.posted_flag, 'N') = 'N'
                           AND   ABS(AID3.amount) = (
                                 SELECT MAX(ABS(AID4.amount))
                                 FROM ap_invoice_distributions AID4
                                 WHERE AID4.invoice_id = l_invoice_id
                                 AND   AID4.line_type_lookup_code
                                       IN('FREIGHT','MISCELLANEOUS')
                                 --Bug 3784909. Folowing two lines Added
                                 AND NVL(AID4.reversal_flag, 'N') <> 'Y'
                                 AND NVL(AID4.posted_flag, 'N') = 'N'));
           END IF;  --IF (l_item_count > 0)

                l_row_count := SQL%ROWCOUNT;
                 IF (l_row_count > 0) THEN
                    ---------------------------------------------------------
                    l_debug_info := l_row_count||' rows updated.';
                    --  Print_Debug(l_api_name, l_debug_info);
		    IF g_debug_mode = 'Y' THEN
                       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
                    END IF;

                    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                    END IF;
                    ---------------------------------------------------------
                 ELSE
                    ---------------------------------------------------------
                    l_debug_info := 'No rows Updated';
                    --  Print_Debug(l_api_name, l_debug_info);
		    IF g_debug_mode = 'Y' THEN
                       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
                    END IF;

                    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                    END IF;
                    ---------------------------------------------------------
                 END IF;
           END IF; -- IF (l_dist_total = l_inv_amount)
        END IF; -- IF (l_dist_total = l_inv_amount)
      END IF; -- If inv currency <> base currency
   END IF; -- If l_distribution_variance_exist = TRUE
   -- Bug 6648094 Ends

   ----------------------------------------------------------------
   l_debug_info := 'Update Total Distribution Amount';
   --  Print_Debug(l_api_name, l_debug_info);
   IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;
   ----------------------------------------------------------------
   Update_Total_Dist_Amount(l_invoice_id,
                            l_curr_calling_sequence);

   --Bug9436217
   /*
   SELECT invoice_type_lookup_code
     INTO l_invoice_type_lookup_code
     FROM ap_invoices_all
    WHERE invoice_id = l_invoice_id;
   */
  l_invoice_type_lookup_code := l_invoice_type;
   --Bug9436217

    --Introduced retainage flag check for bug#9356460
   IF ((l_exclude_tax_from_discount = 'Y' OR l_exclude_freight_from_disc = 'Y' OR l_net_of_retainage_flag <> 'Y')
        OR (l_invoice_type_lookup_code IN ('PO PRICE ADJUST','ADJUSTMENT'))) THEN

         ----------------------------------------------------------------
         l_debug_info := 'Exclude Tax/Freight: Recalculate Payment Schedules';
         --  Print_Debug(l_api_name, l_debug_info);
	 IF g_debug_mode = 'Y' THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
         END IF;
         ----------------------------------------------------------------
         Exclude_Tax_Freight_From_Disc(
				l_invoice_id,
				l_exclude_tax_from_discount,
				l_exclude_freight_from_disc,
				l_net_of_retainage_flag, --9356460
				l_invoice_type_lookup_code,
				l_curr_calling_sequence);

          IF (l_invoice_type in ('PO PRICE ADJUST','ADJUSTMENT')) THEN
              ----------------------------------------------------------------
              l_debug_info := 'Retropricing: Check Line Variance';
              --  Print_Debug(l_api_name, l_debug_info);
	      IF g_debug_mode = 'Y' THEN
                 AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
              END IF;

              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
              END IF;
              ----------------------------------------------------------------
              Check_Line_Variance(
		          l_invoice_id,
		          l_system_user,
		          l_holds,
		          l_hold_count,
		          l_release_count,
		          l_line_variance_hold_exist,
		          l_curr_calling_sequence,
			  l_base_currency_code);   --bug 7271262
          END IF;
   END IF;

   ----------------------------------------------------------------
   l_debug_info := 'Execute General Checks';
   --  Print_Debug(l_api_name, l_debug_info);
   IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;
   ----------------------------------------------------------------
   Execute_General_Checks(
          l_invoice_id,
          l_set_of_books_id,
          l_base_currency_code,
          l_invoice_amount,
          l_invoice_base_amount,
          l_invoice_currency_code,
          l_invoice_amount_limit,
          l_hold_future_payments_flag,
          l_system_user,
          l_holds,
          l_hold_count,
          l_release_count,
          l_curr_calling_sequence);

   IF (l_matched) THEN

       ----------------------------------------------------------------
       l_debug_info := 'Execute Quantity Variance Check';
       --  Print_Debug(l_api_name, l_debug_info);
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;
       ----------------------------------------------------------------
       IF l_invoice_type_lookup_code <> 'PO PRICE ADJUST' THEN
          AP_APPROVAL_MATCHED_PKG.Exec_Qty_Variance_Check(
	            p_invoice_id         => l_invoice_id,
	            p_base_currency_code => l_base_currency_code,
	            p_inv_currency_code  => l_invoice_currency_code,
	            p_system_user        => l_system_user,
	            p_calling_sequence   => l_curr_calling_sequence);
       END IF;

       ----------------------------------------------------------------
       l_debug_info := 'Execute Amount Variance Check';
       --  Print_Debug(l_api_name, l_debug_info);
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;
       ----------------------------------------------------------------
       AP_APPROVAL_MATCHED_PKG.Exec_Amt_Variance_Check(
	            p_invoice_id         => l_invoice_id,
	            p_base_currency_code => l_base_currency_code,
	            p_inv_currency_code  => l_invoice_currency_code,
	            p_system_user        => l_system_user,
	            p_calling_sequence   => l_curr_calling_sequence );

       --for CLM project - bug 9494400
       ----------------------------------------------------------------
       l_debug_info := 'Execute CLM Partial Funds Check';
       --  Print_Debug(l_api_name, l_debug_info);
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;
       ----------------------------------------------------------------
       AP_APPROVAL_MATCHED_PKG.exec_partial_funds_check(
                    p_invoice_id       => l_invoice_id,
                    p_system_user      => l_system_user,
                    p_holds            => l_holds,
                    p_holds_count      => l_hold_count,
                    p_release_count    => l_release_count,
                    p_calling_sequence => l_curr_calling_sequence);

       -- end for CLM project - bug 9494400

       -- 7299826 EnC project
       ----------------------------------------------------------------
       l_debug_info := 'Execute Pay when paid Check';
       --  Print_Debug(l_api_name, l_debug_info);
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;
       ----------------------------------------------------------------
       AP_APPROVAL_MATCHED_PKG.exec_pay_when_paid_check(
                                 p_invoice_id       => l_invoice_id,
                                 p_system_user      => l_system_user,
                                 p_holds            => l_holds,
                                 p_holds_count      => l_hold_count,
                                 p_release_count    => l_release_count,
                                 p_calling_sequence => l_curr_calling_sequence);

       -- 7299826 EnC project
       ----------------------------------------------------------------
       l_debug_info := 'Execute PO Deliverable Check';
       --  Print_Debug(l_api_name, l_debug_info);
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;
       ----------------------------------------------------------------
       AP_APPROVAL_MATCHED_PKG.exec_po_deliverable_check(
                                 p_invoice_id       => l_invoice_id,
                                 p_system_user      => l_system_user,
                                 p_holds            => l_holds,
                                 p_holds_count      => l_hold_count,
                                 p_release_count    => l_release_count,
                                 p_calling_sequence => l_curr_calling_sequence);

       ----------------------------------------------------------------
       l_debug_info := 'Execute Matched Checks';
       --  Print_Debug(l_api_name, l_debug_info);
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;
       ----------------------------------------------------------------
       AP_APPROVAL_MATCHED_PKG.Execute_Matched_Checks(
	            p_invoice_id          		=> l_invoice_id,
	            p_base_currency_code  		=> l_base_currency_code,
	            p_price_tol           		=> l_price_tol,
	            p_qty_tol             		=> l_qty_tol,
	            p_qty_rec_tol         		=> l_qty_rec_tol,
	            p_amt_tol		  		=> l_amt_tol,
		    p_amt_rec_tol	  		=> l_amt_rec_tol,
	            p_max_qty_ord_tol     		=> l_max_qty_ord_tol,
	            p_max_qty_rec_tol     		=> l_max_qty_rec_tol,
		    p_max_amt_ord_tol     		=> l_max_amt_ord_tol,
		    p_max_amt_rec_tol     		=> l_max_amt_rec_tol,
	            p_goods_ship_amt_tolerance  	=> l_goods_ship_amt_tolerance,
	            p_goods_rate_amt_tolerance  	=> l_goods_rate_amt_tolerance,
	            p_goods_total_amt_tolerance 	=> l_goods_total_amt_tolerance,
	            p_services_ship_amt_tolerance  	=> l_services_ship_amt_tolerance,
	            p_services_rate_amt_tolerance  	=> l_services_rate_amt_tolerance,
	            p_services_total_amt_tolerance 	=> l_services_total_amt_tolerance,
	            p_system_user         		=> l_system_user,
	            p_conc_flag           		=> p_conc_flag,
	            p_holds               		=> l_holds,
	            p_holds_count         		=> l_hold_count,
	            p_release_count       		=> l_release_count,
	            p_calling_sequence    		=> l_curr_calling_sequence);

       ----------------------------------------------------------------
       l_debug_info := 'Execute PO Final Close';
       --  Print_Debug(l_api_name, l_debug_info);
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;
       ----------------------------------------------------------------
       AP_APPROVAL_MATCHED_PKG.Exec_PO_Final_Close(
	                l_invoice_id,
	                l_system_user,
	                p_conc_flag,
	                l_holds,
	                l_hold_count,
	                l_release_count,
	                l_curr_calling_sequence);

   END IF;  -- end of matched check

   IF (p_calling_mode = 'APPROVE' and l_invoice_line_count >0 ) THEN --bug 6684139
       ----------------------------------------------------------------
       l_debug_info := 'Validate Invoice for Tax';
       --  Print_Debug(l_api_name, l_debug_info);
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;
       ----------------------------------------------------------------
       l_success := ap_etax_pkg.calling_etax(
	                       p_invoice_id 		=> p_invoice_id,
			       p_calling_mode		=> 'VALIDATE',
			       p_all_error_messages	=> 'N',
			       p_error_code		=>  l_error_code,
			       p_calling_sequence	=> l_curr_calling_sequence);

         IF (NOT l_success) THEN
            IF (nvl(p_conc_flag,'N') = 'N') THEN
                Raise Tax_Exception;
            ELSE
	        NULL;
            END IF;
         END IF;
   END IF;

   ----------------------------------------------------------------
   l_debug_info := 'Call GMS API to ensure missing ADLs are generated';
   --  Print_Debug(l_api_name, l_debug_info);
   IF g_debug_mode = 'Y' THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;
   ----------------------------------------------------------------
   GMS_AP_API2.verify_create_adls
			(l_invoice_id,
			 l_curr_calling_sequence);

   ----------------------------------------------------------------
   l_debug_info := 'Execute Withholding';
   --  Print_Debug(l_api_name, l_debug_info);
   IF g_debug_mode = 'Y' THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;
   ----------------------------------------------------------------
   Withhold_Tax_On(
          l_invoice_id,
          l_gl_date_from_receipt,
          l_system_user,
          l_system_user,
          -1,
          -1,
          -1,
          l_system_user,
          l_holds,
          l_hold_count,
          l_release_count,
          l_curr_calling_sequence);

   ------------------------------------------------------------------
    l_debug_info := 'Calling Custom Validation Hook';
   ------------------------------------------------------------------
      AP_CUSTOM_INV_VALIDATION_PKG.AP_Custom_Validation_Hook
                     (p_invoice_id,
                      l_curr_calling_sequence);

   ----------------------------------------------------------------
   l_debug_info := 'Create Prepayment Application Distributions';
   --  Print_Debug(l_api_name, l_debug_info);
   IF g_debug_mode = 'Y' THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;
   ----------------------------------------------------------------

   -- bug9038462, changing the criteria for the regeneration of
   -- the Prepayment Application Distributions (APAD)
   --
   SELECT count(*)
     INTO l_prepay_dist_count
     FROM ap_invoice_distributions_all
    WHERE Invoice_ID 		= l_invoice_id
      AND Line_Type_Lookup_Code = 'PREPAY'
      --AND Accounting_Event_ID   IS NULL;
      AND NVL(Posted_Flag, 'N') <> 'Y'
      AND NVL(Encumbered_Flag, 'N') <> 'Y';

   IF l_prepay_dist_count > 0 THEN
      ap_acctg_prepay_dist_pkg.prepay_dist_appl(
	             l_invoice_id,
	             l_curr_calling_sequence);
   END IF;

   ----------------------------------------------------------------
   l_debug_info := 'Execute Budgetary Control';
   --  Print_Debug(l_api_name, l_debug_info);
   IF g_debug_mode = 'Y' THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;
   ----------------------------------------------------------------
--Bug 8260168 Start
   ----------------------------------------------------------------
   l_debug_info := 'Check Prepaid Amount Exceeds Invoice Amount';
   --  Print_Debug(l_api_name, l_debug_info);
   IF g_debug_mode = 'Y' THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;
   ----------------------------------------------------------------
    Check_Prepaid_Amount(
	      l_invoice_id,
	      l_system_user,
	      l_holds,
	      l_hold_count,
	      l_release_count,
	      l_curr_calling_sequence);

--Bug 8260168 End

   IF p_budget_control = 'Y' THEN

      l_debug_info := 'p_budget_control is Y';
      --  Print_Debug(l_api_name, l_debug_info);
      IF g_debug_mode = 'Y' THEN
         AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      -- Bug 6681580
      select count(*)
      INTO   l_encumbrance_exists
      FROM   ap_invoice_distributions aid
      WHERE  nvl(aid.encumbered_flag,'N') not in ('N','R')        ----added check for 'R' due to bug 7264524
      AND    aid.invoice_id = l_invoice_id;

      -- Bug 6681580
      IF p_calling_mode =  'CANCEL' AND l_encumbrance_exists = 0 THEN
         l_debug_info := 'Calling Mode is CANCEL and No Prior Encumb';
         --  Print_Debug(l_api_name, l_debug_info);
         IF g_debug_mode = 'Y' THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
         END IF;
      ELSE
         l_debug_info := 'Calling AP_FUNDS_CONTROL_PKG.Funds_Reserve';
         --  Print_Debug(l_api_name, l_debug_info);
         IF g_debug_mode = 'Y' THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
         END IF;

         AP_FUNDS_CONTROL_PKG.Funds_Reserve(
	            p_calling_mode,
	            l_invoice_id,
	            l_set_of_books_id,
	            l_base_currency_code,
	            p_conc_flag,
	            l_system_user,
	            l_holds,
	            l_hold_count,
	            l_release_count,
	            p_funds_return_code,
	            l_curr_calling_sequence);
      END IF; -- Bug 6681580
   END IF;


   -- Project LCM 7588322
   /*Check whether this invoice is matched to any LCM enabled receipt*/
   BEGIN
	   SELECT 'Y'
	   INTO l_lcm_used
	   FROM DUAL
	   WHERE EXISTS
	       (SELECT 1 FROM AP_INVOICE_DISTRIBUTIONS aid, RCV_TRANSACTIONS rt
				  WHERE aid.invoice_id         = l_invoice_id
					AND   aid.rcv_transaction_id = rt.transaction_id
					AND   rt.lcm_shipment_line_id IS NOT NULL
					AND   aid.match_status_flag = 'S');
   EXCEPTION
       WHEN NO_DATA_FOUND THEN NULL;
   END;

   /*Check if there are unpostable holds put on this invoice by now.
     If any such holds are there, we should not be calling LCM to
     pick this invoice to LCM.*/
   -- Added by 7641045, modified by 7678786, modification reverted by 7830298
   BEGIN
             SELECT 'Y'
             INTO l_unpostable_holds_exist
             FROM dual
             WHERE EXISTS (SELECT 1
                            FROM    ap_holds H, ap_hold_codes C
                            WHERE   H.invoice_id = l_invoice_id
                            AND     H.hold_lookup_code = C.hold_lookup_code
                            AND     ((H.release_lookup_code IS NULL)
                            AND     ((C.postable_flag = 'N') OR (C.postable_flag = 'X'))));
      /* The condition above is same as the one used in Update_Inv_Dists_To_Approved
      procedure. However, we removed encumbrance checks.*/

    EXCEPTION
       WHEN NO_DATA_FOUND THEN NULL;
    END;



    IF(l_lcm_used = 'Y') THEN
     IF (l_unpostable_holds_exist <> 'Y') THEN -- Bug 7641045

	   ----------------------------------------------------------------
	   l_debug_info := 'Call LCM API';
	   --  Print_Debug(l_api_name, l_debug_info);
           IF g_debug_mode = 'Y' THEN
              AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
           END IF;

           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
           END IF;
	   ----------------------------------------------------------------

	   --EXECUTE IMMEDIATE
	   INL_MATCH_GRP.Create_MatchesFromAP
	   (p_api_version    => 1.0, -- API version
	    p_init_msg_list  => FND_API.G_TRUE, -- This is to initialize the message list whenever the API is called, not cumulating messages from one execution to other
	    p_commit         => FND_API.G_FALSE, -- This is to not issue any commit inside the API, since commit cycle is managed by the calling program
	    p_invoice_id     => l_invoice_id,
	    x_return_status  => l_lcm_return_status, -- Returns "S", "E" or "U", i.e. FND_API.G_RET_STS_SUCCESS , FND_API.G_RET_STS_ERROR or FND_API.G_RET_STS_UNEXP_ERROR.
	    x_msg_count      => l_lcm_msg_count, -- Number of messages in the list
	    x_msg_data       => l_lcm_msg_data); -- Messages stored in encoded format

	   IF(l_lcm_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       -- Bug 7718385
       RAISE LCM_Exception;
	   END IF;
    END IF; -- l_unpostable_holds_exist <> 'Y'
   END IF; -- l_lcm_used = 'Y'

   -- End Project LCM 7588322

   ----------------------------------------------------------------
   l_debug_info := 'Update Invoice Distributions to APPROVED';
   --  Print_Debug(l_api_name, l_debug_info);
   IF g_debug_mode = 'Y' THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;
   ----------------------------------------------------------------
   Update_Inv_Dists_To_Approved(
	          l_invoice_id,
	          l_user_id,
	          l_curr_calling_sequence);

   ----------------------------------------------------------------
   l_debug_info := 'Generate Accounting Events';
   --  Print_Debug(l_api_name, l_debug_info);
   IF g_debug_mode = 'Y' THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;
   ----------------------------------------------------------------
   Generate_Account_Event(
            l_invoice_id,
            l_curr_calling_sequence);


   END IF; -- end of Inv_Needs_Approving...

   ----------------------------------------------------------------
   l_debug_info := 'Execute Due Date Sweeper after validation';
   --  Print_Debug(l_api_name, l_debug_info);
   IF g_debug_mode = 'Y' THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;
   ----------------------------------------------------------------

   IF (l_recalc_pay_schedule_flag = 'Y') THEN

      SELECT DECODE(NVL((MAX(aps.last_update_date)- MIN(aps.creation_date)),0),
                     0,'N','Y')
        INTO l_diff_flag
        FROM ap_payment_schedules aps
       WHERE aps.invoice_id = l_invoice_id;

      IF (l_diff_flag = 'N') THEN
        AP_PPA_PKG.Due_Date_Sweeper(
                l_invoice_id,
                l_matched,
                l_system_user,
                l_receipt_acc_days,
                l_curr_calling_sequence);
      END IF;
   END IF;

   ----------------------------------------------------------------
   l_debug_info := 'Update force_revalidation_flag to No';
   --  Print_Debug(l_api_name, l_debug_info);
   IF g_debug_mode = 'Y' THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;
   ----------------------------------------------------------------

   UPDATE ap_invoices_all
      SET force_revalidation_flag = 'N'
    WHERE invoice_id = l_invoice_id;

  END IF; -- end of approve_invoice_cur cursor count check


  IF (p_calling_mode = 'PAYMENT REQUEST') OR
     (p_calling_mode = 'CANCEL' and l_invoice_type_pr = 'PAYMENT REQUEST')  THEN
     ----------------------------------------------------------------
     l_debug_info := 'Close approve_pay_request_cur';
     --  Print_Debug(l_api_name, l_debug_info);
     IF g_debug_mode = 'Y' THEN
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
     END IF;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;
     ----------------------------------------------------------------
     CLOSE approve_pay_request_cur;
  ELSE
     ----------------------------------------------------------------
     l_debug_info := 'Close approve_invoice_cursor';
     --  Print_Debug(l_api_name, l_debug_info);
     IF g_debug_mode = 'Y' THEN
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
     END IF;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;
     ----------------------------------------------------------------
     CLOSE approve_invoice_cur;
  END IF;

  ----------------------------------------------------------------
  l_debug_info := 'Retrieve total hold count and validation status';
  --  Print_Debug(l_api_name, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  ----------------------------------------------------------------
  Get_Invoice_Statuses(
	      l_invoice_id,
	      p_holds_count,
	      p_approval_status,
	      l_curr_calling_sequence);

  ----------------------------------------------------------------
  l_debug_info := 'Validation Status: '||p_approval_status;
  --  Print_Debug(l_api_name, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  ----------------------------------------------------------------

  IF  p_calling_mode = 'APPROVE' THEN

      IF l_invoice_line_count > 0 THEN

         BEGIN
          SELECT *
            INTO l_inv_header_rec
            FROM ap_invoices_all
           WHERE invoice_id = P_Invoice_Id;
         END;
	--BUG 6974733
      IF (l_inv_header_rec.invoice_type_lookup_code NOT IN ('AWT', 'INTEREST')) THEN
         -------------------------------------------------------------------
         l_debug_info := 'Get event class code';
         --  Print_Debug(l_api_name, l_debug_info);
         IF g_debug_mode = 'Y' THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
         END IF;
         -------------------------------------------------------------------
         IF NOT(AP_ETAX_UTILITY_PKG.Get_Event_Class_Code(
			P_Invoice_Type_Lookup_Code => l_inv_header_rec.invoice_type_lookup_code,
			P_Event_Class_Code         => l_event_class_code,
			P_error_code               => l_error_code,
			P_calling_sequence         => l_curr_calling_sequence)) THEN

            IF (nvl(p_conc_flag,'N') = 'N') THEN
                Raise Tax_Exception;
            ELSE
                NULL;
            END IF;
         END IF;

         -----------------------------------------------------------------
         l_debug_info := 'Call Freeze Distributions';
         --  Print_Debug(l_api_name, l_debug_info);
         IF g_debug_mode = 'Y' THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
         END IF;
         -----------------------------------------------------------------
         --Bug7592845
         IF NOT(AP_ETAX_SERVICES_PKG.Freeze_itm_Distributions(
                        P_Invoice_Header_Rec  => l_inv_header_rec,
                        P_Calling_Mode        => 'FREEZE DISTRIBUTIONS',
                        P_Event_Class_Code    => l_event_class_code,
                        P_All_Error_Messages  => 'N',
                        P_Error_Code          => l_error_code,
                        P_Calling_Sequence    => l_curr_calling_sequence)) THEN

            IF (nvl(p_conc_flag,'N') = 'N') THEN
                Raise Tax_Exception;
            ELSE
                NULL;
            END IF;
         END IF;
         --Bug9021265
         --Checking the Freeze Flag Y by defauly as per discussion
         --Himesh,Atul,Venkat,Kiran,Ranjith,Taniya
         SELECT COUNT(1)
           INTO l_unfreeze_count
           FROM zx_rec_nrec_dist
          WHERE application_id = 200
            AND entity_code    = 'AP_INVOICES'
            AND event_class_code IN ('STANDARD INVOICES', 'PREPAYMENT INVOICES', 'EXPENSE REPORTS')
            AND trx_id         = l_inv_header_rec.invoice_id
            AND freeze_flag = 'N';
        -----------------------------------------------------------------
        l_debug_info := 'UnFrozen Dists Count '||l_unfreeze_count;
        --  Print_Debug(l_api_name, l_debug_info);
        IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        -----------------------------------------------------------------
        IF l_unfreeze_count > 0 THEN
           RAISE TAX_UNFREEZE_EXCEPTION;
        END IF;
         --Bug9021265
    END IF;--BUG 6974733
         IF p_approval_status IN ('APPROVED','AVAILABLE','UNPAID','FULL') THEN

            ----------------------------------------------------------------
            l_debug_info := 'Call API to freeze invoice in tax schema';
            --  Print_Debug(l_api_name, l_debug_info);
            IF g_debug_mode = 'Y' THEN
               AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;
            ----------------------------------------------------------------
            l_success := ap_etax_pkg.calling_etax(
				p_invoice_id		=> p_invoice_id,
				p_calling_mode		=> 'FREEZE INVOICE',
				p_all_error_messages	=> 'N',
				p_error_code		=> l_error_code,
				p_calling_sequence	=> l_curr_calling_sequence);

            IF (NOT l_success) THEN
                IF (nvl(p_conc_flag,'N') = 'N') THEN
                    Raise Tax_Exception;
                ELSE
                    NULL;
                END IF;
            END IF;
          END IF;
      END IF;
  END IF;

  AP_INVOICE_DISTRIBUTIONS_PKG.Make_Distributions_Permanent
                 (P_Invoice_Id          => p_invoice_id,
                  P_Invoice_Line_Number => NULL,
                  P_Calling_Sequence    => 'Invoice Validation'); --Bug6653070

  --END IF;

  IF (l_any_records_flag = 'Y') THEN
      IF NVL(p_commit, 'Y') = 'Y' THEN
         ----------------------------------------------------------------
         l_debug_info := 'Commit Data';
         --  Print_Debug(l_api_name, l_debug_info);
         IF g_debug_mode = 'Y' THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
         END IF;
         ----------------------------------------------------------------
         COMMIT;
      END IF;
  END IF;

  --  Print_Debug (l_api_name, 'AP_APPROVAL_PKG.APPROVE.END');
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, 'AP_APPROVAL_PKG.APPROVE.END' );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'AP_APPROVAL_PKG.APPROVE.END');
  END IF;

EXCEPTION
  --Bug9021265
  WHEN TAX_UNFREEZE_EXCEPTION THEN
       fnd_message.set_name( 'SQLAP', 'AP_UNFRZN_TAX_DIST' ); -- Bug 9777752

       IF (approve_invoice_cur%ISOPEN) THEN
           CLOSE approve_invoice_cur;
       END IF;
       IF (approve_pay_request_cur%ISOPEN) THEN
           CLOSE approve_pay_request_cur;
       END IF;
       IF (invoice_line_cur%ISOPEN) THEN
           CLOSE invoice_line_cur;
       END IF;

       APP_EXCEPTION.RAISE_EXCEPTION;
  -- Bug 7718385
  WHEN LCM_EXCEPTION THEN

       -- Logging error messages
 	     FOR i in 1 ..l_lcm_msg_count
	     LOOP
	      l_lcm_msg_data := FND_MSG_PUB.get(i, FND_API.g_false);
	      l_debug_info :='l_msg_data ('||i||'): '||l_lcm_msg_data;
              --  Print_Debug(l_api_name, l_debug_info);
              IF g_debug_mode = 'Y' THEN
                 AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
              END IF;

              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
              END IF;
	     END LOOP;

       -- Throwing error messages to form to display
       FND_MESSAGE.SET_NAME('SQLAP','AP_LCM_EXCEPTION');
       /*  Error Text is
       --  An error occurred while interfacing the invoice to Landed Cost Management.
       --  Error: ERROR
       --
       */
       FND_MESSAGE.SET_TOKEN('ERROR', l_lcm_msg_data);
       APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN TAX_EXCEPTION THEN

       FND_MESSAGE.SET_NAME('SQLAP','AP_TAX_EXCEPTION');
       IF l_error_code IS NOT NULL THEN
          FND_MESSAGE.SET_TOKEN('ERROR', l_error_code);
       ELSE
          FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
       END IF;

       IF (approve_invoice_cur%ISOPEN) THEN
           CLOSE approve_invoice_cur;
       END IF;
       IF (approve_pay_request_cur%ISOPEN) THEN
           CLOSE approve_pay_request_cur;
       END IF;
       IF (invoice_line_cur%ISOPEN) THEN
           CLOSE invoice_line_cur;
       END IF;

       APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN OTHERS THEN
       IF (SQLCODE <> -20001) THEN
           FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS',
	                  'Run Option  = '|| p_run_option
	              ||', Batch Id = '|| to_char(p_invoice_batch_id)
	              ||', Begin Date = '|| to_char(p_begin_invoice_date)
	              ||', End Date = '|| to_char(p_end_invoice_date)
	              ||', Vendor Id = '|| to_char(p_vendor_id)
	              ||', Pay Group = '|| p_pay_group
	              ||', Invoice Id = '|| to_char(p_invoice_id)
	              ||', Entered By = '|| to_char(p_entered_by)
	              ||', Set of Books Id = '|| to_char(p_set_of_books_id));
	   FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
       END IF;

       IF (approve_invoice_cur%ISOPEN) THEN
           CLOSE approve_invoice_cur;
       END IF;
       IF (approve_pay_request_cur%ISOPEN) THEN
           CLOSE approve_pay_request_cur;
       END IF;
       IF (invoice_line_cur%ISOPEN) THEN
           CLOSE invoice_line_cur;
       END IF;

       APP_EXCEPTION.RAISE_EXCEPTION;

END Approve;

/*bug6858309 - modified the function to look for
ap_invoice_lines instead of ap_invoic_distributions
as dists are not created for freshly created
recurring invoice in R12*/
FUNCTION validate_period (p_invoice_id IN NUMBER)
RETURN BOOLEAN IS

   CURSOR get_gl_date IS
   SELECT distinct accounting_date acc_date
     FROM ap_invoice_lines_all
    WHERE invoice_id = p_invoice_id
          and NVL(generate_dists,'N') <> 'D';

   CURSOR get_inv_source IS
   SELECT upper(nvl(source, 'X')), org_id
     FROM ap_invoices_all
    WHERE invoice_id = p_invoice_id;

   l_source ap_invoices_all.source%TYPE;
   l_org_id ap_invoices_all.org_id%TYPE;

BEGIN
   OPEN get_inv_source;
   FETCH get_inv_source INTO l_source, l_org_id;
   CLOSE get_inv_source;

   IF l_source <> 'RECURRING INVOICE' THEN
      return true;
   END IF;

   FOR gl_date IN get_gl_date LOOP
          IF ap_utilities_pkg.period_status(gl_date.acc_date) ='N' then
             return false;
          END IF;
   END LOOP;
   return true;
END validate_period;


/*=============================================================================
 |  PROCEDURE  APPROVAL_INIT
 |
 |      Procedure called by APPROVAL to retrieve system variables to be used by
 |      the APPROVAL program
 |
 |  PROGRAM FLOW
 |      1. Retrieve system parameters
 |      2. Determine if accounting method is Cash Only
 |      3. Retrieve profile option user_id
 |      4. Set approval system user_id value
 |      5. Retrieve system tolerances
 *============================================================================*/

PROCEDURE Approval_Init(
	      p_org_id  		   IN            NUMBER,
	      p_invoice_id		   IN            NUMBER,
              p_invoice_type               IN            VARCHAR2 DEFAULT NULL,
              p_tolerance_id               IN            NUMBER,
              p_services_tolerance_id      IN            NUMBER,
	      p_conc_flag		   IN		 VARCHAR2,
              p_set_of_books_id            IN OUT NOCOPY NUMBER,
              p_recalc_pay_sched_flag      IN OUT NOCOPY VARCHAR2,
              p_sys_xrate_gain_ccid        IN OUT NOCOPY NUMBER,
              p_sys_xrate_loss_ccid        IN OUT NOCOPY NUMBER,
              p_base_currency_code         IN OUT NOCOPY VARCHAR2,
              p_inv_enc_type_id            IN OUT NOCOPY NUMBER,
              p_purch_enc_type_id          IN OUT NOCOPY NUMBER,
              p_gl_date_from_receipt_flag  IN OUT NOCOPY VARCHAR2,
              p_receipt_acc_days           IN OUT NOCOPY NUMBER,
              p_system_user                IN OUT NOCOPY NUMBER,
              p_user_id                    IN OUT NOCOPY NUMBER,
	      p_goods_ship_amt_tolerance     IN OUT NOCOPY NUMBER,
	      p_goods_rate_amt_tolerance     IN OUT NOCOPY NUMBER,
	      p_goods_total_amt_tolerance    IN OUT NOCOPY NUMBER,
	      p_services_ship_amt_tolerance  IN OUT NOCOPY NUMBER,
	      p_services_rate_amt_tolerance  IN OUT NOCOPY NUMBER,
	      p_services_total_amt_tolerance IN OUT NOCOPY NUMBER,
              p_price_tolerance            IN OUT NOCOPY NUMBER,
              p_qty_tolerance              IN OUT NOCOPY NUMBER,
              p_qty_rec_tolerance          IN OUT NOCOPY NUMBER,
	      p_amt_tolerance		   IN OUT NOCOPY NUMBER,
	      p_amt_rec_tolerance	   IN OUT NOCOPY NUMBER,
              p_max_qty_ord_tolerance      IN OUT NOCOPY NUMBER,
              p_max_qty_rec_tolerance      IN OUT NOCOPY NUMBER,
	      p_max_amt_ord_tolerance      IN OUT NOCOPY NUMBER,
	      p_max_amt_rec_tolerance      IN OUT NOCOPY NUMBER,
              p_invoice_line_count         OUT NOCOPY NUMBER,  --Bug 6684139
              p_calling_sequence           IN            VARCHAR2) IS

  l_debug_loc                 VARCHAR2(30)   := 'Approval_Init';
  l_curr_calling_sequence     VARCHAR2(2000);
  l_debug_info                VARCHAR2(1000);
BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

   -- Select stmt added for bug 6684139
   SELECT count(*)
    into p_invoice_line_count
    from ap_invoice_lines
    where invoice_id = p_invoice_id;

  IF nvl(p_conc_flag, 'N') <> 'Y' THEN

	 l_debug_info :=  'Retrieving system parameters for validation';
	 --  Print_Debug(l_debug_loc, l_debug_info);
         IF g_debug_mode = 'Y' THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
         END IF;

	 SELECT   nvl(sp.set_of_books_id, -1),
	          nvl(recalc_pay_schedule_flag, 'N'),
	          nvl(sp.rate_var_gain_ccid, -1),
	          nvl(sp.rate_var_loss_ccid, -1),
	          nvl(sp.base_currency_code, 'USD'),
        	  nvl(fp.inv_encumbrance_type_id, -1),
	          nvl(fp.purch_encumbrance_type_id, -1),
	          nvl(sp.receipt_acceptance_days, 0),
	          nvl(gl_date_from_receipt_flag, 'S')
	 INTO     p_set_of_books_id,
	          p_recalc_pay_sched_flag,
	          p_sys_xrate_gain_ccid,
	          p_sys_xrate_loss_ccid,
	          p_base_currency_code,
	          p_inv_enc_type_id,
	          p_purch_enc_type_id,
	          p_receipt_acc_days,
	          p_gl_date_from_receipt_flag
	  FROM    ap_system_parameters_all sp,
	          financials_system_params_all fp,
	          gl_sets_of_books gls
	  WHERE   sp.org_id = p_org_id
	  AND     fp.org_id = sp.org_id
	  AND     sp.set_of_books_id = gls.set_of_books_id;

  ELSE

	l_debug_info :=  'Set Options from Cache';
    	--  Print_Debug (l_debug_loc, l_debug_info);
        IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
        END IF;

	p_set_of_books_id		:= AP_APPROVAL_PKG.G_Options_Table(p_org_id).set_of_books_id;
	p_recalc_pay_sched_flag		:= AP_APPROVAL_PKG.G_Options_Table(p_org_id).recalc_pay_schedule_flag;
	p_sys_xrate_gain_ccid		:= AP_APPROVAL_PKG.G_Options_Table(p_org_id).rate_var_gain_ccid;
	p_sys_xrate_loss_ccid		:= AP_APPROVAL_PKG.G_Options_Table(p_org_id).rate_var_loss_ccid;
	p_base_currency_code		:= AP_APPROVAL_PKG.G_Options_Table(p_org_id).base_currency_code;
	p_inv_enc_type_id		:= AP_APPROVAL_PKG.G_Options_Table(p_org_id).inv_encumbrance_type_id;
	p_purch_enc_type_id		:= AP_APPROVAL_PKG.G_Options_Table(p_org_id).purch_encumbrance_type_id;
	p_receipt_acc_days		:= AP_APPROVAL_PKG.G_Options_Table(p_org_id).receipt_acceptance_days;
	p_gl_date_from_receipt_flag	:= AP_APPROVAL_PKG.G_Options_Table(p_org_id).gl_date_from_receipt_flag;

  END IF;

  p_system_user := 5;
  p_user_id	:= FND_GLOBAL.user_id;

  l_debug_info :=  'Retrieving tolerances for validation';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;

  IF p_invoice_type <> 'PAYMENT REQUEST' THEN

     IF p_tolerance_id IS NOT NULL THEN
	    p_price_tolerance		:= AP_APPROVAL_PKG.G_GOODS_TOLERANCES(p_tolerance_id).price_tolerance;
            p_qty_tolerance		:= AP_APPROVAL_PKG.G_GOODS_TOLERANCES(p_tolerance_id).quantity_tolerance;
            p_qty_rec_tolerance		:= AP_APPROVAL_PKG.G_GOODS_TOLERANCES(p_tolerance_id).qty_received_tolerance;
            p_max_qty_ord_tolerance	:= AP_APPROVAL_PKG.G_GOODS_TOLERANCES(p_tolerance_id).max_qty_ord_tolerance;
            p_max_qty_rec_tolerance	:= AP_APPROVAL_PKG.G_GOODS_TOLERANCES(p_tolerance_id).max_qty_rec_tolerance;
            p_goods_ship_amt_tolerance	:= AP_APPROVAL_PKG.G_GOODS_TOLERANCES(p_tolerance_id).ship_amt_tolerance;
            p_goods_rate_amt_tolerance	:= AP_APPROVAL_PKG.G_GOODS_TOLERANCES(p_tolerance_id).rate_amt_tolerance;
            p_goods_total_amt_tolerance	:= AP_APPROVAL_PKG.G_GOODS_TOLERANCES(p_tolerance_id).total_amt_tolerance;
    END IF;

    IF p_services_tolerance_id IS NOT NULL THEN
	    p_amt_tolerance			:= AP_APPROVAL_PKG.G_SERVICES_TOLERANCES(p_services_tolerance_id).amount_tolerance;
            p_amt_rec_tolerance			:= AP_APPROVAL_PKG.G_SERVICES_TOLERANCES(p_services_tolerance_id).amt_received_tolerance;
            p_max_amt_ord_tolerance		:= AP_APPROVAL_PKG.G_SERVICES_TOLERANCES(p_services_tolerance_id).max_amt_ord_tolerance;
            p_max_amt_rec_tolerance		:= AP_APPROVAL_PKG.G_SERVICES_TOLERANCES(p_services_tolerance_id).max_amt_rec_tolerance;
            p_services_ship_amt_tolerance	:= AP_APPROVAL_PKG.G_SERVICES_TOLERANCES(p_services_tolerance_id).ser_ship_amt_tolerance;
            p_services_rate_amt_tolerance	:= AP_APPROVAL_PKG.G_SERVICES_TOLERANCES(p_services_tolerance_id).ser_rate_amt_tolerance;
            p_services_total_amt_tolerance	:= AP_APPROVAL_PKG.G_SERVICES_TOLERANCES(p_services_tolerance_id).ser_total_amt_tolerance;
    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Approval_Init;

/*=============================================================================
 |  PROCEDURE Inv_Needs_Approving
 |
 |      Function when given an invoice_id and run_option, it returns a boolean
 |      to indicate whether to approve an invoice or not.  Returns FALSE if the
 |      run_option is 'New' and the invoice doesn't have any unapproved
 |      distributions.
 |
 |  PARAMETERS
 |      p_invoice_id
 |      p_run_option
 |      p_calling_sequence
 |
 |  PROGRAM FLOW
 |
 |  KNOWN ISSUES
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

FUNCTION Inv_Needs_Approving(
             p_invoice_id          IN            NUMBER,
             p_run_option          IN            VARCHAR2,
             p_calling_sequence    IN            VARCHAR2) RETURN BOOLEAN
IS

  l_unapproved_dist_exists     NUMBER;
  l_undistributed_line_exists  VARCHAR2(30);
  l_debug_loc                  VARCHAR2(30) := 'Inv_Needs_Approving';
  l_curr_calling_sequence      VARCHAR2(2000);
  l_debug_info                 VARCHAR2(1000);
  l_api_name                   CONSTANT VARCHAR2(200) := 'Approval_Init';
BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  l_undistributed_line_exists := 'N';

  IF (p_run_option = 'New') THEN

    SELECT count(*)
    INTO   l_unapproved_dist_exists
    FROM   ap_invoice_distributions_all
    WHERE  invoice_id = p_invoice_id
    AND    (nvl(match_status_flag, 'N')) = 'N'
    AND    rownum = 1;

    --bugfix:4745464
    BEGIN
        SELECT 'Y'
        INTO   l_undistributed_line_exists
        FROM   ap_invoice_lines_all L
        WHERE  L.invoice_id = p_invoice_id
        AND    L.amount <>
             (SELECT NVL(SUM(NVL(aid.amount,0)),0)
	      FROM ap_invoice_distributions_all aid
	      WHERE aid.invoice_id = L.invoice_id
	      AND aid.invoice_line_number = L.line_number);
    END;

    IF (l_unapproved_dist_exists = 0 AND l_undistributed_line_exists = 'N') THEN

      l_debug_info := 'Skip Validation: Invoice_Id: ' || p_invoice_id;
      --  Print_Debug(l_api_name, l_debug_info);
      IF g_debug_mode = 'Y' THEN
         AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      return(FALSE);
    END IF;
  END IF;

  return(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
         || 'Run Option = ' || p_run_option);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Inv_Needs_Approving;

/*=============================================================================
 |  PROCEDURE  Update_Inv_Dists_To_Selected
 |
 |      Procedure given the invoice_id, invoice line number and  run option,
 |      updates the invoice distributions to be selected for approval depending
 |      on the run option.
 |      If the run_option is 'New' then we only select distributions that have
 |      never been processed by approval, otherwise we select all distributions
 |      that have not successfully been approved.
 |
 |  PARAMETERS
 |      p_invoice_id - invoice id
 |      p_line_number - invoice line number
 |      p_run_option
 |      p_calling_sequence
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

PROCEDURE Update_Inv_Dists_To_Selected(
              p_invoice_id        IN            NUMBER,
              p_line_number       IN            NUMBER,
              p_run_option        IN            VARCHAR2,
              p_calling_sequence  IN            VARCHAR2) IS

  l_debug_loc              VARCHAR2(30) := 'Update_Inv_Dists_To_Selected';
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_info             VARCHAR2(1000);
BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  IF (p_run_option = 'New') THEN

    l_debug_info :=  'Run Option: New: Set new distribution flag to S';
    --  Print_Debug (l_debug_loc,l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;

    UPDATE  ap_invoice_distributions_all D
    SET     match_status_flag = 'S'
    WHERE   NVL(match_status_flag, 'N') = 'N'
    AND     NVL(D.posted_flag, 'N' ) = 'N' -- Bug 9777752
    AND     D.invoice_id = p_invoice_id
    AND     D.invoice_line_number = p_line_number;


    --Bug	6963908
    UPDATE  ap_self_assessed_tax_dist_all D
    SET     match_status_flag = 'S'
    WHERE   NVL(match_status_flag, 'N') = 'N'
    AND     NVL(D.posted_flag, 'N' ) = 'N' -- Bug 9777752
    AND     D.invoice_id = p_invoice_id
    AND     D.invoice_line_number = p_line_number;
    --Bug	6963908

  ELSE

    l_debug_info :=  'Run Option: All: Set new distribution flag to S';
    --  Print_Debug (l_debug_loc,l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;

    UPDATE  ap_invoice_distributions_all D
    SET     match_status_flag = 'S'
    WHERE   NVL(match_status_flag, '!') <> 'A'
    AND     NVL(D.posted_flag, 'N' ) = 'N' -- Bug 9777752
    AND     D.invoice_id = p_invoice_id;

    --Bug	6963908
    UPDATE  ap_self_assessed_tax_dist_all D
    SET     match_status_flag = 'S'
    WHERE   NVL(match_status_flag, '!') <> 'A'
    AND     NVL(D.posted_flag, 'N' ) = 'N' -- Bug 9777752
    AND     D.invoice_id = p_invoice_id;
    --Bug	6963908

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
         || 'Run Option = ' || p_run_option);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Update_Inv_Dists_To_Selected;


/*=============================================================================
 |  PUBLIC PROCEDURE  Check_Insufficient_Line_Data
 |
 |  DESCRIPTION:
 |                Check all the line information before Distribution generated
 |  PARAMETERS
 |    p_inv_line_rec
 |    p_system_user
 |    p_holds
 |    p_holds_count
 |    p_release_count
 |    p_insufficent_data_exist - boolean indicates if a hold is existing
 |    p_calling_sequence
 |
 |   PROGRAM FLOW
 |     Check for Sufficient Line Data in a priliminary level
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

PROCEDURE Check_Insufficient_Line_Data(
              p_inv_line_rec             IN AP_INVOICES_PKG.r_invoice_line_rec,
              p_system_user              IN            NUMBER,
              p_holds                    IN OUT NOCOPY HOLDSARRAY,
              p_holds_count              IN OUT NOCOPY COUNTARRAY,
              p_release_count            IN OUT NOCOPY COUNTARRAY,
              p_insufficient_data_exist     OUT NOCOPY BOOLEAN,
	      p_calling_mode		 IN            VARCHAR2,
              p_calling_sequence         IN            VARCHAR2)
IS

  CURSOR Alloc_Rule_Cur IS
  SELECT ALOC.rule_type
  FROM   ap_invoice_lines  AIL,
         ap_allocation_rules ALOC
  WHERE  AIL.invoice_id = p_inv_line_rec.invoice_id
    AND  AIL.line_number = p_inv_line_rec.line_number
    AND  AIL.invoice_id = ALOC.invoice_id
    AND  AIL.line_number = ALOC.chrg_invoice_line_number(+);

  l_debug_loc              VARCHAR2(30) := 'Check_Insufficient_Line_Data';
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_info             VARCHAR2(1000);
  l_ret_val                BOOLEAN;
  l_should_have_hold       VARCHAR2(1) := 'N';
  l_alloc_rule_type        ap_allocation_rules.rule_type%TYPE;
  l_product_registered     BOOLEAN;
  l_dummy                  VARCHAR2(100);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||
                             '<-'||p_calling_sequence;

  p_insufficient_data_exist := FALSE;

  OPEN Alloc_Rule_Cur;
  FETCH Alloc_Rule_Cur INTO l_alloc_rule_type;
    IF (Alloc_Rule_Cur%NOTFOUND) THEN
      l_alloc_rule_type := NULL;
    END IF;
  CLOSE Alloc_Rule_Cur;

  IF (Is_Product_Registered(
  		P_application_id => p_inv_line_rec.application_id,
	        X_registration_api    => l_dummy,
	        X_registration_view   => l_dummy,
	        P_calling_sequence    => l_curr_calling_sequence)) THEN
     l_product_registered := TRUE;
  ELSE
     l_product_registered := FALSE;
  END IF;

  ----
  l_debug_info := 'processing info for line number: '||p_inv_line_rec.line_number
                             ||' l_alloc_rule_type: '||l_alloc_rule_type
                                   || ' project_id: '||p_inv_line_rec.project_id
                                ||' generate_dists: '||p_inv_line_rec.generate_dists;
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  ----

  IF (p_inv_line_rec.generate_dists = 'Y'
      and p_inv_line_rec.distribution_set_id IS NULL
      and p_inv_line_rec.default_dist_ccid IS NULL
      and l_alloc_rule_type IS NULL
      and p_inv_line_rec.project_id IS NULL
      and NOT l_product_registered) THEN

      l_debug_info := 'should have hold for line:  '||p_inv_line_rec.line_number;
      --  Print_Debug(l_debug_loc, l_debug_info);
      IF g_debug_mode = 'Y' THEN
         AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
      END IF;

      l_should_have_hold := 'Y';
      p_insufficient_data_exist := TRUE;
  END IF;

  IF (p_calling_mode = 'PERMANENT_DISTRIBUTIONS') THEN
      Process_Inv_Hold_Status(
		p_inv_line_rec.invoice_id,
		null,
		null,
		'INSUFFICIENT LINE INFO',
		l_should_have_hold,
		null,
		p_system_user,
		p_holds,
		p_holds_count,
		p_release_count,
		l_curr_calling_sequence);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_inv_line_rec.invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;

    IF ( Alloc_Rule_Cur%ISOPEN ) THEN
      CLOSE Alloc_Rule_Cur;
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Insufficient_Line_Data;


/*=============================================================================
 |  PUBLIC PROCEDURE  Execute_Dist_Generation_Check
 |
 |  DESCRIPTION:
 |                Call API to generate Distribution from distribution set or
 |                generate distribution based on allocation/default account
 |                information. Handle the error code detected during dist.
 |                generation. Process/Release corresponding Hold.
 |  PARAMETERS
 |    p_batch_id
 |    p_invoice_date
 |    p_vendor_id
 |    p_invoice_currency
 |    p_exchange_rate
 |    p_exchange_rate_type
 |    p_exchange_date
 |    p_inv_line_rec
 |    p_system_user
 |    p_holds
 |    p_holds_count
 |    p_release_count
 |    p_curr_calling_sequence
 |
 |  PROGRAM FLOW
 |
 |  KNOWN ISSUES
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

FUNCTION  Execute_Dist_Generation_Check(
              p_batch_id                IN            NUMBER,
              p_invoice_date            IN            DATE,
              p_vendor_id               IN            NUMBER,
              p_invoice_currency        IN            VARCHAR2,
              p_exchange_rate           IN            NUMBER,
              p_exchange_rate_type      IN            VARCHAR2,
              p_exchange_date           IN            DATE,
              p_inv_line_rec            IN AP_INVOICES_PKG.r_invoice_line_rec,
              p_system_user             IN            NUMBER,
              p_holds                   IN OUT NOCOPY HOLDSARRAY,
              p_holds_count             IN OUT NOCOPY COUNTARRAY,
              p_release_count           IN OUT NOCOPY COUNTARRAY,
	      p_generate_permanent      IN            VARCHAR2,
	      p_calling_mode            IN            VARCHAR2 ,
	      p_error_code              OUT NOCOPY    VARCHAR2,
              p_curr_calling_sequence   IN            VARCHAR2) RETURN BOOLEAN
IS

  CURSOR Alloc_Rule_Cur IS
  SELECT ALOC.rule_type
  FROM   ap_invoice_lines  AIL,
         ap_allocation_rules ALOC
  WHERE  AIL.invoice_id = p_inv_line_rec.invoice_id
    AND  AIL.line_number = p_inv_line_rec.line_number
    AND  AIL.invoice_id = ALOC.invoice_id
    AND  AIL.line_number = ALOC.chrg_invoice_line_number(+);

  l_debug_loc                 VARCHAR2(30) := 'Execute_Dist_Generation_Check';
  l_curr_calling_sequence     VARCHAR2(2000);
  l_debug_info                VARCHAR2(2000);
  l_alloc_rule_type           ap_allocation_rules.rule_type%TYPE;

  l_debug_context             VARCHAR2(2000);
  l_msg_application           VARCHAR2(25);
  l_error_code                VARCHAR2(4000);
  l_msg_data                  VARCHAR2(30);
  l_hold_code                 VARCHAR2(30);
  l_success                   BOOLEAN := FALSE;
  l_gen_dist_hold_exists      VARCHAR2(1) := 'N';

  --Bugfix:4673607
  l_registration_api	      VARCHAR2(1000);
  l_registration_view         VARCHAR2(1000);
  l_reference_key1	      ap_invoice_lines_all.reference_key1%type;
  l_reference_key2	      ap_invoice_lines_all.reference_key2%type;
  l_reference_key3	      ap_invoice_lines_all.reference_key3%type;
  l_reference_key4	      ap_invoice_lines_all.reference_key4%type;
  l_reference_key5	      ap_invoice_lines_all.reference_key5%type;
  l_err varchar2(2000);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                             p_curr_calling_sequence;

  ----------------------------------------------------------------------
  l_debug_info := 'Input Parameters: '||' invoice id: '         ||p_inv_line_rec.invoice_id
				      ||' line_number: '        ||p_inv_line_rec.line_number
				      ||' generate_dists: '     ||p_inv_line_rec.generate_dists
				      ||' distribution_set_id: '||p_inv_line_rec.distribution_set_id
				      ||' accouting_date: '     ||p_inv_line_rec.accounting_date
				      ||' period_name: '        ||p_inv_line_rec.period_name;
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  ----------------------------------------------------------------------

  IF (Is_Product_Registered(P_application_id	=> p_inv_line_rec.application_id,
			    X_registration_api  => l_registration_api,
			    X_registration_view => l_registration_view,
			    P_calling_sequence  => l_curr_calling_sequence)) THEN

      ----------------------------------------------------------------------
      l_debug_info := 'Call the api that will create the distributions '||
                      'based on the other products registered view/api';
      --  Print_Debug(l_debug_loc, l_debug_info);
      IF g_debug_mode = 'Y' THEN
         AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
      END IF;
      ----------------------------------------------------------------------

      l_success := Gen_Dists_From_Registration(
				     P_Batch_Id		   => p_batch_id,
    				     P_Invoice_Line_Rec    => p_inv_line_rec,
				     P_Registration_Api    => l_registration_api,
				     P_Registration_View   => l_registration_view,
				     P_Generate_Permanent  => p_generate_permanent,
				     X_Error_Code          => l_error_code,
				     P_Calling_Sequence    => l_curr_calling_sequence);


  ELSIF ( p_inv_line_rec.distribution_set_id is not null) THEN

    /*-----------------------------------------------------------------+
     | CASE 1 - Generate distribution from distribution set            |
     +-----------------------------------------------------------------*/

    l_debug_info := 'Execute_Dist_Generation_Check - insert from dist set';
    --  Print_Debug(l_debug_loc, l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;

    l_success := AP_INVOICE_LINES_PKG.Insert_From_Dist_Set(
                   X_invoice_id          => p_inv_line_rec.invoice_id,
                   X_line_number         => p_inv_line_rec.line_number,
                   X_GL_Date             => p_inv_line_rec.accounting_date,
                   X_Period_Name         => p_inv_line_rec.period_name,
                   X_Skeleton_Allowed    => 'Y', -- Bug 4928285
                   X_Generate_Dists      => p_inv_line_rec.generate_dists,
                   X_Generate_Permanent  => p_generate_permanent,
                   X_Error_Code          => l_error_code,
                   X_Debug_Info          => l_debug_info,
                   X_Debug_Context       => l_debug_context,
                   X_Msg_Application     => l_msg_application,
                   X_Msg_Data            => l_msg_data,
                   X_calling_sequence    => l_curr_calling_sequence);

    IF ( NOT l_success ) THEN

      IF ( l_error_code is not null ) THEN

	 IF (p_calling_mode = 'PERMANENT_DISTRIBUTIONS') THEN

            CASE l_error_code
               WHEN 'AP_VEN_DIST_SET_INVALID'    THEN
                  l_hold_code := 'DISTRIBUTION SET INACTIVE';
               WHEN 'AP_CANT_USE_SKELETON_DIST_SET' THEN
                  l_hold_code := 'SKELETON DISTRIBUTION SET';
               WHEN 'AP_CANNOT_OVERLAY'    THEN
                  l_hold_code := 'CANNOT OVERLAY ACCOUNT';
               WHEN 'AP_INVALID_CCID'    THEN
                  l_hold_code := 'INVALID DEFAULT ACCOUNT';
               ELSE
                  l_hold_code := null;
            END CASE;

         ELSIF (p_calling_mode = 'CANDIDATE_DISTRIBUTIONS') THEN

            p_error_code := l_error_code;

         END IF;

         l_debug_info := 'Execute_Dist_Generation_Check: Error Code: ' || l_error_code;
	 --  Print_Debug(l_debug_loc, l_debug_info);
         IF g_debug_mode = 'Y' THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
         END IF;

      ELSE

         IF (p_calling_mode =  'CANDIDATE_DISTRIBUTIONS') THEN
           p_error_code := l_debug_info;

	 END IF;

      END IF; /*l_error_code is not null*/

    END IF; -- end of check l_success

  ELSE

    /*-----------------------------------------------------------------+
     | CASE 2 - Generate distribution without distribution set info    |
     +-----------------------------------------------------------------*/

    OPEN Alloc_Rule_Cur;
    FETCH Alloc_Rule_Cur INTO l_alloc_rule_type;
    IF (Alloc_Rule_Cur%NOTFOUND) THEN
      l_alloc_rule_type := NULL;
    END IF;
    CLOSE Alloc_Rule_Cur;

    IF ( p_inv_line_rec.line_type_lookup_code in ('FREIGHT', 'MISCELLANEOUS' ) and
         l_alloc_rule_type is not null ) THEN

    /*-----------------------------------------------------------------+
     | CASE 2.1 - Generate distribution for charge line if there is an |
     |            allocation rule                                      |
     +-----------------------------------------------------------------*/

      l_debug_info := 'Execute_Dist_Generation_Check - charge line with an allocation rule';
      --  Print_Debug(l_debug_loc, l_debug_info);
      IF g_debug_mode = 'Y' THEN
         AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
      END IF;

      l_success := AP_INVOICE_DISTRIBUTIONS_PKG.Insert_Charge_From_Alloc(
                         X_invoice_id          => p_inv_line_rec.invoice_id,
                         X_line_number         => p_inv_line_rec.line_number,
                         X_Generate_Permanent  => p_generate_permanent,
                         X_Validate_Info       => TRUE,
                         X_Error_Code          => l_error_code,
                         X_Debug_Info          => l_debug_info,
                         X_Debug_Context       => l_debug_context,
                         X_Msg_Application     => l_msg_application,
                         X_Msg_Data            => l_msg_data,
                         X_Calling_Sequence    => l_curr_calling_sequence );

      IF ( NOT l_success ) THEN
        IF ( l_error_code is not null ) THEN

	  IF (p_calling_mode = 'PERMANENT_DISTRIBUTIONS') THEN
             IF ( l_error_code IN ( 'AP_NO_ALLOCATION_RULE_FOUND',
                                  'AP_ALLOCATION_ALREADY_EXECUTED',
                                  'AP_NON_FULL_INVOICE',
                                  'AP_UNDISTRIBUTED_LINE_EXISTS',
                                  'AP_IMPROPER_LINE_IN_ALLOC_RULE',
                                  'AP_CANNOT_READ_EXP_DATE',
                                  'AP_INVALID_ACCOUNT',
                                  'AP_CANNOT_OVERLAY',
                                  'AP_NO_OPEN_PERIOD',
                                  'AP_GL_DATE_PA_NOT_OPEN' ) ) THEN
                l_hold_code := 'CANNOT EXECUTE ALLOCATION';
             ELSE
                l_hold_code := null;
             END IF;

          ELSIF (p_calling_mode = 'CANDIDATE_DISTRIBUTIONS') THEN
             p_error_code := l_error_code;
	  END IF;

          l_debug_info := 'Execute_Dist_Generation_Check -  ' ||
                          'Insert_Charge_From_Alloc error '   || l_error_code;
	  --  Print_Debug (l_debug_loc, l_debug_info);
          IF g_debug_mode = 'Y' THEN
             AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
          END IF;

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
          END IF;

        END IF; -- end of check l_error_code
      END IF; -- end of check l_success
--8346277
    ELSIF (p_inv_line_rec.line_type_lookup_code in ('AWT' )
	       AND p_inv_line_rec.line_source ='MANUAL LINE ENTRY')  THEN

     /*-----------------------------------------------------------------+
     | CASE 2.2.1 - Generate distribution for non-match item line or no |
     |            allocation rule charge line                           |
     +-----------------------------------------------------------------*/

      l_debug_info := 'Execute_Dist_Generation_Check - Insert_AWT_Dist_From_Line';
      --  Print_Debug(l_debug_loc, l_debug_info);
      IF g_debug_mode = 'Y' THEN
         AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
      END IF;

      l_success := AP_INVOICE_DISTRIBUTIONS_PKG.Insert_AWT_Dist_From_Line(
                       X_batch_id            => p_batch_id,
                       X_invoice_id          => p_inv_line_rec.invoice_id,
                       X_invoice_date        => p_invoice_date,
                       X_vendor_id           => p_vendor_id,
                       X_invoice_currency    => p_invoice_currency,
                       X_exchange_rate       => p_exchange_rate,
                       X_exchange_rate_type  => p_exchange_rate_type,
                       X_exchange_date       => p_exchange_date,
                       X_line_number         => p_inv_line_rec.line_number,
                       X_invoice_lines_rec   => NULL,
                       X_line_source         => 'VALIDATION',
                       X_Generate_Permanent  => p_generate_permanent,
                       X_Validate_Info       => TRUE,
                       X_Error_Code          => l_error_code,
                       X_Debug_Info          => l_debug_info,
                       X_Debug_Context       => l_debug_context,
                       X_Msg_Application     => l_msg_application,
                       X_Msg_Data            => l_msg_data,
                       X_Calling_Sequence    => l_curr_calling_sequence);


      IF l_success = FALSE THEN

         FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
         FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
         FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
         FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
         FND_MESSAGE.SET_TOKEN('l_error_code',l_error_code);
         FND_MESSAGE.SET_TOKEN('PARAMETERS','fail '|| 'Invoice_id  = '|| to_char(p_inv_line_rec.invoice_id));
         FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
         APP_EXCEPTION.RAISE_EXCEPTION;

      END IF;
    ELSE

     /*-----------------------------------------------------------------+
     | CASE 2.2 - Generate distribution for non-match item line or no   |
     |            allocation rule charge line                           |
     +-----------------------------------------------------------------*/

      l_debug_info := 'Execute_Dist_Generation_Check - Insert_Single_Dist_From_Line';
      --  Print_Debug(l_debug_loc, l_debug_info);
      IF g_debug_mode = 'Y' THEN
         AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
      END IF;

      l_success := AP_INVOICE_DISTRIBUTIONS_PKG.Insert_Single_Dist_From_Line(
                       X_batch_id            => p_batch_id,
                       X_invoice_id          => p_inv_line_rec.invoice_id,
                       X_invoice_date        => p_invoice_date,
                       X_vendor_id           => p_vendor_id,
                       X_invoice_currency    => p_invoice_currency,
                       X_exchange_rate       => p_exchange_rate,
                       X_exchange_rate_type  => p_exchange_rate_type,
                       X_exchange_date       => p_exchange_date,
                       X_line_number         => p_inv_line_rec.line_number,
                       X_invoice_lines_rec   => NULL,
                       X_line_source         => 'VALIDATION',
                       X_Generate_Permanent  => p_generate_permanent,
                       X_Validate_Info       => TRUE,
                       X_Error_Code          => l_error_code,
                       X_Debug_Info          => l_debug_info,
                       X_Debug_Context       => l_debug_context,
                       X_Msg_Application     => l_msg_application,
                       X_Msg_Data            => l_msg_data,
                       X_Calling_Sequence    => l_curr_calling_sequence);

      IF ( NOT l_success ) THEN
        IF ( l_error_code is not null ) THEN

	  IF (p_calling_mode = 'PERMANENT_DISTRIBUTIONS') THEN

             CASE l_error_code
               WHEN 'INVALID_ACCOUNT'    THEN
                 l_hold_code := 'INVALID DEFAULT ACCT';
               WHEN 'CANNOT_OVERLAY'    THEN
                 l_hold_code := 'CANNOT OVERLAY ACCOUNT';
               WHEN 'NOT_OPEN_PERIOD'   THEN
                 -- attention: need to confirm later
                 l_hold_code := 'PERIOD CLOSED';
               WHEN 'GL_DATE_PA_NOT_OPEN'    THEN
                 l_hold_code := 'PROJECT GL DATE CLOSED';
               ELSE
                 l_hold_code := null;
             END CASE;

          ELSIF (p_calling_mode = 'CANDIDATE_DISTRIBUTIONS') THEN

	     p_error_code := l_error_code;

	  END IF;  /*p_calling_mode = 'PERMANENT_DISTRIBUTIONS' */

          l_debug_info := 'Execute_Dist_Generation_Check-insert from dist'
                           || ' set has error - ' || l_error_code ;
          --  Print_Debug(l_debug_loc, l_debug_info);
          IF g_debug_mode = 'Y' THEN
             AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
          END IF;

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
          END IF;

        END IF; -- end of check l_error_code
      END IF; -- end of check l_success
    END IF; -- end of p_inv_line_rec.line_type_lookup_code check
  END IF; -- end of p_inv_line_rec.distribution_set_id check

    /*-----------------------------------------------------------------+
     | To process the error code and the put hold if necessary         |
     +-----------------------------------------------------------------*/

  IF ( NOT l_success and l_hold_code is not null ) THEN
    l_gen_dist_hold_exists := 'Y';

    l_debug_info := 'Execute_Dist_Generation_Check - Process hold code';
    --  Print_Debug(l_debug_loc, l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;

  --BUGFIX:5685469
  --Need to release the holds (related to distribution generation) placed in earlier calls of
  --validation
  ELSIF (p_calling_mode = 'PERMANENT_DISTRIBUTIONS' AND  l_success AND l_hold_code IS NULL) THEN

     BEGIN

       l_debug_info := 'Release any holds related to distribution generation which were placed earlier';
       --  Print_Debug(l_debug_loc, l_debug_info);
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
       END IF;

       IF ( p_inv_line_rec.distribution_set_id is not null) THEN

          SELECT hold_lookup_code
          INTO l_hold_code
          FROM ap_holds_all
          WHERE invoice_id = p_inv_line_rec.invoice_id
          AND hold_lookup_code in ('DISTRIBUTION SET INACTIVE','SKELETON DISTRIBUTION SET',
                             'CANNOT OVERLAY ACCOUNT','INVALID DEFAULT ACCOUNT')
          AND release_lookup_code IS NULL;

       ELSIF ( p_inv_line_rec.line_type_lookup_code in ('FREIGHT', 'MISCELLANEOUS' ) and
               l_alloc_rule_type is not null ) THEN

          SELECT hold_lookup_code
	  INTO l_hold_code
	  FROM ap_holds_all
	  WHERE invoice_id = p_inv_line_rec.invoice_id
	  AND hold_lookup_code = 'CANNOT EXECUTE ALLOCATION'
	  AND release_lookup_code IS NULL;

       ELSE

          SELECT hold_lookup_code
	  INTO l_hold_code
	  FROM ap_holds_all
	  WHERE invoice_id = p_inv_line_rec.invoice_id
	  AND hold_lookup_code in ('CANNOT OVERLAY ACCOUNT','INVALID DEFAULT ACCOUNT',
	  			   'PERIOD CLOSED','PROJECT GL DATE CLOSED')
	  AND release_lookup_code IS NULL;

       END IF;

     EXCEPTION WHEN OTHERS THEN
      /* l_err := sqlerrm;
       l_debug_info := 'in others exception '||l_err;
       Print_Debug(l_debug_loc, l_debug_info); */

       NULL;
     END ;

  END IF;


  --Etax: Validation. Added the IF condition so that when this
  --procedure is called from funds_check, we not process any holds.
  IF (p_calling_mode = 'PERMANENT_DISTRIBUTIONS') THEN
     Process_Inv_Hold_Status(
    	  p_inv_line_rec.invoice_id,
          null,
      	  null,
          l_hold_code,
          l_gen_dist_hold_exists,
          null,
          p_system_user,
          p_holds,
          p_holds_count,
          p_release_count,
          l_curr_calling_sequence);
  END IF;

  RETURN ( l_success );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_inv_line_rec.invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;

    IF ( Alloc_Rule_Cur%ISOPEN ) THEN
      CLOSE Alloc_Rule_Cur;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Execute_Dist_Generation_Check;


/*=============================================================================
 |  PROCEDURE EXECUTE_GENERAL_CHECKS
 |      Procedure that checks general information hold at invoice level and
 |      invoice distribution level.
 |
 |  PARAMETER
 |      p_invoice_id
 |      p_set_of_books_id
 |      p_base_currency_code
 |      p_invoice_amount
 |      p_base_amount
 |      p_invoice_currency_code
 |      p_invoice_amount_limit
 |      p_hold_future_payments_flag
 |      p_system_user
 |      p_holds
 |      p_holds_count
 |      p_release_count
 |      p_calling_sequence
 |
 |  PROGRAM FLOW
 |      1. Check for Invalid Dist Acct - set or release hold
 |      2. Check for PO Required - set or release hold
 |      3. Check for Missing Exchange Rate - set or release hold
 |      4. Check for UnOpen Future Period - set or release hold
 |      5. Check for Invoice Limit and vendor holds - set or release hold
 |      6. Check for project information
 |      7. Check for AWT manual segment - comment out for now
 |      8. Check for Prepayment amount - comment out for now
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 ============================================================================*/


PROCEDURE Execute_General_Checks(
              p_invoice_id                IN            NUMBER,
              p_set_of_books_id           IN            NUMBER,
              p_base_currency_code        IN            VARCHAR2,
              p_invoice_amount            IN            NUMBER,
              p_base_amount               IN            NUMBER,
              p_invoice_currency_code     IN            VARCHAR2,
              p_invoice_amount_limit      IN            NUMBER,
              p_hold_future_payments_flag IN            VARCHAR2,
              p_system_user               IN            NUMBER,
              p_holds                     IN OUT NOCOPY HOLDSARRAY,
              p_holds_count               IN OUT NOCOPY COUNTARRAY,
              p_release_count             IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence          IN            VARCHAR2) IS

  l_debug_loc                 VARCHAR2(30) := 'Execute_General_Checks';
  l_curr_calling_sequence     VARCHAR2(2000);
  l_debug_info                VARCHAR2(1000);

    -- 8691645
  l_vendor_id           AP_INVOICES.VENDOR_ID%TYPE;
  l_vendor_site_id	AP_INVOICES.VENDOR_SITE_ID%TYPE;
  l_remit_to_supplier_site_id   AP_INVOICES.REMIT_TO_SUPPLIER_SITE_ID%TYPE;
  l_invoice_type_lookup_code   AP_INVOICES.INVOICE_TYPE_LOOKUP_CODE%TYPE;
  l_vendor_site_reg_expired    varchar2(1);

BEGIN

   l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                              p_calling_sequence;

   ---------------------------------------------------
   l_debug_info := 'Execute_General_Checks: '
    				||' invoice id: ' 	   ||p_invoice_id
				||' set of books id: '	   ||p_set_of_books_id
				||' base currency code: '  ||p_base_currency_code
				||' invoice amount: '	   ||p_invoice_amount
				||' inv base amount: '	   ||p_base_amount
				||' inv currency code: '   ||p_invoice_currency_code
				||' invoice amount limit: '||p_invoice_amount_limit
				||' hold future pay flag: '||p_hold_future_payments_flag;

   --  Print_Debug(l_debug_loc, l_debug_info);
   IF g_debug_mode = 'Y' THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
   END IF;
   ---------------------------------------------------

     -- Bug 7158219
     ---------------------------------------------------
     l_debug_info := 'Check Invalid Distribution Account';
     --  Print_Debug(l_debug_loc, l_debug_info);
     IF g_debug_mode = 'Y' THEN
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
     END IF;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
     END IF;
     ---------------------------------------------------

     Check_Invalid_Dist_Acct(
              p_invoice_id,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
              l_curr_calling_sequence);

    ---------------------------------------------------
    l_debug_info := 'Check PO Required';
    --  Print_Debug(l_debug_loc, l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;
    ---------------------------------------------------
    Check_PO_Required(
	      p_invoice_id,
	      p_system_user,
	      p_holds,
	      p_holds_count,
	      p_release_count,
	      l_curr_calling_sequence);

    ---------------------------------------------------
    l_debug_info := 'Check for Missing Exchange Rate';
    --  Print_Debug(l_debug_loc, l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;
    ---------------------------------------------------
    Check_No_Rate(
	      p_invoice_id,
	      p_base_currency_code,
	      p_system_user,
	      p_holds,
	      p_holds_count,
	      p_release_count,
	      l_curr_calling_sequence);

 --bug9296410
  ---------------------------------------------------
    l_debug_info := 'Check for Project Commitments For Retainage invoices ';
    --  Print_Debug(l_debug_loc, l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;
    ---------------------------------------------------

   Select  vendor_id,vendor_site_id,
	     remit_to_supplier_site_id,invoice_type_lookup_code
     into    l_vendor_id,l_vendor_site_id,
	     l_remit_to_supplier_site_id,l_invoice_type_lookup_code
     from ap_invoices_all
     where invoice_id = p_invoice_id;

     if ( l_invoice_type_lookup_code = 'RETAINAGE RELEASE') then


    Check_Project_Commitments(
	      p_invoice_id,
	      p_system_user,
	      p_holds,
	      p_holds_count,
	      p_release_count,
	      l_curr_calling_sequence);
   end if ;


    ---------------------------------------------------
    l_debug_info := 'Check for invoice limit and vendor holds';
    --  Print_Debug(l_debug_loc, l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;
    ---------------------------------------------------
    Check_invoice_vendor(
	      p_invoice_id,
	      p_base_currency_code,
	      p_invoice_amount,
	      p_base_amount,
	      p_invoice_currency_code,
	      p_invoice_amount_limit,
	      p_hold_future_payments_flag,
	      p_system_user,
	      p_holds,
	      p_holds_count,
	      p_release_count,
	      l_curr_calling_sequence);
-- Bug 8260168 Removing this Redundant call
/*
    ---------------------------------------------------
    l_debug_info := 'Check Prepaid Amount Exceeds Invoice Amount';
    Print_Debug(l_debug_loc, l_debug_info);
    ---------------------------------------------------
    Check_Prepaid_Amount(
	      p_invoice_id,
	      p_system_user,
	      p_holds,
	      p_holds_count,
	      p_release_count,
	      l_curr_calling_sequence);
*/

    --Start of 8691645
   -----------------------------------------------------------------------------------
   l_debug_info := 'Check whether vendor is CCR registered and registration is active';
   --  Print_Debug(l_debug_loc, l_debug_info);
   IF g_debug_mode = 'Y' THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
   END IF;
   ------------------------------------------------------------------------------------
    --bug9296410 the below code is commented here and moved above before the call to "Check_Project_Commitments" to reduce redundency

     /* Select  vendor_id,vendor_site_id,
	     remit_to_supplier_site_id,invoice_type_lookup_code
     into    l_vendor_id,l_vendor_site_id,
	     l_remit_to_supplier_site_id,l_invoice_type_lookup_code
     from ap_invoices_all
     where invoice_id = p_invoice_id; */



      if(upper(l_invoice_type_lookup_code) in ('STANDARD','PREPAYMENT'))then

       CHECK_CCR_VENDOR(
              p_invoice_id,
              l_vendor_id,
              l_vendor_site_id,
	      l_remit_to_supplier_site_id,
              p_system_user,
              p_holds,
              p_holds_count,
              p_release_count,
	      l_vendor_site_reg_expired,
              l_curr_calling_sequence);

       end if;


       --End of 8691645

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Set of Books Id = '|| to_char(p_set_of_books_id)
              ||', Base Currency Code = '|| p_base_currency_code);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Execute_General_Checks;

/*=============================================================================
 |  PROCEDURE CHECK_INVALID_DIST_ACCT
 |      Procedure that checks whether an invoice has a distribution with an
 |      invalid distribution account and places or releases the
 |      DIST ACCT INVALID hold depending on the condition.
 |
 |  PARAMETER
 |      p_invoice_id
 |      p_system_user
 |      p_holds
 |      p_holds_count
 |      p_release_count
 |      p_calling_sequence
 |
 |  PROGRAM FLOW
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 ============================================================================*/

PROCEDURE Check_Invalid_Dist_Acct(
              p_invoice_id          IN            NUMBER,
              p_system_user         IN            NUMBER,
              p_holds               IN OUT NOCOPY HOLDSARRAY,
              p_holds_count         IN OUT NOCOPY COUNTARRAY,
              p_release_count       IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence    IN            VARCHAR2) IS

  CURSOR Invalid_Dist_Acct_Cur IS
    SELECT  D.dist_code_combination_id, D.accounting_date
    FROM    ap_invoice_distributions D
    WHERE   D.invoice_id = p_invoice_id
    AND     D.posted_flag||'' in ('N', 'P')
    AND ((EXISTS (select 'x'
                  from gl_code_combinations C
                  where D.dist_code_combination_id = C.code_combination_id (+)
                  and (C.code_combination_id is null
                     or C.detail_posting_allowed_flag = 'N'
                     or C.start_date_active > D.accounting_date
                     or C.end_date_active < D.accounting_date
                     or C.template_id is not null
                     or C.enabled_flag <> 'Y'
                     or C.summary_flag <> 'N'
                     )))
    OR (D.dist_code_combination_id = -1))
    AND ROWNUM = 1;

  CURSOR Alternate_Account_Cur (c_ccid NUMBER, c_acct_date DATE) IS
        SELECT 'Y'
          FROM gl_code_combinations glcc
         WHERE glcc.code_combination_id = c_ccid
           AND glcc.alternate_code_combination_id IS NOT NULL
           AND EXISTS
                (
                 SELECT 'Account Valid'
                   FROM gl_code_combinations a
                  WHERE a.code_combination_id         = glcc.alternate_code_combination_id
                    AND a.enabled_flag                = 'Y'
                    AND a.detail_posting_allowed_flag = 'Y'
                    AND c_acct_date BETWEEN NVL(a.start_date_active, c_acct_date)
                                        AND NVL(a.end_date_active, c_acct_date)
                );

  l_ccid			AP_INVOICE_DISTRIBUTIONS_ALL.dist_code_combination_id%TYPE;
  l_accounting_date		AP_INVOICE_DISTRIBUTIONS_ALL.accounting_date%TYPE;
  l_alt_exists			VARCHAR2(50) := 'N';
  l_invalid_dist_ccid_exists    VARCHAR2(1)  := 'N';
  l_test_var                    VARCHAR2(50);
  l_debug_loc                   VARCHAR2(30) := 'Check_Invalid_Dist';
  l_curr_calling_sequence       VARCHAR2(2000);
  l_debug_info                  VARCHAR2(1000);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  IF (g_debug_mode = 'Y') THEN
    l_debug_info := 'General check - check invalid dist account';
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    AP_Debug_Pkg.Print(g_debug_mode, 'invoice id :'||
                       to_char(p_invoice_id) );
  END IF;

  OPEN Invalid_Dist_Acct_Cur;
  LOOP
    FETCH Invalid_Dist_Acct_Cur INTO l_ccid, l_accounting_date;
    EXIT WHEN Invalid_DIst_Acct_Cur%NOTFOUND;

     IF (g_debug_mode = 'Y') THEN
       l_debug_info := 'Inside loop of curser - Invalid_Dist_Acct_Cur';
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       AP_Debug_Pkg.Print(g_debug_mode, 'invalid dist ccid hold'||
                          l_invalid_dist_ccid_exists);
     END IF;

     --
     -- Per discussion with Shelley/Enda we will not place a hold
     -- when the distribution account is invalid and there is a
     -- valid alternate account defined in GL.
     -- Create Accounting will use the alternate account to
     -- generate the journal entries. The invoice distribution
     -- will not be stamped back with the alternate account.
     --
     OPEN  Alternate_Account_Cur(l_ccid, l_accounting_date);
     FETCH Alternate_Account_Cur
      INTO l_alt_exists;
     CLOSE Alternate_Account_Cur;

     IF (g_debug_mode = 'Y') THEN
       AP_Debug_Pkg.Print(g_debug_mode, 'Alternate Account Exists: '||
                          l_alt_exists);
     END IF;

     IF l_alt_exists = 'Y'  THEN
        l_invalid_dist_ccid_exists := 'N';
     ELSE
        l_invalid_dist_ccid_exists := 'Y';
     END IF;

  END LOOP;
  CLOSE Invalid_Dist_Acct_Cur;

  IF (g_debug_mode = 'Y') THEN
    l_debug_info := 'Process DIST ACCT INVALID hold status on invoice';
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  Process_Inv_Hold_Status(
      p_invoice_id,
      null,
      null,
      'DIST ACCT INVALID',
      l_invalid_dist_ccid_exists,
      null,
      p_system_user,
      p_holds,
      p_holds_count,
      p_release_count,
      l_curr_calling_sequence);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;

    IF ( Invalid_Dist_Acct_Cur%ISOPEN ) THEN
      CLOSE Invalid_Dist_Acct_Cur;
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Invalid_Dist_Acct;

/*=============================================================================
 |  PROCEDURE CHECK_PO_REQUIRED
 |      Procedure that checks whether an invoice  has a PO REQUIRED
 |      condition and places or releases the hold depending on the condition
 |      For those distribution lines which have "pa_additon_flag" = 'T', means
 |      they are transferred from projects; Payables does not enforce po
 |      information requirment.
 |
 |  PARAMETER
 |      p_invoice_id
 |      p_system_user
 |      p_holds
 |      p_holds_count
 |      p_release_count
 |      p_calling_sequence
 |
 |  PROGRAM FLOW
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 ============================================================================*/

PROCEDURE Check_PO_Required(
              p_invoice_id         IN            NUMBER,
              p_system_user        IN            NUMBER,
              p_holds              IN OUT NOCOPY HOLDSARRAY,
              p_holds_count        IN OUT NOCOPY COUNTARRAY,
              p_release_count      IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence   IN            VARCHAR2) IS

    CURSOR PO_Required_Cur IS
    -- Perf bug 5058995
    -- Modify below SQL to go to base tables : AP_INVOICES_ALL,
    -- AP_INVOICE_DISTRIBUTIONS_ALL and
    -- AP_SUPPLIER_SITES(instead of po_vendor_sites)
    /* Added the Hint index(apd AP_INVOICE_DISTRIBUTIONS_U1) for bug#7270053 */
    SELECT 'PO REQUIRED'
    FROM ap_invoices_all api, ap_supplier_sites pov
    WHERE EXISTS (select /*+ index(apd AP_INVOICE_DISTRIBUTIONS_U1) */ 'X'
                  from ap_invoice_distributions_all apd
                  where apd.invoice_id = api.invoice_id
                  and apd.line_type_lookup_code in ( 'ITEM', 'ACCRUAL')
                  and apd.po_distribution_id is null
                  and apd.pa_addition_flag <> 'T'
                  group by apd.dist_code_combination_id
                  HAVING sum(apd.amount) <> 0)
    AND   nvl(pov.hold_unmatched_invoices_flag, 'X') = 'Y'
    AND   api.invoice_type_lookup_code not in ('PREPAYMENT', 'INTEREST')
    AND   api.vendor_site_id = pov.vendor_site_id
    AND   api.invoice_id = p_invoice_id;

  l_po_required_exists     VARCHAR2(1)  := 'N';
  l_test_var               VARCHAR2(30) :='';
  l_debug_loc              VARCHAR2(30) := 'Check_PO_Required';
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_info             VARCHAR2(1000);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  OPEN PO_Required_Cur;
  FETCH PO_Required_Cur INTO l_test_var;
  CLOSE PO_Required_Cur;

  IF ( l_test_var is not NULL ) THEN
    l_po_required_exists := 'Y';

    ---------------------------------------------------
    l_debug_info := 'PO REQUIRED hold placed. Invoice_ID: '||p_invoice_id;
    --  Print_Debug(l_debug_loc, l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;
    ---------------------------------------------------
  END IF;

  Process_Inv_Hold_Status(
      p_invoice_id,
      null,
      null,
      'PO REQUIRED',
      l_po_required_exists,
      null,
      p_system_user,
      p_holds,
      p_holds_count,
      p_release_count,
      l_curr_calling_sequence);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    IF ( PO_Required_Cur%ISOPEN ) THEN
      CLOSE PO_Required_Cur;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_PO_Required;

/*=============================================================================
 |  PROCEDURE CHECK_NO_RATE
 |      Procedure that checks if an invoice is a foreign invoice,  missing an
 |      exchange rate and places or releases the NO RATE' hold depending on
 |      the condition.
 |
 |  PARAMETER
 |      p_invoice_id
 |      p_base_currency_code
 |      p_system_user
 |      p_holds
 |      p_holds_count
 |      p_release_count
 |      p_calling_sequence
 |
 |  PROGRAM FLOW
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 ============================================================================*/
PROCEDURE Check_No_Rate(
              p_invoice_id          IN            NUMBER,
              p_base_currency_code  IN            VARCHAR2,
              p_system_user         IN            NUMBER,
              p_holds               IN OUT NOCOPY HOLDSARRAY,
              p_holds_count         IN OUT NOCOPY COUNTARRAY,
              p_release_count       IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence    IN            VARCHAR2) IS

  CURSOR No_Rate_Cur IS
    SELECT 'Foreign Invoice without exchange rate'
    FROM   ap_invoices I
    WHERE  I.invoice_id = p_invoice_id
    AND    I.invoice_currency_code <> p_base_currency_code
    AND    I.exchange_rate is null;

  l_no_rate_exists         VARCHAR2(1)  := 'N';
  l_test_var               VARCHAR2(50) := '';
  l_debug_loc              VARCHAR2(30) := 'Check_No_Rate';
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_info             VARCHAR2(1000);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  OPEN No_Rate_Cur;
  FETCH No_Rate_Cur INTO l_test_var;
  CLOSE No_Rate_Cur;

  IF ( l_test_var is not NULL ) THEN
    l_no_rate_exists := 'Y';

    ---------------------------------------------------
    l_debug_info := 'NO RATE hold placed. Invoice_ID: '||p_invoice_id;
    --  Print_Debug(l_debug_loc, l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;
    ---------------------------------------------------
  END IF;

  Process_Inv_Hold_Status(
      p_invoice_id,
      null,
      null,
      'NO RATE',
      l_no_rate_exists,
      null,
      p_system_user,
      p_holds,
      p_holds_count,
      p_release_count,
      l_curr_calling_sequence);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Base Currency Code = '|| p_base_currency_code);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;

    IF ( No_Rate_Cur%ISOPEN ) THEN
      CLOSE No_Rate_Cur;
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_No_Rate;

--Bug9296410

/*=============================================================================
 |  PROCEDURE CHECK_PROJECT_COMMITMEMT
 |      Procedure that checks if the project commitments are meeted on
 |      time or not . We will give a call to project API which will return
 |      TRUE if commitmemts are meet , if it returns FLASE will place a .
 |      'PROJECT HOLD '
 |  PARAMETER
 |      p_invoice_id
 |      p_system_user
 |      p_holds
 |      p_holds_count
 |      p_release_count
 |      p_calling_sequence
 |
 |  PROGRAM FLOW
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 ============================================================================*/
PROCEDURE Check_project_commitments(
              p_invoice_id          IN            NUMBER,
              p_system_user         IN            NUMBER,
              p_holds               IN OUT NOCOPY HOLDSARRAY,
              p_holds_count         IN OUT NOCOPY COUNTARRAY,
              p_release_count       IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence    IN            VARCHAR2) IS



  l_proj_comm         VARCHAR2(1) := 'N';
  l_test_var               VARCHAR2(50) := '';
  l_debug_loc              VARCHAR2(50) := 'Check_project_commitments'; --bug9296410
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_info             VARCHAR2(1000);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  -- bug 9468749
  PA_AP_VAL_PKG.validate_unprocessed_ded(p_invoice_id , l_proj_comm );

  l_debug_info := 'Call to Project API return flag '|| l_proj_comm ;
   --  Print_Debug(l_debug_loc, l_debug_info);
   IF g_debug_mode = 'Y' THEN
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
   END IF;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
   END IF;

  IF ( l_proj_comm = 'Y' ) THEN

 ---------------------------------------------------
    l_debug_info := 'PROJECT HOLD placed. Invoice_ID: '|| p_invoice_id;
    --  Print_Debug(l_debug_loc, l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;
    ---------------------------------------------------

    ELSE
    -- if the stubbed code return null for AP.A version we will stamp it as 'N'
    l_proj_comm := nvl(l_proj_comm , 'N');

  END IF;

  Process_Inv_Hold_Status(
      p_invoice_id,
      null,
      null,
      'Project Hold',
      l_proj_comm  ,
      null,
      p_system_user,
      p_holds,
      p_holds_count,
      p_release_count,
      l_curr_calling_sequence);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_project_commitments;


/*=============================================================================
 |  PROCEDURE CHECK_DIST_VARIANCE
 |      Procedure that checks whether an invoice has a DIST VARIANCE condition,
 |      i.e. distribution total does not equal to its invoice line amount and
 |      places or releases the hold depending on the condition.
 |
 |  PARAMETER
 |      p_invoice_id
 |      p_invoice_line_number
 |      p_system_user
 |      p_holds
 |      p_holds_count
 |      p_release_count
 |      p_distribution_variance_exist
 |      p_calling_sequence
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 ============================================================================*/

PROCEDURE Check_Dist_Variance(
              p_invoice_id                  IN            NUMBER,
              p_invoice_line_number         IN            NUMBER,
              p_system_user                 IN            NUMBER,
              p_holds                       IN OUT NOCOPY HOLDSARRAY,
              p_holds_count                 IN OUT NOCOPY COUNTARRAY,
              p_release_count               IN OUT NOCOPY COUNTARRAY,
              p_distribution_variance_exist    OUT NOCOPY BOOLEAN,
              p_calling_sequence            IN            VARCHAR2) IS

  CURSOR Dist_Var_Cur IS
    /* Modified by epajaril to fix bug 6729934 */
    SELECT 'Distribution needs to be verified. '
    FROM   DUAL
    WHERE  EXISTS (
             SELECT 'Dist Total <> Invoice Line Amount'
             FROM   ap_invoice_lines_all AIL, ap_invoice_distributions_all D
             -- WHERE  AIL.invoice_id = D.invoice_id
             WHERE  AIL.invoice_id = D.invoice_id(+)
             AND    AIL.line_number = nvl(p_invoice_line_number, AIL.line_number)  --bug6661773
             AND    AIL.invoice_id = p_invoice_id
             -- AND    AIL.line_number = D.invoice_line_number
             AND    AIL.line_number = D.invoice_line_number(+)
             -- AND    (D.line_type_lookup_code <> 'RETAINAGE'
             AND    (NVL(D.line_type_lookup_code, 'ITEM') <> 'RETAINAGE'
    	           OR (AIL.line_type_lookup_code = 'RETAINAGE RELEASE'
    	           and D.line_type_lookup_code = 'RETAINAGE'))
             AND    (AIL.line_type_lookup_code
			NOT IN ('ITEM', 'RETAINAGE RELEASE')
                      or (AIL.line_type_lookup_code
			  IN ('ITEM', 'RETAINAGE RELEASE')
                     and (D.prepay_distribution_id IS NULL
                         or (D.prepay_distribution_id IS NOT NULL
                             and D.line_type_lookup_code NOT IN ('PREPAY', 'REC_TAX', 'NONREC_TAX')))))
    /*
    AND   (ail.line_type_lookup_code <> 'ITEM'
           OR (d.line_type_lookup_code <> 'PREPAY'
               and d.prepay_tax_parent_id IS  NULL)
           )
    */
    GROUP BY AIL.invoice_id, AIL.line_number, AIL.amount
    HAVING AIL.amount <> nvl(SUM(nvl(D.amount,0)),0));

  l_dist_var_exists        VARCHAR2(1)  := 'N';
  l_debug_loc              VARCHAR2(30) := 'Check_Dist_Variance';
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_info             VARCHAR2(1000);
  l_test_var               VARCHAR2(50);
  l_inv_amount		   AP_INVOICES_ALL.INVOICE_AMOUNT%TYPE;
  l_dist_count		   NUMBER;

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||
                             '<-'||p_calling_sequence;


  l_dist_count := 0;
  l_inv_amount := 0;
  p_distribution_variance_exist := FALSE;

  -- Bug 4539514
  SELECT invoice_amount
  INTO l_inv_amount
  FROM ap_invoices_all ai
  WHERE ai.invoice_id = p_invoice_id;

  SELECT count(*) INTO l_dist_count
  FROM   ap_invoice_distributions_all aid
  WHERE  aid.invoice_id = p_invoice_id
  AND   ((aid.line_type_lookup_code <> 'PREPAY'
          AND   aid.prepay_tax_parent_id IS NULL)
          OR    nvl(invoice_includes_prepay_flag,'N') = 'Y')
  AND rownum =1; --Perf 6759699

  IF (l_dist_count = 0 AND l_inv_amount <> 0) Then
      l_dist_var_exists := 'Y';
      p_distribution_variance_exist := TRUE;

  --------------------------------------------------------
  l_debug_info := 'Distribution Variance Exists 1: '||l_dist_var_exists;
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  --------------------------------------------------------

--  END IF;
  -- Perf 6759699
  -- If the variables  l_dist_var_exists and p_distribution_variance_exists
  -- are set in the above if block then there is no need to open the
  -- cursor Dist_Var_Cur.

else

  OPEN Dist_Var_Cur;
  FETCH Dist_Var_Cur
  INTO l_test_var;

  IF (Dist_Var_Cur%ROWCOUNT > 0) THEN
    l_dist_var_exists := 'Y';
    p_distribution_variance_exist := TRUE;

  --------------------------------------------------------
  l_debug_info := 'Distribution Variance Exists 2: '||l_dist_var_exists;
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  --------------------------------------------------------

  END IF;
  CLOSE Dist_Var_Cur;
end if; -- l_dist_count  Bug 6759699

  Process_Inv_Hold_Status(p_invoice_id,
        null,
        null,
        'DIST VARIANCE',
        l_dist_var_exists,
        null,
        p_system_user,
        p_holds,
        p_holds_count,
        p_release_count,
        l_curr_calling_sequence);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;

    IF ( Dist_Var_Cur%ISOPEN ) THEN
      CLOSE Dist_Var_Cur;
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Dist_Variance;


--Start of 8691645
/*=============================================================================
   -- PROCEDURE CHECK_CCR_VENDOR
============================================================================*/

  PROCEDURE CHECK_CCR_VENDOR(
              P_INVOICE_ID                IN     AP_INVOICES.INVOICE_ID%TYPE,
              P_VENDOR_ID                 IN     AP_INVOICES.VENDOR_ID%TYPE,
              P_VENDOR_SITE_ID            IN     AP_INVOICES.VENDOR_SITE_ID%TYPE,
	      P_REMIT_TO_SUPPLIER_SITE_ID IN     AP_INVOICES.REMIT_TO_SUPPLIER_SITE_ID%TYPE,
              P_SYSTEM_USER               IN     NUMBER,
              P_HOLDS                     IN OUT NOCOPY HOLDSARRAY,
              P_HOLDS_COUNT               IN OUT NOCOPY COUNTARRAY,
              P_RELEASE_COUNT             IN OUT NOCOPY COUNTARRAY,
	      P_VENDOR_SITE_REG_EXPIRED   OUT    NOCOPY VARCHAR2,
              P_CALLING_SEQUENCE          IN     VARCHAR2) IS


  l_out_status  VARCHAR2(6);
  l_vndr_ccr_status varchar2(1);

  l_curr_calling_sequence      VARCHAR2(2000);
  l_debug_info                 VARCHAR2(1000);



 Begin
   l_curr_calling_sequence := 'AP_APPROVAL_PKG.CHECK_CCR_VENDOR <-'||p_calling_sequence;

   l_debug_info := 'Before checking vendor is a CCR registered or not ';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line(FND_FILE.LOG,l_debug_info);
    END IF;

    P_Vendor_Site_Reg_Expired := 'N';

     l_out_status := AP_UTILITIES_PKG.GET_CCR_STATUS(
                                     p_object_id => P_vendor_id,
         	                     p_object_type	=> 'S');


      IF(l_out_status = FND_API.G_TRUE) THEN

           initialize_invoice_holds
		   (p_invoice_id       => p_invoice_id,
		    p_calling_sequence => l_curr_calling_sequence);

	   l_debug_info := 'Vendor is CCR registered';
           IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_file.put_line(FND_FILE.LOG,l_debug_info);
           END IF;

          l_vndr_ccr_status :=  AP_UTILITIES_PKG.GET_CCR_REG_STATUS(p_vendor_site_id);

            l_debug_info := 'l_vndr_ccr_status = '|| l_vndr_ccr_status;
             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line(FND_FILE.LOG,l_debug_info);
             END IF;

               IF(l_vndr_ccr_status <> 'A') THEN
                P_Vendor_Site_Reg_Expired := 'Y';
               ELSE
                P_Vendor_Site_Reg_Expired := 'N';
               END IF;



            IF(nvl(p_remit_to_supplier_site_id,p_vendor_site_id) <> p_vendor_site_id
	        and P_Vendor_Site_Reg_Expired <> 'Y') THEN

		l_vndr_ccr_status :=  AP_UTILITIES_PKG.GET_CCR_REG_STATUS
		                        (p_remit_to_supplier_site_id);

	     l_debug_info := 'l_rmt_vndr_ccr_status = '|| l_vndr_ccr_status;
             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line(FND_FILE.LOG,l_debug_info);
             END IF;

             IF(l_vndr_ccr_status <> 'A') THEN
                P_Vendor_Site_Reg_Expired := 'Y';
             ELSE
                P_Vendor_Site_Reg_Expired := 'N';
             END IF;

           END IF;


	      l_debug_info := 'Calling invoice hold process to
	                       put/release holds on invoice';
             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line(FND_FILE.LOG,l_debug_info);
             END IF;

	       Process_Inv_Hold_Status(
                      p_invoice_id,
                      null,
                      null,
                      'Expired Registration',
                      P_Vendor_Site_Reg_Expired,
                      null,
                      p_system_user,
                      p_holds,
                      p_holds_count,
                      p_release_count,
                      l_curr_calling_sequence);

           END IF;


  EXCEPTION

    WHEN OTHERS then

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                   'Invoice_id  = '|| to_char(p_invoice_id)
                 ||', Vendor_id  = '|| to_char(p_vendor_id)
                 ||', Vendor_site_id = '|| to_char(p_vendor_site_id)
        	 ||', Remit_to_supplier_site_id = '||to_char(p_remit_to_supplier_site_id));

    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
 End CHECK_CCR_VENDOR;

--End of 8691645


/*=============================================================================
 |  PROCEDURE CHECK_LINE_VARIANCE
 |    Procedure that checks whether an invoice has a LINE VARIANCE condition,
 |    i.e. lines total does not equal to invoice amount and places or
 |    releases the hold depending on the condition.
 |
 |  PARAMETER
 |      p_invoice_id
 |      p_system_user
 |      p_holds
 |      p_holds_count
 |      p_release_count
 |      p_line_variance_hold_exist
 |      p_calling_sequence
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 ============================================================================*/

PROCEDURE Check_Line_Variance(
              p_invoice_id                IN            NUMBER,
              p_system_user               IN            NUMBER,
              p_holds                     IN OUT NOCOPY HOLDSARRAY,
              p_holds_count               IN OUT NOCOPY COUNTARRAY,
              p_release_count             IN OUT NOCOPY COUNTARRAY,
              p_line_variance_hold_exist     OUT NOCOPY BOOLEAN,
              p_calling_sequence          IN            VARCHAR2,
	      p_base_currency_code        IN            VARCHAR2) IS    --bug7271262


         CURSOR Line_Var_Cur IS
          SELECT 'Line Total <> Invoice Amount'
          FROM   ap_invoice_lines_all AIL, ap_invoices_all A
          WHERE  AIL.invoice_id = A.invoice_id
          AND    AIL.invoice_id = p_invoice_id
          AND    ((AIL.line_type_lookup_code <> 'TAX'
                   and (AIL.line_type_lookup_code NOT IN ('AWT','PREPAY')
                        or NVL(AIL.invoice_includes_prepay_flag,'N') = 'Y') OR
                  (AIL.line_type_lookup_code = 'TAX'
                  /* bug 5222316 */
                   and (AIL.prepay_invoice_id IS NULL
                        or (AIL.prepay_invoice_id is not null
                            and NVL(AIL.invoice_includes_prepay_flag, 'N') = 'Y')))))
               --    and AIL.prepay_invoice_id IS NULL)))
          GROUP BY A.invoice_id, A.invoice_amount, A.net_of_retainage_flag
          HAVING A.invoice_amount <>
                  nvl(SUM(nvl(AIL.amount,0) + decode(A.net_of_retainage_flag,
                                 'Y', nvl(AIL.retained_amount,0),0)),0);

  l_line_var_exists            VARCHAR2(1)  := 'N';
  l_test_var                   VARCHAR2(50);
  l_debug_loc                  VARCHAR2(30) := 'Check_Line_Variance';
  l_curr_calling_sequence      VARCHAR2(2000);
  l_debug_info                 VARCHAR2(1000);
  l_inv_cur_code               ap_invoices.invoice_currency_code%type;
  l_inv_amount		       ap_invoices_all.invoice_amount%TYPE;
  l_line_count		       number;
  l_org_id		       ap_invoices_all.org_id%TYPE;             --bug 7271262
  l_set_of_books_id            ap_invoices_all.set_of_books_id%TYPE;    --bug 7271262
  l_return_code		       VARCHAR2(100);				--bug 7271262
  l_return_message	       VARCHAR2(1000);				--bug 7271262

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||
                             '<-'||p_calling_sequence;

  p_line_variance_hold_exist := FALSE;
  l_line_count := 0;
  l_inv_amount := 0;

  --Bugfix:4539514, added the below code so that we place
  --LINE VARIANCE hold when the user validates a invoice
  --with no lines in it.

  --Bug 7271262 Added the org_id and set_of_books_id parameters in the below
  --select, to pass as parameters for JAI hook jai_ap_tolerance_pkg.inv_holds_check

  SELECT invoice_amount,org_id,set_of_books_id
  INTO l_inv_amount,l_org_id,l_set_of_books_id
  FROM ap_invoices ai
  WHERE ai.invoice_id = p_invoice_id;

  --Added the below code hook for India Localization as part of bug7271262

  l_debug_info := 'Calling code hook jai_ap_tolerance_pkg.inv_holds_check';

  IF (p_base_currency_code = 'INR') Then
    jai_ap_tolerance_pkg.inv_holds_check(
         p_invoice_id             =>  p_invoice_id,
         p_org_id                 =>  l_org_id,
         p_set_of_books_id        =>  l_set_of_books_id,
         p_invoice_amount         =>  l_inv_amount,
         p_invoice_currency_code  =>  p_base_currency_code,
         p_return_code            =>  l_return_code,
         p_return_message         =>  l_return_message);
   End IF;

 /* End of Bug 7271262 */

  SELECT count(*)
  INTO l_line_count
  FROM   ap_invoice_lines ail
  WHERE  ail.invoice_id = p_invoice_id
  AND   (ail.line_type_lookup_code NOT IN ('PREPAY','AWT')
         OR nvl(invoice_includes_prepay_flag,'N') = 'Y');

  IF (l_line_count = 0 AND l_inv_amount <> 0) Then
    l_line_var_exists := 'Y';
    p_line_variance_hold_exist := TRUE;
  END IF;

  --

  OPEN Line_Var_Cur;
  FETCH Line_Var_Cur
  INTO l_test_var;

  IF ( Line_Var_Cur%ROWCOUNT > 0 ) THEN
    l_line_var_exists := 'Y';
    p_line_variance_hold_exist := TRUE;
  END IF;

  CLOSE Line_Var_Cur;

  --------------------------------------------------------
  l_debug_info := 'Line Variance Exists: '||l_line_var_exists;
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  --------------------------------------------------------

  Process_Inv_Hold_Status(
      p_invoice_id,
      null,
      null,
      'LINE VARIANCE',
      l_line_var_exists,
      null,
      p_system_user,
      p_holds,
      p_holds_count,
      p_release_count,
      l_curr_calling_sequence);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    IF ( Line_Var_Cur%ISOPEN ) THEN
      CLOSE Line_Var_Cur;
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Line_Variance;

/*=============================================================================
 |  PROCEDURE Line_BASE_AMOUNT_CALCULATION
 |
 |  DESCRIPTION
 |      Calculate the functional amount for all the lines which were not
 |      partiallly or fully accounted. Populate the rounding amount for lines
 |
 |  PARAMETERS
 |      p_invoice_id
 |      p_invoice_currency_code
 |      p_base_currency_code
 |      p_exchange_rate
 |      p_need_to_round_flag
 |      p_calling_sequence
 |
 |  PROGRAM FLOW
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

PROCEDURE Line_Base_Amount_Calculation(
              p_invoice_id            IN            NUMBER,
              p_invoice_currency_code IN            VARCHAR2,
              p_base_currency_code    IN            VARCHAR2,
              p_exchange_rate         IN            NUMBER,
              p_need_to_round_flag    IN            VARCHAR2 DEFAULT 'N',
              p_calling_sequence      IN            VARCHAR2) IS

  l_rounded_line_num       ap_invoice_lines.line_number%TYPE;
  l_rounded_amt            NUMBER;
  l_round_amt_exist        BOOLEAN := FALSE;
  l_key_value              NUMBER;

  l_debug_loc              VARCHAR2(30) := 'Line_Base_Amount_Calculation';
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_info             VARCHAR2(100);
  l_debug_context          VARCHAR2(2000);

  l_modified_line_rounding_amt   NUMBER; --6892789
  l_base_amt                     NUMBER; --6892789
  l_round_inv_line_numbers       AP_INVOICES_UTILITY_PKG.inv_line_num_tab_type; --6892789

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||
                             '<-'||p_calling_sequence;

  -----------------------------------------------------
  l_debug_info := 'Update Invoice Lines Base Amount';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  -----------------------------------------------------

  UPDATE AP_INVOICE_LINES AIL
     SET AIL.base_amount = DECODE(p_base_currency_code, p_invoice_currency_code,
                                  NULL,
                                  ap_utilities_pkg.ap_round_currency(
                                      amount * p_exchange_rate,
                                      p_base_currency_code)),
         AIL.last_update_date = SYSDATE,
         AIL.last_updated_by = FND_GLOBAL.user_id,
         AIL.last_update_login = FND_GLOBAL.login_id
  WHERE  AIL.invoice_id = p_invoice_id
  AND    AIL.LINE_TYPE_LOOKUP_CODE <> 'TAX' -- bug 9582952
  -- Bug 6621883
  AND    (EXISTS ( SELECT 'NOT POSTED'
                    FROM ap_invoice_distributions_all D
                   WHERE D.invoice_id = AIL.invoice_id
                     AND D.invoice_line_number = AIL.line_number
                     AND NVL(D.posted_flag, 'N') = 'N' )
          OR NOT EXISTS (SELECT 'DIST DOES NOT EXIST'
                    FROM ap_invoice_distributions_all D1
                   WHERE D1.invoice_id = AIL.invoice_id
                     AND D1.invoice_line_number = AIL.line_number
                     AND AIL.amount IS NOT NULL
                        )
          )
  --Retropricing: Adjustment Correction lines on the PPA should be
  -- excluded. Base amounts on zero amount adjustment lines adjustment
  -- correction lines on the PPA is handled while creating PPA Docs.
  --Bugfix:4625349, modified the AND clause
  AND
  ( line_type_lookup_code <> 'RETROITEM' OR
   (line_type_lookup_code = 'RETROITEM' and
    match_type <> 'ADJUSTMENT_CORRECTION')
  );

  -----------------------------------------------------
  l_debug_info := 'Round Invoice Lines Base Amount';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  -----------------------------------------------------

  IF ( NVL(p_need_to_round_flag, 'N') = 'Y' ) THEN
    --Retropricing: Max of the largest invoice line should exclude
    -- Adjustment Correction lines on the PPA as well as the
    -- Zero Amt Adjustment line on the Original Invoice.
    -- Change needs to be done in apinvutb.pls.

  /* modifying following code as per the bug 6892789 as there is a chance
     that line base amt goes to -ve value (line amount being +ve) so in such
     case, adjust line base amount upto zero and adjust the remaing amount in
     another line having next max amount */

    -- get the lines which can be adjusted
    l_round_amt_exist := AP_INVOICES_UTILITY_PKG.round_base_amts(
                             X_Invoice_Id           => p_invoice_id,
                             X_Reporting_Ledger_Id  => NULL,
                             X_Rounded_Line_Numbers => l_round_inv_line_numbers,
                             X_Rounded_Amt          => l_rounded_amt,
                             X_Debug_Info           => l_debug_info,
                             X_Debug_Context        => l_debug_context,
                             X_Calling_sequence     => l_curr_calling_sequence);

    --adjustment required and there exists line numbers that can be adjusted
    IF ( l_round_amt_exist  AND l_round_inv_line_numbers.count > 0 ) THEN
      -- iterate throgh lines until there is no need to adjust
      for i in 1 .. l_round_inv_line_numbers.count
      loop
        IF l_rounded_amt <> 0 THEN
        -- get the existing base amount for the selected line
          select base_amount
          INTO   l_base_amt
          FROM   AP_INVOICE_LINES
          WHERE  invoice_id = p_invoice_id
          AND    line_number = l_round_inv_line_numbers(i);

         -- get the calculated adjusted base amount and rounding amount
         -- get rounding amount for the next line if required
         l_base_amt := AP_APPROVAL_PKG.get_adjusted_base_amount(
                                p_base_amount => l_base_amt,
                                p_rounding_amt => l_modified_line_rounding_amt,
                                p_next_line_rounding_amt => l_rounded_amt);

         -- update the calculatd base amount, rounding amount
          UPDATE AP_INVOICE_LINES
          SET    base_amount = l_base_amt,
                 rounding_amt = ABS( NVL(l_modified_line_rounding_amt, 0) ),
                 last_update_date = SYSDATE,
                 last_updated_by = FND_GLOBAL.user_id,
                 last_update_login = FND_GLOBAL.login_id
          WHERE  invoice_id = p_invoice_id
          AND    line_number = l_round_inv_line_numbers(i)
          AND    line_type_lookup_code <> 'TAX'; -- bug 9582952
        ELSE--adjustment not required or there are no lines that can be adjusted
         EXIT;
        END IF;
      end loop;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Line_Base_Amount_Calculation;

/*=============================================================================
 |  PROCEDURE Dist_BASE_AMOUNT_CALCULATION
 |
 |  DESCRIPTION
 |      Calculate the functional amount for all the lines and distributions
 |      which were not partiallly or fully accounted. Populate the rounding
 |      amount for lines and distribuitons
 |
 |  PARAMETERS
 |      p_invoice_id
 |      p_invoice_line_number
 |      p_invoice_currency_code
 |      p_base_currency_code
 |      p_invoice_exchange_rate
 |
 |      p_calling_sequence
 |
 |  PROGRAM FLOW
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

PROCEDURE Dist_Base_Amount_Calculation(
              p_invoice_id            IN            NUMBER,
              p_invoice_line_number   IN            NUMBER,
              p_invoice_currency_code IN            VARCHAR2,
              p_base_currency_code    IN            VARCHAR2,
              p_invoice_exchange_rate IN            NUMBER,
              p_need_to_round_flag    IN            VARCHAR2 DEFAULT 'N',
              p_calling_sequence      IN            VARCHAR2) IS


  l_round_amt_exists       BOOLEAN := FALSE;
  l_rounded_amt            NUMBER;
  l_rounded_dist_id        ap_invoice_distributions.INVOICE_DISTRIBUTION_ID%TYPE;
  l_debug_loc              VARCHAR2(30) := 'Dist_Base_Amount_Calculation';
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_info             VARCHAR2(1000);
  l_debug_context          VARCHAR2(2000);

  l_base_amt                   NUMBER; --6892789
  l_modified_dist_rounding_amt NUMBER; --6892789
  l_round_dist_id_list  AP_INVOICE_LINES_PKG.distribution_id_tab_type; --6892789

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||
                             '<-'||p_calling_sequence;

  ------------------------------------------------------
  l_debug_info := 'Update Distribution Base Amounts';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  ------------------------------------------------------

  --Bugfix:4625771
  --Added the AND clause so as to not to overwrite the
  --base_amounts calculated on matched distributions
  --which either have an IPV or ERV or both, during the
  --earlier call to exec_matched_variance_checks.
  UPDATE AP_INVOICE_DISTRIBUTIONS
     SET base_amount = DECODE(p_base_currency_code, p_invoice_currency_code,
                               NULL, ap_utilities_pkg.ap_round_currency(
                                         amount * p_invoice_exchange_rate,
                                         p_base_currency_code)),
         last_update_date = SYSDATE,
         last_updated_by = FND_GLOBAL.user_id,
         last_update_login = FND_GLOBAL.login_id
  WHERE  invoice_id = p_invoice_id
  AND    invoice_line_number = p_invoice_line_number
  AND    NVL(posted_flag,'N') = 'N'
  AND    NVL(reversal_flag, 'N') = 'N' -- Bug 9178329
  --Bugfix:4625771
  AND    related_id IS NULL
  AND    line_type_lookup_code NOT IN ('NONREC_TAX','REC_TAX','TRV','TERV','TIPV'); -- bug 9582952

  ------------------------------------------------------
  l_debug_info := 'Round Distribution Base Amounts';
  Print_Debug(l_debug_loc, l_debug_info);
  ------------------------------------------------------

  IF ( NVL(p_need_to_round_flag, 'N') = 'Y' ) THEN

  /* modifying following code as per the bug 6892789 as there is a chance that
     distribution base amt goes to -ve value (amount being +ve) so in such case,
     adjust dist base amount upto zero and adjust the remaing amount in another
     distribution having next max amount */

    -- get the distributions which can be adjusted
    l_round_amt_exists := AP_INVOICE_LINES_PKG.round_base_amts(
                              x_invoice_id          => p_invoice_id,
                              x_line_number         => p_invoice_line_number,
                              x_reporting_ledger_id => NULL,
                              x_round_dist_id_list  => l_round_dist_id_list,
                              x_rounded_amt         => l_rounded_amt,
                              x_debug_info          => l_debug_info,
                              x_debug_context       => l_debug_context,
                              x_calling_sequence    => l_curr_calling_sequence);

    -- adjustment required and there exists dists that can be adjusted
    IF ( l_round_amt_exists  AND l_round_dist_id_list.count > 0 ) THEN
    -- iterate through dists till there is no need to adjust
      for i in 1 .. l_round_dist_id_list.count
      loop
          IF l_rounded_amt <> 0 THEN

            -- get the existing base amount for the selected distribution
            select base_amount
            INTO   l_base_amt
            FROM   AP_INVOICE_DISTRIBUTIONS
            WHERE  invoice_id = p_invoice_id
            AND    invoice_line_number = p_invoice_line_number
            AND    invoice_distribution_id = l_round_dist_id_list(i);

            -- get the calculated adjusted base amount and rounding amount
            -- get rounding amount for the next dist, if required
            l_base_amt := AP_APPROVAL_PKG.get_adjusted_base_amount(
                                 p_base_amount => l_base_amt,
                                 p_rounding_amt => l_modified_dist_rounding_amt,
                                 p_next_line_rounding_amt => l_rounded_amt);

            -- update the calculatd base amount, rounding amount
            UPDATE AP_INVOICE_DISTRIBUTIONS
            SET    base_amount = l_base_amt,
            rounding_amt = ABS( l_modified_dist_rounding_amt ),
            last_update_date = SYSDATE,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id
            WHERE  invoice_distribution_id = l_round_dist_id_list(i)
            AND    line_type_lookup_code NOT IN ('NONREC_TAX','REC_TAX','TRV','TERV','TIPV'); -- bug 9582952

          ELSE
          --adjustment not required or there are no dists that can be adjusted
              EXIT;
          END IF;
     end loop;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Dist_Base_Amount_Calculation;

/*=============================================================================
 |  PROCEDURE GENERATE_ACCOUNT_EVENT
 |
 |  DESCRIPTION:
 |             Generate Accounting Event
 |
 |  PARAMETERS
 |    p_invoice_id
 |    p_calling_sequence
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |      Events Project 5
 |      Before creating new events, we need to check if there are any
 |      events which have been created with the status 'INCOMPLETE'. If
 |      there are, and the holds have now been removed, we may want to
 |      change the status from 'INCOMPLETE' to 'CREATED' rather than
 |      creating a new event.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

PROCEDURE Generate_Account_Event(
              p_invoice_id            IN            NUMBER,
              p_calling_sequence      IN            VARCHAR2) IS

  l_accounting_event_id         NUMBER;       -- Events Project - 1
  l_null_event_id               NUMBER;       -- Events Project - 4
  l_null_event_id_self              NUMBER;   -- Bug 7421528

  l_debug_loc             VARCHAR2(30) := 'Generate_Account_Event';
  l_curr_calling_sequence VARCHAR2(2000);
  l_debug_info            VARCHAR2(1000);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  -------------------------------------------------
  l_debug_info := 'Accounting Event Generation';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  -------------------------------------------------

  SELECT count(*)
    INTO l_null_event_id
    FROM ap_invoice_distributions aid
   WHERE aid.invoice_id = P_invoice_id
     AND aid.accounting_event_id is NULL;

      if(l_null_event_id = 0) then

     SELECT count(*)
    INTO l_null_event_id_self
    FROM ap_self_assessed_tax_dist_all ast
   WHERE ast.invoice_id = P_invoice_id
     AND ast.accounting_event_id is NULL
     AND rownum = 1;

     end if ;


  AP_ACCOUNTING_EVENTS_PKG.Update_Invoice_Events_Status(
		   p_invoice_id		=> p_invoice_id,
	           p_calling_sequence	=> l_curr_calling_sequence);

 -- IF l_null_event_id > 0 then

  --Bug7421528     Added an extra checking

  IF (l_null_event_id > 0  or l_null_event_id_self > 0) then

    -------------------------------------------------
    l_debug_info := 'Accounting Event - create event for null event rows';
    --  Print_Debug(l_debug_loc, l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;
    -------------------------------------------------

    AP_Accounting_Events_Pkg.Create_Events(
            p_event_type	  => 'INVOICES',
	    p_doc_type		  => NULL,
            p_doc_id		  => p_invoice_id,
            p_accounting_date	  => NULL,
            p_accounting_event_id => l_accounting_event_id,
            p_checkrun_name	  => NULL,
            p_calling_sequence	  => l_curr_calling_sequence);

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Generate_Account_Event;

/*=============================================================================
 |  PROCEDURE CHECK_PREPAID_AMOUNT
 |      Procedure that checks whether the invoice amount is more than
 |      the prepaid amount
 |
 |  PARAMETERS
 |      p_invoice_id
 |      p_system_user
 |      p_holds
 |      p_holds_count
 |      p_release_count
 |      p_calling_sequence
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

PROCEDURE Check_Prepaid_Amount(
              p_invoice_id              IN            NUMBER,
              p_system_user             IN            NUMBER,
              p_holds                   IN OUT NOCOPY HOLDSARRAY,
              p_holds_count             IN OUT NOCOPY COUNTARRAY,
              p_release_count           IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence        IN            VARCHAR2) IS

  -- This select modified to use the lines table instead of distributions
  -- to get the prepaid_amount, only if the prepayments are not included
  -- in the invoice.  The prepaid amount will include taxes.

  -- Bug 8260168

  CURSOR Prepay_Var_Cur IS
  SELECT AI.invoice_amount +
          (SELECT SUM(nvl(ail1.amount,0))
             FROM ap_invoice_lines_all ail1
            WHERE ail1.invoice_id=ai.invoice_id
              AND ail1.line_type_lookup_code ='AWT')
         ,nvl(AI.amount_paid,0)
         , (0 - sum(nvl(AIL.amount,0)))  -- taking the remaining amount to be paid on  as part of bug 8339454
    FROM ap_invoices_all AI, ap_invoice_lines_all AIL
   WHERE AI.invoice_id = p_invoice_id
     AND AIL.invoice_id = AI.invoice_id
     --AND AIL.invoice_includes_prepay_flag = 'N'   --commented as part of bug 8339454 we should not diffrentiate in placing the hold as whether the invoice includes prepay or not
     AND AIL.line_type_lookup_code IN ('PREPAY', 'TAX')
     AND AIL.prepay_invoice_id IS NOT NULL
     AND AIL.prepay_line_number IS NOT NULL
   GROUP BY AI.invoice_id, AI.invoice_amount,AI.amount_paid
   Having sum(nvl(AIL.amount,0)) <>0; --Bug5724818

  l_invoice_amount              NUMBER;
  l_prepaid_amount              NUMBER;
  l_paid_amount                 NUMBER; --added as part of bug 833945 to check paid amount
  l_prepay_var_exists           VARCHAR2(1) := 'N';
  l_debug_loc                   VARCHAR2(30) := 'Check_Prepaid_Amount';
  l_debug_info                  VARCHAR2(1000);
  l_curr_calling_sequence       VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||
                             '<-'||p_calling_sequence;

  OPEN Prepay_Var_Cur;
  LOOP
    FETCH Prepay_Var_Cur
     INTO l_invoice_amount, l_prepaid_amount,l_paid_amount ;

    EXIT WHEN Prepay_Var_Cur%NOTFOUND;

    IF l_invoice_amount < l_prepaid_amount THEN
       l_prepay_var_exists := 'Y';

       -------------------------------------------------
       l_debug_info := 'PREPAY VARIANCE hold placed';
       --  Print_Debug(l_debug_loc, l_debug_info);
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
       END IF;
       -------------------------------------------------
    END IF;
   IF l_invoice_amount < l_paid_amount  THEN -- added as part of bug 833945 to check paid amount should not be greater than invoice amount
       l_prepay_var_exists := 'Y';

       -------------------------------------------------
       l_debug_info := 'PREPAY VARIANCE hold placed';
       --  Print_Debug(l_debug_loc, l_debug_info);
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
       END IF;
       -------------------------------------------------
    END IF;  -- end  of bug 833945
  END LOOP;
  CLOSE Prepay_Var_Cur;

  Process_Inv_Hold_Status(
      p_invoice_id,
      null,
      null,
      'PREPAID AMOUNT',
      l_prepay_var_exists,
      null,
      p_system_user,
      p_holds,
      p_holds_count,
      p_release_count,
      l_curr_calling_sequence);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Prepaid_Amount;

/*=============================================================================
 |  PROCEDURE CHECK_INVOICE_VENDOR
 |      Procedure that checks if an invoice has any of the following
 |      1. Exceeds the invoice amount limit stated at the vendor site level
 |         and places or releases the AMOUNT' hold
 |      2. The vendor site has set to hold future payments and places or
 |         release the 'VENDOR' hold
 |
 |  PARAMETERS
 |      p_invoice_id
 |      p_base_currency_code
 |      p_invoice_amount
 |      p_base_amount
 |      p_invoice_currency_code
 |      p_invoice_amount_limit
 |      p_hold_future_payments_flag
 |      p_system_user
 |      p_holds
 |      p_holds_count
 |      p_release_count
 |      p_calling_sequence
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

PROCEDURE Check_invoice_vendor(
              p_invoice_id                IN            NUMBER,
              p_base_currency_code        IN            VARCHAR2,
              p_invoice_amount            IN            NUMBER,
              p_base_amount               IN            NUMBER,
              p_invoice_currency_code     IN            VARCHAR2,
              p_invoice_amount_limit      IN            NUMBER,
              p_hold_future_payments_flag IN            VARCHAR2,
              p_system_user               IN            NUMBER,
              p_holds                     IN OUT NOCOPY HOLDSARRAY,
              p_holds_count               IN OUT NOCOPY COUNTARRAY,
              p_release_count             IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence          IN            VARCHAR2) IS

  l_amount_hold_required        VARCHAR2(1)  := 'N';
  l_debug_loc                   VARCHAR2(30) := 'Check_invoice_vendor';
  l_curr_calling_sequence       VARCHAR2(2000);
  l_debug_info                  VARCHAR2(1000);

BEGIN


  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||
                              '<-'||p_calling_sequence;
   /*-----------------------------------------------------------------+
    |  Check invoice amount limit                                     |
    +-----------------------------------------------------------------*/

  IF (p_invoice_amount_limit is not null) THEN

    IF ((p_invoice_currency_code = p_base_currency_code and
         p_invoice_amount > p_invoice_amount_limit) or
        (p_invoice_currency_code <> p_base_currency_code and
         p_base_amount > p_invoice_amount_limit)) THEN
      l_amount_hold_required := 'Y';
    ELSE
      l_amount_hold_required := 'N';
    END IF;
  END IF;

  -------------------------------------------------------
  l_debug_info := 'AMOUNT hold placed: '||l_amount_hold_required;
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  -------------------------------------------------------

  Process_Inv_Hold_Status(
      p_invoice_id,
      null,
      null,
      'AMOUNT',
      l_amount_hold_required,
      null,
      p_system_user,
      p_holds,
      p_holds_count,
      p_release_count,
      l_curr_calling_sequence);

  -------------------------------------------------------
  l_debug_info := 'Check_invoice_vendor - check hold future payment';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  -------------------------------------------------------

  Process_Inv_Hold_Status(
      p_invoice_id,
      null,
      null,
      'VENDOR',
      p_hold_future_payments_flag,
      null,
      p_system_user,
      p_holds,
      p_holds_count,
      p_release_count,
      l_curr_calling_sequence);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Base Currency Code = '|| p_base_currency_code
              ||', Invoice Currency Code = '|| p_invoice_currency_code
              ||', Invoice Amount = '|| to_char(p_invoice_amount)
              ||', Base Amount = '|| to_char(p_base_amount)
              ||', Invoice Amount Limit = '|| to_char(p_invoice_amount_limit)
              ||', Hold Future Payments Flag = '|| p_hold_future_payments_flag);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Check_invoice_vendor;


/*=============================================================================
 |  PROCEDURE Check_Manual_AWT_Segments
 |      Procedure that checks AWT Account segments
 |
 |
 |  PARAMETERS
 |      p_invoice_id
 |      p_system_user
 |      p_holds
 |      p_holds_count
 |      p_release_count
 |      p_calling_sequence
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |      FOR NON-AWT LINES
 |      1. Excluding the tax line on the prepayment from the distributions
 |      2. Including the Prepayment and Prepayment Tax if
 |         invoice_includes_prepay_flag = 'Y'
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

PROCEDURE Check_Manual_AWT_Segments(
              p_invoice_id       IN            NUMBER,
              p_system_user      IN            NUMBER,
              p_holds            IN OUT NOCOPY HOLDSARRAY,
              p_holds_count      IN OUT NOCOPY COUNTARRAY,
              p_release_count    IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence IN            VARCHAR2) IS

  CURSOR c_manual_awt_dist_segs is
  SELECT ap_utilities_pkg.get_auto_offsets_segments(
                              aid.dist_code_combination_id)
  FROM   ap_invoice_distributions aid
  WHERE  aid.invoice_id = p_invoice_id
  AND    aid.line_type_lookup_code = 'AWT'
  AND    aid.awt_flag = 'M';

  -- eTax Uptake.  This select modified to use the
  -- prepay_distribution_id column to determine if a distribution
  -- is not created by a prepayment application
  -- and include the lines table to know if the prepayment was included
  -- in the invoice
  CURSOR c_non_awt_dists_segs is
  SELECT ap_utilities_pkg.get_auto_offsets_segments(
                               aid.dist_code_combination_id)
  FROM   ap_invoice_distributions_all aid, ap_invoice_lines_all ail
  WHERE  ail.invoice_id = p_invoice_id
  AND    ail.invoice_id = aid.invoice_id
  AND    ail.line_number = aid.invoice_line_number
  AND    ((aid.line_type_lookup_code not in ('AWT','PREPAY')
         AND    aid.prepay_distribution_id IS NULL)
         OR     NVL(ail.invoice_includes_prepay_flag,'N') = 'Y');


  l_manual_awt_dist_segs       VARCHAR2(100);
  l_non_awt_dist_segs          VARCHAR2(100);
  p_dist_segs_hold_required    VARCHAR2(1);
  l_curr_calling_sequence      VARCHAR2(2000);
  l_debug_info                 VARCHAR2(1000);


BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.Check_Manual_AWT_Segments'||'<-'
                             ||p_calling_sequence;

    OPEN c_manual_awt_dist_segs;
    LOOP
      FETCH c_manual_awt_dist_segs into l_manual_awt_dist_segs;
      EXIT WHEN c_manual_awt_dist_segs%NOTFOUND ;
        OPEN c_non_awt_dists_segs;
        LOOP
          FETCH c_non_awt_dists_segs into l_non_awt_dist_segs;
          EXIT  WHEN c_non_awt_dists_segs%NOTFOUND ;

            IF ( l_non_awt_dist_segs = l_manual_awt_dist_segs ) THEN
              p_dist_segs_hold_required := 'N' ;
              EXIT;
            ELSE
              p_dist_segs_hold_required := 'Y';
            END IF;
        END LOOP;
        CLOSE c_non_awt_dists_segs;
    END LOOP;
    CLOSE c_manual_awt_dist_segs;

    /*-----------------------------------------------------------------+
    |  Process Invoice Hold FUTURE PERIOD                              |
    +-----------------------------------------------------------------*/

    Process_Inv_Hold_Status(
        p_invoice_id,
        null,
        null,
        'AWT ACCT INVALID',
        p_dist_segs_hold_required,
        null,
        p_system_user,
        p_holds,
        p_holds_count,
        p_release_count,
        l_curr_calling_sequence);

END Check_Manual_AWT_Segments;

/*=============================================================================
 |  PROCEDURE GET_INV_MATCHED_STATUS
 |      Function given an invoice_id returns TRUE ifthe invoice has any matched
 |      distribution lines, otherwise FALSE
 |
 |  PARAMETERS
 |      p_invoice_id
 |      p_calling_sequence
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

FUNCTION Get_Inv_Matched_Status(
             p_invoice_id        IN            NUMBER,
             p_calling_sequence  IN            VARCHAR2) RETURN BOOLEAN
IS

  l_matched_count          NUMBER;
  l_debug_loc              VARCHAR2(30) := 'Get_Inv_Matched_Status';
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_info             VARCHAR2(1000);

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  SELECT count(*)
  INTO   l_matched_count
  FROM   ap_invoice_distributions
  WHERE  invoice_id = p_invoice_id
  AND    po_distribution_id is not null
  AND    line_type_lookup_code in ( 'ITEM', 'ACCRUAL', 'IPV');

  IF (l_matched_count > 0) THEN
    return(TRUE);
  ELSE
    return(FALSE);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return(FALSE);
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Get_Inv_Matched_Status;


/* ============================================================================
 | WITHHOLD_TAX_ON:
 |
 | Procedure that calls the withholding tax package on an invoice and checks
 | for any errors.  Depending on whether an error exists or not, a hold gets
 | placed or released.
 |
 | Parameters:
 |
 |    p_invoice_id             : Invoice Id
 |    p_gl_date_from_receipt   : GL Date From Receipt Flag system option
 |    p_last_updated_by        : Column Who Info
 |    p_last_update_login      : Column Who Info
 |    p_program_application_id : Column Who Info
 |    p_program_id             : Column Who Info
 |    p_request_id             : Column Who Info
 |    p_system_user            : Approval Program User Id
 |    p_holds                  : Hold Array
 |    p_holds_count            : Holds Count Array
 |    p_release_count          : Release Count Array
 |    p_calling_sequence       : Debugging string to indicate path of module
 |                               calls to be printed out upon error.
 |
 | Program Flow:
 | -------------
 |
 | Check if okay to call Withholding Routine
 |   invoice has at lease on distribution with a withholding tax group
 |   invoice has not already been withheld by the system
 |   invoice has no user non-releaseable holds (ther than AWT ERROR)
 |   invoice has no manual withholding lines
 | IF okay then call AP_DO_WITHHOLDING package on the invoice
 | Depending on whether withholding is successful or not, place or
 | or release the 'AWT ERROR' with the new error reason.
 | (If the invoice already has the hold we want to release the old one and
 |  replace the hold with the new error reason)
 |============================================================================ */

PROCEDURE Withhold_Tax_On(
          p_invoice_id               IN NUMBER,
          p_gl_date_from_receipt     IN VARCHAR2,
          p_last_updated_by          IN NUMBER,
          p_last_update_login        IN NUMBER,
          p_program_application_id   IN NUMBER,
          p_program_id               IN NUMBER,
          p_request_id               IN NUMBER,
          p_system_user              IN NUMBER,
          p_holds                    IN OUT NOCOPY HOLDSARRAY,
          p_holds_count	             IN OUT NOCOPY COUNTARRAY,
          p_release_count            IN OUT NOCOPY COUNTARRAY,
          p_calling_sequence         IN VARCHAR2)
IS
  l_ok_to_withhold	  	VARCHAR2(30);
  l_withholding_amount		NUMBER;
  l_withholding_date		DATE;
  l_invoice_num			VARCHAR2(50);
  l_return_string		VARCHAR2(2000);
  l_withhold_error_exists       VARCHAR2(1);
  l_debug_loc	 		VARCHAR2(30) := 'Withhold_Tax_On';
  l_curr_calling_sequence	VARCHAR2(2000);
  l_debug_info			VARCHAR2(1000);
  l_calling_sequence            VARCHAR2(20);
  l_withhold_date_basis         VARCHAR2(20);  -- bug 9293773

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||p_calling_sequence;

  l_withhold_error_exists := 'N';

  ----------------------------------------------------
  -- Execute Core Withholding Tax Calculation Routine
  ----------------------------------------------------

  IF (NOT Ap_Extended_Withholding_Pkg.Ap_Extended_Withholding_Active) THEN
     BEGIN
       ------------------------------------------------------------------------
       l_debug_info := 'Check if okay to call Withholding Routine - Core';
       ------------------------------------------------------------------------
       -- invoice has at least one distribution with a withholding tax group --
       -- invoice has not already been withheld by the system                --
       -- invoice has no user non-releaseable holds (ther than AWT ERROR)    --
       -- invoice has no manual withholding lines                            --
       ------------------------------------------------------------------------
       -- Perf bug 5058995
       -- Modify below SQL to go to base tables : AP_INVOICES_ALL and
       -- AP_INVOICE_DISTRIBUTIONS_ALL
       SELECT 'OK to call Withholding Routine',
              (AI.invoice_amount * NVL(AI.exchange_rate, 1)),
              AI.invoice_num
         INTO l_ok_to_withhold,
              l_withholding_amount,
              l_invoice_num
         FROM ap_invoices_all AI
        WHERE AI.invoice_id = p_invoice_id
          AND EXISTS (SELECT 'At least 1 dist has an AWT Group'
                       FROM  ap_invoice_distributions_all AID1
                       WHERE  AID1.invoice_id    = AI.invoice_id
                         AND  AID1.awt_group_id  IS NOT NULL)
          AND NOT EXISTS (SELECT 'Unreleased System holds exist'
                            FROM  ap_holds AH,
                                  ap_hold_codes AHC
                           WHERE  AH.invoice_id             = AI.invoice_id
                             AND  AH.release_lookup_code    IS NULL
                             AND  AH.hold_lookup_code       <> 'AWT ERROR'
                             AND  AH.hold_lookup_code       = AHC.hold_lookup_code
                             AND  AHC.user_releaseable_flag = 'N')
          AND NOT EXISTS (SELECT 'Manual AWT lines exist'
                           FROM  ap_invoice_distributions_all AID
                           WHERE  AID.invoice_id            = AI.invoice_id
                             AND  AID.line_type_lookup_code = 'AWT'
                             AND  AID.awt_flag              IN ('M', 'O'));

/*       SELECT  MAX(accounting_date)
         INTO  l_withholding_date
         FROM  ap_invoice_distributions
        WHERE  invoice_id   = p_invoice_id
          AND  awt_group_id IS NOT NULL;   */
/* 5886500 */
--bug 9293773
        SELECT nvl(asp.withholding_date_basis,'INVOICEDATE')
	  INTO l_withhold_date_basis
	  FROM ap_system_parameters_all asp,
	       ap_invoices_all ai
	 WHERE ai.invoice_id = p_invoice_id
	   AND ai.org_id = asp.org_id;

        IF l_withhold_date_basis = 'INVOICEDATE' THEN
         SELECT invoice_date
           INTO l_withholding_date
           FROM ap_invoices
          WHERE invoice_id = p_invoice_id;
	ELSE
         SELECT gl_date
           INTO l_withholding_date
           FROM ap_invoices
          WHERE invoice_id = p_invoice_id;
	END IF;
--bug 9293773

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RETURN;
     END;

     --------------------------------------------------
     l_debug_info := 'Call the Withholding API - Core';
     --------------------------------------------------

     AP_WITHHOLDING_PKG.AP_DO_WITHHOLDING(
          p_invoice_id,
          l_withholding_date,
          'AUTOAPPROVAL',
          l_withholding_amount,
          NULL,
          NULL,
          p_last_updated_by,
          p_last_update_login,
          p_program_application_id,
          p_program_id,
          p_request_id,
          l_return_string);
  ELSE

    ---------------------------------------------------------
    -- Execute Extended Withholding Tax Calculation Routine
    ---------------------------------------------------------

    BEGIN
      ------------------------------------------------------------------------
      l_debug_info := 'Check if okay to call Withholding Routine - Extended';
      ------------------------------------------------------------------------
      -- invoice has at least one distribution with a withholding tax group --
      -- invoice has not already been withheld by the system                --
      -- invoice has no user non-releaseable holds (ther than AWT ERROR)    --
      -- invoice has no manual withholding lines                            --
      ------------------------------------------------------------------------

      -- Perf bug 5058995
      -- Modify below SQL to go to base tables : AP_INVOICES_ALL and
      -- AP_INVOICE_DISTRIBUTIONS_ALL
      SELECT 'OK to call Withholding Routine',
             (AI.invoice_amount * NVL(AI.exchange_rate,1)),
             AI.invoice_num
        INTO l_ok_to_withhold,
             l_withholding_amount,
             l_invoice_num
        FROM ap_invoices_all AI
       WHERE AI.invoice_id = p_invoice_id
         AND NOT EXISTS (SELECT 'Unreleased System holds exist'
                           FROM  ap_holds AH,
                                 ap_hold_codes AHC
                          WHERE  AH.invoice_id                = AI.invoice_id
                            AND  AH.release_lookup_code       IS NULL
                            AND  AH.hold_lookup_code          <> 'AWT ERROR'
                            AND  AH.hold_lookup_code          = AHC.hold_lookup_code
                            AND  AHC.user_releaseable_flag    = 'N')
         AND    NOT EXISTS (SELECT 'Manual AWT lines exist'
                              FROM  ap_invoice_distributions_all AID
                             WHERE  AID.invoice_id            = AI.invoice_id
                               AND  AID.line_type_lookup_code = 'AWT'
                               AND  AID.awt_flag              IN ('M', 'O'));

      SELECT  MAX(accounting_date)
        INTO  l_withholding_date
        FROM  ap_invoice_distributions
       WHERE  invoice_id = p_invoice_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN;
    END;

    ------------------------------------------------------
    l_debug_info := 'Call the Withholding API - Extended';
    ------------------------------------------------------

    IF INSTR(p_calling_sequence, 'AP_CANCEL_PKG') > 0 THEN
        l_calling_sequence := 'INVOICE CANCEL';
    ELSE
        l_calling_sequence :=  'AUTOAPPROVAL';
    END IF;

    AP_WITHHOLDING_PKG.AP_DO_WITHHOLDING(
          p_invoice_id,
          l_withholding_date,
          l_calling_sequence,
          l_withholding_amount,
          NULL,
          NULL,
          p_last_updated_by,
          p_last_update_login,
          p_program_application_id,
          p_program_id,
          p_request_id,
          l_return_string);

  END IF;

  ----------------------------------------
  l_debug_info := 'Process Return String';
  ----------------------------------------

  IF (l_return_string <> 'SUCCESS') THEN

    l_withhold_error_exists := 'Y';

  END IF;

  -------------------------------------------------------------
  l_debug_info := 'Process Invoice Hold Status for AWT ERROR';
  -------------------------------------------------------------

  Process_Inv_Hold_Status(
          p_invoice_id,
          NULL,
          NULL,
          'AWT ERROR',
          l_withhold_error_exists,
          l_return_string,
          p_system_user,
          p_holds,
          p_holds_count,
          p_release_count,
          p_calling_sequence);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Dist_line_num = '|| p_gl_date_from_receipt
              ||', Packet_id = '|| p_last_updated_by
              ||', Fundscheck mode = '|| p_last_update_login
              ||', Dist_line_num = '|| to_char(p_program_application_id)
              ||', Dist_line_num = '|| to_char(p_program_id)
              ||', Dist_line_num = '|| to_char(p_request_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Withhold_Tax_On;


/*=============================================================================
 |  PROCEDURE UPDATE_INV_DISTS_TO_APPROVED
 |      Procedure that updates the invoice distribution match_status_flag to
 |      'A' if encumbered or has no postable holds or is a reversal line,
 |      otherwise if the invoice has postable holds then the match_status_flag
 |      remains a 'T'.
 |
 |  PARAMETERS
 |      p_invoice_id
 |      p_user_id
 |      p_calling_sequence
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

PROCEDURE Update_Inv_Dists_To_Approved(
              p_invoice_id       IN            NUMBER,
              p_user_id          IN            NUMBER,
              p_calling_sequence IN            VARCHAR2) IS

  l_debug_loc              VARCHAR2(30) := 'Update_Inv_Dists_To_Approved';
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_info             VARCHAR2(1000);

  l_dbi_key_value_list1        ap_dbi_pkg.r_dbi_key_value_arr;
  l_dbi_key_value_list2        ap_dbi_pkg.r_dbi_key_value_arr;

BEGIN


  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                              p_calling_sequence;

  ------------------------------------------------------------
  l_debug_info := 'Set selected dists match_status_flag to tested';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  ------------------------------------------------------------

  UPDATE  ap_invoice_distributions D
  SET     match_status_flag = 'T',
          last_update_date = SYSDATE,
          last_updated_by = p_user_id,
          program_application_id = decode(fnd_global.prog_appl_id,
                                          -1,null,
                                          fnd_global.prog_appl_id),
          request_id = decode(fnd_global.conc_request_id,
                              -1,null, fnd_global.conc_request_id),
          program_id = decode(fnd_global.conc_program_id,
                              -1,null, fnd_global.conc_program_id),
          program_update_date = decode(fnd_global.conc_program_id,
                                       -1,null, SYSDATE)
  WHERE   match_status_flag = 'S'
  AND     D.invoice_id = p_invoice_id;

  --Bug6963908
  UPDATE  ap_self_assessed_tax_dist_all D
  SET     match_status_flag = 'T',
          last_update_date = SYSDATE,
          last_updated_by = p_user_id,
          program_application_id = decode(fnd_global.prog_appl_id,
                                          -1,null,
                                          fnd_global.prog_appl_id),
          request_id = decode(fnd_global.conc_request_id,
                              -1,null, fnd_global.conc_request_id),
          program_id = decode(fnd_global.conc_program_id,
                              -1,null, fnd_global.conc_program_id),
          program_update_date = decode(fnd_global.conc_program_id,
                                       -1,null, SYSDATE)
  WHERE   match_status_flag = 'S'
  AND     D.invoice_id = p_invoice_id;
  --Bug6963908


  AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICE_DISTRIBUTIONS',
               p_operation => 'U',
               p_key_value1 => p_invoice_id,
               p_key_value_list => l_dbi_key_value_list1,
                p_calling_sequence => l_curr_calling_sequence);

  ------------------------------------------------------------
  l_debug_info := 'Set Tested dists to Approved if no unpostable holds';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  ------------------------------------------------------------

  -- BUG 4340061
  -- For the AWT lines we have encumbered_flag set to N in invoice-dist.

  UPDATE  ap_invoice_distributions D
  SET     match_status_flag = 'A',
          packet_id = ''
  WHERE   match_status_flag = 'T'
  AND     D.invoice_id = p_invoice_id
  AND     ((NOT EXISTS
                   (SELECT  invoice_id
                    FROM    ap_holds H, ap_hold_codes C
                    WHERE   H.invoice_id = D.invoice_id
                    AND     H.hold_lookup_code = C.hold_lookup_code
                    AND     ((H.release_lookup_code IS NULL) AND
                             ((C.postable_flag = 'N') OR
                              (C.postable_flag = 'X')))))
	            OR (D.line_type_lookup_code<>'AWT' and
        	        (nvl(D.encumbered_flag, 'N') in ('Y','W','D','X','R','T')))
	            OR (D.line_type_lookup_code='AWT' and
        	        (nvl(D.encumbered_flag, 'N') in ('Y','W','D','X','R'))));    -- BUG 4340061


  --Bug6963908
  UPDATE  ap_self_assessed_tax_dist_all D
  SET     match_status_flag = 'A',
          packet_id = ''
  WHERE   match_status_flag = 'T'
  AND     D.invoice_id = p_invoice_id
  AND     ((NOT EXISTS
                   (SELECT  invoice_id
                    FROM    ap_holds H, ap_hold_codes C
                    WHERE   H.invoice_id = D.invoice_id
                    AND     H.hold_lookup_code = C.hold_lookup_code
                    AND     ((H.release_lookup_code IS NULL) AND
                             ((C.postable_flag = 'N') OR
                              (C.postable_flag = 'X')))))
	            OR (D.line_type_lookup_code<>'AWT' and
        	        (nvl(D.encumbered_flag, 'N') in ('Y','W','D','X','R','T')))
	            OR (D.line_type_lookup_code='AWT' and
        	        (nvl(D.encumbered_flag, 'N') in ('Y','W','D','X','R'))));    -- BUG 4340061
  --Bug6963908

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
         || 'Run Option = ' || p_user_id);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Update_Inv_Dists_To_Approved;

--============================================================================
-- HOLD Processing Routines
--============================================================================

/*=============================================================================
 |  PROCEDURE PROCESS_INV_HOLD_STATUS
 |      Procedure that process and invoice hold status. Determines whether to
 |      place or release a given  hold.
 |
 |  PARAMETERS
 |      p_invoice_id
 |      p_line_location_id:  Line Location Id
 |      p_rcv_tansaction_id: rcv transaction id it is matched to
 |      p_hold_lookup_code:  Hold Lookup Code
 |      p_should_have_hold:  ('Y' or 'N') to indicate whether the invoice
 |                           should have the hold (previous parameter)
 |      p_hold_reason:  AWT ERROR parameter.  The only hold whose hold reason
 |                      is  not static.
 |      p_system_user:  Approval Program User Id
 |      p_holds:  Holds Array
 |      p_holds_count:  Holds Count Array
 |      p_release_count:  Release Count Array
 |      p_calling_sequence: Debugging string to indicate path of module calls
 |                          to be printed out upon error.
 |
 |  PROGRAM FLOW:
 |      Retrieve current hold_status for current hold
 |      IF already_on_hold
 |       IF shoould_not_have_hold OR if p_hold_reason is different from the
 |          exists hold reason
 |        Release the hold
 |       ELSIF should_have_hold and hold_status <> Released By User
 |         IF p_hold_reason is null or existing_hold_reason id different from
 |           p_hold_reason
 |        Place the hold on the invoice
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

PROCEDURE Process_Inv_Hold_Status(
              p_invoice_id          IN            NUMBER,
              p_line_location_id    IN            NUMBER,
              p_rcv_transaction_id  IN            NUMBER,
              p_hold_lookup_code    IN            VARCHAR2,
              p_should_have_hold    IN            VARCHAR2,
              p_hold_reason         IN            VARCHAR2,
              p_system_user         IN            NUMBER,
              p_holds               IN OUT NOCOPY HOLDSARRAY,
              p_holds_count         IN OUT NOCOPY COUNTARRAY,
              p_release_count       IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence    IN            VARCHAR2)IS
  l_inv_hold_status       VARCHAR2(20);
  l_existing_hold_reason  VARCHAR2(240);
  l_user_id               NUMBER;
  l_resp_id               NUMBER;
  l_debug_loc             VARCHAR2(30) := 'Process_Inv_Hold_Status';
  l_curr_calling_sequence VARCHAR2(2000);
  l_debug_info            VARCHAR2(1000);
BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

       l_debug_info := 'p_hold_lookup_code,p_should_have_hold,p_hold_reason,p_system_user '||p_hold_lookup_code||','||p_should_have_hold||','||p_hold_reason||','||p_system_user;
        --  Print_Debug(l_debug_loc, l_debug_info);
        IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
        END IF;


  Get_Hold_Status(
      p_invoice_id,
      p_line_location_id,
      p_rcv_transaction_id,
      p_hold_lookup_code,
      p_system_user,
      l_inv_hold_status,
      l_existing_hold_reason,
      l_user_id,
      l_resp_id,
      l_curr_calling_sequence);

  IF (l_inv_hold_status = 'ALREADY ON HOLD') THEN

    IF (p_should_have_hold = 'N') OR ((p_hold_reason IS NOT NULL) AND
        (l_existing_hold_reason <> p_hold_reason)) THEN

      -------------------------------------------
      l_debug_info := 'Release hold if on hold and should not be on hold';
      --  Print_Debug(l_debug_loc, l_debug_info);
      IF g_debug_mode = 'Y' THEN
         AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
      END IF;
      -------------------------------------------

      IF ( check_hold_batch_releaseable(
             p_hold_lookup_code,
             p_calling_sequence) = 'Y' ) THEN

        Release_Hold(
            p_invoice_id,
            p_line_location_id,
            p_rcv_transaction_id,
            p_hold_lookup_code,
            p_holds,
            p_release_count,
            l_curr_calling_sequence);
      END IF;
    END IF;

  ELSIF ((p_should_have_hold = 'Y') AND
         ((l_inv_hold_status <> 'RELEASED BY USER') OR
          ((p_hold_lookup_code = 'INSUFFICIENT FUNDS') AND
           (l_inv_hold_status <> 'ALREADY ON HOLD')))) THEN

    -------------------------------------------
    l_debug_info := 'Set hold if it is not user released and needs hold';
    --  Print_Debug(l_debug_loc, l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;
    -------------------------------------------

    IF ((p_hold_reason IS NULL) OR
         (nvl(l_existing_hold_reason,'dummy') <> p_hold_reason)) THEN
      IF (p_hold_lookup_code = 'INSUFFICIENT FUNDS') THEN

        -------------------------------------------
        l_debug_info := 'Erase responsibility id from old insuff funds holds';
        --  Print_Debug(l_debug_loc, l_debug_info);
        IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
        END IF;
        -------------------------------------------

        UPDATE ap_holds
        SET    responsibility_id = NULL
        WHERE  invoice_id = p_invoice_id
        AND    hold_lookup_code = 'INSUFFICIENT FUNDS';

      END IF;

      -------------------------------------------
      l_debug_info := 'Set Hold';
      --  Print_Debug(l_debug_loc, l_debug_info);
      IF g_debug_mode = 'Y' THEN
         AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
      END IF;
      -------------------------------------------

      Set_Hold(
          p_invoice_id,
          p_line_location_id,
          p_rcv_transaction_id,
          p_hold_lookup_code,
          p_hold_reason,
          p_holds,
          p_holds_count,
          l_curr_calling_sequence);

    END IF; -- end of check p_hold_reason
  END IF; -- end of l_inv_hold_status

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Line_Location_id = '|| to_char(p_line_location_id)
              ||', Hold_code = '|| p_hold_lookup_code
              ||', Hold_reason = '|| p_hold_reason
              ||', Should_have_hold = '|| p_should_have_hold);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Process_Inv_Hold_Status;

/*=============================================================================
 |  PROCEDURE GET_HOLD_STATUS
 |      Procedure to return the hold information and status of an invoice,
 |      whether it is ALREADY ON HOLD, RELEASED BY USER or NOT ON HOLD.
 |
 |  PARAMETERS
 |      p_invoice_id
 |      p_line_location_id:  Line Location Id
 |      p_rcv_transaction_id
 |      p_hold_lookup_code
 |      p_system_user
 |      p_status
 |      p_return_hold_reason
 |      p_user_id
 |      p_resp_id
 |      p_calling_sequence: Debugging string to indicate path of module calls
 |                          to be printed out upon error.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/
PROCEDURE Get_Hold_Status(p_invoice_id		IN NUMBER,
			  p_line_location_id	IN NUMBER,
			  p_rcv_transaction_id  IN NUMBER,
			  p_hold_lookup_code	IN VARCHAR2,
			  p_system_user		IN NUMBER,
			  p_status		IN OUT NOCOPY VARCHAR2,
			  p_return_hold_reason  IN OUT NOCOPY VARCHAR2,
			  p_user_id     	IN OUT NOCOPY VARCHAR2,
			  p_resp_id		IN OUT NOCOPY VARCHAR2,
			  p_calling_sequence  	IN VARCHAR2) IS

  l_debug_loc	 		VARCHAR2(30) := 'Get_Hold_Status';
  l_curr_calling_sequence	VARCHAR2(2000);

BEGIN

  -- Update the calling sequence --

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||p_calling_sequence;

  p_status := 'NOT ON HOLD';

  if g_holds_tab.count > 0 then

     for i in g_holds_tab.first..g_holds_tab.last
     loop
        if (p_hold_lookup_code <> 'INSUFFICIENT FUNDS') then

	    if (g_holds_tab(i).invoice_id = p_invoice_id and
	        g_holds_tab(i).hold_lookup_code = p_hold_lookup_code) then

	        if (p_line_location_id is null
	            or g_holds_tab(i).line_location_id = p_line_location_id) and
	           (p_rcv_transaction_id is null
	            or g_holds_tab(i).rcv_transaction_id = p_rcv_transaction_id) and
	           (g_holds_tab(i).release_lookup_code is null
	            or (g_holds_tab(i).release_lookup_code is not null
	                and g_holds_tab(i).last_updated_by <> p_system_user)) then

                   p_status		:= g_holds_tab(i).hold_status;
                   p_return_hold_reason := g_holds_tab(i).hold_reason;
                   p_user_id            := g_holds_tab(i).last_updated_by;
                   p_resp_id            := g_holds_tab(i).responsibility_id;

                end if;
	    end if;
	else
	    if (g_holds_tab(i).invoice_id = p_invoice_id and
	        g_holds_tab(i).hold_lookup_code = p_hold_lookup_code) then

	        if (p_line_location_id is null
	            or g_holds_tab(i).line_location_id = p_line_location_id) and
	           (g_holds_tab(i).release_lookup_code is null
	            or (g_holds_tab(i).release_lookup_code is not null
	                and g_holds_tab(i).last_updated_by <> p_system_user
	                and g_holds_tab(i).responsibility_id is not null)) then

                   p_status		:= g_holds_tab(i).hold_status;
                   p_return_hold_reason := g_holds_tab(i).hold_reason;
                   p_user_id            := g_holds_tab(i).last_updated_by;
                   p_resp_id            := g_holds_tab(i).responsibility_id;

                end if;
	    end if;
        end if;
     end loop;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Line Location Id = '|| to_char(p_line_location_id)
              ||', System_User_id = '|| to_char(p_system_user)
              ||', Hold Code = '|| p_hold_lookup_code);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Get_Hold_Status;


--Start 8691645
/*=============================================================================
 |  PROCEDURE UPDATE_SCHEDULES
 |  This procedure updates/ recreates payment schedules  whenever
 | 'Expired Registration' hold releases for an invoice.
  ============================================================================*/

PROCEDURE UPDATE_SCHEDULES(P_INVOICE_ID       IN AP_INVOICES.INVOICE_ID%TYPE,
                           P_CALLING_SEQUENCE IN VARCHAR2)IS

cursor invoice_cursor is
     select AI.terms_id,
        AI.last_updated_by,
        AI.created_by,
        AI.batch_id,
        AI.terms_date,
        AI.invoice_amount,
        nvl(AI.pay_curr_invoice_amount, invoice_amount),
        AI.payment_cross_rate,
        AI.amount_applicable_to_discount,
        AI.payment_method_code,
        AI.invoice_currency_code,
        AI.payment_currency_code
     from   ap_invoices AI
     where  AI.invoice_id = p_invoice_id;


 l_terms_id                   ap_invoices.terms_id%type;
 l_last_updated_by            ap_invoices.last_updated_by%type;
 l_created_by                 ap_invoices.created_by%type;
 l_batch_id                   ap_invoices.batch_id%type;
 l_terms_date                 ap_invoices.terms_date%type;
 l_invoice_amount             ap_invoices.invoice_amount%type;
 l_pay_curr_invoice_amount    ap_invoices.pay_curr_invoice_amount%type;
 l_payment_cross_rate         ap_invoices.payment_cross_rate%type;
 l_amt_applicable_to_discount ap_invoices.amount_applicable_to_discount%type;
 l_payment_method_code        ap_invoices.payment_method_code%type;
 l_invoice_currency_code      ap_invoices.invoice_currency_code%type;
 l_payment_currency_code      ap_invoices.payment_currency_code%type;

 l_paid_schd_count  NUMBER;
 l_old_terms_date   Date;
 l_current_calling_sequence     VARCHAR2(2000);
 l_debug_info                VARCHAR2(1000);

BEGIN
    l_current_calling_sequence := 'AP_APPROVAL_PKG.UPDATE_SCHEDULES <- '|| p_calling_sequence;

    l_debug_info := 'Begin UPDATE_SCHEDULES procedure';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line(FND_FILE.LOG,l_debug_info);
    END IF;

    select terms_date
    into l_old_terms_date
    from ap_invoices_all
    where invoice_id = p_invoice_id;

    l_debug_info := 'Before updating invoice terms_date';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line(FND_FILE.LOG,l_debug_info);
    END IF;

     Update ap_invoices_all
     set terms_date =trunc(sysdate),
         invoice_received_date = decode(invoice_received_date,null,null,trunc(sysdate)) --bug9148859
      where invoice_id =  p_invoice_id;

      select count(*)
      into l_paid_schd_count
      from ap_payment_schedules_all
      where invoice_id = p_invoice_id
       and nvl(payment_status_flag,'N') <> 'N';


   IF(l_paid_schd_count >0)THEN

    --If Invoice contains paid schedules update terms date on existing
    --schedules.

     l_debug_info := 'Invoice contains paid schedules.';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line(FND_FILE.LOG,l_debug_info);
    END IF;

     Update ap_payment_schedules_all
     set due_date = due_date +(sysdate-l_old_terms_date)
     where invoice_id = p_invoice_id
       and nvl(payment_status_flag,'N') <> 'Y';

    ELSE

     --If Invoice does not have paid schedules recreate payment schedules

      l_debug_info := 'Invoice does not have paid schedules.';
     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line(FND_FILE.LOG,l_debug_info);
     END IF;

     OPEN  invoice_cursor;
     FETCH invoice_cursor
     INTO  l_terms_id,
           l_last_updated_by,
           l_created_by,
           l_batch_id,
           l_terms_date,
           l_invoice_amount,
           l_pay_curr_invoice_amount,
           l_payment_cross_rate,
           l_amt_applicable_to_discount,
           l_payment_method_code,
           l_invoice_currency_code,
           l_payment_currency_code;
     CLOSE invoice_cursor;


      l_debug_info := 'Create the payment schedules';
     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line(FND_FILE.LOG,l_debug_info);
     END IF;

     AP_CREATE_PAY_SCHEDS_PKG.AP_Create_From_Terms(
                p_invoice_id,
                l_terms_id,
                l_last_updated_by,
                l_created_by,
                null,
                l_batch_id,
                l_terms_date,
                l_invoice_amount,
                l_pay_curr_invoice_amount,
                l_payment_cross_rate,
                l_amt_applicable_to_discount,
                l_payment_method_code,
                l_invoice_currency_code,
                l_payment_currency_code,
                l_current_calling_sequence);
     END IF;

   EXCEPTION
   WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME ('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id  = '|| P_INVOICE_ID);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
 END UPDATE_SCHEDULES;

--End 8691645



/*=============================================================================
 |  PROCEDURE RELEASE_HOLD
 |      Procedure to release a hold from an invoice and update the release
 |      count array.
 |
 |  PARAMETERS
 |      p_invoice_id
 |      p_line_location_id:  Line Location Id
 |      p_rcv_transaction_id
 |      p_hold_lookup_code
 |      p_holds
 |      p_release_count
 |      p_calling_sequence: Debugging string to indicate path of module calls
 |                          to be printed out upon error.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

PROCEDURE Release_Hold(
              p_invoice_id          IN            NUMBER,
              p_line_location_id    IN            NUMBER,
              p_rcv_transaction_id  IN            NUMBER,
              p_hold_lookup_code    IN            VARCHAR2,
              p_holds               IN OUT NOCOPY HOLDSARRAY,
              p_release_count       IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence    IN            VARCHAR2) IS
  l_release_lookup_code    VARCHAR2(30);
  l_debug_loc              VARCHAR2(30) := 'Release_Hold';
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_info             VARCHAR2(1000);
  l_old_wf_status  AP_HOLDS_ALL.WF_STATUS%TYPE ;  -- Bug 8323412
  l_hold_id        AP_HOLDS_ALL.HOLD_ID%TYPE   ;  -- Bug 8323412
BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  -------------------------------------------
  l_debug_info := 'Getting Release Info For Hold';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  -------------------------------------------

  Get_Release_Lookup_For_Hold(
      p_hold_lookup_code,
      l_release_lookup_code,
      l_curr_calling_sequence);

  -------------------------------------------
  l_debug_info := 'Updating AP_HOLDS with release info';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  -------------------------------------------
 /* Commented this part to put this is a loop (8494768)
  -- Bug 8323412 begins
  SELECT  wf_status,
          hold_id
  INTO    l_old_wf_status,
          l_hold_id
  FROM    ap_holds
  WHERE   invoice_id = p_invoice_id
  AND     nvl(line_location_id, -1) = nvl(p_line_location_id, -1)
  AND     nvl(rcv_transaction_id, -1) = nvl(rcv_transaction_id, -1)
  AND     hold_lookup_code = p_hold_lookup_code
  AND     nvl(status_flag, 'x') <> 'x';

  IF l_old_wf_status = 'STARTED' THEN
      AP_WORKFLOW_PKG.abort_holds_workflow( l_hold_id ) ;
  END IF ;
  -- Bug 8323412 ends
  */
   FOR c_wf_status IN ( SELECT   hold_id
                         FROM     ap_holds
                         WHERE    invoice_id = p_invoice_id
                         AND      nvl(line_location_id, -1) = nvl(p_line_location_id, -1)
                         AND      nvl(rcv_transaction_id, -1) = nvl(rcv_transaction_id, -1)
                         AND      hold_lookup_code = p_hold_lookup_code
                         AND      nvl(status_flag, 'x') <> 'x'
                         AND      wf_status /* Bug 9691312 = 'STARTED' */ IN ( 'STARTED', 'NEGOTIATE' )
                       )
   LOOP
        AP_WORKFLOW_PKG.abort_holds_workflow( c_wf_status.hold_id ) ;
    END LOOP ;


  UPDATE ap_holds
  SET    release_lookup_code = l_release_lookup_code,
         release_reason = (SELECT description
                             FROM   ap_lookup_codes
                             WHERE  lookup_code = l_release_lookup_code
                               AND    lookup_type = 'HOLD CODE'),
         last_update_date = sysdate,
         last_updated_by = 5,
         status_flag = 'R'
  WHERE invoice_id = p_invoice_id
  AND   nvl(line_location_id, -1) = nvl(p_line_location_id, -1)
  AND   nvl(rcv_transaction_id, -1) = nvl(rcv_transaction_id, -1)
  AND   hold_lookup_code = p_hold_lookup_code
  AND   nvl(status_flag, 'x') <> 'x';

  -------------------------------------------
  l_debug_info := 'Adjust the Release Count';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  -------------------------------------------

  IF (sql%rowcount >0) THEN
      Count_Org_Hold(
		 p_org_id	   => g_org_id
		,p_hold_lookup_code => p_hold_lookup_code
		,p_place_or_release => 'R'
		,p_calling_sequence => l_curr_calling_sequence);

  END IF;

  -------------------------------------------
  l_debug_info := 'Sync Invoice Holds Cache';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  -------------------------------------------

  initialize_invoice_holds
		(p_invoice_id       => p_invoice_id,
		 p_calling_sequence => l_curr_calling_sequence);

  AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_HOLDS',
               p_operation => 'U',
               p_key_value1 => p_invoice_id,
                p_calling_sequence => l_curr_calling_sequence);

  --Start 8691645

   IF(l_release_lookup_code = 'Registration Activated')THEN
     UPDATE_SCHEDULES(p_invoice_id,p_calling_sequence);
   END IF;

 --End 8691645

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Hold_Code = '|| p_hold_lookup_code
              ||', Line Location Id = '|| (p_line_location_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Release_Hold;

/*=============================================================================
 |  PROCEDURE SET_HOLD
 |      Procedure to Set an Invoice on Hold and update the hold count array.
 |
 |  PARAMETERS
 |      p_invoice_id
 |      p_line_location_id:  Line Location Id
 |      p_rcv_transaction_id
 |      p_hold_lookup_code
 |      p_hold_reason
 |      p_holds
 |      p_hold_count
 |      p_calling_sequence: Debugging string to indicate path of module calls
 |                          to be printed out upon error.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

PROCEDURE Set_Hold(
              p_invoice_id          IN            NUMBER,
              p_line_location_id    IN            NUMBER,
              p_rcv_transaction_id  IN            NUMBER,
              p_hold_lookup_code    IN            VARCHAR2,
              p_hold_reason         IN            VARCHAR2,
              p_holds               IN OUT NOCOPY HOLDSARRAY,
              p_holds_count         IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence    IN            VARCHAR2) IS
  l_debug_loc              VARCHAR2(30) := 'Set_Hold';
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_info             VARCHAR2(1000);
  l_hold_id                NUMBER(15);
  l_user_releaseable_flag  VARCHAR2(1);
  l_initiate_workflow_flag VARCHAR2(1);
   l_org_id            		NUMBER(15);  --8691645

BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  -------------------------------------------
  l_debug_info := 'Inserting Into AP_HOLDS';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  -------------------------------------------

  SELECT ap_holds_s.nextval
  INTO   l_hold_id
  FROM   DUAL;

   --Introduced select stmt for 8691645

   select org_id into l_org_id
   from ap_invoices where invoice_id = p_invoice_id;

  INSERT INTO ap_holds (
                  invoice_id,
                  line_location_id,
                  rcv_transaction_id,
                  hold_lookup_code,
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by,
                  held_by,
                  hold_date,
                  hold_reason,
                  status_flag,
		  org_id,  /* Bug 3700128. MOAC Project */
                  hold_id) -- added for Negotiation Project
    (SELECT p_invoice_id,
            p_line_location_id,
            p_rcv_transaction_id,
            p_hold_lookup_code,
            sysdate,
            5,
            sysdate,
            5,
            5,
            sysdate,
            substrb(nvl(p_hold_reason, description),1,240),
            'S',
	     nvl(g_org_id,l_org_id), /* Bug 3700128. MOAC Project */
            l_hold_id -- Added for Negotiation.
     FROM   ap_lookup_codes
     WHERE  lookup_code = p_hold_lookup_code
     AND    lookup_type = 'HOLD CODE');

  --
  -- Added for Negotiation Workflow
  -- The Holds workflow will be initiated if the placed hold is a system
  -- placed user releaseable hold.
  -- Check if the hold placed is a user releaseable hold
  --

  -------------------------------------------
  l_debug_info := 'Select to see if the hold is user releaseable hold';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  -------------------------------------------

  SELECT user_releaseable_flag,
         initiate_workflow_flag
  INTO   l_user_releaseable_flag,
         l_initiate_workflow_flag
  FROM   ap_hold_codes
  WHERE  hold_lookup_code = p_hold_lookup_code;

  --
  -- If the hold is a user releaseable hold then we will start the
  -- holds workflow.
  --

  IF (l_user_releaseable_flag = 'Y' AND
     l_initiate_workflow_flag = 'Y') THEN

     -------------------------------------------
     l_debug_info := 'Start the Holds Workflow';
     --  Print_Debug(l_debug_loc, l_debug_info);
     IF g_debug_mode = 'Y' THEN
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
     END IF;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
     END IF;
     -------------------------------------------

     AP_WORKFLOW_PKG.create_hold_wf_process(l_hold_id);

     -------------------------------------------
     l_debug_info := 'Started the Holds Workflow';
     --  Print_Debug(l_debug_loc, l_debug_info);
     IF g_debug_mode = 'Y' THEN
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
     END IF;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
     END IF;
     -------------------------------------------

  END IF;

  AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_HOLDS',
               p_operation => 'I',
               p_key_value1 => p_invoice_id,
                p_calling_sequence => l_curr_calling_sequence);

  -------------------------------------------
  l_debug_info := 'Adjust the Holds Count';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  -------------------------------------------
  Count_Org_Hold(
         p_org_id           => g_org_id
        ,p_hold_lookup_code => p_hold_lookup_code
        ,p_place_or_release => 'P'
        ,p_calling_sequence => l_curr_calling_sequence);

  -------------------------------------------
  l_debug_info := 'Sync Invoice Holds Cache';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  -------------------------------------------
  initialize_invoice_holds
		(p_invoice_id       => p_invoice_id,
		 p_calling_sequence => l_curr_calling_sequence);


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Hold_Code = '|| p_hold_lookup_code
              ||', Hold_Reason = '|| p_hold_reason);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Set_Hold;

/*=============================================================================
 |  PROCEDURE COUNT_HOLD
 |      Procedure given the hold_array and count_array, increments the
 |      count for a given hold
 |
 |  PARAMETERS
 |      p_hold_lookup_code
 |      p_holds
 |      p_count
 |      p_calling_sequence: Debugging string to indicate path of module calls
 |                          to be printed out upon error.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

PROCEDURE Count_Hold(
              p_hold_lookup_code    IN            VARCHAR2,
              p_holds               IN OUT NOCOPY HOLDSARRAY,
              p_count               IN OUT NOCOPY COUNTARRAY,
              p_calling_sequence    IN            VARCHAR2) IS
  l_num                         NUMBER;
  l_debug_loc                   VARCHAR2(30) := 'Count_Hold';
  l_curr_calling_sequence       VARCHAR2(2000);
  l_debug_info                  VARCHAR2(1000);
BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                              p_calling_sequence;

  FOR num IN 1..100 LOOP

    IF ((p_holds(num) IS NULL) OR (p_holds(num) = p_hold_lookup_code)) THEN

      l_num := to_number(num);

      EXIT;
    END IF;

  END LOOP;

  p_holds(l_num) := p_hold_lookup_code;
  p_count(l_num) := nvl(p_count(l_num), 0) + 1;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Hold Code  = '|| p_hold_lookup_code);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Count_Hold;


/*=============================================================================
 |  PROCEDURE GET_RELEASE_LOOKUP_FOR_HOLD
 |      Procedure given a hold_lookup_code retunrs the associated
 |      return_lookup_code
 |
 |  PARAMETERS
 |      p_hold_lookup_code
 |      p_release_lookup_code
 |      p_calling_sequence: Debugging string to indicate path of module calls
 |                          to be printed out upon error.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

PROCEDURE Get_Release_Lookup_For_Hold(
              p_hold_lookup_code       IN            VARCHAR2,
              p_release_lookup_code    IN OUT NOCOPY VARCHAR2,
              p_calling_sequence       IN            VARCHAR2) IS

  l_debug_loc              VARCHAR2(30) := 'Get_Release_Lookup_For_Hold';
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_info             VARCHAR2(1000);
  invalid_hold             EXCEPTION;
BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  -------------------------------------------
  l_debug_info := 'Check hold_code to retrieve release code';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  -------------------------------------------


--added the lookup code MILESTONE in the if statement to
--release the MILESTONE hold when PO quantity or amount
--matched properly and invoice validated or when HOLD released manually
--as per bug6768401


  IF (p_hold_lookup_code in ('CANT CLOSE PO', 'CANT TRY PO CLOSE',
           'PO REQUIRED', 'QTY ORD', 'QTY REC',
	   'AMT ORD','AMT REC',
           'PRICE', 'QUALITY', 'CURRENCY DIFFERENCE',
           'TAX DIFFERENCE', 'REC EXCEPTION',
           'PO NOT APPROVED', 'MAX QTY ORD',
           'MAX QTY REC', 'MAX AMT ORD',
	   'MAX AMT REC','FINAL MATCHING',
           'MAX SHIP AMOUNT', 'MAX RATE AMOUNT',
           'MAX TOTAL AMOUNT','MILESTONE',
           'Amount Funded', 'Quantity Funded'   --for CLM project - bug 9494400
           )) THEN

    p_release_lookup_code := 'MATCHED';

  ELSIF (p_hold_lookup_code = 'CANT FUNDS CHECK') THEN

    p_release_lookup_code := 'CAN FUNDS CHECK';

  ELSIF (p_hold_lookup_code = 'INSUFFICIENT FUNDS') THEN

    p_release_lookup_code := 'FUNDS NOW AVAILABLE';

  ELSIF (p_hold_lookup_code = 'AWT ERROR') THEN

    p_release_lookup_code := 'AWT OK';

  ELSIF (p_hold_lookup_code in ('TAX VARIANCE', 'DIST VARIANCE',
        'TAX AMOUNT RANGE', 'LINE VARIANCE')) THEN

    p_release_lookup_code := 'VARIANCE CORRECTED';

  ELSIF (p_hold_lookup_code = 'NATURAL ACCOUNT TAX') THEN

    p_release_lookup_code := 'NATURAL ACCOUNT TAX OK';

  ELSIF (p_hold_lookup_code = 'NO RATE') THEN

    p_release_lookup_code := 'RATE EXISTS';

     --bug9296410
  ELSIF (p_hold_lookup_code = 'Project Hold') THEN

   p_release_lookup_code := 'Project Manager Release';

  ELSIF (p_hold_lookup_code = 'FUTURE PERIOD') THEN

    p_release_lookup_code := 'FUTURE OPEN';

  ELSIF (p_hold_lookup_code = 'DIST ACCT INVALID') THEN

    p_release_lookup_code := 'DIST ACCT VALID';

  ELSIF (p_hold_lookup_code = 'ERV ACCT INVALID') THEN

    p_release_lookup_code := 'ERV ACCT VALID';

  ELSIF (p_hold_lookup_code = 'AWT ACCT INVALID') THEN

    p_release_lookup_code := 'AWT ACCT VALID';

  ELSIF (p_hold_lookup_code in ('AMOUNT','PREPAID AMOUNT')) THEN

    p_release_lookup_code := 'AMOUNT LOWERED';

  ELSIF (p_hold_lookup_code = 'VENDOR') THEN

    p_release_lookup_code := 'VENDOR UPDATED';

  ELSIF (p_hold_lookup_code = 'PROJECT GL DATE CLOSED') THEN

    p_release_lookup_code := 'PROJECT GL DATE OPENED';

  ELSIF (p_hold_lookup_code in ( 'INSUFFICIENT LINE INFO',
                                 'INVALID DEFAULT ACCOUNT',
                                 'DISTRIBUTION SET INACTIVE',
                                 'SKELETON DISTRIBUTION SET',
                                 'CANNOT OVERLAY ACCOUNT',
                                 'CANNOT EXECUTE ALLOCATION' ) ) THEN
    p_release_lookup_code := 'APPROVED';

  -- 7299826 EnC Project
  ELSIF (p_hold_lookup_code IN  ('Pay When Paid', 'PO Deliverable')) THEN

       p_release_lookup_code := 'Automatic Release';

   --start 8691645
  ELSIF (p_hold_lookup_code = 'Expired Registration') THEN

       p_release_lookup_code := 'Registration Activated';
   --end 8691645

  -- Bug 9136390 Start
  ELSIF (p_hold_lookup_code = 'Encumbrance Acctg Fail') THEN
       p_release_lookup_code := 'Encumbrance Acctg Ok';
  -- Bug 9136390 End

  ELSE
    -------------------------------------------
    l_debug_info := 'Invalid Hold Code';
    --  Print_Debug(l_debug_loc, l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;
    -------------------------------------------

    Raise Invalid_Hold;
  END IF;

EXCEPTION
  WHEN Invalid_Hold THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Hold Code  = '|| p_hold_lookup_code
              ||', Release Code = '|| p_release_lookup_code);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Hold Code  = '|| p_hold_lookup_code
              ||', Release Code = '|| p_release_lookup_code);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Get_Release_Lookup_For_Hold;


/*=============================================================================
 |  PROCEDURE GET_INVOICE_STATUSES:
 |      Procedure given a hold_lookup_code retunrs the associated
 |      return_lookup_code
 |
 |  PARAMETERS
 |      p_invoice_id
 |      p_holds_count
 |      p_approval_status
 |      p_calling_sequence: Debugging string to indicate path of module calls
 |                          to be printed out upon error.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

PROCEDURE Get_Invoice_Statuses(
              p_invoice_id       IN            NUMBER,
              p_holds_count      IN OUT NOCOPY NUMBER,
              p_approval_status  IN OUT NOCOPY VARCHAR2,
              p_calling_sequence IN            VARCHAR2) IS

  CURSOR Invoice_Status_Cur IS
    SELECT  AP_INVOICES_PKG.Get_Holds_Count(invoice_id),
            AP_INVOICES_PKG.Get_Approval_Status(
                invoice_id,
                invoice_amount,
                payment_status_flag,
                invoice_type_lookup_code)
    FROM    ap_invoices
    WHERE   invoice_id = p_invoice_id;

  l_debug_loc              VARCHAR2(30) := 'Get_Invoice_Statuses';
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_info             VARCHAR2(1000);
BEGIN

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  -------------------------------------------
  l_debug_info := 'Retrieving new invoice statuses';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  -------------------------------------------

  OPEN Invoice_Status_Cur;
  Fetch Invoice_Status_Cur
   INTO p_holds_count,
        p_approval_status;

  CLOSE Invoice_Status_Cur;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Hold Code  = '|| to_char(p_invoice_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Get_Invoice_Statuses;


/*=============================================================================
 |  PROCEDURE Check_hold_batch_releaseable
 |      Function that returns if the hold batch is releasable.
 |
 |  PARAMETERS
 |      p_hold_name
 |      p_calling_sequence: Debugging string to indicate path of module calls
 |                          to be printed out upon error.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *============================================================================*/

FUNCTION Check_hold_batch_releaseable(
             p_hold_name        IN            VARCHAR2,
             p_calling_sequence IN            VARCHAR2) RETURN VARCHAR2
IS

  l_curr_calling_sequence         VARCHAR2(2000);

BEGIN

  IF ( p_hold_name = 'VENDOR' and
       p_calling_sequence like '%APXAPRVL%' ) THEN
    RETURN 'N';
  ELSE
    RETURN 'Y';
  END IF;

END Check_hold_batch_releaseable;

PROCEDURE Update_Total_Dist_Amount(
              p_invoice_id             IN            NUMBER,
              p_calling_sequence       IN            VARCHAR2) IS

  l_debug_info             VARCHAR2(1000);
  l_curr_calling_sequence  VARCHAR2(2000);
  l_debug_loc              VARCHAR2(30) := 'Update_Total_Dist_Amount';

BEGIN

  -------------------------------------------
  l_debug_info := 'Update Total Dist Amount';
  --  Print_Debug(l_debug_loc, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
  END IF;
  -------------------------------------------

  -- Fix for Bug #5107865.  Replaced bulk update with single update for
  -- performance reasons.
  UPDATE ap_invoice_distributions_all id1
     SET (id1.total_dist_amount,
          id1.total_dist_base_amount) = (SELECT SUM(NVL(id2.amount,0)),
                                                 SUM(NVL(id2.base_amount,0))
                                          FROM  ap_invoice_distributions_all id2
                                          WHERE id2.invoice_distribution_id =
                                                id1.invoice_distribution_id
                                             OR id2.related_id =
                                                id1.invoice_distribution_id)
   WHERE id1.invoice_id = p_invoice_id
     AND id1.line_type_lookup_code NOT IN ('IPV','ERV','TIPV','TRV','TERV');

EXCEPTION
  WHEN OTHERS THEN
    NULL;

END Update_Total_Dist_Amount;


PROCEDURE Exclude_Tax_Freight_From_Disc(
			p_invoice_id IN NUMBER,
                        p_exclude_tax_from_discount IN VARCHAR2,
			p_exclude_freight_from_disc IN VARCHAR2,
			p_net_of_retainage_flag     IN VARCHAR2, --9356460
                        p_invoice_type_lookup_code IN VARCHAR2,
                       p_curr_calling_sequence IN VARCHAR2) IS

  l_debug_loc                   VARCHAR2(100);
  l_curr_calling_sequence       VARCHAR2(2000);
  l_debug_info                  VARCHAR2(1000);
  l_purpose                     VARCHAR2(30);
  l_payment_status              VARCHAR2(1);
  l_prepayment_app_exists       VARCHAR2(1);
  l_discountable_amount         NUMBER;
  l_total_tax_amount		NUMBER;
  l_total_freight_amount	NUMBER;
  l_validated_amount            NUMBER;
  l_terms_id                    NUMBER;
  l_last_updated_by             NUMBER;
  l_created_by                  NUMBER;
  l_payment_priority            NUMBER;
  l_batch_id                    NUMBER;
  l_terms_date                  DATE;
  l_invoice_amount              NUMBER;
  l_pay_curr_invoice_amount     NUMBER;
  l_payment_cross_rate          NUMBER;
  l_payment_method              VARCHAR2(30);
  l_invoice_curr_code           VARCHAR2(15);
  l_pay_curr_code               VARCHAR2(15);
  l_new_amount_to_adjust        NUMBER;
  l_new_discountable_amount     NUMBER;
  l_total_amount_positive       VARCHAR(1);
  l_total_amount                NUMBER ;
  l_records_exist               BOOLEAN;
  j                             NUMBER;
  l_invoice_date                DATE;
  l_tmp_invoice_amount          NUMBER;
  l_tmp_base_amount             NUMBER;
  l_org_id                      NUMBER; --8405589
  l_retained_amount             NUMBER; --8405589
    --Commented for bug#9356460
  --  l_net_of_retainage_flag       VARCHAR2(1); --8405589   -- bug8515942 changed from NUMBER type to VARCHAR


  CURSOR Prepay_Distributions IS
  SELECT aid.invoice_id invoice_id,
         aid.amount*-1 amount,
         l_pay_curr_code pay_currency,
         aid.last_updated_by user_id,
         aid.last_update_login last_update_login,
         l_curr_calling_sequence calling_sequence
  FROM   ap_invoice_distributions  aid,
         ap_invoice_lines ail
  WHERE  aid.invoice_id = p_invoice_id
  AND    ail.invoice_id = aid.invoice_id
  AND    ail.line_number = aid.invoice_line_number
  --bugfix:5609186
  --Bug8340784 Added ITEM to line_type_lookup_code to
  --include recoupment amount on an invoice
  AND    ail.line_type_lookup_code IN ('PREPAY', 'ITEM')
  AND    aid.amount <> 0
  AND    (aid.line_type_lookup_code = 'PREPAY'
          OR aid.charge_applicable_to_dist_id in
            (SELECT invoice_distribution_id
             FROM ap_invoice_distributions
             WHERE line_type_lookup_code = 'PREPAY'
             AND invoice_id = p_invoice_id))
  AND    NVL(aid.invoice_includes_prepay_flag, 'N') <> 'Y';

TYPE  t_prepay_dist_rec IS TABLE OF Prepay_Distributions%ROWTYPE
				INDEX BY BINARY_INTEGER;

v_prepay_dist_rec t_prepay_dist_rec;
l_prepay_excl_tax_amt  number;
BEGIN

  l_debug_loc := 'Exclude_Tax_Freight_From_Disc';
  l_curr_calling_sequence := 'AP_APPROVAL_PKG.Exclude_Tax_From_Discount<-'||P_curr_calling_sequence;

  l_payment_status   := 'N';
  l_prepayment_app_exists := 'N';
  l_total_amount_positive := 'N';
  l_total_amount          := 0;
  l_records_exist         := FALSE;
  j                       :=1;

  ------------------------------------------------------------
  l_debug_info := 'Verify the Parameters and set the purpose';
  ------------------------------------------------------------
   --Introduced retainage flag for bug#9356460
  IF p_exclude_tax_from_discount = 'Y' OR p_exclude_freight_from_disc = 'Y' OR p_net_of_retainage_flag <> 'Y' THEN
    l_purpose := 'EXCLUDE';
  ELSIF (p_invoice_type_lookup_code in ('PO PRICE ADJUST','ADJUSTMENT')) THEN
    l_purpose := 'RETROONLY';
  END IF;

  IF l_purpose = 'EXCLUDE' THEN
     ------------------------------------------------------------
     l_debug_info := 'Check if the Invoice is Paid/partially Paid';
     ------------------------------------------------------------
     BEGIN
        SELECT 'Y'
        INTO   l_payment_status
        FROM   ap_invoice_payments
        WHERE  invoice_id = p_invoice_id
        AND    nvl(reversal_flag,'N') <> 'Y'
        AND    rownum<2;

     EXCEPTION
        WHEN OTHERS THEN
          l_payment_status := 'N';
     END;

     IF l_payment_status <> 'N' THEN
        RETURN;
     END IF;

     ------------------------------------------------------------
     l_debug_info := 'Check if Prepayment Application Exists';
     ------------------------------------------------------------
     BEGIN
       --Bug8340784
	   -- Query table ap_invoice_distributions instead of ap_invoice_lines
	   -- This will include recoupment amount applied as prepayment
       SELECT 'Y'
       INTO   l_prepayment_app_exists
       FROM   ap_invoice_distributions aid
       WHERE  aid.invoice_id = p_invoice_id
		 AND  aid.prepay_distribution_id is not null
         AND  rownum < 2;
	   --End of Bug8340784
     EXCEPTION
       WHEN OTHERS THEN
         l_prepayment_app_exists := 'N';
     END;

     ------------------------------------------------------------
     l_debug_info := 'Get Required Info From Invoice Header';
     ------------------------------------------------------------

     BEGIN
       SELECT amount_applicable_to_discount,
              decode(p_exclude_tax_from_discount,
	             'Y',nvl(total_tax_amount,0),0),
              nvl(validated_tax_amount,0),
              terms_id,
              last_updated_by,
              created_by,
              batch_id,
              terms_date,
              invoice_amount,
              nvl(pay_curr_invoice_amount, invoice_amount),
              payment_cross_rate,
              payment_method_code, --4552701
              invoice_currency_code,
              payment_currency_code,
              invoice_date,
	      org_id   --8405589
	       --Commented for bug#9356460
	     -- net_of_retainage_flag --8405589
       INTO   l_discountable_amount,
              l_total_tax_amount,
              l_validated_amount,
              l_terms_id,
              l_last_updated_by,
              l_created_by,
              l_batch_id,
              l_terms_date,
              l_invoice_amount,
              l_pay_curr_invoice_amount,
              l_payment_cross_rate,
              l_payment_method,
              l_invoice_curr_code,
              l_pay_curr_code,
              l_invoice_date,
              l_org_id  --8405589
	       --Commented for bug#9356460
	     -- l_net_of_retainage_flag  --8405589
       FROM   ap_invoices
       WHERE  invoice_id = p_invoice_id;

     EXCEPTION
      WHEN OTHERS THEN
       RETURN;
     END;

     IF (p_exclude_freight_from_disc = 'Y') THEN
              SELECT NVL(SUM(nvl(ail.amount,0)),0)
        INTO l_total_freight_amount
        FROM ap_invoice_lines ail
        WHERE ail.invoice_id = p_invoice_id
        AND ail.line_type_lookup_code = 'FREIGHT'
        AND nvl(ail.discarded_flag,'N') <> 'Y';
     ELSE
	l_total_freight_amount := 0;
     END IF;

     ------------------------------------------------------------
     l_debug_info := 'Get the retained amount';
     ------------------------------------------------------------

      --Introduced abs() for bug#9356460
     --8405589 Starts

       if nvl(p_net_of_retainage_flag, 'N') <> 'Y' then
	 l_retained_amount := abs(nvl(ap_invoices_utility_pkg.get_retained_total
                                                (p_invoice_id, l_org_id),0));
      end if;
     --8405589 Ends


     ------------------------------------------------------------
     l_debug_info := 'Get the net Tax Amount to Adjust';
     ------------------------------------------------------------
      --Reverted changes done in bug#8405589 for bug#9356460

       l_new_amount_to_adjust := (l_total_tax_amount+l_total_freight_amount+l_retained_amount) - l_validated_amount;

      -- l_new_amount_to_adjust := l_total_tax_amount + l_total_freight_amount - l_retained_amount;

     IF l_new_amount_to_adjust <> 0 THEN
        ------------------------------------------------------------
        l_debug_info := 'Get new discountable Amount';
        ------------------------------------------------------------

        l_new_discountable_amount  := l_discountable_amount
                                  - l_new_amount_to_adjust;


        /* l_new_discountable_amount  := l_invoice_amount
                                  - l_new_amount_to_adjust; */

        ------------------------------------------------------------
        l_debug_info := 'Recreate the Payment Schedules';
        ------------------------------------------------------------
        /* bug 4931755. Procedure Create_Payment_Schedules was called before */
        AP_CREATE_PAY_SCHEDS_PKG.Ap_Create_From_Terms
                     (p_invoice_id,
                      l_terms_id,
                      l_last_updated_by,
                      l_created_by,
                      null,
                      l_batch_id,
                      l_terms_date,
                      l_invoice_amount,
                      l_pay_curr_invoice_amount,
                      l_payment_cross_rate,
                      l_new_discountable_amount,
                      l_payment_method,
                      l_invoice_curr_code,
                      l_pay_curr_code,
                      l_curr_calling_sequence);

        ---------------------------------------------------------------
        l_debug_info := 'Update Pay Schedules if Prepayment APP Exists';
        --------------------------------------------------------------

        IF l_prepayment_app_exists = 'Y' THEN

           OPEN Prepay_Distributions;

           loop
             fetch Prepay_Distributions into v_prepay_dist_rec(j);
             exit when Prepay_Distributions%notfound;
             j:=j+1;
           end loop;

           CLOSE Prepay_Distributions;

           IF v_prepay_dist_rec.COUNT > 0 THEN

              FOR i IN v_prepay_dist_rec.FIRST .. v_prepay_dist_rec.LAST LOOP
                   l_total_amount := l_total_amount + v_prepay_dist_rec(i).amount;
                   l_records_exist := TRUE;
              END LOOP;

              IF l_records_exist THEN

	         --bugfix:5638734
		 -- Get the exculusive tax amount for the prepay appln line.
   	         SELECT sum(aid.amount)
		 INTO l_prepay_excl_tax_amt
		 FROM   ap_invoice_lines_all ail,ap_invoice_distributions_all aid
		 WHERE  ail.line_type_lookup_code='TAX'
		 AND    ail.invoice_id=p_invoice_id
		 AND    aid.invoice_id=ail.invoice_id
	         AND    aid.invoice_line_number=ail.line_number
	         AND   ail.prepay_line_number is not null;

                 l_total_amount:= l_total_amount - nvl(l_prepay_excl_tax_amt,0);

                 IF l_total_amount > 0 THEN
                     l_total_amount_positive := 'Y';
                 ELSE
                     l_total_amount_positive := 'N';
                 END IF;

                 IF l_total_amount <> 0 THEN

                     Update_Payment_Schedule_Prepay(
                                p_invoice_id,
                                l_total_amount,
                                l_total_amount_positive,
                                v_prepay_dist_rec(1).pay_currency,
                                v_prepay_dist_rec(1).user_id,
                                v_prepay_dist_rec(1).last_update_login,
                                v_prepay_dist_rec(1).calling_sequence);

                 END IF;

              END IF;

           END IF;

        END IF;

        --Exclude the manual withholding tax from the payment schedules
        Manual_Withhold_tax( p_invoice_id,
                             5,
                             5,
                             l_curr_calling_sequence);

        --Bug 7393338 added the below call to update amount remaining on payment schedule
                    Update_Pay_Sched_For_Awt( p_invoice_id,
                                        5,
                                        5,
                                       l_curr_calling_sequence);
        ------------------------------------------------------------
        l_debug_info := 'Update Invoice Header';
        ------------------------------------------------------------

        --Introduced l_retained_amount for bug#9356460
       UPDATE ap_invoices
        SET    amount_applicable_to_discount = l_new_discountable_amount,
               validated_tax_amount = l_total_tax_amount+l_total_freight_amount+l_retained_amount
        WHERE  invoice_id = p_invoice_id;


     END IF;

  ELSE -- Retro Price Case

    l_debug_info := 'Retro price case';
    --  Print_Debug(l_debug_loc,l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;

    --Bug9024044: Removed NVL condition from below SUM functions
    SELECT sum(amount),
           sum(base_amount)
      INTO l_tmp_invoice_amount,
           l_tmp_base_amount
      FROM ap_invoice_distributions_all
     WHERE invoice_id = p_invoice_id
       AND ((line_type_lookup_code NOT IN ('PREPAY', 'AWT')
                    AND    prepay_distribution_id IS NULL)
                    OR     nvl(invoice_includes_prepay_flag,'N') = 'Y');

    UPDATE ap_invoices
    SET    invoice_amount                = l_tmp_invoice_amount,
           amount_applicable_to_discount = l_tmp_invoice_amount,
           base_amount                   = l_tmp_base_amount,
           pay_curr_invoice_amount = decode(invoice_currency_code,
                        			nvl(payment_currency_code,invoice_currency_code), l_tmp_invoice_amount,
                        			gl_currency_api.convert_amount
                          				(invoice_currency_code,
                           				 nvl(payment_currency_code,invoice_currency_code),
                           				 payment_cross_rate_date,
                           				 payment_cross_rate_type,
                           				 l_tmp_invoice_amount))
    WHERE invoice_id = p_invoice_id;

     ------------------------------------------------------------
     l_debug_info := 'Get Required Info From Invoice Header';
     ------------------------------------------------------------
     BEGIN
       SELECT amount_applicable_to_discount,
              nvl(total_tax_amount,0),
              nvl(validated_tax_amount,0),
              terms_id,
              last_updated_by,
              created_by,
              batch_id,
              terms_date,
              invoice_amount,
              pay_curr_invoice_amount,
              payment_cross_rate,
              payment_method_code, --4552701
              invoice_currency_code,
              payment_currency_code
       INTO   l_discountable_amount,
              l_total_tax_amount,
              l_validated_amount,
              l_terms_id,
              l_last_updated_by,
              l_created_by,
              l_batch_id,
              l_terms_date,
              l_invoice_amount,
              l_pay_curr_invoice_amount,
              l_payment_cross_rate,
              l_payment_method,
              l_invoice_curr_code,
              l_pay_curr_code
       FROM   ap_invoices
       WHERE  invoice_id = p_invoice_id;

     EXCEPTION
      WHEN OTHERS THEN
       RETURN;
     END;

     ------------------------------------------------------------
     l_debug_info := 'Recreate the Payment Schedules: '|| l_invoice_amount;
     --  Print_Debug(l_debug_loc,l_debug_info);
     IF g_debug_mode = 'Y' THEN
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
     END IF;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
     END IF;
     ------------------------------------------------------------

     AP_CREATE_PAY_SCHEDS_PKG.AP_Create_From_Terms
                   (p_invoice_id,
                    l_terms_id,
                    l_last_updated_by,
                    l_created_by,
                    null,
                    l_batch_id,
                    l_terms_date,
                    l_invoice_amount,
                    l_pay_curr_invoice_amount,
                    l_payment_cross_rate,
                    l_discountable_amount,
                    l_payment_method,
                    l_invoice_curr_code,
                    l_pay_curr_code,
                    l_curr_calling_sequence);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
              ', Invoice Id = '|| to_char(p_invoice_id)
              ||', Exclude Tax from Discount = '|| p_exclude_tax_from_discount
              ||', Invoice Type = '|| p_invoice_type_lookup_code );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Exclude_Tax_Freight_From_Disc;



-------------------------------------------------------------------------------
--This procedure update payment schedules automatically for invoices
--where prepayment is applied. This will be called from the prcedure
-- Exclude_Tax_Freight_From_Discount for the feature as described in the description of
--  the former procedure. A similar procedure exists in prepayment package
-- however due to some restriction we are creating the procedure here. This
-- procedure will not update ap_invoices, but will update payment schedule.
-------------------------------------------------------------------------------

PROCEDURE update_payment_schedule_prepay(
                p_invoice_id                    IN      NUMBER,
                p_apply_amount                  IN      NUMBER,
                p_amount_positive               IN      VARCHAR2,
                p_payment_currency_code         IN      VARCHAR2,
                p_user_id                       IN      NUMBER,
                p_last_update_login             IN      NUMBER,
                p_calling_sequence              IN      VARCHAR2) AS
l_debug_info                    VARCHAR2(1000);
l_current_calling_sequence      VARCHAR2(2000);
l_apply_amount_remaining        NUMBER;
l_cursor_payment_num            NUMBER;
l_cursor_amount                 NUMBER;

CURSOR Schedules IS
    SELECT  payment_num,
            DECODE(p_amount_positive,
                 'N', gross_amount - amount_remaining,
                      amount_remaining)
    --
    -- If unapplying prepayment, we want to get the amount paid, else
    -- we want to get amount remaining so we won't overapply.
    --
    FROM    ap_payment_schedules
    WHERE   invoice_id = p_invoice_id
    AND     (payment_status_flag||'' = 'P'
    OR      payment_status_flag||'' = DECODE(p_amount_positive, 'N', 'Y', 'N'))
    ORDER BY DECODE(p_amount_positive,
                 'N', DECODE(payment_status_flag,'P',1,'Y',2,3),
                      DECODE(NVL(hold_flag,'N'),'N',1,2)),
             DECODE(p_amount_positive,
                     'N', due_date,
                          NULL) DESC,
             DECODE(p_amount_positive,
                     'Y', due_date,
                               NULL),
             DECODE(p_amount_positive,
                 'N', DECODE(hold_flag,'N',1,'Y',2,3),
                      DECODE(NVL(payment_status_flag,'N'),'P',1,'N',2,3));
BEGIN
  -- Update the calling sequence
  l_current_calling_sequence := 'update_payment_schedule_prepay<-'||
                                 p_calling_sequence;
    IF (p_invoice_id IS NULL OR
        p_apply_amount IS NULL OR
        p_amount_positive IS NULL OR
        p_payment_currency_code IS NULL) THEN

       RAISE NO_DATA_FOUND;
    END IF;
   --
   -- l_amount_apply_remaining will keep track of the apply amount that is
   -- remaining to be factored into amount remaining.
   --

   l_apply_amount_remaining := p_apply_amount;
    --
    -- Open schedule ,fetch payment_num and amount into local variable array
    --
    l_debug_info := 'Open Payment Schedule Cursor';

    OPEN SCHEDULES;
    LOOP
    l_debug_info := 'Fetch Schedules into local variables';

    FETCH SCHEDULES INTO l_cursor_payment_num, l_cursor_amount;

    EXIT WHEN SCHEDULES%NOTFOUND;

    if ((((l_apply_amount_remaining - l_cursor_amount) <= 0) AND
        (p_amount_positive = 'Y')) OR
        (((l_apply_amount_remaining + l_cursor_amount) >= 0) AND
        (p_amount_positive = 'N'))) then

    /*-----------------------------------------------------------------------+
     * Case 1 for                                                            *
     *   1. In apply prepayment(amount_positive = 'Y'), the amount remaining *
     *     is greater than apply amount remaining.                           *
     *   2. In unapply prepayment, the apply amount (actually unapply amount *
     *     here) is greater than amount_paid (gross amount-amount remaining).*
     *                                                                       *
     *  It means that this schedule line has enough amount to apply(unapply) *
     *  the whole apply_amount.                                              *
     *                                                                       *
     *  Update the amount remaining for this payment schedule line so that:  *
     *  (amount remaining - apply amount remaining).                         *
     +-----------------------------------------------------------------------*/

     l_debug_info := 'Update ap_payment_schedule for the invoice, case 1';

     UPDATE ap_payment_schedules
        SET amount_remaining = (amount_remaining -
                                ap_utilities_pkg.ap_round_currency(
                                l_apply_amount_remaining,
                                p_payment_currency_code)),
            payment_status_flag =
                        DECODE(amount_remaining -
                               ap_utilities_pkg.ap_round_currency(
                               l_apply_amount_remaining,
                               p_payment_currency_code),
                               0,'Y',
                               gross_amount, 'N',
                               'P'),
            last_update_date = SYSDATE,
            last_updated_by = p_user_id,
            last_update_login = p_last_update_login
      WHERE invoice_id = p_invoice_id
        AND payment_num = l_cursor_payment_num;

     EXIT;

     /* No more amount left */

  else

    /*----------------------------------------------------------------------*
     *Case 2 for this line don't have enough amount to apply(unapply).      *
     *                                                                      *
     *   Update the amount_remaining to 0 and amount_apply_remaining become *
     *   (amount_apply - amount_remaining(this line)), then go to next      *
     *   schedule line.                                                     *
     *----------------------------------------------------------------------*/

     l_debug_info := 'Update ap_payment_schedule for the invoice, case 2';

      UPDATE ap_payment_schedules
         SET amount_remaining = DECODE(p_amount_positive,
                                        'Y', 0,
                                       gross_amount),
             payment_status_flag = DECODE(p_amount_positive,
                                          'Y', 'Y',
                                          'N'),
             last_update_date = SYSDATE,
             last_updated_by = p_user_id,
             last_update_login = p_last_update_login
       WHERE  invoice_id = p_invoice_id
         AND  payment_num = l_cursor_payment_num;

     if (p_amount_positive = 'Y') then
        l_apply_amount_remaining := l_apply_amount_remaining - l_cursor_amount;
     else
        l_apply_amount_remaining := l_apply_amount_remaining + l_cursor_amount;
     end if;

   end if;

END LOOP;

l_debug_info := 'Close Schedule Cursor';

CLOSE SCHEDULES;

--Bug 4539462 DBI logging
AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICES',
               p_operation => 'U',
               p_key_value1 => P_invoice_id,
               p_calling_sequence => l_current_calling_sequence);

EXCEPTION
  WHEN OTHERS then
   if (SQLCODE <> -20001 ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence);

     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(p_invoice_id)
                ||' Apply_amount = '||TO_CHAR(p_apply_amount)
                ||' Amount_positive = '||p_amount_positive
                ||' Apply_amount_remaining = '||
                TO_CHAR(l_apply_amount_remaining)
                ||' Cursor_amount = '||TO_CHAR(l_cursor_amount)
                ||' Cursor_Payment_num = '||TO_CHAR(l_cursor_payment_num)
                ||' User_id = '||TO_CHAR(p_user_id)
                ||' Last_update_login = '||TO_CHAR(p_last_update_login)
                ||' Payment_Currency_code = '||p_payment_currency_code);

     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

   end if;

   APP_EXCEPTION.RAISE_EXCEPTION;

END update_payment_schedule_prepay;


--============================================================================
-- MANUAL_WITHHOLD_TAX:  Procedure that update payment schedules
--                               to reflect the manual withholding amount
--============================================================================
PROCEDURE Manual_Withhold_Tax(p_invoice_id                      IN NUMBER,
                        p_last_updated_by               IN NUMBER,
                        p_last_update_login             IN NUMBER,
                        p_calling_sequence              IN VARCHAR2) IS
  l_manual_awt_amount       ap_invoice_distributions.amount%TYPE :=0;
  l_payment_cross_rate      ap_invoices.payment_cross_rate%TYPE;
  l_pay_curr_code           ap_invoices.payment_currency_code%TYPE;
  l_num_payments                        NUMBER := 0;
  l_invoice_type            ap_invoices.invoice_type_lookup_code%TYPE;--1724924
  l_inv_amt_remaining       ap_payment_schedules.amount_remaining%TYPE := 0;
  l_gross_amount            ap_payment_schedules.gross_amount%TYPE := 0;
  l_debug_loc               VARCHAR2(30) := 'Manual_Withhold_Tax';
  l_curr_calling_sequence   VARCHAR2(2000);

BEGIN

  -- AP_LOGGING_PKG.AP_Begin_Block(l_debug_loc);

  -- Update the calling sequence --

  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||p_calling_sequence;

  -- Initialize local variables
  -- BUG 4340061 : For the lines which have been already been validated but the invoice has been placed on hold.

 --Commented match_status_flag condition for bug#8947048
  SELECT  sum( nvl(amount, 0) )
  INTO   l_manual_awt_amount
  FROM   ap_invoice_distributions
  WHERE  invoice_id = p_invoice_id
--  AND    nvl(match_status_flag, 'N') in ('N','T')   -- BUG 4340061
  AND    line_type_lookup_code = 'AWT'
  AND    awt_flag in ('M', 'O');


  SELECT sum(nvl(amount_remaining,0)), sum(nvl(gross_amount,0))
  INTO l_inv_amt_remaining, l_gross_amount
  FROM ap_payment_schedules
  WHERE invoice_id = p_invoice_id;

  SELECT payment_cross_rate,
         payment_currency_code,
         invoice_type_lookup_code --Bug 1724924
  INTO   l_payment_cross_rate,
         l_pay_curr_code,
         l_invoice_type --Bug 1724924
  FROM   ap_invoices
  WHERE  invoice_id = p_invoice_id;

        --===================================================================
        --Prorate the manual AWT against the invoice amount remaining
        --===================================================================
        --Bug 1985604 - Modified if condition

        -- Bug 2636774. Checking if the manual_awt_amount is <> 0 instead of
        -- not null. This check will ensure that the payment schedule will not
        -- be updated for cancelled invoices.

        -- BUG 4344086 : if condition added. If l_gross_amount = 0 means, the
        -- invoice is either cancelled or is of 0$
        if l_gross_amount = 0
          then
                update ap_payment_schedules
                  set amount_remaining = 0
                where invoice_id = p_invoice_id;

        elsif ((l_inv_amt_remaining <> 0) and (nvl(l_manual_awt_amount,0) <> 0))
          then

                update ap_payment_schedules
                  set amount_remaining = (amount_remaining +
                  ap_utilities_pkg.ap_round_currency(
                 (amount_remaining * (l_manual_awt_amount/l_inv_amt_remaining)
                    * l_payment_cross_rate), l_pay_curr_code ) )
                where invoice_id = p_invoice_id;

        elsif ((l_inv_amt_remaining = 0) and (nvl(l_manual_awt_amount,0) <> 0))
          then

               update ap_payment_schedules
                 set amount_remaining =
                 (amount_remaining +
                 ap_utilities_pkg.ap_round_currency(
                 (gross_amount * (l_manual_awt_amount/l_gross_amount)
                    * l_payment_cross_rate), l_pay_curr_code) ),
                 payment_status_flag = DECODE(payment_status_flag,
                                               'Y','P',payment_status_flag)
               where invoice_id = p_invoice_id;

               update ap_invoices
                 set payment_status_flag = DECODE(payment_status_flag,
                                               'Y','P',payment_status_flag)
               where invoice_id = p_invoice_id;

        end if;


EXCEPTION
  when OTHERS then
            IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',p_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      '  Invoice Id  = '    || to_char(P_Invoice_Id) ||
                      ', Calling module = ' || 'Manual_withhold_tax' );
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

END Manual_Withhold_Tax;

/* Added the following procedure for 7393338 */
--============================================================================
-- Update_Pay_Sched_For_Awt:  Procedure that update payment schedules
--                               to reflect the Automatic withholding amount
--============================================================================


PROCEDURE Update_Pay_Sched_For_Awt(p_invoice_id         IN NUMBER,
                        p_last_updated_by               IN NUMBER,
                        p_last_update_login             IN NUMBER,
                        p_calling_sequence              IN VARCHAR2) IS
 CURSOR Update_payment_schedule IS
         SELECT payment_num,gross_amount,amount_remaining
         FROM ap_payment_schedules
         WHERE invoice_id=p_invoice_id;
  l_automatic_awt_amount       ap_invoice_distributions.amount%TYPE :=0;
  l_payment_cross_rate      ap_invoices.payment_cross_rate%TYPE;
  l_pay_curr_code           ap_invoices.payment_currency_code%TYPE;
  l_num_payments                        NUMBER := 0;
  l_invoice_type            ap_invoices.invoice_type_lookup_code%TYPE;
  l_inv_amt_remaining       ap_payment_schedules.amount_remaining%TYPE := 0;
  l_gross_amount            ap_payment_schedules.gross_amount%TYPE := 0;
  l_payment_num            ap_payment_schedules.payment_num%TYPE;
  l_debug_loc               VARCHAR2(30) := 'Update_Pay_Sched_For_Awt';
  l_curr_calling_sequence   VARCHAR2(2000);
  l_wt_amt_to_subtract      NUMBER := 0;
BEGIN


  l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||p_calling_sequence;


  SELECT  (0 - sum(nvl(amount,0)))
  INTO   l_automatic_awt_amount
  FROM   ap_invoice_distributions
  WHERE  invoice_id = p_invoice_id
  AND    line_type_lookup_code = 'AWT'
  AND    awt_flag = 'A';

 IF  l_automatic_awt_amount <>  0 then

 SELECT payment_cross_rate,
         payment_currency_code,
         invoice_type_lookup_code
  INTO   l_payment_cross_rate,
         l_pay_curr_code,
         l_invoice_type
  FROM   ap_invoices
  WHERE  invoice_id = p_invoice_id;


 OPEN  Update_payment_schedule;

 LOOP
 FETCH Update_payment_schedule into l_payment_num,l_gross_amount,l_inv_amt_remaining;
 EXIT WHEN Update_payment_schedule%NOTFOUND;
         SELECT  nvl(ap_utilities_pkg.ap_round_currency(
                l_automatic_awt_amount*
                ai.payment_cross_rate,l_pay_curr_code),0)*
                l_gross_amount/decode(ai.pay_curr_invoice_amount, 0, 1,
                                      nvl(ai.pay_curr_invoice_amount, 1))
        into    l_wt_amt_to_subtract
        from    ap_invoices ai
        where   ai.invoice_id=p_invoice_id;

        --===================================================================
        --Prorate the automatic AWT against the invoice amount remaining
        --===================================================================
        if l_gross_amount = 0 then
                update ap_payment_schedules
                  set amount_remaining = 0
                where invoice_id = p_invoice_id
                and   payment_num=l_payment_num;

        elsif ((l_inv_amt_remaining <> 0) and (nvl(l_wt_amt_to_subtract,0) <> 0))
          then

                update ap_payment_schedules
                  set amount_remaining = (amount_remaining -
                  ap_utilities_pkg.ap_round_currency(
                 (amount_remaining * ( l_wt_amt_to_subtract/l_inv_amt_remaining)
                    * l_payment_cross_rate), l_pay_curr_code ) )
                where invoice_id = p_invoice_id
                and   payment_num=l_payment_num;

         End If;
               update ap_payment_schedules
               set payment_status_flag ='Y'
               where invoice_id = p_invoice_id
               and payment_num=l_payment_num
               and amount_remaining = 0
               and nvl(payment_status_flag,'N') <> 'Y';
 END LOOP;
 CLOSE Update_payment_schedule;

 END IF;

EXCEPTION
  when OTHERS then
            IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',p_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      '  Invoice Id  = '    || to_char(P_Invoice_Id) ||
                      ', Calling module = ' || 'Update_Pay_Sched_For_Awt' );
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

END Update_Pay_Sched_For_Awt;

--============================================================================
-- createPaymentSchedules:  Procedure that creates payment schedules
--                          for invoice (request) if not yet
--============================================================================
PROCEDURE createPaymentSchedules(p_invoice_id           IN NUMBER,
                        p_calling_sequence              IN VARCHAR2) IS
  l_discountable_amount         NUMBER;
  l_total_tax_amount            NUMBER;
  l_total_freight_amount        NUMBER;
  l_validated_amount            NUMBER;
  l_terms_id                    NUMBER;
  l_last_updated_by             NUMBER;
  l_created_by                  NUMBER;
  l_payment_priority            NUMBER;
  l_batch_id                    NUMBER;
  l_terms_date                  DATE;
  l_invoice_amount              NUMBER;
  l_pay_curr_invoice_amount     NUMBER;
  l_payment_method              VARCHAR2(30);
  l_payment_cross_rate          ap_invoices.payment_cross_rate%TYPE;
  l_invoice_curr_code           VARCHAR2(15);
  l_pay_curr_code               VARCHAR2(15);
  l_debug_info                  VARCHAR2(200);
  l_debug_loc                   VARCHAR2(30) := 'createPaymentSchedules';
  l_schedule_count              NUMBER := 0;
  l_curr_calling_sequence       VARCHAR2(2000);

BEGIN

    l_curr_calling_sequence := 'AP_APPROVAL_PKG.createPaymentSchedules <- '||P_calling_sequence;

    select count(*)
    into   l_schedule_count
    from   ap_payment_schedules_all
    where  invoice_id = p_invoice_id;

    -------------------------------------------
    l_debug_info := 'createPaymentSchedules - payment schedule count = ' || l_schedule_count;
    --  Print_Debug(l_debug_loc, l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;
    -------------------------------------------

    if ( l_schedule_count <= 0 ) then

       -------------------------------------------
       l_debug_info := 'Get Required Info From Invoice Header';
       --  Print_Debug(l_debug_loc, l_debug_info);
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
       END IF;
       -------------------------------------------

       BEGIN
         SELECT invoice_amount,  -- TODO: amount_applicable_to_discount,
              terms_id,
              last_updated_by,
              created_by,
              batch_id,
              terms_date,
              invoice_amount,
              nvl(pay_curr_invoice_amount, invoice_amount),
              payment_cross_rate,
              payment_method_code, --4552701
              invoice_currency_code,
              payment_currency_code
         INTO   l_discountable_amount,
              l_terms_id,
              l_last_updated_by,
              l_created_by,
              l_batch_id,
              l_terms_date,
              l_invoice_amount,
              l_pay_curr_invoice_amount,
              l_payment_cross_rate,
              l_payment_method,
              l_invoice_curr_code,
              l_pay_curr_code
         FROM   ap_invoices
         WHERE  invoice_id = p_invoice_id;

       EXCEPTION
        WHEN OTHERS THEN
        RETURN;
       END;

       -- create payment schedules
       AP_CREATE_PAY_SCHEDS_PKG.Create_Payment_Schedules
                     (p_invoice_id,
                      l_terms_id,
                      l_last_updated_by,
                      l_created_by,
                      null, -- TODO: why payment_priority is null?
                      l_batch_id,
                      l_terms_date,
                      l_invoice_amount,
                      l_pay_curr_invoice_amount,
                      l_payment_cross_rate,
                      l_discountable_amount,
                      l_payment_method,
                      l_invoice_curr_code,
                      l_pay_curr_code,
                      l_curr_calling_sequence);

       -------------------------------------------
       l_debug_info := 'createPaymentSchedules - payment schedule created.';
       --  Print_Debug(l_debug_loc, l_debug_info);
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
       END IF;
       -------------------------------------------

    end if;

EXCEPTION
  when OTHERS then
            IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      '  Invoice Id  = '    || to_char(P_Invoice_Id) ||
                      ', Calling module = ' || 'createPaymentSchedules' );
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

END createPaymentSchedules;


FUNCTION Is_Product_Registered(P_Application_Id      IN         NUMBER,
			       X_Registration_Api    OUT NOCOPY VARCHAR2,
			       X_Registration_View   OUT NOCOPY VARCHAR2,
			       P_Calling_Sequence    IN         VARCHAR2) RETURN BOOLEAN IS

 l_debug_info VARCHAR2(1000);
 l_curr_calling_sequence VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence := 'Is_Product_Registered <-'||p_calling_sequence;

  BEGIN
     SELECT registration_api,
            registration_view
     INTO x_registration_api,
          x_registration_view
     FROM ap_product_registrations
     WHERE application_id = 200
     AND reg_application_id = p_application_id
     AND registration_event_type = 'DISTRIBUTION_GENERATION';

  EXCEPTION WHEN NO_DATA_FOUND THEN
     x_registration_view := NULL;
     x_registration_api := NULL;
     RETURN(FALSE);
  END;

  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS then
     IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
       FND_MESSAGE.SET_TOKEN('PARAMETERS',
                         '  Application Id  = '    || to_char(P_Application_Id) );
     END IF;
     APP_EXCEPTION.RAISE_EXCEPTION;

END Is_Product_Registered;


FUNCTION  Gen_Dists_From_Registration(
		       P_Batch_Id	     IN  NUMBER,
                       P_Invoice_Line_Rec    IN  AP_INVOICES_PKG.r_invoice_line_rec,
                       P_Registration_Api    IN  VARCHAR2,
                       P_Registration_View   IN  VARCHAR2,
		       P_Generate_Permanent  IN  VARCHAR2,
                       X_Error_Code          OUT NOCOPY VARCHAR2,
                       P_Calling_Sequence    IN  VARCHAR2) RETURN BOOLEAN IS

  l_debug_info VARCHAR2(1000);
  l_curr_calling_sequence VARCHAR2(2000);

  TYPE Invoice_Dists_Tab_Type IS TABLE OF ap_invoice_distributions_all%ROWTYPE;
  l_dist_tab Invoice_Dists_Tab_Type := Invoice_Dists_Tab_Type();

  TYPE Expense_Report_Dists_Rec IS RECORD (
	Org_id  ap_exp_report_dists_all.org_id%TYPE,
	Sequence_Num ap_exp_report_dists_all.sequence_num%TYPE,
	Code_Combination_Id ap_exp_report_dists_all.code_combination_id%TYPE,
	Amount  ap_exp_report_dists_all.amount%TYPE,
	Project_Id ap_exp_report_dists_all.project_id%TYPE,
	Task_Id ap_exp_report_dists_all.task_id%TYPE,
	Award_Id ap_exp_report_dists_all.award_id%TYPE,
	pa_quantity ap_expense_report_lines_all.pa_quantity%TYPE, --bug6699834
	Expenditure_Organization_Id ap_exp_report_dists_all.expenditure_organization_id%TYPE,
	Expenditure_type  ap_expense_report_lines_all.expenditure_type%TYPE,
	Expenditure_item_date ap_expense_report_lines_all.expenditure_item_date%TYPE,
        receipt_currency_amount ap_exp_report_dists_all.receipt_currency_amount%TYPE, --bug6520882
        receipt_currency_code    ap_exp_report_dists_all.receipt_currency_code%TYPE,
        receipt_conversion_rate  ap_exp_report_dists_all.receipt_conversion_rate%TYPE);

  TYPE Expense_Report_Dists_Tab_Type IS TABLE OF Expense_Report_Dists_Rec
       index by BINARY_INTEGER;

  l_exp_report_dists_tab  Expense_Report_Dists_Tab_Type;

  CURSOR c_expense_report_dists IS
  SELECT nvl(aerd.org_id,aerl.org_id), --Bug5867415
	 aerd.sequence_num,
	 aerd.code_combination_id,
	 aerd.amount,
	 aerd.project_id,
	 aerd.task_id,
	 aerd.award_id,
	 aerl.pa_quantity,     -- bug6699834
	 aerd.expenditure_organization_id,
	 --bugfix:4939074
	 aerl.expenditure_type,
	 aerl.expenditure_item_date,
         aerd.receipt_currency_amount, --bug6520882
         aerd.receipt_currency_code,
         aerd.receipt_conversion_rate
  FROM ap_exp_report_dists_all aerd,
       ap_expense_report_lines_all aerl
  WHERE aerd.report_header_id = p_invoice_line_rec.reference_key1
  AND aerd.report_line_id = p_invoice_line_rec.reference_key2
  AND aerd.report_line_id = aerl.report_line_id
  AND aerd.report_header_id = aerl.report_header_id
  ORDER BY report_distribution_id;

  i NUMBER;
  j NUMBER;
  l_account_type VARCHAR2(10);
  l_distribution_line_number NUMBER;
  l_total_dist_amount NUMBER;
  l_api_name VARCHAR2(200) :=  'Gen_Dists_From_Registration';

BEGIN

  i:= 0;
  l_distribution_line_number := 0;
  l_total_dist_amount := 0;

  l_curr_calling_sequence := 'Gen_Dists_From_Registration <- '||p_calling_sequence;

  -------------------------------------------
  l_debug_info := 'Generate Distributions as per the applications registered view';
  --  Print_Debug(l_api_name, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  -------------------------------------------

  -------------------------------------------
  l_debug_info := 'P_Registration_View: '||P_Registration_View;
  --  Print_Debug(l_api_name, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  -------------------------------------------

  IF (P_Registration_View = 'AP_EXP_REPORT_DISTS') THEN

     -------------------------------------------
     l_debug_info := 'Open Cursor c_expense_report_dists';
     --  Print_Debug(l_api_name, l_debug_info);
     IF g_debug_mode = 'Y' THEN
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
     END IF;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;
     -------------------------------------------

     OPEN c_expense_report_dists;
     FETCH c_expense_report_dists
     BULK COLLECT INTO l_exp_report_dists_tab;
     CLOSE c_expense_report_dists;

     IF (l_exp_report_dists_tab.COUNT > 0) THEN

       -------------------------------------------
       l_debug_info := 'Exp Report Dists more than zero - setting the amount';
       --  Print_Debug(l_api_name, l_debug_info);
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;
       -------------------------------------------

       FOR i IN l_exp_report_dists_tab.first .. l_exp_report_dists_tab.last LOOP
          l_total_dist_amount := l_total_dist_amount + l_exp_report_dists_tab(i).amount;
       END LOOP;

     END IF;

     IF (l_exp_report_dists_tab.COUNT > 0) THEN

        l_dist_tab.EXTEND(l_exp_report_dists_tab.COUNT);

        -------------------------------------------
        l_debug_info := 'Exp Report Dists more than zero - setting other attributes';
        --  Print_Debug(l_api_name, l_debug_info);
        IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        -------------------------------------------

        FOR i IN l_exp_report_dists_tab.first .. l_exp_report_dists_tab.last LOOP
	   l_distribution_line_number := l_distribution_line_number + 1;

           l_dist_tab(i).org_id := l_exp_report_dists_tab(i).org_id;
	   l_dist_tab(i).distribution_line_number := l_distribution_line_number;
	   l_dist_tab(i).dist_code_combination_id := l_exp_report_dists_tab(i).code_combination_id;
           --bug6597595
	   if l_total_dist_amount = 0 then
	      l_dist_tab(i).amount := 0;
	   else
              --bug6653070
              l_dist_tab(i).amount :=
	   	((p_invoice_line_rec.amount) * l_exp_report_dists_tab(i).amount)/
			l_total_dist_amount;
           end if;
	   l_dist_tab(i).project_id := l_exp_report_dists_tab(i).project_id;
	   l_dist_tab(i).task_id := l_exp_report_dists_tab(i).task_id;
	   l_dist_tab(i).award_id := l_exp_report_dists_tab(i).award_id;
	   l_dist_tab(i).pa_quantity :=  l_exp_report_dists_tab(i).pa_quantity;-- bug6699834

	   l_dist_tab(i).expenditure_organization_id :=  l_exp_report_dists_tab(i).expenditure_organization_id;
	   l_dist_tab(i).expenditure_type := l_exp_report_dists_tab(i).expenditure_type;
	   l_dist_tab(i).expenditure_item_date := l_exp_report_dists_tab(i).expenditure_item_date;
           l_dist_tab(i).receipt_currency_amount:=l_exp_report_dists_tab(i).receipt_currency_amount;--bug6520882
           l_dist_tab(i).receipt_currency_code:= l_exp_report_dists_tab(i).receipt_currency_code;
           l_dist_tab(i).receipt_conversion_rate:= l_exp_report_dists_tab(i).receipt_conversion_rate;
           l_dist_tab(i).batch_id := p_batch_id;
           l_dist_tab(i).invoice_id := p_invoice_line_rec.invoice_id;
           l_dist_tab(i).invoice_line_number := p_invoice_line_rec.line_number;

           SELECT ap_invoice_distributions_s.nextval
           INTO l_dist_tab(i).invoice_distribution_id
           FROM DUAL;

           l_dist_tab(i).line_type_lookup_code := 'ITEM';

           IF (nvl(p_generate_permanent,'N') = 'N') THEN
              l_dist_tab(i).distribution_class := 'CANDIDATE';
           ELSE
              l_dist_tab(i).distribution_class := 'PERMANENT';
           END IF;

           l_dist_tab(i).description := p_invoice_line_rec.description;
           l_dist_tab(i).dist_match_type := 'NOT_MATCHED';
           l_dist_tab(i).accounting_date := p_invoice_line_rec.accounting_date;
           l_dist_tab(i).period_name := p_invoice_line_rec.period_name;
           l_dist_tab(i).accrual_posted_flag := 'N';
           l_dist_tab(i).cash_posted_flag := 'N';
           l_dist_tab(i).posted_flag := 'N';
           l_dist_tab(i).set_of_books_id := p_invoice_line_rec.set_of_books_id;
           l_dist_tab(i).encumbered_flag := 'N';
           l_dist_tab(i).reversal_flag := 'N';
           l_dist_tab(i).cancellation_flag := 'N';
           l_dist_tab(i).income_tax_region := p_invoice_line_rec.income_tax_region;
           l_dist_tab(i).type_1099 := p_invoice_line_rec.type_1099;
           l_dist_tab(i).assets_addition_flag := 'U';
           --Bug9296445
	   l_dist_tab(i).reference_1 := p_invoice_line_rec.reference_1;
	   l_dist_tab(i).reference_2 := p_invoice_line_rec.reference_2;

           BEGIN
              SELECT account_type
              INTO l_account_type
              FROM gl_code_combinations
              WHERE code_combination_id = l_dist_tab(i).dist_code_combination_id;

           EXCEPTION
           WHEN NO_DATA_FOUND THEN

              l_debug_info := l_debug_info || ': cannot read account type information';
	      --  Print_Debug(l_api_name,l_debug_info);
              IF g_debug_mode = 'Y' THEN
                 AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
              END IF;

              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
              END IF;

              RETURN(FALSE);

           END;

           IF (l_account_type = 'A' OR
              (l_account_type = 'E' AND
               p_invoice_line_rec.assets_tracking_flag = 'Y')) then

               l_dist_tab(i).assets_tracking_flag := 'Y';
               l_dist_tab(i).asset_book_type_code := p_invoice_line_rec.asset_book_type_code;
               l_dist_tab(i).asset_category_id := p_invoice_line_rec.asset_category_id;
           ELSE
               l_dist_tab(i).assets_tracking_flag := 'N';
           END IF;

           IF (l_dist_tab(i).project_id IS NULL) THEN
               l_dist_tab(i).pa_addition_flag := 'E';
           ELSE
	       l_dist_tab(i).pa_addition_flag := 'N';
           END IF;

           l_dist_tab(i).awt_group_id := p_invoice_line_rec.awt_group_id;
           l_dist_tab(i).inventory_transfer_status := 'N';
           l_dist_tab(i).intended_use := p_invoice_line_rec.primary_intended_use;
           l_dist_tab(i).rcv_charge_addition_flag := 'N';
           l_dist_tab(i).created_by := FND_GLOBAL.user_id;
           l_dist_tab(i).creation_date := SYSDATE;
           l_dist_tab(i).last_update_date := SYSDATE;
           l_dist_tab(i).last_update_login := FND_GLOBAL.login_id;
	   l_dist_tab(i).last_updated_by := FND_GLOBAL.user_id;

        END LOOP;

     END IF; /* If l_exp_report_dists_tab.count > 0 */

     -------------------------------------------
     l_debug_info := 'Bulk Insert into ap_invoice_distributions';
     --  Print_Debug(l_api_name, l_debug_info);
     IF g_debug_mode = 'Y' THEN
        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
     END IF;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;
     -------------------------------------------
     IF (nvl(l_dist_tab.count,0)<>0) THEN

     FORALL j IN l_dist_tab.first .. l_dist_tab.last
        INSERT INTO ap_invoice_distributions
        VALUES l_dist_tab(j);

      FOR j IN l_dist_tab.first .. l_dist_tab.last
      LOOP
        IF l_dist_tab(j).award_id is not null then
          gms_ap_api.CREATE_AWARD_DISTRIBUTIONS( l_dist_tab(j). invoice_id,
                                                 l_dist_tab(j).distribution_line_number,
                                                 l_dist_tab(j).invoice_distribution_id,
                                                 l_dist_tab(j).award_id,
                                                 'AP',
                                                  NULL,
                                                  NULL);
        End If ;
       END LOOP ;

       END IF;

  ELSIF (P_Registration_Api IS NOT NULL) THEN
    NULL;

  END IF;

  -------------------------------------------
  l_debug_info := 'Setting generate distributions flag to Done';
  --  Print_Debug(l_api_name, l_debug_info);
  IF g_debug_mode = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  -------------------------------------------

  IF (nvl(p_generate_permanent,'N') = 'Y') then
    BEGIN
      UPDATE AP_INVOICE_LINES
      SET GENERATE_DISTS = 'D'
      WHERE invoice_id = p_invoice_line_rec.invoice_id
      AND line_number = p_invoice_line_rec.line_number;
    EXCEPTION
        WHEN OTHERS THEN
          l_debug_info := l_debug_info || ': Error encountered';
          return (FALSE);
    END;
  END IF;

  RETURN(TRUE);


EXCEPTION
  WHEN OTHERS then
    IF (SQLCODE <> -20001) THEN
      l_debug_info := 'In others exception '||sqlerrm;
      --  Print_Debug(l_api_name,l_debug_info);
      IF g_debug_mode = 'Y' THEN
         AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  '  Invoice Id  = '    || to_char(P_invoice_line_rec.Invoice_Id) ||
                  ', Invoice Line Number = '||to_char(p_invoice_line_rec.Line_Number) ||
		  ', Registration Api  = '||P_Registration_Api ||
		  ', Registration View = '||P_Registration_View);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Gen_Dists_From_Registration;


------------------------------------------------------------------------
-- Function Batch_Approval:
-- It selects all invoices depending on the parameters given to it and
-- calls the on-line PL/SQL approval package to approve each invoice
-- individually.
------------------------------------------------------------------------

FUNCTION batch_approval
                (p_run_option           IN VARCHAR2,
                 p_sob_id               IN NUMBER,
                 p_inv_start_date       IN DATE,
                 p_inv_end_date         IN DATE,
                 p_inv_batch_id         IN NUMBER,
                 p_vendor_id            IN NUMBER,
                 p_pay_group            IN VARCHAR2,
                 p_invoice_id           IN NUMBER,
                 p_entered_by           IN NUMBER,
                 p_debug_switch         IN VARCHAR2,
                 p_conc_request_id      IN NUMBER,
                 p_commit_size          IN NUMBER,
                 p_org_id               IN NUMBER,
                 p_report_holds_count   OUT NOCOPY NUMBER,
		 p_transaction_num      IN NUMBER) RETURN BOOLEAN -- Bug 8234569

IS

    TYPE hold_codeTab     IS TABLE OF ap_hold_codes.hold_lookup_code%Type;
    TYPE invoiceIDTab     IS TABLE OF ap_invoices.invoice_id%Type INDEX BY BINARY_INTEGER;
    TYPE invoiceNUMTab    IS TABLE OF ap_invoices.invoice_num%Type INDEX BY BINARY_INTEGER;
    TYPE procinvoiceIDTab IS TABLE OF ap_invoices.invoice_id%Type;
    TYPE hold_org_idTab   IS TABLE OF ap_invoices.org_id%Type;

    TYPE orgIDTab         IS TABLE OF ap_invoices_all.org_id%Type INDEX BY BINARY_INTEGER;
    TYPE invtypeTab IS TABLE OF ap_invoices_all.invoice_type_lookup_code%Type INDEX BY BINARY_INTEGER;

    l_inv_batch_id     			NUMBER(15);
    l_vendor_id         		NUMBER(15);
    l_pay_group         		VARCHAR2(25);
    l_invoice_id        		NUMBER(15);
    l_entered_by        		NUMBER(15);
    l_holds_count       		NUMBER(5);
    l_approval_status   		VARCHAR2(25);

    l_status            		VARCHAR2(80);
    l_approval_error    		VARCHAR2(2000);
    l_org_id            		NUMBER(15);
    l_sel_org_id        		NUMBER(15);
    l_old_org_id        		NUMBER(15);

    l_sel_invoice_type  		VARCHAR2(25);
    l_calling_mode      		VARCHAR2(25);
    l_funds_return_code 		VARCHAR2(30); --Bug6610937

    --Bug9436217
    l_sql_stmt                  	VARCHAR2(8000);
    --Bug9436217
    l_sql_stmt_cursor           	INTEGER;
    ignore                      	INTEGER;
    no_of_rows_fetched          	INTEGER;

    l_hold_code                 	hold_codeTab;
    l_selected_invoice_ids        invoiceIDTab; -- 7461423
    l_sel_invoice_num           	invoiceNUMTab;

    lc_sel_org_id	       		orgIDTab;
    lc_sel_invoice_type	       		invtypeTab;

    l_processed_inv_id         		procinvoiceIDTab;
    l_hold_org_id              		hold_org_idTab;

    l_validation_request_id    		NUMBER;
    l_invoice_num              		VARCHAR2(50);
    l_commit_size              		NUMBER;
    l_curr_calling_sequence		VARCHAR2(2000);

    l_holds                       	HOLDSARRAY;
    l_hold_count                  	COUNTARRAY;
    l_release_count               	COUNTARRAY;
    l_total_hold_count            	NUMBER;
    l_total_release_count         	NUMBER;
    l_line_variance_hold_exist    	BOOLEAN := FALSE;
    l_need_to_round_flag          	VARCHAR2(1) := 'Y';

    l_success				BOOLEAN;
    l_error_code			VARCHAR2(4000);
    l_prorate_across_all_items    	VARCHAR2(1);
    l_debug_context               	VARCHAR2(2000);
    l_insufficient_data_exist     	BOOLEAN := FALSE;

    l_calling_sequence            	VARCHAR2(20);

    l_retained_amount			NUMBER;
    l_recouped_amount			NUMBER;
    l_invoice_rec			AP_APPROVAL_PKG.Invoice_Rec;
    l_invoice_date               	AP_INVOICES.invoice_date%TYPE;
    l_invoice_currency_code      	AP_INVOICES.invoice_currency_code%TYPE;
    l_exchange_rate              	AP_INVOICES.exchange_rate%TYPE;
    l_exchange_rate_type         	AP_INVOICES.exchange_rate_type%TYPE;
    l_exchange_date              	AP_INVOICES.exchange_date%TYPE;
    l_tolerance_id			AP_SUPPLIER_SITES_ALL.TOLERANCE_ID%TYPE;
    l_services_tolerance_id		AP_SUPPLIER_SITES_ALL.SERVICES_TOLERANCE_ID%TYPE;

    Tax_Exception                 	EXCEPTION;

    CURSOR SELECTED_INVOICES_CURSOR  IS
    SELECT
         I.invoice_id,
         I.invoice_num,
         I.org_id,
         I.invoice_amount,
         I.base_amount,
         I.exchange_rate,
         I.invoice_currency_code,
         S.invoice_amount_limit,
         nvl(S.hold_future_payments_flag,'N') hold_future_payments_flag,
         I.invoice_type_lookup_code,
         I.exchange_date,
         I.exchange_rate_type,
         I.vendor_id,
         I.invoice_date,
         nvl(I.disc_is_inv_less_tax_flag,'N') disc_is_inv_less_tax_flag,
         nvl(I.exclude_freight_from_discount,'N') exclude_freight_from_discount,
         nvl(S.tolerance_id,ASP.tolerance_id),                  --Bug8524767
         nvl(S.services_tolerance_id,ASP.services_tolerance_id) --Bug8524767
    FROM   ap_invoices_all I,
	   ap_supplier_sites_all S,
           ap_system_parameters_all ASP                         --Bug8524767
    WHERE  I.vendor_site_id = S.vendor_site_id (+)
    AND    I.validation_request_id = AP_APPROVAL_PKG.G_VALIDATION_REQUEST_ID
    AND    ASP.org_id = I.org_id
    ORDER BY I.org_id;

    --Bug9436217
    l_selected_invoices_cursor	AP_APPROVAL_PKG.Invoices_Table;
    l_blk_err_dist  	varchar2(1):='N';
    --Bug9436217

    l_api_name CONSTANT VARCHAR2(200) := 'Batch_Approval';

-- Start for bug 6511249
   --bug7902867 cusror modified removed ap_supplier_sites_all in join
    CURSOR SELC_INV_CURSOR_BULK_ERROR  IS
    SELECT I.invoice_id, i.invoice_num, i.org_id
      FROM ap_invoices_all I
     WHERE I.validation_request_id = AP_APPROVAL_PKG.G_VALIDATION_REQUEST_ID
     ORDER BY I.org_id;

    TYPE selc_inv_cursor_blk_err is table of selc_inv_cursor_bulk_error%rowtype;

    --bug9738293

    l_sql_tax_err varchar2(1000) := 'SELECT trx_id FROM zx_errors_gt';


    TYPE c_inv_err  IS REF CURSOR;
     r_inv_err  c_inv_err ;

     TYPE inv_err_ids IS TABLE OF zx_errors_gt.trx_id%Type INDEX BY BINARY_INTEGER;
     l_r_inv_err inv_err_ids;

    CURSOR c_tx_err is
             SELECT trx_id, trx_line_id, message_text
             FROM zx_errors_gt;

    TYPE  r_tx_err is  table of c_tx_err%rowtype;
	l_r_tx_err   r_tx_err;

   --bug9738293

    l_selc_inv_cursor_blk_err	selc_inv_cursor_blk_err;
    l_blk_err  		  	varchar2(1):='N';
    l_errbuf   		  	varchar2(200);
    l_conc_status   	  	varchar2(10);
    l_set_status          	boolean;
    Tax_Exception_Handled 	Exception;
    Tax_Dist_Exception_Handled  Exception;
-- End for bug 6511249

     -- 7461423
     TYPE var_cur IS REF CURSOR;
     bat_inv_ref_cursor var_cur;

    -- bug 9304530 - start
    l_invoice_approval_status         VARCHAR2(25);

    CURSOR Invoice_Status_Cursor(p_invoice_id NUMBER) IS
    SELECT AP_INVOICES_PKG.Get_Approval_Status(
                invoice_id,
                invoice_amount,
                payment_status_flag,
                invoice_type_lookup_code)
    FROM    ap_invoices_all
    WHERE   invoice_id = p_invoice_id;
    -- bug 9304530 - end

BEGIN
    IF (p_debug_switch = 'Y') THEN
        g_debug_mode := 'Y';
    END IF;

    ---------------------------------------------------------------------
    --  Print_Debug(l_api_name, 'AP_APPROVAL_PKG.BATCH_APPROVAL.BEGIN');
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, 'AP_APPROVAL_PKG.BATCH_APPROVAL.BEGIN' );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'AP_APPROVAL_PKG.BATCH_APPROVAL.BEGIN');
    END IF;
    ---------------------------------------------------------------------

    ap_approval_pkg.g_validation_request_id := p_conc_request_id;
    g_org_holds.delete;

    ---------------------------------------------------------------------
    --  Print_Debug(l_api_name, 'Setting null input parameters');
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, 'Setting null input parameters' );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Setting null input parameters');
    END IF;
    ---------------------------------------------------------------------
    l_inv_batch_id	:= NVL(p_inv_batch_id,-1);
    l_vendor_id		:= NVL(p_vendor_id,-1);
    l_pay_group		:= NVL(p_pay_group,'All');
    l_invoice_id	:= NVL(p_invoice_id,-1);
    l_entered_by	:= NVL(p_entered_by,-999);
    l_commit_size	:= NVL(p_commit_size,1000);
    l_org_id		:= NVL(p_org_id, -3115);

    ---------------------------------------------------------------------
    --  Print_Debug(l_api_name, 'Clean-up validation_request_id');
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, 'Clean-up validation_request_id' );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Clean-up validation_request_id');
    END IF;
    ---------------------------------------------------------------------
    /* Bug 9777752 : Sl No 4 Change
    UPDATE ap_invoices api
       SET validation_request_id = NULL
     WHERE validation_request_id IS NOT NULL
       AND EXISTS
               ( SELECT 'Request Completed'
                   FROM fnd_concurrent_requests fcr
                  WHERE fcr.request_id = api.validation_request_id
                    AND fcr.phase_code = 'C' ); */

    UPDATE ap_invoices api
       SET validation_request_id = NULL
     WHERE validation_request_id IN
           ( SELECT request_id
               FROM fnd_concurrent_requests fcr
              WHERE fcr.concurrent_program_id = ( SELECT concurrent_program_id
                                                    FROM fnd_concurrent_programs fcp
                                                   WHERE fcp.application_id = 200
                                                     AND fcp.concurrent_program_name = 'APPRVL'
                                                )
                AND fcr.phase_code = 'C'
                AND fcr.status_code not in ( 'X', 'E', 'G')
           );


    ---------------------------------------------------------------------
    --  Print_Debug(l_api_name, 'Cache System Options');
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, 'Cache System Options' );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Cache System Options');
    END IF;
    ---------------------------------------------------------------------
    AP_Approval_PKG.Cache_Options(l_curr_calling_sequence);


    IF (l_invoice_id <> -1) THEN

      --Bug 9304530 - Added check to exclude already validated invoices
      ---------------------------------------------------------------------
      --  Print_Debug(l_api_name, 'Check Invoice Validation Status');
      IF g_debug_mode = 'Y' THEN
         AP_Debug_Pkg.Print(g_debug_mode, 'Check Invoice Validation Status' );
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Check Invoice Validation Status');
      END IF;
      ---------------------------------------------------------------------

      OPEN  Invoice_Status_Cursor(l_invoice_id);
      FETCH Invoice_Status_Cursor
      INTO  l_invoice_approval_status;
      CLOSE Invoice_Status_Cursor;

      IF NVL(l_invoice_approval_status,'DUMMY') NOT IN ('APPROVED','AVAILABLE','UNPAID','FULL','CANCELLED') THEN

        IF validate_period(l_invoice_id) THEN  /*bug6858309 - changed location of the call*/

        ---------------------------------------------------------------------
        --  Print_Debug(l_api_name, 'Begin Approving Single Invoice');
        IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, 'Begin Approving Single Invoice' );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Begin Approving Single Invoice');
        END IF;
        ---------------------------------------------------------------------

/* 6699825/6684139: Added the AND condition to check if the invoice has any
   lines. Otherwise, we will not proceed with validating the invoice */

        UPDATE ap_invoices_all ai
           SET ai.validation_request_id = p_conc_request_id
         WHERE ai.invoice_id = l_invoice_id
           AND ai.validation_request_id IS NULL
		   /*bug 7029877 Invoice saved but not submitted*/
           AND ai.approval_ready_flag <>'S'
           AND EXISTS (select ail.invoice_id
                       from ap_invoice_lines_all ail
                       where ail.invoice_id = ai.invoice_id) ;

         --  bug 6351170 -Added below if condition  -  Return if there are no invoices to process
        IF sql%rowcount = 0 THEN
           RETURN true;
        END IF;

        COMMIT;

        BEGIN
           --Modified SELECT statement for bug #8420964/8556734
 	   --Added ap_system_parameters_all table and nvl condition for
	   --tolerance columns

	     SELECT
		  ai.invoice_num, ai.org_id, ai.invoice_type_lookup_code, ai.validation_request_id,
                  ai.invoice_id,  ai.invoice_date, ai.invoice_currency_code, ai.exchange_rate,
                  ai.exchange_rate_type, ai.exchange_date, ai.vendor_id, ai.org_id,
		  nvl(s.tolerance_id,asp.tolerance_id),nvl(s.services_tolerance_id,asp.services_tolerance_id)
             INTO
		  l_invoice_num, l_sel_org_id, l_sel_invoice_type, l_validation_request_id,
                  l_invoice_id, l_invoice_date, l_invoice_currency_code, l_exchange_rate,
                  l_exchange_rate_type, l_exchange_date, l_vendor_id, l_org_id, l_tolerance_id,
		  l_services_tolerance_id
	     FROM ap_invoices_all ai,
		  ap_supplier_sites_all s,
		  ap_system_parameters_all asp
	    WHERE ai.invoice_id = l_invoice_id
	      AND ai.vendor_site_id = s.vendor_site_id(+)
	      AND ai.org_id = asp.org_id;
	EXCEPTION
	    WHEN OTHERS THEN
	           --  Print_Debug(l_api_name, 'Invoice Number Not Found');
                   IF g_debug_mode = 'Y' THEN
                      AP_Debug_Pkg.Print(g_debug_mode, 'Invoice Number Not Found' );
                   END IF;

                   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Invoice Number Not Found');
                   END IF;
	           RETURN(FALSE);
        END;

        mo_global.set_policy_context('S', l_sel_org_id);

        ---------------------------------------------------------------------
        --  Print_Debug (l_api_name, 'Calculate Tax');
        IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, 'Calculate Tax' );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Calculate Tax');
        END IF;
        ---------------------------------------------------------------------
        l_success := ap_etax_pkg.calling_etax(
                           p_invoice_id         => NULL,
                           p_calling_mode       => 'CALCULATE',
                           p_all_error_messages => 'N',
                           p_error_code         => l_error_code,
                           p_calling_sequence   => l_curr_calling_sequence);

        IF (NOT l_success) THEN
            RAISE Tax_Exception;
        END IF;

        ----------------------------------------------------------------
        --  Print_Debug(l_api_name, 'Initialize Invoice Holds Array');
        IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, 'Initialize Invoice Holds Array' );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Initialize Invoice Holds Array');
        END IF;
        ----------------------------------------------------------------
        Initialize_Invoice_Holds(
                        p_invoice_id       => l_invoice_id,
                        p_calling_sequence => l_curr_calling_sequence);

        ---------------------------------------------------------------------
        --  Print_Debug (l_api_name, 'Generate Distributions');
        IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, 'Generate Distributions' );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Generate Distributions');
        END IF;
        ---------------------------------------------------------------------

        l_invoice_rec.invoice_id               := l_invoice_id;
        l_invoice_rec.invoice_date             := l_invoice_date;
        l_invoice_rec.invoice_currency_code    := l_invoice_currency_code;
        l_invoice_rec.exchange_rate            := l_exchange_rate;
        l_invoice_rec.exchange_rate_type       := l_exchange_rate_type;
        l_invoice_rec.exchange_date            := l_exchange_date;
        l_invoice_rec.vendor_id                := l_vendor_id;
        l_invoice_rec.org_id                   := l_org_id;
	g_org_id 			       := l_org_id;


        AP_APPROVAL_PKG.Generate_Distributions
                                (p_invoice_rec        => l_invoice_rec,
                                 p_base_currency_code => AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_org_id).base_currency_code,
                                 p_inv_batch_id       => p_inv_batch_id,
                                 p_run_option         => p_run_option,
                                 p_calling_sequence   => l_curr_calling_sequence,
                                 x_error_code         => l_error_code);

       ---------------------------------------------------------------------
       --  Print_Debug (l_api_name, 'Generate Tax Distributions');
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, 'Generate Tax Distributions' );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Generate Tax Distributions');
       END IF;
       ---------------------------------------------------------------------
       l_success := ap_etax_pkg.calling_etax (
                           p_invoice_id         => NULL,
                           p_calling_mode       => 'DISTRIBUTE',
                           p_all_error_messages => 'N',
                           p_error_code         => l_error_code,
                           p_calling_sequence   => l_curr_calling_sequence);

       IF (NOT l_success) THEN
           RAISE Tax_Exception;
       END IF;


        IF l_sel_invoice_type = 'PAYMENT REQUEST' THEN
           l_calling_mode := 'PAYMENT REQUEST';
        ELSE
           l_calling_mode := 'APPROVE';
        END IF;

        ---------------------------------------------------------------------
        --  Print_Debug(l_api_name, 'Approving specified invoice : '||l_invoice_num);
        IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, 'Approving specified invoice : '||l_invoice_num );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Approving specified invoice : '||l_invoice_num);
        END IF;
        ---------------------------------------------------------------------

        IF l_validation_request_id = p_conc_request_id THEN

           --IF validate_period(l_invoice_id) THEN  /*commented  for bug 6858309*/

              -- Cache Templates
              Cache_Tolerance_Templates(
                        l_tolerance_id,
                        l_services_tolerance_id,
                        l_calling_sequence);

              --Removed the hardcoded value of p_budget_control, bug6356402
              AP_APPROVAL_PKG.APPROVE(
				'',
                                '',
  				'',
				'',
				'',
				'',
				l_invoice_id,
				'',
				'',
				'',
				'Y',
				l_holds_count,
				l_approval_status,
                        	l_funds_return_code,
                        	l_calling_mode,
				'APXAPRVL',
                        	p_debug_switch
                        	);
          /*commented for bug 6858309
	   ELSE
            fnd_message.set_name('SQLAP', 'AP_INV_NEVER_OPEN_PERIOD');
            fnd_message.set_token('INV_NUM', l_invoice_num);
            fnd_file.put_line(fnd_file.log, fnd_message.get);
           END IF;   */

           UPDATE ap_invoices_all
              SET validation_request_id = NULL
            WHERE invoice_id = l_invoice_id;

        END IF;

        ELSE  /*bug6858309- changed location of the call*/
            fnd_message.set_name('SQLAP', 'AP_INV_NEVER_OPEN_PERIOD');
            fnd_message.set_token('INV_NUM', l_invoice_num);
            fnd_file.put_line(fnd_file.log, fnd_message.get);

        END IF;  --if validate_period(p_invoice_id)

      ELSE  /*Bug 9304530 - Exclude already validated invoices*/
            fnd_message.set_name('SQLAP', 'AP_APPRVL_INV_NOT_FOUND');
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            -----------------------------------------------------------------
            --  Print_Debug(l_api_name, 'Invoice is already approved/cancelled');
            IF g_debug_mode = 'Y' THEN
               AP_Debug_Pkg.Print(g_debug_mode, 'Invoice is already approved/cancelled' );
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Invoice is already approved/cancelled');
            END IF;
            -----------------------------------------------------------------
      END IF;  --if p_approval_status...

        ---------------------------------------------------------------------
        --  Print_Debug(l_api_name, 'End Approving Single Invoice');
        IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, 'End Approving Single Invoice' );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'End Approving Single Invoice');
        END IF;
        ---------------------------------------------------------------------

    ELSE -- Invoice_id is null case -- Marker 0

        ---------------------------------------------------------------------
        --  Print_Debug(l_api_name, 'Batch Approval Start');
        IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, 'Batch Approval Start' );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Batch Approval Start');
        END IF;
        ---------------------------------------------------------------------

       /*bug6858309 modified this dynamic update to filter out
         recurring invoices havign GL DATE in never open period*/
       /* Added for bug#7270053 Start */
        --BUG7902867 replace view with base tables in sub queries
        -- AP_INVOICES_ALL is replace with ap_invoices
	/* BUG 8218038 added nvl condition for historical and payment status flags */
        /* Changed the Sql structure to replace the exists with UNION ALL for bug#7584153 */

        --  Bug 9777752 : Restructured dynamic SQL
	l_sql_stmt :=l_sql_stmt||
       'SELECT  /*+ dynamic_sampling(2) cardinality(ai,10) */ invoice_id from AP_INVOICES AI   -- 7461423
         WHERE AI.VALIDATION_REQUEST_ID IS NULL
           AND AI.APPROVAL_READY_FLAG <> ''S''
	   AND AI.CANCELLED_DATE IS NULL /* Bug 9777752 */
           AND NOT ( NVL(AI.PAYMENT_STATUS_FLAG,''N'') = ''Y'' AND
                     NVL(AI.HISTORICAL_FLAG,''N'') = ''Y'' )
           AND EXISTS (
                        SELECT /*+ PUSH_SUBQ */ 1
                          FROM DUAL
                         WHERE UPPER(NVL(AI.SOURCE, ''X'')) <> ''RECURRING INVOICE''
                        UNION ALL
                        SELECT 1
                          FROM DUAL
                         WHERE UPPER(NVL(AI.SOURCE, ''X'')) = ''RECURRING INVOICE''
                           AND NOT EXISTS
                               (  SELECT NULL
                                    FROM GL_PERIOD_STATUSES GLPS
                                   WHERE GLPS.APPLICATION_ID = ''200''
                                     AND GLPS.SET_OF_BOOKS_ID = AI.SET_OF_BOOKS_ID
                                     AND TRUNC(AI.GL_DATE) BETWEEN GLPS.START_DATE AND GLPS.END_DATE
                                     AND NVL(GLPS.ADJUSTMENT_PERIOD_FLAG, ''N'') = ''N''
                                     AND GLPS.CLOSING_STATUS = ''N''
                               )
                      )
           AND EXISTS (
                        SELECT 1
                          FROM DUAL
                         WHERE AI.FORCE_REVALIDATION_FLAG = ''Y''
                        UNION ALL
                        SELECT 1
                          FROM AP_INVOICE_DISTRIBUTIONS_ALL D,
                               FINANCIALS_SYSTEM_PARAMS_ALL FSP
	                 WHERE D.INVOICE_ID = AI.INVOICE_ID
                           AND FSP.ORG_ID = AI.ORG_ID
                           AND FSP.SET_OF_BOOKS_ID = AI.SET_OF_BOOKS_ID
 		           AND (NVL(FSP.PURCH_ENCUMBRANCE_FLAG,''N'') = ''Y'' AND NVL(D.MATCH_STATUS_FLAG,''N'') <> ''A'' OR
                               (NVL(FSP.PURCH_ENCUMBRANCE_FLAG,''N'') = ''N'' AND NVL(D.MATCH_STATUS_FLAG,''N'') NOT IN (''A'',''T'')))
		        UNION ALL
		        SELECT 1
       		          FROM AP_SELF_ASSESSED_TAX_DIST_ALL D,
                               FINANCIALS_SYSTEM_PARAMS_ALL FSP
		         WHERE D.INVOICE_ID = AI.INVOICE_ID
                           AND FSP.ORG_ID = AI.ORG_ID
                           AND FSP.SET_OF_BOOKS_ID = AI.SET_OF_BOOKS_ID
 		           AND (NVL(FSP.PURCH_ENCUMBRANCE_FLAG,''N'') = ''Y'' AND NVL(D.MATCH_STATUS_FLAG,''N'') <> ''A'' OR
                               (NVL(FSP.PURCH_ENCUMBRANCE_FLAG,''N'') = ''N'' AND NVL(D.MATCH_STATUS_FLAG,''N'') NOT IN (''A'',''T'')))
		           AND NOT EXISTS
		               ( SELECT ''Cancelled distributions''
		                   FROM AP_SELF_ASSESSED_TAX_DIST_ALL D2
		                  WHERE D2.INVOICE_ID = D.INVOICE_ID
		                    AND D2.CANCELLATION_FLAG = ''Y''
		               )
                        UNION ALL
                        SELECT 1
                          FROM AP_HOLDS_ALL H
                         WHERE H.INVOICE_ID = AI.INVOICE_ID
                           AND H.HOLD_LOOKUP_CODE IN
                                  (''QTY ORD'', ''QTY REC'', ''AMT ORD'', ''AMT REC'', ''QUALITY'',
                                   ''PRICE'', ''TAX DIFFERENCE'', ''CURRENCY DIFFERENCE'',
                                   ''REC EXCEPTION'', ''TAX VARIANCE'', ''PO NOT APPROVED'',
                                   ''PO REQUIRED'', ''MAX SHIP AMOUNT'', ''MAX RATE AMOUNT'',
                                   ''MAX TOTAL AMOUNT'', ''TAX AMOUNT RANGE'', ''MAX QTY ORD'',
                                   ''MAX QTY REC'', ''MAX AMT ORD'', ''MAX AMT REC'',
                                   ''CANT CLOSE PO'', ''CANT TRY PO CLOSE'', ''LINE VARIANCE'',
                                   ''CANT FUNDS CHECK'',''Expired Registration'',''Amount Funded'',''Quantity Funded'')
                           AND H.RELEASE_LOOKUP_CODE IS NULL
                            AND EXISTS
                               ( SELECT ''Lines''
                                   FROM AP_INVOICE_LINES_ALL L2
                                  WHERE L2.INVOICE_ID = H.INVOICE_ID ) --8580790,9112369
                        UNION ALL
                        SELECT 1
                          FROM AP_INVOICE_LINES_ALL AIL
                         WHERE AIL.INVOICE_ID = AI.INVOICE_ID
                           /* Bug 9777752 AND AI.CANCELLED_DATE IS NULL  */
                           AND NVL(AIL.DISCARDED_FLAG, ''N'') <> ''Y''
		           AND NVL(AIL.CANCELLED_FLAG, ''N'') <> ''Y''
                           AND (AIL.AMOUNT <> 0  OR
                                (AIL.AMOUNT = 0 AND AIL.GENERATE_DISTS = ''Y'')) --8580790
                           AND NOT EXISTS
                               ( SELECT /*+ NO_UNNEST */
                                       ''distributed line''
                                   FROM AP_INVOICE_DISTRIBUTIONS_ALL D5
                                  WHERE D5.INVOICE_ID = AIL.INVOICE_ID
                                    AND D5.INVOICE_LINE_NUMBER = AIL.LINE_NUMBER
                                )
                      )
           AND NOT EXISTS
                          ( SELECT /*+ no_push_subq */ ''Cancelled distributions''
                              FROM AP_INVOICE_DISTRIBUTIONS_ALL D3
                             WHERE D3.INVOICE_ID = AI.INVOICE_ID
                               AND D3.CANCELLATION_FLAG = ''Y''
                          ) ' ;



         --Bug9436217

         IF P_org_id IS NOT NULL THEN
           l_sql_stmt := l_sql_stmt|| 'AND AI.org_id = :b_org_id ' ;
         END IF ;
         IF P_inv_batch_id IS NOT NULL THEN
           l_sql_stmt := l_sql_stmt|| 'AND AI.batch_id = :b_inv_batch_id ' ;
         END IF ;

         --Bug9436217

         IF P_vendor_id IS NOT NULL THEN
           l_sql_stmt := l_sql_stmt|| 'AND AI.vendor_id = ' || p_vendor_id || ' ' ;
         END IF ;
         IF P_inv_start_date IS NOT NULL AND P_inv_end_date IS NULL THEN
           l_sql_stmt := l_sql_stmt|| 'AND AI.invoice_date >= :b_start_date ' ;
         END IF ;
         IF P_inv_start_date IS NULL AND P_inv_end_date IS NOT NULL THEN
           l_sql_stmt := l_sql_stmt || 'AND AI.invoice_date <= :b_end_date ' ;
         END IF ;
         IF P_inv_start_date IS NOT NULL AND P_inv_end_date IS NOT NULL THEN
           IF P_inv_start_date  <> P_inv_end_date THEN
              l_sql_stmt := l_sql_stmt || 'AND AI.invoice_date BETWEEN :b_start_date AND :b_end_date ' ;
           ELSE
              l_sql_stmt := l_sql_stmt || 'AND AI.invoice_date = :b_start_date ' ;
           END IF ;
         END IF ;
         IF P_entered_by IS NOT NULL THEN
           l_sql_stmt := l_sql_stmt || ' AND AI.created_by = ' || l_entered_by || ' ' ;
         END IF ;
         IF P_pay_group IS NOT NULL THEN
           l_sql_stmt := l_sql_stmt || ' and AI.pay_group_lookup_code = ' || '''' || l_pay_group || '''' || ' ' ;
         END IF ;


        --Bug8587494
	/*
        -- Added for bug 8234569
	IF P_transaction_num IS NOT NULL THEN
	  l_sql_stmt := l_sql_stmt || ' and rownum <= '|| P_transaction_num || ' ';
	END IF ;
	-- Bug 8234569 ends
	*/
        --Bug8587494


        l_sql_stmt :=l_sql_stmt || ' FOR UPDATE SKIP LOCKED';
        ---------------------------------------------------------------------
		-- bug 9054664: modify start
		-- split the string as fndlog cannot handle more than 4000 chars
		--  Print_Debug (l_api_name, substr(l_sql_stmt, 1, 4000));
                --  Print_Debug (l_api_name, substr(l_sql_stmt, 4001));
                IF g_debug_mode = 'Y' THEN
                   AP_Debug_Pkg.Print(g_debug_mode, substr(l_sql_stmt, 1, 4000) );
                   AP_Debug_Pkg.Print(g_debug_mode, substr(l_sql_stmt, 4001) );
                END IF;

                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, substr(l_sql_stmt, 1, 4000));
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, substr(l_sql_stmt, 4001));
                END IF;
		-- bug 9054664: modify end
        ---------------------------------------------------------------------

        --Bug9436217

        IF p_inv_start_date IS NOT NULL OR p_inv_end_date IS NOT NULL THEN
           IF (p_inv_start_date IS NOT NULL AND p_inv_end_date IS NOT NULL AND P_inv_start_date  <> P_inv_end_date) THEN -- bug 7688696

		        IF P_org_id IS NOT NULL THEN
		           IF P_inv_batch_id IS NOT NULL THEN
			          OPEN  bat_inv_ref_cursor FOR l_sql_stmt
			         USING l_org_id, p_inv_batch_id, p_inv_start_date, p_inv_end_date;
		           ELSE
			          OPEN  bat_inv_ref_cursor FOR l_sql_stmt
			         USING l_org_id, p_inv_start_date, p_inv_end_date;
		           END IF ;
		        ELSE
		           IF P_inv_batch_id IS NOT NULL THEN
			          OPEN  bat_inv_ref_cursor FOR l_sql_stmt
			         USING p_inv_batch_id, p_inv_start_date, p_inv_end_date;
		           ELSE
			          OPEN  bat_inv_ref_cursor FOR l_sql_stmt
			         USING p_inv_start_date, p_inv_end_date;
		           END IF ;
		        END IF ;

             ELSE

                        IF P_org_id IS NOT NULL THEN
		          IF P_inv_batch_id IS NOT NULL THEN
			         OPEN  bat_inv_ref_cursor FOR l_sql_stmt
			        USING l_org_id, p_inv_batch_id, NVL(p_inv_start_date, p_inv_end_date);
		          ELSE
			         OPEN  bat_inv_ref_cursor FOR l_sql_stmt
			        USING l_org_id, NVL(p_inv_start_date, p_inv_end_date);
		          END IF ;
		        ELSE
		          IF P_inv_batch_id IS NOT NULL THEN
			         OPEN  bat_inv_ref_cursor FOR l_sql_stmt
			        USING p_inv_batch_id, NVL(p_inv_start_date, p_inv_end_date);
		          ELSE
			         OPEN  bat_inv_ref_cursor FOR l_sql_stmt
			        USING NVL(p_inv_start_date, p_inv_end_date);
		          END IF ;
		       END IF ;

	       END IF;

	    ELSE

           IF P_org_id IS NOT NULL THEN
		      IF P_inv_batch_id IS NOT NULL THEN
    	         OPEN  bat_inv_ref_cursor FOR l_sql_stmt
		        USING l_org_id, p_inv_batch_id ;
	          ELSE
       	         OPEN  bat_inv_ref_cursor FOR l_sql_stmt
		        USING l_org_id ;
	          END IF ;
	       ELSE
   		      IF P_inv_batch_id IS NOT NULL THEN
    		     OPEN  bat_inv_ref_cursor FOR l_sql_stmt
		         USING p_inv_batch_id ;
		      ELSE
  		         OPEN  bat_inv_ref_cursor FOR l_sql_stmt ;
		      END IF ;
	       END IF ;
          END IF;

        --Bug9436217


        --Bug8587494
        IF P_transaction_num is NULL OR P_transaction_num = 0 THEN
           -- 7461423 to skip locked invoices
           FETCH bat_inv_ref_cursor
           BULK COLLECT INTO l_selected_invoice_ids;
           CLOSE bat_inv_ref_cursor;
        ELSIF P_transaction_num > 0 THEN
           -- 7461423 to skip locked invoices
           FETCH bat_inv_ref_cursor
           BULK COLLECT INTO l_selected_invoice_ids LIMIT P_transaction_num;
           CLOSE bat_inv_ref_cursor;
        END IF;
        --Bug8587494

	-- Added debug msg for Bug 8234569
        ---------------------------------------------------------------------
        --  FND_FILE.PUT_LINE(FND_FILE.LOG,'No. of Invoices selected for Processing: '||l_selected_invoice_ids.count);
	--  Print_Debug (l_api_name,'No. of Invoices selected for Processing: '||l_selected_invoice_ids.count);
	IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, 'No. of Invoices selected for Processing: '||l_selected_invoice_ids.count );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'No. of Invoices selected for Processing: '||l_selected_invoice_ids.count);
        END IF;
        ---------------------------------------------------------------------

        IF l_selected_invoice_ids.count > 0 THEN

           --Bug9436217

           FORALL k IN 1..l_selected_invoice_ids.COUNT
	              UPDATE ap_invoices_all
	                 SET validation_request_id = AP_APPROVAL_PKG.G_VALIDATION_REQUEST_ID
	               WHERE invoice_id = l_selected_invoice_ids(k)
                     AND validation_request_id IS NULL;

           --Bug9436217


        ELSE

           RETURN true;

        END IF;

        COMMIT;

       ---------------------------------------------------------------------
       --  Print_Debug (l_api_name, 'Calculate Tax');
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, 'No. of Invoices selected for Processing: '||'Calculate Tax' );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Calculate Tax');
       END IF;
       ---------------------------------------------------------------------

       SAVEPOINT AP_APPROVAL_PKG_SP_ETAX;

       --Bug9436217

       FND_FILE.PUT_LINE(FND_FILE.LOG,'(Bulk CALCULATE) START SYSDATE '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

       --Bug9436217


      --bug 9738293
       --Changed the calling method for Bulk tax calulation . ETAX API will be called till there is no
       -- error in ZX error table or they return success.

	   LOOP

	   delete from zx_errors_gt;  --Flusing the GT Table

       l_success := ap_etax_pkg.calling_etax(
                           p_invoice_id         => NULL,
                           p_calling_mode       => 'CALCULATE',
                           p_all_error_messages => 'N',
                           p_error_code         => l_error_code,
                           p_calling_sequence   => l_curr_calling_sequence);

      OPEN  c_tx_err  ;
         FETCH c_tx_err
          BULK COLLECT INTO l_r_tx_err;
		   CLOSE c_tx_err;

	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Rows fetched from GT is ' || l_r_tx_err.count );
	  END IF ;

		EXIT when (l_r_tx_err.count = 0 OR l_success);


		    OPEN  r_inv_err for l_sql_tax_err ;
                     FETCH r_inv_err
                         BULK COLLECT INTO l_r_inv_err;
                        CLOSE r_inv_err;


		ROLLBACK TO SAVEPOINT AP_APPROVAL_PKG_SP_ETAX;


		FORALL i in 1..l_r_inv_err.count
		Update ap_invoices_all set validation_request_id = NULL where invoice_id =  l_r_inv_err(i);

		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Rows updated ' || sql%rowcount);
         	END IF ;

		  l_conc_status := 'WARNING';

              FOR i in 1..l_r_tx_err.count
	      LOOP

	      fnd_file.put_line (fnd_file.log, l_approval_error
                      || 'Invoice Validation did not process Invoice Id Due to Tax Error:' || l_r_tx_err(i).trx_id
                      || ', Line Number: ' || l_r_tx_err(i).trx_line_id);
             fnd_file.put_line (fnd_file.log, l_r_tx_err(i).message_text);

	     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Invoice Validation did not process Invoice Id Due to Tax Error:'
                      || l_r_tx_err(i).trx_id);
             END IF;
              END LOOP;

  END LOOP;
   --bug 9738293

       --Bug9436217

       FND_FILE.PUT_LINE(FND_FILE.LOG,'(Bulk CALCULATE) END SYSDATE '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

       --Bug9436217

       IF (NOT l_success) THEN  -- Marker 1

         ROLLBACK TO SAVEPOINT AP_APPROVAL_PKG_SP_ETAX;

         l_blk_err := 'Y';

         ---------------------------------------------------------------------
         --  Print_Debug (l_api_name, 'Set Concurrent Request Warning');
         IF g_debug_mode = 'Y' THEN
            AP_Debug_Pkg.Print(g_debug_mode, 'Set Concurrent Request Warning' );
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Set Concurrent Request Warning');
         END IF;
         ---------------------------------------------------------------------

         l_conc_status := 'WARNING';
         --bug 7512258 removed call to FND_CONCURRENT.SET_COMPLETION_STATUS

         ---------------------------------------------------------------------
         --  Print_Debug (l_api_name, 'Begin Single Mode');
         IF g_debug_mode = 'Y' THEN
            AP_Debug_Pkg.Print(g_debug_mode, 'Begin Single Mode' );
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Begin Single Mode');
         END IF;
         ---------------------------------------------------------------------
         --Bug9436217

         OPEN  SELECTED_INVOICES_CURSOR ;
         FETCH SELECTED_INVOICES_CURSOR
         BULK COLLECT INTO l_selected_invoices_cursor ;

         FOR i IN 1..l_selected_invoices_cursor.count

         --Bug9436217

         LOOP

           SAVEPOINT AP_APPROVAL_PKG_SP_INV;

          --Bug9436217
          BEGIN
	  mo_global.set_policy_context('S', l_selected_invoices_cursor(i).org_id);

          --Bug9436217

            ---------------------------------------------------------------------
            --  Print_Debug (l_api_name, 'Calculate Tax');
            IF g_debug_mode = 'Y' THEN
               AP_Debug_Pkg.Print(g_debug_mode, 'Calculate Tax' );
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Calculate Tax');
            END IF;
            ---------------------------------------------------------------------
            l_success := ap_etax_pkg.calling_etax(
                           --Bug9436217
                           p_invoice_id         => l_selected_invoices_cursor(i).invoice_id,
                           --Bug9436217
                           p_calling_mode       => 'CALCULATE',
                           p_all_error_messages => 'N',
                           p_error_code         => l_error_code,
                           p_calling_sequence   => l_curr_calling_sequence);

            IF (NOT l_success) THEN
               RAISE Tax_Exception_Handled;
            END IF;

            ----------------------------------------------------------------
            --  Print_Debug(l_api_name, 'Initialize Invoice Holds Array');
            IF g_debug_mode = 'Y' THEN
               AP_Debug_Pkg.Print(g_debug_mode, 'Initialize Invoice Holds Array' );
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Initialize Invoice Holds Array');
            END IF;
            ----------------------------------------------------------------
            Initialize_Invoice_Holds(
                        --Bug9436217
                        p_invoice_id       => l_selected_invoices_cursor(i).invoice_id,
                        --Bug9436217
                        p_calling_sequence => l_curr_calling_sequence);

            ---------------------------------------------------------------------
            --  Print_Debug (l_api_name, 'Generate Distributions');
            IF g_debug_mode = 'Y' THEN
               AP_Debug_Pkg.Print(g_debug_mode, 'Generate Distributions' );
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Generate Distributions');
            END IF;
            ---------------------------------------------------------------------

            --Bug9436217

            l_invoice_rec.invoice_id               := l_selected_invoices_cursor(i).invoice_id;
            l_invoice_rec.invoice_date             := l_selected_invoices_cursor(i).invoice_date;
            l_invoice_rec.invoice_currency_code    := l_selected_invoices_cursor(i).invoice_currency_code;
            l_invoice_rec.exchange_rate            := l_selected_invoices_cursor(i).exchange_rate;
            l_invoice_rec.exchange_rate_type       := l_selected_invoices_cursor(i).exchange_rate_type;
            l_invoice_rec.exchange_date            := l_selected_invoices_cursor(i).exchange_date;
            l_invoice_rec.vendor_id                := l_selected_invoices_cursor(i).vendor_id;
            l_invoice_rec.org_id                   := l_selected_invoices_cursor(i).org_id;
            g_org_id                               := l_selected_invoices_cursor(i).org_id;

            --Bug9436217


            AP_APPROVAL_PKG.Generate_Distributions
                                (p_invoice_rec        => l_invoice_rec,
                                 --Bug9436217
                                 p_base_currency_code => AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_selected_invoices_cursor(i).org_id).base_currency_code,
                                 --Bug9436217
                                 p_inv_batch_id       => p_inv_batch_id,
                                 p_run_option         => p_run_option,
                                 p_calling_sequence   => l_curr_calling_sequence,
                                 x_error_code         => l_error_code);

            ---------------------------------------------------------------------
            --  Print_Debug (l_api_name, 'Generate Tax Distributions');
            IF g_debug_mode = 'Y' THEN
               AP_Debug_Pkg.Print(g_debug_mode, 'Generate Tax Distributions' );
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Generate Tax Distributions');
            END IF;
            ---------------------------------------------------------------------
            l_success := ap_etax_pkg.calling_etax (
                           --Bug9436217
                           p_invoice_id         => l_selected_invoices_cursor(i).invoice_id,
                           --Bug9436217
                           p_calling_mode       => 'DISTRIBUTE',
                           p_all_error_messages => 'N',
                           p_error_code         => l_error_code,
                           p_calling_sequence   => l_curr_calling_sequence);

            IF (NOT l_success) THEN
               RAISE  Tax_Exception_Handled;
            END IF;

            --Bug9436217
            IF l_selected_invoices_cursor(i).invoice_type_lookup_code = 'PAYMENT REQUEST' THEN
            --Bug9436217
               l_calling_mode := 'PAYMENT REQUEST';
            ELSE
               l_calling_mode := 'APPROVE';
            END IF;

            --Bug9436217
            ---------------------------------------------------------------------
            --  Print_Debug(l_api_name, 'Approving specified invoice : '||l_selected_invoices_cursor(i).invoice_num);
            IF g_debug_mode = 'Y' THEN
               AP_Debug_Pkg.Print(g_debug_mode, 'Approving specified invoice : '||l_selected_invoices_cursor(i).invoice_num );
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Approving specified invoice : '||l_selected_invoices_cursor(i).invoice_num);
            END IF;
            ---------------------------------------------------------------------


            --IF l_validation_request_id = p_conc_request_id THEN

               IF validate_period(l_selected_invoices_cursor(i).invoice_id) THEN
            --Bug9436217
                 -- Cache Templates
                 Cache_Tolerance_Templates(
                        --Bug9436217
                        l_selected_invoices_cursor(i).tolerance_id,
                        l_selected_invoices_cursor(i).services_tolerance_id,
                        --Bug9436217
                        l_calling_sequence);

                   --Removed the hardcoded value of p_budget_control, bug6356402
                   AP_APPROVAL_PKG.APPROVE(
                                '',
                                '',
                                '',
                                '',
                                '',
                                '',
                                --Bug9436217
                                l_selected_invoices_cursor(i).invoice_id,
                                --Bug9436217
                                '',
                                '',
                                '',
                                'Y',
                                l_holds_count,
                                l_approval_status,
                                l_funds_return_code,
                                l_calling_mode,
                                'APXAPRVL',
                                p_debug_switch
                                );
                ELSE
                    fnd_message.set_name('SQLAP', 'AP_INV_NEVER_OPEN_PERIOD');
                    --Bug9436217
                    fnd_message.set_token('INV_NUM', l_selected_invoices_cursor(i).invoice_num);
                    --Bug9436217
                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                END IF;
            --Bug9436217
            --END IF;
	    --Bug9436217
            ---------------------------------------------------------------------
            --  Print_Debug(l_api_name, 'End Approving Single Invoice');
            IF g_debug_mode = 'Y' THEN
               AP_Debug_Pkg.Print(g_debug_mode, 'End Approving Single Invoice' );
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'End Approving Single Invoice');
            END IF;
            ---------------------------------------------------------------------

            EXCEPTION
            WHEN TAX_EXCEPTION_HANDLED THEN

                 ROLLBACK TO SAVEPOINT AP_APPROVAL_PKG_SP_INV;

                  ap_utilities_pkg.ap_get_message(l_approval_error);
                  fnd_file.put_line (fnd_file.log, ' ');
                  --Bug9436217
                  fnd_file.put_line (fnd_file.log, l_approval_error || 'Invoice Validation did not process Invoice Number: '|| l_selected_invoices_cursor(i).invoice_num);
		  --Bug9436217
                  fnd_file.put_line (fnd_file.log, l_error_code); --7392260
                  fnd_file.put_line (fnd_file.log, '  Error: ' ||sqlerrm);
                  --Bug9436217
                  --  Print_Debug (l_api_name, 'Exception: '|| sqlerrm ||' Invoice Validation did not process Invoice Number: '||
                  --                         l_selected_invoices_cursor(i).invoice_num);
                  IF g_debug_mode = 'Y' THEN
                     AP_Debug_Pkg.Print(g_debug_mode, 'Exception: '|| sqlerrm ||' Invoice Validation did not process Invoice Number: '||
                                                      l_selected_invoices_cursor(i).invoice_num);
                  END IF;

                  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Exception: '|| sqlerrm ||' Invoice Validation did not process Invoice Number: '||
                                                                                l_selected_invoices_cursor(i).invoice_num);
                  END IF;
                  --Bug9436217


            WHEN OTHERS THEN

                 ROLLBACK TO SAVEPOINT AP_APPROVAL_PKG_SP_INV;

                  ap_utilities_pkg.ap_get_message(l_approval_error);
                  fnd_file.put_line (fnd_file.log, ' ');
                  --Bug9436217
                  fnd_file.put_line (fnd_file.log, l_approval_error || 'Invoice Validation did not process Invoice Number: '|| l_selected_invoices_cursor(i).invoice_num);
                  --Bug9436217
                  fnd_file.put_line (fnd_file.log, '  Error: ' ||sqlerrm);
                  --Bug9436217
                  --  Print_Debug (l_api_name, 'Exception: '|| sqlerrm ||' Invoice Validation did not process Invoice Number: '||
                  --                         l_selected_invoices_cursor(i).invoice_num);
                  IF g_debug_mode = 'Y' THEN
                     AP_Debug_Pkg.Print(g_debug_mode, 'Exception: '|| sqlerrm ||' Invoice Validation did not process Invoice Number: '||
                                                      l_selected_invoices_cursor(i).invoice_num);
                  END IF;

                  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Exception: '|| sqlerrm ||' Invoice Validation did not process Invoice Number: '||
                                                                                l_selected_invoices_cursor(i).invoice_num);
                  END IF;
                  --Bug9436217

            END;
         END LOOP;

         --Bug9436217

         UPDATE ap_invoices_all
            SET validation_request_id = NULL
          WHERE validation_request_id = AP_APPROVAL_PKG.G_VALIDATION_REQUEST_ID;



         CLOSE SELECTED_INVOICES_CURSOR;

         --Bug9436217

-- bug 7392260: add start
       ELSE -- bulk process succeded.
         -- we might still have errors in few invoices, even though
         -- ebtax returned success status for bulk process.
         -- Eg. control amount not null.
         -- We'll print these msgs to the concurrent log.

	  --bug9738293
	  FOR i in 1..l_r_tx_err.count
		  LOOP

		  fnd_file.put_line (fnd_file.log, l_approval_error
                      || 'Invoice Validation did not process Invoice Id Due to Expected Tax Error :' || l_r_tx_err(i).trx_id
                      || ', Line Number: ' || l_r_tx_err(i).trx_line_id);
             fnd_file.put_line (fnd_file.log, l_r_tx_err(i).message_text);

	      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Invoice Validation did not process Invoice Id Due to Expected Tax Error:'
                      || l_r_tx_err(i).trx_id);
             END IF;
           END LOOP;

	    --bug9738293

         /* DECLARE
           CURSOR c_tx_err is
             SELECT trx_id, trx_line_id, message_text
             FROM zx_errors_gt;
           r_tx_err c_tx_err%rowtype;
         BEGIN
           FOR r_tx_err IN c_tx_err LOOP
             fnd_file.put_line (fnd_file.log, l_approval_error
                      || 'Invoice Validation did not process Invoice Id:' || r_tx_err.trx_id
                      || ', Line Number: ' || r_tx_err.trx_line_id);
             fnd_file.put_line (fnd_file.log, r_tx_err.message_text);
             Print_Debug (l_api_name, ' Invoice Validation did not process Invoice Id: '
                      || r_tx_err.trx_id);
           END LOOP;
         END; */

-- bug 7392260: add end

       END IF; -- Marker 1


       IF l_blk_err = 'N' THEN -- Marker 2

       ---------------------------------------------------------------------
       --  Print_Debug (l_api_name, 'Generate Distributions');
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, 'Generate Distributions' );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Generate Distributions');
       END IF;
       ---------------------------------------------------------------------

       OPEN SELECTED_INVOICES_CURSOR;
       LOOP
         FETCH SELECTED_INVOICES_CURSOR
         BULK COLLECT INTO AP_APPROVAL_PKG.G_SELECTED_INVOICES
         LIMIT l_commit_size;

	 EXIT WHEN SELECTED_INVOICES_CURSOR%NOTFOUND
                   AND AP_APPROVAL_PKG.G_SELECTED_INVOICES.COUNT <= 0;

         FOR i IN 1..AP_APPROVAL_PKG.G_SELECTED_INVOICES.COUNT
         LOOP
             -- Set Policy
             IF AP_APPROVAL_PKG.G_SELECTED_INVOICES(i).org_id <> nvl(l_old_org_id, -3115) THEN

		mo_global.set_policy_context
                        ('S', AP_APPROVAL_PKG.G_SELECTED_INVOICES(i).org_id);

                l_old_org_id := AP_APPROVAL_PKG.G_SELECTED_INVOICES(i).org_id;

             END IF;

	     -- Initialize Invoice Holds Array
	     Initialize_Invoice_Holds(
	                p_invoice_id       => AP_APPROVAL_PKG.G_SELECTED_INVOICES(i).invoice_id,
	                p_calling_sequence => l_curr_calling_sequence);

             g_org_id := AP_APPROVAL_PKG.G_SELECTED_INVOICES(i).org_id;

             AP_APPROVAL_PKG.Generate_Distributions
				(p_invoice_rec        => AP_APPROVAL_PKG.G_SELECTED_INVOICES(i),
				 p_base_currency_code => AP_APPROVAL_PKG.G_OPTIONS_TABLE(g_org_id).base_currency_code,
				 p_inv_batch_id	      => p_inv_batch_id,
				 p_run_option	      => p_run_option,
	                         p_calling_sequence   => l_curr_calling_sequence,
				 x_error_code	      => l_error_code);

         END LOOP;

         AP_APPROVAL_PKG.G_SELECTED_INVOICES.DELETE;

       END LOOP;
       CLOSE SELECTED_INVOICES_CURSOR;

       ---------------------------------------------------------------------
       --  Print_Debug (l_api_name, 'Generate Tax Distributions');
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, 'Generate Tax Distributions' );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Generate Tax Distributions');
       END IF;
       ---------------------------------------------------------------------

       SAVEPOINT AP_APPROVAL_PKG_SP_TAX_DIST;

       --Bug9436217

       FND_FILE.PUT_LINE(FND_FILE.LOG,'(Bulk DISTRIBUTE) START SYSDATE '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

       --Bug9436217

        --bug 9738293
       --Changed the calling method for Bulk tax distributions . ETAX API will be called till there is no
       -- error in ZX error table or they return success.

          LOOP
         delete from zx_errors_gt; --Flusing GT table

       l_success := ap_etax_pkg.calling_etax (
                           p_invoice_id		=> NULL,
                           p_calling_mode	=> 'DISTRIBUTE',
                           p_all_error_messages => 'N',
                           p_error_code 	=> l_error_code,
                           p_calling_sequence 	=> l_curr_calling_sequence);

	OPEN  c_tx_err  ;
         FETCH c_tx_err
		   BULK COLLECT INTO l_r_tx_err;
		   CLOSE c_tx_err;
		EXIT when (l_r_tx_err.count = 0 OR l_success);

                 OPEN  r_inv_err for l_sql_tax_err ;
                FETCH r_inv_err
                 BULK COLLECT INTO l_r_inv_err;
	        CLOSE r_inv_err;


		ROLLBACK TO SAVEPOINT AP_APPROVAL_PKG_SP_TAX_DIST ;





		FORALL i in 1..l_r_inv_err.count
		Update ap_invoices_all set validation_request_id = NULL where invoice_id =  l_r_inv_err(i);

		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Rows updated ' || sql%rowcount);
         	END IF ;


		 l_conc_status := 'WARNING';
             FOR i in 1..l_r_tx_err.count
	     LOOP

	     fnd_file.put_line (fnd_file.log, l_approval_error
                      || 'Invoice Validation did not process Invoice Id Due to Tax Error in Distribution :' || l_r_tx_err(i).trx_id
                      || ', Line Number: ' || l_r_tx_err(i).trx_line_id);
             fnd_file.put_line (fnd_file.log, l_r_tx_err(i).message_text);

	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Invoice Validation did not process Invoice Id Due to Tax Error in Distribution:'
              || l_r_tx_err(i).trx_id);
        END IF;
           END LOOP;

	END LOOP;
	 --bug 9738293

       --Bug9436217

       FND_FILE.PUT_LINE(FND_FILE.LOG,'(Bulk DISTRIBUTE) END SYSDATE '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

       --Bug9436217


       IF (NOT l_success) THEN  -- Marker 3

         ROLLBACK TO SAVEPOINT AP_APPROVAL_PKG_SP_TAX_DIST;

         ---------------------------------------------------------------------
         --  Print_Debug (l_api_name, 'Set Concurrent Request Warning');
         IF g_debug_mode = 'Y' THEN
            AP_Debug_Pkg.Print(g_debug_mode, 'Set Concurrent Request Warning' );
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Set Concurrent Request Warning');
         END IF;
         ---------------------------------------------------------------------

         l_conc_status := 'WARNING';

         --Bug9436217

         l_blk_err_dist := 'Y';

         --Bug9436217

         --bug 7512258 removed call to FND_CONCURRENT.SET_COMPLETION_STATUS

         ---------------------------------------------------------------------
         --  Print_Debug (l_api_name, 'Begin Single Mode');
         IF g_debug_mode = 'Y' THEN
            AP_Debug_Pkg.Print(g_debug_mode, 'Begin Single Mode' );
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Begin Single Mode');
         END IF;
         ---------------------------------------------------------------------

         --Bug9436217

         l_selected_invoices_cursor.DELETE ;
         OPEN  SELECTED_INVOICES_CURSOR ;
         FETCH SELECTED_INVOICES_CURSOR
         BULK COLLECT INTO l_selected_invoices_cursor ;

         FOR i IN 1..l_selected_invoices_cursor.COUNT LOOP

         --Bug9436217

             SAVEPOINT AP_APPROVAL_PKG_SP_TAX_DIST;

	     BEGIN
                --Bug9436217
                mo_global.set_policy_context('S',l_selected_invoices_cursor(i).org_id);
                --Bug9436217


             --Bug9436217
             ---------------------------------------------------------------------
             --  Print_Debug (l_api_name, 'Generate Tax Distributions: '||l_selected_invoices_cursor(i).invoice_id);
             IF g_debug_mode = 'Y' THEN
                AP_Debug_Pkg.Print(g_debug_mode, 'Generate Tax Distributions: '||l_selected_invoices_cursor(i).invoice_id );
             END IF;

             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Generate Tax Distributions: '||l_selected_invoices_cursor(i).invoice_id);
             END IF;
             ---------------------------------------------------------------------
             --Bug9436217
             l_success := ap_etax_pkg.calling_etax (
                            --Bug9436217
                            p_invoice_id         => l_selected_invoices_cursor(i).invoice_id,
                            --Bug9436217
                            p_calling_mode       => 'DISTRIBUTE',
                            p_all_error_messages => 'N',
                            p_error_code         => l_error_code,
                            p_calling_sequence   => l_curr_calling_sequence);

             IF (NOT l_success) THEN
                 RAISE  Tax_Dist_Exception_Handled;
             END IF;
			--Bug 7509921
            --Bug9436217
            IF l_selected_invoices_cursor(i).invoice_type_lookup_code = 'PAYMENT REQUEST' THEN
            --Bug9436217
               l_calling_mode := 'PAYMENT REQUEST';
            ELSE
               l_calling_mode := 'APPROVE';
            END IF;


            --Bug9436217
            ---------------------------------------------------------------------
            --  Print_Debug(l_api_name, 'Approving specified invoice : '||l_selected_invoices_cursor(i).invoice_num);
            IF g_debug_mode = 'Y' THEN
               AP_Debug_Pkg.Print(g_debug_mode, 'Approving specified invoice : '||l_selected_invoices_cursor(i).invoice_num );
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Approving specified invoice : '||l_selected_invoices_cursor(i).invoice_num);
            END IF;
            ---------------------------------------------------------------------
            --Bug9436217

            --Bug9436217
            --IF l_validation_request_id = p_conc_request_id THEN
            --Bug9436217

               --Bug9436217
               IF validate_period(l_selected_invoices_cursor(i).invoice_id) THEN
               --Bug9436217

                 -- Cache Templates
                 Cache_Tolerance_Templates(
                        --Bug9436217
                        l_selected_invoices_cursor(i).tolerance_id,
                        l_selected_invoices_cursor(i).services_tolerance_id,
                        --Bug9436217
                        l_calling_sequence);

                   --Removed the hardcoded value of p_budget_control, bug6356402
                   AP_APPROVAL_PKG.APPROVE(
                                '',
                                '',
                                '',
                                '',
                                '',
                                '',
                                --Bug9436217
                                l_selected_invoices_cursor(i).invoice_id,
                                --Bug9436217
                                '',
                                '',
                                '',
                                'Y',
                                l_holds_count,
                                l_approval_status,
                                l_funds_return_code,
                                l_calling_mode,
                                'APXAPRVL',
                                p_debug_switch
                                );
                ELSE
                    fnd_message.set_name('SQLAP', 'AP_INV_NEVER_OPEN_PERIOD');
                    --Bug9436217
                    fnd_message.set_token('INV_NUM', l_selected_invoices_cursor(i).invoice_num);
                    --Bug9436217
                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                END IF;
            --Bug9436217
            --END IF;
            --Bug9436217
           ---------------------------------------------------------------------
            --  Print_Debug(l_api_name, 'End Approving Single Invoice');
            IF g_debug_mode = 'Y' THEN
               AP_Debug_Pkg.Print(g_debug_mode,  'End Approving Single Invoice' );
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'End Approving Single Invoice');
            END IF;
            ---------------------------------------------------------------------


           EXCEPTION
             WHEN TAX_DIST_EXCEPTION_HANDLED THEN

                  ROLLBACK TO SAVEPOINT AP_APPROVAL_PKG_SP_TAX_DIST;

                  ap_utilities_pkg.ap_get_message(l_approval_error);

                  fnd_file.put_line (fnd_file.log, ' ');

                  --Bug9436217

                  fnd_file.put_line (fnd_file.log, l_approval_error || 'Invoice Validation did not process Invoice Number: '||
                                           l_selected_invoices_cursor(i).invoice_num);
                  --Bug9436217

                  fnd_file.put_line (fnd_file.log, l_error_code); --7392260
                  fnd_file.put_line (fnd_file.log, '  Error: ' ||sqlerrm);

                  --Bug9436217

                  --  Print_Debug (l_api_name, 'Exception: '|| sqlerrm ||' Invoice Validation did not process Invoice Number: '||
                  --                         l_selected_invoices_cursor(i).invoice_num);
                  IF g_debug_mode = 'Y' THEN
                     AP_Debug_Pkg.Print(g_debug_mode, 'Exception: '|| sqlerrm ||' Invoice Validation did not process Invoice Number: '||
                                                      l_selected_invoices_cursor(i).invoice_num );
                  END IF;

                  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Exception: '|| sqlerrm ||' Invoice Validation did not process Invoice Number: '||
                                                                                 l_selected_invoices_cursor(i).invoice_num);
                  END IF;

                  --Bug9436217

             WHEN OTHERS THEN

                 ROLLBACK TO SAVEPOINT AP_APPROVAL_PKG_SP_TAX_DIST;

                 ap_utilities_pkg.ap_get_message(l_approval_error);

                 fnd_file.put_line (fnd_file.log, ' ');

                 --Bug9436217

                 fnd_file.put_line (fnd_file.log, l_approval_error || 'Invoice Validation did not process Invoice Number: '||
                                           l_selected_invoices_cursor(i).invoice_num);

                 --Bug9436217


                 fnd_file.put_line (fnd_file.log, '  Error: ' ||sqlerrm);

                 --Bug9436217

                 --  Print_Debug (l_api_name, 'Exception: '|| sqlerrm ||' Invoice Validation did not process Invoice Number: '||
                 --                          l_selected_invoices_cursor(i).invoice_num);
                  IF g_debug_mode = 'Y' THEN
                     AP_Debug_Pkg.Print(g_debug_mode, 'Exception: '|| sqlerrm ||' Invoice Validation did not process Invoice Number: '||
                                                      l_selected_invoices_cursor(i).invoice_num );
                  END IF;

                  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Exception: '|| sqlerrm ||' Invoice Validation did not process Invoice Number: '||
                                                                                 l_selected_invoices_cursor(i).invoice_num);
                  END IF;

                 --Bug9436217

           END;
         END LOOP;

         --Bug9436217

         UPDATE ap_invoices_all
            SET validation_request_id = NULL
          WHERE validation_request_id = AP_APPROVAL_PKG.G_VALIDATION_REQUEST_ID;

         CLOSE SELECTED_INVOICES_CURSOR ;

         --Bug9436217

-- bug 7392260: add start
       ELSE -- bulk process succeded.
         -- we might still have errors in few invoices, even though
         -- ebtax returned success status for bulk process.
         -- Eg. control amount not null.
         -- We'll print these msgs to the concurrent log.

	  --bug9738293
	 FOR i in 1..l_r_tx_err.count
		  LOOP

		  fnd_file.put_line (fnd_file.log, l_approval_error
                      || 'Invoice Validation did not process Invoice Id Due to Expected Tax Error in Distribution :' || l_r_tx_err(i).trx_id
                      || ', Line Number: ' || l_r_tx_err(i).trx_line_id);
             fnd_file.put_line (fnd_file.log, l_r_tx_err(i).message_text);

	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Invoice Validation did not process Invoice Id Due to Expected Tax Error in Distribution:'
              || l_r_tx_err(i).trx_id);
        END IF;
           END LOOP;

	  --bug9738293

         /* DECLARE
           CURSOR c_tx_err is
             SELECT trx_id, trx_line_id, message_text
             FROM zx_errors_gt;
           r_tx_err c_tx_err%rowtype;
         BEGIN
           FOR r_tx_err IN c_tx_err LOOP
             fnd_file.put_line (fnd_file.log, l_approval_error
                      || 'Invoice Validation did not process Invoice Id:' || r_tx_err.trx_id
                      || ', Line Number: ' || r_tx_err.trx_line_id);
             fnd_file.put_line (fnd_file.log, r_tx_err.message_text);
             Print_Debug (l_api_name, ' Invoice Validation did not process Invoice Id: '
                      || r_tx_err.trx_id);
           END LOOP;
         END; */

-- bug 7392260: add end

       END IF; -- Marker 3

       ---------------------------------------------------------------------
       --  Print_Debug (l_api_name, 'Call Approve per invoice');
       IF g_debug_mode = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_mode, 'Call Approve per invoice' );
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Call Approve per invoice');
       END IF;
       ---------------------------------------------------------------------

       --Bug9436217
       IF l_blk_err_dist = 'N' THEN   --Marker 4
       AP_APPROVAL_PKG.G_SELECTED_INVOICES.DELETE;
       --Bug9436217
       OPEN SELECTED_INVOICES_CURSOR;
       LOOP
         FETCH SELECTED_INVOICES_CURSOR
         BULK COLLECT INTO AP_APPROVAL_PKG.G_SELECTED_INVOICES
         LIMIT l_commit_size;

         EXIT WHEN SELECTED_INVOICES_CURSOR%NOTFOUND
                   and AP_APPROVAL_PKG.G_SELECTED_INVOICES.COUNT <= 0;

         FOR i IN 1..AP_APPROVAL_PKG.G_SELECTED_INVOICES.COUNT LOOP

           -- Set Policy
           IF AP_APPROVAL_PKG.G_SELECTED_INVOICES(i).org_id <> nvl(l_old_org_id, -3115) THEN

              mo_global.set_policy_context('S', AP_APPROVAL_PKG.G_SELECTED_INVOICES(i).org_id);

              l_old_org_id := AP_APPROVAL_PKG.G_SELECTED_INVOICES(i).org_id;

           END IF;

           -- Set Calling Mode
           IF AP_APPROVAL_PKG.G_SELECTED_INVOICES(i).invoice_type_lookup_code = 'PAYMENT REQUEST' THEN
              l_calling_mode := 'PAYMENT REQUEST';
           ELSE
              l_calling_mode := 'APPROVE';

               -- Cache Templates
               Cache_Tolerance_Templates(
	                AP_APPROVAL_PKG.G_SELECTED_INVOICES(i).tolerance_id,
	                AP_APPROVAL_PKG.G_SELECTED_INVOICES(i).services_tolerance_id,
	                l_calling_sequence);
           END IF;

           -- Call Approve
           IF validate_period(
	               AP_APPROVAL_PKG.G_SELECTED_INVOICES(i).invoice_id) THEN

               --Removed the hardcoded value of p_budget_control, bug6356402
               AP_APPROVAL_PKG.approve(
				'',
	                        '',
  				'',
				'',
				'',
				'',
				AP_APPROVAL_PKG.G_SELECTED_INVOICES(i).invoice_id,
				'',
				'',
				'',
				'Y',
				l_holds_count,
				l_approval_status,
	                        l_funds_return_code,
				l_calling_mode,
				'APXAPRVL',
	                        p_debug_switch
	                        );

           ELSE
              fnd_message.set_name('SQLAP', 'AP_INV_NEVER_OPEN_PERIOD');
              fnd_message.set_token('INV_NUM',  AP_APPROVAL_PKG.G_SELECTED_INVOICES(i).invoice_num);
              fnd_file.put_line(fnd_file.log, fnd_message.get);
           END IF;

         END LOOP;

         --Bug9436217

         FORALL blk_upd IN 1..l_selected_invoice_ids.COUNT
	      UPDATE ap_invoices_all
	         SET validation_request_id = NULL
	       WHERE invoice_id = l_selected_invoice_ids( blk_upd )
             AND validation_request_id IS NOT NULL;

         --Bug9436217

	 AP_APPROVAL_PKG.G_SELECTED_INVOICES.DELETE;

       END LOOP;

       CLOSE SELECTED_INVOICES_CURSOR;

    --Bug9436217
    END IF ;  --Marker 4
    --Bug9436217
    END IF; -- Marker 2

    END IF; -- Marker 0

    ---------------------------------------------------------------------
    --  Print_Debug (l_api_name, 'Populate ap_temp_approval_temp_gt');
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, 'Populate ap_temp_approval_temp_gt' );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Populate ap_temp_approval_temp_gt');
    END IF;
    ---------------------------------------------------------------------

    DELETE FROM ap_temp_approval_gt;

    FORALL i in g_org_holds.first..g_org_holds.last
	INSERT INTO ap_temp_approval_gt VALUES g_org_holds(i);

    COMMIT;

    ---------------------------------------------------------------------
    --  Print_Debug (l_api_name, 'Get the count of rows that will be printed');
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, 'Get the count of rows that will be printed' );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Get the count of rows that will be printed');
    END IF;
    ---------------------------------------------------------------------

    SELECT count(*) into  p_report_holds_count
      FROM ap_temp_approval_gt
     WHERE number_holds_placed   <> 0
        OR number_holds_released <> 0;

    -- 7512258
    -- moved the call to end of the approval process
    ---------------------------------------------------------------------
    --  Print_Debug (l_api_name, 'Set Concurrent Request Warning');
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, 'Set Concurrent Request Warning' );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Set Concurrent Request Warning');
    END IF;
    ---------------------------------------------------------------------
    IF l_conc_status = 'WARNING' THEN
       l_errbuf := 'Warning/Error message to be displayed';
       l_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS(l_conc_status,l_errbuf);
    END IF;


    ---------------------------------------------------------------------
    --  Print_Debug(l_api_name, 'AP_APPROVAL_PKG.BATCH_APPROVAL.END');
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, 'AP_APPROVAL_PKG.BATCH_APPROVAL.END' );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'AP_APPROVAL_PKG.BATCH_APPROVAL.END');
    END IF;
    ---------------------------------------------------------------------

    RETURN(TRUE);

EXCEPTION

	WHEN TAX_EXCEPTION THEN
             AP_UTILITIES_PKG.AP_GET_MESSAGE(l_approval_error);
             fnd_file.put_line(fnd_file.log,l_approval_error);
             fnd_file.put_line(fnd_file.log,sqlerrm);
             --  Print_Debug(l_api_name, 'Exception: '||sqlerrm);
	     IF g_debug_mode = 'Y' THEN
                AP_Debug_Pkg.Print(g_debug_mode, 'Exception: '||sqlerrm );
             END IF;

             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Exception: '||sqlerrm);
             END IF;

             --Bug7246971

             FND_MESSAGE.SET_NAME('SQLAP','AP_TAX_EXCEPTION');
             IF l_error_code IS NOT NULL THEN
                FND_MESSAGE.SET_TOKEN('ERROR', l_error_code);
             ELSE
                FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
             END IF;
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      'Run Option  = '|| p_run_option
	              ||', Batch Id = '|| to_char(p_inv_batch_id)
	              ||', Begin Date = '|| to_char(p_inv_start_date)
	              ||', End Date = '|| to_char(p_inv_end_date)
	              ||', Vendor Id = '|| to_char(p_vendor_id)
	              ||', Pay Group = '|| p_pay_group
	              ||', Invoice Id = '|| to_char(p_invoice_id)
	              ||', Entered By = '|| to_char(p_entered_by)
	              ||', Concurrent Request Id = '|| to_char(p_conc_request_id)
                      ||', Org Id = '|| to_char(p_org_id));
             APP_EXCEPTION.RAISE_EXCEPTION;

             --Bug7246971

             RETURN (FALSE);

	WHEN OTHERS THEN
	     AP_UTILITIES_PKG.AP_GET_MESSAGE(l_approval_error);
	     fnd_file.put_line(fnd_file.log,l_approval_error);
	     fnd_file.put_line(fnd_file.log,sqlerrm);
             --  Print_Debug(l_api_name, 'Others: Exception: '||sqlerrm);
	     IF g_debug_mode = 'Y' THEN
                AP_Debug_Pkg.Print(g_debug_mode, 'Others: Exception: '||sqlerrm );
             END IF;

             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Others: Exception: '||sqlerrm);
             END IF;

             --Bug7246971

             IF (SQLCODE <> -20001) THEN
                FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
                FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
                FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
                FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      'Run Option  = '|| p_run_option
	              ||', Batch Id = '|| to_char(p_inv_batch_id)
	              ||', Begin Date = '|| to_char(p_inv_start_date)
	              ||', End Date = '|| to_char(p_inv_end_date)
	              ||', Vendor Id = '|| to_char(p_vendor_id)
	              ||', Pay Group = '|| p_pay_group
	              ||', Invoice Id = '|| to_char(p_invoice_id)
	              ||', Entered By = '|| to_char(p_entered_by)
	              ||', Concurrent Request Id = '|| to_char(p_conc_request_id)
                      ||', Org Id = '|| to_char(p_org_id));

             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

             --Bug7246971

	     RETURN (FALSE);

END BATCH_APPROVAL;

PROCEDURE Cache_Options
            (p_calling_sequence              IN VARCHAR2) IS

    CURSOR C_Options_Query IS
    SELECT  nvl(gls.chart_of_accounts_id, -1) chart_of_accounts_id,
            nvl(sp.set_of_books_id, -1) set_of_books_id,
            nvl(sp.automatic_offsets_flag, 'N') automatic_offsets_flag,
            nvl(recalc_pay_schedule_flag, 'N') recalc_pay_schedule_flag,
            sp.liability_post_lookup_code liability_post_lookup_code,
            nvl(sp.rate_var_gain_ccid, -1) rate_var_gain_ccid,
            nvl(sp.rate_var_loss_ccid, -1) rate_var_loss_ccid,
            nvl(sp.base_currency_code, 'USD') base_currency_code,
            nvl(sp.match_on_tax_flag, 'N') match_on_tax_flag,
            nvl(sp.enforce_tax_from_account, 'N') enforce_tax_from_account,
            nvl(fp.inv_encumbrance_type_id, -1) inv_encumbrance_type_id,
            nvl(fp.purch_encumbrance_type_id, -1) purch_encumbrance_type_id,
            nvl(fp.receipt_acceptance_days, 0) receipt_acceptance_days,
            nvl(gl_date_from_receipt_flag, 'S') gl_date_from_receipt_flag,
            accounting_method_option,
            secondary_accounting_method,
            nvl(fp.cash_basis_enc_nr_tax, 'EXCLUDE RECOVERABLE TAX') cash_basis_enc_nr_tax,
            nvl(fp.non_recoverable_tax_flag, 'N') non_recoverable_tax_flag,
            nvl(disc_is_inv_less_tax_flag,'N') disc_is_inv_less_tax_flag,
            fp.org_id org_id,
            5 System_User,
            fnd_global.user_id User_Id
    FROM    ap_system_parameters_all sp,
            financials_system_params_all fp,
            gl_sets_of_books gls,
            Mo_Glob_Org_Access_Tmp mo
    WHERE   sp.set_of_books_id = gls.set_of_books_id
    AND     sp.org_id = fp.org_id
    AND     mo.organization_id = fp.org_id;

    l_options_rec C_Options_Query%rowtype;

    l_debug_loc	 		VARCHAR2(30) 	:= 'Cache_Options';
    l_curr_calling_sequence	VARCHAR2(2000);
    l_debug_info		VARCHAR2(1000);
  BEGIN

    l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||p_calling_sequence;

    ------------------------------------------------------------
    l_debug_info := 'Retrieving system parameters for approval';
    --  Print_Debug(l_debug_loc,l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;
    ------------------------------------------------------------

     OPEN C_Options_Query;
     LOOP
       FETCH C_Options_Query INTO l_options_rec;
       EXIT WHEN C_Options_Query%NOTFOUND;

         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).chart_of_accounts_id
          := l_options_rec.chart_of_accounts_id;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).set_of_books_id
          := l_options_rec.set_of_books_id;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).automatic_offsets_flag
          := l_options_rec.automatic_offsets_flag;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).recalc_pay_schedule_flag
          := l_options_rec.recalc_pay_schedule_flag;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).liability_post_lookup_code
          := l_options_rec.liability_post_lookup_code;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).rate_var_gain_ccid
          := l_options_rec.rate_var_gain_ccid;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).rate_var_loss_ccid
          := l_options_rec.rate_var_loss_ccid;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).base_currency_code
          := l_options_rec.base_currency_code;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).match_on_tax_flag
          := l_options_rec.match_on_tax_flag;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).enforce_tax_from_account
          := l_options_rec.enforce_tax_from_account;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).inv_encumbrance_type_id
          := l_options_rec.inv_encumbrance_type_id;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).purch_encumbrance_type_id
          := l_options_rec.purch_encumbrance_type_id;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).receipt_acceptance_days
          := l_options_rec.receipt_acceptance_days;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).gl_date_from_receipt_flag
          := l_options_rec.gl_date_from_receipt_flag;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).accounting_method_option
          := l_options_rec.accounting_method_option;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).secondary_accounting_method
          := l_options_rec.secondary_accounting_method;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).cash_basis_enc_nr_tax
          := l_options_rec.cash_basis_enc_nr_tax;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).non_recoverable_tax_flag
          := l_options_rec.non_recoverable_tax_flag;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).disc_is_inv_less_tax_flag
          := l_options_rec.disc_is_inv_less_tax_flag;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).org_id
          := l_options_rec.org_id;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).System_User
          := l_options_rec.System_User;
         AP_APPROVAL_PKG.G_OPTIONS_TABLE(l_options_rec.org_id).user_id
          := l_options_rec.user_id;

     END LOOP;
     CLOSE C_Options_Query;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      IF C_Options_Query%ISOPEN THEN
         CLOSE C_Options_Query;
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Cache_Options;


PROCEDURE Cache_Tolerance_Templates
            ( p_tolerance_id                  IN NUMBER,
              p_services_tolerance_id         IN NUMBER,
              p_calling_sequence              IN VARCHAR2) IS
    l_debug_loc	 		VARCHAR2(30) 	:= 'Cache_Tolerance_Templates';
    l_curr_calling_sequence	VARCHAR2(2000);
    l_debug_info		VARCHAR2(1000);
  BEGIN

    l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||p_calling_sequence;

    ------------------------------------------------------------
    l_debug_info := 'Retrieving Supplier Site Tolerances';
    --  Print_Debug(l_debug_loc,l_debug_info);
    IF g_debug_mode = 'Y' THEN
       AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
    END IF;
    ------------------------------------------------------------

    IF p_tolerance_id IS NOT NULL THEN

       IF NOT G_GOODS_TOLERANCES.exists(p_tolerance_id) THEN

          SELECT decode( price_tolerance, NULL, NULL,
                    (1 + (price_tolerance/100))),
                 decode(quantity_tolerance, NULL, NULL,
                    (1 + (quantity_tolerance/100))),
                 decode( qty_received_tolerance, NULL, NULL,
                   (1 + (qty_received_tolerance/100))),
                 max_qty_ord_tolerance,
                 max_qty_rec_tolerance,
                 ship_amt_tolerance,
                 rate_amt_tolerance,
                 total_amt_tolerance
          INTO   G_GOODS_TOLERANCES(p_tolerance_id).price_tolerance,
                 G_GOODS_TOLERANCES(p_tolerance_id).quantity_tolerance,
                 G_GOODS_TOLERANCES(p_tolerance_id).qty_received_tolerance,
                 G_GOODS_TOLERANCES(p_tolerance_id).max_qty_ord_tolerance,
                 G_GOODS_TOLERANCES(p_tolerance_id).max_qty_rec_tolerance,
                 G_GOODS_TOLERANCES(p_tolerance_id).ship_amt_tolerance,
                 G_GOODS_TOLERANCES(p_tolerance_id).rate_amt_tolerance,
                 G_GOODS_TOLERANCES(p_tolerance_id).total_amt_tolerance
          FROM   ap_tolerance_templates
          WHERE  tolerance_id = p_tolerance_id;

       END IF;
    END IF;

    IF p_services_tolerance_id IS NOT NULL THEN
       IF NOT G_SERVICES_TOLERANCES.exists(p_services_tolerance_id) THEN
          SELECT decode(quantity_tolerance, NULL, NULL,
                    (1 + (quantity_tolerance/100))),
                 decode( qty_received_tolerance, NULL, NULL,
                   (1 + (qty_received_tolerance/100))),
                 max_qty_ord_tolerance,
                 max_qty_rec_tolerance,
                 ship_amt_tolerance,
                 rate_amt_tolerance,
                 total_amt_tolerance
          INTO   G_SERVICES_TOLERANCES(p_services_tolerance_id).amount_tolerance,
                 G_SERVICES_TOLERANCES(p_services_tolerance_id).amt_received_tolerance,
                 G_SERVICES_TOLERANCES(p_services_tolerance_id).max_amt_ord_tolerance,
                 G_SERVICES_TOLERANCES(p_services_tolerance_id).max_amt_rec_tolerance,
                 G_SERVICES_TOLERANCES(p_services_tolerance_id).ser_ship_amt_tolerance,
                 G_SERVICES_TOLERANCES(p_services_tolerance_id).ser_rate_amt_tolerance,
                 G_SERVICES_TOLERANCES(p_services_tolerance_id).ser_total_amt_tolerance
          FROM   ap_tolerance_templates
          WHERE  tolerance_id = p_services_tolerance_id;
       END IF;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
END Cache_Tolerance_Templates;

PROCEDURE Generate_Distributions
                (p_invoice_rec      	IN AP_APPROVAL_PKG.Invoice_Rec,
		 p_base_currency_code	IN VARCHAR2,
		 p_inv_batch_id	    	IN NUMBER,
                 p_run_option       	IN VARCHAR2,
                 p_calling_sequence 	IN VARCHAR2,
                 x_error_code       	IN VARCHAR2,
		 p_calling_mode         IN VARCHAR2  ) IS     /*bug 6833543 - added p_calling_mode*/

  t_inv_lines_table             AP_INVOICES_PKG.t_invoice_lines_table;

  l_curr_calling_sequence       VARCHAR2(2000);
  l_debug_info		  	VARCHAR2(2000);
  l_debug_loc                   VARCHAR2(30) := 'Generate_Distributions';

  l_prorate_across_all_items    VARCHAR2(1);
  l_error_code                  VARCHAR2(4000);
  l_debug_context               VARCHAR2(2000);
  l_success                     BOOLEAN;

  l_system_user                 NUMBER := 5;

  l_holds                       HOLDSARRAY;
  l_hold_count                  COUNTARRAY;
  l_release_count               COUNTARRAY;
  l_insufficient_data_exist     BOOLEAN := FALSE;

  l_recouped_amount             NUMBER;
  l_retained_amount		NUMBER;
  l_result                      BOOLEAN;

  l_line_variance_hold_exist    BOOLEAN := FALSE;
  l_need_to_round_flag          VARCHAR2(1) := 'Y';

  l_not_exist_nond_line         VARCHAR2(1);   --bug6783517
  l_disc_chrge_line             NUMBER := 0;   --bug8820542

  -- bug6783517 starts
  CURSOR dist_gen_holds(p_invoice_id NUMBER)
      IS
  SELECT hold_lookup_code
    FROM ap_holds_all
   WHERE hold_lookup_code IN ('DISTRIBUTION SET INACTIVE',
                              'SKELETON DISTRIBUTION SET',
                              'CANNOT OVERLAY ACCOUNT',
                              'INVALID DEFAULT ACCOUNT',
                              'CANNOT EXECUTE ALLOCATION',
                              'CANNOT OVERLAY ACCOUNT',
                              'INVALID DEFAULT ACCOUNT',
                              'PERIOD CLOSED',
                              'PROJECT GL DATE CLOSED')
     AND release_lookup_code IS NULL
     AND invoice_id = p_invoice_id;

  TYPE holds_tab_type IS
  TABLE OF AP_HOLDS_ALL.HOLD_LOOKUP_CODE%TYPE
  INDEX BY BINARY_INTEGER;

  t_holds_tab                    holds_tab_type;
  -- bug6783517 ends

BEGIN

      l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||p_calling_sequence;

      ----------------------------------------------------------------
      l_debug_info := 'Check Line Variance at invoice header level';
      --  Print_Debug(l_debug_loc, l_debug_info);
      IF g_debug_mode = 'Y' THEN
         AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
      END IF;

      ----------------------------------------------------------------

      Check_Line_Variance(
          p_invoice_rec.invoice_id,
          l_system_user,
          l_holds,
          l_hold_count,
          l_release_count,
          l_line_variance_hold_exist,
          l_curr_calling_sequence,
	  p_base_currency_code);        --bug 7271262

      IF ( p_invoice_rec.invoice_currency_code <> p_base_currency_code ) THEN

        ----------------------------------------------------------------
        l_debug_info := 'Calculate Base Amount. Round if no line variance';
        --  Print_Debug(l_debug_loc, l_debug_info);
        IF g_debug_mode = 'Y' THEN
           AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
        END IF;

        ----------------------------------------------------------------

        IF ( l_line_variance_hold_exist ) THEN
          l_need_to_round_flag := 'N';
        END IF;

        Line_Base_Amount_Calculation(
            p_invoice_id            => p_invoice_rec.invoice_id,
            p_invoice_currency_code => p_invoice_rec.invoice_currency_code,
            p_base_currency_code    => p_base_currency_code,
            p_exchange_rate         => p_invoice_rec.exchange_rate,
            p_need_to_round_flag    => l_need_to_round_flag,
            p_calling_sequence      => l_curr_calling_sequence);

      END IF;

      ----------------------------------------------------------------
      l_debug_info := 'Bulk Collect Invoice Lines';
      --  Print_Debug(l_debug_loc, l_debug_info);
      IF g_debug_mode = 'Y' THEN
         AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
      END IF;
      ----------------------------------------------------------------

      OPEN  Invoice_Line_Cur (p_invoice_rec.invoice_id);
      FETCH Invoice_Line_Cur BULK COLLECT
      INTO  t_inv_lines_table;
      CLOSE Invoice_Line_Cur;

      /* There are some holds which are put on the invoice when */
      /* the distributions are generated for the Invoice        */
      /* But even after the fix in the bug6731107, if a distribution */
      /* is inserted for the Invoice, then the generate_dist flag */
      /* for the line is set to 'D', and hence the code         */
      /* Execute_Dist_Generation_Check would no longer be called */
      /*
      /* As such, when there are no lines on the invoice         */
      /* for which the generate_dist flag is NOT 'D' then we would */
      /* release all the holds on the Invoice which are put during */
      /* the dist generation process : bug6783517 */


      l_debug_info := 'Checking if there exists a non d line';

      BEGIN

        SELECT 'Y'
          INTO l_not_exist_nond_line
          FROM ap_invoice_lines_all ail
         WHERE ail.invoice_id     = p_invoice_rec.invoice_id
           AND nvl(ail.generate_dists, 'N') <> 'D'
           AND rownum < 2;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           l_not_exist_nond_line := 'N';

      END;

       /*bug 6833543: While cancelling an invoice that has a non D line
        and postable hold which is not user releasable like CANNOT EXECUTE
	ALLOCATION, the code failed to release the holds
	and the invoice gets stuck in a semi-cancelled state.Fix of
	6783517 has to take care of releasing holds in such scenario i.e
	when p_calling_mode is CANCEL*/

        --Bug8820542
        BEGIN
        SELECT COUNT(1)
          INTO l_disc_chrge_line
          FROM ap_invoice_lines_all ail
         WHERE ail.invoice_id    = p_invoice_rec.invoice_id
            AND ail.line_type_lookup_code in ('FREIGHT','MISCELLANEOUS')
            AND nvl(ail.prorate_across_all_items,'N') = 'Y'
            AND nvl(ail.discarded_flag,'N') ='Y'
            AND EXISTS (SELECT 1
                          FROM ap_holds_all aha
                         WHERE aha.invoice_id = ail.invoice_id
                           AND aha.hold_lookup_code = 'CANNOT EXECUTE ALLOCATION'
                           AND aha.release_reason IS NULL
                           AND aha.release_lookup_code IS NULL);
        END;
        --Bug8820542

      l_debug_info := 'If there is no non d line or p_calling_mode is CANCEL, then fetch all the dist gen holds';

      IF (l_not_exist_nond_line = 'N' OR p_calling_mode = 'CANCEL' OR l_disc_chrge_line > 0) THEN --Bug8820542
        OPEN  dist_gen_holds (p_invoice_rec.invoice_id);
        FETCH dist_gen_holds BULK COLLECT INTO t_holds_tab;
        CLOSE dist_gen_holds;
      END IF;

      l_debug_info := 'Release all the non D holds';

      IF nvl(t_holds_tab.count, 0) > 0 THEN

        FOR i IN NVL(t_holds_tab.first,0)..NVL(t_holds_tab.last,0)
        LOOP

          l_debug_info := 'Inside the loop';

          Process_Inv_Hold_Status(
             p_invoice_rec.invoice_id,
             null,
             null,
             t_holds_tab(i),
             'N',
             null,
             l_system_user,
             l_holds,
             l_hold_count,
             l_release_count,
             l_curr_calling_sequence);

        END LOOP;

     END IF;
    /* bug 6783517 ends */

  -- Perf 6759699
  -- If the p_run_option is not new then the below function will be
  -- called once for a invoice id.

          IF ( nvl(t_inv_lines_table.count,0) <> 0 AND
               (nvl(p_run_option,'Yes') <> 'New' ))THEN

             Update_Inv_Dists_To_Selected( p_invoice_rec.invoice_id,
                                           null ,
                                           p_run_option,
                                           l_curr_calling_sequence);
          End IF; -- 6759699

      FOR i IN NVL(t_inv_lines_table.first,0)..NVL(t_inv_lines_table.last,0)
      LOOP
       IF (t_inv_lines_table.exists(i)) THEN

           IF t_inv_lines_table(i).line_type_lookup_code in
                          ('FREIGHT', 'MISCELLANEOUS') THEN

	        ----------------------------------------------------------------
                l_debug_info := 'Create charge allocations ';
                --  Print_Debug(l_debug_loc, l_debug_info);
		IF g_debug_mode = 'Y' THEN
		   AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
		END IF;

		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
		END IF;
                ----------------------------------------------------------------

           	SELECT nvl(prorate_across_all_items,'N')
	          INTO l_prorate_across_all_items
                  FROM ap_invoice_lines_all
                 WHERE invoice_id  = t_inv_lines_table(i).invoice_id
                   AND line_number = t_inv_lines_table(i).line_number;

		IF (l_prorate_across_all_items='Y') then

		    l_success := AP_ALLOCATION_RULES_PKG.Create_Proration_Rule(
					t_inv_lines_table(i).invoice_id,
					t_inv_lines_table(i).line_number,
					NULL,
					'APAPRVLB',
					l_error_code,
					l_debug_info,
					l_debug_context,
					'Execute_Dist_Generation_Check');

		END IF;
           END IF;

           -- Bug fix : 6731107: Added 'D' to the below if stmt
           IF (t_inv_lines_table(i).generate_dists IN ('D' , 'Y') ) THEN
--Bug 8346277
	       IF t_inv_lines_table(i).line_type_lookup_code <> 'TAX'
                 AND t_inv_lines_table(i).line_type_lookup_code <> 'AWT' THEN


		  ----------------------------------------------------------------
                  l_debug_info := 'Check Insufficient Line Info: Number and Type: '||
                                  t_inv_lines_table(i).line_number ||' and '||
                                  t_inv_lines_table(i).line_type_lookup_code;
                  --  Print_Debug(l_debug_loc, l_debug_info);
		  IF g_debug_mode = 'Y' THEN
		     AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
		  END IF;

		  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
		  END IF;
                  ----------------------------------------------------------------

                  Check_Insufficient_Line_Data(
				p_inv_line_rec            => t_inv_lines_table(i),
				p_system_user             => l_system_user,
				p_holds                   => l_holds,
				p_holds_count             => l_hold_count,
				p_release_count           => l_release_count,
				p_insufficient_data_exist => l_insufficient_data_exist,
				p_calling_mode		  => 'PERMANENT_DISTRIBUTIONS',
				p_calling_sequence        => l_curr_calling_sequence );

		  IF ( (NOT l_insufficient_data_exist)
                       AND (t_inv_lines_table(i).generate_dists = 'Y') ) THEN
                 --Bug fix 6731107 : added the AND condition to above IF stmt.
                 --Invoice distributions should be generated only when generate_dists flag is set to 'Y'

       	              ----------------------------------------------------------------
                      l_debug_info := 'Generate Invoice Distributions';
	              --  Print_Debug(l_debug_loc, l_debug_info);
		      IF g_debug_mode = 'Y' THEN
		         AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
		      END IF;

		      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
		      END IF;
                      ----------------------------------------------------------------

                      l_result := Execute_Dist_Generation_Check(
	                                    p_batch_id              => p_inv_batch_id,
	                                    p_invoice_date          => p_invoice_rec.invoice_date,
	                                    p_vendor_id             => p_invoice_rec.vendor_id,
	                                    p_invoice_currency      => p_invoice_rec.invoice_currency_code,
	                                    p_exchange_rate         => p_invoice_rec.exchange_rate,
	                                    p_exchange_rate_type    => p_invoice_rec.exchange_rate_type,
	                                    p_exchange_date         => p_invoice_rec.exchange_date,
	                                    p_inv_line_rec          => t_inv_lines_table(i),
	                                    p_system_user           => l_system_user,
	                                    p_holds                 => l_holds,
	                                    p_holds_count           => l_hold_count,
	                                    p_release_count         => l_release_count,
	                                    p_generate_permanent    => 'Y',
	                                    p_calling_mode          => 'PERMANENT_DISTRIBUTIONS',
	                                    p_error_code            => l_error_code,
	                                    p_curr_calling_sequence => l_curr_calling_sequence);

		 ELSE
       	             ----------------------------------------------------------------
                     l_debug_info := 'Insufficient info for invoice line number: '||
                                      t_inv_lines_table(i).line_number;
	             --  Print_Debug(l_debug_loc, l_debug_info);
		     IF g_debug_mode = 'Y' THEN
		        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
		     END IF;

		     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
		     END IF;
                     ----------------------------------------------------------------
                 END IF; -- end of sufficient data check
               END IF; -- end of line_type_lookup_code check
           END IF; -- end of generate_dists check
           -- Bug8414549
           -- Update of amount_paid for recouped amount will now be done
	   -- during matching of invoice.
           /*IF (t_inv_lines_table(i).line_type_lookup_code IN ('ITEM', 'RETAINAGE RELEASE')) THEN

                l_recouped_amount := AP_MATCHING_UTILS_PKG.Get_Inv_Line_Recouped_Amount
	                                        (P_Invoice_Id          => t_inv_lines_table(i).invoice_id,
	                                         P_Invoice_Line_Number => t_inv_lines_table(i).line_number);

                IF l_recouped_amount <> 0 THEN
                   IF (ap_invoice_lines_utility_pkg.get_approval_status
	                        ( p_invoice_id  => t_inv_lines_table(i).invoice_id
	                         ,p_line_number => t_inv_lines_table(i).line_number) = 'NEVER APPROVED') THEN

                       ----------------------------------------------------------------
                       l_debug_info := 'Adjust Amount Paid if unapproved lines with recouped prepayments exist';
          	       Print_Debug(l_debug_loc, l_debug_info);
       	               ----------------------------------------------------------------

		       --bugfix:5609186 removed the l_recouped_amount from the pay_curr_invoice_amount
		       --as pay_curr_invoice_amount has nothing to do with recouped amount. Recoupment
		       --should effect only amount_paid on the invoice.
		       update  ap_invoices_all
                          set  amount_paid = nvl(amount_paid,0) + abs(l_recouped_amount)
                              ,pay_curr_invoice_amount = ap_utilities_pkg.ap_round_currency
	                                                         (pay_curr_invoice_amount  * payment_cross_rate,
	                                                           payment_currency_code)
		        where  invoice_id  = t_inv_lines_table(i).invoice_id;
                  END IF;
               END IF;
           END IF;*/
           --End of Bug8414549
           ----------------------------------------------------------------
           l_debug_info := 'Update Invoice Distributions to SELECTED';
           --  Print_Debug(l_debug_loc, l_debug_info);
           IF g_debug_mode = 'Y' THEN
              AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
           END IF;

           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
           END IF;
           ----------------------------------------------------------------
  -- Perf 6759699
  -- All the reamining values for the p_run_option is handeled before
  -- the loop. If the line number is passed then it will use proper index.This will
  -- work only when the p_run_option is 'NEW'
    if ( p_run_option = 'NEW' ) then  --6759699

	   Update_Inv_Dists_To_Selected(
		            t_inv_lines_table(i).invoice_id,
		            t_inv_lines_table(i).line_number,
		            p_run_option,
		            l_curr_calling_sequence);
     end if; -- p_run_option
           -----------------------------------------------------------------
           --  Print_Debug(l_debug_loc, 'Line Type : '|| t_inv_lines_table(i).line_type_lookup_code );
           --  Print_Debug(l_debug_loc, 'Match Type: '|| t_inv_lines_table(i).match_type );
           IF g_debug_mode = 'Y' THEN
              AP_Debug_Pkg.Print(g_debug_mode, 'Line Type : '|| t_inv_lines_table(i).line_type_lookup_code  );
              AP_Debug_Pkg.Print(g_debug_mode, 'Match Type: '|| t_inv_lines_table(i).match_type  );
           END IF;

           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,'Line Type : '|| t_inv_lines_table(i).line_type_lookup_code);
	     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,'Match Type: '|| t_inv_lines_table(i).match_type);
           END IF;
           -----------------------------------------------------------------

           IF ( t_inv_lines_table(i).line_type_lookup_code = 'ITEM' AND
                t_inv_lines_table(i).match_type in ('ITEM_TO_PO',
	                                            'ITEM_TO_RECEIPT',
	                                            'PRICE_CORRECTION',
	                                            'QTY_CORRECTION',
	                                            'ITEM_TO_SERVICE_PO',
	                                            'ITEM_TO_SERVICE_RECEIPT',
	                                            'AMOUNT_CORRECTION',
	                                            'PO_PRICE_ADJUSTMENT' ) ) THEN

                ----------------------------------------------------------------
                l_debug_info := 'Calculate Exchange Rate and Invoice Price Variance';
                --  Print_Debug(l_debug_loc, l_debug_info);
                IF g_debug_mode = 'Y' THEN
                   AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
                END IF;

                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
                END IF;
                ----------------------------------------------------------------

	        AP_APPROVAL_MATCHED_PKG.Exec_Matched_Variance_Checks(
		              p_invoice_id                => t_inv_lines_table(i).invoice_id,
		              p_inv_line_number           => t_inv_lines_table(i).line_number,
		              p_base_currency_code        => p_base_currency_code,
		              p_inv_currency_code         => p_invoice_rec.invoice_currency_code,
		              p_sys_xrate_gain_ccid       => NULL,
		              p_sys_xrate_loss_ccid       => NULL,
		              p_system_user               => l_system_user,
		              p_holds                     => l_holds,
		              p_hold_count                => l_hold_count,
		              p_release_count             => l_release_count,
		              p_calling_sequence          => l_curr_calling_sequence );

          END IF;
       END IF;
      END LOOP;

      l_retained_amount := nvl(ap_invoices_utility_pkg.get_retained_total(p_invoice_rec.invoice_id, null),0);

      IF l_retained_amount <> 0 THEN

         ----------------------------------------------------------------
         l_debug_info := 'Adjust Amount Applicable To Discount with Retainage';
         --  Print_Debug(l_debug_loc, l_debug_info);
         IF g_debug_mode = 'Y' THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
         END IF;
         ----------------------------------------------------------------

         update ap_invoices_all
         set    amount_applicable_to_discount = amount_applicable_to_discount + l_retained_amount
               ,pay_curr_invoice_amount = ap_utilities_pkg.ap_round_currency
                                                 ((invoice_amount + l_retained_amount) * payment_cross_rate,
                                                   payment_currency_code)
         where invoice_id = p_invoice_rec.invoice_id
         and   nvl(net_of_retainage_flag, 'N') <> 'Y';
      END IF;

EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
END Generate_Distributions;

PROCEDURE initialize_invoice_holds
			(p_invoice_id       IN NUMBER,
			 p_calling_sequence IN VARCHAR2) IS

  Cursor c_invoice_holds (c_invoice_id NUMBER) Is
  Select hold_lookup_code,
	 decode(release_lookup_code, NULL, 'ALREADY ON HOLD',
	        'RELEASED BY USER') hold_status,
  	 invoice_id,
	 hold_reason,
	 release_lookup_code,
	 line_location_id,
	 rcv_transaction_id,
	 last_updated_by,
	 responsibility_id
  From   ap_holds
  Where  invoice_id = c_invoice_id
  Order By 1, 2 DESC;

  j NUMBER := 1;

  l_debug_info                    VARCHAR2(100);
  l_current_calling_sequence      VARCHAR2(2000);

BEGIN

    -- Update the calling sequence
    --
    l_current_calling_sequence := 'initialize_invoice_holds<-'||p_calling_sequence;

    g_holds_tab.delete;

    OPEN c_invoice_holds (p_invoice_id);
    LOOP
       FETCH c_invoice_holds
       INTO  g_holds_tab(j);
       EXIT WHEN c_invoice_holds%notfound;
       j:=j+1;
    END LOOP;
    CLOSE c_invoice_holds;

EXCEPTION
  WHEN OTHERS then
	if (SQLCODE <> -20001 ) then
	    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
	    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
	    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence);
	    FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(p_invoice_id));
	    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
	end if;

	APP_EXCEPTION.RAISE_EXCEPTION;

END initialize_invoice_holds;

Procedure Count_Org_Hold(
	      p_org_id		    IN NUMBER,
              p_hold_lookup_code    IN VARCHAR2,
	      p_place_or_release    IN VARCHAR2,
              p_calling_sequence    IN VARCHAR2) IS

    l_array_set   VARCHAR2(1);
    l_array_count NUMBER;

  l_debug_info                    VARCHAR2(100);
  l_current_calling_sequence      VARCHAR2(2000);

Begin

    -- Update the calling sequence
    --
    l_current_calling_sequence := 'count_org_hold<-'||p_calling_sequence;

    l_array_set := 'N';
    l_array_count := g_org_holds.count;

    l_debug_info := 'Update Org Hold Count';

    if l_array_count > 0 then

       for i in g_org_holds.first..g_org_holds.last loop
           if g_org_holds(i).org_id = p_org_id
              and g_org_holds(i).hold_lookup_code = p_hold_lookup_code then
              if p_place_or_release = 'P' then
	         g_org_holds(i).holds_placed := g_org_holds(i).holds_placed + 1;
                 l_array_set := 'Y';
	         exit;
	      elsif p_place_or_release = 'R' then
                 g_org_holds(i).holds_released := g_org_holds(i).holds_released + 1;
	         l_array_set := 'Y';
	         exit;
	      end if;
	   end if;
       end loop;

    end if;


    if l_array_set = 'N' then

       l_debug_info := 'Set Org Hold Count';

       if l_array_count = 0 then
          l_array_count := 1;
       else
          l_array_count := l_array_count + 1;  --bug6370503
       end if;

       if p_place_or_release = 'P' then
          g_org_holds(l_array_count).org_id           := p_org_id;
          g_org_holds(l_array_count).hold_lookup_code := p_hold_lookup_code;
          g_org_holds(l_array_count).holds_placed     := 1;
          g_org_holds(l_array_count).holds_released   := 0;
       elsif p_place_or_release = 'R' then
          g_org_holds(l_array_count).org_id           := p_org_id;
          g_org_holds(l_array_count).hold_lookup_code := p_hold_lookup_code;
          g_org_holds(l_array_count).holds_placed     := 0;
          g_org_holds(l_array_count).holds_released   := 1;
       end if;
    end if;

EXCEPTION
  WHEN OTHERS then
        if (SQLCODE <> -20001 ) then
            FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
            FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence);
            FND_MESSAGE.SET_TOKEN('PARAMETERS','Org_Id = '||to_char(p_org_id)
                                               ||' Hold = '||p_hold_lookup_code
                                               ||' Action = '||p_place_or_release);
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        end if;

        APP_EXCEPTION.RAISE_EXCEPTION;
End Count_Org_Hold;

Procedure Print_Debug(
		p_api_name		IN VARCHAR2,
		p_debug_info		IN VARCHAR2) IS
BEGIN

  IF g_debug_mode = 'Y' THEN

    AP_Debug_Pkg.Print(g_debug_mode, p_debug_info );

  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||p_api_name,p_debug_info);
  END IF;
END Print_Debug;

/*=============================================================================
 |  FUNCTION - get_adjusted_base_amount()
 |
 |  DESCRIPTION
 |      This function returns base amount after rouding.
 |      Also calculates the rounding amount for the next line
 |      For ex:                           before adjustment  after adjustment
 |            ---------------------------|----------------------------------------------
 |               p_base_amount           |  0.1               0 (since adjustment goes to -ve)
 |               p_rounding_amt          | -0.2              -0.1 (this much amount is adjusted)
 |               p_next_line_rounding_amt|                   -0.1 (remaing amount..forward it to next line)
 |
 |
 |  PARAMETERS
 |      p_base_amount - entered base amount
 |      p_rounding_amt - rounding amount for the base amount
 |      p_next_line_rounding_amt - rounding amount calculate for the next line/distribution
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    19-MAY-2008   KPASIKAN       Created for the bug 6892789
 |
 *============================================================================*/
FUNCTION get_adjusted_base_amount(p_base_amount IN NUMBER,
                                  p_rounding_amt OUT NOCOPY NUMBER,
                                  p_next_line_rounding_amt IN OUT NOCOPY NUMBER)
RETURN NUMBER IS
    l_adjusted_base_amount   NUMBER := 0;
    l_base_amount            NUMBER :=  p_base_amount;
    l_next_line_rounding_amt NUMBER :=  p_next_line_rounding_amt;
BEGIN
    l_adjusted_base_amount := l_base_amount + l_next_line_rounding_amt;

    -- if adjusted base amount goes to -ve
    IF (l_base_amount > 0 AND l_adjusted_base_amount < 0)
      OR (l_base_amount < 0 AND l_adjusted_base_amount > 0) THEN
      -- rounding maount for the next line/dist
 	p_next_line_rounding_amt := l_adjusted_base_amount;

        -- rounding amt for the line/dist
        p_rounding_amt := -l_base_amount;

        -- base amount will be adjusted to zero
	RETURN 0;
    ELSE
        -- rounding amt for the line/dist
        p_rounding_amt := l_next_line_rounding_amt;

        -- no need to adjust next line/dist
	p_next_line_rounding_amt := 0;

        -- base amount
	RETURN l_adjusted_base_amount;
    END IF;
END;

--Bug 8346277
--For Manual AWT Line Added new procedure.
PROCEDURE Generate_Manual_Awt_Dist
                   (p_invoice_rec          IN AP_APPROVAL_PKG.Invoice_Rec,
                    p_base_currency_code        IN VARCHAR2,
                    p_inv_batch_id                    IN NUMBER,
                    p_run_option           IN VARCHAR2,
                    p_calling_sequence     IN VARCHAR2,
                    x_error_code           IN VARCHAR2,
                    p_calling_mode         IN VARCHAR2  ) IS

     t_inv_lines_table             AP_INVOICES_PKG.t_invoice_lines_table;

     l_curr_calling_sequence       VARCHAR2(2000);
     l_debug_info                    VARCHAR2(2000);
     l_debug_loc                   VARCHAR2(30) := 'Generate_Distributions';

     l_prorate_across_all_items    VARCHAR2(1);
     l_error_code                  VARCHAR2(4000);
     l_debug_context               VARCHAR2(2000);
     l_success                     BOOLEAN;

     l_system_user                 NUMBER := 5;

     l_holds                       HOLDSARRAY;
     l_hold_count                  COUNTARRAY;
     l_release_count               COUNTARRAY;
     l_insufficient_data_exist     BOOLEAN := FALSE;

     l_recouped_amount             NUMBER;
     l_retained_amount             NUMBER;
     l_result                      BOOLEAN;

     l_line_variance_hold_exist    BOOLEAN := FALSE;
     l_need_to_round_flag          VARCHAR2(1) := 'Y';

     l_not_exist_nond_line         VARCHAR2(1);
     l_regenerate_dist             NUMBER:=0; /* 0 - Generate, 1 - Do not */

     CURSOR dist_gen_holds(p_invoice_id NUMBER)
         IS
     SELECT hold_lookup_code
       FROM ap_holds_all
      WHERE hold_lookup_code IN ('DISTRIBUTION SET INACTIVE',
                                 'SKELETON DISTRIBUTION SET',
                                 'CANNOT OVERLAY ACCOUNT',
                                 'INVALID DEFAULT ACCOUNT',
                                 'CANNOT EXECUTE ALLOCATION',
                                 'PERIOD CLOSED',
                                 'PROJECT GL DATE CLOSED')
        AND release_lookup_code IS NULL
        AND invoice_id = p_invoice_id;

     TYPE holds_tab_type IS
     TABLE OF AP_HOLDS_ALL.HOLD_LOOKUP_CODE%TYPE
     INDEX BY BINARY_INTEGER;

     t_holds_tab                    holds_tab_type;

   BEGIN

         l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||p_calling_sequence;


         ----------------------------------------------------------------
         l_debug_info := 'Bulk Collect Invoice Lines';
         --  Print_Debug(l_debug_loc, l_debug_info);
         IF g_debug_mode = 'Y' THEN
            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
         END IF;
         ----------------------------------------------------------------

          OPEN  invoice_line_mawt_cur (p_invoice_rec.invoice_id);
         FETCH invoice_line_mawt_cur BULK COLLECT
          INTO  t_inv_lines_table;
         CLOSE invoice_line_mawt_cur;

         l_debug_info := 'Checking if there exists a non d line';

         BEGIN

           SELECT 'Y'
             INTO l_not_exist_nond_line
             FROM ap_invoice_lines_all ail
            WHERE ail.invoice_id     = p_invoice_rec.invoice_id
              AND nvl(ail.generate_dists, 'N') <> 'D'
              AND rownum < 2;

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_not_exist_nond_line := 'N';

         END;

         l_debug_info := 'If there is no non d line or p_calling_mode is CANCEL, then fetch all the dist gen holds';

         IF (l_not_exist_nond_line = 'N' OR p_calling_mode = 'CANCEL') THEN
           OPEN  dist_gen_holds (p_invoice_rec.invoice_id);
           FETCH dist_gen_holds BULK COLLECT INTO t_holds_tab;
           CLOSE dist_gen_holds;
         END IF;

         l_debug_info := 'Release all the non D holds';

         IF nvl(t_holds_tab.count, 0) > 0 THEN

           FOR i IN NVL(t_holds_tab.first,0)..NVL(t_holds_tab.last,0)
           LOOP

             l_debug_info := 'Inside the loop';

             Process_Inv_Hold_Status(
                p_invoice_rec.invoice_id,
                null,
                null,
                t_holds_tab(i),
                'N',
                null,
                l_system_user,
                l_holds,
                l_hold_count,
                l_release_count,
                l_curr_calling_sequence);

           END LOOP;

        END IF;


             IF ( nvl(t_inv_lines_table.count,0) <> 0 AND
                  (nvl(p_run_option,'Yes') <> 'New' ))THEN

                Update_Inv_Dists_To_Selected( p_invoice_rec.invoice_id,
                                              null ,
                                              p_run_option,
                                              l_curr_calling_sequence);
             End IF;

         FOR i IN NVL(t_inv_lines_table.first,0)..NVL(t_inv_lines_table.last,0)
         LOOP
          IF (t_inv_lines_table.exists(i)) THEN

              IF (t_inv_lines_table(i).generate_dists IN ('D' , 'Y') ) THEN
                  IF t_inv_lines_table(i).line_type_lookup_code = 'AWT' THEN

                     ----------------------------------------------------------------
                     l_debug_info := 'Check Insufficient Line Info: Number and Type: '||
                                     t_inv_lines_table(i).line_number ||' and '||
                                     t_inv_lines_table(i).line_type_lookup_code;
                     --  Print_Debug(l_debug_loc, l_debug_info);
		     IF g_debug_mode = 'Y' THEN
		        AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
		     END IF;

		     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
		     END IF;
                     ----------------------------------------------------------------

                     Check_Insufficient_Line_Data(
                                   p_inv_line_rec            => t_inv_lines_table(i),
                                   p_system_user             => l_system_user,
                                   p_holds                   => l_holds,
                                   p_holds_count             => l_hold_count,
                                   p_release_count           => l_release_count,
                                   p_insufficient_data_exist => l_insufficient_data_exist,
                                   p_calling_mode                  => 'PERMANENT_DISTRIBUTIONS',
                                   p_calling_sequence        => l_curr_calling_sequence );

                       SELECT COUNT(*)
                         INTO l_regenerate_dist
                         FROM ap_invoice_distributions_all aid
                        WHERE aid.invoice_id          = t_inv_lines_table(i) .invoice_id
                          AND aid.invoice_line_number = t_inv_lines_table(i) .line_number
                          AND (NVL(posted_flag , 'N') <> 'N'
                                   OR NVL(encumbered_flag,'N') <>'N');

                     IF ( (NOT l_insufficient_data_exist)
                          AND (l_regenerate_dist = 0 ) ) THEN
                         ----------------------------------------------------------------
                         l_debug_info := 'Generate Invoice Distributions';
                         --  Print_Debug(l_debug_loc, l_debug_info);
		         IF g_debug_mode = 'Y' THEN
		            AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
		         END IF;

		         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
		         END IF;
                         ----------------------------------------------------------------

                         l_result := Execute_Dist_Generation_Check(
                                               p_batch_id              => p_inv_batch_id,
                                               p_invoice_date          => p_invoice_rec.invoice_date,
                                               p_vendor_id             => p_invoice_rec.vendor_id,
                                               p_invoice_currency      => p_invoice_rec.invoice_currency_code,
                                               p_exchange_rate         => p_invoice_rec.exchange_rate,
                                               p_exchange_rate_type    => p_invoice_rec.exchange_rate_type,
                                               p_exchange_date         => p_invoice_rec.exchange_date,
                                               p_inv_line_rec          => t_inv_lines_table(i),
                                               p_system_user           => l_system_user,
                                               p_holds                 => l_holds,
                                               p_holds_count           => l_hold_count,
                                               p_release_count         => l_release_count,
                                               p_generate_permanent    => 'Y',
                                               p_calling_mode          => 'PERMANENT_DISTRIBUTIONS',
                                               p_error_code            => l_error_code,
                                               p_curr_calling_sequence => l_curr_calling_sequence);

                    ELSE
                        ----------------------------------------------------------------
                        l_debug_info := 'Insufficient info for invoice line number: '||
                                         t_inv_lines_table(i).line_number;
                        --  Print_Debug(l_debug_loc, l_debug_info);
		        IF g_debug_mode = 'Y' THEN
		           AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
		        END IF;

		        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
		        END IF;
                        ----------------------------------------------------------------
                    END IF; -- end of sufficient data check
                  END IF; -- end of line_type_lookup_code check
              END IF; -- end of generate_dists check


              ----------------------------------------------------------------
              l_debug_info := 'Update Invoice Distributions to SELECTED';
              --  Print_Debug(l_debug_loc, l_debug_info);
              IF g_debug_mode = 'Y' THEN
                 AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
              END IF;

              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
              END IF;
              ----------------------------------------------------------------
     -- All the reamining values for the p_run_option is handeled before
     -- the loop. If the line number is passed then it will use proper index.This will
     -- work only when the p_run_option is 'NEW'
       if ( p_run_option = 'New' ) then

              Update_Inv_Dists_To_Selected(
                               t_inv_lines_table(i).invoice_id,
                               t_inv_lines_table(i).line_number,
                               p_run_option,
                               l_curr_calling_sequence);
        end if; -- p_run_option
              -----------------------------------------------------------------
              --  Print_Debug(l_debug_loc, 'Line Type : '|| t_inv_lines_table(i).line_type_lookup_code );
              --  Print_Debug(l_debug_loc, 'Match Type: '|| t_inv_lines_table(i).match_type );
              IF g_debug_mode = 'Y' THEN
                 AP_Debug_Pkg.Print(g_debug_mode, 'Line Type : '|| t_inv_lines_table(i).line_type_lookup_code  );
                 AP_Debug_Pkg.Print(g_debug_mode, 'Match Type: '|| t_inv_lines_table(i).match_type  );
              END IF;

              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,'Line Type : '|| t_inv_lines_table(i).line_type_lookup_code);
	        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,'Match Type: '|| t_inv_lines_table(i).match_type);
              END IF;
              -----------------------------------------------------------------

          END IF;
         END LOOP;

         l_retained_amount := nvl(ap_invoices_utility_pkg.get_retained_total(p_invoice_rec.invoice_id, null),0);

         IF l_retained_amount <> 0 THEN

            ----------------------------------------------------------------
            l_debug_info := 'Adjust Amount Applicable To Discount with Retainage';
            --  Print_Debug(l_debug_loc, l_debug_info);
            IF g_debug_mode = 'Y' THEN
               AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_debug_loc,l_debug_info);
            END IF;
            ----------------------------------------------------------------

     UPDATE ap_invoices_all
        SET amount_applicable_to_discount    = amount_applicable_to_discount
                                                 + l_retained_amount
          , pay_curr_invoice_amount          = ap_utilities_pkg.ap_round_currency(
                                                   (invoice_amount + l_retained_amount)
                                                        * payment_cross_rate
                                                   , payment_currency_code)
      WHERE invoice_id                       = p_invoice_rec.invoice_id
        AND NVL(net_of_retainage_flag , 'N') <> 'Y';
   END IF;

   EXCEPTION
       WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
             FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
             FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;
   END Generate_Manual_Awt_Dist;


-- Start 8691645
/*=========================================================================
 | This procedure creates invoice validation concurrent request for the
 | given vendor and and for the vendors who contains given vendor
 | as third party vendor
 ===========================================================================*/

PROCEDURE BATCH_APPROVAL_FOR_VENDOR(P_VENDOR_ID        IN  AP_INVOICES.VENDOR_ID%type,
                                    P_CALLING_SEQUENCE IN  VARCHAR2)is

l_request_id                NUMBER;
l_current_calling_sequence  VARCHAR2(2000);
l_debug_info                VARCHAR2(1000);


TYPE VendorIdTab IS TABLE OF ap_suppliers.vendor_id%TYPE INDEX BY BINARY_INTEGER;
l_vendor_id_list       VendorIdTab;

--cursor fetches vendors information
CURSOR vndr_list_to_process IS
select APS.vendor_id
from IBY_EXT_PAYEE_RELATIONSHIPS IEPR,
     AP_SUPPLIERS APS
where IEPR.remit_party_id in (select party_id from ap_suppliers
                              where vendor_id = p_vendor_id)
  and IEPR.party_id = APS.party_id
UNION
select APS.vendor_id
from  AP_SUPPLIERS APS
where APS.vendor_id = p_vendor_id;

Begin

 l_current_calling_sequence := 'AP_APPROVAL_PKG.BATCH_APPROVAL_FOR_VENDOR <- '||
                                P_CALLING_SEQUENCE;
 OPEN vndr_list_to_process;
 FETCH vndr_list_to_process
  BULK COLLECT INTO l_vendor_id_list;
 CLOSE vndr_list_to_process;

 IF l_vendor_id_list.count > 0 THEN

  FOR i IN 1..l_vendor_id_list.count    LOOP

      l_debug_info := 'Before Submitting Request for vendor id: '||l_vendor_id_list(i) ;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line(FND_FILE.LOG,l_debug_info);
    END IF;


     l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                         'SQLAP',
                         'APPRVL',
		          '',              --description
		          '',              --start time
		          FALSE,           --sub_request
		           '',              --org_id
		           'All',           --run option
  		           '',              --invoice_batch_id,
		           '',              --start_date,
		           '',              --end_date,
		          l_vendor_id_list(i), --VENDOR_ID,
		          chr(0)              --pay_group,
		           );

    l_debug_info := 'request_id ='||to_char(l_request_id);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line(FND_FILE.LOG,l_debug_info);
    END IF;

    COMMIT;

     END LOOP;

 END IF;

EXCEPTION

    WHEN OTHERS then

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
      FND_MESSAGE.SET_TOKEN('PARAMETERS','Vendor Id = '|| p_vendor_id);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

End BATCH_APPROVAL_FOR_VENDOR;
--End 8691645


END AP_APPROVAL_PKG;

/
