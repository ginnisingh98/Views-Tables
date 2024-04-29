--------------------------------------------------------
--  DDL for Package AP_WEB_DB_AP_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_AP_INT_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdbaps.pls 120.18.12010000.4 2009/12/14 14:08:45 dsadipir ship $ */

SUBTYPE expHdr_headerID			IS AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE;
SUBTYPE expHdr_defaultExchRate		IS AP_EXPENSE_REPORT_HEADERS.default_exchange_rate%TYPE;

/* Financials System Parameters */
---------------------------------------------------------------------------------------------------
SUBTYPE finSysParams_checkAddrFlag		IS FINANCIALS_SYSTEM_PARAMETERS.expense_check_address_flag%TYPE;
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
SUBTYPE apSetUp_baseCurrencyCode 		IS AP_SYSTEM_PARAMETERS.base_currency_code%TYPE;
SUBTYPE apSetUp_expenseReportID 		IS AP_SYSTEM_PARAMETERS.expense_report_id%TYPE;
SUBTYPE apSetUp_multiCurrencyFlag 		IS AP_SYSTEM_PARAMETERS.multi_currency_flag%TYPE;
SUBTYPE apSetUp_defaultExchRateType 		IS AP_SYSTEM_PARAMETERS.default_exchange_rate_type%TYPE;
SUBTYPE apSetUp_autoTaxCalcFlag 		IS AP_SYSTEM_PARAMETERS.AUTO_TAX_CALC_FLAG%TYPE;
SUBTYPE apSetUp_autoTaxCalcOverride 		IS AP_SYSTEM_PARAMETERS.AUTO_TAX_CALC_OVERRIDE%TYPE;
SUBTYPE apSetUp_amtInclTaxOverride 		IS AP_SYSTEM_PARAMETERS.AMOUNT_INCLUDES_TAX_OVERRIDE%TYPE;
SUBTYPE apSetUp_setOfBooksID	 		IS AP_SYSTEM_PARAMETERS.set_of_books_id%TYPE;
SUBTYPE apSetUp_paymentCurrCode       		IS AP_SYSTEM_PARAMETERS.payment_currency_code%TYPE;
SUBTYPE apSetUp_applyAdvDefault       		IS AP_SYSTEM_PARAMETERS.apply_advances_default%TYPE;
SUBTYPE apSetUp_allowAWTFlag          		IS AP_SYSTEM_PARAMETERS.allow_awt_flag%TYPE;
SUBTYPE apSetUp_allowAWTOverride      		IS AP_SYSTEM_PARAMETERS.allow_awt_override%TYPE;
SUBTYPE apSetUp_defaultAWTGroupID     		IS AP_SYSTEM_PARAMETERS.default_awt_group_id%TYPE;
SUBTYPE apSetUp_vatCode               		IS AP_SYSTEM_PARAMETERS.vat_code%TYPE;
SUBTYPE apSetUp_makeMandatoryFlag	 	IS AP_SYSTEM_PARAMETERS.make_rate_mandatory_flag%TYPE;
---------------------------------------------------------------------------------------------------
/* PO Vendors */
---------------------------------------------------------------------------------------------------
SUBTYPE vendors_vendorID              	IS AP_SUPPLIERS.vendor_id%TYPE;
SUBTYPE vendors_paymentCurrCode       	IS AP_SUPPLIERS.payment_currency_code%TYPE;
SUBTYPE vendors_allowAWTFlag 		IS AP_SUPPLIERS.allow_awt_flag%TYPE;
SUBTYPE vendors_awtGroupID 		IS AP_SUPPLIERS.awt_group_id%TYPE;
SUBTYPE vendors_employeeID 		IS AP_SUPPLIERS.employee_id%TYPE;
SUBTYPE vendors_payGroupLookupCode	IS AP_SUPPLIERS.pay_group_lookup_code%TYPE;
SUBTYPE vendors_vendorName		IS AP_SUPPLIERS.vendor_name%TYPE;
SUBTYPE vendors_setOfBooksID		IS AP_SUPPLIERS.set_of_books_id%TYPE;
SUBTYPE vendors_acctsPayCodeCombID	IS AP_SUPPLIERS.accts_pay_code_combination_id%TYPE;
-------------------------------------------------------------------------------

