--------------------------------------------------------
--  DDL for Package AP_INVOICE_DISTRIBUTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_INVOICE_DISTRIBUTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: apiindis.pls 120.15.12010000.3 2010/06/04 08:37:33 ppodhiya ship $ */

  --Invoice Lines: Distributions
  PROCEDURE CHECK_UNIQUE (X_ROWID                    VARCHAR2,
                          X_INVOICE_ID               NUMBER,
			  X_INVOICE_LINE_NUMBER	     NUMBER,
                          X_DISTRIBUTION_LINE_NUMBER NUMBER,
                          X_Calling_Sequence         VARCHAR2);

  FUNCTION Get_UOM(X_CCID NUMBER, X_Ch_Of_Accts_Id NUMBER) RETURN VARCHAR2;

  FUNCTION Get_Posted_Status(X_Accrual_Posted_Flag VARCHAR2,
                             X_Cash_Posted_Flag    VARCHAR2,
                             X_Posted_Flag         VARCHAR2,
                             X_Org_Id          IN  NUMBER DEFAULT
                             mo_global.get_current_org_id ) RETURN VARCHAR2;

  PROCEDURE Select_Summary(X_Invoice_Id       IN     NUMBER,
                           X_Total            IN OUT NOCOPY NUMBER,
                           X_Total_Rtot_DB    IN OUT NOCOPY NUMBER,
                           X_LINE_NUMBER      IN     NUMBER, --Bug4539547
                           X_Calling_Sequence IN            VARCHAR2);

  PROCEDURE Set_Inv_Packet_Id(X_Invoice_Id       IN     NUMBER,
                              X_Packet_Id        IN OUT NOCOPY NUMBER,
                              X_Calling_Sequence IN VARCHAR2);
  FUNCTION  Query_New_Packet_Id(X_Rowid            VARCHAR2,
                                X_Packet_Id        NUMBER,
                                X_Calling_Sequence VARCHAR2) RETURN BOOLEAN;

  FUNCTION  All_Encumbered(X_Invoice_Id       NUMBER,
                           X_Rowid            VARCHAR2,
                           X_Calling_Sequence VARCHAR2) RETURN BOOLEAN;
  FUNCTION  Check_Cash_Basis_Paid(X_Invoice_Id       NUMBER,
                                  X_Calling_Sequence VARCHAR2) RETURN BOOLEAN;

  PROCEDURE Adjust_PO(X_PO_Distribution_Id NUMBER,
                      X_Line_Location_id   NUMBER,
                      X_Quantity_Billed    NUMBER,
                      X_Amount_Billed      NUMBER,
                      X_Match_Basis        VARCHAR2,  /* Amount Based Matching */
                      X_Matched_Uom        VARCHAR2, /* Bug 4121303 */
                      X_Calling_Sequence   VARCHAR2);

  FUNCTION  Substrbyte(X_String           IN VARCHAR2,
                       X_Start            IN NUMBER,
                       X_End              IN NUMBER,
                       X_Calling_Sequence IN VARCHAR2) RETURN VARCHAR2;

  /*==========================================================================*/
  /*                                                                          */
  /* This function is called from ap_invoice_lines_pkg.insert_from_dist_set   */
  /* to generate invoice distributions from a distribution set given an       */
  /* existing invoice line.  This function will:                              */
  /* 1) create distributions in either candidate or permanent mode depending  */
  /*    X_generate_permanent parameter.                                       */
  /* 2) if an error is encountered, the debug info and context will be        */
  /*    populated into the OUT parameters.                                    */
  /* 3) return TRUE if the generation was successful or FALSE otherwise.      */
  /*                                                                          */
  /*==========================================================================*/

  FUNCTION Insert_From_Dist_Set(
           X_batch_id            IN         NUMBER,
           X_invoice_id          IN         NUMBER,
           X_line_number         IN         NUMBER,
           X_dist_tab            IN         AP_INVOICE_LINES_PKG.dist_tab_type,
           X_Generate_Permanent  IN         VARCHAR2 DEFAULT 'N',
           X_Debug_Info          OUT NOCOPY VARCHAR2,
           X_Debug_Context       OUT NOCOPY VARCHAR2,
           X_Calling_Sequence    IN         VARCHAR2) RETURN BOOLEAN;

/*
 *  eTax Uptake.  Commenting out this function.  It will
 *  be obsolete
  PROCEDURE insert_prepay_dist (X_invoice_id         IN number,
                                X_GL_Date            IN date,
                                X_Period_Name        IN varchar2,
                                X_Type_1099          IN varchar2,
                                X_Income_Tax_Region  IN varchar2,
                                X_Offset_VAT_code    IN varchar2,
                                X_calling_sequence   IN varchar2);
*/

