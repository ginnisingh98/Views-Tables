--------------------------------------------------------
--  DDL for Package Body AP_ACCTG_PREPAY_DIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_ACCTG_PREPAY_DIST_PKG" AS
/* $Header: appredib.pls 120.20.12010000.19 2010/04/01 23:59:16 gagrawal ship $ */

  G_Total_Dist_Amt             NUMBER := 0;
  G_Total_Prorated_Amt         NUMBER := 0;
  G_Total_Tax_Diff_Amt         NUMBER := 0;
  G_Total_Inv_Amount           NUMBER := 0; --Bug8244163
  G_Total_Dist_Amount          NUMBER := 0; --Bug8244163
  G_Total_awt_amount           NUMBER := 0; --Bug9106549

  -- Logging Infra
  G_CURRENT_RUNTIME_LEVEL      NUMBER                := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(50) := 'AP.PLSQL.AP_ACCTG_PREPAY_DIST_PKG.';
  -- Logging Infra


-------------------------------------------------------------------------------
-- PROCEDURE  UPDATE_GAIN_LOSS_IND
-- The purpose of this procedure is to update the gain_loss_indicator on the
-- prepay history table based on the exchange rates of prepayment transactions.
--
--------------------------------------------------------------------------------
PROCEDURE Update_Gain_Loss_Ind
     (P_XLA_Event_Rec      IN   ap_accounting_pay_pkg.r_xla_event_info
     ,P_Calling_Sequence   IN   VARCHAR2
     ) IS

  l_curr_calling_sequence    VARCHAR2(2000);

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Update_Gain_Loss_Ind';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_gain_loss_indicator  ap_prepay_history_all.gain_loss_indicator%type;
  l_gain_loss_indicator_parent ap_prepay_history_all.gain_loss_indicator%type;  -- bug9175969

BEGIN

  l_curr_calling_sequence := 'AP_Acctg_Prepay_Dist_Pkg.Update_Gain_Loss_Ind<- ' ||
                                      p_calling_sequence;


  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;
--added by abhsaxen for bug 9032498
--adding additional condition of escaping 'FINAL APPL ROUNDING'
--from calcuation of gain and loss accounting as it is associated with
--prepayment invoice and should not considered at the time of calcualing
--gain and loss against invoice and prepayment.

  IF (p_xla_event_rec.event_type_code ='PREPAYMENT APPLICATION ADJ') then    -- bug9175969
    SELECT aph1.Gain_Loss_Indicator
    INTO   l_gain_loss_indicator_parent
    FROM   AP_Prepay_History_All aph1,AP_Prepay_History_All APH
    WHERE  aph1.invoice_id=aph.invoice_id
    AND    aph1.accounting_event_id=aph.related_prepay_app_event_id
    AND    aph.accounting_event_id=p_xla_event_rec.event_id
    AND    rownum=1;
  END IF ;

 UPDATE AP_Prepay_History_All APH
  SET    Gain_Loss_Indicator =
                 (SELECT DECODE(APH.Transaction_Type, 'PREPAYMENT APPLIED',
                           DECODE(SIGN(SUM(APAD.Base_Amount - APAD.Base_Amt_At_Prepay_XRate)),
                                  -1, 'G', 1, 'L', NULL),
                         'PREPAYMENT UNAPPLIED',
                           DECODE(SIGN(SUM(APAD.Base_Amount - APAD.Base_Amt_At_Prepay_XRate)),
                                  1, 'G', -1, 'L', NULL),
			'PREPAYMENT APPLICATION ADJ',
			    DECODE(SIGN(SUM(APAD.Base_Amount - APAD.Base_Amt_At_Prepay_XRate)),
                                  -1, 'G', 1, 'L',
				  0,l_gain_loss_indicator_parent))       -- bug9175969
                  FROM   AP_Prepay_App_Dists APAD
                  WHERE  APAD.Prepay_History_ID = APH.Prepay_History_ID
                  AND    APAD.Accounting_Event_ID = p_xla_event_rec.event_id
                  AND    APAD.PREPAY_DIST_LOOKUP_CODE <>'FINAL APPL ROUNDING')
  WHERE  APH.Accounting_Event_ID = p_xla_event_rec.event_id;


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN

    --bug9464881
    BEGIN
      SELECT aph.gain_loss_indicator
        INTO l_gain_loss_indicator
        FROM ap_prepay_history_all aph
       WHERE APH.Accounting_Event_ID = p_xla_event_rec.event_id;

      l_log_msg := 'APH.Gain_Loss_Indicator:'|| nvl(l_gain_loss_indicator,'NULL');
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);

    EXCEPTION
      WHEN OTHERS THEN
        l_log_msg := ' Encountered an Exception:'||SQLERRM||
                     ' while fetching the gain/loss indicator ';
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
        NULL;
    END;

  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'End of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Update_Gain_Loss_Ind;


-------------------------------------------------------------------------------
-- PROCEDURE Prepay_Hist_Insert
-- The purpose of this procedure is to insert the prepayment history info
-- into the prepayment history table
--
--------------------------------------------------------------------------------
-- Bug 4996808. Inserting the prepay headers instead of in the accounting events
-- procedure
PROCEDURE Prepay_Hist_Insert
     (P_Invoice_ID         IN   NUMBER
     ,P_Calling_Sequence   IN   VARCHAR2
     ) IS

  l_curr_calling_sequence         VARCHAR2(2000);
  l_line_amount                   NUMBER;
  l_transaction_type              VARCHAR2(30);
  l_prepay_invoice_id             NUMBER;
  l_prepay_line_number            NUMBER;
  l_accounting_event_id           NUMBER;  --bug9038462
  l_org_id                        NUMBER;
  l_invoice_line_number           NUMBER;
  l_accounting_date               DATE;
  l_related_prepay_app_event_id   NUMBER;
  l_group_number                  NUMBER;

   -- Logging:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Prepay_Hist_Insert';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;


  -- bug9038462,
  -- 1. changed both parts of the union to ensure
  -- creation of a new Prepayment History record for an
  -- Unencumbered and Unaccounted Prepayment Application or
  -- Unapplication record
  --
  -- 2. fetched the accounting_event_id from the Invoice
  -- distribution to be stamped on the Prepay History record
  -- at the time of regeneration
  --
  CURSOR c_prepay_history IS
  SELECT AIL.Line_Number,
         AIL.Amount Amount,
         AIL.Prepay_Invoice_ID,
         AIL.Prepay_Line_Number,
         AID.Accounting_Event_Id,
         AIL.Org_ID,
         AID.Accounting_Date,
         -- 6718967
         DECODE(NVL(AID.Parent_Reversal_ID,-99), -99, 1, 2) Group_Number
  FROM   AP_Invoice_Lines_ALL AIL,
         AP_Invoice_Distributions_All AID
  WHERE  AIL.Invoice_ID = p_invoice_id
  AND    AIL.Line_Type_Lookup_Code = 'PREPAY'
  AND    AIL.Invoice_ID = AID.Invoice_ID
  AND    AIL.Line_Number = AID.Invoice_Line_Number
  --AND    AID.Accounting_Event_ID IS NULL
  AND    nvl(AID.posted_flag, 'N') <> 'Y'
  AND    nvl(AID.encumbered_flag, 'N') <> 'Y'
  GROUP  BY AIL.Invoice_ID, AIL.Line_Number, AIL.Amount, AIL.Prepay_Invoice_ID,
            AIL.Prepay_Line_Number, AIL.Org_ID, AID.Accounting_Date,
            AID.Accounting_Event_Id,
            -- 6718967
            DECODE(NVL(AID.Parent_Reversal_ID,-99), -99, 1, 2)
  UNION
  SELECT AID.Invoice_Line_Number,
         SUM(AID.Amount) Amount,
         AIL1.Invoice_ID,
         AIL1.Line_Number,
         AID.Accounting_Event_Id,
         AIL1.Org_ID,
         AID.Accounting_Date,
         -- 6718967
         DECODE(NVL(AID.Parent_Reversal_ID,-99), -99, 1, 2) Group_Number
  FROM   AP_Invoice_Lines AIL,
         AP_Invoice_Distributions AID,
         AP_Invoice_Lines AIL1,
         AP_Invoice_Distributions AID1
  WHERE  AID.Invoice_ID = p_invoice_id
  AND    AID.Line_Type_Lookup_Code = 'PREPAY'
  AND    AID.Invoice_ID = AIL.Invoice_ID
  AND    AID.Invoice_Line_Number = AIL.Line_Number
  AND    AIL.Line_Type_Lookup_Code <> 'PREPAY'
  --AND    AID.Accounting_Event_ID IS NULL
  AND    NVL(AID.posted_flag, 'N') <> 'Y'
  AND    NVL(AID.encumbered_flag, 'N') <> 'Y'
  AND    AID.Prepay_Distribution_ID = AID1.Invoice_Distribution_ID
  AND    AIL1.Invoice_ID = AID1.Invoice_ID
  AND    AIL1.Line_Number = AID1.Invoice_Line_Number
  GROUP  BY AIL1.Invoice_ID, AIL1.Line_Number, AIL1.Org_ID,
            AID.Invoice_Line_Number, AID.Accounting_Date,
            AID.Accounting_Event_Id,
            -- 6718967
            DECODE(NVL(AID.Parent_Reversal_ID,-99), -99, 1, 2);


BEGIN

  l_curr_calling_sequence := p_calling_sequence ||
            ' -> AP_ACCTG_PREPAY_DISTS_PKG.PREPAY_HIST_INSERT';

  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  l_log_msg :='Begin of procedure '||l_procedure_name;
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    l_log_msg);
  END IF;

  OPEN c_prepay_history;
  LOOP
    FETCH c_prepay_history INTO l_invoice_line_number,
          l_line_amount, l_prepay_invoice_id, l_prepay_line_number,
          l_accounting_event_id, l_org_id, l_accounting_date, l_group_number;
    EXIT WHEN c_prepay_history%NOTFOUND OR
              c_prepay_history%NOTFOUND IS NULL;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'CUR: C_Prepay_History: prepay_invoice_id = '||
                                           l_prepay_invoice_id
                     || ' Prepay_Line_Number = ' || l_prepay_line_number
                     || ' Invoice_Line_Number = ' ||l_invoice_line_number;
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;


    BEGIN

      SELECT min(accounting_Event_id)
      INTO   l_related_prepay_app_event_id
      FROM   AP_INVOICE_DISTRIBUTIONS AID
      WHERE  AID.line_type_lookup_code = 'PREPAY'
      AND    nvl(posted_flag,'N') = 'Y'
      AND    nvl(AID.amount,0) < 0
      AND    AID.invoice_id = P_invoice_id
      AND    AID.invoice_line_number = l_invoice_line_number;


    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_related_prepay_app_event_id:= null;

    END;

    -- Bug 6718967. Added group number to identify if it is
    -- prepayment applied or unapplied.
    IF l_group_number = 1 THEN
      l_transaction_type := 'PREPAYMENT APPLIED';
    ELSE
      l_transaction_type := 'PREPAYMENT UNAPPLIED';
    END IF;


    INSERT INTO AP_PREPAY_HISTORY_ALL
          (PREPAY_HISTORY_ID
          ,PREPAY_INVOICE_ID
          ,PREPAY_LINE_NUM
          ,ACCOUNTING_EVENT_ID
          ,HISTORICAL_FLAG
          ,INVOICE_ID
          ,INVOICE_LINE_NUMBER
          ,ACCOUNTING_DATE
          ,INVOICE_ADJUSTMENT_EVENT_ID
          ,ORG_ID
          ,POSTED_FLAG
          ,RELATED_PREPAY_APP_EVENT_ID
          ,TRANSACTION_TYPE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
          ,CREATED_BY
          ,CREATION_DATE
          ,PROGRAM_APPLICATION_ID
          ,PROGRAM_ID
          ,PROGRAM_UPDATE_DATE
          ,REQUEST_ID)
   VALUES (AP_PREPAY_HISTORY_S.nextval
          ,l_prepay_invoice_id
          ,l_prepay_line_number
          ,l_accounting_event_id   --bug9038462
          ,'N'
          ,p_invoice_id
          ,l_invoice_line_number
          ,l_accounting_date
          ,NULL
          ,l_org_id
          ,'N'
          ,l_related_prepay_app_event_id
          ,l_transaction_type
          ,FND_GLOBAL.user_id
          ,sysdate
          ,FND_GLOBAL.login_id
          ,FND_GLOBAL.user_id
          ,sysdate
          ,null
          ,null
          ,null
          ,null);

  END LOOP;
  CLOSE c_prepay_history;

  l_log_msg :='End of procedure '||l_procedure_name;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME || l_procedure_name,
                     l_log_msg);
  END IF;

