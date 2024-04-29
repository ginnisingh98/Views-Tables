--------------------------------------------------------
--  DDL for Package Body FII_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_CURRENCY" AS
/* $Header: FIICACUB.pls 120.14 2005/10/30 05:07:46 appldev noship $ */


g_prim_currency_code constant varchar2(15) := bis_common_parameters.get_currency_code;
g_prim_rate_type constant varchar2(30) := bis_common_parameters.get_rate_type;
g_sec_currency_code constant varchar2(15) := bis_common_parameters.get_secondary_currency_code;
g_sec_rate_type constant varchar2(30) := bis_common_parameters.get_secondary_rate_type;
g_treasury_rate_type constant Varchar2(30) := bis_common_parameters.get_treasury_rate_type;

/* Below mentioned three variable are for Oracle Internal only */
g_fii_fixed_curr_it constant varchar2(40) := fnd_profile.value('FII_FIXED_CURRENCY_IT');
g_fii_left_curr constant varchar2(15) := substrb(g_fii_fixed_curr_it,1,INSTR(g_fii_fixed_curr_it,'=')-1);
g_fii_right_curr constant varchar2(15):=substrb(g_fii_fixed_curr_it,INSTR(g_fii_fixed_curr_it,'=')+1);
/* Below mentioned three variables for maintaining the cahce */
g_stack_count number:=0;
g_stack_count_sec number:=0;
g_max_stack_size constant number:=20;

TYPE g_primary_cache_Rate IS RECORD
  (from_currency  varchar2(15),
   exchange_date  Date,
   rate           number);

TYPE g_secondary_cache_Rate IS RECORD
  (from_currency  varchar2(15),
   exchange_date  Date,
   rate           number);

TYPE g_prim_cache_rate1 IS VARRAY(20) OF g_primary_cache_rate;

TYPE g_sec_cache_rate1 IS VARRAY(20) OF g_secondary_cache_rate;


g_prim_cache_rate g_prim_cache_rate1;

g_sec_cache_rate g_sec_cache_rate1;

-- --------------------------------------------------------------------------
-- Name : return_prim_rate_if_in_cache
-- Type : Function
-- Description : Returns rate from the PL/SQL table if the given combination
--               of from currency, exchange date
--               exists in the PL/SQL table.
--               Returns 0 if the combination doesn't exist.
-----------------------------------------------------------------------------

function return_prim_rate_if_in_cache(p_from_currency varchar2,
                                        p_exchange_date date)
                        return number is

begin

     if g_prim_cache_rate.exists(1) then
         -- check whether the rate is present
         FOR i in g_prim_cache_rate.FIRST..g_prim_cache_rate.LAST LOOP
	    if ((g_prim_cache_rate(i).from_currency=p_from_currency)
	        AND (g_prim_cache_rate(i).exchange_date=p_exchange_date)) then
		 --combination exists return the rate.
		 return (g_prim_cache_rate(i).rate);

	    end if;
	 END LOOP;
         return 0;
     else
        --pl/sql is empty
	return 0;
     end if;
EXCEPTION
WHEN OTHERS THEN
   return 0;
end;

-- --------------------------------------------------------------------------
-- Name : cache_prim_rate
-- Type : Procedure
-- Description : Caches rate information
-----------------------------------------------------------------------------
procedure cache_prim_rate(p_from_currency varchar2,
                     p_exchange_date date,
	             p_rate number) IS

begin
    if (p_rate <0) then
       null; -- do nothing
    else


	    if (g_stack_count >= g_max_stack_size) then
	        g_stack_count:=0;
	    end if;

	    g_stack_count:=g_stack_count+1;

	  g_prim_cache_rate(g_stack_count).from_currency:=p_from_currency;
          g_prim_cache_rate(g_stack_count).exchange_date:=p_exchange_date;
	  g_prim_cache_rate(g_stack_count).rate:=p_rate;

    end if;
EXCEPTION
WHEN OTHERS THEN
   null;
end;