--ETAX: Invwkb
/*
  PROCEDURE insert_dist (
              X_invoice_id                 IN number,
              X_invoice_line_number        IN number,
              X_invoice_distribution_id    IN number,
              X_Line_Type                  IN varchar2,
              X_GL_Date                    IN date,
              X_Period_Name                IN varchar2,
              X_Type_1099                  IN varchar2,
              X_Income_Tax_Region          IN varchar2,
              X_Amount                     IN number,
              X_Code_Combination_Id        IN number,
              X_PA_Quantity                IN number,
              X_Description                IN varchar2,
              X_tax_recoverable_flag       IN varchar2,
              X_po_distribution_id         IN number,
              X_Attribute_Category         IN varchar2,
              X_Attribute1                 IN varchar2,
              X_Attribute2                 IN varchar2,
              X_Attribute3                 IN varchar2,
              X_Attribute4                 IN varchar2,
              X_Attribute5                 IN varchar2,
              X_Attribute6                 IN varchar2,
              X_Attribute7                 IN varchar2,
              X_Attribute8                 IN varchar2,
              X_Attribute9                 IN varchar2,
              X_Attribute10                IN varchar2,
              X_Attribute11                IN varchar2,
              X_Attribute12                IN varchar2,
              X_Attribute13                IN varchar2,
              X_Attribute14                IN varchar2,
              X_Attribute15                IN varchar2,
              X_Calling_Sequence           IN varchar2,
              X_company_prepaid_invoice_id IN number DEFAULT NULL,
              X_cc_reversal_flag           IN varchar2 DEFAULT NULL);
  */

  PROCEDURE update_distributions (
            X_invoice_id                   IN            number,
            X_line_number                  IN            number,
            X_type_1099                    IN            varchar2,
            X_income_tax_region            IN            varchar2,
            X_vendor_changed_flag          IN OUT NOCOPY varchar2,
            X_update_base                  IN OUT NOCOPY varchar2,
            X_reset_match_status           IN OUT NOCOPY varchar2,
            X_update_occurred              IN OUT NOCOPY varchar2,
            X_calling_sequence             IN            varchar2);

   PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Invoice_Id                     NUMBER,
                       -- Invoice Lines Project Stage 1
                       X_Invoice_Line_Number            NUMBER,
                       X_Distribution_Class             VARCHAR2,
                       X_Invoice_Distribution_Id IN OUT NOCOPY NUMBER,
                       X_Dist_Code_Combination_Id       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Accounting_Date                DATE,
                       X_Period_Name                    VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Amount                         NUMBER,
                       X_Description                    VARCHAR2,
                       X_Type_1099                      VARCHAR2,
                       X_Posted_Flag                    VARCHAR2,
                       X_Batch_Id                       NUMBER,
                       X_Quantity_Invoiced              NUMBER,
                       X_Unit_Price                     NUMBER,
                       X_Match_Status_Flag              VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Prepay_Amount_Remaining        NUMBER,
                       X_Assets_Addition_Flag           VARCHAR2,
                       X_Assets_Tracking_Flag           VARCHAR2,
                       X_Distribution_Line_Number       NUMBER,
                       X_Line_Type_Lookup_Code          VARCHAR2,
                       X_Po_Distribution_Id             NUMBER,
                       X_Base_Amount                    NUMBER,
                       X_Pa_Addition_Flag               VARCHAR2,
                       X_Posted_Amount                  NUMBER,
                       X_Posted_Base_Amount             NUMBER,
                       X_Encumbered_Flag                VARCHAR2,
                       X_Accrual_Posted_Flag            VARCHAR2,
                       X_Cash_Posted_Flag               VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Stat_Amount                    NUMBER,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Accts_Pay_Code_Comb_Id         NUMBER,
                       X_Reversal_Flag                  VARCHAR2,
                       X_Parent_Invoice_Id              NUMBER,
                       X_Income_Tax_Region              VARCHAR2,
                       X_Final_Match_Flag               VARCHAR2,
                       X_Expenditure_Item_Date          DATE,
                       X_Expenditure_Organization_Id    NUMBER,
                       X_Expenditure_Type               VARCHAR2,
                       X_Pa_Quantity                    NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Quantity_Variance              NUMBER,
                       X_Base_Quantity_Variance         NUMBER,
                       X_Packet_Id                      NUMBER,
                       X_Awt_Flag                       VARCHAR2,
                       X_Awt_Group_Id                   NUMBER,
                       X_Pay_Awt_Group_Id               NUMBER,--bug6639866
                       X_Awt_Tax_Rate_Id                NUMBER,
                       X_Awt_Gross_Amount               NUMBER,
                       X_Reference_1                    VARCHAR2,
                       X_Reference_2                    VARCHAR2,
                       X_Org_Id                         NUMBER,
                       X_Other_Invoice_Id               NUMBER,
                       X_Awt_Invoice_Id                 NUMBER,
                       X_Awt_Origin_Group_Id            NUMBER,
                       X_Program_Application_Id         NUMBER,
                       X_Program_Id                     NUMBER,
                       X_Program_Update_Date            DATE,
                       X_Request_Id                     NUMBER,
                       X_Tax_Recoverable_Flag           VARCHAR2,
                       X_Award_Id                       NUMBER,
                       X_Start_Expense_Date             DATE,
                       X_Merchant_Document_Number       VARCHAR2,
                       X_Merchant_Name                  VARCHAR2,
                       X_Merchant_Reference             VARCHAR2,
                       X_Merchant_Tax_Reg_Number        VARCHAR2,
                       X_Merchant_Taxpayer_Id           VARCHAR2,
                       X_Country_Of_Supply              VARCHAR2,
                       X_Parent_Reversal_id    NUMBER,
                       X_rcv_transaction_id    NUMBER,
                       X_matched_uom_lookup_code  VARCHAR2,
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
                       -- Invoice Lines Project Stage 1
                       X_rounding_amt                   NUMBER DEFAULT NULL,
                       X_charge_applicable_to_dist_id   NUMBER DEFAULT NULL,
                       X_corrected_invoice_dist_id      NUMBER DEFAULT NULL,
                       X_related_id                     NUMBER DEFAULT NULL,
                       X_asset_book_type_code           VARCHAR2 DEFAULT NULL,
                       X_asset_category_id              NUMBER DEFAULT NULL ,
		       X_intended_use			VARCHAR2 DEFAULT NULL,
                       x_calling_sequence               VARCHAR2 );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Invoice_Id                       NUMBER,
                     -- Invoice Lines Project Stage 1
                     X_Invoice_Line_Number              NUMBER,
                     X_Distribution_Class               VARCHAR2,
                     X_Invoice_Distribution_Id          NUMBER,
                     X_Dist_Code_Combination_Id         NUMBER,
                     X_Accounting_Date                  DATE,
                     X_Period_Name                      VARCHAR2,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Amount                           NUMBER,
                     X_Description                      VARCHAR2,
                     X_Type_1099                        VARCHAR2,
                     X_Posted_Flag                      VARCHAR2,
                     X_Batch_Id                         NUMBER,
                     X_Quantity_Invoiced                NUMBER,
                     X_Unit_Price                       NUMBER,
                     X_Match_Status_Flag                VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Prepay_Amount_Remaining          NUMBER,
                     X_Assets_Addition_Flag             VARCHAR2,
                     X_Assets_Tracking_Flag             VARCHAR2,
                     X_Distribution_Line_Number         NUMBER,
                     X_Line_Type_Lookup_Code            VARCHAR2,
                     X_Po_Distribution_Id               NUMBER,
                     X_Base_Amount                      NUMBER,
                     X_Pa_Addition_Flag                 VARCHAR2,
                     X_Posted_Amount                    NUMBER,
                     X_Posted_Base_Amount               NUMBER,
                     X_Encumbered_Flag                  VARCHAR2,
                     X_Accrual_Posted_Flag              VARCHAR2,
                     X_Cash_Posted_Flag                 VARCHAR2,
                     X_Stat_Amount                      NUMBER,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Accts_Pay_Code_Comb_Id    NUMBER,
                     X_Reversal_Flag                    VARCHAR2,
                     X_Parent_Invoice_Id                NUMBER,
                     X_Income_Tax_Region                VARCHAR2,
                     X_Final_Match_Flag                 VARCHAR2,
                     X_Expenditure_Item_Date            DATE,
                     X_Expenditure_Organization_Id      NUMBER,
                     X_Expenditure_Type                 VARCHAR2,
                     X_Pa_Quantity                      NUMBER,
                     X_Project_Id                       NUMBER,
                     X_Task_Id                          NUMBER,
                     X_Quantity_Variance                NUMBER,
                     X_Base_Quantity_Variance           NUMBER,
                     X_Packet_Id                        NUMBER,
                     X_Awt_Flag                         VARCHAR2,
                     X_Awt_Group_Id                     NUMBER,
                     X_Pay_Awt_Group_Id                 NUMBER,--bug6639866
                     X_Awt_Tax_Rate_Id                  NUMBER,
                     X_Awt_Gross_Amount                 NUMBER,
                     X_Reference_1                      VARCHAR2,
                     X_Reference_2                      VARCHAR2,
                     X_Org_Id                           NUMBER,
                     X_Other_Invoice_Id                 NUMBER,
                     X_Awt_Invoice_Id                   NUMBER,
                     X_Awt_Origin_Group_Id              NUMBER,
                     X_Program_Application_Id           NUMBER,
                     X_Program_Id                       NUMBER,
                     X_Program_Update_Date              DATE,
                     X_Request_Id                       NUMBER,
                     X_Tax_Recoverable_Flag             VARCHAR2,
                     X_Award_Id                         NUMBER,
                     X_Start_Expense_Date               DATE,
                     X_Merchant_Document_Number         VARCHAR2,
                     X_Merchant_Name                    VARCHAR2,
                     X_Merchant_Reference               VARCHAR2,
                     X_Merchant_Tax_Reg_Number          VARCHAR2,
                     X_Merchant_Taxpayer_Id             VARCHAR2,
                     X_Country_Of_Supply                VARCHAR2,
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
                     -- Invoice Lines Project Stage 1
                     X_rounding_amt                   NUMBER DEFAULT NULL,
                     X_charge_applicable_to_dist_id   NUMBER DEFAULT NULL,
                     X_corrected_invoice_dist_id      NUMBER DEFAULT NULL,
                     X_related_id                     NUMBER DEFAULT NULL,
                     X_asset_book_type_code           VARCHAR2 DEFAULT NULL,
                     X_asset_category_id              NUMBER DEFAULT NULL,
                     --ETAX: Invoice Workbench
                     X_Intended_Use                   VARCHAR2 DEFAULT NULL,
                     X_Calling_Sequence               VARCHAR2 );




  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Invoice_Id                     NUMBER,
                       -- Invoice Lines Project Stage 1
                       X_Invoice_Line_Number            NUMBER,
                       X_Distribution_Class             VARCHAR2,
                       X_Dist_Code_Combination_Id       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Accounting_Date                DATE,
                       X_Period_Name                    VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Amount                         NUMBER,
                       X_Description                    VARCHAR2,
                       X_Type_1099                      VARCHAR2,
                       X_Posted_Flag                    VARCHAR2,
                       X_Batch_Id                       NUMBER,
                       X_Quantity_Invoiced              NUMBER,
                       X_Unit_Price                     NUMBER,
                       X_Match_Status_Flag              VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Prepay_Amount_Remaining        NUMBER,
                       X_Assets_Addition_Flag           VARCHAR2,
                       X_Assets_Tracking_Flag           VARCHAR2,
                       X_Distribution_Line_Number       NUMBER,
                       X_Line_Type_Lookup_Code          VARCHAR2,
                       X_Po_Distribution_Id             NUMBER,
                       X_Base_Amount                    NUMBER,
                       X_Pa_Addition_Flag               VARCHAR2,
                       X_Posted_Amount                  NUMBER,
                       X_Posted_Base_Amount             NUMBER,
                       X_Encumbered_Flag                VARCHAR2,
                       X_Accrual_Posted_Flag              VARCHAR2,
                       X_Cash_Posted_Flag                 VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Stat_Amount                    NUMBER,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Accts_Pay_Code_Comb_Id         NUMBER,
                       X_Reversal_Flag                  VARCHAR2,
                       X_Parent_Invoice_Id              NUMBER,
                       X_Income_Tax_Region              VARCHAR2,
                       X_Final_Match_Flag               VARCHAR2,
                       X_Expenditure_Item_Date          DATE,
                       X_Expenditure_Organization_Id    NUMBER,
                       X_Expenditure_Type               VARCHAR2,
                       X_Pa_Quantity                    NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Quantity_Variance              NUMBER,
                       X_Base_Quantity_Variance         NUMBER,
                       X_Packet_Id                      NUMBER,
                       X_Awt_Flag                       VARCHAR2,
                       X_Awt_Group_Id                   NUMBER,
                       X_Pay_Awt_Group_Id               NUMBER,--bug6639866
                       X_Awt_Tax_Rate_Id                NUMBER,
                       X_Awt_Gross_Amount               NUMBER,
                       X_Reference_1                    VARCHAR2,
                       X_Reference_2                    VARCHAR2,
                       X_Org_Id                         NUMBER,
                       X_Other_Invoice_Id               NUMBER,
                       X_Awt_Invoice_Id                 NUMBER,
                       X_Awt_Origin_Group_Id            NUMBER,
                       X_Program_Application_Id         NUMBER,
                       X_Program_Id                     NUMBER,
                       X_Program_Update_Date            DATE,
                       X_Request_Id                     NUMBER,
                       X_Tax_Recoverable_Flag           VARCHAR2,
                       X_Award_Id                       NUMBER,
                       X_Start_Expense_Date             DATE,
                       X_Merchant_Document_Number       VARCHAR2,
                       X_Merchant_Name                  VARCHAR2,
                       X_Merchant_Tax_Reg_Number        VARCHAR2,
                       X_Merchant_Taxpayer_Id           VARCHAR2,
                       X_Country_Of_Supply              VARCHAR2,
                       X_Merchant_Reference             VARCHAR2,
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
                       X_Calling_Sequence               VARCHAR2,
                       -- Invoice Lines Project Stage 1
                       X_rounding_amt                   NUMBER DEFAULT NULL,
                       X_charge_applicable_to_dist_id    NUMBER DEFAULT NULL,
                       X_corrected_invoice_dist_id      NUMBER DEFAULT NULL,
                       X_related_id                     NUMBER DEFAULT NULL,
                       X_asset_book_type_code           VARCHAR2 DEFAULT NULL,
                       X_asset_category_id              NUMBER DEFAULT NULL,
		       X_Intended_Use			VARCHAR2 DEFAULT NULL);

  PROCEDURE Delete_Row(X_Rowid            VARCHAR2,
                       X_Calling_Sequence VARCHAR2);

  FUNCTION Get_UOM_From_Segments(
          X_Concatenated_Segments         IN      VARCHAR2,
          X_Ch_Of_Accts_Id                IN      NUMBER) RETURN VARCHAR2;

  -- Bug 1567235
  /* Function to get the sum of distribution amount for a given invoice
     and the balancing segment  */
  FUNCTION Get_Segment_Dist_Amount(
           X_invoice_id                   IN      NUMBER,
           X_Prepay_Dist_CCID             IN      NUMBER,
           X_Sob_Id                       IN      NUMBER) RETURN NUMBER;

  -- Bug 1567235.
  /* Procedure to get the sum of distribution amount for a given invoice
     and the sum of the distribution amount for a given prepayment */
  PROCEDURE Get_Prepay_Amount_Available(
            X_Invoice_ID                   IN      NUMBER,
            X_Prepay_ID                    IN      NUMBER,
            X_Sob_Id                       IN      NUMBER,
            X_Balancing_Segment            OUT NOCOPY     VARCHAR2,
            X_Prepay_Amount                OUT NOCOPY     NUMBER,
            X_Invoice_Amount               OUT NOCOPY     NUMBER);

  -- Bug 1648309
  FUNCTION Check_Diff_Dist_Segments(
           X_Invoice_Id                   IN      NUMBER,
           X_Sob_Id                       IN      NUMBER) RETURN BOOLEAN;

  -- Bug 1567235
  /* Function to get the value of the balancing segment for a given
     CCID */
  FUNCTION get_balancing_segment_value(
          X_dist_code_combination_id      IN      NUMBER,
          X_Sob_Id                        IN      NUMBER) RETURN VARCHAR2;

  -- Bug 2118673
  /* Function to get the value of the balancing segment for a given
     account */
  FUNCTION get_balancing_seg_from_acc(
          X_Account      IN VARCHAR2,
          X_Sob_Id       IN NUMBER) RETURN VARCHAR2;

  --  This function corrects error roundings in the biggest distribution
  --  for a given non-base currency invoice.
  PROCEDURE Round_Biggest_Distribution(
   X_Base_Currency_Code     IN VARCHAR2,
          X_Invoice_Id         IN NUMBER,
          X_Calling_Sequence   IN VARCHAR2);