END Prepay_Hist_Insert;



-------------------------------------------------------------------------------
-- PROCEDURE Prepay_Dist_Appl
-- The purpose of this procedure is to prorate the prepayment application
-- amount for all the distributions of the invoice that the prepayment is applied
-- and generate the prepayment application distributions.
--
--------------------------------------------------------------------------------
PROCEDURE Prepay_Dist_Appl
     (P_Invoice_ID         IN   NUMBER
     ,P_Calling_Sequence   IN   VARCHAR2
     ) IS

  l_curr_calling_sequence    VARCHAR2(2000);
  l_total_paid_amt           NUMBER;
  l_final_payment            BOOLEAN := FALSE;

  l_pay_hist_rec             ap_accounting_pay_pkg.r_pay_hist_info;
  l_clr_hist_rec             ap_accounting_pay_pkg.r_pay_hist_info;
  l_inv_rec                  ap_accounting_pay_pkg.r_invoices_info;
  l_prepay_inv_rec           ap_accounting_pay_pkg.r_invoices_info;
  l_inv_dist_rec             ap_accounting_pay_pkg.r_inv_dist_info;
  l_prepay_hist_rec          r_prepay_hist_info;
  l_prepay_dist_rec          r_prepay_dist_info;

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Prepay_Dist_Appl';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  -- BUG # 7688509
  -- condition: historical_flag =Y
  --         and event is 'INVOICE ADJUSTMENT'
  --         and ap_system_parameter.auto_offset_flag ='N'
  --         and sum of the distributions in the invoice adjustment event is 0
  b_generate_prepay_dist   BOOLEAN;
  l_sum_per_event       NUMBER;
  l_dist_count_per_event       NUMBER;

  CURSOR c_sum_per_event(p_acct_event_id  NUMBER) IS
  SELECT SUM(amount), count(1)
    FROM ap_invoice_distributions_all aid,
         xla_events evnt,
	 xla_ae_headers xah,
         ap_system_parameters_all asp
   WHERE aid.accounting_event_id = p_acct_event_id
     AND aid.accounting_event_id = evnt.event_id
     AND evnt.event_type_code in ('INVOICE ADJUSTED', 'CREDIT MEMO ADJUSTED',
                                  'DEBIT MEMO ADJUSTED')
     AND evnt.event_id = xah.event_id
     AND xah.upg_batch_id IS NOT NULL
     AND aid.org_id = asp.org_id
     AND asp.automatic_offsets_flag = 'N'
     AND aid.historical_flag = 'Y'
     AND evnt.application_id=200;

BEGIN

  l_curr_calling_sequence := 'AP_ACCTG_PREPAY_DIST_PKG.Prepay_Dist_Appl<- ' ||
                                      p_calling_sequence;

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;

  -- Bug Fix 5634515
  -- deleting previous unprocessed prepayment history records for invoice
  delete_hist_dists(P_Invoice_ID,
                    l_curr_calling_sequence);

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'calling procedure Prepay_Hist_Insert ';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  /* Bug 4996808. Inserting into the prepayment history table */
  Prepay_Hist_Insert (P_Invoice_ID,
                      l_curr_calling_sequence);


  /* Get the prepayment history header info */
  OPEN Prepay_History(P_Invoice_ID);
  LOOP
    FETCH Prepay_History INTO l_prepay_hist_rec;
    EXIT WHEN Prepay_History%NOTFOUND OR
              Prepay_History%NOTFOUND IS NULL;



    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'CUR: Prepay_History: prepay_history_id = '||
                                           l_prepay_hist_rec.prepay_history_id
                     || ' Prepay_Invoice_ID = ' || l_prepay_hist_rec.Prepay_Invoice_ID
                     || ' Invoice_ID = ' ||l_prepay_hist_rec.Invoice_ID;
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;


    /* Get the standard invoice header info */
    OPEN Invoice_Header(P_Invoice_ID);
    FETCH Invoice_Header INTO l_inv_rec;
    CLOSE Invoice_Header;


    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'CUR: Invoice_Header: Invoice_ID = '|| l_prepay_hist_rec.invoice_id;
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;


    /* Get the prepayment invoice header info */
    OPEN Invoice_Header(l_prepay_hist_rec.prepay_invoice_id);
    FETCH Invoice_Header INTO l_prepay_inv_rec;
    CLOSE Invoice_Header;


    /* Get the payment history info */
    OPEN Payment_History
              (l_prepay_hist_rec.prepay_invoice_id,
               'PAYMENT CREATED');
    FETCH Payment_History INTO l_pay_hist_rec;
    CLOSE Payment_History;


    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'CUR: Payment_History for payment: Payment_History_ID = '||
                                          l_pay_hist_rec.payment_history_id;
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;


    /* Get the clearing payment history info */
    OPEN Payment_History
              (l_prepay_hist_rec.prepay_invoice_id,
               'PAYMENT CLEARING');
    FETCH Payment_History INTO l_clr_hist_rec;
    CLOSE Payment_History;


    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'CUR: Payment_History for clearing: Payment_History_ID = '||
                                          l_clr_hist_rec.payment_history_id;
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;


    /* Get the prepay distributions for this event */
    OPEN Prepay_Dists(P_Invoice_ID,
                      l_prepay_hist_rec.invoice_line_number,
                      l_prepay_hist_rec.accounting_date,
                      l_prepay_hist_rec.prepay_history_id);
    LOOP

       FETCH Prepay_Dists INTO l_prepay_dist_rec;
       EXIT WHEN Prepay_Dists%NOTFOUND OR
                 Prepay_Dists%NOTFOUND IS NULL;


       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'CUR: Prepay_Dists: Invoice_ID = '||l_prepay_dist_rec.invoice_id
                        ||' Invoice_Distribution_ID = '||l_prepay_dist_rec.invoice_distribution_id
                        ||' Prepay_Distribution_ID = '||l_prepay_dist_rec.prepay_distribution_id;
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;


       IF l_prepay_dist_rec.parent_reversal_id IS NOT NULL THEN

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'CUR: Prepay_Dists: Invoice_Distribution_ID = '
                           ||l_prepay_dist_rec.invoice_distribution_id
                           ||' Parent_Reversal_ID = '||l_prepay_dist_rec.parent_reversal_id;
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
              l_log_msg := 'Calling procedure Prepay_Dist_Reverse for prepay dist: '
                                || l_prepay_dist_rec.invoice_distribution_id;
              FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
          END IF;


          /* Creating prepayment appl dists for unapplication by reversing the prepay appl
             distributions */
          Prepay_Dist_Reverse
            (l_prepay_hist_rec,
             l_prepay_dist_rec.parent_reversal_id,
             NULL,  -- p_xla_event_rec
             NULL,  -- p_inv_reversal_id
             -- Bug 7134020
             NULL,  -- p_inv_dist_id
             l_prepay_dist_rec.invoice_distribution_id,
             l_curr_calling_sequence);


          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
              l_log_msg := 'Procedure Prepay_Dist_Reverse executed';
              FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
          END IF;

       ELSE

          /* Check if the invoice is fully paid */
          l_final_payment := AP_Accounting_Pay_Pkg.Is_Final_Payment
                                       (l_inv_rec,
                                        NULL, -- Payment Amount
                                        NULL, -- Discount Amount
                                        l_prepay_dist_rec.amount,
                                        'PAYMENT CREATED',
                                        l_curr_calling_sequence);

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              IF l_final_payment THEN
                 l_log_msg := 'Final payment of Invoice_ID '||l_prepay_dist_rec.invoice_id;
              ELSE
                 l_log_msg := 'Not final payment of Invoice_ID '||l_prepay_dist_rec.invoice_id;
              END IF;
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;
	  --8244163 This query exists 3 places in this package pls make sure that
          --you are modifying in all the places
	  SELECT SUM(NVL(AID.Amount,0)),
                 SUM(DECODE(aid.line_type_lookup_code, 'AWT', 0, NVL(AID.Amount,0) ) ),
                 SUM(DECODE(aid.line_type_lookup_code, 'AWT', NVL(AID.Amount,0),0 ) )
            INTO G_Total_Dist_amount,
                 G_Total_Inv_amount,
                 G_Total_awt_amount    --Bug9106549
            FROM AP_Invoice_Distributions_All AID
           WHERE AID.Invoice_ID = p_invoice_id
             AND AID.Line_Type_Lookup_Code <> 'PREPAY'
             AND AID.Prepay_Distribution_ID IS NULL
             AND AID.Prepay_Tax_Parent_ID IS NULL -- For tax dists created in R11.5
             AND AID.AWT_Invoice_Payment_ID IS NULL
             AND NVL(AID.Cancellation_Flag,'N') <> 'Y' -- BUG 6513956
             AND NOT EXISTS (SELECT 1                  --bug fix 6909150
                               FROM xla_events
                              WHERE event_id = AID.accounting_event_id
					            AND application_id = 200
                                AND event_type_code IN ('INVOICE CANCELLED',
                                                        'CREDIT MEMO CANCELLED',
                                                        'DEBIT MEMO CANCELLED'));

          OPEN Invoice_Dists(p_invoice_id);
          LOOP

            FETCH Invoice_Dists INTO l_inv_dist_rec;
            EXIT WHEN Invoice_Dists%NOTFOUND OR
                      Invoice_Dists%NOTFOUND IS NULL;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                l_log_msg := 'CUR: Invoice_Dists: Invoice_Distribution_ID = '
                                     ||l_inv_dist_rec.invoice_distribution_id;
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;


            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                l_log_msg := 'Calling procedure Prepay_Dist_Proc for dist: '
                                  || l_inv_dist_rec.invoice_distribution_id;
                FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
            END IF;

            -- BUG # 7688509
	    -- condition: historical_flag =Y
            --         and event is 'INVOICE ADJUSTED'
            --         and ap_system_parameter.auto_offset_flag ='N'
            --         and sum of the distributions in the invoice adjustment event is 0

            b_generate_prepay_dist := TRUE;
            IF  l_inv_dist_rec.historical_flag ='Y' THEN
              OPEN c_sum_per_event(l_inv_dist_rec.accounting_event_id);
              FETCH c_sum_per_event into l_sum_per_event, l_dist_count_per_event;

              -- > 0 case is to handled the case that only  1 line in adjustment event and itself amount is 0
              If l_dist_count_per_event > 0 AND l_sum_per_event = 0 THEN
                b_generate_prepay_dist := FALSE;
              END IF;

              CLOSE c_sum_per_event;

            END IF;

            -- Prorate only those awt distributions that were created during the invoice time
	    -- modified the if condition for bug # 7688509
            IF l_inv_dist_rec.awt_invoice_payment_id IS NULL  and b_generate_prepay_dist THEN
               Prepay_Dist_Proc
                         (l_pay_hist_rec,
                          l_clr_hist_rec,
                          l_inv_rec,
                          l_prepay_inv_rec,
                          l_prepay_hist_rec,
                          l_prepay_dist_rec,
                          l_inv_dist_rec,
                          NULL,  -- p_xla_event_rec
                          'A',
                          l_final_payment,
                          l_curr_calling_sequence);
            END IF;


            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                l_log_msg := 'Procedure Prepay_Dist_Proc executed';
                FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
            END IF;

          END LOOP;
          CLOSE Invoice_Dists;

          G_Total_Dist_Amt := 0;
          G_Total_Prorated_Amt := 0;
          G_Total_Tax_Diff_Amt := 0;


          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
              l_log_msg := 'Calling procedure P_Acctg_Pay_Round_Pkg.Do_Rounding for Invoice_ID: '
                                    || l_inv_rec.invoice_id;
              FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
          END IF;

          -- bug 7611160
          SELECT asp.base_currency_code
          INTO ap_accounting_pay_pkg.g_base_currency_code
          FROM ap_system_parameters_all asp,
               ap_invoices_all ai
          WHERE asp.org_id = ai.org_id
            AND ai.invoice_id = l_inv_rec.invoice_id;

          AP_Acctg_Pay_Round_Pkg.Do_Rounding
                     (NULL, -- p_xla_event_rec
                      l_pay_hist_rec,
                      l_clr_hist_rec,
                      l_inv_rec,
                      NULL, -- l_inv_pay_rec
                      l_prepay_inv_rec,
                      l_prepay_hist_rec,
                      l_prepay_dist_rec,
                      l_curr_calling_sequence);

          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
              l_log_msg := 'Procedure P_Acctg_Pay_Round_Pkg.Do_Rounding executed';
              FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
          END IF;

       END IF;
    END LOOP;
    CLOSE Prepay_Dists;

  END LOOP;
  CLOSE Prepay_History;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'End of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Prepay_Dist_Appl;


