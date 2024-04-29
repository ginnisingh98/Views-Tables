--------------------------------------------------------
--  DDL for Package FA_FAS720_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS720_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS720S.pls 120.0.12010000.1 2008/07/28 13:15:18 appldev ship $ */
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	CAT_MAJ_RPROMPT	varchar2(222);
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function CAT_MAJ_RPROMPT_p return varchar2;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
END FA_FAS720_XMLP_PKG;


/
