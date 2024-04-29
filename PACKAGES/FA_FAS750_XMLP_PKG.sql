--------------------------------------------------------
--  DDL for Package FA_FAS750_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS750_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS750S.pls 120.0.12010000.1 2008/07/28 13:15:28 appldev ship $ */
	P_BOOK	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	CAT_MAJ_APROMPT	varchar2(222);
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function d_lifeformula(LIFE in number, ADJ_RATE in number, PROD in number) return varchar2  ;
	Function CAT_MAJ_APROMPT_p return varchar2;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	FUNCTION fadolif(life NUMBER,
		adj_rate NUMBER,
		bonus_rate NUMBER,
		prod NUMBER)
RETURN CHAR;
PROCEDURE VERSION ;
END FA_FAS750_XMLP_PKG;


/
