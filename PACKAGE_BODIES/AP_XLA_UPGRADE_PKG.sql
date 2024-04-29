--------------------------------------------------------
--  DDL for Package Body AP_XLA_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_XLA_UPGRADE_PKG" AS
/* $Header: apxlaupb.pls 120.12.12010000.7 2010/02/24 09:47:37 vbondada ship $ */

G_NO_CHILD_PROCESS       EXCEPTION;
G_PROCEDURE_FAILURE      EXCEPTION;
G_CHILD_FAILED           EXCEPTION;
g_errbuf                 VARCHAR2(2000) := NULL;
g_retcode                VARCHAR2(200)  := NULL;


g_current_runtime_level           NUMBER;
g_level_statement       CONSTANT  NUMBER := FND_LOG.LEVEL_STATEMENT;
g_level_procedure       CONSTANT  NUMBER := FND_LOG.LEVEL_PROCEDURE;


---------------------------------------------------
-- FUNCTION LAUNCH_WORKER
-- This function LAUNCH_WORKER will submit the subworker
-- request.
-- p_worker_no is the worker number of this particular worker
---------------------------------------------------
FUNCTION LAUNCH_WORKER(p_worker_id               NUMBER,
                       p_batch_size              VARCHAR2,
                       p_num_workers             NUMBER,
                       p_inv_script_name         VARCHAR2,
                       p_pay_script_name         VARCHAR2,
                       p_calling_sequence        VARCHAR2)
RETURN NUMBER IS

  l_request_id                  NUMBER;
  l_curr_calling_sequence       VARCHAR2(2000);

BEGIN

  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.LAUNCH_WORKER',
                    'LAUNCH_WORKER(-)');
  END IF;

  l_curr_calling_sequence := 'AP_XLA_UPGRADE_PKG.Launch_Worker<-'
                                   || p_calling_sequence;

  l_request_id := FND_REQUEST.SUBMIT_REQUEST
                         ('SQLAP',
                          'APXLASUB',
                          NULL,
                          NULL,
                          FALSE,
                          p_batch_size,
                          p_worker_id,
                          p_num_workers,
                          p_inv_script_name,
                          p_pay_script_name);

  -- This is the concurrent executable of the subworker.

  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_TRIAL_BALANCE',
                    'Child Request: '||l_request_id||' for worker '||p_worker_id);
  END IF;

  IF (l_request_id = 0) THEN
      rollback;
      g_retcode := -2;
      g_errbuf := 'Error in Procedure: LAUNCH_WORKER
                   Message: '||fnd_message.get;
      RAISE G_NO_CHILD_PROCESS;

  END IF;

  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.LAUNCH_WORKER',
                    'LAUNCH_WORKER(-)');
  END IF;

  RETURN l_request_id;

EXCEPTION
  WHEN G_NO_CHILD_PROCESS THEN
       g_retcode := -1;
       RAISE;
   WHEN OTHERS THEN
        ROLLBACK;
        g_retcode := -2;
        g_errbuf := 'Error in Procedure: LAUNCH_WORKER
                     Message: '||sqlerrm;
        RAISE g_procedure_failure;

END LAUNCH_WORKER;

------------------------------------------------------------------
-- Procedure CREATE_INVOICE_DIST_LINKS
-- Purpose
-- This procedure CREATE_INVOICE_DIST_LINKS creates invoice distribution
-- links
------------------------------------------------------------------
PROCEDURE Create_Invoice_Dist_Links
                (p_start_rowid           rowid,
                 p_end_rowid             rowid,
                 p_calling_sequence   VARCHAR2)  IS


l_curr_calling_sequence         VARCHAR2(2000);

BEGIN

  -- Update the calling sequence
  --
  l_curr_calling_sequence := 'Create_Invoice_Dist_Links<-'||P_calling_sequence;
  --

  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_INVOICE_DIST_LINKS',
                    'CREATE_INVOICE_DIST_LINKS(+)');
  END IF;

--Bug 8725986: Insert statement same as of apidstln.sql version 120.5.12000000.15
INSERT INTO XLA_Distribution_Links t1
        (APPLICATION_ID,
         EVENT_ID,
         AE_HEADER_ID,
         AE_LINE_NUM,
         SOURCE_DISTRIBUTION_TYPE,
         SOURCE_DISTRIBUTION_ID_NUM_1,
         STATISTICAL_AMOUNT,
         UNROUNDED_ENTERED_CR,
         UNROUNDED_ENTERED_DR,
         UNROUNDED_ACCOUNTED_CR,
         UNROUNDED_ACCOUNTED_DR,
         REF_AE_HEADER_ID,
         ACCOUNTING_LINE_CODE,
         ACCOUNTING_LINE_TYPE_CODE,
         MERGE_DUPLICATE_CODE,
	 TAX_LINE_REF_ID, 	  -- 7289100 changes
         TAX_SUMMARY_LINE_REF_ID,
         TAX_REC_NREC_DIST_REF_ID,
         TEMP_LINE_NUM,
         REF_EVENT_ID,
         UPG_BATCH_ID,
         LINE_DEFINITION_OWNER_CODE,
         LINE_DEFINITION_CODE,
         EVENT_CLASS_CODE,
         EVENT_TYPE_CODE)
  SELECT 200 Application_ID,
         Event_ID,
         AE_Header_ID,
         AE_Line_Num,
         'AP_INV_DIST' Source_Distribution_Type,
         Invoice_Distribution_ID,
         Stat_Amount,
        /* 5755674 Populating the distribution amounts instead of
                    the entered and accounted amounts from ae lines */
         DECODE(Accounting_Line_Code, 'AP_LIAB_INV',
                DECODE(SIGN(NVL(Amount,0)),
                   -1, NULL,
                    0, DECODE(SIGN(Base_Amount),
                               -1, NULL,
                               NVL(Amount,0)),
                    NVL(Amount,0)),
                DECODE(SIGN(NVL(Amount,0)),
                   -1, ABS(NVL(Amount,0)),
                    0, DECODE(SIGN(NVL(Base_Amount, Amount)),
                               -1, ABS(nvl(Amount,0)),
                               NULL),
                    NULL)) Entered_Cr,
         DECODE(Accounting_Line_Code, 'AP_LIAB_INV',
                 DECODE(SIGN(NVL(Amount,0)),
                    -1, ABS(NVL(Amount,0)),
                    0, DECODE(SIGN(Base_Amount),
                               -1, ABS(NVL(Amount,0)),
                               NULL),
                    NULL),
                 DECODE(SIGN(NVL(Amount,0)),
                   -1, NULL,
                    0, DECODE(SIGN(Base_Amount),
                               -1, NULL,
                               NVL(Amount,0)),
                    NVL(Amount,0))) Entered_Dr,
         DECODE(Accounting_Line_Code, 'AP_LIAB_INV',
            DECODE(Line_Type_Lookup_Code, 'ERV',
                DECODE(SIGN(NVL(Base_Amount,0)),
                   -1, NULL,
                    NVL(Base_Amount,0)),
                DECODE(SIGN(NVL(Amount,0)),
                   -1, NULL,
                    0, DECODE(SIGN(NVL(Acctd_Amount, Amount)),
                               -1, NULL,
                               NVL(NVL2(Min_Acct_Unit,ROUND(Acctd_Amount/Min_Acct_Unit)*
                                Min_Acct_Unit, ROUND(Acctd_Amount, Precision)), Amount)),
                    NVL(NVL2(Min_Acct_Unit,ROUND(Acctd_Amount/Min_Acct_Unit)*
                                Min_Acct_Unit, ROUND(Acctd_Amount, Precision)), Amount))),
            DECODE(Line_Type_Lookup_Code, 'ERV',
                DECODE(SIGN(NVL(Base_Amount,0)),
                   -1, ABS(NVL(Base_Amount,0)),
                    NULL),
                DECODE(SIGN(NVL(Amount,0)),
                   -1, ABS(NVL(NVL2(Min_Acct_Unit,ROUND(Acctd_Amount/Min_Acct_Unit)*
                                Min_Acct_Unit, ROUND(Acctd_Amount, Precision)), Amount)),
                    0, DECODE(SIGN(NVL(Acctd_Amount, Amount)),
                               -1, ABS(NVL(NVL2(Min_Acct_Unit,ROUND(Acctd_Amount/Min_Acct_Unit)*
                                            Min_Acct_Unit, ROUND(Acctd_Amount, Precision)), Amount)),
                               NULL),
                    NULL))) Accounted_Cr,
         DECODE(Accounting_Line_Code, 'AP_LIAB_INV',
            DECODE(Line_Type_Lookup_Code, 'ERV',
                DECODE(SIGN(NVL(Base_Amount,0)),
                    -1, ABS(NVL(Base_Amount,0)),
                    NULL),
                DECODE(SIGN(NVL(Amount,0)),
                   -1, ABS(NVL(NVL2(Min_Acct_Unit,ROUND(Acctd_Amount/Min_Acct_Unit)*
                                Min_Acct_Unit, ROUND(Acctd_Amount, Precision)), Amount)),
                    0, DECODE(SIGN(NVL(Acctd_Amount, Amount)),
                               -1, ABS(NVL(NVL2(Min_Acct_Unit,ROUND(Acctd_Amount/Min_Acct_Unit)*
                                            Min_Acct_Unit, ROUND(Acctd_Amount, Precision)), Amount)),
                               NULL),
                    NULL)),
            DECODE(Line_Type_Lookup_Code, 'ERV',
                 DECODE(SIGN(NVL(Base_Amount,0)),
                   -1, NULL,
                    NVL(Base_Amount,0)),
                DECODE(SIGN(NVL(Amount,0)),
                   -1, NULL,
                    0, DECODE(SIGN(NVL(Acctd_Amount, Amount)),
                               -1, NULL,
                               NVL(NVL2(Min_Acct_Unit,ROUND(Acctd_Amount/Min_Acct_Unit)*
                                     Min_Acct_Unit, ROUND(Acctd_Amount, Precision)), Amount)),
                    NVL(NVL2(Min_Acct_Unit,ROUND(Acctd_Amount/Min_Acct_Unit)*
                         Min_Acct_Unit, ROUND(Acctd_Amount, Precision)), Amount)))) Accounted_Dr,
         Ref_Ae_Header_ID,
         Accounting_Line_Code,
         'S' Accounting_Line_Type_Code,
         Merge_Duplicate_Code, --changed by abhsaxen for bug#9073033
	 Tax_Line_id,    -- 7289100 changes
         Summary_Tax_Line_ID,
         Detail_Tax_Dist_ID,
         Row_Number() OVER (PARTITION BY AE_Header_ID ORDER BY AE_Line_Num,
                   Invoice_Line_Number, Distribution_Line_Number) Temp_Line_Num,
         Ref_Event_ID,
         UPG_Batch_ID,
         'S' Line_Definition_Owner_Code,
         'ACCRUAL_INVOICES_ALL' Line_Definition_Code,
         'INVOICES' Event_Class_Code,
         'INVOICES_ALL' Event_Type_Code
  FROM  (/* bug#6660487 added hint for FC  */
         /* bug#7289100 added hit for zrd */
         SELECT /*+ ordered rowid(ai) swap_join_inputs (upg) swap_join_inputs(FC)
                    no_expand use_hash(FC,upg)
                    use_nl_with_index (xte, xla_transaction_entities_n1)
                    use_nl_with_index (xle, xla_events_u2)
                    use_nl_with_index (aeh, xla_ae_headers_n2)
                    use_nl_with_index (ael, xla_ae_lines_u1)
                    use_nl_with_index (aid, ap_invoice_distributions_n27)
		    use_nl_with_index (zrd,ZX_REC_NREC_DIST_U1) */
                AEH.Event_ID,
                AEH.AE_Header_ID,
                AEL.AE_Line_Num,
                AID.Invoice_Distribution_ID,
                AID.Stat_Amount,
                AID.Amount Amount,
                NVL(AID.Base_Amount, Amount) Base_Amount,
                --AID.Amount * AEL.Currency_Conversion_Rate Acctd_Amount,
		decode(GL.ledger_category_code, 'PRIMARY', NVL(AID.base_amount, AID.Amount), AID.Amount * AEL.Currency_Conversion_Rate) Acctd_Amount, --bug8370714
                AEH.AE_Header_ID Ref_AE_Header_ID,
                'AP_LIAB_INV' Accounting_Line_Code,
		ZRD.Tax_Line_id,    -- 7289100 changes
                AID.Summary_Tax_Line_ID,
                AID.Detail_Tax_Dist_ID,
                AEH.Event_ID Ref_Event_ID,
                AEL.Upg_Batch_ID,
                AID.Invoice_Line_Number,
                AID.Distribution_Line_Number,
                AID.Line_Type_Lookup_Code,
                FC.Minimum_Accountable_Unit Min_Acct_Unit,
                FC.Precision Precision,
               'A' Merge_Duplicate_Code  --added by abhsaxen for bug#9073033
         FROM   AP_Invoices_All AI,
                XLA_Upgrade_Dates UPG,
                XLA_Transaction_Entities_upg XTE,
                XLA_Events XLE,
                -- AP_Accounting_Events_All AAE,
                XLA_AE_Headers AEH,
                XLA_AE_Lines AEL,
		        FND_Currencies FC,  /* bug#6660487 changed the position for FND_Currencies  */
                AP_Invoice_Distributions_All AID
		,ZX_Rec_Nrec_Dist ZRD   -- 7289100 changes
		,GL_Ledgers GL  --bug8370714
         WHERE  AI.rowid between p_start_rowid and p_end_rowid
         AND    AI.Set_Of_Books_ID = UPG.Ledger_ID
         AND    TRUNC(AI.GL_Date) BETWEEN UPG.Start_Date AND UPG.End_Date
         -- AND    AI.Invoice_ID = AAE.Source_ID
         -- AND    AAE.Source_Table = 'AP_INVOICES'
         -- AND    AAE.AX_Accounted_Flag IS NULL
         -- AND    AAE.Event_Type_Code NOT IN ('PREPAYMENT APPLICATION',
         --                                    'PREPAYMENT UNAPPLICATION')
         -- AND    AAE.Accounting_Event_ID = AEH.Event_ID
         AND    XTE.Application_ID = 200
         AND    AI.Set_Of_Books_ID = XTE.Ledger_ID
	 AND    AEH.ledger_id = GL.ledger_id    --bug8370714
         AND    XTE.Entity_Code = 'AP_INVOICES'
         AND    AI.Invoice_ID = NVL(XTE.Source_ID_Int_1, -99)
         AND    XTE.Entity_ID = XLE.Entity_ID
         AND    XLE.Application_ID = 200
	 AND    XLE.Upg_Batch_ID IS NOT NULL
         AND    XLE.Event_Type_Code NOT IN ('PREPAYMENT APPLIED',
                                            'PREPAYMENT UNAPPLIED')
         AND    XLE.Event_ID = AEH.Event_ID
         AND    AEH.Application_ID = 200
         AND    AEL.AE_Header_ID = AEH.AE_Header_ID
         AND    AEL.Application_ID = 200
         AND    AEL.Source_Table = 'AP_INVOICES'
         AND    AEL.Accounting_Class_Code IN ('LIABILITY')
         AND    AID.Invoice_ID = AEL.Source_ID
         AND    AID.Invoice_ID = AI.Invoice_ID
         AND    AID.Accounting_Event_ID = XLE.Event_ID
         AND    AID.Line_Type_Lookup_Code <> 'PREPAY'
         AND    AID.Prepay_Tax_Parent_ID IS NULL
         AND    AEL.Account_Overlay_Source_ID IS NULL
         -- bug 8730212
         --AND    AEL.currency_code = FC.Currency_Code
         AND    GL.currency_code = FC.Currency_Code
	 /* 7289100 changes start */
	 AND    ZRD.Rec_Nrec_Tax_Dist_ID (+) = AID.Detail_Tax_Dist_ID
	 AND    ZRD.Application_id (+) = 200
	 AND    ZRD.Entity_Code (+) = 'AP_INVOICES'
         -- bug 8535401
         AND    XLE.upg_batch_id IS NOT NULL
         AND    XLE.upg_batch_id <> -9999
         AND    AEH.upg_batch_id IS NOT NULL
         AND    AEH.upg_batch_id <> -9999
	 /* 7289100 changes end */
         UNION ALL            /* bug#7289100 added hit for zrd */
         SELECT /*+ ordered rowid(ai) swap_join_inputs (upg) swap_join_inputs(FC)
                    no_expand use_hash(FC,upg)
                    use_nl_with_index (xte, xla_transaction_entities_n1)
                    use_nl_with_index (xle, xla_events_u2)
                    use_nl_with_index (aeh, xla_ae_headers_n2)
                    use_nl_with_index (ael, xla_ae_lines_u1)
                    use_nl_with_index (aid, ap_invoice_distributions_n26)
		    use_nl_with_index (zrd,ZX_REC_NREC_DIST_U1) */
                AEH.Event_ID,
                AEH.AE_Header_ID,
                AEL.AE_Line_Num,
                AID.Invoice_Distribution_ID,
                AID.Stat_Amount,
                AID.Amount Amount,
                NVL(AID.Base_Amount, Amount) Base_Amount,
                --AID.Amount * AEL.Currency_Conversion_Rate Acctd_Amount,
		decode(GL.ledger_category_code, 'PRIMARY', NVL(AID.base_amount, AID.Amount), AID.Amount * AEL.Currency_Conversion_Rate) Acctd_Amount, --bug8370714
                AEH.AE_Header_ID Ref_AE_Header_ID,
                'AP_LIAB_INV' Accounting_Line_Code,
		ZRD.Tax_Line_id,    -- 7289100 changes
                AID.Summary_Tax_Line_ID,
                AID.Detail_Tax_Dist_ID,
                AEH.Event_ID Ref_Event_ID,
                AEL.Upg_Batch_ID,
                AID.Invoice_Line_Number,
                AID.Distribution_Line_Number,
                AID.Line_Type_Lookup_Code,
                FC.Minimum_Accountable_Unit Min_Acct_Unit,
                FC.Precision Precision,
               'A' Merge_Duplicate_Code  --added by abhsaxen for bug#9073033
         FROM   AP_Invoices_All AI,
                XLA_Upgrade_Dates UPG,
                XLA_Transaction_Entities_upg XTE,
                XLA_Events XLE,
                -- AP_Accounting_Events_All AAE,
                XLA_AE_Headers AEH,
                XLA_AE_Lines AEL,
		        FND_Currencies FC,  /* bug#6660487 changed the position for FND_Currencies  */
                AP_Invoice_Distributions_All AID
		,ZX_Rec_Nrec_Dist ZRD   -- 7289100 changes
		,GL_Ledgers GL  --bug8370714
         WHERE  AI.rowid between p_start_rowid and p_end_rowid
         AND    AI.Set_Of_Books_ID = UPG.Ledger_ID
         AND    TRUNC(AI.GL_Date) BETWEEN UPG.Start_Date AND UPG.End_Date
         -- AND    AI.Invoice_ID = AAE.Source_ID
         -- AND    AAE.Source_Table = 'AP_INVOICES'
         -- AND    AAE.AX_Accounted_Flag IS NULL
         -- AND    AAE.Event_Type_Code NOT IN ('PREPAYMENT APPLICATION',
         --                                    'PREPAYMENT UNAPPLICATION')
         -- AND    AAE.Accounting_Event_ID = AEH.Event_ID
         AND    XTE.Application_ID = 200
         AND    AI.Set_Of_Books_ID = XTE.Ledger_ID
	 AND    AEH.ledger_id = GL.ledger_id    --bug8370714
         AND    XTE.Entity_Code = 'AP_INVOICES'
         AND    AI.Invoice_ID = NVL(XTE.Source_ID_Int_1,-99)
         AND    XTE.Entity_ID = XLE.Entity_ID
         AND    XLE.Application_ID = 200
	 AND    XLE.Upg_Batch_ID IS NOT NULL
         AND    XLE.Event_Type_Code NOT IN ('PREPAYMENT APPLIED',
                                            'PREPAYMENT UNAPPLIED')
         AND    XLE.Event_ID = AEH.Event_ID
         AND    AEH.Application_ID = 200
         AND    AEL.AE_Header_ID = AEH.AE_Header_ID
         AND    AEL.Application_ID = 200
         AND    AEL.Source_Table = 'AP_INVOICES'
         AND    AEL.Accounting_Class_Code IN ('LIABILITY')
         AND    AID.Invoice_ID = AEL.Source_ID
         AND    AID.Invoice_ID = AI.Invoice_ID
         AND    AID.Accounting_Event_ID = XLE.Event_ID
         AND    AID.Line_Type_Lookup_Code <> 'PREPAY'
         AND    AID.Prepay_Tax_Parent_ID IS NULL
         AND    AEL.Account_Overlay_Source_ID = AID.Old_Distribution_ID
         -- bug 8730212
         --AND    AEL.Currency_Code = FC.Currency_Code
         AND    GL.currency_code = FC.currency_code
	 /* 7289100 changes start */
	 AND    ZRD.Rec_Nrec_Tax_Dist_ID (+) = AID.Detail_Tax_Dist_ID
	 AND    ZRD.Application_id (+) = 200
	 AND    ZRD.Entity_Code (+) = 'AP_INVOICES'
	 /* 7289100 changes end */
         -- bug 8535401
         AND    XLE.upg_batch_id IS NOT NULL
         AND    XLE.upg_batch_id <> -9999
         AND    AEH.upg_batch_id IS NOT NULL
         AND    AEH.upg_batch_id <> -9999
		 UNION ALL
	      /* bug#6660487 added the hint for FC  */
	      /* bug#6914954 modified the hint aid1 */
	      /* bug#7289100 added hit for zrd */
         SELECT /*+ ordered rowid(ai) swap_join_inputs (upg) swap_join_inputs(FC)
                    use_nl_with_index (xte, xla_transaction_entities_n1)
                    use_nl_with_index (xle, xla_events_u2)
                    use_nl_with_index (aeh, xla_ae_headers_n2)
                    use_nl_with_index (ael, xla_ae_lines_u1)
                    use_nl_with_index (aid1, ap_invoice_dists_arch_u2)
                    use_nl_with_index (aid, ap_invoice_distributions_n26)
		    use_nl_with_index (zrd,ZX_REC_NREC_DIST_U1) */
                AEH.Event_id,
                AEH.AE_Header_ID,
                AEL.AE_Line_Num,
                AID.Invoice_Distribution_ID,
                AID.Stat_Amount,
                AID.Amount Amount,
                NVL(AID.Base_Amount, AID.Amount) Base_Amount,
                --AID.Amount * AEL.Currency_Conversion_Rate Acctd_Amount,
		decode(GL.ledger_category_code, 'PRIMARY', NVL(AID.base_amount, AID.Amount), AID.Amount * AEL.Currency_Conversion_Rate) Acctd_Amount, --bug8370714
                AEH.AE_Header_ID Ref_AE_Header_ID,
                DECODE(AID.Line_Type_Lookup_Code, 'ITEM', 'AP_ITEM_EXPENSE',
                          'FREIGHT', 'AP_FREIGHT_EXPENSE', 'MISCELLANEOUS',
                          'AP_MISC_EXPENSE', 'REC_TAX', 'AP_RECOV_TAX', 'NONREC_TAX',
                          'AP_NON_RECOV_TAX', 'AWT', 'AP_WITHHOLD_TAX', 'TIPV',
                          'AP_INV_PRICE_VAR', 'TERV', 'AP_TAX_EX_RATE_VAR',
                          'IPV', 'AP_INV_PRICE_VAR', 'ERV', 'AP_EX_RATE_VAR') ||
                  DECODE(AI.Invoice_Type_Lookup_Code, 'CREDIT MEMO', '_CM',
                            'DEBIT MEMO', '_DM', 'PREPAYMENT', '_PREPAY', '_INV')
                  Accounting_Line_Code,
		ZRD.Tax_Line_id,    -- 7289100 changes
                AID.Summary_Tax_Line_ID,
                AID.Detail_Tax_Dist_ID,
                AEH.Event_ID Ref_Event_ID,
                AEL.Upg_Batch_ID,
                AID.Invoice_Line_Number,
                AID.Distribution_Line_Number,
                AID.Line_Type_Lookup_Code,
                FC.Minimum_Accountable_Unit Min_Acct_Unit,
                FC.Precision Precision,
                CASE
                   DECODE(AID.Line_Type_Lookup_Code,'NONREC_TAX','AP_NON_RECOV_TAX',
                          AID.Line_Type_Lookup_Code)||'_INV'
                WHEN 'AP_NON_RECOV_TAX_INV' THEN
                  'W'
                 ELSE
                  'A'
                 END
                MERGE_DUPLICATE_CODE -- changed by abhsaxen for bug 9073033
         FROM   AP_Invoices_All AI,
                XLA_Upgrade_Dates UPG,
                XLA_Transaction_Entities_upg XTE,
                XLA_Events XLE,
                -- AP_Accounting_Events_All AAE,
                XLA_AE_Headers AEH,
                XLA_AE_Lines AEL,
        		FND_Currencies FC,  /* bug#6660487 changed the position for FC */
                AP_Inv_Dists_Source AID1,
                AP_Invoice_Distributions_All AID
		,ZX_Rec_Nrec_Dist ZRD   -- 7289100 changes
		,GL_Ledgers GL  --bug8370714
         WHERE  AI.rowid between p_start_rowid and p_end_rowid
         AND    AI.Set_Of_Books_ID = UPG.Ledger_ID
         AND    TRUNC(AI.GL_Date) BETWEEN UPG.Start_Date AND UPG.End_Date
         -- AND    AI.Invoice_ID = AAE.Source_ID
         -- AND    AAE.Source_Table = 'AP_INVOICES'
         -- AND    AAE.AX_Accounted_Flag IS NULL
         -- AND    AAE.Event_Type_Code NOT IN ('PREPAYMENT APPLICATION',
         --                                    'PREPAYMENT UNAPPLICATION')
         -- AND    AAE.Accounting_Event_ID = AEH.Event_ID
         AND    XTE.Application_ID = 200
         AND    AI.Set_Of_Books_ID = XTE.Ledger_ID
	 AND    AEH.ledger_id = GL.ledger_id    --bug8370714
         AND    XTE.Entity_Code = 'AP_INVOICES'
         AND    AI.Invoice_ID = NVL(XTE.Source_ID_Int_1,-99)
         AND    XTE.Entity_ID = XLE.Entity_ID
         AND    XLE.Application_ID = 200
	 AND    XLE.Upg_Batch_ID IS NOT NULL
         AND    XLE.Event_Type_Code NOT IN ('PREPAYMENT APPLIED',
                                            'PREPAYMENT UNAPPLIED')
         AND    XLE.Event_ID = AEH.Event_ID
         AND    AEH.Application_ID = 200
         AND    AEL.AE_Header_ID = AEH.AE_Header_ID
         AND    AEL.Application_ID = 200
         AND    AEL.Source_Table = 'AP_INVOICE_DISTRIBUTIONS'
         AND    AEL.Accounting_Class_Code IN ('ACCRUAL', 'ITEM EXPENSE', 'IPV',
                          'EXCHANGE_RATE_VARIANCE', 'FREIGHT', 'NRTAX', 'AWT', 'RTAX',
                          'PREPAID_EXPENSE','CHARGE') --Bug 7432304 added CHARGE
         AND    AID.Invoice_id = AI.Invoice_id
         AND    AID1.Invoice_ID = AI.Invoice_ID
         AND  ((DECODE(AEL.Accounting_Class_Code, 'ACCRUAL', 'ITEM',
                          'ITEM EXPENSE', 'ITEM', 'NRTAX', 'NONREC_TAX', 'RTAX', 'REC_TAX',
                          'EXCHANGE_RATE_VARIANCE', 'ERV', 'PREPAID_EXPENSE', 'ITEM','CHARGE','ITEM',/*Bug 7432304 added in decode CHARGE to ITEM*/
                          AEL.Accounting_Class_Code) =
                DECODE(AID.Line_Type_Lookup_Code,
                   'ERV',DECODE(AEL.Description, 'R11.5 Upgrade', 'ERV',
                       DECODE(AEL.Accounting_Class_Code, 'ACCRUAL', 'ERV',
                         DECODE(NVL(AID1.Rate_Var_Code_Combination_ID, AID.Dist_Code_Combination_ID),
                           AID1.Dist_Code_Combination_ID, 'ITEM', 'ERV'))),
                   'TERV', DECODE(AEL.Description, 'R11.5 Upgrade', 'ERV',
                       DECODE(AEL.Accounting_Class_Code, 'ACCRUAL', 'ERV',
                         DECODE(NVL(AID1.Rate_Var_Code_Combination_ID, AID1.Dist_Code_Combination_ID),
                           AID1.Dist_Code_Combination_ID, 'ITEM', 'ERV'))),
                   'IPV', DECODE(AEL.Description, 'R11.5 Upgrade', 'IPV',
                       DECODE(AEL.Accounting_Class_Code, 'ACCRUAL', 'IPV',
                         DECODE(NVL(AID1.Price_Var_Code_Combination_ID, AID1.Dist_Code_Combination_ID),
                           AID1.Dist_Code_Combination_ID, 'ITEM', 'IPV'))),
                   'TIPV', DECODE(AEL.Description, 'R11.5 Upgrade', 'IPV',
                       DECODE(AEL.Accounting_Class_Code, 'ACCRUAL', 'IPV',
                         DECODE(NVL(AID1.Price_Var_Code_Combination_ID, AID1.Dist_Code_Combination_ID),
                           AID1.Dist_Code_Combination_ID, 'ITEM', 'IPV'))),
                   'MISCELLANEOUS', 'ITEM', AID.Line_Type_Lookup_Code)))
         AND    AEL.Source_ID = AID1.Invoice_Distribution_ID
         AND    AID1.Invoice_Distribution_ID = AID.Old_Distribution_ID
         -- bug 8730212
         -- AND    AEL.Currency_Code = FC.Currency_Code
         AND    GL.currency_code = FC.currency_code
	 /* 7289100 changes start */
	 AND    ZRD.Rec_Nrec_Tax_Dist_ID (+) = AID.Detail_Tax_Dist_ID
	 AND    ZRD.Application_id (+) = 200
	 AND    ZRD.Entity_Code (+) = 'AP_INVOICES'
	 /* 7289100 changes end */
         -- bug 8535401
         AND    XLE.upg_batch_id IS NOT NULL
         AND    XLE.upg_batch_id <> -9999
         AND    AEH.upg_batch_id IS NOT NULL
         AND    AEH.upg_batch_id <> -9999
	 );



  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_INVOICE_DIST_LINKS',
                    'CREATE_INVOICE_DIST_LINKS(-)');
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    AP_Debug_Pkg.Print('Y', 'Invoices: p_start_rowid:' ||p_start_rowid ||
                            ' p_end_rowid:'||p_end_rowid);
    AP_Debug_Pkg.Print('Y', 'Error: '||sqlcode||': '||sqlerrm);

    RAISE;
