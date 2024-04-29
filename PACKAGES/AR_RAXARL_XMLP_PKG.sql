--------------------------------------------------------
--  DDL for Package AR_RAXARL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RAXARL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RAXARLS.pls 120.0 2007/12/27 14:15:09 abraghun noship $ */
	P_conc_request_id	number;
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(100);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
END AR_RAXARL_XMLP_PKG;


/
