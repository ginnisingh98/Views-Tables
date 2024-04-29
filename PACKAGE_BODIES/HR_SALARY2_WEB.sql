--------------------------------------------------------
--  DDL for Package Body HR_SALARY2_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SALARY2_WEB" AS
/* $Header: hrprsa2w.pkb 120.2 2005/09/25 09:09:08 svittal noship $*/


    /* ======================================================================
    || Function: get_currency_symbol
    ||----------------------------------------------------------------------
    || Description: returns currency symbol for a given currency code
    ||
    ||
    || Pre Conditions: a valid currency code
    ||
    ||
    || In Parameters:
    ||                p_currency_code
    ||                p_date
    ||
    ||
    || Out Parameters:
    ||
    ||
    || In Out Parameters:
    ||
    ||
    || Post Success:
    ||
    ||     returns currency code
    ||
    || Post Failure:
    ||     Raises Error
    ||
    || Access Status:
    ||     Public.
    ||
    ||=================================================================== */



   FUNCTION  get_currency_symbol(
     p_currency_code VARCHAR2 ,
     p_date          DATE ) RETURN  VARCHAR2
   IS
     CURSOR lc_currency_symbol IS
     SELECT CUR.SYMBOL
     FROM FND_CURRENCIES_VL CUR
     WHERE CUR.CURRENCY_CODE=p_currency_code
     AND p_date BETWEEN
      NVL(CUR.START_DATE_ACTIVE,p_date) AND
      NVL(CUR.END_DATE_ACTIVE,p_date+1);

     lv_symbol  fnd_currencies.symbol%type;

   BEGIN
     OPEN lc_currency_symbol ;
     FETCH lc_currency_symbol  into lv_symbol ;
     CLOSE lc_currency_symbol;

     return lv_symbol;

   EXCEPTION
   WHEN OTHERS THEN
     hr_utility.trace(' hr_salary2_web.get_currency_symbol: ' || SQLERRM );
   END get_currency_symbol ;




    /* ======================================================================
    || Function: get_precision
    ||----------------------------------------------------------------------
    || Description: Gets precisions for a given currency
    ||
    ||
    || Pre Conditions: a valid currency code
    ||
    ||
    || In Parameters: p_uom
    ||                p_currency_code
    ||                p_date
    ||
    ||
    || Out Parameters:
    ||
    ||
    || In Out Parameters:
    ||
    ||
    || Post Success:
    ||
    ||     returns precision
    ||
    || Post Failure:
    ||     Raises Error
    ||
    || Access Status:
    ||     Public.
    ||
    ||=================================================================== */



   FUNCTION  get_precision(
     p_uom           VARCHAR2 ,
     p_currency_code VARCHAR2 ,
     p_date          DATE ) RETURN  NUMBER
   IS
     CURSOR c_precision IS
     SELECT CUR.PRECISION
     FROM FND_CURRENCIES_VL CUR
     WHERE CUR.CURRENCY_CODE=p_currency_code
     AND p_date BETWEEN
      NVL(CUR.START_DATE_ACTIVE,p_date) AND
      NVL(CUR.END_DATE_ACTIVE,p_date+1);

     ln_precision NUMBER ;

   BEGIN
     IF p_uom = 'N'
     THEN
       ln_precision:= 5 ;
     ELSE
       OPEN c_precision ;
       FETCH c_precision into ln_precision ;
       CLOSE c_precision ;

     END IF ;
     return ln_precision ;
   EXCEPTION
   WHEN OTHERS THEN
     hr_utility.trace(' hr_salary2_web.get_precision: ' || SQLERRM );
   END get_precision ;
End ;

/
