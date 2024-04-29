--------------------------------------------------------
--  DDL for Package PO_POXRVOVS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXRVOVS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXRVOVSS.pls 120.1.12010000.2 2014/05/22 05:42:50 liayang ship $ */
	P_title	varchar2(50);
	P_SITE	varchar2(40);
	P_SHIP_TO	varchar2(40);
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_TRANS_DATE_FROM	date;
	P_TRANS_DATE_TO	date;
	P_RECEIVER	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_FLEX_CAT	varchar2(31000);
	P_FLEX_ITEM	varchar2(800);
	P_qty_precision	number;
	P_SORT	varchar2(40);
	P_STRUCT_NUM	number;
	P_ITEM_STRUCT_NUM	number;
	P_sort_disp	varchar2(80);
	P_org_id	number;
	P_org_displayed	varchar2(60);
        FORMAT_MASK varchar2(100);
  P_WHERE_VD_SITE VARCHAR2(200) := '1=1';
  P_WHERE_ST VARCHAR2(200) := '1=1';
  P_WHERE_VF VARCHAR2(200) := '1=1';
  P_WHERE_VT VARCHAR2(200) := '1=1';
  P_WHERE_TXND_FO VARCHAR2(200) := '1=1';
  P_WHERE_TXND_TO VARCHAR2(200) := '1=1';
  P_WHERE_TXND_FO1 VARCHAR2(200) := '1=1';
  P_WHERE_TXND_TO1 VARCHAR2(200) := '1=1';
  P_WHERE_RCER VARCHAR2(200) := '1=1';
  P_WHERE_RCER1 VARCHAR2(200) := '1=1';
  P_WHERE_ORG VARCHAR2(200) := '1=1';
  P_WHERE_ORG1 VARCHAR2(200) := '1=1';
	function BeforeReport return boolean  ;
	procedure get_precision  ;
	function orderby_clauseFormula return VARCHAR2  ;
	function get_p_struct_num return boolean  ;
	function AfterReport return boolean  ;
	function AFTERPFORM RETURN BOOLEAN;
END PO_POXRVOVS_XMLP_PKG;


/
