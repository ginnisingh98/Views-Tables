--------------------------------------------------------
--  DDL for Package Body AR_TRX_GLOBAL_PROCESS_TMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_TRX_GLOBAL_PROCESS_TMP" AS
/* $Header: ARINGTTB.pls 120.10 2007/06/21 21:04:13 mraymond ship $ */
pg_debug     VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

PROCEDURE INSERT_ROWS (
    p_trx_header_tbl        IN   AR_INVOICE_API_PUB.trx_header_tbl_type,
    p_trx_lines_tbl         IN   AR_INVOICE_API_PUB.trx_line_tbl_type,
    p_trx_dist_tbl          IN   AR_INVOICE_API_PUB.trx_dist_tbl_type,
    p_trx_salescredits_tbl  IN   AR_INVOICE_API_PUB.trx_salescredits_tbl_type,
    x_errmsg                OUT NOCOPY  VARCHAR2,
    x_return_status         OUT NOCOPY  VARCHAR2
    ) IS
    RecExist  Number;
BEGIN

    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_TRX_GLOBAL_PROCESS_TMP.INSERT_ROWS(+)');
    END IF;

--For header
  RecExist := p_trx_header_tbl.FIRST;
  IF pg_debug = 'Y'
  THEN
      ar_invoice_utils.debug ('Record Count ' || RecExist);
  END IF;
  IF RecExist >= 1
  THEN
   FOR i IN  p_trx_header_tbl.FIRST .. p_trx_header_tbl.LAST
   LOOP
       -- 4188835 added legal_entity_id
       INSERT INTO ar_trx_header_tmp_gt (
                    TRX_HEADER_ID,
                    TRX_NUMBER,
                    TRX_DATE,
                    TRX_CURRENCY,
                    REFERENCE_NUMBER,
                    TRX_CLASS,
                    CUST_TRX_TYPE_ID,
                    GL_DATE,
                    BILL_TO_CUSTOMER_ID,
                    BILL_TO_ACCOUNT_NUMBER,
                    BILL_TO_CUSTOMER_NAME,
                    BILL_TO_CONTACT_ID,
                    BILL_TO_ADDRESS_ID,
                    BILL_TO_SITE_USE_ID,
                    SHIP_TO_CUSTOMER_ID,
                    SHIP_TO_ACCOUNT_NUMBER,
                    SHIP_TO_CUSTOMER_NAME,
                    SHIP_TO_CONTACT_ID,
                    SHIP_TO_ADDRESS_ID,
                    SHIP_TO_SITE_USE_ID,
                    SOLD_TO_CUSTOMER_ID,
                    TERM_ID,
                    PRIMARY_SALESREP_ID,
                    PRIMARY_SALESREP_NAME,
                    EXCHANGE_RATE_TYPE,
                    EXCHANGE_DATE,
                    EXCHANGE_RATE,
                    TERRITORY_ID,
                    REMIT_TO_ADDRESS_ID,
                    INVOICING_RULE_ID,
                    PRINTING_OPTION,
                    PURCHASE_ORDER,
                    PURCHASE_ORDER_REVISION,
                    PURCHASE_ORDER_DATE,
                    COMMENTS,
                    INTERNAL_NOTES,
                    FINANCE_CHARGES,
                    RECEIPT_METHOD_ID,
                    RELATED_CUSTOMER_TRX_ID,
                    AGREEMENT_ID,
                    SHIP_VIA,
                    SHIP_DATE_ACTUAL,
                    WAYBILL_NUMBER,
                    FOB_POINT,
                    CUSTOMER_BANK_ACCOUNT_ID,
                    DEFAULT_USSGL_TRANSACTION_CODE,
                    STATUS_TRX,
                    PAYING_CUSTOMER_ID,
                    PAYING_SITE_USE_ID,
                    DEFAULT_TAX_EXEMPT_FLAG,
                    DOC_SEQUENCE_VALUE,
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
                    GLOBAL_ATTRIBUTE21,
                    GLOBAL_ATTRIBUTE22,
                    GLOBAL_ATTRIBUTE23,
                    GLOBAL_ATTRIBUTE24,
                    GLOBAL_ATTRIBUTE25,
                    GLOBAL_ATTRIBUTE26,
                    GLOBAL_ATTRIBUTE27,
                    GLOBAL_ATTRIBUTE28,
                    GLOBAL_ATTRIBUTE29,
                    GLOBAL_ATTRIBUTE30,
                    INTERFACE_HEADER_CONTEXT,
                    INTERFACE_HEADER_ATTRIBUTE1,
                    INTERFACE_HEADER_ATTRIBUTE2,
                    INTERFACE_HEADER_ATTRIBUTE3,
                    INTERFACE_HEADER_ATTRIBUTE4,
                    INTERFACE_HEADER_ATTRIBUTE5,
                    INTERFACE_HEADER_ATTRIBUTE6,
                    INTERFACE_HEADER_ATTRIBUTE7,
                    INTERFACE_HEADER_ATTRIBUTE8,
                    INTERFACE_HEADER_ATTRIBUTE9,
                    INTERFACE_HEADER_ATTRIBUTE10,
                    INTERFACE_HEADER_ATTRIBUTE11,
                    INTERFACE_HEADER_ATTRIBUTE12,
                    INTERFACE_HEADER_ATTRIBUTE13,
                    INTERFACE_HEADER_ATTRIBUTE14,
                    INTERFACE_HEADER_ATTRIBUTE15,
                    ORG_ID,
                    LEGAL_ENTITY_ID,
                    payment_trxn_extension_id,
                    BILLING_DATE,
                    interest_header_id,
                    late_charges_assessed,
                    DOCUMENT_SUB_TYPE,
                    DEFAULT_TAXATION_COUNTRY
					)
        VALUES
            (     p_trx_header_tbl(i).TRX_HEADER_ID,
                  p_trx_header_tbl(i).TRX_NUMBER,
                  p_trx_header_tbl(i).TRX_DATE,
                  p_trx_header_tbl(i).TRX_CURRENCY,
                  p_trx_header_tbl(i).REFERENCE_NUMBER,
                  p_trx_header_tbl(i).TRX_CLASS,
                  p_trx_header_tbl(i).CUST_TRX_TYPE_ID,
                  p_trx_header_tbl(i).GL_DATE,
                  p_trx_header_tbl(i).BILL_TO_CUSTOMER_ID,
                  p_trx_header_tbl(i).BILL_TO_ACCOUNT_NUMBER,
                  p_trx_header_tbl(i).BILL_TO_CUSTOMER_NAME,
                  p_trx_header_tbl(i).BILL_TO_CONTACT_ID,
                  p_trx_header_tbl(i).BILL_TO_ADDRESS_ID,
                  p_trx_header_tbl(i).BILL_TO_SITE_USE_ID,
                  p_trx_header_tbl(i).SHIP_TO_CUSTOMER_ID,
                  p_trx_header_tbl(i).SHIP_TO_ACCOUNT_NUMBER,
                  p_trx_header_tbl(i).SHIP_TO_CUSTOMER_NAME,
                  p_trx_header_tbl(i).SHIP_TO_CONTACT_ID,
                  p_trx_header_tbl(i).SHIP_TO_ADDRESS_ID,
                  p_trx_header_tbl(i).SHIP_TO_SITE_USE_ID,
                  p_trx_header_tbl(i).SOLD_TO_CUSTOMER_ID,
                  p_trx_header_tbl(i).TERM_ID,
                  p_trx_header_tbl(i).PRIMARY_SALESREP_ID,
                  p_trx_header_tbl(i).PRIMARY_SALESREP_NAME,
                  p_trx_header_tbl(i).EXCHANGE_RATE_TYPE,
                  p_trx_header_tbl(i).EXCHANGE_DATE,
                  p_trx_header_tbl(i).EXCHANGE_RATE,
                  p_trx_header_tbl(i).TERRITORY_ID,
                  p_trx_header_tbl(i).REMIT_TO_ADDRESS_ID,
                  p_trx_header_tbl(i).INVOICING_RULE_ID,
                  p_trx_header_tbl(i).PRINTING_OPTION,
                  p_trx_header_tbl(i).PURCHASE_ORDER,
                  p_trx_header_tbl(i).PURCHASE_ORDER_REVISION,
                  p_trx_header_tbl(i).PURCHASE_ORDER_DATE,
                  p_trx_header_tbl(i).COMMENTS,
                  p_trx_header_tbl(i).INTERNAL_NOTES,
                  p_trx_header_tbl(i).FINANCE_CHARGES,
                  p_trx_header_tbl(i).RECEIPT_METHOD_ID,
                  p_trx_header_tbl(i).RELATED_CUSTOMER_TRX_ID,
                  p_trx_header_tbl(i).AGREEMENT_ID,
                  p_trx_header_tbl(i).SHIP_VIA,
                  p_trx_header_tbl(i).SHIP_DATE_ACTUAL,
                  p_trx_header_tbl(i).WAYBILL_NUMBER,
                  p_trx_header_tbl(i).FOB_POINT,
                  p_trx_header_tbl(i).CUSTOMER_BANK_ACCOUNT_ID,
                  p_trx_header_tbl(i).DEFAULT_USSGL_TRANSACTION_CODE,
                  p_trx_header_tbl(i).STATUS_TRX,
                  p_trx_header_tbl(i).PAYING_CUSTOMER_ID,
                  p_trx_header_tbl(i).PAYING_SITE_USE_ID,
                  p_trx_header_tbl(i).DEFAULT_TAX_EXEMPT_FLAG,
                  p_trx_header_tbl(i).DOC_SEQUENCE_VALUE,
                  p_trx_header_tbl(i).ATTRIBUTE_CATEGORY,
                  p_trx_header_tbl(i).ATTRIBUTE1,
                  p_trx_header_tbl(i).ATTRIBUTE2,
                  p_trx_header_tbl(i).ATTRIBUTE3,
                  p_trx_header_tbl(i).ATTRIBUTE4,
                  p_trx_header_tbl(i).ATTRIBUTE5,
                  p_trx_header_tbl(i).ATTRIBUTE6,
                  p_trx_header_tbl(i).ATTRIBUTE7,
                  p_trx_header_tbl(i).ATTRIBUTE8,
                  p_trx_header_tbl(i).ATTRIBUTE9,
                  p_trx_header_tbl(i).ATTRIBUTE10,
                  p_trx_header_tbl(i).ATTRIBUTE11,
                  p_trx_header_tbl(i).ATTRIBUTE12,
                  p_trx_header_tbl(i).ATTRIBUTE13,
                  p_trx_header_tbl(i).ATTRIBUTE14,
                  p_trx_header_tbl(i).ATTRIBUTE15,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE_CATEGORY,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE1,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE2,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE3,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE4,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE5,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE6,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE7,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE8,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE9,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE10,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE11,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE12,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE13,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE14,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE15,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE16,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE17,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE18,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE19,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE20,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE21,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE22,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE23,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE24,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE25,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE26,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE27,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE28,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE29,
                  p_trx_header_tbl(i).GLOBAL_ATTRIBUTE30,
                  p_trx_header_tbl(i).INTERFACE_HEADER_CONTEXT,
                  p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE1,
                  p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE2,
                  p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE3,
                  p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE4,
                  p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE5,
                  p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE6,
                  p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE7,
                  p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE8,
                  p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE9,
                  p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE10,
                  p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE11,
                  p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE12,
                  p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE13,
                  p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE14,
                  p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE15,
                  p_trx_header_tbl(i).org_id,
                  p_trx_header_tbl(i).legal_entity_id,
                  p_trx_header_tbl(i).payment_trxn_extension_id,
                  p_trx_header_tbl(i).BILLING_DATE,
                  p_trx_header_tbl(i).interest_header_id,
                  p_trx_header_tbl(i).late_charges_assessed,
                  p_trx_header_tbl(i).document_sub_type,
                  p_trx_header_tbl(i).default_taxation_country
);
   END LOOP;
 END IF;

