--------------------------------------------------------
--  DDL for Package BEN_BENXLAYT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENXLAYT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: BENXLAYTS.pls 120.1 2007/12/10 08:41:16 vjaganat noship $ */
	P_EXT_DFN_ID	number;
	P_CONC_REQUEST_ID	number;
	function commentsformula(total_function in varchar2, data_element_type in varchar2, string_value in varchar2, condition_data_element in number, ext_data_element in number, sum_data_element in number) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END BEN_BENXLAYT_XMLP_PKG;

/