--------------------
/* PO Vendor Sites */
-------------------------------------------------------------------------------
SUBTYPE vendorSites_vendorSiteID        IS AP_SUPPLIER_SITES.vendor_site_id%TYPE;
SUBTYPE vendorSites_vendorID       	IS AP_SUPPLIER_SITES.vendor_id%TYPE;
SUBTYPE vendorSites_payGroupLookupCode  IS AP_SUPPLIER_SITES.pay_group_lookup_code%TYPE;
SUBTYPE vendorSites_invCurrCode		IS AP_SUPPLIER_SITES.invoice_currency_code%TYPE;
SUBTYPE vendorSites_acctsPayCodeCombID	IS AP_SUPPLIER_SITES.accts_pay_code_combination_id%TYPE;
-------------------------------------------------------------------------------

--------------------
/* GL Sets Of Books */
---------------------------------------------------------------------------------------------------
SUBTYPE glsob_chartOfAccountsID 	IS GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE;
SUBTYPE glsob_setOfBooksID		IS GL_SETS_OF_BOOKS.set_of_books_id%TYPE;
SUBTYPE glsob_name			IS GL_SETS_OF_BOOKS.name%TYPE;
---------------------------------------------------------------------------------------------------
/* AP Web Signing Limits */

---------------------------------------------------------------------------------------------------
SUBTYPE signingLimits_signingLimit 	IS AP_WEB_SIGNING_LIMITS.signing_limit%TYPE;
SUBTYPE signingLimits_docType		IS AP_WEB_SIGNING_LIMITS.document_type%TYPE;
SUBTYPE signingLimits_employeeID	IS AP_WEB_SIGNING_LIMITS.employee_id%TYPE;
SUBTYPE signingLimits_costCenter	IS AP_WEB_SIGNING_LIMITS.cost_center%TYPE;
SUBTYPE signingLimits_orgID		IS AP_WEB_SIGNING_LIMITS.org_id%TYPE;
---------------------------------------------------------------------------------------------------

/*AP Invoices */
---------------------------------------------------------------------------------------------------
SUBTYPE invoices_invCurrCode			IS AP_INVOICES.invoice_currency_code%TYPE;
---------------------------------------------------------------------------------------------------

/*AP Invoices Interface */
---------------------------------------------------------------------------------------------------
SUBTYPE invIntf_invID				IS AP_INVOICES_INTERFACE.invoice_id%TYPE;
SUBTYPE invIntf_invNum				IS AP_INVOICES_INTERFACE.invoice_num%TYPE;
SUBTYPE invIntf_partyID				IS AP_INVOICES_INTERFACE.party_id%TYPE;
SUBTYPE invIntf_partySiteID			IS AP_INVOICES_INTERFACE.party_site_id%TYPE;
SUBTYPE invIntf_vendorID			IS AP_INVOICES_INTERFACE.vendor_id%TYPE;
SUBTYPE invIntf_vendorSiteID			IS AP_INVOICES_INTERFACE.vendor_site_id%TYPE;
SUBTYPE invIntf_invAmt				IS AP_INVOICES_INTERFACE.invoice_amount%TYPE;
SUBTYPE invIntf_invCurrCode			IS AP_INVOICES_INTERFACE.invoice_currency_code%TYPE;
SUBTYPE invIntf_source				IS AP_INVOICES_INTERFACE.source%TYPE;
SUBTYPE invIntf_docCategoryCode			IS AP_INVOICES_INTERFACE.doc_category_code%TYPE;
SUBTYPE invIntf_invTypeCode			IS AP_INVOICES_INTERFACE.invoice_type_lookup_code%TYPE;
SUBTYPE invIntf_acctsPayCCID			IS AP_INVOICES_INTERFACE.accts_pay_code_combination_id%TYPE;
---------------------------------------------------------------------------------------------------



/* AP Expense Feed Dists */
---------------------------------------------------------------------------------------------------
SUBTYPE expFeedDists_distID			IS AP_EXPENSE_FEED_DISTS.feed_distribution_id%TYPE;
SUBTYPE expFeedDists_description		IS AP_EXPENSE_FEED_DISTS.description%TYPE;
SUBTYPE expFeedDists_mgrApprvlID		IS AP_EXPENSE_FEED_DISTS.manager_approval_id%TYPE;
SUBTYPE expFeedDists_statusLookupCode		IS AP_EXPENSE_FEED_DISTS.status_lookup_code%TYPE;
SUBTYPE expFeedDists_feedLineID			IS AP_EXPENSE_FEED_DISTS.feed_line_id%TYPE;
SUBTYPE expFeedDists_amount     		IS AP_EXPENSE_FEED_DISTS.amount%TYPE;
SUBTYPE expFeedDists_distCodeCombID     	IS AP_EXPENSE_FEED_DISTS.dist_code_combination_id%TYPE;
SUBTYPE expFeedDists_amtInclTaxFlag     	IS AP_EXPENSE_FEED_DISTS.amount_includes_tax_flag%TYPE;
SUBTYPE expFeedDists_taxCode     		IS AP_EXPENSE_FEED_DISTS.tax_code%TYPE;
SUBTYPE expFeedDists_empVerifID     		IS AP_EXPENSE_FEED_DISTS.employee_verification_id%TYPE;
SUBTYPE expFeedDists_acctSegValue     		IS AP_EXPENSE_FEED_DISTS.account_segment_value%TYPE;
SUBTYPE expFeedDists_costCenter     		IS AP_EXPENSE_FEED_DISTS.cost_center%TYPE;
SUBTYPE expFeedDists_statusChangeDate     	IS AP_EXPENSE_FEED_DISTS.status_change_date%TYPE;
---------------------------------------------------------------------------------------------------


