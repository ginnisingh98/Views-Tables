--------------------------------------------------------
--  DDL for Package Body AP_AIL_TABLE_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_AIL_TABLE_HANDLER_PKG" as
/* $Header: apilnthb.pls 120.13.12010000.2 2010/05/14 11:15:59 asansari ship $ */

-------------------------------------------------------------------
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_AIL_TABLE_HANDLER_PKG';
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
G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_AIL_TABLE_HANDLER_PKG.';

PROCEDURE CHECK_UNIQUE (
          P_ROWID                    VARCHAR2,
          P_INVOICE_ID               NUMBER,
          P_LINE_NUMBER              NUMBER,
          P_CALLING_SEQUENCE         VARCHAR2)
  IS
  dummy number := 0;
  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(100);

BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'AP_AIL_TABLE_HANDLER_PKG.CHECK_UNIQUE<-'
                              ||p_Calling_Sequence;

  debug_info := 'Select from ap_invoice_lines_all';

  SELECT COUNT(1)
    INTO dummy
    FROM ap_invoice_Lines_all
   where (invoice_id  = p_INVOICE_ID AND
          line_number = p_LINE_NUMBER)
     AND  ((p_ROWID is null) OR
           (rowid <> p_ROWID));

  IF (dummy >= 1) THEN
     fnd_message.set_name('SQLAP','AP_ALL_DUPLICATE_VALUE');
     app_exception.raise_exception;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Rowid = '||p_ROWID
             ||', Invoice Id = '||p_INVOICE_ID
             ||', Invoice line number = '||
             p_line_number);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END CHECK_UNIQUE;


PROCEDURE Insert_Row  (
          p_ROWID             IN OUT NOCOPY VARCHAR2,
          p_INVOICE_ID                      NUMBER,
          p_LINE_NUMBER                     NUMBER,
          p_LINE_TYPE_LOOKUP_CODE           VARCHAR2,
          p_LINE_GROUP_NUMBER               NUMBER,
          p_REQUESTER_ID                    NUMBER,
          p_DESCRIPTION                     VARCHAR2,
          p_LINE_SOURCE                     VARCHAR2,
          p_ORG_ID                          NUMBER,
          p_INVENTORY_ITEM_ID               NUMBER,
          p_ITEM_DESCRIPTION                VARCHAR2,
          p_SERIAL_NUMBER                   VARCHAR2,
          p_MANUFACTURER                    VARCHAR2,
          p_MODEL_NUMBER                    VARCHAR2,
          p_WARRANTY_NUMBER                 VARCHAR2,
          p_GENERATE_DISTS                  VARCHAR2,
          p_MATCH_TYPE                      VARCHAR2,
          p_DISTRIBUTION_SET_ID             NUMBER,
          p_ACCOUNT_SEGMENT                 VARCHAR2,
          p_BALANCING_SEGMENT               VARCHAR2,
          p_COST_CENTER_SEGMENT             VARCHAR2,
          p_OVERLAY_DIST_CODE_CONCAT        VARCHAR2,
          p_DEFAULT_DIST_CCID               NUMBER,
          p_PRORATE_ACROSS_ALL_ITEMS        VARCHAR2,
          p_ACCOUNTING_DATE                 DATE,
          p_PERIOD_NAME                     VARCHAR2,
          p_DEFERRED_ACCTG_FLAG             VARCHAR2,
          p_DEF_ACCTG_START_DATE            DATE,
          p_DEF_ACCTG_END_DATE              DATE,
          p_DEF_ACCTG_NUMBER_OF_PERIODS     NUMBER,
          p_DEF_ACCTG_PERIOD_TYPE           VARCHAR2,
          p_SET_OF_BOOKS_ID                 NUMBER,
          p_AMOUNT                          NUMBER,
          p_BASE_AMOUNT                     NUMBER,
          p_ROUNDING_AMT                    NUMBER,
          p_QUANTITY_INVOICED               NUMBER,
          p_UNIT_MEAS_LOOKUP_CODE           VARCHAR2,
          p_UNIT_PRICE                      NUMBER,
          p_WFAPPROVAL_STATUS               VARCHAR2,
          p_DISCARDED_FLAG                  VARCHAR2,
          p_ORIGINAL_AMOUNT                 NUMBER,
          p_ORIGINAL_BASE_AMOUNT            NUMBER,
          p_ORIGINAL_ROUNDING_AMT           NUMBER,
          p_CANCELLED_FLAG                  VARCHAR2,
          p_INCOME_TAX_REGION               VARCHAR2,
          p_TYPE_1099                       VARCHAR2,
          p_STAT_AMOUNT                     NUMBER,
          p_PREPAY_INVOICE_ID               NUMBER,
          p_PREPAY_LINE_NUMBER              NUMBER,
          p_INVOICE_INCLUDES_PREPAY_FLAG    VARCHAR2,
          p_CORRECTED_INV_ID                NUMBER,
          p_CORRECTED_LINE_NUMBER           NUMBER,
          p_PO_HEADER_ID                    NUMBER,
          p_PO_LINE_ID                      NUMBER,
          p_PO_RELEASE_ID                   NUMBER,
          p_PO_LINE_LOCATION_ID             NUMBER,
          p_PO_DISTRIBUTION_ID              NUMBER,
          p_RCV_TRANSACTION_ID              NUMBER,
          p_FINAL_MATCH_FLAG                VARCHAR2,
          p_ASSETS_TRACKING_FLAG            VARCHAR2,
          p_ASSET_BOOK_TYPE_CODE            VARCHAR2,
          p_ASSET_CATEGORY_ID               NUMBER,
          p_PROJECT_ID                      NUMBER,
          p_TASK_ID                         NUMBER,
          p_EXPENDITURE_TYPE                VARCHAR2,
          p_EXPENDITURE_ITEM_DATE           DATE,
          p_EXPENDITURE_ORGANIZATION_ID     NUMBER,
          p_PA_QUANTITY                     NUMBER,
          p_PA_CC_AR_INVOICE_ID             NUMBER,
          p_PA_CC_AR_INVOICE_LINE_NUM       NUMBER,
          p_PA_CC_PROCESSED_CODE            VARCHAR2,
          p_AWARD_ID                        NUMBER,
          p_AWT_GROUP_ID                    NUMBER,
          p_PAY_AWT_GROUP_ID                    NUMBER,--bug6639866
          p_REFERENCE_1                     VARCHAR2,
          p_REFERENCE_2                     VARCHAR2,
          p_RECEIPT_VERIFIED_FLAG           VARCHAR2,
          p_RECEIPT_REQUIRED_FLAG           VARCHAR2,
          p_RECEIPT_MISSING_FLAG            VARCHAR2,
          p_JUSTIFICATION                   VARCHAR2,
          p_EXPENSE_GROUP                   VARCHAR2,
          p_START_EXPENSE_DATE              DATE,
          p_END_EXPENSE_DATE                DATE,
          p_RECEIPT_CURRENCY_CODE           VARCHAR2,
          p_RECEIPT_CONVERSION_RATE         NUMBER,
          p_RECEIPT_CURRENCY_AMOUNT         NUMBER,
          p_DAILY_AMOUNT                    NUMBER,
          p_WEB_PARAMETER_ID                NUMBER,
          p_ADJUSTMENT_REASON               VARCHAR2,
          p_MERCHANT_DOCUMENT_NUMBER        VARCHAR2,
          p_MERCHANT_NAME                   VARCHAR2,
          p_MERCHANT_REFERENCE              VARCHAR2,
          p_MERCHANT_TAX_REG_NUMBER         VARCHAR2,
          p_MERCHANT_TAXPAYER_ID            VARCHAR2,
          p_COUNTRY_OF_SUPPLY               VARCHAR2,
          p_CREDIT_CARD_TRX_ID              NUMBER,
          p_COMPANY_PREPAID_INVOICE_ID      NUMBER,
          p_CC_REVERSAL_FLAG                VARCHAR2,
          p_CREATION_DATE                   DATE,
          p_CREATED_BY                      NUMBER,
          p_LAST_UPDATED_BY                 NUMBER,
          p_LAST_UPDATE_DATE                DATE,
          p_LAST_UPDATE_LOGIN               NUMBER,
          p_PROGRAM_APPLICATION_ID          NUMBER,
          p_PROGRAM_ID                      NUMBER,
          p_PROGRAM_UPDATE_DATE             DATE,
          p_REQUEST_ID                      NUMBER,
          p_ATTRIBUTE_CATEGORY              VARCHAR2,
          p_ATTRIBUTE1                      VARCHAR2,
          p_ATTRIBUTE2                      VARCHAR2,
          p_ATTRIBUTE3                      VARCHAR2,
          p_ATTRIBUTE4                      VARCHAR2,
          p_ATTRIBUTE5                      VARCHAR2,
          p_ATTRIBUTE6                      VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE7                      VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE8                      VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE9                      VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE10                     VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE11                     VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE12                     VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE13                     VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE14                     VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE15                     VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE_CATEGORY       VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE1               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE2               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE3               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE4               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE5               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE6               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE7               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE8               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE9               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE10              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE11              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE12              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE13              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE14              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE15              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE16              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE17              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE18              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE19              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE20              VARCHAR2 DEFAULT NULL,
	  --ETAX: Invwkb
	  p_PRIMARY_INTENDED_USE            VARCHAR2  DEFAULT NULL,
	  p_SHIP_TO_LOCATION_ID             NUMBER    DEFAULT NULL,
	  p_PRODUCT_FISC_CLASSIFICATION     VARCHAR2  DEFAULT NULL,
	  p_USER_DEFINED_FISC_CLASS         VARCHAR2  DEFAULT NULL,
	  p_TRX_BUSINESS_CATEGORY           VARCHAR2  DEFAULT NULL,
	  p_PRODUCT_TYPE                    VARCHAR2  DEFAULT NULL,
	  p_PRODUCT_CATEGORY                VARCHAR2  DEFAULT NULL,
	  p_ASSESSABLE_VALUE                NUMBER    DEFAULT NULL,
	  p_CONTROL_AMOUNT                  NUMBER    DEFAULT NULL,
	  p_TAX_REGIME_CODE                 VARCHAR2  DEFAULT NULL,
	  p_TAX                             VARCHAR2  DEFAULT NULL,
	  p_TAX_STATUS_CODE                 VARCHAR2  DEFAULT NULL,
	  p_TAX_RATE_CODE                   VARCHAR2  DEFAULT NULL,
	  p_TAX_RATE_ID                     NUMBER    DEFAULT NULL,
	  p_TAX_RATE                        NUMBER    DEFAULT NULL,
	  p_TAX_JURISDICTION_CODE           VARCHAR2  DEFAULT NULL,
	  p_PURCHASING_CATEGORY_ID	    NUMBER    DEFAULT NULL,
	  p_COST_FACTOR_ID		    NUMBER    DEFAULT NULL,
          p_RETAINED_AMOUNT		    NUMBER    DEFAULT NULL,
	  p_RETAINED_INVOICE_ID		    NUMBER    DEFAULT NULL,
	  p_RETAINED_LINE_NUMBER	    NUMBER    DEFAULT NULL,
	  p_TAX_CLASSIFICATION_CODE	    VARCHAR2  DEFAULT NULL,
          p_Calling_Sequence                VARCHAR2)
  IS
  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(100);
  l_dist_match_type        VARCHAR2(25);
  CURSOR C IS
  SELECT rowid
    FROM AP_INVOICE_LINES_ALL
   WHERE invoice_id  = p_Invoice_Id
     AND line_number = p_Line_Number;

BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'AP_AIL_TABLE_HANDLER_PKG.Insert_Row<-'
                              ||p_Calling_Sequence;

  -- Check for uniqueness of the distribution line number

  AP_AIL_TABLE_HANDLER_PKG.CHECK_UNIQUE(
          p_Rowid,
          p_Invoice_Id,
          p_Line_Number,
          'AP_AIL_TABLE_HANDLER_PKG.Insert_Row');

  -- Figure out NOCOPY the dist_match_type (not passed from invoice w/b)

  IF (p_rcv_transaction_id IS NOT NULL AND
      p_po_distribution_id IS NOT NULL) THEN
        l_dist_match_type := 'ITEM_TO_RECEIPT';
  ELSIF (p_rcv_transaction_id IS NOT NULL AND
         p_po_distribution_id IS NULL) THEN
        l_dist_match_type := 'OTHER_TO_RECEIPT';
  ELSIF (p_rcv_transaction_id IS NULL AND
        p_po_distribution_id IS NOT NULL) THEN
        l_dist_match_type := 'ITEM_TO_PO';
  ELSE
        l_dist_match_type := NULL;
  END IF;

  debug_info := 'Insert into ap_invoice_lines_all';

  INSERT INTO AP_INVOICE_LINES_ALL(
          INVOICE_ID               ,
          LINE_NUMBER              ,
          LINE_TYPE_LOOKUP_CODE    ,
          LINE_GROUP_NUMBER        ,
          REQUESTER_ID             ,
          DESCRIPTION              ,
          LINE_SOURCE              ,
          ORG_ID            ,
          INVENTORY_ITEM_ID        ,
          ITEM_DESCRIPTION         ,
          SERIAL_NUMBER            ,
          MANUFACTURER             ,
          MODEL_NUMBER             ,
          WARRANTY_NUMBER          ,
          GENERATE_DISTS           ,
          MATCH_TYPE               ,
          DISTRIBUTION_SET_ID      ,
          ACCOUNT_SEGMENT          ,
          BALANCING_SEGMENT        ,
          COST_CENTER_SEGMENT      ,
          OVERLAY_DIST_CODE_CONCAT ,
          DEFAULT_DIST_CCID        ,
          PRORATE_ACROSS_ALL_ITEMS ,
          ACCOUNTING_DATE          ,
          PERIOD_NAME              ,
          DEFERRED_ACCTG_FLAG      ,
          DEF_ACCTG_START_DATE      ,
          DEF_ACCTG_END_DATE        ,
          DEF_ACCTG_NUMBER_OF_PERIODS,
          DEF_ACCTG_PERIOD_TYPE    ,
          SET_OF_BOOKS_ID          ,
          AMOUNT            ,
          BASE_AMOUNT              ,
          ROUNDING_AMT             ,
          QUANTITY_INVOICED        ,
          UNIT_MEAS_LOOKUP_CODE    ,
          UNIT_PRICE               ,
          WFAPPROVAL_STATUS        ,
          DISCARDED_FLAG           ,
          ORIGINAL_AMOUNT          ,
          ORIGINAL_BASE_AMOUNT     ,
          ORIGINAL_ROUNDING_AMT    ,
          CANCELLED_FLAG           ,
          INCOME_TAX_REGION        ,
          TYPE_1099                ,
          STAT_AMOUNT              ,
          PREPAY_INVOICE_ID        ,
          PREPAY_LINE_NUMBER       ,
          INVOICE_INCLUDES_PREPAY_FLAG,
          CORRECTED_INV_ID         ,
          CORRECTED_LINE_NUMBER    ,
          PO_HEADER_ID             ,
          PO_LINE_ID               ,
          PO_RELEASE_ID            ,
          PO_LINE_LOCATION_ID      ,
          PO_DISTRIBUTION_ID       ,
          RCV_TRANSACTION_ID       ,
          FINAL_MATCH_FLAG         ,
          ASSETS_TRACKING_FLAG     ,
          ASSET_BOOK_TYPE_CODE     ,
          ASSET_CATEGORY_ID        ,
          PROJECT_ID               ,
          TASK_ID           ,
          EXPENDITURE_TYPE         ,
          EXPENDITURE_ITEM_DATE    ,
          EXPENDITURE_ORGANIZATION_ID,
          PA_QUANTITY              ,
          PA_CC_AR_INVOICE_ID      ,
          PA_CC_AR_INVOICE_LINE_NUM,
          PA_CC_PROCESSED_CODE     ,
          AWARD_ID          ,
          AWT_GROUP_ID             ,
          PAY_AWT_GROUP_ID         ,--bug6639866
          REFERENCE_1              ,
          REFERENCE_2              ,
          RECEIPT_VERIFIED_FLAG    ,
          RECEIPT_REQUIRED_FLAG    ,
          RECEIPT_MISSING_FLAG     ,
          JUSTIFICATION            ,
          EXPENSE_GROUP            ,
          START_EXPENSE_DATE       ,
          END_EXPENSE_DATE         ,
          RECEIPT_CURRENCY_CODE    ,
          RECEIPT_CONVERSION_RATE  ,
          RECEIPT_CURRENCY_AMOUNT  ,
          DAILY_AMOUNT             ,
          WEB_PARAMETER_ID         ,
          ADJUSTMENT_REASON        ,
          MERCHANT_DOCUMENT_NUMBER ,
          MERCHANT_NAME            ,
          MERCHANT_REFERENCE       ,
          MERCHANT_TAX_REG_NUMBER  ,
          MERCHANT_TAXPAYER_ID     ,
          COUNTRY_OF_SUPPLY        ,
          CREDIT_CARD_TRX_ID       ,
          COMPANY_PREPAID_INVOICE_ID,
          CC_REVERSAL_FLAG         ,
          CREATION_DATE            ,
          CREATED_BY               ,
          LAST_UPDATED_BY          ,
          LAST_UPDATE_DATE         ,
          LAST_UPDATE_LOGIN        ,
          PROGRAM_APPLICATION_ID   ,
          PROGRAM_ID               ,
          PROGRAM_UPDATE_DATE      ,
          REQUEST_ID               ,
          ATTRIBUTE_CATEGORY       ,
          ATTRIBUTE1               ,
          ATTRIBUTE2               ,
          ATTRIBUTE3               ,
          ATTRIBUTE4               ,
          ATTRIBUTE5               ,
          ATTRIBUTE6               ,
          ATTRIBUTE7               ,
          ATTRIBUTE8               ,
          ATTRIBUTE9               ,
          ATTRIBUTE10              ,
          ATTRIBUTE11              ,
          ATTRIBUTE12              ,
          ATTRIBUTE13              ,
          ATTRIBUTE14              ,
          ATTRIBUTE15              ,
          GLOBAL_ATTRIBUTE_CATEGORY,
          GLOBAL_ATTRIBUTE1        ,
          GLOBAL_ATTRIBUTE2        ,
          GLOBAL_ATTRIBUTE3        ,
          GLOBAL_ATTRIBUTE4        ,
          GLOBAL_ATTRIBUTE5        ,
          GLOBAL_ATTRIBUTE6        ,
          GLOBAL_ATTRIBUTE7        ,
          GLOBAL_ATTRIBUTE8        ,
          GLOBAL_ATTRIBUTE9        ,
          GLOBAL_ATTRIBUTE10       ,
          GLOBAL_ATTRIBUTE11       ,
          GLOBAL_ATTRIBUTE12       ,
          GLOBAL_ATTRIBUTE13       ,
          GLOBAL_ATTRIBUTE14       ,
          GLOBAL_ATTRIBUTE15       ,
          GLOBAL_ATTRIBUTE16       ,
          GLOBAL_ATTRIBUTE17       ,
          GLOBAL_ATTRIBUTE18       ,
          GLOBAL_ATTRIBUTE19       ,
          GLOBAL_ATTRIBUTE20       ,
	  PRIMARY_INTENDED_USE     ,
	  SHIP_TO_LOCATION_ID      ,
	  PRODUCT_FISC_CLASSIFICATION,
	  USER_DEFINED_FISC_CLASS  ,
	  TRX_BUSINESS_CATEGORY    ,
	  PRODUCT_TYPE		   ,
	  PRODUCT_CATEGORY         ,
	  ASSESSABLE_VALUE	   ,
	  CONTROL_AMOUNT	   ,
	  TAX_REGIME_CODE	   ,
	  TAX			   ,
	  TAX_STATUS_CODE	   ,
	  TAX_RATE_CODE		   ,
	  TAX_RATE_ID		   ,
	  TAX_RATE		   ,
	  TAX_JURISDICTION_CODE	   ,
	  PURCHASING_CATEGORY_ID   ,
	  COST_FACTOR_ID	   ,
	  RETAINED_AMOUNT	   ,
	  RETAINED_AMOUNT_REMAINING,
	  RETAINED_INVOICE_ID	   ,
	  RETAINED_LINE_NUMBER	   ,
	  TAX_CLASSIFICATION_CODE
	  )
  VALUES (
          p_INVOICE_ID               ,
          p_LINE_NUMBER              ,
          p_LINE_TYPE_LOOKUP_CODE    ,
          p_LINE_GROUP_NUMBER        ,
          p_REQUESTER_ID             ,
          p_DESCRIPTION              ,
          p_LINE_SOURCE              ,
          p_ORG_ID            ,
          p_INVENTORY_ITEM_ID        ,
          p_ITEM_DESCRIPTION         ,
          p_SERIAL_NUMBER            ,
          p_MANUFACTURER             ,
          p_MODEL_NUMBER             ,
          p_WARRANTY_NUMBER          ,
          p_GENERATE_DISTS           ,
          p_MATCH_TYPE               ,
          p_DISTRIBUTION_SET_ID      ,
          p_ACCOUNT_SEGMENT          ,
          p_BALANCING_SEGMENT        ,
          p_COST_CENTER_SEGMENT      ,
          p_OVERLAY_DIST_CODE_CONCAT ,
          p_DEFAULT_DIST_CCID        ,
          p_PRORATE_ACROSS_ALL_ITEMS ,
          p_ACCOUNTING_DATE          ,
          p_PERIOD_NAME              ,
          p_DEFERRED_ACCTG_FLAG      ,
          p_DEF_ACCTG_START_DATE     ,
          p_DEF_ACCTG_END_DATE       ,
          p_DEF_ACCTG_NUMBER_OF_PERIODS,
          p_DEF_ACCTG_PERIOD_TYPE    ,
          p_SET_OF_BOOKS_ID          ,
          p_AMOUNT            ,
          p_BASE_AMOUNT              ,
          p_ROUNDING_AMT             ,
          p_QUANTITY_INVOICED        ,
          p_UNIT_MEAS_LOOKUP_CODE    ,
          p_UNIT_PRICE               ,
          p_WFAPPROVAL_STATUS        ,
          p_DISCARDED_FLAG           ,
          p_ORIGINAL_AMOUNT          ,
          p_ORIGINAL_BASE_AMOUNT     ,
          p_ORIGINAL_ROUNDING_AMT    ,
          p_CANCELLED_FLAG           ,
          p_INCOME_TAX_REGION        ,
          p_TYPE_1099                ,
          p_STAT_AMOUNT              ,
          p_PREPAY_INVOICE_ID        ,
          p_PREPAY_LINE_NUMBER       ,
          p_INVOICE_INCLUDES_PREPAY_FLAG,
          p_CORRECTED_INV_ID         ,
          p_CORRECTED_LINE_NUMBER    ,
          p_PO_HEADER_ID             ,
          p_PO_LINE_ID               ,
          p_PO_RELEASE_ID            ,
          p_PO_LINE_LOCATION_ID      ,
          p_PO_DISTRIBUTION_ID       ,
          p_RCV_TRANSACTION_ID       ,
          p_FINAL_MATCH_FLAG         ,
          p_ASSETS_TRACKING_FLAG     ,
          p_ASSET_BOOK_TYPE_CODE     ,
          p_ASSET_CATEGORY_ID        ,
          p_PROJECT_ID               ,
          p_TASK_ID           ,
          p_EXPENDITURE_TYPE         ,
          p_EXPENDITURE_ITEM_DATE    ,
          p_EXPENDITURE_ORGANIZATION_ID,
          p_PA_QUANTITY              ,
          p_PA_CC_AR_INVOICE_ID      ,
          p_PA_CC_AR_INVOICE_LINE_NUM,
          p_PA_CC_PROCESSED_CODE     ,
          p_AWARD_ID          ,
          p_AWT_GROUP_ID             ,
          p_PAY_AWT_GROUP_ID             ,--bug6639866
          p_REFERENCE_1              ,
          p_REFERENCE_2              ,
          p_RECEIPT_VERIFIED_FLAG    ,
          p_RECEIPT_REQUIRED_FLAG    ,
          p_RECEIPT_MISSING_FLAG     ,
          p_JUSTIFICATION            ,
          p_EXPENSE_GROUP            ,
          p_START_EXPENSE_DATE       ,
          p_END_EXPENSE_DATE         ,
          p_RECEIPT_CURRENCY_CODE    ,
          p_RECEIPT_CONVERSION_RATE  ,
          p_RECEIPT_CURRENCY_AMOUNT  ,
          p_DAILY_AMOUNT             ,
          p_WEB_PARAMETER_ID         ,
          p_ADJUSTMENT_REASON        ,
          p_MERCHANT_DOCUMENT_NUMBER ,
          p_MERCHANT_NAME            ,
          p_MERCHANT_REFERENCE       ,
          p_MERCHANT_TAX_REG_NUMBER  ,
          p_MERCHANT_TAXPAYER_ID     ,
          p_COUNTRY_OF_SUPPLY        ,
          p_CREDIT_CARD_TRX_ID       ,
          p_COMPANY_PREPAID_INVOICE_ID,
          p_CC_REVERSAL_FLAG         ,
          p_CREATION_DATE            ,
          p_CREATED_BY               ,
          p_LAST_UPDATED_BY          ,
          p_LAST_UPDATE_DATE         ,
          p_LAST_UPDATE_LOGIN        ,
          p_PROGRAM_APPLICATION_ID   ,
          p_PROGRAM_ID               ,
          p_PROGRAM_UPDATE_DATE      ,
          p_REQUEST_ID               ,
          p_ATTRIBUTE_CATEGORY       ,
          p_ATTRIBUTE1               ,
          p_ATTRIBUTE2               ,
          p_ATTRIBUTE3               ,
          p_ATTRIBUTE4               ,
          p_ATTRIBUTE5               ,
          p_ATTRIBUTE6               ,
          p_ATTRIBUTE7               ,
          p_ATTRIBUTE8               ,
          p_ATTRIBUTE9               ,
          p_ATTRIBUTE10              ,
          p_ATTRIBUTE11              ,
          p_ATTRIBUTE12              ,
          p_ATTRIBUTE13              ,
          p_ATTRIBUTE14              ,
          p_ATTRIBUTE15              ,
          p_GLOBAL_ATTRIBUTE_CATEGORY,
          p_GLOBAL_ATTRIBUTE1        ,
          p_GLOBAL_ATTRIBUTE2        ,
          p_GLOBAL_ATTRIBUTE3        ,
          p_GLOBAL_ATTRIBUTE4        ,
          p_GLOBAL_ATTRIBUTE5        ,
          p_GLOBAL_ATTRIBUTE6        ,
          p_GLOBAL_ATTRIBUTE7        ,
          p_GLOBAL_ATTRIBUTE8        ,
          p_GLOBAL_ATTRIBUTE9        ,
          p_GLOBAL_ATTRIBUTE10       ,
          p_GLOBAL_ATTRIBUTE11       ,
          p_GLOBAL_ATTRIBUTE12       ,
          p_GLOBAL_ATTRIBUTE13       ,
          p_GLOBAL_ATTRIBUTE14       ,
          p_GLOBAL_ATTRIBUTE15       ,
          p_GLOBAL_ATTRIBUTE16       ,
          p_GLOBAL_ATTRIBUTE17       ,
          p_GLOBAL_ATTRIBUTE18       ,
          p_GLOBAL_ATTRIBUTE19       ,
          p_GLOBAL_ATTRIBUTE20       ,
	  p_PRIMARY_INTENDED_USE     ,
	  p_SHIP_TO_LOCATION_ID      ,
	  p_PRODUCT_FISC_CLASSIFICATION,
	  p_USER_DEFINED_FISC_CLASS  ,
	  p_TRX_BUSINESS_CATEGORY    ,
	  p_PRODUCT_TYPE             ,
	  p_PRODUCT_CATEGORY         ,
	  p_ASSESSABLE_VALUE         ,
	  p_CONTROL_AMOUNT           ,
	  p_TAX_REGIME_CODE          ,
	  p_TAX                      ,
	  p_TAX_STATUS_CODE          ,
	  p_TAX_RATE_CODE            ,
	  p_TAX_RATE_ID              ,
	  p_TAX_RATE                 ,
	  p_TAX_JURISDICTION_CODE    ,
	  p_PURCHASING_CATEGORY_ID   ,
	  p_COST_FACTOR_ID	     ,
          p_RETAINED_AMOUNT	     ,
	  -(p_RETAINED_AMOUNT)       ,
	  p_RETAINED_INVOICE_ID	     ,
	  p_RETAINED_LINE_NUMBER     ,
	  p_TAX_CLASSIFICATION_CODE  );

  debug_info := 'Open cursor C';
  OPEN C;
  debug_info := 'Fetch cursor C';
  FETCH C INTO p_Rowid;
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

  END Insert_Row;


