--------------------------------------------------------
--  DDL for Package Body CE_BAT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_BAT_API" AS
/* $Header: cebtapib.pls 120.32.12010000.10 2010/06/22 10:40:38 ckansara ship $ */
--


-- Statement lines
G_sl_trx_date	DATE := NULL;
G_sl_description	CE_STATEMENT_LINES.trx_text%TYPE := NULL;
G_sl_value_date	DATE := NULL;
G_sl_currency_code	CE_STATEMENT_LINES.currency_code%TYPE := NULL;
G_sl_amount	CE_STATEMENT_LINES.amount%TYPE := NULL;
G_sl_original_amount	CE_STATEMENT_LINES.original_amount%TYPE := NULL;
G_sl_statement_line_id	CE_STATEMENT_LINES.statement_line_id%TYPE := NULL;
G_sl_bank_trx_number	CE_STATEMENT_LINES.bank_trx_number%TYPE := NULL;
G_sl_trx_type	CE_STATEMENT_LINES.trx_type%TYPE := NULL;

-- Bank accounts
G_source_bank_account_id	CE_BANK_ACCOUNTS.bank_account_id%TYPE := NULL;
G_destination_bank_account_id	CE_BANK_ACCOUNTS.bank_account_id%TYPE := NULL;
G_source_bank_account_name CE_BANK_ACCOUNTS.bank_account_name%TYPE := null;
G_dest_bank_account_name CE_BANK_ACCOUNTS.bank_account_name%TYPE := null;
G_source_ba_currency_code	CE_BANK_ACCOUNTS.currency_code%TYPE := NULL;
G_destination_ba_currency_code	CE_BANK_ACCOUNTS.currency_code%TYPE := NULL;
G_source_ba_asset_ccid	CE_BANK_ACCOUNTS.asset_code_combination_id%TYPE := NULL;
G_destination_ba_asset_ccid	CE_BANK_ACCOUNTS.asset_code_combination_id%TYPE := NULL;
G_ba_bank_charge_bearer CE_BANK_ACCOUNTS.pool_bank_charge_bearer_code%TYPE := NULL;
G_ba_payment_method_code CE_BANK_ACCOUNTS.pool_payment_method_code%TYPE := NULL;
G_ba_payment_reason_code CE_BANK_ACCOUNTS.pool_payment_reason_code%TYPE := NULL;
G_ba_payment_reason_comments CE_BANK_ACCOUNTS.pool_payment_reason_comments%TYPE
						 := NULL;
G_ba_remittance_message1 CE_BANK_ACCOUNTS.pool_remittance_message1%TYPE := NULL;
G_ba_remittance_message2 CE_BANK_ACCOUNTS.pool_remittance_message2%TYPE := NULL;
G_ba_remittance_message3 CE_BANK_ACCOUNTS.pool_remittance_message3%TYPE := NULL;


-- Legal entity
G_source_le_id	CE_BANK_ACCOUNTS.account_owner_org_id%TYPE := NULL;
G_destination_le_id	CE_BANK_ACCOUNTS.account_owner_org_id%TYPE := NULL;
G_source_le_party_id	XLE_ENTITY_PROFILES.party_id%TYPE := NULL;
G_destination_le_party_id  XLE_ENTITY_PROFILES.party_id%TYPE := NULL;
G_destination_party_site_id  HZ_PARTY_SITES.party_site_id%TYPE := NULL;


-- Cash pool
G_cp_cashpool_id	CE_CASHPOOLS.cashpool_id%TYPE := NULL;
G_cp_authorize_flag	VARCHAR2(30) := NULL;
G_cp_trxn_subtype_code_id	NUMBER := NULL;
G_cp_currency_code CE_CASHPOOLS.currency_code%TYPE:= NULL;

-- CL Proposed transfer
G_proposed_transfer_id NUMBER := NULL;
G_proposed_as_of_date DATE := NULL;
G_proposed_transfer_amount CE_PROPOSED_TRANSFERS.transfer_amount%TYPE  := NULL;

-- System parameters
G_sp_authorize_flag	CE_SYSTEM_PARAMETERS.authorization_bat%TYPE := NULL;

-- Transfer
G_sl_cashflow_direction	VARCHAR2(30) := NULL;
G_bat_settle_flag	VARCHAR2(10) := NULL;
G_bat_status	VARCHAR2(30) := NULL;
G_bat_authorize_flag	VARCHAR2(10) := NULL;
G_bat_payment_offset_ccid  CE_PAYMENT_TRANSACTIONS.payment_offset_ccid%TYPE
					:= NULL;
G_bat_receipt_offset_ccid   CE_PAYMENT_TRANSACTIONS.receipt_offset_ccid%TYPE
					 := NULL;
G_bat_amount	NUMBER := NULL;
G_bat_date	DATE := NULL;
G_bat_currency_code  CE_STATEMENT_LINES.currency_code%TYPE := NULL;
G_bat_created_from_dir	CE_STATEMENT_LINES.trx_type%TYPE := 'PAYMENT';
G_bat_statement_line_id	CE_STATEMENT_LINES.statement_line_id%TYPE := NULL;
G_bat_anticipated_date DATE := NULL;
G_cashflows_created_flag VARCHAR2(1) := 'N';
G_multi_currency_flag VARCHAR2(1) := 'N';

FUNCTION  spec_revision RETURN VARCHAR2 is
BEGIN
      RETURN G_spec_revision;
END;

FUNCTION  body_revision RETURN VARCHAR2 is
BEGIN
      RETURN '$Revision: 120.32.12010000.10 $';
END;


PROCEDURE log(p_msg varchar2) is
BEGIN
    --  FND_FILE.PUT_LINE(FND_FILE.LOG,p_msg);
    --	dbms_output.put_line(p_msg);
    cep_standard.debug(p_msg);

END log;

/*bug5219357*/
PROCEDURE check_cashpool(
	p_called_by VARCHAR2,
	p_cashpool_id NUMBER,
	p_result OUT NOCOPY VARCHAR2)
IS
  CURSOR c_cashpool (c_cashpool_id number)IS
  SELECT authorization_bat
  FROM ce_cashpools
  WHERE cashpool_id = c_cashpool_id;

  l_authorization_Bat CE_CASHPOOLS.authorization_bat%TYPE;
BEGIN

  OPEN c_Cashpool(p_cashpool_id);
  FETCH c_cashpool INTO l_authorization_bat;
  CLOSE c_cashpool;

  IF (l_authorization_bat IS NULL) THEN
	--setup for XTR
	FND_MESSAGE.set_name('CE','CE_INVALID_CASHPOOL_FOR_CE');
	FND_MSG_PUB.add;
  	p_result := 'FAIL';
	RETURN;
  END IF;

  IF (p_called_by = 'CL' AND g_ba_payment_method_code IS NULL) THEN
	FND_MESSAGE.set_name('CE','CE_INVALID_CASHPOOL_FOR_CE');
	FND_MSG_PUB.add;
  	p_result := 'FAIL';
	RETURN;
  END IF;
	p_result := 'SUCCESS';
EXCEPTION
WHEN OTHERS THEN
	RAISE;
END check_cashpool;

/*bug5219357*/
/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                   |
|       initiate_transfer
|  DESCRIPTION															|
|	This procedure is used when the transfer is created
	by the ZBA and CL programs.It gathers data from different
|	tables necassary for creating the transfer
|                                                                       |
|  HISTORY                                                              |
|       14-JUL-2005        Shaik Vali		Created                 	|
 --------------------------------------------------------------------- */

PROCEDURE initiate_transfer(
	p_called_by VARCHAR2,
	p_source_ba_id	NUMBER,
	p_destination_ba_id	NUMBER,
	p_cashpool_id	NUMBER,
	p_statement_line_id  NUMBER,
	p_transfer_amount NUMBER,
	p_as_of_date	DATE,
	p_payment_details_from VARCHAR2,
	p_result OUT NOCOPY varchar2)
IS

   CURSOR ba_cursor (p_cs_bank_account_id NUMBER) IS
   SELECT
	ba.bank_account_id,
	ba.currency_code,
	ba.account_owner_org_id,
	ba.asset_code_combination_id,
	ba.pool_bank_charge_bearer_code,
	ba.pool_payment_method_code,
	ba.pool_payment_reason_code,
	ba.pool_payment_reason_comments,
	ba.pool_remittance_message1,
	ba.pool_remittance_message2,
	ba.pool_remittance_message3,
	xfp.party_id,
	hps.party_site_id,
	decode(nvl(sp.authorization_bat,'NR'),
			'NR','N','Y'),
	sp.legal_entity_id,
	ba.bank_account_name
   FROM
	ce_bank_accounts ba,
	xle_entity_profiles xfp,
	hz_party_sites hps,
	ce_system_parameters sp
   WHERE
	ba.bank_account_id = p_cs_bank_account_id
	AND xfp.legal_entity_id = ba.account_owner_org_id
	AND sp.legal_entity_id(+)= xfp.legal_entity_id
	AND hps.identifying_address_flag(+) = 'Y'
	AND hps.party_id(+) = xfp.party_id;

   l_dummy VARCHAR2(10);

   l_src_bank_charge_bearer CE_BANK_ACCOUNTS.pool_bank_charge_bearer_code%TYPE;
   l_src_payment_method_code  CE_BANK_ACCOUNTS.pool_payment_method_code%TYPE;
   l_src_payment_reason_code CE_BANK_ACCOUNTS.pool_payment_reason_code%TYPE;
   l_src_payment_reason_comments CE_BANK_ACCOUNTS.pool_payment_reason_comments%TYPE;
   l_src_remittance_message1 CE_BANK_ACCOUNTS.pool_remittance_message1%TYPE;
   l_src_remittance_message2 CE_BANK_ACCOUNTS.pool_remittance_message2%TYPE;
   l_src_remittance_message3 CE_BANK_ACCOUNTS.pool_remittance_message3%TYPE;

   l_dest_bank_charge_bearer CE_BANK_ACCOUNTS.pool_bank_charge_bearer_code%TYPE;
   l_dest_payment_method_code  CE_BANK_ACCOUNTS.pool_payment_method_code%TYPE;
   l_dest_payment_reason_code CE_BANK_ACCOUNTS.pool_payment_reason_code%TYPE;
   l_dest_payment_reason_comments CE_BANK_ACCOUNTS.pool_payment_reason_comments%TYPE;
   l_dest_remittance_message1 CE_BANK_ACCOUNTS.pool_remittance_message1%TYPE;
   l_dest_remittance_message2 CE_BANK_ACCOUNTS.pool_remittance_message2%TYPE;
   l_dest_remittance_message3 CE_BANK_ACCOUNTS.pool_remittance_message3%TYPE;

   l_cnt NUMBER;
   l_anticipated_float NUMBER;
   l_dummy2 NUMBER;
   l_sp_src_le_id NUMBER;
   l_sp_dest_le_id NUMBER;
   l_result varchar2(10);
