--------------------------------------------------------
--  DDL for Package Body AP_INVOICE_LINES_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_INVOICE_LINES_INTERFACE_PKG" as
 /* $Header: apailthb.pls 120.10.12010000.2 2009/04/09 12:42:29 sbonala ship $ */

procedure INSERT_ROW (
          X_ROWID                        IN OUT NOCOPY VARCHAR2,
          X_INVOICE_ID                   IN            NUMBER,
          X_INVOICE_LINE_ID              IN            NUMBER,
          X_LINE_NUMBER                  IN            NUMBER,
          X_LINE_TYPE_LOOKUP_CODE        IN            VARCHAR2,
          X_LINE_GROUP_NUMBER            IN            NUMBER,
          X_AMOUNT                       IN            NUMBER,
          X_ACCOUNTING_DATE              IN            DATE,
          X_DESCRIPTION                  IN            VARCHAR2,
--          X_AMOUNT_INCLUDES_TAX_FLAG     IN            VARCHAR2,
          X_PRORATE_ACROSS_FLAG          IN            VARCHAR2,
          X_TAX_CODE                     IN            VARCHAR2,
          X_TAX_CODE_ID                  IN            NUMBER,
--          X_TAX_CODE_OVERRIDE_FLAG       IN            VARCHAR2,
--          X_TAX_RECOVERY_RATE            IN            NUMBER,
--          X_TAX_RECOVERY_OVERRIDE_FLAG   IN            VARCHAR2,
--          X_TAX_RECOVERABLE_FLAG         IN            VARCHAR2,
          X_FINAL_MATCH_FLAG             IN            VARCHAR2,
          X_PO_HEADER_ID                 IN            NUMBER,
          X_PO_LINE_ID                   IN            NUMBER,
          X_PO_LINE_LOCATION_ID          IN            NUMBER,
          X_PO_DISTRIBUTION_ID           IN            NUMBER,
          X_UNIT_OF_MEAS_LOOKUP_CODE     IN            VARCHAR2,
          X_INVENTORY_ITEM_ID            IN            NUMBER,
          X_QUANTITY_INVOICED            IN            NUMBER,
          X_UNIT_PRICE                   IN            NUMBER,
          X_DISTRIBUTION_SET_ID          IN            NUMBER,
          X_DIST_CODE_CONCATENATED       IN            VARCHAR2,
          X_DIST_CODE_COMBINATION_ID     IN            NUMBER,
          X_AWT_GROUP_ID                 IN            NUMBER,
          X_PAY_AWT_GROUP_ID             IN            NUMBER DEFAULT NULL,--bug6639866
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
          X_PO_RELEASE_ID                IN            NUMBER,
          X_BALANCING_SEGMENT            IN            VARCHAR2,
          X_COST_CENTER_SEGMENT          IN            VARCHAR2,
          X_ACCOUNT_SEGMENT              IN            VARCHAR2,
          X_PROJECT_ID                   IN            NUMBER,
          X_TASK_ID                      IN            NUMBER,
          X_EXPENDITURE_TYPE             IN            VARCHAR2,
          X_EXPENDITURE_ITEM_DATE        IN            DATE,
          X_EXPENDITURE_ORGANIZATION_ID  IN            NUMBER,
          X_PROJECT_ACCOUNTING_CONTEXT   IN            VARCHAR2,
          X_PA_ADDITION_FLAG             IN            VARCHAR2,
          X_PA_QUANTITY                  IN            NUMBER,
          X_STAT_AMOUNT                  IN            NUMBER,
          X_TYPE_1099                    IN            VARCHAR2,
          X_INCOME_TAX_REGION            IN            VARCHAR2,
          X_ASSETS_TRACKING_FLAG         IN            VARCHAR2,
          X_PRICE_CORRECTION_FLAG        IN            VARCHAR2,
       -- X_USSGL_TRANSACTION_CODE       IN            VARCHAR2, - Bug 4277744
          X_RECEIPT_NUMBER               IN            VARCHAR2,
          X_MATCH_OPTION                 IN            VARCHAR2,
          X_RCV_TRANSACTION_ID           IN            NUMBER,
          X_CREATION_DATE                IN            DATE,
          X_CREATED_BY                   IN            NUMBER,
          X_LAST_UPDATE_DATE             IN            DATE,
          X_LAST_UPDATED_BY              IN            NUMBER,
          X_LAST_UPDATE_LOGIN            IN            NUMBER,
          X_ORG_ID                       IN            NUMBER,
          X_MODE                         IN            VARCHAR2 DEFAULT 'R',
          X_Calling_Sequence             IN            VARCHAR2,
          X_award_id                     IN            NUMBER   DEFAULT NULL,
          X_price_correct_inv_num        IN            VARCHAR2 DEFAULT NULL,
          -- Invoice Lines Project Stage 1
          X_PRICE_CORRECT_INV_LINE_NUM   IN            NUMBER   DEFAULT NULL,
          X_SERIAL_NUMBER                IN            VARCHAR2 DEFAULT NULL,
          X_MANUFACTURER                 IN            VARCHAR2 DEFAULT NULL,
          X_MODEL_NUMBER                 IN            VARCHAR2 DEFAULT NULL,
          X_WARRANTY_NUMBER              IN            VARCHAR2 DEFAULT NULL,
          X_ASSET_BOOK_TYPE_CODE         IN            VARCHAR2 DEFAULT NULL,
          X_ASSET_CATEGORY_ID            IN            NUMBER   DEFAULT NULL,
          X_REQUESTER_FIRST_NAME         IN            VARCHAR2 DEFAULT NULL,
          X_REQUESTER_LAST_NAME          IN            VARCHAR2 DEFAULT NULL,
          X_REQUESTER_EMPLOYEE_NUM       IN            VARCHAR2 DEFAULT NULL,
          X_REQUESTER_ID                 IN            NUMBER   DEFAULT NULL,
          X_DEFERRED_ACCTG_FLAG          IN            VARCHAR2 DEFAULT NULL,
          X_DEF_ACCTG_START_DATE         IN            DATE     DEFAULT NULL,
          X_DEF_ACCTG_END_DATE           IN            DATE     DEFAULT NULL,
          X_DEF_ACCTG_NUMBER_OF_PERIODS  IN            NUMBER   DEFAULT NULL,
          X_DEF_ACCTG_PERIOD_TYPE        IN            VARCHAR2 DEFAULT NULL,
	  -- eTax Uptake
	  X_CONTROL_AMOUNT		 IN            NUMBER   DEFAULT NULL,
	  X_ASSESSABLE_VALUE		 IN            NUMBER   DEFAULT NULL,
	  X_DEFAULT_DIST_CCID		 IN            NUMBER   DEFAULT NULL,
	  X_PRIMARY_INTENDED_USE	 IN            VARCHAR2 DEFAULT NULL,
	  X_SHIP_TO_LOCATION_ID		 IN            NUMBER   DEFAULT NULL,
	  X_PRODUCT_TYPE		 IN            VARCHAR2 DEFAULT NULL,
	  X_PRODUCT_CATEGORY		 IN            VARCHAR2 DEFAULT NULL,
	  X_PRODUCT_FISC_CLASSIFICATION  IN            VARCHAR2 DEFAULT NULL,
	  X_USER_DEFINED_FISC_CLASS	 IN            VARCHAR2 DEFAULT NULL,
	  X_TRX_BUSINESS_CATEGORY	 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_REGIME_CODE		 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX				 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_JURISDICTION_CODE	 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_STATUS_CODE		 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_RATE_ID			 IN            NUMBER   DEFAULT NULL,
	  X_TAX_RATE_CODE		 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_RATE			 IN            NUMBER   DEFAULT NULL,
	  X_INCL_IN_TAXABLE_LINE_FLAG	 IN            VARCHAR2 DEFAULT NULL,
	  X_PURCHASING_CATEGORY		 IN            VARCHAR2 DEFAULT NULL,
	  X_PURCHASING_CATEGORY_ID	 IN	       NUMBER   DEFAULT NULL,
	  X_COST_FACTOR_NAME		 IN	       VARCHAR2 DEFAULT NULL,
	  X_COST_FACTOR_ID		 IN	       NUMBER DEFAULT NULL,
          X_TAX_CLASSIFICATION_CODE      IN            VARCHAR2 DEFAULT NULL)
  IS
  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(100);

  CURSOR  C IS
  SELECT  ROWID
    FROM  AP_INVOICE_LINES_INTERFACE
   WHERE  invoice_id      = X_Invoice_Id
     AND  invoice_line_id = X_Invoice_Line_Id;
