--------------------------------------------------------
--  DDL for Package AP_VENDOR_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_VENDOR_PUB_PKG" AUTHID CURRENT_USER AS
/* $Header: appvndrs.pls 120.15.12010000.21 2010/04/21 22:09:13 wjharris ship $ */
/*#
 * This Package provides APIs to allow users to create supplier,
 * supplier site and supplier contact records into Payables.
 * @rep:scope public
 * @rep:product AP
 * @rep:lifecycle active
 * @rep:displayname Suppliers Package
 * @rep:category BUSINESS_ENTITY AP_SUPPLIER
 */
-- Global variables for Import

   g_source               VARCHAR2(30) := 'NOT IMPORT';
   g_multi_org            VARCHAR2(1)  := 'Y';
   g_default_org_id       VARCHAR2(255);
   g_fed_fin_installed    VARCHAR2(1);
   g_user_id              NUMBER(15):=FND_GLOBAL.user_id;
   g_login_id             NUMBER(15):=FND_GLOBAL.login_id;

-- Record Types

-- Bug 4775923: Modified fields in the record types to be of table.column instead of fixed length definitions.
--              Alligned the spec so that it is more readable for troubleshooting.

TYPE r_vendor_rec_type IS RECORD(
	VENDOR_ID			NUMBER,
	SEGMENT1			AP_SUPPLIERS.SEGMENT1%TYPE,
	VENDOR_NAME			AP_SUPPLIERS.VENDOR_NAME%TYPE,
	VENDOR_NAME_ALT			AP_SUPPLIERS.VENDOR_NAME_ALT%TYPE,
	SUMMARY_FLAG			AP_SUPPLIERS.SUMMARY_FLAG%TYPE,
	ENABLED_FLAG			AP_SUPPLIERS.ENABLED_FLAG%TYPE,
	SEGMENT2			AP_SUPPLIERS.SEGMENT2%TYPE,
	SEGMENT3			AP_SUPPLIERS.SEGMENT3%TYPE,
	SEGMENT4			AP_SUPPLIERS.SEGMENT4%TYPE,
	SEGMENT5			AP_SUPPLIERS.SEGMENT5%TYPE,
	EMPLOYEE_ID			NUMBER,
	VENDOR_TYPE_LOOKUP_CODE		AP_SUPPLIERS.VENDOR_TYPE_LOOKUP_CODE%TYPE,
	CUSTOMER_NUM			AP_SUPPLIERS.CUSTOMER_NUM%TYPE,
	ONE_TIME_FLAG			AP_SUPPLIERS.ONE_TIME_FLAG%TYPE,
	PARENT_VENDOR_ID 		NUMBER,
	MIN_ORDER_AMOUNT		NUMBER,
	TERMS_ID			NUMBER,
	SET_OF_BOOKS_ID			NUMBER,
	ALWAYS_TAKE_DISC_FLAG		AP_SUPPLIERS.ALWAYS_TAKE_DISC_FLAG%TYPE,
	PAY_DATE_BASIS_LOOKUP_CODE 	AP_SUPPLIERS.PAY_DATE_BASIS_LOOKUP_CODE%TYPE,
	PAY_GROUP_LOOKUP_CODE		AP_SUPPLIERS.PAY_GROUP_LOOKUP_CODE%TYPE,
	PAYMENT_PRIORITY		NUMBER,
	INVOICE_CURRENCY_CODE		AP_SUPPLIERS.INVOICE_CURRENCY_CODE%TYPE,
	PAYMENT_CURRENCY_CODE		AP_SUPPLIERS.PAYMENT_CURRENCY_CODE%TYPE,
	INVOICE_AMOUNT_LIMIT		NUMBER,
	HOLD_ALL_PAYMENTS_FLAG		AP_SUPPLIERS.HOLD_ALL_PAYMENTS_FLAG%TYPE,
	HOLD_FUTURE_PAYMENTS_FLAG 	AP_SUPPLIERS.HOLD_FUTURE_PAYMENTS_FLAG%TYPE,
	HOLD_REASON			AP_SUPPLIERS.HOLD_REASON%TYPE,
	TYPE_1099			AP_SUPPLIERS.TYPE_1099%TYPE,
	WITHHOLDING_STATUS_LOOKUP_CODE	AP_SUPPLIERS.WITHHOLDING_STATUS_LOOKUP_CODE%TYPE,
	WITHHOLDING_START_DATE		AP_SUPPLIERS.WITHHOLDING_START_DATE%TYPE,
	ORGANIZATION_TYPE_LOOKUP_CODE	AP_SUPPLIERS.ORGANIZATION_TYPE_LOOKUP_CODE%TYPE,
	START_DATE_ACTIVE		AP_SUPPLIERS.START_DATE_ACTIVE%TYPE,
	END_DATE_ACTIVE			AP_SUPPLIERS.END_DATE_ACTIVE%TYPE,
	MINORITY_GROUP_LOOKUP_CODE	AP_SUPPLIERS.MINORITY_GROUP_LOOKUP_CODE%TYPE,
	WOMEN_OWNED_FLAG		AP_SUPPLIERS.WOMEN_OWNED_FLAG%TYPE,
	SMALL_BUSINESS_FLAG		AP_SUPPLIERS.SMALL_BUSINESS_FLAG%TYPE,
	HOLD_FLAG			AP_SUPPLIERS.HOLD_FLAG%TYPE,
	PURCHASING_HOLD_REASON		AP_SUPPLIERS.PURCHASING_HOLD_REASON%TYPE,
	HOLD_BY				NUMBER,
	HOLD_DATE			AP_SUPPLIERS.HOLD_DATE%TYPE,
	TERMS_DATE_BASIS		AP_SUPPLIERS.TERMS_DATE_BASIS%TYPE,
	INSPECTION_REQUIRED_FLAG	AP_SUPPLIERS.INSPECTION_REQUIRED_FLAG%TYPE,
	RECEIPT_REQUIRED_FLAG		AP_SUPPLIERS.RECEIPT_REQUIRED_FLAG%TYPE,
	QTY_RCV_TOLERANCE		NUMBER,
	QTY_RCV_EXCEPTION_CODE		AP_SUPPLIERS.QTY_RCV_EXCEPTION_CODE%TYPE,
	ENFORCE_SHIP_TO_LOCATION_CODE	AP_SUPPLIERS.ENFORCE_SHIP_TO_LOCATION_CODE%TYPE,
	DAYS_EARLY_RECEIPT_ALLOWED	NUMBER,
	DAYS_LATE_RECEIPT_ALLOWED       NUMBER,
	RECEIPT_DAYS_EXCEPTION_CODE	AP_SUPPLIERS.RECEIPT_DAYS_EXCEPTION_CODE%TYPE,
	RECEIVING_ROUTING_ID		NUMBER,
	ALLOW_SUBSTITUTE_RECEIPTS_FLAG	AP_SUPPLIERS.ALLOW_SUBSTITUTE_RECEIPTS_FLAG%TYPE,
	ALLOW_UNORDERED_RECEIPTS_FLAG	AP_SUPPLIERS.ALLOW_UNORDERED_RECEIPTS_FLAG%TYPE,
	HOLD_UNMATCHED_INVOICES_FLAG	AP_SUPPLIERS.HOLD_UNMATCHED_INVOICES_FLAG%TYPE,
	TAX_VERIFICATION_DATE		AP_SUPPLIERS.TAX_VERIFICATION_DATE%TYPE,
	NAME_CONTROL			AP_SUPPLIERS.NAME_CONTROL%TYPE,
	STATE_REPORTABLE_FLAG		AP_SUPPLIERS.STATE_REPORTABLE_FLAG%TYPE,
	FEDERAL_REPORTABLE_FLAG		AP_SUPPLIERS.FEDERAL_REPORTABLE_FLAG%TYPE,
	ATTRIBUTE_CATEGORY		AP_SUPPLIERS.ATTRIBUTE_CATEGORY%TYPE,
	ATTRIBUTE1			AP_SUPPLIERS.ATTRIBUTE1%TYPE,
	ATTRIBUTE2			AP_SUPPLIERS.ATTRIBUTE2%TYPE,
	ATTRIBUTE3			AP_SUPPLIERS.ATTRIBUTE3%TYPE,
	ATTRIBUTE4			AP_SUPPLIERS.ATTRIBUTE4%TYPE,
	ATTRIBUTE5			AP_SUPPLIERS.ATTRIBUTE5%TYPE,
	ATTRIBUTE6			AP_SUPPLIERS.ATTRIBUTE6%TYPE,
	ATTRIBUTE7			AP_SUPPLIERS.ATTRIBUTE7%TYPE,
	ATTRIBUTE8			AP_SUPPLIERS.ATTRIBUTE8%TYPE,
	ATTRIBUTE9			AP_SUPPLIERS.ATTRIBUTE9%TYPE,
	ATTRIBUTE10			AP_SUPPLIERS.ATTRIBUTE10%TYPE,
	ATTRIBUTE11			AP_SUPPLIERS.ATTRIBUTE11%TYPE,
	ATTRIBUTE12			AP_SUPPLIERS.ATTRIBUTE12%TYPE,
	ATTRIBUTE13			AP_SUPPLIERS.ATTRIBUTE13%TYPE,
	ATTRIBUTE14			AP_SUPPLIERS.ATTRIBUTE14%TYPE,
	ATTRIBUTE15			AP_SUPPLIERS.ATTRIBUTE15%TYPE,
	AUTO_CALCULATE_INTEREST_FLAG	AP_SUPPLIERS.AUTO_CALCULATE_INTEREST_FLAG%TYPE,
	VALIDATION_NUMBER		NUMBER,
	EXCLUDE_FREIGHT_FROM_DISCOUNT	AP_SUPPLIERS.EXCLUDE_FREIGHT_FROM_DISCOUNT%TYPE,
	TAX_REPORTING_NAME		AP_SUPPLIERS.TAX_REPORTING_NAME%TYPE,
	CHECK_DIGITS			AP_SUPPLIERS.CHECK_DIGITS%TYPE,
	ALLOW_AWT_FLAG			AP_SUPPLIERS.ALLOW_AWT_FLAG%TYPE,
	AWT_GROUP_ID			NUMBER,
	AWT_GROUP_NAME			AP_AWT_GROUPS.NAME%TYPE,
        PAY_AWT_GROUP_ID                NUMBER,                 --bug6664407
        PAY_AWT_GROUP_NAME              AP_AWT_GROUPS.NAME%TYPE,--bug6664407
	GLOBAL_ATTRIBUTE1 		AP_SUPPLIERS.GLOBAL_ATTRIBUTE1%TYPE,
	GLOBAL_ATTRIBUTE2		AP_SUPPLIERS.GLOBAL_ATTRIBUTE2%TYPE,
	GLOBAL_ATTRIBUTE3		AP_SUPPLIERS.GLOBAL_ATTRIBUTE3%TYPE,
	GLOBAL_ATTRIBUTE4		AP_SUPPLIERS.GLOBAL_ATTRIBUTE4%TYPE,
	GLOBAL_ATTRIBUTE5		AP_SUPPLIERS.GLOBAL_ATTRIBUTE5%TYPE,
	GLOBAL_ATTRIBUTE6		AP_SUPPLIERS.GLOBAL_ATTRIBUTE6%TYPE,
	GLOBAL_ATTRIBUTE7 		AP_SUPPLIERS.GLOBAL_ATTRIBUTE7%TYPE,
	GLOBAL_ATTRIBUTE8		AP_SUPPLIERS.GLOBAL_ATTRIBUTE8%TYPE,
	GLOBAL_ATTRIBUTE9		AP_SUPPLIERS.GLOBAL_ATTRIBUTE9%TYPE,
	GLOBAL_ATTRIBUTE10		AP_SUPPLIERS.GLOBAL_ATTRIBUTE10%TYPE,
	GLOBAL_ATTRIBUTE11		AP_SUPPLIERS.GLOBAL_ATTRIBUTE11%TYPE,
	GLOBAL_ATTRIBUTE12		AP_SUPPLIERS.GLOBAL_ATTRIBUTE12%TYPE,
	GLOBAL_ATTRIBUTE13		AP_SUPPLIERS.GLOBAL_ATTRIBUTE13%TYPE,
	GLOBAL_ATTRIBUTE14		AP_SUPPLIERS.GLOBAL_ATTRIBUTE14%TYPE,
	GLOBAL_ATTRIBUTE15		AP_SUPPLIERS.GLOBAL_ATTRIBUTE15%TYPE,
	GLOBAL_ATTRIBUTE16		AP_SUPPLIERS.GLOBAL_ATTRIBUTE16%TYPE,
	GLOBAL_ATTRIBUTE17		AP_SUPPLIERS.GLOBAL_ATTRIBUTE17%TYPE,
	GLOBAL_ATTRIBUTE18		AP_SUPPLIERS.GLOBAL_ATTRIBUTE18%TYPE,
	GLOBAL_ATTRIBUTE19		AP_SUPPLIERS.GLOBAL_ATTRIBUTE19%TYPE,
	GLOBAL_ATTRIBUTE20		AP_SUPPLIERS.GLOBAL_ATTRIBUTE20%TYPE,
	GLOBAL_ATTRIBUTE_CATEGORY	AP_SUPPLIERS.GLOBAL_ATTRIBUTE_CATEGORY%TYPE,
	BANK_CHARGE_BEARER		AP_SUPPLIERS.BANK_CHARGE_BEARER%TYPE,
	MATCH_OPTION			AP_SUPPLIERS.MATCH_OPTION%TYPE,
	CREATE_DEBIT_MEMO_FLAG		AP_SUPPLIERS.CREATE_DEBIT_MEMO_FLAG%TYPE,
	PARTY_ID			NUMBER,
	PARENT_PARTY_ID			NUMBER,
        JGZZ_FISCAL_CODE                VARCHAR2(20),
        SIC_CODE                        VARCHAR2(30),
        TAX_REFERENCE                   VARCHAR2(50),
	INVENTORY_ORGANIZATION_ID	NUMBER,
	TERMS_NAME			AP_TERMS_TL.NAME%TYPE,
	DEFAULT_TERMS_ID		NUMBER,
    	VENDOR_INTERFACE_ID		NUMBER,
	NI_NUMBER			AP_SUPPLIERS.NI_NUMBER%TYPE,
	EXT_PAYEE_REC			IBY_DISBURSEMENT_SETUP_PUB.EXTERNAL_PAYEE_REC_TYPE,
	-- Bug 7437549 Start
        EDI_PAYMENT_FORMAT         AP_SUPPLIERS_INT.EDI_PAYMENT_FORMAT%TYPE,
        EDI_TRANSACTION_HANDLING   AP_SUPPLIERS_INT.EDI_TRANSACTION_HANDLING%TYPE,
        EDI_PAYMENT_METHOD         AP_SUPPLIERS_INT.EDI_PAYMENT_METHOD%TYPE,
        EDI_REMITTANCE_METHOD      AP_SUPPLIERS_INT.EDI_REMITTANCE_METHOD%TYPE,
        EDI_REMITTANCE_INSTRUCTION AP_SUPPLIERS_INT.EDI_REMITTANCE_INSTRUCTION%TYPE
        -- Bug 7437549 End
	,URL                            HZ_CONTACT_POINTS.URL%TYPE,	-- B# 7831956
	-- B# 7583123
	SUPPLIER_NOTIF_METHOD		AP_SUPPLIERS_INT.SUPPLIER_NOTIF_METHOD%TYPE,
	REMITTANCE_EMAIL                AP_SUPPLIERS_INT.REMITTANCE_EMAIL%TYPE
	,CEO_NAME                       AP_SUPPLIERS_INT.CEO_NAME%TYPE	-- B# 9081643
	,CEO_TITLE                      AP_SUPPLIERS_INT.CEO_TITLE%TYPE	-- B# 9081643
        ,VAT_CODE                       AP_SUPPLIERS.VAT_CODE%TYPE             -- B#9202909
        ,AUTO_TAX_CALC_FLAG             AP_SUPPLIERS.AUTO_TAX_CALC_FLAG%TYPE   -- B#9202909
        ,OFFSET_TAX_FLAG                AP_SUPPLIERS_INT.OFFSET_TAX_FLAG%TYPE  -- B#9202909
	,VAT_REGISTRATION_NUM		AP_SUPPLIERS_INT.VAT_REGISTRATION_NUM%TYPE -- B#9202909
	);