/*AP Invoices Lines Interface */
---------------------------------------------------------------------------------------------------
SUBTYPE invLines_invID				IS AP_INVOICE_LINES_INTERFACE.invoice_id%type;
SUBTYPE invLines_invLineID			IS AP_INVOICE_LINES_INTERFACE.invoice_line_id%type;
SUBTYPE invLines_lineNum			IS AP_INVOICE_LINES_INTERFACE.line_number%type;
SUBTYPE invLines_lineTypeLookupCode		IS AP_INVOICE_LINES_INTERFACE.line_type_lookup_code%type;
SUBTYPE invLines_amount				IS AP_INVOICE_LINES_INTERFACE.amount%type;
SUBTYPE invLines_accountingDate			IS AP_INVOICE_LINES_INTERFACE.accounting_date%type;
SUBTYPE invLines_distCodeCombID			IS AP_INVOICE_LINES_INTERFACE.dist_code_combination_id%type;
SUBTYPE invLines_crdCardTrxID			IS AP_INVOICE_LINES_INTERFACE.credit_card_trx_id%type;
SUBTYPE invLines_description			IS AP_INVOICE_LINES_INTERFACE.description%type;
---------------------------------------------------------------------------------------------------

/*AP Invoices All */
---------------------------------------------------------------------------------------------------
SUBTYPE invAll_exchangeRate	 	        IS AP_INVOICES_ALL.exchange_rate%TYPE;
SUBTYPE invAll_id	 	                IS AP_INVOICES_ALL.invoice_id%TYPE;
SUBTYPE invAll_invoiceAmount 	                IS AP_INVOICES_ALL.invoice_amount%TYPE;
SUBTYPE invAll_baseAmount 	                IS AP_INVOICES_ALL.base_amount%TYPE;
---------------------------------------------------------------------------------------------------

/* AP Tax Codes */

---------------------------------------------------------------------------------------------------
SUBTYPE taxCodes_name		 	IS AP_TAX_CODES.name%TYPE;
SUBTYPE taxCodes_webEnabledFlag 	IS AP_TAX_CODES.web_enabled_flag%TYPE;
SUBTYPE taxCodes_taxID			IS AP_TAX_CODES.TAX_ID%TYPE;
SUBTYPE taxCodes_inactiveDate		IS AP_TAX_CODES.inactive_date%TYPE;
---------------------------------------------------------------------------------------------------



C_No                    	CONSTANT VARCHAR2(1) := 'N';
C_TaxCalcLevelNone        	CONSTANT VARCHAR2(1) := 'N';

TYPE  	TaxCodeCursor 		IS REF CURSOR;
TYPE 	CostCenterValidCursor	IS REF CURSOR;

TYPE  APSysInfoRec IS RECORD (
	base_currency			apSetUp_baseCurrencyCode,
	default_exchange_rate_type	apSetUp_defaultExchRateType,
	base_curr_name      		FND_CURRENCIES_VL.name%TYPE,
	sys_multi_curr_flag 		apSetUp_multiCurrencyFlag
);

--------------------------------------------------------------------------------
FUNCTION get_ap_system_params(
                           p_base_curr_code       OUT NOCOPY      apSetUp_baseCurrencyCode,
                           p_set_of_books_id      OUT NOCOPY      apSetUp_setOfBooksID,
                           p_expense_report_id    OUT NOCOPY      apSetUp_expenseReportID,
                           p_default_exch_rate_type    OUT NOCOPY      apSetUp_defaultExchRateType) RETURN BOOLEAN;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION GetCurrNameForCurrCode(
	p_curr_code	IN	FND_CURRENCIES_VL.currency_code%TYPE,
	p_curr_name OUT NOCOPY FND_CURRENCIES_VL.name%TYPE
) RETURN BOOLEAN;

