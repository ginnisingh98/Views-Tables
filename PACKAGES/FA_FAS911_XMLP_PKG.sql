--------------------------------------------------------
--  DDL for Package FA_FAS911_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS911_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS911S.pls 120.0.12010000.1 2008/07/28 13:16:05 appldev ship $ */
	P_CONC_REQUEST_ID	number;
	P_life_in_months	number;
	P_METHOD_CODE	varchar2(12);
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function d_lifeformula(LIFE in number) return varchar2  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
FUNCTION fadolif(life NUMBER,
		adj_rate NUMBER,
		bonus_rate NUMBER,
		prod NUMBER)
RETURN CHAR;
END FA_FAS911_XMLP_PKG;


/