-------------------------------------------------------------------------------
-- PROCEDURE  Prepay_Dist_Cascade_Adj
-- The purpose of this procedure is to prorate the prepayment amount for all the
-- distributions of the invoice that has been adjusted and generate the
-- prepayment application payment distributions.
--
--------------------------------------------------------------------------------
PROCEDURE Prepay_Dist_Cascade_Adj
     (P_XLA_Event_Rec      IN   ap_accounting_pay_pkg.r_xla_event_info
     ,P_Calling_Sequence   IN   VARCHAR2
     ) IS

  l_curr_calling_sequence    VARCHAR2(2000);
  l_inv_adj_amount           NUMBER := 0;
  l_sum_prepaid_amount       NUMBER := 0;
  l_sum_tax_diff_amount      NUMBER := 0;

  l_pay_hist_rec           ap_accounting_pay_pkg.r_pay_hist_info;
  l_clr_hist_rec           ap_accounting_pay_pkg.r_pay_hist_info;
  l_prepay_inv_rec         ap_accounting_pay_pkg.r_invoices_info;
  l_inv_rec                ap_accounting_pay_pkg.r_invoices_info;
  l_prepay_hist_rec        r_prepay_hist_info;
  l_prepay_dist_rec        r_prepay_dist_info;
  l_inv_dist_rec           ap_accounting_pay_pkg.r_inv_dist_info;
  l_rounding_adjust_id     NUMBER; --bug8201141
  --7488981
  l_prepay_dist_cnt           NUMBER;

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Prepay_Dist_Cascade_Adj';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  -- Bug 6698125. Added adj cursor to get the prepay history record
  -- related to prepayment adjustment type events.
  CURSOR Prepay_History_Adj
        (P_Invoice_ID    NUMBER,
         P_Event_ID      NUMBER
        ) IS
  SELECT APH.Prepay_History_ID,
         APH.Prepay_Invoice_ID,
         APH.Invoice_ID,
         APH.Invoice_Line_Number,
         APH.Transaction_Type,
         APH.Accounting_Date,
         APH.Invoice_Adjustment_Event_ID,
         APH.Related_Prepay_App_Event_ID
  FROM   AP_Prepay_History_All APH
  WHERE  APH.Invoice_ID = P_Invoice_ID
  AND    APH.Accounting_Event_ID = P_Event_ID;

  CURSOR Inv_Adj_Dists
        (P_Event_ID             NUMBER
        ,P_Invoice_ID           NUMBER) IS
  SELECT Distinct AID.Invoice_Distribution_ID,
         AID.Line_Type_Lookup_Code,
         AID.Amount,
         AID.Base_Amount,
         AID.PO_Distribution_ID,
         AID.RCV_Transaction_ID,
         NVL(AID.Reversal_Flag,'N'),
         AID.Parent_Reversal_ID,
         AID.AWT_Related_ID,
         AID.AWT_Invoice_Payment_ID,
         AID.Quantity_Variance,
         AID.Base_Quantity_Variance,
         AID.Amount_Variance,
         AID.Base_Amount_Variance,
         AID.Historical_Flag,   -- bug fix 6674279
         AID.Accounting_Event_Id  -- bug fix 6674279
  FROM   AP_Invoice_Distributions_All AID,
         AP_Prepay_App_Dists APAD,
         Financials_System_Params_All FSP
  WHERE  AID.Invoice_ID = P_Invoice_ID
  AND    NVL(AID.Reversal_Flag,'N') <> 'Y'
  AND    NVL(AID.Accounting_Event_ID,-99) <> P_Event_ID
  AND    APAD.Invoice_Distribution_ID = AID.Invoice_Distribution_ID
  AND    FSP.Org_ID = AID.Org_ID
  AND  ((NVL(FSP.Purch_Encumbrance_Flag,'N') = 'N'
             AND AID.Match_Status_Flag IN ('T','A'))
         OR
       ((NVL(FSP.Purch_Encumbrance_Flag,'N') = 'Y'
             AND AID.Match_Status_Flag = 'A')));

  CURSOR Prepay_Adj_Dists
        (P_Event_ID             NUMBER,
         P_Prepay_History_ID    NUMBER
        ) IS
 (SELECT AID.Invoice_ID,
         AID.Invoice_Distribution_ID,
         AID.Line_Type_Lookup_Code,
         AID.Amount,
         AID.Base_Amount,
         AID.Accounting_Event_ID,
         AID.Prepay_Distribution_ID,
         AID.Prepay_Tax_Diff_Amount,
         AID.Parent_Reversal_ID
  FROM   AP_Invoice_Distributions_All AID
  WHERE  Accounting_Event_ID = P_Event_ID
  AND    EXISTS (SELECT 'Prepay History'
                 FROM   AP_Prepay_History_All APH,
                        AP_Invoice_Distributions_All AID1
                 WHERE  APH.Prepay_History_ID = P_Prepay_History_ID
                 AND    AID1.Invoice_Distribution_ID = AID.Prepay_Distribution_ID
                 AND    AID1.Invoice_ID = APH.Prepay_Invoice_ID
                 AND    AID1.Invoice_Line_Number = APH.Prepay_Line_Num)
  UNION ALL
  SELECT AID.Invoice_ID,
         AID.Invoice_Distribution_ID,
         AID.Line_Type_Lookup_Code,
         AID.Amount,
         AID.Base_Amount,
         AID.Accounting_Event_ID,
         AID.Prepay_Distribution_ID,
         AID.Prepay_Tax_Diff_Amount,
         AID.Parent_Reversal_ID
  FROM   AP_Invoice_Distributions_All AID
  WHERE  Line_Type_Lookup_Code IN ( 'NONREC_TAX','REC_TAX')
  AND    Accounting_Event_ID = P_Event_ID
  AND    Charge_Applicable_To_Dist_ID IN
               (SELECT AID1.Invoice_Distribution_ID
                FROM   AP_Invoice_Distributions_All AID1
                WHERE  Line_Type_Lookup_Code = 'PREPAY'
                AND    Accounting_Event_ID = P_Event_ID
                AND    EXISTS (SELECT 'Prepay History'
                               FROM   AP_Prepay_History_All APH,
                                      AP_Invoice_Distributions_All AID2
                               WHERE  APH.Prepay_History_ID = P_Prepay_History_ID
                               AND    AID2.Invoice_Distribution_ID = AID1.Prepay_Distribution_ID
                               AND    AID2.Invoice_ID = APH.Prepay_Invoice_ID
                               AND    AID2.Invoice_Line_Number = APH.Prepay_Line_Num)));



