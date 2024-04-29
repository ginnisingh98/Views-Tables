--------------------------------------------------------
--  DDL for Package Body CE_AUTO_BANK_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_AUTO_BANK_IMPORT" AS
/* $Header: ceabrimb.pls 120.22.12010000.9 2009/09/30 11:31:46 ckansara ship $ */
   l_DEBUG varchar2(1) := NVL(FND_PROFILE.value('CE_DEBUG'), 'N');
   --l_DEBUG varchar2(1) := 'Y';

   CURSOR branch_cursor ( p_bank_branch_id        NUMBER,
                          p_bank_account_id       NUMBER ) IS
        SELECT aba.bank_account_id,
		aba.ACCOUNT_OWNER_ORG_ID,
               nvl(aba.XTR_USE_ALLOWED_FLAG,'N'),
               nvl(aba.PAY_USE_ALLOWED_FLAG,'N')
        --FROM ce_bank_accounts_v aba
        FROM ce_bank_accts_gt_v aba
        WHERE aba.bank_branch_id = p_bank_branch_id
                AND aba.bank_account_id = NVL(p_bank_account_id, aba.bank_account_id);
		--AND aba.account_classification = 'INTERNAL';
		--AND aba.account_type = CE_AUTO_BANK_MATCH.get_security_account_type(aba.account_type);

   CURSOR bank_cursor (  p_statement_number_from  VARCHAR2,
			 p_statement_number_to	  VARCHAR2,
			 p_statement_date_from	  DATE,
			 p_statement_date_to      DATE,
	 	         p_bank_account_id        NUMBER) IS
	SELECT  sh.rowid,
		sh.statement_number,
		sh.bank_account_num,
		sh.check_digits,
		sh.control_begin_balance,
		sh.control_end_balance,
		sh.cashflow_balance,
		sh.int_calc_balance,
		sh.average_close_ledger_mtd,
		sh.average_close_ledger_ytd,
		sh.average_close_available_mtd,
		sh.average_close_available_ytd,
		sh.one_day_float,
		sh.two_day_float,
		sh.intra_day_flag,
		sh.subsidiary_flag,
		sh.control_total_dr,
		sh.control_total_cr,
		sh.control_dr_line_count,
		sh.control_cr_line_count,
		sh.control_line_count,
		sh.attribute_category,
		sh.attribute1,
		sh.attribute2,
		sh.attribute3,
		sh.attribute4,
		sh.attribute5,
		sh.attribute6,
		sh.attribute7,
		sh.attribute8,
		sh.attribute9,
		sh.attribute10,
		sh.attribute11,
		sh.attribute12,
		sh.attribute13,
		sh.attribute14,
		sh.attribute15,
                sh.statement_date,
	        sh.bank_branch_name,
		sh.bank_name,
		sh.bank_branch_name,
		sh.currency_code,
		--sh.org_id,
		rsh.statement_number,
		ba.bank_account_name,
		ba.currency_code,
		ba.check_digits
	FROM    ce_statement_headers	       rsh,
		ce_statement_headers_int sh,
		ce_bank_accts_gt_v ba --ce_bank_accounts_v	       ba
	WHERE   rsh.statement_number(+) = sh.statement_number
	AND     rsh.bank_account_id(+) = p_bank_account_id
	AND	NVL(sh.record_status_flag, 'I') <> 'T'
	AND	sh.statement_number
		BETWEEN NVL(p_statement_number_from,sh.statement_number)
		AND NVL(p_statement_number_to,sh.statement_number)
	AND	to_char(sh.statement_date,'J')
		BETWEEN NVL(to_char(p_statement_date_from,'J'),1)
		AND NVL(to_char(p_statement_date_to,'J'),3442447)
	AND     sh.bank_account_num =  ba.bank_account_num
	AND     ba.bank_account_id = NVL(p_bank_account_id,ba.bank_account_id)
        AND EXISTS (
            select null
            from   ce_bank_branches_v bb
            where  bb.branch_party_id = ba.bank_branch_id
            and    bb.bank_name = nvl(sh.bank_name, bb.bank_name)
            and    bb.bank_branch_name =
                        nvl(sh.bank_branch_name, bb.bank_branch_name))
 	ORDER BY sh.bank_account_num, sh.statement_number;

CURSOR lines_cursor (  p_statement_number 	VARCHAR2,
	 	          p_bank_account_num  	VARCHAR2) IS
	SELECT distinct  l.rowid,
		l.line_number,
		l.amount,
		l.trx_code,
		l.user_exchange_rate_type,
		l.currency_code,
		l.exchange_rate_date,
		l.trx_date,
      /* commented for bug 7531187
                NVL(DECODE(ctc.trx_type,'DEBIT',       l.amount,
			       	        'MISC_DEBIT',  l.amount,
			       	        'NSF',         l.amount,
					'REJECTED',    l.amount, 0),0),
                DECODE(ctc.trx_type,'DEBIT',       1,
			       	    'MISC_DEBIT',  1,
			       	    'NSF',         1,
				    'REJECTED',    1, 0),
	        NVL(DECODE(ctc.trx_type,'CREDIT',      l.amount,
			       	        'MISC_CREDIT', l.amount,
                                        'STOP',        l.amount, 0),0),
	        DECODE(ctc.trx_type,'CREDIT',      1,
			       	    'MISC_CREDIT', 1,
                                    'STOP',        1, 0),
          */

    -- Added Sweep In and Sweep out in the above commented code - bug 7531187
    NVL(DECODE(ctc.trx_type,'DEBIT',       l.amount,
                            'MISC_DEBIT',  l.amount,
                            'NSF',         l.amount,
                            'SWEEP_OUT',   l.amount,
                            'REJECTED',    l.amount, 0),0),
    DECODE(ctc.trx_type,'DEBIT',       1,
                        'MISC_DEBIT',  1,
                        'NSF',         1,
                        'SWEEP_OUT',   1,
                        'REJECTED',    1, 0),
    NVL(DECODE(ctc.trx_type,'CREDIT',      l.amount,
                            'MISC_CREDIT', l.amount,
                            'SWEEP_IN',    l.amount,
                            'STOP',        l.amount, 0),0),
    DECODE(ctc.trx_type,'CREDIT',      1,
                        'MISC_CREDIT', 1,
                        'SWEEP_IN',    1,
                         'STOP',       1, 0),

		ctc.transaction_code_id,--for bug 7194081 --null, --bug 5665539 l.trx_code, --ctc.transaction_code_id,
		ctc.reconciliation_sequence, -- Bug 8965556
		ctc.start_date ,--8928828 null, --ctc.start_date
		ctc.end_date, --8928828 null, --ctc.end_date
		gt.conversion_type,
		gt.user_conversion_type,
		curr.currency_code
	FROM	fnd_currencies 				curr,
		gl_daily_conversion_types 		gt,
		ce_transaction_codes 			ctc,
		ce_statement_lines_interface 		l
        WHERE 	curr.currency_code(+)			= l.currency_code
	AND 	gt.user_conversion_type(+)		= l.user_exchange_rate_type
	AND 	ctc.trx_code(+) 			= l.trx_code
	AND   ctc.bank_account_id(+)	 		= CE_AUTO_BANK_IMPORT.G_bank_account_id
  AND nvl(ctc.Reconciliation_Sequence,1) = (SELECT nvl(min(ctc2.Reconciliation_Sequence),1)-- Code added for bug 7531187
                                            FROM   ce_Transaction_Codes ctc2
                                            WHERE  ctc2.Bank_Account_Id (+)  =CE_AUTO_BANK_IMPORT.G_bank_account_id
                                            AND    ctc2.trx_Code (+)  = l.trx_Code
                                            AND ((CE_AUTO_BANK_IMPORT.G_cshi_statement_date BETWEEN  --8928828 start
                                                     Nvl(ctc2.start_date,CE_AUTO_BANK_IMPORT.G_cshi_statement_date)
                                                     AND Nvl(ctc2.end_date,CE_AUTO_BANK_IMPORT.G_cshi_statement_date))
                                                OR
                                                 (NOT EXISTS (SELECT 1 FROM ce_transaction_codes tc
                                                      WHERE  tc.trx_code     = l.trx_code
                                                      AND tc. bank_account_id = CE_AUTO_BANK_IMPORT.G_bank_account_id
                                                      AND CE_AUTO_BANK_IMPORT.G_cshi_statement_date BETWEEN
                                                        NVL(tc.start_date, CE_AUTO_BANK_IMPORT.G_cshi_statement_date)
                                                        AND NVL(tc.end_date, CE_AUTO_BANK_IMPORT.G_cshi_statement_date)))) --8928828
                                            )  -- End of Code for  bug 7531187
	AND	l.statement_number 			= p_statement_number
	AND     l.bank_account_num 			= p_bank_account_num
        ORDER   BY l.line_number;


FUNCTION body_revision RETURN VARCHAR2 IS
BEGIN

  RETURN '$Revision: 120.22.12010000.9 $';

END body_revision;

FUNCTION spec_revision RETURN VARCHAR2 IS
BEGIN

  RETURN G_spec_revision;

END spec_revision;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       header_error							|
|                                                                       |
|  DESCRIPTION                                                          |
| 	cover routine  to write header errors				|
 -----------------------------------------------------------------------*/

FUNCTION header_error (error_name VARCHAR2) RETURN BOOLEAN IS
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_IMPORT.header_error');
  END IF;
  CE_HEADER_INTERFACE_ERRORS_PKG.insert_row(CE_AUTO_BANK_IMPORT.G_cshi_statement_number,
					    CE_AUTO_BANK_IMPORT.G_cshi_bank_account_num, error_name);
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_IMPORT.header_error');
  END IF;
  RETURN TRUE;
END header_error;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       line_error							|
|                                                                       |
|  DESCRIPTION                                                          |
| 	cover routine  to write line errors				|
 -----------------------------------------------------------------------*/
FUNCTION line_error (line_number NUMBER, error_name VARCHAR2)  RETURN BOOLEAN IS
  x_rowid	VARCHAR2(100);
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_IMPORT.line_error');
  END IF;
  CE_LINE_INTERFACE_ERRORS_PKG.insert_row(
			    x_rowid,
			    CE_AUTO_BANK_IMPORT.G_cshi_statement_number,
			    CE_AUTO_BANK_IMPORT.G_cshi_bank_account_num,
			    line_number,
			    error_name);
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_IMPORT.line_error');
  END IF;
  RETURN TRUE;
END line_error;


/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION 							|
|	check_balance_values						|
|									|
|  DESCRIPTION								|
|	Balances already exist in balance table. Check if the values 	|
|	are the.                                                        |
|									|
|  CALLED BY								|
|	transfer_header							|
|									|
|  REQUIRES								|
|	p_bank_account_id	Bank Account Id     			|
|	             							|
|	       								|
 --------------------------------------------------------------------- */
