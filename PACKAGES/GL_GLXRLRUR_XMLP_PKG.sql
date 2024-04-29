--------------------------------------------------------
--  DDL for Package GL_GLXRLRUR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXRLRUR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXRLRURS.pls 120.0 2007/12/27 15:18:18 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_STRUCT_NUM	number;
	P_SEGMENT_NAME	varchar2(30);
	STRUCT_NUM	varchar2(15);
	COA_NAME	varchar2(30);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function STRUCT_NUM_p return varchar2;
	Function COA_NAME_p return varchar2;
END GL_GLXRLRUR_XMLP_PKG;


/