--For Lines
  RecExist := p_trx_lines_tbl.FIRST;
  IF pg_debug = 'Y'
  THEN
      ar_invoice_utils.debug ('Record Count ' || RecExist);
  END IF;
  IF RecExist >= 1
  THEN
   FOR i IN  p_trx_lines_tbl.FIRST .. p_trx_lines_tbl.LAST
   LOOP
         INSERT INTO ar_trx_lines_tmp_gt
           (                     TRX_HEADER_ID,
                     TRX_LINE_ID,
                     LINK_TO_TRX_LINE_ID,
                     LINE_NUMBER,
                     REASON_CODE,
                     INVENTORY_ITEM_ID,
                     DESCRIPTION,
                     QUANTITY_ORDERED,
                     QUANTITY_INVOICED,
                     UNIT_STANDARD_PRICE,
                     UNIT_SELLING_PRICE,
                     SALES_ORDER,
                     SALES_ORDER_LINE,
                     SALES_ORDER_DATE,
                     ACCOUNTING_RULE_ID,
                     LINE_TYPE,
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
                     RULE_START_DATE,
                     INTERFACE_LINE_CONTEXT,
                     INTERFACE_LINE_ATTRIBUTE1,
                     INTERFACE_LINE_ATTRIBUTE2,
                     INTERFACE_LINE_ATTRIBUTE3,
                     INTERFACE_LINE_ATTRIBUTE4,
                     INTERFACE_LINE_ATTRIBUTE5,
                     INTERFACE_LINE_ATTRIBUTE6,
                     INTERFACE_LINE_ATTRIBUTE7,
                     INTERFACE_LINE_ATTRIBUTE8,
                     INTERFACE_LINE_ATTRIBUTE9,
                     INTERFACE_LINE_ATTRIBUTE10,
                     INTERFACE_LINE_ATTRIBUTE11,
                     INTERFACE_LINE_ATTRIBUTE12,
                     INTERFACE_LINE_ATTRIBUTE13,
                     INTERFACE_LINE_ATTRIBUTE14,
                     INTERFACE_LINE_ATTRIBUTE15,
                     SALES_ORDER_SOURCE,
                     AMOUNT,
                     TAX_PRECEDENCE,
                     TAX_RATE,
                     TAX_EXEMPTION_ID,
                     MEMO_LINE_ID,
                     UOM_CODE,
                     DEFAULT_USSGL_TRANSACTION_CODE,
                     DEFAULT_USSGL_TRX_CODE_CONTEXT,
                     VAT_TAX_ID,
                     TAX_EXEMPT_FLAG,
                     TAX_EXEMPT_NUMBER,
                     TAX_EXEMPT_REASON_CODE,
                     TAX_VENDOR_RETURN_CODE,
                     MOVEMENT_ID,
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
                     GLOBAL_ATTRIBUTE_CATEGORY,
                     AMOUNT_INCLUDES_TAX_FLAG,
                     WAREHOUSE_ID,
                     CONTRACT_LINE_ID,
                     SOURCE_DATA_KEY1,
                     SOURCE_DATA_KEY2,
                     SOURCE_DATA_KEY3,
                     SOURCE_DATA_KEY4,
                     SOURCE_DATA_KEY5,
                     INVOICED_LINE_ACCTG_LEVEL,
                     SHIP_DATE_ACTUAL,
		     RULE_END_DATE,
                     SOURCE_APPLICATION_ID,
                     SOURCE_EVENT_CLASS_CODE,
                     SOURCE_ENTITY_CODE,
                     SOURCE_TRX_ID,
                     SOURCE_TRX_LINE_ID,
                     SOURCE_TRX_LINE_TYPE,
                     SOURCE_TRX_DETAIL_TAX_LINE_ID,
                     HISTORICAL_FLAG,
                     TAXABLE_FLAG,
                     TAX_REGIME_CODE,
                     TAX,
                     TAX_STATUS_CODE,
                     TAX_RATE_CODE,
                     TAX_JURISDICTION_CODE,
                     TAX_CLASSIFICATION_CODE,
                     INTEREST_LINE_ID,
                     TRX_BUSINESS_CATEGORY,
                     PRODUCT_FISC_CLASSIFICATION,
                     PRODUCT_CATEGORY,
                     PRODUCT_TYPE,
                     LINE_INTENDED_USE,
                     ASSESSABLE_VALUE
            )
          VALUES
            (   p_trx_lines_tbl(i).TRX_HEADER_ID,
                p_trx_lines_tbl(i).TRX_LINE_ID,
                p_trx_lines_tbl(i).LINK_TO_TRX_LINE_ID,
                p_trx_lines_tbl(i).LINE_NUMBER,
                p_trx_lines_tbl(i).REASON_CODE,
                p_trx_lines_tbl(i).INVENTORY_ITEM_ID,
                p_trx_lines_tbl(i).DESCRIPTION,
                p_trx_lines_tbl(i).QUANTITY_ORDERED,
                p_trx_lines_tbl(i).QUANTITY_INVOICED,
                p_trx_lines_tbl(i).UNIT_STANDARD_PRICE,
                p_trx_lines_tbl(i).UNIT_SELLING_PRICE,
                p_trx_lines_tbl(i).SALES_ORDER,
                p_trx_lines_tbl(i).SALES_ORDER_LINE,
                p_trx_lines_tbl(i).SALES_ORDER_DATE,
                p_trx_lines_tbl(i).ACCOUNTING_RULE_ID,
                p_trx_lines_tbl(i).LINE_TYPE,
                p_trx_lines_tbl(i).ATTRIBUTE_CATEGORY,
                p_trx_lines_tbl(i).ATTRIBUTE1,
                p_trx_lines_tbl(i).ATTRIBUTE2,
                p_trx_lines_tbl(i).ATTRIBUTE3,
                p_trx_lines_tbl(i).ATTRIBUTE4,
                p_trx_lines_tbl(i).ATTRIBUTE5,
                p_trx_lines_tbl(i).ATTRIBUTE6,
                p_trx_lines_tbl(i).ATTRIBUTE7,
                p_trx_lines_tbl(i).ATTRIBUTE8,
                p_trx_lines_tbl(i).ATTRIBUTE9,
                p_trx_lines_tbl(i).ATTRIBUTE10,
                p_trx_lines_tbl(i).ATTRIBUTE11,
                p_trx_lines_tbl(i).ATTRIBUTE12,
                p_trx_lines_tbl(i).ATTRIBUTE13,
                p_trx_lines_tbl(i).ATTRIBUTE14,
                p_trx_lines_tbl(i).ATTRIBUTE15,
                p_trx_lines_tbl(i).RULE_START_DATE,
                p_trx_lines_tbl(i).INTERFACE_LINE_CONTEXT,
                p_trx_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE1,
                p_trx_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE2,
                p_trx_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE3,
                p_trx_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE4,
                p_trx_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE5,
                p_trx_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE6,
                p_trx_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE7,
                p_trx_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE8,
                p_trx_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE9,
                p_trx_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE10,
                p_trx_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE11,
                p_trx_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE12,
                p_trx_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE13,
                p_trx_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE14,
                p_trx_lines_tbl(i).INTERFACE_LINE_ATTRIBUTE15,
                p_trx_lines_tbl(i).SALES_ORDER_SOURCE,
                p_trx_lines_tbl(i).AMOUNT,
                p_trx_lines_tbl(i).TAX_PRECEDENCE,
                p_trx_lines_tbl(i).TAX_RATE,
                p_trx_lines_tbl(i).TAX_EXEMPTION_ID,
                p_trx_lines_tbl(i).MEMO_LINE_ID,
                p_trx_lines_tbl(i).UOM_CODE,
                p_trx_lines_tbl(i).DEFAULT_USSGL_TRANSACTION_CODE,
                p_trx_lines_tbl(i).DEFAULT_USSGL_TRX_CODE_CONTEXT,
                p_trx_lines_tbl(i).VAT_TAX_ID,
                p_trx_lines_tbl(i).TAX_EXEMPT_FLAG,
                p_trx_lines_tbl(i).TAX_EXEMPT_NUMBER,
                p_trx_lines_tbl(i).TAX_EXEMPT_REASON_CODE,
                p_trx_lines_tbl(i).TAX_VENDOR_RETURN_CODE,
                p_trx_lines_tbl(i).MOVEMENT_ID,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE1,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE2,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE3,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE4,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE5,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE6,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE7,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE8,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE9,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE10,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE11,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE12,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE13,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE14,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE15,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE16,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE17,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE18,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE19,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE20,
                p_trx_lines_tbl(i).GLOBAL_ATTRIBUTE_CATEGORY,
                p_trx_lines_tbl(i).AMOUNT_INCLUDES_TAX_FLAG,
                p_trx_lines_tbl(i).WAREHOUSE_ID,
                p_trx_lines_tbl(i).CONTRACT_LINE_ID,
                p_trx_lines_tbl(i).SOURCE_DATA_KEY1,
                p_trx_lines_tbl(i).SOURCE_DATA_KEY2,
                p_trx_lines_tbl(i).SOURCE_DATA_KEY3,
                p_trx_lines_tbl(i).SOURCE_DATA_KEY4,
                p_trx_lines_tbl(i).SOURCE_DATA_KEY5,
                p_trx_lines_tbl(i).INVOICED_LINE_ACCTG_LEVEL,
                p_trx_lines_tbl(i).SHIP_DATE_ACTUAL,
                p_trx_lines_tbl(i).rule_end_date,
                p_trx_lines_tbl(i).source_application_id,
                p_trx_lines_tbl(i).source_event_class_code,
                p_trx_lines_tbl(i).source_entity_code,
                p_trx_lines_tbl(i).source_trx_id,
                p_trx_lines_tbl(i).source_trx_line_id,
                p_trx_lines_tbl(i).source_trx_line_type,
                p_trx_lines_tbl(i).source_trx_detail_tax_line_id,
                p_trx_lines_tbl(i).historical_flag,
                p_trx_lines_tbl(i).taxable_flag,
                p_trx_lines_tbl(i).tax_regime_code,
                p_trx_lines_tbl(i).tax,
                p_trx_lines_tbl(i).tax_status_code,
                p_trx_lines_tbl(i).tax_rate_code,
                p_trx_lines_tbl(i).tax_jurisdiction_code,
                p_trx_lines_tbl(i).tax_classification_code,
                p_trx_lines_tbl(i).interest_line_id,
                p_trx_lines_tbl(i).trx_business_category,
                p_trx_lines_tbl(i).product_fisc_classification,
                p_trx_lines_tbl(i).product_category,
                p_trx_lines_tbl(i).product_type,
                p_trx_lines_tbl(i).line_intended_use,
                p_trx_lines_tbl(i).assessable_value
            );

    END LOOP;
   END IF;

    RecExist := p_trx_dist_tbl.FIRST;
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('Record Count ' || RecExist);
    END IF;
    IF RecExist >= 1
    THEN
    FOR i IN  p_trx_dist_tbl.FIRST .. p_trx_dist_tbl.LAST
    LOOP
        INSERT INTO ar_trx_dist_tmp_gt
            (                      TRX_DIST_ID,
                      TRX_HEADER_ID,
                      TRX_LINE_ID,
                      ACCOUNT_CLASS,
                      AMOUNT,
                      ACCTD_AMOUNT,
                      PERCENT,
                      CODE_COMBINATION_ID,
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
                      COMMENTS)
        VALUES
            (                   p_trx_dist_tbl(i).TRX_DIST_ID,
                   p_trx_dist_tbl(i).TRX_HEADER_ID,
                   p_trx_dist_tbl(i).TRX_LINE_ID,
                   p_trx_dist_tbl(i).ACCOUNT_CLASS,
                   p_trx_dist_tbl(i).AMOUNT,
                   p_trx_dist_tbl(i).ACCTD_AMOUNT,
                   p_trx_dist_tbl(i).PERCENT,
                   p_trx_dist_tbl(i).CODE_COMBINATION_ID,
                   p_trx_dist_tbl(i).ATTRIBUTE_CATEGORY,
                   p_trx_dist_tbl(i).ATTRIBUTE1,
                   p_trx_dist_tbl(i).ATTRIBUTE2,
                   p_trx_dist_tbl(i).ATTRIBUTE3,
                   p_trx_dist_tbl(i).ATTRIBUTE4,
                   p_trx_dist_tbl(i).ATTRIBUTE5,
                   p_trx_dist_tbl(i).ATTRIBUTE6,
                   p_trx_dist_tbl(i).ATTRIBUTE7,
                   p_trx_dist_tbl(i).ATTRIBUTE8,
                   p_trx_dist_tbl(i).ATTRIBUTE9,
                   p_trx_dist_tbl(i).ATTRIBUTE10,
                   p_trx_dist_tbl(i).ATTRIBUTE11,
                   p_trx_dist_tbl(i).ATTRIBUTE12,
                   p_trx_dist_tbl(i).ATTRIBUTE13,
                   p_trx_dist_tbl(i).ATTRIBUTE14,
                   p_trx_dist_tbl(i).ATTRIBUTE15,
                   p_trx_dist_tbl(i).COMMENTS
            );

    END LOOP;

   END If;


    RecExist := p_trx_salescredits_tbl.FIRST;
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('Record Count ' || RecExist);
    END IF;
    IF RecExist >= 1
    THEN
    FOR i IN  p_trx_salescredits_tbl.FIRST .. p_trx_salescredits_tbl.LAST
    LOOP
        INSERT INTO ar_trx_salescredits_tmp_gt
            (                      TRX_SALESCREDIT_ID,
                      TRX_LINE_ID,
                      SALESREP_ID,
                      SALESREP_NUMBER,
                      SALES_CREDIT_TYPE_NAME,
                      SALES_CREDIT_TYPE_ID,
                      SALESCREDIT_AMOUNT_SPLIT,
                      SALESCREDIT_PERCENT_SPLIT,
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
                      ATTRIBUTE15
            )
         VALUES
            (                      p_trx_salescredits_tbl(i).TRX_SALESCREDIT_ID,
                      p_trx_salescredits_tbl(i).TRX_LINE_ID,
                      p_trx_salescredits_tbl(i).SALESREP_ID,
                      p_trx_salescredits_tbl(i).SALESREP_NUMBER,
                      p_trx_salescredits_tbl(i).SALES_CREDIT_TYPE_NAME,
                      p_trx_salescredits_tbl(i).SALES_CREDIT_TYPE_ID,
                      p_trx_salescredits_tbl(i).SALESCREDIT_AMOUNT_SPLIT,
                      p_trx_salescredits_tbl(i).SALESCREDIT_PERCENT_SPLIT,
                      p_trx_salescredits_tbl(i).ATTRIBUTE_CATEGORY,
                      p_trx_salescredits_tbl(i).ATTRIBUTE1,
                      p_trx_salescredits_tbl(i).ATTRIBUTE2,
                      p_trx_salescredits_tbl(i).ATTRIBUTE3,
                      p_trx_salescredits_tbl(i).ATTRIBUTE4,
                      p_trx_salescredits_tbl(i).ATTRIBUTE5,
                      p_trx_salescredits_tbl(i).ATTRIBUTE6,
                      p_trx_salescredits_tbl(i).ATTRIBUTE7,
                      p_trx_salescredits_tbl(i).ATTRIBUTE8,
                      p_trx_salescredits_tbl(i).ATTRIBUTE9,
                      p_trx_salescredits_tbl(i).ATTRIBUTE10,
                      p_trx_salescredits_tbl(i).ATTRIBUTE11,
                      p_trx_salescredits_tbl(i).ATTRIBUTE12,
                      p_trx_salescredits_tbl(i).ATTRIBUTE13,
                      p_trx_salescredits_tbl(i).ATTRIBUTE14,
                      p_trx_salescredits_tbl(i).ATTRIBUTE15
            );

    END LOOP;
 END IF;

    IF pg_debug = 'Y'
    THEN
     ar_invoice_utils.debug ('AR_TRX_GLOBAL_PROCESS_TMP.INSERT_ROWS(-)');
    END IF;


