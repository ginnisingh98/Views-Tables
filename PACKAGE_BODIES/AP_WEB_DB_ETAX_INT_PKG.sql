--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_ETAX_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_ETAX_INT_PKG" AS
/* $Header: apwdbtxb.pls 120.1 2005/06/03 22:25:25 qle noship $ */

-------------------------------------------------------------------
FUNCTION IsTaxCodeWebEnabled(
	P_ExpTypeDefaultTaxCode IN  taxClassification) RETURN BOOLEAN
IS
  l_taxCode  taxClassification;
  l_lt       fnd_lookups.lookup_type%type;
-------------------------------------------------------------------
BEGIN
  l_lt := 'ZX_WEB_EXP_TAX_CLASSIFICATIONS';

    select lookup_code
    into l_taxCode
    from fnd_lookups
    WHERE lookup_type = l_lt and
          lookup_code = P_ExpTypeDefaultTaxCode;

    RETURN TRUE;

EXCEPTION

	WHEN TOO_MANY_ROWS THEN
                RETURN TRUE;

	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'IsTaxCodeWebEnabled' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END IsTaxCodeWebEnabled;

END AP_WEB_DB_ETAX_INT_PKG;

/
