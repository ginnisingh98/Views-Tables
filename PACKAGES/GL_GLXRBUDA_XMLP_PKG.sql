--------------------------------------------------------
--  DDL for Package GL_GLXRBUDA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXRBUDA_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXRBUDAS.pls 120.0 2007/12/27 15:06:04 vijranga noship $ */
  P_CONC_REQUEST_ID NUMBER := 0;

  P_LEDGER_ID NUMBER;

  P_BUDGET_VERSION_ID NUMBER;

  P_CURRENCY_CODE VARCHAR2(15);

  P_PERIOD_NAME VARCHAR2(15);

  P_PERIOD_TYPE VARCHAR2(30);

  P_ACCESS_SET_ID NUMBER;

  LEDGER_NAME VARCHAR2(30);

  BUDGET_NAME VARCHAR2(30);

  STRUCT_NUM NUMBER := 50105;

  FLEXDATA VARCHAR2(1000) := '(segment1||''\n''||segment2||''\n''||segment3||''\n''||segment4||''\n''||segment5||
  ''\n''||segment6||''\n''||segment7||''\n''||segment8||''\n''||segment9||''\n''||segment10||''\n''||segment11||
  ''\n''||segment12||''\n''||segment13||''\n''||segment14||''\n''||segment15||''\n''||segment16||''\n''||segment17||''\n''||segment18||''\n''||segment19||''\n''||segment20||''\n''||segment21||
  ''\n''||segment22||''\n''||segment23||''\n''||segment24||''\n''||segment25||''\n''||segment26||''\n''||segment27||''\n''||segment28||''\n''||segment29||''\n''||segment30)';

  ACCOUNT_SEG VARCHAR2(1000) := '(segment1||''\n''||segment2||''\n''||segment3||''\n''||segment4||''\n''||segment5||''\n''||segment6||''\n''||segment7||''\n''||segment8||''\n''||segment9||''\n''
  ||segment10||''\n''||segment11||''\n''||segment12||''\n''||segment13||''\n''||segment14||''\n''||segment15||''\n''||segment16||''\n''||segment17||''\n''||segment18||''\n''||segment19||''\n''||
  segment20||''\n''||segment21||''\n''||segment22||''\n''||segment23||''\n''||segment24||''\n''||segment25||''\n''||segment26||''\n''||segment27||''\n''||segment28||''\n''||segment29||''\n''||segment30)';

  FLEX_ORDERBY VARCHAR2(1000) := '1';

  PTD_YTD VARCHAR2(300) := '(glbd.period_net_dr + glbd.project_to_date_dr - glbd.period_net_cr - glbd.project_to_date_cr)';

  PTD_YTD_DSP VARCHAR2(240);

  ACCESS_SET_NAME VARCHAR2(30);

  WHERE_DAS VARCHAR2(800);

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION LEDGER_NAME_P RETURN VARCHAR2;

  FUNCTION BUDGET_NAME_P RETURN VARCHAR2;

  FUNCTION STRUCT_NUM_P RETURN NUMBER;

  FUNCTION FLEXDATA_P RETURN VARCHAR2;

  FUNCTION ACCOUNT_SEG_P RETURN VARCHAR2;

  FUNCTION FLEX_ORDERBY_P RETURN VARCHAR2;

  FUNCTION PTD_YTD_P RETURN VARCHAR2;

  FUNCTION PTD_YTD_DSP_P RETURN VARCHAR2;

  FUNCTION ACCESS_SET_NAME_P RETURN VARCHAR2;

  FUNCTION WHERE_DAS_P RETURN VARCHAR2;

  PROCEDURE GL_GET_PERIOD_DATES(TLEDGER_ID IN NUMBER
                               ,TPERIOD_NAME IN VARCHAR2
                               ,TSTART_DATE OUT NOCOPY DATE
                               ,TEND_DATE OUT NOCOPY DATE
                               ,ERRBUF OUT NOCOPY VARCHAR2);

  PROCEDURE GL_GET_LEDGER_INFO(LEDID IN NUMBER
                              ,COAID OUT NOCOPY NUMBER
                              ,LEDNAME OUT NOCOPY VARCHAR2
                              ,FUNC_CURR OUT NOCOPY VARCHAR2
                              ,ERRBUF OUT NOCOPY VARCHAR2);

  PROCEDURE GL_GET_BUD_OR_ENC_NAME(ACTUAL_TYPE IN VARCHAR2
                                  ,TYPE_ID IN NUMBER
                                  ,NAME OUT NOCOPY VARCHAR2
                                  ,ERRBUF OUT NOCOPY VARCHAR2);

  PROCEDURE GL_GET_LOOKUP_VALUE(LMODE IN VARCHAR2
                               ,CODE IN VARCHAR2
                               ,TYPE IN VARCHAR2
                               ,VALUE OUT NOCOPY VARCHAR2
                               ,ERRBUF OUT NOCOPY VARCHAR2);

  PROCEDURE GL_GET_FIRST_PERIOD(TLEDGER_ID IN NUMBER
                               ,TPERIOD_NAME IN VARCHAR2
                               ,TFIRST_PERIOD OUT NOCOPY VARCHAR2
                               ,ERRBUF OUT NOCOPY VARCHAR2);

  PROCEDURE GL_GET_FIRST_PERIOD_OF_QUARTER(TLEDGER_ID IN NUMBER
                                          ,TPERIOD_NAME IN VARCHAR2
                                          ,TFIRST_PERIOD OUT NOCOPY VARCHAR2
                                          ,ERRBUF OUT NOCOPY VARCHAR2);

  PROCEDURE GL_GET_CONSOLIDATION_INFO(CONS_ID IN NUMBER
                                     ,CONS_NAME OUT NOCOPY VARCHAR2
                                     ,METHOD OUT NOCOPY VARCHAR2
                                     ,CURR_CODE OUT NOCOPY VARCHAR2
                                     ,FROM_LEDID OUT NOCOPY NUMBER
                                     ,TO_LEDID OUT NOCOPY NUMBER
                                     ,DESCRIPTION OUT NOCOPY VARCHAR2
                                     ,START_DATE OUT NOCOPY DATE
                                     ,END_DATE OUT NOCOPY DATE
                                     ,ERRBUF OUT NOCOPY VARCHAR2);

END GL_GLXRBUDA_XMLP_PKG;



/
