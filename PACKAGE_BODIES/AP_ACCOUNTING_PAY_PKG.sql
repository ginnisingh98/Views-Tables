--------------------------------------------------------
--  DDL for Package Body AP_ACCOUNTING_PAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_ACCOUNTING_PAY_PKG" AS
/* $Header: apacpayb.pls 120.12.12010000.17 2010/03/31 20:51:39 gagrawal ship $ */

-- Logging Infra
G_CURRENT_RUNTIME_LEVEL      NUMBER                := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME                CONSTANT VARCHAR2(50) := 'AP.PLSQL.AP_ACCOUNTING_PAY_PKG.';
-- Logging Infra

-------------------------------------------------------------------------------
-- PROCEDURE  Do_Pay_Accounting
-- Selects Payment Events for processing. Calls the Payment Dists and Prepay Appl
-- Dists Generator for creating Payment and Prepay Appl dists. Single point of
-- entry for Payment processing.
--
--------------------------------------------------------------------------------
PROCEDURE Do_Pay_Accounting
     (P_Calling_Sequence     IN   VARCHAR2
     ) IS

  l_xla_event_rec            r_xla_event_info;
  l_curr_calling_sequence    VARCHAR2(2000);
  l_check_curr_code          ap_checks_all.currency_code%type; --8288996

  CURSOR   xla_events_cur IS
  SELECT   Event_ID,
           Event_Type_Code,
           Event_Date,
           Event_Number,
           Event_Status_Code,
           Entity_Code,
           Source_ID_Int_1
  FROM     XLA_Events_GT
  WHERE   (Entity_Code = 'AP_PAYMENTS'
           OR Event_Type_Code IN ('PREPAYMENT APPLIED',
                                  'PREPAYMENT UNAPPLIED',
                                  'PREPAYMENT APPLICATION ADJ'))
  AND      Event_Status_Code <> 'N'
  ORDER BY Event_ID;

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Do_Pay_Accounting';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  l_curr_calling_sequence := 'AP_Accounting_Pay_Pkg.Do_Pay_Accounting<- ' ||
                                      p_calling_sequence;

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Calling procedure AP_Acctg_Pay_Dist_Pkg.Primary_Pay_Events';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  -- We need to delete the payment hist distributions and prepay appl hist distributions
  -- which were created during the draft mode of the accounting process
  -------------------------------------------------------------------------------

  Delete_Hist_Dists (l_curr_calling_sequence);


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Procedure AP_Acctg_Pay_Dist_Pkg.Primary_Pay_Events executed';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

  OPEN xla_events_cur;
  LOOP

       FETCH xla_events_cur INTO l_xla_event_rec;
       EXIT WHEN xla_events_cur%NOTFOUND OR
                 xla_events_cur%NOTFOUND IS NULL;


       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'CUR: xla_events_cur: entity_code = '|| l_xla_event_rec.entity_code
                        || ' document_id = ' || l_xla_event_rec.source_id_int_1;
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       -- Get the base currency code into global variable
       IF (l_xla_event_rec.entity_code = 'AP_PAYMENTS') THEN

           SELECT ASP.Base_Currency_Code, AC.Currency_Code --8288996
           INTO   g_base_currency_code, l_check_curr_code
           FROM   AP_System_Parameters_All ASP,
                  AP_Checks_All AC
           WHERE  AC.Check_ID = l_xla_event_rec.source_id_int_1
           AND    AC.Org_ID = ASP.Org_ID;

       ELSE

           SELECT ASP.Base_Currency_Code
           INTO   g_base_currency_code
           FROM   AP_System_Parameters_All ASP,
                  AP_Invoices_All AI
           WHERE  AI.Invoice_ID = l_xla_event_rec.source_id_int_1
           AND    AI.Org_ID = ASP.Org_ID;

       END IF;


       -- Based on the event type calling the appropriate event procedures
       -- to create payment and prepayment distributions.
       IF (l_xla_event_rec.event_type_code IN ('PAYMENT CREATED',
                                               'PAYMENT MATURED',
                                               'PAYMENT CLEARED',
                                               'REFUND RECORDED')) THEN

           IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
               l_log_msg := 'Calling procedure AP_Acctg_Pay_Dist_Pkg.Primary_Pay_Events';
               FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;


           AP_Acctg_Pay_Dist_Pkg.Primary_Pay_Events
                                  (l_xla_event_rec,
                                   l_curr_calling_sequence);


           IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
               l_log_msg := 'Procedure AP_Acctg_Pay_Dist_Pkg.Primary_Pay_Events executed';
               FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;

       ELSIF l_xla_event_rec.event_type_code IN ('MANUAL PAYMENT ADJUSTED',
                                                 'UPGRADED MANUAL PMT ADJUSTED') THEN

             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                 l_log_msg := 'Calling procedure AP_Acctg_Pay_Dist_Pkg.Manual_Pay_Adj_Events';
                 FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

             AP_Acctg_Pay_Dist_Pkg.Manual_Pay_Adj_Events
                                  (l_xla_event_rec,
                                   l_curr_calling_sequence);

             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                 l_log_msg := 'Procedure AP_Acctg_Pay_Dist_Pkg.Manual_Pay_Adj_Events executed';
                 FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

       ELSIF l_xla_event_rec.event_type_code IN ('PAYMENT ADJUSTED',
                                                 'PAYMENT MATURITY ADJUSTED',
                                                 'PAYMENT CLEARING ADJUSTED',
                                                 'REFUND ADJUSTED') THEN

             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                 l_log_msg := 'Calling procedure AP_Acctg_Pay_Dist_Pkg.Pay_Dist_Cascade_Adj_Events';
                 FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

             AP_Acctg_Pay_Dist_Pkg.Pay_Dist_Cascade_Adj_Events
                                  (l_xla_event_rec,
                                   l_curr_calling_sequence);

             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                 l_log_msg := 'Procedure AP_Acctg_Pay_Dist_Pkg.Pay_Dist_Cascade_Adj_Events executed';
                 FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

       ELSIF l_xla_event_rec.event_type_code IN ('PAYMENT CANCELLED',
                                                 'PAYMENT MATURITY REVERSED',
                                                 'PAYMENT UNCLEARED',
                                                 'REFUND CANCELLED') THEN

             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                 l_log_msg := 'Calling procedure AP_Acctg_Pay_Dist_Pkg.Cancel_Primary_Pay_Events';
                 FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

             AP_Acctg_Pay_Dist_Pkg.Cancel_Primary_Pay_Events
                                  (l_xla_event_rec,
                                   l_curr_calling_sequence);


             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                 l_log_msg := 'Procedure AP_Acctg_Pay_Dist_Pkg.Cancel_Primary_Pay_Events executed';
                 FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

       ELSIF l_xla_event_rec.event_type_code IN ('PREPAYMENT APPLICATION ADJ') THEN

             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                 l_log_msg := 'Calling procedure AP_Acctg_Prepay_Dist_Pkg.Prepay_Dist_Cascade_Adj';
                 FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

             AP_Acctg_Prepay_Dist_Pkg.Prepay_Dist_Cascade_Adj
                                  (l_xla_event_rec,
                                   l_curr_calling_sequence);

             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                 l_log_msg := 'Procedure AP_Acctg_Prepay_Dist_Pkg.Prepay_Dist_Cascade_Adj executed';
                 FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

       ELSIF l_xla_event_rec.event_type_code IN ('PREPAYMENT APPLIED',
                                                 'PREPAYMENT UNAPPLIED') THEN

             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                 l_log_msg := 'Calling procedure AP_Acctg_Prepay_Dist_Pkg.Update_Gain_Loss_Ind';
                 FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

             AP_Acctg_Prepay_Dist_Pkg.Update_Gain_Loss_Ind
                                  (l_xla_event_rec,
                                   l_curr_calling_sequence);

             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                 l_log_msg := 'Procedure AP_Acctg_Prepay_Dist_Pkg.Updated_Gain_Loss_Ind executed';
                 FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

       END IF;

       -- Added 8288996
       IF (l_xla_event_rec.event_type_code IN ('PAYMENT CREATED')
                                               --'PAYMENT MATURED',
                                               --'PAYMENT CLEARED')
		   AND g_base_currency_code <> l_check_curr_code ) THEN
         /* Restricting the Fix only to Payment Created
            When ever customers reported for Payment Maturity or Payment Clearing
            then just remove the conditions 1=2. Becuase of huge JLT changes now the
            fix is restricted to Payment Created. When ever the contions 1=2 are removed
            please make sure that JLT's are also Handeled */
	--Bug 8670681

             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                 l_log_msg := 'Calling procedure AP_ACCTG_PAY_ROUND_PKG.Final_Cash';
                 FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

             AP_ACCTG_PAY_ROUND_PKG.Final_Cash
                                  (l_xla_event_rec,
                                   l_curr_calling_sequence);

             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
                 l_log_msg := 'Procedure procedure AP_ACCTG_PAY_ROUND_PKG.Final_Cash executed';
                 FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

       END IF; --8288996 ends

  END LOOP;
  CLOSE xla_events_cur;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'End of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
  END IF;

  -- Commenting out the commit since the commit is issued during the post processing of the
  -- accounting process
  -- COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Do_Pay_Accounting;


