--------------------------------------------------------
--  DDL for Package PO_POXKIAGN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXKIAGN_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXKIAGNS.pls 120.2 2007/12/25 11:00:48 krreddy noship $ */
	P_title	varchar2(52);
	P_CONC_REQUEST_ID	number;
	P_START_DATE_FROM	varchar2(40);
	P_START_DATE_TO	varchar2(40);
	P_BUYER	varchar2(40);
	P_FLEX_CAT	varchar2(31000);
	P_qty_precision	number;
	P_ORDERBY	varchar2(40);
	P_ORDERBY_CAT	varchar2(298);
	P_STRUCT_NUM	number;
	LP_STRUCT_NUM	number;
	P_CATEGORY_FROM	varchar2(900);
	P_CATEGORY_TO	varchar2(900);
	P_WHERE_CAT	varchar2(2000) := '1 = 1';
	P_BASE_CURRENCY	varchar2(40);
	P_ORDERBY_DISP	varchar2(80);
	function BeforeReport return boolean  ;
	procedure get_precision  ;
	function get_p_struct_num return boolean  ;
	function orderby_clauseFormula return VARCHAR2  ;
	function return_amt_list(C_min_quote in number, Market_price in number, List in number, C_quantity in number, Rate in number) return number  ;
	function return_amt_saved(C_AMOUNT_LIST in number, C_AMOUNT_ACTUAL in number) return number  ;
	function return_discount(C_AMOUNT_LIST in number, C_AMOUNT_ACTUAL in number) return number  ;
	function return_list(Order_type in varchar2, C_min_quote in number, Market_price in number, List in number, Rate in number) return number  ;
	function return_type(C_min_quote in number, Quote_code in varchar2, Market_price in number, Market_code in varchar2, List in number, List_code in varchar2) return varchar2  ;
	function return_amt_act(C_quantity in number, Line_price in number, Rate in number) return number  ;
	function get_quantity(Shipment_quantity in number, Line_quantity in number) return number  ;
	function AfterReport return boolean  ;
END PO_POXKIAGN_XMLP_PKG;


/