/*==========================================================================*/
/*                                                                          */
/* This function may be called from any process that needs to insert a dist */
/* from a line that is not PO/RCV matched or distribution set based.        */
/* This function should only be called if a default account is available at */
/* the line level either standalone or to be built from overlay code concat.*/
/* If a freight or misc line, then there should be no allocations associated*/
/*  with it.                                                                */
/* The following are the parameters and how/which should be populated by a  */
/* calling module:                                                */
/* 1) X_batch_id -- If batch control enabled, this is a mandatory parameter */
/* 2) X_invoice_id - This is mutually exclusive with X_invoice_lines_rec.   */
/*                 -- If calling module provides invoice id and line number */
/*                 -- this function will read from trx table into a line    */
/*                 -- record, else it will use the X_invoice_lines_rec as   */
/*                 -- line record.                                          */
/* 3) X_invoice_date - Mandatory parameter.                                 */
/* 4) X_vendor_id - Mandatory parameter.                                    */
/* 5) X_invoice_currency - Mandatory parameter.                             */
/* 6) X_exchange_rate - Mandatory if foreign currency invoice.             */
/* 7) X_exchange_rate_type - Mandatory if foreign currency invoice.         */
/* 8) X_line_number - Line number for line to generate dist for.  Should    */
/*                  -- be populated if calling module does not pass line    */
/*                  -- record.                                              */
/* 9) X_invoice_lines_rec - Line record requesting generation of dist       */
/*                        -- If the calling module has it (as in Import)    */
/*                        -- it is most performant to pass it as argument   */
/*                        -- rather than invoice id and line number combo.  */
/* 10)X_line_source - Should be populated with 'IMPORT' if called from the  */
/*                  -- Open interface.  This will improve performance for   */
/*                  -- the interface, since account derivation should have  */
/*                  -- already been done there.                             */
/* 11)X_Generate_Permanent - Pass Y if calling module wants to create       */
/*                         -- permanent distributions, N otherwise.         */
/* 12)X_Validate_Info - Indicates whether calling module requests this      */
/*                    -- function to perform validations                    */
/* 13)Other parameters are used for error handling.                         */
/* This function will:                                                      */
/* 1) create a distributions in either candidate or permanent mode depending*/
/*    X_generate_permanent parameter.                                       */
/* 2) if an error is encountered, and the error refers to invalid data the  */
/*    error code will be populated as follows:                              */
/*    'INVALID_ACCOUNT' - Account provided did not pass validation          */
/*    'CANNOT_OVERLAY'  - Cannot produce a valid account using overlay info */
/*    'NO_OPEN_PERIOD'  - Cannot find an open period.                       */
/*    'GL_DATE_PA_NOT_OPEN' -  GL date is not open period for PA.           */
/* 3) if an unexpected error occurs, the debug info and context will be     */
/*    populated into the OUT parameters.                                    */
/* 4) if an error occurs while validating PA information, the               */
/*    X_Msg_Application and X_Msg_Data will be returned in OUT parameters.  */
/* 5) return TRUE if the generation was successful or FALSE otherwise.      */
/* 6) If called from the Interface Import, most validations will be ignored */
/*    as they are assumed to be handled by the Import Validation.  We       */
/*    distinguish the case by whether the invoice_lines_rec parameter is    */
/*    populated or null.  It should only be populated when called from the  */
/*    Import.                                                               */
/*                                                                          */
/*==========================================================================*/
FUNCTION Insert_Single_Dist_From_Line(
         X_batch_id            IN         AP_INVOICES.BATCH_ID%TYPE,
         X_invoice_id          IN         NUMBER,
         X_invoice_date        IN         AP_INVOICES.INVOICE_DATE%TYPE,
         X_vendor_id           IN         AP_INVOICES.VENDOR_ID%TYPE,
         X_invoice_currency    IN         AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE,
         X_exchange_rate       IN         AP_INVOICES.EXCHANGE_RATE%TYPE,
         X_exchange_rate_type  IN         AP_INVOICES.EXCHANGE_RATE_TYPE%TYPE,
         X_exchange_date       IN         AP_INVOICES.EXCHANGE_DATE%TYPE,
         X_line_number         IN         NUMBER,
         X_invoice_lines_rec   IN         AP_INVOICES_PKG.r_invoice_line_rec,
         X_line_source         IN         VARCHAR2,
         X_Generate_Permanent  IN         VARCHAR2 DEFAULT 'N',
         X_Validate_Info       IN         BOOLEAN DEFAULT TRUE,
         X_Error_Code          OUT NOCOPY VARCHAR2,
         X_Debug_Info          OUT NOCOPY VARCHAR2,
         X_Debug_Context       OUT NOCOPY VARCHAR2,
         X_Msg_Application     OUT NOCOPY VARCHAR2,
         X_Msg_Data            OUT NOCOPY VARCHAR2,
         X_Calling_Sequence    IN         VARCHAR2) RETURN BOOLEAN;

