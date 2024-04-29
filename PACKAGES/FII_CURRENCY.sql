--------------------------------------------------------
--  DDL for Package FII_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_CURRENCY" AUTHID CURRENT_USER AS
/* $Header: FIICACUS.pls 120.7 2005/10/30 05:07:47 appldev noship $ */
-- -------------------------------------------------------------------
-- Name: get_global_rate_primary
-- Parameters: From_Currency
--                    Exchange_Date
-- Desc: Given the from currency and exchange date, this API will
--           call the GL_CURRENCY_API.get_closest_rate_sql API to get
--           the currency conversion rate to the primary Global
--           Currency.
-- Output: Conversion rate, data type: NUMBER
--             Returns -1 if no rate exists
--             Returns -2 if the From Currency is an invalid currency
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function get_global_rate_primary(
      p_from_currency_code  VARCHAR2,
      p_exchange_date           DATE)
 return NUMBER PARALLEL_ENABLE;

--PRAGMA RESTRICT_REFERENCES(get_global_rate_primary, WNDS,WNPS,RNPS);

-- -------------------------------------------------------------------
-- Name: get_global_rate_secondary
-- Parameters: From_Currency
--                    Exchange_Date
-- Desc: Given the from currency and exchange date, this API will
--           call the GL_CURRENCY_API.get_closest_rate_sql API to get
--           the currency conversion rate to the secondary Global
--           Currency.
-- Output: Conversion rate, data type: NUMBER
--             Returns -1 if no rate exists
--             Returns -2 if the From Currency is an invalid currency
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function get_global_rate_secondary(
      p_from_currency_code  VARCHAR2,
      p_exchange_date           DATE)
 return NUMBER PARALLEL_ENABLE;

--PRAGMA RESTRICT_REFERENCES(get_global_rate_secondary, WNDS,WNPS,RNPS);

-- -------------------------------------------------------------------
-- Name: convert_global_amt_primary
-- Parameters: From_Currency
--             Amount
--             Exchange_Date
-- Desc: Given the from currency, amount in from currency, and exchange
--       date, this API will call the
--       GL_CURRENCY_API.convert_global_amount_sql to convert the amount

--       into amount in primary Global Currency.
-- Output: Amount in primary Global currency, data type: NUMBER
--         Returns -1 if no rate exists
--         Returns -2 if the From Currency is an invalid currency
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function convert_global_amt_primary(
      p_from_currency_code  VARCHAR2,
      p_from_amount         NUMBER,
      p_exchange_date       DATE)
 return NUMBER PARALLEL_ENABLE;

--PRAGMA RESTRICT_REFERENCES(convert_global_amt_primary, WNDS,WNPS,RNPS);

-- -------------------------------------------------------------------
-- Name: convert_global_amt_secondary
-- Parameters: From_Currency
--                    Amount
--                    Exchange_Date
-- Desc: Given the from currency, amount in from currency, and exchange
--           date, this API will call the
--           GL_CURRENCY_API.convert_global_amount_sql to convert the
--           amount into amount in secondary Global Currency.
-- Output: Amount in secondary Global currency, data type: NUMBER
--             Returns -1 if no rate exists
--             Returns -2 if the From Currency is an invalid currency
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function convert_global_amt_secondary(
      p_from_currency_code  VARCHAR2,
      p_from_amount         NUMBER,
      p_exchange_date       DATE)
 return NUMBER PARALLEL_ENABLE;

--PRAGMA RESTRICT_REFERENCES(convert_global_amt_secondary, WNDS,WNPS,RNPS);

-- --------------------------------------------------------------
-- Name: get_mau_primary
-- Desc: This function returns minimum accountable unit of the
--       primary global warehouse currency. If a currency does not have
--       minimum accountable unit, function returns currency precision.
--       If there is no precision, function returns default value of 0.01;
--       Function result can never be 0.
--       This function should be used in combination with get_rate
--       function to convert transaction amounts to amounts in primary
--       global warehouse currency:
--                                  <trx amount> * get_rate()
--         <global amount> = round (-------------------------) * get_mau()
--                                          get_mau()
--
-- Input : none
-- Output: function returns NULL in case of any exceptions.
-- --------------------------------------------------------------

FUNCTION get_mau_primary RETURN NUMBER PARALLEL_ENABLE;

--PRAGMA   RESTRICT_REFERENCES(get_mau_primary, WNDS,WNPS,RNPS);

-- --------------------------------------------------------------
-- Name: get_mau_secondary
-- Desc: This function returns minimum accountable unit of the
--       secondary global warehouse currency. If a currency does not have
--       minimum accountable unit, function returns currency precision.
--       If there is no precision, function returns default value of 0.01;
--       Function result can never be 0.
--       This function should be used in combination with get_rate
--       function to convert transaction amounts to amounts in secondary
--       global warehouse currency:
--                                  <trx amount> * get_rate()
--         <global amount> = round (-------------------------) * get_mau()
--                                          get_mau()
--
-- Input : none
-- Output: function returns NULL in case of any exceptions.
-- --------------------------------------------------------------

