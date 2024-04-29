--------------------------------------------------------
--  DDL for Package JG_JGZZFAAD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_JGZZFAAD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JGZZFAADS.pls 120.2 2007/12/25 16:08:20 npannamp noship $ */
  P_REPORT_TYPE VARCHAR2(10);

  P_PRECISION NUMBER;

  P_STATUTORY_REPORT VARCHAR2(1);

  P_PRECISION_WIDTH NUMBER;

  P_BALANCING_SEGMENT VARCHAR2(32767);

  P_ASSET_INFO VARCHAR2(10);

  LP_DYNAMIC_COL VARCHAR2(80);

  P_SUMMARY VARCHAR2(1);

  P_BOOK_TYPE_CODE VARCHAR2(30);

  P_FROM_PERIOD VARCHAR2(30);

  P_TO_PERIOD VARCHAR2(30);

  P_CONC_REQUEST_ID NUMBER;

  RP_COMPANY_NAME VARCHAR2(30);

  RP_REPORT_NAME VARCHAR2(80);

  RP_SOB_NAME VARCHAR2(80);

  RP_PRECISION NUMBER;

  RP_SOB_ID NUMBER;

  RP_CURRENCY_CODE VARCHAR2(32767);

  RP_ACCT_VALUESET_NAME VARCHAR2(80);

  CP_DATE_FORMAT VARCHAR2(11);

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION DISP_OBJECT RETURN BOOLEAN;

  FUNCTION CF_ADDITIONS_CFFORMULA(CS_ADDITIONS_RTOT IN NUMBER
                                 ,ADDITIONS IN NUMBER) RETURN NUMBER;

  FUNCTION CF_BEGIN_BALANCEFORMULA(CS_BEGIN_BALANCE_RTOT IN NUMBER
                                  ,BEGIN_BALANCE IN NUMBER) RETURN NUMBER;

  FUNCTION CF_END_BALANCE_CFFORMULA(CS_END_BALANCE_RTOT IN NUMBER
                                   ,END_BALANCE IN NUMBER) RETURN NUMBER;

  FUNCTION CF_RETIREMENTS_CFFORMULA(CS_RETIREMENTS_RTOT IN NUMBER
                                   ,RETIREMENTS IN NUMBER) RETURN NUMBER;

  FUNCTION CF_REVALUATIONS_CFFORMULA(CS_REVALUATIONS_RTOT IN NUMBER
                                    ,REVALUATIONS IN NUMBER) RETURN NUMBER;

  FUNCTION CF_RECLASSES_CFFORMULA(CS_RECLASSES_RTOT IN NUMBER
                                 ,RECLASSES IN NUMBER) RETURN NUMBER;

  FUNCTION CF_ADJUSTMENTS_CFFORMULA(CS_ADJUSTMENTS_RTOT IN NUMBER
                                   ,ADJUSTMENTS IN NUMBER) RETURN NUMBER;

  FUNCTION CF_COST_BEGIN_BALANCE_CFFORMUL(CS_COST_BEGIN_BALANCE_RTOT IN NUMBER
                                         ,COST_BEGIN_BALANCE IN NUMBER) RETURN NUMBER;

  FUNCTION CF_PAREANT_ACCT_DESCRFORMULA(PARENT_ACCOUNT IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CF_PAGE_PARENT_ACCT_DESCRFORMU(PARENT_ACCT IN VARCHAR2
                                         ,PARENT_ACCOUNT IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CF_COST_BEGIN_BALANCE_REPTOTFO(CS_COST_BEGIN_BALANCE_REPTOT IN NUMBER
                                         ,COST_BEGIN_BALANCE IN NUMBER) RETURN NUMBER;

  FUNCTION CF_BEGIN_BALANCE_REPTOTFORMULA(CS_BEGIN_BAL_REPTOT IN NUMBER
                                         ,BEGIN_BALANCE IN NUMBER) RETURN NUMBER;

  FUNCTION CF_ADDITIONS_REPTOTFORMULA(CS_ADDITIONS_REPTOT IN NUMBER
                                     ,ADDITIONS IN NUMBER) RETURN NUMBER;

  FUNCTION CF_ADJUSTMENTS_REPTOTFORMULA(CS_ADJUSTMENTS_REPTOT IN NUMBER
                                       ,ADJUSTMENTS IN NUMBER) RETURN NUMBER;

  FUNCTION CF_RECLASES_REPTOTFORMULA(CS_RECLASSES_REPTOT IN NUMBER
                                    ,RECLASSES IN NUMBER) RETURN NUMBER;

  FUNCTION CF_RETIREMENTS_REPTOTFORMULA(CS_RETIREMENTS_REPTOT IN NUMBER
                                       ,RETIREMENTS IN NUMBER) RETURN NUMBER;

  FUNCTION CF_REVALUATIONS_REPTOTFORMULA(CS_REVALUATIONS_REPTOT IN NUMBER
                                        ,REVALUATIONS IN NUMBER) RETURN NUMBER;

  FUNCTION CF_END_BALANCE_REPTOTFORMULA(CS_END_BALANCE_REPTOT IN NUMBER
                                       ,END_BALANCE IN NUMBER) RETURN NUMBER;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2;

  FUNCTION RP_SOB_NAME_P RETURN VARCHAR2;

  FUNCTION RP_PRECISION_P RETURN NUMBER;

  FUNCTION RP_SOB_ID_P RETURN NUMBER;

  FUNCTION RP_CURRENCY_CODE_P RETURN VARCHAR2;

  FUNCTION RP_ACCT_VALUESET_NAME_P RETURN VARCHAR2;

  FUNCTION CP_DATE_FORMAT_P RETURN VARCHAR2;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION M_CARRY_FORWARDFORMATTRIGGER RETURN NUMBER;

END JG_JGZZFAAD_XMLP_PKG;



/