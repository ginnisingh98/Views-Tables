--------------------------------------------------------
--  DDL for Package Body AP_LINES_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_LINES_UPGRADE_PKG" AS
/* $Header: aplnupgb.pls 120.23.12010000.20 2010/04/19 11:13:55 mkmeda ship $ */

g_errbuf                 VARCHAR2(2000) := NULL;
g_retcode                VARCHAR2(200)  := NULL;
G_PROCEDURE_FAILURE      EXCEPTION;
G_NO_CHILD_PROCESS       EXCEPTION;
g_init_process           VARCHAR2(1) := 'Y';
g_batch_size             VARCHAR2(30);
g_num_workers            NUMBER;
g_debug_flag             VARCHAR2(1) := 'N';
g_parent_request_id      NUMBER;
g_request_id             NUMBER;
g_upgrade_mode           VARCHAR2(30);
g_table_owner            VARCHAR2(30);

G_CHILD_FAILED           EXCEPTION;
G_TABLE_NOT_EXIST        EXCEPTION;
                         PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);


---------------------------------------------------
-- PROCEDURE TRUNCATE_TABLE
-- This procedure TRUNCATE_TABLE truncates the
-- specifed table
---------------------------------------------------

PROCEDURE Truncate_table (p_table_name VARCHAR2) IS
    l_stmt VARCHAR2(100);
BEGIN
    l_stmt := 'TRUNCATE table '|| g_table_owner ||'.'|| p_table_name;
    if g_debug_flag = 'Y' then
       AP_Debug_Pkg.Print(g_debug_flag, 'Table Owner '|| g_table_owner);
       AP_Debug_Pkg.Print(g_debug_flag,'');
       AP_Debug_Pkg.Print(g_debug_flag,l_stmt);
    end if;
    EXECUTE IMMEDIATE l_stmt;

EXCEPTION
    WHEN G_TABLE_NOT_EXIST THEN
        null;      -- Oracle 942, table does not exist, no actions
    WHEN OTHERS THEN
        RAISE;
END Truncate_Table;


---------------------------------------------------
-- FUNCTION LAUNCH_WORKER
-- This function LAUNCH_WORKER will submit the subworker
-- request.
-- p_worker_no is the worker number of this particular worker
---------------------------------------------------
FUNCTION LAUNCH_WORKER(p_worker_no                    NUMBER,
                       p_calling_sequence             VARCHAR2)
RETURN NUMBER IS

  l_request_id                  NUMBER;
  l_debug_info                  VARCHAR2(1000);
  l_curr_calling_sequence       VARCHAR2(2000);

BEGIN


  l_curr_calling_sequence := 'AP_LINES_UPGRADE_PKG.Launch_Worker<-'
                                   || p_calling_sequence;

  l_debug_info := 'Inside Launch Worker procedure for worker ' || p_worker_no;
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;

  l_request_id := FND_REQUEST.SUBMIT_REQUEST
                         ('SQLAP',
                          'APILNSUB',
                          NULL,
                          NULL,
                          FALSE,
                          p_worker_no,
                          g_init_process,
                          g_upgrade_mode,
                          g_batch_size,
                          g_num_workers,
                          g_parent_request_id,
                          g_debug_flag);

  -- This is the concurrent executable of the subworker.

  l_debug_info := 'Submitted the request ' || l_request_id || 'for worker ' || p_worker_no;
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;


  IF (l_request_id = 0) THEN
      rollback;
      g_retcode := -2;
      g_errbuf := 'Error in Procedure: LAUNCH_WORKER
                   Message: '||fnd_message.get;
      RAISE G_NO_CHILD_PROCESS;

  END IF;

  g_request_id := l_request_id;

  RETURN l_request_id;

EXCEPTION
  WHEN G_NO_CHILD_PROCESS THEN
       g_retcode := -1;
       l_debug_info := 'No child process submitted';
       IF g_debug_flag = 'Y' THEN
          AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
       END IF;

       RAISE;
   WHEN OTHERS THEN
        ROLLBACK;
        g_retcode := -2;
        g_errbuf := 'Error in Procedure: LAUNCH_WORKER
                     Message: '||sqlerrm;
        RAISE g_procedure_failure;

END LAUNCH_WORKER;



------------------------------------------------------------------
-- Procedure insert_dist_line_info
-- Purpose
-- This procedure INSERT_DIST_LINE_INFO inserts the distribution info
-- and the corresponding line number into the temp table
------------------------------------------------------------------
PROCEDURE Insert_Dist_Line_Info
                (p_start_rowid          IN        ROWID,
                 p_end_rowid            IN        ROWID,
                 p_calling_sequence     IN        VARCHAR2)  IS


l_debug_info                    VARCHAR2(1000);
l_curr_calling_sequence         VARCHAR2(2000);

BEGIN

  -- Update the calling sequence
  --
  l_curr_calling_sequence := 'Insert_Dist_Line_Info <-'||P_calling_sequence;
  --

  l_debug_info := 'Inside Insert_Dist_Line_Info procedure';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;

/* BUG 9080712 - In 11i for the reversed payment time AWT distirbutions,
                 the reversal flag populated as N. we need to correct the
		 value to Y. */

   UPDATE AP_Inv_Dists_Source AID
   SET aid.reversal_flag = 'Y'
   WHERE AID.line_type_lookup_code = 'AWT'
   AND   AID.parent_reversal_id IS NOT NULL
   AND   AID.awt_invoice_payment_id IS NOT NULL
   AND   AID.reversal_flag = 'N'
   AND   AID.invoice_id IN (
             SELECT /*+ ROWID(AI) */ AI.Invoice_ID
	     FROM AP_Invoices_ALL AI
	     WHERE AI.Rowid BETWEEN p_start_rowid AND p_end_rowid
	     AND   AI.invoice_id = AID.invoice_id);

/* BUG 9080712 - END */

  /* Insert the distribution info and line number for each distribution
     into the temp table. We can directly access this table
     whenever we need information about the line number for a distribution
     rather than calculating it each time */


  INSERT INTO AP_Dist_Line_GT t1
        (ACCOUNTING_DATE,
         ACCRUAL_POSTED_FLAG,
         ASSETS_ADDITION_FLAG,
         ASSETS_TRACKING_FLAG,
         CASH_POSTED_FLAG,
         DISTRIBUTION_LINE_NUMBER,
         DIST_CODE_COMBINATION_ID,
         INVOICE_ID,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LINE_TYPE_LOOKUP_CODE,
         PERIOD_NAME,
         SET_OF_BOOKS_ID,
         ACCTS_PAY_CODE_COMBINATION_ID,
         AMOUNT,
         BASE_AMOUNT,
         BASE_INVOICE_PRICE_VARIANCE,
         BATCH_ID,
         CREATED_BY,
         CREATION_DATE,
         DESCRIPTION,
         EXCHANGE_RATE_VARIANCE,
         FINAL_MATCH_FLAG,
         INCOME_TAX_REGION,
         INVOICE_PRICE_VARIANCE,
         LAST_UPDATE_LOGIN,
         MATCH_STATUS_FLAG,
         POSTED_FLAG,
         PO_DISTRIBUTION_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
         QUANTITY_INVOICED,
         RATE_VAR_CODE_COMBINATION_ID,
         REQUEST_ID,
         REVERSAL_FLAG,
         TYPE_1099,
         UNIT_PRICE,
         VAT_CODE,
         AMOUNT_ENCUMBERED,
         BASE_AMOUNT_ENCUMBERED,
         ENCUMBERED_FLAG,
         EXCHANGE_DATE,
         EXCHANGE_RATE,
         EXCHANGE_RATE_TYPE,
         PRICE_ADJUSTMENT_FLAG,
         PRICE_VAR_CODE_COMBINATION_ID,
         QUANTITY_UNENCUMBERED,
         STAT_AMOUNT,
         AMOUNT_TO_POST,
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
         ATTRIBUTE_CATEGORY,
         BASE_AMOUNT_TO_POST,
         CASH_JE_BATCH_ID,
         EXPENDITURE_ITEM_DATE,
         EXPENDITURE_ORGANIZATION_ID,
         EXPENDITURE_TYPE,
         JE_BATCH_ID,
         PARENT_INVOICE_ID,
         PA_ADDITION_FLAG,
         PA_QUANTITY,
         POSTED_AMOUNT,
         POSTED_BASE_AMOUNT,
         PREPAY_AMOUNT_REMAINING,
         PROJECT_ACCOUNTING_CONTEXT,
         PROJECT_ID,
         TASK_ID,
         USSGL_TRANSACTION_CODE,
         USSGL_TRX_CODE_CONTEXT,
         EARLIEST_SETTLEMENT_DATE,
         REQ_DISTRIBUTION_ID,
         QUANTITY_VARIANCE,
         BASE_QUANTITY_VARIANCE,
         PACKET_ID,
         AWT_FLAG,
         AWT_GROUP_ID,
         AWT_TAX_RATE_ID,
         AWT_GROSS_AMOUNT,
         AWT_INVOICE_ID,
         AWT_ORIGIN_GROUP_ID,
         REFERENCE_1,
         REFERENCE_2,
         ORG_ID,
         OTHER_INVOICE_ID,
         AWT_INVOICE_PAYMENT_ID,
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
         AMOUNT_INCLUDES_TAX_FLAG,
         TAX_CALCULATED_FLAG,
         LINE_GROUP_NUMBER,
         RECEIPT_VERIFIED_FLAG,
         RECEIPT_REQUIRED_FLAG,
         RECEIPT_MISSING_FLAG,
         JUSTIFICATION,
         EXPENSE_GROUP,
         START_EXPENSE_DATE,
         END_EXPENSE_DATE,
         RECEIPT_CURRENCY_CODE,
         RECEIPT_CONVERSION_RATE,
         RECEIPT_CURRENCY_AMOUNT,
         DAILY_AMOUNT,
         WEB_PARAMETER_ID,
         ADJUSTMENT_REASON,
         AWARD_ID,
         MRC_ACCRUAL_POSTED_FLAG,
         MRC_CASH_POSTED_FLAG,
         MRC_DIST_CODE_COMBINATION_ID,
         MRC_AMOUNT,
         MRC_BASE_AMOUNT,
         MRC_BASE_INV_PRICE_VARIANCE,
         MRC_EXCHANGE_RATE_VARIANCE,
         MRC_POSTED_FLAG,
         MRC_PROGRAM_APPLICATION_ID,
         MRC_PROGRAM_ID,
         MRC_PROGRAM_UPDATE_DATE,
         MRC_RATE_VAR_CCID,
         MRC_REQUEST_ID,
         MRC_EXCHANGE_DATE,
         MRC_EXCHANGE_RATE,
         MRC_EXCHANGE_RATE_TYPE,
         MRC_AMOUNT_TO_POST,
         MRC_BASE_AMOUNT_TO_POST,
         MRC_CASH_JE_BATCH_ID,
         MRC_JE_BATCH_ID,
         MRC_POSTED_AMOUNT,
         MRC_POSTED_BASE_AMOUNT,
         MRC_RECEIPT_CONVERSION_RATE,
         CREDIT_CARD_TRX_ID,
         DIST_MATCH_TYPE,
         RCV_TRANSACTION_ID,
         INVOICE_DISTRIBUTION_ID,
         PARENT_REVERSAL_ID,
         TAX_RECOVERY_RATE,
         TAX_RECOVERY_OVERRIDE_FLAG,
         TAX_RECOVERABLE_FLAG,
         TAX_CODE_OVERRIDE_FLAG,
         TAX_CODE_ID,
         PA_CC_AR_INVOICE_ID,
         PA_CC_AR_INVOICE_LINE_NUM,
         PA_CC_PROCESSED_CODE,
         MERCHANT_DOCUMENT_NUMBER,
         MERCHANT_NAME,
         MERCHANT_REFERENCE,
         MERCHANT_TAX_REG_NUMBER,
         MERCHANT_TAXPAYER_ID,
         COUNTRY_OF_SUPPLY,
         MATCHED_UOM_LOOKUP_CODE,
         GMS_BURDENABLE_RAW_COST,
         ACCOUNTING_EVENT_ID,
         PREPAY_DISTRIBUTION_ID,
         UPGRADE_POSTED_AMT,
         UPGRADE_BASE_POSTED_AMT,
         INVENTORY_TRANSFER_STATUS,
         COMPANY_PREPAID_INVOICE_ID,
         CC_REVERSAL_FLAG,
         PREPAY_TAX_PARENT_ID,
         AWT_WITHHELD_AMT,
         INVOICE_INCLUDES_PREPAY_FLAG,
         PRICE_CORRECT_INV_ID,
         PRICE_CORRECT_QTY,
         PA_CMT_XFACE_FLAG,
         CANCELLATION_FLAG,
         FULLY_PAID_ACCTD_FLAG,
         ROOT_DISTRIBUTION_ID,
         XINV_PARENT_REVERSAL_ID,
         AMOUNT_VARIANCE,
         BASE_AMOUNT_VARIANCE,
         RECURRING_PAYMENT_ID,
         NEW_TAX_CODE_ID,
         LINE_NUMBER,
         REVERSAL_PARENT,
         MATCH_TYPE,
         SUMMARY_TAX_LINE_ID)
  SELECT   -- bug#6716261 hint is modified
         /*+ ORDERED ROWID(AI) SWAP_JOIN_INPUTS(ZXR)
             USE_NL_WITH_INDEX(AID,AP_INVOICE_DISTS_ARCH_U1)
	     USE_NL_WITH_INDEX(AID1,AP_INVOICE_DISTS_ARCH_U2) */
         AID.Accounting_Date,
         AID.Accrual_Posted_Flag,
         AID.Assets_Addition_Flag,
         AID.Assets_Tracking_Flag,
         AID.Cash_Posted_Flag,
         AID.Distribution_Line_Number,
         AID.Dist_Code_Combination_Id,
         AID.Invoice_Id,
         AID.Last_Updated_By,
         AID.Last_Update_Date,
         AID.Line_Type_Lookup_Code,
         AID.Period_Name,
         AID.Set_Of_Books_Id,
         AID.Accts_Pay_Code_Combination_Id,
         AID.Amount,
         AID.Base_Amount,
        -- 9196221 start
	(CASE
	  WHEN (NVL(POD.Accrue_On_Receipt_Flag,'Y') = 'N' AND
	        AID.Dist_Code_Combination_ID
		     = NVL(AID.Rate_Var_Code_Combination_ID,AID.Dist_Code_Combination_ID) AND
                AID.Dist_Code_Combination_ID
		     = NVL(AID.Price_Var_Code_Combination_ID,AID.Dist_Code_Combination_ID) AND
		AID.Amount <> NVL(AID.Invoice_Price_Variance,0)  --9365311
		) THEN
             NULL
	  ELSE  AID.Base_Invoice_Price_Variance
	  END) Base_Invoice_Price_Variance,
	 -- 9196221 end
         AID.Batch_Id,
         AID.Created_By,
         AID.Creation_Date,
         AID.Description,
        -- 9196221 start
	(CASE
	  WHEN (NVL(POD.Accrue_On_Receipt_Flag,'Y') = 'N' AND
	        AID.Dist_Code_Combination_ID
		     = NVL(AID.Rate_Var_Code_Combination_ID,AID.Dist_Code_Combination_ID) AND
                AID.Dist_Code_Combination_ID
		     = NVL(AID.Price_Var_Code_Combination_ID,AID.Dist_Code_Combination_ID) AND
		AID.Amount <> NVL(AID.Invoice_Price_Variance,0)  --9365311
		) THEN
             NULL
	  ELSE  AID.Exchange_Rate_Variance
	  END) Exchange_Rate_Variance,
	 -- 9196221 end
         AID.Final_Match_Flag,
         AID.Income_Tax_Region,
        -- 9196221 start
	(CASE
	  WHEN (NVL(POD.Accrue_On_Receipt_Flag,'Y') = 'N' AND
	        AID.Dist_Code_Combination_ID
		     = NVL(AID.Rate_Var_Code_Combination_ID,AID.Dist_Code_Combination_ID) AND
                AID.Dist_Code_Combination_ID
		     = NVL(AID.Price_Var_Code_Combination_ID,AID.Dist_Code_Combination_ID) AND
		AID.Amount <> NVL(AID.Invoice_Price_Variance,0)  --9365311
		) THEN
             NULL
	  ELSE  AID.Invoice_Price_Variance
	  END) Invoice_Price_Variance,
	 -- 9196221 end
         AID.Last_Update_Login,
         AID.Match_Status_Flag,
         AID.Posted_Flag,
         AID.Po_Distribution_Id,
         AID.Program_Application_Id,
         AID.Program_Id,
         AID.Program_Update_Date,
         AID.Quantity_Invoiced,
         AID.Rate_Var_Code_Combination_Id,
         AID.Request_Id,
         AID.Reversal_Flag,
         AID.Type_1099,
         AID.Unit_Price,
         AID.Vat_Code,
         AID.Amount_Encumbered,
         AID.Base_Amount_Encumbered,
         AID.Encumbered_Flag,
         AID.Exchange_Date,
         AID.Exchange_Rate,
         AID.Exchange_Rate_Type,
         AID.Price_Adjustment_Flag,
         AID.Price_Var_Code_Combination_Id,
         AID.Quantity_Unencumbered,
         AID.Stat_Amount,
         AID.Amount_To_Post,
         AID.Attribute1,
         AID.Attribute10,
         AID.Attribute11,
         AID.Attribute12,
         AID.Attribute13,
         AID.Attribute14,
         AID.Attribute15,
         AID.Attribute2,
         AID.Attribute3,
         AID.Attribute4,
         AID.Attribute5,
         AID.Attribute6,
         AID.Attribute7,
         AID.Attribute8,
         AID.Attribute9,
         AID.Attribute_Category,
         AID.Base_Amount_To_Post,
         AID.Cash_Je_Batch_Id,
         AID.Expenditure_Item_Date,
         AID.Expenditure_Organization_Id,
         AID.Expenditure_Type,
         AID.Je_Batch_Id,
         AID.Parent_Invoice_Id,
         AID.Pa_Addition_Flag,
         AID.Pa_Quantity,
         AID.Posted_Amount,
         AID.Posted_Base_Amount,
         AID.Prepay_Amount_Remaining,
         AID.Project_Accounting_Context,
         AID.Project_Id,
         AID.Task_Id,
         AID.Ussgl_Transaction_Code,
         AID.Ussgl_Trx_Code_Context,
         AID.Earliest_Settlement_Date,
         AID.Req_Distribution_Id,
         AID.Quantity_Variance,
         AID.Base_Quantity_Variance,
         AID.Packet_Id,
         AID.Awt_Flag,
         AID.Awt_Group_Id,
         AID.Awt_Tax_Rate_Id,
         AID.Awt_Gross_Amount,
         AID.Awt_Invoice_Id,
         AID.Awt_Origin_Group_Id,
         AID.Reference_1,
         AID.Reference_2,
         AID.Org_Id,
         AID.Other_Invoice_Id,
         AID.Awt_Invoice_Payment_Id,
         AID.Global_Attribute_Category,
         AID.Global_Attribute1,
         AID.Global_Attribute2,
         AID.Global_Attribute3,
         AID.Global_Attribute4,
         AID.Global_Attribute5,
         AID.Global_Attribute6,
         AID.Global_Attribute7,
         AID.Global_Attribute8,
         AID.Global_Attribute9,
         AID.Global_Attribute10,
         AID.Global_Attribute11,
         AID.Global_Attribute12,
         AID.Global_Attribute13,
         AID.Global_Attribute14,
         AID.Global_Attribute15,
         AID.Global_Attribute16,
         AID.Global_Attribute17,
         AID.Global_Attribute18,
         AID.Global_Attribute19,
         AID.Global_Attribute20,
         AID.Amount_Includes_Tax_Flag,
         AID.Tax_Calculated_Flag,
         AID.Line_Group_Number,
         AID.Receipt_Verified_Flag,
         AID.Receipt_Required_Flag,
         AID.Receipt_Missing_Flag,
         AID.Justification,
         AID.Expense_Group,
         AID.Start_Expense_Date,
         AID.End_Expense_Date,
         AID.Receipt_Currency_Code,
         AID.Receipt_Conversion_Rate,
         AID.Receipt_Currency_Amount,
         AID.Daily_Amount,
         AID.Web_Parameter_Id,
         AID.Adjustment_Reason,
         AID.Award_Id,
         NULL, --AID.Mrc_Accrual_Posted_Flag,
         NULL, --AID.Mrc_Cash_Posted_Flag,
         NULL, --AID.Mrc_Dist_Code_Combination_Id,
         NULL, --AID.Mrc_Amount,
         NULL, --AID.Mrc_Base_Amount,
         NULL, --AID.Mrc_Base_Inv_Price_Variance,
         NULL, --AID.Mrc_Exchange_Rate_Variance,
         NULL, --AID.Mrc_Posted_Flag,
         NULL, --AID.Mrc_Program_Application_Id,
         NULL, --AID.Mrc_Program_Id,
         NULL, --AID.Mrc_Program_Update_Date,
         NULL, --AID.Mrc_Rate_Var_Ccid,
         NULL, --AID.Mrc_Request_Id,
         NULL, --AID.Mrc_Exchange_Date,
         NULL, --AID.Mrc_Exchange_Rate,
         NULL, --AID.Mrc_Exchange_Rate_Type,
         NULL, --AID.Mrc_Amount_To_Post,
         NULL, --AID.Mrc_Base_Amount_To_Post,
         NULL, --AID.Mrc_Cash_Je_Batch_Id,
         NULL, --AID.Mrc_Je_Batch_Id,
         NULL, --AID.Mrc_Posted_Amount,
         NULL, --AID.Mrc_Posted_Base_Amount,
         NULL, --AID.Mrc_Receipt_Conversion_Rate,
         AID.Credit_Card_Trx_Id,
         AID.Dist_Match_Type,
         AID.Rcv_Transaction_Id,
         AID.Invoice_Distribution_Id,
         AID.Parent_Reversal_Id,
         AID.Tax_Recovery_Rate,
         AID.Tax_Recovery_Override_Flag,
         AID.Tax_Recoverable_Flag,
         AID.Tax_Code_Override_Flag,
         AID.Tax_Code_Id,
         AID.Pa_Cc_Ar_Invoice_Id,
         AID.Pa_Cc_Ar_Invoice_Line_Num,
         AID.Pa_Cc_Processed_Code,
         AID.Merchant_Document_Number,
         AID.Merchant_Name,
         AID.Merchant_Reference,
         AID.Merchant_Tax_Reg_Number,
         AID.Merchant_Taxpayer_Id,
         AID.Country_Of_Supply,
         AID.Matched_Uom_Lookup_Code,
         AID.Gms_Burdenable_Raw_Cost,
         AID.Accounting_Event_Id,
         AID.Prepay_Distribution_Id,
         -- Bug 6893055. Calculating the line amount and line base amounts
         SUM(AID.Amount) OVER (PARTITION BY AID.Invoice_ID,
                    NVL(AID.Parent_Reversal_Id, AID.Invoice_Distribution_Id)),
         SUM(AID.Base_Amount) OVER (PARTITION BY AID.Invoice_ID,
                    NVL(AID.Parent_Reversal_Id, AID.Invoice_Distribution_Id)),
         AID.Inventory_Transfer_Status,
         AID.Company_Prepaid_Invoice_Id,
         AID.Cc_Reversal_Flag,
         AID.Prepay_Tax_Parent_Id,
         AID.Awt_Withheld_Amt,
         AID.Invoice_Includes_Prepay_Flag,
         AID.Price_Correct_Inv_Id,
         AID.Price_Correct_Qty,
         AID.Pa_Cmt_Xface_Flag,
         AID.Cancellation_Flag,
         AID.Fully_Paid_Acctd_Flag,
         AID.Root_Distribution_Id,
         AID.Xinv_Parent_Reversal_Id,
         AID.Amount_Variance,
         AID.Base_Amount_Variance,
         AID.Recurring_Payment_Id,
         ZXR.Source_ID New_Tax_Code_ID,         -- Bug 7111010
         NVL(DECODE(AID.Parent_Reversal_ID, NULL, AID.Distribution_Line_Number,
               DECODE(AID1.Parent_Reversal_ID, NULL,
                  DECODE(AID.Reversal_Flag, 'Y', AID1.Distribution_Line_Number,
                         AID.Distribution_Line_Number), AID.Distribution_Line_Number)),
             AID.Distribution_Line_Number) Line_Number,
         DECODE(AID1.Parent_Reversal_ID, NULL,
                DECODE(AID.Parent_Reversal_ID, NULL, 'N',
                  DECODE(AID1.Invoice_Distribution_ID, NULL, 'Y', 'N')), 'Y') Reversal_Parent,
         (CASE
            WHEN AID.Dist_Match_Type IS NOT NULL THEN
                 AID.Dist_Match_Type
            WHEN AID.Dist_Match_Type IS NULL
             AND AID.PO_Distribution_ID IS NULL THEN
                 'NOT_MATCHED'
            WHEN AID.Dist_Match_Type IS NULL
             AND AID.PO_Distribution_ID IS NOT NULL
             AND AID.Price_Correct_Inv_ID IS NOT NULL THEN
                 'PRICE_CORRECTION'
            WHEN AID.Dist_Match_Type IS NULL
             AND AID.Parent_Invoice_ID IS NOT NULL THEN
                 'LINE_CORRECTION'
         END) AS Match_Type,
