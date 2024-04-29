--------------------------------------------------------
--  DDL for Package Body CE_AUTO_BANK_CLEAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_AUTO_BANK_CLEAR" AS
/* $Header: ceabrcrb.pls 120.14.12010000.3 2008/11/20 09:04:33 vnetan ship $ */
  CURSOR C_STATEMENT_LINE_SEQ IS SELECT ce_statement_lines_s.nextval from sys.dual;

FUNCTION body_revision RETURN VARCHAR2 IS
BEGIN

  RETURN '$Revision: 120.14.12010000.3 $';

END body_revision;

FUNCTION spec_revision RETURN VARCHAR2 IS
BEGIN

  RETURN G_spec_revision;

END spec_revision;
/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       set_manual_clearing                                             |
 --------------------------------------------------------------------- */
  PROCEDURE set_manual_clearing IS
  BEGIN
    CE_AUTO_BANK_CLEAR.yes_manual_clearing := 1;
  END set_manual_clearing;

  PROCEDURE set_reverse_mode IS
  BEGIN
    CE_AUTO_BANK_CLEAR.yes_reverse_mode := 1;
  END set_reverse_mode;

  PROCEDURE unset_manual_clearing IS
  BEGIN
    CE_AUTO_BANK_CLEAR.yes_manual_clearing := 0;
  END unset_manual_clearing;

  PROCEDURE unset_reverse_mode IS
  BEGIN
    CE_AUTO_BANK_CLEAR.yes_reverse_mode := 0;
  END unset_reverse_mode;

  FUNCTION get_manual_clearing RETURN NUMBER IS
  BEGIN
    RETURN CE_AUTO_BANK_CLEAR.yes_manual_clearing;
  END get_manual_clearing;

  FUNCTION get_reverse_mode RETURN NUMBER IS
  BEGIN
    RETURN CE_AUTO_BANK_CLEAR.yes_reverse_mode;
  END get_reverse_mode;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	update_line_status						|
|									|
|  DESCRIPTION								|
|	Update the record status to indicate its current state.		|
 --------------------------------------------------------------------- */
PROCEDURE update_line_status (
		X_statement_line_id		NUMBER,
		X_status			VARCHAR2) IS
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_CLEAR.update_line_status');
  if (X_status = 'RECONCILED') then
    if (CE_AUTO_BANK_MATCH.trx_currency_type = 'BANK'
        and CE_AUTO_BANK_MATCH.foreign_exchange_defaulted = 'Y') then
      UPDATE ce_statement_lines l
      SET    status             = X_status,
             reconcile_to_statement_flag =
                              CE_AUTO_BANK_MATCH.reconcile_to_statement_flag
      WHERE  statement_line_id  = X_statement_line_id
      AND EXISTS
         (select NULL
         from  ce_statement_recon_gt_v --ce_statement_reconciliations
         where statement_line_id = l.statement_line_id
         and   current_record_flag = 'Y'
         and   status_flag = 'M');
    else
      UPDATE ce_statement_lines l
       SET    status             = X_status,
              exchange_rate_type = CE_AUTO_BANK_MATCH.csl_exchange_rate_type,
              exchange_rate_date = CE_AUTO_BANK_MATCH.csl_exchange_rate_date,
              exchange_rate      = CE_AUTO_BANK_MATCH.csl_exchange_rate,
              currency_code      = CE_AUTO_BANK_MATCH.csl_currency_code,
              reconcile_to_statement_flag =
                              CE_AUTO_BANK_MATCH.reconcile_to_statement_flag
       WHERE  statement_line_id  = X_statement_line_id
       AND EXISTS
             (select NULL
              from  ce_statement_recon_gt_v --ce_statement_reconciliations
              where statement_line_id = l.statement_line_id
              and   current_record_flag = 'Y'
              and   status_flag = 'M');
    end if;
  else  /* UNRECONCILED */
    UPDATE ce_statement_lines
    SET    status             = X_status,
           reconcile_to_statement_flag =
                              CE_AUTO_BANK_MATCH.reconcile_to_statement_flag
    WHERE  statement_line_id  = X_statement_line_id;
  end if;
  cep_standard.debug('<<CE_AUTO_BANK_CLEAR.update_line_status');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION:  CE_AUTO_BANK_CLEAR.update_line_status');
    RAISE;
END update_line_status;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       DM_reversals                                                    |
|  CALLED BY                                                            |
|       reconcile_process                                               |
 --------------------------------------------------------------------- */
PROCEDURE DM_reversals
                   ( cash_receipt_id                 NUMBER,
                     cc_id                           NUMBER,
                     cust_trx_type_id                NUMBER,
                     cust_trx_type                   VARCHAR2,
                     gl_date                         DATE,
                     reversal_date                   DATE,
                     reason                          VARCHAR2,
                     category                        VARCHAR2,
                     module_name                     VARCHAR2,
                     comment                         VARCHAR2,
                     document_number                 NUMBER,
                     doc_sequence_id                 NUMBER) IS
  out_trx_number     ar_payment_schedules.trx_number%TYPE;
  out_status	     varchar2(10);
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_CLEAR.DM_reversals');

  ARP_CASHBOOK.debit_memo_reversal
		      ( p_cash_receipt_id       => cash_receipt_id,
			p_cc_id			=> cc_id,
			p_dm_cust_trx_type_id	=> cust_trx_type_id,
			p_dm_cust_trx_type	=> cust_trx_type,
                        p_reversal_gl_date      => gl_date,
			p_reversal_date		=> reversal_date,
			p_reversal_category	=> category,
			p_reversal_reason_code	=> reason,
			p_reversal_comments	=> comment,
			p_dm_number		=> out_trx_number,
			p_dm_doc_sequence_value => document_number,
			p_dm_doc_sequence_id	=> doc_sequence_id,
			p_tw_status		=> out_status,
                        p_module_name           => 'CEXCABMR',
                        p_module_version        => '11.5');

  cep_standard.debug('<<CE_AUTO_BANK_CLEAR.DM_reversals');
END DM_reversals;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       reversals                                                  	|
|  CALLED BY                                                            |
|       reconcile_process                                               |
 --------------------------------------------------------------------- */
PROCEDURE reversals( cash_receipt_id                	NUMBER,
                     gl_date                        	DATE,
		     reason			        VARCHAR2,
		     category				VARCHAR2,
                     module_name                    	VARCHAR2,
                     comment                        	VARCHAR2 ) IS
  history_id         AR_CASH_RECEIPT_HISTORY_ALL.cash_receipt_history_id%TYPE;
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_CLEAR.reversals');
  ARP_CASHBOOK.reverse( p_cr_id             		=> cash_receipt_id,
               		p_reversal_gl_date 		=> gl_date,
                	p_reversal_date         	=> sysdate,
                	p_reversal_comments     	=> comment,
                	p_reversal_reason_code   	=> reason,
                	p_reversal_category 		=> category,
                	p_module_name      		=> module_name,
                	p_module_version   		=> '1.0',
                	p_crh_id      			=> history_id);
  cep_standard.debug('<<CE_AUTO_BANK_CLEAR.reversals');
END reversals;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       reconcile_rbatch                                           	|
|  DESCRIPTION                                                          |
|       Each receipt within the remittance batch must be cleared and    |
|       reconciled.                                                     |
|  CALLED BY                                                            |
|       reconcile_process                                               |
 --------------------------------------------------------------------- */
