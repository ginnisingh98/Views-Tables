--------------------------------------------------------
--  DDL for Package Body FUN_VENDOR_PVT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_VENDOR_PVT_PKG" AS
/* $Header: funvndrb.pls 120.0 2006/02/15 14:28:02 ashikuma noship $ */
--Using these record type declarations to copy values to and call AP APIs
p_vendor_rec_a AP_VENDOR_PUB_PKG.r_vendor_rec_type;
p_vendor_site_rec_a AP_VENDOR_PUB_PKG.r_vendor_site_rec_type;
-- This procedure is invoked indirectly from the Supplier-Customer Association creation page
-- through the rosetta-generated java and plsql packages
PROCEDURE Create_Vendor
( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY  VARCHAR2		  	,
	x_msg_count		OUT	NOCOPY  NUMBER,
	x_msg_data		OUT	NOCOPY  VARCHAR2,
	p_vendor_rec		IN	 r_vendor_rec_type,
	x_vendor_id		OUT	NOCOPY  PO_VENDORS.VENDOR_ID%TYPE,
	x_party_id		OUT	NOCOPY  HZ_PARTIES.PARTY_ID%TYPE
) IS
BEGIN
--Copying values between record types
        p_vendor_rec_a.vendor_id :=p_vendor_rec.vendor_id;
	p_vendor_rec_a.SEGMENT1 := p_vendor_rec.SEGMENT1 ;
	p_vendor_rec_a.VENDOR_NAME := p_vendor_rec.VENDOR_NAME ;
	p_vendor_rec_a.VENDOR_NAME_ALT := p_vendor_rec.VENDOR_NAME_ALT;
	p_vendor_rec_a.SUMMARY_FLAG := p_vendor_rec.SUMMARY_FLAG ;
	p_vendor_rec_a.ENABLED_FLAG := p_vendor_rec.ENABLED_FLAG;
	p_vendor_rec_a.SEGMENT2 := p_vendor_rec.SEGMENT2;
	p_vendor_rec_a.SEGMENT3 := p_vendor_rec.SEGMENT3;
	p_vendor_rec_a.SEGMENT4 := p_vendor_rec.SEGMENT4;
	p_vendor_rec_a.SEGMENT5 := p_vendor_rec.SEGMENT5;
	p_vendor_rec_a.EMPLOYEE_ID := p_vendor_rec.EMPLOYEE_ID;
	p_vendor_rec_a.VENDOR_TYPE_LOOKUP_CODE := p_vendor_rec.VENDOR_TYPE_LOOKUP_CODE;
	p_vendor_rec_a.CUSTOMER_NUM := p_vendor_rec.CUSTOMER_NUM;
	p_vendor_rec_a.ONE_TIME_FLAG := p_vendor_rec.ONE_TIME_FLAG;
	p_vendor_rec_a.PARENT_VENDOR_ID := p_vendor_rec.PARENT_VENDOR_ID;
	p_vendor_rec_a.MIN_ORDER_AMOUNT := p_vendor_rec.MIN_ORDER_AMOUNT;
	p_vendor_rec_a.TERMS_ID := p_vendor_rec.TERMS_ID;
	p_vendor_rec_a.SET_OF_BOOKS_ID := p_vendor_rec.SET_OF_BOOKS_ID;
	p_vendor_rec_a.ALWAYS_TAKE_DISC_FLAG := p_vendor_rec.ALWAYS_TAKE_DISC_FLAG;
	p_vendor_rec_a.PAY_DATE_BASIS_LOOKUP_CODE := p_vendor_rec.PAY_DATE_BASIS_LOOKUP_CODE;
	p_vendor_rec_a.PAY_GROUP_LOOKUP_CODE := p_vendor_rec.PAY_GROUP_LOOKUP_CODE;
	p_vendor_rec_a.PAYMENT_PRIORITY := p_vendor_rec.PAYMENT_PRIORITY;
	p_vendor_rec_a.INVOICE_CURRENCY_CODE := p_vendor_rec.INVOICE_CURRENCY_CODE;
	p_vendor_rec_a.PAYMENT_CURRENCY_CODE := p_vendor_rec.PAYMENT_CURRENCY_CODE;
	p_vendor_rec_a.INVOICE_AMOUNT_LIMIT := p_vendor_rec.INVOICE_AMOUNT_LIMIT;
	p_vendor_rec_a.HOLD_ALL_PAYMENTS_FLAG := p_vendor_rec.HOLD_ALL_PAYMENTS_FLAG;
	p_vendor_rec_a.HOLD_FUTURE_PAYMENTS_FLAG := p_vendor_rec.HOLD_FUTURE_PAYMENTS_FLAG;
	p_vendor_rec_a.HOLD_REASON := p_vendor_rec.HOLD_REASON;
	p_vendor_rec_a.TYPE_1099 := p_vendor_rec.TYPE_1099;
	p_vendor_rec_a.WITHHOLDING_STATUS_LOOKUP_CODE := p_vendor_rec.WITHHOLDING_STATUS_LOOKUP_CODE;
	p_vendor_rec_a.WITHHOLDING_START_DATE := p_vendor_rec.WITHHOLDING_START_DATE;
	p_vendor_rec_a.ORGANIZATION_TYPE_LOOKUP_CODE := p_vendor_rec.ORGANIZATION_TYPE_LOOKUP_CODE;
	p_vendor_rec_a.START_DATE_ACTIVE := p_vendor_rec.START_DATE_ACTIVE;
	p_vendor_rec_a.END_DATE_ACTIVE := p_vendor_rec.END_DATE_ACTIVE;
	p_vendor_rec_a.MINORITY_GROUP_LOOKUP_CODE := p_vendor_rec.MINORITY_GROUP_LOOKUP_CODE;
	p_vendor_rec_a.WOMEN_OWNED_FLAG := p_vendor_rec.WOMEN_OWNED_FLAG;
	p_vendor_rec_a.SMALL_BUSINESS_FLAG := p_vendor_rec.SMALL_BUSINESS_FLAG;
	p_vendor_rec_a.HOLD_FLAG := p_vendor_rec.HOLD_FLAG;
	p_vendor_rec_a.PURCHASING_HOLD_REASON := p_vendor_rec.PURCHASING_HOLD_REASON;
	p_vendor_rec_a.HOLD_BY := p_vendor_rec.HOLD_BY;
	p_vendor_rec_a.HOLD_DATE := p_vendor_rec.HOLD_DATE;
	p_vendor_rec_a.TERMS_DATE_BASIS := p_vendor_rec.TERMS_DATE_BASIS;
	p_vendor_rec_a.INSPECTION_REQUIRED_FLAG := p_vendor_rec.INSPECTION_REQUIRED_FLAG;
	p_vendor_rec_a.RECEIPT_REQUIRED_FLAG := p_vendor_rec.RECEIPT_REQUIRED_FLAG;
	p_vendor_rec_a.QTY_RCV_TOLERANCE := p_vendor_rec.QTY_RCV_TOLERANCE;
	p_vendor_rec_a.QTY_RCV_EXCEPTION_CODE := p_vendor_rec.QTY_RCV_EXCEPTION_CODE;
	p_vendor_rec_a.ENFORCE_SHIP_TO_LOCATION_CODE := p_vendor_rec.ENFORCE_SHIP_TO_LOCATION_CODE;
	p_vendor_rec_a.DAYS_EARLY_RECEIPT_ALLOWED := p_vendor_rec.DAYS_EARLY_RECEIPT_ALLOWED;
	p_vendor_rec_a.DAYS_LATE_RECEIPT_ALLOWED := p_vendor_rec.DAYS_LATE_RECEIPT_ALLOWED;
	p_vendor_rec_a.RECEIPT_DAYS_EXCEPTION_CODE := p_vendor_rec.RECEIPT_DAYS_EXCEPTION_CODE;
	p_vendor_rec_a.RECEIVING_ROUTING_ID := p_vendor_rec.RECEIVING_ROUTING_ID;
	p_vendor_rec_a.ALLOW_SUBSTITUTE_RECEIPTS_FLAG := p_vendor_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG;
	p_vendor_rec_a.ALLOW_UNORDERED_RECEIPTS_FLAG := p_vendor_rec.ALLOW_UNORDERED_RECEIPTS_FLAG;
	p_vendor_rec_a.HOLD_UNMATCHED_INVOICES_FLAG := p_vendor_rec.HOLD_UNMATCHED_INVOICES_FLAG;
	p_vendor_rec_a.TAX_VERIFICATION_DATE := p_vendor_rec.TAX_VERIFICATION_DATE;
	p_vendor_rec_a.NAME_CONTROL := p_vendor_rec.NAME_CONTROL;
	p_vendor_rec_a.STATE_REPORTABLE_FLAG := p_vendor_rec.STATE_REPORTABLE_FLAG;
	p_vendor_rec_a.FEDERAL_REPORTABLE_FLAG := p_vendor_rec.FEDERAL_REPORTABLE_FLAG;
	p_vendor_rec_a.ATTRIBUTE_CATEGORY := p_vendor_rec.ATTRIBUTE_CATEGORY;
	p_vendor_rec_a.ATTRIBUTE1 := p_vendor_rec.ATTRIBUTE1;
	p_vendor_rec_a.ATTRIBUTE2 := p_vendor_rec.ATTRIBUTE2;
	p_vendor_rec_a.ATTRIBUTE3 := p_vendor_rec.ATTRIBUTE3;
	p_vendor_rec_a.ATTRIBUTE4 := p_vendor_rec.ATTRIBUTE4;
	p_vendor_rec_a.ATTRIBUTE5 := p_vendor_rec.ATTRIBUTE5;
	p_vendor_rec_a.ATTRIBUTE6 := p_vendor_rec.ATTRIBUTE6;
	p_vendor_rec_a.ATTRIBUTE7 := p_vendor_rec.ATTRIBUTE7;
	p_vendor_rec_a.ATTRIBUTE8 := p_vendor_rec.ATTRIBUTE8;
	p_vendor_rec_a.ATTRIBUTE9 := p_vendor_rec.ATTRIBUTE9;
	p_vendor_rec_a.ATTRIBUTE10 := p_vendor_rec.ATTRIBUTE10;
	p_vendor_rec_a.ATTRIBUTE11 := p_vendor_rec.ATTRIBUTE11;
	p_vendor_rec_a.ATTRIBUTE12 := p_vendor_rec.ATTRIBUTE12;
	p_vendor_rec_a.ATTRIBUTE13 := p_vendor_rec.ATTRIBUTE13;
	p_vendor_rec_a.ATTRIBUTE14 := p_vendor_rec.ATTRIBUTE14;
	p_vendor_rec_a.ATTRIBUTE15 := p_vendor_rec.ATTRIBUTE15;
	p_vendor_rec_a.AUTO_CALCULATE_INTEREST_FLAG := p_vendor_rec.AUTO_CALCULATE_INTEREST_FLAG;
	p_vendor_rec_a.VALIDATION_NUMBER := p_vendor_rec.VALIDATION_NUMBER;
	p_vendor_rec_a.EXCLUDE_FREIGHT_FROM_DISCOUNT := p_vendor_rec.EXCLUDE_FREIGHT_FROM_DISCOUNT;
	p_vendor_rec_a.TAX_REPORTING_NAME := p_vendor_rec.TAX_REPORTING_NAME;
	p_vendor_rec_a.CHECK_DIGITS := p_vendor_rec.CHECK_DIGITS;
	p_vendor_rec_a.ALLOW_AWT_FLAG := p_vendor_rec.ALLOW_AWT_FLAG;
	p_vendor_rec_a.AWT_GROUP_ID := p_vendor_rec.AWT_GROUP_ID;
	p_vendor_rec_a.AWT_GROUP_NAME := p_vendor_rec.AWT_GROUP_NAME;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE1 := p_vendor_rec.GLOBAL_ATTRIBUTE1;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE2 := p_vendor_rec.GLOBAL_ATTRIBUTE2;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE3 := p_vendor_rec.GLOBAL_ATTRIBUTE3;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE4 := p_vendor_rec.GLOBAL_ATTRIBUTE4;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE5 := p_vendor_rec.GLOBAL_ATTRIBUTE5;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE6 := p_vendor_rec.GLOBAL_ATTRIBUTE6;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE7 := p_vendor_rec.GLOBAL_ATTRIBUTE7;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE8 := p_vendor_rec.GLOBAL_ATTRIBUTE8;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE9 := p_vendor_rec.GLOBAL_ATTRIBUTE9;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE10 := p_vendor_rec.GLOBAL_ATTRIBUTE10;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE11 := p_vendor_rec.GLOBAL_ATTRIBUTE11;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE12 := p_vendor_rec.GLOBAL_ATTRIBUTE12;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE13 := p_vendor_rec.GLOBAL_ATTRIBUTE13;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE14 := p_vendor_rec.GLOBAL_ATTRIBUTE14;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE15 := p_vendor_rec.GLOBAL_ATTRIBUTE15;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE16 := p_vendor_rec.GLOBAL_ATTRIBUTE16;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE17 := p_vendor_rec.GLOBAL_ATTRIBUTE17;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE18 := p_vendor_rec.GLOBAL_ATTRIBUTE18;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE19 := p_vendor_rec.GLOBAL_ATTRIBUTE19;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE20 := p_vendor_rec.GLOBAL_ATTRIBUTE20;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE_CATEGORY := p_vendor_rec.GLOBAL_ATTRIBUTE_CATEGORY;
	p_vendor_rec_a.BANK_CHARGE_BEARER := p_vendor_rec.BANK_CHARGE_BEARER;
	p_vendor_rec_a.MATCH_OPTION := p_vendor_rec.MATCH_OPTION;
	p_vendor_rec_a.CREATE_DEBIT_MEMO_FLAG := p_vendor_rec.CREATE_DEBIT_MEMO_FLAG;
	p_vendor_rec_a.PARTY_ID := p_vendor_rec.PARTY_ID;
	p_vendor_rec_a.PARENT_PARTY_ID := p_vendor_rec.PARENT_PARTY_ID;
        p_vendor_rec_a. JGZZ_FISCAL_CODE := p_vendor_rec.JGZZ_FISCAL_CODE;
        p_vendor_rec_a.SIC_CODE := p_vendor_rec.SIC_CODE;
        p_vendor_rec_a. TAX_REFERENCE := p_vendor_rec.TAX_REFERENCE;
	p_vendor_rec_a.INVENTORY_ORGANIZATION_ID := p_vendor_rec.INVENTORY_ORGANIZATION_ID;
	p_vendor_rec_a.TERMS_NAME := p_vendor_rec.TERMS_NAME;
	p_vendor_rec_a.DEFAULT_TERMS_ID := p_vendor_rec.DEFAULT_TERMS_ID;
    	p_vendor_rec_a.VENDOR_INTERFACE_ID := p_vendor_rec.VENDOR_INTERFACE_ID;
	p_vendor_rec_a.NI_NUMBER := p_vendor_rec.NI_NUMBER;