END Create_Invoice_Dist_Links;


------------------------------------------------------------------
-- Procedure CREATE_PREPAY_DIST_LINKS
-- Purpose
-- This procedure CREATE_PREPAY_DIST_LINKS creates prepayment appl
-- distributions and the distribution links
------------------------------------------------------------------
PROCEDURE Create_Prepay_Dist_Links
                (p_start_rowid           rowid,
                 p_end_rowid             rowid,
                 p_calling_sequence   VARCHAR2)  IS


l_curr_calling_sequence         VARCHAR2(2000);

BEGIN

  -- Update the calling sequence
  --
  l_curr_calling_sequence := 'Create_Prepay_Dist_Links<-'||P_calling_sequence;
  --

  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_PREPAY_DIST_LINKS',
                    'CREATE_PREPAY_DIST_LINKS(+)');
  END IF;

  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_PREPAY_DIST_LINKS',
                    'Insert into AP_Prepay_History_All');
  END IF;

  --Bug 8725986: Insert statement same as of apidstln.sql version 120.5.12000000.15
INSERT INTO AP_Prepay_History_All
        (PREPAY_HISTORY_ID,
         PREPAY_INVOICE_ID,
         PREPAY_LINE_NUM,
         ACCOUNTING_EVENT_ID,
         HISTORICAL_FLAG,
         INVOICE_ID,
         ORG_ID,
         POSTED_FLAG,
         RELATED_PREPAY_APP_EVENT_ID,
         TRANSACTION_TYPE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         CREATED_BY,
         CREATION_DATE,
         INVOICE_LINE_NUMBER,
         ACCOUNTING_DATE)
  SELECT /*+ ordered use_nl_with_index(AIL,AP_INVOICE_LINES_U1) */
         ap_prepay_history_s.nextval,
         AIL.Prepay_Invoice_ID,
         AIL.Prepay_Line_Number,
         APH.Accounting_Event_ID,
         'Y',
         APH.Invoice_ID,
         APH.Org_ID,
         APH.Posted_Flag,
         APH.Accounting_Event_ID,
         decode(sign(APH.amount), -1, 'PREPAYMENT APPLIED',
                       'PREPAYMENT UNAPPLIED') Transaction_Type,
         FND_GLOBAL.User_ID Last_Updated_By,
         Sysdate Last_Update_Date,
         FND_GLOBAL.Conc_Login_ID Last_Update_Login,
         FND_GLOBAL.User_ID Created_By,
         Sysdate Creation_Date,
         APH.Invoice_Line_Number,
         APH.Accounting_Date
  FROM
        (SELECT /*+ ordered rowid(AI) swap_join_inputs(UPG)
                    use_nl_with_index(AID,AP_INVOICE_DISTRIBUTIONS_U1) */
                AID.Accounting_Event_ID,
                AID.Invoice_ID,
                AID.Org_ID,
                AID.Posted_Flag,
                AID.Amount,
                AID.Invoice_Line_Number,
                AID.Accounting_Date,
                Row_Number() OVER (PARTITION BY AID.Accounting_Event_ID, AID.Invoice_ID
                                   ORDER BY Invoice_Line_Number) RNum
         FROM   AP_Invoices_All AI,
                XLA_Upgrade_Dates UPG,
                AP_Invoice_Distributions_All AID
         WHERE  AI.rowid between p_start_rowid and p_end_rowid
         AND    TRUNC(AI.GL_Date) BETWEEN UPG.Start_Date and UPG.End_Date
         AND    AI.Set_Of_Books_ID = UPG.Ledger_ID
         AND    AID.Invoice_ID = AI.Invoice_ID
         AND    AID.Line_Type_Lookup_Code = 'PREPAY'
         AND    AID.Accounting_Event_ID IS NOT NULL) APH,
         AP_Invoice_Lines_All AIL
  WHERE  AIL.Invoice_ID = APH.Invoice_ID
  AND    AIL.Line_Number = APH.Invoice_Line_Number
  AND    AIL.historical_flag = 'Y'   --bug8535401
  AND    AIL.Prepay_Invoice_ID IS NOT NULL
  AND    APH.RNum = 1;


  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_PREPAY_DIST_LINKS',
                    'Insert into AP_Prepay_App_Dists');
  END IF;

  --Bug 8725986: Insert statement same as of apidstln.sql version 120.5.12000000.15
