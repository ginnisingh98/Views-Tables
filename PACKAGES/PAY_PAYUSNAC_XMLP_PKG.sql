--------------------------------------------------------
--  DDL for Package PAY_PAYUSNAC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYUSNAC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYUSNACS.pls 120.0 2007/12/28 06:47:08 srikrish noship $ */
	P_CONC_REQUEST_ID	number;
	P_BUSINESS_GROUP_ID	number;
	P_PAYROLL_ACTION_ID	number;
	P_TOTALS_ONLY	varchar2(32767);
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_PAYROLL_ACTION_NAME	varchar2(150);
	C_CONSOLIDATION_SET_ID	number;
	function BeforeReport return boolean  ;
	function get_address(loc_id in number) return varchar2  ;
	function calc_pnot(amount in number) return number  ;
	function get_cid return number  ;
	function get_pay_act_name
return varchar2  ;
	function cf_bal_nachaformula(c_tot_amt in number) return number  ;
	function AfterReport return boolean  ;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_PAYROLL_ACTION_NAME_p return varchar2;
	Function C_CONSOLIDATION_SET_ID_p return number;
END PAY_PAYUSNAC_XMLP_PKG;

/
