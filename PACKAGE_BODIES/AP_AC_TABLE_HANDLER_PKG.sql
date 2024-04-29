--------------------------------------------------------
--  DDL for Package Body AP_AC_TABLE_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_AC_TABLE_HANDLER_PKG" as
/* $Header: apachthb.pls 120.8.12010000.3 2009/01/20 10:09:01 cjain ship $ */

----------------------------------------------------------------------------
  PROCEDURE Insert_Row(p_Rowid                   IN OUT NOCOPY VARCHAR2,
                       p_Amount                         NUMBER,
                       p_Ce_Bank_Acct_Use_Id            NUMBER,
                       p_Bank_Account_Name              VARCHAR2,
                       p_Check_Date                     DATE,
                       p_Check_Id                       NUMBER,
                       p_Check_Number                   NUMBER,
                       p_Currency_Code                  VARCHAR2,
                       p_Last_Updated_By                NUMBER,
                       p_Last_Update_Date               DATE,
                      --IBY:SP p_Payment_Method_Lookup_Code     VARCHAR2,
                       p_Payment_Type_Flag              VARCHAR2,
                       p_Address_Line1                  VARCHAR2 DEFAULT NULL,
                       p_Address_Line2                  VARCHAR2 DEFAULT NULL,
                       p_Address_Line3                  VARCHAR2 DEFAULT NULL,
                       p_Checkrun_Name                  VARCHAR2 DEFAULT NULL,
                       p_Check_Format_Id                NUMBER DEFAULT NULL,
                       p_Check_Stock_Id                 NUMBER DEFAULT NULL,
                       p_City                           VARCHAR2 DEFAULT NULL,
                       p_Country                        VARCHAR2 DEFAULT NULL,
                       p_Created_By                     NUMBER DEFAULT NULL,
                       p_Creation_Date                  DATE DEFAULT NULL,
                       p_Last_Update_Login              NUMBER DEFAULT NULL,
                       p_Status_Lookup_Code             VARCHAR2 DEFAULT NULL,
                       p_Vendor_Name                    VARCHAR2 DEFAULT NULL,
                       p_Vendor_Site_Code               VARCHAR2 DEFAULT NULL,
                       p_External_Bank_Account_Id       NUMBER,
                       p_Zip                            VARCHAR2 DEFAULT NULL,
                       p_Bank_Account_Num               VARCHAR2 DEFAULT NULL,
                       p_Bank_Account_Type              VARCHAR2 DEFAULT NULL,
                       p_Bank_Num                       VARCHAR2 DEFAULT NULL,
                       p_Check_Voucher_Num              NUMBER DEFAULT NULL,
                       p_Cleared_Amount                 NUMBER DEFAULT NULL,
                       p_Cleared_Date                   DATE DEFAULT NULL,
                       p_Doc_Category_Code              VARCHAR2 DEFAULT NULL,
                       p_Doc_Sequence_Id                NUMBER DEFAULT NULL,
                       p_Doc_Sequence_Value             NUMBER DEFAULT NULL,
                       p_Province                       VARCHAR2 DEFAULT NULL,
                       p_Released_Date                  DATE DEFAULT NULL,
                       p_Released_By                    NUMBER DEFAULT NULL,
                       p_State                          VARCHAR2 DEFAULT NULL,
                       p_Stopped_Date                   DATE DEFAULT NULL,
                       p_Stopped_By                     NUMBER DEFAULT NULL,
                       p_Void_Date                      DATE DEFAULT NULL,
                       p_Attribute1                     VARCHAR2 DEFAULT NULL,
                       p_Attribute10                    VARCHAR2 DEFAULT NULL,
                       p_Attribute11                    VARCHAR2 DEFAULT NULL,
                       p_Attribute12                    VARCHAR2 DEFAULT NULL,
                       p_Attribute13                    VARCHAR2 DEFAULT NULL,
                       p_Attribute14                    VARCHAR2 DEFAULT NULL,
                       p_Attribute15                    VARCHAR2 DEFAULT NULL,
                       p_Attribute2                     VARCHAR2 DEFAULT NULL,
                       p_Attribute3                     VARCHAR2 DEFAULT NULL,
                       p_Attribute4                     VARCHAR2 DEFAULT NULL,
                       p_Attribute5                     VARCHAR2 DEFAULT NULL,
                       p_Attribute6                     VARCHAR2 DEFAULT NULL,
                       p_Attribute7                     VARCHAR2 DEFAULT NULL,
                       p_Attribute8                     VARCHAR2 DEFAULT NULL,
                       p_Attribute9                     VARCHAR2 DEFAULT NULL,
                       p_Attribute_Category             VARCHAR2 DEFAULT NULL,
                       p_Future_Pay_Due_Date            DATE DEFAULT NULL,
                       p_Treasury_Pay_Date              DATE DEFAULT NULL,
                       p_Treasury_Pay_Number            NUMBER DEFAULT NULL,
                    -- Removed for bug 4277744
                    -- p_Ussgl_Transaction_Code         VARCHAR2 DEFAULT NULL,
                    -- p_Ussgl_Trx_Code_Context         VARCHAR2 DEFAULT NULL,
                       p_Withholding_Status_Lkup_Code   VARCHAR2 DEFAULT NULL,
                       p_Reconciliation_Batch_Id        NUMBER DEFAULT NULL,
                       p_Cleared_Base_Amount            NUMBER DEFAULT NULL,
                       p_Cleared_Exchange_Rate          NUMBER DEFAULT NULL,
                       p_Cleared_Exchange_Date          DATE DEFAULT NULL,
                       p_Cleared_Exchange_Rate_Type     VARCHAR2 DEFAULT NULL,
                       p_Address_Line4                  VARCHAR2 DEFAULT NULL,
                       p_County                         VARCHAR2 DEFAULT NULL,
                       p_Address_Style                  VARCHAR2 DEFAULT NULL,
                       p_Org_Id                         NUMBER DEFAULT NULL,
                       p_Vendor_Id                      NUMBER,
                       p_Vendor_Site_Id                 NUMBER,
                       p_Exchange_Rate                  NUMBER DEFAULT NULL,
                       p_Exchange_Date                  DATE DEFAULT NULL,
                       p_Exchange_Rate_Type             VARCHAR2 DEFAULT NULL,
                       p_Base_Amount                    NUMBER DEFAULT NULL,
                       p_Checkrun_Id                    NUMBER DEFAULT NULL,
                       p_global_attribute_category      VARCHAR2 DEFAULT NULL,
                       p_global_attribute1              VARCHAR2 DEFAULT NULL,
                       p_global_attribute2              VARCHAR2 DEFAULT NULL,
                       p_global_attribute3              VARCHAR2 DEFAULT NULL,
                       p_global_attribute4              VARCHAR2 DEFAULT NULL,
                       p_global_attribute5              VARCHAR2 DEFAULT NULL,
                       p_global_attribute6              VARCHAR2 DEFAULT NULL,
                       p_global_attribute7              VARCHAR2 DEFAULT NULL,
                       p_global_attribute8              VARCHAR2 DEFAULT NULL,
                       p_global_attribute9              VARCHAR2 DEFAULT NULL,
                       p_global_attribute10             VARCHAR2 DEFAULT NULL,
                       p_global_attribute11             VARCHAR2 DEFAULT NULL,
                       p_global_attribute12             VARCHAR2 DEFAULT NULL,
                       p_global_attribute13             VARCHAR2 DEFAULT NULL,
                       p_global_attribute14             VARCHAR2 DEFAULT NULL,
                       p_global_attribute15             VARCHAR2 DEFAULT NULL,
                       p_global_attribute16             VARCHAR2 DEFAULT NULL,
                       p_global_attribute17             VARCHAR2 DEFAULT NULL,
                       p_global_attribute18             VARCHAR2 DEFAULT NULL,
                       p_global_attribute19             VARCHAR2 DEFAULT NULL,
                       p_global_attribute20             VARCHAR2 DEFAULT NULL,
                       p_transfer_priority              VARCHAR2 DEFAULT NULL,
                       p_maturity_exchange_rate_type    VARCHAR2 DEFAULT NULL,
                       p_maturity_exchange_date        DATE DEFAULT NULL,
                       p_maturity_exchange_rate        NUMBER DEFAULT NULL,
                       p_description                  VARCHAR2 DEFAULT NULL,
                       p_anticipated_value_date        DATE DEFAULT NULL,
                       p_actual_value_date             DATE DEFAULT NULL,
                       p_PAYMENT_METHOD_CODE            VARCHAR2 DEFAULT NULL,
                       p_PAYMENT_PROFILE_ID             NUMBER DEFAULT NULL,
                       p_BANK_CHARGE_BEARER             VARCHAR2 DEFAULT NULL,
                       p_SETTLEMENT_PRIORITY            VARCHAR2 DEFAULT NULL,
                       p_payment_document_id            NUMBER DEFAULT NULL,
                       p_party_id                       NUMBER DEFAULT NULL,
                       p_party_site_id                  NUMBER DEFAULT NULL,
                       p_legal_entity_id                NUMBER DEFAULT NULL,
                       p_payment_id                     NUMBER DEFAULT NULL,
                       p_calling_sequence        VARCHAR2,
		       p_Remit_To_Supplier_Name	VARCHAR2 DEFAULT NULL,
		       p_Remit_To_Supplier_Id	Number DEFAULT NULL,
		       p_Remit_To_Supplier_Site	VARCHAR2 DEFAULT NULL,
		       p_Remit_To_Supplier_Site_Id	NUMBER DEFAULT NULL,
		       p_Relationship_Id			NUMBER DEFAULT NULL,
		       P_paycard_authorization_number VARCHAR2 DEFAULT NULL,
                       P_paycard_reference_id NUMBER DEFAULT NULL
                      )

  IS
  CURSOR C IS SELECT rowid FROM ap_checks
                 WHERE check_id = p_Check_Id;
    l_iban_number               CE_BANK_ACCOUNTS.IBAN_NUMBER%TYPE;  --IBY:SP
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

   BEGIN

