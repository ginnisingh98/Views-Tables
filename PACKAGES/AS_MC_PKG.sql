--------------------------------------------------------
--  DDL for Package AS_MC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_MC_PKG" AUTHID CURRENT_USER AS
/* $Header: asxmcmcs.pls 115.8 2002/12/13 10:58:09 nkamble ship $ */
-- Package
--       AS_MC_PKG
--
-- PURPOSE
--	Creates package specification for multi-currency api
-- HISTORY
--	14-Sep-1998	J. Shang	Created
--   13-Nov-1998    J. Shang  Add three new functions: get_euro_info
--											format_amount
--											unformat_amount
--
--   02-Dec-1999    CHSIN     Change G_NEG_MAX from -9.99E125 to -9.99E120 for Prj. Mona Lisa
--                            solve UI calling get_opportunity  NumberBytesToBigDecimal exception problem
--
-- Exceptions
--
-- User defined exceptions for as_mc_pkg:
--
-- INVALID_DAILY_CONVERSION_TYPE - the profile AS_MC_DAILY_CONVERSION_TYPE is not set
-- INVALID_FORECAST_CALENDAR     - the profile AS_MC_FORECAST_CALENDAR is not set
-- INVALID_PERIOD		 - the period is invalid

INVALID_DAILY_CONVERSION_TYPE		EXCEPTION;
INVALID_FORECAST_CALENDAR		EXCEPTION;
INVALID_PERIOD				EXCEPTION;

G_NEG_MAX  CONSTANT NUMBER := -9.99E120;

-- Start of Comments
--
-- API name	: convert_amount_daily
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes from and to currencies, conversion date, amount and Max Roll
--	days. It returns the amount converted into the appropriate currency. The
--	converted amount is calculated in compliance with the triangulation tule.
--
-- Parameters	:
-- IN		:
--    p_from_currency	IN VARCHAR2 Required -- From currency
--    p_to_currency     IN VARCHAR2 Required -- To currency
--    p_conversion_date	IN DATE     Required -- Conversion date
--    p_amount		IN NUMBER   Required -- Amount to be converted
--    p_max_roll_days	IN NUMBER   Optional -- Maximum days to roll back for a rate
--
-- Version	:
--
-- HISTORY
--	14-Sep-1998	J. Shang	Created
-- Note     :
--    In this function, a cursor is defined to search a closest rate. The query
--    follows the searching rule defined in GL_CURRENCY_API. So, if the rule is
--    changed in GL_CURRENCY_API, this cursor has to be changed also.
--End of Comments

FUNCTION convert_amount_daily (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_date	IN	DATE,
            p_amount		IN	NUMBER,
            p_max_roll_days	IN	NUMBER DEFAULT 0) RETURN NUMBER;

-- Start of Comments
--
-- API name	: convert_amount_daily_sql
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes from and to currencies, conversion date, amount and Max Roll
--	days. It returns the amount converted into the appropriate currency. The
--	converted amount is calculated in compliance with the triangulation tule.
--	This api has the same function as the above api but is used in SQL statement.
--
-- Parameters	:
-- IN		:
--    p_from_currency	IN VARCHAR2 Required -- From currency
--    p_to_currency	IN VARCHAR2 Required -- To currency
--    p_conversion_date	IN DATE     Required -- Conversion date
--    p_amount		IN NUMBER   Required -- Amount to be converted
--    p_max_roll_days	IN NUMBER   Optional -- Maximum days to roll back for a rate
--
-- Version 	:
--
-- HISTORY
--	14-Sep-1998	J. Shang	Created
-- Note     :
--    In this function, a cursor is defined to search a closest rate. The query
--    follows the searching rule defined in GL_CURRENCY_API. So, if the rule is
--    changed in GL_CURRENCY_API, this cursor has to be changed also.
--
-- End of Comments

