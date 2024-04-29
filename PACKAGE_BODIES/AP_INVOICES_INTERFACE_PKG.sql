--------------------------------------------------------
--  DDL for Package Body AP_INVOICES_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_INVOICES_INTERFACE_PKG" as
 /* $Header: apaiithb.pls 120.11.12010000.2 2008/11/20 14:12:01 dcshanmu ship $ */

procedure INSERT_ROW (
          X_ROWID                        IN OUT NOCOPY VARCHAR2,
          X_INVOICE_ID                   IN            NUMBER,
          X_INVOICE_NUM                  IN            VARCHAR2,
          X_INVOICE_TYPE_LOOKUP_CODE     IN            VARCHAR2,
          X_INVOICE_DATE                 IN            DATE,
          X_PO_NUMBER                    IN            VARCHAR2,
          X_VENDOR_ID                    IN            NUMBER,
          X_VENDOR_SITE_ID               IN            NUMBER,
          X_INVOICE_AMOUNT               IN            NUMBER,
          X_INVOICE_CURRENCY_CODE        IN            VARCHAR2,
          X_PAYMENT_CURRENCY_CODE        IN            VARCHAR2,
          X_PAYMENT_CROSS_RATE           IN            NUMBER,
          X_PAYMENT_CROSS_RATE_TYPE      IN            VARCHAR2,
          X_PAYMENT_CROSS_RATE_DATE      IN            DATE,
          X_EXCHANGE_RATE                IN            NUMBER,
          X_EXCHANGE_RATE_TYPE           IN            VARCHAR2,
          X_EXCHANGE_DATE                IN            DATE,
          X_TERMS_ID                     IN            NUMBER,
          X_DESCRIPTION                  IN            VARCHAR2,
          X_AWT_GROUP_ID                 IN            NUMBER,
          X_PAY_AWT_GROUP_ID             IN            NUMBER DEFAULT NULL,--bug6639866
          X_AMT_APPLICABLE_TO_DISCOUNT   IN            NUMBER,
          X_ATTRIBUTE_CATEGORY           IN            VARCHAR2,
          X_ATTRIBUTE1                   IN            VARCHAR2,
          X_ATTRIBUTE2                   IN            VARCHAR2,
          X_ATTRIBUTE3                   IN            VARCHAR2,
          X_ATTRIBUTE4                   IN            VARCHAR2,
          X_ATTRIBUTE5                   IN            VARCHAR2,
          X_ATTRIBUTE6                   IN            VARCHAR2,
          X_ATTRIBUTE7                   IN            VARCHAR2,
          X_ATTRIBUTE8                   IN            VARCHAR2,
          X_ATTRIBUTE9                   IN            VARCHAR2,
          X_ATTRIBUTE10                  IN            VARCHAR2,
          X_ATTRIBUTE11                  IN            VARCHAR2,
          X_ATTRIBUTE12                  IN            VARCHAR2,
          X_ATTRIBUTE13                  IN            VARCHAR2,
          X_ATTRIBUTE14                  IN            VARCHAR2,
          X_ATTRIBUTE15                  IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE_CATEGORY    IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE1            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE2            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE3            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE4            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE5            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE6            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE7            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE8            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE9            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE10           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE11           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE12           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE13           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE14           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE15           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE16           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE17           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE18           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE19           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE20           IN            VARCHAR2,
          X_STATUS                       IN            VARCHAR2,
          X_SOURCE                       IN            VARCHAR2,
          X_GROUP_ID                     IN            VARCHAR2,
          X_WORKFLOW_FLAG                IN            VARCHAR2,
          X_DOC_CATEGORY_CODE            IN            VARCHAR2,
          X_VOUCHER_NUM                  IN            VARCHAR2,
          X_PAY_GROUP_LOOKUP_CODE        IN            VARCHAR2,
          X_GOODS_RECEIVED_DATE          IN            DATE,
          X_INVOICE_RECEIVED_DATE        IN            DATE,
          X_GL_DATE                      IN            DATE,
          X_ACCTS_PAY_CCID               IN            NUMBER,
       -- X_USSGL_TRANSACTION_CODE       IN            VARCHAR2, - Bug 4277744
          X_EXCLUSIVE_PAYMENT_FLAG       IN            VARCHAR2,
          X_INVOICE_INCLUDES_PREPAY_FLAG IN            VARCHAR2,
          X_PREPAY_NUM                   IN            VARCHAR2,
          X_PREPAY_APPLY_AMOUNT          IN            NUMBER,
          X_PREPAY_GL_DATE               IN            DATE,
          X_CREATION_DATE                IN            DATE,
          X_CREATED_BY                   IN            NUMBER,
          X_LAST_UPDATE_DATE             IN            DATE,
          X_LAST_UPDATED_BY              IN            NUMBER,
          X_LAST_UPDATE_LOGIN            IN            NUMBER,
          X_ORG_ID                       IN            NUMBER,
          X_MODE                         IN            VARCHAR2 DEFAULT 'R',
          X_TERMS_DATE                   IN            DATE     DEFAULT NULL,
          X_REQUESTER_ID                 IN            NUMBER   DEFAULT NULL,
          X_OPERATING_UNIT               IN            VARCHAR2 DEFAULT NULL,
          -- Invoice LINes Project Stage 1
          X_PREPAY_LINE_NUM              IN            NUMBER   DEFAULT NULL,
          X_REQUESTER_FIRST_NAME         IN            VARCHAR2 DEFAULT NULL,
          X_REQUESTER_LAST_NAME          IN            VARCHAR2 DEFAULT NULL,
          X_REQUESTER_EMPLOYEE_NUM       IN            VARCHAR2 DEFAULT NULL,
	  -- eTax Uptake
	  X_CALC_TAX_DURING_IMPORT_FLAG  IN            VARCHAR2 DEFAULT NULL,
	  X_CONTROL_AMOUNT  		 IN            NUMBER   DEFAULT NULL,
	  X_ADD_TAX_TO_INV_AMT_FLAG	 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_RELATED_INVOICE_ID       IN            NUMBER   DEFAULT NULL,
	  X_TAXATION_COUNTRY             IN            VARCHAR2 DEFAULT NULL,
	  X_DOCUMENT_SUB_TYPE            IN            VARCHAR2 DEFAULT NULL,
	  X_SUPPLIER_TAX_INVOICE_NUMBER  IN            VARCHAR2 DEFAULT NULL,
	  X_SUPPLIER_TAX_INVOICE_DATE    IN            DATE     DEFAULT NULL,
          X_SUPPLIER_TAX_EXCHANGE_RATE   IN            NUMBER   DEFAULT NULL,
	  X_TAX_INVOICE_RECORDING_DATE   IN            DATE     DEFAULT NULL,
	  X_TAX_INVOICE_INTERNAL_SEQ	 IN            VARCHAR2 DEFAULT NULL,
	  X_LEGAL_ENTITY_ID		 IN            NUMBER   DEFAULT NULL,
          x_PAYMENT_METHOD_CODE          in            varchar2 default null,
          x_PAYMENT_REASON_CODE          in            varchar2 default null,
          X_PAYMENT_REASON_COMMENTS      in            varchar2 default null,
          x_UNIQUE_REMITTANCE_IDENTIFIER in            varchar2 default null,
          x_URI_CHECK_DIGIT              in            varchar2 default null,
          x_BANK_CHARGE_BEARER           in            varchar2 default null,
          x_DELIVERY_CHANNEL_CODE        in            varchar2 default null,
          x_SETTLEMENT_PRIORITY          in            varchar2 default null,
          x_remittance_message1          in            varchar2 default null,
          x_remittance_message2          in            varchar2 default null,
          x_remittance_message3          in            varchar2 default null,
	  x_NET_OF_RETAINAGE_FLAG	 in	       varchar2 default null,
	  x_PORT_OF_ENTRY_CODE		 in	       varchar2 default null,
          X_APPLICATION_ID               IN            NUMBER   DEFAULT NULL,
          X_PRODUCT_TABLE                IN            VARCHAR2 DEFAULT NULL,
          X_REFERENCE_KEY1               IN            VARCHAR2 DEFAULT NULL,
          X_REFERENCE_KEY2               IN            VARCHAR2 DEFAULT NULL,
          X_REFERENCE_KEY3               IN            VARCHAR2 DEFAULT NULL,
          X_REFERENCE_KEY4               IN            VARCHAR2 DEFAULT NULL,
          X_REFERENCE_KEY5               IN            VARCHAR2 DEFAULT NULL,
          X_PARTY_ID                     IN            NUMBER   DEFAULT NULL,
          X_PARTY_SITE_ID                IN            NUMBER   DEFAULT NULL,
          X_PAY_PROC_TRXN_TYPE_CODE      IN            VARCHAR2 DEFAULT NULL,
          X_PAYMENT_FUNCTION             IN            VARCHAR2 DEFAULT NULL,
          X_PAYMENT_PRIORITY             IN            NUMBER   DEFAULT NULL,
          x_external_bank_account_id     in            number   default null,
	  X_REMIT_TO_SUPPLIER_NAME	IN	VARCHAR2 DEFAULT NULL,
	  X_REMIT_TO_SUPPLIER_ID	IN	NUMBER DEFAULT NULL,
	  X_REMIT_TO_SUPPLIER_SITE	IN	VARCHAR2 DEFAULT NULL,
	  X_REMIT_TO_SUPPLIER_SITE_ID	IN	NUMBER DEFAULT NULL,
	  X_RELATIONSHIP_ID	IN	NUMBER DEFAULT NULL
)
  IS
  CURSOR C IS
  SELECT ROWID
    FROM AP_INVOICES_INTERFACE
   WHERE INVOICE_ID = X_INVOICE_ID;
