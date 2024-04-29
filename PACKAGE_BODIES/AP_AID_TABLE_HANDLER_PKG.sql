--------------------------------------------------------
--  DDL for Package Body AP_AID_TABLE_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_AID_TABLE_HANDLER_PKG" as
/* $Header: apaidthb.pls 120.10 2008/01/23 15:33:06 schamaku ship $ */

-------------------------------------------------------------------
PROCEDURE CHECK_UNIQUE (
          p_ROWID                          VARCHAR2,
          p_INVOICE_ID                     NUMBER,
	  p_INVOICE_LINE_NUMBER		   NUMBER,
          p_DISTRIBUTION_LINE_NUMBER       NUMBER,
          p_Calling_Sequence               VARCHAR2) IS

  dummy                    NUMBER := 0;
  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(100);

BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'AP_AID_TABLE_HANDLER_PKG.CHECK_UNIQUE<-'||
                              p_Calling_Sequence;

  debug_info := 'Select from ap_invoice_distributions';

  SELECT COUNT(1)
    INTO dummy
    FROM ap_invoice_distributions
   WHERE (invoice_id = p_INVOICE_ID AND
	  invoice_line_number = p_INVOICE_LINE_NUMBER AND
          distribution_line_number = p_DISTRIBUTION_LINE_NUMBER)
     AND ((p_ROWID is null) or (rowid <> p_ROWID));

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
                   ||', Distribution line number = '||
                   p_DISTRIBUTION_LINE_NUMBER);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END CHECK_UNIQUE;


