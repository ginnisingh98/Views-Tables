--------------------------------------------------------
--  DDL for Package Body CE_BAT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_BAT_UTILS" as
/* $Header: cebtutlb.pls 120.20.12010000.4 2009/09/04 10:52:46 ckansara ship $ */

   --Get the payment transaction

	CURSOR f_row_cursor (p_reference_number NUMBER) IS

		SELECT  TRXN_REFERENCE_NUMBER,
			TRXN_SUBTYPE_CODE_ID,
			TRANSACTION_DATE,
			ANTICIPATED_VALUE_DATE,
			TRANSACTION_DESCRIPTION,
			PAYMENT_CURRENCy_CODE,
			PAYMENT_AMOUNT,
			SOURCE_PARTY_ID,
			SOURCE_LEGAL_ENTITY_ID,
			SOURCE_BANK_ACCOUNT_ID,
			DESTINATION_PARTY_ID,
			DESTINATION_LEGAL_ENTITY_ID,
			DESTINATION_BANK_ACCOUNT_ID,
			CREATED_FROM_DIR,
			CREATE_FROM_STMTLINE_ID,
			BANK_TRXN_NUMBER,
			PAYMENT_OFFSET_CCID,
			RECEIPT_OFFSET_CCID
		FROM
			CE_PAYMENT_TRANSACTIONS
		WHERE
			trxn_reference_number = p_reference_number;


FUNCTION body_revision RETURN VARCHAR2 IS
BEGIN

      RETURN '$Revision: 120.20.12010000.4 $';

END body_revision;

FUNCTION spec_revision RETURN VARCHAR2 IS
BEGIN

      RETURN G_spec_revision;

END spec_revision;

PROCEDURE log(p_char varchar2) is
begin
	--dbms_output.put_line(p_char);
	cep_standard.debug(p_char);

end;

/*----------------------------------------------------------------------
|  PUBLIC FUNCTION                                                    |
|       get_exchange_rate_type                                       	|
|                                                                       |
|  DESCRIPTION                                                          |
|       Returns the cashflow exchange rate type 			|
|									|
 -----------------------------------------------------------------------*/

FUNCTION get_exchange_rate_type(p_le_id number) RETURN VARCHAR2 IS

l_exchange_rate_type 	VARCHAR2(30);
BEGIN
log('>> get_exchange_rate_type');
	select cashflow_exchange_rate_type
	into l_exchange_rate_type
	from ce_system_parameters
	where legal_entity_id = p_le_id;
log(' type '||l_exchange_rate_type);
log('<< get_exchange_rate_type');
	return (l_exchange_rate_type);
EXCEPTION
	WHEN OTHERS THEN
		Return null;

END get_exchange_rate_type;


/*----------------------------------------------------------------------
|  PUBLIC PROCEDURE	                                                |
|       get_exchange_rate_date	                                        |
|                                                                       |
|  DESCRIPTION                                                          |
|      Returns the cashflow exchange date and cashflow exchange rate	|
|      In case of zba if its foreign scenario then if date type in 	|
|      AVD or CLD then rate and date is null otherwise corresponding 	|
|      rate will be populated. If international sceanrio then 		|
|       rate/date/type from ce_statement_lines will be populated.	|
|      If bat/cl then in foreign scenario if date type in CFD or TRX 	|
|      then corresponding date and rate is populated else rate and date	|
|      will be null							|
------------------------------------------------------------------------*/
PROCEDURE get_exchange_rate_date(p_ledger_id number,
			   	 p_bank_account_id number,
				 p_legal_entity_id number,
			   	 p_exch_type IN OUT NOCOPY varchar2,
			   	 p_exchange_date OUT NOCOPY date,
			   	 p_exchange_rate OUT NOCOPY number)  IS

ledger_currency_code	varchar2(15);
bank_currency_code		varchar2(15);
p_exchange_date_type		varchar2(10);
p_exch_rate			number:=null;
p_exch_date			date;

