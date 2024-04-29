--------------------------------------------------------
--  DDL for Package Body AS_MC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_MC_PKG" AS
/* $Header: asxmcmcb.pls 115.10 2002/12/13 11:01:06 nkamble ship $ */
-- Package
--       AS_MC_PKG
--
-- PURPOSE
--	Creates package body for multi-currency api
-- HISTORY
--	22-Sep-98	J. Shang	Created
--   13-Nov-98 J. Shang  Add three new functions : get_euro_info
--										 format_amount
--										 unformat_amount
--   14-APR-00 SAGHOSH changed the code to match open and close cursor
--	BUG# 1270192

--G_NEG_MAX  CONSTANT NUMBER := -9.99E125; -- -9.99999E125;

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
--    p_from_currency	IN VARCHAR2 -- From currency
--    p_to_currency     IN VARCHAR2 -- To currency
--    p_conversion_date	IN DATE     -- Conversion date
--    p_amount		IN NUMBER   -- Amount to be converted
--    p_max_roll_days	IN NUMBER   -- Maximum days to roll back for a rate
--
-- Version	:
--
-- History	:
--	22-Sep-98	J. Shang	Created
-- Note     :
--      Using of p_max_roll_days in daily conversion:
--	When a rate for the conversion date is undefined, p_max_roll_days will be
--	used to find an alternitive rate to do the conversion.
--	1. If it is a positive number, the function will look backward from the
--      conversion date for the most recent date on which a rate is defined.
--	2. If it is a negative number, the function will look backward without any
--      date limit to find the most recent date on which a rate is defined.
--	3. If it is zero, the funtion doesn't look backward. This is the default value.
--	The above definition follows rules defined in GL_CURRENCY_API.
-- End of Comments
--
FUNCTION convert_amount_daily (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_date	IN	DATE,
            p_amount		IN	NUMBER,
            p_max_roll_days	IN	NUMBER DEFAULT 0) RETURN NUMBER IS

            l_converted_amount	NUMBER;
	    l_conversion_type   VARCHAR2(30);
BEGIN
	-- Check if both currencies are identical
	IF (p_from_currency = p_to_currency) THEN
	   return(p_amount);
	END IF;
	-- Decide the value of AS_MC_DAILY_CONVERSION_TYPE is valid
	l_conversion_type := FND_PROFILE.value('AS_MC_DAILY_CONVERSION_TYPE');
	IF (l_conversion_type IS NULL) THEN
	   raise INVALID_DAILY_CONVERSION_TYPE;
	END IF;
	-- Call GL_CURRENCY_API to do conversion
	l_converted_amount := gl_currency_api.convert_closest_amount_sql(p_from_currency,
		p_to_currency,p_conversion_date,l_conversion_type,0,p_amount,p_max_roll_days);
	IF l_converted_amount = -1 THEN
	   raise gl_currency_api.NO_RATE;
	ELSIF l_converted_amount = -2 THEN
	   raise  gl_currency_api.INVALID_CURRENCY;
	END IF;
	return(l_converted_amount);

END convert_amount_daily;

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
--    p_from_currency	IN VARCHAR2 -- From currency
--    p_to_currency	IN VARCHAR2 -- To currency
--    p_conversion_date	IN DATE     -- Conversion date
--    p_amount		IN NUMBER   -- Amount to be converted
--    p_max_roll_days	IN NUMBER   -- Maximum days to roll back for a rate
-- History	:
--	22-Sep-98	J. Shang	Created
-- Version 	:
--
-- Note		:
--	The using of p_max_roll_days follows the rules described in convert_amount_daily
-- End of Comments
--
FUNCTION convert_amount_daily_sql (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_date	IN	DATE,
            p_amount		IN	NUMBER,
            p_max_roll_days	IN	NUMBER DEFAULT 0) RETURN NUMBER IS

	l_converted_amount	NUMBER;
        l_conversion_type	VARCHAR2(30);