PROCEDURE Insert_Row  (
          p_Rowid                        IN OUT NOCOPY VARCHAR2,
          p_Invoice_Id                          NUMBER,
          p_Invoice_Line_Number                 NUMBER,
          p_Distribution_Class                  VARCHAR2,
          p_Invoice_Distribution_Id      IN OUT NOCOPY NUMBER,
          p_Dist_Code_Combination_Id            NUMBER,
          p_Last_Update_Date                    DATE,
          p_Last_Updated_By                     NUMBER,
          p_Accounting_Date                     DATE,
          p_Period_Name                         VARCHAR2,
          p_Set_Of_Books_Id                     NUMBER,
          p_Amount                              NUMBER,
          p_Description                         VARCHAR2,
          p_Type_1099                           VARCHAR2,
          p_Posted_Flag                         VARCHAR2,
          p_Batch_Id                            NUMBER,
          p_Quantity_Invoiced                   NUMBER,
          p_Unit_Price                          NUMBER,
          p_Match_Status_Flag                   VARCHAR2,
          p_Attribute_Category                  VARCHAR2,
          p_Attribute1                          VARCHAR2,
          p_Attribute2                          VARCHAR2,
          p_Attribute3                          VARCHAR2,
          p_Attribute4                          VARCHAR2,
          p_Attribute5                          VARCHAR2,
          p_Prepay_Amount_Remaining             NUMBER,
          p_Assets_Addition_Flag                VARCHAR2,
          p_Assets_Tracking_Flag                VARCHAR2,
          p_Distribution_Line_Number            NUMBER,
          p_Line_Type_Lookup_Code               VARCHAR2,
          p_Po_Distribution_Id                  NUMBER,
          p_Base_Amount                         NUMBER,
          p_Pa_Addition_Flag                    VARCHAR2,
          p_Posted_Amount                       NUMBER,
          p_Posted_Base_Amount                  NUMBER,
          p_Encumbered_Flag                     VARCHAR2,
          p_Accrual_Posted_Flag                 VARCHAR2,
          p_Cash_Posted_Flag                    VARCHAR2,
          p_Last_Update_Login                   NUMBER,
          p_Creation_Date                       DATE,
          p_Created_By                          NUMBER,
          p_Stat_Amount                         NUMBER,
          p_Attribute11                         VARCHAR2,
          p_Attribute12                         VARCHAR2,
          p_Attribute13                         VARCHAR2,
          p_Attribute14                         VARCHAR2,
          p_Attribute6                          VARCHAR2,
          p_Attribute7                          VARCHAR2,
          p_Attribute8                          VARCHAR2,
          p_Attribute9                          VARCHAR2,
          p_Attribute10                         VARCHAR2,
          p_Attribute15                         VARCHAR2,
          p_Accts_Pay_Code_Comb_Id              NUMBER,
          p_Reversal_Flag                       VARCHAR2,
          p_Parent_Invoice_Id                   NUMBER,
          p_Income_Tax_Region                   VARCHAR2,
          p_Final_Match_Flag                    VARCHAR2,
       -- Removed for bug 4277744
       -- p_Ussgl_Transaction_Code              VARCHAR2,
       -- p_Ussgl_Trx_Code_Context              VARCHAR2,
          p_Expenditure_Item_Date               DATE,
          p_Expenditure_Organization_Id         NUMBER,
          p_Expenditure_Type                    VARCHAR2,
          p_Pa_Quantity                         NUMBER,
          p_Project_Id                          NUMBER,
          p_Task_Id                             NUMBER,
          p_Quantity_Variance                   NUMBER,
          p_Base_Quantity_Variance              NUMBER,
          p_Packet_Id                           NUMBER,
          p_Awt_Flag                            VARCHAR2,
          p_Awt_Group_Id                        NUMBER,
          p_Pay_Awt_Group_Id                    NUMBER,--bug6639866
          p_Awt_Tax_Rate_Id                     NUMBER,
          p_Awt_Gross_Amount                    NUMBER,
          p_Reference_1                         VARCHAR2,
          p_Reference_2                         VARCHAR2,
          p_Org_Id                              NUMBER,
          p_Other_Invoice_Id                    NUMBER,
          p_Awt_Invoice_Id                      NUMBER,
          p_Awt_Origin_Group_Id                 NUMBER,
          p_Program_Application_Id              NUMBER,
          p_Program_Id                          NUMBER,
          p_Program_Update_Date                 DATE,
          p_Request_Id                          NUMBER,
          p_Tax_Recoverable_Flag                VARCHAR2,
          p_Award_Id                            NUMBER,
          p_Start_Expense_Date                  DATE,
          p_Merchant_Document_Number            VARCHAR2,
          p_Merchant_Name                       VARCHAR2,
          p_Merchant_Tax_Reg_Number             VARCHAR2,
          p_Merchant_Taxpayer_Id                VARCHAR2,
          p_Country_Of_Supply                   VARCHAR2,
          p_Merchant_Reference                  VARCHAR2,
          p_parent_reversal_id                  NUMBER,
          p_rcv_transaction_id                  NUMBER,
          p_matched_uom_lookup_code             VARCHAR2,
          p_global_attribute_category           VARCHAR2 DEFAULT NULL,
          p_global_attribute1                   VARCHAR2 DEFAULT NULL,
          p_global_attribute2                   VARCHAR2 DEFAULT NULL,
          p_global_attribute3                   VARCHAR2 DEFAULT NULL,
          p_global_attribute4                   VARCHAR2 DEFAULT NULL,
          p_global_attribute5                   VARCHAR2 DEFAULT NULL,
          p_global_attribute6                   VARCHAR2 DEFAULT NULL,
          p_global_attribute7                   VARCHAR2 DEFAULT NULL,
          p_global_attribute8                   VARCHAR2 DEFAULT NULL,
          p_global_attribute9                   VARCHAR2 DEFAULT NULL,
          p_global_attribute10                  VARCHAR2 DEFAULT NULL,
          p_global_attribute11                  VARCHAR2 DEFAULT NULL,
          p_global_attribute12                  VARCHAR2 DEFAULT NULL,
          p_global_attribute13                  VARCHAR2 DEFAULT NULL,
          p_global_attribute14                  VARCHAR2 DEFAULT NULL,
          p_global_attribute15                  VARCHAR2 DEFAULT NULL,
          p_global_attribute16                  VARCHAR2 DEFAULT NULL,
          p_global_attribute17                  VARCHAR2 DEFAULT NULL,
          p_global_attribute18                  VARCHAR2 DEFAULT NULL,
          p_global_attribute19                  VARCHAR2 DEFAULT NULL,
          p_global_attribute20                  VARCHAR2 DEFAULT NULL,
          p_Calling_Sequence                    VARCHAR2,
          p_Receipt_Verified_Flag               VARCHAR2 DEFAULT NULL,
          p_Receipt_Required_flag               VARCHAR2 DEFAULT NULL,
          p_Receipt_Missing_flag                VARCHAR2 DEFAULT NULL,
          p_Justification                       VARCHAR2 DEFAULT NULL,
          p_Expense_Group                       VARCHAR2 DEFAULT NULL,
          p_End_Expense_Date                    DATE DEFAULT NULL,
          p_Receipt_Currency_Code               VARCHAR2 DEFAULT NULL,
          p_Receipt_Conversion_Rate             VARCHAR2 DEFAULT NULL,
          p_Receipt_Currency_Amount             NUMBER DEFAULT NULL,
          p_Daily_Amount                        NUMBER DEFAULT NULL,
          p_Web_Parameter_Id                    NUMBER DEFAULT NULL,
          p_Adjustment_Reason                   VARCHAR2 DEFAULT NULL,
          p_Credit_Card_Trx_Id                  NUMBER DEFAULT NULL,
          p_Company_Prepaid_Invoice_Id          NUMBER DEFAULT NULL,
          -- Invoice Lines Project Stage 1
          p_Rounding_Amt                        NUMBER DEFAULT NULL,
          p_Charge_Applicable_To_Dist_ID        NUMBER DEFAULT NULL,
          p_Corrected_Invoice_Dist_ID           NUMBER DEFAULT NULL,
          p_Related_ID                          NUMBER DEFAULT NULL,
          p_Asset_Book_Type_Code                VARCHAR2 DEFAULT NULL,
          p_Asset_Category_ID                   NUMBER DEFAULT NULL,
	  --ETAX: Invwkb
	  p_Intended_Use                        VARCHAR2 DEFAULT NULL,
	  --Freight and Special Charges
	  p_rcv_charge_addition_flag		VARCHAR2 DEFAULT 'N')
 IS

  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(100);
  l_dist_match_type        VARCHAR2(25);
  CURSOR C IS
  SELECT rowid
    FROM AP_INVOICE_DISTRIBUTIONS
   WHERE invoice_id = p_Invoice_Id
     AND   distribution_line_number = p_Distribution_Line_Number;

  CURSOR C2 IS SELECT ap_invoice_distributions_s.nextval FROM sys.dual;