BEGIN
log('>>get_exchange_rate_date');

	--get the ledger currency code
	gl_mc_info.get_ledger_currency(p_ledger_id,ledger_currency_code);

	--get the bank account currency
	select currency_code
	into bank_currency_code
	from ce_bank_accounts
	where bank_account_id = p_bank_account_id;

	--get the exchange date type
	p_exchange_date_type := get_exchange_date_type(p_legal_entity_id);



	--check if zba or bat/cl
	if(G_created_from_stmtline_id is not null) then --zba case

	--check if foreign scenario or international scenario
		if ((G_payment_curr_code = bank_currency_code) and
			(bank_currency_code <> ledger_currency_code)) then --foreign scenario

			if(p_exchange_date_type in ('AVD','CLD')) then
				p_exch_date	:=null;
				p_exch_rate	:=null;

			elsif (p_exchange_date_type = 'CFD') then
				p_exch_date:=nvl(G_anticipated_value_date,G_transaction_date);

			elsif (p_exchange_date_type = 'BSD') then
				begin
					select statement_date
					into p_exch_date
					from ce_statement_headers sh,
		                        ce_statement_lines	sl
					where sh.statement_header_id = sl.statement_header_id
					and sl.statement_line_id = G_created_from_stmtline_id;
				exception
					when others then
					null;
				end;
			elsif (p_exchange_date_type = 'BSG') then
				begin
					select gl_date
					into p_exch_date
					from ce_statement_headers sh,
		                        ce_statement_lines	sl
					where sh.statement_header_id = sl.statement_header_id
					and sl.statement_line_id = G_created_from_stmtline_id;
				exception
					when others then
					null;
				end;
			elsif (p_exchange_date_type = 'SLD') then
				begin
					select trx_date
					into p_exch_date
					from ce_statement_lines sl
					where sl.statement_line_id = G_created_from_stmtline_id;
				exception
					when others then
					null;
				end;

			elsif (p_exchange_date_type = 'TRX') then
				p_exch_date:=G_transaction_date;

			elsif (p_exchange_date_type is null) then
				p_exch_date := null;
				p_exch_rate := null;
			end if;
			if (p_exch_date is not null) then
				p_exch_rate:=gl_currency_api.get_rate(G_payment_curr_code,
					       			       ledger_currency_code,
		   						       p_exch_date,
					       			       p_exch_type);
			end if;

		--if its an international scenario
		elsif ((G_payment_curr_code <> bank_currency_code) and (bank_currency_code = ledger_currency_code)) then
			begin
				select exchange_rate,
				       exchange_rate_type,
				       exchange_rate_date
				into   p_exch_rate,
				       p_exch_type,
				       p_exch_date
				from ce_statement_lines
				where statement_line_id = G_created_from_stmtline_id;

			exception
				when others then
				null;
			end;

		else	--domestic scenario
			p_exch_date:= null;
			p_exch_rate:= null;
			p_exch_type:=null;
		end if; --end of zba scenario

	--if bat/cl scenario
	elsif (G_created_from_stmtline_id is null) then

	--check if foreign or international scenario

	    if (G_payment_curr_code <> ledger_currency_code) then

		if (p_exchange_date_type in ('CFD','TRX')) then
			if (p_exchange_date_type = 'CFD') then
				p_exch_date:=nvl(G_anticipated_value_date,G_transaction_date);
			else
				p_exch_date:=G_transaction_date;
			end if;
			if (p_exch_date is not null) then
				p_exch_rate:=gl_currency_api.get_rate(G_payment_curr_code,
					       			       ledger_currency_code,
		   						       p_exch_date,
					       			       p_exch_type);
			end if;
		else
			p_exch_date:= null;
			p_exch_rate:= null;
		end if;

	   else  --domestic scenario
			p_exch_date:= null;
			p_exch_rate:= null;
			p_exch_type:=null;

	   end if; --foreign scenario ended

	end if;--zba or bat/cl ended


log('exchange rate '||p_exch_rate);
log('exchange date '||p_exch_date);
log('<< get_exchange_rate');
		p_exchange_rate:= p_exch_rate;
		p_exchange_date:= p_exch_date;
EXCEPTION
	when others then
	FND_MESSAGE.SET_NAME('CE','CE_INCOMPLETE_USER_RATE');
	FND_MSG_PUB.ADD;
	log('exception in get_exchange_rate_date');
	p_exchange_rate:=null;
	p_exchange_date:=null;
	RAISE; -- Bug 8869718

END get_exchange_rate_date;


/*----------------------------------------------------------------------
|  PUBLIC FUNCTION                                                   |
|       get_exchange_date_type                                        |
|                                                                       |
|  DESCRIPTION                                                          |
|      Returns the cashflow exchange date type				|
|									|
 -----------------------------------------------------------------------*/
FUNCTION get_exchange_date_type(p_le_id NUMBER) RETURN VARCHAR2 IS

l_exchange_date_type 	VARCHAR2(30);
BEGIN
   log('>> get_exchange_date_type');
	select bat_exchange_date_type
	into l_exchange_date_type
	from ce_system_parameters
	where legal_entity_id = p_le_id;

log(' type '||l_exchange_date_type);
log('<< get_exchange_date_type');
	return (l_exchange_date_type);
EXCEPTION
	WHEN OTHERS THEN
	log('exception in get_exchange_rate_type');
	Return NULL;

END get_exchange_date_type;


/*----------------------------------------------------------------------
|  PUBLIC FUNCTION	                                                |
|	get_ledger_id	                                 	        |
|                                                                       |
|  DESCRIPTION                                                          |
|      Returns the ledger id for a given legal entity id.
|
|              A given LE can be linked to many types of ledgers:
|
|              a. Primary Ledger      [Only one possible for a given LE]
|              b. Secondary Ledger    [Many possible for a given LE]
|              c. ALC Ledger          [Many possible for a given LE]
|                           Therefore, it is possible to uniquely derive the id
|              of the primary ledger from the given LE id.
|
|
|            Get the primary ledger id for the given LE.
|             The ledger id was formerly known as the
|             set of books id.
|									|
 -----------------------------------------------------------------------*/