-------------------------------------------------------------------------------
-- PROCEDURE Delete_Hist_Dists
-- Procedure to delete the payment history distributions and prepayment
-- application distributions.
--
--------------------------------------------------------------------------------
PROCEDURE Delete_Hist_Dists
     (P_Calling_Sequence     IN   VARCHAR2
     ) IS

  l_curr_calling_sequence    VARCHAR2(2000);

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Do_Pay_Accounting';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  l_curr_calling_sequence := 'AP_Accounting_Pay_Pkg.Do_Pay_Accounting<- ' ||
                                      p_calling_sequence;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;


  -- Bug 5098657. Added the where condition for both the delete statements
  DELETE FROM AP_Payment_Hist_Dists
  WHERE  Accounting_Event_ID IN
                   (SELECT Event_ID
                    FROM   XLA_Events_GT
                    WHERE  Entity_Code = 'AP_PAYMENTS');

  DELETE FROM AP_Prepay_App_Dists
  WHERE  Accounting_Event_ID IN
                   (SELECT Event_ID
                    FROM   XLA_Events_GT
                    WHERE  Event_Type_Code IN ('PREPAYMENT APPLICATION ADJ'));


EXCEPTION

  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Delete_Hist_Dists;



-------------------------------------------------------------------------------
-- Function Get_Casc_Pay_Sum
-- This function gets the sum of the payment amount from the payment history
-- distributions for the given invoice distribution which will be used for
-- payment cascase events
--
--------------------------------------------------------------------------------
FUNCTION Get_Casc_Pay_Sum
     (P_Invoice_Distribution_ID    IN    NUMBER
     ,P_Related_Event_ID           IN    NUMBER
     ,P_Invoice_Payment_ID         IN    NUMBER
     ,P_Calling_Sequence           IN    VARCHAR2
     ) RETURN NUMBER IS

  l_curr_calling_sequence       VARCHAR2(2000);
  l_pay_sum                     NUMBER;

BEGIN

  l_curr_calling_sequence := 'AP_ACCOUNTING_PAY_PKG.Get_Casc_Pay_Sum<- ' ||
                                         P_Calling_Sequence;



  SELECT SUM(APHD.Amount)
  INTO   l_pay_sum
  FROM   AP_Payment_Hist_Dists APHD,
         AP_Payment_History_All APH
  WHERE  APHD.Invoice_Distribution_ID = P_Invoice_Distribution_ID
  AND    APHD.Invoice_Payment_ID = P_Invoice_Payment_ID
  AND    APH.Related_Event_ID = P_Related_Event_ID
  AND    APHD.Payment_History_ID = APH.Payment_History_ID
  AND    APH.Posted_Flag <> 'N'                 -- changed for bug 7560247
  AND    APHD.Pay_Dist_Lookup_Code = 'CASH';

  RETURN NVL(l_pay_sum,0);

END Get_Casc_Pay_Sum;


-------------------------------------------------------------------------------
-- Function Get_Casc_Inv_Dist_Sum
-- This function gets the sum of the paid amount in invoice currency from the
-- payment history distributions for the given invoice distribution which will
-- be used for payment cascase events
--
--------------------------------------------------------------------------------
FUNCTION Get_Casc_Inv_Dist_Sum
     (P_Invoice_Distribution_ID    IN    NUMBER
     ,P_Related_Event_ID           IN    NUMBER
     ,P_Invoice_Payment_ID         IN    NUMBER
     ,P_Calling_Sequence           IN    VARCHAR2
     ) RETURN NUMBER IS

  l_curr_calling_sequence       VARCHAR2(2000);
  l_inv_dist_sum                NUMBER;

BEGIN

  l_curr_calling_sequence := 'AP_ACCOUNTING_PAY_PKG.Get_Casc_Pay_Sum<- ' ||
                                         P_Calling_Sequence;



  SELECT SUM(APHD.Invoice_Dist_Amount)
  INTO   l_inv_dist_sum
  FROM   AP_Payment_Hist_Dists APHD,
         AP_Payment_History_All APH
  WHERE  APHD.Invoice_Distribution_ID = P_Invoice_Distribution_ID
  AND    APHD.Invoice_Payment_ID = P_Invoice_Payment_ID
  AND    APH.Related_Event_ID = P_Related_Event_ID
  AND    APHD.Payment_History_ID = APH.Payment_History_ID
  AND    APH.Posted_Flag <> 'N'                 -- changed for bug 7560247
  AND    APHD.Pay_Dist_Lookup_Code = 'CASH';

  RETURN NVL(l_inv_dist_sum,0);

END Get_Casc_Inv_Dist_Sum;



-------------------------------------------------------------------------------
-- Function Get_Casc_Bank_Curr_Sum
-- This function gets the sum of the paid amount in the bank currency from the
-- payment history distributions for the given invoice distribution which will
-- be used for payment cascase events
--
--------------------------------------------------------------------------------
FUNCTION Get_Casc_Bank_Curr_Sum
     (P_Invoice_Distribution_ID    IN    NUMBER
     ,P_Related_Event_ID           IN    NUMBER
     ,P_Invoice_Payment_ID         IN    NUMBER
     ,P_Calling_Sequence           IN    VARCHAR2
     ) RETURN NUMBER IS

  l_curr_calling_sequence       VARCHAR2(2000);
  l_bank_curr_sum               NUMBER;

BEGIN

  l_curr_calling_sequence := 'AP_ACCOUNTING_PAY_PKG.Get_Casc_Pay_Sum<- ' ||
                                         P_Calling_Sequence;


  SELECT SUM(APHD.Bank_Curr_Amount)
  INTO   l_bank_curr_sum
  FROM   AP_Payment_Hist_Dists APHD,
         AP_Payment_History_All APH
  WHERE  APHD.Invoice_Distribution_ID = P_Invoice_Distribution_ID
  AND    APHD.Invoice_Payment_ID = P_Invoice_Payment_ID
  AND    APH.Related_Event_ID = P_Related_Event_ID
  AND    APHD.Payment_History_ID = APH.Payment_History_ID
  AND    APH.Posted_Flag <> 'N'                 -- changed for bug 7560247
  AND    APHD.Pay_Dist_Lookup_Code = 'CASH';

  RETURN NVL(l_bank_curr_sum,0);

