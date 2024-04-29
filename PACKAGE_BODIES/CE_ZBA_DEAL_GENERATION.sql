--------------------------------------------------------
--  DDL for Package Body CE_ZBA_DEAL_GENERATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_ZBA_DEAL_GENERATION" AS
/* $Header: cezdgenb.pls 120.11.12010000.2 2009/05/13 10:26:17 ckansara ship $ */

l_DEBUG varchar2(1) := NVL(FND_PROFILE.value('CE_DEBUG'), 'N');

  --
  -- MAIN CURSORS
  --
  CURSOR r_branch_cursor( p_bank_branch_id              NUMBER,
			  p_bank_account_id             NUMBER) IS
SELECT cba.bank_account_id
	FROM ce_bank_accounts cba
	WHERE cba.bank_branch_id = p_bank_branch_id
	AND cba.bank_account_id = NVL(p_bank_account_id, cba.bank_account_id)
        ORDER BY cba.bank_account_name;


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
		cba.currency_code,
		cba.multi_currency_allowed_flag,
		cba.check_digits,
		csh.rowid,
		NVL(csh.statement_complete_flag,'N'),
                csh.org_id
	FROM	ce_bank_accounts cba,
		ce_statement_headers csh
	WHERE	cba.bank_account_id = NVL(p_bank_account_id,cba.bank_account_id)
	AND	cba.bank_account_id = csh.bank_account_id
	AND	csh.statement_number
		BETWEEN NVL(p_statement_number_from,csh.statement_number)
		AND NVL(p_statement_number_to,csh.statement_number)
	AND	to_char(to_date(csh.statement_date,'YYYY/MM/DD'),'J')
		BETWEEN NVL(to_char(to_date(p_statement_date_from,'YYYY/MM/DD'),'J'),1)
		AND NVL(to_char(to_date(p_statement_date_to,'YYYY/MM/DD'),'J'),3442447)
	AND 	NVL(csh.statement_complete_flag,'N') = 'N';

  CURSOR line_cursor(csh_statement_header_id  NUMBER) IS
	SELECT	sl.rowid,
		sl.statement_line_id,
		cd.receivables_trx_id,
		cd.receipt_method_id,
		cd.create_misc_trx_flag,
		cd.matching_against,
		cd.correction_method,
		rm.name,
		sl.exchange_rate_type,
		sl.exchange_rate_date,
		sl.exchange_rate,
		sl.currency_code,
		sl.trx_type,
		decode(cd.PAYROLL_PAYMENT_FORMAT_ID, null, NVL(cd.reconcile_flag,'X'),
   			decode(cd.reconcile_flag,'PAY', 'PAY_EFT', NVL(cd.reconcile_flag,'X'))),
		'NONE',
		NULL,
		NULL,
		sl.original_amount,
		ppt.payment_type_name
	FROM	pay_payment_types ppt,
		ar_receipt_methods rm,
		ce_transaction_codes cd,
		ce_statement_lines sl
	WHERE	rm.receipt_method_id(+) 	= cd.receipt_method_id
	AND	cd.transaction_code_id(+) 	= sl.trx_code_id
	AND	cd.payroll_payment_format_id = ppt.payment_type_id (+)
	AND	csh_statement_date
		between nvl(cd.start_date, csh_statement_date)
		and     nvl(cd.end_date, csh_statement_date)
	AND	sl.status 			= 'UNRECONCILED'
	AND	sl.statement_header_id 	= csh_statement_header_id
        AND     sl.trx_type in ('SWEEP_IN', 'SWEEP_OUT')
	ORDER BY DECODE(sl.trx_type, 'NSF', 5, 'REJECTED', 5,
		decode(nvl(cd.matching_against,'MISC'), 'MISC', 3, 'MS', 2, 1)),
		decode(nvl(cd.matching_against,'MISC'), 'MISC', 0,
		to_char(sl.trx_date, 'J')) desc;

FUNCTION body_revision RETURN VARCHAR2 IS
BEGIN

  RETURN '$Revision: 120.11.12010000.2 $';

END body_revision;

FUNCTION spec_revision RETURN VARCHAR2 IS
BEGIN

  RETURN G_spec_revision;

END spec_revision;


FUNCTION get_security_account_type(p_account_type VARCHAR2) RETURN VARCHAR2 IS
    v_acct_type		VARCHAR2(25);
  BEGIN
    v_acct_type :=  FND_PROFILE.VALUE_WNPS('CE_BANK_ACCOUNT_SECURITY_ACCESS');
    IF (v_acct_type = 'ALL' AND p_account_type <> 'EXTERNAL') THEN
      v_acct_type := p_account_type;
    END IF;
    RETURN v_acct_type;
  END get_security_account_type;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       xtr_shared_account                                              |
|                                                                       |
|  DESCRIPTION                                                          |
| 	verify the bank account is a shared account or AP-only account  |
|                                                                       |
|  CALLED BY								|
|	zba_generation							|
|								        |
-----------------------------------------------------------------------*/
PROCEDURE  xtr_shared_account(X_ACCOUNT_RESULT OUT NOCOPY VARCHAR2) IS

  X_ERROR_MSG	        VARCHAR2(1000);

BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.xtr_shared_account'|| '----------' ||
	'xtr_shared_account ORG_ID = '|| CE_ZBA_DEAL_GENERATION.csh_org_id|| '----------' ||
	'xtr_shared_account BANK_ACCOUNT_ID = '|| CE_ZBA_DEAL_GENERATION.csh_bank_account_id|| '----------' ||
	'xtr_shared_account CURRENCY_CODE = '|| CE_ZBA_DEAL_GENERATION.cba_bank_currency);
  END IF;

/*  XTR_WRAPPER_API_P.bank_account_verification(
		 P_ORG_ID 		=> CE_ZBA_DEAL_GENERATION.csh_org_id,
                 P_AP_BANK_ACCOUNT_ID   => CE_ZBA_DEAL_GENERATION.csh_bank_account_id,
		 P_CURRENCY_CODE	=> CE_ZBA_DEAL_GENERATION.cba_bank_currency,
           	 P_RESULT 		=> X_ACCOUNT_RESULT,
                 P_ERROR_MSG 		=> X_ERROR_MSG);
*/
  IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('xtr_shared_account x_account_result = ' || x_account_result|| '----------' ||
	'xtr_shared_account x_error_msg = ' || x_error_msg);
  END IF;

  IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_ZBA_DEAL_GENERATION.xtr_shared_account');
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('EXCEPTION: CE_ZBA_DEAL_GENERATION.xtr_shared_account');
  END IF;
  RAISE;
END xtr_shared_account;


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	lock_statement 							|
|									|
|  DESCRIPTION								|
|	Using the rowid, lock the statement regular way			|
|									|
|  CALLED BY								|
|	zba_generation							|
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
  cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.lock_statement');

  SELECT  statement_header_id
  INTO    x_statement_header_id
  FROM    ce_statement_headers
  WHERE   rowid = CE_ZBA_DEAL_GENERATION.csh_rowid
  FOR UPDATE OF statement_header_id NOWAIT;

  cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.Regular statement lock OK');
  lockname := CE_ZBA_DEAL_GENERATION.csh_rowid;
  timeout  := 1;
  lockmode := 6;
  expiration_secs  := 10;
  release_on_commit := FALSE;
  --
  -- dbms_lock of row to deal with other locking
  --
  cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.Allocating unique');
  dbms_lock.allocate_unique (lockname, lockhandle, expiration_secs);
  lock_status := dbms_lock.request( lockhandle, lockmode, timeout,
				    release_on_commit );
  IF (lock_status <> 0) THEN
    lock_status := dbms_lock.release(lockhandle);
    RAISE APP_EXCEPTIONS.record_lock_exception;
  END IF;
  cep_standard.debug('<<CE_ZBA_DEAL_GENERATION.lock_statement');
  RETURN(TRUE);
EXCEPTION
  WHEN APP_EXCEPTIONS.record_lock_exception THEN
    return(FALSE);
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_ZBA_DEAL_GENERATION.lock_statement' );
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
|	zba_generation							|
 --------------------------------------------------------------------- */
FUNCTION lock_statement_line RETURN BOOLEAN IS
BEGIN
  cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.lock_statement_line');
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
  INTO    CE_ZBA_DEAL_GENERATION.csl_statement_line_id,
	  CE_ZBA_DEAL_GENERATION.csl_trx_date,
	  CE_ZBA_DEAL_GENERATION.csl_trx_type,
	  CE_ZBA_DEAL_GENERATION.csl_trx_code_id,
	  CE_ZBA_DEAL_GENERATION.csl_bank_trx_number,
	  CE_ZBA_DEAL_GENERATION.csl_invoice_text,
	  CE_ZBA_DEAL_GENERATION.csl_bank_account_text,
	  CE_ZBA_DEAL_GENERATION.csl_amount,
	  CE_ZBA_DEAL_GENERATION.csl_charges_amount,
	  CE_ZBA_DEAL_GENERATION.csl_currency_code,
	  CE_ZBA_DEAL_GENERATION.csl_line_number,
	  CE_ZBA_DEAL_GENERATION.csl_customer_text,
	  CE_ZBA_DEAL_GENERATION.csl_effective_date,
	  CE_ZBA_DEAL_GENERATION.csl_original_amount
  FROM    ce_statement_lines
  WHERE   rowid = CE_ZBA_DEAL_GENERATION.csl_rowid
  FOR UPDATE OF status NOWAIT;

  cep_standard.debug('<<CE_ZBA_DEAL_GENERATION.lock_statement_line');
  RETURN(TRUE);

EXCEPTION
  WHEN APP_EXCEPTIONS.record_lock_exception THEN
    return(FALSE);
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_ZBA_DEAL_GENERATION.lock_statement_line' );
    RAISE;
    return(FALSE);
END lock_statement_line;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION                                                     |
|       get_min_statement_line_id                                       |
|                                                                       |
|  DESCRIPTION                                                          |
|                                                                       |
|  CALLED BY                                                            |
|       zba_generation							|
|                                                                       |
|  RETURNS                                                              |
|       csl_statement_line_id   Minimum statement line indentifier      |
 --------------------------------------------------------------------- */