PROCEDURE reconcile_rbatch(
	passin_mode          		VARCHAR2,
        rbatch_id            		NUMBER,
        X_statement_line_id    	IN OUT NOCOPY	NUMBER,
        gl_date              		DATE,
	value_date			DATE,
        bank_currency	     		VARCHAR2,
        exchange_rate_type   		VARCHAR2,
        exchange_rate	     		NUMBER,
        exchange_rate_date   		DATE,
	trx_currency_type    		VARCHAR2,
        module               		VARCHAR2,
        X_trx_number            IN OUT NOCOPY	VARCHAR2,
        X_trx_date              	DATE,
        X_deposit_date          	DATE,
        X_amount                	NUMBER,
	X_foreign_diff_amt		NUMBER,
	X_set_of_books_id		NUMBER,
        X_misc_currency_code    	VARCHAR2,
        X_receipt_method_id     	NUMBER,
        X_bank_account_id       	NUMBER,
        X_activity_type_id      	NUMBER,
        X_comments              	VARCHAR2,
        X_reference_type        	VARCHAR2,
        X_clear_currency_code   	VARCHAR2,
	X_tax_id			NUMBER,
        X_tax_rate			NUMBER,
	X_cr_vat_tax_id			VARCHAR2,
	X_dr_vat_tax_id			VARCHAR2,
        X_trx_type              	VARCHAR2        DEFAULT NULL,
        X_statement_header_id   IN OUT NOCOPY 	NUMBER,
        X_statement_date        	DATE            DEFAULT NULL,
        X_bank_trx_number       	VARCHAR2        DEFAULT NULL,
	X_statement_amount		NUMBER		DEFAULT NULL,
        X_original_amount       	NUMBER          DEFAULT NULL,
        X_effective_date		DATE,
        X_float_handling_flag		VARCHAR2) IS
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_CLEAR.reconcile_rbatch');
  CE_AUTO_BANK_CLEAR1.reconcile_rbatch(
        passin_mode,
        rbatch_id,
        X_statement_line_id,
        gl_date,
	value_date,
        bank_currency,
        exchange_rate_type,
        exchange_rate,
        exchange_rate_date,
        trx_currency_type,
        module,
        X_trx_number,
        X_trx_date,
        X_deposit_date,
        X_amount,
        X_foreign_diff_amt,
        X_set_of_books_id,
        X_misc_currency_code,
        X_receipt_method_id,
        X_bank_account_id,
        X_activity_type_id,
        X_comments,
        X_reference_type,
        X_clear_currency_code,
        X_tax_id,
        X_tax_rate,
        X_cr_vat_tax_id,
        X_dr_vat_tax_id,
        X_trx_type,
        X_statement_header_id,
        X_statement_date,
        X_bank_trx_number,
        X_statement_amount,
        X_original_amount,
        X_effective_date,
        X_float_handling_flag);
  cep_standard.debug('<<CE_AUTO_BANK_CLEAR.reconcile_rbatch');
END reconcile_rbatch;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       misc_receipt                                                    |
 --------------------------------------------------------------------- */
PROCEDURE misc_receipt(  	X_passin_mode           VARCHAR2,
                                X_trx_number            VARCHAR2,
                                X_doc_sequence_value    VARCHAR2,
                                X_doc_sequence_id       NUMBER,
                                X_gl_date               DATE,
				X_value_date		DATE,
                                X_trx_date              DATE,
                                X_deposit_date          DATE,
                                X_amount                NUMBER,
                		X_bank_account_amount   NUMBER,
                                X_set_of_books_id       NUMBER,
                                X_misc_currency_code    VARCHAR2,
                                X_exchange_rate_date    DATE,
                                X_exchange_rate_type    VARCHAR2,
                                X_exchange_rate         NUMBER,
                                X_receipt_method_id     NUMBER,
                                X_bank_account_id       NUMBER,
                                X_activity_type_id      NUMBER,
                                X_comments              VARCHAR2,
                                X_reference_type        VARCHAR2,
                                X_reference_id          NUMBER,
                                X_clear_currency_code   VARCHAR2,
                                X_statement_line_id     IN OUT NOCOPY NUMBER,
                                X_tax_id                NUMBER,
                                X_tax_rate		NUMBER,
				X_paid_from		VARCHAR2,
                                X_module_name           VARCHAR2,
				X_cr_vat_tax_id		VARCHAR2,
				X_dr_vat_tax_id		VARCHAR2,
                                trx_currency_type       VARCHAR2,
                		X_cr_id  	IN OUT NOCOPY  NUMBER,
				X_effective_date	DATE,
				X_org_id		NUMBER ) IS
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_CLEAR.misc_receipt');
  CE_AUTO_BANK_CLEAR1.misc_receipt(
	X_passin_mode,
        X_trx_number,
        X_doc_sequence_value,
        X_doc_sequence_id,
        X_gl_date,
	X_value_date,
        X_trx_date,
        X_deposit_date,
        X_amount,
        X_bank_account_amount,
        X_set_of_books_id,
        X_misc_currency_code,
        X_exchange_rate_date,
        X_exchange_rate_type,
        X_exchange_rate,
        X_receipt_method_id,
        X_bank_account_id,
        X_activity_type_id,
        X_comments,
        X_reference_type,
        X_reference_id,
        X_clear_currency_code,
        X_statement_line_id,
        X_tax_id,
        X_tax_rate,
        X_paid_from,
        X_module_name,
        X_cr_vat_tax_id,
        X_dr_vat_tax_id,
        trx_currency_type,
        X_cr_id,
        X_effective_date,
        X_org_id);
  cep_standard.debug('<<CE_AUTO_BANK_CLEAR.misc_receipt');
END misc_receipt;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|    reconcile_pbatch                                                   |
|  CALLED BY                                                            |
|    reconcile_process							|
 --------------------------------------------------------------------- */
PROCEDURE reconcile_pbatch (	 passin_mode             	VARCHAR2,
                                 pbatch_id               	NUMBER,
                                 statement_line_id	IN OUT NOCOPY	NUMBER,
                                 gl_date                 	DATE,
				 value_date                     DATE,
				 cleared_date			DATE,
                                 amount_to_clear         	NUMBER,
                                 errors_amount           	NUMBER,
                                 charges_amount			NUMBER,
				 prorate_amount			NUMBER,
                                 exchange_rate_type	 	VARCHAR2,
                                 exchange_rate_date	 	DATE,
                                 exchange_rate		 	NUMBER,
				 trx_currency_type	 	VARCHAR2,
                        	 X_statement_header_id	IN OUT NOCOPY 	NUMBER,
                        	 statement_header_date          DATE,
                        	 X_trx_type              	VARCHAR2,
                        	 X_bank_trx_number       	VARCHAR2,
                        	 X_currency_code         	VARCHAR2,
                        	 X_original_amount       	NUMBER,
                	 	 X_effective_date		DATE,
                	 	 X_float_handling_flag		VARCHAR2,
				 X_bank_currency_code           VARCHAR2,
				 pgroup_id                      VARCHAR2 default null -- FOR SEPA ER 6700007
				 ) IS
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_CLEAR.reconcile_pbatch');
  CE_AUTO_BANK_CLEAR1.reconcile_pbatch(
		passin_mode,
                pbatch_id,
                statement_line_id,
                gl_date,
		value_date,
                cleared_date,
                amount_to_clear,
                errors_amount,
                charges_amount,
                prorate_amount,
                exchange_rate_type,
                exchange_rate_date,
                exchange_rate,
                trx_currency_type,
                X_statement_header_id,
                statement_header_date,
                X_trx_type,
                X_bank_trx_number,
                X_currency_code,
                X_original_amount,
                X_effective_date,
                X_float_handling_flag,
		X_bank_currency_code,
		pgroup_id);
  cep_standard.debug('<<CE_AUTO_BANK_CLEAR.reconcile_pbatch');
END reconcile_pbatch;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	calc_foreign_clearing_amounts					|
|  CALLED BY								|
|	calculate_clearing_amounts					|
 --------------------------------------------------------------------- */
PROCEDURE calc_foreign_clearing_amounts (success IN OUT NOCOPY BOOLEAN) IS
  difference_amount	NUMBER;
  clearing_sign         NUMBER;
  real_rate		NUMBER;
  precision                     NUMBER;
  ext_precision                 NUMBER;
  min_acct_unit                 NUMBER;
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_CLEAR.calc_foreign_clearing_amounts');
  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.csl_match_type = '||
			CE_AUTO_BANK_MATCH.csl_match_type);
  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.calc_csl_amount = '||
			CE_AUTO_BANK_MATCH.calc_csl_amount);
  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.trx_amount = '||
			CE_AUTO_BANK_MATCH.trx_amount);
  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.csl_clearing_trx_type = '||
			CE_AUTO_BANK_MATCH.csl_clearing_trx_type);

