--------------------------------------------------------
--  DDL for Package AR_RAXILL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RAXILL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RAXILLS.pls 120.0 2007/12/27 14:24:33 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	ACCT_BAL_APROMPT	varchar2(80);
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(300);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
    function D_unit_std_priceFormula(name in varchar2) return VARCHAR2;
END AR_RAXILL_XMLP_PKG;


/
