--------------------------------------------------------
--  DDL for Package Body AP_ACCTG_PAY_DIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_ACCTG_PAY_DIST_PKG" AS
/* $Header: appaydib.pls 120.28.12010000.57 2010/05/13 10:43:21 rajnisku ship $ */

  G_Total_Dist_Amt             NUMBER := 0;
  G_Total_Prorated_Amt         NUMBER := 0;
  G_Total_Prorated_Disc_Amt    NUMBER := 0;
  G_Total_Inv_Dist_Amt         NUMBER := 0;
  G_Total_Inv_Dist_Disc_Amt    NUMBER := 0;
  G_Total_Bank_Curr_Amt        NUMBER := 0;
  G_Total_Bank_Curr_Disc_Amt   NUMBER := 0;
  G_Total_Dist_Amount          NUMBER := 0; --BUG 7308385
  G_Proration_Divisor          NUMBER := 0; --BUG 7308385
  G_Last_NonExcluded_Dist_ID   NUMBER := 0; --BUG 8202856

  G_Pay_AWT_Total_amt          NUMBER := 0; --Bug 8524600

  -- Logging Infra
  G_CURRENT_RUNTIME_LEVEL      NUMBER                := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(50) := 'AP.PLSQL.AP_ACCTG_PAY_DIST_PKG.';
  -- Logging Infra

-------------------------------------------------------------------------------
-- PROCEDURE  UPDATE_GAIN_LOSS_IND
-- The purpose of this procedure is to update the gain_loss_indicator on the
-- payment history table based on the exchange rates of payment transactions.
--
--------------------------------------------------------------------------------
PROCEDURE Update_Gain_Loss_Ind
     (P_XLA_Event_Rec      IN   ap_accounting_pay_pkg.r_xla_event_info
     ,P_Pay_Hist_Rec       IN   ap_accounting_pay_pkg.r_pay_hist_info
     ,P_Calling_Sequence   IN   VARCHAR2
     ) IS

  l_curr_calling_sequence    VARCHAR2(2000);
  l_pay_mat_count            NUMBER;
  l_when_to_account_gain_loss ap_system_parameters_all.when_to_account_gain_loss%TYPE;

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Update_Gain_Loss_Ind';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  CURSOR GAIN_LOSS_CUR ( P_CHECK_ID NUMBER , P_ACCOUNTING_EVENT_ID  NUMBER)
   IS
   SELECT SUM (NVL(APHD.PAID_BASE_AMOUNT,0) ) INV_PAY_AMT
       , SUM(NVL(APHD.INVOICE_DIST_BASE_AMOUNT,0) ) INV_AMT
       ,SUM(NVL(APHD.CLEARED_BASE_AMOUNT,0)) INV_CLR_AMT
       ,SUM(NVL(APHD.MATURED_BASE_AMOUNT,0)) INV_MAT_AMT
       ,AIP.INVOICE_ID
    FROM AP_INVOICE_PAYMENTS_ALL AIP
       , AP_INVOICE_DISTRIBUTIONS_ALL AID
       , AP_PAYMENT_HIST_DISTS APHD
   WHERE AIP.INVOICE_ID                 =AID.INVOICE_ID
     AND AID.INVOICE_DISTRIBUTION_ID    =APHD.INVOICE_DISTRIBUTION_ID
     AND AIP.CHECK_ID                   =P_CHECK_ID
     AND APHD.ACCOUNTING_EVENT_ID       =P_ACCOUNTING_EVENT_ID
     AND APHD.PAY_DIST_LOOKUP_CODE NOT IN ('FINAL CASH ROUNDING', 'FINAL PAYMENT ROUNDING')
   GROUP BY AIP.INVOICE_ID ;
  GAIN_LOSS_REC GAIN_LOSS_CUR%ROWTYPE ;
  TYPE GAIN_LOSS_TBL_T IS TABLE OF  GAIN_LOSS_CUR%ROWTYPE  INDEX BY BINARY_INTEGER;
  GAIN_LOSS_TBL GAIN_LOSS_TBL_T ;
BEGIN

  l_curr_calling_sequence := 'AP_Acctg_Pay_Dist_Pkg.Update_Gain_Loss_Ind<- ' ||
                                      p_calling_sequence;


  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;

   OPEN  GAIN_LOSS_CUR(P_XLA_EVENT_REC.SOURCE_ID_INT_1,P_XLA_EVENT_REC.EVENT_ID) ;
   FETCH GAIN_LOSS_CUR BULK COLLECT INTO GAIN_LOSS_TBL ;
   CLOSE GAIN_LOSS_CUR  ;

  ---Manual payment adusted event added in the list below for bug 7244022
  --MANUAL PAYMENT ADJUSTED event is commented for bug 7445576

  For I in  GAIN_LOSS_TBL.FIRST..GAIN_LOSS_TBL.LAST
  LOOP
  IF P_XLA_Event_Rec.Event_Type_Code IN ('PAYMENT CREATED', 'PAYMENT ADJUSTED', 'MANUAL PAYMENT ADJUSTED',
                                         'REFUND ADJUSTED', 'REFUND RECORDED') THEN

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Updating Gain Loss Indicator for Events ' ||
                               P_XLA_Event_Rec.Event_Type_Code;
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

	   UPDATE AP_PAYMENT_HIST_DISTS APHD
          SET APHD.GAIN_LOSS_INDICATOR =DECODE(SIGN( GAIN_LOSS_TBL(I).INV_AMT-GAIN_LOSS_TBL(I).INV_PAY_AMT), --BUG 8276839
         1, 'G',  -1, 'L', NULL)
        WHERE APHD.ACCOUNTING_EVENT_ID=P_XLA_EVENT_REC.EVENT_ID
          AND APHD.INVOICE_DISTRIBUTION_ID IN
         (SELECT INVOICE_DISTRIBUTION_ID
             FROM AP_INVOICE_DISTRIBUTIONS_ALL AID
            WHERE AID.INVOICE_ID=GAIN_LOSS_TBL(I).INVOICE_ID
         ) ;

    /* UPDATE AP_Payment_History_All APH
     SET    Gain_Loss_Indicator =
                 (SELECT DECODE(SIGN(SUM(nvl(APHD.Invoice_Dist_Base_Amount,0) - nvl(APHD.Paid_Base_Amount,0))), --Bug 8276839
                                  1, 'G', -1, 'L', NULL)
                  FROM   AP_Payment_Hist_Dists APHD
                  WHERE  APHD.Payment_History_ID = APH.Payment_History_ID
                  AND    APHD.Accounting_Event_ID = p_xla_event_rec.event_id
                  and aphd.invoice_distribution_id
                  in
         	  AND    APHD.pay_dist_lookup_code NOT IN  ('FINAL CASH ROUNDING', 'FINAL PAYMENT ROUNDING') --7614480/8288996
		  --AND	NVL(APHD.Reversal_Flag,'N') <> 'Y'				--added for bug 7244022
		  --above condition commented for bug 7445576
		  )
     WHERE  APH.Payment_History_Id = p_pay_hist_rec.payment_history_id;

    */
   /*Bug 8288996 Changes to handle Final Cash Rounding */

   --added the following additional condition for bug 7445576
   --reversal_flag condition should only be added for event type MANUAL PAYMENT ADJUSTED
   --for MANUAL PAYMENT ADJUSTED event the accounting paradigm is accounting line reversal
   --thus single loss or gain line gets created when PAYMENT CREATED has that
   --this reversal line condition is used so that accounting gets balanced for the event type MANUAL PAYMENT ADJUSTED
 /*  ELSIF P_XLA_Event_Rec.Event_Type_Code = 'MANUAL PAYMENT ADJUSTED' THEN

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Updating Gain Loss Indicator for Events ' ||
                               P_XLA_Event_Rec.Event_Type_Code;
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;


      UPDATE AP_Payment_History_All APH
         SET    Gain_Loss_Indicator =
                 (SELECT DECODE(SIGN(SUM(nvl(APHD.Invoice_Dist_Base_Amount,0) - nvl(APHD.Paid_Base_Amount,0))), --Bug 8276839
                                  1, 'G', -1, 'L', NULL)
                   FROM   AP_Payment_Hist_Dists APHD
                  WHERE  APHD.Payment_History_ID = APH.Payment_History_ID
                    AND    APHD.Accounting_Event_ID = p_xla_event_rec.event_id
		            AND    APHD.pay_dist_lookup_code NOT IN  ('FINAL CASH ROUNDING', 'FINAL PAYMENT ROUNDING')   --7614480/8288996
	                AND	 NVL(APHD.Reversal_Flag,'N') <> 'Y'
		           )
        WHERE  APH.Payment_History_Id = p_pay_hist_rec.payment_history_id;

*/
  ELSIF P_XLA_Event_Rec.Event_Type_Code IN ('PAYMENT MATURED',
                                            'PAYMENT MATURITY ADJUSTED') THEN

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Updating Gain Loss Indicator for Events: Event_ID = ' ||
                               P_XLA_Event_Rec.Event_ID;
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

  UPDATE AP_PAYMENT_HIST_DISTS APHD
     SET APHD.GAIN_LOSS_INDICATOR =DECODE(SIGN( GAIN_LOSS_TBL(I).INV_PAY_AMT-GAIN_LOSS_TBL(I).INV_MAT_AMT), --BUG 8276839
         1, 'G',  -1, 'L', NULL)
   WHERE APHD.ACCOUNTING_EVENT_ID=P_XLA_EVENT_REC.EVENT_ID
     AND APHD.INVOICE_DISTRIBUTION_ID IN
        (SELECT INVOICE_DISTRIBUTION_ID
             FROM AP_INVOICE_DISTRIBUTIONS_ALL AID
            WHERE AID.INVOICE_ID=GAIN_LOSS_TBL(I).INVOICE_ID
         ) ;

     /*UPDATE AP_Payment_History_All APH
     SET    Gain_Loss_Indicator =
              (SELECT DECODE(SIGN(SUM(nvl(APHD.Paid_Base_Amount,0) - nvl(APHD.Matured_Base_Amount,0))),      --Bug 8276839
                               1, 'G', -1, 'L', NULL)
               FROM   AP_Payment_Hist_Dists APHD
               WHERE  APHD.Payment_History_ID = APH.Payment_History_ID
	       AND    APHD.pay_dist_lookup_code NOT IN  ('FINAL CASH ROUNDING', 'FINAL PAYMENT ROUNDING')   --7614480/8288996
               AND    APHD.Accounting_Event_ID = p_xla_event_rec.event_id)
     WHERE  APH.Payment_History_Id = p_pay_hist_rec.payment_history_id;
	 */

    ELSIF P_XLA_Event_Rec.Event_Type_Code IN ('PAYMENT CLEARED',
                                            'PAYMENT CLEARING ADJUSTED') THEN

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Updating Gain Loss Indicator for Events: Event_ID = ' ||
                               P_XLA_Event_Rec.Event_ID;
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

     SELECT count(*)
     INTO   l_pay_mat_count
     FROM   AP_Payment_History_All APH,
            AP_Payment_History_All APH1
     WHERE  APH.Payment_History_Id = p_pay_hist_rec.payment_history_id
     AND    APH.Check_ID = APH1.Check_ID
     AND    APH.Transaction_Type IN ('PAYMENT CLEARING', 'PAYMENT CLEARING ADJUSTED')
     AND    APH1.Transaction_Type = 'PAYMENT MATURITY';

     IF l_pay_mat_count > 0 THEN

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'Updating Gain Loss between maturity and clearing events';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

	  UPDATE AP_PAYMENT_HIST_DISTS APHD
         SET APHD.GAIN_LOSS_INDICATOR =DECODE(SIGN( GAIN_LOSS_TBL(I).INV_MAT_AMT-GAIN_LOSS_TBL(I).INV_CLR_AMT), --BUG 8276839
         1, 'G',  -1, 'L', NULL)
       WHERE APHD.ACCOUNTING_EVENT_ID      =P_XLA_EVENT_REC.EVENT_ID
         AND APHD.INVOICE_DISTRIBUTION_ID IN
           (SELECT INVOICE_DISTRIBUTION_ID
             FROM AP_INVOICE_DISTRIBUTIONS_ALL AID
            WHERE AID.INVOICE_ID=GAIN_LOSS_TBL(I).INVOICE_ID
            ) ;

        /*UPDATE AP_Payment_History_All APH
        SET    Gain_Loss_Indicator =
                 (SELECT DECODE(SIGN(SUM(nvl(APHD.Matured_Base_Amount,0) - nvl(APHD.Cleared_Base_Amount,0))),   --Bug 8276839
                                  1, 'G', -1, 'L', NULL)
                  FROM   AP_Payment_Hist_Dists APHD
                  WHERE  APHD.Payment_History_ID = APH.Payment_History_ID
		  AND    APHD.pay_dist_lookup_code NOT IN  ('FINAL CASH ROUNDING', 'FINAL PAYMENT ROUNDING')   --7614480/8288996
                  AND    APHD.Accounting_Event_ID = p_xla_event_rec.event_id)
        WHERE  APH.Payment_History_Id = p_pay_hist_rec.payment_history_id;
		*/
     ELSE

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'Updating Gain Loss between invoice/payment and clearing events';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

        --bug 5257209

        SELECT ASP.when_to_account_gain_loss
        INTO   l_when_to_account_gain_loss
        FROM   ap_system_parameters_all ASP,
               AP_Payment_History_All APH
        WHERE  APH.org_id = ASP.org_id
        AND  APH.Payment_History_Id = p_pay_hist_rec.payment_history_id;

        IF (  l_when_to_account_gain_loss IS NOT NULL AND
              l_when_to_account_gain_loss = 'CLEARING ONLY' ) THEN

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'Update Gain/Loss between invoice and clearing for gain/loss at clear only';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          -- Bug 6678474. Backing out the fix for bug 6621586 since it is incorrect.
		    UPDATE AP_PAYMENT_HIST_DISTS APHD
               SET APHD.GAIN_LOSS_INDICATOR =DECODE(SIGN( GAIN_LOSS_TBL(I).INV_AMT-GAIN_LOSS_TBL(I).INV_CLR_AMT), --BUG 8276839
                                             1, 'G', -1, 'L', NULL)
             WHERE APHD.ACCOUNTING_EVENT_ID=P_XLA_EVENT_REC.EVENT_ID
               AND APHD.INVOICE_DISTRIBUTION_ID IN
                  (SELECT INVOICE_DISTRIBUTION_ID
                    FROM AP_INVOICE_DISTRIBUTIONS_ALL AID
                   WHERE AID.INVOICE_ID=GAIN_LOSS_TBL(I).INVOICE_ID
                   ) ;
         /* UPDATE AP_Payment_History_All APH
          SET    Gain_Loss_Indicator =
                 (SELECT DECODE(SIGN(SUM(nvl(APHD.Invoice_Dist_Base_Amount,0) - nvl(APHD.Cleared_Base_Amount,0))), --Bug 8276839
                                  1, 'G', -1, 'L', NULL)
                  FROM   AP_Payment_Hist_Dists APHD
                  WHERE  APHD.Payment_History_ID = APH.Payment_History_ID
		  AND    APHD.pay_dist_lookup_code NOT IN  ('FINAL CASH ROUNDING', 'FINAL PAYMENT ROUNDING')   --7614480/8288996
                  AND    APHD.Accounting_Event_ID = p_xla_event_rec.event_id)
          WHERE  APH.Payment_History_Id = p_pay_hist_rec.payment_history_id;
              */
        ELSE

           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'Update Gain/Loss between payment and clearing for gain/loss at always';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          -- Bug 6678474. Backing out the fix for bug 6621586 since it is incorrect.
	      UPDATE AP_PAYMENT_HIST_DISTS APHD
             SET APHD.GAIN_LOSS_INDICATOR =DECODE(SIGN( GAIN_LOSS_TBL(I).INV_PAY_AMT-GAIN_LOSS_TBL(I).INV_CLR_AMT), --BUG 8276839
                                    1, 'G',  -1, 'L', NULL)
           WHERE APHD.ACCOUNTING_EVENT_ID=P_XLA_EVENT_REC.EVENT_ID
             AND APHD.INVOICE_DISTRIBUTION_ID IN
               (SELECT INVOICE_DISTRIBUTION_ID
                  FROM AP_INVOICE_DISTRIBUTIONS_ALL AID
                 WHERE AID.INVOICE_ID=GAIN_LOSS_TBL(I).INVOICE_ID
               ) ;
	  /*
          UPDATE AP_PAYMENT_HISTORY_ALL APH
          SET    GAIN_LOSS_INDICATOR =
                 (SELECT DECODE(SIGN(SUM(NVL(APHD.PAID_BASE_AMOUNT,0) - NVL(APHD.CLEARED_BASE_AMOUNT,0))),   --BUG 8276839
                                  1, 'G', -1, 'L', NULL)
                  FROM   AP_PAYMENT_HIST_DISTS APHD
                  WHERE  APHD.PAYMENT_HISTORY_ID = APH.PAYMENT_HISTORY_ID
		  AND    APHD.PAY_DIST_LOOKUP_CODE NOT IN  ('FINAL CASH ROUNDING', 'FINAL PAYMENT ROUNDING')   --7614480/8288996
                  AND    APHD.ACCOUNTING_EVENT_ID = P_XLA_EVENT_REC.EVENT_ID)
          WHERE  APH.PAYMENT_HISTORY_ID = P_PAY_HIST_REC.PAYMENT_HISTORY_ID;
        */
        END IF;

     END IF;

  ELSIF P_XLA_Event_Rec.Event_Type_Code IN ('PAYMENT CANCELLED',
                                            'PAYMENT MATURITY REVERSED',
                                            'PAYMENT UNCLEARED',
                                            'REFUND CANCELLED') THEN

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Updating Gain Loss Indicator for Events: Event_ID = ' ||
                               P_XLA_Event_Rec.Event_ID;
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

     UPDATE AP_PAYMENT_HIST_DISTS APHD
     SET GAIN_LOSS_INDICATOR=
         (SELECT GAIN_LOSS_INDICATOR
             FROM AP_PAYMENT_HIST_DISTS APHD1
            WHERE PAYMENT_HISTORY_ID=P_PAY_HIST_REC.REV_PMT_HIST_ID
              AND APHD1.INVOICE_DISTRIBUTION_ID=APHD.INVOICE_DISTRIBUTION_ID
              AND ROWNUM=1
          )
   WHERE APHD.ACCOUNTING_EVENT_ID=P_XLA_EVENT_REC.EVENT_ID ;
    /* UPDATE AP_Payment_History_All APH
     SET    APH.Gain_Loss_Indicator =
                   (SELECT Gain_Loss_Indicator
                    FROM   AP_Payment_History_All APH1
                    WHERE  APH1.Payment_History_ID = APH.Rev_Pmt_Hist_ID)
     WHERE  APH.Payment_History_Id = p_pay_hist_rec.payment_history_id;
	 */

  END IF;
END LOOP ;
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
-- PROCEDURE  Primary_Pay_Events
-- The purpose of this procedure is to prorate the payment amount for all the
-- distributions of the invoice and generate the payment history distribution.
--
--------------------------------------------------------------------------------
PROCEDURE Primary_Pay_Events
     (P_XLA_Event_Rec      IN   ap_accounting_pay_pkg.r_xla_event_info
     ,P_Calling_Sequence   IN   VARCHAR2
     ) IS

  l_curr_calling_sequence    VARCHAR2(2000);
  l_event_id                 NUMBER;
  l_total_paid_amt           NUMBER;
  l_final_payment            BOOLEAN := FALSE;
  l_pay_history_id           NUMBER;
  l_mat_history_id           NUMBER;

  l_inv_pay_rec            r_inv_pay_info;
  l_pay_hist_rec           ap_accounting_pay_pkg.r_pay_hist_info;
  l_inv_rec                ap_accounting_pay_pkg.r_invoices_info;
  l_inv_dist_rec           ap_accounting_pay_pkg.r_inv_dist_info;

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Primary_Pay_Events';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  -- bug fix 6674279
  b_generate_pay_dist   BOOLEAN;
  l_sum_per_event       NUMBER;
  l_dist_count_per_event       NUMBER;

  -- bug 6900582
  l_upg_pmt_hist        NUMBER;
  l_upg_inv_pmts        NUMBER;
  l_upg_prepay_app      NUMBER;
  l_upg_event           BOOLEAN;

  --Bug 8524600
  l_curr_pay_awt_tot    NUMBER  :=0;
  l_inv_time_awt        NUMBER  :=0;
  l_inv_time_dist_total NUMBER  :=0;
  l_inv_time_awt_tot    NUMBER  :=0;
  l_count_bank_curr     NUMBER  :=0 ; --9011207
  --Bug 8524600
  -- condition: historical_flag =Y
  --         and event is 'INVOICE ADJUSTMENT'
  --         and ap_system_parameter.auto_offset_flag ='N'
  --         and sum of the distributions in the invoice adjustment event is 0

  CURSOR c_sum_per_event(p_acct_event_id  NUMBER) IS
  SELECT SUM(amount), count(1)
    FROM ap_invoice_distributions_all aid,
         xla_events evnt,
         ap_system_parameters_all asp
   WHERE aid.accounting_event_id = p_acct_event_id
     AND aid.accounting_event_id = evnt.event_id
     AND evnt.event_type_code in ('INVOICE ADJUSTED', 'CREDIT MEMO ADJUSTED',
                                  'DEBIT MEMO ADJUSTED')  --7630203
     AND aid.org_id = asp.org_id
     AND automatic_offsets_flag = 'N'
     AND aid.historical_flag = 'Y'
	 AND evnt.application_id=200;  --7623562