FUNCTION convert_amount_daily_sql (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_date	IN	DATE,
            p_amount		IN	NUMBER,
            p_max_roll_days	IN	NUMBER DEFAULT 0) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(convert_amount_daily_sql, WNDS,WNPS);

-- Start of Comments
--
-- API name	: convert_amount_daily_sql
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes from and to currencies, conversion date, amount, Max Roll
--	days and conversion type. It returns the amount converted into the appropriate
--      currency. The converted amount is calculated in compliance with the triangulation
--      tule.This api has the same function as the above api but is used in SQL statement.
--
-- Parameters	:
-- IN		:
--    p_from_currency	IN VARCHAR2 Required -- From currency
--    p_to_currency	IN VARCHAR2 Required -- To currency
--    p_conversion_date	IN DATE     Required -- Conversion date
--    p_amount		IN NUMBER   Required -- Amount to be converted
--    p_max_roll_days	IN NUMBER   Optional -- Maximum days to roll back for a rate
--    p_conversion_type IN VARCHAR2 Required -- Conversion Type
--
-- Version 	:
--
-- HISTORY
--	14-MAR-00	XDING	Created
-- Note     :
--    In this function, a cursor is defined to search a closest rate. The query
--    follows the searching rule defined in GL_CURRENCY_API. So, if the rule is
--    changed in GL_CURRENCY_API, this cursor has to be changed also.
--
-- End of Comments

FUNCTION convert_amount_daily_sql (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_date	IN	DATE,
            p_amount		IN	NUMBER,
            p_max_roll_days	IN	NUMBER DEFAULT 0,
	    p_conversion_type	IN      VARCHAR2 ) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(convert_amount_daily_sql, WNDS,WNPS);

-- Start of Comments
--
-- API name	: convert_amount_period
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes from and to currencies, conversion period and amount
--	It returns the amount converted into the appropriate currency based on
--	pseudo period. The converted amount is calculated in compliance with
--	the triangulation tule.
--
-- Parameters	:
-- IN		:
--    p_from_currency		IN VARCHAR2 Required -- From currency
--    p_to_currency		IN VARCHAR2 Required -- To currency
--    p_conversion_period	IN VARCHAR2 Required -- Conversion period
--    p_amount			IN NUMBER   Required -- Amount to be converted
--
-- Version 	:
--
-- HISTORY
--	14-Sep-1998	J. Shang	Created
--
-- End of Comments

FUNCTION convert_amount_period (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_period	IN	VARCHAR2,
            p_amount		IN	NUMBER) RETURN NUMBER;

-- Start of Comments
--
-- API name	: convert_amount_period_sql
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes from and to currencies, conversion period and amount
--	It returns the amount converted into the appropriate currency based on
--	pseudo period. The converted amount is calculated in compliance with
--	the triangulation tule. This api has the same function as the above
--	api but is used in SQL statement.
--
-- Parameters	:
-- IN		:
--    p_from_currency		IN VARCHAR2 Required -- From currency
--    p_to_currency		IN VARCHAR2 Required -- To currency
--    p_conversion_period	IN VARCHAR2 Required -- Conversion period
--    p_amount			IN NUMBER   Required -- Amount to be converted
--
-- Version 	:
--
-- HISTORY
--	14-Sep-1998	J. Shang	Created
--
-- End of Comments

FUNCTION convert_amount_period_sql (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_period	IN	VARCHAR2,
            p_amount		IN	NUMBER) RETURN NUMBER;
PRAGMA	RESTRICT_REFERENCES(convert_amount_period_sql, WNDS, WNPS);

