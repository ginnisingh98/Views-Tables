--------------------------------------------------------
--  DDL for Package AP_WEB_DB_COUNTRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_COUNTRY_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdbcts.pls 120.5 2005/10/02 20:11:45 albowicz ship $ */

---------------------------------------------------------------------------------------------------
SUBTYPE curr_name                    IS FND_CURRENCIES_VL.name%TYPE;
SUBTYPE curr_currCode                IS FND_CURRENCIES_VL.currency_code%TYPE;
SUBTYPE curr_currFlag                IS FND_CURRENCIES_VL.currency_flag%TYPE;
SUBTYPE curr_precision               IS FND_CURRENCIES_VL.precision%TYPE;
SUBTYPE curr_minAcctUnit             IS FND_CURRENCIES_VL.minimum_accountable_unit%TYPE;
SUBTYPE curr_deriveEffective         IS FND_CURRENCIES_VL.derive_effective%TYPE;
SUBTYPE curr_deriveType              IS FND_CURRENCIES_VL.derive_type%TYPE;
SUBTYPE curr_deriveFactor            IS FND_CURRENCIES_VL.derive_factor%TYPE;

SUBTYPE terr_shortName		IS FND_TERRITORIES_VL.territory_short_name%TYPE;
SUBTYPE terr_code		IS FND_TERRITORIES_VL.territory_code%TYPE;
---------------------------------------------------------------------------------------------------


TYPE CurrencyCodeCursor		IS REF CURSOR;
TYPE CountryListCursor 		IS REF CURSOR;
TYPE CurrencyInfoCursor 	IS REF CURSOR;
TYPE CurrencyPrecisionCursor	IS REF CURSOR;

TYPE country IS RECORD (
     code           FND_TERRITORIES_VL.TERRITORY_CODE%TYPE,
     name           FND_TERRITORIES_VL.TERRITORY_SHORT_NAME%TYPE);

TYPE countries IS TABLE OF country
  INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------------
FUNCTION GetCountryListCursor(
	p_country_list_cursor	OUT NOCOPY	CountryListCursor
) RETURN BOOLEAN;

--------------------------------------------------------------------------------
FUNCTION GetCurrencyPrecision(
	p_reimb_curr_code		IN 	curr_currCode
) RETURN curr_precision;

-------------------------------------------------------------------
FUNCTION GetCurrencyInfoCursor(
	p_currency_info_cursor OUT NOCOPY	CurrencyInfoCursor
) RETURN BOOLEAN;

-------------------------------------------------------------------
FUNCTION GetCurrCodeProperties(
	p_curr_code 		IN  curr_currCode,
	p_curr_name 		OUT NOCOPY  curr_name,
	p_precision 		OUT NOCOPY curr_precision,
	p_minimum_acct_unit 	OUT NOCOPY curr_minAcctUnit
) RETURN BOOLEAN;

-------------------------------------------------------------------
FUNCTION GetCurrencyProperties(
	p_curr_code 		IN  curr_currCode,
	p_curr_name 		OUT NOCOPY curr_name,
	p_precision 		OUT NOCOPY curr_precision,
	p_minimum_acct_unit 	OUT NOCOPY curr_minAcctUnit
) RETURN BOOLEAN;

--------------------------------------------------------------------------------
FUNCTION GetCurrCodeCursor(
		p_curr_code_cursor	OUT NOCOPY	CurrencyCodeCursor
) RETURN BOOLEAN;

END AP_WEB_DB_COUNTRY_PKG;

 

/