-- Call to AP APIs
  AP_VENDOR_PUB_PKG.Create_Vendor
  ( 	p_api_version,
  	p_init_msg_list,
	p_commit,
	p_validation_level,
	x_return_status,
	x_msg_count,
	x_msg_data,
	p_vendor_rec_a,
	x_vendor_id,
	x_party_id
  );
END Create_Vendor;
-- This procedure is invoked indirectly from the Supplier-Customer Association updation page
-- through the rosetta-generated java and plsql packages
PROCEDURE Update_Vendor
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2		  	,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_rec		IN	 r_vendor_rec_type,
	p_vendor_id		IN	NUMBER
)
IS
BEGIN
--Copying values between record types
        p_vendor_rec_a.vendor_id :=p_vendor_rec.vendor_id;
	p_vendor_rec_a.SEGMENT1 := p_vendor_rec.SEGMENT1 ;
	p_vendor_rec_a.VENDOR_NAME := p_vendor_rec.VENDOR_NAME ;
	p_vendor_rec_a.VENDOR_NAME_ALT := p_vendor_rec.VENDOR_NAME_ALT;
	p_vendor_rec_a.SUMMARY_FLAG := p_vendor_rec.SUMMARY_FLAG ;
	p_vendor_rec_a.ENABLED_FLAG := p_vendor_rec.ENABLED_FLAG;
	p_vendor_rec_a.SEGMENT2 := p_vendor_rec.SEGMENT2;
	p_vendor_rec_a.SEGMENT3 := p_vendor_rec.SEGMENT3;
	p_vendor_rec_a.SEGMENT4 := p_vendor_rec.SEGMENT4;
	p_vendor_rec_a.SEGMENT5 := p_vendor_rec.SEGMENT5;
	p_vendor_rec_a.EMPLOYEE_ID := p_vendor_rec.EMPLOYEE_ID;
	p_vendor_rec_a.VENDOR_TYPE_LOOKUP_CODE := p_vendor_rec.VENDOR_TYPE_LOOKUP_CODE;
	p_vendor_rec_a.CUSTOMER_NUM := p_vendor_rec.CUSTOMER_NUM;
	p_vendor_rec_a.ONE_TIME_FLAG := p_vendor_rec.ONE_TIME_FLAG;
	p_vendor_rec_a.PARENT_VENDOR_ID := p_vendor_rec.PARENT_VENDOR_ID;
	p_vendor_rec_a.MIN_ORDER_AMOUNT := p_vendor_rec.MIN_ORDER_AMOUNT;
	p_vendor_rec_a.TERMS_ID := p_vendor_rec.TERMS_ID;
	p_vendor_rec_a.SET_OF_BOOKS_ID := p_vendor_rec.SET_OF_BOOKS_ID;
	p_vendor_rec_a.ALWAYS_TAKE_DISC_FLAG := p_vendor_rec.ALWAYS_TAKE_DISC_FLAG;
	p_vendor_rec_a.PAY_DATE_BASIS_LOOKUP_CODE := p_vendor_rec.PAY_DATE_BASIS_LOOKUP_CODE;
	p_vendor_rec_a.PAY_GROUP_LOOKUP_CODE := p_vendor_rec.PAY_GROUP_LOOKUP_CODE;
	p_vendor_rec_a.PAYMENT_PRIORITY := p_vendor_rec.PAYMENT_PRIORITY;
	p_vendor_rec_a.INVOICE_CURRENCY_CODE := p_vendor_rec.INVOICE_CURRENCY_CODE;
	p_vendor_rec_a.PAYMENT_CURRENCY_CODE := p_vendor_rec.PAYMENT_CURRENCY_CODE;
	p_vendor_rec_a.INVOICE_AMOUNT_LIMIT := p_vendor_rec.INVOICE_AMOUNT_LIMIT;
	p_vendor_rec_a.HOLD_ALL_PAYMENTS_FLAG := p_vendor_rec.HOLD_ALL_PAYMENTS_FLAG;
	p_vendor_rec_a.HOLD_FUTURE_PAYMENTS_FLAG := p_vendor_rec.HOLD_FUTURE_PAYMENTS_FLAG;
	p_vendor_rec_a.HOLD_REASON := p_vendor_rec.HOLD_REASON;
	p_vendor_rec_a.TYPE_1099 := p_vendor_rec.TYPE_1099;
	p_vendor_rec_a.WITHHOLDING_STATUS_LOOKUP_CODE := p_vendor_rec.WITHHOLDING_STATUS_LOOKUP_CODE;
	p_vendor_rec_a.WITHHOLDING_START_DATE := p_vendor_rec.WITHHOLDING_START_DATE;
	p_vendor_rec_a.ORGANIZATION_TYPE_LOOKUP_CODE := p_vendor_rec.ORGANIZATION_TYPE_LOOKUP_CODE;
	p_vendor_rec_a.START_DATE_ACTIVE := p_vendor_rec.START_DATE_ACTIVE;
	p_vendor_rec_a.END_DATE_ACTIVE := p_vendor_rec.END_DATE_ACTIVE;
	p_vendor_rec_a.MINORITY_GROUP_LOOKUP_CODE := p_vendor_rec.MINORITY_GROUP_LOOKUP_CODE;
	p_vendor_rec_a.WOMEN_OWNED_FLAG := p_vendor_rec.WOMEN_OWNED_FLAG;
	p_vendor_rec_a.SMALL_BUSINESS_FLAG := p_vendor_rec.SMALL_BUSINESS_FLAG;
	p_vendor_rec_a.HOLD_FLAG := p_vendor_rec.HOLD_FLAG;
	p_vendor_rec_a.PURCHASING_HOLD_REASON := p_vendor_rec.PURCHASING_HOLD_REASON;
	p_vendor_rec_a.HOLD_BY := p_vendor_rec.HOLD_BY;
	p_vendor_rec_a.HOLD_DATE := p_vendor_rec.HOLD_DATE;
	p_vendor_rec_a.TERMS_DATE_BASIS := p_vendor_rec.TERMS_DATE_BASIS;
	p_vendor_rec_a.INSPECTION_REQUIRED_FLAG := p_vendor_rec.INSPECTION_REQUIRED_FLAG;
	p_vendor_rec_a.RECEIPT_REQUIRED_FLAG := p_vendor_rec.RECEIPT_REQUIRED_FLAG;
	p_vendor_rec_a.QTY_RCV_TOLERANCE := p_vendor_rec.QTY_RCV_TOLERANCE;
	p_vendor_rec_a.QTY_RCV_EXCEPTION_CODE := p_vendor_rec.QTY_RCV_EXCEPTION_CODE;
	p_vendor_rec_a.ENFORCE_SHIP_TO_LOCATION_CODE := p_vendor_rec.ENFORCE_SHIP_TO_LOCATION_CODE;
	p_vendor_rec_a.DAYS_EARLY_RECEIPT_ALLOWED := p_vendor_rec.DAYS_EARLY_RECEIPT_ALLOWED;
	p_vendor_rec_a.DAYS_LATE_RECEIPT_ALLOWED := p_vendor_rec.DAYS_LATE_RECEIPT_ALLOWED;
	p_vendor_rec_a.RECEIPT_DAYS_EXCEPTION_CODE := p_vendor_rec.RECEIPT_DAYS_EXCEPTION_CODE;
	p_vendor_rec_a.RECEIVING_ROUTING_ID := p_vendor_rec.RECEIVING_ROUTING_ID;
	p_vendor_rec_a.ALLOW_SUBSTITUTE_RECEIPTS_FLAG := p_vendor_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG;
	p_vendor_rec_a.ALLOW_UNORDERED_RECEIPTS_FLAG := p_vendor_rec.ALLOW_UNORDERED_RECEIPTS_FLAG;
	p_vendor_rec_a.HOLD_UNMATCHED_INVOICES_FLAG := p_vendor_rec.HOLD_UNMATCHED_INVOICES_FLAG;
	p_vendor_rec_a.TAX_VERIFICATION_DATE := p_vendor_rec.TAX_VERIFICATION_DATE;
	p_vendor_rec_a.NAME_CONTROL := p_vendor_rec.NAME_CONTROL;
	p_vendor_rec_a.STATE_REPORTABLE_FLAG := p_vendor_rec.STATE_REPORTABLE_FLAG;
	p_vendor_rec_a.FEDERAL_REPORTABLE_FLAG := p_vendor_rec.FEDERAL_REPORTABLE_FLAG;
	p_vendor_rec_a.ATTRIBUTE_CATEGORY := p_vendor_rec.ATTRIBUTE_CATEGORY;
	p_vendor_rec_a.ATTRIBUTE1 := p_vendor_rec.ATTRIBUTE1;
	p_vendor_rec_a.ATTRIBUTE2 := p_vendor_rec.ATTRIBUTE2;
	p_vendor_rec_a.ATTRIBUTE3 := p_vendor_rec.ATTRIBUTE3;
	p_vendor_rec_a.ATTRIBUTE4 := p_vendor_rec.ATTRIBUTE4;
	p_vendor_rec_a.ATTRIBUTE5 := p_vendor_rec.ATTRIBUTE5;
	p_vendor_rec_a.ATTRIBUTE6 := p_vendor_rec.ATTRIBUTE6;
	p_vendor_rec_a.ATTRIBUTE7 := p_vendor_rec.ATTRIBUTE7;
	p_vendor_rec_a.ATTRIBUTE8 := p_vendor_rec.ATTRIBUTE8;
	p_vendor_rec_a.ATTRIBUTE9 := p_vendor_rec.ATTRIBUTE9;
	p_vendor_rec_a.ATTRIBUTE10 := p_vendor_rec.ATTRIBUTE10;
	p_vendor_rec_a.ATTRIBUTE11 := p_vendor_rec.ATTRIBUTE11;
	p_vendor_rec_a.ATTRIBUTE12 := p_vendor_rec.ATTRIBUTE12;
	p_vendor_rec_a.ATTRIBUTE13 := p_vendor_rec.ATTRIBUTE13;
	p_vendor_rec_a.ATTRIBUTE14 := p_vendor_rec.ATTRIBUTE14;
	p_vendor_rec_a.ATTRIBUTE15 := p_vendor_rec.ATTRIBUTE15;
	p_vendor_rec_a.AUTO_CALCULATE_INTEREST_FLAG := p_vendor_rec.AUTO_CALCULATE_INTEREST_FLAG;
	p_vendor_rec_a.VALIDATION_NUMBER := p_vendor_rec.VALIDATION_NUMBER;
	p_vendor_rec_a.EXCLUDE_FREIGHT_FROM_DISCOUNT := p_vendor_rec.EXCLUDE_FREIGHT_FROM_DISCOUNT;
	p_vendor_rec_a.TAX_REPORTING_NAME := p_vendor_rec.TAX_REPORTING_NAME;
	p_vendor_rec_a.CHECK_DIGITS := p_vendor_rec.CHECK_DIGITS;
	p_vendor_rec_a.ALLOW_AWT_FLAG := p_vendor_rec.ALLOW_AWT_FLAG;
	p_vendor_rec_a.AWT_GROUP_ID := p_vendor_rec.AWT_GROUP_ID;
	p_vendor_rec_a.AWT_GROUP_NAME := p_vendor_rec.AWT_GROUP_NAME;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE1 := p_vendor_rec.GLOBAL_ATTRIBUTE1;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE2 := p_vendor_rec.GLOBAL_ATTRIBUTE2;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE3 := p_vendor_rec.GLOBAL_ATTRIBUTE3;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE4 := p_vendor_rec.GLOBAL_ATTRIBUTE4;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE5 := p_vendor_rec.GLOBAL_ATTRIBUTE5;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE6 := p_vendor_rec.GLOBAL_ATTRIBUTE6;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE7 := p_vendor_rec.GLOBAL_ATTRIBUTE7;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE8 := p_vendor_rec.GLOBAL_ATTRIBUTE8;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE9 := p_vendor_rec.GLOBAL_ATTRIBUTE9;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE10 := p_vendor_rec.GLOBAL_ATTRIBUTE10;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE11 := p_vendor_rec.GLOBAL_ATTRIBUTE11;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE12 := p_vendor_rec.GLOBAL_ATTRIBUTE12;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE13 := p_vendor_rec.GLOBAL_ATTRIBUTE13;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE14 := p_vendor_rec.GLOBAL_ATTRIBUTE14;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE15 := p_vendor_rec.GLOBAL_ATTRIBUTE15;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE16 := p_vendor_rec.GLOBAL_ATTRIBUTE16;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE17 := p_vendor_rec.GLOBAL_ATTRIBUTE17;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE18 := p_vendor_rec.GLOBAL_ATTRIBUTE18;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE19 := p_vendor_rec.GLOBAL_ATTRIBUTE19;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE20 := p_vendor_rec.GLOBAL_ATTRIBUTE20;
	p_vendor_rec_a.GLOBAL_ATTRIBUTE_CATEGORY := p_vendor_rec.GLOBAL_ATTRIBUTE_CATEGORY;
	p_vendor_rec_a.BANK_CHARGE_BEARER := p_vendor_rec.BANK_CHARGE_BEARER;
	p_vendor_rec_a.MATCH_OPTION := p_vendor_rec.MATCH_OPTION;
	p_vendor_rec_a.CREATE_DEBIT_MEMO_FLAG := p_vendor_rec.CREATE_DEBIT_MEMO_FLAG;
	p_vendor_rec_a.PARTY_ID := p_vendor_rec.PARTY_ID;
	p_vendor_rec_a.PARENT_PARTY_ID := p_vendor_rec.PARENT_PARTY_ID;
        p_vendor_rec_a. JGZZ_FISCAL_CODE := p_vendor_rec.JGZZ_FISCAL_CODE;
        p_vendor_rec_a.SIC_CODE := p_vendor_rec.SIC_CODE;
        p_vendor_rec_a. TAX_REFERENCE := p_vendor_rec.TAX_REFERENCE;
	p_vendor_rec_a.INVENTORY_ORGANIZATION_ID := p_vendor_rec.INVENTORY_ORGANIZATION_ID;
	p_vendor_rec_a.TERMS_NAME := p_vendor_rec.TERMS_NAME;
	p_vendor_rec_a.DEFAULT_TERMS_ID := p_vendor_rec.DEFAULT_TERMS_ID;
    	p_vendor_rec_a.VENDOR_INTERFACE_ID := p_vendor_rec.VENDOR_INTERFACE_ID;
	p_vendor_rec_a.NI_NUMBER := p_vendor_rec.NI_NUMBER;

