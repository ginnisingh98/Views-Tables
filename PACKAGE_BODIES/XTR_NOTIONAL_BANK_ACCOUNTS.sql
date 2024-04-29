--------------------------------------------------------
--  DDL for Package Body XTR_NOTIONAL_BANK_ACCOUNTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_NOTIONAL_BANK_ACCOUNTS" as
/* $Header: xtrnbnkb.pls 120.1 2005/07/29 09:32:45 badiredd noship $ */

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE modify_xtr_bank_accounts
 *
 * DESCRIPTION
 *     This procedure creates a dummy bank account in xtr_bank_accounts
 *     if the cash pool is being created.
 *     If an existing cash pool is being updated, then the corresponding
 *     dummy bank account in xtr_bank_accounts will be updated.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_cashpool_id                  	Cashpool ID of the Notional Cash Pool
 *					that is being created or updated.
 *     p_bank_account_id		Bank Account ID from CE_BANK_ACCOUNTS
 *					of the Concentration Account of the
 *					Cashpool.
 *   IN/OUT:
 *     x_return_status                  Return status after the call. The
 *                                      status can be Y for success or N for
 *					error.
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   01-26-2005    Rajesh Jose        	o Created.
 *
 */

-- R12 Modified the reference to AP_BANK_ACCOUNTS and AP_BANK_ACCOUNT_ID to CE_BANK_ACCOUNTS and CE_BANK_ACCOUNT_ID
PROCEDURE modify_xtr_bank_accounts(
	p_cashpool_id		IN	CE_CASHPOOLS.CASHPOOL_ID%TYPE,
	p_bank_account_id	IN	CE_BANK_ACCOUNTS.BANK_ACCOUNT_ID%TYPE,
	x_return_status		IN OUT NOCOPY VARCHAR2)
IS
 cursor cashpool_exists IS
	SELECT 	cashpool_id
	FROM	xtr_bank_accounts
	WHERE 	cashpool_id = p_cashpool_id
	AND	setoff_account_yn = 'Y';
	l_cashpool_id	CE_CASHPOOLS.CASHPOOL_ID%TYPE;
BEGIN
	OPEN CASHPOOL_EXISTS;
	FETCH CASHPOOL_EXISTS INTO l_cashpool_id;
	IF CASHPOOL_EXISTS%FOUND THEN
		update_xtr_bank_account(p_cashpool_id, p_bank_account_id,
			x_return_status);
		IF (x_return_status <> 'N') THEN
			COMMIT;
		END IF;
	ELSE
		create_xtr_bank_account(p_cashpool_id, p_bank_account_id,
			x_return_status);
		IF (x_return_status <> 'N') THEN
			COMMIT;
		END IF;
	END IF;
	CLOSE CASHPOOL_EXISTS;
END;

/**
 * PROCEDURE create_xtr_bank_account
 *
 * DESCRIPTION
 *     Creates dummy account in XTR_BANK_ACCOUNTS
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_cashpool_id                  	Cashpool ID of the Notional Cash Pool
 *					that is being created or updated.
 *     p_bank_account_id		Bank Account ID from CE_BANK_ACCOUNTS
 *					of the Concentration Account of the
 *					Cashpool.
 *   IN/OUT:
 *     x_return_status                  Return status after the call. The
 *                                      status can be Y for success or N for
 *					error.
 *   OUT:
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   01-26-2005    Rajesh Jose        	o Created.
 */
-- R12 Modified the reference to AP_BANK_ACCOUNTS_ALL and AP_BANK_ACCOUNT_ID to CE_BANK_ACCOUNTS and CE_BANK_ACCOUNT_ID
PROCEDURE create_xtr_bank_account(
	p_cashpool_id		IN	CE_CASHPOOLS.CASHPOOL_ID%TYPE,
	p_bank_account_id	IN	CE_BANK_ACCOUNTS.BANK_ACCOUNT_ID%TYPE,
	x_return_status		IN OUT NOCOPY VARCHAR2)
