--------------------------------------------------------
--  DDL for Package Body XTR_UPDATE_SETTLEMENT_ACCOUNTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_UPDATE_SETTLEMENT_ACCOUNTS" as
/* $Header: xtrupacb.pls 120.3 2006/11/03 12:27:20 kbabu noship $ */

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE process_settlement_accounts
 *
 * DESCRIPTION
 *     	This procedure updates XTR_DEAL_DATE_AMOUNTS table and sets the
 * 	company account or counterparty account specified as the
 *	account_number_from to the account specified as account_number_to.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     	p_party_code                  	Party Code of the party for whom the
 *					accounts are to be updated.
 *     	p_current_bank_account		Bank Account Number from
 *					XTR_BANK_ACCOUNTS for the above party.
 *					All cashflow records that use this
 *					account are to be updated.
 *	p_new_bank_account		Bank Account Number from
 *					XTR_BANK_ACCOUNTS for the above party.
 *					All cashflow records that use the
 *					above account will be updated with this
 *					account.
 *	p_start_date			All records with an amount_date greater
 *					than or equal to this date will be
 *					considered for update.
 *	p_end_date			All records with an amount_date lesser
 *					than or equal to this date will be
 *					considered for update.
 *	p_deal_type			Only those deals with the specified
 *					Deal Type will be updated.
 *	p_deal_number_from		Only those deals with a deal number
 *					greater than or equal to this
 *					parameter will be updated.
 *	p_deal_number_to		Only those deals with a deal number
 *					lesser than or equal to this
 *					parameter will be updated.
 *      p_include_journalized           Flag to indicate whether cashflows
 *                                      that have already been journalized
 *                                      should be updated.
 *   IN/OUT:
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-Jun-2005    Rajesh Jose        	o Created.
 *
 */
PROCEDURE Process_Settlement_Accounts(
	p_error_buf		OUT NOCOPY VARCHAR2,
	p_retcode		OUT NOCOPY NUMBER,
	p_party_code 		IN XTR_PARTY_INFO.PARTY_CODE%TYPE,
	p_current_bank_account 	IN XTR_BANK_ACCOUNTS.ACCOUNT_NUMBER%TYPE,
	p_new_bank_account 	IN XTR_BANK_ACCOUNTS.ACCOUNT_NUMBER%TYPE,
	p_start_date 		IN VARCHAR2,
	p_end_date 		IN VARCHAR2,
	p_deal_type 		IN XTR_DEALS.DEAL_TYPE%TYPE,
	p_deal_number_from 	IN XTR_DEALS.DEAL_NO%TYPE,
	p_deal_number_to	IN XTR_DEALS.DEAL_NO%TYPE,
	p_include_journalized	IN
		XTR_CFLOW_REQUEST_DETAILS.INCLUDE_JOURNALIZED_FLAG%TYPE)
IS

CURSOR company_list IS
select party_code
from xtr_parties_v where party_type = 'C';

CURSOR max_deal_no IS
select max (deal_number) from XTR_DEAL_DATE_AMOUNTS;

CURSOR comp_accts_with_deal_type (
	p_company_code XTR_PARTY_INFO.PARTY_CODE%TYPE,
	p_int_deal_no_from XTR_DEAL_DATE_AMOUNTS.DEAL_NUMBER%TYPE,
	p_int_deal_no_to XTR_DEAL_DATE_AMOUNTS.DEAL_NUMBER%TYPE,
	p_date DATE,
	p_default_end_date DATE) IS
SELECT 	deal_date_amount_id, deal_number,
	amount_date, amount_type, cashflow_amount,
	settle, batch_id, transaction_number, deal_type
FROM xtr_deal_date_amounts
WHERE account_no = p_current_bank_account
AND amount_date >= p_date
AND amount_date <= p_default_end_date
AND deal_type = p_deal_type
AND company_code = p_company_code
AND deal_number BETWEEN p_int_deal_no_from AND p_int_deal_no_to;

CURSOR comp_accts_with_deal_no (
	p_company_code XTR_PARTY_INFO.PARTY_CODE%TYPE,
	p_int_deal_no_from XTR_DEAL_DATE_AMOUNTS.DEAL_NUMBER%TYPE,
	p_int_deal_no_to XTR_DEAL_DATE_AMOUNTS.DEAL_NUMBER%TYPE,
	p_date DATE,
	p_default_end_date DATE) IS
