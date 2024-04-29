--------------------------------------------------------
--  DDL for Package Body CE_CP_PRIORDAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_CP_PRIORDAY" AS
/* $Header: cecpprib.pls 120.5 2006/07/11 13:25:20 jikumar ship $ */

l_debug VARCHAR2(1) := NVL(FND_PROFILE.value('CE_DEBUG'), 'N');

FUNCTION body_revision RETURN VARCHAR2 IS
BEGIN

  RETURN '$Revision: 120.5 $';

END body_revision;

FUNCTION spec_revision RETURN VARCHAR2 IS
BEGIN

  RETURN G_spec_revision;

END spec_revision;

PROCEDURE set_parameters(p_worksheet_header_id	NUMBER,
			p_as_of_date		VARCHAR2,
			p_display_debug		VARCHAR2,
			p_debug_path		VARCHAR2,
			p_debug_file		VARCHAR2)	IS
BEGIN
  IF l_debug in ('Y', 'C') THEN
    cep_standard.debug('>>CE_CP_PRIORDAY.set_parameters -------');
  END IF;
  CE_CP_PRIORDAY.G_worksheet_header_id	:= p_worksheet_header_id;
  IF (p_as_of_date is null) THEN
    CE_CP_PRIORDAY.G_purge_flag := 'Y';
  ELSE
    CE_CP_PRIORDAY.G_purge_flag := 'N';
  END IF;
  CE_CP_PRIORDAY.G_as_of_date		:= nvl(to_date(p_as_of_date,
						'YYYY/MM/DD HH24:MI:SS'),
						trunc(sysdate));
  CE_CP_PRIORDAY.G_display_debug	:= p_display_debug;
  CE_CP_PRIORDAY.G_debug_path		:= p_debug_path;
  CE_CP_PRIORDAY.G_debug_file		:= p_debug_file;

  cep_standard.debug('G_worksheet_header_id = ' ||
			CE_CP_PRIORDAY.G_worksheet_header_id);
  cep_standard.debug('G_as_of_date = ' || CE_CP_PRIORDAY.G_as_of_date);
  cep_standard.debug('G_display_debug = ' || CE_CP_PRIORDAY.G_display_debug);
  cep_standard.debug('G_debug_path = ' || CE_CP_PRIORDAY.G_debug_path);
  cep_standard.debug('G_debug_file = ' || CE_CP_PRIORDAY.G_debug_file);

END set_parameters;

PROCEDURE calculate_summary IS
  l_ws_id		CE_CP_WORKSHEET_HEADERS.worksheet_header_id%TYPE;
  l_bank_account_id	CE_CP_PRIORDAY_BALANCES.bank_account_id%TYPE;
  l_currency_code       VARCHAR2(15);
  l_statement_date	DATE;
  tmp_balance		NUMBER;

  CURSOR wsba_cursor(p_ws_id	NUMBER) IS
    SELECT WBA.bank_account_id,
           WBA.currency_code,
           OPEN.statement_date
    FROM   CE_CP_OPEN_BAL_V		OPEN,
           CE_CP_WS_BA_V		WBA
    WHERE  WBA.worksheet_header_id = p_ws_id
    AND    WBA.bank_account_id = OPEN.bank_account_id
    AND    OPEN.statement_date < CE_CP_PRIORDAY.G_as_of_date
    AND    OPEN.next_stmt_date >= CE_CP_PRIORDAY.G_as_of_date;

  CURSOR ba_cursor IS
    SELECT bank_account_id,
	   currency_code,
           statement_date
    FROM   CE_CP_OPEN_BAL_V
    WHERE  statement_date < CE_CP_PRIORDAY.G_as_of_date
    AND    next_stmt_date >= CE_CP_PRIORDAY.G_as_of_date;

  CURSOR ws_cursor IS
    SELECT worksheet_header_id
    FROM   CE_CP_WORKSHEET_HEADERS
    WHERE  pd_flag = 'Y'
    AND    (CE_CP_PRIORDAY.G_worksheet_header_id is null
           OR worksheet_header_id = CE_CP_PRIORDAY.G_worksheet_header_id);

