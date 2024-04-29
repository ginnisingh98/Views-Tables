--------------------------------------------------------
--  DDL for Package Body CE_AUTO_BANK_CLEAR1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_AUTO_BANK_CLEAR1" AS
/* $Header: ceabrc1b.pls 120.44.12010000.5 2009/11/10 03:13:21 vnetan ship $								*/
 -- l_DEBUG varchar2(1) := NVL(FND_PROFILE.value('CE_DEBUG'), 'N');
  l_DEBUG varchar2(1) := 'Y';

  CURSOR rbatch_cursor (rbatch_id       NUMBER ) IS
    SELECT a.trx_id                     cash_receipt_history_id,
           a.cash_receipt_id            cash_receipt_id,
           a.trx_type                   trx_type,
           a.trx_date                   trx_date,
           a.status                     status,
           a.bank_account_amount        ba_amount,
           a.amount                     amount,
 	   --a.receipt_gl_date		receipt_gl_date,
	   a.gl_date			receipt_gl_date,
           a.exchange_rate_date         exchange_rate_date,
           a.exchange_rate_type         exchange_rate_type,
	   a.seq_id			seq_id
    --FROM   ce_222_txn_for_batch_v a
    FROM   ce_available_transactions_tmp a
    WHERE  a.batch_id = rbatch_id
    AND    nvl(a.status, 'REMITTED') <> 'REVERSED'
    AND    a.application_id = 222
    AND    NVL(a.reconciled_status_flag, 'N') = 'N';

  -- Fix bug 5637589 for manual remittance batch reconciliation
  CURSOR manual_rbatch_cursor (rbatch_id       NUMBER ) IS
    SELECT a.trx_id                     cash_receipt_history_id,
           a.cash_receipt_id            cash_receipt_id,
           a.trx_type                   trx_type,
           a.trx_date                   trx_date,
           a.status                     status,
           a.bank_account_amount        ba_amount,
           a.amount                     amount,
 	   a.receipt_gl_date		receipt_gl_date,
           a.exchange_rate_date         exchange_rate_date,
           a.exchange_rate_type         exchange_rate_type,
           a.org_id
    FROM   ce_222_txn_for_batch_v a
    --FROM   ce_available_transactions_tmp a
    WHERE  a.batch_id = rbatch_id
    AND    nvl(a.status, 'REMITTED') <> 'REVERSED';

  -- BUG 4435028 added CE trx to payment batches
  -- Bug 7506336 added NVL to the logical_group_reference clause
  CURSOR pbatch_cursor (pbatch_id          NUMBER,
                        pgroup_id varchar2) IS -- FOR SEPA ER 6700007
    SELECT a.trx_id			check_id,
	   a.status			status_lookup_code,
	   'PAYMENT'			batch_trx_type,
	   a.cash_receipt_id		batch_app_id,
	   a.seq_id			seq_id
    --FROM   ce_200_transactions_v a
    FROM   ce_available_transactions_tmp a
    WHERE  a.batch_id =  pbatch_id
    AND    nvl(a.status, 'NEGOTIABLE') <> 'VOIDED'
    AND    a.application_id = 200
    AND    NVL(a.reconciled_status_flag, 'N') = 'N'
    AND    EXISTS ( SELECT 1
                    FROM iby_payments_all IPA ,AP_CHECKS_ALL ACA
		    WHERE ACA.CHECK_ID   =a.trx_id
		      AND ACA.PAYMENT_INSTRUCTION_ID  = pbatch_id
		      AND IPA.PAYMENT_INSTRUCTION_ID (+)  = pbatch_id -- Bug # 8353600 Added Outer Join (+)
		      AND IPA.PAYMENT_ID (+) = ACA.PAYMENT_ID -- Bug # 8353600 Added Outer Join (+)
		      AND NVL(IPA.LOGICAL_GROUP_REFERENCE,'N') = NVL(pgroup_id,NVL(IPA.LOGICAL_GROUP_REFERENCE,'N')))
    UNION ALL
    SELECT a.trx_id,
	   a.status,
	   'CASHFLOW',
	   673,
	   a.seq_id
    --FROM   ce_260_cf_transactions_v a
    FROM   ce_available_transactions_tmp a
    WHERE  a.batch_id =  pbatch_id
    AND    nvl(a.status, 'CANCELED') <> 'CANCELED'
    AND    a.application_id = 261
    AND    NVL(a.reconciled_status_flag, 'N') = 'N'
    AND    pgroup_id is null ;         -- FOR SEPA ER 6700007

  -- BUG 5350073 use for manual reconcilation of IBY batches
    -- Bug 7506336 added NVL to the logical_group_reference clause
  CURSOR manual_pbatch_cursor (pbatch_id  NUMBER,pgroup_id  VARCHAR2) IS -- FOR SEPA ER 6700007
    SELECT a.trx_id			check_id,
	   a.status			status_lookup_code,
	   'PAYMENT'			batch_trx_type,
	   a.cash_receipt_id		batch_app_id,
	   a.org_id			org_id,
	   a.legal_entity_id		legal_entity_id
    FROM   ce_200_transactions_v a
    --FROM   ce_available_transactions_tmp a
    WHERE  a.batch_id =  pbatch_id
    AND    nvl(a.status, 'NEGOTIABLE') <> 'VOIDED'
  -- FOR SEPA ER 6700007
    AND    EXISTS ( SELECT 1
                    FROM iby_payments_all IPA ,AP_CHECKS_ALL ACA
		    WHERE ACA.CHECK_ID   =a.trx_id
		      AND ACA.PAYMENT_INSTRUCTION_ID  = pbatch_id
		      AND IPA.PAYMENT_INSTRUCTION_ID (+) = pbatch_id -- Bug # 8353600 Added Outer Join (+)
		      AND IPA.PAYMENT_ID (+) = ACA.PAYMENT_ID -- Bug # 8353600 Added Outer Join (+)
		      AND NVL(IPA.LOGICAL_GROUP_REFERENCE,'N') = NVL(pgroup_id,NVL(IPA.LOGICAL_GROUP_REFERENCE,'N')))
    --AND    a.application_id = 200
    --AND    NVL(a.reconciled_status_flag, 'N') = 'N'
    UNION ALL
    SELECT a.trx_id,
	   a.status,
	   'CASHFLOW',
	   673,
	   a.org_id,
	   a.legal_entity_id
    FROM   ce_260_cf_transactions_v a
    --FROM   ce_available_transactions_tmp a
    WHERE  a.batch_id =  pbatch_id
    AND    nvl(a.status, 'CANCELED') <> 'CANCELED'
    AND    pgroup_id is null ;         -- FOR SEPA ER 6700007
    --AND    a.application_id = 261;
    --AND    NVL(a.reconciled_status_flag, 'N') = 'N';

  CURSOR C_STATEMENT_LINE_SEQ IS SELECT ce_statement_lines_s.nextval from sys.dual;

FUNCTION body_revision RETURN VARCHAR2 IS
BEGIN

  RETURN '$Revision: 120.44.12010000.5 $';

END body_revision;

FUNCTION spec_revision RETURN VARCHAR2 IS
BEGIN

  RETURN G_spec_revision;

END spec_revision;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       validate_effective_date 					|
|  CALLED BY                                                            |
|       reconcile_trx, reconcile_stmt, reconcile_pbatch, reoncile_rbatch|
 --------------------------------------------------------------------- */

PROCEDURE validate_effective_date(	passin_mode		VARCHAR2,
					X_effective_date	DATE,
                     			X_float_handling_flag	VARCHAR2 ) IS
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_CLEAR1.validate_effective_date');
  END IF;
  IF (X_effective_date > sysdate AND
      X_float_handling_flag = 'E' AND
      passin_mode = 'AUTO') THEN
          FND_MESSAGE.set_name( 'CE','CE_FLOAT_VIOLATION');
          RAISE APP_EXCEPTION.application_exception;
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_CLEAR1.validate_effective_date');
  END IF;
END validate_effective_date;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       check_matching_status                                           |
|                                                                       |
|  DESCRIPTION                                                          |
|       Find out NOCOPY if a receipt has already been matched to Statement line|
|       Original design was to have this SQL to be included into        |
|       CE_AVAILABLE_TRANSACTIONS_V. For performance etc. reasons       |
|       it was moved into reconciliation.                               |
|       Since AR allows RISK_ELIMINATION of already reconciled/matched  |
|       receipts, we need to check the status of the receipt, and       |
|       and compare it against the receipt to be matched                |
|       To be reconciled        Already reconciled      Outcome         |
|   --  CLEARED,RISK_ELIMINATED RISK_ELIMINATED         NOT AVAILABLE   |
|   --  CLEARED,RISK_ELIMINATED CLEARED                 NOT AVAILABLE   |
|   --  CLEARED,RISK_ELIMINATED REMITTED                AVAILABLE       |
|   --  CLEARED,RISK_ELIMINATED REVERSED                AVAILABLE       |
|                                                                       |
|  RETURNS                                                              |
|       Status  Status of the cash_receipt_history_record matched       |
 --------------------------------------------------------------------- */
FUNCTION check_matching_status(cr_id            IN NUMBER,
                               orig_status      IN VARCHAR2) RETURN BOOLEAN IS
  x_status      AR_CASH_RECEIPT_HISTORY_ALL.status%TYPE;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_CLEAR1.check_matching_status');
  END IF;
  SELECT crh.status
  INTO   x_status
  FROM   ce_statement_recon_gt_v rec, --ce_statement_reconcils_all rec,
         ar_cash_receipt_history_all      crh,
         ar_cash_receipts_all             cr
  WHERE  rec.current_record_flag = 'Y'                          AND
         rec.status_flag = 'M'                                  AND
         rec.reference_type = 'RECEIPT'                         AND
         rec.reference_id   = crh.cash_receipt_history_id       AND
         crh.cash_receipt_id = cr.cash_receipt_id               AND
         cr.cash_receipt_id = cr_id;
  IF (orig_status IN ('CLEARED','RISK_ELIMINATED') AND
      x_status IN ('CLEARED','RISK_ELIMINATED')) THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('check_matching_status: ' || 'NOT AVAILABLE FOR RECONCILIATION');
    END IF;
    return(FALSE);
  ELSE
    return(TRUE);
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_CLEAR1.check_matching_status');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('check_matching_status: ' || 'No data found: not an error');
    END IF;
    RETURN TRUE;
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_AUTO_BANK_CLEAR1.check_matching_status');
    END IF;
    RAISE;
END check_matching_status;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       update_line_unreconciled                                        |
|  DESCRIPTION                                                          |
|       Checks if the statement line is fully unreconciled              |
|       and updates the status accordingly                              |
 --------------------------------------------------------------------- */
PROCEDURE update_line_unreconciled (X_statement_line_id NUMBER) IS
   c_count_reconciled  NUMBER;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_CLEAR1.update_line_unreconciled');
  END IF;

  SELECT count(*)
  INTO c_count_reconciled
  FROM CE_STATEMENT_RECONCILS_ALL
  WHERE statement_line_id = X_statement_line_id
  AND  current_record_flag = 'Y'
  AND  status_flag = 'M';

  IF (c_count_reconciled = 0) THEN
    CE_AUTO_BANK_CLEAR.update_line_status(X_statement_line_id,'UNRECONCILED');
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_CLEAR1.update_line_unreconciled');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_AUTO_BANK_CLEAR1.update_line_unreconciled');
    END IF;
    RAISE;
END update_line_unreconciled;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       create_statement_line                                           |
|  DESCRIPTION                                                          |
|       Inserts records into CE_STATEMENT_LINES .                       |
 --------------------------------------------------------------------- */
PROCEDURE create_statement_line IS
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('>>CE_AUTO_BANK_CLEAR1.create_statement_line');
  END IF;
  CE_STAT_LINES_DML_PKG.Insert_Row(
        X_Row_Id                => CE_AUTO_BANK_MATCH.csl_rowid,
        X_statement_line_id     => CE_AUTO_BANK_MATCH.csl_statement_line_id,
        X_statement_header_id   => CE_AUTO_BANK_MATCH.csh_statement_header_id,
        X_line_number           => CE_AUTO_BANK_MATCH.csl_line_number,
        X_trx_date              => CE_AUTO_BANK_MATCH.csl_trx_date,
        X_trx_type              => CE_AUTO_BANK_MATCH.csl_trx_type,
        X_trx_status            => CE_AUTO_BANK_MATCH.trx_status,
        X_trx_code				=> NULL,
        X_effective_date        => CE_AUTO_BANK_MATCH.csl_effective_date,
        X_bank_trx_number       => CE_AUTO_BANK_MATCH.csl_bank_trx_number,
        X_trx_text              => NULL,
        X_customer_text         => NULL,
        X_invoice_text          => NULL,
        X_bank_account_text     => NULL,
        X_amount                => CE_AUTO_BANK_MATCH.csl_amount,
        X_charges_amount        => CE_AUTO_BANK_MATCH.csl_charges_amount,
        X_status                => 'RECONCILED',
        X_created_by            => NVL(FND_GLOBAL.user_id,-1),
        X_creation_date         => sysdate,
        X_last_updated_by       => NVL(FND_GLOBAL.user_id,-1),
        X_last_update_date      => sysdate,
        X_currency_code         => CE_AUTO_BANK_MATCH.csl_currency_code,
        X_original_amount       => CE_AUTO_BANK_MATCH.csl_original_amount,
        X_exchange_rate         => CE_AUTO_BANK_MATCH.csl_exchange_rate,
        X_exchange_rate_type    => CE_AUTO_BANK_MATCH.csl_exchange_rate_type,
        X_exchange_rate_date    => CE_AUTO_BANK_MATCH.csl_exchange_rate_date,
        X_attribute_category    => NULL,
        X_attribute1            => NULL,
        X_attribute2            => NULL,
        X_attribute3            => NULL,
        X_attribute4            => NULL,
        X_attribute5            => NULL,
        X_attribute6            => NULL,
        X_attribute7            => NULL,
        X_attribute8            => NULL,
        X_attribute9            => NULL,
        X_attribute10           => NULL,
        X_attribute11           => NULL,
        X_attribute12           => NULL,
        X_attribute13           => NULL,
        X_attribute14           => NULL,
        X_attribute15           => NULL,
	-- 5916290: GDF Changes
        X_global_att_category   => NULL,
        X_global_attribute1     => NULL,
        X_global_attribute2     => NULL,
        X_global_attribute3     => NULL,
        X_global_attribute4     => NULL,
        X_global_attribute5     => NULL,
        X_global_attribute6     => NULL,
        X_global_attribute7     => NULL,
        X_global_attribute8     => NULL,
        X_global_attribute9     => NULL,
        X_global_attribute10    => NULL,
        X_global_attribute11    => NULL,
        X_global_attribute12    => NULL,
        X_global_attribute13    => NULL,
        X_global_attribute14    => NULL,
        X_global_attribute15    => NULL,
        X_global_attribute16    => NULL,
        X_global_attribute17    => NULL,
        X_global_attribute18    => NULL,
        X_global_attribute19    => NULL,
        X_global_attribute20    => NULL
		);
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('<<CE_AUTO_BANK_CLEAR1.create_statement_line');
  END IF;
END create_statement_line;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       insert_reconciliation                                           |
|  DESCRIPTION                                                          |
|       Inserts records into CE_STATEMENT_RECONCILIATIONS.              |
 --------------------------------------------------------------------- */
PROCEDURE insert_reconciliation (
        Y_statement_line_id     NUMBER   ,
        Y_cleared_trx_type      VARCHAR2,
        Y_cleared_trx_id        NUMBER,
        Y_ar_cash_receipt_id    NUMBER,
        Y_reference_status      VARCHAR2,
        Y_auto_reconciled_flag  VARCHAR2,
        Y_status_flag           VARCHAR2,
        Y_amount                NUMBER  )   IS
  Y_rowid       VARCHAR2(100);
  Y_org_id	number(15);
  Y_legal_entity_id	number(15);
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_CLEAR1.insert_reconciliation');
  END IF;

  --Y_org_id := nvl(CE_AUTO_BANK_REC.G_org_id,CE_AUTO_BANK_REC.G_legal_entity_id);
  --Y_org_id := nvl(CE_AUTO_BANK_REC.G_org_id,CE_AUTO_BANK_MATCH.bau_org_id);
  --Y_legal_entity_id := nvl(CE_AUTO_BANK_REC.G_legal_entity_id,CE_AUTO_BANK_MATCH.bau_legal_entity_id);

  Y_org_id := nvl(nvl(CE_AUTO_BANK_CLEAR.G_org_id,CE_AUTO_BANK_MATCH.trx_org_id),CE_AUTO_BANK_REC.G_org_id) ;
  Y_legal_entity_id := nvl(nvl(CE_AUTO_BANK_CLEAR.G_legal_entity_id,CE_AUTO_BANK_MATCH.trx_legal_entity_id),
				CE_AUTO_BANK_REC.G_legal_entity_id);

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('Y_org_id = ' ||Y_org_id || ', Y_legal_entity_id = ' ||Y_legal_entity_id||
		', CE_AUTO_BANK_MATCH.csl_reconcile_flag = ' ||CE_AUTO_BANK_MATCH.csl_reconcile_flag ||
		', Y_cleared_trx_type = ' ||Y_cleared_trx_type);
  	cep_standard.debug('call CE_STATEMENT_RECONS_PKG.insert_row cestmreb');
  END IF;

  IF (CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'JE') THEN
    CE_STATEMENT_RECONS_PKG.insert_row(
        X_row_id                => Y_rowid,
        X_statement_line_id     => Y_statement_line_id,
        X_reference_type        => Y_cleared_trx_type,
        X_reference_id          => Y_cleared_trx_id,
        X_je_header_id          => Y_ar_cash_receipt_id,
        X_org_id                => NULL,
        X_legal_entity_id       => NULL,
        X_reference_status      => Y_reference_status,
		X_amount                => Y_amount,
        X_status_flag           => Y_status_flag,
        X_action_flag           => 'C',
        X_current_record_flag   => 'Y',
        X_auto_reconciled_flag  => Y_auto_reconciled_flag,
        X_created_by            => nvl(FND_GLOBAL.user_id,-1),
        X_creation_date         => sysdate,
        X_last_updated_by       => nvl(FND_GLOBAL.user_id,-1),
        X_last_update_date      => sysdate,
        X_request_id            => nvl(FND_GLOBAL.conc_request_id,-1),
        X_program_application_id =>nvl(FND_GLOBAL.prog_appl_id,-1),
        X_program_id            => nvl(FND_GLOBAL.conc_program_id,-1),
        X_program_update_date   => sysdate);
  ELSE
    IF (Y_cleared_trx_type IN ('ROI_LINE','STATEMENT')) THEN
      CE_STATEMENT_RECONS_PKG.insert_row(
        X_row_id                => Y_rowid,
        X_statement_line_id     => Y_statement_line_id,
        X_reference_type        => Y_cleared_trx_type,
        X_reference_id          => Y_cleared_trx_id,
        X_org_id                => null,
        X_legal_entity_id       => null,
        X_reference_status      => Y_reference_status,
        X_amount                => Y_amount,
        X_status_flag           => Y_status_flag,
        X_action_flag           => 'C',
        X_current_record_flag   => 'Y',
        X_auto_reconciled_flag  => Y_auto_reconciled_flag,
        X_created_by            => nvl(FND_GLOBAL.user_id,-1),
        X_creation_date         => sysdate,
        X_last_updated_by       => nvl(FND_GLOBAL.user_id,-1),
        X_last_update_date      => sysdate,
        X_request_id            => nvl(FND_GLOBAL.conc_request_id,-1),
        X_program_application_id =>nvl(FND_GLOBAL.prog_appl_id,-1),
        X_program_id            => nvl(FND_GLOBAL.conc_program_id,-1),
        X_program_update_date   => sysdate);
    ELSE
      CE_STATEMENT_RECONS_PKG.insert_row(
        X_row_id                => Y_rowid,
        X_statement_line_id     => Y_statement_line_id,
        X_reference_type        => Y_cleared_trx_type,
        X_reference_id          => Y_cleared_trx_id,
        X_org_id                => Y_org_id,
        X_legal_entity_id       => Y_legal_entity_id,
        X_reference_status      => Y_reference_status,
        X_amount                => Y_amount,
        X_status_flag           => Y_status_flag,
        X_action_flag           => 'C',
        X_current_record_flag   => 'Y',
        X_auto_reconciled_flag  => Y_auto_reconciled_flag,
        X_created_by            => nvl(FND_GLOBAL.user_id,-1),
        X_creation_date         => sysdate,
        X_last_updated_by       => nvl(FND_GLOBAL.user_id,-1),
        X_last_update_date      => sysdate,
        X_request_id            => nvl(FND_GLOBAL.conc_request_id,-1),
        X_program_application_id =>nvl(FND_GLOBAL.prog_appl_id,-1),
        X_program_id            => nvl(FND_GLOBAL.conc_program_id,-1),
        X_program_update_date   => sysdate);

    END IF;
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('end call CE_STATEMENT_RECONS_PKG.insert_row');
  END IF;

  if (CE_AUTO_BANK_MATCH.nsf_info_flag = 'Y') then
     IF l_DEBUG in ('Y', 'C') THEN
     	cep_standard.debug('insert_reconciliation: ' || 'Insert CE_ABR_NSF_INFO warning.');
     END IF;
     CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
        CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_NSF_INFO');
     CE_AUTO_BANK_MATCH.nsf_info_flag := 'N';
  end if;
  if (CE_AUTO_BANK_MATCH.trx_clr_flag = 'Y') then
     IF l_DEBUG in ('Y', 'C') THEN
     	cep_standard.debug('insert_reconciliation: ' || 'Insert CE_TRX_DATE_CLEARED_DATE warning.');
     END IF;
     CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
        CE_AUTO_BANK_MATCH.csl_statement_line_id,
	'CE_TRX_DATE_CLEARED_DATE');
     CE_AUTO_BANK_MATCH.trx_clr_flag := 'N';
  end if;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_CLEAR1.insert_reconciliation');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: CE_AUTO_BANK_CLEAR1.insert_reconciliation');
    END IF;
    RAISE;
