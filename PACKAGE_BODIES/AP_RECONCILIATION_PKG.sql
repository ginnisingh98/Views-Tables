--------------------------------------------------------
--  DDL for Package Body AP_RECONCILIATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_RECONCILIATION_PKG" as
/* $Header: apreconb.pls 120.22.12010000.9 2010/01/09 07:09:46 dcshanmu ship $ */

--============================================================================
-- POSSIBLE SCENARIOS ON HOW THIS API MAY BE CALLED:
-- 1) PAYMENT MATURITY
--    In this case we insert a record into the AP_PAYMENT_HISTORY which
--    contains all information in currency of payment.
-- 2) PAYMENT CLEARING WITH RECONCILIATION ACCOUNTING OFF
--    In this case we simply update the AP_CHECKS and no entry is generated
--    for AP_PAYMENT_HISTORY.  The amounts need to be properly converted
--    to the payment currency.
-- 3) PAYMENT CLEARING WITH RECONCILIATION ACCOUNTING ON
--    Same as 2
-- 4) PAYMENT RECONCILIATION WITH RECONCILIATION ACCOUNTING OFF
--    Same as 2
-- 5) PAYMENT RECONCILIATION WITH RECONCILIATION ACCOUNTING ON
--    Same as 2 + Creation of entry into the AP_PAYMENT_HISTORY table.
-- NOTE: Entry into AP_PAYMENT_HISTORY table will be in the recon currency.
--
-- TERMINOLOGY:
-- 1) PAYMENT MATURITY:
--    TRANSACTION_TYPE = PAYMENT MATURITY
--    MATCHED_FLAG is irrelevant
-- 2) PAYMENT CLEARING:
--    TRANSACTION_TYPE = PAYMENT CLEARING
--    MATCHED_FLAG = N (i.e. clearing not matched to bank statement)
-- 3) PAYMENT RECONCILIATION:
--    TRANSACTION_TYPE = PAYMENT CLEARING
--    MATCHED_FLAG = Y (i.e. clearing matched to bank statement)
--
-- WHAT THIS API RECEIVES FROM CASH MANAGEMENT
-- 1) Transaction, Error and Charge Amounts in Bank Currency
-- 2) Bank Currency Code
-- 3) Exchange rate, date and type between Pmt. Currency and Functional Currency
--    (this exchange info is sufficient 'coz :
--      DOMESTIC: All involved currencies are the same (so it does not matter)
--      FOREIGN: Bank and Pmt. currencies are the same. Hence the rate between
--               pmt. and functional is enough.
--      INTERNATIONAL: Bank and Functional currencies are the same. Hence, the
--                     only needed x-rate is between pmt. and functional.
--    )
-- WHAT THIS API RECEIVES FROM AP for MATURITY
-- 1) Transaction Amount in Pmt. Currency
-- 2) Pmt. Currency Code
-- 3) Exchange rate, date and type between Pmt. Currency and Functional Currency
--
-- POSSIBLE TRANSACTION CONTEXTS:
-- 1) Payment batch.
--    In this case we prorate errors and charges across
--    all checks in the batch with any remaining amount going to the
--    largest. For the cleared amount in AP_CHECKS, we use the check amount +
--    prorated errors and charges converted to payment currency
-- 2) Check
--    In this case all trx_amount, errors and charges converted to payment
--    currency go to the check.
--
-- POSSIBLE CURRENCY SCENARIOS:
-- 1) DOMESTIC:
--    Recon currency = Payment currency = Functional currency
-- 2) INTERNATIONAL
--    Recon currency = Functional currency <> Payment currency
-- 3) FOREIGN
--    Recon currency = Payment currency <> Functional currency
-- 4) CROSS CURRENCY (not currently supported in AP but can happen in MRC)
--    Recon currency <> Payment currency <> Functional currency
--    Recon currency - EMU FIXED - Payment currency
--
--============================================================================

-- Global exception
G_abort_it                        EXCEPTION;

-- debug variables
  G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER   := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER   := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER   := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER   := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER   := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER   := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_RECONCILIATION_PKG.';

/* *************************************************************************
   * RECON_PAYMENT_HISTORY : Reconciliation API to clear or reconcile a    *
   * check. Transaction amount parameter though is not used for actual     *
   * update but actual check amount is used.                               *
   ************************************************************************* */

PROCEDURE Recon_Payment_History(
  X_CHECKRUN_ID               NUMBER,
  X_CHECK_ID                  NUMBER,
  X_ACCOUNTING_DATE           DATE,
  X_CLEARED_DATE              DATE,
  X_TRANSACTION_AMOUNT        NUMBER,      -- in bank curr.
  X_TRANSACTION_TYPE          VARCHAR2,
  X_ERROR_AMOUNT              NUMBER,      -- in bank curr.
  X_CHARGE_AMOUNT             NUMBER,      -- in bank curr.
  X_CURRENCY_CODE             VARCHAR2,    -- bank curr. code
  X_EXCHANGE_RATE_TYPE        VARCHAR2,    -- between payment and functional
  X_EXCHANGE_RATE_DATE        DATE,        -- between payment and functional
  X_EXCHANGE_RATE             NUMBER,      -- between payment and functional
  X_MATCHED_FLAG              VARCHAR2,
  X_ACTUAL_VALUE_DATE         DATE,
  X_LAST_UPDATE_DATE          DATE,
  X_LAST_UPDATED_BY           NUMBER,
  X_LAST_UPDATE_LOGIN         NUMBER,
  X_CREATED_BY                NUMBER,
  X_CREATION_DATE             DATE,
  X_PROGRAM_UPDATE_DATE       DATE,
  X_PROGRAM_APPLICATION_ID    NUMBER,
  X_PROGRAM_ID                NUMBER,
  X_REQUEST_ID                NUMBER,
  X_CALLING_SEQUENCE          VARCHAR2
) AS
  current_calling_sequence    VARCHAR2(2000);
  l_Trx_Bank_Amount           AP_PAYMENT_HISTORY.Trx_Bank_Amount%TYPE;
  l_Errors_Bank_Amount        AP_PAYMENT_HISTORY.Errors_Bank_Amount%TYPE;
  l_Charges_Bank_Amount       AP_PAYMENT_HISTORY.Charges_Bank_Amount%TYPE;
  l_Bank_Currency_Code        AP_PAYMENT_HISTORY.Bank_Currency_Code%TYPE;
  l_Pmt_to_Base_Xrate_Type    AP_PAYMENT_HISTORY.Pmt_to_Base_Xrate_Type%TYPE;
  l_Pmt_to_Base_Xrate_Date    AP_PAYMENT_HISTORY.Pmt_to_Base_Xrate_Date%TYPE;
  l_Pmt_to_Base_Xrate         AP_PAYMENT_HISTORY.Pmt_to_Base_Xrate%TYPE;
  l_debug_info                VARCHAR2(240);
  l_api_name                  CONSTANT VARCHAR2(1000) := 'Recon_Payment_History' ;
BEGIN

  current_calling_sequence := X_CALLING_SEQUENCE ||
                             'AP_RECONCILIATION_PKG.RECON_PAYMENT_HISTORY' ;

    -- Check if all required data is passed
   ----------------------------------------------------------------
   l_debug_info := 'Check for required info';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
   ---------------------------------------------------------------

  IF ( ( X_TRANSACTION_AMOUNT IS NULL ) or
       ( X_TRANSACTION_TYPE IS NULL ) or
       ( X_CURRENCY_CODE IS NULL ) or
       ( X_CREATION_DATE IS NULL ) or
       ( X_CREATED_BY IS NULL ) or
       ( X_LAST_UPDATE_DATE IS NULL ) or
       ( X_LAST_UPDATED_BY IS NULL )  )  THEN
    APP_EXCEPTION.RAISE_EXCEPTION ;
  END IF ;

  l_Trx_Bank_Amount        := X_TRANSACTION_AMOUNT;
  l_Errors_Bank_Amount     := X_ERROR_AMOUNT;
  l_Charges_Bank_Amount    := X_CHARGE_AMOUNT;
  l_Bank_Currency_Code     := X_CURRENCY_CODE;
  l_Pmt_to_Base_Xrate_Type := X_EXCHANGE_RATE_TYPE;
  l_Pmt_to_Base_Xrate_Date := X_EXCHANGE_RATE_DATE;
  l_Pmt_to_Base_Xrate      := X_EXCHANGE_RATE;

  IF X_TRANSACTION_TYPE IN ('PAYMENT MATURITY' ,
                            'PAYMENT MATURITY REVERSAL' ) THEN
   -----------------------------------------------------------------
    l_debug_info := 'Payment Maturity';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
   ---------------------------------------------------------------

    AP_RECONCILIATION_PKG.Recon_Payment_Maturity
                           ( X_CHECK_ID,
                             X_ACCOUNTING_DATE,
                             X_TRANSACTION_TYPE,
                             X_TRANSACTION_AMOUNT,
                             X_CURRENCY_CODE,
                             X_EXCHANGE_RATE_TYPE,
                             X_EXCHANGE_RATE_DATE,
                             X_EXCHANGE_RATE,
                             X_LAST_UPDATE_DATE,
                             X_LAST_UPDATED_BY,
                             X_LAST_UPDATE_LOGIN,
                             X_CREATED_BY,
                             X_CREATION_DATE,
                             X_PROGRAM_UPDATE_DATE,
                             X_PROGRAM_APPLICATION_ID,
                             X_PROGRAM_ID,
                             X_REQUEST_ID,
                             X_CALLING_SEQUENCE ) ;

  ELSIF X_TRANSACTION_TYPE IN ('PAYMENT CLEARING' ) THEN
    -------------------------------------------------------------------
        l_debug_info := 'Payment Clearing';
		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
   ---------------------------------------------------------------
	AP_RECONCILIATION_PKG.Recon_Payment_Clearing
                           ( X_CHECKRUN_ID,
                             X_CHECK_ID,
                             X_ACCOUNTING_DATE,
                             X_CLEARED_DATE,
                             X_TRANSACTION_TYPE,
                             l_Trx_Bank_Amount,
                             l_Errors_Bank_Amount,
                             l_Charges_Bank_Amount,
                             l_Bank_Currency_Code,
                             l_Pmt_to_Base_Xrate_Type,
                             l_Pmt_to_Base_Xrate_Date,
                             l_Pmt_to_Base_Xrate,
                             X_MATCHED_FLAG,
                             X_ACTUAL_VALUE_DATE,
                             X_LAST_UPDATE_DATE,
                             X_LAST_UPDATED_BY,
                             X_LAST_UPDATE_LOGIN,
                             X_CREATED_BY,
                             X_CREATION_DATE,
                             X_PROGRAM_UPDATE_DATE,
                             X_PROGRAM_APPLICATION_ID,
                             X_PROGRAM_ID,
                             X_REQUEST_ID,
                             X_CALLING_SEQUENCE ) ;

  ELSIF X_TRANSACTION_TYPE IN ('PAYMENT UNCLEARING' ) THEN
   --------------------------------------------------------------
	l_debug_info := 'Payment Unclearing';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
   ---------------------------------------------------------------
    AP_RECONCILIATION_PKG.Recon_Payment_Unclearing
                           ( X_CHECKRUN_ID,
                             X_CHECK_ID,
                             X_ACCOUNTING_DATE,
                             X_TRANSACTION_TYPE,
                             X_MATCHED_FLAG,
                             X_LAST_UPDATE_DATE,
                             X_LAST_UPDATED_BY,
                             X_LAST_UPDATE_LOGIN,
                             X_CREATED_BY,
                             X_CREATION_DATE,
                             X_PROGRAM_UPDATE_DATE,
                             X_PROGRAM_APPLICATION_ID,
                             X_PROGRAM_ID,
                             X_REQUEST_ID,
                             X_CALLING_SEQUENCE ) ;

  ELSE
    APP_EXCEPTION.RAISE_EXCEPTION ;
  END IF ;

  EXCEPTION
  WHEN OTHERS THEN
       IF (SQLCODE <> -20001) THEN
           FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;

END Recon_Payment_History;


/* *************************************************************************
   * RECON_PAYMENT_MATURITY: Creates payment history activity for a check  *
   ************************************************************************* */

PROCEDURE Recon_Payment_Maturity(
  X_CHECK_ID                 NUMBER,
  X_ACCOUNTING_DATE          DATE,
  X_TRANSACTION_TYPE         VARCHAR2,
  X_TRANSACTION_AMOUNT       NUMBER,
  X_CURRENCY_CODE            VARCHAR2,
  X_EXCHANGE_RATE_TYPE       VARCHAR2,
  X_EXCHANGE_RATE_DATE       DATE,
  X_EXCHANGE_RATE            NUMBER,
  X_LAST_UPDATE_DATE         DATE,
  X_LAST_UPDATED_BY          NUMBER,
  X_LAST_UPDATE_LOGIN        NUMBER,
  X_CREATED_BY               NUMBER,
  X_CREATION_DATE            DATE,
  X_PROGRAM_UPDATE_DATE      DATE,
  X_PROGRAM_APPLICATION_ID   NUMBER,
  X_PROGRAM_ID               NUMBER,
  X_REQUEST_ID               NUMBER,
  X_CALLING_SEQUENCE         VARCHAR2
) AS
  current_calling_sequence    VARCHAR2(2000);
  l_trx_base_amount           AP_PAYMENT_HISTORY.Trx_Base_Amount%TYPE;
  l_functional_currency_code  VARCHAR2(15);
  l_rev_pmt_hist_id           NUMBER; -- Bug3343314
  l_org_id                    NUMBER;
  l_debug_info                VARCHAR2(240);
  l_api_name                  CONSTANT VARCHAR2(1000) := 'Recon_Payment_Maturity' ;

  -- bug 9069767 starts
  l_exchange_rate		AP_CHECKS_ALL.EXCHANGE_RATE%TYPE;
  l_exchange_date		AP_CHECKS_ALL.EXCHANGE_DATE%TYPE;
  l_exchange_rate_type		AP_CHECKS_ALL.EXCHANGE_RATE_TYPE%TYPE;
  -- bug 9069767 ends