--------------------------------------------------------------------------------
FUNCTION GetBaseCurrInfo(
	p_base_curr_code OUT NOCOPY apSetUp_baseCurrencyCode
) RETURN BOOLEAN;

-------------------------------------------------------------------
FUNCTION GetAPSysCurrencySetupInfo(p_sys_info_rec OUT NOCOPY APSysInfoRec
) RETURN BOOLEAN;

-------------------------------------------------------------------
PROCEDURE GetDefaultExchange(p_default_exchange_rate_type	 OUT NOCOPY VARCHAR2);


----------------------------------------------------------
FUNCTION GetVendorInfoOfEmp(
	p_employee_id		IN  vendors_employeeID,
	p_vendor_id	 OUT NOCOPY vendors_vendorID,
	p_vend_pay_curr_code  OUT NOCOPY vendors_paymentCurrCode,
	p_vend_pay_curr_name OUT NOCOPY FND_CURRENCIES_VL.name%TYPE
) RETURN BOOLEAN;

----------------------------------------------------------
FUNCTION GetVendorAWTSetupForExpRpt(
	p_report_header_id   IN  expHdr_headerID,
	p_ven_allow_awt_flag OUT NOCOPY vendors_allowAWTFlag,
	p_ven_awt_group_id   OUT NOCOPY vendors_awtGroupID
) RETURN BOOLEAN;

-------------------------------------------------------------------
FUNCTION GetCOAofSOB(
	p_chart_of_accounts OUT NOCOPY glsob_chartOfAccountsID
) RETURN BOOLEAN;

-------------------------------------------------------------------
FUNCTION GetSOB(
	p_set_of_books_id OUT NOCOPY glsob_setOfBooksID
) RETURN BOOLEAN;

-------------------------------------------------------------------
FUNCTION ApproverHasAuthority(
	p_approver_id 	  IN signingLimits_employeeID,
	p_doc_cost_center IN signingLimits_costCenter,
	p_approval_amount IN NUMBER,
	p_reimb_precision IN FND_CURRENCIES_VL.PRECISION%TYPE,
	p_item_type       IN signingLimits_docType,
        p_payment_curr_code  IN VARCHAR2,
        p_week_end_date IN DATE,
       	p_has_authority	  OUT NOCOPY BOOLEAN
) RETURN BOOLEAN;

-------------------------------------------------------------------
/*Bug 2743726: New procedure for checking cost center value set
	       alphanumeric_flag is checked or not.
*/
-------------------------------------------------------------------
PROCEDURE IsCostCenterUpperCase(
	p_doc_cost_center IN VARCHAR2,
	Is_Cost_Center_UpperCase_flag	  OUT NOCOPY VARCHAR2
);
-------------------------------------------------------------------


--------------------------------------------------------------------------------
FUNCTION CostCenterValid(
	p_cost_center		IN  expFeedDists_costCenter,
	p_valid		 OUT NOCOPY BOOLEAN,
        p_employee_id           IN  NUMBER DEFAULT null
) RETURN BOOLEAN;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION GetExpenseClearingCCID(
	p_ccid OUT NOCOPY NUMBER,
	p_card_program_id IN NUMBER,
	p_employee_id     IN NUMBER,
	p_as_of_date      IN DATE
) RETURN BOOLEAN;

-----------------------------------------------------
FUNCTION GetAvailablePrepayments(
	p_employee_id 		IN 	vendors_employeeID,
	p_default_currency_code IN 	invoices_invCurrCode,
	p_available_prepays OUT NOCOPY NUMBER
) RETURN BOOLEAN;

-------------------------------------------------------------------
FUNCTION GetVendorID(
	p_employee_id 	IN 	vendors_employeeID,
	p_vendor_id  OUT NOCOPY vendors_vendorID
) RETURN BOOLEAN;
-------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetVendorSitesCodeCombID(
	p_vendor_site_id 	IN 	vendorSites_vendorSiteID,
	p_code_comb_id	  OUT NOCOPY     vendorSites_acctsPayCodeCombID
) RETURN BOOLEAN;
-------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetVendorCodeCombID(
	p_vendor_id 		IN 	vendors_vendorID,
	p_accts_pay	  OUT NOCOPY     vendors_acctsPayCodeCombID
) RETURN BOOLEAN;
-------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetPayGroupLookupCode(
	p_vendor_id 		IN	vendorSites_vendorID,
	p_vendor_site_id 	IN 	vendorSites_vendorSiteID,
	p_pay_group_code  OUT NOCOPY     vendorSites_payGroupLookupCode
) RETURN BOOLEAN;

