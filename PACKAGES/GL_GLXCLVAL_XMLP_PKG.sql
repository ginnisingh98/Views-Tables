--------------------------------------------------------
--  DDL for Package GL_GLXCLVAL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXCLVAL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXCLVALS.pls 120.0 2007/12/27 14:50:53 vijranga noship $ */
	P_PERIOD_SET	varchar2(15);
	P_PERIOD_TYPE	varchar2(15);
	P_START_YEAR	number;
	P_END_YEAR	number;
	P_CONC_REQUEST_ID	number;
	user_period_type	varchar2(30);
	PREV_PS	varchar2(15);
	PREV_PT	varchar2(15);
	TOTAL_VIOLATIONS	number;
	function first_period_numformula(periodset in varchar2, periodtype in varchar2, first_period_year in number) return number  ;
	--function max_num_periodformula(periodtype in varchar2) return number  ;
	function max_num_periodformula(periodtype1 in varchar2) return number  ;
	function last_cal_yearformula(periodset in varchar2, periodtype in varchar2) return number  ;
	function date_lowformula(periodset in varchar2, periodtype in varchar2) return varchar2  ;
	function date_highformula(periodset in varchar2, periodtype in varchar2) return varchar2  ;
	function first_period_yearformula(periodset in varchar2, periodtype in varchar2, first_period_date in varchar2) return number  ;
	function min_quarter2formula(first_period_year in number, periodset in varchar2, periodtype in varchar2, period_year_qg in number) return number  ;
	function max_quarter2formula(periodset in varchar2, periodtype in varchar2, period_year_qg in number) return number  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function count_violation_qgformula(Num_Miss_Quarter_qg in number, max_quarter_qg in number) return number  ;
	function user_period_typeFormula return VARCHAR2  ;
	--procedure gl_increment_violation_count (num number)  ;
	procedure gl_increment_violation_count (num number , periodset varchar2)  ;
	Function user_period_type_p return varchar2;
	Function PREV_PS_p return varchar2;
	Function PREV_PT_p return varchar2;
	Function TOTAL_VIOLATIONS_p return number;
END GL_GLXCLVAL_XMLP_PKG;


/