INSERT INTO AP_Prepay_App_Dists
        (PREPAY_APP_DIST_ID,
         PREPAY_DIST_LOOKUP_CODE,
         INVOICE_DISTRIBUTION_ID,
         PREPAY_APP_DISTRIBUTION_ID,
         ACCOUNTING_EVENT_ID,
         PREPAY_HISTORY_ID,
         PA_ADDITION_FLAG,
         AMOUNT,
         BASE_AMOUNT,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         CREATED_BY,
         CREATION_DATE)
  SELECT AP_Prepay_App_Dists_S.Nextval,
         Prepay_Dist_Lookup_Code,
         Invoice_Distribution_ID,
         Prepay_App_Distribution_ID,
         Accounting_Event_ID,
         Prepay_History_ID,
         PA_Addition_Flag,
         DECODE(Rank_Num, Dist_Count, Entered_Amount + Delta_Entered, Entered_Amount) Amount,
         DECODE(Rank_Num, Dist_Count, Accounted_Amount + Delta_Accounted,
                   Accounted_Amount) Base_Amount,
         FND_GLOBAL.User_ID Last_Updated_By,
         SYSDATE Last_Update_Date,
         FND_GLOBAL.Conc_Login_ID Last_Update_Login,
         FND_GLOBAL.User_ID Created_By,
         SYSDATE Creation_Date
  FROM  (
         SELECT Prepay_Dist_Lookup_Code,
                Invoice_Distribution_ID,
                Prepay_App_Distribution_ID,
                Accounting_Event_ID,
                Prepay_History_ID,
                PA_Addition_Flag,
                NVL2(Minimum_Accountable_Unit, ROUND(Entered_Amt/Minimum_Accountable_Unit)*
                     Minimum_Accountable_Unit, ROUND(Entered_Amt, Precision)) Entered_Amount,
                NVL2(Minimum_Accountable_Unit, ROUND(Accounted_Amt/Minimum_Accountable_Unit)*
                     Minimum_Accountable_Unit, ROUND(Accounted_Amt, Precision)) Accounted_Amount,
                NVL2(Minimum_Accountable_Unit, ROUND(Line_Entered_Amt/Minimum_Accountable_Unit)*
                     Minimum_Accountable_Unit, Line_Entered_Amt) -
                       SUM(NVL2(Minimum_Accountable_Unit, ROUND(Entered_Amt/Minimum_Accountable_Unit)*
                                Minimum_Accountable_Unit, ROUND(Entered_Amt, Precision)))
                          OVER (Partition By Invoice_ID, AE_Header_ID, Prepay_Dist_Lookup_Code,
                                             Partkey) Delta_Entered,
                NVL2(Minimum_Accountable_Unit, ROUND(Line_Accounted_Amt/Minimum_Accountable_Unit)*
                     Minimum_Accountable_Unit, Line_Accounted_Amt) -
                       SUM(NVL2(Minimum_Accountable_Unit, ROUND(Accounted_Amt/Minimum_Accountable_Unit)*
                                Minimum_Accountable_Unit, ROUND(Accounted_Amt, Precision)))
                         OVER (Partition By Invoice_ID, AE_Header_ID, Prepay_Dist_Lookup_Code,
                                             Partkey) Delta_Accounted,
                RANK() OVER (Partition By Invoice_ID, AE_Header_ID, Prepay_Dist_Lookup_Code, Partkey
                                Order By Amount, Distribution_Line_Number) Rank_Num,
                COUNT(*) OVER (Partition By Invoice_ID, AE_Header_ID, Prepay_Dist_Lookup_Code,
                                            Partkey) Dist_Count
         FROM  (
	          /* bug#6660487 added hint for fc */
		  /* bug#6914954 modified the hint aid1 */
                SELECT /*+ ordered use_hash (asp) rowid(ai)
                           swap_join_inputs (asp) swap_join_inputs (upg) swap_join_inputs (fc)
                           use_nl_with_index (xte, xla_transaction_entities_n1)
                           use_nl_with_index (xle, xla_events_u2)
                           use_nl_with_index (aph, ap_prepay_history_n1)
                           use_nl_with_index (aid, ap_invoice_distributions_n27)
                           use_nl_with_index (aid1, ap_invoice_dists_arch_u2)
                           use_nl_with_index (aeh, xla_ae_headers_n2)
                           use_nl_with_index (ael, xla_ae_lines_u1)
                           use_nl_with_index (aidp, ap_invoice_distributions_n26) */
                       DECODE(AEL.Accounting_Class_Code, 'RTAX',
                                 'PREPAY APPL REC TAX', 'NRTAX', 'PREPAY APPL NONREC TAX',
                                 'PREPAY APPL') Prepay_Dist_Lookup_Code,
                       AID.Invoice_Distribution_ID Invoice_Distribution_ID,
                       AIDP.Invoice_Distribution_ID Prepay_App_Distribution_ID,
                       XLE.Event_ID Accounting_Event_ID,
                       AEH.AE_Header_ID AE_Header_ID,
                       APH.Prepay_History_ID Prepay_History_ID,
                       AID.PA_Addition_Flag PA_Addition_Flag,
                       AI.Invoice_ID Invoice_ID,
                       AID.Amount Amount,
                       AID.Distribution_Line_Number Distribution_Line_Number,
                       NVL2(AEL.Account_Overlay_Source_ID, AID1.Invoice_Distribution_ID, 1) Partkey,
                       FC.Minimum_Accountable_Unit Minimum_Accountable_Unit,
                       FC.Precision Precision,
                       NVL(AEL.Accounted_Cr, 0) - NVL(AEL.Accounted_Dr, 0) Line_Accounted_Amt,
                       NVL(AEL.Entered_Cr, 0) - NVL(AEL.Entered_Dr, 0) Line_Entered_Amt,
                       (NVL(AEL.Accounted_Cr, 0) - NVL(AEL.Accounted_Dr, 0)) *
                          NVL(AID.Base_amount, AID.Amount) / NVL2(AEL.Account_Overlay_Source_ID,
                              DECODE(NVL(AID1.base_amount, AID1.amount), 0, 1,
                                     NVL(AID1.Base_Amount, AID1.Amount)),
                              DECODE(NVL(AI.Base_Amount, AI.Invoice_Amount), 0, 1,
                                     NVL(AI.Base_Amount, AI.Invoice_Amount))) Accounted_Amt,
                       (NVL(AEL.Entered_Cr, 0) - NVL(AEL.Entered_Dr, 0)) * AID.Amount /
                            NVL2(AEL.Account_Overlay_Source_ID, DECODE(AID1.Amount,0,1,AID1.Amount),
                                 DECODE(AI.Invoice_Amount,0,1,AI.Invoice_Amount)) Entered_Amt
                FROM   AP_Invoices_All AI,
                       XLA_Upgrade_Dates UPG,
                       AP_System_Parameters_All ASP,
                       FND_Currencies FC,/* bug#6660487 changed the order of FC */
                       XLA_Transaction_Entities_upg XTE,
                       XLA_Events XLE,
                       -- AP_Accounting_Events_All AAE,
                       AP_Prepay_History_All APH,
                       AP_Invoice_Distributions_All AID,
                       AP_Inv_Dists_Source AID1,
                       XLA_AE_Headers AEH,
                       XLA_AE_Lines AEL,
                       AP_Invoice_Distributions_All AIDP
                WHERE  AI.rowid between p_start_rowid and p_end_rowid
                AND    AI.Set_Of_Books_ID = UPG.Ledger_ID
                AND    TRUNC(AI.GL_Date) BETWEEN UPG.Start_Date AND UPG.End_Date
                AND    AI.Org_ID = ASP.Org_ID
                -- AND    AI.Invoice_ID = AAE.Source_ID
                -- AND    AAE.Source_Table = 'AP_INVOICES'
                -- AND    AAE.AX_Accounted_Flag IS NULL
                -- AND    AAE.Event_Type_Code IN ('PREPAYMENT APPLICATION', 'PREPAYMENT UNAPPLICATION')
                AND    XTE.Application_ID = 200
                AND    AI.Set_Of_Books_ID = XTE.Ledger_ID
                AND    XTE.Entity_Code = 'AP_INVOICES'
                AND    AI.Invoice_ID = NVL(XTE.Source_ID_Int_1,-99)
                AND    XTE.Entity_ID = XLE.Entity_ID
                AND    XLE.Application_ID = 200
		AND    XLE.Upg_Batch_ID IS NOT NULL
                AND    XLE.Event_Type_Code IN ('PREPAYMENT APPLIED',
                                               'PREPAYMENT UNAPPLIED')
                -- bug8535401
                AND    XLE.upg_batch_id IS NOT NULL
                AND    XLE.upg_batch_id <> -9999
                AND    AEH.upg_batch_id IS NOT NULL
                AND    AEH.upg_batch_id <> -9999
                AND    APH.historical_flag = 'Y'
                AND    AI.Invoice_ID = APH.Invoice_ID
                AND    XLE.Event_ID = APH.Accounting_Event_ID
                AND    AID.Invoice_ID = AI.Invoice_ID
                AND    AID.Line_Type_Lookup_Code <> 'PREPAY'
                AND    AID.Prepay_Tax_Parent_ID IS NULL
                AND    AID1.Invoice_ID = AI.Invoice_ID
                AND    AID1.Invoice_Distribution_ID = AID.Old_Distribution_ID
                AND    XLE.Event_ID = AEH.Event_ID
                AND    AEH.Application_ID = 200
                AND    AEH.Ledger_ID = ASP.Set_Of_Books_ID
                AND    AEH.AE_Header_ID = AEL.AE_Header_ID
                AND    AEL.Application_ID = AEH.Application_ID
                AND    AIDP.Accounting_Event_ID = APH.Accounting_Event_ID
                AND    AIDP.Old_Distribution_ID = AEL.Source_ID
                AND    AIDP.Accounting_Event_ID <> AID1.Accounting_Event_ID
                AND    AEL.Source_Table = 'AP_INVOICE_DISTRIBUTIONS'
                AND    AEL.Accounting_Class_Code IN ('PREPAID_EXPENSE', 'RTAX', 'NRTAX')
                AND    AID.Old_Distribution_ID = NVL(AEL.Account_Overlay_Source_ID,
                                                       AID.Old_Distribution_ID)
                AND    FC.Currency_Code = ASP.Base_Currency_Code));

  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_PREPAY_DIST_LINKS',
                    'Insert into Distribution Links for Prepayments');
  END IF;

  --Bug 8725986: Insert statement same as of apidstln.sql version 120.5.12000000.15
INSERT INTO XLA_Distribution_Links t1
        (APPLICATION_ID,
         EVENT_ID,
         AE_HEADER_ID,
         AE_LINE_NUM,
         SOURCE_DISTRIBUTION_TYPE,
         SOURCE_DISTRIBUTION_ID_NUM_1,
         STATISTICAL_AMOUNT,
         UNROUNDED_ENTERED_CR,
         UNROUNDED_ENTERED_DR,
         UNROUNDED_ACCOUNTED_CR,
         UNROUNDED_ACCOUNTED_DR,
         REF_AE_HEADER_ID,
         ACCOUNTING_LINE_CODE,
         ACCOUNTING_LINE_TYPE_CODE,
         MERGE_DUPLICATE_CODE,
         TEMP_LINE_NUM,
         REF_EVENT_ID,
         UPG_BATCH_ID,
         LINE_DEFINITION_OWNER_CODE,
         LINE_DEFINITION_CODE,
         EVENT_CLASS_CODE,
         EVENT_TYPE_CODE,
         APPLIED_TO_APPLICATION_ID, --Bug7169843 Starts
         APPLIED_TO_ENTITY_ID,
         APPLIED_TO_DIST_ID_NUM_1,
         GAIN_OR_LOSS_REF ) --Bug7169843 Ends
  SELECT /*+ ordered rowid(ai) swap_join_inputs (upg)
             use_nl_with_index (xte, xla_transaction_entities_n1)
             use_nl_with_index (xle, xla_events_u2)
             use_nl_with_index (apad, ap_prepay_app_dists_n3)
             use_nl_with_index (aid, ap_invoice_distributions_u2)
             use_nl_with_index (aeh, xla_ae_headers_n2)
             use_nl_with_index (ael, xla_ae_lines_u1) */
         200 Application_ID,
         AEH.Event_ID Accounting_Event_ID,
         AEH.AE_Header_ID AE_Header_ID,
         AEL.AE_Line_Num AE_Line_Num,
         'AP_PREPAY'  Source_Distribution_Type, --'AP_INV_DIST' Bug7169843
         APAD.Prepay_App_Dist_ID Source_Distribution_ID_Num_1,
         NULL Statistical_Amount,
         DECODE(SIGN(APAD.Amount), 1, APAD.Amount, NULL) Unrounded_Entered_Cr,
         DECODE(SIGN(APAD.Amount),-1, APAD.Amount, NULL) Unrounded_Entered_Dr,
         DECODE(SIGN(APAD.Base_Amount), 1, APAD.Base_Amount, NULL) Unrounded_Accounted_Cr,
         DECODE(SIGN(APAD.Base_Amount),-1, APAD.Base_Amount, NULL) Unrounded_Accounted_Dr,
         AEH.AE_Header_ID Ref_AE_Header_ID,
         DECODE(AEL.Accounting_Class_Code,
                'GAIN', 'AP_GAIN_PREPAY_APP', 'LOSS', 'AP_LOSS_PREPAY_APP',
                'LIABILITY', 'AP_LIAB_PREPAY_APP', 'PREPAID_EXPENSE',
                                              -- AP_LIABILITY_PREPAY_APP Bug7169843
                'AP_PREPAID_EXP_ACCR_PREPAY_APP', 'ROUNDING',
                'AP_FINAL_PMT_ROUND_PREPAY_APP', 'NRTAX',
                'AP_NRTAX_PREPAY_PAY_RATE_APP', 'RTAX', 'AP_RECOV_PREPAY_PAY_RATE_APP',
                'ACCRUAL', 'AP_ACCR_PREPAY_PAY_RATE_APP', 'ITEM EXPENSE',
                'AP_ITEM_PREPAY_PAY_RATE_APP',
                'EXCHANGE_RATE_VARIANCE', 'AP_EX_RATE_VAR_PREPAY_PAY_RATE',
                'IPV', 'AP_IPV_PREPAY_PAY_RATE_APP', 'NRTAX',
                'AP_NRTAX_PREPAY_PAY_RATE_APP', 'RTAX',
                'AP_RECOV_PREPAY_PAY_RATE_APP', 'FREIGHT',
                'AP_FREIGHT_PREPAY_PAY_RATE_APP', 'AP_ITEM_PREPAY_PAY_RATE_APP')
                Accounting_Line_Code,
         'S' Accounting_Line_Type_Code,
         'A' Merge_Duplicate_Code, --changed by abhsaxen for bug#9073033
         RANK() OVER (PARTITION BY AEH.AE_Header_ID
                      ORDER BY  AEL.AE_Line_Num,
                                APAD.Invoice_Distribution_ID,
                                APAD.Prepay_App_Distribution_ID,
                                APAD.Prepay_Dist_Lookup_Code) Temp_Line_Num,
         AEH.Event_ID Ref_Event_ID,
         AEL.Upg_Batch_ID,
         'S' Line_Definition_Owner_Code,
         'ACCRUAL_INVOICES_ALL' Line_Definition_Code,
         'INVOICES' Event_Class_Code,
         'INVOICES_ALL' Event_Type_Code,
         --Bug7169843 starts
         DECODE(AEL.Accounting_Class_Code, 'LIABILITY' ,200, null) APPLIED_TO_APPLICATION_ID,
         DECODE(AEL.Accounting_Class_Code, 'LIABILITY' ,XTE.Entity_ID, null) APPLIED_TO_ENTITY_ID,
         DECODE(AEL.Accounting_Class_Code, 'LIABILITY' ,AID.Invoice_Distribution_ID, null)
		                                APPLIED_TO_DIST_ID_NUM_1,
         '-2222' GAIN_OR_LOSS_REF --Bug7169843 ends
  FROM   AP_Invoices_All AI,
         XLA_Upgrade_Dates UPG,
         XLA_Transaction_Entities_upg XTE,
         XLA_Events XLE,
         -- AP_Accounting_Events_All AAE,
         AP_Prepay_App_Dists APAD,
         AP_Invoice_Distributions_All AID,
         XLA_AE_Headers AEH,
         XLA_AE_Lines AEL
  WHERE  AI.rowid between p_start_rowid and p_end_rowid
  AND    TRUNC(AI.GL_Date) BETWEEN UPG.Start_Date and UPG.End_Date
  AND    AI.Set_Of_Books_ID = UPG.Ledger_ID
  AND    AI.Invoice_ID = AID.Invoice_ID
  -- AND    AAE.Source_Table = 'AP_INVOICES'
  -- AND    AI.Invoice_ID = AAE.Source_ID
  -- AND    AAE.Accounting_Event_ID = AEH.Event_ID
  AND    XTE.Application_ID = 200
  AND    AI.Set_Of_Books_ID = XTE.Ledger_ID
  AND    XTE.Entity_Code = 'AP_INVOICES'
  AND    AI.Invoice_ID = NVL(XTE.Source_ID_Int_1,-99)
  AND    XTE.Entity_ID = XLE.Entity_ID
  AND    XLE.Application_ID = 200
  AND    XLE.Upg_Batch_ID IS NOT NULL
  AND    XLE.Event_Type_Code IN ('PREPAYMENT APPLIED',
                                 'PREPAYMENT UNAPPLIED')
  AND    XLE.Event_ID = AEH.Event_ID
  AND    AEH.Application_ID = 200
  -- AND    AAE.AX_Accounted_Flag IS NULL
  AND    AEL.AE_Header_ID = AEH.AE_Header_ID
  AND    AEL.Application_ID = 200
  AND    XLE.Event_ID = APAD.Accounting_Event_ID
  -- bug8535401
  AND    XLE.upg_batch_id IS NOT NULL
  AND    XLE.upg_batch_id <> -9999
  AND    AEH.upg_batch_id IS NOT NULL
  AND    AEH.upg_batch_id <> -9999
  AND    APAD.Invoice_Distribution_ID = AID.Invoice_Distribution_ID
  AND    AID.Old_Distribution_ID
                 = NVL(AEL.Account_Overlay_Source_ID, AID.Old_Distribution_ID);

  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_PREPAY_DIST_LINKS',
                    'CREATE_PREPAY_DIST_LINKS(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    AP_Debug_Pkg.Print('Y', 'Prepay: p_start_rowid:' ||p_start_rowid ||
                            ' p_end_rowid:'||p_end_rowid);
    AP_Debug_Pkg.Print('Y', 'Error: '||sqlcode||': '||sqlerrm);
    RAISE;

END Create_Prepay_Dist_Links;


------------------------------------------------------------------
-- Procedure Create_Payment_Dist_Links
-- Purpose
-- This procedure CREATE_PAYMENT_DIST_LINKS inserts the payment
-- distribution links
------------------------------------------------------------------
PROCEDURE Create_Payment_Dist_Links
                (p_start_rowid           rowid,
                 p_end_rowid             rowid,
                 p_calling_sequence   VARCHAR2)  IS

  l_curr_calling_sequence     VARCHAR2(2000);