-- Start of Comments
--
-- API name	: convert_amount_period_sql
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes from and to currencies, conversion date, type and amount
--	It returns the amount converted into the appropriate currency based on
--	pseudo period. The converted amount is calculated in compliance with
--	the triangulation tule. This api has the same function as the above
--	api but is used in SQL statement.
--
-- Parameters	:
-- IN		:
--    p_from_currency		IN VARCHAR2 Required -- From currency
--    p_to_currency		IN VARCHAR2 Required -- To currency
--    p_conversion_date 	IN DATE     Required -- Conversion date
--    p_conversion_type		IN VARCHAR2 Required -- Conversion type
--    p_amount			IN NUMBER   Required -- Amount to be converted
--
-- Version 	:
--
-- HISTORY
--	14-MAR-00	XDING	Created
--
-- End of Comments

FUNCTION convert_amount_period_sql (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_date	IN	DATE,
	    p_conversion_type   IN 	VARCHAR2,
            p_amount		IN	NUMBER) RETURN NUMBER;
PRAGMA	RESTRICT_REFERENCES(convert_amount_period_sql, WNDS, WNPS);

-- Start of Comments
--
-- API name	: get_daily_rate
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes from and to currencies, conversion date, and Max Roll
--	days. It returns the rate from the from currency to the to currency.
--
-- Parameters	:
-- IN		:
--    p_from_currency	IN VARCHAR2 Required -- From currency
--    p_to_currency	IN VARCHAR2 Required -- To currency
--    p_conversion_date	IN DATE     Required -- Conversion date
--    p_max_roll_days	IN NUMBER   Optional -- Maximum days to roll back for a rate
--
-- Version 	:
--
-- HISTORY
--	14-Sep-1998	J. Shang	Created
-- Note     :
--    In this function, a cursor is defined to search a closest rate. The query
--    follows the searching rule defined in GL_CURRENCY_API. So, if the rule is
--    changed in GL_CURRENCY_API, this cursor has to be changed also.
--
-- End of Comments

FUNCTION get_daily_rate (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_date	IN	DATE,
            p_max_roll_days	IN	NUMBER DEFAULT 0) RETURN NUMBER;

-- Start of Comments
--
-- API name	: get_daily_rate_sql
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes from and to currencies, conversion date, and Max Roll
--	days. It returns the rate from the from currency to the to currency.
--	This api has the same function as the above api but is used in SQL
--	statement.
--
-- Parameters	:
-- IN		:
--    p_from_currency	IN VARCHAR2 Required -- From currency
--    p_to_currency	IN VARCHAR2 Required -- To currency
--    p_conversion_date	IN DATE     Required --Conversion date
--    p_max_roll_days	IN NUMBER   Optional --Maximum days to roll back for a rate
-- Version 	:
--
-- HISTORY
--	14-Sep-1998	J. Shang	Created
-- Note     :
--    In this function, a cursor is defined to search a closest rate. The query
--    follows the searching rule defined in GL_CURRENCY_API. So, if the rule is
--    changed in GL_CURRENCY_API, this cursor has to be changed also.
--
-- End of Comments

FUNCTION get_daily_rate_sql (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_date	IN	DATE,
            p_max_roll_days	IN	NUMBER DEFAULT 0) RETURN NUMBER;
PRAGMA	RESTRICT_REFERENCES(get_daily_rate_sql, WNDS);

-- Start of Comments
--
-- API name	: get_period_rate
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes from and to currencies, conversion period. It returns the
--	rate from the from currency to the to currency based on pseudo period rate.
--
-- Parameters	:
-- IN		:
--    p_from_currency		IN VARCHAR2 Required -- From currency
--    p_to_currency		IN VARCHAR2 Required -- To currency
--    p_conversion_period	IN VARCHAR2 Required -- Conversion period
-- Version 	:
--
-- HISTORY
--	14-Sep-1998	J. Shang	Created
--
-- End of Comments

FUNCTION get_period_rate (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_period	IN	VARCHAR2) RETURN NUMBER;