FUNCTION get_ledger_id (l_le_id  NUMBER) RETURN NUMBER IS

l_ledger_list 	GL_MC_INFO.ledger_tbl_type:= GL_MC_INFO.ledger_tbl_type();
l_ledger_id   	NUMBER(15);
l_ret_val	BOOLEAN;

BEGIN
log('>> get_ledger_id');
l_ledger_list := GL_MC_INFO.ledger_tbl_type();


            l_ret_val := GL_MC_INFO.get_le_ledgers
                             ( p_legal_entity_id     => l_le_id
                             , p_get_primary_flag    => 'Y'
                             , p_get_secondary_flag  => 'N'
                             , p_get_alc_flag        => 'N'
                             , x_ledger_list         => l_ledger_list
                             );

             -- Check if return status is a success.
             -- Otherwise raise error.
             --

            IF (l_ret_val <> TRUE) THEN

               l_ledger_id := -1;

            ELSIF (l_ledger_list.COUNT = 0) THEN

               l_ledger_id := -1;

            ELSE

		l_ledger_id:=l_ledger_list(1).ledger_id;

            END IF;
log('ledger_id '||l_ledger_id);
log('<< get_ledger_id');
		return (l_ledger_id);
EXCEPTION
	WHEN OTHERS THEN
	log('exception in get_ledger_id');
	RAISE;

END get_ledger_id;


  /* ---------------------------------------------------------------------
|  PUBLIC FUNCTION                                                     	 |
|       get_accounting_status                                  			 |
|                                                                        |
|  DESCRIPTION                                                           |
|       returns the accounting status of a cashflow						 |
|																 |
 -----------------------------------------------------------------------*/

FUNCTION get_accounting_status(p_cashflow_number	NUMBER) RETURN VARCHAR2 is
p_temp 	  number:=0;
p_status  varchar2(30);
begin
log('>> get_accounting_status');
		 	 select count(1)
			 into p_temp
			 from ce_cashflow_acct_h
			 where cashflow_id = p_cashflow_number
			 and status_code = 'ACCOUNTING_ERROR';

			 if (p_temp <> 0 ) then
log('status accounting_error');
			 	return  ('ACCOUNTING_ERROR');
			 else
			 	 select count(1),status_code
				 into p_temp,p_status
				 from ce_cashflow_acct_h
				 where cashflow_id = p_cashflow_number
				 group by status_code;

log('status '||p_status);
log('<< get_accounting_status');
				 return p_status;
			end if;
EXCEPTION
		WHEN NO_DATA_FOUND THEN
		log('no data found exception so returning status not_applicable');
		return('UNACCOUNTED');
		 WHEN TOO_MANY_ROWS THEN
		log('exception in get_accounting_status returning partial_accounted');
		 	  return ('PARTIAL_ACCOUNTED');
END get_accounting_status;

  /* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       call_payment_process_request                                    |
|                                                                       |
|  DESCRIPTION                                                          |
|       Calls the Oracle Payments submit payment process request API    |
|									|
 -----------------------------------------------------------------------*/

PROCEDURE call_payment_process_request ( p_payment_request_id    NUMBER,
					 p_request_id	OUT NOCOPY NUMBER
					 ) is

  l_request_id		NUMBER;

BEGIN
log('>> call_payment_process_request');
	G_payment_request_id := p_payment_request_id;

	--call the Payments API

	l_request_id := FND_REQUEST.submit_request (
					'IBY',
					'IBYBUILD',
					'',
					'',
					FALSE,
					'260',
					to_char(p_payment_request_id)
					);

	p_request_id:=l_request_id;
log('request id is '|| p_request_id);
log('<< call_payment_process_request');
EXCEPTION
	WHEN others THEN
log('exception in call_payment_process_request');
	p_request_id:=0;
END call_payment_process_request;


PROCEDURE get_intercompany_ccid (p_from_le_id NUMBER,
						 p_to_le_id NUMBER,
						 p_from_cash_gl_ccid NUMBER,
						 p_to_cash_gl_ccid NUMBER,
						 p_transfer_date DATE,
						 p_acct_type VARCHAR2,
			             p_status OUT NOCOPY VARCHAR2,
			             p_msg_count OUT NOCOPY NUMBER,
			             p_msg_data OUT NOCOPY VARCHAR2,
			             p_ccid OUT NOCOPY NUMBER,
			             p_reciprocal_ccid OUT NOCOPY NUMBER,
			             p_result OUT NOCOPY VARCHAR2)
IS
  l_from_ledger_id NUMBER;
  l_to_ledger_id NUMBER;
  l_from_bsv VARCHAR2(1000);
  l_to_bsv VARCHAR2(1000);
