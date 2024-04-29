--------------------------------------------------------
--  DDL for Package FA_FASPRX_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASPRX_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASPRXS.pls 120.0.12010000.1 2008/07/28 13:17:20 appldev ship $ */
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
END FA_FASPRX_XMLP_PKG;


/