END Get_Casc_Bank_Curr_Sum;



-------------------------------------------------------------------------------
-- Function Get_Casc_Prepay_Sum
-- This function gets the sum of the prepayment amount from the prepay appl payment
-- distributions for the given invoice distribution which will be used for
-- prepayment appl cascase events
--
--------------------------------------------------------------------------------
FUNCTION Get_Casc_Prepay_Sum
     (P_Invoice_Distribution_ID    IN    NUMBER
     ,P_Prepay_App_Dist_ID         IN    NUMBER
     ,P_Calling_Sequence           IN    VARCHAR2
     ) RETURN NUMBER IS

  l_curr_calling_sequence       VARCHAR2(2000);
  l_prepay_sum                  NUMBER;

BEGIN

  l_curr_calling_sequence := 'AP_ACCOUNTING_PAY_PKG.Get_Casc_Prepay_Sum<- ' ||
                                         P_Calling_Sequence;


  SELECT SUM(APAD.Amount)
  INTO   l_prepay_sum
  FROM   AP_Prepay_App_Dists APAD
  WHERE  APAD.Invoice_Distribution_ID = P_Invoice_Distribution_ID
  AND    APAD.Prepay_App_Distribution_ID = P_Prepay_App_Dist_ID
  AND    APAD.Prepay_Dist_Lookup_Code IN ('PREPAY APPL', 'PREPAY APPL REC TAX',
                                          'PREPAY APPL NONREC TAX', 'AWT',
                                          'EXCHANGE RATE VARIANCE');

  RETURN NVL(l_prepay_sum,0);

END Get_Casc_Prepay_Sum;


-------------------------------------------------------------------------------
-- Function Get_Casc_Tax_Diff_Sum
-- This function gets the sum of the tax diff amount from the prepay appl payment
-- distributions for the given invoice distribution which will be used for
-- prepayment appl cascase events
--
--------------------------------------------------------------------------------
FUNCTION Get_Casc_Tax_Diff_Sum
     (P_Invoice_Distribution_ID    IN    NUMBER
     ,P_Prepay_App_Dist_ID         IN    NUMBER
     ,P_Calling_Sequence           IN    VARCHAR2
     ) RETURN NUMBER IS

  l_curr_calling_sequence       VARCHAR2(2000);
  l_tax_diff_sum                NUMBER;

BEGIN

  l_curr_calling_sequence := 'AP_ACCOUNTING_PAY_PKG.Get_Casc_Prepay_Sum<- ' ||
                                         P_Calling_Sequence;


  SELECT SUM(APAD.Amount)
  INTO   l_tax_diff_sum
  FROM   AP_Prepay_App_Dists APAD
  WHERE  APAD.Invoice_Distribution_ID = P_Invoice_Distribution_ID
  AND    APAD.Prepay_App_Distribution_ID = P_Prepay_App_Dist_ID
  AND    APAD.Prepay_Dist_Lookup_Code IN ('TAX DIFF');

  RETURN NVL(l_tax_diff_sum,0);

END Get_Casc_Tax_Diff_Sum;



-------------------------------------------------------------------------------
-- Function Get_Casc_Discount_Sum
-- This function gets the sum of the discount amounts from the payment history
-- distributions for the given invoice distribution which will be used for
-- payment cascase events
--
--------------------------------------------------------------------------------
FUNCTION Get_Casc_Discount_Sum
     (P_Invoice_Distribution_ID    IN    NUMBER
     ,P_Related_Event_ID           IN    NUMBER
     ,P_Invoice_Payment_ID         IN    NUMBER
     ,P_Calling_Sequence           IN    VARCHAR2
     ) RETURN NUMBER IS

  l_curr_calling_sequence       VARCHAR2(2000);
  l_discount_sum                NUMBER;

BEGIN

  l_curr_calling_sequence := 'AP_ACCOUNTING_PAY_PKG.Get_Casc_Discount_Sum<- ' ||
                                         P_Calling_Sequence;


  SELECT SUM(APHD.Amount)
  INTO   l_discount_sum
  FROM   AP_Payment_Hist_Dists APHD,
         AP_Payment_History_All APH
  WHERE  APHD.Invoice_Distribution_ID = P_Invoice_Distribution_ID
  AND    APHD.Invoice_Payment_ID = P_Invoice_Payment_ID
  AND    APH.Related_Event_ID = P_Related_Event_ID
  AND    APHD.Payment_History_ID = APH.Payment_History_ID
  AND    APH.Posted_Flag <> 'N'                 -- changed for bug 7560247
  AND    Pay_Dist_Lookup_Code = 'DISCOUNT';

  RETURN NVL(l_discount_sum,0);

END Get_Casc_Discount_Sum;


-------------------------------------------------------------------------------
-- Function Get_Casc_Inv_Dist_Disc_Sum
-- This function gets the sum of the discount amounts from the payment history
-- distributions for the given invoice distribution which will be used for
-- payment cascase events
--
--------------------------------------------------------------------------------
FUNCTION Get_Casc_Inv_Dist_Disc_Sum
     (P_Invoice_Distribution_ID    IN    NUMBER
     ,P_Related_Event_ID           IN    NUMBER
     ,P_Invoice_Payment_ID         IN    NUMBER
     ,P_Calling_Sequence           IN    VARCHAR2
     ) RETURN NUMBER IS

  l_curr_calling_sequence       VARCHAR2(2000);
  l_discount_sum                NUMBER;

BEGIN

  l_curr_calling_sequence := 'AP_ACCOUNTING_PAY_PKG.Get_Casc_Discount_Sum<- ' ||
                                         P_Calling_Sequence;


  SELECT SUM(APHD.Invoice_Dist_Amount)
  INTO   l_discount_sum
  FROM   AP_Payment_Hist_Dists APHD,
         AP_Payment_History_All APH
  WHERE  APHD.Invoice_Distribution_ID = P_Invoice_Distribution_ID
  AND    APHD.Invoice_Payment_ID = P_Invoice_Payment_ID
  AND    APH.Related_Event_ID = P_Related_Event_ID
  AND    APHD.Payment_History_ID = APH.Payment_History_ID
  AND    APH.Posted_Flag <> 'N'                 -- changed for bug 7560247
  AND    Pay_Dist_Lookup_Code = 'DISCOUNT';

  RETURN NVL(l_discount_sum,0);

END Get_Casc_Inv_Dist_Disc_Sum;



-------------------------------------------------------------------------------
-- Function Get_Casc_Bank_Curr_Disc_Sum
-- This function gets the sum of the discount amounts from the payment history
-- distributions for the given invoice distribution which will be used for
-- payment cascase events
--
--------------------------------------------------------------------------------
FUNCTION Get_Casc_Bank_Curr_Disc_Sum
     (P_Invoice_Distribution_ID    IN    NUMBER
     ,P_Related_Event_ID           IN    NUMBER
     ,P_Invoice_Payment_ID         IN    NUMBER
     ,P_Calling_Sequence           IN    VARCHAR2
     ) RETURN NUMBER IS

  l_curr_calling_sequence       VARCHAR2(2000);
  l_discount_sum                NUMBER;

