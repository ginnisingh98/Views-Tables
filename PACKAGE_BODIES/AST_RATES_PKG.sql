--------------------------------------------------------
--  DDL for Package Body AST_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_RATES_PKG" AS
 /* $Header: astrtrtb.pls 115.9 2003/09/09 03:38:27 sssomesw ship $ */
----------------------------------------------------------------------------
--    Purpose: To convert from one currency to another
-- Parameters: From Currency
--             To Currency,
--             Conversion Date
--             Amount to be converted
--    Returns: Converted Amount
--    Pre-req: The user has to make sure the following profiles are defined
--             correctly
--             AS_DEFAULT_PERIOD_TYPE
--             AS_FORECAST_CALENDAR
--  Created By     Date         Comments
--  sesundar       29-AUG-01    Initial version
--                              if the conversion status flag returns 1,it
--                              means that the conversion rate is not
--                              defined properly
----------------------------------------------------------------------------

FUNCTION CONVERT_AMOUNT( x_from_currency VARCHAR2,
					x_to_currency VARCHAR2,
					x_conversion_date DATE,
					x_amount NUMBER) return NUMBER IS

l_period_type      VARCHAR2(100);
l_period_set_name  VARCHAR2(100);
l_converted_amount NUMBER;
l_converted_status NUMBER;

BEGIN

l_period_type:=nvl(fnd_profile.value('AS_DEFAULT_PERIOD_TYPE'),'Month');
l_period_set_name:=nvl(fnd_profile.value('AS_FORECAST_CALENDAR'),'Accounting');

	 begin


	   select round((x_amount/rate.denominator_rate)*rate.numerator_rate,2),
			rate.conversion_status_flag
			into
			l_converted_amount,
			l_converted_status
        from   as_period_rates rate,
			as_period_days day
        where  rate.from_currency=x_from_currency
	   and    rate.to_currency=x_to_currency
	   and    day.period_name=rate.period_name
	   and    day.period_set_name=l_period_set_name
	   and    day.period_type=l_period_type
	   and    day.period_day=trunc(x_conversion_date);


	 exception
		 when others then
		   return null; /* 3133848 x_amount; */

	 end;

	 if l_converted_status=0 then
	    return l_converted_amount;
      else
		   return null; /* 3133848 x_amount; */
      end if;

END CONVERT_AMOUNT;

END;

/