BEGIN
  current_calling_sequence := X_CALLING_SEQUENCE ||
                             'AP_RECONCILIATION_PKG.RECON_PAYMENT_MATURITY' ;

  IF (x_transaction_type IN ('PAYMENT MATURITY', -- Bug3343314
                             'PAYMENT MATURITY REVERSAL')) THEN -- Bug3343314

    -- Bug3343314
    IF (x_transaction_type = 'PAYMENT MATURITY REVERSAL') THEN

      SELECT payment_history_id
      INTO   l_rev_pmt_hist_id
      FROM   ap_payment_history aph
      WHERE  transaction_type = 'PAYMENT MATURITY'
      AND    check_id = x_check_id
      AND    not exists (select 1
			   from   ap_payment_history aph1
			   where  aph.check_id=aph1.check_id
			   and	  aph.payment_history_id=aph1.rev_pmt_hist_id);

      -- Bug 7674770

    ELSE
      l_rev_pmt_hist_id := NULL;
    END IF;

    -- bug 4578865
   -------------------------------------------------------------------
    l_debug_info := 'Inside Recon Payment Maturity, getting base curr';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
   ---------------------------------------------------------------
    SELECT  asp.base_currency_code,
            asp.org_id
      INTO  l_functional_currency_code,
            l_org_id
      FROM  ap_system_parameters asp,
            ap_checks ac
     WHERE  ac.org_id = asp.org_id
       AND  ac.check_id = x_check_id;

   --bug 9069767 starts
   IF (X_Exchange_Rate_Type IS NULL OR
	X_Exchange_Rate_Date IS NULL OR
	X_Exchange_Rate IS NULL) THEN
	   -------------------------------------------------------------------
	    l_debug_info := 'Defaulting Exchange Rate values from Check';
		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	    END IF;
	   ---------------------------------------------------------------
	   SELECT exchange_rate,
		      exchange_date,
		      exchange_rate_type
	   INTO    l_exchange_rate,
		      l_exchange_date,
                      l_exchange_rate_type
           FROM ap_checks_all
	   WHERE check_id = X_CHECK_ID;
   END IF;
   --bug 9069767 ends

   ---------------------------------------------------------------
    l_debug_info := 'Call rounding function';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
   ---------------------------------------------------------------
    l_trx_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY (
                             -- X_Transaction_Amount*nvl(X_Exchange_Rate, 1),
                             -- Bug 3168106
                             X_Transaction_Amount* NVL(X_Exchange_Rate, l_exchange_rate), --bug 9069767
                             l_functional_currency_code );

   -------------------------------------------------------------
    l_debug_info := 'Insert Payment History';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
   ---------------------------------------------------------------

    AP_RECONCILIATION_PKG.Insert_Payment_History
       ( X_CHECK_ID                => X_CHECK_ID,
         X_TRANSACTION_TYPE        => X_TRANSACTION_TYPE,
         X_ACCOUNTING_DATE         => X_ACCOUNTING_DATE,
         X_TRX_BANK_AMOUNT         => NULL,
         X_ERRORS_BANK_AMOUNT      => NULL,
         X_CHARGES_BANK_AMOUNT     => NULL,
         X_BANK_CURRENCY_CODE      => NULL,
         X_BANK_TO_BASE_XRATE_TYPE => NULL,
         X_BANK_TO_BASE_XRATE_DATE => NULL,
         X_BANK_TO_BASE_XRATE      => NULL,
         X_TRX_PMT_AMOUNT          => X_TRANSACTION_AMOUNT,
         X_ERRORS_PMT_AMOUNT       => NULL,
         X_CHARGES_PMT_AMOUNT      => NULL,
         X_PMT_CURRENCY_CODE       => X_CURRENCY_CODE,
         X_PMT_TO_BASE_XRATE_TYPE  => NVL(X_EXCHANGE_RATE_TYPE, l_exchange_rate_type), -- bug 9069767
         X_PMT_TO_BASE_XRATE_DATE  => NVL(X_EXCHANGE_RATE_DATE, l_exchange_date), --bug 9069767
         X_PMT_TO_BASE_XRATE       => NVL(X_EXCHANGE_RATE, l_exchange_rate), --bug 9069767
         X_TRX_BASE_AMOUNT         => l_trx_base_amount,
         X_ERRORS_BASE_AMOUNT      => NULL,
         X_CHARGES_BASE_AMOUNT     => NULL,
         X_MATCHED_FLAG            => NULL,
         X_REV_PMT_HIST_ID         => l_rev_pmt_hist_id, -- Bug3343314
         X_ORG_ID                  => l_org_id, -- Bug 4578865
         X_CREATION_DATE           => X_CREATION_DATE,
         X_CREATED_BY              => X_CREATED_BY,
         X_LAST_UPDATE_DATE        => X_LAST_UPDATE_DATE,
         X_LAST_UPDATED_BY         => X_LAST_UPDATED_BY,
         X_LAST_UPDATE_LOGIN       => X_LAST_UPDATE_LOGIN,
         X_PROGRAM_UPDATE_DATE     => X_PROGRAM_UPDATE_DATE,
         X_PROGRAM_APPLICATION_ID  => X_PROGRAM_APPLICATION_ID,
         X_PROGRAM_ID              => X_PROGRAM_ID,
         X_REQUEST_ID              => X_REQUEST_ID,
         X_CALLING_SEQUENCE        => CURRENT_CALLING_SEQUENCE ) ;

  ELSE
    APP_EXCEPTION.RAISE_EXCEPTION ;
  END IF ;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.SET_NAME('SQLAP','AP_RECON_NO_DATA_FOUND');
       APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
       IF (SQLCODE <> -20001) THEN
           FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
   	   FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;

END Recon_Payment_Maturity ;


/* *************************************************************************
   * DELETE_PAYMENT_MATURITY: Removes entry for payment maturity from      *
   *                          AP_PAYMENT_HISTORY for a particular check    *
   ************************************************************************* */

PROCEDURE Delete_Payment_Maturity (
  X_CHECK_ID                        NUMBER,
  X_CALLING_SEQUENCE                VARCHAR2
) AS
  current_calling_sequence        VARCHAR2(2000);
  l_debug_info                    VARCHAR2(240);
  l_api_name                  CONSTANT VARCHAR2(1000) := 'Delete_Payment_Maturity' ;

BEGIN
  current_calling_sequence := X_CALLING_SEQUENCE ||
                             'AP_RECONCILIATION_PKG.DELETE_PAYMENT_MATURITY' ;
    ----------------------------------------------------------------
	l_debug_info := 'Deleting from Payment History table';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
   ---------------------------------------------------------------

    DELETE FROM AP_PAYMENT_HISTORY
    WHERE       check_id              = x_check_id
    AND         transaction_type      = 'PAYMENT MATURITY'
    AND         nvl(posted_flag,'N')  = 'N';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.SET_NAME('SQLAP','AP_RECON_NO_DATA_FOUND');
    APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Delete_Payment_Maturity ;


/* *************************************************************************
   * RECON_PAYMENT_CLEARING: Creates entries/updates checks due to a       *
   *                         clearing event which may or may not be matched*
   *                         to a bank statement.                           *
   ************************************************************************* */

PROCEDURE Recon_Payment_Clearing(
  X_CHECKRUN_ID             NUMBER,
  X_CHECK_ID                NUMBER,
  X_ACCOUNTING_DATE         DATE,
  X_CLEARED_DATE            DATE,
  X_TRANSACTION_TYPE        VARCHAR2,
  X_TRX_BANK_AMOUNT         NUMBER,
  X_ERRORS_BANK_AMOUNT      NUMBER,
  X_CHARGES_BANK_AMOUNT     NUMBER,
  X_BANK_CURRENCY_CODE      VARCHAR2,
  X_PMT_TO_BASE_XRATE_TYPE  VARCHAR2,
  X_PMT_TO_BASE_XRATE_DATE  DATE,
  X_PMT_TO_BASE_XRATE       NUMBER,
  X_MATCHED_FLAG            VARCHAR2,
  X_ACTUAL_VALUE_DATE       DATE,
  X_LAST_UPDATE_DATE        DATE,
  X_LAST_UPDATED_BY         NUMBER,
  X_LAST_UPDATE_LOGIN       NUMBER,
  X_CREATED_BY              NUMBER,
  X_CREATION_DATE           DATE,
  X_PROGRAM_UPDATE_DATE     DATE,
  X_PROGRAM_APPLICATION_ID  NUMBER,
  X_PROGRAM_ID              NUMBER,
  X_REQUEST_ID              NUMBER,
  X_CALLING_SEQUENCE        VARCHAR2
) AS

  --bugfix:5623562
  l_recon_accounting_flag       ap_system_parameters.recon_accounting_flag%TYPE;
  l_currency_case               VARCHAR2(30);
  l_status_code                 VARCHAR2(30) ;

  l_pmt_currency_code           ap_checks.currency_code%TYPE;
  l_functional_currency_code    ap_system_parameters.base_currency_code%TYPE;
  l_bank_to_base_xrate          ap_checks.exchange_rate%TYPE;
  l_bank_to_base_xrate_type     ap_checks.exchange_rate_type%TYPE;
  l_bank_to_base_xrate_date     ap_checks.exchange_date%TYPE;
  l_trx_pmt_amount              NUMBER;
  l_errors_pmt_amount           NUMBER;
  l_charges_pmt_amount          NUMBER;
  l_trx_base_amount             NUMBER;
  l_errors_base_amount          NUMBER;
  l_charges_base_amount         NUMBER;
  l_remainder_errors_pmt_amt    ap_checks.amount%TYPE;
  l_remainder_charges_pmt_amt   ap_checks.amount%TYPE;
  l_errors_bank_amount          ap_checks.amount%TYPE;
  l_charges_bank_amount         ap_checks.amount%TYPE;

  l_max_pmt_amt                 ap_checks.amount%TYPE;
  l_pay_sum_amt                 ap_checks.amount%TYPE;
  l_payment_count               NUMBER;
  l_pmt_not_matured             NUMBER := 0 ;
  l_running_total_payments      NUMBER := 0;
  l_runtotal_trx_bank_amount    NUMBER := 0;
  l_runtotal_errors_bank_amount NUMBER := 0;
  l_runtotal_charges_bank_amount NUMBER := 0;
  l_check_amount                ap_checks.amount%TYPE;
  l_check_id                    ap_checks.check_id%TYPE;
  l_payment_xrate               ap_checks.exchange_rate%TYPE;
  l_status_lookup_code          ap_checks.status_lookup_code%TYPE;

  l_future_pay_flag             VARCHAR2(1) ;
  l_ind_errors_pmt_amount       ap_checks.amount%TYPE;
  l_ind_charges_pmt_amount      ap_checks.amount%TYPE;
  l_debug_info                  VARCHAR2(2400);
  l_org_id                      NUMBER;
  l_distinct_org                NUMBER;   -- Bug 5674397

  current_calling_sequence      VARCHAR2(2000);
  cant_do_recon_acct            EXCEPTION;
  l_api_name                  CONSTANT VARCHAR2(1000) := 'Recon_Payment_Clearing' ;

  -- bug8628166
  l_pmt_to_base_xrate          ap_checks.exchange_rate%TYPE;
  l_pmt_to_base_xrate_type     ap_checks.exchange_rate_type%TYPE;
  l_pmt_to_base_xrate_date     ap_checks.exchange_date%TYPE;

  -- Distinct Org Cursor
  -- Bug 5674397
  CURSOR distinct_org_cur IS
  SELECT distinct org_id
  FROM   ap_checks
  WHERE  checkrun_id = X_CHECKRUN_ID;

    -- Payment Batch Cursor
  -- Bug 5674397. Added the parameter
  CURSOR pay_batch_cur(P_org_id IN NUMBER) IS
    SELECT      c.check_id,
                c.status_lookup_code,
                nvl(c.amount,0),
                nvl(c.exchange_rate,1),
                decode(c.future_pay_due_date,NULL,'N','Y'),
                c.currency_code,
                asp.base_currency_code,
                asp.org_id,
                nvl(asp.recon_accounting_flag, 'N')
    FROM        ap_checks_all c,
                ap_system_parameters_all asp
    WHERE       c.checkrun_id = X_CHECKRUN_id
    AND         c.org_id  = p_org_id
    AND         c.org_id  = asp.org_id
    AND c.status_lookup_code NOT IN      -- Bug 3408260
            ('VOIDED','SPOILED','OVERFLOW','SETUP','STOP INITIATED',
            'UNCONFIRMED SET UP',
/* 3575546  fbreslin: Add other statuses to skip. */
                 'RECONCILED', 'RECONCILED UNACCOUNTED',
                 'ISSUED')
    GROUP BY    c.check_id,
                c.status_lookup_code,
                nvl(c.amount,0),
                nvl(c.exchange_rate,1),
                decode(c.future_pay_due_date,NULL,'N','Y'),
                c.currency_code,
                asp.base_currency_code,
                asp.org_id,
                nvl(recon_accounting_flag, 'N')
    ORDER BY    nvl(c.amount,0);

