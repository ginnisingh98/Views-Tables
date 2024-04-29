--------------------------------------------------------
--  DDL for Package Body CE_AUTO_BANK_UNREC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_AUTO_BANK_UNREC" AS
/* $Header: ceaurecb.pls 120.19 2007/05/29 12:57:10 kbabu ship $ */

l_DEBUG varchar2(1) := NVL(FND_PROFILE.value('CE_DEBUG'), 'N');
--l_DEBUG varchar2(1) := 'Y';

FUNCTION body_revision RETURN VARCHAR2 IS
BEGIN

  RETURN '$Revision: 120.19 $';

END body_revision;

FUNCTION spec_revision RETURN VARCHAR2 IS
BEGIN

  RETURN G_spec_revision;

END spec_revision;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       Unreconcile_All                                                 |
|                                                                       |
|  DESCRIPTION                                                          |
|       Unreconcile all the reconciled transactions in given bank       |
|	statement							|
 -----------------------------------------------------------------------*/

PROCEDURE unreconcile_all(errbuf                  OUT NOCOPY 	VARCHAR2,
                          retcode                 OUT NOCOPY 	NUMBER,
			  X_bank_account_id 	  IN	NUMBER,
			  X_statement_number	  IN	VARCHAR2,
			  X_statement_line_id     IN	NUMBER,
			  X_display_debug         IN 	VARCHAR2,
                          X_debug_path            IN 	VARCHAR2,
                          X_debug_file            IN 	VARCHAR2) IS
/* 2738067
  Added statement_header_id to the selected fields in the cursor.*/
  CURSOR C_reconciled IS
    SELECT 	row_id, statement_header_number,
		statement_line_id,
		trx_type,
		clearing_trx_type,
		batch_id,
		trx_id,
		cash_receipt_id,
		trx_date,
		gl_date,
		status,
		cleared_date,
		amount,
		bank_errors,
		bank_charges,
		bank_account_amount,
		bank_currency_code,
		exchange_rate_type,
		exchange_rate_date,
		exchange_rate,
		statement_complete_flag,
		statement_header_id, org_id, legal_entity_id, bank_account_id
    FROM	CE_RECONCILED_TRANSACTIONS_V
    WHERE       bank_account_id		= X_bank_account_id
    AND		statement_header_number = NVL(X_statement_number,
						statement_header_number)
    AND		statement_line_id	= NVL(X_statement_line_id,
					      statement_line_id)
   order by   statement_header_number, statement_line_id ;
/* 2853915
Added the nvl condition for statement_header_number */

  CURSOR C_oifs(P_BANK_ACCOUNT_ID number) IS
  SELECT 	RECON_OI_FLOAT_STATUS
  FROM	CE_BANK_ACCOUNTS
  WHERE BANK_ACCOUNT_ID = NVL(X_bank_account_id, P_BANK_ACCOUNT_ID);

/*  SELECT 	open_interface_float_status
    FROM 	CE_SYSTEM_PARAMETERS_ALL sys
    where exists ( select ACCOUNT_OWNER_ORG_ID
   			     from CE_BANK_ACCOUNTS --ACCTS_GT_V --ce_BANK_ACCOUNTS_v
     			     where bank_account_id = X_bank_account_id
  			     and ACCOUNT_OWNER_ORG_ID = sys.legal_entity_id);*/

  l_cnt				NUMBER	:= 0;
  l_status			VARCHAR2(30);
  l_statement_complete_flag     VARCHAR2(1);
  l_next_statement_complete_flag VARCHAR2(1);
  /*Bug 3847491 Added*/

  cash_receipt_history_id	NUMBER;
  MATCH_CORRECTION_TYPE		VARCHAR2(30);
  l_stmt_stmt_num 		CE_STATEMENT_HEADERS.STATEMENT_NUMBER%TYPE;
  l_trx_stmt_num	 	CE_STATEMENT_HEADERS.STATEMENT_NUMBER%TYPE;
  l_skip_lock_unclear 		VARCHAR2(1) := 'N';
  l_app_id			NUMBER;
  l_set_of_books_id		NUMBER;
  l_count			NUMBER;
  l_status1			VARCHAR2(30);
  l_status2			VARCHAR2(30);
  p_bank_account_id		number;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
	--cep_standard.enable_debug(X_debug_path,X_debug_file);
  	cep_standard.debug('>>CE_UNRECONCILE.unreconcile_all '||sysdate);
  	cep_standard.debug('X_bank_account_id '|| X_bank_account_id||
			   ', X_statement_number '||  X_statement_number||
			   ', X_statement_line_id  '||X_statement_line_id );
  END IF;

  -- initialize multi-org
 -- mo_global.init('CE');

 -- populate ce_security_profiles_tmp table with ce_security_profiles_v
 CEP_STANDARD.init_security;

