--------------------------------------------------------
--  DDL for Package Body AP_CHECK_PAYMT_SUPP_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CHECK_PAYMT_SUPP_RPT_PKG" 
-- $Header: AP_CHECKPAYMTSUPPB.pls 120.2.12000000.1 2007/10/24 18:04:18 sgudupat noship $
--*************************************************************************
-- Copyright (c)  2000    Oracle                 Product Development
-- All rights reserved
--*************************************************************************
--
-- HEADER
--  Source control header
--
-- PROGRAM NAME
--   AP_CHECK_PAYMT_SUPP_RPT_PKG
--
-- DESCRIPTION
-- This script creates the package Body  of AP_CHECK_PAYMT_SUPP_RPT_PKG
-- This package is used to report on AP Check payments to Suppliers.
--
-- USAGE
--   To install        sqlplus <apps_user>/<apps_pwd> @AP_CHECKPAYMTSUPPB.pls
--   To execute        sqlplus <apps_user>/<apps_pwd> AP_CHECK_PAYMT_SUPP_RPT_PKG.
--
-- PROGRAM LIST        DESCRIPTION
-- beforereport        This function is used to dynamically get the
--                     WHERE clause in SELECT statement.
-- DEPENDENCIES
-- None
--
-- CALLED BY
-- AP Check Payments to Suppliers Report.
--
-- LAST UPDATE DATE    08-Feb-2007
-- Date the program has been modified for the last time.
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)       DESCRIPTION
-- ------- ----------- --------------- --------------------------------------
-- Draft1A 08-Feb-2007 Rakesh Pulla    Initial Creation
-- Draft1B 22-Jun-2007 Rakesh Pulla    Incorporated the review comments of the Product team.
-- Draft1C 12-Jul-2007 Rakesh Pulla    Incorporated the product team review comments.
-- Draft1D 12-Jul-2007 Rakesh Pulla    Replaced CHCK with CHECK as suggested by the product team.
--************************************************************************
AS

FUNCTION beforereport RETURN BOOLEAN
IS
lc_attribute      VARCHAR2(50);
lc_attribute_col  VARCHAR2(80);
BEGIN -- Begining of the Function beforereport

  BEGIN
      SELECT  FDU.application_column_name attr_column
	  INTO    lc_attribute
      FROM    fnd_descr_flex_col_usage_vl FDU
             ,fnd_application FA
      WHERE   FDU.descriptive_flexfield_name    = 'AP_CHECKS'
      AND     FDU.descriptive_flex_context_code = 'Global Data Elements'
      AND     FDU.application_id                = '200'
      AND     FA.application_short_name         = 'SQLAP'
      AND     FDU.end_user_column_name          = 'Cek_No';

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
	    NULL;
  END;

  IF lc_attribute IS NOT NULL THEN
     lc_attribute_col:= 'APC.'||lc_attribute;
  ELSE
     lc_attribute_col:= NULL;
  END IF;

  GC_ATTRIBUTE_COL:= lc_attribute_col;


IF (P_VNDR_NUMBER_FROM IS NOT NULL) AND (P_VNDR_NUMBER_TO IS NOT NULL) THEN
    GC_WHERE:= GC_WHERE||' AND DECODE(APC.vendor_id,'''',DECODE(APC.party_id,''''
	            ,''******************************'',NULL), APS.segment1)
                BETWEEN :P_VNDR_NUMBER_FROM AND :P_VNDR_NUMBER_TO';
ELSIF (P_VNDR_NUMBER_FROM IS NULL) AND (P_VNDR_NUMBER_TO IS NOT NULL) THEN
    GC_WHERE:= GC_WHERE||' AND DECODE(APC.vendor_id,'''',DECODE(APC.party_id,''''
	           ,''******************************'',NULL), APS.segment1)
			    <= :P_VNDR_NUMBER_TO';