BEGIN
  current_calling_sequence := X_CALLING_SEQUENCE ||
                             'AP_RECONCILIATION_PKG.RECON_PAYMENT_CLEARING' ;


  --bugfix:5623562
  --bug 5674397. Comment the following section
  /*
  SELECT  nvl(recon_accounting_flag, 'N'),
          base_currency_code
  INTO    l_recon_accounting_flag,
          l_functional_currency_code
  FROM    ap_system_parameters;
  */
  l_errors_bank_amount  := nvl(X_ERRORS_BANK_AMOUNT,0);
  l_charges_bank_amount := nvl(X_CHARGES_BANK_AMOUNT,0);

  IF (X_CHECKRUN_ID IS NOT NULL ) THEN

   ---------------------------------------------------------------
   l_debug_info := ' Inside checkrun is not null';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
   ---------------------------------------------------------------
   -- Bug 5674397 Moving at the begining
   SELECT count(check_id), sum(amount) , max(amount)
   INTO   l_payment_count, l_pay_sum_amt, l_max_pmt_amt
   FROM   AP_CHECKS
   WHERE  checkrun_id = x_checkrun_id
   AND status_lookup_code NOT IN
         ('VOIDED','SETUP', 'OVERFLOW','SPOILED',
          'STOP INITIATED','UNCONFIRMED SET UP',
          'RECONCILED', 'RECONCILED UNACCOUNTED',
          'ISSUED');


    -- Bug 5674397
   OPEN distinct_org_cur ;
   LOOP

   FETCH distinct_org_cur INTO  l_distinct_org;
   ---------------------------------------------------------------
   l_debug_info := 'Inside distinct_org_cur cursor';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
   ---------------------------------------------------------------

   IF distinct_org_cur%NOTFOUND THEN
    IF distinct_org_cur%ROWCOUNT < 1 THEN
      RAISE no_data_found;
    ELSE                       -- No more rows
      EXIT ;
    END IF;
   END IF;

     -- Bug 5674397. Moving the cursor before cas type
     l_running_total_payments := 0;

     OPEN pay_batch_cur(l_org_id) ;
     LOOP

      -- bug 4578865
     FETCH pay_batch_cur INTO
                l_check_id,
                l_status_lookup_code,
                l_check_amount,
                l_payment_xrate,
                l_future_pay_flag,
                l_pmt_currency_code,
                l_functional_currency_code,
                l_org_id,
                l_recon_accounting_flag;

   -----------------------------------------------------------------
     l_debug_info := 'Inside pay_batch_cur cursor';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;
   ---------------------------------------------------------------
     IF pay_batch_cur%NOTFOUND THEN
       IF pay_batch_cur%ROWCOUNT < 1 THEN
          RAISE no_data_found;
       ELSE                       -- No more rows
          EXIT ;
       END IF;
     END IF;

     l_running_total_payments := l_running_total_payments + l_check_amount;
   -- bug 4578865

   /*  Bug 5674397, Combining into cursor
   SELECT ac.currency_code,
          asp.base_currency_code,
          asp.org_id,
          nvl(recon_accounting_flag, 'N')  -- Bug 5674397
    INTO   l_pmt_currency_code,
           l_functional_currency_code,
           l_org_id,
           l_recon_accounting_flag
    FROM   ap_checks ac,
           ap_system_parameters asp
    WHERE  ac.checkrun_id = X_CHECKRUN_ID
    AND    asp.org_id = ac.org_id
    AND    ac.org_id  = l_distinct_org
    AND    rownum = 1;
    */
   ---------------------------------------------------------------
    l_debug_info := 'Got payment currency and other system options, calling case_type';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
   ---------------------------------------------------------------

    l_currency_case := Case_Type(
                                 X_BANK_CURRENCY_CODE,
                                 l_pmt_currency_code,
                                 l_functional_currency_code
                                );

    -- bug8628166 - begin
    l_pmt_to_base_xrate_date := X_PMT_TO_BASE_XRATE_DATE;
    l_pmt_to_base_xrate_type := X_PMT_TO_BASE_XRATE_TYPE;
    l_pmt_to_base_xrate      := X_PMT_TO_BASE_XRATE;

    IF (l_currency_case IN ('INTERNATIONAL',  'FOREIGN')) THEN
	IF (X_PMT_TO_BASE_XRATE IS NULL OR		   --bug 9069767
           X_PMT_TO_BASE_XRATE_TYPE IS NULL OR X_PMT_TO_BASE_XRATE_DATE IS NULL) THEN
         SELECT exchange_date,
                exchange_rate_type,
                exchange_rate
           INTO l_pmt_to_base_xrate_date,
                l_pmt_to_base_xrate_type,
                l_pmt_to_base_xrate
           FROM ap_checks_all ac
          WHERE check_id = l_check_id;
	END IF;
    END IF;
    -- bug8628166 - end

    -- If international or  cross currency, convert to payment currency
    -- the errors and charges before proration.

    IF (l_currency_case = 'INTERNATIONAL') THEN
	 -----------------------------------------------------------------
      l_debug_info := 'Inside International';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
     ---------------------------------------------------------------
      l_remainder_errors_pmt_amt := AP_UTILITIES_PKG.AP_ROUND_CURRENCY (
                             l_errors_bank_amount / nvl(l_pmt_to_base_xrate,1), --bug8628166
                             l_pmt_currency_code );
      l_remainder_charges_pmt_amt := AP_UTILITIES_PKG.AP_ROUND_CURRENCY (
                             l_charges_bank_amount / nvl(l_pmt_to_base_xrate,1), --bug8628166
                             l_pmt_currency_code );

      -- Since the bank and base currencies are the same ...

      l_bank_to_base_xrate_type := NULL;
      l_bank_to_base_xrate_date := NULL;
      l_bank_to_base_xrate := NULL;

    ELSIF (l_currency_case = 'FOREIGN') THEN
      ---------------------------------------------------------
	  l_debug_info := 'Inside Foreign';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;
      ---------------------------------------------------------
      l_remainder_errors_pmt_amt := l_errors_bank_amount;
      l_remainder_charges_pmt_amt := l_charges_bank_amount;
      l_bank_to_base_xrate_type := l_pmt_to_base_xrate_type; --bug8628166
      l_bank_to_base_xrate_date := l_pmt_to_base_xrate_date; --bug8628166
      l_bank_to_base_xrate := l_pmt_to_base_xrate;           --bug8628166

    ELSIF (l_currency_case = 'DOMESTIC') THEN
      -------------------------------------------------------
	  l_debug_info := 'Inside Domestic';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      ---------------------------------------------------------------
      l_remainder_errors_pmt_amt := l_errors_bank_amount;
      l_remainder_charges_pmt_amt := l_charges_bank_amount;
      l_bank_to_base_xrate_type := NULL;
      l_bank_to_base_xrate_date := NULL;
      l_bank_to_base_xrate := NULL;

    END IF;

    -- Prepare errors and charges for proration.  Now the amounts
    -- should be in payment currency
    l_errors_pmt_amount := l_remainder_errors_pmt_amt;
    l_charges_pmt_amount := l_remainder_charges_pmt_amt;

    -- Check if batch contains a future pmt check which has not matured
    -----------------------------------------------------------------------
	l_debug_info := 'Check for future pmt checks, that are not matured';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
   ------------------------------------------------------------------------

      -- We cannot clear an already cleared check
      IF ((X_MATCHED_FLAG <> 'Y' ) AND
          (l_status_lookup_code IN ('CLEARED','CLEARED BUT UNACCOUNTED'))) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_RECON_CLEARED_UNMATCHED');
        RAISE G_abort_it;
      END IF ;

      IF (l_pay_sum_amt = 0) THEN
        -----------------------------------------------------------------
        l_debug_info := 'Inside l_pay_sum_amt is 0';
		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ---------------------------------------------------------------

        l_ind_errors_pmt_amount  := AP_UTILITIES_PKG.AP_ROUND_CURRENCY (
                                    l_errors_pmt_amount/l_payment_count,
                                    l_pmt_currency_code );
        l_ind_charges_pmt_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY (
                                    l_charges_pmt_amount/l_payment_count,
                                    l_pmt_currency_code );

      ELSIF (l_running_total_payments = l_pay_sum_amt) THEN
	    ---------------------------------------------------------------
        l_debug_info := 'Inside l_pay_sum_amt is running total';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ---------------------------------------------------------------
        l_ind_errors_pmt_amount := l_remainder_errors_pmt_amt;
        l_ind_charges_pmt_amount := l_remainder_charges_pmt_amt;

      ELSE
	    --------------------------------------------------------------
        l_debug_info := 'Inside l_pay_sum_amt is another value';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ---------------------------------------------------------------
        l_ind_errors_pmt_amount  := AP_UTILITIES_PKG.AP_ROUND_CURRENCY (
                                    l_errors_pmt_amount*l_check_amount
                                                       /l_pay_sum_amt,
                                    l_pmt_currency_code );
        l_ind_charges_pmt_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY (
                                    l_charges_pmt_amount*l_check_amount
                                                        /l_pay_sum_amt,
                                    l_pmt_currency_code );

      END IF ; /* Total payment batch amount is 0 */

      --Bug 8578716 Begins
      IF ( X_MATCHED_FLAG = 'Y') THEN
         IF l_recon_accounting_flag = 'Y' THEN
            IF (l_status_lookup_code = 'NEGOTIABLE') THEN
               l_status_code    := 'RECONCILED UNACCOUNTED' ;
            ELSIF (l_status_lookup_code = 'CLEARED BUT UNACCOUNTED') THEN
               l_status_code    := 'RECONCILED UNACCOUNTED';
            ELSIF (l_status_lookup_code = 'CLEARED') THEN
               l_status_code    := 'RECONCILED';
            END IF;
         ELSE
            l_status_code              := 'RECONCILED';
         END IF;
      ELSE
         IF l_recon_accounting_flag      = 'Y' THEN
            l_status_code := 'CLEARED BUT UNACCOUNTED';
         ELSE
            l_status_code := 'CLEARED';
         END IF;
      END IF ;
      --Bug 8578716 Ends
	  -------------------------------------------------------------------------------

	  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
				'Matched_flag ->'||X_MATCHED_FLAG);
			  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
				'status_lookup_code '||l_status_lookup_code);
			  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
				'status_code'||l_status_code);
		 end if ;

	  ------------------------------------------------------------------------------
      -- Only insert into payment history if reconciliation accounting is ON.
      -----------------------------------------------------------------
	  l_debug_info := 'Set l_status_code';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      ---------------------------------------------------------------

      --bugfix:5623562
      IF ( l_recon_accounting_flag = 'Y' AND
      		l_status_lookup_code = 'NEGOTIABLE') THEN

        IF (l_currency_case = 'INTERNATIONAL') THEN

          IF (l_running_total_payments = l_pay_sum_amt) THEN
           ----------------------------------------------------------------
		   l_debug_info := 'Inside Negotiable, International amounts equal';
			IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;
           ---------------------------------------------------------------

            l_trx_base_amount := X_TRX_BANK_AMOUNT - l_runtotal_trx_bank_amount;
            l_errors_base_amount := X_ERRORS_BANK_AMOUNT
                                         - l_runtotal_errors_bank_amount;
            l_charges_base_amount := X_CHARGES_BANK_AMOUNT
                                         - l_runtotal_charges_bank_amount;
          ELSE
		    -------------------------------------------------------------------
            l_debug_info := 'Inside Negotiable, International amounts not eq';
			IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;
            ---------------------------------------------------------------

            l_trx_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                     (l_check_amount + l_ind_errors_pmt_amount
                      + l_ind_charges_pmt_amount) * nvl(l_pmt_to_base_xrate,1),
                     l_functional_currency_code); --bug8628166
            l_errors_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                                                  l_ind_errors_pmt_amount
                                                   * nvl(l_pmt_to_base_xrate,1),
                                                  l_functional_currency_code); -- bug8628166
            l_charges_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                                                  l_ind_charges_pmt_amount
                                                   * nvl(l_pmt_to_base_xrate,1),                                                 l_functional_currency_code); --bug8628166
          END IF;

          l_runtotal_trx_bank_amount := l_runtotal_trx_bank_amount
                                         + l_trx_base_amount;
          l_runtotal_errors_bank_amount := l_runtotal_errors_bank_amount
                                            + l_errors_base_amount;
          l_runtotal_charges_bank_amount := l_runtotal_charges_bank_amount
                                             + l_charges_base_amount;

          -- Bug 2276503
          --IF Check_Not_Accounted_To_Cash(l_check_id) THEN
          -- Commenting condition for bug 2626686 as accounting is now created correctly
            --------------------------------------------------------------------
			l_debug_info := 'Inside International, Negotiable, before insert';
			IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;
            ---------------------------------------------------------------

            AP_RECONCILIATION_PKG.Insert_Payment_History
               ( X_CHECK_ID               => l_check_id,
                 X_TRANSACTION_TYPE       => X_TRANSACTION_TYPE,
                 X_ACCOUNTING_DATE        => X_ACCOUNTING_DATE,
                 X_TRX_BANK_AMOUNT        => l_trx_base_amount,
                 X_ERRORS_BANK_AMOUNT     => l_errors_base_amount,
                 X_CHARGES_BANK_AMOUNT    => l_charges_base_amount,
                 X_BANK_CURRENCY_CODE     => X_BANK_CURRENCY_CODE,
                 X_BANK_TO_BASE_XRATE_TYPE=> l_bank_to_base_xrate_type,
                 X_BANK_TO_BASE_XRATE_DATE=> l_bank_to_base_xrate_date,
                 X_BANK_TO_BASE_XRATE     => l_bank_to_base_xrate,
                 X_TRX_PMT_AMOUNT         => l_check_amount
                                             + l_ind_errors_pmt_amount
                                             + l_ind_charges_pmt_amount,
                 X_ERRORS_PMT_AMOUNT      => l_ind_errors_pmt_amount,
                 X_CHARGES_PMT_AMOUNT     => l_ind_charges_pmt_amount,
                 X_PMT_CURRENCY_CODE      => l_pmt_currency_code,
                 X_PMT_TO_BASE_XRATE_TYPE => l_pmt_to_base_xrate_type, --bug8628166
                 X_PMT_TO_BASE_XRATE_DATE => l_pmt_to_base_xrate_date, --bug8628166
                 X_PMT_TO_BASE_XRATE      => l_pmt_to_base_xrate,      --bug8628166
                 X_TRX_BASE_AMOUNT        => l_trx_base_amount,
                 X_ERRORS_BASE_AMOUNT     => l_errors_base_amount,
                 X_CHARGES_BASE_AMOUNT    => l_charges_base_amount,
                 X_MATCHED_FLAG           => X_MATCHED_FLAG,
                 X_REV_PMT_HIST_ID        => NULL,
                 X_ORG_ID                 => l_org_id,  -- bug 4578865
                 X_CREATION_DATE          => X_CREATION_DATE,
                 X_CREATED_BY             => X_CREATED_BY,
                 X_LAST_UPDATE_DATE       => X_LAST_UPDATE_DATE,
                 X_LAST_UPDATED_BY        => X_LAST_UPDATED_BY,
                 X_LAST_UPDATE_LOGIN      => X_LAST_UPDATE_LOGIN,
                 X_PROGRAM_UPDATE_DATE    => X_PROGRAM_UPDATE_DATE,
                 X_PROGRAM_APPLICATION_ID => X_PROGRAM_APPLICATION_ID,
                 X_PROGRAM_ID             => X_PROGRAM_ID,
                 X_REQUEST_ID             => X_REQUEST_ID,
                 X_CALLING_SEQUENCE       => CURRENT_CALLING_SEQUENCE ) ;
          --END IF;

        ELSIF (l_currency_case = 'FOREIGN') THEN
		  -----------------------------------------------------------------
          l_debug_info := 'Inside Negotiable, Foreign';
		  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;
          ---------------------------------------------------------------

          l_trx_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                     (l_check_amount + l_ind_errors_pmt_amount
                       + l_ind_charges_pmt_amount) * nvl(l_pmt_to_base_xrate,1),
                     l_functional_currency_code); --bug8628166
          l_errors_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                                                 l_ind_errors_pmt_amount
                                                  * nvl(l_pmt_to_base_xrate,1),
                                                 l_functional_currency_code); --bug8628166
          l_charges_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                                                 l_ind_charges_pmt_amount
                                                  * nvl(l_pmt_to_base_xrate,1),
                                                 l_functional_currency_code); --bug8628166
          -- Bug 2276503
          --IF Check_Not_Accounted_To_Cash(l_check_id) THEN
          -- Commenting condition for bug 2626686 as accounting is now created correctly
		    ------------------------------------------------------------------
            l_debug_info := 'Insert history for Negotiable, Foreign';
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;
            ---------------------------------------------------------------
            AP_RECONCILIATION_PKG.Insert_Payment_History
               ( X_CHECK_ID               => l_check_id,
                 X_TRANSACTION_TYPE       => X_TRANSACTION_TYPE,
                 X_ACCOUNTING_DATE        => X_ACCOUNTING_DATE,
                 X_TRX_BANK_AMOUNT        => l_check_amount
                                             + l_ind_errors_pmt_amount
                                             + l_ind_charges_pmt_amount,
                 X_ERRORS_BANK_AMOUNT     => l_ind_errors_pmt_amount,
                 X_CHARGES_BANK_AMOUNT    => l_ind_charges_pmt_amount,
                 X_BANK_CURRENCY_CODE     => X_BANK_CURRENCY_CODE,
                 X_BANK_TO_BASE_XRATE_TYPE=> l_bank_to_base_xrate_type,
                 X_BANK_TO_BASE_XRATE_DATE=> l_bank_to_base_xrate_date,
                 X_BANK_TO_BASE_XRATE     => l_bank_to_base_xrate,
                 X_TRX_PMT_AMOUNT         => l_check_amount
                                             + l_ind_errors_pmt_amount
                                             + l_ind_charges_pmt_amount,
                 X_ERRORS_PMT_AMOUNT      => l_ind_errors_pmt_amount,
                 X_CHARGES_PMT_AMOUNT     => l_ind_charges_pmt_amount,
                 X_PMT_CURRENCY_CODE      => l_pmt_currency_code,
                 X_PMT_TO_BASE_XRATE_TYPE => l_pmt_to_base_xrate_type, --bug8628166
                 X_PMT_TO_BASE_XRATE_DATE => l_pmt_to_base_xrate_date, --bug8628166
                 X_PMT_TO_BASE_XRATE      => l_pmt_to_base_xrate,      --bug8628166
                 X_TRX_BASE_AMOUNT        => l_trx_base_amount,
                 X_ERRORS_BASE_AMOUNT     => l_errors_base_amount,
                 X_CHARGES_BASE_AMOUNT    => l_charges_base_amount,
                 X_MATCHED_FLAG           => X_MATCHED_FLAG,
                 X_REV_PMT_HIST_ID        => NULL,
                 X_ORG_ID                 => l_org_id, -- Bug 4578865
                 X_CREATION_DATE          => X_CREATION_DATE,
                 X_CREATED_BY             => X_CREATED_BY,
                 X_LAST_UPDATE_DATE       => X_LAST_UPDATE_DATE,
                 X_LAST_UPDATED_BY        => X_LAST_UPDATED_BY,
                 X_LAST_UPDATE_LOGIN      => X_LAST_UPDATE_LOGIN,
                 X_PROGRAM_UPDATE_DATE    => X_PROGRAM_UPDATE_DATE,
                 X_PROGRAM_APPLICATION_ID => X_PROGRAM_APPLICATION_ID,
                 X_PROGRAM_ID             => X_PROGRAM_ID,
                 X_REQUEST_ID             => X_REQUEST_ID,
                 X_CALLING_SEQUENCE       => CURRENT_CALLING_SEQUENCE ) ;

          --END IF;

        ELSIF (l_currency_case = 'DOMESTIC') THEN

          l_trx_base_amount := l_check_amount + l_ind_errors_pmt_amount
                                + l_ind_charges_pmt_amount;
          l_errors_base_amount := l_ind_errors_pmt_amount;
          l_charges_base_amount := l_ind_charges_pmt_amount;

          -- Bug 2276503
          --IF Check_Not_Accounted_To_Cash(l_check_id) THEN
          -- Commenting condition for bug 2626686 as accounting is now created correctly
		    ----------------------------------------------------------------
            l_debug_info := 'Inside Negotiable, Domestic, before Insert';
			IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;
            ---------------------------------------------------------------

            AP_RECONCILIATION_PKG.Insert_Payment_History
               ( X_CHECK_ID               => l_check_id,
                 X_TRANSACTION_TYPE       => X_TRANSACTION_TYPE,
                 X_ACCOUNTING_DATE        => X_ACCOUNTING_DATE,
                 X_TRX_BANK_AMOUNT        => l_check_amount
                                             + l_ind_errors_pmt_amount
                                             + l_ind_charges_pmt_amount,
                 X_ERRORS_BANK_AMOUNT     => l_ind_errors_pmt_amount,
                 X_CHARGES_BANK_AMOUNT    => l_ind_charges_pmt_amount,
                 X_BANK_CURRENCY_CODE     => X_BANK_CURRENCY_CODE,
                 X_BANK_TO_BASE_XRATE_TYPE=> l_bank_to_base_xrate_type,
                 X_BANK_TO_BASE_XRATE_DATE=> l_bank_to_base_xrate_date,
                 X_BANK_TO_BASE_XRATE     => l_bank_to_base_xrate,
                 X_TRX_PMT_AMOUNT         => l_check_amount
                                             + l_ind_errors_pmt_amount
                                             + l_ind_charges_pmt_amount,
                 X_ERRORS_PMT_AMOUNT      => l_ind_errors_pmt_amount,
                 X_CHARGES_PMT_AMOUNT     => l_ind_charges_pmt_amount,
                 X_PMT_CURRENCY_CODE      => l_pmt_currency_code,
                 X_PMT_TO_BASE_XRATE_TYPE => l_pmt_to_base_xrate_type,--bug8628166
                 X_PMT_TO_BASE_XRATE_DATE => l_pmt_to_base_xrate_date,--bug8628166
                 X_PMT_TO_BASE_XRATE      => l_pmt_to_base_xrate,--bug8628166
                 X_TRX_BASE_AMOUNT        => l_trx_base_amount,
                 X_ERRORS_BASE_AMOUNT     => l_errors_base_amount,
                 X_CHARGES_BASE_AMOUNT    => l_charges_base_amount,
                 X_MATCHED_FLAG           => X_MATCHED_FLAG,
                 X_REV_PMT_HIST_ID        => NULL,
                 X_ORG_ID                 => l_org_id, -- Bug 4578865
                 X_CREATION_DATE          => X_CREATION_DATE,
                 X_CREATED_BY             => X_CREATED_BY,
                 X_LAST_UPDATE_DATE       => X_LAST_UPDATE_DATE,
                 X_LAST_UPDATED_BY        => X_LAST_UPDATED_BY,
                 X_LAST_UPDATE_LOGIN      => X_LAST_UPDATE_LOGIN,
                 X_PROGRAM_UPDATE_DATE    => X_PROGRAM_UPDATE_DATE,
                 X_PROGRAM_APPLICATION_ID => X_PROGRAM_APPLICATION_ID,
                 X_PROGRAM_ID             => X_PROGRAM_ID,
                 X_REQUEST_ID             => X_REQUEST_ID,
                 X_CALLING_SEQUENCE       => CURRENT_CALLING_SEQUENCE ) ;

          --END IF;

        END IF;

        l_remainder_errors_pmt_amt  := l_remainder_errors_pmt_amt
                                                  - l_ind_errors_pmt_amount ;
        l_remainder_charges_pmt_amt := l_remainder_charges_pmt_amt
                                                  - l_ind_charges_pmt_amount ;

      --bugfix:5623562 added the code under this ELSE stmt
      ELSIF (l_recon_accounting_flag <> 'Y') THEN
          ----------------------------------------------------------------
          l_debug_info := 'Inside recon flag not Y';
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;
          ---------------------------------------------------------------
          -- Bug 4538437 : Following IF condition is added so that base amounts
          -- are populated even if recon_accounting_flag = 'N'
          IF (l_currency_case = 'INTERNATIONAL') THEN

              IF (l_running_total_payments = l_pay_sum_amt) THEN


	              l_trx_base_amount := X_TRX_BANK_AMOUNT - l_runtotal_trx_bank_amount;
                      l_errors_base_amount := X_ERRORS_BANK_AMOUNT
                                            - l_runtotal_errors_bank_amount;
                      l_charges_base_amount := X_CHARGES_BANK_AMOUNT
                                              - l_runtotal_charges_bank_amount;
               ELSE

	              l_trx_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
 		                               (l_check_amount + l_ind_errors_pmt_amount
		                                 + l_ind_charges_pmt_amount)
			                          * nvl(l_pmt_to_base_xrate,1),
			                           l_functional_currency_code); --bug8628166
		      l_errors_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
		                                  l_ind_errors_pmt_amount
		                                    * nvl(l_pmt_to_base_xrate,1),
		                                  l_functional_currency_code); --bug8628166
	              l_charges_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
	                                          l_ind_charges_pmt_amount
	                                           * nvl(l_pmt_to_base_xrate,1),
		                                    l_functional_currency_code); --bug8628166
              END IF;

          ELSIF (l_currency_case = 'FOREIGN') THEN

	       l_trx_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
	                               (l_check_amount + l_ind_errors_pmt_amount
				         + l_ind_charges_pmt_amount)
					 * nvl(l_pmt_to_base_xrate,1),
					  l_functional_currency_code); -- bug8628166
               l_errors_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
	                                l_ind_errors_pmt_amount
   	                                 * nvl(l_pmt_to_base_xrate,1),
					  l_functional_currency_code);  --bug8628166
               l_charges_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
   	                                l_ind_charges_pmt_amount
				         * nvl(l_pmt_to_base_xrate,1),
				          l_functional_currency_code); --bug8628166

           ELSIF (l_currency_case = 'DOMESTIC') THEN

                l_trx_base_amount := l_check_amount + l_ind_errors_pmt_amount
                                      + l_ind_charges_pmt_amount;
  		                      l_errors_base_amount := l_ind_errors_pmt_amount;
                l_charges_base_amount := l_ind_charges_pmt_amount;


            END IF;   -- Bug 4538437 IF condition end here

            IF (l_future_pay_flag <> 'Y') THEN    -- not a future payment
	        IF ((nvl(X_ERRORS_BANK_AMOUNT,0) <> 0) OR
	            (nvl(X_CHARGES_BANK_AMOUNT,0) <> 0)) THEN
																               RAISE cant_do_recon_acct;
	        ELSE
                  --bug8628166
	          IF ((l_pmt_to_base_xrate_type IS NOT NULL) OR
	              (l_pmt_to_base_xrate_date IS NOT NULL) OR
	              (l_pmt_to_base_xrate IS NOT NULL)) THEN  -- xrate info passed
                      --bug8628166
	              IF (l_payment_xrate <> l_pmt_to_base_xrate) THEN  -- pay <> recon
																                      RAISE cant_do_recon_acct;
		      END IF;   -- l_payment_xrate <> XRATE
		  END IF;   -- xrate_type, xrate_date, xrate is not null
		END IF;   -- error_amount <> 0 and charge_amount <> 0
            END IF;  -- l_future_pay_flag <> 'Y'

      END IF ;/* Reconciliation accounting and matched flag */

      -- Status needs to be updated depending upon matching flag irrespective
      -- of reconciliation accouting is on or OFF
	-----------------------------------------------------------------
  	l_debug_info := 'Before recon_update_check call';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    ---------------------------------------------------------------
	-----------------------------------------------------------------
	 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
				'check_id ->'||l_check_id);
			  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
				'cleared_date -> '||X_CLEARED_DATE);
			  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
				'status_code ->'||l_status_code);
		 end if ;
    -----------------------------------------------------------------
        IF NOT (Recon_Update_Check(l_check_id,
                                   l_check_amount+l_ind_errors_pmt_amount
                                                 +l_ind_charges_pmt_amount,
                                   l_trx_base_amount,
                                   l_ind_errors_pmt_amount,
                                   l_errors_base_amount,
                                   l_ind_charges_pmt_amount,
                                   l_charges_base_amount,
                                   X_CLEARED_DATE,
                                   l_status_code,
                                   l_pmt_to_base_xrate, --bug8628166
                                   l_pmt_to_base_xrate_type, --bug8628166
                                   l_pmt_to_base_xrate_date, --bug8628166
                                   X_ACTUAL_VALUE_DATE,
                                   X_LAST_UPDATED_BY,
                                   X_LAST_UPDATE_LOGIN,
                                   X_REQUEST_ID )) THEN
          RAISE G_abort_it;
        END IF;  -- recon_update_check

      END LOOP ; /* Loop through checks in a payment batch */

      CLOSE pay_batch_cur ;

    END LOOP;

    CLOSE distinct_org_cur;  /* end distinct org cursor */

  ELSE    /* checkrun_id is null....... */
   ---------------------------------------------------------------------
    l_debug_info := 'Inside checkrun is null';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    ---------------------------------------------------------------
    -- Single Payment
    -- Select to retrieve check information
    -- bug 4578865
    SELECT c.currency_code,
           c.status_lookup_code,
           nvl(c.amount, 0),
           nvl(c.exchange_rate,1),
           decode(c.future_pay_due_date,NULL,'N','Y'),
           asp.base_currency_code,
           asp.org_id,
           nvl(recon_accounting_flag, 'N')  -- Bug 5674397
    INTO   l_pmt_currency_code,
           l_status_lookup_code,
           l_check_amount,
           l_payment_xrate,
           l_future_pay_flag,
           l_functional_currency_code,
           l_org_id,
           l_recon_accounting_flag
    FROM   ap_checks_all c,
           ap_system_parameters_all asp
    WHERE  c.check_id = X_CHECK_ID
      AND  c.org_id = asp.org_id;

    IF ((l_status_lookup_code IN ('RECONCILED','RECONCILED UNACCOUNTED'))) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_RECON_ALREADY_RECONCILED');
      RAISE G_abort_it;
    END IF ;

    IF ((l_status_lookup_code = 'ISSUED') And (l_future_pay_flag = 'Y' )) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_RECON_PAYMENT_NOT_MATURED');
      RAISE G_abort_it;
    END IF ;

    IF ((X_MATCHED_FLAG <> 'Y' ) And
        (l_status_lookup_code In ('CLEARED','CLEARED BUT UNACCOUNTED'))) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_RECON_CLEARED_UNMATCHED');
      RAISE G_abort_it;
    END IF ;
	--------------------------------------------------------
    l_debug_info := 'checkrun is null, calling case_type';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    ---------------------------------------------------------------
    l_currency_case := Case_Type(
                                 X_BANK_CURRENCY_CODE,
                                 l_pmt_currency_code,
                                 l_functional_currency_code
                                );
        -- bug8628166 - begin
    l_pmt_to_base_xrate_date := X_PMT_TO_BASE_XRATE_DATE;
    l_pmt_to_base_xrate_type := X_PMT_TO_BASE_XRATE_TYPE;
    l_pmt_to_base_xrate      := X_PMT_TO_BASE_XRATE;

    IF (l_currency_case IN ('INTERNATIONAL',  'FOREIGN')) THEN
	IF (X_PMT_TO_BASE_XRATE IS NULL) AND
           (X_PMT_TO_BASE_XRATE_TYPE IS NULL OR X_PMT_TO_BASE_XRATE_DATE IS NULL) THEN
         SELECT exchange_date,
                exchange_rate_type,
                exchange_rate
           INTO l_pmt_to_base_xrate_date,
                l_pmt_to_base_xrate_type,
                l_pmt_to_base_xrate
           FROM ap_checks_all ac
          WHERE check_id = X_CHECK_ID;
	END IF;
    END IF;
    -- bug8628166 - end

    -- If international or  cross currency, convert to payment currency
    -- the errors and charges before proration.
    IF (l_currency_case = 'INTERNATIONAL') THEN
      l_debug_info := 'checkrun is null, inside International';

      l_ind_errors_pmt_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY (
                             l_errors_bank_amount / nvl(l_pmt_to_base_xrate,1),
                             l_pmt_currency_code ); --bug8628166
      l_ind_charges_pmt_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY (
                             l_charges_bank_amount / nvl(l_pmt_to_base_xrate,1),
                             l_pmt_currency_code ); --bug8628166

      -- Since the bank and base currencies are the same ...

      l_bank_to_base_xrate_type := NULL;
      l_bank_to_base_xrate_date := NULL;
      l_bank_to_base_xrate := NULL;

    ELSIF (l_currency_case = 'FOREIGN') THEN
      -----------------------------------------------------------
      l_debug_info := 'checkrun is null, inside Foreign';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      ---------------------------------------------------------------

      l_ind_errors_pmt_amount := l_errors_bank_amount;
      l_ind_charges_pmt_amount := l_charges_bank_amount;
      l_bank_to_base_xrate_type := l_pmt_to_base_xrate_type; --bug8628166
      l_bank_to_base_xrate_date := l_pmt_to_base_xrate_date; --bug8628166
      l_bank_to_base_xrate := l_pmt_to_base_xrate; --bug8628166

    ELSIF (l_currency_case = 'DOMESTIC') THEN
	 --------------------------------------------------------------
      l_debug_info := 'checkrun is null, inside Domestic';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
     ---------------------------------------------------------------
      l_ind_errors_pmt_amount := l_errors_bank_amount;
      l_ind_charges_pmt_amount := l_charges_bank_amount;
      l_bank_to_base_xrate_type := NULL;
      l_bank_to_base_xrate_date := NULL;
      l_bank_to_base_xrate := NULL;

    END IF;

    --Bug 8578716 Begins
    IF ( X_MATCHED_FLAG = 'Y') THEN
       IF l_recon_accounting_flag = 'Y' THEN
          IF (l_status_lookup_code = 'NEGOTIABLE') THEN
             l_status_code    := 'RECONCILED UNACCOUNTED' ;
          ELSIF (l_status_lookup_code = 'CLEARED BUT UNACCOUNTED') THEN
             l_status_code    := 'RECONCILED UNACCOUNTED';
          ELSIF (l_status_lookup_code = 'CLEARED') THEN
             l_status_code    := 'RECONCILED';
          END IF;
       ELSE
          l_status_code              := 'RECONCILED';
       END IF;
    ELSE
       IF l_recon_accounting_flag      = 'Y' THEN
          l_status_code := 'CLEARED BUT UNACCOUNTED';
       ELSE
          l_status_code := 'CLEARED';
       END IF;
    END IF ;
    --Bug 8578716 Ends

	-------------------------------------------------------------------------------

	  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
				'Matched_flag ->'||X_MATCHED_FLAG);
			  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
				'status_lookup_code '||l_status_lookup_code);
			  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
				'status_code'||l_status_code);
		 end if ;

	  ------------------------------------------------------------------------------


    -- Insert in only if allow_recon  ON
    --bugfix:5623562
    IF (l_recon_accounting_flag = 'Y' AND
    	l_status_lookup_code = 'NEGOTIABLE') THEN

        IF (l_currency_case = 'INTERNATIONAL') THEN

          l_trx_base_amount := X_TRX_BANK_AMOUNT;
          l_errors_base_amount := X_ERRORS_BANK_AMOUNT;
          l_charges_base_amount := X_CHARGES_BANK_AMOUNT;

          -- Bug 2276503
          --IF Check_Not_Accounted_To_Cash(l_check_id) THEN
          -- Commenting condition for bug 2626686 as accounting is now created correctly
            ---------------------------------------------------------------
            l_debug_info := 'Negotiable, International, before Insert';
			IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;
            ---------------------------------------------------------------
            AP_RECONCILIATION_PKG.Insert_Payment_History
               ( X_CHECK_ID               => X_check_id,
                 X_TRANSACTION_TYPE       => X_TRANSACTION_TYPE,
                 X_ACCOUNTING_DATE        => X_ACCOUNTING_DATE,
                 X_TRX_BANK_AMOUNT        => l_trx_base_amount,
                 X_ERRORS_BANK_AMOUNT     => l_errors_base_amount,
                 X_CHARGES_BANK_AMOUNT    => l_charges_base_amount,
                 X_BANK_CURRENCY_CODE     => X_BANK_CURRENCY_CODE,
                 X_BANK_TO_BASE_XRATE_TYPE=> l_bank_to_base_xrate_type,
                 X_BANK_TO_BASE_XRATE_DATE=> l_bank_to_base_xrate_date,
                 X_BANK_TO_BASE_XRATE     => l_bank_to_base_xrate,
                 X_TRX_PMT_AMOUNT         => l_check_amount
                                             + l_ind_errors_pmt_amount
                                             + l_ind_charges_pmt_amount,
                 X_ERRORS_PMT_AMOUNT      => l_ind_errors_pmt_amount,
                 X_CHARGES_PMT_AMOUNT     => l_ind_charges_pmt_amount,
                 X_PMT_CURRENCY_CODE      => l_pmt_currency_code,
                 X_PMT_TO_BASE_XRATE_TYPE => l_pmt_to_base_xrate_type, --bug8628166
                 X_PMT_TO_BASE_XRATE_DATE => l_pmt_to_base_xrate_date,  --bug8628166
                 X_PMT_TO_BASE_XRATE      => l_pmt_to_base_xrate, --bug8628166
                 X_TRX_BASE_AMOUNT        => l_trx_base_amount,
                 X_ERRORS_BASE_AMOUNT     => l_errors_base_amount,
                 X_CHARGES_BASE_AMOUNT    => l_charges_base_amount,
                 X_MATCHED_FLAG           => X_MATCHED_FLAG,
                 X_REV_PMT_HIST_ID        => NULL,
                 X_ORG_ID                 => l_org_id, -- bug 4578865
                 X_CREATION_DATE          => X_CREATION_DATE,
                 X_CREATED_BY             => X_CREATED_BY,
                 X_LAST_UPDATE_DATE       => X_LAST_UPDATE_DATE,
                 X_LAST_UPDATED_BY        => X_LAST_UPDATED_BY,
                 X_LAST_UPDATE_LOGIN      => X_LAST_UPDATE_LOGIN,
                 X_PROGRAM_UPDATE_DATE    => X_PROGRAM_UPDATE_DATE,
                 X_PROGRAM_APPLICATION_ID => X_PROGRAM_APPLICATION_ID,
                 X_PROGRAM_ID             => X_PROGRAM_ID,
                 X_REQUEST_ID             => X_REQUEST_ID,
                 X_CALLING_SEQUENCE       => CURRENT_CALLING_SEQUENCE ) ;

          --END IF;


        ELSIF (l_currency_case = 'FOREIGN') THEN

          l_trx_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                    (l_check_amount + l_ind_errors_pmt_amount
                      + l_ind_charges_pmt_amount) * nvl(l_pmt_to_base_xrate,1),
                    l_functional_currency_code); --bug8628166
          l_errors_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                          l_ind_errors_pmt_amount * nvl(l_pmt_to_base_xrate,1),
                          l_functional_currency_code); --bug8628166
          l_charges_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                         l_ind_charges_pmt_amount * nvl(l_pmt_to_base_xrate,1),
                         l_functional_currency_code); --bug8628166

          -- Bug 2276503
          --IF Check_Not_Accounted_To_Cash(l_check_id) THEN
          -- Commenting condition for bug 2626686 as accounting is now created correctly
		    ---------------------------------------------------------------
            l_debug_info := 'Negotiable, Foreign, before Insert';
			IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;
            ---------------------------------------------------------------

            AP_RECONCILIATION_PKG.Insert_Payment_History
               ( X_CHECK_ID               => X_check_id,
                 X_TRANSACTION_TYPE       => X_TRANSACTION_TYPE,
                 X_ACCOUNTING_DATE        => X_ACCOUNTING_DATE,
                 X_TRX_BANK_AMOUNT        => l_check_amount
                                             + l_ind_errors_pmt_amount
                                             + l_ind_charges_pmt_amount,
                 X_ERRORS_BANK_AMOUNT     => l_ind_errors_pmt_amount,
                 X_CHARGES_BANK_AMOUNT    => l_ind_charges_pmt_amount,
                 X_BANK_CURRENCY_CODE     => X_BANK_CURRENCY_CODE,
                 X_BANK_TO_BASE_XRATE_TYPE=> l_bank_to_base_xrate_type,
                 X_BANK_TO_BASE_XRATE_DATE=> l_bank_to_base_xrate_date,
                 X_BANK_TO_BASE_XRATE     => l_bank_to_base_xrate,
                 X_TRX_PMT_AMOUNT         => l_check_amount
                                             + l_ind_errors_pmt_amount
                                             + l_ind_charges_pmt_amount,
                 X_ERRORS_PMT_AMOUNT      => l_ind_errors_pmt_amount,
                 X_CHARGES_PMT_AMOUNT     => l_ind_charges_pmt_amount,
                 X_PMT_CURRENCY_CODE      => l_pmt_currency_code,
                 X_PMT_TO_BASE_XRATE_TYPE => l_pmt_to_base_xrate_type, --bug8628166
                 X_PMT_TO_BASE_XRATE_DATE => l_pmt_to_base_xrate_date, --bug8628166
                 X_PMT_TO_BASE_XRATE      => l_pmt_to_base_xrate, --bug8628166
                 X_TRX_BASE_AMOUNT        => l_trx_base_amount,
                 X_ERRORS_BASE_AMOUNT     => l_errors_base_amount,
                 X_CHARGES_BASE_AMOUNT    => l_charges_base_amount,
                 X_MATCHED_FLAG           => X_MATCHED_FLAG,
                 X_REV_PMT_HIST_ID        => NULL,
                 X_ORG_ID                 => l_org_id, -- bug 4578865
                 X_CREATION_DATE          => X_CREATION_DATE,
                 X_CREATED_BY             => X_CREATED_BY,
                 X_LAST_UPDATE_DATE       => X_LAST_UPDATE_DATE,
                 X_LAST_UPDATED_BY        => X_LAST_UPDATED_BY,
                 X_LAST_UPDATE_LOGIN      => X_LAST_UPDATE_LOGIN,
                 X_PROGRAM_UPDATE_DATE    => X_PROGRAM_UPDATE_DATE,
                 X_PROGRAM_APPLICATION_ID => X_PROGRAM_APPLICATION_ID,
                 X_PROGRAM_ID             => X_PROGRAM_ID,
                 X_REQUEST_ID             => X_REQUEST_ID,
                 X_CALLING_SEQUENCE       => CURRENT_CALLING_SEQUENCE ) ;

          --END IF;

        ELSIF (l_currency_case = 'DOMESTIC') THEN

          l_trx_base_amount := l_check_amount + l_ind_errors_pmt_amount
                                + l_ind_charges_pmt_amount;
          l_errors_base_amount := l_ind_errors_pmt_amount;
          l_charges_base_amount := l_ind_charges_pmt_amount;

          -- Bug 2276503
          --IF Check_Not_Accounted_To_Cash(l_check_id) THEN
          -- Commenting condition for bug 2626686 as accounting is now created correctly
		    -------------------------------------------------------------
            l_debug_info := 'Negotiable, Domestic, before Insert';
			IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;
            ---------------------------------------------------------------

            AP_RECONCILIATION_PKG.Insert_Payment_History
               ( X_CHECK_ID               => X_check_id,
                 X_TRANSACTION_TYPE       => X_TRANSACTION_TYPE,
                 X_ACCOUNTING_DATE        => X_ACCOUNTING_DATE,
                 X_TRX_BANK_AMOUNT        => l_check_amount
                                             + l_ind_errors_pmt_amount
                                             + l_ind_charges_pmt_amount,
                 X_ERRORS_BANK_AMOUNT     => l_ind_errors_pmt_amount,
                 X_CHARGES_BANK_AMOUNT    => l_ind_charges_pmt_amount,
                 X_BANK_CURRENCY_CODE     => X_BANK_CURRENCY_CODE,
                 X_BANK_TO_BASE_XRATE_TYPE=> l_bank_to_base_xrate_type,
                 X_BANK_TO_BASE_XRATE_DATE=> l_bank_to_base_xrate_date,
                 X_BANK_TO_BASE_XRATE     => l_bank_to_base_xrate,
                 X_TRX_PMT_AMOUNT         => l_check_amount
                                             + l_ind_errors_pmt_amount
                                             + l_ind_charges_pmt_amount,
                 X_ERRORS_PMT_AMOUNT      => l_ind_errors_pmt_amount,
                 X_CHARGES_PMT_AMOUNT     => l_ind_charges_pmt_amount,
                 X_PMT_CURRENCY_CODE      => l_pmt_currency_code,
                 X_PMT_TO_BASE_XRATE_TYPE => l_pmt_to_base_xrate_type, --bug8628166
                 X_PMT_TO_BASE_XRATE_DATE => l_pmt_to_base_xrate_date, --bug8628166
                 X_PMT_TO_BASE_XRATE      => l_pmt_to_base_xrate, --bug8628166
                 X_TRX_BASE_AMOUNT        => l_trx_base_amount,
                 X_ERRORS_BASE_AMOUNT     => l_errors_base_amount,
                 X_CHARGES_BASE_AMOUNT    => l_charges_base_amount,
                 X_MATCHED_FLAG           => X_MATCHED_FLAG,
                 X_REV_PMT_HIST_ID        => NULL,
                 X_ORG_ID                 => l_org_id, -- bug 4578865
                 X_CREATION_DATE          => X_CREATION_DATE,
                 X_CREATED_BY             => X_CREATED_BY,
                 X_LAST_UPDATE_DATE       => X_LAST_UPDATE_DATE,
                 X_LAST_UPDATED_BY        => X_LAST_UPDATED_BY,
                 X_LAST_UPDATE_LOGIN      => X_LAST_UPDATE_LOGIN,
                 X_PROGRAM_UPDATE_DATE    => X_PROGRAM_UPDATE_DATE,
                 X_PROGRAM_APPLICATION_ID => X_PROGRAM_APPLICATION_ID,
                 X_PROGRAM_ID             => X_PROGRAM_ID,
                 X_REQUEST_ID             => X_REQUEST_ID,
                 X_CALLING_SEQUENCE       => CURRENT_CALLING_SEQUENCE ) ;

          --END IF;

        END IF;


   --bugfix:5623562 added ELSE and the code after that.
   ELSIF (l_recon_accounting_flag <> 'Y') THEN

      -- Bug 4538437 Following IF condition added so that base amounts are
      -- populated even if recon_accounting_flag = 'N'
      IF (l_currency_case = 'INTERNATIONAL') THEN

         l_trx_base_amount      := X_TRX_BANK_AMOUNT;
         l_errors_base_amount   := X_ERRORS_BANK_AMOUNT;
	 l_charges_base_amount  := X_CHARGES_BANK_AMOUNT;

       ELSIF (l_currency_case = 'FOREIGN') THEN

	  l_trx_base_amount   := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
	                          (l_check_amount + l_ind_errors_pmt_amount
	                           + l_ind_charges_pmt_amount )
	                           * nvl(l_pmt_to_base_xrate,1),
	                            l_functional_currency_code); --bug8628166

          l_errors_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
		                   l_ind_errors_pmt_amount * nvl(l_pmt_to_base_xrate,1),
	                           l_functional_currency_code); --bug8628166

          l_charges_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
	                          l_ind_charges_pmt_amount * nvl(l_pmt_to_base_xrate,1),
                                  l_functional_currency_code); --bug8628166

       ELSIF (l_currency_case = 'DOMESTIC') THEN

          l_trx_base_amount := l_check_amount + l_ind_errors_pmt_amount
                                          + l_ind_charges_pmt_amount;
          l_errors_base_amount := l_ind_errors_pmt_amount;

          l_charges_base_amount := l_ind_charges_pmt_amount;


        END IF;  -- Bug 4538437 : IF condition added ends here

        IF (l_future_pay_flag <> 'Y') THEN    -- not a future payment
          IF ((nvl(X_ERRORS_BANK_AMOUNT, 0) <> 0) OR
              (nvl(X_CHARGES_BANK_AMOUNT, 0) <> 0)) THEN
              RAISE cant_do_recon_acct;

          -- Bug 898805: We should not make exchange rate comparisons if the
          -- 'Allow Future Dated Payments' option is turned on. Commenting out NOCOPY the ELSE.
	  END IF;   -- error_amount <> 0 and charge_amount <> 0
	END IF;  -- l_future_pay_flag <> 'Y'

     END IF ; /* Reconciliation_flag  */

     -- Status needs to be updated depending upon matching flag irrespective
     -- of reconciliation accouting is on or OFF
	 -------------------------------------------------------
     l_debug_info := 'Before recon_update_check call';
	 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      ---------------------------------------------------------------
	   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
				'check_id ->'||X_check_id);
			  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
				'cleared_date -> '||X_CLEARED_DATE);
			  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
				'status_code ->'||l_status_code);
		 end if ;
	  ---------------------------------------------------------------

     IF NOT (Recon_Update_Check(X_check_id,
                                 l_check_amount+l_ind_errors_pmt_amount
                                               +l_ind_charges_pmt_amount,
                                 l_trx_base_amount,
                                 l_ind_errors_pmt_amount,
                                 l_errors_base_amount,
                                 l_ind_charges_pmt_amount,
                                 l_charges_base_amount,
                                 X_CLEARED_DATE,
                                 l_status_code,
                                 l_pmt_to_base_xrate, --bug8628166
                                 l_pmt_to_base_xrate_type, --bug8628166
                                 l_pmt_to_base_xrate_date, --bug8628166
                                 X_ACTUAL_VALUE_DATE,
                                 X_LAST_UPDATED_BY,
                                 X_LAST_UPDATE_LOGIN,
                                 X_REQUEST_ID )) THEN
          RAISE G_abort_it;
      END IF;  -- recon_update_check

  END IF ; /* checkrun_id not null....... */