BEGIN

   log ('>> initiate_transfer...');
   -- Fetch source bank account data
   log ('Fetching source bank account data ...'|| p_source_ba_id);
   OPEN ba_cursor(p_source_ba_id);
   FETCH ba_cursor
   INTO
	G_source_bank_account_id,
	G_source_ba_currency_code,
	G_source_le_id,
	G_source_ba_asset_ccid,
	l_src_bank_charge_bearer,
	l_src_payment_method_code,
	l_src_payment_reason_code,
	l_src_payment_reason_comments,
	l_src_remittance_message1,
	l_src_remittance_message2,
	l_src_remittance_message3,
	G_source_le_party_id,
	l_dummy2,
	G_sp_authorize_flag,
	l_sp_src_le_id,
	G_source_bank_account_name;
   CLOSE ba_cursor;

   -- Fetch destination bank account data
   log ('Fetching destination bank account data ...'||p_destination_ba_id);
   OPEN ba_cursor(p_destination_ba_id);
   FETCH ba_cursor
   INTO
	G_destination_bank_account_id,
	G_destination_ba_currency_code,
	G_destination_le_id,
	G_destination_ba_asset_ccid,
	l_dest_bank_charge_bearer,
	l_dest_payment_method_code,
	l_dest_payment_reason_code,
	l_dest_payment_reason_comments,
	l_dest_remittance_message1,
	l_dest_remittance_message2,
	l_dest_remittance_message3,
	G_destination_le_party_id,
	G_destination_party_site_id,
	l_dummy,
	l_sp_dest_le_id,
	G_dest_bank_account_name;
   CLOSE ba_cursor;

   -- Identify the bank account to default the payment
   -- attributes from.
   log('Fetching payment attributes ...' || p_payment_details_from);
   IF p_payment_details_from = 'SRC' THEN
	G_ba_bank_charge_bearer  := l_src_bank_charge_bearer;
	G_ba_payment_method_code := l_src_payment_method_code;
	G_ba_payment_reason_code := l_src_payment_reason_code;
	G_ba_payment_reason_comments := l_src_payment_reason_comments;
	G_ba_remittance_message1 := l_src_remittance_message1;
	G_ba_remittance_message2 := l_src_remittance_message2;
	G_ba_remittance_message3 := l_src_remittance_message3;
   ELSIF p_payment_details_from = 'DEST' THEN
	G_ba_bank_charge_bearer := l_dest_bank_charge_bearer;
	G_ba_payment_method_code := l_dest_payment_method_code;
	G_ba_payment_reason_code := l_dest_payment_reason_code;
	G_ba_payment_reason_comments := l_dest_payment_reason_comments;
	G_ba_remittance_message1 := l_dest_remittance_message1;
	G_ba_remittance_message2 := l_dest_remittance_message2;
	G_ba_remittance_message3 := l_dest_remittance_message3;
   END IF;
/*bug5219357*/
	 -- For ZBA and CL the cash pool should be setup
	 -- as CE cashpool
	 check_cashpool(p_called_by,p_cashpool_id,l_result);
 	 IF (l_result in ('FAIL')) THEN
		p_result := 'FAIL';
		RETURN;
	 END IF;
/*bug5219357*/
   -- Fetch cashpool data
   log('Fetching cashpool data...');
   SELECT
	cp.cashpool_id,
	cp.currency_code,
	decode(nvl(cp.authorization_bat,'NR'),
			'NR','N','Y'),
	cp.trxn_subtype_code_id
   INTO
	G_cp_cashpool_id,
	G_cp_currency_code,
	G_cp_authorize_flag,
	G_cp_trxn_subtype_code_id
   FROM	ce_cashpools cp
   WHERE cp.cashpool_id = p_cashpool_id;

   IF (p_called_by = 'ZBA') THEN
	   -- Fetch Statement line data
	   SELECT
		sl.statement_line_id,
		sl.trx_date,
		sl.trx_type,
		sl.amount,
		sl.original_amount,
		sl.effective_date,
		sl.trx_text,
		sl.bank_trx_number,
		sl.currency_code
	   INTO
		G_sl_statement_line_id,
		G_sl_trx_date,
		G_sl_trx_type,
		G_sl_amount,
		G_sl_original_amount,
		G_sl_value_date,
		G_sl_description,
		G_sl_bank_trx_number,
		G_sl_currency_code
	   FROM
		ce_statement_lines sl
	   WHERE
		sl.statement_line_id = p_statement_line_id;

	G_bat_settle_flag := 'N';
	G_bat_amount := NVL(G_sl_original_amount,G_sl_amount);
	G_bat_date := G_sl_trx_date;
	G_bat_anticipated_date := NVL(G_sl_value_date,G_sl_trx_date);
	G_bat_currency_code := NVL(G_sl_currency_code,
						   G_source_ba_currency_code);
	G_bat_statement_line_id := p_statement_line_id;

	IF G_sl_trx_type = 'SWEEP_OUT' THEN
		G_bat_created_from_dir := 'PAYMENT';
	ELSIF G_sl_trx_type = 'SWEEP_IN' THEN
		G_bat_created_from_dir := 'RECEIPT';
	END IF;

  ELSIF (p_called_by = 'CL') THEN

	  -- Get the payment method float days
	  log('Fetching anticipated_float from payment method...'||
	       G_ba_payment_method_code);
	  SELECT anticipated_float
	  INTO l_anticipated_float
	  FROM iby_payment_methods_vl
	  WHERE payment_method_code = G_ba_payment_method_code;

	 G_bat_settle_flag := 'Y';
	 G_bat_amount := p_transfer_amount;
	 G_bat_currency_code := G_cp_currency_code;
	 G_proposed_as_of_date := p_as_of_date;

	 IF (p_as_of_date < sysdate) THEN
  	    G_bat_date := sysdate;
 	    G_bat_anticipated_date := sysdate + l_anticipated_float;
	 ELSE
  	    G_bat_date := p_as_of_date;
	    G_bat_anticipated_date := p_as_of_date + l_anticipated_float;
	 END IF;
  END IF;
   log ('<< initiate_transfer...');
EXCEPTION
WHEN OTHERS THEN
  p_result := 'FAIL';
  log('Exception in initiate_transfer');
  RAISE;
END initiate_transfer;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                   |
|       check_duplicate
|  DESCRIPTION															|
|	This procedure is used to check for duplicate transfers when
|	the transfer is created by ZBA and CL programs.					|
|                                                                       |
|  HISTORY                                                              |
|       14-JUL-2005        Shaik Vali		Created                 	|
 --------------------------------------------------------------------- */

PROCEDURE check_duplicate(
	p_called_by	VARCHAR2,
	p_source_ba_id	 NUMBER,
	p_destination_ba_id	NUMBER,
	p_statement_line_id	NUMBER,
	p_transfer_amount		NUMBER,
	p_transfer_date 	DATE,
	p_pay_trxn_number OUT NOCOPY NUMBER,
	p_result OUT NOCOPY varchar2)
IS
  l_cnt NUMBER;
  -- Bug 9354284 Start
  l_bank_trx_number ce_statement_lines.bank_trx_number%TYPE;
  l_stmt_header_id ce_statement_lines.Statement_header_id%TYPE;
  l_amount ce_statement_lines.amount%TYPE;
  l_trx_date ce_statement_lines.trx_date%TYPE;
  l_cashflow_id ce_statement_lines.cashflow_id%TYPE;
  -- Bug 9354284 End

  -- Bug 9650263
  CURSOR c_stmt_lines(c_stmt_line_id number) IS
  SELECT bank_trx_number,statement_header_id,amount,trx_date
  FROM ce_statement_lines
  WHERE statement_line_id = c_stmt_line_id;


BEGIN
   log ('>> Check duplicate...');
   log ('p_transfer_date='||p_transfer_date||
	'p_source_ba_id='||p_source_ba_id||
	'p_dest_ba_id='||p_destination_ba_id||
	'p_transfer_amnount='||p_transfer_amount);

   IF (p_called_by = 'ZBA') THEN

	 -- Bug 9650263
	OPEN c_stmt_lines(p_statement_line_id);
	FETCH c_stmt_lines
	INTO l_bank_trx_number,
	l_stmt_header_id,
	l_amount,l_trx_date;
	CLOSE c_stmt_lines;

	log('l_bank_trx_number = ' || l_bank_trx_number);
	log('l_stmt_header_id = ' || l_stmt_header_id);
	log('l_trx_date = ' || l_trx_date);
	log('l_amount = ' || l_amount);


      SELECT count(*)
      INTO   l_cnt
      FROM  ce_payment_transactions pt
      WHERE pt.create_from_stmtline_id = p_statement_line_id
      AND pt.source_bank_account_id = p_source_ba_id
      AND pt.destination_bank_account_id = p_destination_ba_id
      AND trunc(pt.transaction_date) = trunc(p_transfer_date)
      AND pt.payment_amount = p_transfer_amount
      AND pt.trxn_status_code not in ('FAILED','CANCELLED');

	  -- Bug 9354284 Start
      log('old count  = ' || l_cnt);
      IF (l_cnt = 0 ) then
        BEGIN

          -- Check if a Cashflow with similar date, amount and reference_number has already been generated for the source account.
          SELECT Count(*)
          INTO l_cnt
          FROM ce_payment_transactions
          WHERE bank_trxn_number = l_bank_trx_number
          AND transaction_date = l_trx_date
          AND payment_amount  = l_amount
          AND CREATE_FROM_STMTLINE_ID IS NOT NULL;

          log('1 count  = ' || l_cnt);

          -- Fetch the cashflow ID If above case is true
          SELECT CASHFLOW_ID
          INTO L_CASHFLOW_ID
          FROM ce_cashflows
          WHERE bank_trxn_number = l_bank_trx_number AND statement_line_id IS NULL
          AND cashflow_bank_account_id = p_source_ba_id
          AND cashflow_date  = l_trx_date
          AND cashflow_amount = l_amount;
          log('L_CASHFLOW_ID  = ' || L_CASHFLOW_ID);

          -- Stamp the Cashflow ID and Statement Line Id in the respective tables
          UPDATE CE_STATEMENT_LINES
          SET CASHFLOW_ID = L_CASHFLOW_ID
          WHERE STATEMENT_LINE_ID = p_statement_line_id;

          UPDATE CE_CASHFLOWS
          SET STATEMENT_LINE_ID = p_statement_line_id
          WHERE CASHFLOW_ID = L_CASHFLOW_ID;

        EXCEPTION
        WHEN No_Data_Found THEN
           log('NO DATA L_CASHFLOW_ID  = ' || L_CASHFLOW_ID);
        END;
        IF ( L_CASHFLOW_ID IS NOT NULL ) THEN
          L_CNT := 1;
        END IF;
        log('2 count  = ' || l_cnt);

      end if;
      -- Bug 9354284 End

   ELSIF (p_called_by = 'CL') THEN
    SELECT count(*)
    INTO l_cnt
    FROM ce_payment_transactions pt
    WHERE
    	pt.source_bank_account_id = p_source_ba_id
    AND	pt.destination_bank_account_id = p_destination_ba_id
    AND	trunc(pt.transaction_date) = trunc(p_transfer_date)
    AND	pt.payment_amount = p_transfer_amount
    AND pt.trxn_status_code not in ('FAILED','CANCELLED');
  END IF;

  IF l_cnt > 0 THEN
	p_result := 'FOUND';
  ELSE
	p_result := 'NOT_FOUND';
  END IF;

   log ('<< check_duplicate...l_cnt='||l_cnt);
EXCEPTION
WHEN OTHERS THEN
  p_result := 'FAIL';
  log('Exception in check_duplicate');
  RAISE;
END check_duplicate;


