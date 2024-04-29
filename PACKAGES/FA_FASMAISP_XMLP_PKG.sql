--------------------------------------------------------
--  DDL for Package FA_FASMAISP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASMAISP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASMAISPS.pls 120.0.12010000.1 2008/07/28 13:17:01 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	Accounting_Flex_Structure	number;
	Currency_Code	varchar2(15);
	Period1_PC	number;
	Period1_PCD	date;
	Period1_POD	date;
	Period1_FY	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(3):='YES';
	function BookFormula return VARCHAR2  ;
	function Period1Formula return VARCHAR2  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function RP_PERIOD_RANGEFormula return VARCHAR2  ;
	Function Accounting_Flex_Structure_p return number;
	Function Currency_Code_p return varchar2;
	Function Period1_PC_p return number;
	Function Period1_PCD_p return date;
	Function Period1_POD_p return date;
	Function Period1_FY_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
END FA_FASMAISP_XMLP_PKG;


/