-- --------------------------------------------------------------------------
-- Name : return_sec_rate_if_in_cache
-- Type : Function
-- Description : Returns rate from the PL/SQL table if the given combination
--               of from currency, exchange date
--               exists in the PL/SQL table.
--               Returns 0 if the combination doesn't exist.
-----------------------------------------------------------------------------

function return_sec_rate_if_in_cache(p_from_currency varchar2,
                                        p_exchange_date date)
                        return number is

begin

     if g_sec_cache_rate.exists(1) then
         -- check whether the rate is present
         FOR i in g_sec_cache_rate.FIRST..g_sec_cache_rate.LAST LOOP
	    if ((g_sec_cache_rate(i).from_currency=p_from_currency)
	        AND (g_sec_cache_rate(i).exchange_date=p_exchange_date)) then
		 --combination exists return the rate.
		 return (g_sec_cache_rate(i).rate);

	    end if;
	 END LOOP;
         return 0;
     else
        --pl/sql is empty
	return 0;
     end if;
EXCEPTION
WHEN OTHERS THEN
   return 0;

end;

-- --------------------------------------------------------------------------
-- Name : cache_sec_rate
-- Type : Procedure
-- Description : Caches rate information
-----------------------------------------------------------------------------
procedure cache_sec_rate(p_from_currency varchar2,
                     p_exchange_date date,
	             p_rate number) IS

begin
     if (p_rate<0) then
       null;
     else

       	    if (g_stack_count_sec >= g_max_stack_size) then
	        g_stack_count_sec:=0;
	    end if;

	    g_stack_count_sec:=g_stack_count_sec+1;

	  g_sec_cache_rate(g_stack_count_sec).from_currency:=p_from_currency;
	  g_sec_cache_rate(g_stack_count_sec).exchange_date:=p_exchange_date;
	  g_sec_cache_rate(g_stack_count_sec).rate:=p_rate;

     end if;
EXCEPTION
WHEN OTHERS THEN
   null;
end;


Function get_global_rate_primary(
      p_from_currency_code  VARCHAR2,
      p_exchange_date           DATE) RETURN NUMBER
 PARALLEL_ENABLE  IS

  l_global_currency_code  VARCHAR2(30);
  l_global_rate_type   VARCHAR2(15);
  l_max_roll_days NUMBER;
  l_exchange_date DATE;
  rate  NUMBER;

begin

  IF (compare_currency_codes(p_from_currency_code,g_prim_currency_code)=1) THEN
     return 1;
  END IF;


  l_max_roll_days := 32;

  l_exchange_date := p_exchange_date;



  IF (p_from_currency_code = 'EUR' AND l_exchange_date < to_date('01/01/1999','DD/MM/RRRR') )
      THEN l_exchange_date := to_date('01/01/1999','DD/MM/RRRR');
  ELSIF (g_prim_currency_code = 'EUR' AND l_exchange_date < to_date('01/01/1999','DD/MM/RRRR') )
      THEN l_exchange_date := to_date('01/01/1999','DD/MM/RRRR');
  END IF;



    rate := GL_CURRENCY_API.get_closest_rate_sql (
                    p_from_currency_code,
                    g_prim_currency_code,
                    l_exchange_date,
                    g_prim_rate_type,
                    l_max_roll_days);



  IF (p_from_currency_code = 'EUR'
        AND p_exchange_date < to_date('01/01/1999','DD/MM/RRRR')
        AND rate = -1 )
      THEN rate := -3;
  ELSIF (g_prim_currency_code = 'EUR'
        AND p_exchange_date < to_date('01/01/1999','DD/MM/RRRR')
        AND rate = -1 )
      THEN rate := -3;
  END IF;

  RETURN (rate);


EXCEPTION
  WHEN OTHERS THEN
    return null;


END get_global_rate_primary;


Function get_global_rate_secondary(
      p_from_currency_code  VARCHAR2,
      p_exchange_date           DATE) RETURN NUMBER
PARALLEL_ENABLE  IS

  l_global_currency_code  VARCHAR2(30);
  l_global_rate_type   VARCHAR2(15);
  l_max_roll_days NUMBER;
  l_exchange_date DATE;
  rate NUMBER;