BEGIN
	-- Check if both currencies are identical
	IF (p_from_currency = p_to_currency) THEN
	   return(p_amount);
	END IF;
	-- Decide the value of AS_MC_DAILY_CONVERSION_TYPE is valid
	l_conversion_type := fnd_profile.value_WNPS('AS_MC_DAILY_CONVERSION_TYPE');
	IF (l_conversion_type IS NULL) THEN
	   raise INVALID_DAILY_CONVERSION_TYPE;
	END IF;
        -- Call GL_CURRENCY_API to do conversion
	l_converted_amount := gl_currency_api.convert_closest_amount_sql(p_from_currency,
		p_to_currency,p_conversion_date,l_conversion_type,0,p_amount,p_max_roll_days);
	IF l_converted_amount = -1 THEN
	   l_converted_amount := G_NEG_MAX;
	ELSIF l_converted_amount = -2 THEN
	      l_converted_amount := G_NEG_MAX;
	END IF;
	RETURN(l_converted_amount);

EXCEPTION
	WHEN INVALID_DAILY_CONVERSION_TYPE THEN
	    return(G_NEG_MAX);
	WHEN OTHERS THEN
	    return(G_NEG_MAX);
END convert_amount_daily_sql;

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
--    p_from_currency	IN VARCHAR2 -- From currency
--    p_to_currency	IN VARCHAR2 -- To currency
--    p_conversion_date	IN DATE     -- Conversion date
--    p_amount		IN NUMBER   -- Amount to be converted
--    p_max_roll_days	IN NUMBER   -- Maximum days to roll back for a rate
--    p_conversion_type IN VARCHAR2 -- Conversion Type
-- History	:
--      14-MAR-00 	XDING	Created
-- Version 	:
--
-- Note		:
--	The using of p_max_roll_days follows the rules described in convert_amount_daily
-- End of Comments
--
FUNCTION convert_amount_daily_sql (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_date	IN	DATE,
            p_amount		IN	NUMBER,
            p_max_roll_days	IN	NUMBER DEFAULT 0,
	    p_conversion_type	IN	VARCHAR2 ) RETURN NUMBER IS

	l_converted_amount	NUMBER;
BEGIN
	-- Check if both currencies are identical
	IF (p_from_currency = p_to_currency) THEN
	   return(p_amount);
	END IF;

	IF (p_conversion_type IS NULL) THEN
	   raise INVALID_DAILY_CONVERSION_TYPE;
	END IF;
        -- Call GL_CURRENCY_API to do conversion
	l_converted_amount := gl_currency_api.convert_closest_amount_sql(p_from_currency,
		p_to_currency,p_conversion_date,p_conversion_type,0,p_amount,p_max_roll_days);
	IF l_converted_amount = -1 THEN
	   l_converted_amount := G_NEG_MAX;
	ELSIF l_converted_amount = -2 THEN
	      l_converted_amount := G_NEG_MAX;
	END IF;
	RETURN(l_converted_amount);

EXCEPTION
	WHEN INVALID_DAILY_CONVERSION_TYPE THEN
	    return(G_NEG_MAX);
	WHEN OTHERS THEN
	    return(G_NEG_MAX);
END convert_amount_daily_sql;

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
	x_period_date	OUT NOCOPY	DATE) IS

	l_start_date	DATE;
	l_end_date	DATE;
	l_calendar	VARCHAR2(15);
	l_date_mapping	VARCHAR2(1);
	l_period	VARCHAR2(15);
	CURSOR l_period_csr IS
	SELECT PERIOD_TYPE, START_DATE, END_DATE
	FROM GL_PERIODS
	WHERE PERIOD_SET_NAME = l_calendar
	AND PERIOD_NAME = l_period;
