--------------------------------------------------------
--  DDL for Package PO_POXPODDR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXPODDR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXPODDRS.pls 120.2.12010000.2 2014/07/16 02:16:49 shipwu ship $ */
	P_title	varchar2(50);
	P_BUYER	varchar2(40);
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_CREATION_DATE_FROM	date;
	P_CREATION_DATE_TO	date;
	P_CREATION_DATE_FROM1	varchar2(25);
	P_CREATION_DATE_TO1	varchar2(25);
	P_PO_NUM_FROM	varchar2(40);
	P_PO_NUM_TO	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_FLEX_ITEM	varchar2(800);
	P_FLEX_ACC	varchar2(31000);
	P_FAILED_FUNDS	varchar2(1);
	P_ORDERBY	varchar2(40);
	p_qty_precision	number;
	TYPE_LOOKUP_CODE	varchar2(40);
	P_ORDERBY_DISP	varchar2(80);
	P_FAILED_FUNDS_DISP	varchar2(80);
	p_ca_set_of_books_id	number;
	P_mrcsobtype	varchar2(10);
	lp_fin_system_parameters_all	varchar2(50);
	lp_fin_system_parameters	varchar2(50);
	LP_PO_HEADERS	varchar2(50);
	LP_PO_HEADERS_ALL	varchar2(50);
	lp_rcv_transactions	varchar2(50);
	lp_po_distributions	varchar2(50);
	lp_po_distributions_all	varchar2(50);
	lp_rcv_shipment_headers	varchar2(50);
	lp_rcv_receiving_sub_ledger	varchar2(50);
	lp_rcv_sub_ledger_details	varchar2(50);
	where_performance	varchar2(2000);
        where_vendor_performance varchar2(2000); --Bug 18323614
	C_amount_func_sub_round	number;
	C_amount_cur_round	number;
	C_amount_fun_round	number;
	C_amount_func_tot_round	number;
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	function select_failed_f return character  ;
	function where_failed_f return character  ;
	function from_failed_f return character  ;
	function orderby_clauseFormula return VARCHAR2  ;
	procedure get_precision  ;
	function get_dist_func_amount(shipment_type in varchar2, dist_quantity_ordered in number, c_dist_rls_qty in number, unit_price in number, rate in number, order_type_lookup_code in varchar2, dist_amount_ordered in number) return number  ;
	function get_dist_cur_amount(shipment_type in varchar2, dist_quantity_ordered in number, c_dist_rls_qty in number, unit_price in number, order_type_lookup_code in varchar2, dist_amount_ordered in number) return number  ;
	function get_ship_quantity(shipment_type in varchar2, ship_qty_ordered in number, c_ship_rls_qty in number) return number  ;
	function AfterPForm return boolean  ;
	Function C_amount_func_sub_round_p return number;
	Function C_amount_cur_round_p(C_DIST_AMT_CUR in number,PO_CURRENCY_PRECISION in  number) return number;
	Function C_amount_fun_round_p(C_DIST_AMT_FUNC in number,PO_CURRENCY_PRECISION in  number) return number;
	Function C_amount_func_tot_round_p return number;
END PO_POXPODDR_XMLP_PKG;


/