BEGIN

  l_from_ledger_id := get_ledger_id(p_from_le_id);
  l_to_ledger_id := get_ledger_id(p_to_le_id);
  l_from_bsv := get_bsv(p_from_cash_gl_ccid,l_from_ledger_id);
  l_to_bsv := get_bsv(p_to_cash_gl_ccid,l_to_ledger_id);

  FUN_BAL_UTILS_GRP.get_inter_intra_account (
             p_api_version =>1.0,
             p_init_msg_list=>null,
             p_ledger_id=>l_from_ledger_id,
	     p_to_ledger_id=>l_to_ledger_id,
             p_from_bsv => l_from_bsv,
             p_to_bsv  => l_to_bsv,
             p_source => 'Cash Management',
             p_category => 'Bank Transfers',
             p_gl_date => p_transfer_date,
             p_acct_type  => p_acct_type,
             x_status  => p_status,
             x_msg_count => p_msg_count,
             x_msg_data => p_msg_data,
             x_ccid => p_ccid,
             x_reciprocal_ccid => p_reciprocal_ccid);

  IF (p_status = 'E') THEN
	p_result := 'NO_INTERCOMPANY_CCID';
	return;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
	p_result := 'FAIL';
END get_intercompany_ccid;


FUNCTION get_bsv (p_cash_ccid NUMBER,
		   p_ledger_id NUMBER)
RETURN VARCHAR2
IS
  l_dist_segments            	FND_FLEX_EXT.SEGMENTARRAY ;
  l_segments                 	FND_FLEX_EXT.SEGMENTARRAY ;
  l_num_of_segments     	    NUMBER;
  l_result                   	BOOLEAN;
  l_coa_id                   	NUMBER;
  l_flex_segment_num     		NUMBER;

BEGIN
  SELECT chart_of_accounts_id
  INTO   l_coa_id
  FROM   gl_sets_of_books
  WHERE  set_of_books_id = p_ledger_id;

  -- Get the segments of the two given accounts
  IF (NOT FND_FLEX_EXT.GET_SEGMENTS('SQLGL', 'GL#',
                                    l_coa_id,
                                    p_cash_ccid,
                                    l_num_of_segments,
                                    l_dist_segments)
     ) THEN
    -- Return -1 if flex failed
    RETURN (-1);
  END IF;
  IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                              101, 'GL#',
                              l_coa_id,
                              'GL_BALANCING',
                              l_flex_segment_num)
     ) THEN
    RETURN (-1);
  END IF;
  FOR i IN 1.. l_num_of_segments LOOP
    IF (i = l_flex_segment_num) THEN
        RETURN(l_dist_segments(i));
    END IF;
  END LOOP;

END Get_bsv;


  /* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       transfer_payment_transaction                                    |
|                                                                       |
|  DESCRIPTION                                                          |
|       Creates cashflows on the base of the values in payment 			|
|	transactions    												|
|																|
 -----------------------------------------------------------------------*/

PROCEDURE transfer_payment_transaction ( p_trxn_reference_number     		 NUMBER,
					 p_multi_currency			 VARCHAR2,
					 p_mode			OUT NOCOPY	 VARCHAR2,
					 p_cashflow_id1		OUT NOCOPY	 NUMBER,
					 p_cashflow_id2		OUT NOCOPY	 NUMBER) is


  type t_cashflow is table of ce_cashflows.cashflow_id%type;
  type t_objectversion is table of ce_cashflows.object_version_number%type;
  type t_rowid is table of varchar2(30);

l_cashflow   		t_cashflow;
l_objectversion 	t_objectversion;
l_rowid			t_rowid;

p_pay_exch_rate_type	VARCHAR2(30);
p_recp_exch_rate_type	VARCHAR2(30);
p_source_dir			VARCHAR2(30);
p_dest_dir			VARCHAR2(30);
l_row_id			VARCHAR2(30) := null;
p_cashflow_id			NUMBER;
p_pay_exchange_rate		NUMBER;
p_recp_exchange_rate		NUMBER;
p_pay_exch_date			DATE;
p_recp_exch_date		DATE;
p_pay_base_amount		NUMBER;
p_recp_base_amount		NUMBER;
p_source_ledger_id		NUMBER;
p_dest_ledger_id		NUMBER;
p_source_offset			NUMBER;
p_dest_offset			NUMBER;
p_objectversion1		NUMBER;
p_objectversion2		NUMBER;
l_mode				VARCHAR2(10);
p_count				NUMBER;
-- Bug 8627837
p_cashflow_amount		NUMBER;
--bug 8358259 start
precision		    NUMBER default NULL;
ext_precision		NUMBER default NULL;
min_acct_unit		NUMBER default NULL;
--bug 8358259 end