/*
         DECODE(AID.Line_Type_Lookup_Code, 'TAX',
              DECODE(AID.Parent_Reversal_ID, NULL, ZX_Lines_Summary_S.NEXTVAL,
                DECODE(AID.Reversal_Flag, 'Y', NULL, ZX_Lines_Summary_S.NEXTVAL)),
              NULL) Summary_Tax_Line_ID
*/
         DECODE(AID.Line_Type_Lookup_Code, 'TAX',
           DECODE(AID1.Parent_Reversal_ID, NULL,
             DECODE(AID.Parent_Reversal_ID, NULL, ZX_Lines_Summary_S.Nextval,
               DECODE(AID.Reversal_Flag, 'Y',
                 DECODE(AID1.Invoice_Distribution_ID, NULL, ZX_Lines_Summary_S.Nextval, NULL),
               ZX_Lines_Summary_S.Nextval)),
             ZX_Lines_Summary_S.Nextval),
           NULL) Summary_Tax_Line_ID
  FROM   AP_Invoices_ALL AI,
         AP_Inv_Dists_Source AID,
         AP_Inv_Dists_Source AID1,
	 PO_Distributions_All POD,  -- 9196221
         ZX_Rates_B ZXR
  WHERE  AI.Invoice_ID = AID.Invoice_ID
  AND    AID.Parent_Reversal_ID = AID1.Invoice_Distribution_ID (+)
  AND    AID.Tax_Code_ID = ZXR.Source_ID (+)
  AND    NVL(AID1.Reversal_Flag, 'Y') = 'Y'
  AND    AID.Line_Type_Lookup_Code =
                 NVL(AID1.Line_Type_Lookup_Code, AID.Line_Type_Lookup_Code)
  AND    AID.PO_Distribution_ID = POD.PO_Distribution_ID (+)   -- 9196221
  AND    AI.Rowid BETWEEN p_start_rowid AND p_end_rowid;


  l_debug_info := 'End of Insert_Dist_Line_Info procedure';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;

/*
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        IF g_debug_flag = 'Y' THEN
           AP_Debug_Pkg.Print('Y','SQLAP','AP_DEBUG','ERROR',SQLERRM,
                              'CALLING_SEQUENCE', l_curr_calling_sequence);
        END IF;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
*/

END Insert_Dist_Line_Info;


------------------------------------------------------------------
-- Procedure insert_alloc_info
-- Purpose
-- This procedure INSERT_ALLOC_INFO inserts the allocation info
-- and the corresponding amounts for each item distribution
-- into the temp table
------------------------------------------------------------------
PROCEDURE Insert_Alloc_Info
                (p_start_rowid          IN        ROWID,
                 p_end_rowid            IN        ROWID,
                 p_calling_sequence     IN        VARCHAR2)  IS


l_debug_info                    VARCHAR2(1000);
l_curr_calling_sequence         VARCHAR2(2000);