begin

  IF (compare_currency_codes(p_from_currency_code,g_sec_currency_code)=1) THEN
     return 1;
  END IF;

  l_max_roll_days := 32;

  l_exchange_date := p_exchange_date;


  IF (p_from_currency_code = 'EUR' AND l_exchange_date < to_date('01/01/1999','DD/MM/RRRR') )
      THEN l_exchange_date := to_date('01/01/1999','DD/MM/RRRR');
  ELSIF (g_sec_currency_code = 'EUR' AND l_exchange_date < to_date('01/01/1999','DD/MM/RRRR') )
      THEN l_exchange_date := to_date('01/01/1999','DD/MM/RRRR');
  END IF;

  IF (g_sec_currency_code IS NULL) THEN
	 rate := 1;

   ELSE     rate := GL_CURRENCY_API.get_closest_rate_sql (
                    p_from_currency_code,
                    g_sec_currency_code,
                    l_exchange_date,
                    g_sec_rate_type,
                    l_max_roll_days);

   END IF;

  IF (p_from_currency_code = 'EUR'
        AND p_exchange_date < to_date('01/01/1999','DD/MM/RRRR')
        AND rate = -1 )
      THEN rate := -3;
  ELSIF (g_sec_currency_code = 'EUR'
        AND p_exchange_date < to_date('01/01/1999','DD/MM/RRRR')
        AND rate = -1 )
      THEN rate := -3;
  END IF;

  RETURN (rate);

EXCEPTION
  WHEN OTHERS THEN
     return null;


END get_global_rate_secondary;

--*************************************************
Function convert_global_amt_primary(
      p_from_currency_code  VARCHAR2,
      p_from_amount         NUMBER,
      p_exchange_date       DATE) RETURN NUMBER
PARALLEL_ENABLE IS

      l_converted_amount   NUMBER := -1;
      l_global_currency_code  VARCHAR2(30);
      l_global_rate_type   VARCHAR2(15);
      l_max_roll_days NUMBER;

BEGIN

	l_global_currency_code := g_prim_currency_code;
	l_global_rate_type := g_prim_rate_type;
   l_max_roll_days := 32;

  IF (l_global_currency_code IS NULL) THEN
		  l_converted_amount := p_from_amount;
  ELSIF (p_from_amount is not NULL and
     compare_currency_codes(p_from_currency_code,l_global_currency_code)=1) then
        l_converted_amount := p_from_amount;
  ELSIF (p_from_amount IS NULL) then
        l_converted_amount := to_number(NULL);
  ELSIF (p_exchange_date IS NULL OR
         p_from_currency_code IS NULL) THEN
        l_converted_amount := -1;
  ELSE
        l_converted_amount := GL_CURRENCY_API.convert_closest_amount_sql (
            p_from_currency_code,
            l_global_currency_code,
            p_exchange_date,
            l_global_rate_type,
            1,
            p_from_amount,
            l_max_roll_days);
  END IF;

  return (l_converted_amount);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   raise_application_error(-20000,
      'No data found,' ||
      'from_amount='||p_from_amount||','||
      'from_curr='||p_from_currency_code||','||
      'date='||to_char(p_exchange_date)||','||
      'rate_type='||l_global_rate_type);
  WHEN OTHERS THEN
   raise_application_error(-20000,
      'Other error,' ||
      'from_amount='||p_from_amount||','||
      'from_curr='||p_from_currency_code||','||
      'date='||to_char(p_exchange_date)||','||
      'rate_type='||l_global_rate_type);

END convert_global_amt_primary;

--*************************************************
Function convert_global_amt_secondary(
      p_from_currency_code  VARCHAR2,
      p_from_amount         NUMBER,
      p_exchange_date       DATE) RETURN NUMBER
PARALLEL_ENABLE IS

      l_converted_amount   NUMBER := -1;
      l_global_currency_code  VARCHAR2(30);
      l_global_rate_type   VARCHAR2(15);
      l_max_roll_days NUMBER;

