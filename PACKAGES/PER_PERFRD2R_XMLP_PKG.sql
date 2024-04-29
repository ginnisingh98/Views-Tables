--------------------------------------------------------
--  DDL for Package PER_PERFRD2R_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERFRD2R_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERFRD2RS.pls 120.0 2007/12/24 13:18:32 amakrish noship $ */
	P_ESTABLISHMENT_ID	number;
	P_YEAR_FIRST_OBLIGATION	number;
	P_YEAR	number;
	PC_1JAN	date;
	PC_31DEC	date;
	PC_31DEC_m varchar2(11);
	P_CONC_REQUEST_ID	number;
	PC_HIRE_YEAR	number;
	PC_YEAR_BECAME_PERMANENT	number;
	PC_JOB_TITLE	varchar2(240);
	PC_HOURS_TRAINING	number;
	PC_PCS_CODE	varchar2(32767);
	PC_UNITS_TOTAL	number;
	PC_UNITS_COEF	number;
	PC_UNITS_ACTUAL	number;
	PC_DISABLED_WHERE_CLAUSE	varchar2(32000);
	PC_HEADCOUNT_OBLIGATION	number;
	PC_HEADCOUNT_PARTICULAR	number;
	PC_BASIS_OBLIGATION	number;
	PC_OBLIGATION	number;
	PC_BREAKDOWN_PARTICULAR	varchar2(32000) := 'select ''00000000000000000000'' pc, 0 ph from dual' ;
	PC_COUNT_DISABLED	varchar2(32000) := '0=0;' ;
	function c_set_unitsformula(cotorep_category in varchar2, age in number, previous_cotorep in varchar2, disability_rate in number, due_to_wa in varchar2, disability_class_code in varchar2, pid in number) return number  ;
	function AfterPForm return boolean  ;
	function BeforeReport return boolean  ;
	function fc_set_job_infoformula(pid in number) return number  ;
	function g_disabled_empgroupfilter(disability_start_date in date, disability_end_date in date) return boolean  ;
	function AfterReport return boolean  ;
	Function PC_HIRE_YEAR_p return number;
	Function PC_YEAR_BECAME_PERMANENT_p return number;
	Function PC_JOB_TITLE_p return varchar2;
	Function PC_HOURS_TRAINING_p return number;
	Function PC_PCS_CODE_p return varchar2;
	Function PC_UNITS_TOTAL_p return number;
	Function PC_UNITS_COEF_p return number;
	Function PC_UNITS_ACTUAL_p return number;
	Function PC_DISABLED_WHERE_CLAUSE_p return varchar2;
	Function PC_HEADCOUNT_OBLIGATION_p return number;
	Function PC_HEADCOUNT_PARTICULAR_p return number;
	Function PC_BASIS_OBLIGATION_p return number;
	Function PC_OBLIGATION_p return number;
	Function PC_BREAKDOWN_PARTICULAR_p return varchar2;
	Function PC_COUNT_DISABLED_p return varchar2;
END PER_PERFRD2R_XMLP_PKG;

/