BEGIN

  l_curr_calling_sequence := 'AP_Acctg_Pay_Dist_Pkg.Prepay_Dist_Cascade_Adj<- ' ||
                                      p_calling_sequence;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;


  /* Get the prepayment history header info */
  OPEN Prepay_History_Adj(P_XLA_Event_Rec.Source_id_int_1,
                          P_XLA_Event_Rec.Event_ID);
  FETCH Prepay_History_Adj INTO l_prepay_hist_rec;
  CLOSE Prepay_History_Adj;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'CUR: Prepay_History: prepay_history_id = '||
                                         l_prepay_hist_rec.prepay_history_id
                   || ' Prepay_Invoice_ID = ' || l_prepay_hist_rec.Prepay_Invoice_ID
                   || ' Invoice_ID = ' ||l_prepay_hist_rec.Invoice_ID
                   || ' Related_Event_ID = ' ||l_prepay_hist_rec.related_prepay_app_event_id
                   || ' Inv_Adj_Event_ID = ' ||l_prepay_hist_rec.invoice_adjustment_event_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  /* Get the standard invoice header info */
  OPEN Invoice_Header(P_XLA_Event_Rec.source_id_int_1);
  FETCH Invoice_Header INTO l_inv_rec;
  CLOSE Invoice_Header;


  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'CUR: Invoice_Header: Invoice_ID = '|| l_prepay_hist_rec.invoice_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  /* Get the prepayment invoice header info */
  OPEN Invoice_Header(l_prepay_hist_rec.prepay_invoice_id);
  FETCH Invoice_Header INTO l_prepay_inv_rec;
  CLOSE Invoice_Header;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'CUR: Prepay Invoice_Header: Invoice_ID = '|| l_prepay_inv_rec.invoice_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  /* Get the payment history info */
  OPEN Payment_History
              (l_prepay_hist_rec.prepay_invoice_id,
               'PAYMENT CREATED');
  FETCH Payment_History INTO l_pay_hist_rec;
  CLOSE Payment_History;


  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'CUR: Payment_History for payment: Payment_History_ID = '||
                                          l_pay_hist_rec.payment_history_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  /* Get the clearing payment history info */
  OPEN Payment_History
              (l_prepay_hist_rec.prepay_invoice_id,
               'PAYMENT CLEARING');
  FETCH Payment_History INTO l_clr_hist_rec;
  CLOSE Payment_History;


  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'CUR: Payment_History for clearing: Payment_History_ID = '||
                                          l_clr_hist_rec.payment_history_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  /* Get the prepay dists based on the related event id */
  OPEN Prepay_Adj_Dists(l_prepay_hist_rec.related_prepay_app_event_id,
                        l_prepay_hist_rec.prepay_history_id);
  LOOP

       FETCH Prepay_Adj_Dists INTO l_prepay_dist_rec;
       EXIT WHEN Prepay_Adj_Dists%NOTFOUND OR
                 Prepay_Adj_Dists%NOTFOUND IS NULL;


       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'CUR: Prepay_Dists: Invoice_ID = '||l_prepay_dist_rec.invoice_id
                        ||' Invoice_Distribution_ID = '||l_prepay_dist_rec.invoice_distribution_id
                        ||' Prepay_Distribution_ID = '||l_prepay_dist_rec.prepay_distribution_id;
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;
       --8244163 This query exists 3 places in this package pls make sure that
       --you are modifying in all the places
       SELECT SUM(NVL(AID.Amount,0)),
              SUM(DECODE(aid.line_type_lookup_code, 'AWT', 0, NVL(AID.Amount,0) ) )
         INTO G_Total_Dist_amount,
              G_Total_Inv_amount
         FROM AP_Invoice_Distributions_All AID
        WHERE AID.Invoice_ID = l_prepay_hist_rec.invoice_id
          AND AID.Line_Type_Lookup_Code <> 'PREPAY'
          AND AID.Prepay_Distribution_ID IS NULL
          AND AID.Prepay_Tax_Parent_ID IS NULL -- For tax dists created in R11.5
          AND AID.AWT_Invoice_Payment_ID IS NULL
          AND NVL(AID.Cancellation_Flag,'N') <> 'Y' -- BUG 6513956
          AND NOT EXISTS (SELECT 1                  --bug fix 6909150
                            FROM xla_events
                           WHERE event_id = AID.accounting_event_id
			                 AND application_id = 200
                             AND event_type_code IN ('INVOICE CANCELLED',
                                                     'CREDIT MEMO CANCELLED',
                                                     'DEBIT MEMO CANCELLED'));

       OPEN Invoice_Dists(l_prepay_hist_rec.invoice_id,
                          l_prepay_hist_rec.invoice_adjustment_event_id);
       LOOP

            FETCH Invoice_Dists INTO l_inv_dist_rec;
            EXIT WHEN Invoice_Dists%NOTFOUND OR
                      Invoice_Dists%NOTFOUND IS NULL;


            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                l_log_msg := 'CUR: Invoice_Dists: Invoice_Distribution_ID = '
                                     ||l_inv_dist_rec.invoice_distribution_id
                                || ' Reversal_Flag = ' ||l_inv_dist_rec.reversal_flag;
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;

  -- in bug 7488981 call to prepay_dist_reverse was made  with null parent_reversal_id
  -- therefore the following check is added to check that
            l_prepay_dist_cnt := 0; --7686421
            IF l_inv_dist_rec.parent_reversal_id IS NOT NULL THEN

               SELECT count(*)
               INTO   l_prepay_dist_cnt
               FROM   ap_prepay_app_dists
               WHERE  invoice_distribution_id = l_inv_dist_rec.parent_reversal_id;

            END IF;

            IF l_inv_dist_rec.reversal_flag = 'Y' AND
               l_prepay_dist_cnt > 0 THEN


               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   l_log_msg := 'Calling procedure Prepay_Dist_Reverse for dist: '
                                     || l_inv_dist_rec.invoice_distribution_id;
                   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
               END IF;

               Prepay_Dist_Reverse
                         (l_prepay_hist_rec,
                          NULL, -- p_prepay_reversal_id
                          p_xla_event_rec, -- Bug 6698125
                          l_inv_dist_rec.parent_reversal_id,
                          l_inv_dist_rec.invoice_distribution_id, -- Bug 7134020
                          l_prepay_dist_rec.invoice_distribution_id,
                          l_curr_calling_sequence);

               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   l_log_msg := 'Procedure Prepay_Dist_Reverse executed';
                   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
               END IF;

            ELSE

               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   l_log_msg := 'Calling procedure Prepay_Dist_Proc for dist: '
                                     || l_inv_dist_rec.invoice_distribution_id;
                   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
               END IF;

               -- Prorate only those awt distributions that were created during the invoice time
               IF (l_inv_dist_rec.awt_invoice_payment_id IS NULL) THEN
                   Prepay_Dist_Proc
                         (l_pay_hist_rec,
                          l_clr_hist_rec,
                          l_inv_rec,
                          l_prepay_inv_rec,
                          l_prepay_hist_rec,
                          l_prepay_dist_rec,
                          l_inv_dist_rec,
                          p_xla_event_rec, -- Bug 6698125
                          'C',
                          NULL,
                          l_curr_calling_sequence);
               END IF;

               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   l_log_msg := 'Procedure Prepay_Dist_Proc executed';
                   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
               END IF;

            END IF;

       END LOOP;
       CLOSE Invoice_Dists;


       SELECT SUM(AID.Amount)
       INTO   l_inv_adj_amount
       FROM   AP_Invoice_Distributions_All AID
       WHERE  AID.Accounting_Event_ID = l_prepay_hist_rec.invoice_adjustment_event_id;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'l_inv_adj_amount = ' ||l_inv_adj_amount;
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

      /* Check if there is any change to the invoice liability. If there is
          a change then we need to adjust the payment hist distributions for the
          old invoice distributions */


       IF l_inv_adj_amount <> 0 THEN

       --8244163 This query exists 3 places in this package pls make sure that
       --you are modifying in all the places
       SELECT SUM(NVL(AID.Amount,0)),
              SUM(DECODE(aid.line_type_lookup_code, 'AWT', 0, NVL(AID.Amount,0) ) )
         INTO G_Total_Dist_amount,
              G_Total_Inv_amount
         FROM AP_Invoice_Distributions_All AID
        WHERE AID.Invoice_ID = l_inv_rec.invoice_id
          AND AID.Line_Type_Lookup_Code <> 'PREPAY'
          AND AID.Prepay_Distribution_ID IS NULL
          AND AID.Prepay_Tax_Parent_ID IS NULL -- For tax dists created in R11.5
          AND AID.AWT_Invoice_Payment_ID IS NULL
          AND NVL(AID.Cancellation_Flag,'N') <> 'Y' -- BUG 6513956
          AND NOT EXISTS (SELECT 1                  --bug fix 6909150
                            FROM xla_events
                           WHERE event_id = AID.accounting_event_id
			                 AND application_id = 200
                             AND event_type_code IN ('INVOICE CANCELLED',
                                                     'CREDIT MEMO CANCELLED',
                                                     'DEBIT MEMO CANCELLED'));

          OPEN Inv_Adj_Dists(l_prepay_hist_rec.invoice_adjustment_event_id,
                             l_inv_rec.invoice_id);
          LOOP

               FETCH Inv_Adj_Dists INTO l_inv_dist_rec;
               EXIT WHEN Inv_Adj_Dists%NOTFOUND OR
                         Inv_Adj_Dists%NOTFOUND IS NULL;


               IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   l_log_msg := 'CUR: Inv_Adj_Dists: Invoice_Distribution_ID = '
                                   ||l_inv_dist_rec.invoice_distribution_id;
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
               END IF;

               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   l_log_msg := 'Calling procedure Prepay_Dist_Proc for dist: '
                                    ||l_inv_dist_rec.invoice_distribution_id;
                   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
               END IF;

               Prepay_Dist_Proc(l_pay_hist_rec,
                                l_clr_hist_rec,
                                l_inv_rec,
                                l_prepay_inv_rec,
                                l_prepay_hist_rec,
                                l_prepay_dist_rec,
                                l_inv_dist_rec,
                                p_xla_event_rec, -- Bug 6698125
                                'C',
                                NULL,
                                l_curr_calling_sequence);

               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   l_log_msg := 'Procedure Prepay_Dist_Proc executed';
                   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
               END IF;


          END LOOP;
          CLOSE Inv_Adj_Dists;
       END IF;

       SELECT MAX(accounting_event_id) into l_rounding_adjust_id   --8201141
         FROM ap_prepay_history_all
        WHERE transaction_type = 'PREPAYMENT APPLICATION ADJ'
          AND posted_flag <> 'Y'
          AND prepay_invoice_id = l_prepay_hist_rec.prepay_invoice_id
          AND invoice_id = l_prepay_hist_rec.invoice_id;

       IF ( l_rounding_adjust_id = p_xla_event_rec.event_id ) THEN

        -- joined with ap_invoice_distributions_all for the performance issue 7235352
       SELECT /*+ leading(aid) */ SUM(DECODE(APAD.Prepay_Dist_Lookup_Code, 'PREPAY APPL', APAD.Amount,
                                  'PREPAY APPL REC TAX', APAD.Amount,
                                  'PREPAY APPL NONREC TAX', APAD.Amount,  0)),
              SUM(DECODE(APAD.Prepay_Dist_Lookup_Code, 'TAX DIFF', APAD.Amount, 0))
       INTO   l_sum_prepaid_amount,
              l_sum_tax_diff_amount
       FROM   AP_Prepay_App_Dists APAD,
              ap_invoice_distributions_all aid
       WHERE  APAD.Prepay_App_Distribution_ID = l_prepay_dist_rec.invoice_distribution_id
              AND apad.invoice_distribution_id = aid.invoice_distribution_id
              AND aid.invoice_id = l_prepay_dist_rec.invoice_id;


       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'Updating the prorated prepaid amounts';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

         -- bug 9240725
       IF(l_inv_rec.invoice_currency_code=ap_accounting_pay_pkg.g_base_currency_code ) THEN

        UPDATE  AP_Prepay_App_Dists APAD
               SET  APAD.Amount = APAD.Amount -  NVL(l_sum_prepaid_amount,0) + l_prepay_dist_rec.amount,
	            APAD.BASE_AMT_AT_PREPAY_XRATE = APAD.BASE_AMT_AT_PREPAY_XRATE - NVL(l_sum_prepaid_amount,0) + l_prepay_dist_rec.amount,
	            APAD.BASE_AMT_AT_PREPAY_PAY_XRATE=APAD.BASE_AMT_AT_PREPAY_PAY_XRATE - NVL(l_sum_prepaid_amount,0) + l_prepay_dist_rec.amount,
		    APAD.BASE_AMOUNT=APAD.BASE_AMOUNT - NVL(l_sum_prepaid_amount,0) + l_prepay_dist_rec.amount,
		    APAD.BASE_AMT_AT_PREPAY_CLR_XRATE=APAD.BASE_AMT_AT_PREPAY_CLR_XRATE - NVL(l_sum_prepaid_amount,0) + l_prepay_dist_rec.amount
             WHERE  APAD.Invoice_Distribution_ID =
                      (SELECT MAX(APAD1.Invoice_Distribution_ID)
                         FROM AP_Prepay_App_Dists APAD1
                        WHERE APAD1.Accounting_Event_ID = p_xla_event_rec.event_id
                          AND APAD1.Prepay_App_Distribution_ID = l_prepay_dist_rec.invoice_distribution_id
                          AND APAD1.Prepay_Dist_Lookup_Code IN ('PREPAY APPL', 'PREPAY APPL REC TAX',
                                                                'PREPAY APPL NONREC TAX')
                          AND ABS(APAD1.Amount) =
                                    (SELECT MAX(APAD2.Amount)
                                       FROM AP_Prepay_App_Dists APAD2
                                      WHERE APAD2.Accounting_Event_ID = p_xla_event_rec.event_id
                                        AND APAD2.Prepay_App_Distribution_ID
                                                    = l_prepay_dist_rec.invoice_distribution_id
                                        AND APAD2.Prepay_Dist_Lookup_Code IN ('PREPAY APPL', 'PREPAY APPL REC TAX',
                                                                              'PREPAY APPL NONREC TAX')))
               AND  APAD.Prepay_Dist_Lookup_Code IN ('PREPAY APPL', 'PREPAY APPL REC TAX',
                                                     'PREPAY APPL NONREC TAX')
               AND  APAD.Accounting_Event_ID = p_xla_event_rec.event_id
               AND  APAD.Prepay_App_Distribution_ID = l_prepay_dist_rec.invoice_distribution_id;


       ELSE

       /* Updating the prorated prepaid amounts for any rounding */
       UPDATE AP_Prepay_App_Dists APAD
       SET    APAD.Amount = APAD.Amount -  NVL(l_sum_prepaid_amount,0) + l_prepay_dist_rec.amount
       WHERE  APAD.Invoice_Distribution_ID =
             (SELECT MAX(APAD1.Invoice_Distribution_ID)
              FROM   AP_Prepay_App_Dists APAD1
              WHERE  APAD1.Accounting_Event_ID = p_xla_event_rec.event_id
              AND    APAD1.Prepay_App_Distribution_ID = l_prepay_dist_rec.invoice_distribution_id
              AND    APAD1.Prepay_Dist_Lookup_Code IN ('PREPAY APPL', 'PREPAY APPL REC TAX',
                                                       'PREPAY APPL NONREC TAX')
              AND    ABS(APAD1.Amount) =
                    (SELECT MAX(APAD2.Amount)
                     FROM   AP_Prepay_App_Dists APAD2
                     WHERE  APAD2.Accounting_Event_ID = p_xla_event_rec.event_id
                     AND    APAD2.Prepay_App_Distribution_ID
                                              = l_prepay_dist_rec.invoice_distribution_id
                     AND    APAD2.Prepay_Dist_Lookup_Code IN ('PREPAY APPL', 'PREPAY APPL REC TAX',
                                                              'PREPAY APPL NONREC TAX')))
       AND    APAD.Prepay_Dist_Lookup_Code IN ('PREPAY APPL', 'PREPAY APPL REC TAX',
                                               'PREPAY APPL NONREC TAX')
       AND    APAD.Accounting_Event_ID = p_xla_event_rec.event_id
       AND    APAD.Prepay_App_Distribution_ID = l_prepay_dist_rec.invoice_distribution_id;

       END IF;


       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'Updating the prorated tax diff amounts';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       /* Updating the prorated tax diff amounts for any rounding */
       IF (l_prepay_dist_rec.prepay_tax_diff_amount <> 0) THEN

           UPDATE AP_Prepay_App_Dists APAD
           SET    APAD.Amount = APAD.Amount -  NVL(l_sum_tax_diff_amount,0)
                                     + l_prepay_dist_rec.prepay_tax_diff_amount
           WHERE  APAD.Invoice_Distribution_ID =
                 (SELECT MAX(APAD1.Invoice_Distribution_ID)
                  FROM   AP_Prepay_App_Dists APAD1
                  WHERE  APAD1.Accounting_Event_ID = p_xla_event_rec.event_id
                  AND    APAD1.Prepay_App_Distribution_ID = l_prepay_dist_rec.invoice_distribution_id
                  AND    APAD1.Prepay_Dist_Lookup_Code = 'TAX DIFF'
                  AND    ABS(APAD1.Amount) =
                        (SELECT MAX(APAD2.Amount)
                         FROM   AP_Prepay_App_Dists APAD2
                         WHERE  APAD2.Accounting_Event_ID = p_xla_event_rec.event_id
                         AND    APAD2.Prepay_App_Distribution_ID
                                              = l_prepay_dist_rec.invoice_distribution_id
                         AND    APAD2.Prepay_Dist_Lookup_Code = 'TAX DIFF'))
           AND    APAD.Prepay_Dist_Lookup_Code = 'TAX DIFF'
           AND    APAD.Prepay_App_Distribution_ID = l_prepay_dist_rec.invoice_distribution_id
           AND    APAD.Accounting_Event_ID = p_xla_event_rec.event_id;

       END IF;


       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'Calling procedure P_Acctg_Pay_Round_Pkg.Do_Rounding for Invoice_ID: '
                                    || l_inv_rec.invoice_id;
           FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
       END IF;

       AP_Acctg_Pay_Round_Pkg.Do_Rounding
                     (NULL, --p_xla_event_rec,
                      l_pay_hist_rec,
                      l_clr_hist_rec,
                      l_inv_rec,
                      NULL, -- l_inv_pay_rec
                      l_prepay_inv_rec,
                      l_prepay_hist_rec,
                      l_prepay_dist_rec,
                      l_curr_calling_sequence);

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'Procedure P_Acctg_Pay_Round_Pkg.Do_Rounding executed';
           FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
       END IF;

     END IF; --l_rounding_adjust_id = p_xla_event_rec.event_id  8201141

  END LOOP;
  CLOSE Prepay_Adj_Dists;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Calling procedure AP_Acctg_Prepay_Dist_Pkg.Update_Gain_Loss_Ind';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

  AP_Acctg_Prepay_Dist_Pkg.Update_Gain_Loss_Ind
              (p_xla_event_rec,
               l_curr_calling_sequence);

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Procedure AP_Acctg_Prepay_Dist_Pkg.Updated_Gain_Loss_Ind executed';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Prepay_Dist_Cascade_Adj;



