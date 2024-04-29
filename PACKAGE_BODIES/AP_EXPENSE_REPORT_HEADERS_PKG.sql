--------------------------------------------------------
--  DDL for Package Body AP_EXPENSE_REPORT_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_EXPENSE_REPORT_HEADERS_PKG" as
/* $Header: apixxrhb.pls 120.5.12010000.2 2009/10/07 07:10:57 sodash ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,

                       X_Report_Header_Id               NUMBER,
                       X_Employee_Id                    NUMBER DEFAULT NULL,
                       X_Week_End_Date                  DATE,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Vouchno                        NUMBER,
                       X_Total                          NUMBER,
                       X_Vendor_Id                      NUMBER DEFAULT NULL,
                       X_Vendor_Site_Id                 NUMBER DEFAULT NULL,
                       X_Expense_Check_Address_Flag     VARCHAR2 DEFAULT NULL,
                       X_Reference_1                    NUMBER DEFAULT NULL,
                       X_Reference_2                    VARCHAR2 DEFAULT NULL,
                       X_Invoice_Num                    VARCHAR2 DEFAULT NULL,
                       X_Expense_Report_Id              NUMBER DEFAULT NULL,
                       X_Accts_Pay_Code_Combinat_Id     NUMBER DEFAULT NULL,
                       X_Set_Of_Books_Id                NUMBER DEFAULT NULL,
                       X_Source                         VARCHAR2 DEFAULT NULL,
                       X_Purgeable_Flag                 VARCHAR2 DEFAULT NULL,
                       X_Accounting_Date                DATE DEFAULT NULL,
                       X_Employee_Ccid                  NUMBER DEFAULT NULL,
                       X_Description                    VARCHAR2 DEFAULT NULL,
                       X_Reject_Code                    VARCHAR2 DEFAULT NULL,
                       X_Hold_Lookup_Code               VARCHAR2 DEFAULT NULL,
                       X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Default_Currency_Code          VARCHAR2,
                       X_Default_Exchange_Rate_Type     VARCHAR2 DEFAULT NULL,
                       X_Default_Exchange_Rate          NUMBER DEFAULT NULL,
                       X_Default_Exchange_Date          DATE DEFAULT NULL,
		       		   X_Payment_Currency_Code          VARCHAR2,
                       X_Payment_Cross_Rate_Type        VARCHAR2,
                       X_Payment_Cross_Rate_Date        DATE,
                       X_Payment_Cross_Rate             NUMBER,
		       		   X_Apply_Advances_Flag			VARCHAR2,
		       		   X_Prepay_Num						VARCHAR2,
		       		   X_Prepay_Dist_Num				NUMBER,
		       		   X_Maximum_Amount_To_Apply		NUMBER,
		       		   X_Prepay_Gl_Date					DATE,
					   X_Advance_Invoice_To_Apply		NUMBER DEFAULT NULL,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Voucher_Num                    VARCHAR2 DEFAULT NULL,
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
                       X_Doc_Category_Code              VARCHAR2 DEFAULT NULL,
                       X_Awt_Group_Id                   NUMBER DEFAULT NULL,
                       X_Org_Id                         NUMBER DEFAULT NULL,
                       X_Workflow_Approved_Flag         VARCHAR2 DEFAULT NULL,
        	       X_global_attribute_category	VARCHAR2 DEFAULT NULL,
        	       X_global_attribute1		VARCHAR2 DEFAULT NULL,
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
		       X_calling_sequence	IN	VARCHAR2,
		       X_Report_Submitted_date          DATE DEFAULT NULL
  ) IS
    CURSOR C IS SELECT rowid FROM AP_EXPENSE_REPORT_HEADERS
                 WHERE report_header_id = X_Report_Header_Id;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

   BEGIN
--     Update the calling sequence
--
       current_calling_sequence := 'AP_EXPENSE_REPORT_HEADERS_PKG.INSERT_ROW<-' ||
                                    X_calling_sequence;

       debug_info := 'Insert into AP_EXPENSE_REPORT_HEADERS';
       INSERT INTO AP_EXPENSE_REPORT_HEADERS(

              report_header_id,
              employee_id,
              week_end_date,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              vouchno,
              total,
              vendor_id,
              vendor_site_id,
              expense_check_address_flag,
              reference_1,
              reference_2,
              invoice_num,
              expense_report_id,
              accts_pay_code_combination_id,
              set_of_books_id,
              source,
              purgeable_flag,
              accounting_date,
              employee_ccid,
              description,
              reject_code,
              hold_lookup_code,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              default_currency_code,
              default_exchange_rate_type,
              default_exchange_rate,
              default_exchange_date,
              payment_currency_code,
              payment_cross_rate_type,
              payment_cross_rate_date,
              payment_cross_rate,
	      	  apply_advances_default,
	      	  prepay_num,
	      	  prepay_dist_num,
	      	  maximum_amount_to_apply,
	      	  prepay_gl_date,
			  advance_invoice_to_apply,
              last_update_login,
              voucher_num,
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
              doc_category_code,
              awt_group_id,
              workflow_approved_flag,
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
              org_id,
	      report_submitted_date
             ) VALUES (

              X_Report_Header_Id,
              X_Employee_Id,
              X_Week_End_Date,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Vouchno,
              X_Total,
              X_Vendor_Id,
              X_Vendor_Site_Id,
              X_Expense_Check_Address_Flag,
              X_Reference_1,
              X_Reference_2,
              X_Invoice_Num,
              X_Expense_Report_Id,
              X_Accts_Pay_Code_Combinat_Id,
              X_Set_Of_Books_Id,
              X_Source,
              X_Purgeable_Flag,
              X_Accounting_Date,
              X_Employee_Ccid,
              X_Description,
              X_Reject_Code,
              X_Hold_Lookup_Code,
              X_Attribute_Category,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Default_Currency_Code,
              X_Default_Exchange_Rate_Type,
              X_Default_Exchange_Rate,
              X_Default_Exchange_Date,
              X_Payment_Currency_Code,
              X_Payment_Cross_Rate_Type,
              X_Payment_Cross_Rate_Date,
              X_Payment_Cross_Rate,
	      	  X_Apply_Advances_flag,
	          X_Prepay_Num,
	      	  X_Prepay_Dist_Num,
	      	  X_Maximum_Amount_To_Apply,
	      	  X_Prepay_Gl_Date,
			  X_Advance_Invoice_To_Apply,
              X_Last_Update_Login,
              X_Voucher_Num,
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
              X_Doc_Category_Code,
              X_Awt_Group_Id,
              X_Workflow_Approved_Flag,
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
              X_org_id,
	      sysdate
             );

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - DATA NOTFOUND';
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
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','REPORT_HEADER_ID = ' ||
                                    X_Report_Header_Id);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Report_Header_Id                 NUMBER,
                     X_Employee_Id                      NUMBER DEFAULT NULL,
                     X_Week_End_Date                    DATE,
                     X_Vouchno                          NUMBER,
                     X_Total                            NUMBER,
                     X_Vendor_Id                        NUMBER DEFAULT NULL,
                     X_Vendor_Site_Id                   NUMBER DEFAULT NULL,
                     X_Expense_Check_Address_Flag       VARCHAR2 DEFAULT NULL,
                     X_Reference_1                      NUMBER DEFAULT NULL,
                     X_Reference_2                      VARCHAR2 DEFAULT NULL,
                     X_Invoice_Num                      VARCHAR2 DEFAULT NULL,
                     X_Expense_Report_Id                NUMBER DEFAULT NULL,
                     X_Accts_Pay_Code_Combinat_Id    NUMBER DEFAULT NULL,
                     X_Set_Of_Books_Id                  NUMBER DEFAULT NULL,
                     X_Source                           VARCHAR2 DEFAULT NULL,
                     X_Purgeable_Flag                   VARCHAR2 DEFAULT NULL,
                     X_Accounting_Date                  DATE DEFAULT NULL,
                     X_Employee_Ccid                    NUMBER DEFAULT NULL,
                     X_Description                      VARCHAR2 DEFAULT NULL,
                     X_Reject_Code                      VARCHAR2 DEFAULT NULL,
                     X_Hold_Lookup_Code                 VARCHAR2 DEFAULT NULL,
                     X_Attribute_Category               VARCHAR2 DEFAULT NULL,
                     X_Attribute1                       VARCHAR2 DEFAULT NULL,
                     X_Attribute2                       VARCHAR2 DEFAULT NULL,
                     X_Attribute3                       VARCHAR2 DEFAULT NULL,
                     X_Attribute4                       VARCHAR2 DEFAULT NULL,
                     X_Attribute5                       VARCHAR2 DEFAULT NULL,
                     X_Default_Currency_Code            VARCHAR2,
                     X_Default_Exchange_Rate_Type       VARCHAR2 DEFAULT NULL,
                     X_Default_Exchange_Rate            NUMBER DEFAULT NULL,
                     X_Default_Exchange_Date            DATE DEFAULT NULL,
                     X_Payment_Currency_Code            VARCHAR2,
                     X_Payment_Cross_Rate_Type          VARCHAR2,
                     X_Payment_Cross_Rate_Date          DATE,
                     X_Payment_Cross_Rate               NUMBER,
		     		 X_Apply_Advances_Flag				VARCHAR2,
		     		 X_Prepay_Num						VARCHAR2,
					 X_Prepay_Dist_Num          		NUMBER,
					 X_Maximum_Amount_To_Apply			NUMBER,
					 X_Prepay_Gl_Date           		DATE,
					 X_Advance_Invoice_To_Apply			NUMBER DEFAULT NULL,
                     X_Voucher_Num                      VARCHAR2 DEFAULT NULL,
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
                     X_Doc_Category_Code                VARCHAR2 DEFAULT NULL,
                     X_Awt_Group_Id                     NUMBER DEFAULT NULL,
                     X_Org_Id                           NUMBER DEFAULT NULL,
                     X_Workflow_Approved_Flag           VARCHAR2 DEFAULT NULL,
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
		     X_calling_sequence		IN	VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   AP_EXPENSE_REPORT_HEADERS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Report_Header_Id NOWAIT;
    Recinfo C%ROWTYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_EXPENSE_REPORT_HEADERS_PKG.LOCK_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;
    if (

               (Recinfo.report_header_id =  X_Report_Header_Id)
           AND (   (Recinfo.employee_id =  X_Employee_Id)
                OR (    (Recinfo.employee_id IS NULL)
                    AND (X_Employee_Id IS NULL)))
           AND (Recinfo.week_end_date =  X_Week_End_Date)
           AND (Recinfo.vouchno =  X_Vouchno)
           AND (Recinfo.total =  X_Total)
           AND (   (Recinfo.vendor_id =  X_Vendor_Id)
                OR (    (Recinfo.vendor_id IS NULL)
                    AND (X_Vendor_Id IS NULL)))
           AND (   (Recinfo.vendor_site_id =  X_Vendor_Site_Id)
                OR (    (Recinfo.vendor_site_id IS NULL)
                    AND (X_Vendor_Site_Id IS NULL)))
           AND (   (Recinfo.expense_check_address_flag = X_Expense_Check_Address_Flag)
                OR (    (Recinfo.expense_check_address_flag IS NULL)
                    AND (X_Expense_Check_Address_Flag IS NULL)))
           AND (   (Recinfo.reference_1 =  X_Reference_1)
                OR (    (Recinfo.reference_1 IS NULL)
                    AND (X_Reference_1 IS NULL)))
           AND (   (Recinfo.reference_2 =  X_Reference_2)
                OR (    (Recinfo.reference_2 IS NULL)
                    AND (X_Reference_2 IS NULL)))
           AND (   (Recinfo.invoice_num =  X_Invoice_Num)
                OR (    (Recinfo.invoice_num IS NULL)
                    AND (X_Invoice_Num IS NULL)))
           AND (   (Recinfo.expense_report_id =  X_Expense_Report_Id)
                OR (    (Recinfo.expense_report_id IS NULL)
                    AND (X_Expense_Report_Id IS NULL)))
           AND (   (Recinfo.accts_pay_code_combination_id =  X_Accts_Pay_Code_Combinat_Id)
                OR (    (Recinfo.accts_pay_code_combination_id IS NULL)
                    AND (X_Accts_Pay_Code_Combinat_Id IS NULL)))
           AND (   (Recinfo.set_of_books_id =  X_Set_Of_Books_Id)
                OR (    (Recinfo.set_of_books_id IS NULL)
                    AND (X_Set_Of_Books_Id IS NULL)))
           AND (   (Recinfo.source =  X_Source)
                OR (    (Recinfo.source IS NULL)
                    AND (X_Source IS NULL)))
           AND (   (Recinfo.purgeable_flag =  X_Purgeable_Flag)
                OR (    (Recinfo.purgeable_flag IS NULL)
                    AND (X_Purgeable_Flag IS NULL)))
           AND (   (Recinfo.accounting_date =  X_Accounting_Date)
                OR (    (Recinfo.accounting_date IS NULL)
                    AND (X_Accounting_Date IS NULL)))
           AND (   (Recinfo.employee_ccid =  X_Employee_Ccid)
                OR (    (Recinfo.employee_ccid IS NULL)
                    AND (X_Employee_Ccid IS NULL)))
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.reject_code =  X_Reject_Code)
                OR (    (Recinfo.reject_code IS NULL)
                    AND (X_Reject_Code IS NULL)))
           AND (   (Recinfo.hold_lookup_code =  X_Hold_Lookup_Code)
                OR (    (Recinfo.hold_lookup_code IS NULL)
                    AND (X_Hold_Lookup_Code IS NULL)))
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
           AND (Recinfo.default_currency_code =  X_Default_Currency_Code)
           AND (   (Recinfo.default_exchange_rate_type =  X_Default_Exchange_Rate_Type)
                OR (    (Recinfo.default_exchange_rate_type IS NULL)
                    AND (X_Default_Exchange_Rate_Type IS NULL)))
           AND (   (Recinfo.default_exchange_rate =  X_Default_Exchange_Rate)
                OR (    (Recinfo.default_exchange_rate IS NULL)
                    AND (X_Default_Exchange_Rate IS NULL)))
           AND (   (Recinfo.default_exchange_date =  X_Default_Exchange_Date)
                OR (    (Recinfo.default_exchange_date IS NULL)
                    AND (X_Default_Exchange_Date IS NULL)))
           AND (   (Recinfo.Payment_currency_code =  X_Payment_Currency_Code)
                OR (    (Recinfo.Payment_currency_code IS NULL)
                    AND (X_Payment_Currency_Code IS NULL)))
           AND (   (Recinfo.payment_cross_rate_type =  X_Payment_Cross_Rate_Type)
                OR (    (Recinfo.payment_cross_rate_type IS NULL)
                    AND (X_Payment_Cross_Rate_Type IS NULL)))
           AND (   (Recinfo.Payment_Cross_rate =  X_Payment_Cross_Rate)
                OR (    (Recinfo.payment_cross_rate IS NULL)
                    AND (X_Payment_Cross_Rate IS NULL)))
           AND (   (Recinfo.payment_cross_rate_date =  X_Payment_Cross_Rate_Date)
                OR (    (Recinfo.payment_cross_rate_date IS NULL)
                    AND (X_Payment_Cross_Rate_Date IS NULL)))
	   AND (   (Recinfo.apply_advances_default =  X_Apply_Advances_Flag)
                OR (    (Recinfo.apply_advances_default IS NULL)
                    AND (X_Apply_Advances_Flag IS NULL)))
	   AND (   (Recinfo.prepay_num =  X_Prepay_Num)
                OR (    (Recinfo.prepay_num IS NULL)
                    AND (X_Prepay_Num IS NULL)))
	   AND (   (Recinfo.prepay_dist_num =  X_Prepay_Dist_Num)
                OR (    (Recinfo.prepay_dist_num IS NULL)
                    AND (X_Prepay_Dist_Num IS NULL)))
	   AND (   (Recinfo.maximum_amount_to_apply =  X_Maximum_Amount_To_Apply)
                OR (    (Recinfo.maximum_amount_to_apply IS NULL)
                    AND (X_Maximum_Amount_To_Apply IS NULL)))
	   AND (   (Recinfo.prepay_gl_date =  X_Prepay_Gl_Date)
                OR (    (Recinfo.prepay_gl_date IS NULL)
                    AND (X_Prepay_Gl_Date IS NULL)))
	   AND (	(Recinfo.advance_invoice_to_apply = X_Advance_Invoice_To_Apply)
				OR ( (Recinfo.advance_invoice_to_apply IS NULL)
					AND (X_Advance_Invoice_To_Apply IS NULL)))
           AND (   (Recinfo.voucher_num =  X_Voucher_Num)
                OR (    (Recinfo.voucher_num IS NULL)
                    AND (X_Voucher_Num IS NULL)))
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
           AND (   (Recinfo.doc_category_code =  X_Doc_Category_Code)
                OR (    (Recinfo.doc_category_code IS NULL)
                    AND (X_Doc_Category_Code IS NULL)))
           AND (   (Recinfo.awt_group_id =  X_Awt_Group_Id)
                OR (    (Recinfo.awt_group_id IS NULL)
                    AND (X_Awt_Group_Id IS NULL)))
           AND (   (Recinfo.Workflow_approved_flag =  X_Workflow_approved_flag)
                OR (    (Recinfo.Workflow_approved_flag IS NULL)
                    AND (X_Workflow_approved_flag IS NULL)))
      ) then
      null;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    if (
               (   (Recinfo.global_attribute_category =  X_global_attribute_category)
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
      ) then
      return;
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
             FND_MESSAGE.SET_TOKEN('PARAMETERS','REPORT_HEADER_ID = ' ||
                                   X_Report_Header_Id);
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
	 END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Report_Header_Id               NUMBER,
                       X_Employee_Id                    NUMBER DEFAULT NULL,
                       X_Week_End_Date                  DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Vouchno                        NUMBER,
                       X_Total                          NUMBER,
                       X_Vendor_Id                      NUMBER DEFAULT NULL,
                       X_Vendor_Site_Id                 NUMBER DEFAULT NULL,
                       X_Expense_Check_Address_Flag     VARCHAR2 DEFAULT NULL,
                       X_Reference_1                    NUMBER DEFAULT NULL,
                       X_Reference_2                    VARCHAR2 DEFAULT NULL,
                       X_Invoice_Num                    VARCHAR2 DEFAULT NULL,
                       X_Expense_Report_Id              NUMBER DEFAULT NULL,
                       X_Accts_Pay_Code_Combinat_Id  NUMBER DEFAULT NULL,
                       X_Set_Of_Books_Id                NUMBER DEFAULT NULL,
                       X_Source                         VARCHAR2 DEFAULT NULL,
                       X_Purgeable_Flag                 VARCHAR2 DEFAULT NULL,
                       X_Accounting_Date                DATE DEFAULT NULL,
                       X_Employee_Ccid                  NUMBER DEFAULT NULL,
                       X_Description                    VARCHAR2 DEFAULT NULL,
                       X_Reject_Code                    VARCHAR2 DEFAULT NULL,
                       X_Hold_Lookup_Code               VARCHAR2 DEFAULT NULL,
                       X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Default_Currency_Code          VARCHAR2,
                       X_Default_Exchange_Rate_Type     VARCHAR2 DEFAULT NULL,
                       X_Default_Exchange_Rate          NUMBER DEFAULT NULL,
                       X_Default_Exchange_Date          DATE DEFAULT NULL,
                       X_Payment_Currency_Code         VARCHAR2,
                       X_Payment_Cross_Rate_Type        VARCHAR2,
                       X_Payment_Cross_Rate_Date        DATE,
                       X_Payment_Cross_Rate             NUMBER,
		       		   X_Apply_Advances_Flag			VARCHAR2,
		       		   X_Prepay_Num						VARCHAR2,
		       		   X_Prepay_Dist_Num				NUMBER,
		       		   X_Maximum_Amount_To_Apply		NUMBER,
		       		   X_Prepay_Gl_Date					DATE,
					   X_Advance_Invoice_To_Apply		NUMBER DEFAULT NULL,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Voucher_Num                    VARCHAR2 DEFAULT NULL,
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
                       X_Doc_Category_Code              VARCHAR2 DEFAULT NULL,
                       X_Awt_Group_Id                   NUMBER DEFAULT NULL,
                       X_Org_Id                         NUMBER DEFAULT NULL,
                       X_Workflow_Approved_Flag         VARCHAR2 DEFAULT NULL,
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
		       X_calling_sequence	IN	VARCHAR2

  ) IS
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_EXPENSE_REPORT_HEADERS_PKG.UPDATE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Update AP_EXPENSE_REPORT_HEADERS';
    UPDATE AP_EXPENSE_REPORT_HEADERS
    SET
       report_header_id                =     X_Report_Header_Id,
       employee_id                     =     X_Employee_Id,
       week_end_date                   =     X_Week_End_Date,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       vouchno                         =     X_Vouchno,
       total                           =     X_Total,
       vendor_id                       =     X_Vendor_Id,
       vendor_site_id                  =     X_Vendor_Site_Id,
       expense_check_address_flag      =     X_Expense_Check_Address_Flag,
       reference_1                     =     X_Reference_1,
       reference_2                     =     X_Reference_2,
       invoice_num                     =     X_Invoice_Num,
       expense_report_id               =     X_Expense_Report_Id,
       accts_pay_code_combination_id   =     X_Accts_Pay_Code_Combinat_Id,
       set_of_books_id                 =     X_Set_Of_Books_Id,
       source                          =     X_Source,
       purgeable_flag                  =     X_Purgeable_Flag,
       accounting_date                 =     X_Accounting_Date,
       employee_ccid                   =     X_Employee_Ccid,
       description                     =     X_Description,
       reject_code                     =     X_Reject_Code,
       hold_lookup_code                =     X_Hold_Lookup_Code,
       attribute_category              =     X_Attribute_Category,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       default_currency_code           =     X_Default_Currency_Code,
       default_exchange_rate_type      =     X_Default_Exchange_Rate_Type,
       default_exchange_rate           =     X_Default_Exchange_Rate,
       default_exchange_date           =     X_Default_Exchange_Date,
       payment_currency_code           =     X_Payment_Currency_Code,
       payment_cross_rate_type         =     X_Payment_Cross_Rate_Type,
       payment_cross_rate_date         =     X_Payment_Cross_Rate_Date,
       payment_cross_rate              =     X_Payment_Cross_Rate,
   	   apply_advances_default	       =     X_Apply_Advances_Flag,
       prepay_num		       		   =     X_Prepay_Num,
       prepay_dist_num		       	   =     X_Prepay_Dist_Num,
       maximum_amount_to_apply	       =     X_Maximum_Amount_To_Apply,
       prepay_gl_date		       	   =     X_Prepay_Gl_Date,
	   advance_invoice_to_apply 	   = 	 X_Advance_Invoice_To_Apply,
       last_update_login               =     X_Last_Update_Login,
       voucher_num                     =     X_Voucher_Num,
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
       doc_category_code               =     X_Doc_Category_Code,
       awt_group_id                    =     X_Awt_Group_Id,
       workflow_approved_flag          =     X_Workflow_Approved_Flag,
       global_attribute_category       =     X_global_attribute_category,
       global_attribute1               =     X_global_attribute1,
       global_attribute2               =     X_global_attribute2,
       global_attribute3               =     X_global_attribute3,
       global_attribute4               =     X_global_attribute4,
       global_attribute5               =     X_global_attribute5,
       global_attribute6               =     X_global_attribute6,
       global_attribute7               =     X_global_attribute7,
       global_attribute8               =     X_global_attribute8,
       global_attribute9               =     X_global_attribute9,
       global_attribute10              =     X_global_attribute10,
       global_attribute11              =     X_global_attribute11,
       global_attribute12              =     X_global_attribute12,
       global_attribute13              =     X_global_attribute13,
       global_attribute14              =     X_global_attribute14,
       global_attribute15              =     X_global_attribute15,
       global_attribute16              =     X_global_attribute16,
       global_attribute17              =     X_global_attribute17,
       global_attribute18              =     X_global_attribute18,
       global_attribute19              =     X_global_attribute19,
       global_attribute20              =     X_global_attribute20
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','REPORT_HEADER_ID = ' ||
                                    X_Report_Header_Id);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid 				VARCHAR2,
		       X_calling_sequence	IN	VARCHAR2
  ) IS
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_EXPENSE_REPORT_HEADERS_PKG.DELETE_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Delete from AP_EXPENSE_REPORT_HEADERS';
    DELETE FROM AP_EXPENSE_REPORT_HEADERS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

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


END AP_EXPENSE_REPORT_HEADERS_PKG;

/