BEGIN
  INSERT INTO AP_INVOICES_INTERFACE (
          INVOICE_ID,
          INVOICE_NUM,
          INVOICE_TYPE_LOOKUP_CODE,
          INVOICE_DATE,
          PO_NUMBER,
          VENDOR_ID,
          VENDOR_SITE_ID,
          INVOICE_AMOUNT,
          INVOICE_CURRENCY_CODE,
          PAYMENT_CURRENCY_CODE,
          PAYMENT_CROSS_RATE,
          PAYMENT_CROSS_RATE_TYPE,
          PAYMENT_CROSS_RATE_DATE,
          EXCHANGE_RATE,
          EXCHANGE_RATE_TYPE,
          EXCHANGE_DATE,
          TERMS_ID,
          DESCRIPTION,
          AWT_GROUP_ID,
          PAY_AWT_GROUP_ID,--bug6639866
          AMOUNT_APPLICABLE_TO_DISCOUNT,
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
          STATUS,
          SOURCE,
          GROUP_ID,
          WORKFLOW_FLAG,
          DOC_CATEGORY_CODE,
          VOUCHER_NUM,
          PAY_GROUP_LOOKUP_CODE,
          GOODS_RECEIVED_DATE,
          INVOICE_RECEIVED_DATE,
          GL_DATE ,
          ACCTS_PAY_CODE_COMBINATION_ID ,
       -- USSGL_TRANSACTION_CODE , - Bug 4277744
          EXCLUSIVE_PAYMENT_FLAG,
          INVOICE_INCLUDES_PREPAY_FLAG ,
          PREPAY_NUM,
          PREPAY_APPLY_AMOUNT,
          PREPAY_GL_DATE,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          ORG_ID,
          TERMS_DATE ,
          REQUESTER_ID,
          OPERATING_UNIT,
          -- Invoice Lines Project Stage 1
          PREPAY_LINE_NUM,
          REQUESTER_FIRST_NAME,
          REQUESTER_LAST_NAME,
          REQUESTER_EMPLOYEE_NUM,
	  -- eTax Uptake
	  CALC_TAX_DURING_IMPORT_FLAG,
	  CONTROL_AMOUNT,
	  ADD_TAX_TO_INV_AMT_FLAG,
	  TAX_RELATED_INVOICE_ID,
	  TAXATION_COUNTRY,
	  DOCUMENT_SUB_TYPE,
	  SUPPLIER_TAX_INVOICE_NUMBER,
	  SUPPLIER_TAX_INVOICE_DATE,
	  SUPPLIER_TAX_EXCHANGE_RATE,
	  TAX_INVOICE_RECORDING_DATE,
	  TAX_INVOICE_INTERNAL_SEQ,
	  LEGAL_ENTITY_ID,
          PAYMENT_METHOD_CODE,
          PAYMENT_REASON_CODE,
          PAYMENT_REASON_COMMENTS,
          UNIQUE_REMITTANCE_IDENTIFIER,
          URI_CHECK_DIGIT,
          BANK_CHARGE_BEARER,
          DELIVERY_CHANNEL_CODE,
          SETTLEMENT_PRIORITY,
          REMITTANCE_MESSAGE1,
          REMITTANCE_MESSAGE2,
          REMITTANCE_MESSAGE3,
	  NET_OF_RETAINAGE_FLAG,
	  PORT_OF_ENTRY_CODE,
          APPLICATION_ID,
          PRODUCT_TABLE,
          REFERENCE_KEY1,
          REFERENCE_KEY2,
          REFERENCE_KEY3,
          REFERENCE_KEY4,
          REFERENCE_KEY5,
          PARTY_ID,
          PARTY_SITE_ID,
          PAY_PROC_TRXN_TYPE_CODE,
          PAYMENT_FUNCTION,
          PAYMENT_PRIORITY,
          external_bank_account_id,
	  REMIT_TO_SUPPLIER_NAME,
	  REMIT_TO_SUPPLIER_ID,
	  REMIT_TO_SUPPLIER_SITE,
	  REMIT_TO_SUPPLIER_SITE_ID,
	  RELATIONSHIP_ID
	  )
VALUES (
          X_INVOICE_ID,
          X_INVOICE_NUM,
          X_INVOICE_TYPE_LOOKUP_CODE,
          X_INVOICE_DATE,
          X_PO_NUMBER,
          X_VENDOR_ID,
          X_VENDOR_SITE_ID,
          X_INVOICE_AMOUNT,
          X_INVOICE_CURRENCY_CODE,
          X_PAYMENT_CURRENCY_CODE,
          X_PAYMENT_CROSS_RATE,
          X_PAYMENT_CROSS_RATE_TYPE,
          X_PAYMENT_CROSS_RATE_DATE,
          X_EXCHANGE_RATE,
          X_EXCHANGE_RATE_TYPE,
          X_EXCHANGE_DATE,
          X_TERMS_ID,
          X_DESCRIPTION,
          X_AWT_GROUP_ID,
          X_PAY_AWT_GROUP_ID,  --bug6639866
          X_AMT_APPLICABLE_TO_DISCOUNT,
          X_ATTRIBUTE_CATEGORY,
          X_ATTRIBUTE1,
          X_ATTRIBUTE2,
          X_ATTRIBUTE3,
          X_ATTRIBUTE4,
          X_ATTRIBUTE5,
          X_ATTRIBUTE6,
          X_ATTRIBUTE7,
          X_ATTRIBUTE8,
          X_ATTRIBUTE9,
          X_ATTRIBUTE10,
          X_ATTRIBUTE11,
          X_ATTRIBUTE12,
          X_ATTRIBUTE13,
          X_ATTRIBUTE14,
          X_ATTRIBUTE15,
          X_GLOBAL_ATTRIBUTE_CATEGORY,
          X_GLOBAL_ATTRIBUTE1,
          X_GLOBAL_ATTRIBUTE2,
          X_GLOBAL_ATTRIBUTE3,
          X_GLOBAL_ATTRIBUTE4,
          X_GLOBAL_ATTRIBUTE5,
          X_GLOBAL_ATTRIBUTE6,
          X_GLOBAL_ATTRIBUTE7,
          X_GLOBAL_ATTRIBUTE8,
          X_GLOBAL_ATTRIBUTE9,
          X_GLOBAL_ATTRIBUTE10,
          X_GLOBAL_ATTRIBUTE11,
          X_GLOBAL_ATTRIBUTE12,
          X_GLOBAL_ATTRIBUTE13,
          X_GLOBAL_ATTRIBUTE14,
          X_GLOBAL_ATTRIBUTE15,
          X_GLOBAL_ATTRIBUTE16,
          X_GLOBAL_ATTRIBUTE17,
          X_GLOBAL_ATTRIBUTE18,
          X_GLOBAL_ATTRIBUTE19,
          X_GLOBAL_ATTRIBUTE20,
          X_STATUS,
          X_SOURCE,
          X_GROUP_ID,
          X_WORKFLOW_FLAG,
          X_DOC_CATEGORY_CODE,
          X_VOUCHER_NUM,
          X_PAY_GROUP_LOOKUP_CODE,
          X_GOODS_RECEIVED_DATE,
          X_INVOICE_RECEIVED_DATE,
          X_GL_DATE ,
          X_ACCTS_PAY_CCID ,
       -- X_USSGL_TRANSACTION_CODE , - Bug 4277744
          X_EXCLUSIVE_PAYMENT_FLAG ,
          X_INVOICE_INCLUDES_PREPAY_FLAG ,
          X_PREPAY_NUM,
          X_PREPAY_APPLY_AMOUNT,
          X_PREPAY_GL_DATE,
          X_Creation_Date,
          X_Created_By,
          X_LAST_UPDATE_DATE,
          X_LAST_UPDATED_BY,
          X_LAST_UPDATE_LOGIN,
          X_ORG_ID,
          X_TERMS_DATE,
          X_REQUESTER_ID,
          X_OPERATING_UNIT,
          -- Invoice Lines Project Stage 1
          X_PREPAY_LINE_NUM,
          X_REQUESTER_FIRST_NAME,
          X_REQUESTER_LAST_NAME,
          X_REQUESTER_EMPLOYEE_NUM,
	  -- eTax Uptake
	  X_CALC_TAX_DURING_IMPORT_FLAG,
	  X_CONTROL_AMOUNT,
	  X_ADD_TAX_TO_INV_AMT_FLAG,
	  X_TAX_RELATED_INVOICE_ID,
	  X_TAXATION_COUNTRY,
	  X_DOCUMENT_SUB_TYPE,
	  X_SUPPLIER_TAX_INVOICE_NUMBER,
	  X_SUPPLIER_TAX_INVOICE_DATE,
	  X_SUPPLIER_TAX_EXCHANGE_RATE,
	  X_TAX_INVOICE_RECORDING_DATE,
	  X_TAX_INVOICE_INTERNAL_SEQ,
	  X_LEGAL_ENTITY_ID,
          x_PAYMENT_METHOD_CODE,
          x_PAYMENT_REASON_CODE,
          X_PAYMENT_REASON_COMMENTS,
          x_UNIQUE_REMITTANCE_IDENTIFIER,
          x_URI_CHECK_DIGIT,
          x_BANK_CHARGE_BEARER,
          x_DELIVERY_CHANNEL_CODE,
          x_SETTLEMENT_PRIORITY,
          X_REMITTANCE_MESSAGE1,
          X_REMITTANCE_MESSAGE2,
          X_REMITTANCE_MESSAGE3,
	  x_NET_OF_RETAINAGE_FLAG,
	  x_PORT_OF_ENTRY_CODE,
          X_APPLICATION_ID,
          X_PRODUCT_TABLE,
          X_REFERENCE_KEY1,
          X_REFERENCE_KEY2,
          X_REFERENCE_KEY3,
          X_REFERENCE_KEY4,
          X_REFERENCE_KEY5,
          X_PARTY_ID,
          X_PARTY_SITE_ID,
          X_PAY_PROC_TRXN_TYPE_CODE,
          X_PAYMENT_FUNCTION,
          X_PAYMENT_PRIORITY,
          x_external_bank_account_id,
	  X_REMIT_TO_SUPPLIER_NAME,
	  X_REMIT_TO_SUPPLIER_ID,
	  X_REMIT_TO_SUPPLIER_SITE,
	  X_REMIT_TO_SUPPLIER_SITE_ID,
	  X_RELATIONSHIP_ID);

  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%notfound) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;