/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                   |
|       check_user_security
|  DESCRIPTION															|
|	This procedure is used to check whether the current user has
|	access to the UMX CEBAT security function. Used when
|	the transfer is created by ZBA and CL programs.					|
|                                                                       |
|  HISTORY                                                              |
|       15-JUL-2005        Shaik Vali		Created                 	|
 --------------------------------------------------------------------- */

PROCEDURE check_user_security(
	p_source_le_id	NUMBER,
	p_destination_le_id	NUMBER,
	p_result OUT NOCOPY varchar2)
IS
  l_s_cnt NUMBER;
  l_d_cnt NUMBER;
BEGIN

     log('>> check_user_security.....');

    l_s_cnt := cep_standard.check_ba_security(p_source_le_id,'CEBAT');
    l_d_cnt := cep_standard.check_ba_security(p_destination_le_id,'CEBAT');

    IF (l_s_cnt = 1 AND l_d_cnt = 1) THEN
	p_result := 'HAS_ACCESS';
    ELSE
	p_result := 'NO_ACCESS';
    END IF;

    log('<< check_user_security.....' || p_result);
EXCEPTION
   WHEN OTHERS THEN
	log('Exception in check_user_security');
	p_result := 'FAIL';
	RAISE;
END check_user_security;


/* --------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|       create_transfer
|  DESCRIPTION															|
|	This procedure is called directly from the ZBA and CL
|	programs. the parameter p_called_by indicates the CL or ZBA		|
|	mode. When called by CL, the transfer is just created with status
|	New and quit the program. When called by ZBA, the transfer is 	|
|	created and also validated.										|
|                                                                       |
|  HISTORY                                                              |
|       14-JUL-2005        Shaik Vali		Created                 	|
 --------------------------------------------------------------------- */

PROCEDURE create_transfer(
	p_called_by_1 VARCHAR2,
	p_source_ba_id NUMBER,
	p_destination_ba_id NUMBER,
	p_statement_line_id NUMBER,
	p_cashpool_id NUMBER,
	p_transfer_amount NUMBER,
	p_payment_details_from VARCHAR2,
	p_as_of_date DATE,
	p_cashflows_created_flag OUT NOCOPY VARCHAR2,
	p_result OUT NOCOPY varchar2,
	p_msg_count OUT NOCOPY NUMBER,
	p_trxn_reference_number OUT NOCOPY NUMBER)
IS
	l_result VARCHAR2(30);
	l_ccid NUMBER;
	l_reciprocal_ccid NUMBER;
	p_called_by VARCHAR2(30);
	l_cashflow_id1 NUMBER;
	l_cashflow_id2 NUMBER;
	l_mode VARCHAR2(100);
	l_settle_flag VARCHAR2(10);
BEGIN

  IF (p_called_by_1 = 'L') THEN
	p_called_by := 'CL';
  ELSIF (p_called_by_1 = 'Z') THEN
	p_called_by := 'ZBA';
  END IF;

  log('>> CE_BAT_API.create_transfer ... mode = ' || p_called_by);
  IF (p_called_by in ('ZBA','CL')) THEN

	 FND_MSG_PUB.initialize;
	 --Gather the data required for creating the transfer
	 initiate_transfer(p_called_by,
					p_source_ba_id,
					p_destination_ba_id,
					p_cashpool_id,
					p_statement_line_id,
					p_transfer_amount,
					p_as_of_date,
					p_payment_details_from,
					p_result);

	IF (p_result in ('FAIL')) THEN
		p_msg_count := FND_MSG_PUB.count_msg;
		RETURN;
	END IF;

	 -- Check whether the user has access to the
	 -- UMX security function to create transfers
     	 check_user_security(G_source_le_id,
					 G_destination_le_id,
					 l_result);

	 IF (l_result in ('NO_ACCESS')) THEN
		FND_MESSAGE.set_name('CE','CE_BAT_NO_ACCESS');
		FND_MSG_PUB.add;
		p_result := 'FAILURE';
		p_msg_count := FND_MSG_PUB.count_msg;
		RETURN;
	 END IF;

	 -- check for duplicate transfers
 	 check_duplicate(p_called_by,
				p_source_ba_id,
				p_destination_ba_id,
				p_statement_line_id,
				G_bat_amount,
				G_bat_date,
				p_trxn_reference_number,
				l_result);

	 IF (l_result in ('FOUND')) THEN
		FND_MESSAGE.set_name('CE','CE_BAT_DUPLICATE_FOUND');
		FND_MSG_PUB.add;
		p_result := 'FAIL';
		-- stop if duplicate transfer is found
		p_msg_count := FND_MSG_PUB.count_msg;
		RETURN;
	 END IF;


	 -- populate payment transactions table
 	 populate_transfer(p_trxn_reference_number);

	 IF (p_called_by = 'ZBA' OR p_called_by = 'CL') THEN
	     IF (p_called_by ='ZBA') THEN
		l_settle_flag := 'N';
	     ELSE
		l_settle_flag := 'Y';
	     END IF;

	     validate_transfer( p_called_by,
					p_trxn_reference_number,
					G_source_le_id,
					G_destination_le_id,
					G_source_ba_currency_code,
					G_destination_ba_currency_code,
					G_bat_currency_code,
					G_bat_date,
					G_source_ba_asset_ccid,
					G_destination_ba_asset_ccid,
					p_destination_ba_id,
					G_cp_authorize_flag,
					l_settle_flag,
					l_ccid,
					l_reciprocal_ccid,
					l_result);

	    IF (l_result = 'FAILURE') THEN
		CE_PAYMENT_TRXN_PKG.update_transfer_status
			(p_trxn_reference_number,'INVALID');

   	    ELSIF (l_result = 'SUCCESS' AND p_called_by='ZBA') THEN
		CE_PAYMENT_TRXN_PKG.update_transfer_status
				(p_trxn_reference_number,'VALIDATED');
		IF (NVL(NVL(G_cp_authorize_flag,G_sp_authorize_flag),'N')= 'N')
		THEN
 		        create_update_cashflows(p_trxn_reference_number,l_mode,
 					    l_cashflow_id1,
					    l_cashflow_id2);

			settle_transfer(p_called_by,p_trxn_reference_number,
					 null,
					 l_cashflow_id1,
					 l_cashflow_id2);

	  	END IF;
	    END IF;
        END IF;
  END IF;
	p_cashflows_created_flag := G_cashflows_created_flag;
	p_result := 'SUCCESS';
	p_msg_count := FND_MSG_PUB.count_msg;

  log('<< BAT_API.create_transfer');
EXCEPTION
  WHEN OTHERS THEN
  log('EXCEPTION in create_transfer');
  p_result := 'FAIL';
  RAISE;
END create_transfer;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       validate_transfer                                               |
|  DESCRIPTION								                            |
|	This procedure performs the necassary validations required while    |
|	creating a transfer. This can be called while creating the 	        |
|	transfer either from ZBA, CL or MANUAL (from the UI) modes.	        |
|	1) When called with MANUAL mode and if Settlement is required       |
|	   then Payments validations are also performed.                    |
|	2) After all the validations are successfull and authorization      |
|	   is not required then authorize the transfer directly.            |
|                                                                       |
|  HISTORY                                                              |
|       16-JUL-2005        Shaik Vali	 Created                 	    |
|       17-JUN-2008        Varun Netan   Bug 6911203: Corrected call to |
|                                        intercompany API.              |
|       02-SEP-2008        Varun Netan   Bug 7357191: Reworked the way  |
|                                        in which CCIDs are fetched     |
|                                        using intercompany API.        |
 --------------------------------------------------------------------- */

PROCEDURE validate_transfer(
	p_called_by                     VARCHAR2,
	p_trxn_reference_number         NUMBER,
	p_source_le_id	                NUMBER,
	p_destination_le_id	            NUMBER,
	p_source_ba_currency_code       VARCHAR2,
	p_destination_ba_currency_code  VARCHAR2,
	p_transfer_currency_code        VARCHAR2,
	p_transfer_date	                DATE,
	p_source_ba_asset_ccid          NUMBER,
	p_destination_ba_asset_ccid     NUMBER,
	p_destination_bank_account_id   NUMBER,
	p_authorize_flag                VARCHAR2,
	p_settle_flag                   VARCHAR2,
	p_ccid	                        OUT NOCOPY NUMBER,
	p_reciprocal_ccid	            OUT NOCOPY NUMBER,
	p_result                        OUT NOCOPY varchar2)
IS
    l_status VARCHAR2(20);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(1000);
    l_result VARCHAR2(20);
    l_mode VARCHAR2(10);
    l_cashflow_id1 NUMBER;
    l_cashflow_id2 NUMBER;
    l_source_ledger_id NUMBER := NULL;
    l_destination_ledger_id NUMBER := NULL;
    l_source_ledger_curr	GL_LEDGERS.currency_code%TYPE := NULL;
    l_destination_ledger_curr  GL_LEDGERS.currency_code%TYPE := NULL;
    l_from_ledger_id NUMBER;
    l_to_ledger_id NUMBER;
    l_from_bsv VARCHAR2(1000);
    l_to_bsv VARCHAR2(1000);
    l_intercompany BOOLEAN := false;

BEGIN
	log('>> validate_transfer.....');

	IF p_called_by = 'MANUAL' THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- The bank accounts should have a not null
	-- asset_combination_id. Transfer cannot be
	-- created for bank accounts that are not attched to
	-- any GL cash account

	IF p_source_ba_asset_ccid is NULL OR
	   p_destination_ba_asset_ccid is NULL THEN
	   IF p_called_by = 'MANUAL' THEN
		SELECT sba.bank_account_name,
			   d_ba.bank_account_name
		INTO g_source_bank_account_name,
			 g_dest_bank_account_name
		FROM ce_bank_accounts sba,
			 ce_bank_accounts d_ba,
			 ce_payment_transactions pt
		WHERE pt.trxn_reference_number=p_trxn_reference_number
		AND  sba.bank_account_id=pt.source_bank_account_id
		AND  d_ba.bank_account_id=pt.destination_bank_account_id;
	  END IF;
	  IF p_source_ba_asset_ccid IS NULL
	  THEN
	  	FND_MESSAGE.set_name('CE','CE_BAT_NO_CASH_ACCOUNT');
		FND_MESSAGE.set_token('BA_NAME',G_source_bank_account_name);
	 	FND_MSG_PUB.add;
  	  END IF;
	  IF p_destination_ba_asset_ccid IS NULL
	  THEN
	  	FND_MESSAGE.set_name('CE','CE_BAT_NO_CASH_ACCOUNT');
		FND_MESSAGE.set_token('BA_NAME',G_dest_bank_account_name);
	 	FND_MSG_PUB.add;
  	  END IF;
  	  p_result := 'FAILURE';
   	  UPDATE ce_payment_transactions
   	  SET trxn_status_code = 'INVALID'
	  WHERE trxn_reference_number = p_trxn_reference_number;
	  RETURN;
	END IF;

	-- The transfer currency should either the source
	-- bank account currency or destination bank account
	IF p_transfer_currency_code NOT IN (p_source_ba_currency_code,
					  p_destination_ba_currency_code)
	THEN
  	  FND_MESSAGE.set_name('CE','CE_BAT_INVALID_CURRENCY');
	  FND_MSG_PUB.add;
 	  p_result := 'FAILURE';
	  UPDATE ce_payment_transactions
	  SET trxn_status_code = 'INVALID'
	  WHERE trxn_reference_number = p_trxn_reference_number;
	  RETURN;
	END IF;

	-- Both the bank accounts cannot be non-functional currency.

	l_source_ledger_id := CE_BAT_UTILS.get_ledger_id(p_source_le_id);
	l_destination_ledger_id:=CE_BAT_UTILS.get_ledger_id(p_destination_le_id);
	SELECT currency_code
	INTO l_source_ledger_curr
	FROM gl_ledgers
	WHERE ledger_id=l_source_ledger_id;

	SELECT currency_code
	INTO l_destination_ledger_curr
	FROM gl_ledgers
	WHERE ledger_id=l_destination_ledger_id;


	-- for bug 6455698
	IF p_source_ba_currency_code <> p_destination_ba_currency_code THEN
	  IF ((p_transfer_currency_code = p_source_ba_currency_code) and
	     (l_destination_ledger_curr <> p_destination_ba_currency_code))  THEN
	       FND_MESSAGE.set_name('CE','CE_BAT_INVALID_DEST_BANK');
		FND_MSG_PUB.add;
	 	p_result := 'FAILURE';
		UPDATE ce_payment_transactions
		SET trxn_status_code = 'INVALID'
		WHERE trxn_reference_number = p_trxn_reference_number;
		RETURN;
	   ELSIF ((p_transfer_currency_code = p_destination_ba_currency_code) and
	       (l_source_ledger_curr <> p_source_ba_currency_code)) THEN
		FND_MESSAGE.set_name('CE','CE_BAT_INVALID_SRC_BANK');
		FND_MSG_PUB.add;
	 	p_result := 'FAILURE';
		UPDATE ce_payment_transactions
		SET trxn_status_code = 'INVALID'
		WHERE trxn_reference_number = p_trxn_reference_number;
		RETURN;
	  END IF;
	END IF;

    -- Check if the transfer is within the same ledger or
    -- different ledgers
    l_from_ledger_id := CE_BAT_UTILS.get_ledger_id(p_source_le_id);
    l_to_ledger_id   := CE_BAT_UTILS.get_ledger_id(p_destination_le_id);
    l_from_bsv       := CE_BAT_UTILS.get_bsv(p_source_ba_asset_ccid,
                          l_from_ledger_id);
    l_to_bsv         := CE_BAT_UTILS.get_bsv(p_destination_ba_asset_ccid,
                          l_to_ledger_id);