IS
 cursor	account_details IS
	SELECT	bank_code, party_code, currency, year_calc_type,
		portfolio_code, interest_calculation_basis,
		rounding_type, day_count_type, code_combination_id
	FROM	XTR_BANK_ACCOUNTS
	WHERE	ce_bank_account_id
			= p_bank_account_id;

 cursor	acct_number_exists(
		p_acct_number XTR_BANK_ACCOUNTS.ACCOUNT_NUMBER%TYPE,
		p_party_code  XTR_BANK_ACCOUNTS.PARTY_CODE%TYPE) IS
	SELECT  account_number
	FROM	XTR_BANK_ACCOUNTS
	WHERE	account_number = p_acct_number
	AND	party_code = p_party_code;

 cursor	cashpool_details IS
	SELECT	substrb(name,1,80), substrb(UPPER(name),1,20)
	FROM	ce_cashpools
	WHERE	cashpool_id = p_cashpool_id;

 cursor dealer_details IS
	SELECT	dealer_code
	FROM	xtr_dealer_codes
	WHERE	user_id = FND_GLOBAL.USER_ID;

 l_bank_code		XTR_BANK_ACCOUNTS.BANK_CODE%TYPE;
 l_party_code		XTR_BANK_ACCOUNTS.PARTY_CODE%TYPE;
 l_currency		XTR_BANK_ACCOUNTS.CURRENCY%TYPE;
 l_year_calc_type	XTR_BANK_ACCOUNTS.YEAR_CALC_TYPE%TYPE;
 l_portfolio_code	XTR_BANK_ACCOUNTS.PORTFOLIO_CODE%TYPE;
 l_int_calc_basis	XTR_BANK_ACCOUNTS.INTEREST_CALCULATION_BASIS%TYPE;
 l_rounding_type	XTR_BANK_ACCOUNTS.ROUNDING_TYPE%TYPE;
 l_day_count_type	XTR_BANK_ACCOUNTS.DAY_COUNT_TYPE%TYPE;
 l_code_combination_id	XTR_BANK_ACCOUNTS.CODE_COMBINATION_ID%TYPE;

 l_account_number	XTR_BANK_ACCOUNTS.ACCOUNT_NUMBER%TYPE;

 l_bank_short_code	XTR_BANK_ACCOUNTS.BANK_SHORT_CODE%TYPE;
 l_new_acct_number	XTR_BANK_ACCOUNTS.ACCOUNT_NUMBER%TYPE;

 l_created_by		XTR_DEALER_CODES.DEALER_CODE%TYPE;
 l_updated_by		XTR_DEALER_CODES.DEALER_CODE%TYPE;

 l_counter		NUMBER;
 l_dummy_char		VARCHAR2(1);

