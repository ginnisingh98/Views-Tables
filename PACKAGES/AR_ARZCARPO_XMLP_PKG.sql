--------------------------------------------------------
--  DDL for Package AR_ARZCARPO_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARZCARPO_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARZCARPOS.pls 120.0 2007/12/27 14:14:12 abraghun noship $ */
  P_CONC_REQUEST_ID NUMBER := 0;

  P_BATCH_ID VARCHAR2(40);

  P_PROCESS_TYPE VARCHAR2(40);

  P_CREATE_FLAG VARCHAR2(2);

  P_APPROVE_FLAG VARCHAR2(2);

  P_FORMAT_FLAG VARCHAR2(2);

  P_BATCH_NAME VARCHAR2(32767);

  P_REQUEST_ID_PRINT NUMBER;

  P_REQUEST_ID_TRANSMIT NUMBER;

  P_CREATE_ONLY_FLAG VARCHAR2(1);

  P_REQUEST_ID_MAIN NUMBER;

  P_NO_DATA_FOUND VARCHAR2(2000);

  P_CC_ERROR_FLAG VARCHAR2(32767);

  RP_REPORT_NAME VARCHAR2(80);

  RP_DATA_FOUND VARCHAR2(300);

  RP_SUB_TITLE VARCHAR2(80);

  FUNCTION REPORT_NAMEFORMULA RETURN VARCHAR2;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION SUB_TITLEFORMULA RETURN VARCHAR2;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION C_EXCEPTION_MEANINGFORMULA(C_EXCEPTION_CODE IN VARCHAR2
                                     ,CC_ERROR_CODE IN VARCHAR2
                                     ,CC_ERROR_FLAG IN VARCHAR2
                                     ,CC_ERROR_TEXT IN VARCHAR2
                                     ,C_ADDL_MESSAGE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CF_1FORMULA(CC_DISPLAY_FLAG IN VARCHAR2) RETURN CHAR;

  FUNCTION DESNAMEVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2;

  FUNCTION RP_DATA_FOUND_P RETURN VARCHAR2;

  FUNCTION RP_SUB_TITLE_P RETURN VARCHAR2;

END AR_ARZCARPO_XMLP_PKG;


/
