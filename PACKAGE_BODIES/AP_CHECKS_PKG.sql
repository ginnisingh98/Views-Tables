--------------------------------------------------------
--  DDL for Package Body AP_CHECKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CHECKS_PKG" as
/* $Header: apichecb.pls 120.15.12010000.9 2010/06/10 06:42:53 rseeta ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Amount                         NUMBER,
                       X_Ce_Bank_Acct_Use_Id            NUMBER,
                       X_Bank_Account_Name              VARCHAR2,
                       X_Check_Date                     DATE,
                       X_Check_Id                       NUMBER,
                       X_Check_Number                   NUMBER,
                       X_Currency_Code                  VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                 --IBY:SP      X_Payment_Method_Lookup_Code     VARCHAR2,
                       X_Payment_Type_Flag              VARCHAR2,
                       X_Address_Line1                  VARCHAR2 DEFAULT NULL,
                       X_Address_Line2                  VARCHAR2 DEFAULT NULL,
                       X_Address_Line3                  VARCHAR2 DEFAULT NULL,
                       X_Checkrun_Name                  VARCHAR2 DEFAULT NULL,
                       X_Check_Format_Id                NUMBER DEFAULT NULL,
                       X_Check_Stock_Id                 NUMBER DEFAULT NULL,
                       X_City                           VARCHAR2 DEFAULT NULL,
                       X_Country                        VARCHAR2 DEFAULT NULL,
                       X_Created_By                     NUMBER DEFAULT NULL,
                       X_Creation_Date                  DATE DEFAULT NULL,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Status_Lookup_Code             VARCHAR2 DEFAULT NULL,
                       X_Vendor_Name                    VARCHAR2 DEFAULT NULL,
                       X_Vendor_Site_Code               VARCHAR2 DEFAULT NULL,
                  X_External_Bank_Account_Id       NUMBER,
                       X_Zip                            VARCHAR2 DEFAULT NULL,
                       X_Bank_Account_Num               VARCHAR2 DEFAULT NULL,
                       X_Bank_Account_Type              VARCHAR2 DEFAULT NULL,
                       X_Bank_Num                       VARCHAR2 DEFAULT NULL,
                       X_Check_Voucher_Num              NUMBER DEFAULT NULL,
                       X_Cleared_Amount                 NUMBER DEFAULT NULL,
                       X_Cleared_Date                   DATE DEFAULT NULL,
                       X_Doc_Category_Code              VARCHAR2 DEFAULT NULL,
                       X_Doc_Sequence_Id                NUMBER DEFAULT NULL,
                       X_Doc_Sequence_Value             NUMBER DEFAULT NULL,
                       X_Province                       VARCHAR2 DEFAULT NULL,
                       X_Released_Date                  DATE DEFAULT NULL,
                       X_Released_By                    NUMBER DEFAULT NULL,
                       X_State                          VARCHAR2 DEFAULT NULL,
                       X_Stopped_Date                   DATE DEFAULT NULL,
                       X_Stopped_By                     NUMBER DEFAULT NULL,
                       X_Void_Date                      DATE DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute10                    VARCHAR2 DEFAULT NULL,
                       X_Attribute11                    VARCHAR2 DEFAULT NULL,
                       X_Attribute12                    VARCHAR2 DEFAULT NULL,
                       X_Attribute13                    VARCHAR2 DEFAULT NULL,
                       X_Attribute14                    VARCHAR2 DEFAULT NULL,
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Attribute6                     VARCHAR2 DEFAULT NULL,
                       X_Attribute7                     VARCHAR2 DEFAULT NULL,
                       X_Attribute8                     VARCHAR2 DEFAULT NULL,
                       X_Attribute9                     VARCHAR2 DEFAULT NULL,
                       X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                       X_Future_Pay_Due_Date            DATE DEFAULT NULL,
                       X_Treasury_Pay_Date              DATE DEFAULT NULL,
                       X_Treasury_Pay_Number            NUMBER DEFAULT NULL,
                    -- Removed for bug 4277744
                    -- X_Ussgl_Transaction_Code         VARCHAR2 DEFAULT NULL,
                    -- X_Ussgl_Trx_Code_Context         VARCHAR2 DEFAULT NULL,
                       X_Withholding_Status_Lkup_Code   VARCHAR2 DEFAULT NULL,
                       X_Reconciliation_Batch_Id        NUMBER DEFAULT NULL,
                       X_Cleared_Base_Amount            NUMBER DEFAULT NULL,
                       X_Cleared_Exchange_Rate          NUMBER DEFAULT NULL,
                       X_Cleared_Exchange_Date          DATE DEFAULT NULL,
                       X_Cleared_Exchange_Rate_Type     VARCHAR2 DEFAULT NULL,
                       X_Address_Line4                  VARCHAR2 DEFAULT NULL,
                       X_County                         VARCHAR2 DEFAULT NULL,
                       X_Address_Style                  VARCHAR2 DEFAULT NULL,
                       X_Org_Id                         NUMBER DEFAULT NULL,
                       X_Vendor_Id                      NUMBER,
                       X_Vendor_Site_Id                 NUMBER,
                       X_Exchange_Rate                  NUMBER DEFAULT NULL,
                       X_Exchange_Date                  DATE DEFAULT NULL,
                       X_Exchange_Rate_Type             VARCHAR2 DEFAULT NULL,
                       X_Base_Amount                    NUMBER DEFAULT NULL,
                       X_Checkrun_Id                    NUMBER DEFAULT NULL,
                       X_global_attribute_category      VARCHAR2 DEFAULT NULL,
                       X_global_attribute1              VARCHAR2 DEFAULT NULL,
                       X_global_attribute2              VARCHAR2 DEFAULT NULL,
                       X_global_attribute3              VARCHAR2 DEFAULT NULL,
                       X_global_attribute4              VARCHAR2 DEFAULT NULL,
                       X_global_attribute5              VARCHAR2 DEFAULT NULL,
                       X_global_attribute6              VARCHAR2 DEFAULT NULL,
                       X_global_attribute7              VARCHAR2 DEFAULT NULL,
                       X_global_attribute8              VARCHAR2 DEFAULT NULL,
                       X_global_attribute9              VARCHAR2 DEFAULT NULL,
                       X_global_attribute10             VARCHAR2 DEFAULT NULL,
                       X_global_attribute11             VARCHAR2 DEFAULT NULL,
                       X_global_attribute12             VARCHAR2 DEFAULT NULL,
                       X_global_attribute13             VARCHAR2 DEFAULT NULL,
                       X_global_attribute14             VARCHAR2 DEFAULT NULL,
                       X_global_attribute15             VARCHAR2 DEFAULT NULL,
                       X_global_attribute16             VARCHAR2 DEFAULT NULL,
                       X_global_attribute17             VARCHAR2 DEFAULT NULL,
                       X_global_attribute18             VARCHAR2 DEFAULT NULL,
                       X_global_attribute19             VARCHAR2 DEFAULT NULL,
                       X_global_attribute20             VARCHAR2 DEFAULT NULL,
                       X_transfer_priority              VARCHAR2 DEFAULT NULL,
               X_maturity_exchange_rate_type    VARCHAR2 DEFAULT NULL,
               X_maturity_exchange_date        DATE DEFAULT NULL,
               X_maturity_exchange_rate        NUMBER DEFAULT NULL,
               X_description            VARCHAR2 DEFAULT NULL,
               X_anticipated_value_date        DATE DEFAULT NULL,
               X_actual_value_date        DATE DEFAULT NULL,
               x_payment_method_code            VARCHAR2 DEFAULT NULL,
               x_payment_profile_id             NUMBER DEFAULT NULL,
               x_bank_charge_bearer             VARCHAR2 DEFAULT NULL,
               x_settlement_priority            VARCHAR2 DEFAULT NULL,
               x_payment_document_id            NUMBER DEFAULT NULL,
               x_party_id                       NUMBER DEFAULT NULL,
               x_party_site_id                  NUMBER DEFAULT NULL,
               x_legal_entity_id                NUMBER DEFAULT NULL,
               x_payment_id                     NUMBER DEFAULT NULL,
               X_calling_sequence    IN    VARCHAR2,
	       X_Remit_To_Supplier_Name	VARCHAR2 DEFAULT NULL,
	       X_Remit_To_Supplier_Id	Number DEFAULT NULL,
	       X_Remit_To_Supplier_Site	VARCHAR2 DEFAULT NULL,
	       X_Remit_To_Supplier_Site_Id	NUMBER DEFAULT NULL,
	       X_Relationship_Id			NUMBER DEFAULT NULL,
               X_paycard_authorization_number VARCHAR2 DEFAULT NULL,
               X_paycard_reference_id NUMBER DEFAULT NULL
  ) IS
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

   BEGIN

--     Update the calling sequence
--
       current_calling_sequence := 'AP_CHECKS_PKG.INSERT_ROW<-' ||
                                    X_calling_sequence;

       debug_info := 'Insert into ap_checks';
       AP_AC_TABLE_HANDLER_PKG.Insert_Row(
              X_Rowid,
              X_Amount,
              X_Ce_Bank_Acct_Use_Id,
              X_Bank_Account_Name,
              X_Check_Date,
              X_Check_Id,
              X_Check_Number,
              X_Currency_Code,
              X_Last_Updated_By,
              X_Last_Update_Date,
          --IBY:SP    X_Payment_Method_Lookup_Code,
              X_Payment_Type_Flag,
              X_Address_Line1,
              X_Address_Line2,
              X_Address_Line3,
              X_Checkrun_Name,
              X_Check_Format_Id,
              X_Check_Stock_Id,
              X_City,
              X_Country,
              X_Created_By,
              X_Creation_Date,
              X_Last_Update_Login,
              X_Status_Lookup_Code,
              X_Vendor_Name,
              X_Vendor_Site_Code,
              X_External_Bank_Account_Id,
              X_Zip,
              X_Bank_Account_Num,
              X_Bank_Account_Type,
              X_Bank_Num,
              X_Check_Voucher_Num,
              X_Cleared_Amount,
              X_Cleared_Date,
              X_Doc_Category_Code,
              X_Doc_Sequence_Id,
              X_Doc_Sequence_Value,
              X_Province,
              X_Released_Date,
              X_Released_By,
              X_State,
              X_Stopped_Date,
              X_Stopped_By,
              X_Void_Date,
              X_Attribute1,
              X_Attribute10,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute15,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute_Category,
              X_Future_Pay_Due_Date,
              X_Treasury_Pay_Date,
              X_Treasury_Pay_Number,
           -- Removed for bug 4277744
           -- X_Ussgl_Transaction_Code,
           -- X_Ussgl_Trx_Code_Context,
              X_Withholding_Status_Lkup_Code,
              X_Reconciliation_Batch_Id,
              X_Cleared_Base_Amount,
              X_Cleared_Exchange_Rate,
              X_Cleared_Exchange_Date,
              X_Cleared_Exchange_Rate_Type,
              X_Address_Line4,
              X_County,
              X_Address_Style,
              X_Org_Id,
              X_Vendor_Id,
              X_Vendor_Site_Id,
              X_Exchange_Rate,
              X_Exchange_Date,
              X_Exchange_Rate_Type,
              X_Base_Amount,
              X_Checkrun_Id,
              X_global_attribute_category,
              X_global_attribute1,
              X_global_attribute2,
              X_global_attribute3,
              X_global_attribute4,
              X_global_attribute5,
              X_global_attribute6,
              X_global_attribute7,
              X_global_attribute8,
              X_global_attribute9,
              X_global_attribute10,
              X_global_attribute11,
              X_global_attribute12,
              X_global_attribute13,
              X_global_attribute14,
              X_global_attribute15,
              X_global_attribute16,
              X_global_attribute17,
              X_global_attribute18,
              X_global_attribute19,
              X_global_attribute20,
              X_transfer_priority,
              X_maturity_exchange_rate_type,
              X_maturity_exchange_date,
              X_maturity_exchange_rate,
              X_description,
              X_anticipated_value_date,
              X_actual_value_date,
              x_payment_method_code,
              x_payment_profile_id,
              x_bank_charge_bearer,
              x_settlement_priority,
              x_payment_document_id,
              x_party_id,
              x_party_site_id,
              x_legal_entity_id,
              x_payment_id,
          current_calling_sequence,
	       X_Remit_To_Supplier_Name,
	       X_Remit_To_Supplier_Id,
	       X_Remit_To_Supplier_Site,
	       X_Remit_To_Supplier_Site_Id,
	       X_Relationship_ID ,
	       x_paycard_authorization_number,
	       X_paycard_reference_id
             );


    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid ||
                                   ', CHECK_ID = ' || TO_CHAR(X_Check_Id));
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Amount                           NUMBER,
                     X_Ce_Bank_Acct_Use_Id              NUMBER,
                     X_Bank_Account_Name                VARCHAR2,
                     X_Check_Date                       DATE,
                     X_Check_Id                         NUMBER,
                     X_Check_Number                     NUMBER,
                     X_Currency_Code                    VARCHAR2,
              --IBY:SP       X_Payment_Method_Lookup_Code       VARCHAR2,
                     X_Payment_Type_Flag                VARCHAR2,
                     X_Address_Line1                    VARCHAR2 DEFAULT NULL,
                     X_Address_Line2                    VARCHAR2 DEFAULT NULL,
                     X_Address_Line3                    VARCHAR2 DEFAULT NULL,
                     X_Checkrun_Name                    VARCHAR2 DEFAULT NULL,
                     X_Check_Format_Id                  NUMBER DEFAULT NULL,
                     X_Check_Stock_Id                   NUMBER DEFAULT NULL,
                     X_City                             VARCHAR2 DEFAULT NULL,
                     X_Country                          VARCHAR2 DEFAULT NULL,
                     X_Status_Lookup_Code               VARCHAR2 DEFAULT NULL,
                     X_Vendor_Name                      VARCHAR2 DEFAULT NULL,
                     X_Vendor_Site_Code                 VARCHAR2 DEFAULT NULL,
                     X_External_Bank_Account_Id         NUMBER,
                     X_Zip                              VARCHAR2 DEFAULT NULL,
                     X_Bank_Account_Num                 VARCHAR2 DEFAULT NULL,
                     X_Bank_Account_Type                VARCHAR2 DEFAULT NULL,
                     X_Bank_Num                         VARCHAR2 DEFAULT NULL,
                     X_Check_Voucher_Num                NUMBER DEFAULT NULL,
                     X_Cleared_Amount                   NUMBER DEFAULT NULL,
                     X_Cleared_Date                     DATE DEFAULT NULL,
                     X_Doc_Category_Code                VARCHAR2 DEFAULT NULL,
                     X_Doc_Sequence_Id                  NUMBER DEFAULT NULL,
                     X_Doc_Sequence_Value               NUMBER DEFAULT NULL,
                     X_Province                         VARCHAR2 DEFAULT NULL,
                     X_Released_Date                    DATE DEFAULT NULL,
                     X_Released_By                      NUMBER DEFAULT NULL,
                     X_State                            VARCHAR2 DEFAULT NULL,
                     X_Stopped_Date                     DATE DEFAULT NULL,
                     X_Stopped_By                       NUMBER DEFAULT NULL,
                     X_Void_Date                        DATE DEFAULT NULL,
                     X_Attribute1                       VARCHAR2 DEFAULT NULL,
                     X_Attribute10                      VARCHAR2 DEFAULT NULL,
                     X_Attribute11                      VARCHAR2 DEFAULT NULL,
                     X_Attribute12                      VARCHAR2 DEFAULT NULL,
                     X_Attribute13                      VARCHAR2 DEFAULT NULL,
                     X_Attribute14                      VARCHAR2 DEFAULT NULL,
                     X_Attribute15                      VARCHAR2 DEFAULT NULL,
                     X_Attribute2                       VARCHAR2 DEFAULT NULL,
                     X_Attribute3                       VARCHAR2 DEFAULT NULL,
                     X_Attribute4                       VARCHAR2 DEFAULT NULL,
                     X_Attribute5                       VARCHAR2 DEFAULT NULL,
                     X_Attribute6                       VARCHAR2 DEFAULT NULL,
                     X_Attribute7                       VARCHAR2 DEFAULT NULL,
                     X_Attribute8                       VARCHAR2 DEFAULT NULL,
                     X_Attribute9                       VARCHAR2 DEFAULT NULL,
                     X_Attribute_Category               VARCHAR2 DEFAULT NULL,
                     X_Future_Pay_Due_Date              DATE DEFAULT NULL,
                     X_Treasury_Pay_Date                DATE DEFAULT NULL,
                     X_Treasury_Pay_Number              NUMBER DEFAULT NULL,
                  -- Removed for bug 4277744
                  -- X_Ussgl_Transaction_Code           VARCHAR2 DEFAULT NULL,
                  -- X_Ussgl_Trx_Code_Context           VARCHAR2 DEFAULT NULL,
                     X_Withholding_Status_Lkup_Code   VARCHAR2 DEFAULT NULL,
                     X_Reconciliation_Batch_Id          NUMBER DEFAULT NULL,
                     X_Cleared_Base_Amount              NUMBER DEFAULT NULL,
                     X_Cleared_Exchange_Rate            NUMBER DEFAULT NULL,
                     X_Cleared_Exchange_Date            DATE DEFAULT NULL,
                     X_Cleared_Exchange_Rate_Type       VARCHAR2 DEFAULT NULL,
                     X_Address_Line4                    VARCHAR2 DEFAULT NULL,
                     X_County                           VARCHAR2 DEFAULT NULL,
                     X_Address_Style                    VARCHAR2 DEFAULT NULL,
                     X_Org_Id                           NUMBER DEFAULT NULL,
                     X_Vendor_Id                        NUMBER,
                     X_Vendor_Site_Id                   NUMBER,
                     X_Exchange_Rate                    NUMBER DEFAULT NULL,
                     X_Exchange_Date                    DATE DEFAULT NULL,
                     X_Exchange_Rate_Type               VARCHAR2 DEFAULT NULL,
                     X_Base_Amount                      NUMBER DEFAULT NULL,
                     X_Checkrun_Id                      NUMBER DEFAULT NULL,
                     X_global_attribute_category        VARCHAR2 DEFAULT NULL,
                     X_global_attribute1                VARCHAR2 DEFAULT NULL,
                     X_global_attribute2                VARCHAR2 DEFAULT NULL,
                     X_global_attribute3                VARCHAR2 DEFAULT NULL,
                     X_global_attribute4                VARCHAR2 DEFAULT NULL,
                     X_global_attribute5                VARCHAR2 DEFAULT NULL,
                     X_global_attribute6                VARCHAR2 DEFAULT NULL,
                     X_global_attribute7                VARCHAR2 DEFAULT NULL,
                     X_global_attribute8                VARCHAR2 DEFAULT NULL,
                     X_global_attribute9                VARCHAR2 DEFAULT NULL,
                     X_global_attribute10               VARCHAR2 DEFAULT NULL,
                     X_global_attribute11               VARCHAR2 DEFAULT NULL,
                     X_global_attribute12               VARCHAR2 DEFAULT NULL,
                     X_global_attribute13               VARCHAR2 DEFAULT NULL,
                     X_global_attribute14               VARCHAR2 DEFAULT NULL,
                     X_global_attribute15               VARCHAR2 DEFAULT NULL,
                     X_global_attribute16               VARCHAR2 DEFAULT NULL,
                     X_global_attribute17               VARCHAR2 DEFAULT NULL,
                     X_global_attribute18               VARCHAR2 DEFAULT NULL,
                     X_global_attribute19               VARCHAR2 DEFAULT NULL,
                     X_global_attribute20               VARCHAR2 DEFAULT NULL,
                     X_transfer_priority                VARCHAR2 DEFAULT NULL,
                     X_maturity_exchange_rate_type    VARCHAR2 DEFAULT NULL,
                     X_maturity_exchange_date        DATE DEFAULT NULL,
                     X_maturity_exchange_rate        NUMBER DEFAULT NULL,
                     X_description            VARCHAR2 DEFAULT NULL,
                     X_anticipated_value_date        DATE DEFAULT NULL,
                     X_actual_value_date        DATE DEFAULT NULL,
                     x_payment_method_code            VARCHAR2 DEFAULT NULL,
                     x_payment_profile_id             NUMBER DEFAULT NULL,
                     x_bank_charge_bearer             VARCHAR2 DEFAULT NULL,
                     x_settlement_priority            VARCHAR2 DEFAULT NULL,
                     x_payment_document_id            NUMBER DEFAULT NULL,
                     x_party_id                       NUMBER DEFAULT NULL,
                     x_party_site_id                  NUMBER DEFAULT NULL,
                     x_legal_entity_id                NUMBER DEFAULT NULL,
                     x_payment_id                     NUMBER DEFAULT NULL,
                     X_calling_sequence        IN    VARCHAR2,
			X_Remit_To_Supplier_Name	VARCHAR2 DEFAULT NULL,
			X_Remit_To_Supplier_Id	Number DEFAULT NULL,
			X_Remit_To_Supplier_Site	VARCHAR2 DEFAULT NULL,
			X_Remit_To_Supplier_Site_Id	NUMBER DEFAULT NULL,
			X_Relationship_Id			NUMBER DEFAULT NULL,
			X_paycard_authorization_number VARCHAR2 DEFAULT NULL,
                        X_paycard_reference_id NUMBER DEFAULT NULL
  ) IS


    --Modified below cursor for bug #8236815/8348653
   --Added rtrim for all varchar2 fields.

    CURSOR C IS
        SELECT
          ACTUAL_VALUE_DATE,
          ANTICIPATED_VALUE_DATE,
          AMOUNT,
          CE_BANK_ACCT_USE_ID,
          rtrim(BANK_ACCOUNT_NAME) BANK_ACCOUNT_NAME,
          CHECK_DATE,
          CHECK_ID,
          CHECK_NUMBER,
          rtrim(CURRENCY_CODE) CURRENCY_CODE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
        --IBY:SP
          --Bug5949912, bug6312110
          rtrim(PAYMENT_METHOD_LOOKUP_CODE) PAYMENT_METHOD_LOOKUP_CODE,
          rtrim(PAYMENT_TYPE_FLAG) payment_type_flag,
          -- Bug 6620381. trimming trailing space for the address lines
          rtrim(ADDRESS_LINE1) ADDRESS_LINE1,
          rtrim(ADDRESS_LINE2) ADDRESS_LINE2,
          rtrim(ADDRESS_LINE3) ADDRESS_LINE3,
          rtrim(CHECKRUN_NAME) checkrun_name,
          -- CHECK_FORMAT_ID,  Bug 5460922. Removing these fields from cursor
          -- CHECK_STOCK_ID,   as these fields are no longer used in R12.
          rtrim(CITY) CITY,
          rtrim(COUNTRY) country,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATE_LOGIN,
          rtrim(STATUS_LOOKUP_CODE) STATUS_LOOKUP_CODE,
	  --bug7670430 trimming trailing spaces for vendor_name
          rtrim(VENDOR_NAME) VENDOR_NAME ,
          rtrim(VENDOR_SITE_CODE) VENDOR_SITE_CODE,
          rtrim(ZIP) ZIP,
          BANK_ACCOUNT_NUM,
          BANK_ACCOUNT_TYPE,
          BANK_NUM,
          CHECK_VOUCHER_NUM,
          CLEARED_AMOUNT,
          CLEARED_DATE,
          DOC_CATEGORY_CODE,
          DOC_SEQUENCE_ID,
          DOC_SEQUENCE_VALUE,
          rtrim(PROVINCE) PROVINCE,
          RELEASED_AT,
          RELEASED_BY,
          rtrim(STATE) STATE,
          STOPPED_AT,
          STOPPED_BY,
          VOID_DATE,
          ATTRIBUTE1,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          rtrim(ATTRIBUTE_CATEGORY) ATTRIBUTE_CATEGORY,
          FUTURE_PAY_DUE_DATE,
          TREASURY_PAY_DATE,
          TREASURY_PAY_NUMBER,
       -- Removed for bug 4277744
       -- USSGL_TRANSACTION_CODE,
       -- USSGL_TRX_CODE_CONTEXT,
          rtrim(WITHHOLDING_STATUS_LOOKUP_CODE) WITHHOLDING_STATUS_LOOKUP_CODE,
          RECONCILIATION_BATCH_ID,
          CLEARED_BASE_AMOUNT,
          CLEARED_EXCHANGE_RATE,
          CLEARED_EXCHANGE_DATE,
          CLEARED_EXCHANGE_RATE_TYPE,
          rtrim(ADDRESS_LINE4) ADDRESS_LINE4,
          rtrim(COUNTY) COUNTY,
          rtrim(ADDRESS_STYLE) ADDRESS_STYLE,
          ORG_ID,
          VENDOR_ID,
          VENDOR_SITE_ID,
          EXCHANGE_RATE,
          EXCHANGE_DATE,
          EXCHANGE_RATE_TYPE,
          BASE_AMOUNT,
          CHECKRUN_ID,
          REQUEST_ID,
          CLEARED_ERROR_AMOUNT,
          CLEARED_CHARGES_AMOUNT,
          CLEARED_ERROR_BASE_AMOUNT,
          CLEARED_CHARGES_BASE_AMOUNT,
          rtrim(POSITIVE_PAY_STATUS_CODE),
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
          TRANSFER_PRIORITY,
          EXTERNAL_BANK_ACCOUNT_ID,
          STAMP_DUTY_AMT,
          STAMP_DUTY_BASE_AMT,
          -- MRC_CLEARED_BASE_AMOUNT,  Bug 5460922
          -- MRC_CLEARED_EXCHANGE_RATE,
          -- MRC_CLEARED_EXCHANGE_DATE,
          -- MRC_CLEARED_EXCHANGE_RATE_TYPE,
          -- MRC_EXCHANGE_RATE,
          -- MRC_EXCHANGE_DATE,
          -- MRC_EXCHANGE_RATE_TYPE,
          -- MRC_BASE_AMOUNT,
          -- MRC_CLEARED_ERROR_BASE_AMOUNT,
          -- MRC_CLEARED_CHARGES_BASE_AMT,
          -- MRC_STAMP_DUTY_BASE_AMT,
          MATURITY_EXCHANGE_DATE,
          MATURITY_EXCHANGE_RATE_TYPE,
          MATURITY_EXCHANGE_RATE,
          rtrim(DESCRIPTION) DESCRIPTION,
          RELEASED_DATE,
          STOPPED_DATE,
          -- MRC_MATURITY_EXG_DATE,  Bug 5460922
          -- MRC_MATURITY_EXG_RATE,
          -- MRC_MATURITY_EXG_RATE_TYPE,
          rtrim(PAYMENT_METHOD_CODE) PAYMENT_METHOD_CODE,
          PAYMENT_PROFILE_ID,
          rtrim(BANK_CHARGE_BEARER) BANK_CHARGE_BEARER,
          SETTLEMENT_PRIORITY,
          PAYMENT_DOCUMENT_ID,
          PARTY_ID,
          PARTY_SITE_ID,
          legal_entity_id,
          payment_id,
	  rtrim(Remit_To_Supplier_Name) Remit_To_Supplier_Name,
	  Remit_To_Supplier_Id,
	  rtrim(Remit_To_Supplier_Site) Remit_To_Supplier_Site,
	  Remit_To_Supplier_Site_Id,
	  Relationship_Id,
	  Paycard_authorization_number,
	  Paycard_reference_id
        FROM   ap_checks_all
        WHERE  rowid = X_Rowid
        FOR UPDATE of Check_Id NOWAIT;
    Recinfo C%ROWTYPE;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);


  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_CHECKS_PKG.LOCK_ROW<-' ||
                                 X_calling_sequence;

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;

    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - ROW NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;
    if (

               (Recinfo.amount =  X_Amount)
           AND ((Recinfo.ce_bank_acct_use_id =  X_Ce_Bank_Acct_Use_Id)
               OR (    (Recinfo.ce_bank_acct_use_id IS NULL)
                    AND (X_Ce_Bank_Acct_Use_Id IS NULL)))
           AND (Recinfo.bank_account_name =  X_Bank_Account_Name)
           AND (Recinfo.check_date =  X_Check_Date)
           AND (Recinfo.check_id =  X_Check_Id)
           AND (Recinfo.check_number =  X_Check_Number)
           AND (Recinfo.currency_code =  X_Currency_Code)
       --IBY:SP    AND (Recinfo.payment_method_lookup_code =  X_Payment_Method_Lookup_Code)
           AND (Recinfo.payment_type_flag =  X_Payment_Type_Flag)
           AND (Recinfo.org_id = X_Org_Id)
           AND (   (Recinfo.address_line1 =  X_Address_Line1)
                OR (    (Recinfo.address_line1 IS NULL)
                    AND (X_Address_Line1 IS NULL)))
           AND (   (Recinfo.address_line2 =  X_Address_Line2)
                OR (    (Recinfo.address_line2 IS NULL)
                    AND (X_Address_Line2 IS NULL)))
           AND (   (Recinfo.address_line3 =  X_Address_Line3)
                OR (    (Recinfo.address_line3 IS NULL)
                    AND (X_Address_Line3 IS NULL)))
           AND (   (Recinfo.checkrun_name =  X_Checkrun_Name)
                OR (    (Recinfo.checkrun_name IS NULL)
                    AND (X_Checkrun_Name IS NULL)))
           /* AND (   (Recinfo.check_format_id =  X_Check_Format_Id)
                OR (    (Recinfo.check_format_id IS NULL)
                    AND (X_Check_Format_Id IS NULL)))
           AND (   (Recinfo.check_stock_id =  X_Check_Stock_Id)
                OR (    (Recinfo.check_stock_id IS NULL)
                    AND (X_Check_Stock_Id IS NULL)))*/ -- Bug 5460922
           AND (   (Recinfo.city =  X_City)
                OR (    (Recinfo.city IS NULL)
                    AND (X_City IS NULL)))
           AND (   (Recinfo.country =  X_Country)
                OR (    (Recinfo.country IS NULL)
                    AND (X_Country IS NULL)))
           AND (   (Recinfo.status_lookup_code =  X_Status_Lookup_Code)
                OR (    (Recinfo.status_lookup_code IS NULL)
                    AND (X_Status_Lookup_Code IS NULL)))
           AND (   (Recinfo.vendor_name =  X_Vendor_Name)
                OR (    (Recinfo.vendor_name IS NULL)
                    AND (X_Vendor_Name IS NULL)))
           AND (   (Recinfo.vendor_site_code =  X_Vendor_Site_Code)
                OR (    (Recinfo.vendor_site_code IS NULL)
                    AND (X_Vendor_Site_Code IS NULL)))
           AND (   (Recinfo.external_bank_Account_id =  X_external_bank_Account_id)
                OR (    (Recinfo.external_bank_Account_id IS NULL)
                    AND (X_external_bank_Account_id IS NULL)))
           AND (   (Recinfo.zip =  X_Zip)
                OR (    (Recinfo.zip IS NULL)
                    AND (X_Zip IS NULL)))
           AND (   (Recinfo.bank_account_num =  X_Bank_Account_Num)
                OR (    (Recinfo.bank_account_num IS NULL)
                    AND (X_Bank_Account_Num IS NULL)))
           AND (   (Recinfo.bank_account_type =  X_Bank_Account_Type)
                OR (    (Recinfo.bank_account_type IS NULL)
                    AND (X_Bank_Account_Type IS NULL)))
           AND (   (Recinfo.bank_num =  X_Bank_Num)
                OR (    (Recinfo.bank_num IS NULL)
                    AND (X_Bank_Num IS NULL)))
           AND (   (Recinfo.check_voucher_num =  X_Check_Voucher_Num)
                OR (    (Recinfo.check_voucher_num IS NULL)
                    AND (X_Check_Voucher_Num IS NULL)))
           AND (   (Recinfo.cleared_amount =  X_Cleared_Amount)
                OR (    (Recinfo.cleared_amount IS NULL)
                    AND (X_Cleared_Amount IS NULL)))
           AND (   (Recinfo.cleared_date =  X_Cleared_Date)
                OR (    (Recinfo.cleared_date IS NULL)
                    AND (X_Cleared_Date IS NULL)))
           AND (   (Recinfo.doc_category_code =  X_Doc_Category_Code)
                OR (    (Recinfo.doc_category_code IS NULL)
                    AND (X_Doc_Category_Code IS NULL)))
           AND (   (Recinfo.doc_sequence_id =  X_Doc_Sequence_Id)
                OR (    (Recinfo.doc_sequence_id IS NULL)
                    AND (X_Doc_Sequence_Id IS NULL)))
           AND (   (Recinfo.doc_sequence_value =  X_Doc_Sequence_Value)
                OR (    (Recinfo.doc_sequence_value IS NULL)
                    AND (X_Doc_Sequence_Value IS NULL)))
           AND (   (Recinfo.province =  X_Province)
                OR (    (Recinfo.province IS NULL)
                    AND (X_Province IS NULL)))
           AND (   (Recinfo.released_date =  X_Released_Date)
                OR (    (Recinfo.released_date IS NULL)
                    AND (X_Released_Date IS NULL)))
           AND (   (Recinfo.released_by =  X_Released_By)
                OR (    (Recinfo.released_by IS NULL)
                    AND (X_Released_By IS NULL)))
           AND (   (Recinfo.state =  X_State)
                OR (    (Recinfo.state IS NULL)
                    AND (X_State IS NULL)))
           AND (   (Recinfo.stopped_date =  X_Stopped_Date)
                OR (    (Recinfo.stopped_date IS NULL)
                    AND (X_Stopped_Date IS NULL)))
           AND (   (Recinfo.stopped_by =  X_Stopped_By)
                OR (    (Recinfo.stopped_by IS NULL)
                    AND (X_Stopped_By IS NULL)))
           AND (   (Recinfo.void_date =  X_Void_Date)
                OR (    (Recinfo.void_date IS NULL)
                    AND (X_Void_Date IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           )then

            if(    (   (Recinfo.attribute11 =  X_Attribute11)
                    OR (    (Recinfo.attribute11 IS NULL)
                        AND (X_Attribute11 IS NULL)))
               AND (   (Recinfo.attribute12 =  X_Attribute12)
                    OR (    (Recinfo.attribute12 IS NULL)
                        AND (X_Attribute12 IS NULL)))
               AND (   (Recinfo.attribute13 =  X_Attribute13)
                    OR (    (Recinfo.attribute13 IS NULL)
                        AND (X_Attribute13 IS NULL)))
               AND (   (Recinfo.attribute14 =  X_Attribute14)
                    OR (    (Recinfo.attribute14 IS NULL)
                        AND (X_Attribute14 IS NULL)))
               AND (   (Recinfo.attribute15 =  X_Attribute15)
                    OR (    (Recinfo.attribute15 IS NULL)
                        AND (X_Attribute15 IS NULL)))
               AND (   (Recinfo.attribute2 =  X_Attribute2)
                    OR (    (Recinfo.attribute2 IS NULL)
                        AND (X_Attribute2 IS NULL)))
               AND (   (Recinfo.attribute3 =  X_Attribute3)
                    OR (    (Recinfo.attribute3 IS NULL)
                        AND (X_Attribute3 IS NULL)))
               AND (   (Recinfo.attribute4 =  X_Attribute4)
                    OR (    (Recinfo.attribute4 IS NULL)
                        AND (X_Attribute4 IS NULL)))
               AND (   (Recinfo.attribute5 =  X_Attribute5)
                    OR (    (Recinfo.attribute5 IS NULL)
                        AND (X_Attribute5 IS NULL)))
               AND (   (Recinfo.attribute6 =  X_Attribute6)
                    OR (    (Recinfo.attribute6 IS NULL)
                        AND (X_Attribute6 IS NULL)))
               AND (   (Recinfo.attribute7 =  X_Attribute7)
                    OR (    (Recinfo.attribute7 IS NULL)
                        AND (X_Attribute7 IS NULL)))
               AND (   (Recinfo.attribute8 =  X_Attribute8)
                    OR (    (Recinfo.attribute8 IS NULL)
                        AND (X_Attribute8 IS NULL)))
               AND (   (Recinfo.attribute9 =  X_Attribute9)
                    OR (    (Recinfo.attribute9 IS NULL)
                        AND (X_Attribute9 IS NULL)))
               /* Commented for bug#6976792 Start
               AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                    OR (    (Recinfo.attribute_category IS NULL)
                        AND (X_Attribute_Category IS NULL)))
               Commented for bug#6976792 End */
               AND (   (Recinfo.future_pay_due_date =  X_Future_Pay_Due_Date)
                    OR (    (Recinfo.future_pay_due_date IS NULL)
                        AND (X_Future_Pay_Due_Date IS NULL)))
               AND (   (Recinfo.treasury_pay_date =  X_Treasury_Pay_Date)
                    OR (    (Recinfo.treasury_pay_date IS NULL)
                        AND (X_Treasury_Pay_Date IS NULL)))
               AND (   (Recinfo.treasury_pay_number =  X_Treasury_Pay_Number)
                    OR (    (Recinfo.treasury_pay_number IS NULL)
                        AND (X_Treasury_Pay_Number IS NULL)))
            -- Removed for bug 4277744
            -- AND (   (Recinfo.ussgl_transaction_code =  X_Ussgl_Transaction_Code)
            --      OR (    (Recinfo.ussgl_transaction_code IS NULL)
            --          AND (X_Ussgl_Transaction_Code IS NULL)))
            -- AND (   (Recinfo.ussgl_trx_code_context =  X_Ussgl_Trx_Code_Context)
            --      OR (    (Recinfo.ussgl_trx_code_context IS NULL)
            --          AND (X_Ussgl_Trx_Code_Context IS NULL)))
               AND (   (Recinfo.withholding_status_lookup_code =  X_Withholding_Status_Lkup_Code)
                    OR (    (Recinfo.withholding_status_lookup_code IS NULL)
                         AND (X_Withholding_Status_Lkup_Code IS NULL)))
               AND (   (Recinfo.reconciliation_batch_id =  X_Reconciliation_Batch_Id)
                    OR (    (Recinfo.reconciliation_batch_id IS NULL)
                         AND (X_Reconciliation_Batch_Id IS NULL)))
               AND (   (Recinfo.cleared_base_amount =  X_Cleared_Base_Amount)
                    OR (    (Recinfo.cleared_base_amount IS NULL)
                         AND (X_Cleared_Base_Amount IS NULL)))
               AND (   (Recinfo.cleared_exchange_rate =  X_Cleared_Exchange_Rate)
                    OR (    (Recinfo.cleared_exchange_rate IS NULL)
                         AND (X_Cleared_Exchange_Rate IS NULL)))
               AND (   (Recinfo.cleared_exchange_date =  X_Cleared_Exchange_Date)
                    OR (    (Recinfo.cleared_exchange_date IS NULL)
                         AND (X_Cleared_Exchange_Date IS NULL)))
               AND (   (Recinfo.cleared_exchange_rate_type =  X_Cleared_Exchange_Rate_Type)
                    OR (    (Recinfo.cleared_exchange_rate_type IS NULL)
                         AND (X_Cleared_Exchange_Rate_Type IS NULL)))
               AND (   (Recinfo.address_line4 =  X_Address_Line4)
                    OR (    (Recinfo.address_line4 IS NULL)
                         AND (X_Address_Line4 IS NULL)))
               AND (   (Recinfo.county =  X_County)
                    OR (    (Recinfo.county IS NULL)
                         AND (X_County IS NULL)))
               AND (   (NVL(Recinfo.address_style,'DEFAULT') = X_Address_Style)
                    OR (    (Recinfo.address_style IS NULL)
                         AND (X_Address_Style IS NULL)))
               /* Bug 6628204. Vnedor_Id and Vendor_site_Id is not there for
                  paying Payment Request type invoice */
               AND (   (Recinfo.vendor_id =  x_vendor_id)
                    OR (    (Recinfo.vendor_id IS NULL)
                        AND (x_vendor_id IS NULL)))
               AND (   (Recinfo.vendor_site_id =  x_vendor_site_id)
                    OR (    (Recinfo.vendor_site_id IS NULL)
                        AND (x_vendor_site_id IS NULL)))
               AND (   (Recinfo.exchange_rate =  X_Exchange_Rate)
                    OR (    (Recinfo.exchange_rate IS NULL)
                         AND (X_Exchange_Rate IS NULL)))
               AND (   (Recinfo.exchange_date =  X_Exchange_Date)
                    OR (    (Recinfo.exchange_date IS NULL)
                         AND (X_Exchange_Date IS NULL)))
               AND (   (Recinfo.exchange_rate_type =  X_Exchange_Rate_Type)
                    OR (    (Recinfo.exchange_rate_type IS NULL)
                         AND (X_Exchange_Rate_Type IS NULL)))
               AND (   (Recinfo.base_amount =  X_Base_Amount)
                    OR (    (Recinfo.base_amount IS NULL)
                         AND (X_Base_Amount IS NULL)))
               AND (   (Recinfo.checkrun_id =  X_Checkrun_Id)
                    OR (    (Recinfo.checkrun_id IS NULL)
                         AND (X_Checkrun_Id IS NULL)))
               AND (   (Recinfo.global_attribute_category =  X_global_attribute_category)
                    OR (    (Recinfo.global_attribute_category IS NULL)
                        AND (X_global_attribute_category IS NULL)))
               AND (   (Recinfo.global_attribute1 =  X_global_attribute1)
                    OR (    (Recinfo.global_attribute1 IS NULL)
                        AND (X_global_attribute1 IS NULL)))
               AND (   (Recinfo.global_attribute2 =  X_global_attribute2)
                    OR (    (Recinfo.global_attribute2 IS NULL)
                        AND (X_global_attribute2 IS NULL)))
               AND (   (Recinfo.global_attribute3 =  X_global_attribute3)
                    OR (    (Recinfo.global_attribute3 IS NULL)
                        AND (X_global_attribute3 IS NULL)))
               AND (   (Recinfo.global_attribute4 =  X_global_attribute4)
                    OR (    (Recinfo.global_attribute4 IS NULL)
                        AND (X_global_attribute4 IS NULL)))
               AND (   (Recinfo.global_attribute5 =  X_global_attribute5)
                    OR (    (Recinfo.global_attribute5 IS NULL)
                        AND (X_global_attribute5 IS NULL)))
               AND (   (Recinfo.global_attribute6 =  X_global_attribute6)
                    OR (    (Recinfo.global_attribute6 IS NULL)
                        AND (X_global_attribute6 IS NULL)))
               AND (   (Recinfo.global_attribute7 =  X_global_attribute7)
                    OR (    (Recinfo.global_attribute7 IS NULL)
                        AND (X_global_attribute7 IS NULL)))
               AND (   (Recinfo.global_attribute8 =  X_global_attribute8)
                    OR (    (Recinfo.global_attribute8 IS NULL)
                        AND (X_global_attribute8 IS NULL)))
               AND (   (Recinfo.global_attribute9 =  X_global_attribute9)
                    OR (    (Recinfo.global_attribute9 IS NULL)
                        AND (X_global_attribute9 IS NULL)))
               AND (   (Recinfo.global_attribute10 =  X_global_attribute10)
                    OR (    (Recinfo.global_attribute10 IS NULL)
                        AND (X_global_attribute10 IS NULL)))
               AND (   (Recinfo.global_attribute11 =  X_global_attribute11)
                    OR (    (Recinfo.global_attribute11 IS NULL)
                        AND (X_global_attribute11 IS NULL)))
               AND (   (Recinfo.global_attribute12 =  X_global_attribute12)
                    OR (    (Recinfo.global_attribute12 IS NULL)
                        AND (X_global_attribute12 IS NULL)))
               AND (   (Recinfo.global_attribute13 =  X_global_attribute13)
                    OR (    (Recinfo.global_attribute13 IS NULL)
                        AND (X_global_attribute13 IS NULL)))
               AND (   (Recinfo.global_attribute14 =  X_global_attribute14)
                    OR (    (Recinfo.global_attribute14 IS NULL)
                        AND (X_global_attribute14 IS NULL)))
               AND (   (Recinfo.global_attribute15 =  X_global_attribute15)
                    OR (    (Recinfo.global_attribute15 IS NULL)
                        AND (X_global_attribute15 IS NULL)))
               AND (   (Recinfo.global_attribute16 =  X_global_attribute16)
                    OR (    (Recinfo.global_attribute16 IS NULL)
                        AND (X_global_attribute16 IS NULL)))
               AND (   (Recinfo.global_attribute17 =  X_global_attribute17)
                    OR (    (Recinfo.global_attribute17 IS NULL)
                        AND (X_global_attribute17 IS NULL)))
               AND (   (Recinfo.global_attribute18 =  X_global_attribute18)
                    OR (    (Recinfo.global_attribute18 IS NULL)
                        AND (X_global_attribute18 IS NULL)))
               AND (   (Recinfo.global_attribute19 =  X_global_attribute19)
                    OR (    (Recinfo.global_attribute19 IS NULL)
                        AND (X_global_attribute19 IS NULL)))
               AND (   (Recinfo.global_attribute20 =  X_global_attribute20)
                    OR (    (Recinfo.global_attribute20 IS NULL)
                        AND (X_global_attribute20 IS NULL)))
               AND (   (Recinfo.transfer_priority =  X_transfer_priority)
                    OR (    (Recinfo.transfer_priority IS NULL)
                        AND (X_transfer_priority IS NULL)))
               AND (   (Recinfo.maturity_exchange_rate_type =  X_maturity_exchange_rate_type)
                    OR (    (Recinfo.maturity_exchange_rate_type IS NULL)
                        AND (X_maturity_exchange_rate_type IS NULL)))
               AND (   (Recinfo.maturity_exchange_date =  X_maturity_exchange_date)
                    OR (    (Recinfo.maturity_exchange_date IS NULL)
                        AND (X_maturity_exchange_date IS NULL)))
               AND (   (Recinfo.maturity_exchange_rate =  X_maturity_exchange_rate)
                    OR (    (Recinfo.maturity_exchange_rate IS NULL)
                        AND (X_maturity_exchange_rate IS NULL)))
               AND (   (Recinfo.description =  X_description)
                    OR (    (Recinfo.description IS NULL)
                        AND (X_description IS NULL)))
               AND (   (Recinfo.anticipated_value_date =  X_anticipated_value_date)
                    OR (    (Recinfo.anticipated_value_date IS NULL)
                        AND (X_anticipated_value_date IS NULL)))

               AND (   (Recinfo.actual_value_date =  X_actual_value_date)
                    OR (    (Recinfo.actual_value_date IS NULL)
                        AND (X_actual_value_date IS NULL)))

                AND (   (Recinfo.payment_method_code =  x_payment_method_code)
                    OR (    (Recinfo.payment_method_code IS NULL)
                        AND (x_payment_method_code IS NULL)))

                AND (   (Recinfo.payment_profile_id =  x_payment_profile_id)
                    OR (    (Recinfo.payment_profile_id IS NULL)
                        AND (x_payment_profile_id IS NULL)))
                AND (   (Recinfo.bank_charge_bearer =  x_bank_charge_bearer)
                    OR (    (Recinfo.bank_charge_bearer IS NULL)
                        AND (x_bank_charge_bearer IS NULL)))
                AND (   (Recinfo.settlement_priority =  x_settlement_priority)
                    OR (    (Recinfo.settlement_priority IS NULL)
                        AND (x_settlement_priority IS NULL)))
                --Bug5949912, bug6312110
                AND (   (Recinfo.payment_document_id =  x_payment_document_id)
                    OR( (Recinfo.payment_document_id IS NULL)
                          AND (x_payment_document_id IS NULL))
                    OR( (Recinfo.payment_method_lookup_code is NOT NULL)
                          AND (x_payment_document_id is NULL)))
                 AND (   (Recinfo.party_id =  x_party_id)
                    OR (    (Recinfo.party_id IS NULL)
                        AND (x_party_id IS NULL)))
                AND (   (Recinfo.party_site_id =  x_party_site_id)
                    OR (    (Recinfo.party_site_id IS NULL)
                        AND (x_party_site_id IS NULL)))
                AND (   (Recinfo.legal_entity_id =  x_legal_entity_id)
                    OR (    (Recinfo.legal_entity_id IS NULL)
                        AND (x_legal_entity_id IS NULL)))
                AND (   (Recinfo.payment_id =  x_payment_id)
                    OR (    (Recinfo.payment_id IS NULL)
                        AND (x_payment_id IS NULL)))
                AND (   (Recinfo.remit_to_supplier_id =  x_remit_to_supplier_id)
                    OR (    (Recinfo.remit_to_supplier_id IS NULL)
                        AND (x_remit_to_supplier_id IS NULL)))
                AND (   (Recinfo.remit_to_supplier_site_id =  x_remit_to_supplier_site_id)
                    OR (    (Recinfo.remit_to_supplier_site_id IS NULL)
                        AND (x_remit_to_supplier_site_id IS NULL)))
                AND (   (Recinfo.relationship_id =  x_relationship_id)
                    OR (    (Recinfo.relationship_id IS NULL)
                        AND (x_relationship_id IS NULL)))
                AND (   (Recinfo.paycard_reference_id =  x_paycard_reference_id)
                    OR (    (Recinfo.paycard_reference_id IS NULL)
                        AND (x_paycard_reference_id IS NULL)))
         ) then

           /* Added for bug#6976792 Start */
           if (    Recinfo.attribute_category is null
               AND Recinfo.payment_type_flag = 'A'
              )
              OR
              (   (Recinfo.attribute_category =  X_Attribute_Category)
	       OR (    (Recinfo.attribute_category IS NULL)
                        AND (X_Attribute_Category IS NULL))
              )
           then
              return;
           else
              FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
              APP_EXCEPTION.Raise_Exception;
           end if;
           /* Added for bug#6976792 End */
           /* return; commented for bug#6976792 */
         else
           FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
           APP_EXCEPTION.Raise_Exception;
         end if;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    EXCEPTION
      WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           IF (SQLCODE = -54) THEN
             FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
           ELSE
             FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
             FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid ||
                                   ', CHECK_ID = ' || TO_CHAR(X_Check_Id));
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
     END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Amount                         NUMBER,
                       X_Ce_Bank_Acct_Use_Id            NUMBER,
                       X_Bank_Account_Name              VARCHAR2,
                       X_Check_Date                     DATE,
                       X_Check_Id                       NUMBER,
                       X_Check_Number                   NUMBER,
                       X_Currency_Code                  VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                   --IBY:SP    X_Payment_Method_Lookup_Code     VARCHAR2,
                       X_Payment_Type_Flag              VARCHAR2,
                       X_Address_Line1                  VARCHAR2 DEFAULT NULL,
                       X_Address_Line2                  VARCHAR2 DEFAULT NULL,
                       X_Address_Line3                  VARCHAR2 DEFAULT NULL,
                       X_Checkrun_Name                  VARCHAR2 DEFAULT NULL,
                       X_Check_Format_Id                NUMBER DEFAULT NULL,
                       X_Check_Stock_Id                 NUMBER DEFAULT NULL,
                       X_City                           VARCHAR2 DEFAULT NULL,
                       X_Country                        VARCHAR2 DEFAULT NULL,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Status_Lookup_Code             VARCHAR2 DEFAULT NULL,
                       X_Vendor_Name                    VARCHAR2 DEFAULT NULL,
                       X_Vendor_Site_Code               VARCHAR2 DEFAULT NULL,
                       X_External_Bank_Account_Id       NUMBER,
                       X_Zip                            VARCHAR2 DEFAULT NULL,
                       X_Bank_Account_Num               VARCHAR2 DEFAULT NULL,
                       X_Bank_Account_Type              VARCHAR2 DEFAULT NULL,
                       X_Bank_Num                       VARCHAR2 DEFAULT NULL,
                       X_Check_Voucher_Num              NUMBER DEFAULT NULL,
                       X_Cleared_Amount                 NUMBER DEFAULT NULL,
                       X_Cleared_Date                   DATE DEFAULT NULL,
                       X_Doc_Category_Code              VARCHAR2 DEFAULT NULL,
                       X_Doc_Sequence_Id                NUMBER DEFAULT NULL,
                       X_Doc_Sequence_Value             NUMBER DEFAULT NULL,
                       X_Province                       VARCHAR2 DEFAULT NULL,
                       X_Released_Date                  DATE DEFAULT NULL,
                       X_Released_By                    NUMBER DEFAULT NULL,
                       X_State                          VARCHAR2 DEFAULT NULL,
                       X_Stopped_Date                   DATE DEFAULT NULL,
                       X_Stopped_By                     NUMBER DEFAULT NULL,
                       X_Void_Date                      DATE DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute10                    VARCHAR2 DEFAULT NULL,
                       X_Attribute11                    VARCHAR2 DEFAULT NULL,
                       X_Attribute12                    VARCHAR2 DEFAULT NULL,
                       X_Attribute13                    VARCHAR2 DEFAULT NULL,
                       X_Attribute14                    VARCHAR2 DEFAULT NULL,
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Attribute6                     VARCHAR2 DEFAULT NULL,
                       X_Attribute7                     VARCHAR2 DEFAULT NULL,
                       X_Attribute8                     VARCHAR2 DEFAULT NULL,
                       X_Attribute9                     VARCHAR2 DEFAULT NULL,
                       X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                       X_Future_Pay_Due_Date            DATE DEFAULT NULL,
                       X_Treasury_Pay_Date              DATE DEFAULT NULL,
                       X_Treasury_Pay_Number            NUMBER DEFAULT NULL,
                    -- Removed for bug 4277744
                    -- X_Ussgl_Transaction_Code         VARCHAR2 DEFAULT NULL,
                    -- X_Ussgl_Trx_Code_Context         VARCHAR2 DEFAULT NULL,
                       X_Withholding_Status_Lkup_Code VARCHAR2 DEFAULT NULL,
                       X_Reconciliation_Batch_Id        NUMBER DEFAULT NULL,
                       X_Cleared_Base_Amount            NUMBER DEFAULT NULL,
                       X_Cleared_Exchange_Rate          NUMBER DEFAULT NULL,
                       X_Cleared_Exchange_Date          DATE DEFAULT NULL,
                       X_Cleared_Exchange_Rate_Type     VARCHAR2 DEFAULT NULL,
                       X_Address_Line4                  VARCHAR2 DEFAULT NULL,
                       X_County                         VARCHAR2 DEFAULT NULL,
                       X_Address_Style                  VARCHAR2 DEFAULT NULL,
                       X_Org_Id                         NUMBER DEFAULT NULL,
                       X_Vendor_Id                      NUMBER,
                       X_Vendor_Site_Id                 NUMBER,
                       X_Exchange_Rate                  NUMBER DEFAULT NULL,
                       X_Exchange_Date                  DATE DEFAULT NULL,
                       X_Exchange_Rate_Type             VARCHAR2 DEFAULT NULL,
                       X_Base_Amount                    NUMBER DEFAULT NULL,
                       X_Checkrun_Id                    NUMBER DEFAULT NULL,
                       X_global_attribute_category      VARCHAR2 DEFAULT NULL,
                       X_global_attribute1              VARCHAR2 DEFAULT NULL,
                       X_global_attribute2              VARCHAR2 DEFAULT NULL,
                       X_global_attribute3              VARCHAR2 DEFAULT NULL,
                       X_global_attribute4              VARCHAR2 DEFAULT NULL,
                       X_global_attribute5              VARCHAR2 DEFAULT NULL,
                       X_global_attribute6              VARCHAR2 DEFAULT NULL,
                       X_global_attribute7              VARCHAR2 DEFAULT NULL,
                       X_global_attribute8              VARCHAR2 DEFAULT NULL,
                       X_global_attribute9              VARCHAR2 DEFAULT NULL,
                       X_global_attribute10             VARCHAR2 DEFAULT NULL,
                       X_global_attribute11             VARCHAR2 DEFAULT NULL,
                       X_global_attribute12             VARCHAR2 DEFAULT NULL,
                       X_global_attribute13             VARCHAR2 DEFAULT NULL,
                       X_global_attribute14             VARCHAR2 DEFAULT NULL,
                       X_global_attribute15             VARCHAR2 DEFAULT NULL,
                       X_global_attribute16             VARCHAR2 DEFAULT NULL,
                       X_global_attribute17             VARCHAR2 DEFAULT NULL,
                       X_global_attribute18             VARCHAR2 DEFAULT NULL,
                       X_global_attribute19             VARCHAR2 DEFAULT NULL,
                       X_global_attribute20             VARCHAR2 DEFAULT NULL,
                       X_transfer_priority              VARCHAR2 DEFAULT NULL,
                       X_maturity_exchange_rate_type    VARCHAR2 DEFAULT NULL,
                       X_maturity_exchange_date        DATE DEFAULT NULL,
                       X_maturity_exchange_rate        NUMBER DEFAULT NULL,
                       X_description            VARCHAR2 DEFAULT NULL,
                       X_anticipated_value_date        DATE DEFAULT NULL,
                       X_actual_value_date        DATE DEFAULT NULL,
                       x_payment_method_code            VARCHAR2 DEFAULT NULL,
                       x_payment_profile_id             NUMBER DEFAULT NULL,
                       x_bank_charge_bearer             VARCHAR2 DEFAULT NULL,
                       x_settlement_priority            VARCHAR2 DEFAULT NULL,
                       x_payment_document_id            NUMBER DEFAULT NULL,
                       x_party_id                       NUMBER DEFAULT NULL,
                       x_party_site_id                  NUMBER DEFAULT NULL,
                       x_legal_entity_id                NUMBER DEFAULT NULL,
                       x_payment_id                     NUMBER DEFAULT NULL,
                       X_calling_sequence    IN    VARCHAR2,
		       X_Remit_To_Supplier_Name	VARCHAR2 DEFAULT NULL,
		       X_Remit_To_Supplier_Id	Number DEFAULT NULL,
		       X_Remit_To_Supplier_Site	VARCHAR2 DEFAULT NULL,
		       X_Remit_To_Supplier_Site_Id	NUMBER DEFAULT NULL,
		       X_Relationship_Id			NUMBER DEFAULT NULL,
		       X_paycard_authorization_number VARCHAR2 DEFAULT NULL,
                       X_paycard_reference_id NUMBER DEFAULT NULL
  ) IS
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);
  l_old_status_lookup_code    AP_CHECKS.status_lookup_code%TYPE;
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_CHECKS_PKG.UPDATE_ROW<-' ||
                                 X_calling_sequence;