EXCEPTION
       WHEN OTHERS THEN
       x_errmsg := 'Error in AR_TRX_GLOBAL_PROCESS_TMP.INSERT_ROWS '||sqlerrm;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RETURN;

END INSERT_ROWS;

PROCEDURE GET_ROWS (
     p_org_id                IN   NUMBER DEFAULT NULL,
    p_trx_header_tbl        OUT NOCOPY   AR_INVOICE_API_PUB.trx_header_tbl_type,
    p_trx_lines_tbl         OUT NOCOPY   AR_INVOICE_API_PUB.trx_line_tbl_type,
    p_trx_dist_tbl          OUT NOCOPY   AR_INVOICE_API_PUB.trx_dist_tbl_type,
    p_trx_salescredits_tbl  OUT NOCOPY   AR_INVOICE_API_PUB.trx_salescredits_tbl_type,
    x_errmsg                OUT NOCOPY  VARCHAR2,
    x_return_status         OUT NOCOPY  VARCHAR2
    ) AS

cursor hdr_cur (p_org_id number) is
     select *
     from ar_trx_header_tmp_gt
     where nvl(org_id,-99) = nvl(p_org_id,-99);

cursor ln_cur (P_TRX_HEADER_ID number) is
     select *
     from ar_trx_lines_tmp_gt
     where TRX_HEADER_ID = P_TRX_HEADER_ID;

