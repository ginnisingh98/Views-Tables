--------------------------------------------------------
--  DDL for Package PAY_PYGBNICV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYGBNICV_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PYGBNICVS.pls 120.2 2007/12/27 05:27:48 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	P_REPORT_TITLE	varchar2(60);
	P_CONC_REQUEST_ID	number;
	P_SORT_ORDER	varchar2(40);
	P_PAYROLL_NAME	varchar2(40);
	P_CONSOLIDATION_SET	varchar2(40);
	P_ASSIGNMENT_SET	varchar2(40);
	P_EFFECTIVE_DATE	date;
	LP_EFFECTIVE_DATE  date;
	P_SORT	varchar2(40);
	P_EFFECTIVE_START_DATE	varchar2(40);
	C_BUSINESS_GROUP_NAME	varchar2(60);
	C_REPORT_SUBTITLE	varchar2(60);
	C_PAYROLL_NAME	varchar2(30);
	C_CONSOLIDATION_SET	varchar2(30);
	C_ASSIGNMENT_SET	varchar2(30);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function C_PAYROLL_NAME_p return varchar2;
	Function C_CONSOLIDATION_SET_p return varchar2;
	Function C_ASSIGNMENT_SET_p return varchar2;
END PAY_PYGBNICV_XMLP_PKG;

/