-- Call to AP APIs
  AP_VENDOR_PUB_PKG.Update_Vendor
  ( 	p_api_version,
  	p_init_msg_list,
	p_commit,
	p_validation_level,
	x_return_status,
	x_msg_count,
	x_msg_data,
	p_vendor_rec_a,
	p_vendor_id
  );
END Update_Vendor;
-- This procedure is invoked indirectly from the Supplier-Customer Association creation page
-- through the rosetta-generated java and plsql packages
PROCEDURE Create_Vendor_Site
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2		  	,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_site_rec	IN	 r_vendor_site_rec_type,
	x_vendor_site_id	OUT	NOCOPY NUMBER,
	x_party_site_id		OUT	NOCOPY NUMBER,
	x_location_id		OUT	NOCOPY NUMBER
)
IS
BEGIN
--Copying values between record types
	p_vendor_site_rec_a.AREA_CODE := p_vendor_site_rec.AREA_CODE;
	p_vendor_site_rec_a.PHONE := p_vendor_site_rec.PHONE;
	p_vendor_site_rec_a.CUSTOMER_NUM := p_vendor_site_rec.CUSTOMER_NUM;
	p_vendor_site_rec_a.SHIP_TO_LOCATION_ID := p_vendor_site_rec.SHIP_TO_LOCATION_ID;
	p_vendor_site_rec_a.BILL_TO_LOCATION_ID := p_vendor_site_rec.BILL_TO_LOCATION_ID;
	p_vendor_site_rec_a.SHIP_VIA_LOOKUP_CODE := p_vendor_site_rec.SHIP_VIA_LOOKUP_CODE;
	p_vendor_site_rec_a.FREIGHT_TERMS_LOOKUP_CODE := p_vendor_site_rec.FREIGHT_TERMS_LOOKUP_CODE;
	p_vendor_site_rec_a.FOB_LOOKUP_CODE := p_vendor_site_rec.FOB_LOOKUP_CODE;
	p_vendor_site_rec_a.INACTIVE_DATE := p_vendor_site_rec.INACTIVE_DATE;
	p_vendor_site_rec_a.FAX := p_vendor_site_rec.FAX;
	p_vendor_site_rec_a.FAX_AREA_CODE := p_vendor_site_rec.FAX_AREA_CODE;
	p_vendor_site_rec_a.TELEX := p_vendor_site_rec.TELEX;
	p_vendor_site_rec_a.TERMS_DATE_BASIS := p_vendor_site_rec.TERMS_DATE_BASIS;
	p_vendor_site_rec_a.DISTRIBUTION_SET_ID := p_vendor_site_rec.DISTRIBUTION_SET_ID;
	p_vendor_site_rec_a.ACCTS_PAY_CODE_COMBINATION_ID := p_vendor_site_rec.ACCTS_PAY_CODE_COMBINATION_ID;
	p_vendor_site_rec_a.PREPAY_CODE_COMBINATION_ID := p_vendor_site_rec.PREPAY_CODE_COMBINATION_ID;
	p_vendor_site_rec_a.PAY_GROUP_LOOKUP_CODE := p_vendor_site_rec.PAY_GROUP_LOOKUP_CODE;
	p_vendor_site_rec_a.PAYMENT_PRIORITY := p_vendor_site_rec.PAYMENT_PRIORITY;
	p_vendor_site_rec_a.TERMS_ID := p_vendor_site_rec.TERMS_ID;
	p_vendor_site_rec_a.INVOICE_AMOUNT_LIMIT := p_vendor_site_rec.INVOICE_AMOUNT_LIMIT;
	p_vendor_site_rec_a.PAY_DATE_BASIS_LOOKUP_CODE := p_vendor_site_rec.PAY_DATE_BASIS_LOOKUP_CODE;
	p_vendor_site_rec_a.ALWAYS_TAKE_DISC_FLAG := p_vendor_site_rec.ALWAYS_TAKE_DISC_FLAG;
	p_vendor_site_rec_a.INVOICE_CURRENCY_CODE := p_vendor_site_rec.INVOICE_CURRENCY_CODE;
	p_vendor_site_rec_a.PAYMENT_CURRENCY_CODE := p_vendor_site_rec.PAYMENT_CURRENCY_CODE;
	p_vendor_site_rec_a.VENDOR_SITE_ID := p_vendor_site_rec.VENDOR_SITE_ID;
	p_vendor_site_rec_a.LAST_UPDATE_DATE := p_vendor_site_rec.LAST_UPDATE_DATE;
	p_vendor_site_rec_a.LAST_UPDATED_BY := p_vendor_site_rec.LAST_UPDATED_BY;
	p_vendor_site_rec_a.VENDOR_ID := p_vendor_site_rec.VENDOR_ID;
	p_vendor_site_rec_a.VENDOR_SITE_CODE := p_vendor_site_rec.VENDOR_SITE_CODE;
	p_vendor_site_rec_a.VENDOR_SITE_CODE_ALT := p_vendor_site_rec.VENDOR_SITE_CODE_ALT;
	p_vendor_site_rec_a.PURCHASING_SITE_FLAG := p_vendor_site_rec.PURCHASING_SITE_FLAG;
	p_vendor_site_rec_a.RFQ_ONLY_SITE_FLAG := p_vendor_site_rec.RFQ_ONLY_SITE_FLAG;
	p_vendor_site_rec_a.PAY_SITE_FLAG := p_vendor_site_rec.PAY_SITE_FLAG;
	p_vendor_site_rec_a.ATTENTION_AR_FLAG := p_vendor_site_rec.ATTENTION_AR_FLAG;
	p_vendor_site_rec_a.HOLD_ALL_PAYMENTS_FLAG := p_vendor_site_rec.HOLD_ALL_PAYMENTS_FLAG;
	p_vendor_site_rec_a.HOLD_FUTURE_PAYMENTS_FLAG := p_vendor_site_rec.HOLD_FUTURE_PAYMENTS_FLAG;
	p_vendor_site_rec_a.HOLD_REASON := p_vendor_site_rec.HOLD_REASON;
	p_vendor_site_rec_a.HOLD_UNMATCHED_INVOICES_FLAG := p_vendor_site_rec.HOLD_UNMATCHED_INVOICES_FLAG;
	p_vendor_site_rec_a.TAX_REPORTING_SITE_FLAG := p_vendor_site_rec.TAX_REPORTING_SITE_FLAG;
	p_vendor_site_rec_a.ATTRIBUTE_CATEGORY := p_vendor_site_rec.ATTRIBUTE_CATEGORY;
	p_vendor_site_rec_a.ATTRIBUTE1 := p_vendor_site_rec.ATTRIBUTE1;
	p_vendor_site_rec_a.ATTRIBUTE2 := p_vendor_site_rec.ATTRIBUTE2;
	p_vendor_site_rec_a.ATTRIBUTE3 := p_vendor_site_rec.ATTRIBUTE3;
	p_vendor_site_rec_a.ATTRIBUTE4 := p_vendor_site_rec.ATTRIBUTE4;
	p_vendor_site_rec_a.ATTRIBUTE5 := p_vendor_site_rec.ATTRIBUTE5;
	p_vendor_site_rec_a.ATTRIBUTE6 := p_vendor_site_rec.ATTRIBUTE6;
	p_vendor_site_rec_a.ATTRIBUTE7 := p_vendor_site_rec.ATTRIBUTE7;
	p_vendor_site_rec_a.ATTRIBUTE8 := p_vendor_site_rec.ATTRIBUTE8;
	p_vendor_site_rec_a.ATTRIBUTE9 := p_vendor_site_rec.ATTRIBUTE9;
	p_vendor_site_rec_a.ATTRIBUTE10 := p_vendor_site_rec.ATTRIBUTE10;
	p_vendor_site_rec_a.ATTRIBUTE11 := p_vendor_site_rec.ATTRIBUTE11;
	p_vendor_site_rec_a.ATTRIBUTE12 := p_vendor_site_rec.ATTRIBUTE12;
	p_vendor_site_rec_a.ATTRIBUTE13 := p_vendor_site_rec.ATTRIBUTE13;
	p_vendor_site_rec_a.ATTRIBUTE14 := p_vendor_site_rec.ATTRIBUTE14;
	p_vendor_site_rec_a.ATTRIBUTE15 := p_vendor_site_rec.ATTRIBUTE15;
	p_vendor_site_rec_a.VALIDATION_NUMBER := p_vendor_site_rec.VALIDATION_NUMBER;
	p_vendor_site_rec_a.EXCLUDE_FREIGHT_FROM_DISCOUNT := p_vendor_site_rec.EXCLUDE_FREIGHT_FROM_DISCOUNT;
	p_vendor_site_rec_a.BANK_CHARGE_BEARER := p_vendor_site_rec.BANK_CHARGE_BEARER;
	p_vendor_site_rec_a.ORG_ID := p_vendor_site_rec.ORG_ID;
	p_vendor_site_rec_a.CHECK_DIGITS := p_vendor_site_rec.CHECK_DIGITS;
	p_vendor_site_rec_a.ALLOW_AWT_FLAG := p_vendor_site_rec.ALLOW_AWT_FLAG;
	p_vendor_site_rec_a.AWT_GROUP_ID := p_vendor_site_rec.AWT_GROUP_ID;
	p_vendor_site_rec_a.DEFAULT_PAY_SITE_ID := p_vendor_site_rec.DEFAULT_PAY_SITE_ID;
	p_vendor_site_rec_a.PAY_ON_CODE := p_vendor_site_rec.PAY_ON_CODE;
	p_vendor_site_rec_a.PAY_ON_RECEIPT_SUMMARY_CODE := p_vendor_site_rec.PAY_ON_RECEIPT_SUMMARY_CODE;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE_CATEGORY := p_vendor_site_rec.GLOBAL_ATTRIBUTE_CATEGORY;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE1 := p_vendor_site_rec.GLOBAL_ATTRIBUTE1;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE2 := p_vendor_site_rec.GLOBAL_ATTRIBUTE2;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE3 := p_vendor_site_rec.GLOBAL_ATTRIBUTE3;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE4 := p_vendor_site_rec.GLOBAL_ATTRIBUTE4;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE5 := p_vendor_site_rec.GLOBAL_ATTRIBUTE5;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE6 := p_vendor_site_rec.GLOBAL_ATTRIBUTE6;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE7 := p_vendor_site_rec.GLOBAL_ATTRIBUTE7;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE8 := p_vendor_site_rec.GLOBAL_ATTRIBUTE8;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE9 := p_vendor_site_rec.GLOBAL_ATTRIBUTE9;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE10 := p_vendor_site_rec.GLOBAL_ATTRIBUTE10;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE11 := p_vendor_site_rec.GLOBAL_ATTRIBUTE11;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE12 := p_vendor_site_rec.GLOBAL_ATTRIBUTE12;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE13 := p_vendor_site_rec.GLOBAL_ATTRIBUTE13;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE14 := p_vendor_site_rec.GLOBAL_ATTRIBUTE14;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE15 := p_vendor_site_rec.GLOBAL_ATTRIBUTE15;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE16 := p_vendor_site_rec.GLOBAL_ATTRIBUTE16;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE17 := p_vendor_site_rec.GLOBAL_ATTRIBUTE17;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE18 := p_vendor_site_rec.GLOBAL_ATTRIBUTE18;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE19 := p_vendor_site_rec.GLOBAL_ATTRIBUTE19;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE20 := p_vendor_site_rec.GLOBAL_ATTRIBUTE20;
	p_vendor_site_rec_a.TP_HEADER_ID := p_vendor_site_rec.TP_HEADER_ID;
	p_vendor_site_rec_a.ECE_TP_LOCATION_CODE := p_vendor_site_rec.ECE_TP_LOCATION_CODE;
	p_vendor_site_rec_a.PCARD_SITE_FLAG := p_vendor_site_rec.PCARD_SITE_FLAG;
	p_vendor_site_rec_a.MATCH_OPTION := p_vendor_site_rec.MATCH_OPTION;
	p_vendor_site_rec_a.COUNTRY_OF_ORIGIN_CODE := p_vendor_site_rec.COUNTRY_OF_ORIGIN_CODE;
	p_vendor_site_rec_a.FUTURE_DATED_PAYMENT_CCID := p_vendor_site_rec.FUTURE_DATED_PAYMENT_CCID;
	p_vendor_site_rec_a.CREATE_DEBIT_MEMO_FLAG := p_vendor_site_rec.CREATE_DEBIT_MEMO_FLAG;
	p_vendor_site_rec_a.SUPPLIER_NOTIF_METHOD := p_vendor_site_rec.SUPPLIER_NOTIF_METHOD;
	p_vendor_site_rec_a.EMAIL_ADDRESS := p_vendor_site_rec.EMAIL_ADDRESS;
	p_vendor_site_rec_a.PRIMARY_PAY_SITE_FLAG := p_vendor_site_rec.PRIMARY_PAY_SITE_FLAG;
	p_vendor_site_rec_a.SHIPPING_CONTROL := p_vendor_site_rec.SHIPPING_CONTROL;
	p_vendor_site_rec_a.SELLING_COMPANY_IDENTIFIER := p_vendor_site_rec.SELLING_COMPANY_IDENTIFIER;
	p_vendor_site_rec_a.GAPLESS_INV_NUM_FLAG := p_vendor_site_rec.GAPLESS_INV_NUM_FLAG;
	p_vendor_site_rec_a.LOCATION_ID := p_vendor_site_rec.LOCATION_ID;
	p_vendor_site_rec_a.PARTY_SITE_ID := p_vendor_site_rec.PARTY_SITE_ID;
	p_vendor_site_rec_a.ORG_NAME := p_vendor_site_rec.ORG_NAME;
	p_vendor_site_rec_a.DUNS_NUMBER := p_vendor_site_rec.DUNS_NUMBER;
	p_vendor_site_rec_a.ADDRESS_STYLE := p_vendor_site_rec.ADDRESS_STYLE;
	p_vendor_site_rec_a.LANGUAGE := p_vendor_site_rec.LANGUAGE;
	p_vendor_site_rec_a.PROVINCE := p_vendor_site_rec.PROVINCE;
	p_vendor_site_rec_a.COUNTRY := p_vendor_site_rec.COUNTRY;
	p_vendor_site_rec_a.ADDRESS_LINE1 := p_vendor_site_rec.ADDRESS_LINE1;
	p_vendor_site_rec_a.ADDRESS_LINE2 := p_vendor_site_rec.ADDRESS_LINE2;
	p_vendor_site_rec_a.ADDRESS_LINE3 := p_vendor_site_rec.ADDRESS_LINE3;
	p_vendor_site_rec_a.ADDRESS_LINE4 := p_vendor_site_rec.ADDRESS_LINE4;
	p_vendor_site_rec_a.ADDRESS_LINES_ALT := p_vendor_site_rec.ADDRESS_LINES_ALT;
	p_vendor_site_rec_a.COUNTY := p_vendor_site_rec.COUNTY;
	p_vendor_site_rec_a.CITY := p_vendor_site_rec.CITY;
	p_vendor_site_rec_a.STATE := p_vendor_site_rec.STATE;
	p_vendor_site_rec_a.ZIP := p_vendor_site_rec.ZIP;
	p_vendor_site_rec_a.TERMS_NAME := p_vendor_site_rec.TERMS_NAME;
	p_vendor_site_rec_a.DEFAULT_TERMS_ID := p_vendor_site_rec.DEFAULT_TERMS_ID;
	p_vendor_site_rec_a.AWT_GROUP_NAME := p_vendor_site_rec.AWT_GROUP_NAME;
	p_vendor_site_rec_a.DISTRIBUTION_SET_NAME := p_vendor_site_rec.DISTRIBUTION_SET_NAME;
        p_vendor_site_rec_a.SHIP_TO_LOCATION_CODE := p_vendor_site_rec.SHIP_TO_LOCATION_CODE;
        p_vendor_site_rec_a.BILL_TO_LOCATION_CODE := p_vendor_site_rec.BILL_TO_LOCATION_CODE;
    	p_vendor_site_rec_a.DEFAULT_DIST_SET_ID := p_vendor_site_rec.DEFAULT_DIST_SET_ID;
        p_vendor_site_rec_a.DEFAULT_SHIP_TO_LOC_ID := p_vendor_site_rec.DEFAULT_SHIP_TO_LOC_ID;
        p_vendor_site_rec_a.DEFAULT_BILL_TO_LOC_ID := p_vendor_site_rec.DEFAULT_BILL_TO_LOC_ID;
	p_vendor_site_rec_a.TOLERANCE_ID := p_vendor_site_rec.TOLERANCE_ID;
	p_vendor_site_rec_a.TOLERANCE_NAME := p_vendor_site_rec.TOLERANCE_NAME;
    	p_vendor_site_rec_a.VENDOR_INTERFACE_ID := p_vendor_site_rec.VENDOR_INTERFACE_ID;
    	p_vendor_site_rec_a.VENDOR_SITE_INTERFACE_ID := p_vendor_site_rec.VENDOR_SITE_INTERFACE_ID;
	p_vendor_site_rec_a.RETAINAGE_RATE := p_vendor_site_rec.RETAINAGE_RATE;