SELECT 	deal_date_amount_id, deal_number,
	amount_date, amount_type, cashflow_amount,
	settle, batch_id, transaction_number, deal_type
FROM xtr_deal_date_amounts
WHERE account_no = p_current_bank_account
AND amount_date >= p_date
AND amount_date <= p_default_end_date
AND company_code = p_company_code
AND deal_type NOT IN ('CA', 'IAC')
AND deal_number BETWEEN p_int_deal_no_from AND p_int_deal_no_to;

Cursor cparty_accts_with_deal_no(
	p_company_code XTR_PARTY_INFO.PARTY_CODE%TYPE,
	p_int_deal_no_from XTR_DEAL_DATE_AMOUNTS.DEAL_NUMBER%TYPE,
	p_int_deal_no_to XTR_DEAL_DATE_AMOUNTS.DEAL_NUMBER%TYPE,
	p_date DATE,
	p_default_end_date DATE) IS
SELECT deal_date_amount_id, deal_number,
	amount_date, amount_type, cashflow_amount,
	settle, batch_id, transaction_number, deal_type
FROM xtr_deal_date_amounts
WHERE cparty_account_no = p_current_bank_account
AND amount_date >= p_date
AND amount_date <= p_default_end_date
AND company_code = p_company_code
AND deal_type NOT IN ('CA', 'IAC')
AND deal_number BETWEEN p_int_deal_no_from AND p_int_deal_no_to;

CURSOR cparty_accts_with_deal_type (
	p_company_code XTR_PARTY_INFO.PARTY_CODE%TYPE,
	p_int_deal_no_from XTR_DEAL_DATE_AMOUNTS.DEAL_NUMBER%TYPE,
	p_int_deal_no_to XTR_DEAL_DATE_AMOUNTS.DEAL_NUMBER%TYPE,
	p_date DATE,
	p_default_end_date DATE) IS
SELECT 	deal_date_amount_id, deal_number,
	amount_date, amount_type, cashflow_amount,
	settle, batch_id, transaction_number, deal_type
FROM xtr_deal_date_amounts
WHERE cparty_account_no = p_current_bank_account
AND amount_date >= p_date
AND amount_date <= p_default_end_date
AND deal_type = p_deal_type
AND company_code = p_company_code
AND deal_number BETWEEN p_int_deal_no_from AND p_int_deal_no_to;

CURSOR check_journal( p_batch_id XTR_DEAL_DATE_AMOUNTS.BATCH_ID%TYPE) IS
SELECT 	'Y'
FROM 	xtr_batches b, xtr_batch_events e
WHERE 	b.batch_id  = e.batch_id
AND	e.event_code = 'JRNLGN'
AND	b.batch_id = p_batch_id;

l_commit_counter 	NUMBER;
l_company_code		XTR_PARTY_INFO.PARTY_CODE%TYPE;
l_current_currency 	XTR_BANK_ACCOUNTS.currency%TYPE;
l_current_party_code 	XTR_BANK_ACCOUNTS.PARTY_CODE%TYPE;
l_new_currency 		XTR_BANK_ACCOUNTS.currency%TYPE;
l_new_authorized 	XTR_BANK_ACCOUNTS.AUTHORISED%TYPE;
l_reqid 		VARCHAR2(30);
l_request_id 		NUMBER;
l_amount_type		XTR_DEAL_DATE_AMOUNTS.AMOUNT_TYPE%TYPE;
l_amount_date		XTR_DEAL_DATE_AMOUNTS.AMOUNT_DATE%TYPE;
l_settle		XTR_DEAL_DATE_AMOUNTS.SETTLE%TYPE;
l_batch_id		XTR_DEAL_DATE_AMOUNTS.BATCH_ID%TYPE;
l_party_type		XTR_PARTY_INFO.PARTY_TYPE%TYPE;
l_deal_number		XTR_DEALS.DEAL_NO%TYPE;
l_deal_date_amount_id	XTR_DEAL_DATE_AMOUNTS.DEAL_DATE_AMOUNT_ID%TYPE;
l_cf_req_details_id	XTR_CFLOW_REQUEST_DETAILS.CASHFLOW_REQUEST_DETAILS_ID%TYPE;
l_cashflow_amount	XTR_DEAL_DATE_AMOUNTS.CASHFLOW_AMOUNT%TYPE;
l_transaction_number	XTR_DEAL_DATE_AMOUNTS.TRANSACTION_NUMBER%TYPE;
l_deal_type		XTR_DEAL_DATE_AMOUNTS.DEAL_TYPE%TYPE;
l_updated_flag		VARCHAR2(1);
l_journalized		VARCHAR2(1);
l_message_name		VARCHAR2(30);

