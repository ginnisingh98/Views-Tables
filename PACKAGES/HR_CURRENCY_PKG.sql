--------------------------------------------------------
--  DDL for Package HR_CURRENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CURRENCY_PKG" AUTHID CURRENT_USER AS
/* $Header: pyemucnv.pkh 120.1.12010000.1 2008/07/27 22:31:44 appldev ship $ */

--
-- Package
--   hr_currency_pkg
--
-- Purpose
--
--   This package will provide a cover for the gl_currency_API for the
--   following purposes:
--   o Determine exchange rate based on any two currencies, currency_type,
--     and conversion date information
--   o Convert an amount to a different currency based on any two currencies,
--     currency Type, and conversion date information
--
-- History
--   02-Jun-98 		wkerr		Created
--

  --
  -- Exceptions
  --
  -- User defined exceptions for hr_currency_api:
  -- o INVALID_CURRENCY - One of the two currencies is invalid.
  -- o NO_RATE          - No rate exists between the two currencies for the
  --                      given date and payroll id.
  -- o NO_DERIVE_TYPE   - No derive type found for the specified currency
  --                      during the specified period.
  --
INVALID_CURRENCY exception;
-- -------------------------------------------------------------------------
-- |-----------------------< check_rate_type >-----------------------------|
-- -------------------------------------------------------------------------
  --
  -- Function
  -- check_rate_type
  --
  -- checks that rate type exists in gl_daily_conversion_types
  -- This function is used within a Fast Formula to validate a
  -- conversion rate type
  --
  -- returns -1 if error or 1 if record exists
  --
  -- History
  --  02/02/99   wkerr.uk 	created
  --
  -- Arguments
  -- p_rate_type	The rate type to check
  --
  Function check_rate_type(
		p_rate_type VARCHAR2) RETURN NUMBER;
  --
-- -------------------------------------------------------------------------
-- |-----------------------< get_rate_type >-------------------------------|
-- -------------------------------------------------------------------------
  -- Function
  -- get_rate_type
  --
  --
  -- Purpose
  --
  --  Returns the rate type given the business group, effective date and
  --  processing type
  --
  --  Returns NULL if no type found
  --
  --  Current processing types are:-
  --			              P - Payroll Processing
  --                                  R - General HRMS reporting
  --				      I - Business Intelligence System
  --
  -- History
  --  22/01/99	wkerr.uk	Created
  --
  --  Argumnents
  --  p_business_group_id	The business group
  --  p_conversion_date		The date for which to return the rate type
  --  p_processing_type		The processing type of which to return the rate
  --
  FUNCTION get_rate_type (
		p_business_group_id	NUMBER,
		p_conversion_date	DATE,
		p_processing_type	VARCHAR2 ) RETURN VARCHAR2;
  --
-- -------------------------------------------------------------------------
-- |-----------------------< get_rate >------------------------------------|
-- -------------------------------------------------------------------------
  -- Function
  --   get_rate
  --
  -- Purpose
  -- 	Returns the rate between the two currencies for a given conversion
  --    date and rate type.
  --
  -- History
  --   22-Apr-98     wkerr 	Created
  --
  -- Arguments
  --   p_from_currency		From currency
  --   p_to_currency		To currency
  --   p_conversion_date	Conversion date
  --   p_rate_type		Rate Type
  --
  FUNCTION get_rate (
		p_from_currency		VARCHAR2,
		p_to_currency		VARCHAR2,
		p_conversion_date	DATE,
		p_rate_type		VARCHAR2) RETURN NUMBER;
-- -------------------------------------------------------------------------
-- |-----------------------< get_rate_sql >--------------------------------|
-- -------------------------------------------------------------------------
  --
  -- Purpose
  -- 	Returns the rate between the two currencies for a given conversion
  --    date and rate type  by calling get_rate().
  --
  --    Return -1 if the NO_RATE exception is raised in get_rate().
  --           -2 if the INVALID_CURRENCY exception is raised in get_rate().
  --
  -- History
  --   22-Apr-98     wkerr 	Created
  --
  -- Arguments
  --   p_from_currency		From currency
  --   p_to_currency		To currency
  --   p_conversion_date	Conversion date
  --   p_rate_type		Rate Type
  --
  FUNCTION get_rate_sql (
		p_from_currency	VARCHAR2,
		p_to_currency		VARCHAR2,
		p_conversion_date	DATE,
		p_rate_type		VARCHAR2) RETURN NUMBER;
