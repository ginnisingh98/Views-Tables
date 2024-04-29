--------------------------------------------------------
--  DDL for Package FA_FASPARAS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASPARAS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASPARASS.pls 120.0.12010000.1 2008/07/28 13:17:12 appldev ship $ */
	P_BOOK	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_FROM_ASSET	varchar2(40);
	P_TO_ASSET	varchar2(40);
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
END FA_FASPARAS_XMLP_PKG;


/
