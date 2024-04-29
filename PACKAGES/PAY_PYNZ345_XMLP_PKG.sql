--------------------------------------------------------
--  DDL for Package PAY_PYNZ345_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYNZ345_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PYNZ345S.pls 120.0 2007/12/13 12:12:19 amakrish noship $ */
	P_Business_Group_ID	number;
	P_REGISTERED_EMPLOYER_ID	number;
	P_PERIOD_END_DATE	date;
	P_CONC_REQUEST_ID	number;
	CP_CURRENCY_FORMAT	varchar2(100);
	CP_CURRENCY_CODE	varchar2(32767);
	CP_PERIOD_START_DATE	date;
	CP_PERIOD_END_DATE	date;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function cf_total_deductionsformula(PAYE_DEDUCTIONS in number, CHILD_SUPPORT_DEDUCTIONS in number, STUDENT_LOAN_DEDUCTIONS in number, SSCWT_DEDUCTIONS in number) return number  ;
	function CF_business_groupFormula return Char  ;
	function CF_registered_employerFormula return VARCHAR2  ;
	Function CP_CURRENCY_FORMAT_p return varchar2;
	Function CP_CURRENCY_CODE_p return varchar2;
	Function CP_PERIOD_START_DATE_p return date;
	Function CP_PERIOD_END_DATE_p return date;
END PAY_PYNZ345_XMLP_PKG;

/