BEGIN
	l_calendar := FND_PROFILE.value_WNPS('AS_FORECAST_CALENDAR');
	IF (l_calendar IS NULL) THEN
	   raise INVALID_FORECAST_CALENDAR;
	END IF;
	l_date_mapping := FND_PROFILE.value_WNPS('AS_MC_DATE_MAPPING_TYPE');
	l_period := p_period;
	OPEN l_period_csr;
	FETCH l_period_csr INTO x_period_type, l_start_date, l_end_date;
	IF NOT l_period_csr%FOUND THEN
	   --SAGHOSH 4/14/00
	   CLOSE l_period_csr ;
	   raise INVALID_PERIOD;
	END IF;
	--SAGHOSH 4/14/00
	CLOSE l_period_csr ;
	IF l_date_mapping = 'E' THEN
		x_period_date := l_end_date;
	ELSE
		x_period_date := l_start_date;
	END IF;
END get_period_info;

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
--   22-Oct-98 J. Shang  Change name of the rate mapping table
-- End of Comments
--

FUNCTION get_conversion_type(
	p_period_type	IN	VARCHAR2 ) RETURN VARCHAR2 IS

	l_conversion_type	VARCHAR2(30);
	l_calendar		VARCHAR2(15);
	l_period_type		VARCHAR2(15);
	CURSOR l_conversion_csr IS
		SELECT CONVERSION_TYPE
		FROM AS_MC_TYPE_MAPPINGS
		WHERE PERIOD_SET_NAME = l_calendar
		AND PERIOD_TYPE = l_period_type;
BEGIN
	l_calendar := FND_PROFILE.value_WNPS('AS_FORECAST_CALENDAR');
	IF (l_calendar IS NULL) THEN
	   raise INVALID_FORECAST_CALENDAR;
	END IF;
	l_period_type := p_period_type;
	OPEN l_conversion_csr;
	FETCH l_conversion_csr INTO l_conversion_type;
	IF NOT l_conversion_csr%FOUND THEN
	   --SAGHOSH 4/14/00
	   CLOSE l_conversion_csr;
	   raise INVALID_PERIOD;
	END IF;
	CLOSE l_conversion_csr;
	return(l_conversion_type);
END get_conversion_type;

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
--    p_from_currency		IN VARCHAR2 -- From currency
--    p_to_currency		IN VARCHAR2 -- To currency
--    p_conversion_period	IN VARCHAR2 -- Conversion period
--    p_amount			IN NUMBER   -- Amount to be converted
--
-- Version 	:
--
-- History	:
--	22-Sep-98	J. Shang	Created
-- End of Comments
--
FUNCTION convert_amount_period (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_period	IN	VARCHAR2,
            p_amount		IN	NUMBER) RETURN NUMBER IS

	l_conversion_type	VARCHAR2(30);
	l_period_type		VARCHAR2(15);
	l_conversion_date	DATE;
	l_converted_amount	NUMBER;
BEGIN
	-- Check if both currencies are identical
	IF (p_from_currency = p_to_currency) THEN
	   RETURN(p_amount);
	END IF;
	get_period_info(p_conversion_period, l_period_type, l_conversion_date);
	l_conversion_type := get_conversion_type(l_period_type);
        -- Call GL_CURRENCY_API to do conversion
	l_converted_amount := gl_currency_api.convert_amount(p_from_currency,p_to_currency,
				l_conversion_date, l_conversion_type, p_amount);
	RETURN(l_converted_amount);
END convert_amount_period;

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
--    p_from_currency		IN VARCHAR2 -- From currency
--    p_to_currency		IN VARCHAR2 -- To currency
--    p_conversion_period	IN VARCHAR2 -- Conversion period
--    p_amount			IN NUMBER   -- Amount to be converted
--
-- Version 	:
--
-- History	:
--	22-Sep-98	J. Shang	Created
-- End of Comments
--
FUNCTION convert_amount_period_sql (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_period	IN	VARCHAR2,
            p_amount		IN	NUMBER) RETURN NUMBER IS

	l_conversion_type	VARCHAR2(30);
	l_period_type		VARCHAR2(15);
	l_conversion_date	DATE;
	l_converted_amount	NUMBER;
