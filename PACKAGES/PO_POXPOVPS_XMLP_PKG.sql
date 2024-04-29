--------------------------------------------------------
--  DDL for Package PO_POXPOVPS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXPOVPS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXPOVPSS.pls 120.2 2008/01/05 15:57:33 dwkrishn noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_CREATION_DATE_FROM	date;
	P_CREATION_DATE_FROM_LP	varchar2(40);
	P_CREATION_DATE_TO	date;
	P_CREATION_DATE_TO_LP	varchar2(40);
	P_VENDOR_TYPE	varchar2(40);
	P_SMALL_BUSINESS	varchar2(1);
	P_MINORITY_OWNED	varchar2(40);
	P_WOMEN_OWNED	varchar2(1);
	P_ORDERBY	varchar2(40);
	P_SMALL_BUSINESS_FLAG	varchar2(40);
	P_BASE_CURRENCY	varchar2(40);
	P_orderby_displayed	varchar2(80);
	LP_orderby_displayed	varchar2(80);
	P_small_business_disp	varchar2(80);
	P_WOMEN_OWNED_DISP	varchar2(80);
	P_minority_owned_disp	varchar2(80);
	C_amount_func_vendor_round	number;
	C_amount_rep_round	number;
	C_amount_func_site_round	number;
	C_amount_func_po_type_round	number;
	C_amount_po_round	number;
	C_amount_functional_round	number;
	C_AMOUNT_WO_ROUND	number;
	C_AMOUNT_SB_ROUND	number;
	C_AMOUNT_MO_ROUND	number;
	function BeforeReport return boolean  ;
	function orderby_clauseFormula return VARCHAR2  ;
	function get_percent_wo(PO_CNT_WO in varchar2, Report_PO_Count in number) return number  ;
	function get_percent_mo(PO_CNT_MO in varchar2, Report_PO_Count in number) return number  ;
	function get_percent_sb(PO_CNT_SB in varchar2, Report_PO_Count in number) return number  ;
	function AfterReport return boolean  ;
	Function C_amount_func_vendor_round_p return number;
	Function C_amount_rep_round_p return number;
	Function C_amount_func_site_round_p return number;
	Function C_amount_func_po_type_round_p return number;
	Function C_amount_po_round_p return number;
	Function C_amount_functional_round_p return number;
	Function C_AMOUNT_WO_ROUND_p return number;
	Function C_AMOUNT_SB_ROUND_p return number;
	Function C_AMOUNT_MO_ROUND_p return number;
END PO_POXPOVPS_XMLP_PKG;


/
