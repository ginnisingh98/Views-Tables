--------------------------------------------------------
--  DDL for Package AP_APXSOBLX_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXSOBLX_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXSOBLXS.pls 120.0 2007/12/27 08:31:04 vjaganat noship $ */
	P_as_of_date	date;
	p_as_of_date_1 VARCHAR2(10);
	P_REFERENCE_NUMBER	varchar2(30);
	P_CONC_REQUEST_ID	number;
	P_CURRENCY	varchar2(3);
	P_SUPPLIER_NAME_FROM	varchar2(240);
	P_SUPPLIER_NAME_TO	varchar2(240);
	P_MIN_INVOICE_BALANCE	number;
	P_MIN_OPEN_BALANCE	number;
	P_INCLUDE_PREPAYMENTS	varchar2(3);
	P_DEBUG_FLAG	varchar2(3);
	P_TRACE_FLAG	varchar2(3);
	P_SET_OF_BOOKS_ID	number;
	function cf_cur_totalformula(c_inv_total in number, c_prepay_total in number) return number  ;
	function CF_as_of_date_displayFormula return char  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function cf_displayformula(CF_cur_total in number) return number  ;
END AP_APXSOBLX_XMLP_PKG;


/
