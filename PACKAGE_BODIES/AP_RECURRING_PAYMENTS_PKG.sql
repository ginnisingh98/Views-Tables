--------------------------------------------------------
--  DDL for Package Body AP_RECURRING_PAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_RECURRING_PAYMENTS_PKG" AS
/* $Header: apircupb.pls 120.7.12010000.3 2010/12/20 12:21:22 sbonala ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Recurring_Payment_Id    IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Vendor_Id                      NUMBER,
                       X_Recurring_Pay_Num              VARCHAR2,
                       X_Vendor_Site_Id                 NUMBER,
                       X_Rec_Pay_Period_Type            VARCHAR2,
                       X_Num_Of_Periods                 NUMBER,
                       X_First_Period                   VARCHAR2,
                       X_First_Period_Num               NUMBER,
                       X_Authorized_Total               NUMBER,
                       X_Control_Amount                 NUMBER,
                       X_Distribution_Set_Id            NUMBER    DEFAULT NULL,
                       X_Terms_Id                       NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Amount_Applicable_To_Disc      NUMBER,
                       X_Rem_Periods                    NUMBER   DEFAULT NULL,
                       X_Accounting_Date                DATE     DEFAULT NULL,
                       X_Released_Amount                NUMBER   DEFAULT NULL,
                       X_Batch_Id                       NUMBER   DEFAULT NULL,
                       X_Accts_Pay_Code_Comb            NUMBER   DEFAULT NULL,
                       X_Invoice_Currency_Code          VARCHAR2,
                       X_Payment_Currency_Code          VARCHAR2,
                       X_Pay_Group_Lookup_Code          VARCHAR2 DEFAULT NULL,
                       X_Tax_Amount                     NUMBER   DEFAULT NULL,
                       X_Exchange_Rate                  NUMBER   DEFAULT NULL,
                       X_Next_Period                    VARCHAR2 DEFAULT NULL,
                       X_Next_Payment                   NUMBER   DEFAULT NULL,
                       X_Increment_Percent              NUMBER   DEFAULT NULL,
                       X_Num_Of_Periods_Rem             NUMBER   DEFAULT NULL,
                       X_Special_Payment_Amount1        NUMBER   DEFAULT NULL,
                       X_Special_Period_Name1           VARCHAR2 DEFAULT NULL,
                       X_Special_Payment_Amount2        NUMBER   DEFAULT NULL,
                       X_Special_Period_Name2           VARCHAR2 DEFAULT NULL,
                       X_Description                    VARCHAR2 DEFAULT NULL,
                       X_Paid_Flag1                     VARCHAR2 DEFAULT NULL,
                       X_Paid_Flag2                     VARCHAR2 DEFAULT NULL,
                       X_Hold_Lookup_Code               VARCHAR2 DEFAULT NULL,
                       X_Hold_Reason                    VARCHAR2 DEFAULT NULL,
                       X_Approved_By                    NUMBER   DEFAULT NULL,
                       X_Expiry_Date                    DATE     DEFAULT NULL,
                       X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Exchange_Rate_Type             VARCHAR2 DEFAULT NULL,
                       X_Payment_Cross_Rate             NUMBER,
                       X_Exchange_Date                  DATE     DEFAULT NULL,
                       X_Last_Update_Login              NUMBER   DEFAULT NULL,
                       X_Tax_Name                       VARCHAR2 DEFAULT NULL,
                       X_Attribute11                    VARCHAR2 DEFAULT NULL,
                       X_Attribute12                    VARCHAR2 DEFAULT NULL,
                       X_Attribute13                    VARCHAR2 DEFAULT NULL,
                       X_Attribute14                    VARCHAR2 DEFAULT NULL,
                       X_Attribute6                     VARCHAR2 DEFAULT NULL,
                       X_Attribute7                     VARCHAR2 DEFAULT NULL,
                       X_Attribute8                     VARCHAR2 DEFAULT NULL,
                       X_Attribute9                     VARCHAR2 DEFAULT NULL,
                       X_Attribute10                    VARCHAR2 DEFAULT NULL,
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Exclusive_Payment_Flag         VARCHAR2 DEFAULT NULL,
                       X_Awt_Group_Id                   NUMBER   DEFAULT NULL,
                       X_Pay_Awt_Group_Id               NUMBER   DEFAULT NULL,--bug6639866
                       X_Org_Id                         NUMBER   DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID,
                       X_Po_Header_Id                   NUMBER   DEFAULT NULL,
                       X_Po_Line_Id                     NUMBER   DEFAULT NULL,
                       X_Line_Location_Id               NUMBER   DEFAULT NULL,
                       X_External_Bank_Account_Id       NUMBER   DEFAULT NULL,
                       X_calling_sequence         IN    VARCHAR2,
                       X_Approval_Required_Flag         VARCHAR2,
                    -- Removed for bug 4277744
                    -- X_USSGL_Txn_Code                 VARCHAR2 DEFAULT NULL,
                       X_Requester_id                   NUMBER   DEFAULT NULL,
                       X_Po_Release_Id                  NUMBER   DEFAULT NULL,
                       X_Item_Description               VARCHAR2 DEFAULT NULL,
                       X_Manufacturer                   VARCHAR2 DEFAULT NULL,
                       X_Model_Number                   VARCHAR2 DEFAULT NULL,
		       X_Tax_Control_Amount		NUMBER   DEFAULT NULL,
		       X_Taxation_Country		VARCHAR2 DEFAULT NULL,
		       X_Product_Fisc_Class		VARCHAR2 DEFAULT NULL,
		       X_User_Defined_Fisc_Class	VARCHAR2 DEFAULT NULL,
		       X_Trx_Bus_Category		VARCHAR2 DEFAULT NULL,
		       X_Primary_Intended_Use		VARCHAR2 DEFAULT NULL,
		       X_Legal_Entity_Id		NUMBER   DEFAULT NULL,
                       x_PAYMENT_METHOD_CODE            varchar2 default null,
                       x_PAYMENT_REASON_CODE            varchar2 default null,
                       x_remittance_message1            varchar2 default null,
                       x_remittance_message2            varchar2 default null,
                       x_remittance_message3            varchar2 default null,
                       x_bank_charge_bearer             varchar2 default null,
                       x_settlement_priority            varchar2 default null,
                       x_payment_reason_comments        varchar2 default null,
                       x_delivery_channel_code          varchar2 default null,
                       X_First_Amount                   NUMBER,  -- 2794958 (2774932)
		       X_REMIT_TO_SUPPLIER_NAME         VARCHAR2 DEFAULT NULL,
		       X_REMIT_TO_SUPPLIER_ID           NUMBER DEFAULT NULL,
		       X_REMIT_TO_SUPPLIER_SITE         VARCHAR2 DEFAULT NULL,
		       X_REMIT_TO_SUPPLIER_SITE_ID      NUMBER DEFAULT NULL,
		       X_RELATIONSHIP_ID                NUMBER DEFAULT NULL,
		       X_PRODUCT_TYPE			VARCHAR2 DEFAULT NULL, --Bug#8640313
		       X_PRODUCT_CATEGORY		VARCHAR2 DEFAULT NULL  --Bug#8640313
  ) IS
    CURSOR C IS SELECT rowid FROM AP_RECURRING_PAYMENTS
                 WHERE recurring_payment_id = X_Recurring_Payment_Id;
      CURSOR C2 IS SELECT ap_recurring_payments_s.nextval FROM sys.dual;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

   BEGIN
      -- Update the calling sequence
      --
      current_calling_sequence :=
        'AP_RECURRING_PAYMENTS_PKG.INSERT_ROW<-'||X_calling_sequence;

      if (X_Recurring_Payment_Id is NULL) then
    debug_info := 'Open cursor C2';
        OPEN C2;
    debug_info := 'Fetch cursor C2';
        FETCH C2 INTO X_Recurring_Payment_Id;
    debug_info := 'Close cursor C2';
        CLOSE C2;
      end if;

       debug_info := 'Insert into AP_RECURRING_PAYMENTS';
       INSERT INTO AP_RECURRING_PAYMENTS(
              recurring_payment_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              vendor_id,
              recurring_pay_num,
              vendor_site_id,
              rec_pay_period_type,
              num_of_periods,
              first_period,
              first_period_num,
              authorized_total,
              control_amount,
              distribution_set_id,
              terms_id,
              set_of_books_id,
              amount_applicable_to_discount,
              rem_periods,
              accounting_date,
              released_amount,
              batch_id,
              accts_pay_code_combination_id,
              invoice_currency_code,
              payment_currency_code,
              pay_group_lookup_code,
              tax_amount,
              exchange_rate,
              next_period,
              next_payment,
              increment_percent,
              num_of_periods_rem,
              special_payment_amount1,
              special_period_name1,
              special_payment_amount2,
              special_period_name2,
              description,
              paid_flag1,
              paid_flag2,
              hold_lookup_code,
              hold_reason,
              approved_by,
              expiry_date,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              exchange_rate_type,
              payment_cross_rate,
              exchange_date,
              last_update_login,
              tax_name,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute15,
              exclusive_payment_flag,
              awt_group_id,
              pay_awt_group_id,--bug6639866
              po_header_id,
              po_line_id,
              External_Bank_Account_Id,
              line_location_id,
              Approval_Required_Flag,
           -- Removed for bug 4277744
           -- USSGL_Transaction_code,
              org_id,
              Requester_id,
              Po_Release_Id,
              Item_Description,
              Manufacturer,
              Model_Number,
	      Tax_Control_Amount,
	      Taxation_Country,
	      Product_Fisc_Classification,
	      User_Defined_Fisc_Class,
	      Trx_Business_Category,
	      Primary_Intended_Use,
	      Legal_Entity_Id,
              PAYMENT_METHOD_CODE,
              PAYMENT_REASON_CODE,
              REMITTANCE_MESSAGE1,
              REMITTANCE_MESSAGE2,
              REMITTANCE_MESSAGE3,
              bank_charge_bearer,
              settlement_priority,
              payment_reason_comments,
              delivery_channel_code,
              first_amount, -- 2794958 (2774932)
	      REMIT_TO_SUPPLIER_NAME,
	      REMIT_TO_SUPPLIER_ID,
	      REMIT_TO_SUPPLIER_SITE,
	      REMIT_TO_SUPPLIER_SITE_ID,
	      RELATIONSHIP_ID,
	      PRODUCT_TYPE,   --Bug#8640313
	      PRODUCT_CATEGORY) --Bug#8640313
       VALUES (
              X_Recurring_Payment_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Vendor_Id,
              X_Recurring_Pay_Num,
              X_Vendor_Site_Id,
              X_Rec_Pay_Period_Type,
              X_Num_Of_Periods,
              X_First_Period,
              X_First_Period_Num,
              X_Authorized_Total,
              X_Control_Amount,
              X_Distribution_Set_Id,
              X_Terms_Id,
              X_Set_Of_Books_Id,
              X_Amount_Applicable_To_Disc,
              X_Rem_Periods,
              X_Accounting_Date,
              X_Released_Amount,
              X_Batch_Id,
              X_Accts_Pay_Code_Comb,
              X_Invoice_Currency_Code,
              X_Payment_Currency_Code,
              X_Pay_Group_Lookup_Code,
              X_Tax_Amount,
              X_Exchange_Rate,
              X_Next_Period,
              X_Next_Payment,
              X_Increment_Percent,
              X_Num_Of_Periods_Rem,
              X_Special_Payment_Amount1,
              X_Special_Period_Name1,
              X_Special_Payment_Amount2,
              X_Special_Period_Name2,
              X_Description,
              X_Paid_Flag1,
              X_Paid_Flag2,
              X_Hold_Lookup_Code,
              X_Hold_Reason,
              X_Approved_By,
              X_Expiry_Date,
              X_Attribute_Category,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Exchange_Rate_Type,
              X_Payment_Cross_Rate,
              X_Exchange_Date,
              X_Last_Update_Login,
              X_Tax_Name,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute10,
              X_Attribute15,
              X_Exclusive_Payment_Flag,
              X_Awt_Group_Id,
              X_Pay_Awt_Group_Id,--bug6639866
              X_Po_Header_Id,
              X_Po_Line_Id,
              X_External_Bank_Account_Id,
              X_Line_Location_Id,
              X_Approval_Required_Flag,
           -- X_USSGL_Txn_Code,  - Bug 4277744
              X_Org_Id,
              X_Requester_id,
              X_Po_Release_Id,
              X_Item_Description,
              X_Manufacturer,
              X_Model_Number,
	      X_Tax_Control_Amount,
	      X_Taxation_Country,
	      X_Product_Fisc_Class,
	      X_User_Defined_Fisc_Class,
	      X_Trx_Bus_Category,
	      X_Primary_Intended_Use,
	      X_Legal_Entity_Id,
              x_PAYMENT_METHOD_CODE,
              x_PAYMENT_REASON_CODE,
              X_REMITTANCE_MESSAGE1,
              X_REMITTANCE_MESSAGE2,
              X_REMITTANCE_MESSAGE3,
              x_bank_charge_bearer,
              x_settlement_priority,
              x_payment_reason_comments,
              x_delivery_channel_code,
              X_First_Amount, -- 2794958 (2774932)
	      X_REMIT_TO_SUPPLIER_NAME,
              X_REMIT_TO_SUPPLIER_ID,
              X_REMIT_TO_SUPPLIER_SITE,
              X_REMIT_TO_SUPPLIER_SITE_ID,
              X_RELATIONSHIP_ID,
	      X_PRODUCT_TYPE,     --Bug#8640313
	      X_PRODUCT_CATEGORY  --Bug#8640313
             );

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - ROW NOTFOUND';
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;

    EXCEPTION
      WHEN OTHERS THEN
        if (SQLCODE <> -20001) then
          FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Rowid = '||X_Rowid
                          ||', Recurring_payment_id = '||TO_CHAR(X_Recurring_Payment_Id)
                                       );
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
        end if;
        APP_EXCEPTION.RAISE_EXCEPTION;


  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Recurring_Payment_Id             NUMBER,
                     X_Vendor_Id                        NUMBER,
                     X_Recurring_Pay_Num                VARCHAR2,
                     X_Vendor_Site_Id                   NUMBER,
                     X_Rec_Pay_Period_Type              VARCHAR2,
                     X_Num_Of_Periods                   NUMBER,
                     X_First_Period                     VARCHAR2,
                     X_First_Period_Num                 NUMBER,
                     X_Authorized_Total                 NUMBER,
                     X_Control_Amount                   NUMBER,
                     X_Distribution_Set_Id              NUMBER,
                     X_Terms_Id                         NUMBER,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Amount_Applicable_To_Disc        NUMBER,
                     X_Rem_Periods                      NUMBER   DEFAULT NULL,
                     X_Accounting_Date                  DATE     DEFAULT NULL,
                     X_Released_Amount                  NUMBER   DEFAULT NULL,
                     X_Batch_Id                         NUMBER   DEFAULT NULL,
                     X_Accts_Pay_Code_Comb              NUMBER   DEFAULT NULL,
                     X_Invoice_Currency_Code            VARCHAR2,
                     X_Payment_Currency_Code            VARCHAR2,
                     X_Pay_Group_Lookup_Code            VARCHAR2 DEFAULT NULL,
                     X_Tax_Amount                       NUMBER   DEFAULT NULL,
                     X_Exchange_Rate                    NUMBER   DEFAULT NULL,
                     X_Next_Period                      VARCHAR2 DEFAULT NULL,
                     X_Next_Payment                     NUMBER   DEFAULT NULL,
                     X_Increment_Percent                NUMBER   DEFAULT NULL,
                     X_Num_Of_Periods_Rem               NUMBER   DEFAULT NULL,
                     X_Special_Payment_Amount1          NUMBER   DEFAULT NULL,
                     X_Special_Period_Name1             VARCHAR2 DEFAULT NULL,
                     X_Special_Payment_Amount2          NUMBER   DEFAULT NULL,
                     X_Special_Period_Name2             VARCHAR2 DEFAULT NULL,
                     X_Description                      VARCHAR2 DEFAULT NULL,
                     X_Paid_Flag1                       VARCHAR2 DEFAULT NULL,
                     X_Paid_Flag2                       VARCHAR2 DEFAULT NULL,
                     X_Hold_Lookup_Code                 VARCHAR2 DEFAULT NULL,
                     X_Hold_Reason                      VARCHAR2 DEFAULT NULL,
                     X_Approved_By                      NUMBER   DEFAULT NULL,
                     X_Expiry_Date                      DATE     DEFAULT NULL,
                     X_Attribute_Category               VARCHAR2 DEFAULT NULL,
                     X_Attribute1                       VARCHAR2 DEFAULT NULL,
                     X_Attribute2                       VARCHAR2 DEFAULT NULL,
                     X_Attribute3                       VARCHAR2 DEFAULT NULL,
                     X_Attribute4                       VARCHAR2 DEFAULT NULL,
                     X_Attribute5                       VARCHAR2 DEFAULT NULL,
                     X_Exchange_Rate_Type               VARCHAR2 DEFAULT NULL,
                     X_Payment_Cross_Rate               NUMBER,
                     X_Exchange_Date                    DATE     DEFAULT NULL,
                     X_Tax_Name                         VARCHAR2 DEFAULT NULL,
                     X_Attribute11                      VARCHAR2 DEFAULT NULL,
                     X_Attribute12                      VARCHAR2 DEFAULT NULL,
                     X_Attribute13                      VARCHAR2 DEFAULT NULL,
                     X_Attribute14                      VARCHAR2 DEFAULT NULL,
                     X_Attribute6                       VARCHAR2 DEFAULT NULL,
                     X_Attribute7                       VARCHAR2 DEFAULT NULL,
                     X_Attribute8                       VARCHAR2 DEFAULT NULL,
                     X_Attribute9                       VARCHAR2 DEFAULT NULL,
                     X_Attribute10                      VARCHAR2 DEFAULT NULL,
                     X_Attribute15                      VARCHAR2 DEFAULT NULL,
                     X_Exclusive_Payment_Flag           VARCHAR2 DEFAULT NULL,
                     X_Awt_Group_Id                     NUMBER   DEFAULT NULL,
                     X_Pay_Awt_Group_Id                     NUMBER   DEFAULT NULL,--bug6639866
                     X_Org_Id                           NUMBER   DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID,
                     X_Po_Header_Id                     NUMBER   DEFAULT NULL,
                     X_Po_Line_Id                       NUMBER   DEFAULT NULL,
                     X_Line_Location_Id                 NUMBER   DEFAULT NULL,
                     X_External_Bank_Account_Id         NUMBER   DEFAULT NULL,
                     X_calling_sequence              IN VARCHAR2,
                     X_Approval_Required_Flag           VARCHAR2,
                  -- Removed for bug 4277744
                  -- X_USSGL_Txn_Code                   VARCHAR2 DEFAULT NULL,
                     X_Requester_id                     NUMBER   DEFAULT NULL,
                     X_Po_Release_Id                    NUMBER   DEFAULT NULL,
                     X_Item_Description                 VARCHAR2 DEFAULT NULL,
                     X_Manufacturer                     VARCHAR2 DEFAULT NULL,
                     X_Model_Number                     VARCHAR2 DEFAULT NULL,
		     X_Tax_Control_Amount		NUMBER   DEFAULT NULL,
		     X_Taxation_Country			VARCHAR2 DEFAULT NULL,
		     X_Product_Fisc_Class		VARCHAR2 DEFAULT NULL,
		     X_User_Defined_Fisc_Class		VARCHAR2 DEFAULT NULL,
		     X_Trx_Bus_Category			VARCHAR2 DEFAULT NULL,
		     X_Primary_Intended_Use		VARCHAR2 DEFAULT NULL,
		     X_Legal_Entity_Id			NUMBER   DEFAULT NULL,
                     x_PAYMENT_METHOD_CODE              varchar2 default null,
                     x_PAYMENT_REASON_CODE              varchar2 default null,
                     x_remittance_message1              varchar2 default null,
                     x_remittance_message2              varchar2 default null,
                     x_remittance_message3              varchar2 default null,
                     x_bank_charge_bearer               varchar2 default null,
                     x_settlement_priority              varchar2 default null,
                     x_payment_reason_comments          varchar2 default null,
                     x_delivery_channel_code            varchar2 default null,
                     X_First_Amount                     NUMBER,  -- 2794958 (2774932)
		     X_REMIT_TO_SUPPLIER_NAME         VARCHAR2 DEFAULT NULL,
		     X_REMIT_TO_SUPPLIER_ID           NUMBER DEFAULT NULL,
		     X_REMIT_TO_SUPPLIER_SITE         VARCHAR2 DEFAULT NULL,
		     X_REMIT_TO_SUPPLIER_SITE_ID      NUMBER DEFAULT NULL,
		     X_RELATIONSHIP_ID                NUMBER DEFAULT NULL,
		     X_PRODUCT_TYPE		      VARCHAR2 DEFAULT NULL, --Bug#8640313
		     X_PRODUCT_CATEGORY		      VARCHAR2 DEFAULT NULL  --Bug#8640313
  ) IS
    CURSOR C IS
        SELECT *
        FROM   AP_RECURRING_PAYMENTS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Recurring_Payment_Id NOWAIT;
    Recinfo C%ROWTYPE;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence :=
        'AP_RECURRING_PAYMENTS_PKG.LOCK_ROW<-'||X_calling_sequence;

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

    IF (
               (Recinfo.recurring_payment_id =  X_Recurring_Payment_Id)
           AND (Recinfo.vendor_id =  X_Vendor_Id)
           AND (Recinfo.recurring_pay_num =  X_Recurring_Pay_Num)
           AND (Recinfo.vendor_site_id =  X_Vendor_Site_Id)
           AND (Recinfo.rec_pay_period_type =  X_Rec_Pay_Period_Type)
           AND (Recinfo.num_of_periods =  X_Num_Of_Periods)
           AND (Recinfo.first_period =  X_First_Period)
           AND (Recinfo.first_period_num =  X_First_Period_Num)
           AND (Recinfo.authorized_total =  X_Authorized_Total)
           AND (Recinfo.control_amount =  X_Control_Amount)
           AND (   (Recinfo.distribution_set_id =  X_distribution_set_id)
                OR (    (Recinfo.distribution_set_id IS NULL)
                    AND (X_distribution_set_id IS NULL)))
           AND (Recinfo.terms_id =  X_Terms_Id)
           AND (Recinfo.set_of_books_id =  X_Set_Of_Books_Id)
           AND (Recinfo.amount_applicable_to_discount =  X_Amount_Applicable_To_Disc)
           AND (   (Recinfo.rem_periods =  X_Rem_Periods)
                OR (    (Recinfo.rem_periods IS NULL)
                    AND (X_Rem_Periods IS NULL)))
           AND (   (Recinfo.accounting_date =  X_Accounting_Date)
                OR (    (Recinfo.accounting_date IS NULL)
                    AND (X_Accounting_Date IS NULL)))
           AND (   (Recinfo.released_amount =  X_Released_Amount)
                OR (    (Recinfo.released_amount IS NULL)
                    AND (X_Released_Amount IS NULL)))
           AND (   (Recinfo.batch_id =  X_Batch_Id)
                OR (    (Recinfo.batch_id IS NULL)
                    AND (X_Batch_Id IS NULL)))
           AND (   (Recinfo.accts_pay_code_combination_id =  X_Accts_Pay_Code_Comb)
                OR (    (Recinfo.accts_pay_code_combination_id IS NULL)
                    AND (X_Accts_Pay_Code_Comb IS NULL)))
           AND (Recinfo.invoice_currency_code =  X_Invoice_Currency_Code)
           AND (Recinfo.payment_currency_code =  X_Payment_Currency_Code)
           AND (   (Recinfo.pay_group_lookup_code =  X_Pay_Group_Lookup_Code)
                OR (    (Recinfo.pay_group_lookup_code IS NULL)
                    AND (X_Pay_Group_Lookup_Code IS NULL)))
           AND (   (Recinfo.tax_amount =  X_Tax_Amount)
                OR (    (Recinfo.tax_amount IS NULL)
                    AND (X_Tax_Amount IS NULL)))
           AND (   (Recinfo.exchange_rate =  X_Exchange_Rate)
                OR (    (Recinfo.exchange_rate IS NULL)
                    AND (X_Exchange_Rate IS NULL)))
           AND (   (Recinfo.next_period =  X_Next_Period)
                OR (    (Recinfo.next_period IS NULL)
                    AND (X_Next_Period IS NULL)))
           AND (   (Recinfo.next_payment =  X_Next_Payment)
                OR (    (Recinfo.next_payment IS NULL)
                    AND (X_Next_Payment IS NULL)))
           AND (   (Recinfo.increment_percent =  X_Increment_Percent)
                OR (    (Recinfo.increment_percent IS NULL)
                    AND (X_Increment_Percent IS NULL)))
           AND (   (Recinfo.num_of_periods_rem =  X_Num_Of_Periods_Rem)
                OR (    (Recinfo.num_of_periods_rem IS NULL)
                    AND (X_Num_Of_Periods_Rem IS NULL)))
           AND (   (Recinfo.special_payment_amount1 =  X_Special_Payment_Amount1)
                OR (    (Recinfo.special_payment_amount1 IS NULL)
                    AND (X_Special_Payment_Amount1 IS NULL)))
           AND (   (Recinfo.special_period_name1 =  X_Special_Period_Name1)
                OR (    (Recinfo.special_period_name1 IS NULL)
                    AND (X_Special_Period_Name1 IS NULL)))
           AND (   (Recinfo.special_payment_amount2 =  X_Special_Payment_Amount2)
                OR (    (Recinfo.special_payment_amount2 IS NULL)
                    AND (X_Special_Payment_Amount2 IS NULL)))
           AND (   (Recinfo.special_period_name2 =  X_Special_Period_Name2)
                OR (    (Recinfo.special_period_name2 IS NULL)
                    AND (X_Special_Period_Name2 IS NULL)))
           AND (   (Recinfo.Taxation_Country =  X_Taxation_Country)
                OR (    (Recinfo.Taxation_Country IS NULL)
                    AND (X_Taxation_Country IS NULL)))
           AND (   (Recinfo.Tax_Control_Amount =  X_Tax_Control_Amount)
                OR (    (Recinfo.Tax_Control_Amount IS NULL)
                    AND (X_Tax_Control_Amount IS NULL)))
           AND (   (Recinfo.Product_Fisc_Classification =  X_Product_Fisc_Class)
                OR (    (Recinfo.Product_Fisc_Classification IS NULL)
                    AND (X_Product_Fisc_Class IS NULL)))
           AND (   (Recinfo.User_Defined_Fisc_Class =  X_User_Defined_Fisc_Class)
                OR (    (Recinfo.User_Defined_Fisc_Class IS NULL)
                    AND (X_User_Defined_Fisc_Class IS NULL)))
           AND (   (Recinfo.Trx_Business_Category =  X_Trx_Bus_Category)
                OR (    (Recinfo.Trx_Business_Category IS NULL)
                    AND (X_Trx_Bus_Category IS NULL)))
           AND (   (Recinfo.Primary_Intended_Use =  X_Primary_Intended_Use)
                OR (    (Recinfo.Primary_Intended_Use IS NULL)
                    AND (X_Primary_Intended_Use IS NULL)))
           AND (   (Recinfo.Legal_Entity_Id =  X_Legal_Entity_Id)
                OR (    (Recinfo.Legal_Entity_Id IS NULL)
                    AND (X_Legal_Entity_Id IS NULL)))
	   AND  (   (Recinfo.REMIT_TO_SUPPLIER_NAME = X_REMIT_TO_SUPPLIER_NAME)
                OR (    (Recinfo.REMIT_TO_SUPPLIER_NAME IS NULL)
		    AND (X_REMIT_TO_SUPPLIER_NAME IS NULL)))

           AND  (   (Recinfo.REMIT_TO_SUPPLIER_ID = X_REMIT_TO_SUPPLIER_ID)
                OR (    (Recinfo.REMIT_TO_SUPPLIER_ID IS NULL)
		    AND (X_REMIT_TO_SUPPLIER_ID IS NULL)))

           AND  (   (Recinfo.REMIT_TO_SUPPLIER_SITE = X_REMIT_TO_SUPPLIER_SITE)
                OR (    (Recinfo.REMIT_TO_SUPPLIER_SITE IS NULL)
		    AND (X_REMIT_TO_SUPPLIER_SITE IS NULL)))

           AND  (   (Recinfo.REMIT_TO_SUPPLIER_SITE_ID = X_REMIT_TO_SUPPLIER_SITE_ID)
                OR (    (Recinfo.REMIT_TO_SUPPLIER_SITE_ID IS NULL)
		    AND (X_REMIT_TO_SUPPLIER_SITE_ID IS NULL)))

           AND  (   (Recinfo.RELATIONSHIP_ID = X_RELATIONSHIP_ID)
                OR (    (Recinfo.RELATIONSHIP_ID IS NULL)
		    AND (X_RELATIONSHIP_ID IS NULL))))
               --Start bug#8640313
            AND  (   (Recinfo.PRODUCT_TYPE = X_PRODUCT_TYPE)
                OR (    (Recinfo.PRODUCT_TYPE IS NULL)
		    AND (X_PRODUCT_TYPE IS NULL)))

            AND  (   (Recinfo.PRODUCT_CATEGORY = X_PRODUCT_CATEGORY)
                OR (    (Recinfo.PRODUCT_CATEGORY IS NULL)
		    AND (X_PRODUCT_CATEGORY IS NULL)))	then

		    --End bug#8640313

      null;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    if(
     (  (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.paid_flag1 =  X_Paid_Flag1)
                OR (    (Recinfo.paid_flag1 IS NULL)
                    AND (X_Paid_Flag1 IS NULL)))
           AND (   (Recinfo.paid_flag2 =  X_Paid_Flag2)
                OR (    (Recinfo.paid_flag2 IS NULL)
                    AND (X_Paid_Flag2 IS NULL)))
           AND (   (Recinfo.hold_lookup_code =  X_Hold_Lookup_Code)
                OR (    (Recinfo.hold_lookup_code IS NULL)
                    AND (X_Hold_Lookup_Code IS NULL)))
           AND (   (Recinfo.hold_reason =  X_Hold_Reason)
                OR (    (Recinfo.hold_reason IS NULL)
                    AND (X_Hold_Reason IS NULL)))
           AND (   (Recinfo.approved_by =  X_Approved_By)
                OR (    (Recinfo.approved_by IS NULL)
                    AND (X_Approved_By IS NULL)))
           AND (   (Recinfo.expiry_date =  X_Expiry_Date)
                OR (    (Recinfo.expiry_date IS NULL)
                    AND (X_Expiry_Date IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
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
           AND (   (Recinfo.exchange_rate_type =  X_Exchange_Rate_Type)
                OR (    (Recinfo.exchange_rate_type IS NULL)
                    AND (X_Exchange_Rate_Type IS NULL)))
           AND (Recinfo.payment_cross_rate =  X_Payment_Cross_Rate)
           AND (   (Recinfo.exchange_date =  X_Exchange_Date)
                OR (    (Recinfo.exchange_date IS NULL)
                    AND (X_Exchange_Date IS NULL)))
           AND (   (Recinfo.tax_name =  X_Tax_Name)
                OR (    (Recinfo.tax_name IS NULL)
                    AND (X_Tax_Name IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
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
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.exclusive_payment_flag =  X_Exclusive_Payment_Flag)
                OR (    (Recinfo.exclusive_payment_flag IS NULL)
                    AND (X_Exclusive_Payment_Flag IS NULL)))
           AND (   (Recinfo.awt_group_id =  X_Awt_Group_Id)
                OR (    (Recinfo.awt_group_id IS NULL)
                    AND (X_Awt_Group_Id IS NULL)))
            AND (   (Recinfo.pay_awt_group_id =  X_Pay_Awt_Group_Id)
                OR (    (Recinfo.pay_awt_group_id IS NULL)
                    AND (X_Pay_Awt_Group_Id IS NULL)))    --bug6639866
           AND (   (Recinfo.po_header_id =  X_po_header_id)
                OR (    (Recinfo.po_header_id IS NULL)
                    AND (X_po_header_id IS NULL)))
           AND (   (Recinfo.po_line_id =  X_po_line_id)
                OR (    (Recinfo.po_line_id IS NULL)
                    AND (X_po_line_id IS NULL)))
           AND (   (Recinfo.External_Bank_Account_Id =  X_External_Bank_Account_Id)
                 OR (    (Recinfo.External_Bank_Account_Id IS NULL)
                    AND (X_External_Bank_Account_Id IS NULL)))
           AND (   (Recinfo.line_location_id =  X_line_location_id)
                OR (    (Recinfo.line_location_id IS NULL)
                    AND (X_line_location_id IS NULL)))
           AND (   (Recinfo.Approval_Required_Flag =  X_Approval_Required_Flag)
                OR (    (Recinfo.Approval_Required_Flag IS NULL)
                    AND (X_Approval_Required_Flag IS NULL)))
        -- Removed for bug 4277744
        -- AND (   (Recinfo.USSGL_Transaction_Code = X_USSGL_Txn_Code)
        --      OR (    (Recinfo.USSGL_Transaction_Code IS NULL)
        --          AND (X_USSGL_Txn_Code IS NULL)))
           AND (   (Recinfo.Org_Id = X_Org_Id)
                OR (    (Recinfo.Org_Id IS NULL)
                    AND (X_Org_Id IS NULL)))
           AND (   (Recinfo.Requester_Id = X_Requester_Id)
                OR (    (Recinfo.Requester_Id IS NULL)
                    AND (X_Requester_Id IS NULL)))
           AND (   (Recinfo.Po_Release_Id = X_Po_Release_Id)
                OR (    (Recinfo.Po_Release_Id IS NULL)
                    AND (X_Po_Release_Id IS NULL)))
           AND (   (Recinfo.Item_Description = X_Item_Description)
                OR (    (Recinfo.Item_Description IS NULL)
                    AND (X_Item_Description IS NULL)))
           AND (   (Recinfo.Manufacturer = X_Manufacturer)
                OR (    (Recinfo.Manufacturer IS NULL)
                    AND (X_Manufacturer IS NULL)))
           AND (   (Recinfo.Model_Number = X_Model_Number)
                OR (    (Recinfo.Model_Number IS NULL)
                    AND (X_Model_Number IS NULL)))
      AND ((Recinfo.PAYMENT_METHOD_CODE = X_PAYMENT_METHOD_CODE)
           OR ((Recinfo.PAYMENT_METHOD_CODE is null)
               AND (X_PAYMENT_METHOD_CODE is null)))
      AND ((Recinfo.PAYMENT_REASON_CODE = X_PAYMENT_REASON_CODE)
           OR ((Recinfo.PAYMENT_REASON_CODE is null)
               AND (X_PAYMENT_REASON_CODE is null)))
      AND ((Recinfo.REMITTANCE_MESSAGE1 = X_REMITTANCE_MESSAGE1)
           OR ((Recinfo.REMITTANCE_MESSAGE1 is null)
               AND (X_REMITTANCE_MESSAGE1 is null)))
      AND ((Recinfo.REMITTANCE_MESSAGE2 = X_REMITTANCE_MESSAGE2)
           OR ((Recinfo.REMITTANCE_MESSAGE2 is null)
               AND (X_REMITTANCE_MESSAGE2 is null)))
      AND ((Recinfo.REMITTANCE_MESSAGE3 = X_REMITTANCE_MESSAGE3)
           OR ((Recinfo.REMITTANCE_MESSAGE3 is null)
               AND (X_REMITTANCE_MESSAGE3 is null)))
      AND ((Recinfo.bank_charge_bearer = X_bank_charge_bearer)
           OR ((Recinfo.bank_charge_bearer is null)
               AND (X_bank_charge_bearer is null)))
      AND ((Recinfo.settlement_priority = X_settlement_priority)
           OR ((Recinfo.settlement_priority is null)
               AND (X_settlement_priority is null)))
      AND ((Recinfo.payment_reason_comments = X_payment_reason_comments)
           OR ((Recinfo.payment_reason_comments is null)
               AND (X_payment_reason_comments is null)))
      AND ((Recinfo.delivery_channel_code = X_delivery_channel_code)
           OR ((Recinfo.delivery_channel_code is null)
               AND (X_delivery_channel_code is null)))
      AND (   (Recinfo.First_Amount = X_First_Amount)
            OR (    (Recinfo.First_Amount IS NULL)
                 AND (X_First_Amount IS NULL))) -- 2794958 (2774932)

      )then
      return;
     else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    EXCEPTION
      WHEN OTHERS THEN
        if (SQLCODE <> -20001) then
          IF (SQLCODE = -54) THEN
            FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
          ELSE
            FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
            FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
            FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Rowid = '||X_Rowid
               ||', Recurring_payment_id = '||TO_CHAR(X_Recurring_Payment_Id)
                                       );
            FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
        end if;
        APP_EXCEPTION.RAISE_EXCEPTION;
  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Recurring_Payment_Id           NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Vendor_Id                      NUMBER,
                       X_Recurring_Pay_Num              VARCHAR2,
                       X_Vendor_Site_Id                 NUMBER,
                       X_Rec_Pay_Period_Type            VARCHAR2,
                       X_Num_Of_Periods                 NUMBER,
                       X_First_Period                   VARCHAR2,
                       X_First_Period_Num               NUMBER,
                       X_Authorized_Total               NUMBER,
                       X_Control_Amount                 NUMBER,
                       X_Distribution_Set_Id            NUMBER   DEFAULT NULL,
                       X_Terms_Id                       NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Amount_Applicable_To_Disc      NUMBER,
                       X_Rem_Periods                    NUMBER   DEFAULT NULL,
                       X_Accounting_Date                DATE     DEFAULT NULL,
                       X_Released_Amount                NUMBER   DEFAULT NULL,
                       X_Batch_Id                       NUMBER   DEFAULT NULL,
                       X_Accts_Pay_Code_Comb            NUMBER   DEFAULT NULL,
                       X_Invoice_Currency_Code          VARCHAR2,
                       X_Payment_Currency_Code          VARCHAR2,
                       X_Pay_Group_Lookup_Code          VARCHAR2 DEFAULT NULL,
                       X_Tax_Amount                     NUMBER   DEFAULT NULL,
                       X_Exchange_Rate                  NUMBER   DEFAULT NULL,
                       X_Next_Period                    VARCHAR2 DEFAULT NULL,
                       X_Next_Payment                   NUMBER   DEFAULT NULL,
                       X_Increment_Percent              NUMBER   DEFAULT NULL,
                       X_Num_Of_Periods_Rem             NUMBER   DEFAULT NULL,
                       X_Special_Payment_Amount1        NUMBER   DEFAULT NULL,
                       X_Special_Period_Name1           VARCHAR2 DEFAULT NULL,
                       X_Special_Payment_Amount2        NUMBER   DEFAULT NULL,
                       X_Special_Period_Name2           VARCHAR2 DEFAULT NULL,
                       X_Description                    VARCHAR2 DEFAULT NULL,
                       X_Paid_Flag1                     VARCHAR2 DEFAULT NULL,
                       X_Paid_Flag2                     VARCHAR2 DEFAULT NULL,
                       X_Hold_Lookup_Code               VARCHAR2 DEFAULT NULL,
                       X_Hold_Reason                    VARCHAR2 DEFAULT NULL,
                       X_Approved_By                    NUMBER   DEFAULT NULL,
                       X_Expiry_Date                    DATE     DEFAULT NULL,
                       X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Exchange_Rate_Type             VARCHAR2 DEFAULT NULL,
                       X_Payment_Cross_Rate             NUMBER,
                       X_Exchange_Date                  DATE     DEFAULT NULL,
                       X_Last_Update_Login              NUMBER   DEFAULT NULL,
                       X_Tax_Name                       VARCHAR2 DEFAULT NULL,
                       X_Attribute11                    VARCHAR2 DEFAULT NULL,
                       X_Attribute12                    VARCHAR2 DEFAULT NULL,
                       X_Attribute13                    VARCHAR2 DEFAULT NULL,
                       X_Attribute14                    VARCHAR2 DEFAULT NULL,
                       X_Attribute6                     VARCHAR2 DEFAULT NULL,
                       X_Attribute7                     VARCHAR2 DEFAULT NULL,
                       X_Attribute8                     VARCHAR2 DEFAULT NULL,
                       X_Attribute9                     VARCHAR2 DEFAULT NULL,
                       X_Attribute10                    VARCHAR2 DEFAULT NULL,
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Exclusive_Payment_Flag         VARCHAR2 DEFAULT NULL,
                       X_Awt_Group_Id                   NUMBER   DEFAULT NULL,
                       X_Pay_Awt_Group_Id                   NUMBER   DEFAULT NULL,--bug6639866
                       X_Org_Id                         NUMBER   DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID,
                       X_Po_Header_Id                   NUMBER   DEFAULT NULL,
                       X_Po_Line_Id                     NUMBER   DEFAULT NULL,
                       X_Line_Location_Id               NUMBER   DEFAULT NULL,
                       X_External_Bank_Account_Id       NUMBER   DEFAULT NULL,
                       X_calling_sequence            IN VARCHAR2,
                       X_Approval_Required_Flag         VARCHAR2,
                    -- Removed for bug 4277744
                    -- X_USSGL_Txn_Code                 VARCHAR2,
                       X_Requester_id                   NUMBER   DEFAULT NULL,
                       X_Po_Release_Id                  NUMBER   DEFAULT NULL,
                       X_Item_Description               VARCHAR2 DEFAULT NULL,
                       X_Manufacturer                   VARCHAR2 DEFAULT NULL,
                       X_Model_Number                   VARCHAR2 DEFAULT NULL,
		       X_Tax_Control_Amount		NUMBER   DEFAULT NULL,
		       X_Taxation_Country		VARCHAR2 DEFAULT NULL,
		       X_Product_Fisc_Class		VARCHAR2 DEFAULT NULL,
		       X_User_Defined_Fisc_Class	VARCHAR2 DEFAULT NULL,
		       X_Trx_Bus_Category		VARCHAR2 DEFAULT NULL,
		       X_Primary_Intended_Use		VARCHAR2 DEFAULT NULL,
		       X_Legal_Entity_Id		NUMBER   DEFAULT NULL,
                       x_PAYMENT_METHOD_CODE            varchar2 default null,
                       x_PAYMENT_REASON_CODE            varchar2 default null,
                       x_remittance_message1            varchar2 default null,
                       x_remittance_message2            varchar2 default null,
                       x_remittance_message3            varchar2 default null,
                       x_bank_charge_bearer             varchar2 default null,
                       x_settlement_priority            varchar2 default null,
                       x_payment_reason_comments        varchar2 default null,
                       x_delivery_channel_code          varchar2 default null,
                       x_first_amount                   number, -- 2794958 (2774932)
		       X_REMIT_TO_SUPPLIER_NAME         VARCHAR2 DEFAULT NULL,
		       X_REMIT_TO_SUPPLIER_ID           NUMBER DEFAULT NULL,
		       X_REMIT_TO_SUPPLIER_SITE         VARCHAR2 DEFAULT NULL,
		       X_REMIT_TO_SUPPLIER_SITE_ID      NUMBER DEFAULT NULL,
		       X_RELATIONSHIP_ID                NUMBER DEFAULT NULL,
		       X_PRODUCT_TYPE			VARCHAR2 DEFAULT NULL, --Bug#8640313
		       X_PRODUCT_CATEGORY		VARCHAR2 DEFAULT NULL  --Bug#8640313
  ) IS

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence :=
        'AP_RECURRING_PAYMENTS_PKG.UPDATE_ROW<-'||X_calling_sequence;

    debug_info := 'Update AP_RECURRING_PAYMENTS';
    UPDATE AP_RECURRING_PAYMENTS_ALL
    SET
       recurring_payment_id            =     X_Recurring_Payment_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       vendor_id                       =     X_Vendor_Id,
       recurring_pay_num               =     X_Recurring_Pay_Num,
       vendor_site_id                  =     X_Vendor_Site_Id,
       rec_pay_period_type             =     X_Rec_Pay_Period_Type,
       num_of_periods                  =     X_Num_Of_Periods,
       first_period                    =     X_First_Period,
       first_period_num                =     X_First_Period_Num,
       authorized_total                =     X_Authorized_Total,
       control_amount                  =     X_Control_Amount,
       distribution_set_id             =     X_Distribution_Set_Id,
       terms_id                        =     X_Terms_Id,
       set_of_books_id                 =     X_Set_Of_Books_Id,
       amount_applicable_to_discount   =     X_Amount_Applicable_To_Disc,
       rem_periods                     =     X_Rem_Periods,
       accounting_date                 =     X_Accounting_Date,
       released_amount                 =     X_Released_Amount,
       batch_id                        =     X_Batch_Id,
       accts_pay_code_combination_id   =     X_Accts_Pay_Code_Comb,
       invoice_currency_code           =     X_Invoice_Currency_Code,
       payment_currency_code           =     X_Payment_Currency_Code,
       pay_group_lookup_code           =     X_Pay_Group_Lookup_Code,
       tax_amount                      =     X_Tax_Amount,
       exchange_rate                   =     X_Exchange_Rate,
       next_period                     =     X_Next_Period,
       next_payment                    =     X_Next_Payment,
       increment_percent               =     X_Increment_Percent,
       num_of_periods_rem              =     X_Num_Of_Periods_Rem,
       special_payment_amount1         =     X_Special_Payment_Amount1,
       special_period_name1            =     X_Special_Period_Name1,
       special_payment_amount2         =     X_Special_Payment_Amount2,
       special_period_name2            =     X_Special_Period_Name2,
       description                     =     X_Description,
       paid_flag1                      =     X_Paid_Flag1,
       paid_flag2                      =     X_Paid_Flag2,
       hold_lookup_code                =     X_Hold_Lookup_Code,
       hold_reason                     =     X_Hold_Reason,
       approved_by                     =     X_Approved_By,
       expiry_date                     =     X_Expiry_Date,
       attribute_category              =     X_Attribute_Category,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       exchange_rate_type              =     X_Exchange_Rate_Type,
       payment_cross_rate              =     X_Payment_Cross_Rate,
       exchange_date                   =     X_Exchange_Date,
       last_update_login               =     X_Last_Update_Login,
       tax_name                        =     X_Tax_Name,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute15                     =     X_Attribute15,
       exclusive_payment_flag          =     X_Exclusive_Payment_Flag,
       awt_group_id                    =     X_Awt_Group_Id,
       pay_awt_group_id                =     X_Pay_Awt_Group_Id,--bug6639866
       po_header_id                    =     X_Po_Header_Id,
       po_line_id                      =     X_Po_Line_Id,
       External_Bank_Account_Id        =     X_External_Bank_Account_Id,
       line_location_id                =     X_Line_Location_Id,
       Approval_Required_Flag           =     X_Approval_Required_Flag,
    -- Removed for bug 4277744
    -- USSGL_Transaction_Code          =     X_USSGL_Txn_Code,
       org_id                          =     X_org_id,
       requester_id                    =     X_Requester_id,
       po_release_id                   =     X_Po_Release_Id,
       Item_Description                =     X_Item_Description,
       Manufacturer                    =     X_Manufacturer,
       Model_Number                    =     X_Model_Number,
       Tax_Control_Amount	       =     X_Tax_Control_Amount,
       Taxation_Country		       =     X_Taxation_Country,
       Product_Fisc_Classification     =     X_Product_Fisc_Class,
       User_Defined_Fisc_Class         =     X_User_Defined_Fisc_Class,
       Trx_Business_Category           =     X_Trx_Bus_Category,
       Primary_Intended_Use            =     X_Primary_Intended_Use,
       Legal_Entity_Id		       =     X_Legal_Entity_Id,
       PAYMENT_METHOD_CODE             =     x_PAYMENT_METHOD_CODE,
       PAYMENT_REASON_CODE             =     x_PAYMENT_REASON_CODE,
       REMITTANCE_MESSAGE1             =     X_REMITTANCE_MESSAGE1,
       REMITTANCE_MESSAGE2             =     X_REMITTANCE_MESSAGE2,
       REMITTANCE_MESSAGE3             =     X_REMITTANCE_MESSAGE3,
       bank_charge_bearer              =     x_bank_charge_bearer,
       settlement_priority             =     x_settlement_priority,
       payment_reason_comments         =     x_payment_reason_comments,
       delivery_channel_code           =     x_delivery_channel_code,
       first_amount                    =     x_first_amount, -- 2794958 (2774932)
       REMIT_TO_SUPPLIER_NAME          =     X_REMIT_TO_SUPPLIER_NAME,
       REMIT_TO_SUPPLIER_ID            =     X_REMIT_TO_SUPPLIER_ID,
       REMIT_TO_SUPPLIER_SITE          =     X_REMIT_TO_SUPPLIER_SITE,
       REMIT_TO_SUPPLIER_SITE_ID       =     X_REMIT_TO_SUPPLIER_SITE_ID,
       RELATIONSHIP_ID                 =     X_RELATIONSHIP_ID,
       PRODUCT_TYPE                    =     X_PRODUCT_TYPE,  --Bug#8640313
       PRODUCT_CATEGORY                =     X_PRODUCT_CATEGORY  --Bug#8640313
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    EXCEPTION
      WHEN OTHERS THEN
        if (SQLCODE <> -20001) then
          FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Rowid = '||X_Rowid
                          ||', Recurring_payment_id = '||TO_CHAR(X_Recurring_Payment_Id)
                                       );
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
        end if;
        APP_EXCEPTION.RAISE_EXCEPTION;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid                 VARCHAR2,
               X_calling_sequence    IN    VARCHAR2) IS

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence :=
        'AP_RECURRING_PAYMENTS_PKG.DELETE_ROW<-'||X_calling_sequence;

    debug_info := 'Delete from AP_RECURRING_PAYMENTS';
    DELETE FROM AP_RECURRING_PAYMENTS_ALL
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    EXCEPTION
      WHEN OTHERS THEN
        if (SQLCODE <> -20001) then
          FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Rowid = '||X_Rowid);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
        end if;
        APP_EXCEPTION.RAISE_EXCEPTION;

  END Delete_Row;

END AP_RECURRING_PAYMENTS_PKG;

/