BEGIN
log('>> transfer_payment_transaction');
	OPEN f_row_cursor (p_trxn_reference_number);
	FETCH
		f_row_cursor
	INTO
		G_trxn_reference_number,
		G_trxn_subtype_code_id,
		G_transaction_date,
		G_anticipated_value_date,
		G_transaction_desc,
		G_payment_curr_code,
		G_payment_amount,
		G_source_party_id,
		G_source_le_id,
		G_source_bank_acct_id,
		G_dest_party_id,
		G_dest_le_id,
		G_dest_bank_acct_id,
		G_created_from_dir,
		G_created_from_stmtline_id,
		G_bank_trxn_number,
		G_payment_offset_ccid,
		G_receipt_offset_ccid;

	--calculate all the necessary parameters.


	p_source_ledger_id    := get_ledger_id(G_source_le_id);
	p_dest_ledger_id      := get_ledger_id(G_dest_le_id);

	--bug 8358259 start
    FND_CURRENCY.get_info(G_payment_curr_code,
				 precision,
				 ext_precision,
				 min_acct_unit);
    log('precision = '||  precision);
	--bug 8358259 end
	-- Bug 8627837
	p_cashflow_amount:= round(G_payment_amount,precision);
	--if multicurrency then calculate exchange information
	if (p_multi_currency = 'N') then
		p_pay_exch_rate_type  := get_exchange_rate_type(G_source_le_id);
		p_recp_exch_rate_type := get_exchange_rate_type(G_dest_le_id);

		get_exchange_rate_date( p_source_ledger_id,
			  	G_source_bank_acct_id,
				G_source_le_id,
			        p_pay_exch_rate_type,
			        p_pay_exch_date,
			        p_pay_exchange_rate);

		get_exchange_rate_date( p_dest_ledger_id,
			  	G_dest_bank_acct_id,
				G_dest_le_id,
			  	p_recp_exch_rate_type,
			  	p_recp_exch_date,
			  	p_recp_exchange_rate);

    --bug 8358259 start
    p_pay_base_amount     := round(G_payment_amount*nvl(p_pay_exchange_rate,1),precision);
	p_recp_base_amount    := round(G_payment_amount*nvl(p_recp_exchange_rate,1),precision);
    --bug 8358259 end

	--if same currency then exchange information should be null
	else
		p_pay_exch_rate_type  := null;
		p_recp_exch_rate_type := null;
		p_pay_exch_date		  := null;
		p_pay_exchange_rate	  := null;
		p_recp_exch_date	  := null;
		p_recp_exchange_rate  := null;
		p_pay_base_amount     := round(G_payment_amount,precision);     --bug  8358259
		p_recp_base_amount	  := round(G_payment_amount,precision);     --bug 8358259
	end if;