BEGIN
	l_dummy_char := '0';

	OPEN	CASHPOOL_DETAILS;
	FETCH	CASHPOOL_DETAILS
	INTO 	l_bank_short_code, l_new_acct_number;
	CLOSE	CASHPOOL_DETAILS;

	OPEN	ACCOUNT_DETAILS;
	FETCH	ACCOUNT_DETAILS
	INTO	l_bank_code, l_party_code, l_currency, l_year_calc_type,
		l_portfolio_code, l_int_calc_basis, l_rounding_type,
		l_day_count_type, l_code_combination_id;
	IF	ACCOUNT_DETAILS%NOTFOUND THEN
		CLOSE	ACCOUNT_DETAILS;
		x_return_status := 'N';
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE	ACCOUNT_DETAILS;

	OPEN	DEALER_DETAILS;
	FETCH	DEALER_DETAILS
	INTO	l_created_by;
	CLOSE	DEALER_DETAILS;
	l_updated_by := l_created_by;

	l_counter := 1;
	FOR  rec in acct_number_exists(l_new_acct_number, l_party_code)
	LOOP
		IF ACCT_NUMBER_EXISTS%FOUND THEN
			IF l_counter < 10 THEN
				SELECT	REPLACE(
					rpad(
					l_new_acct_number, 20, l_dummy_char),
					rpad(
					l_new_acct_number, 20, l_dummy_char),
					substrb
					(rpad
					(l_new_acct_number,20, l_dummy_char),
					1,19)||l_counter)
				INTO	l_new_acct_number
				FROM	DUAL;
			ELSIF ((l_counter >= 10) AND (l_counter < 100)) THEN
				SELECT	REPLACE(
					rpad(
					l_new_acct_number, 20, l_dummy_char),
					rpad(
					l_new_acct_number, 20, l_dummy_char),
					substrb
					(rpad
					(l_new_acct_number,20, l_dummy_char),
					1,18)||l_counter)
				INTO	l_new_acct_number
				FROM	DUAL;
			ELSIF ((l_counter >=100) AND (l_counter < 1000)) THEN
				SELECT	REPLACE(
					rpad(
					l_new_acct_number, 20, l_dummy_char),
					rpad(
					l_new_acct_number, 20, l_dummy_char),
					substrb
					(rpad
					(l_new_acct_number,20, l_dummy_char),
					1,17)||l_counter)
				INTO	l_new_acct_number
				FROM	DUAL;
			ELSIF ((l_counter >=1000) AND (l_counter < 10000)) THEN
				SELECT	REPLACE(
					rpad(
					l_new_acct_number, 20, l_dummy_char),
					rpad(
					l_new_acct_number, 20, l_dummy_char),
					substrb
					(rpad
					(l_new_acct_number,20, l_dummy_char),
					1,16)||l_counter)
				INTO	l_new_acct_number
				FROM	DUAL;
			ELSIF ((l_counter >=10000) AND (l_counter <100000)) THEN
				SELECT	REPLACE(
					rpad(
					l_new_acct_number, 20, l_dummy_char),
					rpad(
					l_new_acct_number, 20, l_dummy_char),
					substrb
					(rpad
					(l_new_acct_number,20, l_dummy_char),
					1,15)||l_counter)
				INTO	l_new_acct_number
				FROM	DUAL;
			ELSIF ((l_counter >=100000) AND
					(l_counter <1000000)) THEN
				SELECT	REPLACE(
					rpad(
					l_new_acct_number, 20, l_dummy_char),
					rpad(
					l_new_acct_number, 20, l_dummy_char),
					substrb
					(rpad
					(l_new_acct_number,20, l_dummy_char),
					1,14)||l_counter)
				INTO	l_new_acct_number
				FROM	DUAL;
			END IF;
			l_counter := l_counter + 1;
		END IF;
		EXIT WHEN ACCT_NUMBER_EXISTS%NOTFOUND;
	END LOOP;

	BEGIN
		INSERT INTO XTR_BANK_ACCOUNTS(
			account_number, setoff_account_yn,
			bank_code, party_code, bank_short_code,
			currency,  location, street, year_calc_type,
			portfolio_code, interest_calculation_basis,
			rounding_type, day_count_type,
			code_combination_id, pricing_model,
			authorised, party_type, cashpool_id,
			created_by, created_on,
			updated_by, updated_on)
		VALUES
			(l_new_acct_number, 'Y',
		 	l_bank_code, l_party_code, l_bank_short_code,
		 	l_currency, 'SETOFF ACCOUNT', 'SETOFF ACCOUNT',
		 	l_year_calc_type,
		 	l_portfolio_code, l_int_calc_basis,
		 	l_rounding_type, l_day_count_type,
		 	l_code_combination_id, 'NO_REVAL',
		 	'Y', 'C', p_cashpool_id,
		 	nvl(l_created_by, FND_GLOBAL.user_id), sysdate,
		 	nvl(l_updated_by, FND_GLOBAL.user_id), sysdate);
		EXCEPTION
		WHEN OTHERS THEN
			x_return_status := 'N';
			RAISE FND_API.G_EXC_ERROR;
		END;
	x_return_status := 'Y';

END create_xtr_bank_account;

/**
 * FUNCTION update_xtr_bank_account
 *
 * DESCRIPTION
 *     Updates the dummy account in XTR_BANK_ACCOUNTS
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_cashpool_id                  	Cashpool ID of the Notional Cash Pool
 *					that is being created or updated.
 *     p_bank_account_id		Bank Account ID from CE_BANK_ACCOUNTS
 *					of the Concentration Account of the
 *					Cashpool.
 *   IN/OUT:
 *     x_return_status                  Return status after the call. The
 *                                      status can be Y for success or N for
 *					error.
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   01-26-2005    Rajesh Jose        	o Created.
 */
-- R12 Modified the reference to AP_BANK_ACCOUNTS and AP_BANK_ACCOUNT_ID to CE_BANK_ACCOUNTS and CE_BANK_ACCOUNT_ID
PROCEDURE update_xtr_bank_account(
	p_cashpool_id		IN	CE_CASHPOOLS.CASHPOOL_ID%TYPE,
	p_bank_account_id	IN	CE_BANK_ACCOUNTS.BANK_ACCOUNT_ID%TYPE,
	x_return_status		IN OUT NOCOPY VARCHAR2)