BEGIN
	-- Check if both currencies are identical
	IF (p_from_currency = p_to_currency) THEN
	   RETURN(p_amount);
	END IF;
	-- API Body
	get_period_info(p_conversion_period, l_period_type, l_conversion_date);
	l_conversion_type := get_conversion_type(l_period_type);
	l_converted_amount := gl_currency_api.convert_amount(p_from_currency,p_to_currency,
				l_conversion_date, l_conversion_type, p_amount);
	RETURN(l_converted_amount);
EXCEPTION
	WHEN gl_currency_api.NO_RATE THEN
		return(G_NEG_MAX);
	WHEN gl_currency_api.INVALID_CURRENCY THEN
		return(G_NEG_MAX);
	WHEN INVALID_PERIOD THEN
		return(G_NEG_MAX);
	WHEN INVALID_FORECAST_CALENDAR THEN
		return(G_NEG_MAX);
	WHEN OTHERS THEN
		return(G_NEG_MAX);
END convert_amount_period_sql;

-- Start of Comments
--
-- API name	: convert_amount_period_sql
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes from and to currencies, conversion date,type and amount
--	It returns the amount converted into the appropriate currency based on
--	pseudo period. The converted amount is calculated in compliance with
--	the triangulation tule. This api has the same function as the above
--	api but is used in SQL statement.
--
-- Parameters	:
-- IN		:
--    p_from_currency		IN VARCHAR2 -- From currency
--    p_to_currency		IN VARCHAR2 -- To currency
--    p_conversion_date		IN DATE     -- Conversion date
--    p_conversion_type 	IN VARCHAR2 -- Conversion type
--    p_amount			IN NUMBER   -- Amount to be converted
--
-- Version 	:
--
-- History	:
--	14-MAR-00	XDING	Created
-- End of Comments
--
FUNCTION convert_amount_period_sql (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_date	IN	DATE,
	    p_conversion_type   IN      VARCHAR2,
            p_amount		IN	NUMBER) RETURN NUMBER IS

	l_converted_amount	NUMBER;
BEGIN
	-- Check if both currencies are identical
	IF (p_from_currency = p_to_currency) THEN
	   RETURN(p_amount);
	END IF;
	-- API Body
	l_converted_amount := gl_currency_api.convert_amount(p_from_currency,p_to_currency,
				p_conversion_date, p_conversion_type, p_amount);
	RETURN(l_converted_amount);
EXCEPTION
	WHEN gl_currency_api.NO_RATE THEN
		return(G_NEG_MAX);
	WHEN gl_currency_api.INVALID_CURRENCY THEN
		return(G_NEG_MAX);
	WHEN INVALID_PERIOD THEN
		return(G_NEG_MAX);
	WHEN INVALID_FORECAST_CALENDAR THEN
		return(G_NEG_MAX);
	WHEN OTHERS THEN
		return(G_NEG_MAX);
END convert_amount_period_sql;

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
--    p_from_currency	IN VARCHAR2 -- From currency
--    p_to_currency	IN VARCHAR2 -- To currency
--    p_conversion_date	IN DATE     -- Conversion date
--    p_max_roll_days	IN NUMBER   -- Maximum days to roll back for a rate
--
-- Version 	:
--
-- Note		:
--	The using of p_max_roll_days follows the rules described in convert_amount_daily
--
-- History	:
--	22-Sep-98	J. Shang	Created
-- End of Comments
--
FUNCTION get_daily_rate (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_date	IN	DATE,
            p_max_roll_days	IN	NUMBER DEFAULT 0) RETURN NUMBER IS

 	l_conversion_rate	NUMBER;
	l_conversion_type	VARCHAR2(30);