/* commented these lines for bug 5528877
	 IF (l_from_ledger_id <> l_to_ledger_id) THEN
	    l_intercompany := true;
 	 ELSIF (l_from_bsv <> l_to_bsv) THEN
	    l_intercompany := true;
	 ELSE
	    l_intercompany := false;
	 END IF;
*/
    l_intercompany := true;
    -- Call Intercompany API to fetch CCIDs
    -- Bug 7357191: Intercompany API calls reworked. The call has to be made
    -- twice, once to fetch Debit CC and once to fetch Credit CC.
    -- For Debit CC the from_cash_gl_ccid/le should be the Payment Account.
    -- For Credit CC the from_cash_gl_ccid/le should be the Receipt Account.
    -- Also assigning values to p_ccid and p_reciprocal_ccid parameters such
    -- that these OUT parameters contain the payment_offset_ccid and
    -- reciept_offset_ccid respectively.
	IF (l_intercompany)
    THEN
        log('Fetch intercompany');
        log('bat_created_from_dir = '||G_bat_created_from_dir);
        IF (G_bat_created_from_dir = 'PAYMENT')
        THEN
            -- Payment Account ==> p_source_ba_asset_ccid
            -- Receipt Account ==> p_destination_ba_asset_ccid
            -- Payment LE ==> p_source_le_id
            -- Receipt LE ==> p_destination_le_id

            -- fetch debit CC
            CE_BAT_UTILS.get_intercompany_ccid (
			 p_from_le_id => p_source_le_id,
			 p_to_le_id => p_destination_le_id,
			 p_from_cash_gl_ccid => p_source_ba_asset_ccid,
			 p_to_cash_gl_ccid => p_destination_ba_asset_ccid,
			 p_transfer_date => p_transfer_date,
             p_acct_type => 'D',
	  	     p_status => l_status,
 		     p_msg_count => l_msg_count,
 		     p_msg_data => l_msg_data,
  	         p_ccid => p_ccid,
			 p_reciprocal_ccid => p_reciprocal_ccid,
			 p_result => l_result);
            -- Set debit CCID as PAYMENT Offset
            G_bat_payment_offset_ccid := p_ccid;

            -- fetch credit CC
            CE_BAT_UTILS.get_intercompany_ccid (
			 p_from_le_id => p_destination_le_id,
			 p_to_le_id => p_source_le_id,
			 p_from_cash_gl_ccid => p_destination_ba_asset_ccid,
			 p_to_cash_gl_ccid => p_source_ba_asset_ccid,
			 p_transfer_date => p_transfer_date,
             p_acct_type => 'C',
	  	     p_status => l_status,
 		     p_msg_count => l_msg_count,
 		     p_msg_data => l_msg_data,
  	         p_ccid => p_ccid,
			 p_reciprocal_ccid => p_reciprocal_ccid,
			 p_result => l_result);
            -- Set credit CCID as RECEIPT offset
            G_bat_receipt_offset_ccid := p_ccid;

        ELSIF (G_bat_created_from_dir = 'RECEIPT')
        THEN
            -- Payment Account ==> p_destination_ba_asset_ccid
            -- Receipt Account ==> p_source_ba_asset_ccid
            -- Payment LE ==> p_destination_le_id
            -- Receipt LE ==> p_source_le_id

            -- fetch debit CC
            CE_BAT_UTILS.get_intercompany_ccid (
             p_from_le_id => p_destination_le_id,
             p_to_le_id => p_source_le_id,
             p_from_cash_gl_ccid => p_destination_ba_asset_ccid,
             p_to_cash_gl_ccid => p_source_ba_asset_ccid,
             p_transfer_date => p_transfer_date,
             p_acct_type => 'D',
             p_status => l_status,
             p_msg_count => l_msg_count,
             p_msg_data => l_msg_data,
             p_ccid => p_ccid,
             p_reciprocal_ccid => p_reciprocal_ccid,
             p_result => l_result);
            -- Set debit CCID as PAYMENT offset
            G_bat_payment_offset_ccid := p_ccid;

            -- fetch credit CC
            CE_BAT_UTILS.get_intercompany_ccid (
             p_from_le_id => p_source_le_id,
             p_to_le_id => p_destination_le_id,
             p_from_cash_gl_ccid => p_source_ba_asset_ccid,
             p_to_cash_gl_ccid => p_destination_ba_asset_ccid,
             p_transfer_date => p_transfer_date,
             p_acct_type => 'C',
             p_status => l_status,
             p_msg_count => l_msg_count,
             p_msg_data => l_msg_data,
             p_ccid => p_ccid,
             p_reciprocal_ccid => p_reciprocal_ccid,
             p_result => l_result);
            -- Set credit CCID as RECEIPT offset
            G_bat_receipt_offset_ccid := p_ccid;

        END IF;
        -- Error resolving inter/intra-company rules
        IF l_result = 'NO_INTERCOMPANY_CCID'
        THEN
            p_result := 'FAILURE';
            UPDATE ce_payment_transactions
            SET trxn_status_code = 'INVALID'
            WHERE trxn_reference_number = p_trxn_reference_number;
            RETURN;
        END IF;
    ELSE -- no intercompany
        log('No Intercompany');
        --7357191: Changed assignments to directly apply values
        -- to Global variables.
    	IF (G_bat_created_from_dir = 'PAYMENT') THEN
           G_bat_payment_offset_ccid := p_destination_ba_asset_ccid;
    	   G_bat_receipt_offset_ccid := p_source_ba_asset_ccid;
    	ELSIF (G_bat_created_from_dir = 'RECEIPT') THEN
    	   G_bat_payment_offset_ccid := p_source_ba_asset_ccid;
    	   G_bat_receipt_offset_ccid := p_destination_ba_asset_ccid;
    	END IF;
    END IF;

    -- 7357191: added for compatibility to ensure that the OUT parameters
    -- have proper values.
    p_ccid := G_bat_payment_offset_ccid;
    p_reciprocal_ccid := G_bat_receipt_offset_ccid;
    log('G_bat_payment_offset_ccid = '||to_char(p_ccid));
    log('G_bat_receipt_offset_ccid = '||to_char(p_reciprocal_ccid));

    -- 7357191: changed values to Global variables
    UPDATE ce_payment_transactions
    SET payment_offset_ccid = G_bat_payment_offset_ccid,
       receipt_offset_ccid = G_bat_receipt_offset_ccid
    WHERE trxn_reference_number = p_trxn_reference_number;
    p_result := 'SUCCESS';

    IF (p_called_by = 'MANUAL' OR p_called_by = 'CL' OR p_called_by = 'ZBA')
    THEN
        IF (p_settle_flag = 'Y')
        THEN
            --call iby validation APIs
            iby_validations(p_destination_bank_account_id,
                            p_trxn_reference_number,
                            p_result);

            IF (p_result = 'SUCCESS')
            THEN
                -- When validations are successful, create/update cashflows
                create_update_cashflows(p_trxn_reference_number,l_mode,
                            l_cashflow_id1,
                            l_cashflow_id2);

                -- After validation is successfull and authorization
                -- is not required then authorize the transfer directly
                IF (p_authorize_flag = 'Y')
                THEN
                    UPDATE ce_payment_transactions
                    SET trxn_status_code = 'VALIDATED'
                    WHERE trxn_reference_number = p_trxn_reference_number;
                ELSE
                    authorize_transfer('AUTO',
                            p_trxn_reference_number,
                            NULL,
                            NULL,
                            p_result);
                END IF;
            ELSE --p_result != 'SUCCESS'
                UPDATE ce_payment_transactions
                SET trxn_Status_code = 'INVALID'
                WHERE trxn_reference_number = p_trxn_reference_number;
            END IF;

        ELSE -- settle_flag != 'Y'
            IF (p_authorize_flag = 'Y')
            THEN
                UPDATE ce_payment_transactions
                SET trxn_status_code = 'VALIDATED'
                WHERE trxn_reference_number = p_trxn_reference_number;

                create_update_cashflows(p_trxn_reference_number,
                    l_mode,
                    l_cashflow_id1,
                    l_cashflow_id2);
	        ELSE
                create_update_cashflows(p_trxn_reference_number,
                    l_mode,
                    l_cashflow_id1,
                    l_cashflow_id2);

                settle_transfer(p_called_by,
                     p_trxn_reference_number,
                     null,
                     l_cashflow_id1,
                     l_cashflow_id2);
            END IF;
	    END IF;
     END IF;
	 log('<< validate_transfer');
EXCEPTION
  WHEN OTHERS THEN
	p_result := 'FAIL';
	log('Exception in validate_transfer');
	-- Bug 8869718 - Commented Following Line
	-- RAISE;
END validate_transfer;


/* --------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|       authorize_transfer
|  DESCRIPTION								|
|	This procedure is called either from 				|
|	1)The UI when the transfer is validated. The validate_transfer	|
|	  api calls this procedure when validations are successfull and	|
|	  authorization is not required.This is the AUTO case. Since |
|	  this is called only when Settlement is required, IBYBUILD 	|
|	  program is submitted						|
|	2)The UI when the transfer is authorized. This is the MANUAL case|
|	  IBYBUILD program is submitted since settlement is required
|                                                                       |
|  HISTORY                                                              |
|       16-JUL-2005        Shaik Vali		Created                 |
 --------------------------------------------------------------------- */