-- Call to AP APIs
  AP_VENDOR_PUB_PKG.Create_Vendor_Site
  ( 	p_api_version,
  	p_init_msg_list,
	p_commit,
	p_validation_level,
	x_return_status,
	x_msg_count,
	x_msg_data,
	p_vendor_site_rec_a,
	x_vendor_site_id,
	x_party_site_id,
	x_location_id
  );
END Create_Vendor_Site;
-- This procedure is invoked indirectly from the Supplier-Customer Association updation page
-- through the rosetta-generated java and plsql packages
PROCEDURE Update_Vendor_Site
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2		  	,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_site_rec	IN	 r_vendor_site_rec_type,
	p_vendor_site_id	IN	NUMBER
)
IS
BEGIN
--Copying values between record types
	p_vendor_site_rec_a.AREA_CODE := p_vendor_site_rec.AREA_CODE;
	p_vendor_site_rec_a.PHONE := p_vendor_site_rec.PHONE;
	p_vendor_site_rec_a.CUSTOMER_NUM := p_vendor_site_rec.CUSTOMER_NUM;
	p_vendor_site_rec_a.SHIP_TO_LOCATION_ID := p_vendor_site_rec.SHIP_TO_LOCATION_ID;
	p_vendor_site_rec_a.BILL_TO_LOCATION_ID := p_vendor_site_rec.BILL_TO_LOCATION_ID;
	p_vendor_site_rec_a.SHIP_VIA_LOOKUP_CODE := p_vendor_site_rec.SHIP_VIA_LOOKUP_CODE;
	p_vendor_site_rec_a.FREIGHT_TERMS_LOOKUP_CODE := p_vendor_site_rec.FREIGHT_TERMS_LOOKUP_CODE;
	p_vendor_site_rec_a.FOB_LOOKUP_CODE := p_vendor_site_rec.FOB_LOOKUP_CODE;
	p_vendor_site_rec_a.INACTIVE_DATE := p_vendor_site_rec.INACTIVE_DATE;
	p_vendor_site_rec_a.FAX := p_vendor_site_rec.FAX;
	p_vendor_site_rec_a.FAX_AREA_CODE := p_vendor_site_rec.FAX_AREA_CODE;
	p_vendor_site_rec_a.TELEX := p_vendor_site_rec.TELEX;
	p_vendor_site_rec_a.TERMS_DATE_BASIS := p_vendor_site_rec.TERMS_DATE_BASIS;
	p_vendor_site_rec_a.DISTRIBUTION_SET_ID := p_vendor_site_rec.DISTRIBUTION_SET_ID;
	p_vendor_site_rec_a.ACCTS_PAY_CODE_COMBINATION_ID := p_vendor_site_rec.ACCTS_PAY_CODE_COMBINATION_ID;
	p_vendor_site_rec_a.PREPAY_CODE_COMBINATION_ID := p_vendor_site_rec.PREPAY_CODE_COMBINATION_ID;
	p_vendor_site_rec_a.PAY_GROUP_LOOKUP_CODE := p_vendor_site_rec.PAY_GROUP_LOOKUP_CODE;
	p_vendor_site_rec_a.PAYMENT_PRIORITY := p_vendor_site_rec.PAYMENT_PRIORITY;
	p_vendor_site_rec_a.TERMS_ID := p_vendor_site_rec.TERMS_ID;
	p_vendor_site_rec_a.INVOICE_AMOUNT_LIMIT := p_vendor_site_rec.INVOICE_AMOUNT_LIMIT;
	p_vendor_site_rec_a.PAY_DATE_BASIS_LOOKUP_CODE := p_vendor_site_rec.PAY_DATE_BASIS_LOOKUP_CODE;
	p_vendor_site_rec_a.ALWAYS_TAKE_DISC_FLAG := p_vendor_site_rec.ALWAYS_TAKE_DISC_FLAG;
	p_vendor_site_rec_a.INVOICE_CURRENCY_CODE := p_vendor_site_rec.INVOICE_CURRENCY_CODE;
	p_vendor_site_rec_a.PAYMENT_CURRENCY_CODE := p_vendor_site_rec.PAYMENT_CURRENCY_CODE;
	p_vendor_site_rec_a.VENDOR_SITE_ID := p_vendor_site_rec.VENDOR_SITE_ID;
	p_vendor_site_rec_a.LAST_UPDATE_DATE := p_vendor_site_rec.LAST_UPDATE_DATE;
	p_vendor_site_rec_a.LAST_UPDATED_BY := p_vendor_site_rec.LAST_UPDATED_BY;
	p_vendor_site_rec_a.VENDOR_ID := p_vendor_site_rec.VENDOR_ID;
	p_vendor_site_rec_a.VENDOR_SITE_CODE := p_vendor_site_rec.VENDOR_SITE_CODE;
	p_vendor_site_rec_a.VENDOR_SITE_CODE_ALT := p_vendor_site_rec.VENDOR_SITE_CODE_ALT;
	p_vendor_site_rec_a.PURCHASING_SITE_FLAG := p_vendor_site_rec.PURCHASING_SITE_FLAG;
	p_vendor_site_rec_a.RFQ_ONLY_SITE_FLAG := p_vendor_site_rec.RFQ_ONLY_SITE_FLAG;
	p_vendor_site_rec_a.PAY_SITE_FLAG := p_vendor_site_rec.PAY_SITE_FLAG;
	p_vendor_site_rec_a.ATTENTION_AR_FLAG := p_vendor_site_rec.ATTENTION_AR_FLAG;
	p_vendor_site_rec_a.HOLD_ALL_PAYMENTS_FLAG := p_vendor_site_rec.HOLD_ALL_PAYMENTS_FLAG;
	p_vendor_site_rec_a.HOLD_FUTURE_PAYMENTS_FLAG := p_vendor_site_rec.HOLD_FUTURE_PAYMENTS_FLAG;
	p_vendor_site_rec_a.HOLD_REASON := p_vendor_site_rec.HOLD_REASON;
	p_vendor_site_rec_a.HOLD_UNMATCHED_INVOICES_FLAG := p_vendor_site_rec.HOLD_UNMATCHED_INVOICES_FLAG;
	p_vendor_site_rec_a.TAX_REPORTING_SITE_FLAG := p_vendor_site_rec.TAX_REPORTING_SITE_FLAG;
	p_vendor_site_rec_a.ATTRIBUTE_CATEGORY := p_vendor_site_rec.ATTRIBUTE_CATEGORY;
	p_vendor_site_rec_a.ATTRIBUTE1 := p_vendor_site_rec.ATTRIBUTE1;
	p_vendor_site_rec_a.ATTRIBUTE2 := p_vendor_site_rec.ATTRIBUTE2;
	p_vendor_site_rec_a.ATTRIBUTE3 := p_vendor_site_rec.ATTRIBUTE3;
	p_vendor_site_rec_a.ATTRIBUTE4 := p_vendor_site_rec.ATTRIBUTE4;
	p_vendor_site_rec_a.ATTRIBUTE5 := p_vendor_site_rec.ATTRIBUTE5;
	p_vendor_site_rec_a.ATTRIBUTE6 := p_vendor_site_rec.ATTRIBUTE6;
	p_vendor_site_rec_a.ATTRIBUTE7 := p_vendor_site_rec.ATTRIBUTE7;
	p_vendor_site_rec_a.ATTRIBUTE8 := p_vendor_site_rec.ATTRIBUTE8;
	p_vendor_site_rec_a.ATTRIBUTE9 := p_vendor_site_rec.ATTRIBUTE9;
	p_vendor_site_rec_a.ATTRIBUTE10 := p_vendor_site_rec.ATTRIBUTE10;
	p_vendor_site_rec_a.ATTRIBUTE11 := p_vendor_site_rec.ATTRIBUTE11;
	p_vendor_site_rec_a.ATTRIBUTE12 := p_vendor_site_rec.ATTRIBUTE12;
	p_vendor_site_rec_a.ATTRIBUTE13 := p_vendor_site_rec.ATTRIBUTE13;
	p_vendor_site_rec_a.ATTRIBUTE14 := p_vendor_site_rec.ATTRIBUTE14;
	p_vendor_site_rec_a.ATTRIBUTE15 := p_vendor_site_rec.ATTRIBUTE15;
	p_vendor_site_rec_a.VALIDATION_NUMBER := p_vendor_site_rec.VALIDATION_NUMBER;
	p_vendor_site_rec_a.EXCLUDE_FREIGHT_FROM_DISCOUNT := p_vendor_site_rec.EXCLUDE_FREIGHT_FROM_DISCOUNT;
	p_vendor_site_rec_a.BANK_CHARGE_BEARER := p_vendor_site_rec.BANK_CHARGE_BEARER;
	p_vendor_site_rec_a.ORG_ID := p_vendor_site_rec.ORG_ID;
	p_vendor_site_rec_a.CHECK_DIGITS := p_vendor_site_rec.CHECK_DIGITS;
	p_vendor_site_rec_a.ALLOW_AWT_FLAG := p_vendor_site_rec.ALLOW_AWT_FLAG;
	p_vendor_site_rec_a.AWT_GROUP_ID := p_vendor_site_rec.AWT_GROUP_ID;
	p_vendor_site_rec_a.DEFAULT_PAY_SITE_ID := p_vendor_site_rec.DEFAULT_PAY_SITE_ID;
	p_vendor_site_rec_a.PAY_ON_CODE := p_vendor_site_rec.PAY_ON_CODE;
	p_vendor_site_rec_a.PAY_ON_RECEIPT_SUMMARY_CODE := p_vendor_site_rec.PAY_ON_RECEIPT_SUMMARY_CODE;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE_CATEGORY := p_vendor_site_rec.GLOBAL_ATTRIBUTE_CATEGORY;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE1 := p_vendor_site_rec.GLOBAL_ATTRIBUTE1;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE2 := p_vendor_site_rec.GLOBAL_ATTRIBUTE2;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE3 := p_vendor_site_rec.GLOBAL_ATTRIBUTE3;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE4 := p_vendor_site_rec.GLOBAL_ATTRIBUTE4;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE5 := p_vendor_site_rec.GLOBAL_ATTRIBUTE5;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE6 := p_vendor_site_rec.GLOBAL_ATTRIBUTE6;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE7 := p_vendor_site_rec.GLOBAL_ATTRIBUTE7;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE8 := p_vendor_site_rec.GLOBAL_ATTRIBUTE8;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE9 := p_vendor_site_rec.GLOBAL_ATTRIBUTE9;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE10 := p_vendor_site_rec.GLOBAL_ATTRIBUTE10;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE11 := p_vendor_site_rec.GLOBAL_ATTRIBUTE11;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE12 := p_vendor_site_rec.GLOBAL_ATTRIBUTE12;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE13 := p_vendor_site_rec.GLOBAL_ATTRIBUTE13;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE14 := p_vendor_site_rec.GLOBAL_ATTRIBUTE14;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE15 := p_vendor_site_rec.GLOBAL_ATTRIBUTE15;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE16 := p_vendor_site_rec.GLOBAL_ATTRIBUTE16;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE17 := p_vendor_site_rec.GLOBAL_ATTRIBUTE17;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE18 := p_vendor_site_rec.GLOBAL_ATTRIBUTE18;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE19 := p_vendor_site_rec.GLOBAL_ATTRIBUTE19;
	p_vendor_site_rec_a.GLOBAL_ATTRIBUTE20 := p_vendor_site_rec.GLOBAL_ATTRIBUTE20;
	p_vendor_site_rec_a.TP_HEADER_ID := p_vendor_site_rec.TP_HEADER_ID;
	p_vendor_site_rec_a.ECE_TP_LOCATION_CODE := p_vendor_site_rec.ECE_TP_LOCATION_CODE;
	p_vendor_site_rec_a.PCARD_SITE_FLAG := p_vendor_site_rec.PCARD_SITE_FLAG;
	p_vendor_site_rec_a.MATCH_OPTION := p_vendor_site_rec.MATCH_OPTION;
	p_vendor_site_rec_a.COUNTRY_OF_ORIGIN_CODE := p_vendor_site_rec.COUNTRY_OF_ORIGIN_CODE;
	p_vendor_site_rec_a.FUTURE_DATED_PAYMENT_CCID := p_vendor_site_rec.FUTURE_DATED_PAYMENT_CCID;
	p_vendor_site_rec_a.CREATE_DEBIT_MEMO_FLAG := p_vendor_site_rec.CREATE_DEBIT_MEMO_FLAG;
	p_vendor_site_rec_a.SUPPLIER_NOTIF_METHOD := p_vendor_site_rec.SUPPLIER_NOTIF_METHOD;
	p_vendor_site_rec_a.EMAIL_ADDRESS := p_vendor_site_rec.EMAIL_ADDRESS;
	p_vendor_site_rec_a.PRIMARY_PAY_SITE_FLAG := p_vendor_site_rec.PRIMARY_PAY_SITE_FLAG;
	p_vendor_site_rec_a.SHIPPING_CONTROL := p_vendor_site_rec.SHIPPING_CONTROL;
	p_vendor_site_rec_a.SELLING_COMPANY_IDENTIFIER := p_vendor_site_rec.SELLING_COMPANY_IDENTIFIER;
	p_vendor_site_rec_a.GAPLESS_INV_NUM_FLAG := p_vendor_site_rec.GAPLESS_INV_NUM_FLAG;
	p_vendor_site_rec_a.LOCATION_ID := p_vendor_site_rec.LOCATION_ID;
	p_vendor_site_rec_a.PARTY_SITE_ID := p_vendor_site_rec.PARTY_SITE_ID;
	p_vendor_site_rec_a.ORG_NAME := p_vendor_site_rec.ORG_NAME;
	p_vendor_site_rec_a.DUNS_NUMBER := p_vendor_site_rec.DUNS_NUMBER;
	p_vendor_site_rec_a.ADDRESS_STYLE := p_vendor_site_rec.ADDRESS_STYLE;
	p_vendor_site_rec_a.LANGUAGE := p_vendor_site_rec.LANGUAGE;
	p_vendor_site_rec_a.PROVINCE := p_vendor_site_rec.PROVINCE;
	p_vendor_site_rec_a.COUNTRY := p_vendor_site_rec.COUNTRY;
	p_vendor_site_rec_a.ADDRESS_LINE1 := p_vendor_site_rec.ADDRESS_LINE1;
	p_vendor_site_rec_a.ADDRESS_LINE2 := p_vendor_site_rec.ADDRESS_LINE2;
	p_vendor_site_rec_a.ADDRESS_LINE3 := p_vendor_site_rec.ADDRESS_LINE3;
	p_vendor_site_rec_a.ADDRESS_LINE4 := p_vendor_site_rec.ADDRESS_LINE4;
	p_vendor_site_rec_a.ADDRESS_LINES_ALT := p_vendor_site_rec.ADDRESS_LINES_ALT;
	p_vendor_site_rec_a.COUNTY := p_vendor_site_rec.COUNTY;
	p_vendor_site_rec_a.CITY := p_vendor_site_rec.CITY;
	p_vendor_site_rec_a.STATE := p_vendor_site_rec.STATE;
	p_vendor_site_rec_a.ZIP := p_vendor_site_rec.ZIP;
	p_vendor_site_rec_a.TERMS_NAME := p_vendor_site_rec.TERMS_NAME;
	p_vendor_site_rec_a.DEFAULT_TERMS_ID := p_vendor_site_rec.DEFAULT_TERMS_ID;
	p_vendor_site_rec_a.AWT_GROUP_NAME := p_vendor_site_rec.AWT_GROUP_NAME;
	p_vendor_site_rec_a.DISTRIBUTION_SET_NAME := p_vendor_site_rec.DISTRIBUTION_SET_NAME;
        p_vendor_site_rec_a.SHIP_TO_LOCATION_CODE := p_vendor_site_rec.SHIP_TO_LOCATION_CODE;
        p_vendor_site_rec_a.BILL_TO_LOCATION_CODE := p_vendor_site_rec.BILL_TO_LOCATION_CODE;
    	p_vendor_site_rec_a.DEFAULT_DIST_SET_ID := p_vendor_site_rec.DEFAULT_DIST_SET_ID;
        p_vendor_site_rec_a.DEFAULT_SHIP_TO_LOC_ID := p_vendor_site_rec.DEFAULT_SHIP_TO_LOC_ID;
        p_vendor_site_rec_a.DEFAULT_BILL_TO_LOC_ID := p_vendor_site_rec.DEFAULT_BILL_TO_LOC_ID;
	p_vendor_site_rec_a.TOLERANCE_ID := p_vendor_site_rec.TOLERANCE_ID;
	p_vendor_site_rec_a.TOLERANCE_NAME := p_vendor_site_rec.TOLERANCE_NAME;
    	p_vendor_site_rec_a.VENDOR_INTERFACE_ID := p_vendor_site_rec.VENDOR_INTERFACE_ID;
    	p_vendor_site_rec_a.VENDOR_SITE_INTERFACE_ID := p_vendor_site_rec.VENDOR_SITE_INTERFACE_ID;
	p_vendor_site_rec_a.RETAINAGE_RATE := p_vendor_site_rec.RETAINAGE_RATE;

-- Call to AP APIs
  AP_VENDOR_PUB_PKG.Update_Vendor_Site
  ( 	p_api_version,
  	p_init_msg_list,
	p_commit,
	p_validation_level,
	x_return_status,
	x_msg_count,
	x_msg_data,
	p_vendor_site_rec_a,
	p_vendor_site_id
  );
END Update_Vendor_Site;
END;



/