BEGIN


  l_curr_calling_sequence := 'AP_XLA_UPGRADE_PKG.Create_Payment_Dist_Link<-'
                                       || p_calling_sequence;

  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_PAYMENT_DIST_LINKS',
                    'CREATE_PAYMENT_DIST_LINKS(+)');
  END IF;

  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_PAYMENT_DIST_LINKS',
                    'Insert into ap_payment_hist_dists');
  END IF;

  --Bug 8725986: Insert statement same as of appdstln.sql version 120.4.12000000.16
INSERT INTO ap_payment_hist_dists
        (PAYMENT_HIST_DIST_ID,
         ACCOUNTING_EVENT_ID,
         PAY_DIST_LOOKUP_CODE,
         INVOICE_DISTRIBUTION_ID,
         AMOUNT,
         PAYMENT_HISTORY_ID,
         INVOICE_PAYMENT_ID,
         CLEARED_BASE_AMOUNT,
         HISTORICAL_FLAG,
         MATURED_BASE_AMOUNT,
         PAID_BASE_AMOUNT,
         REVERSAL_FLAG,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         PA_ADDITION_FLAG)
	 /* bug#6662100 the query is modified to improve performance */
 SELECT  AP_Payment_Hist_Dists_S.Nextval,
         Accounting_Event_ID,
         Pay_Dist_Lookup_Code,
         Invoice_Distribution_ID,
         Decode(Rank_Num, Dist_Count, Entered_Amount + Delta_Entered, Entered_Amount) Amount,
         Payment_History_ID,
         Invoice_Payment_ID,
        (CASE
             WHEN (Accounting_Class_Code IN ('CASH', 'DISCOUNT') AND Recon_Accounting_Flag = 'Y')
               OR (Accounting_Class_Code IN ('BANK_CHG', 'BANK_ERROR')) THEN
                   DECODE(Rank_Num, Dist_Count, Accounted_Amount + Delta_Entered, Accounted_Amount)
             ELSE NULL
         END) Cleared_Base_Amount,
         'Y' Historical_Flag,
        (CASE
            WHEN (Accounting_Class_Code = 'CASH_CLEARING' AND
                  Future_Pay_Due_Date IS NOT NULL)
              OR (Accounting_Class_Code = 'CASH' AND
                  Future_Pay_Due_Date IS NOT NULL AND Recon_Accounting_Flag = 'N') THEN
                  DECODE(Rank_Num, Dist_Count, Accounted_Amount + Delta_Entered, Accounted_Amount)
            ELSE NULL
         END) Matured_Base_Amount,
        (CASE
            WHEN (Accounting_Class_Code IN ('CASH_CLEARING', 'DISCOUNT') AND
                  Future_Pay_Due_Date IS NULL)
              OR (Accounting_Class_Code IN ('CASH', 'DISCOUNT') AND
                  Future_Pay_Due_Date IS NULL AND Recon_Accounting_Flag = 'N')
              OR (Accounting_Class_Code = 'FUTURE_DATED_PMT') THEN
                  DECODE(Rank_Num, Dist_Count, Accounted_Amount + Delta_Entered, Accounted_Amount)
            ELSE NULL
         END) Paid_Base_Amount,
         Reversal_Flag,
         FND_GLOBAL.User_ID Created_By,
         Sysdate Creation_Date,
         Sysdate Last_Update_Date,
         FND_GLOBAL.User_ID Last_Updated_By,
         FND_GLOBAL.Conc_Login_ID Last_Update_Login,
         PA_Addition_Flag
  FROM  (SELECT Pay_Dist_Lookup_Code,
                Invoice_Distribution_ID,
                Accounting_Event_ID,
                Payment_History_ID,
                Invoice_Payment_ID,
                Accounting_Class_Code,
                PA_Addition_Flag,
                Reversal_Flag,
                Recon_Accounting_Flag,
                Future_Pay_Due_Date,
                NVL2(Minimum_Accountable_Unit,
		ROUND(Entered_Amt/Minimum_Accountable_Unit)* Minimum_Accountable_Unit, ROUND(Entered_Amt, Precision)) Entered_Amount,
                NVL2(Minimum_Accountable_Unit, ROUND(Accounted_Amt/Minimum_Accountable_Unit)*
                     Minimum_Accountable_Unit, ROUND(Accounted_Amt, Precision)) Accounted_Amount,
                NVL2(Minimum_Accountable_Unit, ROUND(Line_Entered_Amt/Minimum_Accountable_Unit)*
                     Minimum_Accountable_Unit, Line_Entered_Amt) - SUM(NVL2(Minimum_Accountable_Unit, ROUND(Entered_Amt/Minimum_Accountable_Unit)*
                              Minimum_Accountable_Unit, ROUND(Entered_Amt, Precision)))
                     OVER (Partition By Invoice_ID, AE_Header_ID, Pay_Dist_Lookup_Code, Partkey) Delta_Entered,
                NVL2(Minimum_Accountable_Unit, ROUND(Line_Accounted_Amt/Minimum_Accountable_Unit)*
                     Minimum_Accountable_Unit, Line_Accounted_Amt) - SUM(NVL2(Minimum_Accountable_Unit, ROUND(Accounted_Amt/Minimum_Accountable_Unit)*
                              Minimum_Accountable_Unit, ROUND(Accounted_Amt, Precision)))
                     OVER (Partition By Invoice_ID, AE_Header_ID, Pay_Dist_Lookup_Code, Partkey) Delta_Accounted,
                Rank() OVER (Partition By Invoice_ID, AE_Header_ID, Pay_Dist_Lookup_Code, Partkey
                             Order By Amount, Distribution_Line_Number) Rank_Num,
                Count(*) OVER (Partition By Invoice_ID, AE_Header_ID, Pay_Dist_Lookup_Code, Partkey) Dist_Count
         FROM 	(
		select /*+ ordered use_nl(aid1) */
			v2.*,
			v2.amount_aid amount,
		       DECODE(	v2.Account_Overlay_Source_ID,
		       		NULL,
				(NVL(v2.Accounted_Cr,0) - NVL(v2.Accounted_Dr,0))* NVL(v2.Base_Amount_aid, v2.Amount_aid)/
		              		DECODE(NVL(v2.Base_Amount_ai, v2.Invoice_Amount_ai), 0, 1, NVL(v2.Base_Amount_ai, v2.Invoice_Amount_ai)),
			      	(NVL(v2.Accounted_Cr,0) - NVL(v2.Accounted_Dr,0))* NVL(v2.Base_Amount_aid,v2.Amount_aid)/
			      		DECODE(	AID1.invoice_distribution_id,
						NULL, -- outer join check
						DECODE(NVL(v2.Base_Amount_aid,v2.Amount_aid), 0, 1, NVL(v2.Base_Amount_aid,v2.Amount_aid)),
						DECODE(NVL(AID1.Base_Amount,AID1.Amount), 0, 1, NVL(AID1.Base_Amount,AID1.Amount)))
			     ) Accounted_Amt,
		       DECODE(	v2.Account_Overlay_Source_ID,
		       		NULL,
		             	(NVL(v2.Entered_Cr,0) - NVL(v2.Entered_Dr,0))* v2.Amount_aid /
					DECODE(v2.Invoice_Amount_ai,0,1,v2.Invoice_Amount_ai),
			     	(NVL(v2.Entered_Cr,0) - NVL(v2.Entered_Dr,0))* v2.Amount_aid /
					DECODE(	AID1.invoice_distribution_id,
					        NULL, -- outer join check
						DECODE(v2.Amount_aid,0,1,v2.Amount_aid),
						DECODE(AID1.Amount,0,1,AID1.Amount))
			     ) Entered_Amt,
		       NVL2(v2.Account_Overlay_Source_ID,
		       		NVL(AID1.Invoice_Distribution_ID,v2.Invoice_Distribution_ID), 1) Partkey	--outer join
		from
	 	(
	 	select /*+ ordered use_nl_with_index(aid_b,AP_INVOICE_DISTRIBUTIONS_N27) no_merge */
			nvl(v1.Invoice_ID,AID_b.Invoice_ID) Invoice_ID,
			nvl(v1.Invoice_Distribution_ID,AID_b.Invoice_Distribution_ID) Invoice_Distribution_ID,
			nvl(v1.old_distribution_id,AID_b.old_distribution_id) old_distribution_id,
			nvl(v1.Distribution_Line_Number,AID_b.Distribution_Line_Number) Distribution_Line_Number,
			nvl(v1.Amount_aid,AID_b.Amount) Amount_aid,
			nvl(v1.Base_Amount_aid,AID_b.Base_Amount) Base_Amount_aid,
			nvl(v1.PA_Addition_Flag,AID_b.PA_Addition_Flag) PA_Addition_Flag,
		       v1.Accounting_Event_ID,
		       v1.Payment_History_ID,
		       v1.Invoice_Payment_ID,
		       v1.Pay_Dist_Lookup_Code,
		       v1.Future_Pay_Due_Date,
		       v1.Recon_Accounting_Flag,
		       v1.AE_Header_ID,
		       v1.Reversal_Flag,
		       v1.Accounting_Class_Code,
		       v1.Line_Entered_Amt,
		       v1.Line_Accounted_Amt,
		       v1.Minimum_Accountable_Unit,
		       v1.Precision,
		       v1.Account_Overlay_Source_ID,
		       v1.Accounted_Cr,
		       v1.Accounted_Dr,
		       v1.Entered_Cr,
		       v1.Entered_Dr,
		       v1.Base_Amount_ai,
		       v1.Invoice_Amount_ai
		from
		(SELECT /*+ ordered use_hash(asp, upg) rowid(ac) no_merge
		           swap_join_inputs (upg) swap_join_inputs (asp) swap_join_inputs(fc)
                           use_nl_with_index (xte, xla_transaction_entities_n1)
                           use_nl_with_index (xle, xla_events_u2)
			   use_nl_with_index (aeh, xla_ae_headers_n2)
			   use_nl_with_index (ael, xla_ae_lines_u1)
			   use_nl_with_index (aip, ap_invoice_payments_n2)
			   use_nl_with_index (aph, ap_payment_history_n2)
			   use_nl_with_index (aid_a, ap_invoice_distributions_n26) */
			AID_a.Invoice_ID,
			AID_a.Invoice_Distribution_ID,
			AID_a.old_Distribution_ID old_Distribution_ID,
			AID_a.Distribution_Line_Number,
			AID_a.Amount Amount_aid,
			AID_a.PA_Addition_Flag,
			AID_a.Base_amount Base_amount_aid,
		       XLE.Event_ID Accounting_Event_ID,
		       APH.Payment_History_ID,
		       AIP.Invoice_Payment_ID,
		       DECODE(AEL.Accounting_Class_Code, 'FUTURE_DATED_PMT', 'CASH',
			      'CASH_CLEARING', 'CASH', 'CASH', 'CASH', Accounting_Class_Code) Pay_Dist_Lookup_Code,
		       AC.Future_Pay_Due_Date,
		       ASP.Recon_Accounting_Flag,
		       AEH.AE_Header_ID,
		       AIP.Reversal_Flag,
		       AEL.Accounting_Class_Code,
		       NVL(AEL.Entered_Cr,0) - NVL(AEL.Entered_Dr,0) Line_Entered_Amt,
		       NVL(AEL.Accounted_Cr,0) - NVL(AEL.Accounted_Dr,0) Line_Accounted_Amt,
		       FC.Minimum_Accountable_Unit,
		       FC.Precision,
		       --AEL.Account_Overlay_Source_ID, /* AWT changes */
		       DECODE(AEL.ACCOUNTING_CLASS_CODE , 'AWT', AEL.SOURCE_ID ,
		                 ael.account_overlay_source_id) account_overlay_source_id,
		       AEL.Accounted_Cr,
		       AEL.Accounted_Dr,
		       AEL.Entered_Cr,
		       AEL.Entered_Dr,
		       AI.Base_Amount Base_Amount_ai,
		       AI.Invoice_Amount Invoice_Amount_ai,
		       AIP.invoice_ID invoice_id_aip
	        FROM   AP_Checks_All AC,
		       AP_System_Parameters_All ASP,
		       XLA_Upgrade_Dates UPG,
		       FND_Currencies FC,
                       XLA_Transaction_Entities_Upg XTE,
                       XLA_Events XLE,
		       AP_Invoice_Payments_All AIP,
		       AP_Invoices_All AI,
		       AP_Payment_History_All APH,
		       XLA_AE_Headers AEH,
		       XLA_AE_Lines AEL,
		       AP_Invoice_Distributions_All AID_a
		WHERE  AC.rowid BETWEEN p_start_rowid AND p_end_rowid
		AND    TRUNC(AC.Check_Date) BETWEEN UPG.Start_Date and UPG.End_Date
	        AND    ASP.Set_Of_Books_ID = UPG.Ledger_ID
        	AND    AC.Org_ID = ASP.Org_ID
                AND    ASP.Set_Of_Books_ID = XTE.Ledger_ID
                AND    XTE.Entity_Code = 'AP_PAYMENTS'
                AND    AC.Check_ID = nvl(XTE.Source_ID_Int_1,-99)
                AND    XTE.Application_ID = 200
                AND    XTE.Entity_ID = XLE.Entity_ID
                AND    XLE.Application_ID = 200
                AND    XLE.Event_ID = APH.Accounting_Event_ID
                AND    XLE.Upg_Batch_ID IS NOT NULL
          	    AND    APH.Check_ID = AC.Check_ID
                AND    DECODE(APH.Transaction_Type,'PAYMENT CREATED',XLE.Event_ID,
                             'PAYMENT CANCELLED', XLE.Event_ID,
                             'MANUAL PAYMENT ADJUSTMENT', XLE.Event_ID,
                             AIP.Accounting_Event_ID) = AIP.Accounting_Event_ID
        	AND    AIP.Check_ID = AC.Check_ID
        	AND    XLE.Event_ID = AEH.Event_ID
        	AND    AEH.Application_ID = 200
        	AND    AEL.AE_Header_ID = AEH.AE_Header_ID
                -- bug 8535401
                AND    XLE.upg_batch_id IS NOT NULL
                AND    XLE.upg_batch_id <> -9999
                AND    AEH.upg_batch_id IS NOT NULL
                AND    AEH.upg_batch_id <> -9999
        	AND    AEL.Application_ID = 200
        	AND    AI.Invoice_ID = AIP.Invoice_ID
        	AND    ASP.Set_Of_Books_ID = AEH.Ledger_ID
        	--AND    AIP.Invoice_ID = AID.Invoice_ID
        	--AND    AID.Old_Distribution_ID = NVL (AEL.Account_Overlay_Source_ID, AID.Old_Distribution_ID)
		/* AWT changes start - this condtion is not to skip the AWT lines in the join */
		--and AEL.Account_Overlay_Source_ID = AID_a.Old_Distribution_ID (+)
		AND DECODE(AEL.ACCOUNTING_CLASS_CODE , 'AWT', AEL.SOURCE_ID , ael.account_overlay_source_id) = aid_a.old_distribution_id (+)
		/* AWT changes end */
	        and (AID_a.Old_Distribution_ID IS NOT NULL OR AEL.Account_Overlay_Source_ID IS NULL)
                /* AWT changes start - added another 'OR' condition to include the AWT lines  */
                AND  ((AEL.Source_Table = 'AP_INVOICE_PAYMENTS'
                          AND    AEL.Source_ID = AIP.Invoice_Payment_ID)
                  OR  (AEL.Source_Table = 'AP_CHECKS'
                          AND    AEL.Source_ID = AC.Check_ID)
		  OR (AEL.source_table = 'AP_INVOICE_DISTRIBUTIONS' AND AEL.ACCOUNTING_CLASS_CODE = 'AWT'
		          AND AEL.source_id = AID_A.old_distribution_id AND AI.invoice_id = AID_A.invoice_id) )
                /* AWT changes end */
       AND ((Decode(aph.transaction_type,
       'PAYMENT CLEARING','CASH',
       'PAYMENT UNCLEARING','CASH',
       'PAYMENT MATURITY',Decode(asp.recon_accounting_flag,'Y','CASH_CLEARING', 'CASH'),
       'PAYMENT CREATED' ,Decode(ac.future_pay_due_date,NULL, Decode(asp.recon_accounting_flag,'Y','CASH_CLEARING','CASH'),
                                 'FUTURE_DATED_PMT'),
       'REFUND RECORDED',Decode(ac.future_pay_due_date,NULL,Decode(asp.recon_accounting_flag,'Y','CASH_CLEARING', 'CASH'),
                                 'FUTURE_DATED_PMT'),
       'MANUAL PAYMENT ADJUSTED',Decode(ac.future_pay_due_date,NULL,Decode(asp.recon_accounting_flag,'Y','CASH_CLEARING', 'CASH'),
                                        'FUTURE_DATED_PMT'),
       'PAYMENT CANCELLED',Decode(ac.future_pay_due_date,NULL,Decode(asp.recon_accounting_flag,'Y','CASH_CLEARING', 'CASH'),
                                  'FUTURE_DATED_PMT'),
       'REFUND CANCELLED',Decode(ac.future_pay_due_date,NULL,Decode(asp.recon_accounting_flag,'Y','CASH_CLEARING', 'CASH'),
                                  'FUTURE_DATED_PMT')) = ael.accounting_class_code)
             OR (ael.accounting_class_code IN ('AWT','DISCOUNT','BANK_CHG','BANK_ERROR')))
		/* AWT changes - above line, we added AWT in the list */
       AND    FC.Currency_Code = ASP.Base_Currency_Code
	       ) v1,
		 AP_Invoice_Distributions_All AID_b
	WHERE  DECODE(v1.Old_Distribution_ID, to_number(NULL), v1.invoice_id_aip, to_number(NULL)) = AID_b.Invoice_ID (+)
	       /* AWT changes start - this condtion is to exclude the AWT lines which are inserting as CASH lines */
	       AND  nvl(AID_B.line_type_lookup_code, 1)  <> 'AWT'
	       /* AWT changes end */
	       AND AID_b.prepay_distribution_id IS NULL --7514374 excluding prepay distributions
	) v2,
	AP_Inv_Dists_Source AID1
		-- optimization, since 50% of old_dist id's point to themselves
       	WHERE   AID1.Invoice_Distribution_ID(+) =
		DECODE(v2.Old_Distribution_ID,v2.invoice_distribution_id,TO_NUMBER(null),v2.Old_Distribution_ID)
          AND AID1.prepay_distribution_id IS NULL --7514374 excluding prepay distributions
	)
	); /* bug#6662100 the query is modification ended up here. */


  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_PAYMENT_DIST_LINKS',
                    'Insert into Distribution Links for payments');
  END IF;

    --Bug 8725986: Insert statement same as of appdstln.sql version 120.4.12000000.16