END insert_reconciliation;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       reconcile_rbatch                                                |
|  DESCRIPTION                                                          |
|       Each receipt within the remittance batch must be cleared and    |
|       reconciled.                                                     |
|  CALLED BY                                                            |
|       reconcile_process                                               |
 --------------------------------------------------------------------- */
PROCEDURE reconcile_rbatch(
        passin_mode                     VARCHAR2,
        rbatch_id                       NUMBER,
        X_statement_line_id     IN OUT NOCOPY  NUMBER,
        gl_date                         DATE,
	value_date			DATE,
        bank_currency                   VARCHAR2,
        exchange_rate_type              VARCHAR2,
        exchange_rate                   NUMBER,
        exchange_rate_date              DATE,
        trx_currency_type               VARCHAR2,
        module                          VARCHAR2,
        X_trx_number            IN OUT NOCOPY  VARCHAR2,
        X_trx_date                      DATE,
        X_deposit_date                  DATE,
        X_amount                        NUMBER,
        X_foreign_diff_amt              NUMBER,
        X_set_of_books_id               NUMBER,
        X_misc_currency_code            VARCHAR2,
        X_receipt_method_id             NUMBER,
        X_bank_account_id               NUMBER,
        X_activity_type_id              NUMBER,
        X_comments                      VARCHAR2,
        X_reference_type                VARCHAR2,
        X_clear_currency_code           VARCHAR2,
        X_tax_id                        NUMBER,
        X_tax_rate			NUMBER,
        X_cr_vat_tax_id                 VARCHAR2,
        X_dr_vat_tax_id                 VARCHAR2,
        X_trx_type                      VARCHAR2,
        X_statement_header_id   IN OUT NOCOPY  NUMBER,
        X_statement_date                DATE,
        X_bank_trx_number               VARCHAR2,
        X_statement_amount              NUMBER,
        X_original_amount               NUMBER,
        X_effective_date                DATE,
        X_float_handling_flag           VARCHAR2) IS
  receipt_id             AR_CASH_RECEIPTS_ALL.cash_receipt_id%TYPE;
  receipt_history_id   AR_CASH_RECEIPT_HISTORY_ALL.cash_receipt_history_id%TYPE;
  receipt_type           AR_CASH_RECEIPTS_ALL.type%TYPE;
  receipt_status         CE_LOOKUPS.lookup_code%TYPE;
  receipt_date           DATE;
  receipt_gl_date	DATE;
  amount_to_clear        NUMBER;
  trx_amount             NUMBER;
  adjusted_xrate_amount        NUMBER;
  trx_exchange_rate_date DATE;
  trx_exchange_rate_type AR_CASH_RECEIPTS_ALL.exchange_rate_type%TYPE;
  misc_receipt_id        AR_CASH_RECEIPTS_ALL.cash_receipt_id%TYPE;
  auto_reconcile_flag    VARCHAR2(1);
  l_amount    		 NUMBER;
  l_vat_tax_id           NUMBER := to_number(null);
  l_tax_rate             NUMBER := to_number(null);
  X_org_id             NUMBER ;
precision		NUMBER default NULL;
ext_precision		NUMBER default NULL;
min_acct_unit		NUMBER default NULL;
  l_gt_seq_id		NUMBER := to_number(null);

BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_CLEAR1.reconcile_rbatch');
  END IF;
  auto_reconcile_flag := 'Y';
  CE_AUTO_BANK_CLEAR1.validate_effective_date(          passin_mode,
                                                        X_effective_date,
                                                        X_float_handling_flag);
  IF (NVL(X_amount,0) <> 0  AND (X_receipt_method_id IS NULL OR X_activity_type_id IS NULL)) THEN
    FND_MESSAGE.set_name('CE','CE_BATCHES_MISC_MISSING');
    RAISE APP_EXCEPTION.application_exception;
  END IF;
  IF( passin_mode IN ( 'MANUAL','MANUAL_H', 'MANUAL_C')) THEN
    --IF( X_statement_line_id IS NULL) THEN
    IF (X_statement_line_id IS NULL AND passin_mode <> 'MANUAL_C') THEN --bug 3436722
      OPEN C_STATEMENT_LINE_SEQ;
      FETCH C_STATEMENT_LINE_SEQ INTO X_statement_line_id;
      CLOSE C_STATEMENT_LINE_SEQ;
    END IF;
    auto_reconcile_flag := 'N';
    CE_AUTO_BANK_MATCH.csh_statement_header_id := X_statement_header_id;
    CE_AUTO_BANK_MATCH.csh_statement_date       := X_statement_date;
    CE_AUTO_BANK_REC.G_gl_date          	:= gl_date;
    CE_AUTO_BANK_MATCH.csl_effective_date	:= value_date;
    CE_AUTO_BANK_REC.G_dr_vat_tax_code          := X_dr_vat_tax_id;
    CE_AUTO_BANK_REC.G_cr_vat_tax_code          := X_cr_vat_tax_id;
    CE_AUTO_BANK_MATCH.aba_bank_currency        := bank_currency;
    CE_AUTO_BANK_MATCH.csl_statement_line_id    := X_statement_line_id;
    CE_AUTO_BANK_MATCH.csl_exchange_rate_type   := exchange_rate_type;
    CE_AUTO_BANK_MATCH.csl_exchange_rate_date   := exchange_rate_date;
    CE_AUTO_BANK_MATCH.csl_exchange_rate        := exchange_rate;
    CE_AUTO_BANK_MATCH.csl_trx_date             := X_statement_date;
    CE_AUTO_BANK_MATCH.csl_trx_type             := X_trx_type;
    CE_AUTO_BANK_MATCH.csl_amount               := X_statement_amount;
    CE_AUTO_BANK_MATCH.csl_currency_code        := X_clear_currency_code;
    CE_AUTO_BANK_MATCH.csl_original_amount      := X_original_amount;
    CE_AUTO_BANK_MATCH.csl_charges_amount	:= NULL;
    CE_AUTO_BANK_MATCH.csl_bank_trx_number      := X_bank_trx_number;
    CE_AUTO_BANK_MATCH.trx_status               := NULL;
    IF (passin_mode = 'MANUAL_H') THEN
      CE_AUTO_BANK_CLEAR1.create_statement_line;
      IF(X_statement_header_id IS NULL)THEN
	X_statement_header_id := CE_AUTO_BANK_MATCH.csh_statement_header_id;
      END IF;
    END IF;
  END IF;
  IF (trx_currency_type IN ('FOREIGN','BANK')) THEN
    CE_AUTO_BANK_CLEAR.G_exchange_rate_type     := CE_AUTO_BANK_MATCH.csl_exchange_rate_type;
    CE_AUTO_BANK_CLEAR.G_exchange_date  := CE_AUTO_BANK_MATCH.csl_exchange_rate_date;
    CE_AUTO_BANK_CLEAR.G_exchange_rate  := CE_AUTO_BANK_MATCH.csl_exchange_rate;
  ELSE
    CE_AUTO_BANK_CLEAR.G_exchange_rate_type     := NULL;
    CE_AUTO_BANK_CLEAR.G_exchange_date  := NULL;
    CE_AUTO_BANK_CLEAR.G_exchange_rate  := NULL;
  END IF;
  --
  -- The batch cannot be cleared and reconciled as one transaction so each
  -- receipt within the batch must be processed separately.
  --

if (passin_mode = 'AUTO') then
  OPEN rbatch_cursor (rbatch_id);
  LOOP
    FETCH rbatch_cursor INTO receipt_history_id,
                             receipt_id,
                             receipt_type,
                             receipt_date,
                             receipt_status,
                             amount_to_clear,
                             trx_amount,
			     receipt_gl_date,
                             trx_exchange_rate_date,
                             trx_exchange_rate_type,
			     l_gt_seq_id;
    EXIT WHEN rbatch_cursor%NOTFOUND OR rbatch_cursor%NOTFOUND IS NULL;

    -- mark the transaction in ce_available_transactions_tmp as reconciled