--  cep_standard.debug('DEBUG: CE_AUTO_BANK_REC.G_foreign_difference_handling = '||
--			CE_AUTO_BANK_REC.G_foreign_difference_handling);

  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.ba_recon_ce_fx_diff_handling = '||
			CE_AUTO_BANK_MATCH.ba_recon_ce_fx_diff_handling);
  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.ba_recon_ap_fx_diff_handling = '||
			CE_AUTO_BANK_MATCH.ba_recon_ap_fx_diff_handling);
  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.ba_recon_ar_fx_diff_handling = '||
			CE_AUTO_BANK_MATCH.ba_recon_ar_fx_diff_handling);
  --
  -- Payment
  --
  -- 7571492: Added PGROUP
  IF (CE_AUTO_BANK_MATCH.csl_match_type IN ('PAYMENT','PBATCH','PGROUP') OR
      --CE_AUTO_BANK_MATCH.csl_clearing_trx_type = 'CASHFLOW' OR
      CE_AUTO_BANK_MATCH.trx_match_type = 'PAYMENT') THEN
    if (CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_CREDIT') then
       clearing_sign := -1;
    else
       clearing_sign := 1;
    end if;

    -- bug 4528375
    -- trx_amount was not rounded in view ce_200_transactions_v, so round it
    fnd_currency.get_info(CE_AUTO_BANK_MATCH.aba_bank_currency,
                      precision, ext_precision, min_acct_unit);
    CE_AUTO_BANK_MATCH.trx_amount := round(CE_AUTO_BANK_MATCH.trx_amount, precision);

    difference_amount 	:= CE_AUTO_BANK_MATCH.calc_csl_amount * clearing_sign
				- CE_AUTO_BANK_MATCH.trx_amount;
    /* 2886201
    If transaction currency amount is 0, set real_rate to 1.0 to avoid
    Division by Zero error. */
    IF (CE_AUTO_BANK_MATCH.trx_curr_amount = 0) THEN
	real_rate := 1.0;
    ELSE
    	real_rate	:= (CE_AUTO_BANK_MATCH.csl_amount -
				NVL(CE_AUTO_BANK_MATCH.csl_charges_amount,0))/
					    CE_AUTO_BANK_MATCH.trx_curr_amount;
    END IF;

    /* 2886201 End of Code Changes */
    IF (ABS(difference_amount) <> ABS(CE_AUTO_BANK_MATCH.csl_charges_amount))  THEN
      IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type = 'CASHFLOW') THEN
	--IF (CE_AUTO_BANK_MATCH.G_le_fx_difference_handling = 'C') THEN
	IF (CE_AUTO_BANK_MATCH.ba_recon_ce_fx_diff_handling = 'CH') THEN
          CE_AUTO_BANK_MATCH.csl_exchange_rate_type 	:= CE_AUTO_BANK_MATCH.trx_exchange_rate_type;
          CE_AUTO_BANK_MATCH.csl_exchange_rate_date 	:= CE_AUTO_BANK_MATCH.trx_exchange_rate_date;
          CE_AUTO_BANK_MATCH.csl_exchange_rate 		:= CE_AUTO_BANK_MATCH.trx_exchange_rate;

          CE_AUTO_BANK_MATCH.trx_charges_amount := difference_amount;

	ELSIF (CE_AUTO_BANK_MATCH.ba_recon_ce_fx_diff_handling in  ('E', 'FX')) THEN
 	    CE_AUTO_BANK_MATCH.trx_charges_amount := CE_AUTO_BANK_MATCH.csl_charges_amount;
	    CE_AUTO_BANK_MATCH.trx_errors_amount  := difference_amount - CE_AUTO_BANK_MATCH.csl_charges_amount;
	END IF;
      ELSE
        --IF (CE_AUTO_BANK_MATCH.G_foreign_difference_handling = 'G') THEN
        IF (CE_AUTO_BANK_MATCH.ba_recon_ap_fx_diff_handling = 'G') THEN
	--
	-- bug# 1209738
	-- When foreign option is set to Gain/Loss, for EMU Rate Type
	-- do not override the exchange rate
	--
	  IF (CE_AUTO_BANK_MATCH.csl_exchange_rate_type = 'EMU FIXED') THEN
	    CE_AUTO_BANK_MATCH.calc_csl_amount := CE_AUTO_BANK_MATCH.calc_csl_amount + difference_amount;
	  ELSE
            CE_AUTO_BANK_MATCH.trx_charges_amount 		:= CE_AUTO_BANK_MATCH.csl_charges_amount;
     IF (real_rate <> NVL(CE_AUTO_BANK_MATCH.csl_exchange_rate,real_rate+1)) THEN
              CE_AUTO_BANK_MATCH.csl_exchange_rate_type 	:= 'User';
              CE_AUTO_BANK_MATCH.csl_exchange_rate_date 	:= sysdate;
              CE_AUTO_BANK_MATCH.csl_exchange_rate		:= real_rate;
            END IF;
	  END IF;
        ELSIF (CE_AUTO_BANK_MATCH.ba_recon_ap_fx_diff_handling = 'C') THEN
          CE_AUTO_BANK_MATCH.csl_exchange_rate_type 	:= CE_AUTO_BANK_MATCH.trx_exchange_rate_type;
          CE_AUTO_BANK_MATCH.csl_exchange_rate_date 	:= CE_AUTO_BANK_MATCH.trx_exchange_rate_date;
          CE_AUTO_BANK_MATCH.csl_exchange_rate 		:= CE_AUTO_BANK_MATCH.trx_exchange_rate;

	/*
          IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type = 'CASHFLOW') THEN
            IF (CE_AUTO_BANK_REC.G_ce_differences_account = 'CHARGES') THEN
              CE_AUTO_BANK_MATCH.trx_charges_amount := difference_amount;
	    ELSE
 	      CE_AUTO_BANK_MATCH.trx_charges_amount := CE_AUTO_BANK_MATCH.csl_charges_amount;
	      CE_AUTO_BANK_MATCH.trx_errors_amount  := difference_amount - CE_AUTO_BANK_MATCH.csl_charges_amount;
	    END IF;
	  ELSE
	*/
          IF (CE_AUTO_BANK_REC.G_differences_account = 'CHARGES') THEN
            CE_AUTO_BANK_MATCH.trx_charges_amount := difference_amount;
	  ELSE
 	    CE_AUTO_BANK_MATCH.trx_charges_amount := CE_AUTO_BANK_MATCH.csl_charges_amount;
	    CE_AUTO_BANK_MATCH.trx_errors_amount  := difference_amount - CE_AUTO_BANK_MATCH.csl_charges_amount;
	  END IF;
	  --END IF;

        ELSIF (CE_AUTO_BANK_MATCH.ba_recon_ap_fx_diff_handling = 'N') THEN
          CE_RECONCILIATION_ERRORS_PKG.insert_row(
	  CE_AUTO_BANK_MATCH.csh_statement_header_id,
	  CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_FOREIGN_DIFFERENCE');
	  success := FALSE;
        END IF;
      END IF;
    ELSE --diff amt <> csl_charges_amount
      CE_AUTO_BANK_MATCH.trx_charges_amount := difference_amount;

    END IF;
  --
  -- Receipt
  --
  ELSE
    if (CE_AUTO_BANK_MATCH.csl_match_correction_type = 'REVERSAL') then
       difference_amount := 0;
    else
       if (CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_DEBIT' AND
	   CE_AUTO_BANK_MATCH.csl_match_correction_type = 'ADJUSTMENT') then
           clearing_sign := -1;
       else
           clearing_sign := 1;
       end if;
       difference_amount := CE_AUTO_BANK_MATCH.trx_amount -
			    CE_AUTO_BANK_MATCH.calc_csl_amount * clearing_sign;
    end if;

    /* 2886201
    If transaction currency amount is 0, set real_rate to 1.0 to avoid
    Division by Zero error. */
    IF (CE_AUTO_BANK_MATCH.trx_curr_amount = 0) THEN
	real_rate := 1.0;
    ELSE
    	real_rate		:= (CE_AUTO_BANK_MATCH.csl_amount+
				NVL(CE_AUTO_BANK_MATCH.csl_charges_amount,0))/
					CE_AUTO_BANK_MATCH.trx_curr_amount;
    END IF; /* 2886201 End Code Added */

    IF (difference_amount <> CE_AUTO_BANK_MATCH.csl_charges_amount)  THEN
      IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type = 'CASHFLOW') THEN
	IF (CE_AUTO_BANK_MATCH.ba_recon_ce_fx_diff_handling = 'CH') THEN
          CE_AUTO_BANK_MATCH.csl_exchange_rate_type 	:= CE_AUTO_BANK_MATCH.trx_exchange_rate_type;
          CE_AUTO_BANK_MATCH.csl_exchange_rate_date 	:= CE_AUTO_BANK_MATCH.trx_exchange_rate_date;
          CE_AUTO_BANK_MATCH.csl_exchange_rate 		:= CE_AUTO_BANK_MATCH.trx_exchange_rate;

          CE_AUTO_BANK_MATCH.trx_charges_amount := difference_amount;

	ELSIF (CE_AUTO_BANK_MATCH.ba_recon_ce_fx_diff_handling in  ('E', 'FX')) THEN
 	    CE_AUTO_BANK_MATCH.trx_charges_amount := CE_AUTO_BANK_MATCH.csl_charges_amount;
	    CE_AUTO_BANK_MATCH.trx_errors_amount  := difference_amount - CE_AUTO_BANK_MATCH.csl_charges_amount;
	END IF;
      ELSE

        IF (CE_AUTO_BANK_MATCH.ba_recon_ar_fx_diff_handling = 'G') THEN
	  --
	  -- bug# 1209738
	  -- When foreign option is set to Gain/Loss, for EMU Rate Type
	  -- do not override the exchange rate
	  --
	  IF (CE_AUTO_BANK_MATCH.csl_exchange_rate_type = 'EMU FIXED') THEN
	    CE_AUTO_BANK_MATCH.calc_csl_amount := CE_AUTO_BANK_MATCH.calc_csl_amount + difference_amount;
	    cep_standard.debug('****** CE_AUTO_BANK_MATCH.calc_csl_amount = '||to_char(CE_AUTO_BANK_MATCH.calc_csl_amount));
	  ELSE
            CE_AUTO_BANK_MATCH.trx_charges_amount 		:= CE_AUTO_BANK_MATCH.csl_charges_amount;
            IF (real_rate <> NVL(CE_AUTO_BANK_MATCH.csl_exchange_rate,real_rate+1)) THEN
              CE_AUTO_BANK_MATCH.csl_exchange_rate_type 	:= 'User';
              CE_AUTO_BANK_MATCH.csl_exchange_rate_date 	:= sysdate;
              CE_AUTO_BANK_MATCH.csl_exchange_rate		:= real_rate;
            END IF;
	    CE_AUTO_BANK_MATCH.trx_charges_amount := CE_AUTO_BANK_MATCH.csl_charges_amount;
	  END IF;
        ELSIF (CE_AUTO_BANK_MATCH.ba_recon_ar_fx_diff_handling = 'C') THEN
          CE_AUTO_BANK_MATCH.csl_exchange_rate_type 	:= CE_AUTO_BANK_MATCH.trx_exchange_rate_type;
          CE_AUTO_BANK_MATCH.csl_exchange_rate_date 	:= CE_AUTO_BANK_MATCH.trx_exchange_rate_date;
          CE_AUTO_BANK_MATCH.csl_exchange_rate 	:= CE_AUTO_BANK_MATCH.trx_exchange_rate;

        /*IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type = 'CASHFLOW') THEN
            IF (CE_AUTO_BANK_REC.G_ce_differences_account = 'CHARGES') THEN
              CE_AUTO_BANK_MATCH.trx_charges_amount := difference_amount;
	    ELSE
 	      CE_AUTO_BANK_MATCH.trx_charges_amount := CE_AUTO_BANK_MATCH.csl_charges_amount;
	      CE_AUTO_BANK_MATCH.trx_errors_amount  := difference_amount - CE_AUTO_BANK_MATCH.csl_charges_amount;
	    END IF;
	  ELSE	  */

          CE_AUTO_BANK_MATCH.trx_charges_amount := difference_amount;
	  --END IF;
        ELSIF (CE_AUTO_BANK_MATCH.ba_recon_ar_fx_diff_handling = 'N') THEN
          CE_RECONCILIATION_ERRORS_PKG.insert_row(
  	  CE_AUTO_BANK_MATCH.csh_statement_header_id,
	  CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_FOREIGN_DIFFERENCE');
	  success := FALSE;
        END IF;
      END IF;
    ELSE
      CE_AUTO_BANK_MATCH.trx_charges_amount := difference_amount;
    END IF;
  END IF;
  IF (CE_AUTO_BANK_MATCH.csl_exchange_rate IS NULL) THEN
    CE_AUTO_BANK_MATCH.csl_exchange_rate 	:= real_rate;
    CE_AUTO_BANK_MATCH.csl_exchange_rate_type 	:= 'User';
    CE_AUTO_BANK_MATCH.csl_exchange_rate_date 	:= sysdate;
  END IF;
  cep_standard.debug('CE_AUTO_BANK_CLEAR.calc_foreign_clearing_amounts');
END calc_foreign_clearing_amounts;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	calculate_clearing_amounts					|
|  DESCRIPTION								|
|  	Calculates the error/changes/clearing 				|
|  CALLS								|
|	calc_foreign_clearing_amounts					|
|  CALLED BY								|
|       reconcile_process
 --------------------------------------------------------------------- */
FUNCTION calculate_clearing_amounts RETURN BOOLEAN IS
  difference_amount	NUMBER;
  clearing_sign         NUMBER;
  success 		BOOLEAN;
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_CLEAR.calculate_clearing_amounts');
  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.csl_match_type = '||
			CE_AUTO_BANK_MATCH.csl_match_type);
  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.trx_match_type = '||
			CE_AUTO_BANK_MATCH.trx_match_type);
  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.trx_amount = '||
			CE_AUTO_BANK_MATCH.trx_amount);
  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.csl_match_correction_type = '||
			CE_AUTO_BANK_MATCH.csl_match_correction_type);
  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.csl_trx_type = '||
			CE_AUTO_BANK_MATCH.csl_trx_type);
  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.trx_currency_type = '||
			CE_AUTO_BANK_MATCH.trx_currency_type);
  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.calc_csl_amount = '||
			CE_AUTO_BANK_MATCH.calc_csl_amount);

  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.csl_clearing_trx_type = '||
			CE_AUTO_BANK_MATCH.csl_clearing_trx_type);

  success := TRUE;
  IF (CE_AUTO_BANK_MATCH.csl_match_type = 'JE_LINE') THEN
    NULL;
  ELSIF ((CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'OI') AND
           (CE_AUTO_BANK_REC.G_open_interface_matching_code = 'D')) THEN
    CE_AUTO_BANK_MATCH.trx_charges_amount :=
	CE_AUTO_BANK_MATCH.csl_charges_amount;
  ELSIF (CE_AUTO_BANK_MATCH.tolerance_amount = 0) THEN
    NULL;
  ELSE
    IF (CE_AUTO_BANK_MATCH.trx_currency_type IN ('FUNCTIONAL', 'BANK')) THEN
    -- added 'PGROUP'
      IF (CE_AUTO_BANK_MATCH.csl_match_type IN  ('PAYMENT','PBATCH','PGROUP') OR
	  CE_AUTO_BANK_MATCH.trx_match_type = 'PAYMENT') THEN
	if (CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_CREDIT') then
       	   clearing_sign := -1;
    	else
          clearing_sign := 1;
    	end if;
        difference_amount := CE_AUTO_BANK_MATCH.calc_csl_amount * clearing_sign
				- CE_AUTO_BANK_MATCH.trx_amount;

        IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type = 'CASHFLOW') THEN
          IF (CE_AUTO_BANK_REC.G_ce_differences_account = 'CHARGES') THEN
            CE_AUTO_BANK_MATCH.trx_charges_amount := difference_amount;
	  ELSE
	    CE_AUTO_BANK_MATCH.trx_charges_amount := CE_AUTO_BANK_MATCH.csl_charges_amount;
	    CE_AUTO_BANK_MATCH.trx_errors_amount  := difference_amount - CE_AUTO_BANK_MATCH.csl_charges_amount;
	  END IF;

	ELSE
          IF (CE_AUTO_BANK_REC.G_differences_account = 'CHARGES') THEN
            CE_AUTO_BANK_MATCH.trx_charges_amount := difference_amount;
	  ELSE
	    CE_AUTO_BANK_MATCH.trx_charges_amount := CE_AUTO_BANK_MATCH.csl_charges_amount;
	    CE_AUTO_BANK_MATCH.trx_errors_amount  := difference_amount - CE_AUTO_BANK_MATCH.csl_charges_amount;
	  END IF;
	END IF;

      ELSE  -- cash/receipt
	if (CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_DEBIT' AND
	    CE_AUTO_BANK_MATCH.csl_match_correction_type = 'ADJUSTMENT') then
           clearing_sign := -1;
       	else
           clearing_sign := 1;
       	end if;
        difference_amount := CE_AUTO_BANK_MATCH.trx_amount
				- CE_AUTO_BANK_MATCH.calc_csl_amount * clearing_sign;

        IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type = 'CASHFLOW') THEN
          IF (CE_AUTO_BANK_REC.G_ce_differences_account = 'CHARGES') THEN
	    CE_AUTO_BANK_MATCH.trx_charges_amount := difference_amount;
	  ELSE
	    CE_AUTO_BANK_MATCH.trx_charges_amount := CE_AUTO_BANK_MATCH.csl_charges_amount;
	    CE_AUTO_BANK_MATCH.trx_errors_amount  := difference_amount - CE_AUTO_BANK_MATCH.csl_charges_amount;
	  END IF;
	ELSE
	  CE_AUTO_BANK_MATCH.trx_charges_amount := difference_amount;
        END IF;
      END IF;
    ELSIF (CE_AUTO_BANK_MATCH.trx_currency_type = 'FOREIGN') THEN
      calc_foreign_clearing_amounts(success);
    END IF;
  END IF;
  --
  -- Zero equals to NULL
  --
  IF (CE_AUTO_BANK_MATCH.trx_errors_amount = 0) THEN
    CE_AUTO_BANK_MATCH.trx_errors_amount := NULL;
  END IF;
  IF (CE_AUTO_BANK_MATCH.trx_charges_amount = 0) THEN
    CE_AUTO_BANK_MATCH.trx_charges_amount := NULL;
  END IF;
  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.trx_charges_amount = '||
                        CE_AUTO_BANK_MATCH.trx_charges_amount);

  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.trx_errors_amount = '||
                        CE_AUTO_BANK_MATCH.trx_errors_amount);

  cep_standard.debug('<<CE_AUTO_BANK_CLEAR.calculate_clearing_amounts');
  RETURN (success);
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_AUTO_BANK_CLEAR.calculate_clearing_amounts' );
    RAISE;
