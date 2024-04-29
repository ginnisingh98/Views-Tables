--------------------------------------------------------
--  DDL for Package Body IBY_CE_BATCH_RECON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_CE_BATCH_RECON_PKG" as
/* $Header: ibycepib.pls 120.7.12010000.3 2009/03/19 15:55:40 vkarlapu ship $ */

--============================================================================
-- For reconciliation of IBY payment instructions in CE
-- Copied from AP_RECONCILIATION_PKG 115.43
-- This API will be called by CE for reconciliation at the batch level with
-- R12 payment batches - i.e., IBY payment instructions.
-- (CE only supports auto recon at batch level - no manual clearing).
-- The API do proration as AP, then call product APIs at transaction level
-- so they can execute their business logic.
--
-- R12 Payment instructions supports multiple currencies and orgs
-- with in an instruction; CE will support only single currency for batch
-- recons, and orgs will not be considered during CE batch recon.
--
--============================================================================

-- Global exception
G_abort_it                        EXCEPTION;

-- module name used for the application debugging framework
G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_CE_BATCH_RECON_PKG';



FUNCTION Case_Type(X_BANK_CURRENCY                 IN VARCHAR2,
                   X_PAY_CURRENCY                  IN VARCHAR2,
                   X_FUNC_CURRENCY                 IN VARCHAR2
                   ) RETURN VARCHAR2;

