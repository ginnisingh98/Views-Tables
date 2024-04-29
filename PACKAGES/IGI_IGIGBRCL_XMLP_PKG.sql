--------------------------------------------------------
--  DDL for Package IGI_IGIGBRCL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IGIGBRCL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGIGBRCLS.pls 120.0.12010000.1 2008/07/29 08:58:06 appldev ship $ */
  P_SOB VARCHAR2(40);

  P_CONC_REQUEST_ID NUMBER;

  P_STRUCT_NUM VARCHAR2(15);

  P_DEBUG_SWITCH VARCHAR2(1);

  P_RUN_AOL VARCHAR2(1);

  CP_FLEX_LOW VARCHAR2(1000) := 'segment1_low||''-''||segment2_low||''-''||segment3_low||''-''||
  segment4_low||''-''||segment5_low||''-''||segment6_low||''-''||segment7_low||''-''||segment8_low||
  ''-''||segment9_low||''-''||segment10_low||''-''||segment11_low||''-''||segment12_low||''-''||
  segment13_low||''-''||segment14_low||''-''||segment15_low||''-''||segment16_low||''-''||
  segment17_low||''-''||segment18_low||''-''||segment19_low||''-''||segment20_low||''-''||
  segment21_low||''-''||segment22_low||''-''||segment23_low||''-''||segment24_low||''-''||
  segment25_low||''-''||segment26_low||''-''||segment27_low||''-''||segment28_low||''-''||
  segment29_low||''-''||segment30_low';

  CP_FLEX_HIGH VARCHAR2(1000) := 'segment1_high||''-''||segment2_high||''-''||
  segment3_high||''-''||segment4_high||''-''||segment5_high||''-''||segment6_high
  ||''-''||segment7_high||''-''||segment8_high||''-''||segment9_high||''-''||
  segment10_high||''-''||segment11_high||''-''||segment12_high||''-''||
  segment13_high||''-''||segment14_high||''-''||segment15_high||''-''||
  segment16_high||''-''||segment17_high||''-''||segment18_high||''-''||
  segment19_high||''-''||segment20_high||''-''||segment21_high||''-''||
  segment22_high||''-''||segment23_high||''-''||segment24_high||''-''||
  segment25_high||''-''||segment26_high||''-''||segment27_high||''-''||
  segment28_high||''-''||segment29_high||''-''||segment30_high';

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION CF_FLEX_HIGHFORMULA(HIGH_RANGE IN VARCHAR2
                              ,CF_FLEX_HIGH IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CF_FLEX_LOWFORMULA(LOW_RANGE IN VARCHAR2
                             ,CF_FLEX_LOW IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CP_FLEX_LOW_P RETURN VARCHAR2;

  FUNCTION CP_FLEX_HIGH_P RETURN VARCHAR2;

END IGI_IGIGBRCL_XMLP_PKG;

/