FUNCTION check_balance_values(p_bank_account_id number)
RETURN NUMBER  IS
l_return	number:=0;
BEGIN
	SELECT 1
	INTO l_return
	FROM CE_BANK_ACCT_BALANCES
	WHERE BANK_ACCOUNT_ID = p_bank_account_id
	AND BALANCE_DATE = trunc(CE_AUTO_BANK_IMPORT.G_cshi_statement_date)
	AND NVL(LEDGER_BALANCE,0) = NVL(CE_AUTO_BANK_IMPORT.G_cshi_control_end_balance,0)
	AND NVL(AVAILABLE_BALANCE,0) = NVL(CE_AUTO_BANK_IMPORT.G_cshi_cashflow_balance,0)
	AND NVL(VALUE_DATED_BALANCE,0) = NVL(CE_AUTO_BANK_IMPORT.G_cshi_int_calc_balance,0);

	return l_return;
EXCEPTION
	WHEN OTHERS THEN
	return l_return;
END check_balance_values;


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       xtr_shared_account
|                                                                       |
|  DESCRIPTION                                                          |
| 	verify the bank account is a shared account or AP-only account  |
 -----------------------------------------------------------------------*/
PROCEDURE  xtr_shared_account(X_ACCOUNT_RESULT OUT NOCOPY VARCHAR2) IS

  X_RESULT	        VARCHAR2(100);
  X_ERROR_MSG	        VARCHAR2(1000);
  set_warning     boolean;
  bu_error_found     boolean;

BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_AUTO_BANK_IMPORT.xtr_shared_account'||
	'P_ORG_ID = '|| CE_AUTO_BANK_IMPORT.BA_OWNER_LE_ID ||
	', G_BANK_ACCOUNT_ID = '|| CE_AUTO_BANK_IMPORT.G_bank_account_id||
	' G_cshi_currency_code = '|| CE_AUTO_BANK_IMPORT.G_cshi_currency_code);
END IF;

 XTR_WRAPPER_API_P.bank_account_verification(
		 P_ORG_ID 		=> CE_AUTO_BANK_IMPORT.BA_OWNER_LE_ID, --CE_AUTO_BANK_IMPORT.G_cshi_org_id,
                 P_CE_BANK_ACCOUNT_ID   => CE_AUTO_BANK_IMPORT.G_bank_account_id,
		 P_CURRENCY_CODE	=> CE_AUTO_BANK_IMPORT.G_cshi_currency_code,
           	 P_RESULT 		=> X_RESULT,
                 P_ERROR_MSG 		=> X_ERROR_MSG);

X_ACCOUNT_RESULT := X_RESULT;

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('xtr_shared_account x_result = ' || x_result||
	', x_error_msg = ' || x_error_msg);
END IF;

if (x_account_result = 'XTR1_NOT_SETUP' )  then
 	FND_FILE.put_line(FND_FILE.LOG, X_ERROR_MSG);
  	set_warning :=FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', 'Check log file for warning messages');
  	bu_error_found :=   CE_AUTO_BANK_IMPORT.header_error('CE_XTR_ACCT_NOT_SETUP');
    	update_header_status('E');
end if;

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_AUTO_BANK_IMPORT.xtr_shared_account');
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('EXCEPTION: CE_AUTO_BANK_IMPORT.xtr_shared_account');
  END IF;
  RAISE;
END xtr_shared_account;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       transfer_bank_balances						|
|                                                                       |
|  DESCRIPTION                                                          |
| 	transfer bank balance to xtr if bank account is a shared account   |
 -----------------------------------------------------------------------*/
FUNCTION transfer_bank_balances  RETURN BOOLEAN IS
  X_RESULT	        VARCHAR2(100);
  X_ERROR_MSG	        VARCHAR2(1000);
  bu_error_found     boolean;
  set_warning     boolean;
BEGIN
 IF l_DEBUG in ('Y', 'C') THEN
  cep_standard.debug('>> CE_AUTO_BANK_IMPORT.transfer_bank_balances');
  cep_standard.debug('transfer_bank_balances G_CSHI_ORG_ID = '|| CE_AUTO_BANK_IMPORT.BA_OWNER_LE_ID);
  cep_standard.debug('transfer_bank_balances G_BANK_ACCOUNT_ID = '|| CE_AUTO_BANK_IMPORT.G_bank_account_id);
  cep_standard.debug('transfer_bank_balances G_CSHI_CURRENCY_CODE = '|| CE_AUTO_BANK_IMPORT.G_cshi_currency_code);
  cep_standard.debug('transfer_bank_balances G_CSHI_STATEMENT_DATE = '|| CE_AUTO_BANK_IMPORT.G_cshi_statement_date);
  cep_standard.debug('transfer_bank_balances G_CSHI_CONTROL_END_BALANCE = '|| CE_AUTO_BANK_IMPORT.G_cshi_control_end_balance);
  cep_standard.debug('transfer_bank_balances G_CSHI_CASHFLOW_BALANCE = '|| CE_AUTO_BANK_IMPORT.G_cshi_cashflow_balance);
  cep_standard.debug('transfer_bank_balances G_CSHI_INT_CALC_BALANCE = '|| CE_AUTO_BANK_IMPORT.G_cshi_int_calc_balance);
  cep_standard.debug('transfer_bank_balances G_CSHI_ONE_DAY_FLOAT = '|| CE_AUTO_BANK_IMPORT.G_cshi_one_day_float);
  cep_standard.debug('transfer_bank_balances G_CSHI_TWO_DAY_FLOAT = '|| CE_AUTO_BANK_IMPORT.G_cshi_two_day_float);
 END IF;

 bu_error_found :=  FALSE;



 	XTR_WRAPPER_API_P.bank_balance_upload(
                 P_ORG_ID 		=> CE_AUTO_BANK_IMPORT.BA_OWNER_LE_ID, --CE_AUTO_BANK_IMPORT.G_cshi_org_id,
                 P_CE_BANK_ACCOUNT_ID   => CE_AUTO_BANK_IMPORT.G_bank_account_id,
		 P_CURRENCY_CODE	=> CE_AUTO_BANK_IMPORT.G_cshi_currency_code,
                 P_BALANCE_DATE 	=> CE_AUTO_BANK_IMPORT.G_cshi_statement_date,
                 P_BALANCE_AMOUNT_A 	=> CE_AUTO_BANK_IMPORT.G_cshi_control_end_balance,
                 P_BALANCE_AMOUNT_B 	=> CE_AUTO_BANK_IMPORT.G_cshi_cashflow_balance,
                 P_BALANCE_AMOUNT_C 	=> CE_AUTO_BANK_IMPORT.G_cshi_int_calc_balance,
                 P_ONE_DAY_FLOAT 	=> CE_AUTO_BANK_IMPORT.G_cshi_one_day_float,
                 P_TWO_DAY_FLOAT 	=> CE_AUTO_BANK_IMPORT.G_cshi_two_day_float,
                 P_RESULT 		=> X_RESULT,
                 P_ERROR_MSG 		=> X_ERROR_MSG);
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('transfer_bank_balances x_result = '|| x_result);
    cep_standard.debug('transfer_bank_balances x_error_msg = '|| x_error_msg);
  END IF;
if (x_result = 'XTR3_BU_WARNING') then /* log and import */
  FND_FILE.put_line(FND_FILE.LOG, X_ERROR_MSG);
  set_warning :=FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', 'Check log file for warning messages');
  return TRUE;
elsif (x_result = 'XTR3_BU_SUCCESS') then  /* can import */
  return TRUE;
else					/* do not import */
 FND_FILE.put_line(FND_FILE.LOG, X_ERROR_MSG);
  set_warning :=FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', 'Check log file for warning messages');
  bu_error_found :=   CE_AUTO_BANK_IMPORT.header_error('CE_BU_FAILED');
  update_header_status('E');
  return FALSE;
end if;
IF l_DEBUG in ('Y', 'C') THEN
  cep_standard.debug('<<CE_AUTO_BANK_IMPORT.transfer_bank_balances');
END IF;
EXCEPTION
WHEN OTHERS THEN
IF l_DEBUG in ('Y', 'C') THEN
  cep_standard.debug('EXCEPTION: CE_AUTO_BANK_IMPORT.transfer_bank_balances');
END IF;
  RAISE;
END transfer_bank_balances;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       purge_data							|
|                                                                       |
|  DESCRIPTION                                                          |
|       Purge data from interface tables that have been succesfully 	|
| 	transferred in this run.					|
|                                                                       |
|  CALLED BY                                                            |
|       import_process							|
 -----------------------------------------------------------------------*/
PROCEDURE purge_data IS
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  cep_standard.debug('>>CE_AUTO_BANK_IMPORT.purge_data');
  END IF;
  DELETE FROM ce_statement_headers_int sh
  WHERE rowid = CE_AUTO_BANK_IMPORT.G_cshi_rowid;

  DELETE FROM ce_statement_lines_interface sl
  WHERE sl.bank_account_num = CE_AUTO_BANK_IMPORT.G_cshi_bank_account_num
  AND	sl.statement_number = CE_AUTO_BANK_IMPORT.G_cshi_statement_number;
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('<<CE_AUTO_BANK_IMPORT.purge_data');
  END IF;
EXCEPTION
  WHEN others THEN
    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('EXCEPTION: CE_AUTO_BANK_IMPORT.purge_data' );
      RAISE;
    END IF;
END purge_data;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       archive_lines
|                                                                       |
|  DESCRIPTION                                                          |
|       Archive transactions in lines tables				|
|                                                                       |
|  CALLED BY                                                            |
|       import_process							|
 --------------------------------------------------------------------- */
PROCEDURE archive_lines	IS
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('>>CE_AUTO_BANK_IMPORT.archive_lines');
  END IF;
  INSERT INTO ce_arch_interface_lines
	       (bank_account_num,
		statement_number,
		line_number,
		trx_date,
		trx_code,
		effective_date,
		trx_text,
		invoice_text,
		amount,
		charges_amount,
		currency_code,
		user_exchange_rate_type,
		exchange_rate_date,
		exchange_rate,
		original_amount,
		bank_trx_number,
		customer_text,
 		bank_account_text,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		attribute_category,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15)
  SELECT 	bank_account_num,
       		statement_number,
		line_number,
		trx_date,
		trx_code,
		effective_date,
		trx_text,
		invoice_text,
		amount,
		charges_amount,
		currency_code,
		user_exchange_rate_type,
		exchange_rate_date,
		exchange_rate,
		original_amount,
		bank_trx_number,
		customer_text,
		bank_account_text,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		attribute_category,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15
  FROM ce_statement_lines_interface
  WHERE statement_number = CE_AUTO_BANK_IMPORT.G_cshi_statement_number
  AND   bank_account_num = CE_AUTO_BANK_IMPORT.G_cshi_bank_account_num;
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('<<CE_AUTO_BANK_IMPORT.archive_lines');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('EXCEPTION:  CE_AUTO_BANK_IMPORT.archive_lines');
    END IF;
    RAISE;
END archive_lines;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       archive_header
|                                                                       |
|  DESCRIPTION                                                          |
|       Archive transactions interface header tables			|
|                                                                       |
|  CALLED BY                                                            |
|       import_process							|
 ---------------------------------------------------------------------- */
