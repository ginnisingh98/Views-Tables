--------------------------------------------------------
--  DDL for Package FA_FASFIADJ_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASFIADJ_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASFIADJS.pls 120.0.12010000.1 2008/07/28 13:16:42 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	Period1_POD	date;
	Period1_PCD	date;
	Period1_FY	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_BAL_LPROMPT	varchar2(50);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function Period1_PCFormula return Number  ;
	function d_lifeformula(LIFE in number, ADJUSTED_RATE in number, BONUS_RATE in number, PRODUCTION in number) return varchar2  ;
	Function Period1_POD_p return date;
	Function Period1_PCD_p return date;
	Function Period1_FY_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_BAL_LPROMPT_p return varchar2;
	--ADDED
	FUNCTION fadolif(life NUMBER,
		adj_rate NUMBER,
		bonus_rate NUMBER,
		prod NUMBER)
RETURN CHAR ;
END FA_FASFIADJ_XMLP_PKG;


/
