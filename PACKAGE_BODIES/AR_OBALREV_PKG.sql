--------------------------------------------------------
--  DDL for Package Body AR_OBALREV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_OBALREV_PKG" AS
-- $Header: AROBRRPB.pls 120.8 2007/12/27 11:23:42 sgudupat noship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)     Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
-- AROBRRPB.pls
--
-- DESCRIPTION
--  This script creates the package specification of ar_obalrev_pkg.
--  This package is used to generate AR Open balance Revaluation Report for Slovakia.
--
-- USAGE
--   To install            How to Install
--   To execute         How to Execute
--
--FUNCTION                                                 DESCRIPTION
--  beforereport        It is a public function used to intialize global variables
--                                which will be used to build the queries in the Data Template Dynamically
--
--
-- exch_rate_calc    It is a public function which returns exchange rate, by taking P_AS_OF_DATE,
--                                p_exchange_rate_type,gc_func_currency , and currency as parameter
--
--
-- amtduefilter         It is a public function which returns boolean value
--    which will be used to fetch the data in Data Template Dynamically
--
-- DEPENDENCIES
--   None.
--
--
-- LAST UPDATE DATE   13-MAR-2007
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION   DATE                      AUTHOR(S)                 DESCRIPTION
--     -------      -----------                 -------------------           ---------------------------
--       1.0    11-MAR-2007          Mallikarjun Gupta         Creation
---     1.1      24-DEC-2007         Ravi Kiran G                  Modified to pick CM Details
--****************************************************************************************

FUNCTION beforereport RETURN BOOLEAN IS
lc_exchange_rate_type varchar2(2000);
EX_EXCHANGE_RATE_TYPE EXCEPTION;
BEGIN
 IF P_CUSTOMER IS NOT NULL
 THEN
  SELECT hp.party_name
    INTO gc_customer_name
    FROM hz_parties hp
        ,hz_cust_accounts hca
   WHERE hca.party_id = hp.party_id
     AND hca.account_number = P_CUSTOMER;
  ELSE
       gc_customer_name:=NULL;
  END IF;

 BEGIN
  SELECT GL1.ledger_id
        ,GL1.currency_code
    INTO gc_ledger_id
        ,gc_func_currency
    FROM gl_ledgers                  GL1
        ,gl_access_set_norm_assign   GASNA
   WHERE GASNA.access_set_id     = FND_PROFILE.VALUE('GL_ACCESS_SET_ID')
     AND GL1.ledger_id          = GASNA.ledger_id
     AND GL1.ledger_category_code = 'PRIMARY';

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'1)gc_func_currency = "' || gc_func_currency || '"');
  END;

  BEGIN
   SELECT name
   INTO gc_ou_name
   FROM hr_operating_units
   WHERE organization_id = p_org_id;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    gc_ou_name := NULL;
  END;

 BEGIN
   SELECT gdct.user_conversion_type
    INTO gc_exchange_rate_type
    FROM gl_daily_conversion_types  gdct
   WHERE gdct.conversion_type     = P_EXCHANGE_RATE_TYPE;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'2)gc_exchange_rate_type = "' || gc_exchange_rate_type || '"');
 END;

--***********************************************************************
 ----build the where clause for gc_incl_domestic_inv_where