BEGIN

  l_curr_calling_sequence := 'AP_Acctg_Pay_Dist_Pkg.Primary_Pay_Events<- ' ||
                                      p_calling_sequence;


  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;


  OPEN Payment_History(P_XLA_Event_Rec.Event_ID);
  FETCH Payment_History INTO l_pay_hist_rec;
  CLOSE Payment_History;


  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'CUR: Payment_History: Payment_History_ID = '||
                    l_pay_hist_rec.payment_history_id ||
                    'and event type for payment is: ' ||
                    P_XLA_Event_Rec.Event_Type_Code;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

  /* We need payment hist information for the prior events in order
     to calculate the base amounts for the prior events using the
     exchange rate info from the payment hist table */

  IF (P_XLA_Event_Rec.Event_Type_Code IN ('PAYMENT MATURED')) THEN

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'inside logic of payment matured event and event type'||
                    P_XLA_Event_Rec.Event_Type_Code;
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      SELECT APH.Payment_History_ID,
             APH.Pmt_To_Base_XRate_Type,
             APH.Pmt_To_Base_XRate_Date,
             APH.Pmt_To_Base_XRate
      INTO   l_pay_history_id,
             ap_accounting_pay_pkg.g_pmt_to_base_xrate_type,
             ap_accounting_pay_pkg.g_pmt_to_base_xrate_date,
             ap_accounting_pay_pkg.g_pmt_to_base_xrate
      FROM   AP_Payment_History_All APH
      WHERE  APH.Payment_History_ID =
                        (SELECT MAX(APH1.Payment_History_ID)
                         FROM   AP_Payment_History_All APH1
                         WHERE  APH1.Check_ID = p_xla_event_rec.source_id_int_1
                         AND    APH1.Transaction_Type IN ('PAYMENT CREATED', 'REFUND RECORDED'));


      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Payment_History_ID for payment = '|| l_pay_history_id
                       || 'ap_accounting_pay_pkg.g_pmt_to_base_xrate_type'
                       || ap_accounting_pay_pkg.g_pmt_to_base_xrate_type
                       || 'ap_accounting_pay_pkg.g_pmt_to_base_xrate_date'
                       || ap_accounting_pay_pkg.g_pmt_to_base_xrate_date
                       || 'ap_accounting_pay_pkg.g_pmt_to_base_xrate'
                       || ap_accounting_pay_pkg.g_pmt_to_base_xrate;

          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      ap_accounting_pay_pkg.g_pay_pmt_history_id := l_pay_history_id;

      ap_accounting_pay_pkg.g_mat_pmt_history_id := l_pay_hist_rec.payment_history_id;
      ap_accounting_pay_pkg.g_mat_to_base_xrate_type :=
                                l_pay_hist_rec.pmt_to_base_xrate_type;
      ap_accounting_pay_pkg.g_mat_to_base_xrate_date :=
                                l_pay_hist_rec.pmt_to_base_xrate_date;
      ap_accounting_pay_pkg.g_mat_to_base_xrate := l_pay_hist_rec.pmt_to_base_xrate;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'After assign maturity related global variables and ' ||
                       'ap_accounting_pay_pkg.g_pay_pmt_history_id '||
                       ap_accounting_pay_pkg.g_pay_pmt_history_id ||
                       'ap_accounting_pay_pkg.g_mat_to_base_xrate_type' ||
                       ap_accounting_pay_pkg.g_mat_to_base_xrate_type ||
                       'ap_accounting_pay_pkg.g_mat_to_base_xrate_date' ||
                       ap_accounting_pay_pkg.g_mat_to_base_xrate_date ||
                       'ap_accounting_pay_pkg.g_mat_to_base_xrate' ||
                       ap_accounting_pay_pkg.g_mat_to_base_xrate;

          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

  ELSIF (P_XLA_Event_Rec.Event_Type_Code IN ('PAYMENT CLEARED')) THEN

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'inside logic of payment cleared event and event type'||
                    P_XLA_Event_Rec.Event_Type_Code;
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      SELECT APH.Payment_History_ID,
             APH.Pmt_To_Base_XRate_Type,
             APH.Pmt_To_Base_XRate_Date,
             APH.Pmt_To_Base_XRate
      INTO   l_pay_history_id,
             ap_accounting_pay_pkg.g_pmt_to_base_xrate_type,
             ap_accounting_pay_pkg.g_pmt_to_base_xrate_date,
             ap_accounting_pay_pkg.g_pmt_to_base_xrate
      FROM   AP_Payment_History_All APH
      WHERE  APH.Payment_History_ID =
                        (SELECT MAX(APH1.Payment_History_ID)
                         FROM   AP_Payment_History_All APH1
                         WHERE  APH1.Check_ID = p_xla_event_rec.source_id_int_1
                         AND    APH1.Transaction_Type IN ('PAYMENT CREATED', 'REFUND RECORDED'));

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Payment_History_ID for payment = '
                       || l_pay_history_id
                       || 'Payment_History_ID for maturity ='
                       || l_mat_history_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      SELECT MAX(APH.Payment_History_ID)
      INTO   l_mat_history_id
      FROM   AP_Payment_History_All APH
      WHERE  APH.Check_ID = p_xla_event_rec.source_id_int_1
      AND    APH.Transaction_Type IN ('PAYMENT MATURITY');


      IF l_mat_history_id IS NOT NULL THEN

         SELECT APH.Pmt_To_Base_XRate_Type,
                APH.Pmt_To_Base_XRate_Date,
                APH.Pmt_To_Base_XRate
         INTO   ap_accounting_pay_pkg.g_mat_to_base_xrate_type,
                ap_accounting_pay_pkg.g_mat_to_base_xrate_date,
                ap_accounting_pay_pkg.g_mat_to_base_xrate
         FROM   AP_Payment_History_All APH
         WHERE  APH.Payment_History_ID = l_mat_history_id;

      END IF;


      ap_accounting_pay_pkg.g_pay_pmt_history_id := l_pay_history_id;
      ap_accounting_pay_pkg.g_mat_pmt_history_id := l_mat_history_id;

      ap_accounting_pay_pkg.g_clr_pmt_history_id := l_pay_hist_rec.payment_history_id;
      ap_accounting_pay_pkg.g_clr_to_base_xrate_type :=
                                l_pay_hist_rec.pmt_to_base_xrate_type;
      ap_accounting_pay_pkg.g_clr_to_base_xrate_date :=
                                l_pay_hist_rec.pmt_to_base_xrate_date;
      ap_accounting_pay_pkg.g_clr_to_base_xrate := l_pay_hist_rec.pmt_to_base_xrate;


      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'after set clearing global varaiables, they are'||
                        'ap_accounting_pay_pkg.g_pay_pmt_history_id=' ||
                         ap_accounting_pay_pkg.g_pay_pmt_history_id ||
                        'ap_accounting_pay_pkg.g_mat_pmt_history_id =' ||
                        ap_accounting_pay_pkg.g_mat_pmt_history_id ||
                        ' ap_accounting_pay_pkg.g_clr_pmt_history_id =' ||
                         ap_accounting_pay_pkg.g_clr_pmt_history_id  ||
                        'ap_accounting_pay_pkg.g_clr_to_base_xrate_type=' ||
                        ap_accounting_pay_pkg.g_clr_to_base_xrate_type ||
                        'ap_accounting_pay_pkg.g_clr_to_base_xrate_date=' ||
                        ap_accounting_pay_pkg.g_clr_to_base_xrate_date ||
                        'ap_accounting_pay_pkg.g_clr_to_base_xrate=' ||
                        ap_accounting_pay_pkg.g_clr_to_base_xrate;

          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

  ELSE

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'inside logic of other payment event and event type'||
                     P_XLA_Event_Rec.Event_Type_Code;
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      ap_accounting_pay_pkg.g_pay_pmt_history_id := l_pay_hist_rec.payment_history_id;
      ap_accounting_pay_pkg.g_pmt_to_base_xrate_type :=
                                l_pay_hist_rec.pmt_to_base_xrate_type;
      ap_accounting_pay_pkg.g_pmt_to_base_xrate_date :=
                                l_pay_hist_rec.pmt_to_base_xrate_date;
      ap_accounting_pay_pkg.g_pmt_to_base_xrate := l_pay_hist_rec.pmt_to_base_xrate;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Payment_History_ID for payment = '||
                                        l_pay_hist_rec.payment_history_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

  END IF;


  -- Bug6900582
  -- Get the count of historical payment history records for this check.
  -- We should not do final and total rounding for payments that have been
  -- upgraded to R12, since during upgrade the amounts are not populated for
  -- some exchange rates in the ap_payment_hist_dists table and trying to
  -- calculate the rounding for such payments will result in incorrect
  -- accounting.
  --
  -- Bug 9492002, added the Join with XAH/ASP so as to ensure that
  -- event has been Marked as P with Accounting Lines in R12
  --
  SELECT count(*)
  INTO   l_upg_pmt_hist
  FROM   AP_Payment_History_All APH,
         AP_System_Parameters_ALL ASP,
         XLA_AE_Headers XAH
  WHERE  APH.Check_ID = p_xla_event_rec.source_id_int_1
  AND    APH.Historical_Flag = 'Y'
  AND    APH.Posted_Flag = 'Y'
  AND    APH.Org_ID = ASP.Org_ID
  AND    APH.Accounting_Event_ID = XAH.Event_ID
  AND    XAH.Ledger_id = ASP.Set_Of_Books_ID
  AND    XAH.Application_ID = 200
  AND    XAH.Accounting_Entry_Status_Code = 'F'
  AND    XAH.upg_batch_id IS NOT NULL
  AND    XAH.upg_batch_id <> -9999;


  /* For Clearing and Maturity events we need to get all the invoice payments, but for the
     Payment event we only need to get the invoice payments stamped with that event id */

  IF (P_XLA_Event_Rec.Event_Type_Code IN ('PAYMENT CLEARED', 'PAYMENT MATURED')) THEN
      OPEN Clrg_Invoice_Payments(P_XLA_Event_Rec.Source_ID_Int_1);
  ELSE
      OPEN Invoice_Payments(P_XLA_Event_Rec.Event_ID);
  END IF;

  LOOP

      IF (P_XLA_Event_Rec.Event_Type_Code IN ('PAYMENT CLEARED', 'PAYMENT MATURED')) THEN
           FETCH Clrg_Invoice_Payments INTO l_inv_pay_rec;
           EXIT WHEN Clrg_Invoice_Payments%NOTFOUND OR
                     Clrg_Invoice_Payments%NOTFOUND IS NULL;

           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'loop through CUR: Clrg_Invoice_Payments: Invoice_ID = '||
                                        l_inv_pay_rec.invoice_id;
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;

	   --9011207 final payment logic will not be applied to payment clearing events
	   -- of payment ,if the bank currency of payments paying an invoice are
	   -- different.

	   IF (P_XLA_Event_Rec.Event_Type_Code IN ('PAYMENT CLEARED')) THEN

            BEGIN
             select COUNT( DISTINCT aph.bank_currency_code)
               into l_count_bank_curr
               from ap_payment_history_all aph,
                    ap_invoice_payments_all aip
              where aph.check_id = aip.check_id
                and aph.transaction_type  in ('PAYMENT CLEARING')
                and aip.invoice_id = l_inv_pay_rec.invoice_id
                and aph.REV_PMT_HIST_ID is  null
	        and nvl(aip.reversal_flag,'N') <> 'Y'
	        and not exists ( select '1'
	                           from ap_payment_history_all aph_rev
	          		  where aph_rev.REV_PMT_HIST_ID = aph.payment_history_id
                                    and aph_rev.REV_PMT_HIST_ID is not null)
		;
	    EXCEPTION
             WHEN OTHERS THEN
               l_count_bank_curr := 0 ;
            END ;

	   END IF ;
          --9011207

      ELSE
           FETCH Invoice_Payments INTO l_inv_pay_rec;
           EXIT WHEN Invoice_Payments%NOTFOUND OR
                     Invoice_Payments%NOTFOUND IS NULL;

           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'loop through CUR: Invoice_Payments: Invoice_ID = '||
                                        l_inv_pay_rec.invoice_id;
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;

      END IF;


       OPEN Invoice_Header(l_inv_pay_rec.invoice_id);
       FETCH Invoice_Header INTO l_inv_rec;
       CLOSE Invoice_Header;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'inside payment cursor loop, after open CUR:Invoice_Header: Invoice_ID= '
                         || l_inv_rec.invoice_id;
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;


       -- Bug 6900582. While upgrading the payment hist dists table during R12
       -- upgrade, the invoice, paid, matured and cleared base amounts are not
       -- populated since the exchange rates are not available in a single table
       -- and even if we can get exchange rates there is no guarantee that the
       -- amounts are equal to the accounted amounts due to proration.

       -- In order to fix bug 6900582, when there is a partial payment to an
       -- invoice and the invoice has upgraded payments or when an upgraded
       -- payment is matured or cleared, we will not calculate the final payment
       -- rounding or any other roundings to avoid creating huge gain and loss.

       -- If there is a rounding due to proration, instead of rounding the
       -- the difference can go to gain loss account.

       -- Bug 9492002, added the Join with XAH and ASP in the subquery so as to
       -- ensure that the event has been Accounted in R12
       --
       SELECT count(*)
       INTO   l_upg_inv_pmts
       FROM   AP_Invoice_Payments_All AIP
       WHERE  Invoice_ID = l_inv_pay_rec.invoice_id
       AND    EXISTS (SELECT 'Upg Payment'
                      FROM   AP_Payment_History_All APH,
                             AP_System_Parameters_All ASP,
                             XLA_AE_Headers XAH
                      WHERE  APH.Check_ID = AIP.Check_ID
                      AND    APH.Historical_Flag = 'Y'
                      AND    APH.Posted_Flag = 'Y'
                      AND    APH.Org_id = ASP.Org_id
                      AND    APH.Accounting_Event_ID = XAH.Event_ID
                      AND    XAH.Ledger_id = ASP.Set_of_Books_ID
                      AND    XAH.Application_ID = 200
                      AND    XAH.Accounting_Entry_Status_Code = 'F'
                      AND    XAH.Upg_Batch_ID <> -9999
                      AND    XAH.Upg_Batch_ID IS NOT NULL
                      AND    Rownum = 1);

      -- Bug9492002, checking if there are any upgaded prepay applications
      -- or Unapplication for the Invoice, which are Historical and have
      -- been accounted in 11i
      --
      SELECT count(*)
        INTO l_upg_prepay_app
        FROM AP_Invoice_Distributions_ALL AID,
             XLA_AE_Headers XAH
       WHERE AID.accounting_event_id = XAH.Event_ID
         AND XAH.Application_ID = 200
         AND XAH.Event_type_Code IN ('PREPAYMENT APPLIED', 'PREPAYMENT UNAPPLIED')
         AND XAH.Upg_batch_ID IS NOT NULL
         AND XAH.Upg_batch_ID <> -9999
         AND XAH.Ledger_ID = AID.Set_of_Books_ID
         AND XAH.Accounting_Entry_Status_Code = 'F'
         AND NVL(AID.Historical_Flag, 'N') = 'Y'
         AND AID.Invoice_id = l_inv_pay_rec.Invoice_id
         AND rownum = 1;

       IF l_upg_inv_pmts = 0 AND l_upg_prepay_app = 0 THEN
          /* Check if the invoice is fully paid */

        IF (l_inv_pay_rec.amount <> 0 AND l_count_bank_curr <= 1)THEN
	--bug 8987496
	-- 9011207 Added l_count_bank_curr to the condition
          l_final_payment := AP_Accounting_Pay_Pkg.Is_Final_Payment
                              (l_inv_rec,
                               l_inv_pay_rec.amount,
                               l_inv_pay_rec.discount_taken,
                               0, -- prepay amount
                               p_xla_event_rec.event_type_code,
                               l_curr_calling_sequence);
       -- bug7247744
        END IF; --bug 8987496
       ELSE
         l_final_payment := FALSE;
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           IF l_final_payment THEN
              l_log_msg := 'Final payment of Invoice_ID '||l_inv_rec.invoice_id;
           ELSE
              l_log_msg := 'Not final payment of Invoice_ID '||l_inv_rec.invoice_id;
           END IF;
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Ready to open Invoice_Dists cursor after final payment check';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       -- Perfomance Fix 7308385
       -- Same query is used 3 different places in Pkg. when
       -- ever the query is modified pls do the same in reamining 2 places.
       -- Bug 7636427 Start
      SELECT SUM(decode(aid.prepay_tax_parent_id, NULL, nvl(aid.amount, 0), 0)),
             SUM(decode(aid.line_type_lookup_code, 'AWT', 0, nvl(aid.amount, 0))),
	     SUM(decode(aid.awt_invoice_payment_id, Null, nvl(aid.amount, 0),0)),
	     SUM(decode(aid.awt_invoice_payment_id, Null, 0,nvl(aid.amount, 0))),
	     SUM(decode(aid.line_type_lookup_code, 'AWT',decode(aid.awt_invoice_payment_id, Null, nvl(aid.amount, 0),0), 0))
        INTO G_Total_Dist_Amount,
	     G_Proration_Divisor,
	     l_inv_time_dist_total,
	     l_curr_pay_awt_tot,
	     l_inv_time_awt_tot
        FROM ap_invoice_distributions_all aid
       WHERE aid.invoice_id = l_inv_pay_rec.invoice_id
         AND aid.line_type_lookup_code <> 'PREPAY'
         AND aid.prepay_distribution_id IS NULL
         AND (aid.awt_invoice_payment_id IS NULL    OR
              aid.awt_invoice_payment_id = l_inv_pay_rec.invoice_payment_id) -- bug fix: 6725866
         AND NOT EXISTS
              (SELECT 1 FROM xla_events
               WHERE event_id = aid.accounting_event_id
               AND application_id = 200
               AND event_type_code IN('INVOICE CANCELLED', 'PREPAYMENT CANCELLED',
                      'CREDIT MEMO CANCELLED', 'DEBIT MEMO CANCELLED'));
-- Bug 8524600

        l_curr_pay_awt_tot:= nvl(l_curr_pay_awt_tot,0);
        l_inv_time_awt_tot:= nvl(l_inv_time_awt_tot,0);
        l_inv_time_dist_total:= nvl(l_inv_time_dist_total,0);

        if (l_inv_time_dist_total <> 0 ) then
		G_Pay_AWT_Total_Amt    := nvl(l_curr_pay_awt_tot,0)
			+ nvl( (l_inv_time_awt_tot
			/  l_inv_time_dist_total
			* (GL_Currency_API.Convert_Amount(
				l_inv_rec.payment_currency_code,
				l_inv_rec.invoice_currency_code,
				l_inv_rec.payment_cross_rate_date,
				'EMU FIXED',
				l_inv_pay_rec.amount)-l_curr_pay_awt_tot)),0);
	else
	    G_Pay_AWT_Total_Amt := nvl(l_curr_pay_awt_tot,0) + nvl(l_inv_time_awt_tot,0);
	end if;
	-- Bug 7636427 End
        -- Bug 8524600 End


      --Bug 8202856.  Find the last distribution for which discount will be calculated.
      --This is necessary where some distributions are excluded from the discount calculation.
      --This one will be adjusted to compensate for rounding differences.

      IF l_inv_pay_rec.Discount_Taken > 0 AND (l_inv_rec.Disc_Is_Inv_Less_Tax_Flag = 'Y'
                OR  l_inv_rec.Exclude_Freight_From_Discount = 'Y') THEN

      --Exception handling added for bug 8406754
      BEGIN

        SELECT Sub.Invoice_Distribution_ID
        INTO G_Last_NonExcluded_Dist_ID
        FROM     (SELECT AID.Invoice_Distribution_ID
            FROM   AP_Invoice_Distributions_All AID,
            Financials_System_Params_All FSP,
            AP_Invoices_All AI,
            AP_System_Parameters_All ASP
            WHERE  AID.Invoice_ID = l_inv_rec.Invoice_ID
            AND    AI.Invoice_ID = AID.Invoice_ID
            AND    ASP.Org_ID = AI.Org_ID
            AND    AID.Line_Type_Lookup_Code NOT IN ('PREPAY', 'ERV', 'TERV'
            , 'AWT'  --Pay_Dist_Discount is only called for non-AWT line types
            , decode(AI.Exclude_Freight_From_Discount,'Y', 'FREIGHT', 'DUMMY')
            , decode(NVL(AI.Disc_Is_Inv_Less_Tax_Flag, ASP.Disc_Is_Inv_Less_Tax_Flag)
                    , 'Y', 'TRV', 'DUMMY')
            , decode(NVL(AI.Disc_Is_Inv_Less_Tax_Flag, ASP.Disc_Is_Inv_Less_Tax_Flag)
                    , 'Y', 'TIPV', 'DUMMY')
            , decode(NVL(AI.Disc_Is_Inv_Less_Tax_Flag, ASP.Disc_Is_Inv_Less_Tax_Flag)
                    , 'Y', 'NONREC_TAX', 'DUMMY')
            , decode(NVL(AI.Disc_Is_Inv_Less_Tax_Flag, ASP.Disc_Is_Inv_Less_Tax_Flag)
                    , 'Y', 'REC_TAX', 'DUMMY')
            )
            AND    AID.Prepay_Distribution_ID IS NULL
            AND    AID.Prepay_Tax_Parent_ID IS NULL  -- For tax dists created in R11.5
            AND    AID.Org_ID = FSP.Org_ID
            AND NOT EXISTS (SELECT 1
                FROM   xla_events
                WHERE  event_id = AID.accounting_event_id
                AND    application_id = 200 --bug 7308385
                AND    event_type_code IN ('INVOICE CANCELLED', 'PREPAYMENT CANCELLED',
                'CREDIT MEMO CANCELLED',
                'DEBIT MEMO CANCELLED'))
            AND  ((NVL(FSP.Purch_Encumbrance_Flag,'N') = 'N'
                    AND AID.Match_Status_Flag IN ('T','A'))
                OR
                ((NVL(FSP.Purch_Encumbrance_Flag,'N') = 'Y'
                AND AID.Match_Status_Flag = 'A')))
            ORDER  BY abs(AID.Amount) desc, AID.Invoice_Distribution_ID desc) Sub
        WHERE rownum = 1;

	EXCEPTION

	WHEN OTHERS THEN
        G_Last_NonExcluded_Dist_ID := 0;

	END;

      END IF;


       OPEN Invoice_Dists(l_inv_pay_rec.invoice_id);
       LOOP

            FETCH Invoice_Dists INTO l_inv_dist_rec;
            EXIT WHEN Invoice_Dists%NOTFOUND OR
                      Invoice_Dists%NOTFOUND IS NULL;


            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                l_log_msg := 'Loop start for cur Invoice_Dists : Invoice_Dists: Invoice_Distribution_ID = '
                                     ||l_inv_dist_rec.invoice_distribution_id;
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;


            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                l_log_msg := 'Calling procedure Pay_Dist_Proc for dist: '
                                  || l_inv_dist_rec.invoice_distribution_id;
                FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
            END IF;

            -- bugfix 6674279
            -- for upgraded invoice adjustment event, if the distributions in the adjustment event
            -- have sum amount of 0, then don't create the payment distribution, this will avoid the
            -- accounting failure when payment liability line using Business flow to derive the
            -- accounting ccid from invoice liability as for such case in 11i, there is no liability
            -- accounting line generated.

            -- condition: historical_flag =Y
            --         and event is 'INVOICE ADJUSTED'
            --         and ap_system_parameter.auto_offset_flag ='N'
            --         and sum of the distributions in the invoice adjustment event is 0

            b_generate_pay_dist := TRUE;
            IF  l_inv_dist_rec.historical_flag ='Y' THEN
              OPEN c_sum_per_event(l_inv_dist_rec.accounting_event_id);
              FETCH c_sum_per_event into l_sum_per_event, l_dist_count_per_event;

              -- > 0 case is to handled the case that only  1 line in adjustment event and itself amount is 0
              If l_dist_count_per_event > 0 AND l_sum_per_event = 0 THEN
                b_generate_pay_dist := FALSE;
              END IF;

              CLOSE c_sum_per_event;

            END IF;

            IF b_generate_pay_dist AND
               ((l_inv_dist_rec.awt_invoice_payment_id IS NULL) OR
               (l_inv_dist_rec.awt_invoice_payment_id = l_inv_pay_rec.invoice_payment_id)) THEN
              -- Create awt distributions only when the awt is created during invoice time or
              -- if the awt is created during the payment time then only those awt distributions
              -- created during this payment
               -- Create cash distribution lines
               Pay_Dist_Proc(p_xla_event_rec,
                             l_inv_pay_rec,
                             l_pay_hist_rec,
                             l_inv_rec,
                             l_inv_dist_rec,
                             'P',
                             l_final_payment,
                             l_curr_calling_sequence);
            END IF;


            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                l_log_msg := 'Inside loop Invoice_Dists: After Procedure Pay_Dist_Proc executed';
                FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
            END IF;

       END LOOP;
       CLOSE Invoice_Dists;

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'cursor Invoice_Dists is closed ';
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
       END IF;

       G_Total_Dist_Amt := 0;
       G_Total_Prorated_Amt := 0;
       G_Total_Prorated_Disc_Amt := 0;
       G_Total_Inv_Dist_Amt := 0;
       G_Total_Inv_Dist_Disc_Amt := 0;
       G_Total_Bank_Curr_Amt := 0;
       G_Total_Bank_Curr_Disc_Amt := 0;
       G_Last_NonExcluded_Dist_ID := 0; --Bug 8202856


       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'Calling procedure P_Acctg_Pay_Round_Pkg.Do_Rounding for Invoice_ID: '
                                    || l_inv_rec.invoice_id;
           FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
       END IF;


       -- Bug 6900582. Do not do rounding calculation if the payment is upgraded
       -- or invoice has other upgraded payments
       --
       -- Bug 9492002. Do not do rounding calculations if the invoice being paid
       -- has an Upgraded prepayment Applications
       --
       IF l_upg_inv_pmts = 0 AND
          l_upg_pmt_hist = 0 AND
          l_upg_prepay_app = 0 THEN

          -- Create total and final rounding lines
          AP_Acctg_Pay_Round_Pkg.Do_Rounding
                     (p_xla_event_rec,
                      l_pay_hist_rec,
                      NULL, -- clr hist rec
                      l_inv_rec,
                      l_inv_pay_rec,
                      NULL, -- prepay inv rec
                      NULL, -- prepay hist rec
                      NULL, -- prepay dist rec
                      l_curr_calling_sequence);

       END IF;

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'Procedure P_Acctg_Pay_Round_Pkg.Do_Rounding executed';
           FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
       END IF;

        l_final_payment := FALSE; --9011207 Resetting the flag

  END LOOP;

  IF (P_XLA_Event_Rec.Event_Type_Code IN ('PAYMENT CLEARED', 'PAYMENT MATURED')) THEN
    CLOSE Clrg_Invoice_Payments;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'after close cursor Clrg_Invoice_Payments ';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
    END IF;
  ELSE
    CLOSE Invoice_Payments;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'after close cursor Invoice_Payment ';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
    END IF;
  END IF;


  IF l_pay_hist_rec.Errors_Bank_Amount <> 0 THEN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'Calling procedure Pay_Dist_Err_Chrg for errors bank amount and '
                      || 'l_pay_hist_rec.Errors_Bank_Amount'
                      || l_pay_hist_rec.Errors_Bank_Amount;
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;


     -- Create error distribution lines
     --bug 5659368
     Pay_Dist_Err_Chrg
          ( p_xla_event_rec     => p_xla_event_rec
            ,p_pay_hist_rec     => l_pay_hist_rec
            ,p_distribute_mode  => 'BANK_ERROR'
            ,p_calling_sequence => l_curr_calling_sequence);

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'Procedure Pay_Dist_Err_Chrg for errors bank amount executed';
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;

  END IF;

  IF l_pay_hist_rec.Charges_Bank_Amount <> 0 THEN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'Calling procedure Pay_Dist_Err_Chrg for charges bank amount =' ||
                      'l_pay_hist_rec.Charges_Bank_Amount' ||
                      l_pay_hist_rec.Charges_Bank_Amount;
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;


     -- Create charge distribution lines
     --bug 5659368

     Pay_Dist_Err_Chrg
          ( p_xla_event_rec     => p_xla_event_rec
            ,p_pay_hist_rec     => l_pay_hist_rec
            ,p_distribute_mode  => 'BANK_CHARGE'
            ,p_calling_sequence => l_curr_calling_sequence);

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'Procedure Pay_Dist_Err_Chrg for charges bank amount executed';
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;

  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Calling procedure Update_Gain_Loss_Ind for payments';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  Update_Gain_Loss_Ind
        (p_xla_event_rec,
         l_pay_hist_rec,
         l_curr_calling_sequence);

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Procedure Update_Gain_Loss_Ind executed';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
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

END Primary_Pay_Events;



-------------------------------------------------------------------------------
-- PROCEDURE Manual_Pay_Adj_Events
-- The purpose of this procedure is to prorate the payment amount for all the
-- distributions of the invoice for the manual adjustment event and
-- generate the payment history distribution.
--
--------------------------------------------------------------------------------
PROCEDURE Manual_Pay_Adj_Events
     (P_XLA_Event_Rec      IN   ap_accounting_pay_pkg.r_xla_event_info
     ,P_Calling_Sequence   IN   VARCHAR2
     ) IS

  l_curr_calling_sequence    VARCHAR2(2000);
  l_total_paid_amt           NUMBER;
  l_final_payment            BOOLEAN := FALSE;

  l_inv_pay_rec              r_inv_pay_info;
  l_pay_hist_rec             ap_accounting_pay_pkg.r_pay_hist_info;
  l_inv_rec                  ap_accounting_pay_pkg.r_invoices_info;
  l_inv_dist_rec             ap_accounting_pay_pkg.r_inv_dist_info;
  --Bug 8524600
  l_curr_pay_awt_tot    NUMBER :=0;
  l_inv_time_awt        NUMBER :=0;
  l_inv_time_dist_total NUMBER :=0;
  l_inv_time_awt_tot    NUMBER :=0;
  --Bug 8524600
  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Manual_Pay_Adj_Events';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  l_curr_calling_sequence := 'AP_ACCTG_PAY_DIST_PKG.Manual_Pay_Adj_Events<-' ||
                                           p_calling_sequence;

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;


  -- Get the payment hist info of the payment event
  OPEN Payment_History(p_xla_event_rec.event_id);
  FETCH Payment_History INTO l_pay_hist_rec;
  CLOSE Payment_History;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'CUR: Payment_History: Payment_History_ID = '||
                                          l_pay_hist_rec.payment_history_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  OPEN Invoice_Payments(p_xla_event_rec.event_id);
  LOOP

       Fetch Invoice_Payments INTO l_inv_pay_rec;
       EXIT WHEN Invoice_Payments%NOTFOUND OR
                 Invoice_Payments%NOTFOUND IS NULL;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'CUR: Invoice_Payments: Invoice_ID = '||l_inv_pay_rec.invoice_id
                           || 'Reversal_Flag = '||l_inv_pay_rec.reversal_flag;
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       /* If this invoice payment is a reversal the payment distributions will be created
          by reversing the original distributions */
       IF l_inv_pay_rec.reversal_flag = 'Y' THEN


          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
              l_log_msg := 'Calling procedure Pay_Dist_Reverse for invoice: '
                                || l_inv_pay_rec.invoice_id;
              FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
          END IF;

          -- Create payment hist distributions by reversing the
          -- original payment hist dists.
          Pay_Dist_Reverse
               (p_xla_event_rec,
                l_inv_pay_rec,
                l_pay_hist_rec,
                l_inv_pay_rec.reversal_inv_pmt_id,
                NULL, -- related_Event_id
                NULL, -- inv dist id
                NULL, -- inv dist rec
                l_curr_calling_sequence);

          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
              l_log_msg := 'Procedure Pay_Dist_Reverse executed';
              FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
          END IF;

       ELSE

          OPEN Invoice_Header(l_inv_pay_rec.invoice_id);
          FETCH Invoice_Header INTO l_inv_rec;
          CLOSE Invoice_Header;


          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'CUR: Invoice_Header: Invoice_ID= '|| l_inv_rec.invoice_id;
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          /* Check if the invoice is fully paid */
	  IF l_inv_pay_rec.amount <> 0 THEN    --bug 8987496
            l_final_payment := AP_Accounting_Pay_Pkg.Is_Final_Payment
                                 (l_inv_rec,
                                  l_inv_pay_rec.amount,
                                  l_inv_pay_rec.discount_taken,
                                  0, -- prepay amount
                                  p_xla_event_rec.event_type_code,
                                  l_curr_calling_sequence);
          END IF;  --bug 8987496
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              IF l_final_payment THEN
                 l_log_msg := 'Final payment of Invoice_ID '||l_inv_rec.invoice_id;
              ELSE
                 l_log_msg := 'Not final payment of Invoice_ID '||l_inv_rec.invoice_id;
              END IF;
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

       -- Perfomance Fix 7308385
	   -- Bug 7636427 Start
      SELECT SUM(decode(aid.prepay_tax_parent_id, NULL, nvl(aid.amount, 0), 0)),
             SUM(decode(aid.line_type_lookup_code, 'AWT', 0, nvl(aid.amount, 0))),
	     SUM(decode(aid.awt_invoice_payment_id, Null, nvl(aid.amount, 0),0)),
	     SUM(decode(aid.awt_invoice_payment_id, Null, 0,nvl(aid.amount, 0))),
	     SUM(decode(aid.line_type_lookup_code, 'AWT',decode(aid.awt_invoice_payment_id, Null, nvl(aid.amount, 0),0), 0))
        INTO G_Total_Dist_Amount,
	     G_Proration_Divisor,
	     l_inv_time_dist_total,
 	     l_curr_pay_awt_tot,
	     l_inv_time_awt_tot
        FROM ap_invoice_distributions_all aid
       WHERE aid.invoice_id = l_inv_pay_rec.invoice_id
         AND aid.line_type_lookup_code <> 'PREPAY'
         AND aid.prepay_distribution_id IS NULL
         AND (aid.awt_invoice_payment_id IS NULL    OR
              aid.awt_invoice_payment_id = l_inv_pay_rec.invoice_payment_id) -- bug fix: 6725866
         AND NOT EXISTS
              (SELECT 1 FROM xla_events
               WHERE event_id = aid.accounting_event_id
               AND application_id = 200
               AND event_type_code IN('INVOICE CANCELLED', 'PREPAYMENT CANCELLED',
                      'CREDIT MEMO CANCELLED', 'DEBIT MEMO CANCELLED'));

 -- Bug 8524600
        l_curr_pay_awt_tot:= nvl(l_curr_pay_awt_tot,0);
        l_inv_time_awt_tot:= nvl(l_inv_time_awt_tot,0);
        l_inv_time_dist_total:= nvl(l_inv_time_dist_total,0);

        if (l_inv_time_dist_total <> 0 ) then
		G_Pay_AWT_Total_Amt    := nvl(l_curr_pay_awt_tot,0)
			+ nvl( (l_inv_time_awt_tot
			/  l_inv_time_dist_total
			* (GL_Currency_API.Convert_Amount(
				l_inv_rec.payment_currency_code,
				l_inv_rec.invoice_currency_code,
				l_inv_rec.payment_cross_rate_date,
				'EMU FIXED',
				l_inv_pay_rec.amount)-l_curr_pay_awt_tot)),0);
	else
	    G_Pay_AWT_Total_Amt := nvl(l_curr_pay_awt_tot,0) + nvl(l_inv_time_awt_tot,0);
	end if;
	-- Bug 7636427 End
        -- Bug 8524600 End

          OPEN Invoice_Dists(l_inv_pay_rec.invoice_id);
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
                   l_log_msg := 'Calling procedure Pay_Dist_Proc for dist: '
                                     || l_inv_dist_rec.invoice_distribution_id;
                   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
               END IF;

               -- Create awt distributions only when the awt is created during invoice time or
               -- if the awt is created during the payment time then only those awt distributions
               -- created during this payment
               IF (l_inv_dist_rec.awt_invoice_payment_id IS NULL) OR
                  (l_inv_dist_rec.awt_invoice_payment_id = l_inv_pay_rec.invoice_payment_id) THEN
                  -- Create cash distribution lines for the new invoice payment
                  Pay_Dist_Proc(p_xla_event_rec,
                                l_inv_pay_rec,
                                l_pay_hist_rec,
                                l_inv_rec,
                                l_inv_dist_rec,
                                'M',
                                l_final_payment,
                                l_curr_calling_sequence);

               END IF;


               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   l_log_msg := 'Procedure Pay_Dist_Proc executed';
                   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
               END IF;


          END LOOP;
          CLOSE Invoice_Dists;

          G_Total_Dist_Amt := 0;
          G_Total_Prorated_Amt := 0;
          G_Total_Prorated_Disc_Amt := 0;
          G_Total_Inv_Dist_Amt := 0;
          G_Total_Inv_Dist_Disc_Amt := 0;
          G_Total_Bank_Curr_Amt := 0;
          G_Total_Bank_Curr_Disc_Amt := 0;


          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
              l_log_msg := 'Calling procedure P_Acctg_Pay_Round_Pkg.Do_Rounding for Invoice_ID: '
                                       || l_inv_rec.invoice_id;
              FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
          END IF;

          -- Create total and final payment roundings
          AP_Acctg_Pay_Round_Pkg.Do_Rounding
                     (p_xla_event_rec,
                      l_pay_hist_rec,
                      NULL, -- clr hist rec
                      l_inv_rec,
                      l_inv_pay_rec,
                      NULL, -- prepay inv rec
                      NULL, -- prepay hist rec
                      NULL, -- prepay dist rec
                      l_curr_calling_sequence);

          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
              l_log_msg := 'Procedure P_Acctg_Pay_Round_Pkg.Do_Rounding executed';
              FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
          END IF;


      END IF;

  END LOOP;
  CLOSE Invoice_Payments;



  IF l_pay_hist_rec.Errors_Bank_Amount <> 0 THEN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'Calling procedure Pay_Dist_Err_Chrg for errors bank amount';
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;

     --bug 5659368
     Pay_Dist_Err_Chrg
          ( p_xla_event_rec     => p_xla_event_rec
            ,p_pay_hist_rec     => l_pay_hist_rec
            ,p_distribute_mode  => 'BANK_ERROR'
            ,p_calling_sequence => l_curr_calling_sequence);

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'Procedure Pay_Dist_Err_Chrg for errors bank amount executed';
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;

  END IF;


  IF l_pay_hist_rec.Charges_Bank_Amount <> 0 THEN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'Calling procedure Pay_Dist_Err_Chrg for charges bank amount';
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;

     --bug 5659368
     Pay_Dist_Err_Chrg
          ( p_xla_event_rec     => p_xla_event_rec
            ,p_pay_hist_rec     => l_pay_hist_rec
            ,p_distribute_mode  => 'BANK_CHARGE'
            ,p_calling_sequence => l_curr_calling_sequence);

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'Procedure Pay_Dist_Err_Chrg for charges bank amount executed';
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;

  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Calling procedure Update_Gain_Loss_Ind for payments';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  Update_Gain_Loss_Ind
        (p_xla_event_rec,
         l_pay_hist_rec,
         l_curr_calling_sequence);

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Procedure Update_Gain_Loss_Ind executed';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
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