--     Update the calling sequence
--
       current_calling_sequence := 'AP_AC_TABLE_HANDLER_PKG.INSERT_ROW<-' ||
                                    p_calling_sequence;

       -- Bug 2633878
       debug_info := 'Get the IBAN_NUMBER';
       IF  P_External_Bank_Account_Id is not NULL THEN
         BEGIN
             SELECT  iban
             INTO    l_iban_number
             FROM    IBY_PAYEE_ALL_BANKACCT_V /* External Bank Uptake */
             WHERE   ext_bank_account_id = P_External_Bank_Account_Id
             AND     party_id = P_party_id;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
             l_iban_number := NULL;
         END;
       END IF;

       debug_info := 'Insert into ap_checks';
       INSERT INTO ap_checks_all(
              amount,
              ce_bank_acct_use_id,
              bank_account_name,
              check_date,
              check_id,
              check_number,
              currency_code,
              last_updated_by,
              last_update_date,
            --IBY:SP  payment_method_lookup_code,
              payment_type_flag,
              address_line1,
              address_line2,
              address_line3,
              checkrun_name,
              check_format_id,
              check_stock_id,
              city,
              country,
              created_by,
              creation_date,
              last_update_login,
              status_lookup_code,
              vendor_name,
              vendor_site_code,
              external_bank_account_id,
              zip,
              bank_account_num,
              iban_number,
              bank_account_type,
              bank_num,
              check_voucher_num,
              cleared_amount,
              cleared_date,
              doc_category_code,
              doc_sequence_id,
              doc_sequence_value,
              province,
              released_date,
              released_by,
              state,
              stopped_date,
              stopped_by,
              void_date,
              attribute1,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute_category,
              future_pay_due_date,
              treasury_pay_date,
              treasury_pay_number,
           -- ussgl_transaction_code, -Bug 4277744
           -- ussgl_trx_code_context, -Bug 4277744
              withholding_status_lookup_code,
              reconciliation_batch_id,
              cleared_base_amount,
              cleared_exchange_rate,
              cleared_exchange_date,
              cleared_exchange_rate_type,
              address_line4,
              county,
              address_style,
              vendor_id,
              vendor_site_id,
              exchange_rate,
              exchange_date,
              exchange_rate_type,
              base_amount,
              checkrun_id,
              global_attribute_category,
              global_attribute1,
              global_attribute2,
              global_attribute3,
              global_attribute4,
              global_attribute5,
              global_attribute6,
              global_attribute7,
              global_attribute8,
              global_attribute9,
              global_attribute10,
              global_attribute11,
              global_attribute12,
              global_attribute13,
              global_attribute14,
              global_attribute15,
              global_attribute16,
              global_attribute17,
              global_attribute18,
              global_attribute19,
              global_attribute20,
              transfer_priority,
              maturity_exchange_rate_type,
              maturity_exchange_date,
              maturity_exchange_rate,
              description,
              anticipated_value_date,
              actual_value_date,
              org_id,
              payment_method_code,
              payment_profile_id,
              bank_charge_bearer,
              settlement_priority,
              payment_document_id,
              party_id,
              party_site_id,
              legal_entity_id,
              payment_id,
	      Remit_To_Supplier_Name,
	      Remit_To_Supplier_Id,
	      Remit_To_Supplier_Site,
	      Remit_To_Supplier_Site_Id,
	      Relationship_Id,
	      paycard_authorization_number,
	      paycard_reference_id
             ) VALUES (
              p_Amount,
              p_Ce_Bank_Acct_Use_Id,
              p_Bank_Account_Name,
              p_Check_Date,
              p_Check_Id,
              p_Check_Number,
              p_Currency_Code,
              p_Last_Updated_By,
              p_Last_Update_Date,
              --IBY:SP p_Payment_Method_Lookup_Code,
              p_Payment_Type_Flag,
              p_Address_Line1,
              p_Address_Line2,
              p_Address_Line3,
              p_Checkrun_Name,
              p_Check_Format_Id,
              p_Check_Stock_Id,
              p_City,
              p_Country,
              p_Created_By,
              p_Creation_Date,
              p_Last_Update_Login,
              p_Status_Lookup_Code,
              p_Vendor_Name,
              p_Vendor_Site_Code,
              p_External_Bank_Account_Id,
              p_Zip,
              p_Bank_Account_Num,
              l_iban_number,
              p_Bank_Account_Type,
              p_Bank_Num,
              p_Check_Voucher_Num,
              p_Cleared_Amount,
              p_Cleared_Date,
              p_Doc_Category_Code,
              p_Doc_Sequence_Id,
              p_Doc_Sequence_Value,
              p_Province,
              p_Released_Date,
              p_Released_By,
              p_State,
              p_Stopped_Date,
              p_Stopped_By,
              p_Void_Date,
              p_Attribute1,
              p_Attribute10,
              p_Attribute11,
              p_Attribute12,
              p_Attribute13,
              p_Attribute14,
              p_Attribute15,
              p_Attribute2,
              p_Attribute3,
              p_Attribute4,
              p_Attribute5,
              p_Attribute6,
              p_Attribute7,
              p_Attribute8,
              p_Attribute9,
              p_Attribute_Category,
              p_Future_Pay_Due_Date,
              p_Treasury_Pay_Date,
              p_Treasury_Pay_Number,
           -- p_Ussgl_Transaction_Code, -Bug 4277744
           -- p_Ussgl_Trx_Code_Context, -Bug 4277744
              p_Withholding_Status_Lkup_Code,
              p_Reconciliation_Batch_Id,
              p_Cleared_Base_Amount,
              p_Cleared_Exchange_Rate,
              p_Cleared_Exchange_Date,
              p_Cleared_Exchange_Rate_Type,
              p_Address_Line4,
              p_County,
              DECODE(p_Address_Style, 'DEFAULT', NULL, p_Address_Style),
              p_Vendor_Id,
              p_Vendor_Site_Id,
              p_Exchange_Rate,
              p_Exchange_Date,
              p_Exchange_Rate_Type,
              p_Base_Amount,
              p_Checkrun_Id,
              p_global_attribute_category,
              p_global_attribute1,
              p_global_attribute2,
              p_global_attribute3,
              p_global_attribute4,
              p_global_attribute5,
              p_global_attribute6,
              p_global_attribute7,
              p_global_attribute8,
              p_global_attribute9,
              p_global_attribute10,
              p_global_attribute11,
              p_global_attribute12,
              p_global_attribute13,
              p_global_attribute14,
              p_global_attribute15,
              p_global_attribute16,
              p_global_attribute17,
              p_global_attribute18,
              p_global_attribute19,
              p_global_attribute20,
              p_transfer_priority,
              p_maturity_exchange_rate_type,
              p_maturity_exchange_date,
              p_maturity_exchange_rate,
              p_description,
              p_anticipated_value_date,
              p_actual_value_date,
              p_org_id,
              p_payment_method_code,
              p_payment_profile_id,
              p_bank_charge_bearer,
              p_settlement_priority,
              p_payment_document_id,
              p_party_id,
              p_party_site_id,
              p_legal_entity_id,
              p_payment_id,
	       p_Remit_To_Supplier_Name,
	       p_Remit_To_Supplier_Id,
	       p_Remit_To_Supplier_Site,
	       p_Remit_To_Supplier_Site_Id,
	       p_Relationship_Id ,
	       p_paycard_authorization_number,
               P_paycard_reference_id
             );

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO p_Rowid;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - ROW NOTFOUND';
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence)
;
              FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || p_Rowid ||
                                        ', CHECK_ID = ' || TO_CHAR(p_Check_Id));
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;

 ----------------------------------------------------------------------------

  PROCEDURE Update_Row(p_Rowid                          VARCHAR2,
                       p_Amount                         NUMBER,
                       p_Ce_Bank_Acct_Use_Id            NUMBER,
                       p_Bank_Account_Name              VARCHAR2,
                       p_Check_Date                     DATE,
                       p_Check_Id                       NUMBER,
                       p_Check_Number                   NUMBER,
                       p_Currency_Code                  VARCHAR2,
                       p_Last_Updated_By                NUMBER,
                       p_Last_Update_Date               DATE,
                    --IBY:SP   p_Payment_Method_Lookup_Code     VARCHAR2,
                       p_Payment_Type_Flag              VARCHAR2,
                       p_Address_Line1                  VARCHAR2 DEFAULT NULL,
                       p_Address_Line2                  VARCHAR2 DEFAULT NULL,
                       p_Address_Line3                  VARCHAR2 DEFAULT NULL,
                       p_Checkrun_Name                  VARCHAR2 DEFAULT NULL,
                       p_Check_Format_Id                NUMBER DEFAULT NULL,
                       p_Check_Stock_Id                 NUMBER DEFAULT NULL,
                       p_City                           VARCHAR2 DEFAULT NULL,
                       p_Country                        VARCHAR2 DEFAULT NULL,
                       p_Last_Update_Login              NUMBER DEFAULT NULL,
                       p_Status_Lookup_Code             VARCHAR2 DEFAULT NULL,
                       p_Vendor_Name                    VARCHAR2 DEFAULT NULL,
                       p_Vendor_Site_Code               VARCHAR2 DEFAULT NULL,
                       p_External_Bank_Account_Id       NUMBER,
                       p_Zip                            VARCHAR2 DEFAULT NULL,
                       p_Bank_Account_Num               VARCHAR2 DEFAULT NULL,
                       p_Bank_Account_Type              VARCHAR2 DEFAULT NULL,
                       p_Bank_Num                       VARCHAR2 DEFAULT NULL,
                       p_Check_Voucher_Num              NUMBER DEFAULT NULL,
                       p_Cleared_Amount                 NUMBER DEFAULT NULL,
                       p_Cleared_Date                   DATE DEFAULT NULL,
                       p_Doc_Category_Code              VARCHAR2 DEFAULT NULL,
                       p_Doc_Sequence_Id                NUMBER DEFAULT NULL,
                       p_Doc_Sequence_Value             NUMBER DEFAULT NULL,
                       p_Province                       VARCHAR2 DEFAULT NULL,
                       p_Released_Date                  DATE DEFAULT NULL,
                       p_Released_By                    NUMBER DEFAULT NULL,
                       p_State                          VARCHAR2 DEFAULT NULL,
                       p_Stopped_Date                   DATE DEFAULT NULL,
                       p_Stopped_By                     NUMBER DEFAULT NULL,
                       p_Void_Date                      DATE DEFAULT NULL,
                       p_Attribute1                     VARCHAR2 DEFAULT NULL,
                       p_Attribute10                    VARCHAR2 DEFAULT NULL,
                       p_Attribute11                    VARCHAR2 DEFAULT NULL,
                       p_Attribute12                    VARCHAR2 DEFAULT NULL,
                       p_Attribute13                    VARCHAR2 DEFAULT NULL,
                       p_Attribute14                    VARCHAR2 DEFAULT NULL,
                       p_Attribute15                    VARCHAR2 DEFAULT NULL,
                       p_Attribute2                     VARCHAR2 DEFAULT NULL,
                       p_Attribute3                     VARCHAR2 DEFAULT NULL,
                       p_Attribute4                     VARCHAR2 DEFAULT NULL,
                       p_Attribute5                     VARCHAR2 DEFAULT NULL,
                       p_Attribute6                     VARCHAR2 DEFAULT NULL,
                       p_Attribute7                     VARCHAR2 DEFAULT NULL,
                       p_Attribute8                     VARCHAR2 DEFAULT NULL,
                       p_Attribute9                     VARCHAR2 DEFAULT NULL,
                       p_Attribute_Category             VARCHAR2 DEFAULT NULL,
                       p_Future_Pay_Due_Date            DATE DEFAULT NULL,
                       p_Treasury_Pay_Date              DATE DEFAULT NULL,
                       p_Treasury_Pay_Number            NUMBER DEFAULT NULL,
                    -- Removed for bug 4277744
                    -- p_Ussgl_Transaction_Code         VARCHAR2 DEFAULT NULL,
                    -- p_Ussgl_Trx_Code_Context         VARCHAR2 DEFAULT NULL,
                       p_Withholding_Status_Lkup_Code   VARCHAR2 DEFAULT NULL,
                       p_Reconciliation_Batch_Id        NUMBER DEFAULT NULL,
                       p_Cleared_Base_Amount            NUMBER DEFAULT NULL,
                       p_Cleared_Exchange_Rate          NUMBER DEFAULT NULL,
                       p_Cleared_Exchange_Date          DATE DEFAULT NULL,
                       p_Cleared_Exchange_Rate_Type     VARCHAR2 DEFAULT NULL,
                       p_Address_Line4                  VARCHAR2 DEFAULT NULL,
                       p_County                         VARCHAR2 DEFAULT NULL,
                       p_Address_Style                  VARCHAR2 DEFAULT NULL,
                       p_Org_Id                         NUMBER DEFAULT NULL,
                       p_Vendor_Id                      NUMBER,
                       p_Vendor_Site_Id                 NUMBER,
                       p_Exchange_Rate                  NUMBER DEFAULT NULL,
                       p_Exchange_Date                  DATE DEFAULT NULL,
                       p_Exchange_Rate_Type             VARCHAR2 DEFAULT NULL,
                       p_Base_Amount                    NUMBER DEFAULT NULL,
                       p_Checkrun_Id                    NUMBER DEFAULT NULL,
                       p_global_attribute_category      VARCHAR2 DEFAULT NULL,
                       p_global_attribute1              VARCHAR2 DEFAULT NULL,
                       p_global_attribute2              VARCHAR2 DEFAULT NULL,
                       p_global_attribute3              VARCHAR2 DEFAULT NULL,
                       p_global_attribute4              VARCHAR2 DEFAULT NULL,
                       p_global_attribute5              VARCHAR2 DEFAULT NULL,
                       p_global_attribute6              VARCHAR2 DEFAULT NULL,
                       p_global_attribute7              VARCHAR2 DEFAULT NULL,
                       p_global_attribute8              VARCHAR2 DEFAULT NULL,
                       p_global_attribute9              VARCHAR2 DEFAULT NULL,
                       p_global_attribute10             VARCHAR2 DEFAULT NULL,
                       p_global_attribute11             VARCHAR2 DEFAULT NULL,
                       p_global_attribute12             VARCHAR2 DEFAULT NULL,
                       p_global_attribute13             VARCHAR2 DEFAULT NULL,
                       p_global_attribute14             VARCHAR2 DEFAULT NULL,
                       p_global_attribute15             VARCHAR2 DEFAULT NULL,
                       p_global_attribute16             VARCHAR2 DEFAULT NULL,
                       p_global_attribute17             VARCHAR2 DEFAULT NULL,
                       p_global_attribute18             VARCHAR2 DEFAULT NULL,
                       p_global_attribute19             VARCHAR2 DEFAULT NULL,
                       p_global_attribute20             VARCHAR2 DEFAULT NULL,
                       p_transfer_priority              VARCHAR2 DEFAULT NULL,
               p_maturity_exchange_rate_type    VARCHAR2 DEFAULT NULL,
               p_maturity_exchange_date        DATE DEFAULT NULL,
               p_maturity_exchange_rate        NUMBER DEFAULT NULL,
               p_description            VARCHAR2 DEFAULT NULL,
               p_anticipated_value_date        DATE DEFAULT NULL,
               p_actual_value_date        DATE DEFAULT NULL,
               p_PAYMENT_METHOD_CODE            VARCHAR2 DEFAULT NULL,
               p_PAYMENT_PROFILE_ID             NUMBER DEFAULT NULL,
               p_BANK_CHARGE_BEARER             VARCHAR2 DEFAULT NULL,
               p_SETTLEMENT_PRIORITY            VARCHAR2 DEFAULT NULL,
               p_payment_document_id            NUMBER DEFAULT NULL,
               p_party_id                       NUMBER DEFAULT NULL,
               p_party_site_id                  NUMBER DEFAULT NULL,
               p_legal_entity_id                NUMBER DEFAULT NULL,
               p_payment_id                     NUMBER DEFAULT NULL,
               p_calling_sequence        VARCHAR2,
		       p_Remit_To_Supplier_Name	VARCHAR2 DEFAULT NULL,
		       p_Remit_To_Supplier_Id	Number DEFAULT NULL,
		       p_Remit_To_Supplier_Site	VARCHAR2 DEFAULT NULL,
		       p_Remit_To_Supplier_Site_Id	NUMBER DEFAULT NULL,
		       p_Relationship_Id			NUMBER DEFAULT NULL,
		       P_paycard_authorization_number VARCHAR2 DEFAULT NULL,
                       P_paycard_reference_id NUMBER DEFAULT NULL
                      )
  IS
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_AC_TABLE_HANDLER_PKG.UPDATE_ROW<-' ||
                                 p_calling_sequence;

    debug_info := 'Update ap_checks';
    UPDATE ap_checks
    SET
       amount                          =     p_Amount,
       ce_bank_acct_use_id             =     p_Ce_Bank_Acct_Use_Id,
       bank_account_name               =     p_Bank_Account_Name,
       check_date                      =     p_Check_Date,
       check_id                        =     p_Check_Id,
       check_number                    =     p_Check_Number,
       currency_code                   =     p_Currency_Code,
       last_updated_by                 =     p_Last_Updated_By,
       last_update_date                =     p_Last_Update_Date,
      --IBY:SP payment_method_lookup_code      =     p_Payment_Method_Lookup_Code,
       payment_type_flag               =     p_Payment_Type_Flag,
       address_line1                   =     p_Address_Line1,
       address_line2                   =     p_Address_Line2,
       address_line3                   =     p_Address_Line3,
       checkrun_name                   =     p_Checkrun_Name,
       check_format_id                 =     p_Check_Format_Id,
       check_stock_id                  =     p_Check_Stock_Id,
       city                            =     p_City,
       country                         =     p_Country,
       last_update_login               =     p_Last_Update_Login,
       status_lookup_code              =     p_Status_Lookup_Code,
       vendor_name                     =     p_Vendor_Name,
       vendor_site_code                =     p_Vendor_Site_Code,
       external_bank_account_id        =     p_External_Bank_Account_Id,
       zip                             =     p_Zip,
       bank_account_num                =     p_Bank_Account_Num,
       bank_account_type               =     p_Bank_Account_Type,
       bank_num                        =     p_Bank_Num,
       check_voucher_num               =     p_Check_Voucher_Num,
       cleared_amount                  =     p_Cleared_Amount,
       cleared_date                    =     p_Cleared_Date,
       doc_category_code               =     p_Doc_Category_Code,
       doc_sequence_id                 =     p_Doc_Sequence_Id,
       doc_sequence_value              =     p_Doc_Sequence_Value,
       province                        =     p_Province,
       released_date                   =     p_Released_Date,
       released_by                     =     p_Released_By,
       state                           =     p_State,
       stopped_date                    =     p_Stopped_Date,
       stopped_by                      =     p_Stopped_By,
       void_date                       =     p_Void_Date,
       attribute1                      =     p_Attribute1,
       attribute10                     =     p_Attribute10,
       attribute11                     =     p_Attribute11,
       attribute12                     =     p_Attribute12,
       attribute13                     =     p_Attribute13,
       attribute14                     =     p_Attribute14,
       attribute15                     =     p_Attribute15,
       attribute2                      =     p_Attribute2,
       attribute3                      =     p_Attribute3,
       attribute4                      =     p_Attribute4,
       attribute5                      =     p_Attribute5,
       attribute6                      =     p_Attribute6,
       attribute7                      =     p_Attribute7,
       attribute8                      =     p_Attribute8,
       attribute9                      =     p_Attribute9,
       attribute_category              =     p_Attribute_Category,
       future_pay_due_date             =     p_Future_Pay_Due_Date,
       treasury_pay_date               =     p_Treasury_Pay_Date,
       treasury_pay_number             =     p_Treasury_Pay_Number,
    -- Removed for bug 4277744
    -- ussgl_transaction_code          =     p_Ussgl_Transaction_Code,
    -- ussgl_trx_code_context          =     p_Ussgl_Trx_Code_Context,
       withholding_status_lookup_code  =     p_Withholding_Status_Lkup_Code,
       reconciliation_batch_id         =     p_Reconciliation_Batch_Id,
       cleared_base_amount             =     p_Cleared_Base_Amount,
       cleared_exchange_rate           =     p_Cleared_Exchange_Rate,
       cleared_exchange_date           =     p_Cleared_Exchange_Date,
       cleared_exchange_rate_type      =     p_Cleared_Exchange_Rate_Type,
       address_line4                   =     p_Address_Line4,
       county                          =     p_County,
       address_style                   =     DECODE(p_Address_Style,
                                                    'DEFAULT', NULL,
                                                    p_Address_Style),
       vendor_id                       =     p_Vendor_Id,
       vendor_site_id                  =     p_Vendor_Site_Id,
       exchange_rate                   =     p_Exchange_Rate,
       exchange_date                   =     p_Exchange_Date,
       exchange_rate_type              =     p_Exchange_Rate_Type,
       base_amount                     =     p_Base_Amount,
       checkrun_id                     =     p_Checkrun_Id,
       global_attribute_category       =     p_global_attribute_category,
       global_attribute1               =     p_global_attribute1,
       global_attribute2               =     p_global_attribute2,
       global_attribute3               =     p_global_attribute3,
       global_attribute4               =     p_global_attribute4,
       global_attribute5               =     p_global_attribute5,
       global_attribute6               =     p_global_attribute6,
       global_attribute7               =     p_global_attribute7,
       global_attribute8               =     p_global_attribute8,
       global_attribute9               =     p_global_attribute9,
       global_attribute10              =     p_global_attribute10,
       global_attribute11              =     p_global_attribute11,
       global_attribute12              =     p_global_attribute12,
       global_attribute13              =     p_global_attribute13,
       global_attribute14              =     p_global_attribute14,
       global_attribute15              =     p_global_attribute15,
       global_attribute16              =     p_global_attribute16,
       global_attribute17              =     p_global_attribute17,
       global_attribute18              =     p_global_attribute18,
       global_attribute19              =     p_global_attribute19,
       global_attribute20              =     p_global_attribute20,
       transfer_priority               =     p_transfer_Priority,
       maturity_exchange_rate_type     =     p_maturity_exchange_rate_type,
       maturity_exchange_date          =     p_maturity_exchange_date,
       maturity_exchange_rate          =     p_maturity_exchange_rate,
       description                     =     p_description,
       anticipated_value_date          =     p_anticipated_value_date,
       actual_value_date               =     p_actual_value_date,
       org_id                          =     p_org_id,
       payment_method_code             =     p_payment_method_code,
       payment_profile_id              =    p_payment_profile_id,
       bank_charge_bearer              =     p_bank_charge_bearer,
       settlement_priority             =     p_settlement_priority,
       payment_document_id             =     p_payment_document_id,
       party_id                        =     p_party_id,
       party_site_id                   =     p_party_site_id,
       legal_entity_id                 =     p_legal_entity_id,
       payment_id                      =     p_payment_id,
	Remit_To_Supplier_Name	=       p_Remit_To_Supplier_Name,
	Remit_To_Supplier_Id		=	 p_Remit_To_Supplier_Id,
	Remit_To_Supplier_Site		=	 p_Remit_To_Supplier_Site,
	Remit_To_Supplier_Site_Id	=	 p_Remit_To_Supplier_Site_Id	,
	Relationship_Id			=	 p_Relationship_Id,
        paycard_authorization_number    =    p_paycard_authorization_number,
        paycard_reference_id            =    P_paycard_reference_id

    WHERE rowid = p_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence)