/* 4652982 - Modified to only insert line-level dists */
cursor dist_cur (P_TRX_LINE_ID number ) is
     select *
     from ar_trx_dist_tmp_gt
     where TRX_LINE_ID = P_TRX_LINE_ID;

/* 4652982 - Added to insert header-level dists */
cursor dist_rec_cur (P_TRX_HEADER_ID number) is
     select *
     from ar_trx_dist_tmp_gt
     where TRX_HEADER_ID = P_TRX_HEADER_ID
     and   TRX_LINE_ID is NULL;

cursor sc_cur (P_TRX_HEADER_ID number, P_TRX_LINE_ID number) is
     select *
     from ar_trx_salescredits_tmp_gt
     where --(TRX_HEADER_ID = P_TRX_HEADER_ID)           or
           (TRX_LINE_ID = P_TRX_LINE_ID);
i number :=0;
j number :=0;
k number :=0;
l number :=0;
BEGIN

       FOR hdr_rec in  hdr_cur(p_org_id) LOOP
       i := i+1;
        -- put header record
               p_trx_header_tbl(i).TRX_HEADER_ID:=	hdr_rec.TRX_HEADER_ID;
               p_trx_header_tbl(i).TRX_NUMBER:=	hdr_rec.TRX_NUMBER;
               p_trx_header_tbl(i).TRX_DATE:=	hdr_rec.TRX_DATE;
               p_trx_header_tbl(i).TRX_CURRENCY:=	hdr_rec.TRX_CURRENCY;
               p_trx_header_tbl(i).REFERENCE_NUMBER:=	hdr_rec.REFERENCE_NUMBER;
               p_trx_header_tbl(i).TRX_CLASS:=	hdr_rec.TRX_CLASS;
               p_trx_header_tbl(i).CUST_TRX_TYPE_ID:=	hdr_rec.CUST_TRX_TYPE_ID;
               p_trx_header_tbl(i).GL_DATE:=	hdr_rec.GL_DATE;
               p_trx_header_tbl(i).BILL_TO_CUSTOMER_ID:=	hdr_rec.BILL_TO_CUSTOMER_ID;
               p_trx_header_tbl(i).BILL_TO_ACCOUNT_NUMBER:=	hdr_rec.BILL_TO_ACCOUNT_NUMBER;
               p_trx_header_tbl(i).BILL_TO_CUSTOMER_NAME:=	hdr_rec.BILL_TO_CUSTOMER_NAME;
               p_trx_header_tbl(i).BILL_TO_CONTACT_ID:=	hdr_rec.BILL_TO_CONTACT_ID;
               p_trx_header_tbl(i).BILL_TO_ADDRESS_ID:=	hdr_rec.BILL_TO_ADDRESS_ID;
               p_trx_header_tbl(i).BILL_TO_SITE_USE_ID:=	hdr_rec.BILL_TO_SITE_USE_ID;
               p_trx_header_tbl(i).SHIP_TO_CUSTOMER_ID:=	hdr_rec.SHIP_TO_CUSTOMER_ID;
               p_trx_header_tbl(i).SHIP_TO_ACCOUNT_NUMBER:=	hdr_rec.SHIP_TO_ACCOUNT_NUMBER;
               p_trx_header_tbl(i).SHIP_TO_CUSTOMER_NAME:=	hdr_rec.SHIP_TO_CUSTOMER_NAME;
               p_trx_header_tbl(i).SHIP_TO_CONTACT_ID:=	hdr_rec.SHIP_TO_CONTACT_ID;
               p_trx_header_tbl(i).SHIP_TO_ADDRESS_ID:=	hdr_rec.SHIP_TO_ADDRESS_ID;
               p_trx_header_tbl(i).SHIP_TO_SITE_USE_ID:=	hdr_rec.SHIP_TO_SITE_USE_ID;
               p_trx_header_tbl(i).SOLD_TO_CUSTOMER_ID:=	hdr_rec.SOLD_TO_CUSTOMER_ID;
               p_trx_header_tbl(i).TERM_ID:=	hdr_rec.TERM_ID;
               p_trx_header_tbl(i).PRIMARY_SALESREP_ID:=	hdr_rec.PRIMARY_SALESREP_ID;
               p_trx_header_tbl(i).PRIMARY_SALESREP_NAME:=	hdr_rec.PRIMARY_SALESREP_NAME;
               p_trx_header_tbl(i).EXCHANGE_RATE_TYPE:=	hdr_rec.EXCHANGE_RATE_TYPE;
               p_trx_header_tbl(i).EXCHANGE_DATE:=	hdr_rec.EXCHANGE_DATE;
               p_trx_header_tbl(i).EXCHANGE_RATE:=	hdr_rec.EXCHANGE_RATE;
               p_trx_header_tbl(i).TERRITORY_ID:=	hdr_rec.TERRITORY_ID;
               p_trx_header_tbl(i).REMIT_TO_ADDRESS_ID:=	hdr_rec.REMIT_TO_ADDRESS_ID;
               p_trx_header_tbl(i).INVOICING_RULE_ID:=	hdr_rec.INVOICING_RULE_ID;
               p_trx_header_tbl(i).PRINTING_OPTION:=	hdr_rec.PRINTING_OPTION;
               p_trx_header_tbl(i).PURCHASE_ORDER:=	hdr_rec.PURCHASE_ORDER;
               p_trx_header_tbl(i).PURCHASE_ORDER_REVISION:=	hdr_rec.PURCHASE_ORDER_REVISION;
               p_trx_header_tbl(i).PURCHASE_ORDER_DATE:=	hdr_rec.PURCHASE_ORDER_DATE;
               p_trx_header_tbl(i).COMMENTS:=	hdr_rec.COMMENTS;
               p_trx_header_tbl(i).INTERNAL_NOTES:=	hdr_rec.INTERNAL_NOTES;
               p_trx_header_tbl(i).FINANCE_CHARGES:=	hdr_rec.FINANCE_CHARGES;
               p_trx_header_tbl(i).RECEIPT_METHOD_ID:=	hdr_rec.RECEIPT_METHOD_ID;
               p_trx_header_tbl(i).RELATED_CUSTOMER_TRX_ID:=	hdr_rec.RELATED_CUSTOMER_TRX_ID;
               p_trx_header_tbl(i).AGREEMENT_ID:=	hdr_rec.AGREEMENT_ID;
               p_trx_header_tbl(i).SHIP_VIA:=	hdr_rec.SHIP_VIA;
               p_trx_header_tbl(i).SHIP_DATE_ACTUAL:=	hdr_rec.SHIP_DATE_ACTUAL;
               p_trx_header_tbl(i).WAYBILL_NUMBER:=	hdr_rec.WAYBILL_NUMBER;
               p_trx_header_tbl(i).FOB_POINT:=	hdr_rec.FOB_POINT;
               p_trx_header_tbl(i).CUSTOMER_BANK_ACCOUNT_ID:=	hdr_rec.CUSTOMER_BANK_ACCOUNT_ID;
               p_trx_header_tbl(i).DEFAULT_USSGL_TRANSACTION_CODE:=	hdr_rec.DEFAULT_USSGL_TRANSACTION_CODE;
               p_trx_header_tbl(i).STATUS_TRX:=	hdr_rec.STATUS_TRX;
               p_trx_header_tbl(i).PAYING_CUSTOMER_ID:=	hdr_rec.PAYING_CUSTOMER_ID;
               p_trx_header_tbl(i).PAYING_SITE_USE_ID:=	hdr_rec.PAYING_SITE_USE_ID;
               p_trx_header_tbl(i).DEFAULT_TAX_EXEMPT_FLAG:=	hdr_rec.DEFAULT_TAX_EXEMPT_FLAG;
               p_trx_header_tbl(i).DOC_SEQUENCE_VALUE:=	hdr_rec.DOC_SEQUENCE_VALUE;
               p_trx_header_tbl(i).ATTRIBUTE_CATEGORY:=	hdr_rec.ATTRIBUTE_CATEGORY;
               p_trx_header_tbl(i).ATTRIBUTE1:=	hdr_rec.ATTRIBUTE1;
               p_trx_header_tbl(i).ATTRIBUTE2:=	hdr_rec.ATTRIBUTE2;
               p_trx_header_tbl(i).ATTRIBUTE3:=	hdr_rec.ATTRIBUTE3;
               p_trx_header_tbl(i).ATTRIBUTE4:=	hdr_rec.ATTRIBUTE4;
               p_trx_header_tbl(i).ATTRIBUTE5:=	hdr_rec.ATTRIBUTE5;
               p_trx_header_tbl(i).ATTRIBUTE6:=	hdr_rec.ATTRIBUTE6;
               p_trx_header_tbl(i).ATTRIBUTE7:=	hdr_rec.ATTRIBUTE7;
               p_trx_header_tbl(i).ATTRIBUTE8:=	hdr_rec.ATTRIBUTE8;
               p_trx_header_tbl(i).ATTRIBUTE9:=	hdr_rec.ATTRIBUTE9;
               p_trx_header_tbl(i).ATTRIBUTE10:=	hdr_rec.ATTRIBUTE10;
               p_trx_header_tbl(i).ATTRIBUTE11:=	hdr_rec.ATTRIBUTE11;
               p_trx_header_tbl(i).ATTRIBUTE12:=	hdr_rec.ATTRIBUTE12;
               p_trx_header_tbl(i).ATTRIBUTE13:=	hdr_rec.ATTRIBUTE13;
               p_trx_header_tbl(i).ATTRIBUTE14:=	hdr_rec.ATTRIBUTE14;
               p_trx_header_tbl(i).ATTRIBUTE15:=	hdr_rec.ATTRIBUTE15;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE_CATEGORY:=	hdr_rec.GLOBAL_ATTRIBUTE_CATEGORY;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE1:=	hdr_rec.GLOBAL_ATTRIBUTE1;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE2:=	hdr_rec.GLOBAL_ATTRIBUTE2;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE3:=	hdr_rec.GLOBAL_ATTRIBUTE3;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE4:=	hdr_rec.GLOBAL_ATTRIBUTE4;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE5:=	hdr_rec.GLOBAL_ATTRIBUTE5;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE6:=	hdr_rec.GLOBAL_ATTRIBUTE6;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE7:=	hdr_rec.GLOBAL_ATTRIBUTE7;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE8:=	hdr_rec.GLOBAL_ATTRIBUTE8;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE9:=	hdr_rec.GLOBAL_ATTRIBUTE9;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE10:=	hdr_rec.GLOBAL_ATTRIBUTE10;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE11:=	hdr_rec.GLOBAL_ATTRIBUTE11;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE12:=	hdr_rec.GLOBAL_ATTRIBUTE12;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE13:=	hdr_rec.GLOBAL_ATTRIBUTE13;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE14:=	hdr_rec.GLOBAL_ATTRIBUTE14;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE15:=	hdr_rec.GLOBAL_ATTRIBUTE15;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE16:=	hdr_rec.GLOBAL_ATTRIBUTE16;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE17:=	hdr_rec.GLOBAL_ATTRIBUTE17;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE18:=	hdr_rec.GLOBAL_ATTRIBUTE18;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE19:=	hdr_rec.GLOBAL_ATTRIBUTE19;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE20:=	hdr_rec.GLOBAL_ATTRIBUTE20;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE21:=	hdr_rec.GLOBAL_ATTRIBUTE21;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE22:=	hdr_rec.GLOBAL_ATTRIBUTE22;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE23:=	hdr_rec.GLOBAL_ATTRIBUTE23;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE24:=	hdr_rec.GLOBAL_ATTRIBUTE24;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE25:=	hdr_rec.GLOBAL_ATTRIBUTE25;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE26:=	hdr_rec.GLOBAL_ATTRIBUTE26;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE27:=	hdr_rec.GLOBAL_ATTRIBUTE27;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE28:=	hdr_rec.GLOBAL_ATTRIBUTE28;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE29:=	hdr_rec.GLOBAL_ATTRIBUTE29;
               p_trx_header_tbl(i).GLOBAL_ATTRIBUTE30:=	hdr_rec.GLOBAL_ATTRIBUTE30;
               p_trx_header_tbl(i).INTERFACE_HEADER_CONTEXT:=	hdr_rec.INTERFACE_HEADER_CONTEXT;
               p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE1:=	hdr_rec.INTERFACE_HEADER_ATTRIBUTE1;
               p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE2:=	hdr_rec.INTERFACE_HEADER_ATTRIBUTE2;
               p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE3:=	hdr_rec.INTERFACE_HEADER_ATTRIBUTE3;
               p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE4:=	hdr_rec.INTERFACE_HEADER_ATTRIBUTE4;
               p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE5:=	hdr_rec.INTERFACE_HEADER_ATTRIBUTE5;
               p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE6:=	hdr_rec.INTERFACE_HEADER_ATTRIBUTE6;
               p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE7:=	hdr_rec.INTERFACE_HEADER_ATTRIBUTE7;
               p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE8:=	hdr_rec.INTERFACE_HEADER_ATTRIBUTE8;
               p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE9:=	hdr_rec.INTERFACE_HEADER_ATTRIBUTE9;
               p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE10:=	hdr_rec.INTERFACE_HEADER_ATTRIBUTE10;
               p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE11:=	hdr_rec.INTERFACE_HEADER_ATTRIBUTE11;
               p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE12:=	hdr_rec.INTERFACE_HEADER_ATTRIBUTE12;
               p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE13:=	hdr_rec.INTERFACE_HEADER_ATTRIBUTE13;
               p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE14:=	hdr_rec.INTERFACE_HEADER_ATTRIBUTE14;
               p_trx_header_tbl(i).INTERFACE_HEADER_ATTRIBUTE15:=	hdr_rec.INTERFACE_HEADER_ATTRIBUTE15;
               p_trx_header_tbl(i).ORG_ID:=	hdr_rec.ORG_ID;
               -- 4188835
               p_trx_header_tbl(i).LEGAL_ENTITY_ID := hdr_rec.LEGAL_ENTITY_ID;
               p_trx_header_tbl(i).PAYMENT_TRXN_EXTENSION_ID := hdr_rec.PAYMENT_TRXN_EXTENSION_ID;
               p_trx_header_tbl(i).BILLING_DATE := hdr_rec.BILLING_DATE;
               --Late Charges
               p_trx_header_tbl(i).INTEREST_HEADER_ID    := hdr_rec.INTEREST_HEADER_ID;
               p_trx_header_tbl(i).LATE_CHARGES_ASSESSED := hdr_rec.LATE_CHARGES_ASSESSED;
               p_trx_header_tbl(i).DOCUMENT_SUB_TYPE := hdr_rec.document_sub_type;
               p_trx_header_tbl(i).DEFAULT_TAXATION_COUNTRY := hdr_rec.default_taxation_country;
        FOR ln_rec in ln_cur(hdr_rec.trx_header_id) LOOP
         j :=j+1;
                             p_trx_lines_tbl(j).TRX_HEADER_ID	 :=ln_rec.TRX_HEADER_ID;
                     p_trx_lines_tbl(j).TRX_LINE_ID	 :=ln_rec.TRX_LINE_ID;
                     p_trx_lines_tbl(j).LINK_TO_TRX_LINE_ID	 :=ln_rec.LINK_TO_TRX_LINE_ID;
                     p_trx_lines_tbl(j).LINE_NUMBER	 :=ln_rec.LINE_NUMBER;
                     p_trx_lines_tbl(j).REASON_CODE	 :=ln_rec.REASON_CODE;
                     p_trx_lines_tbl(j).INVENTORY_ITEM_ID	 :=ln_rec.INVENTORY_ITEM_ID;
                     p_trx_lines_tbl(j).DESCRIPTION	 :=ln_rec.DESCRIPTION;
                     p_trx_lines_tbl(j).QUANTITY_ORDERED	 :=ln_rec.QUANTITY_ORDERED;
                     p_trx_lines_tbl(j).QUANTITY_INVOICED	 :=ln_rec.QUANTITY_INVOICED;
                     p_trx_lines_tbl(j).UNIT_STANDARD_PRICE	 :=ln_rec.UNIT_STANDARD_PRICE;
                     p_trx_lines_tbl(j).UNIT_SELLING_PRICE	 :=ln_rec.UNIT_SELLING_PRICE;
                     p_trx_lines_tbl(j).SALES_ORDER	 :=ln_rec.SALES_ORDER;
                     p_trx_lines_tbl(j).SALES_ORDER_LINE	 :=ln_rec.SALES_ORDER_LINE;
                     p_trx_lines_tbl(j).SALES_ORDER_DATE	 :=ln_rec.SALES_ORDER_DATE;
                     p_trx_lines_tbl(j).ACCOUNTING_RULE_ID	 :=ln_rec.ACCOUNTING_RULE_ID;
                     p_trx_lines_tbl(j).LINE_TYPE	 :=ln_rec.LINE_TYPE;
                     p_trx_lines_tbl(j).ATTRIBUTE_CATEGORY	 :=ln_rec.ATTRIBUTE_CATEGORY;
                     p_trx_lines_tbl(j).ATTRIBUTE1	 :=ln_rec.ATTRIBUTE1;
                     p_trx_lines_tbl(j).ATTRIBUTE2	 :=ln_rec.ATTRIBUTE2;
                     p_trx_lines_tbl(j).ATTRIBUTE3	 :=ln_rec.ATTRIBUTE3;
                     p_trx_lines_tbl(j).ATTRIBUTE4	 :=ln_rec.ATTRIBUTE4;
                     p_trx_lines_tbl(j).ATTRIBUTE5	 :=ln_rec.ATTRIBUTE5;
                     p_trx_lines_tbl(j).ATTRIBUTE6	 :=ln_rec.ATTRIBUTE6;
                     p_trx_lines_tbl(j).ATTRIBUTE7	 :=ln_rec.ATTRIBUTE7;
                     p_trx_lines_tbl(j).ATTRIBUTE8	 :=ln_rec.ATTRIBUTE8;
                     p_trx_lines_tbl(j).ATTRIBUTE9	 :=ln_rec.ATTRIBUTE9;
                     p_trx_lines_tbl(j).ATTRIBUTE10	 :=ln_rec.ATTRIBUTE10;
                     p_trx_lines_tbl(j).ATTRIBUTE11	 :=ln_rec.ATTRIBUTE11;
                     p_trx_lines_tbl(j).ATTRIBUTE12	 :=ln_rec.ATTRIBUTE12;
                     p_trx_lines_tbl(j).ATTRIBUTE13	 :=ln_rec.ATTRIBUTE13;
                     p_trx_lines_tbl(j).ATTRIBUTE14	 :=ln_rec.ATTRIBUTE14;
                     p_trx_lines_tbl(j).ATTRIBUTE15	 :=ln_rec.ATTRIBUTE15;
                     p_trx_lines_tbl(j).RULE_START_DATE	 :=ln_rec.RULE_START_DATE;
                     p_trx_lines_tbl(j).INTERFACE_LINE_CONTEXT	 :=ln_rec.INTERFACE_LINE_CONTEXT;
                     p_trx_lines_tbl(j).INTERFACE_LINE_ATTRIBUTE1	 :=ln_rec.INTERFACE_LINE_ATTRIBUTE1;
                     p_trx_lines_tbl(j).INTERFACE_LINE_ATTRIBUTE2	 :=ln_rec.INTERFACE_LINE_ATTRIBUTE2;
                     p_trx_lines_tbl(j).INTERFACE_LINE_ATTRIBUTE3	 :=ln_rec.INTERFACE_LINE_ATTRIBUTE3;
                     p_trx_lines_tbl(j).INTERFACE_LINE_ATTRIBUTE4	 :=ln_rec.INTERFACE_LINE_ATTRIBUTE4;
                     p_trx_lines_tbl(j).INTERFACE_LINE_ATTRIBUTE5	 :=ln_rec.INTERFACE_LINE_ATTRIBUTE5;
                     p_trx_lines_tbl(j).INTERFACE_LINE_ATTRIBUTE6	 :=ln_rec.INTERFACE_LINE_ATTRIBUTE6;
                     p_trx_lines_tbl(j).INTERFACE_LINE_ATTRIBUTE7	 :=ln_rec.INTERFACE_LINE_ATTRIBUTE7;
                     p_trx_lines_tbl(j).INTERFACE_LINE_ATTRIBUTE8	 :=ln_rec.INTERFACE_LINE_ATTRIBUTE8;
                     p_trx_lines_tbl(j).INTERFACE_LINE_ATTRIBUTE9	 :=ln_rec.INTERFACE_LINE_ATTRIBUTE9;
                     p_trx_lines_tbl(j).INTERFACE_LINE_ATTRIBUTE10	 :=ln_rec.INTERFACE_LINE_ATTRIBUTE10;
                     p_trx_lines_tbl(j).INTERFACE_LINE_ATTRIBUTE11	 :=ln_rec.INTERFACE_LINE_ATTRIBUTE11;
                     p_trx_lines_tbl(j).INTERFACE_LINE_ATTRIBUTE12	 :=ln_rec.INTERFACE_LINE_ATTRIBUTE12;
                     p_trx_lines_tbl(j).INTERFACE_LINE_ATTRIBUTE13	 :=ln_rec.INTERFACE_LINE_ATTRIBUTE13;
                     p_trx_lines_tbl(j).INTERFACE_LINE_ATTRIBUTE14	 :=ln_rec.INTERFACE_LINE_ATTRIBUTE14;
                     p_trx_lines_tbl(j).INTERFACE_LINE_ATTRIBUTE15	 :=ln_rec.INTERFACE_LINE_ATTRIBUTE15;
                     p_trx_lines_tbl(j).SALES_ORDER_SOURCE	 :=ln_rec.SALES_ORDER_SOURCE;
                     p_trx_lines_tbl(j).AMOUNT	 :=ln_rec.AMOUNT;
                     p_trx_lines_tbl(j).TAX_PRECEDENCE	 :=ln_rec.TAX_PRECEDENCE;
                     p_trx_lines_tbl(j).TAX_RATE	 :=ln_rec.TAX_RATE;
                     p_trx_lines_tbl(j).TAX_EXEMPTION_ID	 :=ln_rec.TAX_EXEMPTION_ID;
                     p_trx_lines_tbl(j).MEMO_LINE_ID	 :=ln_rec.MEMO_LINE_ID;
                     p_trx_lines_tbl(j).UOM_CODE	 :=ln_rec.UOM_CODE;
                     p_trx_lines_tbl(j).DEFAULT_USSGL_TRANSACTION_CODE	 :=ln_rec.DEFAULT_USSGL_TRANSACTION_CODE;
                     p_trx_lines_tbl(j).DEFAULT_USSGL_TRX_CODE_CONTEXT	 :=ln_rec.DEFAULT_USSGL_TRX_CODE_CONTEXT;
                     p_trx_lines_tbl(j).VAT_TAX_ID	 :=ln_rec.VAT_TAX_ID;
                     p_trx_lines_tbl(j).TAX_EXEMPT_FLAG	 :=ln_rec.TAX_EXEMPT_FLAG;
                     p_trx_lines_tbl(j).TAX_EXEMPT_NUMBER	 :=ln_rec.TAX_EXEMPT_NUMBER;
                     p_trx_lines_tbl(j).TAX_EXEMPT_REASON_CODE	 :=ln_rec.TAX_EXEMPT_REASON_CODE;
                     p_trx_lines_tbl(j).TAX_VENDOR_RETURN_CODE	 :=ln_rec.TAX_VENDOR_RETURN_CODE;
                     p_trx_lines_tbl(j).MOVEMENT_ID	 :=ln_rec.MOVEMENT_ID;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE1	 :=ln_rec.GLOBAL_ATTRIBUTE1;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE2	 :=ln_rec.GLOBAL_ATTRIBUTE2;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE3	 :=ln_rec.GLOBAL_ATTRIBUTE3;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE4	 :=ln_rec.GLOBAL_ATTRIBUTE4;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE5	 :=ln_rec.GLOBAL_ATTRIBUTE5;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE6	 :=ln_rec.GLOBAL_ATTRIBUTE6;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE7	 :=ln_rec.GLOBAL_ATTRIBUTE7;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE8	 :=ln_rec.GLOBAL_ATTRIBUTE8;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE9	 :=ln_rec.GLOBAL_ATTRIBUTE9;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE10	 :=ln_rec.GLOBAL_ATTRIBUTE10;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE11	 :=ln_rec.GLOBAL_ATTRIBUTE11;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE12	 :=ln_rec.GLOBAL_ATTRIBUTE12;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE13	 :=ln_rec.GLOBAL_ATTRIBUTE13;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE14	 :=ln_rec.GLOBAL_ATTRIBUTE14;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE15	 :=ln_rec.GLOBAL_ATTRIBUTE15;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE16	 :=ln_rec.GLOBAL_ATTRIBUTE16;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE17	 :=ln_rec.GLOBAL_ATTRIBUTE17;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE18	 :=ln_rec.GLOBAL_ATTRIBUTE18;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE19	 :=ln_rec.GLOBAL_ATTRIBUTE19;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE20	 :=ln_rec.GLOBAL_ATTRIBUTE20;
                     p_trx_lines_tbl(j).GLOBAL_ATTRIBUTE_CATEGORY	 :=ln_rec.GLOBAL_ATTRIBUTE_CATEGORY;
                     p_trx_lines_tbl(j).AMOUNT_INCLUDES_TAX_FLAG	 :=ln_rec.AMOUNT_INCLUDES_TAX_FLAG;
                     p_trx_lines_tbl(j).WAREHOUSE_ID	 :=ln_rec.WAREHOUSE_ID;
                     p_trx_lines_tbl(j).CONTRACT_LINE_ID	 :=ln_rec.CONTRACT_LINE_ID;
                     p_trx_lines_tbl(j).SOURCE_DATA_KEY1	 :=ln_rec.SOURCE_DATA_KEY1;
                     p_trx_lines_tbl(j).SOURCE_DATA_KEY2	 :=ln_rec.SOURCE_DATA_KEY2;
                     p_trx_lines_tbl(j).SOURCE_DATA_KEY3	 :=ln_rec.SOURCE_DATA_KEY3;
                     p_trx_lines_tbl(j).SOURCE_DATA_KEY4	 :=ln_rec.SOURCE_DATA_KEY4;
                     p_trx_lines_tbl(j).SOURCE_DATA_KEY5	 :=ln_rec.SOURCE_DATA_KEY5;
                     p_trx_lines_tbl(j).INVOICED_LINE_ACCTG_LEVEL	 :=ln_rec.INVOICED_LINE_ACCTG_LEVEL;
                     p_trx_lines_tbl(j).SHIP_DATE_ACTUAL	 :=ln_rec.SHIP_DATE_ACTUAL;
                     p_trx_lines_tbl(j).RULE_END_DATE            :=ln_rec.RULE_END_DATE;
                     p_trx_lines_tbl(j).SOURCE_APPLICATION_ID    :=ln_rec.SOURCE_APPLICATION_ID;
                     p_trx_lines_tbl(j).SOURCE_EVENT_CLASS_CODE  :=ln_rec.SOURCE_EVENT_CLASS_CODE;
                     p_trx_lines_tbl(j).SOURCE_ENTITY_CODE       :=ln_rec.SOURCE_ENTITY_CODE;
                     p_trx_lines_tbl(j).SOURCE_TRX_ID            :=ln_rec.SOURCE_TRX_ID;
                     p_trx_lines_tbl(j).SOURCE_TRX_LINE_ID       :=ln_rec.SOURCE_TRX_LINE_ID;
                     p_trx_lines_tbl(j).SOURCE_TRX_LINE_TYPE     :=ln_rec.SOURCE_TRX_LINE_TYPE;
                     p_trx_lines_tbl(j).SOURCE_TRX_DETAIL_TAX_LINE_ID :=
                                                                   ln_rec.SOURCE_TRX_DETAIL_TAX_LINE_ID;
                     p_trx_lines_tbl(j).HISTORICAL_FLAG          :=ln_rec.HISTORICAL_FLAG;
                     p_trx_lines_tbl(j).TAXABLE_FLAG             :=ln_rec.TAXABLE_FLAG;
                     p_trx_lines_tbl(j).TAX_REGIME_CODE          :=ln_rec.TAX_REGIME_CODE;
                     p_trx_lines_tbl(j).TAX                      :=ln_rec.TAX;
                     p_trx_lines_tbl(j).TAX_STATUS_CODE          :=ln_rec.TAX_STATUS_CODE;
                     p_trx_lines_tbl(j).TAX_RATE_CODE            :=ln_rec.TAX_RATE_CODE;
                     p_trx_lines_tbl(j).TAX_JURISDICTION_CODE    :=ln_rec.TAX_JURISDICTION_CODE;
                     p_trx_lines_tbl(j).TAX_CLASSIFICATION_CODE  :=ln_rec.TAX_CLASSIFICATION_CODE;
                     --Late Charges
                     p_trx_lines_tbl(j).interest_line_id  :=ln_rec.interest_line_id;
                     p_trx_lines_tbl(j).trx_business_category := ln_rec.trx_business_category;
                     p_trx_lines_tbl(j).product_fisc_classification := ln_rec.product_fisc_classification;
                     p_trx_lines_tbl(j).product_category := ln_rec.product_category;
                     p_trx_lines_tbl(j).product_type := ln_rec.product_type;
                     p_trx_lines_tbl(j).line_intended_use := ln_rec.line_intended_use;
                     p_trx_lines_tbl(j).assessable_value := ln_rec.assessable_value;

          FOR dist_rec in  dist_cur(ln_rec.trx_line_id) LOOP
          -- put dist record
           k :=k+1;
                          p_trx_dist_tbl(k).TRX_DIST_ID	 :=dist_rec.TRX_DIST_ID;
                          p_trx_dist_tbl(k).TRX_HEADER_ID	 :=dist_rec.TRX_HEADER_ID;
                          p_trx_dist_tbl(k).TRX_LINE_ID	 :=dist_rec.TRX_LINE_ID;
                          p_trx_dist_tbl(k).ACCOUNT_CLASS	 :=dist_rec.ACCOUNT_CLASS;
                          p_trx_dist_tbl(k).AMOUNT	 :=dist_rec.AMOUNT;
                          p_trx_dist_tbl(k).ACCTD_AMOUNT	 :=dist_rec.ACCTD_AMOUNT;
                          p_trx_dist_tbl(k).PERCENT	 :=dist_rec.PERCENT;
                          p_trx_dist_tbl(k).CODE_COMBINATION_ID	 :=dist_rec.CODE_COMBINATION_ID;
                          p_trx_dist_tbl(k).ATTRIBUTE_CATEGORY	 :=dist_rec.ATTRIBUTE_CATEGORY;
                          p_trx_dist_tbl(k).ATTRIBUTE1	 :=dist_rec.ATTRIBUTE1;
                          p_trx_dist_tbl(k).ATTRIBUTE2	 :=dist_rec.ATTRIBUTE2;
                          p_trx_dist_tbl(k).ATTRIBUTE3	 :=dist_rec.ATTRIBUTE3;
                          p_trx_dist_tbl(k).ATTRIBUTE4	 :=dist_rec.ATTRIBUTE4;
                          p_trx_dist_tbl(k).ATTRIBUTE5	 :=dist_rec.ATTRIBUTE5;
                          p_trx_dist_tbl(k).ATTRIBUTE6	 :=dist_rec.ATTRIBUTE6;
                          p_trx_dist_tbl(k).ATTRIBUTE7	 :=dist_rec.ATTRIBUTE7;
                          p_trx_dist_tbl(k).ATTRIBUTE8	 :=dist_rec.ATTRIBUTE8;
                          p_trx_dist_tbl(k).ATTRIBUTE9	 :=dist_rec.ATTRIBUTE9;
                          p_trx_dist_tbl(k).ATTRIBUTE10	 :=dist_rec.ATTRIBUTE10;
                          p_trx_dist_tbl(k).ATTRIBUTE11	 :=dist_rec.ATTRIBUTE11;
                          p_trx_dist_tbl(k).ATTRIBUTE12	 :=dist_rec.ATTRIBUTE12;
                          p_trx_dist_tbl(k).ATTRIBUTE13	 :=dist_rec.ATTRIBUTE13;
                          p_trx_dist_tbl(k).ATTRIBUTE14	 :=dist_rec.ATTRIBUTE14;
                          p_trx_dist_tbl(k).ATTRIBUTE15	 :=dist_rec.ATTRIBUTE15;
                          p_trx_dist_tbl(k).COMMENTS	 :=dist_rec.COMMENTS;

          END LOOP;

          FOR sc_rec in sc_cur(ln_rec.trx_header_id,ln_rec.trx_line_id) LOOP
             --put SC record
             l:=l+1;
                   p_trx_salescredits_tbl(l).TRX_SALESCREDIT_ID	 :=sc_rec.TRX_SALESCREDIT_ID;
                   p_trx_salescredits_tbl(l).TRX_LINE_ID	 :=sc_rec.TRX_LINE_ID;
                   p_trx_salescredits_tbl(l).SALESREP_ID	 :=sc_rec.SALESREP_ID;
                   p_trx_salescredits_tbl(l).SALESREP_NUMBER	 :=sc_rec.SALESREP_NUMBER;
                   p_trx_salescredits_tbl(l).SALES_CREDIT_TYPE_NAME	 :=sc_rec.SALES_CREDIT_TYPE_NAME;
                   p_trx_salescredits_tbl(l).SALES_CREDIT_TYPE_ID	 :=sc_rec.SALES_CREDIT_TYPE_ID;
                   p_trx_salescredits_tbl(l).SALESCREDIT_AMOUNT_SPLIT	 :=sc_rec.SALESCREDIT_AMOUNT_SPLIT;
                   p_trx_salescredits_tbl(l).SALESCREDIT_PERCENT_SPLIT	 :=sc_rec.SALESCREDIT_PERCENT_SPLIT;
                   p_trx_salescredits_tbl(l).ATTRIBUTE_CATEGORY	 :=sc_rec.ATTRIBUTE_CATEGORY;
                   p_trx_salescredits_tbl(l).ATTRIBUTE1	 :=sc_rec.ATTRIBUTE1;
                   p_trx_salescredits_tbl(l).ATTRIBUTE2	 :=sc_rec.ATTRIBUTE2;
                   p_trx_salescredits_tbl(l).ATTRIBUTE3	 :=sc_rec.ATTRIBUTE3;
                   p_trx_salescredits_tbl(l).ATTRIBUTE4	 :=sc_rec.ATTRIBUTE4;
                   p_trx_salescredits_tbl(l).ATTRIBUTE5	 :=sc_rec.ATTRIBUTE5;
                   p_trx_salescredits_tbl(l).ATTRIBUTE6	 :=sc_rec.ATTRIBUTE6;
                   p_trx_salescredits_tbl(l).ATTRIBUTE7	 :=sc_rec.ATTRIBUTE7;
                   p_trx_salescredits_tbl(l).ATTRIBUTE8	 :=sc_rec.ATTRIBUTE8;
                   p_trx_salescredits_tbl(l).ATTRIBUTE9	 :=sc_rec.ATTRIBUTE9;
                   p_trx_salescredits_tbl(l).ATTRIBUTE10	 :=sc_rec.ATTRIBUTE10;
                   p_trx_salescredits_tbl(l).ATTRIBUTE11	 :=sc_rec.ATTRIBUTE11;
                   p_trx_salescredits_tbl(l).ATTRIBUTE12	 :=sc_rec.ATTRIBUTE12;
                   p_trx_salescredits_tbl(l).ATTRIBUTE13	 :=sc_rec.ATTRIBUTE13;
                   p_trx_salescredits_tbl(l).ATTRIBUTE14	 :=sc_rec.ATTRIBUTE14;
                   p_trx_salescredits_tbl(l).ATTRIBUTE15	 :=sc_rec.ATTRIBUTE15;

          END LOOP;
        END LOOP;

         /* 4652982 - Insert header dist rows
             NOTE:  We use same index as prev dist insert so
             our records are consecutive in the table for
             future bulk reads. */
         FOR dist_rec in  dist_rec_cur(hdr_rec.trx_header_id) LOOP
           k := k + 1;
                          p_trx_dist_tbl(k).TRX_DIST_ID	 :=dist_rec.TRX_DIST_ID;
                          p_trx_dist_tbl(k).TRX_HEADER_ID	 :=dist_rec.TRX_HEADER_ID;
                          p_trx_dist_tbl(k).TRX_LINE_ID	 :=dist_rec.TRX_LINE_ID;
                          p_trx_dist_tbl(k).ACCOUNT_CLASS	 :=dist_rec.ACCOUNT_CLASS;
                          p_trx_dist_tbl(k).AMOUNT	 :=dist_rec.AMOUNT;
                          p_trx_dist_tbl(k).ACCTD_AMOUNT	 :=dist_rec.ACCTD_AMOUNT;
                          p_trx_dist_tbl(k).PERCENT	 :=dist_rec.PERCENT;
                          p_trx_dist_tbl(k).CODE_COMBINATION_ID	 :=dist_rec.CODE_COMBINATION_ID;
                          p_trx_dist_tbl(k).ATTRIBUTE_CATEGORY	 :=dist_rec.ATTRIBUTE_CATEGORY;
                          p_trx_dist_tbl(k).ATTRIBUTE1	 :=dist_rec.ATTRIBUTE1;
                          p_trx_dist_tbl(k).ATTRIBUTE2	 :=dist_rec.ATTRIBUTE2;
                          p_trx_dist_tbl(k).ATTRIBUTE3	 :=dist_rec.ATTRIBUTE3;
                          p_trx_dist_tbl(k).ATTRIBUTE4	 :=dist_rec.ATTRIBUTE4;
                          p_trx_dist_tbl(k).ATTRIBUTE5	 :=dist_rec.ATTRIBUTE5;
                          p_trx_dist_tbl(k).ATTRIBUTE6	 :=dist_rec.ATTRIBUTE6;
                          p_trx_dist_tbl(k).ATTRIBUTE7	 :=dist_rec.ATTRIBUTE7;
                          p_trx_dist_tbl(k).ATTRIBUTE8	 :=dist_rec.ATTRIBUTE8;
                          p_trx_dist_tbl(k).ATTRIBUTE9	 :=dist_rec.ATTRIBUTE9;
                          p_trx_dist_tbl(k).ATTRIBUTE10	 :=dist_rec.ATTRIBUTE10;
                          p_trx_dist_tbl(k).ATTRIBUTE11	 :=dist_rec.ATTRIBUTE11;
                          p_trx_dist_tbl(k).ATTRIBUTE12	 :=dist_rec.ATTRIBUTE12;
                          p_trx_dist_tbl(k).ATTRIBUTE13	 :=dist_rec.ATTRIBUTE13;
                          p_trx_dist_tbl(k).ATTRIBUTE14	 :=dist_rec.ATTRIBUTE14;
                          p_trx_dist_tbl(k).ATTRIBUTE15	 :=dist_rec.ATTRIBUTE15;
                          p_trx_dist_tbl(k).COMMENTS	 :=dist_rec.COMMENTS;

         END LOOP; -- end of hdr rec/round dist insert

       END LOOP;

EXCEPTION
       WHEN OTHERS THEN
       x_errmsg := 'Error in AR_TRX_GLOBAL_PROCESS_TMP.GET_ROWS '||sqlerrm;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RETURN;

END GET_ROWS;

END AR_TRX_GLOBAL_PROCESS_TMP;

/