BEGIN
  -- Update the calling sequence

  current_calling_sequence :='AP_INVOICE_LINES_INTERFACE_PKG.Insert_Row<-'||
                                     X_Calling_Sequence;

  -- Check for uniqueness of the line number in the process.

  debug_info := 'Insert into ap_invoice_distributions';

  INSERT INTO AP_INVOICE_LINES_INTERFACE (
          INVOICE_ID,
          INVOICE_LINE_ID,
          LINE_NUMBER,
          LINE_TYPE_LOOKUP_CODE,
          LINE_GROUP_NUMBER,
          AMOUNT,
          ACCOUNTING_DATE,
          DESCRIPTION,
          -- AMOUNT_INCLUDES_TAX_FLAG,
          PRORATE_ACROSS_FLAG,
          TAX_CODE,
          TAX_CODE_ID,
          -- TAX_CODE_OVERRIDE_FLAG,
          -- TAX_RECOVERY_RATE,
          -- TAX_RECOVERY_OVERRIDE_FLAG,
          -- TAX_RECOVERABLE_FLAG,
          FINAL_MATCH_FLAG,
          PO_HEADER_ID,
          PO_LINE_ID,
          PO_LINE_LOCATION_ID,
          PO_DISTRIBUTION_ID,
          UNIT_OF_MEAS_LOOKUP_CODE,
          INVENTORY_ITEM_ID,
          QUANTITY_INVOICED,
          UNIT_PRICE,
          DISTRIBUTION_SET_ID,
          DIST_CODE_CONCATENATED,
          DIST_CODE_COMBINATION_ID,
          AWT_GROUP_ID,
          PAY_AWT_GROUP_ID,--bug6639866
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
          PO_RELEASE_ID,
          BALANCING_SEGMENT,
          COST_CENTER_SEGMENT,
          ACCOUNT_SEGMENT,
          PROJECT_ID,
          TASK_ID,
          EXPENDITURE_TYPE,
          EXPENDITURE_ITEM_DATE,
          EXPENDITURE_ORGANIZATION_ID,
          PROJECT_ACCOUNTING_CONTEXT,
          PA_ADDITION_FLAG,
          PA_QUANTITY,
          STAT_AMOUNT,
          TYPE_1099,
          INCOME_TAX_REGION,
          ASSETS_TRACKING_FLAG,
          PRICE_CORRECTION_FLAG,
       -- USSGL_TRANSACTION_CODE, - Bug 4277744
          RECEIPT_NUMBER,
          MATCH_OPTION,
          RCV_TRANSACTION_ID,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          ORG_ID,
          AWARD_ID,
          PRICE_CORRECT_INV_NUM,
          -- Invoice Lines Project Stage 1
          PRICE_CORRECT_INV_LINE_NUM,
          SERIAL_NUMBER,
          MANUFACTURER,
          MODEL_NUMBER,
          WARRANTY_NUMBER,
          ASSET_BOOK_TYPE_CODE,
          ASSET_CATEGORY_ID,
          REQUESTER_FIRST_NAME,
          REQUESTER_LAST_NAME,
          REQUESTER_EMPLOYEE_NUM,
          REQUESTER_ID,
          DEFERRED_ACCTG_FLAG,
          DEF_ACCTG_START_DATE,
          DEF_ACCTG_END_DATE,
          DEF_ACCTG_NUMBER_OF_PERIODS,
          DEF_ACCTG_PERIOD_TYPE,
	  CONTROL_AMOUNT,
	  ASSESSABLE_VALUE,
	  DEFAULT_DIST_CCID,
	  PRIMARY_INTENDED_USE,
	  SHIP_TO_LOCATION_ID,
	  PRODUCT_TYPE,
	  PRODUCT_CATEGORY,
	  PRODUCT_FISC_CLASSIFICATION,
	  USER_DEFINED_FISC_CLASS,
	  TRX_BUSINESS_CATEGORY,
	  TAX_REGIME_CODE,
	  TAX,
	  TAX_JURISDICTION_CODE,
	  TAX_STATUS_CODE,
	  TAX_RATE_ID,
	  TAX_RATE_CODE,
	  TAX_RATE,
	  INCL_IN_TAXABLE_LINE_FLAG,
	  PURCHASING_CATEGORY,
	  PURCHASING_CATEGORY_ID,
	  COST_FACTOR_NAME,
	  COST_FACTOR_ID,
	  TAX_CLASSIFICATION_CODE)
    VALUES (
          X_INVOICE_ID,
          X_INVOICE_LINE_ID,
          X_LINE_NUMBER,
          X_LINE_TYPE_LOOKUP_CODE,
          X_LINE_GROUP_NUMBER,
          X_AMOUNT,
          X_ACCOUNTING_DATE,
          X_DESCRIPTION,
          -- X_AMOUNT_INCLUDES_TAX_FLAG,
          X_PRORATE_ACROSS_FLAG,
          X_TAX_CODE,
          X_TAX_CODE_ID,
          -- X_TAX_CODE_OVERRIDE_FLAG,
          -- X_TAX_RECOVERY_RATE,
          -- X_TAX_RECOVERY_OVERRIDE_FLAG,
          -- X_TAX_RECOVERABLE_FLAG,
          X_FINAL_MATCH_FLAG,
          X_PO_HEADER_ID,
          X_PO_LINE_ID,
          X_PO_LINE_LOCATION_ID,
          X_PO_DISTRIBUTION_ID,
          X_UNIT_OF_MEAS_LOOKUP_CODE,
          X_INVENTORY_ITEM_ID,
          X_QUANTITY_INVOICED,
          X_UNIT_PRICE,
          X_DISTRIBUTION_SET_ID,
          X_DIST_CODE_CONCATENATED,
          X_DIST_CODE_COMBINATION_ID,
          X_AWT_GROUP_ID,
          X_PAY_AWT_GROUP_ID,--bug6639866
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
          X_PO_RELEASE_ID,
          X_BALANCING_SEGMENT,
          X_COST_CENTER_SEGMENT,
          X_ACCOUNT_SEGMENT,
          X_PROJECT_ID,
          X_TASK_ID,
          X_EXPENDITURE_TYPE,
          X_EXPENDITURE_ITEM_DATE,
          X_EXPENDITURE_ORGANIZATION_ID,
          X_PROJECT_ACCOUNTING_CONTEXT,
          X_PA_ADDITION_FLAG,
          X_PA_QUANTITY,
          X_STAT_AMOUNT,
          X_TYPE_1099,
          X_INCOME_TAX_REGION,
          X_ASSETS_TRACKING_FLAG,
          X_PRICE_CORRECTION_FLAG,
       -- X_USSGL_TRANSACTION_CODE, - Bug 4277744
          X_RECEIPT_NUMBER,
          X_MATCH_OPTION,
          X_RCV_TRANSACTION_ID,
          X_LAST_UPDATE_DATE,
          X_LAST_UPDATED_BY,
          X_LAST_UPDATE_DATE,
          X_LAST_UPDATED_BY,
          X_LAST_UPDATE_LOGIN,
          X_ORG_ID,
          X_AWARD_ID,
          X_price_correct_inv_num,
          -- Invoice Lines Project Stage 1
          X_PRICE_CORRECT_INV_LINE_NUM,
          X_SERIAL_NUMBER,
          X_MANUFACTURER,
          X_MODEL_NUMBER,
          X_WARRANTY_NUMBER,
          X_ASSET_BOOK_TYPE_CODE,
          X_ASSET_CATEGORY_ID,
          X_REQUESTER_FIRST_NAME,
          X_REQUESTER_LAST_NAME,
          X_REQUESTER_EMPLOYEE_NUM,
          X_REQUESTER_ID,
          X_DEFERRED_ACCTG_FLAG,
          X_DEF_ACCTG_START_DATE,
          X_DEF_ACCTG_END_DATE,
          X_DEF_ACCTG_NUMBER_OF_PERIODS,
          X_DEF_ACCTG_PERIOD_TYPE,
	  -- eTax Uptake
          X_CONTROL_AMOUNT,
          X_ASSESSABLE_VALUE,
          X_DEFAULT_DIST_CCID,
          X_PRIMARY_INTENDED_USE,
          X_SHIP_TO_LOCATION_ID,
          X_PRODUCT_TYPE,
          X_PRODUCT_CATEGORY,
          X_PRODUCT_FISC_CLASSIFICATION,
          X_USER_DEFINED_FISC_CLASS,
          X_TRX_BUSINESS_CATEGORY,
          X_TAX_REGIME_CODE,
          X_TAX,
          X_TAX_JURISDICTION_CODE,
          X_TAX_STATUS_CODE,
          X_TAX_RATE_ID,
          X_TAX_RATE_CODE,
          X_TAX_RATE,
          X_INCL_IN_TAXABLE_LINE_FLAG,
	  X_PURCHASING_CATEGORY,
	  X_PURCHASING_CATEGORY_ID,
	  X_COST_FACTOR_NAME,
	  X_COST_FACTOR_ID,
	  X_TAX_CLASSIFICATION_CODE);

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO X_Rowid;
    IF (C%NOTFOUND) THEN
      debug_info := 'Close cursor C - ROW NOTFOUND';
      CLOSE C;
      Raise NO_DATA_FOUND;
    END IF;
    debug_info := 'Close cursor C';
    CLOSE C;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

END INSERT_ROW;

