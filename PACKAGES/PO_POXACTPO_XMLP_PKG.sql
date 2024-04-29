--------------------------------------------------------
--  DDL for Package PO_POXACTPO_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXACTPO_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXACTPOS.pls 120.2 2008/01/05 11:59:41 dwkrishn noship $ */
	P_title	varchar2(50);
	P_CREATION_DATE_FROM	date;
	P_CREATION_DATE_TO	date;
LP_CREATION_DATE_FROM   varchar2(30);
LP_CREATION_DATE_TO     varchar2(30);
	P_VENDOR	varchar2(240);
	P_BUYER	varchar2(240);
	P_TYPE	varchar2(40);
	P_CONC_REQUEST_ID	number;
	p_qty_precision	number;
	P_ORDERBY	varchar2(40);
	P_BASE_CURRENCY	varchar2(40);
	P_orderby_displayed	varchar2(40);
	P_type_displayed	varchar2(40);
	C_CURRENCY	varchar2(40);
	p_ca_set_of_books_id	number;
	lp_fin_system_parameters	varchar2(50);
	LP_FIN_SYSTEM_PARAMETERS_ALL	varchar2(50);
	LP_PO_HEADERS	varchar2(50):='po_headers';
	lp_po_headers_all	varchar2(50);
	lp_po_distributions	varchar2(50);
	lp_po_distributions_all	varchar2(50);
	lp_rcv_transactions	varchar2(50);
	lp_rcv_shipment_headers	varchar2(50);
	lp_rcv_receiving_sub_ledger	varchar2(50);
	lp_rcv_sub_ledger_details	varchar2(50);
	P_MRCSOBTYPE	varchar2(10);
	P_POH_CREATION_DATE_CLAUSE	varchar2(200);
	P_POR_CREATION_DATE_CLAUSE	varchar2(200);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function orderby_clauseFormula return VARCHAR2  ;
	function round_amount(c_amount in number, c_po_currency_precision in number) return number  ;
	function base_amount_round(c_base_amount in number, c_precision in number) return number  ;
	function AfterPForm return boolean  ;
END PO_POXACTPO_XMLP_PKG;


/
