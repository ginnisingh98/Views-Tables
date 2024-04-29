--------------------------------------------------------
--  DDL for Package GL_GLXRLBOL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXRLBOL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXRLBOLS.pls 120.0 2007/12/27 15:11:56 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_LEDGER_ID	number;
	P_BUDGET_ENTITY_ID	varchar2(15);
	P_BUDGET_ENTITY_ID_NEW  varchar2(15);
	P_FLEXDATA	varchar2(800);
	P_ORDERBY	varchar2(400);
	P_DAS_ID	number;
	LEDGER_NAME	varchar2(30);
	ORGNAME	varchar2(25);
	ORGDESC	varchar2(240);
	ORGPASS	varchar2(15);
	STARTDATE	date;
	ENDDATE	date;
	STRUCT_NUM	number;
	budgetary_control_flag	varchar2(1);
	DAS_NAME	varchar2(30);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	FUNCTION gl_get_all_org_id RETURN NUMBER  ;
	Function LEDGER_NAME_p return varchar2;
	Function ORGNAME_p return varchar2;
	Function ORGDESC_p return varchar2;
	Function ORGPASS_p return varchar2;
	Function STARTDATE_p return date;
	Function ENDDATE_p return date;
	Function STRUCT_NUM_p return number;
	Function budgetary_control_flag_p return varchar2;
	Function DAS_NAME_p return varchar2;
END GL_GLXRLBOL_XMLP_PKG;


/
