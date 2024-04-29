--------------------------------------------------------
--  DDL for Package BEN_BENXAUDT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENXAUDT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: BENXAUDTS.pls 120.1 2007/12/10 08:40:09 vjaganat noship $ */
	P_REQUEST_ID	number;
	P_RECORD_FROM	number;
	P_RECORD_TO	number;
	P_CONC_REQUEST_ID	number;
	g_counter      number := 0;
	procedure get_seq_num;
	function valueformula(ext_rcd_id in number, ext_rslt_dtl_id in number, seq_num in number) return varchar2  ;
	--function business_nameformula(business_group_id in number) return varchar2  ;
	function business_nameformula(p_business_group_id in number) return varchar2  ;
	function BetweenPage return boolean  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END BEN_BENXAUDT_XMLP_PKG;

/
