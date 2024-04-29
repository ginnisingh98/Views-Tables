--------------------------------------------------------
--  DDL for Package GL_GLXDALST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXDALST_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXDALSTS.pls 120.0 2007/12/27 14:53:21 vijranga noship $ */
	P_ACCESS_SET_ID	number;
	P_CONC_REQUEST_ID	number;
	DATA_AS_NAME	varchar2(30);
	DESCRIPTION	varchar2(240);
	COA	varchar2(30);
	CALENDAR	varchar2(15);
	PERIOD_TYPE	varchar2(15);
	--TYPE	varchar2(30);
	L_TYPE	varchar2(30);
	DEFAULT_LEDGER	varchar2(30);
	SECURITY_SEGMENT_CODE	varchar2(1);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function DATA_AS_NAME_p return varchar2;
	Function DESCRIPTION_p return varchar2;
	Function COA_p return varchar2;
	Function CALENDAR_p return varchar2;
	Function PERIOD_TYPE_p return varchar2;
	Function TYPE_p return varchar2;
	Function DEFAULT_LEDGER_p return varchar2;
	Function SECURITY_SEGMENT_CODE_p return varchar2;
END GL_GLXDALST_XMLP_PKG;


/
