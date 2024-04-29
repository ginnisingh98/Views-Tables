--------------------------------------------------------
--  DDL for Package GL_GLXDFUSR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXDFUSR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXDFUSRS.pls 120.0 2007/12/27 14:57:32 vijranga noship $ */
	P_USER_NAME	varchar2(100);
	P_DEFINITION_TYPE	varchar2(30);
	P_CONC_REQUEST_ID	number;
	ID_COLUMNS	varchar2(200) := 'null, null, null, null, null' ;
	NAME_COLUMN	varchar2(30) := 'user_definition_access_set' ;
	TABLE_NAME	varchar2(30) := 'gl_defas_access_sets' ;
	WHERE_DEFAS	varchar2(300) := 'WHERE 1=1' ;
	DEFINITION_TYPE	varchar2(240);
	ROW_COUNT	number;
	ID_COLUMN1	varchar2(35) := 'NULL' ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	PROCEDURE GL_INCREMENT_COUNT  ;
	Function ID_COLUMNS_p return varchar2;
	Function NAME_COLUMN_p return varchar2;
	Function TABLE_NAME_p return varchar2;
	Function WHERE_DEFAS_p return varchar2;
	Function DEFINITION_TYPE_p return varchar2;
	Function ROW_COUNT_p return number;
	Function ID_COLUMN1_p return varchar2;
END GL_GLXDFUSR_XMLP_PKG;


/