;
              FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || p_Rowid ||
                                        ', CHECK_ID = ' || TO_CHAR(p_Check_Id));
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Update_Row;

 ----------------------------------------------------------------------------
  PROCEDURE Delete_Row(p_Rowid                 VARCHAR2,
               p_calling_sequence        VARCHAR2)
  IS
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);
  l_check_id                  NUMBER;

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_AC_TABLE_HANDLER_PKG.DELETE_ROW<-' ||
                                 p_calling_sequence;
    debug_info := 'Delete from ap_checks';
    DELETE FROM ap_checks
    WHERE rowid = p_Rowid
    RETURNING check_id
    INTO l_check_id;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence)
;
              FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || p_Rowid);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Delete_Row;

  -----------------------------------------------------------------------
  -- Procedure Update_Amounts is created for GLOBAL to update amounts
  -- based on the value the passed. This will make sure mrc api will
  -- for no currency architecture  have no effect on the GLOBAL code.

   PROCEDURE Update_Amounts(
                       P_check_id         IN   NUMBER,
                       P_amount           IN   NUMBER,
                       P_base_amount      IN   NUMBER,
                       P_calling_sequence IN VARCHAR2) IS

   current_calling_sequence  VARCHAR2(2000);
   debug_info                VARCHAR2(100);


   Begin

   -- Update the calling sequence
   --
   current_calling_sequence := 'ap_ac_table_handler_pkg.update_amounts<-'||
                              P_calling_sequence;

   debug_info := 'update ap_checks amounts';

   UPDATE ap_checks
     SET amount = nvl(p_amount, amount),
         base_amount = nvl(p_base_amount, base_amount)
     WHERE check_id = p_check_id;

   Exception
     WHEN OTHERS then

     if (SQLCODE <> -20001 ) then
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
       FND_MESSAGE.SET_TOKEN('PARAMETERS'
                ,' Check_Id = '||TO_CHAR(P_Check_id)
                ||', Amount = '||TO_CHAR(P_amount)
                ||', Base_Amount = '||TO_CHAR(P_Base_Amount));

       FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
     end if;

     APP_EXCEPTION.RAISE_EXCEPTION;

   END Update_Amounts;


END AP_AC_TABLE_HANDLER_PKG;

/
