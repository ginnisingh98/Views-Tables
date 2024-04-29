--------------------------------------------------------
--  DDL for Package PAY_PAYRPDTR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYRPDTR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYRPDTRS.pls 120.0 2008/01/11 07:07:26 srikrish noship $ */
	P_STATUS	varchar2(40) := 'ENABLED';
	P_ENABLED_FLAG	varchar2(40) := 'N';
	P_CONC_REQUEST_ID	number;
	CP_COUNT_SHORT_NAME	number;
	CP_STATUS	varchar2(20);
	CP_ENABLED_FLAG	varchar2(20);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function cf_count_short_nameformula(CS_COUNT_SHORT_NAME in number) return number  ;
	function CF_STATUSFormula return Char  ;
	function CF_ENABLED_FLAGFormula return Char  ;
	Function CP_COUNT_SHORT_NAME_p return number;
	Function CP_STATUS_p return varchar2;
	Function CP_ENABLED_FLAG_p return varchar2;
END PAY_PAYRPDTR_XMLP_PKG;

/