EXCEPTION
  WHEN NO_DATA_FOUND THEN
       IF pay_batch_cur%ISOPEN THEN
         CLOSE pay_batch_cur ;
       END IF ;
       FND_MESSAGE.SET_NAME('SQLAP','AP_RECON_NO_DATA_FOUND');
       APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN G_abort_it THEN
       IF pay_batch_cur%ISOPEN THEN
         CLOSE pay_batch_cur ;
       END IF ;
       APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN cant_do_recon_acct THEN
       IF pay_batch_cur%ISOPEN THEN
         CLOSE pay_batch_cur ;
       END IF ;
       FND_MESSAGE.SET_NAME('SQLAP', 'AP_RECON_CANT_RECONCILE');
       APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
       IF pay_batch_cur%ISOPEN THEN
         CLOSE pay_batch_cur ;
       END IF ;
       IF (SQLCODE <> -20001) THEN
           FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
	   FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;

END Recon_Payment_Clearing ;


/* *************************************************************************
   * RECON_PAYMENT_UNCLEARING: Creates entries/updates checks due to an    *
   *                           in clearing event which may or may not be   *
   *                           matched to a bank statement.                *
   ************************************************************************* */

PROCEDURE recon_payment_unclearing
(
  X_CHECKRUN_ID                  NUMBER,
  X_CHECK_ID                     NUMBER,
  X_ACCOUNTING_DATE              DATE,
  X_TRANSACTION_TYPE             VARCHAR2,
  X_MATCHED_FLAG                 VARCHAR2,
  X_LAST_UPDATE_DATE             DATE,
  X_LAST_UPDATED_BY              NUMBER,
  X_LAST_UPDATE_LOGIN            NUMBER,
  X_CREATED_BY                   NUMBER,
  X_CREATION_DATE                DATE,
  X_PROGRAM_UPDATE_DATE          DATE,
  X_PROGRAM_APPLICATION_ID       NUMBER,
  X_PROGRAM_ID                   NUMBER,
  X_REQUEST_ID                   NUMBER,
  X_CALLING_SEQUENCE             VARCHAR2
)
AS

  --bgufix:5623562
  l_recon_accounting_flag       ap_system_parameters.recon_accounting_flag%TYPE;
  l_check_amount                 ap_checks.amount%TYPE;
  l_rev_pmt_hist_id              ap_payment_history.rev_pmt_hist_id%TYPE;
  l_check_id                     ap_checks.check_id%TYPE;
  l_ind_trx_bank_amount          ap_payment_history.trx_bank_amount%TYPE;
  l_ind_errors_bank_amount       ap_payment_history.errors_bank_amount%TYPE;
  l_ind_charges_bank_amount      ap_payment_history.charges_bank_amount%TYPE;
  l_bank_currency_code           ap_payment_history.bank_currency_code%TYPE;
  l_bank_to_base_xrate_type      ap_payment_history.bank_to_base_xrate_type%TYPE;
  l_bank_to_base_xrate_date      ap_payment_history.bank_to_base_xrate_date%TYPE;
  l_bank_to_base_xrate           ap_payment_history.bank_to_base_xrate%TYPE;
  l_ind_trx_pmt_amount           ap_payment_history.trx_pmt_amount%TYPE;
  l_ind_errors_pmt_amount        ap_payment_history.errors_pmt_amount%TYPE;
  l_ind_charges_pmt_amount       ap_payment_history.charges_pmt_amount%TYPE;
  l_pmt_currency_code            ap_payment_history.pmt_currency_code%TYPE;
  l_pmt_to_base_xrate_type       ap_payment_history.pmt_to_base_xrate_type%TYPE;
  l_pmt_to_base_xrate_date       ap_payment_history.pmt_to_base_xrate_date%TYPE;
  l_pmt_to_base_xrate            ap_payment_history.pmt_to_base_xrate%TYPE;
  l_ind_trx_base_amount          ap_payment_history.trx_base_amount%TYPE;
  l_ind_errors_base_amount       ap_payment_history.errors_base_amount%TYPE;
  l_ind_charges_base_amount      ap_payment_history.charges_base_amount%TYPE;
  l_debug_info                   VARCHAR2(240);
  l_api_name                  CONSTANT VARCHAR2(1000) := 'recon_payment_unclearing' ;

  l_org_id                       NUMBER;

  cant_do_recon_acct             EXCEPTION;
  current_calling_sequence       VARCHAR2(2000);

  l_distinct_org                NUMBER;   -- Bug 5674397


  -- Distinct Org Cursor
  -- Bug 5674397
  CURSOR distinct_org_cur IS
  SELECT distinct org_id
  FROM   ap_checks
  WHERE  checkrun_id = X_CHECKRUN_ID;

  -- Payment Batch Cursor

  CURSOR pay_batch_cur (p_org_id IN NUMBER)IS
    SELECT APHA.payment_history_id,
           APHA.trx_bank_amount,
           APHA.errors_bank_amount,
           APHA.charges_bank_amount,
           APHA.bank_currency_code,
           APHA.bank_to_base_xrate_type,
           APHA.bank_to_base_xrate_date,
           APHA.bank_to_base_xrate,
           APHA.trx_pmt_amount,
           APHA.errors_pmt_amount,
           APHA.charges_pmt_amount,
           APHA.pmt_currency_code,
           APHA.pmt_to_base_xrate_type,
           APHA.pmt_to_base_xrate_date,
           APHA.pmt_to_base_xrate,
           APHA.trx_base_amount,
           APHA.errors_base_amount,
           APHA.charges_base_amount,
           C.check_id,
           NVL(c.amount, 0),
           c.org_id
      FROM ap_payment_history_all APHA,
           ap_checks_all C
     WHERE APHA.check_id = C.check_id
       AND C.checkrun_id = X_CHECKRUN_ID
       AND C.org_id      = p_org_id     -- Bug 5674397
       AND APHA.transaction_type = 'PAYMENT CLEARING'
       AND C.status_lookup_code IN ('CLEARED',
                                    'CLEARED BUT UNACCOUNTED',
                                    'RECONCILED',
                                    'RECONCILED UNACCOUNTED')
       AND NOT EXISTS (SELECT APHB.payment_history_id
                         FROM ap_payment_history APHB
                        WHERE APHB.check_id = APHA.check_id
                          AND APHB.rev_pmt_hist_id = APHA.payment_history_id)
     GROUP BY
           APHA.payment_history_id,
           APHA.trx_bank_amount,
           APHA.errors_bank_amount,
           APHA.charges_bank_amount,
           APHA.bank_currency_code,
           APHA.bank_to_base_xrate_type,
           APHA.bank_to_base_xrate_date,
           APHA.bank_to_base_xrate,
           APHA.trx_pmt_amount,
           APHA.errors_pmt_amount,
           APHA.charges_pmt_amount,
           APHA.pmt_currency_code,
           APHA.pmt_to_base_xrate_type,
           APHA.pmt_to_base_xrate_date,
           APHA.pmt_to_base_xrate,
           APHA.trx_base_amount,
           APHA.errors_base_amount,
           APHA.charges_base_amount,
           C.check_id,
           NVL(C.amount, 0),
		       c.org_id;

  l_key_value_list_recon         GL_CA_UTILITY_PKG.r_key_value_arr;
  debug_info                     VARCHAR2(1000);
  l_dummy 			 NUMBER;