BEGIN

  -- Update the calling sequence
  --
  l_curr_calling_sequence := 'Insert_Alloc_Info <-'||P_calling_sequence;
  --

  l_debug_info := 'Inserting into AP_TAX_ALLOC_AMOUNT_GT table';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;


  /* Inserting into temp table the distribution amount that
     will be calculated for a tax line */

  INSERT INTO AP_Tax_Alloc_Amount_GT t1
        (Invoice_ID,
         Line_Number,
         Line_Amount,
         Line_Base_Amount,
         Charge_Allocation_ID,
         Item_Charge_Alloc_ID,
         Item_Charge_Alloc_ID2,
         New_Dist_ID,
         Old_Dist_ID,
         Item_Dist_ID,
         Allocated_Amount,
         Allocated_Base_Amount,
         Dist_Count,
         Rank_Num,
         Amount,
         Sum_Amount,
         Base_Amount,
         Sum_Base_Amount,
         IPV_Amount,
         Sum_IPV_Amount,
         IPV_Base_Amount,
         Sum_IPV_Base_Amount,
         ERV_Amount,
         Sum_ERV_Amount,
         Detail_Tax_Dist_ID,
         Set_Of_Books_ID,
	 Org_Item_ID, --8608129
         Parent_reversal_id ) --8608129
  SELECT /*+ swap_join_inputs(FC) */
         Invoice_ID,
         Line_Number,
         Line_Amount,
         Line_Base_Amount,
         Charge_Allocation_ID,
         NVL(Item_Charge_Alloc_ID, -99),
         NVL(Item_Charge_Alloc_ID2, -99),
         DECODE(Charge_Allocation_ID, NULL, Old_Dist_ID,
                     AP_Invoice_Distributions_S.Nextval) New_Dist_ID,
         Old_Dist_ID,
         Item_Dist_ID,
         Allocated_Amount,
         Allocated_Base_Amount,
         COUNT(*) OVER (PARTITION BY Old_Dist_ID) Dist_Count,
         RANK() OVER (PARTITION BY Old_Dist_ID
                      ORDER BY Allocated_Amount, Item_Dist_ID,
                               NVL(Item_Charge_Alloc_ID,1)) Rank_Num,
         DECODE(FC.Minimum_Accountable_Unit, NULL, ROUND(Amount, FC.Precision),
                   ROUND(Amount/FC.Minimum_Accountable_Unit)
                   * FC.Minimum_Accountable_Unit) Amount,
         SUM(DECODE(FC.Minimum_Accountable_Unit, NULL, ROUND(Amount, FC.Precision),
                       ROUND(Amount/FC.Minimum_Accountable_Unit)
                       * FC.Minimum_Accountable_Unit))
             OVER (PARTITION BY Old_Dist_ID) Sum_Amount,
         DECODE(FC.Minimum_Accountable_Unit, NULL, ROUND(Base_Amount, FC.Precision),
                   ROUND(Base_Amount/FC.Minimum_Accountable_Unit)
                   * FC.Minimum_Accountable_Unit) Base_Amount,
         SUM(DECODE(FC.Minimum_Accountable_Unit, NULL, ROUND(Base_Amount, FC.Precision),
                       ROUND(Base_Amount/FC.Minimum_Accountable_Unit)
                       * FC.Minimum_Accountable_Unit))
             OVER (PARTITION BY Old_Dist_ID) Sum_Base_Amount,
         DECODE(FC.Minimum_Accountable_Unit, NULL, ROUND(IPV_Amount, FC.Precision),
                   ROUND(IPV_Amount/FC.Minimum_Accountable_Unit)
                   * FC.Minimum_Accountable_Unit) IPV_Amount,
         SUM(DECODE(FC.Minimum_Accountable_Unit, NULL, ROUND(IPV_Amount, FC.Precision),
                       ROUND(IPV_Amount/FC.Minimum_Accountable_Unit)
                       * FC.Minimum_Accountable_Unit))
             OVER (PARTITION BY Old_Dist_ID) Sum_IPV_Amount,
         DECODE(FC.Minimum_Accountable_Unit, NULL, ROUND(IPV_Base_Amount, FC.Precision),
                   ROUND(IPV_Base_Amount/FC.Minimum_Accountable_Unit)
                   * FC.Minimum_Accountable_Unit) IPV_Base_Amount,
         SUM(DECODE(FC.Minimum_Accountable_Unit, NULL, ROUND(IPV_Base_Amount, FC.Precision),
                       ROUND(IPV_Base_Amount/FC.Minimum_Accountable_Unit)
                       * FC.Minimum_Accountable_Unit))
             OVER (PARTITION BY Old_Dist_ID) Sum_IPV_Base_Amount,
         DECODE(FC.Minimum_Accountable_Unit, NULL, ROUND(ERV_Amount, FC.Precision),
                   ROUND(ERV_Amount/FC.Minimum_Accountable_Unit)
                   * FC.Minimum_Accountable_Unit) ERV_Amount,
         SUM(DECODE(FC.Minimum_Accountable_Unit, NULL, ROUND(ERV_Amount, FC.Precision),
                       ROUND(ERV_Amount/FC.Minimum_Accountable_Unit)
                       * FC.Minimum_Accountable_Unit))
             OVER (PARTITION BY Old_Dist_ID) Sum_ERV_Amount,
         ZX_REC_NREC_DIST_S.Nextval Detail_Tax_Dist_ID,
         Set_Of_Books_ID,
	 org_item_id, --8608129
         parent_reversal_id --8608129
  FROM   FND_Currencies FC,
        (SELECT  /*+ Rowid(AI) NO_MERGE Leading(AI) Use_hash(AID)
                    Use_nl(ACA) Use_hash(AID1) Use_nl(ACA1) use_hash(AID2)
		    NO_EXPAND */            -- bug# 6680833 NO_EXPAND hint added
                AID.Invoice_ID Invoice_ID,
                AID.Line_Number Line_Number,
              /*  DECODE(NVL(AID.Reversal_Flag,'N'), 'N', AID.Amount,
                    DECODE(AID.Reversal_Parent, 'Y', AID.Amount, 0)) Line_Amount,  */
             -- For the Reversed Pair the Line amount is Zero finally the Inv Distributions
             -- in r12 will have zero amounts for the reversed Pair instead of the
             -- original amounts
                AID.Amount Line_Amount, --Bug 6931847
               /* DECODE(NVL(AID.Reversal_Flag,'N'), 'N', AID.Base_Amount,
                    DECODE(AID.Reversal_Parent, 'Y', AID.Base_Amount,
                       DECODE(AID.Base_Amount, NULL, NULL, 0))) Line_Base_Amount, */
		       AID.Base_Amount Line_Base_Amount, --Bug 6931847
                ACA.Charge_Allocation_ID Charge_Allocation_ID,
                ACA1.Charge_Allocation_ID Item_Charge_Alloc_ID,
                    NULL Item_Charge_Alloc_ID2, --Perf 6973846  ACA2.Charge_Allocation_ID
                AID.Invoice_Distribution_ID Old_Dist_ID,
                NVL(ACA.Item_Dist_ID, AID.Invoice_Distribution_ID) Item_Dist_ID,
               (CASE
                  WHEN AID1.Line_Type_Lookup_Code IN ('FREIGHT', 'MISCELLANEOUS') THEN
                       NVL((ACA.Allocated_Amount * ACA1.Allocated_Amount /
                              DECODE(AID1.Amount,0,1,AID1.Amount)), AID.Amount)
                  ELSE NVL(ACA.Allocated_Amount, AID.Amount)
                END) As Allocated_Amount,
               (CASE
                  WHEN AID1.Line_Type_Lookup_Code IN ('FREIGHT', 'MISCELLANEOUS') THEN
                       NVL((ACA.Allocated_Base_Amount * ACA1.Allocated_Base_Amount /
                              DECODE(AID1.Base_Amount,0,1,AID1.Base_Amount)),
                                          AID.Base_Amount)
                  ELSE NVL(ACA.Allocated_Base_Amount, AID.Base_Amount)
                END) As Allocated_Base_Amount,
               (CASE
                  WHEN AID1.Line_Type_Lookup_Code IN ('FREIGHT', 'MISCELLANEOUS') THEN
                       NVL((ACA.Allocated_Amount * ACA1.Allocated_Amount /
                               DECODE(AID1.Amount,0,1,AID1.Amount)), AID.Amount)
                       - (NVL((ACA.Allocated_Amount * ACA1.Allocated_Amount /
                               DECODE(AID1.Amount,0,1,AID1.Amount)), AID.Amount) *
                             NVL(AID.Invoice_Price_Variance,0) / DECODE(AID.Amount, 0, 1, AID.Amount))
                  ELSE NVL(ACA.Allocated_Amount, AID.Amount)
                               - (NVL(ACA.Allocated_Amount, AID.Amount) * NVL(AID.Invoice_Price_Variance,0)
                                     / DECODE(AID.Amount, 0, 1, AID.Amount))
                END) As Amount,
               (CASE
                  WHEN AID1.Line_Type_Lookup_Code IN ('FREIGHT', 'MISCELLANEOUS') THEN
                       NVL((ACA.Allocated_Base_Amount * ACA1.Allocated_Base_Amount /
                                DECODE(AID1.Base_Amount,0,1,AID1.Base_Amount)), AID.Base_Amount)
                       - (NVL((ACA.Allocated_Base_Amount * ACA1.Allocated_Base_Amount /
                                DECODE(AID1.Base_Amount,0,1,AID1.Base_Amount)), AID.Base_Amount)
                       * NVL(AID.Base_Invoice_Price_Variance,0)
                       / DECODE(AID.Base_Amount, 0, 1, AID.Base_Amount))
                       - (NVL((ACA.Allocated_Base_Amount * ACA1.Allocated_Base_Amount /
                               DECODE(AID.Base_Amount,0,1,AID.Base_Amount)), AID.Base_Amount)
                       * NVL(AID.Exchange_Rate_Variance,0)
                       / DECODE(AID.Base_Amount, 0, 1, AID.Base_Amount))
                  ELSE NVL(ACA.Allocated_Base_Amount, AID.Base_Amount)
                       - (NVL(ACA.Allocated_Base_Amount, AID.Base_Amount)
                       * NVL(AID.Base_Invoice_Price_Variance,0)
                       / DECODE(AID.Base_Amount, 0, 1, AID.Base_Amount))
                       - (NVL(ACA.Allocated_Base_Amount, AID.Base_Amount)
                       * NVL(AID.Exchange_Rate_Variance,0)
                       / DECODE(AID.Base_Amount, 0, 1, AID.Base_Amount))
                END) As Base_Amount,
               (CASE
                  WHEN AID1.Line_Type_Lookup_Code IN ('FREIGHT', 'MISCELLANEOUS') THEN
                       NVL((ACA.Allocated_Amount * ACA1.Allocated_Amount /
                                   DECODE(AID1.Amount,0,1,AID1.Amount)), AID.Amount)
                       * NVL(AID.Invoice_Price_Variance,0)
                       / DECODE(AID.Amount, 0, 1, AID.Amount)
                  ELSE NVL(ACA.Allocated_Amount, AID.Amount) * NVL(AID.Invoice_Price_Variance,0)
                       / DECODE(AID.Amount, 0, 1, AID.Amount)
                END) As IPV_Amount,
               (CASE
                  WHEN AID1.Line_Type_Lookup_Code IN ('FREIGHT', 'MISCELLANEOUS') THEN
                       NVL((ACA.Allocated_Base_Amount * ACA1.Allocated_Base_Amount /
                            DECODE(AID1.Base_Amount,0,1,AID1.Base_Amount)),
                                    AID.Base_Amount)
                       * NVL(AID.Base_Invoice_Price_Variance,0)
                       / DECODE(AID.Base_Amount, 0, 1, AID.Base_Amount)
                  ELSE NVL(ACA.Allocated_Base_Amount, AID.Base_Amount)
                       * NVL(AID.Base_Invoice_Price_Variance,0)
                       / DECODE(AID.Base_Amount, 0, 1, AID.Base_Amount)
                END) As IPV_Base_Amount,
               (CASE
                  WHEN AID1.Line_Type_Lookup_Code IN ('FREIGHT', 'MISCELLANEOUS') THEN
                       NVL((ACA.Allocated_Base_Amount * ACA1.Allocated_Base_Amount /
                            DECODE(AID1.Base_Amount,0,1,AID1.Base_Amount)),
                                    AID.Base_Amount)
                       * NVL(AID.Exchange_Rate_Variance,0)
                       / DECODE(AID.Base_Amount, 0, 1, AID.Base_Amount)
                  ELSE NVL(ACA.Allocated_Base_Amount, AID.Base_Amount)
                       * NVL(AID.Exchange_Rate_Variance,0)
                       / DECODE(AID.Base_Amount, 0, 1, AID.Base_Amount)
                END) As ERV_Amount,
                AI.Invoice_Currency_Code Invoice_Currency_Code,
                AI.Set_Of_Books_ID Set_Of_Books_ID,
		nvl(AID2.Parent_Reversal_ID, AID2.Invoice_Distribution_ID) org_item_id,  --8608129
                AID.parent_reversal_id parent_reversal_id --8608129
         FROM   AP_Invoices_All AI,
                AP_Chrg_Allocations_All ACA,
                AP_Dist_Line_GT AID,
                AP_Chrg_Allocations_All ACA1,
                AP_Dist_Line_GT AID1,
		AP_Dist_Line_GT AID2 --8608129
              --  AP_Chrg_Allocations_All ACA2
         WHERE  AI.Invoice_ID = AID.Invoice_ID
         -- AND    AID.Line_Type_Lookup_Code IN ('FREIGHT', 'MISCELLANEOUS', 'TAX')
         AND    AID.Invoice_Distribution_ID = ACA.Charge_Dist_ID (+)
         AND    ACA.Item_Dist_ID = ACA1.Charge_Dist_ID (+)
         AND    ACA1.Charge_Dist_ID = AID1.Invoice_Distribution_ID (+)
         AND    decode(ACA.charge_allocation_id, null, null,ACA.Item_Dist_ID) =
                             		   AID2.Invoice_Distribution_ID (+) --8608129
        -- AND    ACA1.Item_Dist_ID = ACA2.Charge_Dist_ID (+)
         AND    NVL(AID1.Line_Type_Lookup_Code, 'FREIGHT') IN ('FREIGHT', 'MISCELLANEOUS')
         AND    AI.Rowid BETWEEN p_start_rowid AND p_end_rowid) ATEMP
  WHERE  FC.Currency_Code = ATEMP.Invoice_Currency_Code;



  l_debug_info := 'End of Insert_Alloc_Info procedure';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;


/*
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        IF g_debug_flag = 'Y' THEN
           AP_Debug_Pkg.Print('Y','SQLAP','AP_DEBUG','ERROR',SQLERRM,
                              'CALLING_SEQUENCE', l_curr_calling_sequence);
        END IF;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
*/


END Insert_Alloc_Info;



------------------------------------------------------------------
-- Procedure CREATE_LINES
-- Purpose
-- This procedure CREATE_LINES creates lines from the existing
-- 11i distributions.
------------------------------------------------------------------
PROCEDURE Create_Lines
                (p_start_rowid        ROWID,
                 p_end_rowid          ROWID,
                 p_calling_sequence   VARCHAR2)  IS


l_inv_installed                 VARCHAR2(1);
l_industry                      VARCHAR2(10);
l_fnd_return                    BOOLEAN;
l_inv_flag                      VARCHAR2(1);
l_debug_info                    VARCHAR2(1000);
l_curr_calling_sequence         VARCHAR2(2000);