PROCEDURE Payment_Instruction_Clearing(
                          P_PAYMENT_INSTRUCTION_ID IN NUMBER,
                          P_ACCOUNTING_DATE        IN DATE,
                          P_CLEARED_DATE           IN DATE,
                          P_TRANSACTION_AMOUNT     IN NUMBER,      -- in bank curr.
                          P_ERROR_AMOUNT           IN NUMBER,      -- in bank curr.
                          P_CHARGE_AMOUNT          IN NUMBER,      -- in bank curr.
                          P_CURRENCY_CODE          IN VARCHAR2,    -- bank curr. code
                          P_EXCHANGE_RATE_TYPE     IN VARCHAR2,    -- between payment and functional
                          P_EXCHANGE_RATE_DATE     IN DATE,        -- between payment and functional
                          P_EXCHANGE_RATE          IN NUMBER,      -- between payment and functional
                          P_MATCHED_FLAG           IN VARCHAR2,
                          P_ACTUAL_VALUE_DATE      IN DATE,
                          P_PASSIN_MODE            IN VARCHAR2,    -- passed back to CE
                          P_STATEMENT_LINE_ID      IN NUMBER,      -- passed back to CE
                          P_STATEMENT_LINE_TYPE    IN VARCHAR2,    -- passed back to CE
                          P_LAST_UPDATE_DATE       IN DATE,
                          P_LAST_UPDATED_BY        IN NUMBER,
                          P_LAST_UPDATE_LOGIN      IN NUMBER,
                          P_CREATED_BY             IN NUMBER,
                          P_CREATION_DATE          IN DATE,
                          P_PROGRAM_UPDATE_DATE    IN DATE,
                          P_PROGRAM_APPLICATION_ID IN NUMBER,
                          P_PROGRAM_ID             IN NUMBER,
                          P_REQUEST_ID             IN NUMBER,
                          P_CALLING_SEQUENCE       IN VARCHAR2,
                          P_LOGICAL_GROUP_REFERENCE IN VARCHAR2
) AS

  l_trx_id                      NUMBER;
  l_app_id                      NUMBER;
  l_currency_case               VARCHAR2(30);
  l_status                      VARCHAR2(30);

  l_bank_trxn_amount            NUMBER;
  l_bank_error_amount           NUMBER;
  l_bank_charge_amount          NUMBER;

  l_pmt_currency_code           ap_checks.currency_code%TYPE;
  l_functional_currency_code    ap_system_parameters.base_currency_code%TYPE;
  l_bank_to_base_xrate          ap_checks.exchange_rate%TYPE;
  l_bank_to_base_xrate_type     ap_checks.exchange_rate_type%TYPE;
  l_bank_to_base_xrate_date     ap_checks.exchange_date%TYPE;
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
  l_running_total_payments      NUMBER := 0;
  l_runtotal_trx_bank_amount    NUMBER := 0;
  l_runtotal_errors_bank_amount NUMBER := 0;
  l_runtotal_charges_bank_amount NUMBER := 0;
  l_check_amount                ap_checks.amount%TYPE;
  l_ind_errors_pmt_amount       ap_checks.amount%TYPE;
  l_ind_charges_pmt_amount      ap_checks.amount%TYPE;
  current_calling_sequence    VARCHAR2(2000);

  l_debug_info                  VARCHAR2(240);
  l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.Payment_Instruction_Clearing';

     CURSOR l_ins_pmt_clr_cur IS
     SELECT distinct check_id,
            status_lookup_code,
            amount,
            200 app_id
       FROM ap_checks checks, iby_payments_all pmts
      WHERE checks.payment_instruction_id = P_PAYMENT_INSTRUCTION_ID
      AND checks.payment_id = pmts.payment_id (+)
      AND Nvl(pmts.logical_group_reference, 'N') = Nvl(P_LOGICAL_GROUP_REFERENCE, nvl(pmts.logical_group_reference,'N'))

    /* Bug 8340931
      and
      exists (select 1 from iby_payments_all pay
               where nvl(logical_group_reference,'N') = nvl(P_LOGICAL_GROUP_REFERENCE,nvl(logical_group_reference,'N'))
	          and checks.payment_instruction_id = pay.payment_instruction_id
		  and checks.payment_id = pay.payment_id)*/
        AND checks.status_lookup_code not in
	   ('VOIDED','SPOILED','OVERFLOW','SETUP','STOP INITIATED',
            'UNCONFIRMED SET UP', 'RECONCILED', 'RECONCILED UNACCOUNTED',
                 'ISSUED')
  UNION ALL
     SELECT distinct CC.CASHFLOW_ID,
            CC.CASHFLOW_STATUS_CODE,
            CC.CASHFLOW_AMOUNT,
            260 app_id
       FROM CE_SECURITY_PROFILES_GT le,
	    iby_fd_docs_payable_v docs,
	    iby_fd_payments_v pay,
	    CE_CASHFLOWS CC,
	    CE_CASHFLOW_ACCT_H CCH
      WHERE pay.payment_instruction_id = P_PAYMENT_INSTRUCTION_ID
        AND CC.CASHFLOW_STATUS_CODE  IN ('CREATED', 'CLEARED')
        AND CC.CASHFLOW_ID = CCH.CASHFLOW_ID
        AND CCH.CURRENT_RECORD_FLAG = 'Y'
        AND CCH.EVENT_TYPE in
            ('CE_STMT_RECORDED', 'CE_BAT_CLEARED', 'CE_BAT_CREATED')
        and cc.source_trxn_type ='BAT'
        AND exists
            (select null
    	     from ce_payment_transactions pt
    	     where  cc.trxn_reference_number =  pt.trxn_reference_number
	     and pt.trxn_reference_number = cc.trxn_reference_number
	     and  pt.trxn_status_code = 'SETTLED')
     	and cc.trxn_reference_number = docs.calling_app_doc_ref_number
     	and pay.payment_id = docs.payment_id
        and docs.CALLING_APP_ID   = 260
        AND CC.CASHFLOW_LEGAL_ENTITY_ID =  LE.ORGANIZATION_ID
        AND LE.ORGANIZATION_TYPE     = 'LEGAL_ENTITY'
   ORDER BY 3;


     CURSOR l_ins_total_cur IS
     SELECT count(check_id), sum(amount) , max(amount)
       FROM ap_checks checks, iby_payments_all pmts
      WHERE checks.payment_instruction_id = P_PAYMENT_INSTRUCTION_ID
      AND checks.payment_id = pmts.payment_id (+)
      AND Nvl(pmts.logical_group_reference, 'N') = Nvl(P_LOGICAL_GROUP_REFERENCE, nvl(pmts.logical_group_reference,'N'))