BEGIN

  -- Update the calling sequence

  current_calling_sequence := 'AP_AID_TABLE_HANDLER_PKG.Insert_Row<-'
                              ||p_Calling_Sequence;

  -- Check for uniqueness of the distribution line number

  AP_AID_TABLE_HANDLER_PKG.CHECK_UNIQUE(
          p_Rowid,
          p_Invoice_Id,
	  p_Invoice_Line_Number,
          p_Distribution_Line_Number,
          'AP_AID_TABLE_HANDLER_PKG.Insert_Row');

  debug_info := 'Open cursor C2';
  OPEN C2;
  debug_info := 'Fetch cursor C2';
  FETCH C2 INTO p_Invoice_Distribution_Id;
  debug_info := 'Close cursor C2';
  CLOSE C2;

  -- Figure out NOCOPY the dist_match_type (not passed from invoice w/b)

  IF (p_rcv_transaction_id IS NOT NULL AND
      p_po_distribution_id IS NOT NULL) THEN
        l_dist_match_type := 'ITEM_TO_RECEIPT';
  ELSIF (p_rcv_transaction_id IS NOT NULL AND
         p_po_distribution_id IS NULL)     THEN
        l_dist_match_type := 'OTHER_TO_RECEIPT';
  ELSIF (p_rcv_transaction_id IS NULL AND
        p_po_distribution_id IS NOT NULL) THEN
        l_dist_match_type := 'ITEM_TO_PO';
  ELSE
        l_dist_match_type := NULL;
  END IF;

  debug_info := 'Insert into ap_invoice_distributions';

  INSERT INTO AP_INVOICE_DISTRIBUTIONS(
              invoice_id,
              -- Invoice Lines Project Stage 1
              invoice_line_number,
              distribution_class,
              dist_code_combination_id,
              invoice_distribution_id,
              last_update_date,
              last_updated_by,
              accounting_date,
              period_name,
              set_of_books_id,
              amount,
              description,
              type_1099,
              posted_flag,
              batch_id,
              quantity_invoiced,
              unit_price,
              match_status_flag,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              prepay_amount_remaining,
              assets_addition_flag,
              assets_tracking_flag,
              distribution_line_number,
              line_type_lookup_code,
              po_distribution_id,
              base_amount,
              pa_addition_flag,
              posted_amount,
              posted_base_amount,
              encumbered_flag,
              accrual_posted_flag,
              cash_posted_flag,
              last_update_login,
              creation_date,
              created_by,
              stat_amount,
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
              accts_pay_code_combination_id,
              reversal_flag,
              parent_invoice_id,
              income_tax_region,
              final_match_flag,
           -- Removed for bug 4277744
           -- ussgl_transaction_code,
           -- ussgl_trx_code_context,
              expenditure_item_date,
              expenditure_organization_id,
              expenditure_type,
              pa_quantity,
              project_id,
              task_id,
              quantity_variance,
              base_quantity_variance,
              packet_id,
              awt_flag,
              awt_group_id,
              pay_awt_group_id,--bug6639866
              awt_tax_rate_id,
              awt_gross_amount,
              reference_1,
              reference_2,
              other_invoice_id,
              awt_invoice_id,
              awt_origin_group_id,
              program_application_id,
              program_id,
              program_update_date,
              request_id,
              tax_recoverable_flag,
              award_id,
              start_expense_date,
              merchant_document_number,
              merchant_name,
              merchant_tax_reg_number,
              merchant_taxpayer_id,
              country_of_supply,
              merchant_reference,
              parent_reversal_id,
              rcv_transaction_id,
              dist_match_type,
              matched_uom_lookup_code,
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
              receipt_verified_flag,
              receipt_required_flag,
              receipt_missing_flag,
              justification,
              expense_Group,
              end_Expense_Date,
              receipt_Currency_Code,
              receipt_Conversion_Rate,
              receipt_Currency_Amount,
              daily_Amount,
              web_Parameter_Id,
              adjustment_Reason,
              credit_Card_Trx_Id,
              company_Prepaid_Invoice_Id,
              org_id, --MOAC project
              -- Invoice Lines Project Stage 1
              rounding_amt,
              charge_applicable_to_dist_id,
              corrected_invoice_dist_id,
              related_id,
              asset_book_type_code,
              asset_category_id,
	      --ETAX: Invwkb
	      intended_use,
	      --Freight and Special Charges
	      rcv_charge_addition_flag
             ) VALUES (
              p_Invoice_Id,
              -- Invoice Lines Project Stage 1
              p_Invoice_Line_Number,
              p_Distribution_Class,
              p_Dist_Code_Combination_Id,
              p_Invoice_Distribution_Id,
              --add for new column 'Invoice_Distribution_Id'
              p_Last_Update_Date,
              p_Last_Updated_By,
              p_Accounting_Date,
              p_Period_Name,
              p_Set_Of_Books_Id,
              p_Amount,
              p_Description,
              p_Type_1099,
              p_Posted_Flag,
              p_Batch_Id,
              p_Quantity_Invoiced,
              p_Unit_Price,
              p_Match_Status_Flag,
              p_Attribute_Category,
              p_Attribute1,
              p_Attribute2,
              p_Attribute3,
              p_Attribute4,
              p_Attribute5,
              p_Prepay_Amount_Remaining,
              p_Assets_Addition_Flag,
              p_Assets_Tracking_Flag,
              p_Distribution_Line_Number,
              p_Line_Type_Lookup_Code,
              p_Po_Distribution_Id,
              p_Base_Amount,
              p_Pa_Addition_Flag,
              p_Posted_Amount,
              p_Posted_Base_Amount,
              p_Encumbered_Flag,
              p_Accrual_Posted_Flag,
              p_Cash_Posted_Flag,
              p_Last_Update_Login,
              p_Creation_Date,
              p_Created_By,
              p_Stat_Amount,
              p_Attribute11,
              p_Attribute12,
              p_Attribute13,
              p_Attribute14,
              p_Attribute6,
              p_Attribute7,
              p_Attribute8,
              p_Attribute9,
              p_Attribute10,
              p_Attribute15,
              p_Accts_Pay_Code_Comb_Id,
              p_Reversal_Flag,
              p_Parent_Invoice_Id,
              p_Income_Tax_Region,
              p_Final_Match_Flag,
           -- Removed for bug 4277744
           -- p_Ussgl_Transaction_Code,
           -- p_Ussgl_Trx_Code_Context,
              p_Expenditure_Item_Date,
              p_Expenditure_Organization_Id,
              p_Expenditure_Type,
              p_Pa_Quantity,
              p_Project_Id,
              p_Task_Id,
              p_Quantity_Variance,
              p_Base_Quantity_Variance,
              p_Packet_Id,
              p_Awt_Flag,
              p_Awt_Group_Id,
              p_Pay_Awt_Group_Id,--bug6639866
              p_Awt_Tax_Rate_Id,
              p_Awt_Gross_Amount,
              p_Reference_1,
              p_Reference_2,
              p_Other_Invoice_Id,
              p_Awt_Invoice_Id,
              p_Awt_Origin_Group_Id,
              p_Program_Application_Id,
              p_Program_Id,
              p_Program_Update_Date,
              p_Request_Id,
              p_Tax_Recoverable_Flag,
              p_Award_Id,
              p_Start_Expense_Date,
              p_Merchant_Document_Number,
              p_Merchant_Name,
              p_Merchant_Tax_Reg_Number,
              p_Merchant_Taxpayer_Id,
              p_Country_Of_Supply,
              p_Merchant_Reference,
              p_Parent_Reversal_Id,
              p_rcv_transaction_id,
              l_dist_match_type,
              p_matched_uom_lookup_code,
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
              p_Receipt_Verified_Flag,
              p_Receipt_Required_flag,
              p_Receipt_Missing_flag,
              p_Justification,
              p_Expense_Group,
              p_End_Expense_Date,
              p_Receipt_Currency_Code,
              p_Receipt_Conversion_Rate,
              p_Receipt_Currency_Amount,
              p_Daily_Amount,
              p_Web_Parameter_Id,
              p_Adjustment_Reason,
              p_Credit_Card_Trx_Id,
              p_Company_Prepaid_Invoice_Id,
              p_org_id,  --MOAC project
              -- Invoice Lines Project Stage 1
              p_rounding_amt,
              p_charge_applicable_to_dist_id,
              p_corrected_invoice_dist_id,
              p_related_id,
              p_asset_book_type_code,
              p_asset_category_id,
	      --ETAX: Invwkb
	      p_intended_use,
	      p_rcv_charge_addition_flag
             );

    --Bug 4539462 DBI logging
    AP_DBI_PKG.Maintain_DBI_Summary
            (p_table_name => 'AP_INVOICE_DISTRIBUTIONS',
             p_operation => 'I',
             p_key_value1 => p_invoice_id,
             p_key_value2 => p_invoice_distribution_id,
             p_calling_sequence => current_calling_sequence);

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