BEGIN

  -- Update the calling sequence
  --
  l_curr_calling_sequence := 'Create_Lines<-'||P_calling_sequence;
  --

  l_debug_info := 'Inside Create_Lines procedure';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;

  l_fnd_return := FND_INSTALLATION.GET(401,401, l_inv_flag, l_industry);

  if (l_inv_flag = 'I') then
      l_inv_installed := 'Y';
  else
      l_inv_installed := 'N';
  end if;


  l_debug_info := 'Creating invoice lines from the distributions table';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;


  /* The following logic will be used to create an invoice line

     We will create one invoice line per invoice distribution and copy the
     distribution_line_number as the invoice_line_number except reversal pairs

     For reversal pairs we will create only one line for the pair and copy the
     distribution_line_number of the parent distribution as the invoice_line_number

     For those reversal distributions that have a reversal parent we will create
     one line per distribution and copy the distribution_line_number as the
     invoice_line_number
  */

  INSERT INTO ap_invoice_lines_all t1
        (INVOICE_ID,
         LINE_NUMBER,
         LINE_TYPE_LOOKUP_CODE,
         REQUESTER_ID,
         DESCRIPTION,
         LINE_SOURCE,
         ORG_ID,
         INVENTORY_ITEM_ID,
         ITEM_DESCRIPTION,
         GENERATE_DISTS,
         MATCH_TYPE,
         DEFAULT_DIST_CCID,
         PRORATE_ACROSS_ALL_ITEMS,
         ACCOUNTING_DATE,
         PERIOD_NAME,
         DEFERRED_ACCTG_FLAG,
         DEF_ACCTG_START_DATE,
         DEF_ACCTG_END_DATE,
         DEF_ACCTG_NUMBER_OF_PERIODS,
         DEF_ACCTG_PERIOD_TYPE,
         SET_OF_BOOKS_ID,
         AMOUNT,
         BASE_AMOUNT,
         QUANTITY_INVOICED,
         UNIT_MEAS_LOOKUP_CODE,
         UNIT_PRICE,
         WFAPPROVAL_STATUS,
         USSGL_TRANSACTION_CODE,
         DISCARDED_FLAG,
         ORIGINAL_AMOUNT,
         ORIGINAL_BASE_AMOUNT,
         CANCELLED_FLAG,
         INCOME_TAX_REGION,
         TYPE_1099,
         STAT_AMOUNT,
         PREPAY_INVOICE_ID,
         PREPAY_LINE_NUMBER,
         INVOICE_INCLUDES_PREPAY_FLAG,
         CORRECTED_INV_ID,
         CORRECTED_LINE_NUMBER,
         PO_HEADER_ID,
         PO_LINE_ID,
         PO_RELEASE_ID,
         PO_LINE_LOCATION_ID,
         PO_DISTRIBUTION_ID,
         RCV_TRANSACTION_ID,
         RCV_SHIPMENT_LINE_ID,
         FINAL_MATCH_FLAG,
         ASSETS_TRACKING_FLAG,
         PROJECT_ID,
         TASK_ID,
         EXPENDITURE_TYPE,
         EXPENDITURE_ITEM_DATE,
         EXPENDITURE_ORGANIZATION_ID,
         PA_QUANTITY,
         PA_CC_AR_INVOICE_ID,
         PA_CC_AR_INVOICE_LINE_NUM,
         PA_CC_PROCESSED_CODE,
         AWARD_ID,
         AWT_GROUP_ID,
         REFERENCE_1,
         REFERENCE_2,
         RECEIPT_VERIFIED_FLAG,
         RECEIPT_REQUIRED_FLAG,
         RECEIPT_MISSING_FLAG,
         JUSTIFICATION,
         EXPENSE_GROUP,
         START_EXPENSE_DATE,
         END_EXPENSE_DATE,
         RECEIPT_CURRENCY_CODE,
         RECEIPT_CONVERSION_RATE,
         RECEIPT_CURRENCY_AMOUNT,
         DAILY_AMOUNT,
         WEB_PARAMETER_ID,
         ADJUSTMENT_REASON,
         MERCHANT_DOCUMENT_NUMBER,
         MERCHANT_NAME,
         MERCHANT_REFERENCE,
         MERCHANT_TAX_REG_NUMBER,
         MERCHANT_TAXPAYER_ID,
         COUNTRY_OF_SUPPLY,
         CREDIT_CARD_TRX_ID,
         COMPANY_PREPAID_INVOICE_ID,
         CC_REVERSAL_FLAG,
         LINE_SELECTED_FOR_APPL_FLAG,
         PREPAY_APPL_REQUEST_ID,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
         REQUEST_ID,
         CONTROL_AMOUNT,
         ASSESSABLE_VALUE,
         TOTAL_REC_TAX_AMOUNT,
         TOTAL_NREC_TAX_AMOUNT,
         TOTAL_REC_TAX_AMT_FUNCL_CURR,
         TOTAL_NREC_TAX_AMT_FUNCL_CURR,
         INCLUDED_TAX_AMOUNT,
         TAX_ALREADY_CALCULATED_FLAG,
         PRIMARY_INTENDED_USE,
         SHIP_TO_LOCATION_ID,
         PRODUCT_TYPE,
         PRODUCT_CATEGORY,
         PRODUCT_FISC_CLASSIFICATION,
         USER_DEFINED_FISC_CLASS,
         TRX_BUSINESS_CATEGORY,
         SUMMARY_TAX_LINE_ID,
         TAX_REGIME_CODE,
         TAX,
         TAX_JURISDICTION_CODE,
         TAX_CLASSIFICATION_CODE,
         TAX_STATUS_CODE,
         TAX_RATE_ID,
         TAX_RATE_CODE,
         TAX_RATE,
         TAX_CODE_ID,
         HISTORICAL_FLAG)
  SELECT /*+ Rowid(AI) ORDERED Use_hash(AI,AID,ZXR) USE_NL(pd,pl,aid1,atc,rct) swap_join_inputs(ZXR) */
         AID.Invoice_ID Invoice_ID,
         AID.Line_Number Line_Number,
         AID.Line_Type_Lookup_Code Line_Type_Lookup_Code,
         DECODE(AID.Line_Type_Lookup_Code, 'ITEM', AI.Requester_ID, NULL) Requester_ID,
         AID.Description Description,
         (CASE
            WHEN AID.Match_Type IN ('ITEM_TO_PO', 'ITEM_TO_RECEIPT') THEN
                 'HEADER MATCH'
            WHEN AID.Match_Type IN ('OTHER_TO_RECEIPT') THEN
                 'CHRG ITEM MATCH'
            WHEN AID.Match_Type IN ('PRICE_CORRECTION', 'LINE_CORRECTION') THEN
                 'HEADER CORRECTION'
            WHEN AID.Line_Type_Lookup_Code IN ('PREPAY') THEN
                 'PREPAY APPL'
            WHEN AID.Line_Type_Lookup_Code IN ('AWT')
             AND AID.Awt_Flag = 'A' THEN
                 'AUTO WITHHOLDING'
            WHEN AID.Line_Type_Lookup_Code IN ('TAX')
             AND nvl(AID.tax_calculated_flag,'N') = 'Y' THEN -- Bug 7154952
                 'ETAX'
            WHEN AID.Line_Type_Lookup_Code IN ('TAX')
             AND nvl(AID.tax_calculated_flag,'N') <> 'Y' THEN -- Bug 7154952
                 'MANUAL LINE ENTRY'
            WHEN AID.Line_Type_Lookup_Code IN ('FREIGHT')
             AND AID.Match_Type IN ('NOT_MATCHED') THEN
                 'HEADER FREIGHT'
            WHEN AI.Source IN ('Manual Invoice Entry') THEN
                 'MANUAL LINE ENTRY'
            WHEN AI.Source IN ('Confirm PaymentBatch', 'Withholding Tax', 'Recurring Invoice') THEN
                 'AUTO INVOICE CREATION'
            ELSE 'IMPORTED'
            END) AS Line_Source,
         AID.Org_ID,
         PL.Item_ID,
         PL.Item_Description,
         'D' Generate_Dists,
         AID.Match_Type Match_Type,
         AID.Dist_Code_Combination_ID,
         NULL Prorate_Across_All_Items,
         AID.Accounting_Date Accounting_Date,
         AID.Period_Name Period_Name,
         'N' Deferred_Acctg_Flag,
         NULL Def_Acctg_Start_Date,
         NULL Def_Acctg_End_Date,
         NULL Def_Acctg_Number_Of_Periods,
         NULL Def_Acctg_Period_Type,
         AID.Set_Of_Books_ID Set_Of_Books_ID,
        (CASE
            WHEN NVL(AID.Reversal_Flag,'N') = 'N' or AID.Reversal_Parent = 'Y'
                 THEN NVL(AID.Amount,0)
            -- Bug 6893055. Copying the already calculated line amount so as to
            -- correctly populate the amounts for dists reversed prior to 11i
            ELSE NVL(AID.Upgrade_Posted_Amt,0)
         END) AS Amount,
        (CASE
            WHEN AI.Invoice_Currency_Code = ASP.Base_Currency_Code
                 THEN NULL
            WHEN NVL(AID.Reversal_Flag,'N') = 'N' or AID.Reversal_Parent = 'Y'
                 THEN AID.Base_Amount
            -- Bug 6893055. Copying the already calculated line base amt so as to
            -- correctly populate the base amts for dists reversed prior to 11i
            ELSE AID.Upgrade_Base_Posted_Amt
         END) AS Base_Amount,
         AID.Quantity_Invoiced Quantity_Invoiced,
         AID.Matched_UOM_Lookup_Code Unit_Meas_Lookup_Code,
         AID.Unit_Price Unit_Price,
         'NOT REQUIRED' Wfapproval_Status,
         AID.USSGL_Transaction_Code USSGL_Transaction_Code,
         DECODE(AID.Reversal_Parent, 'N', AID.Reversal_Flag, 'N') Discarded_Flag,
        (CASE
            WHEN AID.Reversal_Flag = 'N' or AID.Reversal_Parent = 'Y'
                 THEN 0
            ELSE AID.Amount
         END) AS Original_Amount,
        (CASE
            WHEN (AID.Reversal_Flag = 'N' or AID.Reversal_Parent = 'Y')
             AND AI.Invoice_Currency_Code <> ASP.Base_Currency_Code
                 THEN 0
            ELSE AID.Base_Amount
         END) AS Original_Base_Amount,
         NULL Cancelled_Flag,
         AID.Income_Tax_Region Income_Tax_Region,
         AID.Type_1099 Type_1099,
         AID.Stat_Amount Stat_Amount,
         DECODE(AID.Prepay_Distribution_ID, NULL, NULL,
                           AID1.Invoice_ID) Prepay_Invoice_ID,
         DECODE(AID.Prepay_Distribution_ID, NULL, NULL,
                           AID1.Distribution_Line_Number) Prepay_Line_Number,
         AID.Invoice_Includes_Prepay_Flag Invoice_Includes_Prepay_Flag,
         AID.Price_Correct_Inv_ID Corrected_Inv_ID,
         NULL Corrected_Line_Number,
         PD.PO_Header_ID PO_Header_ID,
         PD.PO_Line_ID PO_Line_ID,
         PD.PO_Release_ID PO_Release_ID,
         PD.Line_Location_ID PO_Line_Location_ID,
         AID.PO_Distribution_ID PO_Distribution_ID,
         AID.Rcv_Transaction_ID Rcv_Transacion_ID,
         RCT.SHIPMENT_LINE_ID RCV_SHIPMENT_LINE_ID,
         AID.Final_Match_Flag Final_Match_Flag,
         AID.Assets_Tracking_Flag Assets_Tracking_Flag,
         AID.Project_ID Project_ID,
         AID.Task_ID Task_ID,
         AID.Expenditure_Type Expenditure_Type,
         AID.Expenditure_Item_Date Expenditure_Item_Date,
         AID.Expenditure_Organization_ID Expenditure_Organization_ID,
         AID.PA_Quantity PA_Quantity,
         AID.PA_CC_AR_Invoice_ID PA_CC_AR_Invoice_ID,
         AID.PA_CC_AR_Invoice_Line_Num PA_CC_AR_Invoice_Line_Num,
         AID.PA_CC_Processed_Code PA_CC_Processed_Code,
         AID.Award_ID Award_ID,
         AID.Awt_Group_ID Awt_Group_ID,
         AID.Reference_1 Reference_1,
         AID.Reference_2 Reference_2,
         AID.Receipt_Verified_Flag Receipt_Verified_Flag,
         AID.Receipt_Required_Flag Receipt_Required_Flag,
         AID.Receipt_Missing_Flag Receipt_Missing_Flag,
         AID.Justification Justification,
         AID.Expense_Group Expense_Group,
         AID.Start_Expense_Date Start_Expense_Date,
         AID.End_Expense_Date End_Expense_Date,
         AID.Receipt_Currency_Code Receipt_Currency_Code,
         AID.Receipt_Conversion_Rate Receipt_Conversion_Rate,
         AID.Receipt_Currency_Amount Receipt_Currency_Amount,
         AID.Daily_Amount Daily_Amount,
         AID.Web_Parameter_ID Web_Parameter_ID,
         AID.Adjustment_Reason Adjustment_Reason,
         AID.Merchant_Document_Number Merchant_Document_Number,
         AID.Merchant_Name Merchant_Name,
         AID.Merchant_Reference Merchant_Reference,
         AID.Merchant_Tax_Reg_Number Merchant_Tax_Reg_Number,
         AID.Merchant_Taxpayer_ID Merchant_Taxpayer_ID,
         SUBSTR(AID.Global_Attribute_Category,4,2) Country_Of_Supply,
         AID.Credit_Card_Trx_ID Credit_Card_Trx_ID,
         AID.Company_Prepaid_Invoice_ID Company_Prepaid_Invoice_ID,
         AID.CC_Reversal_Flag CC_Reversal_Flag,
         NULL Line_Selected_For_Appl_Flag,
         NULL Prepay_Appl_Request_ID,
         sysdate Creation_Date,
         1 Created_By,
         1 Last_Updated_By,
         sysdate Last_Update_Date,
         0 Last_Update_Login,
         AID.Program_Application_ID Program_Application_ID,
         AID.Program_ID Program_ID,
         AID.Program_Update_Date Program_Update_Date,
         AID.Request_ID Request_ID,
         NULL Control_Amount,
         (CASE
               WHEN AID.global_attribute_category = 'JE.IT.APXINWKB.DISTRIBUTIONS' THEN
                    AID.global_attribute1
               WHEN AID.global_attribute_category = 'JE.IT.APXIISIM.DISTRIBUTIONS' THEN
                    AID.global_attribute1
         END) AS Accessable_Value,
         NULL Total_Rec_Tax_Amount,
         NULL Total_NRec_Tax_Amount,
         NULL Total_Rec_Tax_Amt_Funcl_Curr,
         NULL Total_NRec_Tax_Amt_Funcl_Curr,
         NULL Included_Tax_Amount,
         'Y' Tax_Already_Calculated_Flag,
         (CASE
               WHEN AI.global_attribute_category = 'JL.AR.APXINWKB.INVOICES ' THEN
                    AI.global_attribute10
               WHEN AI.global_attribute_category = 'JL.AR.APXIISIM.INVOICES_FOLDER' THEN
                    AI.global_attribute10
         END) AS Primary_Intended_Use,
         (CASE
               WHEN AI.global_attribute_category = 'JL.AR.APXINWKB.INVOICES'
               AND  AID.global_attribute3 IS NULL THEN
                    AI.global_attribute18
               WHEN AI.global_attribute_category = 'JL.CO.APXINWKB.INVOICES'
               AND  AID.global_attribute3 IS NULL THEN
                    AI.global_attribute18
               WHEN AID.global_attribute_category = 'JL.AR.APXINWKB.DISTRIBUTIONS' THEN
                    AID.global_attribute3
               WHEN AID.global_attribute_category = 'JL.CO.APXINWKB.DISTRIBUTIONS' THEN
                    AID.global_attribute3
         END) AS Ship_To_Location_ID,
         NULL Product_Type,
         (CASE
               WHEN AID.global_attribute_category = 'JA.TW.APXINWKB.INVOICES'
                    AND  l_inv_installed = 'N' THEN
                    DECODE(AID.global_attribute2, 'Y', 'WINE CIGARRETE',
                                                  'N', NULL)
               WHEN AID.global_attribute_category = 'JE.HU.APXINWKB.STAT_CODE'
                    AND  l_inv_installed = 'N' THEN
                    AID.global_attribute6
               WHEN AID.global_attribute_category = 'JE.PL.APXINWKB.STAT_CODE'
                    AND  l_inv_installed = 'N' THEN
                    AID.global_attribute1
               WHEN AID.global_attribute_category = 'JA.TW.APXIISIM.INVOICES_FOLDER'
                    AND  l_inv_installed = 'N' THEN
                    DECODE(AID.global_attribute2, 'Y', 'WINE CIGARRETE',
                                                  'N', NULL)
               WHEN AID.global_attribute_category = 'JE.HU.APXIISIM.STAT_CODE'
                    AND  l_inv_installed = 'N' THEN
                    AID.global_attribute5
               WHEN AID.global_attribute_category = 'JE.PL.APXIISIM.STAT_CODE'
                    AND  l_inv_installed = 'N' THEN
                    AID.global_attribute1
         END) AS Product_Category,
         (CASE
               WHEN AID.global_attribute_category = 'JA.TW.APXINWKB.INVOICES'
                    AND  l_inv_installed = 'Y' THEN
                    DECODE(AID.global_attribute2, 'Y', 'WINE CIGARRETE',
                                                  'N', NULL)
               WHEN AID.global_attribute_category = 'JE.HU.APXINWKB.STAT_CODE'
                    AND  l_inv_installed = 'Y' THEN
                    AID.global_attribute6
               WHEN AID.global_attribute_category = 'JE.PL.APXINWKB.STAT_CODE'
                    AND  l_inv_installed = 'Y' THEN
                    AID.global_attribute1
               WHEN AID.global_attribute_category = 'JA.TW.APXIISIM.INVOICES_FOLDER'
                    AND  l_inv_installed = 'N' THEN
                    DECODE(AID.global_attribute2, 'Y', 'WINE CIGARRETE',
                                                  'N', NULL)
               WHEN AID.global_attribute_category = 'JE.HU.APXIISIM.STAT_CODE'
                    AND  l_inv_installed = 'N' THEN
                    AID.global_attribute5
         END) AS Product_Fisc_Classification,
         (CASE
               WHEN AID.global_attribute_category = 'JL.BR.APXINWKB.D_SUM_FOLDER' THEN
                    AID.global_attribute1
               WHEN AID.global_attribute_category = 'JL.BR.APXIISIM.LINES_FOLDER' THEN
                    AID.global_attribute1
               WHEN AID.global_attribute_category = 'JE.ES.APXINWKB.MODELO347' THEN
                    nvl(AI.global_attribute8,'MOD340NONE')
               WHEN AID.global_attribute_category = 'JE.ES.APXINWKB.MODELO347PR' THEN
                    nvl(AI.global_attribute8,'MOD340NONE')
               WHEN AID.global_attribute_category = 'JE.ES.APXINWKB.MODELO415' THEN
                    nvl(AI.global_attribute8,'MOD340NONE')
               WHEN AID.global_attribute_category = 'JE.ES.APXINWKB.MODELO415_347' THEN
                    nvl(AI.global_attribute8,'MOD340NONE')
               WHEN AID.global_attribute_category = 'JE.ES.APXINWKB.MODELO415_347PR' THEN
                    nvl(AI.global_attribute8,'MOD340NONE')
               WHEN AID.global_attribute_category = 'JE.ES.APXINWKB.MODELO349' THEN
                    nvl(AI.global_attribute8,'MOD340NONE')
               WHEN AID.global_attribute_category = 'JE.ES.APXINWKB.MODELO340' THEN
                    nvl(AI.global_attribute8,'MOD340NONE')

         END) AS User_Defined_Fisc_Class,
         (CASE
               WHEN AI.global_attribute_category = 'JE.ES.APXINWKB.MODELO347' THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'INVOICE TYPE/'||'MOD347/'||nvl(AI.GLOBAL_ATTRIBUTE11,'A')
               WHEN AI.global_attribute_category = 'JE.ES.APXINWKB.MODELO347PR' THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'INVOICE TYPE/'||'MOD347PR/'||nvl(AI.GLOBAL_ATTRIBUTE11,'A')
               WHEN AI.global_attribute_category = 'JE.ES.APXINWKB.MODELO349' THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'INVOICE TYPE/'||'MOD349'
               WHEN AI.global_attribute_category = 'JE.ES.APXINWKB.MODELO415' THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'INVOICE TYPE/'||'MOD415/'||nvl(AI.GLOBAL_ATTRIBUTE11,'A')
               WHEN AI.global_attribute_category = 'JE.ES.APXINWKB.MODELO415_347' THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'INVOICE TYPE/'||'MOD415_347/'||nvl(AI.GLOBAL_ATTRIBUTE11,'A')
               WHEN AI.global_attribute_category = 'JE.ES.APXINWKB.MODELO415_347PR' THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'INVOICE TYPE/'||'MOD415_347PR/'||nvl(AI.GLOBAL_ATTRIBUTE11,'A')
               WHEN AI.global_attribute_category = 'JE.ES.APXINWKB.MODELO340' THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'INVOICE TYPE/'||'MOD340/'||nvl(AI.GLOBAL_ATTRIBUTE8,'A')
               WHEN AI.global_attribute_category = 'JE.ES.APXINWKB.OTHER' THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'INVOICE TYPE/'||'OTH'
               WHEN AI.global_attribute_category = 'JA.TW.APXINWKB.INVOICES' THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'DEDUCTIBLE TYPE/' ||
                    AI.GLOBAL_ATTRIBUTE3
               WHEN AI.global_attribute_category = 'JE.ES.APXIISIM.MODELO347' THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'INVOICE TYPE/'||'MOD347'
               WHEN AI.global_attribute_category = 'JE.ES.APXIISIM.MODELO347PR' THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'INVOICE TYPE/'||'MOD347PR'
               WHEN AI.global_attribute_category = 'JE.ES.APXIISIM.MODELO349' THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'INVOICE TYPE/'||'MOD349'
               WHEN AI.global_attribute_category = 'JE.ES.APXIISIM.OTHER' THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'INVOICE TYPE/'||'OTH'
               WHEN AI.global_attribute_category = 'JA.TW.APXIISIM.INVOICES_FOLDER' THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'DEDUCTIBLE TYPE/' ||
                    AI.GLOBAL_ATTRIBUTE3
               WHEN AI.global_attribute_category  = 'JL.BR.APXINWKB.AP_INVOICES' AND
                    AID.global_attribute1 IS NULL THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'OPERATION FISCAL CODE/' ||
                    AI.GLOBAL_ATTRIBUTE2
               WHEN AID.global_attribute_category  = 'JL.BR.APXINWKB.D_SUM_FOLDER' THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'OPERATION FISCAL CODE/'||
                    AID.GLOBAL_ATTRIBUTE1
               WHEN AI.global_attribute_category  = 'JL.BR.APXIISIM.INVOICES_FOLDER' AND
                    AID.global_attribute1 is NULL THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'OPERATION FISCAL CODE/'||
                    AI.GLOBAL_ATTRIBUTE2
               WHEN AID.global_attribute_category  = 'JL.BR.APXIISIM.LINES_FOLDER' THEN
                    decode(ai.invoice_type_lookup_code,
                           'EXPENSE REPORT','EXPENSE_REPORT/',
                           'PREPAYMENT','PURCHASE_PREPAYMENTTRANSACTION/',
                           'PURCHASE_TRANSACTION/') || 'OPERATION FISCAL CODE/'||
                    AID.GLOBAL_ATTRIBUTE1
         END) AS Trx_Business_Category,
         AID.Summary_Tax_Line_ID Summary_Tax_Line_ID,
         DECODE(AID.Line_Type_Lookup_Code, 'TAX',
                       ZXR.Tax_Regime_Code, NULL) Tax_Regime_Code,
         DECODE(AID.Line_Type_Lookup_Code, 'TAX',
                       ZXR.Tax, NULL) Tax,
         DECODE(AID.Line_Type_Lookup_Code, 'TAX',
                       ZXR.Tax_Jurisdiction_Code, NULL) Tax_Jurisdiction_Code,
         DECODE(AID.Line_Type_Lookup_Code, 'TAX', ATC.Name,
                     NULL) Tax_Classification_Code,
         DECODE(AID.Line_Type_Lookup_Code, 'TAX',
                       ZXR.Tax_Status_Code, NULL) Tax_Status_Code,
         DECODE(AID.Line_Type_Lookup_Code, 'TAX',
                       ZXR.Tax_Rate_ID, NULL) Tax_Rate_ID,
         DECODE(AID.Line_Type_Lookup_Code, 'TAX',
                       ZXR.Tax_Rate_Code, NULL) Tax_Rate_Code,
         DECODE(AID.Line_Type_Lookup_Code, 'TAX',
                       ZXR.Percentage_Rate, NULL) Tax_Rate,
         ZXR.Source_ID Tax_Code_ID,                      --Bug 7111010
         'Y'
  FROM   AP_System_Parameters_All ASP,
         AP_Invoices_All AI,
         AP_Dist_Line_GT AID,
	 RCV_Transactions  RCT, -- bug 6896361 added to get rcv_shipment_line_id from this table
         PO_Distributions_All PD,
         PO_Lines_All PL,
         AP_Inv_Dists_Source AID1,
         AP_Tax_Codes_All ATC,
         ZX_Rates_B ZXR
  WHERE  AI.Invoice_ID = AID.Invoice_ID
  AND    NVL(AI.Org_ID,-99) = NVL(ASP.Org_ID,-99)
  AND  ((NVL(AID.Reversal_Flag,'N') = 'N')
  OR    (AID.Reversal_Flag = 'Y' AND AID.Parent_Reversal_ID IS NULL)
  OR    (AID.Reversal_Flag = 'Y' AND AID.Reversal_Parent = 'Y'))
  AND    AID.PO_Distribution_ID = PD.PO_Distribution_ID (+)
  AND    PD.PO_Line_ID = PL.PO_Line_ID (+)
  AND    AID.Tax_Code_ID = ATC.Tax_ID (+)
  AND    AID.Tax_Code_ID = ZXR.Source_ID (+)
  AND    AID.Prepay_Distribution_ID = AID1.Invoice_Distribution_ID (+)
  AND    AID.RCV_TRANSACTION_ID = RCT.Transaction_id(+)-- added for bug 6896361
  AND    AI.Rowid BETWEEN p_start_rowid and p_end_rowid;


  l_debug_info := 'End of Create_Lines procedure';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;