FUNCTION get_min_statement_line_id RETURN NUMBER IS
  min_statement_line		NUMBER;
  min_statement_line_num	NUMBER;
BEGIN
  cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.get_min_statement_line_id');
  SELECT min(line_number)
  INTO   min_statement_line_num
  FROM   ce_statement_lines
  WHERE  statement_header_id = CE_ZBA_DEAL_GENERATION.csh_statement_header_id;

  SELECT statement_line_id
  INTO   min_statement_line
  FROM   ce_statement_lines
  WHERE  line_number = min_statement_line_num
  AND	 statement_header_id = CE_ZBA_DEAL_GENERATION.csh_statement_header_id;
	 cep_standard.debug('<<CE_ZBA_DEAL_GENERATION.get_min_statement_line_id');

  RETURN (min_statement_line);
EXCEPTION
  WHEN OTHERS THEN
  cep_standard.debug('EXCEPTION: CE_ZBA_DEAL_GENERATION.get_min_statement_line_id');
  RAISE;
END get_min_statement_line_id;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	set_parameters							|
|									|
|  DESCRIPTION								|
|	Procedure to set parameter values into globals			|
|  CALLED BY								|
|	zba_generation							|
|  REQUIRES								|
|	all parameters of CE_ZBA_DEAL_GENERATION.zba_generation		|
 --------------------------------------------------------------------- */
PROCEDURE set_parameters(p_bank_branch_id		NUMBER,
			 p_bank_account_id            	NUMBER,
			 p_statement_number_from      	VARCHAR2,
			 p_statement_number_to        	VARCHAR2,
			 p_statement_date_from	     	VARCHAR2,
			 p_statement_date_to	     	VARCHAR2,
			 p_display_debug	   	VARCHAR2,
			 p_debug_path			VARCHAR2,
			 p_debug_file			VARCHAR2) IS
BEGIN

  CE_ZBA_DEAL_GENERATION.G_bank_branch_id		:= p_bank_branch_id;
  CE_ZBA_DEAL_GENERATION.G_bank_account_id		:= p_bank_account_id;
  CE_ZBA_DEAL_GENERATION.G_statement_number_from 	:= p_statement_number_from;
  CE_ZBA_DEAL_GENERATION.G_statement_number_to 		:= p_statement_number_to;
  CE_ZBA_DEAL_GENERATION.G_statement_date_from		:= to_date(p_statement_date_from,'YYYY/MM/DD HH24:MI:SS');
  CE_ZBA_DEAL_GENERATION.G_statement_date_to		:= to_date(p_statement_date_to,'YYYY/MM/DD HH24:MI:SS');
  CE_ZBA_DEAL_GENERATION.G_display_debug		:= p_display_debug;
  CE_ZBA_DEAL_GENERATION.G_debug_path                 	:= p_debug_path;
  CE_ZBA_DEAL_GENERATION.G_debug_file			:= p_debug_file;


  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_ZBA_DEAL_GENERATION.set_parameters');
  END IF;
END set_parameters;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION                                                     |
|       break_bank_link                                                 |
|                                                                       |
|  DESCRIPTION                                                          |
|                                                                       |
|  CALLED BY                                                            |
|       								|
|                                                                       |
|  RETURNS                                                              |
 --------------------------------------------------------------------- */
 FUNCTION break_bank_link(p_ap_bank_account_id NUMBER) RETURN BOOLEAN IS

  code_row_count		NUMBER;
  line_row_count		NUMBER;
  p_statement_header_id         NUMBER;
  i                             NUMBER;

  CURSOR header_cursor IS
         SELECT statement_header_id
         FROM ce_statement_headers
         WHERE bank_account_id = p_ap_bank_account_id;
BEGIN

   SELECT count(1)
   INTO   code_row_count
   FROM   ce_transaction_codes
   WHERE  bank_account_id = p_ap_bank_account_id
   AND    trx_type in ('SWEEP_IN', 'SWEEP_OUT');

  IF (code_row_count > 0) THEN
    RETURN (FALSE);
  ELSE
     OPEN header_cursor;
     i := 0;
     LOOP
     FETCH header_cursor INTO p_statement_header_id;
     IF (header_cursor%ROWCOUNT = i) THEN
      IF i = 0 THEN
       RETURN TRUE;
      END IF;
      EXIT;
     ELSE
       i := i + 1;
     END IF;
     SELECT count(1)
     INTO   line_row_count
     FROM   ce_statement_lines
     WHERE  statement_header_id = p_statement_header_id
     AND    trx_type in ('SWEEP_IN', 'SWEEP_OUT');

     cep_standard.debug('line_row_count = '||line_row_count);

     IF (line_row_count > 0) THEN
       G_sweep_flag := TRUE;
       RETURN (FALSE);
     ELSE
       RETURN (TRUE);
     END IF;
      EXIT WHEN G_sweep_flag = TRUE;
     END LOOP;
     CLOSE header_cursor;
 END IF;