log('values to be inserted in cashfows are');
log('source ledger id '|| p_source_ledger_id);
log('dest ledger id '|| p_dest_ledger_id);
log('pay exchange rate type '|| p_pay_exch_rate_type);
log('recp exchange rate type '|| p_recp_exch_rate_type);
log('pay exchange rate '|| p_pay_exchange_rate);
log('recp exchange rate '|| p_recp_exchange_rate);
log('pay base amount '|| p_pay_base_amount);
log('recp base amount '|| p_recp_base_amount);


	IF (G_created_from_dir = 'PAYMENT') THEN
		p_source_dir 	:= 'PAYMENT';
		p_source_offset	:= G_payment_offset_ccid;
		p_dest_dir		:= 'RECEIPT';
		p_dest_offset	:= G_receipt_offset_ccid;
	ELSE
		p_source_dir	:='RECEIPT';
		p_source_offset := G_payment_offset_ccid;
		p_dest_dir		:= 'PAYMENT';
		p_dest_offset	:= G_receipt_offset_ccid;
	END IF;

	--check if its in insert or update mode
	BEGIN
		SELECT COUNT(*)
		INTO p_count
		FROM CE_CASHFLOWS
		WHERE TRXN_REFERENCE_NUMBER = p_trxn_reference_number;

		IF ( p_count <> 0 ) THEN
		    l_mode := 'UPDATE';
		ELSE
		    l_mode := 'INSERT';
		END IF;

	EXCEPTION
		WHEN OTHERS THEN
		NULL;
	END;

	IF (l_mode = 'INSERT') THEN

	--insert a source cashflow

	CE_CASHFLOWS_PKG.insert_row (
					X_ROWID			       		   => l_row_id,
					X_CASHFLOW_ID		       	   => p_cashflow_id1,
					X_CASHFLOW_LEDGER_ID 	       => p_source_ledger_id,
					X_CASHFLOW_LEGAL_ENTITY_ID     => G_source_le_id,
					X_CASHFLOW_BANK_ACCOUNT_ID     => G_source_bank_acct_id,
					X_CASHFLOW_DIRECTION	       => p_source_dir,
					X_CASHFLOW_CURRENCY_CODE       => G_payment_curr_code,
					X_CASHFLOW_DATE		           => G_transaction_date,
					X_CASHFLOW_AMOUNT	       	   => p_cashflow_amount, -- Bug 8627837 G_payment_amount,
					X_BASE_AMOUNT		           => p_pay_base_amount,
					X_DESCRIPTION		           => G_transaction_desc,
					X_CASHFLOW_EXCHANGE_RATE       => p_pay_exchange_rate,
					X_CASHFLOW_EXCHANGE_DATE       => p_pay_exch_date,
					X_CASHFLOW_EXCHANGE_RATE_TYPE  => p_pay_exch_rate_type,
					X_TRXN_REFERENCE_NUMBER	       => G_trxn_reference_number,
					X_BANK_TRXN_NUMBER	           => G_bank_trxn_number,
					X_SOURCE_TRXN_TYPE	           => 'BAT',
					X_SOURCE_TRXN_SUBTYPE_CODE_ID  => G_trxn_subtype_code_id,
					X_STATEMENT_LINE_ID	           => G_created_from_stmtline_id,
					X_ACTUAL_VALUE_DATE	           => null,
					X_COUNTERPARTY_PARTY_ID	       => G_dest_party_id,
					X_COUNTERPARTY_BANK_ACCOUNT_ID => G_dest_bank_acct_id,
					X_OFFSET_CCID		           => p_source_offset,
					X_CASHFLOW_STATUS_CODE	       => 'CREATED',
					X_CLEARED_DATE		           => null,
					X_CLEARED_AMOUNT	           => null,
					X_CLEARED_EXCHANGE_RATE	       => null,
					X_CLEARED_EXCHANGE_DATE	       => null,
					X_CLEARED_EXCHANGE_RATE_TYPE   => null,
					X_CLEARING_CHARGES_AMOUNT      => null,
					X_CLEARING_ERROR_AMOUNT	       => null,
					X_CLEARED_BY_FLAG	           => null,
					X_REFERENCE_TEXT	           => null,
					X_BANK_ACCOUNT_TEXT			   => null,
					X_CUSTOMER_TEXT				   => null,
					X_CREATED_BY		           => nvl(fnd_global.user_id, -1),
					X_CREATION_DATE		           => sysdate,
					X_LAST_UPDATED_BY	           => nvl(fnd_global.user_id, -1),
					X_LAST_UPDATE_DATE	           => sysdate,
					X_LAST_UPDATE_LOGIN	           => nvl(fnd_global.user_id, -1)
					) ;

	-- insert a destination cashflow


	CE_CASHFLOWS_PKG.insert_row (
					X_ROWID			               => l_row_id,
					X_CASHFLOW_ID		           => p_cashflow_id2,
					X_CASHFLOW_LEDGER_ID 	       => p_dest_ledger_id,
					X_CASHFLOW_LEGAL_ENTITY_ID     => G_dest_le_id,
					X_CASHFLOW_BANK_ACCOUNT_ID     => G_dest_bank_acct_id,
					X_CASHFLOW_DIRECTION	       => p_dest_dir,
					X_CASHFLOW_CURRENCY_CODE       => G_payment_curr_code,
					X_CASHFLOW_DATE		           => G_transaction_date,
					X_CASHFLOW_AMOUNT	           => p_cashflow_amount,  -- Bug 8627837 G_payment_amount,
					X_BASE_AMOUNT		           => p_recp_base_amount,
					X_DESCRIPTION		           => G_transaction_desc,
					X_CASHFLOW_EXCHANGE_RATE       => p_recp_exchange_rate,
					X_CASHFLOW_EXCHANGE_DATE       => p_recp_exch_date,
					X_CASHFLOW_EXCHANGE_RATE_TYPE  => p_recp_exch_rate_type,
					X_TRXN_REFERENCE_NUMBER	       => G_trxn_reference_number,
					X_BANK_TRXN_NUMBER	           => G_bank_trxn_number,
					X_SOURCE_TRXN_TYPE	           => 'BAT',
					X_SOURCE_TRXN_SUBTYPE_CODE_ID  => G_trxn_subtype_code_id,
					X_STATEMENT_LINE_ID	           => null,
					X_ACTUAL_VALUE_DATE	           => null,
					X_COUNTERPARTY_PARTY_ID	       => G_source_party_id,
					X_COUNTERPARTY_BANK_ACCOUNT_ID => G_source_bank_acct_id,
					X_OFFSET_CCID		           => p_dest_offset,
					X_CASHFLOW_STATUS_CODE	       => 'CREATED',
					X_CLEARED_DATE		           => null,
					X_CLEARED_AMOUNT	           => null,
					X_CLEARED_EXCHANGE_RATE	       => null,
					X_CLEARED_EXCHANGE_DATE	       => null,
					X_CLEARED_EXCHANGE_RATE_TYPE   => null,
					X_CLEARING_CHARGES_AMOUNT      => null,
					X_CLEARING_ERROR_AMOUNT	       => null,
					X_CLEARED_BY_FLAG	           => null,
					X_REFERENCE_TEXT	           => null,
					X_BANK_ACCOUNT_TEXT			   => null,
					X_CUSTOMER_TEXT				   => null,
					X_CREATED_BY		           => nvl(fnd_global.user_id, -1),
					X_CREATION_DATE		           => sysdate,
					X_LAST_UPDATED_BY	           => nvl(fnd_global.user_id, -1),
					X_LAST_UPDATE_DATE	           => sysdate,
					X_LAST_UPDATE_LOGIN	           => nvl(fnd_global.user_id, -1)
					) ;

	ELSIF (l_mode = 'UPDATE') THEN
	BEGIN
		select rowid, cashflow_id, object_version_number
		bulk collect into l_rowid, l_cashflow, l_objectversion
		from ce_cashflows
		where trxn_reference_number = p_trxn_reference_number
		order by cashflow_id;
		p_cashflow_id1 := l_cashflow(1);
		p_cashflow_id2 := l_cashflow(2);

		--update the source cashflow
		CE_CASHFLOWS_PKG.update_row (
					X_ROWID			       => l_rowid(1),
					X_CASHFLOW_ID		       => p_cashflow_id1,
					X_CASHFLOW_LEDGER_ID 	       => p_source_ledger_id,
					X_CASHFLOW_LEGAL_ENTITY_ID     => G_source_le_id,
					X_CASHFLOW_BANK_ACCOUNT_ID     => G_source_bank_acct_id,
					X_CASHFLOW_DIRECTION	       => p_source_dir,
					X_CASHFLOW_CURRENCY_CODE       => G_payment_curr_code,
					X_CASHFLOW_DATE		       => G_transaction_date,
					X_CASHFLOW_AMOUNT	       => p_cashflow_amount, --Bug 8627837 G_payment_amount,
					X_BASE_AMOUNT		       => p_pay_base_amount,
					X_DESCRIPTION		       => G_transaction_desc,
					X_CASHFLOW_EXCHANGE_RATE       => p_pay_exchange_rate,
					X_CASHFLOW_EXCHANGE_DATE       => p_pay_exch_date,
					X_CASHFLOW_EXCHANGE_RATE_TYPE  => p_pay_exch_rate_type,
					X_TRXN_REFERENCE_NUMBER	       => G_trxn_reference_number,
					X_BANK_TRXN_NUMBER	       => G_bank_trxn_number,
					X_SOURCE_TRXN_TYPE	       => 'BAT',
					X_SOURCE_TRXN_SUBTYPE_CODE_ID  => G_trxn_subtype_code_id,
					X_STATEMENT_LINE_ID	       => G_created_from_stmtline_id,
					X_ACTUAL_VALUE_DATE	       => null,
					X_COUNTERPARTY_PARTY_ID	       => G_dest_party_id,
					X_COUNTERPARTY_BANK_ACCOUNT_ID => G_dest_bank_acct_id,
					X_OFFSET_CCID		       => p_source_offset,
					X_CASHFLOW_STATUS_CODE	       => 'CREATED',
					X_CLEARED_DATE		       => null,
					X_CLEARED_AMOUNT	       => null,
					X_CLEARED_EXCHANGE_RATE	       => null,
					X_CLEARED_EXCHANGE_DATE	       => null,
					X_CLEARED_EXCHANGE_RATE_TYPE   => null,
					X_CLEARING_CHARGES_AMOUNT      => null,
					X_CLEARING_ERROR_AMOUNT	       => null,
					X_CLEARED_BY_FLAG	       => null,
					X_REFERENCE_TEXT	       => null,
					X_BANK_ACCOUNT_TEXT	       => null,
					X_CUSTOMER_TEXT		       => null,
					X_LAST_UPDATED_BY	       => nvl(fnd_global.user_id, -1),
					X_LAST_UPDATE_DATE	       => sysdate,
					X_LAST_UPDATE_LOGIN	       => nvl(fnd_global.user_id, -1),
					X_OBJECT_VERSION_NUMBER	       => l_objectversion(1)
					);

	--update a destination cashflow
	CE_CASHFLOWS_PKG.update_row(
					X_ROWID			       => l_rowid(2),
					X_CASHFLOW_ID		       => p_cashflow_id2,
					X_CASHFLOW_LEDGER_ID 	       => p_dest_ledger_id,
					X_CASHFLOW_LEGAL_ENTITY_ID     => G_dest_le_id,
					X_CASHFLOW_BANK_ACCOUNT_ID     => G_dest_bank_acct_id,
					X_CASHFLOW_DIRECTION	       => p_dest_dir,
					X_CASHFLOW_CURRENCY_CODE       => G_payment_curr_code,
					X_CASHFLOW_DATE		       => G_transaction_date,
					X_CASHFLOW_AMOUNT	       => p_cashflow_amount, -- Bug 8627837 G_payment_amount,
					X_BASE_AMOUNT		       => p_recp_base_amount,
					X_DESCRIPTION		       => G_transaction_desc,
					X_CASHFLOW_EXCHANGE_RATE       => p_recp_exchange_rate,
					X_CASHFLOW_EXCHANGE_DATE       => p_recp_exch_date,
					X_CASHFLOW_EXCHANGE_RATE_TYPE  => p_recp_exch_rate_type,
					X_TRXN_REFERENCE_NUMBER	       => G_trxn_reference_number,
					X_BANK_TRXN_NUMBER	       => G_bank_trxn_number,
					X_SOURCE_TRXN_TYPE	       => 'BAT',
					X_SOURCE_TRXN_SUBTYPE_CODE_ID  => G_trxn_subtype_code_id,
					X_STATEMENT_LINE_ID	       => null,
					X_ACTUAL_VALUE_DATE	       => null,
					X_COUNTERPARTY_PARTY_ID	       => G_source_party_id,
					X_COUNTERPARTY_BANK_ACCOUNT_ID => G_source_bank_acct_id,
					X_OFFSET_CCID		       => p_dest_offset,
					X_CASHFLOW_STATUS_CODE	       => 'CREATED',
					X_CLEARED_DATE		       => null,
					X_CLEARED_AMOUNT	       => null,
					X_CLEARED_EXCHANGE_RATE	       => null,
					X_CLEARED_EXCHANGE_DATE	       => null,
					X_CLEARED_EXCHANGE_RATE_TYPE   => null,
					X_CLEARING_CHARGES_AMOUNT      => null,
					X_CLEARING_ERROR_AMOUNT	       => null,
					X_CLEARED_BY_FLAG	       => null,
					X_REFERENCE_TEXT	       => null,
					X_BANK_ACCOUNT_TEXT	       => null,
					X_CUSTOMER_TEXT		       => null,
					X_LAST_UPDATED_BY	       => nvl(fnd_global.user_id, -1),
					X_LAST_UPDATE_DATE	       => sysdate,
					X_LAST_UPDATE_LOGIN	       => nvl(fnd_global.user_id, -1),
					X_OBJECT_VERSION_NUMBER	       => l_objectversion(2)
					);
	EXCEPTION
		WHEN OTHERS THEN
		NULL;
	END;
	END IF;
	p_mode:= l_mode;
	CLOSE f_row_cursor;