PROCEDURE archive_header IS
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('>>CE_AUTO_BANK_IMPORT.archive_header');
  END IF;
  INSERT INTO ce_arch_interface_headers
	       (statement_number,
		bank_account_num,
		statement_date,
	        check_digits,
		bank_name,
		bank_branch_name,
		control_begin_balance,
		control_end_balance,
		cashflow_balance,
		int_calc_balance,
		average_close_ledger_mtd,
		average_close_ledger_ytd,
		average_close_available_mtd,
		average_close_available_ytd,
		one_day_float,
		two_day_float,
		intra_day_flag,
		control_total_dr,
		control_total_cr,
		control_dr_line_count,
		control_cr_line_count,
                control_line_count,
		record_status_flag,
		currency_code,
		created_by,
		creation_date,
		attribute_category,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15,
		last_updated_by,
		last_update_date)
		--org_id)
  SELECT  	statement_number,
		bank_account_num,
		statement_date,
		check_digits,
		bank_name,
		bank_branch_name,
		control_begin_balance,
		control_end_balance,
		cashflow_balance,
		int_calc_balance,
		average_close_ledger_mtd,
		average_close_ledger_ytd,
		average_close_available_mtd,
		average_close_available_ytd,
		one_day_float,
		two_day_float,
		intra_day_flag,
		control_total_dr,
		control_total_cr,
		control_dr_line_count,
		control_cr_line_count,
                control_line_count,
		record_status_flag,
		currency_code,
		created_by,
		creation_date,
		attribute_category,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15,
		last_updated_by,
		last_update_date
		--org_id
  FROM  ce_statement_headers_int
  WHERE rowid = CE_AUTO_BANK_IMPORT.G_cshi_rowid;
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('<<CE_AUTO_BANK_IMPORT.archive_header');
  END IF;
EXCEPTION
   WHEN OTHERS THEN
     IF l_DEBUG in ('Y', 'C') THEN
       cep_standard.debug('EXCEPTION:  CE_AUTO_BANK_IMPORT.archive_header');
     END IF;
     RAISE;
END archive_header;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	get_sequence_info						|
|									|
|  DESCRIPTION								|
|	get the document sequence information				|
|									|
|  CALLED BY								|
|	transfer_header, reconcile_trx, reconcile_rbatch		|
 --------------------------------------------------------------------- */
FUNCTION get_sequence_info (app_id		IN NUMBER,
			    category_code	IN VARCHAR2,
			    set_of_books_id	IN NUMBER,
			    entry_method	IN CHAR,
			    trx_date		IN DATE,
			    seq_name	IN	OUT NOCOPY VARCHAR2,
			    seq_id	IN 	OUT NOCOPY NUMBER,
			    seq_value	IN	OUT NOCOPY NUMBER) RETURN BOOLEAN IS
  l_return_code		NUMBER;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_IMPORT.get_sequence_info' );
  END IF;
  IF (CE_AUTO_BANK_REC.G_sequence_numbering IN ('A','P')) THEN
    --
    -- bug# 1062247
    -- Change FND_SEQNUM.get_next_sequence call to FND_SEQNUM.get_seq_val call
    --
    l_return_code := FND_SEQNUM.get_seq_val( app_id,
                               		     category_code,
                                     	     set_of_books_id,
                                             entry_method,
                                             trx_date,
				             seq_value,
				             seq_id,
				             'N', 'N');

    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('get_sequence_info: ' || '>>CE_AUTO_BANK_IMPORT.dbseqname:  '|| seq_name || '----------' ||
    	'get_sequence_info: ' || '>>CE_AUTO_BANK_IMPORT.seq_id:  '|| TO_CHAR( seq_id ) || '----------' ||
    	'get_sequence_info: ' || '>>CE_AUTO_BANK_IMPORT.doc_seq_value:  '|| TO_CHAR( seq_value ) );
    END IF;
  END IF;
  IF (((NVL(seq_value,0) = 0) OR l_return_code <> 0)
	AND (CE_AUTO_BANK_REC.G_sequence_numbering = 'A' )) THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_IMPORT.get_sequence_info' );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (CE_AUTO_BANK_REC.G_sequence_numbering= 'A') THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
END get_sequence_info;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	lock_statement							|
|									|
|  DESCRIPTION								|
|	Using the rowid, retrieve the statement details.		|
|									|
|  CALLED BY								|
|	import_prcess							|
 --------------------------------------------------------------------- */
FUNCTION lock_statement RETURN BOOLEAN IS
  X_statement_number CE_STATEMENT_HEADERS_INT.statement_number%TYPE;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('>>CE_AUTO_BANK_IMPORT.lock_statement');
  END IF;
  SELECT  statement_number
  INTO    X_statement_number
  FROM    ce_statement_headers_int
  WHERE   rowid = CE_AUTO_BANK_IMPORT.G_cshi_rowid
  FOR UPDATE OF statement_number NOWAIT;

  IF l_DEBUG in ('Y', 'C') THEN
  cep_standard.debug('<<CE_AUTO_BANK_IMPORT.lock_statement');
  END IF;
  RETURN(TRUE);
EXCEPTION
  WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('EXCEPTION: CE_AUTO_BANK_IMPORT.lock_statement STATEMENT LOCKED');
    END IF;
    return(FALSE);
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('EXCEPTION: CE_AUTO_BANK_IMPORT.lock_statement');
    END IF;
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
|	import_prcess							|
 --------------------------------------------------------------------- */
FUNCTION lock_statement_line(csli_rowid IN  VARCHAR2) RETURN BOOLEAN IS
  csli_amount	CE_STATEMENT_LINES.amount%TYPE;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_IMPORT.lock_statement_line');
  END IF;
  SELECT  amount
  INTO    csli_amount
  FROM    ce_statement_lines_interface
  WHERE   rowid = csli_rowid
  FOR UPDATE OF bank_account_num NOWAIT;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_IMPORT.lock_statement_line');
  END IF;
  RETURN(TRUE);
EXCEPTION
  WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: CE_AUTO_BANK_IMPORT.lock_statement_line STATEMENT LOCKED');
    END IF;
    return(FALSE);
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: CE_AUTO_BANK_IMPORT.lock_statement_line');
    END IF;
    RAISE;
    return(FALSE);
END lock_statement_line;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	transfer_lines							|
|									|
|  DESCRIPTION								|
|	Copy the statement lines in CE_STATEMENT_LINES_INTERFACE into	|
|	CE_STATEMENT_LINES for the given statement and bank account	|
|	combination.  Record the bank account id and not the bank	|
|	account number.  If the currency field is null, populate it 	|
|	with the base currency of the bank.				|
|									|
|  CALLED BY								|
|	import_process							|
|									|
|  HISTORY								|
 --------------------------------------------------------------------- */
PROCEDURE transfer_lines IS

  fixed_relation		BOOLEAN;
  curr_relation			VARCHAR2(30);

BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('>>CE_AUTO_BANK_IMPORT.transfer_lines');
    cep_standard.debug('func: '||CE_AUTO_BANK_REC.G_functional_currency);
  END IF;

  IF (G_cshi_intra_day_flag = 'Y' AND CE_AUTO_BANK_REC.G_intra_day_flag = 'Y') THEN
    INSERT INTO ce_intra_stmt_lines
	       (statement_line_id,
		statement_header_id,
		line_number,
		trx_date,
		trx_type,
		trx_code_id,
		effective_date,
		bank_trx_number,
		trx_text,
		customer_text,
		invoice_text,
		bank_account_text,
		amount,
		charges_amount,
		status,
		currency_code,
		exchange_rate_type,
		exchange_rate_date,
		exchange_rate,
		original_amount,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		attribute_category,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15)
	SELECT  ce_intra_stmt_lines_s.nextval,
		G_cshi_statement_header_id,
		csli.line_number,
		csli.trx_date,
		ctc.trx_type,
		ctc.transaction_code_id,
		NVL(csli.effective_date,csli.trx_date+NVL(ctc.float_days,0)),
		csli.bank_trx_number,
		csli.trx_text,
		csli.customer_text,
		csli.invoice_text,
		csli.bank_account_text,
		csli.amount,
		csli.charges_amount,
		'',
		csli.currency_code,
		null,
		csli.exchange_rate_date,
		csli.exchange_rate,
		csli.original_amount,
		NVL(FND_GLOBAL.user_id, -1),
		sysdate,
		NVL(FND_GLOBAL.user_id, -1),
		sysdate,
		csli.attribute_category,
		csli.attribute1,
		csli.attribute2,
		csli.attribute3,
		csli.attribute4,
		csli.attribute5,
		csli.attribute6,
		csli.attribute7,
		csli.attribute8,
		csli.attribute9,
		csli.attribute10,
		csli.attribute11,
		csli.attribute12,
		csli.attribute13,
		csli.attribute14,
		csli.attribute15
	FROM 	ce_transaction_codes 				ctc,
		ce_statement_lines_interface 			csli,
		ce_bank_accts_gt_v   aba   --ce_bank_accounts_v aba
	WHERE	ctc.trx_code(+)	= csli.trx_code
	AND     NVL(ctc.bank_account_id,aba.bank_account_id) 	=
						aba.bank_account_id
	AND 	csli.statement_number = G_cshi_statement_number
	AND     csli.bank_account_num = aba.bank_account_num
	AND	aba.bank_account_id = G_bank_account_id
	AND ctc.reconciliation_sequence = CE_AUTO_BANK_IMPORT.G_trx_recon_seq_id; -- Bug 8965556 Added condition
  ELSIF (nvl(G_cshi_intra_day_flag,'N') <> 'Y' AND CE_AUTO_BANK_REC.G_intra_day_flag <> 'Y') THEN
  --Bug 6710502: Added an nvl to subsisdiary flag to handle records upgraded from 11i to R12
	IF ( nvl(G_cshi_subsidiary_flag,'N') = 'N' ) THEN
      INSERT INTO ce_statement_lines
	       (statement_line_id,
		statement_header_id,
		line_number,
		trx_date,
		trx_type,
		trx_code, --trx_code_id,
		effective_date,
		bank_trx_number,
		trx_text,
		customer_text,
		invoice_text,
		bank_account_text,
		amount,
		charges_amount,
		status,
		currency_code,
		exchange_rate_type,
		exchange_rate_date,
		exchange_rate,
		original_amount,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		attribute_category,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15)
	SELECT  ce_statement_lines_s.nextval,
		CE_AUTO_BANK_IMPORT.G_cshi_statement_header_id,
		csli.line_number,
		csli.trx_date,
		(select distinct ctc.trx_type
			from ce_transaction_codes ctc
			 where ctc.trx_code(+)	= csli.trx_code
			AND     NVL(ctc.bank_account_id,aba.bank_account_id) 	=
						aba.bank_account_id),
		csli.trx_code, --ctc.transaction_code_id,
		--NVL(csli.effective_date,csli.trx_date+NVL(ctc.float_days,0)),
		NVL(csli.effective_date,csli.trx_date),
		-- Bug #8687512 Start - Added ltrim(rtrim())
		ltrim(rtrim(csli.bank_trx_number)),
		ltrim(rtrim(csli.trx_text)),
		ltrim(rtrim(csli.customer_text)),
		ltrim(rtrim(csli.invoice_text)),
		ltrim(rtrim(csli.bank_account_text)),
		-- Bug #8687512 End
		csli.amount,
		csli.charges_amount,
		'UNRECONCILED',
		csli.currency_code,
		decode(gl_currency_api.is_fixed_rate(
			CE_AUTO_BANK_REC.G_functional_currency,
			nvl(csli.currency_code,aba.currency_code),
			nvl(csli.exchange_rate_date,csli.trx_date)),
			'Y', decode(gdct.conversion_type, NULL,NULL,
			decode(nvl(csli.currency_code,aba.currency_code),
			CE_AUTO_BANK_REC.G_functional_currency,
			gdct.conversion_type,'EMU FIXED')),
			gdct.conversion_type),
		csli.exchange_rate_date,
		csli.exchange_rate,
		csli.original_amount,
		NVL(FND_GLOBAL.user_id, -1),
		sysdate,
		NVL(FND_GLOBAL.user_id, -1),
		sysdate,
		csli.attribute_category,
		csli.attribute1,
		csli.attribute2,
		csli.attribute3,
		csli.attribute4,
		csli.attribute5,
		csli.attribute6,
		csli.attribute7,
		csli.attribute8,
		csli.attribute9,
		csli.attribute10,
		csli.attribute11,
		csli.attribute12,
		csli.attribute13,
		csli.attribute14,
		csli.attribute15
	FROM 	--ce_transaction_codes 				ctc,
		gl_daily_conversion_types 			gdct,
		ce_statement_lines_interface 			csli,
		ce_bank_accts_gt_v  aba    --ce_bank_accounts_v aba
	WHERE	gdct.user_conversion_type(+) 	= csli.user_exchange_rate_type
	--AND	ctc.trx_code(+)			= csli.trx_code
	--AND     NVL(ctc.bank_account_id,aba.bank_account_id) 	=
	--					aba.bank_account_id
	AND 	csli.statement_number =
				CE_AUTO_BANK_IMPORT.G_cshi_statement_number
	AND     csli.bank_account_num 	= aba.bank_account_num
	AND	aba.bank_account_id	= CE_AUTO_BANK_IMPORT.G_bank_account_id;
    END IF;
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('<<CE_AUTO_BANK_IMPORT.transfer_lines');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('EXCEPTION:  CE_AUTO_BANK_IMPORT.transfer_lines');
    END IF;
    RAISE;