PROCEDURE authorize_transfer(
	p_called_by VARCHAR2,
	p_trxn_reference_number	NUMBER,
	p_settle_flag VARCHAR2,
	p_pay_proc_req_code NUMBER,
	p_result OUT NOCOPY varchar2)
IS
	l_cnt NUMBER;
	l_request_id NUMBER;
	l_pay_proc_req_code NUMBER;
BEGIN
     log('>> authorize_transfer');

     IF p_called_by = 'MANUAL' THEN
	 -- called by UI
	 SELECT count(*)
	 INTO l_cnt
	 FROM ce_payment_transactions
	 WHERE payment_request_number = p_pay_proc_req_code;

	 IF l_cnt > 0 THEN
	    CE_BAT_UTILS.call_payment_process_request(
		p_pay_proc_req_code,l_request_id);

	    IF (l_request_id = 0) THEN
		FND_MESSAGE.set_name('CE','CE_BAT_IBY_BUILD_FAILED');
		FND_MSG_PUB.add;
		p_result := 'FAILURE';
	    ELSE
		UPDATE ce_payment_transactions
	  	SET trxn_status_code = 'IN_PROCESS'
		WHERE payment_request_number = p_pay_proc_req_code;
		p_result := 'SUCCESS';
	    END IF;
	 END IF;

     ELSIF p_called_by = 'AUTO' THEN
	 -- called by validate_transfer

	 -- generate the unique payment process request code
	 SELECT ce_payment_transactions_s.nextval
	 INTO l_pay_proc_req_code
	 FROM dual;

	 -- stamp the transfer with the payment process reqeuest code
	 UPDATE ce_payment_transactions
	 SET payment_request_number = l_pay_proc_req_code
	 WHERE trxn_reference_number = p_trxn_reference_number;

	 -- call IBY Build program
 	 log('submitting the Payments build program');
	 CE_BAT_UTILS.call_payment_process_request(
			l_pay_proc_req_code,l_request_id);

	 IF l_request_id = 0 THEN
		FND_MESSAGE.set_name('CE','CE_BAT_IBY_BUILD_FAILED');
		FND_MSG_PUB.add;
		p_result := 'FAILURE';
	 ELSE
	 log('submitted the Payments Build program:' || l_request_id);
	 	CE_PAYMENT_TRXN_PKG.update_transfer_status(
				p_trxn_reference_number,'IN_PROCESS');
		p_result := 'SUCCESS';
	 END IF;
     END IF;
log('<< authorize_transfer result=' || p_result);
EXCEPTION
WHEN OTHERS THEN
log('Exception in authorize_transfer');
p_result := 'FAILURE';
RAISE;
END authorize_transfer;


/* --------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|       reject_transfer
|  DESCRIPTION															|
|	This procedure is called either from the UI when the transfer	|
|	is rejected or by the payments call back api.							 						|
|                                                                       |
|  HISTORY                                                              |
|       22-JUL-2005        Shaik Vali		Created                 	|
 --------------------------------------------------------------------- */

PROCEDURE reject_transfer(
	p_pay_trxn_number	NUMBER,
	p_result OUT NOCOPY	varchar2)
IS
	CURSOR c_cashflows(p_pay_trxn_number NUMBER) IS
	SELECT cashflow_id
	FROM ce_cashflows
	WHERE trxn_reference_number=p_pay_trxn_number;

	l_cashflow_id1 NUMBER;
	l_cashflow_id2 NUMBER;
	l_result VARCHAR2(20);
BEGIN
	CE_PAYMENT_TRXN_PKG.update_transfer_status(
			p_pay_trxn_number, 'REJECTED');


	UPDATE ce_cashflows
	SET cashflow_status_code='CANCELED'
	WHERE trxn_reference_number=p_pay_trxn_number;

	p_result := 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
	p_result := 'FAIL';
	RAISE;
END reject_transfer;


/* --------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|       cancel_transfer
|  DESCRIPTION															|
|	This procedure is called either from the UI when the transfer	|
|	is canceled. This procedure cancels the cashflows created		|
|	by the transfer and raise the XLA events
|                                                                       |
|  HISTORY                                                              |
|       22-JUL-2005        Shaik Vali		Created                 	|
 --------------------------------------------------------------------- */

PROCEDURE cancel_transfer(
	p_pay_trxn_number	NUMBER,
	p_result OUT NOCOPY VARCHAR2)
IS

  l_cnt NUMBER;
  l_event_id NUMBER;
  l_cashflow_id NUMBER;

  CURSOR cashflows_c (p_trxn_ref_number NUMBER) IS
  SELECT cf.cashflow_id
  FROM	 ce_cashflows cf,
	 ce_payment_transactions pt
  WHERE  cf.trxn_reference_number = pt.trxn_reference_number
  AND	 pt.trxn_status_code = 'SETTLED'
  AND 	 cf.trxn_reference_number = p_trxn_ref_number;

BEGIN
	log('>>cancel transfer');
	OPEN cashflows_c (p_pay_trxn_number);
	LOOP
	  FETCH cashflows_c
	     INTO l_cashflow_id;
  	  EXIT WHEN cashflows_c%NOTFOUND OR cashflows_c%NOTFOUND is null;
	  log('calling XLA cancel event...'|| l_cashflow_id);
   	  -- call the XLA API to cancel the BAT
	  CE_XLA_ACCT_EVENTS_PKG.create_event
		(l_cashflow_id,'CE_BAT_CANCELED');

  	END LOOP;
	CLOSE cashflows_c;

	-- Update the cashflows status to CANCELED
	UPDATE ce_cashflows
	SET	cashflow_status_code = 'CANCELED'
	WHERE	trxn_reference_number = p_pay_trxn_number;

	-- Update the payment transaction status to CANCELED
	CE_PAYMENT_TRXN_PKG.update_transfer_status
			(p_pay_trxn_number,'CANCELED');

	p_result := 'SUCCESS';
	log('<<cancel transfer');
EXCEPTION
  WHEN OTHERS THEN
	p_result := 'FAIL';
	log('Exception in cancel_transfer');
	RAISE;
END cancel_transfer;


/* --------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|       populate_transfer
|  DESCRIPTION															|
|	This procedure is dumps the data gathered by initiate_transfer	|
|	into the ce_payment_transactions table
|                                                                       |
|  HISTORY                                                              |
|       17-JUL-2005        Shaik Vali		Created                 	|
 --------------------------------------------------------------------- */

PROCEDURE populate_transfer (p_pay_trxn_number OUT NOCOPY NUMBER)
IS
	l_settle_flag VARCHAR2(2);
	l_created_from_dir	CE_STATEMENT_LINES.trx_type%TYPE;
	l_row_id ROWID;
BEGIN

 log('>> populate_transfer...');
 CE_PAYMENT_TRXN_PKG.Insert_Row(
	 X_ROWID => l_row_id,
	 X_TRXN_REFERENCE_NUMBER => p_pay_trxn_number,
	 X_SETTLE_BY_SYSTEM_FLAG => G_bat_settle_flag,
	 X_TRANSACTION_TYPE    => 'BAT',
	 X_TRXN_SUBTYPE_CODE_ID  => G_cp_trxn_subtype_code_id,
	 X_TRANSACTION_DATE    => G_bat_date,
	 X_ANTICIPATED_VALUE_DATE => G_bat_anticipated_date,
	 X_TRANSACTION_DESCRIPTION  => G_sl_description,
	 X_PAYMENT_CURRENCY_CODE   => G_bat_currency_code,
	 X_PAYMENT_AMOUNT       => G_bat_amount,
	 X_SOURCE_PARTY_ID       => G_source_le_party_id,
	 X_SOURCE_LEGAL_ENTITY_ID  => G_source_le_id,
	 X_SOURCE_BANK_ACCOUNT_ID  => G_source_bank_account_id,
	 X_DEST_PARTY_ID           => G_destination_le_party_id,
	 X_DEST_LEGAL_ENTITY_ID    => G_destination_le_id,
	 X_DEST_BANK_ACCOUNT_ID    => G_destination_bank_account_id,
	 X_DEST_PARTY_SITE_ID  => G_destination_party_site_id,
	 X_REPETITIVE_PAYMENT_CODE => NULL,
	 X_TRXN_STATUS_CODE        => 'NEW',
	 X_PAYMENT_METHOD_CODE     => G_ba_payment_method_code,
	 X_AUTHORIZE_FLAG          => NVL(G_cp_authorize_flag,G_sp_authorize_flag),
	 X_BANK_CHARGE_BEARER      => G_ba_bank_charge_bearer,
	 X_PAYMENT_REASON_CODE     => G_ba_payment_reason_code,
	 X_PAYMENT_REASON_COMMENTS => G_ba_payment_reason_comments,
	 X_REMITTANCE_MESSAGE1  => G_ba_remittance_message1,
	 X_REMITTANCE_MESSAGE2  => G_ba_remittance_message2,
	 X_REMITTANCE_MESSAGE3  => G_ba_remittance_message3,
	 X_CREATED_FROM_DIR        => G_bat_created_from_dir,
	 X_CREATE_FROM_STMTLINE_ID => G_bat_statement_line_id,
	 X_BANK_TRXN_NUMBER        => G_sl_bank_trx_number,
	 X_PAYMENT_REQUEST_NUMBER => NULL,
	 X_PAPER_DOCUMENT_NUMBER  => NULL,
	 X_DOC_SEQUENCE_ID   => NULL,
	 X_DOC_SEQUENCE_VALUE => NULL,
	 X_DOC_CATEGORY_CODE => NULL,
	 X_PAYMENT_OFFSET_CCID     => G_bat_payment_offset_ccid,
	 X_RECEIPT_OFFSET_CCID     => G_bat_receipt_offset_ccid,
	 X_CASHPOOL_ID             => G_cp_cashpool_id,
	 X_CREATED_BY              => FND_GLOBAL.user_id,
	 X_CREATION_DATE           => sysdate,
	 X_LAST_UPDATED_BY         => FND_GLOBAL.user_id,
	 X_LAST_UPDATE_DATE        => sysdate,
	 X_LAST_UPDATE_LOGIN       => FND_GLOBAL.user_id,
	 X_EXT_BANK_ACCOUNT_ID 	=> NULL,
	 X_ATTRIBUTE_CATEGORY => NULL,
	 X_ATTRIBUTE1 => NULL,
	 X_ATTRIBUTE2 => NULL,
	 X_ATTRIBUTE3 => NULL,
	 X_ATTRIBUTE4 => NULL,
	 X_ATTRIBUTE5 => NULL,
	 X_ATTRIBUTE6 => NULL,
	 X_ATTRIBUTE7 => NULL,
	 X_ATTRIBUTE8 => NULL,
	 X_ATTRIBUTE9 => NULL,
	 X_ATTRIBUTE10 => NULL,
	 X_ATTRIBUTE11 => NULL,
	 X_ATTRIBUTE12 => NULL,
	 X_ATTRIBUTE13 => NULL,
	 X_ATTRIBUTE14 => NULL,
	 X_ATTRIBUTE15 => NULL);
 log('<< populate_transfer...');
END populate_transfer;


