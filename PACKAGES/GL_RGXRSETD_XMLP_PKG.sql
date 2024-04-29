--------------------------------------------------------
--  DDL for Package GL_RGXRSETD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_RGXRSETD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RGXRSETDS.pls 120.0 2007/12/27 15:42:42 vijranga noship $ */
	P_ACCESS_SET_ID	number;
	P_CONC_REQUEST_ID	number;
	P_REPORT_SET_ID	number;
	P_DELIMITER	varchar2(40);
	C_ID_FLEX_CODE	varchar2(4) := 'GLLE' ;
	C_STRUCTURE_ID	number;
	C_INDUSTRY_TYPE	varchar2(1) := 'C' ;
	C_ATTRIBUTE_FLAG	varchar2(1) := 'N' ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	--function f_override_segment(segment varchar)(segment  varchar) return varchar  ;
	function f_override_segment(segment varchar) return varchar  ;
	function c_segment_overrideformula(segment_override1 in varchar2) return char  ;
	Function C_ID_FLEX_CODE_p return varchar2;
	Function C_STRUCTURE_ID_p return number;
	Function C_INDUSTRY_TYPE_p return varchar2;
	Function C_ATTRIBUTE_FLAG_p return varchar2;
END GL_RGXRSETD_XMLP_PKG;


/