/*
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        IF g_debug_flag = 'Y' THEN
           AP_Debug_Pkg.Print('Y','SQLAP','AP_DEBUG','ERROR',SQLERRM,
                              'CALLING_SEQUENCE', l_curr_calling_sequence);
        END IF;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
*/

END Create_Lines;


------------------------------------------------------------------
-- Procedure TRANSFORM_DISTRIBUTIONS
-- Purpose
-- This procedure TRANSFORM_DISTRIBUTIONS inserts the new distributions
-- into the ap_inv_dists_target table from the existing 11i distributions.
------------------------------------------------------------------
PROCEDURE Transform_Distributions
                (p_start_rowid        ROWID,
                 p_end_rowid          ROWID,
                 p_calling_sequence   VARCHAR2)  IS

  l_debug_info                VARCHAR2(1000);
  l_curr_calling_sequence     VARCHAR2(2000);


BEGIN


  l_curr_calling_sequence := 'AP_LINES_UPGRADE_PKG.Transform_Distributions<-'
                                       || p_calling_sequence;

  l_debug_info := 'Inside Transform_Distributions procedure';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;


  l_debug_info := 'Creating ITEM, PREPAY, AWT, ERV and IPV type of distributions';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;


  /* This insert statement will insert all the ITEM, PREPAY
     and AWT type of distributions based on the data from the
     ap_invoice_distributions table of 11i. */

  INSERT INTO ap_inv_dists_target t1
        (BATCH_ID,
         INVOICE_ID,
         INVOICE_LINE_NUMBER,
         INVOICE_DISTRIBUTION_ID,
         DISTRIBUTION_LINE_NUMBER,
         LINE_TYPE_LOOKUP_CODE,
         DESCRIPTION,
         DIST_MATCH_TYPE,
         ORG_ID,
         DIST_CODE_COMBINATION_ID,
         ACCOUNTING_DATE,
         PERIOD_NAME,
         ACCRUAL_POSTED_FLAG,
         CASH_POSTED_FLAG,
         AMOUNT_TO_POST,
         BASE_AMOUNT_TO_POST,
         POSTED_FLAG,
         ACCOUNTING_EVENT_ID,
         SET_OF_BOOKS_ID,
         AMOUNT,
         BASE_AMOUNT,
         EXCHANGE_DATE,
         QUANTITY_VARIANCE,
         BASE_QUANTITY_VARIANCE,
         MATCH_STATUS_FLAG,
         ENCUMBERED_FLAG,
         PACKET_ID,
         USSGL_TRANSACTION_CODE,
         USSGL_TRX_CODE_CONTEXT,
         REVERSAL_FLAG,
         PARENT_REVERSAL_ID,
         CANCELLED_FLAG,
         INCOME_TAX_REGION,
         TYPE_1099,
         STAT_AMOUNT,
         CHARGE_APPLICABLE_TO_DIST_ID,
         PREPAY_AMOUNT_REMAINING,
         PREPAY_DISTRIBUTION_ID,
         PARENT_INVOICE_ID,
         CORRECTED_QUANTITY,
         PO_DISTRIBUTION_ID,
         RCV_TRANSACTION_ID,
         UNIT_PRICE,
         MATCHED_UOM_LOOKUP_CODE,
         QUANTITY_INVOICED,
         FINAL_MATCH_FLAG,
         RELATED_ID,
         ASSETS_ADDITION_FLAG,
         ASSETS_TRACKING_FLAG,
         PROJECT_ID,
         TASK_ID,
         EXPENDITURE_TYPE,
         EXPENDITURE_ITEM_DATE,
         EXPENDITURE_ORGANIZATION_ID,
         PA_QUANTITY,
         PA_ADDITION_FLAG,
         AWARD_ID,
         GMS_BURDENABLE_RAW_COST,
         AWT_FLAG,
         AWT_GROUP_ID,
         AWT_TAX_RATE_ID,
         AWT_GROSS_AMOUNT,
         AWT_INVOICE_ID,
         AWT_ORIGIN_GROUP_ID,
         AWT_INVOICE_PAYMENT_ID,
         AWT_WITHHELD_AMT,
         INVENTORY_TRANSFER_STATUS,
         REFERENCE_1,
         REFERENCE_2,
         RECEIPT_VERIFIED_FLAG,
         RECEIPT_REQUIRED_FLAG,
         RECEIPT_MISSING_FLAG,
         JUSTIFICATION,
         EXPENSE_GROUP,
         START_EXPENSE_DATE,
         END_EXPENSE_DATE,
         RECEIPT_CURRENCY_CODE,
         RECEIPT_CONVERSION_RATE,
         RECEIPT_CURRENCY_AMOUNT,
         DAILY_AMOUNT,
         WEB_PARAMETER_ID,
         ADJUSTMENT_REASON,
         MERCHANT_DOCUMENT_NUMBER,
         MERCHANT_NAME,
         MERCHANT_REFERENCE,
         MERCHANT_TAX_REG_NUMBER,
         MERCHANT_TAXPAYER_ID,
         COUNTRY_OF_SUPPLY,
         CREDIT_CARD_TRX_ID,
         COMPANY_PREPAID_INVOICE_ID,
         CC_REVERSAL_FLAG,
         DETAIL_TAX_DIST_ID,
         RECOVERY_TYPE_CODE,
         RECOVERY_RATE_NAME,
         REC_NREC_RATE,
         TAX_RECOVERABLE_FLAG,
         TAXABLE_AMOUNT,
         TAXABLE_BASE_AMOUNT,
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
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
         REQUEST_ID,
         OLD_DISTRIBUTION_ID,
         OLD_DIST_LINE_NUMBER,
         DISTRIBUTION_CLASS,
         TOTAL_DIST_AMOUNT,
         TOTAL_DIST_BASE_AMOUNT,
         WITHHOLDING_TAX_CODE_ID,
         TAX_CODE_ID,
         TAX_ALREADY_DISTRIBUTED_FLAG,
         INTENDED_USE,
         HISTORICAL_FLAG,
         RCV_CHARGE_ADDITION_FLAG)
  --bug6655754.commented the following hint and added the one below
  --SELECT /*+ ordered Rowid(AI)  cardinality(ai 10) use_nl(ai aid aca) swap_join_inputs(line) full(line) use_hash(line) */
    SELECT /*+ ordered rowid(AI) use_hash(AID,ACA) no_expand */
         AID.Batch_ID Batch_ID,
         AID.Invoice_ID Invoice_ID,
         AID.Line_Number Invoice_Line_Number,
        (CASE
            WHEN Line.Line_Type IN ('IPV','ERV') THEN
                 AP_Invoice_Distributions_S.NEXTVAL
            ELSE DECODE(ACA.Charge_Allocation_ID, NULL, AID.Invoice_Distribution_ID,
                             NVL(ACA.New_Dist_ID, AP_Invoice_Distributions_S.NEXTVAL))
         END) AS Invoice_Distribution_ID,
         -- AP_Dist_Line_Num_Upg_S.NEXTVAL Distribution_Line_Number,
         RANK() OVER (PARTITION BY AID.INVOICE_ID, AID.LINE_NUMBER
                      ORDER BY NVL(ACA.Charge_Allocation_ID, AID.INVOICE_DISTRIBUTION_ID),
                               NVL(ACA.Item_Charge_Alloc_ID, AID.Invoice_Distribution_ID),
                               NVL(ACA.New_Dist_ID, AID.Invoice_Distribution_ID), LINE.LINE_TYPE)
            Distribution_Line_Number,
        (CASE
            WHEN AID.Line_Type_Lookup_Code IN ('FREIGHT', 'MISCELLANEOUS') THEN
                 AID.Line_Type_Lookup_Code
            WHEN Line.Line_Type IN ('IPV', 'ERV') THEN
                 Line.Line_Type
            ELSE AID.Line_Type_Lookup_Code
         END) AS Line_Type_Lookup_Code,
         AID.Description Description,
         DECODE(AID.Match_Type, 'LINE_CORRECTION', 'DIST_CORRECTION',
                                 AID.Match_Type) Dist_Match_Type,
         AID.Org_ID Org_ID,
         DECODE(Line.Line_Type, 'IPV', NVL(AID.Price_Var_Code_Combination_ID,AID.Dist_Code_Combination_ID),
                'ERV', NVL(AID.Rate_Var_Code_Combination_ID,AID.Dist_Code_Combination_ID),
                AID.Dist_Code_Combination_ID) Dist_Code_Combination_ID,
         AID.Accounting_Date Accounting_Date,
         AID.Period_Name Period_Name,
         AID.Accrual_Posted_Flag Accrual_Posted_Flag,
         AID.Cash_Posted_Flag Cash_Posted_Flag,
         AID.Amount_To_Post Amount_To_Post,
         AID.Base_Amount_To_Post Base_Amount_To_Post,
         AID.Posted_Flag Posted_Flag,
         AID.Accounting_Event_ID Accounting_Event_ID,
         AID.Set_Of_Books_ID Set_Of_Books_ID,
        (CASE
            WHEN ACA.Charge_Allocation_ID IS NULL THEN
                 DECODE(Line.Line_Type, 'ITEM', AID.Amount - NVL(AID.Invoice_Price_Variance,0),
                     'IPV', AID.Invoice_Price_Variance, 'ERV', 0)
            ELSE
              DECODE(Line.Line_Type, 'ITEM',
                  DECODE(ACA.Rank_Num, ACA.Dist_Count,
                      ACA.Amount - ACA.Sum_Amount
                        - DECODE(AID.Reversal_Flag, 'Y', 0, NVL(AID.Invoice_Price_Variance,0))
                        + ACA.Line_Amount, ACA.Amount),
                  'IPV', DECODE(ACA.Rank_Num, ACA.Dist_Count,
                        ACA.IPV_Amount - ACA.Sum_IPV_Amount
                          + DECODE(AID.Reversal_Flag, 'Y', 0, NVL(AID.Invoice_Price_Variance,0)),
                        ACA.IPV_Amount),
                  0)
         END) AS Amount,
        (CASE
            WHEN ACA.Charge_Allocation_ID IS NULL THEN
                 DECODE(Line.Line_Type, 'ITEM', AID.Base_Amount
                           - NVL(AID.Base_Invoice_Price_Variance,0)
                           - NVL(AID.Exchange_Rate_Variance,0),
                  'IPV', DECODE(AID.Base_Amount, NULL, NULL, AID.Base_Invoice_Price_Variance),
                  'ERV', AID.Exchange_Rate_Variance)
            ELSE DECODE(Line.Line_Type, 'ITEM',
                   DECODE(ACA.Rank_Num, ACA.Dist_Count,
                         ACA.Base_Amount - ACA.Sum_Base_Amount -
                           DECODE(AID.Base_Amount, NULL, 0,
                              DECODE(AID.Reversal_Flag, 'Y', 0, NVL(AID.Base_Invoice_Price_Variance,0)))
                           - DECODE(AID.Reversal_Flag, 'Y', 0, NVL(AID.Exchange_Rate_Variance,0))
                           + ACA.Line_Base_Amount,
                         ACA.Base_Amount),
                   'IPV', DECODE(ACA.Rank_Num, ACA.Dist_Count,
                         ACA.IPV_Base_Amount - ACA.Sum_IPV_Base_Amount
                             + DECODE(AID.Reversal_Flag, 'Y', 0,
                                 DECODE(AID.Base_Amount, NULL, 0, AID.Base_Invoice_Price_Variance)),
                         ACA.IPV_Base_Amount),
                   DECODE(ACA.Rank_Num, ACA.Dist_Count,
                         ACA.ERV_Amount - ACA.Sum_ERV_Amount +
                             DECODE(AID.Reversal_Flag, 'Y', 0, AID.Exchange_Rate_Variance),
                         ACA.ERV_Amount))
         END) AS Base_Amount,
         AID.Exchange_Date Exchange_Date,
         DECODE(Line.Line_Type, 'ITEM', AID.Quantity_Variance, NULL) Quantity_Variance,
         DECODE(Line.Line_Type, 'ITEM', AID.Base_Quantity_Variance, NULL) Base_Quantity_Variance,
         AID.Match_Status_Flag Match_Status_Flag,
         AID.Encumbered_Flag Encumbered_Flag,
         AID.Packet_ID Packet_ID,
         AID.USSGL_Transaction_Code USSGL_Transaction_Code,
         AID.USSGL_Trx_Code_Context USSGL_Trx_Code_Context,
         AID.Reversal_Flag Reversal_Flag,
	 /* bug 9067770 - nullified parent reversal id
	    for IPV and ERV columns to avoid duplicate reversal ids for thse
	    line type after upgrade */
         DECODE(Line.Line_Type, 'IPV', NULL,
	                        'ERV', NULL,
				AID.Parent_Reversal_ID) Parent_Reversal_ID,
         AID.Cancellation_Flag Cancelled_Flag,
         AID.Income_Tax_Region Income_Tax_Region,
         AID.Type_1099 Type_1099,
         AID.Stat_Amount Stat_Amount,
         DECODE(ACA.Charge_Allocation_ID, NULL, NULL, ACA.Item_Dist_ID) Charge_Applicable_To_Dist_ID,
         DECODE(Line.Line_Type, 'ITEM', AID.Prepay_Amount_Remaining, NULL) Prepay_Amount_Remaining,
         DECODE(Line.Line_Type, 'ITEM', AID.Prepay_Distribution_ID, NULL) Prepay_Distribution_ID,
         AID.Parent_Invoice_ID Parent_Invoice_ID,
         DECODE(Line.Line_Type, 'ITEM', AID.Price_Correct_Qty, NULL) Corrected_Quantity,
         AID.PO_Distribution_ID PO_Distribution_ID,
         AID.RCV_Transaction_ID RCV_Transaction_ID,
         AID.Unit_Price Unit_Price,
         AID.Matched_UOM_Lookup_Code Matched_UOM_Lookup_Code,
         DECODE(Line.Line_Type, 'ITEM', AID.Quantity_Invoiced, NULL) Quantity_Invoiced,
         AID.Final_Match_Flag Final_Match_Flag,
         NVL(ACA.New_Dist_ID, AID.Invoice_Distribution_ID) Related_ID,
         AID.Assets_Addition_Flag Assets_Addition_Flag,
         AID.Assets_Tracking_Flag Assets_Tracking_Flag,
         AID.Project_ID Project_ID,
         AID.Task_ID Task_ID,
         AID.Expenditure_Type Expenditure_Type,
         AID.Expenditure_Item_Date Expenditure_Item_Date,
         AID.Expenditure_Organization_ID Expenditure_Organization_ID,
         AID.PA_Quantity PA_Quantity,
         AID.PA_Addition_Flag PA_Addition_Flag,
         AID.Award_ID Award_ID,
         AID.GMS_Burdenable_Raw_Cost GMS_Burdenable_Raw_Cost,
         AID.Awt_Flag,                      --9366024
         AID.Awt_Group_ID,                  --9366024
         AID.Awt_Tax_Rate_ID,               --9366024
         DECODE(Line.Line_Type, 'ITEM', AID.Awt_Gross_Amount, NULL) Awt_Gross_Amount,
         AID.Awt_Invoice_ID,                --9366024
         AID.Awt_Origin_Group_ID,           --9366024
         AID.Awt_Invoice_Payment_ID,        --9366024
         DECODE(Line.Line_Type, 'ITEM', AID.Awt_Withheld_Amt, NULL) Awt_Withheld_Amt,
         AID.Inventory_Transfer_Status Inventory_Transfer_Status,
         AID.Reference_1 Reference_1,
         AID.Reference_2 Reference_2,
         AID.Receipt_Verified_Flag Receipt_Verified_Flag,
         AID.Receipt_Required_Flag Receipt_Required_Flag,
         AID.Receipt_Missing_Flag Receipt_Missing_Flag,
         AID.Justification Justification,
         AID.Expense_Group Expense_Group,
         AID.Start_Expense_Date Start_Expense_Date,
         AID.End_Expense_Date End_Expense_Date,
         AID.Receipt_Currency_Code Receipt_Currency_Code,
         AID.Receipt_Conversion_Rate Receipt_Conversion_Rate,
         AID.Receipt_Currency_Amount Receipt_Currency_Amount,
         AID.Daily_Amount Daily_Amount,
         AID.Web_Parameter_ID Web_Parameter_ID,
         AID.Adjustment_Reason Adjustment_Reason,
         AID.Merchant_Document_Number Merchant_Document_Number,
         AID.Merchant_Name Merchant_Name,
         AID.Merchant_Reference Merchant_Reference,
         AID.Merchant_Tax_Reg_Number Merchant_Tax_Reg_Number,
         AID.Merchant_Taxpayer_ID Merchant_Taxpayer_ID,
         AID.Country_Of_Supply Country_Of_Supply,
         AID.Credit_Card_Trx_ID Credit_Card_Trx_ID,
         AID.Company_Prepaid_Invoice_ID Company_Prepaid_Invoice_ID,
         AID.CC_Reversal_Flag CC_Reversal_Flag,
         NULL Detail_Tax_Dist_ID,
         NULL Recovery_Type_Code,
         NULL Recovery_Rate_Name,
         NULL Rec_NRec_Rate,
         AID.Tax_Recoverable_Flag Tax_Recoverable_Flag,
         NULL Taxable_Amount,
         NULL Taxable_Base_Amount,
         AID.Attribute_Category Attribute_Category,
         AID.Attribute1 Attribute1,
         AID.Attribute2 Attribute2,
         AID.Attribute3 Attribute3,
         AID.Attribute4 Attribute4,
         AID.Attribute5 Attribute5,
         AID.Attribute6 Attribute6,
         AID.Attribute7 Attribute7,
         AID.Attribute8 Attribute8,
         AID.Attribute9 Attribute9,
         AID.Attribute10 Attribute10,
         AID.Attribute11 Attribute11,
         AID.Attribute12 Attribute12,
         AID.Attribute13 Attribute13,
         AID.Attribute14 Attribute14,
         AID.Attribute15 Attribute15,
         AID.Global_Attribute_Category Global_Attribute_Category,
         AID.Global_Attribute1 Global_Attribute1,
         AID.Global_Attribute2 Global_Attribute2,
         AID.Global_Attribute3 Global_Attribute3,
         AID.Global_Attribute4 Global_Attribute4,
         AID.Global_Attribute5 Global_Attribute5,
         AID.Global_Attribute6 Global_Attribute6,
         AID.Global_Attribute7 Global_Attribute7,
         AID.Global_Attribute8 Global_Attribute8,
         AID.Global_Attribute9 Global_Attribute9,
         AID.Global_Attribute10 Global_Attribute10,
         AID.Global_Attribute11 Global_Attribute11,
         AID.Global_Attribute12 Global_Attribute12,
         AID.Global_Attribute13 Global_Attribute13,
         AID.Global_Attribute14 Global_Attribute14,
         AID.Global_Attribute15 Global_Attribute15,
         AID.Global_Attribute16 Global_Attribute16,
         AID.Global_Attribute17 Global_Attribute17,
         AID.Global_Attribute18 Global_Attribute18,
         AID.Global_Attribute19 Global_Attribute19,
         AID.Global_Attribute20 Global_Attribute20,
         AID.Created_By Created_By,
         AID.Creation_Date Creation_Date,
         AID.Last_Updated_By Last_Updated_By,
         AID.Last_Update_Date Last_Update_Date,
         AID.Last_Update_Login Last_Update_Login,
         AID.Program_Application_ID Program_Application_ID,
         AID.Program_ID Program_ID,
         AID.Program_Update_Date Program_Update_Date,
         AID.Request_ID Request_ID,
         AID.Invoice_Distribution_ID Old_Distribution_ID,
         AID.Distribution_Line_Number Old_Dist_Line_Number,
         'PERMANENT' Distribution_Class,
         DECODE(Line.Line_Type, 'ITEM', NVL(ACA.Allocated_Amount,AID.Amount),
                                        NULL) Total_Dist_Amount,
         DECODE(Line.Line_Type, 'ITEM',
                DECODE(AID.Base_Amount, NULL, NULL,
                        NVL(ACA.Allocated_Base_Amount,AID.Base_Amount))) Total_Dist_Base_Amount,
         DECODE(AID.Line_Type_Lookup_Code, 'AWT', AID.Tax_Code_ID, NULL) Withholding_Tax_Code_ID,
         AID.New_Tax_Code_ID Tax_Code_ID,
         'Y' Tax_Already_Distributed_Flag,
         (CASE
               WHEN AI.global_attribute_category = 'JL.AR.APXINWKB.INVOICES ' THEN
                    AI.global_attribute10
               WHEN AI.global_attribute_category = 'JL.AR.APXIISIM.INVOICES_FOLDER' THEN
                    AI.global_attribute10
         END) AS Intended_Use,
         'Y' Historical_Flag,
         'N' RCV_Charge_Addition_Flag
  FROM   AP_Invoices_ALL AI,
         AP_Dist_Line_GT AID,
         AP_Tax_Alloc_Amount_GT ACA,
         AP_Line_Temp_GT Line
  WHERE  AI.Invoice_ID = AID.Invoice_ID
  AND    AID.Line_Type_Lookup_Code IN ('ITEM', 'PREPAY', 'AWT', 'ICMS',
                                       'IPI', 'FREIGHT', 'MISCELLANEOUS')
  AND    AID.Invoice_Distribution_ID = ACA.Old_Dist_ID (+)
  AND    AI.RowID BETWEEN p_start_rowid AND p_end_rowid
  AND  ((Line.Line_Type = 'ITEM' AND AID.Amount IS NOT NULL)
  OR    (Line.Line_Type = 'IPV'  AND NVL(AID.Invoice_Price_Variance, 0) <> 0)
  OR    (Line.Line_Type = 'ERV'  AND NVL(AID.Exchange_Rate_Variance, 0) <> 0));



  l_debug_info := 'Creating TAX, TIPV and TERV type of distributions';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;


  /* This insert statement will insert TAX, TIPV and TERV type of distributions
     based on the data from ap_invoice_distributions and
     ap_chrg_allocations of 11i. */


  INSERT INTO ap_inv_dists_target t1
        (BATCH_ID,
         INVOICE_ID,
         INVOICE_LINE_NUMBER,
         INVOICE_DISTRIBUTION_ID,
         DISTRIBUTION_LINE_NUMBER,
         LINE_TYPE_LOOKUP_CODE,
         DESCRIPTION,
         DIST_MATCH_TYPE,
         ORG_ID,
         DIST_CODE_COMBINATION_ID,
         ACCOUNTING_DATE,
         PERIOD_NAME,
         ACCRUAL_POSTED_FLAG,
         CASH_POSTED_FLAG,
         AMOUNT_TO_POST,
         BASE_AMOUNT_TO_POST,
         POSTED_FLAG,
         ACCOUNTING_EVENT_ID,
         SET_OF_BOOKS_ID,
         AMOUNT,
         BASE_AMOUNT,
         EXCHANGE_DATE,
         ROUNDING_AMT,
         QUANTITY_VARIANCE,
         BASE_QUANTITY_VARIANCE,
         MATCH_STATUS_FLAG,
         ENCUMBERED_FLAG,
         PACKET_ID,
         USSGL_TRANSACTION_CODE,
         USSGL_TRX_CODE_CONTEXT,
         REVERSAL_FLAG,
         PARENT_REVERSAL_ID,
         CANCELLED_FLAG,
         INCOME_TAX_REGION,
         TYPE_1099,
         STAT_AMOUNT,
         CHARGE_APPLICABLE_TO_DIST_ID,
         PREPAY_AMOUNT_REMAINING,
         PREPAY_DISTRIBUTION_ID,
         PREPAY_TAX_PARENT_ID,
         PARENT_INVOICE_ID,
         CORRECTED_QUANTITY,
         PO_DISTRIBUTION_ID,
         RCV_TRANSACTION_ID,
         UNIT_PRICE,
         MATCHED_UOM_LOOKUP_CODE,
         QUANTITY_INVOICED,
         FINAL_MATCH_FLAG,
         RELATED_ID,
         ASSETS_ADDITION_FLAG,
         ASSETS_TRACKING_FLAG,
         PROJECT_ID,
         TASK_ID,
         EXPENDITURE_TYPE,
         EXPENDITURE_ITEM_DATE,
         EXPENDITURE_ORGANIZATION_ID,
         PA_QUANTITY,
         PA_ADDITION_FLAG,
         AWARD_ID,
         GMS_BURDENABLE_RAW_COST,
         AWT_FLAG,
         AWT_GROUP_ID,
         AWT_TAX_RATE_ID,
         AWT_GROSS_AMOUNT,
         AWT_INVOICE_ID,
         AWT_ORIGIN_GROUP_ID,
         AWT_INVOICE_PAYMENT_ID,
         AWT_WITHHELD_AMT,
         INVENTORY_TRANSFER_STATUS,
         REFERENCE_1,
         REFERENCE_2,
         RECEIPT_VERIFIED_FLAG,
         RECEIPT_REQUIRED_FLAG,
         RECEIPT_MISSING_FLAG,
         JUSTIFICATION,
         EXPENSE_GROUP,
         START_EXPENSE_DATE,
         END_EXPENSE_DATE,
         RECEIPT_CURRENCY_CODE,
         RECEIPT_CONVERSION_RATE,
         RECEIPT_CURRENCY_AMOUNT,
         DAILY_AMOUNT,
         WEB_PARAMETER_ID,
         ADJUSTMENT_REASON,
         MERCHANT_DOCUMENT_NUMBER,
         MERCHANT_NAME,
         MERCHANT_REFERENCE,
         MERCHANT_TAX_REG_NUMBER,
         MERCHANT_TAXPAYER_ID,
         COUNTRY_OF_SUPPLY,
         CREDIT_CARD_TRX_ID,
         COMPANY_PREPAID_INVOICE_ID,
         CC_REVERSAL_FLAG,
         SUMMARY_TAX_LINE_ID,
         DETAIL_TAX_DIST_ID,
         RECOVERY_RATE_CODE,
         RECOVERY_RATE_ID,
         RECOVERY_TYPE_CODE,
         RECOVERY_RATE_NAME,
         REC_NREC_RATE,
         TAX_RECOVERABLE_FLAG,
         TAXABLE_AMOUNT,
         TAXABLE_BASE_AMOUNT,
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
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
         REQUEST_ID,
         OLD_DISTRIBUTION_ID,
         OLD_DIST_LINE_NUMBER,
         DISTRIBUTION_CLASS,
         TOTAL_DIST_AMOUNT,
         TOTAL_DIST_BASE_AMOUNT,
         TAX_CODE_ID,
         TAX_ALREADY_DISTRIBUTED_FLAG,
         INTENDED_USE,
         HISTORICAL_FLAG,
         RCV_CHARGE_ADDITION_FLAG)
  SELECT /*+ Rowid(AI) Ordered Use_hash(AI,TAA,AID,TAA1,AID1,TAA2) NO_EXPAND */
         AID.Batch_ID Batch_ID,
         AID.Invoice_ID Invoice_ID,
         AID.Line_Number Invoice_Line_Number,
         DECODE(Line.Line_Type, 'TAX', TAA.New_Dist_ID,
                     AP_INVOICE_DISTRIBUTIONS_S.NEXTVAL) Invoice_Distribution_ID,
         -- AP_DIST_LINE_NUM_UPG_S.NEXTVAL Distribution_Line_Number,
         RANK() OVER (PARTITION BY AID.INVOICE_ID, AID.LINE_NUMBER
                      ORDER BY NVL(TAA.Charge_Allocation_ID, AID.Invoice_Distribution_ID),
                               LINE.Line_Type, TAA.New_Dist_ID) Distribution_Line_Number,
         DECODE(Line.Line_Type, 'TAX',
                   DECODE(AID.Tax_Recoverable_Flag, 'Y', 'REC_TAX', 'NONREC_TAX'),
                   Line.Line_Type) Line_Type_Lookup_Code,
         AID.Description Description,
         DECODE(AID.Match_Type, 'LINE_CORRECTION', 'DIST_CORRECTION',
                                 AID.Match_Type) Dist_Match_Type,
         AID.Org_ID Org_ID,
	 /* BUG# 9154829 - assigned  Price_Var_Code_Combination_ID to TIPV
	     and Rate_Var_Code_Combination_ID to TERV.  */
         DECODE(Line.Line_Type, 'TAX', AID.Dist_Code_Combination_ID,
                  'TIPV', NVL(AID.Price_Var_Code_Combination_ID, AID.Dist_Code_Combination_ID),
                  'TERV', NVL(AID.Rate_Var_Code_Combination_ID, AID.Dist_Code_Combination_ID))
             Dist_Code_Combination_ID,
         AID.Accounting_Date Accounting_Date,
         AID.Period_Name Period_Name,
         AID.Accrual_Posted_Flag Accrual_Posted_Flag,
         AID.Cash_Posted_Flag Cash_Posted_Flag,
         AID.Amount_To_Post Amount_To_Post,
         AID.Base_Amount_To_Post Base_Amount_To_Post,
         AID.Posted_Flag Posted_Flag,
         AID.Accounting_Event_ID Accounting_Event_ID,
         AID.Set_Of_Books_ID Set_Of_Books_ID,
         DECODE(Line.Line_Type, 'TAX',
           DECODE(TAA.Rank_Num, TAA.Dist_Count,
                  TAA.Amount - TAA.Sum_Amount
                      - DECODE(AID.Reversal_Flag, 'Y', 0, NVL(AID.Invoice_Price_Variance,0))
                      + TAA.Line_Amount, TAA.Amount),
             'TIPV', DECODE(TAA.Rank_Num, TAA.Dist_Count,
                      TAA.IPV_Amount - TAA.Sum_IPV_Amount
                        + DECODE(AID.Reversal_Flag, 'Y', 0, NVL(AID.Invoice_Price_Variance,0)),
                      TAA.IPV_Amount),
             0) Amount,
         DECODE(Line.Line_Type, 'TAX',
           DECODE(TAA.Rank_Num, TAA.Dist_Count,
                   TAA.Base_Amount - TAA.Sum_Base_Amount -
                     DECODE(AID.Base_Amount, NULL, 0,
                        DECODE(AID.Reversal_Flag, 'Y', 0, NVL(AID.Base_Invoice_Price_Variance,0)))
                     - DECODE(AID.Reversal_Flag, 'Y', 0, NVL(AID.Exchange_Rate_Variance,0))
                     + TAA.Line_Base_Amount,
                   TAA.Base_Amount),
             'TIPV', DECODE(TAA.Rank_Num, TAA.Dist_Count,
                   TAA.IPV_Base_Amount - TAA.Sum_IPV_Base_Amount
                       + DECODE(AID.Reversal_Flag, 'Y', 0,
                           DECODE(AID.Base_Amount, NULL, 0, AID.Base_Invoice_Price_Variance)),
                   TAA.IPV_Base_Amount),
             DECODE(TAA.Rank_Num, TAA.Dist_Count,
                   TAA.ERV_Amount - TAA.Sum_ERV_Amount +
                       DECODE(AID.Reversal_Flag, 'Y', 0, AID.Exchange_Rate_Variance),
                   TAA.ERV_Amount)) Base_Amount,
         AID.Exchange_Date Exchange_Date,
         NULL Rounding_Amt,
         DECODE(Line.Line_Type, 'TAX', AID.Quantity_Variance, NULL) Quantity_Variance,
         DECODE(Line.Line_Type, 'TAX', AID.Base_Quantity_Variance, NULL) Base_Quantity_Variance,
         AID.Match_Status_Flag Match_Status_Flag,
         AID.Encumbered_Flag Encumbered_Flag,
         AID.Packet_ID Packet_ID,
         AID.USSGL_Transaction_Code USSGL_Transaction_Code,
         AID.USSGL_Trx_Code_Context USSGL_Trx_Code_Context,
         AID.Reversal_Flag Reversal_Flag,
	 /* bug 9067770 - nullified the parent reversal id
	    for TIPV and TERV columns to avoid duplicate reversal ids for thse
	    line type after upgrade */
         DECODE(Line.Line_Type, 'TIPV', NULL,
	                        'TERV', NULL,
                NVL(TAA2.new_dist_id,AID.Parent_Reversal_ID) ) Parent_Reversal_ID, --8608129
         AID.Cancellation_Flag Cancelled_Flag,
         AID.Income_Tax_Region Income_Tax_Region,
         AID.Type_1099 Type_1099,
         AID.Stat_Amount Stat_Amount,
         DECODE(AID.Prepay_Tax_Parent_ID, NULL,
                DECODE(TAA.Charge_Allocation_ID, NULL, NULL,
                       NVL(TAA1.New_Dist_ID,TAA.Item_Dist_ID)),
                AID.Prepay_Tax_Parent_ID) Charge_Applicable_To_Dist_ID,
         DECODE(Line.Line_Type, 'TAX', AID.Prepay_Amount_Remaining, NULL) Prepay_Amount_Remaining,
         DECODE(Line.Line_Type, 'TAX', AID.Prepay_Distribution_ID, NULL) Prepay_Distribution_ID,
         AID.Prepay_Tax_Parent_ID Prepay_Tax_Parent_ID,
         AID.Parent_Invoice_ID Parent_Invoice_ID,
         DECODE(Line.Line_Type, 'TAX', AID.Price_Correct_Qty, NULL) Corrected_Quantity,
         AID.PO_Distribution_ID PO_Distribution_ID,
         AID.RCV_Transaction_ID RCV_Transaction_ID,
         AID.Unit_Price Unit_Price,
         AID.Matched_UOM_Lookup_Code Matched_UOM_Lookup_Code,
         DECODE(Line.Line_Type, 'TAX', AID.Quantity_Invoiced, NULL) Quantity_Invoiced,
         AID.Final_Match_Flag Final_Match_Flag,
         TAA.New_Dist_ID Related_ID,
         AID.Assets_Addition_Flag Assets_Addition_Flag,
         AID.Assets_Tracking_Flag Assets_Tracking_Flag,
         AID.Project_ID Project_ID,
         AID.Task_ID Task_ID,
         AID.Expenditure_Type Expenditure_Type,
         AID.Expenditure_Item_Date Expenditure_Item_Date,
         AID.Expenditure_Organization_ID Expenditure_Organization_ID,
         AID.PA_Quantity PA_Quantity,
         AID.PA_Addition_Flag PA_Addition_Flag,
         AID.Award_ID Award_ID,
         AID.GMS_Burdenable_Raw_Cost GMS_Burdenable_Raw_Cost,
         AID.Awt_Flag,               --9366024
         AID.Awt_Group_ID,           --9366024
         AID.Awt_Tax_Rate_ID,        --9366024
         DECODE(Line.Line_Type, 'TAX', AID.Awt_Gross_Amount, NULL) Awt_Gross_Amount,
         AID.Awt_Invoice_ID,         --9366024
         AID.Awt_Origin_Group_ID,    --9366024
         AID.Awt_Invoice_Payment_ID, --9366024
         DECODE(Line.Line_Type, 'TAX', AID.Awt_Withheld_Amt, NULL) Awt_Withheld_Amt,
         DECODE(Line.Line_Type, 'TAX', AID.Inventory_Transfer_Status, NULL) Inventory_Transfer_Status,
         AID.Reference_1 Reference_1,
         AID.Reference_2 Reference_2,
         AID.Receipt_Verified_Flag Receipt_Verified_Flag,
         AID.Receipt_Required_Flag Receipt_Required_Flag,
         AID.Receipt_Missing_Flag Receipt_Missing_Flag,
         AID.Justification Justification,
         AID.Expense_Group Expense_Group,
         AID.Start_Expense_Date Start_Expense_Date,
         AID.End_Expense_Date End_Expense_Date,
         AID.Receipt_Currency_Code Receipt_Currency_Code,
         AID.Receipt_Conversion_Rate Receipt_Conversion_Rate,
         AID.Receipt_Currency_Amount Receipt_Currency_Amount,
         AID.Daily_Amount Daily_Amount,
         AID.Web_Parameter_ID Web_Parameter_ID,
         AID.Adjustment_Reason Adjustment_Reason,
         AID.Merchant_Document_Number Merchant_Document_Number,
         AID.Merchant_Name Merchant_Name,
         AID.Merchant_Reference Merchant_Reference,
         AID.Merchant_Tax_Reg_Number Merchant_Tax_Reg_Number,
         AID.Merchant_Taxpayer_ID Merchant_Taxpayer_ID,
         AID.Country_Of_Supply Country_Of_Supply,
         AID.Credit_Card_Trx_ID Credit_Card_Trx_ID,
         AID.Company_Prepaid_Invoice_ID Company_Prepaid_Invoice_ID,
         AID.CC_Reversal_Flag CC_Reversal_Flag,
         NVL(AID.Summary_Tax_Line_ID, AID1.Summary_Tax_Line_ID) Summary_Tax_Line_ID,
         TAA.Detail_Tax_Dist_ID Detail_Tax_Dist_ID,
         NULL Recovery_Rate_Code,
         NULL Recovery_Rate_ID,
         NULL Recovery_Type_Code,
         NULL Recovery_Rate_Name,
         DECODE(Line.Line_Type, 'TAX',
           DECODE(ALLOC.Rec_NRec_Rate, NULL,
              ROUND((NVL(TAA.Allocated_Amount,0)
                / DECODE(ALLOC.Sum_Alloc_Amount, 0, 1, ALLOC.Sum_Alloc_Amount)) * 100, 2),
              DECODE(AID.Tax_Recoverable_Flag, 'N', 100 - ALLOC.Rec_NRec_Rate,
                ALLOC.Rec_NRec_Rate)), NULL) Rec_NRec_Rate,
         AID.Tax_Recoverable_Flag Tax_Recoverable_Flag,
	 NVL(ALLOC.Item_Amount,0) Taxable_Amount,            -- 9369683
	 NVL(ALLOC.Item_Base_Amount,0) Taxable_Base_Amount,  -- 9369683
         AID.Attribute_Category Attribute_Category,
         AID.Attribute1 Attribute1,
         AID.Attribute2 Attribute2,
         AID.Attribute3 Attribute3,
         AID.Attribute4 Attribute4,
         AID.Attribute5 Attribute5,
         AID.Attribute6 Attribute6,
         AID.Attribute7 Attribute7,
         AID.Attribute8 Attribute8,
         AID.Attribute9 Attribute9,
         AID.Attribute10 Attribute10,
         AID.Attribute11 Attribute11,
         AID.Attribute12 Attribute12,
         AID.Attribute13 Attribute13,
         AID.Attribute14 Attribute14,
         AID.Attribute15 Attribute15,
         AID.Global_Attribute_Category Global_Attribute_Category,
         AID.Global_Attribute1 Global_Attribute1,
         AID.Global_Attribute2 Global_Attribute2,
         AID.Global_Attribute3 Global_Attribute3,
         AID.Global_Attribute4 Global_Attribute4,
         AID.Global_Attribute5 Global_Attribute5,
         AID.Global_Attribute6 Global_Attribute6,
         AID.Global_Attribute7 Global_Attribute7,
         AID.Global_Attribute8 Global_Attribute8,
         AID.Global_Attribute9 Global_Attribute9,
         AID.Global_Attribute10 Global_Attribute10,
         AID.Global_Attribute11 Global_Attribute11,
         AID.Global_Attribute12 Global_Attribute12,
         AID.Global_Attribute13 Global_Attribute13,
         AID.Global_Attribute14 Global_Attribute14,
         AID.Global_Attribute15 Global_Attribute15,
         AID.Global_Attribute16 Global_Attribute16,
         AID.Global_Attribute17 Global_Attribute17,
         AID.Global_Attribute18 Global_Attribute18,
         AID.Global_Attribute19 Global_Attribute19,
         AID.Global_Attribute20 Global_Attribute20,
         AID.Created_By Created_By,
         AID.Creation_Date Creation_Date,
         AID.Last_Updated_By Last_Updated_By,
         AID.Last_Update_Date Last_Update_Date,
         AID.Last_Update_Login Last_Update_Login,
         AID.Program_Application_ID Program_Application_ID,
         AID.Program_ID Program_ID,
         AID.Program_Update_Date Program_Update_Date,
         AID.Request_ID Request_ID,
         AID.Invoice_Distribution_ID Old_Distribution_ID,
         AID.Distribution_Line_Number Old_Dist_Line_Number,
         'PERMANENT' Distribution_Class,
         DECODE(Line.Line_Type, 'TAX',
           DECODE(TAA.Rank_Num, TAA.Dist_Count,
                  TAA.Amount - TAA.Sum_Amount
                      + TAA.Line_Amount, TAA.Amount), NULL) Total_Dist_Amount,
         DECODE(Line.Line_Type, 'TAX', TAA.Base_Amount + TAA.IPV_Base_Amount + TAA.ERV_Amount,
                                       NULL) Total_Dist_Base_Amount,
         AID.New_Tax_Code_ID Tax_Code_ID,
         'Y' Tax_Already_Distributed_Flag,
         (CASE
               WHEN AI.global_attribute_category = 'JL.AR.APXINWKB.INVOICES ' THEN
                    AI.global_attribute10
               WHEN AI.global_attribute_category = 'JL.AR.APXIISIM.INVOICES_FOLDER' THEN
                    AI.global_attribute10
         END) AS Intended_Use,
         'Y' Historical_Flag,
         'N' RCV_Charge_Addition_Flag
  FROM   AP_System_Parameters_All ASP,
         AP_Invoices_ALL AI,
         FND_Currencies FC,
         AP_Dist_Line_GT AID,
         AP_Tax_Alloc_Amount_GT TAA,
         AP_Tax_Alloc_Amount_GT TAA1,
         AP_Dist_Line_GT AID1,
        (SELECT /*+ ROWID (AI) Ordered USE_NL(ACA,AID,AID1) */
                AID.Invoice_Distribution_ID Item_Dist_ID,
                AID.Amount Item_Amount,
                AID.Base_Amount Item_Base_Amount,
                SUM(NVL(ACA.Allocated_Amount,AID.Amount)) Sum_Alloc_Amount,
                SUM(NVL(ACA.Allocated_Base_Amount,AID.Base_Amount)) Sum_Alloc_Base_Amount,
                AID.Tax_Recovery_Rate Rec_NRec_Rate,
                AID.Set_Of_Books_ID
         FROM   AP_Invoices_All AI,
                AP_Inv_Dists_Source AID,
                AP_Chrg_Allocations_All ACA,
                AP_Inv_Dists_Source AID1
         WHERE  AI.Invoice_ID = AID.Invoice_ID
         AND    AID.Invoice_Distribution_ID = ACA.Item_Dist_ID
         AND    AID1.Invoice_Distribution_ID = ACA.Charge_Dist_ID
         AND    AID1.Line_Type_Lookup_Code = 'TAX'
         AND    AI.RowID BETWEEN p_start_rowid AND p_end_rowid
         GROUP  BY AID.Invoice_Distribution_ID,
                   AID.Amount,
                   AID.Base_Amount,
                   AID.Tax_Recovery_Rate,
                   AID.Set_Of_Books_ID
        ) ALLOC,
         AP_Line_Temp_GT Line,
         AP_Tax_Alloc_Amount_GT TAA2  --8608129
  WHERE  AI.Invoice_ID = AID.Invoice_ID
  AND    NVL(AI.Org_ID,-99) = NVL(ASP.Org_ID,-99)
  AND    AI.Invoice_Currency_Code = FC.Currency_Code
  AND    AID.Line_Type_Lookup_Code = 'TAX'
  AND    AID.Invoice_Distribution_ID = TAA.Old_Dist_ID
  AND    TAA.Item_Dist_ID = ALLOC.Item_Dist_ID (+)
  AND    TAA.Item_Charge_Alloc_ID = TAA1.Charge_Allocation_ID (+)
  AND    TAA.Item_Charge_Alloc_ID2 = TAA1.Item_Charge_Alloc_ID (+)
  AND    AID.Parent_Reversal_ID = AID1.Invoice_Distribution_ID (+)
  AND    TAA.Parent_Reversal_ID = TAA2.old_dist_id (+) --8608129
  AND    TAA.org_item_id = TAA2.Item_Dist_ID (+)  --8608129
  AND    decode(TAA2.Item_Dist_ID, null, 1, TAA2.charge_allocation_id) IS NOT NULL --8608129
  AND    TAA.Item_Charge_Alloc_ID = TAA2.Item_Charge_Alloc_ID (+) --8681082
  AND    AI.RowID BETWEEN p_start_rowid AND p_end_rowid
  AND  ((Line.Line_Type = 'TAX' AND AID.Amount IS NOT NULL)
  OR    (Line.Line_Type = 'TIPV' AND NVL(AID.Invoice_Price_Variance, 0) <> 0)
  OR    (Line.Line_Type = 'TERV' AND NVL(AID.Exchange_Rate_Variance, 0) <> 0));