/* --------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|       settle_transfer
|  DESCRIPTION															|
|	This procedure creates the cashflows for a transfer and raises |
|	XLA events. This is	called when 							|
|	1) the transfer is authorized and settlement is not required	|
|	2) By the IBYBUILD program's callback apis, after the payment is|
|	   created.
| 	                                                                   |
|  HISTORY                                                              |
|       24-JUL-2005        Shaik Vali		Created                 	|
 --------------------------------------------------------------------- */

PROCEDURE settle_transfer(
	p_called_by VARCHAR2,
	p_pay_trxn_number NUMBER,
	/*Bug7559093 - Changed NUMBER to VARCHAR2 */
	p_payment_reference_number VARCHAR2,
	p_cashflow_id1 NUMBER,
	p_cashflow_id2 NUMBER)
IS
	l_event_id1 NUMBER;
	l_event_id2 NUMBER;

	l_cashflow_id1 NUMBER;
	l_cashflow_id2 NUMBER;

	CURSOR c_cashflows(p_trxn_ref_number NUMBER) IS
	SELECT cashflow_id
	FROM ce_cashflows
	WHERE trxn_Reference_number=p_trxn_ref_number;
BEGIN
	log('>>settle_transfer...' || p_pay_trxn_number);

	l_cashflow_id1 := p_cashflow_id1;
	l_cashflow_id2 := p_cashflow_id2;

	IF (p_called_by = 'CALL_BACK' OR p_called_by='MANUAL') THEN

		OPEN c_cashflows(p_pay_trxn_number);
		FETCH c_cashflows INTO l_cashflow_id1;
		FETCH c_cashflows INTO l_cashflow_id2;
		CLOSE c_cashflows;
/* Bug7559093, As p_payment_reference_number changed to VARCHAR2
the comparision <>0 changed to <>'0' */
		IF (p_payment_reference_number <>'0') THEN
  		  UPDATE ce_payment_transactions
		  SET bank_trxn_number = p_payment_reference_number
		  WHERE trxn_reference_number = p_pay_trxn_number;

		  UPDATE ce_cashflows
		  SET bank_trxn_number = p_payment_reference_number
		  WHERE trxn_reference_number = p_pay_trxn_number;
	 	END IF;
	END IF;


	log('updating status to SETTLED...');
	--update transfer status to SETTLED
	CE_PAYMENT_TRXN_PKG.update_transfer_status(
			 p_pay_trxn_number,
			 'SETTLED');


	log('raising XLA create events for cashflows...: ' ||
		l_cashflow_id1 || ' , ' || l_cashflow_id2);

	--raise CREATE AE in XLA for the 2 cashflows
	CE_XLA_ACCT_EVENTS_PKG.create_event(
					 l_cashflow_id1,
				 	'CE_BAT_CREATED');

	CE_XLA_ACCT_EVENTS_PKG.create_event(
					 l_cashflow_id2,
					 'CE_BAT_CREATED');

	G_cashflows_created_flag := 'Y';

	log('<<settle_transfer');
EXCEPTION
WHEN OTHERS THEN
	log('Exception in settle_transfer');
	RAISE;
END settle_transfer;


/* --------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|       call_iby_validate
|  DESCRIPTION															|
|	This procedure calls Payments online validations api and is called|
|	from the UI on clicking the validate icon. However, before	|
|	the api is called, we need to populate the GT iby_docs_payment_gt|
|	After the validations are done, and if there are any validations|
|	failures, the errors are store in table iby_transaction_errors_gt|
|	This errors table is queried and shown from the UI.
| 	                                                                   |
|  HISTORY                                                              |
|       24-JUL-2005        Shaik Vali		Created                 	|
 --------------------------------------------------------------------- */

PROCEDURE call_iby_validate(p_trxn_reference_number NUMBER,
					p_doc_payable_id OUT NOCOPY NUMBER,
					p_return_status OUT NOCOPY VARCHAR2)
IS

  l_docs_payable_rec IBY_DOCS_PAYABLE_GT%ROWTYPE;
  l_return_status VARCHAR2(20);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(1000);
  l_transaction_id NUMBER;
  l_error_type IBY_TRANSACTION_ERRORS_GT.error_type%TYPE;
  l_error_code IBY_TRANSACTION_ERRORS_GT.error_code%TYPE;
  l_error_message IBY_TRANSACTION_ERRORS_GT.error_message%TYPE;
  l_error_date IBY_TRANSACTION_ERRORS_GT.error_date%TYPE;
  l_error_status IBY_TRANSACTION_ERRORS_GT.error_status%TYPE;
  l_validation_Set_code IBY_TRANSACTION_ERRORS_GT.validation_set_code%TYPE;
  l_cnt NUMBER;

BEGIN
log('>> call_iby_validate');
	SELECT
		ANTICIPATED_VALUE_DATE,
		'Y',
		BANK_CHARGE_BEARER,
		TRXN_REFERENCE_NUMBER,
		TRXN_REFERENCE_NUMBER,
		260,
		PAYMENT_AMOUNT,
		PAYMENT_CURRENCY_CODE,
		TRANSACTION_DATE,
		TRANSACTION_DESCRIPTION,
		'BAT',
		'Y',
		EXT_BANK_ACCOUNT_ID,
		DESTINATION_BANK_ACCOUNT_ID,
		DESTINATION_LEGAL_ENTITY_ID,
		DESTINATION_LEGAL_ENTITY_ID,
		'LEGAL_ENTITY',
		'BAT',
		DESTINATION_PARTY_ID,
		DESTINATION_PARTY_SITE_ID,
		PAYMENT_AMOUNT,
		PAYMENT_CURRENCY_CODE,
		TRANSACTION_DATE,
		'CASH_PAYMENT',
		PAYMENT_METHOD_CODE,
		PAYMENT_REASON_CODE,
		PAYMENT_REASON_COMMENTS,
		REMITTANCE_MESSAGE1,
		REMITTANCE_MESSAGE2,
		REMITTANCE_MESSAGE3,
		IBY_DOCS_PAYABLE_GT_S.nextval
	INTO
		l_docs_payable_rec.anticipated_value_date,
		l_docs_payable_rec.allow_removing_document_flag,
		l_docs_payable_rec.bank_charge_bearer,
		l_docs_payable_rec.calling_app_doc_unique_ref1,
		l_docs_payable_rec.calling_app_doc_ref_number,
		l_docs_payable_rec.calling_app_id,
		l_docs_payable_rec.document_amount,
		l_docs_payable_rec.document_currency_code,
		l_docs_payable_rec.document_date,
		l_docs_payable_rec.document_description,
		l_docs_payable_rec.document_type,
		l_docs_payable_rec.exclusive_payment_flag,
		l_docs_payable_rec.external_bank_account_id,
		l_docs_payable_rec.internal_bank_account_id,
		l_docs_payable_rec.legal_entity_id,
		l_docs_payable_rec.org_id,
		l_docs_payable_rec.org_type,
		l_docs_payable_rec.pay_proc_trxn_type_code,
		l_docs_payable_rec.payee_party_id,
		l_docs_payable_rec.payee_party_site_id,
		l_docs_payable_rec.payment_amount,
		l_docs_payable_rec.payment_currency_code,
		l_docs_payable_rec.payment_date,
		l_docs_payable_rec.payment_function,
		l_docs_payable_rec.payment_method_code,
		l_docs_payable_rec.payment_reason_code,
		l_docs_payable_rec.payment_reason_comments,
		l_docs_payable_rec.remittance_message1,
		l_docs_payable_rec.remittance_message2,
		l_docs_payable_rec.remittance_message3,
		l_docs_payable_rec.document_payable_id
	FROM
		ce_payment_transactions
	WHERE
		trxn_reference_number = p_trxn_reference_number;

	log('inserting data into iby_docs_payable_gt');

	INSERT INTO IBY_DOCS_PAYABLE_GT(
		ANTICIPATED_VALUE_DATE,
		ALLOW_REMOVING_DOCUMENT_FLAG,
		BANK_CHARGE_BEARER,
		CALLING_APP_DOC_UNIQUE_REF1,
		CALLING_APP_DOC_REF_NUMBER,
		CALLING_APP_ID,
		DOCUMENT_AMOUNT,
		DOCUMENT_CURRENCY_CODE,
		DOCUMENT_DATE,
		DOCUMENT_DESCRIPTION,
		DOCUMENT_PAYABLE_ID,
		DOCUMENT_TYPE,
		EXCLUSIVE_PAYMENT_FLAG,
		EXTERNAL_BANK_ACCOUNT_ID,
		INTERNAL_BANK_ACCOUNT_ID,
		LEGAL_ENTITY_ID,
		ORG_ID,
		ORG_TYPE,
		PAY_PROC_TRXN_TYPE_CODE,
		PAYEE_PARTY_ID,
		PAYEE_PARTY_SITE_ID,
		PAYMENT_AMOUNT,
		PAYMENT_CURRENCY_CODE,
		PAYMENT_DATE,
		PAYMENT_FUNCTION,
		PAYMENT_METHOD_CODE,
		PAYMENT_REASON_CODE,
		PAYMENT_REASON_COMMENTS,
		REMITTANCE_MESSAGE1,
		REMITTANCE_MESSAGE2,
		REMITTANCE_MESSAGE3,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		OBJECT_VERSION_NUMBER)
	VALUES(
		l_docs_payable_rec.anticipated_value_date,
		l_docs_payable_rec.allow_removing_document_flag,
		l_docs_payable_rec.bank_charge_bearer,
		l_docs_payable_rec.calling_app_doc_unique_ref1,
		l_docs_payable_rec.calling_app_doc_ref_number,
		l_docs_payable_rec.calling_app_id,
		l_docs_payable_rec.document_amount,
		l_docs_payable_rec.document_currency_code,
		l_docs_payable_rec.document_date,
		l_docs_payable_rec.document_description,
		l_docs_payable_rec.document_payable_id,
		l_docs_payable_rec.document_type,
		l_docs_payable_rec.exclusive_payment_flag,
		l_docs_payable_rec.external_bank_account_id,
		l_docs_payable_rec.internal_bank_account_id,
		l_docs_payable_rec.legal_entity_id,
		l_docs_payable_rec.org_id,
		l_docs_payable_rec.org_type,
		l_docs_payable_rec.pay_proc_trxn_type_code,
		l_docs_payable_rec.payee_party_id,
		l_docs_payable_rec.payee_party_site_id,
		l_docs_payable_rec.payment_amount,
		l_docs_payable_rec.payment_currency_code,
		l_docs_payable_rec.payment_date,
		l_docs_payable_rec.payment_function,
		l_docs_payable_rec.payment_method_code,
		l_docs_payable_rec.payment_reason_code,
		l_docs_payable_rec.payment_reason_comments,
		l_docs_payable_rec.remittance_message1,
		l_docs_payable_rec.remittance_message2,
		l_docs_payable_rec.remittance_message3,
		NVL(FND_GLOBAL.user_id,-1),
		SYSDATE,
		NVL(FND_GLOBAL.user_id,-1),
		SYSDATE,
		NVL(FND_GLOBAL.user_id,-1),
		1);

		log('calling validate_documents...');
		-- Call iby validate api
		IBY_DISBURSEMENT_COMP_PUB.validate_documents(
				P_API_VERSION => 1.0,
				P_INIT_MSG_LIST => FND_API.G_FALSE,
				P_DOCUMENT_ID  => l_docs_payable_rec.document_payable_id,
				X_RETURN_STATUS => l_return_status,
				X_MSG_COUNT => l_msg_count,
				X_MSG_DATA => l_msg_data);

		p_doc_payable_id := l_docs_payable_rec.document_payable_id;
		p_return_status := l_return_status;

