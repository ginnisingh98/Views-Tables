--------------------------------------------------------
--  DDL for Package PAY_PAYKRSPL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYKRSPL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYKRSPLS.pls 120.0 2007/12/13 12:11:55 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_CONC_REQUEST_ID	number;
	P_SELECTION_DATE	varchar2(40);
	P_SORT_BY	varchar2(50);
--	P_SELECTION_VALUE	varchar2(50);
	P_SELECTION_VALUE	varchar2(50):='COST_CENTER';
	P_PAYROLL_ID	varchar2(40);
	P_ESTABLISHMENT_ID	number;
	frame_counter number:=0;
        total         number:=0;
        assignment_id number:=0;
	CP_Unit	varchar2(50);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function CF_business_groupFormula return VARCHAR2  ;
	function CF_legislation_codeFormula return VARCHAR2  ;
	function cf_currency_format_maskformula(cf_legislation_code in varchar2) return varchar2  ;
	PROCEDURE set_currency_format_mask  ;
	function P_BUSINESS_GROUP_IDValidTrigge return boolean  ;
	function CF_PERIOD_NAMEFormula return Char  ;
	function BetweenPage return boolean  ;
	function cf_average_salaryformula(average_salary_me in number, average_salary_ybon in number, average_salary_alr in number) return number  ;
	function CF_DATE_FORMAT_MASKFormula return Char  ;
	function cf_page_totalformula(cs_total in number) return number  ;
	function cf_separation_payformula(separation_pay in number, liability_rate in varchar2) return number  ;
	function cf_format_working_periodformul(working_period in varchar2, proportion in number, assignment_id_1 in number) return char  ;
	Function CP_Unit_p return varchar2;
END PAY_PAYKRSPL_XMLP_PKG;

/