TYPE r_vendor_site_rec_type IS RECORD(
	AREA_CODE			AP_SUPPLIER_SITES_ALL.AREA_CODE%TYPE,
	PHONE				AP_SUPPLIER_SITES_ALL.PHONE%TYPE,
	CUSTOMER_NUM			AP_SUPPLIER_SITES_ALL.CUSTOMER_NUM%TYPE,
	SHIP_TO_LOCATION_ID		NUMBER,
	BILL_TO_LOCATION_ID		NUMBER,
	SHIP_VIA_LOOKUP_CODE		AP_SUPPLIER_SITES_ALL.SHIP_VIA_LOOKUP_CODE%TYPE,
	FREIGHT_TERMS_LOOKUP_CODE	AP_SUPPLIER_SITES_ALL.FREIGHT_TERMS_LOOKUP_CODE%TYPE,
	FOB_LOOKUP_CODE			AP_SUPPLIER_SITES_ALL.FOB_LOOKUP_CODE%TYPE,
	INACTIVE_DATE			AP_SUPPLIER_SITES_ALL.INACTIVE_DATE%TYPE,
	FAX				AP_SUPPLIER_SITES_ALL.FAX	%TYPE,
	FAX_AREA_CODE			AP_SUPPLIER_SITES_ALL.FAX_AREA_CODE%TYPE,
	TELEX				AP_SUPPLIER_SITES_ALL.TELEX%TYPE,
	TERMS_DATE_BASIS		AP_SUPPLIER_SITES_ALL.TERMS_DATE_BASIS%TYPE,
	DISTRIBUTION_SET_ID		NUMBER,
	ACCTS_PAY_CODE_COMBINATION_ID	NUMBER,
	PREPAY_CODE_COMBINATION_ID	NUMBER,
	PAY_GROUP_LOOKUP_CODE		AP_SUPPLIER_SITES_ALL.PAY_GROUP_LOOKUP_CODE%TYPE,
	PAYMENT_PRIORITY		NUMBER,
	TERMS_ID			NUMBER,
	INVOICE_AMOUNT_LIMIT		AP_SUPPLIER_SITES_ALL.INVOICE_AMOUNT_LIMIT%TYPE,
	PAY_DATE_BASIS_LOOKUP_CODE	AP_SUPPLIER_SITES_ALL.PAY_DATE_BASIS_LOOKUP_CODE%TYPE,
	ALWAYS_TAKE_DISC_FLAG		AP_SUPPLIER_SITES_ALL.ALWAYS_TAKE_DISC_FLAG%TYPE,
	INVOICE_CURRENCY_CODE		AP_SUPPLIER_SITES_ALL.INVOICE_CURRENCY_CODE%TYPE,
	PAYMENT_CURRENCY_CODE		AP_SUPPLIER_SITES_ALL.PAYMENT_CURRENCY_CODE%TYPE,
	VENDOR_SITE_ID			NUMBER,
	LAST_UPDATE_DATE		AP_SUPPLIER_SITES_ALL.LAST_UPDATE_DATE%TYPE,
	LAST_UPDATED_BY			AP_SUPPLIER_SITES_ALL.LAST_UPDATED_BY%TYPE,
	VENDOR_ID		        NUMBER,
	VENDOR_SITE_CODE		AP_SUPPLIER_SITES_ALL.VENDOR_SITE_CODE%TYPE,
	VENDOR_SITE_CODE_ALT		AP_SUPPLIER_SITES_ALL.VENDOR_SITE_CODE_ALT%TYPE,
	PURCHASING_SITE_FLAG		AP_SUPPLIER_SITES_ALL.PURCHASING_SITE_FLAG%TYPE,
	RFQ_ONLY_SITE_FLAG		AP_SUPPLIER_SITES_ALL.RFQ_ONLY_SITE_FLAG%TYPE,
	PAY_SITE_FLAG			AP_SUPPLIER_SITES_ALL.PAY_SITE_FLAG%TYPE,
	ATTENTION_AR_FLAG		AP_SUPPLIER_SITES_ALL.ATTENTION_AR_FLAG%TYPE,
	HOLD_ALL_PAYMENTS_FLAG		AP_SUPPLIER_SITES_ALL.HOLD_ALL_PAYMENTS_FLAG%TYPE,
	HOLD_FUTURE_PAYMENTS_FLAG	AP_SUPPLIER_SITES_ALL.HOLD_FUTURE_PAYMENTS_FLAG%TYPE,
	HOLD_REASON			AP_SUPPLIER_SITES_ALL.HOLD_REASON%TYPE,
	HOLD_UNMATCHED_INVOICES_FLAG	AP_SUPPLIER_SITES_ALL.HOLD_UNMATCHED_INVOICES_FLAG%TYPE,
	TAX_REPORTING_SITE_FLAG		AP_SUPPLIER_SITES_ALL.TAX_REPORTING_SITE_FLAG%TYPE,
	ATTRIBUTE_CATEGORY		AP_SUPPLIER_SITES_ALL.ATTRIBUTE_CATEGORY%TYPE,
	ATTRIBUTE1			AP_SUPPLIER_SITES_ALL.ATTRIBUTE1%TYPE,
	ATTRIBUTE2			AP_SUPPLIER_SITES_ALL.ATTRIBUTE2%TYPE,
	ATTRIBUTE3			AP_SUPPLIER_SITES_ALL.ATTRIBUTE3%TYPE,
	ATTRIBUTE4			AP_SUPPLIER_SITES_ALL.ATTRIBUTE4%TYPE,
	ATTRIBUTE5			AP_SUPPLIER_SITES_ALL.ATTRIBUTE5%TYPE,
	ATTRIBUTE6			AP_SUPPLIER_SITES_ALL.ATTRIBUTE6%TYPE,
	ATTRIBUTE7			AP_SUPPLIER_SITES_ALL.ATTRIBUTE7%TYPE,
	ATTRIBUTE8			AP_SUPPLIER_SITES_ALL.ATTRIBUTE8%TYPE,
	ATTRIBUTE9			AP_SUPPLIER_SITES_ALL.ATTRIBUTE9%TYPE,
	ATTRIBUTE10			AP_SUPPLIER_SITES_ALL.ATTRIBUTE10%TYPE,
	ATTRIBUTE11			AP_SUPPLIER_SITES_ALL.ATTRIBUTE11%TYPE,
	ATTRIBUTE12			AP_SUPPLIER_SITES_ALL.ATTRIBUTE12%TYPE,
	ATTRIBUTE13			AP_SUPPLIER_SITES_ALL.ATTRIBUTE13%TYPE,
	ATTRIBUTE14			AP_SUPPLIER_SITES_ALL.ATTRIBUTE14%TYPE,
	ATTRIBUTE15			AP_SUPPLIER_SITES_ALL.ATTRIBUTE15%TYPE,
	VALIDATION_NUMBER	        NUMBER,
	EXCLUDE_FREIGHT_FROM_DISCOUNT	AP_SUPPLIER_SITES_ALL.EXCLUDE_FREIGHT_FROM_DISCOUNT%TYPE,
	BANK_CHARGE_BEARER		AP_SUPPLIER_SITES_ALL.BANK_CHARGE_BEARER%TYPE,
	ORG_ID				NUMBER,
	CHECK_DIGITS			AP_SUPPLIER_SITES_ALL.CHECK_DIGITS%TYPE,
	ALLOW_AWT_FLAG			AP_SUPPLIER_SITES_ALL.ALLOW_AWT_FLAG%TYPE,
	AWT_GROUP_ID			NUMBER,
        PAY_AWT_GROUP_ID                NUMBER,                 --bug6664407
	DEFAULT_PAY_SITE_ID		NUMBER,
	PAY_ON_CODE			AP_SUPPLIER_SITES_ALL.PAY_ON_CODE%TYPE,
	PAY_ON_RECEIPT_SUMMARY_CODE	AP_SUPPLIER_SITES_ALL.PAY_ON_RECEIPT_SUMMARY_CODE%TYPE,
	GLOBAL_ATTRIBUTE_CATEGORY	AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE_CATEGORY%TYPE,
	GLOBAL_ATTRIBUTE1		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE1%TYPE,
	GLOBAL_ATTRIBUTE2		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE2%TYPE,
	GLOBAL_ATTRIBUTE3		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE3%TYPE,
	GLOBAL_ATTRIBUTE4		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE4%TYPE,
	GLOBAL_ATTRIBUTE5		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE5%TYPE,
	GLOBAL_ATTRIBUTE6		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE6%TYPE,
	GLOBAL_ATTRIBUTE7		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE7%TYPE,
	GLOBAL_ATTRIBUTE8		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE8%TYPE,
	GLOBAL_ATTRIBUTE9		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE9%TYPE,
	GLOBAL_ATTRIBUTE10		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE10%TYPE,
	GLOBAL_ATTRIBUTE11		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE11%TYPE,
	GLOBAL_ATTRIBUTE12		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE12%TYPE,
	GLOBAL_ATTRIBUTE13		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE13%TYPE,
	GLOBAL_ATTRIBUTE14		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE14%TYPE,
	GLOBAL_ATTRIBUTE15		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE15%TYPE,
	GLOBAL_ATTRIBUTE16		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE16%TYPE,
	GLOBAL_ATTRIBUTE17		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE17%TYPE,
	GLOBAL_ATTRIBUTE18		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE18%TYPE,
	GLOBAL_ATTRIBUTE19		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE19%TYPE,
	GLOBAL_ATTRIBUTE20		AP_SUPPLIER_SITES_ALL.GLOBAL_ATTRIBUTE20%TYPE,
	TP_HEADER_ID			NUMBER,
	ECE_TP_LOCATION_CODE		AP_SUPPLIER_SITES_ALL.ECE_TP_LOCATION_CODE%TYPE,
	PCARD_SITE_FLAG			AP_SUPPLIER_SITES_ALL.PCARD_SITE_FLAG%TYPE,
	MATCH_OPTION			AP_SUPPLIER_SITES_ALL.MATCH_OPTION%TYPE,
	COUNTRY_OF_ORIGIN_CODE		AP_SUPPLIER_SITES_ALL.COUNTRY_OF_ORIGIN_CODE%TYPE,
	FUTURE_DATED_PAYMENT_CCID	NUMBER,
	CREATE_DEBIT_MEMO_FLAG		AP_SUPPLIER_SITES_ALL.CREATE_DEBIT_MEMO_FLAG%TYPE,
	SUPPLIER_NOTIF_METHOD		AP_SUPPLIER_SITES_ALL.SUPPLIER_NOTIF_METHOD%TYPE,
	EMAIL_ADDRESS			AP_SUPPLIER_SITES_ALL.EMAIL_ADDRESS%TYPE,
	PRIMARY_PAY_SITE_FLAG		AP_SUPPLIER_SITES_ALL.PRIMARY_PAY_SITE_FLAG%TYPE,
	SHIPPING_CONTROL		AP_SUPPLIER_SITES_ALL.SHIPPING_CONTROL%TYPE,
	SELLING_COMPANY_IDENTIFIER	AP_SUPPLIER_SITES_ALL.SELLING_COMPANY_IDENTIFIER%TYPE,
	GAPLESS_INV_NUM_FLAG		AP_SUPPLIER_SITES_ALL.GAPLESS_INV_NUM_FLAG%TYPE,
	LOCATION_ID			NUMBER,
	PARTY_SITE_ID			NUMBER,
	ORG_NAME			HR_OPERATING_UNITS.NAME%TYPE,
        DUNS_NUMBER     		AP_SUPPLIER_SITES_ALL.DUNS_NUMBER%TYPE,
        ADDRESS_STYLE   		AP_SUPPLIER_SITES_ALL.ADDRESS_STYLE%TYPE,
        LANGUAGE        		AP_SUPPLIER_SITES_ALL.LANGUAGE%TYPE,
        PROVINCE        		AP_SUPPLIER_SITES_ALL.PROVINCE%TYPE,
        COUNTRY         		AP_SUPPLIER_SITES_ALL.COUNTRY%TYPE,
        ADDRESS_LINE1   		AP_SUPPLIER_SITES_ALL.ADDRESS_LINE1%TYPE,
        ADDRESS_LINE2   		AP_SUPPLIER_SITES_ALL.ADDRESS_LINE2%TYPE,
        ADDRESS_LINE3   		AP_SUPPLIER_SITES_ALL.ADDRESS_LINE3%TYPE,
        ADDRESS_LINE4   		AP_SUPPLIER_SITES_ALL.ADDRESS_LINE4%TYPE,
        ADDRESS_LINES_ALT       	AP_SUPPLIER_SITES_ALL.ADDRESS_LINES_ALT%TYPE,
        COUNTY          		AP_SUPPLIER_SITES_ALL.COUNTY%TYPE,
        CITY            		AP_SUPPLIER_SITES_ALL.CITY%TYPE,
        STATE           		AP_SUPPLIER_SITES_ALL.STATE%TYPE,
        ZIP             		AP_SUPPLIER_SITES_ALL.ZIP%TYPE,
       	TERMS_NAME			AP_TERMS_TL.NAME%TYPE,
	DEFAULT_TERMS_ID		NUMBER,
	AWT_GROUP_NAME			AP_AWT_GROUPS.NAME%TYPE,
        PAY_AWT_GROUP_NAME              AP_AWT_GROUPS.NAME%TYPE,--bug6664407
        DISTRIBUTION_SET_NAME		AP_DISTRIBUTION_SETS_ALL.DISTRIBUTION_SET_NAME%TYPE,
        SHIP_TO_LOCATION_CODE           HR_LOCATIONS_ALL_TL.LOCATION_CODE%TYPE,
        BILL_TO_LOCATION_CODE           HR_LOCATIONS_ALL_TL.LOCATION_CODE%TYPE,
    	DEFAULT_DIST_SET_ID             NUMBER,
        DEFAULT_SHIP_TO_LOC_ID          NUMBER,
        DEFAULT_BILL_TO_LOC_ID          NUMBER,
	TOLERANCE_ID			NUMBER,
	TOLERANCE_NAME			AP_TOLERANCE_TEMPLATES.TOLERANCE_NAME%TYPE,
    	VENDOR_INTERFACE_ID		NUMBER,
    	VENDOR_SITE_INTERFACE_ID	NUMBER,
        EXT_PAYEE_REC			IBY_DISBURSEMENT_SETUP_PUB.EXTERNAL_PAYEE_REC_TYPE,
	RETAINAGE_RATE			NUMBER DEFAULT NULL,
        SERVICES_TOLERANCE_ID           NUMBER,
        SERVICES_TOLERANCE_NAME         AP_TOLERANCE_TEMPLATES.TOLERANCE_NAME%TYPE,
        SHIPPING_LOCATION_ID            NUMBER,
        VAT_CODE                        AP_SUPPLIER_SITES_ALL.VAT_CODE%TYPE,
	VAT_REGISTRATION_NUM		AP_SUPPLIER_SITES_INT.VAT_REGISTRATION_NUM%TYPE, -- Bug 7197036
	REMITTANCE_EMAIL		AP_SUPPLIER_SITES_INT.REMITTANCE_EMAIL%TYPE, -- Bug 7339389
	-- Bug 7437549 Start
        EDI_ID_NUMBER              AP_SUPPLIER_SITES_INT.EDI_ID_NUMBER%TYPE,
        EDI_PAYMENT_FORMAT         AP_SUPPLIER_SITES_INT.EDI_PAYMENT_FORMAT%TYPE,
        EDI_TRANSACTION_HANDLING   AP_SUPPLIER_SITES_INT.EDI_TRANSACTION_HANDLING%TYPE,
        EDI_PAYMENT_METHOD         AP_SUPPLIER_SITES_INT.EDI_PAYMENT_METHOD%TYPE,
        EDI_REMITTANCE_METHOD      AP_SUPPLIER_SITES_INT.EDI_REMITTANCE_METHOD%TYPE,
        EDI_REMITTANCE_INSTRUCTION AP_SUPPLIER_SITES_INT.EDI_REMITTANCE_INSTRUCTION%TYPE,
        -- Bug 7437549 End
        PARTY_SITE_NAME            HZ_PARTY_SITES.PARTY_SITE_NAME%TYPE, -- Bug 7429668
        OFFSET_TAX_FLAG             AP_SUPPLIER_SITES_INT.OFFSET_TAX_FLAG%TYPE, -- Bug#7506443
        AUTO_TAX_CALC_FLAG          AP_SUPPLIER_SITES_INT.AUTO_TAX_CALC_FLAG%TYPE -- Bug#7506443
	,REMIT_ADVICE_DELIVERY_METHOD AP_SUPPLIER_SITES_INT.REMIT_ADVICE_DELIVERY_METHOD%TYPE  -- Bug 8422781
	,REMIT_ADVICE_FAX           AP_SUPPLIER_SITES_INT.REMIT_ADVICE_FAX%TYPE -- Bug 8769088
  -- starting the Changes for CLM reference data management bug#9499174
	,CAGE_CODE                     AP_SUPPLIER_SITES_ALL.CAGE_CODE%TYPE ,
        LEGAL_BUSINESS_NAME            AP_SUPPLIER_SITES_ALL.LEGAL_BUSINESS_NAME%TYPE ,
        DOING_BUS_AS_NAME              AP_SUPPLIER_SITES_ALL.DOING_BUS_AS_NAME%TYPE ,
        DIVISION_NAME                  AP_SUPPLIER_SITES_ALL.DIVISION_NAME%TYPE ,
        SMALL_BUSINESS_CODE            AP_SUPPLIER_SITES_ALL.SMALL_BUSINESS_CODE%TYPE ,
        CCR_COMMENTS                   AP_SUPPLIER_SITES_ALL.CCR_COMMENTS%TYPE ,
        DEBARMENT_START_DATE           AP_SUPPLIER_SITES_ALL.DEBARMENT_START_DATE%TYPE ,
        DEBARMENT_END_DATE             AP_SUPPLIER_SITES_ALL.DEBARMENT_END_DATE%TYPE
	,AP_TAX_ROUNDING_RULE		ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE /* Bug 9530837 */
	,AMOUNT_INCLUDES_TAX_FLAG	ZX_PARTY_TAX_PROFILE.INCLUSIVE_TAX_FLAG%TYPE /* Bug 9530837 */
	);
  -- Ending the Changes for CLM reference data management bug#9499174