BEGIN

  l_curr_calling_sequence := 'AP_ACCOUNTING_PAY_PKG.Get_Casc_Discount_Sum<- ' ||
                                         P_Calling_Sequence;


  SELECT SUM(APHD.Bank_Curr_Amount)
  INTO   l_discount_sum
  FROM   AP_Payment_Hist_Dists APHD,
         AP_Payment_History_All APH
  WHERE  APHD.Invoice_Distribution_ID = P_Invoice_Distribution_ID
  AND    APHD.Invoice_Payment_ID = P_Invoice_Payment_ID
  AND    APH.Related_Event_ID = P_Related_Event_ID
  AND    APHD.Payment_History_ID = APH.Payment_History_ID
  AND    APH.Posted_Flag <> 'N'                 -- changed for bug 7560247
  AND    Pay_Dist_Lookup_Code = 'DISCOUNT';

  RETURN NVL(l_discount_sum,0);

END Get_Casc_Bank_Curr_Disc_Sum;



-------------------------------------------------------------------------------
-- Procedure Get_Pay_Sum
-- This procedure gets the sum of the payment amount from the payment history
-- distributions for the given invoice distribution
-- Modified history
-- 1. for bug 5570002, modify the condition of APH.posted_flag to "Y"
--------------------------------------------------------------------------------
PROCEDURE Get_Pay_Sum
     (P_Invoice_Distribution_ID    IN          NUMBER
     ,P_Transaction_Type           IN          VARCHAR2
     ,P_Payment_Sum                OUT NOCOPY  NUMBER
     ,P_Inv_Dist_Sum               OUT NOCOPY  NUMBER
     ,P_Bank_Curr_Sum              OUT NOCOPY  NUMBER
     ,P_Calling_Sequence           IN          VARCHAR2
     ) IS

  l_curr_calling_sequence       VARCHAR2(2000);
  l_pay_sum                     NUMBER;
  l_inv_dist_sum                NUMBER;
  l_bank_curr_sum               NUMBER;

BEGIN

  l_curr_calling_sequence := 'AP_ACCOUNTING_PAY_PKG.Get_Pay_Sum<- ' ||
                                         P_Calling_Sequence;

  IF (P_Transaction_Type IN ('PAYMENT CLEARED', 'PAYMENT CLEARING ADJUSTED')) THEN

      SELECT SUM(APHD.Amount),
             SUM(APHD.Invoice_Dist_Amount),
             SUM(APHD.Bank_Curr_Amount)
      INTO   l_pay_sum,
             l_inv_dist_sum,
             l_bank_curr_sum
      FROM   AP_Payment_Hist_Dists APHD,
             AP_Payment_History_All APH
      WHERE  APHD.Invoice_Distribution_ID in ( /*bug8882706*/
			   select p_invoice_distribution_id from dual
                            union
                           -- awt distributions which are applied on the p_invoice_distribution_id
                           select distinct aid_awt.invoice_distribution_id
                             from ap_invoice_distributions_all aid_awt,
                                  ap_invoice_distributions_all aid_item
                            where 1=1
                              and aid_item.invoice_distribution_id = p_invoice_distribution_id
			      and aid_item.line_type_lookup_code <> 'AWT'
                              and aid_awt.invoice_id = aid_item.invoice_id
                              and aid_awt.awt_related_id = aid_item.invoice_distribution_id
                              and aid_awt.line_type_lookup_code = 'AWT'
                             )
      AND    APHD.Pay_Dist_Lookup_Code IN ('CASH', 'DISCOUNT', 'AWT')
      AND    NVL(APH.Posted_Flag, 'N') IN ('Y', 'S')  		--bug 7614480, added status 'S'
      AND    APH.Payment_History_ID = APHD.Payment_History_ID
      AND    APH.Transaction_Type IN ('PAYMENT CLEARING', 'PAYMENT UNCLEARING',
                                      'PAYMENT CLEARING ADJUSTED')
      AND NOT EXISTS (SELECT 'Event Reversed'
                      FROM   AP_PAYMENT_HISTORY_ALL APH_REL
                      WHERE  APH_REL.check_id = APH.check_id --bug9282163
                      AND    NVL(APH_REL.RELATED_EVENT_ID, APH_REL.ACCOUNTING_EVENT_ID) =
                                          NVL(APH.RELATED_EVENT_ID, APH.ACCOUNTING_EVENT_ID)
                      AND    APH_REL.REV_PMT_HIST_ID IS NOT NULL);
      --bug8975671, reversed entries and their reversals shouldn't be considered
  ELSIF (P_Transaction_Type IN ('PAYMENT MATURED', 'PAYMENT MATURITY ADJUSTED')) THEN

      SELECT SUM(APHD.Amount),
             SUM(APHD.Invoice_Dist_Amount),
             SUM(APHD.Bank_Curr_Amount)
      INTO   l_pay_sum,
             l_inv_dist_sum,
             l_bank_curr_sum
      FROM   AP_Payment_Hist_Dists APHD,
             AP_Payment_History_All APH
      WHERE  APHD.Invoice_Distribution_ID in ( /*bug8882706*/
			   select p_invoice_distribution_id from dual
                            union
                           -- awt distributions which are applied on p_invoice_distribution_id
                           select distinct aid_awt.invoice_distribution_id
                             from ap_invoice_distributions_all aid_awt,
                                  ap_invoice_distributions_all aid_item
                            where 1=1
                              and aid_item.invoice_distribution_id = p_invoice_distribution_id
			      and aid_item.line_type_lookup_code <> 'AWT'
                              and aid_awt.invoice_id = aid_item.invoice_id
                              and aid_awt.awt_related_id = aid_item.invoice_distribution_id
                              and aid_awt.line_type_lookup_code = 'AWT'
                             )
      AND    APHD.Pay_Dist_Lookup_Code IN ('CASH', 'DISCOUNT', 'AWT') -- bug8882706
      AND    NVL(APH.Posted_Flag, 'N') IN ('Y', 'S')  		--bug 7614480, added status 'S'
      AND    APH.Payment_History_ID = APHD.Payment_History_ID
      AND    APH.Transaction_Type IN ('PAYMENT MATURITY', 'PAYMENT MATURITY REVERSED',
                                      'PAYMENT MATURITY ADJUSTED')
      AND NOT EXISTS (SELECT 'Event Reversed'
                      FROM   AP_PAYMENT_HISTORY_ALL APH_REL
                      WHERE  APH_REL.check_id = APH.check_id --bug9282163
                      AND    NVL(APH_REL.RELATED_EVENT_ID, APH_REL.ACCOUNTING_EVENT_ID) =
                                          NVL(APH.RELATED_EVENT_ID, APH.ACCOUNTING_EVENT_ID)
                      AND    APH_REL.REV_PMT_HIST_ID IS NOT NULL);
      --bug8975671, reversed entries and their reversals shouldn't be considered
  ELSE

      SELECT SUM(APHD.Amount),
             SUM(APHD.Invoice_Dist_Amount),
             SUM(APHD.Bank_Curr_Amount)
      INTO   l_pay_sum,
             l_inv_dist_sum,
             l_bank_curr_sum
      FROM   AP_Payment_Hist_Dists APHD,
             AP_Payment_History_All APH
      WHERE  APHD.Invoice_Distribution_ID in ( /*bug 8882706*/
			   select p_invoice_distribution_id from dual
                            union
                           -- awt distributions which are applied on p_invoice_distribution_id
                           select distinct aid_awt.invoice_distribution_id
                             from ap_invoice_distributions_all aid_awt,
                                  ap_invoice_distributions_all aid_item
                            where 1=1
                              and aid_item.invoice_distribution_id = p_invoice_distribution_id
                              and aid_item.line_type_lookup_code <> 'AWT'
                              and aid_awt.invoice_id = aid_item.invoice_id
                              and aid_awt.awt_related_id = aid_item.invoice_distribution_id                                   and aid_awt.line_type_lookup_code = 'AWT'
                             )
      AND    APHD.Pay_Dist_Lookup_Code IN ('CASH', 'DISCOUNT', 'AWT') -- bug8882706
      AND    NVL(APH.Posted_Flag, 'N') IN ('Y', 'S')  		--bug 7614480, added status 'S'
      AND    APH.Payment_History_ID = APHD.Payment_History_ID
      AND    APH.Transaction_Type IN ('PAYMENT CREATED', 'PAYMENT CANCELLED', 'PAYMENT ADJUSTED',
                                      'MANUAL PAYMENT ADJUSTED', 'UPGRADED MANUAL PMT ADJUSTED',
                                      'REFUND RECORDED',
                                      'REFUND ADJUSTED', 'REFUND CANCELLED')
      AND NOT EXISTS (SELECT 'Event Reversed'
                      FROM   AP_PAYMENT_HISTORY_ALL APH_REL
                      WHERE  APH_REL.check_id = APH.check_id --bug9282163
                      AND    NVL(APH_REL.RELATED_EVENT_ID, APH_REL.ACCOUNTING_EVENT_ID) =
                                          NVL(APH.RELATED_EVENT_ID, APH.ACCOUNTING_EVENT_ID)
                      AND    APH_REL.REV_PMT_HIST_ID IS NOT NULL);
      --bug8975671, reversed entries and their reversals shouldn't be considered
  END IF;

  p_payment_sum := NVL(l_pay_sum,0);
  p_inv_dist_sum := NVL(l_inv_dist_sum,0);
  p_bank_curr_sum := NVL(l_bank_curr_sum,0);

