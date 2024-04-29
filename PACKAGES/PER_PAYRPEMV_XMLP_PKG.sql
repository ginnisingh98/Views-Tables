--------------------------------------------------------
--  DDL for Package PER_PAYRPEMV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PAYRPEMV_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYRPEMVS.pls 120.1 2007/12/06 11:24:44 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	P_REPORT_TITLE	varchar2(60);
	P_CONC_REQUEST_ID	number;
	P_ORG_STRUCTURE_ID	number;
	P_ORG_STRUCTURE_VERSION_ID	number;
	P_PARENT_ORGANIZATION_ID	number;
	P_DATE_FROM	date;
	P_DATE_TO	date;
	P_DATE_FROM_T varchar2(25);
	P_DATE_TO_T varchar2(25);
	P_PAYROLL_ID	number;
	P_PAYROLL_PERIOD_ID	number;
	P_ORG_MATCHING	varchar2(500);
	P_PAYROLL_MATCHING	varchar2(500);
	P_DATES_MATCHING	varchar2(500);
	P_DATES_MATCHING2	varchar2(500);
	--P_DATES_MATCHING3	varchar2(500); Commented during DT Fix
	--P_DATES_MATCHING4	varchar2(500); Commented during DT Fix
	--P_DATES_MATCHING5	varchar2(500); Commented during DT Fix
        P_DATES_MATCHING3	varchar2(500) := 'is not null';
        P_DATES_MATCHING4	varchar2(500) := '''12314712''';
        P_DATES_MATCHING5	varchar2(500) := '''12314712''';
	P_EMPLOYEE_DETAIL	varchar2(50);
	P_EMP_ORD_CLAUSE	varchar2(150);
	P_ORG_MATCHING2	varchar2(500);
	P_ORG_MATCHING3	varchar2(500);
	P_PAYROLL_MATCHING2	varchar2(500);
	P_PAYROLL_MATCHING3	varchar2(500);
	P_TRACE	varchar2(32767);
	P_worker_type	varchar2(100) := 'E';
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_REPORT_SUBTITLE	varchar2(60);
	C_ORG_STRUCTURE_NAME	varchar2(80);
	C_VERSION_NUMBER	number;
	C_PARENT_ORGANIZATION_NAME	varchar2(240);
	C_PAYROLL_NAME	varchar2(80);
	C_PAYROLL_PERIOD	varchar2(80);
	C_emp_det_param_disp	varchar2(80);
	CP_worker_type_desc	varchar2(80);
	CP_total_emp_newhire	number := 0 ;
	CP_total_cwk_newhire	number := 0 ;
	CP_total_emp_term	number := 0 ;
	CP_total_cwk_term	number := 0 ;
	CP_total_emp_transin	number := 0 ;
	CP_total_cwk_transin	number := 0 ;
	CP_total_emp_transout	number := 0 ;
	CP_total_cwk_transout	number := 0 ;
	function BeforeReport return boolean  ;
	function c_net_changeformula(c_new_hires_count in number, c_transfers_in in number, c_terminations_count in number, c_transfers_out in number) return varchar2  ;
	function C_sql_traceFormula return VARCHAR2  ;
	function TRACEFormula return VARCHAR2  ;
	function cf_control_total_newhireformul(new_hire_asg_type in varchar2, assignment_type in varchar2) return number  ;
	function cf_control_total_termformula(term_asg_type in varchar2) return number  ;
	function cf_control_total_transinformul(trans_ex_asg_type in varchar2) return number  ;
	function cf_control_total_transoutformu(transout_ex_asg_type in varchar2) return number  ;
	function AfterReport return boolean  ;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function C_ORG_STRUCTURE_NAME_p return varchar2;
	Function C_VERSION_NUMBER_p return number;
	Function C_PARENT_ORGANIZATION_NAME_p return varchar2;
	Function C_PAYROLL_NAME_p return varchar2;
	Function C_PAYROLL_PERIOD_p return varchar2;
	Function C_emp_det_param_disp_p return varchar2;
	Function CP_worker_type_desc_p return varchar2;
	Function CP_total_emp_newhire_p return number;
	Function CP_total_cwk_newhire_p return number;
	Function CP_total_emp_term_p return number;
	Function CP_total_cwk_term_p return number;
	Function CP_total_emp_transin_p return number;
	Function CP_total_cwk_transin_p return number;
	Function CP_total_emp_transout_p return number;
	Function CP_total_cwk_transout_p return number;
END PER_PAYRPEMV_XMLP_PKG;

/