END Manual_Pay_Adj_Events;



-------------------------------------------------------------------------------
-- PROCEDURE Cancel_Primary_Pay_Events
-- The purpose of this procedure is to reverse the payment distributions
-- for the payment transactions that have been cancelled, uncleared or
-- unmatured and insert into the payment hist distribution table.
--
--------------------------------------------------------------------------------
PROCEDURE Cancel_Primary_Pay_Events
     (P_XLA_Event_Rec      IN   ap_accounting_pay_pkg.r_xla_event_info
     ,P_Calling_Sequence   IN   VARCHAR2
     ) IS

  l_curr_calling_sequence    VARCHAR2(2000);

  l_pay_hist_rec             ap_accounting_pay_pkg.r_pay_hist_info;

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Cancel_Primary_Pay_Events';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  l_curr_calling_sequence := 'AP_ACCTG_PAY_DIST_PKG.Cancel_Primary_Pay_Events<-' ||
                                           p_calling_sequence;

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;


  OPEN Payment_History(p_xla_event_rec.event_id);
  FETCH Payment_History INTO l_pay_hist_rec;
  CLOSE Payment_History;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'CUR: Payment_History: Payment_History_ID = '||
                                          l_pay_hist_rec.payment_history_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Calling procedure Pay_Dist_Reverse for related event: '
                            || l_pay_hist_rec.related_event_id;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;


  -- Create payment hist dists by reversing the original payment hist
  -- distributions
  Pay_Dist_Reverse
        (p_xla_event_rec,
         NULL,
         l_pay_hist_rec,
         NULL, -- reversal_inv_pmt_id,
         l_pay_hist_rec.related_event_id,
         NULL, -- invoice_dist_id
         NULL, -- inv_dist_rec
         l_curr_calling_sequence);

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Procedure Pay_Dist_Reverse executed';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Calling procedure Update_Gain_Loss_Ind for payments';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  Update_Gain_Loss_Ind
        (p_xla_event_rec,
         l_pay_hist_rec,
         l_curr_calling_sequence);

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Procedure Update_Gain_Loss_Ind executed';
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

END Cancel_Primary_Pay_Events;


-------------------------------------------------------------------------------
-- PROCEDURE  Pay_Dist_Cascade_Adj_Events
-- The purpose of this procedure is to prorate the payment amount for all the
-- distributions of the invoice that has been adjusted and generate the
-- payment history distribution.
--
--------------------------------------------------------------------------------
PROCEDURE Pay_Dist_Cascade_Adj_Events
     (P_XLA_Event_Rec      IN   ap_accounting_pay_pkg.r_xla_event_info
     ,P_Calling_Sequence   IN   VARCHAR2
     ) IS

  l_curr_calling_sequence    VARCHAR2(2000);
  l_event_id                 NUMBER;
  l_inv_adj_amount           NUMBER := 0;
  l_invoice_id               NUMBER;
  l_sum_paid_amount          NUMBER := 0;
  l_sum_disc_amount          NUMBER := 0;
  l_sum_error_amount         NUMBER := 0;
  l_sum_charge_amount        NUMBER := 0;
  l_pay_history_id           NUMBER;
  l_mat_history_id           NUMBER;

  l_inv_pay_rec            r_inv_pay_info;
  l_pay_hist_rec           ap_accounting_pay_pkg.r_pay_hist_info;
  l_inv_rec                ap_accounting_pay_pkg.r_invoices_info;
  l_inv_dist_rec           ap_accounting_pay_pkg.r_inv_dist_info;
  --Bug 8524600
  l_curr_pay_awt_tot         NUMBER :=0;
  l_inv_time_awt             NUMBER :=0;
  l_inv_time_dist_total      NUMBER :=0;
  l_inv_time_awt_tot         NUMBER :=0;
  --Bug 8524600
  l_pay_dist_cnt           NUMBER;
  l_do_round               NUMBER; --7454170 contains payment_history_id
  l_tech_round_amt    NUMBER; --9414219

  CURSOR Inv_Adj_Dists
        (P_Event_ID             NUMBER
        ,P_Invoice_ID           NUMBER
        ,P_Related_Event_ID     NUMBER) IS
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
         AID.historical_flag,   -- bug fix 6674279
         AID.accounting_event_id  -- bug fix 6674279
  FROM   AP_Invoice_Distributions_All AID,
         AP_Payment_History_All APH,
         AP_Payment_Hist_Dists APHD
  WHERE  AID.Invoice_ID = P_Invoice_ID
  AND    NVL(AID.Reversal_Flag,'N') <> 'Y'
  AND    AID.Invoice_Distribution_ID = APHD.Invoice_Distribution_ID
  AND    APH.Payment_History_ID = APHD.Payment_History_ID
  AND    APH.Related_Event_ID = P_Related_Event_ID
  AND    NVL(AID.Accounting_Event_ID,-99) <> P_Event_ID
  AND    APHD.Pay_Dist_Lookup_Code IN ('CASH', 'AWT');


  CURSOR Adj_Invoice_Payments
        (P_Check_ID     NUMBER
        ,P_Invoice_ID   NUMBER
        ) IS
  SELECT AIP.Invoice_ID,
         AIP.Invoice_Payment_ID,
         AIP.Amount,
         AIP.Discount_Taken,
         AIP.Payment_Base_Amount,
         AIP.Invoice_Base_Amount,
         AIP.Exchange_Rate_Type,
         AIP.Exchange_Date,
         AIP.Exchange_Rate,
         NVL(AIP.Reversal_Flag,'N'),
         AIP.Reversal_Inv_Pmt_ID
  FROM   AP_Invoice_Payments_All AIP
  WHERE  AIP.Check_ID = P_Check_ID
  AND    AIP.Invoice_ID = P_Invoice_ID
  AND    AIP.REVERSAL_INV_PMT_ID IS NULL;  --bug 9005225

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Pay_Dist_Cascade_Adj_Events';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;


BEGIN

  l_curr_calling_sequence := 'AP_Acctg_Pay_Dist_Pkg.Pay_Dist_Cascade_Adj_Events<- ' ||
                                      p_calling_sequence;

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;


  OPEN Payment_History(p_xla_event_rec.event_id);
  FETCH Payment_History INTO l_pay_hist_rec;
  CLOSE Payment_History;


  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'CUR: Payment_History: Payment_History_ID = '||
                                          l_pay_hist_rec.payment_history_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  /* We need payment hist information for the prior events in order
     to calculate the base amounts for the prior events using the
     exchange rate info from the payment hist table */

  IF (P_XLA_Event_Rec.Event_Type_Code IN ('PAYMENT MATURITY ADJUSTED')) THEN

      SELECT MAX(APH.Payment_History_ID)
      INTO   l_pay_history_id
      FROM   AP_Payment_History_All APH
      WHERE  APH.Check_ID = p_xla_event_rec.source_id_int_1
      AND    APH.Transaction_Type IN ('PAYMENT CREATED', 'REFUND RECORDED');

      SELECT APH.Pmt_To_Base_XRate_Type,
             APH.Pmt_To_Base_XRate_Date,
             APH.Pmt_To_Base_XRate
      INTO   ap_accounting_pay_pkg.g_pmt_to_base_xrate_type,
             ap_accounting_pay_pkg.g_pmt_to_base_xrate_date,
             ap_accounting_pay_pkg.g_pmt_to_base_xrate
      FROM   AP_Payment_History_All APH
      WHERE  APH.Payment_History_ID = l_pay_history_id;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Payment_History_ID for payment = '|| l_pay_history_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;


      ap_accounting_pay_pkg.g_pay_pmt_history_id := l_pay_history_id;

      ap_accounting_pay_pkg.g_mat_pmt_history_id := l_pay_hist_rec.payment_history_id;
      ap_accounting_pay_pkg.g_mat_to_base_xrate_type :=
                                l_pay_hist_rec.pmt_to_base_xrate_type;
      ap_accounting_pay_pkg.g_mat_to_base_xrate_date :=
                                l_pay_hist_rec.pmt_to_base_xrate_date;
      ap_accounting_pay_pkg.g_mat_to_base_xrate := l_pay_hist_rec.pmt_to_base_xrate;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Payment_History_ID for maturity = '||
                                    l_pay_hist_rec.payment_history_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;


  ELSIF (P_XLA_Event_Rec.Event_Type_Code IN ('PAYMENT CLEARING ADJUSTED')) THEN

      SELECT MAX(APH.Payment_History_ID)
      INTO   l_pay_history_id
      FROM   AP_Payment_History_All APH
      WHERE  APH.Check_ID = p_xla_event_rec.source_id_int_1
      AND    APH.Transaction_Type IN ('PAYMENT CREATED', 'REFUND RECORDED');

      SELECT APH.Pmt_To_Base_XRate_Type,
             APH.Pmt_To_Base_XRate_Date,
             APH.Pmt_To_Base_XRate
      INTO   ap_accounting_pay_pkg.g_pmt_to_base_xrate_type,
             ap_accounting_pay_pkg.g_pmt_to_base_xrate_date,
             ap_accounting_pay_pkg.g_pmt_to_base_xrate
      FROM   AP_Payment_History_All APH
      WHERE  APH.Payment_History_ID = l_pay_history_id;

      SELECT MAX(APH.Payment_History_ID)
      INTO   l_mat_history_id
      FROM   AP_Payment_History_All APH
      WHERE  APH.Check_ID = p_xla_event_rec.source_id_int_1
      AND    APH.Transaction_Type IN ('PAYMENT MATURITY');


      IF l_mat_history_id IS NOT NULL THEN

         SELECT APH.Pmt_To_Base_XRate_Type,
                APH.Pmt_To_Base_XRate_Date,
                APH.Pmt_To_Base_XRate
         INTO   ap_accounting_pay_pkg.g_mat_to_base_xrate_type,
                ap_accounting_pay_pkg.g_mat_to_base_xrate_date,
                ap_accounting_pay_pkg.g_mat_to_base_xrate
         FROM   AP_Payment_History_All APH
         WHERE  APH.Payment_History_ID = l_mat_history_id;

      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Payment_History_ID for payment = '|| l_pay_history_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Payment_History_ID for maturity = '|| l_mat_history_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;


      ap_accounting_pay_pkg.g_pay_pmt_history_id := l_pay_history_id;
      ap_accounting_pay_pkg.g_mat_pmt_history_id := l_mat_history_id;

      ap_accounting_pay_pkg.g_clr_pmt_history_id := l_pay_hist_rec.payment_history_id;
      ap_accounting_pay_pkg.g_clr_to_base_xrate_type :=
                                l_pay_hist_rec.pmt_to_base_xrate_type;
      ap_accounting_pay_pkg.g_clr_to_base_xrate_date :=
                                l_pay_hist_rec.pmt_to_base_xrate_date;
      ap_accounting_pay_pkg.g_clr_to_base_xrate := l_pay_hist_rec.pmt_to_base_xrate;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Payment_History_ID for clearing = '||
                                         l_pay_hist_rec.payment_history_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

  ELSE

      ap_accounting_pay_pkg.g_pay_pmt_history_id := l_pay_hist_rec.payment_history_id;
      ap_accounting_pay_pkg.g_pmt_to_base_xrate_type :=
                                l_pay_hist_rec.pmt_to_base_xrate_type;
      ap_accounting_pay_pkg.g_pmt_to_base_xrate_date :=
                                l_pay_hist_rec.pmt_to_base_xrate_date;
      ap_accounting_pay_pkg.g_pmt_to_base_xrate := l_pay_hist_rec.pmt_to_base_xrate;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Payment_History_ID for payment = '||
                                        l_pay_hist_rec.payment_history_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;


  END IF;


  SELECT AID.Invoice_ID
  INTO   l_invoice_id
  FROM   AP_Invoice_Distributions_All AID
  WHERE  AID.Accounting_Event_ID = l_pay_hist_rec.invoice_adjustment_event_id
  AND    Rownum = 1;

  OPEN Invoice_Header(l_invoice_id);
  FETCH Invoice_Header INTO l_inv_rec;
  CLOSE Invoice_Header;



  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'CUR: Invoice_Header: Invoice_ID= '|| l_inv_rec.invoice_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  /* Get the invoice payments that need to be adjusted */
  OPEN Adj_Invoice_Payments(p_xla_event_rec.source_id_int_1,
                            l_invoice_id);
  LOOP

       Fetch Adj_Invoice_Payments INTO l_inv_pay_rec;
       EXIT WHEN Adj_Invoice_Payments%NOTFOUND OR
                 Adj_Invoice_Payments%NOTFOUND IS NULL;


       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'CUR: Invoice_Payments: Invoice_ID = '||
                                   l_inv_pay_rec.invoice_id;
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       -- Perfomance Fix 7308385
       -- Bug 7636427 Start
      SELECT SUM(decode(aid.prepay_tax_parent_id, NULL, nvl(aid.amount, 0), 0)),
             SUM(decode(aid.line_type_lookup_code, 'AWT', 0, nvl(aid.amount, 0))),
 	     SUM(decode(aid.awt_invoice_payment_id, Null, nvl(aid.amount, 0),0)),
	     SUM(decode(aid.awt_invoice_payment_id, Null, 0,nvl(aid.amount, 0))),
	     SUM(decode(aid.line_type_lookup_code, 'AWT',decode(aid.awt_invoice_payment_id, Null, nvl(aid.amount, 0),0), 0))
        INTO G_Total_Dist_Amount,
	     G_Proration_Divisor,
	     l_inv_time_dist_total,
             l_curr_pay_awt_tot,
	     l_inv_time_awt_tot
        FROM ap_invoice_distributions_all aid
       WHERE aid.invoice_id = l_inv_pay_rec.invoice_id
         AND aid.line_type_lookup_code <> 'PREPAY'
         AND aid.prepay_distribution_id IS NULL
         AND (aid.awt_invoice_payment_id IS NULL    OR
              aid.awt_invoice_payment_id = l_inv_pay_rec.invoice_payment_id) -- bug fix: 6725866
         AND NOT EXISTS
              (SELECT 1 FROM xla_events
               WHERE event_id = aid.accounting_event_id
               AND application_id = 200
               AND event_type_code IN('INVOICE CANCELLED', 'PREPAYMENT CANCELLED',
                      'CREDIT MEMO CANCELLED', 'DEBIT MEMO CANCELLED'));

   -- Bug 8524600
        l_curr_pay_awt_tot:= nvl(l_curr_pay_awt_tot,0);
        l_inv_time_awt_tot:= nvl(l_inv_time_awt_tot,0);
        l_inv_time_dist_total:= nvl(l_inv_time_dist_total,0);

        if (l_inv_time_dist_total <> 0 ) then
		G_Pay_AWT_Total_Amt    := nvl(l_curr_pay_awt_tot,0)
			+ nvl( (l_inv_time_awt_tot
			/  l_inv_time_dist_total
			* (GL_Currency_API.Convert_Amount(
				l_inv_rec.payment_currency_code,
				l_inv_rec.invoice_currency_code,
				l_inv_rec.payment_cross_rate_date,
				'EMU FIXED',
				l_inv_pay_rec.amount)-l_curr_pay_awt_tot)),0);
	else
	    G_Pay_AWT_Total_Amt := nvl(l_curr_pay_awt_tot,0) + nvl(l_inv_time_awt_tot,0);
	end if;
	-- Bug 7636427 End
        -- Bug 8524600 End
       -- Get the new or reversed invoice dists
       OPEN Invoice_Dists(l_invoice_id,
                          l_pay_hist_rec.invoice_adjustment_event_id);
       LOOP

            FETCH Invoice_Dists INTO l_inv_dist_rec;
            EXIT WHEN Invoice_Dists%NOTFOUND OR
                      Invoice_Dists%NOTFOUND IS NULL;


            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                l_log_msg := 'CUR: Invoice_Dists: Invoice_Distribution_ID = '
                                ||l_inv_dist_rec.invoice_distribution_id
                                ||'Reversal_Flag = '||l_inv_dist_rec.reversal_flag;
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;

            -- Bug 7384943. Get the count of payment dists for the parent invoice dist
            l_pay_dist_cnt :=0; --7602927 Intialising
            IF l_inv_dist_rec.parent_reversal_id IS NOT NULL THEN

               SELECT count(*)
               INTO   l_pay_dist_cnt
               FROM   ap_payment_hist_dists
               WHERE  invoice_distribution_id = l_inv_dist_rec.parent_reversal_id;

            END IF;

            -- Bug 7384943. Call pay_dist_reverse only if there exists payment
            -- dists for the parent invoice dist otherwise create payment dists
            -- by calculating the prorated amounts

            IF l_inv_dist_rec.reversal_flag = 'Y' AND
               l_inv_dist_rec.parent_reversal_id IS NOT NULL AND -- Bug 7602927
               l_pay_dist_cnt > 0 THEN

               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   l_log_msg := 'Calling procedure Pay_Dist_Reverse for dist: '
                                     || l_inv_dist_rec.invoice_distribution_id;
                   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
               END IF;

               Pay_Dist_Reverse
                         (p_xla_event_rec,
                          NULL, -- inv_pay_rec
                          l_pay_hist_rec, -- pay_hist_rec
                          NULL, -- reversal_inv_pmt_id,
                          NULL, -- related_event_id,
                          l_inv_dist_rec.parent_reversal_id, -- invoice_dist_id
                          l_inv_dist_rec, -- Bug6887295
                          l_curr_calling_sequence);

               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   l_log_msg := 'Procedure Pay_Dist_Reverse executed';
                   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
               END IF;


            ELSE

               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   l_log_msg := 'Calling procedure Pay_Dist_Proc for dist: '
                                     || l_inv_dist_rec.invoice_distribution_id;
                   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
               END IF;


               -- Create awt distributions only when the awt is created during invoice time or
               -- if the awt is created during the payment time then only those awt distributions
               -- created during this payment
               IF (l_inv_dist_rec.awt_invoice_payment_id IS NULL) OR
                  (l_inv_dist_rec.awt_invoice_payment_id = l_inv_pay_rec.invoice_payment_id) THEN
                  Pay_Dist_Proc(p_xla_event_rec,
                                l_inv_pay_rec,
                                l_pay_hist_rec,
                                l_inv_rec,
                                l_inv_dist_rec,
                                'C',
                                NULL,
                                l_curr_calling_sequence);

               END IF;

               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   l_log_msg := 'Procedure Pay_Dist_Proc executed';
                   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
               END IF;


           END IF;

       END LOOP;
       CLOSE Invoice_Dists;


       SELECT SUM(AID.Amount)
       INTO   l_inv_adj_amount
       FROM   AP_Invoice_Distributions_All AID
       WHERE  AID.Accounting_Event_ID = l_pay_hist_rec.invoice_adjustment_event_id;


       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'l_inv_adj_amount = ' || l_inv_adj_amount;
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       /* Check if there is any change to the invoice liability. If there is
          a change then we need to adjust the payment hist distributions for the
          old invoice distributions */

