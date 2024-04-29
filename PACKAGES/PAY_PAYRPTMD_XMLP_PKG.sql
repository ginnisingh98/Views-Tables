--------------------------------------------------------
--  DDL for Package PAY_PAYRPTMD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYRPTMD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYRPTMDS.pls 120.0 2008/01/11 07:08:44 srikrish noship $ */
	P_ENABLED_FLAG	varchar2(40);
        P_ENABLED_FLAG_1	varchar2(40);
	P_CONC_REQUEST_ID	number;
	CP_COUNT_TABLE_NAME	number;
	CP_ENABLED_FLAG	varchar2(20);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function cf_count_table_nameformula(CS_COUNT_TABLE_NAME in number) return number  ;
	function CF_ENABLED_FLAGFormula return Char  ;
	Function CP_COUNT_TABLE_NAME_p return number;
	Function CP_ENABLED_FLAG_p return varchar2;
END PAY_PAYRPTMD_XMLP_PKG;

/
