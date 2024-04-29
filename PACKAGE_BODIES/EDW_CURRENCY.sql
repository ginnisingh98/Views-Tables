--------------------------------------------------------
--  DDL for Package Body EDW_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_CURRENCY" as
/* $Header: FIICACRB.pls 120.1 2002/10/22 21:52:39 djanaswa ship $ */

-- --------------------------------------------------------------
-- Name: convert_global_amount
-- --------------------------------------------------------------
FUNCTION convert_global_amount (
		x_trx_amount		NUMBER,
		x_base_amount		NUMBER DEFAULT NULL,
		x_trx_currency_code	VARCHAR2,
		x_base_currency_code	VARCHAR2 DEFAULT NULL,
		x_exchange_date		DATE,
		x_exchange_rate_type	VARCHAR2 DEFAULT NULL
) RETURN NUMBER IS

		l_converted_amount	NUMBER := -1;
		l_rate_type		VARCHAR2(30);
      l_global_currency_code  VARCHAR2(30);
      l_global_rate_type   VARCHAR2(15);

BEGIN
	Select /*+ FULL(SP) CACHE(SP) */
         warehouse_currency_code, rate_type
        into l_global_currency_code, l_global_rate_type
	From   EDW_LOCAL_SYSTEM_PARAMETERS SP;

  IF (x_base_amount is not NULL)	and
     (x_base_currency_code = l_global_currency_code) then
        l_converted_amount := x_base_amount;
  ELSIF (x_trx_amount is not NULL)	and
        (x_trx_currency_code = l_global_currency_code) then
        l_converted_amount := x_trx_amount;
  ELSIF (x_base_amount IS NULL AND x_trx_amount IS NULL ) then
        l_converted_amount := to_number(NULL);
  ELSIF (x_exchange_date IS NULL) THEN
        l_converted_amount := -1;
  ELSE

    IF (x_base_currency_code is not NULL) and
       (x_base_amount is not NULL)   then
        l_converted_amount := GL_CURRENCY_API.convert_amount_sql (
            x_base_currency_code,
            l_global_currency_code,
            x_exchange_date,
            l_global_rate_type,
            x_base_amount);
    END IF;

    IF (l_converted_amount = -1 AND
        x_trx_currency_code is not NULL AND
        x_trx_amount is not NULL) then
        l_converted_amount := GL_CURRENCY_API.convert_amount_sql (
            x_trx_currency_code,
            l_global_currency_code,
            x_exchange_date,
            l_global_rate_type,
            x_trx_amount);
    END IF;

  END IF;

  return (l_converted_amount);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
	raise_application_error(-20000,
		'No data found, trx_amount='||x_trx_amount||','||
		'base_amount='||x_base_amount||','||
		'trx_curr='||x_trx_currency_code||','||
		'base_curr='||x_base_currency_code||','||
		'date='||to_char(x_exchange_date)||','||
		'rate_type='||x_exchange_rate_type);
  WHEN OTHERS THEN
	raise_application_error(-20000,
		'Other error, trx_amount='||x_trx_amount||','||
		'base_amount='||x_base_amount||','||
		'trx_curr='||x_trx_currency_code||','||
		'base_curr='||x_base_currency_code||','||
		'date='||to_char(x_exchange_date)||','||
		'rate_type='||x_exchange_rate_type);

END convert_global_amount;



-- --------------------------------------------------------------
-- Name: convert_global_amount
-- Performance: Worse case, 9 buffer gets per call
-- --------------------------------------------------------------
FUNCTION convert_global_amount (
		x_trx_amount		NUMBER,
		x_base_amount		NUMBER DEFAULT NULL,
		x_trx_currency_code	VARCHAR2,
		x_set_of_books_id	NUMBER,
		x_exchange_date		DATE,
		x_exchange_rate_type	VARCHAR2 DEFAULT NULL
) RETURN NUMBER IS
		l_base_currency_code 	VARCHAR2(15) := NULL;
    		l_converted_amount 	NUMBER;
	cursor sob_cur is
		Select currency_code
		From   GL_SETS_OF_BOOKS
		Where  set_of_books_id = x_set_of_books_id;
BEGIN

  if (x_base_amount is not NULL) then
	open sob_cur;
	fetch sob_cur into l_base_currency_code;
	close sob_cur;
  end if;

  l_converted_amount := convert_global_amount(
					x_trx_amount,
					x_base_amount,
					x_trx_currency_code,
					l_base_currency_code,
					x_exchange_date,
					x_exchange_rate_type
					);

  return (l_converted_amount);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
	raise_application_error(-20000,
		'No data found, trx_amount='||x_trx_amount||','||
		'base_amount='||x_base_amount||','||
		'trx_curr='||x_trx_currency_code||','||
		'sob_id='||x_set_of_books_id||','||
		'date='||to_char(x_exchange_date)||','||
		'rate_type='||x_exchange_rate_type);
  WHEN OTHERS THEN
        if sob_cur%ISOPEN then
                close sob_cur;
        end if;
	raise_application_error(-20000,
		'Other error, trx_amount='||x_trx_amount||','||
		'base_amount='||x_base_amount||','||
		'trx_curr='||x_trx_currency_code||','||
		'sob_id='||x_set_of_books_id||','||
		'date='||to_char(x_exchange_date)||','||
		'rate_type='||x_exchange_rate_type);


END convert_global_amount;



-- -------------------------------
-- get_rate
-- -------------------------------

FUNCTION get_rate (
		x_trx_currency_code	VARCHAR2,
		x_exchange_date	        DATE,
		x_exchange_rate_type    VARCHAR2 DEFAULT NULL
) RETURN NUMBER IS

  l_warehouse_currency_code     VARCHAR2(15);
  l_warehouse_rate_type         VARCHAR2(30);
  l_global_currency_code  VARCHAR2(30);
  l_global_rate_type   VARCHAR2(15);

begin

	Select /*+ FULL(SP) CACHE(SP) */
         warehouse_currency_code, rate_type
        into l_global_currency_code, l_global_rate_type
	From   EDW_LOCAL_SYSTEM_PARAMETERS SP;

  if  x_trx_currency_code = l_global_currency_code then
    return 1;
  else
    return GL_CURRENCY_API.get_rate_sql (
                    x_trx_currency_code,
                    l_global_currency_code,
                    x_exchange_date,
                    l_global_rate_type);

  end if;

EXCEPTION
  WHEN OTHERS THEN
     return null;

END get_rate;


-- -------------------------------
-- get_mau
-- -------------------------------

FUNCTION get_mau RETURN NUMBER IS
  l_mau     NUMBER;
BEGIN

  select nvl( curr.minimum_accountable_unit, power( 10, (-1 * curr.precision)))
  into   l_mau
  from   edw_local_system_parameters    lsp,
         gl_currencies                  curr
  where  lsp.warehouse_currency_code = curr.currency_code;

  if l_mau is null then
    l_mau := 0.01;  -- assign default value if null;
  elsif l_mau = 0 then
    l_mau := 1;
  end if;

  return l_mau;

EXCEPTION
  WHEN OTHERS THEN
     return null;

END get_mau;


END EDW_CURRENCY;

/
