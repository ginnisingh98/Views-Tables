--------------------------------------------------------
--  DDL for Package OKS_OKSSUMRP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_OKSSUMRP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: OKSSUMRPS.pls 120.2 2007/12/25 08:02:30 nchinnam noship $ */
  P_REP_NAME_WHERE VARCHAR2(1000) := ' ';

  P_CUSTOMER_NAME_WHERE VARCHAR2(1000) := ' ';

  P_FROM_DATE DATE;

  P_TO_DATE DATE;

  P_CUSTOMER_NAME NUMBER;

  P_REP_NAME NUMBER;

  P_OPERATING_UNIT NUMBER;

  P_ORG_ID_WHERE VARCHAR2(1000);

  P_CUSTOMER_NUMBER NUMBER;

  P_CUSTOMER_NUMBER_WHERE VARCHAR2(1000) := ' ';

  P_CURRENCY_CODE_WHERE VARCHAR2(1000) := ' ';

  P_CURRENCY_CODE VARCHAR2(50);

  P_CONTRACT_GROUP NUMBER;

  P_CONTRACT_GROUP_WHERE VARCHAR2(2000) := ' ';

  P_START_DATE_WHERE VARCHAR2(2000) := ' ';

  P_CONC_REQUEST_ID NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION CF_1FORMULA(REP_NAME1 IN VARCHAR2
                      ,ORG_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_LAST_INTRERACTIONFORMULA(CONTRACT_ID IN NUMBER) RETURN CHAR;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

END OKS_OKSSUMRP_XMLP_PKG;


/