/* bug 4914608
  OPEN C_oifs;
  FETCH C_oifs INTO l_status;
  CLOSE C_oifs;
*/
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('l_status='||l_status);
  END IF;


  FOR C_rec IN C_reconciled LOOP
   l_skip_lock_unclear :='N'; -- Bug 3427433 added this line.

    IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('--------- new statement line/trx -------------');
      	cep_standard.debug('C_rec.trx_type = ' || C_rec.trx_type ||
				', C_rec.clearing_trx_type = ' || C_rec.clearing_trx_type||
				', C_rec.batch_id = ' || C_rec.batch_id);
      	cep_standard.debug('C_rec.trx_id = ' || C_rec.trx_id||
				', C_rec.cash_receipt_id = ' || C_rec.cash_receipt_id||
				', C_rec.statement_line_id = ' || C_rec.statement_line_id);

      	cep_standard.debug('C_rec.trx_date = ' || C_rec.trx_date||
				', C_rec.gl_date = ' || to_char(C_rec.gl_date,'YYYY/MM/DD')||
				', C_rec.cleared_date=  ' || C_rec.cleared_date);

      	cep_standard.debug('C_rec.status ' || C_rec.status||', C_rec.amount ' || C_rec.amount||
				', C_rec.bank_account_amount ' || C_rec.bank_account_amount);

       	cep_standard.debug('C_rec.row_id = ' || C_rec.row_id||
				', C_rec.statement_complete_flag = ' || C_rec.statement_complete_flag);

        cep_standard.debug('C_rec.org_id = ' || C_rec.org_id ||
				', C_rec.legal_entity_id = '||C_rec.legal_entity_id  );
     	cep_standard.debug('l_stmt_stmt_num=  ' || l_stmt_stmt_num||
				', l_trx_stmt_num = ' || l_trx_stmt_num||
				', l_skip_lock_unclear = ' || l_skip_lock_unclear);

       	cep_standard.debug('C_rec.statement_header_id=' || C_rec.statement_header_id ||
			', C_rec.org_id = '||C_rec.org_id||', C_rec.legal_entity_id='||C_rec.legal_entity_id);
       	cep_standard.debug('C_rec.bank_account_id=' || C_rec.bank_account_id);

   END IF;

   -- BUG 4914608 SYSTEM PARAMETERS changes
   P_BANK_ACCOUNT_ID := NVL(X_BANK_ACCOUNT_ID, C_rec.bank_account_id);

   OPEN C_oifs(P_BANK_ACCOUNT_ID);
   FETCH C_oifs INTO l_status;
   CLOSE C_oifs;