/*   Bug 8340931
        AND exists (select 1 from iby_payments_all pay
               where nvl(logical_group_reference,'N') = nvl(P_LOGICAL_GROUP_REFERENCE,nvl(logical_group_reference,'N'))
	          and checks.payment_instruction_id = pay.payment_instruction_id
		  and checks.payment_id = pay.payment_id)  */
        AND checks.status_lookup_code NOT IN
            ('VOIDED','SPOILED','OVERFLOW','SETUP','STOP INITIATED',
            'UNCONFIRMED SET UP', 'RECONCILED', 'RECONCILED UNACCOUNTED',
                 'ISSUED')
  UNION ALL
     SELECT count(CC.CASHFLOW_ID), sum(CC.CASHFLOW_AMOUNT) ,
	    max(CC.CASHFLOW_AMOUNT)
       FROM CE_SECURITY_PROFILES_GT le,
            iby_fd_docs_payable_v docs,
            iby_fd_payments_v pay,
            CE_CASHFLOWS CC,
            CE_CASHFLOW_ACCT_H CCH
      WHERE pay.payment_instruction_id = P_PAYMENT_INSTRUCTION_ID
        AND CC.CASHFLOW_STATUS_CODE  IN ('CREATED', 'CLEARED')
        AND CC.CASHFLOW_ID = CCH.CASHFLOW_ID
        AND CCH.CURRENT_RECORD_FLAG = 'Y'
        AND CCH.EVENT_TYPE in
            ('CE_STMT_RECORDED', 'CE_BAT_CLEARED', 'CE_BAT_CREATED')
        and cc.source_trxn_type ='BAT'
        AND exists
            (select null
             from ce_payment_transactions pt
             where  cc.trxn_reference_number =  pt.trxn_reference_number
             and pt.trxn_reference_number = cc.trxn_reference_number
             and  pt.trxn_status_code = 'SETTLED')
        and cc.trxn_reference_number = docs.calling_app_doc_ref_number
        and pay.payment_id = docs.payment_id
        and docs.CALLING_APP_ID   = 260
        AND CC.CASHFLOW_LEGAL_ENTITY_ID =  LE.ORGANIZATION_ID
        AND LE.ORGANIZATION_TYPE     = 'LEGAL_ENTITY';

