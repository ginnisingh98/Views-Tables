--------------------------------------------------------
--  DDL for Package Body ICX_CAT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_UTIL_PKG" AS
/* $Header: ICXCUTLB.pls 115.2 2003/08/10 02:41:55 jingyu ship $ */


  -- Procedure
  --   get_info
  --
  -- Arguments
  --   x_currency		Currency to be checked
  --   x_mau                    Minimum accountable unit
  --
  PROCEDURE get_info(
		x_currency			VARCHAR2,
		x_mau			IN OUT NOCOPY NUMBER) IS

  BEGIN
     -- Get currency information from FND_CURRENCIES table
     SELECT  nvl( minimum_accountable_unit, power( 10, (-1 * extended_precision)))
     INTO    x_mau
     FROM    FND_CURRENCIES
     WHERE   currency_code = x_currency;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
	raise INVALID_CURRENCY;

  END get_info;

  --

  FUNCTION convert_amount_sql (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL,
		x_amount		NUMBER ) RETURN NUMBER IS

    to_mau              NUMBER;
    converted_amount 		NUMBER;
    default_conversion_type VARCHAR2(25);
  BEGIN

    -- If from currency is null, then assume it is same as to currency
    if ( x_from_currency = x_to_currency OR x_from_currency is null) then
        return( x_amount);
    END IF;

    -- use default rate type from purchasing options if rate type is null
    if ( x_conversion_type is null ) then
      begin
       SELECT default_rate_type into default_conversion_type FROM po_system_parameters;
      exception
        WHEN OTHERS THEN default_conversion_type := null;
      end;
    end if;

    get_info( x_to_currency, to_mau);

    if ( x_conversion_type is null ) then
      converted_amount :=   round ( ( x_amount * gl_currency_api.get_rate(x_from_currency,x_to_currency, x_conversion_date, default_conversion_type ))/to_mau ) *  to_mau ;
    else
       converted_amount :=   round ( ( x_amount * gl_currency_api.get_rate(x_from_currency,x_to_currency, x_conversion_date, x_conversion_type ))/to_mau ) *  to_mau ;
    end if;

    return( converted_amount );

    EXCEPTION
    	WHEN gl_currency_api.NO_RATE THEN
  	  --bmunagal, 11/05/02, for FPI, return null if there is no rate
	    --converted_amount := -1;
  	  converted_amount := null;
	    return( converted_amount );

  	WHEN INVALID_CURRENCY THEN
	    converted_amount := -2;
	    return( converted_amount );

  END convert_amount_sql;




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
		x_amount		NUMBER ) RETURN NUMBER IS

    to_mau              NUMBER;
    converted_amount 		NUMBER;
    default_conversion_type VARCHAR2(25);

  BEGIN

    -- If from currency is null, then assume it is same as to currency
    if ( x_from_currency = x_to_currency OR x_from_currency is null) then
        return( x_amount);
    END IF;

    get_info( x_to_currency, to_mau);

    if(x_conversion_rate is not null AND x_conversion_rate > 0) then
      -- This is User rate, just use the rate
      converted_amount := round ( ( x_amount * x_conversion_rate)/to_mau ) *  to_mau ;
    elsif (x_conversion_type is null)  then
       -- Get the rate depending on the default rate type from purchasing options
      begin
        SELECT default_rate_type into default_conversion_type FROM po_system_parameters;
      exception
        WHEN OTHERS THEN default_conversion_type := null;
      end;
      converted_amount :=   round ( ( x_amount * gl_currency_api.get_rate(x_from_currency,x_to_currency, x_conversion_date, default_conversion_type ))/to_mau ) *  to_mau ;
    else
      -- Get the rate depending on rate type
      converted_amount :=   round ( ( x_amount * gl_currency_api.get_rate(x_from_currency,x_to_currency, x_conversion_date, x_conversion_type ))/to_mau ) *  to_mau ;
    end if;

    return( converted_amount );

    EXCEPTION
    	WHEN gl_currency_api.NO_RATE THEN
  	  --bmunagal, 11/05/02, for FPI, return null if there is no rate
	    --converted_amount := -1;
  	  converted_amount := null;
	    return( converted_amount );

  	WHEN INVALID_CURRENCY THEN
	    converted_amount := -2;
	    return( converted_amount );

  END convert_amount_sql;

end icx_cat_util_pkg;

/