--------------------------------------------------------------------------------
-- Bug: 6838894
FUNCTION InsertInvoiceInterface(
	p_invoice_id		IN invIntf_invID,
	p_party_id		IN invIntf_partyID,
	p_vendor_id		IN invIntf_vendorID,
	p_vendor_site_id 	IN invIntf_vendorSiteID,
	p_sum			IN invIntf_invAmt,
	p_invoice_curr_code 	IN invIntf_invCurrCode,
	p_source		IN invIntf_source,
	p_pay_group_lookup_code	IN vendorSites_payGroupLookupCode,
        p_org_id                IN NUMBER,
        p_doc_category_code     IN invIntf_docCategoryCode,
        p_invoice_type_lookup_code IN invIntf_invTypeCode,
        p_accts_pay_ccid        IN invIntf_acctsPayCCID,
	p_party_site_id		IN invIntf_partySiteID default null,
	p_terms_id		IN AP_TERMS.TERM_ID%TYPE default null
) RETURN BOOLEAN;

--------------------------------------------------------------------------------
FUNCTION InsertInvoiceLinesInterface(
	p_invoice_id		IN invLines_invID,
	p_invoice_line_id	IN invLines_invLineID,
	p_count			IN invLines_lineNum,
	p_linetype		IN invLines_lineTypeLookupCode,
	p_amount		IN invLines_amount,
	p_trxn_date		IN invLines_accountingDate,
	p_ccid			IN invLines_distCodeCombID,
	p_card_trxn_id		IN invLines_crdCardTrxID,
        p_description           IN invLines_description,
        p_org_id                IN NUMBER

) RETURN BOOLEAN;

--------------------------------------------------------------------------------
FUNCTION GetNextInvoiceId(
	p_invoice_id OUT NOCOPY NUMBER
) RETURN BOOLEAN;

--------------------------------------------------------------------------------
FUNCTION GetNextInvoiceLineId(
	p_invoice_line_id OUT NOCOPY NUMBER
) RETURN BOOLEAN;

-------------------------------------------------------------------
FUNCTION IsTaxCodeWebEnabled(
	P_ExpTypeDefaultTaxCode IN  taxCodes_name,
	p_tax_web_enabled OUT NOCOPY taxCodes_webEnabledFlag
) RETURN BOOLEAN;

PROCEDURE GenTaxFunctions;


--------------------------------------------------------------------------------
FUNCTION GetInvoiceAmt(
        p_invoiceId  IN invAll_id,
        p_invoiceAmt OUT NOCOPY invLines_amount,
        p_exchangeRate OUT NOCOPY invAll_exchangeRate,
        p_minAcctUnit OUT NOCOPY FND_CURRENCIES_VL.minimum_accountable_unit%TYPE ,
        p_precision OUT NOCOPY FND_CURRENCIES_VL.PRECISION%TYPE
) RETURN BOOLEAN;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION SetInvoiceAmount(
p_invoiceId     IN invAll_id,
p_invoiceAmt 	IN invAll_invoiceAmount,
p_baseAmt       IN invAll_baseAmount
) RETURN BOOLEAN;
--------------------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetVatCode(
	P_TaxCodeID 	IN  taxCodes_taxID,
	p_VatCode OUT NOCOPY taxCodes_name
) RETURN BOOLEAN;
-------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetTaxCodeID(
	P_VatCode	IN  taxCodes_name,
	P_TaxCodeID  OUT NOCOPY taxCodes_taxID
) RETURN BOOLEAN;
-------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetTaxCodeID(
	P_VatCode	IN  taxCodes_name,
	P_ExpLine_Date	IN  DATE,
	P_TaxCodeID  OUT NOCOPY taxCodes_taxID
) RETURN BOOLEAN;
-------------------------------------------------------------------

FUNCTION GetRoundingErrorCCID(
        p_ccid OUT NOCOPY NUMBER
) RETURN BOOLEAN;

--------------------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION getTemplateCostCenter(
	p_parameter_id		IN  NUMBER
) RETURN VARCHAR2;
-------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION isCostCenterExistOnTemplate(
	p_expense_report_id		IN  NUMBER
) RETURN VARCHAR2;

-------------------------------------------------------------------
FUNCTION GetExpenseClearingCCID(
	p_trx_id NUMBER
) RETURN NUMBER;

-----------------------------------------------------

---------------------------------------------------------------------
PROCEDURE GetDefaultExchangeRates(
        p_default_exchange_rates OUT NOCOPY VARCHAR2,
        p_exchange_rate_allowance OUT NOCOPY NUMBER
);
---------------------------------------------------------------------


END AP_WEB_DB_AP_INT_PKG;

/
