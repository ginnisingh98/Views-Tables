--------------------------------------------------------
--  DDL for Package PAY_PYGBNSEX_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYGBNSEX_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PYGBNSEXS.pls 120.2 2007/12/27 05:28:27 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_TAX_REF	varchar2(14);
	P_PAYROLL_ID	number;
	P_EFFECTIVE_DATE	date;
	/* added as fix */
	P_EFFECTIVE_DATE_T date;
	P_STARTERS_FROM	date;
		CP_EFFECTIVE_DATE_T date;
		CP_STARTERS_FROM	date;
	P_CONC_REQUEST_ID	number;
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_ORDER_BY	varchar2(30) := 'last_name' ;
	C_HEAD_ORDER_BY	varchar2(30);
	C_PAYROLL_NAME	varchar2(80);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_ORDER_BY_p return varchar2;
	Function C_HEAD_ORDER_BY_p return varchar2;
	Function C_PAYROLL_NAME_p return varchar2;
END PAY_PYGBNSEX_XMLP_PKG;

/
