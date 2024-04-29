--------------------------------------------------------
--  DDL for Package JL_JLMXFISR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_JLMXFISR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JLMXFISRS.pls 120.1 2007/12/25 16:53:46 dwkrishn noship $ */
  P_BOOK_TYPE_CODE VARCHAR2(40);

  P_END_OF_REPORT VARCHAR2(21);

  P_NO_DATA_FOUND VARCHAR2(21);

  P_PROCESS_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  P_CURR_FY NUMBER;

  P_INCLUDE_DPIS VARCHAR2(32767);

  P_INCLUDE_RET VARCHAR2(32767);

  P_INCLUDE_ZERO_NBV_ASSETS VARCHAR2(32767);

  P_CA_SET_OF_BOOKS_ID NUMBER;

  P_CURRENCY_CODE VARCHAR2(3);

  P_MRCSOBTYPE VARCHAR2(10) := 'P';

  LP_FA_RETIREMENTS VARCHAR2(50);

  LP_FA_DEPRN_SUMMARY VARCHAR2(50) := 'fa_deprn_summary';

  LP_FA_DEPRN_PERIODS VARCHAR2(50) := 'fa_deprn_periods';

  LP_FA_DEPRN_DETAIL VARCHAR2(50) := 'fa_deprn_detail';

  LP_FA_DEFERRED_DEPRN VARCHAR2(50);

  LP_FA_BOOK_CONTROLS VARCHAR2(50) := 'fa_book_controls';

  LP_FA_BOOKS VARCHAR2(50) := 'fa_books';

  LP_FA_ASSET_INVOICES VARCHAR2(50);

  LP_FA_ADJUSTMENTS VARCHAR2(50) := 'fa_adjustments';

  LP_CURRENCY_CODE VARCHAR2(15);

  C_BASE_CURRENCY_CODE VARCHAR2(15);

  C_BASE_PRECISION NUMBER;

  C_BASE_MIN_ACCT_UNIT NUMBER;

  C_BASE_DESCRIPTION VARCHAR2(240);

  C_ORGANIZATION_NAME VARCHAR2(30);

  C_MAX_PERIOD_COUNTER NUMBER;

  C_LAST_PERIOD_COUNTER NUMBER;

  C_FISCAL_START_DATE DATE;

  C_FISCAL_END_DATE DATE;

  C_RATIO_PRECISION NUMBER;

  C_MIN_PERIOD_COUNTER NUMBER;

  CAT_FLEX_STRUCT NUMBER;

  C_USER_ID NUMBER;

  C_ALL_SEGS VARCHAR2(600) := '(segment1|| ''\n'' ||segment2|| ''\n'' ||segment3|| ''\n'' ||segment4|| ''\n'' ||segment5|| ''\n'' ||segment6|| ''\n'' ||segment7)';

  PROCEDURE GET_BASE_CURR_DATA;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION C_PRICE_INDEXFORMULA(ASSET_CAT_ID IN NUMBER
                               ,ACQDATE IN DATE) RETURN NUMBER;

  FUNCTION C_INDEX_VALUEFORMULA(C_PRICE_INDEX IN NUMBER
                               ,ACQDATE IN DATE) RETURN NUMBER;

  FUNCTION C_CORR_FACTORFORMULA(C_INDEX_VALUE_HALF_PERIOD IN NUMBER
                               ,C_INDEX_VALUE IN NUMBER) RETURN NUMBER;

  FUNCTION C_ACCUM_DEPRN_PREV_YRFORMULA(ASSET_ID IN NUMBER
                                       ,PERIOD_COUNTER IN NUMBER
                                       ,ORIGINAL_COST IN NUMBER
                                       ,RETIREMENT_ID IN NUMBER) RETURN NUMBER;

  FUNCTION C_ADJ_ACCUM_DEPRNFORMULA(C_ACCUM_DEPRN_CURR_YR IN NUMBER
                                   ,C_CORR_FACTOR IN NUMBER
                                   ,ASSET_ID IN NUMBER
                                   ,TRANSACTION_HEADER_ID_IN IN NUMBER
                                   ,TRANSACTION_HEADER_ID_OUT IN NUMBER
                                   ,DESCRIPTION IN VARCHAR2
                                   ,ASSET_CAT_ID IN NUMBER
                                   ,ASSET_NUMBER IN VARCHAR2
                                   ,ACQDATE IN DATE
                                   ,PRORATE_DATE IN DATE
                                   ,RETIREMENT_ID IN NUMBER
                                   ,C_INDEX_VALUE IN NUMBER
                                   ,ORIGINAL_COST IN NUMBER
                                   ,C_ACCUM_DEPRN_PREV_YR IN NUMBER
                                   ,PERIOD_COUNTER_FULLY_RESERVED IN NUMBER) RETURN NUMBER;

  FUNCTION C_ACCUM_DEPRNFORMULA(STATUS IN VARCHAR2
                               ,TRANSACTION_HEADER_ID_OUT IN NUMBER
                               ,TRANSACTION_HEADER_ID_IN IN NUMBER
                               ,ASSET_ID IN NUMBER
                               ,PERIOD_COUNTER IN NUMBER
                               ,RETIREMENT_ID IN NUMBER
                               ,ORIGINAL_COST IN NUMBER) RETURN NUMBER;

  FUNCTION C_ACCUM_DEPRN_CURR_YRFORMULA(C_ACCUM_DEPRN IN NUMBER
                                       ,C_ACCUM_DEPRN_PREV_YR IN NUMBER) RETURN NUMBER;

  FUNCTION C_INDEX_VALUE_HALF_PERIODFORMU(RETIREMENT_ID_1 IN NUMBER
                                         ,ACQDATE IN DATE
                                         ,C_PRICE_INDEX IN NUMBER) RETURN NUMBER;

  PROCEDURE CUSTOM_INIT;

  PROCEDURE RAISE_ERR(MSGNAME IN VARCHAR2
                     ,ABORT_FLAG IN VARCHAR2);

  PROCEDURE RAISE_ORA_ERR;

  PROCEDURE PRC_PREV_FISCAL_YEAR_DEPRN(P_ASSET_ID IN NUMBER
                                      ,P_BOOK_TYPE_CODE IN VARCHAR
                                      ,P_PERIOD_START IN NUMBER
                                      ,P_PERIOD_END IN NUMBER
                                      ,P_PERIOD_COUNTER IN NUMBER
                                      ,P_COST_RETIRED IN NUMBER
                                      ,P_RETIREMENT_ID IN NUMBER
                                      ,P_ACC_DEPRN_PREV_FY OUT NOCOPY NUMBER);

  PROCEDURE PRC_LIFE_TO_DATE_DEPRN(P_ASSET_ID IN NUMBER
                                  ,P_BOOK_TYPE_CODE IN VARCHAR
                                  ,P_TRANSACTION_HEADER_ID IN NUMBER
                                  ,P_PERIOD_START IN NUMBER
                                  ,P_PERIOD_END IN NUMBER
                                  ,P_PERIOD_COUNTER IN NUMBER
                                  ,P_RETIREMENT_ID IN NUMBER
                                  ,P_COST_RETIRED IN NUMBER
                                  ,P_ACC_DEPRN_LIFE_TD OUT NOCOPY NUMBER);

  FUNCTION CF_RETIREMENT_DATE(RETIREMENT_ID_1 IN NUMBER) RETURN DATE;

  FUNCTION CF_INCLUDE_DPISFORMULA RETURN CHAR;

  function BeforeReport return boolean;

  FUNCTION CF_INCLUDE_RETFORMULA RETURN CHAR;

  FUNCTION CF_INCLUDE_ZERO_NVB_ASSETSFORM RETURN CHAR;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION C_BASE_CURRENCY_CODE_P RETURN VARCHAR2;

  FUNCTION C_BASE_PRECISION_P RETURN NUMBER;

  FUNCTION C_BASE_MIN_ACCT_UNIT_P RETURN NUMBER;

  FUNCTION C_BASE_DESCRIPTION_P RETURN VARCHAR2;

  FUNCTION C_ORGANIZATION_NAME_P RETURN VARCHAR2;

  FUNCTION C_MAX_PERIOD_COUNTER_P RETURN NUMBER;

  FUNCTION C_LAST_PERIOD_COUNTER_P RETURN NUMBER;

  FUNCTION C_FISCAL_START_DATE_P RETURN DATE;

  FUNCTION C_FISCAL_END_DATE_P RETURN DATE;

  FUNCTION C_RATIO_PRECISION_P RETURN NUMBER;

  FUNCTION C_MIN_PERIOD_COUNTER_P RETURN NUMBER;

  FUNCTION CAT_FLEX_STRUCT_P RETURN NUMBER;

  FUNCTION C_USER_ID_P RETURN NUMBER;

  FUNCTION C_ALL_SEGS_P RETURN VARCHAR2;

  PROCEDURE SET_NAME(APPLICATION IN VARCHAR2
                    ,NAME IN VARCHAR2);

  PROCEDURE SET_TOKEN(TOKEN IN VARCHAR2
                     ,VALUE IN VARCHAR2
                     ,TRANSLATE IN BOOLEAN);

  PROCEDURE RETRIEVE(MSGOUT OUT NOCOPY VARCHAR2);

  PROCEDURE CLEAR;

  FUNCTION GET_STRING(APPIN IN VARCHAR2
                     ,NAMEIN IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION GET_NUMBER(APPIN IN VARCHAR2
                     ,NAMEIN IN VARCHAR2) RETURN NUMBER;

  FUNCTION GET RETURN VARCHAR2;

  FUNCTION GET_ENCODED RETURN VARCHAR2;

  PROCEDURE PARSE_ENCODED(ENCODED_MESSAGE IN VARCHAR2
                         ,APP_SHORT_NAME OUT NOCOPY VARCHAR2
                         ,MESSAGE_NAME OUT NOCOPY VARCHAR2);

  PROCEDURE SET_ENCODED(ENCODED_MESSAGE IN VARCHAR2);

  PROCEDURE RAISE_ERROR;

END JL_JLMXFISR_XMLP_PKG;




/