FUNCTION get_mau_secondary RETURN NUMBER PARALLEL_ENABLE;

--PRAGMA   RESTRICT_REFERENCES(get_mau_secondary, WNDS,WNPS,RNPS);

-- -------------------------------------------------------------------
-- Name: get_rate
-- Parameters: From Currency
--             To Currency
--             Exchange Date
--             Exchange Rate Type
-- Desc: Given the from currency, to currency, exchange date and rate type,
--       this API will call the GL_CURRENCY_API.get_closest_rate_sql API to
--       get the currency conversion rate.
-- Output: Conversion rate, data type: NUMBER
--          Returns -1 if no rate exists
--          Returns -2 if the From Currency is an invalid currency
--          Returns -3 when one of the currency is EUR and the
--          exchange date is before Jan 1,1999 and no rate exists
--          on Jan 1,1999 between the two currencies.
--          Returns -4 for other exceptions.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function get_rate(
      p_from_currency_code VARCHAR2,
      p_to_currency_code   VARCHAR2,
      p_exchange_date      DATE,
      p_exchange_rate_type VARCHAR2)
 return NUMBER PARALLEL_ENABLE;

 ----------------------------
-- Rate Conversion API
----------------------------

-- --------------------------------------------------------------------------
-- Name : compare_currency_codes
-- Type : Function
-- Description : Returns 1 if the given currency codes are the same
--               else returns 0;
--               This function also takes care of fixed currency for Oracle IT.
--               If USD is treated as CD , then if one of the parameters is CD
--               and the other is USD then the function returns 1.
-----------------------------------------------------------------------------
FUNCTION compare_currency_codes(
                                p_currency_code1 IN VARCHAR2,
				p_currency_code2 IN VARCHAR2) RETURN NUMBER PARALLEL_ENABLE;

-- -----------------------------------------------------------------------
-- Name : get_fc_to_pgc_rate
-- Type : Function
-- Description : Returns rate to convert amounts from functional currency
--               to primary global currency. If the transactional currency
--               is the same as primary global currency , functional amts
--               are not converted and transactional amounts are used.
-- Output : Returns 0 if transactional currency and the primary global
--          currency is the same.
--          Returns 1 if the functional currency is the same as primary
--          global currency
--          Returns the rate between the functional currency and the
--          primary global currency.
-- Exceptions : Returns -1 when no rate exists
--              Returns -2 when invalid currency
--              Returns -3 when one of the currency is EUR and the
--              exchange date is before Jan 1,1999 and no rate exists
--              from fc to pgc on Jan 1,1999
--              Return -4 for any other exception.
-- How the exceptions are handled :
--     Other exceptions are handled by get_fc_to_pgc_rate
--     No Rate and Invalid Currency are handled in gl_currency_api.get_closest_rate_sql
--     When one of the currency is EUR and exchange date is before Jan 1,1999
--     and no rate exists from fc to pgc on Jan 1,1999 ,-3 is returned from
--     FII_CURRENCY.get_rate.
---------------------------------------------------------------------------
Function  get_fc_to_pgc_rate(p_tc_code IN VARCHAR2,
                            p_fc_code IN VARCHAR2,
			    p_exchange_date IN DATE) RETURN NUMBER PARALLEL_ENABLE;


-- -----------------------------------------------------------------------
-- Name : get_fc_to_sgc_rate
-- Type : Function
-- Description : Returns rate to convert amounts from functional currency
--               to secondary global currency. If the transactional currency
--               is the same as secondary global currency , functional amts
--               are not converted and transactional amounts are used.
-- Output : Returns 0 if transactional currency and the secondary global
--          currency is the same.
--          Returns 1 if the functional currency is the same as secondary
--          global currency or secondary currency is not defined.
--          Returns the rate between the functional currency and the
--          secondary global currency.
-- Exceptions : Returns -1 when no rate exists
--              Returns -2 when invalid currency
--              Returns -3 when one of the currency is EUR and the
--              exchange date is before Jan 1 ,1999 and no rate exists
--              from fc to pgc on Jan 1,1999
--              Return -4 for any other exception.
-- How the exceptions are handled :
--     Other exceptions are handled by get_fc_to_pgc_rate
--     No Rate and Invalid Currency are handled in gl_currency_api.get_closest_rate_sql
--     When one of the currency is EUR and exchange date is before Jan 1,1999
--     and no rate exists from fc to pgc on Jan 1,1999 ,-3 is returned from
--     FII_CURRENCY.get_rate.
---------------------------------------------------------------------------
Function  get_fc_to_sgc_rate(p_tc_code IN VARCHAR2,
                            p_fc_code IN VARCHAR2,
			    p_exchange_date IN DATE) RETURN NUMBER PARALLEL_ENABLE;