procedure LOCK_ROW (
          X_INVOICE_ID                   IN            NUMBER,
          X_INVOICE_NUM                  IN            VARCHAR2,
          X_INVOICE_TYPE_LOOKUP_CODE     IN            VARCHAR2,
          X_INVOICE_DATE                 IN            DATE,
          X_PO_NUMBER                    IN            VARCHAR2,
          X_VENDOR_ID                    IN            NUMBER,
          X_VENDOR_SITE_ID               IN            NUMBER,
          X_INVOICE_AMOUNT               IN            NUMBER,
          X_INVOICE_CURRENCY_CODE        IN            VARCHAR2,
          X_PAYMENT_CURRENCY_CODE        IN            VARCHAR2,
          X_PAYMENT_CROSS_RATE           IN            NUMBER,
          X_PAYMENT_CROSS_RATE_TYPE      IN            VARCHAR2,
          X_PAYMENT_CROSS_RATE_DATE      IN            DATE,
          X_EXCHANGE_RATE                IN            NUMBER,
          X_EXCHANGE_RATE_TYPE           IN            VARCHAR2,
          X_EXCHANGE_DATE                IN            DATE,
          X_TERMS_ID                     IN            NUMBER,
          X_DESCRIPTION                  IN            VARCHAR2,
          X_AWT_GROUP_ID                 IN            NUMBER,
          X_PAY_AWT_GROUP_ID             IN            NUMBER DEFAULT NULL,--bug6639866
          X_AMT_APPLICABLE_TO_DISCOUNT   IN            NUMBER,
          X_ATTRIBUTE_CATEGORY           IN            VARCHAR2,
          X_ATTRIBUTE1                   IN            VARCHAR2,
          X_ATTRIBUTE2                   IN            VARCHAR2,
          X_ATTRIBUTE3                   IN            VARCHAR2,
          X_ATTRIBUTE4                   IN            VARCHAR2,
          X_ATTRIBUTE5                   IN            VARCHAR2,
          X_ATTRIBUTE6                   IN            VARCHAR2,
          X_ATTRIBUTE7                   IN            VARCHAR2,
          X_ATTRIBUTE8                   IN            VARCHAR2,
          X_ATTRIBUTE9                   IN            VARCHAR2,
          X_ATTRIBUTE10                  IN            VARCHAR2,
          X_ATTRIBUTE11                  IN            VARCHAR2,
          X_ATTRIBUTE12                  IN            VARCHAR2,
          X_ATTRIBUTE13                  IN            VARCHAR2,
          X_ATTRIBUTE14                  IN            VARCHAR2,
          X_ATTRIBUTE15                  IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE_CATEGORY    IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE1            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE2            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE3            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE4            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE5            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE6            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE7            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE8            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE9            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE10           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE11           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE12           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE13           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE14           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE15           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE16           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE17           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE18           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE19           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE20           IN            VARCHAR2,
          X_STATUS                       IN            VARCHAR2,
          X_SOURCE                       IN            VARCHAR2,
          X_GROUP_ID                     IN            VARCHAR2,
          X_WORKFLOW_FLAG                IN            VARCHAR2,
          X_DOC_CATEGORY_CODE            IN            VARCHAR2,
          X_VOUCHER_NUM                  IN            VARCHAR2,
          X_PAY_GROUP_LOOKUP_CODE        IN            VARCHAR2,
          X_GOODS_RECEIVED_DATE          IN            DATE,
          X_INVOICE_RECEIVED_DATE        IN            DATE,
          X_GL_DATE                      IN            DATE,
          X_ACCTS_PAY_CCID               IN            NUMBER,
       -- X_USSGL_TRANSACTION_CODE       IN            VARCHAR2, - Bug 4277744
          X_EXCLUSIVE_PAYMENT_FLAG       IN            VARCHAR2,
          X_INVOICE_INCLUDES_PREPAY_FLAG IN            VARCHAR2,
          X_PREPAY_NUM                   IN            VARCHAR2,
          X_PREPAY_APPLY_AMOUNT          IN            NUMBER,
          X_PREPAY_GL_DATE               IN            DATE,
          X_TERMS_DATE                   IN            DATE     DEFAULT NULL,
          X_REQUESTER_ID                 IN            NUMBER   DEFAULT NULL,
          X_OPERATING_UNIT               IN            VARCHAR2 DEFAULT NULL,
          -- Invoice LINes Project Stage 1
          X_PREPAY_LINE_NUM              IN            NUMBER   DEFAULT NULL,
          X_REQUESTER_FIRST_NAME         IN            VARCHAR2 DEFAULT NULL,
          X_REQUESTER_LAST_NAME          IN            VARCHAR2 DEFAULT NULL,
          X_REQUESTER_EMPLOYEE_NUM       IN            VARCHAR2 DEFAULT NULL,
	  -- eTax Uptake
	  X_CALC_TAX_DURING_IMPORT_FLAG  IN            VARCHAR2 DEFAULT NULL,
	  X_CONTROL_AMOUNT  		 IN            NUMBER   DEFAULT NULL,
	  X_ADD_TAX_TO_INV_AMT_FLAG	 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_RELATED_INVOICE_ID       IN            NUMBER   DEFAULT NULL,
	  X_TAXATION_COUNTRY             IN            VARCHAR2 DEFAULT NULL,
	  X_DOCUMENT_SUB_TYPE            IN            VARCHAR2 DEFAULT NULL,
	  X_SUPPLIER_TAX_INVOICE_NUMBER  IN            VARCHAR2 DEFAULT NULL,
	  X_SUPPLIER_TAX_INVOICE_DATE    IN            DATE     DEFAULT NULL,
          X_SUPPLIER_TAX_EXCHANGE_RATE   IN            NUMBER   DEFAULT NULL,
	  X_TAX_INVOICE_RECORDING_DATE   IN            DATE     DEFAULT NULL,
	  X_TAX_INVOICE_INTERNAL_SEQ	 IN            VARCHAR2 DEFAULT NULL,
	  X_LEGAL_ENTITY_ID		 IN            NUMBER   DEFAULT NULL,
          x_PAYMENT_METHOD_CODE          in            varchar2 default null,
          x_PAYMENT_REASON_CODE          in            varchar2 default null,
          X_PAYMENT_REASON_COMMENTS      in            varchar2 default null,
          x_UNIQUE_REMITTANCE_IDENTIFIER in            varchar2 default null,
          x_URI_CHECK_DIGIT              in            varchar2 default null,
          x_BANK_CHARGE_BEARER           in            varchar2 default null,
          x_DELIVERY_CHANNEL_CODE        in            varchar2 default null,
          x_SETTLEMENT_PRIORITY          in            varchar2 default null,
          x_remittance_message1          in            varchar2 default null,
          x_remittance_message2          in            varchar2 default null,
          x_remittance_message3          in            varchar2 default null,
	  x_NET_OF_RETAINAGE_FLAG	 in	       varchar2 default null,
	  x_PORT_OF_ENTRY_CODE		 in	       varchar2 default null,
          X_APPLICATION_ID               IN            NUMBER   DEFAULT NULL,
          X_PRODUCT_TABLE                IN            VARCHAR2 DEFAULT NULL,
          X_REFERENCE_KEY1               IN            VARCHAR2 DEFAULT NULL,
          X_REFERENCE_KEY2               IN            VARCHAR2 DEFAULT NULL,
          X_REFERENCE_KEY3               IN            VARCHAR2 DEFAULT NULL,
          X_REFERENCE_KEY4               IN            VARCHAR2 DEFAULT NULL,
          X_REFERENCE_KEY5               IN            VARCHAR2 DEFAULT NULL,
          X_PARTY_ID                     IN            NUMBER   DEFAULT NULL,
          X_PARTY_SITE_ID                IN            NUMBER   DEFAULT NULL,
          X_PAY_PROC_TRXN_TYPE_CODE      IN            VARCHAR2 DEFAULT NULL,
          X_PAYMENT_FUNCTION             IN            VARCHAR2 DEFAULT NULL,
          X_PAYMENT_PRIORITY             IN            NUMBER   DEFAULT NULL,
          x_external_bank_account_id     in            number   default null,
	  X_REMIT_TO_SUPPLIER_NAME	IN	VARCHAR2 DEFAULT NULL,
	  X_REMIT_TO_SUPPLIER_ID	IN	NUMBER DEFAULT NULL,
	  X_REMIT_TO_SUPPLIER_SITE	IN	VARCHAR2 DEFAULT NULL,
	  X_REMIT_TO_SUPPLIER_SITE_ID	IN	NUMBER DEFAULT NULL,
	  X_RELATIONSHIP_ID	IN	NUMBER DEFAULT NULL)

  IS
  CURSOR c1 IS SELECT
          INVOICE_NUM,
          INVOICE_TYPE_LOOKUP_CODE,
          INVOICE_DATE,
          PO_NUMBER,
          VENDOR_ID,
          VENDOR_SITE_ID,
          INVOICE_AMOUNT,
          INVOICE_CURRENCY_CODE,
          PAYMENT_CURRENCY_CODE,
          PAYMENT_CROSS_RATE,
          PAYMENT_CROSS_RATE_TYPE,
          PAYMENT_CROSS_RATE_DATE,
          EXCHANGE_RATE,
          EXCHANGE_RATE_TYPE,
          EXCHANGE_DATE,
          TERMS_ID,
          DESCRIPTION,
          AWT_GROUP_ID,
          PAY_AWT_GROUP_ID, --bug6639866
          AMOUNT_APPLICABLE_TO_DISCOUNT,
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
          STATUS,
          SOURCE,
          GROUP_ID,
          WORKFLOW_FLAG,
          DOC_CATEGORY_CODE,
          VOUCHER_NUM,
          PAY_GROUP_LOOKUP_CODE,
          GOODS_RECEIVED_DATE,
          INVOICE_RECEIVED_DATE,
          GL_DATE ,
          ACCTS_PAY_CODE_COMBINATION_ID ,
       -- USSGL_TRANSACTION_CODE , - Bug 4277744
          EXCLUSIVE_PAYMENT_FLAG,
          INVOICE_INCLUDES_PREPAY_FLAG,
          PREPAY_NUM,
          PREPAY_APPLY_AMOUNT,
          PREPAY_GL_DATE,
          TERMS_DATE ,
          REQUESTER_ID,
          OPERATING_UNIT,
          -- Invoice Lines Project Stage 1
          PREPAY_LINE_NUM,
          REQUESTER_FIRST_NAME,
          REQUESTER_LAST_NAME,
          REQUESTER_EMPLOYEE_NUM,
	  -- eTax Uptake
	  CALC_TAX_DURING_IMPORT_FLAG,
	  CONTROL_AMOUNT,
	  ADD_TAX_TO_INV_AMT_FLAG,
	  TAX_RELATED_INVOICE_ID,
	  TAXATION_COUNTRY,
	  DOCUMENT_SUB_TYPE,
	  SUPPLIER_TAX_INVOICE_NUMBER,
	  SUPPLIER_TAX_INVOICE_DATE,
	  SUPPLIER_TAX_EXCHANGE_RATE,
	  TAX_INVOICE_RECORDING_DATE,
	  TAX_INVOICE_INTERNAL_SEQ,
	  LEGAL_ENTITY_ID,
          PAYMENT_METHOD_CODE,
          PAYMENT_REASON_CODE,
          PAYMENT_REASON_COMMENTS,
          UNIQUE_REMITTANCE_IDENTIFIER,
          URI_CHECK_DIGIT,
          BANK_CHARGE_BEARER,
          DELIVERY_CHANNEL_CODE,
          SETTLEMENT_PRIORITY,
          REMITTANCE_MESSAGE1,
          REMITTANCE_MESSAGE2,
          REMITTANCE_MESSAGE3,
	  NET_OF_RETAINAGE_FLAG,
	  PORT_OF_ENTRY_CODE,
          APPLICATION_ID,
          PRODUCT_TABLE,
          REFERENCE_KEY1,
          REFERENCE_KEY2,
          REFERENCE_KEY3,
          REFERENCE_KEY4,
          REFERENCE_KEY5,
          PARTY_ID,
          PARTY_SITE_ID,
          PAY_PROC_TRXN_TYPE_CODE,
          PAYMENT_FUNCTION,
          PAYMENT_PRIORITY,
          external_bank_account_id,
	  REMIT_TO_SUPPLIER_NAME,
	  REMIT_TO_SUPPLIER_ID,
	  REMIT_TO_SUPPLIER_SITE,
	  REMIT_TO_SUPPLIER_SITE_ID,
	  RELATIONSHIP_ID
    FROM  AP_INVOICES_INTERFACE
    WHERE INVOICE_ID = X_INVOICE_ID
    FOR UPDATE OF INVOICE_ID nowait;

  tlinfo c1%rowtype;

