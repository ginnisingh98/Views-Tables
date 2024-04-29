--------------------------------------------------------
--  DDL for Package INV_INVARHMA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INVARHMA_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: INVARHMAS.pls 120.2 2008/01/08 06:20:05 dwkrishn noship $ */
  P_CONC_REQUEST_ID NUMBER := 0;

  P_ORG_ID NUMBER;

  P_HEADERID NUMBER;

  P_FROMDATE DATE;

  P_TODATE DATE;

  LP_FROMDATE DATE;

  LP_TODATE DATE;

  P_CBO_FLAG NUMBER;

  P_TRACE_FLAG NUMBER;

  FUNCTION C_FORMATTEDCURRENCYCODEFORMULA(CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION F_OUTTOLERANCEFLAGFORMULA(SERIAL_DETAIL IN NUMBER
                                    ,SERIAL_NUMBER IN VARCHAR2
                                    ,ADJ_QUANTITY IN NUMBER
                                    ,SYS_QUANTITY IN NUMBER
                                    ,NEG_TOL IN NUMBER
                                    ,POS_TOL IN NUMBER) RETURN NUMBER;

  FUNCTION F_ACCURACYPERCENTFORMULA(F_TOTALENTRIES IN NUMBER
                                   ,C_TOTALOUTTOLERANCE IN NUMBER) RETURN NUMBER;

  FUNCTION FS_ACCURACYPERCENTFORMULA(SS_TOTALENTRIES IN NUMBER
                                    ,SS_TOTALOUTTOLERANCE IN NUMBER) RETURN NUMBER;

  FUNCTION SR_ACCURACYPERCENTFORMULA(SR_TOTALENTRIES IN NUMBER
                                    ,SR_TOTALOUTTOLERANCE IN NUMBER) RETURN NUMBER;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION C_SERIAL_YES_NOFORMULA(CNT_SL_NO IN NUMBER) RETURN VARCHAR2;

  FUNCTION BEFOREPFORM RETURN BOOLEAN;

END INV_INVARHMA_XMLP_PKG;



/