END transfer_lines;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	transfer_header							|
|									|
|  DESCRIPTION								|
|	Copy the header line in CE_STATEMENT_HEADER_INTERFACE into	|
|	CE_STATEMENT_HEADERS for the given statement and bank account	|
|	combination.  Record the bank account id and not the bank	|
|	account number.							|
|									|
|  CALLED BY								|
|	import_process							|
 --------------------------------------------------------------------- */
FUNCTION transfer_header( aba_bank_account_id		NUMBER,
			  aba_bank_account_name		VARCHAR2) RETURN BOOLEAN IS
  l_dbseqname         		VARCHAR2(30);
  l_doc_seq_id        		NUMBER;
  l_doc_seq_value     		NUMBER;
  x_bal_count			    NUMBER;
  l_valid_seq	      		BOOLEAN;
  l_dup_balance				BOOLEAN;
  l_encoded_message		VARCHAR2(255);
  l_message_name		VARCHAR2(50);
  l_app_short_name		VARCHAR2(30);
  x_temp_rowid			VARCHAR2(100);
  x_flag			VARCHAR2(2);
  X_bank_acct_balance_id    NUMBER;

BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_IMPORT.transfer_header '||
  	' CE_AUTO_BANK_IMPORT.aba_bank_account_id   :  '|| aba_bank_account_id||
  	', CE_AUTO_BANK_IMPORT.aba_bank_account_name :  '|| aba_bank_account_name);
  END IF;
  --
  -- Call the AOL sequence numbering routine to get Seq. number
  --
  l_valid_seq := CE_AUTO_BANK_IMPORT.get_sequence_info(260,
			      aba_bank_account_name,
			      CE_AUTO_BANK_REC.G_set_of_books_id,
			      'A',
			      CE_AUTO_BANK_IMPORT.G_cshi_statement_date,
			      l_dbseqname,
			      l_doc_seq_id,
			      l_doc_seq_value );



  IF (NOT l_valid_seq) THEN

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('transfer_header not l_valid_seq  ');
  END IF;

    l_valid_seq := CE_AUTO_BANK_IMPORT.header_error('CE_DOC_SEQUENCE_HEADER_ERR');
    update_header_status('E');
    return FALSE;
  ELSE
    CE_AUTO_BANK_IMPORT.G_cshi_statement_header_id := NULL;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('G_cshi_intra_day_flag  '|| G_cshi_intra_day_flag ||
  	', CE_AUTO_BANK_REC.G_intra_day_flag  '|| CE_AUTO_BANK_REC.G_intra_day_flag);
  END IF;

    IF (G_cshi_intra_day_flag = 'Y' AND CE_AUTO_BANK_REC.G_intra_day_flag = 'Y') THEN
      DELETE FROM CE_INTRA_STMT_LINES
      WHERE statement_header_id in
	(select statement_header_id
	from ce_intra_stmt_headers
	where statement_number = G_cshi_statement_number
        and bank_account_id in
	  (select bank_account_id from ce_bank_accounts_v
	  where bank_account_num = G_cshi_bank_account_num));
      DELETE FROM CE_INTRA_STMT_HEADERS
      WHERE statement_number = G_cshi_statement_number
      AND bank_account_id in
	(select bank_account_id from ce_bank_accounts_v
	where bank_account_num = G_cshi_bank_account_num);

      select ce_intra_stmt_headers_s.nextval
	into G_cshi_statement_header_id
	from sys.dual;
      INSERT INTO CE_INTRA_STMT_HEADERS (
		statement_header_id,
             	bank_account_id,
             	statement_number,
             	statement_date,
		check_digits,
             	control_begin_balance,
             	control_end_balance,
             	cashflow_balance,
             	int_calc_balance,
		one_day_float,
		two_day_float,
             	control_total_dr,
             	control_total_cr,
             	control_dr_line_count,
             	control_cr_line_count,
             	doc_sequence_id,
             	doc_sequence_value,
             	created_by,
             	creation_date,
             	last_updated_by,
             	last_update_date,
             	attribute_category,
             	attribute1,
             	attribute2,
             	attribute3,
             	attribute4,
             	attribute5,
             	attribute6,
             	attribute7,
             	attribute8,
             	attribute9,
             	attribute10,
             	attribute11,
             	attribute12,
             	attribute13,
             	attribute14,
             	attribute15,
             	auto_loaded_flag,
             	statement_complete_flag,
             	gl_date)
		--org_id)
	VALUES
            	(G_cshi_statement_header_id,
             	aba_bank_account_id,
             	G_cshi_statement_number,
             	G_cshi_statement_date,
		G_cshi_check_digits,
             	G_cshi_control_begin_balance,
             	G_cshi_control_end_balance,
             	G_cshi_cashflow_balance,
             	G_cshi_int_calc_balance,
		G_cshi_one_day_float,
		G_cshi_two_day_float,
             	G_cshi_control_total_dr,
             	G_cshi_control_total_cr,
             	G_cshi_control_dr_line_count,
             	G_cshi_control_cr_line_count,
             	l_doc_seq_id,
             	l_doc_seq_value,
             	NVL(FND_GLOBAL.user_id,-1),
             	sysdate,
             	NVL(FND_GLOBAL.user_id,-1),
             	sysdate,
             	G_cshi_attribute_category,
             	G_cshi_attribute1,
             	G_cshi_attribute2,
             	G_cshi_attribute3,
             	G_cshi_attribute4,
             	G_cshi_attribute5,
             	G_cshi_attribute6,
             	G_cshi_attribute7,
             	G_cshi_attribute8,
             	G_cshi_attribute9,
             	G_cshi_attribute10,
             	G_cshi_attribute11,
             	G_cshi_attribute12,
             	G_cshi_attribute13,
             	G_cshi_attribute14,
             	G_cshi_attribute15,
             	'Y',
             	'N',
             	null);
		--G_cshi_org_id);
      update_header_status('T');
      RETURN TRUE;
    ELSIF ( nvl(G_cshi_intra_day_flag,'N') <> 'Y'  AND CE_AUTO_BANK_REC.G_intra_day_flag <> 'Y') THEN

    --check if statement date is less than sysdate
    -- cannot import statements with date  greater than or equal to sysdate
    -- Bug 8726869
    if (trunc(CE_AUTO_BANK_IMPORT.G_cshi_statement_date) >  trunc(sysdate)) then
	l_dup_balance:= CE_AUTO_BANK_IMPORT.header_error('CE_LOD_STATEMENT_DATE');
	RETURN FALSE;
    end if;

    select count(1)
    into x_bal_count
    from ce_bank_acct_balances
    where bank_account_id = aba_bank_account_id
    and balance_date = trunc(CE_AUTO_BANK_IMPORT.G_cshi_statement_date);

    IF x_bal_count > 0 THEN
	x_flag:='YI'; --balance already exist when inserting through loader
       --check if all the balance values are same, if yes then no log message required
	if ( check_balance_values(aba_bank_account_id)=0)then
	 l_dup_balance:=CE_AUTO_BANK_IMPORT.header_error('CE_DUP_BALANCE');
	end if;
    ELSE
	x_flag:='N';
    END IF;

    -- bug 6893481: adding an NVL clause to handle cases where subsidiary
	-- flag would be null.
    IF ( NVL(G_cshi_subsidiary_flag,'N') = 'N' ) THEN
      CE_STAT_HDRS_DML_PKG.insert_row (
			X_rowid 				=> x_temp_rowid,
			X_statement_header_id	=> CE_AUTO_BANK_IMPORT.G_cshi_statement_header_id,
			X_bank_account_id		=> aba_bank_account_id,
			X_statement_number		=> CE_AUTO_BANK_IMPORT.G_cshi_statement_number,
			X_statement_date		=> trunc(CE_AUTO_BANK_IMPORT.G_cshi_statement_date),
			X_check_digits			=> CE_AUTO_BANK_IMPORT.G_cshi_check_digits,
			X_control_begin_balance	=> CE_AUTO_BANK_IMPORT.G_cshi_control_begin_balance,
			X_control_end_balance	=> CE_AUTO_BANK_IMPORT.G_cshi_control_end_balance,
			X_cashflow_balance		=> CE_AUTO_BANK_IMPORT.G_cshi_cashflow_balance,
			X_int_calc_balance		=> CE_AUTO_BANK_IMPORT.G_cshi_int_calc_balance,
			X_one_day_float			=> CE_AUTO_BANK_IMPORT.G_cshi_one_day_float,
			X_two_day_float			=> CE_AUTO_BANK_IMPORT.G_cshi_two_day_float,
			X_control_total_dr		=> CE_AUTO_BANK_IMPORT.G_cshi_control_total_dr,
			X_control_total_cr		=> CE_AUTO_BANK_IMPORT.G_cshi_control_total_cr,
			X_control_dr_line_count	=> CE_AUTO_BANK_IMPORT.G_cshi_control_dr_line_count,
			X_control_cr_line_count	=> CE_AUTO_BANK_IMPORT.G_cshi_control_cr_line_count,
			X_doc_sequence_id		=> l_doc_seq_id,
			X_doc_sequence_value	=> l_doc_seq_value,
			X_created_by			=> NVL(FND_GLOBAL.user_id,-1),
			X_creation_date			=> sysdate,
			X_last_updated_by		=> NVL(FND_GLOBAL.user_id,-1),
			X_last_update_date		=> sysdate,
			X_attribute_category	=> CE_AUTO_BANK_IMPORT.G_cshi_attribute_category ,
			X_attribute1			=> CE_AUTO_BANK_IMPORT.G_cshi_attribute1,
			X_attribute2			=> CE_AUTO_BANK_IMPORT.G_cshi_attribute2,
			X_attribute3			=> CE_AUTO_BANK_IMPORT.G_cshi_attribute3,
			X_attribute4			=> CE_AUTO_BANK_IMPORT.G_cshi_attribute4,
			X_attribute5			=> CE_AUTO_BANK_IMPORT.G_cshi_attribute5,
			X_attribute6			=> CE_AUTO_BANK_IMPORT.G_cshi_attribute6,
			X_attribute7			=> CE_AUTO_BANK_IMPORT.G_cshi_attribute7,
			X_attribute8			=> CE_AUTO_BANK_IMPORT.G_cshi_attribute8,
			X_attribute9			=> CE_AUTO_BANK_IMPORT.G_cshi_attribute9,
			X_attribute10			=> CE_AUTO_BANK_IMPORT.G_cshi_attribute10,
			X_attribute11			=> CE_AUTO_BANK_IMPORT.G_cshi_attribute11,
			X_attribute12			=> CE_AUTO_BANK_IMPORT.G_cshi_attribute12,
			X_attribute13			=> CE_AUTO_BANK_IMPORT.G_cshi_attribute13,
			X_attribute14			=> CE_AUTO_BANK_IMPORT.G_cshi_attribute14,
			X_attribute15			=> CE_AUTO_BANK_IMPORT.G_cshi_attribute15,
			X_auto_loaded_flag			=> 'Y',
			X_statement_complete_flag	=> 'N',
			X_gl_date				=> CE_AUTO_BANK_REC.G_gl_date,
			X_balance_flag			=> x_flag,
			X_average_close_ledger_mtd		=> CE_AUTO_BANK_IMPORT.G_cshi_close_ledger_mtd,
			X_average_close_ledger_ytd		=> CE_AUTO_BANK_IMPORT.G_cshi_close_ledger_ytd,
			X_average_close_available_mtd	=> CE_AUTO_BANK_IMPORT.G_cshi_close_available_mtd,
			X_average_close_available_ytd	=> CE_AUTO_BANK_IMPORT.G_cshi_close_available_ytd,
		-- 5916290 : GDF Changes
			X_bank_acct_balance_id  => NULL,
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
			X_global_attribute20	=> NULL
		);
	ELSE
	      SELECT CE_BANK_ACCT_BALANCES_S.nextval
	      INTO X_bank_acct_balance_id
	      FROM SYS.dual;

	      INSERT INTO CE_BANK_ACCT_BALANCES
		(bank_acct_balance_id,
		 bank_account_id,
		 balance_date,
		 ledger_balance,
		 available_balance,
		 value_dated_balance,
		 one_day_float,
		 two_day_float,
		 average_close_ledger_mtd,
		 average_close_ledger_ytd,
		 average_close_available_mtd,
		 average_close_available_ytd,
		 last_update_date,
		 last_updated_by,
		 creation_date,
		 created_by,
		 last_update_login,
		 object_version_number)
		values
		(X_bank_acct_balance_id,
		 aba_bank_account_id,
		 trunc(CE_AUTO_BANK_IMPORT.G_cshi_statement_date),
		 CE_AUTO_BANK_IMPORT.G_cshi_control_end_balance,
		 CE_AUTO_BANK_IMPORT.G_cshi_cashflow_balance,
		 CE_AUTO_BANK_IMPORT.G_cshi_int_calc_balance,
		 CE_AUTO_BANK_IMPORT.G_cshi_one_day_float,
		 CE_AUTO_BANK_IMPORT.G_cshi_two_day_float,
		 CE_AUTO_BANK_IMPORT.G_cshi_close_ledger_mtd,
		 CE_AUTO_BANK_IMPORT.G_cshi_close_ledger_ytd,
		 CE_AUTO_BANK_IMPORT.G_cshi_close_available_mtd,
		 CE_AUTO_BANK_IMPORT.G_cshi_close_available_ytd,
		 sysdate,
		 NVL(FND_GLOBAL.user_id,-1),
		 sysdate,
		 NVL(FND_GLOBAL.user_id,-1),
		 NVL(FND_GLOBAL.user_id,-1),
		 '1');
	END IF;

      update_header_status('T');
      RETURN TRUE;
    ELSE
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('transfer_header return false' );
  END IF;
      RETURN FALSE;
    END IF;
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_IMPORT.transfer_header');
  END IF;
