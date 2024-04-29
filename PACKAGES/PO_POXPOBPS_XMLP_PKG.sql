--------------------------------------------------------
--  DDL for Package PO_POXPOBPS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXPOBPS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXPOBPSS.pls 120.2 2007/12/25 11:09:22 krreddy noship $ */
	P_title	varchar2(50);
	P_qty_precision	number;
	QTY_PRECISION VARCHAR2(100);
	P_PO_NUM_FROM	varchar2(40);
	P_PO_NUM_TO	varchar2(40);
	P_BUYER	varchar2(240);
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_CATEGORY_FROM	varchar2(900);
	P_EXPIRATION_DATE	date;
	P_FLEX_ITEM	varchar2(800);
	P_CONC_REQUEST_ID	number;
	P_CATEGORY_TO	varchar2(900);
	P_WHERE_CAT	varchar2(2000);
	P_FLEX_CAT	varchar2(31000);
	P_STRUCT_NUM	number;
	P_ORDERBY	varchar2(200);
	P_ITEM_STRUCT_NUM	varchar2(40);
	P_ORDERBY_DISPLAYED	varchar2(80);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	procedure get_precision  ;
	function orderby_clauseFormula return VARCHAR2  ;
	function get_p_struct_num return boolean  ;
	function cur_planned_amt_agreed(PO_type in varchar2, po_header_id1 in number) return number  ;
	function cur_planned_amt_released(PO_type in varchar2, PO_HEADER_ID1 in number) return number  ;
	function c_amount_rel(po_header_id1 in number) return number  ;
	function c_amount_rem(po_header_id1 in number) return number  ;
	function c_po_relformula(global_agreement_flag in varchar2, std_po in varchar2, Release in number) return char  ;
	function c_org_nameformula(po_org_id in number, global_agreement_flag in varchar2) return char  ;
END PO_POXPOBPS_XMLP_PKG;


/