INSERT INTO XLA_Distribution_Links t1
        (APPLICATION_ID,
         EVENT_ID,
         AE_HEADER_ID,
         AE_LINE_NUM,
         SOURCE_DISTRIBUTION_TYPE,
         SOURCE_DISTRIBUTION_ID_NUM_1,
         UNROUNDED_ENTERED_CR,
         UNROUNDED_ENTERED_DR,
         UNROUNDED_ACCOUNTED_CR,
         UNROUNDED_ACCOUNTED_DR,
         REF_AE_HEADER_ID,
         ACCOUNTING_LINE_CODE,
         ACCOUNTING_LINE_TYPE_CODE,
         MERGE_DUPLICATE_CODE,
         TEMP_LINE_NUM,
         REF_EVENT_ID,
         UPG_BATCH_ID,
         LINE_DEFINITION_OWNER_CODE,
         LINE_DEFINITION_CODE,
         EVENT_CLASS_CODE,
         EVENT_TYPE_CODE,
         APPLIED_TO_APPLICATION_ID, --Bug7169843 Starts
         APPLIED_TO_ENTITY_ID,
         APPLIED_TO_DIST_ID_NUM_1,
         GAIN_OR_LOSS_REF ,--Bug7169843 Ends
	 /* 7360647 changes start */
	 TAX_LINE_REF_ID,
	 TAX_SUMMARY_LINE_REF_ID,
	 TAX_REC_NREC_DIST_REF_ID
	 /* 7360647 changes end */
       )
  SELECT v1.APPLICATION_ID,
     v1.ACCOUNTING_EVENT_ID,
     v1.AE_HEADER_ID,
     v1.AE_LINE_NUM,
     v1.SOURCE_DISTRIBUTION_TYPE,
     v1.SOURCE_DISTRIBUTION_ID_NUM_1,
     v1.UNROUNDED_ENTERED_CR,
     v1.UNROUNDED_ENTERED_DR,
     v1.UNROUNDED_ACCOUNTED_CR,
     v1.UNROUNDED_ACCOUNTED_DR,
     v1.REF_AE_HEADER_ID,
     v1.ACCOUNTING_LINE_CODE,
     v1.ACCOUNTING_LINE_TYPE_CODE,
     v1.MERGE_DUPLICATE_CODE,
     Row_Number() OVER (PARTITION BY v1.AE_Header_ID
              ORDER BY v1.AE_Line_Num,
                       v1.Invoice_Distribution_ID,
                       v1.Invoice_Payment_ID,
                       v1.Payment_History_ID) Temp_Line_Num,
     v1.REF_EVENT_ID,
     v1.UPG_BATCH_ID,
     v1.LINE_DEFINITION_OWNER_CODE,
     v1.LINE_DEFINITION_CODE,
     v1.EVENT_CLASS_CODE,
     v1.EVENT_TYPE_CODE,
     v1.APPLIED_TO_APPLICATION_ID, --Bug7169843 Starts
     v1.APPLIED_TO_ENTITY_ID,
     v1.APPLIED_TO_DIST_ID_NUM_1,
     v1.GAIN_OR_LOSS_REF,  --Bug7169843 Ends
       /* 7360647 changes start */
     v1.Tax_Line_id,
     v1.Summary_Tax_Line_ID,
     v1.Detail_Tax_Dist_ID
 	 /* 7360647 changes end */
   FROM
  (  /* bug#7360647 added hit for zrd */
  SELECT /*+ ordered use_hash(asp, upg) rowid(ac)
	     swap_join_inputs (upg) swap_join_inputs (asp)
             use_nl_with_index (xte, xla_transaction_entities_n1)
             use_nl_with_index (xle, xla_events_u2)
             use_nl_with_index (aeh, xla_ae_headers_n2)
             use_nl_with_index (ael, xla_ae_lines_u1)
             use_nl_with_index (aph, ap_payment_history_n2)
             use_nl_with_index (aid, ap_invoice_distributions_n26)
             use_nl_with_index (aphd, ap_payment_hist_dists_n2)
	     use_nl_with_index (zrd,ZX_REC_NREC_DIST_U1) */
         200 Application_ID,
         AEH.Event_ID Accounting_Event_ID,
         AEH.AE_Header_ID AE_Header_ID,
         AEL.AE_Line_Num AE_Line_Num,
         'AP_PMT_DIST' Source_Distribution_Type,
         APHD.Payment_Hist_Dist_ID Source_Distribution_ID_Num_1,
                 (CASE
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CREATED', 'REFUND RECORDED',
                                         'MANUAL PAYMENT ADJUSTED',
                                         'PAYMENT CANCELLED', 'REFUND CANCELLED') AND
                 AEL.Accounting_Class_Code IN ('LIABILITY', 'PREPAID_EXPENSE', 'ACCRUAL',
                                               'ITEM EXPENSE', 'EXCHANGE_RATE_VARIANCE',
                                               'IPV', 'RTAX', 'NRTAX', 'FREIGHT', 'AWT',
                                               'ROUNDING', 'LOSS', 'BANK_CHG',
                                               'BANK_ERROR')) THEN
                 DECODE(SIGN(APHD.Amount), -1, ABS(APHD.Amount),
                        0, DECODE(SIGN(APHD.Paid_Base_Amount), -1, 0,
			              -- bug #7585406
                                     DECODE(AEL.Unrounded_Entered_CR, NULL, NULL, 0))
		         , NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CREATED', 'REFUND RECORDED',
                                         'MANUAL PAYMENT ADJUSTED',
                                         'PAYMENT CANCELLED', 'REFUND CANCELLED') AND
                 AEL.Accounting_Class_Code IN ('CASH', 'CASH_CLEARING', 'GAIN',
                                               'FUTURE_DATED_PMT')) THEN
                 DECODE(SIGN(APHD.Amount), 1, APHD.Amount,
                        0, DECODE(SIGN(APHD.Paid_Base_Amount), -1, NULL,
			                     -- bug #7585406
                                           DECODE(AEL.Unrounded_Entered_CR, NULL, NULL, 0))
			 , NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CLEARED', 'PAYMENT UNCLEARED') AND
                 AEL.Accounting_Class_Code IN ('CASH')) THEN
                 DECODE(SIGN(APHD.Amount), 1, APHD.Amount,
                        0, DECODE(SIGN(NVL(APHD.Cleared_Base_Amount, APHD.Paid_Base_Amount)),
                              -1, NULL, 0), NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT MATURED') AND
                 AEL.Accounting_Class_Code IN ('CASH', 'CASH_CLEARING')) THEN
                 DECODE(SIGN(APHD.Amount), 1, APHD.Amount,
                        0, DECODE(SIGN(NVL(APHD.Matured_Base_Amount, APHD.Paid_Base_Amount)),
                              -1, NULL, 0), NULL)
           ELSE
                 DECODE(SIGN(APHD.Amount), 1, APHD.Amount,
                          0, DECODE(SIGN(APHD.Paid_Base_Amount), -1, NULL, 0), NULL)
         END) Unrounded_Entered_Cr,
        (CASE
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CREATED', 'REFUND RECORDED',
                                         'MANUAL PAYMENT ADJUSTED',
                                         'PAYMENT CANCELLED', 'REFUND CANCELLED') AND
                 AEL.Accounting_Class_Code IN ('LIABILITY', 'PREPAID_EXPENSE', 'ACCRUAL',
                                               'ITEM EXPENSE', 'EXCHANGE_RATE_VARIANCE',
                                               'IPV', 'RTAX', 'NRTAX', 'FREIGHT', 'AWT',
                                               'ROUNDING', 'LOSS', 'BANK_CHG',
                                               'BANK_ERROR')) THEN
                 DECODE(SIGN(APHD.Amount), 1, APHD.Amount,
                        0, DECODE(SIGN(APHD.Paid_Base_Amount), -1, NULL,
			                       -- bug #7585406
                                            DECODE(AEL.Unrounded_Entered_DR, NULL, NULL, 0))
			 , NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CREATED', 'REFUND RECORDED',
                                         'MANUAL PAYMENT ADJUSTED',
                                         'PAYMENT CANCELLED', 'REFUND CANCELLED') AND
                 AEL.Accounting_Class_Code IN ('CASH', 'CASH_CLEARING', 'GAIN',
                                               'FUTURE_DATED_PMT')) THEN
                 DECODE(SIGN(APHD.Amount), -1, ABS(APHD.Amount),
                        0, DECODE(SIGN(APHD.Paid_Base_Amount), -1, 0,
			                           -- bug #7585406
                                                DECODE(AEL.Unrounded_Entered_DR, NULL, NULL, 0))
			 , NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CLEARED', 'PAYMENT UNCLEARED') AND
                 AEL.Accounting_Class_Code IN ('CASH')) THEN
                 DECODE(SIGN(APHD.Amount), -1, ABS(APHD.Amount),
                        0, DECODE(SIGN(NVL(APHD.Cleared_Base_Amount, APHD.Paid_Base_Amount)),
                              -1, 0, NULL), NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT MATURED') AND
                 AEL.Accounting_Class_Code IN ('CASH', 'CASH_CLEARING')) THEN
                 DECODE(SIGN(APHD.Amount), -1, ABS(APHD.Amount),
                        0, DECODE(SIGN(NVL(APHD.Matured_Base_Amount, APHD.Paid_Base_Amount)),
                              -1, 0, NULL), NULL)
           ELSE
                 DECODE(SIGN(APHD.Amount), -1, ABS(APHD.Amount),
                        0, DECODE(SIGN(APHD.Paid_Base_Amount), -1, 0, NULL), NULL)
         END) Unrounded_Entered_Dr,
        (CASE
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CREATED', 'REFUND RECORDED',
                                         'MANUAL PAYMENT ADJUSTED',
                                         'PAYMENT CANCELLED', 'REFUND CANCELLED') AND
                 AEL.Accounting_Class_Code IN ('LIABILITY', 'PREPAID_EXPENSE', 'ACCRUAL',
                                               'ITEM EXPENSE', 'EXCHANGE_RATE_VARIANCE',
                                               'IPV', 'RTAX', 'NRTAX', 'FREIGHT', 'AWT',
                                               'ROUNDING', 'LOSS', 'BANK_CHG',
                                               'BANK_ERROR')) THEN
                 DECODE(SIGN(APHD.Paid_Base_Amount), -1, ABS(APHD.Paid_Base_Amount),
		                                           -- bug #7585406
                                                      0, DECODE(AEL.Unrounded_Accounted_Cr, NULL, NULL, 0)
						       , NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CREATED', 'REFUND RECORDED',
                                         'MANUAL PAYMENT ADJUSTED',
                                         'PAYMENT CANCELLED', 'REFUND CANCELLED') AND
                 AEL.Accounting_Class_Code IN ('CASH', 'CASH_CLEARING', 'GAIN',
                                               'FUTURE_DATED_PMT')) THEN
                 DECODE(SIGN(APHD.Paid_Base_Amount), 1, APHD.Paid_Base_Amount,
		                                           -- bug #7585406
                                                     0, DECODE(AEL.Unrounded_Accounted_Cr, NULL, NULL, 0)
                                                      , NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CLEARED', 'PAYMENT UNCLEARED') AND
                 AEL.Accounting_Class_Code IN ('CASH')) THEN
                 DECODE(SIGN(NVL(APHD.Cleared_Base_Amount, APHD.Paid_Base_Amount)), 1,
                        NVL(APHD.Cleared_Base_Amount, APHD.Paid_Base_Amount), NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT MATURED') AND
                 AEL.Accounting_Class_Code IN ('CASH', 'CASH_CLEARING')) THEN
                 DECODE(SIGN(NVL(APHD.Matured_Base_Amount, APHD.Paid_Base_Amount)), 1,
                        NVL(APHD.Matured_Base_Amount, APHD.Paid_Base_Amount), 0, 0, NULL)
           ELSE
                 DECODE(SIGN(APHD.Paid_Base_Amount), 1, APHD.Paid_Base_Amount, 0, 0, NULL)
         END) Unrounded_Accounted_Cr,
        (CASE
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CREATED', 'REFUND RECORDED',
                                         'MANUAL PAYMENT ADJUSTED',
                                         'PAYMENT CANCELLED', 'REFUND CANCELLED') AND
                 AEL.Accounting_Class_Code IN ('LIABILITY', 'PREPAID_EXPENSE', 'ACCRUAL',
                                               'ITEM EXPENSE', 'EXCHANGE_RATE_VARIANCE',
                                               'IPV', 'RTAX', 'NRTAX', 'FREIGHT', 'AWT',
                                               'ROUNDING', 'LOSS', 'BANK_CHG',
                                               'BANK_ERROR')) THEN
                 DECODE(SIGN(APHD.Amount), 1, APHD.Amount,
		                                   -- bug #7585406
                                           0, DECODE(AEL.Unrounded_Accounted_Dr, NULL, NULL, 0)
                                            , NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CREATED', 'REFUND RECORDED',
                                         'MANUAL PAYMENT ADJUSTED',
                                         'PAYMENT CANCELLED', 'REFUND CANCELLED') AND
                 AEL.Accounting_Class_Code IN ('CASH', 'CASH_CLEARING', 'GAIN',
                                               'FUTURE_DATED_PMT')) THEN
                 DECODE(SIGN(APHD.Paid_Base_Amount), -1, ABS(APHD.Paid_Base_Amount),
		                                          -- bug #7585406
                                                      0, DECODE(AEL.Unrounded_Accounted_Dr, NULL, NULL, 0)
                                                       , NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CLEARED', 'PAYMENT UNCLEARED') AND
                 AEL.Accounting_Class_Code IN ('CASH')) THEN
                 DECODE(SIGN(NVL(APHD.Cleared_Base_Amount, APHD.Paid_Base_Amount)), -1,
                             ABS(NVL(APHD.Cleared_Base_Amount,APHD.Paid_Base_Amount)),NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT MATURED') AND
                 AEL.Accounting_Class_Code IN ('CASH', 'CASH_CLEARING')) THEN
                 DECODE(SIGN(NVL(APHD.Matured_Base_Amount, APHD.Paid_Base_Amount)), -1,
                             ABS(NVL(APHD.Matured_Base_Amount,APHD.Paid_Base_Amount)),NULL)
           ELSE
                 DECODE(SIGN(APHD.Paid_Base_Amount), -1, ABS(APHD.Paid_Base_Amount), NULL)
         END) Unrounded_Accounted_Dr,
         AEH.AE_Header_ID Ref_AE_Header_ID,
        (CASE
             WHEN AC.Payment_Type_Flag = 'R' THEN
                  DECODE(AEL.Accounting_Class_Code,
                         'CASH_CLEARING', 'AP_CASH_CLEAR_REF', 'CASH', 'AP_CASH_REF',
                         'ACCRUAL', 'AP_ACCRUAL_REF', 'DISCOUNT', 'AP_DISCOUNT_ACCR_REF',
                         'EXCHANGE_RATE_VARIANCE', 'AP_EX_RATE_VAR_REF',
                         'ROUNDING', 'AP_FINAL_PMT_ROUNDING_REF',
                         'GAIN', 'AP_GAIN_REF', 'FREIGHT', 'AP_FREIGHT_EXPENSE_REF',
                         'IPV', 'AP_INV_PRICE_VAR_REF', 'ITEM EXPENSE', 'AP_ITEM_EXPENSE_REF',
                         'LOSS', 'AP_LOSS_REF', 'LIABILITY', 'AP_LIAB_REF',
                         'NRTAX', 'AP_NON_RECOV_TAX_REF',
                         'PREPAID_EXPENSE', 'AP_PREPAID_EXP_REF', 'RTAX','AP_RECOV_TAX_REF',
                         'AWT', 'AP_WITHHOLD_TAX_ACCR_REF')
             WHEN APH.Transaction_Type = 'PAYMENT MATURITY' THEN
                  DECODE(AEL.Accounting_Class_Code, 'FUTURE_DATED_PMT', 'AP_FUTURE_DATED_PMT_MAT',
                         'CASH_CLEARING', 'AP_CASH_CLEAR_PMT_MAT',
                         'CASH', 'AP_CASH_PMT_MAT', 'GAIN', 'AP_GAIN_PMT_MAT',
                         'LOSS', 'AP_LOSS_PMT_MAT',
                         'ROUNDING', 'AP_FUTURE_PMT_ROUNDING_MAT')
	     /* bug # 7707573 below when condition, included
	        'MANUAL PAYMENT ADJUSTED' and 'PAYMENT ADJUSTED' transaction types too */
             WHEN APH.Transaction_Type IN ('PAYMENT CREATED', 'PAYMENT CANCELLED',
	                                   'MANUAL PAYMENT ADJUSTED','PAYMENT ADJUSTED') THEN
                  DECODE(AEL.Accounting_Class_Code, 'FUTURE_DATED_PMT', 'AP_FUTURE_DATED_PMT',
                         'CASH_CLEARING', 'AP_CASH_CLEAR_PMT', 'CASH', 'AP_CASH_PMT',
                         'ACCRUAL', 'AP_ACCRUAL_PMT', 'DISCOUNT', 'AP_DISCOUNT_ACCR_PMT',
                         'EXCHANGE_RATE_VARIANCE', 'AP_EX_RATE_VAR_PMT',
                         'ROUNDING', 'AP_FINAL_PMT_ROUNDING_PMT',
                         'GAIN', 'AP_GAIN_PMT', 'FREIGHT', 'AP_FREIGHT_EXPENSE_PMT',
                         'IPV', 'AP_INV_PRICE_VAR_PMT', 'ITEM EXPENSE', 'AP_ITEM_EXPENSE_PMT',
                         'LOSS', 'AP_LOSS_PMT', 'LIABILITY', 'AP_LIAB_PMT',
                         'NRTAX', 'AP_NON_RECOV_TAX_PMT',
                         'PREPAID_EXPENSE', 'AP_PREPAID_EXP_PMT', 'RTAX','AP_RECOV_TAX_PMT',
                         'AWT', 'AP_WITHHOLD_TAX_ACCR_PMT')
             WHEN APH.Transaction_Type IN ('PAYMENT CLEARING', 'PAYMENT UNCLEARING') THEN
                  DECODE(AEL.Accounting_Class_Code, 'BANK_CHG', 'AP_BANK_CHARGES_CLEAR',
                         'CASH_CLEARING', 'AP_CASH_CLEAR_CLEAR', 'CASH', 'AP_CASH_CLEAR',
                         'ACCRUAL', 'AP_ACCRUAL_CLEAR', 'DISCOUNT', 'AP_DISCOUNT_ACCR_CLEAR',
                         'EXCHANGE_RATE_VARIANCE', 'AP_EX_RATE_VAR_CLEAR','BANK_ERROR', 'AP_BANK_ERROR_CLEAR',
                         'ROUNDING', 'AP_FINAL_PMT_ROUNDING_CLEAR',
                         'GAIN', 'AP_GAIN_PMT_CLEAR', 'FREIGHT', 'AP_FREIGHT_EXPENSE_CLEAR',
                         'IPV', 'AP_INV_PRICE_VAR_CLEAR', 'ITEM EXPENSE', 'AP_ITEM_EXPENSE_CLEAR',
                         'LOSS', 'AP_LOSS_PMT_CLEAR', 'LIABILITY', 'AP_LIAB_CLEAR',
                         'NRTAX', 'AP_NON_RECOV_TAX_CLEAR',
                         'RTAX','AP_RECOV_TAX_CLEAR',
                         'AWT', 'AP_WITHHOLD_TAX_ACCR_CLEAR')
         END) AS Accounting_Line_Code,
         'S' Accounting_Line_Type_Code,
         'A' Merge_Duplicate_Code, --added by abhsaxen for bug#9073033
         /*  Row_Number() OVER (PARTITION BY AEH.AE_Header_ID
                      ORDER BY AEL.AE_Line_Num,
                               APHD.Invoice_Distribution_ID,
                               APHD.Invoice_Payment_ID,
                               APHD.Payment_History_ID) Temp_Line_Num, */
         AEH.Event_ID Ref_Event_ID,
         AEL.Upg_Batch_ID,
         'S' Line_Definition_Owner_Code,
         'ACCRUAL_PAYMENTS_ALL' Line_Definition_Code,
         'PAYMENTS' Event_Class_Code,
         'PAYMENTS_ALL' Event_Type_Code,
          APHD.payment_history_id PAYMENT_HISTORY_ID,
          APHD.invoice_distribution_id INVOICE_DISTRIBUTION_ID,
          APHD.invoice_payment_id INVOICE_PAYMENT_ID,
          --Bug 7169843 Starts
          DECODE(AEL.Accounting_Class_Code, 'LIABILITY' ,200, null) APPLIED_TO_APPLICATION_ID,
          DECODE(AEL.Accounting_Class_Code, 'LIABILITY' ,XTE_INV.Entity_ID, null) APPLIED_TO_ENTITY_ID,
          DECODE(AEL.Accounting_Class_Code, 'LIABILITY' ,AID.Invoice_Distribution_ID, null)  APPLIED_TO_DIST_ID_NUM_1,
         '-1111' GAIN_OR_LOSS_REF, --Bug7169843 ends
	 /* 7360647 changes start */
	  ZRD.Tax_Line_id,
          AID.Summary_Tax_Line_ID,
          AID.Detail_Tax_Dist_ID
	 /* 7360647 changes end */
  FROM   AP_Checks_All AC,
         AP_System_Parameters_All ASP,
         XLA_Upgrade_Dates UPG,
         XLA_Transaction_Entities_Upg XTE,
         XLA_Events XLE,
         AP_Payment_History_All APH,
         XLA_AE_Headers AEH,
         XLA_AE_Lines AEL,
         AP_Invoice_Distributions_All AID,
         AP_Payment_Hist_Dists APHD,
         XLA_Events XTE_INV, --Bug7169843
	 ZX_Rec_Nrec_Dist ZRD   -- 7360647 changes
  WHERE  AC.rowid BETWEEN p_start_rowid AND p_end_rowid
  AND    TRUNC(AC.Check_Date) BETWEEN UPG.Start_Date and UPG.End_Date
  AND    ASP.Set_Of_Books_ID = UPG.Ledger_ID
  AND    AC.Org_ID = ASP.Org_ID
  AND    ASP.Set_Of_Books_ID = XTE.Ledger_ID
  AND    XTE.Entity_Code = 'AP_PAYMENTS'
  AND    AC.Check_ID = nvl(XTE.Source_ID_Int_1,-99)
  AND    XTE.Application_ID = 200
  AND    XTE.Entity_ID = XLE.Entity_ID
  AND    XLE.Application_ID = 200
  AND    XLE.Event_ID = AEH.Event_ID
  AND    XLE.Upg_Batch_ID IS NOT NULL
  AND    AEH.Application_ID = 200
  AND    AEL.AE_Header_ID = AEH.AE_Header_ID
  AND    AEL.Application_ID = 200
  AND    XLE.Event_ID = APH.Accounting_Event_ID
  AND    APH.Check_ID = AC.Check_ID
  AND    APH.Payment_History_ID = APHD.Payment_History_ID
  AND    APHD.Invoice_Payment_ID = DECODE(AEL.Source_Table, 'AP_INVOICE_PAYMENTS',
                                            AEL.Source_ID, APHD.Invoice_Payment_ID)
  AND    APHD.Invoice_Distribution_ID = AID.Invoice_Distribution_ID
  AND    AID.Old_Distribution_ID = AEL.Account_Overlay_Source_ID
  AND    XTE_INV.Application_ID = 200 --Bug7169843
  AND    XTE_INV.Event_id = AID.Accounting_event_id --Bug7169843
   /* 7360647 changes start */
  AND    ZRD.Rec_Nrec_Tax_Dist_ID (+) = AID.Detail_Tax_Dist_ID
  AND    ZRD.Application_id (+) = 200
  AND    ZRD.Entity_Code (+) = 'AP_INVOICES'
   /* 7360647 changes end */
  -- bug8535401
  AND    XLE.upg_batch_id IS NOT NULL
  AND    XLE.upg_batch_id <> -9999
  AND    AEH.upg_batch_id IS NOT NULL
  AND    AEH.upg_batch_id <> -9999
  UNION ALL   /* bug#7360647 added hit for zrd */
  SELECT /*+ ordered use_hash(asp, upg) rowid(ac)
	         swap_join_inputs (upg) swap_join_inputs (asp)
             use_nl_with_index (xte, xla_transaction_entities_n1)
             use_nl_with_index (xle, xla_events_u2)
             use_nl_with_index (aeh, xla_ae_headers_n2)
             use_nl_with_index (ael, xla_ae_lines_u1)
             use_nl_with_index (aph, ap_payment_history_n2)
             use_nl_with_index (aphd, ap_payment_hist_dists_n1)
             use_nl_with_index (aid, ap_invoice_distributions_u2)
	     use_nl_with_index (zrd,ZX_REC_NREC_DIST_U1) */
         200 Application_ID,
         AEH.Event_ID Accounting_Event_ID,
         AEH.AE_Header_ID AE_Header_ID,
         AEL.AE_Line_Num AE_Line_Num,
         'AP_PMT_DIST' Source_Distribution_Type,
         APHD.Payment_Hist_Dist_ID Source_Distribution_ID_Num_1,
                 (CASE
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CREATED', 'REFUND RECORDED',
                                         'MANUAL PAYMENT ADJUSTED',
                                         'PAYMENT CANCELLED', 'REFUND CANCELLED') AND
                 AEL.Accounting_Class_Code IN ('LIABILITY', 'PREPAID_EXPENSE', 'ACCRUAL',
                                               'ITEM EXPENSE', 'EXCHANGE_RATE_VARIANCE',
                                               'IPV', 'RTAX', 'NRTAX', 'FREIGHT', 'AWT',
                                               'ROUNDING', 'LOSS', 'BANK_CHG',
                                               'BANK_ERROR')) THEN
                 DECODE(SIGN(APHD.Amount), -1, ABS(APHD.Amount),
                        0, DECODE(SIGN(APHD.Paid_Base_Amount), -1, 0,
			               -- bug #7585406
                                  DECODE(AEL.Unrounded_Entered_CR, NULL, NULL, 0)), NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CREATED', 'REFUND RECORDED',
                                         'MANUAL PAYMENT ADJUSTED',
                                         'PAYMENT CANCELLED', 'REFUND CANCELLED') AND
                 AEL.Accounting_Class_Code IN ('CASH', 'CASH_CLEARING', 'GAIN',
                                               'FUTURE_DATED_PMT')) THEN
                 DECODE(SIGN(APHD.Amount), 1, APHD.Amount,
                        0, DECODE(SIGN(APHD.Paid_Base_Amount), -1, NULL,
			                 -- bug #7585406
                                   DECODE(AEL.Unrounded_Entered_CR, NULL, NULL, 0)), NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CLEARED', 'PAYMENT UNCLEARED') AND
                 AEL.Accounting_Class_Code IN ('CASH')) THEN
                 DECODE(SIGN(APHD.Amount), 1, APHD.Amount,
                        0, DECODE(SIGN(NVL(APHD.Cleared_Base_Amount, APHD.Paid_Base_Amount)),
                              -1, NULL, 0), NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT MATURED') AND
                 AEL.Accounting_Class_Code IN ('CASH', 'CASH_CLEARING')) THEN
                 DECODE(SIGN(APHD.Amount), 1, APHD.Amount,
                        0, DECODE(SIGN(NVL(APHD.Matured_Base_Amount, APHD.Paid_Base_Amount)),
                              -1, NULL, 0), NULL)
           ELSE
                 DECODE(SIGN(APHD.Amount), 1, APHD.Amount,
                          0, DECODE(SIGN(APHD.Paid_Base_Amount), -1, NULL, 0), NULL)
         END) Unrounded_Entered_Cr,
        (CASE
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CREATED', 'REFUND RECORDED',
                                         'MANUAL PAYMENT ADJUSTED',
                                         'PAYMENT CANCELLED', 'REFUND CANCELLED') AND
                 AEL.Accounting_Class_Code IN ('LIABILITY', 'PREPAID_EXPENSE', 'ACCRUAL',
                                               'ITEM EXPENSE', 'EXCHANGE_RATE_VARIANCE',
                                               'IPV', 'RTAX', 'NRTAX', 'FREIGHT', 'AWT',
                                               'ROUNDING', 'LOSS', 'BANK_CHG',
                                               'BANK_ERROR')) THEN
                 DECODE(SIGN(APHD.Amount), 1, APHD.Amount,
                        0, DECODE(SIGN(APHD.Paid_Base_Amount), -1, NULL,
			                       -- bug #7585406
                                    DECODE(AEL.Unrounded_Entered_DR, NULL, NULL, 0)), NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CREATED', 'REFUND RECORDED',
                                         'MANUAL PAYMENT ADJUSTED',
                                         'PAYMENT CANCELLED', 'REFUND CANCELLED') AND
                 AEL.Accounting_Class_Code IN ('CASH', 'CASH_CLEARING', 'GAIN',
                                               'FUTURE_DATED_PMT')) THEN
                 DECODE(SIGN(APHD.Amount), -1, ABS(APHD.Amount),
                        0, DECODE(SIGN(APHD.Paid_Base_Amount), -1, 0,
			                   -- bug #7585406
                                  DECODE(AEL.Unrounded_Entered_DR, NULL, NULL, 0)), NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CLEARED', 'PAYMENT UNCLEARED') AND
                 AEL.Accounting_Class_Code IN ('CASH')) THEN
                 DECODE(SIGN(APHD.Amount), -1, ABS(APHD.Amount),
                        0, DECODE(SIGN(NVL(APHD.Cleared_Base_Amount, APHD.Paid_Base_Amount)),
                              -1, 0, NULL), NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT MATURED') AND
                 AEL.Accounting_Class_Code IN ('CASH', 'CASH_CLEARING')) THEN
                 DECODE(SIGN(APHD.Amount), -1, ABS(APHD.Amount),
                        0, DECODE(SIGN(NVL(APHD.Matured_Base_Amount, APHD.Paid_Base_Amount)),
                              -1, 0, NULL), NULL)
           ELSE
                 DECODE(SIGN(APHD.Amount), -1, ABS(APHD.Amount),
                        0, DECODE(SIGN(APHD.Paid_Base_Amount), -1, 0, NULL), NULL)
         END) Unrounded_Entered_Dr,
        (CASE
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CREATED', 'REFUND RECORDED',
                                         'MANUAL PAYMENT ADJUSTED',
                                         'PAYMENT CANCELLED', 'REFUND CANCELLED') AND
                 AEL.Accounting_Class_Code IN ('LIABILITY', 'PREPAID_EXPENSE', 'ACCRUAL',
                                               'ITEM EXPENSE', 'EXCHANGE_RATE_VARIANCE',
                                               'IPV', 'RTAX', 'NRTAX', 'FREIGHT', 'AWT',
                                               'ROUNDING', 'LOSS', 'BANK_CHG',
                                               'BANK_ERROR')) THEN
                 DECODE(SIGN(APHD.Paid_Base_Amount), -1, ABS(APHD.Paid_Base_Amount),
		                                             -- bug #7585406
                                                      0, DECODE(AEL.Unrounded_Accounted_Cr, NULL, NULL, 0)
                                                       , NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CREATED', 'REFUND RECORDED',
                                         'MANUAL PAYMENT ADJUSTED',
                                         'PAYMENT CANCELLED', 'REFUND CANCELLED') AND
                 AEL.Accounting_Class_Code IN ('CASH', 'CASH_CLEARING', 'GAIN',
                                               'FUTURE_DATED_PMT')) THEN
                 DECODE(SIGN(APHD.Paid_Base_Amount), 1, APHD.Paid_Base_Amount,
		                                              -- bug #7585406
                                                     0, DECODE(AEL.Unrounded_Accounted_Cr, NULL, NULL, 0)
                                                      , NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CLEARED', 'PAYMENT UNCLEARED') AND
                 AEL.Accounting_Class_Code IN ('CASH')) THEN
                 DECODE(SIGN(NVL(APHD.Cleared_Base_Amount, APHD.Paid_Base_Amount)), 1,
                        NVL(APHD.Cleared_Base_Amount, APHD.Paid_Base_Amount), NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT MATURED') AND
                 AEL.Accounting_Class_Code IN ('CASH', 'CASH_CLEARING')) THEN
                 DECODE(SIGN(NVL(APHD.Matured_Base_Amount, APHD.Paid_Base_Amount)), 1,
                        NVL(APHD.Matured_Base_Amount, APHD.Paid_Base_Amount), 0, 0, NULL)
           ELSE
                 DECODE(SIGN(APHD.Paid_Base_Amount), 1, APHD.Paid_Base_Amount, 0, 0, NULL)
         END) Unrounded_Accounted_Cr,
        (CASE
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CREATED', 'REFUND RECORDED',
                                         'MANUAL PAYMENT ADJUSTED',
                                         'PAYMENT CANCELLED', 'REFUND CANCELLED') AND
                 AEL.Accounting_Class_Code IN ('LIABILITY', 'PREPAID_EXPENSE', 'ACCRUAL',
                                               'ITEM EXPENSE', 'EXCHANGE_RATE_VARIANCE',
                                               'IPV', 'RTAX', 'NRTAX', 'FREIGHT', 'AWT',
                                               'ROUNDING', 'LOSS', 'BANK_CHG',
                                               'BANK_ERROR')) THEN
                 DECODE(SIGN(APHD.Amount), 1, APHD.Amount,
		                                   -- bug #7585406
                                           0, DECODE(AEL.Unrounded_Accounted_Dr, NULL, NULL, 0)
                                            , NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CREATED', 'REFUND RECORDED',
                                         'MANUAL PAYMENT ADJUSTED',
                                         'PAYMENT CANCELLED', 'REFUND CANCELLED') AND
                 AEL.Accounting_Class_Code IN ('CASH', 'CASH_CLEARING', 'GAIN',
                                               'FUTURE_DATED_PMT')) THEN
                 DECODE(SIGN(APHD.Paid_Base_Amount), -1, ABS(APHD.Paid_Base_Amount),
		                                           -- bug #7585406
                                                      0, DECODE(AEL.Unrounded_Accounted_Dr, NULL, NULL, 0)
                                                       , NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT CLEARED', 'PAYMENT UNCLEARED') AND
                 AEL.Accounting_Class_Code IN ('CASH')) THEN
                 DECODE(SIGN(NVL(APHD.Cleared_Base_Amount, APHD.Paid_Base_Amount)), -1,
                             ABS(NVL(APHD.Cleared_Base_Amount,APHD.Paid_Base_Amount)),NULL)
           WHEN (XLE.Event_Type_Code IN ('PAYMENT MATURED') AND
                 AEL.Accounting_Class_Code IN ('CASH', 'CASH_CLEARING')) THEN
                 DECODE(SIGN(NVL(APHD.Matured_Base_Amount, APHD.Paid_Base_Amount)), -1,
                             ABS(NVL(APHD.Matured_Base_Amount,APHD.Paid_Base_Amount)),NULL)
           ELSE
                 DECODE(SIGN(APHD.Paid_Base_Amount), -1, ABS(APHD.Paid_Base_Amount), NULL)
         END) Unrounded_Accounted_Dr,
         AEH.AE_Header_ID Ref_AE_Header_ID,
        (CASE
             WHEN AC.Payment_Type_Flag = 'R' THEN
                  DECODE(AEL.Accounting_Class_Code,
                         'CASH_CLEARING', 'AP_CASH_CLEAR_REF', 'CASH', 'AP_CASH_REF',
                         'ACCRUAL', 'AP_ACCRUAL_REF', 'DISCOUNT', 'AP_DISCOUNT_ACCR_REF',
                         'EXCHANGE_RATE_VARIANCE', 'AP_EX_RATE_VAR_REF',
                         'ROUNDING', 'AP_FINAL_PMT_ROUNDING_REF',
                         'GAIN', 'AP_GAIN_REF', 'FREIGHT', 'AP_FREIGHT_EXPENSE_REF',
                         'IPV', 'AP_INV_PRICE_VAR_REF', 'ITEM EXPENSE', 'AP_ITEM_EXPENSE_REF',
                         'LOSS', 'AP_LOSS_REF', 'LIABILITY', 'AP_LIAB_REF',
                         'NRTAX', 'AP_NON_RECOV_TAX_REF',
                         'PREPAID_EXPENSE', 'AP_PREPAID_EXP_REF', 'RTAX','AP_RECOV_TAX_REF',
                         'AWT', 'AP_WITHHOLD_TAX_ACCR_REF')
             WHEN APH.Transaction_Type = 'PAYMENT MATURITY' THEN
                  DECODE(AEL.Accounting_Class_Code, 'FUTURE_DATED_PMT', 'AP_FUTURE_DATED_PMT_MAT',
                         'CASH_CLEARING', 'AP_CASH_CLEAR_PMT_MAT',
                         'CASH', 'AP_CASH_PMT_MAT', 'GAIN', 'AP_GAIN_PMT_MAT',
                         'LOSS', 'AP_LOSS_PMT_MAT',
                         'ROUNDING', 'AP_FUTURE_PMT_ROUNDING_MAT')
	     /* bug # 7707573 below when condition, included
	        'MANUAL PAYMENT ADJUSTED' and 'PAYMENT ADJUSTED' transaction types too */
             WHEN APH.Transaction_Type IN ('PAYMENT CREATED', 'PAYMENT CANCELLED',
	                                   'MANUAL PAYMENT ADJUSTED','PAYMENT ADJUSTED') THEN
                  DECODE(AEL.Accounting_Class_Code, 'FUTURE_DATED_PMT', 'AP_FUTURE_DATED_PMT',
                         'CASH_CLEARING', 'AP_CASH_CLEAR_PMT', 'CASH', 'AP_CASH_PMT',
                         'ACCRUAL', 'AP_ACCRUAL_PMT', 'DISCOUNT', 'AP_DISCOUNT_ACCR_PMT',
                         'EXCHANGE_RATE_VARIANCE', 'AP_EX_RATE_VAR_PMT',
                         'ROUNDING', 'AP_FINAL_PMT_ROUNDING_PMT',
                         'GAIN', 'AP_GAIN_PMT', 'FREIGHT', 'AP_FREIGHT_EXPENSE_PMT',
                         'IPV', 'AP_INV_PRICE_VAR_PMT', 'ITEM EXPENSE', 'AP_ITEM_EXPENSE_PMT',
                         'LOSS', 'AP_LOSS_PMT', 'LIABILITY', 'AP_LIAB_PMT',
                         'NRTAX', 'AP_NON_RECOV_TAX_PMT',
                         'PREPAID_EXPENSE', 'AP_PREPAID_EXP_PMT', 'RTAX','AP_RECOV_TAX_PMT',
                         'AWT', 'AP_WITHHOLD_TAX_ACCR_PMT')
             WHEN APH.Transaction_Type IN ('PAYMENT CLEARING', 'PAYMENT UNCLEARING') THEN
                  DECODE(AEL.Accounting_Class_Code, 'BANK_CHG', 'AP_BANK_CHARGES_CLEAR',
                         'CASH_CLEARING', 'AP_CASH_CLEAR_CLEAR', 'CASH', 'AP_CASH_CLEAR',
                         'ACCRUAL', 'AP_ACCRUAL_CLEAR', 'DISCOUNT', 'AP_DISCOUNT_ACCR_CLEAR',
                         'EXCHANGE_RATE_VARIANCE', 'AP_EX_RATE_VAR_CLEAR','BANK_ERROR', 'AP_BANK_ERROR_CLEAR',
                         'ROUNDING', 'AP_FINAL_PMT_ROUNDING_CLEAR',
                         'GAIN', 'AP_GAIN_PMT_CLEAR', 'FREIGHT', 'AP_FREIGHT_EXPENSE_CLEAR',
                         'IPV', 'AP_INV_PRICE_VAR_CLEAR', 'ITEM EXPENSE', 'AP_ITEM_EXPENSE_CLEAR',
                         'LOSS', 'AP_LOSS_PMT_CLEAR', 'LIABILITY', 'AP_LIAB_CLEAR',
                         'NRTAX', 'AP_NON_RECOV_TAX_CLEAR',
                         'RTAX','AP_RECOV_TAX_CLEAR',
                         'AWT', 'AP_WITHHOLD_TAX_ACCR_CLEAR')
         END) AS Accounting_Line_Code,
         'S' Accounting_Line_Type_Code,
         'A' Merge_Duplicate_Code, --CHANGED BY ABHSAXEN FOR BUG#9073033
         /* Row_Number() OVER (PARTITION BY AEH.AE_Header_ID
                      ORDER BY AEL.AE_Line_Num,
                               APHD.Invoice_Distribution_ID,
                               APHD.Invoice_Payment_ID,
                               APHD.Payment_History_ID) Temp_Line_Num, */
         AEH.Event_ID Ref_Event_ID,
         AEL.Upg_Batch_ID,
         'S' Line_Definition_Owner_Code,
         'ACCRUAL_PAYMENTS_ALL' Line_Definition_Code,
         'PAYMENTS' Event_Class_Code,
         'PAYMENTS_ALL' Event_Type_Code,
          APHD.payment_history_id PAYMENT_HISTORY_ID,
          APHD.invoice_distribution_id INVOICE_DISTRIBUTION_ID,
          APHD.invoice_payment_id INVOICE_PAYMENT_ID,
         --Bug7169843 Starts
         DECODE(AEL.Accounting_Class_Code, 'LIABILITY' ,200, null) APPLIED_TO_APPLICATION_ID,
         DECODE(AEL.Accounting_Class_Code, 'LIABILITY' ,XTE_INV.Entity_ID, null) APPLIED_TO_ENTITY_ID,
         DECODE(AEL.Accounting_Class_Code, 'LIABILITY' ,AID.Invoice_Distribution_ID, null) APPLIED_TO_DIST_ID_NUM_1,
         '-1111' GAIN_OR_LOSS_REF,  --Bug7169843 Ends
	 /* 7360647 changes start */
	  ZRD.Tax_Line_id,
          AID.Summary_Tax_Line_ID,
          AID.Detail_Tax_Dist_ID
	 /* 7360647 changes end */
  FROM   AP_Checks_All AC,
         AP_System_Parameters_All ASP,
         XLA_Upgrade_Dates UPG,
         XLA_Transaction_Entities_Upg XTE,
         XLA_Events XLE,
         AP_Payment_History_All APH,
         XLA_AE_Headers AEH,
         XLA_AE_Lines AEL,
         AP_Payment_Hist_Dists APHD,
         AP_Invoice_Distributions_All AID,
         XLA_Events XTE_INV, --Bug7169843
	 ZX_Rec_Nrec_Dist ZRD   -- 7360647 changes
  WHERE  AC.rowid BETWEEN p_start_rowid AND p_end_rowid
  AND    TRUNC(AC.Check_Date) BETWEEN UPG.Start_Date and UPG.End_Date
  AND    ASP.Set_Of_Books_ID = UPG.Ledger_ID
  AND    AC.Org_ID = ASP.Org_ID
  AND    ASP.Set_Of_Books_ID = XTE.Ledger_ID
  AND    XTE.Entity_Code = 'AP_PAYMENTS'
  AND    AC.Check_ID = nvl(XTE.Source_ID_Int_1,-99)
  AND    XTE.Application_ID = 200
  AND    XTE.Entity_ID = XLE.Entity_ID
  AND    XLE.Application_ID = 200
  AND    XLE.Event_ID = AEH.Event_ID
  AND    XLE.Upg_Batch_ID IS NOT NULL
  AND    AEH.Application_ID = 200
  AND    AEL.AE_Header_ID = AEH.AE_Header_ID
  AND    AEL.Application_ID = 200
  AND    XLE.Event_ID = APH.Accounting_Event_ID
  AND    APH.Check_ID = AC.Check_ID
  AND    APH.Payment_History_ID = APHD.Payment_History_ID
  AND    APHD.Invoice_Payment_ID = DECODE(AEL.Source_Table, 'AP_INVOICE_PAYMENTS',
                                            AEL.Source_ID, APHD.Invoice_Payment_ID)