/* uncommenting the code for bug 7560247.
   For partially paid invoices are adjusted, for the payment's
   adjustment events, the values are populating wrongly.
   Due to commenting the below code, it is inserting the data
   in payment hist dist only for the adjusted distributions and not for all
   the distributions. But it should do for all the distributions */

 --/*  commented the code for bug 7147610
 -- For the Payment Adjustments we are populating the
 -- Payment Hists Dists in the cursor loop Invoice_Dists
 -- This Inv_Adj_Dists is not required.
       IF l_inv_adj_amount <> 0 THEN

          OPEN Inv_Adj_Dists(l_pay_hist_rec.invoice_adjustment_event_id,
                             l_inv_rec.invoice_id,
                             l_pay_hist_rec.related_event_id);
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
                   l_log_msg := 'Calling procedure Pay_Dist_Proc for dist: '
                                     || l_inv_dist_rec.invoice_distribution_id;
                   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
               END IF;

               Pay_Dist_Proc(p_xla_event_rec,
                             l_inv_pay_rec,
                             l_pay_hist_rec,
                             l_inv_rec,
                             l_inv_dist_rec,
                             'C',
                             NULL,
                             l_curr_calling_sequence);

               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                   l_log_msg := 'Procedure Pay_Dist_Proc executed';
                   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
               END IF;


          END LOOP;
          CLOSE Inv_Adj_Dists;
       END IF;
  /* code changes end for the bug 7560247 */

    -- BUG 7454170 and BUG 7489271
    -- Calling rounding only once for all payment adjsument events
    -- for each invoice payment level.

    SELECT max(aph2.payment_history_id) into l_do_round
      FROM ap_payment_history_all aph1,
           ap_payment_history_all aph2
     WHERE aph1.payment_history_id = l_pay_hist_rec.payment_history_id
       AND aph2.check_id = aph1.check_id
       AND aph2.posted_flag <> 'Y'
	   AND aph1.posted_flag <> 'Y'
       AND aph1.transaction_type = aph2.transaction_type
       AND l_invoice_id = (SELECT invoice_id
                           FROM ap_invoice_distributions_all d
                           WHERE d.accounting_event_id = aph2.invoice_adjustment_event_id
                           AND rownum = 1);

    IF ( l_do_round = l_pay_hist_rec.payment_history_id ) Then


       SELECT SUM(DECODE(APHD.Pay_Dist_Lookup_Code, 'CASH', APHD.Amount, 0)),
              SUM(DECODE(APHD.Pay_Dist_Lookup_Code, 'DISCOUNT', APHD.Amount, 0)),
              SUM(DECODE(APHD.Pay_Dist_Lookup_Code, 'BANK ERROR', APHD.Amount, 0)),
              SUM(DECODE(APHD.Pay_Dist_Lookup_Code, 'BANK CHARGE', APHD.Amount, 0))
       INTO   l_sum_paid_amount,
              l_sum_disc_amount,
              l_sum_error_amount,
              l_sum_charge_amount
       FROM   AP_Payment_Hist_Dists APHD,
              AP_Invoice_Distributions_All AID,
              AP_Payment_History_All APH
       WHERE  APH.Related_Event_ID = l_pay_hist_rec.related_event_id
       AND    APHD.Invoice_Payment_ID = l_inv_pay_rec.invoice_payment_id
       AND    APH.Payment_History_ID = APHD.Payment_History_ID
       AND    APHD.Invoice_Distribution_ID = AID.Invoice_Distribution_ID
       AND    AID.Invoice_ID = l_invoice_id;


       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'Adjusting payment amount for technical rounding';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       --bug 9274621, if payment and clearing currencies are the same then bank_curr_amount should be technically
       --rounded as well, for clearing transactions
       --9414219 Added base amount columns for Technical rounding

       l_tech_round_amt := -NVL(l_sum_paid_amount, 0) + l_inv_pay_rec.amount;

       IF (P_XLA_Event_Rec.Event_Type_Code IN ('PAYMENT CLEARING ADJUSTED')
           AND l_pay_hist_rec.bank_currency_code = l_pay_hist_rec.pmt_currency_code) THEN

          UPDATE AP_Payment_Hist_Dists APD
          SET    APD.Amount = APD.amount + l_tech_round_amt,
                 APD.bank_curr_amount = APD.bank_curr_amount + l_tech_round_amt,
                 APD.Cleared_Base_Amount = Decode(l_pay_hist_rec.bank_currency_code,
                                                  ap_accounting_pay_pkg.g_base_currency_code,
                                                  APD.Cleared_Base_Amount + l_tech_round_amt,
                                                  APD.Cleared_Base_Amount),
                 APD.Paid_Base_Amount = Decode(l_pay_hist_rec.bank_currency_code,
                                               ap_accounting_pay_pkg.g_base_currency_code,
                                               APD.Paid_Base_Amount + l_tech_round_amt,
                                               APD.Paid_Base_Amount),
                 APD.Matured_Base_Amount = Decode(l_pay_hist_rec.bank_currency_code,
                                                  ap_accounting_pay_pkg.g_base_currency_code,
                                                  APD.Matured_Base_Amount + l_tech_round_amt,
                                                  APD.Matured_Base_Amount),
                 APD.Invoice_Dist_Base_Amount = Decode(l_pay_hist_rec.bank_currency_code,
                                                       ap_accounting_pay_pkg.g_base_currency_code,
                                                       Decode(l_pay_hist_rec.bank_currency_code,
                                                              l_inv_rec.invoice_currency_code,
                                                              APD.Matured_Base_Amount + l_tech_round_amt,
                                                              APD.Invoice_Dist_Base_Amount),
                                                       APD.Invoice_Dist_Base_Amount),
                 APD.Invoice_Dist_Amount = Decode(l_pay_hist_rec.bank_currency_code,
                                                  l_inv_rec.invoice_currency_code,
                       				  APD.Invoice_Dist_Amount + l_tech_round_amt,                                                                                                 APD.Invoice_Dist_Amount)
          WHERE  APD.Invoice_Distribution_ID =
             (SELECT MAX(APD1.Invoice_Distribution_ID)
              FROM   AP_Payment_Hist_Dists APD1
              WHERE  APD1.Accounting_Event_ID = p_xla_event_rec.event_id
              AND    APD1.Invoice_Payment_ID = l_inv_pay_rec.invoice_payment_id
              AND    APD1.Pay_Dist_Lookup_Code = 'CASH'
              AND    ABS(APD1.Amount) =
                    (SELECT MAX(APD2.Amount)
                     FROM   AP_Payment_Hist_Dists APD2
                     WHERE  APD2.Accounting_Event_ID = p_xla_event_rec.event_id
                     AND    APD2.Invoice_Payment_ID  = l_inv_pay_rec.invoice_payment_id
                     AND    APD2.Pay_Dist_Lookup_Code = 'CASH'))
          AND    APD.Pay_Dist_Lookup_Code = 'CASH'
          AND    APD.Invoice_Payment_ID = l_inv_pay_rec.invoice_payment_id
          AND    APD.Payment_History_ID = l_pay_hist_rec.payment_history_id
          AND    APD.Accounting_Event_ID = p_xla_event_rec.event_id;

       --bug 9218593, if payment is in ledger currency then technical rounding should be done
       -- for base currency columns as well
       --bug 9274621, inv_dist_base_amount should be rounded here if invoice is in base_currency
       ELSIF l_inv_rec.payment_currency_code = ap_accounting_pay_pkg.g_base_currency_code
          AND l_inv_rec.invoice_currency_code = ap_accounting_pay_pkg.g_base_currency_code THEN

          UPDATE AP_Payment_Hist_Dists APD
          SET    APD.Amount = APD.amount -  NVL(l_sum_paid_amount,0) + l_inv_pay_rec.amount,
                 APD.paid_base_amount = APD.paid_base_amount -  NVL(l_sum_paid_amount,0) + l_inv_pay_rec.amount,
                 APD.invoice_dist_amount = APD.invoice_dist_amount -  NVL(l_sum_paid_amount,0) + l_inv_pay_rec.amount,
                 APD.invoice_dist_base_amount = APD.invoice_dist_base_amount -  NVL(l_sum_paid_amount,0) + l_inv_pay_rec.amount
          WHERE  APD.Invoice_Distribution_ID =
             (SELECT MAX(APD1.Invoice_Distribution_ID)
              FROM   AP_Payment_Hist_Dists APD1
              WHERE  APD1.Accounting_Event_ID = p_xla_event_rec.event_id
              AND    APD1.Invoice_Payment_ID = l_inv_pay_rec.invoice_payment_id
              AND    APD1.Pay_Dist_Lookup_Code = 'CASH'
              AND    ABS(APD1.Amount) =
                    (SELECT MAX(APD2.Amount)
                     FROM   AP_Payment_Hist_Dists APD2
                     WHERE  APD2.Accounting_Event_ID = p_xla_event_rec.event_id
                     AND    APD2.Invoice_Payment_ID  = l_inv_pay_rec.invoice_payment_id
                     AND    APD2.Pay_Dist_Lookup_Code = 'CASH'))
          AND    APD.Pay_Dist_Lookup_Code = 'CASH'
          AND    APD.Invoice_Payment_ID = l_inv_pay_rec.invoice_payment_id
          AND    APD.Payment_History_ID = l_pay_hist_rec.payment_history_id
          AND    APD.Accounting_Event_ID = p_xla_event_rec.event_id;

       --Adjust the payment amount for technical rounding
       ELSE

          UPDATE AP_Payment_Hist_Dists APD
          SET    APD.Amount = APD.Amount -  NVL(l_sum_paid_amount,0) + l_inv_pay_rec.amount
          WHERE  APD.Invoice_Distribution_ID =
             (SELECT MAX(APD1.Invoice_Distribution_ID)
              FROM   AP_Payment_Hist_Dists APD1
              WHERE  APD1.Accounting_Event_ID = p_xla_event_rec.event_id
              AND    APD1.Invoice_Payment_ID = l_inv_pay_rec.invoice_payment_id
              AND    APD1.Pay_Dist_Lookup_Code = 'CASH'
              AND    ABS(APD1.Amount) =
                    (SELECT MAX(APD2.Amount)
                     FROM   AP_Payment_Hist_Dists APD2
                     WHERE  APD2.Accounting_Event_ID = p_xla_event_rec.event_id
                     AND    APD2.Invoice_Payment_ID  = l_inv_pay_rec.invoice_payment_id
                     AND    APD2.Pay_Dist_Lookup_Code = 'CASH'))
          AND    APD.Pay_Dist_Lookup_Code = 'CASH'
          AND    APD.Invoice_Payment_ID = l_inv_pay_rec.invoice_payment_id
          AND    APD.Payment_History_ID = l_pay_hist_rec.payment_history_id
          AND    APD.Accounting_Event_ID = p_xla_event_rec.event_id;
       END IF;

       IF (l_inv_pay_rec.discount_taken <> 0) THEN

           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'Adjusting discount amount for technical rounding';
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;


           /* Adjust the discount amount for technical rounding */
           UPDATE AP_Payment_Hist_Dists APD
           SET    APD.Amount = APD.Amount -  NVL(l_sum_disc_amount,0)
                                     + l_inv_pay_rec.discount_taken
           WHERE  APD.Invoice_Distribution_ID =
                 (SELECT MAX(APD1.Invoice_Distribution_ID)
                  FROM   AP_Payment_Hist_Dists APD1
                  WHERE  APD1.Accounting_Event_ID = p_xla_event_rec.event_id
                  AND    APD1.Invoice_Payment_ID = l_inv_pay_rec.invoice_payment_id
                  AND    APD1.Pay_Dist_Lookup_Code = 'DISCOUNT'
                  AND    ABS(APD1.Amount) =
                        (SELECT MAX(APD2.Amount)
                         FROM   AP_Payment_Hist_Dists APD2
                         WHERE  APD2.Accounting_Event_ID = p_xla_event_rec.event_id
                         AND    APD2.Invoice_Payment_ID = l_inv_pay_rec.invoice_payment_id
                         AND    APD2.Pay_Dist_Lookup_Code = 'DISCOUNT'))
          AND    APD.Pay_Dist_Lookup_Code = 'DISCOUNT'
          AND    APD.Invoice_Payment_ID = l_inv_pay_rec.invoice_payment_id
          AND    APD.Payment_History_ID = l_pay_hist_rec.payment_history_id
          AND    APD.Accounting_Event_ID = p_xla_event_rec.event_id;

       END IF;

       IF (l_pay_hist_rec.errors_bank_amount <> 0) THEN

           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'Adjusting errors bank amount for technical rounding';
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;


           /* Adjust the bank errors amount for technical rounding */
           UPDATE AP_Payment_Hist_Dists APD
           SET    APD.Amount = APD.Amount -  NVL(l_sum_error_amount,0)
                                     + l_pay_hist_rec.errors_bank_amount
           WHERE  APD.Invoice_Distribution_ID =
                 (SELECT MAX(APD1.Invoice_Distribution_ID)
                  FROM   AP_Payment_Hist_Dists APD1
                  WHERE  APD1.Accounting_Event_ID = p_xla_event_rec.event_id
                  AND    APD1.Invoice_Payment_ID = l_inv_pay_rec.invoice_payment_id
                  AND    APD1.Pay_Dist_Lookup_Code = 'BANK ERROR'
                  AND    ABS(APD1.Amount) =
                        (SELECT MAX(APD2.Amount)
                         FROM   AP_Payment_Hist_Dists APD2
                         WHERE  APD2.Accounting_Event_ID = p_xla_event_rec.event_id
                         AND    APD2.Invoice_Payment_ID = l_inv_pay_rec.invoice_payment_id
                         AND    APD2.Pay_Dist_Lookup_Code = 'BANK ERROR'))
          AND    APD.Pay_Dist_Lookup_Code = 'BANK ERROR'
          AND    APD.Invoice_Payment_ID = l_inv_pay_rec.invoice_payment_id
          AND    APD.Payment_History_ID = l_pay_hist_rec.payment_history_id
          AND    APD.Accounting_Event_ID = p_xla_event_rec.event_id;

       END IF;

       IF (l_pay_hist_rec.charges_bank_amount <> 0) THEN


           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'Adjusting charges bank amount for technical rounding';
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;

           /* Adjust the bank charges amount for technical rounding */
           UPDATE AP_Payment_Hist_Dists APD
           SET    APD.Amount = APD.Amount -  NVL(l_sum_charge_amount,0)
                                     + l_pay_hist_rec.charges_bank_amount
           WHERE  APD.Invoice_Distribution_ID =
                 (SELECT MAX(APD1.Invoice_Distribution_ID)
                  FROM   AP_Payment_Hist_Dists APD1
                  WHERE  APD1.Accounting_Event_ID = p_xla_event_rec.event_id
                  AND    APD1.Invoice_Payment_ID = l_inv_pay_rec.invoice_payment_id
                  AND    APD1.Pay_Dist_Lookup_Code = 'BANK CHARGE'
                  AND    ABS(APD1.Amount) =
                        (SELECT MAX(APD2.Amount)
                         FROM   AP_Payment_Hist_Dists APD2
                         WHERE  APD2.Accounting_Event_ID = p_xla_event_rec.event_id
                         AND    APD2.Invoice_Payment_ID = l_inv_pay_rec.invoice_payment_id
                         AND    APD2.Pay_Dist_Lookup_Code = 'BANK CHARGE'))
          AND    APD.Pay_Dist_Lookup_Code = 'BANK CHARGE'
          AND    APD.Invoice_Payment_ID = l_inv_pay_rec.invoice_payment_id
          AND    APD.Payment_History_ID = l_pay_hist_rec.payment_history_id
          AND    APD.Accounting_Event_ID = p_xla_event_rec.event_id;

       END IF;


       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'Calling procedure P_Acctg_Pay_Round_Pkg.Do_Rounding for Invoice_ID: '
                                    || l_inv_rec.invoice_id;
           FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
       END IF;

       -- Create total and final payment rounding lines
       AP_Acctg_Pay_Round_Pkg.Do_Rounding
                     (p_xla_event_rec,
                      l_pay_hist_rec,
                      NULL, -- clr hist rec
                      l_inv_rec,
                      l_inv_pay_rec,
                      NULL, -- prepay inv rec
                      NULL, -- prepay hist rec
                      NULL, -- prepay dist rec
                      l_curr_calling_sequence);

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'Procedure P_Acctg_Pay_Round_Pkg.Do_Rounding executed';
           FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
       END IF;
    END IF; --l_do_round = l_pay_hist_rec.payment_history_id 7489271

  END LOOP;
  CLOSE Adj_Invoice_Payments;


  IF l_pay_hist_rec.Errors_Bank_Amount <> 0 THEN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'Calling procedure Pay_Dist_Err_Chrg for errors bank amount';
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;

     --bug 5659368
     Pay_Dist_Err_Chrg
          ( p_xla_event_rec     => p_xla_event_rec
            ,p_pay_hist_rec     => l_pay_hist_rec
            ,p_distribute_mode  => 'BANK_ERROR'
            ,p_calling_sequence => l_curr_calling_sequence);

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'Procedure Pay_Dist_Err_Chrg for errors bank amount executed';
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;


  END IF;


  IF l_pay_hist_rec.Charges_Bank_Amount <> 0 THEN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'Calling procedure Pay_Dist_Err_Chrg for charges bank amount';
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;

     --bug 5659368
     Pay_Dist_Err_Chrg
          ( p_xla_event_rec     => p_xla_event_rec
            ,p_pay_hist_rec     => l_pay_hist_rec
            ,p_distribute_mode  => 'BANK_CHARGE'
            ,p_calling_sequence => l_curr_calling_sequence);

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'Procedure Pay_Dist_Err_Chrg for charges bank amount executed';
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;

  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Calling procedure Update_Gain_Loss_Ind for payments';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  Update_Gain_Loss_Ind
        (p_xla_event_rec,
         l_pay_hist_rec,
         l_curr_calling_sequence);

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Procedure Update_Gain_Loss_Ind executed';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
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

END Pay_Dist_Cascade_Adj_Events;

---------------------------------------------------------------------
-- Procedure Pay_Dist_Proc
-- This procedure prorates the payment amounts for each distribution
-- and inserts the calculated values into payment hist dists table
-- Also calculates discounts and ERV
---------------------------------------------------------------------

PROCEDURE Pay_Dist_Proc
      (p_xla_event_rec      IN    ap_accounting_pay_pkg.r_xla_event_info
      ,p_inv_pay_rec        IN    r_inv_pay_info
      ,p_pay_hist_rec       IN    ap_accounting_pay_pkg.r_pay_hist_info
      ,p_inv_rec            IN    ap_accounting_pay_pkg.r_invoices_info
      ,p_inv_dist_rec       IN    ap_accounting_pay_pkg.r_inv_dist_info
      ,p_calc_mode          IN    VARCHAR2
      ,p_final_payment      IN    BOOLEAN
      ,p_calling_sequence   IN    VARCHAR2
      ) IS


  l_curr_calling_sequence       VARCHAR2(2000);
  l_dist_amt_pay_curr           NUMBER;
  l_dist_amt_bank_curr          NUMBER;
  l_pay_amount_inv_curr         NUMBER;
  l_pay_amount_bank_curr        NUMBER;
  l_prorated_amount             NUMBER;
  l_prorated_base_amount        NUMBER;
  l_inv_dist_amount             NUMBER;
  l_bank_curr_amount            NUMBER;

  l_disc_pay_amount             NUMBER := 0;
  l_disc_dist_amount            NUMBER := 0;
  l_disc_bank_amount            NUMBER := 0;

  l_total_paid_amt              NUMBER;
  l_total_prepaid_amt           NUMBER;
  l_tot_paid_amt_inv_curr       NUMBER;
  l_tot_paid_amt_bank_curr      NUMBER;
  l_tot_prepaid_amt_pay_curr    NUMBER;
  l_tot_prepaid_amt_bank_curr   NUMBER;
  l_proration_divisor           NUMBER;
  l_total_dist_amount           NUMBER;

  l_qty_variance                NUMBER;
  l_base_qty_variance           NUMBER;
  l_amt_variance                NUMBER;
  l_base_amt_variance           NUMBER;

  l_pd_rec                      AP_PAYMENT_HIST_DISTS%ROWTYPE;

--Bug 9282465  start
  l_total_paid_base_amt         NUMBER;
  l_tot_paid_inv_base_amt       NUMBER;
  l_tot_paid_cleared_base_amt   NUMBER;
  l_total_prepaid_base_amt      NUMBER;
  l_total_prepaid_inv_base_amt  NUMBER;
  l_total_prepaid_clr_base_amt  NUMBER;
  l_inv_dist_base_amount        NUMBER;
  l_cleared_base_amount         NUMBER;
  l_paid_base_amount            NUMBER;
--Bug 9282465 end
  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Pay_Dist_Proc';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  l_curr_calling_sequence := 'AP_ACCTG_PAY_DIST_PKG.Pay_Dist_Proc<- ' ||
                                              p_calling_sequence;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;


  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Parameters: Invoice_ID = '|| p_inv_rec.invoice_id
                   ||'Invoice_Dist_ID = '|| p_inv_dist_rec.invoice_distribution_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

/* Performance Fix 7308385 starts
  -- Selecting the distribution amount including the AWT distributions for
  -- prorating the AWT distributions.
  SELECT SUM(NVL(AID.Amount,0))
  INTO   l_total_dist_amount
  FROM   AP_Invoice_Distributions_All AID
  WHERE  AID.Invoice_ID = p_inv_pay_rec.invoice_id
  AND    AID.Line_Type_Lookup_Code <> 'PREPAY'
  AND    AID.Prepay_Distribution_ID IS NULL
  AND    AID.Prepay_Tax_Parent_ID IS NULL  -- For tax dists created in R11.5
  AND   (AID.AWT_Invoice_Payment_ID IS NULL
  OR     AID.AWT_Invoice_Payment_ID = p_inv_pay_rec.invoice_payment_id)
  -- bug fix: 6725866
  AND    NOT EXISTS (SELECT 1
                       FROM   xla_events
                       WHERE  event_id = AID.accounting_event_id
                       AND    application_id = 200 -- bug7281412
                       AND    event_type_code IN ('INVOICE CANCELLED',
                                                  'PREPAYMENT CANCELLED',
                                                  'CREDIT MEMO CANCELLED',
                                                  'DEBIT MEMO CANCELLED'));
*/
  l_total_dist_amount := G_Total_Dist_Amount;
  -- Performance Fix 7308385 ends

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,
      'l_total_dist_amount: '||l_total_dist_amount||
      ' p_inv_pay_rec.invoice_payment_id: '||p_inv_pay_rec.invoice_payment_id);
  END IF;

  IF p_inv_dist_rec.Line_Type_Lookup_Code = 'AWT' THEN
    l_proration_divisor := l_total_dist_amount;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'p_inv_dist_rec.Line_Type_Lookup_Code = AWT' ||
                   'including AWT and l_proration_divisor =' || NVL(l_proration_divisor,0);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

  ELSE
    --bug6147546
    --l_proration_divisor := p_inv_rec.invoice_amount;
    -- Bug 6712649. Added Credit and debit memo cancelled. Also added the
    -- line_type not in 'PREPAY' and 'AWT'
/* Performance Fix 7308385 starts
    SELECT SUM(AID.amount)
    INTO   l_proration_divisor
    FROM   ap_invoice_distributions_all AID
    WHERE  AID.invoice_id = p_inv_rec.invoice_id
    AND    AID.Line_Type_Lookup_Code NOT IN ('PREPAY', 'AWT')
    AND    AID.Prepay_Distribution_ID IS NULL
    AND    NOT EXISTS (SELECT 1
                       FROM   xla_events
                       WHERE  event_id = AID.accounting_event_id
                       AND    application_id = 200 --bug 7281412
                       AND    event_type_code IN ('INVOICE CANCELLED',
                                                  'PREPAYMENT CANCELLED',
                                                  'CREDIT MEMO CANCELLED',
                                                  'DEBIT MEMO CANCELLED'));
*/
    l_proration_divisor := G_Proration_Divisor;
    -- Performance Fix 7308385 ends


    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'p_inv_dist_rec.Line_Type_Lookup_Code <> AWT' ||
                   'exclude AWT and l_proration_divisor =' || NVL(l_proration_divisor,0);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
  END IF;


  -- Converting the distribution amount into payment currency for
  -- cross currency invoices.
  IF (p_inv_rec.invoice_currency_code <> p_inv_rec.payment_currency_code) THEN

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'this is cross currency';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
      l_dist_amt_pay_curr := GL_Currency_API.Convert_Amount(
                                p_inv_rec.invoice_currency_code,
                                p_inv_rec.payment_currency_code,
                                p_inv_rec.payment_cross_rate_date,
                                'EMU FIXED',
                                p_inv_dist_rec.amount);

      l_pay_amount_inv_curr := GL_Currency_API.Convert_Amount(
                                p_inv_rec.payment_currency_code,
                                p_inv_rec.invoice_currency_code,
                                p_inv_rec.payment_cross_rate_date,
                                'EMU FIXED',
                                p_inv_pay_rec.amount);

  ELSE

     l_dist_amt_pay_curr := p_inv_dist_rec.amount;
     l_pay_amount_inv_curr := p_inv_pay_rec.amount;

  END IF;

  IF (p_xla_event_rec.event_type_code IN ('PAYMENT CLEARED',
                                          'PAYMENT CLEARING ADJUSTED')) THEN

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Calculating payment and dist amt in bank currency for event type:'
                       ||p_xla_event_rec.event_type_code;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;


      /* Converting the payment and distribution amount into bank currency */
      IF ( p_pay_hist_rec.pmt_currency_code <> p_pay_hist_rec.bank_currency_code
           AND p_pay_hist_rec.bank_currency_code is not NULL )  THEN

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := '1. payment currency code <> bank_currency_code and' ||
                         'p_pay_hist_rec.pmt_currency_code = ' || p_pay_hist_rec.pmt_currency_code ||
                         'p_pay_hist_rec.bank_currency_code = ' || p_pay_hist_rec.bank_currency_code ||
                         'p_inv_pay_rec.amount = ' || p_inv_pay_rec.amount ||
                         'l_dist_amt_pay_curr =' || l_dist_amt_pay_curr ||
                         'p_pay_hist_rec.pmt_to_base_xrate = ' || p_pay_hist_rec.pmt_to_base_xrate ||
                         'p_pay_hist_rec.bank_to_base_xrate' || p_pay_hist_rec.bank_to_base_xrate;
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;


         l_pay_amount_bank_curr := AP_Utilities_Pkg.AP_Round_Currency(
                                       p_inv_pay_rec.amount * p_pay_hist_rec.pmt_to_base_xrate
                                            /p_pay_hist_rec.bank_to_base_xrate,
                                       p_pay_hist_rec.bank_currency_code);

         l_dist_amt_bank_curr := AP_Utilities_Pkg.AP_Round_Currency(
                                      l_dist_amt_pay_curr *  p_pay_hist_rec.pmt_to_base_xrate
                                            /p_pay_hist_rec.bank_to_base_xrate,
                                      p_pay_hist_rec.bank_currency_code);

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'after calculation and' ||
                         'l_dist_amt_bank_curr = ' || l_dist_amt_bank_curr||
                         'l_pay_amount_bank_curr = ' || l_pay_amount_bank_curr;
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

      -- Added for bug fix 5694577
      ELSE  -- p_pay_hist_rec.pmt_currency_code = p_pay_hist_rec.bank_currency_code

           l_pay_amount_bank_curr := p_inv_pay_rec.amount;
           l_dist_amt_bank_curr := l_dist_amt_pay_curr;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,
                         'l_pay_amount_bank_curr = ' || l_pay_amount_bank_curr||
                         'l_dist_amt_bank_curr = ' || l_dist_amt_bank_curr);
         END IF;

      END IF;  -- end of checking  p_pay_hist_rec.pmt_currency_code <> p_pay_hist_rec.bank_currency_code

  ELSE

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'assign some bank related variables for other event type=>'
                       ||p_xla_event_rec.event_type_code;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

     l_pay_amount_bank_curr := p_inv_pay_rec.amount;
     l_dist_amt_bank_curr := l_dist_amt_pay_curr;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'payment currency code = bank currency code for event type '||
                         'l_dist_amt_bank_curr = ' || l_dist_amt_bank_curr||
                         'l_pay_amount_bank_curr = ' || l_pay_amount_bank_curr;
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

  END IF; -- end of check event type


  g_total_dist_amt := g_total_dist_amt + p_inv_dist_rec.amount;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_msg := 'this run  p_inv_dist_rec.amount = ' ||
                  p_inv_dist_rec.amount ||
                  'Up to now ->g_total_dist_amt = '||g_total_dist_amt;
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

  /* We should distribute the discount amount first so that during the final payment
     this discount amount is also considered for adjusting the distribution */
  IF p_inv_pay_rec.Discount_Taken <> 0 and
     p_inv_dist_rec.Line_Type_Lookup_Code <> 'AWT' THEN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'Calling procedure Pay_Dist_Discount for dist: '
                       || p_inv_dist_rec.invoice_distribution_id;
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;

     Pay_Dist_Discount
          (p_xla_event_rec,
           p_inv_pay_rec,
           p_pay_hist_rec,
           p_inv_rec,
           p_inv_dist_rec,
           p_calc_mode,
           l_disc_pay_amount,
           l_disc_dist_amount,
           l_disc_bank_amount,
           l_curr_calling_sequence);

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'Procedure Pay_Dist_Discount executed and ' ||
                      'p_disc_pay_amount =' || l_disc_pay_amount ||
                      'p_disc_dist_amount ='|| l_disc_dist_amount ||
                      'p_disc_bank_amount ='|| l_disc_bank_amount;

         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;
  END IF;

  IF (p_calc_mode IN ('P', 'M')) THEN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
       l_log_msg := 'calculation mode p_calc_mode =' || p_calc_mode ;
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;

      -- If this payment is a final payment for the invoice then we should make sure
      -- that the sum of payment distributions amount should be equal to the distribution
      -- total. This way the liability is fully relieved.

      IF p_final_payment = TRUE THEN

         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
             l_log_msg := 'This is a final payment and now calling AP_Accounting_Pay_Pkg.Get_Pay_Sum';
             FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
         END IF;

         AP_Accounting_Pay_Pkg.Get_Pay_Sum
                          (p_inv_dist_rec.invoice_distribution_id,
                           p_xla_event_rec.event_type_code,
                           l_total_paid_amt,
                           l_tot_paid_amt_inv_curr,
                           l_tot_paid_amt_bank_curr,
                           l_curr_calling_sequence);

         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
             l_log_msg := 'After Calling function AP_Accounting_Pay_Pkg.Get_Pay_Sum' ||
                          'l_total_paid_amt==' || nvl(l_total_paid_amt,0) ||
                          'l_tot_paid_amt_inv_curr=' || nvl(l_tot_paid_amt_inv_curr,0) ||
                          'l_tot_paid_amt_bank_curr =' || nvl(l_tot_paid_amt_bank_curr,0);
             FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
         END IF;

--Bug 9282465
         AP_Accounting_Pay_Pkg.Get_Pay_Base_Sum
                          (p_inv_dist_rec.invoice_distribution_id,
                           p_xla_event_rec.event_type_code,
                           l_total_paid_base_amt,
                           l_tot_paid_inv_base_amt,
                           l_tot_paid_cleared_base_amt,
                           l_curr_calling_sequence);

         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
             l_log_msg := 'After Calling function AP_Accounting_Pay_Pkg.Get_Pay_Base_Sum' ||
                          'l_total_paid_base_amt==' || nvl(l_total_paid_base_amt,0) ||
                          'l_tot_paid_inv_base_amt=' || nvl(l_tot_paid_inv_base_amt,0) ||
                          'l_tot_paid_cleared_base_amt =' || nvl(l_tot_paid_cleared_base_amt,0);
             FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
         END IF;

         l_total_prepaid_amt          := AP_Accounting_Pay_Pkg.Get_Prepay_Sum
                                             (p_inv_dist_rec.invoice_distribution_id,
                                             l_curr_calling_sequence);

         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'get pay sum and its amount = ' ||
                          l_total_paid_amt ||
                        'get prepay sum and its amount = '||
                          l_total_prepaid_amt;
           FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
         END IF;

--Bug 9282465
         AP_Accounting_Pay_Pkg.Get_Prepay_Base_Sum(
                           p_inv_dist_rec.invoice_distribution_id,
                           l_total_prepaid_base_amt,
                           l_total_prepaid_inv_base_amt,
                           l_total_prepaid_clr_base_amt,
                           l_curr_calling_sequence);

         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'get pay base sum and its amount = ' ||
                          l_total_paid_base_amt ||
                        'get prepay base sum and its amount = '||
                          l_total_prepaid_base_amt;
           FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
         END IF;

         -- Converting the distribution and prepaid amount into payment currency for
         -- cross currency invoices.
         IF (p_inv_rec.invoice_currency_code <> p_inv_rec.payment_currency_code) THEN

             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 l_log_msg := 'Converting prepaid amount into payment currency';
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

             l_tot_prepaid_amt_pay_curr := GL_Currency_API.Convert_Amount(
                                             p_inv_rec.invoice_currency_code,
                                             p_inv_rec.payment_currency_code,
                                             p_inv_rec.payment_cross_rate_date,
                                             'EMU FIXED',
                                             l_total_prepaid_amt);


         ELSE
            l_tot_prepaid_amt_pay_curr := l_total_prepaid_amt;
         END IF;

         IF (p_xla_event_rec.event_type_code IN ('PAYMENT CLEARED',
                                                 'PAYMENT CLEARING ADJUSTED')) THEN

             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 l_log_msg := 'Converting prepaid amount into bank currency';
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

             IF ( p_pay_hist_rec.pmt_currency_code <> p_pay_hist_rec.bank_currency_code
                 AND p_pay_hist_rec.bank_currency_code is not NULL )  THEN

                l_tot_prepaid_amt_bank_curr :=
                           AP_Utilities_Pkg.AP_Round_Currency(
                                l_tot_prepaid_amt_pay_curr * p_pay_hist_rec.pmt_to_base_xrate
                                        /p_pay_hist_rec.bank_to_base_xrate,
                                p_pay_hist_rec.bank_currency_code);

             ELSE

                l_tot_prepaid_amt_bank_curr := l_tot_prepaid_amt_pay_curr;
             END IF;
         END IF;


         /* If this payment is a final payment then we should make sure that the
            distributed payment amount equals the distribution amount. This way the
            the liability for the distribution is relieved completely */

         -- use NVL to make sure the following amt won't be NULL
         /*bug 8975671, removed l_disc_pay_amount from the equations below as the total paid amounts in all
           all currencies is inclusive of the discount amount in APHD*/

