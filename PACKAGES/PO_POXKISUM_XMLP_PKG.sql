--------------------------------------------------------
--  DDL for Package PO_POXKISUM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXKISUM_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXKISUMS.pls 120.3 2007/12/25 11:02:44 krreddy noship $ */
	P_title	varchar2(52);
	P_CREATION_DATE_FROM	date;
	P_CREATION_DATE_TO	date;
	CP_CREATION_DATE_FROM	varchar2(25);
	CP_CREATION_DATE_TO	varchar2(25);
	P_BUYER	varchar2(240);
	P_CONC_REQUEST_ID	number;
	P_qty_precision	number;
	P_ORDERBY	varchar2(100);
	P_BASE_CURRENCY	varchar2(40);
	P_orderby_displayed	varchar2(80);
	P_SORT	varchar2(100);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function return_amt_saved(C_AMOUNT_LIST1 in number, C_AMOUNT_ACTUAL1 in number) return number  ;
	function orderby_clauseFormula return VARCHAR2  ;
	function return_amt_act(C_quantity in number, Line_price in number, Rate in number) return number  ;
	function return_amt_list(C_min_quote in number, Market_price in number, List in number, C_quantity in number, Rate in number) return number  ;
	function return_type(C_min_quote in number, Quote_code in varchar2, Market_price in number, Market_code in varchar2, List in number, List_code in varchar2) return varchar2  ;
	function return_list(C_min_quote in number, Market_price in number, List in number, Rate in number) return number  ;
	function return_discount(C_AMOUNT_LIST1 in number, C_AMOUNT_ACTUAL1 in number) return number  ;
	function get_quantity(Shipment_quantity in number, Shipment_quantity_cancelled in number, Line_quantity in number) return number  ;
	function round_amount_actual_rep(c_amount_actual_rep in number, c_curr_precision in number) return number  ;
	function round_amount_saved_rep(c_amount_saved_rep in number, c_curr_precision in number) return number  ;
	function round_amount_list_rep(c_amount_list_rep in number, c_curr_precision in number) return number  ;
	function round_amount_list_subtotal_rep(c_amount_list_subtotal in number, c_curr_precision in number) return number  ;
	function round_amount_actual_subtotal(c_amount_actual_subtotal in number, c_curr_precision in number) return number  ;
	function round_amount_saved_subtotal(c_amount_saved_subtotal in number, c_curr_precision in number) return number  ;
	function round_amount_list1(c_amount_list1 in number, c_curr_precision in number) return number  ;
	function round_amount_actual1(c_amount_actual1 in number, c_curr_precision in number) return number  ;
	function round_amount_saved(c_amount_saved in number, c_curr_precision in number) return number  ;
END PO_POXKISUM_XMLP_PKG;


/