begin

  current_calling_sequence := P_CALLING_SEQUENCE ||
                             'IBY_CE_BATCH_RECON_PKG.Payment_Instruction_Clearing';

  iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
                 debug_level => FND_LOG.LEVEL_PROCEDURE,
                 module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'Input parameters: ',
                 debug_level => FND_LOG.LEVEL_STATEMENT,
                 module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => '============================================',
                 debug_level => FND_LOG.LEVEL_STATEMENT,
                 module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_PAYMENT_INSTRUCTION_ID: ' || P_PAYMENT_INSTRUCTION_ID,
                 debug_level => FND_LOG.LEVEL_STATEMENT,
                 module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_ACCOUNTING_DATE: ' || P_ACCOUNTING_DATE,
                  debug_level => FND_LOG.LEVEL_STATEMENT,
                  module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_CLEARED_DATE: ' || P_CLEARED_DATE,
                  debug_level => FND_LOG.LEVEL_STATEMENT,
                  module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_TRANSACTION_AMOUNT: ' || P_TRANSACTION_AMOUNT,
                  debug_level => FND_LOG.LEVEL_STATEMENT,
                  module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_ERROR_AMOUNT: ' || P_ERROR_AMOUNT,
                  debug_level => FND_LOG.LEVEL_STATEMENT,
                  module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_CHARGE_AMOUNT: ' || P_CHARGE_AMOUNT,
                  debug_level => FND_LOG.LEVEL_STATEMENT,
                  module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_CURRENCY_CODE: ' || P_CURRENCY_CODE,
                  debug_level => FND_LOG.LEVEL_STATEMENT,
                  module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_EXCHANGE_RATE_TYPE: ' || P_EXCHANGE_RATE_TYPE,
                  debug_level => FND_LOG.LEVEL_STATEMENT,
                  module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_EXCHANGE_RATE_DATE: ' || P_EXCHANGE_RATE_DATE,
                  debug_level => FND_LOG.LEVEL_STATEMENT,
                  module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_EXCHANGE_RATE: ' || P_EXCHANGE_RATE,
                  debug_level => FND_LOG.LEVEL_STATEMENT,
                  module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_MATCHED_FLAG: ' || P_MATCHED_FLAG,
                  debug_level => FND_LOG.LEVEL_STATEMENT,
                  module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_ACTUAL_VALUE_DATE: ' || P_ACTUAL_VALUE_DATE,
                  debug_level => FND_LOG.LEVEL_STATEMENT,
                  module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_PASSIN_MODE: ' || P_PASSIN_MODE,
                  debug_level => FND_LOG.LEVEL_STATEMENT,
                  module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_STATEMENT_LINE_ID: ' || P_STATEMENT_LINE_ID,
                  debug_level => FND_LOG.LEVEL_STATEMENT,
                  module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_STATEMENT_LINE_TYPE: ' || P_STATEMENT_LINE_TYPE,
                  debug_level => FND_LOG.LEVEL_STATEMENT,
                  module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => '============================================',
                 debug_level => FND_LOG.LEVEL_STATEMENT,
                 module => l_Debug_Module);


  IF (P_PAYMENT_INSTRUCTION_ID IS NULL ) THEN
    fnd_message.set_name('IBY', 'IBY_G_INVALID_PARAM_ERR');
    fnd_message.set_token('API', l_Debug_Module);
    fnd_message.set_token('PARAM', P_PAYMENT_INSTRUCTION_ID);
    fnd_message.set_token('REASON', ' parameter cannot be null');
    FND_MSG_PUB.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;


  l_errors_bank_amount  := nvl(P_ERROR_AMOUNT, 0);
  l_charges_bank_amount := nvl(P_CHARGE_AMOUNT, 0);

  SELECT   base_currency_code
  INTO    l_functional_currency_code
  FROM    ap_system_parameters;

  iby_debug_pub.add(debug_msg => 'base_currency_code: ' || l_functional_currency_code,
                 debug_level => FND_LOG.LEVEL_STATEMENT,
                 module => l_Debug_Module);

  SELECT   payment_currency_code
    INTO   l_pmt_currency_code
    FROM   iby_pay_instructions_all
    WHERE  payment_instruction_id = P_PAYMENT_INSTRUCTION_ID;

  iby_debug_pub.add(debug_msg => 'payment currency_code: ' || l_pmt_currency_code,
                 debug_level => FND_LOG.LEVEL_STATEMENT,
                 module => l_Debug_Module);

  l_currency_case := Case_Type(P_CURRENCY_CODE,
                               l_pmt_currency_code,
                               l_functional_currency_code
                              );

  iby_debug_pub.add(debug_msg => 'l_currency_case: ' || l_currency_case,
                 debug_level => FND_LOG.LEVEL_STATEMENT,
                 module => l_Debug_Module);

    -- If international or  cross currency, convert to payment currency
    -- the errors and charges before proration.
    IF (l_currency_case = 'INTERNATIONAL') THEN

      l_remainder_errors_pmt_amt := AP_UTILITIES_PKG.AP_ROUND_CURRENCY (
                             l_errors_bank_amount / nvl(P_EXCHANGE_RATE,1),
                             l_pmt_currency_code );
      l_remainder_charges_pmt_amt := AP_UTILITIES_PKG.AP_ROUND_CURRENCY (
                             l_charges_bank_amount / nvl(P_EXCHANGE_RATE,1),
                             l_pmt_currency_code );

      -- Since the bank and base currencies are the same ...
      l_bank_to_base_xrate_type := NULL;
      l_bank_to_base_xrate_date := NULL;
      l_bank_to_base_xrate := NULL;

    ELSIF (l_currency_case = 'FOREIGN') THEN

      l_remainder_errors_pmt_amt := l_errors_bank_amount;
      l_remainder_charges_pmt_amt := l_charges_bank_amount;
      l_bank_to_base_xrate_type := P_EXCHANGE_RATE_TYPE;
      l_bank_to_base_xrate_date := P_EXCHANGE_RATE_DATE;
      l_bank_to_base_xrate := P_EXCHANGE_RATE;

    ELSIF (l_currency_case = 'DOMESTIC') THEN

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

    OPEN l_ins_total_cur;
    FETCH l_ins_total_cur INTO l_payment_count, l_pay_sum_amt, l_max_pmt_amt;
    CLOSE l_ins_total_cur;

    l_running_total_payments := 0;

    -- start the main proration loop
    OPEN l_ins_pmt_clr_cur;
    LOOP

      FETCH l_ins_pmt_clr_cur INTO
                l_trx_id,
                l_status,
                l_check_amount,
                l_app_id;

      l_debug_info := 'Inside l_ins_pmt_clr_cur cursor';
      iby_debug_pub.add(debug_msg => 'l_trx_id: ' || l_trx_id,
                        debug_level => FND_LOG.LEVEL_STATEMENT,
                        module => l_Debug_Module);

      iby_debug_pub.add(debug_msg => 'l_status: ' || l_status,
                        debug_level => FND_LOG.LEVEL_STATEMENT,
                        module => l_Debug_Module);

      iby_debug_pub.add(debug_msg => 'l_check_amount: ' || l_check_amount,
                        debug_level => FND_LOG.LEVEL_STATEMENT,
                        module => l_Debug_Module);

      iby_debug_pub.add(debug_msg => 'l_app_id: ' || l_app_id,
                        debug_level => FND_LOG.LEVEL_STATEMENT,
                        module => l_Debug_Module);

      IF l_ins_pmt_clr_cur%NOTFOUND THEN
        IF l_ins_pmt_clr_cur%ROWCOUNT < 1 THEN
          RAISE no_data_found;
        ELSE                       -- No more rows
          EXIT ;
        END IF;
      END IF;

      l_running_total_payments := l_running_total_payments + l_check_amount;

      IF (l_pay_sum_amt = 0) THEN
        l_debug_info := 'Inside l_pay_sum_amt is 0';

        l_ind_errors_pmt_amount  := AP_UTILITIES_PKG.AP_ROUND_CURRENCY (
                                    l_errors_pmt_amount/l_payment_count,
                                    l_pmt_currency_code );
        l_ind_charges_pmt_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY (
                                    l_charges_pmt_amount/l_payment_count,
                                    l_pmt_currency_code );

      ELSIF (l_running_total_payments = l_pay_sum_amt) THEN
        l_debug_info := 'Inside l_pay_sum_amt is running total';

        l_ind_errors_pmt_amount := l_remainder_errors_pmt_amt;
        l_ind_charges_pmt_amount := l_remainder_charges_pmt_amt;

      ELSE
        l_debug_info := 'Inside l_pay_sum_amt is another value';

        l_ind_errors_pmt_amount  := AP_UTILITIES_PKG.AP_ROUND_CURRENCY (
                                    l_errors_pmt_amount*l_check_amount
                                                       /l_pay_sum_amt,
                                    l_pmt_currency_code );
        l_ind_charges_pmt_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY (
                                    l_charges_pmt_amount*l_check_amount
                                                        /l_pay_sum_amt,
                                    l_pmt_currency_code );

      END IF ; -- Total payment batch amount is 0


      IF (l_currency_case = 'INTERNATIONAL') THEN

        IF (l_running_total_payments = l_pay_sum_amt) THEN
          l_debug_info := 'Inside Negotiable, International amounts equal';

          l_trx_base_amount := P_TRANSACTION_AMOUNT - l_runtotal_trx_bank_amount;
          l_errors_base_amount := P_ERROR_AMOUNT
                                       - l_runtotal_errors_bank_amount;
          l_charges_base_amount := P_CHARGE_AMOUNT
                                       - l_runtotal_charges_bank_amount;
        ELSE
          l_debug_info := 'Inside Negotiable, International amounts not eq';

          l_trx_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                   (l_check_amount + l_ind_errors_pmt_amount
                    + l_ind_charges_pmt_amount) * nvl(P_EXCHANGE_RATE,1),
                   l_functional_currency_code);
          l_errors_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                                                l_ind_errors_pmt_amount
                                                 * nvl(P_EXCHANGE_RATE,1),
                                                l_functional_currency_code);
          l_charges_base_amount := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
                                                l_ind_charges_pmt_amount
                                                 * nvl(P_EXCHANGE_RATE,1),
                                                l_functional_currency_code);
        END IF;

        l_runtotal_trx_bank_amount := l_runtotal_trx_bank_amount
                                       + l_trx_base_amount;
        l_runtotal_errors_bank_amount := l_runtotal_errors_bank_amount
                                          + l_errors_base_amount;
        l_runtotal_charges_bank_amount := l_runtotal_charges_bank_amount
                                           + l_charges_base_amount;

        l_bank_trxn_amount := l_trx_base_amount;
        l_bank_error_amount := l_errors_base_amount;
        l_bank_charge_amount := l_charges_base_amount;

      ELSIF (l_currency_case = 'FOREIGN' OR l_currency_case = 'DOMESTIC') THEN
        l_bank_trxn_amount := l_check_amount + l_ind_errors_pmt_amount + l_ind_charges_pmt_amount;
        l_bank_error_amount := l_ind_errors_pmt_amount;
        l_bank_charge_amount := l_ind_charges_pmt_amount;

      END IF;

      IF l_app_id = 200 THEN
        AP_RECONCILIATION_PKG.recon_payment_history(
          X_CHECKRUN_ID           => NULL,
          X_CHECK_ID              => l_trx_id,
          X_ACCOUNTING_DATE       => P_ACCOUNTING_DATE,
          X_CLEARED_DATE          => P_CLEARED_DATE,
          X_TRANSACTION_AMOUNT    => NVL(l_bank_trxn_amount, 0),
          X_TRANSACTION_TYPE      => 'PAYMENT CLEARING',
          X_ERROR_AMOUNT          => NVL(l_bank_error_amount, 0),
          X_CHARGE_AMOUNT         => NVL(l_bank_charge_amount, 0),
          X_CURRENCY_CODE         => P_CURRENCY_CODE,
          X_EXCHANGE_RATE_TYPE    => P_EXCHANGE_RATE_TYPE,
          X_EXCHANGE_RATE_DATE    => P_EXCHANGE_RATE_DATE,
          X_EXCHANGE_RATE         => P_EXCHANGE_RATE,
          X_MATCHED_FLAG          => 'Y',
          X_ACTUAL_VALUE_DATE     => P_ACTUAL_VALUE_DATE,
          X_LAST_UPDATE_DATE      => P_LAST_UPDATE_DATE,
          X_LAST_UPDATED_BY       => P_LAST_UPDATED_BY,
          X_LAST_UPDATE_LOGIN     => P_LAST_UPDATE_LOGIN,
          X_CREATED_BY            => P_CREATED_BY,
          X_CREATION_DATE         => P_CREATION_DATE,
          X_PROGRAM_UPDATE_DATE   => P_PROGRAM_UPDATE_DATE,
          X_PROGRAM_APPLICATION_ID=> P_PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID            => P_PROGRAM_ID,
          X_REQUEST_ID            => P_REQUEST_ID,
          X_CALLING_SEQUENCE      => current_calling_sequence
        );
      ELSIF l_app_id = 260 THEN
        CE_CASHFLOW_PKG.clear_cashflow(
          X_CASHFLOW_ID                => l_trx_id,
          X_TRX_STATUS                 => l_status,
          X_actual_value_date          => P_ACTUAL_VALUE_DATE,
          X_ACCOUNTING_DATE            => P_ACCOUNTING_DATE,
          X_CLEARED_DATE               => P_CLEARED_DATE,
          X_CLEARED_AMOUNT             => NVL(l_bank_trxn_amount, 0),
          X_CLEARED_ERROR_AMOUNT       => NVL(l_bank_error_amount, 0),
          X_CLEARED_CHARGE_AMOUNT      => NVL(l_bank_charge_amount, 0),
          X_CLEARED_EXCHANGE_RATE_TYPE => P_EXCHANGE_RATE_TYPE,
          X_CLEARED_EXCHANGE_RATE_DATE => P_EXCHANGE_RATE_DATE,
          X_CLEARED_EXCHANGE_RATE      => P_EXCHANGE_RATE,
          X_PASSIN_MODE                => P_PASSIN_MODE,
          X_STATEMENT_LINE_ID          => P_STATEMENT_LINE_ID,
          X_STATEMENT_LINE_TYPE        => P_STATEMENT_LINE_TYPE
        );
    END IF;

      l_remainder_errors_pmt_amt  := l_remainder_errors_pmt_amt
                                                - l_ind_errors_pmt_amount;
      l_remainder_charges_pmt_amt := l_remainder_charges_pmt_amt
                                                - l_ind_charges_pmt_amount;

    END LOOP; -- Loop through payments in an instruction

    CLOSE l_ins_pmt_clr_cur;

  iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
                 debug_level => FND_LOG.LEVEL_PROCEDURE,
                 module => l_Debug_Module);


