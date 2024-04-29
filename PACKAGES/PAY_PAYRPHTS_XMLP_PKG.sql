--------------------------------------------------------
--  DDL for Package PAY_PAYRPHTS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYRPHTS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYRPHTSS.pls 120.0 2008/01/11 07:08:18 srikrish noship $ */
	P_DETAIL	varchar2(40);
        P_DETAIL_1 varchar2(40);
	P_STATUS	varchar2(40);
	P_STATUS_1	varchar2(40);
	P_CONC_REQUEST_ID	number;
	CP_COUNT_TRIGGER_NAME	number;
	CP_STATUS	varchar2(20);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function cf_count_trigger_nameformula(CS_COUNT_TRIGGER_NAME in number) return number  ;
	function CF_ENABLED_FLAGFormula return Char  ;
	Function CP_COUNT_TRIGGER_NAME_p return number;
	Function CP_STATUS_p return varchar2;
END PAY_PAYRPHTS_XMLP_PKG;

/
