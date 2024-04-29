--------------------------------------------------------
--  DDL for Package EDW_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_CURRENCY" AUTHID CURRENT_USER as
/* $Header: FIICACRS.pls 120.1 2002/10/22 21:54:12 djanaswa ship $ */


-- ------------------------
-- Public Functions
-- ------------------------

-- --------------------------------------------------------------
-- Name: convert_global_amount
-- Desc: This function converts the given transaction amount
--       to the equivalent value in global warehouse currency.
--       It will skip the conversion if either base currency or
--       transaction currency is the same as the global warehouse
--       Currency.  It's not required to pass in base amounts or
--       base currency code; however, it may improve performance
--       by allowing the function to skip conversions.
--       If exchange rate type is not specified, the api will use
--       the global rate type setup in the global warehouse admin.
-- Input : x_trx_amount - amount to be converted in trx currency
--         x_base_amount - amount to be converted in base currency
--         x_exchange_date - indicates which day's rates to use
--	   x_exchange_rate_type - indicates what kind of rate type to use
-- Output: If rate not available, returns -1
--	   If input currency invalid, returns -2
-- Error: global warehouse parameters such as global currency have not
--        been setup or if any sql errors occur during execution, an
--        exception is raised.
-- --------------------------------------------------------------
FUNCTION convert_global_amount (
		x_trx_amount		NUMBER,
		x_base_amount		NUMBER DEFAULT NULL,
		x_trx_currency_code	VARCHAR2,
		x_base_currency_code	VARCHAR2 DEFAULT NULL,
		x_exchange_date		DATE,
		x_exchange_rate_type	VARCHAR2 DEFAULT NULL
		) RETURN NUMBER;

PRAGMA   RESTRICT_REFERENCES(convert_global_amount, WNDS,WNPS,RNPS);


-- --------------------------------------------------------------
-- Name: convert_global_amount
-- Desc: This function converts the given transaction amount
--       to the equivalent value in global warehouse currency.
--       It will skip the conversion if either base currency or
--       transaction currency is the same as the global warehouse
--       Currency.  It is the same as the above function except
--       it derives the base currency from set of books id.
--       It's not required to pass in base amounts or
--       set of books id ; however, it may improve performance
--       by allowing the function to skip conversions.
--       If exchange rate type is not specified, the api will use
--       the global rate type setup in the global warehouse admin.
-- Input : x_trx_amount - amount to be converted in trx currency
--         x_base_amount - amount to be converted in base currency
--         x_set_of_books_id - sob used to derive the base currency
--         x_exchange_date - indicates which day's rates to use
--	   x_exchange_rate_type - indicates what kind of rate type to use
-- Output: If rate not available, returns -1
--	   If input currency invalid, returns -2
-- Error: global warehouse parameters such as global currency have not
--        been setup or if any sql errors occur during execution, an
--        exception is raised.
-- --------------------------------------------------------------
FUNCTION convert_global_amount (
		x_trx_amount		NUMBER,
		x_base_amount		NUMBER DEFAULT NULL,
		x_trx_currency_code	VARCHAR2,
		x_set_of_books_id		NUMBER,
		x_exchange_date		DATE,
		x_exchange_rate_type	VARCHAR2 DEFAULT NULL
		) RETURN NUMBER;

PRAGMA   RESTRICT_REFERENCES(convert_global_amount, WNDS,WNPS,RNPS);


-- --------------------------------------------------------------
-- Name: get_rate
-- Desc: This function returns conversion rate between transaction
--       currency (parameter x_trx_currency_code) and global
--       warehouse currency.
--       If exchange rate type is not specified, the api will use
--       the global rate type setup in the global warehouse admin.
-- Input : x_trx_currency_code - source currency code
--         x_exchange_date - indicates which day's rates to use
--	   x_exchange_rate_type - indicates what kind of rate type to use
-- Output: If rate not available, returns -1
--	   If input currency invalid, returns -2
--         Any other exception - returns NULL
-- Error: global warehouse parameters such as global currency have not
--        been setup or if any sql errors occur during execution, an
--        exception is raised and null value is returned
-- --------------------------------------------------------------

FUNCTION get_rate (
		x_trx_currency_code	VARCHAR2,
		x_exchange_date	        DATE,
		x_exchange_rate_type    VARCHAR2 DEFAULT NULL
                ) RETURN NUMBER;

PRAGMA   RESTRICT_REFERENCES(get_rate, WNDS,WNPS,RNPS);


-- --------------------------------------------------------------
-- Name: get_mau
-- Desc: This function returns minimum accountable unit of the
--       global warehouse currency. If a currency does not have
--       minimum accountable unit, function returns currency precision.
--       If there is no precision, function returns default value of 0.01;
--       Function result can never be 0.
--       This function should be used in combination with get_rate
--       function to convert transaction amounts to amounts in global
--       warehouse currency:
--                                  <trx amount> * get_rate()
--         <global amount> = round (-------------------------) * get_mau()
--                                          get_mau()
--
-- Input : none
-- Output: function returns NULL in case of any exceptions.
-- --------------------------------------------------------------

FUNCTION get_mau RETURN NUMBER;

PRAGMA   RESTRICT_REFERENCES(get_mau, WNDS,WNPS,RNPS);


END EDW_CURRENCY;

 

/
