--------------------------------------------------------
--  DDL for Package PAY_PAYRPBLK1_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYRPBLK1_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYRPBLK1S.pls 120.0 2008/01/11 07:07:02 srikrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_CONC_REQUEST_ID	number;
	P_PAYROLL_ID	number;
	P_EFFECTIVE_DATE	date;
	LP_EFFECTIVE_DATE	date ;
	CP_PAYROLL_NAME	varchar2(80);
	CP_Q1_NO_DATA_FOUND	number;
	CP_Q2_NO_DATA_FOUND	number;
	C_EFFECTIVE_DATE	varchar2(20);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function CF_business_groupFormula return VARCHAR2  ;
	function CF_legislation_codeFormula return VARCHAR2  ;
	function cf_currency_format_maskformula(cf_legislation_code in varchar2) return varchar2  ;
	PROCEDURE set_currency_format_mask  ;
	function P_BUSINESS_GROUP_IDValidTrigge return boolean  ;
	function CF_Q1_data_foundFormula return Number  ;
	function CF_Q2_data_foundFormula return Number  ;
	Function CP_PAYROLL_NAME_p return varchar2;
	Function CP_Q1_NO_DATA_FOUND_p return number;
	Function CP_Q2_NO_DATA_FOUND_p return number;
	Function C_EFFECTIVE_DATE_p return varchar2;
END PAY_PAYRPBLK1_XMLP_PKG;

/