---------------------------------------------------------------------
-- Procedure Prepay_Dist_Proc
-- This procedure prorates the prepayment application amounts for each
-- distribution and inserts the calculated values into prepayment
-- application distribution table
-- Also calculates ERV
---------------------------------------------------------------------
-- Bug 6698125. Added p_xla_event_rec parameter
PROCEDURE Prepay_Dist_Proc
      (p_pay_hist_rec       IN    ap_accounting_pay_pkg.r_pay_hist_info
      ,p_clr_hist_rec       IN    ap_accounting_pay_pkg.r_pay_hist_info
      ,p_inv_rec            IN    ap_accounting_pay_pkg.r_invoices_info
      ,p_prepay_inv_rec     IN    ap_accounting_pay_pkg.r_invoices_info
      ,p_prepay_hist_rec    IN    r_prepay_hist_info
      ,p_prepay_dist_rec    IN    r_prepay_dist_info
      ,p_inv_dist_rec       IN    ap_accounting_pay_pkg.r_inv_dist_info
      ,p_xla_event_rec      IN    ap_accounting_pay_pkg.r_xla_event_info
      ,p_calc_mode          IN    VARCHAR2
      ,p_final_payment      IN    BOOLEAN
      ,p_calling_sequence   IN    VARCHAR2
      ) IS


  l_curr_calling_sequence       VARCHAR2(2000);
  l_dist_amount                 NUMBER;
  l_prorated_amount             NUMBER;
  l_prorated_base_amount        NUMBER;
  l_inv_dist_amount             NUMBER;
  l_prorated_pay_amt            NUMBER;
  l_prorated_clr_amt            NUMBER;
  l_total_paid_amt              NUMBER;
  l_total_prepaid_amt           NUMBER;
  l_total_inv_dist_amt          NUMBER;
  l_total_bank_curr_amt         NUMBER;
  l_total_dist_amount           NUMBER;
  l_qty_variance                NUMBER;
  l_base_qty_variance           NUMBER;
  l_amt_variance                NUMBER;
  l_base_amt_variance           NUMBER;
  --l_awt_prorated_amt            NUMBER; --8364229 --commenting for bug8882706
  l_pad_rec                     AP_PREPAY_APP_DISTS%ROWTYPE;

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Prepay_Dist_Proc';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_total_inv_amount            NUMBER; --Bug9106549
  l_total_awt_amount            NUMBER; --Bug9106549


BEGIN

  l_curr_calling_sequence := 'AP_ACCTG_PREPAY_DIST_PKG.Prepay_Dist_Proc<- ' ||
                                              p_calling_sequence;


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;
  --Bug 8244163 Calculating l_total_inv_amt = total invoice amt with out AWT / PREPAY lines
  --Replacing p_inv_rec.invoice_amount with g_total_inv_amount. Because invoice_amount will be
  --adjusted when prepayment application is happened with option "prepayment on Invoice"

/*  -- 8244163
  SELECT SUM(NVL(AID.Amount,0))
  INTO   l_total_dist_amount
  FROM   AP_Invoice_Distributions_All AID
  WHERE  AID.Invoice_ID = p_inv_rec.invoice_id
  AND    AID.Line_Type_Lookup_Code <> 'PREPAY'
  AND    AID.Prepay_Distribution_ID IS NULL
  AND    AID.Prepay_Tax_Parent_ID IS NULL -- For tax dists created in R11.5
  AND    AID.AWT_Invoice_Payment_ID IS NULL
  AND    NVL(AID.Cancellation_Flag,'N') <> 'Y' -- BUG 6513956
  --bug fix 6909150
  AND    NOT EXISTS (SELECT 1
                       FROM   xla_events
                       WHERE  event_id = AID.accounting_event_id
                       AND    event_type_code IN ('INVOICE CANCELLED',
                                                  'CREDIT MEMO CANCELLED',
                                                  'DEBIT MEMO CANCELLED'));
*/
  l_total_dist_amount := g_total_dist_amount; --8244163
  l_total_inv_amount  := G_Total_Inv_amount;  --Bug9106549
  l_total_awt_amount  := g_total_awt_amount;  --Bug9106549

  g_total_dist_amt := g_total_dist_amt + p_inv_dist_rec.amount;


  IF (p_calc_mode = 'A') THEN

      -- If this payment is a final payment for the invoice then we should make sure
      -- that the sum of prepay appl dists amount should be equal to the distribution
      -- total. This way the liability is fully relieved.
      IF p_final_payment = TRUE THEN

         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
             l_log_msg := 'Calling procedure AP_Accounting_Pay_Pkg.Get_Pay_Sum';
             FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
         END IF;

         AP_Accounting_Pay_Pkg.Get_Pay_Sum
                     (p_inv_dist_rec.invoice_distribution_id,
                      'PAYMENT CREATED',
                      l_total_paid_amt,
                      l_total_inv_dist_amt,
                      l_total_bank_curr_amt,
                      l_curr_calling_sequence);


         l_total_prepaid_amt := AP_Accounting_Pay_Pkg.Get_Prepay_Sum
                                    (p_inv_dist_rec.invoice_distribution_id,
                                     l_curr_calling_sequence);


         -- Converting the distribution and prepaid amount into payment currency for
         -- cross currency invoices.
         IF (p_inv_rec.invoice_currency_code <> p_inv_rec.payment_currency_code) THEN

             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 l_log_msg := 'Invoice curr diff than payment curr';
                 l_log_msg := l_log_msg || ' Converting l_total_paid_amt to invoice curr';
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

             l_total_paid_amt := GL_Currency_API.Convert_Amount(
                                          p_inv_rec.payment_currency_code,
                                          p_inv_rec.invoice_currency_code,
                                          p_inv_rec.payment_cross_rate_date,
                                          'EMU FIXED',
                                          l_total_paid_amt);

         END IF;


         /* If this payment is a final payment then we should make sure that the
            distributed payment amount equals the distribution amount. This way the
            the liability for the distribution is relieved completely */

 	 IF (p_inv_dist_rec.line_type_lookup_code = 'AWT') THEN --8364229
                 l_prorated_amount := -1 * (-1*p_inv_dist_rec.amount - l_total_paid_amt +
                                          l_total_prepaid_amt);
         ELSE
	   --commenting out the following code for bug8882706 as the same will be handled
           --now in ap_accounting_pay_pkg.get_prepay_sum
	    /*SELECT SUM(apad.amount) INTO   l_awt_prorated_amt
	      FROM ap_prepay_app_dists apad
	     WHERE apad.prepay_dist_lookup_code = 'AWT'
	       AND apad.awt_related_id = p_inv_dist_rec.invoice_distribution_id
	       AND apad.invoice_distribution_id in
			         (SELECT invoice_distribution_id
				    FROM ap_invoice_distributions_all
				   WHERE invoice_id = p_inv_rec.invoice_id
				     AND line_type_lookup_code = 'AWT');
	    */
             l_prorated_amount := -1 * (p_inv_dist_rec.amount - l_total_paid_amt +
                                         l_total_prepaid_amt );
	 END IF; --p_inv_dist_rec.line_type_lookup_code = 'AWT' 8364229 ends

      ELSE

         IF g_total_dist_amt = l_total_dist_amount THEN -- last dist rec

            -- To avoid rounding, massage the last (biggest) line
            l_prorated_amount := p_prepay_dist_rec.amount - g_total_prorated_amt;
         ELSE

            IF g_total_inv_amount = 0 THEN --8244163
               l_prorated_amount := 0;

            ELSE

               IF (p_inv_dist_rec.line_type_lookup_code = 'AWT') THEN
                   l_prorated_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY
                                          (p_prepay_dist_rec.amount * (-1*p_inv_dist_rec.amount)
                                                 / l_total_dist_amount,
                                           p_inv_rec.invoice_currency_code);
               ELSE