PROCEDURE Lock_Row(
          p_ROWID                           VARCHAR2,
          p_INVOICE_ID                      NUMBER,
          p_LINE_NUMBER                     NUMBER,
          p_LINE_TYPE_LOOKUP_CODE           VARCHAR2,
          p_LINE_GROUP_NUMBER               NUMBER,
          p_REQUESTER_ID                    NUMBER,
          p_DESCRIPTION                     VARCHAR2,
          p_LINE_SOURCE                     VARCHAR2,
          p_ORG_ID                          NUMBER,
          p_INVENTORY_ITEM_ID               NUMBER,
          p_ITEM_DESCRIPTION                VARCHAR2,
          p_SERIAL_NUMBER                   VARCHAR2,
          p_MANUFACTURER                    VARCHAR2,
          p_MODEL_NUMBER                    VARCHAR2,
          p_WARRANTY_NUMBER                 VARCHAR2,
          p_GENERATE_DISTS                  VARCHAR2,
          p_MATCH_TYPE                      VARCHAR2,
          p_DISTRIBUTION_SET_ID             NUMBER,
          p_ACCOUNT_SEGMENT                 VARCHAR2,
          p_BALANCING_SEGMENT               VARCHAR2,
          p_COST_CENTER_SEGMENT             VARCHAR2,
          p_OVERLAY_DIST_CODE_CONCAT        VARCHAR2,
          p_DEFAULT_DIST_CCID               NUMBER,
          p_PRORATE_ACROSS_ALL_ITEMS        VARCHAR2,
          p_ACCOUNTING_DATE                 DATE,
          p_PERIOD_NAME                     VARCHAR2,
          p_DEFERRED_ACCTG_FLAG             VARCHAR2,
          p_DEF_ACCTG_START_DATE            DATE,
          p_DEF_ACCTG_END_DATE              DATE,
          p_DEF_ACCTG_NUMBER_OF_PERIODS     NUMBER,
          p_DEF_ACCTG_PERIOD_TYPE           VARCHAR2,
          p_SET_OF_BOOKS_ID                 NUMBER,
          p_AMOUNT                          NUMBER,
          p_BASE_AMOUNT                     NUMBER,
          p_ROUNDING_AMT                    NUMBER,
          p_QUANTITY_INVOICED               NUMBER,
          p_UNIT_MEAS_LOOKUP_CODE           VARCHAR2,
          p_UNIT_PRICE                      NUMBER,
          p_WFAPPROVAL_STATUS               VARCHAR2,
          p_DISCARDED_FLAG                  VARCHAR2,
          p_ORIGINAL_AMOUNT                 NUMBER,
          p_ORIGINAL_BASE_AMOUNT            NUMBER,
          p_ORIGINAL_ROUNDING_AMT           NUMBER,
          p_CANCELLED_FLAG                  VARCHAR2,
          p_INCOME_TAX_REGION               VARCHAR2,
          p_TYPE_1099                       VARCHAR2,
          p_STAT_AMOUNT                     NUMBER,
          p_PREPAY_INVOICE_ID               NUMBER,
          p_PREPAY_LINE_NUMBER              NUMBER,
          p_INVOICE_INCLUDES_PREPAY_FLAG    VARCHAR2,
          p_CORRECTED_INV_ID                NUMBER,
          p_CORRECTED_LINE_NUMBER           NUMBER,
          p_PO_HEADER_ID                    NUMBER,
          p_PO_LINE_ID                      NUMBER,
          p_PO_RELEASE_ID                   NUMBER,
          p_PO_LINE_LOCATION_ID             NUMBER,
          p_PO_DISTRIBUTION_ID              NUMBER,
          p_RCV_TRANSACTION_ID              NUMBER,
          p_FINAL_MATCH_FLAG                VARCHAR2,
          p_ASSETS_TRACKING_FLAG            VARCHAR2,
          p_ASSET_BOOK_TYPE_CODE            VARCHAR2,
          p_ASSET_CATEGORY_ID               NUMBER,
          p_PROJECT_ID                      NUMBER,
          p_TASK_ID                         NUMBER,
          p_EXPENDITURE_TYPE                VARCHAR2,
          p_EXPENDITURE_ITEM_DATE           DATE,
          p_EXPENDITURE_ORGANIZATION_ID     NUMBER,
          p_PA_QUANTITY                     NUMBER,
          p_PA_CC_AR_INVOICE_ID             NUMBER,
          p_PA_CC_AR_INVOICE_LINE_NUM       NUMBER,
          p_PA_CC_PROCESSED_CODE            VARCHAR2,
          p_AWARD_ID                        NUMBER,
          p_AWT_GROUP_ID                    NUMBER,
          p_PAY_AWT_GROUP_ID                NUMBER,--bug6639866
          p_REFERENCE_1                     VARCHAR2,
          p_REFERENCE_2                     VARCHAR2,
          p_RECEIPT_VERIFIED_FLAG           VARCHAR2,
          p_RECEIPT_REQUIRED_FLAG           VARCHAR2,
          p_RECEIPT_MISSING_FLAG            VARCHAR2,
          p_JUSTIFICATION                   VARCHAR2,
          p_EXPENSE_GROUP                   VARCHAR2,
          p_START_EXPENSE_DATE              DATE,
          p_END_EXPENSE_DATE                DATE,
          p_RECEIPT_CURRENCY_CODE           VARCHAR2,
          p_RECEIPT_CONVERSION_RATE         NUMBER,
          p_RECEIPT_CURRENCY_AMOUNT         NUMBER,
          p_DAILY_AMOUNT                    NUMBER,
          p_WEB_PARAMETER_ID                NUMBER,
          p_ADJUSTMENT_REASON               VARCHAR2,
          p_MERCHANT_DOCUMENT_NUMBER        VARCHAR2,
          p_MERCHANT_NAME                   VARCHAR2,
          p_MERCHANT_REFERENCE              VARCHAR2,
          p_MERCHANT_TAX_REG_NUMBER         VARCHAR2,
          p_MERCHANT_TAXPAYER_ID            VARCHAR2,
          p_COUNTRY_OF_SUPPLY               VARCHAR2,
          p_CREDIT_CARD_TRX_ID              NUMBER,
          p_COMPANY_PREPAID_INVOICE_ID      NUMBER,
          p_CC_REVERSAL_FLAG                VARCHAR2,
          p_CREATION_DATE                   DATE,
          p_CREATED_BY                      NUMBER,
          p_LAST_UPDATED_BY                 NUMBER,
          p_LAST_UPDATE_DATE                DATE,
          p_LAST_UPDATE_LOGIN               NUMBER,
          p_PROGRAM_APPLICATION_ID          NUMBER,
          p_PROGRAM_ID                      NUMBER,
          p_PROGRAM_UPDATE_DATE             DATE,
          p_REQUEST_ID                      NUMBER,
          p_ATTRIBUTE_CATEGORY              VARCHAR2,
          p_ATTRIBUTE1                      VARCHAR2,
          p_ATTRIBUTE2                      VARCHAR2,
          p_ATTRIBUTE3                      VARCHAR2,
          p_ATTRIBUTE4                      VARCHAR2,
          p_ATTRIBUTE5                      VARCHAR2,
          p_ATTRIBUTE6                      VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE7                      VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE8                      VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE9                      VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE10                     VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE11                     VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE12                     VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE13                     VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE14                     VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE15                     VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE_CATEGORY       VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE1               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE2               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE3               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE4               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE5               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE6               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE7               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE8               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE9               VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE10              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE11              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE12              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE13              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE14              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE15              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE16              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE17              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE18              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE19              VARCHAR2 DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE20              VARCHAR2 DEFAULT NULL,
	  p_PRIMARY_INTENDED_USE            VARCHAR2  DEFAULT NULL,
	  p_SHIP_TO_LOCATION_ID             NUMBER    DEFAULT NULL,
	  p_PRODUCT_FISC_CLASSIFICATION     VARCHAR2  DEFAULT NULL,
	  p_USER_DEFINED_FISC_CLASS         VARCHAR2  DEFAULT NULL,
	  p_TRX_BUSINESS_CATEGORY           VARCHAR2  DEFAULT NULL,
	  p_PRODUCT_TYPE                    VARCHAR2  DEFAULT NULL,
	  p_PRODUCT_CATEGORY                VARCHAR2  DEFAULT NULL,
	  p_ASSESSABLE_VALUE                NUMBER    DEFAULT NULL,
	  p_CONTROL_AMOUNT                  NUMBER    DEFAULT NULL,
	  p_TAX_REGIME_CODE                 VARCHAR2  DEFAULT NULL,
	  p_TAX                             VARCHAR2  DEFAULT NULL,
	  p_TAX_STATUS_CODE                 VARCHAR2  DEFAULT NULL,
	  p_TAX_RATE_CODE                   VARCHAR2  DEFAULT NULL,
	  p_TAX_RATE_ID                     NUMBER    DEFAULT NULL,
	  p_TAX_RATE                        NUMBER    DEFAULT NULL,
	  p_TAX_JURISDICTION_CODE           VARCHAR2  DEFAULT NULL,
	  p_PURCHASING_CATEGORY_ID	    NUMBER    DEFAULT NULL,
	  p_COST_FACTOR_ID		    NUMBER    DEFAULT NULL,
          p_RETAINED_AMOUNT		    NUMBER    DEFAULT NULL,
	  p_RETAINED_INVOICE_ID		    NUMBER    DEFAULT NULL,
	  p_RETAINED_LINE_NUMBER	    NUMBER    DEFAULT NULL,
	  p_TAX_CLASSIFICATION_CODE	    VARCHAR2  DEFAULT NULL,
          p_Calling_Sequence                VARCHAR2)
  IS
  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(100);
  CURSOR C IS
  SELECT
          INVOICE_ID               ,
          LINE_NUMBER              ,
          LINE_TYPE_LOOKUP_CODE    ,
          LINE_GROUP_NUMBER        ,
          REQUESTER_ID             ,
          DESCRIPTION              ,
          LINE_SOURCE              ,
          ORG_ID            ,
          INVENTORY_ITEM_ID        ,
          ITEM_DESCRIPTION         ,
          SERIAL_NUMBER            ,
          MANUFACTURER             ,
          MODEL_NUMBER             ,
          WARRANTY_NUMBER          ,
          GENERATE_DISTS           ,
          MATCH_TYPE               ,
          DISTRIBUTION_SET_ID      ,
          ACCOUNT_SEGMENT          ,
          BALANCING_SEGMENT        ,
          COST_CENTER_SEGMENT      ,
          OVERLAY_DIST_CODE_CONCAT ,
          DEFAULT_DIST_CCID        ,
          PRORATE_ACROSS_ALL_ITEMS ,
          ACCOUNTING_DATE          ,
          PERIOD_NAME              ,
          DEFERRED_ACCTG_FLAG      ,
          DEF_ACCTG_START_DATE      ,
          DEF_ACCTG_END_DATE        ,
          DEF_ACCTG_NUMBER_OF_PERIODS,
          DEF_ACCTG_PERIOD_TYPE    ,
          SET_OF_BOOKS_ID          ,
          AMOUNT            ,
          BASE_AMOUNT              ,
          ROUNDING_AMT             ,
          QUANTITY_INVOICED        ,
          UNIT_MEAS_LOOKUP_CODE    ,
          UNIT_PRICE               ,
          WFAPPROVAL_STATUS        ,
          DISCARDED_FLAG           ,
          ORIGINAL_AMOUNT          ,
          ORIGINAL_BASE_AMOUNT     ,
          ORIGINAL_ROUNDING_AMT    ,
          CANCELLED_FLAG           ,
          INCOME_TAX_REGION        ,
          TYPE_1099                ,
          STAT_AMOUNT              ,
          PREPAY_INVOICE_ID        ,
          PREPAY_LINE_NUMBER       ,
          INVOICE_INCLUDES_PREPAY_FLAG,
          CORRECTED_INV_ID         ,
          CORRECTED_LINE_NUMBER    ,
          PO_HEADER_ID             ,
          PO_LINE_ID               ,
          PO_RELEASE_ID            ,
          PO_LINE_LOCATION_ID      ,
          PO_DISTRIBUTION_ID       ,
          RCV_TRANSACTION_ID       ,
          FINAL_MATCH_FLAG         ,
          ASSETS_TRACKING_FLAG     ,
          ASSET_BOOK_TYPE_CODE     ,
          ASSET_CATEGORY_ID        ,
          PROJECT_ID               ,
          TASK_ID           ,
          EXPENDITURE_TYPE         ,
          EXPENDITURE_ITEM_DATE    ,
          EXPENDITURE_ORGANIZATION_ID,
          PA_QUANTITY              ,
          PA_CC_AR_INVOICE_ID      ,
          PA_CC_AR_INVOICE_LINE_NUM,
          PA_CC_PROCESSED_CODE     ,
          AWARD_ID          ,
          AWT_GROUP_ID             ,
          PAY_AWT_GROUP_ID         ,--bug6639866
          REFERENCE_1              ,
          REFERENCE_2              ,
          RECEIPT_VERIFIED_FLAG    ,
          RECEIPT_REQUIRED_FLAG    ,
          RECEIPT_MISSING_FLAG     ,
          JUSTIFICATION            ,
          EXPENSE_GROUP            ,
          START_EXPENSE_DATE       ,
          END_EXPENSE_DATE         ,
          RECEIPT_CURRENCY_CODE    ,
          RECEIPT_CONVERSION_RATE  ,
          RECEIPT_CURRENCY_AMOUNT  ,
          DAILY_AMOUNT             ,
          WEB_PARAMETER_ID         ,
          ADJUSTMENT_REASON        ,
          MERCHANT_DOCUMENT_NUMBER ,
          MERCHANT_NAME            ,
          MERCHANT_REFERENCE       ,
          MERCHANT_TAX_REG_NUMBER  ,
          MERCHANT_TAXPAYER_ID     ,
          COUNTRY_OF_SUPPLY        ,
          CREDIT_CARD_TRX_ID       ,
          COMPANY_PREPAID_INVOICE_ID,
          CC_REVERSAL_FLAG         ,
          CREATION_DATE            ,
          CREATED_BY               ,
          LAST_UPDATED_BY          ,
          LAST_UPDATE_DATE         ,
          LAST_UPDATE_LOGIN        ,
          PROGRAM_APPLICATION_ID   ,
          PROGRAM_ID               ,
          PROGRAM_UPDATE_DATE      ,
          REQUEST_ID               ,
          ATTRIBUTE_CATEGORY       ,
          ATTRIBUTE1               ,
          ATTRIBUTE2               ,
          ATTRIBUTE3               ,
          ATTRIBUTE4               ,
          ATTRIBUTE5               ,
          ATTRIBUTE6               ,
          ATTRIBUTE7               ,
          ATTRIBUTE8               ,
          ATTRIBUTE9               ,
          ATTRIBUTE10              ,
          ATTRIBUTE11              ,
          ATTRIBUTE12              ,
          ATTRIBUTE13              ,
          ATTRIBUTE14              ,
          ATTRIBUTE15              ,
          GLOBAL_ATTRIBUTE_CATEGORY,
          GLOBAL_ATTRIBUTE1        ,
          GLOBAL_ATTRIBUTE2        ,
          GLOBAL_ATTRIBUTE3        ,
          GLOBAL_ATTRIBUTE4        ,
          GLOBAL_ATTRIBUTE5        ,
          GLOBAL_ATTRIBUTE6        ,
          GLOBAL_ATTRIBUTE7        ,
          GLOBAL_ATTRIBUTE8        ,
          GLOBAL_ATTRIBUTE9        ,
          GLOBAL_ATTRIBUTE10       ,
          GLOBAL_ATTRIBUTE11       ,
          GLOBAL_ATTRIBUTE12       ,
          GLOBAL_ATTRIBUTE13       ,
          GLOBAL_ATTRIBUTE14       ,
          GLOBAL_ATTRIBUTE15       ,
          GLOBAL_ATTRIBUTE16       ,
          GLOBAL_ATTRIBUTE17       ,
          GLOBAL_ATTRIBUTE18       ,
          GLOBAL_ATTRIBUTE19       ,
          GLOBAL_ATTRIBUTE20       ,
	  PRIMARY_INTENDED_USE     ,
	  SHIP_TO_LOCATION_ID      ,
	  PRODUCT_FISC_CLASSIFICATION,
	  USER_DEFINED_FISC_CLASS  ,
	  TRX_BUSINESS_CATEGORY    ,
	  PRODUCT_TYPE             ,
	  PRODUCT_CATEGORY         ,
	  ASSESSABLE_VALUE         ,
	  CONTROL_AMOUNT           ,
	  TAX_REGIME_CODE          ,
	  TAX                      ,
	  TAX_STATUS_CODE          ,
	  TAX_RATE_CODE            ,
	  TAX_RATE_ID              ,
	  TAX_RATE                 ,
	  TAX_JURISDICTION_CODE    ,
	  PURCHASING_CATEGORY_ID   ,
	  COST_FACTOR_ID           ,
	  RETAINED_AMOUNT	   ,
	  RETAINED_INVOICE_ID	   ,
	  RETAINED_LINE_NUMBER	   ,
	  TAX_CLASSIFICATION_CODE
    FROM  AP_INVOICE_LINES_ALL
   WHERE  rowid = P_Rowid
     FOR  UPDATE of Invoice_Id NOWAIT;
 Recinfo  C%ROWTYPE;

