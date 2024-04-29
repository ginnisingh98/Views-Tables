--------------------------------------------------------
--  DDL for Package FA_FASLSPRC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASLSPRC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASLSPRCS.pls 120.0.12010000.1 2008/07/28 13:16:54 appldev ship $ */
	P_FY_YEAR_NAME	varchar2(30);
	P_CONC_REQUEST_ID	number;
	P_FY_YEAR	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_START_DATE	date;
	RP_END_DATE	date;
	RP_DATA_FOUND	varchar2(3);
	function report_nameformula(Company_Name in varchar2, START_DATE in date, END_DATE in date) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function G_PRO_CONVGroupFilter return boolean  ;
	function G_PRO_DATESGroupFilter return boolean  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_START_DATE_p return date;
	Function RP_END_DATE_p return date;
	Function RP_DATA_FOUND_p return varchar2;
END FA_FASLSPRC_XMLP_PKG;


/
