--------------------------------------------------------
--  DDL for Package PAY_PAYUSTIM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYUSTIM_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYUSTIMS.pls 120.0 2007/12/28 06:48:20 srikrish noship $ */
	T_START_DATE varchar2(40);
	T_END_DATE varchar2(40);
	P_BUSINESS_GROUP_ID	number;
	P_REPORT_TITLE	varchar2(60);
	P_CONC_REQUEST_ID	number;
	P_START_DATE	date;
	P_CONSOLIDATION_SET_ID	varchar2(40);
	P_PAYROLL_ID	number;
	P_DEBUG	varchar2(32767);
	P_END_DATE	date;
	P_sort1	varchar2(32767);
	P_sort2	varchar2(32767);
	P_sort3	varchar2(32767);
	PACTID	number;
	P_GRE_ID	number;
	PPA_FINDER	number;
	des_type	varchar2(80);
	no_copies	number;
	CHNKNO	number;
	P_DIMENSION_NAME	number;
	CP_BUSINESS_GROUP_NAME	varchar2(240);
	CP_PAYROLL_NAME	varchar2(50);
	CP_GRE_NAME	varchar2(240);
	CP_CONSOLIDATION_SET_NAME	varchar2(100);
	CP_PRINT_SET_PAYROLL_NAME	varchar2(100);
	function AfterPForm return boolean  ;
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	function cf_1formula(assg_exp in varchar2) return char  ;
	function cf_ra_gra_plan_by_instformula(RA_GRA_PLAN_BY_INST1 in number) return number  ;
	function cf_ra_gra_plan_reductformula(RA_GRA_PLAN_REDUCT1 in number) return number  ;
	function cf_ra_plan_deductformula(RA_PLAN_DEDUCT1 in number) return number  ;
	function cf_ra_addl_reductformula(RA_ADDL_REDUCT1 in number) return number  ;
	function cf_ra_addl_deductformula(RA_ADDL_DEDUCT1 in number) return number  ;
	function cf_sra_gsra_reductformula(SRA_GSRA_REDUCT1 in number) return number  ;
	Function CP_BUSINESS_GROUP_NAME_p return varchar2;
	Function CP_PAYROLL_NAME_p return varchar2;
	Function CP_GRE_NAME_p return varchar2;
	Function CP_CONSOLIDATION_SET_NAME_p return varchar2;
	Function CP_PRINT_SET_PAYROLL_NAME_p return varchar2;
END PAY_PAYUSTIM_XMLP_PKG;

/
