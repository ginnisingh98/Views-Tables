--------------------------------------------------------
--  DDL for Package PO_POXPOEDR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXPOEDR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXPOEDRS.pls 120.1.12010000.2 2013/04/02 04:19:52 ssindhe ship $ */
	P_title	varchar2(52);
	P_CONC_REQUEST_ID	number;
	P_FLEX_ACC	varchar2(31000);
	P_qty_precision	varchar2(40);
	P_ACCOUNT_FROM	varchar2(600);
	P_ACCOUNT_TO	varchar2(600);
	P_COST_CENTER_FROM	varchar2(600);
	P_COST_CENTER_TO	varchar2(600);
	P_ENCUMBRANCE_DATE_FROM	date;
	P_ENCUMBRANCE_DATE_TO	date;
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_WHERE_ACC	varchar2(1500);
	P_STRUCT_NUM	number;
	P_CHART_OF_ACCOUNTS	varchar2(40);
	P_Type	varchar2(32767);
	P_type_displayed	varchar2(80);
	P_ORDERBY_ACC	varchar2(31000);
	P_ACTIVE_ONLY	varchar2(32767);
	CP_PRECISION_PO	number;
  QTY_PRECISION varchar2(100);
	CP_OLD_PO_CUR	varchar2(20);
	CP_PRECISION_BPO	number;
	CP_OLD_BPO_CUR	varchar2(15);
	function BeforeReport return boolean  ;
	procedure get_precision  ;
	function c_amount_chg_accformula(C_AMOUNT_REQ_SUBTOTAL in number, C_AMOUNT_PO_SUBTOTAL in number, C_AMOUNT_BPO_SUBTOTAL in number) return number  ;
	function AfterReport return boolean  ;
	function cost_center(c_cost_center_s in varchar2) return character  ;
	function get_p_struct_num return boolean  ;
	function get_chart_of_accounts_id return boolean  ;
	function c_amount_func_poformula(c_amount_base_po in number, c_currency_base1 in varchar2, c_currency_po in varchar2, rate in number, c_precision in number) return number  ;
	function c_amount_base_poformula(PO_TYPE in varchar2, po_enc_amount_func in number, accrual_flag in varchar2, parent_join_id in number , c_precision in number) return number  ;
	function adjusted_q_orderedformula(po_type in varchar2, p_po_header_id in number, p_po_line_id in number, Parent_join_id in number, quantity_ordered in number) return number  ;
	function c_func_amount_bpoformula(c_base_amount_bpo in number, c_currency_base1 in varchar2, c_currency_po1 in varchar2, rate1 in number, c_precision in number) return number  ;
	Function CP_PRECISION_PO_p return number;
	Function CP_OLD_PO_CUR_p return varchar2;
	Function CP_PRECISION_BPO_p return number;
	Function CP_OLD_BPO_CUR_p return varchar2;
END PO_POXPOEDR_XMLP_PKG;


/
