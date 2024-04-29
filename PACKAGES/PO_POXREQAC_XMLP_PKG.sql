--------------------------------------------------------
--  DDL for Package PO_POXREQAC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXREQAC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXREQACS.pls 120.1 2007/12/25 11:41:29 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_CREATION_DATE_FROM	date;
	LP_CREATION_DATE_FROM	varchar2(20);
	LP_CREATION_DATE_TO	varchar2(20);
	P_CREATION_DATE_TO	date;
	P_TYPE	varchar2(40);
	P_PREPARER	varchar2(240);
	P_BASE_CURRENCY	varchar2(40);
	P_TYPE_DISPLAYED	varchar2(80);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function round_amount_req(c_amount_req in number, c_currency_precision in number) return number  ;
	function round_amount_sum_req(c_amount_sum_req in number, c_currency_precision in number) return number  ;
	function round_amount_report(c_amount_report in number, c_curr_precision in number) return number  ;
END PO_POXREQAC_XMLP_PKG;


/