EXCEPTION

  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Get_Pay_Sum;



-------------------------------------------------------------------------------
-- Procedure Get_Pay_Base_Sum
-- This procedure gets the sum of the payment amount from the payment history
-- distributions for the given invoice distribution
-- Added For Bug 9282465
--------------------------------------------------------------------------------
PROCEDURE Get_Pay_Base_Sum
     (P_Invoice_Distribution_ID    IN          NUMBER
     ,P_Transaction_Type           IN          VARCHAR2
     ,P_Payment_Sum                OUT NOCOPY  NUMBER
     ,P_Inv_Dist_Sum               OUT NOCOPY  NUMBER
     ,P_Bank_Curr_Sum              OUT NOCOPY  NUMBER
     ,P_Calling_Sequence           IN          VARCHAR2
     ) IS

  l_curr_calling_sequence       VARCHAR2(2000);
  l_pay_sum                     NUMBER;
  l_inv_dist_sum                NUMBER;
  l_bank_curr_sum               NUMBER;

BEGIN

  l_curr_calling_sequence := 'AP_ACCOUNTING_PAY_PKG.Get_Pay_Base_Sum<- ' ||
                                         P_Calling_Sequence;

  IF (P_Transaction_Type IN ('PAYMENT CLEARED', 'PAYMENT CLEARING ADJUSTED')) THEN

           SELECT SUM( APHD.Paid_Base_Amount )
                , SUM( APHD.Invoice_Dist_Base_Amount )
                , SUM( APHD.Cleared_Base_Amount )
             INTO l_pay_sum
                , l_inv_dist_sum
                , l_bank_curr_sum
             FROM AP_Payment_Hist_Dists APHD
                , AP_Payment_History_All APH
            WHERE APHD.Invoice_Distribution_ID IN
                  (SELECT p_invoice_distribution_id
                      FROM dual
                     UNION
                  SELECT DISTINCT aid_awt.invoice_distribution_id
                      FROM ap_invoice_distributions_all aid_awt
                         , ap_invoice_distributions_all aid_item
                     WHERE 1                                = 1
                       AND aid_item.invoice_distribution_id = p_invoice_distribution_id
                       AND aid_item.line_type_lookup_code  <> 'AWT'
                       AND aid_awt.invoice_id               = aid_item.invoice_id
                       AND aid_awt.awt_related_id           =
                           aid_item.invoice_distribution_id
                       AND aid_awt.line_type_lookup_code = 'AWT'
                  )
              AND APHD.Pay_Dist_Lookup_Code   IN( 'CASH', 'DISCOUNT', 'AWT' )
              AND NVL( APH.Posted_Flag, 'N' ) IN( 'Y', 'S' )
              AND APH.Payment_History_ID       = APHD.Payment_History_ID
              AND APH.Transaction_Type        IN( 'PAYMENT CLEARING',
                  'PAYMENT UNCLEARING', 'PAYMENT CLEARING ADJUSTED' )
              AND NOT EXISTS
                  (SELECT 'Event Reversed'
                      FROM AP_PAYMENT_HISTORY_ALL APH_REL
                     WHERE APH_REL.check_id = APH.check_id
                       AND NVL( APH_REL.RELATED_EVENT_ID, APH_REL.ACCOUNTING_EVENT_ID )
                                                    = NVL( APH.RELATED_EVENT_ID, APH.ACCOUNTING_EVENT_ID )
                       AND APH_REL.REV_PMT_HIST_ID IS NOT NULL
                  );
  ELSIF (P_Transaction_Type IN ('PAYMENT MATURED', 'PAYMENT MATURITY ADJUSTED')) THEN

           SELECT SUM( APHD.Paid_Base_Amount )
                , SUM( APHD.Invoice_Dist_Base_Amount )
                , SUM( APHD.Cleared_Base_Amount )
             INTO l_pay_sum
                , l_inv_dist_sum
                , l_bank_curr_sum
             FROM AP_Payment_Hist_Dists APHD
                , AP_Payment_History_All APH
            WHERE APHD.Invoice_Distribution_ID IN
                  (SELECT p_invoice_distribution_id
                      FROM dual
                     UNION
                  SELECT DISTINCT aid_awt.invoice_distribution_id
                      FROM ap_invoice_distributions_all aid_awt
                         , ap_invoice_distributions_all aid_item
                     WHERE 1                                = 1
                       AND aid_item.invoice_distribution_id = p_invoice_distribution_id
                       AND aid_item.line_type_lookup_code  <> 'AWT'
                       AND aid_awt.invoice_id               = aid_item.invoice_id
                       AND aid_awt.awt_related_id           =
                           aid_item.invoice_distribution_id
                       AND aid_awt.line_type_lookup_code = 'AWT'
                  )
              AND APHD.Pay_Dist_Lookup_Code   IN( 'CASH', 'DISCOUNT', 'AWT' )
              AND NVL( APH.Posted_Flag, 'N' ) IN( 'Y', 'S' )
              AND APH.Payment_History_ID       = APHD.Payment_History_ID
              AND APH.Transaction_Type        IN( 'PAYMENT MATURITY',
                  'PAYMENT MATURITY REVERSED', 'PAYMENT MATURITY ADJUSTED' )
              AND NOT EXISTS
                  (SELECT 'Event Reversed'
                      FROM AP_PAYMENT_HISTORY_ALL APH_REL
                     WHERE APH_REL.check_id = APH.check_id
                       AND NVL( APH_REL.RELATED_EVENT_ID, APH_REL.ACCOUNTING_EVENT_ID )
                                                    = NVL( APH.RELATED_EVENT_ID, APH.ACCOUNTING_EVENT_ID )
                       AND APH_REL.REV_PMT_HIST_ID IS NOT NULL
                  );
  ELSE

           SELECT SUM( APHD.Paid_Base_Amount )
                , SUM( APHD.Invoice_Dist_Base_Amount )
                , SUM( APHD.Cleared_Base_Amount )
             INTO l_pay_sum
                , l_inv_dist_sum
                , l_bank_curr_sum
             FROM AP_Payment_Hist_Dists APHD
                , AP_Payment_History_All APH
            WHERE APHD.Invoice_Distribution_ID IN
                  (SELECT p_invoice_distribution_id
                      FROM dual
                     UNION
                  SELECT DISTINCT aid_awt.invoice_distribution_id
                      FROM ap_invoice_distributions_all aid_awt
                         , ap_invoice_distributions_all aid_item
                     WHERE 1                                = 1
                       AND aid_item.invoice_distribution_id = p_invoice_distribution_id
                       AND aid_item.line_type_lookup_code  <> 'AWT'
                       AND aid_awt.invoice_id               = aid_item.invoice_id
                       AND aid_awt.awt_related_id           =
                           aid_item.invoice_distribution_id
                       AND aid_awt.line_type_lookup_code = 'AWT'
                  )
              AND APHD.Pay_Dist_Lookup_Code   IN( 'CASH', 'DISCOUNT', 'AWT' )
              AND NVL( APH.Posted_Flag, 'N' ) IN( 'Y', 'S' )
              AND APH.Payment_History_ID       = APHD.Payment_History_ID
              AND APH.Transaction_Type        IN( 'PAYMENT CREATED', 'PAYMENT CANCELLED'
                  , 'PAYMENT ADJUSTED', 'MANUAL PAYMENT ADJUSTED',
                  'UPGRADED MANUAL PMT ADJUSTED', 'REFUND RECORDED', 'REFUND ADJUSTED',
                  'REFUND CANCELLED' )
              AND NOT EXISTS
                  (SELECT 'Event Reversed'
                      FROM AP_PAYMENT_HISTORY_ALL APH_REL
                     WHERE APH_REL.check_id = APH.check_id
                       AND NVL( APH_REL.RELATED_EVENT_ID, APH_REL.ACCOUNTING_EVENT_ID )
                                                    = NVL( APH.RELATED_EVENT_ID, APH.ACCOUNTING_EVENT_ID )
                       AND APH_REL.REV_PMT_HIST_ID IS NOT NULL
                  );