procedure LOCK_ROW (
          X_ROWID                        IN            VARCHAR2,
          X_INVOICE_ID                   IN            NUMBER,
          X_INVOICE_LINE_ID              IN            NUMBER,
          X_LINE_NUMBER                  IN            NUMBER,
          X_LINE_TYPE_LOOKUP_CODE        IN            VARCHAR2,
          X_LINE_GROUP_NUMBER            IN            NUMBER,
          X_AMOUNT                       IN            NUMBER,
          X_ACCOUNTING_DATE              IN            DATE,
          X_DESCRIPTION                  IN            VARCHAR2,
--          X_AMOUNT_INCLUDES_TAX_FLAG     IN            VARCHAR2,
          X_PRORATE_ACROSS_FLAG          IN            VARCHAR2,
   --    X_TAX_CODE                      IN            VARCHAR2, -- Commented for bug 8330367/8304429
   --     X_TAX_CODE_ID                  IN            NUMBER,   -- Commented for bug 8330367/8304429
--          X_TAX_CODE_OVERRIDE_FLAG       IN            VARCHAR2,
--          X_TAX_RECOVERY_RATE            IN            NUMBER,
--          X_TAX_RECOVERY_OVERRIDE_FLAG   IN            VARCHAR2,
--          X_TAX_RECOVERABLE_FLAG         IN            VARCHAR2,
          X_FINAL_MATCH_FLAG             IN            VARCHAR2,
          X_PO_HEADER_ID                 IN            NUMBER,
          X_PO_LINE_ID                   IN            NUMBER,
          X_PO_LINE_LOCATION_ID          IN            NUMBER,
          X_PO_DISTRIBUTION_ID           IN            NUMBER,
          X_UNIT_OF_MEAS_LOOKUP_CODE     IN            VARCHAR2,
          X_INVENTORY_ITEM_ID            IN            NUMBER,
          X_QUANTITY_INVOICED            IN            NUMBER,
          X_UNIT_PRICE                   IN            NUMBER,
          X_DISTRIBUTION_SET_ID          IN            NUMBER,
          X_DIST_CODE_CONCATENATED       IN            VARCHAR2,
          X_DIST_CODE_COMBINATION_ID     IN            NUMBER,
          X_AWT_GROUP_ID                 IN            NUMBER,
          X_PAY_AWT_GROUP_ID             IN            NUMBER DEFAULT NULL,--bug6639866
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
          X_PO_RELEASE_ID                IN            NUMBER,
          X_BALANCING_SEGMENT            IN            VARCHAR2,
          X_COST_CENTER_SEGMENT          IN            VARCHAR2,
          X_ACCOUNT_SEGMENT              IN            VARCHAR2,
          X_PROJECT_ID                   IN            NUMBER,
          X_TASK_ID                      IN            NUMBER,
          X_EXPENDITURE_TYPE             IN            VARCHAR2,
          X_EXPENDITURE_ITEM_DATE        IN            DATE,
          X_EXPENDITURE_ORGANIZATION_ID  IN            NUMBER,
          X_PROJECT_ACCOUNTING_CONTEXT   IN            VARCHAR2,
          X_PA_ADDITION_FLAG             IN            VARCHAR2,
          X_PA_QUANTITY                  IN            NUMBER,
          X_STAT_AMOUNT                  IN            NUMBER,
          X_TYPE_1099                    IN            VARCHAR2,
          X_INCOME_TAX_REGION            IN            VARCHAR2,
          X_ASSETS_TRACKING_FLAG         IN            VARCHAR2,
          X_PRICE_CORRECTION_FLAG        IN            VARCHAR2,
       -- X_USSGL_TRANSACTION_CODE       IN            VARCHAR2, - Bug 4277744
          X_RECEIPT_NUMBER               IN            VARCHAR2,
          X_MATCH_OPTION                 IN            VARCHAR2,
          X_RCV_TRANSACTION_ID           IN            NUMBER,
          X_CALLING_SEQUENCE             IN            VARCHAR2,
          X_AWARD_ID                     IN            NUMBER   DEFAULT NULL,
          X_PRICE_CORRECT_INV_NUM        IN            VARCHAR2 DEFAULT NULL,
          -- Invoice Lines Project Stage 1
          X_PRICE_CORRECT_INV_LINE_NUM   IN            NUMBER   DEFAULT NULL,
          X_SERIAL_NUMBER                IN            VARCHAR2 DEFAULT NULL,
          X_MANUFACTURER                 IN            VARCHAR2 DEFAULT NULL,
          X_MODEL_NUMBER                 IN            VARCHAR2 DEFAULT NULL,
          X_WARRANTY_NUMBER              IN            VARCHAR2 DEFAULT NULL,
          X_ASSET_BOOK_TYPE_CODE         IN            VARCHAR2 DEFAULT NULL,
          X_ASSET_CATEGORY_ID            IN            NUMBER   DEFAULT NULL,
          X_REQUESTER_FIRST_NAME         IN            VARCHAR2 DEFAULT NULL,
          X_REQUESTER_LAST_NAME          IN            VARCHAR2 DEFAULT NULL,
          X_REQUESTER_EMPLOYEE_NUM       IN            VARCHAR2 DEFAULT NULL,
          X_REQUESTER_ID                 IN            NUMBER   DEFAULT NULL,
          X_DEFERRED_ACCTG_FLAG          IN            VARCHAR2 DEFAULT NULL,
          X_DEF_ACCTG_START_DATE         IN            DATE     DEFAULT NULL,
          X_DEF_ACCTG_END_DATE           IN            DATE     DEFAULT NULL,
          X_DEF_ACCTG_NUMBER_OF_PERIODS  IN            NUMBER   DEFAULT NULL,
          X_DEF_ACCTG_PERIOD_TYPE        IN            VARCHAR2 DEFAULT NULL,
	  -- eTax Uptake
	  X_CONTROL_AMOUNT		 IN            NUMBER   DEFAULT NULL,
	  X_ASSESSABLE_VALUE		 IN            NUMBER   DEFAULT NULL,
	  X_DEFAULT_DIST_CCID		 IN            NUMBER   DEFAULT NULL,
	  X_PRIMARY_INTENDED_USE	 IN            VARCHAR2 DEFAULT NULL,
	  X_SHIP_TO_LOCATION_ID		 IN            NUMBER   DEFAULT NULL,
	  X_PRODUCT_TYPE		 IN            VARCHAR2 DEFAULT NULL,
	  X_PRODUCT_CATEGORY		 IN            VARCHAR2 DEFAULT NULL,
	  X_PRODUCT_FISC_CLASSIFICATION  IN            VARCHAR2 DEFAULT NULL,
	  X_USER_DEFINED_FISC_CLASS	 IN            VARCHAR2 DEFAULT NULL,
	  X_TRX_BUSINESS_CATEGORY	 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_REGIME_CODE		 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX				 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_JURISDICTION_CODE	 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_STATUS_CODE		 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_RATE_ID			 IN            NUMBER   DEFAULT NULL,
	  X_TAX_RATE_CODE		 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_RATE			 IN            NUMBER   DEFAULT NULL,
	  X_INCL_IN_TAXABLE_LINE_FLAG	 IN            VARCHAR2 DEFAULT NULL,
	  X_PURCHASING_CATEGORY		 IN	       VARCHAR2 DEFAULT NULL,
	  X_PURCHASING_CATEGORY_ID	 IN            NUMBER   DEFAULT NULL,
	  X_COST_FACTOR_NAME		 IN	       VARCHAR2 DEFAULT NULL,
	  X_COST_FACTOR_ID		 IN	       NUMBER   DEFAULT NULL,
          X_TAX_CLASSIFICATION_CODE      IN            VARCHAR2 DEFAULT NULL)
  IS
  CURSOR C1 IS
  SELECT
          INVOICE_ID,
          INVOICE_LINE_ID,
          LINE_NUMBER,
          LINE_TYPE_LOOKUP_CODE,
          LINE_GROUP_NUMBER,
          AMOUNT,
          ACCOUNTING_DATE,
          DESCRIPTION,
          -- AMOUNT_INCLUDES_TAX_FLAG,
          PRORATE_ACROSS_FLAG,
          -- TAX_CODE, -- Commented for bug 8330367/8304429
          -- TAX_CODE_ID, -- Commented for bug 8330367/8304429
          -- TAX_CODE_OVERRIDE_FLAG,
          -- TAX_RECOVERY_RATE,
          -- TAX_RECOVERY_OVERRIDE_FLAG,
          -- TAX_RECOVERABLE_FLAG,
          FINAL_MATCH_FLAG,
          PO_HEADER_ID,
          PO_LINE_ID,
          PO_LINE_LOCATION_ID,
          PO_DISTRIBUTION_ID,
          UNIT_OF_MEAS_LOOKUP_CODE,
          INVENTORY_ITEM_ID,
          QUANTITY_INVOICED,
          UNIT_PRICE,
          DISTRIBUTION_SET_ID,
          DIST_CODE_CONCATENATED,
          DIST_CODE_COMBINATION_ID,
          AWT_GROUP_ID,
          PAY_AWT_GROUP_ID,--bug6639866
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
          PO_RELEASE_ID,
          BALANCING_SEGMENT,
          COST_CENTER_SEGMENT,
          ACCOUNT_SEGMENT,
          PROJECT_ID,
          TASK_ID,
          EXPENDITURE_TYPE,
          EXPENDITURE_ITEM_DATE,
          EXPENDITURE_ORGANIZATION_ID,
          PROJECT_ACCOUNTING_CONTEXT,
          PA_ADDITION_FLAG,
          PA_QUANTITY,
          STAT_AMOUNT,
          TYPE_1099,
          INCOME_TAX_REGION,
          ASSETS_TRACKING_FLAG,
          PRICE_CORRECTION_FLAG,
       -- USSGL_TRANSACTION_CODE, - Bug 4277744
          RECEIPT_NUMBER,
          MATCH_OPTION,
          RCV_TRANSACTION_ID,
          AWARD_ID,
          PRICE_CORRECT_INV_NUM,
          -- Invoice Lines Project Stage 1
          PRICE_CORRECT_INV_LINE_NUM,
          SERIAL_NUMBER,
          MANUFACTURER,
          MODEL_NUMBER,
          WARRANTY_NUMBER,
          ASSET_BOOK_TYPE_CODE,
          ASSET_CATEGORY_ID,
          REQUESTER_FIRST_NAME,
          REQUESTER_LAST_NAME,
          REQUESTER_EMPLOYEE_NUM,
          REQUESTER_ID,
          DEFERRED_ACCTG_FLAG,
          DEF_ACCTG_START_DATE,
          DEF_ACCTG_END_DATE,
          DEF_ACCTG_NUMBER_OF_PERIODS,
          DEF_ACCTG_PERIOD_TYPE,
          CONTROL_AMOUNT,
          ASSESSABLE_VALUE,
          DEFAULT_DIST_CCID,
          PRIMARY_INTENDED_USE,
          SHIP_TO_LOCATION_ID,
          PRODUCT_TYPE,
          PRODUCT_CATEGORY,
          PRODUCT_FISC_CLASSIFICATION,
          USER_DEFINED_FISC_CLASS,
          TRX_BUSINESS_CATEGORY,
          TAX_REGIME_CODE,
          TAX,
          TAX_JURISDICTION_CODE,
          TAX_STATUS_CODE,
          TAX_RATE_ID,
          TAX_RATE_CODE,
          TAX_RATE,
	  INCL_IN_TAXABLE_LINE_FLAG,
	  PURCHASING_CATEGORY,
	  PURCHASING_CATEGORY_ID,
	  COST_FACTOR_NAME,
	  COST_FACTOR_ID,
	  TAX_CLASSIFICATION_CODE
    FROM  AP_INVOICE_LINES_INTERFACE
   WHERE  rowid = X_Rowid
     FOR UPDATE OF Invoice_id NOWAIT;

  tlinfo c1%rowtype;
  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(100);
