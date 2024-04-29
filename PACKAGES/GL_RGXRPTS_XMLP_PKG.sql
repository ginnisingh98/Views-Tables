--------------------------------------------------------
--  DDL for Package GL_RGXRPTS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_RGXRPTS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RGXRPTSS.pls 120.0 2007/12/27 15:41:33 vijranga noship $ */
	P_ACCESS_SET_ID	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_DELIMITER	varchar2(32767);
	C_STRUCTURE_ID	number;
	C_ID_FLEX_CODE	varchar2(4) := 'GLLE' ;
	C_INDUSTRY_TYPE	varchar2(1) := 'C' ;
	C_ATTRIBUTE_FLAG	varchar2(1) := 'N' ;
	function print_detail (dtl_type in varchar2,
                       pset_id in number) return number  ;
	function print_detail_text (pset_id in number) return number  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function f_override_segment(segment varchar) return char  ;
	function c_segment_overrideformula(segment_override in varchar2) return char  ;
	Function C_STRUCTURE_ID_p return number;
	Function C_ID_FLEX_CODE_p return varchar2;
	Function C_INDUSTRY_TYPE_p return varchar2;
	Function C_ATTRIBUTE_FLAG_p return varchar2;
END GL_RGXRPTS_XMLP_PKG;


/