-- VAT_CODE ADDED TO ABOVE STRUCTURE Bug 6645014
-- To Import the VAT Code in Sites.

-- bug 6745669 - added attribute_category to vendor contact record

TYPE r_vendor_contact_rec_type IS RECORD(
	VENDOR_CONTACT_ID		NUMBER,
	VENDOR_SITE_ID			NUMBER,
	VENDOR_ID       		NUMBER,
 	PER_PARTY_ID			NUMBER,
 	RELATIONSHIP_ID			NUMBER,
 	REL_PARTY_ID			NUMBER,
 	PARTY_SITE_ID			NUMBER,
 	ORG_CONTACT_ID			NUMBER,
	ORG_PARTY_SITE_ID		NUMBER,
	PERSON_FIRST_NAME		AP_SUPPLIER_CONTACTS.FIRST_NAME%TYPE,
	PERSON_MIDDLE_NAME		AP_SUPPLIER_CONTACTS.MIDDLE_NAME%TYPE,
	PERSON_LAST_NAME		AP_SUPPLIER_CONTACTS.LAST_NAME%TYPE,
	PERSON_TITLE			AP_SUPPLIER_CONTACTS.TITLE%TYPE,
	ORGANIZATION_NAME_PHONETIC	VARCHAR2(320),
	PERSON_FIRST_NAME_PHONETIC	AP_SUPPLIER_CONTACTS.FIRST_NAME_ALT%TYPE,
	PERSON_LAST_NAME_PHONETIC	AP_SUPPLIER_CONTACTS.LAST_NAME_ALT%TYPE,
	ATTRIBUTE_CATEGORY			AP_SUPPLIER_CONTACTS.ATTRIBUTE_CATEGORY%TYPE,
	ATTRIBUTE1			AP_SUPPLIER_CONTACTS.ATTRIBUTE1%TYPE,
	ATTRIBUTE2			AP_SUPPLIER_CONTACTS.ATTRIBUTE2%TYPE,
	ATTRIBUTE3			AP_SUPPLIER_CONTACTS.ATTRIBUTE3%TYPE,
	ATTRIBUTE4			AP_SUPPLIER_CONTACTS.ATTRIBUTE4%TYPE,
	ATTRIBUTE5			AP_SUPPLIER_CONTACTS.ATTRIBUTE5%TYPE,
	ATTRIBUTE6			AP_SUPPLIER_CONTACTS.ATTRIBUTE6%TYPE,
	ATTRIBUTE7			AP_SUPPLIER_CONTACTS.ATTRIBUTE7%TYPE,
	ATTRIBUTE8			AP_SUPPLIER_CONTACTS.ATTRIBUTE8%TYPE,
	ATTRIBUTE9			AP_SUPPLIER_CONTACTS.ATTRIBUTE9%TYPE,
	ATTRIBUTE10			AP_SUPPLIER_CONTACTS.ATTRIBUTE10%TYPE,
	ATTRIBUTE11			AP_SUPPLIER_CONTACTS.ATTRIBUTE11%TYPE,
	ATTRIBUTE12			AP_SUPPLIER_CONTACTS.ATTRIBUTE12%TYPE,
	ATTRIBUTE13			AP_SUPPLIER_CONTACTS.ATTRIBUTE13%TYPE,
	ATTRIBUTE14			AP_SUPPLIER_CONTACTS.ATTRIBUTE14%TYPE,
	ATTRIBUTE15			AP_SUPPLIER_CONTACTS.ATTRIBUTE15%TYPE,
	INACTIVE_DATE			AP_SUPPLIER_CONTACTS.INACTIVE_DATE%TYPE,
	PARTY_NUMBER			VARCHAR2(30),
	DEPARTMENT			AP_SUPPLIER_CONTACTS.DEPARTMENT%TYPE,
	MAIL_STOP			AP_SUPPLIER_CONTACTS.MAIL_STOP%TYPE,
	AREA_CODE			AP_SUPPLIER_CONTACTS.AREA_CODE%TYPE,
	PHONE				AP_SUPPLIER_CONTACTS.PHONE%TYPE,
	ALT_AREA_CODE			AP_SUPPLIER_CONTACTS.ALT_AREA_CODE%TYPE,
	ALT_PHONE			AP_SUPPLIER_CONTACTS.ALT_PHONE%TYPE,
	FAX_AREA_CODE			AP_SUPPLIER_CONTACTS.FAX_AREA_CODE%TYPE,
	FAX_PHONE			AP_SUPPLIER_CONTACTS.FAX%TYPE,
	EMAIL_ADDRESS			AP_SUPPLIER_CONTACTS.EMAIL_ADDRESS%TYPE,
	URL				AP_SUPPLIER_CONTACTS.URL%TYPE,
        VENDOR_CONTACT_INTERFACE_ID	NUMBER,
        VENDOR_INTERFACE_ID		NUMBER,
        VENDOR_SITE_CODE		AP_SUP_SITE_CONTACT_INT.VENDOR_SITE_CODE%TYPE,
        ORG_ID				NUMBER,
        OPERATING_UNIT_NAME		AP_SUP_SITE_CONTACT_INT.OPERATING_UNIT_NAME%TYPE,
        PREFIX				AP_SUP_SITE_CONTACT_INT.PREFIX%TYPE,
        CONTACT_NAME_PHONETIC		AP_SUP_SITE_CONTACT_INT.CONTACT_NAME_ALT%TYPE,
	PARTY_SITE_NAME  HZ_PARTY_SITES.PARTY_SITE_NAME%TYPE -- Bug 7013954
        );