--***********************************************************************
 IF p_incl_domestic_inv       = 'N' THEN
  gc_incl_domestic_inv_where := 'acr.currency_code <> '''||gc_func_currency||'''';
 ELSE
  gc_incl_domestic_inv_where := '1=1';
 END IF;

 IF p_incl_domestic_inv       = 'N' THEN
    gc_incl_domestic_inv_where1 := 'RCTA.invoice_currency_code <> '''||gc_func_currency||'''';
 ELSE
    gc_incl_domestic_inv_where1 := '1=1';
 END IF;

--***********************************************************************
 ----build the where clause for gc_currency_where
--***********************************************************************
 IF p_currency IS NOT NULL THEN
     gc_currency_where := 'acr.currency_code = :p_currency';
 ELSE
    IF P_EXCHANGE_RATE_TYPE = 'User' THEN
            fnd_message.SET_name('AR', 'AR_EXCHANGE_RATE_TYPE');
            lc_exchange_rate_type := FND_MESSAGE.GET;
            RAISE EX_EXCHANGE_RATE_TYPE;
    END IF;
    gc_currency_where := '1=1';

 END IF;

 IF p_currency IS NOT NULL THEN
         gc_currency_where1 := 'RCTA.invoice_currency_code = :p_currency';
 ELSE
    IF P_EXCHANGE_RATE_TYPE = 'User' THEN
            fnd_message.SET_name('AR', 'AR_EXCHANGE_RATE_TYPE');
            lc_exchange_rate_type := FND_MESSAGE.GET;
            RAISE EX_EXCHANGE_RATE_TYPE;
    END IF;
        gc_currency_where1 := '1=1';
 END IF;

--************************************************************************
 ----build the where clause for gc_customer_where
--***********************************************************************
 IF p_customer IS NOT NULL THEN
     gc_customer_where := 'HCA.account_number = :P_CUSTOMER';
     gc_customer_where1 := 'HCA.account_number = :P_CUSTOMER';
 ELSE
     gc_customer_where := '1=1';
     gc_customer_where1 := '1=1';
 END IF;

--****************************************************************************
      ----build where clause for gc_trx_date_where
--****************************************************************************

    --gd_date_to :=TO_DATE(TO_CHAR(TO_DATE(P_AS_OF_DATE,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY'));
 gd_date_to1:=fnd_date.canonical_to_date(P_AS_OF_DATE);
 gc_trx_date_where := 'ara.gl_date<='||''''||gd_date_to1||'''';
 gc_trx_date_where1 := 'RCTA.trx_date<='||''''||gd_date_to1||'''';
 gd_date_to := ''''||gd_date_to1||'''';
--****************************************************************************
    --build where clause for gc_ou_where
--****************************************************************************

    IF p_org_id IS NULL THEN
      gc_ou_where :='1=1';
      gc_ou_where1 :='1=1';
    ELSE
      gc_ou_where :='acr.org_id=:p_org_id';
      gc_ou_where1 :='rcta.org_id=:p_org_id';
    END IF;

RETURN TRUE;
EXCEPTION
WHEN EX_EXCHANGE_RATE_TYPE THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,lc_exchange_rate_type);
         RETURN FALSE;
END beforereport;


--*************************************************************************
   -----function to calculate exchange rate for a given currency
--*************************************************************************
FUNCTION get_rate(p_currency IN VARCHAR2) RETURN NUMBER AS
  ln_exch_rate NUMBER;
  lc_exchange_rate_type varchar2(2000);
BEGIN
  IF p_currency <> gc_func_currency THEN
  ln_exch_rate := gl_currency_api.get_rate_sql(p_currency
                                             ,gc_func_currency
                                             ,gd_date_to1
                                             ,p_exchange_rate_type);
    IF ln_exch_rate = -1 THEN

      fnd_message.SET_name('AR', 'AR_EXCHANGE_RATE');
      fnd_message.SET_TOKEN('P_EXCHANGE_RATE_TYPE',P_EXCHANGE_RATE_TYPE);
      fnd_message.SET_TOKEN('CURRENCY',P_CURRENCY);
      fnd_message.SET_TOKEN('P_AS_OF_DATE',gd_date_to1);
      lc_exchange_rate_type := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.LOG,lc_exchange_rate_type);
      raise_application_error (-20101,lc_exchange_rate_type);
      ln_exch_rate:=NULL;
    ELSIF ln_exch_rate = -2 THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid Currency exception raised in GL_CURRENCY_API');
    ln_exch_rate:=NULL;
    END IF;
  ELSE
     ln_exch_rate:=1;
  END IF;
   RETURN (ln_exch_rate);
END get_rate;

FUNCTION amtduefilter   (p_amt_due   IN   NUMBER) RETURN BOOLEAN AS
BEGIN
  IF p_amt_due = 0 OR p_amt_due IS NULL THEN
   RETURN (FALSE);
  ELSE
   RETURN (TRUE);
  END IF;
END;

FUNCTION test(inv_num VARCHAR2 , amount NUMBER) RETURN NUMBER IS
var1 VARCHAR2(100) := 0;
BEGIN
var1 := inv_num;
IF var1 = var2 THEN
      var2:=var1;
      RETURN (0);
ELSE
    var2 := var1;
    RETURN(AMOUNT);
END IF;
END test;

END ar_obalrev_pkg;

/
