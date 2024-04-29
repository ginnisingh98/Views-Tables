--------------------------------------------------------
--  DDL for Package PA_PAXAUMTC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXAUMTC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXAUMTCS.pls 120.0 2008/01/02 11:18:57 krreddy noship $ */
	EMPLOYEE_ID	number;
	DATE_LO	date;
	DATE_HI	date;
	INCURRED_ORG	number;
	SUPERVISOR	number;
	P_Debug_mode	varchar2(3);
	P_CONC_REQUEST_ID	number;
	P_rule_optimizer	varchar2(3);
	where_stmt	varchar2(32766);
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_employee_name	varchar2(40);
	C_date_lo	varchar2(40);
	C_date_hi	varchar2(40);
	C_incurred_org	varchar2(30);
	C_supervisor	varchar2(30);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function AfterReport return boolean  ;
	function AfterPForm return boolean  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_employee_name_p return varchar2;
	Function C_date_lo_p return date;
	Function C_date_hi_p return date;
	Function C_incurred_org_p return varchar2;
	Function C_supervisor_p return varchar2;
END PA_PAXAUMTC_XMLP_PKG;

/