log('<< call_iby_validate... result=' || l_return_status);
EXCEPTION
WHEN OTHERS THEN
log('Exception in call_iby_validate');
--p_return_status := FND_API.G_RET_STS_EXCEPTION;
p_return_status := 'EXCEPTION';
RAISE;
END call_iby_validate;


/* --------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|       check_create_ext_bank_acct
|  DESCRIPTION															|
|	This procedure checks if the destination bank account of a transfer|
|	exists as an external bank account in iby. If it does't exists then |
|	it creates one. This procedure is called from the UI validate action|
|	if settlement is required.
| 	                                                                   |
|  HISTORY                                                              |
|       24-JUL-2005        Shaik Vali		Created                 	|
 --------------------------------------------------------------------- */

PROCEDURE check_create_ext_bank_acct (p_bank_account_id NUMBER,
							  p_ext_bank_account_id OUT NOCOPY NUMBER,
							  p_return_status OUT NOCOPY VARCHAR2)
IS
	l_return_status VARCHAR2(20);
	l_ext_bankacct_rec IBY_EXT_BANKACCT_PUB.Extbankacct_rec_type;
	l_msg_count NUMBER;
	l_msg_data VARCHAR2(1000);
	l_response IBY_FNDCPT_COMMON_PUB.Result_rec_type;
	l_start_date DATE;
	l_end_date DATE;
BEGIN
log('>> check_create_ext_bank_acct');
	SELECT
		bb.bank_home_country,
		bb.branch_party_id,
		bb.bank_party_id,
		ba.account_owner_party_id,
		ba.bank_account_name,
		ba.bank_account_num,
		ba.currency_code,
		ba.iban_number,
		ba.check_digits,
		ba.multi_currency_allowed_flag,
		ba.bank_account_name_alt,
		ba.short_account_name,
		ba.bank_account_type,
		ba.account_suffix,
		ba.description,
		ba.agency_location_code,
		'N',
		'Y'
	INTO
		l_ext_bankacct_rec.COUNTRY_CODE,
		l_ext_bankacct_rec.BRANCH_ID,
		l_ext_bankacct_rec.BANK_ID,
		l_ext_bankacct_rec.ACCT_OWNER_PARTY_ID,
		l_ext_bankacct_rec.BANK_ACCOUNT_NAME,
		l_ext_bankacct_rec.BANK_ACCOUNT_NUM,
		l_ext_bankacct_rec.CURRENCY,
		l_ext_bankacct_rec.IBAN,
		l_ext_bankacct_rec.CHECK_DIGITS,
		l_ext_bankacct_rec.MULTI_CURRENCY_ALLOWED_FLAG,
		l_ext_bankacct_rec.ALTERNATE_ACCT_NAME,
		l_ext_bankacct_rec.SHORT_ACCT_NAME,
		l_ext_bankacct_rec.ACCT_TYPE,
		l_ext_bankacct_rec.ACCT_SUFFIX,
		l_ext_bankacct_rec.DESCRIPTION,
		l_ext_bankacct_rec.AGENCY_LOCATION_CODE,
		l_ext_bankacct_rec.PAYMENT_FACTOR_FLAG,
		l_ext_bankacct_rec.foreign_payment_use_flag -- bug 9088808
	FROM
		ce_bank_accounts ba,
		ce_bank_branches_v bb
	WHERE
		ba.bank_branch_id = bb.branch_party_id
	AND	ba.bank_account_id = p_bank_account_id;

	log('checking if the ext bank account already exists...');
	IBY_EXT_BANKACCT_PUB.check_ext_acct_exist(
		p_api_version => 1.0,
		p_bank_id => l_ext_bankacct_rec.bank_id,
		p_branch_id => l_ext_bankacct_rec.branch_id,
		p_acct_number => l_ext_bankacct_rec.bank_account_num,
		p_acct_name	  => l_ext_bankacct_rec.bank_account_name,
		p_currency => l_ext_bankacct_rec.currency,
		p_country_code => l_ext_bankacct_rec.country_code,
		x_acct_id => p_ext_bank_account_id,
		x_start_date => l_start_date,
		x_end_date => l_end_date,
		x_return_status => l_return_status,
		x_msg_count => l_msg_count,
		x_msg_data => l_msg_data,
		x_response => l_response);

	p_return_status := l_return_status;
	IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		IF p_ext_bank_account_id IS NOT NULL THEN
			-- external bank account already exists
			IF nvl(l_start_date, SYSDATE) <= SYSDATE AND
			   nvl(l_end_date, SYSDATE) >= SYSDATE THEN
					RETURN;
			ELSE
				FND_MESSAGE.set_name('CE','CE_BAT_EXT_BA_END');
				FND_MSG_PUB.add;
				RETURN;
			END IF;
		END IF;
	END IF;

	p_return_status := l_return_status;

	log('creating the ext bank account ...');
	IBY_EXT_BANKACCT_PUB.create_ext_bank_acct(
		P_API_VERSION => 1.0,
		p_INIT_MSG_LIST => FND_API.G_FALSE,
		p_EXT_BANK_ACCT_REC => l_ext_bankacct_rec,
		X_ACCT_ID => p_ext_bank_account_id,
		X_RETURN_STATUS => l_return_status,
		X_MSG_COUNT => l_msg_count,
		X_MSG_DATA  => l_msg_data,
		X_RESPONSE  => l_response);

	p_return_status := l_return_status;
log('<< check_create_ext_bank_acct'||p_return_status);
EXCEPTION
WHEN OTHERS THEN
log('Exception in check_create_ext_bank_acct');
RAISE;
END check_create_ext_bank_acct;


/* --------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|       create_external_payee
|  DESCRIPTION															|
|	This procedure creates is called from the UI on validate action. |
|	The destination LE of a transfer has to created as an external |
|	payee in IBY.
| 	                                                                   |
|  HISTORY                                                              |
|       24-JUL-2005        Shaik Vali		Created                 	|
 --------------------------------------------------------------------- */

PROCEDURE create_external_payee(p_trxn_reference_number NUMBER,
						p_return_status OUT NOCOPY VARCHAR2)
IS
	l_ext_payee_rec IBY_DISBURSEMENT_SETUP_PUB.External_Payee_Rec_Type;
	l_ext_payee_tab IBY_DISBURSEMENT_SETUP_PUB.External_Payee_Tab_Type;
	l_ext_payee_id_rec IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_ID_Rec_Type;
	l_ext_payee_id_tab IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_ID_Tab_Type;
	l_ext_payee_create_rec IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Create_Rec_Type;
	l_ext_payee_create_tab IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Create_Tab_Type;
	l_msg_count NUMBER;
	l_msg_data VARCHAR2(2000);
	l_return_status VARCHAR2(1);
BEGIN
log('>> create_external_payee');
	SELECT
		destination_party_id,
		destination_party_site_id,
		source_legal_entity_id,
		'LEGAL_ENTITY',
		'CASH_PAYMENT',
		'Y'
	INTO
		l_ext_payee_rec.payee_party_id,
		l_ext_payee_rec.payee_party_site_id,
		l_ext_payee_rec.payer_org_id,
		l_ext_payee_rec.payer_org_type,
		l_ext_payee_rec.payment_function,
		l_ext_payee_rec.exclusive_pay_flag
	FROM
		ce_payment_transactions
	WHERE   trxn_reference_number = p_trxn_reference_number;

	l_ext_payee_tab(1) := l_ext_payee_rec;


	IBY_DISBURSEMENT_SETUP_PUB.create_external_payee(
			p_api_version => 1,
			p_init_msg_list => FND_API.G_FALSE,
			p_ext_payee_tab => l_ext_payee_tab,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data,
			x_ext_payee_id_tab => l_ext_payee_id_tab,
			x_ext_payee_status_tab => l_ext_payee_create_tab);

	p_return_status := l_return_status;

log('<< create_external_payee');
EXCEPTION
WHEN OTHERS THEN
	log('Exception in create_external_payee');
	RAISE;
END create_external_payee;

-- Bug 9818163 Start

/* ----------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       SET_PAYEE_INSTR_ASSIGNMENT                                      |
|  DESCRIPTION															                            |
|	This procedure  is called from the UI on validate action.             |
|	It cretaes a relation betwwen the payee and the external bank         |
|	account in IBY.                                                       |
| 	                                                                    |
| HISTORY                                                               |
|     21-JUN-2010     CKANSARA		  Created                 	          |
 --------------------------------------------------------------------- */

PROCEDURE SET_PAYEE_INSTR_ASSIGNMENT(p_trxn_reference_number NUMBER,
            l_ext_bank_account_id NUMBER,
						p_return_status OUT NOCOPY VARCHAR2)
IS
	l_payee_rec IBY_DISBURSEMENT_SETUP_PUB.PayeeContext_Rec_Type;
  l_pay_instr_rec IBY_FNDCPT_SETUP_PUB.PmtInstrument_rec_type;
  l_pay_assign_rec IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
  l_msg_count NUMBER;
  p_commit VARCHAR2(10);
	l_msg_data VARCHAR2(2000);
	l_return_status VARCHAR2(1);
  l_assign_id NUMBER;
  l_response IBY_FNDCPT_COMMON_PUB.Result_rec_type;
BEGIN
  log('>> SET_PAYEE_INSTR_ASSIGNMENT');
  Log ('p_trxn_reference_number = '  || p_trxn_reference_number);
  Log ('l_ext_bank_account_id = '  || l_ext_bank_account_id);

  SELECT
		destination_party_id,
		destination_party_site_id,
		source_legal_entity_id
	INTO
		l_payee_rec.party_id,
		l_payee_rec.party_site_id,
		l_payee_rec.org_id
	FROM
		ce_payment_transactions
	WHERE   trxn_reference_number = p_trxn_reference_number;

  Log ('l_payee_rec.party_id = '  || l_payee_rec.party_id);
  Log ('l_payee_rec.party_site_id = '  || l_payee_rec.party_site_id);
  Log ('l_payee_rec.org_id = '  || l_payee_rec.org_id);

  l_payee_rec.Payment_Function   := 'CASH_PAYMENT';
  l_payee_rec.Supplier_Site_id   := NULL;
  l_payee_rec.Org_Type   := 'LEGAL_ENTITY';

  l_pay_instr_rec.Instrument_Type := 'BANKACCOUNT';
  l_pay_instr_rec.Instrument_Id   := l_ext_bank_account_id;

  l_pay_assign_rec.Instrument   := l_pay_instr_rec;
  l_pay_assign_rec.Priority   := 1;
  l_pay_assign_rec.Start_Date   := sysdate;
  l_pay_assign_rec.End_Date   := NULL;

  Log('Calling IBY API IBY_DISBURSEMENT_SETUP_PUB.Set_Payee_Instr_Assignment.. ');
  IBY_DISBURSEMENT_SETUP_PUB.Set_Payee_Instr_Assignment(
			p_api_version => 1,
			p_init_msg_list => FND_API.G_FALSE,
      p_commit => FND_API.G_TRUE,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data,
			p_payee => l_payee_rec,
      p_assignment_attribs => l_pay_assign_rec,
      x_assign_id => l_assign_id,
      x_response => l_response);

	p_return_status := l_return_status;

  Log ('p_return_status = ' || p_return_status);
  log('<< SET_PAYEE_INSTR_ASSIGNMENT');