BEGIN
  OPEN c1;
  FETCH c1 INTO tlinfo;
  IF (c1%notfound) THEN
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
    close c1;
    RETURN;
  END IF;
  CLOSE c1;

  IF ( ((tlinfo.INVOICE_NUM = X_INVOICE_NUM)
           OR ((tlinfo.INVOICE_NUM is null)
               AND (X_INVOICE_NUM is null)))
      AND ((tlinfo.INVOICE_TYPE_LOOKUP_CODE = X_INVOICE_TYPE_LOOKUP_CODE)
           OR ((tlinfo.INVOICE_TYPE_LOOKUP_CODE is null)
               AND (X_INVOICE_TYPE_LOOKUP_CODE is null)))
      AND ((tlinfo.INVOICE_DATE = X_INVOICE_DATE)
           OR ((tlinfo.INVOICE_DATE is null)
               AND (X_INVOICE_DATE is null)))
      AND ((tlinfo.PO_NUMBER = X_PO_NUMBER)
           OR ((tlinfo.PO_NUMBER is null)
               AND (X_PO_NUMBER is null)))
      AND ((tlinfo.VENDOR_ID = X_VENDOR_ID)
           OR ((tlinfo.VENDOR_ID is null)
               AND (X_VENDOR_ID is null)))
      AND ((tlinfo.VENDOR_SITE_ID = X_VENDOR_SITE_ID)
           OR ((tlinfo.VENDOR_SITE_ID is null)
               AND (X_VENDOR_SITE_ID is null)))
      AND ((tlinfo.INVOICE_AMOUNT = X_INVOICE_AMOUNT)
           OR ((tlinfo.INVOICE_AMOUNT is null)
               AND (X_INVOICE_AMOUNT is null)))
      AND ((tlinfo.INVOICE_CURRENCY_CODE = X_INVOICE_CURRENCY_CODE)
           OR ((tlinfo.INVOICE_CURRENCY_CODE is null)
               AND (X_INVOICE_CURRENCY_CODE is null)))
      AND ((tlinfo.PAYMENT_CURRENCY_CODE = X_PAYMENT_CURRENCY_CODE)
           OR ((tlinfo.PAYMENT_CURRENCY_CODE is null)
               AND (X_PAYMENT_CURRENCY_CODE is null)))
      AND ((tlinfo.PAYMENT_CROSS_RATE = X_PAYMENT_CROSS_RATE)
           OR ((tlinfo.PAYMENT_CROSS_RATE is null)
               AND (X_PAYMENT_CROSS_RATE is null)))
      AND ((tlinfo.PAYMENT_CROSS_RATE_TYPE = X_PAYMENT_CROSS_RATE_TYPE)
           OR ((tlinfo.PAYMENT_CROSS_RATE_TYPE is null)
               AND (X_PAYMENT_CROSS_RATE_TYPE is null)))
      AND ((tlinfo.PAYMENT_CROSS_RATE_DATE = X_PAYMENT_CROSS_RATE_DATE)
           OR ((tlinfo.PAYMENT_CROSS_RATE_DATE is null)
               AND (X_PAYMENT_CROSS_RATE_DATE is null)))
      AND ((tlinfo.EXCHANGE_RATE = X_EXCHANGE_RATE)
           OR ((tlinfo.EXCHANGE_RATE is null)
               AND (X_EXCHANGE_RATE is null)))
      AND ((tlinfo.EXCHANGE_RATE_TYPE = X_EXCHANGE_RATE_TYPE)
           OR ((tlinfo.EXCHANGE_RATE_TYPE is null)
               AND (X_EXCHANGE_RATE_TYPE is null)))
      AND ((tlinfo.EXCHANGE_DATE = X_EXCHANGE_DATE)
           OR ((tlinfo.EXCHANGE_DATE is null)
               AND (X_EXCHANGE_DATE is null)))
      AND ((tlinfo.TERMS_ID = X_TERMS_ID)
           OR ((tlinfo.TERMS_ID is null)
               AND (X_TERMS_ID is null)))
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
     AND ((tlinfo.PAY_AWT_GROUP_ID = X_PAY_AWT_GROUP_ID)
           OR ((tlinfo.PAY_AWT_GROUP_ID is null)
               AND (X_PAY_AWT_GROUP_ID is null)))   --bug6639866
      AND ((tlinfo.AWT_GROUP_ID = X_AWT_GROUP_ID)
           OR ((tlinfo.AWT_GROUP_ID is null)
               AND (X_AWT_GROUP_ID is null)))
      AND ((tlinfo.AMOUNT_APPLICABLE_TO_DISCOUNT =
                         X_AMT_APPLICABLE_TO_DISCOUNT)
           OR ((tlinfo.AMOUNT_APPLICABLE_TO_DISCOUNT is null)
               AND (X_AMT_APPLICABLE_TO_DISCOUNT is null)))
      AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((tlinfo.ATTRIBUTE_CATEGORY is null)
               AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((tlinfo.ATTRIBUTE1 is null)
               AND (X_ATTRIBUTE1 is null)))
      AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((tlinfo.ATTRIBUTE2 is null)
               AND (X_ATTRIBUTE2 is null)))
      AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((tlinfo.ATTRIBUTE3 is null)
               AND (X_ATTRIBUTE3 is null)))
      AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((tlinfo.ATTRIBUTE4 is null)
               AND (X_ATTRIBUTE4 is null)))
      AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((tlinfo.ATTRIBUTE5 is null)
               AND (X_ATTRIBUTE5 is null)))
      AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((tlinfo.ATTRIBUTE6 is null)
               AND (X_ATTRIBUTE6 is null)))
      AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((tlinfo.ATTRIBUTE7 is null)
               AND (X_ATTRIBUTE7 is null)))
      AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((tlinfo.ATTRIBUTE8 is null)
               AND (X_ATTRIBUTE8 is null)))
      AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((tlinfo.ATTRIBUTE9 is null)
               AND (X_ATTRIBUTE9 is null)))
      AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((tlinfo.ATTRIBUTE10 is null)
               AND (X_ATTRIBUTE10 is null)))
      AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((tlinfo.ATTRIBUTE11 is null)
               AND (X_ATTRIBUTE11 is null)))
      AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((tlinfo.ATTRIBUTE12 is null)
               AND (X_ATTRIBUTE12 is null)))
      AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((tlinfo.ATTRIBUTE13 is null)
               AND (X_ATTRIBUTE13 is null)))
      AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((tlinfo.ATTRIBUTE14 is null)
               AND (X_ATTRIBUTE14 is null)))
      AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((tlinfo.ATTRIBUTE15 is null)
               AND (X_ATTRIBUTE15 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE_CATEGORY =
                          X_GLOBAL_ATTRIBUTE_CATEGORY)
           OR ((tlinfo.GLOBAL_ATTRIBUTE_CATEGORY is null)
               AND (X_GLOBAL_ATTRIBUTE_CATEGORY is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE1 = X_GLOBAL_ATTRIBUTE1)
           OR ((tlinfo.GLOBAL_ATTRIBUTE1 is null)
               AND (X_GLOBAL_ATTRIBUTE1 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE2 = X_GLOBAL_ATTRIBUTE2)
           OR ((tlinfo.GLOBAL_ATTRIBUTE2 is null)
               AND (X_GLOBAL_ATTRIBUTE2 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE3 = X_GLOBAL_ATTRIBUTE3)
           OR ((tlinfo.GLOBAL_ATTRIBUTE3 is null)
               AND (X_GLOBAL_ATTRIBUTE3 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE4 = X_GLOBAL_ATTRIBUTE4)
           OR ((tlinfo.GLOBAL_ATTRIBUTE4 is null)
               AND (X_GLOBAL_ATTRIBUTE4 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE5 = X_GLOBAL_ATTRIBUTE5)
           OR ((tlinfo.GLOBAL_ATTRIBUTE5 is null)
               AND (X_GLOBAL_ATTRIBUTE5 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE6 = X_GLOBAL_ATTRIBUTE6)
           OR ((tlinfo.GLOBAL_ATTRIBUTE6 is null)
               AND (X_GLOBAL_ATTRIBUTE6 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE7 = X_GLOBAL_ATTRIBUTE7)
           OR ((tlinfo.GLOBAL_ATTRIBUTE7 is null)
               AND (X_GLOBAL_ATTRIBUTE7 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE8 = X_GLOBAL_ATTRIBUTE8)
           OR ((tlinfo.GLOBAL_ATTRIBUTE8 is null)
               AND (X_GLOBAL_ATTRIBUTE8 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE9 = X_GLOBAL_ATTRIBUTE9)
           OR ((tlinfo.GLOBAL_ATTRIBUTE9 is null)
               AND (X_GLOBAL_ATTRIBUTE9 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE10 = X_GLOBAL_ATTRIBUTE10)
           OR ((tlinfo.GLOBAL_ATTRIBUTE10 is null)
               AND (X_GLOBAL_ATTRIBUTE10 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE11 = X_GLOBAL_ATTRIBUTE11)
           OR ((tlinfo.GLOBAL_ATTRIBUTE11 is null)
               AND (X_GLOBAL_ATTRIBUTE11 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE12 = X_GLOBAL_ATTRIBUTE12)
           OR ((tlinfo.GLOBAL_ATTRIBUTE12 is null)
               AND (X_GLOBAL_ATTRIBUTE12 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE13 = X_GLOBAL_ATTRIBUTE13)
           OR ((tlinfo.GLOBAL_ATTRIBUTE13 is null)
               AND (X_GLOBAL_ATTRIBUTE13 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE14 = X_GLOBAL_ATTRIBUTE14)
           OR ((tlinfo.GLOBAL_ATTRIBUTE14 is null)
               AND (X_GLOBAL_ATTRIBUTE14 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE15 = X_GLOBAL_ATTRIBUTE15)
           OR ((tlinfo.GLOBAL_ATTRIBUTE15 is null)
               AND (X_GLOBAL_ATTRIBUTE15 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE16 = X_GLOBAL_ATTRIBUTE16)
           OR ((tlinfo.GLOBAL_ATTRIBUTE16 is null)
               AND (X_GLOBAL_ATTRIBUTE16 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE17 = X_GLOBAL_ATTRIBUTE17)
           OR ((tlinfo.GLOBAL_ATTRIBUTE17 is null)
               AND (X_GLOBAL_ATTRIBUTE17 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE18 = X_GLOBAL_ATTRIBUTE18)
           OR ((tlinfo.GLOBAL_ATTRIBUTE18 is null)
               AND (X_GLOBAL_ATTRIBUTE18 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE19 = X_GLOBAL_ATTRIBUTE19)
           OR ((tlinfo.GLOBAL_ATTRIBUTE19 is null)
               AND (X_GLOBAL_ATTRIBUTE19 is null)))
      AND ((tlinfo.GLOBAL_ATTRIBUTE20 = X_GLOBAL_ATTRIBUTE20)
           OR ((tlinfo.GLOBAL_ATTRIBUTE20 is null)
               AND (X_GLOBAL_ATTRIBUTE20 is null)))
      AND ((tlinfo.STATUS = X_STATUS)
           OR ((tlinfo.STATUS is null)
               AND (X_STATUS is null)))
      AND ((tlinfo.SOURCE = X_SOURCE)
           OR ((tlinfo.SOURCE is null)
               AND (X_SOURCE is null)))
      AND ((tlinfo.GROUP_ID = X_GROUP_ID)
           OR ((tlinfo.GROUP_ID is null)
               AND (X_GROUP_ID is null)))
      AND ((tlinfo.WORKFLOW_FLAG = X_WORKFLOW_FLAG)
           OR ((tlinfo.WORKFLOW_FLAG is null)
               AND (X_WORKFLOW_FLAG is null)))
      AND ((tlinfo.DOC_CATEGORY_CODE = X_DOC_CATEGORY_CODE)
           OR ((tlinfo.DOC_CATEGORY_CODE is null)
               AND (X_DOC_CATEGORY_CODE is null)))
      AND ((tlinfo.VOUCHER_NUM = X_VOUCHER_NUM)
           OR ((tlinfo.VOUCHER_NUM is null)
               AND (X_VOUCHER_NUM is null)))
      AND ((tlinfo.PAY_GROUP_LOOKUP_CODE = X_PAY_GROUP_LOOKUP_CODE)
           OR ((tlinfo.PAY_GROUP_LOOKUP_CODE is null)
               AND (X_PAY_GROUP_LOOKUP_CODE is null)))
      AND ((tlinfo.GOODS_RECEIVED_DATE = X_GOODS_RECEIVED_DATE)
           OR ((tlinfo.GOODS_RECEIVED_DATE is null)
               AND (X_GOODS_RECEIVED_DATE is null)))
      AND ((tlinfo.INVOICE_RECEIVED_DATE = X_INVOICE_RECEIVED_DATE)
           OR ((tlinfo.INVOICE_RECEIVED_DATE is null)
               AND (X_INVOICE_RECEIVED_DATE is null)))
      AND ((tlinfo.GL_DATE = X_GL_DATE)
           OR ((tlinfo.GL_DATE is null)
               AND (X_GL_DATE is null)))
      AND ((tlinfo.ACCTS_PAY_CODE_COMBINATION_ID = X_ACCTS_PAY_CCID)
           OR ((tlinfo.ACCTS_PAY_CODE_COMBINATION_ID is null)
               AND (X_ACCTS_PAY_CCID is null)))
   -- Removed for bug 4277744
   -- AND ((tlinfo.USSGL_TRANSACTION_CODE = X_USSGL_TRANSACTION_CODE)
   --      OR ((tlinfo.USSGL_TRANSACTION_CODE is null)
   --          AND (X_USSGL_TRANSACTION_CODE is null)))
      AND ((tlinfo.EXCLUSIVE_PAYMENT_FLAG = X_EXCLUSIVE_PAYMENT_FLAG)
           OR ((tlinfo.EXCLUSIVE_PAYMENT_FLAG is null)
               AND (X_EXCLUSIVE_PAYMENT_FLAG is null)))
      AND ((tlinfo.INVOICE_INCLUDES_PREPAY_FLAG =
                           X_INVOICE_INCLUDES_PREPAY_FLAG)
           OR ((tlinfo.INVOICE_INCLUDES_PREPAY_FLAG is null)
               AND (X_INVOICE_INCLUDES_PREPAY_FLAG is null)))
      AND ((tlinfo.PREPAY_NUM = X_PREPAY_NUM)
           OR ((tlinfo.PREPAY_NUM is null)
               AND (X_PREPAY_NUM is null)))
      AND ((tlinfo.PREPAY_APPLY_AMOUNT = X_PREPAY_APPLY_AMOUNT)
           OR ((tlinfo.PREPAY_APPLY_AMOUNT is null)
               AND (X_PREPAY_APPLY_AMOUNT is null)))
      AND ((tlinfo.PREPAY_GL_DATE = X_PREPAY_GL_DATE)
           OR ((tlinfo.PREPAY_GL_DATE is null)
               AND (X_PREPAY_GL_DATE is null)))
-- Bug 1534162, Added terms_date for PN integration
      AND ((tlinfo.TERMS_DATE = X_TERMS_DATE)
           OR ((tlinfo.TERMS_DATE is null)
               AND (X_TERMS_DATE is null)))
      AND ((tlinfo.REQUESTER_ID = X_REQUESTER_ID)
           OR ((tlinfo.REQUESTER_ID is null)
               AND (X_REQUESTER_ID is null)))
      AND ((tlinfo.OPERATING_UNIT = X_OPERATING_UNIT)
           OR ((tlinfo.OPERATING_UNIT is null)
               AND (X_OPERATING_UNIT is null)))
-- Invoice Lines Project Stage 1
      AND ((tlinfo.PREPAY_LINE_NUM = X_PREPAY_LINE_NUM)
           OR ((tlinfo.PREPAY_LINE_NUM is null)
               AND (X_PREPAY_LINE_NUM is null)))
      AND ((tlinfo.REQUESTER_FIRST_NAME = X_REQUESTER_FIRST_NAME)
           OR ((tlinfo.REQUESTER_FIRST_NAME is null)
               AND (X_REQUESTER_FIRST_NAME is null)))
      AND ((tlinfo.REQUESTER_LAST_NAME = X_REQUESTER_LAST_NAME)
           OR ((tlinfo.REQUESTER_LAST_NAME is null)
               AND (X_REQUESTER_LAST_NAME is null)))
      AND ((tlinfo.REQUESTER_EMPLOYEE_NUM = X_REQUESTER_EMPLOYEE_NUM)
           OR ((tlinfo.REQUESTER_EMPLOYEE_NUM is null)
               AND (X_REQUESTER_EMPLOYEE_NUM is null)))
      AND ((tlinfo.CALC_TAX_DURING_IMPORT_FLAG = X_CALC_TAX_DURING_IMPORT_FLAG)
           OR ((tlinfo.CALC_TAX_DURING_IMPORT_FLAG is null)
               AND (X_CALC_TAX_DURING_IMPORT_FLAG is null)))
      AND ((tlinfo.CONTROL_AMOUNT = X_CONTROL_AMOUNT)
           OR ((tlinfo.CONTROL_AMOUNT is null)
               AND (X_CONTROL_AMOUNT is null)))
      AND ((tlinfo.ADD_TAX_TO_INV_AMT_FLAG = X_ADD_TAX_TO_INV_AMT_FLAG)
           OR ((tlinfo.ADD_TAX_TO_INV_AMT_FLAG is null)
               AND (X_ADD_TAX_TO_INV_AMT_FLAG is null)))
      AND ((tlinfo.TAX_RELATED_INVOICE_ID = X_TAX_RELATED_INVOICE_ID)
           OR ((tlinfo.TAX_RELATED_INVOICE_ID is null)
               AND (X_TAX_RELATED_INVOICE_ID is null)))
      AND ((tlinfo.TAXATION_COUNTRY = X_TAXATION_COUNTRY)
           OR ((tlinfo.TAXATION_COUNTRY is null)
               AND (X_TAXATION_COUNTRY is null)))
      AND ((tlinfo.DOCUMENT_SUB_TYPE = X_DOCUMENT_SUB_TYPE)
           OR ((tlinfo.DOCUMENT_SUB_TYPE is null)
               AND (X_DOCUMENT_SUB_TYPE is null)))
      AND ((tlinfo.SUPPLIER_TAX_INVOICE_NUMBER = X_SUPPLIER_TAX_INVOICE_NUMBER)
           OR ((tlinfo.SUPPLIER_TAX_INVOICE_NUMBER is null)
               AND (X_SUPPLIER_TAX_INVOICE_NUMBER is null)))
      AND ((tlinfo.SUPPLIER_TAX_INVOICE_DATE = X_SUPPLIER_TAX_INVOICE_DATE)
           OR ((tlinfo.SUPPLIER_TAX_INVOICE_DATE is null)
               AND (X_SUPPLIER_TAX_INVOICE_DATE is null)))
      AND ((tlinfo.SUPPLIER_TAX_EXCHANGE_RATE = X_SUPPLIER_TAX_EXCHANGE_RATE)
           OR ((tlinfo.SUPPLIER_TAX_EXCHANGE_RATE is null)
               AND (X_SUPPLIER_TAX_EXCHANGE_RATE is null)))
      AND ((tlinfo.TAX_INVOICE_RECORDING_DATE = X_TAX_INVOICE_RECORDING_DATE)
           OR ((tlinfo.TAX_INVOICE_RECORDING_DATE is null)
               AND (X_TAX_INVOICE_RECORDING_DATE is null)))
      AND ((tlinfo.TAX_INVOICE_INTERNAL_SEQ = X_TAX_INVOICE_INTERNAL_SEQ)
           OR ((tlinfo.TAX_INVOICE_INTERNAL_SEQ is null)
               AND (X_TAX_INVOICE_INTERNAL_SEQ is null)))
      AND ((tlinfo.LEGAL_ENTITY_ID = X_LEGAL_ENTITY_ID)
           OR ((tlinfo.LEGAL_ENTITY_ID is null)
               AND (X_LEGAL_ENTITY_ID is null)))
      AND ((tlinfo.PAYMENT_METHOD_CODE = X_PAYMENT_METHOD_CODE)
           OR ((tlinfo.PAYMENT_METHOD_CODE is null)
               AND (X_PAYMENT_METHOD_CODE is null)))
      AND ((tlinfo.PAYMENT_REASON_CODE = X_PAYMENT_REASON_CODE)
           OR ((tlinfo.PAYMENT_REASON_CODE is null)
               AND (X_PAYMENT_REASON_CODE is null)))
      AND ((tlinfo.PAYMENT_REASON_COMMENTS = X_PAYMENT_REASON_COMMENTS)
           OR ((tlinfo.PAYMENT_REASON_COMMENTS is null)
               AND (X_PAYMENT_REASON_COMMENTS is null)))
      AND ((tlinfo.UNIQUE_REMITTANCE_IDENTIFIER = X_UNIQUE_REMITTANCE_IDENTIFIER)
           OR ((tlinfo.UNIQUE_REMITTANCE_IDENTIFIER is null)
               AND (X_UNIQUE_REMITTANCE_IDENTIFIER is null)))
      AND ((tlinfo.URI_CHECK_DIGIT = X_URI_CHECK_DIGIT)
           OR ((tlinfo.URI_CHECK_DIGIT is null)
               AND (X_URI_CHECK_DIGIT is null)))
      AND ((tlinfo.BANK_CHARGE_BEARER = X_BANK_CHARGE_BEARER)
           OR ((tlinfo.BANK_CHARGE_BEARER is null)
               AND (X_BANK_CHARGE_BEARER is null)))
      AND ((tlinfo.DELIVERY_CHANNEL_CODE = X_DELIVERY_CHANNEL_CODE)
           OR ((tlinfo.DELIVERY_CHANNEL_CODE is null)
               AND (X_DELIVERY_CHANNEL_CODE is null)))
      AND ((tlinfo.SETTLEMENT_PRIORITY = X_SETTLEMENT_PRIORITY)
           OR ((tlinfo.SETTLEMENT_PRIORITY is null)
               AND (X_SETTLEMENT_PRIORITY is null)))
      AND ((tlinfo.REMITTANCE_MESSAGE1 = X_REMITTANCE_MESSAGE1)
           OR ((tlinfo.REMITTANCE_MESSAGE1 is null)
               AND (X_REMITTANCE_MESSAGE1 is null)))
      AND ((tlinfo.REMITTANCE_MESSAGE2 = X_REMITTANCE_MESSAGE2)
           OR ((tlinfo.REMITTANCE_MESSAGE2 is null)
               AND (X_REMITTANCE_MESSAGE2 is null)))
      AND ((tlinfo.REMITTANCE_MESSAGE3 = X_REMITTANCE_MESSAGE3)
           OR ((tlinfo.REMITTANCE_MESSAGE3 is null)
               AND (X_REMITTANCE_MESSAGE3 is null)))
      AND ((tlinfo.NET_OF_RETAINAGE_FLAG = X_NET_OF_RETAINAGE_FLAG)
           OR ((tlinfo.NET_OF_RETAINAGE_FLAG is null)
               AND (X_NET_OF_RETAINAGE_FLAG is null)))
      AND ((tlinfo.PORT_OF_ENTRY_CODE = X_PORT_OF_ENTRY_CODE)
           OR ((tlinfo.PORT_OF_ENTRY_CODE is null)
               AND (X_PORT_OF_ENTRY_CODE is null)))
      AND ((tlinfo.APPLICATION_ID = X_APPLICATION_ID)
           OR ((tlinfo.APPLICATION_ID is null)
               AND (X_APPLICATION_ID is null)))
      AND ((tlinfo.PRODUCT_TABLE = X_PRODUCT_TABLE)
           OR ((tlinfo.PRODUCT_TABLE is null)
               AND (X_PRODUCT_TABLE is null)))
      AND ((tlinfo.REFERENCE_KEY1 = X_REFERENCE_KEY1)
           OR ((tlinfo.REFERENCE_KEY1 is null)
               AND (X_REFERENCE_KEY1 is null)))
      AND ((tlinfo.REFERENCE_KEY2 = X_REFERENCE_KEY2)
           OR ((tlinfo.REFERENCE_KEY2 is null)
               AND (X_REFERENCE_KEY2 is null)))
      AND ((tlinfo.REFERENCE_KEY3 = X_REFERENCE_KEY3)
           OR ((tlinfo.REFERENCE_KEY3 is null)
               AND (X_REFERENCE_KEY3 is null)))
      AND ((tlinfo.REFERENCE_KEY4 = X_REFERENCE_KEY4)
           OR ((tlinfo.REFERENCE_KEY4 is null)
               AND (X_REFERENCE_KEY4 is null)))
      AND ((tlinfo.REFERENCE_KEY5 = X_REFERENCE_KEY5)
           OR ((tlinfo.REFERENCE_KEY5 is null)
               AND (X_REFERENCE_KEY5 is null)))
      AND ((tlinfo.PARTY_ID = X_PARTY_ID)
           OR ((tlinfo.PARTY_ID is null)
               AND (X_PARTY_ID is null)))
      AND ((tlinfo.PARTY_SITE_ID = X_PARTY_SITE_ID)
           OR ((tlinfo.PARTY_SITE_ID is null)
               AND (X_PARTY_SITE_ID is null)))
      AND ((tlinfo.PAY_PROC_TRXN_TYPE_CODE = X_PAY_PROC_TRXN_TYPE_CODE)
           OR ((tlinfo.PAY_PROC_TRXN_TYPE_CODE is null)
               AND (X_PAY_PROC_TRXN_TYPE_CODE is null)))
      AND ((tlinfo.PAYMENT_FUNCTION = X_PAYMENT_FUNCTION)
           OR ((tlinfo.PAYMENT_FUNCTION is null)
               AND (X_PAYMENT_FUNCTION is null)))
      AND ((tlinfo.PAYMENT_PRIORITY = X_PAYMENT_PRIORITY)
           OR ((tlinfo.PAYMENT_PRIORITY is null)
               AND (X_PAYMENT_PRIORITY is null)))
      AND ((tlinfo.external_bank_account_id = X_external_bank_account_id)
           OR ((tlinfo.external_bank_account_id is null)
               AND (X_external_bank_account_id is null)))
      AND ((tlinfo.remit_to_supplier_name = X_remit_to_supplier_name)
           OR ((tlinfo.remit_to_supplier_name is null)
               AND (X_remit_to_supplier_name is null)))
      AND ((tlinfo.remit_to_supplier_id = X_remit_to_supplier_id)
           OR ((tlinfo.remit_to_supplier_id is null)
               AND (X_remit_to_supplier_id is null)))
      AND ((tlinfo.remit_to_supplier_site = X_remit_to_supplier_site)
           OR ((tlinfo.remit_to_supplier_site is null)
               AND (X_remit_to_supplier_site is null)))
      AND ((tlinfo.remit_to_supplier_site_id = X_remit_to_supplier_site_id)
           OR ((tlinfo.remit_to_supplier_site_id is null)
               AND (X_remit_to_supplier_site_id is null)))
      AND ((tlinfo.relationship_id = X_relationship_id)
           OR ((tlinfo.relationship_id is null)
               AND (X_relationship_id is null)))

 ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;
  RETURN;
END LOCK_ROW;


procedure UPDATE_ROW (
          X_INVOICE_ID                   IN            NUMBER,
          X_INVOICE_NUM                  IN            VARCHAR2,
          X_INVOICE_TYPE_LOOKUP_CODE     IN            VARCHAR2,
          X_INVOICE_DATE                 IN            DATE,
          X_PO_NUMBER                    IN            VARCHAR2,
          X_VENDOR_ID                    IN            NUMBER,
          X_VENDOR_SITE_ID               IN            NUMBER,
          X_INVOICE_AMOUNT               IN            NUMBER,
          X_INVOICE_CURRENCY_CODE        IN            VARCHAR2,
          X_PAYMENT_CURRENCY_CODE        IN            VARCHAR2,
          X_PAYMENT_CROSS_RATE           IN            NUMBER,
          X_PAYMENT_CROSS_RATE_TYPE      IN            VARCHAR2,
          X_PAYMENT_CROSS_RATE_DATE      IN            DATE,
          X_EXCHANGE_RATE                IN            NUMBER,
          X_EXCHANGE_RATE_TYPE           IN            VARCHAR2,
          X_EXCHANGE_DATE                IN            DATE,
          X_TERMS_ID                     IN            NUMBER,
          X_DESCRIPTION                  IN            VARCHAR2,
          X_AWT_GROUP_ID                 IN            NUMBER,
          X_PAY_AWT_GROUP_ID             IN            NUMBER DEFAULT NULL, --bug6639866
          X_AMT_APPLICABLE_TO_DISCOUNT   IN            NUMBER,
          X_ATTRIBUTE_CATEGORY           IN            VARCHAR2,
          X_ATTRIBUTE1                   IN            VARCHAR2,
          X_ATTRIBUTE2                   IN            VARCHAR2,
          X_ATTRIBUTE3                   IN            VARCHAR2,
          X_ATTRIBUTE4                   IN            VARCHAR2,
          X_ATTRIBUTE5                   IN            VARCHAR2,
          X_ATTRIBUTE6                   IN            VARCHAR2,
          X_ATTRIBUTE7                   IN            VARCHAR2,
          X_ATTRIBUTE8                   IN            VARCHAR2,
          X_ATTRIBUTE9                   IN            VARCHAR2,
          X_ATTRIBUTE10                  IN            VARCHAR2,
          X_ATTRIBUTE11                  IN            VARCHAR2,
          X_ATTRIBUTE12                  IN            VARCHAR2,
          X_ATTRIBUTE13                  IN            VARCHAR2,
          X_ATTRIBUTE14                  IN            VARCHAR2,
          X_ATTRIBUTE15                  IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE_CATEGORY    IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE1            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE2            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE3            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE4            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE5            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE6            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE7            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE8            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE9            IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE10           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE11           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE12           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE13           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE14           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE15           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE16           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE17           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE18           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE19           IN            VARCHAR2,
          X_GLOBAL_ATTRIBUTE20           IN            VARCHAR2,
          X_STATUS                       IN            VARCHAR2,
          X_SOURCE                       IN            VARCHAR2,
          X_GROUP_ID                     IN            VARCHAR2,
          X_WORKFLOW_FLAG                IN            VARCHAR2,
          X_DOC_CATEGORY_CODE            IN            VARCHAR2,
          X_VOUCHER_NUM                  IN            VARCHAR2,
          X_PAY_GROUP_LOOKUP_CODE        IN            VARCHAR2,
          X_GOODS_RECEIVED_DATE          IN            DATE,
          X_INVOICE_RECEIVED_DATE        IN            DATE,
          X_GL_DATE                      IN            DATE,
          X_ACCTS_PAY_CCID               IN            NUMBER,
       -- X_USSGL_TRANSACTION_CODE       IN            VARCHAR2, - Bug 4277744
          X_EXCLUSIVE_PAYMENT_FLAG       IN            VARCHAR2,
          X_INVOICE_INCLUDES_PREPAY_FLAG IN            VARCHAR2,
          X_PREPAY_NUM                   IN            VARCHAR2,
          X_PREPAY_APPLY_AMOUNT          IN            NUMBER,
          X_PREPAY_GL_DATE               IN            DATE,
          X_LAST_UPDATE_DATE             IN            DATE,
          X_LAST_UPDATED_BY              IN            NUMBER,
          X_LAST_UPDATE_LOGIN            IN            NUMBER,
          X_MODE                         IN            VARCHAR2 DEFAULT 'R',
          X_TERMS_DATE                   IN            DATE     DEFAULT NULL,
          X_REQUESTER_ID                 IN            NUMBER   DEFAULT NULL,
          X_OPERATING_UNIT               IN            VARCHAR2 DEFAULT NULL,
          -- Invoice LINes Project Stage 1
          X_PREPAY_LINE_NUM              IN            NUMBER   DEFAULT NULL,
          X_REQUESTER_FIRST_NAME         IN            VARCHAR2 DEFAULT NULL,
          X_REQUESTER_LAST_NAME          IN            VARCHAR2 DEFAULT NULL,
          X_REQUESTER_EMPLOYEE_NUM       IN            VARCHAR2 DEFAULT NULL,
	  -- eTax Uptake
	  X_CALC_TAX_DURING_IMPORT_FLAG  IN            VARCHAR2 DEFAULT NULL,
	  X_CONTROL_AMOUNT  		 IN            NUMBER   DEFAULT NULL,
	  X_ADD_TAX_TO_INV_AMT_FLAG	 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_RELATED_INVOICE_ID       IN            NUMBER   DEFAULT NULL,
	  X_TAXATION_COUNTRY             IN            VARCHAR2 DEFAULT NULL,
	  X_DOCUMENT_SUB_TYPE            IN            VARCHAR2 DEFAULT NULL,
	  X_SUPPLIER_TAX_INVOICE_NUMBER  IN            VARCHAR2 DEFAULT NULL,
	  X_SUPPLIER_TAX_INVOICE_DATE    IN            DATE     DEFAULT NULL,
          X_SUPPLIER_TAX_EXCHANGE_RATE   IN            NUMBER   DEFAULT NULL,
	  X_TAX_INVOICE_RECORDING_DATE   IN            DATE     DEFAULT NULL,
	  X_TAX_INVOICE_INTERNAL_SEQ	 IN            VARCHAR2 DEFAULT NULL,
	  X_LEGAL_ENTITY_ID              IN            NUMBER   DEFAULT NULL,
          x_PAYMENT_METHOD_CODE          in            varchar2 default null,
          x_PAYMENT_REASON_CODE          in            varchar2 default null,
          X_PAYMENT_REASON_COMMENTS      in            varchar2 default null,
          x_UNIQUE_REMITTANCE_IDENTIFIER in            varchar2 default null,
          x_URI_CHECK_DIGIT              in            varchar2 default null,
          x_BANK_CHARGE_BEARER           in            varchar2 default null,
          x_DELIVERY_CHANNEL_CODE        in            varchar2 default null,
          x_SETTLEMENT_PRIORITY          in            varchar2 default null,
          x_remittance_message1          in            varchar2 default null,
          x_remittance_message2          in            varchar2 default null,
          x_remittance_message3          in            varchar2 default null,
	  x_NET_OF_RETAINAGE_FLAG	 in            varchar2 default null,
	  x_PORT_OF_ENTRY_CODE		 in	       varchar2 default null,
          X_APPLICATION_ID               IN            NUMBER   DEFAULT NULL,
          X_PRODUCT_TABLE                IN            VARCHAR2 DEFAULT NULL,
          X_REFERENCE_KEY1               IN            VARCHAR2 DEFAULT NULL,
          X_REFERENCE_KEY2               IN            VARCHAR2 DEFAULT NULL,
          X_REFERENCE_KEY3               IN            VARCHAR2 DEFAULT NULL,
          X_REFERENCE_KEY4               IN            VARCHAR2 DEFAULT NULL,
          X_REFERENCE_KEY5               IN            VARCHAR2 DEFAULT NULL,
          X_PARTY_ID                     IN            NUMBER   DEFAULT NULL,
          X_PARTY_SITE_ID                IN            NUMBER   DEFAULT NULL,
          X_PAY_PROC_TRXN_TYPE_CODE      IN            VARCHAR2 DEFAULT NULL,
          X_PAYMENT_FUNCTION             IN            VARCHAR2 DEFAULT NULL,
          X_PAYMENT_PRIORITY             IN            NUMBER   DEFAULT NULL,
          X_external_bank_account_id     in            number   default null,
	  X_REMIT_TO_SUPPLIER_NAME	IN	VARCHAR2 DEFAULT NULL,
	  X_REMIT_TO_SUPPLIER_ID	IN	NUMBER DEFAULT NULL,
	  X_REMIT_TO_SUPPLIER_SITE	IN	VARCHAR2 DEFAULT NULL,
	  X_REMIT_TO_SUPPLIER_SITE_ID	IN	NUMBER DEFAULT NULL,
	  X_RELATIONSHIP_ID	IN	NUMBER DEFAULT NULL)
IS
BEGIN
  UPDATE AP_INVOICES_INTERFACE
     SET
          INVOICE_NUM                   = X_INVOICE_NUM,
          INVOICE_TYPE_LOOKUP_CODE      = X_INVOICE_TYPE_LOOKUP_CODE,
          INVOICE_DATE                  = X_INVOICE_DATE,
          PO_NUMBER                     = X_PO_NUMBER,
          VENDOR_ID                     = X_VENDOR_ID,
          VENDOR_SITE_ID                = X_VENDOR_SITE_ID,
          INVOICE_AMOUNT                = X_INVOICE_AMOUNT,
          INVOICE_CURRENCY_CODE         = X_INVOICE_CURRENCY_CODE,
          PAYMENT_CURRENCY_CODE         = X_PAYMENT_CURRENCY_CODE,
          PAYMENT_CROSS_RATE            = X_PAYMENT_CROSS_RATE,
          PAYMENT_CROSS_RATE_TYPE       = X_PAYMENT_CROSS_RATE_TYPE,
          PAYMENT_CROSS_RATE_DATE       = X_PAYMENT_CROSS_RATE_DATE,
          EXCHANGE_RATE                 = X_EXCHANGE_RATE,
          EXCHANGE_RATE_TYPE            = X_EXCHANGE_RATE_TYPE,
          EXCHANGE_DATE                 = X_EXCHANGE_DATE,
          TERMS_ID                      = X_TERMS_ID,
          DESCRIPTION                   = X_DESCRIPTION,
          AWT_GROUP_ID                  = X_AWT_GROUP_ID,
          PAY_AWT_GROUP_ID              = X_PAY_AWT_GROUP_ID, --bug6639866
          AMOUNT_APPLICABLE_TO_DISCOUNT = X_AMT_APPLICABLE_TO_DISCOUNT,
          ATTRIBUTE_CATEGORY            = X_ATTRIBUTE_CATEGORY,
          ATTRIBUTE1                    = X_ATTRIBUTE1,
          ATTRIBUTE2                    = X_ATTRIBUTE2,
          ATTRIBUTE3                    = X_ATTRIBUTE3,
          ATTRIBUTE4                    = X_ATTRIBUTE4,
          ATTRIBUTE5                    = X_ATTRIBUTE5,
          ATTRIBUTE6                    = X_ATTRIBUTE6,
          ATTRIBUTE7                    = X_ATTRIBUTE7,
          ATTRIBUTE8                    = X_ATTRIBUTE8,
          ATTRIBUTE9                    = X_ATTRIBUTE9,
          ATTRIBUTE10                    = X_ATTRIBUTE10,
          ATTRIBUTE11                    = X_ATTRIBUTE11,
          ATTRIBUTE12                    = X_ATTRIBUTE12,
          ATTRIBUTE13                    = X_ATTRIBUTE13,
          ATTRIBUTE14                    = X_ATTRIBUTE14,
          ATTRIBUTE15                    = X_ATTRIBUTE15,
          GLOBAL_ATTRIBUTE_CATEGORY      = X_GLOBAL_ATTRIBUTE_CATEGORY,
          GLOBAL_ATTRIBUTE1              = X_GLOBAL_ATTRIBUTE1,
          GLOBAL_ATTRIBUTE2              = X_GLOBAL_ATTRIBUTE2,
          GLOBAL_ATTRIBUTE3              = X_GLOBAL_ATTRIBUTE3,
          GLOBAL_ATTRIBUTE4              = X_GLOBAL_ATTRIBUTE4,
          GLOBAL_ATTRIBUTE5              = X_GLOBAL_ATTRIBUTE5,
          GLOBAL_ATTRIBUTE6              = X_GLOBAL_ATTRIBUTE6,
          GLOBAL_ATTRIBUTE7              = X_GLOBAL_ATTRIBUTE7,
          GLOBAL_ATTRIBUTE8              = X_GLOBAL_ATTRIBUTE8,
          GLOBAL_ATTRIBUTE9              = X_GLOBAL_ATTRIBUTE9,
          GLOBAL_ATTRIBUTE10              = X_GLOBAL_ATTRIBUTE10,
          GLOBAL_ATTRIBUTE11              = X_GLOBAL_ATTRIBUTE11,
          GLOBAL_ATTRIBUTE12              = X_GLOBAL_ATTRIBUTE12,
          GLOBAL_ATTRIBUTE13              = X_GLOBAL_ATTRIBUTE13,
          GLOBAL_ATTRIBUTE14              = X_GLOBAL_ATTRIBUTE14,
          GLOBAL_ATTRIBUTE15              = X_GLOBAL_ATTRIBUTE15,
          GLOBAL_ATTRIBUTE16              = X_GLOBAL_ATTRIBUTE16,
          GLOBAL_ATTRIBUTE17              = X_GLOBAL_ATTRIBUTE17,
          GLOBAL_ATTRIBUTE18              = X_GLOBAL_ATTRIBUTE18,
          GLOBAL_ATTRIBUTE19              = X_GLOBAL_ATTRIBUTE19,
          GLOBAL_ATTRIBUTE20              = X_GLOBAL_ATTRIBUTE20,
          STATUS                          = X_STATUS,
          SOURCE                          = X_SOURCE,
          GROUP_ID                        = X_GROUP_ID,
          WORKFLOW_FLAG                   = X_WORKFLOW_FLAG,
          DOC_CATEGORY_CODE               = X_DOC_CATEGORY_CODE,
          VOUCHER_NUM                     = X_VOUCHER_NUM,
          PAY_GROUP_LOOKUP_CODE           = X_PAY_GROUP_LOOKUP_CODE,
          GOODS_RECEIVED_DATE             = X_GOODS_RECEIVED_DATE,
          GL_DATE                         = X_GL_DATE,
          ACCTS_PAY_CODE_COMBINATION_ID   = X_ACCTS_PAY_CCID,
       -- Removed for bug 4277744
       -- USSGL_TRANSACTION_CODE          = X_USSGL_TRANSACTION_CODE,
          EXCLUSIVE_PAYMENT_FLAG          = X_EXCLUSIVE_PAYMENT_FLAG,
          INVOICE_INCLUDES_PREPAY_FLAG    = X_INVOICE_INCLUDES_PREPAY_FLAG,
          PREPAY_NUM                      = X_PREPAY_NUM,
          PREPAY_APPLY_AMOUNT             = X_PREPAY_APPLY_AMOUNT,
          PREPAY_GL_DATE                  = X_PREPAY_GL_DATE,
          INVOICE_RECEIVED_DATE           = X_INVOICE_RECEIVED_DATE,
          LAST_UPDATE_DATE                = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY                 = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN               = X_LAST_UPDATE_LOGIN,
          TERMS_DATE                      = X_TERMS_DATE,
          REQUESTER_ID                    = X_REQUESTER_ID,
          OPERATING_UNIT                  = X_OPERATING_UNIT,
          -- Invoice Lines Project Stage 1
          PREPAY_LINE_NUM                 = X_PREPAY_LINE_NUM,
          REQUESTER_FIRST_NAME            = X_REQUESTER_FIRST_NAME,
          REQUESTER_LAST_NAME             = X_REQUESTER_LAST_NAME,
          REQUESTER_EMPLOYEE_NUM          = X_REQUESTER_EMPLOYEE_NUM,
	  -- eTax Uptake
	  CALC_TAX_DURING_IMPORT_FLAG	  = X_CALC_TAX_DURING_IMPORT_FLAG,
	  CONTROL_AMOUNT  		  = X_CONTROL_AMOUNT,
	  ADD_TAX_TO_INV_AMT_FLAG	  = X_ADD_TAX_TO_INV_AMT_FLAG,
	  TAX_RELATED_INVOICE_ID          = X_TAX_RELATED_INVOICE_ID,
	  TAXATION_COUNTRY             	  = X_TAXATION_COUNTRY,
	  DOCUMENT_SUB_TYPE            	  = X_DOCUMENT_SUB_TYPE,
	  SUPPLIER_TAX_INVOICE_NUMBER  	  = X_SUPPLIER_TAX_INVOICE_NUMBER,
	  SUPPLIER_TAX_INVOICE_DATE    	  = X_SUPPLIER_TAX_INVOICE_DATE,
	  SUPPLIER_TAX_EXCHANGE_RATE   	  = X_SUPPLIER_TAX_EXCHANGE_RATE,
	  TAX_INVOICE_RECORDING_DATE   	  = X_TAX_INVOICE_RECORDING_DATE,
	  TAX_INVOICE_INTERNAL_SEQ	  = X_TAX_INVOICE_INTERNAL_SEQ,
	  LEGAL_ENTITY_ID		  = X_LEGAL_ENTITY_ID,
          PAYMENT_METHOD_CODE             = x_PAYMENT_METHOD_CODE,
          PAYMENT_REASON_CODE             = x_PAYMENT_REASON_CODE,
          PAYMENT_REASON_COMMENTS         = X_PAYMENT_REASON_COMMENTS,
          UNIQUE_REMITTANCE_IDENTIFIER    = x_UNIQUE_REMITTANCE_IDENTIFIER,
          URI_CHECK_DIGIT                 = x_URI_CHECK_DIGIT,
          BANK_CHARGE_BEARER              = x_BANK_CHARGE_BEARER,
          DELIVERY_CHANNEL_CODE           = x_DELIVERY_CHANNEL_CODE,
          SETTLEMENT_PRIORITY             = x_SETTLEMENT_PRIORITY,
          REMITTANCE_MESSAGE1             = X_REMITTANCE_MESSAGE1,
          REMITTANCE_MESSAGE2             = X_REMITTANCE_MESSAGE2,
          REMITTANCE_MESSAGE3             = X_REMITTANCE_MESSAGE3,
	  NET_OF_RETAINAGE_FLAG		  = X_NET_OF_RETAINAGE_FLAG,
	  PORT_OF_ENTRY_CODE		  = X_PORT_OF_ENTRY_CODE,
          APPLICATION_ID                  = X_APPLICATION_ID,
          PRODUCT_TABLE                   = X_PRODUCT_TABLE,
          REFERENCE_KEY1                  = X_REFERENCE_KEY1,
          REFERENCE_KEY2                  = X_REFERENCE_KEY2,
          REFERENCE_KEY3                  = X_REFERENCE_KEY3,
          REFERENCE_KEY4                  = X_REFERENCE_KEY4,
          REFERENCE_KEY5                  = X_REFERENCE_KEY5,
          PARTY_ID                        = X_PARTY_ID,
          PARTY_SITE_ID                   = X_PARTY_SITE_ID,
          PAY_PROC_TRXN_TYPE_CODE         = X_PAY_PROC_TRXN_TYPE_CODE,
          PAYMENT_FUNCTION                = X_PAYMENT_FUNCTION,
          PAYMENT_PRIORITY                = X_PAYMENT_PRIORITY,
          external_bank_account_id        = x_external_bank_account_id,
	  REMIT_TO_SUPPLIER_NAME        = x_remit_to_supplier_name,
	  REMIT_TO_SUPPLIER_ID        = x_remit_to_supplier_id,
	  REMIT_TO_SUPPLIER_SITE        = x_remit_to_supplier_site,
	  REMIT_TO_SUPPLIER_SITE_ID        = x_remit_to_supplier_site_id,
	  RELATIONSHIP_ID        = x_relationship_id
  WHERE   INVOICE_ID = X_INVOICE_ID;

  IF (sql%notfound) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END UPDATE_ROW;

procedure DELETE_ROW (
          X_INVOICE_ID IN     NUMBER)
IS
BEGIN

  -- Bug 2496745. Deleting the interface lines and rejections
  -- when the invoice is deleted.

/* Delete invoice rejections from the rejections table */
  DELETE FROM ap_interface_rejections
   WHERE parent_id = X_INVOICE_ID AND
         parent_table = 'AP_INVOICES_INTERFACE';

/* Delete invoice lines rejections from the rejections table */
  DELETE FROM ap_interface_rejections
   WHERE parent_id IN (SELECT invoice_line_id
                         FROM ap_invoice_lines_interface
                        WHERE invoice_id = X_INVOICE_ID)
  and parent_table = 'AP_INVOICE_LINES_INTERFACE';

  /* Delete invoice lines from interface */
  DELETE FROM ap_invoice_lines_interface
   WHERE invoice_id = X_INVOICE_ID;

  /* Delete invoices from interface */
  DELETE FROM AP_INVOICES_INTERFACE
   WHERE INVOICE_ID = X_INVOICE_ID;

  IF (sql%notfound) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

END AP_INVOICES_INTERFACE_PKG;

/