/* 2738067
Read Statement_complete_flag from ce_statement_headers since
the field in the view need not be populated always */
	SELECT 	cesh.statement_complete_flag
	INTO	l_statement_complete_flag
	FROM    ce_statement_headers cesh
	WHERE	cesh.statement_header_id = C_rec.statement_header_id;

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('l_statement_complete_flag='||l_statement_complete_flag);
  END IF;

    IF nvl(l_statement_complete_flag, 'N') <> 'Y' THEN

      IF C_rec.clearing_trx_type in ('PAYMENT','CASH','MISC') THEN -- bug 5999462
        IF C_rec.trx_type = 'PAYMENT' THEN
	  l_app_id := 200;
        ELSE
	  l_app_id := 222;
	END IF;
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('check if period is open or future');
  END IF;


        -- Check to see if period is open or future
	--IF (C_rec.org_id is not null or C_rec.legal_entity_id is not null) THEN
	--IF (C_rec.bank_account_id is not null) THEN
          SELECT count(1)
          INTO   l_count
          FROM   gl_period_statuses glp,
         	 ce_system_parameters sys,
		 ce_bank_accounts  ba
          WHERE  glp.application_id = l_app_id
          AND    glp.set_of_books_id = sys.set_of_books_id
          AND    glp.adjustment_period_flag = 'N'
          AND    glp.closing_status in ('O','F')
          AND    to_char(C_rec.gl_date,'YYYY/MM/DD') between to_char(glp.start_date,'YYYY/MM/DD') and to_char(glp.end_date,'YYYY/MM/DD')
	  AND    sys.legal_entity_id = ba.account_owner_org_id
	  AND	 ba.bank_account_id = C_rec.bank_account_id;
   	  --and (sys.org_id = C_rec.org_id or sys.legal_entity_id = C_rec.legal_entity_id) ;
 	 IF l_DEBUG in ('Y', 'C') THEN
  	   cep_standard.debug('l_count='||l_count ||', C_rec.gl_date=' || to_char(C_rec.gl_date,'YYYY/MM/DD') );
	 END IF;

      /*ELSE
          SELECT count(1)
          INTO   l_count
          FROM   gl_period_statuses glp,
         	 ce_system_parameters sys
          WHERE  glp.application_id = l_app_id
          AND    glp.set_of_books_id = sys.set_of_books_id
          AND    glp.adjustment_period_flag = 'N'
          AND    glp.closing_status in ('O','F');
	END IF;
      */

 	 IF l_DEBUG in ('Y', 'C') THEN
  	   cep_standard.debug('l_app_id=' ||l_app_id||', l_count='||l_count);
	 END IF;

	-- If period is closed don't proceed to lock and unclear
	-- Bug 3427050 added the AND in the following IF
        IF l_count = 0 AND C_rec.status NOT IN ('STOP INITIATED','VOIDED') THEN
   	  l_skip_lock_unclear := 'Y';
	END IF;
      END IF;


      IF ( C_rec.clearing_trx_type <> 'ROI_LINE') or
           ( l_status is null) then
        l_status := C_rec.status;
      END IF;

      IF (C_rec.clearing_trx_type = 'STATEMENT') THEN
        MATCH_CORRECTION_TYPE	:= 'REVERSAL';

	-- bug 2993811 do not call lock_transaction and unclear_process for second statement line
	-- bug 3208354 compare the statuses of the two statement lines to be UNRECONCILED for skipping

	select statement_number,status
	into l_stmt_stmt_num, l_status1
	from ce_statement_headers hd, ce_statement_lines ln
	where   C_rec.statement_line_id = ln.statement_line_id
	and ln.statement_header_id = hd.statement_header_id;

	/* Bug 3847491. If the line being reconciled has been
	reconcile against another statement line, then check that
	the statement to which this statement line belongs is
	not marked complete*/
	l_next_statement_complete_flag := 'N';

	select statement_number,status,hd.statement_complete_flag
	into l_trx_stmt_num,l_status2, l_next_statement_complete_flag
	from ce_statement_headers hd, ce_statement_lines ln
	where   C_rec.trx_id = ln.statement_line_id
	and ln.statement_header_id = hd.statement_header_id;

	-- stmt number is the same and it is the second stmt ln
	-- bug 3208354 changed the following if condition

	if (l_stmt_stmt_num = l_trx_stmt_num) and  (l_status1 = l_status2)
		 and (l_status1 = 'UNRECONCILED')   then
	 l_skip_lock_unclear :='Y';
	else
	 l_skip_lock_unclear :='N';
	end if;


      ELSE
        MATCH_CORRECTION_TYPE	:= NULL;
      END IF;

      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('C_rec.trx_type ' || C_rec.trx_type ||
				', C_rec.clearing_trx_type ' || C_rec.clearing_trx_type||
				', C_rec.batch_id ' || C_rec.batch_id);
      	cep_standard.debug('C_rec.trx_id ' || C_rec.trx_id||
				', C_rec.cash_receipt_id ' || C_rec.cash_receipt_id||
				', C_rec.statement_line_id ' || C_rec.statement_line_id);

      	cep_standard.debug('C_rec.trx_date ' || C_rec.trx_date||
				', C_rec.gl_date ' || C_rec.gl_date||
				', C_rec.cleared_date ' || C_rec.cleared_date);

      	cep_standard.debug('l_status ' || l_status||', C_rec.amount ' || C_rec.amount||
				', C_rec.bank_account_amount ' || C_rec.bank_account_amount);

       	cep_standard.debug('C_rec.row_id ' || C_rec.row_id||
				', C_rec.statement_complete_flag ' || C_rec.statement_complete_flag);

        cep_standard.debug('C_rec.org_id ' || C_rec.org_id ||
				', C_rec.legal_entity_id '||C_rec.legal_entity_id  );
      	cep_standard.debug('l_stmt_stmt_num ' || l_stmt_stmt_num||
				', l_status1 ' || l_status1);
	cep_standard.debug('l_trx_stmt_num ' || l_trx_stmt_num||
				', l_status2 ' || l_status2||
				', l_skip_lock_unclear ' || l_skip_lock_unclear);
        cep_standard.debug('MATCH_CORRECTION_TYPE '  ||MATCH_CORRECTION_TYPE);

      END IF;

      /* Bug 3847491 added the IF condition nelow */
    IF(nvl(l_next_statement_complete_flag,'N') <> 'Y') THEN

      IF (l_skip_lock_unclear = 'N') then
      	cep_standard.debug('call CE_AUTO_BANK_MATCH.lock_transaction');

        CE_AUTO_BANK_MATCH.lock_transaction(
	X_RECONCILE_FLAG	=> 'Y',
	X_CALL_MODE		=> 'M',
	X_TRX_TYPE 		=> C_rec.trx_type,
	X_CLEARING_TRX_TYPE 	=> C_rec.clearing_trx_type,
	X_TRX_ROWID		=> C_rec.row_id,
	X_BATCH_BA_AMOUNT	=> C_rec.bank_account_amount,
	X_MATCH_CORRECTION_TYPE	=> MATCH_CORRECTION_TYPE);


       IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('call CE_AUTO_BANK_CLEAR.unclear_process');
       END IF;

       CE_AUTO_BANK_CLEAR.unclear_process(
                        passin_mode             => 'MANUAL',
			X_header_or_line	=> 'HEADERS',
			tx_type			=> C_rec.trx_type,
                        clearing_trx_type       => C_rec.clearing_trx_type,
                        batch_id                => C_rec.batch_id,
                        trx_id                  => C_rec.trx_id,
                        cash_receipt_id         => C_rec.cash_receipt_id,
                        trx_date                => C_rec.trx_date,
                        gl_date                 => C_rec.gl_date,
                        cash_receipt_history_id => cash_receipt_history_id,
                        stmt_line_id            => C_rec.statement_line_id,
                        status                  => l_status,
			cleared_date		=> C_rec.cleared_date,
			transaction_amount	=> C_rec.amount,
			error_amount		=> C_rec.bank_errors,
			charge_amount		=> C_rec.bank_charges,
			currency_code		=> C_rec.bank_currency_code,
			xtype		        => C_rec.exchange_rate_type,
			xdate		        => C_rec.exchange_rate_date,
			xrate		        => C_rec.exchange_rate,
                        org_id                  => C_rec.org_id,
                        legal_entity_id         => C_rec.legal_entity_id);
      END IF;  --(l_skip_lock_unclear = 'N')
    END IF; -- (l_next_statement_complete_flag <> 'Y')
      l_cnt := l_cnt + 1;
      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('unreconcile_all: ' || 'Reconciled statement line ID ' ||
			to_char(C_rec.statement_line_id));
      END IF;
      IF (l_cnt = CE_AUTO_BANK_REC.G_lines_per_commit) THEN
        COMMIT;
        l_cnt := 0;
      END IF;
    END IF;
  END LOOP;

  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('<<CE_UNRECONCILE.unreconcile_all '||sysdate);
    cep_standard.disable_debug(X_display_debug);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END UNRECONCILE_ALL;

END CE_AUTO_BANK_UNREC;

/
