--------------------------------------------------------
--  DDL for Package PO_POXCONST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXCONST_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXCONSTS.pls 120.1 2007/12/25 10:50:06 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_FLEX_ITEM	varchar2(800);
	P_FLEX_CAT	varchar2(3100);
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_PO_NUMBER_FROM	varchar2(40);
	P_PO_NUMBER_TO	varchar2(40);
	P_qty_precision	number;
	QTY_PRECISION  varchar2(100);
	P_ORDERBY_CAT	varchar2(298);
	P_ORDERBY_ITEM	varchar2(298);
	P_ORDERBY	varchar2(40);
	P_STRUCT_NUM	number;
	CONTRACT_RATE	varchar2(40);
	P_orderby_displayed	varchar2(80);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	procedure get_precision  ;
	function orderby_clauseFormula return VARCHAR2  ;
	function get_p_struct_num return boolean  ;
	function c_sum_contract_round(C_SUM_CONTRACT in number, C_PRECISION in number) return number  ;
	function c_amount_round(C_AMOUNT in number, C_PRECISION in number) return number  ;
	function c_total_po_amount_round(C_TOTAL_PO_AMOUNT in number, C_PRECISION in number) return number  ;
	function c_amount_1_round(c_amount_1 in number, c_precision in number) return number  ;
	function c_unit_price_roundformula(UNIT_PRICE in varchar2, C_EXTENDED_PRECISION in number) return number  ;
END PO_POXCONST_XMLP_PKG;


/