BEGIN

  IF l_debug in ('Y', 'C') THEN
    cep_standard.debug('>>CE_CP_PRIORDAY.calculate_summary -------');
  END IF;

  /* purge prior-day data */
  IF (CE_CP_PRIORDAY.G_purge_flag = 'Y') THEN
    BEGIN
      DELETE CE_CP_PRIORDAY_BALANCES
      WHERE  worksheet_header_id = -1
      AND    as_of_date <= trunc(sysdate);
    END;
  ELSE
    BEGIN
      DELETE CE_CP_PRIORDAY_BALANCES
      WHERE  worksheet_header_id = -1
      AND    as_of_date = CE_CP_PRIORDAY.G_as_of_date;
    END;
  END IF;

  /* generate prior-day data */
  OPEN ba_cursor;
  LOOP
    FETCH ba_cursor INTO l_bank_account_id, l_currency_code, l_statement_date;
    EXIT WHEN ba_cursor%NOTFOUND OR ba_cursor%NOTFOUND IS NULL;

    BEGIN

	--bug5219376
	   LOCK TABLE CE_CP_PRIORDAY_BALANCES in EXCLUSIVE MODE;

      INSERT INTO CE_CP_PRIORDAY_BALANCES
          (worksheet_header_id,
          as_of_date,
          bank_account_id,
          balance_date,
          source_type,
          balance,
          last_update_date,
          last_updated_by,
          last_update_login,
          creation_date,
          created_by)
        VALUES (-1,
          CE_CP_PRIORDAY.G_as_of_date,
          l_bank_account_id,
          l_statement_date,
          'HEAD',
          0,
          trunc(sysdate),
          -1,
          -1,
          trunc(sysdate),
          -1);
    END;

    tmp_balance := 0;

    /* Prior Day for APP */
    SELECT -sum(decode(currency_code, l_currency_code, amount, base_amount))
    INTO   tmp_balance
    FROM   CE_AP_FC_PAYMENTS_V
    WHERE  bank_account_id = l_bank_account_id
    AND    nvl(actual_value_date, nvl(anticipated_value_date,
		nvl(maturity_date, payment_date))) > l_statement_date
    AND    nvl(actual_value_date, nvl(anticipated_value_date,
		nvl(maturity_date, payment_date)))
		< CE_CP_PRIORDAY.G_as_of_date;

    IF (tmp_balance IS NOT NULL) THEN
      BEGIN
        INSERT INTO CE_CP_PRIORDAY_BALANCES
            (worksheet_header_id,
            as_of_date,
            bank_account_id,
            balance_date,
            source_type,
            balance,
            last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by)
          VALUES (-1,
            CE_CP_PRIORDAY.G_as_of_date,
            l_bank_account_id,
            l_statement_date,
            'APP',
            tmp_balance,
            trunc(sysdate),
            -1,
            -1,
            trunc(sysdate),
            -1);
      END;
    END IF;

    tmp_balance := 0;

    /* Prior Day for ARR */
    SELECT sum(decode(currency_code, l_currency_code, amount, base_amount))
    INTO   tmp_balance
    FROM   CE_AR_FC_RECEIPTS_V
    WHERE  bank_account_id = l_bank_account_id
    AND	  cash_activity_date > l_statement_date
    AND    cash_Activity_date < CE_CP_PRIORDAY.G_as_of_date;

    IF (tmp_balance is not null) THEN
      BEGIN
        INSERT INTO CE_CP_PRIORDAY_BALANCES
          (worksheet_header_id,
          as_of_date,
          bank_account_id,
          balance_date,
          source_type,
          balance,
          last_update_date,
          last_updated_by,
          last_update_login,
          creation_date,
          created_by)
        VALUES (-1,
          CE_CP_PRIORDAY.G_as_of_date,
          l_bank_account_id,
          l_statement_date,
          'ARR',
          tmp_balance,
          trunc(sysdate),
          -1,
          -1,
          trunc(sysdate),
          -1);
      END;
    END IF;

    tmp_balance := 0;

    /* Prior Day for XTR */
    SELECT sum(amount)
    INTO   tmp_balance
    FROM   CE_XTR_CASHFLOWS_V
    WHERE  bank_account_id = l_bank_account_id
    AND    trx_date > l_statement_date
    AND    trx_date < CE_CP_PRIORDAY.G_as_of_date;

    IF (tmp_balance is not null) THEN
      BEGIN
        INSERT INTO CE_CP_PRIORDAY_BALANCES
          (worksheet_header_id,
          as_of_date,
          bank_account_id,
          balance_date,
          source_type,
          balance,
          last_update_date,
          last_updated_by,
          last_update_login,
          creation_date,
          created_by)
        VALUES (-1,
          CE_CP_PRIORDAY.G_as_of_date,
          l_bank_account_id,
          l_statement_date,
          'XTR',
          tmp_balance,
          trunc(sysdate),
          -1,
          -1,
          trunc(sysdate),
          -1);
      END;
    END IF;

    tmp_balance := 0;

    /* Prior Day for PAY */
    SELECT -sum(decode(currency_code, l_currency_code, amount, base_amount))
    INTO   tmp_balance
    FROM   CE_PAY_FC_PAYROLL_V
    WHERE  bank_account_id = l_bank_account_id
    AND    trx_date > l_statement_date
    AND    trx_date < CE_CP_PRIORDAY.G_as_of_date;

    IF (tmp_balance is not null) THEN
      BEGIN
        INSERT INTO CE_CP_PRIORDAY_BALANCES
          (worksheet_header_id,
          as_of_date,
          bank_account_id,
          balance_date,
          source_type,
          balance,
          last_update_date,
          last_updated_by,
          last_update_login,
          creation_date,
          created_by)
        VALUES (-1,
          CE_CP_PRIORDAY.G_as_of_date,
          l_bank_account_id,
          l_statement_date,
          'PAY',
          tmp_balance,
          trunc(sysdate),
          -1,
          -1,
          trunc(sysdate),
          -1);
      END;
    END IF;

    /* Prior Day for CEI */
    SELECT sum(decode(currency_code, l_currency_code, cashflow_amount, base_amount))
    INTO   tmp_balance
    FROM   CE_CE_CASHFLOWS_V
    WHERE  cash_activity_date > l_statement_date
    AND    cash_activity_date < CE_CP_PRIORDAY.G_as_of_date
    AND	   source_trxn_type <> 'STMT'
    AND	   cashflow_direction = 'RECEIPT';

    IF (tmp_balance is not null) THEN
      BEGIN
        INSERT INTO CE_CP_PRIORDAY_BALANCES
          (worksheet_header_id,
          as_of_date,
          bank_account_id,
          balance_date,
          source_type,
          balance,
          last_update_date,
          last_updated_by,
          last_update_login,
          creation_date,
          created_by)
        VALUES (-1,
          CE_CP_PRIORDAY.G_as_of_date,
          l_bank_account_id,
          l_statement_date,
          'CEI',
          tmp_balance,
          trunc(sysdate),
          -1,
          -1,
          trunc(sysdate),
          -1);
      END;
    END IF;

    tmp_balance := 0;

    /* Prior Day for CEO */
    SELECT sum(decode(currency_code, l_currency_code, cashflow_amount, base_amount))
    INTO   tmp_balance
    FROM   CE_CE_CASHFLOWS_V
    WHERE  cash_activity_date > l_statement_date
    AND    cash_activity_date < CE_CP_PRIORDAY.G_as_of_date
    AND	   source_trxn_type <> 'STMT'
    AND	   cashflow_direction = 'PAYMENT';

    IF (tmp_balance is not null) THEN
      BEGIN
        INSERT INTO CE_CP_PRIORDAY_BALANCES
          (worksheet_header_id,
          as_of_date,
          bank_account_id,
          balance_date,
          source_type,
          balance,
          last_update_date,
          last_updated_by,
          last_update_login,
          creation_date,
          created_by)
        VALUES (-1,
          CE_CP_PRIORDAY.G_as_of_date,
          l_bank_account_id,
          l_statement_date,
          'CEO',
          tmp_balance,
          trunc(sysdate),
          -1,
          -1,
          trunc(sysdate),
          -1);
      END;
    END IF;

    tmp_balance := 0;


  END LOOP;
  CLOSE ba_cursor;

  COMMIT;

  /* generate overdue data */
  OPEN ws_cursor;
  LOOP
    FETCH ws_cursor INTO l_ws_id;
    EXIT WHEN ws_cursor%NOTFOUND OR ws_cursor%NOTFOUND IS NULL;

    cep_standard.debug('l_ws_id = ' || l_ws_id);

    /* purge overdue data */
    IF (CE_CP_PRIORDAY.G_purge_flag = 'Y') THEN
      DELETE CE_CP_PRIORDAY_BALANCES
      WHERE  worksheet_header_id = l_ws_id
      AND    as_of_date <= trunc(sysdate);
    ELSE
      DELETE CE_CP_PRIORDAY_BALANCES
      WHERE  worksheet_header_id = l_ws_id
      AND    as_of_date = CE_CP_PRIORDAY.G_as_of_date;
    END IF;

    OPEN wsba_cursor(l_ws_id);
    LOOP
      FETCH wsba_cursor INTO l_bank_account_id, l_currency_code,
		l_statement_date;
      EXIT WHEN wsba_cursor%NOTFOUND OR wsba_cursor%NOTFOUND IS NULL;

      cep_standard.debug('>>l_bank_account_id = ' || l_bank_account_id);
      cep_standard.debug('>>l_currency_code = ' || l_currency_code);
      cep_standard.debug('>>l_statement_date = ' || to_char(l_statement_date,
						'YYYY/MM/DD'));

      tmp_balance := 0;

      SELECT -sum(decode(AP.currency_code, l_currency_code,
		AP.amount, AP.base_amount))
      INTO   tmp_balance
      FROM   CE_AP_FC_PAYMENTS_V AP,
	     CE_CP_WORKSHEET_LINES WSL
      WHERE  WSL.worksheet_header_id = l_ws_id
      AND    WSL.source_type = 'APP'
      AND    WSL.include_flag = 'Y'
      AND    WSL.cut_off_days is not null
      AND    AP.bank_account_id = l_bank_account_id
      AND    AP.status = 'NEGOTIABLE'
      AND    nvl(AP.actual_value_date, nvl(AP.anticipated_value_date,
		nvl(AP.maturity_date, AP.payment_date)))
		> l_statement_date - WSL.cut_off_days
      AND    nvl(AP.actual_value_date, nvl(AP.anticipated_value_date,
		nvl(AP.maturity_date, AP.payment_date)))
		<= l_statement_date
      AND    (WSL.payment_method is null OR
		AP.payment_method = WSL.payment_method);

      IF (tmp_balance is not null) THEN
        BEGIN
          INSERT INTO CE_CP_PRIORDAY_BALANCES
	    (worksheet_header_id,
	    as_of_date,
	    bank_account_id,
            balance_date,
	    source_type,
	    balance,
	    last_update_date,
	    last_updated_by,
	    last_update_login,
	    creation_date,
	    created_by)
          VALUES (l_ws_id,
	    CE_CP_PRIORDAY.G_as_of_date,
	    l_bank_account_id,
            l_statement_date,
	    'APPOD',
	    tmp_balance,
	    trunc(sysdate),
	    -1,
	    -1,
	    trunc(sysdate),
	    -1);
        END;
      END IF;

      tmp_balance := 0;

      SELECT	sum(decode(ARR.currency_code, l_currency_code,
			ARR.amount, ARR.base_amount))
      INTO	tmp_balance
      FROM	CE_AR_FC_RECEIPTS_V	ARR,
		CE_CP_WORKSHEET_LINES	WSL
      WHERE	WSL.worksheet_header_id = l_ws_id
      AND	WSL.source_type = 'ARR'
      AND	WSL.include_flag = 'Y'
      AND	WSL.cut_off_days is not null
      AND       ARR.bank_account_id = l_bank_account_id
      AND       ARR.status not in ('CLEARED', 'RISK_ELIMINATED')
      AND	ARR.cash_activity_date 	> l_statement_date - WSL.cut_off_days
      AND	ARR.cash_activity_date	<= l_statement_date
      AND	(WSL.receipt_method_id is null OR
			ARR.receipt_method_id = WSL.receipt_method_id);


      IF (tmp_balance is not null) THEN
        BEGIN
          INSERT INTO CE_CP_PRIORDAY_BALANCES
	    (worksheet_header_id,
	    as_of_date,
	    bank_account_id,
            balance_date,
	    source_type,
	    balance,
	    last_update_date,
	    last_updated_by,
	    last_update_login,
	    creation_date,
	    created_by)
          VALUES (l_ws_id,
	    CE_CP_PRIORDAY.G_as_of_date,
	    l_bank_account_id,
            l_statement_date,
	    'ARROD',
	    tmp_balance,
	    trunc(sysdate),
	    -1,
	    -1,
	    trunc(sysdate),
	    -1);
        END;
      END IF;

      tmp_balance := 0;

      SELECT	sum(XTR.amount)
      INTO	tmp_balance
      FROM	CE_CP_WORKSHEET_LINES	WSL,
		CE_XTR_CASHFLOWS_V	XTR
      WHERE	WSL.worksheet_header_id = l_ws_id
      AND	WSL.source_type = 'XTI'
      AND	WSL.include_flag = 'Y'
      AND	WSL.cut_off_days is not null
      AND	XTR.bank_account_id = l_bank_account_id
      AND	XTR.amount >= 0
      AND	XTR.reconciled_reference is null
      AND	XTR.trx_date > l_statement_date - WSL.cut_off_days
      AND	XTR.trx_date <= l_statement_date
      AND	(WSL.trx_type is null OR XTR.deal_type = WSL.trx_type)
      AND	(WSL.indicative_flag = 'Y' OR NOT (XTR.dda_deal_type = 'EXP'
			AND XTR.dda_deal_subtype = 'INDIC'));

      IF (tmp_balance is not null) THEN
        BEGIN
          INSERT INTO CE_CP_PRIORDAY_BALANCES
	    (worksheet_header_id,
	    as_of_date,
	    bank_account_id,
            balance_date,
	    source_type,
	    balance,
	    last_update_date,
	    last_updated_by,
	    last_update_login,
	    creation_date,
	    created_by)
          VALUES (l_ws_id,
	    CE_CP_PRIORDAY.G_as_of_date,
	    l_bank_account_id,
            l_statement_date,
	    'XTIOD',
	    tmp_balance,
	    trunc(sysdate),
	    -1,
	    -1,
	    trunc(sysdate),
	    -1);
        END;
      END IF;

      tmp_balance := 0;

      SELECT	sum(XTR.amount)
      INTO	tmp_balance
      FROM	CE_CP_WORKSHEET_LINES	WSL,
		CE_XTR_CASHFLOWS_V	XTR
      WHERE	WSL.worksheet_header_id = l_ws_id
      AND	WSL.source_type = 'XTO'
      AND	WSL.include_flag = 'Y'
      AND	WSL.cut_off_days is not null
      AND	XTR.bank_account_id = l_bank_account_id
      AND	XTR.amount < 0
      AND	XTR.reconciled_reference is null
      AND	XTR.trx_date > l_statement_date - WSL.cut_off_days
      AND	XTR.trx_date <= l_statement_date
      AND	(WSL.trx_type is null OR XTR.deal_type = WSL.trx_type)
      AND	(WSL.indicative_flag = 'Y' OR NOT (XTR.dda_deal_type = 'EXP'
			AND XTR.dda_deal_subtype = 'INDIC'));

      IF (tmp_balance is not null) THEN
        BEGIN
          INSERT INTO CE_CP_PRIORDAY_BALANCES
	    (worksheet_header_id,
	    as_of_date,
	    bank_account_id,
            balance_date,
	    source_type,
	    balance,
	    last_update_date,
	    last_updated_by,
	    last_update_login,
	    creation_date,
	    created_by)
          VALUES (l_ws_id,
	    CE_CP_PRIORDAY.G_as_of_date,
	    l_bank_account_id,
            l_statement_date,
	    'XTOOD',
	    tmp_balance,
	    trunc(sysdate),
	    -1,
	    -1,
	    trunc(sysdate),
	    -1);
        END;
      END IF;

	/*Overdue CEI*/

      tmp_balance := 0;

      SELECT -sum(decode(CEI.currency_code, l_currency_code,
		CEI.cashflow_amount, CEI.base_amount))
      INTO   tmp_balance
      FROM   CE_CE_CASHFLOWS_V CEI,
	     CE_CP_WORKSHEET_LINES WSL
      WHERE  WSL.worksheet_header_id = l_ws_id
      AND    WSL.source_type = 'CEI'
      AND    WSL.include_flag = 'Y'
      AND    WSL.cut_off_days is not null
      AND    CEI.cashflow_bank_account_id = l_bank_account_id
      AND    CEI.cashflow_status = 'CREATED'
      AND    CEI.cash_activity_date
		> l_statement_date - WSL.cut_off_days
      AND    CEI.cash_activity_date
		<= l_statement_date
      AND    (WSL.trxn_subtype_code_id is null OR
		CEI.trxn_subtype_code_id = WSL.trxn_subtype_code_id)
      AND    CEI.cashflow_direction = 'RECEIPT'
      AND    CEI.source_trxn_type <> 'STMT';


      IF (tmp_balance is not null) THEN
        BEGIN
          INSERT INTO CE_CP_PRIORDAY_BALANCES
	    (worksheet_header_id,
	    as_of_date,
	    bank_account_id,
            balance_date,
	    source_type,
	    balance,
	    last_update_date,
	    last_updated_by,
	    last_update_login,
	    creation_date,
	    created_by)
          VALUES (l_ws_id,
	    CE_CP_PRIORDAY.G_as_of_date,
	    l_bank_account_id,
            l_statement_date,
	    'CEIOD',
	    tmp_balance,
	    trunc(sysdate),
	    -1,
	    -1,
	    trunc(sysdate),
	    -1);
        END;
      END IF;

      tmp_balance := 0;


      /*Overdue CEO*/

      tmp_balance := 0;

      SELECT -sum(decode(CEO.currency_code, l_currency_code,
		CEO.cashflow_amount, CEO.base_amount))
      INTO   tmp_balance
      FROM   CE_CE_CASHFLOWS_V CEO,
	     CE_CP_WORKSHEET_LINES WSL
      WHERE  WSL.worksheet_header_id = l_ws_id
      AND    WSL.source_type = 'CEO'
      AND    WSL.include_flag = 'Y'
      AND    WSL.cut_off_days is not null
      AND    CEO.cashflow_bank_account_id = l_bank_account_id
      AND    CEO.cashflow_status = 'CREATED'
      AND    CEO.cash_activity_date
		> l_statement_date - WSL.cut_off_days
      AND    CEO.cash_activity_date
		<= l_statement_date
      AND    (WSL.trxn_subtype_code_id is null OR
		CEO.trxn_subtype_code_id = WSL.trxn_subtype_code_id)
      AND    CEO.cashflow_direction = 'PAYMENT'
      AND    CEO.source_trxn_type <> 'STMT';

      IF (tmp_balance is not null) THEN
        BEGIN
          INSERT INTO CE_CP_PRIORDAY_BALANCES
	    (worksheet_header_id,
	    as_of_date,
	    bank_account_id,
            balance_date,
	    source_type,
	    balance,
	    last_update_date,
	    last_updated_by,
	    last_update_login,
	    creation_date,
	    created_by)
          VALUES (l_ws_id,
	    CE_CP_PRIORDAY.G_as_of_date,
	    l_bank_account_id,
            l_statement_date,
	    'CEOOD',
	    tmp_balance,
	    trunc(sysdate),
	    -1,
	    -1,
	    trunc(sysdate),
	    -1);
        END;
      END IF;

      tmp_balance := 0;

    END LOOP;
    CLOSE wsba_cursor;

    BEGIN
      INSERT INTO CE_CP_PRIORDAY_BALANCES
	(worksheet_header_id,
	as_of_date,
	bank_account_id,
        balance_date,
	source_type,
	balance,
	last_update_date,
	last_updated_by,
	last_update_login,
	creation_date,
	created_by)
      VALUES (l_ws_id,
	CE_CP_PRIORDAY.G_as_of_date,
	-1,
        trunc(CE_CP_PRIORDAY.G_as_of_date),
	'HEAD',
	0,
	trunc(sysdate),
	-1,
	-1,
	trunc(sysdate),
	-1);
    END;

    COMMIT;

  END LOOP;
  CLOSE ws_cursor;