p_int_start_date	DATE;
p_int_end_date		DATE;
p_int_deal_number_from	NUMBER;
p_int_deal_number_to	NUMBER;
p_company_code		XTR_PARTY_INFO.PARTY_CODE%TYPE;

BEGIN

 G_user_id := FND_GLOBAL.USER_ID;
 G_create_date := trunc(sysdate);
 p_int_start_date := to_date(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
 p_int_end_date := to_date(p_end_date, 'YYYY/MM/DD HH24:MI:SS');
 --Verify Bank Account Currencies are the same
 fnd_profile.get('CONC_REQUEST_ID', l_reqid);
 l_request_id := to_number(l_reqid);

/* for bug 5634804*/
 IF p_int_end_date IS NULL THEN
	p_int_end_date := to_date('31-12-4712', 'DD-MM-RRRR');
 END IF;
/* for bug 5634804*/

 SELECT xban.currency, xpv.party_type
 INTO	l_current_currency, l_party_type
 FROM 	xtr_bank_accounts xban, xtr_parties_v xpv
 WHERE  xban.account_number = p_current_bank_account
 AND	xban.party_code = p_party_code
 AND	xpv.party_code = xban.party_code;

 SELECT	currency, authorised
 INTO	l_new_currency, l_new_authorized
 FROM	xtr_bank_accounts
 WHERE	account_number = p_new_bank_account
 AND	party_code = p_party_code;

 IF l_new_authorized <> 'Y' THEN
	SELECT 	XTR_CFLOW_REQUEST_DETAILS_S.NEXTVAL
	INTO	l_cf_req_details_id
	FROM	DUAL;
	insert_request_details( l_cf_req_details_id,
			l_request_id, p_party_code,
			p_current_bank_account, p_new_bank_account,
			p_deal_type, p_deal_number_from,
			p_deal_number_to, p_int_start_date,
			p_int_end_date, p_include_journalized);
	l_message_name := 'XTR_CFLOW_ACCT_UNAUTHORIZED';
	insert_transaction_details(l_cf_req_details_id, sysdate,
			'', 0, '', 0, 0, 'N',
			l_message_name);
	l_request_id := FND_REQUEST.SUBMIT_REQUEST('XTR', 'XTRUPREP',
				'','', FALSE, l_cf_req_details_id);
	IF l_request_id = 0 THEN
		RAISE APP_EXCEPTION.application_exception;
	END IF;
 END IF;

 IF (l_message_name IS NULL) THEN
 	IF l_current_currency <> l_new_currency THEN
		SELECT 	XTR_CFLOW_REQUEST_DETAILS_S.NEXTVAL
		INTO	l_cf_req_details_id
		FROM	DUAL;
		insert_request_details( l_cf_req_details_id,
				l_request_id, p_party_code,
				p_current_bank_account, p_new_bank_account,
				p_deal_type, p_deal_number_from,
				p_deal_number_to, p_int_start_date,
				p_int_end_date, p_include_journalized);
		l_message_name := 'XTR_CFLOW_CURRENCY_MISMATCH';
		insert_transaction_details(l_cf_req_details_id, sysdate,
				'', 0, '', 0, 0, 'N',
				l_message_name);
		l_request_id := FND_REQUEST.SUBMIT_REQUEST('XTR', 'XTRUPREP',
				'','', FALSE, l_cf_req_details_id);
		IF l_request_id = 0 THEN
			RAISE APP_EXCEPTION.application_exception;
		END IF;
 	END IF;
 END IF;

 IF l_message_name IS NULL THEN
	SELECT	XTR_CFLOW_REQUEST_DETAILS_S.NEXTVAL
	INTO	l_cf_req_details_id
	FROM	DUAL;
	insert_request_details(l_cf_req_details_id, l_request_id,
				p_party_code, p_current_bank_account,
				p_new_bank_account, p_deal_type,
				p_deal_number_from, p_deal_number_to,
				p_int_start_date, p_int_end_date,
				p_include_journalized);
	IF p_deal_number_from IS NULL THEN
		p_int_deal_number_from := 0;
	ELSE
		p_int_deal_number_from := p_deal_number_from;
	END IF;
	IF p_deal_number_to IS NULL THEN
		OPEN max_deal_no;
		FETCH max_deal_no INTO p_int_deal_number_to;
		CLOSE max_deal_no;
	ELSE
		p_int_deal_number_to := p_deal_number_to;
	END IF;
	l_commit_counter := 0;
	IF l_party_type = 'C' THEN
		IF p_deal_type IS NULL THEN
			OPEN comp_accts_with_deal_no (
				p_party_code, p_int_deal_number_from,
				p_int_deal_number_to,
				p_int_start_date, p_int_end_date);
			LOOP
				FETCH comp_accts_with_deal_no INTO
					l_deal_date_amount_id,
					l_deal_number,
					l_amount_date, l_amount_type,
					l_cashflow_amount, l_settle,
					l_batch_id,
					l_transaction_number, l_deal_type;
				IF comp_accts_with_deal_no%NOTFOUND THEN
					CLOSE comp_accts_with_deal_no;
					EXIT;
				END IF;
				l_updated_flag := 'Y';
				l_message_name := '';
				IF l_settle = 'Y' THEN
					l_updated_flag := 'N';
					l_message_name :=
						'XTR_CFLOW_NOT_UPDATED';
				END IF;
				IF (l_batch_id IS NOT NULL AND
				    l_updated_flag = 'Y') THEN
					OPEN check_journal(l_batch_id);
					FETCH check_journal
					INTO	l_journalized;
					CLOSE	check_journal;
					IF l_journalized = 'Y' THEN
						IF p_include_journalized = 'Y'
						THEN
						   l_updated_flag := 'Y';
						   l_message_name :=
						    'XTR_ACCNT_CHNG_AFTER_JRNL';
						ELSE
						   l_updated_flag := 'N';
						   l_message_name :=
							'XTR_CFLOW_NOT_UPDATED';
						END IF;
					END IF;
				END IF;
				IF l_updated_flag = 'Y' THEN
					UPDATE xtr_deal_date_amounts
					set account_no = p_new_bank_account
					where deal_date_amount_id =
						l_deal_date_amount_id;
				END IF;
				l_commit_counter := l_commit_counter + 1;
				insert_transaction_details(
					l_cf_req_details_id,
					l_amount_date,
					l_amount_type,
					l_cashflow_amount,
					l_deal_type,
					l_deal_number,
					l_transaction_number,
					l_updated_flag,
					l_message_name);
				IF l_commit_counter = 1000 THEN
					COMMIT;
					l_commit_counter := 0;
				END IF;
			END LOOP;
			COMMIT;
			IF comp_accts_with_deal_no%ISOPEN THEN
				CLOSE comp_accts_with_deal_no;
			END IF;
		ELSE -- p_deal_type is not null
			OPEN comp_accts_with_deal_type(
				p_party_code, p_int_deal_number_from,
				p_int_deal_number_to,
				p_int_start_date, p_int_end_date);
			 LOOP
				FETCH comp_accts_with_deal_type
				INTO
					l_deal_date_amount_id,
					l_deal_number,
					l_amount_date, l_amount_type,
					l_cashflow_amount, l_settle,
					l_batch_id,
					l_transaction_number, l_deal_type;
				IF comp_accts_with_deal_type%NOTFOUND THEN
					CLOSE comp_accts_with_deal_type;
					EXIT;
				END IF;
				l_updated_flag := 'Y';
				l_message_name := '';
				IF l_settle = 'Y' THEN
					l_updated_flag := 'N';
					l_message_name :=
						'XTR_CFLOW_NOT_UPDATED';
				END IF;
				IF (l_batch_id IS NOT NULL AND
				    l_updated_flag = 'Y') THEN
					OPEN check_journal(l_batch_id);
					FETCH check_journal
					INTO	l_journalized;
					CLOSE	check_journal;
					IF l_journalized = 'Y' THEN
						IF p_include_journalized = 'Y'
						THEN
						   l_updated_flag := 'Y';
						   l_message_name :=
						    'XTR_ACCNT_CHNG_AFTER_JRNL';
						ELSE
						   l_updated_flag := 'N';
						   l_message_name :=
							'XTR_CFLOW_NOT_UPDATED';
						END IF;
					END IF;
				END IF;
				IF l_updated_flag = 'Y' THEN
					UPDATE xtr_deal_date_amounts
					set account_no = p_new_bank_account
					where deal_date_amount_id =
						l_deal_date_amount_id;
				END IF;
				l_commit_counter := l_commit_counter + 1;
				insert_transaction_details(
					l_cf_req_details_id,
					l_amount_date,
					l_amount_type,
					l_cashflow_amount,
					l_deal_type,
					l_deal_number,
					l_transaction_number,
					l_updated_flag,
					l_message_name);
				IF l_commit_counter = 1000 THEN
					COMMIT;
					l_commit_counter := 0;
				END IF;
			END LOOP;
			COMMIT;
			IF comp_accts_with_deal_type%ISOPEN THEN
				CLOSE comp_accts_with_deal_type;
			END IF;
		END IF; -- p_deal_type is null
	ELSE -- p_party_type = Counterparty
		IF p_deal_type IS NULL THEN
			OPEN company_list;
			LOOP
				FETCH company_list INTO l_company_code;
				IF company_list%NOTFOUND THEN
					CLOSE company_list;
					EXIT;
				END IF;
				l_commit_counter := 0;
				OPEN cparty_accts_with_deal_no
						(l_company_code,
						p_int_deal_number_from,
						p_int_deal_number_to,
						p_int_start_date,
						p_int_end_date);
				LOOP
					FETCH cparty_accts_with_deal_no
					INTO
					l_deal_date_amount_id,
					l_deal_number,
					l_amount_date, l_amount_type,
					l_cashflow_amount, l_settle,
					l_batch_id,
					l_transaction_number, l_deal_type;
					IF cparty_accts_with_deal_no%NOTFOUND
					THEN
						CLOSE cparty_accts_with_deal_no;
						EXIT;
					END IF;
					l_updated_flag := 'Y';
					l_message_name := '';
					IF l_settle = 'Y' THEN
						l_updated_flag := 'N';
						l_message_name :=
							'XTR_CFLOW_NOT_UPDATED';
					END IF;
					IF (l_batch_id IS NOT NULL AND
				    	    l_updated_flag = 'Y') THEN
					   OPEN check_journal(l_batch_id);
					   FETCH check_journal
					   INTO	l_journalized;
					   CLOSE check_journal;
					   IF l_journalized = 'Y' THEN
						IF p_include_journalized = 'Y'
						THEN
						   l_updated_flag := 'Y';
						   l_message_name :=
						    'XTR_ACCNT_CHNG_AFTER_JRNL';
						ELSE
						   l_updated_flag := 'N';
						   l_message_name :=
							'XTR_CFLOW_NOT_UPDATED';
						END IF;
					   END IF;
					END IF;
					IF l_updated_flag = 'Y' THEN
						Update XTR_DEAL_DATE_AMOUNTS
						Set cparty_account_no =
							p_new_bank_account
						Where deal_date_amount_id =
							l_deal_date_amount_id;
					END IF;
					l_commit_counter :=
						l_commit_counter + 1;
					insert_transaction_details(
						l_cf_req_details_id,
						l_amount_date,
						l_amount_type,
						l_cashflow_amount,
						l_deal_type,
						l_deal_number,
						l_transaction_number,
						l_updated_flag,
						l_message_name);
					IF l_commit_counter = 1000 THEN
						COMMIT;
						l_commit_counter := 0;
					END IF;
				END LOOP; -- unauth_counterparty
				COMMIT;
				IF cparty_accts_with_deal_no%ISOPEN THEN
					CLOSE cparty_accts_with_deal_no;
		       		END IF;
			END LOOP; -- company_list
			IF company_list%ISOPEN THEN
				CLOSE company_list;
			END IF;
		ELSE -- p_deal_type is not null
		OPEN company_list;
			LOOP
				FETCH company_list INTO l_company_code;
				IF company_list%NOTFOUND THEN
					CLOSE company_list;
					EXIT;
				END IF;
				l_commit_counter := 0;
				OPEN cparty_accts_with_deal_type
						(l_company_code,
						p_int_deal_number_from,
						p_int_deal_number_to,
						p_int_start_date,
						p_int_end_date);
				LOOP
					FETCH cparty_accts_with_deal_type
					INTO
					l_deal_date_amount_id,
					l_deal_number,
					l_amount_date, l_amount_type,
					l_cashflow_amount, l_settle,
					l_batch_id,
					l_transaction_number, l_deal_type;
					IF cparty_accts_with_deal_type%NOTFOUND
					THEN
					      CLOSE cparty_accts_with_deal_type;
						EXIT;
					END IF;
					l_updated_flag := 'Y';
					l_message_name := '';
					IF l_settle = 'Y' THEN
						l_updated_flag := 'N';
						l_message_name :=
							'XTR_CFLOW_NOT_UPDATED';
					END IF;
					IF (l_batch_id IS NOT NULL AND
				    	    l_updated_flag = 'Y') THEN
					   OPEN check_journal(l_batch_id);
					   FETCH check_journal
					   INTO	l_journalized;
					   CLOSE check_journal;
					   IF l_journalized = 'Y' THEN
						IF p_include_journalized = 'Y'
						THEN
						   l_updated_flag := 'Y';
						   l_message_name :=
						    'XTR_ACCNT_CHNG_AFTER_JRNL';
						ELSE
						   l_updated_flag := 'N';
						   l_message_name :=
							'XTR_CFLOW_NOT_UPDATED';
						END IF;
					   END IF;
					END IF;
					IF l_updated_flag = 'Y' THEN
						Update XTR_DEAL_DATE_AMOUNTS
						Set cparty_account_no =
							p_new_bank_account
						Where deal_date_amount_id =
							l_deal_date_amount_id;
					END IF;
					l_commit_counter :=
						l_commit_counter + 1;
					insert_transaction_details(
						l_cf_req_details_id,
						l_amount_date,
						l_amount_type,
						l_cashflow_amount,
						l_deal_type,
						l_deal_number,
						l_transaction_number,
						l_updated_flag,
						l_message_name);
					IF l_commit_counter = 1000 THEN
						COMMIT;
						l_commit_counter := 0;
					END IF;
				END LOOP; -- unauth_counterparty
				COMMIT;
				IF cparty_accts_with_deal_type%ISOPEN THEN
					CLOSE cparty_accts_with_deal_type;
		       		END IF;
			END LOOP; -- company_list
			IF company_list%ISOPEN THEN
				CLOSE company_list;
			END IF;
		END IF;
	END IF;

	l_request_id := FND_REQUEST.SUBMIT_REQUEST('XTR', 'XTRUPREP',
					'','', FALSE, l_cf_req_details_id);
	IF l_request_id = 0 THEN
		RAISE APP_EXCEPTION.application_exception;
	END IF;
 END IF;
END;



/**
 * PROCEDURE insert_request_details
 *
 * DESCRIPTION
 *     	Inserts request details into XTR_CFLOW_REQUEST_DETAILS table so that
 *	the execution report can be run at any time.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *	p_cashflow_request_details_id	The identifier for the record.
 *	p_request_id			The Request ID of the Concurrent
 *					Request that was run to update the
 *					Settlement Accounts.
 *     	p_party_code                  	Party Code Parameter from the request.
 *     	p_current_bank_account		Current Bank Account Number Parameter
 *					from the request.
 *	p_new_bank_account		New Bank Account Number Parameter
 *					from request.
 *	p_start_date			Start Date Parameter from the request.
 *	p_end_date			End Date Parameter from the request.
 *	p_deal_type			Deal Type Parameter from the request.
 *	p_deal_number_from		Deal Number From Parameter from the
 *					request.
 *	p_deal_number_to		Deal Number To Parameter from the
 *					request.
 *	p_inc_journalized		Include Journalized Transactions
 *					Parameter from the request.
 *   IN/OUT:
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-Jun-2005    Rajesh Jose        	o Created.
 */
PROCEDURE Insert_Request_Details(
	p_cashflow_request_details_id IN
		XTR_CFLOW_REQUEST_DETAILS.CASHFLOW_REQUEST_DETAILS_ID%TYPE,
	p_request_id 		IN	NUMBER,
	p_party_code 		IN	XTR_PARTY_INFO.PARTY_CODE%TYPE,
	p_current_bank_account 	IN	XTR_BANK_ACCOUNTS.ACCOUNT_NUMBER%TYPE,
	p_new_bank_account 	IN	XTR_BANK_ACCOUNTS.ACCOUNT_NUMBER%TYPE,
	p_deal_type 		IN	XTR_DEALS.DEAL_TYPE%TYPE,
	p_deal_number_from 	IN	XTR_DEALS.DEAL_NO%TYPE,
	p_deal_number_to 	IN	XTR_DEALS.DEAL_NO%TYPE,
	p_start_date 		IN	DATE,
	p_end_date 		IN	DATE,
	p_inc_journalized 	IN
			XTR_CFLOW_REQUEST_DETAILS.INCLUDE_JOURNALIZED_FLAG%TYPE)
IS
BEGIN
	INSERT INTO XTR_CFLOW_REQUEST_DETAILS
	(cashflow_request_details_id, request_id, party_code,
	 account_no_from, account_no_to, deal_type,
	 deal_number_from, deal_number_to, starting_cflow_date,
	 ending_cflow_date, include_journalized_flag,
	 created_by, creation_date, last_updated_by, last_update_date,
	 last_update_login)
	VALUES
	(p_cashflow_request_details_id, p_request_id, p_party_code,
	 p_current_bank_account, p_new_bank_account, p_deal_type,
	 p_deal_number_from, p_deal_number_to, p_start_date,
	 p_end_date, p_inc_journalized,
	 G_user_id, G_create_date, G_user_id, G_create_date,
	 G_user_id);
END;


/**
 * PROCEDURE insert_transaction_details
 *
 * DESCRIPTION
 *	Inserts details of transactions updated by the concurrent request
 *	so that the Execution Report shows accurate data at any point of time.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *	p_cashflow_request_details_id	Foreign key reference from
 *					XTR_CFLOW_REQUEST_DETAILS.
 *	p_amount_date			The amount date of the cashflow.
 *	p_amount_type			The type of cashflow.
 *	p_cashflow_amount		The amount of cash flow.
 *	p_deal_type			The Deal Type for the record.
 *	p_deal_number			The Deal Number for the record.
 *	p_transaction_number		The Transaction Number for the record.
 *	p_updated_flag			Flag indicating whether the record was
 *					updated or not.
 *	p_message_name			Message to be shown if record was not
 *					updated. Conveys the reason why the
 *					record was not updated.
 *   IN/OUT:
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *   06-Jun-2005    Rajesh Jose        	o Created.
 *
 */

PROCEDURE Insert_Transaction_Details(
	p_cashflow_request_details_id 	IN
		XTR_CFLOW_REQUEST_DETAILS.CASHFLOW_REQUEST_DETAILS_ID%TYPE,
	p_amount_date		IN	DATE,
	p_amount_type		IN	XTR_DEAL_DATE_AMOUNTS.AMOUNT_TYPE%TYPE,
	p_cashflow_amount	IN
				XTR_DEAL_DATE_AMOUNTS.CASHFLOW_AMOUNT%TYPE,
	p_deal_type		IN	XTR_DEAL_DATE_AMOUNTS.DEAL_TYPE%TYPE,
	p_deal_number		IN	XTR_DEALS.DEAL_NO%TYPE,
	p_transaction_number	IN
				XTR_DEAL_DATE_AMOUNTS.TRANSACTION_NUMBER%TYPE,
	p_updated_flag		IN	VARCHAR2,
	p_message_name		IN	VARCHAR2)
IS
BEGIN
	INSERT INTO XTR_CFLOW_UPDATED_RECORDS
	(cashflow_request_details_id, amount_date, amount_type,
	 cashflow_amount, deal_type, deal_number,
	 transaction_number, updated_flag, message_name,
	 created_by, creation_date, last_updated_by, last_update_date,
	 last_update_login)
	VALUES
	(p_cashflow_request_details_id, p_amount_date, p_amount_type,
	 p_cashflow_amount, p_deal_type, p_deal_number,
	 p_transaction_number, p_updated_flag, p_message_name,
	 G_user_id, G_create_date, G_user_id, G_create_date,
	 G_user_id);
END;


END XTR_UPDATE_SETTLEMENT_ACCOUNTS;


/