END break_bank_link;


  /*========================================================================+
   | PRIVATE PROCEDURE                                                      |
   |   zba_generation                                                       |
   |                                                                        |
   | DESCRIPTION                                                            |
   |   Main procedure of sweep transactions generation 			    |
   |                                                                        |
   | ARGUMENTS                                                              |
   |   IN:                                                                  |
   |     p_bank_branch_id        Bank_branch_id				    |
   |     p_bank_account_id       Bank_account_id			    |
   |     p_statement_number_from Statement number from                      |
   |     p_statement_number_to   Statement number to                        |
   |     p_statement_date_from   Statement Date from                        |
   |     p_statement_date_to     Statement Date to                          |
   |                                                                        |
   |     p_display_debug         Debug message flag (Y/N)                   |
   |     p_debug_path            Debug path name if specified               |
   |     p_debug_file            Debug file name if specified               |
   |                                                                        |
   | CALLS                                                                  |
   +========================================================================*/
PROCEDURE zba_generation (errbuf        OUT NOCOPY     VARCHAR2,
                      	  retcode       OUT NOCOPY     NUMBER,
                          p_bank_branch_id 	     NUMBER,
			  p_bank_account_id          NUMBER,
			  p_statement_number_from    VARCHAR2,
			  p_statement_number_to      VARCHAR2,
			  p_statement_date_from      VARCHAR2,
			  p_statement_date_to        VARCHAR2,
                          p_display_debug	     VARCHAR2,
			  p_debug_path		     VARCHAR2,
			  p_debug_file		     VARCHAR2) IS

   error_statement_line_id	CE_STATEMENT_LINES.statement_line_id%TYPE;
   lockhandle			VARCHAR2(128);
   lock_status			NUMBER;
   statement_line_count		NUMBER;
   i				NUMBER;
   j				NUMBER;
   rec_status                   NUMBER;
   row_count                    NUMBER;
   x_account_result		VARCHAR2(50);

   x_offset_bank_account_id	NUMBER;
   x_cashpool_id		NUMBER;

   req_id		NUMBER;
   request_id		NUMBER;
   reqid		VARCHAR2(30);
   number_of_copies	number;
   printer		VARCHAR2(30);
   print_style		VARCHAR2(30);
   save_output_flag	VARCHAR2(30);
   save_output_bool	BOOLEAN;
   cp_match_bool	BOOLEAN;

   l_success_flag       VARCHAR2(1);
   l_deal_type		VARCHAR2(3);
   l_deal_num		NUMBER;
   l_transaction_num    NUMBER;
   l_offset_deal_num    NUMBER;
   l_offset_transaction_num	NUMBER;

   l_count		NUMBER;
   l_msg_count		NUMBER;
   l_error_msg		VARCHAR2(255);
   l_cashflows_created_flag VARCHAR2(1);

   l_bank_acct_text ce_statement_lines.bank_account_text%TYPE; -- Bug # 7829965
   l_dst_bank_acct_id ce_statement_headers.bank_account_id%TYPE :=0; -- Bug # 7829965