--Bug 9282465
         IF p_inv_dist_rec.line_type_lookup_code = 'AWT' THEN --bug9059910
            l_prorated_amount       := NVL(l_dist_amt_pay_curr, 0) + NVL(l_total_paid_amt, 0)
                                             - NVL(l_tot_prepaid_amt_pay_curr, 0);
            l_inv_dist_amount       := NVL(p_inv_dist_rec.amount, 0) + NVL(l_tot_paid_amt_inv_curr, 0)
                                             - NVL(l_total_prepaid_amt, 0);
            l_bank_curr_amount      := NVL(l_dist_amt_bank_curr, 0) + NVL(l_tot_paid_amt_bank_curr, 0)
                                             - NVL(l_tot_prepaid_amt_bank_curr, 0);

            l_inv_dist_base_amount  := NVL(p_inv_dist_rec.base_amount + NVL(l_tot_paid_inv_base_amt,0)
                                             - NVL(l_total_prepaid_inv_base_amt,0),l_inv_dist_amount);

            l_paid_base_amount      := nvl(l_inv_dist_base_amount * nvl(p_inv_rec.payment_cross_rate ,1)
                                           * nvl(p_pay_hist_rec.pmt_to_base_xrate,1) / nvl(p_inv_rec.exchange_rate,1),l_prorated_amount);

            --This logic needs to modify when we are getting issues.
            IF ( p_pay_hist_rec.pmt_currency_code = p_pay_hist_rec.bank_currency_code) THEN
                 l_cleared_base_amount   := l_paid_base_amount * nvl(p_pay_hist_rec.bank_to_base_xrate,1)
                                             /nvl(p_pay_hist_rec.pmt_to_base_xrate,1);
            ELSE
                 l_cleared_base_amount   := l_bank_curr_amount;
            END IF;

         ELSE
	   l_prorated_amount := NVL(l_dist_amt_pay_curr, 0) - NVL(l_total_paid_amt, 0)
                              + NVL(l_tot_prepaid_amt_pay_curr, 0);
            l_inv_dist_amount := NVL(p_inv_dist_rec.amount, 0) - NVL(l_tot_paid_amt_inv_curr, 0)
                              + NVL(l_total_prepaid_amt, 0);
            l_bank_curr_amount := NVL(l_dist_amt_bank_curr, 0) - NVL(l_tot_paid_amt_bank_curr, 0)
                              + NVL(l_tot_prepaid_amt_bank_curr, 0);
         END IF;

         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'Value for l_prorated_amount = ' || l_prorated_amount ||
                        'Value for l_inv_dist_amount = ' || l_inv_dist_amount ||
                        'Value for l_bank_curr_amount =' || l_bank_curr_amount;

           FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
         END IF;

      ELSE

         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'this is NOT a final payment';
           FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
         END IF;

       IF ((g_total_dist_amt = l_total_dist_amount) AND
           NOT (((g_proration_divisor + g_pay_awt_total_amt) = 0)
              AND (l_pay_amount_inv_curr = 0)
              AND (p_inv_dist_rec.line_type_lookup_code ='AWT'))) THEN --Bug 9078285

            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
              l_log_msg := 'g_total_dist_amt equal l_total_dist_amount =' ||
                            l_total_dist_amount;
              FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
            END IF;

            -- To avoid rounding, massage the last (biggest) line
            l_prorated_amount := p_inv_pay_rec.amount - g_total_prorated_amt;
            l_inv_dist_amount := l_pay_amount_inv_curr - g_total_inv_dist_amt;
            -- bug 5638490
            l_bank_curr_amount := l_pay_amount_bank_curr - g_total_bank_curr_amt;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                l_log_msg := 'Value for l_prorated_amount = ' || l_prorated_amount ||
                             'Value for l_inv_dist_amoun = ' || l_inv_dist_amount ||
                             'l_bank_curr_amount = ' || l_bank_curr_amount;
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;


         ELSE

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                l_log_msg := 'This is not the last invoice distribution for proration';
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;

             IF ( NVL(G_Proration_Divisor,0) = 0 )THEN  -- Bug 7636427
               l_prorated_amount := 0;
               l_inv_dist_amount := 0;
               l_bank_curr_amount := 0;

            ELSE

               IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 l_log_msg := 'l_proration_divisor is not 0 it is =>'
                              || l_proration_divisor;
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
               END IF;

               -- We do not need to prorate the AWT amounts for the AWT distributions
               -- that are created during payment time

               IF p_inv_dist_rec.awt_invoice_payment_id IS NOT NULL THEN

                  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   l_log_msg := 'AWT at payment time and should not prorate to awt pmt distribution';
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                 END IF;
--Bug 9282465
                  l_inv_dist_base_amount  := p_inv_dist_rec.base_amount;

                  l_paid_base_amount      := nvl(p_inv_dist_rec.base_amount,p_inv_dist_rec.amount)
                                                  * nvl(p_inv_rec.payment_cross_rate ,1)
                                                  * nvl(p_pay_hist_rec.pmt_to_base_xrate,1)
                                                  / nvl(p_inv_rec.exchange_rate,1);
                  l_prorated_amount := GL_Currency_API.Convert_Amount(
                                             p_inv_rec.invoice_currency_code,
                                             p_inv_rec.payment_currency_code,
                                             p_inv_rec.payment_cross_rate_date,
                                             'EMU FIXED',
                                             p_inv_dist_rec.amount);

                  l_inv_dist_amount := p_inv_dist_rec.amount;

                  IF (  p_pay_hist_rec.pmt_currency_code <> p_pay_hist_rec.bank_currency_code
                        AND p_pay_hist_rec.bank_currency_code IS NOT NULL )  THEN
--Bug 9282465
                    l_bank_curr_amount      := AP_Utilities_Pkg.AP_Round_Currency(
                                                  l_prorated_amount * p_pay_hist_rec.pmt_to_base_xrate
                                                  /p_pay_hist_rec.bank_to_base_xrate,
                                                  p_pay_hist_rec.bank_currency_code);
                    l_cleared_base_amount   :=  l_paid_base_amount
                                                  * nvl(p_pay_hist_rec.bank_to_base_xrate,1)
                                                  /nvl(p_pay_hist_rec.pmt_to_base_xrate,1);
                  ELSE
--Bug 9282465
                    l_bank_curr_amount      := l_prorated_amount;
                    l_cleared_base_amount   := l_bank_curr_amount;
                  END IF;

                  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   l_log_msg := 'AWT at payment time and ' ||
                                ' l_prorated_amount = ' || l_prorated_amount ||
                                'l_bank_curr_amount = ' || l_bank_curr_amount;
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                  END IF;

               ELSE

-- Bug 7636427 Start
                 /* We need to calculate the payment amount and invoice dist amount
                    seperately to avoid rounding when calculating the base amounts */

/*
                 l_prorated_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY
                                        (p_inv_pay_rec.amount * p_inv_dist_rec.amount
                                               / l_proration_divisor,
                                         p_pay_hist_rec.pmt_currency_code);

                 l_inv_dist_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY
                                        (l_pay_amount_inv_curr * p_inv_dist_rec.amount
                                               / l_proration_divisor,
                                         p_inv_rec.invoice_currency_code);

*/                 -- bug 5638490
-- Bug 8524600 Start
-- Bug 9282465
                    IF p_inv_dist_rec.line_type_lookup_code ='AWT' AND p_inv_dist_rec.base_amount IS NOT NULL THEN

                       l_inv_dist_base_amount  := p_inv_dist_rec.base_amount
                                                      / g_proration_divisor
                                                      * ( l_pay_amount_inv_curr- g_pay_awt_total_amt);
                       l_inv_dist_amount       :=  l_inv_dist_base_amount / nvl(p_inv_rec.exchange_rate,1);

                       l_paid_base_amount      := nvl(l_inv_dist_base_amount,l_inv_dist_amount)
                                                      * nvl(p_inv_rec.payment_cross_rate ,1)
                                                      * nvl(p_pay_hist_rec.pmt_to_base_xrate,1)
                                                      / nvl(p_inv_rec.exchange_rate,1);

                              IF ( p_pay_hist_rec.pmt_currency_code = p_pay_hist_rec.bank_currency_code) THEN
                                   l_cleared_base_amount   :=  l_paid_base_amount
                                                               * nvl(p_pay_hist_rec.bank_to_base_xrate,1)
                                                               /nvl(p_pay_hist_rec.pmt_to_base_xrate,1);
                              ELSE
                                   l_cleared_base_amount   := l_bank_curr_amount;
                              END IF;
                    ELSE
                             SELECT
                                  (p_inv_dist_rec.amount
                                    / g_proration_divisor
                                    * ( l_pay_amount_inv_curr
                                        - g_pay_awt_total_amt
                                      )
                                    + nvl
                                      (
                                          (SELECT sum(amount)
                                             FROM ap_invoice_distributions_all aid
                                            WHERE aid.invoice_id                 =p_inv_pay_rec.invoice_id
                                              AND aid.awt_invoice_payment_id     =p_inv_pay_rec.invoice_payment_id
                                              AND aid.line_type_lookup_code      ='AWT'
                                              AND aid.awt_related_id             =p_inv_dist_rec.invoice_distribution_id
                                          )
                                          ,0
                                      )
                                    + nvl
                                      (
                                          (SELECT  sum(amount) / g_proration_divisor *  (l_pay_amount_inv_curr - g_pay_awt_total_amt)
                                             FROM ap_invoice_distributions_all aid
                                            WHERE aid.invoice_id                 =p_inv_pay_rec.invoice_id
                                              AND aid.line_type_lookup_code      ='AWT'
                                              AND awt_invoice_payment_id         is null
                                              AND awt_related_id                 =p_inv_dist_rec.invoice_distribution_id
                                          )
                                          ,0
                                      )
                                  )
                                INTO l_inv_dist_amount
                             FROM sys.dual;

                  END IF; -- IF AWT created at invoice time
                    l_prorated_amount     := GL_Currency_API.Convert_Amount(
                                                         p_inv_rec.invoice_currency_code
                                                        ,p_inv_rec.payment_currency_code
                                                        ,p_inv_rec.payment_cross_rate_date
                                                        ,'EMU FIXED'
                                                        ,l_inv_dist_amount);

                    l_prorated_amount     := AP_UTILITIES_PKG.AP_ROUND_CURRENCY (
                                                         l_prorated_amount
                                                        ,p_pay_hist_rec.pmt_currency_code);

                    l_inv_dist_amount     := AP_UTILITIES_PKG.AP_ROUND_CURRENCY (
                                                         l_inv_dist_amount
                                                        ,p_inv_rec.invoice_currency_code);


                  IF (  p_pay_hist_rec.pmt_currency_code <> p_pay_hist_rec.bank_currency_code
                        and p_pay_hist_rec.bank_currency_code is not null )  THEN

                     l_bank_curr_amount   := AP_Utilities_Pkg.AP_Round_Currency(
                                                        l_prorated_amount
                                                             * nvl(p_pay_hist_rec.pmt_to_base_xrate,1)
                                                             / nvl(p_pay_hist_rec.bank_to_base_xrate,1)
                                                        ,p_pay_hist_rec.bank_currency_code);
-- Bug 8524600 End
                 ELSE
			l_bank_curr_amount := l_prorated_amount;
                 END IF;

               END IF; -- If AWT created at payment time

               IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   l_log_msg := 'Value for l_prorated_amount = ' || l_prorated_amount;
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
               END IF;


            END IF;

         END IF;
      END IF;  -- If final payment


      -- We should not include the AWT prorated amount int the total prorated amt used
      -- for the technical proration rounding
      IF p_inv_dist_rec.line_type_lookup_code <> 'AWT' THEN
         g_total_prorated_amt := g_total_prorated_amt + l_prorated_amount;
         g_total_inv_dist_amt := g_total_inv_dist_amt + l_inv_dist_amount;
         g_total_bank_curr_amt := g_total_bank_curr_amt + l_bank_curr_amount;
      END IF;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'After final payment check/process and' ||
                     'g_total_prorated_amt = ' || nvl(g_total_prorated_amt,0) ||
                     'g_total_inv_dist_amt = ' || nvl(g_total_inv_dist_amt,0) ||
                     'g_total_bank_curr_amt = ' ||nvl(g_total_bank_curr_amt,0);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;


  /* If this is a cascade event then we will create new payment distributions
     for the existing invoice distributions that have already been distributed to
     this payment in order to adjust the payments as a result of adjusting the
     invoice */
  ELSE

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
       l_log_msg := 'calculation mode p_calc_mode (cascade?) =' || p_calc_mode ;
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
    END IF;

      IF NVL(l_proration_divisor, 0) = 0 THEN
         l_prorated_amount := 0;
         l_inv_dist_amount := 0;
         l_bank_curr_amount := 0;

      ELSE

        -- We do not need to prorate the AWT amounts for the AWT distributions
        -- that are created during payment time
        IF p_inv_dist_rec.awt_invoice_payment_id IS NOT NULL THEN

           l_prorated_amount := GL_Currency_API.Convert_Amount(
                                             p_inv_rec.invoice_currency_code,
                                             p_inv_rec.payment_currency_code,
                                             p_inv_rec.payment_cross_rate_date,
                                             'EMU FIXED',
                                             p_inv_dist_rec.amount) -
                                  AP_Accounting_Pay_Pkg.get_casc_pay_sum
                                            (p_inv_dist_rec.invoice_distribution_id,
                                             p_pay_hist_rec.related_event_id,
                                             p_inv_pay_rec.invoice_payment_id,
                                             l_curr_calling_sequence);

           l_inv_dist_amount := p_inv_dist_rec.amount -
                                  AP_Accounting_Pay_Pkg.get_casc_inv_dist_sum
                                           (p_inv_dist_rec.invoice_distribution_id,
                                            p_pay_hist_rec.related_event_id,
                                            p_inv_pay_rec.invoice_payment_id,
                                            l_curr_calling_sequence);

           IF ( p_pay_hist_rec.pmt_currency_code <> p_pay_hist_rec.bank_currency_code and
                p_pay_hist_rec.bank_currency_code is not NULL ) THEN

                     l_bank_curr_amount := AP_Utilities_Pkg.AP_Round_Currency(
                                              l_prorated_amount * p_pay_hist_rec.pmt_to_base_xrate
                                                     /p_pay_hist_rec.bank_to_base_xrate,
                                              p_pay_hist_rec.bank_currency_code) -
                                           AP_Accounting_Pay_Pkg.get_casc_bank_curr_sum(
                                              p_inv_dist_rec.invoice_distribution_id,
                                              p_pay_hist_rec.related_event_id,
                                              p_inv_pay_rec.invoice_payment_id,
                                              l_curr_calling_sequence);

           ELSE

                    l_bank_curr_amount := l_prorated_amount -
                                           AP_Accounting_Pay_Pkg.get_casc_bank_curr_sum(
                                              p_inv_dist_rec.invoice_distribution_id,
                                              p_pay_hist_rec.related_event_id,
                                              p_inv_pay_rec.invoice_payment_id,
                                              l_curr_calling_sequence);

           END IF;

         ELSE

           -- In case of cascade events we will recalculate the prorated amount and subtract
           -- this amount from the already calculated amount previously so that this would
           -- give us the amount that needs to be adjusted
           l_prorated_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY
                                  (((p_inv_dist_rec.amount * p_inv_pay_rec.amount)
                                         / l_proration_divisor)
                                      - AP_Accounting_Pay_Pkg.get_casc_pay_sum
                                           (p_inv_dist_rec.invoice_distribution_id,
                                            p_pay_hist_rec.related_event_id,
                                            p_inv_pay_rec.invoice_payment_id,
                                            l_curr_calling_sequence),
                                     p_pay_hist_rec.pmt_currency_code);

           l_inv_dist_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY
                                  (((p_inv_dist_rec.amount * l_pay_amount_inv_curr)
                                         / l_proration_divisor)
                                      - AP_Accounting_Pay_Pkg.get_casc_inv_dist_sum
                                           (p_inv_dist_rec.invoice_distribution_id,
                                            p_pay_hist_rec.related_event_id,
                                            p_inv_pay_rec.invoice_payment_id,
                                            l_curr_calling_sequence),
                                     p_inv_rec.invoice_currency_code);

           IF ( p_pay_hist_rec.bank_currency_code is not NULL ) THEN

             l_bank_curr_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY
                                  (((p_inv_dist_rec.amount * l_pay_amount_bank_curr)
                                         / l_proration_divisor)
                                      - AP_Accounting_Pay_Pkg.get_casc_bank_curr_sum
                                           (p_inv_dist_rec.invoice_distribution_id,
                                            p_pay_hist_rec.related_event_id,
                                            p_inv_pay_rec.invoice_payment_id,
                                            l_curr_calling_sequence),
                                    p_pay_hist_rec.bank_currency_code);
           END IF;

        END IF; -- If AWT created at payment time

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'Value for l_prorated_amount = ' || l_prorated_amount;
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

      END IF;
  END IF;  -- If calc_mode in ('P','M')

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
       l_log_msg := 'Now calling AP_Accounting_Pay_Pkg.Get_Base_Amount before insert';
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  l_prorated_base_amount := AP_Accounting_Pay_Pkg.Get_Base_Amount
                                   (l_prorated_amount,
                                    p_pay_hist_rec.pmt_currency_code,
                                    ap_accounting_pay_pkg.g_base_currency_code,
                                    p_pay_hist_rec.pmt_to_base_xrate_type,
                                    p_pay_hist_rec.pmt_to_base_xrate_date,
                                    p_pay_hist_rec.pmt_to_base_xrate,
                                    l_curr_calling_sequence);

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'after call AP_Accounting_Pay_Pkg.Get_Base_Amoun and ' ||
                 'l_prorated_base_amount=' || nvl(l_prorated_base_amount,0) ||
                 'l_prorated_amount= ' || nvl(l_prorated_amount,0);
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  -- populate the payment distribution record

  l_pd_rec.accounting_event_id := p_xla_event_rec.event_id;
  l_pd_rec.invoice_distribution_id := p_inv_dist_rec.invoice_distribution_id;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'Start to populate the l_pd_rec for event id' ||
                  l_pd_rec.accounting_event_id;
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

--Bug 9282465
  IF p_inv_dist_rec.line_type_lookup_code = 'AWT' THEN
     l_pd_rec.pay_dist_lookup_code  := 'AWT';
     l_pd_rec.awt_related_id        := p_inv_dist_rec.awt_related_id;
     l_prorated_base_amount         := nvl(l_paid_base_amount
                                      ,nvl(l_inv_dist_base_amount
                                             * p_pay_hist_rec.pmt_to_base_xrate
                                             / p_inv_rec.exchange_rate
                                      ,l_prorated_amount));
     l_inv_dist_base_amount         := -1 * l_inv_dist_base_amount;
     l_prorated_amount              := -1 * l_prorated_amount;
     l_prorated_base_amount         := -1 * ap_utilities_pkg.ap_round_currency
                                      (l_prorated_base_amount,ap_accounting_pay_pkg.g_base_currency_code);
     l_inv_dist_amount              := -1 * l_inv_dist_amount;
     l_bank_curr_amount             := -1 * l_bank_curr_amount;
  ELSE
     l_pd_rec.pay_dist_lookup_code := 'CASH';
  END IF;

  l_pd_rec.amount := l_prorated_amount;
  l_pd_rec.payment_history_id := p_pay_hist_rec.payment_history_id;
  l_pd_rec.invoice_payment_id := p_inv_pay_rec.invoice_payment_id;

  l_pd_rec.bank_curr_amount := l_bank_curr_amount;

  IF p_xla_event_rec.event_type_code IN
         ('PAYMENT CLEARED', 'PAYMENT CLEARING ADJUSTED') THEN
--Bug 9282465
         IF (p_inv_dist_rec.line_type_lookup_code = 'AWT' AND l_cleared_base_amount is not null) THEN
         l_pd_rec.cleared_base_amount := ap_utilities_pkg.ap_round_currency
                                         (l_cleared_base_amount,ap_accounting_pay_pkg.g_base_currency_code);
         ELSE

         l_pd_rec.cleared_base_amount := AP_Accounting_Pay_Pkg.Get_Base_Amount
                                      (l_bank_curr_amount,
                                       p_pay_hist_rec.bank_currency_code,
                                       ap_accounting_pay_pkg.g_base_currency_code,
                                       p_pay_hist_rec.bank_to_base_xrate_type,
                                       p_pay_hist_rec.bank_to_base_xrate_date,
                                       p_pay_hist_rec.bank_to_base_xrate,
                                       l_curr_calling_sequence);
         END IF;

--Bug 9282465
         IF (p_inv_dist_rec.line_type_lookup_code = 'AWT' AND (l_inv_dist_base_amount is not null or l_inv_dist_amount is not null) ) THEN
         l_pd_rec.paid_base_amount :=ap_utilities_pkg.ap_round_currency
                                     ( nvl(l_inv_dist_base_amount,l_inv_dist_amount)
                                             * nvl(p_inv_rec.payment_cross_rate ,1)
                                             * nvl(ap_accounting_pay_pkg.g_pmt_to_base_xrate,1)
                                             / nvl(p_inv_rec.exchange_rate,1),ap_accounting_pay_pkg.g_base_currency_code);
         ELSE

         l_pd_rec.paid_base_amount := AP_Accounting_Pay_Pkg.Get_Base_Amount
                                      (l_prorated_amount,
                                       p_pay_hist_rec.pmt_currency_code,
                                       ap_accounting_pay_pkg.g_base_currency_code,
                                       ap_accounting_pay_pkg.g_pmt_to_base_xrate_type,
                                       ap_accounting_pay_pkg.g_pmt_to_base_xrate_date,
                                       ap_accounting_pay_pkg.g_pmt_to_base_xrate,
                                       l_curr_calling_sequence);
         END IF;

     IF ap_accounting_pay_pkg.g_mat_to_base_xrate IS NOT NULL THEN

        l_pd_rec.matured_base_amount := AP_Accounting_Pay_Pkg.Get_Base_Amount
                                          (l_prorated_amount,
                                           p_pay_hist_rec.pmt_currency_code,
                                           ap_accounting_pay_pkg.g_base_currency_code,
                                           ap_accounting_pay_pkg.g_mat_to_base_xrate_type,
                                           ap_accounting_pay_pkg.g_mat_to_base_xrate_date,
                                           ap_accounting_pay_pkg.g_mat_to_base_xrate,
                                           l_curr_calling_sequence);
     END IF ;

  ELSIF p_xla_event_rec.event_type_code IN
                  ('PAYMENT MATURED', 'PAYMENT MATURITY ADJUSTED') THEN
     l_pd_rec.matured_base_amount := l_prorated_base_amount;

     l_pd_rec.paid_base_amount := AP_Accounting_Pay_Pkg.Get_Base_Amount
                                      (l_prorated_amount,
                                       p_pay_hist_rec.pmt_currency_code,
                                       ap_accounting_pay_pkg.g_base_currency_code,
                                       ap_accounting_pay_pkg.g_pmt_to_base_xrate_type,
                                       ap_accounting_pay_pkg.g_pmt_to_base_xrate_date,
                                       ap_accounting_pay_pkg.g_pmt_to_base_xrate,
                                       l_curr_calling_sequence);

  ELSE
     l_pd_rec.paid_base_amount := l_prorated_base_amount;
  END IF;

  l_pd_rec.invoice_dist_amount := l_inv_dist_amount;


  /* If the exchange rates between the invoice and payment have not changed then
     the invoice and payment base amounts should be the same. Assigning the
     payment base amount to the invoice base amount instead of recalculating the
     invoice base amount */
         IF (p_inv_dist_rec.line_type_lookup_code = 'AWT' AND l_cleared_base_amount is not null) THEN
              l_pd_rec.invoice_dist_base_amount:=l_inv_dist_base_amount;
         ELSE

           IF (p_pay_hist_rec.pmt_to_base_xrate =
                        p_inv_rec.exchange_rate / p_inv_rec.payment_cross_rate) THEN

               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                 l_log_msg := 'pmt to base rate = inv to base rate';
                 FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
               END IF;

               l_pd_rec.invoice_dist_base_amount := l_prorated_base_amount;

           ELSE

               l_pd_rec.invoice_dist_base_amount :=
                                             AP_Accounting_Pay_Pkg.Get_Base_Amount
                                                  (l_inv_dist_amount,
                                                   p_inv_rec.invoice_currency_code,
                                                   ap_accounting_pay_pkg.g_base_currency_code,
                                                   p_inv_rec.exchange_rate_type,
                                                   p_inv_rec.exchange_date,
                                                   p_inv_rec.exchange_rate,
                                                   l_curr_calling_sequence);

               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                 l_log_msg := 'pmt to base rate <> inv to base rate and ' ||
                              'l_pd_rec.invoice_dist_base_amount =' ||
                              nvl(l_pd_rec.invoice_dist_base_amount,0) ||
                              'l_prorated_base_amount =' || nvl(l_prorated_base_amount,0);
                 FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
               END IF;

           END IF;
END IF;

  IF p_inv_dist_rec.quantity_variance IS NOT NULL THEN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'Invoice has quantity variance';
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;

     IF p_inv_dist_rec.amount = 0 THEN
        l_qty_variance := 0;
     ELSE
        l_qty_variance := AP_Utilities_PKG.AP_Round_Currency(
                          ((p_inv_dist_rec.quantity_variance * l_inv_dist_amount) /
                                  p_inv_dist_rec.amount),
                            p_inv_rec.invoice_currency_code);
     END IF;

     IF p_inv_dist_rec.base_amount = 0 THEN
        l_base_qty_variance := 0;
     ELSE
        l_base_qty_variance := AP_Utilities_PKG.AP_Round_Currency(
                               ((p_inv_dist_rec.base_quantity_variance
                                    * l_pd_rec.invoice_dist_base_amount)
                                    / p_inv_dist_rec.base_amount),
                                 ap_accounting_pay_pkg.g_base_currency_code);
     END IF;
  END IF;

  IF p_inv_dist_rec.amount_variance IS NOT NULL THEN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'Invoice has amount variance';
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     END IF;

     IF p_inv_dist_rec.amount = 0 THEN
        l_amt_variance := 0;
     ELSE
        l_amt_variance := AP_Utilities_PKG.AP_Round_Currency(
                          ((p_inv_dist_rec.amount_variance * l_inv_dist_amount) /
                                  p_inv_dist_rec.amount),
                            p_inv_rec.invoice_currency_code);
     END IF;

     IF p_inv_dist_rec.base_amount = 0 THEN
        l_base_amt_variance := 0;
     ELSE
        l_base_amt_variance := AP_Utilities_PKG.AP_Round_Currency(
                               ((p_inv_dist_rec.base_amount_variance
                                    * l_pd_rec.invoice_dist_base_amount)
                                    / p_inv_dist_rec.base_amount),
                                 ap_accounting_pay_pkg.g_base_currency_code);
     END IF;
  END IF;

  l_pd_rec.quantity_variance := l_qty_variance;
  l_pd_rec.invoice_base_qty_variance := l_base_qty_variance;
  l_pd_rec.amount_variance := l_amt_variance;
  l_pd_rec.invoice_base_amt_variance := l_base_amt_variance;


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Calling procedure Pay_Dist_Insert';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;


  -- Insert the payment hist distribution

  Pay_Dist_Insert
          (l_pd_rec,
           l_curr_calling_sequence);

 --bug7446229
IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Procedure Pay_Dist_Insert executed';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;


  IF ((p_xla_event_rec.event_type_code NOT IN
             ('PAYMENT MATURED', 'PAYMENT MATURITY ADJUSTED')) AND
      (p_inv_rec.payment_currency_code <> ap_accounting_pay_pkg.g_base_currency_code) AND
       p_inv_dist_rec.po_distribution_id IS NOT NULL AND
       p_inv_dist_rec.line_type_lookup_code <> 'AWT') THEN

       -----------------------------------------------------------------------------
       -- Bug 5570002
       -- The ERV/TERV calculated did not consider the discount portion as part
       -- of this payment, this will make a difference between the original
       -- invoice distribution base amount and the paid invoice base amount
       -- due to this, unnecessary big amount Final payment is created
       -----------------------------------------------------------------------------

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'Calling procedure Pay_Dist_ERV for dist:' ||
                        p_inv_dist_rec.invoice_distribution_id ||
                        'and pmt l_prorated_amount =' || l_prorated_amount ||
                        'and discount amout prorated = ' || l_disc_pay_amount ;
           FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
       END IF;

       Pay_Dist_ERV
            (p_xla_event_rec,
             p_inv_pay_rec,
             p_pay_hist_rec,
             p_inv_rec,
             p_inv_dist_rec,
             l_prorated_amount + l_disc_pay_amount,
             l_curr_calling_sequence);

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'Procedure Pay_Dist_ERV executed';
           FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
       END IF;


  END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := 'End of pay_dist_proc';
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

END Pay_Dist_Proc;


---------------------------------------------------------------------
-- Procedure Pay_Dist_Discount
-- This procedure prorates the discount amounts for each distribution
-- and inserts the calculated values into payment hist dists table
---------------------------------------------------------------------

PROCEDURE Pay_Dist_Discount
      (p_xla_event_rec    IN    ap_accounting_pay_pkg.r_xla_event_info
      ,p_inv_pay_rec      IN    r_inv_pay_info
      ,p_pay_hist_rec     IN    ap_accounting_pay_pkg.r_pay_hist_info
      ,p_inv_rec          IN    ap_accounting_pay_pkg.r_invoices_info
      ,p_inv_dist_rec     IN    ap_accounting_pay_pkg.r_inv_dist_info
      ,p_calc_mode        IN    VARCHAR2
      ,p_disc_pay_amount  IN    OUT NOCOPY    NUMBER
      ,p_disc_dist_amount IN    OUT NOCOPY    NUMBER
      ,p_disc_bank_amount IN    OUT NOCOPY    NUMBER
      ,p_calling_sequence IN    VARCHAR2
      ) IS

  l_curr_calling_sequence          VARCHAR2(2000);
  l_invoice_amount                 NUMBER;
  l_prorated_disc_amt              NUMBER;
  l_prorated_base_amount           NUMBER;
  l_exclude_tax_from_disc          VARCHAR2(1);
  l_exclude_frt_from_disc          VARCHAR2(1);
  l_inv_dist_amount                NUMBER;
  l_bank_curr_amount               NUMBER;
  l_disc_amt_inv_curr              NUMBER;
  l_disc_amt_bank_curr             NUMBER;

  l_pd_rec                         AP_PAYMENT_HIST_DISTS%ROWTYPE;

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Pay_Dist_Discount';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_total_dist_amount  NUMBER; -- Added for bug 7577312