-- Start of comments
--	API name 	: Create_Vendor
--	Type		: Public
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version IN NUMBER  Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level IN NUMBER Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count		OUT	NUMBER
--				x_msg_data		OUT     VARCHAR2(2000)
--				parameter1
--				parameter2
--				.
--				.
--	Version		: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: Vendor API, called from various features and other
--			  products, to create new vendors
--
-- End of comments
-- Bug 7553276 Added annotation for integration repository.
/*#
 * This procedure is used to create Supplier in Payables and populate other
 * internal tables with supplier information.
 * @param p_api_version The version of the API
 * @param p_init_msg_list The initialize message list
 * @param p_commit The Commit flag
 * @param p_validation_level The validation level
 * @param x_return_status The return status
 * @param x_msg_count The message count
 * @param x_msg_data The message data
 * @param p_vendor_rec The Supplier record
 * @param x_vendor_id The Supplier Identifier
 * @param x_party_id The Party Identifier
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Supplier
 * @rep:category BUSINESS_ENTITY AP_SUPPLIER
 */
PROCEDURE Create_Vendor
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY  VARCHAR2,
	x_msg_count		OUT	NOCOPY  NUMBER,
	x_msg_data		OUT	NOCOPY  VARCHAR2,
	p_vendor_rec		IN	r_vendor_rec_type,
	x_vendor_id		OUT	NOCOPY  AP_SUPPLIERS.VENDOR_ID%TYPE,
	x_party_id		OUT	NOCOPY  HZ_PARTIES.PARTY_ID%TYPE
);