-- --------------------------------------------------------------------------------
-- Name : get_tc_to_pgc_rate
-- Type : Function
-- Description : This api is to be used for modules not storing functional currency.
--               Returns rate to convert amounts from transactional currency to
--               primary global currency.
-- Output :
--                o If transactional currency and primary global currency is the same
--                  then return 1. user-defined rate is ignored.
--                o If user defined rate is given and functional currency and primary
--                  global currency is the same then return the user defined rate
--                  else returns the product of the user defined rate and the retrieved
--                  rate between the functional currency and the primary global currency.
--                o In all other cases, it returns the product of rate between transactional
--                  currency and functional currency and rate between functional currency
--                  and primary global currency.
-- Exceptions : Returns -2 when either of transactional currency and functional currency
--              is invalid.
--              Returns -3 when transactional or functional currency is EUR and the exchange date
--               is before Jan 1 ,1999 and no rate exists on Jan 1,1999.
--              Returns -4 for any other exception
--              Returns -5 when no rate exists between transactional currency and functional
--              currency.
--              Returns -6 when no rate exists between functional currency and primary
--              global currency.
--              Returns -7 when functional or primary global currency is EUR and the
--              exchange date is before Jan 1 ,1999 and no rate exists on Jan 1,1999.
--              Returns -8 when treasury rate type is null and p_rate is null and exchange
--              rate type is null.
-- How the exceptions are handled :
--              Other exceptions are handled by get_tc_to_pgc_rate
--              Invalid Currency (-2) is handled in gl_currency_api.get_closest_rate_sql
--              When one of the currency is EUR and exchange date is before Jan 1,1999
--              and no rate exists on Jan 1,1999 then -3 is returned from FII_CURRENCY.get_rate
--              -5,-6,-7,-8 are handled in get_tc_pgc_rate
----------------------------------------------------------------------------------------------

FUNCTION get_tc_to_pgc_rate(p_tc_code IN VARCHAR2,
                            p_exchange_date1 IN DATE,
			    p_exchange_rate_type IN VARCHAR2,
			    p_fc_code IN VARCHAR2,
			    p_exchange_date2 IN DATE,
			    p_rate IN NUMBER DEFAULT NULL) RETURN NUMBER PARALLEL_ENABLE;

-- --------------------------------------------------------------------------------
-- Name : get_tc_to_sgc_rate
-- Type : Function
-- Description : This api is to be used for modules not storing functional currency.
--               Returns rate to convert amounts from transactional currency to
--               secondary global currency.
-- Output :
--                o If transactional currency and secondary global currency is the same
--                  then return 1. user-defined rate is ignored.
--                o If global secondary currency is not defined it returns 1.
--                o If user defined rate is given and functional currency and secondary
--                  global currency is the same then return the user defined rate
--                  else returns the product of the user defined rate and the retrieved
--                  rate between the functional currency and the secondary global currency.
--                o In all other cases, it returns the product of rate between transactional
--                  currency and functional currency and rate between functional currency
--                  and secondary global currency.
-- Exceptions : Returns -2 when either of transactional currency and functional currency
--              is invalid.
--              Returns -3 when transactional or functional currency is EUR and the exchange date
--               is before Jan 1 ,1999 and no rate exists on Jan 1,1999.
--              Returns -4 for any other exception
--              Returns -5 when no rate exists between transactional currency and functional
--              currency.
--              Returns -6 when no rate exists between functional currency and secondary
--              global currency.
--              Returns -7 when functional or secondary global currency is EUR and the
--              exchange date is before Jan 1 ,1999 and no rate exists on Jan 1,1999.
--              Returns -8 when treasury rate type is null and p_rate is null and exchange
--              rate type is null.
-- How the exceptions are handled :
--              Other exceptions are handled by get_tc_to_pgc_rate
--              Invalid Currency (-2) is handled in gl_currency_api.get_closest_rate_sql
--              When one of the currency is EUR and exchange date is before Jan 1,1999
--              and no rate exists on Jan 1,1999 then -3 is returned from FII_CURRENCY.get_rate
--              -5,-6,-7,-8 are handled in get_tc_sgc_rate
----------------------------------------------------------------------------------------------
FUNCTION get_tc_to_sgc_rate(p_tc_code IN VARCHAR2,
                            p_exchange_date1 IN DATE,
			    p_exchange_rate_type IN VARCHAR2,
			    p_fc_code IN VARCHAR2,
			    p_exchange_date2 IN DATE,
			    p_rate IN NUMBER DEFAULT NULL) RETURN NUMBER PARALLEL_ENABLE;


END FII_CURRENCY;

 

/