EXCEPTION
  WHEN APP_EXCEPTION.application_exception THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:CE_AUTO_BANK_IMPORT.transfer_header-APP_EXCEPTION');
    END IF;
    l_encoded_message := FND_MESSAGE.GET_ENCODED;
    IF (l_encoded_message IS NOT NULL) THEN
      FND_MESSAGE.parse_encoded(l_encoded_message,l_app_short_name,l_message_name);
    ELSE
      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('transfer_header: ' || 'No messages on stack');
      END IF;
      l_message_name := 'OTHER_APP_ERROR';
    END IF;
    l_valid_seq := CE_AUTO_BANK_IMPORT.header_error('CE_DOC_SEQUENCE_HEADER_ERR');
    update_header_status('E');
    return FALSE;
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_AUTO_BANK_IMPORT.transfer_header');
    END IF;
    RAISE;
END transfer_header;


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	update_header_status						|
|									|
|  DESCRIPTION								|
|	Errors have been found within the statement header or lines.	|
|	The statement header record status is updated with 'ERROR'.	|
|									|
|  CALLED BY								|
|	import_process							|
|									|
|  REQUIRES								|
|	p_status		Status to be updated			|
|	'T'ransferred							|
|	'E'rror								|
 --------------------------------------------------------------------- */
PROCEDURE update_header_status(p_status	VARCHAR2)  IS
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_IMPORT.update_header_status');
  END IF;
  UPDATE ce_statement_headers_int
  SET    record_status_flag = p_status
  WHERE  rowid = CE_AUTO_BANK_IMPORT.G_cshi_rowid;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_IMPORT.update_header_status');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_AUTO_BANK_IMPORT.update_header_status');
    END IF;
    RAISE;
END update_header_status;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	validate_control_totals						|
|									|
|  DESCRIPTION								|
|	Many control totals are held within the statement header and	|
|	may be used to check that all the statement lines have been	|
|	loaded.								|
|									|
|  CALLED BY								|
|	import_process							|
|									|
|  RETURNS								|
|	error_found		BOOLEAN					|
 --------------------------------------------------------------------- */
FUNCTION validate_control_totals RETURN BOOLEAN IS
  error_found BOOLEAN;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('>>CE_AUTO_BANK_IMPORT.validate_control_totals');
  END IF;
  error_found := FALSE;
 IF (NVL(CE_AUTO_BANK_IMPORT.G_cshi_control_total_dr,CE_AUTO_BANK_IMPORT.G_dr_sum) <> CE_AUTO_BANK_IMPORT.G_dr_sum) THEN
    error_found := CE_AUTO_BANK_IMPORT.header_error('CE_CTRL_DR_TOTAL');
  END IF;
  IF (NVL(CE_AUTO_BANK_IMPORT.G_cshi_control_total_cr,CE_AUTO_BANK_IMPORT.G_cr_sum) <> CE_AUTO_BANK_IMPORT.G_cr_sum) THEN
    error_found := CE_AUTO_BANK_IMPORT.header_error('CE_CTRL_CR_TOTAL');
  END IF;
  IF (NVL(CE_AUTO_BANK_IMPORT.G_cshi_control_dr_line_count,CE_AUTO_BANK_IMPORT.G_dr_count) <> CE_AUTO_BANK_IMPORT.G_dr_count) THEN
    error_found := CE_AUTO_BANK_IMPORT.header_error('CE_DR_LINE_COUNT');
  END IF;
  IF (NVL(CE_AUTO_BANK_IMPORT.G_cshi_control_cr_line_count,CE_AUTO_BANK_IMPORT.G_cr_count) <> CE_AUTO_BANK_IMPORT.G_cr_count) THEN
    error_found := CE_AUTO_BANK_IMPORT.header_error('CE_CR_LINE_COUNT');
  END IF;
  IF (NVL(CE_AUTO_BANK_IMPORT.G_cshi_control_begin_balance,0) -
      NVL(CE_AUTO_BANK_IMPORT.G_cshi_control_total_dr,0) +
      NVL(CE_AUTO_BANK_IMPORT.G_cshi_control_total_cr,0) <> NVL(CE_AUTO_BANK_IMPORT.G_cshi_control_end_balance,0)) THEN
    error_found := CE_AUTO_BANK_IMPORT.header_error('CE_CTRL_END_BALANCE');
  END IF;
  IF (NVL(CE_AUTO_BANK_IMPORT.G_cshi_control_line_count,CE_AUTO_BANK_IMPORT.G_total_count) <> CE_AUTO_BANK_IMPORT.G_total_count) THEN
      error_found := CE_AUTO_BANK_IMPORT.header_error('CE_LINE_COUNT');
  END IF;
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('<<CE_AUTO_BANK_IMPORT.validate_control_totals');
  END IF;
  return error_found;
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION:  CE_AUTO_BANK_IMPORT.validate_control_totals');
    RAISE;
END validate_control_totals;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	validate_bank_account						|
|									|
|  CALLED BY								|
|	header_validation						|
 --------------------------------------------------------------------- */
PROCEDURE validate_bank_account (aba_bank_currency	   VARCHAR2,
				 aba_bank_check_digits     VARCHAR2,
				 error_found	           OUT NOCOPY BOOLEAN) IS
  trx_code_count	NUMBER;
  aba_bank_account_id   NUMBER;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_IMPORT.validate_bank_account');
  END IF;
  --
  -- Bank and bank branch name validations
  -- NOTE: We just check for the 'INTERNAL' accounts
  --