-- Start of comments
--	API name 	: Update_Vendor
--	Type		: Public
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version IN NUMBER  Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level IN NUMBER Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count		OUT	NUMBER
--				x_msg_data		OUT     VARCHAR2(2000)
--				parameter1
--				parameter2
--				.
--				.
--	Version		: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: Vendor API, called from various features and other
--			  products, to update vendors.
--			  This API will not update any TCA tables
-- End of comments

PROCEDURE Update_Vendor
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_rec		IN	r_vendor_rec_type,
	p_vendor_id		IN	NUMBER
);

-- Start of comments
--	API name 	: Validate_Vendor
--	Type		: Public
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version IN NUMBER  Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level IN NUMBER Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count		OUT	NUMBER
--				x_msg_data		OUT     VARCHAR2(2000)
--				parameter1
--				parameter2
--				.
--				.
--	Version		: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: Vendor API, called from various features and other
--			  products, to validate a vendor record.
--
-- End of comments

PROCEDURE Validate_Vendor
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_rec		IN OUT	NOCOPY r_vendor_rec_type,
	p_mode			IN	VARCHAR2,
	p_calling_prog		IN	VARCHAR2,
	x_party_valid		OUT	NOCOPY VARCHAR2,
	x_payee_valid		OUT	NOCOPY VARCHAR2,
	p_vendor_id		IN	NUMBER
);

