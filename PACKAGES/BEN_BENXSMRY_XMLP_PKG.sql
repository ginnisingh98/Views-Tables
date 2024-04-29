--------------------------------------------------------
--  DDL for Package BEN_BENXSMRY_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENXSMRY_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: BENXSMRYS.pls 120.1 2007/12/10 08:41:48 vjaganat noship $ */
	p_ext_rslt_id	number;
	P_CONC_REQUEST_ID	number;
	function valueformula(ext_rcd_id in number, ext_rslt_dtl_id in number, seq_num in number) return varchar2  ;
	function business_groupformula(p_business_group_id in number) return varchar2  ;
	function total_peopleformula(people_count_dummy in number, error_count_dummy in number) return number  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END BEN_BENXSMRY_XMLP_PKG;

/
