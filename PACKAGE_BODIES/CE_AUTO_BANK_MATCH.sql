--------------------------------------------------------
--  DDL for Package Body CE_AUTO_BANK_MATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_AUTO_BANK_MATCH" AS
/* $Header: ceabrmab.pls 120.62.12010000.19 2010/03/11 06:59:44 ckansara ship $ */

  --
  -- MAIN CURSORS
  --
  CURSOR r_branch_cursor( p_bank_branch_id              NUMBER,
			  p_bank_account_id             NUMBER,
			  p_org_id		        NUMBER,
			  p_legal_entity_id             NUMBER) IS
	SELECT aba.bank_account_id,
		aba.ACCOUNT_OWNER_ORG_ID,
	       --bau.bank_acct_use_id,
	      /* aba.AP_AMOUNT_TOLERANCE,
	       aba.AP_PERCENT_TOLERANCE,
	       aba.AR_AMOUNT_TOLERANCE,
	       aba.AR_PERCENT_TOLERANCE,
	       aba.CE_AMOUNT_TOLERANCE,
	       aba.CE_PERCENT_TOLERANCE,
	       nvl(bau.AP_USE_ENABLE_FLAG,'N'),
               nvl(bau.AR_USE_ENABLE_FLAG,'N'),
               nvl(bau.XTR_USE_ENABLE_FLAG,'N'),
               nvl(bau.PAY_USE_ENABLE_FLAG,'N'),
	       decode(bau.org_id, -1, null, bau.org_id),
	       bau.legal_entity_id,*/
	       -1 /* for JEC - replace cash account GL CCID here*/
	FROM ce_bank_accounts aba
	     --ce_bank_acct_uses bau
	WHERE aba.bank_branch_id = p_bank_branch_id
	AND aba.bank_account_id = NVL(p_bank_account_id, aba.bank_account_id)
	--AND aba.bank_account_id = bau.bank_account_id
        --and sysdate <= nvl(bau.end_date,sysdate)
	AND aba.account_classification = 'INTERNAL'
	--and aba.ACCOUNT_OWNER_ORG_ID = nvl(p_legal_entity_id,aba.ACCOUNT_OWNER_ORG_ID)
	and exists (select 1 from ce_bank_acct_uses_gt_v bau
			where bau.bank_account_id = aba.bank_account_id
			and sysdate <= nvl(bau.end_date,sysdate)
			and  (bau.org_id = nvl(p_org_id, bau.org_id) or
			     bau.legal_entity_id = nvl(p_legal_entity_id,bau.legal_entity_id)))
	order by aba.bank_account_id;

	--SELECT aba.bank_account_id
	--FROM ap_bank_accounts aba
	--WHERE aba.bank_branch_id = p_bank_branch_id
	--AND aba.bank_account_id = NVL(p_bank_account_id, aba.bank_account_id)
	--AND aba.account_type = get_security_account_type(aba.account_type);

  CURSOR r_bank_cursor(	p_statement_number_from       	VARCHAR2,
			p_statement_number_to		VARCHAR2,
			p_statement_date_from		DATE,
			p_statement_date_to		DATE,
			p_bank_account_id		NUMBER) IS
	SELECT	csh.statement_header_id,
		csh.statement_number,
		csh.statement_date,
		csh.check_digits,
		csh.gl_date,
		aba.currency_code,
		aba.multi_currency_allowed_flag,
		aba.check_digits,
		csh.rowid,
		NVL(csh.statement_complete_flag,'N')
	FROM	ce_bank_accts_gt_v aba, --ce_bank_accounts_v aba,
		ce_statement_headers csh
	WHERE	aba.bank_account_id = NVL(p_bank_account_id,aba.bank_account_id)
	AND	aba.bank_account_id = csh.bank_account_id
	AND	csh.statement_number
		BETWEEN NVL(p_statement_number_from,csh.statement_number)
		AND NVL(p_statement_number_to,csh.statement_number)
	AND	to_char(csh.statement_date,'YYYY/MM/DD')
		BETWEEN NVL(to_char(p_statement_date_from,'YYYY/MM/DD'),
				to_char(csh.statement_date,'YYYY/MM/DD'))
		AND NVL(to_char(p_statement_date_to,'YYYY/MM/DD'),
				to_char(csh.statement_date,'YYYY/MM/DD'))
	AND 	NVL(csh.statement_complete_flag,'N') = 'N'; -- Bug 2593830 added this condition

  CURSOR line_cursor(csh_statement_header_id  NUMBER) IS
	SELECT distinct 	sl.rowid,
		sl.statement_line_id,
		--cd.receivables_trx_id,
		--cd.receipt_method_id,
		--cd.create_misc_trx_flag,
		--cd.matching_against,
		--cd.correction_method,
		--rm.name,
		sl.exchange_rate_type,
		sl.exchange_rate_date,
		sl.exchange_rate,
		sl.currency_code,
		sl.trx_type,
		--decode(cd.PAYROLL_PAYMENT_FORMAT_ID, null, NVL(cd.reconcile_flag,'X'),
   		--	decode(cd.reconcile_flag,'PAY', 'PAY_EFT', NVL(cd.reconcile_flag,'X'))),
		'NONE',
		NULL,
		NULL,
		sl.original_amount,
		--ppt.payment_type_name,
		sl.je_status_flag, --JEC
		sl.accounting_date, --JEC
		--sl.accounting_event_id,  --JEC
		sl.cashflow_id,
		DECODE(sl.trx_type, 'NSF', 5, 'REJECTED', 5,
			decode(nvl(matching_against,'MISC'), 'MISC', 3, 'MS', 2, 1)) order_stmt_lns1,
		decode(nvl(matching_against,'MISC'), 'MISC', 0,
			to_char(sl.trx_date, 'J')) order_stmt_lns2
	FROM	--pay_payment_types ppt,
		--ar_receipt_methods rm,
		ce_statement_headers sh,
		ce_transaction_codes cd,
		ce_statement_lines sl
	WHERE	--rm.receipt_method_id(+) 	= cd.receipt_method_id
		--nvl(cd.RECONCILIATION_SEQUENCE (+) ,1) = 1
		nvl(cd.RECONCILIATION_SEQUENCE ,1) =
			(select nvl(min(tc.reconciliation_sequence),1)
			from ce_transaction_codes tc
			where  tc.bank_account_id = cd.bank_account_id
			and tc.trx_code = cd.trx_code)
	AND	cd.trx_code 	= sl.trx_code
	--AND	cd.payroll_payment_format_id = ppt.payment_type_id (+)
	AND	csh_statement_date
		between nvl(cd.start_date, csh_statement_date)
		and     nvl(cd.end_date, csh_statement_date)
	AND	sl.status 			= 'UNRECONCILED'
	AND	sl.statement_header_id 	= csh_statement_header_id
	and 	sh.statement_header_id = sl.statement_header_id
	and 	sh.bank_account_id = cd.bank_account_id
	ORDER BY order_stmt_lns1, order_stmt_lns2 desc;
	    --DECODE(sl.trx_type, 'NSF', 5, 'REJECTED', 5,
		--decode(nvl(cd.matching_against,'MISC'), 'MISC', 3, 'MS', 2, 1)),
		--decode(nvl(cd.matching_against,'MISC'), 'MISC', 0,
		--to_char(sl.trx_date, 'J')) desc;


  CURSOR trx_code_cursor(csl_statement_line_id  NUMBER, csh_bank_account_id NUMBER) IS
	SELECT	cd.receivables_trx_id,
		cd.receipt_method_id,
		cd.create_misc_trx_flag,
		cd.matching_against,
		cd.correction_method,
		rm.name,
		decode(cd.PAYROLL_PAYMENT_FORMAT_ID, null, NVL(cd.reconcile_flag,'X'),
   			decode(cd.reconcile_flag,'PAY', 'PAY_EFT', NVL(cd.reconcile_flag,'X'))),
		ppt.payment_type_name
	FROM	pay_payment_types ppt,
		ar_receipt_methods rm,
		ce_transaction_codes cd,
		ce_statement_lines sl
	WHERE	rm.receipt_method_id(+) 	= cd.receipt_method_id
	--AND	cd.transaction_code_id(+) 	= sl.trx_code_id
	AND	cd.trx_code (+)	= sl.trx_code
	AND	cd.payroll_payment_format_id = ppt.payment_type_id (+)
	AND	csh_statement_date
		between nvl(cd.start_date, csh_statement_date)
		and     nvl(cd.end_date, csh_statement_date)
	AND	sl.status 		= 'UNRECONCILED'
	AND	sl.statement_line_id 	= csl_statement_line_id
	AND	cd.bank_account_id 	= csh_bank_account_id
	ORDER BY cd.RECONCILIATION_SEQUENCE, DECODE(sl.trx_type, 'NSF', 5, 'REJECTED', 5,
		decode(nvl(cd.matching_against,'MISC'), 'MISC', 3, 'MS', 2, 1)),
		decode(nvl(cd.matching_against,'MISC'), 'MISC', 0,
		to_char(sl.trx_date, 'J')) desc;



  --
  -- LOCKING CURSORS
  --
  -- Journals
  --
  CURSOR lock_101 (x_call_mode VARCHAR2, trx_rowid VARCHAR2) IS
	SELECT	jel.je_header_id
	FROM	gl_je_lines 			jel,
		ce_statement_reconcils_all 	rec
	WHERE	jel.rowid 				= trx_rowid
	AND	rec.reference_id(+) 			= jel.je_line_num
	AND	rec.je_header_id(+)			= jel.je_header_id
	AND	rec.reference_type(+)			= 'JE_LINE'
	AND	NVL(rec.status_flag,X_call_mode)	= x_call_mode
	AND	NVL(rec.current_record_flag,'Y') 	= 'Y'
  FOR UPDATE OF jel.je_header_id NOWAIT;

  --
  -- Checks
  --
  CURSOR lock_200 (X_call_mode VARCHAR2,trx_rowid VARCHAR2) IS
	SELECT	c.check_id
	FROM	ap_checks_all 			c,
		ce_statement_reconcils_all 	rec
	WHERE	c.rowid 				= trx_rowid
	AND	rec.reference_id(+)			= c.check_id
	AND	rec.reference_type(+)			= 'PAYMENT'
	AND	NVL(rec.status_flag,x_call_mode)	= X_call_mode
	AND	NVL(rec.current_record_flag,'Y') 	= 'Y'
  FOR UPDATE OF c.check_id NOWAIT;

  --
  -- Check clearing
  --
  CURSOR clear_lock_200 (X_call_mode VARCHAR2,trx_rowid	VARCHAR2) IS
	SELECT	c.check_id, c.status_lookup_code
	FROM 	ap_checks_all c
	WHERE	c.rowid = trx_rowid
  FOR UPDATE OF c.check_id NOWAIT;

  --
  -- Receipts
  --
  CURSOR lock_222 (X_call_mode VARCHAR2,trx_rowid VARCHAR2) IS
	SELECT	crh.cash_receipt_history_id,
		cr.cash_receipt_id,
		NVL(crh.current_record_flag,'N')
	FROM	ar_cash_receipts_all 			cr,
		ar_cash_receipt_history_all		crh,
		ce_statement_reconcils_all 	rec
	WHERE	cr.cash_receipt_id		= crh.cash_receipt_id
	AND	crh.rowid 			= trx_rowid
	AND	rec.reference_id(+)		= crh.cash_receipt_history_id
	AND	rec.reference_type(+) = decode(arp_cashbook.receipt_debit_memo_reversed(crh.cash_receipt_id), 'Y', 'DM REVERSAL', 'RECEIPT')
	AND	NVL(rec.status_flag,X_call_mode) = X_call_mode
	AND	NVL(rec.current_record_flag,'Y') = 'Y'
	FOR UPDATE OF crh.cash_receipt_history_id,
			cr.cash_receipt_id NOWAIT;

  --
  -- XTR transactions
  --
CURSOR lock_185 (x_call_mode VARCHAR2, trx_rowid VARCHAR2) IS
	select xtr.settlement_summary_id
	FROM	xtr_settlement_summary        xtr,
		ce_statement_reconcils_all 	rec
	WHERE	xtr.rowid 				= trx_rowid
	AND	rec.reference_id(+) 			= xtr.settlement_summary_id
	AND	rec.reference_type(+)			= 'XTR_LINE'
	AND	NVL(rec.status_flag,X_call_mode)	= x_call_mode
	AND	NVL(rec.current_record_flag,'Y') 	= 'Y'
  FOR UPDATE OF xtr.settlement_summary_id NOWAIT;


  --
  -- Receipts clearing
  --
  CURSOR clear_lock_222 (X_call_mode VARCHAR2,trx_rowid VARCHAR2) IS
	SELECT	crh.cash_receipt_history_id,
		cr.cash_receipt_id,
		NVL(crh.current_record_flag,'N')
	FROM	ar_cash_receipts_all 		cr,
		ar_cash_receipt_history_all	crh
	WHERE	cr.cash_receipt_id		= crh.cash_receipt_id
	AND	crh.rowid 			= trx_rowid
	FOR UPDATE OF crh.cash_receipt_history_id,
			  cr.cash_receipt_id NOWAIT;

  --
  -- Statement lines
  --
  CURSOR lock_260 (X_call_mode VARCHAR2,trx_rowid VARCHAR2) IS
	SELECT	cl.statement_line_id
	FROM	ce_statement_lines                   cl,
		ce_statement_reconcils_all         rec
	WHERE	cl.rowid                             = trx_rowid
	AND	rec.reference_id(+)                  = cl.statement_line_id
	AND	rec.reference_type(+)                = 'STATEMENT'
	AND	NVL(rec.status_flag,x_call_mode)     = X_call_mode
	AND	NVL(rec.current_record_flag,'Y')     = 'Y'
  FOR UPDATE OF cl.statement_line_id NOWAIT;

  --
  -- Statement line clearing
  --
  CURSOR clear_lock_260 (X_call_mode VARCHAR2,trx_rowid VARCHAR2) IS
	SELECT	cl.statement_line_id
	FROM	ce_statement_lines              cl
	WHERE	cl.rowid                        = trx_rowid
  FOR UPDATE OF cl.statement_line_id NOWAIT;

  --
  -- cashflow transaction
  --
  CURSOR lock_260_cf (X_call_mode VARCHAR2,trx_rowid VARCHAR2) IS
	SELECT	cc.cashflow_id
	FROM	ce_cashflows		cc,
		ce_statement_reconcils_all         rec
	WHERE	cc.rowid                             = trx_rowid
	AND	rec.reference_id(+)                  = cc.cashflow_id
	AND	rec.reference_type(+)                = 'CASHFLOW'
	AND	NVL(rec.status_flag,x_call_mode)     = X_call_mode
	AND	NVL(rec.current_record_flag,'Y')     = 'Y'
  FOR UPDATE OF cc.cashflow_id NOWAIT;

  --
  -- cashflow clearing
  --
  CURSOR clear_lock_260_cf (X_call_mode VARCHAR2,trx_rowid VARCHAR2) IS
	SELECT	cc.cashflow_id
	FROM	ce_cashflows		cc
	WHERE	cc.rowid                        = trx_rowid
  FOR UPDATE OF cc.cashflow_id NOWAIT;

  --
  -- Payroll
  --
  CURSOR lock_801 (X_call_mode VARCHAR2,trx_rowid VARCHAR2) IS
	SELECT	paa.assignment_action_id
	FROM	pay_assignment_actions		paa,
		ce_statement_reconcils_all	rec
	WHERE	paa.rowid                            = trx_rowid
	AND	rec.reference_id(+)                  = paa.assignment_action_id
	AND	rec.reference_type(+)                = 'PAY'
	AND	NVL(rec.status_flag,x_call_mode)     = X_call_mode
	AND	NVL(rec.current_record_flag,'Y')     = 'Y'
  FOR UPDATE OF paa.assignment_action_id NOWAIT;

  --
  -- Payroll line clearing
  --
  CURSOR clear_lock_801 (X_call_mode VARCHAR2,trx_rowid VARCHAR2) IS
	SELECT	paa.assignment_action_id
	FROM	pay_assignment_actions paa
	WHERE	paa.rowid = trx_rowid
  FOR UPDATE OF paa.assignment_action_id NOWAIT;

  --
  -- Remittance batches
  --
  CURSOR LOCK_BATCH_RECEIPTS (trx_rowid VARCHAR2) IS
	SELECT	crh.cash_receipt_history_id,
		cr.cash_receipt_id,
		b.batch_id batch_id
	FROM	AR_CASH_RECEIPTS_all CR,
		AR_CASH_RECEIPT_HISTORY_all CRH,
		AR_CASH_RECEIPT_HISTORY_all CRH2,
		AR_BATCHES_all B
	WHERE	b.rowid = trx_rowid
	AND	crh.cash_receipt_history_id = decode(crh.batch_id,
			null, crh2.reversal_cash_receipt_hist_id,
			crh2.cash_receipt_history_id)
	AND	nvl(crh.status, 'REMITTED') <> 'REVERSED'
	AND	crh.cash_receipt_id = crh2.cash_receipt_id
	AND	cr.cash_receipt_id = crh.cash_receipt_id
	AND	crh2.batch_id = b.batch_id
  FOR UPDATE OF crh.cash_receipt_history_id,
		cr.cash_receipt_id,
		b.batch_id NOWAIT;

  CURSOR Receipt_Amounts (X_batch_id NUMBER) IS
	SELECT	SUM(a.bank_account_amount)
	FROM	ce_222_txn_for_batch_v a
	WHERE	a.batch_id = x_batch_id
	AND	nvl(a.status, 'REMITTED') <> 'REVERSED';

  --
  -- Payment batches
  --
  CURSOR LOCK_BATCH_CHECKS (trx_rowid VARCHAR2) IS
	SELECT	c.check_id,
		b.PAYMENT_INSTRUCTION_ID
	FROM	AP_CHECKS_all C,
		iby_pay_instructions_all  B
	WHERE	c.PAYMENT_INSTRUCTION_ID = b.PAYMENT_INSTRUCTION_ID AND
		b.rowid = trx_rowid
	AND	nvl(c.status_lookup_code, 'NEGOTIABLE') <> 'VOIDED'
  FOR UPDATE OF c.check_id, b.PAYMENT_INSTRUCTION_ID NOWAIT;

/* bug 5350073
	SELECT	c.check_id,
		b.checkrun_id
	FROM	AP_CHECKS_all C,
		AP_INVOICE_SELECTION_CRITERIA B
	WHERE	c.checkrun_id = b.checkrun_id AND
		b.rowid = trx_rowid
	AND	nvl(c.status_lookup_code, 'NEGOTIABLE') <> 'VOIDED'
  FOR UPDATE OF c.check_id, b.checkrun_id NOWAIT;*/

-- bug 5350073 ce_available_transactions_tmp is not populated when manually reconcile IBY batches
  CURSOR CHECK_AMOUNTS (X_batch_id NUMBER) IS
	SELECT	SUM(bank_account_amount)
	FROM	CE_200_TRANSACTIONS_V
	--FROM	ce_available_transactions_tmp
	WHERE	batch_id = X_batch_id
	AND	nvl(status, 'NEGOTIABLE') <> 'VOIDED'
	AND	application_id = 200;
	--AND	NVL(reconciled_status_flag, 'N') = 'N';

	/* for SEPA ER 6700007 begins */
  CURSOR LOCK_GROUP_CHECKS (trx_rowid VARCHAR2,X_LOGICAL_GROUP_REFERENCE VARCHAR2) IS
	SELECT	ACA.check_id,
		b.PAYMENT_INSTRUCTION_ID
	FROM	AP_CHECKS_all ACA,
		iby_pay_instructions_all  B,
		iby_payments_all IPA
	WHERE	ACA.PAYMENT_INSTRUCTION_ID = b.PAYMENT_INSTRUCTION_ID AND
		b.rowid = trx_rowid
	AND	nvl(ACA.status_lookup_code, 'NEGOTIABLE') <> 'VOIDED'
	AND     IPA.PAYMENT_INSTRUCTION_ID  = b.PAYMENT_INSTRUCTION_ID
	AND     IPA.PAYMENT_ID = ACA.PAYMENT_ID
	AND      IPA.LOGICAL_GROUP_REFERENCE = X_LOGICAL_GROUP_REFERENCE
  FOR UPDATE OF ACA.check_id, b.PAYMENT_INSTRUCTION_ID NOWAIT;


  CURSOR CHECK_group_AMOUNTS (X_batch_id NUMBER,X_LOGICAL_GROUP_REFERENCE VARCHAR2) IS
	SELECT	SUM(bank_account_amount)
	FROM	CE_200_TRANSACTIONS_V catv
	WHERE	batch_id = X_batch_id
	AND	nvl(status, 'NEGOTIABLE') <> 'VOIDED'
	AND	application_id = 200
     AND    EXISTS ( SELECT 1
                    FROM iby_payments_all IPA ,AP_CHECKS_ALL ACA
		    WHERE ACA.CHECK_ID   =catv.trx_id
		      AND ACA.PAYMENT_INSTRUCTION_ID  = X_batch_id
		      AND IPA.PAYMENT_INSTRUCTION_ID  = X_batch_id
		      AND IPA.PAYMENT_ID = ACA.PAYMENT_ID
		      AND IPA.LOGICAL_GROUP_REFERENCE = X_LOGICAL_GROUP_REFERENCE);

	/* for SEPA ER 6700007 ends */

  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN
	RETURN '$Revision: 120.62.12010000.19 $';
  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN
	RETURN G_spec_revision;
  END spec_revision;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       set_<application_id>/all					|
|                                                                       |
|  HISTORY                                                              |
|       04-MAR-96        Kai Pigg		Created                 |
 --------------------------------------------------------------------- */
  PROCEDURE set_101 IS
  BEGIN
    CE_AUTO_BANK_MATCH.yes_101 := 1;
  END set_101;

  PROCEDURE set_200 IS
  BEGIN
    CE_AUTO_BANK_MATCH.yes_200 := 1;
  END set_200;


  -- FOR SEPA ER 6700007
  PROCEDURE set_200_GROUP IS
  BEGIN
    CE_AUTO_BANK_MATCH.yes_200_GROUP := 1;
  END set_200_GROUP;

  PROCEDURE set_222 IS
  BEGIN
    CE_AUTO_BANK_MATCH.yes_222 := 1;
  END set_222;

  PROCEDURE set_260 IS
  BEGIN
    CE_AUTO_BANK_MATCH.yes_260 := 1;
  END set_260;

  PROCEDURE set_801 IS
  BEGIN
    CE_AUTO_BANK_MATCH.yes_801 := 1;
  END set_801;

  PROCEDURE set_999 IS
  BEGIN
    CE_AUTO_BANK_MATCH.yes_999 := 1;
  END set_999;

  PROCEDURE set_all IS
  BEGIN
    CE_AUTO_BANK_MATCH.yes_101 := 1;
    CE_AUTO_BANK_MATCH.yes_200 := 1;
    CE_AUTO_BANK_MATCH.yes_222 := 1;
    CE_AUTO_BANK_MATCH.yes_260 := 1;
    CE_AUTO_BANK_MATCH.yes_801 := 1;
    CE_AUTO_BANK_MATCH.yes_999 := 1;
    CE_AUTO_BANK_MATCH.yes_200_GROUP := 1;  -- FOR SEPA ER 6700007
  END set_all;

  PROCEDURE set_inverse_rate(inverse_rate VARCHAR2) IS
  BEGIN
    CE_AUTO_BANK_MATCH.display_inverse_rate := inverse_rate;
  END set_inverse_rate;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       unset_<application_id>/all					|
 --------------------------------------------------------------------- */
  PROCEDURE unset_101 IS
  BEGIN
    CE_AUTO_BANK_MATCH.yes_101 := 0;
  END unset_101;

  PROCEDURE unset_200 IS
  BEGIN
    CE_AUTO_BANK_MATCH.yes_200 := 0;
  END unset_200;

 -- FOR SEPA ER 6700007
  PROCEDURE unset_200_group IS
  BEGIN
    CE_AUTO_BANK_MATCH.yes_200_GROUP := 0;
  END unset_200_group;

  PROCEDURE unset_222 IS
  BEGIN
    CE_AUTO_BANK_MATCH.yes_222 := 0;
  END unset_222;

  PROCEDURE unset_260 IS
  BEGIN
    CE_AUTO_BANK_MATCH.yes_260 := 0;
  END unset_260;

  PROCEDURE unset_801 IS
  BEGIN
    CE_AUTO_BANK_MATCH.yes_801 := 0;
  END unset_801;

  PROCEDURE unset_999 IS
  BEGIN
    CE_AUTO_BANK_MATCH.yes_999 := 0;
  END unset_999;

  PROCEDURE unset_all IS
  BEGIN
    CE_AUTO_BANK_MATCH.yes_101 := 0;
    CE_AUTO_BANK_MATCH.yes_200 := 0;
    CE_AUTO_BANK_MATCH.yes_222 := 0;
    CE_AUTO_BANK_MATCH.yes_260 := 0;
    CE_AUTO_BANK_MATCH.yes_801 := 0;
    CE_AUTO_BANK_MATCH.yes_999 := 0;
    CE_AUTO_BANK_MATCH.yes_200_GROUP :=  0;  -- FOR SEPA ER 6700007
  END unset_all;

/* --------------------------------------------------------------------
|  PRIVATE FUNCTIONS                                                    |
|       get_<application_id>						|
 --------------------------------------------------------------------- */
  FUNCTION get_101 RETURN NUMBER IS
  BEGIN
    RETURN CE_AUTO_BANK_MATCH.yes_101;
  END get_101;

  FUNCTION get_200 RETURN NUMBER IS
  BEGIN
    RETURN CE_AUTO_BANK_MATCH.yes_200;
  END get_200;

-- FOR SEPA ER 6700007
   FUNCTION get_200_GROUP RETURN NUMBER IS
  BEGIN
    RETURN CE_AUTO_BANK_MATCH.yes_200_GROUP;
  END get_200_GROUP;

  FUNCTION get_222 RETURN NUMBER IS
  BEGIN
    RETURN CE_AUTO_BANK_MATCH.yes_222;
  END get_222;

  FUNCTION get_260 RETURN NUMBER IS
  BEGIN
    RETURN CE_AUTO_BANK_MATCH.yes_260;
  END get_260;

  FUNCTION get_801 RETURN NUMBER IS
  BEGIN
    RETURN CE_AUTO_BANK_MATCH.yes_801;
  END get_801;

  FUNCTION get_999 RETURN NUMBER IS
  BEGIN
    RETURN CE_AUTO_BANK_MATCH.yes_999;
  END get_999;

  FUNCTION get_security_account_type(p_account_type VARCHAR2) RETURN VARCHAR2 IS
    v_acct_type		VARCHAR2(25);
  BEGIN
    v_acct_type :=  FND_PROFILE.VALUE_WNPS('CE_BANK_ACCOUNT_SECURITY_ACCESS');
    IF (v_acct_type = 'ALL' AND p_account_type <> 'EXTERNAL') THEN
      v_acct_type := p_account_type;
    END IF;
    RETURN v_acct_type;
  END get_security_account_type;

  FUNCTION get_inverse_rate RETURN VARCHAR2 IS
  BEGIN
    RETURN CE_AUTO_BANK_MATCH.display_inverse_rate;
  END get_inverse_rate;

/* --------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|       ce_check_numeric       						|
|									|
|  DESCRIPTION								|
|	check if check_value is a numeric value				|
|	  - check if the bank_trx_number is numeric or alphanumeric	|
|	  - value such as '10084325 23580029' will be considered as 	|
|	       alphanumeric because of the space in between the two #	|
|									|
|  RETURN								|
|       0 - numeric value						|
|       1 - alphanumeric value						|
|									|
|  CALLED BY								|
|       trx_match							|
 --------------------------------------------------------------------- */
  /* check if check_value is a numeric value */
  FUNCTION ce_check_numeric(check_value VARCHAR2,
                                    pos_from NUMBER,
                                    pos_for NUMBER)  RETURN VARCHAR2  IS
      num_check NUMBER;
  BEGIN
      num_check  := TO_NUMBER(substr(check_value,pos_from,pos_for));
      RETURN('0');
          EXCEPTION
    WHEN OTHERS THEN
      RETURN('1');

  END ce_check_numeric;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	set_single_org							|
|									|
|  DESCRIPTION								|
|	set to single org for AR/AP processing when
|	  CE_AUTO_BANK_REC.G_org_id is null
|       - always use base table (_ALL) for AP/AR table when try to find
|         a match.  Our ce_security_profile_gt will handle the security	|
|	- set single org is needed when call AR/AP API, since we cannot
| 	  pass the org_id
|  CALLED BY								|
|	stmtline_match,	match_engine, match_process 			|
 --------------------------------------------------------------------- */

PROCEDURE set_single_org(x_org_id	number) IS
current_org_id		number;
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.set_single_org  x_org_id =' || x_org_id);

    select mo_global.GET_CURRENT_ORG_ID
    into current_org_id
    from dual;

    cep_standard.debug('current_org_id =' ||current_org_id );

    -- bug 3782741 set single org, since AR will not allow org_id to be passed
    --IF CE_AUTO_BANK_MATCH.bau_org_id is not null THEN
    --IF CE_AUTO_BANK_REC.G_org_id is not null THEN (this is set at ceabrdrb ce_auto_bank_rec)
    IF (x_org_id is not null) THEN
      IF  ((current_org_id is null) or (x_org_id <> current_org_id )) THEN
        mo_global.set_policy_context('S',x_org_id);
        cep_standard.debug('set current_org_id to ' ||x_org_id );
      END IF;
    END IF;

  cep_standard.debug('<<CE_AUTO_BANK_MATCH.set_single_org');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.set_single_org' );
    RAISE;
END set_single_org;
/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	set_multi_org							|
|									|
|  DESCRIPTION								|
|	set to multi org after processing AR/AP
|  CALLED BY								|
|									|
 --------------------------------------------------------------------- */

PROCEDURE set_multi_org(x_org_id	number) IS

BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.set_multi_org  x_org_id =' || x_org_id);

  MO_GLOBAL.init('CE');

  cep_standard.debug('<<CE_AUTO_BANK_MATCH.set_multi_org');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.set_multi_org' );
    RAISE;
END set_multi_org;

/* ----------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       get_receivables_org_id                                          |
|                                                                       |
|  DESCRIPTION                                                          |
|       find the org_id for a RECEIVABLES_TRX_ID      			|
|  CALL BY
|       create_misc_trx
 --------------------------------------------------------------------- */
PROCEDURE get_receivables_org_id (X_ORG_ID OUT NOCOPY NUMBER ) IS
x_receivables_trx_id number;

BEGIN
  cep_standard.debug( '>>CE_AUTO_BANK_MATCH.get_receivables_org_id' );
  cep_standard.debug( 'CE_AUTO_BANK_MATCH.csl_receivables_trx_id= '|| CE_AUTO_BANK_MATCH.csl_receivables_trx_id||
			',CE_AUTO_BANK_MATCH.trx_org_id='||CE_AUTO_BANK_MATCH.trx_org_id  );

   x_receivables_trx_id :=  nvl(CE_AUTO_BANK_MATCH.csl_receivables_trx_id,
				CE_AUTO_BANK_REC.G_receivables_trx_id);

  cep_standard.debug( 'x_receivables_trx_id= '|| x_receivables_trx_id);

-- bug 5722367 removed the reference to ar_receivables_trx_all table to ar_receivables_trx
  if (x_receivables_trx_id is not null) THEN
    select org_id
    into X_ORG_ID
    from AR_RECEIVABLES_TRX
    where RECEIVABLES_TRX_ID = x_receivables_trx_id;

    cep_standard.debug( 'x_ORG_ID= '|| X_ORG_ID);

  ELSE
    cep_standard.debug('receivables_trx_id is missing');
    CE_RECONCILIATION_ERRORS_PKG.insert_row(
	   CE_AUTO_BANK_MATCH.csh_statement_header_id,
	   CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_MISSING_REC_ACT_ID');

  END IF;

  cep_standard.debug( '<<CE_AUTO_BANK_MATCH.get_receivables_org_id' );
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    cep_standard.debug('receivables_trx_id does not exists');
    CE_RECONCILIATION_ERRORS_PKG.insert_row(
	   CE_AUTO_BANK_MATCH.csh_statement_header_id,
	   CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_NO_REC_ACT_ID');
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.get_receivables_org_id' );
    RAISE;
END get_receivables_org_id;

/* --------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|       match_oi_trx							|
|									|
|  DESCRIPTION								|
|	Matching open interface transactions by date, currency and	|
|	amount.								|
|									|
|  CALLED BY								|
|       trx_match							|
 --------------------------------------------------------------------- */
PROCEDURE match_oi_trx(
                tx_type VARCHAR2,
                tx_curr VARCHAR2,
                tx_match_amount NUMBER,
                precision NUMBER,
                no_of_matches OUT NOCOPY NUMBER) IS
BEGIN
  cep_standard.debug( '>>CE_AUTO_BANK_MATCH.match_oi_trx' );

-- match xtr transaction first then non-xtr OI trx
-- bug 4914608 some bank acct used by xtr might not have xtr_use_enable_flag = Y
  IF ((CE_AUTO_BANK_REC.G_legal_entity_id is not null) or
  --IF ((CE_AUTO_BANK_MATCH.bau_legal_entity_id is not null) AND
	(CE_AUTO_BANK_MATCH.bau_xtr_use_enable_flag = 'Y'))  THEN
  cep_standard.debug( ' use ce_185_transactions_v CE_AUTO_BANK_MATCH.csl_trx_date='|| CE_AUTO_BANK_MATCH.csl_trx_date);
    SELECT  catv.trx_id,
          catv.cash_receipt_id,
          catv.row_id,
          catv.trx_date,
          catv.currency_code,
          catv.bank_account_amount,
          catv.base_amount,
          catv.status,
          nvl(catv.amount_cleared,0),
          catv.trx_type,
          1,
          catv.trx_currency_type,
          catv.amount,
          catv.clearing_trx_type,
          catv.exchange_rate,
          catv.exchange_rate_date,
          catv.exchange_rate_type,
	  catv.legal_entity_id,
 	  catv.CE_BANK_ACCT_USE_ID,
          catv.seq_id
    INTO    CE_AUTO_BANK_MATCH.trx_id,
          CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
          CE_AUTO_BANK_MATCH.trx_rowid,
          CE_AUTO_BANK_MATCH.trx_date,
          CE_AUTO_BANK_MATCH.trx_currency_code,
          CE_AUTO_BANK_MATCH.trx_amount,
          CE_AUTO_BANK_MATCH.trx_base_amount,
          CE_AUTO_BANK_MATCH.trx_status,
          CE_AUTO_BANK_MATCH.trx_cleared_amount,
          CE_AUTO_BANK_MATCH.csl_match_type,
          no_of_matches,
          CE_AUTO_BANK_MATCH.trx_currency_type,
          CE_AUTO_BANK_MATCH.trx_curr_amount,
          CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
          CE_AUTO_BANK_MATCH.trx_exchange_rate,
          CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
          CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
          CE_AUTO_BANK_MATCH.trx_legal_entity_id,
 	  CE_AUTO_BANK_MATCH.trx_bank_acct_use_id,
	  CE_AUTO_BANK_MATCH.gt_seq_id
    --FROM    ce_185_transactions_v catv
    FROM    ce_available_transactions_tmp catv
    WHERE   catv.trx_type = tx_type
    AND	catv.legal_entity_id = nvl(CE_AUTO_BANK_REC.G_legal_entity_id, catv.legal_entity_id)
    --AND	catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
    AND     catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
    AND     to_char(catv.trx_date,'YYYY/MM/DD') =
                to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
    AND     catv.currency_code = tx_curr
    AND     round(catv.amount, precision) = tx_match_amount
    AND	    catv.application_id = 185
    AND	    NVL(catv.reconciled_status_flag, 'N') = 'N';
  END IF;

  -- no xtr match from above query
  IF ( CE_AUTO_BANK_MATCH.trx_id is null) THEN
  cep_standard.debug( ' use ce_999_transactions_v ' );

    SELECT  catv.trx_id,
          catv.cash_receipt_id,
          catv.row_id,
          catv.trx_date,
          catv.currency_code,
          catv.bank_account_amount,
          catv.base_amount,
          catv.status,
          nvl(catv.amount_cleared,0),
          catv.trx_type,
          1,
          catv.trx_currency_type,
          catv.amount,
          catv.clearing_trx_type,
          catv.exchange_rate,
          catv.exchange_rate_date,
          catv.exchange_rate_type,
	  catv.org_id,
	  catv.legal_entity_id,
 	  catv.CE_BANK_ACCT_USE_ID,
	  catv.seq_id
    INTO    CE_AUTO_BANK_MATCH.trx_id,
          CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
          CE_AUTO_BANK_MATCH.trx_rowid,
          CE_AUTO_BANK_MATCH.trx_date,
          CE_AUTO_BANK_MATCH.trx_currency_code,
          CE_AUTO_BANK_MATCH.trx_amount,
          CE_AUTO_BANK_MATCH.trx_base_amount,
          CE_AUTO_BANK_MATCH.trx_status,
          CE_AUTO_BANK_MATCH.trx_cleared_amount,
          CE_AUTO_BANK_MATCH.csl_match_type,
          no_of_matches,
          CE_AUTO_BANK_MATCH.trx_currency_type,
          CE_AUTO_BANK_MATCH.trx_curr_amount,
          CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
          CE_AUTO_BANK_MATCH.trx_exchange_rate,
          CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
          CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
          CE_AUTO_BANK_MATCH.trx_org_id,
          CE_AUTO_BANK_MATCH.trx_legal_entity_id,
 	  CE_AUTO_BANK_MATCH.trx_bank_acct_use_id,
	  CE_AUTO_BANK_MATCH.gt_seq_id
    --FROM    ce_999_transactions_v catv
    FROM    ce_available_transactions_tmp catv
    WHERE   catv.trx_type = tx_type
    --AND	catv.org_id = CE_AUTO_BANK_REC.G_org_id
    --AND	catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
    AND     catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
    AND     to_char(catv.trx_date,'YYYY/MM/DD') =
                to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
    AND     catv.currency_code = tx_curr
    AND     round(catv.amount, precision) = tx_match_amount
    AND	    catv.application_id = 999
    AND     NVL(catv.reconciled_status_flag, 'N') = 'N';
  END IF;
  cep_standard.debug( '<<CE_AUTO_BANK_MATCH.match_oi_trx' );
END match_oi_trx;

/* --------------------------------------------------------------------
|  PRIVATE FUNCTION                                                     |
|       validate_exchange_details                                       |
|                                                                       |
|  DESCRIPTION                                                          |
|       If the user selects the exhange rate type of 'User', they must  |
|       also provide the exchange rate.  If the type is anything other  |
|       than user, the exchange rate date must be provided.             |
|                                                                       |
|  CALLED BY                                                            |
|       trx_validation                                                  |
 --------------------------------------------------------------------- */
FUNCTION validate_exchange_details RETURN BOOLEAN IS
  error_found 		BOOLEAN;
  x_exchange_rate 	GL_DAILY_RATES.conversion_rate%TYPE;
  fixed_relation  	BOOLEAN;
  curr_relation		VARCHAR2(30);
fixed_relation_temp     varchar2(30);
BEGIN

  cep_standard.debug('>>CE_AUTO_BANK_MATCH.validate_exchange_details');
  error_found := FALSE;

  --
  -- TRX Currency needs to be the same that the SL currency
  --

  IF (CE_AUTO_BANK_MATCH.csl_currency_code IS NULL) THEN
    IF (CE_AUTO_BANK_MATCH.trx_currency_type = 'BANK') THEN
      CE_AUTO_BANK_MATCH.csl_currency_code :=
		CE_AUTO_BANK_MATCH.aba_bank_currency;
    ELSIF (CE_AUTO_BANK_MATCH.trx_currency_type = 'FOREIGN') THEN
      CE_AUTO_BANK_MATCH.csl_currency_code :=
		CE_AUTO_BANK_MATCH.trx_currency_code;
    END IF;
  END IF;

  IF (CE_AUTO_BANK_MATCH.trx_currency_code <>
	NVL(CE_AUTO_BANK_MATCH.csl_currency_code,
	    CE_AUTO_BANK_MATCH.trx_currency_code)) THEN
  cep_standard.debug('Inconsistent currencies');

    CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_DIFFERENT_CURRENCY');
    return(FALSE);
  END IF;

  --
  -- When Fixed relationship is found, exchange info is not mandatory.
  --
  cep_standard.debug('CE_AUTO_BANK_REC.G_functional_currency '||CE_AUTO_BANK_REC.G_functional_currency ||
			', CE_AUTO_BANK_MATCH.csl_currency_code ' ||CE_AUTO_BANK_MATCH.csl_currency_code);

  cep_standard.debug('CE_AUTO_BANK_MATCH.csl_exchange_rate_date '||CE_AUTO_BANK_MATCH.csl_exchange_rate_date ||
			', CE_AUTO_BANK_MATCH.csl_trx_date ' ||CE_AUTO_BANK_MATCH.csl_trx_date);

  BEGIN
	gl_currency_api.get_relation(CE_AUTO_BANK_REC.G_functional_currency,
			     CE_AUTO_BANK_MATCH.csl_currency_code,
			     nvl(CE_AUTO_BANK_MATCH.csl_exchange_rate_date,
					 CE_AUTO_BANK_MATCH.csl_trx_date),
			     fixed_relation,
			     curr_relation);
  EXCEPTION
  WHEN OTHERS THEN
	cep_standard.debug('Cannot find relationship for the give curr');
	fixed_relation := FALSE;
	curr_relation  := 'OTHER';
  END;
  IF fixed_relation THEN
	fixed_relation_temp := 'TRUE';
  ELSE
	fixed_relation_temp := 'FALSE';
  END IF;
  cep_standard.debug('fixed_relation_temp ' ||fixed_relation_temp || ', curr_relation '||curr_relation);

  IF (fixed_relation) THEN
    CE_AUTO_BANK_MATCH.csl_exchange_rate_type	:= 'EMU FIXED';
    CE_AUTO_BANK_MATCH.csl_exchange_rate_date	:=
			     nvl(CE_AUTO_BANK_MATCH.csl_exchange_rate_date,
				 CE_AUTO_BANK_MATCH.csl_trx_date);
  ELSE -- non-emu

    -- If we have a foreign currency trx and line does not have ANY xrate info
    -- we calculate the exchange rate and provide that as 'User' rate
    -- (International)

    IF (CE_AUTO_BANK_MATCH.trx_currency_type = 'FOREIGN') AND
	(CE_AUTO_BANK_MATCH.csl_exchange_rate_type 	IS NULL AND
	 CE_AUTO_BANK_MATCH.csl_exchange_rate 		IS NULL AND
	 CE_AUTO_BANK_MATCH.csl_exchange_rate_date 	IS NULL) THEN

      CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
	  CE_AUTO_BANK_MATCH.csl_trx_date;
      CE_AUTO_BANK_MATCH.csl_exchange_rate_type := 'User';
      CE_AUTO_BANK_MATCH.csl_exchange_rate :=
	  CE_AUTO_BANK_MATCH.trx_amount/CE_AUTO_BANK_MATCH.trx_curr_amount;
			return(TRUE);

    ELSIF (CE_AUTO_BANK_MATCH.trx_currency_type = 'BANK' AND
	CE_AUTO_BANK_MATCH.csl_exchange_rate_type	IS NULL AND
	CE_AUTO_BANK_MATCH.csl_exchange_rate		IS NULL AND
	CE_AUTO_BANK_MATCH.csl_exchange_rate_date	IS NULL AND
	CE_AUTO_BANK_MATCH.csl_original_amount		IS NULL) THEN

      cep_standard.debug('++CE_AUTO_BANK_REC.G_exchange_rate_type = ' ||
	  CE_AUTO_BANK_REC.G_exchange_rate_type);
      cep_standard.debug('++CE_AUTO_BANK_REC.G_exchange_rate_date = ' ||
	  CE_AUTO_BANK_REC.G_exchange_rate_date);

      IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type = 'CASHFLOW') THEN
        CE_AUTO_BANK_MATCH.csl_exchange_rate_type := CE_AUTO_BANK_REC.G_CASHFLOW_EXCHANGE_RATE_TYPE;
      ELSE
        CE_AUTO_BANK_MATCH.csl_exchange_rate_type := CE_AUTO_BANK_REC.G_exchange_rate_type;

      END IF;

      IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type = 'CASHFLOW') THEN
	IF (CE_AUTO_BANK_MATCH.trx_reference_type = 'STMT')  THEN  -- JEC
	  IF (CE_AUTO_BANK_REC.G_BSC_EXCHANGE_DATE_TYPE = 'CFD') THEN
	    CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
					CE_AUTO_BANK_MATCH.trx_date;
	  ELSIF (CE_AUTO_BANK_REC.G_BSC_EXCHANGE_DATE_TYPE = 'CLD') THEN
		/* The statement line trx date is used for the cleared date in autoReconciliation
		So, we will use the matching transaction cleared date  when the cashflow exchange
		date type is set to use the cleared date.  If there is no cleared date, then the
		statement line transaction date will be used. */

	    CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
			NVL(CE_AUTO_BANK_MATCH.trx_cleared_date,CE_AUTO_BANK_MATCH.csl_trx_date);
			--NVL(CE_AUTO_BANK_MATCH.trx_cleared_date,CE_AUTO_BANK_MATCH.trx_date);
	  ELSIF (CE_AUTO_BANK_REC.G_BSC_EXCHANGE_DATE_TYPE = 'BSD') THEN
	    CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
					CE_AUTO_BANK_MATCH.csh_statement_date;
	  ELSIF (CE_AUTO_BANK_REC.G_BSC_EXCHANGE_DATE_TYPE = 'BSG') THEN
	    CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
					CE_AUTO_BANK_MATCH.csh_statement_gl_date;
	  END IF;


	ELSE  -- BAT
	  IF (CE_AUTO_BANK_REC.G_BAT_EXCHANGE_DATE_TYPE = 'CFD') THEN
	    CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
					CE_AUTO_BANK_MATCH.trx_date;
	  ELSIF (CE_AUTO_BANK_REC.G_BAT_EXCHANGE_DATE_TYPE = 'AVD') THEN
	    CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
					CE_AUTO_BANK_MATCH.trx_value_date;
	  ELSIF (CE_AUTO_BANK_REC.G_BAT_EXCHANGE_DATE_TYPE = 'CLD') THEN
	    CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
			NVL(CE_AUTO_BANK_MATCH.trx_cleared_date,CE_AUTO_BANK_MATCH.csl_trx_date);
			--NVL(CE_AUTO_BANK_MATCH.trx_cleared_date,CE_AUTO_BANK_MATCH.trx_date);
	  ELSIF (CE_AUTO_BANK_REC.G_BAT_EXCHANGE_DATE_TYPE = 'BSD') THEN
	    CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
					CE_AUTO_BANK_MATCH.csh_statement_date;
	  ELSIF (CE_AUTO_BANK_REC.G_BAT_EXCHANGE_DATE_TYPE = 'BSG') THEN
	    CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
					CE_AUTO_BANK_MATCH.csh_statement_gl_date;
          ELSIF (CE_AUTO_BANK_REC.G_BAT_EXCHANGE_DATE_TYPE = 'SLD') THEN
	    CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
					CE_AUTO_BANK_MATCH.csl_trx_date;
	  ELSIF (CE_AUTO_BANK_REC.G_BAT_EXCHANGE_DATE_TYPE = 'TRX') THEN
	    CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
					CE_AUTO_BANK_MATCH.trx_deposit_date;
	  END IF;

        END IF;
      ELSE  -- not cashflow

        IF (CE_AUTO_BANK_REC.G_exchange_rate_date = 'SLD') THEN
	  CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
		CE_AUTO_BANK_MATCH.csl_trx_date;
        ELSIF (CE_AUTO_BANK_REC.G_exchange_rate_date = 'BSD') THEN
	  CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
		CE_AUTO_BANK_MATCH.csh_statement_date;
        ELSIF (CE_AUTO_BANK_REC.G_exchange_rate_date = 'BGD') THEN
	  CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
		CE_AUTO_BANK_MATCH.csh_statement_gl_date;
        ELSIF (CE_AUTO_BANK_REC.G_exchange_rate_date = 'TCD') THEN
	  CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
		CE_AUTO_BANK_MATCH.trx_date;
        ELSIF (CE_AUTO_BANK_REC.G_exchange_rate_date = 'TXD') THEN
	  CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date;
        ELSIF (CE_AUTO_BANK_REC.G_exchange_rate_date = 'TGD') THEN
          CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
		CE_AUTO_BANK_MATCH.trx_gl_date;
        END IF;


      END IF;

      CE_AUTO_BANK_MATCH.foreign_exchange_defaulted := 'Y';

    ELSE
	  cep_standard.debug('MATCH.CSL_xtype: '||CE_AUTO_BANK_MATCH.csl_exchange_rate_type);
	  cep_standard.debug('MATCH.CSL_xdate: '||CE_AUTO_BANK_MATCH.csl_exchange_rate_date);

      --
      -- line must have either xrate, original_amount or (xdate+xtype)
      --
      IF (CE_AUTO_BANK_MATCH.csl_exchange_rate_date IS NULL or
	  CE_AUTO_BANK_MATCH.csl_exchange_rate_type IS NULL) THEN

        IF (CE_AUTO_BANK_MATCH.csl_exchange_rate IS NOT NULL) or
	   (CE_AUTO_BANK_MATCH.csl_original_amount IS NOT NULL) THEN

	  CE_AUTO_BANK_MATCH.csl_exchange_rate_date :=
		CE_AUTO_BANK_MATCH.csl_trx_date;
	  CE_AUTO_BANK_MATCH.csl_exchange_rate_type := 'User';

	  cep_standard.debug('xtype: '||CE_AUTO_BANK_MATCH.csl_exchange_rate_type);
	  cep_standard.debug('xdate: '||CE_AUTO_BANK_MATCH.csl_exchange_rate_date);

	ELSE

	  IF (CE_AUTO_BANK_MATCH.csl_exchange_rate_type IS NULL) THEN
	    CE_RECONCILIATION_ERRORS_PKG.insert_row(
		CE_AUTO_BANK_MATCH.csh_statement_header_id,
		CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_NO_RATE_TYPE');
	  ELSIF (CE_AUTO_BANK_MATCH.csl_exchange_rate_date IS NULL) THEN
	    CE_RECONCILIATION_ERRORS_PKG.insert_row(
		CE_AUTO_BANK_MATCH.csh_statement_header_id,
		CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_NO_RATE_DATE');
	  END IF;
	  return(FALSE);

	END IF;

      END IF;

    END IF; -- foreign curr

  END IF; -- fixed_relation

  --
  -- Rate Validation for emu and non-emu
  --
  cep_standard.debug('CE_AUTO_BANK_MATCH.csl_exchange_rate_type ='||CE_AUTO_BANK_MATCH.csl_exchange_rate_type);

  IF (CE_AUTO_BANK_MATCH.csl_exchange_rate_type = 'User') THEN

    IF (CE_AUTO_BANK_MATCH.csl_exchange_rate IS NULL) THEN
      IF (CE_AUTO_BANK_MATCH.trx_currency_type = 'BANK') THEN
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	    CE_AUTO_BANK_MATCH.csh_statement_header_id,
	    CE_AUTO_BANK_MATCH.csl_statement_line_id,
		'CE_INCOMPLETE_USER_RATE');
	return(FALSE);
      ELSE
	CE_AUTO_BANK_MATCH.csl_exchange_rate :=
	    CE_AUTO_BANK_MATCH.csl_amount/trx_curr_amount;
      END IF;
    END IF;

  ELSE

    BEGIN
  cep_standard.debug('CE_AUTO_BANK_REC.G_set_of_books_id = '||CE_AUTO_BANK_REC.G_set_of_books_id ||
			', CE_AUTO_BANK_MATCH.trx_currency_code = '|| CE_AUTO_BANK_MATCH.trx_currency_code );
  cep_standard.debug('CE_AUTO_BANK_MATCH.csl_exchange_rate_date = '|| CE_AUTO_BANK_MATCH.csl_exchange_rate_date ||
			', CE_AUTO_BANK_MATCH.csl_exchange_rate_type = '|| CE_AUTO_BANK_MATCH.csl_exchange_rate_type);

      x_exchange_rate := gl_currency_api.get_rate(
      x_set_of_books_id	=> CE_AUTO_BANK_REC.G_set_of_books_id,
      x_from_currency	=> nvl(CE_AUTO_BANK_MATCH.trx_currency_code,CE_AUTO_BANK_MATCH.csl_currency_code),
      x_conversion_date	=> CE_AUTO_BANK_MATCH.csl_exchange_rate_date,
      x_conversion_type => CE_AUTO_BANK_MATCH.csl_exchange_rate_type);

      cep_standard.debug('x_ex: '||x_exchange_rate);
      cep_standard.debug('csl_ex: '||CE_AUTO_BANK_MATCH.csl_exchange_rate);

      IF (CE_AUTO_BANK_MATCH.csl_exchange_rate IS NULL) THEN
	CE_AUTO_BANK_MATCH.csl_exchange_rate := x_exchange_rate;
      END IF;

      IF (round(x_exchange_rate,9) =
	  round(CE_AUTO_BANK_MATCH.csl_exchange_rate,9)) THEN
	RETURN(TRUE);
      ELSE
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	    CE_AUTO_BANK_MATCH.csh_statement_header_id,
	    CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_OTHER_ERROR_RATE');
	RETURN(FALSE);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
	IF (SQL%NOTFOUND) THEN
	  cep_standard.debug('No Rate for the given criteria');
	--for bug 6786355 start
	CE_AUTO_BANK_MATCH.csl_exchange_rate_type := null;
	CE_AUTO_BANK_MATCH.csl_exchange_rate	    := null;
	CE_AUTO_BANK_MATCH.csl_exchange_rate_date   := null;
	CE_AUTO_BANK_MATCH.csl_original_amount      := null;
	--for bug 6786355 end
	  CE_RECONCILIATION_ERRORS_PKG.insert_row(
	      CE_AUTO_BANK_MATCH.csh_statement_header_id,
	      CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_OTHER_NO_RATE');
	  RETURN(FALSE);
	ELSE
	  cep_standard.debug('EXCEPTION:gl_currency_api.get_rate' );
	  RAISE;
	END IF;
    END;

  END IF; -- user type
  return(TRUE);
  cep_standard.debug('<<CE_AUTO_BANK_MATCH.validate_exchange_details');

EXCEPTION
  WHEN OTHERS THEN
  cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.validate_exchange_details');
    RAISE;
END validate_exchange_details;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION                                                     |
|       close_cursors							|
|                                                                       |
|  DESCRIPTION                                                          |
|	Closes the locking cursors  					|
|  CALLED BY                                                            |
|       lock_transaction						|
 --------------------------------------------------------------------- */
PROCEDURE close_cursors IS
BEGIN
  IF lock_101%ISOPEN THEN
    CLOSE lock_101;
  END IF;
  IF lock_200%ISOPEN THEN
    CLOSE lock_200;
  END IF;
  IF lock_222%ISOPEN THEN
    CLOSE lock_222;
  END IF;
  IF lock_185%ISOPEN THEN
    CLOSE lock_185;
  END IF;
  IF lock_260%ISOPEN THEN
    CLOSE lock_260;
  END IF;
  IF lock_260_cf%ISOPEN THEN
    CLOSE lock_260_cf;
  END IF;
  IF lock_801%ISOPEN THEN
    CLOSE lock_801;
  END IF;
  IF clear_lock_200%ISOPEN THEN
    CLOSE clear_lock_200;
  END IF;
  IF clear_lock_222%ISOPEN THEN
    CLOSE clear_lock_222;
  END IF;
  IF clear_lock_260%ISOPEN THEN
    CLOSE clear_lock_260;
  END IF;
  IF clear_lock_260_cf%ISOPEN THEN
    CLOSE clear_lock_260_cf;
  END IF;
  IF clear_lock_801%ISOPEN THEN
    CLOSE clear_lock_801;
  END IF;
  IF lock_batch_checks%ISOPEN THEN
    CLOSE lock_batch_checks;
  END IF;
  IF LOCK_GROUP_CHECKS%ISOPEN THEN
    CLOSE LOCK_GROUP_CHECKS;
  END IF;
  IF lock_batch_receipts%ISOPEN THEN
    CLOSE lock_batch_receipts;
  END IF;
  IF check_amounts%ISOPEN THEN
    CLOSE check_amounts;
  END IF;
  IF receipt_amounts%ISOPEN THEN
    CLOSE receipt_amounts;
  END IF;
END close_cursors;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION                                                     |
|       get_min_statement_line_id                                       |
|                                                                       |
|  DESCRIPTION                                                          |
|                                                                       |
|  CALLED BY                                                            |
|       match_process							|
|                                                                       |
|  RETURNS                                                              |
|       csl_statement_line_id   Minimum statement line indentifier      |
 --------------------------------------------------------------------- */
FUNCTION get_min_statement_line_id RETURN NUMBER IS
  min_statement_line		NUMBER;
  min_statement_line_num	NUMBER;
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.get_min_statement_line_id');
  SELECT min(line_number)
  INTO   min_statement_line_num
  FROM   ce_statement_lines
  WHERE  statement_header_id = CE_AUTO_BANK_MATCH.csh_statement_header_id;

  SELECT statement_line_id
  INTO   min_statement_line
  FROM   ce_statement_lines
  WHERE  line_number = min_statement_line_num
  AND	 statement_header_id = CE_AUTO_BANK_MATCH.csh_statement_header_id;
	 cep_standard.debug('<<CE_AUTO_BANK_MATCH.get_min_statement_line_id');

  RETURN (min_statement_line);
EXCEPTION
  WHEN OTHERS THEN
  cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.get_min_statement_line_id');
  RAISE;
END get_min_statement_line_id;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	lock_transaction						|
|									|
|  DESCRIPTION								|
|	A match has been found and need to lock these transactions in	|
|	the AP/AR 							|
|	X_CALL_MODE is 'U' for reconciliation locking			|
|		       'M' for unreconciliation locking			|
|	X_RECONCILE_FLAG is 'Y' for reconciliation 			|
|		            'N' for clearing				|
|  CALLED BY								|
|	trx_validation							|
 --------------------------------------------------------------------- */
PROCEDURE lock_transaction (X_RECONCILE_FLAG	VARCHAR2,
			    X_CALL_MODE		VARCHAR2,
			    X_TRX_TYPE		VARCHAR2,
			    X_CLEARING_TRX_TYPE	VARCHAR2,
			    X_TRX_ROWID		VARCHAR2,
			    X_BATCH_BA_AMOUNT	NUMBER,
			    X_MATCH_CORRECTION_TYPE VARCHAR2,
			    X_LOGICAL_GROUP_REFERENCE VARCHAR2 DEFAULT NULL) IS
  id1			NUMBER;
  id2			NUMBER;
  id3			NUMBER;
  current_record_flag	AR_CASH_RECEIPT_HISTORY_ALL.current_record_flag%TYPE;
  tx_status		CE_LOOKUPS.lookup_code%TYPE;
  batch_ba_amount	NUMBER;
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.lock_transaction');
  cep_standard.debug('X_RECONCILE_FLAG='||X_RECONCILE_FLAG ||
		', X_CALL_MODE='|| X_CALL_MODE	||',X_TRX_TYPE='|| X_TRX_TYPE||
		', X_CLEARING_TRX_TYPE='|| X_CLEARING_TRX_TYPE	);
  cep_standard.debug('X_TRX_ROWID='|| X_TRX_ROWID||
		', X_BATCH_BA_AMOUNT='||X_BATCH_BA_AMOUNT||
		', X_MATCH_CORRECTION_TYPE='||X_MATCH_CORRECTION_TYPE);

  IF (X_reconcile_flag = 'Y') THEN
    --
    -- This logics needs to be fixed for Prod16.
    -- Reason this is here is that MREC passes "wrong values"
    -- for locking
    --
    IF (X_trx_type = 'JE_LINE' OR X_clearing_trx_type = 'JE_LINE') THEN
      OPEN CE_AUTO_BANK_MATCH.lock_101(X_CALL_MODE, X_trx_rowid);
      FETCH CE_AUTO_BANK_MATCH.lock_101 INTO id1;
      IF (CE_AUTO_BANK_MATCH.lock_101%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
      END IF;
      CLOSE CE_AUTO_BANK_MATCH.lock_101;
    ELSIF (X_clearing_trx_type 	= 'ROI_LINE') THEN
      CE_999_PKG.lock_row(X_CALL_MODE, X_trx_type, X_trx_rowid);
    ELSIF (X_clearing_trx_type 	= 'XTR_LINE') THEN
      OPEN CE_AUTO_BANK_MATCH.lock_185(X_CALL_MODE, X_trx_rowid);
      FETCH CE_AUTO_BANK_MATCH.lock_185 INTO id1;
      IF (CE_AUTO_BANK_MATCH.lock_185%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
      END IF;
      CLOSE CE_AUTO_BANK_MATCH.lock_185;
    ELSIF (X_clearing_trx_type 	= 'CASHFLOW') THEN
      OPEN CE_AUTO_BANK_MATCH.lock_260_cf(X_CALL_MODE, X_trx_rowid);
      FETCH CE_AUTO_BANK_MATCH.lock_260_cf INTO id1;
      IF (CE_AUTO_BANK_MATCH.lock_260_cf%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
      END IF;
      CLOSE CE_AUTO_BANK_MATCH.lock_260_cf;
    ELSIF (X_trx_type in ('PAYMENT', 'REFUND')) THEN
      --IF (X_clearing_trx_type = 'PAY') THEN
      IF (X_clearing_trx_type in ('PAY', 'PAY_EFT')) THEN
	OPEN CE_AUTO_BANK_MATCH.lock_801(X_CALL_MODE, X_trx_rowid);
	FETCH CE_AUTO_BANK_MATCH.lock_801 INTO id1;
	IF (CE_AUTO_BANK_MATCH.lock_801%NOTFOUND) THEN
	  RAISE NO_DATA_FOUND;
	END IF;
	CLOSE CE_AUTO_BANK_MATCH.lock_801;
      ELSE
	OPEN CE_AUTO_BANK_MATCH.lock_200(X_CALL_MODE, X_trx_rowid);
	FETCH CE_AUTO_BANK_MATCH.lock_200 INTO id1;
	IF (CE_AUTO_BANK_MATCH.lock_200%NOTFOUND) THEN
	  RAISE NO_DATA_FOUND;
	END IF;
	CLOSE CE_AUTO_BANK_MATCH.lock_200;
      END IF;
    ELSIF (X_trx_type IN ('MISC','CASH'))THEN
  cep_standard.debug('open lock_222');
      OPEN CE_AUTO_BANK_MATCH.lock_222(X_CALL_MODE, x_trx_rowid);
      FETCH CE_AUTO_BANK_MATCH.lock_222 INTO id1, id2, current_record_flag;
  cep_standard.debug('id1 '||id1);
  cep_standard.debug('id2 '||id2);
  cep_standard.debug('current_record_flag '||current_record_flag);

      IF (CE_AUTO_BANK_MATCH.lock_222%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
      END IF;
      IF (X_call_mode = 'U' AND current_record_flag = 'N') THEN
	RAISE NO_DATA_FOUND;
      END IF;
      CLOSE CE_AUTO_BANK_MATCH.lock_222;
    ELSIF( X_CLEARING_TRX_TYPE   = 'STATEMENT') THEN
      IF (X_MATCH_CORRECTION_TYPE is not NULL) then
        CE_AUTO_BANK_MATCH.csl_match_correction_type := X_MATCH_CORRECTION_TYPE;
      end if;
      if (nvl(CE_AUTO_BANK_MATCH.csl_match_correction_type, 'NONE')
	  = 'REVERSAL') then
	OPEN CE_AUTO_BANK_MATCH.lock_260(X_CALL_MODE, x_trx_rowid);
	FETCH CE_AUTO_BANK_MATCH.lock_260 INTO id1;
	IF (CE_AUTO_BANK_MATCH.lock_260%NOTFOUND) THEN
	   RAISE NO_DATA_FOUND;
	END IF;
	CLOSE CE_AUTO_BANK_MATCH.lock_260;
      elsif (nvl(CE_AUTO_BANK_MATCH.csl_match_correction_type, 'NONE')
	  = 'ADJUSTMENT') then
	cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.trx_rowid2='||
	    CE_AUTO_BANK_MATCH.trx_rowid2);
	OPEN CE_AUTO_BANK_MATCH.lock_260(X_CALL_MODE,
	    CE_AUTO_BANK_MATCH.trx_rowid2);
	FETCH CE_AUTO_BANK_MATCH.lock_260 INTO id1;
	IF (CE_AUTO_BANK_MATCH.lock_260%NOTFOUND) THEN
	  RAISE NO_DATA_FOUND;
	END IF;
	CLOSE CE_AUTO_BANK_MATCH.lock_260;
	if (CE_AUTO_BANK_MATCH.reconciled_this_run is NULL) then
	  if ((CE_AUTO_BANK_MATCH.corr_csl_amount > 0 AND
	      csl_trx_type = 'MISC_CREDIT') OR
	    (CE_AUTO_BANK_MATCH.corr_csl_amount < 0 AND
	      csl_trx_type = 'MISC_DEBIT')) then
	    OPEN CE_AUTO_BANK_MATCH.lock_222(X_CALL_MODE, x_trx_rowid);
	    FETCH CE_AUTO_BANK_MATCH.lock_222 INTO id1, id2,current_record_flag;
	    IF (CE_AUTO_BANK_MATCH.lock_222%NOTFOUND) THEN
	      RAISE NO_DATA_FOUND;
	    END IF;
	    IF (X_call_mode = 'U' AND current_record_flag = 'N') THEN
	      RAISE NO_DATA_FOUND;
	    END IF;
	    CLOSE CE_AUTO_BANK_MATCH.lock_222;
	  elsif ((CE_AUTO_BANK_MATCH.corr_csl_amount < 0 AND
	      csl_trx_type = 'MISC_CREDIT') OR
	      (CE_AUTO_BANK_MATCH.corr_csl_amount > 0 AND
	      csl_trx_type = 'MISC_DEBIT')) then
	    OPEN CE_AUTO_BANK_MATCH.lock_200(X_CALL_MODE, X_trx_rowid);
	    FETCH CE_AUTO_BANK_MATCH.lock_200 INTO id1;
	    IF (CE_AUTO_BANK_MATCH.lock_200%NOTFOUND) THEN
	      RAISE NO_DATA_FOUND;
	    END IF;
	    CLOSE CE_AUTO_BANK_MATCH.lock_200;
	  end if;
	end if;	   -- CE_AUTO_BANK_MATCH.reconciled_this_run is NULL
      end if;
    ELSIF (X_trx_type = 'PBATCH') THEN
      cep_standard.debug('open lock_batch_checks X_trx_rowid='|| X_trx_rowid);
      OPEN CE_AUTO_BANK_MATCH.lock_batch_checks(X_trx_rowid);
      FETCH CE_AUTO_BANK_MATCH.lock_batch_checks INTO id1, id2;
      IF (CE_AUTO_BANK_MATCH.lock_batch_checks%NOTFOUND) THEN
        cep_standard.debug('no_data_found for  lock_batch_checks');

	RAISE NO_DATA_FOUND;
      END IF;
      cep_standard.debug('open check_amounts id2='||id2);
      OPEN CE_AUTO_BANK_MATCH.check_amounts(id2);
      FETCH CE_AUTO_BANK_MATCH.check_amounts INTO batch_ba_amount;
      IF (CE_AUTO_BANK_MATCH.check_amounts%NOTFOUND) THEN
	cep_standard.debug('EKA NO DATA');
	RAISE NO_DATA_FOUND;
      END IF;

       cep_standard.debug('batch_ba_amount='||batch_ba_amount||', X_batch_ba_amount='||X_batch_ba_amount );

      IF ((batch_ba_amount = X_batch_ba_amount) OR
	  ((batch_ba_amount IS NULL) AND (X_batch_ba_amount IS NULL))) THEN
	NULL;
      ELSE
	cep_standard.debug('TOKA NO DATA  batch_ba_amount <> X_batch_ba_amount ');
	RAISE NO_DATA_FOUND;
      END IF;
      CLOSE CE_AUTO_BANK_MATCH.Check_Amounts;
      CLOSE CE_AUTO_BANK_MATCH.Lock_Batch_Checks;
  ELSIF (X_trx_type = 'PGROUP') THEN -- SEPA ER 6700007
      cep_standard.debug('open lock_group_checks X_trx_rowid='|| X_trx_rowid||' X_LOGICAL_GROUP_REFERENCE-'||X_LOGICAL_GROUP_REFERENCE);
      OPEN CE_AUTO_BANK_MATCH.lock_group_checks(X_trx_rowid,X_LOGICAL_GROUP_REFERENCE);
      FETCH CE_AUTO_BANK_MATCH.lock_group_checks INTO id1, id2;
      IF (CE_AUTO_BANK_MATCH.lock_group_checks%NOTFOUND) THEN
        cep_standard.debug('no_data_found for  lock_group_checks');

	     RAISE NO_DATA_FOUND;
      END IF;
      cep_standard.debug('open check_amounts id2='||id2);
      OPEN CE_AUTO_BANK_MATCH.check_group_amounts(id2,X_LOGICAL_GROUP_REFERENCE);
      FETCH CE_AUTO_BANK_MATCH.check_group_amounts INTO batch_ba_amount;
      IF (CE_AUTO_BANK_MATCH.check_group_amounts%NOTFOUND) THEN
   	    cep_standard.debug('EKA NO DATA');
	RAISE NO_DATA_FOUND;
      END IF;

       cep_standard.debug('batch_ba_amount='||batch_ba_amount||', X_batch_ba_amount='||X_batch_ba_amount );

      IF ((batch_ba_amount = X_batch_ba_amount) OR
	  ((batch_ba_amount IS NULL) AND (X_batch_ba_amount IS NULL))) THEN
	NULL;
      ELSE
	cep_standard.debug('TOKA NO DATA  batch_ba_amount <> X_batch_ba_amount ');
	RAISE NO_DATA_FOUND;
      END IF;
      CLOSE CE_AUTO_BANK_MATCH.Check_GROUP_Amounts;
      CLOSE CE_AUTO_BANK_MATCH.Lock_group_Checks;
    ELSIF (X_trx_type = 'RBATCH') THEN
cep_standard.debug('open lock_batch_receipts X_trx_rowid='|| X_trx_rowid);
      OPEN CE_AUTO_BANK_MATCH.lock_batch_receipts(X_trx_rowid);
      FETCH CE_AUTO_BANK_MATCH.lock_batch_receipts INTO id1, id2, id3;
      IF (CE_AUTO_BANK_MATCH.lock_batch_receipts%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
      END IF;

cep_standard.debug('open receipt_amounts id3='||id3);

      OPEN CE_AUTO_BANK_MATCH.receipt_amounts(id3);
      FETCH CE_AUTO_BANK_MATCH.receipt_amounts INTO batch_ba_amount;
      IF (CE_AUTO_BANK_MATCH.receipt_amounts%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
      END IF;

cep_standard.debug('batch_ba_amount='||batch_ba_amount||', X_batch_ba_amount='||X_batch_ba_amount );

      IF ((batch_ba_amount = X_batch_ba_amount) OR
	  ((batch_ba_amount IS NULL) AND (X_batch_ba_amount IS NULL))) THEN
	NULL;
      ELSE
	cep_standard.debug(' remittance batch no_data_found batch_ba_amount <> X_batch_ba_amount ');
	RAISE NO_DATA_FOUND;
      END IF;
      CLOSE CE_AUTO_BANK_MATCH.Receipt_Amounts;
      CLOSE CE_AUTO_BANK_MATCH.Lock_Batch_Receipts;
    END IF;
  ELSE -- Clearing only, just lock the transaction table and check the status
    IF (X_clearing_trx_type = 'ROI_LINE') THEN
	CE_999_PKG.lock_row(X_CALL_MODE, X_trx_type, X_trx_rowid);
    ELSIF (X_CLEARING_TRX_TYPE   = 'CASHFLOW') THEN
      OPEN CE_AUTO_BANK_MATCH.clear_lock_260_cf(X_CALL_MODE, x_trx_rowid);
      FETCH CE_AUTO_BANK_MATCH.clear_lock_260_cf INTO id1;
      IF (CE_AUTO_BANK_MATCH.clear_lock_260_cf%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
      END IF;
      CLOSE CE_AUTO_BANK_MATCH.clear_lock_260_cf;
    ELSIF (X_trx_type in ('PAYMENT', 'REFUND')) THEN
      OPEN CE_AUTO_BANK_MATCH.clear_lock_200(X_CALL_MODE, X_trx_rowid);
      FETCH CE_AUTO_BANK_MATCH.clear_lock_200 INTO id1,tx_status;
      IF (CE_AUTO_BANK_MATCH.clear_lock_200%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
      END IF;
      IF (X_call_mode = 'U' and tx_status <> 'NEGOTIABLE') THEN
	RAISE NO_DATA_FOUND;
      END IF;
      IF (X_call_mode = 'M' and
	  tx_status NOT IN  ('CLEARED','CLEARED BUT UNACCOUNTED')) THEN
	RAISE NO_DATA_FOUND;
      END IF;
      CLOSE CE_AUTO_BANK_MATCH.clear_lock_200;
    ELSIF (X_trx_type	IN ('MISC','CASH')) THEN
      OPEN CE_AUTO_BANK_MATCH.clear_lock_222(X_CALL_MODE, x_trx_rowid);
      FETCH CE_AUTO_BANK_MATCH.clear_lock_222 INTO id1,id2,current_record_flag;
      IF (CE_AUTO_BANK_MATCH.clear_lock_222%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
      END IF;
      IF (current_record_flag = 'N') THEN
	RAISE NO_DATA_FOUND;
      END IF;
      CLOSE CE_AUTO_BANK_MATCH.clear_lock_222;
    ELSIF (X_CLEARING_TRX_TYPE   = 'STATEMENT') THEN
      OPEN CE_AUTO_BANK_MATCH.clear_lock_260(X_CALL_MODE, x_trx_rowid);
      FETCH CE_AUTO_BANK_MATCH.clear_lock_260 INTO id1;
      IF (CE_AUTO_BANK_MATCH.clear_lock_260%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
      END IF;
      CLOSE CE_AUTO_BANK_MATCH.clear_lock_260;
    END IF;
  END IF;
  cep_standard.debug('<<CE_AUTO_BANK_MATCH.lock_transaction');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    cep_standard.debug('Transaction Either Deleted OR Reconciled');
    CE_AUTO_BANK_MATCH.close_cursors;
    RAISE NO_DATA_FOUND;
  WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
    cep_standard.debug('Could not lock transactions');
    CE_AUTO_BANK_MATCH.close_cursors;
    RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
END lock_transaction;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	ce_match 	    						|
|									|
|  DESCRIPTION								|
|	Cash Managment transaction will be matched in the following
|         sequence

|  Seq Matching Criteria Tolerance CE_CASHFLOWS column
|  --- ----------------- --------- -------------------
|  1   Statement Line ID  Yes	    STATEMENT_LINE_ID

        For ZBA transfers created through the sweep transactions
         generation program and cashflows created through the
         Journal Entry Creation program

|  2   Transaction Number Yes	    BANK_TRXN_NUMBER,
        , date and Amount             CASHFLOW_DATE, CASHFLOW_AMOUNT

        The amount is in the bank account currency. Tolerances are
         always calculated based on the functional currency. For dates
         always match first by the statement line value date, if null
         use the statement line transaction date followed by statement
         header date.

|  3   Agent Bank Account Yes	COUNTERPARTY_BANK_ACCOUNT_ID,
	, Date and Amount         CASHFLOW_DATE, CASHFLOW_AMOUNT

|									|
|  CALLED BY								|
|	trx_match/match_line					        |
 --------------------------------------------------------------------- */
PROCEDURE ce_match(no_of_matches		OUT NOCOPY  NUMBER
		) IS

  cursor stmt_ln_id_cur(tx_type varchar2) IS
          SELECT    catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.base_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		catv.trx_type,
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.clearing_trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		catv.reference_type,
		catv.value_date,
		catv.cleared_date,
		catv.deposit_date,
		catv.legal_entity_id,
		catv.seq_id
        --FROM      ce_260_cf_transactions_v catv
        FROM      ce_available_transactions_tmp catv
        WHERE     catv.trx_type = tx_type
        AND       catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
        AND	catv.legal_entity_id = nvl(CE_AUTO_BANK_REC.G_legal_entity_id , catv.legal_entity_id)
        --AND	catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
        AND       catv.check_number = CE_AUTO_BANK_MATCH.csl_statement_line_id
  	AND	catv.application_id = 261
	AND	NVL(catv.reconciled_status_flag, 'N') = 'N';

    cursor trx_num_date_amt_cur(tx_type varchar2) IS
        SELECT    catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.base_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		catv.trx_type,
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.clearing_trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		catv.reference_type,
		catv.value_date,
		catv.cleared_date,
		catv.deposit_date,
		catv.legal_entity_id,
		catv.seq_id
        --FROM      ce_260_cf_transactions_v catv
        FROM      ce_available_transactions_tmp catv
        WHERE     catv.trx_type = tx_type
        AND       catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
        AND	catv.legal_entity_id = nvl(CE_AUTO_BANK_REC.G_legal_entity_id, catv.legal_entity_id)
        --AND	catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
        AND     catv.trx_number = CE_AUTO_BANK_MATCH.csl_bank_trx_number
	and 	catv.check_number is null
	AND     to_char(catv.trx_date,'YYYY/MM/DD') =
                to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
	AND	catv.application_id = 261
	AND	NVL(catv.reconciled_status_flag, 'N') = 'N';

  cursor agent_ba_date_amt_cur(tx_type varchar2) IS
        SELECT    catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.base_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		catv.trx_type,
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.clearing_trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		catv.reference_type,
		catv.value_date,
		catv.cleared_date,
		catv.deposit_date,
		catv.legal_entity_id,
		catv.seq_id
        --FROM      ce_260_cf_transactions_v catv
        FROM      ce_available_transactions_tmp catv
        WHERE     catv.trx_type = tx_type
        AND       catv.bank_account_id   = CE_AUTO_BANK_MATCH.csh_bank_account_id
        --AND	catv.legal_entity_id     = CE_AUTO_BANK_REC.G_legal_entity_id
        --AND	catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
        --AND     catv.customer_id       = CE_AUTO_BANK_MATCH.csl_bank_trx_number
    	AND    catv.bank_account_text    = CE_AUTO_BANK_MATCH.csl_bank_account_text
	and 	catv.check_number is null
	AND     to_char(catv.trx_date,'YYYY/MM/DD') =
                to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
	AND	catv.application_id = 261
	AND	NVL(catv.reconciled_status_flag, 'N') = 'N';

/*  cursor le_sys_par IS
      SELECT
	   NVL(s.amount_tolerance_old,0),
	   NVL(s.percent_tolerance_old,0),
	   NVL(s.fx_difference_handling_old,'C'),
	   s.CE_DIFFERENCES_ACCOUNT_old,
	   s.CASHFLOW_EXCHANGE_RATE_TYPE,
	   s.AUTHORIZATION_BAT,
	   s.BSC_EXCHANGE_DATE_TYPE,
 	   s.BAT_EXCHANGE_DATE_TYPE,
	   1
      FROM CE_SYSTEM_PARAMETERS s
      WHERE s.legal_entity_id =  CE_AUTO_BANK_MATCH.trx_legal_entity_id;
*/
  curr		                NUMBER;
  tx_type 			VARCHAR2(30);
  le_found	                NUMBER;
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.ce_match');

  no_of_matches := 0;
  le_found	:= 0;

  cep_standard.debug('CE_AUTO_BANK_MATCH.csl_trx_type = '|| CE_AUTO_BANK_MATCH.csl_trx_type
			||' CE_AUTO_BANK_MATCH.csl_bank_trx_number = '|| CE_AUTO_BANK_MATCH.csl_bank_trx_number);
  cep_standard.debug('CE_AUTO_BANK_MATCH.csh_bank_account_id = '|| CE_AUTO_BANK_MATCH.csh_bank_account_id
			||', CE_AUTO_BANK_MATCH.csl_trx_date = '|| CE_AUTO_BANK_MATCH.csl_trx_date
			||', CE_AUTO_BANK_MATCH.csl_payroll_payment_format = '|| CE_AUTO_BANK_MATCH.csl_payroll_payment_format);

  IF (CE_AUTO_BANK_MATCH.csl_trx_type IN ('DEBIT','STOP','SWEEP_OUT') AND
     ( CE_AUTO_BANK_MATCH.csl_reconcile_flag NOT IN ('PAY', 'PAY_EFT'))) THEN
    tx_type := 'PAYMENT';
  ELSIF (CE_AUTO_BANK_MATCH.csl_trx_type IN ('CREDIT','NSF','REJECTED','SWEEP_IN')) THEN
    --tx_type := 'CASH';
    tx_type := 'RECEIPT';
  ELSIF (CE_AUTO_BANK_MATCH.csl_trx_type IN ('MISC_CREDIT','MISC_DEBIT')) THEN
    tx_type := 'MISC';
  END IF;


   cep_standard.debug('>>MATCH ce trx by statement_line_id');
	curr:=1;
	OPEN stmt_ln_id_cur(tx_type);
   	FETCH stmt_ln_id_cur
        INTO      CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
		CE_AUTO_BANK_MATCH.trx_reference_type,
		CE_AUTO_BANK_MATCH.trx_value_date,
		CE_AUTO_BANK_MATCH.trx_cleared_date,
		CE_AUTO_BANK_MATCH.trx_deposit_date,
		CE_AUTO_BANK_MATCH.trx_legal_entity_id,
		CE_AUTO_BANK_MATCH.gt_seq_id;
	CLOSE stmt_ln_id_cur;


   IF (no_of_matches = 0) THEN
     cep_standard.debug('>>MATCH ce trx by transaction number, date and amount');
	curr:=2;
 	OPEN trx_num_date_amt_cur(tx_type);
   	FETCH trx_num_date_amt_cur
        INTO      CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
		CE_AUTO_BANK_MATCH.trx_reference_type,
		CE_AUTO_BANK_MATCH.trx_value_date,
		CE_AUTO_BANK_MATCH.trx_cleared_date,
		CE_AUTO_BANK_MATCH.trx_deposit_date,
		CE_AUTO_BANK_MATCH.trx_legal_entity_id,
		CE_AUTO_BANK_MATCH.gt_seq_id;
	CLOSE  trx_num_date_amt_cur;

   END IF;


   IF (no_of_matches = 0) THEN
     cep_standard.debug('>>MATCH ce trx by agent bank account, date and amount');
	curr:=3;
 	OPEN agent_ba_date_amt_cur(tx_type);
   	FETCH agent_ba_date_amt_cur
        INTO      CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
		CE_AUTO_BANK_MATCH.trx_reference_type,
		CE_AUTO_BANK_MATCH.trx_value_date,
		CE_AUTO_BANK_MATCH.trx_cleared_date,
		CE_AUTO_BANK_MATCH.trx_deposit_date,
		CE_AUTO_BANK_MATCH.trx_legal_entity_id,
		CE_AUTO_BANK_MATCH.gt_seq_id;

	CLOSE agent_ba_date_amt_cur;

   END IF;

  cep_standard.debug('CE_AUTO_BANK_MATCH.trx_id = '|| CE_AUTO_BANK_MATCH.trx_id
			||', CE_AUTO_BANK_MATCH.trx_amount = '|| CE_AUTO_BANK_MATCH.trx_amount
			);
  cep_standard.debug('CE_AUTO_BANK_MATCH.csl_match_type = '|| CE_AUTO_BANK_MATCH.csl_match_type
			||', no_of_matches = '|| no_of_matches
			||', CE_AUTO_BANK_MATCH.csl_trx_date = '|| CE_AUTO_BANK_MATCH.csl_trx_date
			);


  IF (no_of_matches = 0) THEN
    RAISE NO_DATA_FOUND;
  END IF;
/*
  IF (no_of_matches = 1 and CE_AUTO_BANK_MATCH.trx_legal_entity_id is not null)  THEN
	curr:=4;
 	OPEN le_sys_par;
   	FETCH le_sys_par
        INTO
	  CE_AUTO_BANK_MATCH.G_le_amount_tolerance,
	  CE_AUTO_BANK_MATCH.G_le_percent_tolerance,
	  CE_AUTO_BANK_MATCH.G_le_Fx_Difference_Handling,
	  CE_AUTO_BANK_REC.G_CE_DIFFERENCES_ACCOUNT,
	  CE_AUTO_BANK_REC.G_CASHFLOW_EXCHANGE_RATE_TYPE,
	  CE_AUTO_BANK_REC.G_AUTHORIZATION_BAT,
          CE_AUTO_BANK_REC.G_BSC_EXCHANGE_DATE_TYPE,
          CE_AUTO_BANK_REC.G_BAT_EXCHANGE_DATE_TYPE,
	  le_found;

	CLOSE le_sys_par;

  END IF;

  IF (le_found = 0) THEN
   --no system parameter set at LE level default value
	  CE_AUTO_BANK_MATCH.G_le_amount_tolerance  := 0;
	  CE_AUTO_BANK_MATCH.G_le_percent_tolerance := 0;
	  CE_AUTO_BANK_MATCH.G_le_Fx_Difference_Handling := 'F';
	  CE_AUTO_BANK_REC.G_CE_DIFFERENCES_ACCOUNT := 'CHARGES';
	  --CE_AUTO_BANK_REC.G_CASHFLOW_EXCHANGE_RATE_TYPE
	  CE_AUTO_BANK_REC.G_AUTHORIZATION_BAT  :='NR';
          CE_AUTO_BANK_REC.G_BSC_EXCHANGE_DATE_TYPE :='BSD';
          CE_AUTO_BANK_REC.G_BAT_EXCHANGE_DATE_TYPE :='TRX';

  END IF;
*/
  IF (CE_AUTO_BANK_MATCH.aba_bank_currency <>
	  CE_AUTO_BANK_REC.G_functional_currency) and
     (CE_AUTO_BANK_MATCH.aba_bank_currency <>
	  CE_AUTO_BANK_MATCH.trx_currency_code) THEN
    cep_standard.debug('Forex account not using the same curr as bk');
    curr := 6;
    RAISE NO_DATA_FOUND;
  END IF;

  cep_standard.debug('<<CE_AUTO_BANK_MATCH.ce_match');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    cep_standard.debug('EXCEPTION - NO_DATA_FOUND: No data found in CE_AUTO_BANK_MATCH.ce_match');
    if (curr = 6) then
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	  CE_AUTO_BANK_MATCH.csh_statement_header_id,
	  CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_NO_FOREIGN_RECON');
    else
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	  CE_AUTO_BANK_MATCH.csh_statement_header_id,
	  CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_NO_CE_TRX_MATCH');
    end if;
    no_of_matches := 0;
  WHEN OTHERS THEN
    IF (SQL%NOTFOUND) THEN
      cep_standard.debug('EXCEPTION - OTHERS: NO data found in CE_AUTO_BANK_MATCH.ce_match');
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	    CE_AUTO_BANK_MATCH.csh_statement_header_id,
	    CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_NO_TRX_MATCH');
      no_of_matches:=0;
    ELSIF (SQL%ROWCOUNT >0) THEN
      cep_standard.debug('EXCEPTION: More than one CE trx match this statement line' );

	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	    CE_AUTO_BANK_MATCH.csh_statement_header_id,
	    CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_DUP_CE_TRX_MATCH');
      no_of_matches:=999;
    ELSE
      cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.ce_match' );
      RAISE;
    END IF;
END ce_match;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	pay_eft_match     						|
|									|
|  DESCRIPTION								|
|	Using the statement line transaction number, transaction date   |
|       and Amount try to find a 					|
| 	matching batch for eft payments from CE_801_EFT_TRANSACTIONS_V  |
|									|
|  CALLED BY								|
|	match_line						        |
 --------------------------------------------------------------------- */
PROCEDURE pay_eft_match(no_of_matches		OUT NOCOPY  NUMBER,
		      no_of_currencies		IN OUT NOCOPY  NUMBER) IS
  trx_count			NUMBER;
  curr		                NUMBER;

BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.pay_eft_match');
  no_of_matches := 0;
  cep_standard.debug('CE_AUTO_BANK_MATCH.csl_trx_type = '|| CE_AUTO_BANK_MATCH.csl_trx_type
			||' CE_AUTO_BANK_MATCH.csl_bank_trx_number = '|| CE_AUTO_BANK_MATCH.csl_bank_trx_number);
  cep_standard.debug('CE_AUTO_BANK_MATCH.csh_bank_account_id = '|| CE_AUTO_BANK_MATCH.csh_bank_account_id
			||', CE_AUTO_BANK_MATCH.csl_trx_date = '|| CE_AUTO_BANK_MATCH.csl_trx_date
			||', CE_AUTO_BANK_MATCH.csl_payroll_payment_format = '|| CE_AUTO_BANK_MATCH.csl_payroll_payment_format);

  IF (CE_AUTO_BANK_MATCH.csl_trx_type IN ('DEBIT')) THEN
    IF (substr(CE_AUTO_BANK_MATCH.csl_payroll_payment_format,1,4) = 'BACS') THEN
       curr := 1;
    ELSE
       curr := 2;
    END IF;

   cep_standard.debug('>>MATCH trx ');

      SELECT 	count(*),
		sum(catv.bank_account_amount),
		nvl(sum(catv.base_amount),0),
		nvl(sum(catv.amount_cleared),0),
		SUM(DECODE(catv.currency_code,
		    CE_AUTO_BANK_MATCH.trx_currency_code,0,1)),
		sum(catv.amount),
		'PAY_EFT',
		1,
		catv.batch_id,
		catv.org_id,
		catv.CE_BANK_ACCT_USE_ID
      INTO    	CE_AUTO_BANK_MATCH.trx_count,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		no_of_currencies,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_group,
 		CE_AUTO_BANK_MATCH.trx_org_id,
 		CE_AUTO_BANK_MATCH.trx_bank_acct_use_id
      --FROM 	ce_801_EFT_transactions_v catv
      FROM      ce_available_transactions_tmp catv
      WHERE       upper(catv.batch_name) =
		    upper(CE_AUTO_BANK_MATCH.csl_bank_trx_number)
      AND	catv.trx_date = CE_AUTO_BANK_MATCH.csl_trx_date
      AND	catv.org_id = nvl(CE_AUTO_BANK_REC.G_org_id, catv.org_id)
      --AND	catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
      AND	catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
      AND		nvl(catv.status, 'C') <> 'V'
      AND       catv.application_id = 802
      AND       NVL(catv.reconciled_status_flag, 'N') = 'N'
	    having sum(catv.bank_account_amount) = CE_AUTO_BANK_MATCH.csl_amount
	group by catv.batch_id, catv.batch_name, catv.trx_date, catv.org_id, catv.ce_bank_acct_use_id; -- bug  7242853

  END IF;

  cep_standard.debug('CE_AUTO_BANK_MATCH.trx_count = '|| CE_AUTO_BANK_MATCH.trx_count
			||', CE_AUTO_BANK_MATCH.trx_amount = '|| CE_AUTO_BANK_MATCH.trx_amount
			||', no_of_currencies = '|| no_of_currencies);
  cep_standard.debug('CE_AUTO_BANK_MATCH.csl_match_type = '|| CE_AUTO_BANK_MATCH.csl_match_type
			||', no_of_matches = '|| no_of_matches
			||', CE_AUTO_BANK_MATCH.csl_trx_date = '|| CE_AUTO_BANK_MATCH.csl_trx_date
			||', CE_AUTO_BANK_MATCH.trx_group = '|| CE_AUTO_BANK_MATCH.trx_group);


  curr := 5;
  IF (CE_AUTO_BANK_MATCH.trx_count = 0) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  IF (CE_AUTO_BANK_MATCH.aba_bank_currency <>
	  CE_AUTO_BANK_REC.G_functional_currency) and
     (CE_AUTO_BANK_MATCH.aba_bank_currency <>
	  CE_AUTO_BANK_MATCH.trx_currency_code) THEN
    cep_standard.debug('Forex account not using the same curr as bk');
    curr := 6;
    RAISE NO_DATA_FOUND;
  END IF;

  cep_standard.debug('<<CE_AUTO_BANK_MATCH.pay_eft_match');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    cep_standard.debug('EXCEPTION - NO_DATA_FOUND: No data found in CE_AUTO_BANK_MATCH.pay_eft_match');
    if (curr = 6) then
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	  CE_AUTO_BANK_MATCH.csh_statement_header_id,
	  CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_NO_FOREIGN_RECON');
    elsif (curr = 1) then
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	  CE_AUTO_BANK_MATCH.csh_statement_header_id,
	  CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_NO_BATCH_BACS');
    elsif (curr = 2) then
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	  CE_AUTO_BANK_MATCH.csh_statement_header_id,
	  CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_NO_BATCH_NACHA');
    end if;
    no_of_matches := 0;
  WHEN OTHERS THEN
    IF (SQL%NOTFOUND) THEN
      cep_standard.debug('EXCEPTION - OTHERS: NO data found in CE_AUTO_BANK_MATCH.pay_eft_match');
      if (curr = 1) then
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	    CE_AUTO_BANK_MATCH.csh_statement_header_id,
	    CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_NO_BATCH_BACS');
      elsif (curr = 2) then
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	    CE_AUTO_BANK_MATCH.csh_statement_header_id,
	    CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_NO_BATCH_NACHA');
      end if;
      no_of_matches:=0;
    ELSIF (SQL%ROWCOUNT >0) THEN
      cep_standard.debug('EXCEPTION: More than one EFT batch match this payment' );
     -- if (CE_AUTO_BANK_MATCH.csl_trx_type IN ('DEBIT','STOP')) then
      if (curr = 1) then
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	    CE_AUTO_BANK_MATCH.csh_statement_header_id,
	    CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_DUP_BATCH_BACS');
      elsif (curr = 2) then
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	    CE_AUTO_BANK_MATCH.csh_statement_header_id,
	    CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_DUP_BATCH_NACHA');
      end if;
      no_of_matches:=999;
    ELSE
      cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.pay_eft_match' );
      RAISE;
    END IF;
END pay_eft_match;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	bank_account_match						|
|									|
|  DESCRIPTION								|
| 	Using the bank account number and invoice_number, try to find   |
|	a matching receipt NEW/Release 11. Capability to match by       |
|	bank account number and invoice number also for AP.		|
|									|
|  CALLED BY								|
|	match_line							|
 --------------------------------------------------------------------- */
PROCEDURE bank_account_match(no_of_matches		OUT NOCOPY	NUMBER) IS
  curr		NUMBER;
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.bank_account_match');
  no_of_matches := 1;
  IF (CE_AUTO_BANK_MATCH.csl_trx_type IN ('DEBIT','STOP')) THEN
    SELECT	DISTINCT(c.check_id),
		to_number(NULL),
		c.rowid,
		DECODE(c.currency_code,
			sob.currency_code,c.amount,
			ba.currency_code,c.amount,
			NVL(c.base_amount,c.amount)),
		DECODE(DECODE(c.status_lookup_code,
				'CLEARED BUT UNACCOUNTED','CLEARED',
				c.status_lookup_code),
		     'CLEARED',c.cleared_base_amount,
		     c.cleared_amount),
		c.status_lookup_code,
		DECODE(c.currency_code,
			sob.currency_code, DECODE(DECODE(c.status_lookup_code,
					'CLEARED BUT UNACCOUNTED','CLEARED',
					c.status_lookup_code),
				'CLEARED',c.cleared_amount),
			ba.currency_code, DECODE(DECODE(c.status_lookup_code,
					'CLEARED BUT UNACCOUNTED','CLEARED',
					c.status_lookup_code),
				'CLEARED',c.cleared_amount),
			DECODE(DECODE(c.status_lookup_code,
					'CLEARED BUT UNACCOUNTED','CLEARED',
					c.status_lookup_code),
				'CLEARED',NVL(c.cleared_base_amount, c.cleared_amount))),
		'PAYMENT',
		c.currency_code,
		DECODE(c.currency_code,
			sob.currency_code, 'FUNCTIONAL',
			ba.currency_code, 'BANK',
			'FOREIGN'),
		c.amount,
		'PAYMENT',
		DECODE(DECODE(c.status_lookup_code,
				'CLEARED BUT UNACCOUNTED','CLEARED',
				c.status_lookup_code),
			'CLEARED',c.cleared_exchange_rate,
			c.exchange_rate),
		DECODE(DECODE(c.status_lookup_code,
				'CLEARED BUT UNACCOUNTED','CLEARED',
				c.status_lookup_code),
			'CLEARED',c.cleared_exchange_date,
			c.exchange_date),
		DECODE(DECODE(c.status_lookup_code,
				'CLEARED BUT UNACCOUNTED','CLEARED',
				c.status_lookup_code),
			'CLEARED',c.cleared_exchange_rate_type,
			c.exchange_rate_type),
		aph.accounting_date,
      		c.cleared_date,
		c.org_id,
		c.CE_BANK_ACCT_USE_ID
    INTO   CE_AUTO_BANK_MATCH.trx_id,
	   CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
	   CE_AUTO_BANK_MATCH.trx_rowid,
	   CE_AUTO_BANK_MATCH.trx_amount,
	   CE_AUTO_BANK_MATCH.trx_base_amount,
	   CE_AUTO_BANK_MATCH.trx_status,
	   CE_AUTO_BANK_MATCH.trx_cleared_amount,
	   CE_AUTO_BANK_MATCH.csl_match_type,
	   CE_AUTO_BANK_MATCH.trx_currency_code,
	   CE_AUTO_BANK_MATCH.trx_currency_type,
	   CE_AUTO_BANK_MATCH.trx_curr_amount,
	   CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
	   CE_AUTO_BANK_MATCH.trx_exchange_rate,
	   CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
	   CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
	   CE_AUTO_BANK_MATCH.trx_gl_date,
	   CE_AUTO_BANK_MATCH.trx_cleared_date,
	   CE_AUTO_BANK_MATCH.trx_org_id,
	   CE_AUTO_BANK_MATCH.trx_bank_acct_use_id
   FROM    gl_sets_of_books 		sob,
	   ce_system_parameters 	sp,
	   ce_statement_reconcils_all   rec,
	   ce_bank_acct_uses_ou_v 	aba,
	   ce_bank_accounts	 	ba,
	   -- ce_bank_acct_uses_ou_v 	aba2,  --   Bug 9062935 removed use of view
	   iby_ext_bank_accounts ext, -- Bug 9062935
	   --ce_bank_accounts	 	ba2,   --  Bug 9361270  Commented Line
	   ap_payment_history_all	aph,
	   ap_checks_all			c,
	   ap_invoice_payments_all		pay,
	   ap_invoices_all			inv,
	   po_vendors			ven
    WHERE  sob.set_of_books_id 		= sp.set_of_books_id
    AND    NVL(rec.status_flag, 'U') 	= 'U'
    AND    NVL(rec.current_record_flag,'Y') = 'Y'
    AND	   rec.reference_type(+) 	= 'PAYMENT'
    AND	   rec.reference_id(+) 		= c.check_id
    --AND  aba.bank_account_id		= c.bank_account_id
    AND	   aba.bank_acct_use_id		= c.CE_BANK_ACCT_USE_ID
    AND    aba.bank_account_id	 	= ba.bank_account_id
    AND    aba.bank_account_id 		= CE_AUTO_BANK_MATCH.csh_bank_account_id --bug5182963
    AND   BA.ACCOUNT_OWNER_ORG_ID = SP.LEGAL_ENTITY_ID
    AND	   aba.org_id			= c.org_id
    AND	   aba.org_id			= nvl(CE_AUTO_BANK_REC.G_org_id, c.org_id)
    --AND  aba.bank_acct_use_id		= CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
    AND    aba.AP_USE_ENABLE_FLAG = 'Y'
    AND	   c.status_lookup_code		IN
		('NEGOTIABLE', 'STOP INITIATED',
		   DECODE(CE_AUTO_BANK_MATCH.csl_trx_type,
			'STOP', 'VOIDED',
			'NEGOTIABLE'),
		   DECODE(sp.show_cleared_flag,
			'N','NEGOTIABLE',
			'CLEARED'),
		   DECODE(sp.show_cleared_flag,
			'N','NEGOTIABLE',
			'CLEARED BUT UNACCOUNTED'))
    AND	   c.check_date		 >= sp.cashbook_begin_date
    --and    c.org_id	= sp.org_id
    and    c.org_id	= rec.org_id  (+) -- Bug 9062935 added outer join
    AND    c.check_id		 = pay.check_id
    AND    c.org_id		 = pay.org_id
    AND	   pay.invoice_id	 = inv.invoice_id
    AND	   pay.org_id	 	= inv.org_id
    AND    ven.vendor_id	 = inv.vendor_id
    AND	   inv.invoice_num	 = CE_AUTO_BANK_MATCH.csl_invoice_text
    -- AND    aba2.bank_account_id	 = ba2.bank_account_id  --   Bug 9062935 removed Condition
    -- AND    aba2.AP_USE_ENABLE_FLAG = 'Y'  --   Bug 9062935 removed Condition
    -- AND    aba2.bank_acct_use_id = c.external_bank_account_id --c.external_bank_acct_use_id  --   Bug 9062935 removed Condition
	AND    ext.ext_bank_account_id =  c.external_bank_account_id --    Bug 9062935 Added Condition
    -- AND    ba2.bank_account_num = CE_AUTO_BANK_MATCH.csl_bank_account_text -- Bug 9361270 Commented Line
    AND    ext.bank_account_num = CE_AUTO_BANK_MATCH.csl_bank_account_text -- Bug 9361270
    AND    aph.check_id (+) = c.check_id
    AND    aph.org_id (+) = c.org_id
    AND    aph.transaction_type (+) = 'PAYMENT CLEARING'
    AND not exists
       (select null
	from ap_payment_history_all aph2
     	where aph2.check_id = c.check_id
     	and  aph2.org_id = c.org_id
     	and aph2.transaction_type = 'PAYMENT CLEARING'
       	and aph2.payment_history_id > aph.payment_history_id);
  ELSE
    SELECT distinct(crh.cash_receipt_history_id),
	   crh.cash_receipt_id,
	   crh.rowid,
	   DECODE(cr.currency_code,
		CE_AUTO_BANK_REC.G_functional_currency, crh.amount,
		CE_AUTO_BANK_MATCH.aba_bank_currency, crh.amount,
		NVL(crh.acctd_amount,crh.amount)),
	   crh.acctd_amount,
	   crh.status,
	   DECODE(crh.status,
		'CLEARED', crh.amount,
		'RISK_ELIMINATED', crh.amount,
		0),
	   cr.type,
	   cr.currency_code,
	   DECODE(cr.currency_code,
		sob.currency_code, 'FUNCTIONAL',
		ba.currency_code, 'BANK',
		'FOREIGN'),
	   crh.amount,
	   cr.type,
	   crh.exchange_rate,
	   crh.exchange_date,
	   crh.exchange_rate_type,
	   crh.org_id,
	   cr.remit_bank_acct_use_id
    INTO   CE_AUTO_BANK_MATCH.trx_id,
	   CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
	   CE_AUTO_BANK_MATCH.trx_rowid,
	   CE_AUTO_BANK_MATCH.trx_amount,
	   CE_AUTO_BANK_MATCH.trx_base_amount,
	   CE_AUTO_BANK_MATCH.trx_status,
	   CE_AUTO_BANK_MATCH.trx_cleared_amount,
	   CE_AUTO_BANK_MATCH.csl_match_type,
	   CE_AUTO_BANK_MATCH.trx_currency_code,
	   CE_AUTO_BANK_MATCH.trx_currency_type,
	   CE_AUTO_BANK_MATCH.trx_curr_amount,
	   CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
	   CE_AUTO_BANK_MATCH.trx_exchange_rate,
	   CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
	   CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
	   CE_AUTO_BANK_MATCH.trx_org_id,
	   CE_AUTO_BANK_MATCH.trx_bank_acct_use_id
    FROM   gl_sets_of_books 		  sob,
	   ce_system_parameters 	  sp,
	   ce_statement_reconcils_all     rec,
	   ce_bank_acct_uses_ou_v 	  aba,
	   ce_bank_accounts	 	ba,
	   ce_bank_acct_uses_ou_v 	  aba2,
	   ce_bank_accounts	 	ba2,
	   ar_cash_receipt_history_all 	  crh,
	   ar_cash_receipts_all 	  cr,
	   ar_receivable_applications_all  ra,
	   ar_payment_schedules_all 	  ps
    WHERE  sob.set_of_books_id 		  = sp.set_of_books_id
    AND    nvl(rec.status_flag, 'U') 	  = 'U'
    AND    nvl(rec.current_record_flag,'Y') = 'Y'
    AND    nvl(rec.reference_type, 'RECEIPT') IN ('RECEIPT', 'DM REVERSAL')
    AND	   rec.reference_id(+) 		  = crh.cash_receipt_history_id
    AND    crh.status IN (
		DECODE(CE_AUTO_BANK_MATCH.csl_trx_type,
			'CREDIT', 'REMITTED',
			'REVERSED'),
		DECODE(sp.show_cleared_flag,
			'N','REMITTED',
			'CLEARED'),
		'REMITTED',
		'RISK_ELIMINATED')
    AND    crh.current_record_flag 	  = 'Y'
    AND    crh.cash_receipt_id 		  = cr.cash_receipt_id
    and    crh.org_id	= cr.org_id
    and    crh.org_id	= rec.org_id
    --AND  aba.bank_account_id 		  = cr.REMIT_BANK_ACCT_USE_ID
    --AND  cr.remittance_bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
    --AND  aba.bank_acct_use_id 	 = cr.remittance_bank_account_id
    --AND    cr.remit_bank_acct_use_id 	 = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
    AND	   aba.bank_acct_use_id 	 = cr.remit_bank_acct_use_id
    AND	   aba.org_id 	 		 = cr.org_id
    AND	   aba.org_id = nvl(CE_AUTO_BANK_REC.G_org_id, aba.org_id)
    --AND	   aba.org_id 	 		 = sp.org_id
    and BA.ACCOUNT_OWNER_ORG_ID = SP.LEGAL_ENTITY_ID
    AND    aba.bank_account_id 		 = ba.bank_account_id
    AND    aba.bank_account_id   	 = CE_AUTO_BANK_MATCH.csh_bank_account_id
    AND    aba.AR_USE_ENABLE_FLAG 	 = 'Y'
    AND	   crh.trx_date			  >= sp.cashbook_begin_date
    AND    cr.cash_receipt_id 		  = ra.cash_receipt_id
    and    cr.org_id			  = ra.org_id
    AND	   ra.display			  = 'Y'
    AND    ra.status 			  = 'APP'
    AND    ra.applied_payment_schedule_id = ps.payment_schedule_id
    and    ra.org_id			  = ps.org_id
    AND    ps.trx_number 	          = CE_AUTO_BANK_MATCH.csl_invoice_text
    --AND    aba2.bank_account_id         = cr.customer_bank_account_id
    AND    aba2.bank_acct_use_id          = cr.customer_bank_account_id --cr.customer_bank_acct_use_id
    AND	   aba2.org_id 	 		 = cr.org_id
    AND    aba2.bank_account_id 	 = ba2.bank_account_id
    AND    ba2.bank_account_num     	  = CE_AUTO_BANK_MATCH.csl_bank_account_text;
  END IF;

  IF ((CE_AUTO_BANK_MATCH.aba_bank_currency <>
      CE_AUTO_BANK_REC.G_functional_currency) and
      (CE_AUTO_BANK_MATCH.aba_bank_currency <>
      CE_AUTO_BANK_MATCH.trx_currency_code)) THEN
    cep_standard.debug('Forex account not using the same curr as bk');
    curr := 1;
    RAISE NO_DATA_FOUND;
  END IF;

  cep_standard.debug('<<CE_AUTO_BANK_MATCH.bank_account_match');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    cep_standard.debug('EXCEPTION: No data found');
    if (curr = 1) then
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	  CE_AUTO_BANK_MATCH.csh_statement_header_id,
	  CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_NO_FOREIGN_RECON');
    end if;
    cep_standard.debug('EXCEPTION: NO bank account match this receipt');
    if (CE_AUTO_BANK_MATCH.csl_trx_type IN ('DEBIT','STOP')) then
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	  CE_AUTO_BANK_MATCH.csh_statement_header_id,
	  CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_NO_BAP');
    else
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	  CE_AUTO_BANK_MATCH.csh_statement_header_id,
	  CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_NO_BAR');
    end if;
    no_of_matches := 0;
  WHEN OTHERS THEN
    IF (SQL%ROWCOUNT > 0) THEN
      cep_standard.debug('EXCEPTION: More than one bank account match this transaction');
      if (CE_AUTO_BANK_MATCH.csl_trx_type IN ('DEBIT','STOP')) then
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_APT_PARTIAL');
      else
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_ART_PARTIAL');
      end if;
      no_of_matches:=999;
    ELSE
      cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.bank_account_match' );
      RAISE;
    END IF;
END bank_account_match;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	invoice_match						        |
|									|
|  DESCRIPTION								|
| 	Using the invoice_number, try to find a matching receipt	|
|	NEW/prod16. Capability to match by invoice number also for AP	|
|									|
|  CALLED BY								|
|	match_line							|
 --------------------------------------------------------------------- */
PROCEDURE invoice_match (no_of_matches		OUT NOCOPY	NUMBER) IS
  curr		NUMBER;
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.invoice_match');
  no_of_matches := 1;
  IF (CE_AUTO_BANK_MATCH.csl_trx_type IN ('DEBIT','STOP')) THEN
    SELECT    DISTINCT(c.check_id),
	      to_number(NULL),
	      c.rowid,
	      DECODE(c.currency_code,
			sob.currency_code,c.amount,
			ba.currency_code,c.amount,
			NVL(c.base_amount,c.amount)),
	      DECODE(DECODE(c.status_lookup_code,
				'CLEARED BUT UNACCOUNTED','CLEARED',
				c.status_lookup_code),
			'CLEARED',c.cleared_base_amount,
			c.cleared_amount),
	      c.status_lookup_code,
	      DECODE(c.currency_code,
			sob.currency_code, DECODE(DECODE(c.status_lookup_code,
					'CLEARED BUT UNACCOUNTED','CLEARED',
					c.status_lookup_code),
				'CLEARED',c.cleared_amount),
			ba.currency_code, DECODE(DECODE(c.status_lookup_code,
					'CLEARED BUT UNACCOUNTED','CLEARED',
					c.status_lookup_code),
				'CLEARED',c.cleared_amount),
			DECODE(DECODE(c.status_lookup_code,
					'CLEARED BUT UNACCOUNTED','CLEARED',
					c.status_lookup_code),
				'CLEARED',NVL(c.cleared_base_amount, c.cleared_amount))),
	      'PAYMENT',
	      c.currency_code,
	      DECODE(c.currency_code,
		     sob.currency_code, 'FUNCTIONAL',
		     ba.currency_code, 'BANK',
	 	     'FOREIGN'),
	      c.amount,
	      'PAYMENT',
	      DECODE(DECODE(c.status_lookup_code,
				'CLEARED BUT UNACCOUNTED','CLEARED',
				c.status_lookup_code),
			'CLEARED',c.cleared_exchange_rate,
			c.exchange_rate),
	      DECODE(DECODE(c.status_lookup_code,
				'CLEARED BUT UNACCOUNTED','CLEARED',
				c.status_lookup_code),
			'CLEARED',c.cleared_exchange_date,
			c.exchange_date),
	      DECODE(DECODE(c.status_lookup_code,
				'CLEARED BUT UNACCOUNTED','CLEARED',
				c.status_lookup_code),
			'CLEARED',c.cleared_exchange_rate_type,
			c.exchange_rate_type),
	      aph.accounting_date,
              c.cleared_date,
	      c.org_id,
	      c.CE_BANK_ACCT_USE_ID
    INTO   CE_AUTO_BANK_MATCH.trx_id,
	   CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
	   CE_AUTO_BANK_MATCH.trx_rowid,
	   CE_AUTO_BANK_MATCH.trx_amount,
	   CE_AUTO_BANK_MATCH.trx_base_amount,
	   CE_AUTO_BANK_MATCH.trx_status,
	   CE_AUTO_BANK_MATCH.trx_cleared_amount,
	   CE_AUTO_BANK_MATCH.csl_match_type,
	   CE_AUTO_BANK_MATCH.trx_currency_code,
	   CE_AUTO_BANK_MATCH.trx_currency_type,
	   CE_AUTO_BANK_MATCH.trx_curr_amount,
	   CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
	   CE_AUTO_BANK_MATCH.trx_exchange_rate,
	   CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
	   CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
	   CE_AUTO_BANK_MATCH.trx_gl_date,
	   CE_AUTO_BANK_MATCH.trx_cleared_date,
	   CE_AUTO_BANK_MATCH.trx_org_id,
 	   CE_AUTO_BANK_MATCH.trx_bank_acct_use_id
    FROM   gl_sets_of_books 		sob,
	   ce_system_parameters 	sp,
	   ce_statement_reconcils_all   rec,
	   ce_bank_accounts		ba,
	   ce_bank_acct_uses_ou_v	aba,
	   ap_payment_history_all       aph,
	   ap_checks_all		c,
	   ap_invoice_payments_all	pay,
	   ap_invoices_all		inv,
	   po_vendors			ven
    WHERE  sob.set_of_books_id 		= sp.set_of_books_id
    AND    NVL(rec.status_flag, 'U') 	= 'U'
    AND    NVL(rec.current_record_flag,'Y') = 'Y'
    AND	   rec.reference_type(+) 	= 'PAYMENT'
    AND	   rec.reference_id(+) 		= c.check_id
    --AND  aba.bank_account_id		= c.bank_account_id
    AND	   aba.bank_acct_use_id		= c.CE_BANK_ACCT_USE_ID
    AND    aba.bank_account_id	 	= ba.bank_account_id
    AND    aba.bank_account_id 		= CE_AUTO_BANK_MATCH.csh_bank_account_id --bug5182963
    and BA.ACCOUNT_OWNER_ORG_ID = SP.LEGAL_ENTITY_ID
    AND	   aba.org_id			= c.org_id
    AND		aba.org_id = nvl(CE_AUTO_BANK_REC.G_org_id, aba.org_id)
    --AND	   aba.bank_acct_use_id		= CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
    AND	   c.status_lookup_code		IN
	   ('NEGOTIABLE', 'STOP INITIATED',
	   DECODE(CE_AUTO_BANK_MATCH.csl_trx_type,
		'STOP', 'VOIDED',
		'NEGOTIABLE'),
	   DECODE(sp.show_cleared_flag,
		'N','NEGOTIABLE',
		'CLEARED'),
	   DECODE(sp.show_cleared_flag,
		'N','NEGOTIABLE',
		'CLEARED BUT UNACCOUNTED'))
    AND	   c.check_date			 >= sp.cashbook_begin_date
    AND    c.check_id			 = pay.check_id
    AND	   c.org_id			= pay.org_id
    AND	   pay.invoice_id		 = inv.invoice_id
    AND	   inv.invoice_num		 = CE_AUTO_BANK_MATCH.csl_invoice_text
    AND    inv.vendor_id		 = ven.vendor_id
	-- AND    ven.vendor_name		 = NVL(CE_AUTO_BANK_MATCH.csl_customer_text, ven.vendor_name) -- Bug 9402067
    AND    ven.vendor_name		 =  CE_AUTO_BANK_MATCH.csl_customer_text -- Bug 9402067
    AND    aph.check_id (+) 		 = c.check_id
    AND	   aph.org_id (+) 		 = c.org_id
    AND    aph.transaction_type (+) = 'PAYMENT CLEARING'
    AND not exists
        (select null
         from   ap_payment_history aph2
         where  aph2.check_id = c.check_id
      	 and  aph2.org_id = c.org_id
         and    aph2.transaction_type = 'PAYMENT CLEARING'
         and    aph2.payment_history_id > aph.payment_history_id);
  ELSE
    SELECT distinct(crh.cash_receipt_history_id),
	   crh.cash_receipt_id,
	   crh.rowid,
	   DECODE(cr.currency_code,
		CE_AUTO_BANK_REC.G_functional_currency, crh.amount,
		CE_AUTO_BANK_MATCH.aba_bank_currency,   crh.amount,
		NVL(crh.acctd_amount,crh.amount)),
	   crh.acctd_amount,
	   crh.status,
	   DECODE( crh.status,
		'CLEARED', crh.amount,
		'RISK_ELIMINATED', crh.amount,
		0),
	   cr.type,
	   cr.currency_code,
	   DECODE(cr.currency_code,
		sob.currency_code, 'FUNCTIONAL',
		ba.currency_code, 'BANK',
		'FOREIGN'),
	   crh.amount,
	   cr.type,
	   crh.exchange_rate,
	   crh.exchange_date,
	   crh.exchange_rate_type,
	   crh.org_id,
	   cr.remit_bank_acct_use_id
    INTO   CE_AUTO_BANK_MATCH.trx_id,
	   CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
	   CE_AUTO_BANK_MATCH.trx_rowid,
	   CE_AUTO_BANK_MATCH.trx_amount,
	   CE_AUTO_BANK_MATCH.trx_base_amount,
	   CE_AUTO_BANK_MATCH.trx_status,
	   CE_AUTO_BANK_MATCH.trx_cleared_amount,
	   CE_AUTO_BANK_MATCH.csl_match_type,
	   CE_AUTO_BANK_MATCH.trx_currency_code,
	   CE_AUTO_BANK_MATCH.trx_currency_type,
	   CE_AUTO_BANK_MATCH.trx_curr_amount,
	   CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
	   CE_AUTO_BANK_MATCH.trx_exchange_rate,
	   CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
	   CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
 	   CE_AUTO_BANK_MATCH.trx_org_id,
 	   CE_AUTO_BANK_MATCH.trx_bank_acct_use_id
   FROM   gl_sets_of_books 		  sob,
	   ce_system_parameters	  sp,
	   ce_statement_reconcils_all   rec,
	   ce_bank_accounts 		  ba,
	   ce_bank_acct_uses_ou_v	  aba,
	   ar_cash_receipt_history_all 	  crh,
	   ar_cash_receipts_all 	  cr,
	   ar_receivable_applications_all  ra,
	   --ra_customers			  rc,
        HZ_CUST_ACCOUNTS                CU,
	   hz_parties			hp,
	   ar_payment_schedules_all 	  ps
    WHERE  sob.set_of_books_id 		  = sp.set_of_books_id
    AND    nvl(rec.status_flag, 'U') 	  = 'U'
    AND    nvl(rec.current_record_flag,'Y') = 'Y'
    AND    nvl(rec.reference_type, 'RECEIPT') IN ('RECEIPT', 'DM REVERSAL')
    AND	   rec.reference_id(+) 		  = crh.cash_receipt_history_id
    AND    crh.status	IN ('REMITTED',
		DECODE(sp.show_cleared_flag,
			'N','REMITTED',
			'CLEARED'),
		decode(CE_AUTO_BANK_MATCH.csl_trx_type,
			'NSF', 'REVERSED',
			'REJECTED', 'REVERSED',
			'REMITTED'),
		'RISK_ELIMINATED')
    AND    crh.current_record_flag 	  = 'Y'
    AND    crh.cash_receipt_id 		  = cr.cash_receipt_id
    and    crh.org_id	= cr.org_id
    and    crh.org_id	= rec.org_id (+)  -- Bug # 8587301 Added (+) Outer Join
    --AND  aba.bank_account_id 		  = cr.remittance_bank_account_id
    --AND    cr.remittance_bank_account_id =CE_AUTO_BANK_MATCH.csh_bank_account_id
    AND	   aba.bank_acct_use_id 	 = cr.remit_bank_acct_use_id
    AND   aba.org_id = nvl(CE_AUTO_BANK_REC.G_org_id, aba.org_id)
    --AND	   aba.bank_acct_use_id		= CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
    AND	   aba.org_id 	 		 = cr.org_id
    --AND	   aba.org_id 	 		 = sp.org_id
    AND  aba.bank_account_id 		  = ba.bank_account_id
    and   BA.ACCOUNT_OWNER_ORG_ID = SP.LEGAL_ENTITY_ID
    AND    crh.status = decode(CE_AUTO_BANK_MATCH.csl_trx_type,
		   'NSF', decode(CE_AUTO_BANK_REC.G_nsf_handling,
				'REVERSE',crh.status,
				'REVERSED'),
		   'REJECTED', decode('REVERSE',
				'REVERSE', crh.status,
				'REVERSED'),
		   crh.status)
    AND	   crh.trx_date			  >= sp.cashbook_begin_date
    AND    cr.cash_receipt_id 		  = ra.cash_receipt_id
    and    cr.org_id			  = ra.org_id
--    AND	   ra.display			  = 'Y'
    AND    ra.status 			  = 'APP'
    AND    ra.applied_payment_schedule_id = ps.payment_schedule_id
    and    ra.org_id			  = ps.org_id
    --AND    rc.customer_name 		  = CE_AUTO_BANK_MATCH.csl_customer_text
    --AND    rc.customer_id  		  = nvl(ps.customer_id,rc.customer_id)
AND	CU.CUST_ACCOUNT_ID		= CR.PAY_FROM_CUSTOMER
AND     HP.PARTY_ID 			= CU.PARTY_ID
    AND    hp.party_name 		  = CE_AUTO_BANK_MATCH.csl_customer_text
    AND    CU.CUST_ACCOUNT_ID  		  = nvl(ps.customer_id,CU.CUST_ACCOUNT_ID) -- Bug # 8675333 Changed Hp.Party_id to CU.CUST_ACCOUNT_ID
   AND    ps.trx_number 	          = CE_AUTO_BANK_MATCH.csl_invoice_text;
  END IF;

  IF (CE_AUTO_BANK_MATCH.aba_bank_currency <>
	  CE_AUTO_BANK_REC.G_functional_currency) and
     (CE_AUTO_BANK_MATCH.aba_bank_currency <>
	  CE_AUTO_BANK_MATCH.trx_currency_code) THEN
    cep_standard.debug('Forex account not using the same curr as bk');
    curr := 1;
    RAISE NO_DATA_FOUND;
  END IF;

  cep_standard.debug('<<CE_AUTO_BANK_MATCH.invoice_match');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
      cep_standard.debug('EXCEPTION: No data found');
      if (curr = 1) then
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_NO_FOREIGN_RECON');
      end if;
      cep_standard.debug('EXCEPTION: NO invoices match this receipt');
      if (CE_AUTO_BANK_MATCH.csl_trx_type IN ('DEBIT','STOP')) then
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_NO_INP');
      else
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_NO_INR');
      end if;
      no_of_matches := 0;
  WHEN OTHERS THEN
    IF (SQL%ROWCOUNT >0) THEN
      cep_standard.debug('EXCEPTION: More than one invoice match this transaction');
      if (CE_AUTO_BANK_MATCH.csl_trx_type IN ('DEBIT','STOP')) then
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_APT_PARTIAL');
      else
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_ART_PARTIAL');
      end if;
      no_of_matches:=999;
    ELSE
      cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.invoice_match' );
      RAISE;
    END IF;
END invoice_match;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	batch_match     						|
|									|
|  DESCRIPTION								|
|	Using the statement line transaction number, try to find a 	|
| 	matching batch from CE_<APPL_ID>_BATCHES_V			|
|									|
|  CALLED BY								|
|	match_line						        |
 --------------------------------------------------------------------- */
PROCEDURE batch_match(no_of_matches		OUT NOCOPY  NUMBER,
		      no_of_currencies		IN OUT NOCOPY  NUMBER) IS

  trx_count			NUMBER;
  curr		                NUMBER;

  trx_count_ap			NUMBER;
  trx_count_ce			NUMBER;
  trx_amount_ap        		NUMBER;
  trx_amount_ce        		NUMBER;
  trx_base_amount_ap   		NUMBER;
  trx_base_amount_ce   		NUMBER;
  trx_cleared_amount_ap 	NUMBER;
  trx_cleared_amount_ce 	NUMBER;
  no_of_currencies_ap 		NUMBER;
  no_of_currencies_ce 		NUMBER;
  trx_curr_amount_ap  		NUMBER;
  trx_curr_amount_ce  		NUMBER;

  /* Bug 8218042 add variables for rounding FOREIGN currency amounts */
  funct_curr_precision      NUMBER;
  funct_curr_ext_precision  NUMBER;
  funct_curr_min_acct_unit  NUMBER;

BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.batch_match csl_trx_type='||CE_AUTO_BANK_MATCH.csl_trx_type);
  no_of_matches := 0;

  IF (CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'PAY_EFT') THEN
	pay_eft_match(no_of_matches, no_of_currencies);

  ELSIF (CE_AUTO_BANK_MATCH.csl_trx_type IN ('DEBIT','STOP')) THEN
    --
    -- 7571492: Added clearing_trx_type as 'PAYMENT' for a payment
    -- batch. Without this tolerances were not being properly fetched.
    --
    curr := 1;
    SELECT
         ab.batch_id,
         ab.row_id,
         1,
         ab.trx_currency_type,
         ab.currency_code,
         'PBATCH',
         ab.exchange_rate,
         ab.exchange_rate_date,
         ab.exchange_rate_type,
         ab.org_id,
         ab.legal_entity_id,
         ab.CE_BANK_ACCT_USE_ID,
         'PAYMENT'                       -- bug 7571492
    INTO
         CE_AUTO_BANK_MATCH.trx_id,
         CE_AUTO_BANK_MATCH.trx_rowid,
         no_of_matches,
         CE_AUTO_BANK_MATCH.trx_currency_type,
         CE_AUTO_BANK_MATCH.trx_currency_code,
         CE_AUTO_BANK_MATCH.csl_match_type,
         CE_AUTO_BANK_MATCH.trx_exchange_rate,
         CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
         CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
         CE_AUTO_BANK_MATCH.trx_org_id,
         CE_AUTO_BANK_MATCH.trx_legal_entity_id,
         CE_AUTO_BANK_MATCH.trx_bank_acct_use_id,
         CE_AUTO_BANK_MATCH.csl_clearing_trx_type -- bug 7571492
    FROM CE_200_BATCHES_V ab
    WHERE
         UPPER(ab.trx_number) = UPPER(CE_AUTO_BANK_MATCH.csl_bank_trx_number)
        --AND	ab.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id  --bug 4435028 ignore MO security for IBY batches
         AND (ab.org_id = nvl(CE_AUTO_BANK_REC.G_org_id, ab.org_id)
            OR ab.legal_entity_id = nvl(CE_AUTO_BANK_REC.G_legal_entity_id, ab.legal_entity_id))
         AND		ab.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id;

     --bug 7514063 added NVL to the columns in select clause
    curr := 2;
    SELECT 	count(*),
		NVL(sum(catv.bank_account_amount),0),
		nvl(sum(catv.base_amount),0),
		nvl(sum(catv.amount_cleared),0),
		NVL(SUM(DECODE(catv.currency_code,
		    CE_AUTO_BANK_MATCH.trx_currency_code,0,1)),0),
		NVL(sum(catv.amount),0),
		'PBATCH'
    INTO    	trx_count_ap,
		trx_amount_ap,
		trx_base_amount_ap,
		trx_cleared_amount_ap,
		no_of_currencies_ap,
		trx_curr_amount_ap,
		CE_AUTO_BANK_MATCH.csl_match_type
    --FROM 	ce_200_transactions_v catv
    FROM      	ce_available_transactions_tmp catv
    WHERE	catv.batch_id = CE_AUTO_BANK_MATCH.trx_id
    AND		nvl(catv.status, 'NEGOTIABLE') <> 'VOIDED'
    AND		catv.application_id = 200
    AND		NVL(catv.reconciled_status_flag, 'N') = 'N';


    --bug 7514063 added NVL to the columns in select clause
    curr := 22;
    SELECT 	count(*),
		NVL(sum(catv.bank_account_amount),0),
		nvl(sum(catv.base_amount),0),
		nvl(sum(catv.amount_cleared),0),
		NVL(SUM(DECODE(catv.currency_code,
		    CE_AUTO_BANK_MATCH.trx_currency_code,0,1)),0),
		NVL(sum(catv.amount),0),
		'PBATCH'
    INTO    	trx_count_ce,
		trx_amount_ce,
		trx_base_amount_ce,
		trx_cleared_amount_ce,
		no_of_currencies_ce,
		trx_curr_amount_ce,
		CE_AUTO_BANK_MATCH.csl_match_type
    --FROM 	ce_260_cf_transactions_v catv
    FROM        ce_available_transactions_tmp catv
    WHERE	catv.batch_id = CE_AUTO_BANK_MATCH.trx_id
    AND		nvl(catv.status, 'CANCELED') <> 'CANCELED'
    AND		catv.application_id = 261
    AND		NVL(catv.reconciled_status_flag, 'N') = 'N';

	-- bug 4435028 new iPayment batches include transactions from both AP and CE
	trx_count 				:= trx_count_ap + trx_count_ce;
	CE_AUTO_BANK_MATCH.trx_amount 		:= trx_amount_ap + trx_amount_ce;
	CE_AUTO_BANK_MATCH.trx_base_amount	:= trx_base_amount_ap + trx_base_amount_ce;
	CE_AUTO_BANK_MATCH.trx_cleared_amount	:= trx_cleared_amount_ap + trx_cleared_amount_ce;
	no_of_currencies			:= no_of_currencies_ap + no_of_currencies_ce;
	CE_AUTO_BANK_MATCH.trx_curr_amount	:= trx_curr_amount_ap + trx_curr_amount_ce;

    cep_standard.debug('CE_AUTO_BANK_MATCH.trx_amount='|| CE_AUTO_BANK_MATCH.trx_amount);

    /* Bug 8218042 - The amount is not rounded in the view. */
    IF ((CE_AUTO_BANK_MATCH.trx_currency_type = 'FOREIGN') AND
        (CE_AUTO_BANK_MATCH.trx_currency_code <> CE_AUTO_BANK_REC.G_functional_currency))
    THEN
        cep_standard.debug('rounding trx amount');
        fnd_currency.get_info(CE_AUTO_BANK_REC.G_functional_currency,
                              funct_curr_precision,
                              funct_curr_ext_precision,
                              funct_curr_min_acct_unit);

        CE_AUTO_BANK_MATCH.trx_amount := round(CE_AUTO_BANK_MATCH.trx_curr_amount *
                                               CE_AUTO_BANK_MATCH.trx_exchange_rate,
                                               funct_curr_precision);
    END IF;
    cep_standard.debug('rounded CE_AUTO_BANK_MATCH.trx_amount='|| CE_AUTO_BANK_MATCH.trx_amount);
    /* Bug 8218042 */


  ELSIF (CE_AUTO_BANK_MATCH.csl_trx_type IN ('CREDIT','NSF','REJECTED')) THEN

    curr := 3;
    SELECT  	ab.batch_id,
		ab.row_id,
		1,
		ab.trx_currency_type,
		ab.currency_code,
		'RBATCH',
		ab.exchange_rate,
		ab.exchange_rate_date,
		ab.exchange_rate_type,
		ab.org_id,
		ab.CE_BANK_ACCT_USE_ID
    INTO        CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.csl_match_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
		CE_AUTO_BANK_MATCH.trx_org_id,
 		CE_AUTO_BANK_MATCH.trx_bank_acct_use_id
    FROM 	CE_222_BATCHES_V ab
    WHERE       ab.trx_number = CE_AUTO_BANK_MATCH.csl_bank_trx_number
    --AND		ab.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
    AND   ab.org_id = nvl(CE_AUTO_BANK_REC.G_org_id, ab.org_id)
    AND		ab.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id;

    curr := 4;
    SELECT 	count(*),
		sum(catv.bank_account_amount),
		sum(catv.base_amount),
		nvl(sum(catv.amount_cleared),0),
		SUM(DECODE(catv.currency_code,
		    CE_AUTO_BANK_MATCH.trx_currency_code,0,1)),
		SUM(catv.amount),
		'RBATCH'
    INTO    	trx_count,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		no_of_currencies,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_match_type
    FROM 	ce_222_txn_for_batch_v catv
    WHERE catv.batch_id = CE_AUTO_BANK_MATCH.trx_id
    AND   nvl(catv.status, 'REMITTED') <> 'REVERSED';
  END IF;

  curr := 5;
  IF (trx_count = 0) THEN
    RAISE NO_DATA_FOUND;
  END IF;
  cep_standard.debug('Batch trx_count = '||trx_count);
  cep_standard.debug('trx_amount = '||CE_AUTO_BANK_MATCH.trx_amount);
  cep_standard.debug('trx_base_amount = '||CE_AUTO_BANK_MATCH.trx_base_amount);
  cep_standard.debug('trx_cleared_amount = '||CE_AUTO_BANK_MATCH.trx_cleared_amount);
  cep_standard.debug('trx_curr_amount = '||CE_AUTO_BANK_MATCH.trx_curr_amount);
  cep_standard.debug('csl_match_type = '||CE_AUTO_BANK_MATCH.csl_match_type);

  IF (CE_AUTO_BANK_MATCH.aba_bank_currency <>
	  CE_AUTO_BANK_REC.G_functional_currency) and
     (CE_AUTO_BANK_MATCH.aba_bank_currency <>
	  CE_AUTO_BANK_MATCH.trx_currency_code) THEN
    cep_standard.debug('Forex account not using the same curr as bk');
    curr := 6;
    RAISE NO_DATA_FOUND;
  END IF;

  cep_standard.debug('<<CE_AUTO_BANK_MATCH.batch_match');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    cep_standard.debug('EXCEPTION: No data found');
    if (curr = 6) then
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	  CE_AUTO_BANK_MATCH.csh_statement_header_id,
	  CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_NO_FOREIGN_RECON');
    elsif (curr = 1) then
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	  CE_AUTO_BANK_MATCH.csh_statement_header_id,
	  CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_NO_BATCH_P');
    elsif (curr = 3) then
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	  CE_AUTO_BANK_MATCH.csh_statement_header_id,
	  CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_NO_BATCH_R');
    end if;
    no_of_matches := 0;
  WHEN OTHERS THEN
    IF (SQL%NOTFOUND) THEN
      cep_standard.debug('EXCEPTION: NO data found in batch_match');
      if (curr = 1) then
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	    CE_AUTO_BANK_MATCH.csh_statement_header_id,
	    CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_NO_BATCH_P');
      elsif (curr = 3) then
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	    CE_AUTO_BANK_MATCH.csh_statement_header_id,
	    CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_NO_BATCH_R');
      end if;
      no_of_matches:=0;
    ELSIF (SQL%ROWCOUNT >0) THEN
      cep_standard.debug('EXCEPTION: More than one batch match this receipt' );
      if (CE_AUTO_BANK_MATCH.csl_trx_type IN ('DEBIT','STOP')) then
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	    CE_AUTO_BANK_MATCH.csh_statement_header_id,
	    CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_APB_PARTIAL');
      else
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	    CE_AUTO_BANK_MATCH.csh_statement_header_id,
	    CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_ARB_PARTIAL');
      end if;
      no_of_matches:=999;
    ELSE
      cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.batch_match' );
      RAISE;
    END IF;
END batch_match;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|    group_match                                                        |
|                                                                       |
|  DESCRIPTION                                                          |
|    Using the statement line transaction number, try to find a         |
|     matching group in payment from CE_200_GROUPS_V                    |
|    FOR SEPA ER 6700007                                                |
|  CALLED BY                                                            |
|    match_line                                                         |
 --------------------------------------------------------------------- */
PROCEDURE group_match(
    no_of_matches       OUT NOCOPY  NUMBER,
    no_of_currencies    IN OUT NOCOPY  NUMBER
) IS

    trx_count               NUMBER;
    curr                    NUMBER;

    /* Bug 8218042 add variables for rounding FOREIGN currency amounts */
    funct_curr_precision      NUMBER;
    funct_curr_ext_precision  NUMBER;
    funct_curr_min_acct_unit  NUMBER;

BEGIN
    cep_standard.debug('>>CE_AUTO_BANK_MATCH.group_match csl_trx_type='||CE_AUTO_BANK_MATCH.csl_trx_type);
    no_of_matches := 0;

    curr := 1;
    --
    -- 7571492: Added clearing_trx_type as 'PAYMENT' for a payment
    -- batch. Without this tolerances were not being properly fetched.
    --
    SELECT
        ab.batch_id,
        ab.row_id,
        1,
        ab.trx_currency_type,
        ab.currency_code,
        'PGROUP',       -- 7571492 : Changed to PGROUP
        ab.exchange_rate,
        ab.exchange_rate_date,
        ab.exchange_rate_type,
        ab.org_id,
        ab.legal_entity_id,
        ab.CE_BANK_ACCT_USE_ID,
        ab.logical_group_reference,
        'PAYMENT'                       -- bug 7571492
    INTO
        CE_AUTO_BANK_MATCH.trx_id,
        CE_AUTO_BANK_MATCH.trx_rowid,
        no_of_matches,
        CE_AUTO_BANK_MATCH.trx_currency_type,
        CE_AUTO_BANK_MATCH.trx_currency_code,
        CE_AUTO_BANK_MATCH.csl_match_type,
        CE_AUTO_BANK_MATCH.trx_exchange_rate,
        CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
        CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
        CE_AUTO_BANK_MATCH.trx_org_id,
        CE_AUTO_BANK_MATCH.trx_legal_entity_id,
        CE_AUTO_BANK_MATCH.trx_bank_acct_use_id,
        CE_AUTO_BANK_MATCH.logical_group_reference,
        CE_AUTO_BANK_MATCH.csl_clearing_trx_type -- bug 7571492
    FROM CE_200_GROUPS_V ab
    WHERE upper(ab.logical_group_reference) = upper(CE_AUTO_BANK_MATCH.csl_bank_trx_number)
      AND (ab.org_id = nvl(CE_AUTO_BANK_REC.G_org_id, ab.org_id)
           or
           ab.legal_entity_id = nvl(CE_AUTO_BANK_REC.G_legal_entity_id, ab.legal_entity_id))
      AND ab.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id;

    -- 7571492 : Changed local variables in INTO clause to global variables.
    curr := 2;
    SELECT
        count(*),
        sum(catv.bank_account_amount),
        nvl(sum(catv.base_amount),0),
        nvl(sum(catv.amount_cleared),0),
        SUM(DECODE(catv.currency_code, CE_AUTO_BANK_MATCH.trx_currency_code,0,1)),
        sum(catv.amount),
        'PGROUP'
    INTO
        trx_count,
        CE_AUTO_BANK_MATCH.trx_amount,
        CE_AUTO_BANK_MATCH.trx_base_amount,
        CE_AUTO_BANK_MATCH.trx_cleared_amount,
        no_of_currencies,
        CE_AUTO_BANK_MATCH.trx_curr_amount,
        CE_AUTO_BANK_MATCH.csl_match_type
    FROM          ce_available_transactions_tmp catv
    WHERE    catv.batch_id = CE_AUTO_BANK_MATCH.trx_id
    AND        nvl(catv.status, 'NEGOTIABLE') <> 'VOIDED'
    AND        catv.application_id = 200
    AND        NVL(catv.reconciled_status_flag, 'N') = 'N'
    AND    EXISTS ( SELECT 1
                    FROM iby_payments_all IPA ,AP_CHECKS_ALL ACA
            WHERE ACA.CHECK_ID   =catv.trx_id
              AND ACA.PAYMENT_INSTRUCTION_ID  = CE_AUTO_BANK_MATCH.trx_id
              AND IPA.PAYMENT_INSTRUCTION_ID  = CE_AUTO_BANK_MATCH.trx_id
              AND IPA.PAYMENT_ID = ACA.PAYMENT_ID
              AND IPA.LOGICAL_GROUP_REFERENCE = NVL(CE_AUTO_BANK_MATCH.LOGICAL_GROUP_REFERENCE,IPA.LOGICAL_GROUP_REFERENCE));

  IF (trx_count = 0) THEN
    cep_standard.debug('No trx for group '||CE_AUTO_BANK_MATCH.csl_bank_trx_number);
    RAISE NO_DATA_FOUND;
  END IF;
  cep_standard.debug('Group trx_count = '||trx_count);
  cep_standard.debug('trx_amount = '||CE_AUTO_BANK_MATCH.trx_amount);
  cep_standard.debug('trx_base_amount = '||CE_AUTO_BANK_MATCH.trx_base_amount);
  cep_standard.debug('trx_cleared_amount = '||CE_AUTO_BANK_MATCH.trx_cleared_amount);
  cep_standard.debug('trx_curr_amount = '||CE_AUTO_BANK_MATCH.trx_curr_amount);
  cep_standard.debug('csl_match_type = '||CE_AUTO_BANK_MATCH.csl_match_type);

  IF (CE_AUTO_BANK_MATCH.aba_bank_currency <> CE_AUTO_BANK_REC.G_functional_currency) AND
     (CE_AUTO_BANK_MATCH.aba_bank_currency <> CE_AUTO_BANK_MATCH.trx_currency_code)
  THEN
    cep_standard.debug('Forex trx not using the same curr as account');
    curr := 6;
    RAISE NO_DATA_FOUND;
  END IF;

    /* Bug 8218042 - The amount is not rounded in the view. */
    IF ((CE_AUTO_BANK_MATCH.trx_currency_type = 'FOREIGN') AND
        (CE_AUTO_BANK_MATCH.trx_currency_code <> CE_AUTO_BANK_REC.G_functional_currency))
    THEN
        cep_standard.debug('rounding trx amount');
        fnd_currency.get_info(CE_AUTO_BANK_REC.G_functional_currency,
                              funct_curr_precision,
                              funct_curr_ext_precision,
                              funct_curr_min_acct_unit);

        CE_AUTO_BANK_MATCH.trx_amount := round(CE_AUTO_BANK_MATCH.trx_curr_amount *
                                               CE_AUTO_BANK_MATCH.trx_exchange_rate,
                                               funct_curr_precision);
    END IF;
    cep_standard.debug('rounded CE_AUTO_BANK_MATCH.trx_amount='|| CE_AUTO_BANK_MATCH.trx_amount);
    /* Bug 8218042 */

    cep_standard.debug('<<CE_AUTO_BANK_MATCH.group_match');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    cep_standard.debug('EXCEPTION: #1 No data found in group_match');
    cep_standard.debug('curr = '||curr);
    if (curr = 6) then
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
      CE_AUTO_BANK_MATCH.csh_statement_header_id,
      CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_NO_FOREIGN_RECON');
    elsif (curr = 1) then
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
      CE_AUTO_BANK_MATCH.csh_statement_header_id,
      CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_NO_GROUP_P');
     end if;
    no_of_matches := 0;
  WHEN OTHERS THEN
    IF (SQL%NOTFOUND) THEN
      cep_standard.debug('EXCEPTION: NO data found in group_match');
      cep_standard.debug('curr = '||curr);
     CE_RECONCILIATION_ERRORS_PKG.insert_row(
        CE_AUTO_BANK_MATCH.csh_statement_header_id,
        CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_NO_GROUP_P');
      no_of_matches:=0;
    ELSIF (SQL%ROWCOUNT >0) THEN
      cep_standard.debug('EXCEPTION: More than one batch match this group' );
      cep_standard.debug('curr = '||curr);
    CE_RECONCILIATION_ERRORS_PKG.insert_row(
        CE_AUTO_BANK_MATCH.csh_statement_header_id,
        CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_APG_PARTIAL');
      no_of_matches:=999;
    ELSE
      cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.group_match' );
      RAISE;
    END IF;
END group_match;


FUNCTION convert_to_base_curr( amount_to_convert NUMBER) RETURN NUMBER IS
  precision		NUMBER;
  ext_precision		NUMBER;
  min_acct_unit		NUMBER;
  acctd_amount		NUMBER;
  rounded_amount	NUMBER;
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.convert_to_base_curr');

  IF (CE_AUTO_BANK_MATCH.csl_exchange_rate_type <> 'User') THEN

    BEGIN
      acctd_amount := gl_currency_api.convert_amount(
		CE_AUTO_BANK_MATCH.csl_currency_code,
		CE_AUTO_BANK_REC.G_functional_currency,
		nvl(CE_AUTO_BANK_MATCH.csl_exchange_rate_date,
		    CE_AUTO_BANK_MATCH.csl_trx_date),
		CE_AUTO_BANK_MATCH.csl_exchange_rate_type,
		amount_to_convert);

      cep_standard.debug('acctd_amount '||acctd_amount);
    EXCEPTION
      WHEN OTHERS THEN
	cep_standard.debug('EXCEPTION: Could not convert amount');
	acctd_amount := NULL;
    END;

    rounded_amount := acctd_amount;

  ELSE

    acctd_amount := amount_to_convert * CE_AUTO_BANK_MATCH.csl_exchange_rate;
    fnd_currency.get_info(CE_AUTO_BANK_MATCH.aba_bank_currency, precision,
		ext_precision, min_acct_unit);
    IF (min_acct_unit IS NOT NULL) THEN
      rounded_amount := round(acctd_amount/min_acct_unit,0) * min_acct_unit;
    ELSE
      rounded_amount := round(acctd_amount,precision);
    END IF;

  END IF;

  cep_standard.debug('<<CE_AUTO_BANK_MATCH.convert_to_base_curr');
  RETURN(rounded_amount);

EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.convert_to_base_curr');
    RAISE;
END convert_to_base_curr;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|    create_misc_trx                                                    |
|                                                                       |
|  DESCRIPTION                                                          |
|    Misc receipt can be created when                                   |
|       1) csl_bank_trx_number is null and csl_create_misc_trx_flag=Y   |
|       2) csl_bank_trx_number is not null and no matching misc receipt |
|          and csl_create_misc_trx_flag=Y                               |
|          bug 3407503, 4542114                                         |
|  CALLED BY                                                            |
|       match_engine                                                    |
--------------------------------------------------------------------- */
PROCEDURE create_misc_trx
IS
  no_of_currencies       NUMBER;
  x_statement_line_id    CE_STATEMENT_LINES.statement_line_id%TYPE;
  misc_exists            VARCHAR2(1);
  receipt_amount         NUMBER;
  base_receipt_amount    NUMBER;
  PRECISION              NUMBER;
  ext_precision          NUMBER;
  min_acct_unit          NUMBER;
  l_vat_tax_id           NUMBER;
  l_tax_rate             NUMBER;
  l_trx_number           CE_STATEMENT_LINES.BANK_TRX_NUMBER%TYPE; --Bug 3385023 added this variable.
  current_org_id         NUMBER;
  receivables_trx_org_id NUMBER;
  l_creation_status      AR_RECEIPT_CLASSES.creation_status%TYPE; --Bug 9021558 Added
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.create_misc_trx');
  IF (CE_AUTO_BANK_MATCH.csl_create_misc_trx_flag = 'Y' AND
      CE_AUTO_BANK_MATCH.csl_matching_against <> 'STMT')
  THEN
    cep_standard.debug('DEBUG: trx_curr: '|| CE_AUTO_BANK_MATCH.trx_currency_type);
    IF (trx_currency_type = 'FOREIGN' AND
        CE_AUTO_BANK_MATCH.aba_bank_currency <> CE_AUTO_BANK_REC.G_functional_currency)
     OR(trx_currency_type = 'FUNCTIONAL' AND
        CE_AUTO_BANK_MATCH.aba_bank_currency <> CE_AUTO_BANK_REC.G_functional_currency)
    THEN
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
          CE_AUTO_BANK_MATCH.csh_statement_header_id,
          CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_NO_FOREIGN_MISC');
    ELSE
      CE_AUTO_BANK_MATCH.csl_match_type        := 'CMISC';
      CE_AUTO_BANK_MATCH.csl_clearing_trx_type := 'MISC';
      CE_AUTO_BANK_MATCH.trx_status            := 'REMITTED';
      CE_AUTO_BANK_MATCH.trx_cleared_amount    := 0;
      CE_AUTO_BANK_MATCH.trx_currency_code     := NVL(CE_AUTO_BANK_MATCH.csl_currency_code,
                                                      CE_AUTO_BANK_MATCH.aba_bank_currency);
      IF (trx_validation(no_of_currencies)) THEN
        IF (ce_auto_bank_match.csl_trx_type   = 'MISC_DEBIT') THEN
          CE_AUTO_BANK_MATCH.calc_csl_amount :=     CE_AUTO_BANK_MATCH.calc_csl_amount -
                                                NVL(CE_AUTO_BANK_MATCH.csl_charges_amount,0);
        ELSE
          CE_AUTO_BANK_MATCH.calc_csl_amount :=     CE_AUTO_BANK_MATCH.calc_csl_amount +
                                                NVL(CE_AUTO_BANK_MATCH.csl_charges_amount,0);
        END IF;
        -- bug 2293491
        -- 9095828: Added trx_currency_type <> 'FUNCTIONAL' check
        IF (trx_currency_type <> 'FUNCTIONAL') THEN
          IF ((CE_AUTO_BANK_MATCH.csl_exchange_rate_type IS NULL AND
               CE_AUTO_BANK_MATCH.csl_exchange_rate_date IS NULL AND
               CE_AUTO_BANK_MATCH.csl_exchange_rate IS NULL)
           OR (CE_AUTO_BANK_MATCH.csl_exchange_rate_type <> 'User' AND
               CE_AUTO_BANK_MATCH.csl_exchange_rate IS NULL))
          THEN
            IF (NOT validate_exchange_details) THEN
              cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.trx_validation' );
            END IF;
          END IF;
        END IF; -- 9095828: trx_currency_type <> 'FUNCTIONAL' check

        --
        -- bug# 939160
        -- Verified that exchange information is not null
        --    when creating foreign currency misc receipts
        --
        IF (CE_AUTO_BANK_MATCH.aba_bank_currency <> CE_AUTO_BANK_REC.G_functional_currency AND
            CE_AUTO_BANK_MATCH.csl_create_misc_trx_flag = 'Y' AND
            (   CE_AUTO_BANK_MATCH.csl_exchange_rate_date IS NULL
             OR CE_AUTO_BANK_MATCH.csl_exchange_rate_type IS NULL
             OR CE_AUTO_BANK_MATCH.csl_exchange_rate IS NULL))
        THEN
          CE_RECONCILIATION_ERRORS_PKG.insert_row(
              CE_AUTO_BANK_MATCH.csh_statement_header_id,
              CE_AUTO_BANK_MATCH.csl_statement_line_id,
              'CE_REQUIRED_EXCHANGE_FIELD');
        ELSE
          -- bug# 1190376
          -- Make sure the amount is converted to foreign curr
          -- and the decimal is rounded correctly
          --
          IF (CE_AUTO_BANK_MATCH.csl_exchange_rate IS NULL OR
              CE_AUTO_BANK_MATCH.trx_currency_type = 'BANK')
          THEN
            receipt_amount      := CE_AUTO_BANK_MATCH.calc_csl_amount;
            base_receipt_amount := receipt_amount;
          ELSIF (CE_AUTO_BANK_MATCH.csl_exchange_rate_type <> 'User')
          THEN
            BEGIN
              receipt_amount := gl_currency_api.convert_amount(
                                  CE_AUTO_BANK_REC.G_functional_currency,
                                  CE_AUTO_BANK_MATCH.csl_currency_code,
                                  NVL(CE_AUTO_BANK_MATCH.csl_exchange_rate_date,
                                      CE_AUTO_BANK_MATCH.csl_trx_date),
                                  CE_AUTO_BANK_MATCH.csl_exchange_rate_type,
                                  CE_AUTO_BANK_MATCH.calc_csl_amount);
            EXCEPTION
            WHEN OTHERS THEN
              cep_standard.debug('EXCEPTION: Could not convert amount');
              receipt_amount := NULL;
            END;
            base_receipt_amount := convert_to_base_curr(receipt_amount);
          ELSE -- forigen currency type 'User'
            receipt_amount := CE_AUTO_BANK_MATCH.calc_csl_amount * (1/CE_AUTO_BANK_MATCH.csl_exchange_rate);
            fnd_currency.get_info(CE_AUTO_BANK_MATCH.aba_bank_currency,
                                  PRECISION,
                                  ext_precision,
                                  min_acct_unit);
            receipt_amount      := ROUND(receipt_amount,PRECISION);
            base_receipt_amount := convert_to_base_curr(receipt_amount);
          END IF;
          -- Bug 7655528 Start
          get_receivables_org_id(receivables_trx_org_id);
          CE_AUTO_BANK_MATCH.trx_org_id := receivables_trx_org_id;
          -- Bug 7655528 End
          -- if (CE_AUTO_BANK_MATCH.ar_accounting_method = 'ACCRUAL') then  -- Bug 7655528 Commented The Line
          CE_AUTO_BANK_MATCH.get_vat_tax_id('AUTO_TRX', l_vat_tax_id, l_tax_rate);
          -- end if; -- Bug 7655528 Commented The Line
          /* Bug 3385023 - Start code fix */
          --- Shorten the trx_number for the misc receipts created by the
          --- AutoReconciliation Program.
          IF CE_AUTO_BANK_MATCH.csl_bank_trx_number IS NOT NULL THEN -- for bug 6376250
            l_trx_number := CE_AUTO_BANK_MATCH.csl_bank_trx_number;
          ELSE
            l_trx_number := CE_AUTO_BANK_MATCH.csh_statement_number||'/'|| CE_AUTO_BANK_MATCH.csl_line_number;
          END IF;
          IF LENGTH(l_trx_number) > 30 THEN
            l_trx_number := substrb(l_trx_number, LENGTH(l_trx_number)-25, LENGTH(l_trx_number));
          END IF;
          /* Bug 3385023 - End code fix */
          IF NOT(VALIDATE_PAYMENT_METHOD) THEN
            CE_RECONCILIATION_ERRORS_PKG.insert_row(CE_AUTO_BANK_MATCH.csh_statement_header_id,
                                                    CE_AUTO_BANK_MATCH.csl_statement_line_id,
                                                    'CE_PAYMENT_METHOD');
          ELSE

            --9021558: Check creation_status
            cep_standard.debug('9021558: Checking creation_status');
            SELECT creation_status
              INTO l_creation_status
              FROM ce_receipt_methods_v
             WHERE receipt_method_id = CE_AUTO_BANK_MATCH.csl_receipt_method_id;
            cep_standard.debug('9021558: creation_status='||l_creation_status);

            -- 9021558: Don't create receipt if status is CONFIRMED
            IF (l_creation_status = 'CONFIRMED') THEN
              CE_RECONCILIATION_ERRORS_PKG.insert_row(CE_AUTO_BANK_MATCH.csh_statement_header_id,
                                                      CE_AUTO_BANK_MATCH.csl_statement_line_id,
                                                      'CE_ABR_BAD_RM');
              cep_standard.debug('9021558: CE_AUTO_BANK_MATCH.trx_status='||
                                  NVL(CE_AUTO_BANK_MATCH.trx_status,'X'));

            ELSE -- 9021558: receipt can be created
              cep_standard.debug('CE_AUTO_BANK_MATCH.csl_receivables_trx_id= '
                               || CE_AUTO_BANK_MATCH.csl_receivables_trx_id);
              -- bug 5185358  not able to create misc receipt
              -- get_receivables_org_id(receivables_trx_org_id);  -- Bug 7655528 Commented The Line
              -- CE_AUTO_BANK_MATCH.trx_org_id := receivables_trx_org_id; -- Bug 7655528 Commented The Line
              cep_standard.debug('receivables_trx_org_id= '|| receivables_trx_org_id);
              set_single_org(receivables_trx_org_id);
              SELECT mo_global.GET_CURRENT_ORG_ID
                INTO current_org_id
                FROM dual;

              cep_standard.debug('current_org_id =' ||current_org_id );
              cep_standard.debug('create_misc_trx: >> CE_AUTO_BANK_CLEAR.misc_receipt');
              CE_AUTO_BANK_CLEAR.misc_receipt(
                  X_passin_mode => 'AUTO_TRX',
                  X_trx_number => l_trx_number,
                  X_doc_sequence_value => to_number(NULL),
                  X_doc_sequence_id => to_number(NULL),
                  X_gl_date => CE_AUTO_BANK_REC.G_gl_date,
                  X_value_date => CE_AUTO_BANK_MATCH.csl_effective_date,
                  X_trx_date => CE_AUTO_BANK_MATCH.csl_trx_date,
                  X_deposit_date => CE_AUTO_BANK_MATCH.csl_trx_date,
                  X_amount => receipt_amount,
                  X_bank_account_amount => base_receipt_amount,
                  X_set_of_books_id => CE_AUTO_BANK_REC.G_set_of_books_id,
                  X_misc_currency_code => NVL(CE_AUTO_BANK_MATCH.csl_currency_code,
                  CE_AUTO_BANK_MATCH.aba_bank_currency),
                  X_exchange_rate_date => CE_AUTO_BANK_MATCH.csl_exchange_rate_date,
                  X_exchange_rate_type => CE_AUTO_BANK_MATCH.csl_exchange_rate_type,
                  X_exchange_rate => CE_AUTO_BANK_MATCH.csl_exchange_rate,
                  X_receipt_method_id => CE_AUTO_BANK_MATCH.csl_receipt_method_id,
                  X_bank_account_id => CE_AUTO_BANK_MATCH.csh_bank_account_id,
                  X_activity_type_id => CE_AUTO_BANK_MATCH.csl_receivables_trx_id,
                  X_comments => 'Created by Auto Bank Rec',
                  X_tax_id => l_vat_tax_id,
                  X_tax_rate => l_tax_rate,
                  X_paid_from => NULL,
                  X_reference_type => NULL,
                  X_reference_id => NULL,
                  X_clear_currency_code => NULL,
                  X_statement_line_id =>
                  X_statement_line_id,
                  X_module_name => 'CE_AUTO_BANK_REC',
                  X_cr_vat_tax_id => CE_AUTO_BANK_REC.G_cr_vat_tax_code,
                  X_dr_vat_tax_id => CE_AUTO_BANK_REC.G_dr_vat_tax_code,
                  trx_currency_type => CE_AUTO_BANK_MATCH.trx_currency_type,
                  X_cr_id => CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
                  X_effective_date => CE_AUTO_BANK_MATCH.csl_effective_date,
                  X_org_id => NVL(CE_AUTO_BANK_MATCH.trx_org_id, CE_AUTO_BANK_REC.G_org_id)
              );
              cep_standard.debug('end create_misc_trx: >> CE_AUTO_BANK_CLEAR.misc_receipt');
              CE_AUTO_BANK_MATCH.csl_match_found := 'FULL';
            END IF; --9021558: check creation_status
          END IF; -- validate payment method
        END IF; -- if not creating foreign misc receipts with null exchange info
      ELSE
        CE_AUTO_BANK_MATCH.csl_match_found := 'NONE';
      END IF; -- valid trx
      -- bug# 1190376
      CE_AUTO_BANK_MATCH.trx_amount             := base_receipt_amount;
      CE_AUTO_BANK_MATCH.trx_curr_amount        := receipt_amount;
      CE_AUTO_BANK_MATCH.trx_exchange_rate_date := CE_AUTO_BANK_MATCH.csl_exchange_rate_date;
      CE_AUTO_BANK_MATCH.trx_exchange_rate_type := CE_AUTO_BANK_MATCH.csl_exchange_rate_type;
      CE_AUTO_BANK_MATCH.trx_exchange_rate      := CE_AUTO_BANK_MATCH.csl_exchange_rate;
    END IF; -- FOREIGN CURRENCY check
  ELSE      -- create flag = 'N'
    CE_AUTO_BANK_MATCH.csl_match_found := 'NONE';
  END IF; -- If create-misc-flag = 'Y'
  cep_standard.debug('<<CE_AUTO_BANK_MATCH.create_misc_trx');
EXCEPTION
WHEN NO_DATA_FOUND THEN
  cep_standard.debug('CE_AUTO_BANK_MATCH.create_misc_trx no_data_found');
  RAISE NO_DATA_FOUND;
WHEN OTHERS THEN
  cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.create_misc_trx' );
  RAISE;
END create_misc_trx;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	trx_validation							|
|									|
|  DESCRIPTION								|
|	After a match has been found, we need to validate the matching  |
|	Trx. Things that are validated are:				|
|	1. Exchange rate for foreign (BANK,FOREIGN) trxs		|
|	2. For Foreign batches, all the trxs in a batch must be of same |
|	   (batch) currency						|
|	3. Tolerances							|
|	4. For batches with toleranced differences we need to validate  |
|	   payment method						|
|	5. GL Date (open or future enterable in AP/AR)			|
|	6. Future Dated Payment	- is not status 'ISSUED'(bug# 868977)	|
|	7. The cleared GL date cannot be earlier than the original      |
|          GL date of the receipt.	-bug 1941362                    |
|	8. The cleared_date cannot be earlier than the original GL date |
|	   of the receipts		-bug 1941362			|
|									|
|  CALLED BY								|
|	match_line							|
 --------------------------------------------------------------------- */
FUNCTION trx_validation(no_of_currencies	NUMBER) RETURN BOOLEAN IS
  valid_trx		BOOLEAN;
  comp_csl_amount	NUMBER;
  base_csl_amount	NUMBER;
  base_tolerance_amount	NUMBER;
  valid_trx_temp	varchar2(10);

BEGIN
  cep_standard.debug('   ++++++++++++++ trx_validation ++++++++++++++ ');
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.trx_validation');
  valid_trx := TRUE;
  cep_standard.debug('CE_AUTO_BANK_MATCH.csl_match_type '||CE_AUTO_BANK_MATCH.csl_match_type ||
		     ', CE_AUTO_BANK_MATCH.csl_clearing_trx_type ' ||CE_AUTO_BANK_MATCH.csl_clearing_trx_type );

  -- 7571492: Added 'PGROUP'
  IF (CE_AUTO_BANK_MATCH.csl_match_type IN
      ('PAYMENT','MISC','CASH','PBATCH','RBATCH', 'NSF', 'RECEIPT','PGROUP')) THEN
    IF (CE_AUTO_BANK_MATCH.csl_match_type IN ('PBATCH','RBATCH','PGROUP')) THEN
      IF (no_of_currencies > 0) THEN
	valid_trx := FALSE;
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	   CE_AUTO_BANK_MATCH.csh_statement_header_id,
	   CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_PBATCH_CURRENCY');
      END IF;
    END IF;
    --
    -- Validate the transaction currency for foreign transactions
    --
    IF (CE_AUTO_BANK_MATCH.trx_currency_type IN ('BANK','FOREIGN')) THEN
      IF (NOT validate_exchange_details) THEN
    cep_standard.debug('not validate_exchange_details' );
	valid_trx := FALSE;
      END IF;
    END IF;
    IF valid_trx THEN
	valid_trx_temp := 'TRUE';
    ELSE
	valid_trx_temp := 'FALSE';
    END IF;
    cep_standard.debug('valid_trx_temp  validate_exchange_details validate trx cur for FX trx ' ||valid_trx_temp);
    cep_standard.debug('DEBUG - trx_currency_type = ' || trx_currency_type);
    -------------------------------------------------------------------------
    --
    -- We calculate the tolerance here since here is where we need that
    -- for the first time
    --
    calc_actual_tolerance;
    cep_standard.debug('DEBUG#6.3- tolerance_amount = ' || tolerance_amount);

    -------------------------------------------------------------------------
    --
    -- Validate the transaction amount
    --
    IF (CE_AUTO_BANK_MATCH.csl_match_correction_type = 'REVERSAL') THEN
      CE_AUTO_BANK_MATCH.csl_charges_amount := NULL;
    ELSIF (CE_AUTO_BANK_MATCH.csl_match_correction_type = 'ADJUSTMENT') THEN
      if ((CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_DEBIT' AND
	   CE_AUTO_BANK_MATCH.csl_match_type IN ('CASH', 'MISC')) OR
	  (CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_CREDIT' AND
	   CE_AUTO_BANK_MATCH.csl_match_type = 'PAYMENT')) then
	comp_csl_amount := - CE_AUTO_BANK_MATCH.corr_csl_amount;
      else
	comp_csl_amount := CE_AUTO_BANK_MATCH.corr_csl_amount;
      end if;

      cep_standard.debug('comp_csl_amount: '||comp_csl_amount);
      cep_standard.debug('trx_amount: '||trx_amount);
      if CE_AUTO_BANK_MATCH.trx_amount
	NOT BETWEEN (comp_csl_amount
		    - CE_AUTO_BANK_MATCH.tolerance_amount)
	AND (comp_csl_amount
		    + CE_AUTO_BANK_MATCH.tolerance_amount) then
	valid_trx := FALSE;
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	   CE_AUTO_BANK_MATCH.csh_statement_header_id,
	   CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_PMT_AMOUNT');
      end if;
    ELSIF (CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'OI' AND
        CE_AUTO_BANK_REC.G_open_interface_matching_code = 'D') THEN
        -- do not perform the following check for open-interface transactions
        -- when matched by Date and Amount
        null;
    -- 7581995 : Statement line amount is always in bank-account currency
    ELSIF (
         CE_AUTO_BANK_MATCH.trx_amount
            NOT BETWEEN (CE_AUTO_BANK_MATCH.calc_csl_amount-CE_AUTO_BANK_MATCH.tolerance_amount)
                    AND (CE_AUTO_BANK_MATCH.calc_csl_amount+CE_AUTO_BANK_MATCH.tolerance_amount)
    ) THEN

        valid_trx := FALSE;
        CE_RECONCILIATION_ERRORS_PKG.insert_row(
            CE_AUTO_BANK_MATCH.csh_statement_header_id,
            CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_PMT_AMOUNT');
    --
    -- Validate the charges_amount
    --
    ELSIF (abs(CE_AUTO_BANK_MATCH.csl_charges_amount) > CE_AUTO_BANK_MATCH.tolerance_amount) THEN
        CE_RECONCILIATION_ERRORS_PKG.insert_row(
            CE_AUTO_BANK_MATCH.csh_statement_header_id,
            CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_CHARGES_AMOUNT');
        valid_trx:= FALSE;
    END IF;
    IF valid_trx THEN
	valid_trx_temp := 'TRUE';
    ELSE
	valid_trx_temp := 'FALSE';
    END IF;

    cep_standard.debug('valid_trx_temp validate charge amount ' ||valid_trx_temp);

    --
    -- If trx_currency_type is BANK, check that there are no gross
    -- discrepancies in foreign exchange rates provided
    --
    IF (CE_AUTO_BANK_MATCH.trx_currency_type = 'BANK' AND
	CE_AUTO_BANK_MATCH.csl_match_type NOT IN ('CMISC')) THEN
      base_tolerance_amount 	:=
	  convert_to_base_curr(CE_AUTO_BANK_MATCH.tolerance_amount);
      base_csl_amount		:=
	  convert_to_base_curr(CE_AUTO_BANK_MATCH.calc_csl_amount);

      cep_standard.debug('calc_csl_amount: '||calc_csl_amount);
      cep_standard.debug('trx_base_amount: '||trx_base_amount);
      cep_standard.debug('base_csl_amount: '||base_csl_amount);
      cep_standard.debug('base_tolerance_amount: '||base_tolerance_amount);

      IF (CE_AUTO_BANK_MATCH.trx_base_amount
	  NOT BETWEEN (base_csl_amount - base_tolerance_amount)
		 AND (base_csl_amount + base_tolerance_amount)) THEN
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	   CE_AUTO_BANK_MATCH.csh_statement_header_id,
	   CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_XCH_AMOUNT');
	valid_trx := FALSE;
      END IF;
    END IF;

  IF valid_trx THEN
	valid_trx_temp := 'TRUE';
  ELSE
	valid_trx_temp := 'FALSE';
  END IF;
  cep_standard.debug('valid_trx_temp  transaction amount ' ||valid_trx_temp);

    cep_standard.debug('DEBUG#6.5- calc_csl_amount = ' || calc_csl_amount);
    --
    -- Remittance batches with amount differences
    -- try to create misc receipts
    -- we need to validate the payment method
    --
    IF (CE_AUTO_BANK_MATCH.trx_amount <> CE_AUTO_BANK_MATCH.calc_csl_amount AND
	CE_AUTO_BANK_MATCH.csl_match_type = 'RBATCH') THEN
      IF NOT (validate_payment_method) THEN
	valid_trx := FALSE;
	CE_RECONCILIATION_ERRORS_PKG.insert_row(CE_AUTO_BANK_MATCH.csh_statement_header_id,
	   CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_PAYMENT_METHOD');
      END IF;
    END IF;

    --
    -- bug 868977
    -- Make sure the Future Dated Payment has already Matured
    -- with status 'NEGOTIABLE' and not 'ISSUED'
    --
    IF (CE_AUTO_BANK_MATCH.trx_status = 'ISSUED') THEN
      valid_trx := FALSE;
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	  CE_AUTO_BANK_MATCH.csh_statement_header_id,
	  CE_AUTO_BANK_MATCH.csl_statement_line_id,
	  'CE_CANNOT_RECONCILE_FD_PAYMENT');
    END IF;

  ELSIF (CE_AUTO_BANK_MATCH.csl_match_type IN  ('JE_LINE', 'PAY_LINE', 'PAY_EFT')) THEN
    --
    -- JE_LINE and PAY_LINE validation:
    --
    IF (CE_AUTO_BANK_MATCH.trx_amount <>CE_AUTO_BANK_MATCH.calc_csl_amount) THEN
      valid_trx := FALSE;
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	  CE_AUTO_BANK_MATCH.csh_statement_header_id,
	  CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_PMT_AMOUNT');
    END IF;
  END IF;

  IF valid_trx THEN
	valid_trx_temp := 'TRUE';
  ELSE
	valid_trx_temp := 'FALSE';
  END IF;
  cep_standard.debug('valid_trx_temp batch ' ||valid_trx_temp);
 -------------------------------------------------------------------------------
  --
  -- Validate GL date #5
  --
  -- 7571492 : Added PGROUP for csl_match_type
  IF (CE_AUTO_BANK_MATCH.csl_match_type IN
      ('PAYMENT','CASH','MISC','PBATCH','RBATCH','CMISC','RECEIPT','PGROUP') --bug 4435028
      AND NVL(CE_AUTO_BANK_MATCH.csl_reconcile_flag, 'X') <> 'OI' ) THEN
    -- Bug #8287134 Start
	IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type = 'CASHFLOW') THEN
		IF(NOT(CE_AUTO_BANK_REC.find_gl_period(CE_AUTO_BANK_REC.G_gl_date, 101))) THEN
		  cep_standard.debug('Exception CE_INVALID_GL_PERIOD raised For Cashflow......................');
		  valid_trx:=FALSE;
		  CE_RECONCILIATION_ERRORS_PKG.insert_row(
		  CE_AUTO_BANK_MATCH.csh_statement_header_id,
		  CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_INVALID_GL_PERIOD');
		END IF;
    -- Bug #8287134 End
	-- 7571492 : Added PGROUP for csl_match_type
    ELSIF (CE_AUTO_BANK_MATCH.csl_match_type IN ('PBATCH','PAYMENT','PGROUP')) THEN
      IF(NOT(CE_AUTO_BANK_REC.find_gl_period(CE_AUTO_BANK_REC.G_gl_date, 200))) THEN
	valid_trx:=FALSE;
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	    CE_AUTO_BANK_MATCH.csh_statement_header_id,
	    CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_INVALID_AP_PERIOD');
      END IF;
      -- bug 1196994
      -- 7571492 : Added PGROUP for csl_match_type
      IF (CE_AUTO_BANK_MATCH.csl_match_type in ('PAYMENT', 'PBATCH','PGROUP')
	  and (to_char(CE_AUTO_BANK_MATCH.trx_date,'YYYY/MM/DD') >
	  to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'))) THEN
	CE_AUTO_BANK_MATCH.trx_clr_flag := 'Y';
      END IF;
    ELSIF (NOT(CE_AUTO_BANK_REC.find_gl_period(CE_AUTO_BANK_REC.G_gl_date, 222))) THEN
      valid_trx:= FALSE;
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	  CE_AUTO_BANK_MATCH.csh_statement_header_id,
	  CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_INVALID_AR_PERIOD');
    END IF;
  END IF;
  IF valid_trx THEN
	valid_trx_temp := 'TRUE';
  ELSE
	valid_trx_temp := 'FALSE';
  END IF;
  cep_standard.debug('valid_trx_temp gl date ' ||valid_trx_temp);
 -------------------------------------------------------------------------------

  --
  --	7. The cleared GL date cannot be earlier than the original
  --          GL date of the receipt.	-bug 1941362
  --
  --
  -- cep_standard.debug('7 Before** to_date( CE_AUTO_BANK_REC.G_gl_date  = ' || CE_AUTO_BANK_REC.G_gl_date);
  -- cep_standard.debug('7 Before** to_date( CE_AUTO_BANK_REC.G_gl_date_original  = ' || CE_AUTO_BANK_REC.G_gl_date_original);
  -- cep_standard.debug('7 Before** to_date( CE_AUTO_BANK_MATCH.trx_gl_date  = ' || CE_AUTO_BANK_MATCH.trx_gl_date);


  IF ((CE_AUTO_BANK_MATCH.csl_match_type =  'CASH' or CE_AUTO_BANK_MATCH.csl_clearing_trx_type = 'CASHFLOW'  ) AND
       (to_char(CE_AUTO_BANK_REC.G_gl_date,'YYYY/MM/DD') < to_char(CE_AUTO_BANK_MATCH.trx_gl_date,'YYYY/MM/DD'))) THEN
     CE_AUTO_BANK_REC.G_gl_date := CE_AUTO_BANK_MATCH.trx_gl_date;
  END IF;

  -- cep_standard.debug('7 After** to_date(CE_AUTO_BANK_REC.G_gl_date  = ' || CE_AUTO_BANK_REC.G_gl_date);

  --
  --	8. The cleared_date cannot be earlier than the original GL date
  --	   of the receipts		-bug 1941362
  --

  -- cep_standard.debug('8 Before** to_date( CE_AUTO_BANK_MATCH.csl_trx_date  = ' || CE_AUTO_BANK_MATCH.csl_trx_date);
  -- cep_standard.debug('8 Before** to_date( CE_AUTO_BANK_REC.G_gl_date  = ' || CE_AUTO_BANK_REC.G_gl_date);
  -- cep_standard.debug('8 Before** to_date( CE_AUTO_BANK_MATCH.trx_date  = ' || CE_AUTO_BANK_MATCH.trx_date);

  IF ((CE_AUTO_BANK_MATCH.csl_match_type  = 'CASH' or CE_AUTO_BANK_MATCH.csl_clearing_trx_type = 'CASHFLOW' ) AND
        (to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD') < to_char(CE_AUTO_BANK_MATCH.trx_gl_date,'YYYY/MM/DD'))) THEN
       CE_AUTO_BANK_MATCH.csl_trx_date := CE_AUTO_BANK_MATCH.trx_gl_date;
  END IF;

  -- cep_standard.debug('8 After** to_date(CE_AUTO_BANK_MATCH.csl_trx_date  = ' || CE_AUTO_BANK_MATCH.csl_trx_date);
  -- cep_standard.debug('8 After** to_date(CE_AUTO_BANK_MATCH.trx_gl_date  = ' || CE_AUTO_BANK_MATCH.trx_gl_date);

  IF valid_trx THEN
	valid_trx_temp := 'TRUE';
  ELSE
	valid_trx_temp := 'FALSE';
  END IF;
  cep_standard.debug('valid_trx_temp 7 8 ' ||valid_trx_temp);

  --
  -- Lock the transaction
  --

 cep_standard.debug('trx_validation - call CE_AUTO_BANK_MATCH.lock_transaction');
 cep_standard.debug('CE_AUTO_BANK_MATCH.csl_match_type='||CE_AUTO_BANK_MATCH.csl_match_type||
			', CE_AUTO_BANK_MATCH.csl_clearing_trx_type='||CE_AUTO_BANK_MATCH.csl_clearing_trx_type	);

cep_standard.debug('CE_AUTO_BANK_MATCH.trx_rowid='||CE_AUTO_BANK_MATCH.trx_rowid||
			', CE_AUTO_BANK_MATCH.trx_amount='||CE_AUTO_BANK_MATCH.trx_amount);

  BEGIN
    CE_AUTO_BANK_MATCH.lock_transaction(
		'Y',
		'U',
		CE_AUTO_BANK_MATCH.csl_match_type,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_amount);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	 CE_AUTO_BANK_MATCH.csh_statement_header_id,
	 CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_TRX_RECONCILED');
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	 CE_AUTO_BANK_MATCH.csh_statement_header_id,
	 CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_TRX_BUSY');
    WHEN OTHERS THEN
      RAISE;
  END;

  IF valid_trx THEN
	valid_trx_temp := 'TRUE';
  ELSE
	valid_trx_temp := 'FALSE';
  END IF;
  cep_standard.debug('valid_trx_temp ' ||valid_trx_temp);
  cep_standard.debug('<<CE_AUTO_BANK_MATCH.trx_validation');

  RETURN (valid_trx);
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.trx_validation' );
    RAISE;
END trx_validation;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	trx_match       						|
|									|
|  DESCRIPTION								|
|	Using the statement line trx number, try to find a matching	|
|	check/receipt from CE_<APPL_ID>_TRANSACTIONS_V			|
|									|
|  CALLED BY								|
|	match_line				         		|
 --------------------------------------------------------------------- */
PROCEDURE trx_match(no_of_matches		OUT NOCOPY   NUMBER) IS
  tx_type	  CE_LOOKUPS.lookup_code%TYPE;
  curr		  NUMBER;
  tx_curr	  VARCHAR2(10);
  min_unit	  NUMBER;
  amount_to_match NUMBER;
  bank_charges	  NUMBER;
  stmt_amount	  NUMBER;
  precision	  NUMBER;
  ext_precision	  NUMBER;
  numeric_result_trx_num varchar2(40);
  /* Bug 2925260 */
  funct_curr_precision NUMBER;
  funct_curr_ext_precision NUMBER;
  funct_curr_min_acct_unit NUMBER;
  /* Bug 2925260 */

BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.trx_match');
  no_of_matches := 0;
  -- bug 5122576 - zba trx in xtr
  IF (CE_AUTO_BANK_MATCH.csl_trx_type IN ('DEBIT','STOP','SWEEP_OUT') AND
     ( CE_AUTO_BANK_MATCH.csl_reconcile_flag NOT IN ('PAY', 'PAY_EFT'))) THEN
    tx_type := 'PAYMENT';
  ELSIF (CE_AUTO_BANK_MATCH.csl_trx_type IN ('CREDIT','NSF','REJECTED','SWEEP_IN')) THEN
    tx_type := 'CASH';
  ELSIF (CE_AUTO_BANK_MATCH.csl_trx_type IN ('MISC_CREDIT','MISC_DEBIT')) THEN
    tx_type := 'MISC';
  END IF;
  cep_standard.debug('CE_AUTO_BANK_MATCH.csl_trx_type ' ||CE_AUTO_BANK_MATCH.csl_trx_type);
  cep_standard.debug('tx_type ' ||tx_type);
  cep_standard.debug('CE_AUTO_BANK_MATCH.csl_reconcile_flag ' ||CE_AUTO_BANK_MATCH.csl_reconcile_flag);
/*  cep_standard.debug('CE_AUTO_BANK_MATCH.bau_ar_use_enable_flag ' ||CE_AUTO_BANK_MATCH.bau_ar_use_enable_flag);
  cep_standard.debug('CE_AUTO_BANK_MATCH.bau_ap_use_enable_flag ' ||CE_AUTO_BANK_MATCH.bau_ap_use_enable_flag);
  cep_standard.debug('CE_AUTO_BANK_MATCH.bau_xtr_use_enable_flag ' ||CE_AUTO_BANK_MATCH.bau_xtr_use_enable_flag);
  cep_standard.debug('CE_AUTO_BANK_MATCH.bau_pay_use_enable_flag ' ||CE_AUTO_BANK_MATCH.bau_pay_use_enable_flag);*/
  cep_standard.debug('CE_AUTO_BANK_MATCH.csl_bank_trx_number ' ||CE_AUTO_BANK_MATCH.csl_bank_trx_number);

  IF (CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'CE') THEN
	ce_match(no_of_matches);


  ELSIF ((CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'PAY') AND
	(CE_AUTO_BANK_MATCH.bau_pay_use_enable_flag = 'Y'))    THEN
    curr := 1;
    SELECT 	catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.base_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		'PAY_LINE',
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.clearing_trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		catv.org_id,
		catv.CE_BANK_ACCT_USE_ID,
		catv.seq_id
    INTO        CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
		CE_AUTO_BANK_MATCH.trx_org_id,
 		CE_AUTO_BANK_MATCH.trx_bank_acct_use_id,
		CE_AUTO_BANK_MATCH.gt_seq_id
    --FROM        ce_801_transactions_v catv
    FROM        ce_available_transactions_tmp catv
    WHERE       catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
    AND		catv.bank_account_amount = CE_AUTO_BANK_MATCH.csl_amount
    AND		catv.org_id = nvl(CE_AUTO_BANK_REC.G_org_id, catv.org_id)
    --AND		catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
    AND		catv.trx_number = CE_AUTO_BANK_MATCH.csl_bank_trx_number
    AND		catv.application_id = 801
    AND		NVL(catv.reconciled_status_flag, 'N') = 'N';

  ELSIF (CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'JE') THEN

    curr := 2;
    SELECT 	catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.base_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		'JE_LINE',
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.clearing_trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		catv.seq_id
    INTO        CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
		CE_AUTO_BANK_MATCH.gt_seq_id
    --FROM        ce_101_transactions_v catv
    FROM    	ce_available_transactions_tmp  catv
    WHERE       catv.trx_type = tx_type
    AND         catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
    AND         catv.trx_number = CE_AUTO_BANK_MATCH.csl_bank_trx_number
    AND		catv.application_id = 101
    AND		NVL(catv.reconciled_status_flag, 'N') = 'N';

  ELSIF (CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'OI') THEN

  cep_standard.debug('CE_AUTO_BANK_MATCH.bau_xtr_use_enable_flag ' ||CE_AUTO_BANK_MATCH.bau_xtr_use_enable_flag);

    curr := 3;

    if (CE_AUTO_BANK_REC.G_open_interface_matching_code = 'T') then
      IF ((CE_AUTO_BANK_REC.G_legal_entity_id is not null) or
          (CE_AUTO_BANK_MATCH.bau_xtr_use_enable_flag = 'Y'))  THEN

	  cep_standard.debug('use ce_185_transactions_v ' );

        SELECT    catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.base_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		catv.trx_type,
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.clearing_trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		catv.legal_entity_id,
		catv.CE_BANK_ACCT_USE_ID,
		catv.seq_id
        INTO      CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
		CE_AUTO_BANK_MATCH.trx_legal_entity_id,
 		CE_AUTO_BANK_MATCH.trx_bank_acct_use_id,
		CE_AUTO_BANK_MATCH.gt_seq_id
        --FROM      ce_185_transactions_v catv
        FROM      ce_available_transactions_tmp catv
        WHERE     catv.trx_type = tx_type
        AND       catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
		--8978548: changed the NVL clause to use catv.legal_enity_id if null
        AND	catv.legal_entity_id = nvl(CE_AUTO_BANK_REC.G_legal_entity_id,catv.legal_entity_id)
        --AND	catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
        AND       catv.trx_number = CE_AUTO_BANK_MATCH.csl_bank_trx_number
        AND	catv.application_id = 185
        AND     NVL(catv.reconciled_status_flag, 'N') = 'N';
      ELSE -- no LE_ID or not XTR acct
	cep_standard.debug('use ce_999_transactions_v ' );

        SELECT    catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.base_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		catv.trx_type,
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.clearing_trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		catv.legal_entity_id,
		catv.seq_id
        INTO      CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
		CE_AUTO_BANK_MATCH.trx_legal_entity_id,
		CE_AUTO_BANK_MATCH.gt_seq_id
        --FROM      ce_999_transactions_v catv
        FROM      ce_available_transactions_tmp catv
        WHERE     catv.trx_type = tx_type
        AND       catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
        --AND	catv.legal_entity_id = nvl(CE_AUTO_BANK_REC.G_legal_entity_id,CE_AUTO_BANK_REC.G_legal_entity_id)
        --AND	catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
        AND       catv.trx_number = CE_AUTO_BANK_MATCH.csl_bank_trx_number
        AND	catv.application_id = 999
 	AND	NVL(catv.reconciled_status_flag, 'N') = 'N';

      END IF;
    else  -- match by DATE and AMOUNT

     cep_standard.debug('match by DATE and AMOUNT ' );
     -- bug 5122576 issue with zba trx in xtr
     --if (CE_AUTO_BANK_MATCH.csl_trx_type = 'CREDIT') then
     if (CE_AUTO_BANK_MATCH.csl_trx_type in ('SWEEP_IN', 'CREDIT')) then
	bank_charges := -nvl(CE_AUTO_BANK_MATCH.csl_charges_amount,0);
      else
	bank_charges := nvl(CE_AUTO_BANK_MATCH.csl_charges_amount,0);
      end if;
      stmt_amount := CE_AUTO_BANK_MATCH.csl_amount - bank_charges;
      tx_curr := nvl(CE_AUTO_BANK_MATCH.csl_currency_code,
                        CE_AUTO_BANK_MATCH.aba_bank_currency);
      fnd_currency.get_info(tx_curr, precision, ext_precision,
			min_unit);

      if (tx_curr = CE_AUTO_BANK_MATCH.aba_bank_currency) then

        /* bank currency match */
        amount_to_match := round(stmt_amount, precision);

   cep_standard.debug('tx_type='||tx_type ||', amount_to_match =' || amount_to_match);

        match_oi_trx(tx_type, tx_curr, amount_to_match, precision,
                no_of_matches);

      else

        /* foreign currency match */
        if (CE_AUTO_BANK_MATCH.csl_original_amount is not null) then
          if (nvl(CE_AUTO_BANK_MATCH.csl_charges_amount,0) <> 0) then
            if (nvl(CE_AUTO_BANK_MATCH.csl_exchange_rate,0) = 0) then
              no_of_matches := 0;
	      IF (CE_AUTO_BANK_MATCH.csl_currency_code <>
		  CE_AUTO_BANK_MATCH.aba_bank_currency AND
		  CE_AUTO_BANK_MATCH.csl_exchange_rate IS NULL) THEN
		CE_RECONCILIATION_ERRORS_PKG.insert_row(
		    CE_AUTO_BANK_MATCH.csh_statement_header_id,
		    CE_AUTO_BANK_MATCH.csl_statement_line_id,
		    'CE_REQUIRED_EXCHANGE_FIELD');
	      END IF;
	      RAISE NO_DATA_FOUND;
            else
              amount_to_match := round(stmt_amount
		  / CE_AUTO_BANK_MATCH.csl_exchange_rate, precision);

   cep_standard.debug('tx_type='||tx_type ||', amount_to_match =' || amount_to_match);

              match_oi_trx(tx_type, tx_curr, amount_to_match, precision,
		  no_of_matches);
            end if;
          else
            amount_to_match := round(CE_AUTO_BANK_MATCH.csl_original_amount,
		precision);

   cep_standard.debug('tx_type='||tx_type ||', amount_to_match =' || amount_to_match);

            match_oi_trx(tx_type, tx_curr, amount_to_match, precision,
		no_of_matches);
          end if;
        else
          if (nvl(CE_AUTO_BANK_MATCH.csl_exchange_rate,0) = 0) then
	    no_of_matches := 0;
	    IF (CE_AUTO_BANK_MATCH.csl_currency_code <>
		CE_AUTO_BANK_MATCH.aba_bank_currency AND
		CE_AUTO_BANK_MATCH.csl_exchange_rate IS NULL) THEN
		CE_RECONCILIATION_ERRORS_PKG.insert_row(
		    CE_AUTO_BANK_MATCH.csh_statement_header_id,
		    CE_AUTO_BANK_MATCH.csl_statement_line_id,
		    'CE_REQUIRED_EXCHANGE_FIELD');
	    END IF;
	    RAISE NO_DATA_FOUND;
          else
            amount_to_match := round(stmt_amount
		/ CE_AUTO_BANK_MATCH.csl_exchange_rate, precision);

   cep_standard.debug('tx_type='||tx_type ||', amount_to_match =' || amount_to_match);

            match_oi_trx(tx_type, tx_curr, amount_to_match, precision,
		no_of_matches);
          end if;
        end if;
      end if;

    end if;

  ELSIF ((CE_AUTO_BANK_MATCH.csl_trx_type IN ('NSF','REJECTED')) AND
	 (CE_AUTO_BANK_MATCH.bau_ar_use_enable_flag = 'Y'))  THEN

    curr := 4;
    SELECT 	catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.base_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		catv.trx_type,
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.trx_type,
		to_number(NULL),
		to_date(NULL),
		NULL,
		catv.customer_id,
		'N',  -- reversed receipt flag
		catv.org_id,
		catv.CE_BANK_ACCT_USE_ID,
		-1
    INTO	CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
		CE_AUTO_BANK_MATCH.trx_customer_id,
		CE_AUTO_BANK_MATCH.reversed_receipt_flag,
 		CE_AUTO_BANK_MATCH.trx_org_id,
 		CE_AUTO_BANK_MATCH.trx_bank_acct_use_id,
		CE_AUTO_BANK_MATCH.gt_seq_id
   FROM  	ce_222_reversal_v catv
    WHERE	DECODE(tx_type,'CASH',
				DECODE(catv.trx_type,'MISC',
						     'CASH',
						     catv.trx_type),
				catv.trx_type) = tx_type
    AND		catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
    AND		catv.org_id = nvl(CE_AUTO_BANK_REC.G_org_id, catv.org_id)
    --AND		catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
    AND		catv.trx_number = CE_AUTO_BANK_MATCH.csl_bank_trx_number
    AND		catv.status = decode(CE_AUTO_BANK_REC.G_nsf_handling,
				'REVERSE',catv.status,
				'DM REVERSE',catv.status, 'REVERSED')
    UNION
    SELECT      catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.base_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		catv.trx_type,
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.trx_type,
		to_number(NULL),
		to_date(NULL),
		NULL,
		catv.customer_id,
		NVL(catv.reversed_receipt_flag, 'N'),
		catv.org_id,
		catv.CE_BANK_ACCT_USE_ID,
		catv.seq_id
    --FROM        ce_222_transactions_v catv
    FROM        ce_available_transactions_tmp catv
    WHERE       DECODE(tx_type,'CASH',
				DECODE(catv.trx_type,'MISC',
						     'CASH',
						     catv.trx_type),
				catv.trx_type) = tx_type
    AND         catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
    AND		catv.org_id = nvl(CE_AUTO_BANK_REC.G_org_id, catv.org_id)
    --AND		catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
    AND         catv.trx_number = CE_AUTO_BANK_MATCH.csl_bank_trx_number
    AND		catv.status = 'REVERSED'
    AND		catv.application_id = 222
    AND		NVL(catv.reconciled_status_flag, 'N') = 'N';

  ELSIF ((tx_type IN ('CASH','MISC')) AND
	 (CE_AUTO_BANK_MATCH.bau_ar_use_enable_flag = 'Y'))  THEN
  cep_standard.debug('curr 5 ' );

    curr := 5;
    SELECT	catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.base_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		catv.trx_type,
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.clearing_trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		NVL(catv.reversed_receipt_flag, 'N'),
		catv.gl_date,
		catv.org_id,
		catv.CE_BANK_ACCT_USE_ID,
		catv.seq_id
    INTO	CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
		CE_AUTO_BANK_MATCH.reversed_receipt_flag,
		CE_AUTO_BANK_MATCH.trx_gl_date ,
 		CE_AUTO_BANK_MATCH.trx_org_id,
 		CE_AUTO_BANK_MATCH.trx_bank_acct_use_id,
		CE_AUTO_BANK_MATCH.gt_seq_id
   --FROM  	ce_222_transactions_v catv
    FROM        ce_available_transactions_tmp catv
    WHERE	DECODE(tx_type,'CASH',
				DECODE(catv.trx_type,'MISC',
						     'CASH',
						     catv.trx_type),
				catv.trx_type) = tx_type
    AND		catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
    AND		catv.org_id = nvl(CE_AUTO_BANK_REC.G_org_id, catv.org_id)
    --AND		catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
    AND		catv.trx_number = CE_AUTO_BANK_MATCH.csl_bank_trx_number
    AND         catv.status <> 'REVERSED'
    AND		catv.application_id = 222
    AND		NVL(catv.reconciled_status_flag, 'N') = 'N';

  ELSIF ((tx_type = 'PAYMENT') AND
	 (CE_AUTO_BANK_MATCH.bau_ap_use_enable_flag = 'Y'))  THEN

    curr := 6;
    numeric_result_trx_num := ce_check_numeric(CE_AUTO_BANK_MATCH.csl_bank_trx_number,
						1,length(CE_AUTO_BANK_MATCH.csl_bank_trx_number));

    if (numeric_result_trx_num = '0') then /* CE_AUTO_BANK_MATCH.csl_bank_trx_number is numeric */
      SELECT	catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.base_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		'PAYMENT', /* catv.trx_type, */
		1,
		catv.trx_currency_type,
		catv.amount,
		'PAYMENT', /* catv.clearing_trx_type, */
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
               	catv.gl_date,
               	catv.cleared_date,
		catv.org_id,
		catv.CE_BANK_ACCT_USE_ID,
		catv.seq_id
      INTO	CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
		CE_AUTO_BANK_MATCH.trx_gl_date,
                CE_AUTO_BANK_MATCH.trx_cleared_date,
 		CE_AUTO_BANK_MATCH.trx_org_id,
 		CE_AUTO_BANK_MATCH.trx_bank_acct_use_id,
		CE_AUTO_BANK_MATCH.gt_seq_id
      --FROM  	ce_200_transactions_v catv
      FROM	ce_available_transactions_tmp  catv
      WHERE	catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
      AND	catv.org_id = nvl(CE_AUTO_BANK_REC.G_org_id, catv.org_id)
      --AND	catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
      AND	catv.check_number =
		to_number(LTRIM(CE_AUTO_BANK_MATCH.csl_bank_trx_number, '0'))
      AND	catv.application_id = 200
      AND       NVL(catv.reconciled_status_flag, 'N') = 'N';
    else /* CE_AUTO_BANK_MATCH.csl_bank_trx_number is alphanumeric */
      SELECT	catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.base_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		'PAYMENT', /* catv.trx_type, */
		1,
		catv.trx_currency_type,
		catv.amount,
		'PAYMENT', /* catv.clearing_trx_type, */
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
               	catv.gl_date,
               	catv.cleared_date,
		catv.org_id,
		catv.CE_BANK_ACCT_USE_ID,
		catv.seq_id
      INTO	CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
		CE_AUTO_BANK_MATCH.trx_gl_date,
                CE_AUTO_BANK_MATCH.trx_cleared_date,
 		CE_AUTO_BANK_MATCH.trx_org_id,
 		CE_AUTO_BANK_MATCH.trx_bank_acct_use_id,
		CE_AUTO_BANK_MATCH.gt_seq_id
      --FROM  	ce_200_transactions_v catv
      FROM	ce_available_transactions_tmp  catv
      WHERE	catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
      --AND	catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
      AND	catv.org_id = nvl(CE_AUTO_BANK_REC.G_org_id,catv.org_id)
      AND	catv.trx_number =
		LTRIM(CE_AUTO_BANK_MATCH.csl_bank_trx_number, '0')
      AND	catv.application_id = 200
      AND	NVL(catv.reconciled_status_flag, 'N') = 'N';

    END IF;
    /* Bug 2925260
       The amount is not rounded in the view. */

    IF ((CE_AUTO_BANK_MATCH.trx_currency_type = 'FOREIGN')
       AND (CE_AUTO_BANK_MATCH.trx_currency_code <>
            CE_AUTO_BANK_REC.G_functional_currency)) THEN
	fnd_currency.get_info(CE_AUTO_BANK_REC.G_functional_currency,
                                funct_curr_precision,
                                funct_curr_ext_precision,
                                funct_curr_min_acct_unit);
        CE_AUTO_BANK_MATCH.trx_amount :=
                        round(CE_AUTO_BANK_MATCH.trx_curr_amount *
                              CE_AUTO_BANK_MATCH.trx_exchange_rate,
                              funct_curr_precision);
    END IF;
    /* Bug 2925260
       End Code Changes */

  END IF;

  IF (CE_AUTO_BANK_MATCH.aba_bank_currency <>
	  CE_AUTO_BANK_REC.G_functional_currency) and
     (CE_AUTO_BANK_MATCH.aba_bank_currency <>
	  CE_AUTO_BANK_MATCH.trx_currency_code) THEN
    cep_standard.debug('Forex account not using the same curr as bk');
    curr := 9;
    RAISE NO_DATA_FOUND;
  END IF;

  cep_standard.debug('<<CE_AUTO_BANK_MATCH.trx_match');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    cep_standard.debug('EXCEPTION: No data found in trx_match');
    if (curr = 7) then
      CE_RECONCILIATION_ERRORS_PKG.insert_row(CE_AUTO_BANK_MATCH.csh_statement_header_id,
                                              CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_BAD_ARL');
    elsif (curr = 8) then
    CE_RECONCILIATION_ERRORS_PKG.insert_row(CE_AUTO_BANK_MATCH.csh_statement_header_id,
                                            CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_BAD_NSF');
    elsif (curr = 9) then
    CE_RECONCILIATION_ERRORS_PKG.insert_row(CE_AUTO_BANK_MATCH.csh_statement_header_id,
                                            CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_NO_FOREIGN_RECON');
    elsif (curr = 4 or curr = 5) then
      IF (CE_AUTO_BANK_MATCH.csl_trx_type in('CREDIT','MISC_CREDIT','MISC_DEBIT')) THEN
        IF (CE_AUTO_BANK_MATCH.trx_status = 'REVERSED') THEN  -- 9092830 removed NVL
          cep_standard.debug('>>receipt with reversed status');
          CE_RECONCILIATION_ERRORS_PKG.insert_row(CE_AUTO_BANK_MATCH.csh_statement_header_id,
                                                  CE_AUTO_BANK_MATCH.csl_statement_line_id,
                                                  'CE_STATEMENT_REVERSAL_NSF');
        ELSIF (CE_AUTO_BANK_MATCH.trx_status) NOT IN -- 9092830 removed NVL
                ('REMITTED', 'CLEARED', 'RISK_ELIMINATED') THEN
          cep_standard.debug('>>receipt with wrong status');
          CE_RECONCILIATION_ERRORS_PKG.insert_row(CE_AUTO_BANK_MATCH.csh_statement_header_id,
          CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_BAD_ARL');
        ELSE
          CE_RECONCILIATION_ERRORS_PKG.insert_row(CE_AUTO_BANK_MATCH.csh_statement_header_id,
                                                  CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_NO_ARL');
        END IF;
      ELSE -- NSF, REJECTED
        IF (NVL(CE_AUTO_BANK_MATCH.trx_status,'X') NOT IN  -- Bug 8310127 Added NVL
                  ('REMITTED', 'CLEARED', 'RISK_ELIMINATED','REVERSED')) THEN
          cep_standard.debug('>>NSF/REJECTED with wrong status');
          CE_RECONCILIATION_ERRORS_PKG.insert_row(CE_AUTO_BANK_MATCH.csh_statement_header_id,
                                                  CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_BAD_NSF');
        END IF;
      END IF;
    elsif (curr = 1) then
    CE_RECONCILIATION_ERRORS_PKG.insert_row(CE_AUTO_BANK_MATCH.csh_statement_header_id,
                                            CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_NO_PAYL');
    elsif (curr = 2) then
    CE_RECONCILIATION_ERRORS_PKG.insert_row(CE_AUTO_BANK_MATCH.csh_statement_header_id,
                                            CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_NO_JEL');
    elsif (curr = 3) then
    CE_RECONCILIATION_ERRORS_PKG.insert_row(CE_AUTO_BANK_MATCH.csh_statement_header_id,
                                            CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_NO_OIL');
    elsif (curr = 6) then
    CE_RECONCILIATION_ERRORS_PKG.insert_row(CE_AUTO_BANK_MATCH.csh_statement_header_id,
                                            CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_NO_APL');
    end if;
    no_of_matches := 0;
  WHEN OTHERS THEN
    IF (SQL%ROWCOUNT >0) THEN
      cep_standard.debug('EXCEPTION: More than one transaction match this receipt' );
      if (CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'JE') then
        CE_RECONCILIATION_ERRORS_PKG.insert_row(
        CE_AUTO_BANK_MATCH.csh_statement_header_id,
        CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_JEL_PARTIAL');
      elsif (CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'OI') then
        CE_RECONCILIATION_ERRORS_PKG.insert_row(
        CE_AUTO_BANK_MATCH.csh_statement_header_id,
        CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_OIL_PARTIAL');
      elsif (CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'PAY') then
        CE_RECONCILIATION_ERRORS_PKG.insert_row(
        CE_AUTO_BANK_MATCH.csh_statement_header_id,
        CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_PAYL_PARTIAL');
      elsif (CE_AUTO_BANK_MATCH.csl_trx_type IN ('DEBIT','STOP')) then
        CE_RECONCILIATION_ERRORS_PKG.insert_row(
        CE_AUTO_BANK_MATCH.csh_statement_header_id,
        CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_APT_PARTIAL');
      else
        CE_RECONCILIATION_ERRORS_PKG.insert_row(
        CE_AUTO_BANK_MATCH.csh_statement_header_id,
        CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_ART_PARTIAL');
      end if;
      no_of_matches:=999;
    ELSE
      cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.trx_match' );
      RAISE;
    END IF;
END trx_match;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       stmtline_match                                                  |
|                                                                       |
|  DESCRIPTION                                                          |
|       Using the statement line trx number, try to find a matching     |
|       statement line from CE_260_TRANSACTIONS_V                       |
|                                                                       |
|  CALLED BY                                                            |
|       match_line                                                      |
 --------------------------------------------------------------------- */
PROCEDURE stmtline_match(no_of_matches            IN OUT NOCOPY   NUMBER) IS
   cursor get_reversal is
	SELECT  catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.base_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		catv.trx_type,
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.clearing_trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		catv.seq_id
	--FROM	ce_260_transactions_v catv
        FROM    ce_available_transactions_tmp catv
	WHERE	catv.trx_id <> CE_AUTO_BANK_MATCH.csl_statement_line_id
	AND	catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
	AND 	nvl(catv.trx_number, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_trx_number, '-99999')
	AND	(nvl(catv.invoice_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_invoice_text,'-99999')
	AND	(nvl(catv.bank_account_text,'-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_account_text,'-99999')
			or nvl(catv.customer_text,'-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_customer_text,'-99999')))
	AND	catv.trx_type in (
			decode(csl_trx_type,
				'MISC_DEBIT', 'CREDIT',
				'DEBIT'),
			decode(csl_trx_type,
				'MISC_DEBIT', 'MISC_CREDIT',
				'MISC_DEBIT'))
	AND	catv.bank_account_amount = CE_AUTO_BANK_MATCH.csl_amount
	AND	to_char(catv.trx_date,'YYYY/MM/DD') <=
		to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
        AND	catv.application_id = 260
        AND   	NVL(catv.reconciled_status_flag, 'N') = 'N';

   cursor get_adjustment(tolerance_amount_ap NUMBER,tolerance_amount_ar NUMBER) is
       SELECT   catv.trx_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.base_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		catv.trx_type,
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		catv.seq_id,
		v.trx_id,
		v.cash_receipt_id,
		v.row_id,
		v.trx_date,
		v.currency_code,
		v.bank_account_amount,
		v.base_amount,
		v.status,
		nvl(v.amount_cleared,0),
		v.trx_type,
		v.trx_currency_type,
		v.amount,
		v.clearing_trx_type,
		v.exchange_rate,
		v.exchange_rate_date,
		v.exchange_rate_type,
               	v.gl_date,
               	v.cleared_date,
		v.org_id,
		v.CE_BANK_ACCT_USE_ID,
		v.seq_id
	--FROM    ce_222_transactions_v v, ce_260_transactions_v catv
        FROM    ce_available_transactions_tmp v, ce_available_transactions_tmp catv
	WHERE	catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
	AND     nvl(catv.trx_number, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_trx_number,'-99999')
	AND	(nvl(catv.invoice_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_invoice_text,'-99999')
			and (nvl(catv.customer_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_customer_text,'-99999')
			or nvl(catv.bank_account_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_account_text,'-99999')))
	AND     catv.trx_number = CE_AUTO_BANK_MATCH.csl_bank_trx_number
	AND     to_char(catv.trx_date,'YYYY/MM/DD') <=
		to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
	AND     catv.trx_id <> CE_AUTO_BANK_MATCH.csl_statement_line_id
	AND	catv.trx_type in ('MISC_DEBIT', 'MISC_CREDIT')
	AND	v.trx_type = 'MISC'
	AND	v.bank_account_id = catv.bank_account_id
        --AND	v.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
        AND	v.org_id = nvl(CE_AUTO_BANK_REC.G_org_id,v.org_id)
	AND    	v.trx_number = nvl(catv.trx_number,v.trx_number)
	AND    	to_char(v.trx_date,'YYYY/MM/DD') <=
		to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
	AND    	v.status in ('REMITTED', 'CLEARED', 'RISK_ELIMINATED')
	AND    	v.bank_account_amount
			between (CE_AUTO_BANK_MATCH.calc_csl_amount +
			  decode(catv.trx_type,
				'MISC_CREDIT', catv.amount,
				- catv.amount)
			  - decode(catv.trx_currency_type,
				'BANK', tolerance_amount_ar,
				CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance))
			and (CE_AUTO_BANK_MATCH.calc_csl_amount +
			  decode(catv.trx_type,
				'MISC_CREDIT', catv.amount,
				- catv.amount)
			  + decode(catv.trx_currency_type,
				'BANK', tolerance_amount_ar,
				CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance))
	AND     v.bank_account_amount
			between ((CE_AUTO_BANK_MATCH.calc_csl_amount +
			  decode(catv.trx_type,
				'MISC_CREDIT', catv.amount,
				- catv.amount))
			  - abs((CE_AUTO_BANK_MATCH.calc_csl_amount +
			  decode(catv.trx_type,
				'MISC_CREDIT', catv.amount,
			  	- catv.amount))
			  * CE_AUTO_BANK_MATCH.ba_ar_percent_tolerance / 100))
			and ((CE_AUTO_BANK_MATCH.calc_csl_amount +
			  decode(catv.trx_type,
				'MISC_CREDIT', catv.amount,
				- catv.amount))
			  + abs((CE_AUTO_BANK_MATCH.calc_csl_amount +
			  decode(catv.trx_type,
				'MISC_CREDIT', catv.amount,
			  	- catv.amount))
			  * CE_AUTO_BANK_MATCH.ba_ar_percent_tolerance / 100))
        AND	v.application_id = 222
        AND	NVL(v.reconciled_status_flag, 'N') = 'N'
        AND	catv.application_id = 260
        AND	NVL(catv.reconciled_status_flag, 'N') = 'N'
	UNION
       SELECT   catv.trx_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.base_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		catv.trx_type,
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		catv.seq_id,
		v.trx_id,
		v.cash_receipt_id,
		v.row_id,
		v.trx_date,
		v.currency_code,
		v.bank_account_amount,
		v.base_amount,
		v.status,
		nvl(v.amount_cleared,0),
		v.trx_type,
		v.trx_currency_type,
		v.amount,
		v.clearing_trx_type,
		v.exchange_rate,
		v.exchange_rate_date,
		v.exchange_rate_type,
                v.gl_date,
                v.cleared_date,
		v.org_id,
		v.CE_BANK_ACCT_USE_ID,
		v.seq_id
       --FROM     ce_222_transactions_v v, ce_260_transactions_v catv
       FROM     ce_available_transactions_tmp v, ce_available_transactions_tmp catv
       WHERE    catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
       AND      nvl(catv.trx_number, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_trx_number,'-99999')
       AND	(nvl(catv.invoice_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_invoice_text,'-99999')
			and (nvl(catv.customer_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_customer_text,'-99999')
			or nvl(catv.bank_account_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_account_text,'-99999')))
       AND      to_char(catv.trx_date,'YYYY/MM/DD') <=
		to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
       AND      catv.trx_id <> CE_AUTO_BANK_MATCH.csl_statement_line_id
       AND      catv.trx_type in ('DEBIT', 'CREDIT')
       AND      v.trx_type = 'CASH'
       AND	v.bank_account_id = catv.bank_account_id
       --AND	v.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
       AND	v.org_id = nvl(CE_AUTO_BANK_REC.G_org_id, v.org_id)
       AND    	v.trx_number = nvl(catv.trx_number,v.trx_number)
       AND    	to_char(v.trx_date,'YYYY/MM/DD') <=
		to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
       AND    	v.status in ('REMITTED', 'CLEARED', 'RISK_ELIMINATED')
       AND      CE_AUTO_BANK_MATCH.calc_csl_amount +
		    decode(catv.trx_type,'DEBIT',-catv.amount, catv.amount) > 0
       AND    	v.bank_account_amount
		between (CE_AUTO_BANK_MATCH.calc_csl_amount +
		  decode(catv.trx_type, 'CREDIT', catv.amount, - catv.amount)
		  - decode(catv.trx_currency_type, 'BANK', tolerance_amount_ar,
			CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance))
		and (CE_AUTO_BANK_MATCH.calc_csl_amount +
		  decode(catv.trx_type, 'CREDIT', catv.amount, - catv.amount)
		  + decode(catv.trx_currency_type, 'BANK', tolerance_amount_ar,
			CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance))
       AND      v.bank_account_amount
		between ((CE_AUTO_BANK_MATCH.calc_csl_amount +
		  decode(catv.trx_type, 'CREDIT', catv.amount, - catv.amount))
		  - abs((CE_AUTO_BANK_MATCH.calc_csl_amount +
		  decode(catv.trx_type, 'CREDIT', catv.amount, - catv.amount))
		  * CE_AUTO_BANK_MATCH.ba_ar_percent_tolerance / 100))
		and ((CE_AUTO_BANK_MATCH.calc_csl_amount +
		  decode(catv.trx_type, 'CREDIT', catv.amount, - catv.amount))
		  + abs((CE_AUTO_BANK_MATCH.calc_csl_amount +
		  decode(catv.trx_type, 'CREDIT', catv.amount, - catv.amount))
		  * CE_AUTO_BANK_MATCH.ba_ar_percent_tolerance/ 100))
       AND	v.application_id = 222
       AND	NVL(v.reconciled_status_flag, 'N') = 'N'
       AND	catv.application_id = 260
       AND     	NVL(catv.reconciled_status_flag, 'N') = 'N'
       UNION
       SELECT   catv.trx_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.base_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		catv.trx_type,
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		catv.seq_id,
		v2.trx_id,
		v2.cash_receipt_id,
		v2.row_id,
		v2.trx_date,
		v2.currency_code,
		v2.bank_account_amount,
		v2.base_amount,
		v2.status,
		nvl(v2.amount_cleared,0),
		'PAYMENT', /* v2.trx_type, */
		v2.trx_currency_type,
		v2.amount,
		'PAYMENT', /* v2.clearing_trx_type, */
		v2.exchange_rate,
		v2.exchange_rate_date,
		v2.exchange_rate_type,
                v2.gl_date,
                v2.cleared_date,
		v2.org_id,
		v2.CE_BANK_ACCT_USE_ID,
		v2.seq_id
       --FROM     ce_200_transactions_v v2, ce_260_transactions_v catv
       FROM  	ce_available_transactions_tmp v2, ce_available_transactions_tmp  catv
       WHERE    catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
       AND      nvl(catv.trx_number, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_trx_number,'-99999')
       AND	(nvl(catv.invoice_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_invoice_text,'-99999')
			and (nvl(catv.customer_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_customer_text,'-99999')
			or nvl(catv.bank_account_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_account_text,'-99999')))
       AND      to_char(catv.trx_date,'YYYY/MM/DD') <=
		to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
       AND      catv.trx_id <> CE_AUTO_BANK_MATCH.csl_statement_line_id
       AND      catv.trx_type in ('DEBIT', 'CREDIT')
       AND	v2.bank_account_id = catv.bank_account_id
       AND	v2.org_id = nvl(CE_AUTO_BANK_REC.G_org_id, v2.org_id)
       --AND	v2.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
       AND    	v2.trx_number = nvl(catv.trx_number,v2.trx_number)
       AND    	to_char(v2.trx_date,'YYYY/MM/DD') <=
		to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
       AND      CE_AUTO_BANK_MATCH.calc_csl_amount +
		decode(catv.trx_type, 'DEBIT', - catv.amount, catv.amount) < 0
       AND      v2.bank_account_amount
		between (- CE_AUTO_BANK_MATCH.calc_csl_amount +
		  decode(catv.trx_type, 'DEBIT', catv.amount, - catv.amount)
		  - decode(catv.trx_currency_type, 'BANK', tolerance_amount_ap,
			CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance))
		and (- CE_AUTO_BANK_MATCH.calc_csl_amount +
		  decode(catv.trx_type, 'DEBIT', catv.amount, - catv.amount)
		  + decode(catv.trx_currency_type, 'BANK', tolerance_amount_ap,
			CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance))
       AND      v2.bank_account_amount
		between ((- CE_AUTO_BANK_MATCH.calc_csl_amount +
		  decode(catv.trx_type, 'DEBIT', catv.amount, - catv.amount))
		  - abs((- CE_AUTO_BANK_MATCH.calc_csl_amount +
		  decode(catv.trx_type, 'DEBIT', catv.amount, - catv.amount))
		  * CE_AUTO_BANK_MATCH.ba_ap_percent_tolerance / 100))
		and ((- CE_AUTO_BANK_MATCH.calc_csl_amount +
		  decode(catv.trx_type, 'DEBIT', catv.amount, - catv.amount))
		  + abs((- CE_AUTO_BANK_MATCH.calc_csl_amount +
		  decode(catv.trx_type, 'DEBIT', catv.amount, - catv.amount))
		  * CE_AUTO_BANK_MATCH.ba_ap_percent_tolerance / 100))
       AND	v2.application_id = 200
       AND	NVL(v2.reconciled_status_flag, 'N') = 'N'
       AND	catv.application_id = 260
       AND	NVL(catv.reconciled_status_flag, 'N') = 'N';

  cursor get_rev_credit is
       SELECT   catv.statement_line_id,
		catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		catv.trx_type,
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.clearing_trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		catv.org_id,
		catv.CE_BANK_ACCT_USE_ID
       FROM     ce_200_reconciled_v catv
       WHERE    catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
       --AND	catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
       AND	catv.org_id = nvl(CE_AUTO_BANK_REC.G_org_id, catv.org_id)
       AND      nvl(catv.trx_number,'-99999')
			= nvl(CE_AUTO_BANK_MATCH.csl_bank_trx_number,'-99999')
       AND      (nvl(catv.invoice_text, '-99999')
			= nvl(CE_AUTO_BANK_MATCH.csl_invoice_text,'-99999')
		and (nvl(catv.customer_text, '-99999')
			= nvl(CE_AUTO_BANK_MATCH.csl_customer_text,'-99999')
		     or
		     nvl(catv.bank_account_text, '-99999')
		= nvl(CE_AUTO_BANK_MATCH.csl_bank_account_text,'-99999')))
       AND      catv.bank_account_amount = CE_AUTO_BANK_MATCH.csl_amount
       AND      to_char(catv.trx_date,'YYYY/MM/DD') <=
		to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
       AND      catv.request_id = nvl(FND_GLOBAL.conc_request_id,-1)
       AND NOT EXISTS
	  (select NULL
	   from   ce_statement_reconcils_all r
	   where  r.statement_line_id = catv.statement_line_id
	   and    r.current_record_flag = 'Y'
	   and    nvl(r.status_flag, 'U') <> 'U'
	   AND    r.reference_type = 'STATEMENT');

  cursor get_rev_debit is
       SELECT   catv.statement_line_id,
		catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		catv.trx_type,
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.clearing_trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		catv.org_id,
		catv.CE_BANK_ACCT_USE_ID
       FROM     ce_222_reconciled_v catv
       WHERE    catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
       --AND	catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
       AND	catv.org_id = nvl(CE_AUTO_BANK_REC.G_org_id,catv.org_id)
       AND      nvl(catv.trx_number,'-99999')
			= nvl(CE_AUTO_BANK_MATCH.csl_bank_trx_number,'-99999')
       AND      (nvl(catv.invoice_text, '-99999')
			= nvl(CE_AUTO_BANK_MATCH.csl_invoice_text,'-99999')
		and (nvl(catv.customer_text, '-99999')
			= nvl(CE_AUTO_BANK_MATCH.csl_customer_text,'-99999')
		     or
		     nvl(catv.bank_account_text, '-99999')
			= nvl(CE_AUTO_BANK_MATCH.csl_bank_account_text,'-99999')))
       AND      catv.bank_account_amount = decode(csl_trx_type,
			'MISC_CREDIT', - CE_AUTO_BANK_MATCH.csl_amount,
			CE_AUTO_BANK_MATCH.csl_amount)
       AND      to_char(catv.trx_date,'YYYY/MM/DD') <=
		to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
       AND      catv.request_id = nvl(FND_GLOBAL.conc_request_id,-1)
       AND NOT EXISTS
	  (select NULL
	   from   ce_statement_reconcils_all r
	   where  r.statement_line_id = catv.statement_line_id
	   and    r.current_record_flag = 'Y'
	   and    nvl(r.status_flag, 'U') <> 'U'
	   AND    r.reference_type = 'STATEMENT');

  cursor get_recon_adj_misc(tolerance_amount NUMBER) is
       SELECT   sl.statement_line_id,
		'RECEIPT',
		sl.trx_type,
		sl.rowid,
		sl.amount,
		catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		catv.trx_type,
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.clearing_trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		catv.org_id,
		catv.CE_BANK_ACCT_USE_ID
       FROM     ce_222_reconciled_v catv, ce_statement_lines sl
       WHERE    nvl(sl.bank_trx_number,'-9999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_trx_number, '-9999')
       AND      (nvl(sl.invoice_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_invoice_text, '-99999')
			and (nvl(sl.bank_account_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_account_text,'-99999')
			or nvl(sl.customer_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_customer_text,'-99999')))
       AND      sl.statement_line_id = catv.statement_line_id
       AND      sl.trx_type in ('MISC_DEBIT', 'MISC_CREDIT')
       AND      catv.trx_type = 'MISC'
       AND      catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
       --AND	catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
       AND	catv.org_id = nvl(CE_AUTO_BANK_REC.G_org_id, catv.org_id)
       AND      nvl(catv.trx_number, '-99999')
			 = nvl(CE_AUTO_BANK_MATCH.csl_bank_trx_number,'-99999')
       AND      to_char(catv.trx_date,'YYYY/MM/DD') <=
		to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
       AND      catv.request_id = nvl(FND_GLOBAL.conc_request_id,-1)
       AND      catv.bank_account_amount
		between (decode(sl.trx_type,
				'MISC_CREDIT', sl.amount,
				- sl.amount) +
			 decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				'MISC_DEBIT', - CE_AUTO_BANK_MATCH.csl_amount,
				CE_AUTO_BANK_MATCH.csl_amount)
			 - decode(catv.trx_currency_type,
				'BANK', tolerance_amount,
				CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance))
		and     (decode(sl.trx_type,
				'MISC_CREDIT', sl.amount,
				- sl.amount) +
			 decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				'MISC_DEBIT', - CE_AUTO_BANK_MATCH.csl_amount,
				CE_AUTO_BANK_MATCH.csl_amount)
			 + decode(catv.trx_currency_type,
				'BANK', tolerance_amount,
				CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance))
       AND      catv.bank_account_amount
		between ((decode(sl.trx_type,
				'MISC_CREDIT', sl.amount,
				- sl.amount) +
			decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				'MISC_DEBIT', - CE_AUTO_BANK_MATCH.csl_amount,
				CE_AUTO_BANK_MATCH.csl_amount))
				- abs((decode(sl.trx_type,
					'MISC_CREDIT', sl.amount,
					- sl.amount) +
			decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				'MISC_DEBIT', - CE_AUTO_BANK_MATCH.csl_amount,
				CE_AUTO_BANK_MATCH.csl_amount)) *
				CE_AUTO_BANK_MATCH.ba_ar_percent_tolerance / 100))
		and	((decode(sl.trx_type,
				'MISC_CREDIT', sl.amount,
				- sl.amount)
			+ decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				 'MISC_DEBIT', - CE_AUTO_BANK_MATCH.csl_amount,
				CE_AUTO_BANK_MATCH.csl_amount))
			+ abs((decode(sl.trx_type,
				'MISC_CREDIT', sl.amount,
				- sl.amount)
			+ decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				'MISC_DEBIT', - CE_AUTO_BANK_MATCH.csl_amount,
				CE_AUTO_BANK_MATCH.csl_amount)) *
				CE_AUTO_BANK_MATCH.ba_ar_percent_tolerance / 100))
       AND NOT EXISTS
	  (select NULL
	   from   ce_statement_reconcils_all r
	   where  r.statement_line_id = catv.statement_line_id
	   and    r.current_record_flag = 'Y'
	   and    nvl(r.status_flag, 'U') <> 'U'
	   AND    r.reference_type = 'STATEMENT');

  cursor get_recon_adj_cash(tolerance_amount NUMBER) is
       SELECT   sl.statement_line_id,
		'RECEIPT',
		sl.trx_type,
		sl.rowid,
		sl.amount,
		catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		catv.trx_type,
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.clearing_trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		catv.org_id,
		catv.CE_BANK_ACCT_USE_ID
       FROM     ce_222_reconciled_v catv, ce_statement_lines sl
       WHERE    nvl(sl.bank_trx_number,'-9999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_trx_number, '-9999')
       AND      (nvl(sl.invoice_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_invoice_text, '-99999')
			and (nvl(sl.bank_account_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_account_text,'-99999')
			or nvl(sl.customer_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_customer_text,'-99999')))
       AND      sl.statement_line_id = catv.statement_line_id
       AND      sl.trx_type in ('DEBIT', 'CREDIT')
       AND      catv.trx_type = 'CASH'
       AND      catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
       --AND	catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
       AND	catv.org_id = nvl(CE_AUTO_BANK_REC.G_org_id,catv.org_id)
       AND      nvl(catv.trx_number, '-99999')
			 = nvl(CE_AUTO_BANK_MATCH.csl_bank_trx_number, '-99999')
       AND      to_char(catv.trx_date,'YYYY/MM/DD') <=
		to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
       AND      catv.request_id = nvl(FND_GLOBAL.conc_request_id,-1)
       AND      catv.bank_account_amount
		between (decode(sl.trx_type,
				'CREDIT', sl.amount,
				- sl.amount)
			+ decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				'MISC_DEBIT', - CE_AUTO_BANK_MATCH.csl_amount,
				CE_AUTO_BANK_MATCH.csl_amount)
			- decode(catv.trx_currency_type,
				'BANK', tolerance_amount,
				CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance))
		and     (decode(sl.trx_type,
				'CREDIT', sl.amount,
				- sl.amount)
			+ decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				'MISC_DEBIT', - CE_AUTO_BANK_MATCH.csl_amount,
				CE_AUTO_BANK_MATCH.csl_amount)
			+ decode(catv.trx_currency_type,
				'BANK', tolerance_amount,
				CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance))
       AND      catv.bank_account_amount
		between ((decode(sl.trx_type,
				'CREDIT', sl.amount,
				- sl.amount)
			+ decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				'MISC_DEBIT', - CE_AUTO_BANK_MATCH.csl_amount,
				CE_AUTO_BANK_MATCH.csl_amount))
			- abs((decode(sl.trx_type,
				'CREDIT', sl.amount,
				- sl.amount)
			+ decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				'MISC_DEBIT', - CE_AUTO_BANK_MATCH.csl_amount,
				CE_AUTO_BANK_MATCH.csl_amount)) *
				CE_AUTO_BANK_MATCH.ba_ar_percent_tolerance / 100))
		and     ((decode(sl.trx_type,
				'CREDIT', sl.amount,
				- sl.amount)
			+ decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				'MISC_DEBIT', - CE_AUTO_BANK_MATCH.csl_amount,
				CE_AUTO_BANK_MATCH.csl_amount))
			+ abs((decode(sl.trx_type,
				'CREDIT', sl.amount,
				- sl.amount)
			+ decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				'MISC_DEBIT', - CE_AUTO_BANK_MATCH.csl_amount,
				CE_AUTO_BANK_MATCH.csl_amount)) *
				CE_AUTO_BANK_MATCH.ba_ar_percent_tolerance / 100))
       AND NOT EXISTS
	  (select NULL
	   from   ce_statement_reconcils_all r
	   where  r.statement_line_id = catv.statement_line_id
	   and    r.current_record_flag = 'Y'
	   and    nvl(r.status_flag, 'U') <> 'U'
	   AND    r.reference_type = 'STATEMENT');

  cursor get_recon_adj_pay(tolerance_amount NUMBER) is
       SELECT   catv.statement_line_id,
		'PAYMENT',
		sl.trx_type,
		sl.rowid,
		sl.amount,
		catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		catv.trx_type,
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.clearing_trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		catv.org_id,
		catv.CE_BANK_ACCT_USE_ID
       FROM     ce_200_reconciled_v catv, ce_statement_lines sl
       WHERE    nvl(sl.bank_trx_number,'-9999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_trx_number, '-9999')
       AND      (nvl(sl.invoice_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_invoice_text, '-99999')
		and (nvl(sl.bank_account_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_account_text,'-99999')
			or nvl(sl.customer_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_customer_text,'-99999')))
       AND      sl.statement_line_id = catv.statement_line_id
       AND      sl.trx_type in ('DEBIT', 'CREDIT')
       AND      catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
       --AND	catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
       AND	catv.org_id = nvl(CE_AUTO_BANK_REC.G_org_id,catv.org_id)
       AND      nvl(catv.trx_number,'-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_trx_number,'-99999')
       AND      to_char(catv.trx_date,'YYYY/MM/DD') <=
		to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
       AND      catv.request_id = nvl(FND_GLOBAL.conc_request_id,-1)
       AND      catv.bank_account_amount
		between (decode(sl.trx_type,
				'DEBIT', sl.amount,
				- sl.amount)
			+ decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				'MISC_DEBIT', CE_AUTO_BANK_MATCH.csl_amount,
				- CE_AUTO_BANK_MATCH.csl_amount)
			- decode(catv.trx_currency_type,
				'BANK', tolerance_amount,
				CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance))
		and     (decode(sl.trx_type,
				'DEBIT', sl.amount,
				- sl.amount)
			+ decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				'MISC_DEBIT', CE_AUTO_BANK_MATCH.csl_amount,
				- CE_AUTO_BANK_MATCH.csl_amount)
			+ decode(catv.trx_currency_type,
				'BANK', tolerance_amount,
				CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance))
       AND      catv.bank_account_amount
		between ((decode(sl.trx_type,
				'CREDIT', sl.amount,
				- sl.amount)
			+ decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				'MISC_DEBIT', CE_AUTO_BANK_MATCH.csl_amount,
				- CE_AUTO_BANK_MATCH.csl_amount))
			- abs((decode(sl.trx_type,
				'CREDIT', sl.amount,
				- sl.amount)
			+ decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				'MISC_DEBIT', CE_AUTO_BANK_MATCH.csl_amount,
				- CE_AUTO_BANK_MATCH.csl_amount)) *
				CE_AUTO_BANK_MATCH.ba_ap_percent_tolerance / 100))
		and     ((decode(sl.trx_type,
				'CREDIT', sl.amount,
				- sl.amount)
			+ decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				'MISC_DEBIT', CE_AUTO_BANK_MATCH.csl_amount,
				- CE_AUTO_BANK_MATCH.csl_amount))
			+ abs((decode(sl.trx_type,
				'CREDIT', sl.amount,
				- sl.amount)
			+ decode(CE_AUTO_BANK_MATCH.csl_trx_type,
				'MISC_DEBIT', CE_AUTO_BANK_MATCH.csl_amount,
				- CE_AUTO_BANK_MATCH.csl_amount)) *
				CE_AUTO_BANK_MATCH.ba_ap_percent_tolerance / 100))
       AND NOT EXISTS
	  (select NULL
	   from   ce_statement_reconcils_all r
	   where  r.statement_line_id = catv.statement_line_id
	   and    r.current_record_flag = 'Y'
	   and    nvl(r.status_flag, 'U') <> 'U'
	   AND    r.reference_type = 'STATEMENT');

  cursor get_recon_adj2_ar(tolerance_amount NUMBER) is
       SELECT   l.statement_line_id,
		l.rowid,
		l.trx_date,
		l.currency_code,
		decode(l.currency_code, CE_AUTO_BANK_REC.G_functional_currency,
		  l.amount, CE_AUTO_BANK_MATCH.aba_bank_currency, l.amount,
		  nvl(l.original_amount, l.amount)),
		l.original_amount,
		l.status,
		0,
		l.trx_type,
		1,
		decode(l.currency_code, CE_AUTO_BANK_REC.G_functional_currency,
		  'FUNCTIONAL', CE_AUTO_BANK_MATCH.aba_bank_currency, 'BANK',
		  'FOREIGN'),
		l.amount,
		l.trx_type,
		l.exchange_rate,
		l.exchange_rate_date,
		glcc.user_conversion_type,
		v.trx_id,
		v.cash_receipt_id,
		v.row_id,
		v.trx_date,
		v.currency_code,
		v.bank_account_amount,
		v.base_amount,
		v.status,
		nvl(v.amount_cleared,0),
		v.trx_type,
		v.trx_currency_type,
		v.amount,
		v.clearing_trx_type,
		v.exchange_rate,
		v.exchange_rate_date,
		v.exchange_rate_type,
		'RECEIPT',
		r.reference_id,
		ar.cash_receipt_id,
		ar.trx_date,
		v.org_id,
		v.CE_BANK_ACCT_USE_ID,
		v.seq_id
       --FROM     ce_222_transactions_v v, gl_daily_conversion_types glcc,
       FROM     ce_available_transactions_tmp v, gl_daily_conversion_types glcc,
		ar_cash_receipt_history_all ar, ce_statement_headers h,
		ce_statement_reconcils_all r, ce_statement_lines l
       WHERE    h.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
       AND      nvl(l.bank_trx_number,'-9999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_trx_number, '-9999')
       AND      (nvl(l.invoice_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_invoice_text, '-99999')
			and (nvl(l.bank_account_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_account_text,'-99999')
			or nvl(l.customer_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_customer_text,'-99999')))
       AND      to_char(l.trx_date,'YYYY/MM/DD') <=
		to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
       AND      l.status = 'RECONCILED'
       AND      l.statement_line_id <> CE_AUTO_BANK_MATCH.csl_statement_line_id
       AND      l.trx_type in ('DEBIT', 'CREDIT')
       AND	l.statement_header_id = h.statement_header_id
       AND	r.statement_line_id = l.statement_line_id
       AND	r.org_id = v.org_id
       AND	nvl(r.current_record_flag, 'Y') = 'Y'
       AND	nvl(r.status_flag, 'U') <> 'U'
       AND	glcc.conversion_type = l.exchange_rate_type
       AND	ar.cash_receipt_history_id = r.reference_id
       AND	ar.org_id = r.org_id
       AND      v.trx_type = 'CASH'
       AND	v.bank_account_id = h.bank_account_id
       --AND	v.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
       AND	v.org_id = nvl(CE_AUTO_BANK_REC.G_org_id,v.org_id)
       AND    	v.trx_number = nvl(l.bank_trx_number,v.trx_number)
       AND    	to_char(v.trx_date,'YYYY/MM/DD') <=
		to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
       AND    	v.status in ('REMITTED', 'CLEARED', 'RISK_ELIMINATED')
       AND      CE_AUTO_BANK_MATCH.calc_csl_amount +
		decode(l.trx_type, 'DEBIT', - l.amount, l.amount) > 0
       AND    	v.bank_account_amount
		between (CE_AUTO_BANK_MATCH.calc_csl_amount
			+ decode(l.trx_type,
				'CREDIT', l.amount,
				- l.amount)
			- decode(l.currency_code,
				CE_AUTO_BANK_REC.G_functional_currency,
					CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance,
				CE_AUTO_BANK_MATCH.aba_bank_currency,
					tolerance_amount,
				CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance))
		and (CE_AUTO_BANK_MATCH.calc_csl_amount
			+ decode(l.trx_type,
				'CREDIT', l.amount,
				- l.amount)
			+ decode(l.currency_code,
				CE_AUTO_BANK_REC.G_functional_currency,
					CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance,
				CE_AUTO_BANK_MATCH.aba_bank_currency,
					tolerance_amount,
				CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance))
       AND      v.bank_account_amount
		between ((CE_AUTO_BANK_MATCH.calc_csl_amount
			+ decode(l.trx_type, 'CREDIT', l.amount, - l.amount))
			- abs((CE_AUTO_BANK_MATCH.calc_csl_amount +
			  decode(l.trx_type, 'CREDIT', l.amount, - l.amount))
			  * CE_AUTO_BANK_MATCH.ba_ar_percent_tolerance / 100))
		and ((CE_AUTO_BANK_MATCH.calc_csl_amount
			+ decode(l.trx_type, 'CREDIT', l.amount, - l.amount))
			+ abs((CE_AUTO_BANK_MATCH.calc_csl_amount +
			  decode(l.trx_type, 'CREDIT', l.amount, - l.amount))
			  * CE_AUTO_BANK_MATCH.ba_ar_percent_tolerance / 100))
       AND	v.application_id = 222
       AND	NVL(v.reconciled_status_flag, 'N') = 'N';

  cursor get_recon_adj2_ap(tolerance_amount NUMBER) is
       SELECT   l.statement_line_id,
		l.rowid,
		l.trx_date,
		l.currency_code,
		decode(l.currency_code, CE_AUTO_BANK_REC.G_functional_currency,
		  l.amount, CE_AUTO_BANK_MATCH.aba_bank_currency, l.amount,
		  nvl(l.original_amount, l.amount)),
		l.original_amount,
		l.status,
		0,
		l.trx_type,
		1,
		decode(l.currency_code, CE_AUTO_BANK_REC.G_functional_currency,
		  'FUNCTIONAL', CE_AUTO_BANK_MATCH.aba_bank_currency, 'BANK',
		  'FOREIGN'),
		l.amount,
		l.trx_type,
		l.exchange_rate,
		l.exchange_rate_date,
		glcc.user_conversion_type,
		v2.trx_id,
		v2.cash_receipt_id,
		v2.row_id,
		v2.trx_date,
		v2.currency_code,
		v2.bank_account_amount,
		v2.base_amount,
		v2.status,
		nvl(v2.amount_cleared,0),
		'PAYMENT', /* v2.trx_type, */
		v2.trx_currency_type,
		v2.amount,
		'PAYMENT', /* v2.clearing_trx_type, */
		v2.exchange_rate,
		v2.exchange_rate_date,
		v2.exchange_rate_type,
		'PAYMENT',
		r.reference_id,
		to_number(NULL),
		to_date(NULL),
		v2.org_id,
		v2.CE_BANK_ACCT_USE_ID,
		v2.seq_id
       --FROM     ce_200_transactions_v v2, gl_daily_conversion_types glcc,
       FROM     ce_available_transactions_tmp v2, gl_daily_conversion_types glcc,
		ce_statement_headers h,
		ce_statement_reconcils_all r, ce_statement_lines l
       WHERE    h.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
       AND      nvl(l.bank_trx_number,'-9999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_trx_number, '-9999')
       AND      (nvl(l.invoice_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_invoice_text, '-99999')
			and (nvl(l.bank_account_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_bank_account_text,'-99999')
			or nvl(l.customer_text, '-99999') =
			nvl(CE_AUTO_BANK_MATCH.csl_customer_text,'-99999')))
       AND      to_char(l.trx_date,'YYYY/MM/DD') <=
		to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
       AND      l.status = 'RECONCILED'
       AND      l.statement_line_id <> CE_AUTO_BANK_MATCH.csl_statement_line_id
       AND      l.trx_type in ('DEBIT', 'CREDIT')
       AND      l.statement_header_id = h.statement_header_id
       AND      r.statement_line_id = l.statement_line_id
       AND	r.org_id	= v2.org_id
       AND      nvl(r.current_record_flag, 'Y') = 'Y'
       AND      nvl(r.status_flag, 'U') <> 'U'
       AND      glcc.conversion_type = l.exchange_rate_type
       AND	v2.bank_account_id = h.bank_account_id
       --AND	v2.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
       AND	v2.org_id = nvl(CE_AUTO_BANK_REC.G_org_id,v2.org_id)
       AND    	v2.trx_number = nvl(l.bank_trx_number,v2.trx_number)
       AND    	to_char(v2.trx_date,'YYYY/MM/DD') <=
		to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
       AND      CE_AUTO_BANK_MATCH.calc_csl_amount +
		decode(l.trx_type, 'DEBIT', - l.amount, l.amount) < 0
       AND      v2.bank_account_amount
		between (- CE_AUTO_BANK_MATCH.calc_csl_amount
			+ decode(l.trx_type, 'DEBIT', l.amount, - l.amount)
			- decode(l.currency_code,
				CE_AUTO_BANK_REC.G_functional_currency,
					CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance,
				CE_AUTO_BANK_MATCH.aba_bank_currency,
					tolerance_amount,
				CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance))
		and (- CE_AUTO_BANK_MATCH.calc_csl_amount
			+ decode(l.trx_type, 'DEBIT', l.amount, - l.amount)
			+ decode(l.currency_code,
				CE_AUTO_BANK_REC.G_functional_currency,
					CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance,
				CE_AUTO_BANK_MATCH.aba_bank_currency,
					tolerance_amount,
				CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance))
       AND      v2.bank_account_amount
		between ((- CE_AUTO_BANK_MATCH.calc_csl_amount
			+ decode(l.trx_type, 'DEBIT', l.amount, - l.amount))
			- abs((- CE_AUTO_BANK_MATCH.calc_csl_amount +
			  decode(l.trx_type, 'DEBIT', l.amount, - l.amount))
			  * CE_AUTO_BANK_MATCH.ba_ap_percent_tolerance / 100))
		and ((- CE_AUTO_BANK_MATCH.calc_csl_amount
			+ decode(l.trx_type, 'DEBIT', l.amount, - l.amount))
			+ abs((- CE_AUTO_BANK_MATCH.calc_csl_amount +
			  decode(l.trx_type, 'DEBIT', l.amount, - l.amount))
			  * CE_AUTO_BANK_MATCH.ba_ap_percent_tolerance / 100))
       AND 	v2.application_id = 200
       AND	NVL(v2.reconciled_status_flag, 'N') = 'N';

  calc_tolerance_amount	 NUMBER;
  calc_tolerance_amount_ap	 NUMBER;
  calc_tolerance_amount_ar	 NUMBER;
  loc_match_type	 CE_LOOKUPS.lookup_code%TYPE;
  loc_trx_id		 AR_CASH_RECEIPT_HISTORY_ALL.cash_receipt_history_id%TYPE;
  loc_cash_receipt_id	 AR_CASH_RECEIPT_HISTORY_ALL.cash_receipt_id%TYPE;
  loc_trx_date		 DATE;

BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.stmtline_match');
  no_of_matches := 0;

  /* Calculate calc_tolerance_amount. */

  IF (NVL(CE_AUTO_BANK_MATCH.csl_currency_code,
	CE_AUTO_BANK_MATCH.aba_bank_currency)
	= CE_AUTO_BANK_REC.G_functional_currency) THEN
    CE_AUTO_BANK_MATCH.trx_currency_type := 'FUNCTIONAL';
  ELSIF (NVL(CE_AUTO_BANK_MATCH.csl_currency_code,
	CE_AUTO_BANK_MATCH.aba_bank_currency)
	= CE_AUTO_BANK_MATCH.aba_bank_currency) THEN
    CE_AUTO_BANK_MATCH.trx_currency_type := 'BANK';
  ELSE
    CE_AUTO_BANK_MATCH.trx_currency_type := 'FOREIGN';
  END IF;

  --
  -- Amount tolerance
  -- bug 3676745 MO/BA uptake
  -- AP/AR transactions - get tolerance amount in the following order (per Amrita)
  -- 1) tolerances defined at the bank account level
  -- 2) tolerances defined at the system parameters level for the OU for which the transactions
  --   	are being reconciled
  -- 3) if none exist then the tolerance is zero.
  -- No tolerance for PAY, PAY_EFT, JE_LINE, STATEMENT transactions
  -- ROI_LINE -LE???

  -- In rel 11i - tolerance amount is in Functional currency		|
  -- In rel 12 - tolerance amount is in Bank Account currency (bug 4969806)
  -- bug 4969806  tolerance amount is in Bank Account currency,
  --              do not need to convert tolerance amount
  IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('PAYMENT')) THEN
    calc_tolerance_amount_ap := CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance ;
  ELSIF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('CASH', 'MISC')) THEN
    calc_tolerance_amount_ar := CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance;
  ELSE
    calc_tolerance_amount := 0;
  END IF;

/*
  IF (CE_AUTO_BANK_MATCH.trx_currency_type = 'BANK') THEN
    IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('PAYMENT')) THEN
      IF (nvl(CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance,0) <> 0) THEN
	  calc_tolerance_amount_ap :=
 	    convert_amount_tolerance(CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance);
      ELSE
        calc_tolerance_amount_ap := 0;
      END IF;
    ELSIF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('CASH','MISC')) THEN
      IF (nvl(CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance,0) <> 0) THEN
	  calc_tolerance_amount_ar :=
 	    convert_amount_tolerance(CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance);
      ELSE
        calc_tolerance_amount_ar := 0;
      END IF;
    ELSE
      IF (NVL(CE_AUTO_BANK_MATCH.BA_RECON_OI_AMOUNT_TOLERANCE,0) <> 0) THEN
        calc_tolerance_amount :=
	  convert_amount_tolerance(CE_AUTO_BANK_MATCH.BA_RECON_OI_AMOUNT_TOLERANCE);
      ELSE
        calc_tolerance_amount := 0;
      END IF;
    END IF;
  ELSIF (CE_AUTO_BANK_MATCH.trx_currency_type IN ('FUNCTIONAL','FOREIGN')) THEN
    IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('PAYMENT')) THEN
        calc_tolerance_amount_ap := CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance ;
    ELSIF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('CASH', 'MISC')) THEN
       calc_tolerance_amount_ar := CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance;
    ELSE
      calc_tolerance_amount := CE_AUTO_BANK_MATCH.BA_RECON_OI_AMOUNT_TOLERANCE;
    END IF;
  END IF;
*/
/*
  IF (CE_AUTO_BANK_MATCH.trx_currency_type = 'BANK') THEN
    IF (NVL(CE_AUTO_BANK_REC.G_amount_tolerance,0) <> 0) THEN
      calc_tolerance_amount :=
	  convert_amount_tolerance(CE_AUTO_BANK_REC.G_amount_tolerance);
    ELSE
      calc_tolerance_amount := 0;
    END IF;
  ELSIF (CE_AUTO_BANK_MATCH.trx_currency_type IN ('FUNCTIONAL','FOREIGN')) THEN
    calc_tolerance_amount := CE_AUTO_BANK_REC.G_amount_tolerance;
  END IF;
*/

  --------------------------------------------------------------------------------
  cep_standard.debug('DEBUG: calc_tolerance_amount = '|| calc_tolerance_amount);
  cep_standard.debug('DEBUG: calc_tolerance_amount_ap = '|| calc_tolerance_amount_ap);
  cep_standard.debug('DEBUG: calc_tolerance_amount_ar = '|| calc_tolerance_amount_ar);
  cep_standard.debug('DEBUG: csl_correction_method = '|| csl_correction_method);

  if (CE_AUTO_BANK_MATCH.csl_correction_method in ('REVERSAL', 'BOTH')) then
    OPEN get_reversal;
    FETCH get_reversal
    INTO     	CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
		CE_AUTO_BANK_MATCH.gt_seq_id;
    CLOSE get_reversal;

    cep_standard.debug('DEBUG: get_reversal no_of_matches = '|| no_of_matches);
    if (no_of_matches = 1) then
       CE_AUTO_BANK_MATCH.csl_match_correction_type := 'REVERSAL';
       CE_AUTO_BANK_MATCH.corr_csl_amount := 0;
       CE_AUTO_BANK_MATCH.calc_csl_amount := 0;
    end if;
  end if;

  if (CE_AUTO_BANK_MATCH.csl_correction_method in ('ADJUSTMENT', 'BOTH') AND
      no_of_matches <> 1) then
    cep_standard.debug('DEBUG: get_adjustment calc_tolerance_amount = '
		|| calc_tolerance_amount);
    cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.csh_bank_account_id = '
		|| CE_AUTO_BANK_MATCH.csh_bank_account_id);
    cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.csl_bank_trx_number = '
		|| CE_AUTO_BANK_MATCH.csl_bank_trx_number);
    cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.csl_trx_date = '
		|| CE_AUTO_BANK_MATCH.csl_trx_date);
    cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.csl_statement_line_id = '
		|| CE_AUTO_BANK_MATCH.csl_statement_line_id);
    cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.calc_csl_amount = '
		|| CE_AUTO_BANK_MATCH.calc_csl_amount);


    -- No transaction match if the sum of statement line amount is $0.
    --OPEN get_adjustment(calc_tolerance_amount);
    OPEN get_adjustment(calc_tolerance_amount_ap,calc_tolerance_amount_ar );
    FETCH get_adjustment
    INTO	CE_AUTO_BANK_MATCH.trx_id2,
		CE_AUTO_BANK_MATCH.trx_rowid2,
		CE_AUTO_BANK_MATCH.trx_date2,
		CE_AUTO_BANK_MATCH.trx_currency_code2,
		CE_AUTO_BANK_MATCH.trx_amount2,
		CE_AUTO_BANK_MATCH.trx_base_amount2,
		CE_AUTO_BANK_MATCH.trx_status2,
		CE_AUTO_BANK_MATCH.trx_cleared_amount2,
		CE_AUTO_BANK_MATCH.csl_match_type2,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type2,
		CE_AUTO_BANK_MATCH.trx_curr_amount2,
		CE_AUTO_BANK_MATCH.trx_type2,
		CE_AUTO_BANK_MATCH.trx_exchange_rate2,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date2,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type2,
		CE_AUTO_BANK_MATCH.gt_seq_id2,
		CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
		CE_AUTO_BANK_MATCH.trx_gl_date,
               	CE_AUTO_BANK_MATCH.trx_cleared_date,
 		CE_AUTO_BANK_MATCH.trx_org_id,
 		CE_AUTO_BANK_MATCH.trx_bank_acct_use_id,
		CE_AUTO_BANK_MATCH.gt_seq_id;
    CLOSE get_adjustment;

    cep_standard.debug('DEBUG: get_adjustment no_of_matches = '||no_of_matches);
    if (no_of_matches = 1) then
      CE_AUTO_BANK_MATCH.csl_match_correction_type := 'ADJUSTMENT';
      if (CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_CREDIT') then
	if (CE_AUTO_BANK_MATCH.trx_type2 in ('CREDIT', 'MISC_CREDIT')) then
	  CE_AUTO_BANK_MATCH.corr_csl_amount := CE_AUTO_BANK_MATCH.csl_amount
	      + CE_AUTO_BANK_MATCH.trx_amount2;
	else
	  CE_AUTO_BANK_MATCH.corr_csl_amount := CE_AUTO_BANK_MATCH.csl_amount
	      - CE_AUTO_BANK_MATCH.trx_amount2;
	end if;
      else  /* CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_DEBIT' */
	if (CE_AUTO_BANK_MATCH.trx_type2 in ('DEBIT', 'MISC_DEBIT')) then
	  CE_AUTO_BANK_MATCH.corr_csl_amount := CE_AUTO_BANK_MATCH.csl_amount
	      + CE_AUTO_BANK_MATCH.trx_amount2;
	else
	  CE_AUTO_BANK_MATCH.corr_csl_amount := CE_AUTO_BANK_MATCH.csl_amount
	      - CE_AUTO_BANK_MATCH.trx_amount2;
	end if;
      end if;
      cep_standard.debug('corr_csl_amount: '||corr_csl_amount);
      CE_AUTO_BANK_MATCH.calc_csl_amount := CE_AUTO_BANK_MATCH.corr_csl_amount;
    end if;
  end if;

  if (CE_AUTO_BANK_MATCH.csl_correction_method in ('REVERSAL', 'BOTH') AND
      no_of_matches <> 1) then

    if (csl_trx_type = 'MISC_CREDIT') then
      OPEN get_rev_credit;
      FETCH get_rev_credit
      INTO	CE_AUTO_BANK_MATCH.trx_id2,
		CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
 		CE_AUTO_BANK_MATCH.trx_org_id,
 		CE_AUTO_BANK_MATCH.trx_bank_acct_use_id;
      CLOSE get_rev_credit;
    end if;

    if (csl_trx_type = 'MISC_DEBIT' OR no_of_matches <> 1) then
      OPEN get_rev_debit;
      FETCH get_rev_debit
      INTO	CE_AUTO_BANK_MATCH.trx_id2,
		CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
 		CE_AUTO_BANK_MATCH.trx_org_id,
 		CE_AUTO_BANK_MATCH.trx_bank_acct_use_id;
      CLOSE get_rev_debit;
    end if;

    cep_standard.debug('DEBUG: get_rev_xx no_of_matches = '|| no_of_matches);
    if (no_of_matches = 1) then

      -- bug 4914608 set the org after a match for AR/AP
      set_single_org(CE_AUTO_BANK_MATCH.trx_org_id);

      if CE_AUTO_BANK_MATCH.csl_match_type = 'PAYMENT' then
/*
	  AP_RECONCILIATION_PKG.recon_reverse(
	     X_CHECKRUN_ID                   => NULL,
	     X_CHECK_ID                      => CE_AUTO_BANK_MATCH.trx_id,
	     X_LAST_UPDATED_BY               => nvl(FND_GLOBAL.user_id, -1),
	     X_LAST_UPDATE_LOGIN             => nvl(FND_GLOBAL.user_id, -1),
	     X_CREATED_BY                    => nvl(FND_GLOBAL.user_id, -1),
	     X_PROGRAM_APPLICATION_ID        => NULL,
	     X_PROGRAM_ID                    => NULL,
	     X_REQUEST_ID                    => NULL);
*/
	  AP_RECONCILIATION_PKG.recon_payment_history(
	     X_CHECKRUN_ID           => to_number(NULL),
	     X_CHECK_ID              => CE_AUTO_BANK_MATCH.trx_id,
	     X_ACCOUNTING_DATE       => to_date(NULL),
	     X_CLEARED_DATE          => to_date(NULL),
	     X_TRANSACTION_AMOUNT    => CE_AUTO_BANK_MATCH.trx_amount,
	     X_TRANSACTION_TYPE      => 'PAYMENT UNCLEARING',
	     X_ERROR_AMOUNT          => to_number(NULL),
	     X_CHARGE_AMOUNT         => to_number(NULL),
	     X_CURRENCY_CODE         => CE_AUTO_BANK_MATCH.trx_currency_code,
	     X_EXCHANGE_RATE_TYPE  => CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
	     X_EXCHANGE_RATE_DATE  => CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
	     X_EXCHANGE_RATE         => CE_AUTO_BANK_MATCH.trx_exchange_rate,
	     X_MATCHED_FLAG          => 'Y',
	     X_ACTUAL_VALUE_DATE     => to_date(NULL),
	     X_LAST_UPDATE_DATE      => sysdate,
	     X_LAST_UPDATED_BY       => NVL(FND_GLOBAL.user_id,-1),
	     X_LAST_UPDATE_LOGIN     => NVL(FND_GLOBAL.user_id,-1),
	     X_CREATED_BY            => NVL(FND_GLOBAL.user_id,-1),
	     X_CREATION_DATE         => sysdate,
	     X_PROGRAM_UPDATE_DATE   => to_date(NULL),
	     X_PROGRAM_APPLICATION_ID=> to_number(NULL),
	     X_PROGRAM_ID            => to_number(NULL),
	     X_REQUEST_ID            => to_number(NULL),
	     X_CALLING_SEQUENCE      => 'CE_AUTO_BANK_MATCH.stmtline_match');

      elsif CE_AUTO_BANK_MATCH.csl_match_type = 'RECEIPT' then

	ARP_CASHBOOK.unclear(
	     p_cr_id                 => CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
	     p_trx_date              => CE_AUTO_BANK_MATCH.trx_date,
	     p_gl_date               => CE_AUTO_BANK_REC.G_gl_date,
	     p_actual_value_date     => CE_AUTO_BANK_MATCH.csl_effective_date,
	     p_module_name           => 'CEABRMA',
	     p_module_version        => '1.0',
	     p_crh_id                => CE_AUTO_BANK_MATCH.trx_id);
      end if;

      --delete from ce_statement_reconciliations
      delete from ce_statement_reconcils_all
      where statement_line_id = CE_AUTO_BANK_MATCH.trx_id2
      and request_id = nvl(FND_GLOBAL.conc_request_id,-1);
      CE_AUTO_BANK_MATCH.trx_id := CE_AUTO_BANK_MATCH.trx_id2;
      CE_AUTO_BANK_MATCH.csl_match_correction_type := 'REVERSAL';
      CE_AUTO_BANK_MATCH.corr_csl_amount := 0;
      CE_AUTO_BANK_MATCH.calc_csl_amount := 0;
      CE_AUTO_BANK_MATCH.reconciled_this_run := 'Y';
    end if;
  end if;

  if (CE_AUTO_BANK_MATCH.csl_correction_method in ('ADJUSTMENT', 'BOTH') AND
      no_of_matches <> 1) then
    OPEN get_recon_adj_misc(calc_tolerance_amount_ar);
    FETCH get_recon_adj_misc
    INTO        CE_AUTO_BANK_MATCH.trx_id2,
		CE_AUTO_BANK_MATCH.csl_match_type2,
		CE_AUTO_BANK_MATCH.trx_type2,
		CE_AUTO_BANK_MATCH.trx_rowid2,
		CE_AUTO_BANK_MATCH.trx_amount2,
		CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
 		CE_AUTO_BANK_MATCH.trx_org_id,
 		CE_AUTO_BANK_MATCH.trx_bank_acct_use_id;
    CLOSE get_recon_adj_misc;

    if (no_of_matches <> 1) then
      OPEN get_recon_adj_cash(calc_tolerance_amount_ar);
      FETCH get_recon_adj_cash
      INTO      CE_AUTO_BANK_MATCH.trx_id2,
		CE_AUTO_BANK_MATCH.csl_match_type2,
		CE_AUTO_BANK_MATCH.trx_type2,
		CE_AUTO_BANK_MATCH.trx_rowid2,
		CE_AUTO_BANK_MATCH.trx_amount2,
		CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
 		CE_AUTO_BANK_MATCH.trx_org_id,
 		CE_AUTO_BANK_MATCH.trx_bank_acct_use_id;
      CLOSE get_recon_adj_cash;
    end if;

    if (no_of_matches <> 1) then
      OPEN get_recon_adj_pay(calc_tolerance_amount_ap);
      FETCH get_recon_adj_pay
      INTO      CE_AUTO_BANK_MATCH.trx_id2,
		CE_AUTO_BANK_MATCH.csl_match_type2,
		CE_AUTO_BANK_MATCH.trx_type2,
		CE_AUTO_BANK_MATCH.trx_rowid2,
		CE_AUTO_BANK_MATCH.trx_amount2,
		CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
 		CE_AUTO_BANK_MATCH.trx_org_id,
 		CE_AUTO_BANK_MATCH.trx_bank_acct_use_id;
      CLOSE get_recon_adj_pay;
    end if;

    cep_standard.debug('DEBUG: get_reconciled_adj no_of_matches = '||
	no_of_matches);
    if (no_of_matches = 1) then
      CE_AUTO_BANK_MATCH.reconciled_this_run := 'Y';
    else
      OPEN get_recon_adj2_ar(calc_tolerance_amount_ar);
      FETCH get_recon_adj2_ar
      INTO	CE_AUTO_BANK_MATCH.trx_id2,
		CE_AUTO_BANK_MATCH.trx_rowid2,
		CE_AUTO_BANK_MATCH.trx_date2,
		CE_AUTO_BANK_MATCH.trx_currency_code2,
		CE_AUTO_BANK_MATCH.trx_amount2,
		CE_AUTO_BANK_MATCH.trx_base_amount2,
		CE_AUTO_BANK_MATCH.trx_status2,
		CE_AUTO_BANK_MATCH.trx_cleared_amount2,
		CE_AUTO_BANK_MATCH.csl_match_type2,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type2,
		CE_AUTO_BANK_MATCH.trx_curr_amount2,
		CE_AUTO_BANK_MATCH.trx_type2,
		CE_AUTO_BANK_MATCH.trx_exchange_rate2,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date2,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type2,
		CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
		loc_match_type,
		loc_trx_id,
		loc_cash_receipt_id,
		loc_trx_date,
 		CE_AUTO_BANK_MATCH.trx_org_id,
 		CE_AUTO_BANK_MATCH.trx_bank_acct_use_id,
		CE_AUTO_BANK_MATCH.gt_seq_id;
      CLOSE get_recon_adj2_ar;

      if (no_of_matches <> 1) then
        OPEN	get_recon_adj2_ap(calc_tolerance_amount_ap);
        FETCH	get_recon_adj2_ap
        INTO	CE_AUTO_BANK_MATCH.trx_id2,
		CE_AUTO_BANK_MATCH.trx_rowid2,
		CE_AUTO_BANK_MATCH.trx_date2,
		CE_AUTO_BANK_MATCH.trx_currency_code2,
		CE_AUTO_BANK_MATCH.trx_amount2,
		CE_AUTO_BANK_MATCH.trx_base_amount2,
		CE_AUTO_BANK_MATCH.trx_status2,
		CE_AUTO_BANK_MATCH.trx_cleared_amount2,
		CE_AUTO_BANK_MATCH.csl_match_type2,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type2,
		CE_AUTO_BANK_MATCH.trx_curr_amount2,
		CE_AUTO_BANK_MATCH.trx_type2,
		CE_AUTO_BANK_MATCH.trx_exchange_rate2,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date2,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type2,
		CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
		loc_match_type,
		loc_trx_id,
		loc_cash_receipt_id,
		loc_trx_date,
 		CE_AUTO_BANK_MATCH.trx_org_id,
 		CE_AUTO_BANK_MATCH.trx_bank_acct_use_id,
		CE_AUTO_BANK_MATCH.gt_seq_id;
      CLOSE get_recon_adj2_ap;
    end if;

      cep_standard.debug('DEBUG: get_reconciled_adj2 no_of_matches = '||
		no_of_matches);
      if (no_of_matches = 1) then

      -- bug 4914608 set the org after a match for AR/AP
      set_single_org(CE_AUTO_BANK_MATCH.trx_org_id);

	if (loc_match_type = 'PAYMENT') then
	/*
	    AP_RECONCILIATION_PKG.recon_reverse(
	     X_CHECKRUN_ID                   => NULL,
	     X_CHECK_ID                      => loc_trx_id,
	     X_LAST_UPDATED_BY               => nvl(FND_GLOBAL.user_id, -1),
	     X_LAST_UPDATE_LOGIN             => nvl(FND_GLOBAL.user_id, -1),
	     X_CREATED_BY                    => nvl(FND_GLOBAL.user_id, -1),
	     X_PROGRAM_APPLICATION_ID        => NULL,
	     X_PROGRAM_ID                    => NULL,
	     X_REQUEST_ID                    => NULL);
	*/
	    AP_RECONCILIATION_PKG.recon_payment_history(
	     X_CHECKRUN_ID           => to_number(NULL),
	     X_CHECK_ID              => loc_trx_id,
	     X_ACCOUNTING_DATE       => to_date(NULL),
	     X_CLEARED_DATE          => to_date(NULL),
	     X_TRANSACTION_AMOUNT    => CE_AUTO_BANK_MATCH.trx_amount,
	     X_TRANSACTION_TYPE      => 'PAYMENT UNCLEARING',
	     X_ERROR_AMOUNT          => to_number(NULL),
	     X_CHARGE_AMOUNT         => to_number(NULL),
	     X_CURRENCY_CODE         => CE_AUTO_BANK_MATCH.trx_currency_code,
	     X_EXCHANGE_RATE_TYPE  => CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
	     X_EXCHANGE_RATE_DATE  => CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
	     X_EXCHANGE_RATE         => CE_AUTO_BANK_MATCH.trx_exchange_rate,
	     X_MATCHED_FLAG          => 'Y',
	     X_ACTUAL_VALUE_DATE     => to_date(NULL),
	     X_LAST_UPDATE_DATE      => sysdate,
	     X_LAST_UPDATED_BY       => NVL(FND_GLOBAL.user_id,-1),
	     X_LAST_UPDATE_LOGIN     => NVL(FND_GLOBAL.user_id,-1),
	     X_CREATED_BY            => NVL(FND_GLOBAL.user_id,-1),
	     X_CREATION_DATE         => sysdate,
	     X_PROGRAM_UPDATE_DATE   => to_date(NULL),
	     X_PROGRAM_APPLICATION_ID=> to_number(NULL),
	     X_PROGRAM_ID            => to_number(NULL),
	     X_REQUEST_ID            => to_number(NULL),
	     X_CALLING_SEQUENCE      => 'CE_AUTO_BANK_MATCH.stmtline_match');

	elsif (loc_match_type = 'RECEIPT') then
	    ARP_CASHBOOK.unclear(
	     p_cr_id                 => loc_cash_receipt_id,
	     p_trx_date              => loc_trx_date,
	     p_gl_date               => CE_AUTO_BANK_REC.G_gl_date,
	     p_actual_value_date     => CE_AUTO_BANK_MATCH.csl_effective_date,
	     p_module_name           => 'CEABRMA',
	     p_module_version        => '1.0',
	     p_crh_id                => loc_trx_id);
	end if;
	CE_AUTO_BANK_MATCH.reconciled_this_run := 'N';
      end if;
    end if;

    if (no_of_matches = 1) then
      CE_AUTO_BANK_MATCH.csl_match_correction_type := 'ADJUSTMENT';
      if (CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_CREDIT') then
	if (CE_AUTO_BANK_MATCH.trx_type2 in ('CREDIT', 'MISC_CREDIT')) then
	  CE_AUTO_BANK_MATCH.corr_csl_amount := CE_AUTO_BANK_MATCH.csl_amount
			+ CE_AUTO_BANK_MATCH.trx_amount2;
	else
	  CE_AUTO_BANK_MATCH.corr_csl_amount := CE_AUTO_BANK_MATCH.csl_amount
			- CE_AUTO_BANK_MATCH.trx_amount2;
	end if;
      else  /* CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_DEBIT' */
	if (CE_AUTO_BANK_MATCH.trx_type2 in ('DEBIT', 'MISC_DEBIT')) then
	  CE_AUTO_BANK_MATCH.corr_csl_amount := CE_AUTO_BANK_MATCH.csl_amount
			+ CE_AUTO_BANK_MATCH.trx_amount2;
	else
	  CE_AUTO_BANK_MATCH.corr_csl_amount := CE_AUTO_BANK_MATCH.csl_amount
			- CE_AUTO_BANK_MATCH.trx_amount2;
	end if;
      end if;
      CE_AUTO_BANK_MATCH.calc_csl_amount := CE_AUTO_BANK_MATCH.corr_csl_amount;
    end if;
  end if;
  if (no_of_matches = 0) then
    raise NO_DATA_FOUND;
  elsif (no_of_matches > 1) then
    raise TOO_MANY_ROWS;
  end if;
  cep_standard.debug('<<CE_AUTO_BANK_MATCH.stmtline_match' );

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_NO_STMTL');
    no_of_matches:=0;
  WHEN TOO_MANY_ROWS THEN
    cep_standard.debug('EXCEPTION: More than one statement line match this receipt' );
    CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_ABR_STMT_PARTIAL');
    no_of_matches:=999;
  WHEN OTHERS THEN
    cep_standard.debug('SQLCODE = '|| sqlcode);
    cep_standard.debug('SQLERRM = '|| sqlerrm);
    cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.stmtline_match' );
    RAISE;

END stmtline_match;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	match_line							|
|  CALLS								|
|	trx_match			         			|
|	batch_match			         			|
|	bank_account_match       					|
|	invoice_match			         			|
|	stmtline_match			         			|
|	trx_validation							|
|									|
|  CALLED BY								|
|	match_engine							|
 --------------------------------------------------------------------- */
PROCEDURE match_line(call_mode	VARCHAR2) IS
  no_of_matches		NUMBER;
  no_of_currencies    	NUMBER;
  dup_invoice           NUMBER;
  curr			NUMBER;

cursor count_dup_invoice is
	select count(*)
	from ap_invoices ap,
	ap_invoice_payments aip,
	ap_checks_all ac,
	ce_bank_accounts ba,
	ce_bank_acct_uses_ou_v bau
	where ba.bank_account_num = CE_AUTO_BANK_MATCH.csl_bank_account_text
	and ba.bank_account_id = bau.bank_account_id
	and bau.AP_USE_ENABLE_FLAG ='Y'
	--and bau.bank_account_id = ac.external_bank_account_id
    	--and bau.bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
        AND bau.org_id = nvl(CE_AUTO_BANK_REC.G_org_id,bau.org_id)
	and bau.bank_acct_use_id = ac.CE_BANK_ACCT_USE_ID
	and ac.check_id    = aip.check_id
	and ac.org_id      = aip.org_id
	and aip.invoice_id = ap.invoice_id
	and ap.invoice_num = CE_AUTO_BANK_MATCH.csl_invoice_text;

BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.match_line');

/* Comment this out NOCOPY since Kayo move this to the match_engine().
  if (CE_AUTO_BANK_MATCH.csl_bank_trx_number is NULL AND
      (CE_AUTO_BANK_MATCH.csl_invoice_text is NULL AND
       CE_AUTO_BANK_MATCH.csl_customer_text is NULL) AND
      (CE_AUTO_BANK_MATCH.csl_bank_account_text is NULL AND
       CE_AUTO_BANK_MATCH.csl_invoice_text is NULL)) then
	--  Message #53000
    raise NO_DATA_FOUND;
  end if;
*/

  IF (call_mode = 'T') THEN
    trx_match(no_of_matches);
  ELSIF (call_mode = 'B') THEN
    batch_match(no_of_matches, no_of_currencies);
  ELSIF (call_mode = 'G') THEN
    Group_match(no_of_matches, no_of_currencies);  --FOR SEPA ER 6700007 END
  ELSIF (call_mode = 'A') THEN
    bank_account_match(no_of_matches);
  ELSIF (call_mode = 'I') THEN
    invoice_match(no_of_matches);
  ELSIF (call_mode = 'S') THEN
    stmtline_match(no_of_matches);
  END IF;

  cep_standard.debug('no_of_matches = '|| no_of_matches);
  cep_standard.debug('no_of_currencies = '|| no_of_currencies);

  IF (no_of_matches = 1) THEN
    IF (trx_validation(no_of_currencies)) THEN
      CE_AUTO_BANK_MATCH.csl_match_found := 'FULL';
    ELSE
      CE_AUTO_BANK_MATCH.csl_match_found := 'PARTIAL';
    END IF;
  ELSIF (no_of_matches > 1) THEN
    CE_AUTO_BANK_MATCH.csl_match_found := 'ERROR';
/*    open  count_dup_invoice;
    fetch count_dup_invoice into dup_invoice;
    close count_dup_invoice;
    IF (dup_invoice > 0) THEN
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
      CE_AUTO_BANK_MATCH.csh_statement_header_id,
      CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_MULTI_MATCH_INVOICE');
    ELSE
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_PMT_PARTIAL');
    END IF;
*/
  ELSE
    CE_AUTO_BANK_MATCH.csl_match_found := 'NONE';
  END IF;
  cep_standard.debug('DEBUG #5 - csl_match_found = '|| csl_match_found);
  cep_standard.debug('<<CE_AUTO_BANK_MATCH.match_line');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.match_line' );
    RAISE;
END match_line;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	match_engine							|
|									|
|  DESCRIPTION								|
|	Depending on the statement line type, try and match the trans-	|
|	action to a credit, debit or miscellaneous transaction.		|
|  									|
|	Relationship between trx_type and receipt_type			|
|	trx_type	receipt_type					|
|	--------	------------					|
|	JE_LINE		JE_LINE						|
|	ROI_LINE	PAYMENT						|
|			CASH						|
|  CALLS								|
|	match_line						        |
|									|
|  CALLED BY								|
|	match_process							|
 --------------------------------------------------------------------- */
PROCEDURE match_engine IS
  l_encoded_message		VARCHAR2(500);
  l_message_name		FND_NEW_MESSAGES.message_name%TYPE;
  l_app_short_name		VARCHAR2(30);
  no_of_currencies		NUMBER;
  primary_match			VARCHAR2(10);
  secondary_match		VARCHAR2(10);
  Tertiary_match		VARCHAR2(10); --- FOR SEPA ER 6700007
  x_statement_line_id		CE_STATEMENT_LINES.statement_line_id%TYPE;
  misc_exists			VARCHAR2(1) := 'N';
  receipt_amount		NUMBER;
  base_receipt_amount		NUMBER;
  precision			NUMBER;
  ext_precision			NUMBER;
  min_acct_unit			NUMBER;
  l_vat_tax_id                  NUMBER := to_number(null);
  l_tax_rate                    NUMBER := to_number(null);
  l_trx_number CE_STATEMENT_LINES.BANK_TRX_NUMBER%TYPE; --Bug 3385023 added this variable.
 accounting_method_found	NUMBER := 0;
  current_org_id		number;
  receivables_trx_org_id		number;

BEGIN

  cep_standard.debug('>>CE_AUTO_BANK_MATCH.match_engine');

  CE_AUTO_BANK_MATCH.csl_match_correction_type := 'NONE';
  CE_AUTO_BANK_MATCH.reconciled_this_run := NULL;
  CE_AUTO_BANK_MATCH.reconcile_to_statement_flag := NULL;

  --
  -- bug 1941362
  -- Reset G_gl_date because trx_match might have changed the G_gl_date
  --
  -- cep_standard.debug('Before reset ** to_date( CE_AUTO_BANK_REC.G_gl_date  = ' || CE_AUTO_BANK_REC.G_gl_date);

  CE_AUTO_BANK_REC.G_gl_date	:= CE_AUTO_BANK_REC.G_gl_date_original;

  -- cep_standard.debug('After reset ** to_date( CE_AUTO_BANK_REC.G_gl_date  = ' || CE_AUTO_BANK_REC.G_gl_date);

  --
  -- Set the trx_currency_type
  --

  IF (NVL(CE_AUTO_BANK_MATCH.csl_currency_code,
      CE_AUTO_BANK_MATCH.aba_bank_currency)
      = CE_AUTO_BANK_REC.G_functional_currency) THEN
    CE_AUTO_BANK_MATCH.trx_currency_type := 'FUNCTIONAL';
  ELSIF (NVL(CE_AUTO_BANK_MATCH.csl_currency_code,
      CE_AUTO_BANK_MATCH.aba_bank_currency)
      = CE_AUTO_BANK_MATCH.aba_bank_currency) THEN
    CE_AUTO_BANK_MATCH.trx_currency_type := 'BANK';
  ELSE
    CE_AUTO_BANK_MATCH.trx_currency_type := 'FOREIGN';
  END IF;

  -- bug3668921
  IF (CE_AUTO_BANK_MATCH.trx_currency_type = 'BANK') THEN
    IF ((CE_AUTO_BANK_MATCH.csl_exchange_rate_type is null and
         CE_AUTO_BANK_MATCH.csl_exchange_rate_date is null and
         CE_AUTO_BANK_MATCH.csl_exchange_rate is null) OR
         (CE_AUTO_BANK_MATCH.csl_exchange_rate_type <> 'User' and
          CE_AUTO_BANK_MATCH.csl_exchange_rate IS NULL)) THEN
      IF (NOT validate_exchange_details) THEN
        cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.trx_validation' );
      END IF;
    END IF;
  END IF;

  IF ((csl_bank_trx_number is null) and not (csl_reconcile_flag = 'OI' and
       nvl(CE_AUTO_BANK_REC.G_open_interface_matching_code,'T') = 'D') and
      (csl_invoice_text is null and csl_bank_account_text is null) and
      (csl_invoice_text is null and csl_customer_text is null) and
      (CE_AUTO_BANK_MATCH.csl_trx_type not in ('MISC_CREDIT', 'MISC_DEBIT') or
      (CE_AUTO_BANK_MATCH.csl_trx_type in ('MISC_CREDIT', 'MISC_DEBIT') and
       nvl(CE_AUTO_BANK_MATCH.csl_create_misc_trx_flag,'N') = 'N'))) THEN

    raise NO_DATA_FOUND;

  ELSIF (trx_currency_type = 'FOREIGN' and CE_AUTO_BANK_MATCH.aba_bank_currency
	<> CE_AUTO_BANK_REC.G_functional_currency) OR
	(trx_currency_type = 'FUNCTIONAL' and
	CE_AUTO_BANK_MATCH.aba_bank_currency
	<> CE_AUTO_BANK_REC.G_functional_currency) THEN

    CE_RECONCILIATION_ERRORS_PKG.insert_row(
    CE_AUTO_BANK_MATCH.csh_statement_header_id,
    CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_NO_FOREIGN_RECON');

  ELSE
    --
    -- Open Interface system option needs to be enabled
    -- before we try to find the match
    --
    IF (CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'OI' AND
	NVL(CE_AUTO_BANK_REC.G_open_interface_flag,'N') = 'N' ) THEN
      CE_RECONCILIATION_ERRORS_PKG.insert_row(
	  CE_AUTO_BANK_MATCH.csh_statement_header_id,
	  CE_AUTO_BANK_MATCH.csl_statement_line_id,
	  'CE_OPEN_INTERFACE_DISABLED');
      CE_AUTO_BANK_MATCH.csl_match_found := 'NONE';

    --
    -- If statement line NOT MISC-creation
    --
    ELSIF (CE_AUTO_BANK_MATCH.csl_trx_type IN
	('DEBIT', 'STOP','CREDIT','NSF','REJECTED', 'SWEEP_IN', 'SWEEP_OUT')) THEN
      primary_match := NULL;
      secondary_match := NULL;
      Tertiary_match  := NULL; --FOR SEPA ER 6700007
      --
      -- For open interface, journal, and payroll reconciliation
      -- csl_reconcile_flag is 'JE' or 'OI' or 'PAY'
      --
      IF (CE_AUTO_BANK_MATCH.csl_reconcile_flag IN ('JE', 'OI', 'PAY','CE')) THEN
        primary_match := 'T';
      --
      -- AP/AR Transaction
      --
      ELSIF (CE_AUTO_BANK_MATCH.csl_reconcile_flag IN ( 'PAY_EFT')) THEN
        primary_match := 'B';
      --
      -- AP/AR Transaction
      --
      ELSE
        --
        -- Prod16 NEW, ability to match by invoice number also for AP
        --
        cep_standard.debug('AP/AR trx');
	IF (CE_AUTO_BANK_MATCH.csl_bank_account_text IS NOT NULL AND
	    CE_AUTO_BANK_MATCH.csl_invoice_text IS NOT NULL) THEN
	  primary_match := 'T';
	  secondary_match := 'A';
	ELSIF (CE_AUTO_BANK_MATCH.csl_invoice_text IS NOT NULL) THEN
	  primary_match := 'T';
	  secondary_match := 'I';
	ELSE
	  IF (CE_AUTO_BANK_MATCH.csl_trx_type IN ('DEBIT', 'STOP')) THEN
	    --FOR SEPA ER 6700007 START
	    primary_match := NVL(CE_AUTO_BANK_REC.G_ap_matching_order,'T');
 	    --bug 7565001 : selective setting secondary_match
        IF (primary_match = 'T') THEN
     	    secondary_match  := NVL(CE_AUTO_BANK_REC.G_ap_matching_order2,'B');
        ELSE
          secondary_match  := NVL(CE_AUTO_BANK_REC.G_ap_matching_order2,'T');
        END IF;


         IF (primary_match = 'T') and (secondary_match = 'B') THEN
	       Tertiary_match := 'G' ;
	     ELSIF (primary_match = 'T') and (secondary_match = 'G') THEN
	       Tertiary_match := 'B';
	     ELSIF (primary_match = 'G') and (secondary_match = 'B') THEN
	       Tertiary_match := 'T';
	     ELSIF (primary_match = 'G') and (secondary_match = 'T') THEN
	       Tertiary_match := 'B';
	     ELSIF (primary_match = 'B') and (secondary_match = 'T') THEN
	       Tertiary_match := 'G';
	     ELSIF (primary_match = 'B') and (secondary_match = 'G') THEN
	       Tertiary_match := 'T';
	     END IF;
	     cep_standard.debug('AP primary_match -'||primary_match||' secondary_match -'||secondary_match||' Tertiary_match -'||Tertiary_match);
	  ELSE
	    primary_match := NVL(CE_AUTO_BANK_REC.G_ar_matching_order,'T');
	    IF (primary_match = 'T') THEN
	        secondary_match := 'B';
	    ELSE
	        secondary_match := 'T';
	    END IF;
	  END IF;
	  --FOR SEPA ER 6700007 END
	END IF;
      END IF;
       cep_standard.debug('EXECUTING  primary_match ');

      match_line(primary_match);
      IF (CE_AUTO_BANK_MATCH.csl_match_found IN ('ERROR','NONE','PARTIAL') AND
	  nvl(CE_AUTO_BANK_MATCH.csl_reconcile_flag,'NONE')
	  NOT IN ('JE', 'OI', 'PAY', 'PAY_EFT', 'CE') AND secondary_match IS NOT NULL) THEN

          cep_standard.debug('EXECUTING  secondary_match ');


        match_line(secondary_match);

		-- Bug 9434957 Start
        -- If Secondary Match Based on Invoice Number and Supplier Bank Accout Number Fetches no Matches Then
        -- Search Based on Invoice Number and Supplier Name (If Given).
          IF (CE_AUTO_BANK_MATCH.csl_bank_account_text IS NOT NULL AND
              CE_AUTO_BANK_MATCH.csl_customer_text  IS NOT NULL AND
              secondary_match <> 'I' AND
              CE_AUTO_BANK_MATCH.csl_match_found IN ('ERROR','NONE','PARTIAL')) THEN
              cep_standard.debug('EXECUTING secondary_match For Invoice');
                match_line('I');
          END IF;
        -- Bug 9434957 End

	 --FOR SEPA ER 6700007 START
	IF (CE_AUTO_BANK_MATCH.csl_match_found IN ('ERROR','NONE','PARTIAL') AND
	   CE_AUTO_BANK_MATCH.csl_trx_type IN ('DEBIT', 'STOP')  AND
	   Tertiary_match IS NOT NULL) THEN

	    cep_standard.debug('EXECUTING  Tertiary_match ');

             match_line(Tertiary_match);

        END IF;
         --FOR SEPA ER 6700007 END
      END IF;

      -- bug 4914608 set the org after a match for AR/AP
      cep_standard.debug('CE_AUTO_BANK_MATCH.trx_org_id =' ||CE_AUTO_BANK_MATCH.trx_org_id);
      if (CE_AUTO_BANK_MATCH.csl_match_found = 'FULL')  THEN
        set_single_org(CE_AUTO_BANK_MATCH.trx_org_id);
      END IF;

      -- moved from match_process
      -- bug 1796965
      SELECT count(*)
      INTO	accounting_method_found
      FROM	ar_system_parameters s
      where s.org_id = nvl(CE_AUTO_BANK_REC.G_org_id,CE_AUTO_BANK_MATCH.trx_org_id);

      if (accounting_method_found = 1) then
        SELECT accounting_method
        INTO   CE_AUTO_BANK_MATCH.ar_accounting_method
        FROM   ar_system_parameters s
        where s.org_id = nvl(CE_AUTO_BANK_REC.G_org_id,CE_AUTO_BANK_MATCH.trx_org_id);
      else
        CE_AUTO_BANK_MATCH.ar_accounting_method := NULL;
      end if;
      cep_standard.debug('CE_AUTO_BANK_MATCH.ar_accounting_method =' ||CE_AUTO_BANK_MATCH.ar_accounting_method);

      --
      -- Bug 928060: Create a misc receipt for NSF line with tolerance.
      --
      if (CE_AUTO_BANK_MATCH.csl_match_found = 'FULL' and
  	CE_AUTO_BANK_MATCH.csl_trx_type = 'NSF' and
  	(CE_AUTO_BANK_MATCH.trx_amount <>
  	CE_AUTO_BANK_MATCH.calc_csl_amount)) then

	begin
	  select 'Y'
	  into   misc_exists
	  --from   ce_222_transactions_v
          from   ce_available_transactions_tmp
	  where  trx_number = CE_AUTO_BANK_MATCH.csl_bank_trx_number || '/NSF'
	  and    trx_type = 'MISC'
          and    rownum = 1
          and    application_id = 222
          and    reconciled_status_flag = 'N';
        exception
	  when no_data_found then
	    misc_exists := 'N';
	  when others then
	    misc_exists := 'N';
	end;

	IF (misc_exists = 'N') THEN
	  if (nvl(CE_AUTO_BANK_MATCH.csl_receipt_method_id,
	      CE_AUTO_BANK_REC.G_payment_method_id) is null OR
	      nvl(CE_AUTO_BANK_MATCH.csl_receivables_trx_id,
	      CE_AUTO_BANK_REC.G_receivables_trx_id) is null) then
	    cep_standard.debug('No receipt method or receivable activity info.');
	    CE_AUTO_BANK_MATCH.nsf_info_flag := 'Y';
	  else
	    cep_standard.debug('Create a misc receipt for NSF line with tolerance.');
	    declare
	      p_cr_id ar_cash_receipts.cash_receipt_id%TYPE;
	    begin

	      --
	      -- bug# 1180124
	      -- If exchange type is pre-defined rate type, populate the
	      -- exchange rate
	      --
	      -- bug 2293491
              IF ((CE_AUTO_BANK_MATCH.csl_exchange_rate_type is null and
			CE_AUTO_BANK_MATCH.csl_exchange_rate_date is null and
			CE_AUTO_BANK_MATCH.csl_exchange_rate is null) OR
			(CE_AUTO_BANK_MATCH.csl_exchange_rate_type <> 'User' and
			CE_AUTO_BANK_MATCH.csl_exchange_rate IS NULL)) THEN
		IF (NOT validate_exchange_details) THEN
		  cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.trx_validation' );
		END IF;
	      END IF;

	      --
	      -- bug# 939160
	      -- Verified that exchange information is not null
	      --    when creating foreign currency misc receipts
	      --
	      IF (CE_AUTO_BANK_MATCH.aba_bank_currency <>
		  CE_AUTO_BANK_REC.G_functional_currency
		  AND CE_AUTO_BANK_MATCH.csl_create_misc_trx_flag = 'Y'
		  AND (CE_AUTO_BANK_MATCH.csl_exchange_rate_date IS NULL
		  OR CE_AUTO_BANK_MATCH.csl_exchange_rate_type IS NULL
		  OR CE_AUTO_BANK_MATCH.csl_exchange_rate IS NULL) ) THEN
		CE_RECONCILIATION_ERRORS_PKG.insert_row(
		    CE_AUTO_BANK_MATCH.csh_statement_header_id,
		    CE_AUTO_BANK_MATCH.csl_statement_line_id,
		    'CE_REQUIRED_EXCHANGE_FIELD');
	      ELSE
 	        --
 	        -- bug# 1190376
 	        -- Make sure the amount is converted to foreign curr
 	        -- and the decimal is rounded correctly
 	        --
 	        IF (CE_AUTO_BANK_MATCH.csl_exchange_rate IS NULL
		    OR CE_AUTO_BANK_MATCH.trx_currency_type = 'BANK') THEN
		  receipt_amount := CE_AUTO_BANK_MATCH.trx_amount -
			CE_AUTO_BANK_MATCH.calc_csl_amount;
		  base_receipt_amount := receipt_amount;
		ELSIF (CE_AUTO_BANK_MATCH.csl_exchange_rate_type <> 'User') THEN
		  BEGIN
		    receipt_amount := gl_currency_api.convert_amount(
			CE_AUTO_BANK_REC.G_functional_currency,
			CE_AUTO_BANK_MATCH.csl_currency_code,
			nvl(CE_AUTO_BANK_MATCH.csl_exchange_rate_date,
			CE_AUTO_BANK_MATCH.csl_trx_date),
			CE_AUTO_BANK_MATCH.csl_exchange_rate_type,
			(CE_AUTO_BANK_MATCH.trx_amount
			- CE_AUTO_BANK_MATCH.calc_csl_amount));
		  EXCEPTION
		    WHEN OTHERS THEN
		      cep_standard.debug('EXCEPTION: Could not convert amount');
		      receipt_amount := NULL;
		  END;

		  base_receipt_amount := convert_to_base_curr(receipt_amount);

		ELSE -- foreign curr type = 'User'
		  receipt_amount := (CE_AUTO_BANK_MATCH.trx_amount
		      - CE_AUTO_BANK_MATCH.calc_csl_amount) *
		      (1/CE_AUTO_BANK_MATCH.csl_exchange_rate);
		  fnd_currency.get_info(CE_AUTO_BANK_MATCH.aba_bank_currency,
		      precision, ext_precision, min_acct_unit);
		  receipt_amount := round(receipt_amount,precision);
		  base_receipt_amount := convert_to_base_curr(receipt_amount);
		END IF;

		/* This is to populate cleared amount properly. */
		CE_AUTO_BANK_MATCH.calc_csl_amount :=
		    CE_AUTO_BANK_MATCH.trx_amount;

		if (CE_AUTO_BANK_MATCH.ar_accounting_method = 'ACCRUAL') then
		  CE_AUTO_BANK_MATCH.get_vat_tax_id('AUTO_NSF',
		      l_vat_tax_id, l_tax_rate);
		end if;

		--Bug 4260337 Validate payment method for end date
		IF NOT(VALIDATE_PAYMENT_METHOD)  THEN
			CE_RECONCILIATION_ERRORS_PKG.insert_row(CE_AUTO_BANK_MATCH.csh_statement_header_id,
				CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_PAYMENT_METHOD');
		ELSE

                  cep_standard.debug('CE_AUTO_BANK_MATCH.csl_receivables_trx_id= '||
						CE_AUTO_BANK_MATCH.csl_receivables_trx_id);

		  -- bug 5185358  not able to create misc receipt
		  get_receivables_org_id(receivables_trx_org_id);
		  CE_AUTO_BANK_MATCH.trx_org_id := receivables_trx_org_id;

		  cep_standard.debug('receivables_trx_org_id= '|| receivables_trx_org_id);

		  set_single_org(receivables_trx_org_id);

		  select mo_global.GET_CURRENT_ORG_ID
		  into current_org_id
		  from dual;

		  cep_standard.debug('current_org_id =' ||current_org_id );


  		  cep_standard.debug('match_engine: >> CE_AUTO_BANK_CLEAR.misc_receipt');

		  CE_AUTO_BANK_CLEAR.misc_receipt(
			X_passin_mode => 'AUTO_TRX',
			X_trx_number  =>
			    CE_AUTO_BANK_MATCH.csl_bank_trx_number || '/NSF',
			X_doc_sequence_value => NULL,
			X_doc_sequence_id   => to_number(NULL),
			X_gl_date => CE_AUTO_BANK_REC.G_gl_date,
			X_value_date => CE_AUTO_BANK_MATCH.csl_effective_date,
			X_trx_date  => CE_AUTO_BANK_MATCH.csl_trx_date,
			X_deposit_date =>  CE_AUTO_BANK_MATCH.csl_trx_date,
			X_amount => receipt_amount,
			X_bank_account_amount => base_receipt_amount,
			X_set_of_books_id => CE_AUTO_BANK_REC.G_set_of_books_id,
			X_misc_currency_code =>
			    NVL(CE_AUTO_BANK_MATCH.csl_currency_code,
			    CE_AUTO_BANK_MATCH.aba_bank_currency),
		 	X_exchange_rate_date  =>
			    CE_AUTO_BANK_MATCH.csl_exchange_rate_date,
			X_exchange_rate_type =>
			    CE_AUTO_BANK_MATCH.csl_exchange_rate_type,
			X_exchange_rate       =>
			    CE_AUTO_BANK_MATCH.csl_exchange_rate,
			X_receipt_method_id   =>
			    nvl(CE_AUTO_BANK_MATCH.csl_receipt_method_id,
				CE_AUTO_BANK_REC.G_payment_method_id),
			X_bank_account_id =>
			    CE_AUTO_BANK_MATCH.csh_bank_account_id,
			X_activity_type_id   =>
			    nvl(CE_AUTO_BANK_MATCH.csl_receivables_trx_id,
				CE_AUTO_BANK_REC.G_receivables_trx_id),
			X_comments            => 'Created by Auto Bank Rec',
			X_reference_type      => NULL,
			X_reference_id        => to_number(NULL),
			X_clear_currency_code => NULL,
			X_statement_line_id   => X_statement_line_id,
			X_tax_id              => l_vat_tax_id,
			X_tax_rate	      => l_tax_rate,
			X_paid_from           => NULL,
			X_module_name         => 'CE_AUTO_BANK_REC',
			X_cr_vat_tax_id  => CE_AUTO_BANK_REC.G_cr_vat_tax_code,
			X_dr_vat_tax_id  => CE_AUTO_BANK_REC.G_dr_vat_tax_code,
			trx_currency_type =>
			    CE_AUTO_BANK_MATCH.trx_currency_type,
			X_cr_id               => p_cr_id,
			X_effective_date      =>
			    CE_AUTO_BANK_MATCH.csl_effective_date,
			X_org_id      =>
			    nvl(CE_AUTO_BANK_MATCH.trx_org_id,CE_AUTO_BANK_REC.G_org_id));
			    --CE_AUTO_BANK_MATCH.bau_org_id);

  		  cep_standard.debug('end match_engine: >> CE_AUTO_BANK_CLEAR.misc_receipt');
 		  cep_standard.debug('p_cr_id = '|| p_cr_id);

		cep_standard.debug('Create a misc receipt with cash_receipt_id='|| to_char(p_cr_id));
		END IF; --validate payment method
	      END IF; -- if not creating foreign misc receipts with null exchange info

	    exception
	      when others then
		cep_standard.debug('Error in CE_AUTO_BANK_CLEAR.misc_receipt');
		raise;
	    end;
	  end if;

	ELSE	/* misc_exists = 'Y' */
	  cep_standard.debug('Exist a misc receipt with trx number <'||
	      CE_AUTO_BANK_MATCH.csl_bank_trx_number || '/NSF>.');
	END IF;
      end if;

    --
    --  If the transaction type is miscellaneous, try and match the
    --  statement line to a miscellaneous receipt. If the bank trx number
    --  is provided.
    --
    ELSIF CE_AUTO_BANK_MATCH.csl_trx_type IN ('MISC_CREDIT', 'MISC_DEBIT') THEN
      IF CE_AUTO_BANK_MATCH.csl_bank_trx_number IS NOT NULL
	  --and CE_AUTO_BANK_MATCH.csl_create_misc_trx_flag <> 'Y') --bug 4542114
	  or
	  (CE_AUTO_BANK_MATCH.csl_invoice_text IS NOT NULL and
	  (CE_AUTO_BANK_MATCH.csl_bank_account_text IS NOT NULL or
	  CE_AUTO_BANK_MATCH.csl_customer_text IS NOT NULL)) THEN

	-- Changes for Release 11.
	-- Check if the misc statement line is to match against statement line
	-- and/or transaction.
	if (CE_AUTO_BANK_MATCH.csl_matching_against = 'MISC') then
	  primary_match := 'T';
	  secondary_match := NULL;
	elsif (CE_AUTO_BANK_MATCH.csl_matching_against = 'STMT') then
	  primary_match := 'S';
	  secondary_match := NULL;
	elsif (CE_AUTO_BANK_MATCH.csl_matching_against = 'MS') then
	  primary_match := 'T';
	  secondary_match := 'S';
	else   /* CE_AUTO_BANK_MATCH.csl_matching_against = 'SM' */
	  primary_match := 'S';
	  secondary_match := 'T';
	end if;

	match_line(primary_match);
	cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.csl_match_found = '||
	    CE_AUTO_BANK_MATCH.csl_match_found);
	cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.csl_reconcile_flag = '||
	    CE_AUTO_BANK_MATCH.csl_reconcile_flag);
	cep_standard.debug('DEBUG: secondary_match = '|| secondary_match);
	if (CE_AUTO_BANK_MATCH.csl_match_found IN ('ERROR','NONE','PARTIAL') AND
	    nvl(CE_AUTO_BANK_MATCH.csl_reconcile_flag,'NONE')
	    NOT IN ('JE', 'OI') AND secondary_match IS NOT NULL) then
	  match_line(secondary_match);
	end if;


cep_standard.debug('CE_AUTO_BANK_MATCH.csl_match_found - '|| CE_AUTO_BANK_MATCH.csl_match_found);
cep_standard.debug('CE_AUTO_BANK_MATCH.csl_reconcile_flag - '|| CE_AUTO_BANK_MATCH.csl_reconcile_flag);
cep_standard.debug('CE_AUTO_BANK_MATCH.csl_matching_against - '|| CE_AUTO_BANK_MATCH.csl_matching_against);
cep_standard.debug('CE_AUTO_BANK_MATCH.csl_create_misc_trx_flag -  '|| CE_AUTO_BANK_MATCH.csl_create_misc_trx_flag );
cep_standard.debug('CE_AUTO_BANK_MATCH.csl_bank_trx_number - '|| CE_AUTO_BANK_MATCH.csl_bank_trx_number);
cep_standard.debug('CE_AUTO_BANK_MATCH.csl_invoice_text - '|| CE_AUTO_BANK_MATCH.csl_invoice_text);
cep_standard.debug('CE_AUTO_BANK_MATCH.csl_bank_account_text - '|| CE_AUTO_BANK_MATCH.csl_bank_account_text);
cep_standard.debug('CE_AUTO_BANK_MATCH.csl_customer_text - '|| CE_AUTO_BANK_MATCH.csl_customer_text);

	-- bug 4542114  If there is no match, then create the misc receipt
        /* bug 	6049035  If there is no match with  and data is available in "Customer name" or "account number" and also the
           invoice field in the Bank Statement lines window, then create the misc receipt */

	if (CE_AUTO_BANK_MATCH.csl_match_found IN ('ERROR','NONE','PARTIAL') AND
	    nvl(CE_AUTO_BANK_MATCH.csl_reconcile_flag,'NONE') NOT IN ('JE', 'OI')  AND
	    CE_AUTO_BANK_MATCH.csl_matching_against <> 'STMT'  AND
	    CE_AUTO_BANK_MATCH.csl_create_misc_trx_flag = 'Y'  AND
	      (CE_AUTO_BANK_MATCH.csl_bank_trx_number IS NOT NULL  or
		  (CE_AUTO_BANK_MATCH.csl_invoice_text IS NOT NULL and
		  (CE_AUTO_BANK_MATCH.csl_bank_account_text IS NOT NULL or
		   CE_AUTO_BANK_MATCH.csl_customer_text IS NOT NULL))))	then

	   cep_standard.debug('calling create_misc_trx ');
  	   create_misc_trx;
	end if;

      ELSE

	-- bug 4542114
	create_misc_trx;

      END IF;   -- CE_AUTO_BANK_MATCH.csl_bank_trx_number not is null

      CE_AUTO_BANK_MATCH.trx_match_type := CE_AUTO_BANK_MATCH.csl_match_type;
      IF (CE_AUTO_BANK_MATCH.csl_match_found = 'FULL') THEN
	CE_AUTO_BANK_MATCH.csl_match_type := 'MISC';
      ELSE
	CE_AUTO_BANK_MATCH.csl_match_type := 'NONE';
	--CE_RECONCILIATION_ERRORS_PKG.insert_row(CE_AUTO_BANK_MATCH.csh_statement_header_id,
	--CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_DR_NOT_FOUND');
      END IF;
    END IF; -- End main IF statement -- CE_AUTO_BANK_MATCH.csl_reconcile_flag = 'OI'
  END IF; -- Forex

  cep_standard.debug('<<CE_AUTO_BANK_MATCH.match_engine');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    cep_standard.debug('info missing');
    CE_RECONCILIATION_ERRORS_PKG.insert_row(
	   CE_AUTO_BANK_MATCH.csh_statement_header_id,
	   CE_AUTO_BANK_MATCH.csl_statement_line_id, 'CE_ABR_INFO_MISSING');
  WHEN app_exception.application_exception THEN
    cep_standard.debug('EXCEPTION:CE_AUTO_BANK_MATCH.match_engine-application_exception' );
    l_encoded_message := FND_MESSAGE.GET_ENCODED;
    IF (l_encoded_message IS NOT NULL) THEN
      cep_standard.debug('Encoded message is: ' ||l_encoded_message);
      FND_MESSAGE.parse_encoded(l_encoded_message,l_app_short_name,
				l_message_name);
    ELSE
      cep_standard.debug('No messages on stack');
      l_message_name := 'OTHER_APP_ERROR';
    END IF;
    CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id, l_message_name,
	l_app_short_name);
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.match_engine' );
    RAISE;
END match_engine;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	lock_statement 							|
|									|
|  DESCRIPTION								|
|	Using the rowid, lock the statement regular way			|
|									|
|  CALLED BY								|
|	match_process							|
|									|
|  REQUIRES								|
|	lockhandle							|
 --------------------------------------------------------------------- */
FUNCTION lock_statement(lockhandle IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
  x_statement_header_id	CE_STATEMENT_HEADERS.statement_header_id%TYPE;
  lock_status		NUMBER;
  expiration_secs	NUMBER;
  lockname		VARCHAR2(128);
  lockmode		NUMBER;
  timeout		NUMBER;
  release_on_commit	BOOLEAN;
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.lock_statement');

  SELECT  statement_header_id
  INTO    x_statement_header_id
  FROM    ce_statement_headers
  WHERE   rowid = CE_AUTO_BANK_MATCH.csh_rowid
  FOR UPDATE OF statement_header_id NOWAIT;

  cep_standard.debug('>>CE_AUTO_BANK_MATCH.Regular statement lock OK');
  lockname := CE_AUTO_BANK_MATCH.csh_rowid;
  timeout  := 1;
  lockmode := 6;
  expiration_secs  := 10;
  release_on_commit := FALSE;
  --
  -- dbms_lock of row to deal with other locking
  --
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.Allocating unique');
  dbms_lock.allocate_unique (lockname, lockhandle, expiration_secs);
  lock_status := dbms_lock.request( lockhandle, lockmode, timeout,
				    release_on_commit );
  IF (lock_status <> 0) THEN
    lock_status := dbms_lock.release(lockhandle);
    RAISE APP_EXCEPTIONS.record_lock_exception;
  END IF;
  cep_standard.debug('<<CE_AUTO_BANK_MATCH.lock_statement');
  RETURN(TRUE);
EXCEPTION
  WHEN APP_EXCEPTIONS.record_lock_exception THEN
    return(FALSE);
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.lock_statement' );
    RAISE;
    return(FALSE);
END lock_statement;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	lock_statement_line						|
|									|
|  DESCRIPTION								|
|	Using the rowid, retrieve the statement line details.		|
|									|
|  CALLED BY								|
|	match_process							|
 --------------------------------------------------------------------- */
FUNCTION lock_statement_line RETURN BOOLEAN IS
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.lock_statement_line');
  SELECT  statement_line_id,
	  trx_date,
	  trx_type,
	  trx_code_id,
	  bank_trx_number,
	  invoice_text,
	  bank_account_text,
	  amount,
	  NVL(charges_amount,0),
	  currency_code,
	  line_number,
	  customer_text,
	  effective_date,
	  original_amount
  INTO    CE_AUTO_BANK_MATCH.csl_statement_line_id,
	  CE_AUTO_BANK_MATCH.csl_trx_date,
	  CE_AUTO_BANK_MATCH.csl_trx_type,
	  CE_AUTO_BANK_MATCH.csl_trx_code_id,
	  CE_AUTO_BANK_MATCH.csl_bank_trx_number,
	  CE_AUTO_BANK_MATCH.csl_invoice_text,
	  CE_AUTO_BANK_MATCH.csl_bank_account_text,
	  CE_AUTO_BANK_MATCH.csl_amount,
	  CE_AUTO_BANK_MATCH.csl_charges_amount,
	  CE_AUTO_BANK_MATCH.csl_currency_code,
	  CE_AUTO_BANK_MATCH.csl_line_number,
	  CE_AUTO_BANK_MATCH.csl_customer_text,
	  CE_AUTO_BANK_MATCH.csl_effective_date,
	  CE_AUTO_BANK_MATCH.csl_original_amount
  FROM    ce_statement_lines
  WHERE   rowid = CE_AUTO_BANK_MATCH.csl_rowid
  FOR UPDATE OF status NOWAIT;

  cep_standard.debug('CE_AUTO_BANK_MATCH.csl_trx_type='||CE_AUTO_BANK_MATCH.csl_trx_type||
			', csl_currency_code=' || csl_currency_code ||
			', csl_bank_trx_number='||csl_bank_trx_number );
  cep_standard.debug('csl_customer_text='||csl_customer_text ||
			', csl_invoice_text='|| csl_invoice_text||
			', csl_bank_account_text='||csl_bank_account_text);
  cep_standard.debug('csl_amount='||csl_amount ||
			', csl_charges_amount='||csl_charges_amount||
			', csl_original_amount='||csl_original_amount);

  cep_standard.debug('<<CE_AUTO_BANK_MATCH.lock_statement_line');
  RETURN(TRUE);

EXCEPTION
  WHEN APP_EXCEPTIONS.record_lock_exception THEN
    return(FALSE);
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.lock_statement_line' );
    RAISE;
    return(FALSE);
END lock_statement_line;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	update_gl_date							|
|									|
|  DESCRIPTION								|
|	Update the gl posting date on ce_statement_headers to the new 	|
|	one for	this run.						|
|									|
|  CALLED BY								|
|	match_process							|
 --------------------------------------------------------------------- */
PROCEDURE update_gl_date IS
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.update_gl_date');
  IF ((CE_AUTO_BANK_REC.find_gl_period(CE_AUTO_BANK_REC.G_gl_date, 200)) OR
     (CE_AUTO_BANK_REC.find_gl_period(CE_AUTO_BANK_REC.G_gl_date, 222))) THEN
    UPDATE ce_statement_headers
    SET    gl_date = CE_AUTO_BANK_REC.G_gl_date
    WHERE  rowid = CE_AUTO_BANK_MATCH.csh_rowid;
  END IF;
  cep_standard.debug('<<CE_AUTO_BANK_MATCH.update_gl_date');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.update_gl_date' );
    RAISE;
END update_gl_date;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	find_le_sys_par							|
|									|
|  DESCRIPTION								|
|	Need to get legal entity system parameters values for		|
|       Open Interface transactions
|									|
|  CALLED BY								|
|									|
 --------------------------------------------------------------------- */
/*
PROCEDURE find_le_sys_par(x_bank_account_id	number) IS

BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.find_le_sys_par x_bank_account_id'|| x_bank_account_id);
 -- populate ce_security_profiles_tmp table with ce_security_procfiles_v
 CEP_STANDARD.init_security;

  IF (x_bank_account_id is not null)
	select ACCOUNT_OWNER_ORG_ID
	into p_le_id
	from ce_bank_accts_gt_v  --ce_BANK_ACCOUNTS_v
	where BANK_ACCOUNT_ID = x_bank_account_id;

	select   AMOUNT_TOLERANCE_OLD,
		 PERCENT_TOLERANCE_OLD,
		 OI_FLOAT_STATUS_OLD,
		 OI_CLEAR_STATUS_OLD,
		 FLOAT_HANDLING_FLAG_OLD,
		 SHOW_VOID_PAYMENT_FLAG,
		 OI_MATCHING_CODE_OLD
	FROM CE_SYSTEM_PARAMETERS;

  END IF;
  cep_standard.debug('<<CE_AUTO_BANK_MATCH.find_le_sys_par');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.find_le_sys_par' );
    RAISE;
END find_le_sys_par;
*/

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	calc_actual_tolerance						|
|									|
|  DESCRIPTION								|
|	Calculate the tolerance range from the percentage tolerance and	|
|	the amount tolerance.						|
|       In rel 11i - tolerance amount is in Functional currency		|
|	In rel 12 - tolerance amount is in Bank Account currency (bug 4969806)
|									|
|  CALLED BY								|
|	match_process							|
 --------------------------------------------------------------------- */
PROCEDURE calc_actual_tolerance IS
  calc_percent_tolerance     	NUMBER;
  calc_amount_tolerance		NUMBER;
  calc_charges_amount		NUMBER;
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.calc_actual_tolerance');
  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.trx_currency_type = '||
		CE_AUTO_BANK_MATCH.trx_currency_type);

  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.corr_csl_amount = '||
		CE_AUTO_BANK_MATCH.corr_csl_amount);

  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance = '||
		CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance ||
		', CE_AUTO_BANK_MATCH.ba_ap_percent_tolerance = '||
		CE_AUTO_BANK_MATCH.ba_ap_percent_tolerance);

  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance = '||
		CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance ||
		', CE_AUTO_BANK_MATCH.ba_ar_percent_tolerance = '||
		CE_AUTO_BANK_MATCH.ba_ar_percent_tolerance);

  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.ba_ce_amount_tolerance = '||
		CE_AUTO_BANK_MATCH.ba_ce_amount_tolerance ||
		', CE_AUTO_BANK_MATCH.ba_ce_percent_tolerance = '||
		CE_AUTO_BANK_MATCH.ba_ce_percent_tolerance);

 cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.BA_RECON_OI_AMOUNT_TOLERANCE = '||
		CE_AUTO_BANK_MATCH.BA_RECON_OI_AMOUNT_TOLERANCE ||
		', CE_AUTO_BANK_MATCH.BA_RECON_OI_PERCENT_TOLERANCE = '||
		CE_AUTO_BANK_MATCH.BA_RECON_OI_PERCENT_TOLERANCE);

  cep_standard.debug('DEBUG: CE_AUTO_BANK_MATCH.csl_clearing_trx_type = '||
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type);

  CE_AUTO_BANK_MATCH.tolerance_amount := 0;
  IF (CE_AUTO_BANK_MATCH.csl_trx_type IN ('REJECTED', 'STOP')
      OR (CE_AUTO_BANK_MATCH.csl_clearing_trx_type in ('ROI_LINE', 'XTR_LINE')
	AND CE_AUTO_BANK_REC.G_open_interface_matching_code = 'D')) THEN
    CE_AUTO_BANK_MATCH.tolerance_amount := 0;
  ELSE
    --
    -- Amount tolerance
    -- bug 3676745 MO/BA uptake
    -- AP/AR transactions - get tolerance amount in the following order (per Amrita)
    -- 1) tolerances defined at the bank account level
    -- 2) tolerances defined at the system parameters level for the OU for which the transactions
    --   	are being reconciled
    -- 3) if none exist then the tolerance is zero.
    -- No tolerance for PAY, PAY_EFT, JE_LINE, STATEMENT transactions
    -- ROI_LINE -LE???

    -- bug 4914608 no more tolerance at system parameters level, always get tolerance at bank account level
    -- bug 4969806  tolerance amount is in Bank Account currency,
    --              do not need to convert tolerance amount
    IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('PAYMENT')) THEN
      calc_amount_tolerance := CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance ;
    ELSIF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('CASH', 'MISC')) THEN
        calc_amount_tolerance := CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance;
    ELSIF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('CASHFLOW')) THEN
      calc_amount_tolerance := CE_AUTO_BANK_MATCH.ba_ce_amount_tolerance;
    ELSIF  (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('ROI_LINE')) THEN
      calc_amount_tolerance := CE_AUTO_BANK_MATCH.BA_RECON_OI_AMOUNT_TOLERANCE;
    ELSE
      calc_amount_tolerance := 0;
    END IF;


/*
    IF (CE_AUTO_BANK_MATCH.trx_currency_type = 'BANK') THEN
      IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('PAYMENT')) THEN
        IF (nvl(CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance,0) <> 0) THEN
	  calc_amount_tolerance := convert_amount_tolerance(CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance);
        ELSE
	  calc_amount_tolerance := 0;
        END IF;
      ELSIF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('CASH','MISC')) THEN
        IF (nvl(CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance,0) <> 0) THEN
	  calc_amount_tolerance := convert_amount_tolerance(CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance);
        ELSE
	  calc_amount_tolerance := 0;
        END IF;
      ELSIF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('CASHFLOW')) THEN --bug 4435028
        IF (nvl(CE_AUTO_BANK_MATCH.ba_ce_amount_tolerance,0) <> 0) THEN
	  calc_amount_tolerance := convert_amount_tolerance(CE_AUTO_BANK_MATCH.ba_ce_amount_tolerance);
        ELSE
	  calc_amount_tolerance := 0;
        END IF;
      ELSE -- (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('ROI_LINE')) THEN
        IF (NVL(CE_AUTO_BANK_MATCH.BA_RECON_OI_AMOUNT_TOLERANCE,0) <> 0) THEN
	  calc_amount_tolerance :=
	     convert_amount_tolerance(CE_AUTO_BANK_MATCH.BA_RECON_OI_AMOUNT_TOLERANCE);
        ELSE
	  calc_amount_tolerance := 0;
        END IF;
      END IF;

    ELSIF (CE_AUTO_BANK_MATCH.trx_currency_type IN
	('FUNCTIONAL','FOREIGN')) THEN
      IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('PAYMENT')) THEN
        calc_amount_tolerance := CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance ;
      ELSIF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('CASH', 'MISC')) THEN
        calc_amount_tolerance := CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance;
      ELSIF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('CASHFLOW')) THEN
        calc_amount_tolerance := CE_AUTO_BANK_MATCH.ba_ce_amount_tolerance;
      ELSE -- (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('ROI_LINE')) THEN
        calc_amount_tolerance := CE_AUTO_BANK_MATCH.BA_RECON_OI_AMOUNT_TOLERANCE;
      END IF;
    END IF;
*/

    --
    -- Percent tolerance
    --
    if (CE_AUTO_BANK_MATCH.csl_match_correction_type IN
	('REVERSAL', 'ADJUSTMENT')) then
      IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('PAYMENT')) THEN
        calc_percent_tolerance := CE_AUTO_BANK_MATCH.corr_csl_amount *
	  (CE_AUTO_BANK_MATCH.ba_ap_percent_tolerance / 100);
      ELSIF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('CASH', 'MISC')) THEN
        calc_percent_tolerance := CE_AUTO_BANK_MATCH.corr_csl_amount *
	  (CE_AUTO_BANK_MATCH.ba_ar_percent_tolerance / 100);
      ELSIF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('CASHFLOW')) THEN
        calc_percent_tolerance := CE_AUTO_BANK_MATCH.corr_csl_amount *
	  (CE_AUTO_BANK_MATCH.ba_ce_percent_tolerance / 100);
      ELSE
        calc_percent_tolerance := CE_AUTO_BANK_MATCH.corr_csl_amount *
	  (CE_AUTO_BANK_MATCH.BA_RECON_OI_PERCENT_TOLERANCE / 100);
      END IF;
    else
      IF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('PAYMENT')) THEN
        calc_percent_tolerance := CE_AUTO_BANK_MATCH.csl_amount *
	  (CE_AUTO_BANK_MATCH.ba_ap_percent_tolerance / 100);
      ELSIF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('CASH', 'MISC')) THEN
        calc_percent_tolerance := CE_AUTO_BANK_MATCH.csl_amount *
	  (CE_AUTO_BANK_MATCH.ba_ar_percent_tolerance / 100);
      ELSIF (CE_AUTO_BANK_MATCH.csl_clearing_trx_type IN ('CASHFLOW')) THEN  --bug 4435028
        calc_percent_tolerance := CE_AUTO_BANK_MATCH.csl_amount *
	  (CE_AUTO_BANK_MATCH.ba_ce_percent_tolerance / 100);
      ELSE
        calc_percent_tolerance := CE_AUTO_BANK_MATCH.csl_amount *
	  (CE_AUTO_BANK_MATCH.BA_RECON_OI_PERCENT_TOLERANCE / 100);
      END IF;
    end if;

    cep_standard.debug('%calc_amount_tolerance: '||calc_amount_tolerance);
    cep_standard.debug('%calc_percent_tolerance: '||calc_percent_tolerance);

    if (calc_percent_tolerance < 0) then
      calc_percent_tolerance := calc_percent_tolerance * -1;
    end if;
    --
    -- Comparison
    --
    cep_standard.debug('calc_amount_tolerance: '||calc_amount_tolerance);
    cep_standard.debug('calc_percent_tolerance: '||calc_percent_tolerance);
    IF (calc_amount_tolerance = 0) THEN
      CE_AUTO_BANK_MATCH.tolerance_amount := calc_percent_tolerance;
    ELSIF (calc_percent_tolerance = 0) THEN
      CE_AUTO_BANK_MATCH.tolerance_amount := calc_amount_tolerance;
    ELSE
      IF (calc_percent_tolerance > calc_amount_tolerance) THEN
	CE_AUTO_BANK_MATCH.tolerance_amount := calc_amount_tolerance;
      ELSE
	CE_AUTO_BANK_MATCH.tolerance_amount := calc_percent_tolerance;
      END IF;
    END IF;
  END IF;
  cep_standard.debug('<<CE_AUTO_BANK_MATCH.calc_actual_tolerance');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.calc_actual_tolerance' );
    RAISE;
END calc_actual_tolerance;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	convert_amount_tolerance					|
|									|
|  DESCRIPTION								|
|	If the bank account currency is not the same as the functional	|
|	currency, convert the tolerance amount into the bank currency.	|
|									|
|  CALLED BY								|
|	calc_actual_tolerance						|
 --------------------------------------------------------------------- */
FUNCTION convert_amount_tolerance (amount_to_convert NUMBER)  RETURN NUMBER IS
  precision		NUMBER;
  ext_precision		NUMBER;
  min_acct_unit		NUMBER;
  acctd_amount		NUMBER;
  rounded_amount	NUMBER;
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.convert_amount_tolerance');

  IF (CE_AUTO_BANK_MATCH.csl_exchange_rate_type <> 'User') THEN

    BEGIN
    --bug 4452153 exchanged the currency code parameters
      acctd_amount := gl_currency_api.convert_amount(
		CE_AUTO_BANK_REC.G_functional_currency,
		CE_AUTO_BANK_MATCH.csl_currency_code,
		nvl(CE_AUTO_BANK_MATCH.csl_exchange_rate_date,
		    CE_AUTO_BANK_MATCH.csl_trx_date),
		CE_AUTO_BANK_MATCH.csl_exchange_rate_type,
		amount_to_convert);
    EXCEPTION
      WHEN OTHERS THEN
	cep_standard.debug('EXCEPTION: Could not convert amount');
	acctd_amount := NULL;
    END;

    rounded_amount := acctd_amount;
    cep_standard.debug('convert_amount_tolerance: rounded_amount: '||
	acctd_amount);

  ELSE

    acctd_amount := amount_to_convert / CE_AUTO_BANK_MATCH.csl_exchange_rate;
    fnd_currency.get_info(CE_AUTO_BANK_MATCH.aba_bank_currency, precision,
	ext_precision, min_acct_unit);
    IF min_acct_unit IS NOT NULL THEN
      rounded_amount := round(acctd_amount/min_acct_unit,0) * min_acct_unit;
    ELSE
      rounded_amount := round(acctd_amount,precision);
    END IF;

  END IF;

  cep_standard.debug('<<CE_AUTO_BANK_MATCH.convert_amount_tolerance');
  RETURN(rounded_amount);

EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.convert_amount_tolerance');
    RAISE;
END convert_amount_tolerance;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	validate_payment_method						|
|									|
|  DESCRIPTION								|
|	To create a miscellaneous transaction, a valid payment method	|
|	must be provided by the user.  Payment methods are valid for	|
|	bank accounts.							|
|									|
|  CALLED BY								|
|	match_engine, trx_validation, create_misc_trx
|									|
|  RETURNS								|
|	valid_method		TRUE / FALSE				|
 --------------------------------------------------------------------- */
FUNCTION validate_payment_method RETURN BOOLEAN IS
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.validate_payment_method_id');
  cep_standard.debug('CE_AUTO_BANK_MATCH.csl_receipt_method_id '|| CE_AUTO_BANK_MATCH.csl_receipt_method_id);
  cep_standard.debug('CE_AUTO_BANK_MATCH.trx_org_id '|| CE_AUTO_BANK_MATCH.trx_org_id);

  SELECT arm.name
  INTO   CE_AUTO_BANK_REC.G_payment_method_name
  FROM   ar_receipt_method_accounts arma,
	 ar_receipt_methods arm
  WHERE  arm.receipt_method_id = arma.receipt_method_id
  --AND    arma.REMIT_BANK_ACCT_USE_ID = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
  AND    arma.REMIT_BANK_ACCT_USE_ID = nvl(CE_AUTO_BANK_MATCH.trx_bank_acct_use_id, arma.REMIT_BANK_ACCT_USE_ID)
  --AND    arma.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
  --AND	 arma.org_id = CE_AUTO_BANK_MATCH.bau_org_id
  AND	 arma.org_id = nvl(CE_AUTO_BANK_MATCH.trx_org_id,  nvl(CE_AUTO_BANK_REC.G_org_id, arma.org_id))
  --AND    arm.receipt_method_id = nvl(CE_AUTO_BANK_REC.G_payment_method_id,CE_AUTO_BANK_MATCH.csl_receipt_method_id)
  AND    arm.receipt_method_id = nvl(CE_AUTO_BANK_MATCH.csl_receipt_method_id, CE_AUTO_BANK_REC.G_payment_method_id)
  AND    CE_AUTO_BANK_MATCH.csl_trx_date between nvl(arm.start_date,CE_AUTO_BANK_MATCH.csl_trx_date)
  AND    nvl(arm.end_date,CE_AUTO_BANK_MATCH.csl_trx_date)
  and exists (select 1 from ce_bank_acct_uses_gt_v bau
		where bau.bank_acct_use_id = arma.REMIT_BANK_ACCT_USE_ID
		and bau.bank_account_id =CE_AUTO_BANK_MATCH.csh_bank_account_id
		and bau.AR_USE_ENABLE_FLAG = 'Y' );
  cep_standard.debug('<<CE_AUTO_BANK_MATCH.validate_payment_method_id');
  RETURN (TRUE);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    cep_standard.debug('<<CE_AUTO_BANK_MATCH.Invalid payment method');
    RETURN (FALSE);
  WHEN TOO_MANY_ROWS THEN
    cep_standard.debug('<<CE_AUTO_BANK_MATCH.too many payment method for this account');
    RETURN (FALSE);
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_AUTO_BANK_MATCH.validate_payment_method');
    RAISE;
END validate_payment_method;

/* ----------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       get_tax_id                                                      |
|                                                                       |
|  DESCRIPTION                                                          |
|       fetches the tax id depending on the statement line type and     |
|       transaction date                                                |
|  CALL BY
|       match_engine, create_misc_trx
 --------------------------------------------------------------------- */
/*FUNCTION  get_vat_tax_id RETURN NUMBER IS */
PROCEDURE get_vat_tax_id (X_pass_mode   VARCHAR2,
			  l_vat_tax_id OUT NOCOPY NUMBER,
			  X_tax_rate OUT NOCOPY NUMBER) IS

--  l_vat_tax_id	NUMBER;
  y_dr_vat_tax_code       AR_RECEIVABLES_TRX.liability_tax_code%type;
  y_cr_vat_tax_code       AR_RECEIVABLES_TRX.asset_tax_code%type;

 -- bug 5733971
      l_return_status   VARCHAR2(50);
      l_msg_count       NUMBER;
      l_msg_data        VARCHAR2(1024);
      l_eff_date        date ;
      l_le_id      NUMBER;

BEGIN
  cep_standard.debug( '>>CE_AUTO_BANK_MATCH.get_vat_tax_id' );
  cep_standard.debug( 'CE_AUTO_BANK_MATCH.csl_receivables_trx_id= '|| CE_AUTO_BANK_MATCH.csl_receivables_trx_id||
			',CE_AUTO_BANK_MATCH.trx_org_id='||CE_AUTO_BANK_MATCH.trx_org_id  );
  if (X_pass_mode = 'AUTO_TRX') then
    SELECT ar.liability_tax_code, ar.asset_tax_code
    INTO   y_dr_vat_tax_code, y_cr_vat_tax_code
    FROM   ar_receivables_trx  ar
    WHERE  ar.receivables_trx_id = CE_AUTO_BANK_MATCH.csl_receivables_trx_id
    AND	   ar.org_id = nvl(CE_AUTO_BANK_MATCH.trx_org_id,CE_AUTO_BANK_REC.G_org_id) ; --CE_AUTO_BANK_MATCH.bau_org_id;
  else
    y_dr_vat_tax_code := CE_AUTO_BANK_REC.G_dr_vat_tax_code;
    y_cr_vat_tax_code := CE_AUTO_BANK_REC.G_cr_vat_tax_code;
  end if;


 -- bug 5733971
  begin

    select  LEGAL_ENTITY_ID
    into     l_le_id
    from XLE_FP_OU_LEDGER_V
    where OPERATING_UNIT_ID =nvl(CE_AUTO_BANK_MATCH.trx_org_id,CE_AUTO_BANK_REC.G_org_id) ;
  exception
    WHEN OTHERS THEN
    l_le_id := nvl(CE_AUTO_BANK_MATCH.trx_org_id,CE_AUTO_BANK_REC.G_org_id) ;
  end;

        zx_api_pub.set_tax_security_context(
            p_api_version      => 1.0,
            p_init_msg_list    => 'T',
            p_commit           => 'F',
            p_validation_level => NULL,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data,
            p_internal_org_id  => nvl(CE_AUTO_BANK_MATCH.trx_org_id, CE_AUTO_BANK_REC.G_org_id), --:org_id,
            p_legal_entity_id  =>  l_le_id, --:org_id,
            p_transaction_date => sysdate,
            p_related_doc_date => NULL,
            p_adjusted_doc_date=> NULL,
            x_effective_date   => l_eff_date);



  IF (CE_AUTO_BANK_MATCH.csl_trx_type IN ('MISC_DEBIT','DEBIT','STOP')) THEN
    SELECT ar.vat_tax_id, ar.tax_rate
    INTO   l_vat_tax_id, X_tax_rate
    FROM   ce_misc_tax_code_v ar --ar_vat_tax ar
    WHERE  ar.tax_code = y_dr_vat_tax_code
    AND	   ar.org_id = nvl(CE_AUTO_BANK_MATCH.trx_org_id, CE_AUTO_BANK_REC.G_org_id)
    AND    to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
	   between to_char(ar.start_date,'YYYY/MM/DD')
	   and NVL(to_char(ar.end_date,'YYYY/MM/DD'),
		 to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'));
  ELSE
    SELECT ar.vat_tax_id, ar.tax_rate
    INTO   l_vat_tax_id, X_tax_rate
    FROM    ce_misc_tax_code_v ar --ar_vat_tax ar
    WHERE  tax_code = y_cr_vat_tax_code
    AND	   ar.org_id = nvl(CE_AUTO_BANK_MATCH.trx_org_id,CE_AUTO_BANK_REC.G_org_id)
    AND    to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD')
	   between to_char(ar.start_date,'YYYY/MM/DD')
	   and NVL(to_char(ar.end_date,'YYYY/MM/DD'),
  	  to_char(CE_AUTO_BANK_MATCH.csl_trx_date,'YYYY/MM/DD'));
  END IF;
  cep_standard.debug('>>get_vat_tax_id.l_vat_tax_id:  '||TO_CHAR(l_vat_tax_id));
  cep_standard.debug('>>get_vat_tax_id.X_tax_rate:  '||TO_CHAR(X_tax_rate));
  cep_standard.debug( '<<CE_AUTO_BANK_MATCH.get_vat_tax_id' );
--  RETURN l_vat_tax_id;
EXCEPTION
  WHEN OTHERS THEN
  return;
END get_vat_tax_id;

/* ----------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       set_acct_type
|                                                                       |
|  DESCRIPTION                                                          |
|       set  type of bank account
|
|  CALL BY
|       match_process
 --------------------------------------------------------------------- */

PROCEDURE set_acct_type(x_bank_account_id number) IS
    x_ap_count	NUMBER;
    x_ar_count	NUMBER;
    x_xtr_count	NUMBER;
    x_pay_count	NUMBER;
    x_pay_only_count	NUMBER;
    x_acct_uses_count	NUMBER;
    x_ou_exists_in_bau	NUMBER;
  BEGIN
  cep_standard.debug( '>>CE_AUTO_BANK_MATCH.set_acct_type x_bank_account_id ' ||x_bank_account_id );

    IF (x_bank_account_id is not null) THEN

   -- IS AP ACCOUNT?
     Select count(*)
     into x_ap_count
     from ce_bank_acct_uses_all bau, CE_SECURITY_PROFILES_GT OU
     where AP_USE_ENABLE_FLAG = 'Y'
     and sysdate <= nvl(end_date,sysdate)
     and BANK_ACCOUNT_ID = x_bank_account_id
     and BAU.ORG_ID = OU.ORGANIZATION_ID
     AND OU.ORGANIZATION_TYPE = 'OPERATING_UNIT';


     IF (x_ap_count > 0) THEN
       CE_AUTO_BANK_MATCH.BAU_AP_USE_ENABLE_FLAG := 'Y';
     ELSE
       CE_AUTO_BANK_MATCH.BAU_AP_USE_ENABLE_FLAG := 'N';
     END IF;

   -- IS AR ACCOUNT?
     Select count(*)
     into x_ar_count
     from ce_bank_acct_uses_all bau, CE_SECURITY_PROFILES_GT OU
     where AR_USE_ENABLE_FLAG = 'Y'
     and sysdate <= nvl(end_date,sysdate)
     and BANK_ACCOUNT_ID = x_bank_account_id
     and BAU.ORG_ID = OU.ORGANIZATION_ID
     AND OU.ORGANIZATION_TYPE = 'OPERATING_UNIT';

     IF (x_ar_count > 0) THEN
       CE_AUTO_BANK_MATCH.BAU_AR_USE_ENABLE_FLAG := 'Y';
     ELSE
       CE_AUTO_BANK_MATCH.BAU_AR_USE_ENABLE_FLAG := 'N';
     END IF;

   -- IS xtr ACCOUNT?
     Select count(*)
     into x_xtr_count
     from ce_bank_acct_uses_all bau, CE_SECURITY_PROFILES_GT OU
     where XTR_USE_ENABLE_FLAG = 'Y'
     and sysdate <= nvl(end_date,sysdate)
     and BANK_ACCOUNT_ID = x_bank_account_id
     and BAU.LEGAL_ENTITY_ID = OU.ORGANIZATION_ID   --BUG 5122576
     AND OU.ORGANIZATION_TYPE = 'LEGAL_ENTITY';

     IF (x_xtr_count > 0) THEN
       CE_AUTO_BANK_MATCH.BAU_XTR_USE_ENABLE_FLAG := 'Y';
     ELSE
       CE_AUTO_BANK_MATCH.BAU_XTR_USE_ENABLE_FLAG := 'N';
     END IF;

   -- IS pay ACCOUNT?
     Select count(*)
     into x_pay_count
     from ce_bank_acct_uses_all bau, CE_SECURITY_PROFILES_GT OU
     where PAY_USE_ENABLE_FLAG = 'Y'
     and sysdate <= nvl(end_date,sysdate)
     and BANK_ACCOUNT_ID = x_bank_account_id
     and BAU.ORG_ID = OU.ORGANIZATION_ID
     AND OU.ORGANIZATION_TYPE = 'BUSINESS_GROUP';

     IF (x_pay_count > 0) THEN
       CE_AUTO_BANK_MATCH.BAU_PAY_USE_ENABLE_FLAG := 'Y';
     ELSE
       CE_AUTO_BANK_MATCH.BAU_PAY_USE_ENABLE_FLAG := 'N';
     END IF;
   END IF;  -- (x_bank_account_id is not null)

  cep_standard.debug('CE_AUTO_BANK_MATCH.bau_ar_use_enable_flag ' ||CE_AUTO_BANK_MATCH.bau_ar_use_enable_flag);
  cep_standard.debug('CE_AUTO_BANK_MATCH.bau_ap_use_enable_flag ' ||CE_AUTO_BANK_MATCH.bau_ap_use_enable_flag);
  cep_standard.debug('CE_AUTO_BANK_MATCH.bau_xtr_use_enable_flag ' ||CE_AUTO_BANK_MATCH.bau_xtr_use_enable_flag);
  cep_standard.debug('CE_AUTO_BANK_MATCH.bau_pay_use_enable_flag ' ||CE_AUTO_BANK_MATCH.bau_pay_use_enable_flag);

  cep_standard.debug( '<<CE_AUTO_BANK_MATCH.set_acct_type ' );

    EXCEPTION
    WHEN OTHERS THEN
	  cep_standard.debug('EXCEPTION: ce_auto_bank_match.set_acct_type');

      RAISE;
  END set_acct_type;

/* ---------------------------------------------------------------------|
|  PRIVATE PROCEDURE                                	                |
|       match_stmt_line_JE						|
|  DESCRIPTION								|
|	 For the Journal Entry Creation project.			|
|	 Bug 3951431							|
|	 This procedure mathes and reconcils the stmt line that has     |
|	 created a JE. The matching is done on the following fields     |
|	 1) JE actual flag ='A'						|
|	 2) JE status = 'P'						|
|	 3) JE ccid = bank cash account ccid				|
|	 4) JE effective date = sl.accounting_date			|
|	 5) JE source ='Other'						|
|	 6) JE currency = sl (or bank) currency				|
|	 7) JE amount = sl.amount (or original amount)			|
|                                                                       |
|        bug 4435028   8/10/05                                          |
|        - Match JEC/ZBA by cashflow_id  only                           |
|                                                                       |
|  HISTORY                                                              |
|       16-SEP-2004        Shaik Vali		Created
|       15-APR-2205        BHCHUNG              SLA change
|       10-AUG-2005	   lkwan       bug 4435028 -
|                                      - Match JEC/ZBA by cashflow_id  only
 --------------------------------------------------------------------- */
  PROCEDURE match_stmt_line_JE IS
  no_of_matches		NUMBER;
	l_je_header_id GL_JE_HEADERS.je_header_id%TYPE := null;
	l_je_line_num  GL_JE_LINES.je_line_num%TYPE;
	l_trx_currency_type VARCHAR2(100);
	l_sob_currency_code FND_CURRENCIES.CURRENCY_CODE%TYPE;
	l_je_amount GL_JE_LINES.accounted_dr%TYPE;
	l_sl_amount CE_STATEMENT_LINES.amount%TYPE;
	l_je_entered_dr GL_JE_LINES.entered_dr%TYPE;
	l_je_entered_cr GL_JE_LINES.entered_cr%TYPE;
	l_je_currency_code FND_CURRENCIES.CURRENCY_CODE%TYPE;
	l_sl_currency_code FND_CURRENCIES.CURRENCY_CODE%TYPE;
	d_statement_header_id CE_STATEMENT_HEADERS.statement_header_id%TYPE;
	P_CURRENCY_CODE  VARCHAR2(15);
	P_STATUS	VARCHAR2(30);
	P_AMOUNT	NUMBER;
  BEGIN
  cep_standard.debug( '>>CE_AUTO_BANK_MATCH.match_stmt_line_JE ' );

-- bug 4435028 - get JEC lines from ce_cashflows

/*
	SELECT
		JEL.JE_HEADER_ID,
		JEL.JE_LINE_NUM,
		SOB.CURRENCY_CODE,
		JEL.ENTERED_DR,
		JEL.ENTERED_CR,
		JEH.CURRENCY_CODE
	INTO
		l_je_header_id,
		l_je_line_num,
		l_sob_currency_code,
		l_je_entered_dr,
		l_je_entered_cr,
		l_je_currency_code
	FROM
		GL_JE_LINES JEL,
		GL_SETS_OF_BOOKS SOB,
		CE_SYSTEM_PARAMETERS SYS,
		GL_JE_HEADERS JEH,
		GL_PERIOD_STATUSES GPS,
		XLA_DISTRIBUTION_LINKS XLA,
		XLA_AE_LINES XLL
	WHERE
	    JEH.JE_HEADER_ID = JEL.JE_HEADER_ID
	    AND JEL.CODE_COMBINATION_ID = CE_AUTO_BANK_MATCH.aba_asset_code_combination_id
	    AND JEL.PERIOD_NAME = GPS.PERIOD_NAME
	    AND GPS.APPLICATION_ID = 101
	    AND GPS.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
	    AND SOB.SET_OF_BOOKS_ID = SYS.SET_OF_BOOKS_ID
--JEC	    AND JEL.SET_OF_BOOKS_ID = SYS.SET_OF_BOOKS_ID
	    AND JEL.EFFECTIVE_DATE >= SYS.CASHBOOK_BEGIN_DATE
	    AND JEH.JE_SOURCE ='Other'
	    AND JEL.STATUS = 'P'
	    AND JEH.ACTUAL_FLAG = 'A'
	    AND JEL.EFFECTIVE_DATE = CE_AUTO_BANK_MATCH.csl_accounting_date
	    AND JEH.CURRENCY_CODE = NVL(CE_AUTO_BANK_MATCH.csl_currency_code,
								CE_AUTO_BANK_MATCH.aba_bank_currency)
	    AND XLL.AE_LINE_NUM = XLA.AE_LINE_NUM
	    AND XLL.AE_HEADER_ID = XLA.AE_HEADER_ID
	    AND XLA.APPLICATION_ID = 260
	    AND XLA.EVENT_ID = CE_AUTO_BANK_MATCH.csl_event_id
	    AND JEL.GL_SL_LINK_ID = XLL.GL_SL_LINK_ID
	    AND JEL.GL_SL_LINK_TABLE = XLL.GL_SL_LINK_TABLE
	    AND NOT EXISTS
	   (SELECT NULL
	    FROM
	       CE_STATEMENT_RECONCILS_ALL CRE2,
	   	CE_SYSTEM_PARAMETERS SYS2
	    WHERE JEL.JE_HEADER_ID = CRE2.JE_HEADER_ID
		AND JEL.JE_LINE_NUM = CRE2.REFERENCE_ID
		AND CRE2.STATUS_FLAG = 'M'
		AND NVL(CRE2.CURRENT_RECORD_FLAG,'Y') = 'Y');
--JEC		AND SYS2.SET_OF_BOOKS_ID = JEL.SET_OF_BOOKS_ID);

*/

    SELECT 	catv.trx_id,
		catv.cash_receipt_id,
		catv.row_id,
		catv.trx_date,
		catv.currency_code,
		catv.bank_account_amount,
		catv.base_amount,
		catv.status,
		nvl(catv.amount_cleared,0),
		'CASHFLOW',
		1,
		catv.trx_currency_type,
		catv.amount,
		catv.clearing_trx_type,
		catv.exchange_rate,
		catv.exchange_rate_date,
		catv.exchange_rate_type,
		catv.legal_entity_id,
		catv.seq_id
    INTO        CE_AUTO_BANK_MATCH.trx_id,
		CE_AUTO_BANK_MATCH.trx_cash_receipt_id,
		CE_AUTO_BANK_MATCH.trx_rowid,
		CE_AUTO_BANK_MATCH.trx_date,
		CE_AUTO_BANK_MATCH.trx_currency_code,
		CE_AUTO_BANK_MATCH.trx_amount,
		CE_AUTO_BANK_MATCH.trx_base_amount,
		CE_AUTO_BANK_MATCH.trx_status,
		CE_AUTO_BANK_MATCH.trx_cleared_amount,
		CE_AUTO_BANK_MATCH.csl_match_type,
		no_of_matches,
		CE_AUTO_BANK_MATCH.trx_currency_type,
		CE_AUTO_BANK_MATCH.trx_curr_amount,
		CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
		CE_AUTO_BANK_MATCH.trx_exchange_rate,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_date,
		CE_AUTO_BANK_MATCH.trx_exchange_rate_type,
		CE_AUTO_BANK_MATCH.trx_legal_entity_id,
		CE_AUTO_BANK_MATCH.gt_seq_id
    --FROM        ce_260_cf_transactions_v catv
    FROM        ce_available_transactions_tmp catv
    WHERE       catv.bank_account_id = CE_AUTO_BANK_MATCH.csh_bank_account_id
     AND 	catv.TRX_ID = CE_AUTO_BANK_MATCH.csl_cashflow_id
       AND	catv.legal_entity_id = nvl(CE_AUTO_BANK_REC.G_legal_entity_id,catv.legal_entity_id)
     AND	catv.application_id = 261
     AND	NVL(catv.reconciled_status_flag, 'N') = 'N';
    --AND		catv.bank_account_amount = CE_AUTO_BANK_MATCH.csl_amount
    --AND		catv.ce_bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
    --AND		catv.trx_number = CE_AUTO_BANK_MATCH.csl_bank_trx_number;

  cep_standard.debug( 'no_of_matches '||no_of_matches );

	--
	-- Currency and amount should be matched based on
	-- whether the stmt line is DOMESTIC, FOREIGN or
	-- INTERNATIONAL
	--
	IF (NVL(CE_AUTO_BANK_MATCH.CSL_CURRENCY_CODE, CE_AUTO_BANK_MATCH.ABA_BANK_CURRENCY)
		 = l_SOB_CURRENCY_CODE) THEN
		l_trx_currency_type := 'FUNCTIONAL';
		l_sl_currency_code := l_SOB_CURRENCY_CODE;
		l_sl_amount := CE_AUTO_BANK_MATCH.csl_amount;
	ELSIF (NVL(CE_AUTO_BANK_MATCH.CSL_CURRENCY_CODE, CE_AUTO_BANK_MATCH.ABA_BANK_CURRENCY)
		 = CE_AUTO_BANK_MATCH.aba_bank_currency) THEN
		l_trx_currency_type := 'BANK';
		l_sl_currency_code := CE_AUTO_BANK_MATCH.aba_bank_currency;
		l_sl_amount := CE_AUTO_BANK_MATCH.csl_amount;
	ELSE
		l_trx_currency_type := 'FOREIGN';
		l_sl_currency_code := CE_AUTO_BANK_MATCH.csl_currency_code;
		-- bug 4953625
		-- CE_AUTO_BANK_MATCH.csl_original_amount is the trx currency
		-- CE_AUTO_BANK_MATCH.csl_amount is the bank account currency
		--l_sl_amount := CE_AUTO_BANK_MATCH.csl_original_amount;
		l_sl_amount := CE_AUTO_BANK_MATCH.csl_amount;
	END IF;
	--
	-- Match should be on the balancing JE, which will have reverse amounts
	--
	/*
	IF (CE_AUTO_BANK_MATCH.csl_trx_type in ('DEBIT','MISC_DEBIT','NSF')) THEN
	   l_je_amount := l_je_entered_cr;
	ELSE
	   l_je_amount := l_je_entered_dr;
	END IF;
	*/

  cep_standard.debug( 'CE_AUTO_BANK_MATCH.trx_currency_code '||CE_AUTO_BANK_MATCH.trx_currency_code
			|| ', l_sl_currency_code '|| l_sl_currency_code
			|| ', CE_AUTO_BANK_MATCH.trx_amount '|| CE_AUTO_BANK_MATCH.trx_amount
			|| ', l_sl_amount ' ||l_sl_amount);

	--IF(l_je_currency_code = l_sl_currency_code AND l_je_amount = l_sl_amount)
	-- bug 4953625 match trx bank acct cur amt with stmt ln bank acct cur amt
	IF(CE_AUTO_BANK_MATCH.trx_currency_code = l_sl_currency_code AND
		CE_AUTO_BANK_MATCH.trx_amount = l_sl_amount) 	THEN

 	  --CE_AUTO_BANK_MATCH.csl_reconcile_flag := CE_AUTO_BANK_MATCH.csl_match_type; --'JE';
	  --CE_AUTO_BANK_MATCH.csl_reconcile_flag := 'CE';
	  --CE_AUTO_BANK_MATCH.trx_id := CE_AUTO_BANK_MATCH.csl_cashflow_id; --l_je_line_num;

	  CE_AUTO_BANK_CLEAR.reconcile_trx(
		passin_mode 		=> 'AUTO',
		tx_type 		=> CE_AUTO_BANK_MATCH.csl_match_type, -- CASHFLOW --'JE_LINE',
		trx_id			=> CE_AUTO_BANK_MATCH.TRX_id, --l_je_line_num,
		trx_status		=> CE_AUTO_BANK_MATCH.trx_status, --'P',
		receipt_type		=> CE_AUTO_BANK_MATCH.csl_match_type,-- CASHFLOW - --'JE',
		exchange_rate_type  	=> CE_AUTO_BANK_MATCH.csl_exchange_rate_type,
		exchange_date	    	=> CE_AUTO_BANK_MATCH.csl_exchange_rate_date,
		exchange_rate		=> CE_AUTO_BANK_MATCH.csl_exchange_rate,
/*		amount_cleared		=> CE_AUTO_BANK_MATCH.calc_csl_amount,*/
		amount_cleared		=> CE_AUTO_BANK_MATCH.trx_amount, --CE_AUTO_BANK_MATCH.csl_amount,
		charges_amount		=> CE_AUTO_BANK_MATCH.trx_charges_amount,
		errors_amount		=> CE_AUTO_BANK_MATCH.trx_errors_amount,
		gl_date			=> CE_AUTO_BANK_REC.G_gl_date_original,
		value_date		=> CE_AUTO_BANK_MATCH.csl_effective_date,
		cleared_date		=> CE_AUTO_BANK_MATCH.csl_trx_date,
		ar_cash_receipt_id	=> NULL, --l_je_header_id,
		X_bank_currency	    	=> CE_AUTO_BANK_MATCH.aba_bank_currency,
		X_statement_line_id	=> CE_AUTO_BANK_MATCH.csl_statement_line_id,
		X_statement_line_type	=> CE_AUTO_BANK_MATCH.csl_line_trx_type,
		reference_status	=> NULL,
		trx_currency_type	=> l_trx_currency_type,
	        X_currency_code     	=> NVL(CE_AUTO_BANK_MATCH.csl_currency_code,CE_AUTO_BANK_MATCH.aba_bank_currency),
		auto_reconciled_flag 	=> 'Y',
		X_statement_header_id	=> d_statement_header_id,
		X_effective_date	=> CE_AUTO_BANK_MATCH.csl_effective_date,
		X_float_handling_flag	=> CE_AUTO_BANK_REC.G_float_handling_flag,
	        X_reversed_receipt_flag => CE_AUTO_BANK_MATCH.reversed_receipt_flag);

	        CE_AUTO_BANK_CLEAR.update_line_status(CE_AUTO_BANK_MATCH.csl_statement_line_id,'RECONCILED');

		-- update the reconciled_status_flag of the GT table, ce_available_transactions_tmp,
		-- to 'Y'
		update_gt_reconciled_status (CE_AUTO_BANK_MATCH.gt_seq_id, 'Y');

	ELSE
  	  cep_standard.debug( 'currency or amount does not match' );
  	  CE_RECONCILIATION_ERRORS_PKG.delete_row(
 	    CE_AUTO_BANK_MATCH.csh_statement_header_id,
	    CE_AUTO_BANK_MATCH.csl_statement_line_id);

	  CE_RECONCILIATION_ERRORS_PKG.insert_row(
	    CE_AUTO_BANK_MATCH.csh_statement_header_id,
	    CE_AUTO_BANK_MATCH.csl_statement_line_id,'CE_CE_TRX_AMT_OR_CUR_NOT_MATCH');

	END IF;
 cep_standard.debug( '<<CE_AUTO_BANK_MATCH.match_stmt_line_JE ' );

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
  CE_RECONCILIATION_ERRORS_PKG.delete_row(
 	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id);
  CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id,
	'CE_NO_CE_TRX_MATCH');

  WHEN TOO_MANY_ROWS THEN
  CE_RECONCILIATION_ERRORS_PKG.delete_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id);
  CE_RECONCILIATION_ERRORS_PKG.insert_row(
	CE_AUTO_BANK_MATCH.csh_statement_header_id,
	CE_AUTO_BANK_MATCH.csl_statement_line_id,
	'CE_ABR_JEL_PARTIAL');
  END;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       populate_available_gt                                           |
|                                                                       |
|  DESCRIPTION                                                          |
|       populate ce_available_transactions_tmp for auto reconciliation  |
|                                                                       |
|  CALLED BY                                                            |
|       match_process                                                   |
|                                                                       |
|  HISTORY                                                              |
|       11-MAY-2006        Xin Wang     Created                         |
 --------------------------------------------------------------------- */
PROCEDURE populate_available_gt (p_bank_account_id 	NUMBER) IS
   cursor r_trx_source(p_bank_account_id 	NUMBER) is
        SELECT 	trx_type,
		trx_code,
		decode(PAYROLL_PAYMENT_FORMAT_ID, null, NVL(reconcile_flag,'X'),
                        decode(reconcile_flag,'PAY', 'PAY_EFT', NVL(reconcile_flag,'X'))),
		matching_against
	FROM  	ce_transaction_codes
	WHERE  	bank_account_id = p_bank_account_id;
   l_trx_type	VARCHAR2(30);
   l_trx_code	VARCHAR2(30);
   l_trx_source	VARCHAR2(20);
   l_matching_against	VARCHAR2(20);
   l_cf		NUMBER(15) := 0;
BEGIN
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.populate_available_gt');

  -- clean up the temp table
  delete ce_available_transactions_tmp;

  -- first check if there's any stmt line that has cashflow_id
  -- if so, populate from ce_260_cf_transactions_v,
  -- this is because in autoreconciliation, if a line has cashflow_id,
  -- before everything else, it'll match to cashflow transactions

  select count(1)
  into   l_cf
  from   ce_statement_lines      sl,
         ce_statement_headers    sh
  where  sl.statement_header_id = sh.statement_header_id
  and    sh.bank_account_id = p_bank_account_id
  and    sl.cashflow_id is not null;

  IF l_cf > 0 THEN  -- some line has cashflow_id
    IF CE_AUTO_BANK_MATCH.av_260_cf_inserted_flag = 'N' THEN
      cep_standard.debug('inserting data from ce_260_cf_transactions_v');
      insert into ce_available_transactions_tmp
		(seq_id,
		ROW_ID,
		MULTI_SELECT,
		BANK_ACCOUNT_ID,
		BANK_ACCOUNT_NAME,
		BANK_ACCOUNT_NUM,
		BANK_NAME,
		BANK_BRANCH_NAME,
		TRX_ID,
		TRX_TYPE,
		TYPE_MEANING,
		TRX_NUMBER,
		CHECK_NUMBER,
		CURRENCY_CODE,
		AMOUNT,
		BANK_ACCOUNT_AMOUNT,
		AMOUNT_CLEARED,
		GL_DATE,
		STATUS_DSP,
		STATUS,
		TRX_DATE,
		CLEARED_DATE,
		MATURITY_DATE,
		EXCHANGE_RATE_DATE,
		EXCHANGE_RATE_TYPE,
		USER_EXCHANGE_RATE_TYPE,
		EXCHANGE_RATE,
		BANK_CHARGES,
		BANK_ERRORS,
		BATCH_NAME,
		BATCH_ID,
		AGENT_NAME,
		CUSTOMER_NAME,
		PAYMENT_METHOD,
		VENDOR_NAME,
		CUSTOMER_ID,
		SUPPLIER_ID,
		REFERENCE_TYPE_DSP,
		REFERENCE_TYPE,
		REFERENCE_ID,
		ACTUAL_AMOUNT_CLEARED,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		REMITTANCE_NUMBER,
		CASH_RECEIPT_ID,
		APPLICATION_ID,
		COUNT_CLEARED,
		BANK_CURRENCY_CODE,
		TRX_CURRENCY_TYPE,
		CODE_COMBINATION_ID,
		PERIOD_NAME,
		JOURNAL_ENTRY_NAME,
		DOCUMENT_NUMBER,
		JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
		JOURNAL_CATEGORY,
		BASE_AMOUNT,
		RECEIPT_CLASS_ID,
		RECEIPT_METHOD_ID,
		RECEIPT_CLASS_NAME,
		DEPOSIT_DATE,
		VALUE_DATE,
		REVERSED_RECEIPT_FLAG,
		LEGAL_ENTITY_ID,
		ORG_ID,
		INVOICE_TEXT,
		BANK_ACCOUNT_TEXT,
		CUSTOMER_TEXT,
		COUNTERPARTY,
		TRXN_SUBTYPE,
		CE_BANK_ACCT_USE_ID,
		RECONCILED_STATUS_FLAG)
      select	ce_available_transactions_s.nextval,
		ROW_ID,
                MULTI_SELECT,
                BANK_ACCOUNT_ID,
                BANK_ACCOUNT_NAME,
                BANK_ACCOUNT_NUM,
                BANK_NAME,
                BANK_BRANCH_NAME,
                TRX_ID,
                TRX_TYPE,
                TYPE_MEANING,
                TRX_NUMBER,
                CHECK_NUMBER,
		CURRENCY_CODE,
                AMOUNT,
                BANK_ACCOUNT_AMOUNT,
                AMOUNT_CLEARED,
                GL_DATE,
                STATUS_DSP,
                STATUS,
                TRX_DATE,
                CLEARED_DATE,
                MATURITY_DATE,
                EXCHANGE_RATE_DATE,
                EXCHANGE_RATE_TYPE,
                USER_EXCHANGE_RATE_TYPE,
                EXCHANGE_RATE,
                BANK_CHARGES,
                BANK_ERRORS,
                BATCH_NAME,
                BATCH_ID,
                AGENT_NAME,
                CUSTOMER_NAME,
                PAYMENT_METHOD,
		VENDOR_NAME,
                CUSTOMER_ID,
                SUPPLIER_ID,
                REFERENCE_TYPE_DSP,
                REFERENCE_TYPE,
                REFERENCE_ID,
                ACTUAL_AMOUNT_CLEARED,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                REMITTANCE_NUMBER,
                CASH_RECEIPT_ID,
                261,   --APPLICATION_ID,
                COUNT_CLEARED,
                BANK_CURRENCY_CODE,
                TRX_CURRENCY_TYPE,
                CODE_COMBINATION_ID,
                PERIOD_NAME,
                JOURNAL_ENTRY_NAME,
                DOCUMENT_NUMBER,
                JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
                JOURNAL_CATEGORY,
                BASE_AMOUNT,
                RECEIPT_CLASS_ID,
                RECEIPT_METHOD_ID,
                RECEIPT_CLASS_NAME,
                DEPOSIT_DATE,
                VALUE_DATE,
                REVERSED_RECEIPT_FLAG,
                LEGAL_ENTITY_ID,
                ORG_ID,
		INVOICE_TEXT,
                BANK_ACCOUNT_TEXT,
                CUSTOMER_TEXT,
                COUNTERPARTY,
                TRXN_SUBTYPE,
                CE_BANK_ACCT_USE_ID,
		'N'
      from 	ce_260_cf_transactions_v
      where     bank_account_id = p_bank_account_id;

      CE_AUTO_BANK_MATCH.av_260_cf_inserted_flag := 'Y';
     END IF;  --CE_AUTO_BANK_MATCH.av_260_cf_inserted_flag = 'N'
  END IF;  -- l_cf = 1

  OPEN r_trx_source (p_bank_account_id);
  LOOP
    FETCH r_trx_source INTO
      l_trx_type,
      l_trx_code,
      l_trx_source,
      l_matching_against;
    EXIT WHEN r_trx_source%NOTFOUND OR r_trx_source%NOTFOUND IS NULL;

    cep_standard.debug('bank_account_id = ' || p_bank_account_id);
    cep_standard.debug('l_trx_source = ' || l_trx_source ||
			', l_trx_type = ' || l_trx_type ||
			', l_trx_code = ' || l_trx_code ||
			', l_matching_against = ' || l_matching_against);
    IF l_trx_source = 'AP' THEN

     IF CE_AUTO_BANK_MATCH.av_200_inserted_flag = 'N' THEN  -- AP data has not been inserted into the GT table

      cep_standard.debug('inserting data from ce_200_transactions_v');

      insert into ce_available_transactions_tmp
		(seq_id,
		ROW_ID,
		MULTI_SELECT,
		BANK_ACCOUNT_ID,
		BANK_ACCOUNT_NAME,
		BANK_ACCOUNT_NUM,
		BANK_NAME,
		BANK_BRANCH_NAME,
		TRX_ID,
		TRX_TYPE,
		TYPE_MEANING,
		TRX_NUMBER,
		CHECK_NUMBER,
		CURRENCY_CODE,
		AMOUNT,
		BANK_ACCOUNT_AMOUNT,
		AMOUNT_CLEARED,
		GL_DATE,
		STATUS_DSP,
		STATUS,
		TRX_DATE,
		CLEARED_DATE,
		MATURITY_DATE,
		EXCHANGE_RATE_DATE,
		EXCHANGE_RATE_TYPE,
		USER_EXCHANGE_RATE_TYPE,
		EXCHANGE_RATE,
		BANK_CHARGES,
		BANK_ERRORS,
		BATCH_NAME,
		BATCH_ID,
		AGENT_NAME,
		CUSTOMER_NAME,
		PAYMENT_METHOD,
		VENDOR_NAME,
		CUSTOMER_ID,
		SUPPLIER_ID,
		REFERENCE_TYPE_DSP,
		REFERENCE_TYPE,
		REFERENCE_ID,
		ACTUAL_AMOUNT_CLEARED,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		REMITTANCE_NUMBER,
		CASH_RECEIPT_ID,
		APPLICATION_ID,
		COUNT_CLEARED,
		BANK_CURRENCY_CODE,
		TRX_CURRENCY_TYPE,
		CODE_COMBINATION_ID,
		PERIOD_NAME,
		JOURNAL_ENTRY_NAME,
		DOCUMENT_NUMBER,
		JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
		JOURNAL_CATEGORY,
		BASE_AMOUNT,
		RECEIPT_CLASS_ID,
		RECEIPT_METHOD_ID,
		RECEIPT_CLASS_NAME,
		DEPOSIT_DATE,
		VALUE_DATE,
		REVERSED_RECEIPT_FLAG,
		LEGAL_ENTITY_ID,
		ORG_ID,
		CE_BANK_ACCT_USE_ID,
		RECONCILED_STATUS_FLAG)
      select  	ce_available_transactions_s.nextval,
		ROW_ID,
                MULTI_SELECT,
                BANK_ACCOUNT_ID,
                BANK_ACCOUNT_NAME,
                BANK_ACCOUNT_NUM,
                BANK_NAME,
                BANK_BRANCH_NAME,
                TRX_ID,
                TRX_TYPE,
                TYPE_MEANING,
                TRX_NUMBER,
                CHECK_NUMBER,
		CURRENCY_CODE,
                AMOUNT,
                BANK_ACCOUNT_AMOUNT,
                AMOUNT_CLEARED,
                GL_DATE,
                STATUS_DSP,
                STATUS,
                TRX_DATE,
                CLEARED_DATE,
                MATURITY_DATE,
                EXCHANGE_RATE_DATE,
                EXCHANGE_RATE_TYPE,
                USER_EXCHANGE_RATE_TYPE,
                EXCHANGE_RATE,
                BANK_CHARGES,
                BANK_ERRORS,
                BATCH_NAME,
                BATCH_ID,
                AGENT_NAME,
                CUSTOMER_NAME,
                PAYMENT_METHOD,
		VENDOR_NAME,
                CUSTOMER_ID,
                SUPPLIER_ID,
                REFERENCE_TYPE_DSP,
                REFERENCE_TYPE,
                REFERENCE_ID,
                ACTUAL_AMOUNT_CLEARED,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                REMITTANCE_NUMBER,
                CASH_RECEIPT_ID,
                APPLICATION_ID,
                COUNT_CLEARED,
                BANK_CURRENCY_CODE,
                TRX_CURRENCY_TYPE,
                CODE_COMBINATION_ID,
                PERIOD_NAME,
                JOURNAL_ENTRY_NAME,
                DOCUMENT_NUMBER,
                JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
                JOURNAL_CATEGORY,
                BASE_AMOUNT,
                RECEIPT_CLASS_ID,
                RECEIPT_METHOD_ID,
                RECEIPT_CLASS_NAME,
                DEPOSIT_DATE,
                VALUE_DATE,
                REVERSED_RECEIPT_FLAG,
                LEGAL_ENTITY_ID,
                ORG_ID,
                CE_BANK_ACCT_USE_ID,
		'N'
      from 	ce_200_transactions_v
      where     bank_account_id = p_bank_account_id;

      CE_AUTO_BANK_MATCH.av_200_inserted_flag := 'Y';
     END IF;

    ELSIF l_trx_source = 'AR' THEN

     IF CE_AUTO_BANK_MATCH.av_222_inserted_flag = 'N' THEN  -- AP data has not been inserted into the GT table
      cep_standard.debug('inserting data from ce_222_transactions_v');

      insert into ce_available_transactions_tmp
		(seq_id,
		ROW_ID,
		MULTI_SELECT,
		BANK_ACCOUNT_ID,
		BANK_ACCOUNT_NAME,
		BANK_ACCOUNT_NUM,
		BANK_NAME,
		BANK_BRANCH_NAME,
		TRX_ID,
		TRX_TYPE,
		TYPE_MEANING,
		TRX_NUMBER,
		CHECK_NUMBER,
		CURRENCY_CODE,
		AMOUNT,
		BANK_ACCOUNT_AMOUNT,
		AMOUNT_CLEARED,
		GL_DATE,
		STATUS_DSP,
		STATUS,
		TRX_DATE,
		CLEARED_DATE,
		MATURITY_DATE,
		EXCHANGE_RATE_DATE,
		EXCHANGE_RATE_TYPE,
		USER_EXCHANGE_RATE_TYPE,
		EXCHANGE_RATE,
		BANK_CHARGES,
		BANK_ERRORS,
		BATCH_NAME,
		BATCH_ID,
		AGENT_NAME,
		CUSTOMER_NAME,
		PAYMENT_METHOD,
		VENDOR_NAME,
		CUSTOMER_ID,
		SUPPLIER_ID,
		REFERENCE_TYPE_DSP,
		REFERENCE_TYPE,
		REFERENCE_ID,
		ACTUAL_AMOUNT_CLEARED,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		REMITTANCE_NUMBER,
		CASH_RECEIPT_ID,
		APPLICATION_ID,
		COUNT_CLEARED,
		BANK_CURRENCY_CODE,
		TRX_CURRENCY_TYPE,
		CODE_COMBINATION_ID,
		PERIOD_NAME,
		JOURNAL_ENTRY_NAME,
		DOCUMENT_NUMBER,
		JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
		JOURNAL_CATEGORY,
		BASE_AMOUNT,
		RECEIPT_CLASS_ID,
		RECEIPT_METHOD_ID,
		RECEIPT_CLASS_NAME,
		DEPOSIT_DATE,
		VALUE_DATE,
		REVERSED_RECEIPT_FLAG,
		LEGAL_ENTITY_ID,
		ORG_ID,
		CE_BANK_ACCT_USE_ID,
		RECONCILED_STATUS_FLAG)
      select	ce_available_transactions_s.nextval,
		ROW_ID,
                MULTI_SELECT,
                BANK_ACCOUNT_ID,
                BANK_ACCOUNT_NAME,
                BANK_ACCOUNT_NUM,
                BANK_NAME,
                BANK_BRANCH_NAME,
                TRX_ID,
                TRX_TYPE,
                TYPE_MEANING,
                TRX_NUMBER,
                CHECK_NUMBER,
		CURRENCY_CODE,
                AMOUNT,
                BANK_ACCOUNT_AMOUNT,
                AMOUNT_CLEARED,
                GL_DATE,
                STATUS_DSP,
                STATUS,
                TRX_DATE,
                CLEARED_DATE,
                MATURITY_DATE,
                EXCHANGE_RATE_DATE,
                EXCHANGE_RATE_TYPE,
                USER_EXCHANGE_RATE_TYPE,
                EXCHANGE_RATE,
                BANK_CHARGES,
                BANK_ERRORS,
                BATCH_NAME,
                BATCH_ID,
                AGENT_NAME,
                CUSTOMER_NAME,
                PAYMENT_METHOD,
		VENDOR_NAME,
                CUSTOMER_ID,
                SUPPLIER_ID,
                REFERENCE_TYPE_DSP,
                REFERENCE_TYPE,
                REFERENCE_ID,
                ACTUAL_AMOUNT_CLEARED,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                REMITTANCE_NUMBER,
                CASH_RECEIPT_ID,
                APPLICATION_ID,
                COUNT_CLEARED,
                BANK_CURRENCY_CODE,
                TRX_CURRENCY_TYPE,
                CODE_COMBINATION_ID,
                PERIOD_NAME,
                JOURNAL_ENTRY_NAME,
                DOCUMENT_NUMBER,
                JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
                JOURNAL_CATEGORY,
                BASE_AMOUNT,
                RECEIPT_CLASS_ID,
                RECEIPT_METHOD_ID,
                RECEIPT_CLASS_NAME,
                DEPOSIT_DATE,
                VALUE_DATE,
                REVERSED_RECEIPT_FLAG,
                LEGAL_ENTITY_ID,
                ORG_ID,
                CE_BANK_ACCT_USE_ID,
		'N'
      from 	ce_222_transactions_v
      where     bank_account_id = p_bank_account_id;

      CE_AUTO_BANK_MATCH.av_222_inserted_flag := 'Y';
     END IF;

    ELSIF l_trx_source = 'CE' THEN
     -- when l_trx_source is 'CE', only populate from ce_260_cf_transactions_v
/*
     IF av_260_inserted_flag = 'N' THEN

      cep_standard.debug('inserting data from ce_260_transactions_v');

      insert into ce_available_transactions_tmp
		(seq_id,
		ROW_ID,
		MULTI_SELECT,
		BANK_ACCOUNT_ID,
		BANK_ACCOUNT_NAME,
		BANK_ACCOUNT_NUM,
		BANK_NAME,
		BANK_BRANCH_NAME,
		TRX_ID,
		TRX_TYPE,
		TYPE_MEANING,
		TRX_NUMBER,
		CHECK_NUMBER,
		CURRENCY_CODE,
		AMOUNT,
		BANK_ACCOUNT_AMOUNT,
		AMOUNT_CLEARED,
		GL_DATE,
		STATUS_DSP,
		STATUS,
		TRX_DATE,
		CLEARED_DATE,
		MATURITY_DATE,
		EXCHANGE_RATE_DATE,
		EXCHANGE_RATE_TYPE,
		USER_EXCHANGE_RATE_TYPE,
		EXCHANGE_RATE,
		BANK_CHARGES,
		BANK_ERRORS,
		BATCH_NAME,
		BATCH_ID,
		AGENT_NAME,
		CUSTOMER_NAME,
		PAYMENT_METHOD,
		VENDOR_NAME,
		CUSTOMER_ID,
		SUPPLIER_ID,
		REFERENCE_TYPE_DSP,
		REFERENCE_TYPE,
		REFERENCE_ID,
		ACTUAL_AMOUNT_CLEARED,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		REMITTANCE_NUMBER,
		CASH_RECEIPT_ID,
		APPLICATION_ID,
		COUNT_CLEARED,
		BANK_CURRENCY_CODE,
		TRX_CURRENCY_TYPE,
		CODE_COMBINATION_ID,
		PERIOD_NAME,
		JOURNAL_ENTRY_NAME,
		DOCUMENT_NUMBER,
		JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
		JOURNAL_CATEGORY,
		BASE_AMOUNT,
		RECEIPT_CLASS_ID,
		RECEIPT_METHOD_ID,
		RECEIPT_CLASS_NAME,
		DEPOSIT_DATE,
		VALUE_DATE,
		REVERSED_RECEIPT_FLAG,
		LEGAL_ENTITY_ID,
		ORG_ID,
		INVOICE_TEXT,
		BANK_ACCOUNT_TEXT,
		CUSTOMER_TEXT,
		CE_BANK_ACCT_USE_ID,
		RECONCILED_STATUS_FLAG)
      select	ce_available_transactions_s.nextval,
		ROW_ID,
                MULTI_SELECT,
                BANK_ACCOUNT_ID,
                BANK_ACCOUNT_NAME,
                BANK_ACCOUNT_NUM,
                BANK_NAME,
                BANK_BRANCH_NAME,
                TRX_ID,
                TRX_TYPE,
                TYPE_MEANING,
                TRX_NUMBER,
                CHECK_NUMBER,
		CURRENCY_CODE,
                AMOUNT,
                BANK_ACCOUNT_AMOUNT,
                AMOUNT_CLEARED,
                GL_DATE,
                STATUS_DSP,
                STATUS,
                TRX_DATE,
                CLEARED_DATE,
                MATURITY_DATE,
                EXCHANGE_RATE_DATE,
                EXCHANGE_RATE_TYPE,
                USER_EXCHANGE_RATE_TYPE,
                EXCHANGE_RATE,
                BANK_CHARGES,
                BANK_ERRORS,
                BATCH_NAME,
                BATCH_ID,
                AGENT_NAME,
                CUSTOMER_NAME,
                PAYMENT_METHOD,
		VENDOR_NAME,
                CUSTOMER_ID,
                SUPPLIER_ID,
                REFERENCE_TYPE_DSP,
                REFERENCE_TYPE,
                REFERENCE_ID,
                ACTUAL_AMOUNT_CLEARED,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                REMITTANCE_NUMBER,
                CASH_RECEIPT_ID,
                APPLICATION_ID,
                COUNT_CLEARED,
                BANK_CURRENCY_CODE,
                TRX_CURRENCY_TYPE,
                CODE_COMBINATION_ID,
                PERIOD_NAME,
                JOURNAL_ENTRY_NAME,
                DOCUMENT_NUMBER,
                JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
                JOURNAL_CATEGORY,
                BASE_AMOUNT,
                RECEIPT_CLASS_ID,
                RECEIPT_METHOD_ID,
                RECEIPT_CLASS_NAME,
                DEPOSIT_DATE,
                VALUE_DATE,
                REVERSED_RECEIPT_FLAG,
                LEGAL_ENTITY_ID,
                ORG_ID,
		INVOICE_TEXT,
                BANK_ACCOUNT_TEXT,
                CUSTOMER_TEXT,
                CE_BANK_ACCT_USE_ID,
		'N'
      from 	ce_260_transactions_v
      where     bank_account_id = p_bank_account_id;

      av_260_inserted_flag := 'Y';
     END IF;
*/
     IF CE_AUTO_BANK_MATCH.av_260_cf_inserted_flag = 'N' THEN
      cep_standard.debug('inserting data from ce_260_cf_transactions_v');
      insert into ce_available_transactions_tmp
		(seq_id,
		ROW_ID,
		MULTI_SELECT,
		BANK_ACCOUNT_ID,
		BANK_ACCOUNT_NAME,
		BANK_ACCOUNT_NUM,
		BANK_NAME,
		BANK_BRANCH_NAME,
		TRX_ID,
		TRX_TYPE,
		TYPE_MEANING,
		TRX_NUMBER,
		CHECK_NUMBER,
		CURRENCY_CODE,
		AMOUNT,
		BANK_ACCOUNT_AMOUNT,
		AMOUNT_CLEARED,
		GL_DATE,
		STATUS_DSP,
		STATUS,
		TRX_DATE,
		CLEARED_DATE,
		MATURITY_DATE,
		EXCHANGE_RATE_DATE,
		EXCHANGE_RATE_TYPE,
		USER_EXCHANGE_RATE_TYPE,
		EXCHANGE_RATE,
		BANK_CHARGES,
		BANK_ERRORS,
		BATCH_NAME,
		BATCH_ID,
		AGENT_NAME,
		CUSTOMER_NAME,
		PAYMENT_METHOD,
		VENDOR_NAME,
		CUSTOMER_ID,
		SUPPLIER_ID,
		REFERENCE_TYPE_DSP,
		REFERENCE_TYPE,
		REFERENCE_ID,
		ACTUAL_AMOUNT_CLEARED,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		REMITTANCE_NUMBER,
		CASH_RECEIPT_ID,
		APPLICATION_ID,
		COUNT_CLEARED,
		BANK_CURRENCY_CODE,
		TRX_CURRENCY_TYPE,
		CODE_COMBINATION_ID,
		PERIOD_NAME,
		JOURNAL_ENTRY_NAME,
		DOCUMENT_NUMBER,
		JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
		JOURNAL_CATEGORY,
		BASE_AMOUNT,
		RECEIPT_CLASS_ID,
		RECEIPT_METHOD_ID,
		RECEIPT_CLASS_NAME,
		DEPOSIT_DATE,
		VALUE_DATE,
		REVERSED_RECEIPT_FLAG,
		LEGAL_ENTITY_ID,
		ORG_ID,
		INVOICE_TEXT,
		BANK_ACCOUNT_TEXT,
		CUSTOMER_TEXT,
		COUNTERPARTY,
		TRXN_SUBTYPE,
		CE_BANK_ACCT_USE_ID,
		RECONCILED_STATUS_FLAG)
      select	ce_available_transactions_s.nextval,
		ROW_ID,
                MULTI_SELECT,
                BANK_ACCOUNT_ID,
                BANK_ACCOUNT_NAME,
                BANK_ACCOUNT_NUM,
                BANK_NAME,
                BANK_BRANCH_NAME,
                TRX_ID,
                TRX_TYPE,
                TYPE_MEANING,
                TRX_NUMBER,
                CHECK_NUMBER,
		CURRENCY_CODE,
                AMOUNT,
                BANK_ACCOUNT_AMOUNT,
                AMOUNT_CLEARED,
                GL_DATE,
                STATUS_DSP,
                STATUS,
                TRX_DATE,
                CLEARED_DATE,
                MATURITY_DATE,
                EXCHANGE_RATE_DATE,
                EXCHANGE_RATE_TYPE,
                USER_EXCHANGE_RATE_TYPE,
                EXCHANGE_RATE,
                BANK_CHARGES,
                BANK_ERRORS,
                BATCH_NAME,
                BATCH_ID,
                AGENT_NAME,
                CUSTOMER_NAME,
                PAYMENT_METHOD,
		VENDOR_NAME,
                CUSTOMER_ID,
                SUPPLIER_ID,
                REFERENCE_TYPE_DSP,
                REFERENCE_TYPE,
                REFERENCE_ID,
                ACTUAL_AMOUNT_CLEARED,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                REMITTANCE_NUMBER,
                CASH_RECEIPT_ID,
                261,   --APPLICATION_ID,
                COUNT_CLEARED,
                BANK_CURRENCY_CODE,
                TRX_CURRENCY_TYPE,
                CODE_COMBINATION_ID,
                PERIOD_NAME,
                JOURNAL_ENTRY_NAME,
                DOCUMENT_NUMBER,
                JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
                JOURNAL_CATEGORY,
                BASE_AMOUNT,
                RECEIPT_CLASS_ID,
                RECEIPT_METHOD_ID,
                RECEIPT_CLASS_NAME,
                DEPOSIT_DATE,
                VALUE_DATE,
                REVERSED_RECEIPT_FLAG,
                LEGAL_ENTITY_ID,
                ORG_ID,
		INVOICE_TEXT,
                BANK_ACCOUNT_TEXT,
                CUSTOMER_TEXT,
                COUNTERPARTY,
                TRXN_SUBTYPE,
                CE_BANK_ACCT_USE_ID,
		'N'
      from 	ce_260_cf_transactions_v
      where     bank_account_id = p_bank_account_id;

      CE_AUTO_BANK_MATCH.av_260_cf_inserted_flag := 'Y';
     END IF;

    ELSIF l_trx_source = 'JE' THEN

     IF CE_AUTO_BANK_MATCH.av_101_inserted_flag = 'N' THEN

      cep_standard.debug('inserting data from ce_101_transactions_v');

      insert into ce_available_transactions_tmp
		(seq_id,
		ROW_ID,
		MULTI_SELECT,
		BANK_ACCOUNT_ID,
		BANK_ACCOUNT_NAME,
		BANK_ACCOUNT_NUM,
		BANK_NAME,
		BANK_BRANCH_NAME,
		TRX_ID,
		TRX_TYPE,
		TYPE_MEANING,
		TRX_NUMBER,
		CHECK_NUMBER,
		CURRENCY_CODE,
		AMOUNT,
		BANK_ACCOUNT_AMOUNT,
		AMOUNT_CLEARED,
		GL_DATE,
		STATUS_DSP,
		STATUS,
		DESCRIPTION,
		TRX_DATE,
		CLEARED_DATE,
		MATURITY_DATE,
		EXCHANGE_RATE_DATE,
		EXCHANGE_RATE_TYPE,
		USER_EXCHANGE_RATE_TYPE,
		EXCHANGE_RATE,
		BANK_CHARGES,
		BANK_ERRORS,
		BATCH_NAME,
		BATCH_ID,
		AGENT_NAME,
		CUSTOMER_NAME,
		PAYMENT_METHOD,
		VENDOR_NAME,
		CUSTOMER_ID,
		SUPPLIER_ID,
		REFERENCE_TYPE_DSP,
		REFERENCE_TYPE,
		REFERENCE_ID,
		ACTUAL_AMOUNT_CLEARED,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		REMITTANCE_NUMBER,
		CASH_RECEIPT_ID,
		APPLICATION_ID,
		COUNT_CLEARED,
		BANK_CURRENCY_CODE,
		TRX_CURRENCY_TYPE,
		CODE_COMBINATION_ID,
		PERIOD_NAME,
		JOURNAL_ENTRY_NAME,
		DOCUMENT_NUMBER,
		JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
		JOURNAL_CATEGORY,
		BASE_AMOUNT,
		RECEIPT_CLASS_ID,
		RECEIPT_METHOD_ID,
		RECEIPT_CLASS_NAME,
		DEPOSIT_DATE,
		VALUE_DATE,
		REVERSED_RECEIPT_FLAG,
		LEGAL_ENTITY_ID,
		ORG_ID,
		CE_BANK_ACCT_USE_ID,
		RECONCILED_STATUS_FLAG)
      select	ce_available_transactions_s.nextval,
		ROW_ID,
                MULTI_SELECT,
                BANK_ACCOUNT_ID,
                BANK_ACCOUNT_NAME,
                BANK_ACCOUNT_NUM,
                BANK_NAME,
                BANK_BRANCH_NAME,
                TRX_ID,
                TRX_TYPE,
                TYPE_MEANING,
                TRX_NUMBER,
                CHECK_NUMBER,
		CURRENCY_CODE,
                AMOUNT,
                BANK_ACCOUNT_AMOUNT,
                AMOUNT_CLEARED,
                GL_DATE,
                STATUS_DSP,
                STATUS,
                DESCRIPTION,
                TRX_DATE,
                CLEARED_DATE,
                MATURITY_DATE,
                EXCHANGE_RATE_DATE,
                EXCHANGE_RATE_TYPE,
                USER_EXCHANGE_RATE_TYPE,
                EXCHANGE_RATE,
                BANK_CHARGES,
                BANK_ERRORS,
                BATCH_NAME,
                BATCH_ID,
                AGENT_NAME,
                CUSTOMER_NAME,
                PAYMENT_METHOD,
		VENDOR_NAME,
                CUSTOMER_ID,
                SUPPLIER_ID,
                REFERENCE_TYPE_DSP,
                REFERENCE_TYPE,
                REFERENCE_ID,
                ACTUAL_AMOUNT_CLEARED,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                REMITTANCE_NUMBER,
                CASH_RECEIPT_ID,
                APPLICATION_ID,
                COUNT_CLEARED,
                BANK_CURRENCY_CODE,
                TRX_CURRENCY_TYPE,
                CODE_COMBINATION_ID,
                PERIOD_NAME,
                JOURNAL_ENTRY_NAME,
                DOCUMENT_NUMBER,
                JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
                JOURNAL_CATEGORY,
                BASE_AMOUNT,
                RECEIPT_CLASS_ID,
                RECEIPT_METHOD_ID,
                RECEIPT_CLASS_NAME,
                DEPOSIT_DATE,
                VALUE_DATE,
                REVERSED_RECEIPT_FLAG,
                LEGAL_ENTITY_ID,
                ORG_ID,
                CE_BANK_ACCT_USE_ID,
		'N'
      from 	ce_101_transactions_v
      where     bank_account_id = p_bank_account_id;

      CE_AUTO_BANK_MATCH.av_101_inserted_flag := 'Y';
     END IF;

    ELSIF l_trx_source = 'OI' THEN

     -- Bug 7356199 removed the inserting data from ce_185_transactions_v
     -- as ce_999_transactions_v consists a union  of ce_185_transactions_v
     IF CE_AUTO_BANK_MATCH.av_999_inserted_flag = 'N' THEN

      cep_standard.debug('inserting data from ce_999_transactions_v');

      insert into ce_available_transactions_tmp
		(seq_id,
		ROW_ID,
		MULTI_SELECT,
		BANK_ACCOUNT_ID,
		BANK_ACCOUNT_NAME,
		BANK_ACCOUNT_NUM,
		BANK_NAME,
		BANK_BRANCH_NAME,
		TRX_ID,
		TRX_TYPE,
		TYPE_MEANING,
		TRX_NUMBER,
		CHECK_NUMBER,
		CURRENCY_CODE,
		AMOUNT,
		BANK_ACCOUNT_AMOUNT,
		AMOUNT_CLEARED,
		GL_DATE,
		STATUS_DSP,
		STATUS,
		TRX_DATE,
		CLEARED_DATE,
		MATURITY_DATE,
		EXCHANGE_RATE_DATE,
		EXCHANGE_RATE_TYPE,
		USER_EXCHANGE_RATE_TYPE,
		EXCHANGE_RATE,
		BANK_CHARGES,
		BANK_ERRORS,
		BATCH_NAME,
		BATCH_ID,
		AGENT_NAME,
		CUSTOMER_NAME,
		PAYMENT_METHOD,
		VENDOR_NAME,
		CUSTOMER_ID,
		SUPPLIER_ID,
		REFERENCE_TYPE_DSP,
		REFERENCE_TYPE,
		REFERENCE_ID,
		ACTUAL_AMOUNT_CLEARED,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		REMITTANCE_NUMBER,
		CASH_RECEIPT_ID,
		APPLICATION_ID,
		COUNT_CLEARED,
		BANK_CURRENCY_CODE,
		TRX_CURRENCY_TYPE,
		CODE_COMBINATION_ID,
		PERIOD_NAME,
		JOURNAL_ENTRY_NAME,
		DOCUMENT_NUMBER,
		JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
		JOURNAL_CATEGORY,
		BASE_AMOUNT,
		RECEIPT_CLASS_ID,
		RECEIPT_METHOD_ID,
		RECEIPT_CLASS_NAME,
		DEPOSIT_DATE,
		VALUE_DATE,
		REVERSED_RECEIPT_FLAG,
		LEGAL_ENTITY_ID,
		ORG_ID,
		CE_BANK_ACCT_USE_ID,
		RECONCILED_STATUS_FLAG)
      select	ce_available_transactions_s.nextval,
		ROW_ID,
                MULTI_SELECT,
                BANK_ACCOUNT_ID,
                BANK_ACCOUNT_NAME,
                BANK_ACCOUNT_NUM,
                BANK_NAME,
                BANK_BRANCH_NAME,
                TRX_ID,
                TRX_TYPE,
                TYPE_MEANING,
                TRX_NUMBER,
                CHECK_NUMBER,
		CURRENCY_CODE,
                AMOUNT,
                BANK_ACCOUNT_AMOUNT,
                AMOUNT_CLEARED,
                GL_DATE,
                STATUS_DSP,
                STATUS,
                TRX_DATE,
                CLEARED_DATE,
                MATURITY_DATE,
                EXCHANGE_RATE_DATE,
                EXCHANGE_RATE_TYPE,
                USER_EXCHANGE_RATE_TYPE,
                EXCHANGE_RATE,
                BANK_CHARGES,
                BANK_ERRORS,
                BATCH_NAME,
                BATCH_ID,
                AGENT_NAME,
                CUSTOMER_NAME,
                PAYMENT_METHOD,
		VENDOR_NAME,
                CUSTOMER_ID,
                SUPPLIER_ID,
                REFERENCE_TYPE_DSP,
                REFERENCE_TYPE,
                REFERENCE_ID,
                ACTUAL_AMOUNT_CLEARED,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                REMITTANCE_NUMBER,
                CASH_RECEIPT_ID,
                APPLICATION_ID,
                COUNT_CLEARED,
                BANK_CURRENCY_CODE,
                TRX_CURRENCY_TYPE,
                CODE_COMBINATION_ID,
                PERIOD_NAME,
                JOURNAL_ENTRY_NAME,
                DOCUMENT_NUMBER,
                JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
                JOURNAL_CATEGORY,
                BASE_AMOUNT,
                RECEIPT_CLASS_ID,
                RECEIPT_METHOD_ID,
                RECEIPT_CLASS_NAME,
                DEPOSIT_DATE,
                VALUE_DATE,
                REVERSED_RECEIPT_FLAG,
                LEGAL_ENTITY_ID,
                ORG_ID,
                CE_BANK_ACCT_USE_ID,
		'N'
      from 	ce_999_transactions_v
      where     bank_account_id = p_bank_account_id;

      CE_AUTO_BANK_MATCH.av_999_inserted_flag := 'Y';
     END IF;

    ELSIF l_trx_source = 'PAY' THEN
     IF CE_AUTO_BANK_MATCH.av_801_inserted_flag = 'N' THEN
      cep_standard.debug('inserting data from ce_801_transactions_v');

      insert into ce_available_transactions_tmp
		(seq_id,
		ROW_ID,
		MULTI_SELECT,
		BANK_ACCOUNT_ID,
		BANK_ACCOUNT_NAME,
		BANK_ACCOUNT_NUM,
		BANK_NAME,
		BANK_BRANCH_NAME,
		TRX_ID,
		TRX_TYPE,
		TYPE_MEANING,
		TRX_NUMBER,
		CHECK_NUMBER,
		CURRENCY_CODE,
		AMOUNT,
		BANK_ACCOUNT_AMOUNT,
		AMOUNT_CLEARED,
		GL_DATE,
		STATUS_DSP,
		STATUS,
		TRX_DATE,
		CLEARED_DATE,
		MATURITY_DATE,
		EXCHANGE_RATE_DATE,
		EXCHANGE_RATE_TYPE,
		USER_EXCHANGE_RATE_TYPE,
		EXCHANGE_RATE,
		BANK_CHARGES,
		BANK_ERRORS,
		BATCH_NAME,
		BATCH_ID,
		AGENT_NAME,
		CUSTOMER_NAME,
		PAYMENT_METHOD,
		VENDOR_NAME,
		CUSTOMER_ID,
		SUPPLIER_ID,
		REFERENCE_TYPE_DSP,
		REFERENCE_TYPE,
		REFERENCE_ID,
		ACTUAL_AMOUNT_CLEARED,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		REMITTANCE_NUMBER,
		CASH_RECEIPT_ID,
		APPLICATION_ID,
		COUNT_CLEARED,
		BANK_CURRENCY_CODE,
		TRX_CURRENCY_TYPE,
		CODE_COMBINATION_ID,
		PERIOD_NAME,
		JOURNAL_ENTRY_NAME,
		DOCUMENT_NUMBER,
		JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
		JOURNAL_CATEGORY,
		BASE_AMOUNT,
		RECEIPT_CLASS_ID,
		RECEIPT_METHOD_ID,
		RECEIPT_CLASS_NAME,
		DEPOSIT_DATE,
		VALUE_DATE,
		REVERSED_RECEIPT_FLAG,
		LEGAL_ENTITY_ID,
		ORG_ID,
		CE_BANK_ACCT_USE_ID,
		RECONCILED_STATUS_FLAG)
      select	ce_available_transactions_s.nextval,
		ROW_ID,
                MULTI_SELECT,
                BANK_ACCOUNT_ID,
                BANK_ACCOUNT_NAME,
                BANK_ACCOUNT_NUM,
                BANK_NAME,
                BANK_BRANCH_NAME,
                TRX_ID,
                TRX_TYPE,
                TYPE_MEANING,
                TRX_NUMBER,
                CHECK_NUMBER,
		CURRENCY_CODE,
                AMOUNT,
                BANK_ACCOUNT_AMOUNT,
                AMOUNT_CLEARED,
                GL_DATE,
                STATUS_DSP,
                STATUS,
                TRX_DATE,
                CLEARED_DATE,
                MATURITY_DATE,
                EXCHANGE_RATE_DATE,
                EXCHANGE_RATE_TYPE,
                USER_EXCHANGE_RATE_TYPE,
                EXCHANGE_RATE,
                BANK_CHARGES,
                BANK_ERRORS,
                BATCH_NAME,
                BATCH_ID,
                AGENT_NAME,
                CUSTOMER_NAME,
                PAYMENT_METHOD,
		VENDOR_NAME,
                CUSTOMER_ID,
                SUPPLIER_ID,
                REFERENCE_TYPE_DSP,
                REFERENCE_TYPE,
                REFERENCE_ID,
                ACTUAL_AMOUNT_CLEARED,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                REMITTANCE_NUMBER,
                CASH_RECEIPT_ID,
                APPLICATION_ID,
                COUNT_CLEARED,
                BANK_CURRENCY_CODE,
                TRX_CURRENCY_TYPE,
                CODE_COMBINATION_ID,
                PERIOD_NAME,
                JOURNAL_ENTRY_NAME,
                DOCUMENT_NUMBER,
                JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
                JOURNAL_CATEGORY,
                BASE_AMOUNT,
                RECEIPT_CLASS_ID,
                RECEIPT_METHOD_ID,
                RECEIPT_CLASS_NAME,
                DEPOSIT_DATE,
                VALUE_DATE,
                REVERSED_RECEIPT_FLAG,
                LEGAL_ENTITY_ID,
                ORG_ID,
                CE_BANK_ACCT_USE_ID,
		'N'
      from 	ce_801_transactions_v
      where     bank_account_id = p_bank_account_id;

      CE_AUTO_BANK_MATCH.av_801_inserted_flag := 'Y';
     END IF;

    ELSIF l_trx_source = 'PAY_EFT' THEN
     IF CE_AUTO_BANK_MATCH.av_801_eft_inserted_flag = 'N' THEN
      cep_standard.debug('inserting data from ce_801_eft_transactions_v');

      insert into ce_available_transactions_tmp
		(seq_id,
		ROW_ID,
		MULTI_SELECT,
		BANK_ACCOUNT_ID,
		BANK_ACCOUNT_NAME,
		BANK_ACCOUNT_NUM,
		BANK_NAME,
		BANK_BRANCH_NAME,
		TRX_ID,
		TRX_TYPE,
		TYPE_MEANING,
		TRX_NUMBER,
		CHECK_NUMBER,
		CURRENCY_CODE,
		AMOUNT,
		BANK_ACCOUNT_AMOUNT,
		AMOUNT_CLEARED,
		GL_DATE,
		STATUS_DSP,
		STATUS,
		TRX_DATE,
		CLEARED_DATE,
		MATURITY_DATE,
		EXCHANGE_RATE_DATE,
		EXCHANGE_RATE_TYPE,
		USER_EXCHANGE_RATE_TYPE,
		EXCHANGE_RATE,
		BANK_CHARGES,
		BANK_ERRORS,
		BATCH_NAME,
		BATCH_ID,
		AGENT_NAME,
		CUSTOMER_NAME,
		PAYMENT_METHOD,
		VENDOR_NAME,
		CUSTOMER_ID,
		SUPPLIER_ID,
		REFERENCE_TYPE_DSP,
		REFERENCE_TYPE,
		REFERENCE_ID,
		ACTUAL_AMOUNT_CLEARED,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		REMITTANCE_NUMBER,
		CASH_RECEIPT_ID,
		APPLICATION_ID,
		COUNT_CLEARED,
		BANK_CURRENCY_CODE,
		TRX_CURRENCY_TYPE,
		CODE_COMBINATION_ID,
		PERIOD_NAME,
		JOURNAL_ENTRY_NAME,
		DOCUMENT_NUMBER,
		JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
		JOURNAL_CATEGORY,
		BASE_AMOUNT,
		RECEIPT_CLASS_ID,
		RECEIPT_METHOD_ID,
		RECEIPT_CLASS_NAME,
		DEPOSIT_DATE,
		VALUE_DATE,
		REVERSED_RECEIPT_FLAG,
		LEGAL_ENTITY_ID,
		ORG_ID,
		CE_BANK_ACCT_USE_ID,
		RECONCILED_STATUS_FLAG)
      select 	ce_available_transactions_s.nextval,
		ROW_ID,
                MULTI_SELECT,
                BANK_ACCOUNT_ID,
                BANK_ACCOUNT_NAME,
                BANK_ACCOUNT_NUM,
                BANK_NAME,
                BANK_BRANCH_NAME,
                TRX_ID,
                TRX_TYPE,
                TYPE_MEANING,
                TRX_NUMBER,
                CHECK_NUMBER,
		CURRENCY_CODE,
                AMOUNT,
                BANK_ACCOUNT_AMOUNT,
                AMOUNT_CLEARED,
                GL_DATE,
                STATUS_DSP,
                STATUS,
                TRX_DATE,
                CLEARED_DATE,
                MATURITY_DATE,
                EXCHANGE_RATE_DATE,
                EXCHANGE_RATE_TYPE,
                USER_EXCHANGE_RATE_TYPE,
                EXCHANGE_RATE,
                BANK_CHARGES,
                BANK_ERRORS,
                BATCH_NAME,
                BATCH_ID,
                AGENT_NAME,
                CUSTOMER_NAME,
                PAYMENT_METHOD,
		VENDOR_NAME,
                CUSTOMER_ID,
                SUPPLIER_ID,
                REFERENCE_TYPE_DSP,
                REFERENCE_TYPE,
                REFERENCE_ID,
                ACTUAL_AMOUNT_CLEARED,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                REMITTANCE_NUMBER,
                CASH_RECEIPT_ID,
                802,   --APPLICATION_ID,
                COUNT_CLEARED,
                BANK_CURRENCY_CODE,
                TRX_CURRENCY_TYPE,
                CODE_COMBINATION_ID,
                PERIOD_NAME,
                JOURNAL_ENTRY_NAME,
                DOCUMENT_NUMBER,
                JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
                JOURNAL_CATEGORY,
                BASE_AMOUNT,
                RECEIPT_CLASS_ID,
                RECEIPT_METHOD_ID,
                RECEIPT_CLASS_NAME,
                DEPOSIT_DATE,
                VALUE_DATE,
                REVERSED_RECEIPT_FLAG,
                LEGAL_ENTITY_ID,
                ORG_ID,
                CE_BANK_ACCT_USE_ID,
		'N'
      from 	ce_801_eft_transactions_v
      where     bank_account_id = p_bank_account_id;

      CE_AUTO_BANK_MATCH.av_801_eft_inserted_flag := 'Y';
     END IF;

    ELSIF l_trx_source = 'X' OR l_trx_source is null THEN
      IF l_trx_type IN ('MISC_CREDIT', 'MISC_DEBIT') THEN
        IF l_matching_against IN ('STMT', 'MS', 'SM') THEN
          IF CE_AUTO_BANK_MATCH.av_260_inserted_flag = 'N' THEN
            cep_standard.debug('inserting data from ce_260_transactions_v');
            insert into ce_available_transactions_tmp
		(seq_id,
		ROW_ID,
		MULTI_SELECT,
		BANK_ACCOUNT_ID,
		BANK_ACCOUNT_NAME,
		BANK_ACCOUNT_NUM,
		BANK_NAME,
		BANK_BRANCH_NAME,
		TRX_ID,
		TRX_TYPE,
		TYPE_MEANING,
		TRX_NUMBER,
		CHECK_NUMBER,
		CURRENCY_CODE,
		AMOUNT,
		BANK_ACCOUNT_AMOUNT,
		AMOUNT_CLEARED,
		GL_DATE,
		STATUS_DSP,
		STATUS,
		TRX_DATE,
		CLEARED_DATE,
		MATURITY_DATE,
		EXCHANGE_RATE_DATE,
		EXCHANGE_RATE_TYPE,
		USER_EXCHANGE_RATE_TYPE,
		EXCHANGE_RATE,
		BANK_CHARGES,
		BANK_ERRORS,
		BATCH_NAME,
		BATCH_ID,
		AGENT_NAME,
		CUSTOMER_NAME,
		PAYMENT_METHOD,
		VENDOR_NAME,
		CUSTOMER_ID,
		SUPPLIER_ID,
		REFERENCE_TYPE_DSP,
		REFERENCE_TYPE,
		REFERENCE_ID,
		ACTUAL_AMOUNT_CLEARED,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		REMITTANCE_NUMBER,
		CASH_RECEIPT_ID,
		APPLICATION_ID,
		COUNT_CLEARED,
		BANK_CURRENCY_CODE,
		TRX_CURRENCY_TYPE,
		CODE_COMBINATION_ID,
		PERIOD_NAME,
		JOURNAL_ENTRY_NAME,
		DOCUMENT_NUMBER,
		JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
		JOURNAL_CATEGORY,
		BASE_AMOUNT,
		RECEIPT_CLASS_ID,
		RECEIPT_METHOD_ID,
		RECEIPT_CLASS_NAME,
		DEPOSIT_DATE,
		VALUE_DATE,
		REVERSED_RECEIPT_FLAG,
		LEGAL_ENTITY_ID,
		ORG_ID,
		INVOICE_TEXT,
		BANK_ACCOUNT_TEXT,
		CUSTOMER_TEXT,
		CE_BANK_ACCT_USE_ID,
		RECONCILED_STATUS_FLAG)
         select ce_available_transactions_s.nextval,
		ROW_ID,
                MULTI_SELECT,
                BANK_ACCOUNT_ID,
                BANK_ACCOUNT_NAME,
                BANK_ACCOUNT_NUM,
                BANK_NAME,
                BANK_BRANCH_NAME,
                TRX_ID,
                TRX_TYPE,
                TYPE_MEANING,
                TRX_NUMBER,
                CHECK_NUMBER,
		CURRENCY_CODE,
                AMOUNT,
                BANK_ACCOUNT_AMOUNT,
                AMOUNT_CLEARED,
                GL_DATE,
                STATUS_DSP,
                STATUS,
                TRX_DATE,
                CLEARED_DATE,
                MATURITY_DATE,
                EXCHANGE_RATE_DATE,
                EXCHANGE_RATE_TYPE,
                USER_EXCHANGE_RATE_TYPE,
                EXCHANGE_RATE,
                BANK_CHARGES,
                BANK_ERRORS,
                BATCH_NAME,
                BATCH_ID,
                AGENT_NAME,
                CUSTOMER_NAME,
                PAYMENT_METHOD,
		VENDOR_NAME,
                CUSTOMER_ID,
                SUPPLIER_ID,
                REFERENCE_TYPE_DSP,
                REFERENCE_TYPE,
                REFERENCE_ID,
                ACTUAL_AMOUNT_CLEARED,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                REMITTANCE_NUMBER,
                CASH_RECEIPT_ID,
                APPLICATION_ID,
                COUNT_CLEARED,
                BANK_CURRENCY_CODE,
                TRX_CURRENCY_TYPE,
                CODE_COMBINATION_ID,
                PERIOD_NAME,
                JOURNAL_ENTRY_NAME,
                DOCUMENT_NUMBER,
                JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
                JOURNAL_CATEGORY,
                BASE_AMOUNT,
                RECEIPT_CLASS_ID,
                RECEIPT_METHOD_ID,
                RECEIPT_CLASS_NAME,
                DEPOSIT_DATE,
                VALUE_DATE,
                REVERSED_RECEIPT_FLAG,
                LEGAL_ENTITY_ID,
                ORG_ID,
		INVOICE_TEXT,
                BANK_ACCOUNT_TEXT,
                CUSTOMER_TEXT,
                CE_BANK_ACCT_USE_ID,
		'N'
          from 	ce_260_transactions_v
          where bank_account_id = p_bank_account_id;

            CE_AUTO_BANK_MATCH.av_260_inserted_flag := 'Y';
          END IF;  --  CE_AUTO_BANK_MATCH.av_260_inserted_flag = 'N'

        END IF;  -- l_matching_against

        IF l_matching_against IN ('MISC', 'MS', 'SM') THEN
          IF CE_AUTO_BANK_MATCH.av_222_inserted_flag = 'N' THEN
            cep_standard.debug('inserting data from ce_222_transactions_v');
            insert into ce_available_transactions_tmp
		(seq_id,
		ROW_ID,
		MULTI_SELECT,
		BANK_ACCOUNT_ID,
		BANK_ACCOUNT_NAME,
		BANK_ACCOUNT_NUM,
		BANK_NAME,
		BANK_BRANCH_NAME,
		TRX_ID,
		TRX_TYPE,
		TYPE_MEANING,
		TRX_NUMBER,
		CHECK_NUMBER,
		CURRENCY_CODE,
		AMOUNT,
		BANK_ACCOUNT_AMOUNT,
		AMOUNT_CLEARED,
		GL_DATE,
		STATUS_DSP,
		STATUS,
		TRX_DATE,
		CLEARED_DATE,
		MATURITY_DATE,
		EXCHANGE_RATE_DATE,
		EXCHANGE_RATE_TYPE,
		USER_EXCHANGE_RATE_TYPE,
		EXCHANGE_RATE,
		BANK_CHARGES,
		BANK_ERRORS,
		BATCH_NAME,
		BATCH_ID,
		AGENT_NAME,
		CUSTOMER_NAME,
		PAYMENT_METHOD,
		VENDOR_NAME,
		CUSTOMER_ID,
		SUPPLIER_ID,
		REFERENCE_TYPE_DSP,
		REFERENCE_TYPE,
		REFERENCE_ID,
		ACTUAL_AMOUNT_CLEARED,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		REMITTANCE_NUMBER,
		CASH_RECEIPT_ID,
		APPLICATION_ID,
		COUNT_CLEARED,
		BANK_CURRENCY_CODE,
		TRX_CURRENCY_TYPE,
		CODE_COMBINATION_ID,
		PERIOD_NAME,
		JOURNAL_ENTRY_NAME,
		DOCUMENT_NUMBER,
		JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
		JOURNAL_CATEGORY,
		BASE_AMOUNT,
		RECEIPT_CLASS_ID,
		RECEIPT_METHOD_ID,
		RECEIPT_CLASS_NAME,
		DEPOSIT_DATE,
		VALUE_DATE,
		REVERSED_RECEIPT_FLAG,
		LEGAL_ENTITY_ID,
		ORG_ID,
		CE_BANK_ACCT_USE_ID,
		RECONCILED_STATUS_FLAG)
      select	ce_available_transactions_s.nextval,
		ROW_ID,
                MULTI_SELECT,
                BANK_ACCOUNT_ID,
                BANK_ACCOUNT_NAME,
                BANK_ACCOUNT_NUM,
                BANK_NAME,
                BANK_BRANCH_NAME,
                TRX_ID,
                TRX_TYPE,
                TYPE_MEANING,
                TRX_NUMBER,
                CHECK_NUMBER,
		CURRENCY_CODE,
                AMOUNT,
                BANK_ACCOUNT_AMOUNT,
                AMOUNT_CLEARED,
                GL_DATE,
                STATUS_DSP,
                STATUS,
                TRX_DATE,
                CLEARED_DATE,
                MATURITY_DATE,
                EXCHANGE_RATE_DATE,
                EXCHANGE_RATE_TYPE,
                USER_EXCHANGE_RATE_TYPE,
                EXCHANGE_RATE,
                BANK_CHARGES,
                BANK_ERRORS,
                BATCH_NAME,
                BATCH_ID,
                AGENT_NAME,
                CUSTOMER_NAME,
                PAYMENT_METHOD,
		VENDOR_NAME,
                CUSTOMER_ID,
                SUPPLIER_ID,
                REFERENCE_TYPE_DSP,
                REFERENCE_TYPE,
                REFERENCE_ID,
                ACTUAL_AMOUNT_CLEARED,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                REMITTANCE_NUMBER,
                CASH_RECEIPT_ID,
                APPLICATION_ID,
                COUNT_CLEARED,
                BANK_CURRENCY_CODE,
                TRX_CURRENCY_TYPE,
                CODE_COMBINATION_ID,
                PERIOD_NAME,
                JOURNAL_ENTRY_NAME,
                DOCUMENT_NUMBER,
                JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
                JOURNAL_CATEGORY,
                BASE_AMOUNT,
                RECEIPT_CLASS_ID,
                RECEIPT_METHOD_ID,
                RECEIPT_CLASS_NAME,
                DEPOSIT_DATE,
                VALUE_DATE,
                REVERSED_RECEIPT_FLAG,
                LEGAL_ENTITY_ID,
                ORG_ID,
                CE_BANK_ACCT_USE_ID,
		'N'
          from  ce_222_transactions_v
          where bank_account_id = p_bank_account_id;

            CE_AUTO_BANK_MATCH.av_222_inserted_flag := 'Y';
          END IF;  -- CE_AUTO_BANK_MATCH.av_222_inserted_flag = 'N'
        END IF;   -- l_matching_against

      ELSIF l_trx_type IN ('REJECTED', 'NSF') THEN
        IF CE_AUTO_BANK_MATCH.av_222_inserted_flag = 'N' THEN
          cep_standard.debug('inserting data from ce_222_transactions_v');

          insert into ce_available_transactions_tmp
		(seq_id,
		ROW_ID,
		MULTI_SELECT,
		BANK_ACCOUNT_ID,
		BANK_ACCOUNT_NAME,
		BANK_ACCOUNT_NUM,
		BANK_NAME,
		BANK_BRANCH_NAME,
		TRX_ID,
		TRX_TYPE,
		TYPE_MEANING,
		TRX_NUMBER,
		CHECK_NUMBER,
		CURRENCY_CODE,
		AMOUNT,
		BANK_ACCOUNT_AMOUNT,
		AMOUNT_CLEARED,
		GL_DATE,
		STATUS_DSP,
		STATUS,
		TRX_DATE,
		CLEARED_DATE,
		MATURITY_DATE,
		EXCHANGE_RATE_DATE,
		EXCHANGE_RATE_TYPE,
		USER_EXCHANGE_RATE_TYPE,
		EXCHANGE_RATE,
		BANK_CHARGES,
		BANK_ERRORS,
		BATCH_NAME,
		BATCH_ID,
		AGENT_NAME,
		CUSTOMER_NAME,
		PAYMENT_METHOD,
		VENDOR_NAME,
		CUSTOMER_ID,
		SUPPLIER_ID,
		REFERENCE_TYPE_DSP,
		REFERENCE_TYPE,
		REFERENCE_ID,
		ACTUAL_AMOUNT_CLEARED,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		REMITTANCE_NUMBER,
		CASH_RECEIPT_ID,
		APPLICATION_ID,
		COUNT_CLEARED,
		BANK_CURRENCY_CODE,
		TRX_CURRENCY_TYPE,
		CODE_COMBINATION_ID,
		PERIOD_NAME,
		JOURNAL_ENTRY_NAME,
		DOCUMENT_NUMBER,
		JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
		JOURNAL_CATEGORY,
		BASE_AMOUNT,
		RECEIPT_CLASS_ID,
		RECEIPT_METHOD_ID,
		RECEIPT_CLASS_NAME,
		DEPOSIT_DATE,
		VALUE_DATE,
		REVERSED_RECEIPT_FLAG,
		LEGAL_ENTITY_ID,
		ORG_ID,
		CE_BANK_ACCT_USE_ID,
		RECONCILED_STATUS_FLAG)
      select	ce_available_transactions_s.nextval,
		ROW_ID,
                MULTI_SELECT,
                BANK_ACCOUNT_ID,
                BANK_ACCOUNT_NAME,
                BANK_ACCOUNT_NUM,
                BANK_NAME,
                BANK_BRANCH_NAME,
                TRX_ID,
                TRX_TYPE,
                TYPE_MEANING,
                TRX_NUMBER,
                CHECK_NUMBER,
		CURRENCY_CODE,
                AMOUNT,
                BANK_ACCOUNT_AMOUNT,
                AMOUNT_CLEARED,
                GL_DATE,
                STATUS_DSP,
                STATUS,
                TRX_DATE,
                CLEARED_DATE,
                MATURITY_DATE,
                EXCHANGE_RATE_DATE,
                EXCHANGE_RATE_TYPE,
                USER_EXCHANGE_RATE_TYPE,
                EXCHANGE_RATE,
                BANK_CHARGES,
                BANK_ERRORS,
                BATCH_NAME,
                BATCH_ID,
                AGENT_NAME,
                CUSTOMER_NAME,
                PAYMENT_METHOD,
		VENDOR_NAME,
                CUSTOMER_ID,
                SUPPLIER_ID,
                REFERENCE_TYPE_DSP,
                REFERENCE_TYPE,
                REFERENCE_ID,
                ACTUAL_AMOUNT_CLEARED,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                REMITTANCE_NUMBER,
                CASH_RECEIPT_ID,
                APPLICATION_ID,
                COUNT_CLEARED,
                BANK_CURRENCY_CODE,
                TRX_CURRENCY_TYPE,
                CODE_COMBINATION_ID,
                PERIOD_NAME,
                JOURNAL_ENTRY_NAME,
                DOCUMENT_NUMBER,
                JOURNAL_ENTRY_LINE_NUMBER,
		CLEARING_TRX_TYPE,
                JOURNAL_CATEGORY,
                BASE_AMOUNT,
                RECEIPT_CLASS_ID,
                RECEIPT_METHOD_ID,
                RECEIPT_CLASS_NAME,
                DEPOSIT_DATE,
                VALUE_DATE,
                REVERSED_RECEIPT_FLAG,
                LEGAL_ENTITY_ID,
                ORG_ID,
                CE_BANK_ACCT_USE_ID,
		'N'
          from 	ce_222_transactions_v
          where bank_account_id = p_bank_account_id;

         CE_AUTO_BANK_MATCH.av_222_inserted_flag := 'Y';
       END IF;  -- av_222_inserted_flag = 'N'
      END IF;   -- l_trx_type
    END IF;  -- l_trx_source
  END LOOP;  -- r_trx_source cursor
  CLOSE r_trx_source;
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: populate_available_gt');
    IF r_trx_source%ISOPEN THEN
      CLOSE r_trx_source;
    END IF;
    RAISE;
END populate_available_gt;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       update_gt_reconciled_status                                     |
|                                                                       |
|  DESCRIPTION                                                          |
|       update the reconciled_status_flag of table                      |
|       ce_available_transactions_tmp                                   |
|                                                                       |
|  CALLED BY                                                            |
|       match_process                                                   |
|       match_stmt_line_JE                                              |
|       CE_AUTO_BANK_CLEAR1.reconcile_pbatch                            |
|       CE_AUTO_BANK_CLEAR1.reconcile_rbatch                            |
|       CE_AUTO_BANK_CLEAR1.reconcile_pay_eft                           |
|                                                                       |
|  HISTORY                                                              |
|       11-MAY-2006        Xin Wang     Created                         |
 --------------------------------------------------------------------- */
PROCEDURE update_gt_reconciled_status(p_seq_id	NUMBER,
				      p_status	VARCHAR2) IS
BEGIN
  update ce_available_transactions_tmp
  set    reconciled_status_flag = p_status
  where  seq_id = p_seq_id;
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: update_gt_reconciled_status');
    RAISE;
END update_gt_reconciled_status;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       update_gt_reconciled_status                                     |
|                                                                       |
|  DESCRIPTION                                                          |
|       update the reconciled_status_flag of table                      |
|       ce_available_transactions_tmp                                   |
|       mainly used to update the status to 'N' during unreconciliation |
|                                                                       |
|  CALLED BY                                                            |
|       CE_AUTO_BANK_CLEAR1.unclear_process                             |
|                                                                       |
|  HISTORY                                                              |
|       11-MAY-2006        Xin Wang     Created                         |
 --------------------------------------------------------------------- */
PROCEDURE update_gt_reconciled_status(p_application_id          NUMBER,
                                      p_trx_id                  NUMBER,
                                      p_reconciled_status       VARCHAR2) IS
BEGIN
  update ce_available_transactions_tmp
  set    reconciled_status_flag = p_reconciled_status
  where  application_id = p_application_id
  and	 trx_id = p_trx_id;
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: update_gt_reconciled_status');
    RAISE;
END update_gt_reconciled_status;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       update_gt_reconciled_status                                     |
|                                                                       |
|  DESCRIPTION                                                          |
|       update the reconciled_status_flag of table                      |
|       ce_available_transactions_tmp                                   |
|       mainly used to update the status to 'N' during 			|
|	auto unreconciliation 						|
|                                                                       |
|  CALLED BY                                                            |
|       CE_AUTO_BANK_CLEAR1.unclear_process                             |
|                                                                       |
|  HISTORY                                                              |
|       11-MAY-2006        Xin Wang     Created                         |
 --------------------------------------------------------------------- */
PROCEDURE update_gt_reconciled_status(p_reconciled_status       VARCHAR2) IS
BEGIN
  update ce_available_transactions_tmp
  set    reconciled_status_flag = p_reconciled_status;
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: update_gt_reconciled_status');
    RAISE;
END update_gt_reconciled_status;


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	match_process							|
|									|
|  DESCRIPTION								|
|	Reconcile the imported statement.				|
|									|
|	Match statement lines by looping:				|
|	1. r_branch_cursor - find all bank accounts
|	2. r_bank_cursor - find all statements for each bank account
|       3. line_cursor - find all statement lines for each statement
|       4. trx_code_cursor - match each statement line based on the
|                            trx code source by sequences		|
|	5. Do not need to loop through each bank_acct_uses_id (OU/BG/LE)|
|	   The base views ce_*_transactions_v already has the security	|
|	   access.  If the org_id or legal_entity_id is passed, then we
|          need to restrict the matching to the org_id/legal_entity_id.	|
|	   If no org_id or legal_entity_id is passed, then we will
|           match trx source across OUs/BGs/LEs.  This is to check for
|           duplicates across OUs/BGs/LEs.  If a line could be
|           reconciled to two trxns that have the same reference
|           but happen to be in two different OUs, then the right
|           thing is to flag them as duplicates. (Omar)
|									|
|  CALLS								|
|	Lock_Statement							|
|	Update_GL_Date							|
|	CE_RECONCILIATION_ERRORS_PKG.delete_row				|
|	Lock_Statement_Line						|
|	Match_Statement_Line						|
|	CE_AUTO_BANK_CLEAR.reconcile_process				|
|	CE_RECONCILIATION_ERRORS_PKG.insert_row				|
|	Get_Min_Statement_Line_Id					|
|									|
|  CALLED BY								|
|	statement							|
 --------------------------------------------------------------------- */
PROCEDURE match_process IS
  error_statement_line_id	CE_STATEMENT_LINES.statement_line_id%TYPE;
  lockhandle			VARCHAR2(128);
  lock_status			NUMBER;
  statement_line_count		NUMBER;
  i				NUMBER;
  j				NUMBER;
  rec_status                    NUMBER;
--  account_type		CE_BANK_ACCOUNTS.account_classification%TYPE;
  accounting_method_found	NUMBER := 0;
  row_count                     NUMBER;
  ignore_trx_id		NUMBER;
  ignore_trx_id2		NUMBER;
  ignore_trx_id3		NUMBER;
  ignore_trx_id4		NUMBER;
  x_pay_count		NUMBER;
  current_org_id           NUMBER;
  x_trx_code_row_count        NUMBER;
BEGIN
  /* Bug 3364143 - Start code fix */
   IF CE_AUTO_BANK_REC.G_ce_debug_flag in ('Y', 'C') THEN
          cep_standard.enable_debug(CE_AUTO_BANK_REC.G_debug_path,
			      CE_AUTO_BANK_REC.G_debug_file);
  end if;
  /* Bug 3364143 - End code fix */

  cep_standard.debug('========== START MATCHING ========== ');
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.match_process');

 -- populate ce_security_profiles_tmp table with ce_security_procfiles_v
 CEP_STANDARD.init_security;

/* --bug3676745 move this down to after fetch r_branch_cursor
  cep_standard.debug('Get AR accounting method.');

  -- bug 1796965
  SELECT count(*)
  INTO	accounting_method_found
  FROM	ar_system_parameters s
  where s.org_id = CE_AUTO_BANK_REC.G_org_id;

  if (accounting_method_found = 1) then
    SELECT accounting_method
    INTO   CE_AUTO_BANK_MATCH.ar_accounting_method
    FROM   ar_system_parameters s
    where s.org_id = CE_AUTO_BANK_REC.G_org_id;
  else
    CE_AUTO_BANK_MATCH.ar_accounting_method := NULL;
  end if;
*/
  cep_standard.debug('>>CE_AUTO_BANK_MATCH.Opening r_branch_cursor');
  OPEN r_branch_cursor( CE_AUTO_BANK_REC.G_bank_branch_id,
			CE_AUTO_BANK_REC.G_bank_account_id,
			CE_AUTO_BANK_REC.G_org_id,
			CE_AUTO_BANK_REC.G_legal_entity_id);
  j := 0;
  LOOP
    cep_standard.debug('>>CE_AUTO_BANK_MATCH.Fetching r_branch_cursor');
    FETCH r_branch_cursor INTO CE_AUTO_BANK_MATCH.csh_bank_account_id,
				CE_AUTO_BANK_MATCH.ba_owner_le_id,
				CE_AUTO_BANK_MATCH.aba_asset_code_combination_id;
/*
    -- bug 5221561
    -- for every bank account, reinitialize the global temp variables
    CE_AUTO_BANK_MATCH.av_101_inserted_flag := 'N';
    CE_AUTO_BANK_MATCH.av_200_inserted_flag := 'N';
    CE_AUTO_BANK_MATCH.av_222_inserted_flag := 'N';
    CE_AUTO_BANK_MATCH.av_260_inserted_flag := 'N';
    CE_AUTO_BANK_MATCH.av_260_cf_inserted_flag := 'N';
    CE_AUTO_BANK_MATCH.av_801_inserted_flag := 'N';
    CE_AUTO_BANK_MATCH.av_801_eft_inserted_flag := 'N';
    CE_AUTO_BANK_MATCH.av_999_inserted_flag := 'N';
    CE_AUTO_BANK_MATCH.av_185_inserted_flag := 'N';

    -- populate the GT table
    populate_available_gt (CE_AUTO_BANK_MATCH.csh_bank_account_id);
*/
    cep_standard.debug('CE_AUTO_BANK_MATCH.csh_bank_account_id = '||CE_AUTO_BANK_MATCH.csh_bank_account_id);
			--||', CE_AUTO_BANK_MATCH.bau_bank_acct_use_id = '||CE_AUTO_BANK_MATCH.bau_bank_acct_use_id);

   -- For each bank account set the use flag
   set_acct_type(CE_AUTO_BANK_MATCH.csh_bank_account_id);

/*
    cep_standard.debug('CE_AUTO_BANK_MATCH.bau_org_id = '||CE_AUTO_BANK_MATCH.bau_org_id
			||',CE_AUTO_BANK_MATCH.bau_legal_entity_id = '||CE_AUTO_BANK_MATCH.bau_legal_entity_id);

    select mo_global.GET_CURRENT_ORG_ID
    into current_org_id
    from dual;

    cep_standard.debug('current_org_id =' ||current_org_id );

    -- bug 3782741 set single org, since AR will not allow org_id to be passed
    --IF CE_AUTO_BANK_MATCH.bau_org_id is not null THEN
    IF CE_AUTO_BANK_REC.G_org_id is not null THEN
      IF  ((current_org_id is null) or (CE_AUTO_BANK_MATCH.bau_org_id <> current_org_id )) THEN
        mo_global.set_policy_context('S',CE_AUTO_BANK_MATCH.bau_org_id);
        cep_standard.debug('set current_org_id to ' ||CE_AUTO_BANK_MATCH.bau_org_id );
      END IF;
    END IF;

   cep_standard.debug('Get AR accounting method.');

 -- bug 1796965
  SELECT count(*)
  INTO	accounting_method_found
  FROM	ar_system_parameters s
  where s.org_id = nvl(CE_AUTO_BANK_REC.G_org_id,CE_AUTO_BANK_MATCH.bau_org_id);

  if (accounting_method_found = 1) then
    SELECT accounting_method
    INTO   CE_AUTO_BANK_MATCH.ar_accounting_method
    FROM   ar_system_parameters s
    where s.org_id = nvl(CE_AUTO_BANK_REC.G_org_id,CE_AUTO_BANK_MATCH.bau_org_id);
  else
    CE_AUTO_BANK_MATCH.ar_accounting_method := NULL;
  end if;
*/
    -- bug 3676745 1/20/05 Did not enter organization (le_id and org_id missing)
    --   use match org_id and legal_entity_id
   -- if CE_AUTO_BANK_REC.G_legal_entity_id is not null then it has already been set by ceabrdrb.pls
  --IF (CE_AUTO_BANK_REC.G_legal_entity_id is null and CE_AUTO_BANK_REC.G_org_id is null) THEN
    --bug 4914608 get owner LE info from ce_system_parameters
  IF (CE_AUTO_BANK_REC.G_legal_entity_id is null) THEN
    --IF (CE_AUTO_BANK_MATCH.bau_org_id is not null or CE_AUTO_BANK_MATCH.bau_legal_entity_id is not null) THEN
    IF (CE_AUTO_BANK_MATCH.ba_owner_le_id is not null) THEN
        CE_SYSTEM_PARAMETERS1_PKG.select_columns(CE_AUTO_BANK_REC.G_rowid,
				CE_AUTO_BANK_REC.G_set_of_books_id,
				CE_AUTO_BANK_REC.G_cashbook_begin_date,
				CE_AUTO_BANK_REC.G_show_cleared_flag,
                                CE_AUTO_BANK_REC.G_show_void_payment_flag,
				CE_AUTO_BANK_REC.G_line_autocreation_flag,
			 	CE_AUTO_BANK_REC.G_interface_purge_flag,
				CE_AUTO_BANK_REC.G_interface_archive_flag,
				CE_AUTO_BANK_REC.G_lines_per_commit,
				CE_AUTO_BANK_REC.G_functional_currency,
				CE_AUTO_BANK_REC.G_sob_short_name,
				CE_AUTO_BANK_REC.G_account_period_type,
				CE_AUTO_BANK_REC.G_user_exchange_rate_type,
				CE_AUTO_BANK_REC.G_chart_of_accounts_id,
				CE_AUTO_BANK_REC.G_CASHFLOW_EXCHANGE_RATE_TYPE,
				CE_AUTO_BANK_REC.G_AUTHORIZATION_BAT,
                                CE_AUTO_BANK_REC.G_BSC_EXCHANGE_DATE_TYPE,
                                CE_AUTO_BANK_REC.G_BAT_EXCHANGE_DATE_TYPE,
                                CE_AUTO_BANK_MATCH.ba_owner_le_id
			);
    END IF;
  END IF;

  -- bug 4914608 set bank account variables
  IF (CE_AUTO_BANK_MATCH.csh_bank_account_id is not null) THEN

        CE_SYSTEM_PARAMETERS1_PKG.ba_select_columns(CE_AUTO_BANK_MATCH.BA_ROWID,
				CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance,
				CE_AUTO_BANK_MATCH.ba_ap_percent_tolerance,
				CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance,
				CE_AUTO_BANK_MATCH.ba_ar_percent_tolerance,
				CE_AUTO_BANK_MATCH.ba_ce_amount_tolerance,
				CE_AUTO_BANK_MATCH.ba_ce_percent_tolerance,
				CE_AUTO_BANK_REC.G_float_handling_flag,
				CE_AUTO_BANK_REC.G_ap_matching_order,
				CE_AUTO_BANK_REC.G_ar_matching_order,
				CE_AUTO_BANK_REC.G_exchange_rate_type,
				CE_AUTO_BANK_REC.G_exchange_rate_date,
				CE_AUTO_BANK_REC.G_open_interface_flag,
				CE_AUTO_BANK_REC.G_open_interface_float_status,
				CE_AUTO_BANK_REC.G_open_interface_clear_status,
				CE_AUTO_BANK_REC.G_open_interface_matching_code,
 				CE_AUTO_BANK_MATCH.BA_RECON_OI_AMOUNT_TOLERANCE,
 				CE_AUTO_BANK_MATCH.BA_RECON_OI_PERCENT_TOLERANCE,
				ignore_trx_id,
				ignore_trx_id2,
 				CE_AUTO_BANK_MATCH.BA_RECON_AP_FX_DIFF_HANDLING,
 				CE_AUTO_BANK_MATCH.BA_RECON_AR_FX_DIFF_HANDLING,
 				CE_AUTO_BANK_MATCH.BA_RECON_CE_FX_DIFF_HANDLING,
 				CE_AUTO_BANK_REC.G_differences_account,
 				CE_AUTO_BANK_REC.G_CE_DIFFERENCES_ACCOUNT,
                                CE_AUTO_BANK_MATCH.ba_owner_le_id,
				CE_AUTO_BANK_MATCH.csh_bank_account_id,
				CE_AUTO_BANK_REC.G_ap_matching_order2 -- FOR SEPA ER 6700007
			);


  END IF;

    cep_standard.debug('CE_AUTO_BANK_MATCH.BA_ROWID '|| CE_AUTO_BANK_MATCH.BA_ROWID);
    cep_standard.debug('CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance= ' || CE_AUTO_BANK_MATCH.ba_ap_amount_tolerance ||
			', CE_AUTO_BANK_MATCH.ba_ap_percent_tolerance= '||CE_AUTO_BANK_MATCH.ba_ap_percent_tolerance);
    cep_standard.debug('CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance= ' || CE_AUTO_BANK_MATCH.ba_ar_amount_tolerance ||
			', CE_AUTO_BANK_MATCH.ba_ar_percent_tolerance= '||CE_AUTO_BANK_MATCH.ba_ar_percent_tolerance);
    cep_standard.debug('CE_AUTO_BANK_MATCH.ba_ce_amount_tolerance= ' || CE_AUTO_BANK_MATCH.ba_ce_amount_tolerance ||
			', CE_AUTO_BANK_MATCH.ba_ce_percent_tolerance= '||CE_AUTO_BANK_MATCH.ba_ce_percent_tolerance);
    cep_standard.debug('CE_AUTO_BANK_REC.G_float_handling_flag='||CE_AUTO_BANK_REC.G_float_handling_flag ||
			', CE_AUTO_BANK_REC.G_ap_matching_order ='|| CE_AUTO_BANK_REC.G_ap_matching_order ||
			', CE_AUTO_BANK_REC.G_ar_matching_order ='|| CE_AUTO_BANK_REC.G_ar_matching_order);
    cep_standard.debug('CE_AUTO_BANK_REC.G_exchange_rate_type='||CE_AUTO_BANK_REC.G_exchange_rate_type ||
			', CE_AUTO_BANK_REC.G_exchange_rate_date='|| CE_AUTO_BANK_REC.G_exchange_rate_date);
    cep_standard.debug('CE_AUTO_BANK_REC.G_open_interface_flag='|| CE_AUTO_BANK_REC.G_open_interface_flag||
			', REC.G_open_interface_float_status='|| CE_AUTO_BANK_REC.G_open_interface_float_status  ||
			', REC.G_open_interface_clear_status='||  CE_AUTO_BANK_REC.G_open_interface_clear_status);
    cep_standard.debug('REC.G_open_interface_matching_code='||CE_AUTO_BANK_REC.G_open_interface_matching_code||
			', BA_RECON_OI_AMOUNT_TOLERANCE='|| BA_RECON_OI_AMOUNT_TOLERANCE ||
			', BA_RECON_OI_PERCENT_TOLERANCE='|| BA_RECON_OI_PERCENT_TOLERANCE);
    cep_standard.debug('BA_RECON_AP_FX_DIFF_HANDLING='|| BA_RECON_AP_FX_DIFF_HANDLING ||
			', BA_RECON_AR_FX_DIFF_HANDLING='||  BA_RECON_AR_FX_DIFF_HANDLING ||
			', BA_RECON_CE_FX_DIFF_HANDLING='|| BA_RECON_CE_FX_DIFF_HANDLING);
    cep_standard.debug('REC.G_differences_account=' || CE_AUTO_BANK_REC.G_differences_account ||
			', REC.G_CE_DIFFERENCES_ACCOUNT=' ||  CE_AUTO_BANK_REC.G_CE_DIFFERENCES_ACCOUNT);



  IF (r_branch_cursor%ROWCOUNT = j) THEN
      EXIT;
  ELSE
      j := r_branch_cursor%ROWCOUNT;
      -- bug 5221561
    -- for every bank account, reinitialize the global temp variables
    CE_AUTO_BANK_MATCH.av_101_inserted_flag := 'N';
    CE_AUTO_BANK_MATCH.av_200_inserted_flag := 'N';
    CE_AUTO_BANK_MATCH.av_222_inserted_flag := 'N';
    CE_AUTO_BANK_MATCH.av_260_inserted_flag := 'N';
    CE_AUTO_BANK_MATCH.av_260_cf_inserted_flag := 'N';
    CE_AUTO_BANK_MATCH.av_801_inserted_flag := 'N';
    CE_AUTO_BANK_MATCH.av_801_eft_inserted_flag := 'N';
    CE_AUTO_BANK_MATCH.av_999_inserted_flag := 'N';
--    CE_AUTO_BANK_MATCH.av_185_inserted_flag := 'N'; Bug 7356199

    -- populate the GT table
    populate_available_gt (CE_AUTO_BANK_MATCH.csh_bank_account_id);
  END IF;

    cep_standard.debug('>>CE_AUTO_BANK_MATCH.Opening r_bank_cursor');
    OPEN r_bank_cursor (CE_AUTO_BANK_REC.G_statement_number_from,
		      CE_AUTO_BANK_REC.G_statement_number_to,
		      CE_AUTO_BANK_REC.G_statement_date_from,
		      CE_AUTO_BANK_REC.G_statement_date_to,
		      CE_AUTO_BANK_MATCH.csh_bank_account_id);
    i := 0;
      LOOP
	cep_standard.debug('>>CE_AUTO_BANK_MATCH.Fetching r_bank_cursor');
	FETCH r_bank_cursor INTO CE_AUTO_BANK_MATCH.csh_statement_header_id,
			     CE_AUTO_BANK_MATCH.csh_statement_number,
			     CE_AUTO_BANK_MATCH.csh_statement_date,
			     CE_AUTO_BANK_MATCH.csh_check_digits,
			     CE_AUTO_BANK_MATCH.csh_statement_gl_date,
			     CE_AUTO_BANK_MATCH.aba_bank_currency,
			     CE_AUTO_BANK_MATCH.aba_multi_currency_flag,
			     CE_AUTO_BANK_MATCH.aba_check_digits,
			     CE_AUTO_BANK_MATCH.csh_rowid,
			     CE_AUTO_BANK_MATCH.csh_statement_complete_flag;
	cep_standard.debug('>>CE_AUTO_BANK_MATCH.After fetch header');
	cep_standard.debug('>>CE_AUTO_BANK_MATCH.statement_header_id:' ||
			CE_AUTO_BANK_MATCH.csh_statement_header_id );

	if (r_bank_cursor%ROWCOUNT = i) then
	  EXIT;
	else
	  i := r_bank_cursor%ROWCOUNT;
	end if;
	-- EXIT WHEN r_bank_cursor%NOTFOUND OR r_bank_cursor%NOTFOUND IS NULL;

        select count(1)
        into row_count
        from ce_statement_lines
        where statement_header_id = CE_AUTO_BANK_MATCH.csh_statement_header_id;

        if (row_count = 0 ) then
          CE_RECONCILIATION_ERRORS_PKG.delete_row(
                  CE_AUTO_BANK_MATCH.csh_statement_header_id,
                  to_number(NULL));
          CE_RECONCILIATION_ERRORS_PKG.insert_row(
                  CE_AUTO_BANK_MATCH.csh_statement_header_id,
                  to_number(NULL), 'CE_NO_STMT_LINE');
        end if;

	IF (nvl(LTRIM(nvl(CE_AUTO_BANK_MATCH.csh_check_digits, 'NO DIGIT'),
		'0'), '0') = nvl(LTRIM(nvl(CE_AUTO_BANK_MATCH.aba_check_digits,
		'NO DIGIT'), '0'), '0')) THEN

	  --
	  -- Lock the statement
	  --
	  IF (lock_statement(lockhandle)) THEN
	    IF (csh_statement_complete_flag = 'N') THEN

	   /*   Select count(*)
	      into x_pay_count
	      from ce_bank_acct_uses_all bau, CE_SECURITY_PROFILES_GT OU
	      where bau.PAY_USE_ENABLE_FLAG = 'Y'
	      and sysdate <= nvl(end_date,sysdate)
	      and BANK_ACCOUNT_ID = CE_AUTO_BANK_MATCH.csh_bank_account_id
	      --and BAU.bank_acct_use_id = CE_AUTO_BANK_MATCH.bau_bank_acct_use_id
	      and BAU.ORG_ID = nvl(CE_AUTO_BANK_REC.G_org_id, BAU.ORG_ID)
	      and BAU.ORG_ID = OU.ORGANIZATION_ID
	      AND OU.ORGANIZATION_TYPE = 'BUSINESS_GROUP';
	   */
	  /*  SELECT aba.account_classification
	      INTO   account_type
	      FROM   ce_bank_accounts_v aba
	      WHERE  aba.bank_account_id =
		     CE_AUTO_BANK_MATCH.csh_bank_account_id;
	 */
	     -- IF account_type <> 'PAYROLL' THEN
	      --IF (x_pay_count  <> 0) THEN
	      IF (CE_AUTO_BANK_MATCH.BAU_PAY_USE_ENABLE_FLAG <> 'Y') THEN
		update_gl_date;
	      END IF;
	      statement_line_count := 0;

	      --
	      -- Read in all the lines on the statement for the selected bank
	      -- account.
	      --
    	      cep_standard.debug('>>CE_AUTO_BANK_MATCH.Opening line_cursor');
	      OPEN line_cursor (CE_AUTO_BANK_MATCH.csh_statement_header_id);
	      LOOP
		FETCH line_cursor INTO CE_AUTO_BANK_MATCH.csl_rowid,
			 CE_AUTO_BANK_MATCH.csl_statement_line_id,
			 --CE_AUTO_BANK_MATCH.csl_receivables_trx_id,
			 --CE_AUTO_BANK_MATCH.csl_receipt_method_id,
			 --CE_AUTO_BANK_MATCH.csl_create_misc_trx_flag,
			 --CE_AUTO_BANK_MATCH.csl_matching_against,
			 --CE_AUTO_BANK_MATCH.csl_correction_method,
			 --CE_AUTO_BANK_MATCH.csl_receipt_method_name,
			 CE_AUTO_BANK_MATCH.csl_exchange_rate_type,
			 CE_AUTO_BANK_MATCH.csl_exchange_rate_date,
			 CE_AUTO_BANK_MATCH.csl_exchange_rate,
			 CE_AUTO_BANK_MATCH.csl_currency_code,
			 CE_AUTO_BANK_MATCH.csl_line_trx_type,
			 --CE_AUTO_BANK_MATCH.csl_reconcile_flag,
			 CE_AUTO_BANK_MATCH.csl_match_found,
			 CE_AUTO_BANK_MATCH.csl_match_type,
			 CE_AUTO_BANK_MATCH.csl_clearing_trx_type,
			 CE_AUTO_BANK_MATCH.csl_original_amount,
			 --CE_AUTO_BANK_MATCH.csl_payroll_payment_format,
			 CE_AUTO_BANK_MATCH.csl_je_status_flag,
			 CE_AUTO_BANK_MATCH.csl_accounting_date,
			 --CE_AUTO_BANK_MATCH.csl_event_id,
			 CE_AUTO_BANK_MATCH.csl_cashflow_id,
			ignore_trx_id,
			ignore_trx_id2	;
		EXIT WHEN line_cursor%NOTFOUND OR line_cursor%NOTFOUND IS NULL;

		cep_standard.debug('========= new statement line ============ ');

		cep_standard.debug('CE_AUTO_BANK_MATCH.csl_statement_line_id = '|| CE_AUTO_BANK_MATCH.csl_statement_line_id
				 ||' CE_AUTO_BANK_MATCH.csl_payroll_payment_format = '|| CE_AUTO_BANK_MATCH.csl_payroll_payment_format
				 ||' CE_AUTO_BANK_MATCH.csl_cashflow_id = '|| CE_AUTO_BANK_MATCH.csl_cashflow_id);


		select count(*)
		into   rec_status
		--from   ce_statement_reconciliations
		from   ce_statement_reconcils_all
		where  statement_line_id =
		       CE_AUTO_BANK_MATCH.csl_statement_line_id
		and    nvl(status_flag, 'U') = 'M'
		and    nvl(current_record_flag, 'Y') = 'Y';

		if (rec_status = 0) then

		  --
		  -- NULL values to transaction holders
		  --
		  CE_AUTO_BANK_MATCH.trx_id		 := to_number(NULL);
		  CE_AUTO_BANK_MATCH.trx_cash_receipt_id := to_number(NULL);
		  CE_AUTO_BANK_MATCH.trx_rowid		 := NULL;
		  CE_AUTO_BANK_MATCH.trx_currency_code	 := NULL;
		  CE_AUTO_BANK_MATCH.trx_amount		 := to_number(NULL);
		  CE_AUTO_BANK_MATCH.trx_base_amount	 := to_number(NULL);
		  CE_AUTO_BANK_MATCH.trx_cleared_amount	 := to_number(NULL);
		  CE_AUTO_BANK_MATCH.trx_curr_amount	 := to_number(NULL);
		  CE_AUTO_BANK_MATCH.trx_currency_type   := NULL;
		  CE_AUTO_BANK_MATCH.trx_status		 := NULL;
		  CE_AUTO_BANK_MATCH.trx_errors_amount	 := to_number(NULL);
		  CE_AUTO_BANK_MATCH.trx_charges_amount	 := to_number(NULL);
		  CE_AUTO_BANK_MATCH.trx_prorate_amount	 := to_number(NULL);
		  CE_AUTO_BANK_MATCH.trx_reference_type  := NULL;
		  CE_AUTO_BANK_MATCH.trx_value_date      := to_date(NULL);
		  CE_AUTO_BANK_MATCH.trx_cleared_date    := to_date(NULL);
		  CE_AUTO_BANK_MATCH.trx_deposit_date    := to_date(NULL);
		  CE_AUTO_BANK_MATCH.trx_legal_entity_id := to_number(NULL);
		  CE_AUTO_BANK_MATCH.trx_org_id := to_number(NULL);
		  CE_AUTO_BANK_MATCH.gt_seq_id 		 := to_number(NULL);
                  CE_AUTO_BANK_MATCH.gt_seq_id2          := to_number(NULL);
		/* for bug 6786355 start */
		  CE_AUTO_BANK_MATCH.trx_exchange_rate       := to_number(NULL);
		  CE_AUTO_BANK_MATCH.trx_exchange_rate_date  := to_date(NULL);
		  CE_AUTO_BANK_MATCH.trx_exchange_rate_type  := NULL;
		  CE_AUTO_BANK_MATCH.trx_gl_date             := to_date(NULL);
                  CE_AUTO_BANK_MATCH.trx_date                := to_date(NULL);
		  CE_AUTO_BANK_MATCH.trx_value_date          := to_date(NULL);
		  CE_AUTO_BANK_MATCH.trx_deposit_date        := to_date(NULL);
		/* for bug 6786355 end */

		  statement_line_count := statement_line_count + 1;
		  --
		  -- Clear recon_errors table
		  --
		  CE_RECONCILIATION_ERRORS_PKG.delete_row(
			CE_AUTO_BANK_MATCH.csh_statement_header_id,
			CE_AUTO_BANK_MATCH.csl_statement_line_id);
		  IF (lock_statement_line) THEN
		    --
		    -- On the statement line MISC_DEBIT amounts will come
		    -- through as a positive amount but the transaction
		    -- will be negative.  If the transaction is a
		    -- MISC_DEBIT, reverse the sign on the amount.
		    --
			/* JEC Bug 4234483 modified the IF condition below */
		   -- bug 4435028 amount in ce_cashflows should be positive ??
		/*
		    IF (CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_DEBIT' and
				(CE_AUTO_BANK_MATCH.csl_je_status_flag is null OR
				(CE_AUTO_BANK_MATCH.csl_je_status_flag <> 'C'))) THEN
		      CE_AUTO_BANK_MATCH.calc_csl_amount :=
			  CE_AUTO_BANK_MATCH.csl_amount * -1;
		    ELSE
		      CE_AUTO_BANK_MATCH.calc_csl_amount :=
			  CE_AUTO_BANK_MATCH.csl_amount;
		    END IF;
		*/


		--BUG NO. 6136002
		 IF (CE_AUTO_BANK_MATCH.csl_trx_type = 'MISC_DEBIT' and
		    (CE_AUTO_BANK_MATCH.csl_cashflow_id is null)) THEN
			  CE_AUTO_BANK_MATCH.calc_csl_amount :=
			  CE_AUTO_BANK_MATCH.csl_amount * -1;
		 ELSE
			  CE_AUTO_BANK_MATCH.calc_csl_amount :=
			  CE_AUTO_BANK_MATCH.csl_amount;
		 END IF;

		--CE_AUTO_BANK_MATCH.calc_csl_amount := CE_AUTO_BANK_MATCH.csl_amount;

		 cep_standard.debug('CE_AUTO_BANK_MATCH.calc_csl_amount = '|| CE_AUTO_BANK_MATCH.calc_csl_amount);

		/*JEC*/
		-- bug4435028
		--IF(CE_AUTO_BANK_MATCH.csl_je_status_flag = 'C') THEN
		    IF(CE_AUTO_BANK_MATCH.csl_cashflow_id is not null) THEN  --this will handle JEC/ZBA(?) trx
			match_stmt_line_JE;
		    ELSE
		    -- bug 4435028 multi-matching based on trx_code
    	      	      cep_standard.debug('>>CE_AUTO_BANK_MATCH.Opening trx_code_cursor');

 		      OPEN trx_code_cursor (CE_AUTO_BANK_MATCH.csl_statement_line_id,CE_AUTO_BANK_MATCH.csh_bank_account_id);
		      LOOP
		        FETCH trx_code_cursor INTO
			  CE_AUTO_BANK_MATCH.csl_receivables_trx_id,
			  CE_AUTO_BANK_MATCH.csl_receipt_method_id,
			  CE_AUTO_BANK_MATCH.csl_create_misc_trx_flag,
			  CE_AUTO_BANK_MATCH.csl_matching_against,
			  CE_AUTO_BANK_MATCH.csl_correction_method,
			  CE_AUTO_BANK_MATCH.csl_receipt_method_name,
			  CE_AUTO_BANK_MATCH.csl_reconcile_flag,
			  CE_AUTO_BANK_MATCH.csl_payroll_payment_format;

	                EXIT WHEN trx_code_cursor%NOTFOUND OR trx_code_cursor%NOTFOUND IS NULL;

		cep_standard.debug('CE_AUTO_BANK_MATCH.csl_reconcile_flag = '|| CE_AUTO_BANK_MATCH.csl_reconcile_flag
				 ||', CE_AUTO_BANK_MATCH.csl_matching_against = '|| CE_AUTO_BANK_MATCH.csl_matching_against
				 ||', CE_AUTO_BANK_MATCH.csl_payroll_payment_format = '|| CE_AUTO_BANK_MATCH.csl_payroll_payment_format);

		cep_standard.debug('CE_AUTO_BANK_MATCH.csl_match_found = '|| CE_AUTO_BANK_MATCH.csl_match_found);

		        IF (CE_AUTO_BANK_MATCH.csl_match_found IN ('ERROR','NONE','PARTIAL') ) THEN

		          CE_AUTO_BANK_MATCH.match_engine;

			  cep_standard.debug('CE_AUTO_BANK_MATCH.csl_match_found = '|| CE_AUTO_BANK_MATCH.csl_match_found);
		          IF (CE_AUTO_BANK_MATCH.csl_match_found = 'FULL') THEN

			    -- bug 4914608 set the org after a match for AR/AP
		            cep_standard.debug('CE_AUTO_BANK_MATCH.trx_org_id =' ||CE_AUTO_BANK_MATCH.trx_org_id);
			    set_single_org(CE_AUTO_BANK_MATCH.trx_org_id);

			    CE_AUTO_BANK_CLEAR.reconcile_process;

			    -- after a match and reconcilation,
			    -- update the ce_available_transactions_tmp.reconciled_status_flag
			    IF (CE_AUTO_BANK_MATCH.gt_seq_id is not null) AND
			       (CE_AUTO_BANK_MATCH.gt_seq_id <> -1) THEN
			      update_gt_reconciled_status (CE_AUTO_BANK_MATCH.gt_seq_id, 'Y');
			      --update ce_available_transactions_tmp
			      --set    reconciled_status_flag = 'Y'
			      --where  seq_id = CE_AUTO_BANK_MATCH.gt_seq_id;
			    END IF;

			    IF CE_AUTO_BANK_MATCH.gt_seq_id2 is not null THEN
                              update_gt_reconciled_status (CE_AUTO_BANK_MATCH.gt_seq_id2, 'Y');
                              --update ce_available_transactions_tmp
                              --set    reconciled_status_flag = 'Y'
                              --where  seq_id = CE_AUTO_BANK_MATCH.gt_seq_id2;
                            END IF;


		          -- Bug 900251 - remove this default message.
		          --ELSIF (CE_AUTO_BANK_MATCH.csl_match_found IN
			  --  ('NONE','PARTIAL')) THEN
		          --  CE_RECONCILIATION_ERRORS_PKG.insert_row(
			  --    CE_AUTO_BANK_MATCH.csh_statement_header_id,
			  --    CE_AUTO_BANK_MATCH.csl_statement_line_id,
			  --    'CE_DR_NOT_FOUND');
		          --
		          END IF;  --CE_AUTO_BANK_MATCH.csl_match_found = FULL
		        END IF; --CE_AUTO_BANK_MATCH.csl_match_found IN ('ERROR','NONE','PARTIAL')
      		      END LOOP; -- trx_code_cursor

                        x_trx_code_row_count := trx_code_cursor%ROWCOUNT;
                        cep_standard.debug('x_trx_code_row_count  = '||  x_trx_code_row_count );

		      CLOSE trx_code_cursor;
		    END IF; -- cashflow_id is not null
		  ELSE -- statement line is locked
		    CE_RECONCILIATION_ERRORS_PKG.insert_row(
			CE_AUTO_BANK_MATCH.csh_statement_header_id,
			CE_AUTO_BANK_MATCH.csl_statement_line_id,
			'CE_LINE_LOCKED');
		  END IF;
		  IF (statement_line_count =
		      CE_AUTO_BANK_REC.G_lines_per_commit) THEN
		    COMMIT;
		    statement_line_count := 0;
		  END IF;

		end if;   --  rec_status = 0
	      END LOOP; -- statement lines
	      CLOSE line_cursor;

	    ELSE
	      error_statement_line_id := get_min_statement_line_id;
	      CE_RECONCILIATION_ERRORS_PKG.delete_row(
		  CE_AUTO_BANK_MATCH.csh_statement_header_id,
		  error_statement_line_id);
	      CE_RECONCILIATION_ERRORS_PKG.insert_row(
		  CE_AUTO_BANK_MATCH.csh_statement_header_id,
		  error_statement_line_id, 'CE_STATEMENT_COMPLETED');
	  END IF; -- statement completed

	ELSE -- statement is locked
	/*      error_statement_line_id := get_min_statement_line_id;
	      CE_RECONCILIATION_ERRORS_PKG.delete_row(error_statement_line_id);
	      CE_RECONCILIATION_ERRORS_PKG.insert_row(
		  error_statement_line_id,'CE_LOCK_STATEMENT_HEADER_ERR');
	*/
	  CE_RECONCILIATION_ERRORS_PKG.delete_row(
	      CE_AUTO_BANK_MATCH.csh_statement_header_id, to_number(NULL));
	      CE_RECONCILIATION_ERRORS_PKG.insert_row(
		  CE_AUTO_BANK_MATCH.csh_statement_header_id,to_number(NULL),
		  'CE_LOCK_STATEMENT_HEADER_ERR');
	END IF;
	lock_status := dbms_lock.release(lockhandle);

      ELSE -- check digits failed
	/*        error_statement_line_id := get_min_statement_line_id;
		CE_RECONCILIATION_ERRORS_PKG.delete_row(error_statement_line_id);
		CE_RECONCILIATION_ERRORS_PKG.insert_row(
		error_statement_line_id,'CE_CHECK_DIGITS');
	*/
	CE_RECONCILIATION_ERRORS_PKG.delete_row(
	    CE_AUTO_BANK_MATCH.csh_statement_header_id, to_number(NULL));
	CE_RECONCILIATION_ERRORS_PKG.insert_row(
	    CE_AUTO_BANK_MATCH.csh_statement_header_id,to_number(NULL),
	    'CE_CHECK_DIGITS');
      END IF; -- check_digits

    END LOOP; -- statement headers
    CLOSE r_bank_cursor;
  END LOOP;
  CLOSE r_branch_cursor;
  cep_standard.debug('<<CE_AUTO_BANK_MATCH.match_process');
  cep_standard.debug('========== END MATCHING ========== ');

/* Bug 3364143 start code fix */
  cep_standard.disable_debug(CE_AUTO_BANK_REC.G_display_debug);
/* Bug 3364143 end code fix */
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug(' EXCEPTION: CE_AUTO_BANK_MATCH.match_process - OTHERS');
    IF r_branch_cursor%ISOPEN THEN
      CLOSE r_branch_cursor;
    END IF;
    IF r_bank_cursor%ISOPEN THEN
      CLOSE r_bank_cursor;
    END IF;
    IF line_cursor%ISOPEN THEN
      CLOSE line_cursor;
    END IF;
    IF trx_code_cursor%ISOPEN THEN
      CLOSE trx_code_cursor;
    END IF;
    lock_status := dbms_lock.release(lockhandle);
    cep_standard.debug('DEBUG: sqlcode:' || sqlcode );
    cep_standard.debug('DEBUG: sqlerrm:' || sqlerrm);
    RAISE;
END match_process;

END CE_AUTO_BANK_MATCH;

/