END IF;

  p_payment_sum := NVL(l_pay_sum,0);
  p_inv_dist_sum := NVL(l_inv_dist_sum,0);
  p_bank_curr_sum := NVL(l_bank_curr_sum,0);

EXCEPTION

  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Get_Pay_Base_Sum;


-------------------------------------------------------------------------------
-- Function Get_Prepay_Sum
-- This function gets the sum of the prepaid amount from the  prepay appl payment
-- distributions for the given invoice distribution
--
--------------------------------------------------------------------------------
FUNCTION Get_Prepay_Sum
      ( P_Invoice_Distribution_ID    IN    NUMBER
       ,P_Calling_Sequence           IN          VARCHAR2
     ) RETURN NUMBER IS

  l_curr_calling_sequence       VARCHAR2(2000);
  l_prepay_sum                  NUMBER;

BEGIN

  l_curr_calling_sequence := 'AP_ACCOUNTING_PAY_PKG.Get_Prepay_Sum<- ' ||
                                         P_Calling_Sequence;


  SELECT SUM(APAD.Amount)
  INTO   l_prepay_sum
  FROM   AP_Prepay_App_Dists APAD,
         AP_Invoice_Distributions_All AID
  WHERE  APAD.Invoice_Distribution_ID in ( /*bug 8882706*/
			   select p_invoice_distribution_id from dual
                            union
			   /* awt distributions which are applied on the p_invoice_distribution_id*/
                           select distinct aid_awt.invoice_distribution_id
                             from ap_invoice_distributions_all aid_awt,
                                  ap_invoice_distributions_all aid_item
                            where 1=1
                              and aid_item.invoice_distribution_id = p_invoice_distribution_id
			      and aid_item.line_type_lookup_code <> 'AWT'
                              and aid_awt.invoice_id = aid_item.invoice_id
                              and aid_awt.awt_related_id = aid_item.invoice_distribution_id
                              and aid_awt.line_type_lookup_code = 'AWT'
                             )
  AND   APAD.Prepay_App_Distribution_ID = AID.Invoice_Distribution_ID
  AND   NVL(AID.Reversal_Flag, 'N') <> 'Y'  --bug9322001
  AND   APAD.Prepay_Dist_Lookup_Code IN ('PREPAY APPL', 'PREPAY APPL REC TAX',
                                          'PREPAY APPL NONREC TAX', 'AWT',
                                          'EXCHANGE RATE VARIANCE');

  RETURN NVL(l_prepay_sum,0);

END Get_Prepay_Sum;


-------------------------------------------------------------------------------
-- Procedure Get_Prepay_Base_Sum
-- This Procedure gets the sum of the prepaid amounts from the
-- prepay appl payment distributions for the given invoice distribution
-- Added For Bug 9282465
--------------------------------------------------------------------------------
PROCEDURE Get_Prepay_Base_Sum
       (P_Invoice_Distribution_ID    IN          NUMBER
       ,P_Paid_Base_Sum              OUT NOCOPY  NUMBER
       ,P_Inv_Dist_Base_Sum          OUT NOCOPY  NUMBER
       ,P_Clr_Base_Curr_Sum          OUT NOCOPY  NUMBER
       ,P_Calling_Sequence           IN          VARCHAR2)IS

  l_curr_calling_sequence       VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence := 'AP_ACCOUNTING_PAY_PKG.Get_Prepay_Base_Sum<- ' ||
                                         P_Calling_Sequence;

   SELECT SUM( APAD.Base_Amount )
       , SUM( APAD.Base_Amt_At_Prepay_XRate )
       , SUM( APAD.Base_Amt_At_Prepay_Clr_XRate )
    INTO P_Inv_Dist_Base_Sum
       , P_Paid_Base_Sum
       , P_Clr_Base_Curr_Sum
    FROM AP_Prepay_App_Dists APAD
   WHERE APAD.Invoice_Distribution_ID IN
         ( SELECT p_invoice_distribution_id FROM dual
            UNION
           SELECT DISTINCT aid_awt.invoice_distribution_id
             FROM ap_invoice_distributions_all aid_awt
                , ap_invoice_distributions_all aid_item
            WHERE 1                                = 1
              AND aid_item.invoice_distribution_id = p_invoice_distribution_id
              AND aid_item.line_type_lookup_code  <> 'AWT'
              AND aid_awt.invoice_id               = aid_item.invoice_id
              AND aid_awt.awt_related_id           = aid_item.invoice_distribution_id
              AND aid_awt.line_type_lookup_code    = 'AWT'
         )
     AND APAD.Prepay_Dist_Lookup_Code IN( 'PREPAY APPL', 'PREPAY APPL REC TAX',
         'PREPAY APPL NONREC TAX', 'AWT', 'EXCHANGE RATE VARIANCE' );
EXCEPTION

  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Get_Prepay_Base_Sum;


