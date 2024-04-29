--------------------------------------------------------
--  DDL for Package PO_POXRVRTN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXRVRTN_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXRVRTNS.pls 120.1 2007/12/25 12:20:52 krreddy noship $ */
	P_title	varchar2(50);
	P_SITE	varchar2(40);
	P_SHIP_TO	varchar2(40);
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_TRANS_DATE_FROM	date;
	P_TRANS_DATE_FROM_date date;
	LP_TRANS_DATE_FROM	varchar2(40);
	P_TRANS_DATE_TO	date;
	P_TRANS_DATE_TO_date date;
	LP_TRANS_DATE_TO	varchar2(40);
	P_RECEIVER	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_FLEX_CAT	varchar2(31000);
	P_FLEX_ITEM	varchar2(800);
	P_qty_precision	number;
	QTY_PRECISION  varchar2(100);
	P_SORT	varchar2(40);
	P_STRUCT_NUM	number;
	P_ITEM_STRUCT_NUM	number;
	P_sort_disp	varchar2(80);
	P_ORG_ID	number;
	P_org_displayed	varchar2(60);
	P_CUSTOMER_FROM	varchar2(240);
	P_CUSTOMER_TO	varchar2(240);
	function BeforeReport return boolean  ;
	procedure get_precision  ;
	function orderby_clauseFormula return VARCHAR2  ;
	function get_p_struct_num return boolean  ;
	function document_numberformula(release_number in number, PO_Number in varchar2) return varchar2  ;
	function c_qty_net_rcvdformula(C_qty_received in varchar2, C_qty_corrected in varchar2, C_qty_rtv in varchar2, C_qty_corrected_rtv in varchar2) return number  ;
	function c_qty_rtv_and_correctedformula(C_qty_rtv in varchar2, C_qty_corrected_rtv in varchar2) return number  ;
	function AfterPForm return boolean  ;
	function BeforePForm return boolean  ;
	function BetweenPage return boolean  ;
	function AfterReport return boolean  ;
END PO_POXRVRTN_XMLP_PKG;


/
