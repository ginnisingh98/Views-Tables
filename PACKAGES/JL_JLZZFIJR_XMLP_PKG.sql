--------------------------------------------------------
--  DDL for Package JL_JLZZFIJR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_JLZZFIJR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JLZZFIJRS.pls 120.1 2007/12/25 16:54:17 dwkrishn noship $ */
  P_BOOK VARCHAR2(32767);

  P_PERIOD VARCHAR2(32767);

  P_ASSET_CATEGORY VARCHAR2(32767);

  P_ASSET_TYPE VARCHAR2(32767);

  P_CATEGORY_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  P_MIN_PRECISION NUMBER := 2;

  P_END_OF_REPORT VARCHAR2(30);

  P_NO_DATA_FOUND VARCHAR2(30);

  P_CA_SET_OF_BOOKS_ID NUMBER;

  LP_CURRENCY_CODE VARCHAR2(32767);

  P_CA_ORG_ID VARCHAR2(15);

  P_MRCSOBTYPE VARCHAR2(10) := 'P';

  LP_FA_RETIREMENTS VARCHAR2(50);

  LP_FA_DEPRN_SUMMARY VARCHAR2(50) := 'fa_deprn_summary';

  LP_FA_DEPRN_DETAIL VARCHAR2(50) := 'fa_deprn_detail';

  LP_FA_DEFERRED_DEPRN VARCHAR2(50);

  LP_FA_BOOK_CONTROLS VARCHAR2(50) := 'fa_book_controls';

  LP_FA_BOOKS VARCHAR2(50) := 'fa_books';

  LP_FA_ASSET_INVOICES VARCHAR2(50);

  LP_FA_ADJUSTMENTS VARCHAR2(50) := 'fa_adjustments';

  LP_FA_DEPRN_PERIODS VARCHAR2(50) := 'fa_deprn_periods';

  CP_CAT_CORP_COST VARCHAR2(17);

  CP_CAT_ADJ_COST_PER VARCHAR2(16);

  CP_CAT_ADJ_COST VARCHAR2(17);

  CP_CAT_CORP_DEPR_RESERVE VARCHAR2(17);

  CP_CAT_DEPR_RESERVE_ADJ_PER VARCHAR2(17);

  CP_CAT_ADJ_DEPRN_RESERVE VARCHAR2(17);

  CP_CAT_CORP_YTD_DEPRN_EXPENSE VARCHAR2(17);

  CP_CAT_YTD_DEPRN_EXPENSE_ADJ_P VARCHAR2(17);

  CP_CAT_ADJ_YTD_DEPRN_EXPENSE VARCHAR2(17);

  CP_ASSET_CORP_COST VARCHAR2(17);

  CP_ASSET_ADJ_COST_PER VARCHAR2(16);

  CP_ASSET_ADJ_COST VARCHAR2(17);

  CP_ASSET_CORP_DEPR_RESERVE VARCHAR2(17);

  CP_ASSET_DEPR_RESERVE_ADJ_PER VARCHAR2(17);

  CP_ASSET_ADJ_DEPRN_RESERVE VARCHAR2(17);

  CP_ASSET_CORP_YTD_DEPRN_EXPENS VARCHAR2(17);

  CP_ASSET_YTD_DEPR_EXPN_ADJ_PER VARCHAR2(17);

  CP_ASSET_YTD_DEPRN_EXPENSE VARCHAR2(17);

  BOOK_CLASS VARCHAR2(15);

  DISTRIBUTION_SOURCE_BOOK VARCHAR2(15);

  CP_REPORT_NAME VARCHAR2(2000);

  CP_COMPANY_NAME VARCHAR2(80);

  CURRENCY_CODE VARCHAR2(15);

  CP_PARAM_CURRENCY VARCHAR2(20);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION REPORT_NAMEFORMULA(COMPANY_NAME IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION BOOKFORMULA RETURN VARCHAR2;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION PERIOD_PCFORMULA RETURN NUMBER;

  FUNCTION DEPR_RESERVE_ADJ_PERFORMULA(ASSET_ID IN NUMBER
                                      ,PERIOD_PC IN NUMBER) RETURN NUMBER;

  FUNCTION DEPR_EXPENSE_ADJ_PERFORMULA(ASSET_ID IN NUMBER
                                      ,PERIOD_PC IN NUMBER) RETURN NUMBER;

  FUNCTION CP_CAT_CORP_COST_P RETURN VARCHAR2;

  FUNCTION CP_CAT_ADJ_COST_PER_P RETURN VARCHAR2;

  FUNCTION CP_CAT_ADJ_COST_P RETURN VARCHAR2;

  FUNCTION CP_CAT_CORP_DEPR_RESERVE_P RETURN VARCHAR2;

  FUNCTION CP_CAT_DEPR_RESERVE_ADJ_PER_P RETURN VARCHAR2;

  FUNCTION CP_CAT_ADJ_DEPRN_RESERVE_P RETURN VARCHAR2;

  FUNCTION CP_CAT_CORP_YTD_DEPRN_EXPE_p RETURN VARCHAR2;

  FUNCTION CP_CAT_YTD_DEPRN_EXPENSE_ADJ_ RETURN VARCHAR2;

  FUNCTION CP_CAT_ADJ_YTD_DEPRN_EXPENSE_P RETURN VARCHAR2;

  FUNCTION CP_ASSET_CORP_COST_P RETURN VARCHAR2;

  FUNCTION CP_ASSET_ADJ_COST_PER_P RETURN VARCHAR2;

  FUNCTION CP_ASSET_ADJ_COST_P RETURN VARCHAR2;

  FUNCTION CP_ASSET_CORP_DEPR_RESERVE_P RETURN VARCHAR2;

  FUNCTION CP_ASSET_DEPR_RESERVE_ADJ_P RETURN VARCHAR2;

  FUNCTION CP_ASSET_ADJ_DEPRN_RESERVE_P RETURN VARCHAR2;

  FUNCTION CP_ASSET_CORP_YTD_DEPRN_EXPEN RETURN VARCHAR2;

  FUNCTION CP_ASSET_YTD_DEPR_EXPN_ADJ_PE RETURN VARCHAR2;

  FUNCTION CP_ASSET_YTD_DEPRN_EXPENSE_P RETURN VARCHAR2;

  FUNCTION BOOK_CLASS_P RETURN VARCHAR2;

  FUNCTION DISTRIBUTION_SOURCE_BOOK_P RETURN VARCHAR2;

  FUNCTION CP_REPORT_NAME_P RETURN VARCHAR2;

  FUNCTION CP_COMPANY_NAME_P RETURN VARCHAR2;

  FUNCTION CURRENCY_CODE_P RETURN VARCHAR2;

  FUNCTION CP_PARAM_CURRENCY_P RETURN VARCHAR2;

END JL_JLZZFIJR_XMLP_PKG;



/