/* Bug# 599912: internal bank account is already validated when bank_account_id is passed to the package.

	  SELECT aba.bank_account_id
	  INTO   aba_bank_account_id
	  FROM   ap_bank_branches abb,
		 ap_bank_accounts aba
	  WHERE  aba.bank_branch_id   = abb.bank_branch_id
	  AND    abb.bank_name        = nvl(CE_AUTO_BANK_IMPORT.G_cshi_bank_name, abb.bank_name)
	  AND    abb.bank_branch_name = nvl(CE_AUTO_BANK_IMPORT.G_cshi_bank_branch_name,abb.bank_branch_name)
	  AND    aba.bank_account_num = CE_AUTO_BANK_IMPORT.G_cshi_bank_account_num
	  AND	 aba.account_type     = 'INTERNAL';
	*/
  --
  -- Check for existence of the Transaction codes
  -- We need to do this because of the control total validation relies on these codes
  --
  SELECT 	count(*)
  INTO  	trx_code_count
  FROM 		ce_transaction_codes
  WHERE 	bank_account_id = CE_AUTO_BANK_IMPORT.G_bank_account_id;
  IF (trx_code_count = 0) THEN
    error_found := CE_AUTO_BANK_IMPORT.header_error('CE_NO_TRX_CODES');
  END IF;
  --
  -- Bank account currency code validation
  --
  IF (aba_bank_currency <> NVL(CE_AUTO_BANK_IMPORT.G_cshi_currency_code,aba_bank_currency)) THEN
    error_found := CE_AUTO_BANK_IMPORT.header_error('CE_FOREIGN_CURRENCY');
  END IF;
  --
  -- Check digits validation -- bug 7214921
  If CE_AUTO_BANK_IMPORT.G_cshi_check_digits is not null and aba_bank_check_digits is not null Then
     IF ( CE_AUTO_BANK_IMPORT.G_cshi_check_digits <> aba_bank_check_digits ) THEN
		error_found := CE_AUTO_BANK_IMPORT.header_error('CE_CHECK_DIGITS');
      END IF;
   End If ;

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_IMPORT.validate_bank_account');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (SQL%NOTFOUND) THEN
      error_found := CE_AUTO_BANK_IMPORT.header_error('CE_INVALID_BANK');
      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('validate_bank_account: ' || 'error: BANK NOT FOUND');
      END IF;
    ELSIF (SQL%ROWCOUNT > 0) THEN
      error_found := CE_AUTO_BANK_IMPORT.header_error('CE_DUP_BANK');
      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('validate_bank_account: ' || 'error: DUPLICATE BANK');
      END IF;
    ELSE
      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('validate_bank_account: ' || 'error: OTHER BANK VALIDATION');
      END IF;
      RAISE;
    END IF;
END validate_bank_account;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	header_validation						|
|									|
|  DESCRIPTION								|
|	Validate the statement header records				|
|	on the interface tables for import errors.  If any errors are	|
|	detected, the statement will not be imported.			|
|									|
|  CALLS								|
|	validate_bank_account						|
|	gl_date_found							|
|	check for existing statement				        |
|									|
|  CALLED BY								|
|	import_process							|
 --------------------------------------------------------------------- */
FUNCTION header_validation(	r_statement_number		VARCHAR2,
				aba_bank_currency	 	VARCHAR2,
				aba_bank_check_digits		VARCHAR2,
				aba_bank_account_id		NUMBER) RETURN BOOLEAN IS
  bank_error  		BOOLEAN;
  duplicate_found	BOOLEAN;
  gl_date_found 	BOOLEAN;
  error_found 		BOOLEAN;
  account_type		VARCHAR2(25);
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_IMPORT.header_validation');
  END IF;
  error_found			:= FALSE;
  bank_error			:= FALSE;
  duplicate_found		:= FALSE;
  gl_date_found			:= TRUE;

/*
  --SELECT aba.account_type
  SELECT aba.account_classification
  INTO   account_type
  FROM   ce_bank_branches_v abb,
	 ce_bank_accts_gt_v aba --ce_bank_accounts_v aba
  WHERE  aba.bank_branch_id   = abb.branch_party_id
  AND    abb.bank_name        = nvl(CE_AUTO_BANK_IMPORT.G_cshi_bank_name, abb.bank_name)
  AND    abb.bank_branch_name = nvl(CE_AUTO_BANK_IMPORT.G_cshi_bank_branch_name,abb.bank_branch_name)
  AND    aba.bank_account_num = CE_AUTO_BANK_IMPORT.G_cshi_bank_account_num
  AND    aba.bank_account_id   = aba_bank_account_id;
*/
  --
  -- 1. Bank account
  --
  validate_bank_account(aba_bank_currency, aba_bank_check_digits, bank_error);

  --
  -- 2. The GL date (Must be Open or Future Enterable in AP OR AR)
  --    bug 3676745 MO/BA uptake
  --    If the bank account is also used for xtr or payroll, do not check GL DATE

  IF (CE_AUTO_BANK_REC.G_intra_day_flag <> 'Y') THEN
    --IF (account_type <> 'PAYROLL') THEN
    IF (CE_AUTO_BANK_IMPORT.G_xtr_use_allowed_flag = 'N' and
	CE_AUTO_BANK_IMPORT.G_pay_use_allowed_flag = 'N') THEN
      gl_date_found :=
	(CE_AUTO_BANK_REC.find_gl_period(CE_AUTO_BANK_REC.G_gl_date, 222)
	 OR CE_AUTO_BANK_REC.find_gl_period(CE_AUTO_BANK_REC.G_gl_date, 200));
      IF (NOT gl_date_found)  THEN
        error_found := CE_AUTO_BANK_IMPORT.header_error('CE_INVALID_PERIOD');
      END IF;
    END IF;
  END IF;
  --
  -- 3. Already existing in the CE_STATEMENT_HEADERS
  --
  IF (CE_AUTO_BANK_REC.G_intra_day_flag <> 'Y') THEN
    IF (r_statement_number IS NOT NULL) THEN
      duplicate_found := CE_AUTO_BANK_IMPORT.header_error('CE_PREV_IMPORT');
    END IF;
  END IF;

  IF (bank_error) THEN
    error_found := TRUE;
  END IF;
  IF (CE_AUTO_BANK_REC.G_intra_day_flag <> 'Y') THEN
    IF  (duplicate_found OR NOT gl_date_found) THEN
      error_found := TRUE;
    END IF;
  END IF;

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_IMPORT.header_validation');
  END IF;
  RETURN error_found;
EXCEPTION
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_AUTO_BANK_IMPORT.header_validation');
    END IF;
    RAISE;
    RETURN FALSE;
END header_validation;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION							|
|	line_validation							|
|									|
|  DESCRIPTION								|
|	Validate the statement line records				|
|	on the interface tables for import errors.  If any errors are	|
|	detected, the statement will not be imported.			|
|									|
|  CALLED BY								|
|	import_process							|
|									|
|  RETURNS								|
|	aba_bank_account_id	Id for bank account being imported	|
 --------------------------------------------------------------------- */
FUNCTION line_validation(	csli_amount			NUMBER,
				csli_user_exchange_rate_type	VARCHAR2,
				csli_currency_code		VARCHAR2,
				csli_exchange_rate_date		DATE,
				csli_trx_date			DATE,
				csli_line_number		NUMBER,
				csli_trx_code			VARCHAR2,
				aba_bank_currency		VARCHAR2,
				r_trx_code_id			NUMBER,
				r_start_date			DATE,
				r_end_date			DATE,
				r_exchange_rate_type		VARCHAR2,
				r_user_conversion_type		VARCHAR2,
				r_currency_code			VARCHAR2) RETURN BOOLEAN IS
  error_found 		BOOLEAN;
  fixed_rate_yn 	VARCHAR2(30);

BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_AUTO_BANK_IMPORT.line_validation');
  END IF;
  error_found := FALSE;
  --
  -- 1. Line Amount
  --
  IF (csli_amount IS NULL) THEN
    error_found := CE_AUTO_BANK_IMPORT.line_error(csli_line_number, 'CE_NO_AMOUNT');
  END IF;

  --
  -- 2. Trx Code
  --
  -- Null csli_trx_code indicates that the statement interface line is missing
  -- a transaction code.
  --
  IF (csli_trx_code IS NULL) THEN
    error_found := CE_AUTO_BANK_IMPORT.line_error( csli_line_number, 'CE_MISSING_TRX_NUM');

  --
  -- Non-Null csli_trx_code and null r_trx_code_id indicate transaction code is not
  -- defined for the bank.
  --
  -- bug 4435028 BAT, we cannot do this validation because there are multiple rows with same trx_code

  --7194081 Uncommented.
  ELSIF (r_trx_code_id IS NULL) THEN
  error_found := CE_AUTO_BANK_IMPORT.line_error( csli_line_number, 'CE_INVALID_TRX_NUM');

  --
  -- Check effective date of this transaction code.
  -- defined for the bank.
  --
  -- bug 4435028 BAT, we cannot do this validation because there are multiple rows with same trx_code
  -- cannot get start_date and end_date

  --8928828 Validation can be done as only one valid trx code has been considered in
  --lines_cursor if multiple trx_codes exists
  --Lines_cursor is modified to get start_date and end_date
  ELSIF ( CE_AUTO_BANK_IMPORT.G_cshi_statement_date NOT BETWEEN
          NVL(r_start_date, CE_AUTO_BANK_IMPORT.G_cshi_statement_date) AND
          NVL(r_end_date, CE_AUTO_BANK_IMPORT.G_cshi_statement_date)) THEN

      error_found := CE_AUTO_BANK_IMPORT.line_error( csli_line_number, 'CE_INVALID_TRX_NUM_DATE');

  END IF;

  --
  -- 3.Exchange rate type
  --
  IF (csli_user_exchange_rate_type IS NOT NULL AND r_user_conversion_type IS NULL) THEN
    error_found := CE_AUTO_BANK_IMPORT.line_error( csli_line_number, 'CE_INVALID_EXCHANGE_TYPE');
  END IF;

  --
  -- 4. Currency code
  --
  IF (csli_currency_code IS NOT NULL AND r_currency_code IS NULL) THEN
    error_found := CE_AUTO_BANK_IMPORT.line_error( csli_line_number, 'CE_INVALID_CURRENCY');
  END IF;

  --
  -- 5. EMU Fixed type is only for valid curr and xdate
  --
  BEGIN

