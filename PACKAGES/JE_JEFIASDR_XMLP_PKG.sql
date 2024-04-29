--------------------------------------------------------
--  DDL for Package JE_JEFIASDR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_JEFIASDR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JEFIASDRS.pls 120.2 2008/01/08 10:05:37 vijranga noship $ */
  P_CONC_REQUEST_ID NUMBER := 0;

  P_SET_OF_BOOKS_ID VARCHAR2(15);

  P_TAX_BOOK VARCHAR2(30);

  P_PERIOD_NAME VARCHAR2(15);

  P_REPORT_TYPE VARCHAR2(30);

  P_AS_NUM_HIGH VARCHAR2(40);

  P_AS_NUM_LOW VARCHAR2(40);

  C_ACCT_FLEX_STRUCT NUMBER;

  C_ACCT_FLEX_BAL_SEG VARCHAR2(240);

  C_SET_OF_BOOKS_ID NUMBER;

  C_SOB_NAME VARCHAR2(50);

  C_CAT_FLEX_STRUCT NUMBER;

  C_ASSET_KEY_STRUCT NUMBER;

  C_BOOK_TYPE_CODE VARCHAR2(32767);

  C_DISTRIBUTION_SOURCE_BOOK VARCHAR2(15);

  C_CURRENCY_CODE VARCHAR2(30);

  C_PRECISION NUMBER;

  C_COST_COMPANY VARCHAR2(200);

  P_CATEGORY_FLEX_FROM VARCHAR2(60);

  P_CATEGORY_FLEX_TO VARCHAR2(60);

  C_WHERE_CAT_FLEX VARCHAR2(240);

  C_MAJOR_CATEGORY VARCHAR2(600);

  C_ALL_CATEGORY VARCHAR2(200);

  C_COST_ACCOUNT VARCHAR2(100);

  C_REPORT_DATE VARCHAR2(32767);

  C_START_DATE DATE;

  C_CLOSE_DATE DATE;

  C_FISCAL_YEAR VARCHAR2(32767);

  C_START_COUNTER NUMBER;

  C_END_COUNTER NUMBER;

  C_FROM_OPEN_DATE DATE;

  C_FROM_CLOSE_DATE DATE;

  C_FROM_COUNTER NUMBER;

  C_CALENDAR_OPEN_DATE DATE;

  C_CALENDAR_CLOSE_DATE DATE;

  C_FROM_FISCAL_YEAR VARCHAR2(4);

  C_TO_COUNTER NUMBER;

  C_TO_OPEN_DATE DATE;

  C_TO_CLOSE_DATE DATE;

  C_TO_FISCAL_YEAR VARCHAR2(4);

  C_COST_ACCT_DESC VARCHAR2(50);

  C_ASSET_WHERE VARCHAR2(240);

  C_TIME_TO_CLOSE_DATE DATE;

  C_CORP_FROM_COUNTER NUMBER;

  C_CORP_TO_COUNTER NUMBER;

  C_CORP_CALENDAR_OPEN_DATE DATE;

  C_CORP_CALENDAR_CLOSE_DATE DATE;

  C_CORP_TO_OPEN_DATE DATE;

  C_CORP_TO_CLOSE_DATE DATE;

  C_CORP_TIME_TO_CLOSE_DATE DATE;

  P_DEBUG_SWITCH VARCHAR2(1);

  C_DISTRIBUTION_CORP_BOOK VARCHAR2(40);

  STRUCT_NUM VARCHAR2(15) := '101';

  SET_OF_BOOKS_NAME VARCHAR2(30);

  SELECT_ALL VARCHAR2(1000) := '(CC.SEGMENT1 || ''\n'' || SEGMENT2 || ''\n'' || SEGMENT3 || ''\n'' || SEGMENT4 || ''\n'' || SEGMENT5 || ''\n'' || SEGMENT6 || ''\n'' || SEGMENT7 || ''\n'' || SEGMENT8 || ''\n'' || SEGMENT9 || ''\n'' || SEGMENT10
  || ''\n'' || SEGMENT11 || ''\n'' || SEGMENT12 || ''\n'' || SEGMENT13 || ''\n'' || SEGMENT14 || ''\n'' || SEGMENT15 || ''\n'' || SEGMENT16 || ''\n'' || SEGMENT17 || ''\n'' || SEGMENT18 || ''\n'' || SEGMENT19 || ''\n'' || SEGMENT20 || ''\n''
  || SEGMENT21 || ''\n'' || SEGMENT22 || ''\n'' || SEGMENT23 || ''\n'' || SEGMENT24 || ''\n'' || SEGMENT25 || ''\n'' || SEGMENT26 || ''\n'' || SEGMENT27 || ''\n'' || SEGMENT28 || ''\n'' || SEGMENT29 || ''\n'' || SEGMENT30)';

  WHERE_FLEX VARCHAR2(4000) := 'CC.SEGMENT11 BETWEEN  ''00'' and ''11''';

  ORDERBY_ACCT VARCHAR2(30) := 'CC.SEGMENT10';

  PRECISION NUMBER := 0;

  FUNC_CURRENCY VARCHAR2(25);

  C_BOOK_CLASS VARCHAR2(32);

  C_ACCOUNT_FLEX_ID NUMBER;

  CP_CLOSE_DATE DATE;

  CP_LASTYR_BEGIN_PERIOD_COUNTER NUMBER;

  CP_REPORT_NAME VARCHAR2(80);

  CP_FROM_FISCAL_YEAR VARCHAR2(32767);

  CP_PERIOD_NAME VARCHAR2(20);

  CP_TAX_BOOK VARCHAR2(50);

  CP_DISTRIBUTION_CORP_BOOK VARCHAR2(50);

  CP_CURRENCY_CODE VARCHAR2(20);

  CP_SOB_NAME VARCHAR2(50);

  CP_CALENDAR_OPEN_DATE VARCHAR2(20);

  CP_CALENDAR_CLOSE_DATE VARCHAR2(20);

  CP_REPORT_TYPE VARCHAR2(20);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION C_COST_ACCT_DESCFORMULA(COST_ACCOUNT IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CF_ASSET_CLOSE_NBVFORMULA(CF_ASS_INITIAL_NBV_ADJUSTED IN NUMBER
                                    ,CF_ASS_TAX_ADDITIONS IN NUMBER
                                    ,CS_ASS_TAX_RETIREMENT IN NUMBER
                                    ,A1_1 IN NUMBER
                                    ,CF_ASS_DEF_DP IN NUMBER) RETURN NUMBER;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  PROCEDURE GET_THE_ACCT_DESC(P_ACCOUNT IN VARCHAR2
                             ,P_DESCR OUT NOCOPY VARCHAR2);

  FUNCTION CF_F_CAT_CORP_GAINFORMULA(CS_F_CAT_CORP_SALES_PROCEEDS IN NUMBER
                                    ,CS_F_CAT_RETIREMENT IN NUMBER) RETURN NUMBER;

  FUNCTION CF_F_ASSET_COST_ENDFORMULA(CS_F_CAT_CORP_COST IN NUMBER
                                     ,CS_F_CAT_CORP_ADDITION IN NUMBER
                                     ,CS_F_CAT_CORP_RETIREMENT IN NUMBER) RETURN NUMBER;

  FUNCTION CF_F_CAT_CORP_DEPRN_RESERVEFOR(CS_F_CAT_CORP_DEPRN_RESERVE IN NUMBER
                                         ,CF_F_CAT_CP_YTD IN NUMBER
                                         ,CS_F_CAT_CORP_RET_RESERVE IN NUMBER) RETURN NUMBER;

  FUNCTION CF_F_CAT_NBV_STARTFORMULA(CS_F_CAT_CORP_COST IN NUMBER
                                    ,CS_F_CAT_CORP_DEPRN_RESERVE IN NUMBER) RETURN NUMBER;

  FUNCTION CF_F_CAT_NBV_ENDFORMULA(CF_F_CAT_ASSET_COST_END IN NUMBER
                                  ,CF_F_CAT_CORP_DEPRN_RESERVE IN NUMBER) RETURN NUMBER;

  FUNCTION CF_F_CAT_CORP_DEPN_RESERVEFORM(CS_F_CAT_TAX_DEPRN_RESERVE IN NUMBER
                                         ,CS_F_CAT_CORP_DEPRN_RESERVE IN NUMBER) RETURN NUMBER;

  FUNCTION CF_F_CAT_DEF_DEPRN_YTDFORMULA(CF_F_CAT_TAX_YTD_DEP IN NUMBER
                                        ,CF_F_CAT_CP_YTD IN NUMBER) RETURN NUMBER;

  FUNCTION CF_F_CAT_DEFERRED_DEPRNFORMULA(CF_F_CAT_CORP_DEPN_RESERVE IN NUMBER
                                         ,CF_F_CAT_DEF_DEPRN_YTD IN NUMBER
                                         ,CS_F_CAT_CORP_RET_RESERVE IN NUMBER) RETURN NUMBER;

  FUNCTION CF_F_CAT_RETIREMENTSFORMULA(CS_F_CAT_CORP_SALES_PROCEEDS IN NUMBER
                                      ,CS_F_CAT_CORP_NBV_RETIRED IN NUMBER) RETURN NUMBER;

  FUNCTION CF_ASS_TAX_ADDITIONSFORMULA(CS_ASS_TAX_ADDITIONS IN NUMBER) RETURN NUMBER;

  FUNCTION CF_ASS_CORP_ADDITIONSFORMULA(CS_ASS_CORP_ADDITIONS IN NUMBER) RETURN NUMBER;

  FUNCTION CF_ASS_DEF_DPFORMULA(CS_ASS_TAX_DEPRN IN NUMBER
                               ,A1_1 IN NUMBER
                               ,CS_ASS_THIS_FISADJ IN NUMBER) RETURN NUMBER;

  FUNCTION CF_F_CAT_CP_YTDFORMULA(CS_F_CAT_CORP_YTD_DEPRN IN NUMBER) RETURN NUMBER;

  FUNCTION CF_F_CAT_TAX_YTD_DEPFORMULA(CS_F_CAT_TAX_YTD_DEPRN IN NUMBER
                                      ,CS_F_CAT_TAX_RESERVE_RETIRED IN NUMBER) RETURN NUMBER;

  FUNCTION CF_F_CAT_RETIRE_DIFFFORMULA(CS_F_CAT_CORP_RET_RESERVE IN NUMBER
                                      ,CS_F_CAT_TAX_RESERVE_RETIRED IN NUMBER) RETURN NUMBER;

  FUNCTION CF_1FORMULA0029(CF_F_CAT_CORP_DEPN_RESERVE IN NUMBER
                          ,CS_CAT_DEF_DEPRN IN NUMBER
                          ,CF_F_CAT_RETIRE_DIFF IN NUMBER) RETURN NUMBER;

  FUNCTION CF_ASS_INITIAL_NBV_ADJUSTEDFOR(ASSET_NUMBER IN VARCHAR2
                                         ,CAT_ID IN NUMBER
                                         ,ENABLED_FLAG IN VARCHAR2
                                         ,INITIAL_NBV IN NUMBER
                                         ,CS_ASS_FISCAL_ADJUSTMENT IN NUMBER) RETURN NUMBER;

  FUNCTION CF_ASS_TAX_DP_RESERVE_ADJUSTED(TAX_DP_RESERVE IN NUMBER
                                         ,CS_ASS_FISCAL_ADJUSTMENT IN NUMBER) RETURN NUMBER;

  FUNCTION CF_REPORT_DATEFORMULA RETURN CHAR;

  FUNCTION STRUCT_NUM_P RETURN VARCHAR2;

  FUNCTION SET_OF_BOOKS_NAME_P RETURN VARCHAR2;

  FUNCTION SELECT_ALL_P RETURN VARCHAR2;

  FUNCTION WHERE_FLEX_P RETURN VARCHAR2;

  FUNCTION ORDERBY_ACCT_P RETURN VARCHAR2;

  FUNCTION PRECISION_P RETURN NUMBER;

  FUNCTION FUNC_CURRENCY_P RETURN VARCHAR2;

  FUNCTION C_BOOK_CLASS_P RETURN VARCHAR2;

  FUNCTION C_ACCOUNT_FLEX_ID_P RETURN NUMBER;

  FUNCTION CP_CLOSE_DATE_P RETURN DATE;

  FUNCTION CP_LASTYR_BEGIN_PERIOD_COUNTE RETURN NUMBER;

  FUNCTION CP_REPORT_NAME_P RETURN VARCHAR2;

  FUNCTION CP_FROM_FISCAL_YEAR_P RETURN VARCHAR2;

  FUNCTION CP_PERIOD_NAME_P RETURN VARCHAR2;

  FUNCTION CP_TAX_BOOK_P RETURN VARCHAR2;

  FUNCTION CP_DISTRIBUTION_CORP_BOOK_P RETURN VARCHAR2;

  FUNCTION CP_CURRENCY_CODE_P RETURN VARCHAR2;

  FUNCTION CP_SOB_NAME_P RETURN VARCHAR2;

  FUNCTION CP_CALENDAR_OPEN_DATE_P RETURN VARCHAR2;

  FUNCTION CP_CALENDAR_CLOSE_DATE_P RETURN VARCHAR2;

  FUNCTION CP_REPORT_TYPE_P RETURN VARCHAR2;

END JE_JEFIASDR_XMLP_PKG;




/