/*
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        IF g_debug_flag = 'Y' THEN
           AP_Debug_Pkg.Print('Y','SQLAP','AP_DEBUG','ERROR',SQLERRM,
                              'CALLING_SEQUENCE', l_curr_calling_sequence);
        END IF;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
*/


END Transform_Distributions;



-------------------------------------------------------------------
-- PROCEDURE Populate_Lines
-- Purpose
-- This procedure POPULATE_LINES calls the Create_Lines and
-- Transform_Distributions procedures to insert lines and distributions
-------------------------------------------------------------------
PROCEDURE Populate_Lines
               (P_Start_Rowid        IN         ROWID,
                P_End_Rowid          IN         ROWID,
                P_Calling_Sequence   IN         VARCHAR2) IS

  l_debug_info                 VARCHAR2(1000);
  l_curr_calling_sequence      VARCHAR2(1000);

BEGIN

  l_curr_calling_sequence := 'AP_LINES_UPGRADE_PKG.Populate_Lines<-'
                                        || p_calling_sequence;

  l_debug_info := 'Inside Populate_Lines procedure';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;


  l_debug_info := 'Calling procedure insert_dist_line_info';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;

  Insert_Dist_Line_Info(P_Start_Rowid,
                        P_End_Rowid,
                        l_curr_calling_sequence);


  l_debug_info := 'Calling procedure insert_alloc_info';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;

  Insert_Alloc_Info(P_Start_Rowid,
                    P_End_Rowid,
                    l_curr_calling_sequence);


  l_debug_info := 'Calling Create_Lines procedure';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;


  /* Calling Create_Lines procedure to insert lines into
     the ap_invoice_lines_all table */
  Create_Lines (P_Start_Rowid,
                P_End_Rowid,
                l_curr_calling_sequence);


  l_debug_info := 'Calling Transform_Distributions procedure';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;


  /* Calling Transform_Distributions procedure to insert the
     new distributions into the ap_inv_dists_update table */
  Transform_Distributions (P_Start_Rowid,
                           P_End_Rowid,
                           l_curr_calling_sequence);

  l_debug_info := 'End of Populate_Lines procedure';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;