--  We need to check if the payment is being matured/unmatured during this
--  updated, i.e. if the status_lookup_code is going from ISSUED to MATURED
--  or vice-versa. If yes, then we want to insert/delete a row in the
--  ap_payment_history table.
--  I am putting the logic to figure out NOCOPY if the status has changed in this
--  procedure because it is too messy and bug prone to put it in the form.
--  Some of the issues are - we will need to track the previous and new value
--  of the displayed field and then retrieve the lookup_codes to figure out NOCOPY
--  whether this has happened or not. This might be done in the WVI. However,
--  the actual insert/delete should be in the pre-update (maybe). What if the
--  user flips it back and forth a few times and we try to delete when no
--  row exists ......
--  There is a bit of performance hit here 'cos we are checking for this
--  even if the user did not touch this field, but that seems to be a fair
--  trade off. Of course, we should do this only if the payment is future
--  dated and X_status_lookup_code is either 'ISSUED' or 'NEGOTIABLE'.

    If ((X_future_pay_due_date is NOT NULL) AND
        (X_status_lookup_code in ('ISSUED', 'NEGOTIABLE')))
    Then

      debug_info := 'Retrieve existing status_lookup_code in the DB';
      SELECT  status_lookup_code
      INTO    l_old_status_lookup_code
      FROM    ap_checks_all
      WHERE   rowid = X_RowID;

      If (l_old_status_lookup_code = 'ISSUED' AND
          X_status_lookup_code = 'NEGOTIABLE')
      Then
         debug_info := 'Insert row in Ap_Payment_History for payment maturity';
         ap_reconciliation_pkg.recon_payment_history
        (X_CHECKRUN_ID          => NULL,
        X_CHECK_ID          => X_check_id,
        X_TRANSACTION_TYPE      => 'PAYMENT MATURITY',
        X_ACCOUNTING_DATE      => X_future_pay_due_date,
        X_CLEARED_DATE           => NULL,
        X_TRANSACTION_AMOUNT      => X_amount,
        X_ERROR_AMOUNT          => NULL,
        X_CHARGE_AMOUNT          => NULL,
        X_CURRENCY_CODE          => X_currency_code,
        X_EXCHANGE_RATE_TYPE      => X_maturity_exchange_rate_type,
        X_EXCHANGE_RATE_DATE      => X_maturity_exchange_date,
        X_EXCHANGE_RATE          => X_maturity_exchange_rate,
        X_MATCHED_FLAG          => NULL,
        X_ACTUAL_VALUE_DATE      => NULL,
        X_CREATION_DATE          => sysdate,
         X_CREATED_BY              => X_last_updated_by,
        X_LAST_UPDATE_DATE      => sysdate,
         X_LAST_UPDATED_BY         => X_last_updated_by,
         X_LAST_UPDATE_LOGIN       => X_last_update_login,
        X_PROGRAM_UPDATE_DATE      => NULL,
         X_PROGRAM_APPLICATION_ID  => NULL,
         X_PROGRAM_ID              => NULL,
         X_REQUEST_ID           => NULL,
            X_CALLING_SEQUENCE      => current_calling_sequence);
      Elsif (l_old_status_lookup_code = 'NEGOTIABLE' AND
             X_status_lookup_code = 'ISSUED')
      Then
         debug_info := 'Delete maturity row from ap_payment_history';
         ap_reconciliation_pkg.recon_payment_history
        (X_CHECKRUN_ID          => NULL,
        X_CHECK_ID          => X_check_id,
        X_TRANSACTION_TYPE      => 'PAYMENT MATURITY REVERSAL',
        X_ACCOUNTING_DATE      => X_future_pay_due_date,
        X_CLEARED_DATE           => NULL,
        X_TRANSACTION_AMOUNT      => X_amount,
        X_ERROR_AMOUNT          => NULL,
        X_CHARGE_AMOUNT          => NULL,
        X_CURRENCY_CODE          => X_currency_code,
        X_EXCHANGE_RATE_TYPE      => X_maturity_exchange_rate_type,
        X_EXCHANGE_RATE_DATE      => X_maturity_exchange_date,
        X_EXCHANGE_RATE          => X_maturity_exchange_rate,
        X_MATCHED_FLAG          => NULL,
        X_ACTUAL_VALUE_DATE      => NULL,
        X_CREATION_DATE          => sysdate,
         X_CREATED_BY              => X_last_updated_by,
        X_LAST_UPDATE_DATE      => sysdate,
         X_LAST_UPDATED_BY         => X_last_updated_by,
         X_LAST_UPDATE_LOGIN       => X_last_update_login,
        X_PROGRAM_UPDATE_DATE      => NULL,
         X_PROGRAM_APPLICATION_ID  => NULL,
         X_PROGRAM_ID              => NULL,
         X_REQUEST_ID           => NULL,
            X_CALLING_SEQUENCE      => current_calling_sequence);
      End If;

    End IF;

    debug_info := 'Update ap_checks';
    AP_AC_TABLE_HANDLER_PKG.Update_Row(
              X_Rowid,
              X_Amount,
              X_Ce_Bank_Acct_Use_Id,
              X_Bank_Account_Name,
              X_Check_Date,
              X_Check_Id,
              X_Check_Number,
              X_Currency_Code,
              X_Last_Updated_By,
              X_Last_Update_Date,
         --IBY:SP     X_Payment_Method_Lookup_Code,
              X_Payment_Type_Flag,
              X_Address_Line1,
              X_Address_Line2,
              X_Address_Line3,
              X_Checkrun_Name,
              X_Check_Format_Id,
              X_Check_Stock_Id,
              X_City,
              X_Country,
              X_Last_Update_Login,
              X_Status_Lookup_Code,
              X_Vendor_Name,
              X_Vendor_Site_Code,
              X_External_Bank_Account_Id,
              X_Zip,
              X_Bank_Account_Num,
              X_Bank_Account_Type,
              X_Bank_Num,
              X_Check_Voucher_Num,
              X_Cleared_Amount,
              X_Cleared_Date,
              X_Doc_Category_Code,
              X_Doc_Sequence_Id,
              X_Doc_Sequence_Value,
              X_Province,
              X_Released_Date,
              X_Released_By,
              X_State,
              X_Stopped_Date,
              X_Stopped_By,
              X_Void_Date,
              X_Attribute1,
              X_Attribute10,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute15,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute_Category,
              X_Future_Pay_Due_Date,
              X_Treasury_Pay_Date,
              X_Treasury_Pay_Number,
           -- Removed for bug 4277744
           -- X_Ussgl_Transaction_Code,
           -- X_Ussgl_Trx_Code_Context,
              X_Withholding_Status_Lkup_Code,
              X_Reconciliation_Batch_Id,
              X_Cleared_Base_Amount,
              X_Cleared_Exchange_Rate,
              X_Cleared_Exchange_Date,
              X_Cleared_Exchange_Rate_Type,
              X_Address_Line4,
              X_County,
              X_Address_Style,
              X_Org_Id,
              X_Vendor_Id,
              X_Vendor_Site_Id,
              X_Exchange_Rate,
              X_Exchange_Date,
              X_Exchange_Rate_Type,
              X_Base_Amount,
              X_Checkrun_Id,
              X_global_attribute_category,
              X_global_attribute1,
              X_global_attribute2,
              X_global_attribute3,
              X_global_attribute4,
              X_global_attribute5,
              X_global_attribute6,
              X_global_attribute7,
              X_global_attribute8,
              X_global_attribute9,
              X_global_attribute10,
              X_global_attribute11,
              X_global_attribute12,
              X_global_attribute13,
              X_global_attribute14,
              X_global_attribute15,
              X_global_attribute16,
              X_global_attribute17,
              X_global_attribute18,
              X_global_attribute19,
              X_global_attribute20,
              X_transfer_priority,
              X_maturity_exchange_rate_type,
              X_maturity_exchange_date,
              X_maturity_exchange_rate,
              X_description,
              X_anticipated_value_date,
              X_actual_value_date,
              x_payment_method_code,
              x_payment_profile_id,
              x_bank_charge_bearer,
              x_settlement_priority,
              x_payment_document_id,
              x_party_id,
              x_party_site_id,
              x_legal_entity_id,
              x_payment_id,
              current_calling_sequence,
	       X_Remit_To_Supplier_Name,
	       X_Remit_To_Supplier_Id,
	       X_Remit_To_Supplier_Site,
	       X_Remit_To_Supplier_Site_Id,
	       X_Relationship_Id,
	       x_paycard_authorization_number,
	       x_paycard_reference_id
             );


    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid ||
                                   ', CHECK_ID = ' || TO_CHAR(X_Check_Id));
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid                 VARCHAR2,
               X_calling_sequence    IN    VARCHAR2) IS
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_CHECKS_PKG.DELETE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Delete from ap_checks';
    AP_AC_TABLE_HANDLER_PKG.Delete_Row(
      X_Rowid,
      current_calling_sequence);

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Delete_Row;

  -----------------------------------------------------------------------
  -- Function get_invoices_paid returns a comma delimited list of
  -- invoices paid by this check.
  --
  FUNCTION get_invoices_paid (l_check_id IN NUMBER)
      RETURN VARCHAR2
  IS
      l_inv_num        AP_INVOICES.INVOICE_NUM%TYPE;
      l_inv_num_list    VARCHAR2(2000) := NULL;

      -------------------------------------------------------------------
      -- Declare cursor to return the Invoice number
      --
      CURSOR inv_num_cursor IS
      SELECT ai.invoice_num
      FROM   ap_invoices         ai,
         ap_invoice_payments aip
      WHERE  aip.check_id   = l_check_id
      AND    aip.invoice_id = ai.invoice_id;

  BEGIN

      OPEN inv_num_cursor;

      LOOP
      FETCH inv_num_cursor INTO l_inv_num;
      EXIT WHEN inv_num_cursor%NOTFOUND;

      IF (l_inv_num_list IS NOT NULL) THEN
          l_inv_num_list := l_inv_num_list || ', ';
      END IF;

      l_inv_num_list := l_inv_num_list || l_inv_num;

      END LOOP;

      CLOSE inv_num_cursor;

      RETURN(l_inv_num_list);

  END get_invoices_paid;

  -----------------------------------------------------------------------
  -- Function is_maturity_accounted returns TRUE if the maturity event
  -- has been accounted for, i.e. a PAYMENT MATURITY row exists in
  -- ap_payment_history for this payment with posted_flag = 'Y'.
  -- Otherwise it returns a FALSE.
  --
  FUNCTION is_maturity_accounted(X_check_id        IN NUMBER,
                                 X_calling_sequence    IN VARCHAR2)
           return BOOLEAN IS
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);
  l_num_accounted_pay_hist    NUMBER;
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_CHECKS_PKG.is_maturity_accounted<-' ||
                                 X_calling_sequence;
    debug_info := 'Selecting from ap_payment_history';
    SELECT  count(*)
    INTO    l_num_accounted_pay_hist
    FROM    ap_payment_history
    WHERE   check_id = X_check_id
    AND     transaction_type = 'PAYMENT MATURITY'
    AND     posted_flag = 'Y';

    If (l_num_accounted_pay_hist = 0)
    then
       return(FALSE);
    else
       return(TRUE);
    end if;

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','check_id = ' || to_char(X_check_id));
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;
  END is_maturity_accounted;

  -----------------------------------------------------------------------
  -- Function is_payment_matured returns TRUE if the maturity event
  -- has been created, i.e. a PAYMENT MATURITY row exists in
  -- ap_payment_history for this payment.
  -- Otherwise it returns a FALSE.
  --
  FUNCTION is_payment_matured(X_check_id        IN NUMBER,
                              X_calling_sequence    IN VARCHAR2)
           return BOOLEAN IS
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);
  l_num_pay_hist            NUMBER;
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_CHECKS_PKG.is_payment_matured<-' ||
                                 X_calling_sequence;
    debug_info := 'Selecting from ap_payment_history';
    SELECT  count(*)
    INTO    l_num_pay_hist
    FROM    ap_payment_history
    WHERE   check_id = X_check_id
    AND     transaction_type = 'PAYMENT MATURITY';

    If (l_num_pay_hist = 0)
    then
       return(FALSE);
    else
       return(TRUE);
    end if;

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','check_id = ' || to_char(X_check_id));
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;
  END is_payment_matured;


  -----------------------------------------------------------------------
  -- Function get_posting_status returns the payment posting status flag.
  --
  --                     'Y' - Posted
  --                     'S' - Selected
  --                     'P' - Partial
  --                     'N' - Unposted
  --
  FUNCTION get_posting_status(l_check_id IN NUMBER)
      RETURN VARCHAR2
  IS
      payment_posting_flag           VARCHAR2(1);
      posting_flag      VARCHAR2(1);

      ---------------------------------------------------------------------
      -- Declare cursor to establish the payment-level posting flag
      --
      -- The first two selects simply look at the posting flags (cash and/or
      -- accrual) for the distributions.  The rest is to cover one specific
      -- case when some of the distributions are fully posted (Y) and some
      -- are unposted (N).  The status should be partial (P).
      --

      -- Fix for 1375672.  Modified the cursor to select the posted_flag from
      -- ap_invoice_payments and ap_payment_history. Previously, the cursor
      -- selected the cash_posted_flag and accrual_posted_flag (depending upon
      -- the accounting option) from ap_invoice_payments only, ignoring
      -- the ap_payment_history table.

      -- bug 3676049 Posting status of check is irrespective of Payment Maturity
      -- when Payment Accounting = 'CLEARING ONLY'
      CURSOR posting_cursor IS
      SELECT posted_flag
      FROM   ap_invoice_payments_all
      WHERE  check_id = l_check_id
      UNION ALL
      SELECT posted_flag
      FROM   ap_payment_history aph, ap_system_parameters asp
      WHERE  check_id = l_check_id
      AND    nvl(aph.org_id, -99) = nvl(asp.org_id, -99)
      AND    (nvl(asp.when_to_account_pmt, 'ALWAYS') = 'ALWAYS' or
             (nvl(asp.when_to_account_pmt, 'ALWAYS') = 'CLEARING ONLY' and
              aph.transaction_type in
              ('PAYMENT CLEARING', 'PAYMENT UNCLEARING',
	       'PAYMENT CLEARING ADJUSTED')));  --Bug 9789574

  BEGIN

      ---------------------------------------------------------------------
      -- Establish the payment-level posting flag
      --
      -- Use the following ordering sequence to determine the payment-level
      -- posting flag:
      --                     'S' - Selected
      --                     'N' - Unposted
      --                     'Y' - Posted
      --                     'P' - Partial
      --
      -- Initialize payment-level posting flag
      --
      -- Fix for 1375672.  Modified the logic of this IF block to get the
      -- correct payment posting status. The logic works as follows: If all
      -- values, that are returned by the cursor, are 'Y' then status is
      -- 'Y', if all are 'N' then the status is 'N', otherwise the status
      -- is 'P' (Partial)

      payment_posting_flag := 'X';

      OPEN posting_cursor;

      LOOP
          FETCH posting_cursor INTO posting_flag;
          EXIT WHEN posting_cursor%NOTFOUND;

          IF (posting_flag = 'S') THEN
              payment_posting_flag := 'S';
          ELSIF (posting_flag = 'N' AND
                 payment_posting_flag NOT IN ('S','Y','P')) THEN
              payment_posting_flag := 'N';
          ELSIF (posting_flag = 'Y' AND
                 payment_posting_flag NOT IN ('S','N','P')) THEN
              payment_posting_flag := 'Y';
          ELSIF (payment_posting_flag <> 'S') THEN
              payment_posting_flag := 'P';
          END IF;

      END LOOP;

      CLOSE posting_cursor;

      if (payment_posting_flag = 'X') then
        -- No distributions belong to this invoice; therefore,
       -- the payment-level posting status should be 'N'
        payment_posting_flag := 'N';
      end if;

      RETURN(payment_posting_flag);

  END get_posting_status;


  --Added for Payment Request
  -----------------------------------------------------------------------
  -- Procedure to subscribe to the payment event by other products
  -- This procedure checks the product registry table for all the
  -- products that have subscribed to a particular event and inturn
  -- calls the products API
  --
  -----------------------------------------------------------------------
  PROCEDURE Subscribe_To_Payment_Event
                      (P_Event_Type         IN             VARCHAR2,
                       P_Check_ID           IN             NUMBER,
                       P_Application_ID     IN             NUMBER,
                       P_Return_Status      OUT     NOCOPY VARCHAR2,
                       P_Msg_Count          OUT     NOCOPY NUMBER,
                       P_Msg_Data           OUT     NOCOPY VARCHAR2,
                       P_Calling_Sequence   IN             VARCHAR2) IS


  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);

  l_stmt                      VARCHAR2(1000);
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);


  CURSOR c_products_registered IS
  SELECT Reg_Application_ID,
         Registration_API
  FROM   AP_Product_Registrations
  WHERE  Reg_Application_ID = P_Application_ID
  AND    Registration_Event_Type = P_Event_Type;


  BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence := 'AP_CHECKS_PKG.Subscribe_To_Payment_Event<-' ||
                                           P_calling_sequence;

    debug_info := 'Calling the subscribe payment event API';

    FOR c_product_rec IN c_products_registered
    LOOP

        l_stmt := 'Begin ' ||
                   c_product_rec.Registration_API ||
                          '(:P_Event_Type,' ||
                           ':P_Check_ID,' ||
                           ':l_return_Status,' ||
                           ':l_msg_count,' ||
                           ':l_msg_data);' ||
                  'End;';

        EXECUTE IMMEDIATE l_stmt
                  USING IN  P_Event_Type,
                        IN  P_Check_ID,
                        OUT l_return_status,
                        OUT l_msg_count,
                        OUT l_msg_data;

        P_Return_Status := l_return_status;
        P_Msg_Count := l_msg_count;
        P_Msg_Data := l_msg_data;


    END LOOP;

  EXCEPTION

    WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
             FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
             FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS','check_id = ' || to_char(P_Check_ID));
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
         END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

  END Subscribe_To_Payment_Event;


END AP_CHECKS_PKG;

/
