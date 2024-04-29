--------------------------------------------------------
--  DDL for Package ASO_MULTI_CURRENCY_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_MULTI_CURRENCY_INT" AUTHID CURRENT_USER as
/* $Header: asoimcxs.pls 120.1 2005/06/29 12:33:50 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_multi_currency_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



G_NEG_MAX  CONSTANT NUMBER := -9.99E125;

-- Start of Comments
--
-- API name	: convert_amount_daily
-- Type		:
-- Pre-reqs	:
-- Function	:
-- This api takes from and to currencies, conversion date, amount and Max Roll
--days. It returns the amount converted into the appropriate currency. The
--converted amount is calculated in compliance with the triangulation tule.
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
-- History	:
--	22-Sep-98	J. Shang	Created
-- Note     :
--      Using of p_max_roll_days in daily conversion:
--When a rate for the conversion date is undefined, p_max_roll_days will be
--used to find an alternitive rate to do the conversion.
--1. If it is a positive number, the function will look backward from the
-- conversion date for the most recent date on which a rate is defined.
--2. If it is a negative number, the function will look backward without any
--   date limit to find the most recent date on which a rate is defined.
--3. If it is zero,the funtion doesn't look backward. This is the default value
--	The above definition follows rules defined in GL_CURRENCY_API.

-- End of Comments


FUNCTION convert_amount_daily (
            p_from_currency	IN	VARCHAR2,
            p_to_currency	IN	VARCHAR2,
            p_conversion_date	IN	DATE,
            p_amount		IN	NUMBER,
            p_max_roll_days	IN	NUMBER DEFAULT 0) RETURN NUMBER ;



-- Start of Comments
-- API name	: get_euro_info
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes currency code and the effective date,
-- it will get the currency

-- Parameters	:
-- IN		:
--    p_currency_code	IN VARCHAR2 -- Currency to be checked
--    p_effective_date	IN DATE	    -- Effective date
--    x_currency_type   OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- Type of the currency.
--     Euro currency, set to 'EURO'
--     Emu currency, set to 'EMU'
--    Other currencies,set to 'OTHER'

--    Invalid currency, set to NULL
--    x_conversion_rate OUT NOCOPY /* file.sql.39 change */ NUMBER -- Fixed rate for conversion
-- Version 	:
--
-- History	:
--	03-Nov-98	J. Shang	Created
-- Note		:
--    This is temporary solution for OSM, and the procedure follows
-- the similar  privatre  procedure defined in GL.

-- End of Comments
--

PROCEDURE get_euro_info(p_currency_code	IN VARCHAR2,
		   p_effective_date	IN DATE,
		   x_currency_type OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
		   x_conversion_rate OUT NOCOPY /* file.sql.39 change */   NUMBER) ;


END ASO_multi_currency_INT;


 

/