BEGIN

   l_global_currency_code := g_sec_currency_code;
   l_global_rate_type := g_sec_rate_type;
   l_max_roll_days := 32;

  IF (l_global_currency_code IS NULL) THEN
        l_converted_amount := p_from_amount;
  ELSIF (p_from_amount is not NULL and
     compare_currency_codes(p_from_currency_code,l_global_currency_code)=1) then
        l_converted_amount := p_from_amount;
  ELSIF (p_from_amount IS NULL) then
        l_converted_amount := to_number(NULL);
  ELSIF (p_exchange_date IS NULL OR
         p_from_currency_code IS NULL) THEN
        l_converted_amount := -1;
  ELSE
        l_converted_amount := GL_CURRENCY_API.convert_closest_amount_sql (
            p_from_currency_code,
            l_global_currency_code,
            p_exchange_date,
            l_global_rate_type,
            1,
            p_from_amount,
            l_max_roll_days);
  END IF;

  return (l_converted_amount);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
   raise_application_error(-20000,
      'No data found,' ||
      'from_amount='||p_from_amount||','||
      'from_curr='||p_from_currency_code||','||
      'date='||to_char(p_exchange_date)||','||
      'rate_type='||l_global_rate_type);
  WHEN OTHERS THEN
   raise_application_error(-20000,
      'Other error,' ||
      'from_amount='||p_from_amount||','||
      'from_curr='||p_from_currency_code||','||
      'date='||to_char(p_exchange_date)||','||
      'rate_type='||l_global_rate_type);

END convert_global_amt_secondary;

--**********************************************************
FUNCTION get_mau_primary RETURN NUMBER PARALLEL_ENABLE IS
  l_mau     NUMBER;
  l_warehouse_currency_code VARCHAR2(15);
  l_exchange_date DATE;
  rate NUMBER;

BEGIN

	l_warehouse_currency_code := bis_common_parameters.get_currency_code;

  	select nvl( curr.minimum_accountable_unit, power( 10, (-1 * curr.precision)))
  	into   l_mau
  	from   gl_currencies                  curr
  	where  curr.currency_code = l_warehouse_currency_code;

  if l_mau is null then
    l_mau := 0.01;  -- assign default value if null;
  elsif l_mau = 0 then
    l_mau := 1;
  end if;

  return l_mau;

EXCEPTION
  WHEN OTHERS THEN
     return null;

END get_mau_primary;

--**********************************************************
FUNCTION get_mau_secondary RETURN NUMBER PARALLEL_ENABLE IS
  l_mau     NUMBER;
  l_warehouse_currency_code VARCHAR2(15);
BEGIN

   l_warehouse_currency_code := bis_common_parameters.get_secondary_currency_code;

   select nvl( curr.minimum_accountable_unit, power( 10, (-1 * curr.precision)))
   into   l_mau
   from   gl_currencies                  curr
   where  curr.currency_code = l_warehouse_currency_code;

  if l_mau is null then
    l_mau := 0.01;  -- assign default value if null;
  elsif l_mau = 0 then
    l_mau := 1;
  end if;

  return l_mau;

EXCEPTION
  WHEN OTHERS THEN
     return null;

END get_mau_secondary;

--**********************************************************

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
      p_exchange_rate_type VARCHAR2) RETURN NUMBER
PARALLEL_ENABLE IS

  l_exchange_date DATE;
  rate            NUMBER;

  l_max_roll_days NUMBER := 32;

begin

  l_exchange_date := p_exchange_date;


  IF (compare_currency_codes(p_from_currency_code,p_to_currency_code)=1) THEN
    rate := 1;

  ELSE

     IF (p_from_currency_code = 'EUR' AND l_exchange_date < to_date('01/01/1999','DD/MM/RRRR') )
      THEN l_exchange_date := to_date('01/01/1999','DD/MM/RRRR');
     ELSIF (p_to_currency_code = 'EUR' AND l_exchange_date < to_date('01/01/1999','DD/MM/RRRR') )
      THEN l_exchange_date := to_date('01/01/1999','DD/MM/RRRR');
     END IF;

    rate :=  GL_CURRENCY_API.get_closest_rate_sql (
                    p_from_currency_code,
                    p_to_currency_code,
                    l_exchange_date,
                    p_exchange_rate_type,
                    l_max_roll_days);

  END IF;

  IF (p_from_currency_code = 'EUR'
        AND p_exchange_date < to_date('01/01/1999','DD/MM/RRRR')
        AND rate = -1 )
      THEN rate := -3;
  ELSIF (p_to_currency_code = 'EUR'
        AND p_exchange_date < to_date('01/01/1999','DD/MM/RRRR')
        AND rate = -1 )
      THEN rate := -3;
  END IF;

  RETURN (rate);