END calculate_clearing_amounts;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	trx_remain							|
|  DESCRIPTION								|
|
|  CALLS								|
|	Manual unReconciliation only 					|
|	 call from form - RECONCILED_PAY_EFT.UNRECON_ALL_EFT            |
 --------------------------------------------------------------------- */
FUNCTION trx_remain( 	stmt_ln_list	VARCHAR2,
			trx_id_list	VARCHAR2) RETURN NUMBER IS
  tmp_query		varchar2(1000) := null;
  count_pay_eft1		NUMBER;
  cursor_id		INTEGER;
  exec_id		INTEGER;

BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_CLEAR.trx_remain' );
  tmp_query := 'select count(*)
			from ce_801_eft_reconciled_v
			where clearing_trx_type = ''PAY_EFT''
			and to_char(statement_line_id) in (' || stmt_ln_list ||')
			and to_char(trx_id) not in (' || trx_id_list || ')';

       cep_standard.debug('created tmp_query = '|| tmp_query);
       cep_standard.debug('open_cursor');

  cursor_id := DBMS_SQL.open_cursor;
  cep_standard.debug('Cursor opened sucessfully with cursor_id: '||
	to_char(cursor_id));

      cep_standard.debug('parse sql');
   --DBMS_SQL.Parse(cursor_id, tmp_query, DBMS_SQL.native);
   DBMS_SQL.Parse(cursor_id, tmp_query, DBMS_SQL.v7);

      cep_standard.debug('define column');
   DBMS_SQL.Define_Column(cursor_id, 1, count_pay_eft1);

      cep_standard.debug('execute cursor');
   exec_id := dbms_sql.execute(cursor_id);

      cep_standard.debug('column_value');

   IF (DBMS_SQL.FETCH_ROWS(cursor_id) >0 ) THEN
     DBMS_SQL.COLUMN_VALUE(cursor_id, 1, count_pay_eft1);
   END IF;

     cep_standard.debug('count_pay_eft1 = '|| count_pay_eft1);
     cep_standard.debug('<<CE_AUTO_BANK_CLEAR.trx_remain' );

  return count_pay_eft1;

EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION - OTHERS: CE_AUTO_BANK_CLEAR.trx_remain' );
	IF DBMS_SQL.IS_OPEN(cursor_id) THEN
	  DBMS_SQL.CLOSE_CURSOR(cursor_id);
	  cep_standard.debug('Cursor Closed');
	END IF;
    RAISE;
END trx_remain;


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       reconcile_stmt                                                  |
|  CALLED BY                                                            |
|       reconcile_process                                               |
 --------------------------------------------------------------------- */
PROCEDURE reconcile_stmt(passin_mode                    VARCHAR2,
                         tx_type                        VARCHAR2,
                         trx_id                         NUMBER,
                         trx_status                     VARCHAR2,
                         receipt_type                   VARCHAR2,
                         exchange_rate_type             VARCHAR2,
                         exchange_date                  DATE,
                         exchange_rate                  NUMBER,
                         amount_cleared                 NUMBER,
                         charges_amount                 NUMBER,
                         errors_amount                  NUMBER,
                         gl_date                        DATE,
			 value_date			DATE,
                         cleared_date                   DATE,
                         ar_cash_receipt_id             NUMBER,
                         X_bank_currency                VARCHAR2,
                         X_statement_line_id            IN OUT NOCOPY NUMBER,
                         X_statement_line_type          VARCHAR2,
                         reference_status               VARCHAR2,
                         trx_currency_type              VARCHAR2,
                         auto_reconciled_flag           VARCHAR2,
                         X_statement_header_id          IN OUT NOCOPY NUMBER,
                         X_effective_date               DATE DEFAULT NULL,
                         X_float_handling_flag          VARCHAR2 DEFAULT NULL,
                         X_currency_code                VARCHAR2 default NULL,
                         X_bank_trx_number              VARCHAR2 default NULL,
                         X_reversed_receipt_flag        VARCHAR2) IS
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_CLEAR.reconcile_stmt');
  CE_AUTO_BANK_CLEAR1.reconcile_stmt(
			 passin_mode,
                         tx_type,
                         trx_id,
                         trx_status,
                         receipt_type,
                         exchange_rate_type,
                         exchange_date,
                         exchange_rate,
                         amount_cleared,
                         charges_amount,
                         errors_amount,
                         gl_date,
			 value_date,
                         cleared_date,
                         ar_cash_receipt_id,
                         X_bank_currency,
                         X_statement_line_id,
                         X_statement_line_type,
                         reference_status,
                         trx_currency_type,
                         auto_reconciled_flag,
                         X_statement_header_id,
                         X_effective_date,
                         X_float_handling_flag,
			 X_currency_code,
			 X_bank_trx_number,
                         X_reversed_receipt_flag);
  cep_standard.debug('<<CE_AUTO_BANK_CLEAR.reconcile_stmt');