BEGIN

 current_calling_sequence :=
   X_CALLING_SEQUENCE || 'AP_RECONCILIATION_PKG.recon_payment_unclearing';


IF (X_CHECKRUN_ID IS NOT NULL) THEN

    -- Bug 5674397
  OPEN distinct_org_cur ;
  LOOP

  FETCH distinct_org_cur INTO  l_distinct_org;
  ----------------------------------------------------------------
  l_debug_info := 'Inside distinct_org_cur cursor';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  ---------------------------------------------------------------

  IF distinct_org_cur%NOTFOUND THEN
   IF distinct_org_cur%ROWCOUNT < 1 THEN
     RAISE no_data_found;
   ELSE                       -- No more rows
     EXIT ;
   END IF;
  END IF;

    --bugfix:5623562
  SELECT  nvl(recon_accounting_flag, 'N')
  INTO  l_recon_accounting_flag
  FROM  ap_system_parameters_all
  WHERE org_id = l_distinct_org ;

  IF (l_recon_accounting_flag = 'Y') THEN

    OPEN pay_batch_cur(l_distinct_org);
    LOOP

    FETCH pay_batch_cur INTO
      l_rev_pmt_hist_id,
      l_ind_trx_bank_amount,
      l_ind_errors_bank_amount,
      l_ind_charges_bank_amount,
      l_bank_currency_code,
      l_bank_to_base_xrate_type,
      l_bank_to_base_xrate_date,
      l_bank_to_base_xrate,
      l_ind_trx_pmt_amount,
      l_ind_errors_pmt_amount,
      l_ind_charges_pmt_amount,
      l_pmt_currency_code,
      l_pmt_to_base_xrate_type,
      l_pmt_to_base_xrate_date,
      l_pmt_to_base_xrate,
      l_ind_trx_base_amount,
      l_ind_errors_base_amount,
      l_ind_charges_base_amount,
      l_check_id,
      l_check_amount,
      l_org_id; -- bug 4578865
    l_debug_info := 'Inside pay_batch_cur cursor';
    IF (pay_batch_cur%NOTFOUND) THEN
      IF (pay_batch_cur%ROWCOUNT < 1) THEN
        RAISE no_data_found;
      ELSE                       -- No more rows
        EXIT ;
      END IF;
    END IF;
	-----------------------------------------------------------------------
    l_debug_info := 'Inside recon_payment_unclearing, before insert';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    ---------------------------------------------------------------


    AP_RECONCILIATION_PKG.insert_payment_history
    (
      X_CHECK_ID               => l_check_id,
      X_TRANSACTION_TYPE       => X_TRANSACTION_TYPE,
      X_ACCOUNTING_DATE        => X_ACCOUNTING_DATE,
      X_TRX_BANK_AMOUNT        => l_ind_trx_bank_amount,
      X_ERRORS_BANK_AMOUNT     => l_ind_errors_bank_amount,
      X_CHARGES_BANK_AMOUNT    => l_ind_charges_bank_amount,
      X_BANK_CURRENCY_CODE     => l_bank_currency_code,
      X_BANK_TO_BASE_XRATE_TYPE=> l_bank_to_base_xrate_type,
      X_BANK_TO_BASE_XRATE_DATE=> l_bank_to_base_xrate_date,
      X_BANK_TO_BASE_XRATE     => l_bank_to_base_xrate,
      X_TRX_PMT_AMOUNT         => l_ind_trx_pmt_amount,
      X_ERRORS_PMT_AMOUNT      => l_ind_errors_pmt_amount,
      X_CHARGES_PMT_AMOUNT     => l_ind_charges_pmt_amount,
      X_PMT_CURRENCY_CODE      => l_pmt_currency_code,
      X_PMT_TO_BASE_XRATE_TYPE => l_pmt_to_base_xrate_type,
      X_PMT_TO_BASE_XRATE_DATE => l_pmt_to_base_xrate_date,
      X_PMT_TO_BASE_XRATE      => l_pmt_to_base_xrate,
      X_TRX_BASE_AMOUNT        => l_ind_trx_base_amount,
      X_ERRORS_BASE_AMOUNT     => l_ind_errors_base_amount,
      X_CHARGES_BASE_AMOUNT    => l_ind_charges_base_amount,
      X_MATCHED_FLAG           => X_MATCHED_FLAG,
      X_REV_PMT_HIST_ID        => l_rev_pmt_hist_id,
      X_ORG_ID                 => l_org_id,  -- bug 4578865
      X_CREATION_DATE          => X_CREATION_DATE,
      X_CREATED_BY             => X_CREATED_BY,
      X_LAST_UPDATE_DATE       => X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY        => X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN      => X_LAST_UPDATE_LOGIN,
      X_PROGRAM_UPDATE_DATE    => X_PROGRAM_UPDATE_DATE,
      X_PROGRAM_APPLICATION_ID => X_PROGRAM_APPLICATION_ID,
      X_PROGRAM_ID             => X_PROGRAM_ID,
      X_REQUEST_ID             => X_REQUEST_ID,
      X_CALLING_SEQUENCE       => CURRENT_CALLING_SEQUENCE
    );

    END LOOP;

    CLOSE pay_batch_cur;

  END IF /* Reconciliation flag */;

  END LOOP;

  CLOSE distinct_org_cur;


  -- Update the status for all checks to NEGOTIABLE and clear the amounts
  -- Bug 1889740 added who parameters
  IF NOT (UnClear_Check(X_CHECKRUN_ID,
		        NULL,
      		        X_LAST_UPDATE_DATE       => X_LAST_UPDATE_DATE,
                	X_LAST_UPDATED_BY        => X_LAST_UPDATED_BY,
                    	X_LAST_UPDATE_LOGIN      => X_LAST_UPDATE_LOGIN)) THEN
      RAISE G_abort_it;
    END IF;