-- Start of Comments
--
-- API name	: get_period_rate_sql
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes from and to currencies, conversion period. It returns the
--	rate from the from currency to the to currency based on pseudo period rate.
--	This api has the same function as the above api but is used in SQL
--	statement.
-- Parameters	:
-- IN		:
--    p_from_currency		IN VARCHAR2 Required -- From currency
--    p_to_currency		IN VARCHAR2 Required -- To currency
--    p_conversion_period	IN VARCHAR2 Required -- Conversion period
-- Version 	:
--
-- HISTORY
--	14-Sep-1998	J. Shang	Created
--
-- End of Comments

FUNCTION get_period_rate_sql (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_period	IN	VARCHAR2) RETURN NUMBER;
PRAGMA	RESTRICT_REFERENCES(get_period_rate_sql, WNDS);

FUNCTION daily_rate_exists (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_date	IN	DATE,
            p_max_roll_days	IN	NUMBER DEFAULT 0,
	    x_rate_date		OUT NOCOPY	DATE) RETURN VARCHAR2;

-- Start of Comments
--
-- API name	: period_rate_exists
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes from and to currencies, conversion period. It checks if there
--	is a rate from the from currency to the to currency based on pseudo period rate.
--
-- Parameters	:
-- IN		:
--    p_from_currency		IN VARCHAR2 Required -- From currency
--    p_to_currency		IN VARCHAR2 Required -- To currency
--    p_conversion_period	IN VARCHAR2 Required -- Conversion period
-- Version 	:
--
-- HISTORY
--	14-Sep-1998	J. Shang	Created
--
-- End of Comments

FUNCTION period_rate_exists (
            p_from_currency     IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_period	IN	VARCHAR2) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(period_rate_exists, WNDS);

-- Start of Comments
--
-- API name	: get_period_info
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes conversion period and returns the information of this period,
--	such as, period type, start date and end date.
--
-- Parameters	:
-- IN		:
--    p_period		IN VARCHAR2 -- Conversion period
-- OUT
--    x_period_type	OUT VARCHAR2 -- Conversion period type
--    x_period_date	OUT DATE     -- Converion date
-- Version 	:
--
-- History	:
--	22-Sep-98	J. Shang	Created
-- End of Comments
--
PROCEDURE get_period_info(
	p_period	IN	VARCHAR2,
	x_period_type	OUT NOCOPY	VARCHAR2,
	x_period_date	OUT NOCOPY	DATE);
PRAGMA RESTRICT_REFERENCES(get_period_info,WNDS,WNPS);

-- Start of Comments
--
-- API name	: get_conversion_type
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes conversion period type and returns the conversion type for
--	this period type.
--
-- Parameters	:
-- IN		:
--    p_period_type	IN VARCHAR2 -- Conversion period type
-- Version 	:
--
-- History	:
--	22-Sep-98	J. Shang	Created
--      22-Oct-98       J. Shang        Change name of the rate mapping table
-- End of Comments
--
FUNCTION get_conversion_type(
	p_period_type	IN	VARCHAR2 ) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_conversion_type,WNDS,WNPS);

-- Start of Comments
--
-- API name	: get_euro_info
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes currency code and the effective date, it will get the currency
--	type information about the given currency
--
-- Parameters	:
-- IN		:
--    p_currency_code	IN VARCHAR2 -- Currency to be checked
--    p_effective_date	IN DATE	    -- Effective date
--    x_currency_type   OUT VARCHAR2 -- Type of the currency. Euro currency, set to 'EURO'
--							      Emu currency, set to 'EMU'
--							      Other currencies,set to 'OTHER'
--							      Invalid currency, set to NULL
--    x_conversion_rate	OUT NUMBER -- Fixed rate for conversion
-- Version 	:
--
-- History	:
--	03-Nov-98	J. Shang	Created
-- Note		:
--    This is temporary solution for OSM, and the procedure follows the similar privatre
--    procedure, get_info, defined in GL.
-- End of Comments
--
PROCEDURE get_euro_info(p_currency_code	IN VARCHAR2,
		   p_effective_date	IN DATE,
		   x_currency_type	OUT NOCOPY VARCHAR2,
		   x_conversion_rate	OUT NOCOPY NUMBER);