/*
    IF l_gt_seq_id is not null THEN
      update ce_available_transactions_tmp
      set    reconciled_status_flag = 'Y'
      where  seq_id = l_gt_seq_id;
    END IF;
*/
    --IF (to_date(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD') < to_date(receipt_gl_date,'YYYY/MM/DD')) THEN
    IF (to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD') < to_date(to_char(receipt_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD')) THEN
      CE_AUTO_BANK_REC.G_gl_date := receipt_gl_date;
    END IF;

    --IF (to_date(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD') <
	--to_date(receipt_gl_date,'YYYY/MM/DD')) THEN
    IF (to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD') <
	to_date(to_char(receipt_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD')) THEN
      CE_AUTO_BANK_MATCH.csl_trx_date := receipt_gl_date;
    END IF;

    IF (receipt_status not in ('CLEARED', 'RISK_ELIMINATED')) THEN
      IF (amount_to_clear = trx_amount) THEN
        ARP_CASHBOOK.clear(
         p_cr_id               => receipt_id,
         p_trx_date            => to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
         p_gl_date             => to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
	 p_actual_value_date   => to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
         p_exchange_date       => to_date(to_char(CE_AUTO_BANK_CLEAR.G_exchange_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
         p_exchange_rate_type  => CE_AUTO_BANK_CLEAR.G_exchange_rate_type,
         p_exchange_rate       => to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate),
         p_bank_currency       => CE_AUTO_BANK_MATCH.aba_bank_currency,
         p_amount_cleared      => amount_to_clear,
         p_amount_factored     => 0,
         p_module_name         => module,
         p_module_version      => '1.0',
         p_crh_id              => receipt_history_id);
      ELSE -- foreign currency remittance batch
        -- bug 3911424 used the new xrate, xrate date, xrate type and xrate amount cleared
        IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('receipt_id = '||  receipt_id);
  	 cep_standard.debug('(CE_AUTO_BANK_MATCH.csl_trx_date) = '|| to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD') );
  	 cep_standard.debug('(CE_AUTO_BANK_REC.G_gl_date) = '||to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD'));
  	 cep_standard.debug('(CE_AUTO_BANK_MATCH.csl_effective_date) = '|| to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'));
  	 cep_standard.debug('exchange_rate = '||  to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate));
  	 cep_standard.debug('CE_AUTO_BANK_CLEAR.G_exchange_rate_type = '||  CE_AUTO_BANK_CLEAR.G_exchange_rate_type);

  	 cep_standard.debug('to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate)  = '|| to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate)  );
  	 cep_standard.debug('CE_AUTO_BANK_MATCH.aba_bank_currency  = '|| CE_AUTO_BANK_MATCH.aba_bank_currency  );
  	 cep_standard.debug('module  = '||  module );
  	 cep_standard.debug('receipt_history_id  = '||  receipt_history_id );

  	 cep_standard.debug('trx_amount = '||  trx_amount);
  	 cep_standard.debug('amount_to_clear = '||  amount_to_clear);

  	 cep_standard.debug('trx_exchange_rate_date = '|| trx_exchange_rate_date );
  	 cep_standard.debug(' trx_exchange_rate_type = '|| trx_exchange_rate_type  );
        END IF;

        IF ((trx_currency_type = 'FOREIGN') and
	  (CE_AUTO_BANK_CLEAR.G_exchange_rate  is not null)) THEN

	  adjusted_xrate_amount := (trx_amount * to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate));

          FND_CURRENCY.get_info(CE_AUTO_BANK_MATCH.csl_currency_code,
				 precision,
				 ext_precision,
				 min_acct_unit);

          IF l_DEBUG in ('Y', 'C') THEN
    	    cep_standard.debug('precision = '||  precision);
          END IF;

 	  amount_to_clear := round(adjusted_xrate_amount, precision) ;

        END IF;
        IF l_DEBUG in ('Y', 'C') THEN

 	  cep_standard.debug('set adjusted xrate_amount to amount_to_clear, trx_amount * CE_AUTO_BANK_CLEAR.G_exchange_rate ');
  	  cep_standard.debug('amount_to_clear = '||  amount_to_clear);
        END IF;

        ARP_CASHBOOK.clear(
         p_cr_id               => receipt_id,
         p_trx_date            => to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
         p_gl_date             => to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
	 p_actual_value_date   => to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
         p_exchange_date       => to_date(to_char(CE_AUTO_BANK_CLEAR.G_exchange_date,'YYYY/MM/DD'),'YYYY/MM/DD'), --trx_exchange_rate_date,
         p_exchange_rate_type  => CE_AUTO_BANK_CLEAR.G_exchange_rate_type,  --trx_exchange_rate_type,
         p_exchange_rate       => to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate), --amount_to_clear/trx_amount,
         p_bank_currency       => CE_AUTO_BANK_MATCH.aba_bank_currency,
         p_amount_cleared      => amount_to_clear,
         p_amount_factored     => 0,
         p_module_name         => module,
         p_module_version      => '1.0',
         p_crh_id              => receipt_history_id);
      END IF;
    END IF;
    IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('after call');
 	 cep_standard.debug('receipt_id = '||  receipt_id);
  	 cep_standard.debug('(CE_AUTO_BANK_MATCH.csl_trx_date) = '||  to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'));
  	 cep_standard.debug('(CE_AUTO_BANK_REC.G_gl_date) = '||to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD'));
  	 cep_standard.debug('(CE_AUTO_BANK_MATCH.csl_effective_date) = '|| to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'));
  	 cep_standard.debug('exchange_rate = '||  to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate));
  	 cep_standard.debug('CE_AUTO_BANK_CLEAR.G_exchange_rate_type = '||  CE_AUTO_BANK_CLEAR.G_exchange_rate_type);

  	 cep_standard.debug('to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate)  = '|| to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate)  );
  	 cep_standard.debug('CE_AUTO_BANK_MATCH.aba_bank_currency  = '|| CE_AUTO_BANK_MATCH.aba_bank_currency  );
  	 cep_standard.debug('module  = '||  module );
  	 cep_standard.debug('receipt_history_id  = '||  receipt_history_id );

  	 cep_standard.debug('trx_amount = '||  trx_amount);
  	 cep_standard.debug('trx_exchange_rate_date = '|| trx_exchange_rate_date );
  	 cep_standard.debug(' trx_exchange_rate_type = '|| trx_exchange_rate_type  );
  	 cep_standard.debug('amount_to_clear = '||  amount_to_clear);
    END IF;
    CE_AUTO_BANK_MATCH.csl_reconcile_flag := 'CASH';
    IF (passin_mode <> 'MANUAL_C' ) THEN -- bug 3436722
      CE_AUTO_BANK_CLEAR1.insert_reconciliation (
        Y_cleared_trx_type      =>receipt_type,
        Y_cleared_trx_id        =>receipt_history_id,
        Y_ar_cash_receipt_id    =>receipt_id,
        Y_reference_status      =>receipt_status,
        Y_auto_reconciled_flag  =>auto_reconcile_flag,
        Y_status_flag           =>'M',
	Y_amount		=> amount_to_clear);
    END IF;

    -- mark the transaction in ce_available_transactions_tmp as reconciled
    IF l_gt_seq_id is not null THEN
      CE_AUTO_BANK_MATCH.update_gt_reconciled_status (l_gt_seq_id, 'Y');
    END IF;


  END LOOP; -- rbatch_cursor
  CLOSE rbatch_cursor;
else
  -- Fix bug 5637589 for manual remittance batch reconciliation
  OPEN manual_rbatch_cursor (rbatch_id);
  LOOP
    FETCH manual_rbatch_cursor INTO receipt_history_id,
                             receipt_id,
                             receipt_type,
                             receipt_date,
                             receipt_status,
                             amount_to_clear,
                             trx_amount,
			     receipt_gl_date,
                             trx_exchange_rate_date,
                             trx_exchange_rate_type,
			     X_org_id;
    EXIT WHEN manual_rbatch_cursor%NOTFOUND OR manual_rbatch_cursor%NOTFOUND IS NULL;

    --IF (to_date(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD') < to_date(receipt_gl_date,'YYYY/MM/DD')) THEN
    IF (to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD') < to_date(to_char(receipt_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD')) THEN
      CE_AUTO_BANK_REC.G_gl_date := receipt_gl_date;
    END IF;

    --IF (to_date(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD') <
	--to_date(receipt_gl_date,'YYYY/MM/DD')) THEN
    IF (to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD') <
	to_date(to_char(receipt_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD')) THEN
      CE_AUTO_BANK_MATCH.csl_trx_date := receipt_gl_date;
    END IF;

    IF (receipt_status not in ('CLEARED', 'RISK_ELIMINATED')) THEN
      IF (amount_to_clear = trx_amount) THEN
        ARP_CASHBOOK.clear(
         p_cr_id               => receipt_id,
         p_trx_date            => to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
         p_gl_date             => to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
	 p_actual_value_date   => to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
         p_exchange_date       => to_date(to_char(CE_AUTO_BANK_CLEAR.G_exchange_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
         p_exchange_rate_type  => CE_AUTO_BANK_CLEAR.G_exchange_rate_type,
         p_exchange_rate       => to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate),
         p_bank_currency       => CE_AUTO_BANK_MATCH.aba_bank_currency,
         p_amount_cleared      => amount_to_clear,
         p_amount_factored     => 0,
         p_module_name         => module,
         p_module_version      => '1.0',
         p_crh_id              => receipt_history_id);
      ELSE -- foreign currency remittance batch
        -- bug 3911424 used the new xrate, xrate date, xrate type and xrate amount cleared
        IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('receipt_id = '||  receipt_id);
  	 cep_standard.debug('(CE_AUTO_BANK_MATCH.csl_trx_date) = '|| to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD') );
  	 cep_standard.debug('(CE_AUTO_BANK_REC.G_gl_date) = '||to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD'));
  	 cep_standard.debug('(CE_AUTO_BANK_MATCH.csl_effective_date) = '|| to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'));
  	 cep_standard.debug('exchange_rate = '||  to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate));
  	 cep_standard.debug('CE_AUTO_BANK_CLEAR.G_exchange_rate_type = '||  CE_AUTO_BANK_CLEAR.G_exchange_rate_type);

  	 cep_standard.debug('to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate)  = '|| to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate)  );
  	 cep_standard.debug('CE_AUTO_BANK_MATCH.aba_bank_currency  = '|| CE_AUTO_BANK_MATCH.aba_bank_currency  );
  	 cep_standard.debug('module  = '||  module );
  	 cep_standard.debug('receipt_history_id  = '||  receipt_history_id );

  	 cep_standard.debug('trx_amount = '||  trx_amount);
  	 cep_standard.debug('amount_to_clear = '||  amount_to_clear);

  	 cep_standard.debug('trx_exchange_rate_date = '|| trx_exchange_rate_date );
  	 cep_standard.debug(' trx_exchange_rate_type = '|| trx_exchange_rate_type  );
        END IF;

        IF ((trx_currency_type = 'FOREIGN') and
	  (CE_AUTO_BANK_CLEAR.G_exchange_rate  is not null)) THEN

	  adjusted_xrate_amount := (trx_amount * to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate));

          FND_CURRENCY.get_info(CE_AUTO_BANK_MATCH.csl_currency_code,
				 precision,
				 ext_precision,
				 min_acct_unit);

          IF l_DEBUG in ('Y', 'C') THEN
    	    cep_standard.debug('precision = '||  precision);
          END IF;

 	  amount_to_clear := round(adjusted_xrate_amount, precision) ;

        END IF;
        IF l_DEBUG in ('Y', 'C') THEN

 	  cep_standard.debug('set adjusted xrate_amount to amount_to_clear, trx_amount * CE_AUTO_BANK_CLEAR.G_exchange_rate ');
  	  cep_standard.debug('amount_to_clear = '||  amount_to_clear);
        END IF;

        ARP_CASHBOOK.clear(
         p_cr_id               => receipt_id,
         p_trx_date            => to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
         p_gl_date             => to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
	 p_actual_value_date   => to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
         p_exchange_date       => to_date(to_char(CE_AUTO_BANK_CLEAR.G_exchange_date,'YYYY/MM/DD'),'YYYY/MM/DD'), --trx_exchange_rate_date,
         p_exchange_rate_type  => CE_AUTO_BANK_CLEAR.G_exchange_rate_type,  --trx_exchange_rate_type,
         p_exchange_rate       => to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate), --amount_to_clear/trx_amount,
         p_bank_currency       => CE_AUTO_BANK_MATCH.aba_bank_currency,
         p_amount_cleared      => amount_to_clear,
         p_amount_factored     => 0,
         p_module_name         => module,
         p_module_version      => '1.0',
         p_crh_id              => receipt_history_id);
      END IF;
    END IF;
    IF l_DEBUG in ('Y', 'C') THEN
  	 cep_standard.debug('after call');
 	 cep_standard.debug('receipt_id = '||  receipt_id);
  	 cep_standard.debug('(CE_AUTO_BANK_MATCH.csl_trx_date) = '||  to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'));
  	 cep_standard.debug('(CE_AUTO_BANK_REC.G_gl_date) = '||to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD'));
  	 cep_standard.debug('(CE_AUTO_BANK_MATCH.csl_effective_date) = '|| to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'));
  	 cep_standard.debug('exchange_rate = '||  to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate));
  	 cep_standard.debug('CE_AUTO_BANK_CLEAR.G_exchange_rate_type = '||  CE_AUTO_BANK_CLEAR.G_exchange_rate_type);

  	 cep_standard.debug('to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate)  = '|| to_number(CE_AUTO_BANK_CLEAR.G_exchange_rate)  );
  	 cep_standard.debug('CE_AUTO_BANK_MATCH.aba_bank_currency  = '|| CE_AUTO_BANK_MATCH.aba_bank_currency  );
  	 cep_standard.debug('module  = '||  module );
  	 cep_standard.debug('receipt_history_id  = '||  receipt_history_id );

  	 cep_standard.debug('trx_amount = '||  trx_amount);
  	 cep_standard.debug('trx_exchange_rate_date = '|| trx_exchange_rate_date );
  	 cep_standard.debug(' trx_exchange_rate_type = '|| trx_exchange_rate_type  );
  	 cep_standard.debug('amount_to_clear = '||  amount_to_clear);
    END IF;
    CE_AUTO_BANK_MATCH.csl_reconcile_flag := 'CASH';
    IF (passin_mode <> 'MANUAL_C' ) THEN -- bug 3436722
      -- 5637589
      CE_AUTO_BANK_MATCH.trx_org_id := X_org_id;
      CE_AUTO_BANK_CLEAR1.insert_reconciliation (
        Y_cleared_trx_type      =>receipt_type,
        Y_cleared_trx_id        =>receipt_history_id,
        Y_ar_cash_receipt_id    =>receipt_id,
        Y_reference_status      =>receipt_status,
        Y_auto_reconciled_flag  =>auto_reconcile_flag,
        Y_status_flag           =>'M',
	Y_amount		=> amount_to_clear);
    END IF;

  END LOOP; -- manual_rbatch_cursor
  CLOSE manual_rbatch_cursor;
end if;  -- End manual remittance batch reconciliation

  IF (passin_mode <> 'MANUAL_C' ) THEN  -- bug 3436722
    IF (NVL(X_amount,0) <> 0) THEN
      SELECT h.statement_number || '/' || to_char(l.line_number)
      INTO   X_trx_number
      FROM   CE_STATEMENT_HEADERS h,
           CE_STATEMENT_LINES l
      WHERE  h.statement_header_id = l.statement_header_id AND
           l.statement_line_id   = X_statement_line_id;

      IF trx_currency_type = 'FOREIGN' THEN
        l_amount := X_amount/exchange_rate;
      ELSE
        l_amount := X_amount;
      END IF;

      if (passin_mode = 'AUTO' and
	CE_AUTO_BANK_MATCH.ar_accounting_method = 'ACCRUAL') then
        CE_AUTO_BANK_MATCH.get_vat_tax_id('AUTO', l_vat_tax_id, l_tax_rate);
      else
        l_vat_tax_id := X_tax_id;
        l_tax_rate := X_tax_rate;
      end if;

      CE_AUTO_BANK_CLEAR.misc_receipt(
        X_PASSIN_MODE           => passin_mode,
        X_TRX_NUMBER            => X_trx_number,
        X_DOC_SEQUENCE_VALUE    => NULL,
        X_DOC_SEQUENCE_ID       => NULL,
        X_GL_DATE               => gl_date,
	X_VALUE_DATE		=> value_date,
        X_TRX_DATE              => X_trx_date,
        X_DEPOSIT_DATE          => X_deposit_date,
        X_AMOUNT                => l_amount,
        X_BANK_ACCOUNT_AMOUNT   => X_amount,
        X_SET_OF_BOOKS_ID       => X_set_of_books_id,
        X_MISC_CURRENCY_CODE    => X_misc_currency_code,
        X_EXCHANGE_RATE_DATE    => exchange_rate_date,
        X_EXCHANGE_RATE_TYPE    => exchange_rate_type,
        X_EXCHANGE_RATE         => exchange_rate,
        X_RECEIPT_METHOD_ID     => X_receipt_method_id,
        X_BANK_ACCOUNT_ID       => X_bank_account_id,
        X_ACTIVITY_TYPE_ID      => X_activity_type_id,
        X_COMMENTS              => X_comments,
        X_REFERENCE_TYPE        => X_reference_type,
        X_REFERENCE_ID          => rbatch_id,
        X_CLEAR_CURRENCY_CODE   => bank_currency,
        X_STATEMENT_LINE_ID     => X_statement_line_id,
        X_TAX_ID                => l_vat_tax_id,
        X_TAX_RATE 		=> l_tax_rate,
        X_PAID_FROM             => NULL,
        X_MODULE_NAME           => module,
        X_cr_vat_tax_id         => X_cr_vat_tax_id,
        X_dr_vat_tax_id         => X_dr_vat_tax_id,
        trx_currency_type       => trx_currency_type,
        X_CR_ID                 => misc_receipt_id,
        X_effective_date        => X_effective_date,
        --X_org_id	        => CE_AUTO_BANK_MATCH.bau_org_id);
        X_org_id	        => CE_AUTO_BANK_MATCH.trx_org_id );
    END IF;
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_CLEAR1.reconcile_rbatch');
  END IF;
EXCEPTION
        WHEN OTHERS THEN
            -- bug 2875549
            cep_standard.debug('Exception: CE_AUTO_BANK_CLEAR1.reconcile_rbatch');
            if (passin_mode = 'AUTO') then
              IF rbatch_cursor%ISOPEN THEN
                 CLOSE rbatch_cursor;
              END IF;
            else
              IF manual_rbatch_cursor%ISOPEN THEN
                 CLOSE manual_rbatch_cursor;
              END IF;
            end if;
            RAISE;
END reconcile_rbatch;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       reconcile_pay_eft                                               |
|  DESCRIPTION                                                          |
|       Each EFT payment should be cleared and reconciled               |
|       This procedure is used in AutoReconciliation only               |
|       Use reconcile_trx for manual reconciliation of EFT payments     |
|  CALLED BY                                                            |
|       reconcile_process                                               |
 --------------------------------------------------------------------- */
PROCEDURE reconcile_pay_eft( passin_mode       	   	VARCHAR2,
                	 tx_type                        VARCHAR2,
                	 trx_count			NUMBER,
                	 trx_group	                VARCHAR2,
                	 cleared_trx_type               VARCHAR2,
			 cleared_date			DATE,
                	 X_bank_currency               	VARCHAR2,
                	 X_statement_line_id 	        NUMBER,
			 X_statement_line_type		VARCHAR2,
			 trx_currency_type		VARCHAR2,
                	 auto_reconciled_flag		VARCHAR2,
                	 X_statement_header_id          NUMBER,
                	 X_bank_trx_number              VARCHAR2,
                	 X_bank_account_id              VARCHAR2,
                 	 X_payroll_payment_format	VARCHAR2,
                	 X_effective_date		DATE,
                	 X_float_handling_flag		VARCHAR2) IS

  amount_to_clear        NUMBER;
  cleared_trx_id        NUMBER;
  auto_reconcile_flag    VARCHAR2(1);
  l_amount    		 NUMBER;
  l_gt_seq_id		NUMBER := to_number(null);

   cursor pay_eft_cursor is

	SELECT 	catv.trx_id,
		catv.bank_account_amount,
                catv.seq_id
      --FROM 	ce_801_EFT_transactions_v catv
      FROM      ce_available_transactions_tmp catv
      WHERE       upper(catv.batch_name) =
		    upper(CE_AUTO_BANK_MATCH.csl_bank_trx_number)
      AND	catv.trx_date = CE_AUTO_BANK_MATCH.csl_trx_date
      AND	catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
      AND		nvl(catv.status, 'C') <> 'V'
	and nvl(catv.batch_id, 0) = nvl(CE_AUTO_BANK_MATCH.trx_group,0)
      AND	catv.application_id = 802 -- for payroll eft 802 is application id bug 7242853
      AND	NVL(catv.reconciled_status_flag, 'N') = 'N';



BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_CLEAR1.reconcile_pay_eft');
  END IF;
  auto_reconcile_flag := 'Y';
  CE_AUTO_BANK_MATCH.csl_bank_trx_number      := X_bank_trx_number;
  --CE_AUTO_BANK_MATCH.csl_amount               := amount_cleared;
  CE_AUTO_BANK_MATCH.csh_bank_account_id      := X_bank_account_id;
  CE_AUTO_BANK_MATCH.trx_count      	      := trx_count;
  CE_AUTO_BANK_MATCH.trx_group    	      := trx_group;
  CE_AUTO_BANK_MATCH.csl_trx_date	      := cleared_date;
  CE_AUTO_BANK_MATCH.csl_payroll_payment_format  := X_payroll_payment_format;
  CE_AUTO_BANK_MATCH.csl_reconcile_flag	      := cleared_trx_type;

  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('>>CE_AUTO_BANK_MATCH.csl_bank_trx_number = '|| CE_AUTO_BANK_MATCH.csl_bank_trx_number);
    cep_standard.debug('>>CE_AUTO_BANK_MATCH.csh_bank_account_id = '|| CE_AUTO_BANK_MATCH.csh_bank_account_id);
    cep_standard.debug('>>CE_AUTO_BANK_MATCH.trx_group = '|| CE_AUTO_BANK_MATCH.trx_group);
    cep_standard.debug('>>CE_AUTO_BANK_MATCH.csl_payroll_payment_format = '|| CE_AUTO_BANK_MATCH.csl_payroll_payment_format);
    cep_standard.debug('>>CE_AUTO_BANK_MATCH.csl_reconcile_flag = '|| CE_AUTO_BANK_MATCH.csl_reconcile_flag);
    cep_standard.debug('>>CE_AUTO_BANK_MATCH.csl_trx_date = '|| CE_AUTO_BANK_MATCH.csl_trx_date);

  END IF;

  CE_AUTO_BANK_CLEAR1.validate_effective_date(          passin_mode,
                                                        X_effective_date,
                                                        X_float_handling_flag);
  --
  -- The batch cannot be cleared and reconciled as one transaction so each
  -- EFT payment must be processed separately.
  --
  IF( passin_mode IN ( 'AUTO') AND (CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'PAY_EFT')) THEN
    --IF (substr(CE_AUTO_BANK_MATCH.csl_payroll_payment_format,1,4) = 'BACS') THEN

	IF l_DEBUG in ('Y', 'C') THEN
  	  cep_standard.debug('reconcile_pay_eft ' );
    	  cep_standard.debug('>>open pay_eft_cursor  ');
	END IF;

      OPEN pay_eft_cursor;
      LOOP
	IF l_DEBUG in ('Y', 'C') THEN
    	  cep_standard.debug('>>fetch pay_eft_cursor  ');
	END IF;

        FETCH pay_eft_cursor INTO cleared_trx_id,
                                	amount_to_clear,
				  l_gt_seq_id;

	IF l_DEBUG in ('Y', 'C') THEN
    	  cep_standard.debug('>>pay_eft_cursor  cleared_trx_id  = '|| cleared_trx_id);
	  cep_standard.debug('>>pay_eft_cursor  amount_to_clear  = '|| amount_to_clear);
	END IF;

        EXIT WHEN pay_eft_cursor%NOTFOUND OR pay_eft_cursor%NOTFOUND IS NULL;

        -- mark the transaction in ce_available_transactions_tmp as reconciled
/*
        IF l_gt_seq_id is not null THEN
          update ce_available_transactions_tmp
          set    reconciled_status_flag = 'Y'
          where  seq_id = l_gt_seq_id;
        END IF;
*/


        IF l_DEBUG in ('Y', 'C') THEN
        	cep_standard.debug('reconcile_pay_eft: ' || '>>> Calling PAY_CE_RECONCILIATION_PKG.reconcile_payment'|| '-----' ||
        		   ' reconcile_pay_eft: ' || '>>> p_payment_id = '|| cleared_trx_id||
			   ' p_cleared_date = '|| to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD') ||
           		   ' p_trx_amount = '|| NVL(amount_to_clear,0)||
           		   ' p_trx_type = '||CE_AUTO_BANK_MATCH.csl_reconcile_flag);
        END IF;

      PAY_CE_RECONCILIATION_PKG.reconcile_payment (
           p_payment_id		=> cleared_trx_id, --CE_AUTO_BANK_MATCH.trx_id,
           p_cleared_date	=> to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
           p_trx_amount		=> NVL(amount_to_clear,0),
           p_trx_type		=> cleared_trx_type, --CE_AUTO_BANK_MATCH.csl_reconcile_flag,
           p_last_updated_by    => NVL(FND_GLOBAL.user_id,-1),
           p_last_update_login  => NVL(FND_GLOBAL.user_id,-1),
           p_created_by         => NVL(FND_GLOBAL.user_id,-1) );

	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('reconcile_pay_eft: ' || '<<< End PAY_CE_RECONCILIATION_PKG.reconcile_payment');
	END IF;


      IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('reconcile_pay_eft: ' || 'cleared_trx_type='||cleared_trx_type||
		',cleared_trx_id='||to_char(cleared_trx_id));
	cep_standard.debug(',auto_reconciled_flag='||auto_reconciled_flag||',amount_cleared='||to_char(amount_to_clear));
  	cep_standard.debug('reconcile_pay_eft: call CE_AUTO_BANK_CLEAR1.insert_reconciliation ');
      END IF;

      CE_AUTO_BANK_CLEAR1.insert_reconciliation (
        Y_cleared_trx_type      => cleared_trx_type,
        Y_cleared_trx_id        => cleared_trx_id,
        Y_ar_cash_receipt_id    => null,
        Y_reference_status      => null,
        Y_auto_reconciled_flag  => auto_reconciled_flag,
        Y_status_flag           => 'M',
        Y_amount                =>  amount_to_clear);

        -- mark the transaction in ce_available_transactions_tmp as reconciled
        IF l_gt_seq_id is not null THEN
          CE_AUTO_BANK_MATCH.update_gt_reconciled_status (l_gt_seq_id, 'Y');
        END IF;


	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('reconcile_pay_eft: ' || '<<< End CE_AUTO_BANK_CLEAR1.insert_reconciliation');
	END IF;

      END LOOP; -- pay_eft_cursor
      CLOSE pay_eft_cursor;

  END IF;

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_CLEAR1.reconcile_pay_eft');
  END IF;
EXCEPTION
        WHEN OTHERS THEN
            cep_standard.debug('Exception - OTHERS: CE_AUTO_BANK_CLEAR1.reconcile_pay_eft');
            IF pay_eft_cursor%ISOPEN THEN
               CLOSE pay_eft_cursor;
            END IF;
            RAISE;
END reconcile_pay_eft;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       misc_receipt                                                    |
 --------------------------------------------------------------------- */
PROCEDURE misc_receipt(         X_passin_mode           VARCHAR2,
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
                                X_paid_from             VARCHAR2,
                                X_module_name           VARCHAR2,
                                X_cr_vat_tax_id         VARCHAR2,
                                X_dr_vat_tax_id         VARCHAR2,
                                trx_currency_type       VARCHAR2,
                                X_cr_id         IN OUT NOCOPY  NUMBER,
				X_effective_date	DATE,
				X_org_id		NUMBER ) IS
  cash_receipt_history_id   AR_CASH_RECEIPT_HISTORY_ALL.cash_receipt_history_id%
TYPE;
  l_dbseqname                   VARCHAR2(30);
  l_doc_seq_id                  NUMBER;
  l_doc_seq_value               NUMBER;
  l_valid_seq                   BOOLEAN := TRUE;
  l_status                      VARCHAR2(30);
  l_amount			NUMBER;
  temp                          BOOLEAN;
  current_org_id		number;
  X_REMIT_BANK_ACCT_USE_ID     number;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_CLEAR1.misc_receipt');
  END IF;
  IF (X_statement_line_id IS NULL) THEN
    OPEN C_STATEMENT_LINE_SEQ;
    FETCH C_STATEMENT_LINE_SEQ INTO X_statement_line_id;
    CLOSE C_STATEMENT_LINE_SEQ;
  END IF;
  IF (X_passin_mode IN ('MANUAL_REC','MANUAL_NO_REC','MANUAL', 'MANUAL_H')) THEN
    CE_AUTO_BANK_REC.G_gl_date          	:= X_gl_date;
    CE_AUTO_BANK_MATCH.csl_trx_date             := X_trx_date;
    CE_AUTO_BANK_MATCH.csl_effective_date	:= X_value_date;
    CE_AUTO_BANK_MATCH.csl_exchange_rate_date   := X_exchange_rate_date;
    CE_AUTO_BANK_MATCH.csl_exchange_rate_type   := X_exchange_rate_type;
    CE_AUTO_BANK_MATCH.csl_exchange_rate        := X_exchange_rate;
    CE_AUTO_BANK_REC.G_payment_method_id        := X_receipt_method_id;
    CE_AUTO_BANK_MATCH.csh_bank_account_id      := X_bank_account_id;
    CE_AUTO_BANK_REC.G_receivables_trx_id       := X_activity_type_id;
    CE_AUTO_BANK_MATCH.csl_statement_line_id    := X_statement_line_id;
    CE_AUTO_BANK_MATCH.aba_bank_currency        := X_clear_currency_code;
    CE_AUTO_BANK_REC.G_set_of_books_id  := X_set_of_books_id;
    CE_AUTO_BANK_REC.G_cr_vat_tax_code  := X_cr_vat_tax_id;
    CE_AUTO_BANK_REC.G_dr_vat_tax_code  := X_dr_vat_tax_id;
    temp := CE_AUTO_BANK_MATCH.validate_payment_method;
    --CE_AUTO_BANK_REC.G_org_id          	:= X_org_id;
    CE_AUTO_BANK_CLEAR.G_org_id          	:= X_org_id;
  END IF;
  IF (trx_currency_type IN ('FOREIGN','BANK')) THEN
    CE_AUTO_BANK_CLEAR.G_exchange_rate_type     := CE_AUTO_BANK_MATCH.csl_exchange_rate_type;
    CE_AUTO_BANK_CLEAR.G_exchange_date  := CE_AUTO_BANK_MATCH.csl_exchange_rate_date;
    CE_AUTO_BANK_CLEAR.G_exchange_rate  := CE_AUTO_BANK_MATCH.csl_exchange_rate;
  ELSE
    CE_AUTO_BANK_CLEAR.G_exchange_rate_type     := NULL;
    CE_AUTO_BANK_CLEAR.G_exchange_date  := NULL;
    CE_AUTO_BANK_CLEAR.G_exchange_rate  := NULL;
  END IF;
  --
  -- Call the AOL sequence numbering routine to get Seq. number
  --
  IF (X_passin_mode IN ('MANUAL_REC', 'MANUAL_NO_REC')) THEN
    l_doc_seq_id        := X_doc_sequence_id;
    l_doc_seq_value     := X_doc_sequence_value;
  ELSE
   -- l_vat_tax_id := CE_AUTO_BANK_MATCH.get_vat_tax_id;
    -- CE_AUTO_BANK_MATCH.get_vat_tax_id(l_vat_tax_id, l_tax_rate);
    l_valid_seq := CE_AUTO_BANK_IMPORT.get_sequence_info(
                        222,
                        nvl(CE_AUTO_BANK_MATCH.csl_receipt_method_name,
			    CE_AUTO_BANK_REC.G_payment_method_name),
                        CE_AUTO_BANK_REC.G_set_of_books_id,
                        'A',
                        CE_AUTO_BANK_MATCH.csl_trx_date,
                        l_dbseqname,
                        l_doc_seq_id,
                        l_doc_seq_value );
    IF (NOT l_valid_seq) THEN
      IF (X_passin_mode IN ('AUTO','AUTO_TRX')) THEN
        CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_DOC_SEQUENCE_ERR');
      ELSE
        FND_MESSAGE.set_name('CE','CE_DOC_SEQUENCE_ERR');
      END IF;
      RAISE APP_EXCEPTION.application_exception;
    END IF;
  END IF;

/* bug# 1097681 take care of the logic in the MISC_RECEIPTS forms

  --
  -- Bug750582
  --
  IF X_misc_currency_code <> CE_AUTO_BANK_MATCH.aba_bank_currency THEN
      l_amount := X_amount / X_exchange_rate;
  ELSE
      l_amount := X_amount;
  END IF;
*/
  --set this in the form mo_global.set_policy_context('S',x_org_id);

    select mo_global.GET_CURRENT_ORG_ID
    into current_org_id
    from dual;

  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('current_org_id =' ||current_org_id );

    cep_standard.debug('X_trx_number =' ||X_trx_number );
    cep_standard.debug('l_doc_seq_value =' ||l_doc_seq_value );
    cep_standard.debug('l_doc_seq_id =' ||l_doc_seq_id );
    cep_standard.debug('X_gl_date =' ||X_gl_date );
    cep_standard.debug('X_trx_date =' ||X_trx_date );
    cep_standard.debug('X_deposit_date =' ||X_deposit_date );
    cep_standard.debug('X_amount =' ||X_amount );
    cep_standard.debug('X_misc_currency_code =' ||X_misc_currency_code );
    cep_standard.debug('X_exchange_rate_date =' ||X_exchange_rate_date );
    cep_standard.debug('X_exchange_rate_type =' ||X_exchange_rate_type );
    cep_standard.debug('X_exchange_rate =' ||X_exchange_rate );
    cep_standard.debug('X_receipt_method_id =' ||X_receipt_method_id );
    cep_standard.debug('X_bank_account_id =' ||X_bank_account_id );
    cep_standard.debug('X_activity_type_id =' ||X_activity_type_id );
    cep_standard.debug('X_comments =' ||X_comments );
    cep_standard.debug('X_tax_id =' ||X_tax_id );
    cep_standard.debug('X_reference_type =' ||X_reference_type );
    cep_standard.debug('X_reference_id =' ||X_reference_id );
    cep_standard.debug('X_paid_from =' ||X_paid_from );
    cep_standard.debug('X_effective_date =' ||X_effective_date );
    cep_standard.debug('X_module_name =' ||X_module_name );
    --cep_standard.debug('X_cr_id =' ||X_cr_id );
    cep_standard.debug('X_tax_rate =' ||X_tax_rate );

  END IF;

  -- bug 5185358/5221366 p_remit_bank_account_id is the
  --                     ar_receipt_method_accounts.remit_bank_acct_uses_id
  -- bug 5722367 changed to check for the bank account use id

  BEGIN
    SELECT  REMIT_BANK_ACCT_USE_ID
    INTO    X_REMIT_BANK_ACCT_USE_ID
    FROM   ar_receipt_methods rm,
           ar_receipt_method_accounts rma,
	   ce_bank_acct_uses cba
    WHERE
           rm.receipt_method_id = X_receipt_method_id
    AND    rma.receipt_method_id = rm.receipt_method_id
    AND    cba.bank_acct_use_id = rma.remit_bank_acct_use_id
    AND    cba.ar_use_enable_flag = 'Y'
    AND    cba.bank_account_id = X_bank_account_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('X_receipt_method_id does not exists ' || 'No data found');
      END IF;
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	   CE_AUTO_BANK_MATCH.csh_statement_header_id,
	   CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_TEMP_AR_METHOD_ORG_INVALID');
  END;

  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('X_REMIT_BANK_ACCT_USE_ID = '||X_REMIT_BANK_ACCT_USE_ID);
    cep_standard.debug('call ARP_CASHBOOK.ins_misc_txn ');
  END IF;

  ARP_CASHBOOK.ins_misc_txn(
        p_receipt_number                => X_trx_number,
        p_document_number               => l_doc_seq_value,
        p_doc_sequence_id               => l_doc_seq_id,
        p_gl_date                       => X_gl_date,
        p_receipt_date                  => X_trx_date,
        p_deposit_date                  => X_deposit_date,
        p_receipt_amount                => X_amount,
        p_currency_code                 => X_misc_currency_code,
        p_exchange_date                 => X_exchange_rate_date,
        p_exchange_rate_type            => X_exchange_rate_type,
        p_exchange_rate                 => X_exchange_rate,
        p_receipt_method_id             => X_receipt_method_id,
        p_remit_bank_account_id         => X_REMIT_BANK_ACCT_USE_ID, --X_bank_account_id,
        p_receivables_trx_id            => X_activity_type_id,
        p_comments                      => X_comments,
        p_vat_tax_id                    => X_tax_id,
        p_reference_type                => X_reference_type,
        p_reference_id                  => X_reference_id,
        p_misc_payment_source           => X_paid_from,
        p_anticipated_clearing_date     => X_effective_date,
        p_module_name                   => X_module_name,
        p_module_version                => '1.0',
        p_cr_id                         => X_cr_id,
        p_tax_rate			=> abs(X_tax_rate));

  IF l_DEBUG in ('Y', 'C') THEN
       cep_standard.debug('end call ARP_CASHBOOK.ins_misc_txn ');
       cep_standard.debug('X_cr_id = '|| X_cr_id);

  END IF;

  -- set this in the form mo_global.set_policy_context('M',null);
  --
  -- Check the status of the newly created receipt, and not to cleared
  -- it if it was created with Cleared status
  --
  BEGIN
    SELECT      arh.status, arh.cash_receipt_history_id
    INTO        l_status, cash_receipt_history_id
    FROM        ar_cash_receipt_history_all arh --ar_cash_receipt_history arh
    WHERE       arh.cash_receipt_id = X_cr_id   AND
                arh.current_record_flag = 'Y';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        l_status := 'REMITTED';
  END;
  if (CE_AUTO_BANK_MATCH.trx_status <> 'REVERSED') then
    CE_AUTO_BANK_MATCH.trx_status := l_status;
    CE_AUTO_BANK_MATCH.trx_id := cash_receipt_history_id;
  end if;
  --
  -- Clear and Match the newly created receipt
  --
  IF (X_passin_mode NOT IN ('MANUAL_NO_REC','AUTO_TRX')) THEN
    IF (l_status not in ('CLEARED', 'RISK_ELIMINATED'))THEN
      ARP_CASHBOOK.clear(X_cr_id,
                        to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
                        to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
			to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
                        to_date(to_char(CE_AUTO_BANK_CLEAR.G_exchange_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
                        CE_AUTO_BANK_CLEAR.G_exchange_rate_type,
                        CE_AUTO_BANK_CLEAR.G_exchange_rate,
                        CE_AUTO_BANK_MATCH.aba_bank_currency,
                        X_bank_account_amount,
                        0,
                        X_module_name,
                        '1.0',
                        cash_receipt_history_id);
    END IF;
    CE_AUTO_BANK_MATCH.csl_reconcile_flag := 'MISC';
    CE_AUTO_BANK_CLEAR1.insert_reconciliation (
        Y_cleared_trx_type      => 'MISC',
        Y_cleared_trx_id        => cash_receipt_history_id,
        Y_ar_cash_receipt_id    => X_cr_id,
        Y_reference_status      => NULL,
        Y_auto_reconciled_flag  => 'N',
        Y_status_flag           => 'M',
	Y_amount                => X_bank_account_amount);
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_CLEAR1.misc_receipt');
  END IF;
END misc_receipt;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|    reconcile_pbatch                                                   |
|  CALLED BY                                                            |
|    reconcile_process                                                  |
 --------------------------------------------------------------------- */
PROCEDURE reconcile_pbatch (     passin_mode                    VARCHAR2,
                                 pbatch_id                      NUMBER,
                                 statement_line_id      IN OUT NOCOPY  NUMBER,
                                 gl_date                        DATE,
                                 value_date                     DATE,
                                 cleared_date                   DATE,
                                 amount_to_clear                NUMBER,
                                 errors_amount                  NUMBER,
                                 charges_amount                 NUMBER,
                                 prorate_amount                 NUMBER,
                                 exchange_rate_type             VARCHAR2,
                                 exchange_rate_date             DATE,
                                 exchange_rate                  NUMBER,
                                 trx_currency_type              VARCHAR2,
                                 X_statement_header_id  IN OUT NOCOPY  NUMBER,
                                 statement_header_date          DATE,
                                 X_trx_type                     VARCHAR2,
                                 X_bank_trx_number              VARCHAR2,
                                 X_currency_code                VARCHAR2,
                                 X_original_amount              NUMBER,
                                 X_effective_date               DATE,
                                 X_float_handling_flag          VARCHAR2,
				 X_bank_currency_code		VARCHAR2,
				 pgroup_id                      VARCHAR2 DEFAULT NULL -- FOR SEPA ER 6700007
	) IS
  check_id              AP_CHECKS_ALL.check_id%TYPE;
  check_status          CE_LOOKUPS.lookup_code%TYPE;
  amount_cleared	AP_CHECKS_ALL.cleared_amount%TYPE;
  auto_reconciled_flag  VARCHAR2(1);
  batch_trx_type	varchar2(30);
  batch_app_id		number;
  l_gt_seq_id		number := to_number(null);
  x_org_id		number;
  x_legal_entity_id	number;

BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_CLEAR1.reconcile_pbatch');
  	cep_standard.debug('passin_mode='||passin_mode );
  END IF;
  auto_reconciled_flag := 'Y';
  CE_AUTO_BANK_CLEAR1.validate_effective_date(          passin_mode,
                                                        X_effective_date,
                                                        X_float_handling_flag);
  IF (passin_mode IN ( 'MANUAL', 'MANUAL_H', 'MANUAL_C')) THEN
    --IF (statement_line_id IS NULL) THEN
    IF (statement_line_id IS NULL AND passin_mode <> 'MANUAL_C') THEN --bug 3436722
      OPEN  C_STATEMENT_LINE_SEQ;
      FETCH C_STATEMENT_LINE_SEQ INTO statement_line_id;
      CLOSE C_STATEMENT_LINE_SEQ;
    END IF;
    CE_AUTO_BANK_MATCH.csh_statement_header_id  := X_statement_header_id;
    CE_AUTO_BANK_MATCH.csh_statement_date       := statement_header_date;
    CE_AUTO_BANK_REC.G_gl_date          := gl_date;
    CE_AUTO_BANK_MATCH.csl_effective_date       := value_date;
    CE_AUTO_BANK_MATCH.csl_statement_line_id   := statement_line_id;
    CE_AUTO_BANK_MATCH.csl_exchange_rate_type   := exchange_rate_type;
    CE_AUTO_BANK_MATCH.csl_exchange_rate_date   := exchange_rate_date;
    CE_AUTO_BANK_MATCH.csl_exchange_rate        := exchange_rate;
    CE_AUTO_BANK_MATCH.csl_amount               := ABS(amount_to_clear);
    CE_AUTO_BANK_MATCH.csl_original_amount      := X_original_amount;
    CE_AUTO_BANK_MATCH.csl_charges_amount	:= charges_amount;
    CE_AUTO_BANK_MATCH.csl_currency_code        := X_currency_code;
    CE_AUTO_BANK_MATCH.csl_trx_type             := X_trx_type;
    CE_AUTO_BANK_MATCH.csl_trx_date             := cleared_date;
    CE_AUTO_BANK_MATCH.csl_bank_trx_number      := X_bank_trx_number;
    CE_AUTO_BANK_MATCH.trx_status               := NULL;
    auto_reconciled_flag                        := 'N';
    IF( passin_mode = 'MANUAL_H') THEN
      CE_AUTO_BANK_CLEAR1.create_statement_line;
      IF(X_statement_header_id IS NULL)THEN
	X_statement_header_id := CE_AUTO_BANK_MATCH.csh_statement_header_id;
      END IF;
    END IF;
  END IF;
  IF (trx_currency_type IN ('FOREIGN','BANK')) THEN
    CE_AUTO_BANK_CLEAR.G_exchange_rate_type     := CE_AUTO_BANK_MATCH.csl_exchange_rate_type;
    CE_AUTO_BANK_CLEAR.G_exchange_date  := CE_AUTO_BANK_MATCH.csl_exchange_rate_date;
    CE_AUTO_BANK_CLEAR.G_exchange_rate  := CE_AUTO_BANK_MATCH.csl_exchange_rate;
  ELSE
    CE_AUTO_BANK_CLEAR.G_exchange_rate_type     := NULL;
    CE_AUTO_BANK_CLEAR.G_exchange_date  := NULL;
    CE_AUTO_BANK_CLEAR.G_exchange_rate  := NULL;
  END IF;
  ------------------------------------------------------------------------
  IF (passin_mode <> 'MANUAL_C' ) THEN --bug 3436722
    -- bug 5350073 ce_available_transactions_tmp is not populated when
    --             manually reconcile IBY batches
    IF (passin_mode = 'AUTO' ) THEN
      cep_standard.debug('open pbatch_cursor');

      OPEN pbatch_cursor(pbatch_id, pgroup_id );-- FOR SEPA ER 6700007
      LOOP
        FETCH pbatch_cursor INTO check_id, check_status, batch_trx_type, batch_app_id, l_gt_seq_id;
        EXIT WHEN pbatch_cursor%NOTFOUND OR pbatch_cursor%NOTFOUND IS NULL;

        -- mark the transaction in ce_available_transactions_tmp as reconciled
/*
        IF l_gt_seq_id is not null THEN
          update ce_available_transactions_tmp
          set    reconciled_status_flag = 'Y'
          where  seq_id = l_gt_seq_id;
        END IF;
*/
      IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('batch_trx_type='||batch_trx_type ||
				', check_id='||check_id||',check_status='||check_status );
   	cep_standard.debug('batch_app_id='||batch_app_id||', l_gt_seq_id='||l_gt_seq_id);
 	cep_standard.debug('call CE_AUTO_BANK_CLEAR1.insert_reconciliation');
      END IF;
      CE_AUTO_BANK_CLEAR1.insert_reconciliation (
        Y_cleared_trx_type              => batch_trx_type, -- 'PAYMENT',
        Y_cleared_trx_id                => check_id,
        Y_ar_cash_receipt_id            => NULL,
        Y_reference_status              => check_status,
        Y_auto_reconciled_flag          => auto_reconciled_flag,
        Y_status_flag                   => 'M');

        -- mark the transaction in ce_available_transactions_tmp as reconciled
        IF l_gt_seq_id is not null THEN
          CE_AUTO_BANK_MATCH.update_gt_reconciled_status (l_gt_seq_id, 'Y');
        END IF;

      END LOOP; -- pbatch_cursor
      CLOSE pbatch_cursor;
    ELSE -- manual reconciliation
      cep_standard.debug('open manual_pbatch_cursor ');

      OPEN manual_pbatch_cursor(pbatch_id, pgroup_id );-- FOR SEPA ER 6700007
      LOOP
        FETCH manual_pbatch_cursor
        INTO check_id, check_status, batch_trx_type, batch_app_id,
	     x_org_id, x_legal_entity_id;
        EXIT WHEN manual_pbatch_cursor%NOTFOUND OR manual_pbatch_cursor%NOTFOUND IS NULL;

      IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('batch_trx_type='||batch_trx_type ||
				', check_id='||check_id||',check_status='||check_status );
   	cep_standard.debug('batch_app_id='||batch_app_id);
 	cep_standard.debug('call CE_AUTO_BANK_CLEAR1.insert_reconciliation');
      END IF;
      CE_AUTO_BANK_MATCH.trx_org_id := x_org_id;
      CE_AUTO_BANK_MATCH.trx_legal_entity_id := x_legal_entity_id;
      CE_AUTO_BANK_CLEAR1.insert_reconciliation (
        Y_cleared_trx_type              => batch_trx_type, -- 'PAYMENT',
        Y_cleared_trx_id                => check_id,
        Y_ar_cash_receipt_id            => NULL,
        Y_reference_status              => check_status,
        Y_auto_reconciled_flag          => auto_reconciled_flag,
        Y_status_flag                   => 'M');

      END LOOP; -- manual_pbatch_cursor
      CLOSE manual_pbatch_cursor;
    END IF;
  END IF; --(passin_mode <> 'MANUAL_C' )

  ------------------------------------------------------------------------

/*
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('reconcile_pbatch: ' || '>>>AP_RECONCILIATION_PKG.recon_payment_history'|| chr(10) ||
  	'X_CHECKRUN_ID: '||to_char(pbatch_id)|| chr(10) ||
	'pgroup_id: '||to_char(pgroup_id)|| chr(10) ||
  	'X_ACCOUNTING_DATE: '||CE_AUTO_BANK_REC.G_gl_date|| chr(10) ||
  	'X_CLEARED_DATE: '||CE_AUTO_BANK_MATCH.csl_trx_date|| chr(10) ||
  	'X_TRANSACTION_AMOUNT: '||to_char(amount_to_clear)|| chr(10) ||
  	'X_ERROR_AMOUNT: '||to_char(errors_amount)|| chr(10) ||
  	'X_CHARGE_AMOUNT: '||to_char(charges_amount)|| chr(10) ||
  	'X_CURRENCY_CODE: '||X_currency_code|| chr(10) ||
  	'X_BANK_CURRENCY_CODE: '||X_bank_currency_code|| chr(10) ||
  	'X_EXCHANGE_RATE_TYPE: '||CE_AUTO_BANK_CLEAR.G_exchange_rate_type|| chr(10) ||
  	'X_EXCHANGE_RATE_DATE: '||CE_AUTO_BANK_CLEAR.G_exchange_date|| chr(10) ||
  	'X_EXCHANGE_RATE: '||to_char(CE_AUTO_BANK_CLEAR.G_exchange_rate)|| chr(10) ||
  	'X_ACTUAL_VALUE_DATE: '||CE_AUTO_BANK_MATCH.csl_effective_date);
  END IF;
*/
------------------------------------------------------------------------------
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('pbatch_id='||pbatch_id||', CE_AUTO_BANK_REC.G_gl_date='||to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD')||
			', CE_AUTO_BANK_MATCH.csl_trx_date='||to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'));

    cep_standard.debug('amount_to_clear='||NVL(amount_to_clear,0)||', errors_amount='||NVL(errors_amount,0)||
			', charges_amount='||NVL(charges_amount,0)||', X_bank_currency_code='||X_bank_currency_code);

    cep_standard.debug('CE_AUTO_BANK_CLEAR.G_exchange_rate_type='||CE_AUTO_BANK_CLEAR.G_exchange_rate_type||
			', CE_AUTO_BANK_CLEAR.G_exchange_date='||to_date(to_char(CE_AUTO_BANK_CLEAR.G_exchange_date,'YYYY/MM/DD'),'YYYY/MM/DD') ||
			', CE_AUTO_BANK_CLEAR.G_exchange_rate='||CE_AUTO_BANK_CLEAR.G_exchange_rate);

    cep_standard.debug('CE_AUTO_BANK_MATCH.csl_effective_date='||to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD')||
			', passin_mode='||passin_mode ||', statement_line_id='||statement_line_id);

   END IF;

  --check if pbatch_id is a AP batch or IBY batch
  if (batch_app_id = 200) THEN
    cep_standard.debug('call AP_RECONCILIATION_PKG.recon_payment_history');

    AP_RECONCILIATION_PKG.recon_payment_history(
	X_CHECKRUN_ID           => pbatch_id,
  	X_CHECK_ID              => to_number(NULL),
  	X_ACCOUNTING_DATE       => to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
  	X_CLEARED_DATE          => to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
  	X_TRANSACTION_AMOUNT    => NVL(amount_to_clear,0),
  	X_TRANSACTION_TYPE      => 'PAYMENT CLEARING',
	X_ERROR_AMOUNT          => NVL(errors_amount,0),
  	X_CHARGE_AMOUNT         => NVL(charges_amount,0),
  	X_CURRENCY_CODE         => X_bank_currency_code,
  	X_EXCHANGE_RATE_TYPE    => CE_AUTO_BANK_CLEAR.G_exchange_rate_type,
  	X_EXCHANGE_RATE_DATE    => to_date(to_char(CE_AUTO_BANK_CLEAR.G_exchange_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
  	X_EXCHANGE_RATE         => CE_AUTO_BANK_CLEAR.G_exchange_rate,
  	X_MATCHED_FLAG          => 'Y',
	X_ACTUAL_VALUE_DATE     =>
				to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
  	X_LAST_UPDATE_DATE      => sysdate,
  	X_LAST_UPDATED_BY       => NVL(FND_GLOBAL.user_id,-1),
  	X_LAST_UPDATE_LOGIN     => NVL(FND_GLOBAL.user_id,-1),
  	X_CREATED_BY            => NVL(FND_GLOBAL.user_id,-1),
  	X_CREATION_DATE         => sysdate,
  	X_PROGRAM_UPDATE_DATE   => sysdate,
  	X_PROGRAM_APPLICATION_ID=> NVL(FND_GLOBAL.prog_appl_id,-1),
  	X_PROGRAM_ID            => NVL(FND_GLOBAL.conc_program_id,-1),
  	X_REQUEST_ID            => NVL(FND_GLOBAL.conc_request_id,-1),
  	X_CALLING_SEQUENCE      => 'CE_AUTO_BANK_CLEAR1.reconcile_pbatch '
        );
    IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('reconcile_pbatch: ' || '<<<AP_RECONCILIATION_PKG.recon_payment_history');
    END IF;

  else --IBY batches

    cep_standard.debug('call IBY_CE_BATCH_RECON_PKG.Payment_Instruction_Clearing');
    IBY_CE_BATCH_RECON_PKG.Payment_Instruction_Clearing(
        P_PAYMENT_INSTRUCTION_ID  => pbatch_id,
        P_ACCOUNTING_DATE         => to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
        P_CLEARED_DATE            => to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
        P_TRANSACTION_AMOUNT      => NVL(amount_to_clear,0),     -- in bank curr.
        P_ERROR_AMOUNT            => NVL(errors_amount,0),     -- in bank curr.
        P_CHARGE_AMOUNT           => NVL(charges_amount,0),     -- in bank curr.
        P_CURRENCY_CODE           => X_bank_currency_code,    -- bank curr. code
        P_EXCHANGE_RATE_TYPE      => CE_AUTO_BANK_CLEAR.G_exchange_rate_type,   -- between payment and functional
        P_EXCHANGE_RATE_DATE      => to_date(to_char(CE_AUTO_BANK_CLEAR.G_exchange_date,'YYYY/MM/DD'),'YYYY/MM/DD'), -- between payment and functional
        P_EXCHANGE_RATE           => CE_AUTO_BANK_CLEAR.G_exchange_rate,     -- between payment and functional
        P_MATCHED_FLAG            => 'Y',
        P_ACTUAL_VALUE_DATE       => to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
   	P_PASSIN_MODE             =>  passin_mode  ,
   	P_STATEMENT_LINE_ID       =>  statement_line_id  ,
   	P_STATEMENT_LINE_TYPE     =>  null,
        P_LAST_UPDATE_DATE        => sysdate,
        P_LAST_UPDATED_BY         => NVL(FND_GLOBAL.user_id,-1),
        P_LAST_UPDATE_LOGIN       => NVL(FND_GLOBAL.user_id,-1),
        P_CREATED_BY              => NVL(FND_GLOBAL.user_id,-1),
        P_CREATION_DATE           => sysdate,
        P_PROGRAM_UPDATE_DATE     => sysdate,
        P_PROGRAM_APPLICATION_ID  => NVL(FND_GLOBAL.prog_appl_id,-1),
        P_PROGRAM_ID              => NVL(FND_GLOBAL.conc_program_id,-1),
        P_REQUEST_ID              => NVL(FND_GLOBAL.conc_request_id,-1),
        P_CALLING_SEQUENCE        => 'CE_AUTO_BANK_CLEAR1.reconcile_pbatch',
	P_LOGICAL_GROUP_REFERENCE => pgroup_id);-- FOR SEPA ER 6700007

    cep_standard.debug('end call IBY_CE_BATCH_RECON_PKG.Payment_Instruction_Clearing');

  end if;
------------------------------------
  IF (passin_mode <> 'MANUAL_C' ) THEN --bug 3436677
    IF l_DEBUG in ('Y', 'C') THEN
       	cep_standard.debug('update ce_statement_reconcils_all');
    END IF;
    --update ce_statement_reconciliations r
    update ce_statement_reconcils_all r
    set    amount =
	(select DECODE(c.currency_code,
                X_bank_currency_code, c.cleared_amount,
                nvl(c.cleared_base_amount, c.cleared_amount*CE_AUTO_BANK_CLEAR.G_exchange_rate))
         from ap_checks_all c
         where c.check_id = r.reference_id)
    where  statement_line_id = CE_AUTO_BANK_MATCH.csl_statement_line_id
    and    reference_type = 'PAYMENT'
    and    status_flag = 'M'
    and    current_record_flag = 'Y'
    and    amount is null;
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_CLEAR1.reconcile_pbatch');
  END IF;
EXCEPTION
        WHEN OTHERS THEN
            cep_standard.debug('Exception: CE_AUTO_BANK_CLEAR1.reconcile_pbatch');
            if (passin_mode = 'AUTO') then
              IF pbatch_cursor%ISOPEN THEN
                 CLOSE pbatch_cursor;
              END IF;
            else
              IF manual_pbatch_cursor%ISOPEN THEN
                 CLOSE manual_pbatch_cursor;
              END IF;
            end if;
            RAISE;
END reconcile_pbatch;

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
                         X_effective_date               DATE,
                         X_float_handling_flag          VARCHAR2,
                         X_currency_code                VARCHAR2,
                         X_bank_trx_number              VARCHAR2,
                         X_reversed_receipt_flag        VARCHAR2) IS
  cleared_trx_type      CE_LOOKUPS.lookup_code%TYPE;
  cleared_trx_id        CE_STATEMENT_RECONCILS_ALL.reference_id%TYPE;
  clearing_flag         VARCHAR2(1) := 'N';
  clearing_sign		NUMBER;
  x_trx_id              NUMBER;
  x_trx_amount          NUMBER;
  x_trx_amount2         NUMBER;
  x_trx_amount3         NUMBER;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_CLEAR1.reconcile_stmt, passin_mode = '||passin_mode  );
  END IF;
  IF (passin_mode <> 'MANUAL_C') THEN
    clearing_flag := 'Y';
    CE_AUTO_BANK_CLEAR1.validate_effective_date(        passin_mode,
                                                        X_effective_date,
                                                        X_float_handling_flag);
  END IF;
  IF (passin_mode IN ('MANUAL_L','MANUAL_C')) THEN
    IF (X_statement_line_id IS NULL AND passin_mode <> 'MANUAL_C') THEN
      OPEN C_STATEMENT_LINE_SEQ;
      FETCH C_STATEMENT_LINE_SEQ INTO X_statement_line_id;
      CLOSE C_STATEMENT_LINE_SEQ;
    END IF;
    CE_AUTO_BANK_MATCH.csl_trx_type             := tx_type;
    CE_AUTO_BANK_MATCH.csh_statement_header_id := X_statement_header_id;
 -- CE_AUTO_BANK_MATCH.csh_statement_date       := X_statement_header_date;
    CE_AUTO_BANK_MATCH.aba_bank_currency        := X_bank_currency;
    CE_AUTO_BANK_REC.G_gl_date                  := gl_date;
    CE_AUTO_BANK_MATCH.csl_effective_date	:= value_date;
    CE_AUTO_BANK_MATCH.csl_exchange_rate_type   := exchange_rate_type;
    CE_AUTO_BANK_MATCH.csl_exchange_rate_date   := exchange_date;
    CE_AUTO_BANK_MATCH.csl_exchange_rate        := exchange_rate;
    CE_AUTO_BANK_MATCH.csl_trx_date             := cleared_date;
    CE_AUTO_BANK_MATCH.csl_statement_line_id    := X_statement_line_id;
    CE_AUTO_BANK_MATCH.csl_reconcile_flag       := receipt_type;
    CE_AUTO_BANK_MATCH.csl_match_type           := tx_type;
    CE_AUTO_BANK_MATCH.csl_amount               := amount_cleared;
    CE_AUTO_BANK_MATCH.csl_trx_type             := tx_type;
    CE_AUTO_BANK_MATCH.trx_id                   := trx_id;
    CE_AUTO_BANK_MATCH.trx_status               := trx_status;
    CE_AUTO_BANK_MATCH.csl_currency_code        := X_currency_code;
 -- CE_AUTO_BANK_MATCH.csl_original_amount     := X_original_amount;
    CE_AUTO_BANK_MATCH.csl_bank_trx_number      := X_bank_trx_number;
    CE_AUTO_BANK_MATCH.reversed_receipt_flag    := X_reversed_receipt_flag;
    IF (passin_mode = 'MANUAL_C' ) THEN
      CE_AUTO_BANK_MATCH.csl_trx_date := sysdate;
    END IF;
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('CE_AUTO_BANK_MATCH.csl_trx_type ='|| CE_AUTO_BANK_MATCH.csl_trx_type ||
			   ', CE_AUTO_BANK_MATCH.reversed_receipt_flag = ' ||CE_AUTO_BANK_MATCH.reversed_receipt_flag);
  	cep_standard.debug('CE_AUTO_BANK_MATCH.csl_match_correction_type =' || CE_AUTO_BANK_MATCH.csl_match_correction_type ||
			   ', CE_AUTO_BANK_MATCH.reconciled_this_run = '|| CE_AUTO_BANK_MATCH.reconciled_this_run);
  END IF;


  IF (trx_currency_type IN ('FOREIGN','BANK')) THEN
    CE_AUTO_BANK_CLEAR.G_exchange_rate_type    := CE_AUTO_BANK_MATCH.csl_exchange_rate_type;
    CE_AUTO_BANK_CLEAR.G_exchange_date  := CE_AUTO_BANK_MATCH.csl_exchange_rate_date;
    CE_AUTO_BANK_CLEAR.G_exchange_rate  := CE_AUTO_BANK_MATCH.csl_exchange_rate;
  ELSE
    CE_AUTO_BANK_CLEAR.G_exchange_rate_type    := NULL;
    CE_AUTO_BANK_CLEAR.G_exchange_date  := NULL;
    CE_AUTO_BANK_CLEAR.G_exchange_rate  := NULL;
  END IF;
  if (passin_mode = 'AUTO') then
    if (CE_AUTO_BANK_MATCH.csl_match_correction_type = 'ADJUSTMENT' AND
        CE_AUTO_BANK_MATCH.reconciled_this_run is NULL) then
       if (CE_AUTO_BANK_MATCH.trx_match_type IN ('CASH', 'MISC')) then
         cleared_trx_type := CE_AUTO_BANK_MATCH.csl_match_type;
         --
         -- when reconcile the original receipt which has been reversed
         -- only perform the reconciliation process and skip the call to
         -- any AR packages
         --
         IF (CE_AUTO_BANK_MATCH.reversed_receipt_flag = 'Y'
		OR (trx_status IN ('RISK_ELIMINATED', 'CLEARED'))) THEN
 	      cleared_trx_id := CE_AUTO_BANK_MATCH.trx_id;
              --
              -- bug 922650
              -- update actual_value_date in AR_CASH_RECEIPS table.
	      --
		IF l_DEBUG in ('Y', 'C') THEN
	  	  cep_standard.debug('call ARP_CASHBOOK.update_actual_value_date');
		END IF;

	      ARP_CASHBOOK.update_actual_value_date(to_number(ar_cash_receipt_id),
				to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'));
	 ELSE
	   IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('reconcile_stmt: ' || 'RECEIPT: amount_cleared = '|| to_char(amount_cleared)||
			'RECEIPT: charges_amount = '|| to_char(charges_amount));
	   END IF;
	    if (CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_DEBIT') then
		clearing_sign := -1;
	    else
		clearing_sign := 1;
	    end if;
            cleared_trx_type := 'RECEIPT';
            IF l_DEBUG in ('Y', 'C') THEN
              cep_standard.debug('call ARP_CASHBOOK.clear');
            END IF;
            ARP_CASHBOOK.clear(
            p_cr_id              => to_number(ar_cash_receipt_id),
            p_trx_date           => to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
            p_gl_date            => to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
	    p_actual_value_date  => to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
            p_exchange_date    => to_date(to_char(CE_AUTO_BANK_CLEAR.G_exchange_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
            p_exchange_rate_type => CE_AUTO_BANK_CLEAR.G_exchange_rate_type,
            p_exchange_rate      => CE_AUTO_BANK_CLEAR.G_exchange_rate,
            p_bank_currency      => CE_AUTO_BANK_MATCH.aba_bank_currency,
            p_amount_cleared     => amount_cleared * clearing_sign,
            p_amount_factored    => charges_amount,
            p_module_name        => 'CE_AUTO_BANK_REC',
            p_module_version     => '1.0',
            p_crh_id             => cleared_trx_id );
         END IF;
       elsif (CE_AUTO_BANK_MATCH.trx_match_type = 'PAYMENT') then
         IF( trx_status NOT IN ( 'STOP INITIATED', 'VOIDED' )) THEN
	   IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('reconcile_stmt: ' || 'PAYMENT: amount_cleared = '|| to_char(amount_cleared)||
			'PAYMENT: charges_amount = '|| to_char(charges_amount));
	   END IF;
	   if (CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_CREDIT') then
                clearing_sign := -1;
           else
                clearing_sign := 1;
           end if;
           if (passin_mode = 'AUTO') then
             if (CE_AUTO_BANK_MATCH.trx_gl_date is not null) then
                CE_AUTO_BANK_REC.G_gl_date := CE_AUTO_BANK_MATCH.trx_gl_date;
             end if;
             if (CE_AUTO_BANK_MATCH.trx_cleared_date is not null) then
                CE_AUTO_BANK_MATCH.csl_trx_date :=
                       CE_AUTO_BANK_MATCH.trx_cleared_date;
             end if;
           end if;

     	   IF l_DEBUG in ('Y', 'C') THEN
  	     cep_standard.debug('reconcile_stmt: ' || '>>>AP_RECONCILIATION_PKG.recon_payment_history'||
  		'X_CHECK_ID: '||to_char(CE_AUTO_BANK_MATCH.trx_id)||
  		'X_ACCOUNTING_DATE: '||CE_AUTO_BANK_REC.G_gl_date);
	     cep_standard.debug('X_CLEARED_DATE: '||CE_AUTO_BANK_MATCH.csl_trx_date||
  		'X_TRANSACTION_AMOUNT: '||to_char(amount_cleared*clearing_sign)||
  		'X_ERROR_AMOUNT: '||to_char(errors_amount)||
  		'X_CHARGE_AMOUNT: '||to_char(charges_amount));
	     cep_standard.debug('X_CURRENCY_CODE: '||X_currency_code||
  		'X_EXCHANGE_RATE_TYPE: '||CE_AUTO_BANK_CLEAR.G_exchange_rate_type||
  		'X_EXCHANGE_RATE_DATE: '||CE_AUTO_BANK_CLEAR.G_exchange_date);
	     cep_standard.debug('X_EXCHANGE_RATE: '||to_char(CE_AUTO_BANK_CLEAR.G_exchange_rate)||
  		'X_ACTUAL_VALUE_DATE: '||CE_AUTO_BANK_MATCH.csl_effective_date);
  	   END IF;

           IF l_DEBUG in ('Y', 'C') THEN
             cep_standard.debug('call AP_RECONCILIATION_PKG.recon_payment_history');
           END IF;

  	   AP_RECONCILIATION_PKG.recon_payment_history(
    	     X_CHECKRUN_ID           => to_number(NULL),
             X_CHECK_ID              => CE_AUTO_BANK_MATCH.trx_id,
             X_ACCOUNTING_DATE       => CE_AUTO_BANK_REC.G_gl_date,
             X_CLEARED_DATE          => to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
             X_TRANSACTION_AMOUNT    => NVL(amount_cleared,0) * clearing_sign,
             X_TRANSACTION_TYPE      => 'PAYMENT CLEARING',
             X_ERROR_AMOUNT          => NVL(errors_amount,0),
             X_CHARGE_AMOUNT         => NVL(charges_amount,0),
             X_CURRENCY_CODE         => X_bank_currency,
             X_EXCHANGE_RATE_TYPE    => CE_AUTO_BANK_CLEAR.G_exchange_rate_type,
             X_EXCHANGE_RATE_DATE    => to_date(to_char(CE_AUTO_BANK_CLEAR.G_exchange_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
             X_EXCHANGE_RATE         => CE_AUTO_BANK_CLEAR.G_exchange_rate,
             X_MATCHED_FLAG          => clearing_flag,
             X_ACTUAL_VALUE_DATE     =>
				to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
             X_LAST_UPDATE_DATE      => sysdate,
             X_LAST_UPDATED_BY       => NVL(FND_GLOBAL.user_id,-1),
             X_LAST_UPDATE_LOGIN     => NVL(FND_GLOBAL.user_id,-1),
             X_CREATED_BY            => NVL(FND_GLOBAL.user_id,-1),
             X_CREATION_DATE         => sysdate,
             X_PROGRAM_UPDATE_DATE   => sysdate,
             X_PROGRAM_APPLICATION_ID=> NVL(FND_GLOBAL.prog_appl_id,-1),
             X_PROGRAM_ID            => NVL(FND_GLOBAL.conc_program_id,-1),
             X_REQUEST_ID            => NVL(FND_GLOBAL.conc_request_id,-1),
             X_CALLING_SEQUENCE      => 'CE_AUTO_BANK_CLEAR1.reconcile_stmt '
           );
           IF l_DEBUG in ('Y', 'C') THEN
        	cep_standard.debug('reconcile_stmt: ' || '<<<AP_RECONCILIATION_PKG.recon_payment_history');
           END IF;
           cleared_trx_id      := CE_AUTO_BANK_MATCH.trx_id;
           cleared_trx_type    := 'PAYMENT';
         END IF;
       elsif (CE_AUTO_BANK_MATCH.trx_match_type = 'PAY_LINE') then
	 if (CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_CREDIT') then
           clearing_sign := -1;
         else
           clearing_sign := 1;
         end if;
         IF l_DEBUG in ('Y', 'C') THEN
           cep_standard.debug('call PAY_CE_RECONCILIATION_PKG.reconcile_payment');
         END IF;


	 PAY_CE_RECONCILIATION_PKG.reconcile_payment (
           p_payment_id		=> CE_AUTO_BANK_MATCH.trx_id,
           p_cleared_date	=> to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
           p_trx_amount		=> NVL(amount_cleared,0) * clearing_sign,
           p_trx_type		=> 'PAY',
           p_last_updated_by    => NVL(FND_GLOBAL.user_id,-1),
           p_last_update_login  => NVL(FND_GLOBAL.user_id,-1),
           p_created_by         => NVL(FND_GLOBAL.user_id,-1) );
           cleared_trx_id      := CE_AUTO_BANK_MATCH.trx_id;
           cleared_trx_type    := 'PAY';
       end if;
    end if;
    if (CE_AUTO_BANK_MATCH.csl_match_correction_type = 'REVERSAL') then
       x_trx_id := CE_AUTO_BANK_MATCH.trx_id;
       x_trx_amount := CE_AUTO_BANK_MATCH.trx_amount;
       x_trx_amount2 := CE_AUTO_BANK_MATCH.csl_amount;
    else
       x_trx_id := CE_AUTO_BANK_MATCH.trx_id2;
       x_trx_amount := CE_AUTO_BANK_MATCH.trx_amount2;
       if (CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_CREDIT') then
         if (CE_AUTO_BANK_MATCH.trx_type2 in
                ('CREDIT', 'MISC_CREDIT')) then
            x_trx_amount2 := - x_trx_amount;
         else
            x_trx_amount2 := x_trx_amount;
         end if;
       else  /* CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_DEBIT' */
         if (CE_AUTO_BANK_MATCH.trx_type2 in
                ('DEBIT', 'MISC_DEBIT')) then
            x_trx_amount2 := - x_trx_amount;
         else
            x_trx_amount2 := x_trx_amount;
         end if;
       end if;
       IF l_DEBUG in ('Y', 'C') THEN
       	cep_standard.debug('reconcile_stmt: ' || 'DEBUG: trx_type2 = '|| CE_AUTO_BANK_MATCH.trx_type2||
	       	' x_trx_amount = '|| x_trx_amount||' x_trx_amount2 = '|| x_trx_amount2);
       END IF;
    end if;
    -- Need to calculate cleared amount, x_amount_cleared, here.
    IF l_DEBUG in ('Y', 'C') THEN
       	cep_standard.debug('update ce_statement_reconcils_all');
    END IF;
    --update ce_statement_reconciliations
    update ce_statement_reconcils_all
    set current_record_flag = 'N'
    where statement_line_id in
          (x_trx_id, CE_AUTO_BANK_MATCH.csl_statement_line_id)
    and reference_type = tx_type
    and nvl(current_record_flag, 'N') = 'Y'
    and nvl(request_id, -999) <> nvl(FND_GLOBAL.conc_request_id,-1);

    CE_AUTO_BANK_CLEAR1.insert_reconciliation (
           Y_statement_line_id     => x_trx_id,
           Y_cleared_trx_type      => 'STATEMENT',
           Y_cleared_trx_id        => CE_AUTO_BANK_MATCH.csl_statement_line_id,
           Y_ar_cash_receipt_id    => to_number(NULL),
           Y_reference_status      => reference_status,
           Y_auto_reconciled_flag  => auto_reconciled_flag,
           Y_status_flag           => 'M',
           Y_amount                => x_trx_amount );

    CE_AUTO_BANK_CLEAR1.insert_reconciliation (
           Y_statement_line_id     => CE_AUTO_BANK_MATCH.csl_statement_line_id,
           Y_cleared_trx_type      => 'STATEMENT',
           Y_cleared_trx_id        => x_trx_id,
           Y_ar_cash_receipt_id    => to_number(NULL),
           Y_reference_status      => reference_status,
           Y_auto_reconciled_flag  => auto_reconciled_flag,
           Y_status_flag           => 'M',
           Y_amount                => x_trx_amount2);

    if (CE_AUTO_BANK_MATCH.csl_match_correction_type = 'ADJUSTMENT') then

	-- bug 3252844 reconciled amount is duplicated because the
	--             the reconciled PAYMENT amount is negative on
	--		CE_STATEMENT_RECONCILS_ALL

    	x_trx_amount3 := CE_AUTO_BANK_MATCH.corr_csl_amount;

    	if (CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_CREDIT') then
          if (CE_AUTO_BANK_MATCH.trx_match_type = 'PAYMENT') then
            x_trx_amount3 :=
                -1 * CE_AUTO_BANK_MATCH.corr_csl_amount;
          end if;
    	/*elsif  (CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_DEBIT') then
          if (CE_AUTO_BANK_MATCH.trx_match_type = 'CASH') then
            x_trx_amount3 :=
                -1 * CE_AUTO_BANK_MATCH.corr_csl_amount;
          end if;*/
    	end if;

       IF l_DEBUG in ('Y', 'C') THEN
       	 cep_standard.debug('reconcile_stmt: DEBUG: x_trx_amount3 = '|| x_trx_amount3
			||', CE_AUTO_BANK_MATCH.csl_trx_type: ' ||CE_AUTO_BANK_MATCH.csl_trx_type
			||', CE_AUTO_BANK_MATCH.trx_match_type: ' ||CE_AUTO_BANK_MATCH.trx_match_type);
       END IF;

       if (CE_AUTO_BANK_MATCH.reconciled_this_run is NULL) then
         CE_AUTO_BANK_CLEAR1.insert_reconciliation (
           Y_statement_line_id     => CE_AUTO_BANK_MATCH.csl_statement_line_id,
           Y_cleared_trx_type      => cleared_trx_type,
           Y_cleared_trx_id        => cleared_trx_id,
           Y_ar_cash_receipt_id    => ar_cash_receipt_id,
           Y_reference_status      => reference_status,
           Y_auto_reconciled_flag  => auto_reconciled_flag,
           Y_status_flag           => 'M',
           Y_amount                => x_trx_amount3);
           --Y_amount                => CE_AUTO_BANK_MATCH.corr_csl_amount);
        else    /* CE_AUTO_BANK_MATCH.reconciled_this_run = 'Y' */
    	  IF l_DEBUG in ('Y', 'C') THEN
       		cep_standard.debug('update ce_statement_reconcils_all');
	  END IF;
           --update ce_statement_reconciliations
	   update ce_statement_reconcils_all
           set    statement_line_Id = CE_AUTO_BANK_MATCH.csl_statement_line_id,
                  amount = x_trx_amount3
                  --amount = CE_AUTO_BANK_MATCH.corr_csl_amount
           where  statement_line_id = x_trx_id
           and    reference_type <> 'STATEMENT'
           and    reference_id = CE_AUTO_BANK_MATCH.trx_id
           and    nvl(request_id,-999) = nvl(FND_GLOBAL.conc_request_id,-1);
        end if;
    end if;
  elsif (passin_mode <> 'MANUAL_C') then
    CE_AUTO_BANK_MATCH.reconcile_to_statement_flag := 'Y';

    -- bug# 1189554
    x_trx_amount2 := CE_AUTO_BANK_MATCH.csl_amount;

    if (X_statement_line_type = 'MISC_CREDIT') then
        if (tx_type in ('CREDIT', 'MISC_CREDIT')) then
           x_trx_amount2 :=
                -1 * CE_AUTO_BANK_MATCH.csl_amount;
        end if;
    else        /* X_statement_line_type = 'MISC_DEBIT' */
        if (tx_type in ('DEBIT', 'MISC_DEBIT')) then
           x_trx_amount2 :=
                -1 * CE_AUTO_BANK_MATCH.csl_amount;
        end if;
    end if;

    CE_AUTO_BANK_CLEAR1.insert_reconciliation (
        Y_statement_line_id     => CE_AUTO_BANK_MATCH.trx_id,
        Y_cleared_trx_type      => 'STATEMENT',
        Y_cleared_trx_id        => CE_AUTO_BANK_MATCH.csl_statement_line_id,
        Y_ar_cash_receipt_id    => ar_cash_receipt_id,
        Y_reference_status      => reference_status,
        Y_auto_reconciled_flag  => auto_reconciled_flag,
        Y_status_flag           => 'M',
        Y_amount                => CE_AUTO_BANK_MATCH.csl_amount);

    CE_AUTO_BANK_CLEAR.update_line_status(
           CE_AUTO_BANK_MATCH.trx_id,'RECONCILED');

    CE_AUTO_BANK_CLEAR1.insert_reconciliation (
        Y_statement_line_id     => CE_AUTO_BANK_MATCH.csl_statement_line_id,
        Y_cleared_trx_type      => 'STATEMENT',
        Y_cleared_trx_id        => CE_AUTO_BANK_MATCH.trx_id,
        Y_ar_cash_receipt_id    => ar_cash_receipt_id,
        Y_reference_status      => reference_status,
        Y_auto_reconciled_flag  => auto_reconciled_flag,
        Y_status_flag           => 'M',
        Y_amount                => x_trx_amount2);

    CE_AUTO_BANK_CLEAR.update_line_status(
	CE_AUTO_BANK_MATCH.csl_statement_line_id, 'RECONCILED');
  end if;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_CLEAR1.reconcile_stmt');
  END IF;
END reconcile_stmt;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       reconcile_trx                                                   |
|  CALLED BY                                                            |
|       reconcile_process                                               |
 --------------------------------------------------------------------- */
PROCEDURE reconcile_trx( passin_mode                    VARCHAR2,
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
                         X_statement_header_date        DATE,
                         X_bank_trx_number              VARCHAR2,
                         X_currency_code                VARCHAR2,
                         X_original_amount              NUMBER,
                         X_effective_date               DATE,
                         X_float_handling_flag          VARCHAR2,
                         X_reversed_receipt_flag        VARCHAR2,
	                 X_org_id		       	NUMBER 	DEFAULT NULL,
        	         X_legal_entity_id       	NUMBER 	DEFAULT NULL) IS
  cleared_trx_type      CE_LOOKUPS.lookup_code%TYPE;
  cleared_trx_id        CE_STATEMENT_RECONCILS_ALL.reference_id%TYPE;
  clearing_flag         VARCHAR2(1) := 'N';
  X_RESULT	        VARCHAR2(100);
  X_RECONCILED_METHOD   VARCHAR2(1);
  current_org_id		NUMBER;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_CLEAR1.reconcile_trx '||
  	', CE_AUTO_BANK_CLEAR1.csl_reconcile_flag = '||CE_AUTO_BANK_MATCH.csl_reconcile_flag);
  END IF;

  IF (X_org_id is not null or X_legal_entity_id is not null) THEN
    --CE_AUTO_BANK_REC.G_org_id := X_org_id;
    --CE_AUTO_BANK_REC.G_legal_entity_id :=  X_legal_entity_id;
    CE_AUTO_BANK_CLEAR.G_org_id := X_org_id;
    CE_AUTO_BANK_CLEAR.G_legal_entity_id :=  X_legal_entity_id;
  END IF;

--fnd_message.debug('CE_AUTO_BANK_REC.G_org_id = '||CE_AUTO_BANK_REC.G_org_id);

  IF (passin_mode <> 'MANUAL_C') THEN
    clearing_flag := 'Y';
    CE_AUTO_BANK_CLEAR1.validate_effective_date(        passin_mode,
                                                        X_effective_date,
                                                        X_float_handling_flag);
  END IF;
  IF (passin_mode IN ('MANUAL_H','MANUAL_L','MANUAL_C')) THEN
    IF (X_statement_line_id IS NULL AND passin_mode <> 'MANUAL_C') THEN
      OPEN C_STATEMENT_LINE_SEQ;
      FETCH C_STATEMENT_LINE_SEQ INTO X_statement_line_id;
      CLOSE C_STATEMENT_LINE_SEQ;
    END IF;
    CE_AUTO_BANK_MATCH.csl_trx_type             := tx_type;
    CE_AUTO_BANK_MATCH.csh_statement_header_id 	:= X_statement_header_id;
    CE_AUTO_BANK_MATCH.csh_statement_date       := X_statement_header_date;
    CE_AUTO_BANK_MATCH.aba_bank_currency        := X_bank_currency;
    CE_AUTO_BANK_REC.G_gl_date          	:= gl_date;
    CE_AUTO_BANK_MATCH.csl_exchange_rate_type   := exchange_rate_type;
    CE_AUTO_BANK_MATCH.csl_exchange_rate_date   := exchange_date;
    CE_AUTO_BANK_MATCH.csl_exchange_rate        := exchange_rate;
    CE_AUTO_BANK_MATCH.csl_trx_date             := cleared_date;
    CE_AUTO_BANK_MATCH.csl_effective_date	:= value_date;
    CE_AUTO_BANK_MATCH.csl_statement_line_id    := X_statement_line_id;
    CE_AUTO_BANK_MATCH.csl_reconcile_flag       := receipt_type;
    CE_AUTO_BANK_MATCH.csl_match_type           := tx_type;
    CE_AUTO_BANK_MATCH.csl_amount               := amount_cleared;
    CE_AUTO_BANK_MATCH.trx_id                   := trx_id;
    CE_AUTO_BANK_MATCH.trx_status               := trx_status;
    CE_AUTO_BANK_MATCH.csl_currency_code        := X_currency_code;
    CE_AUTO_BANK_MATCH.csl_original_amount     := X_original_amount;
    CE_AUTO_BANK_MATCH.csl_charges_amount	:= charges_amount;
    CE_AUTO_BANK_MATCH.csl_bank_trx_number      := X_bank_trx_number;
    CE_AUTO_BANK_MATCH.reversed_receipt_flag    := X_reversed_receipt_flag;
    IF (passin_mode = 'MANUAL_H' ) THEN
      CE_AUTO_BANK_CLEAR1.create_statement_line;
      IF(X_statement_header_id IS NULL)THEN
	X_statement_header_id := CE_AUTO_BANK_MATCH.csh_statement_header_id;
      END IF;
    END IF;
    IF (passin_mode = 'MANUAL_C' ) THEN
      CE_AUTO_BANK_MATCH.csl_trx_date := cleared_date;
    END IF;
  END IF;
  IF (trx_currency_type IN ('FOREIGN','BANK')) THEN
    CE_AUTO_BANK_CLEAR.G_exchange_rate_type    := CE_AUTO_BANK_MATCH.csl_exchange_rate_type;
    CE_AUTO_BANK_CLEAR.G_exchange_date  := CE_AUTO_BANK_MATCH.csl_exchange_rate_date;
    CE_AUTO_BANK_CLEAR.G_exchange_rate  := CE_AUTO_BANK_MATCH.csl_exchange_rate;
  ELSE
    CE_AUTO_BANK_CLEAR.G_exchange_rate_type    := NULL;
    CE_AUTO_BANK_CLEAR.G_exchange_date  := NULL;
    CE_AUTO_BANK_CLEAR.G_exchange_rate  := NULL;
  END IF;
  IF(CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'OI' and
	 CE_AUTO_BANK_MATCH.csl_clearing_trx_type = 'XTR_LINE') THEN
	 CE_AUTO_BANK_MATCH.csl_reconcile_flag := 'XTR_LINE';
  END IF;
  IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type = 'CASHFLOW') THEN
	 CE_AUTO_BANK_MATCH.csl_reconcile_flag := 'CASHFLOW';
  END IF;
  IF (CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'OI') THEN
    CE_999_PKG.clear(
        X_trx_id                => CE_AUTO_BANK_MATCH.trx_id,
        X_trx_type              => CE_AUTO_BANK_MATCH.csl_match_type,
        X_status                => nvl(CE_AUTO_BANK_REC.G_open_interface_clear_status,
				       CE_AUTO_BANK_MATCH.trx_status),
        X_trx_number            => CE_AUTO_BANK_MATCH.csl_bank_trx_number,
        X_trx_date              => CE_AUTO_BANK_MATCH.csl_trx_date,
        X_trx_currency          => CE_AUTO_BANK_MATCH.csl_currency_code,
        X_gl_date               => CE_AUTO_BANK_REC.G_gl_date,
        X_bank_currency         => CE_AUTO_BANK_MATCH.aba_bank_currency,
        X_cleared_amount        => NVL(amount_cleared,0),
	X_cleared_date		=> CE_AUTO_BANK_MATCH.csl_trx_date,
        X_charges_amount        => charges_amount,
        X_errors_amount         => errors_amount,
        X_exchange_date         => CE_AUTO_BANK_MATCH.csl_exchange_rate_date,
        X_exchange_type         => CE_AUTO_BANK_MATCH.csl_exchange_rate_type,
        X_exchange_rate         => CE_AUTO_BANK_MATCH.csl_exchange_rate);
    cleared_trx_type := 'ROI_LINE';
    cleared_trx_id   := CE_AUTO_BANK_MATCH.trx_id;
  ELSIF (CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'XTR_LINE') THEN
    X_RECONCILED_METHOD := substr(passin_mode,1,1);
	 XTR_WRAPPER_API_P.reconciliation(
                 P_SETTLEMENT_SUMMARY_ID => CE_AUTO_BANK_MATCH.trx_id,
                 P_TASK 		=> 'REC',
                 P_RECONCILED_METHOD    => X_RECONCILED_METHOD,
                 P_RESULT 		=> X_RESULT,
                 P_RECON_AMT => amount_cleared, -- 8978548 (1/4): Added
                 P_VAL_DATE => value_date);     -- 8978548 (2/4): Added
    if (X_RESULT <> 'XTR2_SUCCESS') then
          FND_MESSAGE.set_name( 'CE','CE_XTR_UPDATE_FAILED');
          RAISE APP_EXCEPTION.application_exception;
    end if;
    cleared_trx_type := 'XTR_LINE';
    cleared_trx_id   := CE_AUTO_BANK_MATCH.trx_id;
  ELSIF (CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'CASHFLOW') THEN

    CE_CASHFLOW_PKG.CLEAR_CASHFLOW(
    	X_CASHFLOW_ID   		=> CE_AUTO_BANK_MATCH.trx_id,
	X_TRX_STATUS			=> CE_AUTO_BANK_MATCH.trx_status,
        x_actual_value_date  		=> to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
        X_ACCOUNTING_DATE       	=> CE_AUTO_BANK_REC.G_gl_date,
        X_CLEARED_DATE          	=> to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
        X_CLEARED_AMOUNT		=> NVL(amount_cleared,0),
        X_CLEARED_ERROR_AMOUNT          => NVL(errors_amount,0),
        X_CLEARED_CHARGE_AMOUNT         => NVL(charges_amount,0),
        X_CLEARED_EXCHANGE_RATE_TYPE    => CE_AUTO_BANK_CLEAR.G_exchange_rate_type,
        X_CLEARED_EXCHANGE_RATE_DATE    => to_date(to_char(CE_AUTO_BANK_CLEAR.G_exchange_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
        X_CLEARED_EXCHANGE_RATE         => CE_AUTO_BANK_CLEAR.G_exchange_rate,
	X_PASSIN_MODE			=> passin_mode,
	x_statement_line_id		=> x_statement_line_id,
	x_statement_line_type		=> x_statement_line_type
         ) ;
    cleared_trx_type := 'CASHFLOW';
    cleared_trx_id   := CE_AUTO_BANK_MATCH.trx_id;
  ELSIF( CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'JE' ) THEN
    cleared_trx_type := 'JE_LINE';
    cleared_trx_id   := CE_AUTO_BANK_MATCH.trx_id;
  ELSIF (CE_AUTO_BANK_MATCH.csl_reconcile_flag IN ('PAY', 'PAY_EFT')) THEN
      --
      -- NVL(X_statement_line_type) is for cases where we create the statement line
      -- here (MANUAL_H) and we know that the created statement line
      -- is always fine
      --
      IF ((NVL(X_statement_line_type,'XXX') = 'STOP' AND trx_status <> 'V') OR
          (NVL(X_statement_line_type,'STOP') <> 'STOP' AND trx_status = 'V')) THEN
        FND_MESSAGE.set_name( 'CE', 'CE_STOP_VOID');
        RAISE APP_EXCEPTION.application_exception;
      ELSE
        IF l_DEBUG in ('Y', 'C') THEN
        	cep_standard.debug('>>> Calling PAY_CE_RECONCILIATION_PKG.reconcile_payment'||
        	 ' p_payment_id = '|| to_char(CE_AUTO_BANK_MATCH.trx_id)||
			   ' p_cleared_date = '|| to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'));
           	cep_standard.debug(' p_trx_amount = '|| to_char(amount_cleared)||
           		   ' p_trx_type = '||CE_AUTO_BANK_MATCH.csl_reconcile_flag);
        END IF;

	PAY_CE_RECONCILIATION_PKG.reconcile_payment (
           p_payment_id		=> CE_AUTO_BANK_MATCH.trx_id,
           p_cleared_date	=> to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
           p_trx_amount		=> NVL(amount_cleared,0),
           p_trx_type		=> CE_AUTO_BANK_MATCH.csl_reconcile_flag,
           p_last_updated_by    => NVL(FND_GLOBAL.user_id,-1),
           p_last_update_login  => NVL(FND_GLOBAL.user_id,-1),
           p_created_by         => NVL(FND_GLOBAL.user_id,-1) );

	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('reconcile_trx: ' || '<<< End PAY_CE_RECONCILIATION_PKG.reconcile_payment');
	END IF;
      END IF;
      cleared_trx_id      := CE_AUTO_BANK_MATCH.trx_id;
      cleared_trx_type    := CE_AUTO_BANK_MATCH.csl_reconcile_flag;
   ELSE
    IF (CE_AUTO_BANK_MATCH.csl_match_type = 'PAYMENT') THEN
      --
      -- NVL(X_statement_line_type) is for cases where we create the statement line
      -- here (MANUAL_H) and we know that the created statement line
      -- is always fine
      --
      IF ((NVL(X_statement_line_type,'XXX') = 'STOP' AND trx_status NOT IN ('STOP INITIATED', 'VOIDED')) OR
          (NVL(X_statement_line_type,'STOP') <> 'STOP' AND trx_status IN ( 'STOP INITIATED', 'VOIDED'))) THEN
        if (trx_status = 'STOP INITIATED') then
          FND_MESSAGE.set_name( 'CE', 'CE_ABR_PYMT_STOPPED' );
          RAISE APP_EXCEPTION.application_exception;
        elsif (trx_status = 'VOIDED') then
          FND_MESSAGE.set_name( 'CE', 'CE_ABR_PYMT_VOIDED' );
          RAISE APP_EXCEPTION.application_exception;
        else
          FND_MESSAGE.set_name( 'CE', 'CE_PAYMENT_STOPPED' );
          RAISE APP_EXCEPTION.application_exception;
	end if;
      ELSIF( trx_status NOT IN ( 'STOP INITIATED', 'VOIDED' )) THEN
        if (passin_mode = 'AUTO') then
/* bug 2260411
          if (CE_AUTO_BANK_MATCH.trx_gl_date is not null) then
             CE_AUTO_BANK_REC.G_gl_date := CE_AUTO_BANK_MATCH.trx_gl_date;
          end if;
*/
          if (CE_AUTO_BANK_MATCH.trx_cleared_date is not null) then
             CE_AUTO_BANK_MATCH.csl_trx_date :=
                       CE_AUTO_BANK_MATCH.trx_cleared_date;
          end if;
        end if;

  	IF l_DEBUG in ('Y', 'C') THEN
  		cep_standard.debug('X_CHECK_ID: '||to_char(CE_AUTO_BANK_MATCH.trx_id)||
  				 ' X_ACCOUNTING_DATE: '||CE_AUTO_BANK_REC.G_gl_date);
  		cep_standard.debug('X_CLEARED_DATE: '||CE_AUTO_BANK_MATCH.csl_trx_date||
  				' X_TRANSACTION_AMOUNT: '||to_char(amount_cleared));
  		cep_standard.debug('X_ERROR_AMOUNT: '||to_char(errors_amount)||
  				' X_CHARGE_AMOUNT: '||to_char(charges_amount));
  		cep_standard.debug('X_CURRENCY_CODE: '||X_currency_code||
	  			' X_EXCHANGE_RATE_TYPE: '||CE_AUTO_BANK_CLEAR.G_exchange_rate_type);
  		cep_standard.debug('X_EXCHANGE_RATE_DATE: '||CE_AUTO_BANK_CLEAR.G_exchange_date||
  				' X_EXCHANGE_RATE: '||to_char(CE_AUTO_BANK_CLEAR.G_exchange_rate));
  		cep_standard.debug('X_ACTUAL_VALUE_DATE: '||CE_AUTO_BANK_MATCH.csl_effective_date);
  		cep_standard.debug('reconcile_trx >>>AP_RECONCILIATION_PKG.recon_payment_history');
  	END IF;

       AP_RECONCILIATION_PKG.recon_payment_history(
        X_CHECKRUN_ID           => to_number(NULL),
        X_CHECK_ID              => to_number(CE_AUTO_BANK_MATCH.trx_id),
        X_ACCOUNTING_DATE       => CE_AUTO_BANK_REC.G_gl_date,
        X_CLEARED_DATE          => CE_AUTO_BANK_MATCH.csl_trx_date,
        X_TRANSACTION_AMOUNT    => NVL(amount_cleared,0),
        X_TRANSACTION_TYPE      => 'PAYMENT CLEARING',
        X_ERROR_AMOUNT          => NVL(errors_amount,0),
        X_CHARGE_AMOUNT         => NVL(charges_amount,0),
        X_CURRENCY_CODE         => X_bank_currency,
        X_EXCHANGE_RATE_TYPE    => CE_AUTO_BANK_CLEAR.G_exchange_rate_type,
        X_EXCHANGE_RATE_DATE    => CE_AUTO_BANK_CLEAR.G_exchange_date,
        X_EXCHANGE_RATE         => CE_AUTO_BANK_CLEAR.G_exchange_rate,
        X_MATCHED_FLAG          => clearing_flag,
	X_ACTUAL_VALUE_DATE     =>
				CE_AUTO_BANK_MATCH.csl_effective_date,
        X_LAST_UPDATE_DATE      => sysdate,
        X_LAST_UPDATED_BY       => NVL(FND_GLOBAL.user_id,-1),
        X_LAST_UPDATE_LOGIN     => NVL(FND_GLOBAL.user_id,-1),
        X_CREATED_BY            => NVL(FND_GLOBAL.user_id,-1),
        X_CREATION_DATE         => sysdate,
        X_PROGRAM_UPDATE_DATE   => sysdate,
        X_PROGRAM_APPLICATION_ID=> NVL(FND_GLOBAL.prog_appl_id,-1),
        X_PROGRAM_ID            => NVL(FND_GLOBAL.conc_program_id,-1),
        X_REQUEST_ID            => NVL(FND_GLOBAL.conc_request_id,-1),
        X_CALLING_SEQUENCE      => 'CE_AUTO_BANK_CLEAR1.reconcile_trx '
        );

      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('reconcile_trx: ' || '<<<AP_RECONCILIATION_PKG.recon_payment_history');
      END IF;
      END IF;
      cleared_trx_id      := CE_AUTO_BANK_MATCH.trx_id;
      cleared_trx_type    := CE_AUTO_BANK_MATCH.csl_match_type;
    ELSE -- Receipt
      IF ((NVL(X_statement_line_type,'NSF') NOT IN ('NSF','REJECTED') AND
	  trx_status in ('REVERSED','DM REVERSED'))) THEN
        FND_MESSAGE.set_name('CE', 'CE_STATEMENT_REVERSAL_NSF');
        RAISE APP_EXCEPTION.application_exception;
      ELSE
        IF (passin_mode = 'AUTO'                                        AND
            CE_AUTO_BANK_MATCH.csl_trx_type IN ('NSF','REJECTED')       AND
            CE_AUTO_BANK_REC.G_nsf_handling = 'REVERSE' AND
	    CE_AUTO_BANK_MATCH.trx_status <> 'REVERSED') THEN
          ARP_CASHBOOK.reverse(
                p_cr_id                 => ar_cash_receipt_id,
                p_reversal_gl_date      => to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
                p_reversal_date         => sysdate,
                p_reversal_comments     => NULL,
                p_reversal_reason_code  => NULL,
                p_reversal_category     => NULL,
                p_module_name           => 'CE_AUTO_BANK_REC',
                p_module_version        => '1.0',
                p_crh_id                => cleared_trx_id);
          cleared_trx_type := CE_AUTO_BANK_MATCH.csl_match_type;
        ELSIF (passin_mode = 'AUTO'                                     AND
            CE_AUTO_BANK_MATCH.csl_trx_type IN ('NSF','REJECTED')       AND
            CE_AUTO_BANK_REC.G_nsf_handling = 'DM REVERSE' AND
	    CE_AUTO_BANK_MATCH.trx_status <> 'REVERSED') THEN

	  IF (CE_AUTO_BANK_MATCH.csl_match_type = 'CASH' AND
	      CE_AUTO_BANK_MATCH.trx_customer_id is not null) THEN
	    declare
	    cc_id		ra_cust_trx_types.gl_id_rec%type;
	    cust_trx_type_id	ra_cust_trx_types.cust_trx_type_id%type;
	    cust_trx_type	ra_cust_trx_types.name%type;
	    l_dbseqname		varchar2(30);
  	    l_doc_seq_id        NUMBER;
  	    l_doc_seq_value     NUMBER;
  	    l_valid_seq         BOOLEAN := TRUE;
  	    out_trx_number     	ar_payment_schedules_all.trx_number%TYPE;
  	    out_status         	varchar2(10);

	    begin
	    select name, gl_id_rec, cust_trx_type_id
	    into   cust_trx_type, cc_id, cust_trx_type_id
	    from   ra_cust_trx_types
	    where  type = 'DM'
	    and    post_to_gl = 'Y'
	    and    accounting_affect_flag = 'Y'
	    and    tax_calculation_flag = 'N'
	    and    rownum = 1
	    order by name, cust_trx_type_id;

    	    l_valid_seq := CE_AUTO_BANK_IMPORT.get_sequence_info(
                        222,
                        cust_trx_type,
                        CE_AUTO_BANK_REC.G_set_of_books_id,
                        'A',
                        CE_AUTO_BANK_MATCH.csl_trx_date,
                        l_dbseqname,
                        l_doc_seq_id,
                        l_doc_seq_value );

	    if (l_valid_seq) then
  	       ARP_CASHBOOK.debit_memo_reversal
                      ( p_cash_receipt_id       => ar_cash_receipt_id,
                        p_cc_id                 => cc_id,
                        p_dm_cust_trx_type_id   => cust_trx_type_id,
                        p_dm_cust_trx_type      => cust_trx_type,
                        p_reversal_gl_date      =>
				to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
                        p_reversal_date         =>
				to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
                        p_reversal_category     => 'NSF',
                        p_reversal_reason_code  => 'NSF',
                        p_reversal_comments     => 'test',
                        p_dm_number             => out_trx_number,
                        p_dm_doc_sequence_value => l_doc_seq_value,
                        p_dm_doc_sequence_id    => l_doc_seq_id,
                        p_tw_status             => out_status,
                        p_module_name           => 'CE_AUTO_BANK_REC',
                        p_module_version        => '1.0');

	      if (out_status = 'OK') then
		cleared_trx_id := CE_AUTO_BANK_MATCH.trx_id;
          	cleared_trx_type := CE_AUTO_BANK_MATCH.csl_match_type;
	      end if;
	    end if;
	    exception
	    when no_data_found then
	      IF l_DEBUG in ('Y', 'C') THEN
	      	cep_standard.debug('reconcile_trx: ' || '<<CE_AUTO_BANK_CLEAR1.reconcile_trx calls debit_memo_reversal'||
		      	 'NO DATA FOUND');
	      END IF;
	      raise;
	    when others then
	      IF l_DEBUG in ('Y', 'C') THEN
	      	cep_standard.debug('reconcile_trx: ' ||
	      '<<CE_AUTO_BANK_CLEAR1.reconcile_trx calls debit_memo_reversal');
	      END IF;
	      raise;
	    end;
	  END IF;

        ELSE
          IF (reference_status <> 'REVERSED' AND NOT
              CE_AUTO_BANK_CLEAR1.check_matching_status(ar_cash_receipt_id,
              reference_status)) THEN
            FND_MESSAGE.set_name('CE','CE_MATCHED_AR_ENTRY');
            RAISE APP_EXCEPTION.application_exception;
          ELSE
	    IF l_DEBUG in ('Y', 'C') THEN
	    	cep_standard.debug('reconcile_trx: ' || ' amount_cleared = '|| amount_cleared||
		    	' charges_amount = '|| charges_amount||	' trx_status = '|| trx_status);
	    END IF;
            cleared_trx_type := CE_AUTO_BANK_MATCH.csl_match_type;
            --
            -- when reconcile the original receipt which has been reversed
            -- only perform the reconciliation process and skip the call to
            -- any AR packages
            --
            IF (CE_AUTO_BANK_MATCH.reversed_receipt_flag = 'Y'
		OR (trx_status IN ('RISK_ELIMINATED', 'CLEARED'))
		OR (CE_AUTO_BANK_MATCH.csl_trx_type in ('NSF', 'REJECTED')) ) THEN
              cleared_trx_id := CE_AUTO_BANK_MATCH.trx_id;
              --
              -- bug 922650
              -- update actual_value_date in AR_CASH_RECEIPS table.
	      --
  	cep_standard.debug('reconcile_trx: call ARP_CASHBOOK.update_actual_value_date');
	      ARP_CASHBOOK.update_actual_value_date(to_number(ar_cash_receipt_id),
				to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'));
            ELSE
	      IF l_DEBUG in ('Y', 'C') THEN
	    	cep_standard.debug('reconcile_trx: ' || ' ar_cash_receipt_id= '|| ar_cash_receipt_id ||
		    	' CE_AUTO_BANK_MATCH.csl_trx_date = '|| CE_AUTO_BANK_MATCH.csl_trx_date ||
		    	' CE_AUTO_BANK_REC.G_gl_date= '|| 	CE_AUTO_BANK_REC.G_gl_date);
	    	cep_standard.debug(' CE_AUTO_BANK_MATCH.csl_effective_date= '|| 	CE_AUTO_BANK_MATCH.csl_effective_date ||
		    	' CE_AUTO_BANK_CLEAR.G_exchange_date= '|| 	CE_AUTO_BANK_CLEAR.G_exchange_date ||
		    	' CE_AUTO_BANK_CLEAR.G_exchange_rate_type= '|| 	CE_AUTO_BANK_CLEAR.G_exchange_rate_type);
	   	cep_standard.debug('CE_AUTO_BANK_CLEAR.G_exchange_rate= '|| 	CE_AUTO_BANK_CLEAR.G_exchange_rate ||
		    	'CE_AUTO_BANK_MATCH.aba_bank_currency= '|| 	CE_AUTO_BANK_MATCH.aba_bank_currency ||
		    	' amount_cleared	= '|| amount_cleared);
		cep_standard.debug('charges_amount	= '|| charges_amount ||
		    	' cleared_trx_id	= '|| cleared_trx_id);
	      END IF;
  	cep_standard.debug('reconcile_trx: call ARP_CASHBOOK.clear ');

              ARP_CASHBOOK.clear(
              p_cr_id              => to_number(ar_cash_receipt_id),
              p_trx_date           => to_date(to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
              p_gl_date            => to_date(to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
	      p_actual_value_date  => to_date(to_char(CE_AUTO_BANK_MATCH.csl_effective_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
              p_exchange_date    => to_date(to_char(CE_AUTO_BANK_CLEAR.G_exchange_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
              p_exchange_rate_type => CE_AUTO_BANK_CLEAR.G_exchange_rate_type,
              p_exchange_rate      => CE_AUTO_BANK_CLEAR.G_exchange_rate,
              p_bank_currency      => CE_AUTO_BANK_MATCH.aba_bank_currency,
              p_amount_cleared     => amount_cleared,
              p_amount_factored    => charges_amount,
              p_module_name        => 'CE_AUTO_BANK_REC',
              p_module_version     => '1.0',
              p_crh_id             => cleared_trx_id );
  	cep_standard.debug('end call ARP_CASHBOOK.clear ');
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
  END IF;

  IF (passin_mode <> 'MANUAL_C' ) THEN

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('reconcile_trx: ' || 'cleared_trx_type='||cleared_trx_type||',cleared_trx_id='||
	to_char(cleared_trx_id)||',ar_cash_receipt_id='||to_char(ar_cash_receipt_id));
	cep_standard.debug('reconcile_trx: ' ||',reference_status='||reference_status||
	',auto_reconciled_flag='||auto_reconciled_flag||',amount_cleared='|| to_char(amount_cleared));
  END IF;

    CE_AUTO_BANK_CLEAR1.insert_reconciliation (
        Y_cleared_trx_type      => cleared_trx_type,
        Y_cleared_trx_id        => cleared_trx_id,
        Y_ar_cash_receipt_id    => ar_cash_receipt_id,
        Y_reference_status      => reference_status,
        Y_auto_reconciled_flag  => auto_reconciled_flag,
        Y_status_flag           => 'M',
        Y_amount                => amount_cleared);
  END IF;

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_CLEAR1.reconcile_trx');
  END IF;

END reconcile_trx;

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
value_date DATE := null;
p_current_record_flag VARCHAR2(1) := null;
  current_org_id		NUMBER;

  X_RESULT	       VARCHAR2(100);

BEGIN

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_CLEAR1.unclear_process');

	cep_standard.debug('passin_mode = ' ||passin_mode||' tx_type = '|| tx_type ||
			', clearing_trx_type = ' ||clearing_trx_type || ', org_id = ' ||org_id ||
			', legal_entity_id = ' ||legal_entity_id);
	cep_standard.debug('stmt_line_id = ' ||stmt_line_id || ', status = ' || status||
			', currency_code = '||currency_code );
	cep_standard.debug('X_CHECKRUN_ID: '||to_char(batch_id)||', X_CHECK_ID: '||to_char(trx_id) ||
			', cash_receipt_id ' ||cash_receipt_id ||
			', trx_date ' ||trx_date ||
			', cash_receipt_history_id '|| cash_receipt_history_id  );

	 cep_standard.debug('X_ACCOUNTING_DATE: '||fnd_date.date_to_charDT(gl_date)||
  			 ', X_CLEARED_DATE: '||fnd_date.date_to_charDT(cleared_date)||
  			 ', X_TRANSACTION_AMOUNT: '||to_char(transaction_amount));
	 cep_standard.debug('X_ERROR_AMOUNT: '||to_char(error_amount)||
  			 ', X_CHARGE_AMOUNT: '||to_char(charge_amount)||
	  		 ', X_CURRENCY_CODE: '||currency_code);
	 cep_standard.debug('X_EXCHANGE_RATE_TYPE: '||xtype||
 			 ', X_EXCHANGE_RATE_DATE: '||fnd_date.date_to_charDT(xdate));
	 cep_standard.debug('X_EXCHANGE_RATE: '||to_char(xrate)||
  			 ', X_ACTUAL_VALUE_DATE: '||fnd_date.date_to_charDT(value_date));
  END IF;

  --CE_AUTO_BANK_REC.G_org_id := org_id;
  --CE_AUTO_BANK_REC.G_legal_entity_id := legal_entity_id;
  CE_AUTO_BANK_CLEAR.G_org_id := org_id;
  CE_AUTO_BANK_CLEAR.G_legal_entity_id := legal_entity_id;

  IF (org_id is not null)  THEN
    select mo_global.GET_CURRENT_ORG_ID
    into current_org_id
    from dual;

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('current_org_id =' ||current_org_id );
    END IF;

    -- bug 3782741 set single org, since AR will not allow org_id to be passed
    IF  (((current_org_id is null) or (org_id <> current_org_id )) AND
	 (clearing_trx_type in ('CASH','MISC', 'PAYMENT'))) THEN
      mo_global.set_policy_context('S',org_id);
      cep_standard.debug('set current_org_id to ' ||org_id );
    END IF;
  END IF;

  select mo_global.GET_CURRENT_ORG_ID
  into current_org_id
  from dual;

  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('current_org_id =' ||current_org_id );
  END IF;

  CE_AUTO_BANK_MATCH.reconcile_to_statement_flag := NULL;
  IF (clearing_trx_type = 'PAYMENT') THEN

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('>>>AP_RECONCILIATION_PKG.recon_payment_history');
    END IF;

  /*Bug 3427050 added the following IF */
    IF (status NOT IN ('STOP INITIATED','VOIDED')) THEN
      AP_RECONCILIATION_PKG.recon_payment_history(
        X_CHECKRUN_ID           => to_number(NULL),
        X_CHECK_ID              => trx_id,
        X_ACCOUNTING_DATE       => gl_date,
        X_CLEARED_DATE          => cleared_date,
        X_TRANSACTION_AMOUNT    => transaction_amount,
        X_TRANSACTION_TYPE      => 'PAYMENT UNCLEARING',
        X_ERROR_AMOUNT          => error_amount,
        X_CHARGE_AMOUNT         => charge_amount,
        X_CURRENCY_CODE         => currency_code,
        X_EXCHANGE_RATE_TYPE    => xtype,
        X_EXCHANGE_RATE_DATE    => xdate,
        X_EXCHANGE_RATE         => xrate,
        X_MATCHED_FLAG          => 'Y',
	X_ACTUAL_VALUE_DATE     => value_date,
        X_LAST_UPDATE_DATE      => sysdate,
        X_LAST_UPDATED_BY       => NVL(FND_GLOBAL.user_id,-1),
        X_LAST_UPDATE_LOGIN     => NVL(FND_GLOBAL.user_id,-1),
        X_CREATED_BY            => NVL(FND_GLOBAL.user_id,-1),
        X_CREATION_DATE         => sysdate,
        X_PROGRAM_UPDATE_DATE   => to_date(NULL),
        X_PROGRAM_APPLICATION_ID=> to_number(NULL),
        X_PROGRAM_ID            => to_number(NULL),
        X_REQUEST_ID            => to_number(NULL),
        X_CALLING_SEQUENCE      => 'CE_AUTO_BANK_CLEAR1.unclear_process '
        );
	IF l_DEBUG in ('Y', 'C') THEN
  		cep_standard.debug('unclear_process: ' || '>>>AP_RECONCILIATION_PKG.recon_payment_history');
  	END IF;

	-- after unreconcile, update the reconciled_status of this trx in the GT table to 'N'
	CE_AUTO_BANK_MATCH.update_gt_reconciled_status(200, trx_id, 'N');
    END IF; -- Bug 3427050
  ELSIF (clearing_trx_type IN ('CASH','MISC')) THEN

    SELECT NVL(arh.current_record_flag, 'N')
    INTO   p_current_record_flag
    FROM   ar_cash_receipt_history_all arh
    WHERE  arh.cash_receipt_history_id = trx_id;

    IF (status not in ('REVERSED', 'RISK_ELIMINATED')
	  AND p_current_record_flag <> 'N'
	  AND arp_cashbook.receipt_debit_memo_reversed(cash_receipt_id) = 'N') THEN
      IF l_DEBUG in ('Y', 'C') THEN
  		cep_standard.debug('call ARP_CASHBOOK.unclear');
      END IF;

      ARP_CASHBOOK.unclear( 	p_cr_id			=> cash_receipt_id,
		 		p_trx_date		=> trx_date,
				p_gl_date		=> gl_date,
				p_actual_value_date     => value_date,
				p_module_name		=> 'CEXCABMR',
				p_module_version	=> '1.0',
				p_crh_id		=> cash_receipt_history_id);
      IF l_DEBUG in ('Y', 'C') THEN
  		cep_standard.debug('end call ARP_CASHBOOK.unclear');
      END IF;

      -- after unreconcile, update the reconciled_status of this trx in the GT table to 'N'
      update ce_available_transactions_tmp
      set    reconciled_status_flag = 'N'
      where  application_id = 222
      and    trx_id = trx_id
      and    status <> 'REVERSED';
    END IF;
  ELSIF (clearing_trx_type = 'ROI_LINE' ) THEN
    CE_999_PKG.unclear( X_trx_id	=> trx_id,
			X_trx_type	=> tx_type,
			X_status        => nvl(CE_AUTO_BANK_REC.G_open_interface_float_status, status),
			X_trx_date	=> trx_date,
			X_gl_date	=> gl_date);
    -- after unreconcile, update the reconciled_status of this trx in the GT table to 'N'
    CE_AUTO_BANK_MATCH.update_gt_reconciled_status(999, trx_id, 'N');

  ELSIF (clearing_trx_type = 'XTR_LINE' ) THEN
    IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('unclear_process: ' || 'clearing_trx_type = xtr_line start');
    END IF;
	 XTR_WRAPPER_API_P.reconciliation(
                 P_SETTLEMENT_SUMMARY_ID => trx_id,
                 P_TASK 		=> 'UNR',
                 P_RECONCILED_METHOD    => null,
                 P_RESULT 		=> X_RESULT,
                 P_RECON_AMT => NULL, -- 8978548 (3/4): Added
                 P_VAL_DATE => NULL); -- 8978548 (4/4): Added
	-- after unreconcile, update the reconciled_status of this trx in the GT table to 'N'
        CE_AUTO_BANK_MATCH.update_gt_reconciled_status(185, trx_id, 'N');


    IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('unclear_process: ' || 'X_RESULT = ' ||X_RESULT);
    END IF;
    if (X_RESULT <> 'XTR2_SUCCESS') then
          FND_MESSAGE.set_name( 'CE','CE_XTR_UPDATE_FAILED');
          RAISE APP_EXCEPTION.application_exception;
    end if;
    IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('unclear_process: ' || 'clearing_trx_type = xtr_line END');
    END IF;
  ELSIF (clearing_trx_type = 'CASHFLOW' ) THEN
    IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('clearing_trx_type = CASHFLOW start');
    END IF;
    -- passin_mode MANUAL, MANUAL_UC


    CE_CASHFLOW_PKG.CLEAR_CASHFLOW(
    	X_CASHFLOW_ID   		=> trx_id,
	X_TRX_STATUS			=> status,
        x_actual_value_date  		=> trx_date,
        X_ACCOUNTING_DATE       	=> gl_date,
        X_CLEARED_DATE          	=> trx_date,
        X_CLEARED_AMOUNT		=> transaction_amount,
        X_CLEARED_ERROR_AMOUNT          => NVL(error_amount,0),
        X_CLEARED_CHARGE_AMOUNT         => NVL(charge_amount,0),
        X_CLEARED_EXCHANGE_RATE_TYPE    => CE_AUTO_BANK_CLEAR.G_exchange_rate_type,
        X_CLEARED_EXCHANGE_RATE_DATE    => to_date(to_char(CE_AUTO_BANK_CLEAR.G_exchange_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
        X_CLEARED_EXCHANGE_RATE         => CE_AUTO_BANK_CLEAR.G_exchange_rate,
	X_PASSIN_MODE			=> passin_mode,
	x_statement_line_id		=> stmt_line_id,
	x_statement_line_type		=> null
         ) ;

    -- after unreconcile, update the reconciled_status of this trx in the GT table to 'N'
    CE_AUTO_BANK_MATCH.update_gt_reconciled_status(261, trx_id, 'N');


  /*
    CE_CASHFLOW_PKG.CLEAR_CASHFLOW(
    	X_CASHFLOW_ID   		=> trx_id,
	X_TRX_STATUS			=> status,
        x_actual_value_date  		=> trx_date,
        X_ACCOUNTING_DATE       	=> gl_date,
        X_CLEARED_DATE          	=> trx_date,
        X_CLEARED_AMOUNT		=> NVL(amount_cleared,0),
        X_CLEARED_ERROR_AMOUNT          => NVL(errors_amount,0),
        X_CLEARED_CHARGE_AMOUNT         => NVL(charges_amount,0),
        X_CLEARED_EXCHANGE_RATE_TYPE    => CE_AUTO_BANK_CLEAR.G_exchange_rate_type,
        X_CLEARED_EXCHANGE_RATE_DATE    => to_date(to_char(CE_AUTO_BANK_CLEAR.G_exchange_date,'YYYY/MM/DD'),'YYYY/MM/DD'),
        X_CLEARED_EXCHANGE_RATE         => CE_AUTO_BANK_CLEAR.G_exchange_rate,
	X_PASSIN_MODE			=> passin_mode
         ) ;
  */
    IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('clearing_trx_type = CASHFLOW END');
    END IF;

  ELSIF (clearing_trx_type = 'STATEMENT') THEN
	IF (passin_mode = 'MANUAL') THEN
 	   CE_AUTO_BANK_MATCH.csl_statement_line_id := stmt_line_id;
        END IF;
    -- bug 4247469 the CE_AUTO_BANK_MATCH.csl_reconcile_flag need to be cleared
    --             in case a journal is processed before the stmt transaction
    CE_AUTO_BANK_MATCH.csl_reconcile_flag := NULL;

    CE_AUTO_BANK_CLEAR1.insert_reconciliation (
	Y_statement_line_id	=> trx_id,
        Y_cleared_trx_type      => clearing_trx_type,
        Y_cleared_trx_id        => CE_AUTO_BANK_MATCH.csl_statement_line_id,
        Y_ar_cash_receipt_id    => cash_receipt_id,
        Y_reference_status      => status,
        Y_auto_reconciled_flag  => 'N',
        Y_status_flag           => 'U');

    CE_AUTO_BANK_CLEAR1.update_line_unreconciled(trx_id);

    -- after unreconcile, update the reconciled_status of this trx in the GT table to 'N'
    CE_AUTO_BANK_MATCH.update_gt_reconciled_status(260, trx_id, 'N');

  ELSIF (clearing_trx_type IN  ('PAY','PAY_EFT')) THEN
    IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('call PAY_CE_RECONCILIATION_PKG.reverse_reconcile');
    END IF;

    PAY_CE_RECONCILIATION_PKG.reverse_reconcile(
	p_payment_id		=> trx_id);

    -- after unreconciliation, update the reconciled_status of this trx in the GT table to 'N'
    IF (clearing_trx_type = 'PAY') THEN
      CE_AUTO_BANK_MATCH.update_gt_reconciled_status(801, trx_id, 'N');
    ELSE
      CE_AUTO_BANK_MATCH.update_gt_reconciled_status(802, trx_id, 'N');
    END IF;


    IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('end call PAY_CE_RECONCILIATION_PKG.reverse_reconcile');
    END IF;
  END IF;
  IF (passin_mode <> 'MANUAL_UC') THEN
    CE_AUTO_BANK_MATCH.csl_statement_line_id := stmt_line_id;
    IF (clearing_trx_type IN ('PAYMENT','CASH','MISC','ROI_LINE','XTR_LINE','STATEMENT','PAY','PAY_EFT','CASHFLOW')) THEN
      CE_AUTO_BANK_MATCH.csl_reconcile_flag := NULL;
    ELSE
      CE_AUTO_BANK_MATCH.csl_reconcile_flag := 'JE';
    END IF;

    CE_AUTO_BANK_CLEAR1.insert_reconciliation (
	Y_statement_line_id	=> CE_AUTO_BANK_MATCH.csl_statement_line_id,
	Y_cleared_trx_type	=> clearing_trx_type,
	Y_cleared_trx_id	=> trx_id,
	Y_ar_cash_receipt_id	=> cash_receipt_id,
	Y_reference_status	=> status,
	Y_auto_reconciled_flag	=> 'N',
	Y_status_flag		=> 'U');

    IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('call CE_AUTO_BANK_CLEAR1.update_line_unreconciled');
    END IF;

    CE_AUTO_BANK_CLEAR1.update_line_unreconciled(stmt_line_id);

    IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('end call CE_AUTO_BANK_CLEAR1.update_line_unreconciled');
    END IF;
  END IF;
  IF (X_header_or_line = 'HEADERS') THEN
    CE_AUTO_BANK_CLEAR1.update_line_unreconciled(stmt_line_id);
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_CLEAR1.unclear_process');
  END IF;

EXCEPTION
  when others then
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_AUTO_BANK_CLEAR1.unclear_process');
    END IF;
    RAISE;
END unclear_process;


PROCEDURE populate_avail_trx(
		X_table				VARCHAR2,
		X_where_clause			VARCHAR,
		X_asset_code_combination_id	NUMBER,
		X_bank_account_id		NUMBER,
		X_from_number			VARCHAR2,
		X_to_number			VARCHAR2,
		X_status			VARCHAR2,
		X_currency_code			VARCHAR2,
		X_reference_id			NUMBER,
		X_from_batch_name		VARCHAR2,
		X_to_batch_name			VARCHAR2,
		X_from_remit_num		VARCHAR2,
		X_to_remit_num			VARCHAR2,
		X_from_date			DATE,
		X_to_date			DATE,
		X_from_maturity_date		DATE,
		X_to_maturity_date		DATE,
		X_customer_id			NUMBER,
		X_receipt_class_id		NUMBER,
		X_receipt_method_id		NUMBER,
		X_deposit_date_from		DATE,
		X_deposit_date_to		DATE,
		X_supplier_id			NUMBER,
		X_reference_type		VARCHAR2,
		X_period_name			VARCHAR2,
		X_from_journal_entry_name	VARCHAR2,
		X_to_journal_entry_name		VARCHAR2,
		X_from_document_number		NUMBER,
		X_to_document_number		NUMBER,
		X_from_je_line_number		NUMBER,
		X_to_je_line_number		NUMBER,
		X_cleared_date			DATE,
		X_value_date			DATE,
		X_gl_date			DATE,
		X_from_amount			NUMBER,
		X_to_amount			NUMBER,
		X_org_id			NUMBER,
		X_legal_entity_id		NUMBER) IS
    insert_stmt  VARCHAR2(3000);
    cursor_id	 INTEGER;
    exec_id	 INTEGER;
BEGIN
    cursor_id := DBMS_SQL.open_cursor;
    insert_stmt := 'INSERT INTO ce_available_transactions_tmp ' ||
	'(ROW_ID, MULTI_SELECT, BANK_ACCOUNT_ID, BANK_ACCOUNT_NAME, ' ||
	'BANK_ACCOUNT_NUM, BANK_NAME, BANK_BRANCH_NAME, '||
	'TRX_ID, TRX_TYPE, TYPE_MEANING, TRX_NUMBER, CHECK_NUMBER, ' ||
	'CURRENCY_CODE, AMOUNT, BANK_ACCOUNT_AMOUNT, AMOUNT_CLEARED, ' ||
	'GL_DATE, STATUS_DSP, STATUS, DESCRIPTION, TRX_DATE, CLEARED_DATE, ' ||
	'MATURITY_DATE, EXCHANGE_RATE_DATE, EXCHANGE_RATE_TYPE, ' ||
	'USER_EXCHANGE_RATE_TYPE, EXCHANGE_RATE, BANK_CHARGES, BANK_ERRORS, '||
	'BATCH_NAME, BATCH_ID, AGENT_NAME, CUSTOMER_NAME, PAYMENT_METHOD, '||
	'VENDOR_NAME, CUSTOMER_ID, SUPPLIER_ID, REFERENCE_TYPE_DSP, '||
	'REFERENCE_TYPE, REFERENCE_ID, ACTUAL_AMOUNT_CLEARED, CREATION_DATE, '||
	'CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, REMITTANCE_NUMBER, '||
	'CASH_RECEIPT_ID, APPLICATION_ID, COUNT_CLEARED, BANK_CURRENCY_CODE, '||
	'TRX_CURRENCY_TYPE, CODE_COMBINATION_ID, PERIOD_NAME, '||
	'JOURNAL_ENTRY_NAME, DOCUMENT_NUMBER, JOURNAL_ENTRY_LINE_NUMBER, '||
	'CLEARING_TRX_TYPE, JOURNAL_CATEGORY, BASE_AMOUNT, RECEIPT_CLASS_ID, '||
	'RECEIPT_METHOD_ID, RECEIPT_CLASS_NAME, DEPOSIT_DATE, VALUE_DATE, ' ||
	'REVERSED_RECEIPT_FLAG, LEGAL_ENTITY_ID, ORG_ID) ' ||
	'SELECT ROW_ID, MULTI_SELECT, BANK_ACCOUNT_ID, BANK_ACCOUNT_NAME, '||
	'BANK_ACCOUNT_NUM, BANK_NAME, BANK_BRANCH_NAME, TRX_ID, TRX_TYPE, ' ||
	'TYPE_MEANING, TRX_NUMBER, CHECK_NUMBER, CURRENCY_CODE, AMOUNT, '||
	'BANK_ACCOUNT_AMOUNT, AMOUNT_CLEARED, GL_DATE, STATUS_DSP, STATUS, ' ||
	'null, TRX_DATE, CLEARED_DATE, MATURITY_DATE, EXCHANGE_RATE_DATE, ' ||
	'EXCHANGE_RATE_TYPE, USER_EXCHANGE_RATE_TYPE, EXCHANGE_RATE, ' ||
	'BANK_CHARGES, BANK_ERRORS, BATCH_NAME, BATCH_ID, AGENT_NAME, ' ||
	'CUSTOMER_NAME, PAYMENT_METHOD, VENDOR_NAME, CUSTOMER_ID, ' ||
	'SUPPLIER_ID, REFERENCE_TYPE_DSP, REFERENCE_TYPE, REFERENCE_ID, ' ||
	'ACTUAL_AMOUNT_CLEARED, CREATION_DATE, CREATED_BY, ' ||
	'LAST_UPDATE_DATE, LAST_UPDATED_BY, REMITTANCE_NUMBER, ' ||
	'CASH_RECEIPT_ID, APPLICATION_ID, COUNT_CLEARED, BANK_CURRENCY_CODE, '||
	'TRX_CURRENCY_TYPE, CODE_COMBINATION_ID, PERIOD_NAME, '||
	'JOURNAL_ENTRY_NAME, DOCUMENT_NUMBER, JOURNAL_ENTRY_LINE_NUMBER, '||
	'CLEARING_TRX_TYPE, JOURNAL_CATEGORY, BASE_AMOUNT, RECEIPT_CLASS_ID, '||
	'RECEIPT_METHOD_ID, RECEIPT_CLASS_NAME, DEPOSIT_DATE, VALUE_DATE, ' ||
	'REVERSED_RECEIPT_FLAG, LEGAL_ENTITY_ID, ORG_ID FROM ' || X_table ||
	' WHERE ' || X_where_clause;

    DBMS_SQL.Parse(cursor_id,
		 insert_stmt,
		 DBMS_SQL.v7);
    if (X_asset_code_combination_id is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':asset_code_combination_id',
		X_asset_code_combination_id);
    end if;
    if (X_bank_account_id is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':bank_account_id',
		X_bank_account_id);
    end if;
    if (X_org_id is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':org_id',
		X_org_id);
    elsif (X_legal_entity_id is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':legal_entity_id',
		X_legal_entity_id);
    end if;
    if (X_from_number is not null AND X_from_number <> '%') then
      DBMS_SQL.bind_variable(cursor_id, ':from_number', X_from_number);
    end if;
    if (X_to_number is not null AND X_to_number <> '%') then
      DBMS_SQL.bind_variable(cursor_id, ':to_number', X_to_number);
    end if;
    if (X_status is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':status', X_status);
    end if;
    if (X_currency_code is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':currency_code', X_currency_code);
    end if;
    if (X_reference_id is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':reference_id', X_reference_id);
    end if;
    if (X_from_batch_name is not null AND X_from_batch_name <> '%') then
      DBMS_SQL.bind_variable(cursor_id, ':from_batch_name', X_from_batch_name);
    end if;
    if (X_to_batch_name is not null AND X_to_batch_name <> '%') then
      DBMS_SQL.bind_variable(cursor_id, ':to_batch_name', X_to_batch_name);
    end if;
    if (X_from_remit_num is not null AND X_from_remit_num <> '%') then
      DBMS_SQL.bind_variable(cursor_id, ':from_remit_num', X_from_remit_num);
    end if;
    if (X_to_remit_num is not null AND X_to_remit_num <> '%') then
      DBMS_SQL.bind_variable(cursor_id, ':to_remit_num', X_to_remit_num);
    end if;
    if (X_from_date is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':from_date', X_from_date);
    end if;
    if (X_to_date is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':to_date', X_to_date);
    end if;
    if (X_from_maturity_date is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':from_maturity_date',
		X_from_maturity_date);
    end if;
    if (X_to_maturity_date is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':to_maturity_date',
		X_to_maturity_date);
    end if;
    if (X_customer_id is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':customer_id', X_customer_id);
    end if;
    if (X_receipt_class_id is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':receipt_class_id',
		X_receipt_class_id);
    end if;
    if (X_receipt_method_id is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':receipt_method_id',
		X_receipt_method_id);
    end if;
    if (X_deposit_date_from is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':deposit_date_from',
		X_deposit_date_from);
    end if;
    if (X_deposit_date_to is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':deposit_date_to', X_deposit_date_to);
    end if;
    if (X_receipt_class_id is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':receipt_class_id',
		X_receipt_class_id);
    end if;
    if (X_supplier_id is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':supplier_id', X_supplier_id);
    end if;
    if (X_reference_type is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':reference_type', X_reference_type);
    end if;
    if (X_period_name is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':period_name', X_period_name);
    end if;
    if (X_from_journal_entry_name is not null
	AND X_from_journal_entry_name <> '%') then
      DBMS_SQL.bind_variable(cursor_id, ':from_journal_entry_name',
		X_from_journal_entry_name);
    end if;
    if (X_to_journal_entry_name is not null
	AND X_to_journal_entry_name <> '%') then
      DBMS_SQL.bind_variable(cursor_id, ':to_journal_entry_name',
		X_to_journal_entry_name);
    end if;
    if (X_from_document_number is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':from_document_number',
		X_from_document_number);
    end if;
    if (X_to_document_number is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':to_document_number',
		X_to_document_number);
    end if;
    if (X_from_je_line_number is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':from_je_line_number',
		X_from_je_line_number);
    end if;
    if (X_to_je_line_number is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':to_je_line_number',
		X_to_je_line_number);
    end if;
    if (X_cleared_date is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':cleared_date', X_cleared_date);
    end if;
    if (X_value_date is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':value_date', X_value_date);
    end if;
    if (X_gl_date is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':gl_date', X_gl_date);
    end if;
    if (X_from_amount is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':from_amount', X_from_amount);
    end if;
    if (X_to_amount is not null) then
      DBMS_SQL.bind_variable(cursor_id, ':to_amount', X_to_amount);
    end if;
    exec_id := DBMS_SQL.execute(cursor_id);
    DBMS_SQL.close_cursor(cursor_id);
EXCEPTION
  when others then
    null;
END populate_avail_trx;

END CE_AUTO_BANK_CLEAR1;

/