BEGIN


  l_curr_calling_sequence := 'AP_ACCTG_PAY_DIST_PKG.Pay_Dist_Discount<- ' ||
                                                 p_calling_sequence;


  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;


  l_exclude_tax_from_disc := p_inv_rec.Disc_Is_Inv_Less_Tax_Flag;
  l_exclude_frt_from_disc := p_inv_rec.exclude_freight_from_discount;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'l_exclude_tax_from_disc =' || l_exclude_tax_from_disc ||
                   'l_exclude_frt_from_disc = ' || l_exclude_frt_from_disc;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  -- Bug 7577312: Assigning the value of the l_total_dist_amount
  l_total_dist_amount := G_Total_Dist_Amount;

  /* Get the remaining invoice amount to be paid. Exclude the Tax and
     Freight amounts based on the system options to exclude tax and freight
     from discount */

  --added exception handling for bug 8406754
  BEGIN

  SELECT GL_Currency_API.Convert_Amount(
              p_inv_rec.invoice_currency_code,
              p_inv_rec.payment_currency_code,
              p_inv_rec.payment_cross_rate_date,
              'EMU FIXED',
              SUM(NVL(AID.Amount,0)))
  INTO   l_invoice_amount
  FROM   AP_Invoice_Distributions_All AID
  WHERE  AID.Invoice_ID =  p_inv_pay_rec.Invoice_ID
  AND    AID.Line_Type_Lookup_Code NOT IN ('PREPAY', 'AWT')
  AND    AID.Prepay_Tax_Parent_ID IS NULL -- For tax dists created in R11.5
  AND    AID.Prepay_Distribution_ID IS NULL
  AND    ( l_exclude_tax_from_disc = 'Y' and
           AID.Line_Type_Lookup_Code NOT IN ('REC_TAX', 'NONREC_TAX') or
           nvl(l_exclude_tax_from_disc, 'N') = 'N' )
  AND    AID.Line_Type_Lookup_Code <>
             DECODE(l_exclude_frt_from_disc, 'Y', 'FREIGHT', 'DUMMY')
  GROUP  BY AID.Invoice_ID;

  EXCEPTION

  WHEN OTHERS THEN
  l_invoice_amount := 0;

  END;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Total invoice amount excluding tax or freight = '||
                                          l_invoice_amount;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  /* If the options exclude_tax_from_disc and exclude_frt_from_disc
     are set to 'Y' then we do not need to distribution the payment
     to the Tax and Freight type of invoice distribution */
  IF (l_exclude_tax_from_disc = 'Y'
            AND ( p_inv_dist_rec.line_type_lookup_code = 'REC_TAX' or
                  p_inv_dist_rec.line_type_lookup_code = 'NONREC_TAX') ) THEN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'l_exclude_tax_from_disc= Y so this procedure do nothing for tax line';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      RETURN;

  ELSIF (l_exclude_frt_from_disc = 'Y'
            AND p_inv_dist_rec.line_type_lookup_code = 'FREIGHT') THEN

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'l_exclude_frt_from_disc= Y so this procedure do nothing';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      RETURN;

  ELSE

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'consider discount prorate to frieight';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      IF (p_inv_rec.invoice_currency_code <> p_inv_rec.payment_currency_code) THEN

          l_disc_amt_inv_curr := GL_Currency_API.Convert_Amount(
                                          p_inv_rec.payment_currency_code,
                                          p_inv_rec.invoice_currency_code,
                                          p_inv_rec.payment_cross_rate_date,
                                          'EMU FIXED',
                                          p_inv_pay_rec.discount_taken);

      ELSE

         l_disc_amt_inv_curr := p_inv_pay_rec.discount_taken;

      END IF;

      IF (p_xla_event_rec.event_type_code IN ('PAYMENT CLEARED',
                                              'PAYMENT CLEARING ADJUSTED')) THEN

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 l_log_msg := 'assigning the disc_amt_bank_curr for event type' ||
                              p_xla_event_rec.event_type_code;
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          IF p_pay_hist_rec.pmt_currency_code <> p_pay_hist_rec.bank_currency_code THEN

             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 l_log_msg := 'Converting discount amt into bank currency';
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;


             l_disc_amt_bank_curr :=
                       AP_Utilities_Pkg.AP_Round_Currency(
                            p_inv_pay_rec.discount_taken * p_pay_hist_rec.pmt_to_base_xrate
                                     /p_pay_hist_rec.bank_to_base_xrate,
                            p_pay_hist_rec.bank_currency_code);

          ELSE

             l_disc_amt_bank_curr := p_inv_pay_rec.discount_taken;

          END IF;

      ELSE

           -- bug 5652032
           -- due to record were inserted into payment history.
           -- often we don't need to have bank currency and bank amount
           -- related information, we need to take care of this case
           -- when transaction type is not clearing/unclearing

           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 l_log_msg := 'assigning the disc_amt_bank_curr for event type' ||
                              p_xla_event_rec.event_type_code;
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;

          l_disc_amt_bank_curr := p_inv_pay_rec.discount_taken;

      END IF;


      IF (p_calc_mode IN ('P','M')) THEN

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'not cascade mode - p_calc_mode = ' || p_calc_mode;
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          -- Bug 7577312: Changed the logic here to refer to l_total_dist_amount
          -- Bug 8202856. Added check for G_Last_NonExcluded_Dist_ID to cover cases
          -- where no discount amount is prorated to the last distribution.
          IF g_total_dist_amt = l_total_dist_amount OR
            p_inv_dist_rec.invoice_distribution_id = G_Last_NonExcluded_Dist_ID THEN -- last dist rec

             -- To avoid rounding, massage the last (biggest) line
             l_prorated_disc_amt := p_inv_pay_rec.discount_taken - g_total_prorated_disc_amt;
             l_inv_dist_amount := l_disc_amt_inv_curr - g_total_inv_dist_disc_amt;
             l_bank_curr_amount := l_disc_amt_bank_curr - g_total_bank_curr_disc_amt;

             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 l_log_msg := 'Value of l_prorated_disc_amt = '||l_prorated_disc_amt;
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;


          ELSE

             IF l_invoice_amount = 0 THEN

                l_prorated_disc_amt := 0;
                l_inv_dist_amount := 0;
                l_bank_curr_amount := 0;

             ELSE

                l_prorated_disc_amt := AP_UTILITIES_PKG.AP_ROUND_CURRENCY
                                        (p_inv_pay_rec.discount_taken * p_inv_dist_rec.amount
                                              / l_invoice_amount,
                                         p_pay_hist_rec.pmt_currency_code);

                l_inv_dist_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY
                                        (l_disc_amt_inv_curr * p_inv_dist_rec.amount
                                              / l_invoice_amount,
                                         p_inv_rec.invoice_currency_code);


               IF ( p_pay_hist_rec.bank_currency_code is not NULL ) THEN
                 l_bank_curr_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY
                                        (l_disc_amt_bank_curr * p_inv_dist_rec.amount
                                              / l_invoice_amount,
                                         p_pay_hist_rec.bank_currency_code);

               END IF;

             END IF;

             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 l_log_msg := 'Value of l_prorated_disc_amt = '||l_prorated_disc_amt;
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

          END IF;

          g_total_prorated_disc_amt := g_total_prorated_disc_amt + l_prorated_disc_amt;
          g_total_inv_dist_disc_amt := g_total_inv_dist_disc_amt + l_inv_dist_amount;
          g_total_bank_curr_disc_amt := g_total_bank_curr_disc_amt + l_bank_curr_amount;

      ELSE

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'seems cascade mode - p_calc_mode = ' || p_calc_mode;
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          l_prorated_disc_amt := AP_UTILITIES_PKG.AP_ROUND_CURRENCY
                                    (p_inv_pay_rec.discount_taken * p_inv_dist_rec.amount
                                          / l_invoice_amount,
                                     p_pay_hist_rec.pmt_currency_code)
                                 - ap_accounting_pay_pkg.get_casc_discount_sum
                                        (p_inv_dist_rec.invoice_distribution_id,
                                         p_pay_hist_rec.related_event_id,
                                         p_inv_pay_rec.invoice_payment_id,
                                         l_curr_calling_sequence);

          l_inv_dist_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY
                                    (l_disc_amt_inv_curr * p_inv_dist_rec.amount
                                          / l_invoice_amount,
                                     p_inv_rec.invoice_currency_code)
                                 - ap_accounting_pay_pkg.get_casc_inv_dist_disc_sum
                                        (p_inv_dist_rec.invoice_distribution_id,
                                         p_pay_hist_rec.related_event_id,
                                         p_inv_pay_rec.invoice_payment_id,
                                         l_curr_calling_sequence);

          IF ( p_pay_hist_rec.bank_currency_code is not NULL ) THEN
            l_inv_dist_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY
                                    (l_disc_amt_bank_curr * p_inv_dist_rec.amount
                                          / l_invoice_amount,
                                     p_pay_hist_rec.bank_currency_code)
                                 - ap_accounting_pay_pkg.get_casc_bank_curr_disc_sum
                                        (p_inv_dist_rec.invoice_distribution_id,
                                         p_pay_hist_rec.related_event_id,
                                         p_inv_pay_rec.invoice_payment_id,
                                         l_curr_calling_sequence);
          END IF;

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'Value of l_prorated_disc_amt = '||l_prorated_disc_amt;
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;


      END IF; -- If calc_mode in ('P,'M')

  END IF;


  -- Populate payment dist rec
  l_pd_rec.accounting_event_id := p_xla_event_rec.event_id;
  l_pd_rec.pay_dist_lookup_code := 'DISCOUNT';
  l_pd_rec.invoice_distribution_id := p_inv_dist_rec.invoice_distribution_id;
  l_pd_rec.amount := l_prorated_disc_amt;

  l_pd_rec.payment_history_id := p_pay_hist_rec.payment_history_id;
  l_pd_rec.invoice_payment_id := p_inv_pay_rec.invoice_payment_id;

  l_pd_rec.bank_curr_amount :=  l_bank_curr_amount;

  l_prorated_base_amount := AP_Accounting_Pay_Pkg.Get_Base_Amount
                                   (l_prorated_disc_amt,
                                    p_pay_hist_rec.pmt_currency_code,
                                    ap_accounting_pay_pkg.g_base_currency_code,
                                    p_pay_hist_rec.pmt_to_base_xrate_type,
                                    p_pay_hist_rec.pmt_to_base_xrate_date,
                                    p_pay_hist_rec.pmt_to_base_xrate,
                                    l_curr_calling_sequence);

  IF p_xla_event_rec.event_type_code IN
                  ('PAYMENT CLEARED', 'PAYMENT CLEARING ADJUSTED') THEN

     l_pd_rec.cleared_base_amount := AP_Accounting_Pay_Pkg.Get_Base_Amount
                                      (l_bank_curr_amount,
                                       p_pay_hist_rec.bank_currency_code,
                                       ap_accounting_pay_pkg.g_base_currency_code,
                                       p_pay_hist_rec.bank_to_base_xrate_type,
                                       p_pay_hist_rec.bank_to_base_xrate_date,
                                       p_pay_hist_rec.bank_to_base_xrate,
                                       l_curr_calling_sequence);

     l_pd_rec.paid_base_amount := AP_Accounting_Pay_Pkg.Get_Base_Amount
                                      (l_prorated_disc_amt,
                                       p_pay_hist_rec.pmt_currency_code,
                                       ap_accounting_pay_pkg.g_base_currency_code,
                                       ap_accounting_pay_pkg.g_pmt_to_base_xrate_type,
                                       ap_accounting_pay_pkg.g_pmt_to_base_xrate_date,
                                       ap_accounting_pay_pkg.g_pmt_to_base_xrate,
                                       l_curr_calling_sequence);

     IF ap_accounting_pay_pkg.g_mat_to_base_xrate IS NOT NULL THEN

        l_pd_rec.matured_base_amount := AP_Accounting_Pay_Pkg.Get_Base_Amount
                                          (l_prorated_disc_amt,
                                           p_pay_hist_rec.pmt_currency_code,
                                           ap_accounting_pay_pkg.g_base_currency_code,
                                           ap_accounting_pay_pkg.g_mat_to_base_xrate_type,
                                           ap_accounting_pay_pkg.g_mat_to_base_xrate_date,
                                           ap_accounting_pay_pkg.g_mat_to_base_xrate,
                                           l_curr_calling_sequence);
     END IF ;

  ELSIF p_xla_event_rec.event_type_code IN
                  ('PAYMENT MATURED', 'PAYMENT MATURITY ADJUSTED') THEN
     l_pd_rec.matured_base_amount := l_prorated_base_amount;

     l_pd_rec.paid_base_amount := AP_Accounting_Pay_Pkg.Get_Base_Amount
                                      (l_prorated_disc_amt,
                                       p_pay_hist_rec.pmt_currency_code,
                                       ap_accounting_pay_pkg.g_base_currency_code,
                                       ap_accounting_pay_pkg.g_pmt_to_base_xrate_type,
                                       ap_accounting_pay_pkg.g_pmt_to_base_xrate_date,
                                       ap_accounting_pay_pkg.g_pmt_to_base_xrate,
                                       l_curr_calling_sequence);

  ELSE
     l_pd_rec.paid_base_amount := l_prorated_base_amount;
  END IF;


  l_pd_rec.invoice_dist_amount := l_inv_dist_amount;

  /* If the exchange rates between the invoice and payment have not changed then
     the invoice and payment base amounts should be the same. Assigning the
     payment base amount to the invoice base amount instead of recalculating the
     invoice base amount */

  IF (p_pay_hist_rec.pmt_to_base_xrate =
               p_inv_rec.exchange_rate / p_inv_rec.payment_cross_rate) THEN

      l_pd_rec.invoice_dist_base_amount := l_prorated_base_amount;

  ELSE

      l_pd_rec.invoice_dist_base_amount :=
                                    AP_Accounting_Pay_Pkg.Get_Base_Amount
                                         (l_inv_dist_amount,
                                          p_inv_rec.invoice_currency_code,
                                          ap_accounting_pay_pkg.g_base_currency_code,
                                          p_inv_rec.exchange_rate_type,
                                          p_inv_rec.exchange_date,
                                          p_inv_rec.exchange_rate,
                                          l_curr_calling_sequence);

  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Calling procedure Pay_Dist_Insert';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;


  Pay_Dist_Insert
          (l_pd_rec,
           l_curr_calling_sequence);


  p_disc_pay_amount := NVL(l_prorated_disc_amt,0);
  p_disc_dist_amount := NVL(l_inv_dist_amount,0);
  p_disc_bank_amount := NVL(l_bank_curr_amount,0);


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Procedure Pay_Dist_Insert executed';
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

END Pay_Dist_Discount;


---------------------------------------------------------------------
-- Procedure Pay_Dist_ERV
-- This procedure calculates the ERV base amounts for the ERV distributions
-- and inserts the calculated values into payment hist dists table
---------------------------------------------------------------------

PROCEDURE Pay_Dist_ERV
      (p_xla_event_rec    IN    ap_accounting_pay_pkg.r_xla_event_info
      ,p_inv_pay_rec      IN    r_inv_pay_info
      ,p_pay_hist_rec     IN    ap_accounting_pay_pkg.r_pay_hist_info
      ,p_inv_rec          IN    ap_accounting_pay_pkg.r_invoices_info
      ,p_inv_dist_rec     IN    ap_accounting_pay_pkg.r_inv_dist_info
      ,p_prorated_amount  IN    NUMBER
      ,p_calling_sequence IN    VARCHAR2
      ) IS

  l_curr_calling_sequence          VARCHAR2(2000);
  l_po_exchange_rate               NUMBER;
  l_po_pay_exchange_rate           NUMBER;
  l_erv_amount                     NUMBER;
  l_inv_erv_amount                 NUMBER;
  l_pd_rec                         AP_PAYMENT_HIST_DISTS%ROWTYPE;

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Pay_Dist_ERV';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN


  l_curr_calling_sequence := 'AP_ACCTG_PAY_DIST_PKG.Pay_Dist_ERV<- ' ||
                                                 p_calling_sequence;


  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;

  IF p_inv_dist_rec.rcv_transaction_id IS NOT NULL THEN

     SELECT Currency_Conversion_Rate
     INTO   l_po_exchange_rate
     FROM   rcv_transactions
     WHERE  transaction_id = p_inv_dist_rec.rcv_transaction_id;

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'receipt matching and exchange rate = ' ||
                    l_po_exchange_rate;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
     END IF;

  ELSE

     SELECT Rate
     INTO   l_po_exchange_rate
     FROM   PO_Distributions_All
     WHERE  PO_Distribution_ID = p_inv_dist_rec.PO_Distribution_ID;

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'po matching and exchange rate = ' ||
                    l_po_exchange_rate;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
     END IF;

  END IF;

  IF p_inv_rec.invoice_currency_code <> p_inv_rec.payment_currency_code THEN

     l_po_pay_exchange_rate := l_po_exchange_rate / p_inv_rec.payment_cross_rate;

  ELSE
     l_po_pay_exchange_rate := l_po_exchange_rate;
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Value of l_po_pay_exchange_rate = '||l_po_pay_exchange_rate ||
                   'value of p_prorated_amount=' ||  p_prorated_amount;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  /* For Cash Basis ERV is Difference between Payment Exchange Rate and
     either Receipt Exchange rate or PO distributions exchange rate */

  l_erv_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                      (p_pay_hist_rec.pmt_to_base_xrate - l_po_pay_exchange_rate) *
                           p_prorated_amount, p_pay_hist_rec.pmt_currency_code);


  /* In order to back out the encumbrance entries correctly during cash basis
     we need to calculate ERV based on the difference between the Invoice
     Exchange Rate and either Receipt Exchange rate or PO distributions
     exchange rate. This calculated ERV amount will be stored in the
     invoice_dist_base_amount column */

  l_inv_erv_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                         (p_inv_rec.exchange_rate - l_po_pay_exchange_rate) *
                              p_prorated_amount, p_inv_rec.invoice_currency_code);


  -- Populate payment dist rec
  l_pd_rec.accounting_event_id := p_xla_event_rec.event_id;

  IF (p_inv_dist_rec.line_type_lookup_code IN ('NONREC_TAX', 'REC_TAX')) THEN
      l_pd_rec.pay_dist_lookup_code := 'TAX EXCHANGE RATE VARIANCE';
  ELSE
      l_pd_rec.pay_dist_lookup_code := 'EXCHANGE RATE VARIANCE';
  END IF;

  l_pd_rec.invoice_distribution_id := p_inv_dist_rec.invoice_distribution_id;
  l_pd_rec.amount := 0;

  l_pd_rec.payment_history_id := p_pay_hist_rec.payment_history_id;
  l_pd_rec.invoice_payment_id := p_inv_pay_rec.invoice_payment_id;
  l_pd_rec.bank_curr_amount := 0;
  l_pd_rec.invoice_dist_amount := 0;

  IF (p_xla_event_rec.event_type_code IN ('PAYMENT CLEARED',
                                         'PAYMENT CLEARING ADJUSTED')) THEN
      l_pd_rec.cleared_base_amount := l_erv_amount;
  ELSE
      l_pd_rec.paid_base_amount := l_erv_amount;
  END IF;

  l_pd_rec.invoice_dist_base_amount := l_inv_erv_amount;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Calling procedure Pay_Dist_Insert';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'before callining erv/terv insert -' ||
                   'l_pd_rec.invoice_dist_base_amount = ' ||
                   l_pd_rec.invoice_dist_base_amount ||
                   'l_pd_rec.paid_base_amount or cleared_base_amount =' ||
                   l_erv_amount;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  --9081055, Not inserting Exchange rate variance when the exchange rates
  -- at PO, Invoice and Payments are equal . Added condition to call
  -- Pay_dist_insert procedure.

  IF ( l_erv_amount <>0 OR l_inv_erv_amount <>0) THEN
    Pay_Dist_Insert
          (l_pd_rec,
           l_curr_calling_sequence);
  END IF ;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Procedure Pay_Dist_Insert executed';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'end of procedure Pay_Dist_ERV';
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

END Pay_Dist_ERV;


---------------------------------------------------------------------
-- Procedure Pay_Dist_Err_Chrg
-- This procedure prorates the errors and charge amounts for each distribution
-- and inserts the calculated values into payment hist dists table
---------------------------------------------------------------------

PROCEDURE Pay_Dist_Err_Chrg
      (p_xla_event_rec    IN    ap_accounting_pay_pkg.r_xla_event_info
      ,p_pay_hist_rec     IN    ap_accounting_pay_pkg.r_pay_hist_info
      ,p_distribute_mode  IN    VARCHAR2
      ,p_calling_sequence IN    VARCHAR2
      ) IS

  l_curr_calling_sequence          VARCHAR2(2000);
  l_err_chrg_amount                NUMBER;
  l_prorated_amt                   NUMBER;
  l_prorated_base_amount           NUMBER;
  l_total_pay_amt                  NUMBER;
  l_pay_dist_type                  VARCHAR2(30);
  l_total_dist_amt                 NUMBER := 0;
  l_total_prorated_amt             NUMBER := 0;
  l_inv_dist_amount                NUMBER;

  l_pd_rec                         AP_PAYMENT_HIST_DISTS%ROWTYPE;

  CURSOR clearing_pay_dists
        (P_Event_ID    NUMBER)
        IS
  SELECT Accounting_Event_ID,
         Invoice_Distribution_ID,
         Amount,
         Payment_History_ID,
         Invoice_Payment_ID
  FROM   AP_Payment_Hist_Dists APHD
  WHERE  APHD.Accounting_Event_ID = P_Event_ID
  AND    APHD.Pay_Dist_Lookup_Code = 'CASH'
  ORDER  BY Amount;

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Pay_Dist_Err_Chrg';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;


BEGIN


  l_curr_calling_sequence := 'AP_ACCTG_PAY_DIST_PKG.Pay_Dist_Err_Chrg<- ' ||
                                                 p_calling_sequence;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Passing Parameters are ' ||
                   'p_distribute_mode=' || p_distribute_mode ||
                   'event_id = ' || p_xla_event_rec.event_id;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;


  IF ( p_distribute_mode = 'BANK_ERROR' AND
       NVL(p_pay_hist_rec.errors_bank_amount,0) <> 0) THEN

      l_err_chrg_amount := p_pay_hist_rec.errors_bank_amount;
      l_pay_dist_type := 'BANK ERROR';

  ELSIF (  p_distribute_mode = 'BANK_CHARGE' AND
            NVL(p_pay_hist_rec.charges_bank_amount,0) <> 0 ) THEN

      l_err_chrg_amount := p_pay_hist_rec.charges_bank_amount;
      l_pay_dist_type := 'BANK CHARGE';

  ELSE
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'No need to prorate charge or error when amount=0 - return';
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
      END IF;
      return;
  END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'l_err_chrg_amount= ' || l_err_chrg_amount;
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;


  SELECT SUM(Amount)
  INTO   l_total_pay_amt
  FROM   AP_Payment_Hist_Dists
  WHERE  Payment_History_ID = p_pay_hist_rec.payment_history_id
  AND    Pay_Dist_Lookup_Code = 'CASH';


  FOR l_clr_rec IN clearing_pay_dists(p_xla_event_rec.event_id)
  LOOP

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'CUR: clearing_pay_dists: Invoice_Dist_ID = '
                       ||l_clr_rec.invoice_distribution_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      l_total_dist_amt := l_total_dist_amt + l_clr_rec.amount;

      IF l_total_dist_amt = l_total_pay_amt THEN
         l_prorated_amt := l_err_chrg_amount - l_total_prorated_amt;
      ELSE
         l_prorated_amt := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                                  l_err_chrg_amount * l_clr_rec.amount
                                    / l_total_pay_amt, p_pay_hist_rec.pmt_currency_code);
      END IF;

      l_total_prorated_amt := l_total_prorated_amt + l_prorated_amt;


      -- Populate payment dist rec
      l_pd_rec.accounting_event_id := p_xla_event_rec.event_id;

      l_pd_rec.pay_dist_lookup_code := l_pay_dist_type;
      l_pd_rec.invoice_distribution_id := l_clr_rec.invoice_distribution_id;
      l_pd_rec.amount := l_prorated_amt;

      l_pd_rec.payment_history_id := p_pay_hist_rec.payment_history_id;
      l_pd_rec.invoice_payment_id := l_clr_rec.invoice_payment_id;

      -- Bug#8790270 l_prorated_amt is in bank currency
      -- l_pd_rec.bank_curr_amount := l_prorated_amt; 8720521

      IF (p_pay_hist_rec.bank_currency_code <> p_pay_hist_rec.pmt_currency_code) Then --8720521

         l_pd_rec.bank_curr_amount := AP_Utilities_Pkg.AP_Round_Currency
                                       (l_prorated_amt
                                        * nvl(p_pay_hist_rec.pmt_to_base_xrate,1)
                                        / nvl(p_pay_hist_rec.bank_to_base_xrate,1)
                                        ,p_pay_hist_rec.bank_currency_code);

      ELSE
         l_pd_rec.bank_curr_amount := l_prorated_amt;
      End If; -- bank_currency_code <> pmt_currency_code 8720521 End

      /*l_pd_rec.bank_curr_amount :=  AP_Accounting_Pay_Pkg.Get_Base_Amount
                                         (l_prorated_amt,
                                          p_pay_hist_rec.bank_currency_code,
                                          ap_accounting_pay_pkg.g_base_currency_code,
                                          p_pay_hist_rec.bank_to_base_xrate_type,
                                          p_pay_hist_rec.bank_to_base_xrate_date,
                                          p_pay_hist_rec.bank_to_base_xrate,
                                          l_curr_calling_sequence);
       */
      -- Bug6901436. l_prorated_amount is in bank currency. Bank to base
      -- exchange rate details needs to be provided to Get_Base_Amount
      -- procedure.

      /*l_prorated_base_amount := AP_Accounting_Pay_Pkg.Get_Base_Amount
      --                                   (l_prorated_amt,
      --                                    p_pay_hist_rec.pmt_currency_code,
      --                                    ap_accounting_pay_pkg.g_base_currency_code,
      --                                    p_pay_hist_rec.pmt_to_base_xrate_type,
      --                                    p_pay_hist_rec.pmt_to_base_xrate_date,
      --                                    p_pay_hist_rec.pmt_to_base_xrate,
      --                                    l_curr_calling_sequence);*/

       l_prorated_base_amount := AP_Accounting_Pay_Pkg.Get_Base_Amount
                                         (l_prorated_amt,
                                          p_pay_hist_rec.bank_currency_code,
                                          ap_accounting_pay_pkg.g_base_currency_code,
                                          p_pay_hist_rec.bank_to_base_xrate_type,
                                          p_pay_hist_rec.bank_to_base_xrate_date,
                                          p_pay_hist_rec.bank_to_base_xrate,
                                          l_curr_calling_sequence);

      -- End bug6901436

      IF p_xla_event_rec.event_type_code IN
                      ('PAYMENT CLEARED', 'PAYMENT CLEARING ADJUSTED') THEN
         l_pd_rec.cleared_base_amount := l_prorated_base_amount;

         l_pd_rec.paid_base_amount := AP_Accounting_Pay_Pkg.Get_Base_Amount
                                          (l_prorated_amt,
                                           p_pay_hist_rec.pmt_currency_code,
                                           ap_accounting_pay_pkg.g_base_currency_code,
                                           ap_accounting_pay_pkg.g_pmt_to_base_xrate_type,
                                           ap_accounting_pay_pkg.g_pmt_to_base_xrate_date,
                                           ap_accounting_pay_pkg.g_pmt_to_base_xrate,
                                           l_curr_calling_sequence);

         IF ap_accounting_pay_pkg.g_mat_to_base_xrate IS NOT NULL THEN

            l_pd_rec.matured_base_amount := AP_Accounting_Pay_Pkg.Get_Base_Amount
                                              (l_prorated_amt,
                                               p_pay_hist_rec.pmt_currency_code,
                                               ap_accounting_pay_pkg.g_base_currency_code,
                                               ap_accounting_pay_pkg.g_mat_to_base_xrate_type,
                                               ap_accounting_pay_pkg.g_mat_to_base_xrate_date,
                                               ap_accounting_pay_pkg.g_mat_to_base_xrate,
                                               l_curr_calling_sequence);
         END IF ;
      ELSIF p_xla_event_rec.event_type_code IN
                      ('PAYMENT MATURED', 'PAYMENT MATURITY ADJUSTED') THEN
         l_pd_rec.matured_base_amount := l_prorated_base_amount;

         l_pd_rec.paid_base_amount := AP_Accounting_Pay_Pkg.Get_Base_Amount
                                      (l_prorated_amt,
                                       p_pay_hist_rec.pmt_currency_code,
                                       ap_accounting_pay_pkg.g_base_currency_code,
                                       ap_accounting_pay_pkg.g_pmt_to_base_xrate_type,
                                       ap_accounting_pay_pkg.g_pmt_to_base_xrate_date,
                                       ap_accounting_pay_pkg.g_pmt_to_base_xrate,
                                       l_curr_calling_sequence);

      ELSE
         l_pd_rec.paid_base_amount := l_prorated_base_amount;
      END IF;

      l_pd_rec.invoice_dist_amount := NULL;
      l_pd_rec.invoice_dist_base_amount := NULL;


      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'Calling procedure Pay_Dist_Insert';
          FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
      END IF;

      -- Insert the payment hist distribution
      Pay_Dist_Insert
              (l_pd_rec,
               l_curr_calling_sequence);

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'Procedure Pay_Dist_Insert executed';
          FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
      END IF;


  END LOOP;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Pay_Dist_Err_Chrg;



---------------------------------------------------------------------
-- Procedure Pay_Dist_Reverse
-- This procedure reverses the payment distributions of the invoice
-- payments that have been reversed.
--
---------------------------------------------------------------------