END reconcile_stmt;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       reconcile_trx                                              	|
|  CALLED BY                                                            |
|       reconcile_process                                               |
 --------------------------------------------------------------------- */
PROCEDURE reconcile_trx( passin_mode       	   	VARCHAR2,
                	 tx_type                        VARCHAR2,
                	 trx_id                         NUMBER,
                	 trx_status                     VARCHAR2,
                	 receipt_type                   VARCHAR2,
                	 exchange_rate_type             VARCHAR2,
                	 exchange_date                  DATE,
                	 exchange_rate                  NUMBER,
                	 amount_cleared                 NUMBER,
                	 charges_amount                 NUMBER,
                	 errors_amount                  NUMBER,
                	 gl_date                        DATE,
			 value_date			DATE,
			 cleared_date			DATE,
                	 ar_cash_receipt_id             NUMBER,
                	 X_bank_currency               	VARCHAR2,
                	 X_statement_line_id 	        IN OUT NOCOPY NUMBER,
			 X_statement_line_type		VARCHAR2,
                	 reference_status               VARCHAR2,
			 trx_currency_type		VARCHAR2,
                	 auto_reconciled_flag		VARCHAR2,
                	 X_statement_header_id          IN OUT NOCOPY NUMBER,
                	 X_statement_header_date        DATE,
                	 X_bank_trx_number              VARCHAR2,
                	 X_currency_code                VARCHAR2,
                	 X_original_amount              NUMBER,
                	 X_effective_date		DATE,
                	 X_float_handling_flag		VARCHAR2,
                         X_reversed_receipt_flag        VARCHAR2,
	                 X_org_id		       	NUMBER 		DEFAULT NULL,
        	         X_legal_entity_id       	NUMBER 		DEFAULT NULL) IS
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_CLEAR.reconcile_trx');
  CE_AUTO_BANK_CLEAR1.reconcile_trx(
			 passin_mode,
                         tx_type,
                         trx_id,
                         trx_status,
                         receipt_type,
                         exchange_rate_type,
                         exchange_date,
                         exchange_rate,
                         amount_cleared,
                         charges_amount,
                         errors_amount,
                         gl_date,
			 value_date,
                         cleared_date,
                         ar_cash_receipt_id,
                         X_bank_currency,
                         X_statement_line_id,
                         X_statement_line_type,
                         reference_status,
                         trx_currency_type,
                         auto_reconciled_flag,
                         X_statement_header_id,
                         X_statement_header_date,
                         X_bank_trx_number,
                         X_currency_code,
                         X_original_amount,
                         X_effective_date,
                         X_float_handling_flag,
                         X_reversed_receipt_flag,
	                 X_org_id,
        	         X_legal_entity_id);
  cep_standard.debug('<<CE_AUTO_BANK_CLEAR.reconcile_trx');
END reconcile_trx;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       reconcile_pay_eft                                              	|
|  CALLED BY                                                            |
|       reconcile_process                                               |
 --------------------------------------------------------------------- */
PROCEDURE reconcile_pay_eft( passin_mode       	   	VARCHAR2,
                	 tx_type                        VARCHAR2,
                	 trx_count			NUMBER,
                	 trx_group                      VARCHAR2,
                	 cleared_trx_type               VARCHAR2,
			 cleared_date			DATE,
                	 X_bank_currency               	VARCHAR2,
                	 X_statement_line_id 	        NUMBER,
			 X_statement_line_type		VARCHAR2,
			 trx_currency_type		VARCHAR2,
                	 auto_reconciled_flag		VARCHAR2,
                	 X_statement_header_id          NUMBER,
                	 X_bank_trx_number              VARCHAR2,
                	 X_bank_account_id		NUMBER,
                	 X_payroll_payment_format	VARCHAR2,
                	 X_effective_date		DATE,
                	 X_float_handling_flag		VARCHAR2) IS
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_CLEAR.reconcile_pay_eft');
  CE_AUTO_BANK_CLEAR1.reconcile_pay_eft(
			 passin_mode,
                         tx_type,
			 trx_count,
		 	 trx_group,
			 cleared_trx_type,
                         cleared_date,
                         X_bank_currency,
                         X_statement_line_id,
                         X_statement_line_type,
                         trx_currency_type,
                         auto_reconciled_flag,
                         X_statement_header_id,
                         X_bank_trx_number,
                         X_bank_account_id,
                         X_payroll_payment_format,
			 X_effective_date,
                         X_float_handling_flag);
  cep_standard.debug('<<CE_AUTO_BANK_CLEAR.reconcile_pay_eft');
END reconcile_pay_eft;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	unclear_process							|
|  DESCRIPTION								|
|	Unclear and unreconcile the reconcilied statement line.		|
|  CALLED BY								|
|	This piece of code is called only from Manual Reconciliation	|
 --------------------------------------------------------------------- */
PROCEDURE unclear_process (	passin_mode			VARCHAR2,
				X_header_or_line		VARCHAR2,
			  	tx_type				VARCHAR2,
				clearing_trx_type		VARCHAR2,
				batch_id			NUMBER,
				trx_id				NUMBER,
				cash_receipt_id			NUMBER,
				trx_date			DATE,
				gl_date				DATE,
				cash_receipt_history_id 	IN OUT NOCOPY	NUMBER,
				stmt_line_id			NUMBER,
				status				VARCHAR2,
				cleared_date                    DATE,
                                transaction_amount              NUMBER,
                                error_amount                    NUMBER,
                                charge_amount                   NUMBER,
                                currency_code                   VARCHAR2,
                                xtype                           VARCHAR2,
                                xdate                           DATE,
                                xrate                           NUMBER,
                                org_id                          NUMBER,
                                legal_entity_id                 NUMBER ) IS
BEGIN
	CE_AUTO_BANK_CLEAR1.unclear_process(
				passin_mode		,
				X_header_or_line	,
			  	tx_type			,
				clearing_trx_type	,
				batch_id		,
				trx_id			,
				cash_receipt_id		,
				trx_date		,
				gl_date			,
				cash_receipt_history_id ,
				stmt_line_id		,
				status			,
				cleared_date		,
				transaction_amount	,
				error_amount		,
				charge_amount		,
				currency_code		,
				xtype			,
				xdate			,
				xrate			,
				org_id 			,
				legal_entity_id);

END unclear_process;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	reconcile_process						|
|  DESCRIPTION								|
|	Clear and reconcile the matched statement line.			|
|  CALLS								|
|	calculate_clearing_amounts
|  CALLED BY								|
|	CE_AUTO_BANK_MATCH.match_process 				|
 --------------------------------------------------------------------- */