PROCEDURE Update_Row  (
          p_Rowid                               VARCHAR2,
          p_Invoice_Id                          NUMBER,
          p_Invoice_Line_Number                 NUMBER,
          p_Distribution_Class                  VARCHAR2,
          p_Dist_Code_Combination_Id            NUMBER,
          p_Last_Update_Date                    DATE,
          p_Last_Updated_By                     NUMBER,
          p_Accounting_Date                     DATE,
          p_Period_Name                         VARCHAR2,
          p_Set_Of_Books_Id                     NUMBER,
          p_Amount                              NUMBER,
          p_Description                         VARCHAR2,
          p_Type_1099                           VARCHAR2,
          p_Posted_Flag                         VARCHAR2,
          p_Batch_Id                            NUMBER,
          p_Quantity_Invoiced                   NUMBER,
          p_Unit_Price                          NUMBER,
          p_Match_Status_Flag                   VARCHAR2,
          p_Attribute_Category                  VARCHAR2,
          p_Attribute1                          VARCHAR2,
          p_Attribute2                          VARCHAR2,
          p_Attribute3                          VARCHAR2,
          p_Attribute4                          VARCHAR2,
          p_Attribute5                          VARCHAR2,
          p_Prepay_Amount_Remaining             NUMBER,
          p_Assets_Addition_Flag                VARCHAR2,
          p_Assets_Tracking_Flag                VARCHAR2,
          p_Distribution_Line_Number            NUMBER,
          p_Line_Type_Lookup_Code               VARCHAR2,
          p_Po_Distribution_Id                  NUMBER,
          p_Base_Amount                         NUMBER,
          p_Pa_Addition_Flag                    VARCHAR2,
          p_Posted_Amount                       NUMBER,
          p_Posted_Base_Amount                  NUMBER,
          p_Encumbered_Flag                     VARCHAR2,
          p_Accrual_Posted_Flag                 VARCHAR2,
          p_Cash_Posted_Flag                    VARCHAR2,
          p_Last_Update_Login                   NUMBER,
          p_Stat_Amount                         NUMBER,
          p_Attribute11                         VARCHAR2,
          p_Attribute12                         VARCHAR2,
          p_Attribute13                         VARCHAR2,
          p_Attribute14                         VARCHAR2,
          p_Attribute6                          VARCHAR2,
          p_Attribute7                          VARCHAR2,
          p_Attribute8                          VARCHAR2,
          p_Attribute9                          VARCHAR2,
          p_Attribute10                         VARCHAR2,
          p_Attribute15                         VARCHAR2,
          p_Accts_Pay_Code_Comb_Id              NUMBER,
          p_Reversal_Flag                       VARCHAR2,
          p_Parent_Invoice_Id                   NUMBER,
          p_Income_Tax_Region                   VARCHAR2,
          p_Final_Match_Flag                    VARCHAR2,
       -- Removed for bug 4277744
       -- p_Ussgl_Transaction_Code              VARCHAR2,
       -- p_Ussgl_Trx_Code_Context              VARCHAR2,
          p_Expenditure_Item_Date               DATE,
          p_Expenditure_Organization_Id         NUMBER,
          p_Expenditure_Type                    VARCHAR2,
          p_Pa_Quantity                         NUMBER,
          p_Project_Id                          NUMBER,
          p_Task_Id                             NUMBER,
          p_Quantity_Variance                   NUMBER,
          p_Base_Quantity_Variance              NUMBER,
          p_Packet_Id                           NUMBER,
          p_Awt_Flag                            VARCHAR2,
          p_Awt_Group_Id                        NUMBER,
          p_Pay_Awt_Group_Id                    NUMBER,--bug6639866
          p_Awt_Tax_Rate_Id                     NUMBER,
          p_Awt_Gross_Amount                    NUMBER,
          p_Reference_1                         VARCHAR2,
          p_Reference_2                         VARCHAR2,
          p_Org_Id                              NUMBER,
          p_Other_Invoice_Id                    NUMBER,
          p_Awt_Invoice_Id                      NUMBER,
          p_Awt_Origin_Group_Id                 NUMBER,
          p_Program_Application_Id              NUMBER,
          p_Program_Id                          NUMBER,
          p_Program_Update_Date                 DATE,
          p_Request_Id                          NUMBER,
          p_Tax_Recoverable_Flag                VARCHAR2,
          p_Award_Id                            NUMBER,
          p_Start_Expense_Date                  DATE,
          p_Merchant_Document_Number            VARCHAR2,
          p_Merchant_Name                       VARCHAR2,
          p_Merchant_Tax_Reg_Number             VARCHAR2,
          p_Merchant_Taxpayer_Id                VARCHAR2,
          p_Country_Of_Supply                   VARCHAR2,
          p_Merchant_Reference                  VARCHAR2,
          p_global_attribute_category           VARCHAR2 DEFAULT NULL,
          p_global_attribute1                   VARCHAR2 DEFAULT NULL,
          p_global_attribute2                   VARCHAR2 DEFAULT NULL,
          p_global_attribute3                   VARCHAR2 DEFAULT NULL,
          p_global_attribute4                   VARCHAR2 DEFAULT NULL,
          p_global_attribute5                   VARCHAR2 DEFAULT NULL,
          p_global_attribute6                   VARCHAR2 DEFAULT NULL,
          p_global_attribute7                   VARCHAR2 DEFAULT NULL,
          p_global_attribute8                   VARCHAR2 DEFAULT NULL,
          p_global_attribute9                   VARCHAR2 DEFAULT NULL,
          p_global_attribute10                  VARCHAR2 DEFAULT NULL,
          p_global_attribute11                  VARCHAR2 DEFAULT NULL,
          p_global_attribute12                  VARCHAR2 DEFAULT NULL,
          p_global_attribute13                  VARCHAR2 DEFAULT NULL,
          p_global_attribute14                  VARCHAR2 DEFAULT NULL,
          p_global_attribute15                  VARCHAR2 DEFAULT NULL,
          p_global_attribute16                  VARCHAR2 DEFAULT NULL,
          p_global_attribute17                  VARCHAR2 DEFAULT NULL,
          p_global_attribute18                  VARCHAR2 DEFAULT NULL,
          p_global_attribute19                  VARCHAR2 DEFAULT NULL,
          p_global_attribute20                  VARCHAR2 DEFAULT NULL,
          p_Calling_Sequence                    VARCHAR2,
          -- Invoice Lines Project Stage 1
          p_Rounding_Amt                        NUMBER   DEFAULT NULL,
          p_Charge_Applicable_To_Dist_ID        NUMBER   DEFAULT NULL,
          p_Corrected_Invoice_Dist_ID           NUMBER   DEFAULT NULL,
          p_Related_ID                          NUMBER   DEFAULT NULL,
          p_Asset_Book_Type_Code                VARCHAR2 DEFAULT NULL,
          p_Asset_Category_ID                   NUMBER   DEFAULT NULL,
	  --ETAX: Invwkb
	  p_Intended_Use                        VARCHAR2 DEFAULT NULL)

  IS
  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(100);
  l_invoice_distribution_id NUMBER;