ELSE    /* checkrun_id not null....... */

    -- Single Payment

    -- Select to retrieve check information
	------------------------------------------------------------
    l_debug_info := 'checkrun is null,  before select';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    ---------------------------------------------------------------


   --bugfix:5674397
  SELECT  nvl(recon_accounting_flag, 'N')
  INTO  l_recon_accounting_flag
  FROM  ap_system_parameters_all asp,
        ap_checks_all ac
  WHERE asp.org_id = ac.org_id
  AND   ac.check_id = X_CHECK_ID;

 --bugfix:5623562   -- 5674397
 IF (l_recon_accounting_flag = 'Y') THEN

    --bugfix:2972765 added the following select and if statements.
    SELECT count(*)
    INTO   l_dummy
    FROM   ap_payment_history
    WHERE  check_id=x_check_id
    AND    transaction_type='PAYMENT CLEARING';

    --bugfix:5623562
    IF (l_dummy>0 ) THEN
        ---------------------------------------------------------------------
        l_debug_info := 'checkrun is null, recon flag is Y, before select';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ---------------------------------------------------------------


        SELECT APHA.payment_history_id,
           APHA.trx_bank_amount,
           APHA.errors_bank_amount,
           APHA.charges_bank_amount,
           APHA.bank_currency_code,
           APHA.bank_to_base_xrate_type,
           APHA.bank_to_base_xrate_date,
           APHA.bank_to_base_xrate,
           APHA.trx_pmt_amount,
           APHA.errors_pmt_amount,
           APHA.charges_pmt_amount,
           APHA.pmt_currency_code,
           APHA.pmt_to_base_xrate_type,
           APHA.pmt_to_base_xrate_date,
           APHA.pmt_to_base_xrate,
           APHA.trx_base_amount,
           APHA.errors_base_amount,
           APHA.charges_base_amount,
           NVL(C.amount, 0),
           c.org_id
      INTO l_rev_pmt_hist_id,
           l_ind_trx_bank_amount,
           l_ind_errors_bank_amount,
           l_ind_charges_bank_amount,
           l_bank_currency_code,
           l_bank_to_base_xrate_type,
           l_bank_to_base_xrate_date,
           l_bank_to_base_xrate,
           l_ind_trx_pmt_amount,
           l_ind_errors_pmt_amount,
           l_ind_charges_pmt_amount,
           l_pmt_currency_code,
           l_pmt_to_base_xrate_type,
           l_pmt_to_base_xrate_date,
           l_pmt_to_base_xrate,
           l_ind_trx_base_amount,
           l_ind_errors_base_amount,
           l_ind_charges_base_amount,
           l_check_amount,
           l_org_id
      FROM ap_payment_history APHA,
           ap_checks C
     WHERE APHA.check_id = X_CHECK_ID
       AND APHA.check_id  = C.check_id
       AND APHA.transaction_type = 'PAYMENT CLEARING'
       AND C.status_lookup_code IN ('CLEARED',
                                    'CLEARED BUT UNACCOUNTED',
                                    'RECONCILED',
                                    'RECONCILED UNACCOUNTED')
       AND NOT EXISTS (SELECT APHB.payment_history_id
                         FROM ap_payment_history APHB
                        WHERE APHB.check_id = APHA.check_id
                          AND APHB.rev_pmt_hist_id = APHA.payment_history_id);

    AP_RECONCILIATION_PKG.Insert_Payment_History
    (
      X_CHECK_ID               => X_check_id,
      X_TRANSACTION_TYPE       => X_TRANSACTION_TYPE,
      X_ACCOUNTING_DATE        => X_ACCOUNTING_DATE,
      X_TRX_BANK_AMOUNT        => l_ind_trx_bank_amount,
      X_ERRORS_BANK_AMOUNT     => l_ind_errors_bank_amount,
      X_CHARGES_BANK_AMOUNT    => l_ind_charges_bank_amount,
      X_BANK_CURRENCY_CODE     => l_bank_currency_code,
      X_BANK_TO_BASE_XRATE_TYPE=> l_bank_to_base_xrate_type,
      X_BANK_TO_BASE_XRATE_DATE=> l_bank_to_base_xrate_date,
      X_BANK_TO_BASE_XRATE     => l_bank_to_base_xrate,
      X_TRX_PMT_AMOUNT         => l_ind_trx_pmt_amount,
      X_ERRORS_PMT_AMOUNT      => l_ind_errors_pmt_amount,
      X_CHARGES_PMT_AMOUNT     => l_ind_charges_pmt_amount,
      X_PMT_CURRENCY_CODE      => l_pmt_currency_code,
      X_PMT_TO_BASE_XRATE_TYPE => l_pmt_to_base_xrate_type,
      X_PMT_TO_BASE_XRATE_DATE => l_pmt_to_base_xrate_date,
      X_PMT_TO_BASE_XRATE      => l_pmt_to_base_xrate,
      X_TRX_BASE_AMOUNT        => l_ind_trx_base_amount,
      X_ERRORS_BASE_AMOUNT     => l_ind_errors_base_amount,
      X_CHARGES_BASE_AMOUNT    => l_ind_charges_base_amount,
      X_MATCHED_FLAG           => X_MATCHED_FLAG,
      X_REV_PMT_HIST_ID        => l_rev_pmt_hist_id,
      X_ORG_ID                 => l_org_id,
      X_CREATION_DATE          => X_CREATION_DATE,
      X_CREATED_BY             => X_CREATED_BY,
      X_LAST_UPDATE_DATE       => X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY        => X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN      => X_LAST_UPDATE_LOGIN,
      X_PROGRAM_UPDATE_DATE    => X_PROGRAM_UPDATE_DATE,
      X_PROGRAM_APPLICATION_ID => X_PROGRAM_APPLICATION_ID,
      X_PROGRAM_ID             => X_PROGRAM_ID,
      X_REQUEST_ID             => X_REQUEST_ID,
      X_CALLING_SEQUENCE       => CURRENT_CALLING_SEQUENCE
    );

  END IF; --bugg2972765
 END IF; /* Reconciliation_flag  */

  -- Update the status for all checks to NEGOTIABLE and clear the amounts
  --Bug 1889740 added who parameters
  IF NOT (UnClear_Check(NULL,
                         X_CHECK_ID,
                         X_LAST_UPDATE_DATE       => X_LAST_UPDATE_DATE,
                         X_LAST_UPDATED_BY        => X_LAST_UPDATED_BY,
                         X_LAST_UPDATE_LOGIN      => X_LAST_UPDATE_LOGIN)) THEN
      RAISE G_abort_it;
   END IF;

