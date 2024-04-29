--------------------------------------------------------
--  DDL for Package PER_PERUSCPE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERUSCPE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERUSCPES.pls 120.0 2007/12/28 06:58:09 srikrish noship $ */
	P_PERSON_ID	number;
	P_QUAL_DATE	date;
	P_SESSION_DATE	date;
	LP_SESSION_DATE	date;
	P_BUSINESS_GROUP_ID	number;
	P_REPORT_TITLE	varchar2(30);
	P_CONC_REQUEST_ID	number;
	C_LETTER_DATE	date;
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_EMPLOYEE_NAME	varchar2(240);
	C_QUALIFYING_DATE	varchar2(14);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_LETTER_DATE_p return date;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_EMPLOYEE_NAME_p return varchar2;
	Function C_QUALIFYING_DATE_p return varchar2;
END PER_PERUSCPE_XMLP_PKG;

/