/*                   l_prorated_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY
                                          (p_prepay_dist_rec.amount * p_inv_dist_rec.amount
                                                 / g_total_inv_amount, --8244163
                                           p_inv_rec.invoice_currency_code);
*/
--Bug9106549

                    SELECT  p_inv_dist_rec.amount
                            / l_total_inv_amount
                            * (p_prepay_dist_rec.amount
                                - (
                                     l_total_awt_amount / l_total_dist_amount * p_prepay_dist_rec.amount
                                  )
                               )
                            +
                              nvl(
                                  (select  sum(amount) / l_total_dist_amount *  p_prepay_dist_rec.amount
                                     from ap_invoice_distributions_all aid
                                    where aid.invoice_id=p_inv_rec.invoice_id
                                      and aid.awt_invoice_payment_id is null
                                      and aid.awt_related_id=p_inv_dist_rec.invoice_distribution_id
                                   ), 0)
                           INTO l_prorated_amount
                      from sys.dual ;

                      l_prorated_amount := ap_utilities_pkg.ap_round_currency(l_prorated_amount, p_inv_rec.invoice_currency_code);

               END IF; -- IF AWT line type

            END IF;
         END IF;

      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Value of l_prorated_amount = '|| l_prorated_amount;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;


      IF (p_inv_dist_rec.line_type_lookup_code <> 'AWT') THEN
          g_total_prorated_amt := g_total_prorated_amt + l_prorated_amount;
      END IF;


  /* If this is a cascade event then we will create new payment distributions
     for the existing invoice distributions that have already been distributed to
     this payment in order to adjust the payments as a result of adjusting the
     invoice */
  ELSE

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Calculating prorated amount for cascade adjustment';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      IF g_total_inv_amount = 0 THEN --8244163
         l_prorated_amount := 0;
      ELSE

         -- In case of cascade events we will recalculate the prorated amount and subtract
         -- this amount from the already calculated amount previously so that this would
         -- give us the amount that needs to be adjusted
         l_prorated_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY
                                (((p_inv_dist_rec.amount * p_prepay_dist_rec.amount)
                                       / g_total_inv_amount) --8244163
                                    - AP_Accounting_Pay_Pkg.get_casc_prepay_sum
                                         (p_inv_dist_rec.invoice_distribution_id,
                                          p_prepay_dist_rec.invoice_distribution_id,
                                          l_curr_calling_sequence),
                                   p_inv_rec.invoice_currency_code);

      END IF;
  END IF;


  -- Populate prepay appl dist rec

  l_pad_rec.prepay_history_id := p_prepay_hist_rec.prepay_history_id;

  IF p_inv_dist_rec.line_type_lookup_code = 'AWT' THEN
     l_pad_rec.prepay_dist_lookup_code := 'AWT';
     l_pad_rec.awt_related_id := p_inv_dist_rec.awt_related_id;
  ELSIF p_prepay_dist_rec.line_type_lookup_code = 'NONREC_TAX' THEN
     l_pad_rec.prepay_dist_lookup_code := 'PREPAY APPL NONREC TAX';
  ELSIF p_prepay_dist_rec.line_type_lookup_code = 'REC_TAX' THEN
     l_pad_rec.prepay_dist_lookup_code := 'PREPAY APPL REC TAX';
  ELSE
     l_pad_rec.prepay_dist_lookup_code := 'PREPAY APPL';
  END IF;

  l_pad_rec.invoice_distribution_id := p_inv_dist_rec.invoice_distribution_id;
  l_pad_rec.prepay_app_distribution_id := p_prepay_dist_rec.invoice_distribution_id;

  -- bug9038462, added the below if condition to ensure that the APAD
  -- records have an appropriate Accounting_Event_id in case the
  -- Accounting_Event_id has been already generated, and the APAD
  -- and APH records are being regenerated
  --
  IF p_calc_mode = 'A' THEN
    l_pad_rec.accounting_event_id := p_prepay_dist_rec.accounting_event_id;
  ELSE
    l_pad_rec.accounting_event_id := p_xla_event_rec.event_id;
  END IF;


  l_pad_rec.amount := l_prorated_amount;

  l_pad_rec.prepay_exchange_date := p_prepay_inv_rec.exchange_date;
  l_pad_rec.prepay_pay_exchange_date := p_pay_hist_rec.pmt_to_base_xrate_date;
  l_pad_rec.prepay_clr_exchange_date := p_clr_hist_rec.bank_to_base_xrate_date;

  l_pad_rec.prepay_exchange_rate := p_prepay_inv_rec.exchange_rate;
  l_pad_rec.prepay_pay_exchange_rate := p_pay_hist_rec.pmt_to_base_xrate;
  l_pad_rec.prepay_clr_exchange_rate := p_clr_hist_rec.bank_to_base_xrate;

  l_pad_rec.prepay_exchange_rate_type := p_prepay_inv_rec.exchange_rate_type;
  l_pad_rec.prepay_pay_exchange_rate_type := p_pay_hist_rec.pmt_to_base_xrate_type;
  l_pad_rec.prepay_clr_exchange_rate_type := p_clr_hist_rec.bank_to_base_xrate_type;


  l_pad_rec.base_amt_at_prepay_xrate :=  AP_Accounting_Pay_Pkg.Get_Base_Amount
                                              (l_prorated_amount,
                                               p_prepay_inv_rec.invoice_currency_code,
                                               p_inv_rec.base_currency_code,
                                               p_prepay_inv_rec.exchange_rate_type,
                                               p_prepay_inv_rec.exchange_date,
                                               p_prepay_inv_rec.exchange_rate,
                                               l_curr_calling_sequence);


  IF (p_inv_rec.invoice_currency_code <> p_pay_hist_rec.pmt_currency_code) THEN
      l_prorated_pay_amt := AP_UTILITIES_PKG.AP_Round_Currency(
                                  l_prorated_amount * p_inv_rec.payment_cross_rate,
                                  p_pay_hist_rec.pmt_currency_code);
  ELSE
      l_prorated_pay_amt := l_prorated_amount;
  END IF;

  l_pad_rec.base_amt_at_prepay_pay_xrate :=  AP_Accounting_Pay_Pkg.Get_Base_Amount
                                               (l_prorated_pay_amt,
                                                p_pay_hist_rec.pmt_currency_code,
                                                p_inv_rec.base_currency_code,
                                                p_pay_hist_rec.pmt_to_base_xrate_type,
                                                p_pay_hist_rec.pmt_to_base_xrate_date,
                                                p_pay_hist_rec.pmt_to_base_xrate,
                                                l_curr_calling_sequence);

  IF (p_clr_hist_rec.pmt_currency_code <> p_clr_hist_rec.bank_currency_code) THEN

      l_prorated_clr_amt := AP_UTILITIES_PKG.AP_Round_Currency(
                                  l_prorated_pay_amt * p_clr_hist_rec.pmt_to_base_xrate,
                                  p_pay_hist_rec.bank_currency_code);
  ELSE
      l_prorated_clr_amt := l_prorated_pay_amt;
  END IF;

  l_pad_rec.base_amt_at_prepay_clr_xrate :=  AP_Accounting_Pay_Pkg.Get_Base_Amount
                                               (l_prorated_clr_amt,
                                                p_clr_hist_rec.bank_currency_code,
                                                p_inv_rec.base_currency_code,
                                                p_clr_hist_rec.bank_to_base_xrate_type,
                                                p_clr_hist_rec.bank_to_base_xrate_date,
                                                p_clr_hist_rec.bank_to_base_xrate,
                                                l_curr_calling_sequence);


  l_pad_rec.base_amount  := AP_Accounting_Pay_Pkg.Get_Base_Amount
                                   (l_prorated_amount,
                                    p_inv_rec.invoice_currency_code,
                                    p_inv_rec.base_currency_code,
                                    p_inv_rec.exchange_rate_type,
                                    p_inv_rec.exchange_date,
                                    p_inv_rec.exchange_rate,
                                    l_curr_calling_sequence);


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Calling procedure Prepay_Dist_Insert';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;


  IF p_inv_dist_rec.quantity_variance IS NOT NULL THEN

     IF p_inv_dist_rec.amount = 0 THEN
        l_qty_variance := 0;
     ELSE
        l_qty_variance := AP_Utilities_PKG.AP_Round_Currency(
                             ((p_inv_dist_rec.quantity_variance * l_prorated_amount) /
                                     p_inv_dist_rec.amount),
                               p_inv_rec.invoice_currency_code);
     END IF;

     IF p_inv_dist_rec.base_amount = 0 THEN
        l_base_qty_variance := 0;
     ELSE
        l_base_qty_variance := AP_Utilities_PKG.AP_Round_Currency(
                                  ((p_inv_dist_rec.base_quantity_variance
                                        * l_pad_rec.base_amount)
                                        / p_inv_dist_rec.base_amount),
                                    p_inv_rec.base_currency_code);

     END IF;
  END IF;

  IF p_inv_dist_rec.amount_variance IS NOT NULL THEN

     IF p_inv_dist_rec.amount = 0 THEN
        l_amt_variance := 0;
     ELSE
        l_amt_variance := AP_Utilities_PKG.AP_Round_Currency(
                             ((p_inv_dist_rec.amount_variance * l_prorated_amount) /
                                     p_inv_dist_rec.amount),
                               p_inv_rec.invoice_currency_code);
     END IF;

     IF p_inv_dist_rec.base_amount = 0 THEN
        l_base_amt_variance := 0;
     ELSE
        l_base_amt_variance := AP_Utilities_PKG.AP_Round_Currency(
                                  ((p_inv_dist_rec.base_amount_variance
                                        * l_pad_rec.base_amount)
                                        / p_inv_dist_rec.base_amount),
                                    p_inv_rec.base_currency_code);
     END IF;
  END IF;

  l_pad_rec.quantity_variance := l_qty_variance;
  l_pad_rec.invoice_base_qty_variance := l_base_qty_variance;
  l_pad_rec.amount_variance := l_amt_variance;
  l_pad_rec.invoice_base_amt_variance := l_base_amt_variance;


  Prepay_Dist_Insert
          (l_pad_rec,
           l_curr_calling_sequence);

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Procedure Prepay_Dist_Insert executed';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;


  IF (p_prepay_dist_rec.prepay_tax_diff_amount <> 0) THEN


      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'Calling procedure Prepay_Dist_Tax_Diff';
          FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
      END IF;

      -- Creating the tax diff distributions
      Prepay_Dist_Tax_Diff
          (p_pay_hist_rec,
           p_clr_hist_rec,
           p_inv_rec,
           p_prepay_inv_rec,
           p_prepay_hist_rec,
           p_prepay_dist_rec,
           p_inv_dist_rec,
           p_calc_mode,
           l_curr_calling_sequence);

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'Procedure Prepay_Dist_Tax_Diff executed';
          FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
      END IF;


  END IF;


  IF (p_inv_dist_rec.po_distribution_id IS NOT NULL AND
      p_inv_rec.invoice_currency_code <> p_inv_rec.base_currency_code) THEN

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'Calling procedure Prepay_Dist_ERV';
          FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
      END IF;

     -- Creating ERV distributions
     Prepay_Dist_ERV
          (p_pay_hist_rec,
           p_clr_hist_rec,
           p_inv_rec,
           p_prepay_inv_rec,
           p_prepay_hist_rec,
           p_prepay_dist_rec,
           p_inv_dist_rec,
           l_prorated_amount,
           l_curr_calling_sequence);

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'Procedure Prepay_Dist_ERV executed';
          FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
      END IF;

  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Procedure Prepay_Dist_Insert executed';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Prepay_Dist_Proc;



---------------------------------------------------------------------
-- Procedure Prepay_Dist_Tax_Diff
-- This procedure prorates the tax difference amounts for each
-- distribution and inserts the calculated values into prepayment
-- application distribution table
---------------------------------------------------------------------

PROCEDURE Prepay_Dist_Tax_Diff
      (p_pay_hist_rec       IN    ap_accounting_pay_pkg.r_pay_hist_info
      ,p_clr_hist_rec       IN    ap_accounting_pay_pkg.r_pay_hist_info
      ,p_inv_rec            IN    ap_accounting_pay_pkg.r_invoices_info
      ,p_prepay_inv_rec     IN    ap_accounting_pay_pkg.r_invoices_info
      ,p_prepay_hist_rec    IN    r_prepay_hist_info
      ,p_prepay_dist_rec    IN    r_prepay_dist_info
      ,p_inv_dist_rec       IN    ap_accounting_pay_pkg.r_inv_dist_info
      ,p_calc_mode          IN    VARCHAR2
      ,p_calling_sequence   IN    VARCHAR2
      ) IS


  l_curr_calling_sequence       VARCHAR2(2000);
  l_prorated_amount             NUMBER;
  l_prorated_pay_amt            NUMBER;
  l_prorated_clr_amt            NUMBER;

  l_pad_rec                     AP_PREPAY_APP_DISTS%ROWTYPE;

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Prepay_Dist_Tax_Diff';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;


BEGIN

  l_curr_calling_sequence := 'AP_ACCTG_PREPAY_DIST_PKG.Prepay_Dist_Tax_Diff<- ' ||
                                              p_calling_sequence;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;


  IF p_calc_mode = 'A' THEN
     IF g_total_dist_amt = g_total_inv_amount THEN -- last dist rec --8244163

        -- To avoid rounding, massage the last (biggest) line
        l_prorated_amount := p_prepay_dist_rec.prepay_tax_diff_amount - g_total_tax_diff_amt;
     ELSE

        IF g_total_inv_amount = 0 THEN --8244163
           l_prorated_amount := 0;

        ELSE
           l_prorated_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY
                                  (p_prepay_dist_rec.prepay_tax_diff_amount * p_inv_dist_rec.amount
                                       / g_total_inv_amount,
                                    p_inv_rec.invoice_currency_code);

        END IF;
     END IF;

  ELSE

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Calculating prorated amount for cascade adjustment';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      IF g_total_inv_amount = 0 THEN
         l_prorated_amount := 0;
      ELSE

         -- In case of cascade events we will recalculate the prorated amount and subtract
         -- this amount from the already calculated amount previously so that this would
         -- give us the amount that needs to be adjusted
         l_prorated_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY
                                (((p_inv_dist_rec.amount * p_prepay_dist_rec.prepay_tax_diff_amount)
                                       / g_total_inv_amount)
                                    - AP_Accounting_Pay_Pkg.get_casc_tax_diff_sum
                                         (p_inv_dist_rec.invoice_distribution_id,
                                          p_prepay_dist_rec.invoice_distribution_id,
                                          l_curr_calling_sequence),
                                   p_inv_rec.invoice_currency_code);

      END IF;
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Value for l_prorated_amount = '|| l_prorated_amount;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  g_total_tax_diff_amt := g_total_tax_diff_amt + l_prorated_amount;


  -- Populate prepay appl dist rec

  l_pad_rec.prepay_history_id := p_prepay_hist_rec.prepay_history_id;
  l_pad_rec.prepay_dist_lookup_code := 'TAX DIFF';
  l_pad_rec.invoice_distribution_id := p_inv_dist_rec.invoice_distribution_id;
  l_pad_rec.prepay_app_distribution_id := p_prepay_dist_rec.invoice_distribution_id;
  l_pad_rec.accounting_event_id := p_prepay_dist_rec.accounting_event_id;

  l_pad_rec.amount := l_prorated_amount;

  l_pad_rec.prepay_exchange_date := p_prepay_inv_rec.exchange_date;
  l_pad_rec.prepay_pay_exchange_date := p_pay_hist_rec.pmt_to_base_xrate_date;
  l_pad_rec.prepay_clr_exchange_date := p_clr_hist_rec.bank_to_base_xrate_date;

  l_pad_rec.prepay_exchange_rate := p_prepay_inv_rec.exchange_rate;
  l_pad_rec.prepay_pay_exchange_rate := p_pay_hist_rec.pmt_to_base_xrate;
  l_pad_rec.prepay_clr_exchange_rate := p_clr_hist_rec.bank_to_base_xrate;

  l_pad_rec.prepay_exchange_rate_type := p_prepay_inv_rec.exchange_rate_type;
  l_pad_rec.prepay_pay_exchange_rate_type := p_pay_hist_rec.pmt_to_base_xrate_type;
  l_pad_rec.prepay_clr_exchange_rate_type := p_clr_hist_rec.bank_to_base_xrate_type;


  l_pad_rec.base_amt_at_prepay_xrate :=  AP_Accounting_Pay_Pkg.Get_Base_Amount
                                              (l_prorated_amount,
                                               p_prepay_inv_rec.invoice_currency_code,
                                               p_inv_rec.base_currency_code,
                                               p_prepay_inv_rec.exchange_rate_type,
                                               p_prepay_inv_rec.exchange_date,
                                               p_prepay_inv_rec.exchange_rate,
                                               l_curr_calling_sequence);

  IF (p_inv_rec.invoice_currency_code <> p_pay_hist_rec.pmt_currency_code) THEN
      l_prorated_pay_amt := l_prorated_amount * p_inv_rec.payment_cross_rate;
  ELSE
      l_prorated_pay_amt := l_prorated_amount;
  END IF;


  l_pad_rec.base_amt_at_prepay_pay_xrate :=  AP_Accounting_Pay_Pkg.Get_Base_Amount
                                               (l_prorated_pay_amt,
                                                p_pay_hist_rec.pmt_currency_code,
                                                p_inv_rec.base_currency_code,
                                                p_pay_hist_rec.pmt_to_base_xrate_type,
                                                p_pay_hist_rec.pmt_to_base_xrate_date,
                                                p_pay_hist_rec.pmt_to_base_xrate,
                                                l_curr_calling_sequence);

  IF (p_clr_hist_rec.pmt_currency_code <> p_clr_hist_rec.bank_currency_code) THEN

      l_prorated_clr_amt := AP_UTILITIES_PKG.AP_Round_Currency(
                                  l_prorated_pay_amt * p_clr_hist_rec.pmt_to_base_xrate,
                                  p_pay_hist_rec.bank_currency_code);
  ELSE
      l_prorated_clr_amt := l_prorated_pay_amt;
  END IF;

  l_pad_rec.base_amt_at_prepay_clr_xrate :=  AP_Accounting_Pay_Pkg.Get_Base_Amount
                                               (l_prorated_clr_amt,
                                                p_clr_hist_rec.bank_currency_code,
                                                p_inv_rec.base_currency_code,
                                                p_clr_hist_rec.bank_to_base_xrate_type,
                                                p_clr_hist_rec.bank_to_base_xrate_date,
                                                p_clr_hist_rec.bank_to_base_xrate,
                                                l_curr_calling_sequence);


  l_pad_rec.base_amount  := AP_Accounting_Pay_Pkg.Get_Base_Amount
                                   (l_prorated_amount,
                                    p_inv_rec.invoice_currency_code,
                                    p_inv_rec.base_currency_code,
                                    p_inv_rec.exchange_rate_type,
                                    p_inv_rec.exchange_date,
                                    p_inv_rec.exchange_rate,
                                    l_curr_calling_sequence);


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Calling procedure Prepay_Dist_Insert';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  Prepay_Dist_Insert
          (l_pad_rec,
           l_curr_calling_sequence);


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Procedure Prepay_Dist_Insert executed';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Prepay_Dist_Tax_Diff;