BEGIN
	-- Check if both currencies are identical
	IF (p_from_currency = p_to_currency) THEN
	   RETURN(1);
	END IF;
	-- API Body
	l_conversion_type := FND_PROFILE.value('AS_MC_DAILY_CONVERSION_TYPE');
	IF (l_conversion_type IS NULL) THEN
	   raise INVALID_DAILY_CONVERSION_TYPE;
	END IF;
	l_conversion_rate := gl_currency_api.get_closest_rate(p_from_currency, p_to_currency,
                            p_conversion_date,  l_conversion_type, p_max_roll_days);
	return(l_conversion_rate);
END get_daily_rate;

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
--    p_from_currency	IN VARCHAR2 -- From currency
--    p_to_currency	IN VARCHAR2 -- To currency
--    p_conversion_date	IN DATE --Conversion date
--    p_max_roll_days	IN NUMBER --Maximum days to roll back for a rate
-- Version 	:
--
-- Note		:
--	The using of p_max_roll_days follows the rules described in convert_amount_daily
-- History	:
--	22-Sep-98	J. Shang	Created
-- End of Comments
--
FUNCTION get_daily_rate_sql (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_date	IN	DATE,
            p_max_roll_days	IN	NUMBER DEFAULT 0) RETURN NUMBER IS

	l_conversion_rate NUMBER;
	l_conversion_type VARCHAR2(30);
BEGIN
	-- Check if both currencies are identical
	IF (p_from_currency = p_to_currency) THEN
	   RETURN(1);
	END IF;
	-- API Body
	l_conversion_type := FND_PROFILE.value('AS_MC_DAILY_CONVERSION_TYPE');
	IF (l_conversion_type IS NULL) THEN
	   raise INVALID_DAILY_CONVERSION_TYPE;
	END IF;
	l_conversion_rate := gl_currency_api.get_closest_rate(p_from_currency, p_to_currency,
	           p_conversion_date, l_conversion_type, p_max_roll_days);
	return(l_conversion_rate);
EXCEPTION
	WHEN gl_currency_api.NO_RATE THEN
	     return(G_NEG_MAX);
	WHEN gl_currency_api.INVALID_CURRENCY THEN
	     return(G_NEG_MAX);
        WHEN INVALID_DAILY_CONVERSION_TYPE THEN
	     return(G_NEG_MAX);
	WHEN OTHERS THEN
		return(G_NEG_MAX);
END get_daily_rate_sql;

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
--    p_from_currency		IN VARCHAR2 -- From currency
--    p_to_currency		IN VARCHAR2 -- To currency
--    p_conversion_period	IN VARCHAR2 -- Conversion period
-- Version 	:
--
-- History	:
--	22-Sep-98	J. Shang	Created
-- End of Comments
--
FUNCTION get_period_rate (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_period	IN	VARCHAR2) RETURN NUMBER IS

	l_period_type		VARCHAR2(15);
	l_conversion_date	DATE;
	l_conversion_type	VARCHAR2(30);
	l_conversion_rate	NUMBER;
BEGIN
	-- Check if both currencies are identical
	IF (p_from_currency = p_to_currency) THEN
	   RETURN(1);
	END IF;
	-- API Body
	get_period_info(p_conversion_period, l_period_type, l_conversion_date);
	l_conversion_type := get_conversion_type(l_period_type);
	l_conversion_rate := gl_currency_api.get_rate(p_from_currency, p_to_currency,
                                        l_conversion_date, l_conversion_type);

	return(l_conversion_rate);
END get_period_rate;

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
--    p_from_currency		IN VARCHAR2 -- From currency
--    p_to_currency		IN VARCHAR2 -- To currency
--    p_conversion_period	IN VARCHAR2 -- Conversion period
-- Version 	:
--
-- History	:
--	22-Sep-98	J. Shang	Created
-- End of Comments
--

FUNCTION get_period_rate_sql (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_period	IN	VARCHAR2) RETURN NUMBER IS

	l_period_type		VARCHAR2(15);
	l_conversion_date	DATE;
	l_conversion_type	VARCHAR2(30);
	l_conversion_rate	NUMBER;
