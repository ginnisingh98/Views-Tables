--------------------------------------------------------
--  DDL for Package Body ISC_EDW_O2C_DRILL_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_EDW_O2C_DRILL_P" AS
/* $Header: ISCO2CDB.pls 115.8 2002/12/13 21:11:45 kxliu ship $ */

PROCEDURE drill_across_wk (pParameter1 IN NUMBER)
IS
BEGIN
   IF pParameter1 = 1 THEN
      bis_parameter_validation.drillacross(pURLString => 'pFunctionName=ISC_OPI_TOP_ORDERS_WK',
                                            pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                            pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                                            pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID),
                                            pFunctionName=> 'ISC_OPI_IND_CROSS_TAB'
                                           );
    ELSIF pParameter1 = 2 THEN
     bis_parameter_validation.drillacross(pURLString => 'pFunctionName=ISC_OPI_BOOKED_ORD_SUM_WK&VIEW_BY=EDW_TRD_PARTNER_M+EDW_TPRT_TRADE_PARTNER',
                                          pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                          pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                                          pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID),
                                          pFunctionName=> 'ISC_OPI_IND_CROSS_TAB'
                                          );
    ELSIF pParameter1 = 3 THEN
     bis_parameter_validation.drillacross(pURLString => 'pFunctionName=ISC_OPI_BOOKED_ORD_SUM_WK&VIEW_BY=EDW_TRD_PARTNER_M+EDW_TPRT_TRADE_PARTNER',
                                          pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                          pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                                          pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID),
                                          pFunctionName=> 'ISC_OPI_IND_CROSS_TAB'
                                          );
   ELSIF pParameter1 = 4 THEN
     bis_parameter_validation.drillacross(pURLString => 'pFunctionName=FII_AR_INV_CUST_L7D&VIEW_BY=EDW_TRD_PARTNER_M+EDW_TPRT_TRADE_PARTNER',
                                          pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                          pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                                          pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID),
                                          pFunctionName=> 'ISC_OPI_IND_CROSS_TAB'
                                          );
   ELSIF pParameter1 = 5 THEN
      bis_parameter_validation.drillacross(pURLString => 'pFunctionName=FII_AR_REV_CUST_L7D&VIEW_BY=EDW_TRD_PARTNER_M+EDW_TPRT_TRADE_PARTNER',
                                            pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                            pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                                            pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID),
                                            pFunctionName=> 'ISC_OPI_IND_CROSS_TAB'
                                           );
   ELSIF pParameter1 = 6 THEN
      bis_parameter_validation.drillacross(pURLString => 'pFunctionName=FII_AR_CASH_CUST_L7D&VIEW_BY=EDW_TRD_PARTNER_M+EDW_TPRT_TRADE_PARTNER',
                                            pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                            pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                                            pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID),
                                            pFunctionName=> 'ISC_OPI_IND_CROSS_TAB'
                                           );
   END IF;
END drill_across_wk;

PROCEDURE drill_across_qtd (pParameter1 IN NUMBER)
IS
BEGIN
   IF pParameter1 = 1 THEN
      bis_parameter_validation.drillacross(pURLString => 'pFunctionName=ISC_OPI_TOP_ORDERS_QTD',
                                            pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                            pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                                            pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID),
                                            pFunctionName=> 'ISC_OPI_IND_CROSS_TAB'
                                           );
   ELSIF pParameter1 = 2 THEN
     bis_parameter_validation.drillacross(pURLString => 'pFunctionName=ISC_OPI_BOOKED_ORD_SUM_QTD&VIEW_BY=EDW_TRD_PARTNER_M+EDW_TPRT_TRADE_PARTNER',
                                          pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                          pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                                          pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID),
                                          pFunctionName=> 'ISC_OPI_IND_CROSS_TAB'
                                          );
    ELSIF pParameter1 = 3 THEN
     bis_parameter_validation.drillacross(pURLString => 'pFunctionName=ISC_OPI_BOOKED_ORD_SUM_QTD&VIEW_BY=EDW_TRD_PARTNER_M+EDW_TPRT_TRADE_PARTNER',
                                          pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                          pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                                          pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID),
                                          pFunctionName=> 'ISC_OPI_IND_CROSS_TAB'
                                          );
   ELSIF pParameter1 = 4 THEN
     bis_parameter_validation.drillacross(pURLString => 'pFunctionName=FII_AR_INV_CUST&VIEW_BY=EDW_TRD_PARTNER_M+EDW_TPRT_TRADE_PARTNER',
                                          pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                          pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                                          pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID),
                                          pFunctionName=> 'ISC_OPI_IND_CROSS_TAB'
                                          );
   ELSIF pParameter1 = 5 THEN
      bis_parameter_validation.drillacross(pURLString => 'pFunctionName=FII_AR_REV_CUST&VIEW_BY=EDW_TRD_PARTNER_M+EDW_TPRT_TRADE_PARTNER',
                                            pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                            pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                                            pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID),
                                            pFunctionName=> 'ISC_OPI_IND_CROSS_TAB'
                                           );
   ELSIF pParameter1 = 6 THEN
      bis_parameter_validation.drillacross(pURLString => 'pFunctionName=FII_AR_CASH_CUST&VIEW_BY=EDW_TRD_PARTNER_M+EDW_TPRT_TRADE_PARTNER',
                                            pUserId  => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                                            pSessionId => icx_sec.getID(icx_sec.PV_SESSION_ID),
                                            pRespId => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID),
                                            pFunctionName=> 'ISC_OPI_IND_CROSS_TAB'
                                           );
   END IF;
END drill_across_qtd;

END isc_edw_o2c_drill_p;

/