BEGIN

  -- Update the calling sequence

  current_calling_sequence := 'AP_AID_TABLE_HANDLER_PKG.Update_Row<-'
                              ||p_Calling_Sequence;

  -- Check for uniqueness of the distribution line number

  AP_AID_TABLE_HANDLER_PKG.CHECK_UNIQUE(
          p_Rowid,
          p_Invoice_Id,
	  p_Invoice_Line_Number,
          p_Distribution_Line_Number,
          'AP_AID_TABLE_HANDLER_PKG.Update_Row');

  debug_info := 'Update ap_invoice_distributions';


  UPDATE AP_INVOICE_DISTRIBUTIONS
     SET
       invoice_id                      = p_Invoice_Id,
       invoice_line_number             = p_Invoice_Line_Number,
       distribution_class              = p_Distribution_Class,
       dist_code_combination_id        = p_Dist_Code_Combination_Id,
       last_update_date                = p_Last_Update_Date,
       last_updated_by                 = p_Last_Updated_By,
       accounting_date                 = p_Accounting_Date,
       period_name                     = p_Period_Name,
       set_of_books_id                 = p_Set_Of_Books_Id,
       amount                          = p_Amount,
       description                     = p_Description,
       type_1099                       = p_Type_1099,
       posted_flag                     = p_Posted_Flag,
       batch_id                        = p_Batch_Id,
       quantity_invoiced               = p_Quantity_Invoiced,
       unit_price                      = p_Unit_Price,
       match_status_flag               = p_Match_Status_Flag,
       attribute_category              = p_Attribute_Category,
       attribute1                      = p_Attribute1,
       attribute2                      = p_Attribute2,
       attribute3                      = p_Attribute3,
       attribute4                      = p_Attribute4,
       attribute5                      = p_Attribute5,
       prepay_amount_remaining         = p_Prepay_Amount_Remaining,
       assets_addition_flag            = p_Assets_Addition_Flag,
       assets_tracking_flag            = p_Assets_Tracking_Flag,
       distribution_line_number        = p_Distribution_Line_Number,
       line_type_lookup_code           = p_Line_Type_Lookup_Code,
       po_distribution_id              = p_Po_Distribution_Id,
       base_amount                     = p_Base_Amount,
       pa_addition_flag                = p_Pa_Addition_Flag,
       posted_amount                   = p_Posted_Amount,
       posted_base_amount              = p_Posted_Base_Amount,
       encumbered_flag                 = p_Encumbered_Flag,
       accrual_posted_flag             = p_Accrual_Posted_Flag,
       cash_posted_flag                = p_Cash_Posted_Flag,
       last_update_login               = p_Last_Update_Login,
       stat_amount                     = p_Stat_Amount,
       attribute11                     = p_Attribute11,
       attribute12                     = p_Attribute12,
       attribute13                     = p_Attribute13,
       attribute14                     = p_Attribute14,
       attribute6                      = p_Attribute6,
       attribute7                      = p_Attribute7,
       attribute8                      = p_Attribute8,
       attribute9                      = p_Attribute9,
       attribute10                     = p_Attribute10,
       attribute15                     = p_Attribute15,
       accts_pay_code_combination_id   = p_Accts_Pay_Code_Comb_Id,
       reversal_flag                   = p_Reversal_Flag,
       parent_invoice_id               = p_Parent_Invoice_Id,
       income_tax_region               = p_Income_Tax_Region,
       final_match_flag                = p_Final_Match_Flag,
    -- Removed for bug 4277744
    -- ussgl_transaction_code          = p_Ussgl_Transaction_Code,
    -- ussgl_trx_code_context          = p_Ussgl_Trx_Code_Context,
       expenditure_item_date           = p_Expenditure_Item_Date,
       expenditure_organization_id     = p_Expenditure_Organization_Id,
       expenditure_type                = p_Expenditure_Type,
       pa_quantity                     = p_Pa_Quantity,
       project_id                      = p_Project_Id,
       task_id                         = p_Task_Id,
       quantity_variance               = p_Quantity_Variance,
       base_quantity_variance          = p_Base_Quantity_Variance,
       packet_id                       = p_Packet_Id,
       awt_flag                        = p_Awt_Flag,
       awt_group_id                    = p_Awt_Group_Id,
       pay_awt_group_id                = p_Pay_Awt_Group_Id,--bug6639866
       awt_tax_rate_id                 = p_Awt_Tax_Rate_Id,
       awt_gross_amount                = p_Awt_Gross_Amount,
       reference_1                     = p_Reference_1,
       reference_2                     = p_Reference_2,
       other_invoice_id                = p_Other_Invoice_Id,
       awt_invoice_id                  = p_Awt_Invoice_Id,
       awt_origin_group_id             = p_Awt_Origin_Group_Id,
       program_application_id          = p_Program_Application_Id,
       program_id                      = p_Program_Id,
       program_update_date             = p_Program_Update_Date,
       request_id                      = p_Request_Id,
       tax_recoverable_flag            = p_Tax_Recoverable_Flag,
       award_id                        = p_Award_Id,
       start_expense_date              = p_Start_Expense_Date,
       merchant_document_number        = p_Merchant_Document_Number,
       merchant_name                   = p_Merchant_Name,
       merchant_tax_reg_number         = p_Merchant_Tax_Reg_Number,
       merchant_taxpayer_id            = p_Merchant_Taxpayer_Id,
       country_of_supply               = p_Country_Of_Supply,
       merchant_reference              = p_Merchant_Reference,
       global_attribute_category       = p_global_attribute_category,
       global_attribute1               = p_global_attribute1,
       global_attribute2               = p_global_attribute2,
       global_attribute3               = p_global_attribute3,
       global_attribute4               = p_global_attribute4,
       global_attribute5               = p_global_attribute5,
       global_attribute6               = p_global_attribute6,
       global_attribute7               = p_global_attribute7,
       global_attribute8               = p_global_attribute8,
       global_attribute9               = p_global_attribute9,
       global_attribute10              = p_global_attribute10,
       global_attribute11              = p_global_attribute11,
       global_attribute12              = p_global_attribute12,
       global_attribute13              = p_global_attribute13,
       global_attribute14              = p_global_attribute14,
       global_attribute15              = p_global_attribute15,
       global_attribute16              = p_global_attribute16,
       global_attribute17              = p_global_attribute17,
       global_attribute18              = p_global_attribute18,
       global_attribute19              = p_global_attribute19,
       global_attribute20              = p_global_attribute20,
       Rounding_Amt                    = p_rounding_amt,
       Charge_Applicable_To_Dist_ID    = p_charge_applicable_to_dist_id,
       Corrected_Invoice_Dist_ID       = p_corrected_invoice_dist_id,
       Related_ID                      = p_related_id,
       Asset_Book_Type_Code            = p_asset_book_type_code,
       Asset_Category_ID               = p_asset_category_id ,
       --ETAX: Invwkb
       Intended_Use		       = p_intended_use
   WHERE rowid = p_Rowid;

    IF (SQL%NOTFOUND) THEN
      Raise NO_DATA_FOUND;
    END IF;

    --Bug 4539462 DBI logging
    AP_DBI_PKG.Maintain_DBI_Summary
       (p_table_name => 'AP_INVOICE_DISTRIBUTIONS',
        p_operation => 'U',
        p_key_value1 => P_invoice_id,
        p_key_value2 => l_invoice_distribution_id,
        p_calling_sequence => current_calling_sequence);


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
          p_Rowid                   VARCHAR2,
          p_Calling_Sequence        VARCHAR2)
  IS
  current_calling_sequence      VARCHAR2(2000);
  debug_info                    VARCHAR2(100);
  l_invoice_distribution_id     NUMBER;
  l_invoice_id	      NUMBER;

BEGIN

  -- Update the calling sequence

  current_calling_sequence := 'AP_AID_TABLE_HANDLER_PKG.Delete_Row<-'
                              ||p_Calling_Sequence;

    SELECT invoice_distribution_id, invoice_id
    INTO l_invoice_distribution_id, l_invoice_id
    FROM ap_invoice_distributions
    WHERE rowid = p_Rowid;

  DELETE FROM AP_INVOICE_DISTRIBUTIONS
   WHERE rowid = p_Rowid;

  IF (SQL%NOTFOUND) THEN
    Raise NO_DATA_FOUND;
  END IF;

    --Bug 4539462 DBI logging
    AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICE_DISTRIBUTIONS',
               p_operation => 'D',
	       p_key_value1 => l_invoice_id,
               p_key_value2 => l_invoice_distribution_id,
                p_calling_sequence => current_calling_sequence);

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

END AP_AID_TABLE_HANDLER_PKG;

/