BEGIN
	-- Check if both currencies are identical
	IF (p_from_currency = p_to_currency) THEN
	   RETURN(1);
	END IF;
	-- API Body
	get_period_info(p_conversion_period, l_period_type, l_conversion_date);
	l_conversion_type := get_conversion_type(l_period_type);
	l_conversion_rate := gl_currency_api.get_rate(p_from_currency, p_to_currency,
                                        l_conversion_date, l_conversion_type);

	return(l_conversion_rate);
EXCEPTION
	WHEN gl_currency_api.NO_RATE THEN
		return(G_NEG_MAX);
	WHEN gl_currency_api.INVALID_CURRENCY THEN
		return(G_NEG_MAX);
	WHEN INVALID_PERIOD THEN
		return(G_NEG_MAX);
	WHEN INVALID_FORECAST_CALENDAR THEN
		return(G_NEG_MAX);
	WHEN OTHERS THEN
		return(G_NEG_MAX);
END get_period_rate_sql;

-- Start of Comments
--
-- API name	: daily_rate_exists
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes from and to currencies, conversion date, and Max Roll
--	days. It checks if there is the rate from the from currency to the to
--	currency.
--
-- Parameters	:
-- IN		:
--    p_from_currency	IN VARCHAR2 -- From currency
--    p_to_currency	IN VARCHAR2 -- To currency
--    p_conversion_date	IN DATE     -- Conversion date
--    p_max_roll_days	IN NUMBER   -- Maximum days to roll back for a rate
--
-- Version 	:
--
-- Note		:
--	The using of p_max_roll_days follows the rules described in convert_amount_daily
-- History	:
--	22-Sep-98	J. Shang	Created
-- Note     :
--    In this function, a cursor is defined to search a closest rate. The query
--    follows the searching rule defined in GL_CURRENCY_API. So, if the rule is
--    changed in GL_CURRENCY_API, this cursor has to be changed also.
-- End of Comments
--
FUNCTION daily_rate_exists (
	      p_from_currency	IN	VARCHAR2, -- From currency
	      p_to_currency	IN	VARCHAR2, -- To currency
	      p_conversion_date IN	DATE,     -- Conversion date
	      p_max_roll_days	IN	NUMBER DEFAULT 0,   -- Maximum days to roll back for a rate
	      x_rate_date	OUT NOCOPY	DATE) RETURN VARCHAR2 IS     -- The date on which there is rate defined
 	l_conversion_rate	NUMBER;
	l_conversion_type	VARCHAR2(30);
	l_exist_flag		VARCHAR2(1);
	l_closest_date		DATE;
	l_fix_rate		BOOLEAN;
	l_relationship		VARCHAR2(18);
	l_from_currency	VARCHAR2(15);
	l_to_currency		VARCHAR2(15);
	l_max_roll_days	NUMBER;
	l_conversion_date	DATE;
        CURSOR l_closest_rate_csr IS
		SELECT conversion_date
		FROM GL_DAILY_RATES
		WHERE from_currency = l_from_currency
		AND to_currency = l_to_currency
		AND conversion_type = l_conversion_type
		AND conversion_date BETWEEN
			(decode(sign(l_max_roll_days), 1,
			trunc(l_conversion_date)-l_max_roll_days,
			-1, trunc(to_date('1000/01/01','YYYY/MM/DD'))))
		AND trunc(l_conversion_date)
		ORDER BY conversion_date DESC;