/*    -- bug 3676745, if p_option = 'IMPORT', no org information to get CE_AUTO_BANK_REC.G_functional_currency

    IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('CE_AUTO_BANK_REC.G_functional_currency = '|| CE_AUTO_BANK_REC.G_functional_currency ||
				',CE_AUTO_BANK_REC.G_interface_purge_flag = ' ||CE_AUTO_BANK_REC.G_interface_purge_flag ||
				',CE_AUTO_BANK_REC.G_interface_archive_flag  = '|| 	CE_AUTO_BANK_REC.G_interface_archive_flag );
    END IF;
    IF (CE_AUTO_BANK_REC.G_org_id is null and
	CE_AUTO_BANK_REC.G_legal_entity_id is null and
	CE_AUTO_BANK_REC.G_functional_currency is null ) THEN
      SELECT  g.currency_code,
	   NVL(s.interface_purge_flag,'N'),
	   NVL(s.interface_archive_flag,'N')
      INTO    CE_AUTO_BANK_REC.G_functional_currency,
		CE_AUTO_BANK_REC.G_interface_purge_flag ,
		CE_AUTO_BANK_REC.G_interface_archive_flag
      FROM    CE_SYSTEM_PARAMETERS_ALL s,
	      GL_SETS_OF_BOOKS g,
	      ce_bank_accts_gt_v ba --ce_bank_accounts_v ba
      WHERE ba.bank_account_id = CE_AUTO_BANK_IMPORT.G_bank_account_id
      and ba.ACCOUNT_OWNER_ORG_ID = s.legal_entity_id
      and s.set_of_books_id = g.set_of_books_id;

    END IF;
*/
    IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('CE_AUTO_BANK_REC.G_functional_currency = '|| CE_AUTO_BANK_REC.G_functional_currency ||
				',CE_AUTO_BANK_REC.G_interface_purge_flag = ' ||CE_AUTO_BANK_REC.G_interface_purge_flag ||
				',CE_AUTO_BANK_REC.G_interface_archive_flag  = '|| 	CE_AUTO_BANK_REC.G_interface_archive_flag );
    END IF;

    fixed_rate_yn := gl_currency_api.is_fixed_rate(
				CE_AUTO_BANK_REC.G_functional_currency,
				nvl(csli_currency_code,aba_bank_currency),
				nvl(csli_exchange_rate_date,csli_trx_date));
  EXCEPTION
    WHEN OTHERS THEN cep_standard.debug('cannot get relationship for the give curr');
	fixed_rate_yn := 'N';
  END;

  IF (fixed_rate_yn = 'N') AND (r_exchange_rate_type = 'EMU FIXED') THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('line_validation: ' || 'emu fixed is not allowed for this curr type');
    END IF;
    error_found := line_error(csli_line_number, 'CE_EMU_FIXED_NOT_ALLOWED');
  END IF;

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_AUTO_BANK_IMPORT.line_validation');
  END IF;
  RETURN error_found;

EXCEPTION
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION:  CE_AUTO_BANK_IMPORT.line_validation');
    END IF;
    RAISE;
    RETURN FALSE;
END line_validation;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	import_process							|
|									|
|  CALLS								|
|	statement_import						|
|									|
|  CALLED BY								|
|	CE_AUTO_BANK_REC.statement					|
 --------------------------------------------------------------------- */
PROCEDURE import_process IS
  aba_bank_account_id		CE_BANK_ACCOUNTS.bank_account_id%TYPE;
  aba_bank_currency		CE_BANK_ACCOUNTS.currency_code%TYPE;
  aba_bank_account_name		CE_BANK_ACCOUNTS.bank_account_name%TYPE;
  aba_bank_check_digits		CE_BANK_ACCOUNTS.check_digits%TYPE;
  csli_line_number		CE_STATEMENT_LINES_INTERFACE.line_number%TYPE;
  csli_amount			CE_STATEMENT_LINES_INTERFACE.amount%TYPE;
  csli_trx_code			CE_STATEMENT_LINES_INTERFACE.trx_code%TYPE;
  csli_user_exchange_rate_type	CE_STATEMENT_LINES_INTERFACE.user_exchange_rate_type%TYPE;
  csli_currency_code		CE_STATEMENT_LINES_INTERFACE.currency_code%TYPE;
  csli_exchange_rate_date	CE_STATEMENT_LINES_INTERFACE.exchange_rate_date%TYPE;
  csli_trx_date			CE_STATEMENT_LINES_INTERFACE.trx_date%TYPE;
  csli_dr_sum			CE_STATEMENT_LINES_INTERFACE.amount%TYPE;
  csli_cr_sum			CE_STATEMENT_LINES_INTERFACE.amount%TYPE;
  csli_dr_count			CE_STATEMENT_LINES_INTERFACE.amount%TYPE;
  csli_cr_count			CE_STATEMENT_LINES_INTERFACE.amount%TYPE;
  r_statement_number		CE_STATEMENT_HEADERS.statement_number%TYPE;
  r_user_conversion_type	GL_DAILY_CONVERSION_TYPES.user_conversion_type%TYPE;
  r_exchange_rate_type   	GL_DAILY_CONVERSION_TYPES.conversion_type%TYPE;
  r_currency_code		FND_CURRENCIES.currency_code%TYPE;
  r_trx_code_id			CE_TRANSACTION_CODES.transaction_code_id%TYPE;
  r_start_date			CE_TRANSACTION_CODES.start_date%TYPE;
  r_end_date			CE_TRANSACTION_CODES.end_date%TYPE;
  line_error_found           	BOOLEAN;
  l_error_found           	BOOLEAN;
  header_error_found           	BOOLEAN;
  lock_error_found           	BOOLEAN;
  control_error_found         	BOOLEAN;
  cshi_rowid			VARCHAR2(100);
  csli_rowid			VARCHAR2(100);
 l_errbuf			varchar2(100);
 l_retcode			number;
 x_account_result		varchar2(100);

BEGIN