-- Start of comments
--	API name 	: Create_Vendor_Site
--	Type		: Public
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version IN NUMBER  Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level IN NUMBER Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count		OUT	NUMBER
--				x_msg_data		OUT     VARCHAR2(2000)
--				parameter1
--				parameter2
--				.
--				.
--	Version		: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: Vendor Site API, called from various features and other
--			  products, to create new vendor site.
--
-- End of comments
-- Bug 7553276 Added annotation for integration repository.
/*#
 * This procedure is used to create Supplier Site in Payables and populate other
 * internal tables with the site information.
 * @param p_api_version The version of the API
 * @param p_init_msg_list The initialize message list
 * @param p_commit The Commit flag
 * @param p_validation_level The validation level
 * @param x_return_status The return status
 * @param x_msg_count The message count
 * @param x_msg_data The message data
 * @param p_vendor_site_rec Supplier Site record
 * @param x_vendor_site_id Supplier Site Identifier
 * @param x_party_site_id Party Site Identifier for Supplier Site
 * @param x_location_id Location Identifier for Supplier Site
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Supplier Site
 * @rep:category BUSINESS_ENTITY AP_SUPPLIER_SITE
 */
PROCEDURE Create_Vendor_Site
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_site_rec	IN	r_vendor_site_rec_type,
	x_vendor_site_id	OUT	NOCOPY NUMBER,
	x_party_site_id		OUT	NOCOPY NUMBER,
	x_location_id		OUT	NOCOPY NUMBER
);