/*
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        IF g_debug_flag = 'Y' THEN
           AP_Debug_Pkg.Print('Y','SQLAP','AP_DEBUG','ERROR',SQLERRM,
                              'CALLING_SEQUENCE', l_curr_calling_sequence);
        END IF;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
*/

END Populate_Lines;



-------------------------------------------------------------------
-- PROCEDURE Transaction_Upgrade_Subworker
-- Purpose
-- This procedure TRANSACTION_UPGRADE_SUBWORKER handles all functions
-- involved in the creation of lines and populating the new
-- distributions.
-------------------------------------------------------------------
PROCEDURE Transaction_Upgrade_Subworker
               (Errbuf                  IN OUT NOCOPY VARCHAR2,
                Retcode                 IN OUT NOCOPY VARCHAR2,
                P_Worker_No             IN            NUMBER,
                P_Init_Process          IN            VARCHAR2,
                P_Upgrade_Mode          IN            VARCHAR2,
                P_Batch_Size            IN            VARCHAR2,
                P_Num_Workers           IN            NUMBER,
                P_Parent_Request_ID     IN            NUMBER,
                P_Debug_Flag            IN            VARCHAR2) IS

  l_status                    VARCHAR2(30);
  l_industry                  VARCHAR2(30);
  l_debug_info                VARCHAR2(1000);
  l_curr_calling_sequence     VARCHAR2(2000);

  l_table_owner               VARCHAR2(30);
  l_any_rows_to_process       BOOLEAN;

  l_table_name                VARCHAR2(30) := 'AP_INVOICES_ALL';
  l_script_name               VARCHAR2(30) := 'apilnupg.sql';

  l_start_rowid               ROWID;
  l_end_rowid                 ROWID;
  l_rows_processed            NUMBER;

  l_request_id                NUMBER := FND_GLOBAL.conc_request_id;
  l_restart                   BOOLEAN := FALSE;

  TYPE LineList IS TABLE OF VARCHAR2(25);
  linetype  LineList := LineList('ITEM', 'ERV', 'IPV', 'TAX', 'TERV', 'TIPV');

