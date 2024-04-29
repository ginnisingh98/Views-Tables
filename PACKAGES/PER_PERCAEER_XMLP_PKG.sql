--------------------------------------------------------
--  DDL for Package PER_PERCAEER_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERCAEER_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERCAEERS.pls 120.0 2007/12/28 06:54:04 srikrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	P_SESSION_DATE1 varchar2(240);
	P_REPORT_TITLE	varchar2(60);
	P_CONC_REQUEST_ID	number;
	P_year	varchar2(4);
	P_naic_code	varchar2(32767);
	P_DATE_ALL_EMP	varchar2(21);
	P_DATE_TMP_EMP	varchar2(21);
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_REPORT_SUBTITLE	varchar2(60);
	function BeforeReport return boolean  ;
	function CF_f5_n_promptFormula return Char  ;
	function cf_f5_n_totalformula(f4_n_type in varchar2) return number  ;
	function cf_f5_n_totmaformula(f4_n_type in varchar2) return number  ;
	function cf_f5_n_totfeformula(f4_n_type in varchar2) return number  ;
	function cf_f5_n_totabformula(f4_n_type in varchar2) return number  ;
	function cf_f5_n_maabformula(f4_n_type in varchar2) return number  ;
	function cf_f5_n_feabformula(f4_n_type in varchar2) return number  ;
	function cf_f5_n_totviformula(f4_n_type in varchar2) return number  ;
	function cf_f5_n_maviformula(f4_n_type in varchar2) return number  ;
	function cf_f5_n_feviformula(f4_n_type in varchar2) return number  ;
	function cf_f5_n_totdiformula(f4_n_type in varchar2) return number  ;
	function cf_f5_n_madiformula(f4_n_type in varchar2) return number  ;
	function cf_f5_n_fediformula(f4_n_type in varchar2) return number  ;
	function cf_f5_p_totalformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number  ;
	function cf_f5_p_totmaformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number  ;
	function cf_f5_p_totfeformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number  ;
	function cf_f5_p_totabformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number  ;
	function cf_f5_p_maabformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number  ;
	function cf_f5_p_feabformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number  ;
	function cf_f5_p_totdiformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number  ;
	function cf_f5_p_madiformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number  ;
	function cf_f5_p_fediformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number  ;
	function cf_f5_p_totviformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number  ;
	function cf_f5_p_maviformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number  ;
	function cf_f5_p_feviformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number  ;
	function CF_f5_p_promptFormula return Char  ;
	function AfterReport return boolean  ;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
END PER_PERCAEER_XMLP_PKG;

/