---------------------------------------------------------------------
-- Procedure Prepay_Dist_ERV
-- This procedure calculates the ERV base amounts for the ERV distributions
-- and inserts the calculated values into prepay appl payment dists table
---------------------------------------------------------------------

PROCEDURE Prepay_Dist_ERV
      (p_pay_hist_rec     IN    ap_accounting_pay_pkg.r_pay_hist_info
      ,p_clr_hist_rec     IN    ap_accounting_pay_pkg.r_pay_hist_info
      ,p_inv_rec          IN    ap_accounting_pay_pkg.r_invoices_info
      ,p_prepay_inv_rec   IN    ap_accounting_pay_pkg.r_invoices_info
      ,p_prepay_hist_rec  IN    r_prepay_hist_info
      ,p_prepay_dist_rec  IN    r_prepay_dist_info
      ,p_inv_dist_rec     IN    ap_accounting_pay_pkg.r_inv_dist_info
      ,p_prorated_amount  IN    NUMBER
      ,p_calling_sequence IN    VARCHAR2
      ) IS

  l_curr_calling_sequence          VARCHAR2(2000);
  l_po_exchange_rate               NUMBER;
  l_po_pay_exchange_rate           NUMBER;
  l_pay_erv_amount                 NUMBER;
  l_clr_erv_amount                 NUMBER;
  l_inv_erv_amount                 NUMBER;
  l_pad_rec                       AP_PREPAY_APP_DISTS%ROWTYPE;

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Prepay_Dist_ERV';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN


  l_curr_calling_sequence := 'AP_ACCTG_PREPAY_DIST_PKG.PrePay_Dist_ERV<- ' ||
                                                 p_calling_sequence;


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;


  IF p_inv_dist_rec.rcv_transaction_id IS NOT NULL THEN

     SELECT Currency_Conversion_Rate
     INTO   l_po_exchange_rate
     FROM   rcv_transactions
     WHERE  transaction_id = p_inv_dist_rec.rcv_transaction_id;

  ELSE

     SELECT Rate
     INTO   l_po_exchange_rate
     FROM   PO_Distributions_All
     WHERE  PO_Distribution_ID = p_inv_dist_rec.PO_Distribution_ID;

  END IF;

  IF p_inv_rec.invoice_currency_code <> p_inv_rec.payment_currency_code THEN
     l_po_pay_exchange_rate := l_po_exchange_rate / p_inv_rec.payment_cross_rate;
  ELSE
     l_po_pay_exchange_rate := l_po_exchange_rate;
  END IF;


  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Value of l_po_pay_exchange_rate = '||l_po_pay_exchange_rate;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  /* For Cash Basis ERV is Difference between Payment Exchange Rate and
     either Receipt Exchange rate or PO distributions exchange rate */

  l_pay_erv_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                         (p_pay_hist_rec.pmt_to_base_xrate - l_po_pay_exchange_rate) *
                              p_prorated_amount, p_pay_hist_rec.pmt_currency_code);


  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Value of l_pay_erv_amount = '||l_pay_erv_amount;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  /* If the payment accounting is at the at the clearing time, then ERV should be
     calculated based on the difference between Prepay payment clearing exchange rate
     and either Receipt Exchange rate or PO distributions exchange rate */

  IF p_clr_hist_rec.pmt_currency_code IS NOT NULL THEN   -- Bug 5701788.
    l_clr_erv_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                         (p_clr_hist_rec.pmt_to_base_xrate - l_po_pay_exchange_rate) *
                              p_inv_dist_rec.amount, p_clr_hist_rec.pmt_currency_code);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Value of l_clr_erv_amount = '||l_clr_erv_amount;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  /* In order to back out the encumbrance entries correctly during cash basis
     we need to calculate ERV based on the difference between the Invoice
     Exchange Rate and either Receipt Exchange rate or PO distributions
     exchange rate. This calculated ERV amount will be stored in the
     invoice_dist_base_amount column */

  l_inv_erv_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                         (p_inv_rec.exchange_rate - l_po_exchange_rate) *
                              p_prorated_amount, p_inv_rec.invoice_currency_code);

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Value of l_inv_erv_amount = '||l_inv_erv_amount;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  IF (p_inv_dist_rec.line_type_lookup_code IN ('NONREC_TAX', 'REC_TAX')) THEN
      l_pad_rec.prepay_dist_lookup_code := 'TAX EXCHANGE RATE VARIANCE';
  ELSE
      l_pad_rec.prepay_dist_lookup_code := 'EXCHANGE RATE VARIANCE';
  END IF;

  l_pad_rec.prepay_history_id := p_prepay_hist_rec.prepay_history_id;
  l_pad_rec.invoice_distribution_id := p_inv_dist_rec.invoice_distribution_id;
  l_pad_rec.prepay_app_distribution_id := p_prepay_dist_rec.invoice_distribution_id;
  l_pad_rec.accounting_event_id := p_prepay_dist_rec.accounting_event_id;

  l_pad_rec.amount := 0;

  l_pad_rec.prepay_exchange_date := p_prepay_inv_rec.exchange_date;
  l_pad_rec.prepay_pay_exchange_date := p_pay_hist_rec.pmt_to_base_xrate_date;
  l_pad_rec.prepay_clr_exchange_date := p_clr_hist_rec.bank_to_base_xrate_date;

  l_pad_rec.prepay_exchange_rate := p_prepay_inv_rec.exchange_rate;
  l_pad_rec.prepay_pay_exchange_rate := p_pay_hist_rec.pmt_to_base_xrate;
  l_pad_rec.prepay_clr_exchange_rate := p_clr_hist_rec.bank_to_base_xrate;

  l_pad_rec.prepay_exchange_rate_type := p_prepay_inv_rec.exchange_rate_type;
  l_pad_rec.prepay_pay_exchange_rate_type := p_pay_hist_rec.pmt_to_base_xrate_type;
  l_pad_rec.prepay_clr_exchange_rate_type := p_clr_hist_rec.bank_to_base_xrate_type;


  l_pad_rec.base_amt_at_prepay_xrate :=  0;
  l_pad_rec.base_amt_at_prepay_pay_xrate := l_pay_erv_amount;
  l_pad_rec.base_amt_at_prepay_clr_xrate := l_clr_erv_amount;
  l_pad_rec.base_amount := 0;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Calling procedure Prepay_Dist_Insert';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  Prepay_Dist_Insert
          (l_pad_rec,
           l_curr_calling_sequence);

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Procedure Prepay_Dist_Insert executed';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Prepay_Dist_ERV;



---------------------------------------------------------------------
-- Procedure Prepay_Dist_Reverse
-- This procedure reverses the prepayment application payment distributions
-- of the prepayment unapplications.
--
---------------------------------------------------------------------
-- Bug 6698125. Added p_xla_event_rec parameter
-- Bug 7134020. Added p_inv_dist_id parameter
PROCEDURE Prepay_Dist_Reverse
      (p_prepay_hist_rec       IN    r_prepay_hist_info
      ,p_prepay_reversal_id    IN    NUMBER
      ,P_XLA_Event_Rec         IN    ap_accounting_pay_pkg.r_xla_event_info
      ,p_inv_reversal_id       IN    NUMBER
      ,p_inv_dist_id           IN    NUMBER
      ,p_prepay_inv_dist_id    IN    NUMBER
      ,p_calling_sequence      IN    VARCHAR2
      ) IS

  l_curr_calling_sequence          VARCHAR2(2000);

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Prepay_Dist_Reverse';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;