BEGIN

  IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.enable_debug(p_debug_path, p_debug_file);

  	cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.zba_generation '||sysdate);
  	cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.p_bank_branch_id     :  '|| p_bank_branch_id);
  	cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.p_bank_account_id    :  '|| p_bank_account_id);
  	cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.p_statement_number_from:  '|| p_statement_number_from);
  	cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.p_statement_number_to:  '|| p_statement_number_to);
  	cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.p_statement_date_from:  '|| p_statement_date_from);
  	cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.p_statement_date_to:    '|| p_statement_date_to);
  	cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.p_display_debug:  '|| p_display_debug);
  	cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.p_debug_path:  '|| p_debug_path);
  	cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.p_debug_file:  '|| p_debug_file);


  END IF;
  cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.zba_generation');

 -- populate ce_security_profiles_gt table with ce_security_procfiles_v
 CEP_STANDARD.init_security;

  set_parameters(p_bank_branch_id,
	         p_bank_account_id,
	         p_statement_number_from,
		 p_statement_number_to,
		 p_statement_date_from,
		 p_statement_date_to,
		 p_display_debug,
		 p_debug_path,
		 p_debug_file);

  cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.Opening r_branch_cursor');
  OPEN r_branch_cursor( CE_ZBA_DEAL_GENERATION.G_bank_branch_id,
			CE_ZBA_DEAL_GENERATION.G_bank_account_id);
  j := 0;
  LOOP
    cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.Fetching r_branch_cursor');
    FETCH r_branch_cursor INTO CE_ZBA_DEAL_GENERATION.csh_bank_account_id;

    cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.csh_bank_account_id = '||CE_ZBA_DEAL_GENERATION.csh_bank_account_id);

    IF (r_branch_cursor%ROWCOUNT = j) THEN
      EXIT;
    ELSE
      j := r_branch_cursor%ROWCOUNT;
    END IF;

    cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.Opening r_bank_cursor');
    OPEN r_bank_cursor (CE_ZBA_DEAL_GENERATION.G_statement_number_from,
		        CE_ZBA_DEAL_GENERATION.G_statement_number_to,
		        CE_ZBA_DEAL_GENERATION.G_statement_date_from,
		        CE_ZBA_DEAL_GENERATION.G_statement_date_to,
		        CE_ZBA_DEAL_GENERATION.csh_bank_account_id);
    i := 0;
      LOOP
	cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.Fetching r_bank_cursor');
	FETCH r_bank_cursor INTO CE_ZBA_DEAL_GENERATION.csh_statement_header_id,
			     CE_ZBA_DEAL_GENERATION.csh_statement_number,
			     CE_ZBA_DEAL_GENERATION.csh_statement_date,
			     CE_ZBA_DEAL_GENERATION.csh_check_digits,
			     CE_ZBA_DEAL_GENERATION.csh_statement_gl_date,
			     CE_ZBA_DEAL_GENERATION.cba_bank_currency,
			     CE_ZBA_DEAL_GENERATION.cba_multi_currency_flag,
			     CE_ZBA_DEAL_GENERATION.cba_check_digits,
			     CE_ZBA_DEAL_GENERATION.csh_rowid,
			     CE_ZBA_DEAL_GENERATION.csh_statement_complete_flag,
                             CE_ZBA_DEAL_GENERATION.csh_org_id;
	cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.After fetch header');
	cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.statement_header_id:' ||
			   CE_ZBA_DEAL_GENERATION.csh_statement_header_id );

	if (r_bank_cursor%ROWCOUNT = i) then
	  EXIT;
	else
	  i := r_bank_cursor%ROWCOUNT;
	end if;
	-- EXIT WHEN r_bank_cursor%NOTFOUND OR r_bank_cursor%NOTFOUND IS NULL;

        -- Clean up error table
        CE_ZBA_DEAL_INF_PKG.delete_row(
                  CE_ZBA_DEAL_GENERATION.csh_statement_header_id,
                  to_number(NULL));

        --Validate existing of unreconciled sweep lines
        select count(1)
        into row_count
        from ce_statement_lines
        where statement_header_id = CE_ZBA_DEAL_GENERATION.csh_statement_header_id
        and trx_type in ('SWEEP_IN', 'SWEEP_OUT');

        cep_standard.debug('row_count = '||row_count);

        if (row_count = 0 ) then
          CE_ZBA_DEAL_INF_PKG.insert_row(
                  CE_ZBA_DEAL_GENERATION.csh_statement_header_id,
                  to_number(NULL), 'CE_NO_SWEEP_STMT_LINE');
          EXIT;
        cep_standard.debug('>>validate existing of unreconciled sweep lines');
        else --Validate the bank account is an authorized treasury account
	  if fnd_profile.value('CE_BANK_ACCOUNT_TRANSFERS') = 'XTR' then
	    select count(1) into l_count
	    from ce_bank_accounts ba, ce_bank_acct_uses_all bau
	    where ba.bank_account_id = CE_ZBA_DEAL_GENERATION.csh_bank_account_id
	    and bau.bank_account_id = ba.bank_account_id
	    and ba.xtr_use_allowed_flag = 'Y'
	    and bau.authorized_flag = 'Y';

	    if l_count = 0 then
             CE_ZBA_DEAL_INF_PKG.insert_row (
                   CE_ZBA_DEAL_GENERATION.csh_statement_header_id,
                   to_number(NULL), 'CE_XTR_INVALID_ACCT');
             EXIT;
            end if;
          end if;
        end if;

        cep_standard.debug('>>validate shared bank account is setup correctly');

	IF (nvl(LTRIM(nvl(CE_ZBA_DEAL_GENERATION.csh_check_digits, 'NO DIGIT'),
		'0'), '0') = nvl(LTRIM(nvl(CE_ZBA_DEAL_GENERATION.cba_check_digits,
		'NO DIGIT'), '0'), '0')) THEN

        cep_standard.debug('csh_check_digits = '||csh_check_digits);
        cep_standard.debug('cba_check_digits = '||cba_check_digits);

	  --
	  -- Lock the statement
	  --
	  IF (lock_statement(lockhandle)) THEN
	    IF (csh_statement_complete_flag = 'N') THEN

	      statement_line_count := 0;

	      --
	      -- Read in all the lines on the statement for the selected bank
	      -- account.
	      --
    		cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.Opening line_cursor');
	      OPEN line_cursor (CE_ZBA_DEAL_GENERATION.csh_statement_header_id);
	      LOOP
		FETCH line_cursor INTO CE_ZBA_DEAL_GENERATION.csl_rowid,
			 CE_ZBA_DEAL_GENERATION.csl_statement_line_id,
			 CE_ZBA_DEAL_GENERATION.csl_receivables_trx_id,
			 CE_ZBA_DEAL_GENERATION.csl_receipt_method_id,
			 CE_ZBA_DEAL_GENERATION.csl_create_misc_trx_flag,
			 CE_ZBA_DEAL_GENERATION.csl_matching_against,
			 CE_ZBA_DEAL_GENERATION.csl_correction_method,
			 CE_ZBA_DEAL_GENERATION.csl_receipt_method_name,
			 CE_ZBA_DEAL_GENERATION.csl_exchange_rate_type,
			 CE_ZBA_DEAL_GENERATION.csl_exchange_rate_date,
			 CE_ZBA_DEAL_GENERATION.csl_exchange_rate,
			 CE_ZBA_DEAL_GENERATION.csl_currency_code,
			 CE_ZBA_DEAL_GENERATION.csl_line_trx_type,
			 CE_ZBA_DEAL_GENERATION.csl_reconcile_flag,
			 CE_ZBA_DEAL_GENERATION.csl_match_found,
			 CE_ZBA_DEAL_GENERATION.csl_match_type,
			 CE_ZBA_DEAL_GENERATION.csl_clearing_trx_type,
			 CE_ZBA_DEAL_GENERATION.csl_original_amount,
			 CE_ZBA_DEAL_GENERATION.csl_payroll_payment_format;
		EXIT WHEN line_cursor%NOTFOUND OR line_cursor%NOTFOUND IS NULL;
		cep_standard.debug('>>CE_ZBA_DEAL_GENERATION.csl_statement_line_id = '|| CE_ZBA_DEAL_GENERATION.csl_statement_line_id);


		select count(*)
		into   rec_status
		--from   ce_statement_reconciliations

		from   ce_statement_reconcils_all
		where  statement_line_id =
		       CE_ZBA_DEAL_GENERATION.csl_statement_line_id
		and    nvl(status_flag, 'U') = 'M'
		and    nvl(current_record_flag, 'Y') = 'Y';

		if (rec_status = 0) then

		  statement_line_count := statement_line_count + 1;
		  --
		  -- Clear ce_zba_deal_inf table
		  --
		  CE_ZBA_DEAL_INF_PKG.delete_row(
			CE_ZBA_DEAL_GENERATION.csh_statement_header_id,
			CE_ZBA_DEAL_GENERATION.csl_statement_line_id);
		  IF (lock_statement_line) THEN

                     --Validate zero amount line
                     IF (CE_ZBA_DEAL_GENERATION.csl_amount = 0)THEN
                       CE_ZBA_DEAL_INF_PKG.insert_row (
                         CE_ZBA_DEAL_GENERATION.csh_statement_header_id,
                           CE_ZBA_DEAL_GENERATION.csl_statement_line_id, 'CE_ZBA_ZERO_AMOUNT');
                     END IF;
                     cep_standard.debug('csl_amount = '||csl_amount);

                     --Validate different currencies between statement header and line
                     IF (CE_ZBA_DEAL_GENERATION.cba_bank_currency <>
                         nvl(CE_ZBA_DEAL_GENERATION.csl_currency_code, CE_ZBA_DEAL_GENERATION.cba_bank_currency)) THEN
                         CE_ZBA_DEAL_INF_PKG.insert_row (
                          CE_ZBA_DEAL_GENERATION.csh_statement_header_id,
                           CE_ZBA_DEAL_GENERATION.csl_statement_line_id, 'CE_ZBA_DIFF_CURRENCY');
                     END IF;
                     cep_standard.debug('csl_currency_code = '||csl_currency_code);
                     cep_standard.debug('cba_bank_currency = '||cba_bank_currency);

					/*  Bug # 7829965 Start */
					BEGIN
                     SELECT bank_account_text
					 INTO l_bank_acct_text
					 FROM ce_statement_lines
					 WHERE statement_line_id = CE_ZBA_DEAL_GENERATION.csl_statement_line_id;

					 SELECT cps. account_id
 		             INTO l_dst_bank_acct_id
		             FROM ce_bank_accounts  cba,ce_cashpools cp,CE_CASHPOOL_SUB_ACCTS cps
		             WHERE cba.bank_account_id = cp.conc_account_id AND cp.cashpool_id = cps.cashpool_id
							AND cps.account_id IN (SELECT bank_account_id FROM ce_bank_accounts WHERE bank_account_num = l_bank_acct_text);
					EXCEPTION
			          WHEN OTHERS THEN
			              NULL; -- The Exception is not handeled here when the agent bank account is not found as it is already handled in the code.
			        END;

					 /*  Bug # 7829965 End */
			 IF(CE_ZBA_DEAL_GENERATION.csh_bank_account_id <>  l_dst_bank_acct_id) THEN  -- Bug # 7829965   -- If Source and Destination Accounts are not the same
		     --
		     -- Deal Generation
                     --
                     cp_match_bool := CE_LEVELING_UTILS.Match_Cashpool(
                   		p_header_bank_account_id	=> CE_ZBA_DEAL_GENERATION.csh_bank_account_id,
                          	p_offset_bank_account_num	=> CE_ZBA_DEAL_GENERATION.csl_bank_account_text,
                          	p_trx_type			=> CE_ZBA_DEAL_GENERATION.csl_trx_type,
                          	p_trx_date			=> CE_ZBA_DEAL_GENERATION.csl_trx_date,
                          	p_offset_bank_account_id	=> x_offset_bank_account_id,
                                p_cashpool_id			=> x_cashpool_id);

                     IF (cp_match_bool) THEN  --  found matching cash pool
                       CE_ZBA_DEAL_GENERATION.p_offset_bank_account_id := x_offset_bank_account_id;
                        CE_ZBA_DEAL_GENERATION.p_cashpool_id := x_cashpool_id;

			-- Bug5122576. The from and to bank accounts will be determined
			-- in the Generate_Fund_Transfer api. From here, the
			-- p_from_bank_account_id will always be the statement line's
			-- bank account and p_to_bank_Account_id will always be the
			-- offset bank account

			CE_ZBA_DEAL_GENERATION.p_from_bank_account_id :=
				CE_ZBA_DEAL_GENERATION.csh_bank_account_id;
                        CE_ZBA_DEAL_GENERATION.p_to_bank_account_id :=
				CE_ZBA_DEAL_GENERATION.p_offset_bank_account_id;


		       CE_LEVELING_UTILS.Generate_Fund_Transfer(
				X_from_bank_account_id		=> CE_ZBA_DEAL_GENERATION.p_from_bank_account_id,
				X_to_bank_account_id		=> CE_ZBA_DEAL_GENERATION.p_to_bank_account_id,
				X_cashpool_id			=> CE_ZBA_DEAL_GENERATION.p_cashpool_id,
				X_amount			=> CE_ZBA_DEAL_GENERATION.csl_amount,
				X_transfer_date			=> CE_ZBA_DEAL_GENERATION.csl_trx_date,
				X_settlement_authorized		=> 'Y',
				X_accept_limit_error		=> 'Y',
				X_request_id			=> null,
 				X_deal_type			=> l_deal_type,
              			X_deal_no			=> l_deal_num,
	      			X_trx_number			=> l_transaction_num,
	      			X_offset_deal_no		=> l_offset_deal_num,
	      			X_offset_trx_number		=> l_offset_transaction_num,
				X_success_flag			=> l_success_flag,
				X_statement_line_id		=> CE_ZBA_DEAL_GENERATION.csl_statement_line_id,
				X_msg_count			=> l_msg_count,
				X_cashflows_created_flag	=> l_cashflows_created_flag,
				X_called_by_flag		=> 'Z');

               IF l_success_flag = 'Y' THEN
						  			  INSERT INTO CE_ZBA_DEAL_MESSAGES(
							      			application_short_name,
						 	      			statement_header_id,
						              			statement_line_id,
						              			creation_date,
						              			created_by,
						              			deal_type,
						              			deal_num,
							      			transaction_num,
										cashpool_id,
										cashflows_created_flag,
							      			offset_deal_num,
							      			offset_transaction_num,
							      			deal_status_flag)
						              		  VALUES (
							      			'CE',
						 	      			CE_ZBA_DEAL_GENERATION.csh_statement_header_id,
						   			        CE_ZBA_DEAL_GENERATION.csl_statement_line_id,
							      			sysdate,
							      			NVL(FND_GLOBAL.user_id,-1),
						              			l_deal_type,
						              			l_deal_num,
							      			l_transaction_num,
										CE_ZBA_DEAL_GENERATION.p_cashpool_id,
										l_cashflows_created_flag,
							      			l_offset_deal_num,
							      			l_offset_transaction_num,
							      			'Y');
						                        ELSE
									  FOR i IN 1..l_msg_count LOOP
									    INSERT INTO CE_ZBA_DEAL_MESSAGES(
							      			application_short_name,
						              			statement_header_id,
						              			statement_line_id,
						              			message_name,
						              			creation_date,
						              			created_by,
						              			deal_status_flag,
										cashpool_id)
						              		    VALUES (
							      			'CE',
						 	      			CE_ZBA_DEAL_GENERATION.csh_statement_header_id,
						   			        CE_ZBA_DEAL_GENERATION.csl_statement_line_id,
						              			FND_MSG_PUB.get(1, FND_API.G_FALSE),
							      			sysdate,
							      			NVL(FND_GLOBAL.user_id,-1),
						              			'N',
										CE_ZBA_DEAL_GENERATION.p_cashpool_id);
									    FND_MSG_PUB.delete_msg(1);
									  END LOOP;
									END IF;
                  ELSE
					       CE_ZBA_DEAL_INF_PKG.insert_row(
					         CE_ZBA_DEAL_GENERATION.csh_statement_header_id,
						 CE_ZBA_DEAL_GENERATION.csl_statement_line_id,
						 'CE_NO_CASHPOOL_MATCH');
				  END IF;
		    /*  Bug # 7829965 Start */
			ELSE
                  CE_ZBA_DEAL_INF_PKG.insert_row(
			            CE_ZBA_DEAL_GENERATION.csh_statement_header_id,
			            CE_ZBA_DEAL_GENERATION.csl_statement_line_id,
			            'CE_BAT_INVALID_BACCNTS');
            END IF; -- if (CE_ZBA_DEAL_GENERATION.csh_bank_account_id <>  l_dst_bank_acct_id) THEN
			/*  Bug # 7829965 End */
		  ELSE -- statement line is locked
		    CE_ZBA_DEAL_INF_PKG.insert_row(
			CE_ZBA_DEAL_GENERATION.csh_statement_header_id,
			CE_ZBA_DEAL_GENERATION.csl_statement_line_id,
			'CE_LINE_LOCKED');
		  END IF;
		  IF (statement_line_count =
		      CE_AUTO_BANK_REC.G_lines_per_commit) THEN
		    COMMIT;
		    statement_line_count := 0;
		  END IF;

		end if;   -- if rec_status = 0

	      END LOOP; -- statement lines
	      CLOSE line_cursor;

	    ELSE
	      error_statement_line_id := get_min_statement_line_id;
	      CE_ZBA_DEAL_INF_PKG.delete_row(
		  CE_ZBA_DEAL_GENERATION.csh_statement_header_id,
		  error_statement_line_id);
	      CE_ZBA_DEAL_INF_PKG.insert_row(
		  CE_ZBA_DEAL_GENERATION.csh_statement_header_id,
		  error_statement_line_id, 'CE_STATEMENT_COMPLETED');
	  END IF; -- statement completed

	ELSE -- statement is locked
	  CE_ZBA_DEAL_INF_PKG.delete_row(
	      CE_ZBA_DEAL_GENERATION.csh_statement_header_id, to_number(NULL));
	      CE_ZBA_DEAL_INF_PKG.insert_row(
		  CE_ZBA_DEAL_GENERATION.csh_statement_header_id,to_number(NULL),
		  'CE_LOCK_STATEMENT_HEADER_ERR');
	END IF;
	lock_status := dbms_lock.release(lockhandle);

      ELSE -- check digits failed
	CE_ZBA_DEAL_INF_PKG.delete_row(
	    CE_ZBA_DEAL_GENERATION.csh_statement_header_id, to_number(NULL));
	CE_ZBA_DEAL_INF_PKG.insert_row(
	    CE_ZBA_DEAL_GENERATION.csh_statement_header_id,to_number(NULL),
	    'CE_CHECK_DIGITS');
      END IF; -- check_digits

    END LOOP; -- statement headers
    CLOSE r_bank_cursor;
  END LOOP;
  CLOSE r_branch_cursor;

  --
  -- Get original request id
  --
  fnd_profile.get('CONC_REQUEST_ID', reqid);
  request_id := to_number(reqid);
  --
  -- Get print options
  --
  IF( FND_CONCURRENT.GET_REQUEST_PRINT_OPTIONS(request_id,
						number_of_copies,
						print_style,
						printer,
						save_output_flag))THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('zba_generation: ' || 'Message: get print options success');
    END IF;
  ELSE
    IF (save_output_flag = 'Y') THEN
      save_output_bool := TRUE;
    ELSE
      save_output_bool := FALSE;
    END IF;

    IF( FND_CONCURRENT.GET_PROGRAM_ATTRIBUTES ('CE',
                                           'CEZBAERR',
                                           printer,
                                           print_style,
                                           save_output_flag)) THEN
      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('zba_generation: ' || 'Message: get print options failed');
      END IF;
    END IF;

  END IF;
    --
    -- Set print options
    --
    IF (NOT FND_REQUEST.set_print_options(printer,
                                           print_style,
                                           number_of_copies,
                                           save_output_bool)) THEN
      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('zba_generation: ' || 'Set print options failed');
      END IF;
    END IF;
    req_id := FND_REQUEST.SUBMIT_REQUEST('CE',
			            'CEZBAERR',
				    NULL,
				    to_char(sysdate,'YYYY/MM/DD'),
			            FALSE,
                                    p_bank_branch_id,
				    p_bank_account_id,
				    p_statement_number_from,
				    p_statement_number_to,
				    p_statement_date_from,
				    p_statement_date_to,
				    p_display_debug,
				    p_display_debug);
  COMMIT;
  IF (req_id = 0) THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('zba_generation: ' || 'ERROR submitting concurrent request');
    END IF;
  ELSE
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('zba_generation: ' || 'EXECUTION REPORT SUBMITTED');
    END IF;
  END IF;

  cep_standard.debug('<<CE_ZBA_DEAL_GENERATION.zba_generation');
  cep_standard.disable_debug(p_display_debug);

EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug(' EXCEPTION: CE_ZBA_DEAL_GENERATION.zba_generation - OTHERS');
    IF r_branch_cursor%ISOPEN THEN
      CLOSE r_branch_cursor;
    END IF;
    IF r_bank_cursor%ISOPEN THEN
      CLOSE r_bank_cursor;
    END IF;
    IF line_cursor%ISOPEN THEN
      CLOSE line_cursor;
    END IF;
    lock_status := dbms_lock.release(lockhandle);
    cep_standard.debug('DEBUG: sqlcode:' || sqlcode );
    cep_standard.debug('DEBUG: sqlerrm:' || sqlerrm);
    RAISE;
END zba_generation;

END CE_ZBA_DEAL_GENERATION;

/