END IF ; /* checkrun_id not null....... */


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.SET_NAME('SQLAP','AP_RECON_NO_DATA_FOUND');
    APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Recon_Payment_Unclearing ;

--============================================================================
-- INSERT_PAYMENT_HISTORY : API to insert a row into the AP_Payment_History
--                          table.
--
-- Due to R12 SLA project impact, for every payment action, we will need
-- to add the row in ap_payment_history
-- in 11i - transaction types are
--    PAYMENT MATURITY
--    PAYMENT UNCLEARING
--    PAYMENT CLEARING
-- in R12, for upgrade and code impact, these transction type will be
-- retained, the transaction types will be the same as event type.
--============================================================================
PROCEDURE Insert_Payment_History(
  X_CHECK_ID                IN NUMBER,
  X_TRANSACTION_TYPE        IN VARCHAR2,
  X_ACCOUNTING_DATE         IN DATE,
  X_TRX_BANK_AMOUNT         IN NUMBER,
  X_ERRORS_BANK_AMOUNT      IN NUMBER,
  X_CHARGES_BANK_AMOUNT     IN NUMBER,
  X_BANK_CURRENCY_CODE      IN VARCHAR2,
  X_BANK_TO_BASE_XRATE_TYPE IN VARCHAR2,
  X_BANK_TO_BASE_XRATE_DATE IN DATE,
  X_BANK_TO_BASE_XRATE      IN NUMBER,
  X_TRX_PMT_AMOUNT          IN NUMBER,
  X_ERRORS_PMT_AMOUNT       IN NUMBER,
  X_CHARGES_PMT_AMOUNT      IN NUMBER,
  X_PMT_CURRENCY_CODE       IN VARCHAR2,
  X_PMT_TO_BASE_XRATE_TYPE  IN VARCHAR2,
  X_PMT_TO_BASE_XRATE_DATE  IN DATE,
  X_PMT_TO_BASE_XRATE       IN NUMBER,
  X_TRX_BASE_AMOUNT         IN NUMBER,
  X_ERRORS_BASE_AMOUNT      IN NUMBER,
  X_CHARGES_BASE_AMOUNT     IN NUMBER,
  X_MATCHED_FLAG            IN VARCHAR2,
  X_REV_PMT_HIST_ID         IN NUMBER,
  X_ORG_ID                  IN NUMBER, -- bug 4578865
  X_CREATION_DATE           IN DATE,
  X_CREATED_BY              IN NUMBER,
  X_LAST_UPDATE_DATE        IN DATE,
  X_LAST_UPDATED_BY         IN NUMBER,
  X_LAST_UPDATE_LOGIN       IN NUMBER,
  X_PROGRAM_UPDATE_DATE     IN DATE,
  X_PROGRAM_APPLICATION_ID  IN NUMBER,
  X_PROGRAM_ID              IN NUMBER,
  X_REQUEST_ID              IN NUMBER,
  X_CALLING_SEQUENCE        IN VARCHAR2,
  -- Bug 3343314
  X_ACCOUNTING_EVENT_ID     IN NUMBER DEFAULT NULL,
  -- Bug fix 5694577
  x_invoice_adjustment_event_id  IN NUMBER DEFAULT NULL
) IS

  l_accounting_event_id     NUMBER(15);   -- Events Project - 6

  current_calling_sequence  VARCHAR2(2000);
  l_event_calling_type      VARCHAR2(30); -- 4578865
  l_doc_type                VARCHAR2(15);
  l_debug_info              VARCHAR2(240);
  l_api_name                  CONSTANT VARCHAR2(1000) := 'Insert_Payment_History' ;

  l_related_event_id        NUMBER(15); -- Bug 5015973

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
     'AP_RECONCILIATION_PKG.insert_payment_history<-'||X_Calling_Sequence;

  -- Bug 3343314
  ---------------------------------------------------------------
  --  Create accounting event if event id is null
  ---------------------------------------------------------------
  IF x_accounting_event_id is null THEN
    ---------------------------------------------------------------------
    l_debug_info := 'Call AP_ACCOUNTING_EVENTS_PKG.CREATE_EVENTS';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    ---------------------------------------------------------------

    -- bug 4578865
    IF ( X_TRANSACTION_TYPE = 'PAYMENT CREATED' ) THEN
      l_event_calling_type := 'PAYMENT';
    ELSIF ( X_TRANSACTION_TYPE = 'REFUND RECORDED') THEN
      l_doc_type := 'R';
      l_event_calling_type := 'PAYMENT';
    ELSIF ( X_TRANSACTION_TYPE = 'PAYMENT CANCELLED' ) THEN
      l_event_calling_type := 'PAYMENT CANCELLATION';
    ELSIF ( X_TRANSACTION_TYPE = 'REFUND CANCELLED' ) THEN
      l_doc_type := 'R';
      l_event_calling_type := 'PAYMENT CANCELLATION';
    ELSIF ( X_TRANSACTION_TYPE
             IN ('PAYMENT MATURITY',
                 'PAYMENT CLEARING',
                 'PAYMENT UNCLEARING') ) THEN
      l_event_calling_type := X_TRANSACTION_TYPE;

	  ELSIF ( X_TRANSACTION_TYPE
	           IN ( 'MANUAL PAYMENT ADJUSTED') ) THEN
      l_event_calling_type := 'PAYMENT ADJUSTMENT';

    -- bug fix 5659451
    -- fixed the following condition check as the X_TRANSACTION_TYPE passed
    -- in will be 'PAYMENT MATURITY REVERSAL'
    --  ELSIF ( X_TRANSACTION_TYPE = 'PAYMENT MATURITY REVERSED') THEN
    ELSIF ( X_TRANSACTION_TYPE = 'PAYMENT MATURITY REVERSAL') THEN
      l_event_calling_type := 'PAYMENT MATURITY REVERSAL';
    ELSE
      l_event_calling_type := NULL;

	  END IF;

    AP_ACCOUNTING_EVENTS_PKG.CREATE_EVENTS
    (
      p_event_type          => l_event_calling_type, -- bug 4578865
      p_doc_type            => l_doc_type,
      p_doc_id              => x_check_id,
      p_accounting_date     => x_accounting_date,
      p_accounting_event_id => l_accounting_event_id, -- OUT
      p_checkrun_name       => NULL,
      p_calling_sequence    => current_calling_sequence
    );
  ELSE
    l_accounting_event_id := x_accounting_event_id;
  END IF;

  -- End Bug 3343314

  -- Bug 5015973. We need to populate the related event id
  -- for creating the payment dists for reversals
  IF X_REV_PMT_HIST_ID IS NOT NULL THEN

     SELECT Accounting_Event_ID
     INTO   l_related_event_id
     FROM   AP_Payment_History APH
     WHERE  APH.Payment_History_ID = X_REV_PMT_HIST_ID;

  END IF;

  -- Bug 6887295
  IF x_transaction_type IN ('PAYMENT ADJUSTED', 'MANUAL PAYMENT ADJUSTED',
                            'PAYMENT MATURITY ADJUSTED',
                            'PAYMENT CLEARING ADJUSTED',
                            'REFUND ADJUSTED' ) THEN --8449674 added refund adjusted
     BEGIN
       SELECT Accounting_Event_ID
       INTO   l_related_event_id
       FROM   AP_Payment_History APH
       WHERE  APH.Check_ID = x_check_id
       AND    APH.Transaction_Type =
              DECODE(X_Transaction_Type, 'PAYMENT ADJUSTED' ,'PAYMENT CREATED',
                       'MANUAL PAYMENT ADJUSTED', 'PAYMENT CREATED',
                       'PAYMENT MATURITY ADJUSTED', 'PAYMENT MATURITY',
                       'PAYMENT CLEARING ADJUSTED', 'PAYMENT CLEARING',
                       'REFUND ADJUSTED', 'REFUND RECORDED' ) --8449674
       AND    NOT EXISTS (SELECT 'Reversal Pay Hist'
                          FROM   AP_Payment_History APH1
                          WHERE  APH1.Check_ID = x_check_id
                          AND    APH1.Rev_Pmt_Hist_ID = APH.Payment_History_ID)
       AND    ROWNUM = 1;
     EXCEPTION
       WHEN others THEN
            NULL;
     END;

  END IF;

  ----------------------------------------------------------------
  -- Insert payment information into payment history table
  ----------------------------------------------------------------
  l_debug_info := 'Inserting into AP_Payment_History';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  ---------------------------------------------------------------

  INSERT INTO AP_PAYMENT_HISTORY_ALL
  ( PAYMENT_HISTORY_ID,
    CHECK_ID,
    ACCOUNTING_DATE,
    TRANSACTION_TYPE,
    POSTED_FLAG,
    TRX_BANK_AMOUNT,
    ERRORS_BANK_AMOUNT,
    CHARGES_BANK_AMOUNT,
    BANK_CURRENCY_CODE,
    BANK_TO_BASE_XRATE_TYPE,
    BANK_TO_BASE_XRATE_DATE,
    BANK_TO_BASE_XRATE,
    TRX_PMT_AMOUNT,
    ERRORS_PMT_AMOUNT,
    CHARGES_PMT_AMOUNT,
    PMT_CURRENCY_CODE,
    PMT_TO_BASE_XRATE_TYPE,
    PMT_TO_BASE_XRATE_DATE,
    PMT_TO_BASE_XRATE,
    TRX_BASE_AMOUNT,
    ERRORS_BASE_AMOUNT,
    CHARGES_BASE_AMOUNT,
    MATCHED_FLAG,
    REV_PMT_HIST_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PROGRAM_UPDATE_DATE,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    ACCOUNTING_EVENT_ID, -- Events Project - 10
    REQUEST_ID ,
    ORG_ID, -- Bug 4526577
    RELATED_EVENT_ID, -- Bug 5015973
    invoice_adjustment_event_id -- bug 5694577
    )
  VALUES
  ( AP_PAYMENT_HISTORY_S.nextval,
    X_CHECK_ID,
    X_ACCOUNTING_DATE,
    X_TRANSACTION_TYPE,
    'N',
    X_TRX_BANK_AMOUNT,
    X_ERRORS_BANK_AMOUNT,
    X_CHARGES_BANK_AMOUNT,
    X_BANK_CURRENCY_CODE,
    X_BANK_TO_BASE_XRATE_TYPE,
    X_BANK_TO_BASE_XRATE_DATE,
    X_BANK_TO_BASE_XRATE,
    X_TRX_PMT_AMOUNT,
    X_ERRORS_PMT_AMOUNT,
    X_CHARGES_PMT_AMOUNT,
    X_PMT_CURRENCY_CODE,
    X_PMT_TO_BASE_XRATE_TYPE,
    X_PMT_TO_BASE_XRATE_DATE,
    X_PMT_TO_BASE_XRATE,
    X_TRX_BASE_AMOUNT,
    X_ERRORS_BASE_AMOUNT,
    X_CHARGES_BASE_AMOUNT,
    X_MATCHED_FLAG,
    X_REV_PMT_HIST_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PROGRAM_UPDATE_DATE,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_ID,
    L_ACCOUNTING_EVENT_ID, -- Events Project - 11
    X_REQUEST_ID,
    x_org_id,  -- bug 4578865
    NVL(l_related_event_id, l_accounting_event_id), --Bug 5015973
    x_invoice_adjustment_event_id -- bug fix 5694577
    );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) then
      FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
            'X_check_id = '||to_char(x_check_id)
           ||' X_transaction_type = '||X_transaction_type
           ||' X_accounting_date = '||to_char(x_accounting_date)
           ||' X_trx_bank_amount = '||to_char(x_trx_bank_amount)
           ||' X_errors_bank_amount = '||to_char(x_errors_bank_amount)
           ||' X_charges_bank_amount = '||to_char(x_charges_bank_amount)
           ||' X_bank_currency_code = '||x_bank_currency_code
           ||' X_bank_to_base_xrate_type = '||x_bank_to_base_xrate_type
           ||' X_bank_to_base_xrate_date = '||to_char(x_bank_to_base_xrate_date)
           ||' X_bank_to_base_xrate = '||to_char(x_bank_to_base_xrate)
           ||' X_trx_pmt_amount = '||to_char(x_trx_pmt_amount)
           ||' X_errors_pmt_amount = '||to_char(x_errors_pmt_amount)
           ||' X_charges_pmt_amount = '||to_char(x_charges_pmt_amount)
           ||' X_pmt_currency_code = '||x_pmt_currency_code
           ||' X_pmt_to_base_xrate_type = '||x_pmt_to_base_xrate_type
           ||' X_pmt_to_base_xrate_date = '||to_char(x_pmt_to_base_xrate_date)
           ||' X_pmt_to_base_xrate = '||to_char(x_pmt_to_base_xrate)
           ||' X_trx_base_amount = '||to_char(x_trx_base_amount)
           ||' X_errors_base_amount = '||to_char(x_errors_base_amount)
           ||' X_charges_base_amount = '||to_char(x_charges_base_amount)
           ||' X_matched_flag = '||x_matched_flag
           ||' X_creation_date = '||to_char(x_creation_date)
           ||' X_created_by = '||to_char(x_created_by)
           ||' X_Last_update_date = '||to_char(x_last_update_date)
           ||' X_Last_updated_by = '||to_char(x_last_updated_by)
           ||' X_last_update_login = '||to_char(x_last_update_login)
           ||' X_program_update_date = '||to_char(x_program_update_date)
           ||' X_program_application_id = '||to_char(x_program_application_id)
           ||' X_program_id = '||to_char(x_program_id)
           ||' X_request_id = '||to_char(x_request_id));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Insert_Payment_History;