-- Start of Comments
--
-- API name	: format_amount
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes currency code and amount to be formatted. It returns the amount
--      converted into the appropriate format. The format mask is get from foundation
--      library.
--
-- Parameters	:
-- IN		:
--    p_currency_code	IN VARCHAR2 -- Currency code to get format mask
--    p_amount		IN NUMBER -- Amount to be formatted
--    p_length		IN NUMBER -- The maximum number of characters available to hold
--				     the formatted value
--
-- Version	:
--
-- History	:
--	05-Nov-98	J. Shang	Created
-- Note     :
--
-- End of Comments
--
FUNCTION format_amount(p_currency_code	IN VARCHAR2,
			 p_amount		IN NUMBER,
			 p_length		IN NUMBER) RETURN VARCHAR2;

-- Start of Comments
--
-- API name	: unformat_amount
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes currency code and amount to be unformatted. It returns the amount
--      converted into a number. The format mask is get from foundation library.
--
-- Parameters	:
-- IN		:
--    p_currency_code	IN VARCHAR2 -- Currency code to get format mask
--    p_amount		IN NUMBER -- Amount to be formatted
--
-- Version	:
--
-- History	:
--	12-Nov-98	J. Shang	Created
-- Note     :
--   Conversion rules :
--        1. For pass-in amount without format, such as, 12345.23, 58.6, this function will
--		   convert the amount using format mask and then do conversion again to get the amount
--		   in NUMBER type.
--	     2. For pass-in amount with exact format, the function will do conversion using the format
--		   mask and return the amount in NUMBER type.
--		3. For other situation, like an amount in invalid format, the fuction will return NEG_MAX_NUM
--		   define in this package.
-- End of Comments
--
FUNCTION unformat_amount(p_currency_code	IN VARCHAR2,
			   p_amount		IN VARCHAR2) RETURN NUMBER;

-- Start of Comments
--
-- API name	: convert_group_amounts_daily
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes from currency, to currency, conversion date and a group of amount
--	to be converted. It returns the converted amount. This procedure is mainly to save
--	communication time between form and database
-- Parameters	:
-- IN		:
--    p_from_currency     IN  VARCHAR2
--    p_to_currency       IN  VARCHAR2
--    p_conversion_date   IN  DATE
--    p_amount1           IN  NUMBER
--    p_amount2           IN  NUMBER
--    p_amount3           IN  NUMBER
--    p_amount4           IN  NUMBER
--    p_amount5           IN  NUMBER
-- OUT
--    p_out_amount1       OUT NUMBER
--    p_out_amount2       OUT NUMBER
--    p_out_amount3       OUT NUMBER
--    p_out_amount4       OUT NUMBER
--    p_out_amount5       OUT NUMBER
--
-- Version	:
--
-- History	:
--	11-Dec-98	J. Shang	Created
-- Note     :
--	The possible exceptions generated from this procedure are
--		gl_currency_api.NO_RATE
--		gl_currency_api.INVALID_CURRENCY
--		as_mc_pkg.INVALID_DAILY_CONVERSION_TYPE
-- End of Comments
--
PROCEDURE convert_group_amounts_daily (
            p_from_currency     IN      VARCHAR2,
            p_to_currency       IN      VARCHAR2,
            p_conversion_date   IN      DATE,
            p_amount1           IN      NUMBER,
            p_amount2           IN      NUMBER,
            p_amount3           IN      NUMBER,
            p_amount4           IN      NUMBER,
            p_amount5           IN      NUMBER,
            p_out_amount1       OUT NOCOPY     NUMBER,
            p_out_amount2       OUT NOCOPY     NUMBER,
            p_out_amount3       OUT NOCOPY     NUMBER,
            p_out_amount4       OUT NOCOPY     NUMBER,
            p_out_amount5       OUT NOCOPY     NUMBER);

END AS_MC_PKG;

 

/
