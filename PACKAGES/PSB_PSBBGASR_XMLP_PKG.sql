--------------------------------------------------------
--  DDL for Package PSB_PSBBGASR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_PSBBGASR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PSBBGASRS.pls 120.1 2008/02/22 07:59:08 vijranga noship $ */
  P_SET_OF_BOOKS_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER := 0;

  P_BUDGET_GROUP_ID NUMBER;

  P_PRINT_SUBGROUPS_FLAG VARCHAR2(1);

  CP_FLEXDATA_HIGH VARCHAR2(1000) := '(lines.segment1_high || ''\n'' ||
  lines.segment2_high || ''\n'' || lines.segment3_high || ''\n'' ||
  lines.segment4_high || ''\n'' || lines.segment5_high || ''\n'' ||
  lines.segment6_high || ''\n'' || lines.segment7_high || ''\n'' ||
  lines.segment8_high || ''\n'' || lines.segment9_high || ''\n'' ||
  lines.segment10_high || ''\n'' || lines.segment11_high || ''\n'' ||
  lines.segment12_high || ''\n'' || lines.segment13_high || ''\n'' ||
  lines.segment14_high || ''\n'' || lines.segment15_high || ''\n'' ||
  lines.segment16_high || ''\n'' || lines.segment17_high || ''\n'' ||
  lines.segment18_high || ''\n'' || lines.segment19_high || ''\n'' || lines.segment20_high || ''\n'' ||
  lines.segment21_high || ''\n'' || lines.segment22_high || ''\n'' || lines.segment23_high || ''\n'' ||
  lines.segment24_high || ''\n'' || lines.segment25_high || ''\n'' || lines.segment26_high || ''\n'' ||
  lines.segment27_high || ''\n'' || lines.segment28_high || ''\n'' || lines.segment29_high || ''\n'' ||
  lines.segment30_high)';

  CP_FLEXDATA_LOW VARCHAR2(1000) := '(lines.segment1_low || ''\n'' || lines.segment2_low || ''\n'' ||
lines.segment3_low || ''\n'' || lines.segment4_low || ''\n'' || lines.segment5_low || ''\n'' ||
lines.segment6_low || ''\n'' || lines.segment7_low || ''\n'' || lines.segment8_low || ''\n'' ||
lines.segment9_low || ''\n'' || lines.segment10_low || ''\n'' || lines.segment11_low || ''\n'' ||
lines.segment12_low || ''\n'' || lines.segment13_low || ''\n'' || lines.segment14_low || ''\n'' ||
lines.segment15_low || ''\n'' || lines.segment16_low || ''\n'' || lines.segment17_low || ''\n'' ||
lines.segment18_low || ''\n'' || lines.segment19_low || ''\n'' || lines.segment20_low || ''\n'' ||
lines.segment21_low || ''\n'' || lines.segment22_low || ''\n'' || lines.segment23_low || ''\n'' ||
lines.segment24_low || ''\n'' || lines.segment25_low || ''\n'' || lines.segment26_low || ''\n'' ||
lines.segment27_low || ''\n'' || lines.segment28_low || ''\n'' || lines.segment29_low || ''\n'' ||
lines.segment30_low)';

  P_STRUCT_NUM NUMBER := 101;

  CP_SET_OF_BOOKS_NAME VARCHAR2(30);

  CP_BUDGET_GROUP_NAME VARCHAR2(80);

  CP_PRINT_SUBGROUPS VARCHAR2(80);

  CP_NO_DATA_FOUND VARCHAR2(50);

  CP_END_OF_REPORT VARCHAR2(50);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION CF_FLEXFIELD_HIGHFORMULA(COA_ID IN NUMBER
                                   ,FLEXDATA_HIGH IN VARCHAR2
                                   ,CF_FLEXFIELD_HIGH IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CF_FLEXFIELD_LOWFORMULA(COA_ID IN NUMBER
                                  ,FLEXDATA_LOW IN VARCHAR2
                                  ,CF_FLEXFIELD_LOW IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CF_USER_EXIT_DUMMYFORMULA(COA_ID IN NUMBER) RETURN NUMBER;

  FUNCTION BETWEENPAGE RETURN BOOLEAN;

  FUNCTION CP_FLEXDATA_HIGH_P RETURN VARCHAR2;

  FUNCTION CP_FLEXDATA_LOW_P RETURN VARCHAR2;

  FUNCTION P_STRUCT_NUM_P RETURN NUMBER;

  FUNCTION CP_SET_OF_BOOKS_NAME_P RETURN VARCHAR2;

  FUNCTION CP_BUDGET_GROUP_NAME_P RETURN VARCHAR2;

  FUNCTION CP_PRINT_SUBGROUPS_P RETURN VARCHAR2;

  FUNCTION CP_NO_DATA_FOUND_P RETURN VARCHAR2;

  FUNCTION CP_END_OF_REPORT_P RETURN VARCHAR2;

END PSB_PSBBGASR_XMLP_PKG;







/