BEGIN
	-- Check if both currencies are identical
	IF (p_from_currency = p_to_currency) THEN
	   x_rate_date := p_conversion_date;
	   RETURN('Y');
	END IF;
	-- API Body
	l_conversion_type := FND_PROFILE.value('AS_MC_DAILY_CONVERSION_TYPE');
	IF (l_conversion_type IS NULL) THEN
	   raise INVALID_DAILY_CONVERSION_TYPE;
	END IF;
	l_exist_flag := gl_currency_api.rate_exists(p_from_currency, p_to_currency,
			    p_conversion_date, l_conversion_type);
	IF (l_exist_flag = 'Y') THEN
	  x_rate_date := p_conversion_date;
	ELSE
	  IF (p_max_roll_days = 0) THEN
		l_exist_flag := 'N';
	  ELSE
		gl_currency_api.get_relation(p_from_currency, p_to_currency,
			p_conversion_date, l_fix_rate, l_relationship);
		IF (INSTR(l_relationship,'OTHER') <> 0) THEN
			l_from_currency := p_from_currency;
			l_to_currency := p_to_currency;
			l_max_roll_days := p_max_roll_days;
			l_conversion_date := p_conversion_date;
			OPEN l_closest_rate_csr;
			FETCH l_closest_rate_csr INTO l_closest_date;
			IF NOT l_closest_rate_csr%FOUND THEN
				l_exist_flag := 'N';
			ELSE
			   x_rate_date := l_closest_date;
			   l_exist_flag := 'Y';
			END IF;
	   		--SAGHOSH 4/14/00
			CLOSE l_closest_rate_csr ;
		ELSE
		   l_exist_flag := 'N';
		END IF;
	  END IF;
	END IF;
	RETURN(l_exist_flag);
END daily_rate_exists;

-- Start of Comments
--
-- API name	: period_rate_exists
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes from and to currencies, conversion period. It checks if there
--      is  the rate from the from currency to the to currency based on pseudo period rate.
-- Parameters	:
-- IN		:
--    p_from_currency		IN VARCHAR2 -- From currency
--    p_to_currency		IN VARCHAR2 -- To currency
--    p_conversion_period	IN VARCHAR2 -- Conversion period
-- Version 	:
--
-- History	:
--	22-Sep-98	J. Shang	Created
-- End of Comments
--
FUNCTION period_rate_exists (
	       p_from_currency		IN	VARCHAR2, -- From currency
	       p_to_currency		IN	VARCHAR2, -- To currency
	       p_conversion_period	IN	VARCHAR2) RETURN VARCHAR2 IS -- Conversion period

	l_period_type		VARCHAR2(15);
	l_conversion_date	DATE;
	l_conversion_type	VARCHAR2(30);
	l_conversion_rate	NUMBER;
	l_exist_flag		VARCHAR2(1);
BEGIN
	-- Check if both currencies are identical
	IF (p_from_currency = p_to_currency) THEN
	   RETURN('Y');
	END IF;
	-- API Body
	get_period_info(p_conversion_period, l_period_type, l_conversion_date);
	l_conversion_type := get_conversion_type(l_period_type);
	l_exist_flag := gl_currency_api.rate_exists(p_from_currency, p_to_currency,
			    l_conversion_date, l_conversion_type);
	return(l_exist_flag);
END period_rate_exists;

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
--    procedure defined in GL.
-- End of Comments
--
PROCEDURE get_euro_info(p_currency_code	IN VARCHAR2,
		   p_effective_date	IN DATE,
		   x_currency_type	OUT NOCOPY VARCHAR2,
		   x_conversion_rate	OUT NOCOPY NUMBER) IS
CURSOR l_currency_info_csr(l_currency_code VARCHAR2,l_effective_date DATE) IS
	SELECT decode(derive_type,
                 'EURO', 'EURO',
                 'EMU', decode( sign( trunc(l_effective_date) -
                          trunc(derive_effective)),
                             -1, 'OTHER',
                          'EMU'),
                 'OTHER' ),
		decode(derive_type, 'EURO', 1,
				    'EMU',  derive_factor,
				    'OTHER',-1)
     FROM   FND_CURRENCIES
     WHERE  currency_code = l_currency_code;
BEGIN
	OPEN l_currency_info_csr(p_currency_code,p_effective_date);
	FETCH l_currency_info_csr INTO x_currency_type,x_conversion_rate;
	IF l_currency_info_csr%NOTFOUND THEN
	   x_currency_type := NULL;
	   x_conversion_rate := -1;
	END IF;
	CLOSE l_currency_info_csr;
