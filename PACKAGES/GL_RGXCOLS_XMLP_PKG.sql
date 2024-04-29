--------------------------------------------------------
--  DDL for Package GL_RGXCOLS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_RGXCOLS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RGXCOLSS.pls 120.0 2007/12/27 15:31:33 vijranga noship $ */
	P_ACCESS_SET_ID	number;
	P_CONC_REQUEST_ID	number;
	C_STRUCTURE_ID	number;
	C_ID_FLEX_CODE	varchar2(4) := 'GLLE' ;
	C_ATTRIBUTE_FLAG	varchar2(1) := 'N' ;
	C_INDUSTRY_TYPE	varchar2(1) := 'C' ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_STRUCTURE_ID_p return number;
	Function C_ID_FLEX_CODE_p return varchar2;
	Function C_ATTRIBUTE_FLAG_p return varchar2;
	Function C_INDUSTRY_TYPE_p return varchar2;
END GL_RGXCOLS_XMLP_PKG;


/