EXCEPTION
  WHEN OTHERS THEN
    RETURN -4; -- Could we return -4 instead of NULL???

END get_rate;

-----------------------------
-- Rate Conversion API's
-----------------------------


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
				p_currency_code2 IN VARCHAR2) RETURN NUMBER
				PARALLEL_ENABLE IS

BEGIN
      IF (p_currency_code1=p_currency_code2) THEN
          return 1;
      ELSE
         if (g_fii_fixed_curr_it is not null) then
           CASE g_fii_left_curr
	   WHEN p_currency_code1 THEN
	           if (g_fii_right_curr=p_currency_code2) then
		      return 1;
                   else
		      return 0;
                   end if;
           WHEN p_currency_code2 THEN
	          if (g_fii_right_curr=p_currency_code1) then
		      return 1;
                  else
		      return 0;
		  end if;
	   ELSE return 0;
	   END CASE;

         end if;

          return 0;
      END IF;
END;

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
--              Retunrs -3 when one of the currency is EUR and the
--              exchange date is before Jan 1 ,1999
--              Return -4 for any other exception.
-- How the exceptions are handled :
--     Other exceptions are handled by get_fc_to_pgc_rate
--     No Rate and Invalid Currency are handled in gl_currency_api.get_closest_rate_sql
--     When one of the currency is EUR and exchange date is before Jan 1,1999
--     -3 is returned from get_rate.
---------------------------------------------------------------------------
FUNCTION get_fc_to_pgc_rate(p_tc_code IN VARCHAR2,
                            p_fc_code IN VARCHAR2,
			    p_exchange_date IN DATE) RETURN NUMBER PARALLEL_ENABLE IS
  l_rate NUMBER;
BEGIN


      IF (compare_currency_codes(p_tc_code,g_prim_currency_code)=1) THEN
          return 0;
      ELSE
          l_rate:=return_prim_rate_if_in_cache(p_fc_code,p_exchange_date);
         if (l_rate=0) then
	        l_rate:=get_rate(p_fc_code,g_prim_currency_code,p_exchange_date,g_prim_rate_type);
		cache_prim_rate(p_fc_code,p_exchange_date,l_rate);
	 end if;
	     return l_rate;
      END IF;

EXCEPTION
   WHEN OTHERS THEN
      return -4;
END;


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
--          global currency or secondary global currency is not defined.
--          Returns the rate between the functional currency and the
--          secondary global currency.
-- Exceptions : Returns -1 when no rate exists
--              Returns -2 when invalid currency
--              Retunrs -3 when one of the currency is EUR and the
--              exchange date is before Jan 1 ,1999
--              Return -4 for any other exception.
-- How the exceptions are handled :
--     Other exceptions are handled by get_fc_to_sgc_rate
--     No Rate and Invalid Currency are handled in gl_currency_api.get_closest_rate_sql
--     When one of the currency is EUR and exchange date is before Jan 1,1999
--     -3 is returned from get_rate.
---------------------------------------------------------------------------
FUNCTION get_fc_to_sgc_rate(p_tc_code IN VARCHAR2,
                            p_fc_code IN VARCHAR2,
			    p_exchange_date IN DATE) RETURN NUMBER PARALLEL_ENABLE IS
 l_rate number;

BEGIN


      IF (g_sec_currency_code is not null) THEN
        IF (compare_currency_codes(p_tc_code,g_sec_currency_code)=1) THEN
             return 0;
        ELSE
	      l_rate:=return_sec_rate_if_in_cache(p_fc_code,p_exchange_date);
	      if (l_rate=0) then
                l_rate:=get_rate(p_fc_code,g_sec_currency_code,p_exchange_date,g_sec_rate_type);
		cache_sec_rate(p_fc_code,p_exchange_date,l_rate);
	      end if;
	        return l_rate;
        END IF;
      ELSE
          return to_number(null); -- No secondary Global Currency .No need for conversion

      END IF;