END calculate_summary;

PROCEDURE gen_prior_day(errbuf			OUT NOCOPY	VARCHAR2,
			retcode			OUT NOCOPY	NUMBER,
			p_worksheet_header_id	NUMBER,
			p_as_of_date		VARCHAR2,
			p_display_debug		VARCHAR2,
			p_debug_path		VARCHAR2,
			p_debug_file		VARCHAR2)	IS
BEGIN

  cep_standard.init_security;
  IF l_debug in ('Y', 'C') THEN
    cep_standard.enable_debug(p_debug_path, p_debug_file);
    cep_standard.debug('>>CE_CP_PRIORDAY.gen_prior_day ------- '||sysdate||
		' -------');
    cep_standard.debug('p_worksheet_header_id: '|| p_worksheet_header_id);
    cep_standard.debug('p_as_of_date: '|| p_as_of_date);
    cep_standard.debug('p_display_debug: '||p_display_debug);
    cep_standard.debug('p_debug_path: '||p_debug_path);
    cep_standard.debug('p_debug_file: '||p_debug_file);
  END IF;

  set_parameters(p_worksheet_header_id, p_as_of_date, p_display_debug,
		p_debug_path, p_debug_file);

  calculate_summary;

  IF l_debug in ('Y', 'C') THEN
    cep_standard.debug('<<CE_CP_PRIORDAY.gen_prior_day -------');
  END IF;

END gen_prior_day;

END CE_CP_PRIORDAY;

/
