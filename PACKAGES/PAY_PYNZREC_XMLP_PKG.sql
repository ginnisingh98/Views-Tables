--------------------------------------------------------
--  DDL for Package PAY_PYNZREC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYNZREC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PYNZRECS.pls 120.0 2007/12/13 12:12:43 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SORT_ORDER	varchar2(250);
	P_PAYROLL_ACTION_ID	varchar2(40);
	P_CONC_REQUEST_ID	number;
	CP_input_value_name	varchar2(30);
	CP_UOM	varchar2(30);
	CP_report_name	varchar2(8);
	function AfterReport return boolean  ;
	function CF_business_groupFormula return VARCHAR2  ;
	function CF_payroll_run_displayFormula return VARCHAR2  ;
	function CP_input_value_nameFormula return VARCHAR2  ;
	function CP_UOMFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function CF_legislation_codeFormula return VARCHAR2  ;
	function CF_sort_order_displayFormula return VARCHAR2  ;
	function cf_currency_format_maskformula(cf_legislation_code in varchar2) return varchar2  ;
	function CP_report_nameFormula return VARCHAR2  ;
	Function CP_input_value_name_p return varchar2;
	Function CP_UOM_p return varchar2;
	Function CP_report_name_p return varchar2;
END PAY_PYNZREC_XMLP_PKG;

/
