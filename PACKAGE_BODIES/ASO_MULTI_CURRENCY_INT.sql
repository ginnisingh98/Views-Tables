--------------------------------------------------------
--  DDL for Package Body ASO_MULTI_CURRENCY_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_MULTI_CURRENCY_INT" as
/* $Header: asoimcxb.pls 120.1 2005/06/29 12:33:46 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_multi_currency_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_multi_currency_INT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoimcx.pls';


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
            p_max_roll_days	IN	NUMBER := 0) RETURN NUMBER IS

            l_converted_amount	NUMBER;
	    l_conversion_type   VARCHAR2(30);
BEGIN

     aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
	-- Check if both currencies are identical
	IF (p_from_currency = p_to_currency) THEN
	   return(p_amount);
	END IF;

	-- Decide the value of AS_MC_DAILY_CONVERSION_TYPE is valid
	l_conversion_type := FND_PROFILE.value('ASO_QUOTE_CONVERSION_TYPE');
	IF (l_conversion_type IS NULL) THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      fnd_message.set_name('ASO', 'ASO_QTE_MISSING_CONV_TYPE');
  	      FND_MSG_PUB.Add;
	    END IF;
	   return(-1); --raise INVALID_DAILY_CONVERSION_TYPE;
	END IF;


	-- Call GL_CURRENCY_API to do conversion
	l_converted_amount :=
                gl_currency_api.convert_closest_amount_sql(p_from_currency,
		p_to_currency,p_conversion_date,l_conversion_type,0,p_amount,
                p_max_roll_days);


	IF l_converted_amount = -1 THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      fnd_message.set_name('ASO', 'ASO_NO_RATE');
              fnd_message.set_token('FROM_CURR', p_from_currency);
              fnd_message.set_token('TO_CURR', p_to_currency);
  	      FND_MSG_PUB.Add;
	    END IF;
	   return(-1);
	ELSIF l_converted_amount = -2 THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      fnd_message.set_name('ASO', 'ASO_INVALID_CURRENCY');
              fnd_message.set_token('FROM_CURR', p_from_currency);
              fnd_message.set_token('TO_CURR', p_to_currency);
  	      FND_MSG_PUB.Add;
	    END IF;
	   return(-1);      --raise  gl_currency_api.INVALID_CURRENCY;
	END IF;

	return(l_converted_amount);

END convert_amount_daily;




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
		   x_conversion_rate OUT NOCOPY /* file.sql.39 change */   NUMBER) IS

CURSOR l_currency_info_csr(l_currency_code VARCHAR2,l_effective_date DATE) IS
	SELECT decode(derive_type,
                 'EURO', 'EURO',
                 'EMU', decode( sign( trunc(l_effective_date) -
                                      trunc(derive_effective)),
                             -1, 'OTHER', 'EMU'), 'OTHER' ),
		decode(derive_type, 'EURO', 1,
				    'EMU',  derive_factor,
				    'OTHER',-1)
     FROM   FND_CURRENCIES
     WHERE  currency_code = l_currency_code;

BEGIN

     aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

	OPEN l_currency_info_csr(p_currency_code,p_effective_date);
	FETCH l_currency_info_csr INTO x_currency_type,x_conversion_rate;

	IF l_currency_info_csr%NOTFOUND THEN
	   x_currency_type := NULL;
	   x_conversion_rate := -1;
	END IF;

	CLOSE l_currency_info_csr;
END get_euro_info;

END ASO_multi_currency_INT;

/
