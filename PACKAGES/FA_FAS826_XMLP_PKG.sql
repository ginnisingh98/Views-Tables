--------------------------------------------------------
--  DDL for Package FA_FAS826_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS826_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS826S.pls 120.0.12010000.1 2008/07/28 13:15:47 appldev ship $ */
	P_BATCH_ID	number;
	P_CONC_REQUEST_ID	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(3);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function d_statusformula(STATUS in varchar2) return varchar2  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
END FA_FAS826_XMLP_PKG;


/
