--------------------------------------------------------
--  DDL for Package PER_PERUSCNL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERUSCNL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERUSCNLS.pls 120.1 2008/03/12 10:39:50 amakrish noship $ */
	NOT_DATE	date;
	P_PERSON_ID	number;
	P_QUALIFYING_DATE	date;
	P_SESSION_DATE	date;
	LP_SESSION_DATE	date;
	PER_BUSINESS_GROUP_ID	number;
	P_REPORT_TITLE	varchar2(25);
	P_CONC_REQUEST_ID	number;
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_EMPLOYEE_NAME	varchar2(240);
	C_QUALIFYING_DATE	varchar2(14);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_EMPLOYEE_NAME_p return varchar2;
	Function C_QUALIFYING_DATE_p return varchar2;
END PER_PERUSCNL_XMLP_PKG;

/
