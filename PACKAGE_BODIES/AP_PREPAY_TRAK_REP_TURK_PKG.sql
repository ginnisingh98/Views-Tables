--------------------------------------------------------
--  DDL for Package Body AP_PREPAY_TRAK_REP_TURK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PREPAY_TRAK_REP_TURK_PKG" AS
-- $Header: APPPTRPB.pls 120.2.12000000.1 2007/10/24 18:07:08 sgudupat noship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)     Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
-- APPPTRPB.pls
--
-- DESCRIPTION
--  This script creates the package body of APPPTRPB.pls.
--  This package is used to generate Prepayment Tracking Report for Turkey.
--
-- USAGE
--   To install        How to Install
--   To execute        How to Execute
--
-- DEPENDENCIES
--   None.
--
--
-- LAST UPDATE DATE   26-JAN-2007
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)         DESCRIPTION
-- ------- ----------- ---------------   ------------------------------------
-- 1.0    26-JAN-2007 Pgollu M Creation
--
--****************************************************************************************
FUNCTION beforeReport  RETURN BOOLEAN IS
BEGIN
  gd_date_from := TO_DATE(P_INVOICE_FROM,'YYYY/MM/DD HH24:MI:SS');
  gd_date_to := TO_DATE(P_INVOICE_TO,'YYYY/MM/DD HH24:MI:SS');
  IF P_INVOICE_FROM IS NOT NULL AND P_INVOICE_TO IS NOT NULL THEN
	c_lex_invoice_date :=' AND ai.invoice_date
			      BETWEEN TO_DATE(:P_INVOICE_FROM,''YYYY/MM/DD HH24:MI:SS'')
				  AND TO_DATE(:P_INVOICE_TO,''YYYY/MM/DD HH24:MI:SS'')';

	--c_lex_invoice_date :=' AND ai.gl_date BETWEEN'||''''||gd_date_from||''''||' AND '||''''||gd_date_to||'''';
  ELSE
    c_lex_invoice_date := ' AND 1 = 1';
  END IF;

IF P_PREPAY_STATUS IS NULL THEN
       c_lex_prepay_status := 'AND 1=1';
  ELSE
       c_lex_prepay_status := 'AND ALC.lookup_code=:P_PREPAY_STATUS';
  END IF;

  IF P_SUPPLIER_FROM IS NOT NULL AND P_SUPPLIER_TO IS NOT NULL THEN
	IF UPPER(P_SUPPLIER_FROM) <= UPPER(P_SUPPLIER_TO) THEN
    c_lex_supplier := ' AND UPPER(POV.vendor_name) BETWEEN UPPER(:P_SUPPLIER_FROM) AND UPPER(:P_SUPPLIER_TO)';
	ELSE
	c_lex_supplier := ' AND UPPER(POV.vendor_name) BETWEEN UPPER(:P_SUPPLIER_TO) AND UPPER(:P_SUPPLIER_FROM)';
	END IF;
  ELSE
    c_lex_supplier := ' AND 1 = 1';
  END IF;

  IF P_CURRENCY = 'ANY' THEN
	c_lex_currency := ' AND 1 = 1';
  ELSE
	--c_lex_currency := ' AND AI.INVOICE_CURRENCY_CODE = '''||P_CURRENCY||'''';
	c_lex_currency := ' AND AI.INVOICE_CURRENCY_CODE = :P_CURRENCY';
  END IF;

  IF P_VENDOR_TYPE IS NOT NULL THEN
    --c_lex_vendor_type := ' AND POV.VENDOR_TYPE_LOOKUP_CODE = '''||P_VENDOR_TYPE||'''';
	c_lex_vendor_type := ' AND POV.VENDOR_TYPE_LOOKUP_CODE = :P_VENDOR_TYPE';
  ELSE
    c_lex_vendor_type := ' AND 1 = 1';
  END IF;

  IF P_ORG_ID IS NOT NULL THEN
      gc_org_where := ' AND ai.org_id = :P_ORG_ID ';
  ELSE
      gc_org_where := ' AND 1 = 1';
  END IF;

  RETURN TRUE;
END beforeReport;

FUNCTION date_close(prepay_inv_num IN VARCHAR2
                   ,prepay_line_number_param IN NUMBER
		   ,prepay_amount_remaining IN NUMBER) RETURN DATE IS
	lc_closing_date DATE;
BEGIN
  IF prepay_amount_remaining =0  THEN
    SELECT MAX(AVPFPV.accounting_date)
    INTO   lc_closing_date
    FROM   ap_view_prepays_fr_prepay_v AVPFPV
    WHERE  AVPFPV.prepay_id= prepay_inv_num
    AND    AVPFPV.prepay_line_number= prepay_line_number_param ;
  ELSIF prepay_amount_remaining IS NULL OR prepay_amount_remaining>0 THEN
    RETURN(NULL);
  END IF;
  RETURN(lc_closing_date);
END date_close;

END AP_PREPAY_TRAK_REP_TURK_PKG;

/