/* AWT changes start */

/*this condition is to skip AWT Liability */
  AND DECODE(AEL.accounting_class_code, 'LIABILITY', AEL.Source_Table,'MATCH')
            <> DECODE(AEL.accounting_class_code, 'LIABILITY', 'AP_INVOICES','UNMATCH')
/*this condition is to handle AWT Lines*/
  AND   APHD.INVOICE_DISTRIBUTION_ID
              = DECODE(AEL.source_table, 'AP_INVOICE_DISTRIBUTIONS'
		        ,DECODE(AEL.Accounting_Class_Code,'AWT',AEL.source_id
			            ,APHD.INVOICE_DISTRIBUTION_ID),
                         APHD.INVOICE_DISTRIBUTION_ID)

/*this condition is to link AWT Liability and discount to respective APHD entries */
  AND DECODE(ael.accounting_class_code,'AWT','AWT','DISCOUNT','DISCOUNT',
	      aphd.pay_dist_lookup_code) = aphd.pay_dist_lookup_code

/*this condition is not to link the CASH lines to AWT and DISCOUNT */
  AND decode(AEL.source_table, 'AP_CHECKS', AEL.Accounting_Class_Code, APHD.Pay_Dist_Lookup_Code)
         = decode(AEL.source_table, 'AP_CHECKS'
               ,decode(APHD.Pay_Dist_Lookup_Code,'AWT','AWT','DISCOUNT','DISCOUNT',AEL.Accounting_Class_Code)
         ,APHD.Pay_Dist_Lookup_Code)