EXCEPTION
  WHEN NO_DATA_FOUND THEN
       IF l_ins_pmt_clr_cur%ISOPEN THEN
         CLOSE l_ins_pmt_clr_cur;
       END IF;
       FND_MESSAGE.SET_NAME('SQLAP','AP_RECON_NO_DATA_FOUND');
       APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
       IF l_ins_pmt_clr_cur%ISOPEN THEN
         CLOSE l_ins_pmt_clr_cur;
       END IF;
       RAISE;

END Payment_Instruction_Clearing;




PROCEDURE Payment_Instruction_Unclearing(
                          P_PAYMENT_INSTRUCTION_ID IN NUMBER,
                          P_ACCOUNTING_DATE        IN DATE,
                          P_MATCHED_FLAG           IN VARCHAR2,
                          P_LAST_UPDATE_DATE       IN DATE,
                          P_LAST_UPDATED_BY        IN NUMBER,
                          P_LAST_UPDATE_LOGIN      IN NUMBER,
                          P_CREATED_BY             IN NUMBER,
                          P_CREATION_DATE          IN DATE,
                          P_PROGRAM_UPDATE_DATE    IN DATE,
                          P_PROGRAM_APPLICATION_ID IN NUMBER,
                          P_PROGRAM_ID             IN NUMBER,
                          P_REQUEST_ID             IN NUMBER,
                          P_CALLING_SEQUENCE       IN VARCHAR2
) AS

  -- conditions for AP are
  -- copied from apreconb 115.44
  CURSOR l_ins_pmt_unclr_cur IS
  SELECT chk.check_id,
         200 app_id
    FROM iby_payments_all pmt,
         iby_pay_service_requests ppr,
         ap_checks_all chk,
         ap_payment_history apha
   WHERE pmt.payment_instruction_id = P_PAYMENT_INSTRUCTION_ID
     AND pmt.payment_service_request_id = ppr.payment_service_request_id
     AND ppr.calling_app_id = 200
     AND apha.check_id = chk.check_id
     AND apha.transaction_type = 'PAYMENT CLEARING'
     AND chk.status_lookup_code IN
                 ('CLEARED', 'CLEARED BUT UNACCOUNTED',
                  'RECONCILED', 'RECONCILED UNACCOUNTED')
     AND NOT EXISTS
         (SELECT aphb.payment_history_id
          FROM   ap_payment_history aphb
          WHERE  aphb.check_id = apha.check_id
          AND    aphb.rev_pmt_hist_id = apha.payment_history_id);

  l_trx_id    NUMBER;
  l_app_id    NUMBER;
  current_calling_sequence    VARCHAR2(2000);
  l_debug_info                  VARCHAR2(240);
  l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.Payment_Instruction_Unclearing';

