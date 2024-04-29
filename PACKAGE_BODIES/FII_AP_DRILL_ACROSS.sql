--------------------------------------------------------
--  DDL for Package Body FII_AP_DRILL_ACROSS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_DRILL_ACROSS" AS
/* $Header: FIIAPS5B.pls 120.2 2005/08/26 13:55:45 vkazhipu noship $ */

PROCEDURE drill_across(pSource IN varchar2,  pOperatingUnit IN varchar2,
                       pSupplier IN varchar2, pCurrency IN varchar2,
                       pAsOfDateValue IN varchar2,pPeriod IN varchar2,pParamIds IN varchar2) IS
p1   varchar2(100);
p2    varchar2(100);
pS    varchar2(100);
pSu    varchar2(500);
pOU    varchar2(500);
pD   varchar2(100);
pC   varchar2(100);
pP   varchar2(100);


BEGIN

IF pSource = 'FII_AP_HOLD_TREND'  THEN

p1 := 'FII_AP_INV_ON_HOLD_DETAIL';

p2 := 'FII_AP_INV_ON_HOLD_DETAIL';

pS := pSource;

pSu := pSupplier;

pOU := pOperatingUnit;

pd := pAsOfDateValue;

pC := pCurrency;
bisviewer_pub.showreport(pURLString => 'pFunctionName='||p1||'&pParameterDisplayOnly=Y&ORGANIZATION+FII_OPERATING_UNITS='||pOU||'&SUPPLIER+POA_SUPPLIERS='||pSu||'&CURRENCY+FII_CURRENCIES='||pC||'&FII_REPORT_SOURCE='||p2||'&AS_OF_DATE='||pD||
													 '&pParamIds=Y',
                           pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                           pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                           pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID));
/* addding the logic below to implement drill in Electronic Invoice trend report*/


ELSIF pSource = 'FII_AP_E_INV_ENT_DTL' THEN

p1 := 'FII_AP_E_INV_ENT_DTL';

p2 := 'FII_AP_E_INV_ENT_DTL';

pS := pSource;

pSu := pSupplier;

pOU := pOperatingUnit;

pd := pAsOfDateValue;

pC := pCurrency;


CASE pPeriod
when 'FII_TIME_ENT_PERIOD' THEN
pP := '&FII_TIME_ENT_PERIOD=TIME+FII_TIME_ENT_PERIOD';

when 'FII_TIME_ENT_YEAR' THEN
pP := '&FII_TIME_ENT_YEAR=TIME+FII_TIME_ENT_YEAR';

when 'FII_TIME_ENT_QTR'  THEN
pP := '&FII_TIME_ENT_QTR=TIME+FII_TIME_ENT_QTR';

when 'FII_TIME_WEEK'  THEN
pP := '&FII_TIME_WEEK=TIME+FII_TIME_WEEK';

END CASE;


bisviewer_pub.showreport(pURLString => 'pFunctionName='||p1||'&pParameterDisplayOnly=Y&ORGANIZATION+FII_OPERATING_UNITS='||pOU||'&SUPPLIER+POA_SUPPLIERS='||pSu||'&CURRENCY+FII_CURRENCIES='||pC||pP||'&FII_REPORT_SOURCE='||p2||'&AS_OF_DATE='||pD||'
                            &pParamIds=Y',
                           	   pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                           pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                           pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID));

END IF;

END drill_across;

END FII_AP_DRILL_ACROSS;

/
