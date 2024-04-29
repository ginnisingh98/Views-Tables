--------------------------------------------------------
--  DDL for Package PA_PAXPCTCE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXPCTCE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXPCTCES.pls 120.0 2008/01/02 11:45:02 krreddy noship $ */
	EMPLOYEE_ID	number;
	DATE_LOW	date;
	DATE_HIGH	date;
	DATE_LOW_1	varchar2(25);
	DATE_HIGH_1	varchar2(25);
	INCURRED_ORG	number;
	INC_ROUTING_HISTORY	varchar2(40);
	P_rule_optimizer	varchar2(3);
	P_CONC_REQUEST_ID	number;
	EXP_ID	number;
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_employee_name	varchar2(80);
	C_INCURRED_ORG	varchar2(30);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function c_billable_timeformula(c_hours in number, c_billable_hour in number) return number  ;
	function BeforePForm return boolean  ;
	function AfterPForm return boolean  ;
	function BetweenPage return boolean  ;
	function AfterReport return boolean  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_employee_name_p return varchar2;
	Function C_INCURRED_ORG_p return varchar2;
END PA_PAXPCTCE_XMLP_PKG;

/