--FND_FILE.put_line(FND_FILE.LOG, 'ceabrimb');

 IF l_DEBUG in ('Y', 'C') THEN
  cep_standard.debug('>>CE_AUTO_BANK_IMPORT.import_process ');
 END IF;

 -- populate ce_security_profiles_tmp table with ce_security_procfiles_v
 CEP_STANDARD.init_security;

 OPEN branch_cursor( CE_AUTO_BANK_REC.G_bank_branch_id,
		     CE_AUTO_BANK_REC.G_bank_account_id );
 LOOP
  FETCH branch_cursor INTO CE_AUTO_BANK_IMPORT.G_bank_account_id,
				CE_AUTO_BANK_IMPORT.BA_OWNER_LE_ID,
				CE_AUTO_BANK_IMPORT.G_xtr_use_allowed_flag,
				CE_AUTO_BANK_IMPORT.G_pay_use_allowed_flag;
  aba_bank_account_id := CE_AUTO_BANK_IMPORT.G_bank_account_id;

  -- 1/20/05 Did not enter organization (le_id and org_id missing)
  -- BUG 4914608
 /* IF (CE_AUTO_BANK_REC.G_legal_entity_id is null and CE_AUTO_BANK_REC.G_org_id is null) THEN
    select ACCOUNT_OWNER_ORG_ID
    into X_le_id
    from ce_BANK_ACCOUNTS
    where BANK_ACCOUNT_ID = aba_bank_account_id; */
  --IF (CE_AUTO_BANK_REC.G_legal_entity_id is null and CE_AUTO_BANK_REC.G_org_id is null) THEN
  IF (CE_AUTO_BANK_REC.G_legal_entity_id is null) and
	(CE_AUTO_BANK_IMPORT.BA_OWNER_LE_ID is not null) THEN

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
				CE_AUTO_BANK_IMPORT.BA_OWNER_LE_ID
		);
  END IF;

  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('aba_bank_account_id =' ||aba_bank_account_id);
  END IF;

  EXIT WHEN branch_cursor%NOTFOUND OR branch_cursor%NOTFOUND IS NULL;

  OPEN bank_cursor(CE_AUTO_BANK_REC.G_statement_number_from,
		     CE_AUTO_BANK_REC.G_statement_number_to,
		     CE_AUTO_BANK_REC.G_statement_date_from,
		     CE_AUTO_BANK_REC.G_statement_date_to,
		     CE_AUTO_BANK_IMPORT.G_bank_account_id);
  LOOP
    FETCH bank_cursor INTO CE_AUTO_BANK_IMPORT.G_cshi_rowid,
			     CE_AUTO_BANK_IMPORT.G_cshi_statement_number,
			     CE_AUTO_BANK_IMPORT.G_cshi_bank_account_num,
			     CE_AUTO_BANK_IMPORT.G_cshi_check_digits,
			     CE_AUTO_BANK_IMPORT.G_cshi_control_begin_balance,
			     CE_AUTO_BANK_IMPORT.G_cshi_control_end_balance,
			     CE_AUTO_BANK_IMPORT.G_cshi_cashflow_balance,
			     CE_AUTO_BANK_IMPORT.G_cshi_int_calc_balance,
				 CE_AUTO_BANK_IMPORT.G_cshi_close_ledger_mtd,
				 CE_AUTO_BANK_IMPORT.G_cshi_close_ledger_ytd,
				 CE_AUTO_BANK_IMPORT.G_cshi_close_available_mtd,
				 CE_AUTO_BANK_IMPORT.G_cshi_close_available_ytd,
			     CE_AUTO_BANK_IMPORT.G_cshi_one_day_float,
			     CE_AUTO_BANK_IMPORT.G_cshi_two_day_float,
			     CE_AUTO_BANK_IMPORT.G_cshi_intra_day_flag,
                         CE_AUTO_BANK_IMPORT.G_cshi_subsidiary_flag,
			     CE_AUTO_BANK_IMPORT.G_cshi_control_total_dr,
			     CE_AUTO_BANK_IMPORT.G_cshi_control_total_cr,
			     CE_AUTO_BANK_IMPORT.G_cshi_control_dr_line_count,
			     CE_AUTO_BANK_IMPORT.G_cshi_control_cr_line_count,
			     CE_AUTO_BANK_IMPORT.G_cshi_control_line_count,
			     CE_AUTO_BANK_IMPORT.G_cshi_attribute_category,
			     CE_AUTO_BANK_IMPORT.G_cshi_attribute1,
			     CE_AUTO_BANK_IMPORT.G_cshi_attribute2,
			     CE_AUTO_BANK_IMPORT.G_cshi_attribute3,
			     CE_AUTO_BANK_IMPORT.G_cshi_attribute4,
			     CE_AUTO_BANK_IMPORT.G_cshi_attribute5,
			     CE_AUTO_BANK_IMPORT.G_cshi_attribute6,
			     CE_AUTO_BANK_IMPORT.G_cshi_attribute7,
			     CE_AUTO_BANK_IMPORT.G_cshi_attribute8,
			     CE_AUTO_BANK_IMPORT.G_cshi_attribute9,
			     CE_AUTO_BANK_IMPORT.G_cshi_attribute10,
			     CE_AUTO_BANK_IMPORT.G_cshi_attribute11,
			     CE_AUTO_BANK_IMPORT.G_cshi_attribute12,
			     CE_AUTO_BANK_IMPORT.G_cshi_attribute13,
			     CE_AUTO_BANK_IMPORT.G_cshi_attribute14,
			     CE_AUTO_BANK_IMPORT.G_cshi_attribute15,
			     CE_AUTO_BANK_IMPORT.G_cshi_statement_date,
			     CE_AUTO_BANK_IMPORT.G_cshi_bank_branch_name,
			     CE_AUTO_BANK_IMPORT.G_cshi_bank_name,
			     CE_AUTO_BANK_IMPORT.G_cshi_bank_branch_name,
			     CE_AUTO_BANK_IMPORT.G_cshi_currency_code,
 			     --CE_AUTO_BANK_IMPORT.G_cshi_org_id,
			     r_statement_number,
			     aba_bank_account_name,
			     aba_bank_currency,
			     aba_bank_check_digits;
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('CE_AUTO_BANK_IMPORT.G_cshi_statement_number ='||CE_AUTO_BANK_IMPORT.G_cshi_statement_number);
  END IF;


    EXIT WHEN bank_cursor%NOTFOUND OR bank_cursor%NOTFOUND IS NULL;
    --
    -- Delete all the line/header import errors
    --
    line_error_found := FALSE;
    l_error_found := FALSE;
    header_error_found := FALSE;
    lock_error_found := FALSE;
    control_error_found := FALSE;
    CE_HEADER_INTERFACE_ERRORS_PKG.delete_row(
		CE_AUTO_BANK_IMPORT.G_cshi_statement_number,
		CE_AUTO_BANK_IMPORT.G_cshi_bank_account_num );
    CE_LINE_INTERFACE_ERRORS_PKG.delete_row(
		CE_AUTO_BANK_IMPORT.G_cshi_statement_number,
		CE_AUTO_BANK_IMPORT.G_cshi_bank_account_num, NULL);
    IF (lock_statement) THEN
      IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('aba_bank_account_id =' ||aba_bank_account_id);
      END IF;

      header_error_found := header_validation(r_statement_number,
					      aba_bank_currency,
					      aba_bank_check_digits,
					      aba_bank_account_id);
      CE_AUTO_BANK_IMPORT.G_dr_sum      := 0;
      CE_AUTO_BANK_IMPORT.G_cr_sum      := 0;
      CE_AUTO_BANK_IMPORT.G_dr_count    := 0;
      CE_AUTO_BANK_IMPORT.G_cr_count    := 0;
      CE_AUTO_BANK_IMPORT.G_total_count := 0;
      OPEN lines_cursor(CE_AUTO_BANK_IMPORT.G_cshi_statement_number, CE_AUTO_BANK_IMPORT.G_cshi_bank_account_num);
      LOOP
	FETCH lines_cursor INTO 	csli_rowid,
					csli_line_number,
					csli_amount,
 					csli_trx_code,
					csli_user_exchange_rate_type,
					csli_currency_code,
					csli_exchange_rate_date,
					csli_trx_date,
					csli_dr_sum,
					csli_dr_count,
					csli_cr_sum,
					csli_cr_count,
					r_trx_code_id,
					CE_AUTO_BANK_IMPORT.G_trx_recon_seq_id , -- Bug 8965556
					r_start_date,
					r_end_date,
					r_exchange_rate_type,
					r_user_conversion_type,
					r_currency_code;
	EXIT WHEN lines_cursor%NOTFOUND OR lines_cursor%NOTFOUND IS NULL;
	cep_standard.debug('>>CE_AUTO_BANK_IMPORT.fetch line: ' || csli_line_number);
	CE_AUTO_BANK_IMPORT.G_dr_sum 	   := CE_AUTO_BANK_IMPORT.G_dr_sum 	 + csli_dr_sum;
	CE_AUTO_BANK_IMPORT.G_cr_sum 	   := CE_AUTO_BANK_IMPORT.G_cr_sum 	 + csli_cr_sum;
	CE_AUTO_BANK_IMPORT.G_dr_count    := CE_AUTO_BANK_IMPORT.G_dr_count 	 + csli_dr_count;
	CE_AUTO_BANK_IMPORT.G_cr_count    := CE_AUTO_BANK_IMPORT.G_cr_count 	 + csli_cr_count;
	CE_AUTO_BANK_IMPORT.G_total_count := CE_AUTO_BANK_IMPORT.G_total_count + 1;
	IF (lock_statement_line(csli_rowid)) THEN
	  l_error_found := line_validation(	csli_amount,
						csli_user_exchange_rate_type,
						csli_currency_code,
						csli_exchange_rate_date,
						csli_trx_date,
						csli_line_number,
						csli_trx_code,
						aba_bank_currency,
						r_trx_code_id,
						r_start_date,
						r_end_date,
						r_exchange_rate_type,
						r_user_conversion_type,
						r_currency_code);
	  IF (l_error_found) THEN
	    line_error_found := TRUE;
	  END IF;
	ELSE
	  line_error_found := CE_AUTO_BANK_IMPORT.line_error(csli_line_number, 'CE_STATEMENT_LINT_LOCK');
	END IF;
      END LOOP; -- lines_cursor
      close lines_cursor;
      control_error_found := validate_control_totals;
    ELSE -- Statement header is locked
      lock_error_found := CE_AUTO_BANK_IMPORT.header_error('CE_STATEMENT_HINT_LOCK');
    END IF; -- Statement header lock
    IF (header_error_found OR line_error_found OR lock_error_found) THEN
      IF (lock_error_found) THEN
	NULL;
      ELSE
	update_header_status('E');
      END IF;
    ELSE

      -- bug 3676745 MO/BA uptake
      -- if the bank account is defined as a treasury use bank account, the bank balances
      -- can be uploaded to treasury and if it is a shared account (bug 4932152)

      xtr_shared_account(x_account_result);

      IF ((x_account_result = 'XTR1_SHARED' AND nvl(G_cshi_intra_day_flag,'N') <> 'Y') or
          (CE_AUTO_BANK_IMPORT.G_xtr_use_allowed_flag = 'Y' AND nvl(G_cshi_intra_day_flag,'N') <> 'Y')) THEN
	IF (transfer_bank_balances) THEN
          IF (transfer_header(aba_bank_account_id,aba_bank_account_name)) THEN
	    transfer_lines;
	    IF (CE_AUTO_BANK_REC.G_interface_archive_flag = 'Y')  THEN
	      archive_header;
	      archive_lines;
	    END IF;
	    IF (CE_AUTO_BANK_REC.G_interface_purge_flag = 'Y') THEN
	      purge_data;
	    END IF;
          END IF;
        END IF;
      --ELSIF (x_account_result = 'XTR1_AP' OR nvl(G_cshi_intra_day_flag,'N') = 'Y') THEN
      ELSIF (CE_AUTO_BANK_IMPORT.G_xtr_use_allowed_flag = 'N' OR nvl(G_cshi_intra_day_flag,'N') = 'Y') THEN
       IF (transfer_header(aba_bank_account_id,aba_bank_account_name)) THEN
	  transfer_lines;
	  IF (CE_AUTO_BANK_REC.G_interface_archive_flag = 'Y')  THEN
	    archive_header;
	    archive_lines;
	  END IF;
	  IF (CE_AUTO_BANK_REC.G_interface_purge_flag = 'Y') THEN
	    purge_data;
	  END IF;
        END IF;
      END IF; -- xtr_shared_account

    END IF; -- error_found

    -- bug 2732755
    CE_AUTO_BANK_IMPORT.G_cshi_rowid := null;
    CE_AUTO_BANK_IMPORT.G_cshi_statement_number := null;
    CE_AUTO_BANK_IMPORT.G_cshi_bank_account_num := null;
    CE_AUTO_BANK_IMPORT.G_cshi_check_digits := null;
    CE_AUTO_BANK_IMPORT.G_cshi_control_begin_balance := null;
    CE_AUTO_BANK_IMPORT.G_cshi_control_end_balance := null;
    CE_AUTO_BANK_IMPORT.G_cshi_cashflow_balance := null;
    CE_AUTO_BANK_IMPORT.G_cshi_int_calc_balance := null;
    CE_AUTO_BANK_IMPORT.G_cshi_close_ledger_mtd := null;
    CE_AUTO_BANK_IMPORT.G_cshi_close_ledger_ytd := null;
    CE_AUTO_BANK_IMPORT.G_cshi_close_available_mtd := null;
    CE_AUTO_BANK_IMPORT.G_cshi_close_available_ytd := null;
    CE_AUTO_BANK_IMPORT.G_cshi_one_day_float := null;
    CE_AUTO_BANK_IMPORT.G_cshi_two_day_float := null;
    CE_AUTO_BANK_IMPORT.G_cshi_intra_day_flag := null;
    CE_AUTO_BANK_IMPORT.G_cshi_subsidiary_flag := null;
    CE_AUTO_BANK_IMPORT.G_cshi_control_total_dr := null;
    CE_AUTO_BANK_IMPORT.G_cshi_control_total_cr := null;
    CE_AUTO_BANK_IMPORT.G_cshi_control_dr_line_count := null;
    CE_AUTO_BANK_IMPORT.G_cshi_control_cr_line_count := null;
    CE_AUTO_BANK_IMPORT.G_cshi_control_line_count := null;
    CE_AUTO_BANK_IMPORT.G_cshi_attribute_category := null;
    CE_AUTO_BANK_IMPORT.G_cshi_attribute1 := null;
    CE_AUTO_BANK_IMPORT.G_cshi_attribute2 := null;
    CE_AUTO_BANK_IMPORT.G_cshi_attribute3 := null;
    CE_AUTO_BANK_IMPORT.G_cshi_attribute4 := null;
    CE_AUTO_BANK_IMPORT.G_cshi_attribute5 := null;
    CE_AUTO_BANK_IMPORT.G_cshi_attribute6 := null;
    CE_AUTO_BANK_IMPORT.G_cshi_attribute7 := null;
    CE_AUTO_BANK_IMPORT.G_cshi_attribute8 := null;
    CE_AUTO_BANK_IMPORT.G_cshi_attribute9 := null;
    CE_AUTO_BANK_IMPORT.G_cshi_attribute10 := null;
    CE_AUTO_BANK_IMPORT.G_cshi_attribute11 := null;
    CE_AUTO_BANK_IMPORT.G_cshi_attribute12 := null;
    CE_AUTO_BANK_IMPORT.G_cshi_attribute13 := null;
    CE_AUTO_BANK_IMPORT.G_cshi_attribute14 := null;
    CE_AUTO_BANK_IMPORT.G_cshi_attribute15 := null;
    CE_AUTO_BANK_IMPORT.G_cshi_statement_date := null;
    CE_AUTO_BANK_IMPORT.G_cshi_bank_branch_name := null;
    CE_AUTO_BANK_IMPORT.G_cshi_bank_name := null;
    CE_AUTO_BANK_IMPORT.G_cshi_bank_branch_name := null;
    CE_AUTO_BANK_IMPORT.G_cshi_currency_code := null;
	CE_AUTO_BANK_IMPORT.G_trx_recon_seq_id := NULL; -- Bug 8965556
    --CE_AUTO_BANK_IMPORT.G_cshi_org_id := null;
    r_statement_number := null;
    aba_bank_account_name := null;
    aba_bank_currency := null;
    aba_bank_check_digits := null;

  END LOOP; -- bank_cursor
  close bank_cursor;

 END LOOP; -- branch_cursor
 close branch_cursor;

EXCEPTION
  WHEN OTHERS THEN
    IF branch_cursor%ISOPEN THEN
	close branch_cursor;
    END IF;
    IF bank_cursor%ISOPEN THEN
      close bank_cursor;
    END IF;
    IF lines_cursor%ISOPEN THEN
      close lines_cursor;
    END IF;
    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('EXCEPTION:  CE_AUTO_BANK_IMPORT.import_process');
    END IF;
    RAISE;
END import_process;

END CE_AUTO_BANK_IMPORT;

/