-- Bug 6887295. Added parameter p_inv_dist_rec
PROCEDURE Pay_Dist_Reverse
      (p_xla_event_rec           IN    ap_accounting_pay_pkg.r_xla_event_info
      ,p_inv_pay_rec             IN    r_inv_pay_info
      ,p_pay_hist_rec            IN    ap_accounting_pay_pkg.r_pay_hist_info
      ,p_reversal_inv_pmt_id     IN    NUMBER
      ,p_related_event_id        IN    NUMBER
      ,p_invoice_dist_id         IN    NUMBER
      ,p_inv_dist_rec            IN    ap_accounting_pay_pkg.r_inv_dist_info
      ,p_calling_sequence        IN    VARCHAR2
      ) IS

  l_curr_calling_sequence          VARCHAR2(2000);

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Pay_Dist_Reverse';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  l_transaction_type      AP_PAYMENT_HISTORY_ALL.TRANSACTION_TYPE%TYPE;
  l_payment_history_id    AP_PAYMENT_HISTORY_ALL.PAYMENT_HISTORY_ID%TYPE;
  l_accounting_event_id   AP_PAYMENT_HISTORY_ALL.ACCOUNTING_EVENT_ID%TYPE;
  l_historical_flag       AP_PAYMENT_HISTORY_ALL.HISTORICAL_FLAG%TYPE;
  l_reversed_in_R12       VARCHAR2(1) := 'N';
  l_upg_batch_id          XLA_AE_HEADERS.UPG_BATCH_ID%TYPE;


BEGIN

  l_curr_calling_sequence := 'AP_ACCTG_PAY_DIST_PKG.Pay_Dist_Reverse<-' ||
                                           p_calling_sequence;


  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;

  IF p_reversal_inv_pmt_id IS NOT NULL THEN


     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Reversing based on reversal_inv_pmt_id '||
                                             p_reversal_inv_pmt_id;
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

     INSERT INTO ap_payment_hist_dists
           (Payment_Hist_Dist_ID,
            Accounting_Event_ID,
            Amount,
            Pay_Dist_Lookup_Code,
            Payment_History_ID,
            Invoice_Distribution_ID,
            Invoice_Payment_ID,
            Bank_Curr_Amount,
            Cleared_Base_Amount,
            Invoice_Dist_Amount,
            Invoice_Dist_Base_Amount,
            Invoice_Adjustment_Event_ID,
            Matured_Base_Amount,
            Paid_Base_Amount,
            Reversal_Flag,
            Reversed_Pay_Hist_Dist_ID,
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
            Program_Login_ID,
            Program_Update_Date,
            Request_ID
           )
     SELECT AP_Payment_Hist_Dists_S.nextval,
            p_xla_event_rec.event_id,
            -1 * APHD.Amount,
            APHD.Pay_Dist_Lookup_Code,
            p_pay_hist_rec.Payment_History_ID,
            APHD.Invoice_Distribution_ID,
            p_inv_pay_rec.invoice_payment_id,
            -1 * APHD.Bank_Curr_Amount,
            -1 * APHD.Cleared_Base_Amount,
            -1 * APHD.Invoice_Dist_Amount,
            -1 * APHD.Invoice_Dist_Base_Amount,
            APHD.Invoice_Adjustment_Event_ID,
            -1 * APHD.Matured_Base_Amount,
            -1 * APHD.Paid_Base_Amount,
            'Y',
            APHD.Payment_Hist_Dist_ID,
            APHD.AWT_Related_ID,
            'N',
            APHD.Quantity_Variance,
            APHD.Invoice_Base_Qty_Variance,
            APHD.Amount_Variance,
            APHD.Invoice_Base_Amt_Variance,
            FND_GLOBAL.User_ID,
            SYSDATE,
            SYSDATE,
            FND_GLOBAL.User_ID,
            FND_GLOBAL.User_ID,
            FND_GLOBAL.Prog_Appl_ID,
            FND_GLOBAL.Conc_Program_ID,
            NULL,
            SYSDATE,
            FND_GLOBAL.Conc_Request_ID
     FROM   AP_Payment_Hist_Dists APHD,
            AP_Invoice_Payments_All AIP,
            AP_Invoice_Distributions_All AID
     WHERE  AIP.Invoice_Payment_ID = p_reversal_inv_pmt_id
     AND    AIP.Accounting_Event_ID = APHD.Accounting_Event_ID
     AND    AIP.Invoice_ID = AID.Invoice_ID
     AND    AID.Invoice_Distribution_ID = APHD.Invoice_Distribution_ID;


  ELSIF p_related_event_id IS NOT NULL THEN


     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Reversing based on related_event_id '||
                                             p_related_event_id;
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

     -- Bug 5015973. We will insert the new invoice_payment_id only for the
     -- cancelled event.
     IF p_xla_event_rec.event_type_code IN ('PAYMENT CANCELLED',
                                            'REFUND CANCELLED') THEN

        INSERT INTO ap_payment_hist_dists
              (Payment_Hist_Dist_ID,
               Accounting_Event_ID,
               Amount,
               Pay_Dist_Lookup_Code,
               Payment_History_ID,
               Invoice_Distribution_ID,
               Invoice_Payment_ID,
               Bank_Curr_Amount,
               Cleared_Base_Amount,
               Invoice_Dist_Amount,
               Invoice_Dist_Base_Amount,
               Invoice_Adjustment_Event_ID,
               Matured_Base_Amount,
               Paid_Base_Amount,
               Reversal_Flag,
               Reversed_Pay_Hist_Dist_ID,
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
               Program_Login_ID,
               Program_Update_Date,
               Request_ID
              )
        SELECT AP_Payment_Hist_Dists_S.nextval,
               p_xla_event_rec.event_id,
               -1 * APHD.Amount,
               APHD.Pay_Dist_Lookup_Code,
               p_pay_hist_rec.Payment_History_ID,
               APHD.Invoice_Distribution_ID,
               AIP.Invoice_Payment_ID,
               -1 * APHD.Bank_Curr_Amount,
               -1 * APHD.Cleared_Base_Amount,
               -1 * APHD.Invoice_Dist_Amount,
               -1 * APHD.Invoice_Dist_Base_Amount,
               APHD.Invoice_Adjustment_Event_ID,
               -1 * APHD.Matured_Base_Amount,
               -1 * APHD.Paid_Base_Amount,
               'Y',
               APHD.Payment_Hist_Dist_ID,
               APHD.AWT_Related_ID,
               'N',
               APHD.Quantity_Variance,
               APHD.Invoice_Base_Qty_Variance,
               APHD.Amount_Variance,
               APHD.Invoice_Base_Amt_Variance,
               FND_GLOBAL.User_ID,
               SYSDATE,
               SYSDATE,
               FND_GLOBAL.User_ID,
               FND_GLOBAL.User_ID,
               FND_GLOBAL.Prog_Appl_ID,
               FND_GLOBAL.Conc_Program_ID,
               NULL,
               SYSDATE,
               FND_GLOBAL.Conc_Request_ID
        FROM   AP_Payment_Hist_Dists APHD,
               AP_Payment_History_All APH,
               AP_Invoice_Payments_All AIP,
               AP_Invoice_Distributions_All AID   -- 6804379
        WHERE  nvl(APH.Related_Event_ID, APH.Accounting_Event_ID) = p_related_event_id
        AND    APHD.Payment_History_ID = APH.Payment_History_ID
        AND    NVL(APHD.Reversal_Flag,'N') <> 'Y'
        AND    AID.Invoice_Distribution_ID = APHD.Invoice_Distribution_ID
	AND    AIP.Reversal_inv_pmt_id = APHD.invoice_payment_id --Bug 6881085
        AND    AIP.Accounting_Event_ID = p_xla_event_rec.event_id
        AND    AIP.Check_ID = APH.Check_ID -- Bug 6856694
        AND    AIP.Invoice_ID = AID.Invoice_ID
        AND    NOT EXISTS (SELECT 'Reversal Payment Dists'
                           FROM   AP_Payment_Hist_Dists APHD1
                           WHERE  APHD1.Reversed_Pay_Hist_Dist_ID
                                      = APHD.Payment_Hist_Dist_ID
                           -- Bug 6856694
                           AND    APHD1.Invoice_Distribution_ID
                                      = APHD.Invoice_Distribution_ID);

     ELSE
        INSERT INTO ap_payment_hist_dists
              (Payment_Hist_Dist_ID,
               Accounting_Event_ID,
               Amount,
               Pay_Dist_Lookup_Code,
               Payment_History_ID,
               Invoice_Distribution_ID,
               Invoice_Payment_ID,
               Bank_Curr_Amount,
               Cleared_Base_Amount,
               Invoice_Dist_Amount,
               Invoice_Dist_Base_Amount,
               Invoice_Adjustment_Event_ID,
               Matured_Base_Amount,
               Paid_Base_Amount,
               Reversal_Flag,
               Reversed_Pay_Hist_Dist_ID,
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
               Program_Login_ID,
               Program_Update_Date,
               Request_ID
              )
        SELECT AP_Payment_Hist_Dists_S.nextval,
               p_xla_event_rec.event_id,
               -1 * APHD.Amount,
               APHD.Pay_Dist_Lookup_Code,
               p_pay_hist_rec.Payment_History_ID,
               APHD.Invoice_Distribution_ID,
               APHD.Invoice_Payment_ID,
               -1 * APHD.Bank_Curr_Amount,
               -1 * APHD.Cleared_Base_Amount,
               -1 * APHD.Invoice_Dist_Amount,
               -1 * APHD.Invoice_Dist_Base_Amount,
               APHD.Invoice_Adjustment_Event_ID,
               -1 * APHD.Matured_Base_Amount,
               -1 * APHD.Paid_Base_Amount,
               'Y',
               APHD.Payment_Hist_Dist_ID,
               APHD.AWT_Related_ID,
               'N',
               APHD.Quantity_Variance,
               APHD.Invoice_Base_Qty_Variance,
               APHD.Amount_Variance,
               APHD.Invoice_Base_Amt_Variance,
               FND_GLOBAL.User_ID,
               SYSDATE,
               SYSDATE,
               FND_GLOBAL.User_ID,
               FND_GLOBAL.User_ID,
               FND_GLOBAL.Prog_Appl_ID,
               FND_GLOBAL.Conc_Program_ID,
               NULL,
               SYSDATE,
               FND_GLOBAL.Conc_Request_ID
        FROM   AP_Payment_Hist_Dists APHD,
               AP_Payment_History_All APH -- 6804379
        WHERE  APH.Check_ID = p_xla_event_rec.Source_ID_Int_1 -- Bug 6856694
        AND    NVL(APH.Related_Event_ID, APH.Accounting_Event_ID) = p_related_event_id
        AND    APHD.Payment_History_ID = APH.Payment_History_ID
        AND    NVL(APHD.Reversal_Flag,'N') <> 'Y'
        AND    NOT EXISTS (SELECT 'Reversal Payment Dists'
                           FROM   AP_Payment_Hist_Dists APHD1
                           WHERE  APHD1.Reversed_Pay_Hist_Dist_ID
                                      = APHD.Payment_Hist_Dist_ID
                           -- Bug 6856694
                           AND    APHD1.Invoice_Distribution_ID
                                      = APHD.Invoice_Distribution_ID);

     END IF;

  ELSE

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Reversing based on invoice_distribution_id '||
                                             p_invoice_dist_id;
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

     INSERT INTO ap_payment_hist_dists
           (Payment_Hist_Dist_ID,
            Accounting_Event_ID,
            Amount,
            Pay_Dist_Lookup_Code,
            Payment_History_ID,
            Invoice_Distribution_ID,
            Invoice_Payment_ID,
            Bank_Curr_Amount,
            Cleared_Base_Amount,
            Invoice_Dist_Amount,
            Invoice_Dist_Base_Amount,
            Invoice_Adjustment_Event_ID,
            Matured_Base_Amount,
            Paid_Base_Amount,
            Reversal_Flag,
            Reversed_Pay_Hist_Dist_ID,
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
            Program_Login_ID,
            Program_Update_Date,
            Request_ID
           )
     SELECT AP_Payment_Hist_Dists_S.nextval,
            p_xla_event_rec.event_id,
            -1 * APHD.Amount,
            APHD.Pay_Dist_Lookup_Code,
            p_pay_hist_rec.Payment_History_ID,
            p_inv_dist_rec.Invoice_Distribution_ID, -- Bug 6887295
            APHD.Invoice_Payment_ID,
            -1 * APHD.Bank_Curr_Amount,
            -1 * APHD.Cleared_Base_Amount,
            -1 * APHD.Invoice_Dist_Amount,
            -1 * APHD.Invoice_Dist_Base_Amount,
            p_pay_hist_rec.Invoice_Adjustment_Event_ID,
            -1 * APHD.Matured_Base_Amount,
            -1 * APHD.Paid_Base_Amount,
            'Y',
            APHD.Payment_Hist_Dist_ID,
            APHD.AWT_Related_ID,
            'N',
            APHD.Quantity_Variance,
            APHD.Invoice_Base_Qty_Variance,
            APHD.Amount_Variance,
            APHD.Invoice_Base_Amt_Variance,
            FND_GLOBAL.User_ID,
            SYSDATE,
            SYSDATE,
            FND_GLOBAL.User_ID,
            FND_GLOBAL.User_ID,
            FND_GLOBAL.Prog_Appl_ID,
            FND_GLOBAL.Conc_Program_ID,
            NULL,
            SYSDATE,
            FND_GLOBAL.Conc_Request_ID
     FROM   AP_Payment_Hist_Dists APHD,
            AP_Payment_History_All APH
     WHERE  APHD.Invoice_Distribution_ID = p_invoice_dist_id
     AND    APHD.Payment_History_ID = APH.Payment_History_ID
     AND    APH.Check_ID = p_xla_event_rec.source_id_int_1 -- Bug 6887295
     AND    APH.Related_Event_ID = p_pay_hist_rec.related_event_id;

  END IF;


  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Done reversing the payment dists';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  -- Bug 6839052. Payment Cancellation cannot account for upgraded payments
  -- since the amounts are not populated in the pay dists table or in the
  -- xla distribution links table and XLA depends on these amounts for
  -- creating reversal accounting.

  IF p_xla_event_rec.event_type_code IN
                 ('PAYMENT CANCELLED','REFUND CANCELLED',
                  'PAYMENT MATURITY REVERSED', 'PAYMENT UNCLEARED',
                  'MANUAL PAYMENT ADJUSTED') THEN
  -- Bug 8708433 If payment Creation and Payment cleared are accounted in 11i
  -- and upgraded, then we need to do the repopulation for the accounting
  -- entries of these events also, when we account the payment cancellation in R12
  -- As such I have called the api Upg_Dist_Links_Insert in a loop so that we can
  -- reinsert the dist links for the other events as well
  -- If the event_type_code is other than cancellation, then the same logic as before
  -- applies

     IF p_xla_event_rec.event_type_code IN ('PAYMENT CANCELLED','REFUND CANCELLED') THEN
       FOR aph_events in (
         SELECT Payment_History_ID,
                Accounting_Event_ID,
                NVL(Historical_Flag, 'N') Historical_Flag,
                XAH.upg_batch_id
           FROM ap_payment_history_all APH,
                xla_ae_headers XAH,
                ap_system_parameters_all ASP
          WHERE  APH.Check_ID = p_xla_event_rec.source_id_int_1
            -- AND    APH.rev_pmt_hist_id is null   bug9448974
            AND    APH.Posted_Flag = 'Y'
            AND    XAH.application_id = 200
            AND    XAH.event_id = APH.accounting_event_id
            AND    ASP.org_id = APH.org_id
            AND    ASP.set_of_books_id = XAH.ledger_id)
       LOOP

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'Inside loop for upgrading dist links for '||
	                'PAYMENT CANCELLED,REFUND CANCELLED ';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

         IF (aph_events.Historical_Flag = 'Y' AND
             aph_events.upg_batch_id IS NOT NULL AND
             aph_events.upg_batch_id <> -9999) THEN
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'Calling Upg_Dist_Links_Insert for payment_history_id '||
	                   aph_events.payment_history_id;
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;


           -- We should not be recreating the distribution links for the historical
           -- event which has already been reversed in R12, say a PAYMENT CLEARING
           -- event (historical) for which unclearing has already been Accounted in R12
           -- (bug9492684)
           BEGIN
             l_reversed_in_R12 := 'N';

             SELECT 'Y'
               INTO l_reversed_in_R12
               FROM dual
              WHERE EXISTS
                    (SELECT 'reversed in R12'
                       FROM ap_payment_history_all aph,
                            xla_ae_headers xah,
                            ap_system_parameters_all asp
                      WHERE aph.rev_pmt_hist_id = aph_events.payment_history_id
                        AND xah.application_id = 200
                        AND aph.accounting_event_id = xah.event_id
                        AND aph.posted_flag = 'Y'
                        AND xah.accounting_entry_status_code = 'F'
                        AND xah.ledger_id = asp.set_of_books_id
                        AND aph.org_id = aph.org_id
                        AND (xah.upg_batch_id IS NULL OR
                             xah.upg_batch_id = -9999));

           EXCEPTION
             WHEN OTHERS THEN
               l_reversed_in_R12 := 'N';

           END;

           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'Event reversed in R12 already '||l_reversed_in_R12;
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;

           IF l_reversed_in_R12 = 'N' THEN

   	     Upg_Dist_Links_Insert
                    (p_xla_event_rec,
                     aph_events.payment_history_id,
                     aph_events.accounting_event_id,
                     l_curr_calling_sequence);
           END IF;

	   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'Procedure Upg_Dist_Link_Insert complete';
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;

         END IF;
       END LOOP;
     ELSE
  -- Bug 8708433 If event is any other than cancellation, then the same logic as before
  --- applies
       IF p_xla_event_rec.event_type_code = 'MANUAL PAYMENT ADJUSTED' THEN
         l_transaction_type := 'PAYMENT CREATED';
       ELSIF p_xla_event_rec.event_type_code = 'PAYMENT UNCLEARED' THEN
         l_transaction_type := 'PAYMENT CLEARING';
       ELSIF p_xla_event_rec.event_type_code = 'PAYMENT MATURITY REVERSED' THEN
         l_transaction_type := 'PAYMENT MATURITY';
       END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'Transaction Type based on the event type is '||
                                               l_transaction_type;
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       BEGIN
       -- bug8911872
         SELECT Payment_History_ID,
                Accounting_Event_ID,
                NVL(Historical_Flag, 'N'),
                XAH.upg_batch_id
           INTO l_payment_history_id,
                l_accounting_event_id,
                l_historical_flag,
                l_upg_batch_id
           FROM ap_payment_history_all APH,
                xla_ae_headers XAH,
                ap_system_parameters_all ASP
          WHERE APH.Check_ID = p_xla_event_rec.source_id_int_1
            AND APH.Transaction_Type = l_transaction_type
            AND APH.payment_history_id =
                        DECODE(l_transaction_type,
                               'PAYMENT CLEARING', p_pay_hist_rec.rev_pmt_hist_id,
                               'PAYMENT MATURITY', p_pay_hist_rec.rev_pmt_hist_id,
                                APH.payment_history_id)
            AND APH.Posted_Flag = 'Y'
            AND XAH.application_id = 200
            AND XAH.event_id = APH.accounting_event_id
            AND ASP.org_id = APH.org_id
            AND ASP.set_of_books_id = XAH.ledger_id;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'Accounting Event ID of the related event '||
                                                 l_accounting_event_id;
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'Historical Flag of the related event '||
                                               l_historical_flag;
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         IF (l_historical_flag = 'Y' AND
             l_upg_batch_id IS NOT NULL AND
             l_upg_batch_id <> -9999) THEN

           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'Calling procedure Upg_Dist_Link_Insert';
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;

           Upg_Dist_Links_Insert
                    (p_xla_event_rec,
                     l_payment_history_id,
                     l_accounting_event_id,
                     l_curr_calling_sequence);
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'Procedure Upg_Dist_Link_Insert complete';
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;
         END IF;

       EXCEPTION
         WHEN others THEN
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'Procedure Pay_Dist_Reverse raised exceptions';
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;
           NULL;
       END;
    END IF;
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

END Pay_Dist_Reverse;


----------------------------------------------------------------------------------
-- PROCEDURE Pay_Dist_Insert
-- This procedure is used to insert the payment hist distributions into the
-- ap_payment_hist_dists table
----------------------------------------------------------------------------------

PROCEDURE Pay_Dist_Insert
     (P_PD_Rec            IN     AP_PAYMENT_HIST_DISTS%ROWTYPE
     ,P_Calling_Sequence  IN     VARCHAR2
     ) IS

  l_curr_calling_sequence      VARCHAR2(2000);

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Pay_Dist_Insert';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;


BEGIN

  l_curr_calling_sequence := 'AP_ACCTG_PAY_DIST_PKG.Pay_Dist_Insert<- ' ||
                                     P_Calling_Sequence;


  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;


  INSERT INTO AP_Payment_Hist_Dists
        (Payment_Hist_Dist_ID,
         Accounting_Event_ID,
         Amount,
         Pay_Dist_Lookup_Code,
         Payment_History_ID,
         Invoice_Distribution_ID,
         Invoice_Payment_ID,
         Bank_Curr_Amount,
         Cleared_Base_Amount,
         Invoice_Dist_Amount,
         Invoice_Dist_Base_Amount,
         Invoice_Adjustment_Event_ID,
         Matured_Base_Amount,
         Paid_Base_Amount,
         Reversal_Flag,
         Reversed_Pay_Hist_Dist_ID,
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
         Program_Login_ID,
         Program_Update_Date,
         Request_ID
         )
  VALUES (AP_Payment_Hist_Dists_S.nextval,
         P_PD_Rec.Accounting_Event_ID,
         P_PD_Rec.Amount,
         P_PD_Rec.Pay_Dist_Lookup_Code,
         P_PD_Rec.Payment_History_ID,
         P_PD_Rec.Invoice_Distribution_ID,
         P_PD_Rec.Invoice_Payment_ID,
         P_PD_Rec.Bank_Curr_Amount,
         P_PD_Rec.Cleared_Base_Amount,
         P_PD_Rec.Invoice_Dist_Amount,
         P_PD_Rec.Invoice_Dist_Base_Amount,
         P_PD_Rec.Invoice_Adjustment_Event_ID,
         P_PD_Rec.Matured_Base_Amount,
         P_PD_Rec.Paid_Base_Amount,
         P_PD_Rec.Reversal_Flag,
         P_PD_Rec.Reversed_Pay_Hist_Dist_ID,
         P_PD_Rec.AWT_Related_ID,
         'N',
         P_PD_Rec.Quantity_Variance,
         P_PD_Rec.Invoice_Base_Qty_Variance,
         P_PD_Rec.Amount_Variance,
         P_PD_Rec.Invoice_Base_Amt_Variance,
         FND_GLOBAL.User_ID,
         SYSDATE,
         SYSDATE,
         FND_GLOBAL.User_ID,
         FND_GLOBAL.User_ID,
         FND_GLOBAL.Prog_Appl_ID,
         FND_GLOBAL.Conc_Program_ID,
         NULL,
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

END Pay_Dist_Insert;



-- Bug 6839052. Added this procedure to delete and recreate the distribution
-- links by prorating the line amount to all the payment distributions
-- so that the transaction and distribution reversals use these new
-- distribution links with the right amounts
----------------------------------------------------------------------------------
-- PROCEDURE Upg_Dist_Links_Insert
-- This procedure is used to insert the payment hist distributions into the
-- ap_payment_hist_dists table
----------------------------------------------------------------------------------

PROCEDURE Upg_Dist_Links_Insert
           (p_xla_event_rec       IN  ap_accounting_pay_pkg.r_xla_event_info
           ,p_payment_history_id  IN  NUMBER
           ,p_accounting_event_id IN  NUMBER
           ,p_calling_sequence    IN  VARCHAR2
           ) IS

  l_curr_calling_sequence      VARCHAR2(2000);

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Upg_Dist_Links_Insert';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;


BEGIN

  l_curr_calling_sequence := 'AP_ACCTG_PAY_DIST_PKG.Upg_Dist_Links_Insert<- ' ||
                                     P_Calling_Sequence;


  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||
                      '.begin', l_log_msg);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Deleting xla_distribution_links';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

  DELETE FROM xla_distribution_links
  WHERE  application_id = 200
  AND    ae_header_id IN
              (SELECT ae_header_id
               FROM   xla_ae_headers aeh,
                      ap_payment_history_all aph
               WHERE  aeh.event_id = aph.accounting_event_id
               AND    aph.accounting_event_id = p_accounting_event_id
               AND    aph.check_id = p_xla_event_rec.source_id_int_1
               AND    aph.historical_flag = 'Y'
               AND    aeh.upg_batch_id IS NOT NULL)
  AND    upg_batch_id IS NOT NULL;


  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Inserting xla_distribution_links for event '||
                               p_accounting_event_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