log('first cashflow id'|| p_cashflow_id1);
log('second cashflow id'|| p_cashflow_id2);
log('<< transfer payment transaction');
EXCEPTION
	WHEN OTHERS THEN
log('exception in transfer payment transaction');
	   CLOSE f_row_cursor;
	   RAISE;
END transfer_payment_transaction;


PROCEDURE get_bat_default_pmt_method
		(p_payer_le_id NUMBER,
		 p_org_id NUMBER,
		 p_payee_party_id NUMBER,
		 p_payee_party_site_id NUMBER,
		 p_supplier_site_id NUMBER,
		 p_payment_currency VARCHAR2,
		 p_payment_amount NUMBER,
		 x_return_status OUT NOCOPY VARCHAR2 ,
		 x_msg_data OUT NOCOPY VARCHAR2 ,
		 x_msg_count OUT NOCOPY NUMBER ,
		 x_def_pm_code OUT NOCOPY VARCHAR2 ,
		 x_def_pm_name OUT NOCOPY VARCHAR2 )
IS
  l_Trxn_Attribs IBY_DISBURSEMENT_COMP_PUB.Trxn_Attributes_Rec_Type;
  x_default_pmt_attrs_rec IBY_DISBURSEMENT_COMP_PUB.Default_Pmt_Attrs_Rec_Type;
