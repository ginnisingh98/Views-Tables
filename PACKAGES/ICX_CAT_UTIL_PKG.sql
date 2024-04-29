--------------------------------------------------------
--  DDL for Package ICX_CAT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_UTIL_PKG" AUTHID CURRENT_USER as
/* $Header: ICXCUTLS.pls 115.1 2002/11/21 08:40:48 bmunagal ship $ */


  INVALID_CURRENCY  EXCEPTION;
  NO_RATE           EXCEPTION;


  --
  -- Function
  --   convert_amount_sql
  --
  -- Purpose
  -- 	Returns the amount converted from the from currency into the
  --    functional currency of that set of books by calling convert_amount().
  --    The amount returned is rounded to the precision and minimum account
  --    unit of the to currency.
  --
  --    Return -1 if the NO_RATE exception is raised in convert_amount().
  --           -2 if the INVALID_CURRENCY exception is raised in
  --                 convert_amount().
  --
  -- History
  --   03-JAN-2002  SSURI 	Created
  FUNCTION convert_amount_sql (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
		x_amount		NUMBER ) RETURN NUMBER;
         PRAGMA   RESTRICT_REFERENCES(convert_amount_sql,WNDS,WNPS,RNPS);

  --
  -- Function
  --   convert_amount_sql
  --
  -- Purpose
  --
  --    Overloaded function: If x_conversion_rate is not null, the rate is used to convert
  --       otherwise, rate is calculated using from and to currencies
  --
  -- 	Returns the amount converted from the from currency into the
  --    functional currency of that set of books by calling convert_amount().
  --    The amount returned is rounded to the precision and minimum account
  --    unit of the to currency.
  --
  --    Return -1 if the NO_RATE exception is raised in convert_amount().
  --           -2 if the INVALID_CURRENCY exception is raised in
  --                 convert_amount().
  --
  -- History
  --   30-OCT-2002  BMUNAGAL 	Created
  FUNCTION convert_amount_sql (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
		x_conversion_rate	NUMBER,
		x_amount		NUMBER ) RETURN NUMBER;
         PRAGMA   RESTRICT_REFERENCES(convert_amount_sql,WNDS,WNPS,RNPS);

END icx_cat_util_pkg;

 

/
