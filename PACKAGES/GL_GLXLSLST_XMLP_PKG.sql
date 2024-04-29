--------------------------------------------------------
--  DDL for Package GL_GLXLSLST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXLSLST_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXLSLSTS.pls 120.0 2007/12/27 15:00:48 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_LEDGER_ID	number;
	C_CALENDAR	varchar2(15);
	C_PERIOD_TYPE	varchar2(20);
	C_STRUCT_NUM	number;
	C_DESCRIPTION	varchar2(240);
	C_COA_NAME	varchar2(40);
	C_LEDGER_SET_NAME	varchar2(30);
	C_LANGUAGE	varchar2(100);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_CALENDAR_p return varchar2;
	Function C_PERIOD_TYPE_p return varchar2;
	Function C_STRUCT_NUM_p return number;
	Function C_DESCRIPTION_p return varchar2;
	Function C_COA_NAME_p return varchar2;
	Function C_LEDGER_SET_NAME_p return varchar2;
	Function C_LANGUAGE_p return varchar2;
END GL_GLXLSLST_XMLP_PKG;



/