BEGIN
  -- Update the calling sequence

  current_calling_sequence :='AP_INVOICE_LINES_INTERFACE_PKG.Lock_Row<-'
                             ||X_Calling_Sequence;

  debug_info := 'Select from ap_invoice_lines_interface';

  OPEN c1;

  debug_info := 'Fetch cursor C1';
  FETCH c1 INTO tlinfo;
  IF (c1%notfound) THEN
    debug_info := 'Close cursor C - ROW NOTFOUND';
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
    CLOSE c1;
    RETURN;
  END IF;
  CLOSE c1;

  IF ( (tlinfo.INVOICE_ID = X_INVOICE_ID)
      AND ((tlinfo.INVOICE_LINE_ID = X_INVOICE_LINE_ID)
           OR ((tlinfo.INVOICE_LINE_ID is null)
               AND (X_INVOICE_LINE_ID is null)))
      AND ((tlinfo.LINE_NUMBER = X_LINE_NUMBER)
           OR ((tlinfo.LINE_NUMBER is null)
               AND (X_LINE_NUMBER is null)))
      AND ((tlinfo.LINE_TYPE_LOOKUP_CODE = X_LINE_TYPE_LOOKUP_CODE)
           OR ((tlinfo.LINE_TYPE_LOOKUP_CODE is null)
               AND (X_LINE_TYPE_LOOKUP_CODE is null)))
      AND ((tlinfo.LINE_GROUP_NUMBER = X_LINE_GROUP_NUMBER)
           OR ((tlinfo.LINE_GROUP_NUMBER is null)
               AND (X_LINE_GROUP_NUMBER is null)))
      AND ((tlinfo.AMOUNT = X_AMOUNT)
           OR ((tlinfo.AMOUNT is null)
               AND (X_AMOUNT is null)))
      AND ((tlinfo.ACCOUNTING_DATE = X_ACCOUNTING_DATE)
           OR ((tlinfo.ACCOUNTING_DATE is null)
               AND (X_ACCOUNTING_DATE is null)))
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
/*
      AND ((tlinfo.AMOUNT_INCLUDES_TAX_FLAG = X_AMOUNT_INCLUDES_TAX_FLAG)
           OR ((tlinfo.AMOUNT_INCLUDES_TAX_FLAG is null)
               AND (X_AMOUNT_INCLUDES_TAX_FLAG is null)))
*/
      AND ((tlinfo.PRORATE_ACROSS_FLAG = X_PRORATE_ACROSS_FLAG)
           OR ((tlinfo.PRORATE_ACROSS_FLAG is null)
               AND (X_PRORATE_ACROSS_FLAG is null)))

     -- Commented for bug 8330367/8304429
     /* AND ((tlinfo.TAX_CODE = X_TAX_CODE)
           OR ((tlinfo.TAX_CODE is null)
               AND (X_TAX_CODE is null)))
      AND ((tlinfo.TAX_CODE_ID = X_TAX_CODE_ID)
           OR ((tlinfo.TAX_CODE_ID is null)
               AND (X_TAX_CODE_ID is null))) */
      -- End of 8330367/8304429
/*
      AND ((tlinfo.TAX_CODE_OVERRIDE_FLAG = X_TAX_CODE_OVERRIDE_FLAG)
           OR ((tlinfo.TAX_CODE_OVERRIDE_FLAG is null)
               AND (X_TAX_CODE_OVERRIDE_FLAG is null)))
      AND ((tlinfo.TAX_RECOVERY_RATE = X_TAX_RECOVERY_RATE)
           OR ((tlinfo.TAX_RECOVERY_RATE is null)
               AND (X_TAX_RECOVERY_RATE is null)))
      AND ((tlinfo.TAX_RECOVERY_OVERRIDE_FLAG = X_TAX_RECOVERY_OVERRIDE_FLAG)
           OR ((tlinfo.TAX_RECOVERY_OVERRIDE_FLAG is null)
               AND (X_TAX_RECOVERY_OVERRIDE_FLAG is null)))
      AND ((tlinfo.TAX_RECOVERABLE_FLAG = X_TAX_RECOVERABLE_FLAG)
           OR ((tlinfo.TAX_RECOVERABLE_FLAG is null)
               AND (X_TAX_RECOVERABLE_FLAG is null)))
*/
      AND ((tlinfo.FINAL_MATCH_FLAG = X_FINAL_MATCH_FLAG)
           OR ((tlinfo.FINAL_MATCH_FLAG is null)
               AND (X_FINAL_MATCH_FLAG is null)))
      AND ((tlinfo.PO_HEADER_ID = X_PO_HEADER_ID)
           OR ((tlinfo.PO_HEADER_ID is null)
               AND (X_PO_HEADER_ID is null)))
      AND ((tlinfo.PO_LINE_ID = X_PO_LINE_ID)
           OR ((tlinfo.PO_LINE_ID is null)
               AND (X_PO_LINE_ID is null)))
      AND ((tlinfo.PO_LINE_LOCATION_ID = X_PO_LINE_LOCATION_ID)
           OR ((tlinfo.PO_LINE_LOCATION_ID is null)
               AND (X_PO_LINE_LOCATION_ID is null)))
      AND ((tlinfo.PO_DISTRIBUTION_ID = X_PO_DISTRIBUTION_ID)
           OR ((tlinfo.PO_DISTRIBUTION_ID is null)
               AND (X_PO_DISTRIBUTION_ID is null)))
      AND ((tlinfo.UNIT_OF_MEAS_LOOKUP_CODE = X_UNIT_OF_MEAS_LOOKUP_CODE)
           OR ((tlinfo.UNIT_OF_MEAS_LOOKUP_CODE is null)
               AND (X_UNIT_OF_MEAS_LOOKUP_CODE is null)))
      AND ((tlinfo.INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID)
           OR ((tlinfo.INVENTORY_ITEM_ID is null)
               AND (X_INVENTORY_ITEM_ID is null)))
      AND ((tlinfo.QUANTITY_INVOICED = X_QUANTITY_INVOICED)
           OR ((tlinfo.QUANTITY_INVOICED is null)
               AND (X_QUANTITY_INVOICED is null)))
      AND ((tlinfo.UNIT_PRICE = X_UNIT_PRICE)
           OR ((tlinfo.UNIT_PRICE is null)
               AND (X_UNIT_PRICE is null)))
      AND ((tlinfo.DISTRIBUTION_SET_ID = X_DISTRIBUTION_SET_ID)
           OR ((tlinfo.DISTRIBUTION_SET_ID is null)
               AND (X_DISTRIBUTION_SET_ID is null)))
      AND ((tlinfo.DIST_CODE_CONCATENATED = X_DIST_CODE_CONCATENATED)
           OR ((tlinfo.DIST_CODE_CONCATENATED is null)
               AND (X_DIST_CODE_CONCATENATED is null)))
      AND ((tlinfo.DIST_CODE_COMBINATION_ID = X_DIST_CODE_COMBINATION_ID)
           OR ((tlinfo.DIST_CODE_COMBINATION_ID is null)
               AND (X_DIST_CODE_COMBINATION_ID is null)))
      AND ((tlinfo.AWT_GROUP_ID = X_AWT_GROUP_ID)
           OR ((tlinfo.AWT_GROUP_ID is null)
               AND (X_AWT_GROUP_ID is null)))
       AND ((tlinfo.PAY_AWT_GROUP_ID = X_PAY_AWT_GROUP_ID)
           OR ((tlinfo.PAY_AWT_GROUP_ID is null)
               AND (X_PAY_AWT_GROUP_ID is null)))       --bug6639866
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
      AND ((tlinfo.GLOBAL_ATTRIBUTE_CATEGORY = X_GLOBAL_ATTRIBUTE_CATEGORY)
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
      AND ((tlinfo.PO_RELEASE_ID = X_PO_RELEASE_ID)
           OR ((tlinfo.PO_RELEASE_ID is null)
               AND (X_PO_RELEASE_ID is null)))
      AND ((tlinfo.BALANCING_SEGMENT = X_BALANCING_SEGMENT)
           OR ((tlinfo.BALANCING_SEGMENT is null)
               AND (X_BALANCING_SEGMENT is null)))
      AND ((tlinfo.COST_CENTER_SEGMENT = X_COST_CENTER_SEGMENT)
           OR ((tlinfo.COST_CENTER_SEGMENT is null)
               AND (X_COST_CENTER_SEGMENT is null)))
      AND ((tlinfo.ACCOUNT_SEGMENT = X_ACCOUNT_SEGMENT)
           OR ((tlinfo.ACCOUNT_SEGMENT is null)
               AND (X_ACCOUNT_SEGMENT is null)))
      AND ((tlinfo.PROJECT_ID = X_PROJECT_ID)
           OR ((tlinfo.PROJECT_ID is null)
               AND (X_PROJECT_ID is null)))
      AND ((tlinfo.TASK_ID = X_TASK_ID)
           OR ((tlinfo.TASK_ID is null)
               AND (X_TASK_ID is null)))
      AND ((tlinfo.EXPENDITURE_TYPE = X_EXPENDITURE_TYPE)
           OR ((tlinfo.EXPENDITURE_TYPE is null)
               AND (X_EXPENDITURE_TYPE is null)))
      AND ((tlinfo.EXPENDITURE_ITEM_DATE = X_EXPENDITURE_ITEM_DATE)
           OR ((tlinfo.EXPENDITURE_ITEM_DATE is null)
               AND (X_EXPENDITURE_ITEM_DATE is null)))
      AND ((tlinfo.EXPENDITURE_ORGANIZATION_ID = X_EXPENDITURE_ORGANIZATION_ID)
           OR ((tlinfo.EXPENDITURE_ORGANIZATION_ID is null)
               AND (X_EXPENDITURE_ORGANIZATION_ID is null)))
      AND ((tlinfo.PROJECT_ACCOUNTING_CONTEXT = X_PROJECT_ACCOUNTING_CONTEXT)
           OR ((tlinfo.PROJECT_ACCOUNTING_CONTEXT is null)
               AND (X_PROJECT_ACCOUNTING_CONTEXT is null)))
      AND ((tlinfo.PA_ADDITION_FLAG = X_PA_ADDITION_FLAG)
           OR ((tlinfo.PA_ADDITION_FLAG is null)
               AND (X_PA_ADDITION_FLAG is null)))
      AND ((tlinfo.PA_QUANTITY = X_PA_QUANTITY)
           OR ((tlinfo.PA_QUANTITY is null)
               AND (X_PA_QUANTITY is null)))
      AND ((tlinfo.STAT_AMOUNT = X_STAT_AMOUNT)
           OR ((tlinfo.STAT_AMOUNT is null)
               AND (X_STAT_AMOUNT is null)))
      AND ((tlinfo.TYPE_1099 = X_TYPE_1099)
           OR ((tlinfo.TYPE_1099 is null)
               AND (X_TYPE_1099 is null)))
      AND ((tlinfo.INCOME_TAX_REGION = X_INCOME_TAX_REGION)
           OR ((tlinfo.INCOME_TAX_REGION is null)
               AND (X_INCOME_TAX_REGION is null)))
      AND ((tlinfo.ASSETS_TRACKING_FLAG = X_ASSETS_TRACKING_FLAG)
           OR ((tlinfo.ASSETS_TRACKING_FLAG is null)
               AND (X_ASSETS_TRACKING_FLAG is null)))
      AND ((tlinfo.PRICE_CORRECTION_FLAG = X_PRICE_CORRECTION_FLAG)
           OR ((tlinfo.PRICE_CORRECTION_FLAG is null)
               AND (X_PRICE_CORRECTION_FLAG is null)))
      AND ((tlinfo.PRICE_CORRECT_INV_NUM = X_PRICE_CORRECT_INV_NUM)
           OR ((tlinfo.PRICE_CORRECT_INV_NUM is null)
               AND (X_PRICE_CORRECT_INV_NUM is null)))
   -- Removed for bug 4277744
   -- AND ((tlinfo.USSGL_TRANSACTION_CODE = X_USSGL_TRANSACTION_CODE)
   --      OR ((tlinfo.USSGL_TRANSACTION_CODE is null)
   --          AND (X_USSGL_TRANSACTION_CODE is null)))
      AND ((tlinfo.RECEIPT_NUMBER = X_RECEIPT_NUMBER)
           OR ((tlinfo.RECEIPT_NUMBER is null)
               AND (X_RECEIPT_NUMBER is null)))
      AND ((tlinfo.MATCH_OPTION = X_MATCH_OPTION)
           OR ((tlinfo.MATCH_OPTION is null)
               AND (X_MATCH_OPTION is null)))
      AND ((tlinfo.AWARD_ID = X_AWARD_ID)
           OR ((tlinfo.AWARD_ID is null)
               AND (X_AWARD_ID is null)))
      AND ((tlinfo.RCV_TRANSACTION_ID = X_RCV_TRANSACTION_ID)
           OR ((tlinfo.RCV_TRANSACTION_ID is null)
               AND (X_RCV_TRANSACTION_ID is null)))
-- Invoice Lines Project Stage 1
      AND ((tlinfo.PRICE_CORRECT_INV_LINE_NUM = X_PRICE_CORRECT_INV_LINE_NUM)
           OR ((tlinfo.PRICE_CORRECT_INV_LINE_NUM is null)
               AND (X_PRICE_CORRECT_INV_LINE_NUM is null)))
      AND ((tlinfo.SERIAL_NUMBER = X_SERIAL_NUMBER)
           OR ((tlinfo.SERIAL_NUMBER is null)
               AND (X_SERIAL_NUMBER is null)))
      AND ((tlinfo.MANUFACTURER = X_MANUFACTURER)
           OR ((tlinfo.MANUFACTURER is null)
               AND (X_MANUFACTURER is null)))
      AND ((tlinfo.MODEL_NUMBER = X_MODEL_NUMBER)
           OR ((tlinfo.MODEL_NUMBER is null)
               AND (X_MODEL_NUMBER is null)))
      AND ((tlinfo.WARRANTY_NUMBER = X_WARRANTY_NUMBER)
           OR ((tlinfo.WARRANTY_NUMBER is null)
               AND (X_WARRANTY_NUMBER is null)))
      AND ((tlinfo.ASSET_BOOK_TYPE_CODE = X_ASSET_BOOK_TYPE_CODE)
           OR ((tlinfo.ASSET_BOOK_TYPE_CODE is null)
               AND (X_ASSET_BOOK_TYPE_CODE is null)))
      AND ((tlinfo.ASSET_CATEGORY_ID = X_ASSET_CATEGORY_ID)
           OR ((tlinfo.ASSET_CATEGORY_ID is null)
               AND (X_ASSET_CATEGORY_ID is null)))
      AND ((tlinfo.REQUESTER_FIRST_NAME = X_REQUESTER_FIRST_NAME)
           OR ((tlinfo.REQUESTER_FIRST_NAME is null)
               AND (X_REQUESTER_FIRST_NAME is null)))
      AND ((tlinfo.REQUESTER_LAST_NAME = X_REQUESTER_LAST_NAME)
           OR ((tlinfo.REQUESTER_LAST_NAME is null)
               AND (X_REQUESTER_LAST_NAME is null)))
      AND ((tlinfo.REQUESTER_EMPLOYEE_NUM = X_REQUESTER_EMPLOYEE_NUM)
           OR ((tlinfo.REQUESTER_EMPLOYEE_NUM is null)
               AND (X_REQUESTER_EMPLOYEE_NUM is null)))
      AND ((tlinfo.REQUESTER_ID = X_REQUESTER_ID)
           OR ((tlinfo.REQUESTER_ID is null)
               AND (X_REQUESTER_ID is null)))
      AND ((tlinfo.DEFERRED_ACCTG_FLAG = X_DEFERRED_ACCTG_FLAG)
           OR ((tlinfo.DEFERRED_ACCTG_FLAG is null)
               AND (X_DEFERRED_ACCTG_FLAG is null)))
      AND ((tlinfo.DEF_ACCTG_START_DATE = X_DEF_ACCTG_START_DATE)
           OR ((tlinfo.DEF_ACCTG_START_DATE is null)
               AND (X_DEF_ACCTG_START_DATE is null)))
      AND ((tlinfo.DEF_ACCTG_END_DATE = X_DEF_ACCTG_END_DATE)
           OR ((tlinfo.DEF_ACCTG_END_DATE is null)
               AND (X_DEF_ACCTG_END_DATE is null)))
      AND ((tlinfo.DEF_ACCTG_NUMBER_OF_PERIODS = X_DEF_ACCTG_NUMBER_OF_PERIODS)
           OR ((tlinfo.DEF_ACCTG_NUMBER_OF_PERIODS is null)
               AND (X_DEF_ACCTG_NUMBER_OF_PERIODS is null)))
      AND ((tlinfo.DEF_ACCTG_PERIOD_TYPE = X_DEF_ACCTG_PERIOD_TYPE)
           OR ((tlinfo.DEF_ACCTG_PERIOD_TYPE is null)
               AND (X_DEF_ACCTG_PERIOD_TYPE is null)))
      -- eTax Uptake
      AND ((tlinfo.CONTROL_AMOUNT = X_CONTROL_AMOUNT)
           OR ((tlinfo.CONTROL_AMOUNT is null)
               AND (X_CONTROL_AMOUNT is null)))
      AND ((tlinfo.ASSESSABLE_VALUE = X_ASSESSABLE_VALUE)
           OR ((tlinfo.ASSESSABLE_VALUE is null)
               AND (X_ASSESSABLE_VALUE is null)))
      AND ((tlinfo.DEFAULT_DIST_CCID = X_DEFAULT_DIST_CCID)
           OR ((tlinfo.DEFAULT_DIST_CCID is null)
               AND (X_DEFAULT_DIST_CCID is null)))
      AND ((tlinfo.PRIMARY_INTENDED_USE = X_PRIMARY_INTENDED_USE)
           OR ((tlinfo.PRIMARY_INTENDED_USE is null)
               AND (X_PRIMARY_INTENDED_USE is null)))
      AND ((tlinfo.SHIP_TO_LOCATION_ID = X_SHIP_TO_LOCATION_ID)
           OR ((tlinfo.SHIP_TO_LOCATION_ID is null)
               AND (X_SHIP_TO_LOCATION_ID is null)))
      AND ((tlinfo.PRODUCT_TYPE = X_PRODUCT_TYPE)
           OR ((tlinfo.PRODUCT_TYPE is null)
               AND (X_PRODUCT_TYPE is null)))
      AND ((tlinfo.PRODUCT_CATEGORY = X_PRODUCT_CATEGORY)
           OR ((tlinfo.PRODUCT_CATEGORY is null)
               AND (X_PRODUCT_CATEGORY is null)))
      AND ((tlinfo.PRODUCT_FISC_CLASSIFICATION = X_PRODUCT_FISC_CLASSIFICATION)
           OR ((tlinfo.PRODUCT_FISC_CLASSIFICATION is null)
               AND (X_PRODUCT_FISC_CLASSIFICATION is null)))
      AND ((tlinfo.USER_DEFINED_FISC_CLASS = X_USER_DEFINED_FISC_CLASS)
           OR ((tlinfo.USER_DEFINED_FISC_CLASS is null)
               AND (X_USER_DEFINED_FISC_CLASS is null)))
      AND ((tlinfo.TRX_BUSINESS_CATEGORY = X_TRX_BUSINESS_CATEGORY)
           OR ((tlinfo.TRX_BUSINESS_CATEGORY is null)
               AND (X_TRX_BUSINESS_CATEGORY is null)))
      AND ((tlinfo.TAX_REGIME_CODE = X_TAX_REGIME_CODE)
           OR ((tlinfo.TAX_REGIME_CODE is null)
               AND (X_TAX_REGIME_CODE is null)))
      AND ((tlinfo.TAX = X_TAX)
           OR ((tlinfo.TAX is null)
               AND (X_TAX is null)))
      AND ((tlinfo.TAX_JURISDICTION_CODE = X_TAX_JURISDICTION_CODE)
           OR ((tlinfo.TAX_JURISDICTION_CODE is null)
               AND (X_TAX_JURISDICTION_CODE is null)))
      AND ((tlinfo.TAX_STATUS_CODE = X_TAX_STATUS_CODE)
           OR ((tlinfo.TAX_STATUS_CODE is null)
               AND (X_TAX_STATUS_CODE is null)))
      AND ((tlinfo.TAX_RATE_ID = X_TAX_RATE_ID)
           OR ((tlinfo.TAX_RATE_ID is null)
               AND (X_TAX_RATE_ID is null)))
      AND ((tlinfo.TAX_RATE_CODE = X_TAX_RATE_CODE)
           OR ((tlinfo.TAX_RATE_CODE is null)
               AND (X_TAX_RATE_CODE is null)))
      AND ((tlinfo.TAX_RATE = X_TAX_RATE)
           OR ((tlinfo.TAX_RATE is null)
               AND (X_TAX_RATE is null)))
      AND ((tlinfo.INCL_IN_TAXABLE_LINE_FLAG = X_INCL_IN_TAXABLE_LINE_FLAG)
           OR ((tlinfo.INCL_IN_TAXABLE_LINE_FLAG is null)
               AND (X_INCL_IN_TAXABLE_LINE_FLAG is null)))
      AND ((tlinfo.PURCHASING_CATEGORY = X_PURCHASING_CATEGORY)
           OR ((tlinfo.PURCHASING_CATEGORY IS NULL)
	       AND (X_PURCHASING_CATEGORY IS NULL)))
      AND ((tlinfo.PURCHASING_CATEGORY_ID = X_PURCHASING_CATEGORY_ID)
           OR ((tlinfo.PURCHASING_CATEGORY_ID IS NULL)
	       AND (X_PURCHASING_CATEGORY_ID IS NULL)))
      AND ((tlinfo.COST_FACTOR_NAME = X_COST_FACTOR_NAME)
           OR ((tlinfo.COST_FACTOR_NAME IS NULL)
	       AND (X_COST_FACTOR_NAME IS NULL)))
      AND ((tlinfo.COST_FACTOR_ID = X_COST_FACTOR_ID)
           OR ((tlinfo.COST_FACTOR_ID IS NULL)
               AND (X_COST_FACTOR_ID IS NULL)))
      AND ((tlinfo.TAX_CLASSIFICATION_CODE = X_TAX_CLASSIFICATION_CODE)
           OR ((tlinfo.TAX_CLASSIFICATION_CODE IS NULL)
               AND (X_TAX_CLASSIFICATION_CODE IS NULL)))
) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;
  RETURN;
EXCEPTION
    WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        IF (SQLCODE = -54) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
        ELSE
          FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
        END IF;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
END LOCK_ROW;

procedure UPDATE_ROW (
          X_Rowid                        IN            VARCHAR2,
          X_INVOICE_ID                   IN            NUMBER,
          X_INVOICE_LINE_ID              IN            NUMBER,
          X_LINE_NUMBER                  IN            NUMBER,
          X_LINE_TYPE_LOOKUP_CODE        IN            VARCHAR2,
          X_LINE_GROUP_NUMBER            IN            NUMBER,
          X_AMOUNT                       IN            NUMBER,
          X_ACCOUNTING_DATE              IN            DATE,
          X_DESCRIPTION                  IN            VARCHAR2,
--          X_AMOUNT_INCLUDES_TAX_FLAG     IN            VARCHAR2,
          X_PRORATE_ACROSS_FLAG          IN            VARCHAR2,
          X_TAX_CODE                     IN            VARCHAR2,
          X_TAX_CODE_ID                  IN            NUMBER,
--          X_TAX_CODE_OVERRIDE_FLAG       IN            VARCHAR2,
--          X_TAX_RECOVERY_RATE            IN            NUMBER,
--          X_TAX_RECOVERY_OVERRIDE_FLAG   IN            VARCHAR2,
--          X_TAX_RECOVERABLE_FLAG         IN            VARCHAR2,
          X_FINAL_MATCH_FLAG             IN            VARCHAR2,
          X_PO_HEADER_ID                 IN            NUMBER,
          X_PO_LINE_ID                   IN            NUMBER,
          X_PO_LINE_LOCATION_ID          IN            NUMBER,
          X_PO_DISTRIBUTION_ID           IN            NUMBER,
          X_UNIT_OF_MEAS_LOOKUP_CODE     IN            VARCHAR2,
          X_INVENTORY_ITEM_ID            IN            NUMBER,
          X_QUANTITY_INVOICED            IN            NUMBER,
          X_UNIT_PRICE                   IN            NUMBER,
          X_DISTRIBUTION_SET_ID          IN            NUMBER,
          X_DIST_CODE_CONCATENATED       IN            VARCHAR2,
          X_DIST_CODE_COMBINATION_ID     IN            NUMBER,
          X_AWT_GROUP_ID                 IN            NUMBER,
          X_PAY_AWT_GROUP_ID             IN            NUMBER DEFAULT NULL,--bug6639866
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
          X_PO_RELEASE_ID                IN            NUMBER,
          X_BALANCING_SEGMENT            IN            VARCHAR2,
          X_COST_CENTER_SEGMENT          IN            VARCHAR2,
          X_ACCOUNT_SEGMENT              IN            VARCHAR2,
          X_PROJECT_ID                   IN            NUMBER,
          X_TASK_ID                      IN            NUMBER,
          X_EXPENDITURE_TYPE             IN            VARCHAR2,
          X_EXPENDITURE_ITEM_DATE        IN            DATE,
          X_EXPENDITURE_ORGANIZATION_ID  IN            NUMBER,
          X_PROJECT_ACCOUNTING_CONTEXT   IN            VARCHAR2,
          X_PA_ADDITION_FLAG             IN            VARCHAR2,
          X_PA_QUANTITY                  IN            NUMBER,
          X_STAT_AMOUNT                  IN            NUMBER,
          X_TYPE_1099                    IN            VARCHAR2,
          X_INCOME_TAX_REGION            IN            VARCHAR2,
          X_ASSETS_TRACKING_FLAG         IN            VARCHAR2,
          X_PRICE_CORRECTION_FLAG        IN            VARCHAR2,
       -- X_USSGL_TRANSACTION_CODE       IN            VARCHAR2, - Bug 4277744
          X_RECEIPT_NUMBER               IN            VARCHAR2,
          X_MATCH_OPTION                 IN            VARCHAR2,
          X_RCV_TRANSACTION_ID           IN            NUMBER,
          X_LAST_UPDATE_DATE             IN            DATE,
          X_LAST_UPDATED_BY              IN            NUMBER,
          X_LAST_UPDATE_LOGIN            IN            NUMBER,
          X_MODE                         IN            VARCHAR2 DEFAULT 'R',
          X_CALLING_SEQUENCE             IN            VARCHAR2,
          X_AWARD_ID                     IN            NUMBER,
          X_price_correct_inv_num        IN            VARCHAR2 DEFAULT NULL,
          -- Invoice Lines Project Stage 1
          X_PRICE_CORRECT_INV_LINE_NUM   IN            NUMBER   DEFAULT NULL,
          X_SERIAL_NUMBER                IN            VARCHAR2 DEFAULT NULL,
          X_MANUFACTURER                 IN            VARCHAR2 DEFAULT NULL,
          X_MODEL_NUMBER                 IN            VARCHAR2 DEFAULT NULL,
          X_WARRANTY_NUMBER              IN            VARCHAR2 DEFAULT NULL,
          X_ASSET_BOOK_TYPE_CODE         IN            VARCHAR2 DEFAULT NULL,
          X_ASSET_CATEGORY_ID            IN            NUMBER   DEFAULT NULL,
          X_REQUESTER_FIRST_NAME         IN            VARCHAR2 DEFAULT NULL,
          X_REQUESTER_LAST_NAME          IN            VARCHAR2 DEFAULT NULL,
          X_REQUESTER_EMPLOYEE_NUM       IN            VARCHAR2 DEFAULT NULL,
          X_REQUESTER_ID                 IN            NUMBER   DEFAULT NULL,
          X_DEFERRED_ACCTG_FLAG          IN            VARCHAR2 DEFAULT NULL,
          X_DEF_ACCTG_START_DATE         IN            DATE     DEFAULT NULL,
          X_DEF_ACCTG_END_DATE           IN            DATE     DEFAULT NULL,
          X_DEF_ACCTG_NUMBER_OF_PERIODS  IN            NUMBER   DEFAULT NULL,
          X_DEF_ACCTG_PERIOD_TYPE        IN            VARCHAR2 DEFAULT NULL,
	  -- eTax Uptake
	  X_CONTROL_AMOUNT		 IN            NUMBER   DEFAULT NULL,
	  X_ASSESSABLE_VALUE		 IN            NUMBER   DEFAULT NULL,
	  X_DEFAULT_DIST_CCID		 IN            NUMBER   DEFAULT NULL,
	  X_PRIMARY_INTENDED_USE	 IN            VARCHAR2 DEFAULT NULL,
	  X_SHIP_TO_LOCATION_ID		 IN            NUMBER   DEFAULT NULL,
	  X_PRODUCT_TYPE		 IN            VARCHAR2 DEFAULT NULL,
	  X_PRODUCT_CATEGORY		 IN            VARCHAR2 DEFAULT NULL,
	  X_PRODUCT_FISC_CLASSIFICATION  IN            VARCHAR2 DEFAULT NULL,
	  X_USER_DEFINED_FISC_CLASS	 IN            VARCHAR2 DEFAULT NULL,
	  X_TRX_BUSINESS_CATEGORY	 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_REGIME_CODE		 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX				 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_JURISDICTION_CODE	 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_STATUS_CODE		 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_RATE_ID			 IN            NUMBER   DEFAULT NULL,
	  X_TAX_RATE_CODE		 IN            VARCHAR2 DEFAULT NULL,
	  X_TAX_RATE			 IN            NUMBER   DEFAULT NULL,
	  X_INCL_IN_TAXABLE_LINE_FLAG	 IN            VARCHAR2 DEFAULT NULL,
	  X_PURCHASING_CATEGORY		 IN	       VARCHAR2 DEFAULT NULL,
	  X_PURCHASING_CATEGORY_ID       IN	       NUMBER   DEFAULT NULL,
	  X_COST_FACTOR_NAME		 IN	       VARCHAR2 DEFAULT NULL,
	  X_COST_FACTOR_ID		 IN 	       NUMBER   DEFAULT NULL,
          X_TAX_CLASSIFICATION_CODE      IN            VARCHAR2 DEFAULT NULL)
  IS

  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(100);

BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'AP_INVOICE_LINES_INTERFACE_PKG.Update_Row<-'
                              ||X_Calling_Sequence;

  debug_info := 'Update ap_invoice_lines_interface';

  UPDATE AP_INVOICE_LINES_INTERFACE SET
          INVOICE_ID                 = X_INVOICE_ID,
          INVOICE_LINE_ID            = X_INVOICE_LINE_ID,
          LINE_NUMBER                = X_LINE_NUMBER,
          LINE_TYPE_LOOKUP_CODE      = X_LINE_TYPE_LOOKUP_CODE,
          LINE_GROUP_NUMBER          = X_LINE_GROUP_NUMBER,
          AMOUNT                     = X_AMOUNT,
          ACCOUNTING_DATE            = X_ACCOUNTING_DATE,
          DESCRIPTION                = X_DESCRIPTION,
          -- AMOUNT_INCLUDES_TAX_FLAG   = X_AMOUNT_INCLUDES_TAX_FLAG,
          PRORATE_ACROSS_FLAG        = X_PRORATE_ACROSS_FLAG,
          TAX_CODE                   = X_TAX_CODE,
          TAX_CODE_ID                = X_TAX_CODE_ID,
          -- TAX_CODE_OVERRIDE_FLAG     = X_TAX_CODE_OVERRIDE_FLAG,
          -- TAX_RECOVERY_RATE          = X_TAX_RECOVERY_RATE,
          -- TAX_RECOVERY_OVERRIDE_FLAG = X_TAX_RECOVERY_OVERRIDE_FLAG,
          -- TAX_RECOVERABLE_FLAG       = X_TAX_RECOVERABLE_FLAG,
          FINAL_MATCH_FLAG           = X_FINAL_MATCH_FLAG,
          PO_HEADER_ID               = X_PO_HEADER_ID,
          PO_LINE_ID                 = X_PO_LINE_ID,
          PO_LINE_LOCATION_ID        = X_PO_LINE_LOCATION_ID,
          PO_DISTRIBUTION_ID         = X_PO_DISTRIBUTION_ID,
          UNIT_OF_MEAS_LOOKUP_CODE   = X_UNIT_OF_MEAS_LOOKUP_CODE,
          INVENTORY_ITEM_ID          = X_INVENTORY_ITEM_ID,
          QUANTITY_INVOICED          = X_QUANTITY_INVOICED,
          UNIT_PRICE                 = X_UNIT_PRICE,
          DISTRIBUTION_SET_ID        = X_DISTRIBUTION_SET_ID,
          DIST_CODE_CONCATENATED     = X_DIST_CODE_CONCATENATED,
          DIST_CODE_COMBINATION_ID   = X_DIST_CODE_COMBINATION_ID,
          AWT_GROUP_ID               = X_AWT_GROUP_ID,
          PAY_AWT_GROUP_ID           = X_PAY_AWT_GROUP_ID,--bug6639866
          ATTRIBUTE_CATEGORY         = X_ATTRIBUTE_CATEGORY,
          ATTRIBUTE1                 = X_ATTRIBUTE1,
          ATTRIBUTE2                 = X_ATTRIBUTE2,
          ATTRIBUTE3                 = X_ATTRIBUTE3,
          ATTRIBUTE4                 = X_ATTRIBUTE4,
          ATTRIBUTE5                 = X_ATTRIBUTE5,
          ATTRIBUTE6                 = X_ATTRIBUTE6,
          ATTRIBUTE7                 = X_ATTRIBUTE7,
          ATTRIBUTE8                 = X_ATTRIBUTE8,
          ATTRIBUTE9                 = X_ATTRIBUTE9,
          ATTRIBUTE10                = X_ATTRIBUTE10,
          ATTRIBUTE11                = X_ATTRIBUTE11,
          ATTRIBUTE12                = X_ATTRIBUTE12,
          ATTRIBUTE13                = X_ATTRIBUTE13,
          ATTRIBUTE14                = X_ATTRIBUTE14,
          ATTRIBUTE15                = X_ATTRIBUTE15,
          GLOBAL_ATTRIBUTE_CATEGORY  = X_GLOBAL_ATTRIBUTE_CATEGORY,
          GLOBAL_ATTRIBUTE1          = X_GLOBAL_ATTRIBUTE1,
          GLOBAL_ATTRIBUTE2          = X_GLOBAL_ATTRIBUTE2,
          GLOBAL_ATTRIBUTE3          = X_GLOBAL_ATTRIBUTE3,
          GLOBAL_ATTRIBUTE4          = X_GLOBAL_ATTRIBUTE4,
          GLOBAL_ATTRIBUTE5          = X_GLOBAL_ATTRIBUTE5,
          GLOBAL_ATTRIBUTE6          = X_GLOBAL_ATTRIBUTE6,
          GLOBAL_ATTRIBUTE7          = X_GLOBAL_ATTRIBUTE7,
          GLOBAL_ATTRIBUTE8          = X_GLOBAL_ATTRIBUTE8,
          GLOBAL_ATTRIBUTE9          = X_GLOBAL_ATTRIBUTE9,
          GLOBAL_ATTRIBUTE10         = X_GLOBAL_ATTRIBUTE10,
          GLOBAL_ATTRIBUTE11         = X_GLOBAL_ATTRIBUTE11,
          GLOBAL_ATTRIBUTE12         = X_GLOBAL_ATTRIBUTE12,
          GLOBAL_ATTRIBUTE13         = X_GLOBAL_ATTRIBUTE13,
          GLOBAL_ATTRIBUTE14         = X_GLOBAL_ATTRIBUTE14,
          GLOBAL_ATTRIBUTE15         = X_GLOBAL_ATTRIBUTE15,
          GLOBAL_ATTRIBUTE16         = X_GLOBAL_ATTRIBUTE16,
          GLOBAL_ATTRIBUTE17         = X_GLOBAL_ATTRIBUTE17,
          GLOBAL_ATTRIBUTE18         = X_GLOBAL_ATTRIBUTE18,
          GLOBAL_ATTRIBUTE19         = X_GLOBAL_ATTRIBUTE19,
          GLOBAL_ATTRIBUTE20         = X_GLOBAL_ATTRIBUTE20,
          PO_RELEASE_ID              = X_PO_RELEASE_ID,
          BALANCING_SEGMENT          = X_BALANCING_SEGMENT,
          COST_CENTER_SEGMENT        = X_COST_CENTER_SEGMENT,
          ACCOUNT_SEGMENT            = X_ACCOUNT_SEGMENT,
          PROJECT_ID                 = X_PROJECT_ID,
          TASK_ID                    = X_TASK_ID,
          EXPENDITURE_TYPE           = X_EXPENDITURE_TYPE,
          EXPENDITURE_ITEM_DATE      = X_EXPENDITURE_ITEM_DATE,
          EXPENDITURE_ORGANIZATION_ID= X_EXPENDITURE_ORGANIZATION_ID,
          PROJECT_ACCOUNTING_CONTEXT = X_PROJECT_ACCOUNTING_CONTEXT,
          PA_ADDITION_FLAG           = X_PA_ADDITION_FLAG,
          PA_QUANTITY                = X_PA_QUANTITY,
          STAT_AMOUNT                = X_STAT_AMOUNT,
          TYPE_1099                  = X_TYPE_1099,
          INCOME_TAX_REGION          = X_INCOME_TAX_REGION,
          ASSETS_TRACKING_FLAG       = X_ASSETS_TRACKING_FLAG,
          PRICE_CORRECTION_FLAG      = X_PRICE_CORRECTION_FLAG,
       -- USSGL_TRANSACTION_CODE     = X_USSGL_TRANSACTION_CODE, - Bug 4277744
          RECEIPT_NUMBER             = X_RECEIPT_NUMBER,
          MATCH_OPTION               = X_MATCH_OPTION,
          RCV_TRANSACTION_ID         = X_RCV_TRANSACTION_ID,
          LAST_UPDATE_DATE           = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY            = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN          = X_LAST_UPDATE_LOGIN,
          AWARD_ID                   = X_AWARD_ID,
          PRICE_CORRECT_INV_NUM      = X_PRICE_CORRECT_INV_NUM,
          -- Invoice Lines Project Stage 1
          PRICE_CORRECT_INV_LINE_NUM = X_PRICE_CORRECT_INV_LINE_NUM,
          SERIAL_NUMBER              = X_SERIAL_NUMBER,
          MANUFACTURER               = X_MANUFACTURER,
          MODEL_NUMBER               = X_MODEL_NUMBER,
          WARRANTY_NUMBER            = X_WARRANTY_NUMBER,
          ASSET_BOOK_TYPE_CODE       = X_ASSET_BOOK_TYPE_CODE,
          ASSET_CATEGORY_ID          = X_ASSET_CATEGORY_ID,
          REQUESTER_FIRST_NAME       = X_REQUESTER_FIRST_NAME,
          REQUESTER_LAST_NAME        = X_REQUESTER_LAST_NAME,
          REQUESTER_EMPLOYEE_NUM     = X_REQUESTER_EMPLOYEE_NUM,
          REQUESTER_ID               = X_REQUESTER_ID,
          DEFERRED_ACCTG_FLAG        = X_DEFERRED_ACCTG_FLAG,
          DEF_ACCTG_START_DATE       = X_DEF_ACCTG_START_DATE,
          DEF_ACCTG_END_DATE         = X_DEF_ACCTG_END_DATE,
          DEF_ACCTG_NUMBER_OF_PERIODS= X_DEF_ACCTG_NUMBER_OF_PERIODS,
          DEF_ACCTG_PERIOD_TYPE      = X_DEF_ACCTG_PERIOD_TYPE,
	  -- eTax Uptake
	  CONTROL_AMOUNT	     = X_CONTROL_AMOUNT,
	  ASSESSABLE_VALUE	     = X_ASSESSABLE_VALUE,
	  DEFAULT_DIST_CCID	     = X_DEFAULT_DIST_CCID,
	  PRIMARY_INTENDED_USE	     = X_PRIMARY_INTENDED_USE,
	  SHIP_TO_LOCATION_ID	     = X_SHIP_TO_LOCATION_ID,
	  PRODUCT_TYPE		     = X_PRODUCT_TYPE,
	  PRODUCT_CATEGORY	     = X_PRODUCT_CATEGORY,
	  PRODUCT_FISC_CLASSIFICATION = X_PRODUCT_FISC_CLASSIFICATION,
	  USER_DEFINED_FISC_CLASS    = X_USER_DEFINED_FISC_CLASS,
	  TRX_BUSINESS_CATEGORY	     = X_TRX_BUSINESS_CATEGORY,
	  TAX_REGIME_CODE	     = X_TAX_REGIME_CODE,
	  TAX			     = X_TAX,
	  TAX_JURISDICTION_CODE	     = X_TAX_JURISDICTION_CODE,
	  TAX_STATUS_CODE	     = X_TAX_STATUS_CODE,
	  TAX_RATE_ID		     = X_TAX_RATE_ID,
	  TAX_RATE_CODE		     = X_TAX_RATE_CODE,
	  TAX_RATE		     = X_TAX_RATE,
	  INCL_IN_TAXABLE_LINE_FLAG  = X_INCL_IN_TAXABLE_LINE_FLAG,
	  PURCHASING_CATEGORY	     = X_PURCHASING_CATEGORY,
	  PURCHASING_CATEGORY_ID     = X_PURCHASING_CATEGORY_ID,
	  COST_FACTOR_NAME	     = X_COST_FACTOR_NAME,
	  COST_FACTOR_ID	     = X_COST_FACTOR_ID,
	  TAX_CLASSIFICATION_CODE    = X_TAX_CLASSIFICATION_CODE
          WHERE rowid                = X_Rowid;

  IF (sql%notfound) THEN
    Raise no_data_found;
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
END UPDATE_ROW;


PROCEDURE Delete_Row(
          X_INVOICE_LINE_ID         NUMBER,
          X_Calling_Sequence        VARCHAR2)
  IS
  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(100);

BEGIN

  -- Update the calling sequence

  current_calling_sequence := 'AP_INVOICE_LINES_INTERFACE_PKG.Delete_Row<-'
                              ||X_Calling_Sequence;

  -- Bug 2496745. Deleting the rejections for this invoice line.

  debug_info := 'Delete from ap_interface_rejections';

  DELETE FROM AP_INTERFACE_REJECTIONS
   WHERE parent_id    = X_invoice_line_id
     AND parent_table = 'AP_INVOICE_LINES_INTERFACE';

  debug_info := 'Delete from ap_invoice_lines_interface';

  DELETE FROM AP_INVOICE_LINES_INTERFACE
   WHERE invoice_line_id = X_invoice_line_id;

  IF (SQL%NOTFOUND) THEN
    Raise NO_DATA_FOUND;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Delete_Row;

END AP_INVOICE_LINES_INTERFACE_PKG;

/
