--------------------------------------------------------
--  DDL for Package PO_POXRRCVV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXRRCVV_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXRRCVVS.pls 120.0.12010000.2 2010/06/04 11:23:10 dashah ship $ */
	P_CONC_REQUEST_ID	varchar2(32767);
	P_ORG_ID	varchar2(40);
	P_CURRENCY_CODE	varchar2(15);
	P_EXCHANGE_RATE	number;
	P_SORT_OPTION	varchar2(38);
	P_ITEM_FROM	varchar2(800);
	P_ITEM_TO	varchar2(800);
	P_CATEGORY_SET	number;
	P_CAT_NUM	number;
	P_CAT_FROM	varchar2(800);
	P_CAT_TO	varchar2(800);
	P_ZERO_COST	number;
	P_ORGANIZATION	varchar2(60);
	ROUND_UNIT	number := 1;
	FORMAT_MASK     varchar2(50);
	P_ITEM_SEG	varchar2(2400) := 'MSI.DESCRIPTION||MSI.DESCRIPTION||MSI.DESCRIPTION||MSI.DESCRIPTION||MSI.DESCRIPTION||MSI.DESCRIPTION';
	P_CAT_SEG	varchar2(2400) := 'MC.ATTRIBUTE1||MC.ATTRIBUTE1||MC.ATTRIBUTE1||MC.ATTRIBUTE1||MC.ATTRIBUTE1||MC.ATTRIBUTE1||MC.ATTRIBUTE1||MC.ATTRIBUTE1||MC.ATTRIBUTE1';
	P_ITEM_WHERE	varchar2(2400);
	P_CAT_WHERE	varchar2(2400);
	P_SORT_BY	varchar2(80);
	P_CAT_SET_NAME	varchar2(40);
	P_DETAIL_LEVEL	varchar2(80);
	P_COST_TYPE_ID	number;
	P_DEF_COST_TYPE	number :=1;
	P_COST_TYPE	varchar2(40);
	P_EXT_PREC	number;
	P_qty_precision	number;
	P_ORG_WHERE	varchar2(2400);
	P_RPT_OPTION	number;
	P_CURRENCY_DSP	varchar2(50);
	P_DOCUMENT_TYPE	varchar2(40);
	P_DOCUMENT_TYPE_DISPLAYED	varchar2(80);
	P_sort_option1	number;
	P_ITEM_REVISION	number;
	P_Title	varchar2(60);
	P_sort_header_displayed	varchar2(80);
	P_AS_OF_DATE	varchar2(30);
	P_AS_OF_DATE1	varchar2(30);
	P_ONE_TIME	number;
	P_PERIOD_END	number;
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	function itemcatformula(CATEGORY_PSEG in varchar2) return varchar2  ;
	function comp_avg_unit_price (ITEM_QUANTITY in number, ITEM_TOTAL_PUR_VALUE in number, c_ext_precision in number) return number  ;
	procedure get_precision1  ;
	function total_pur_valueformula(total_purchase_value in number) return number  ;
	function c_quantityformula(quantity in number) return number  ;
	function c_total_pur_valueformula(total_pur_value in number) return number  ;
	function CF_SORT_HEADER_DISPLAYEDFormul return Char  ;
	function CF_cat_range_dispFormula return Char  ;
	function CF_item_range_dispFormula return Char  ;
	function cf_item_cost_dispformula(SORT_COLUMN in varchar2) return char  ;
	function CF_MAIN_DISPFormula return Char  ;
	function CF_REV_DISPFormula return Char  ;
	function CF_CAT_DISPFormula return Char  ;
	function CF_cat_fromFormula return Char  ;
	function CF_cat_toFormula return Char  ;
	function CF_cost_typeFormula return Char  ;
	function CF_currency_dspFormula return Char  ;
	function CF_detail_levelFormula return Char  ;
	function CF_item_fromFormula return Char  ;
	function CF_item_toFormula return Char  ;
	function CF_titleFormula return Char  ;
	function CF_cat_set_nameFormula return Char  ;
	function CF_SORT_DISPFormula return Char  ;
END PO_POXRRCVV_XMLP_PKG;


/
