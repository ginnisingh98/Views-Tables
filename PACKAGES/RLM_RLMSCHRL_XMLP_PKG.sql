--------------------------------------------------------
--  DDL for Package RLM_RLMSCHRL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_RLMSCHRL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RLMSCHRLS.pls 120.0 2008/01/25 09:44:08 krreddy noship $ */
  P_CUSTOMER NUMBER;

  P_SCHEDULE_TYPE VARCHAR2(32767);

  P_SCHEDULE_NUM VARCHAR2(40);

  P_SHIP_FROM NUMBER;

  P_SHIP_TO VARCHAR2(32767);

  P_SCHEDULE_PURPOSE VARCHAR2(32767);

  P_HORIZON_START_DATE VARCHAR2(30);

  P_HORIZON_END_DATE VARCHAR2(30);

  P_ISSUE_DATE_FROM VARCHAR2(30);

  P_ISSUE_DATE_TO VARCHAR2(30);

  P_TP_FROM VARCHAR2(32767);

  P_TP_TO VARCHAR2(32767);

  P_TP_LOC_FROM VARCHAR2(32767);

  P_TP_LOC_TO VARCHAR2(32767);

  P_PROCESS_DATE_FROM VARCHAR2(30);

  P_PROCESS_DATE_TO VARCHAR2(30);

  P_WHERE_CLAUSE VARCHAR2(1500);

  P_PROCESS_STATUS NUMBER;

  P_SCHEDULE_SOURCE VARCHAR2(32767);

  P_DETAIL_TYPE VARCHAR2(30);

  P_TITLE VARCHAR2(50);

  P_SHIPPED_REC_CUM VARCHAR2(100);

  P_AUTH VARCHAR2(30);

  P_OTHER VARCHAR2(32767);

  P_REF_NUM VARCHAR2(35);

  P_ORG_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  CP_CUSTOMER VARCHAR2(20);

  CP_SCHEDULE_REF_NUM VARCHAR2(35);

  CP_SHIP_FROM_ORG VARCHAR2(20);

  CP_SHIP_TO VARCHAR2(20);

  CP_SCHEDULE_TYPE VARCHAR2(30);

  CP_SCHEDULE_PURPOSE VARCHAR2(30);

  CP_SCHEDULE_SOURCE VARCHAR2(20);

  CP_PROCESS_STATUS VARCHAR2(40);

  CP_HORIZON_START_DATE VARCHAR2(30);

  CP_HORIZON_END_DATE VARCHAR2(30);

  CP_ISSUE_DATE_FROM VARCHAR2(30);

  CP_ISSUE_DATE_TO VARCHAR2(30);

  CP_TP_FROM VARCHAR2(20);

  CP_TP_TO VARCHAR2(20);

  CP_TP_LOC_CODE_FROM VARCHAR2(20);

  CP_TP_LOC_CODE_TO VARCHAR2(20);

  CP_PROCESS_DATE_FROM VARCHAR2(30);

  CP_PROCESS_DATE_TO VARCHAR2(30);

  CP_TITLE VARCHAR2(50);

  CP_DEFAULT_OU VARCHAR2(240);

  FUNCTION CF_CUSTOMER_NUMFORMULA(CUSTOMER_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_SHIP_FROM_ORGFORMULA(SCHEDULE_SOURCE IN VARCHAR2
                                  ,SHIP_FROM_ORG_ID IN NUMBER
                                  ,CUST_SHIP_FROM_ORG_EXT IN VARCHAR2) RETURN VARCHAR;

  FUNCTION CF_SHIP_TO_LOCFORMULA(SCHEDULE_SOURCE IN VARCHAR2
                                ,SHIP_TO_ADDRESS_ID IN NUMBER
                                ,CUST_SHIP_TO_EXT IN VARCHAR2) RETURN VARCHAR;

  FUNCTION CF_CUST_ITEM_NUMFORMULA(SCHEDULE_SOURCE IN VARCHAR2
                                  ,CUSTOMER_ITEM_ID IN NUMBER
                                  ,CUSTOMER_ID IN NUMBER
                                  ,CUSTOMER_ITEM_EXT IN VARCHAR2) RETURN VARCHAR;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION CF_TEST_INDICATORFORMULA(EDI_TEST_INDICATOR IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_SHIP_DEL_PATTERNFORMULA(SHIP_DEL_PATTERN_EXT IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_INV_ITEM_CONC_SEGMENTFORMUL(INVENTORY_ITEM_ID IN NUMBER
                                         ,SHIP_FROM_ORG_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_SHIP_FROM_ORG1FORMULA(SCHEDULE_SOURCE IN VARCHAR2
                                   ,SHIP_FROM_ORG_ID1 IN NUMBER
                                   ,CUST_SHIP_FROM_ORG_EXT1 IN VARCHAR2) RETURN VARCHAR;

  FUNCTION CF_SHIP_TO_LOC1FORMULA(SCHEDULE_SOURCE IN VARCHAR2
                                 ,SHIP_TO_ADDRESS_ID1 IN NUMBER
                                 ,CUST_SHIP_TO_EXT1 IN VARCHAR2) RETURN VARCHAR;

  FUNCTION CF_SHIP_DEL_PATTERN1FORMULA(SHIP_DEL_PATTERN_EXT1 IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_INV_CONC_SEGMENT1FORMULA(INVENTORY_ITEM_ID1 IN NUMBER
                                      ,SHIP_FROM_ORG_ID1 IN NUMBER) RETURN CHAR;

  FUNCTION CF_CUST_ITEM_NUM1FORMULA(SCHEDULE_SOURCE IN VARCHAR2
                                   ,CUSTOMER_ITEM_ID1 IN NUMBER
                                   ,CUSTOMER_ID IN NUMBER
                                   ,CUSTOMER_ITEM_EXT1 IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_BILL_TO_LOCFORMULA(BILL_TO_ADDRESS_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_BILL_TO_LOC1FORMULA(BILL_TO_ADDRESS_ID1 IN NUMBER) RETURN CHAR;

  FUNCTION CF_SCHEDULE_SOURCEFORMULA(SCHEDULE_SOURCE IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_ADDRESS1FORMULA(CUST_ADDRESS_1_EXT IN VARCHAR2
                             ,CUST_ADDRESS_2_EXT IN VARCHAR2
                             ,CUST_ADDRESS_3_EXT IN VARCHAR2
                             ,CUST_ADDRESS_4_EXT IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_ADDRESS2FORMULA(CUST_ADDRESS_1_EXT IN VARCHAR2
                             ,CUST_ADDRESS_2_EXT IN VARCHAR2
                             ,CUST_ADDRESS_3_EXT IN VARCHAR2
                             ,CUST_ADDRESS_4_EXT IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_ADDRESS3FORMULA(CUST_ADDRESS_1_EXT IN VARCHAR2
                             ,CUST_ADDRESS_2_EXT IN VARCHAR2
                             ,CUST_ADDRESS_3_EXT IN VARCHAR2
                             ,CUST_ADDRESS_4_EXT IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_ADDRESS4FORMULA(CUST_ADDRESS_1_EXT IN VARCHAR2
                             ,CUST_ADDRESS_2_EXT IN VARCHAR2
                             ,CUST_ADDRESS_3_EXT IN VARCHAR2
                             ,CUST_ADDRESS_4_EXT IN VARCHAR2) RETURN CHAR;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CP_CUSTOMER_P RETURN VARCHAR2;

  FUNCTION CP_SCHEDULE_REF_NUM_P RETURN VARCHAR2;

  FUNCTION CP_SHIP_FROM_ORG_P RETURN VARCHAR2;

  FUNCTION CP_SHIP_TO_P RETURN VARCHAR2;

  FUNCTION CP_SCHEDULE_TYPE_P RETURN VARCHAR2;

  FUNCTION CP_SCHEDULE_PURPOSE_P RETURN VARCHAR2;

  FUNCTION CP_SCHEDULE_SOURCE_P RETURN VARCHAR2;

  FUNCTION CP_PROCESS_STATUS_P RETURN VARCHAR2;

  FUNCTION CP_HORIZON_START_DATE_P RETURN VARCHAR2;

  FUNCTION CP_HORIZON_END_DATE_P RETURN VARCHAR2;

  FUNCTION CP_ISSUE_DATE_FROM_P RETURN VARCHAR2;

  FUNCTION CP_ISSUE_DATE_TO_P RETURN VARCHAR2;

  FUNCTION CP_TP_FROM_P RETURN VARCHAR2;

  FUNCTION CP_TP_TO_P RETURN VARCHAR2;

  FUNCTION CP_TP_LOC_CODE_FROM_P RETURN VARCHAR2;

  FUNCTION CP_TP_LOC_CODE_TO_P RETURN VARCHAR2;

  FUNCTION CP_PROCESS_DATE_FROM_P RETURN VARCHAR2;

  FUNCTION CP_PROCESS_DATE_TO_P RETURN VARCHAR2;

  FUNCTION CP_TITLE_P RETURN VARCHAR2;

  FUNCTION CP_DEFAULT_OU_P RETURN VARCHAR2;

END RLM_RLMSCHRL_XMLP_PKG;

/