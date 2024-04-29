--------------------------------------------------------
--  DDL for Package FA_FAS828_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS828_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS828S.pls 120.0.12010000.1 2008/07/28 13:15:49 appldev ship $ */
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_FEEDER_SYSTEM	varchar2(40);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function currency_codeformula(BOOK in varchar2) return varchar2  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_FEEDER_SYSTEM_p return varchar2;
--Added during DT Fix
        Function D_COSTFormula(FEEDER_SYSTEM in varchar2) return varchar2;
--End of DT Fix
END FA_FAS828_XMLP_PKG;


/
