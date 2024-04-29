--------------------------------------------------------
--  DDL for Package PO_POXPOCOM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXPOCOM_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXPOCOMS.pls 120.0 2008/01/02 07:47:45 dwkrishn noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_PERIOD	varchar2(40);
	P_PO_NUMBER_FROM	varchar2(40);
	P_PO_NUMBER_TO	varchar2(40);
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_BUYER	varchar2(40);
	P_CATEGORY_FROM	varchar2(900);
	P_CATEGORY_TO	varchar2(900);
	P_SORT	varchar2(40);
	P_SORT_1	varchar2(40);
	P_WHERE_CAT	varchar2(2000);
	P_STRUCT_NUM	number;
	P_PERIOD_NUM	number;
	P_orderby_displayed	varchar2(80);
	P_period_year	number;
	P_ALT_ORDERBY_DISPLAYED	varchar2(80);
	function BeforeReport return boolean  ;
	function get_p_struct_num return boolean  ;
	function get_period_num return boolean  ;
	function C_break_headerFormula return VARCHAR2  ;
	function C_other_headerFormula return VARCHAR2  ;
	function c_sum_allformula(C_break_per1 in number, C_break_per2 in number, C_break_per3 in number, C_break_per4 in number, c_precision in number) return number  ;
	function G_periodsGroupFilter return boolean  ;
	function c_break_per1_round(c_break_per1 in number, c_precision in number) return number  ;
	function c_break_per2_round(c_break_per2 in number, c_precision in number) return number  ;
	function c_break_per3_round(c_break_per3 in number, c_precision in number) return number  ;
	function c_break_per4_round(c_break_per4 in number, c_precision in number) return number  ;
	function c_amt_per1_round(c_amount_per1 in number, c_precision in number) return number  ;
	function c_amt_per2_round(c_amount_per2 in number, c_precision in number) return number  ;
	function c_amt_per3_round(c_amount_per3 in number, c_precision in number) return number  ;
	function c_amt_per4_round(c_amount_per4 in number, c_precision in number) return number  ;
	function AfterReport return boolean  ;
END PO_POXPOCOM_XMLP_PKG;


/
