--------------------------------------------------------
--  DDL for Package PAY_PYKRSSEL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYKRSSEL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PYKRSSELS.pls 120.0 2007/12/13 12:12:07 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_CONC_REQUEST_ID	number;
	P_Selection_criteria	varchar2(50);
	P_SELECTION_DATE	varchar2(15);
--	Group	varchar2(40);
	P_SUMMARY_DETAIL	number;
	P_PARAMETER_NAME	varchar2(30);
	P_PARAMETER_VALUE	varchar2(30):='cost_center';
	P_PERIOD_NAME	varchar2(50);
	P_PAYROLL	number;
	CP_unit	varchar2(20);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function CF_business_groupFormula return VARCHAR2  ;
	function CF_legislation_codeFormula return VARCHAR2  ;
	function cf_currency_format_maskformula(cf_legislation_code in varchar2) return varchar2  ;
	PROCEDURE set_currency_format_mask  ;
	function cf_average_sep_payformula(cs_sep_pay in number, cs_no_of_emp in number) return number  ;
	function cf_average_working_periodformu(cs_work_period in number, cs_no_of_emp in number) return number  ;
	function cf_end_of_reportformula(cs_average_Salary in number) return char  ;
	function cf_average_payment_daysformula(cs_pay_days in number, cs_no_of_emp in number) return number  ;
	function AfterPForm return boolean  ;
	function CF_PERIOD_NAMEFormula return Char  ;
	Function CP_unit_p return varchar2;
END PAY_PYKRSSEL_XMLP_PKG;

/