BEGIN
  l_Trxn_Attribs.Application_Id:=260;
  l_Trxn_Attribs.Payer_Legal_Entity_Id:=p_payer_le_id;
  l_Trxn_Attribs.Payer_Org_Id:=p_org_id;
  l_Trxn_Attribs.Payer_Org_Type:='LEGAL_ENTITY';
  l_Trxn_Attribs.Payee_Party_Id:=p_payee_party_id;
  l_Trxn_Attribs.Payee_Party_Site_Id:=p_payee_party_site_id;
  l_Trxn_Attribs.Supplier_Site_Id:=p_supplier_site_id;
  l_Trxn_Attribs.Pay_Proc_Trxn_Type_Code:='BAT';
  l_Trxn_Attribs.Payment_Currency :=p_payment_currency;
  l_Trxn_Attribs.Payment_Amount :=p_payment_amount;
  l_Trxn_Attribs.Payment_Function:='CASH_PAYMENT';
  iby_disbursement_comp_pub.Get_Default_Payment_Attributes(
   	1.0,
	FND_API.G_TRUE,
	'Y',
	l_Trxn_Attribs,
	x_return_status,
	x_msg_count,
	x_msg_data,
	x_default_pmt_attrs_rec
	);

  x_def_pm_code := x_default_pmt_attrs_rec.payment_method.payment_method_code;
  x_def_pm_name := x_default_pmt_attrs_rec.payment_method.payment_method_name;
END;


END CE_BAT_UTILS;


/