/*this condition is not to link the CASH LIABILITY lines to AWT */
     AND decode(AEL.source_table,
              'AP_INVOICE_PAYMENTS', DECODE(AEL.Accounting_Class_Code
                                           ,'LIABILITY','LIABILITY',APHD.Pay_Dist_Lookup_Code)
              , APHD.Pay_Dist_Lookup_Code)
     =  decode(AEL.source_table,
              'AP_INVOICE_PAYMENTS', DECODE(AEL.Accounting_Class_Code,'LIABILITY',
              DECODE(APHD.Pay_Dist_Lookup_Code,'AWT','AWT',AEL.Accounting_Class_Code),APHD.Pay_Dist_Lookup_Code)
              , APHD.Pay_Dist_Lookup_Code)

  /* AWT changes  end */

  AND    AEL.Account_Overlay_Source_ID IS NULL
  AND    APHD.Invoice_Distribution_ID = AID.Invoice_Distribution_ID
  AND    XTE_INV.Application_ID = 200 --Bug7169843
  AND    XTE_INV.Event_id = AID.Accounting_event_id
  /* 7360647 changes start */
  AND    ZRD.Rec_Nrec_Tax_Dist_ID (+) = AID.Detail_Tax_Dist_ID
  AND    ZRD.Application_id (+) = 200
  AND    ZRD.Entity_Code (+) = 'AP_INVOICES'
  /* 7360647 changes end */
  -- bug8535401
  AND    XLE.upg_batch_id IS NOT NULL
  AND    XLE.upg_batch_id <> -9999
  AND    AEH.upg_batch_id IS NOT NULL
  AND    AEH.upg_batch_id <> -9999
 ) v1;

  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_PAYMENT_DIST_LINKS',
                    'CREATE_PAYMENT_DIST_LINKS(-)');
  END IF;



EXCEPTION
  WHEN OTHERS THEN
    AP_Debug_Pkg.Print('Y', 'Payment: p_start_rowid:' ||p_start_rowid ||
                            ' p_end_rowid:'||p_end_rowid);
    AP_Debug_Pkg.Print('Y', 'Error: '||sqlcode||': '||sqlerrm);
    RAISE;

END Create_Payment_Dist_Links;


------------------------------------------------------------------
-- Procedure Create_Trial_Balance
-- Purpose
-- This procedure CREATE_TRIAL_BALANCE calls the XLA API to insert
-- the initial balances for a particular ledger
------------------------------------------------------------------
PROCEDURE Create_Trial_Balance
                (p_ledger_id                 NUMBER,
                 p_mode                      VARCHAR2,
                 p_return_status  OUT NOCOPY VARCHAR2,
                 p_msg_count      OUT NOCOPY NUMBER,
                 p_msg_data       OUT NOCOPY VARCHAR2,
                 p_calling_sequence          VARCHAR2)  IS

  l_definition_code           VARCHAR2(30);
  l_definition_name           VARCHAR2(80);
  l_definition_desc           VARCHAR2(80);
  l_ledger_id                 NUMBER(15);
  l_balance_side_code         VARCHAR2(30);
  l_je_source_name            VARCHAR2(30);
  l_upg_batch_id              NUMBER(15);
  l_mode                      VARCHAR2(30);
  l_sob_name                  VARCHAR2(30);
  l_org_count                 NUMBER;
  l_gl_date_from              DATE;
  l_gl_date_to                DATE;

  l_curr_calling_sequence     VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence := 'AP_XLA_UPGRADE_PKG.Create_Trial_Balance <-'
                                       || p_calling_sequence;

  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_TRIAL_BALANCE',
                    'CREATE_TRIAL_BALANCE(+)');
  END IF;

  l_definition_code := 'AP_200_' || p_ledger_id;
  l_ledger_id := p_ledger_id;
  l_balance_side_code := 'C';
  l_je_source_name := 'Payables';
  l_mode := p_mode;


  SELECT Name
  INTO   l_sob_name
  FROM   GL_Ledgers
  WHERE  Ledger_ID = p_ledger_id;

  l_definition_name := 'Liabilities Payables, ' || l_sob_name;
  l_definition_desc := 'Liabilities Payables, ' || l_sob_name;

  IF g_level_procedure >= g_current_runtime_level then
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_TRIAL_BALANCE',
         'Definition Name: '||l_definition_name);
  END IF;

  SELECT count(*)
  INTO   l_org_count
  FROM   AP_System_Parameters_All
  WHERE  Set_Of_Books_ID = p_ledger_id
  AND    Future_Dated_Pmt_Liab_Relief = 'MATURITY';

  IF p_mode = 'UPDATE' THEN

     BEGIN
       SELECT Start_Date,
              End_Date
       INTO   l_gl_date_from,
              l_gl_date_to
       FROM   XLA_Upgrade_Dates
       WHERE  Ledger_ID = p_ledger_id;
     EXCEPTION
       WHEN OTHERS THEN
            l_gl_date_from := NULL;
            l_gl_date_to := NULL;
     END;
  ELSE
     l_gl_date_from := NULL;
     l_gl_date_to := NULL;
  END IF;

  IF l_org_count = 0 THEN

     IF g_level_procedure >= g_current_runtime_level then
        FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_TRIAL_BALANCE',
            'Populate XLA Balances table from AP Liability table');
     END IF;

     INSERT INTO xla_tb_balances_gt
           (Definition_Code,
            Code_Combination_ID,
            Balance_Date,
            Balance_Amount)
     SELECT 'AP_200_' || p_ledger_id,
            Code_Combination_ID,
            Balance_Date,
            Balance_Amount
     FROM  (SELECT APL.Code_Combination_ID Code_Combination_ID,
                   UPG.Start_Date Balance_Date,
                   SUM(NVL(APL.Accounted_Cr,0) - NVL(APL.Accounted_Dr,0)) Balance_Amount
            FROM   AP_Liability_Balance APL,
                   XLA_Upgrade_Dates UPG
            WHERE  APL.Set_Of_Books_ID = p_ledger_id
            AND    APL.Set_Of_Books_ID = UPG.Ledger_ID
            AND    APL.Accounting_Date < UPG.Start_Date
            HAVING SUM(NVL(APL.Accounted_Cr,0) - NVL(APL.Accounted_Dr,0)) <> 0
            GROUP  BY APL.Set_Of_Books_ID,
                      APL.Code_Combination_ID,
                      UPG.Start_Date);

  ELSE

     IF g_level_procedure >= g_current_runtime_level then
        FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_TRIAL_BALANCE',
            'Populate XLA Balance GT table from Liability and Future Dated' );
     END IF;

     INSERT INTO xla_tb_balances_gt
           (Definition_Code,
            Code_Combination_ID,
            Balance_Date,
            Balance_Amount)
     SELECT 'AP_200_' || p_ledger_id,
            BAL.Code_Combination_ID,
            BAL.Balance_Date,
            SUM(BAL.Remaining_Amount)
     FROM  (SELECT APL.Set_Of_Books_ID Ledger_ID,
                   APL.Code_Combination_ID Code_Combination_ID,
                   UPG.Start_Date Balance_Date,
                   NVL(APL.Accounted_Cr,0) - NVL(APL.Accounted_Dr,0) Remaining_Amount
            FROM   AP_Liability_Balance APL,
                   XLA_Upgrade_Dates UPG
            WHERE  APL.Set_Of_Books_ID = p_ledger_id
            AND    APL.Set_Of_Books_ID = UPG.Ledger_ID
            AND    APL.Accounting_Date < UPG.Start_Date
            UNION ALL
            SELECT XEH.Ledger_ID Ledger_ID,
                   XEL.Code_Combination_ID Code_Combination_ID,
                   UPG.Start_Date Balance_Date,
                   NVL(XEL.Accounted_Cr,0) - NVL(XEL.Accounted_Dr,0) Remaining_Amount
            FROM   XLA_AE_Lines XEL,
                   XLA_AE_Headers XEH,
                   AP_Checks_ALL AC,
                   AP_System_Parameters_ALL ASP,
                   XLA_Upgrade_Dates UPG
            WHERE  XEL.Accounting_Class_Code = 'FUTURE_DATED_PMT'
            AND    XEL.AE_Header_ID = XEH.AE_Header_ID
            AND    XEH.GL_Transfer_Status_Code = 'Y'
            AND    TRUNC(XEH.Accounting_Date) < UPG.Start_Date
            AND    XEL.Source_Table = 'AP_CHECKS'
            AND    XEL.Source_ID = AC.Check_ID
            AND    AC.Org_ID = ASP.Org_ID
            AND    ASP.Set_Of_Books_ID = p_ledger_id
            AND    ASP.Set_Of_Books_ID = UPG.Ledger_ID
            AND    ASP.Future_Dated_Pmt_Liab_Relief = 'MATURITY'
            AND    NOT EXISTS (SELECT 'Payment Maturity'
                               FROM   AP_Payment_History_All APH,
                                      XLA_Events XLE,
                                      XLA_AE_Headers XEH1
                               WHERE  APH.Accounting_Event_ID = XLE.Event_ID
                               AND    XLE.Event_ID = XEH1.Event_ID
                               AND    APH.Check_ID = AC.Check_ID
                               AND    APH.Transaction_Type = 'PAYMENT MATURITY'
                               AND    TRUNC(APH.Accounting_Date) < UPG.Start_Date
                               and    XEH1.GL_Transfer_Status_Code = 'Y')) BAL
     HAVING SUM(BAL.Remaining_Amount) <> 0
     GROUP BY BAL.Ledger_ID,
              BAL.Code_Combination_ID,
              BAL.Balance_Date;

  END IF;

  IF g_level_procedure >= g_current_runtime_level then
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_TRIAL_BALANCE',
         'Calling XLA_TB_Balance_Pub.Upload_Balances API');
  END IF;

  XLA_TB_Balance_Pub.Upload_Balances
         (p_api_version => 1.0,
          p_init_msg_list => FND_API.G_TRUE,
          p_commit => FND_API.G_FALSE,
          x_return_status => p_return_status,
          x_msg_count => p_msg_count,
          x_msg_data => p_msg_data,
          p_definition_code => l_definition_code,
          p_definition_name => l_definition_name,
          p_definition_desc => l_definition_desc,
          p_ledger_id => l_ledger_id,
          p_balance_side_code => l_balance_side_code,
          p_je_source_name => l_je_source_name,
          p_gl_date_from => l_gl_date_from,
          p_gl_date_to => l_gl_date_to,
          p_mode => l_mode);

  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.CREATE_TRIAL_BALANCE',
                    'CREATE_TRIAL_BALANCE(-)');
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