EXCEPTION
  WHEN OTHERS THEN
      return -4;
END;

------------------------------------------
--Modules Not Storing Functional Currency
------------------------------------------

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
--              -5,-6,-7 ,-8 are handled in get_tc_pgc_rate
----------------------------------------------------------------------------------------------

FUNCTION get_tc_to_pgc_rate(p_tc_code IN VARCHAR2,
                            p_exchange_date1 IN DATE,
			    p_exchange_rate_type IN VARCHAR2,
			    p_fc_code IN VARCHAR2,
			    p_exchange_date2 IN DATE,
			    p_rate IN NUMBER DEFAULT NULL) RETURN NUMBER PARALLEL_ENABLE IS

  l_rate          number;
  l_rate1         number;
BEGIN


      IF (compare_currency_codes(p_tc_code,g_prim_currency_code)=1) THEN
          return 1;
      END IF;

      IF (p_rate is not null and p_rate > 0) THEN
          IF (compare_currency_codes(p_fc_code,g_prim_currency_code)=1) THEN
	      return p_rate;
          ELSE
	      l_rate:=return_prim_rate_if_in_cache(p_fc_code,p_exchange_date2);
	      if (l_rate=0) then
                  l_rate:=get_rate(p_fc_code,g_prim_currency_code,p_exchange_date2,g_prim_rate_type);

	          if (l_rate < 0) then
	             if (l_rate=-1) then
		           return -6;
		     elsif (l_rate=-3) then
		           return -7;
		     end if;
                       return l_rate;
                  end if;
		  cache_prim_rate(p_fc_code,p_exchange_date2,l_rate);
	      end if;

	       return l_rate * p_rate;

          END IF;
      ELSIF (p_rate < 0) THEN
             if (p_rate = -1) then
	         return -5;
	     else
	         return p_rate;
	     end if;
       ELSE
          /* Covert from tc to fc */

	   IF (p_exchange_rate_type is not null) THEN
	        l_rate:=get_rate(p_tc_code,p_fc_code,p_exchange_date1,p_exchange_rate_type);
           ELSE
	       if (g_treasury_rate_type is null) then
	          return -8;
	       else
	           l_rate:=get_rate(p_tc_code,p_fc_code,p_exchange_date1,g_treasury_rate_type);
	       end if;
           END IF;

	   if (l_rate < 0) then
               if (l_rate = -1 ) then
	          l_rate:= -5;
               else
	          return l_rate;
	       end if;
	   end if;

          /* Now convert from fc to gc */
	   IF (compare_currency_codes(p_fc_code,g_prim_currency_code)=1) THEN
	      return l_rate*1;
	   ELSE
	      l_rate1:=return_prim_rate_if_in_cache(p_fc_code,p_exchange_date2);
              if (l_rate1=0) then
	         l_rate1:=get_rate(p_fc_code,g_prim_currency_code,p_exchange_date2,g_prim_rate_type);
		  if (l_rate1 < 0) then
                     if (l_rate1 = -1 ) then
	                   l_rate1:= -6;
                     elsif (l_rate1 = -3) then
	                   return -7;
	             else
	               return l_rate1;
	             end if;
		  else
		     cache_prim_rate(p_fc_code,p_exchange_date2,l_rate);
	          end if;
	      end if;

	      if (l_rate=-5 and l_rate1=-6) then
	          return -6;
	      elsif (l_rate > 0 and l_rate1=-6) then
	          return l_rate1;
              elsif (l_rate1 > 0 and l_rate=-5) then
	          return l_rate;
              end if;

	         return l_rate*l_rate1;

           END IF;
      END IF;
EXCEPTION
  WHEN OTHERS THEN
     return -4;
END;