ELSIF (P_VNDR_NUMBER_FROM IS NOT NULL) AND (P_VNDR_NUMBER_TO IS NULL) THEN
    GC_WHERE:= GC_WHERE||' AND DECODE(APC.vendor_id,'''',DECODE(APC.party_id,''''
	           ,''******************************'',NULL), APS.segment1)
			   >= :P_VNDR_NUMBER_FROM';
END IF;

IF (P_CHECK_DATE_FROM IS NOT NULL) AND (P_CHECK_DATE_TO IS NOT NULL) THEN
    GC_WHERE:= GC_WHERE||' AND APC.check_date
    BETWEEN TO_DATE((TO_CHAR(:P_CHECK_DATE_FROM,''DD-MON-YYYY'')||''00-00-00'')
	,''DD-MON-YYYY HH24:MI:SS'') AND TO_DATE((TO_CHAR(NVL(:P_CHECK_DATE_TO,SYSDATE)
	,''DD-MON-YYYY'')||''23:59:59''),''DD-MON-YYYY HH24:MI:SS'')';
ELSIF (P_CHECK_DATE_FROM IS NULL) AND (P_CHECK_DATE_TO IS NOT NULL) THEN
    GC_WHERE:= GC_WHERE||' AND APC.check_date <=
	TO_DATE((TO_CHAR(:P_CHECK_DATE_TO,''DD-MON-YYYY'')||''23:59:59'')
	,''DD-MON-YYYY HH24:MI:SS'')';
ELSIF (P_CHECK_DATE_FROM IS NOT NULL) AND (P_CHECK_DATE_TO IS NULL) THEN
    GC_WHERE:= GC_WHERE||' AND APC.check_date >=
	TO_DATE((TO_CHAR(:P_CHECK_DATE_FROM,''DD-MON-YYYY'')||''00-00-00'')
	,''DD-MON-YYYY HH24:MI:SS'')';
END IF;

IF (P_CHECK_DUE_DATE_FROM IS NOT NULL) AND (P_CHECK_DUE_DATE_TO IS NOT NULL) THEN
    GC_WHERE:= GC_WHERE||' AND APC.future_pay_due_date
    BETWEEN TO_DATE((TO_CHAR(:P_CHECK_DUE_DATE_FROM,''DD-MON-YYYY'')||''00-00-00''),''DD-MON-YYYY HH24:MI:SS'')
	  AND TO_DATE((TO_CHAR(NVL(:P_CHECK_DUE_DATE_TO,SYSDATE),''DD-MON-YYYY'')||''23:59:59'')
	  ,''DD-MON-YYYY HH24:MI:SS'')';
ELSIF (P_CHECK_DUE_DATE_FROM IS NULL) AND (P_CHECK_DUE_DATE_TO IS NOT NULL) THEN
    GC_WHERE:= GC_WHERE||' AND APC.future_pay_due_date <=
	TO_DATE((TO_CHAR(:P_CHECK_DUE_DATE_TO,''DD-MON-YYYY'')||''23:59:59'')
	,''DD-MON-YYYY HH24:MI:SS'')';
ELSIF (P_CHECK_DUE_DATE_FROM IS NOT NULL) AND (P_CHECK_DUE_DATE_TO IS NULL) THEN
    GC_WHERE:= GC_WHERE||' AND APC.future_pay_due_date >=
	TO_DATE((TO_CHAR(:P_CHECK_DUE_DATE_FROM,''DD-MON-YYYY'')||''00-00-00'')
	,''DD-MON-YYYY HH24:MI:SS'')';
END IF;

IF (P_CURRENCY IS NOT NULL) THEN
    GC_WHERE:= GC_WHERE||' AND APC.currency_code= :P_CURRENCY';
END IF;

IF (P_CHECK_STAT IS NOT NULL) THEN
    GC_WHERE:= GC_WHERE||' AND APLC.lookup_code= :P_CHECK_STAT';
ELSE
    GC_WHERE:= GC_WHERE||' AND APC.status_lookup_code <> ''VOIDED''';
END IF;

RETURN(TRUE);

END beforereport; --End of the beforereport.

END AP_CHECK_PAYMT_SUPP_RPT_PKG ;

/