begin

  current_calling_sequence := P_CALLING_SEQUENCE ||
                             'IBY_CE_BATCH_RECON_PKG.Payment_Instruction_Unclearing';

  iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
                 debug_level => FND_LOG.LEVEL_PROCEDURE,
                 module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'Input parameters: ',
                 debug_level => FND_LOG.LEVEL_STATEMENT,
                 module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => '============================================',
                 debug_level => FND_LOG.LEVEL_STATEMENT,
                 module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_PAYMENT_INSTRUCTION_ID: ' || P_PAYMENT_INSTRUCTION_ID,
                 debug_level => FND_LOG.LEVEL_STATEMENT,
                 module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_ACCOUNTING_DATE: ' || P_ACCOUNTING_DATE,
                  debug_level => FND_LOG.LEVEL_STATEMENT,
                  module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => 'P_MATCHED_FLAG: ' || P_MATCHED_FLAG,
                  debug_level => FND_LOG.LEVEL_STATEMENT,
                  module => l_Debug_Module);

  iby_debug_pub.add(debug_msg => '============================================',
                 debug_level => FND_LOG.LEVEL_STATEMENT,
                 module => l_Debug_Module);


  IF (P_PAYMENT_INSTRUCTION_ID IS NULL ) THEN
    fnd_message.set_name('IBY', 'IBY_G_INVALID_PARAM_ERR');
    fnd_message.set_token('API', l_Debug_Module);
    fnd_message.set_token('PARAM', P_PAYMENT_INSTRUCTION_ID);
    fnd_message.set_token('REASON', ' parameter cannot be null');
    FND_MSG_PUB.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;


  -- start the main loop
  OPEN l_ins_pmt_unclr_cur;
  LOOP

    FETCH l_ins_pmt_unclr_cur INTO
              l_trx_id,
              l_app_id;

    l_debug_info := 'Inside l_ins_pmt_unclr_cur cursor';

    IF l_ins_pmt_unclr_cur%NOTFOUND THEN
      IF l_ins_pmt_unclr_cur%ROWCOUNT < 1 THEN
        RAISE no_data_found;
      ELSE                       -- No more rows
        EXIT ;
      END IF;
    END IF;

    IF l_app_id = 200 THEN
      AP_RECONCILIATION_PKG.recon_payment_history(
        X_CHECKRUN_ID           => NULL,
        X_CHECK_ID              => l_trx_id,
        X_ACCOUNTING_DATE       => P_ACCOUNTING_DATE,
        X_CLEARED_DATE          => NULL,
        X_TRANSACTION_AMOUNT    => NULL,
        X_TRANSACTION_TYPE      => 'PAYMENT UNCLEARING',
        X_ERROR_AMOUNT          => NULL,
        X_CHARGE_AMOUNT         => NULL,
        X_CURRENCY_CODE         => NULL,
        X_EXCHANGE_RATE_TYPE    => NULL,
        X_EXCHANGE_RATE_DATE    => NULL,
        X_EXCHANGE_RATE         => NULL,
        X_MATCHED_FLAG          => P_MATCHED_FLAG,
        X_ACTUAL_VALUE_DATE     => NULL,
        X_LAST_UPDATE_DATE      => P_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY       => P_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN     => P_LAST_UPDATE_LOGIN,
        X_CREATED_BY            => P_CREATED_BY,
        X_CREATION_DATE         => P_CREATION_DATE,
        X_PROGRAM_UPDATE_DATE   => P_PROGRAM_UPDATE_DATE,
        X_PROGRAM_APPLICATION_ID=> P_PROGRAM_APPLICATION_ID,
        X_PROGRAM_ID            => P_PROGRAM_ID,
        X_REQUEST_ID            => P_REQUEST_ID,
        X_CALLING_SEQUENCE      => current_calling_sequence
      );
    END IF;

  END LOOP; -- Loop through payments in an instruction

  CLOSE l_ins_pmt_unclr_cur;

  iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
                 debug_level => FND_LOG.LEVEL_PROCEDURE,
                 module => l_Debug_Module);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       IF l_ins_pmt_unclr_cur%ISOPEN THEN
         CLOSE l_ins_pmt_unclr_cur;
       END IF;
       FND_MESSAGE.SET_NAME('SQLAP','AP_RECON_NO_DATA_FOUND');
       APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
       IF l_ins_pmt_unclr_cur%ISOPEN THEN
         CLOSE l_ins_pmt_unclr_cur;
       END IF;
       RAISE;

end Payment_Instruction_Unclearing;



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


END IBY_CE_BATCH_RECON_PKG;



/