BEGIN

  -- Update the calling sequence
  --
  current_calling_sequence := 'AP_INVOICE_LINES_PKG.Lock_Row<-'
                             ||P_Calling_Sequence;

  debug_info := 'Select from ap_invoice_lines_all';
  OPEN C;

  debug_info := 'Fetch cursor C';
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) THEN
    debug_info := 'Close cursor C - ROW NOTFOUND';
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.Raise_Exception;
  END IF;
  debug_info := 'Close cursor C';
  CLOSE C;
  IF (       (Recinfo.invoice_id          =  P_Invoice_Id)
           AND (Recinfo.line_number         =  P_Line_Number)
           AND (Recinfo.accounting_date     =  P_Accounting_Date)
           AND (Recinfo.wfapproval_status   =  P_Wfapproval_Status)
           AND (Recinfo.amount              =  P_Amount)
           AND (Recinfo.org_id              =  P_org_id)
           AND (Recinfo.set_of_books_id     =  P_Set_Of_Books_Id)
           AND (   (Recinfo.type_1099 =  P_Type_1099)
                OR (    (Recinfo.type_1099 IS NULL)
                    AND (P_Type_1099 IS NULL)))
           AND (   (Recinfo.quantity_invoiced =  P_Quantity_Invoiced)
                OR (    (Recinfo.quantity_invoiced IS NULL)
                    AND (P_Quantity_Invoiced IS NULL)))
           AND (   (Recinfo.unit_price =  P_Unit_Price)
                OR (    (Recinfo.unit_price IS NULL)
                    AND (P_Unit_Price IS NULL)))
           AND (   (Recinfo.attribute_category =  P_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (P_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  P_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (P_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  P_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (P_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  P_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (P_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  P_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (P_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  P_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (P_Attribute5 IS NULL)))
          AND (   (Recinfo.PO_HEADER_ID =  P_PO_HEADER_ID)
                OR (    (Recinfo.PO_HEADER_ID IS NULL)
                    AND (P_PO_HEADER_ID IS NULL)))
          AND (   (Recinfo.PO_LINE_ID =  P_PO_LINE_ID)
                OR (    (Recinfo.PO_LINE_ID IS NULL)
                    AND (P_PO_LINE_ID IS NULL)))
          AND (   (Recinfo.PO_RELEASE_ID =  P_PO_RELEASE_ID)
                OR (    (Recinfo.PO_RELEASE_ID IS NULL)
                    AND (P_PO_RELEASE_ID IS NULL)))
          AND (   (Recinfo.PO_LINE_LOCATION_ID =  P_PO_LINE_LOCATION_ID)
                OR (    (Recinfo.PO_LINE_LOCATION_ID IS NULL)
                    AND (P_PO_LINE_LOCATION_ID IS NULL)))
          AND (   (Recinfo.PO_DISTRIBUTION_ID =  P_PO_DISTRIBUTION_ID)
                OR (    (Recinfo.PO_DISTRIBUTION_ID IS NULL)
                    AND (P_PO_DISTRIBUTION_ID IS NULL)))
          AND (   (Recinfo.RCV_TRANSACTION_ID =  P_RCV_TRANSACTION_ID)
                OR (    (Recinfo.RCV_TRANSACTION_ID IS NULL)
                    AND (P_RCV_TRANSACTION_ID IS NULL)))
           AND (   (Recinfo.base_amount =  P_Base_Amount)
                OR (    (Recinfo.base_amount IS NULL)
                    AND (P_Base_Amount IS NULL)))
           AND (   (Recinfo.stat_amount =  P_Stat_Amount)
                OR (    (Recinfo.stat_amount IS NULL)
                    AND (P_Stat_Amount IS NULL)))
           AND (   (Recinfo.attribute11 =  P_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (P_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  P_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (P_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  P_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (P_Attribute13 IS NULL)))) THEN
    NULL;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;
  END IF;
  IF (
               (   (Recinfo.attribute14 =  P_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (P_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute6 =  P_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (P_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  P_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (P_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  P_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (P_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  P_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (P_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  P_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (P_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute15 =  P_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (P_Attribute15 IS NULL)))
           AND (   (Recinfo.income_tax_region =  P_Income_Tax_Region)
                OR (    (Recinfo.income_tax_region IS NULL)
                    AND (P_Income_Tax_Region IS NULL)))
           AND (   (Recinfo.final_match_flag =  P_Final_Match_Flag)
                OR (    (Recinfo.final_match_flag IS NULL)
                    AND (P_Final_Match_Flag IS NULL)))
           AND (   (Recinfo.assets_tracking_flag =  P_assets_tracking_flag)
                OR (    (Recinfo.assets_tracking_flag IS NULL)
                    AND (P_assets_tracking_Flag IS NULL)))
           AND (   (Recinfo.asset_book_type_code =  P_asset_book_type_code)
                OR (    (Recinfo.asset_book_type_code IS NULL)
                    AND (P_asset_book_type_code IS NULL)))
           AND (   (Recinfo.asset_category_id =  P_asset_category_id)
                OR (    (Recinfo.asset_category_id IS NULL)
                    AND (P_asset_category_id IS NULL)))
           AND (   (Recinfo.expenditure_item_date =  P_Expenditure_Item_Date)
                OR (    (Recinfo.expenditure_item_date IS NULL)
                    AND (P_Expenditure_Item_Date IS NULL)))
           AND (   (Recinfo.expenditure_organization_id
                                 =  P_Expenditure_Organization_Id)
                OR (    (Recinfo.expenditure_organization_id IS NULL)
                    AND (P_Expenditure_Organization_Id IS NULL)))
           AND (   (Recinfo.expenditure_type =  P_Expenditure_Type)
                OR (    (Recinfo.expenditure_type IS NULL)
                    AND (P_Expenditure_Type IS NULL)))
           AND (   (Recinfo.project_id =  P_Project_Id)
                OR (    (Recinfo.project_id IS NULL)
                    AND (P_Project_Id IS NULL)))
           AND (   (Recinfo.task_id =  P_Task_Id)
                OR (    (Recinfo.task_id IS NULL)
                    AND (P_Task_Id IS NULL)))
           AND (   (Recinfo.pa_quantity =  P_Pa_Quantity)
                OR (    (Recinfo.pa_quantity IS NULL)
                    AND (P_Pa_Quantity IS NULL)))
           AND (   (Recinfo.awt_group_id =  P_Awt_Group_Id)
                OR (    (Recinfo.awt_group_id IS NULL)
                    AND (P_Awt_Group_Id IS NULL)))
            AND (   (Recinfo.pay_awt_group_id =  P_Pay_Awt_Group_Id)
                OR (    (Recinfo.pay_awt_group_id IS NULL)
                    AND (P_Pay_Awt_Group_Id IS NULL)))      --bug6639866
           AND (   (Recinfo.reference_1 =  P_Reference_1)
                OR (    (Recinfo.reference_1 IS NULL)
                    AND (P_Reference_1 IS NULL)))
           AND (   (Recinfo.reference_2 =  P_Reference_2)
                OR (    (Recinfo.reference_2 IS NULL)
                    AND (P_Reference_2 IS NULL)))
           AND (   (Recinfo.program_application_id = P_Program_Application_Id)
                OR (    (Recinfo.program_application_id IS NULL)
                    AND (P_Program_Application_id IS NULL)))
           AND (   (Recinfo.program_id = P_Program_Id)
                OR (    (Recinfo.program_id IS NULL)
                    AND (P_Program_Id IS NULL)))
           AND (   (Recinfo.program_update_date = P_Program_Update_Date)
                OR (    (Recinfo.program_update_date IS NULL)
                    AND (P_Program_Update_Date IS NULL)))
           AND (   (Recinfo.request_id = P_Request_Id)
                OR (    (Recinfo.request_id IS NULL)
                    AND (P_Request_Id IS NULL)))
           AND (    (Recinfo.award_id = P_Award_Id)
                OR (    (Recinfo.award_id IS NULL)
                     AND (P_Award_Id IS NULL)))
           AND (    (Recinfo.Expense_Group = P_Expense_Group)
                OR (    (Recinfo.Expense_Group IS NULL)
                     AND (P_Expense_Group IS NULL)))
           AND (    (Recinfo.start_expense_date = P_Start_Expense_Date)
                OR (    (Recinfo.start_expense_date IS NULL)
                     AND (P_Start_Expense_Date IS NULL)))
          AND (   (Recinfo.End_Expense_Date =  P_End_Expense_Date)
                OR (    (Recinfo.End_Expense_Date IS NULL)
                    AND (P_End_Expense_Date IS NULL)))
           AND (    (Recinfo.merchant_document_number
                                       = P_Merchant_Document_Number)
                OR (    (Recinfo.merchant_document_number IS NULL)
                     AND (P_Merchant_Document_Number IS NULL)))
           AND (    (Recinfo.merchant_name = P_Merchant_Name)
                OR (    (Recinfo.merchant_name IS NULL)
                     AND (P_Merchant_Name IS NULL)))
           AND (    (Recinfo.merchant_tax_reg_number
                                  = P_Merchant_Tax_Reg_Number)
                OR (    (Recinfo.merchant_tax_reg_number IS NULL)
                     AND (P_Merchant_Tax_Reg_Number IS NULL)))
           AND (    (Recinfo.merchant_taxpayer_id = P_Merchant_Taxpayer_Id)
                OR (    (Recinfo.merchant_taxpayer_id IS NULL)
                     AND (P_Merchant_Taxpayer_Id IS NULL)))
           AND (    (Recinfo.merchant_reference = P_Merchant_Reference)
                OR (    (Recinfo.merchant_reference IS NULL)
                     AND (P_Merchant_Reference IS NULL)))
           AND (    (Recinfo.country_of_supply = P_Country_Of_Supply)
                OR (    (Recinfo.country_of_supply IS NULL)
                     AND (P_Country_Of_Supply IS NULL)))) THEN
    NULL;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;
  END IF;
  IF (
               (   (Recinfo.global_attribute_category =
                                       P_global_attribute_category)
                OR (    (Recinfo.global_attribute_category IS NULL)
                    AND (P_global_attribute_category IS NULL)))
           AND (   (Recinfo.global_attribute1 =  P_global_attribute1)
                OR (    (Recinfo.global_attribute1 IS NULL)
                    AND (P_global_attribute1 IS NULL)))
           AND (   (Recinfo.global_attribute2 =  P_global_attribute2)
                OR (    (Recinfo.global_attribute2 IS NULL)
                    AND (P_global_attribute2 IS NULL)))
           AND (   (Recinfo.global_attribute3 =  P_global_attribute3)
                OR (    (Recinfo.global_attribute3 IS NULL)
                    AND (P_global_attribute3 IS NULL)))
           AND (   (Recinfo.global_attribute4 =  P_global_attribute4)
                OR (    (Recinfo.global_attribute4 IS NULL)
                    AND (P_global_attribute4 IS NULL)))
           AND (   (Recinfo.global_attribute5 =  P_global_attribute5)
                OR (    (Recinfo.global_attribute5 IS NULL)
                    AND (P_global_attribute5 IS NULL)))
           AND (   (Recinfo.global_attribute6 =  P_global_attribute6)
                OR (    (Recinfo.global_attribute6 IS NULL)
                    AND (P_global_attribute6 IS NULL)))
           AND (   (Recinfo.global_attribute7 =  P_global_attribute7)
                OR (    (Recinfo.global_attribute7 IS NULL)
                    AND (P_global_attribute7 IS NULL)))
           AND (   (Recinfo.global_attribute8 =  P_global_attribute8)
                OR (    (Recinfo.global_attribute8 IS NULL)
                    AND (P_global_attribute8 IS NULL)))
           AND (   (Recinfo.global_attribute9 =  P_global_attribute9)
                OR (    (Recinfo.global_attribute9 IS NULL)
                    AND (P_global_attribute9 IS NULL)))
           AND (   (Recinfo.global_attribute10 =  P_global_attribute10)
                OR (    (Recinfo.global_attribute10 IS NULL)
                    AND (P_global_attribute10 IS NULL)))
           AND (   (Recinfo.global_attribute11 =  P_global_attribute11)
                OR (    (Recinfo.global_attribute11 IS NULL)
                    AND (P_global_attribute11 IS NULL)))
           AND (   (Recinfo.global_attribute12 =  P_global_attribute12)
                OR (    (Recinfo.global_attribute12 IS NULL)
                    AND (P_global_attribute12 IS NULL)))
           AND (   (Recinfo.global_attribute13 =  P_global_attribute13)
                OR (    (Recinfo.global_attribute13 IS NULL)
                    AND (P_global_attribute13 IS NULL)))
           AND (   (Recinfo.global_attribute14 =  P_global_attribute14)
                OR (    (Recinfo.global_attribute14 IS NULL)
                    AND (P_global_attribute14 IS NULL)))
           AND (   (Recinfo.global_attribute15 =  P_global_attribute15)
                OR (    (Recinfo.global_attribute15 IS NULL)
                    AND (P_global_attribute15 IS NULL)))
           AND (   (Recinfo.global_attribute16 =  P_global_attribute16)
                OR (    (Recinfo.global_attribute16 IS NULL)
                    AND (P_global_attribute16 IS NULL)))
           AND (   (Recinfo.global_attribute17 =  P_global_attribute17)
                OR (    (Recinfo.global_attribute17 IS NULL)
                    AND (P_global_attribute17 IS NULL)))
           AND (   (Recinfo.global_attribute18 =  P_global_attribute18)
                OR (    (Recinfo.global_attribute18 IS NULL)
                    AND (P_global_attribute18 IS NULL)))
           AND (   (Recinfo.global_attribute19 =  P_global_attribute19)
                OR (    (Recinfo.global_attribute19 IS NULL)
                    AND (P_global_attribute19 IS NULL)))
           AND (   (Recinfo.global_attribute20 =  P_global_attribute20)
                OR (    (Recinfo.global_attribute20 IS NULL)
                    AND (P_global_attribute20 IS NULL)))
           AND (Recinfo.line_type_lookup_code =  P_Line_Type_Lookup_Code)
           AND (   (Recinfo.line_group_number =  P_line_group_number)
                OR (    (Recinfo.line_group_number IS NULL)
                    AND (P_LINE_GROUP_NUMBER IS NULL)))
           AND (   (Recinfo.REQUESTER_ID =  P_REQUESTER_ID)
                OR (    (Recinfo.REQUESTER_ID IS NULL)
                    AND (P_REQUESTER_ID IS NULL)))
           AND (   (Recinfo.DESCRIPTION =  P_DESCRIPTION)
                OR (    (Recinfo.DESCRIPTION IS NULL)
                    AND (P_DESCRIPTION IS NULL)))
           AND (   (Recinfo.LINE_SOURCE =  P_LINE_SOURCE)
                OR (    (Recinfo.LINE_SOURCE IS NULL)
                    AND (P_LINE_SOURCE IS NULL)))
           AND (   (Recinfo.INVENTORY_ITEM_Id =  P_INVENTORY_ITEM_ID)
                OR (    (Recinfo.INVENTORY_ITEM_ID IS NULL)
                    AND (P_INVENTORY_ITEM_ID IS NULL)))
           AND (   (Recinfo.ITEM_DESCRIPTION =  P_ITEM_DESCRIPTION)
                OR (    (Recinfo.ITEM_DESCRIPTION IS NULL)
                    AND (P_ITEM_DESCRIPTION IS NULL)))
           AND (   (Recinfo.SERIAL_NUMBER =  P_SERIAL_NUMBER)
                OR (    (Recinfo.SERIAL_NUMBER IS NULL)
                    AND (P_SERIAL_NUMBER IS NULL)))
           AND (   (Recinfo.MANUFACTURER =  P_MANUFACTURER)
                OR (    (Recinfo.MANUFACTURER IS NULL)
                    AND (P_MANUFACTURER IS NULL)))
           AND (   (Recinfo.MODEL_NUMBER =  P_MODEL_NUMBER)
                OR (    (Recinfo.MODEL_NUMBER IS NULL)
                    AND (P_MODEL_NUMBER IS NULL)))
           AND (   (Recinfo.WARRANTY_NUMBER =  P_WARRANTY_NUMBER)
                OR (    (Recinfo.WARRANTY_NUMBER IS NULL)
                    AND (P_WARRANTY_NUMBER IS NULL)))
           AND (   (Recinfo.GENERATE_DISTS =  P_GENERATE_DISTS)
                OR (    (Recinfo.GENERATE_DISTS IS NULL)
                    AND (P_GENERATE_DISTS IS NULL)))
           AND (   (Recinfo.MATCH_TYPE =  P_MATCH_TYPE)
                OR (    (Recinfo.MATCH_TYPE IS NULL)
                    AND (P_MATCH_TYPE IS NULL)))
           AND (   (Recinfo.DISTRIBUTION_SET_ID =  P_DISTRIBUTION_SET_ID)
                OR (    (Recinfo.DISTRIBUTION_SET_ID IS NULL)
                    AND (P_DISTRIBUTION_SET_ID IS NULL)))
           AND (   (Recinfo.ACCOUNT_SEGMENT =  P_ACCOUNT_SEGMENT)
                OR (    (Recinfo.ACCOUNT_SEGMENT IS NULL)
                    AND (P_ACCOUNT_SEGMENT IS NULL)))
          AND (   (Recinfo.BALANCING_SEGMENT =  P_BALANCING_SEGMENT)
                OR (    (Recinfo.BALANCING_SEGMENT IS NULL)
                    AND (P_BALANCING_SEGMENT IS NULL)))
          AND (   (Recinfo.COST_CENTER_SEGMENT =  P_COST_CENTER_SEGMENT)
                OR (    (Recinfo.COST_CENTER_SEGMENT IS NULL)
                    AND (P_COST_CENTER_SEGMENT IS NULL)))
          AND (   (Recinfo.OVERLAY_DIST_CODE_CONCAT
                                     =  P_OVERLAY_DIST_CODE_CONCAT)
                OR (    (Recinfo.OVERLAY_DIST_CODE_CONCAT IS NULL)
                    AND (P_OVERLAY_DIST_CODE_CONCAT IS NULL)))
          AND (   (Recinfo.DEFAULT_DIST_CCID =  P_DEFAULT_DIST_CCID)
                OR (    (Recinfo.DEFAULT_DIST_CCID IS NULL)
                    AND (P_DEFAULT_DIST_CCID IS NULL)))
          AND (   (Recinfo.PRORATE_ACROSS_ALL_ITEMS
                                     =  P_PRORATE_ACROSS_ALL_ITEMS)
                OR (    (Recinfo.PRORATE_ACROSS_ALL_ITEMS IS NULL)
                    AND (P_PRORATE_ACROSS_ALL_ITEMS IS NULL)))
           AND (   (Recinfo.ROUNDING_AMT =  P_ROUNDING_AMT)
                OR (    (Recinfo.ROUNDING_AMT IS NULL)
                    AND (P_ROUNDING_AMT IS NULL)))
          AND (   (Recinfo.DEFERRED_ACCTG_FLAG =  P_DEFERRED_ACCTG_FLAG)
                OR (    (Recinfo.DEFERRED_ACCTG_FLAG IS NULL)
                    AND (P_DEFERRED_ACCTG_FLAG IS NULL)))
          AND (   (Recinfo.DEF_ACCTG_START_DATE =  P_DEF_ACCTG_START_DATE)
                OR (    (Recinfo.DEF_ACCTG_START_DATE IS NULL)
                    AND (P_DEF_ACCTG_START_DATE IS NULL)))
          AND (   (Recinfo.DEF_ACCTG_END_DATE =  P_DEF_ACCTG_END_DATE)
                OR (    (Recinfo.DEF_ACCTG_END_DATE IS NULL)
                    AND (P_DEF_ACCTG_END_DATE IS NULL)))
          AND (   (Recinfo.DEF_ACCTG_NUMBER_OF_PERIODS
                                      =  P_DEF_ACCTG_NUMBER_OF_PERIODS)
                OR (    (Recinfo.DEF_ACCTG_NUMBER_OF_PERIODS IS NULL)
                    AND (P_DEF_ACCTG_NUMBER_OF_PERIODS IS NULL)))
          AND (   (Recinfo.DEF_ACCTG_PERIOD_TYPE =  P_DEF_ACCTG_PERIOD_TYPE)
                OR (    (Recinfo.DEF_ACCTG_PERIOD_TYPE IS NULL)
                    AND (P_DEF_ACCTG_PERIOD_TYPE IS NULL)))
          AND (   (Recinfo.UNIT_MEAS_LOOKUP_CODE =  P_UNIT_MEAS_LOOKUP_CODE)
                OR (    (Recinfo.UNIT_MEAS_LOOKUP_CODE IS NULL)
                    AND (P_UNIT_MEAS_LOOKUP_CODE IS NULL)))
          AND (   (Recinfo.PERIOD_NAME =  P_PERIOD_NAME)
                OR (    (Recinfo.PERIOD_NAME IS NULL)
                    AND (P_PERIOD_NAME IS NULL)))
          AND (   (Recinfo.DISCARDED_FLAG =  P_DISCARDED_FLAG)
                OR (    (Recinfo.DISCARDED_FLAG IS NULL)
                    AND (P_DISCARDED_FLAG IS NULL)))
          AND (   (Recinfo.ORIGINAL_AMOUNT =  P_ORIGINAL_AMOUNT)
                OR (    (Recinfo.ORIGINAL_AMOUNT IS NULL)
                    AND (P_ORIGINAL_AMOUNT IS NULL)))
          AND (   (Recinfo.ORIGINAL_BASE_AMOUNT =  P_ORIGINAL_BASE_AMOUNT)
                OR (    (Recinfo.ORIGINAL_BASE_AMOUNT IS NULL)
                    AND (P_ORIGINAL_BASE_AMOUNT IS NULL)))
          AND (   (Recinfo.ORIGINAL_ROUNDING_AMT =  P_ORIGINAL_ROUNDING_AMT)
                OR (    (Recinfo.ORIGINAL_ROUNDING_AMT IS NULL)
                    AND (P_ORIGINAL_ROUNDING_AMT IS NULL)))
          AND (   (Recinfo.CANCELLED_FLAG =  P_CANCELLED_FLAG)
                OR (    (Recinfo.CANCELLED_FLAG IS NULL)
                    AND (P_CANCELLED_FLAG IS NULL)))
          AND (   (Recinfo.PREPAY_INVOICE_ID =  P_PREPAY_INVOICE_ID)
                OR (    (Recinfo.PREPAY_INVOICE_ID IS NULL)
                    AND (P_PREPAY_INVOICE_ID IS NULL)))
          AND (   (Recinfo.PREPAY_LINE_NUMBER =  P_PREPAY_LINE_NUMBER)
                OR (    (Recinfo.PREPAY_LINE_NUMBER IS NULL)
                    AND (P_PREPAY_LINE_NUMBER IS NULL)))
          AND (   (Recinfo.INVOICE_INCLUDES_PREPAY_FLAG
                                 =  P_INVOICE_INCLUDES_PREPAY_FLAG)
                OR (    (Recinfo.INVOICE_INCLUDES_PREPAY_FLAG IS NULL)
                    AND (P_INVOICE_INCLUDES_PREPAY_FLAG IS NULL)))
          AND (   (Recinfo.CORRECTED_INV_ID =  P_CORRECTED_INV_ID)
                OR (    (Recinfo.CORRECTED_INV_ID IS NULL)
                    AND (P_CORRECTED_INV_ID IS NULL)))
          AND (   (Recinfo.CORRECTED_LINE_NUMBER =  P_CORRECTED_LINE_NUMBER)
                OR (    (Recinfo.CORRECTED_LINE_NUMBER IS NULL)
                    AND (P_CORRECTED_LINE_NUMBER IS NULL)))
          AND (   (Recinfo.PA_CC_AR_INVOICE_ID =  P_PA_CC_AR_INVOICE_ID)
                OR (    (Recinfo.PA_CC_AR_INVOICE_ID IS NULL)
                    AND (P_PA_CC_AR_INVOICE_ID IS NULL)))
          AND (   (Recinfo.PA_CC_AR_INVOICE_LINE_NUM
                                =  P_PA_CC_AR_INVOICE_LINE_NUM)
                OR (    (Recinfo.PA_CC_AR_INVOICE_LINE_NUM IS NULL)
                    AND (P_PA_CC_AR_INVOICE_LINE_NUM IS NULL)))
          AND (   (Recinfo.PA_CC_PROCESSED_CODE =  P_PA_CC_PROCESSED_CODE)
                OR (    (Recinfo.PA_CC_PROCESSED_CODE IS NULL)
                    AND (P_PA_CC_PROCESSED_CODE IS NULL)))
          AND (   (Recinfo.RECEIPT_VERIFIED_FLAG =  P_RECEIPT_VERIFIED_FLAG)
                OR (    (Recinfo.RECEIPT_VERIFIED_FLAG IS NULL)
                    AND (P_RECEIPT_VERIFIED_FLAG IS NULL)))
          AND (   (Recinfo.RECEIPT_REQUIRED_FLAG =  P_RECEIPT_REQUIRED_FLAG)
                OR (    (Recinfo.RECEIPT_REQUIRED_FLAG IS NULL)
                    AND (P_RECEIPT_REQUIRED_FLAG IS NULL)))
          AND (   (Recinfo.RECEIPT_MISSING_FLAG =  P_RECEIPT_MISSING_FLAG)
                OR (    (Recinfo.RECEIPT_MISSING_FLAG IS NULL)
                    AND (P_RECEIPT_MISSING_FLAG IS NULL)))
          AND (   (Recinfo.JUSTIFICATION =  P_JUSTIFICATION)
                OR (    (Recinfo.JUSTIFICATION IS NULL)
                    AND (P_JUSTIFICATION IS NULL)))
          AND (   (Recinfo.RECEIPT_CURRENCY_CODE =  P_RECEIPT_CURRENCY_CODE)
                OR (    (Recinfo.RECEIPT_CURRENCY_CODE IS NULL)
                    AND (P_RECEIPT_CURRENCY_CODE IS NULL)))
          AND (   (Recinfo.RECEIPT_CONVERSION_RATE =  P_RECEIPT_CONVERSION_RATE)
                OR (    (Recinfo.RECEIPT_CONVERSION_RATE IS NULL)
                    AND (P_RECEIPT_CONVERSION_RATE IS NULL)))
          AND (   (Recinfo.RECEIPT_CURRENCY_AMOUNT =  P_RECEIPT_CURRENCY_AMOUNT)
                OR (    (Recinfo.RECEIPT_CURRENCY_AMOUNT IS NULL)
                    AND (P_RECEIPT_CURRENCY_AMOUNT IS NULL)))
          AND (   (Recinfo.DAILY_AMOUNT =  P_DAILY_AMOUNT)
                OR (    (Recinfo.DAILY_AMOUNT IS NULL)
                    AND (P_DAILY_AMOUNT IS NULL)))
          AND (   (Recinfo.WEB_PARAMETER_ID =  P_WEB_PARAMETER_ID)
                OR (    (Recinfo.WEB_PARAMETER_ID IS NULL)
                    AND (P_WEB_PARAMETER_ID IS NULL)))
          AND (   (Recinfo.ADJUSTMENT_REASON =  P_ADJUSTMENT_REASON)
                OR (    (Recinfo.ADJUSTMENT_REASON IS NULL)
                    AND (P_ADJUSTMENT_REASON IS NULL)))
          AND (   (Recinfo.CREDIT_CARD_TRX_ID =  P_CREDIT_CARD_TRX_ID)
                OR (    (Recinfo.CREDIT_CARD_TRX_ID IS NULL)
                    AND (P_CREDIT_CARD_TRX_ID IS NULL)))
          AND (   (Recinfo.COMPANY_PREPAID_INVOICE_ID
                                 =  P_COMPANY_PREPAID_INVOICE_ID)
                OR (    (Recinfo.COMPANY_PREPAID_INVOICE_ID IS NULL)
                    AND (P_COMPANY_PREPAID_INVOICE_ID IS NULL)))
          AND (   (Recinfo.CC_REVERSAL_FLAG =  P_CC_REVERSAL_FLAG)
                OR (    (Recinfo.CC_REVERSAL_FLAG IS NULL)
                    AND (P_CC_REVERSAL_FLAG IS NULL)))
          --ETAX: Invwkb
	  AND (   (Recinfo.PRIMARY_INTENDED_USE =  P_PRIMARY_INTENDED_USE)
	        OR (    (Recinfo.PRIMARY_INTENDED_USE IS NULL)
		    AND (P_PRIMARY_INTENDED_USE IS NULL)))
          AND (   (Recinfo.SHIP_TO_LOCATION_ID =  P_SHIP_TO_LOCATION_ID)
	        OR (    (Recinfo.SHIP_TO_LOCATION_ID IS NULL)
	            AND (P_SHIP_TO_LOCATION_ID IS NULL)))
          AND (   (Recinfo.PRODUCT_FISC_CLASSIFICATION =  P_PRODUCT_FISC_CLASSIFICATION)
	        OR (    (Recinfo.PRODUCT_FISC_CLASSIFICATION IS NULL)
	            AND (P_PRODUCT_FISC_CLASSIFICATION IS NULL)))
          AND (   (Recinfo.USER_DEFINED_FISC_CLASS =  P_USER_DEFINED_FISC_CLASS)
	        OR (    (Recinfo.USER_DEFINED_FISC_CLASS IS NULL)
	            AND (P_USER_DEFINED_FISC_CLASS IS NULL)))
	  AND (   (Recinfo.TRX_BUSINESS_CATEGORY =  P_TRX_BUSINESS_CATEGORY)
	        OR (    (Recinfo.TRX_BUSINESS_CATEGORY IS NULL)
	            AND (P_TRX_BUSINESS_CATEGORY IS NULL)))
          AND (   (Recinfo.PRODUCT_TYPE =  P_PRODUCT_TYPE)
                OR (    (Recinfo.PRODUCT_TYPE IS NULL)
                    AND (P_PRODUCT_TYPE IS NULL)))
          AND (   (Recinfo.PRODUCT_CATEGORY =  P_PRODUCT_CATEGORY)
	        OR (    (Recinfo.PRODUCT_CATEGORY IS NULL)
	            AND (P_PRODUCT_CATEGORY IS NULL)))
	  AND (   (Recinfo.ASSESSABLE_VALUE =  P_ASSESSABLE_VALUE)
	        OR (    (Recinfo.ASSESSABLE_VALUE IS NULL)
	            AND (P_ASSESSABLE_VALUE IS NULL)))
	  AND (   (Recinfo.CONTROL_AMOUNT =  P_CONTROL_AMOUNT)
	        OR (    (Recinfo.CONTROL_AMOUNT IS NULL)
	            AND (P_CONTROL_AMOUNT IS NULL)))
	  AND (   (Recinfo.TAX_REGIME_CODE =  P_TAX_REGIME_CODE)
	        OR (    (Recinfo.TAX_REGIME_CODE IS NULL)
	            AND (P_TAX_REGIME_CODE IS NULL)))
	  AND (   (Recinfo.TAX =  P_TAX)
	        OR (    (Recinfo.TAX IS NULL)
	            AND (P_TAX IS NULL)))
	  AND (   (Recinfo.TAX_STATUS_CODE =  P_TAX_STATUS_CODE)
	       OR (    (Recinfo.TAX_STATUS_CODE IS NULL)
	           AND (P_TAX_STATUS_CODE IS NULL)))
          AND (   (Recinfo.TAX_RATE_CODE =  P_TAX_RATE_CODE)
	       OR (    (Recinfo.TAX_RATE_CODE IS NULL)
	           AND (P_TAX_RATE_CODE IS NULL)))
	  AND (   (Recinfo.TAX_RATE_ID =  P_TAX_RATE_ID)
	       OR (    (Recinfo.TAX_RATE_ID IS NULL)
	           AND (P_TAX_RATE_ID IS NULL)))
	  AND (   (Recinfo.TAX_RATE =  P_TAX_RATE)
	       OR (    (Recinfo.TAX_RATE IS NULL)
	           AND (P_TAX_RATE IS NULL)))
	  AND (   (Recinfo.TAX_JURISDICTION_CODE =  P_TAX_JURISDICTION_CODE)
	       OR (    (Recinfo.TAX_JURISDICTION_CODE IS NULL)
	           AND (P_TAX_JURISDICTION_CODE IS NULL)))
          AND (Recinfo.po_header_id IS NOT NULL OR
	      ((Recinfo.PURCHASING_CATEGORY_ID = P_PURCHASING_CATEGORY_ID)
	         OR  (    (Recinfo.PURCHASING_CATEGORY_ID IS NULL)
	              AND (P_PURCHASING_CATEGORY_ID IS NULL)))
	      )
          AND (   (Recinfo.COST_FACTOR_ID = P_COST_FACTOR_ID)
	       OR (    (Recinfo.COST_FACTOR_ID IS NULL)
	            AND (P_COST_FACTOR_ID IS NULL)))
          AND (   (Recinfo.RETAINED_AMOUNT = P_RETAINED_AMOUNT)
	       OR (    (Recinfo.RETAINED_AMOUNT IS NULL)
	            AND (P_RETAINED_AMOUNT IS NULL)))
          AND (   (Recinfo.RETAINED_INVOICE_ID = P_RETAINED_INVOICE_ID)
	       OR (    (Recinfo.RETAINED_INVOICE_ID IS NULL)
	            AND (P_RETAINED_INVOICE_ID IS NULL)))
          AND (   (Recinfo.RETAINED_LINE_NUMBER = P_RETAINED_LINE_NUMBER)
	       OR (    (Recinfo.RETAINED_LINE_NUMBER IS NULL)
	            AND (P_RETAINED_LINE_NUMBER IS NULL)))
          AND (   (Recinfo.TAX_CLASSIFICATION_CODE = P_TAX_CLASSIFICATION_CODE)
	       OR (    (Recinfo.TAX_CLASSIFICATION_CODE IS NULL)
	            AND (P_TAX_CLASSIFICATION_CODE IS NULL)))
   ) THEN
    RETURN;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
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

END Lock_Row;


PROCEDURE Update_Row  (
          p_ROWID           IN OUT NOCOPY VARCHAR2,
          p_INVOICE_ID                      NUMBER,
          p_LINE_NUMBER                     NUMBER,
          p_LINE_TYPE_LOOKUP_CODE           VARCHAR2,
          p_LINE_GROUP_NUMBER               NUMBER,
          p_REQUESTER_ID                    NUMBER,
          p_DESCRIPTION                     VARCHAR2,
          p_LINE_SOURCE                     VARCHAR2,
          p_ORG_ID                          NUMBER,
          p_INVENTORY_ITEM_ID               NUMBER,
          p_ITEM_DESCRIPTION                VARCHAR2,
          p_SERIAL_NUMBER                   VARCHAR2,
          p_MANUFACTURER                    VARCHAR2,
          p_MODEL_NUMBER                    VARCHAR2,
          p_WARRANTY_NUMBER                 VARCHAR2,
          p_GENERATE_DISTS                  VARCHAR2,
          p_MATCH_TYPE                      VARCHAR2,
          p_DISTRIBUTION_SET_ID             NUMBER,
          p_ACCOUNT_SEGMENT                 VARCHAR2,
          p_BALANCING_SEGMENT               VARCHAR2,
          p_COST_CENTER_SEGMENT             VARCHAR2,
          p_OVERLAY_DIST_CODE_CONCAT        VARCHAR2,
          p_DEFAULT_DIST_CCID               NUMBER,
          p_PRORATE_ACROSS_ALL_ITEMS        VARCHAR2,
          p_ACCOUNTING_DATE                 DATE,
          p_PERIOD_NAME                     VARCHAR2,
          p_DEFERRED_ACCTG_FLAG             VARCHAR2,
          p_DEF_ACCTG_START_DATE            DATE,
          p_DEF_ACCTG_END_DATE              DATE,
          p_DEF_ACCTG_NUMBER_OF_PERIODS     NUMBER,
          p_DEF_ACCTG_PERIOD_TYPE           VARCHAR2,
          p_SET_OF_BOOKS_ID                 NUMBER,
          p_AMOUNT                          NUMBER,
          p_BASE_AMOUNT                     NUMBER,
          p_ROUNDING_AMT                    NUMBER,
          p_QUANTITY_INVOICED               NUMBER,
          p_UNIT_MEAS_LOOKUP_CODE           VARCHAR2,
          p_UNIT_PRICE                      NUMBER,
          p_WFAPPROVAL_STATUS               VARCHAR2,
          p_DISCARDED_FLAG                  VARCHAR2,
          p_ORIGINAL_AMOUNT                 NUMBER,
          p_ORIGINAL_BASE_AMOUNT            NUMBER,
          p_ORIGINAL_ROUNDING_AMT           NUMBER,
          p_CANCELLED_FLAG                  VARCHAR2,
          p_INCOME_TAX_REGION               VARCHAR2,
          p_TYPE_1099                       VARCHAR2,
          p_STAT_AMOUNT                     NUMBER,
          p_PREPAY_INVOICE_ID               NUMBER,
          p_PREPAY_LINE_NUMBER              NUMBER,
          p_INVOICE_INCLUDES_PREPAY_FLAG    VARCHAR2,
          p_CORRECTED_INV_ID                NUMBER,
          p_CORRECTED_LINE_NUMBER           NUMBER,
          p_PO_HEADER_ID                    NUMBER,
          p_PO_LINE_ID                      NUMBER,
          p_PO_RELEASE_ID                   NUMBER,
          p_PO_LINE_LOCATION_ID             NUMBER,
          p_PO_DISTRIBUTION_ID              NUMBER,
          p_RCV_TRANSACTION_ID              NUMBER,
          p_FINAL_MATCH_FLAG                VARCHAR2,
          p_ASSETS_TRACKING_FLAG            VARCHAR2,
          p_ASSET_BOOK_TYPE_CODE            VARCHAR2,
          p_ASSET_CATEGORY_ID               NUMBER,
          p_PROJECT_ID                      NUMBER,
          p_TASK_ID                         NUMBER,
          p_EXPENDITURE_TYPE                VARCHAR2,
          p_EXPENDITURE_ITEM_DATE           DATE,
          p_EXPENDITURE_ORGANIZATION_ID     NUMBER,
          p_PA_QUANTITY                     NUMBER,
          p_PA_CC_AR_INVOICE_ID             NUMBER,
          p_PA_CC_AR_INVOICE_LINE_NUM       NUMBER,
          p_PA_CC_PROCESSED_CODE            VARCHAR2,
          p_AWARD_ID                        NUMBER,
          p_AWT_GROUP_ID                    NUMBER,
          p_PAY_AWT_GROUP_ID                NUMBER,--bug6639866
          p_REFERENCE_1                     VARCHAR2,
          p_REFERENCE_2                     VARCHAR2,
          p_RECEIPT_VERIFIED_FLAG           VARCHAR2,
          p_RECEIPT_REQUIRED_FLAG           VARCHAR2,
          p_RECEIPT_MISSING_FLAG            VARCHAR2,
          p_JUSTIFICATION                   VARCHAR2,
          p_EXPENSE_GROUP                   VARCHAR2,
          p_START_EXPENSE_DATE              DATE,
          p_END_EXPENSE_DATE                DATE,
          p_RECEIPT_CURRENCY_CODE           VARCHAR2,
          p_RECEIPT_CONVERSION_RATE         NUMBER,
          p_RECEIPT_CURRENCY_AMOUNT         NUMBER,
          p_DAILY_AMOUNT                    NUMBER,
          p_WEB_PARAMETER_ID                NUMBER,
          p_ADJUSTMENT_REASON               VARCHAR2,
          p_MERCHANT_DOCUMENT_NUMBER        VARCHAR2,
          p_MERCHANT_NAME                   VARCHAR2,
          p_MERCHANT_REFERENCE              VARCHAR2,
          p_MERCHANT_TAX_REG_NUMBER         VARCHAR2,
          p_MERCHANT_TAXPAYER_ID            VARCHAR2,
          p_COUNTRY_OF_SUPPLY               VARCHAR2,
          p_CREDIT_CARD_TRX_ID              NUMBER,
          p_COMPANY_PREPAID_INVOICE_ID      NUMBER,
          p_CC_REVERSAL_FLAG                VARCHAR2,
          p_CREATION_DATE                   DATE,
          p_CREATED_BY                      NUMBER,
          p_LAST_UPDATED_BY                 NUMBER,
          p_LAST_UPDATE_DATE                DATE,
          p_LAST_UPDATE_LOGIN               NUMBER,
          p_PROGRAM_APPLICATION_ID          NUMBER,
          p_PROGRAM_ID                      NUMBER,
          p_PROGRAM_UPDATE_DATE             DATE,
          p_REQUEST_ID                      NUMBER,
          p_ATTRIBUTE_CATEGORY              VARCHAR2,
          p_ATTRIBUTE1                      VARCHAR2,
          p_ATTRIBUTE2                      VARCHAR2,
          p_ATTRIBUTE3                      VARCHAR2,
          p_ATTRIBUTE4                      VARCHAR2,
          p_ATTRIBUTE5                      VARCHAR2,
          p_ATTRIBUTE6                      VARCHAR2  DEFAULT NULL,
          p_ATTRIBUTE7                      VARCHAR2  DEFAULT NULL,
          p_ATTRIBUTE8                      VARCHAR2  DEFAULT NULL,
          p_ATTRIBUTE9                      VARCHAR2  DEFAULT NULL,
          p_ATTRIBUTE10                     VARCHAR2  DEFAULT NULL,
          p_ATTRIBUTE11                     VARCHAR2  DEFAULT NULL,
          p_ATTRIBUTE12                     VARCHAR2  DEFAULT NULL,
          p_ATTRIBUTE13                     VARCHAR2  DEFAULT NULL,
          p_ATTRIBUTE14                     VARCHAR2  DEFAULT NULL,
          p_ATTRIBUTE15                     VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE_CATEGORY       VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE1               VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE2               VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE3               VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE4               VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE5               VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE6               VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE7               VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE8               VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE9               VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE10              VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE11              VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE12              VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE13              VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE14              VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE15              VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE16              VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE17              VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE18              VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE19              VARCHAR2  DEFAULT NULL,
          p_GLOBAL_ATTRIBUTE20              VARCHAR2  DEFAULT NULL,
	  --ETAX: Invwkb
	  p_PRIMARY_INTENDED_USE            VARCHAR2  DEFAULT NULL,
	  p_SHIP_TO_LOCATION_ID             NUMBER    DEFAULT NULL,
	  p_PRODUCT_FISC_CLASSIFICATION     VARCHAR2  DEFAULT NULL,
	  p_USER_DEFINED_FISC_CLASS         VARCHAR2  DEFAULT NULL,
	  p_TRX_BUSINESS_CATEGORY           VARCHAR2  DEFAULT NULL,
	  p_PRODUCT_TYPE                    VARCHAR2  DEFAULT NULL,
	  p_PRODUCT_CATEGORY                VARCHAR2  DEFAULT NULL,
	  p_ASSESSABLE_VALUE                NUMBER    DEFAULT NULL,
	  p_CONTROL_AMOUNT                  NUMBER    DEFAULT NULL,
	  p_TAX_REGIME_CODE                 VARCHAR2  DEFAULT NULL,
	  p_TAX                             VARCHAR2  DEFAULT NULL,
	  p_TAX_STATUS_CODE                 VARCHAR2  DEFAULT NULL,
	  p_TAX_RATE_CODE                   VARCHAR2  DEFAULT NULL,
	  p_TAX_RATE_ID                     NUMBER    DEFAULT NULL,
	  p_TAX_RATE                        NUMBER    DEFAULT NULL,
	  p_TAX_JURISDICTION_CODE           VARCHAR2  DEFAULT NULL,
	  p_PURCHASING_CATEGORY_ID 	    NUMBER    DEFAULT NULL,
	  p_COST_FACTOR_ID		    NUMBER    DEFAULT NULL,
	  p_RETAINED_AMOUNT		    NUMBER    DEFAULT NULL,
	  p_RETAINED_INVOICE_ID		    NUMBER    DEFAULT NULL,
	  p_RETAINED_LINE_NUMBER	    NUMBER    DEFAULT NULL,
	  p_TAX_CLASSIFICATION_CODE	    VARCHAR2  DEFAULT NULL,
          p_Calling_Sequence                VARCHAR2)
  IS
  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(100);
BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'AP_AIL_TABLE_HANDLER_PKG.Update_Row<-'
                              ||p_Calling_Sequence;

  -- Check for uniqueness of the distribution line number

  AP_AIL_TABLE_HANDLER_PKG.CHECK_UNIQUE(
          p_Rowid,
          p_Invoice_Id,
          p_Line_Number,
          'AP_AIL_TABLE_HANDLER_PKG.Update_Row');

  debug_info := 'Update ap_invoice_lines_all';

  UPDATE AP_INVOICE_LINES_ALL
     SET
          INVOICE_ID                   =  P_INVOICE_ID,
          LINE_NUMBER                  =  P_LINE_NUMBER,
          LINE_TYPE_LOOKUP_CODE        =  P_LINE_TYPE_LOOKUP_CODE,
          LINE_GROUP_NUMBER            =  p_LINE_GROUP_NUMBER,
          REQUESTER_ID                 =  P_REQUESTER_ID,
          DESCRIPTION                  =  P_DESCRIPTION,
          LINE_SOURCE                  =  P_LINE_SOURCE,
          ORG_ID                       =  P_ORG_ID,
          INVENTORY_ITEM_ID            =  P_INVENTORY_ITEM_ID,
          ITEM_DESCRIPTION             =  P_ITEM_DESCRIPTION,
          SERIAL_NUMBER                =  P_SERIAL_NUMBER,
          MANUFACTURER                 =  P_MANUFACTURER,
          MODEL_NUMBER                 =  P_MODEL_NUMBER,
          WARRANTY_NUMBER              =  P_WARRANTY_NUMBER,
          GENERATE_DISTS               =  P_GENERATE_DISTS,
          MATCH_TYPE                   =  P_MATCH_TYPE,
          DISTRIBUTION_SET_ID          =  P_DISTRIBUTION_SET_ID,
          ACCOUNT_SEGMENT              =  P_ACCOUNT_SEGMENT,
          BALANCING_SEGMENT            =  P_BALANCING_SEGMENT,
          COST_CENTER_SEGMENT          =  P_COST_CENTER_SEGMENT,
          OVERLAY_DIST_CODE_CONCAT     =  P_OVERLAY_DIST_CODE_CONCAT,
          DEFAULT_DIST_CCID            =  P_DEFAULT_DIST_CCID,
          PRORATE_ACROSS_ALL_ITEMS     =  P_PRORATE_ACROSS_ALL_ITEMS,
          ACCOUNTING_DATE              =  P_ACCOUNTING_DATE,
          PERIOD_NAME                  =  P_PERIOD_NAME,
          DEFERRED_ACCTG_FLAG          =  P_DEFERRED_ACCTG_FLAG ,
          DEF_ACCTG_START_DATE         =  P_DEF_ACCTG_START_DATE,
          DEF_ACCTG_END_DATE           =  P_DEF_ACCTG_END_DATE ,
          DEF_ACCTG_NUMBER_OF_PERIODS  =  P_DEF_ACCTG_NUMBER_OF_PERIODS,
          DEF_ACCTG_PERIOD_TYPE        =  P_DEF_ACCTG_PERIOD_TYPE,
          SET_OF_BOOKS_ID              =  P_SET_OF_BOOKS_ID,
          AMOUNT                       =  P_AMOUNT,
          BASE_AMOUNT                  =  P_BASE_AMOUNT,
          ROUNDING_AMT                 =  P_ROUNDING_AMT ,
          QUANTITY_INVOICED            =  P_QUANTITY_INVOICED,
          UNIT_MEAS_LOOKUP_CODE        =  P_UNIT_MEAS_LOOKUP_CODE,
          UNIT_PRICE                   =  P_UNIT_PRICE,
          WFAPPROVAL_STATUS            =  P_WFAPPROVAL_STATUS,
          DISCARDED_FLAG               =  P_DISCARDED_FLAG,
          ORIGINAL_AMOUNT              =  P_ORIGINAL_AMOUNT,
          ORIGINAL_BASE_AMOUNT         =  P_ORIGINAL_BASE_AMOUNT,
          ORIGINAL_ROUNDING_AMT        =  P_ORIGINAL_ROUNDING_AMT,
          CANCELLED_FLAG               =  P_CANCELLED_FLAG,
          INCOME_TAX_REGION            =  P_INCOME_TAX_REGION,
          TYPE_1099                    =  P_TYPE_1099,
          STAT_AMOUNT                  =  P_STAT_AMOUNT,
          PREPAY_INVOICE_ID            =  P_PREPAY_INVOICE_ID,
          PREPAY_LINE_NUMBER           =  P_PREPAY_LINE_NUMBER,
          INVOICE_INCLUDES_PREPAY_FLAG =  P_INVOICE_INCLUDES_PREPAY_FLAG,
          CORRECTED_INV_ID             =  P_CORRECTED_INV_ID,
          CORRECTED_LINE_NUMBER        =  P_CORRECTED_LINE_NUMBER,
          PO_HEADER_ID                 =  P_PO_HEADER_ID,
          PO_LINE_ID                   =  P_PO_LINE_ID,
	  --bugfix:4990529, changed the p_po_line_location_id to
	  --p_po_release_id
          PO_RELEASE_ID                =  P_PO_RELEASE_ID,
          PO_LINE_LOCATION_ID          =  P_PO_LINE_LOCATION_ID,
          PO_DISTRIBUTION_ID           =  P_PO_DISTRIBUTION_ID,
          RCV_TRANSACTION_ID           =  P_RCV_TRANSACTION_ID,
          FINAL_MATCH_FLAG             =  P_FINAL_MATCH_FLAG,
          ASSETS_TRACKING_FLAG         =  P_ASSETS_TRACKING_FLAG,
          ASSET_BOOK_TYPE_CODE         =  P_ASSET_BOOK_TYPE_CODE,
          ASSET_CATEGORY_ID            =  P_ASSET_CATEGORY_ID,
          PROJECT_ID                   =  P_PROJECT_ID,
          TASK_ID                      =  P_TASK_ID,
          EXPENDITURE_TYPE             =  P_EXPENDITURE_TYPE,
          EXPENDITURE_ITEM_DATE        =  P_EXPENDITURE_ITEM_DATE,
          EXPENDITURE_ORGANIZATION_ID  =  P_EXPENDITURE_ORGANIZATION_ID,
          PA_QUANTITY                  =  P_PA_QUANTITY,
          PA_CC_AR_INVOICE_ID          =  P_PA_CC_AR_INVOICE_ID,
          PA_CC_AR_INVOICE_LINE_NUM    =  P_PA_CC_AR_INVOICE_LINE_NUM,
          PA_CC_PROCESSED_CODE         =  P_PA_CC_PROCESSED_CODE,
          AWARD_ID                     =  P_AWARD_ID,
          AWT_GROUP_ID                 =  P_AWT_GROUP_ID,
          PAY_AWT_GROUP_ID             =  P_PAY_AWT_GROUP_ID,--bug6639866
          REFERENCE_1                  =  P_REFERENCE_1,
          REFERENCE_2                  =  P_REFERENCE_2,
          RECEIPT_VERIFIED_FLAG        =  P_RECEIPT_REQUIRED_FLAG,
          RECEIPT_REQUIRED_FLAG        =  P_RECEIPT_REQUIRED_FLAG,
          RECEIPT_MISSING_FLAG         =  P_RECEIPT_MISSING_FLAG,
          JUSTIFICATION                =  P_JUSTIFICATION,
          EXPENSE_GROUP                =  P_EXPENSE_GROUP,
          START_EXPENSE_DATE           =  P_START_EXPENSE_DATE,
          END_EXPENSE_DATE             =  P_END_EXPENSE_DATE,
          RECEIPT_CURRENCY_CODE        =  P_RECEIPT_CURRENCY_CODE,
          RECEIPT_CONVERSION_RATE      =  P_RECEIPT_CONVERSION_RATE,
          RECEIPT_CURRENCY_AMOUNT      =  P_RECEIPT_CURRENCY_AMOUNT,
          DAILY_AMOUNT                 =  P_DAILY_AMOUNT,
          WEB_PARAMETER_ID             =  P_WEB_PARAMETER_ID,
          ADJUSTMENT_REASON            =  P_ADJUSTMENT_REASON,
          MERCHANT_DOCUMENT_NUMBER     =  P_MERCHANT_DOCUMENT_NUMBER,
          MERCHANT_NAME                =  P_MERCHANT_NAME,
          MERCHANT_REFERENCE           =  P_MERCHANT_REFERENCE,
          MERCHANT_TAX_REG_NUMBER      =  P_MERCHANT_TAX_REG_NUMBER,
          MERCHANT_TAXPAYER_ID         =  P_MERCHANT_TAXPAYER_ID,
          COUNTRY_OF_SUPPLY            =  P_COUNTRY_OF_SUPPLY,
          CREDIT_CARD_TRX_ID           =  P_CREDIT_CARD_TRX_ID,
          COMPANY_PREPAID_INVOICE_ID   =  P_COMPANY_PREPAID_INVOICE_ID,
          CC_REVERSAL_FLAG             =  P_CC_REVERSAL_FLAG,
          CREATION_DATE                =  P_CREATION_DATE,
          CREATED_BY                   =  P_CREATED_BY,
          LAST_UPDATED_BY              =  P_LAST_UPDATED_BY,
          LAST_UPDATE_DATE             =  P_LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN            =  P_LAST_UPDATE_LOGIN,
          PROGRAM_APPLICATION_ID       =  P_PROGRAM_APPLICATION_ID,
          PROGRAM_ID                   =  P_PROGRAM_ID,
          PROGRAM_UPDATE_DATE          =  P_PROGRAM_UPDATE_DATE,
          REQUEST_ID                   =  P_REQUEST_ID,
          ATTRIBUTE_CATEGORY           =  P_ATTRIBUTE_CATEGORY,
          ATTRIBUTE1                   =  P_ATTRIBUTE1,
          ATTRIBUTE2                   =  P_ATTRIBUTE2,
          ATTRIBUTE3                   =  P_ATTRIBUTE3,
          ATTRIBUTE4                   =  P_ATTRIBUTE4,
          ATTRIBUTE5                   =  P_ATTRIBUTE5,
          ATTRIBUTE6                   =  P_ATTRIBUTE6,
          ATTRIBUTE7                   =  P_ATTRIBUTE7,
          ATTRIBUTE8                   =  P_ATTRIBUTE8,
          ATTRIBUTE9                   =  P_ATTRIBUTE9,
          ATTRIBUTE10                  =  P_ATTRIBUTE10,
          ATTRIBUTE11                  =  P_ATTRIBUTE11,
          ATTRIBUTE12                  =  P_ATTRIBUTE12,
          ATTRIBUTE13                  =  P_ATTRIBUTE13,
          ATTRIBUTE14                  =  P_ATTRIBUTE14,
          ATTRIBUTE15                  =  P_ATTRIBUTE15,
          GLOBAL_ATTRIBUTE_CATEGORY    =  P_GLOBAL_ATTRIBUTE_CATEGORY,
          GLOBAL_ATTRIBUTE1            =  P_GLOBAL_ATTRIBUTE1,
          GLOBAL_ATTRIBUTE2            =  P_GLOBAL_ATTRIBUTE2,
          GLOBAL_ATTRIBUTE3            =  P_GLOBAL_ATTRIBUTE3,
          GLOBAL_ATTRIBUTE4            =  P_GLOBAL_ATTRIBUTE4,
          GLOBAL_ATTRIBUTE5            =  P_GLOBAL_ATTRIBUTE5,
          GLOBAL_ATTRIBUTE6            =  P_GLOBAL_ATTRIBUTE6,
          GLOBAL_ATTRIBUTE7            =  P_GLOBAL_ATTRIBUTE7,
          GLOBAL_ATTRIBUTE8            =  P_GLOBAL_ATTRIBUTE8,
          GLOBAL_ATTRIBUTE9            =  P_GLOBAL_ATTRIBUTE9,
          GLOBAL_ATTRIBUTE10           =  P_GLOBAL_ATTRIBUTE10,
          GLOBAL_ATTRIBUTE11           =  P_GLOBAL_ATTRIBUTE11,
          GLOBAL_ATTRIBUTE12           =  P_GLOBAL_ATTRIBUTE12,
          GLOBAL_ATTRIBUTE13           =  P_GLOBAL_ATTRIBUTE13,
          GLOBAL_ATTRIBUTE14           =  P_GLOBAL_ATTRIBUTE14,
          GLOBAL_ATTRIBUTE15           =  P_GLOBAL_ATTRIBUTE15,
          GLOBAL_ATTRIBUTE16           =  P_GLOBAL_ATTRIBUTE16,
          GLOBAL_ATTRIBUTE17           =  P_GLOBAL_ATTRIBUTE17,
          GLOBAL_ATTRIBUTE18           =  P_GLOBAL_ATTRIBUTE18,
          GLOBAL_ATTRIBUTE19           =  P_GLOBAL_ATTRIBUTE19,
          GLOBAL_ATTRIBUTE20           =  P_GLOBAL_ATTRIBUTE20,
	  PRIMARY_INTENDED_USE	       =  P_PRIMARY_INTENDED_USE,
	  SHIP_TO_LOCATION_ID	       =  P_SHIP_TO_LOCATION_ID,
	  PRODUCT_FISC_CLASSIFICATION  =  P_PRODUCT_FISC_CLASSIFICATION,
	  USER_DEFINED_FISC_CLASS      =  P_USER_DEFINED_FISC_CLASS,
	  TRX_BUSINESS_CATEGORY	       =  P_TRX_BUSINESS_CATEGORY,
	  PRODUCT_TYPE		       =  P_PRODUCT_TYPE,
	  PRODUCT_CATEGORY	       =  P_PRODUCT_CATEGORY,
	  ASSESSABLE_VALUE	       =  P_ASSESSABLE_VALUE,
	  CONTROL_AMOUNT	       =  P_CONTROL_AMOUNT,
	  TAX_REGIME_CODE	       =  P_TAX_REGIME_CODE,
	  TAX			       =  P_TAX,
	  TAX_STATUS_CODE	       =  P_TAX_STATUS_CODE,
	  TAX_RATE_CODE		       =  P_TAX_RATE_CODE,
	  TAX_RATE_ID		       =  P_TAX_RATE_ID,
	  TAX_RATE		       =  P_TAX_RATE,
	  TAX_JURISDICTION_CODE	       =  P_TAX_JURISDICTION_CODE,
	  PURCHASING_CATEGORY_ID       =  P_PURCHASING_CATEGORY_ID,
	  COST_FACTOR_ID	       =  P_COST_FACTOR_ID,
	  RETAINED_AMOUNT	       =  P_RETAINED_AMOUNT,
	  RETAINED_AMOUNT_REMAINING    =  -(P_RETAINED_AMOUNT),
	  RETAINED_INVOICE_ID	       =  P_RETAINED_INVOICE_ID,
	  RETAINED_LINE_NUMBER	       =  P_RETAINED_LINE_NUMBER,
	  TAX_CLASSIFICATION_CODE      =  P_TAX_CLASSIFICATION_CODE
  WHERE rowid = p_Rowid;

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

END Update_Row;


PROCEDURE Delete_Row (
          p_Rowid            VARCHAR2,
          p_Calling_Sequence VARCHAR2)
  IS
  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(100);
  --Bugfix:4670908
  l_invoice_id		   AP_INVOICES_ALL.INVOICE_ID%TYPE;
  l_line_number		   AP_INVOICE_LINES_ALL.LINE_NUMBER%TYPE;
  l_invoice_distribution_id NUMBER;
  --Bug9295867
  l_line_type 		   AP_INVOICE_LINES_ALL.LINE_TYPE_LOOKUP_CODE%TYPE;
  l_tax_calculated_flag    VARCHAR2(3);
  l_success                BOOLEAN;
  l_error_code             VARCHAR2(4000);
  l_api_name               CONSTANT VARCHAR2(200) := 'Delete_Row';
BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'AP_AIL_TABLE_HANDLER_PKG.Delete_Row<-' ||
                              p_Calling_Sequence;

  debug_info := 'Delete from child entity ap_invoice_distributions_all';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,debug_info);
  END IF;
  --Bugfix:4670908
  --Bug9295867 : added l_line_type, l_tax_calculated_flag
  SELECT invoice_id,line_number,line_type_lookup_code,tax_already_calculated_flag
  INTO l_invoice_id,l_line_number, l_line_type, l_tax_calculated_flag
  FROM ap_invoice_lines_all
  WHERE rowid=p_rowid;

  DELETE FROM ap_invoice_distributions_all
  WHERE invoice_id = l_invoice_id
  AND invoice_line_number = l_line_number;

  --Bug9295867
  if(l_line_type = 'ITEM' and l_tax_calculated_flag ='Y') THEN
	debug_info := 'Calling eTax to delete corresponding tax data';
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         	 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,debug_info);
        END IF;
        l_success := ap_etax_pkg.calling_etax(
		         P_Invoice_Id => l_invoice_id,
	  	      	 P_Calling_Mode => 'MARK TAX LINES DELETED',
	 	     	 P_Line_Number_To_Delete =>l_line_number,
          		 P_All_Error_Messages => 'N',
	 		 P_error_code  => l_error_code,
	  		 P_calling_sequence => current_calling_sequence);

           IF(not l_success) THEN
        	FND_MESSAGE.SET_NAME('SQLAP','AP_ETX_TAX_LINE_DEL_FAIL');
        	FND_MESSAGE.SET_TOKEN('REASON',l_error_code);
        	APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;
  END IF;
  --End of Bug9295867

  debug_info := 'Delete from ap_invoice_lines';
  DELETE FROM AP_INVOICE_LINES_ALL
   WHERE rowid = p_Rowid;

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

END AP_AIL_TABLE_HANDLER_PKG;

/