IS

 cursor	account_changed IS
	SELECT 	conc_account_id
	FROM	CE_CASHPOOLS
	WHERE	cashpool_id = p_cashpool_id;

 cursor	changed_account_details IS
	SELECT	xba.bank_code, xba.year_calc_type,
		xba.interest_calculation_basis, xba.rounding_type,
		xba.day_count_type, xba.code_combination_id,
		xpin.set_of_books_id
	FROM	XTR_BANK_ACCOUNTS xba, XTR_PARTY_INFO xpin
	WHERE	ce_bank_account_id =
			p_bank_account_id
	AND	xpin.party_code = xba.party_code
	AND	xpin.party_type = 'C';

 cursor dealer_details IS
	SELECT	dealer_code
	FROM	xtr_dealer_codes
	WHERE	user_id = FND_GLOBAL.USER_ID;

 l_conc_account_id	CE_BANK_ACCOUNTS.BANK_ACCOUNT_ID%TYPE;

 l_bank_code		XTR_BANK_ACCOUNTS.BANK_CODE%TYPE;
 l_year_calc_type	XTR_BANK_ACCOUNTS.YEAR_CALC_TYPE%TYPE;
 l_int_calc_basis	XTR_BANK_ACCOUNTS.INTEREST_CALCULATION_BASIS%TYPE;
 l_rounding_type	XTR_BANK_ACCOUNTS.ROUNDING_TYPE%TYPE;
 l_day_count_type	XTR_BANK_ACCOUNTS.DAY_COUNT_TYPE%TYPE;
 l_code_combination_id	XTR_BANK_ACCOUNTS.CODE_COMBINATION_ID%TYPE;
 l_party_code		XTR_BANK_ACCOUNTS.PARTY_CODE%TYPE;

 l_orig_set_of_books_id	GL_SETS_OF_BOOKS.SET_OF_BOOKS_ID%TYPE;
 l_new_set_of_books_id	GL_SETS_OF_BOOKS.SET_OF_BOOKS_ID%TYPE;

 l_updated_by		XTR_DEALER_CODES.DEALER_CODE%TYPE;

BEGIN
	OPEN	account_changed;
	FETCH	account_changed
	INTO	l_conc_account_id;
	CLOSE	account_changed;

	IF (l_conc_account_id <> p_bank_account_ID) THEN
		OPEN	changed_account_details;
		FETCH	changed_account_details
		INTO	l_bank_code, l_year_calc_type,
			l_int_calc_basis, l_rounding_type,
			l_day_count_type, l_code_combination_id,
			l_new_set_of_books_id;
		CLOSE	changed_account_details;

		BEGIN
		SELECT	set_of_books_id
		INTO	l_orig_set_of_books_id
		FROM	XTR_PARTY_INFO xpin, XTR_BANK_ACCOUNTS xba
		WHERE	xpin.party_code = xba.party_code
		AND	ce_bank_account_id
			= l_conc_account_id
		AND	xpin.party_type = 'C';

		EXCEPTION
		WHEN OTHERS THEN
			x_return_status := 'N';
			RAISE FND_API.G_EXC_ERROR;
		END;
		OPEN	DEALER_DETAILS;
		FETCH	DEALER_DETAILS
		INTO	l_updated_by;
		CLOSE	DEALER_DETAILS;

		IF l_new_set_of_books_id = l_orig_set_of_books_id THEN
			BEGIN
			UPDATE	XTR_BANK_ACCOUNTS
			SET	bank_code = l_bank_code,
				year_calc_type = l_year_calc_type,
				interest_calculation_basis = l_int_calc_basis,
				rounding_type = l_rounding_type,
				day_count_type = l_day_count_type,
				code_combination_id = l_code_combination_id,
				updated_by = nvl(l_updated_by,
						FND_GLOBAL.user_id),
				updated_on = sysdate
			WHERE	cashpool_id = p_cashpool_id
			AND	setoff_account_yn = 'Y';
			EXCEPTION
			WHEN OTHERS THEN
			      x_return_status := 'N';
			      RAISE FND_API.G_EXC_ERROR;
			END;
		ELSE
			BEGIN
			UPDATE	XTR_BANK_ACCOUNTS
			SET	bank_code = l_bank_code,
				year_calc_type = l_year_calc_type,
				interest_calculation_basis = l_int_calc_basis,
				rounding_type = l_rounding_type,
				day_count_type = l_day_count_type,
				updated_by = nvl(l_updated_by,
						FND_GLOBAL.user_id),
				updated_on = sysdate
			WHERE	cashpool_id = p_cashpool_id
			AND	setoff_account_yn = 'Y';
			EXCEPTION
			WHEN OTHERS THEN
			      x_return_status := 'N';
			      RAISE FND_API.G_EXC_ERROR;
			END;
		END IF;
	END IF;
		x_return_status := 'Y';
END update_xtr_bank_account;

END XTR_NOTIONAL_BANK_ACCOUNTS;


/