-- --------------------------------------------------------------------------------
-- Name : get_tc_to_sgc_rate
-- Type : Function
-- Description : This api is to be used for modules not storing functional currency.
--               Returns rate to convert amounts from transactional currency to
--               secondary global currency.
-- Output :
--                o If transactional currency and secondary global currency is the same
--                  then return 1. user-defined rate is ignored.
--                o If secondary global currency is not defined then it returns 1.
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
--              -5,-6,-7 ,-8 are handled in get_tc_sgc_rate
----------------------------------------------------------------------------------------------


FUNCTION get_tc_to_sgc_rate(p_tc_code IN VARCHAR2,
                            p_exchange_date1 IN DATE,
			    p_exchange_rate_type IN VARCHAR2,
			    p_fc_code IN VARCHAR2,
			    p_exchange_date2 IN DATE,
			    p_rate IN NUMBER DEFAULT NULL) RETURN NUMBER PARALLEL_ENABLE IS

  l_rate          number;
  l_rate1         number;
BEGIN

    IF (g_sec_currency_code is not null ) then
      IF (compare_currency_codes(p_tc_code,g_sec_currency_code)=1) THEN
          return 1;
      END IF;

      IF (p_rate is not null and p_rate > 0) THEN
          IF (compare_currency_codes(p_fc_code,g_sec_currency_code)=1) THEN
	      return p_rate;
          ELSE
	      l_rate:=return_sec_rate_if_in_cache(p_fc_code,p_exchange_date2);
	      if (l_rate=0) then
	          l_rate:=get_rate(p_fc_code,g_sec_currency_code,p_exchange_date2,g_sec_rate_type);
	          if (l_rate < 0) then
	              if (l_rate=-1) then
		           return -6;
		      elsif (l_rate=-3) then
		           return -7;
		      end if;
                           return l_rate;
                   end if;
		   cache_sec_rate(p_fc_code,p_exchange_date2,l_rate);
              end if;
	       return l_rate * p_rate;

          END IF;
      ELSIF (p_rate < 0) THEN
             if (p_rate = -1) then
	         return -5;
	     else
	         return p_rate;
	     end if;
       ELSE
          /* Covert from tc to fc */
           IF (p_exchange_rate_type is not null) THEN
	        l_rate:=get_rate(p_tc_code,p_fc_code,p_exchange_date1,p_exchange_rate_type);
           ELSE
	       if (g_treasury_rate_type is null) then
	           return -8;
	       else
	        l_rate:=get_rate(p_tc_code,p_fc_code,p_exchange_date1,g_treasury_rate_type);
	       -- l_rate:=get_rate(p_tc_code,p_fc_code,p_exchange_date1,'Corporate');
	       end if;
           END IF;

	   if (l_rate < 0) then
               if (l_rate = -1 ) then
	          l_rate:= -5;
               else
	          return l_rate;
	       end if;
	   end if;

          /* Now convert from fc to gc */
	   IF (compare_currency_codes(p_fc_code,g_sec_currency_code)=1) THEN
	      return l_rate*1;
	   ELSE
	      l_rate1:=return_sec_rate_if_in_cache(p_fc_code,p_exchange_date2);
	      if (l_rate1=0) then
	         l_rate1:=get_rate(p_fc_code,g_sec_currency_code,p_exchange_date2,g_sec_rate_type);
	         if (l_rate1 < 0) then
                   if (l_rate1 = -1 ) then
	                l_rate1 := -6;
                   elsif (l_rate1 = -3) then
	                return -7;
	           else
	                return l_rate1;
	           end if;
		 else
		   cache_sec_rate(p_fc_code,p_exchange_date2,l_rate1);
	        end if;
	      end if;

	      if (l_rate=-5 and l_rate1=-6) then
	          return -6;
	      elsif (l_rate > 0 and l_rate1=-6) then
	          return l_rate1;
              elsif (l_rate1 > 0 and l_rate=-5) then
	          return l_rate;
              end if;


	         return l_rate*l_rate1;

           END IF;
      END IF;
    ELSE
         return to_number(null); -- No gobal secondary currency exists.
    END IF;
EXCEPTION
  WHEN OTHERS THEN
     return -4;
END;


END FII_CURRENCY;

/