-- Start of comments
--	API name 	: Update_Vendor_Site
--	Type		: Public
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version IN NUMBER  Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level IN NUMBER Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count		OUT	NUMBER
--				x_msg_data		OUT     VARCHAR2(2000)
--				parameter1
--				parameter2
--				.
--				.
--	Version		: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: Vendor Site API, called from various features and other
--			  products, to update vendor site.
--			  This API will not update any TCA records.
-- End of comments

PROCEDURE Update_Vendor_Site
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_site_rec	IN	r_vendor_site_rec_type,
	p_vendor_site_id	IN	NUMBER,
	p_calling_prog		IN	VARCHAR2 DEFAULT 'NOT ISETUP'
);

-- Start of comments
--	API name 	: Validate_Vendor_Site
--	Type		: Public
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version IN NUMBER  Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level IN NUMBER Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count		OUT	NUMBER
--				x_msg_data		OUT     VARCHAR2(2000)
--				parameter1
--				parameter2
--				.
--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Vendor Site API, called from various features and other
--			  products, to validate vendor site record fields.
--
-- End of comments

PROCEDURE Validate_Vendor_Site
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_site_rec	IN OUT	NOCOPY r_vendor_site_rec_type,
	p_mode			IN	VARCHAR2,
	p_calling_prog		IN	VARCHAR2,
	x_party_site_valid	OUT	NOCOPY VARCHAR2,
	x_location_valid	OUT	NOCOPY VARCHAR2,
	x_payee_valid		OUT	NOCOPY VARCHAR2,
	p_vendor_site_id	IN	NUMBER
);

-- Start of comments
--	API name 	: Create_Vendor_Contact
--	Type		: Public
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version IN NUMBER  Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level IN NUMBER Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count		OUT	NUMBER
--				x_msg_data		OUT     VARCHAR2(2000)
--				parameter1
--				parameter2
--				.
--				.
--	Version		: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: Vendor Contact API, called from various features and other
--				products, to create new vendor contact record.
--
-- End of comments
/*#
 * This procedure is used to create Supplier Contact in Payables and populate
 * other internal tables with supplier contact information.
 * @param p_api_version The version of the API
 * @param p_init_msg_list The initialize message list
 * @param p_commit The Commit flag
 * @param p_validation_level The validation level
 * @param x_return_status The return status
 * @param x_msg_count The message count
 * @param x_msg_data The message data
 * @param p_vendor_contact_rec Supplier Contact record
 * @param x_vendor_contact_id Supplier Contact Identifier
 * @param x_per_party_id Person Party Identifier created for Contact
 * @param x_rel_party_id Relationship Party Identifier created for Contact
 * @param x_rel_id Relationship Identifier for Contact with Supplier
 * @param x_org_contact_id Organization Identifier for Contact
 * @param x_party_site_id Party Site Identifier for Contact
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Supplier Contact
 * @rep:category BUSINESS_ENTITY AP_SUPPLIER_CONTACT
 */
PROCEDURE Create_Vendor_Contact
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_contact_rec	IN	r_vendor_contact_rec_type,
	x_vendor_contact_id	OUT	NOCOPY NUMBER,
	x_per_party_id		OUT	NOCOPY NUMBER,
	x_rel_party_id		OUT 	NOCOPY NUMBER,
	x_rel_id		OUT	NOCOPY NUMBER,
	x_org_contact_id	OUT	NOCOPY NUMBER,
	x_party_site_id		OUT	NOCOPY NUMBER
);

-- Start of comments
--	API name 	: Update_Vendor_Contact
--	Type		: Public
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version IN NUMBER  Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level IN NUMBER Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count		OUT	NUMBER
--				x_msg_data		OUT     VARCHAR2(2000)
--	Version		: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: Vendor Contact API, called from various features and other
--				products, to update existing vendor contact record.
--
-- End of comments

PROCEDURE Update_Vendor_Contact
( 	p_api_version       IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:=  FND_API.G_VALID_LEVEL_FULL,
	p_vendor_contact_rec	IN	r_vendor_contact_rec_type,
	x_return_status		OUT	NOCOPY VARCHAR2		  	,
	x_msg_count		    OUT	NOCOPY NUMBER,
	x_msg_data		    OUT	NOCOPY VARCHAR2
);

-- Start of comments
--	API name 	: Validate_Vendor_Contact
--	Type		: Public
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version IN NUMBER  Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level IN NUMBER Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count		OUT	NUMBER
--				x_msg_data		OUT     VARCHAR2(2000)
--				parameter1
--				parameter2
--				.
--				.
--	Version		: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: Vendor Contact API, called from various features and other
--			  products, to validate vendor contact record fields.
--
-- End of comments

PROCEDURE Validate_Vendor_Contact
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_contact_rec	IN OUT	NOCOPY r_vendor_contact_rec_type,
	x_rel_party_valid 	OUT 	NOCOPY VARCHAR2,
	x_per_party_valid 	OUT 	NOCOPY VARCHAR2,
	x_rel_valid 		OUT 	NOCOPY VARCHAR2,
	x_org_party_id		OUT	NOCOPY NUMBER,
	x_org_contact_valid 	OUT 	NOCOPY VARCHAR2,
	x_location_id		OUT 	NOCOPY NUMBER,
        x_party_site_valid      OUT     NOCOPY VARCHAR2
);

