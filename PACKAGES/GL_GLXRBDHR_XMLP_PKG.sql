--------------------------------------------------------
--  DDL for Package GL_GLXRBDHR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXRBDHR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXRBDHRS.pls 120.0 2007/12/27 15:03:09 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_LEDGER_ID	number;
	P_ACCESS_SET_ID	number;
	LEDGER_NAME	varchar2(30);
	STRUCT_NUM	number;
	ACCESS_SET_NAME	varchar2(30);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function LEDGER_NAME_p return varchar2;
	Function STRUCT_NUM_p return number;
	Function ACCESS_SET_NAME_p return varchar2;
END GL_GLXRBDHR_XMLP_PKG;


/