END Create_Trial_Balance;


-------------------------------------------------------------------
-- PROCEDURE AP_XLA_Upgrade_Subworker
-- Purpose
-- This procedure AP_XLA_UPGRADE_SUBWORKER handles all functions
-- involved in the creation of invoice distribution links and the
-- payment distribution links during the on demand upgrade
-------------------------------------------------------------------
PROCEDURE AP_XLA_Upgrade_Subworker
               (Errbuf                  IN OUT NOCOPY VARCHAR2,
                Retcode                 IN OUT NOCOPY VARCHAR2,
                P_batch_size            IN            VARCHAR2,
                P_Worker_Id             IN            NUMBER,
                P_Num_Workers           IN            NUMBER,
                P_Inv_Script_Name       IN            VARCHAR2,
                P_Pay_Script_Name       IN            VARCHAR2) IS

  l_curr_calling_sequence     VARCHAR2(2000);

  l_status                    VARCHAR2(30);
  l_industry                  VARCHAR2(30);
  l_table_owner               VARCHAR2(30);
  l_any_rows_to_process       BOOLEAN;

  l_table_name                VARCHAR2(30);
  l_script_name               VARCHAR2(30);
  l_id_column                 VARCHAR2(30);
  l_sql_stmt                  VARCHAR2(5000);

  --Start 8725986
  --l_start_id                  NUMBER;
  --l_end_id                    NUMBER;
  l_start_rowid               rowid;
  l_end_rowid                 rowid;
  --End 8725986
  l_rows_processed            NUMBER;

  l_rows_to_process           NUMBER;
  l_restarted_ledgers         NUMBER;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);

  l_ledger_id                 NUMBER;
  l_mode                      VARCHAR2(30) := 'UPDATE';

BEGIN

  AP_Debug_Pkg.Print('Y','Inside SLA On Demand Upgrade Subworker');

  l_curr_calling_sequence := 'AP_XLA_UPGRADE_PKG.AP_XLA_Upgrade_Subworker';

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF g_level_procedure >= g_current_runtime_level then
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_SUBWORKER',
                    'AP_XLA_UPGRADE_SUBWORKER(+)');
  END IF;

  AP_Debug_Pkg.Print('Y', 'AP_XLA_UPGRADE_SUBWORKER(+)');
  AP_Debug_Pkg.Print('Y', 'Starting at '||to_char(sysdate,'HH24:MI:SS'));

  IF (FND_INSTALLATION.GET_APP_INFO('SQLAP', l_status, l_industry, l_table_owner)) THEN
      NULL;
  END IF;


  IF g_level_statement >= g_current_runtime_level then
     FND_LOG.STRING(g_level_statement,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_SUBWORKER',
         'Worker: '||P_Worker_Id ||' P_Worker_Id is ' ||  P_Worker_Id);
     FND_LOG.STRING(g_level_statement,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_SUBWORKER',
         'Worker: '||P_Worker_Id||' P_Num_Workers is ' || P_Num_Workers );
  END IF;


  l_table_name := 'AP_INVOICES_ALL';
  l_script_name := p_inv_script_name;
  --l_id_column := 'INVOICE_ID';  Bug 8725986

   --Start 8725986
  ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           l_script_name,
           p_worker_id,
           p_num_workers,
           p_batch_size, 0);

  ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           p_batch_size,
           TRUE);

  --End 8725986

  IF g_level_procedure >= g_current_runtime_level then
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_SUBWORKER',
           'Worker: '||p_worker_id );
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_SUBWORKER',
           'Worker: '||p_worker_id||' l_start_rowid is ' || l_start_rowid );
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_SUBWORKER',
           'Worker: '||p_worker_id||' l_end_rowid is ' || l_end_rowid );
  END IF;


  WHILE (l_any_rows_to_process = TRUE) LOOP

         --AP_Debug_Pkg.Print('Y', 'Start of Create_Invoice_Dist_Links');
         Create_Invoice_Dist_Links(
                         l_start_rowid,
                         l_end_rowid,
                         l_curr_calling_sequence);

         --AP_Debug_Pkg.Print('Y', 'End of Create_Invoice_Dist_Links');

         l_rows_processed := SQL%ROWCOUNT;

         --AP_Debug_Pkg.Print('Y', 'Start of Create_Prepay_Dist_Links');
         Create_Prepay_Dist_Links(
                         l_start_rowid,
                         l_end_rowid,
                         l_curr_calling_sequence);

         --AP_Debug_Pkg.Print('Y', 'End of Create_Prepay_Dist_Links');

      ad_parallel_updates_pkg.processed_rowid_range(
						  l_rows_processed,
						  l_end_rowid);
         COMMIT;

         --
         -- get new range of rowids
         --
      ad_parallel_updates_pkg.get_rowid_range(l_start_rowid,
					      l_end_rowid,
					      l_any_rows_to_process,
					      p_batch_size,
					      FALSE);

         IF g_level_procedure >= g_current_runtime_level then
            FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_SUBWORKER',
                  'Worker: '||p_worker_id );
            FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_SUBWORKER',
                  'Worker: '||p_worker_id||' l_start_rowid is ' || l_start_rowid );
            FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_SUBWORKER',
                  'Worker: '||p_worker_id||' l_end_rowid is ' || l_end_rowid );
         END IF;

  END LOOP;


  l_table_name := 'AP_CHECKS_ALL';
  l_script_name := p_pay_script_name;
  --l_id_column := 'CHECK_ID';

  --Start 8725986

  ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           l_script_name,
           p_worker_id,
           p_num_workers,
           p_batch_size, 0);

  ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           p_batch_size,
           TRUE);

--End 8725986

  IF g_level_procedure >= g_current_runtime_level then
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_SUBWORKER',
           'Worker: '||p_worker_id );
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_SUBWORKER',
           'Worker: '||p_worker_id||' l_start_rowid is ' || l_start_rowid );
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_SUBWORKER',
           'Worker: '||p_worker_id||' l_end_rowid is ' || l_end_rowid );
  END IF;

  WHILE (l_any_rows_to_process = TRUE) LOOP

         --AP_Debug_Pkg.Print('Y', 'Start of Create_Payment_Dist_Links');
         Create_Payment_Dist_Links(
                         l_start_rowid,
                         l_end_rowid,
                         l_curr_calling_sequence);

         --AP_Debug_Pkg.Print('Y', 'End of Create_Payment_Dist_Links');

         l_rows_processed := SQL%ROWCOUNT;

      ad_parallel_updates_pkg.processed_rowid_range(
						  l_rows_processed,
						  l_end_rowid);
         COMMIT;

         --
         -- get new range of rowids
         --
      ad_parallel_updates_pkg.get_rowid_range(l_start_rowid,
					      l_end_rowid,
					      l_any_rows_to_process,
					      p_batch_size,
					      FALSE);


         IF g_level_procedure >= g_current_runtime_level then
            FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_SUBWORKER',
                  'Worker: '||p_worker_id );
            FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_SUBWORKER',
                  'Worker: '||p_worker_id||' l_start_rowid is ' || l_start_rowid );
            FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_SUBWORKER',
                  'Worker: '||p_worker_id||' l_end_rowid is ' || l_end_rowid );
         END IF;

   END LOOP;

  COMMIT;

  retcode := 'Success';

  IF g_level_procedure >= g_current_runtime_level then
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_SUBWORKER',
                    'AP_XLA_UPGRADE_SUBWORKER(-)');
  END IF;

  AP_Debug_Pkg.Print('Y', 'AP_XLA_UPGRADE_SUBWORKER(-)');
  AP_Debug_Pkg.Print('Y', 'End at ' || to_char(sysdate,'HH24:MI:SS'));

EXCEPTION
  WHEN OTHERS THEN
    retcode := 'Failed';
    APP_EXCEPTION.RAISE_EXCEPTION;

END AP_XLA_Upgrade_Subworker;



-------------------------------------------------------------------
-- PROCEDURE AP_XLA_Upgrade_Main
-- Purpose
-- This procedure TRANSACTION_UPGRADE_MAIN is the main procedure
-- involved in the creation of lines and populating the new
-- distributions.
--
-- This program could be run during the PRE-UPGRADE or UPGRADE mode
-------------------------------------------------------------------
PROCEDURE AP_XLA_Upgrade_OnDemand
               (Errbuf            IN OUT NOCOPY VARCHAR2,
                Retcode           IN OUT NOCOPY VARCHAR2,
                P_Batch_Size      IN            VARCHAR2,
                P_Num_Workers     IN            NUMBER) IS

  l_curr_calling_sequence     VARCHAR2(2000);

  TYPE WorkerList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_worker                    WorkerList;

  l_errbuf                    VARCHAR2(2000);
  l_retcode                   VARCHAR2(200);

  l_result                    BOOLEAN;
  l_phase                     VARCHAR2(500) := NULL;
  l_req_status                VARCHAR2(500) := NULL;
  l_devphase                  VARCHAR2(500) := NULL;
  l_devstatus                 VARCHAR2(500) := NULL;
  l_message                   VARCHAR2(500) := NULL;
  l_child_notcomplete         BOOLEAN := TRUE;
  l_child_success             VARCHAR2(1);

  l_status                    VARCHAR2(30);
  l_industry                  VARCHAR2(30);
  l_table_owner               VARCHAR2(30);
  l_stmt                      VARCHAR2(1000);

  l_mig_status                VARCHAR2(1);
  l_gps_update_error          EXCEPTION;
  l_inv_script_name           VARCHAR2(30);
  l_pay_script_name           VARCHAR2(30);
  l_batch_id                  NUMBER;

BEGIN

  l_curr_calling_sequence := 'AP_XLA_UPGRADE_PKG.AP_XLA_Upgrade_OnDemand';

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_ONDEMAND',
                    'AP_XLA_UPGRADE_ONDEMAND(+)');
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_ONDEMAND',
                    ' Calling LAUNCH_WORKER');
  END IF;

  AP_Debug_Pkg.Print('Y', 'AP_XLA_UPGRADE_ONDEMAND(+) ');
  AP_Debug_Pkg.Print('Y', 'Starting at ' || to_char(sysdate, 'HH24:MI:SS'));
  AP_Debug_Pkg.Print('Y', 'Number of workers ' || p_num_workers);

  IF (FND_INSTALLATION.GET_APP_INFO('SQLAP', l_status, l_industry, l_table_owner)) THEN
      NULL;
  END IF;

  SELECT xla_upg_batches_s.nextval
  INTO   l_batch_id
  FROM   DUAL;

  BEGIN
    SELECT sub_module
    INTO   l_inv_script_name
    FROM   ap_invoices_upg_control
    WHERE  module_name = 'SLA_ONDEMAND_INV_UPGRADE'
    AND    end_date IS NULL;

    AP_Debug_Pkg.Print('Y', 'Existing script name for invoices '||l_inv_script_name);
  EXCEPTION
    WHEN no_data_found THEN

         l_inv_script_name := 'apidstln.sql'||l_batch_id;
         AP_Debug_Pkg.Print('Y', 'New script name for invoices '||l_inv_script_name);

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
         VALUES ('SLA_ONDEMAND_INV_UPGRADE',
                l_inv_script_name,
                'AP_SLA_ONDEMAND',
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
  END;

  BEGIN
    SELECT sub_module
    INTO   l_pay_script_name
    FROM   ap_invoices_upg_control
    WHERE  module_name = 'SLA_ONDEMAND_PAY_UPGRADE'
    AND    end_date IS NULL;

    AP_Debug_Pkg.Print('Y', 'Existing script name for payments '||l_pay_script_name);
  EXCEPTION
    WHEN no_data_found THEN

         l_pay_script_name := 'appdstln.sql'||l_batch_id;
         AP_Debug_Pkg.Print('Y', 'New script name for payments '||l_pay_script_name);

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
         VALUES ('SLA_ONDEMAND_PAY_UPGRADE',
                l_pay_script_name,
                'AP_SLA_ONDEMAND',
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
  END;


  /* When the program is run in on demand upgrade mode it is submitted from
     the concurrent program and hence we need to spawn multiple child
     workers */

  FOR i in 1..p_num_workers
  LOOP

    IF g_level_procedure >= g_current_runtime_level THEN
       FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_ONDEMAND',
                      'Submitting concurrent request for worker '||i);
    END IF;

    AP_Debug_Pkg.Print('Y', 'Submitting concurrent request for worker '||i);

    l_worker(i) := LAUNCH_WORKER(i,
                                 p_batch_size,
                                 p_num_workers,
                                 l_inv_script_name,
                                 l_pay_script_name,
                                 l_curr_calling_sequence);

  END LOOP;

  COMMIT;


  WHILE l_child_notcomplete LOOP

     dbms_lock.sleep(100);

     IF g_level_procedure >= g_current_runtime_level THEN
        FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_ONDEMAND',
                       'Inside Loop for checking the child request status');
     END IF;

     AP_Debug_Pkg.Print('Y', 'Inside Loop for checking the child request status');

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

          IF g_level_procedure >= g_current_runtime_level THEN
             FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_ONDEMAND',
                          'Loop once again');
          END IF;

          AP_Debug_Pkg.Print('Y', 'Loop once again for worker '|| l_worker(i));

          l_child_notcomplete := TRUE;
       END IF;

       --bug:8791198
       IF l_devphase = 'COMPLETE' AND l_devstatus NOT IN ('NORMAL','WARNING') THEN
          l_child_success := 'N';
       END IF;

     END LOOP;
  END LOOP;

  /* If any subworkers have failed then raise an error */
  IF l_child_success = 'N' THEN
     RAISE G_CHILD_FAILED;
  ELSE

    IF g_level_procedure >= g_current_runtime_level THEN
       FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_ONDEMAND',
                      'Setting XLA migration status to processed');
    END IF;

    AP_Debug_Pkg.Print('Y', 'Setting XLA migration status to processed');

    l_mig_status := XLA_Upgrade_Pub.Set_Migration_Status_Code
                     (200, null, null, null);

    IF l_mig_status = 'F' THEN
       RAISE l_gps_update_error;
    END IF;
  END IF;

  UPDATE AP_Invoices_Upg_Control
  SET    End_Date = Sysdate
  WHERE  Module_Name IN ('SLA_ONDEMAND_INV_UPGRADE', 'SLA_ONDEMAND_PAY_UPGRADE')
  AND    Upgrade_Phase = 'AP_SLA_ONDEMAND'
  AND    End_Date IS NULL;

  COMMIT;

  IF g_level_procedure >= g_current_runtime_level THEN
     FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_ONDEMAND',
                    'AP_XLA_UPGRADE_ONDEMAND(-)');
  END IF;

  AP_Debug_Pkg.Print('Y', 'AP_XLA_UPGRADE_ONDEMAND(-)');
  AP_Debug_Pkg.Print('Y', 'Ending at '|| to_char(sysdate,'HH24:MI:SS'));

  COMMIT;

  -- set the Return Code and the Error Buffer.
  retcode := 0;
  errbuf := 'Execution is successful';

EXCEPTION

  WHEN G_CHILD_FAILED THEN
    g_retcode := -1;
    IF g_level_procedure >= g_current_runtime_level THEN
       FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_ONDEMAND',
                      'Error in procedure AP_XLA_UPGRADE_SUBWORKER');
    END IF;
    AP_Debug_Pkg.Print('Y', 'Error in procedure AP_XLA_UPGRADE_SUBWORKER');

    errbuf := 'Error in procedure AP_XLA_UPGRADE_SUBWORKER';
    retcode := 2;

    --APP_EXCEPTION.RAISE_EXCEPTION; bug:8791198

  WHEN l_gps_update_error THEN
    g_retcode := -1;
    IF g_level_procedure >= g_current_runtime_level THEN
       FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_ONDEMAND',
                      'Error while updating migration status code');
    END IF;
    AP_Debug_Pkg.Print('Y', 'Error while updating migration status code');

    --bug:8791198
    errbuf := 'Error while updating migration status code';
    retcode := 2;

    APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
        IF g_level_procedure >= g_current_runtime_level THEN
           FND_LOG.STRING(g_level_procedure,'AP_XLA_UPGRADE_PKG.AP_XLA_UPGRADE_ONDEMAND',
                   'Error '||SQLERRM||' Calling Sequence '||l_curr_calling_sequence);
        END IF;
    END IF;

    --bug:8791198
    errbuf := 'Other: Error in procedure AP_XLA_UPGRADE_SUBWORKER';
    retcode := 2;

    APP_EXCEPTION.RAISE_EXCEPTION;

END AP_XLA_Upgrade_OnDemand;


END AP_XLA_UPGRADE_PKG;

/