-- Bug 8708433 This insert is for primary ledger id , hence the new join condition
-- AND    AEH.ledger_id = ASP.Set_Of_Books_ID
-- In this insert, we are prorating the amounts on the basis of the table
-- ap_invoice_distributions_all

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
	 --- changed for bug#7293021 start
	 APPLIED_TO_APPLICATION_ID,
         APPLIED_TO_ENTITY_ID,
         APPLIED_TO_DIST_ID_NUM_1,
         APPLIED_TO_DISTRIBUTION_TYPE
	 --- changed for bug#7293021 end
	 )
  SELECT 200,
         Accounting_Event_ID,
         AE_Header_ID,
         AE_Line_Num,
         'AP_PMT_DIST',
         Source_Distribution_ID_Num_1,
        (CASE
            WHEN Line_Entered_Cr IS NOT NULL THEN
               Decode(Rank_Num, Dist_Count, (Line_Entered_Amt - Sum_Entered_Amt) +
                           Entered_Amt, Entered_Amt)
            ELSE NULL
         END),
        (CASE
            WHEN Line_Entered_Dr IS NOT NULL THEN
               Decode(Rank_Num, Dist_Count, (Line_Entered_Amt - Sum_Entered_Amt) +
                           Entered_Amt, Entered_Amt)
            ELSE NULL
         END),
        (CASE
            WHEN Line_Accounted_Cr IS NOT NULL THEN
                 Decode(Rank_Num, Dist_Count, (Line_Accounted_Amt - Sum_Accounted_Amt) +
                           Accounted_Amt, Accounted_Amt)
            ELSE NULL
         END),
        (CASE
            WHEN Line_Accounted_Dr IS NOT NULL THEN
                 Decode(Rank_Num, Dist_Count, (Line_Accounted_Amt - Sum_Accounted_Amt) +
                           Accounted_Amt, Accounted_Amt)
            ELSE NULL
         END),
         Ref_AE_Header_ID,
        (CASE
             WHEN Payment_Type_Flag = 'R' THEN
                  DECODE(Accounting_Class_Code,
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
             WHEN Transaction_Type = 'PAYMENT MATURITY' THEN
                  DECODE(Accounting_Class_Code, 'FUTURE_DATED_PMT', 'AP_FUTURE_DATED_PMT_MAT',
                         'CASH_CLEARING', 'AP_CASH_CLEAR_PMT_MAT',
                         'CASH', 'AP_CASH_PMT_MAT', 'GAIN', 'AP_GAIN_PMT_MAT',
                         'LOSS', 'AP_LOSS_PMT_MAT', 'ROUNDING', 'AP_FUTURE_PMT_ROUNDING_MAT')
             WHEN Transaction_Type IN ('PAYMENT CREATED', 'PAYMENT CANCELLED') THEN
                  DECODE(Accounting_Class_Code, 'FUTURE_DATED_PMT', 'AP_FUTURE_DATED_PMT',
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
             WHEN Transaction_Type IN ('PAYMENT CLEARING', 'PAYMENT UNCLEARING') THEN
                  DECODE(Accounting_Class_Code, 'BANK_CHG', 'AP_BANK_CHARGES_CLEAR',
                         'CASH_CLEARING', 'AP_CASH_CLEAR_CLEAR', 'CASH', 'AP_CASH_CLEAR',
                         'ACCRUAL', 'AP_ACCRUAL_CLEAR', 'DISCOUNT', 'AP_DISCOUNT_ACCR_CLEAR',
                         'EXCHANGE_RATE_VARIANCE', 'AP_EX_RATE_VAR_CLEAR',
                         'BANK_ERROR', 'AP_BANK_ERROR_CLEAR',
                         'ROUNDING', 'AP_FINAL_PMT_ROUNDING_CLEAR',
                         'GAIN', 'AP_GAIN_PMT_CLEAR', 'FREIGHT', 'AP_FREIGHT_EXPENSE_CLEAR',
                         'IPV', 'AP_INV_PRICE_VAR_CLEAR', 'ITEM EXPENSE', 'AP_ITEM_EXPENSE_CLEAR',
                         'LOSS', 'AP_LOSS_PMT_CLEAR', 'LIABILITY', 'AP_LIAB_CLEAR',
                         'NRTAX', 'AP_NON_RECOV_TAX_CLEAR', 'RTAX','AP_RECOV_TAX_CLEAR',
                         'AWT', 'AP_WITHHOLD_TAX_ACCR_CLEAR')
         END),
         'S',
         'A',  --changed by abhsaxen for bug#9073033
         Row_Number() OVER (PARTITION BY AE_Header_ID
                      ORDER BY AE_Line_Num,
                               Invoice_Distribution_ID,
                               Invoice_Payment_ID,
                               Payment_History_ID) Temp_Line_Num,
         Accounting_Event_ID,
         Upg_Batch_ID,
         'S',
         'ACCRUAL_PAYMENTS_ALL',
         'PAYMENTS',
         'PAYMENTS_ALL',
         -- changed for bug#7293021 start
         DECODE(Accounting_Class_Code, 'LIABILITY' ,200, null),
         DECODE(Accounting_Class_Code, 'LIABILITY' ,aid_Entity_id, null),
         DECODE(Accounting_Class_Code, 'LIABILITY' ,Invoice_Distribution_ID, null),
         'AP_INV_DIST'
         -- changed for bug#7293021 end
  FROM (
  SELECT Accounting_Event_ID,
         AE_Header_ID,
         AE_Line_Num,
         Line_Entered_Cr,
         Line_Entered_Dr,
         Line_Accounted_Cr,
         Line_Accounted_Dr,
         Invoice_Distribution_ID,
         Invoice_Payment_ID,
         Payment_History_ID,
         Upg_Batch_ID,
         Base_Currency_Code,
         Source_Distribution_ID_Num_1,
         Line_Entered_Amt,
         Line_Accounted_Amt,
         DECODE(FC.Minimum_Accountable_Unit, NULL,
            ROUND((Line_Accounted_Amt * Dist_Base_Amount
                  / DECODE(PDivisor_Acct_Amt, 0, 1, PDivisor_Acct_Amt)),
              FC.Precision),
            ROUND((Line_Accounted_Amt * Dist_Base_Amount
                  / DECODE(PDivisor_Acct_Amt, 0, 1, PDivisor_Acct_Amt))
              /FC.Minimum_Accountable_Unit) * FC.Minimum_Accountable_Unit) Accounted_Amt,
         DECODE(FC.Minimum_Accountable_Unit, NULL,
            ROUND((Line_Entered_Amt * Dist_Amount
                  / DECODE(PDivisor_Ent_Amt, 0 ,1, PDivisor_Ent_Amt)), FC.Precision),
            ROUND((Line_Entered_Amt * Dist_Amount
                  / DECODE(PDivisor_Acct_Amt, 0 ,1, PDivisor_Ent_Amt))
              /FC.Minimum_Accountable_Unit) * FC.Minimum_Accountable_Unit) Entered_Amt,
         Dist_Count,
         Rank_Num,
         SUM(DECODE(FC.Minimum_Accountable_Unit, NULL,
            ROUND((Line_Accounted_Amt * Dist_Base_Amount
                   / DECODE(PDivisor_Acct_Amt, 0, 1, PDivisor_Acct_Amt)),
                   FC.Precision),
            ROUND((Line_Accounted_Amt * Dist_Base_Amount
                   / DECODE(PDivisor_Acct_Amt, 0, 1, PDivisor_Acct_Amt))
              /FC.Minimum_Accountable_Unit) * FC.Minimum_Accountable_Unit))
            OVER (PARTITION BY Check_ID, Part_Key1, Part_Key2, AE_Line_Num)
                 Sum_Accounted_Amt,
         SUM(DECODE(FC.Minimum_Accountable_Unit, NULL,
              ROUND((Line_Entered_Amt * Dist_Amount
                  / DECODE(PDivisor_Ent_Amt, 0 ,1, PDivisor_Ent_Amt)), FC.Precision),
              ROUND((Line_Entered_Amt * Dist_Amount
                  / DECODE(PDivisor_Ent_Amt, 0 ,1, PDivisor_Ent_Amt))
               /FC.Minimum_Accountable_Unit) * FC.Minimum_Accountable_Unit))
            OVER (PARTITION BY Check_ID, Part_Key1, Part_Key2, AE_Line_Num) Sum_Entered_Amt,
         Ref_AE_Header_ID,
         Payment_Type_Flag,
         Transaction_Type,
         Accounting_Class_Code,
        aid_Entity_id  -- changed for bug#7293021
  FROM (
  SELECT AC.Check_ID Check_ID,
         AEH.Event_ID Accounting_Event_ID,
         AEH.AE_Header_ID AE_Header_ID,
         AEL.AE_Line_Num AE_Line_Num,
         AEL.Entered_Cr Line_Entered_Cr,
         AEL.Entered_Dr Line_Entered_Dr,
         AEL.Accounted_Cr Line_Accounted_Cr,
         AEL.Accounted_Dr Line_Accounted_Dr,
         APHD.Invoice_Distribution_ID Invoice_Distribution_ID,
         APHD.Invoice_Payment_ID Invoice_Payment_ID,
         APHD.Payment_History_ID Payment_History_ID,
         AEL.Upg_Batch_ID Upg_Batch_ID,
         ASP.Base_Currency_Code Base_Currency_Code,
         APHD.Payment_Hist_Dist_ID Source_Distribution_ID_Num_1,
         NVL(AEL.Entered_Cr, AEL.Entered_Dr) Line_Entered_Amt,
         NVL(AEL.Accounted_Cr, AEL.Accounted_Dr) Line_Accounted_Amt,
         AID.Amount Dist_Amount,
         NVL(AID.Base_Amount, AID.Amount) Dist_Base_Amount,
         COUNT(*) OVER (PARTITION BY AI.Invoice_ID, AID1.Invoice_Distribution_ID,
                                     AEL.AE_Line_Num) Dist_Count,
         RANK() OVER (PARTITION BY AI.Invoice_ID, AID1.Invoice_Distribution_ID,
                                   AEL.AE_Line_Num
                        ORDER BY AID.Amount,
                                 APHD.Invoice_Payment_Id,    --bug9307438
                                 AID.Invoice_distribution_id --bug8774970
                                           /*AID.Distribution_Line_Number*/) Rank_Num,
         AID1.Amount PDivisor_Ent_Amt,
         NVL(AID1.Base_Amount, AID1.Amount) PDivisor_Acct_Amt,
         AI.Invoice_ID Part_Key1,
         AID1.Invoice_Distribution_ID Part_Key2,
         AEH.AE_Header_ID Ref_AE_Header_ID,
         AC.Payment_Type_Flag Payment_Type_Flag,
         APH.Transaction_Type Transaction_Type,
         AEL.Accounting_Class_Code Accounting_Class_Code,
	 aid_xe.entity_id aid_Entity_id
  FROM   AP_Checks_All AC,
         AP_System_Parameters_All ASP,
         XLA_Transaction_Entities_Upg XTE,
         XLA_Events XLE,
         AP_Payment_History_All APH,
         XLA_AE_Headers AEH,
         XLA_AE_Lines AEL,
         AP_Inv_Dists_Source AID1,
         AP_Invoices_All AI,
         AP_Invoice_Distributions_All AID,
         AP_Payment_Hist_Dists APHD,
         xla_events aid_xe -- changed for bug#7293021
  WHERE  AC.Check_ID = p_xla_event_rec.source_id_int_1
  AND    AC.Org_ID = ASP.Org_ID
  AND    XLE.Event_ID = p_accounting_event_id
  AND    ASP.Set_Of_Books_ID = XTE.Ledger_ID
  AND    AEH.ledger_id       = ASP.Set_Of_Books_ID -- Bug#8708433
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
  AND    APH.Payment_History_ID = p_payment_history_id
  AND    APH.Payment_History_ID = APHD.Payment_History_ID
  AND    APHD.Invoice_Payment_ID = DECODE(AEL.Source_Table, 'AP_INVOICE_PAYMENTS',
                                            AEL.Source_ID, APHD.Invoice_Payment_ID)
  -- begin 8774970
  AND    NVL(AID.Old_Distribution_Id, AID.Invoice_Distribution_Id) =
              DECODE(AEL.Source_Table, 'AP_INVOICE_DISTRIBUTIONS',
                     AEL.Source_ID, NVL(AID.Old_Distribution_Id,APHD.Invoice_Distribution_Id))
  AND    AID.Invoice_Id = DECODE(AEL.Source_Table, 'AP_INVOICES',
                                 AEL.Source_ID, AID.Invoice_Id)
  AND    APH.Check_Id = DECODE(AEL.Source_Table, 'AP_CHECKS',
                               AEL.Source_ID, APH.Check_Id)
  -- end 8774970
  AND    APHD.Invoice_Distribution_ID = AID.Invoice_Distribution_ID
  AND    AEL.Account_Overlay_Source_ID = AID1.Invoice_Distribution_ID
  AND    AID1.Invoice_ID = AI.Invoice_ID
  AND    AID1.Invoice_Distribution_ID = AID.Old_Distribution_ID
  AND    aid_xe.application_id = 200 --- changed for bug#7293021
  AND    aid_xe.event_id    = aid.accounting_event_id
  UNION ALL
  SELECT AC.Check_ID Check_ID,
         AEH.Event_ID Accounting_Event_ID,
         AEH.AE_Header_ID AE_Header_ID,
         AEL.AE_Line_Num AE_Line_Num,
         AEL.Entered_Cr Line_Entered_Cr,
         AEL.Entered_Dr Line_Entered_Dr,
         AEL.Accounted_Cr Line_Accounted_Cr,
         AEL.Accounted_Dr Line_Accounted_Dr,
         APHD.Invoice_Distribution_ID Invoice_Distribution_ID,
         APHD.Invoice_Payment_ID Invoice_Payment_ID,
         APHD.Payment_History_ID Payment_History_ID,
         AEL.Upg_Batch_ID Upg_Batch_ID,
         ASP.Base_Currency_Code Base_Currency_Code,
         APHD.Payment_Hist_Dist_ID Source_Distribution_ID_Num_1,
         NVL(AEL.Entered_Cr, AEL.Entered_Dr) Line_Entered_Amt,
         NVL(AEL.Accounted_Cr, AEL.Accounted_Dr) Line_Accounted_Amt,
         AID.Amount Dist_Amount,
         NVL(AID.Base_Amount, AID.Amount) Dist_Base_Amount,
         COUNT(*) OVER (PARTITION BY AC.Check_ID,
                          DECODE(AEL.Source_Table, 'AP_CHECKS', 1, AI.Invoice_ID),
		          AEL.AE_Line_Num) Dist_Count,
         RANK() OVER (PARTITION BY AC.Check_ID, aeh.ae_header_id, -- bug 8638413
                          DECODE(AEL.Source_Table, 'AP_CHECKS', AC.Check_ID, AI.Invoice_ID),
		          AEL.AE_Line_Num
                      ORDER BY AID.Amount,
                               APHD.Invoice_Payment_Id,    --bug9307438
                               AID.Invoice_distribution_id --bug8774970
                                           /*AID.Distribution_Line_Number*/) Rank_Num,
         SUM(AID.Amount)
                OVER (PARTITION BY AC.Check_ID, aeh.ae_header_id, -- bug 8638413
                          DECODE(AEL.Source_Table, 'AP_CHECKS', 1, AI.Invoice_ID),
		          AEL.AE_Line_Num) PDivisor_Ent_Amt,
         SUM(NVL(AID.Base_Amount, AID.Amount))
                OVER (PARTITION BY AC.Check_ID, aeh.ae_header_id, -- bug 8638413
                          DECODE(AEL.Source_Table, 'AP_CHECKS', 1, AI.Invoice_ID),
		          AEL.AE_Line_Num) PDivisor_Acct_Amt,
         DECODE(AEL.Source_Table, 'AP_CHECKS', 1, AI.Invoice_ID) Part_Key1,
         1 Part_Key2,
         AEH.AE_Header_ID Ref_AE_Header_ID,
         AC.Payment_Type_Flag Payment_Type_Flag,
         APH.Transaction_Type Transaction_Type,
         AEL.Accounting_Class_Code Accounting_Class_Code,
	 aid_xe.entity_id aid_Entity_id --- changed for bug#7293021
  FROM   AP_Checks_All AC,
         AP_System_Parameters_All ASP,
         XLA_Transaction_Entities_Upg XTE,
         XLA_Events XLE,
         AP_Payment_History_All APH,
         XLA_AE_Headers AEH,
         XLA_AE_Lines AEL,
         AP_Payment_Hist_Dists APHD,
         AP_Invoice_Distributions_All AID,
         AP_Invoices_All AI,
	 xla_events aid_xe -- changed for bug#7293021
  WHERE  AC.Check_ID = p_xla_event_rec.source_id_int_1
  AND    AC.Org_ID = ASP.Org_ID
  AND    XLE.Event_ID = p_accounting_event_id
  AND    ASP.Set_Of_Books_ID = XTE.Ledger_ID
  AND    AEH.ledger_id       = ASP.Set_Of_Books_ID -- Bug#8708433
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
  AND    APH.Payment_History_ID = p_payment_history_id
  AND    APH.Payment_History_ID = APHD.Payment_History_ID
  AND    APHD.Invoice_Payment_ID = DECODE(AEL.Source_Table, 'AP_INVOICE_PAYMENTS',
                                            AEL.Source_ID, APHD.Invoice_Payment_ID)
  -- begin 8774970
  AND    NVL(AID.Old_Distribution_Id, AID.Invoice_Distribution_Id) =
              DECODE(AEL.Source_Table, 'AP_INVOICE_DISTRIBUTIONS',
                     AEL.Source_ID, NVL(AID.Old_Distribution_Id,APHD.Invoice_Distribution_Id))
  AND    AID.Invoice_Id = DECODE(AEL.Source_Table, 'AP_INVOICES',
                                 AEL.Source_ID, AID.Invoice_Id)
  AND    APH.Check_Id = DECODE(AEL.Source_Table, 'AP_CHECKS',
                               AEL.Source_ID, APH.Check_Id)
  -- end 8774970
  AND    AEL.Account_Overlay_Source_ID IS NULL
  AND    APHD.Invoice_Distribution_ID = AID.Invoice_Distribution_ID
  AND    AI.Invoice_ID = AID.Invoice_ID
  AND    aid_xe.application_id = 200 --- changed for bug#7293021
  AND    aid_xe.event_id    = aid.accounting_event_id
  AND DECODE(ael.accounting_class_code,'AWT','AWT','DISCOUNT','DISCOUNT',
	      aphd.pay_dist_lookup_code) = aphd.pay_dist_lookup_code --8293590
  AND decode(AEL.source_table, 'AP_CHECKS', AEL.Accounting_Class_Code, APHD.Pay_Dist_Lookup_Code)
         = decode(AEL.source_table, 'AP_CHECKS'
               ,decode(APHD.Pay_Dist_Lookup_Code,'AWT','AWT','DISCOUNT','DISCOUNT',
                    AEL.Accounting_Class_Code) ,APHD.Pay_Dist_Lookup_Code) --8293590

  ) ADL,
  FND_Currencies FC
  WHERE  FC.Currency_Code = ADL.Base_Currency_Code);


  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Done inserting into xla_distribution_links for primary ledger';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,
l_log_msg);
  END IF;

-- Bug 8708443 For all other non-primary ledgers, the proration of amounts
-- while inserting into xla_distribution_links should happen on the basis of
-- the amounts in the table ap_mc_invoice_dists, this is required becasue
-- if the primary ledger and the secondary ledger have a different currency,
-- then doing the proration for accounting entries of secondary ledger on the
-- basis of the amounts in ap_invoice_distributions_all, which is in another
-- currency would be wrong.

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
	 --- changed for bug#7293021 start
	 APPLIED_TO_APPLICATION_ID,
         APPLIED_TO_ENTITY_ID,
         APPLIED_TO_DIST_ID_NUM_1,
         APPLIED_TO_DISTRIBUTION_TYPE
	 --- changed for bug#7293021 end
	 )
 SELECT 200,
        Accounting_Event_ID,
        AE_Header_ID,
        AE_Line_Num,
        'AP_PMT_DIST',
        Source_Distribution_ID_Num_1,
       (CASE
           WHEN Line_Entered_Cr IS NOT NULL THEN
              Decode(Rank_Num, Dist_Count, (Line_Entered_Amt - Sum_Entered_Amt) +
                          Entered_Amt, Entered_Amt)
           ELSE NULL
        END),
       (CASE
           WHEN Line_Entered_Dr IS NOT NULL THEN
              Decode(Rank_Num, Dist_Count, (Line_Entered_Amt - Sum_Entered_Amt) +
                          Entered_Amt, Entered_Amt)
           ELSE NULL
        END),
       (CASE
           WHEN Line_Accounted_Cr IS NOT NULL THEN
                Decode(Rank_Num, Dist_Count, (Line_Accounted_Amt - Sum_Accounted_Amt) +
                          Accounted_Amt, Accounted_Amt)
           ELSE NULL
        END),
       (CASE
           WHEN Line_Accounted_Dr IS NOT NULL THEN
                Decode(Rank_Num, Dist_Count, (Line_Accounted_Amt - Sum_Accounted_Amt) +
                          Accounted_Amt, Accounted_Amt)
           ELSE NULL
        END),
        Ref_AE_Header_ID,
       (CASE
            WHEN Payment_Type_Flag = 'R' THEN
                 DECODE(Accounting_Class_Code,
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
            WHEN Transaction_Type = 'PAYMENT MATURITY' THEN
                 DECODE(Accounting_Class_Code, 'FUTURE_DATED_PMT', 'AP_FUTURE_DATED_PMT_MAT',
                        'CASH_CLEARING', 'AP_CASH_CLEAR_PMT_MAT',
                        'CASH', 'AP_CASH_PMT_MAT', 'GAIN', 'AP_GAIN_PMT_MAT',
                        'LOSS', 'AP_LOSS_PMT_MAT', 'ROUNDING', 'AP_FUTURE_PMT_ROUNDING_MAT')
            WHEN Transaction_Type IN ('PAYMENT CREATED', 'PAYMENT CANCELLED') THEN
                 DECODE(Accounting_Class_Code, 'FUTURE_DATED_PMT', 'AP_FUTURE_DATED_PMT',
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
            WHEN Transaction_Type IN ('PAYMENT CLEARING', 'PAYMENT UNCLEARING') THEN
                 DECODE(Accounting_Class_Code, 'BANK_CHG', 'AP_BANK_CHARGES_CLEAR',
                        'CASH_CLEARING', 'AP_CASH_CLEAR_CLEAR', 'CASH', 'AP_CASH_CLEAR',
                        'ACCRUAL', 'AP_ACCRUAL_CLEAR', 'DISCOUNT', 'AP_DISCOUNT_ACCR_CLEAR',
                        'EXCHANGE_RATE_VARIANCE', 'AP_EX_RATE_VAR_CLEAR',
                        'BANK_ERROR', 'AP_BANK_ERROR_CLEAR',
                        'ROUNDING', 'AP_FINAL_PMT_ROUNDING_CLEAR',
                        'GAIN', 'AP_GAIN_PMT_CLEAR', 'FREIGHT', 'AP_FREIGHT_EXPENSE_CLEAR',
                        'IPV', 'AP_INV_PRICE_VAR_CLEAR', 'ITEM EXPENSE', 'AP_ITEM_EXPENSE_CLEAR',
                        'LOSS', 'AP_LOSS_PMT_CLEAR', 'LIABILITY', 'AP_LIAB_CLEAR',
                        'NRTAX', 'AP_NON_RECOV_TAX_CLEAR', 'RTAX','AP_RECOV_TAX_CLEAR',
                        'AWT', 'AP_WITHHOLD_TAX_ACCR_CLEAR')
        END),
        'S',
         'A',  --changed by abhsaxen for bug#9073033
        Row_Number() OVER (PARTITION BY AE_Header_ID
                     ORDER BY AE_Line_Num,
                              Invoice_Distribution_ID,
                              Invoice_Payment_ID,
                              Payment_History_ID) Temp_Line_Num,
        Accounting_Event_ID,
        Upg_Batch_ID,
        'S',
        'ACCRUAL_PAYMENTS_ALL',
        'PAYMENTS',
        'PAYMENTS_ALL',
        -- changed for bug#7293021 start
        DECODE(Accounting_Class_Code, 'LIABILITY' ,200, null),
        DECODE(Accounting_Class_Code, 'LIABILITY' ,aid_Entity_id, null),
        DECODE(Accounting_Class_Code, 'LIABILITY' ,Invoice_Distribution_ID, null),
        'AP_INV_DIST'
FROM
  (
  SELECT Accounting_Event_ID,
         AE_Header_ID,
         AE_Line_Num,
         Line_Entered_Cr,
         Line_Entered_Dr,
         Line_Accounted_Cr,
         Line_Accounted_Dr,
         Invoice_Distribution_ID,
         Invoice_Payment_ID,
         Payment_History_ID,
         Upg_Batch_ID,
         Base_Currency_Code,
         Source_Distribution_ID_Num_1,
         Line_Entered_Amt,
         Line_Accounted_Amt,
         DECODE(FC.Minimum_Accountable_Unit, NULL,
            ROUND((Line_Accounted_Amt * Dist_Base_Amount
                  / DECODE(PDivisor_Acct_Amt, 0, 1, PDivisor_Acct_Amt)),
              FC.Precision),
            ROUND((Line_Accounted_Amt * Dist_Base_Amount
                  / DECODE(PDivisor_Acct_Amt, 0, 1, PDivisor_Acct_Amt))
              /FC.Minimum_Accountable_Unit) * FC.Minimum_Accountable_Unit) Accounted_Amt,
         DECODE(FC.Minimum_Accountable_Unit, NULL,
            ROUND((Line_Entered_Amt * Dist_Amount
                  / DECODE(PDivisor_Ent_Amt, 0 ,1, PDivisor_Ent_Amt)), FC.Precision),
            ROUND((Line_Entered_Amt * Dist_Amount
                  / DECODE(PDivisor_Acct_Amt, 0 ,1, PDivisor_Ent_Amt))
              /FC.Minimum_Accountable_Unit) * FC.Minimum_Accountable_Unit) Entered_Amt,
         Dist_Count,
         Rank_Num,
         SUM(DECODE(FC.Minimum_Accountable_Unit, NULL,
            ROUND((Line_Accounted_Amt * Dist_Base_Amount
                   / DECODE(PDivisor_Acct_Amt, 0, 1, PDivisor_Acct_Amt)),
                   FC.Precision),
            ROUND((Line_Accounted_Amt * Dist_Base_Amount
                   / DECODE(PDivisor_Acct_Amt, 0, 1, PDivisor_Acct_Amt))
              /FC.Minimum_Accountable_Unit) * FC.Minimum_Accountable_Unit))
            OVER (PARTITION BY Check_ID, Part_Key1, Part_Key2, AE_Line_Num)
                 Sum_Accounted_Amt,
         SUM(DECODE(FC.Minimum_Accountable_Unit, NULL,
              ROUND((Line_Entered_Amt * Dist_Amount
                  / DECODE(PDivisor_Ent_Amt, 0 ,1, PDivisor_Ent_Amt)), FC.Precision),
              ROUND((Line_Entered_Amt * Dist_Amount
                  / DECODE(PDivisor_Ent_Amt, 0 ,1, PDivisor_Ent_Amt))
               /FC.Minimum_Accountable_Unit) * FC.Minimum_Accountable_Unit))
            OVER (PARTITION BY Check_ID, Part_Key1, Part_Key2, AE_Line_Num) Sum_Entered_Amt,
         Ref_AE_Header_ID,
         Payment_Type_Flag,
         Transaction_Type,
         Accounting_Class_Code,
        aid_Entity_id
FROM
(
  SELECT AC.Check_ID Check_ID,
         AEH.Event_ID Accounting_Event_ID,
         AEH.AE_Header_ID AE_Header_ID,
         AEL.AE_Line_Num AE_Line_Num,
         AEL.Entered_Cr Line_Entered_Cr,
         AEL.Entered_Dr Line_Entered_Dr,
         AEL.Accounted_Cr Line_Accounted_Cr,
         AEL.Accounted_Dr Line_Accounted_Dr,
         APHD.Invoice_Distribution_ID Invoice_Distribution_ID,
         APHD.Invoice_Payment_ID Invoice_Payment_ID,
         APHD.Payment_History_ID Payment_History_ID,
         AEL.Upg_Batch_ID Upg_Batch_ID,
         ASP.Base_Currency_Code Base_Currency_Code,
         APHD.Payment_Hist_Dist_ID Source_Distribution_ID_Num_1,
         NVL(AEL.Entered_Cr, AEL.Entered_Dr) Line_Entered_Amt,
         NVL(AEL.Accounted_Cr, AEL.Accounted_Dr) Line_Accounted_Amt,
         AID_MC.Amount Dist_Amount,
         NVL(AID_MC.Base_Amount, AID_MC.Amount) Dist_Base_Amount,
         COUNT(*) OVER (PARTITION BY AC.Check_ID,
                          DECODE(AEL.Source_Table, 'AP_CHECKS', 1, AI.Invoice_ID),
		          AEL.AE_Line_Num) Dist_Count,
         RANK() OVER (PARTITION BY AC.Check_ID, aeh.ae_header_id, -- bug 8638413
                          DECODE(AEL.Source_Table, 'AP_CHECKS', AC.Check_ID, AI.Invoice_ID),
		          AEL.AE_Line_Num
                      ORDER BY AID_MC.Amount,
                               APHD.Invoice_Payment_Id,   --bug9307438
                               AID_MC.Invoice_distribution_id) Rank_Num,
         SUM(AID_MC.Amount)
                OVER (PARTITION BY AC.Check_ID, aeh.ae_header_id, -- bug 8638413
                          DECODE(AEL.Source_Table, 'AP_CHECKS', 1, AI.Invoice_ID),
		          AEL.AE_Line_Num) PDivisor_Ent_Amt,
         SUM(NVL(AID_MC.Base_Amount, AID_MC.Amount))
                OVER (PARTITION BY AC.Check_ID, aeh.ae_header_id, -- bug 8638413
                          DECODE(AEL.Source_Table, 'AP_CHECKS', 1, AI.Invoice_ID),
		          AEL.AE_Line_Num) PDivisor_Acct_Amt,
         DECODE(AEL.Source_Table, 'AP_CHECKS', 1, AI.Invoice_ID) Part_Key1,
         1 Part_Key2,
         AEH.AE_Header_ID Ref_AE_Header_ID,
         AC.Payment_Type_Flag Payment_Type_Flag,
         APH.Transaction_Type Transaction_Type,
         AEL.Accounting_Class_Code Accounting_Class_Code,
	 AID_xe.entity_id AID_Entity_id --- changed for bug#7293021
  FROM   AP_Checks_All AC,
         AP_System_Parameters_All ASP,
         XLA_Transaction_Entities_Upg XTE,
         XLA_Events XLE,
         AP_Payment_History_All APH,
         XLA_AE_Headers AEH,
         XLA_AE_Lines AEL,
         AP_Payment_Hist_Dists APHD,
         ap_mc_invoice_dists AID_MC,
         AP_Invoices_All AI,
	 xla_events AID_xe, -- changed for bug#7293021
	 ap_invoice_distributions_all aid
  WHERE  AC.Check_ID = p_xla_event_rec.source_id_int_1
  AND    AC.Org_ID = ASP.Org_ID
  AND    XLE.Event_ID = p_accounting_event_id
  AND    ASP.Set_Of_Books_ID = XTE.Ledger_ID
  AND    AEH.ledger_id <> ASP.Set_Of_Books_ID
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
  AND    APH.Payment_History_ID = p_payment_history_id
  AND    APH.Payment_History_ID = APHD.Payment_History_ID
  AND    APHD.Invoice_Payment_ID = DECODE(AEL.Source_Table, 'AP_INVOICE_PAYMENTS',
                                            AEL.Source_ID, APHD.Invoice_Payment_ID)
  -- begin 8774970
  AND    NVL(AID.Old_Distribution_Id, AID.Invoice_Distribution_Id) =
              DECODE(AEL.Source_Table, 'AP_INVOICE_DISTRIBUTIONS',
                     AEL.Source_ID, NVL(AID.Old_Distribution_Id,APHD.Invoice_Distribution_Id))
  AND    AID.Invoice_Id = DECODE(AEL.Source_Table, 'AP_INVOICES',
                                 AEL.Source_ID, AID.Invoice_Id)
  AND    APH.Check_Id = DECODE(AEL.Source_Table, 'AP_CHECKS',
                               AEL.Source_ID, APH.Check_Id)
  -- end 8774970
  AND    AEL.Account_Overlay_Source_ID IS NULL
  AND    APHD.Invoice_Distribution_ID = AID_MC.Invoice_Distribution_ID
  AND    AI.Invoice_ID = AID_MC.Invoice_ID
  AND    AID_MC.set_of_books_id = AEH.ledger_id
  AND    AID_xe.application_id = 200 --- changed for bug#7293021
  AND    AID_xe.event_id    = AID.accounting_event_id
  AND    AID.invoice_distribution_id = AID_MC.Invoice_Distribution_ID
  AND DECODE(ael.accounting_class_code,'AWT','AWT','DISCOUNT','DISCOUNT',
	      aphd.pay_dist_lookup_code) = aphd.pay_dist_lookup_code --8293590
  AND decode(AEL.source_table, 'AP_CHECKS', AEL.Accounting_Class_Code, APHD.Pay_Dist_Lookup_Code)
         = decode(AEL.source_table, 'AP_CHECKS'
               ,decode(APHD.Pay_Dist_Lookup_Code,'AWT','AWT','DISCOUNT','DISCOUNT',
                    AEL.Accounting_Class_Code) ,APHD.Pay_Dist_Lookup_Code)
) ADL,
  FND_Currencies FC
WHERE  FC.Currency_Code = ADL.Base_Currency_Code );

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Done inserting into xla_distribution_links for non-primary ledgers';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,
l_log_msg);
  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'End of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end',
l_log_msg);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Upg_Dist_Links_Insert;


END AP_ACCTG_PAY_DIST_PKG;

/
