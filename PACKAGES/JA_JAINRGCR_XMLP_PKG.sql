--------------------------------------------------------
--  DDL for Package JA_JAINRGCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_JAINRGCR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JAINRGCRS.pls 120.1 2007/12/25 16:28:21 dwkrishn noship $ */
  P_REGM_PRMY_REGN VARCHAR2(40);

  P_FROM_DATE DATE;

  P_TO_DATE DATE;

  CP_FROM_DATE VARCHAR2(40);

  CP_TO_DATE VARCHAR2(40);

  P_CONC_REQUEST_ID NUMBER;

  P_ORG_WHERE VARCHAR2(2000);

  P_REPORTING_ENTITY_ID NUMBER;

  P_REPORTING_LEVEL VARCHAR2(30);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION CF_CREDIT_TAKENFORMULA(CS_SERVICE_CREDIT IN NUMBER
                                 ,CS_EDU_CREDIT IN NUMBER) RETURN NUMBER;

  FUNCTION CF_CREDIT_UTILIZEDFORMULA RETURN NUMBER;

  FUNCTION CF_CLOSING_BALFORMULA(CF_OPENING_BAL IN NUMBER
                                ,CF_CREDIT_TAKEN IN NUMBER
                                ,CF_CREDIT_UTILIZED IN NUMBER) RETURN NUMBER;

  FUNCTION CF_OPENING_BALFORMULA RETURN NUMBER;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CF_SERVICE_TYPEFORMULA(SERVICE_TYPE_CODE IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_VALUEFORMULA(INVOICE_ID IN NUMBER
                          ,SOURCE_TYPE IN VARCHAR2
                          ,ST_RATE IN NUMBER
                          ,ST IN NUMBER
                          ,VALUE IN NUMBER) RETURN NUMBER;

  FUNCTION CF_DESCRIPTIONFORMULA(SRC_DOC_ID IN NUMBER
                                ,ITEM_ID IN NUMBER
                                ,SOURCE_TYPE IN VARCHAR2) RETURN CHAR;

  LV_TAX_TYPE_SERVICE CONSTANT VARCHAR2(15) DEFAULT 'Service';

  LV_TAX_TYPE_SERVICE_EDU_CESS CONSTANT VARCHAR2(30) DEFAULT 'SERVICE_EDUCATION_CESS';

  LV_TAX_TYPE_SH_SER_EDU_CESS CONSTANT VARCHAR2(30) DEFAULT 'SERVICE_SH_EDU_CESS';

  LV_SERVICE_REGIME CONSTANT VARCHAR2(15) DEFAULT 'SERVICE';

  LV_SERVICE_SRC_DISTRIBUTE_OUT CONSTANT VARCHAR2(30) DEFAULT 'SERVICE_DISTRIBUTE_OUT';

  LV_SERVICE_SRC_DISTRIBUTE_IN CONSTANT VARCHAR2(30) DEFAULT 'SERVICE_DISTRIBUTE_IN';

  LV_RECOVERY CONSTANT VARCHAR2(20) DEFAULT 'RECOVERY';

  LV_LIABILITY CONSTANT VARCHAR2(20) DEFAULT 'LIABILITY';

  LV_ADJUST_RECOVERY CONSTANT VARCHAR2(20) DEFAULT 'ADJUSTMENT-RECOVERY';

  LV_ADJUST_LIABILITY CONSTANT VARCHAR2(20) DEFAULT 'ADJUSTMENT-LIABILITY';

  LV_OTH_REG_TYPE CONSTANT VARCHAR2(30) DEFAULT 'OTHERS';

  LV_PRIM_ATT_TYPE_CODE CONSTANT VARCHAR2(30) DEFAULT 'PRIMARY';

  LV_SERVICE_ATT_CODE CONSTANT VARCHAR2(30) DEFAULT 'SERVICE_TAX_REGISTRATION_NO';

END JA_JAINRGCR_XMLP_PKG;



/