BEGIN

  l_curr_calling_sequence := 'AP_LINES_UPGRADE_PKG.Transaction_Upgrade_Subworker';

  g_debug_flag := p_debug_flag;

  l_debug_info := 'Inside Transaction_Upgrade_Subworker procedure';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;


  /* Inserting into the ap_invoices_upg_control table information
     about the Transaction Upgrade Subworkers that have been
     submitted from the Main program */
  INSERT INTO ap_invoices_upg_control
        (Module_Name,
         Sub_Module,
         Upgrade_Phase,
         Start_Date,
         End_Date,
         Parent_Request_ID,
         Creation_Date,
         Created_By,
         Last_Updated_By,
         Last_Update_Date,
         Last_Update_Login,
         Program_Application_ID,
         Program_ID,
         Request_ID)
  VALUES
        ('TRANSACTION_UPGRADE_MAIN',
         'TRANSACTION_UPGRADE_SUBWORKER',
         p_upgrade_mode,
         sysdate,
         NULL,
         p_parent_request_id,
         sysdate,
         FND_GLOBAL.User_ID,
         FND_GLOBAL.User_ID,
         sysdate,
         FND_GLOBAL.Login_ID,
         DECODE(p_upgrade_mode, 'PRE-UPGRADE', FND_GLOBAL.prog_appl_id, NULL),
         DECODE(p_upgrade_mode, 'PRE-UPGRADE', FND_GLOBAL.conc_program_id, NULL),
         DECODE(p_upgrade_mode, 'PRE-UPGRADE', l_request_id, NULL));


  FORALL i IN linetype.FIRST..linetype.LAST
     INSERT INTO AP_Line_Temp_GT (Line_Type)
     VALUES (linetype(i));

  IF (FND_INSTALLATION.GET_APP_INFO('SQLAP', l_status, l_industry, l_table_owner)) THEN
      NULL;
  END IF;

  g_table_owner := l_table_owner;

  ad_parallel_updates_pkg.initialize_rowid_range(
                 ad_parallel_updates_pkg.ROWID_RANGE,
                 l_table_owner,
                 l_table_name,
                 l_script_name,
                 p_worker_no,
                 p_num_workers,
                 p_batch_size, 0);


  IF p_init_process = 'Y' THEN
     l_restart := TRUE;
  ELSE
     l_restart := FALSE;
  END IF;

  ad_parallel_updates_pkg.get_rowid_range(
                l_start_rowid,
                l_end_rowid,
                l_any_rows_to_process,
                p_batch_size,
                l_restart);

  l_debug_info := 'Upgrading Invoices from ' || l_start_rowid
                                   || ' to ' || l_end_rowid;
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;


  WHILE (l_any_rows_to_process = TRUE) LOOP

         l_debug_info := 'Calling Populate_Lines procedure';
         IF g_debug_flag = 'Y' THEN
            AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
         END IF;


         Populate_Lines (l_start_rowid,
                         l_end_rowid,
                         l_curr_calling_sequence);


         l_rows_processed := SQL%ROWCOUNT;

         ad_parallel_updates_pkg.processed_rowid_range
                                 (l_rows_processed,
                                  l_end_rowid);
         COMMIT;

         --
         -- get new range of rowids
         --
         ad_parallel_updates_pkg.get_rowid_range
                                 (l_start_rowid,
                                  l_end_rowid,
                                  l_any_rows_to_process,
                                  p_batch_size,
                                  FALSE);

         l_debug_info := 'Upgrading Invoices from ' || l_start_rowid
                                          || ' to ' || l_end_rowid;
         IF g_debug_flag = 'Y' THEN
            AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
         END IF;

  END LOOP;

  UPDATE ap_invoices_upg_control
  SET    end_date = sysdate
  WHERE  parent_request_id = p_parent_request_id
  AND    request_id = l_request_id;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        IF g_debug_flag = 'Y' THEN
           AP_Debug_Pkg.Print('Y','SQLAP','AP_DEBUG','ERROR',SQLERRM,
                              'CALLING_SEQUENCE', l_curr_calling_sequence);
        END IF;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Transaction_Upgrade_Subworker;



-------------------------------------------------------------------
-- PROCEDURE Transaction_Upgrade_Main
-- Purpose
-- This procedure TRANSACTION_UPGRADE_MAIN is the main procedure
-- involved in the creation of lines and populating the new
-- distributions.
--
-- This program could be run during the PRE-UPGRADE or UPGRADE mode
-------------------------------------------------------------------
PROCEDURE Transaction_Upgrade_Main
               (Errbuf            IN OUT NOCOPY VARCHAR2,
                Retcode           IN OUT NOCOPY VARCHAR2,
                P_Upgrade_Mode    IN            VARCHAR2,
                P_Batch_Size      IN            VARCHAR2,
                P_Num_Workers     IN            NUMBER,
                P_Force_Upgrade   IN            VARCHAR2,
                P_Debug_Flag      IN            VARCHAR2) IS

  l_status                    VARCHAR2(30);
  l_industry                  VARCHAR2(30);
  l_debug_info                VARCHAR2(1000);
  l_curr_calling_sequence     VARCHAR2(2000);
  l_control_count             NUMBER;
  l_end_date                  DATE;
  l_failed_count              NUMBER;
  l_table_owner               VARCHAR2(30);


  TYPE WorkerList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_worker                    WorkerList;

  l_result                    BOOLEAN;
  l_phase                     VARCHAR2(500) := NULL;
  l_req_status                VARCHAR2(500) := NULL;
  l_devphase                  VARCHAR2(500) := NULL;
  l_devstatus                 VARCHAR2(500) := NULL;
  l_message                   VARCHAR2(500) := NULL;
  l_child_success             VARCHAR2(1);

  l_errbuf                    VARCHAR2(2000);
  l_retcode                   VARCHAR2(200);

  l_child_notcomplete         BOOLEAN := TRUE;

  TYPE LineList IS TABLE OF VARCHAR2(25);
  linetype  LineList := LineList('ITEM', 'ERV', 'IPV', 'TAX', 'TERV', 'TIPV');

BEGIN

  l_curr_calling_sequence := 'AP_LINES_UPGRADE_PKG.Transaction_Upgrade_Main';

  g_batch_size := p_batch_size;
  g_num_workers := p_num_workers;
  g_debug_flag := p_debug_flag;
  g_parent_request_id := FND_GLOBAL.conc_request_id;
  g_upgrade_mode := p_upgrade_mode;


  l_debug_info := 'Inside Transaction_Upgrade_Main procedure';
  IF g_debug_flag = 'Y' THEN
     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
  END IF;

  IF (FND_INSTALLATION.GET_APP_INFO('SQLAP', l_status, l_industry, l_table_owner)) THEN
      NULL;
  END IF;

  g_table_owner := l_table_owner;

  ZX_P2P_DEF_AP_PREUPG.Pre_Upgrade_Wrapper;

  IF p_force_upgrade = 'Y' THEN

     Truncate_Table('AP_INV_DISTS_UPDATE');
     Truncate_Table('AP_INVOICE_LINES_ALL');
     Truncate_Table('AP_INVOICES_UPG_CONTROL');

     ad_parallel_updates_pkg.delete_update_information
                             (ad_parallel_updates_pkg.ROWID_RANGE,
                              l_table_owner,
                              'AP_INVOICES_ALL',
                              'apilnupg.sql');

  END IF;


  /* Getting the previous run information for this program */
  SELECT count(*), max(end_date)
  INTO   l_control_count, l_end_date
  FROM   ap_invoices_upg_control
  WHERE  module_name = 'TRANSACTION_UPGRADE_MAIN';


  IF l_control_count = 1 and l_end_date IS NULL THEN
     g_init_process := 'N';
  END IF;


  /* If this is the first time that this program is submitted then enable
     the triggers on ap_invoice_distributions and ap_chrg_allocations of 11i */
  IF l_control_count = 0 THEN

     EXECUTE IMMEDIATE 'ALTER TRIGGER ap_invoice_distributions_aiud ENABLE';
     EXECUTE IMMEDIATE 'ALTER TRIGGER ap_chrg_allocations_aiud ENABLE';


     l_debug_info := 'Inserting record in the ap_invoices_upg_control table';
     IF g_debug_flag = 'Y' THEN
        AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
     END IF;

     /* Inserting into ap_invoices_upg_control table information about the
        Main program so as to track the progress of the upgrade */
     INSERT INTO ap_invoices_upg_control
           (Module_Name,
            Sub_Module,
            Upgrade_Phase,
            Start_Date,
            End_Date,
            Creation_Date,
            Created_By,
            Last_Updated_By,
            Last_Update_Date,
            Last_Update_Login,
            Program_Application_ID,
            Program_ID,
            Request_ID)
     VALUES
           ('TRANSACTION_UPGRADE_MAIN',
            NULL,
            p_upgrade_mode,
            sysdate,
            NULL,
            sysdate,
            FND_GLOBAL.User_ID,
            FND_GLOBAL.User_ID,
            sysdate,
            FND_GLOBAL.Login_ID,
            FND_GLOBAL.prog_appl_id,
            FND_GLOBAL.conc_program_id,
            FND_GLOBAL.conc_request_id);

  END IF;


  /* If the program is being submitted the first time or if the program has
     not completed successfully during the previous run then we will perform
     the upgrade */
  IF l_control_count = 0 OR l_end_date IS NULL THEN

     l_debug_info := 'Inserting into AP_Line_Temp_GT table';
     IF g_debug_flag = 'Y' THEN
        AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
     END IF;

     FORALL i IN linetype.FIRST..linetype.LAST
        INSERT INTO AP_Line_Temp_GT (Line_Type)
        VALUES (linetype(i));

     /* When the program is run in pre-upgrade mode it is submitted from
        the concurrent program and hence we need to spawn multiple child
        workers */

     l_debug_info := 'Launching child workers';
     IF g_debug_flag = 'Y' THEN
        AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
     END IF;

     FOR i in 1..p_num_workers
     LOOP

        IF g_init_process = 'Y' and i = 1 THEN
           g_init_process := 'Y';
        ELSE
           g_init_process := 'N';
        END IF;

        l_worker(i) := LAUNCH_WORKER(i, l_curr_calling_sequence);

     END LOOP;

     COMMIT;

/*

     WHILE l_child_notcomplete LOOP

           dbms_lock.sleep(300);

           l_debug_info := 'Inside Loop for checking the child request status';
           IF g_debug_flag = 'Y' THEN
              AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
           END IF;

           l_child_notcomplete := FALSE;

           FOR i in 1..p_num_workers
           LOOP

               IF (FND_CONCURRENT.GET_REQUEST_STATUS
                                 (l_worker(i),
                                  NULL,
                                  NULL,
                                  l_phase,
                                  l_req_status,
                                  l_devphase,
                                  l_devstatus,
                                  l_message)) THEN
                   NULL;
               END IF;

               IF l_devphase <> 'COMPLETE'  Then

                  l_debug_info := 'Loop once again';
                  IF g_debug_flag = 'Y' THEN
                     AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
                  END IF;

                  l_child_notcomplete := TRUE;
               END IF;

               IF l_devstatus = 'ERROR' THEN
                  l_child_success := 'N';
               END IF;

               EXIT;

           END LOOP;
     END LOOP;
*/

     FOR i IN 1..p_num_workers
     LOOP

       WHILE l_child_notcomplete LOOP

          dbms_lock.sleep(300);

          l_debug_info := 'Inside Loop for checking the child request status';
          IF g_debug_flag = 'Y' THEN
             AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
          END IF;

          l_child_notcomplete := FALSE;

          IF (FND_CONCURRENT.GET_REQUEST_STATUS
                                 (l_worker(i),
                                  NULL,
                                  NULL,
                                  l_phase,
                                  l_req_status,
                                  l_devphase,
                                  l_devstatus,
                                  l_message)) THEN
             NULL;
         END IF;

         IF l_devphase <> 'COMPLETE'  Then

            l_debug_info := 'Loop once again';
            IF g_debug_flag = 'Y' THEN
               AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
            END IF;

            l_child_notcomplete := TRUE;
         END IF;

         IF l_devstatus = 'ERROR' THEN
            l_child_success := 'N';
         END IF;

       END LOOP;
     END LOOP;


     /* If any subworkers have failed then raise an error */
     IF l_child_success = 'N' THEN
        RAISE G_CHILD_FAILED;
     END IF;


     SELECT count(*)
     INTO   l_failed_count
     FROM   ap_invoices_upg_control
     WHERE  parent_request_id = g_parent_request_id
     AND    end_date IS NULL;

     IF l_failed_count = 0 THEN

        UPDATE ap_invoices_upg_control
        SET    end_date = sysdate
        WHERE  module_name = 'TRANSACTION_UPGRADE_MAIN'
        AND    request_id = FND_GLOBAL.conc_request_id;

     END IF;

  ELSE

     l_debug_info := 'Calling the Sync Program';
     IF g_debug_flag = 'Y' THEN
        AP_Debug_Pkg.Print(g_debug_flag, l_debug_info);
     END IF;

     AP_LINES_UPGRADE_SYNC_PKG.Transaction_Upgrade_Sync
                              (l_errbuf,
                               l_retcode,
                               p_upgrade_mode,
                               p_debug_flag);


  END IF;

  COMMIT;

EXCEPTION

  WHEN G_CHILD_FAILED THEN
    g_retcode := -1;
    if g_debug_flag = 'Y' then
       AP_Debug_Pkg.Print('Y', 'Error in Procedure TRANSACTION_UPGRADE_SUB');
    end if;
    APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        IF g_debug_flag = 'Y' THEN
           AP_Debug_Pkg.Print('Y','SQLAP','AP_DEBUG','ERROR',SQLERRM,
                              'CALLING_SEQUENCE', l_curr_calling_sequence);
        END IF;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Transaction_Upgrade_Main;


END AP_LINES_UPGRADE_PKG;

/
