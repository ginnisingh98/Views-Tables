--------------------------------------------------------
--  DDL for Package GL_GLXDFLST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXDFLST_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXDFLSTS.pls 120.0 2007/12/27 14:56:29 vijranga noship $ */
	P_DEFAS_ID	number;
	P_DEFINITION_TYPE	varchar2(30);
	P_CONC_REQUEST_ID	number;
	DEFAS_NAME	varchar2(100);
	DEFAS_DESCRIPTION	varchar2(240);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function DEFAS_NAME_p return varchar2;
	Function DEFAS_DESCRIPTION_p return varchar2;
END GL_GLXDFLST_XMLP_PKG;


/