EXCEPTION

WHEN OTHERS THEN
	log('Exception in SET_PAYEE_INSTR_ASSIGNMENT');
	RAISE;

END SET_PAYEE_INSTR_ASSIGNMENT;

-- Bug 9818163 End



/* --------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|       iby_validations
|  DESCRIPTION															|
|	This procedure summarizes all the validations required for a transfer|
|	when settlement is required. This procedures does the following:|
|	1)Checks and creates an external bank account in IBY for the |
|	   destination bank acount of the transfer.
|	2)Creates an external payee in IBY for the destination LE of the|
|	  transfer.
|	3)Calls IBY's online validations api.
| 	                                                                   |
|  HISTORY                                                              |
|       24-JUL-2005        Shaik Vali		Created                 	|
 --------------------------------------------------------------------- */

PROCEDURE iby_validations(p_bank_account_id NUMBER,
				  p_trxn_reference_number NUMBER,
				  p_result OUT NOCOPY VARCHAR2)
IS
	l_return_status VARCHAR2(20);
	l_ext_bank_account_id NUMBER;
	l_doc_payable_id NUMBER;
	l_cnt NUMBER;
BEGIN
log('>> iby_validations');
	-- check and create the external bank account
	check_create_ext_bank_acct(p_bank_account_id,
						   l_ext_bank_account_id,
						   l_return_status);

	IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		UPDATE ce_payment_transactions
		SET ext_bank_account_id = l_ext_bank_account_id
		WHERE trxn_reference_number = p_trxn_reference_number;

		p_result := 'SUCCESS';
	ELSE
		p_result := 'FAILURE';
		RETURN;
	END IF;

	-- create the external payee
	log('creating external payee..');
	create_external_payee(p_trxn_reference_number,
				      l_return_status);

	IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		p_result := 'SUCCESS';
	ELSE
		p_result := 'FAILURE';
		RETURN;
	END IF;
	-- Bug 9818163 Start

	log('Creating Relation between payee and any external bank account');

	SET_PAYEE_INSTR_ASSIGNMENT (p_trxn_reference_number,
							  l_ext_bank_account_id,
							  l_return_status);
	IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		p_result := 'SUCCESS';
	ELSE
		p_result := 'FAILURE';
		RETURN;
	END IF;

	-- Bug 9818163 End

	-- call the IBY's validation API
	log('calling iby validations..');
	call_iby_validate(p_trxn_reference_number,
				  l_doc_payable_id,
				  l_return_status);

	IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		p_result := 'SUCCESS';
	ELSE
		p_result := 'FAILURE';
	END IF;
log('<< iby_validations result=' || p_result);
EXCEPTION
WHEN OTHERS THEN
log('Exception in iby_validations');
p_result := 'FAILURE';
RAISE;
END iby_validations;


PROCEDURE cancel_cashflow(
	p_cashflow_id	NUMBER,
	p_result OUT NOCOPY VARCHAR2
	)
IS

  l_cashflow_id NUMBER;

BEGIN
	log('>>cancel cashflow');
	l_cashflow_id := p_cashflow_id;
	log('cashflow id '|| l_cashflow_id);

	log('calling XLA cancel event...'|| l_cashflow_id);
   	  -- call the XLA API to cancel the BAT
	  CE_XLA_ACCT_EVENTS_PKG.create_event
		(l_cashflow_id,'CE_STMT_CANCELED');

	-- Update the cashflows status to CANCELED
	UPDATE ce_cashflows
	SET	cashflow_status_code = 'CANCELED'
	WHERE	cashflow_id = l_cashflow_id;

/*bug4997215*/
	-- Update statement line to nullify the cashflow id
	UPDATE ce_statement_lines
	SET cashflow_id = null,
	    je_status_flag = null
	WHERE cashflow_id = l_cashflow_id;
	p_result := 'SUCCESS';
	log('<<cancel cashflow');
EXCEPTION
  WHEN OTHERS THEN
	p_result := 'FAIL';
	log('Exception in cancel_cashflow');
	RAISE;
END cancel_cashflow;


PROCEDURE create_update_cashflows(p_trxn_reference_number NUMBER,
				  p_mode OUT NOCOPY VARCHAR2,
				  p_cashflow_id1 OUT NOCOPY NUMBER,
				  p_cashflow_id2 OUT NOCOPY NUMBER)
IS
BEGIN
	log('>>create_update_cashflows..');
	log('>>creating cashflows..');
	--create cashflows
	CE_BAT_UTILS.transfer_payment_transaction(
			p_trxn_reference_number,
			G_multi_currency_flag,
			p_mode,
			p_cashflow_id1,
			p_cashflow_id2);

	UPDATE ce_statement_lines
	set cashflow_id=p_cashflow_id1
	WHERE statement_line_id=G_sl_statement_line_id;

	log('<<..create_update_cashflows');
EXCEPTION
WHEN OTHERS THEN
	log('Exception in create_update_cashflows..');
RAISE;
END create_update_cashflows;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       validate_foreign_currency                                       |
|  DESCRIPTION                                                          |
|      This procedure is called by the UI while creating a transfer for |
|      checking that the currencies for both accounts involved in bank  |
|      account transfers are not non-functional(bug 6046852)		|
| HISTORY                                                               |
|       13-JUL-2007        Varun Netan      Created                     |
|       07-FEB-2008        kbabu            Modified for bug 6455698    |
 --------------------------------------------------------------------- */
PROCEDURE validate_foreign_currency(
    p_source_le_id  NUMBER,
    p_destination_le_id NUMBER,
    p_source_ba_id VARCHAR2,
    p_destination_ba_id VARCHAR2,
    p_pmt_currency VARCHAR2,  --for bug 6455698
    p_error_code  OUT NOCOPY VARCHAR2  --for bug 6455698
    )
IS
  l_source_ledger_id NUMBER := NULL;
  l_destination_ledger_id NUMBER := NULL;
  l_source_ba_currency_code CE_BANK_ACCOUNTS.currency_code%TYPE := NULL;
  l_destination_ba_currency_code CE_BANK_ACCOUNTS.currency_code%TYPE := NULL;
  l_source_ledger_curr  GL_LEDGERS.currency_code%TYPE := NULL;
  l_destination_ledger_curr  GL_LEDGERS.currency_code%TYPE := NULL;

BEGIN
    log('>> validate_foreign_currency.....');
    p_error_code := NULL;

    -- Get the bank account currencies for source/destination
    SELECT currency_code
    INTO l_source_ba_currency_code
    FROM ce_bank_accounts
    WHERE bank_account_id = p_source_ba_id;

    SELECT currency_code
    INTO l_destination_ba_currency_code
    FROM ce_bank_accounts
    WHERE bank_account_id = p_destination_ba_id;

    --Transaction currency is the same as the bank account currency on both sides
    --then it is valid bat
    If (p_pmt_currency = l_source_ba_currency_code) and
       (p_pmt_currency = l_destination_ba_currency_code) then
	p_error_code := NULL;
	RETURN;
    END IF;

    --Get the ledger currencies for source/destination
    l_source_ledger_id := CE_BAT_UTILS.get_ledger_id(p_source_le_id);
    l_destination_ledger_id:=CE_BAT_UTILS.get_ledger_id(p_destination_le_id);
    SELECT currency_code
    INTO l_source_ledger_curr
    FROM gl_ledgers
    WHERE ledger_id=l_source_ledger_id;

    SELECT currency_code
    INTO l_destination_ledger_curr
    FROM gl_ledgers
    WHERE ledger_id=l_destination_ledger_id;

    IF p_pmt_currency = l_source_ba_currency_code  THEN
	IF l_destination_ledger_curr <> l_destination_ba_currency_code THEN
	  p_error_code := 'CE_BAT_INVALID_DEST_BANK';
	  RETURN;
        END IF;
    ELSIF p_pmt_currency = l_destination_ba_currency_code  THEN
	IF l_source_ledger_curr <> l_source_ba_currency_code THEN
	  p_error_code := 'CE_BAT_INVALID_SRC_BANK';
	  RETURN;
        END IF;
    ELSE
       -- Transaction currency should be either Source bank account currency or Destination bank account currency.
	p_error_code := 'CE_BAT_INVALID_CURRENCY';
        RETURN;
    END IF;

    log('<< validate_foreign_currency');
EXCEPTION
  WHEN OTHERS THEN
    p_error_code := 'FAILURE';
    log('Exception in validate_foreign_currency');
    RAISE;
END validate_foreign_currency;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       check_gl_period                                                 |
|  DESCRIPTION                                                          |
|      This procedure is called by the UI while creating a transfer for |
|      checking that the bank transfer date lies in an Open GL period   |
| HISTORY                                                               |
|       15-MAY-2009    vnetan   Created for bug 8459147                 |
 --------------------------------------------------------------------- */
PROCEDURE check_gl_period(
    p_date		     DATE,
    p_source_le_id   NUMBER,
    p_destination_le_id NUMBER,
    x_period_status  OUT NOCOPY VARCHAR2)
IS
    dummy NUMBER;
    l_src_ledger_id NUMBER;
    l_dest_ledger_id NUMBER;
BEGIN
    cep_standard.debug('>>CE_BAT_API.check_gl_period');
    x_period_status := 'C';

    -- fetch the set_of_books_id
    SELECT ledger_id
    INTO l_src_ledger_id
    FROM gl_ledger_le_v
    WHERE legal_entity_id = p_source_le_id
    AND ledger_category_code = 'PRIMARY';

    SELECT ledger_id
    INTO l_dest_ledger_id
    FROM gl_ledger_le_v
    WHERE legal_entity_id = p_destination_le_id
    AND ledger_category_code = 'PRIMARY';

    cep_standard.debug('l_src_ledger_id='||l_src_ledger_id);
    cep_standard.debug('l_dest_ledger_id='||l_dest_ledger_id);

    -- Check if period is open or future enterable
    BEGIN
        SELECT 1
        INTO   dummy
        FROM   gl_period_statuses
        WHERE  application_id = 101
        AND    set_of_books_id = l_src_ledger_id
        AND    adjustment_period_flag = 'N'
        AND    closing_status in ('O','F')
        AND    p_date between start_date and end_date;

        cep_standard.debug('Source period is open');

        SELECT 1
        INTO   dummy
        FROM   gl_period_statuses
        WHERE  application_id = 101
        AND    set_of_books_id = l_dest_ledger_id
        AND    adjustment_period_flag = 'N'
        AND    closing_status in ('O','F')
        AND    p_date between start_date and end_date;

        cep_standard.debug('Destination period is open');
        cep_standard.debug('Both periods are open');
        x_period_status := 'O';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        cep_standard.debug('Either or both periods are not open');
        x_period_status := 'C';
    END;
    cep_standard.debug('x_period_status='||x_period_status);
    cep_standard.debug('<<CE_BAT_API.check_gl_period');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        cep_standard.debug('Period info not available');
        x_period_status := 'C';
    WHEN OTHERS THEN
        cep_standard.debug('EXCEPTION: CE_BAT_API.check_gl_period:OTHERS');
        RAISE;
END check_gl_period;

END CE_BAT_API;


/
