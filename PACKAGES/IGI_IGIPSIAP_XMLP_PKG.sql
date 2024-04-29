--------------------------------------------------------
--  DDL for Package IGI_IGIPSIAP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IGIPSIAP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGIPSIAPS.pls 120.0.12010000.4 2008/11/11 12:10:58 dramired ship $ */
  P_APPROVAL_GROUP NUMBER;

  P_APPROVER VARCHAR2(100);

  P_FLEXFIELD_FROM VARCHAR2(100);

  P_FLEXFIELD_TO VARCHAR2(100);

  P_CONC_REQUEST_ID NUMBER;

 /* P_FLEXDATA VARCHAR2(1200) := '(SEGMENT1_LOW||''-''||SEGMENT2_LOW||''-''||SEGMENT3_LOW||''-''
  ||SEGMENT4_LOW||''-''||segment5_low||''-''||segment6_low||''-''||segment7_low||''-''
  ||segment8_low||''-''||segment9_low||''-''||segment10_low)';*/
  --bug 7431526
  P_FLEXDATA VARCHAR2(1200) ;
  P_STRUCT_NUM VARCHAR2(15);

  P_WHERE VARCHAR2(600) := '1=1';

  --P_ORDER_FLEX VARCHAR2(298);

  P_OPERAND1 VARCHAR2(15);

  P_SET_OF_BOOKS VARCHAR2(15);

  /*P_FLEXDATA_TO VARCHAR2(1200) := '(segment1_high||''-''||segment2_high||''-''
  ||segment3_high||''-''||segment4_high||''-''||segment5_high||''-''||segment6_high
  ||''-''||segment7_high||''-''||segment8_high||''-''||segment9_high||''-''||segment10_high)';*/
  --bug 7431526
  P_FLEXDATA_TO VARCHAR2(1200);
  P_WHERE1 VARCHAR2(600) := '1=1';
  --bug 7431526
  P_WHERES VARCHAR2(600):='1=1';

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION BEFOREREPORT(P_FLEXFIELD_FROM in out NOCOPY varchar2, P_FLEXFIELD_TO in out NOCOPY varchar2) RETURN BOOLEAN;
  --bug 7431526
  /*FUNCTION CONV_FLEX_HIGH(P_FLEX IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CONV_FLEX_LOW(P_FLEX IN VARCHAR2) RETURN VARCHAR2;*/

  FUNCTION CONV_WHERE(P_FLEXFIELD IN VARCHAR2,P_SEGMENT IN VARCHAR2) RETURN VARCHAR2;

   FUNCTION CONV_WHERE1(P_FLEXFIELD IN VARCHAR2,P_SEGMENT IN VARCHAR2) RETURN VARCHAR2;

END IGI_IGIPSIAP_XMLP_PKG;

/
