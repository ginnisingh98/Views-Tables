--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_COUNTRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_COUNTRY_PKG" AS
/* $Header: apwdbctb.pls 120.5 2005/10/02 20:11:38 albowicz ship $ */
--------------------------------------------------------------------------------
FUNCTION GetCountryListCursor(
	p_country_list_cursor	OUT NOCOPY	CountryListCursor
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
	OPEN p_country_list_cursor FOR
		SELECT	territory_short_name,
			territory_code
		FROM	fnd_territories_vl;

	return TRUE;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCountryListCursor' );

    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;
END GetCountryListCursor;


--------------------------------------------------------------------------------
FUNCTION GetCurrencyPrecision(
	p_reimb_curr_code		IN 	curr_currCode
) RETURN curr_precision IS
--------------------------------------------------------------------------------

l_curr_precision   	AP_WEB_DB_COUNTRY_PKG.curr_precision;

BEGIN

	SELECT NVL(fndcvl.precision,0) precision
	INTO l_curr_precision
    	FROM   fnd_currencies_vl fndcvl
    	WHERE  fndcvl.currency_code = p_reimb_curr_code;

	return l_curr_precision;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
		RETURN NULL;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCurrencyPrecision' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		RETURN NULL;
END GetCurrencyPrecision;


/* Suggested currency cursor extraction in apwxutlb.pls */
-------------------------------------------------------------------
FUNCTION GetCurrencyInfoCursor(
	p_currency_info_cursor OUT NOCOPY	CurrencyInfoCursor
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN

OPEN p_currency_info_cursor FOR
    SELECT fndcvl.currency_code,
	   fndcvl.name,
	   NVL(fndcvl.precision,0) precision,
           fndcvl.minimum_accountable_unit,
	   fndcvl.derive_factor,
	   fndcvl.derive_effective
    FROM   fnd_currencies_vl fndcvl
    WHERE  fndcvl.enabled_flag = 'Y'
    AND    fndcvl.currency_flag = 'Y'
    AND    trunc(nvl(fndcvl.start_date_active, sysdate)) <= trunc(sysdate)
    AND    trunc(nvl(fndcvl.end_date_active, sysdate)) >= trunc(sysdate)
    ORDER BY UPPER(fndcvl.currency_code);

    return TRUE;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCurrencyInfoCursor' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;
END GetCurrencyInfoCursor;

--------------------------------------------------------------------------------
FUNCTION GetCurrNameForCurrCode(
	p_curr_code	IN	AP_WEB_DB_COUNTRY_PKG.curr_currCode,
	p_curr_name	OUT NOCOPY	AP_WEB_DB_COUNTRY_PKG.curr_name
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
        SELECT name
        INTO   p_curr_name
        FROM   fnd_currencies_vl
        WHERE  currency_code = p_curr_code;

	RETURN TRUE;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCurrNameForCurrCode' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;
END GetCurrNameForCurrCode;

-------------------------------------------------------------------
FUNCTION GetCurrCodeProperties(
	p_curr_code 		IN  curr_currCode,
	p_curr_name 		OUT NOCOPY curr_name,
	p_precision 		OUT NOCOPY curr_precision,
	p_minimum_acct_unit 	OUT NOCOPY curr_minAcctUnit
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
	 SELECT fndcvl.name,
         	NVL(fndcvl.precision,0),
         	fndcvl.minimum_accountable_unit
	 INTO	p_curr_name,
		p_precision,
		p_minimum_acct_unit
         FROM   fnd_currencies_vl fndcvl
	 WHERE	currency_code = p_curr_code;

	return TRUE;
EXCEPTION

	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCurrCodeProperties' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;
END GetCurrCodeProperties;

-------------------------------------------------------------------
FUNCTION GetCurrencyProperties(
	p_curr_code 		IN  curr_currCode,
	p_curr_name 		OUT NOCOPY curr_name,
	p_precision 		OUT NOCOPY curr_precision,
	p_minimum_acct_unit 	OUT NOCOPY curr_minAcctUnit
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN

	SELECT 	fndcvl.name,
         	NVL(fndcvl.precision,0),
         	fndcvl.minimum_accountable_unit
	INTO	p_curr_name,
		p_precision,
		p_minimum_acct_unit
       	FROM   	fnd_currencies_vl fndcvl
	WHERE	currency_code = p_curr_code
      	AND    	fndcvl.enabled_flag = 'Y'
      	AND    	fndcvl.currency_flag = 'Y'
      	AND    	trunc(nvl(fndcvl.start_date_active, sysdate)) <= trunc(sysdate)
      	AND    	trunc(nvl(fndcvl.end_date_active, sysdate)) >= trunc(sysdate);

	RETURN TRUE;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCurrencyProperties' );

    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;
END GetCurrencyProperties;

--------------------------------------------------------------------------------
FUNCTION GetCurrCodeCursor(
		p_curr_code_cursor	OUT NOCOPY	CurrencyCodeCursor
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
	OPEN p_curr_code_cursor FOR
    	SELECT	fndcvl.currency_code
    	FROM   	fnd_currencies_vl fndcvl
-- chiho:1326239:
	WHERE	enabled_flag = 'Y'
    	ORDER BY UPPER(fndcvl.currency_code);

	RETURN TRUE;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCurrCodeCursor' );

    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;
END GetCurrCodeCursor;


END AP_WEB_DB_COUNTRY_PKG;

/