-------------------------------------------------------------------------------
-- Function Is_Final_Payment
-- Function to check if this payment is the final payment for the given
-- invoice.
-- bug 5623129 Note
--   1.added more debug message
--   2. P_Transaction_Type should match to event type.
--     The payment history transaction type is different from event type
--   3. add AND    APH.Posted_Flag = 'Y'  to get accounted paid amount
--------------------------------------------------------------------------------
FUNCTION Is_Final_Payment
                 (P_Inv_Rec             IN  r_invoices_info
                 ,P_Payment_Amount      IN  NUMBER
                 ,P_Discount_Amount     IN  NUMBER
                 ,P_Prepay_Amount       IN  NUMBER
                 ,P_Transaction_Type    IN  VARCHAR2
                 ,P_calling_sequence    IN  VARCHAR2
                 ) RETURN BOOLEAN IS

  l_paid_acctd_amt           NUMBER;
  l_prepaid_acctd_amt        NUMBER;
  l_total_paid_amt           NUMBER;
  l_total_prepaid_amt        NUMBER;
  l_final_payment            BOOLEAN := FALSE;
  l_inv_inc_prepay_tot       NUMBER;   --bug8613795
  l_inv_inc_prepay_pay       NUMBER;   --bug8613795
  l_curr_calling_sequence    VARCHAR2(2000);
  l_total_awt                NUMBER; --Bug 9166188

  l_procedure_name CONSTANT VARCHAR2(30) := 'is_final_payment';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN


  l_curr_calling_sequence := 'AP_ACCOUNTING_PAY_PKG.Is_Final_Payment<-' ||
                                       P_Calling_Sequence;


  /* We need to get the paid amount for a particular transaction type
     as payment hist dists stores paid amounts for all types of
     payment events. */



   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of is_ainal_payment function call and passin parameters are' ||
                   'P_Payment_Amount=' || P_Payment_Amount ||
                   'P_Discount_Amount=' ||P_Discount_Amount ||
                   'P_Prepay_Amount =' || P_Prepay_Amount ||
                   'P_Transaction_Type =' || P_Transaction_Type;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;


  IF (P_Transaction_Type IN ('PAYMENT CLEARED')) THEN

      /* Getting the sum of payment distributions to check if this is the final
         payment */

      -------------------------------------------------------------------------
      --  bug 5570002
      -- 1. Take out the Exchange rate variance consideration
      --   Because for entered amount, it is 0 always
      -- 2. comment out the "APH.posted_flag" <> 'N' and
      --    later change to  "APH.posted_flag" = 'Y'
      -------------------------------------------------------------------------

      SELECT SUM(--DECODE(APHD.Pay_Dist_Lookup_Code,
                        --'EXCHANGE RATE VARIANCE', -1 * APHD.Amount,
                        APHD.Amount)
      INTO   l_paid_acctd_amt
      FROM   AP_Payment_Hist_Dists APHD,
             AP_Invoice_Distributions_All AID,
             AP_Payment_History_All APH
      WHERE  AID.Invoice_ID = p_inv_rec.invoice_id
      AND    AID.Invoice_Distribution_ID = APHD.Invoice_Distribution_ID
      AND    APHD.Pay_Dist_Lookup_Code IN ('CASH', 'DISCOUNT')  --bug 9265516, removed 'AWT'
      AND    APH.Posted_Flag IN ('Y', 'S')                      --bug 7614480, added status 'S'
      AND    APH.Payment_History_ID = APHD.Payment_History_ID
      AND    APH.Transaction_Type IN ('PAYMENT CLEARING', 'PAYMENT UNCLEARING',
                                      'PAYMENT CLEARING ADJUSTED')
      AND    NOT EXISTS(SELECT 'reversed event'
                       FROM AP_PAYMENT_HISTORY_ALL APH_REV
                      WHERE  APH_REV.check_id = APH.check_id --bug9282163
                        AND  nvl(aph_rev.related_event_id, aph_rev.accounting_event_id)
                                  = nvl(aph.related_event_id, aph.accounting_event_id)
                        AND aph_rev.rev_pmt_hist_id IS NOT NULL); --bug 7614480, added not exists


      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'transaction type is payment clearing and ' ||
                   'l_paid_acctd_amt=' || l_paid_acctd_amt;
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

  ELSIF (P_Transaction_Type IN ('PAYMENT MATURED')) THEN

      /* Getting the sum of payment distributions to check if this is the final
         payment */
      SELECT SUM(--DECODE(APHD.Pay_Dist_Lookup_Code,
                        --'EXCHANGE RATE VARIANCE', -1 * APHD.Amount,
                        APHD.Amount)
      INTO   l_paid_acctd_amt
      FROM   AP_Payment_Hist_Dists APHD,
             AP_Invoice_Distributions_All AID,
             AP_Payment_History_All APH
      WHERE  AID.Invoice_ID = p_inv_rec.invoice_id
      AND    AID.Invoice_Distribution_ID = APHD.Invoice_Distribution_ID
      AND    APHD.Pay_Dist_Lookup_Code IN ('CASH', 'DISCOUNT')  --bug 9265516, removed 'AWT'
      AND    APH.Posted_Flag IN ('Y', 'S')                      --bug 7614480, added status 'S'
      AND    APH.Payment_History_ID = APHD.Payment_History_ID
      AND    APH.Transaction_Type IN ('PAYMENT MATURITY', 'PAYMENT MATURITY REVERSED',
                                      'PAYMENT MATURITY ADJUSTED')
      AND NOT EXISTS(SELECT 'reversed event'
                       FROM AP_PAYMENT_HISTORY_ALL APH_REV
                      WHERE  APH_REV.check_id = APH.check_id --bug9282163
                        AND  nvl(aph_rev.related_event_id, aph_rev.accounting_event_id)
                                  = nvl(aph.related_event_id, aph.accounting_event_id)
                        AND aph_rev.rev_pmt_hist_id IS NOT NULL); --bug 7614480, added not exists

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'transaction type is payment matruity and ' ||
                   'l_paid_acctd_amt=' || l_paid_acctd_amt;
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;


  ELSE

      /* Getting the sum of payment distributions to check if this is the final
         payment */
      SELECT SUM(--DECODE(APHD.Pay_Dist_Lookup_Code,
                        --'EXCHANGE RATE VARIANCE', -1 * APHD.Amount,
                         APHD.Amount)
      INTO   l_paid_acctd_amt
      FROM   AP_Payment_Hist_Dists APHD,
             AP_Invoice_Distributions_All AID,
             AP_Payment_History_All APH,
             AP_INVOICE_PAYMENTS_ALL AIP
      WHERE  AID.Invoice_ID = p_inv_rec.invoice_id
      AND    AID.Invoice_Distribution_ID = APHD.Invoice_Distribution_ID
      AND    APHD.Pay_Dist_Lookup_Code IN ('CASH', 'DISCOUNT')  --bug 9265516, removed 'AWT'
      AND    APH.Posted_Flag IN ('Y', 'S')                      --bug 7614480, added status 'S'
      AND    APH.Payment_History_ID = APHD.Payment_History_ID
      AND    APH.Transaction_Type IN ('PAYMENT CREATED', 'PAYMENT CANCELLED', 'PAYMENT ADJUSTED',
                                      'MANUAL PAYMENT ADJUSTED', 'UPGRADED MANUAL PMT ADJUSTED',
                                      'REFUND RECORDED', 'REFUND ADJUSTED', 'REFUND CANCELLED')
      AND    aphd.invoice_payment_id = aip.invoice_payment_id
      AND    aip.invoice_id = aid.invoice_id
      AND    aip.check_id = aph.check_id
      AND    nvl(aip.reversal_flag, 'N') <> 'Y'; --bug 7614480, added not exists

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'transaction type is payment created or others ' ||
                   'l_paid_acctd_amt=' || l_paid_acctd_amt;
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

  END IF;


  /* Get the total prepaid amount from the ap_prepay_app_dists table */
  /* bug9322001, changed the where clause to remove conditions on accounting */
  /* events, and checked only for reversal flag on the Prepay Application dists */
  SELECT SUM(APAD.Amount)
  INTO   l_prepaid_acctd_amt
  FROM   AP_Prepay_App_Dists APAD,
         AP_Invoice_Distributions_All AID,
	 AP_PREPAY_HISTORY_ALL APPH
  WHERE  AID.Invoice_ID = p_inv_rec.invoice_id
  AND    AID.Invoice_Distribution_ID = APAD.Invoice_Distribution_ID
  AND    APAD.prepay_history_id = APPH.PREPAY_HISTORY_ID
  AND    APAD.Prepay_Dist_Lookup_Code IN ('PREPAY APPL', 'PREPAY APPL REC TAX',
                                          'PREPAY APPL NONREC TAX')  --bug 9265516, removed 'AWT'
  AND NOT EXISTS( SELECT 'reversed prepay application'
                    FROM ap_invoice_distributions_all aidp
                   WHERE aidp.invoice_distribution_id = APAD.prepay_app_distribution_id
                     AND aidp.reversal_flag = 'Y');			--bug 7614480, added not exists


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'there is a prepay application and  ' ||
                   'l_prepaid_acctd_amt =' || l_prepaid_acctd_amt;
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;


  IF (p_inv_rec.invoice_currency_code <> p_inv_rec.payment_currency_code) THEN

      l_total_prepaid_amt := GL_Currency_API.Convert_Amount(
                                    p_inv_rec.invoice_currency_code,
                                    p_inv_rec.payment_currency_code,
                                    p_inv_rec.payment_cross_rate_date,
                                    'EMU FIXED',
                                    NVL(l_prepaid_acctd_amt,0)
                                       + NVL(p_prepay_amount,0));

  ELSE

     l_total_prepaid_amt := NVL(l_prepaid_acctd_amt,0) + NVL(p_prepay_amount,0);

  END IF;

  -- bug8613795

  SELECT NVL(SUM(AID.amount), 0)
    INTO l_inv_inc_prepay_tot
    FROM ap_invoice_distributions_all AID
   WHERE AID.invoice_id = p_inv_rec.invoice_id
     AND AID.line_type_lookup_code        IN ('PREPAY','REC_TAX','NONREC_TAX')
     AND AID.prepay_distribution_id       IS NOT NULL
     AND AID.invoice_includes_prepay_flag = 'Y';

  IF (p_inv_rec.invoice_currency_code <> p_inv_rec.payment_currency_code) THEN

      l_inv_inc_prepay_pay := GL_Currency_API.Convert_Amount(
                                    p_inv_rec.invoice_currency_code,
                                    p_inv_rec.payment_currency_code,
                                    p_inv_rec.payment_cross_rate_date,
                                    'EMU FIXED',
                                    l_inv_inc_prepay_tot);
  END IF;

--Bug 9166188

  SELECT nvl(sum(amount),0) into l_total_awt
    FROM ap_invoice_distributions_all aid
   WHERE aid.invoice_id= p_inv_rec.invoice_id
     AND aid.line_type_lookup_code ='AWT';

  IF (p_inv_rec.invoice_currency_code <> p_inv_rec.payment_currency_code) THEN

      l_total_awt := GL_Currency_API.Convert_Amount(
                                    p_inv_rec.invoice_currency_code,
                                    p_inv_rec.payment_currency_code,
                                    p_inv_rec.payment_cross_rate_date,
                                    'EMU FIXED',
                                    l_total_awt);
  END IF;

--Bug 9166188



  l_total_paid_amt := NVL(l_paid_acctd_amt,0) + NVL(p_payment_amount,0)
                                  + NVL(p_discount_amount,0);


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'Now total paid amount = l_paid_acctd_amt + p_payment_amount + p_discount_amount and' ||
                 ' l_total_paid_amt =' || l_total_paid_amt ||
                 'compare invoice amount either with ' ||
                 'p_inv_rec.pay_curr_invoice_amount' || p_inv_rec.pay_curr_invoice_amount ||
                 'p_inv_rec.invoice_amount ' || p_inv_rec.invoice_amount ||
                 'l_total_awt '||l_total_awt;

    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

  --bug8613795
  --Bug 9166188
  IF (nvl(p_inv_rec.pay_curr_invoice_amount, p_inv_rec.invoice_amount) -
           nvl(l_inv_inc_prepay_pay,0) + nvl(l_total_awt,0)
                  = nvl(l_total_paid_amt,0) - nvl(l_total_prepaid_amt,0)) THEN

    l_final_payment := TRUE;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'This is a final payment after comparison';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

  END IF;

  RETURN l_final_payment;

END Is_Final_Payment;

-------------------------------------------------------------------------------
-- FUNCTION Get_Base_Amount RETURN NUMBER
-- Converts the given amount to base amount depending on the exchange rate type

-- Parameters
   ----------
   -- Amount - Amount to convert
   -- Currency_Code - Currency code to convert from
   -- Base_Currency_Code - Currency Code to convert to
   -- Exchange_Rate_Type - Type of exchange rate
   -- Exchange_Rate_Date - Date the conversion is happening
   -- Exchange_Rate - The Exchange rate between the two currencies
   -- bug 5623129 note
   --   1. add more debug message
-------------------------------------------------------------------------------
FUNCTION Get_Base_Amount
                 (P_amount              IN  NUMBER
                 ,P_currency_code       IN  VARCHAR2
                 ,P_base_currency_code  IN  VARCHAR2
                 ,P_exchange_rate_type  IN  VARCHAR2
                 ,P_exchange_rate_date  IN  DATE
                 ,P_exchange_rate       IN  NUMBER
                 ,P_calling_sequence    IN  VARCHAR2
                 ) RETURN NUMBER IS

  l_base_amount              NUMBER := 0 ;
  l_curr_calling_sequence    VARCHAR2(2000);

  l_procedure_name CONSTANT VARCHAR2(30) := 'Get_Base_Amount';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  l_curr_calling_sequence := 'AP_ACCOUNTING_PAY_PKG.Get_Base_Amount<-'
                             || P_calling_sequence;



  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Begin of get_base_amount and parameters are' ||
                   'p_amount=' || nvl(p_amount, 0) ||
                   'P_currency_code =' || P_currency_code ||
                   'P_base_currency_code =' || P_base_currency_code ||
                   'P_exchange_rate_type =' || P_exchange_rate_type ||
                   'P_exchange_rate_date =' || P_exchange_rate_date ||
                   'P_exchange_rate  =' || P_exchange_rate ;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

  IF ( P_currency_code = P_base_currency_code ) THEN

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'base currency code = transaction currency code';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);

    END IF;

    l_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(P_amount,
                                                        P_base_currency_code);

  ELSIF ( P_exchange_rate_type <> 'User'
            AND GL_Currency_API.Is_Fixed_Rate(P_currency_code,
                                    P_base_currency_code,
                                    P_exchange_rate_date) = 'Y' ) THEN

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN

      l_log_msg := 'exchange rate type is not user and it is a fixed rate';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);

    END IF;

    l_base_amount := GL_Currency_API.Convert_Amount(P_currency_code,
                                                    P_base_currency_code,
                                                    P_exchange_rate_date,
                                                    P_exchange_rate_type,
                                                    P_amount) ;
  ELSE

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN

      l_log_msg := 'not a fix rate, and not a same currency code';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, l_log_msg);

    END IF;


    l_base_amount := AP_Utilities_Pkg.AP_Round_Currency
                                      (P_amount * NVL(P_exchange_rate, 1),
                                       P_base_currency_code) ;

  END IF;

  RETURN l_base_amount ;

EXCEPTION
  WHEN GL_CURRENCY_API.NO_RATE THEN
    RAISE_APPLICATION_ERROR(-20010, 'Could not find fixed rate between'
       || P_currency_code || ' and ' || P_base_currency_code || ' on '
       || to_char(P_exchange_rate_date) );

END Get_Base_Amount;


END AP_ACCOUNTING_PAY_PKG;

/