-- -------------------------------------------------------------------------
-- |------------------------< convert_amount >-----------------------------|
-- -------------------------------------------------------------------------
  --
  -- Purpose
  -- 	Returns the amount converted from the from currency into the
  --    to currency for a given conversion date and rate type.
  --    The amount returned is rounded to the precision and minimum
  --    account unit of the to currency.
  --
  -- History
  --   22-Apr-98      wkerr 	Created
  --
  -- Arguments
  --   p_from_currency		From currency
  --   p_to_currency		To currency
  --   p_conversion_date	Conversion date
  --   p_amount			Amount to be converted from the from currency
  -- 				into the to currency
  --   p_rate_type		Rate Type
  --   p_round                Rounding decimal places
  --
  FUNCTION convert_amount (
		p_from_currency	VARCHAR2,
		p_to_currency		VARCHAR2,
		p_conversion_date	DATE,
		p_amount		     NUMBER,
		p_rate_type		VARCHAR2 DEFAULT NULL,
		p_round             NUMBER DEFAULT NULL) RETURN NUMBER;
-- -------------------------------------------------------------------------
-- |-----------------------< convert_amount_sql >--------------------------|
-- -------------------------------------------------------------------------
  --
  -- Purpose
  -- 	Returns the amount converted from the from currency into the
  --    to currency for a given conversion date and rate type by
  --    calling convert_amount().
  --    The amount returned is rounded to the precision and minimum
  --    account unit of the to currency.
  --
  --    Return -1 if the NO_RATE exception is raised in convert_amount().
  --           -2 if the INVALID_CURRENCY exception is raised in
  --                 convert_amount().
  --
  -- History
  --   22-Apr-98     wkerr 	Created
  --
  -- Arguments
  --   p_from_currency		From currency
  --   p_to_currency		To currency
  --   p_conversion_date	Conversion date
  --   p_amount			Amount to be converted from the from currency
  -- 			            into the to currency
  --   p_rate_type		     Rate Type
  --   p_round                Round decimal places
  FUNCTION convert_amount_sql (
		p_from_currency	VARCHAR2,
		p_to_currency		VARCHAR2,
		p_conversion_date	DATE,
		p_amount		     NUMBER,
		p_rate_type		VARCHAR2 DEFAULT NULL,
		p_round             NUMBER DEFAULT NULL) RETURN NUMBER;
-- -------------------------------------------------------------------------
-- |-----------------------< is_ncu_currency >-----------------------------|
-- -------------------------------------------------------------------------
--
-- Purpose
--  Returns EMU if currency is a valid NCU code
--
-- Arguments
--  p_currency     Currency code to check
--  p_date         Date that we are checking this currency
--
-- ----------------------------------------------------------------------------
FUNCTION is_ncu_currency
   (p_currency VARCHAR2
   ,p_date     DATE) RETURN varchar2;
--
-- -------------------------------------------------------------------------
-- |-----------------------< is_ncu_currency_sql >-------------------------|
-- -------------------------------------------------------------------------
--
-- Purpose
--  Returns EMU if currency is a valid NCU code
--
-- Arguments
--  p_currency     currency
--  p_date         date to check
--
-- ----------------------------------------------------------------------------
FUNCTION is_ncu_currency_sql
   (p_currency VARCHAR2
   ,p_date     DATE) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< efc_convert_number_amount >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   EFC conversion process money amount conversion function. Used to convert