--Bug 8346277
FUNCTION Insert_AWT_Dist_From_Line(
         X_batch_id            IN         AP_INVOICES.BATCH_ID%TYPE,
         X_invoice_id          IN         NUMBER,
         X_invoice_date        IN         AP_INVOICES.INVOICE_DATE%TYPE,
         X_vendor_id           IN         AP_INVOICES.VENDOR_ID%TYPE,
         X_invoice_currency    IN         AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE,
         X_exchange_rate       IN         AP_INVOICES.EXCHANGE_RATE%TYPE,
         X_exchange_rate_type  IN         AP_INVOICES.EXCHANGE_RATE_TYPE%TYPE,
         X_exchange_date       IN         AP_INVOICES.EXCHANGE_DATE%TYPE,
         X_line_number         IN         NUMBER,
         X_invoice_lines_rec   IN         AP_INVOICES_PKG.r_invoice_line_rec,
         X_line_source         IN         VARCHAR2,
         X_Generate_Permanent  IN         VARCHAR2 DEFAULT 'N',
         X_Validate_Info       IN         BOOLEAN DEFAULT TRUE,
         X_Error_Code          OUT NOCOPY VARCHAR2,
         X_Debug_Info          OUT NOCOPY VARCHAR2,
         X_Debug_Context       OUT NOCOPY VARCHAR2,
         X_Msg_Application     OUT NOCOPY VARCHAR2,
         X_Msg_Data            OUT NOCOPY VARCHAR2,
         X_Calling_Sequence    IN         VARCHAR2) RETURN BOOLEAN;

  /*========================================================================*/
  /*                                                                        */
  /* This function may be called from any process that needs to insert dists*/
  /* from a charge line that has an associated allocation rule.             */
  /* This function will:                                                    */
  /* 1) create a distributions in either candidate or permanent mode        */
  /*    depending on X_generate_permanent parameter.                        */
  /* 2) X_Validate_Info parameter indicates whether validations should be   */
  /*    performed.  This parameter should be FALSE if calling module        */
  /*    already performed validations e.g. Open Interface Import.  However, */
  /*    the overlay process/PA account process will still take place        */
  /*    and may produce an error.                                           */
  /* 3) if an error is encountered, and the error refers to invalid data the*/
  /*    error code will be populated as follows:                            */
  /*   'NO_ALLOCATION_RULE_FOUND' - No allocation rule was found associated */
  /*                                with the charge line                    */
  /*   'ALLOCATION_ALREADY_EXECUTED' - The allocation rule has already been */
  /*                                   executed.                            */
  /*   'NON_FULL_INVOICE' -  Allocation rule indicates full proration but   */
  /*                         invoice is not complete.                       */
  /*   'UNDISTRIBUTED_LINE_EXISTS' - Allocating to an undistributed line is */
  /*                                 not possible and one such line exists. */
  /*   'IMPROPER_LINE_IN_ALLOC_RULE' -A line contains 0 total distributions */
  /*                                   and we cannot allocate against it.   */
  /*   'CANNOT_READ_EXP_DATE' - Failed to read expenditure item date.       */
  /*   'INVALID_ACCOUNT' - Account provided did not pass validation         */
  /*   'CANNOT_OVERLAY'  - Cannot produce a valid a/c using overlay info    */
  /*   'NO_OPEN_PERIOD'  - Cannot find an open period.                      */
  /*   'GL_DATE_PA_NOT_OPEN' -  GL date is not open period for PA.          */
  /* 4) if an unexpected error occurs, the debug info and context will be   */
  /*    populated into the OUT parameters.                                  */
  /* 5) if an error occurs while validating PA information, the             */
  /*    X_Msg_Application and X_Msg_Data will be returned in OUT parameters.*/
  /* 6) return TRUE if the generation was successful or FALSE otherwise.    */
  /*                                                                        */
  /*========================================================================*/
  FUNCTION Insert_Charge_From_Alloc(
         X_invoice_id          IN         NUMBER,
         X_line_number         IN         NUMBER,
         X_Generate_Permanent  IN         VARCHAR2 DEFAULT 'N',
         X_Validate_Info       IN         BOOLEAN DEFAULT TRUE,
         X_Error_Code          OUT NOCOPY VARCHAR2,
         X_Debug_Info          OUT NOCOPY VARCHAR2,
         X_Debug_Context       OUT NOCOPY VARCHAR2,
         X_Msg_Application     OUT NOCOPY VARCHAR2,
         X_Msg_Data            OUT NOCOPY VARCHAR2,
         X_Calling_Sequence    IN         VARCHAR2) RETURN BOOLEAN;

  /*========================================================================*/
  /*                                                                        */
  /* This function may be called to get the original amount for an ITEM     */
  /* or ACCRUAL type line that has been split into ITEM/ACCRUAL, IPV and ERV*/
  /* It may also be called in Price Corrections where there was no original */
  /* ITEM/ACCRUAL but simply IPV which may have been split into IPV and ERV.*/
  /*                                                                        */
  /*========================================================================*/
  FUNCTION Get_Total_Dist_Amount(
         X_invoice_distribution_id IN       NUMBER) RETURN NUMBER;

    /*========================================================================*/
  /*                                                                        */
  /* Function to get the distribution line number by given distribution id  */
  /*                                                                        */
  /*========================================================================*/

  FUNCTION GET_DIST_LINE_NUM(
          X_invoice_dist_id    IN         NUMBER) RETURN NUMBER;

  /*========================================================================*/
  /*                                                                        */
  /* Function to get the invoice line number by given distribution id       */
  /*                                                                        */
  /*========================================================================*/

  FUNCTION GET_INV_LINE_NUM(
          X_invoice_dist_id    IN         NUMBER) RETURN NUMBER;

  /*========================================================================*/
  /*                                                                        */
  /* Function to get the invoice number by given distribution id            */
  /*                                                                        */
  /*========================================================================*/

  FUNCTION GET_INVOICE_NUM(
          X_invoice_dist_id    IN         NUMBER) RETURN VARCHAR2;

  /*========================================================================*/
  /*                                                                        */
  /* Function to get the correct related_id for reveral distribution line   */
  /*          when system is reversing the distribution or discard inv line */
  /*                                                                        */
  /*========================================================================*/

  FUNCTION GET_REVERSAL_RELATED_ID(
          X_related_dist_id    IN         NUMBER) RETURN NUMBER;


  --Invoice Lines: Distributions
  /*========================================================================*/
  /* Function to get the reversing distribution num for a particular       */
  /* invoice distribution id						   */
  /*=======================================================================*/

  FUNCTION GET_REVERSING_DIST_NUM (
	  X_Invoice_Dist_id    IN	  NUMBER) RETURN NUMBER;

  FUNCTION Calculate_Variance(
            X_DISTRIBUTION_ID      IN            NUMBER,
            X_REPORTING_LEDGER_ID  IN            NUMBER,
            X_DISTRIBUTION_AMT        OUT NOCOPY NUMBER,
            X_DIST_BASE_AMT           OUT NOCOPY NUMBER,
            X_IPV                  IN OUT NOCOPY NUMBER,
            X_BIPV                 IN OUT NOCOPY NUMBER,
            X_ERV                  IN OUT NOCOPY NUMBER,
            X_DEBUG_INFO           IN OUT NOCOPY VARCHAR2,
            X_DEBUG_CONTEXT        IN OUT NOCOPY VARCHAR2,
            X_CALLING_SEQUENCE     IN OUT NOCOPY VARCHAR2) Return Boolean;

 --Invoice Lines: Distributions
 FUNCTION Dist_Refer_Active_Corr(P_Invoice_Dist_ID  IN NUMBER,
				 P_Calling_Sequence IN VARCHAR2) RETURN BOOLEAN;

 --Invoice Lines: Distributions
 FUNCTION Chrg_Refer_Active_Dist(P_Invoice_Dist_Id  IN NUMBER,
				 P_Calling_Sequence IN VARCHAR2) RETURN BOOLEAN;
 --Invoice Lines: Distributions
 PROCEDURE Make_Distributions_Permanent
                   (P_Invoice_Id          IN NUMBER,
                    P_Invoice_Line_Number IN NUMBER DEFAULT NULL,
		    P_Calling_Sequence    IN VARCHAR2);

 --Invoice Lines: Distributions
 Function Associated_Charges(
		P_Invoice_Id              IN NUMBER,
                P_Invoice_Distribution_Id IN NUMBER) RETURN NUMBER;

 --Invoice Lines: Distributions: Wrapper for Java. -- Bug 9374412
 FUNCTION Dist_Refer_Active_Corr_Wrap(P_Invoice_Dist_ID  IN NUMBER,
				 P_Calling_Sequence IN VARCHAR2) RETURN NUMBER;

 --Invoice Lines: Distributions: Wrapper for Java. -- Bug 9374412
 FUNCTION Chrg_Refer_Active_Dist_Wrap(P_Invoice_Dist_Id  IN NUMBER,
				 P_Calling_Sequence IN VARCHAR2) RETURN NUMBER;

END AP_INVOICE_DISTRIBUTIONS_PKG;


/