-- Start of comments
--      API name        : Import_Vendors
--      Type            : Public
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              :       p_api_version IN NUMBER  Required
--                              p_source IN VARCHAR2 Optional
--                                      Default = 'IMPORT'
--                              p_what_to_import IN VARCHAR2 Optional
--                                      Default = NULL
--                              p_commit_size IN NUMBER OPTIONAL
--                                      Default = 100
--                              .
--                              .
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--                              .
--                              .
--      Version 	: Current version       1.0
--                        Initial version       1.0
--
--      Notes           : Import Vendors,
--                        called from Import Vendor Concurrent Program
--                        This will call vendor APIS to
--                        create vendors based on AP_SUPPLIERS_INT
--
-- End of comments

PROCEDURE Import_Vendors
(       p_api_version           IN      NUMBER,
        p_source                IN      VARCHAR2 DEFAULT 'IMPORT',
        p_what_to_import        IN      VARCHAR2 DEFAULT NULL,
        p_commit_size           IN      NUMBER   DEFAULT 1000,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2
);

-- Start of comments
--      API name        : Import_Vendor_Sites
--      Type            : Public
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              :       p_api_version IN NUMBER  Required
--                              p_source IN VARCHAR2 Optional
--                                      Default = 'IMPORT'
--                              p_what_to_import IN VARCHAR2 Optional
--                                      Default = NULL
--                              p_commit_size IN NUMBER OPTIONAL
--                                      Default = 100
--                              .
--                              .
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--                              .
--                              .
--      Version 	: Current version       1.0
--                        Initial version       1.0
--
--      Notes           : Import Vendor Sites,
--                        called from Import Vendor Sites Conc Program
--                        This will call vendor sites API to create
--                        vendor sitess based on AP_SUPPLIER_SITES_INT
--
-- End of comments

PROCEDURE Import_Vendor_Sites
(       p_api_version           IN  NUMBER,
        p_source                IN  VARCHAR2 DEFAULT 'IMPORT',
        p_what_to_import        IN  VARCHAR2 DEFAULT NULL,
        p_commit_size           IN  NUMBER   DEFAULT 1000,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2
);


-- Start of comments
--      API name        : Import_Vendor_Contacts
--      Type            : Public
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              :       p_api_version IN NUMBER  Required
--                              p_source IN VARCHAR2 Optional
--                                      Default = 'IMPORT'
--                              p_what_to_import IN VARCHAR2 Optional
--                                      Default = NULL
--                              p_commit_size IN NUMBER OPTIONAL
--                                      Default = 100
--                              .
--                              .
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--                              .
--                              .
--      Version 	: Current version       1.0
--                        Initial version       1.0
--
--      Notes           : Import Vendor Contacts,
--                        called from Import Vendor Contacts Conc Program
--                        This will call vendor sites API to create vendor
--                        contacts based on AP_SUP_SITE_CONTACT_INT
--
-- End of comments

PROCEDURE Import_Vendor_Contacts
(       p_api_version           IN  NUMBER,
        p_source                IN  VARCHAR2 DEFAULT 'IMPORT',
        p_what_to_import        IN  VARCHAR2 DEFAULT NULL,
        p_commit_size           IN  NUMBER   DEFAULT 1000,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2
);

function is_taxpayer_id_valid(
    p_taxpayer_id     IN VARCHAR2,
    p_country         IN VARCHAR2
)
RETURN VARCHAR2;

-- Bug 6745669
-- Start of comments
--      API name        : Update_Address_Assignments_DFF
--      Type            : Public
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              :       p_api_version IN NUMBER  Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--                              p_attribute_category IN VARCHAR2 Optional
--                                      Default = NULL
--                              p_attribute1-15 IN VARCHAR2 Optional
--                                      Default = NULL
--                              .
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--                              .
--                              .
--      Version 	: Current version       1.0
--                        Initial version       1.0
--
--      Notes           : Update Address Assignments DFF,called from various
--      		  features and other products,
--                        This will update the DFF columns of the address
--                        assignments contacts in AP_SUPPLIER_CONTACTS
--                        The database values of Attribute_Category and
--                        the Attributes 1-15, will be updated to whatever is
--                        passed to the API and the default value is null.
--
-- End of comments

PROCEDURE Update_Address_Assignments_DFF(
        p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
        p_contact_party_id      IN      NUMBER,
        p_org_party_site_id     IN      NUMBER,
        p_attribute_category    IN      VARCHAR2 DEFAULT NULL,
        p_attribute1            IN      VARCHAR2 DEFAULT NULL,
        p_attribute2            IN      VARCHAR2 DEFAULT NULL,
        p_attribute3            IN      VARCHAR2 DEFAULT NULL,
        p_attribute4            IN      VARCHAR2 DEFAULT NULL,
        p_attribute5            IN      VARCHAR2 DEFAULT NULL,
        p_attribute6            IN      VARCHAR2 DEFAULT NULL,
        p_attribute7            IN      VARCHAR2 DEFAULT NULL,
        p_attribute8            IN      VARCHAR2 DEFAULT NULL,
        p_attribute9            IN      VARCHAR2 DEFAULT NULL,
        p_attribute10           IN      VARCHAR2 DEFAULT NULL,
        p_attribute11           IN      VARCHAR2 DEFAULT NULL,
        p_attribute12           IN      VARCHAR2 DEFAULT NULL,
        p_attribute13           IN      VARCHAR2 DEFAULT NULL,
        p_attribute14           IN      VARCHAR2 DEFAULT NULL,
        p_attribute15           IN      VARCHAR2 DEFAULT NULL,
        x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2
);

-- Bug 7307669
-- Start of comments
--      API name        : Raise_Supplier_Event
--      Type            : Public
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : i_vendor_id     IN  NUMBER  Optional DEFAULT NULL
--			  i_vendor_site_id    IN  NUMBER  Optional DEFAULT NULL
--			  i_vendor_contact_id IN  NUMBER  Optional DEFAULT NULL
--
--      OUT             : None
--
--      Version 	: Current version       1.0
--                        Initial version       1.0
--
--      Notes           : Raise_Supplier_Event is called to raise a business
--                        event whenever a Supplier / Supplier Site / Supplier
--                        Contact is created or updated
-- End of comments

PROCEDURE Raise_Supplier_Event(
			       i_vendor_id          IN  NUMBER  DEFAULT NULL,
			       i_vendor_site_id     IN  NUMBER  DEFAULT NULL,
			       i_vendor_contact_id  IN  NUMBER  DEFAULT NULL
                	      );

--Bug 9143273
-- Start of comments
--      API name        : is_Vendor_site_merged
--      Type            : Public
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--        IN            : p_vendor_site_id NUMBER  Required
--        Return        : Varchar2
--
--      Version 	    : 1.0
--      Notes           : This function is used tio check if the vendor site
--                        is already merged or not. This function returns
--                        'Y' (vendor site is already merged) or 'N'(vendor
--                        site is already merged)

FUNCTION Is_Vendor_Site_Merged(
    p_vendor_site_id     IN VARCHAR2
)
RETURN VARCHAR2;
--Bug 9143273

END;

/