--   NCU currency amounts to the EUR currency. Created for performance reasons.
--
-- Prerequisites:
--   This function should only be used as part of the EFC conversion process.
--   The p_round parameter should only be specified when the default number
--   of decimal places for the EUR currency should not be used.
--   The p_amount parameter should be set with a number datatype.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_from_currency                Yes  varchar2 Currency code which matches
--                                                the p_amount value.
--   p_amount                       Yes  number   Money value to be converted.
--   p_round                        No   number   Number of decimal places for
--                                                the converted value.
--
-- Post Success:
--   If the p_from_currency value is not an NCU currency as of sysdate or
--   the p_from_currency is already EUR then p_amount will be returned. The
--   value for p_round will be ignored.
--
--   If the p_from_currency is an NCU currency as of sysdate the p_amount
--   value will be converted to the EUR currency, using the derived_factor
--   defined in the FND_CURRENCIES table. If p_round is undefined or null then
--   the returned value will be specified to the number of decimal places for
--   the EUR currency as defined in the FND_CURRENCIES table. Otherwise the
--   number of decimal places specified by p_round will be used.
--
-- Post Failure:
--   The INVALID_CURRENCY exception will be raised if the p_from_currency
--   or 'EUR' currency does not exist in the FND_CURRENCIES table.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function efc_convert_number_amount
  (p_from_currency                 in     varchar2
  ,p_amount                        in     number
  ,p_round                         in     number   default null
  ) return number;
PRAGMA RESTRICT_REFERENCES(efc_convert_number_amount, WNDS);
-- ----------------------------------------------------------------------------
-- |----------------------< efc_get_derived_factor >--------------------------|
-- ----------------------------------------------------------------------------
--
function efc_get_derived_factor
 (p_from_currency                 in     varchar2
 ) return number;
--
-- ----------------------------------------------------------------------------
-- |----------------------< efc_convert_varchar2_amount >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   EFC conversion process money amount conversion function. Used to convert
--   NCU currency amounts held in varchar2 columns to the EUR currency.
--   Created for performance reasons.
--
-- Prerequisites:
--   This function should only be used as part of the EFC conversion process.
--   The p_round parameter should only be specified when the default number
--   of decimal places for the EUR currency should not be used.
--   The p_amount parameter must be set with a value in checkformat's varchar2
--   'MONEY' format.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_from_currency                Yes  varchar2 Currency code which matches
--                                                the p_amount value.
--   p_amount                       Yes  varchar2 Money value to be converted.
--   p_round                        No   number   Number of decimal places for
--                                                the converted value.
--
-- Post Success:
--   Provides the same behaviour as the efc_convert_number_amount function,
--   except returns the amount in checkformat's varchar2 'MONEY' format.
--
-- Post Failure:
--   The INVALID_CURRENCY exception will be raised if the p_from_currency
--   or 'EUR' currency does not exist in the FND_CURRENCIES table.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function efc_convert_varchar2_amount
  (p_from_currency                 in     varchar2
  ,p_amount                        in     varchar2
  ,p_round                         in     number   default null
  ) return varchar2;
PRAGMA RESTRICT_REFERENCES(efc_convert_varchar2_amount, WNDS);
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< efc_is_ncu_currency >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   EFC conversion process function to indicate if a currency is an NCU
--   (National Currency Unit) as of sysdate. Where possible this version
--   should be used, as it makes use of a cache for performance reasons.
--
--   The is_ncu_currency function which does not make use of a cache should
--   only be used when an WNPS pragma is required or the NCU status needs
--   to be detected using a different date to sysdate.
--
-- Prerequisites:
--   This function should only be used as part of the EFC conversion process.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_currency                     Yes  varchar2 Currency code to test for
--                                                NCU status.
--
-- Post Success:
--   Returns TRUE if p_currency is an NCU as of sysdate. Otherwise FALSE is
--   returned.
--
-- Post Failure:
--   The INVALID_CURRENCY exception will be raised if the p_currency
--   currency does not exist in the FND_CURRENCIES table.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
FUNCTION efc_is_ncu_currency
  (p_currency                      in     varchar2
   ) return boolean;
PRAGMA RESTRICT_REFERENCES(efc_is_ncu_currency,WNDS);

END hr_currency_pkg;

/