/* *************************************************************************
   * UNCLEAR_CHECK: Nulls all clearing related columns in the check so     *
   *                it no longer shows up as cleared.                      *
   ************************************************************************* */
    --Bug 1889740 added who parameters
FUNCTION UnClear_Check(
  CC_CHECKRUN_ID    NUMBER,
  CC_CHECK_ID       NUMBER,
  X_LAST_UPDATE_DATE DATE,
  X_LAST_UPDATED_BY NUMBER,
  X_LAST_UPDATE_LOGIN NUMBER
) RETURN BOOLEAN IS

  l_debug_info                      VARCHAR2(240);
  l_api_name                  CONSTANT VARCHAR2(1000) := 'UnClear_Check' ;
BEGIN

  IF (CC_CHECKRUN_ID IS NOT NULL AND CC_CHECK_ID IS NULL) THEN
   ------------------------------------------------------------------------------
   l_debug_info := 'cc_checkrun_id not null and cc_check_id null, before Update';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;
   ---------------------------------------------------------------

    UPDATE      ap_checks
    SET         CLEARED_DATE               = NULL,
                CLEARED_AMOUNT             = NULL,
                CLEARED_BASE_AMOUNT        = NULL,
                CLEARED_ERROR_AMOUNT       = NULL,
                CLEARED_ERROR_BASE_AMOUNT  = NULL,
                CLEARED_CHARGES_AMOUNT     = NULL,
                CLEARED_CHARGES_BASE_AMOUNT= NULL,
                CLEARED_EXCHANGE_RATE      = NULL,
                CLEARED_EXCHANGE_DATE      = NULL,
                CLEARED_EXCHANGE_RATE_TYPE = NULL,
                ACTUAL_VALUE_DATE          = NULL,
                STATUS_LOOKUP_CODE         = 'NEGOTIABLE',
                LAST_UPDATE_DATE           = X_LAST_UPDATE_DATE,
                LAST_UPDATED_BY            = X_LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN          = X_LAST_UPDATE_LOGIN
    WHERE       checkrun_id                = CC_CHECKRUN_ID
    AND         status_lookup_code IN ('CLEARED',
                                       'RECONCILED',
                                       'RECONCILED UNACCOUNTED',
                                       'CLEARED BUT UNACCOUNTED');

  ELSE
    ----------------------------------------------------------------------------------------
    l_debug_info := 'cc_checkrun_id  null or cc_check_id not null, before Update ap_checks';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    ---------------------------------------------------------------

    UPDATE      ap_checks
    SET         CLEARED_DATE               = NULL,
                CLEARED_AMOUNT             = NULL,
                CLEARED_BASE_AMOUNT        = NULL,
                CLEARED_ERROR_AMOUNT       = NULL,
                CLEARED_ERROR_BASE_AMOUNT  = NULL,
                CLEARED_CHARGES_AMOUNT     = NULL,
                CLEARED_CHARGES_BASE_AMOUNT= NULL,
                CLEARED_EXCHANGE_RATE      = NULL,
                CLEARED_EXCHANGE_DATE      = NULL,
                CLEARED_EXCHANGE_RATE_TYPE = NULL,
                ACTUAL_VALUE_DATE          = NULL,
                STATUS_LOOKUP_CODE         = 'NEGOTIABLE',
    LAST_UPDATE_DATE           = X_LAST_UPDATE_DATE,
                LAST_UPDATED_BY            = X_LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN          = X_LAST_UPDATE_LOGIN
    WHERE       check_id                   = CC_CHECK_ID
    AND         status_lookup_code IN ('CLEARED',
                                       'RECONCILED',
                                       'RECONCILED UNACCOUNTED',
                                       'CLEARED BUT UNACCOUNTED');

  END IF;

  RETURN(TRUE);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(TRUE);
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE','AP_RECONCILATION_PKG.Clear_Check');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
   RETURN(FALSE);

END UnClear_Check;


/* *************************************************************************
   * RECON_UPDATE_CHECK: Populates all clearing related columns given the  *
   *                     appropriate amounts.  Also sets the status of     *
   *                         the check appropriately.                           *
   ************************************************************************* */

FUNCTION Recon_Update_Check(
  RU_CHECK_ID                    NUMBER,
  RU_CLEARED_AMOUNT              NUMBER,
  RU_CLEARED_BASE_AMOUNT         NUMBER,
  RU_CLEARED_ERROR_AMOUNT        NUMBER,
  RU_CLEARED_ERROR_BASE_AMOUNT   NUMBER,
  RU_CLEARED_CHARGES_AMOUNT      NUMBER,
  RU_CLEARED_CHARGES_BASE_AMOUNT NUMBER,
  RU_CLEARED_DATE                DATE,
  RU_CHECK_STATUS                VARCHAR2,
  RU_CLEARED_XRATE               NUMBER,
  RU_CLEARED_XRATE_TYPE          VARCHAR2,
  RU_CLEARED_XRATE_DATE          DATE,
  RU_ACTUAL_VALUE_DATE           DATE,
  RU_LAST_UPDATED_BY             NUMBER,
  RU_LAST_UPDATE_LOGIN           NUMBER,
  RU_REQUEST_ID                  NUMBER
) RETURN BOOLEAN IS
  l_date                        DATE;
  l_debug_info                    VARCHAR2(240);
  l_api_name                  CONSTANT VARCHAR2(1000) := 'Recon_Update_Check' ;

BEGIN

  SELECT
    SYSDATE
  INTO
    l_date
  FROM
    DUAL;
  --------------------------------------------------------------
  l_debug_info := ' inside Recon_Update_Check, Before Update';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  ---------------------------------------------------------------
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
				'check_id ->'||RU_CHECK_ID);
			  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
				'cleared_date '||RU_CLEARED_DATE);
			  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
				'status_code'||RU_CHECK_STATUS);
		 end if ;

  ----------------------------------------------------------------
  --bug 8545814
  UPDATE ap_checks_all
  SET    CLEARED_AMOUNT              = RU_CLEARED_AMOUNT,
         CLEARED_BASE_AMOUNT         = RU_CLEARED_BASE_AMOUNT,
         CLEARED_ERROR_AMOUNT        = RU_CLEARED_ERROR_AMOUNT,
         CLEARED_ERROR_BASE_AMOUNT   = RU_CLEARED_ERROR_BASE_AMOUNT,
         CLEARED_CHARGES_AMOUNT      = RU_CLEARED_CHARGES_AMOUNT,
         CLEARED_CHARGES_BASE_AMOUNT = RU_CLEARED_CHARGES_BASE_AMOUNT,
         CLEARED_DATE                = RU_CLEARED_DATE,
         STATUS_LOOKUP_CODE          = RU_CHECK_STATUS,
         CLEARED_EXCHANGE_RATE       = RU_CLEARED_XRATE,
         CLEARED_EXCHANGE_DATE       = RU_CLEARED_XRATE_DATE,
         CLEARED_EXCHANGE_RATE_TYPE  = RU_CLEARED_XRATE_TYPE,
         ACTUAL_VALUE_DATE           = RU_ACTUAL_VALUE_DATE,
         LAST_UPDATED_BY             = RU_LAST_UPDATED_BY,
         LAST_UPDATE_DATE            = L_DATE,
         LAST_UPDATE_LOGIN           = RU_LAST_UPDATE_LOGIN,
         REQUEST_ID                  = RU_REQUEST_ID
  WHERE  check_id                    = RU_CHECK_ID;

  RETURN(TRUE);
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE','AP_RECONCILATION_PKG.Recon_Update_Check');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
  RETURN(FALSE);

END Recon_Update_Check;


/* *************************************************************
   * FUNCTION: CASE_TYPE                                       *
   *                This function returns the currency scenario of    *
   *           the current payment activity given the scenarios*
   *           defined in the top of this package               *
   ************************************************************* */

FUNCTION CASE_TYPE(
        X_BANK_CURRENCY          IN VARCHAR2,
        X_PAY_CURRENCY           IN VARCHAR2,
        X_FUNC_CURRENCY          IN VARCHAR2
                  ) RETURN VARCHAR2 IS
BEGIN

  IF (x_bank_currency = x_func_currency AND
      x_bank_currency = x_pay_currency) THEN

    RETURN('DOMESTIC');

  ELSIF (x_bank_currency = x_func_currency AND
         x_bank_currency <> x_pay_currency) THEN

    RETURN('INTERNATIONAL');

  ELSIF (x_bank_currency <> x_func_currency AND
         x_bank_currency = x_pay_currency) THEN

    RETURN('FOREIGN');

/******* This is not valid yet!
  ELSIF (x_bank_currency <> x_func_currency AND
         x_bank_currency <> x_pay_currency) THEN

    RETURN('CROSS_CURRENCY');
*******/

  ELSE

    raise G_abort_it;

  END IF;

END CASE_TYPE;


END AP_RECONCILIATION_PKG;

/