PROCEDURE reconcile_process IS
  encoded_message		VARCHAR2(255);
  message_name			VARCHAR2(50);
  app_short_name		VARCHAR2(30);
  d_statement_header_id		CE_STATEMENT_HEADERS.statement_header_id%TYPE;
  misc_number			AR_CASH_RECEIPTS_ALL.receipt_number%TYPE;
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_CLEAR.reconcile_process');
  --
  -- Statement lines
  --
  IF (CE_AUTO_BANK_MATCH.csl_match_type = 'MISC' AND
      CE_AUTO_BANK_MATCH.csl_match_correction_type IN
      ('REVERSAL', 'ADJUSTMENT')) THEN
    IF (calculate_clearing_amounts) THEN
      reconcile_stmt(
	passin_mode 		=> 'AUTO',
	tx_type 		=> CE_AUTO_BANK_MATCH.csl_match_type,
	trx_id			=> CE_AUTO_BANK_MATCH.trx_id,
	trx_status		=> CE_AUTO_BANK_MATCH.trx_status,
	receipt_type		=> CE_AUTO_BANK_MATCH.csl_reconcile_flag,
	exchange_rate_type      => CE_AUTO_BANK_MATCH.csl_exchange_rate_type,
	exchange_date	  => to_date(to_char(CE_AUTO_BANK_MATCH.csl_exchange_rate_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
	exchange_rate		=> CE_AUTO_BANK_MATCH.csl_exchange_rate,
	amount_cleared		=> CE_AUTO_BANK_MATCH.calc_csl_amount,
	charges_amount		=> CE_AUTO_BANK_MATCH.trx_charges_amount,
	errors_amount		=> CE_AUTO_BANK_MATCH.trx_errors_amount,
	gl_date			=> to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
	value_date		=> to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
	cleared_date		=> to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
	ar_cash_receipt_id	=> CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
	X_bank_currency	        => CE_AUTO_BANK_MATCH.aba_bank_currency,
	X_statement_line_id	=> CE_AUTO_BANK_MATCH.csl_statement_line_id,
	X_statement_line_type	=> CE_AUTO_BANK_MATCH.csl_line_trx_type,
	reference_status	=> NULL,
	trx_currency_type	=> CE_AUTO_BANK_MATCH.trx_currency_type,
	auto_reconciled_flag   	=> 'Y',
	X_statement_header_id 	=> d_statement_header_id,
	X_effective_date	=> CE_AUTO_BANK_MATCH.csl_effective_date,
	X_float_handling_flag	=> CE_AUTO_BANK_REC.G_float_handling_flag,
        X_currency_code         => CE_AUTO_BANK_MATCH.trx_currency_code,
        X_reversed_receipt_flag => CE_AUTO_BANK_MATCH.reversed_receipt_flag);
	CE_AUTO_BANK_MATCH.reconcile_to_statement_flag := 'Y';
	if (CE_AUTO_BANK_MATCH.csl_match_correction_type = 'REVERSAL') then
      	   CE_AUTO_BANK_CLEAR.update_line_status(CE_AUTO_BANK_MATCH.trx_id,
		'RECONCILED');
	else	/* ADJUSTMENT */
      	   CE_AUTO_BANK_CLEAR.update_line_status(CE_AUTO_BANK_MATCH.trx_id2,
		'RECONCILED');
	end if;
	CE_AUTO_BANK_MATCH.reconcile_to_statement_flag := NULL;
        CE_AUTO_BANK_CLEAR.update_line_status(
	   CE_AUTO_BANK_MATCH.csl_statement_line_id,'RECONCILED');
    END IF;
  --
  -- Transaction
  --
  ELSIF (CE_AUTO_BANK_MATCH.csl_match_type IN
	('PAY_LINE', 'JE_LINE','PAYMENT','CASH','MISC','RECEIPT')) THEN
    IF (calculate_clearing_amounts) THEN
      reconcile_trx(
	passin_mode 		=> 'AUTO',
	tx_type 		=> CE_AUTO_BANK_MATCH.csl_match_type,
	trx_id			=> CE_AUTO_BANK_MATCH.trx_id,
	trx_status		=> CE_AUTO_BANK_MATCH.trx_status,
	receipt_type		=> CE_AUTO_BANK_MATCH.csl_reconcile_flag,
	exchange_rate_type      => CE_AUTO_BANK_MATCH.csl_exchange_rate_type,
	exchange_date	  => to_date(to_char(CE_AUTO_BANK_MATCH.csl_exchange_rate_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
	exchange_rate		=> CE_AUTO_BANK_MATCH.csl_exchange_rate,
	amount_cleared		=> CE_AUTO_BANK_MATCH.calc_csl_amount,
	charges_amount		=> CE_AUTO_BANK_MATCH.trx_charges_amount,
	errors_amount		=> CE_AUTO_BANK_MATCH.trx_errors_amount,
	gl_date			=> to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
	value_date		=> to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
	cleared_date		=> to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
	ar_cash_receipt_id	=> CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
	X_bank_currency	        => CE_AUTO_BANK_MATCH.aba_bank_currency,
	X_statement_line_id	=> CE_AUTO_BANK_MATCH.csl_statement_line_id,
	X_statement_line_type	=> CE_AUTO_BANK_MATCH.csl_line_trx_type,
	reference_status	=> NULL,
	trx_currency_type	=> CE_AUTO_BANK_MATCH.trx_currency_type,
        X_currency_code         => CE_AUTO_BANK_MATCH.trx_currency_code,
	auto_reconciled_flag   	=> 'Y',
	X_statement_header_id 	=> d_statement_header_id,
	X_effective_date	=> CE_AUTO_BANK_MATCH.csl_effective_date,
	X_float_handling_flag	=> CE_AUTO_BANK_REC.G_float_handling_flag,
        X_reversed_receipt_flag => CE_AUTO_BANK_MATCH.reversed_receipt_flag);
      CE_AUTO_BANK_CLEAR.update_line_status(CE_AUTO_BANK_MATCH.csl_statement_line_id,'RECONCILED');
    END IF;
  --
  -- Payroll EFT Transaction
  --
  ELSIF (CE_AUTO_BANK_MATCH.csl_match_type = 'PAY_EFT') THEN
    IF (calculate_clearing_amounts) THEN
      reconcile_pay_eft(
	passin_mode 		=> 'AUTO',
	tx_type 		=> CE_AUTO_BANK_MATCH.csl_match_type, --PAY_EFT
	trx_count		=> CE_AUTO_BANK_MATCH.trx_count,
	trx_group		=> CE_AUTO_BANK_MATCH.trx_group,
	cleared_trx_type	=> CE_AUTO_BANK_MATCH.csl_reconcile_flag,
	cleared_date		=> to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
	X_bank_currency	        => CE_AUTO_BANK_MATCH.aba_bank_currency,
	X_statement_line_id	=> CE_AUTO_BANK_MATCH.csl_statement_line_id,
	X_statement_line_type	=> CE_AUTO_BANK_MATCH.csl_line_trx_type,
	trx_currency_type	=> CE_AUTO_BANK_MATCH.trx_currency_type,
	auto_reconciled_flag   	=> 'Y',
	X_statement_header_id 	=> d_statement_header_id,
        X_bank_trx_number	=> CE_AUTO_BANK_MATCH.csl_bank_trx_number,
        X_bank_account_id	=> CE_AUTO_BANK_MATCH.csh_bank_account_id,
        X_payroll_payment_format => CE_AUTO_BANK_MATCH.csl_payroll_payment_format,
	X_effective_date	=> CE_AUTO_BANK_MATCH.csl_effective_date,
	X_float_handling_flag	=> CE_AUTO_BANK_REC.G_float_handling_flag);
      CE_AUTO_BANK_CLEAR.update_line_status(CE_AUTO_BANK_MATCH.csl_statement_line_id,'RECONCILED');
    END IF;
  --
  -- Payment Batch
  --
  ELSIF (CE_AUTO_BANK_MATCH.csl_match_type = 'PBATCH') THEN
    IF (calculate_clearing_amounts) THEN
        reconcile_pbatch(
            passin_mode           => 'AUTO',
            pbatch_id             => CE_AUTO_BANK_MATCH.trx_id,
            statement_line_id     => CE_AUTO_BANK_MATCH.csl_statement_line_id,
            gl_date               => TO_DATE(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD' ),'YYYY/MM/DD'),
            value_date            => CE_AUTO_BANK_MATCH.csl_effective_date,
            cleared_date          => TO_DATE(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
            amount_to_clear    => CE_AUTO_BANK_MATCH.calc_csl_amount,
            errors_amount         => CE_AUTO_BANK_MATCH.trx_errors_amount,
            charges_amount        => CE_AUTO_BANK_MATCH.trx_charges_amount,
            prorate_amount        => CE_AUTO_BANK_MATCH.trx_prorate_amount,
            exchange_rate_type    => CE_AUTO_BANK_MATCH.csl_exchange_rate_type,
            exchange_rate_date    => to_date(to_char(CE_AUTO_BANK_MATCH.csl_exchange_rate_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
            exchange_rate         => CE_AUTO_BANK_MATCH.csl_exchange_rate,
            trx_currency_type     => CE_AUTO_BANK_MATCH.trx_currency_type,
            X_statement_header_id => d_statement_header_id,
            X_currency_code       => CE_AUTO_BANK_MATCH.trx_currency_code,
            X_effective_date      => CE_AUTO_BANK_MATCH.csl_effective_date,
            X_float_handling_flag => CE_AUTO_BANK_REC.G_float_handling_flag,
            X_bank_currency_code  => CE_AUTO_BANK_MATCH.aba_bank_currency);

        CE_AUTO_BANK_CLEAR.update_line_status(CE_AUTO_BANK_MATCH.csl_statement_line_id,'RECONCILED');
    END IF;
  --
  -- Payment Group
  --
  ELSIF (CE_AUTO_BANK_MATCH.csl_match_type = 'PGROUP') THEN
    IF (calculate_clearing_amounts) THEN
        reconcile_pbatch(
            passin_mode             => 'AUTO',
            pbatch_id               => CE_AUTO_BANK_MATCH.trx_id,
            statement_line_id       => CE_AUTO_BANK_MATCH.csl_statement_line_id,
            gl_date                 => TO_DATE(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD' ),'YYYY/MM/DD'),
            value_date              => CE_AUTO_BANK_MATCH.csl_effective_date,
            cleared_date            => TO_DATE(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
            amount_to_clear         => CE_AUTO_BANK_MATCH.calc_csl_amount,
            errors_amount           => CE_AUTO_BANK_MATCH.trx_errors_amount,
            charges_amount          => CE_AUTO_BANK_MATCH.trx_charges_amount,
            prorate_amount          => CE_AUTO_BANK_MATCH.trx_prorate_amount,
            exchange_rate_type	    => CE_AUTO_BANK_MATCH.csl_exchange_rate_type,
            exchange_rate_date      => to_date(to_char(CE_AUTO_BANK_MATCH.csl_exchange_rate_date,
                                                'YYYY/MM/DD'),'YYYY/MM/DD'),
            exchange_rate           => CE_AUTO_BANK_MATCH.csl_exchange_rate,
            trx_currency_type       => CE_AUTO_BANK_MATCH.trx_currency_type,
            X_statement_header_id   => d_statement_header_id,
            X_currency_code         => CE_AUTO_BANK_MATCH.trx_currency_code,
            X_effective_date        => CE_AUTO_BANK_MATCH.csl_effective_date,
            X_float_handling_flag   => CE_AUTO_BANK_REC.G_float_handling_flag,
            X_bank_currency_code    => CE_AUTO_BANK_MATCH.aba_bank_currency,
            pgroup_id               => CE_AUTO_BANK_MATCH.LOGICAL_GROUP_REFERENCE);
        CE_AUTO_BANK_CLEAR.update_line_status(CE_AUTO_BANK_MATCH.csl_statement_line_id,'RECONCILED');
    END IF;
  --
  -- Remittance Batch
  --
  ELSIF (CE_AUTO_BANK_MATCH.csl_match_type = 'RBATCH') THEN
    IF (calculate_clearing_amounts) THEN
      misc_number := nvl(CE_AUTO_BANK_MATCH.csl_bank_trx_number,
	  CE_AUTO_BANK_MATCH.csh_statement_number||'/'
          || CE_AUTO_BANK_MATCH.csl_line_number);
      reconcile_rbatch(
	passin_mode	   	=> 'AUTO',
	rbatch_id	   	=> CE_AUTO_BANK_MATCH.trx_id,
    	X_statement_line_id  	=> CE_AUTO_BANK_MATCH.csl_statement_line_id,
	gl_date		   	=> CE_AUTO_BANK_REC.G_gl_date,
	value_date		=> CE_AUTO_BANK_MATCH.csl_effective_date,
	bank_currency	   	=> CE_AUTO_BANK_MATCH.aba_bank_currency,
	exchange_rate_type 	=> CE_AUTO_BANK_MATCH.csl_exchange_rate_type,
	exchange_rate	   	=> CE_AUTO_BANK_MATCH.csl_exchange_rate,
	exchange_rate_date 	=> CE_AUTO_BANK_MATCH.csl_exchange_rate_date,
	trx_currency_type  	=> CE_AUTO_BANK_MATCH.trx_currency_type,
	module		   	=> 'CE_AUTO_BANK_CLEAR',
      	X_TRX_NUMBER	   	=> misc_number,
	X_TRX_DATE		=> to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
	X_DEPOSIT_DATE		=> to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
	X_AMOUNT		=> -CE_AUTO_BANK_MATCH.trx_charges_amount,
	X_FOREIGN_DIFF_AMT	=> CE_AUTO_BANK_MATCH.trx_prorate_amount,
	X_SET_OF_BOOKS_ID	=> CE_AUTO_BANK_REC.G_set_of_books_id,
	X_MISC_CURRENCY_CODE 	=> CE_AUTO_BANK_MATCH.aba_bank_currency,
	X_RECEIPT_METHOD_ID	=> CE_AUTO_BANK_REC.G_payment_method_id,
	X_BANK_ACCOUNT_ID	=> CE_AUTO_BANK_MATCH.csh_bank_account_id,
	X_ACTIVITY_TYPE_ID	=> CE_AUTO_BANK_REC.G_receivables_trx_id,
	X_COMMENTS		=> 'Created by Auto Bank Rec',
	X_REFERENCE_TYPE	=> 'REMITTANCE BATCH',
	X_CLEAR_CURRENCY_CODE	=> CE_AUTO_BANK_MATCH.aba_bank_currency,
	X_TAX_ID		=> NULL,
        X_TAX_RATE		=> NULL,
	X_CR_VAT_TAX_ID		=> CE_AUTO_BANK_REC.G_cr_vat_tax_code,
	X_DR_VAT_TAX_ID		=> CE_AUTO_BANK_REC.G_dr_vat_tax_code,
	X_statement_header_id   => d_statement_header_id,
	X_effective_date	=> CE_AUTO_BANK_MATCH.csl_effective_date,
	X_float_handling_flag	=> CE_AUTO_BANK_REC.G_float_handling_flag);
      CE_AUTO_BANK_CLEAR.update_line_status(CE_AUTO_BANK_MATCH.csl_statement_line_id,'RECONCILED');
    END IF;
  END IF;
  cep_standard.debug('<<CE_AUTO_BANK_CLEAR.reconcile_process');
EXCEPTION
  WHEN APP_EXCEPTION.application_exception THEN
    encoded_message := FND_MESSAGE.GET_ENCODED;
    IF (encoded_message IS NOT NULL) THEN
      FND_MESSAGE.parse_encoded(encoded_message,app_short_name,message_name);
    END IF;
    IF (message_name IS NULL) THEN
      app_short_name := 'CE';
      message_name   := 'OTHER_APP_ERROR';
    END IF;
    CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id, message_name, app_short_name);
    --
    -- get rid of any lines that might have been inserted into
    -- the reconciliation tables. This happens when lines per commit
    -- is not zero
    --
    --DELETE FROM ce_statement_reconciliations
    DELETE FROM ce_statement_reconcils_all
    WHERE statement_line_id = CE_AUTO_BANK_MATCH.csl_statement_line_id;
  WHEN OTHERS THEN
   cep_standard.debug('EXCEPTION: CE_AUTO_BANK_CLEAR.reconcile_process OTHERS');
   /*
    IF (rbatch_cursor%ISOPEN) THEN
      CLOSE rbatch_cursor;
    END IF;
    IF (pbatch_cursor%ISOPEN) THEN
      CLOSE pbatch_cursor;
    END IF;
    */
    RAISE;
END reconcile_process;

END CE_AUTO_BANK_CLEAR;

/