BEGIN

  l_curr_calling_sequence := 'AP_ACCTG_PAY_DIST_PKG.Prepay_Dist_Reverse<-' ||
                                           p_calling_sequence;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;

  -- Bug 6698125. Added if condition to correctly reverse the prepay app
  -- distributions based on if reversed for prepayment unapplication or
  -- prepayment application adjusted events.

  IF p_prepay_reversal_id IS NOT NULL THEN

     -- bug9038462, modified this Insert into apad which takes
     -- care of the Non-Cascade Prepayment reversals, to stamp
     -- an Accounting_event_id appropriately, if present on the
     -- corresponding Prepayment History Record
     --

     INSERT INTO AP_Prepay_App_Dists
           (Prepay_App_Dist_ID,
            Prepay_Dist_Lookup_Code,
            Invoice_Distribution_ID,
            Prepay_App_Distribution_ID,
            Accounting_Event_ID,
            Prepay_History_ID,
            Prepay_Exchange_Date,
            Prepay_Pay_Exchange_Date,
            Prepay_Clr_Exchange_Date,
            Prepay_Exchange_Rate,
            Prepay_Pay_Exchange_Rate,
            Prepay_Clr_Exchange_Rate,
            Prepay_Exchange_Rate_Type,
            Prepay_Pay_Exchange_Rate_Type,
            Prepay_Clr_Exchange_Rate_Type,
            Reversed_Prepay_App_Dist_ID,
            Amount,
            Base_Amt_At_Prepay_XRate,
            Base_Amt_At_Prepay_Pay_XRate,
            Base_Amt_At_Prepay_Clr_XRate,
            Base_Amount,
            AWT_Related_ID,
            PA_Addition_Flag,
            Quantity_Variance,
            Invoice_Base_Qty_Variance,
            Amount_Variance,
            Invoice_Base_Amt_Variance,
            Created_By,
            Creation_Date,
            Last_Update_Date,
            Last_Updated_By,
            Last_Update_Login,
            Program_Application_ID,
            Program_ID,
            Program_Update_Date,
            Request_ID
           )
     SELECT AP_Prepay_App_Dists_S.nextval,
            APAD.Prepay_Dist_Lookup_Code,
            APAD.Invoice_Distribution_ID,
            p_prepay_inv_dist_id,
            xer.event_id,                 --p_xla_event_rec.event_id,
            p_prepay_hist_rec.prepay_history_id,
            APAD.Prepay_Exchange_Date,
            APAD.Prepay_Pay_Exchange_Date,
            APAD.Prepay_Clr_Exchange_Date,
            APAD.Prepay_Exchange_Rate,
            APAD.Prepay_Pay_Exchange_Rate,
            APAD.Prepay_Clr_Exchange_Rate,
            APAD.Prepay_Exchange_Rate_Type,
            APAD.Prepay_Pay_Exchange_Rate_Type,
            APAD.Prepay_Clr_Exchange_Rate_Type,
            APAD.Prepay_App_Dist_ID,
            -1 * APAD.Amount,
            -1 * APAD.Base_Amt_At_Prepay_XRate,
            -1 * APAD.Base_Amt_At_Prepay_Pay_XRate,
            -1 * APAD.Base_Amt_At_Prepay_Clr_XRate,
            -1 * APAD.Base_Amount,
            APAD.AWT_Related_ID,
            'N',
            APAD.Quantity_Variance,
            APAD.Invoice_Base_Qty_Variance,
            APAD.Amount_Variance,
            APAD.Invoice_Base_Amt_Variance,
            FND_GLOBAL.User_ID,
            SYSDATE,
            SYSDATE,
            FND_GLOBAL.User_ID,
            FND_GLOBAL.User_ID,
            FND_GLOBAL.Prog_Appl_ID,
            FND_GLOBAL.Conc_Program_ID,
            SYSDATE,
            FND_GLOBAL.Conc_Request_ID
     FROM   AP_Prepay_App_Dists APAD,
            ap_prepay_history_all aph,                                 --Bug 9112240
            ap_prepay_history_all aphr,
            xla_events xer
     WHERE  apad.Prepay_App_Distribution_ID = P_Prepay_Reversal_ID
       AND  apad.prepay_history_id          = aph.prepay_history_id  --Bug 9112240
       AND  aphr.prepay_history_id          = p_prepay_hist_rec.prepay_history_id
       AND  aphr.accounting_event_id        = xer.event_id(+)
       AND  xer.application_id(+)           = 200;

  ELSIF p_inv_reversal_id IS NOT NULL THEN

     INSERT INTO AP_Prepay_App_Dists
           (Prepay_App_Dist_ID,
            Prepay_Dist_Lookup_Code,
            Invoice_Distribution_ID,
            Prepay_App_Distribution_ID,
            Accounting_Event_ID,
            Prepay_History_ID,
            Prepay_Exchange_Date,
            Prepay_Pay_Exchange_Date,
            Prepay_Clr_Exchange_Date,
            Prepay_Exchange_Rate,
            Prepay_Pay_Exchange_Rate,
            Prepay_Clr_Exchange_Rate,
            Prepay_Exchange_Rate_Type,
            Prepay_Pay_Exchange_Rate_Type,
            Prepay_Clr_Exchange_Rate_Type,
            Reversed_Prepay_App_Dist_ID,
            Amount,
            Base_Amt_At_Prepay_XRate,
            Base_Amt_At_Prepay_Pay_XRate,
            Base_Amt_At_Prepay_Clr_XRate,
            Base_Amount,
            AWT_Related_ID,
            PA_Addition_Flag,
            Quantity_Variance,
            Invoice_Base_Qty_Variance,
            Amount_Variance,
            Invoice_Base_Amt_Variance,
            Created_By,
            Creation_Date,
            Last_Update_Date,
            Last_Updated_By,
            Last_Update_Login,
            Program_Application_ID,
            Program_ID,
            Program_Update_Date,
            Request_ID
           )
     SELECT AP_Prepay_App_Dists_S.nextval,
            APAD.Prepay_Dist_Lookup_Code,
            p_inv_dist_id, -- Bug 7134020
            APAD.Prepay_App_Distribution_ID,
            p_xla_event_rec.event_id,
            p_prepay_hist_rec.prepay_history_id,
            APAD.Prepay_Exchange_Date,
            APAD.Prepay_Pay_Exchange_Date,
            APAD.Prepay_Clr_Exchange_Date,
            APAD.Prepay_Exchange_Rate,
            APAD.Prepay_Pay_Exchange_Rate,
            APAD.Prepay_Clr_Exchange_Rate,
            APAD.Prepay_Exchange_Rate_Type,
            APAD.Prepay_Pay_Exchange_Rate_Type,
            APAD.Prepay_Clr_Exchange_Rate_Type,
            APAD.Prepay_App_Dist_ID,
            -1 * APAD.Amount,
            -1 * APAD.Base_Amt_At_Prepay_XRate,
            -1 * APAD.Base_Amt_At_Prepay_Pay_XRate,
            -1 * APAD.Base_Amt_At_Prepay_Clr_XRate,
            -1 * APAD.Base_Amount,
            APAD.AWT_Related_ID,
            'N',
            APAD.Quantity_Variance,
            APAD.Invoice_Base_Qty_Variance,
            APAD.Amount_Variance,
            APAD.Invoice_Base_Amt_Variance,
            FND_GLOBAL.User_ID,
            SYSDATE,
            SYSDATE,
            FND_GLOBAL.User_ID,
            FND_GLOBAL.User_ID,
            FND_GLOBAL.Prog_Appl_ID,
            FND_GLOBAL.Conc_Program_ID,
            SYSDATE,
            FND_GLOBAL.Conc_Request_ID
     FROM   AP_Prepay_App_Dists APAD,
            ap_prepay_history_all aph                                 --Bug 9112240
     WHERE  apad.Prepay_App_Distribution_ID = P_Prepay_Reversal_ID
       AND  apad.prepay_history_id          = aph.prepay_history_id   --Bug 9112240
       AND  APAD.Prepay_App_Distribution_ID = nvl(p_prepay_inv_dist_id,APAD.Prepay_App_Distribution_ID);   --7686421
  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'End of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Prepay_Dist_Reverse;



----------------------------------------------------------------------------------
-- PROCEDURE Prepay_Dist_Insert
-- This procedure is used to insert the prepay application payment distributions
-- into the ap_prepay_app_dists table
----------------------------------------------------------------------------------

PROCEDURE Prepay_Dist_Insert
     (P_PAD_Rec           IN     AP_PREPAY_APP_DISTS%ROWTYPE
     ,P_Calling_Sequence  IN     VARCHAR2
     ) IS

  l_curr_calling_sequence      VARCHAR2(2000);

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Prepay_Dist_Insert';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  l_curr_calling_sequence := 'AP_ACCTG_PREPAY_DIST_PKG.Prepay_Dist_Insert<- ' ||
                                     P_Calling_Sequence;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;


  INSERT INTO AP_Prepay_App_Dists
        (Prepay_App_Dist_ID,
         Prepay_Dist_Lookup_Code,
         Invoice_Distribution_ID,
         Prepay_App_Distribution_ID,
         Accounting_Event_ID,
         Prepay_History_ID,
         Prepay_Exchange_Date,
         Prepay_Pay_Exchange_Date,
         Prepay_Clr_Exchange_Date,
         Prepay_Exchange_Rate,
         Prepay_Pay_Exchange_Rate,
         Prepay_Clr_Exchange_Rate,
         Prepay_Exchange_Rate_Type,
         Prepay_Pay_Exchange_Rate_Type,
         Prepay_Clr_Exchange_Rate_Type,
         Reversed_Prepay_App_Dist_ID,
         Amount,
         Base_Amt_At_Prepay_XRate,
         Base_Amt_At_Prepay_Pay_XRate,
         Base_Amt_At_Prepay_Clr_XRate,
         Base_Amount,
         AWT_Related_ID,
         PA_Addition_Flag,
         Quantity_Variance,
         Invoice_Base_Qty_Variance,
         Amount_Variance,
         Invoice_Base_Amt_Variance,
         Created_By,
         Creation_Date,
         Last_Update_Date,
         Last_Updated_By,
         Last_Update_Login,
         Program_Application_ID,
         Program_ID,
         Program_Update_Date,
         Request_ID
         )
  VALUES (AP_Prepay_App_Dists_S.nextval,
         P_PAD_Rec.Prepay_Dist_Lookup_Code,
         P_PAD_Rec.Invoice_Distribution_ID,
         P_PAD_Rec.Prepay_App_Distribution_ID,
         P_PAD_Rec.Accounting_Event_ID,
         P_PAD_Rec.Prepay_History_ID,
         P_PAD_Rec.Prepay_Exchange_Date,
         P_PAD_Rec.Prepay_Pay_Exchange_Date,
         P_PAD_Rec.Prepay_Clr_Exchange_Date,
         P_PAD_Rec.Prepay_Exchange_Rate,
         P_PAD_Rec.Prepay_Pay_Exchange_Rate,
         P_PAD_Rec.Prepay_Clr_Exchange_Rate,
         P_PAD_Rec.Prepay_Exchange_Rate_Type,
         P_PAD_Rec.Prepay_Pay_Exchange_Rate_Type,
         P_PAD_Rec.Prepay_Clr_Exchange_Rate_Type,
         P_PAD_Rec.Reversed_Prepay_App_Dist_ID,
         P_PAD_Rec.Amount,
         P_PAD_Rec.Base_Amt_At_Prepay_XRate,
         P_PAD_Rec.Base_Amt_At_Prepay_Pay_XRate,
         P_PAD_Rec.Base_Amt_At_Prepay_Clr_XRate,
         P_PAD_Rec.Base_Amount,
         P_PAD_Rec.AWT_Related_ID,
         'N',
         P_PAD_Rec.Quantity_Variance,
         P_PAD_Rec.Invoice_Base_Qty_Variance,
         P_PAD_Rec.Amount_Variance,
         P_PAD_Rec.Invoice_Base_Amt_Variance,
         FND_GLOBAL.User_ID,
         SYSDATE,
         SYSDATE,
         FND_GLOBAL.User_ID,
         FND_GLOBAL.User_ID,
         FND_GLOBAL.Prog_Appl_ID,
         FND_GLOBAL.Conc_Program_ID,
         SYSDATE,
         FND_GLOBAL.Conc_Request_ID
         );

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'End of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Prepay_Dist_Insert;

--Bug5373620 Added following procedure
-------------------------------------------------------------------------------
-- PROCEDURE Delete_Hist_Dists
-- Procedure to delete the Prepay history distributions and prepayment
-- application distributions.
--
--
-- bug9038462, rewrote the DELETE statements in the procedure to make
-- sure of the regeneration of the Prepayment Application distributions
-- if the corresponding Invoice distribution for prepayment application
-- has not been posted or encumbered
--

--------------------------------------------------------------------------------
PROCEDURE Delete_Hist_Dists
     (P_invoice_id           IN   NUMBER,
      P_Calling_Sequence     IN   VARCHAR2
     ) IS

  l_curr_calling_sequence    VARCHAR2(2000);

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Delete_Hist_Dists';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  l_curr_calling_sequence := 'AP_Acctg_Prepay_Dist_Pkg.Delete_hist_dists<- ' ||
                                      p_calling_sequence;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;

  -- Bug fix 5634515
  -- rewrite the query to delete the correct prepay application dist record.

  -- delete from AP_Prepay_history_all is placed after delete from AP_Prepay_App_Dists
  -- due to bug 7264479

  -- Bug fix 5634515
  -- rewrite the query to delete the correct prepay history record.

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;

  --  bug9038462, the previous bug tags have been retained, but for the sake
  -- of code cleanliness, I am removing the old sqls used for deletions. Please
  -- refer to the prior versions if changes have to be compared
  --
  DELETE FROM ap_prepay_app_dists apad1
   WHERE apad1.prepay_history_id IN
      (SELECT apph.prepay_history_id
         FROM ap_prepay_history_all apph
        WHERE nvl(apph.posted_flag, 'N') <> 'Y'
          AND apph.invoice_id = p_invoice_id
          AND NOT EXISTS
              (SELECT 1
                 FROM ap_prepay_app_dists apad,
	              ap_invoice_distributions_all aid
                WHERE apad.prepay_history_id = apph.prepay_history_id
                  AND apad.prepay_app_distribution_id = aid.invoice_distribution_id
	          AND (aid.posted_flag = 'Y' OR aid.encumbered_flag = 'Y')));

  DELETE FROM ap_prepay_history_all apph1
   WHERE apph1.prepay_history_id IN
      (SELECT apph.prepay_history_id
         FROM ap_prepay_history_all apph
        WHERE nvl(apph.posted_flag, 'N') <> 'Y'
          AND apph.invoice_id = p_invoice_id
          AND NOT EXISTS
              (SELECT 1
                 FROM ap_prepay_app_dists apad,
	              ap_invoice_distributions_all aid
                WHERE apad.prepay_history_id = apph.prepay_history_id
                  AND apad.prepay_app_distribution_id = aid.invoice_distribution_id
	          AND (aid.posted_flag = 'Y' OR aid.encumbered_flag = 'Y')));


EXCEPTION

  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Delete_Hist_Dists;
END AP_ACCTG_PREPAY_DIST_PKG;

/