END get_euro_info;

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
-- Output:
--    If the p_length to hold the formatted value is not enough to hold the formatted
--    amount, p_length number of '#' will be returned. NULL will be returned when
--    p_length is negative or less than the length of p_amount.
-- Version	:
--
-- History	:
--	2-Nov-98	J. Shang	Created
-- Note     :
--
-- End of Comments
--
FUNCTION format_amount(p_currency_code	IN VARCHAR2,
			 p_amount		IN NUMBER,
			 p_length		IN NUMBER) RETURN VARCHAR2 IS
l_formatted_amount VARCHAR2(2000);
BEGIN
  IF (p_length <= 0) OR (p_length < length(to_char(p_amount))) THEN
     RETURN NULL;
  END IF;
  l_formatted_amount := to_char(p_amount,FND_CURRENCY.GET_FORMAT_MASK(p_currency_code,p_length));
  RETURN l_formatted_amount;
END format_amount;

-- Start of Comments
--
-- API name	: unformat_amount
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes currency code and amount to be unformatted. It returns the amount
--      converted into a number. The format mask is get from foundation library. If the
--	number is using invalid format, NEG_MAX_NUM will be returned
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
--
-- End of Comments
--
FUNCTION unformat_amount(p_currency_code	IN VARCHAR2,
			   p_amount		IN VARCHAR2) RETURN NUMBER IS
l_unformatted_num NUMBER := G_NEG_MAX;
l_length NUMBER;
l_mask VARCHAR2(2000);
BEGIN
	l_length := LENGTH(p_amount) * 2;
	l_mask := FND_CURRENCY.GET_FORMAT_MASK(p_currency_code,l_length);
        BEGIN
		l_unformatted_num := to_number(p_amount);
		l_unformatted_num := to_number(to_char(l_unformatted_num,l_mask),l_mask);
	EXCEPTION
		WHEN INVALID_NUMBER THEN
	  		l_unformatted_num := G_NEG_MAX;
		WHEN VALUE_ERROR THEN
			l_unformatted_num := G_NEG_MAX;
	END;
	IF l_unformatted_num < 0 THEN
		l_unformatted_num := to_number(p_amount,l_mask);
	END IF;
	RETURN l_unformatted_num;
EXCEPTION
	WHEN INVALID_NUMBER THEN
	    l_unformatted_num := G_NEG_MAX;
	    RETURN l_unformatted_num;
	WHEN VALUE_ERROR THEN
	    l_unformatted_num := G_NEG_MAX;
	    RETURN l_unformatted_num;
END unformat_amount;

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
            p_out_amount5       OUT NOCOPY     NUMBER) IS
BEGIN

  if p_amount1 is not NULL then
    p_out_amount1 := AS_MC_PKG.convert_amount_daily
                        (p_from_currency,
                        p_to_currency,
                        p_conversion_date,
                        p_amount1);
  end if;

  if p_amount2 is not NULL then
    p_out_amount2 := AS_MC_PKG.convert_amount_daily
                        (p_from_currency,
                        p_to_currency,
                        p_conversion_date,
                        p_amount2);
  end if;

  if p_amount3 is not NULL then
    p_out_amount3 := AS_MC_PKG.convert_amount_daily
                        (p_from_currency,
                        p_to_currency,
                        p_conversion_date,
                        p_amount3);
  end if;

  if p_amount4 is not NULL then
    p_out_amount4 := AS_MC_PKG.convert_amount_daily
                        (p_from_currency,
                        p_to_currency,
                        p_conversion_date,
                        p_amount4);
  end if;

  if p_amount5 is not NULL then
    p_out_amount5 := AS_MC_PKG.convert_amount_daily
                        (p_from_currency,
                        p_to_currency,
                        p_conversion_date,
                        p_amount5);
  end if;

END convert_group_amounts_daily;

END AS_MC_PKG;

/
